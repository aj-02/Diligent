----------------------------------------------------------------------------------------------------
Main program     ZJV_SAPF100                               Level 0    Page 1
Object           ZJV_SAPF100                               Lines 4229
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:11
----------------------------------------------------------------------------------------------------
1      ***********************************************************************
2      * Date        Transport     USERID       Description
3      * 06/10/2008  <RD1K960036>  SAB_PUNIT    1) Added new include to
4      *                                           resolved the syntax error.
5      ***********************************************************************
6      * Foreign currency revaluation of open items AND balances
7      REPORT sapf100 MESSAGE-ID fr NO STANDARD PAGE HEADING. "#EC CI_USAGE_OK[2270335]
8
9      * database selection
10     TYPE-POOLS: rsds.
11
12     TABLES: tcurr, t001a,
13             t044a, t044b,
14             t001, t033, bsbw,
15             rfdt,
16             kna1,  knb1,
17             lfa1,   lfb1,
18             ska1,   skat, skb1,  ekko,
19             skc1c,                         "used for RFSBEW00
20             *skc1c,                                             "#EC NEEDED
21             bkpf, bseg, bsid, bsis, bsik,bsed, bsec,
22             x001, t030h, t003, t030b,  t009,t074,
23     *       t030hb, t030u, (no called with FB
24             bhdgd, fimsg,
25             rfsdo, sscrfields,rfpdo3,
26             zjv_fcurr_val.
27
28     * posting table
29     DATA:
30       BEGIN OF buchung OCCURS 10,       "Tabelle der gebuchten Betraege
31         hwtyp(1),
32         bukrs    LIKE bkpf-bukrs,
33         hkont    LIKE bseg-hkont,
34         budat    LIKE bkpf-budat,
35         belnr    LIKE bkpf-belnr,
36         post(6)  TYPE p,         "Zaehler / Schl. fuer Belege
37         buzei    LIKE bseg-buzei,
38         waers    LIKE bkpf-waers,
39         dmbtr    LIKE bseg-dmbtr,
40         hwaer    LIKE tcurd-hwaer,
41         bktxt    LIKE bkpf-bktxt,
42         bschl    LIKE bseg-bschl,
43         konto    LIKE bseg-hkont,
44
45         msgno    LIKE fimsg-msgno,
46         msgid    LIKE fimsg-msgid,
47         monat    LIKE bkpf-monat.
48     *       INCLUDE STRUCTURE RFSBEW_INCL.
49     DATA:  vbund      LIKE bseg-vbund,
50            gsber      LIKE bseg-gsber,
51            sgtxt      LIKE bseg-sgtxt,
52            faedt      LIKE bsega-netdt,
53            bdiff_rem  LIKE bseg-dmbe2,     "additional remeasurement   y
54            hwaer_rem  LIKE x001-hwae2,
55            dmbe2_t033 LIKE bseg-dmbe2,  "additional postings T033
56            dmbe3_t033 LIKE bseg-dmbe3,
57            dmbe1_t033 LIKE bseg-dmbe2,
58            fimsg      LIKE fimsg,
59            END OF buchung.
60
61     DATA: BEGIN OF tdd07v OCCURS 20.
62             INCLUDE STRUCTURE dd07v.
63     DATA: END OF tdd07v.
64
65     DATA  akonts LIKE bseg-hkont.          "rec.account from master record
66     INCLUDE fiuums40.                      "Umsetzung 4.0
67     * Tabelle fuer das Buchen
68     * contains all necessary data for posting the reval. differences
69     DATA:
70       BEGIN OF bu_waertab  OCCURS 50,   "Buchen der Bewertung
71         bukrs     LIKE bseg-bukrs,
72         curtp     LIKE t001a-curtp,
73         hwtyp(1),                                           " 1 2 3
74         storno(1),                     "      Flag für Stornbuchung
75         x_no_op,                       "      bei Saldenbewertung
76         hkont     LIKE bseg-hkont,
77         ta_waers  LIKE bkpf-waers,
78         vbund     LIKE bseg-vbund,
79         gsber     LIKE bseg-gsber.
80     *hier kommt der Variable Teil
81     *       INCLUDE STRUCTURE RFSBEW_INCL.
82     DATA:
83       aflag(1),                      "Betrag ist Aufwand
84       dmshb(12)     TYPE p,
85       hwaer         LIKE tcurd-hwaer,
86     *
87       bdiff_rem(12) TYPE p,          "remeasured value
88       hwaer_rem     LIKE tcurd-hwaer,  "remeasured
89     *
90       belnr         LIKE bseg-belnr,                              "
91       buzei         LIKE bseg-buzei,
92       END OF bu_waertab.
93     * already cleared items have to be reversed separatelly
94     * the old realized difference will be reversed and
95     * with the augdt
96     DATA:BEGIN OF bu_waertab_clear OCCURS 50,   "Buchen der Bewertung
97            augbl LIKE bseg-augbl,                              "
98            augdt LIKE bseg-augdt.
99             INCLUDE STRUCTURE bu_waertab.
100    DATA:   shkzg     LIKE bseg-shkzg,
101            new_belnr LIKE bseg-belnr,
102            new_budat LIKE bkpf-budat,
103            END OF bu_waertab_clear.
104    DATA: co_pa_flag.
105    DATA: sbew_special_periods(1).         "is marked to valuatae
106    "period 12-16 when P_period = 'X'
107    * batch-input
108    DATA: BEGIN OF ftpost OCCURS 20.
109            INCLUDE STRUCTURE ftpost.
110    DATA: END OF ftpost.
111
112    DATA: post_line     LIKE ftpost-count,     "zaehler buchungszeilen
113          post_count(6) TYPE p,            "anzahl gebuchter Belege
114          post_now(1).                     "wenn buchen
115    DATA: bi_filled_flag,                  "data in batch input session
116          bi_open_flag.                    "something was posted
117    * table contains wrong postings
118    DATA:
119         BEGIN OF bu_waertab_err  OCCURS 50.    "Buchen der Bewertung
120            INCLUDE STRUCTURE bu_waertab.
121    DATA:  text(80),
122          END OF bu_waertab_err.
123
124    * documents cleared sorted by clearing document
125    * the documents listed in new_belnr have to be reversed in case
126    * clearing reversal happens
127    DATA: BEGIN OF f100_bel OCCURS 100,
128            bukrs LIKE bkpf-bukrs,
129            augbl LIKE bseg-augbl,
130            augdt LIKE bseg-augdt,
131            belnr LIKE bkpf-belnr,
132            budat LIKE bkpf-budat,
133          END OF f100_bel.
134
135    DATA  curtp_rem LIKE t033-curtp.
136    DATA: gd_t033_rem LIKE t033.
137    DATA: hwtyp2, hwtyp3.
138
139    * fuer Pruefung Feld und Waehrung eines Waehrungstyps pro bukrs
140    DATA: BEGIN OF haus,
141            field(1),                      "in welchem feld steht die HW
142            waers    LIKE tcurd-hwaer,
143            curtp    LIKE x001-curt2,
144          END OF haus.
145    DATA: rem_haus  LIKE haus,
146          rem2_haus LIKE haus.
147
148    * used for testing
149    DATA:
150    *  is ebeln and ebelp for GR/IR accounts
151    *  is BSEG-REBZ
152    *  is belnr
153    *  is space for Saldenbewertung
154      BEGIN OF bezugsnr,
155        nr LIKE bseg-zuonr,         "fuer gruppierung von positione
156        ja LIKE bseg-gjahr,
157        zz LIKE bseg-buzei,
158      END OF bezugsnr,
159    *
160      ok LIKE sy-subrc.
161
162    * arranges the relevant document (by account or group )
163    * to determine the balance per currency to derive the rate
164    * and to revaluate
165    * all documents for one account
166    DATA: BEGIN OF belege OCCURS 300,
167            zbukr    LIKE bkpf-bukrs,
168            waers    LIKE bkpf-waers,    "evtl erste HW
169            bezugsnr LIKE bezugsnr,   "bezug pro
170            koart    LIKE bseg-koart,
171            konto    LIKE f107v-konto,
172            bukrs    LIKE bkpf-bukrs,    "Originalbuchungskreis
173            gsber    LIKE bseg-gsber.
174    *hier kommt der variable teil
175    *       INCLUDE STRUCTURE RFSBEW_INCL.
176    DATA:
177      gjahr      LIKE bkpf-gjahr,
178      belnr      LIKE bseg-belnr,
179      buzei      LIKE bseg-buzei,
180      shkzg      LIKE bseg-shkzg,
181      dmbtr(12)  TYPE p,
182      wrbtr(12)  TYPE p,
183      gbetr      LIKE bseg-gbetr,    "kurgesicherter Betrag
184      kursra(12),               "Kurssicherung aus Beleg
185      kursr(12),                "Kurs der Bewertung
186      umskz      LIKE bseg-umskz,
187      blart      LIKE bkpf-blart,
188      budat      LIKE bkpf-budat,
189      augbl      LIKE bseg-augbl,
190      augdt      LIKE bseg-augdt,
191      rdiff(12)  TYPE p,         "realiserte Differenz
192      rdiffn(12) TYPE p,        "realiserte Differenz neu
193      bdiff(12)  TYPE p,         "alte bewdiff
194      bwdiff(12) TYPE p,        "neue bewdiff
195      ta_waers   LIKE bkpf-waers,
196      hkont      LIKE bseg-hkont,
197      vbund      LIKE bseg-vbund,
198      wflag(1)   TYPE c,          "reset revaluation
199      bdiff_rem  LIKE belege-bwdiff, "remeasured difference
200
201
202    * just for information - not used in logic
203      hwtyp(1),
204      curtp      LIKE t001a-curtp,
205      dmbe2(12)  TYPE p,
206      dmbe3(12)  TYPE p,
207      bdif2(12)  TYPE p,        "alte bewdiff  2
208      bwdif2(12) TYPE p,        "neue bewdiff  2
209      bdif3(12)  TYPE p,        "alte bewdiff  3
210      bwdif3(12) TYPE p,        "neue bewdiff  3
211      rdif2(12)  TYPE p,        "realiserte Differenz
212      rdif3(12)  TYPE p,        "realiserte Differenz
213      END OF belege.
214    DATA: bdiff_delta(12) TYPE p.          "delta new /old difference
215    * used to sort the data
216    * it is empty when a grouping by konzern or BEWGP is used
217    DATA: BEGIN OF sort,
218            koart     LIKE bseg-koart,
219            hkont     LIKE bseg-hkont,
220            vbund     LIKE bseg-vbund,
221    *        konto like belege-konto,
222            konto(30), "account + empfg
223
224          END OF sort.
225    *locks an account during the update
226    DATA: BEGIN OF lock_tab OCCURS 0,
227            bukrs LIKE bkpf-bukrs,
228            koart LIKE bseg-koart,
229            konto LIKE belege-konto,
230          END OF lock_tab.
231    DATA: locked LIKE sy-subrc.            "lock is ok
232    * all documents associated to one posting
233    DATA: BEGIN OF belege_upd OCCURS 300,
234            bukrs     LIKE bkpf-bukrs,
235            gjahr     LIKE bkpf-gjahr,
236            belnr     LIKE bseg-belnr,
237            buzei     LIKE bseg-buzei,
238            hwtyp     LIKE belege-hwtyp,
239            bdiff     LIKE bseg-bdiff,
240            rdiff     LIKE bseg-rdiff,
241            augbl     LIKE bseg-augbl,
242            bdiff_rem LIKE bseg-bdiff,
243          END OF belege_upd.
244    DATA:  t_bsbw LIKE bsbw OCCURS 0 WITH HEADER LINE.
245    DATA:  t_bsbw_new LIKE bsbw OCCURS 0 WITH HEADER LINE.
246    *======================*
247    * declarations for ALV *
248    *======================*
249    INCLUDE <line>.
250    INCLUDE <icon>.
251    *
252    DATA: h_variant        LIKE disvariant.
253    DATA: selkey LIKE sy-tabix.            "counter fuer Konten
254    * type pool declarations
255    TYPE-POOLS: slis.
256    DATA:   gl_bhdgd         TYPE bhdgd.
257    DATA:   t_fieldcat          TYPE slis_t_fieldcat_alv WITH HEADER LINE,
258            t_events            TYPE slis_t_event WITH HEADER LINE,
259            t_event_exit        TYPE slis_t_event_exit WITH HEADER LINE,
260            t_slis_sort         TYPE slis_t_sortinfo_alv,
261            t_slis_layout_alv   TYPE slis_layout_alv,
262            t_slis_print_alv    TYPE slis_print_alv,
263            gt_list_top_of_page TYPE slis_t_listheader,
264            h_tabname_header    TYPE slis_tabname,
265            h_tabname_item      TYPE slis_tabname,
266
267            h_repid             LIKE sy-repid,
268            h_user_command      TYPE slis_formname,
269            h_set_pf_status     TYPE slis_formname.
270    * zweite tabelle (Druck Buchungen)
271    DATA: caller(40).
272    DATA:   t2_fieldcat       TYPE slis_t_fieldcat_alv WITH HEADER LINE.
273    * dritte tabelle Druck der Meldungen
274    DATA:   t3_fieldcat       TYPE slis_t_fieldcat_alv WITH HEADER LINE.
275
276    DATA: BEGIN OF t_fimsg OCCURS 100.
277            INCLUDE STRUCTURE fimsg.
278    DATA: END OF t_fimsg.
279
280    *===========*
281    * Main list *
282    *===========*
283    DATA: BEGIN OF list_item OCCURS 100,
284            zbukr      LIKE bwpos-zbukr,
285            bewgp      LIKE bwpos-gruppe,
286            koart      LIKE bseg-koart,
287            hkont      LIKE bseg-hkont,
288            altkt      LIKE skb1-altkt,
289            konto      LIKE f107v-konto,
290    * hier kommen die Belege
291            waers      LIKE bkpf-waers,
292            bezugsnr   LIKE bezugsnr,          "bezug pro
293            gsber      LIKE bseg-gsber,
294            gjahr      LIKE bkpf-gjahr,
295            belnr      LIKE bseg-belnr,
296            buzei      LIKE bseg-buzei,
297            shkzg      LIKE bseg-shkzg,
298            wrbtr(10)  TYPE p,
299            dmbtr(10)  TYPE p,
300            bwwrt(10)  TYPE p,                "bewerteter Betrag
301            gbetr      LIKE bseg-gbetr,           "kurgesicherter Betrag
302            kursra     LIKE bseg-kursr,
303            kursr      LIKE resreval-kursu,       "verwendeter Kurs like kursu
304            umskz      LIKE bseg-umskz,
305            kursf      LIKE bkpf-kursf,           "Anschaffungskurs
306    *      kursf like revalc-fw_ankurs,
307            blart      LIKE bkpf-blart,
308            budat      LIKE bkpf-budat,
309            augbl      LIKE bseg-augbl,
310            bdiff      LIKE bwpos-bwshb_old,      "old diff
311            bwdiff     LIKE bwpos-bwshb_net,     "neue bewdiff
312            bubetr(10) TYPE p,               "differenz die gebucht wird
313    *      bubetr(10) like bseg-dmbtr,          "differenz die gebucht wird
314            rdiff      LIKE bseg-rdiff,          "realiserte Differenz
315            rdiffn     LIKE bseg-rdiff,          "realiserte Differenz
316            bukrs      LIKE bkpf-bukrs,           "Originalbuchungskreis
317            vbund      LIKE bseg-vbund,
318            txt50      LIKE skat-txt50.           "Sachkontenlangtext
319    DATA: bdiff_rem LIKE bwpos-bwshb_net.  "remeasured difference
320    DATA: hwaer_rem LIKE x001-hwae2.
321    * variabler teil
322    *       INCLUDE STRUCTURE RFSBEW_INCL.
323    DATA:
324      hwaer LIKE tcurd-hwaer,
325    *     selkey      like sy-tabix,
326      END OF list_item.
327    *
328    *=========*
329    * end ALV *
330    *=========*
331
332    DATA:
333      cnt_belg TYPE i,               "belegzaehler gesamt
334
335      maxup(8) TYPE n VALUE 1000,      "allow 1000 updates per posting
336      anzup(8) TYPE n.
337
338
339    *information about active currency types and
340    DATA: BEGIN OF bk_methode OCCURS 20,   "Methoden pro bukrs
341            bukrs      LIKE bkpf-bukrs,
342            meth1      LIKE t044a-bwmet,        "Bewertungsmethode
343            meth2      LIKE t044a-bwmet,
344            meth3      LIKE t044a-bwmet,
345            hwae1      LIKE tcurd-hwaer,        "Hauswaehrung
346            hwae2      LIKE t001-waers,
347            hwae3      LIKE t001-waers,
348            curt1      LIKE x001-curt2,         "waehrungstyp 10,30..60
349            curt2      LIKE x001-curt2,
350            curt3      LIKE x001-curt2,
351            curs2      LIKE x001-basw2,
352            curs3      LIKE x001-basw2,
353            hwaer_rem  LIKE t001-waers,
354            typ_rem(1),
355          END OF bk_methode.
356
357    DATA: dk_konzs LIKE kna1-konzs.        "Summenfeld
358
359
360    * SKV accounts should not be valuated
361    DATA: BEGIN OF t030skv OCCURS 300,
362            hkont LIKE bsis-hkont,
363          END OF t030skv.
364
365    * these are the GR/IR accounts
366    DATA: BEGIN OF t_grir OCCURS 10,
367            ktopl LIKE t001-ktopl,
368            hkont LIKE bseg-hkont,
369          END OF t_grir,
370          grir_flag.                       "is a gr/ir account
371    DATA: flag_onli.
372    CONSTANTS:
373      xon TYPE xfeld        VALUE 'X',      "Flag eingeschaltet
374      off TYPE xfeld        VALUE ' '.      "Flag ausgeschaltet
375    *   no_entry  TYPE cfeld        VALUE '!'.      "Kein Eintrag
376    * daten fuer bewertungsbereiche
377    CONSTANTS:
378      methode LIKE bsbw-methd VALUE '1'.   "muss 1 sein = FW Bewertung
379
380    RANGES: curr_sel FOR bkpf-waers.
381    * wird später fuer RFSBEW00_incl benoetigt, damit nicht von-bis Wert
382    TYPE-POOLS: sscr.
383    * Definition des Objekts, das an den  RESTRICTION übergeben
384    DATA restrict TYPE sscr_restrict.
385    * Hilfsobjekte zum Füllen von RESTRICT
386    DATA: opt_list TYPE sscr_opt_list,
387          ass      TYPE sscr_ass.
388
389    * free selections.
390    DATA: fs_f1_icon LIKE smp_dyntxt.      "f1 taste
391    DATA: lfa1_clauses        TYPE rsds_where,  lfa1_clauses_filled.
392    DATA: lfb1_clauses        TYPE rsds_where,  lfb1_clauses_filled.
393    DATA: bsik_clauses        TYPE rsds_where,  bsik_clauses_filled.
394
395    DATA: kna1_clauses        TYPE rsds_where,  kna1_clauses_filled.
396    DATA: knb1_clauses        TYPE rsds_where,  knb1_clauses_filled.
397    DATA: bsid_clauses        TYPE rsds_where,  bsid_clauses_filled.
398
399    DATA: ska1_clauses        TYPE rsds_where,  ska1_clauses_filled.
400    DATA: skb1_clauses        TYPE rsds_where,  skb1_clauses_filled.
401    DATA: gt_callback LIKE ldbcb    OCCURS 0 WITH HEADER LINE,
402          seltab      TYPE rsparams OCCURS 0 WITH HEADER LINE.
403    DATA: bsis_clauses        TYPE rsds_where,  bsis_clauses_filled.
404
405    DATA: bseg_clauses        TYPE rsds_where,  bseg_clauses_filled.
406    DATA: bkpf_clauses        TYPE rsds_where,  bkpf_clauses_filled.
407    *
408    DATA: sdf_expressions TYPE rsds_texpr. "for SDF
409    DATA: sdf_expressions_line TYPE rsds_expr. "for SDF
410
411    *==================================*
412    * declarations for application log *
413    *==================================*
414    * global data
415    DATA: g_s_log      TYPE bal_s_log,
416          g_log_handle TYPE balloghndl,
417          g_dummy      TYPE c,
418          g_e_msg      TYPE  boolean.
419
420    * priority clas
421    CONSTANTS:
422      probclass_very_high TYPE bal_s_msg-probclass VALUE '1',
423      probclass_high      TYPE bal_s_msg-probclass VALUE '2',
424      probclass_medium    TYPE bal_s_msg-probclass VALUE '3',
425      probclass_low       TYPE bal_s_msg-probclass VALUE '4',
426      probclass_none      TYPE bal_s_msg-probclass VALUE ' '.
427    * message types
428    CONSTANTS:
429      msgty_x    TYPE sy-msgty            VALUE 'X',
430      msgty_a    TYPE sy-msgty            VALUE 'A',
431      msgty_e    TYPE sy-msgty            VALUE 'E',
432      msgty_w    TYPE sy-msgty            VALUE 'W',
433      msgty_i    TYPE sy-msgty            VALUE 'I',
434      msgty_s    TYPE sy-msgty            VALUE 'S',
435      msgty_none TYPE sy-msgty            VALUE ' '.
436    DATA: t_spono LIKE schedman_spool .
437    DATA: gt_spono LIKE t_spono OCCURS 0.
438
439    INCLUDE rkasmawf.             "<     necessary for Workflow
440    INCLUDE schedman_events.          "Events for Wokflow
441
442    DEFINE check_currency.
443    * check foreign currency
444      if p_curtp1 = '10'.
445        check &1 ne t001-waers.
446      elseif p_curtp1 = bk_methode-curt2.
447        if bk_methode-curs2 = '1'.
448          check &1 ne bk_methode-hwae2.
449        endif.
450      elseif p_curtp1 = bk_methode-curt3.
451        if bk_methode-curs3 = '1'.
452          check &1 ne bk_methode-hwae3.
453        endif.
454      elseif p_curtp1 <> bk_methode-curt3.
455        check 0 = 1.                       "keine parallele Währung
456      endif.
457    END-OF-DEFINITION.
458    *===================*
459    * selection-screens *
460    *===================*
461    SELECTION-SCREEN FUNCTION KEY 1.       "free selectons
462
463    SELECTION-SCREEN BEGIN OF BLOCK 001
464                     WITH FRAME.           "TITLE TEXT-001.
465    SELECT-OPTIONS:
466                bukrs      FOR bkpf-bukrs.
467    PARAMETERS: stichtag LIKE rfpdo-sbewstag,
468                bwmet1   LIKE rfpdo1-f100meth.
469    * currencytyp and reval-area
470    SELECTION-SCREEN BEGIN OF LINE.
471    SELECTION-SCREEN COMMENT 1(30) text-069.
472    SELECTION-SCREEN POSITION POS_LOW.
473    PARAMETERS: p_curtp1 LIKE rfpdo3-sbewcurtp  DEFAULT '10'.
474
475    SELECTION-SCREEN COMMENT 42(25) text-062.
476    SELECTION-SCREEN POSITION 70.
477    PARAMETERS:
478               p_bwber       LIKE rfpdo3-allgbwbe.
479    SELECTION-SCREEN END OF LINE.
480    *
481    SELECTION-SCREEN END OF BLOCK 001.
482    *Batch input --------------------------------------------------------
483    SELECTION-SCREEN BEGIN OF SCREEN 1020 AS SUBSCREEN.
484    PARAMETERS: post_upd LIKE rfpdo-f100pupd MODIF ID sld.
485    PARAMETERS: no_post(1) NO-DISPLAY.         "used be JVA
486    PARAMETERS: par_bi LIKE rfpdo1-f100buch   DEFAULT ' '.
487    PARAMETERS: par_bnam LIKE rfpdo-allgbina,
488    *           par_sgtx  like bseg-sgtxt,
489                p_bldat  LIKE rfpdo-allgedat,
490                p_bbudat LIKE rfpdo-allgbdat,    "Buchungsdatum
491                p_bbupem LIKE rfpdo-allgbupe,    "Buper-Monat
492                st_budat LIKE rfpdo-allgsdat,    "Buchungsdatum storno
493                p_sbupem LIKE rfpdo-allgsbup.    "Buper-Monat   storno
494    *Do not use t030h von non OI accounts
495    PARAMETERS: no_t030h(1) NO-DISPLAY  DEFAULT ' '.
496    SELECTION-SCREEN SKIP 1.
497    PARAMETERS: p_storno   LIKE rfpdo3-allgstor DEFAULT ' '.    "
498    *----flex hauptbuch
499    SELECT-OPTIONS:
500                 incl_fld  FOR rfpdo3-sbewfnam         "Feldnamen
501                           NO INTERVALS NO-DISPLAY.    "not supported yet
502
503    **** Added by SAB_KBHAT on 13.01.2006
504
505    SELECTION-SCREEN SKIP 2.
506
507    SELECT-OPTIONS: s_vname FOR bseg-vname NO-EXTENSION OBLIGATORY,
508                    s_recid FOR bseg-recid NO-EXTENSION OBLIGATORY,
509                    s_egrup FOR bseg-egrup NO-EXTENSION OBLIGATORY.
510
511    **** End of addition by SAB_KBHAT
512
513    SELECTION-SCREEN END OF SCREEN 1020.
514    *---Output information  --------------------------------------------
515    SELECTION-SCREEN BEGIN OF SCREEN 1060 AS SUBSCREEN.
516    *sELECTION-SCREEN COMMENT 1(40) text-069.
517    SELECTION-SCREEN: BEGIN OF LINE.
518    SELECTION-SCREEN COMMENT 1(30) text-029.
519    SELECTION-SCREEN POSITION POS_LOW.
520    PARAMETERS p_lvar   LIKE h_variant-variant DEFAULT space.
521    SELECTION-SCREEN POSITION POS_HIGH.
522    SELECTION-SCREEN: PUSHBUTTON (15) text-028 USER-COMMAND con1.
523    SELECTION-SCREEN END OF LINE.
524    PARAMETERS:
525      title  LIKE rfpdo-allgline,
526      xaltkt LIKE rfpdo1-allgaltk.   "alternative ktonummer
527    PARAMETERS:          filename LIKE rfpdo1-f100xfil.
528    PARAMETERS:          p_zbukrs LIKE rfpdo3-allgzbuk.
529    * Zusammenfassung und Buchung in den Zielbukrs (auch Customizing)
530    SELECTION-SCREEN END OF SCREEN 1060.
531    *----FASB 52---------------------------------------------------------
532    SELECTION-SCREEN BEGIN OF SCREEN 1011 AS SUBSCREEN.
533
534    SELECTION-SCREEN BEGIN OF BLOCK 6 WITH FRAME TITLE text-055.
535
536    PARAMETER:           p_remon
537    *                              as checkbox,
538                                   LIKE rfpdo3-f100xrem,
539                         p_remsct LIKE tcurr-kurst DEFAULT 'M',
540                         p_bwber2 LIKE rfpdo3-sbewrembwber.
541    SELECTION-SCREEN END OF BLOCK 6.
542    *election-screen skip 1.
543    SELECTION-SCREEN BEGIN OF BLOCK 7 WITH FRAME TITLE text-060.
544    *
545    PARAMETER:           p_transl LIKE rfpdo3-sbewtrans.
546    SELECTION-SCREEN BEGIN OF LINE.
547    SELECTION-SCREEN COMMENT 1(30) text-063 FOR FIELD fromctp.
548    SELECTION-SCREEN POSITION POS_LOW.
549    PARAMETERS:fromctp LIKE  rfpdo3-sbewcurtp.
550    SELECTION-SCREEN COMMENT 42(25) text-062 FOR FIELD frombwb.
551    SELECTION-SCREEN POSITION 58.
552    SELECTION-SCREEN POSITION 70.
553    PARAMETERS:  frombwb LIKE rfpdo3-allgbwbe.
554    SELECTION-SCREEN END OF LINE.
555
556    SELECTION-SCREEN END OF BLOCK 7.
557    SELECTION-SCREEN END OF SCREEN 1011.
558
559    *--------Selections for AP and AR---------------------------------------
560    SELECTION-SCREEN BEGIN OF SCREEN 1080 AS SUBSCREEN.
561    SELECTION-SCREEN BEGIN OF BLOCK ap1.
562    PARAMETERS:      x_ap     LIKE rfpdo-f010kred  DEFAULT ' '.
563    SELECT-OPTIONS:  kkonto   FOR lfb1-lifnr  MATCHCODE OBJECT kred.
564    PARAMETERS:      x_ar     LIKE rfpdo-f010debi DEFAULT ' '.
565    SELECT-OPTIONS:  dkonto   FOR knb1-kunnr  MATCHCODE OBJECT debi.
566    *
567    SELECT-OPTIONS:  akonto   FOR bseg-hkont  MATCHCODE OBJECT sako.
568    SELECTION-SCREEN END OF BLOCK ap1.
569    SELECTION-SCREEN END OF SCREEN 1080.
570    *-select options for GL Accounts------------------------------------
571    SELECTION-SCREEN BEGIN OF SCREEN 1050 AS SUBSCREEN.
572
573    SELECTION-SCREEN BEGIN OF BLOCK gl1.
574    PARAMETERS:      x_gl     LIKE rfpdo-f123sakn DEFAULT ' '.
575    PARAMETER:       x_salbew AS    CHECKBOX.
576    SELECT-OPTIONS:  skonto   FOR bseg-hkont  MATCHCODE OBJECT sako.
577    *
578    PARAMETERS:      pa_weren  RADIOBUTTON GROUP 0001. "no were
579    PARAMETERS:      pa_were  LIKE rfpdo1-f100were
580                                 RADIOBUTTON GROUP 0001. "use po data
581    PARAMETERS:      pa_weref RADIOBUTTON GROUP 0001. "use FI data
582    *
583    SELECT-OPTIONS:  s_gracc  FOR rfpdo3-f100graccts. "WE/RE accts
584
585    PARAMETERS:     p_plcacc LIKE rfpdo3-sbewplc,
586                    p_period LIKE rfpdo3-sbewbalance.
587    *select-options      s_no_acc for rfsdo-sbewnoac.
588    SELECT-OPTIONS:     s_kdfsl    FOR skb1-kdfsl.
589    SELECT-OPTIONS:     s_gsber    FOR skc1c-gsber.
590
591    SELECTION-SCREEN END OF BLOCK gl1.
592
593    SELECTION-SCREEN END OF SCREEN 1050.
594    *---------------------------------------------------------------------
595
596    * gl and ap and ar
597    SELECTION-SCREEN BEGIN OF SCREEN 1100 AS SUBSCREEN.
598    SELECTION-SCREEN INCLUDE BLOCKS gl1.
599    *election-screen skip 1.
600    SELECTION-SCREEN INCLUDE BLOCKS ap1.
601    SELECT-OPTIONS:  belnr    FOR bkpf-belnr,
602                     waehrung FOR bkpf-waers.
603    SELECTION-SCREEN END OF SCREEN 1100.
604    PARAMETER:
605
606               fs_dyns TYPE rsds_type NO-DISPLAY,
607               fs_num LIKE sy-tfill   NO-DISPLAY.
608
609
610    *---------------------------------------------------------------------
611    *-----------------------------------------------------------------------
612    *PARAMETERS:
613    *                 P_NOSTOR RADIOBUTTON GROUP 0001,
614    *                 P_RESTOR RADIOBUTTON GROUP 0001,
615    *                 P_STORE   RADIOBUTTON GROUP 0001,
616    *                 STOR_NAM LIKE RFPDO3-ALLGALVNAM.
617    DATA:             p_nostor,
618                      p_restor,
619                      p_store,
620                      stor_nam.
621
622
623
624    *-----------------------------------------------------------------------
625    SELECTION-SCREEN BEGIN OF TABBED BLOCK tabbl FOR 16 LINES.
626
627    SELECTION-SCREEN TAB (16) tabs1020 USER-COMMAND ucom1020
628                         DEFAULT SCREEN 1020.
629    SELECTION-SCREEN TAB (15) tabs1100 USER-COMMAND ucom1100
630                         DEFAULT SCREEN 1100.
631    SELECTION-SCREEN TAB (15) tabs1060 USER-COMMAND ucom1060
632                         DEFAULT SCREEN 1060.
633    SELECTION-SCREEN TAB (15) tabs1011 USER-COMMAND ucom1011
634                         DEFAULT SCREEN 1011.
635
636
637    SELECTION-SCREEN END OF BLOCK tabbl.
638    ************************************************************************
639
640
641    FIELD-GROUPS: header,
642                  daten.                   "Einzelbelege
643
644    INSERT belege-zbukr                    "evtl zielbukr
645             skb1-xopvw                    "to separate between nop and ops
646             dk_konzs                      "summenbegriff
647             sort-koart
648             sort-hkont
649             sort-vbund
650             sort-konto
651           belege-waers
652                        INTO header.
653    INSERT:  belege
654                    INTO daten.
655
656    FIELD-SYMBOLS: <fwsaldo>, <hwsaldo>, <hwsaldo1>.
657
658    INITIALIZATION.
659
660      tabs1060 = 'Ausgabe'(001).
661      tabs1020 = 'Buchungen'(003).
662      tabs1011 = 'FASB52'(012).
663      tabs1100 = 'Selektionen'(014).
664
665
666
667
668      opt_list-name = xon.
669      opt_list-options-eq = xon.
670      APPEND opt_list TO restrict-opt_list_tab.
671      ass-kind = 'S'.
672      ass-name = 'INCL_FLD'.
673      ass-sg_main = 'I'.
674      ass-sg_addy = ' '.
675      ass-op_main = xon.
676      ass-op_addy = xon.
677      APPEND ass TO restrict-ass_tab.
678      CALL FUNCTION 'SELECT_OPTIONS_RESTRICT'
679        EXPORTING
680          restriction = restrict
681        EXCEPTIONS
682          OTHERS      = 1.
683
684    *--alv used for F4
685      h_repid = sy-repid.
686      h_variant-report     = h_repid.
687      h_variant-log_group  = '0001'.
688
689    * Setzen Default-Sichtag
690      stichtag = sy-datlo.
691      stichtag+6(2) = '01'.
692      stichtag = stichtag - 1.
693
694    * icon freie selection
695      PERFORM fs_set_sscrtexts_dynsel CHANGING fs_f1_icon.
696      sscrfields-functxt_01 = fs_f1_icon.
697    * psb = fs_F1_icon-ICON_TEXT .
698
699
700    AT SELECTION-SCREEN OUTPUT.
701      IF sy-dynnr = '1100' OR sy-dynnr = '1000'.
702        PERFORM fs_set_sscrtexts_dynsel CHANGING fs_f1_icon.
703    *    PSB =  fs_F1_icon-icon_text.
704        sscrfields-functxt_01 = fs_f1_icon.
705      ENDIF.
706    *
707    * PERFORM: FLEX_FELDER_ERL_AUFBAUEN USING 'RFSBEW_INCL'.
708    **** Added by SAB_KBHAT on 13.01.2006
709
710      PERFORM fill_custom_fields.
711
712    **** End of Addition by SAB_KBHAT
713
714    AT SELECTION-SCREEN ON bukrs.
715      IF sy-dynnr = '1000'.
716        CALL FUNCTION 'BUKRS_AUTHORITY_CHECK'
717          EXPORTING
718            xdatabase = 'B'
719          TABLES
720            xbukreis  = bukrs.
721      ENDIF.
722
723    AT SELECTION-SCREEN ON p_zbukrs.
724      IF p_zbukrs <> space AND sy-dynnr = '1060'.
725        SELECT SINGLE * FROM t001 WHERE bukrs = p_zbukrs.
726        IF sy-subrc <> 0.
727          MESSAGE e058(00) WITH  p_zbukrs space space space.
728        ENDIF.
729      ENDIF.
730
731    AT SELECTION-SCREEN ON stichtag.
732      IF stichtag IS INITIAL.
733        MESSAGE e361.
734      ENDIF.
735
736    AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_lvar.
737      h_variant-variant = p_lvar.
738      PERFORM f4_for_s_lvar   USING h_variant.
739      p_lvar = h_variant-variant.
740    *AT SELECTION-SCREEN ON VALUE-REQUEST FOR stor_nam.
741    ** PERFORM f4_for_stor_nam   USING stor_nam.
742
743    AT SELECTION-SCREEN ON bwmet1.
744      IF t044a-bwmet NE bwmet1 AND bwmet1 <> space.
745        SELECT SINGLE * FROM t044a WHERE bwmet =  bwmet1.
746        IF sy-subrc NE 0.
747          MESSAGE e362.
748        ENDIF.
749      ENDIF.
750      IF bwmet1 = space
751        AND ( sscrfields-ucomm = 'ONLI' OR sscrfields-ucomm = 'PRIN' ).
752        CLEAR sscrfields-ucomm.
753        MESSAGE e055(00).
754      ENDIF.
755
756
757
758    AT SELECTION-SCREEN ON p_bwber.
759      IF p_bwber2 = p_bwber AND p_bwber NE space.
760        MESSAGE e012.
761      ENDIF.
762
763    AT SELECTION-SCREEN ON p_bwber2.
764      IF sy-dynnr = '1011'.
765        IF NOT p_bwber2 IS INITIAL.
766          SELECT SINGLE * FROM t033 WHERE bwber = p_bwber2.
767          IF sy-subrc NE 0.
768            MESSAGE e058(00) WITH p_bwber2 space space space.
769          ENDIF.
770    * remeasurement not in lc (because posting would not work)
771          IF t033-curtp = p_curtp1 AND p_remon <> space.        "H335756
772            MESSAGE e011.
773          ENDIF.
774          PERFORM check_curtp USING t033-curtp.
775          IF p_bwber2 = p_bwber.
776            MESSAGE e012.
777          ENDIF.
778        ENDIF.
779      ENDIF.
780    *AT SELECTION-SCREEN ON INCL_FLD.
781    *  PERFORM CHECK_INCL_FLD.
782
783    *AT SELECTION-SCREEN ON VALUE-REQUEST FOR INCL_FLD-LOW.
784    *  PERFORM F4_FOR_INCL_FLD USING INCL_FLD-LOW.
785
786
787
788    *-----------------------------------------------------------------------
789    AT SELECTION-SCREEN.
790    * Auf die User-Commands reagieren
791      CASE sscrfields-ucomm.
792    *   WHEN 'UCOMM1'.                     "Tabreiter wechseln
793    *     tabstrip-activetab = 'UCOMM1'.
794    *     tabstrip-dynnr = 1.
795        WHEN 'UCOM1100'.
796    *  change screen for A/P
797    *     if sy-tcode = 'F.05'.
798    *     if ( X_AP <> space or X_ar <> space )
799    *       and ( X_GL = space and x_salbew = space ).
800    *       tabbl-dynnr   = 1100.
801    *     endif.
802
803        WHEN 'SEL1'.
804          IF sy-dynnr = '1100'.            "Selektionen
805            CLEAR: sy-ucomm, sscrfields-ucomm.
806            PERFORM free_selections.
807            CHECK 0 = 1.
808          ENDIF.
809        WHEN 'FC01'.                       "function key
810          IF sy-dynnr = '1000'.                                 "
811            CLEAR: sy-ucomm, sscrfields-ucomm.
812            PERFORM free_selections.
813            CHECK 0 = 1.
814          ENDIF.
815        WHEN 'CON1'.                       "Ausgabeliste konfigurieren
816    *     if sy-dynnr = '1000'.
817          IF sy-dynnr = '1000'.
818            PERFORM list_config_list USING 'SAPF100'
819                                           'LISTE'.  "which form
820          ENDIF.
821      ENDCASE.
822      IF sy-dynnr = '1000'.
823        IF p_bwber NE space.
824          SELECT SINGLE * FROM t033 WHERE bwber = p_bwber.
825          IF sy-subrc NE 0.
826            MESSAGE e058(00) WITH p_bwber space space space.
827          ELSE.
828            p_curtp1 = t033-curtp.
829          ENDIF.
830        ENDIF.
831        IF p_curtp1 = space. MESSAGE e055(00). ENDIF.
832        PERFORM check_curtp USING p_curtp1.
833      ENDIF.
834
835    *     for update you need a valuation area
836      IF post_upd <> space AND p_remon <> space AND p_bwber = space.
837        MESSAGE  e014.
838    *        'Bei bilanzwirksamer Bewertung und'
839    *        'und Bewertungsdifferenz umrechnen'
840    *        'muss ein Bewertungsbereich verwendet werden'.
841      ENDIF.
842
843    *------1011
844      IF sy-dynnr = '1011'.
845        IF NOT frombwb IS INITIAL.
846          SELECT SINGLE * FROM t033 WHERE bwber = frombwb.
847          IF sy-subrc NE 0.
848            MESSAGE e058(00) WITH frombwb space space space.
849          ENDIF.
850          fromctp = t033-curtp.
851
852          IF frombwb = p_bwber.
853            MESSAGE e012.
854          ENDIF.
855        ENDIF.
856        PERFORM check_curtp USING fromctp.
857
858
859        IF p_remon <> space AND p_transl <> space.
860          MESSAGE e329.
861        ENDIF.
862        IF p_transl <> space.
863          IF fromctp IS INITIAL.
864            MESSAGE e055(00).
865          ENDIF.
866          IF fromctp NE '10'.
867            MESSAGE e013.
868          ENDIF.
869        ENDIF.
870        IF p_remon <> space.
871          curtp_rem = space.
872          SELECT SINGLE curtp
873                          FROM t033 INTO curtp_rem
874                                    WHERE bwber = p_bwber2.
875          IF curtp_rem = space.
876            MESSAGE e055(00).
877          ENDIF.
878        ENDIF.
879      ENDIF.
880    *---------------
881    * perform check_bwmetxx using bwmet1.
882    * if p_curtp1 = space. message e055(00). endif.
883
884    * belegupdate geht nur mit batchinput
885      IF post_upd NE space.
886        IF par_bi IS INITIAL.
887          par_bi = 'X'.
888          MESSAGE i584.
889        ENDIF.
890        IF par_bnam = space.
891          par_bnam = sy-repid.
892        ENDIF.
893      ENDIF.
894    **** Added by SAB_KBHAT on 13.01.2006
895
896      PERFORM fill_custom_fields.
897
898    **** End of Addition by SAB_KBHAT
899    *--check only if user enters start
900      CHECK sscrfields-ucomm = 'ONLI' OR sscrfields-ucomm = 'PRIN'.
901    * if x_salbew = 'X'.
902    *   perform s_build_noacc.
903    * endif.
904
905
906      PERFORM check_before_start.
907      CLOSE DATASET filename.
908      IF sscrfields-ucomm = 'ONLI'.
909        flag_onli = 'X'.
910      ELSE.
911        flag_onli = ' '.
912      ENDIF.
913    ************************************************************************
914    START-OF-SELECTION.
915
916    ****  Added by SAB_KBHAT on 13.01.2006
917      PERFORM buffer_selection.
918    ****  End of addition by SAB_KBHAT
919      CLEAR gt_callback.
920    ** for reval areas store the values ALWAYS
921      IF p_bwber <> space AND par_bi <> space.
922        post_upd = 'X'.
923      ENDIF.
924    **
925    * display old values
926    *  IF STOR_NAM NE SPACE AND P_RESTOR NE SPACE.
927    *    PERFORM RESTORE.
928    *    EXIT.
929    *  ENDIF.
930
931      PERFORM log_almsg_init.
932      PERFORM schedman_start_stop USING 'START'.
933
934    * Batch-Input-Vorarbeiten
935      IF p_bbudat IS INITIAL.
936        p_bbudat = stichtag.
937      ENDIF.
938
939      IF st_budat IS INITIAL.
940        st_budat = p_bbudat + 1.
941      ENDIF.
942
943      IF p_bldat IS INITIAL.
944        p_bldat = p_bbudat.
945      ENDIF.
946
947      PERFORM read_t044a USING  bwmet1.
948
949    * estimate gr_ir accounts
950      PERFORM gr_ir_build_tab.
951      CLEAR t001.
952
953      PERFORM check_before_start.
954    * lock company code
955      IF post_upd <> space AND p_bwber = space.
956        PERFORM enqueue USING 'ON'.
957        PERFORM set_t042x.
958      ENDIF.
959      COMMIT WORK.
960
961    * Tabelle UMS40 wegen Umsetzung nach 4.0 einlesen
962      IMPORT ums40 FROM DATABASE rfdt(fu) ID 'UMS40'.
963
964      CLEAR haus.
965
966      IF p_bwber NE space.
967        SELECT SINGLE * FROM t033 WHERE bwber = p_bwber.
968        IF sy-subrc NE 0.
969          MESSAGE e058(00) WITH p_bwber space space space.
970        ENDIF.
971    *   set variables
972        p_curtp1 = t033-curtp.
973      ENDIF.
974
975      IF NOT p_bwber2 IS INITIAL.
976        SELECT SINGLE *
977                        FROM t033 INTO gd_t033_rem
978                                  WHERE bwber = p_bwber2.
979        curtp_rem = gd_t033_rem-curtp.
980      ENDIF.
981      IF NOT frombwb IS INITIAL.
982        SELECT SINGLE curtp
983                        FROM t033 INTO fromctp
984                                  WHERE bwber = frombwb.
985      ENDIF.
986
987      PERFORM free_selections_build.
988
989    * read balances of g/l accounts
990      IF x_salbew NE space.
991        PERFORM sdf_sbew00.
992      ENDIF.
993
994    * A/R open items
995      IF  x_ar  <> space.
996        SELECT * FROM t001 WHERE bukrs IN bukrs.
997          PERFORM build_bk_methode USING t001-bukrs.
998    * setup waehrung select-option
999          PERFORM fill_curr_sel USING bk_methode-bukrs.
1000
1001         PERFORM select_bsid USING 'BSID'.
1002         PERFORM select_bsid USING 'BSAD'.
1003
1004       ENDSELECT.
1005     ENDIF.
1006
1007   * A/P open items
1008     IF  x_ap  <> space.
1009       SELECT * FROM t001 WHERE bukrs IN bukrs.
1010         PERFORM build_bk_methode USING t001-bukrs.
1011   * setup currency select-option
1012         PERFORM fill_curr_sel USING bk_methode-bukrs.
1013
1014         PERFORM select_bsik USING 'BSIK'.
1015         PERFORM select_bsik USING 'BSAK'.
1016
1017       ENDSELECT.
1018     ENDIF.
1019
1020   * G/L Open items
1021     IF  x_gl  <> space.
1022       CLEAR: belege, bseg.
1023       SELECT * FROM t001 WHERE bukrs IN bukrs.
1024         PERFORM t030skv_set.
1025         PERFORM build_bk_methode USING t001-bukrs.
1026         SELECT * FROM skb1
1027                            WHERE bukrs = t001-bukrs           "H204475
1028                            AND   saknr IN skonto
1029                            AND   xopvw = 'X'
1030                            AND   kdfsl IN s_kdfsl
1031                             AND   (skb1_clauses-where_tab).
1032           IF ska1_clauses_filled = 'X'.
1033             SELECT SINGLE saknr  FROM ska1 INTO ska1-saknr
1034                                  WHERE  saknr = skb1-saknr
1035                                  AND   (ska1_clauses-where_tab).
1036             CHECK sy-subrc = 0.
1037           ENDIF.
1038   *     Account may not be SKV
1039           READ TABLE t030skv WITH KEY
1040                   hkont = skb1-saknr BINARY SEARCH.
1041           IF sy-subrc = 0.
1042             CHECK 0 = 1.                 "no skv account
1043           ENDIF.
1044   *       determine whether gr/ir accounts are selected
1045           PERFORM gr_ir_check CHANGING skb1-xopvw
1046                                        grir_flag.
1047           CHECK   skb1-xopvw =  'X'.
1048   *       commented out because some gl accounts have no
1049   *       extra correction account
1050   *       if s_no_acc-low ne space.
1051   *          check: not ( skb1-saknr in s_no_acc ).
1052   *       endif.
1053
1054           PERFORM fill_curr_sel USING bk_methode-bukrs.
1055
1056           dk_konzs = space.
1057           IF t044a-gl_grup NE space.
1058             PERFORM get_dkonzs_gl CHANGING dk_konzs.
1059           ENDIF.
1060           PERFORM select_bsis USING 'BSIS'.
1061           PERFORM select_bsis USING 'BSAS'.
1062         ENDSELECT.                       "skb1
1063       ENDSELECT.
1064     ENDIF.
1065
1066   END-OF-SELECTION.
1067
1068   * revaluate the extracted items and balances
1069
1070     CLEAR bseg.
1071     SORT.
1072     LOOP.
1073
1074       AT NEW belege-zbukr.
1075         SELECT SINGLE * FROM t001 WHERE bukrs = belege-zbukr.
1076         ska1-ktopl = t001-ktopl.
1077         PERFORM build_bk_methode USING t001-bukrs.
1078         IF NOT bk_methode-hwaer_rem IS INITIAL.
1079           IF NOT gd_t033_rem-curtp2 IS INITIAL.
1080             PERFORM derive_hauswaers
1081                         USING
1082                            t001-bukrs
1083                            gd_t033_rem-curtp
1084                         CHANGING
1085                            rem_haus.
1086             PERFORM derive_hauswaers
1087                         USING
1088                            t001-bukrs
1089                            gd_t033_rem-curtp2
1090                         CHANGING
1091                            rem2_haus.
1092             IF rem_haus-waers NE rem2_haus-waers.
1093               CLEAR gd_t033_rem-curtp2.
1094             ENDIF.
1095           ENDIF.
1096         ENDIF.
1097         PERFORM get_co_pa_flag USING belege-bukrs
1098                               CHANGING co_pa_flag.
1099       ENDAT.
1100
1101
1102       AT NEW sort-hkont.
1103   *     Zuruecksetzen Hauptbuchkonten-Tabellen
1104         grir_flag = space.
1105         IF pa_were NE space AND belege-koart = 'S'
1106           AND  skb1-xopvw = 'X'.
1107           skb1-saknr = belege-hkont.
1108           PERFORM gr_ir_check CHANGING skb1-xopvw
1109                                        grir_flag.
1110         ENDIF.
1111       ENDAT.
1112
1113       AT NEW sort-konto.
1114         REFRESH: belege, lock_tab.
1115       ENDAT.
1116
1117   * alle belege eines (kontokorrentkontos) zwischenspeichern
1118       AT daten.
1119         APPEND belege.
1120         IF post_upd <> space AND p_bwber = space.
1121           MOVE-CORRESPONDING belege TO lock_tab.
1122           IF lock_tab-koart = 'S' AND belege-belnr NE space.
1123             lock_tab-konto = belege-hkont.
1124           ENDIF.
1125           COLLECT lock_tab.
1126         ENDIF.
1127       ENDAT.
1128
1129
1130
1131       AT END OF sort-konto.
1132
1133   *   Hauwaehrung bewerten
1134         IF bk_methode-meth1 NE space.
1135   *    Belege bewerten + drucken
1136           PERFORM belege2 USING '1'.
1137         ELSEIF bk_methode-meth2 NE space.
1138   * Hauswaehrung 2 .
1139           PERFORM belege2 USING '2'.
1140         ELSEIF bk_methode-meth3 NE space.
1141   * Hauswaehrung 3 .
1142           PERFORM belege2 USING '3'.
1143         ENDIF.
1144
1145         IF post_upd <> space AND p_bwber = space.
1146           LOOP AT lock_tab.
1147             PERFORM ausgleich_sperren_s USING lock_tab-koart
1148                                               lock_tab-konto
1149                                               lock_tab-bukrs
1150                                        CHANGING locked.
1151             IF locked <> 0. EXIT. ENDIF.
1152           ENDLOOP.
1153         ENDIF.
1154
1155   *     belege = space.
1156         LOOP AT belege.
1157
1158           AT NEW waers.
1159             SUM.
1160             bdiff_delta = belege-bwdiff - belege-bdiff.
1161           ENDAT.
1162           AT NEW bezugsnr.
1163             SUM.
1164   *     revaluation by document (and references)
1165             IF t044a-xsalb = space.
1166               SUM.
1167               bdiff_delta = belege-bwdiff - belege-bdiff.
1168             ENDIF.
1169           ENDAT.
1170
1171
1172   *       for listings
1173           IF locked = 0.
1174             PERFORM list_item_fill.
1175
1176             IF belege-bdiff NE belege-bwdiff.
1177               PERFORM fill_bu_waertab.   "and record docum for upda
1178
1179               ADD 1 TO anzup.
1180             ELSEIF post_upd <> space AND p_bwber <> space
1181                    AND grir_flag = space.
1182               MOVE-CORRESPONDING belege TO belege_upd. "#EC CI_FLDEXT_OK[2610650]
1183               APPEND belege_upd.
1184             ENDIF.
1185           ENDIF.
1186           IF post_upd NE space AND anzup GE maxup.
1187             PERFORM posting.             "post everything in bu_waert.
1188           ENDIF.
1189
1190         ENDLOOP.
1191         IF post_upd <> space AND p_bwber = space.
1192           LOOP AT lock_tab.
1193             PERFORM ausgleich_entsperren_s USING lock_tab-koart
1194                                               lock_tab-konto
1195                                               lock_tab-bukrs.
1196           ENDLOOP.
1197         ENDIF.
1198
1199       ENDAT.
1200
1201       AT END OF sort-hkont.
1202   * force posting to get rid of update documents
1203         IF post_upd NE space.
1204           PERFORM posting.               "post everything in bu_waert.
1205         ENDIF.
1206       ENDAT.
1207
1208       AT LAST.
1209         PERFORM posting.
1210       ENDAT.
1211     ENDLOOP.
1212
1213
1214     PERFORM enqueue USING 'OFF'.
1215
1216     PERFORM file_close.
1217
1218     PERFORM posting_document USING 'CLOSE'.
1219
1220     PERFORM log_posting_errors.
1221   * store data
1222   *  IF P_STORE NE SPACE.
1223   *   CLEAR FIMSG.
1224   *     FIMSG-MSGID = 'FR'.
1225   *     FIMSG-MSGTY = 'I'.
1226   *     FIMSG-MSGNO = '007'.
1227   *     FIMSG-MSGV1 = STOR_NAM.
1228   *     PERFORM LOG_FIMSG USING '01'.
1229   *     CALL FUNCTION 'FI_MESSAGE_GET'
1230   *          TABLES
1231   *               T_FIMSG    = T_FIMSG
1232   *          EXCEPTIONS
1233   *               OTHERS     = 0.
1234   *     PERFORM LIST_STORE USING 'E'.  "export
1235   * ENDIF.
1236     IF flag_onli <> space.    "nur online - nicht drucken
1237       PERFORM schedman_start_stop USING 'STOP'.
1238     ENDIF.
1239
1240   * start output
1241     PERFORM liste.
1242     IF flag_onli = space          "nur bei Druck oder Batch
1243       OR sy-batch = 'X'.
1244       PERFORM schedman_start_stop USING 'STOP'.
1245     ENDIF.
1246   * begin of <RD1K960036>
1247   *  include SAPF100_i1.
1248   *  include SAPF100_sbew.
1249   *  include SAPF100_postings.
1250     INCLUDE zsapf100_i1_new.
1251     INCLUDE zsapf100_sbew_new.
1252     INCLUDE zsapf100_postings_new.
1253   * end of <RD1K960036>
1254
1255   ************************************************************************
1256   ************************************************************************
1257
1258
1259   *&--------------------------------------------------------------------*
1260   *&      FORM EXTRACT                                                  *
1261   *&--------------------------------------------------------------------*
1262   *       ........                                                      *
1263   *---------------------------------------------------------------------*
1264   FORM extract.
1265     IF belege-belnr <> space.
1266       CHECK:
1267              belege-wrbtr NE 0.
1268
1269   * select additional fields from bseg
1270       IF belege-koart <> 'S' OR  fs_num > 0.
1271         IF bseg_clauses_filled = 'X'.
1272           SELECT SINGLE rdiff FROM bseg
1273                         INTO CORRESPONDING FIELDS OF bseg
1274                                    WHERE bukrs = belege-bukrs
1275                                    AND belnr   = belege-belnr
1276                                    AND gjahr   = belege-gjahr
1277                                    AND buzei   = belege-buzei
1278                                    AND (bseg_clauses-where_tab).
1279           CHECK sy-subrc = 0.
1280         ENDIF.
1281
1282         SELECT SINGLE rdiff rdif2 rdif3 gbetr kursr
1283                       bdiff bdif2 bdif3    "to be sure...
1284                       xhkom
1285                         FROM bseg
1286                         INTO CORRESPONDING FIELDS OF bseg
1287                                    WHERE bukrs = belege-bukrs
1288                                    AND belnr   = belege-belnr
1289                                    AND gjahr   = belege-gjahr
1290                                    AND buzei   = belege-buzei.
1291         CHECK sy-subrc = 0.
1292       ENDIF.
1293
1294   *----get hedged value from rebzg---------------------------------------
1295       IF NOT bseg-rebzg IS INITIAL AND t044a-xsich NE space.
1296
1297         SELECT SINGLE waers FROM bkpf
1298                               INTO bseg-pswsl
1299                               WHERE bukrs = belege-bukrs
1300                               AND   belnr = bseg-rebzg
1301                               AND   gjahr = bseg-rebzj.
1302         IF belege-waers = bseg-pswsl.
1303           SELECT SINGLE gbetr kursr
1304                           FROM bseg
1305                           INTO CORRESPONDING FIELDS OF bseg
1306                                      WHERE bukrs = belege-bukrs
1307                                      AND belnr   = bseg-rebzg
1308                                      AND gjahr   = bseg-rebzj
1309                                      AND buzei   = bseg-rebzz.
1310           IF sy-subrc = 0.
1311             belege-gbetr = bseg-gbetr. belege-kursr = bseg-kursr.
1312             IF belege-gbetr > belege-wrbtr.  "always positive values
1313               bseg-gbetr = belege-wrbtr.
1314             ENDIF.
1315           ENDIF.
1316         ENDIF.
1317       ENDIF.
1318   *----------------------------------------------------------------------
1319   *  bestimmen der bezugsnummer --- used for grouping -------------------
1320       bezugsnr = space.
1321   *   pruefen ob cpd konto
1322       IF bseg-xcpdd NE space.
1323         SELECT SINGLE * FROM bsec WHERE bukrs = belege-bukrs
1324                                   AND   gjahr = belege-gjahr
1325                                   AND   belnr = belege-belnr
1326                                   AND   buzei = belege-buzei.
1327   *     bezugsnr = bsec-empfg.
1328       ELSE.
1329         bsec-empfg = space.
1330       ENDIF.
1331   *   kein cpd konto
1332
1333   *     gibt es keine bezugsnummer wird die belegnummer verwendet
1334       IF bseg-rebzj =  '0000'.
1335         bezugsnr-nr = belege-belnr.
1336         bezugsnr-ja = belege-gjahr.
1337         bezugsnr-zz = belege-buzei.
1338       ELSE.
1339         bezugsnr-nr = bseg-rebzg.
1340         bezugsnr-ja = bseg-rebzj.
1341         bezugsnr-zz = bseg-rebzz.
1342       ENDIF.
1343   * bei werekonten.
1344       IF grir_flag = 'X' AND bseg-ebeln NE space.
1345         CONCATENATE bseg-ebeln bseg-ebelp INTO bezugsnr.
1346   *     bezugsnr = bseg-ebeln.
1347   *     bezugsnr-ja = bseg-ebelp.
1348       ENDIF.
1349       belege-bezugsnr = bezugsnr.
1350   *----------------------------------------------------------------------
1351
1352       CLEAR: belege-kursr, belege-kursra.
1353   * use hedging ---------------------------------------------------------
1354
1355       IF ( t044a-xsich = 'X' AND bseg-ebeln IS INITIAL ).
1356         belege-kursra = bseg-kursr. belege-gbetr = bseg-gbetr.
1357         belege-kursr  = bseg-kursr.
1358       ELSE.
1359         CLEAR: belege-kursra, belege-gbetr.
1360       ENDIF.
1361     ENDIF.  "only for documents
1362   *----------------------------------------------------------------------
1363   * buchungskreis mit Zielbuchungskreis ueberschreiben
1364     belege-zbukr = belege-bukrs.
1365     IF p_zbukrs NE space.
1366       belege-zbukr = p_zbukrs.
1367     ENDIF.
1368   * Bewertung zurücksetzen
1369     IF t044a-xreset NE space.
1370       belege-wflag = '0'.
1371     ELSE.
1372       belege-wflag = '1'.
1373     ENDIF.
1374     sort-hkont = belege-hkont.
1375   * ----check for changed rec. account ---------------------------------
1376     IF belege-koart NE 'S'
1377      AND  bseg-xhkom = space.  "kein willentlich geändertes Hkont
1378
1379       IF belege-umskz NE space.
1380         IF t074-umskz NE belege-umskz
1381            OR t074-hkont NE akonts.
1382   *   Aktuelles Sonderhauptbuchkonto aus Tabelle 074 ermitteln
1383           SELECT SINGLE * FROM t074 WHERE ktopl = t001-ktopl
1384                                     AND   koart = belege-koart
1385                                     AND   umskz = belege-umskz
1386                                     AND   hkont = akonts.
1387           IF sy-subrc <> 0. t074-skont = space. ENDIF.
1388         ENDIF.
1389         IF t074-skont NE space.
1390           sort-hkont = t074-skont.       "neues sonderhauptbuchkonto
1391         ENDIF.
1392       ELSE.
1393         sort-hkont = akonts.
1394       ENDIF.
1395     ENDIF.                               "kontoart
1396   * --------------------------------------------------------------------
1397
1398   * damit werden keine at Zeitpunkte durchgefuehrt.
1399     IF dk_konzs NE space AND grir_flag = space.
1400       sort-koart = space.
1401       sort-hkont = space.
1402       sort-vbund = space.
1403       sort-konto = space.
1404     ELSE.
1405       sort-koart = belege-koart.
1406       sort-vbund = belege-vbund.
1407       sort-konto = belege-konto.
1408       IF bseg-xcpdd <> space.
1409         WRITE bsec-empfg TO sort-konto+10.
1410       ENDIF.
1411   *   in sort-hkont is the (changed) hkont
1412     ENDIF.
1413
1414   * get old value Bdiff (set to zero)
1415   *  IF p_bwber NE space.
1416   *    PERFORM bsbw_get.
1417   *  ENDIF.
1418   *
1419   * setup from value (WRBTR) and BDIFF (old difference) -----------------
1420     belege-ta_waers = belege-waers.
1421     belege-hwtyp = space.
1422     IF p_transl = space.
1423       IF p_bwber NE space.
1424         belege-bdiff = belege-bdif2  = belege-bdif3  = 0.
1425         bseg-rdiff = bseg-rdif2 = bseg-rdif3 = 0.
1426       ENDIF.
1427       belege-hwtyp = space.
1428
1429       IF bk_methode-meth1 NE space.
1430         belege-hwtyp = '1'.
1431         belege-rdiff = bseg-rdiff.
1432       ELSEIF bk_methode-meth2 NE space.
1433         IF bk_methode-curs2 = '2'.
1434           belege-waers = bk_methode-hwae1.
1435           belege-wrbtr = belege-dmbtr + belege-bdiff.
1436         ENDIF.
1437         belege-dmbtr = belege-dmbe2.
1438         belege-bwdiff = belege-bwdif2.
1439         belege-bdiff = belege-bdif2.
1440         belege-rdiff = bseg-rdif2.
1441         belege-hwtyp = '2'.
1442       ELSEIF bk_methode-meth3 NE space.
1443         IF bk_methode-curs3 = '2'.
1444           belege-waers = bk_methode-hwae1.
1445           belege-wrbtr = belege-dmbtr + belege-bdiff.
1446         ENDIF.
1447         belege-dmbtr = belege-dmbe3.
1448         belege-bwdiff = belege-bwdif3.
1449         belege-bdiff = belege-bdif3.
1450         belege-rdiff = bseg-rdif3.
1451         belege-hwtyp = '3'.
1452       ENDIF.
1453     ELSE.
1454   * translation active
1455   * setup from value (WRBTR) and BDIFF (old difference) -----------------
1456   * wrbtr = dmbtr + bdiff
1457   * bdiff (old) is set to zero
1458
1459       PERFORM bsbw_translation_op.
1460
1461
1462       IF frombwb <> space.
1463         t_bsbw-bwshb = 0.
1464         LOOP AT t_bsbw WHERE curtp = fromctp  AND bwber = frombwb.
1465           EXIT.
1466         ENDLOOP.
1467       ELSE.
1468         CASE fromctp.
1469           WHEN bk_methode-curt1. t_bsbw-bwshb = belege-bdiff.
1470           WHEN bk_methode-curt2. t_bsbw-bwshb = belege-bdif2.
1471           WHEN bk_methode-curt3. t_bsbw-bwshb = belege-bdif3.
1472           WHEN OTHERS. t_bsbw-bwshb = 0.
1473         ENDCASE.
1474       ENDIF.
1475   * build belege-wrbtr from the local currencie(s)
1476   * this is the revaluated amount
1477       IF fromctp      = '10'.
1478         belege-waers = bk_methode-hwae1.
1479         belege-wrbtr = belege-dmbtr +  t_bsbw-bwshb.
1480       ELSEIF fromctp   =  bk_methode-curt2.
1481         belege-waers = bk_methode-hwae2.
1482         belege-wrbtr = belege-dmbe2 + t_bsbw-bwshb.
1483       ELSEIF fromctp   =  bk_methode-curt3.
1484         belege-waers = bk_methode-hwae3.
1485         belege-wrbtr = belege-dmbe3 + t_bsbw-bwshb.
1486       ENDIF.
1487   * do not use the old difference
1488       belege-bdiff = belege-bdif2  = belege-bdif3  = 0.
1489       bseg-rdiff = bseg-rdif2 = bseg-rdif3 = 0.
1490   * dmbtr is the to value -----------------
1491       IF bk_methode-meth1 NE space.
1492         belege-hwtyp = '1'.
1493       ELSEIF bk_methode-meth2 NE space.
1494         belege-dmbtr = belege-dmbe2.
1495         belege-hwtyp = '2'.
1496       ELSEIF bk_methode-meth3 NE space.
1497         belege-dmbtr = belege-dmbe3.
1498         belege-hwtyp = '3'.
1499       ENDIF.
1500   * get remeasurement value and adds it to belege-dmbtr.
1501       LOOP AT t_bsbw WHERE curtp = curtp_rem AND bwber = p_bwber2.
1502         ADD t_bsbw-bwshb TO belege-dmbtr.
1503       ENDLOOP.
1504
1505     ENDIF.
1506
1507     IF belege-shkzg = 'H'.
1508       belege-dmbtr = 0 - belege-dmbtr.
1509       belege-wrbtr = 0 - belege-wrbtr.
1510       belege-bdiff = 0 - belege-bdiff.
1511       belege-rdiff = 0 - belege-rdiff.
1512     ELSE.
1513
1514     ENDIF.
1515   * set old and new value equal
1516     belege-bwdiff = belege-bdiff.
1517   * --------------------------------------------------------------------
1518     CHECK belege-hwtyp NE space.
1519
1520   * normally revaluaton works from
1521   * wrbtr / dmbtr or
1522   * dmbtr+diff / dmbtr2 or dmbtr3
1523   * from curr / to currency
1524   * for translation
1525
1526
1527     EXTRACT daten.
1528   ENDFORM.
1529   *---------------------------------------------------------------------*
1530   *       FORM belege2                                                  *
1531   *---------------------------------------------------------------------*
1532   * allow revaluation to original value if a previos val.dif in the
1533   * document. the difference is set to zero.
1534   * Bewertung des Hauswaehrungsbetrags 2
1535   FORM belege2 USING parw.
1536     DATA: fc_balance(12) TYPE p.
1537     DATA: fwb_flag.
1538     DATA: gnb_flag(1).                   "for GR/IR accts
1539     DATA: f_currency LIKE bkpf-waers,
1540           lc_amount  LIKE belege-dmbtr,
1541           fc_amount  LIKE belege-wrbtr,
1542           fc_gbetr   LIKE belege-gbetr,    "gesicherter Betrag
1543           t_curs     LIKE  x001-basw2.
1544     PERFORM umgebung USING parw.
1545     IF parw = '2'.
1546       t_curs = bk_methode-curs2.
1547     ELSEIF  parw = '3'.
1548       t_curs = bk_methode-curs3.
1549     ENDIF.
1550   ************************* neuer loop ueber belege
1551     SORT belege BY zbukr
1552                    waers
1553                    bezugsnr
1554                      koart
1555                      konto
1556                    belnr.
1557   * belege = space.
1558     LOOP AT belege.
1559       AT NEW waers.
1560   *       Bestimmung des Geld-, Brief-, oder Mittelkurses
1561         IF t044a-xsalk = 'X'.            "Saldo aus Konto
1562           SUM.
1563           fc_balance = belege-wrbtr.
1564         ENDIF.
1565       ENDAT.
1566
1567       AT NEW bezugsnr.
1568         SUM.
1569         gnb_flag = space.
1570         IF  belege-dmbtr < 0 OR belege-dmbe2 < 0 OR belege-dmbe3 < 0.
1571           gnb_flag = '1'.
1572         ENDIF.
1573         IF t044a-xsalr = 'X'.
1574   *       Bestimmung des Geld-, Brief-, oder Mittelkurses
1575           fc_balance = belege-wrbtr.
1576         ENDIF.
1577       ENDAT.
1578
1579       IF grir_flag NE space AND pa_were <> space. "if is a gr/ir account
1580         IF gnb_flag <> '1' AND NOT s_gracc[] IS INITIAL.
1581           IF belege-hkont IN s_gracc.
1582             gnb_flag = '1'.
1583           ENDIF.
1584         ENDIF.
1585         IF gnb_flag NE '1'.
1586
1587   *     delete entry, because it is not valued
1588   *     and no longer needed
1589           DELETE belege WHERE bezugsnr = belege-bezugsnr.
1590           CONTINUE.
1591         ENDIF.
1592       ENDIF.
1593
1594       IF belege-wflag = '1'.
1595   *     get currency rate type
1596         IF fc_balance >= 0.
1597           tcurr-kurst = t044a-kurss.
1598         ELSE.
1599           tcurr-kurst = t044a-kursh.
1600         ENDIF.
1601
1602         lc_amount = belege-dmbtr.
1603   *     cursr = '1'.   "original T-Waers.
1604         f_currency = belege-waers.
1605         fc_amount = belege-wrbtr.
1606   *     if foreign currency then revaluate
1607         IF haus-waers       NE f_currency.
1608   *       parallel currencies cannot use gbetr
1609           IF parw NE '1'.
1610             fc_gbetr  = 0.
1611           ELSE.
1612             fc_gbetr = belege-gbetr.
1613           ENDIF.
1614           PERFORM fc_revaluation
1615                USING fc_amount f_currency
1616                      haus-waers  lc_amount
1617                      fc_gbetr
1618                CHANGING belege-bwdiff
1619                         belege-kursr.
1620         ELSE.
1621   *       use local currency as foreign currency
1622           belege-bwdiff = fc_amount - lc_amount.
1623         ENDIF.
1624       ELSE.
1625         belege-bwdiff = 0.
1626       ENDIF.
1627       belege-rdiffn = belege-rdiff.
1628       IF NOT belege-augbl IS INITIAL AND p_bwber = space
1629                          AND grir_flag = space.
1630         belege-rdiffn = belege-rdiff - ( belege-bwdiff - belege-bdiff ).
1631       ENDIF.
1632
1633       MODIFY belege TRANSPORTING bwdiff
1634                                  rdiffn
1635                                  kursr.
1636     ENDLOOP.
1637
1638   * check the revaluation method
1639
1640     LOOP AT belege.
1641
1642       AT NEW waers.
1643   *     Balance revaluation
1644         IF t044a-xsalb NE space.
1645           SUM.
1646           PERFORM fc_fwb_flag USING belege-bwdiff belege-bdiff
1647                            CHANGING fwb_flag.
1648         ENDIF.
1649       ENDAT.
1650
1651       AT NEW bezugsnr.
1652         SUM.
1653   *     revaluation by document (and references)
1654         IF t044a-xsalb = space.
1655           PERFORM fc_fwb_flag USING belege-bwdiff belege-bdiff
1656                            CHANGING fwb_flag.
1657         ENDIF.
1658       ENDAT.
1659
1660
1661   *   set new difference according to the method
1662       IF  fwb_flag  = '0'.
1663         belege-bwdiff = belege-bdiff.    "use old difference
1664         CLEAR belege-kursr.
1665   * allow revaluation to original value if a previos val.dif in the
1666   * document. the difference is set to zero.
1667         IF t044a-xnwpr <> space AND belege-bdiff NE 0.
1668           belege-bwdiff = 0.
1669           CLEAR belege-kursr.
1670         ENDIF.
1671         MODIFY belege TRANSPORTING bwdiff
1672                                    kursr.
1673       ENDIF.
1674
1675       IF p_remon NE space AND belege-bwdiff <> 0
1676         AND bk_methode-hwaer_rem NE space.
1677   * remeasure new difference
1678         lc_amount = 0. fc_gbetr = 0.
1679         fc_amount = belege-bwdiff.
1680         tcurr-kurst = p_remsct.
1681         PERFORM fc_revaluation
1682              USING fc_amount  haus-waers
1683                    bk_methode-hwaer_rem lc_amount
1684                    fc_gbetr
1685              CHANGING belege-bdiff_rem
1686                       belege-kursr.
1687
1688         MODIFY belege TRANSPORTING bdiff_rem.
1689       ENDIF.
1690
1691   *   write data into file
1692       IF filename NE space AND belege-belnr NE space.
1693         PERFORM file_append.
1694       ENDIF.
1695
1696
1697     ENDLOOP.
1698   ENDFORM.
1699   * check according to valuation principle the new difference
1700   FORM fc_fwb_flag USING neu LIKE belege-bwdiff
1701                       alt LIKE belege-bdiff
1702                 CHANGING o_flag.
1703     o_flag = '0'.
1704     IF t044a-xaufw = 'X'.                "Always
1705       o_flag = '1'.
1706   *         Posten muss abgewertet sein
1707     ELSEIF t044a-xnwpr = 'X'.            "niederstwerprinzip
1708       IF neu < 0.
1709         o_flag = '1'.
1710       ENDIF.
1711   *         Posten muss staerker abgewertet sein als letzte Bewertung
1712     ELSEIF t044a-xsnwp <> space.         "strenges NW-Prinzip
1713       IF neu LE alt.
1714         o_flag = '1'.
1715       ENDIF.
1716     ELSEIF t044a-xnabw <> space.         "only Profi
1717       IF neu  > 0.
1718         o_flag = '1'.
1719       ENDIF.
1720     ELSEIF t044a-xreset <> space. " Always revaluate when parameter reset
1721       o_flag = '1'.
1722     ENDIF.
1723
1724
1725   ENDFORM.
1726   *&---------------------------------------------------------------------*
1727   *&      Form  build_bk_methode
1728   *&---------------------------------------------------------------------*
1729   *       determine currency types and valuation methods for company code
1730   *----------------------------------------------------------------------*
1731   *  -->  p1        text
1732   *  <--  p2        text
1733   *----------------------------------------------------------------------*
1734   FORM build_bk_methode USING bukrs   LIKE t001-bukrs.
1735     READ TABLE bk_methode WITH KEY bukrs BINARY SEARCH.
1736     IF sy-subrc NE 0.
1737       CLEAR x001.
1738   *   Bestimmen der Waehrungstypen in einem Buchungskreis.
1739       CALL FUNCTION 'FI_CURRENCY_INFORMATION'
1740         EXPORTING
1741           i_bukrs = bukrs
1742         IMPORTING
1743           e_x001  = x001
1744         EXCEPTIONS
1745           OTHERS  = 0.
1746
1747   *   Ist ueberhaupt Bewertungskreis 1 vorhanden ?
1748       SELECT SINGLE * FROM t001 WHERE bukrs = bukrs.
1749       CLEAR bk_methode.
1750       bk_methode-hwae1 = t001-waers.
1751       bk_methode-hwae2 = x001-hwae2.
1752       bk_methode-hwae3 = x001-hwae3.
1753       bk_methode-curt1 = '10'.
1754       bk_methode-curt2 = x001-curt2.
1755       bk_methode-curt3 = x001-curt3.
1756       bk_methode-curs2 = x001-basw2.
1757       bk_methode-curs3 = x001-basw3.
1758   *   bewertung 1 (fuer dmshb)
1759       bk_methode-meth1 = space.
1760       IF p_curtp1 = '10'.
1761         bk_methode-meth1 =  bwmet1.
1762   * bewertung in DMBE2
1763       ELSEIF p_curtp1 = x001-curt2.
1764         bk_methode-meth2 =  bwmet1.
1765   *   dritte waehrung
1766       ELSEIF p_curtp1 = x001-curt3.
1767         bk_methode-meth3 = bwmet1.
1768       ENDIF.
1769       CLEAR bk_methode-typ_rem.
1770       CLEAR bk_methode-hwaer_rem.
1771       IF p_remon <> space.
1772         CASE curtp_rem.
1773           WHEN bk_methode-curt2.
1774             bk_methode-typ_rem = '2'.
1775             bk_methode-hwaer_rem = bk_methode-hwae2.
1776           WHEN bk_methode-curt3.
1777             bk_methode-typ_rem  = '3'.
1778             bk_methode-hwaer_rem = bk_methode-hwae3.
1779           WHEN bk_methode-curt1.  "10
1780             bk_methode-typ_rem  = '1'.
1781             bk_methode-hwaer_rem = bk_methode-hwae1.
1782         ENDCASE.
1783       ENDIF.                             "remon
1784       bk_methode-bukrs = bukrs.
1785       APPEND bk_methode.
1786       SORT bk_methode BY bukrs.
1787     ENDIF.
1788     IF NOT p_transl IS INITIAL.
1789       bk_methode-curs2 = '2'.    "use local currency
1790       bk_methode-curs3 = '2'.    "use local currency
1791     ENDIF.
1792   *     Wenn Bewertungsmethode nicht space ist,
1793   *     WIRD BEWERTUNGSKREIS BEARBEITET.
1794   ENDFORM.
1795   *&--------------------------------------------------------------------*
1796   *&      FORM READ_T004A                                               *
1797   *&--------------------------------------------------------------------*
1798   *       read valuation method                                         *
1799   *---------------------------------------------------------------------*
1800   FORM read_t044a USING bwmet LIKE t044a-bwmet.
1801     STATICS: obwmet LIKE t044a-bwmet.
1802     IF obwmet <> bwmet.
1803       SELECT SINGLE * FROM t044a WHERE bwmet = bwmet.
1804       IF sy-subrc NE 0.
1805         MESSAGE s363.
1806         STOP.
1807       ENDIF.
1808       obwmet = bwmet.
1809       SELECT SINGLE * FROM t044b WHERE bwmet = bwmet
1810                                 AND spras   = sy-langu.
1811     ENDIF.
1812   ENDFORM.
1813   *&---------------------------------------------------------------------*
1814   *&       FORM UMGEBUNG                                                 *
1815   *&---------------------------------------------------------------------*
1816   *        determine valuation method, local currency and currency type  *
1817   *----------------------------------------------------------------------*
1818   FORM umgebung USING hwtype LIKE haus-field.
1819   *     aus dem Waehrungstyp laesst sich die Bewertungsmethode
1820   *     rueckschliessen
1821     IF hwtype = '1'.
1822       t044a-bwmet = bk_methode-meth1.
1823       haus-curtp  = bk_methode-curt1.
1824       haus-waers = bk_methode-hwae1.   haus-field = '1'.
1825     ENDIF.
1826     IF hwtype = '2'.
1827       t044a-bwmet = bk_methode-meth2.
1828       haus-curtp  = bk_methode-curt2.
1829       haus-waers = bk_methode-hwae2.   haus-field = '2'.
1830     ENDIF.
1831     IF hwtype = '3'.
1832       t044a-bwmet = bk_methode-meth3.
1833       haus-curtp  = bk_methode-curt3.
1834       haus-waers = bk_methode-hwae3.   haus-field = '3'.
1835     ENDIF.
1836     PERFORM read_t044a USING t044a-bwmet.
1837   * Hauswaehrung festlegen
1838     t001-waers = haus-waers.  "t001-waers wird in Batch headin wieder gel.
1839   ENDFORM.
1840   *&--------------------------------------------------------------------*
1841   *&      FORM AUSGLEICH_SPERREN_S                                      *
1842   *&--------------------------------------------------------------------*
1843   *       ........                                                      *
1844   *---------------------------------------------------------------------*
1845   *  -->  X                                                             *
1846   *---------------------------------------------------------------------*
1847   FORM ausgleich_sperren_s USING asp_koart asp_konto asp_bukrs
1848                            CHANGING  return LIKE sy-subrc.
1849     STATICS:
1850       enq_koart LIKE bseg-koart,
1851       enq_konto LIKE bseg-lifnr,
1852       enq_bukrs LIKE bkpf-bukrs.
1853     DATA: char(12).
1854     CHECK asp_koart NE enq_koart
1855        OR asp_konto NE enq_konto
1856        OR asp_bukrs NE enq_bukrs.
1857     CASE asp_koart.
1858       WHEN 'D'.
1859         CALL FUNCTION 'ENQUEUE_EFKNB1AS'
1860           EXPORTING
1861             kunnr          = asp_konto
1862             bukrs          = asp_bukrs
1863           EXCEPTIONS
1864             foreign_lock   = 1
1865             system_failure = 2.
1866       WHEN 'K'.
1867         CALL FUNCTION 'ENQUEUE_EFLFB1AS'
1868           EXPORTING
1869             lifnr          = asp_konto
1870             bukrs          = asp_bukrs
1871           EXCEPTIONS
1872             foreign_lock   = 1
1873             system_failure = 2.
1874       WHEN 'S'.
1875         CALL FUNCTION 'ENQUEUE_EFSKB1AS'
1876           EXPORTING
1877             saknr          = asp_konto
1878             bukrs          = asp_bukrs
1879           EXCEPTIONS
1880             foreign_lock   = 1
1881             system_failure = 2.
1882     ENDCASE.
1883     return = sy-subrc.
1884
1885     CASE sy-subrc.
1886       WHEN 1.
1887         char(12) = sy-msgv1.
1888   *     MESSAGE s287(f5) WITH ASP_KONTO ASP_BUKRS CHAR(12).
1889         MESSAGE e287(f5) WITH  asp_konto
1890                                asp_bukrs
1891                                char
1892                                INTO g_dummy.
1893
1894         PERFORM log_almsg USING '06'.
1895       WHEN 2.
1896   *     MESSAGE s288.
1897         MESSAGE e288(f5).
1898         PERFORM log_almsg USING '06'.
1899     ENDCASE.
1900     enq_koart = asp_koart.
1901     enq_konto = asp_konto.
1902     enq_bukrs = asp_bukrs.
1903   ENDFORM.
1904   *&---------------------------------------------------------------------*
1905   *&       FORM AUSGLEICH_ENTSPERREN_S                                   *
1906   *&---------------------------------------------------------------------*
1907   *       ........                                                      *
1908   *---------------------------------------------------------------------*
1909   *  -->  ASP_KOART                                                     *
1910   *  -->  ASP_KONTO                                                     *
1911   *  -->  ASP_BUKRS                                                     *
1912   *---------------------------------------------------------------------*
1913   FORM ausgleich_entsperren_s USING asp_koart asp_konto asp_bukrs.
1914     STATICS:
1915       enq_koart LIKE bseg-koart,
1916       enq_konto LIKE bseg-lifnr,
1917       enq_bukrs LIKE bkpf-bukrs.
1918
1919     CHECK asp_koart NE enq_koart
1920        OR asp_konto NE enq_konto
1921        OR asp_bukrs NE enq_bukrs.
1922     CASE asp_koart.
1923       WHEN 'D'.
1924         CALL FUNCTION 'DEQUEUE_EFKNB1AS'
1925           EXPORTING
1926             kunnr = asp_konto
1927             bukrs = asp_bukrs.
1928       WHEN 'K'.
1929         CALL FUNCTION 'DEQUEUE_EFLFB1AS'
1930           EXPORTING
1931             lifnr = asp_konto
1932             bukrs = asp_bukrs.
1933       WHEN 'S'.
1934         CALL FUNCTION 'DEQUEUE_EFSKB1AS'
1935           EXPORTING
1936             saknr = asp_konto
1937             bukrs = asp_bukrs.
1938     ENDCASE.
1939
1940     enq_koart = asp_koart.
1941     enq_konto = asp_konto.
1942     enq_bukrs = asp_bukrs.
1943   ENDFORM.
1944   *&--------------------------------------------------------------------*
1945   *&      FORM enqueue                                                  *
1946   *&--------------------------------------------------------------------*
1947   *       ........                                                      *
1948   *---------------------------------------------------------------------*
1949   *  -->  x                                                             *
1950   *---------------------------------------------------------------------*
1951   FORM enqueue USING x.
1952     DATA: user LIKE sy-msgv1.
1953     CHECK post_upd NE space.             "nur bei Postenupdate
1954     IF x = 'ON'.
1955       SELECT * FROM t001 WHERE bukrs IN bukrs.
1956         AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
1957                  ID 'BUKRS' FIELD t001-bukrs
1958                  ID 'ACTVT' FIELD '01'.
1959         IF NOT sy-subrc EQ 0.
1960           CONCATENATE text-s15 t001-bukrs INTO user SEPARATED BY space.
1961           MESSAGE e812 WITH text-003 user.
1962           STOP.
1963         ENDIF.
1964       ENDSELECT.
1965       SELECT * FROM t001 WHERE bukrs IN bukrs.
1966         CALL FUNCTION 'ENQUEUE_EFT001EX'
1967           EXPORTING
1968             mandt          = sy-mandt
1969             bukrs          = t001-bukrs
1970             _scope         = '1'
1971           EXCEPTIONS
1972             foreign_lock   = 1
1973             system_failure = 2
1974             OTHERS         = 2.
1975         IF sy-subrc NE 0.
1976           user = sy-msgv1.
1977           MESSAGE e369 WITH t001-bukrs user. "sy-msgv1.
1978           STOP.
1979         ENDIF.
1980       ENDSELECT.
1981     ELSE.
1982       SELECT * FROM t001 WHERE bukrs IN bukrs.
1983         CALL FUNCTION 'DEQUEUE_EFT001EX'
1984           EXPORTING
1985             mandt = sy-mandt
1986             bukrs = t001-bukrs.
1987   *     enq_bukrs = t001-bukrs.
1988       ENDSELECT.
1989     ENDIF.
1990
1991   ENDFORM.
1992   *&---------------------------------------------------------------------*
1993   *&       FORM CHECK_BWMETXX                                            *
1994   *&---------------------------------------------------------------------*
1995   *        checks bei at selection screen........                        *
1996   *----------------------------------------------------------------------*
1997   FORM check_bwmetxx USING xx LIKE t044a-bwmet.
1998     IF xx NE space.
1999   * sind die Batch-input daten vollstaendig
2000       IF t044a-blart = space AND par_bi NE space.
2001         MESSAGE e363.
2002       ENDIF.
2003       IF
2004          t044a-xfile = 'X' AND filename = space.
2005         MESSAGE e377.
2006       ENDIF.
2007     ENDIF.
2008   ENDFORM.
2009   *&---------------------------------------------------------------------*
2010   *&       FORM GET_CURTP                                                *
2011   *&---------------------------------------------------------------------*
2012   *       ........                                                      *
2013   *---------------------------------------------------------------------*
2014   *  -->  ICURTP                                                        *
2015   *---------------------------------------------------------------------*
2016   FORM check_curtp USING icurtp.
2017     TABLES: dcobjdef.
2018     dcobjdef-name = 'CURTP'.
2019     CHECK icurtp NE space.
2020
2021     DESCRIBE TABLE tdd07v LINES sy-tfill.
2022     IF sy-tfill = 0.
2023       CALL FUNCTION 'DDUT_DOMVALUES_GET'
2024         EXPORTING
2025           name      = dcobjdef-name
2026           langu     = sy-langu
2027   *       TEXTS_ONLY    = ' '
2028         TABLES
2029           dd07v_tab = tdd07v
2030         EXCEPTIONS
2031           OTHERS    = 0.
2032     ENDIF.
2033
2034   *
2035     LOOP AT tdd07v WHERE domvalue_l = icurtp.
2036     ENDLOOP.
2037     IF sy-subrc NE 0.
2038       MESSAGE e002(00).
2039     ENDIF.
2040     IF icurtp = '00'.
2041       MESSAGE e264(fc) WITH icurtp.
2042     ENDIF.
2043   ENDFORM.
2044   *&--------------------------------------------------------------------*
2045   *&      FORM check_before_start                                       *
2046   *&--------------------------------------------------------------------*
2047   *       ........                                                      *
2048   *---------------------------------------------------------------------*
2049   FORM check_before_start.
2050     IF bwmet1 = space.
2051       MESSAGE e055(00).
2052     ENDIF.
2053
2054     PERFORM check_bwmetxx USING bwmet1.
2055     IF p_zbukrs NE space.
2056       PERFORM check_zbukrs.
2057     ENDIF.
2058     IF filename NE space.
2059   ***    Start of UC Check changes 20.06.2016
2060   *    OPEN DATASET filename FOR OUTPUT.
2061       OPEN DATASET filename FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
2062   ****    End of Uc chech changes 20.06.2016
2063       IF sy-subrc NE 0.
2064         MESSAGE e474 WITH filename.
2065       ENDIF.
2066     ELSE.
2067       IF t044a-xfile <> space.
2068         tabbl-dynnr   = 1060.
2069         tabbl-activetab = '1060'.
2070         MESSAGE e377.
2071       ENDIF.
2072     ENDIF.
2073   ENDFORM.
2074   *&---------------------------------------------------------------------*
2075   *&       FORM DERIVE_HAUSWAERS                                         *
2076   *&---------------------------------------------------------------------*
2077   *       ........                                                      *
2078   *---------------------------------------------------------------------*
2079   *  -->  I_BUKRS                                                       *
2080   *  -->  I_CURT                                                        *
2081   *---------------------------------------------------------------------*
2082   FORM derive_hauswaers USING    i_bukrs
2083                                  i_curt
2084                         CHANGING ihaus STRUCTURE haus.
2085     SELECT SINGLE * FROM t001 WHERE bukrs = i_bukrs.
2086     IF i_curt = '10'.
2087       ihaus-waers = t001-waers. ihaus-field = '1'.
2088     ELSE.
2089       CLEAR x001.
2090   *     Bestimmen der Waehrungstypen in einem Buchungskreis.
2091       CALL FUNCTION 'FI_CURRENCY_INFORMATION'
2092         EXPORTING
2093           i_bukrs = i_bukrs
2094         IMPORTING
2095           e_x001  = x001
2096         EXCEPTIONS
2097           OTHERS  = 0.
2098
2099       IF x001-curt2 = i_curt.
2100         ihaus-waers = x001-hwae2. ihaus-field = '2'.
2101       ELSEIF x001-curt3 = i_curt.
2102         ihaus-waers = x001-hwae3. ihaus-field = '3'.
2103       ELSE.
2104         ihaus-waers = space.   ihaus-field = space.
2105       ENDIF.
2106     ENDIF.
2107
2108   ENDFORM.                               " DERIVE_HAUSWAERS
2109   *&--------------------------------------------------------------------*
2110   *&      FORM  bsbw_translation_op                                     *
2111   *&--------------------------------------------------------------------*
2112   *       ........                                                      *
2113   *---------------------------------------------------------------------*
2114   FORM bsbw_translation_op.
2115     CHECK belege-belnr NE space.
2116     REFRESH t_bsbw.
2117     SELECT * FROM bsbw INTO TABLE t_bsbw
2118                              WHERE bukrs = belege-bukrs
2119                              AND    belnr = belege-belnr
2120                              AND    gjahr = belege-gjahr
2121                              AND    buzei = belege-buzei
2122                              AND    methd = methode.
2123   ENDFORM.
2124   *&---------------------------------------------------------------------*
2125   *&       FORM BSBW_GET                                                 *
2126   *&---------------------------------------------------------------------*
2127   *       ........                                                      *
2128   *---------------------------------------------------------------------*
2129   FORM bsbw_get.
2130     belege-bdiff = belege-bdif2  = belege-bdif3  = 0.
2131   * RDIFF darf nicht verwendet werden
2132     bseg-rdiff = bseg-rdif2 = bseg-rdif3 = 0.
2133
2134     EXIT. "do not use old values because postings are reversed
2135
2136     SELECT SINGLE * FROM bsbw
2137                               WHERE bukrs = belege-bukrs
2138                              AND    belnr = belege-belnr
2139                              AND    gjahr = belege-gjahr
2140                              AND    buzei = belege-buzei
2141                              AND    curtp = p_curtp1
2142                              AND    bwber = p_bwber
2143                              AND    methd = methode.
2144     CHECK sy-subrc = 0.
2145
2146   * old value
2147     belege-bdiff = belege-bdif2  = belege-bdif3  = bsbw-bwshb.
2148
2149   ENDFORM.
2150   *&---------------------------------------------------------------------*
2151   *&       FORM BSBW_WRITE                                               *
2152   *&---------------------------------------------------------------------*
2153   *       ........                                                      *
2154   *---------------------------------------------------------------------*
2155   FORM bsbw_update USING icurtp LIKE t001a-curtp
2156                          ibwber LIKE t033-bwber
2157                          iact TYPE string.
2158     LOOP AT belege_upd.
2159       MOVE-CORRESPONDING belege_upd TO t_bsbw_new.
2160       IF iact <> 'REM'.
2161         t_bsbw_new-bwshb = belege_upd-bdiff.
2162       ELSE.
2163         t_bsbw_new-bwshb = belege_upd-bdiff_rem.
2164       ENDIF.
2165       t_bsbw_new-datum = sy-datum.
2166       t_bsbw_new-curtp = icurtp.
2167       t_bsbw_new-bwber = ibwber.
2168       t_bsbw_new-methd = methode.
2169       APPEND t_bsbw_new.
2170       cnt_belg = cnt_belg + 1.
2171     ENDLOOP.
2172   ENDFORM.
2173   *&--------------------------------------------------------------------*
2174   *&      FORM bsbw_update_db                                           *
2175   *&--------------------------------------------------------------------*
2176   FORM bsbw_update_db.
2177     DELETE bsbw  FROM TABLE t_bsbw_new.  "delete old
2178     INSERT bsbw  FROM TABLE t_bsbw_new ACCEPTING DUPLICATE KEYS.
2179   ENDFORM.
2180   *&---------------------------------------------------------------------*
2181   *&      Form f100_bel_rfdt
2182   *&---------------------------------------------------------------------*
2183   *       store data
2184   *----------------------------------------------------------------------*
2185   *  -->  p1        text
2186   *  <--  p2        text
2187   *----------------------------------------------------------------------*
2188   FORM f100_bel_rfdt TABLES if100_bel STRUCTURE f100_bel.
2189
2190     DATA: BEGIN OF f100_tab OCCURS 10.
2191             INCLUDE STRUCTURE bkpf_key.
2192     DATA: END OF f100_tab.
2193
2194     DATA: BEGIN OF bkpf_key.
2195             INCLUDE STRUCTURE bkpf_key.
2196     DATA: END OF bkpf_key.
2197
2198     LOOP AT if100_bel.
2199       AT NEW augdt.
2200         REFRESH f100_tab.
2201         CLEAR bkpf_key.
2202         SELECT * FROM bkpf WHERE bukrs = if100_bel-bukrs
2203                            AND   belnr = if100_bel-augbl.
2204           SELECT augbl FROM bseg INTO bseg-augbl
2205                WHERE bukrs = bkpf-bukrs
2206                AND   gjahr = bkpf-gjahr
2207                AND   belnr = bkpf-belnr
2208                AND   augdt = if100_bel-augdt
2209                AND   augbl = bkpf-belnr ORDER BY PRIMARY KEY.
2210             EXIT.
2211           ENDSELECT.
2212           IF sy-subrc = 0.
2213             MOVE-CORRESPONDING bkpf TO bkpf_key.
2214             EXIT. "#EC CI_NOORDER
2215           ENDIF.
2216         ENDSELECT.
2217
2218         IF sy-subrc = 0.
2219   *   get old values
2220           PERFORM f100_bel_get TABLES f100_tab
2221                                USING  bkpf_key 'I'.
2222         ELSE.
2223           MESSAGE i600(fr) WITH text-007
2224                                 if100_bel-bukrs
2225                                 if100_bel-augbl
2226                            INTO g_dummy.
2227           PERFORM log_almsg USING '50'.
2228   *       WRITE: / 'Ausgleichsbeleg nicht gefunden'(007),IF100_BEL-BUKRS,
2229   *                                     IF100_BEL-AUGBL.
2230           MOVE-CORRESPONDING if100_bel TO bkpf_key.
2231         ENDIF.
2232       ENDAT.
2233   *   get new document
2234   *    SELECT SINGLE * FROM bkpf WHERE bukrs = if100_bel-bukrs
2235   *                              AND   budat = if100_bel-budat
2236   *                              AND   belnr = if100_bel-belnr.
2237       SELECT * FROM bkpf UP TO 1 ROWS WHERE bukrs = if100_bel-bukrs
2238                                 AND   budat = if100_bel-budat
2239                                 AND   belnr = if100_bel-belnr ORDER BY PRIMARY KEY. ENDSELECT.
2240       IF sy-subrc = 0.
2241         MOVE-CORRESPONDING bkpf TO f100_tab.
2242         COLLECT f100_tab.
2243       ELSE.
2244         MESSAGE i600(fr) WITH text-011
2245                               if100_bel-bukrs
2246                               if100_bel-belnr
2247                          INTO g_dummy.
2248         PERFORM log_almsg USING '50'.
2249   *     WRITE: / 'Rücknahme Beleg für Ausgleich fehlt'(011),
2250   *                                   IF100_BEL-BUKRS,
2251   *                                   IF100_BEL-belnr.
2252       ENDIF.
2253
2254       AT END OF augdt.
2255   *   export values
2256         PERFORM f100_bel_get TABLES f100_tab
2257                              USING  bkpf_key 'E'.
2258
2259       ENDAT.
2260     ENDLOOP.
2261     REFRESH if100_bel.
2262
2263   ENDFORM.
2264   *&---------------------------------------------------------------------*
2265   *&       FORM F100_BEL_GET                                             *
2266   *&---------------------------------------------------------------------*
2267   *       ........                                                      *
2268   *---------------------------------------------------------------------*
2269   *  -->  IBKPF_TAB                                                     *
2270   *  -->  IKEY                                                          *
2271   *  -->  MODE                                                          *
2272   *---------------------------------------------------------------------*
2273   FORM f100_bel_get TABLES ibkpf_tab STRUCTURE bkpf_key
2274                     USING ikey LIKE bkpf_key
2275                           mode TYPE c.
2276     DATA: BEGIN OF bkpf_tab OCCURS 10.
2277             INCLUDE STRUCTURE bkpf_key.
2278     DATA: END OF bkpf_tab.
2279
2280     DATA:    BEGIN OF f100id,            "maybe only 22 char
2281                progr(4) TYPE c VALUE 'F100', " Programmname
2282                bukrs    LIKE bkpf-bukrs,
2283                belnr    LIKE bkpf-belnr,
2284                gjahr    LIKE bkpf-gjahr,
2285              END OF f100id.
2286
2287     MOVE-CORRESPONDING ikey TO f100id.
2288   * f100id-mandt = sy-mandt.
2289     IF mode = 'E'.
2290       bkpf_tab[] = ibkpf_tab[].
2291       EXPORT bkpf_tab TO DATABASE rfdt(f2)  CLIENT sy-mandt
2292                         ID f100id.
2293     ELSEIF mode = 'I'.
2294       IMPORT bkpf_tab FROM DATABASE rfdt(f2) CLIENT sy-mandt
2295                                  ID f100id.
2296       IF sy-subrc <> 0.
2297         f100id-gjahr = f100id-gjahr - 1.  "test again with prior year
2298         IMPORT bkpf_tab FROM DATABASE rfdt(f2) ID f100id.
2299       ENDIF.
2300       LOOP AT bkpf_tab WHERE gjahr <> ikey-gjahr.
2301         DELETE bkpf_tab.      "delete wrong entries
2302       ENDLOOP.
2303       ibkpf_tab[] = bkpf_tab[].
2304     ENDIF.
2305
2306   ENDFORM.
2307   *&--------------------------------------------------------------------*
2308   *&      FORM  account_determination                                   *
2309   *&--------------------------------------------------------------------*
2310   *       holt Konten fuer die FW-Buchungen                             *
2311   *---------------------------------------------------------------------*
2312   FORM account_determination USING iccode LIKE t001-bukrs
2313                          icurrency LIKE bkpf-waers
2314                          iaccount LIKE t030h-hkont
2315                          ibwber LIKE t030hb-bwber
2316                          icurtp LIKE t030h-curtp
2317                          ixno_op TYPE c.
2318
2319     DATA: l_use_t030h.
2320     l_use_t030h = 'X'.
2321     IF ixno_op = 'X' AND no_t030h = 'X'.
2322       l_use_t030h = space.
2323     ENDIF.
2324
2325     CALL FUNCTION 'FI_ACCT_DET_UXD'
2326       EXPORTING
2327         i_ccode          = iccode
2328         i_account        = iaccount
2329         i_currency       = icurrency
2330         i_reval_area     = ibwber
2331         i_curtp          = icurtp
2332         i_use_t030h      = l_use_t030h
2333       IMPORTING
2334         e_corr_account   = t030h-lkorr
2335         e_profit_account = t030h-lhbew
2336         e_loss_account   = t030h-lsbew
2337       EXCEPTIONS
2338         no_account_found = 1
2339         OTHERS           = 2.
2340     IF sy-subrc <> 0.
2341       IF ibwber NE space.
2342         CALL FUNCTION 'FI_ACCT_DET_UXD'
2343           EXPORTING
2344             i_ccode          = iccode
2345             i_account        = iaccount
2346             i_currency       = icurrency
2347   *         i_reval_area     = ibwber   "<<<now without
2348             i_curtp          = icurtp
2349             i_use_t030h      = l_use_t030h
2350           IMPORTING
2351             e_corr_account   = t030h-lkorr
2352             e_profit_account = t030h-lhbew
2353             e_loss_account   = t030h-lsbew
2354           EXCEPTIONS
2355             no_account_found = 1
2356             OTHERS           = 2.
2357       ENDIF.
2358     ENDIF.
2359     IF sy-subrc <> 0.
2360       ok = 0.
2361       MESSAGE e257(fr) WITH iccode
2362                             ibwber
2363                             iaccount
2364                        INTO g_dummy.
2365       PERFORM log_almsg USING '13'.
2366       CLEAR t030h.
2367       ok = 0.
2368       IF t030h-lkorr IS INITIAL. WRITE text-133 TO t030h-lkorr. ENDIF.
2369       IF t030h-lsbew IS INITIAL. WRITE text-134 TO t030h-lsbew. ENDIF.
2370       IF t030h-lhbew IS INITIAL. WRITE text-135 TO t030h-lhbew. ENDIF.
2371
2372
2373     ELSE.
2374       ok = 1.
2375       PERFORM: check_account USING iaccount CHANGING t030h-lkorr ok,
2376                check_account USING iaccount CHANGING t030h-lsbew ok,
2377                check_account USING iaccount CHANGING t030h-lhbew ok.
2378     ENDIF.
2379
2380   ENDFORM.
2381   FORM account_determination_rxd USING iccode LIKE t001-bukrs
2382                          icurrency LIKE bkpf-waers
2383                          iaccount LIKE t030h-hkont
2384   *not possible          ibwber like t030hb-bwber
2385                          icurtp LIKE t030h-curtp.
2386
2387     CALL FUNCTION 'FI_ACCT_DET_UXD'
2388       EXPORTING
2389         i_ccode          = iccode
2390         i_account        = iaccount
2391         i_currency       = icurrency
2392   *     i_reval_area     = ibwber
2393         i_curtp          = icurtp
2394       IMPORTING
2395         e_corr_account   = t030h-lkorr
2396         e_profit_account = t030h-lhbew
2397         e_loss_account   = t030h-lsbew
2398         e_rxd_profit_acc = t030h-lhrea
2399         e_rxd_loss_acc   = t030h-lsrea
2400       EXCEPTIONS
2401         no_account_found = 1
2402         OTHERS           = 2.
2403     IF sy-subrc <> 0.
2404       ok = 0.
2405       MESSAGE e257(fr) WITH iccode
2406                             space
2407                             iaccount
2408                        INTO g_dummy.
2409       PERFORM log_almsg USING '13'.
2410       CLEAR t030h.
2411       ok = 0.
2412     ELSE.
2413       ok = 1.
2414       PERFORM: check_account USING iaccount CHANGING t030h-lkorr ok,
2415                check_account USING iaccount CHANGING t030h-lsbew ok,
2416                check_account USING iaccount CHANGING t030h-lhbew ok.
2417       IF post_upd <> space.
2418         PERFORM: check_account USING iaccount CHANGING t030h-lhrea ok,
2419                  check_account USING iaccount CHANGING t030h-lsrea ok.
2420       ENDIF.
2421     ENDIF.
2422
2423   ENDFORM.
2424
2425   *&--------------------------------------------------------------------*
2426   *&      FORM CHECK_ACCOUNT                                            *
2427   *&--------------------------------------------------------------------*
2428   *       ........                                                      *
2429   *---------------------------------------------------------------------*
2430   *  -->  IKONTO                                                        *
2431   *---------------------------------------------------------------------*
2432   FORM  check_account USING ihkont LIKE t030h-lkorr
2433                       CHANGING ikonto LIKE t030h-lkorr
2434                                iok    LIKE ok.
2435     STATICS: BEGIN OF exists OCCURS 10,
2436                bukrs LIKE skb1-bukrs,
2437                saknr LIKE skb1-saknr,
2438              END OF exists.
2439
2440     READ TABLE exists WITH KEY bukrs = t001-bukrs
2441                            saknr = ikonto BINARY SEARCH.
2442     IF sy-subrc NE 0.
2443
2444       SELECT SINGLE * FROM skb1  WHERE bukrs = t001-bukrs
2445                               AND   saknr = ikonto.
2446       IF sy-subrc =  0.
2447         exists-bukrs = skb1-bukrs.
2448         exists-saknr = skb1-saknr.
2449         COLLECT exists.
2450       ELSE.
2451         IF ikonto NE space.
2452           MESSAGE e884 WITH ikonto
2453                                 t001-bukrs
2454                                 ihkont
2455                            INTO g_dummy.
2456         ELSE.
2457           fimsg-msgv1 = ''' '''.
2458           MESSAGE e885 WITH fimsg-msgv1
2459                                 t001-bukrs
2460                                 ihkont
2461                            INTO g_dummy.
2462         ENDIF.
2463         PERFORM log_almsg USING '13'.
2464         iok = 0.
2465       ENDIF.
2466     ENDIF.
2467   *
2468     IF iok = 0 AND ikonto = space. ikonto = text-130. ENDIF.
2469   * message e106(f5).
2470   ENDFORM.
2471   *&--------------------------------------------------------------------*
2472   *&      FORM FILE_CLOSE                                               *
2473   *&--------------------------------------------------------------------*
2474   *       ........                                                      *
2475   *---------------------------------------------------------------------*
2476   FORM file_close.
2477   * write name of seq. file
2478     CHECK filename NE space.
2479     CLOSE DATASET filename.
2480   *
2481     MESSAGE i600(fr) WITH text-300
2482                           space
2483                           space
2484                      INTO g_dummy.
2485     PERFORM log_almsg USING '10'.
2486   *
2487     MESSAGE i600(fr) WITH text-301
2488                           filename
2489                           space
2490                      INTO g_dummy.
2491     PERFORM log_almsg USING '11'.
2492   ENDFORM.
2493   *&---------------------------------------------------------------------*
2494   *& FORM FC_REVALUATION                                                 *
2495   *&---------------------------------------------------------------------*
2496   *  Umrechnung Fremd- in Hauswaehrung: Stichtags-Bewertung
2497   *---------------------------------------------------------------------*
2498   *       Daten einer Belegposition                                     *
2499   *  -->  Source Amount (eg dmshb)
2500   *  -->  teilgesicherter Amount (eg gbtr)
2501   *  -->  target currency
2502   *  <--  Bwdiff    Bewertungsdifferenz in Hauswaehrung                 *
2503   *---------------------------------------------------------------------*
2504   FORM fc_revaluation USING
2505                        s_amount LIKE belege-wrbtr
2506                        s_waers  LIKE haus-waers
2507                        t_waers  TYPE bkpf-waers
2508                        t_amount LIKE belege-dmbtr
2509                        s_gbetr  TYPE bseg-gbetr
2510
2511                        CHANGING ibwdiff LIKE belege-bwdiff
2512                                 s_kursr LIKE belege-kursr.
2513     DATA: diff(12) TYPE p.
2514
2515     DATA:
2516       l_gebtr  LIKE bseg-gbetr,
2517       uwrshb   LIKE belege-wrbtr,      "amount not hedged
2518       l_reval1 LIKE belege-dmbtr,     "reval. hedged amount
2519       l_reval2 LIKE l_reval1.
2520     l_gebtr = s_gbetr.
2521     uwrshb = s_amount.                   "wrshb
2522     l_reval1  = 0.
2523     l_reval2  = t_amount.                "dmshb
2524   * revaluate the hedged amount
2525     IF t044a-xsich = 'X' AND s_gbetr NE 0.
2526       IF s_amount LT 0.
2527         l_gebtr = - l_gebtr.
2528         IF s_amount GT l_gebtr.
2529           l_gebtr = s_amount.
2530         ENDIF.
2531       ELSE.
2532         IF s_amount LT l_gebtr.
2533           l_gebtr = s_amount.
2534         ENDIF.
2535       ENDIF.
2536       uwrshb  = s_amount -  l_gebtr
2537                                    .
2538       bseg-kursr = s_kursr.
2539       CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
2540         EXPORTING
2541           foreign_amount   = l_gebtr
2542           foreign_currency = s_waers
2543           local_currency   = t_waers
2544           type_of_rate     = tcurr-kurst
2545           date             = stichtag
2546           rate             = bseg-kursr  "gesicherter k.
2547         IMPORTING
2548           local_amount     = l_reval1
2549         EXCEPTIONS
2550           error_message    = 1
2551           OTHERS           = 6.
2552   *   move error messages to log
2553       IF sy-subrc NE 0.
2554         PERFORM log_almsg USING '08'.
2555       ENDIF.
2556     ENDIF.
2557   * revaluate the amount not hegded (rest of it)
2558     IF uwrshb NE 0.
2559       CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
2560         EXPORTING
2561           foreign_amount   = uwrshb
2562           foreign_currency = s_waers
2563           local_currency   = t_waers
2564           type_of_rate     = tcurr-kurst
2565           date             = stichtag
2566         IMPORTING
2567           local_amount     = l_reval2
2568           exchange_rate    = s_kursr  "verw.Kurs
2569         EXCEPTIONS
2570           error_message    = 1
2571           OTHERS           = 1.
2572   *   move error messages to log
2573       IF sy-subrc NE 0.
2574         l_reval2 = t_amount     - l_reval1.
2575         PERFORM log_almsg USING '08'.
2576       ENDIF.
2577     ELSE.
2578       l_reval2 = 0.
2579     ENDIF.
2580
2581     l_reval2 = l_reval2 + l_reval1.
2582     ibwdiff = l_reval2 - t_amount.
2583   *rounding
2584     diff =  abs( l_reval2 - t_amount ).
2585     IF diff LE t044a-mindiff.
2586       ibwdiff = 0.
2587     ENDIF.
2588   * new difference
2589
2590   ENDFORM.
2591   *&---------------------------------------------------------------------*
2592   *&       FORM FILL_BU_WAERTAB                                          *
2593   *&---------------------------------------------------------------------*
2594   *        save differences for each item, also save rdiff if any
2595   *----------------------------------------------------------------------*
2596   FORM fill_bu_waertab.
2597   * setup table for posting
2598     MOVE-CORRESPONDING belege TO bu_waertab.
2599     IF belege-belnr = space.
2600       bu_waertab-x_no_op = 'X'.
2601     ELSE.
2602       CLEAR bu_waertab-x_no_op.
2603     ENDIF.
2604
2605     bu_waertab-hwaer_rem = bk_methode-hwaer_rem.
2606     bu_waertab-ta_waers = belege-ta_waers.  "original transaction waers
2607     bu_waertab-storno = space.
2608     bu_waertab-bukrs = belege-bukrs.
2609   * czech post line for each item otherwise condense
2610     IF t044a-xpost = space.
2611       CLEAR: bu_waertab-belnr,
2612              bu_waertab-buzei.
2613     ENDIF.
2614
2615   * post the delta between new and old difference
2616     bu_waertab-dmshb = belege-bwdiff - belege-bdiff.
2617   *   BDIFF DELTA IS Uused for aflag
2618   *  if t044a-xsalb = space.
2619   *    bdiff_delta = bu_waertab-dmshb.
2620   *  endif.
2621
2622     PERFORM collect_bu_waertab USING bu_waertab-dmshb
2623                                      bdiff_delta.
2624   *   reverse GR/IR immediately in case of update
2625     IF grir_flag <> space AND post_upd <> space
2626       AND p_bwber =  space.                                   "H316012
2627       bu_waertab-storno = 'C'.
2628       PERFORM collect_bu_waertab USING bu_waertab-dmshb
2629                                        bdiff_delta.
2630     ENDIF.
2631   *
2632   * change sign for credit amounts
2633     IF post_upd NE space AND belege-belnr NE space.
2634       MOVE-CORRESPONDING belege TO belege_upd. "#EC CI_FLDEXT_OK[2610650]
2635   *   if belege-dmbtr < 0.
2636       IF belege-shkzg = 'H'.
2637         belege_upd-bdiff = - belege-bwdiff.
2638         belege_upd-bdiff_rem = - belege-bdiff_rem.
2639       ELSE.
2640         belege_upd-bdiff =  belege-bwdiff.
2641         belege_upd-bdiff_rem =  belege-bdiff_rem.
2642       ENDIF.
2643       belege_upd-bukrs = belege-bukrs.
2644   *correct RXD of cleared items
2645   * Cleared items have to be reversed
2646       IF NOT belege-augbl IS INITIAL AND p_bwber = space
2647                          AND grir_flag = space.
2648         belege_upd-rdiff = belege-rdiffn.
2649   *     if belege-dmbtr < 0.
2650         IF belege-shkzg = 'H'.
2651           belege_upd-rdiff = 0 - belege_upd-rdiff.
2652         ENDIF.
2653   *     IF BELEGE-BDIFF NE BELEGE-BWDIFF.
2654         MOVE-CORRESPONDING bu_waertab TO bu_waertab_clear.
2655   *
2656         bu_waertab_clear-shkzg = belege-shkzg.
2657         bu_waertab_clear-storno = 'R'.
2658         bu_waertab_clear-dmshb = belege-rdiff.
2659         PERFORM collect_bu_waertab_clear USING bu_waertab_clear-dmshb
2660                                          bu_waertab_clear-dmshb.
2661   *     post the corrected realised difference
2662         bu_waertab_clear-dmshb = belege-bwdiff - belege-bdiff  "neu - alt
2663                             - belege-rdiff.
2664         bu_waertab_clear-storno = 'N'.
2665         PERFORM collect_bu_waertab_clear USING bu_waertab_clear-dmshb
2666                                          bu_waertab_clear-dmshb.
2667   *     ENDIF.
2668       ENDIF.                             "cleared items
2669   *   store values for update
2670       APPEND belege_upd.
2671
2672     ENDIF.
2673
2674   ENDFORM.
2675   *&--------------------------------------------------------------------*
2676   *&      FORM COLLECT_BU_WAERTAB                                       *
2677   *&--------------------------------------------------------------------*
2678   *       ........                                                      *
2679   *---------------------------------------------------------------------*
2680   *  -->  WERT                                                          *
2681   *---------------------------------------------------------------------*
2682   FORM collect_bu_waertab USING wert LIKE belege-rdiff
2683                                 ibal.
2684     CHECK wert <> 0.
2685     IF ibal > 0.                         "Profit
2686       bu_waertab-aflag  = space.
2687     ELSE.                                "Loss
2688       bu_waertab-aflag  = 'X'.
2689     ENDIF.
2690     bu_waertab-hwaer = haus-waers.
2691     bu_waertab-curtp = haus-curtp.
2692
2693     COLLECT bu_waertab.
2694
2695   ENDFORM.
2696   *&---------------------------------------------------------------------*
2697   *&       FORM COLLECT_BU_WAERTAB_CLEAR                                 *
2698   *&---------------------------------------------------------------------*
2699   *       ........                                                      *
2700   *---------------------------------------------------------------------*
2701   *  -->  WERT                                                          *
2702   *  -->  IBAL                                                          *
2703   *---------------------------------------------------------------------*
2704   FORM collect_bu_waertab_clear USING wert LIKE belege-rdiff
2705                                 ibal.
2706     IF wert NE 0.
2707       IF ibal > 0.                       "Profit
2708         bu_waertab_clear-aflag  = space.
2709       ELSEIF ibal         < 0.           "Loss
2710         bu_waertab_clear-aflag  = 'X'.
2711       ENDIF.
2712       bu_waertab_clear-hwaer = haus-waers.
2713       IF co_pa_flag = 'X' AND belege-koart NE 'S'.
2714         bu_waertab_clear-augdt = belege-augdt.
2715         bu_waertab_clear-augbl = belege-augbl.
2716       ELSE.
2717         bu_waertab_clear-augbl = space.
2718   *      clear bu_waertab_clear-augdt.
2719         CALL FUNCTION 'SLS_MISC_GET_LAST_DAY_OF_MONTH'
2720           EXPORTING
2721             day_in            = belege-augdt
2722           IMPORTING
2723             last_day_of_month = bu_waertab_clear-augdt
2724           EXCEPTIONS
2725             OTHERS            = 4.
2726         IF sy-subrc <> 0.
2727           bu_waertab_clear-augdt = belege-augdt.
2728         ENDIF.
2729       ENDIF.
2730       COLLECT bu_waertab_clear.
2731     ENDIF.
2732   ENDFORM.
2733   *&--------------------------------------------------------------------*
2734   *&      FORM Bseg_update                                              *
2735   *&--------------------------------------------------------------------*
2736   *       ........                                                      *
2737   *---------------------------------------------------------------------*
2738   FORM bseg_update.
2739     DATA: table(10).
2740     LOOP AT belege_upd.
2741   * read bseg for indices
2742       SELECT SINGLE FOR UPDATE * FROM bseg WHERE bukrs = belege_upd-bukrs
2743                                 AND   belnr = belege_upd-belnr
2744                                 AND   gjahr = belege_upd-gjahr
2745                                 AND   buzei = belege_upd-buzei.
2746       CHECK sy-subrc = 0.
2747       IF belege_upd-augbl NE bseg-augbl.
2748   *     Fehler beim Belegupdate &1 &2 &3 &4
2749         MESSAGE e479(fr) WITH belege_upd-bukrs
2750                               belege_upd-gjahr
2751                               belege_upd-belnr
2752                               'BSEG'
2753                          INTO g_dummy.
2754         PERFORM log_almsg USING '23'.
2755         sy-subrc = 4.
2756         CHECK 1 = 0.
2757       ENDIF.
2758
2759   * ---one of this values has changed --------------------------
2760       CASE belege_upd-hwtyp.
2761         WHEN '1'.
2762           bseg-bdiff = belege_upd-bdiff.
2763         WHEN '2'.
2764           bseg-bdif2 = belege_upd-bdiff.
2765         WHEN '3'.
2766           bseg-bdif3 = belege_upd-bdiff.
2767       ENDCASE.
2768   *
2769       IF NOT belege_upd-augbl IS INITIAL.
2770         CASE belege_upd-hwtyp.
2771           WHEN '1'.
2772             bseg-rdiff = belege_upd-rdiff.
2773           WHEN '2'.
2774             bseg-rdif2 = belege_upd-rdiff.
2775           WHEN '3'.
2776             bseg-rdif3 = belege_upd-rdiff.
2777         ENDCASE.
2778   *     set reason for not allowed for reversal
2779         bseg-xragl = '1'.
2780   *     begin note 409364
2781         CALL FUNCTION 'BREAKDOWN_RELATION_FI_DOC_SUB'
2782           EXPORTING
2783             i_bukrs = belege_upd-bukrs
2784             i_belnr = belege_upd-belnr
2785             i_gjahr = belege_upd-gjahr
2786             i_koart = bseg-koart.
2787   *     end note 409364
2788       ENDIF.
2789
2790   * ---------------------------------------------------------------
2791       UPDATE bseg
2792
2793               SET bdiff = bseg-bdiff
2794                   bdif2 = bseg-bdif2
2795                   bdif3 = bseg-bdif3
2796                   rdiff = bseg-rdiff
2797                   rdif2 = bseg-rdif2
2798                   rdif3 = bseg-rdif3
2799                   xragl = bseg-xragl
2800
2801                   WHERE bukrs = bseg-bukrs
2802                                 AND   belnr = bseg-belnr
2803                                 AND   gjahr = bseg-gjahr
2804                                 AND   buzei = bseg-buzei.
2805       IF sy-subrc NE 0.
2806         ROLLBACK WORK.
2807   *     Fehler beim Belegupdate &1 &2 &3 &4
2808         MESSAGE e479(fr) WITH  belege_upd-bukrs
2809                                belege_upd-gjahr
2810                                belege_upd-belnr
2811                                'BSEG'
2812                          INTO g_dummy.
2813         PERFORM log_almsg USING '23'.
2814         CHECK 1 = 0.
2815       ELSE.
2816   *...write entry in table BWFI_AEDAT...................................*
2817         IF sy-subrc = 0.
2818           CALL FUNCTION 'OPEN_FI_PERFORM_00005011_P'
2819             EXPORTING
2820               i_chgtype   = 'U'
2821               i_origin    = 'SAPF100 UPDATE'
2822               i_tabname   = 'BSEG'
2823                i_structure = bseg "#EC CI_FLDEXT_OK[2610650]
2824             EXCEPTIONS
2825               error       = 1
2826               OTHERS      = 2.
2827         ENDIF.
2828       ENDIF.
2829
2830   *------- Übernahmestatus im Belegkopf fortschreiben --------------------
2831       LOOP AT ums40 WHERE bukrs = belege_upd-bukrs.
2832         UPDATE bkpf SET duefl = 'A' WHERE belnr = belege_upd-belnr
2833                                     AND   bukrs = belege_upd-bukrs
2834                                     AND   gjahr = belege_upd-gjahr
2835                                     AND   duefl = 'X'.
2836         EXIT.
2837       ENDLOOP.
2838
2839       CASE bseg-koart.
2840         WHEN 'D'.
2841           IF bseg-augdt = '00000000'.
2842   "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
2843
2844   *          UPDATE bsid
2845   *             SET bdiff = bseg-bdiff
2846   *                 bdif2 = bseg-bdif2
2847   *                 bdif3 = bseg-bdif3
2848   *             WHERE bukrs = bseg-bukrs    AND    kunnr = bseg-kunnr
2849   *             AND   umsks = bseg-umsks    AND    augdt = bseg-augdt
2850   *             AND   augbl = bseg-augbl    AND    zuonr = bseg-zuonr
2851   *             AND   gjahr = bseg-gjahr    AND    belnr = bseg-belnr
2852   *             AND   umskz = bseg-umskz    AND    buzei = bseg-buzei.
2853             table = 'BSID'.
2854   "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
2855   *<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< start insert note 200576
2856             IF sy-subrc EQ 0.
2857               CALL FUNCTION 'OPEN_FI_PERFORM_00005010_P'
2858                 EXPORTING
2859                   i_chgtype     = 'U'
2860                   i_origin      = 'SAPF100 UPDATE'
2861                   i_tabname     = 'BSID'
2862                   i_where_bukrs = bseg-bukrs
2863                   i_where_kunnr = bseg-kunnr
2864                   i_where_umsks = bseg-umsks
2865                   i_where_umskz = bseg-umskz
2866                   i_where_augdt = bseg-augdt
2867                   i_where_augbl = bseg-augbl
2868                   i_where_zuonr = bseg-zuonr
2869                   i_where_gjahr = bseg-gjahr
2870                   i_where_belnr = bseg-belnr
2871                   i_where_buzei = bseg-buzei
2872                 EXCEPTIONS
2873                   OTHERS        = 1.
2874               IF sy-subrc NE 0.
2875                 MESSAGE ID sy-msgid TYPE 'A' NUMBER sy-msgno
2876                         WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
2877               ENDIF.
2878             ENDIF.
2879   *>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> end insert note 200576
2880           ELSE.
2881             "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
2882   *          UPDATE bsad
2883   *            SET bdiff = bseg-bdiff
2884   *                bdif2 = bseg-bdif2
2885   *                bdif3 = bseg-bdif3
2886   *                xragl = bseg-xragl
2887   *            WHERE bukrs = bseg-bukrs    AND    kunnr = bseg-kunnr
2888   *            AND   umsks = bseg-umsks    AND    augdt = bseg-augdt
2889   *            AND   augbl = bseg-augbl    AND    zuonr = bseg-zuonr
2890   *            AND   gjahr = bseg-gjahr    AND    belnr = bseg-belnr
2891   *            AND   umskz = bseg-umskz    AND    buzei = bseg-buzei.
2892             "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
2893             table = 'BSAD'.
2894
2895   *<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< start insert P4B200576
2896             IF sy-subrc EQ 0.
2897               CALL FUNCTION 'OPEN_FI_PERFORM_00005010_P'
2898                 EXPORTING
2899                   i_chgtype     = 'U'
2900                   i_origin      = 'SAPF100 UPDATE'
2901                   i_tabname     = 'BSAD'
2902                   i_where_bukrs = bseg-bukrs
2903                   i_where_kunnr = bseg-kunnr
2904                   i_where_umsks = bseg-umsks
2905                   i_where_umskz = bseg-umskz
2906                   i_where_augdt = bseg-augdt
2907                   i_where_augbl = bseg-augbl
2908                   i_where_zuonr = bseg-zuonr
2909                   i_where_gjahr = bseg-gjahr
2910                   i_where_belnr = bseg-belnr
2911                   i_where_buzei = bseg-buzei
2912                 EXCEPTIONS
2913                   OTHERS        = 1.
2914               IF sy-subrc NE 0.
2915                 MESSAGE ID sy-msgid TYPE 'A' NUMBER sy-msgno
2916                         WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
2917               ENDIF.
2918             ENDIF.
2919   *>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> end insert P4B200576
2920           ENDIF.
2921         WHEN 'K'.
2922           IF bseg-augdt = '00000000'.
2923    "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
2924   *          UPDATE bsik
2925   *             SET bdiff = bseg-bdiff
2926   *                 bdif2 = bseg-bdif2
2927   *                 bdif3 = bseg-bdif3
2928   *             WHERE bukrs = bseg-bukrs    AND    lifnr = bseg-lifnr
2929   *             AND   umsks = bseg-umsks    AND    augdt = bseg-augdt
2930   *             AND   augbl = bseg-augbl    AND    zuonr = bseg-zuonr
2931   *             AND   gjahr = bseg-gjahr    AND    belnr = bseg-belnr
2932   *             AND   umskz = bseg-umskz    AND    buzei = bseg-buzei.
2933   "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
2934             table = 'BSIK'.
2935
2936   *<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< start insert P4B200576
2937             IF sy-subrc EQ 0.
2938               CALL FUNCTION 'OPEN_FI_PERFORM_00005010_P'
2939                 EXPORTING
2940                   i_chgtype     = 'U'
2941                   i_origin      = 'SAPF100 UPDATE'
2942                   i_tabname     = 'BSIK'
2943                   i_where_bukrs = bseg-bukrs
2944                   i_where_lifnr = bseg-lifnr
2945                   i_where_umsks = bseg-umsks
2946                   i_where_umskz = bseg-umskz
2947                   i_where_augdt = bseg-augdt
2948                   i_where_augbl = bseg-augbl
2949                   i_where_zuonr = bseg-zuonr
2950                   i_where_gjahr = bseg-gjahr
2951                   i_where_belnr = bseg-belnr
2952                   i_where_buzei = bseg-buzei
2953                 EXCEPTIONS
2954                   OTHERS        = 1.
2955               IF sy-subrc NE 0.
2956                 MESSAGE ID sy-msgid TYPE 'A' NUMBER sy-msgno
2957                         WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
2958               ENDIF.
2959             ENDIF.
2960   *>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> end insert P4B200576
2961           ELSE.
2962    "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
2963   *          UPDATE bsak
2964   *            SET bdiff = bseg-bdiff
2965   *                bdif2 = bseg-bdif2
2966   *                bdif3 = bseg-bdif3
2967   *                xragl = bseg-xragl
2968   *            WHERE bukrs = bseg-bukrs    AND    lifnr = bseg-lifnr
2969   *            AND   umsks = bseg-umsks    AND    augdt = bseg-augdt
2970   *            AND   augbl = bseg-augbl    AND    zuonr = bseg-zuonr
2971   *            AND   gjahr = bseg-gjahr    AND    belnr = bseg-belnr
2972   *            AND   umskz = bseg-umskz    AND    buzei = bseg-buzei.
2973             "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
2974             table = 'BSAK'.
2975
2976   *<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< start insert P4B200576
2977             IF sy-subrc EQ 0.
2978               CALL FUNCTION 'OPEN_FI_PERFORM_00005010_P'
2979                 EXPORTING
2980                   i_chgtype     = 'U'
2981                   i_origin      = 'SAPF100 UPDATE'
2982                   i_tabname     = 'BSAK'
2983                   i_where_bukrs = bseg-bukrs
2984                   i_where_lifnr = bseg-lifnr
2985                   i_where_umsks = bseg-umsks
2986                   i_where_umskz = bseg-umskz
2987                   i_where_augdt = bseg-augdt
2988                   i_where_augbl = bseg-augbl
2989                   i_where_zuonr = bseg-zuonr
2990                   i_where_gjahr = bseg-gjahr
2991                   i_where_belnr = bseg-belnr
2992                   i_where_buzei = bseg-buzei
2993                 EXCEPTIONS
2994                   OTHERS        = 1.
2995               IF sy-subrc NE 0.
2996                 MESSAGE ID sy-msgid TYPE 'A' NUMBER sy-msgno
2997                         WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
2998               ENDIF.
2999             ENDIF.
3000   *>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> end insert P4B200576
3001           ENDIF.
3002       ENDCASE.
3003   * Sachkonto oder Mitbuchkonto
3004       IF bseg-koart = 'S'
3005         OR bseg-xhres NE space.
3006         IF bseg-koart <> 'S'.
3007           bseg-zuonr = bseg-hzuon.
3008         ENDIF.
3009         IF bseg-augdt = '00000000'.
3010    "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
3011   *        UPDATE bsis
3012   *           SET bdiff = bseg-bdiff
3013   *               bdif2 = bseg-bdif2
3014   *               bdif3 = bseg-bdif3
3015   *           WHERE bukrs = bseg-bukrs    AND    hkont = bseg-hkont
3016   *           AND   zuonr = bseg-zuonr    AND    augdt = bseg-augdt
3017   *           AND   augbl = bseg-augbl
3018   *           AND   gjahr = bseg-gjahr    AND    belnr = bseg-belnr
3019   *           AND   buzei = bseg-buzei.
3020   "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
3021           table = 'BSIS'.
3022         ELSE.
3023   "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
3024   *        UPDATE bsas
3025   *          SET bdiff = bseg-bdiff
3026   *              bdif2 = bseg-bdif2
3027   *              bdif3 = bseg-bdif3
3028   *              xragl = bseg-xragl
3029   *          WHERE bukrs = bseg-bukrs    AND    hkont = bseg-hkont
3030   *                                      AND    augdt = bseg-augdt
3031   *          AND   zuonr = bseg-zuonr
3032   *          AND   augbl = bseg-augbl
3033   *          AND   gjahr = bseg-gjahr    AND    belnr = bseg-belnr
3034   *          AND   buzei = bseg-buzei.
3035   "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
3036           table = 'BSAS'.
3037         ENDIF.
3038       ENDIF.
3039
3040
3041       IF sy-subrc NE 0.
3042   *     Fehler beim Belegupdate &1 &2 &3 &4
3043         MESSAGE e479(fr) WITH belege_upd-bukrs
3044                               belege_upd-gjahr
3045                               belege_upd-belnr
3046                               table
3047                          INTO g_dummy.
3048         PERFORM log_almsg USING '23'.
3049   * try again
3050    "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
3051         CASE table.
3052           WHEN 'BSID'.
3053   *          UPDATE bsid
3054   *             SET bdiff = bseg-bdiff
3055   *                 bdif2 = bseg-bdif2
3056   *                 bdif3 = bseg-bdif3
3057   *             WHERE bukrs = bseg-bukrs
3058   *             AND kunnr = bseg-kunnr   AND gjahr = bseg-gjahr
3059   *             AND   belnr = bseg-belnr AND buzei = bseg-buzei.
3060           WHEN 'BSAD'.
3061   *          UPDATE bsad
3062   *             SET bdiff = bseg-bdiff
3063   *                 bdif2 = bseg-bdif2
3064   *                 bdif3 = bseg-bdif3
3065   *             WHERE bukrs = bseg-bukrs
3066   *             AND kunnr = bseg-kunnr   AND gjahr = bseg-gjahr
3067   *             AND   belnr = bseg-belnr AND buzei = bseg-buzei.
3068
3069           WHEN 'BSIK'.
3070   *          UPDATE bsik
3071   *             SET bdiff = bseg-bdiff
3072   *                 bdif2 = bseg-bdif2
3073   *                 bdif3 = bseg-bdif3
3074   *             WHERE bukrs = bseg-bukrs
3075   *             AND lifnr = bseg-lifnr   AND gjahr = bseg-gjahr
3076   *             AND   belnr = bseg-belnr AND buzei = bseg-buzei.
3077
3078           WHEN 'BSAK'.
3079   *          UPDATE bsak
3080   *             SET bdiff = bseg-bdiff
3081   *                 bdif2 = bseg-bdif2
3082   *                 bdif3 = bseg-bdif3
3083   *             WHERE bukrs = bseg-bukrs
3084   *             AND lifnr = bseg-lifnr   AND gjahr = bseg-gjahr
3085   *             AND   belnr = bseg-belnr AND buzei = bseg-buzei.
3086
3087           WHEN 'BSIS'.
3088   *          UPDATE bsis
3089   *             SET bdiff = bseg-bdiff
3090   *                 bdif2 = bseg-bdif2
3091   *                 bdif3 = bseg-bdif3
3092   *             WHERE bukrs = bseg-bukrs
3093   *             AND hkont = bseg-hkont   AND gjahr = bseg-gjahr
3094   *             AND   belnr = bseg-belnr AND buzei = bseg-buzei.
3095
3096           WHEN 'BSAS'.
3097   *          UPDATE bsas
3098   *             SET bdiff = bseg-bdiff
3099   *                 bdif2 = bseg-bdif2
3100   *                 bdif3 = bseg-bdif3
3101   *             WHERE bukrs = bseg-bukrs
3102   *             AND hkont = bseg-hkont   AND gjahr = bseg-gjahr
3103   *             AND   belnr = bseg-belnr AND buzei = bseg-buzei.
3104         ENDCASE.
3105   *"Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
3106         CHECK 1 = 0.
3107       ENDIF.
3108       cnt_belg = cnt_belg + 1.
3109     ENDLOOP.
3110
3111   ENDFORM.
3112   *&--------------------------------------------------------------------*
3113   *&      FORM SET_T042X                                                *
3114   *&--------------------------------------------------------------------*
3115   *       ........                                                      *
3116   *---------------------------------------------------------------------*
3117   * - notify payment program, that the valuation program was run for
3118   *   these accounts and company codes
3119   * - the payment program will then read again the latest val differences
3120   *   from the database
3121   * - tell SAPF110 to reread date when it was a update run for BDIFF
3122   *---------------------------------------------------------------------*
3123   FORM set_t042x.
3124     TABLES: t042x.
3125   * only necessary when update in bdiff
3126     CHECK p_bwber IS INITIAL.
3127
3128     t042x-laufd = sy-datum.
3129     t042x-laufi = 'F100XX'.
3130     t042x-datum = sy-datum.
3131     t042x-uzeit = sy-uzeit.
3132     t001 = space.
3133
3134     SELECT * FROM t001 WHERE bukrs IN bukrs.
3135       t042x-bukrs = t001-bukrs.
3136       IF  x_ar  <> space.
3137         t042x-koart = 'D'.
3138         MODIFY t042x.
3139       ENDIF.
3140       IF  x_ap  <> space.
3141         t042x-koart = 'K'.
3142         MODIFY t042x.
3143       ENDIF.
3144     ENDSELECT.
3145     COMMIT WORK.
3146   ENDFORM.
3147   *&---------------------------------------------------------------------*
3148   *&       FORM T030SKV_SET                                              *
3149   *&---------------------------------------------------------------------*
3150   *       ........                                                      *
3151   *---------------------------------------------------------------------*
3152   ********** SKV Konten duerfen nicht bewerten werden ****************
3153   FORM t030skv_set.
3154     REFRESH t030skv.
3155     TABLES: t030.
3156     IF  p_bwber IS INITIAL AND NOT post_upd EQ space.
3157       SELECT * FROM t030 WHERE  ktosl = 'SKV' AND ktopl = t001-ktopl ORDER BY PRIMARY KEY.
3158         t030skv-hkont = t030-konts .
3159         COLLECT t030skv.
3160         t030skv-hkont = t030-konth.
3161         COLLECT t030skv.
3162       ENDSELECT.
3163     ENDIF.
3164     SORT t030skv.
3165   ENDFORM.
3166   *&--------------------------------------------------------------------*
3167   *&      FORM gr_ir_get_order.                                         *
3168   *&--------------------------------------------------------------------*
3169   *       ........                                                      *
3170   *---------------------------------------------------------------------*
3171   *---------------------------------------------------------------------*
3172   * Read the Order because the Goods received part may be               *
3173   * in local currency only, when the customer uses the old mm           *
3174   * transaction.                                                        *
3175   *---------------------------------------------------------------------*
3176   FORM gr_ir_get_order.
3177     STATICS: x_ekbe LIKE ekbe   OCCURS 0 WITH HEADER LINE.
3178     DATA   : x_ekbes LIKE ekbes   OCCURS 0 WITH HEADER LINE.
3179     DATA   : x_ekbez LIKE ekbez   OCCURS 0 WITH HEADER LINE.
3180     STATICS: x_ekbz LIKE ekbz    OCCURS 0 WITH HEADER LINE.
3181     DATA   : x_ekbnk LIKE ekbnk   OCCURS 0 WITH HEADER LINE.
3182     STATICS: l_ebeln LIKE ekko-ebeln.
3183     STATICS: l_ebelp LIKE ekpo-ebelp.
3184
3185
3186
3187
3188     IF l_ebeln NE bseg-ebeln.
3189       SELECT SINGLE * FROM ekko WHERE ebeln = bseg-ebeln.
3190       l_ebeln = ekko-ebeln. l_ebelp = space.
3191     ELSE.
3192       sy-subrc = 0.
3193     ENDIF.
3194     CHECK sy-subrc = 0.
3195
3196     CHECK belege-waers NE ekko-waers.
3197
3198     bkpf-awkey = space.
3199
3200   * special case ekko-waers = parallel currency
3201     IF x001-bukrs NE belege-bukrs.
3202       CALL FUNCTION 'FI_CURRENCY_INFORMATION'
3203         EXPORTING
3204           i_bukrs = belege-bukrs
3205         IMPORTING
3206           e_x001  = x001
3207         EXCEPTIONS
3208           OTHERS  = 0.
3209
3210     ENDIF.
3211
3212   * use parallel amount if ekko-waers equals parallel waers 06051998
3213
3214     IF belege-dmbe2 NE 0 AND ekko-waers = x001-hwae2.
3215       belege-waers = ekko-waers. belege-waers = ekko-waers.
3216       belege-wrbtr = belege-dmbe2.
3217     ELSEIF belege-dmbe3 NE 0 AND ekko-waers = x001-hwae3.
3218       belege-waers = ekko-waers. belege-waers = ekko-waers.
3219       belege-wrbtr = belege-dmbe3.
3220     ENDIF.
3221     CHECK belege-waers NE ekko-waers.
3222   *
3223     bseg-kursr = ekko-wkurs.
3224     IF l_ebeln <> bseg-ebeln OR l_ebelp <> bseg-ebelp.
3225       REFRESH: x_ekbe, x_ekbz.
3226       l_ebelp = bseg-ebelp.
3227       CALL FUNCTION 'ME_READ_HISTORY'
3228         EXPORTING
3229           ebeln  = bseg-ebeln
3230           ebelp  = bseg-ebelp
3231           webre  = 'E'
3232         TABLES
3233           xekbe  = x_ekbe
3234           xekbes = x_ekbes
3235           xekbez = x_ekbez
3236           xekbnk = x_ekbnk
3237           xekbz  = x_ekbz
3238         EXCEPTIONS
3239           OTHERS = 4.
3240     ELSE.
3241       sy-subrc = 0.
3242     ENDIF.
3243     IF sy-subrc = 0.
3244       CLEAR: x_ekbe.                     "06051998     bseg-wrbtr.
3245       LOOP AT x_ekbe WHERE waers = ekko-waers.
3246         IF x_ekbe-dmbtr = belege-dmbtr AND x_ekbe-wrbtr NE 0.
3247           belege-wrbtr = x_ekbe-wrbtr.
3248           belege-waers = ekko-waers.
3249   *           check awkey
3250           IF bkpf-awkey = space.
3251             SELECT SINGLE awkey FROM bkpf INTO bkpf-awkey
3252                          WHERE bukrs = belege-bukrs
3253                          AND   belnr = belege-belnr
3254                          AND   gjahr = belege-gjahr.
3255             IF sy-subrc = 0 AND bkpf-awkey CS x_ekbe-belnr.
3256               EXIT.
3257             ENDIF.
3258           ENDIF.
3259         ENDIF.
3260       ENDLOOP.
3261   *      oder in Bezugsnebenkosten
3262       CHECK belege-waers NE ekko-waers.
3263       LOOP AT x_ekbz WHERE waers = ekko-waers.
3264         IF x_ekbz-dmbtr = belege-dmbtr AND x_ekbz-wrbtr NE 0.
3265           belege-wrbtr = x_ekbz-wrbtr.
3266           belege-waers = ekko-waers.
3267           bkpf-waers = ekko-waers.
3268           EXIT.
3269         ENDIF.
3270       ENDLOOP.
3271
3272   *      calculate from local currency into Ekko-  currency
3273   *      because the value was not found in the EKBE
3274       CHECK belege-waers NE ekko-waers.
3275       LOOP AT x_ekbe.
3276         IF x_ekbe-arewr = belege-dmbtr.
3277           IF t003-blart NE belege-blart.
3278             SELECT SINGLE * FROM t003 WHERE blart = belege-blart.
3279             IF t003-kurst = space. t003-kurst = 'M'. ENDIF.
3280           ENDIF.
3281   *           calculate foreign currency.
3282           bseg-dmbtr = belege-dmbtr.
3283           CALL FUNCTION 'CONVERT_TO_FOREIGN_CURRENCY'
3284             EXPORTING
3285               local_amount     = bseg-dmbtr
3286               foreign_currency = ekko-waers
3287               local_currency   = t001-waers
3288               type_of_rate     = t003-kurst
3289               rate             = ekko-wkurs
3290               date             = belege-budat
3291             IMPORTING
3292               foreign_amount   = bseg-wrbtr
3293             EXCEPTIONS
3294               error_message    = 1
3295               OTHERS           = 1.
3296           IF sy-subrc = 0.
3297             belege-waers = ekko-waers.
3298             bkpf-waers = ekko-waers.
3299             belege-wrbtr = bseg-wrbtr.
3300
3301           ELSE.
3302   *             perform log_almsg using '12'.
3303           ENDIF.
3304           EXIT.
3305         ENDIF.
3306       ENDLOOP.
3307     ENDIF.
3308   ENDFORM.
3309   *&---------------------------------------------------------------------*
3310   *&       FORM GR_IR_BUILD_TAB                                          *
3311   *&---------------------------------------------------------------------*
3312   *       ........                                                      *
3313   *---------------------------------------------------------------------*
3314   FORM gr_ir_build_tab.
3315     CHECK: NOT x_gl IS INITIAL.          "only used when OI and GL
3316     SELECT * FROM t030 WHERE ktosl = 'WRX' ORDER BY PRIMARY KEY.
3317       t_grir-ktopl = t030-ktopl.
3318       t_grir-hkont = t030-konts.
3319       COLLECT t_grir.
3320     ENDSELECT.
3321     SORT t_grir.
3322   ENDFORM.
3323   *&---------------------------------------------------------------------*
3324   *&       FORM GR_IR_CHECK                                              *
3325   *&---------------------------------------------------------------------*
3326   *       ........                                                      *
3327   *---------------------------------------------------------------------*
3328   *  -->  SKB1-XOPVW                                                    *
3329   *---------------------------------------------------------------------*
3330   FORM gr_ir_check CHANGING eopvw TYPE c
3331                             e_flag TYPE c.
3332   * GR_ir in selopt in table WRX
3333     IF skb1-saknr IN s_gracc AND NOT s_gracc[] IS INITIAL.
3334       sy-subrc = 0.
3335     ELSE.
3336       READ TABLE t_grir WITH KEY ktopl = t001-ktopl
3337                                    hkont = skb1-saknr
3338                                    BINARY SEARCH.
3339     ENDIF.
3340     IF sy-subrc NE 0.
3341   * es ist kein we/er konto
3342       e_flag = space.
3343     ELSE.
3344       e_flag = 'X'.
3345       IF pa_were = space AND pa_weref = space.
3346         eopvw = space.                   "do not use this account
3347       ENDIF.
3348     ENDIF.
3349   ENDFORM.
3350   *&---------------------------------------------------------------------*
3351   *&       FORM SELECT_BSID                                              *
3352   *&---------------------------------------------------------------------*
3353   *       ........                                                      *
3354   *---------------------------------------------------------------------*
3355   *  -->  ITAB                                                          *
3356   *---------------------------------------------------------------------*
3357   FORM select_bsid USING itab.
3358     DATA: knx_sel.
3359     RANGES: st_augdt FOR bseg-augdt OCCURS 1.
3360     IF itab = 'BSID'.
3361     ELSE.
3362       st_augdt-low = stichtag.
3363       st_augdt-sign = 'I'.
3364       st_augdt-option = 'GT'.
3365       APPEND st_augdt.
3366     ENDIF.
3367
3368     SELECT * FROM (itab) INTO bsid "#EC CI_FLDEXT_OK[2610650]
3369                        WHERE bukrs = t001-bukrs
3370                        AND   kunnr IN dkonto
3371                        AND   waers IN waehrung
3372                        AND   bstat = space
3373                        AND   augdt IN st_augdt
3374                        AND   budat LE stichtag
3375                        AND   hkont IN akonto
3376                        AND   belnr IN belnr
3377                        AND  (bsid_clauses-where_tab) ORDER BY PRIMARY KEY.
3378
3379   * is it foreign currency
3380       check_currency bsid-waers.
3381
3382       IF bsid-umskz NE space.
3383   * Pruefen, ob Wechsel zu bewerten ist
3384         IF bsid-umsks = 'W'.
3385   *       CHECK: BSID-WVERW = SPACE.      "nicht extrahieren
3386           IF bsid-wverw NE space.
3387             SELECT SINGLE wverd FROM bsed INTO bsed-wverd
3388                                           WHERE bukrs = bsid-bukrs
3389                                           AND   belnr = bsid-belnr
3390                                           AND   gjahr = bsid-gjahr
3391                                           AND   buzei = bsid-buzei.
3392             IF p_transl EQ space.
3393               CHECK bsed-wverd GT stichtag.
3394             ENDIF.
3395           ENDIF.
3396         ENDIF.
3397       ENDIF.
3398
3399       IF t044a-ar_grup NE space AND bsid-kunnr NE kna1-kunnr.
3400         PERFORM get_dkonzs_ar CHANGING dk_konzs.
3401         kna1-kunnr = bsid-kunnr.
3402       ENDIF.
3403
3404       MOVE-CORRESPONDING bsid TO belege. "#EC CI_FLDEXT_OK[2610650]
3405       belege-konto = bsid-kunnr.
3406       belege-koart = 'D'.
3407
3408       bseg-rebzg = bsid-rebzg.
3409       bseg-rebzj = bsid-rebzj.
3410       bseg-rebzz = bsid-rebzz.
3411       bseg-xcpdd = bsid-xcpdd.
3412
3413       IF bsid-xcpdd = 'X'.
3414         SELECT SINGLE * FROM kna1 WHERE kunnr = belege-konto.
3415         bseg-xcpdd = kna1-xcpdk.
3416       ENDIF.
3417
3418       IF knb1-kunnr NE bsid-kunnr
3419          OR knb1-bukrs NE bsid-bukrs.
3420   *    setup info from master data
3421         SELECT SINGLE *  FROM knb1 INTO knb1
3422                          WHERE  kunnr = bsid-kunnr
3423                          AND    bukrs = bsid-bukrs.
3424         akonts = knb1-akont.
3425
3426   * free selections
3427         knx_sel = space.
3428         IF kna1_clauses_filled = 'X'.
3429           SELECT SINGLE kunnr  FROM kna1 INTO kna1-kunnr
3430                                WHERE  kunnr = knb1-kunnr
3431                                AND   (kna1_clauses-where_tab).
3432           IF sy-subrc <> 0. knx_sel = 'X'. ENDIF.
3433         ENDIF.
3434         CHECK knx_sel = space.
3435
3436         IF knb1_clauses_filled = 'X'.
3437           SELECT SINGLE kunnr  FROM knb1 INTO knb1-kunnr
3438                                WHERE  kunnr = knb1-kunnr
3439                                AND    bukrs = bsid-bukrs
3440                                AND   (knb1_clauses-where_tab).
3441           IF sy-subrc <> 0. knx_sel = 'X'. ENDIF.
3442         ENDIF.
3443       ENDIF.
3444       CHECK knx_sel = space.
3445
3446       PERFORM extract.
3447
3448     ENDSELECT.
3449   ENDFORM.
3450   *&---------------------------------------------------------------------*
3451   *&       FORM get_dkonzs_AR                                            *
3452   *&---------------------------------------------------------------------*
3453   *       ........                                                      *
3454   *---------------------------------------------------------------------*
3455   *  -->  e_group                                                       *
3456   *---------------------------------------------------------------------*
3457   FORM get_dkonzs_ar CHANGING e_group LIKE dk_konzs.
3458     SELECT SINGLE konzs FROM kna1 INTO  e_group
3459                                   WHERE kunnr = bsid-kunnr.
3460     IF e_group = space.
3461       e_group = bsid-kunnr.
3462     ENDIF.
3463   ENDFORM.
3464   *&---------------------------------------------------------------------*
3465   *&       FORM SELECT_BSIK                                              *
3466   *&---------------------------------------------------------------------*
3467   *       ........                                                      *
3468   *---------------------------------------------------------------------*
3469   *  -->  ITAB                                                          *
3470   *---------------------------------------------------------------------*
3471   FORM select_bsik USING itab.
3472     DATA: lfx_sel.
3473     RANGES: st_augdt FOR bseg-augdt OCCURS 1.
3474     IF itab = 'BSIK'.
3475     ELSE.
3476       st_augdt-low = stichtag.
3477       st_augdt-sign = 'I'.
3478       st_augdt-option = 'GT'.
3479       APPEND st_augdt.
3480     ENDIF.
3481     SELECT * FROM (itab) INTO  bsik  "#EC CI_FLDEXT_OK[2610650]
3482                        WHERE bukrs =  t001-bukrs
3483                        AND   lifnr IN kkonto
3484                        AND   waers IN waehrung
3485                        AND   bstat = space
3486                        AND   augdt IN st_augdt
3487                        AND   budat LE stichtag
3488                        AND   hkont IN akonto
3489                        AND   belnr IN belnr
3490                        AND  (bsik_clauses-where_tab) ORDER BY PRIMARY KEY.
3491
3492   * is it foreign currency
3493       check_currency bsik-waers.
3494
3495       IF t044a-ap_grup NE space.
3496         PERFORM get_dkonzs_ap CHANGING dk_konzs.
3497         lfa1-lifnr = bsik-lifnr.
3498       ENDIF.
3499
3500       MOVE-CORRESPONDING bsik TO belege. "#EC CI_FLDEXT_OK[2610650]
3501       belege-konto = bsik-lifnr.
3502       belege-koart = 'K'.
3503
3504       bseg-rebzg = bsik-rebzg.
3505       bseg-rebzj = bsik-rebzj.
3506       bseg-rebzz = bsik-rebzz.
3507       bseg-xcpdd = bsik-xcpdd.
3508
3509       IF bsik-xcpdd = 'X'.
3510         SELECT SINGLE * FROM lfa1 WHERE lifnr = belege-konto.
3511         bseg-xcpdd = lfa1-xcpdk.
3512       ENDIF.
3513
3514       IF     lfb1-lifnr NE bsik-lifnr
3515           OR lfb1-bukrs NE bsik-bukrs.
3516   *    setup info from master data
3517         SELECT SINGLE *  FROM    lfb1 INTO lfb1
3518                          WHERE   lifnr = bsik-lifnr
3519                          AND     bukrs = bsik-bukrs.
3520         akonts = lfb1-akont.
3521
3522   * free selections
3523         lfx_sel = space.
3524         IF lfa1_clauses_filled = 'X'.
3525           SELECT SINGLE lifnr  FROM lfa1 INTO lfa1-lifnr
3526                                WHERE  lifnr = lfb1-lifnr
3527                                AND   (lfa1_clauses-where_tab).
3528           IF sy-subrc <> 0. lfx_sel = 'X'. ENDIF.
3529         ENDIF.
3530         CHECK lfx_sel = space.
3531
3532         IF lfb1_clauses_filled = 'X'.
3533           SELECT SINGLE lifnr  FROM lfb1 INTO lfb1-lifnr
3534                                WHERE  lifnr = lfb1-lifnr
3535                                AND    bukrs = bsik-bukrs
3536                                AND   (lfb1_clauses-where_tab).
3537           IF sy-subrc <> 0. lfx_sel = 'X'. ENDIF.
3538         ENDIF.
3539       ENDIF.
3540       CHECK lfx_sel = space.
3541
3542       PERFORM extract.
3543
3544     ENDSELECT.
3545   ENDFORM.
3546   *&---------------------------------------------------------------------*
3547   *&      Form  get_dkonzs_AP
3548   *&---------------------------------------------------------------------*
3549   *       .........
3550   *----------------------------------------------------------------------*
3551   *  -->  p1        text
3552   *  <--  p2        text
3553   *----------------------------------------------------------------------*
3554   FORM get_dkonzs_ap CHANGING e_group LIKE dk_konzs.
3555     SELECT SINGLE konzs FROM lfa1 INTO e_group
3556                                   WHERE lifnr = bsik-lifnr.
3557     IF e_group = space.
3558       e_group = bsik-lifnr.
3559     ENDIF.
3560   ENDFORM.
3561   *&---------------------------------------------------------------------*
3562   *&       FORM SELECT_BSIS                                              *
3563   *&---------------------------------------------------------------------*
3564   *       ........                                                      *
3565   *---------------------------------------------------------------------*
3566   *  -->  ITAB                                                          *
3567   *---------------------------------------------------------------------*
3568   FORM select_bsis USING itab.
3569     RANGES: st_augdt FOR bseg-augdt OCCURS 1.
3570     RANGES: l_curr_sel FOR bkpf-waers.
3571
3572   * GR/IR accounts have GR in local currency
3573     IF grir_flag = space.
3574       l_curr_sel[] = curr_sel[].
3575     ENDIF.
3576
3577     IF itab = 'BSIS'.
3578     ELSE.
3579       st_augdt-low = stichtag.
3580       st_augdt-sign = 'I'.
3581       st_augdt-option = 'GT'.
3582       APPEND st_augdt.
3583     ENDIF.
3584     SELECT * FROM (itab) "#EC CI_FLDEXT_OK[2610650]
3585          INTO CORRESPONDING FIELDS OF bsis
3586                 WHERE bukrs = skb1-bukrs
3587                 AND   budat LE stichtag
3588                 AND   augdt IN st_augdt
3589                 AND   hkont = skb1-saknr
3590                 AND   waers IN waehrung
3591                 AND   waers IN l_curr_sel
3592                 AND   bstat = space
3593                 AND   belnr IN belnr
3594                 AND (bsis_clauses-where_tab).
3595       MOVE-CORRESPONDING bsis TO belege. "#EC CI_FLDEXT_OK[2610650]
3596       CLEAR belege-konto.
3597       belege-koart = 'S'.
3598
3599       SELECT SINGLE rdiff rdif2 rdif3 gbetr kursr
3600                     bdiff bdif2 bdif3
3601                     rebzj rebzg rebzz    "sachkonten
3602                     ebeln ebelp          "evtl were
3603                       FROM bseg
3604                       INTO CORRESPONDING FIELDS OF bseg
3605                                  WHERE bukrs = belege-bukrs
3606                                  AND belnr   = belege-belnr
3607                                  AND gjahr   = belege-gjahr
3608                                  AND buzei   = belege-buzei.
3609   * ist es ein werekonto
3610       IF grir_flag <> space AND bseg-ebeln <> space
3611         AND pa_were <> space.            "
3612         PERFORM gr_ir_get_order.
3613         bsis-waers = belege-waers.       "use ekko-wars.
3614       ELSE.
3615         bseg-ebeln = space.
3616       ENDIF.
3617   * is it foreign currency
3618       check_currency bsis-waers.
3619
3620       CHECK belege-waers IN waehrung.
3621   *   setup proper value vor wrbtr in case of translation
3622       IF belege-wrbtr = 0.
3623         IF bk_methode-meth2 NE space
3624           AND bk_methode-curs2 = '2'.
3625           belege-wrbtr = belege-dmbtr + belege-bdiff.
3626         ELSEIF bk_methode-meth3 NE space
3627           AND bk_methode-curs3 = '2'.
3628           belege-wrbtr = belege-dmbtr + belege-bdiff.
3629         ENDIF.
3630       ENDIF.
3631       PERFORM extract.
3632
3633     ENDSELECT.
3634   ENDFORM.
3635   *&---------------------------------------------------------------------*
3636   *&      Form  get_dkonzs_GL                                            *
3637   *&---------------------------------------------------------------------*
3638   *       text
3639   *----------------------------------------------------------------------*
3640   FORM get_dkonzs_gl CHANGING e_group LIKE dk_konzs.
3641     e_group = skb1-bewgp.
3642
3643     IF e_group = space.
3644       e_group = skb1-saknr.
3645     ENDIF.
3646   ENDFORM.
3647   *&---------------------------------------------------------------------*
3648   *&      Form  CHECK_ZBUKRS
3649   *&---------------------------------------------------------------------*
3650   *       text
3651   *----------------------------------------------------------------------*
3652   *  -->  p1        text
3653   *  <--  p2        text
3654   *----------------------------------------------------------------------*
3655   FORM check_zbukrs.
3656     DATA: BEGIN OF zhaus.
3657             INCLUDE STRUCTURE haus.
3658     DATA: END OF zhaus.
3659
3660     SELECT SINGLE * FROM t001 WHERE bukrs = p_zbukrs.
3661     IF sy-subrc NE 0.
3662       MESSAGE e817 WITH p_zbukrs.
3663     ENDIF.
3664   * allow only one curtp
3665
3666     IF p_bwber = space.
3667       t033-curtp = p_curtp1.
3668     ENDIF.
3669   * hauswaehrungen herausfinden
3670     PERFORM derive_hauswaers USING t001-bukrs t033-curtp
3671                              CHANGING zhaus.
3672     SELECT * FROM t001 WHERE bukrs IN bukrs.
3673       PERFORM derive_hauswaers USING t001-bukrs t033-curtp
3674                                CHANGING haus.
3675       CHECK haus-waers NE space.         "no parallel currency
3676   * Einschränkung: Hauwaehrungen müssen identisch sein (logische Einschr.)
3677   * Ausserdem muss die Reihenfolge der parallele Währungen uebereinstimmen
3678   * das ist eine reine programmtechnische Einschränkung. Damit ist
3679   * sichergestellt das immer die korrekten Betraege addiert werden,
3680   * denn es koennte ja in bukrs 0001 in dmbe2 der typ 30 und in
3681   * bukrs 0002 in dmbe2 der typ 20 sein, und er typ 30 dmbe3.
3682   *
3683       IF zhaus-waers NE haus-waers OR zhaus-field NE haus-field.
3684         MESSAGE e181.
3685       ENDIF.
3686     ENDSELECT.
3687   ENDFORM.                               " CHECK_ZBUKRS
3688   *&---------------------------------------------------------------------*
3689   *&      Form  FILL_CURR_SEL
3690   *&---------------------------------------------------------------------*
3691   *       text
3692   *----------------------------------------------------------------------*
3693   *      -->P_T001_BUKRS  text
3694   *----------------------------------------------------------------------*
3695   FORM fill_curr_sel USING    p_t001_bukrs LIKE t001-bukrs.
3696     REFRESH curr_sel.
3697     IF p_curtp1 = '10'.
3698       curr_sel-low    = bk_methode-hwae1.
3699       curr_sel-option = 'NE'.
3700       curr_sel-sign   = 'I'.
3701       APPEND curr_sel.
3702     ENDIF.
3703   ENDFORM.                               " FILL_CURR_SEL
3704   *&---------------------------------------------------------------------*
3705   *&      Form  CHECK_INCL_FLD
3706   *&---------------------------------------------------------------------*
3707   *       text
3708   *----------------------------------------------------------------------*
3709   *  -->  p1        text
3710   *  <--  p2        text
3711   *----------------------------------------------------------------------*
3712   FORM check_incl_fld.
3713   *  loop at incl_fld.
3714   *    loop at fieldtab_glu1
3715   *     where fieldname = incl_fld-low.
3716   *      exit.
3717   *    endloop.
3718   *    if sy-subrc ne 0.
3719   *      message e600 with text-002 incl_fld-low.
3720   *    endif.
3721   ** already defined
3722   ** show the already defined fields
3723   **   LOOP AT L_T_F INTO L_T_F_LINE.
3724   **     IF L_T_F_LINE = INCL_FLD-LOW.
3725   **       DELETE INCL_FLD.
3726   **       MESSAGE I600 WITH TEXT-003 INCL_FLD-LOW.
3727   **     ENDIF.
3728   **   ENDLOOP.
3729   **  endloop.
3730   ENDFORM.                               " CHECK_INCL_FLD
3731   *&---------------------------------------------------------------------*
3732   *&       FORM f4_for_incl_fld                                          *
3733   *&---------------------------------------------------------------------*
3734   *       ........                                                      *
3735   *---------------------------------------------------------------------*
3736   *  -->  feld                                                          *
3737   *---------------------------------------------------------------------*
3738   FORM f4_for_incl_fld USING feld.
3739
3740   * Aufruf
3741   *  data:
3742   *      f4ret like ddshretval occurs 1 with header line.
3743   *
3744   *  call function 'F4IF_INT_TABLE_VALUE_REQUEST'
3745   *       EXPORTING
3746   *            retfield   = 'FIELDNAME'
3747   *            value_org  = 'S'
3748   *       TABLES
3749   *            value_tab  = f4tab
3750   *            return_tab = f4ret.
3751
3752   * Wert übernehmen
3753   *  check not f4ret[] is initial.
3754   *  read table f4ret index 1.
3755   *  feld = f4ret-fieldval.
3756
3757   ENDFORM.
3758   *&---------------------------------------------------------------------*
3759   *&       FORM schedman_start_stop                                      *
3760   *&---------------------------------------------------------------------*
3761   *       ........                                                      *
3762   *---------------------------------------------------------------------*
3763   *  -->  icommand                                                      *
3764   *---------------------------------------------------------------------*
3765   FORM schedman_start_stop USING icommand.
3766
3767     STATICS: ls_key_static LIKE schedman_key.
3768
3769     DATA: gs_key      LIKE schedman_key.
3770
3771     DATA: ld_worklist_flag(1).
3772     DATA:  ls_detail   LIKE schedman_detail_user.
3773     DATA:  lt_selkrit  LIKE schedman_selkrit OCCURS 0 WITH HEADER LINE.
3774     DATA:  lt_param    LIKE schedman_selkrit OCCURS 0 WITH HEADER LINE.
3775     DATA:  ls_witem    LIKE scma_witem.
3776     DATA: ls_scma_event LIKE scma_event.
3777     DATA: ls_ext              LIKE schedman_ext.
3778     DATA: ls_message LIKE schedman_message,
3779           ld_objects LIKE smmain-nr_of_objects,
3780           ld_aplstat LIKE smmain-aplstat.
3781   * muss in scmatasks
3782     ls_detail-repid = 'SAPF100'.         "sy-repid.
3783     ls_detail-variante = sy-slset.       "<<die variante
3784     ls_detail-application = 'FI-GL'.
3785   * save some select-options
3786     CLEAR lt_selkrit.
3787     lt_selkrit-structure = 'BKPF'.
3788     lt_selkrit-field     = 'BUKRS'.
3789     LOOP AT bukrs.
3790   *   lt_selkrit-entry     =  .
3791       MOVE-CORRESPONDING bukrs TO lt_selkrit.
3792       APPEND lt_selkrit.
3793     ENDLOOP.
3794   *
3795     lt_param-entry     = 1.
3796     lt_param-optio = 'EQ'.
3797     lt_param-structure = 'RFPDO'.
3798     lt_param-field     = 'SBEWSTAG'.
3799     lt_param-low    = stichtag.
3800     APPEND lt_param.
3801   *
3802     lt_param-structure = 'RFPDO'.
3803     lt_param-field     = 'ALLGLINE'.
3804     lt_param-low    = title.
3805     APPEND lt_param.
3806   *
3807     lt_param-structure = 'RFPDO1'.
3808     lt_param-field     = 'F100METH'.
3809     lt_param-low    = bwmet1.
3810     APPEND lt_param.
3811
3812
3813     IF icommand = 'START'.
3814   *.fill information from Workflow-include into structure
3815       CLEAR ls_witem.
3816       ls_witem-wf_witem = wf_witem.
3817       ls_witem-wf_wlist = wf_wlist.
3818       CALL FUNCTION 'KPEP_MONI_INIT_RECORD'
3819         EXPORTING
3820           ls_detail  = ls_detail
3821           ls_witem   = ls_witem
3822   *       LS_APPL    =
3823   *       LD_WORKLIST_FLAG = ' '
3824         IMPORTING
3825           ls_key     = ls_key_static
3826         TABLES
3827           lt_selkrit = lt_selkrit
3828           lt_param   = lt_param.
3829     ELSEIF icommand = 'STOP'.
3830       ld_aplstat  = '0'.
3831       IF g_e_msg ='X'.
3832         ld_aplstat  = '4'.    "set status for schedman
3833         IF sy-batch = 'X'.
3834           MESSAGE s348(sy).
3835         ENDIF.
3836       ENDIF. "error occurred
3837
3838   *.Tell workflow to stop or to go on
3839       CLEAR ls_scma_event.
3840   *  IF LD_APLSTAT = '4' OR LD_APLSTAT = 'A'.
3841   *     LS_SCMA_EVENT-WF_EVENT = CS_WF_EVENTS-ERROR.
3842   *  ELSE.
3843       ls_scma_event-wf_event = cs_wf_events-finished.
3844   *  ENDIF.
3845
3846       ls_scma_event-wf_witem = wf_witem.
3847       ls_scma_event-wf_okey = wf_okey.
3848
3849       CALL FUNCTION 'KPEP_MONI_CLOSE_RECORD'
3850         EXPORTING
3851           ls_key        = ls_key_static
3852   *       LS_MESSAGE    =
3853   *       LD_OBJECTS    =
3854   *       LS_EXT        =
3855   *       LS_RL         =
3856           ls_scma_event = ls_scma_event
3857         TABLES
3858           lt_spool      = gt_spono
3859         CHANGING
3860           ld_aplstat    = ld_aplstat
3861         EXCEPTIONS
3862   *       NO_ID_GIVEN   = 1
3863           OTHERS        = 0.
3864
3865
3866     ENDIF.
3867     COMMIT WORK.
3868
3869   ENDFORM.
3870
3871   *&---------------------------------------------------------------------*
3872   *&      Form  FREE_SELECTIONS
3873   *&---------------------------------------------------------------------*
3874   *       free selections
3875   *----------------------------------------------------------------------*
3876   *  -->  p1        text
3877   *  <--  p2        text
3878   *----------------------------------------------------------------------*
3879   FORM free_selections.
3880   *? DATA BEGIN OF P_TABLES OCCURS 10.
3881   *?          INCLUDE STRUCTURE RSDSTABS.
3882   *?  DATA END   OF P_TABLES.
3883     DATA BEGIN OF tables_tab OCCURS 10.
3884             INCLUDE STRUCTURE rsdstabs.
3885     DATA END   OF tables_tab.
3886   *Felder obiger Tabellen
3887     DATA: BEGIN OF fields OCCURS 10.
3888             INCLUDE STRUCTURE rsdsfields.
3889     DATA: END   OF fields.
3890     DATA: BEGIN OF fields_not OCCURS 10.
3891             INCLUDE STRUCTURE rsdsfields.
3892     DATA: END   OF fields_not.
3893
3894     DATA:ds_expr_tab TYPE rsds_expr_tab.
3895     DATA:ds_expr_tab_line LIKE rsdsexpr.
3896
3897     DATA: ds_texpr  TYPE rsds_expr.
3898
3899     DATA: selection_id LIKE  rsdynsel-selid.
3900     IF x_ap <> space.
3901   * credit
3902       tables_tab-prim_tab = 'LFA1'. APPEND tables_tab.
3903       tables_tab-prim_tab = 'LFB1'. APPEND tables_tab.
3904       tables_tab-prim_tab = 'BSIK'. APPEND tables_tab.
3905     ENDIF.
3906   *
3907     IF x_ar <> space.
3908       tables_tab-prim_tab = 'KNA1'. APPEND tables_tab.
3909       tables_tab-prim_tab = 'KNB1'. APPEND tables_tab.
3910       tables_tab-prim_tab = 'BSID'. APPEND tables_tab.
3911     ENDIF.
3912
3913     IF x_gl <> space OR x_salbew NE space.
3914       tables_tab-prim_tab = 'SKA1'. APPEND tables_tab.
3915       tables_tab-prim_tab = 'SKB1'. APPEND tables_tab.
3916     ENDIF.
3917
3918     IF x_gl <> space.
3919       tables_tab-prim_tab = 'BSIS'. APPEND tables_tab.
3920     ENDIF.
3921     IF x_ap <> space OR x_ar <> space OR x_gl <> space.
3922       tables_tab-prim_tab = 'BSEG'. APPEND tables_tab.
3923     ENDIF.
3924   * do not allow empty selection table
3925     DESCRIBE TABLE tables_tab LINES sy-tfill.
3926     IF sy-tfill = 0. MESSAGE e124. ENDIF.
3927   * fill fields from previous fs_dyns in case it was in variant
3928     LOOP AT fs_dyns-texpr INTO ds_texpr.
3929
3930       ds_expr_tab = ds_texpr-expr_tab.
3931       fields-tablename = ds_texpr-tablename.
3932       LOOP AT ds_expr_tab INTO ds_expr_tab_line
3933               WHERE fieldname <> space.
3934         fields-fieldname = ds_expr_tab_line-fieldname.
3935         COLLECT fields.
3936       ENDLOOP.
3937     ENDLOOP.
3938   *** because these are already on the selection-screen nur bei 'F'
3939   *fields_not-TABLENAME = tables_tab-PRIM_TAB.
3940   *fields_not-FIELDNAME = 'BUKRS'. append fields_not.
3941   *fields_not-FIELDNAME = 'WAERS'. append fields_not.
3942   *fields_not-FIELDNAME = 'LIFNR'. append fields_not.
3943   *fields_not-FIELDNAME = 'HKONT'. append fields_not.
3944   *fields_not-FIELDNAME = 'KUNNR'. append fields_not.
3945   *fields_not-FIELDNAME = 'BELNR'. append fields_not.
3946   ***
3947   ***
3948     CALL FUNCTION 'FREE_SELECTIONS_INIT'
3949       EXPORTING
3950         kind                     = 'T'
3951   *         Alte Abgrenzungen erscheinen wieder
3952         expressions              = fs_dyns-texpr
3953   *     FIELD_GROUPS_KEY         =
3954   *     RESTRICTION              =
3955   *     ALV                      =
3956   *     CURR_QUAN_PROG           = SY-CPROG
3957   *     CURR_QUAN_RELATION       =
3958       IMPORTING
3959         selection_id             = selection_id
3960         where_clauses            = fs_dyns-clauses
3961         expressions              = fs_dyns-texpr
3962         field_ranges             = fs_dyns-trange
3963         number_of_active_fields  = fs_num
3964       TABLES
3965         tables_tab               = tables_tab
3966         fields_tab               = fields
3967   *     FIELD_DESC               =
3968   *     FIELD_TEXTS              =
3969   *     EVENTS                   =
3970   *     EVENT_FIELDS             =
3971         fields_not_selected      = fields_not
3972       EXCEPTIONS
3973         fields_incomplete        = 1
3974         fields_no_join           = 2
3975         field_not_found          = 3
3976         no_tables                = 4
3977         table_not_found          = 5
3978         expression_not_supported = 6
3979         incorrect_expression     = 7
3980         illegal_kind             = 8
3981         area_not_found           = 9
3982         inconsistent_area        = 10
3983         kind_f_no_fields_left    = 11
3984         kind_f_no_fields         = 12
3985         too_many_fields          = 13
3986         dup_field                = 14
3987         field_no_type            = 15
3988         field_ill_type           = 16
3989         dup_event_field          = 17
3990         node_not_in_ldb          = 18
3991         area_no_field            = 19
3992         OTHERS                   = 20.
3993     IF sy-subrc <> 0.
3994       MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
3995               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
3996     ENDIF.
3997
3998     CHECK sy-subrc = 0.
3999     CALL FUNCTION 'FREE_SELECTIONS_DIALOG'
4000       EXPORTING
4001         selection_id            = selection_id
4002         title                   = 'Freie Selektion '(013)
4003   *     FRAME_TEXT              = ' '
4004   *     STATUS                  =
4005   *     AS_WINDOW               = ' '
4006   *     START_ROW               = 2
4007   *     START_COL               = 2
4008   *     NO_INTERVALS            = ' '
4009   *     JUST_DISPLAY            = ' '
4010   *     PFKEY                   =
4011   *     ALV                     = ' '
4012   *     TREE_VISIBLE            = 'X'
4013   *     DIAG_TEXT_1             =
4014   *     DIAG_TEXT_2             =
4015   *     WARNING_TITLE           =
4016       IMPORTING
4017         where_clauses           = fs_dyns-clauses
4018         expressions             = fs_dyns-texpr
4019         field_ranges            = fs_dyns-trange
4020         number_of_active_fields = fs_num
4021       TABLES
4022         fields_tab              = fields
4023   *     FCODE_TAB               =
4024         fields_not_selected     = fields_not
4025       EXCEPTIONS
4026   *     internal_error          =
4027   *     no_action               =
4028   *     selid_not_found         =
4029   *     illegal_status          =
4030         OTHERS                  = 0.
4031
4032
4033
4034
4035
4036
4037   ENDFORM.
4038   *&---------------------------------------------------------------------*
4039   *&      Form  FS_SET_SSCRTEXTS_DYNSEL
4040   *&---------------------------------------------------------------------*
4041   *       Text für Drucktaste
4042   *----------------------------------------------------------------------*
4043   *  -->  p1        text
4044   *  <--  p2        text
4045   *----------------------------------------------------------------------*
4046   FORM fs_set_sscrtexts_dynsel CHANGING p_text " LIKE SSCRTEXTS-DYNSEL.
4047                                                LIKE smp_dyntxt.
4048     DATA l_text LIKE smp_dyntxt.
4049
4050     MOVE: icon_fencing TO l_text-icon_id,
4051           'Free selections'(270) TO l_text-text.              "#EC *
4052
4053     IF fs_num > 0.
4054       WRITE fs_num TO l_text-icon_text(2).
4055       MOVE 'active'(271) TO l_text-icon_text+3.               "#EC *
4056     ENDIF.
4057     p_text = l_text.
4058
4059   ENDFORM.                               " SET_SSCRTEXTS_DYNSEL
4060   *&---------------------------------------------------------------------*
4061   *&      Form FREE_SELECTIONS_BUILD
4062   *&---------------------------------------------------------------------*
4063   *       Build free selections
4064   *----------------------------------------------------------------------*
4065   *  -->  p1        text
4066   *  <--  p2        text
4067   *----------------------------------------------------------------------*
4068   FORM free_selections_build.
4069   * free selections.
4070     CLEAR bseg_clauses.
4071   * MOVE 'BSEG' TO DS_CLAUSES-TABLENAME.
4072     READ TABLE fs_dyns-clauses
4073                WITH KEY 'BSEG'               INTO bseg_clauses.
4074     IF sy-subrc = 0. bseg_clauses_filled = 'X'. ENDIF.
4075     READ TABLE fs_dyns-clauses
4076                WITH KEY 'BKPF'               INTO bkpf_clauses.
4077     IF sy-subrc = 0. bkpf_clauses_filled = 'X'. ENDIF.
4078   *
4079     READ TABLE fs_dyns-clauses WITH KEY 'LFA1' INTO lfa1_clauses.
4080     IF sy-subrc = 0. lfa1_clauses_filled = 'X'. ENDIF.
4081     READ TABLE fs_dyns-clauses WITH KEY 'LFB1' INTO lfb1_clauses.
4082     IF sy-subrc = 0. lfb1_clauses_filled = 'X'. ENDIF.
4083     READ TABLE fs_dyns-clauses WITH KEY 'BSIK' INTO bsik_clauses.
4084     IF sy-subrc = 0. bsik_clauses_filled = 'X'. ENDIF.
4085     READ TABLE fs_dyns-clauses WITH KEY 'KNA1' INTO kna1_clauses.
4086     IF sy-subrc = 0. kna1_clauses_filled = 'X'. ENDIF.
4087     READ TABLE fs_dyns-clauses WITH KEY 'KNB1' INTO knb1_clauses.
4088     IF sy-subrc = 0. knb1_clauses_filled = 'X'. ENDIF.
4089     READ TABLE fs_dyns-clauses WITH KEY 'BSID' INTO bsid_clauses.
4090     IF sy-subrc = 0. bsid_clauses_filled = 'X'. ENDIF.
4091   * Open items G/L
4092     READ TABLE fs_dyns-clauses WITH KEY 'SKA1' INTO ska1_clauses.
4093     IF sy-subrc = 0. ska1_clauses_filled = 'X'. ENDIF.
4094     READ TABLE fs_dyns-clauses WITH KEY 'SKB1' INTO skb1_clauses.
4095     IF sy-subrc = 0. skb1_clauses_filled = 'X'. ENDIF.
4096     READ TABLE fs_dyns-clauses WITH KEY 'BSIS' INTO bsis_clauses.
4097     IF sy-subrc = 0. bsis_clauses_filled = 'X'. ENDIF.
4098   * G/L non open items for
4099     READ TABLE fs_dyns-texpr WITH KEY 'SKA1' INTO sdf_expressions_line.
4100     APPEND sdf_expressions_line TO sdf_expressions.           "11102000
4101     READ TABLE fs_dyns-texpr WITH KEY 'SKB1' INTO sdf_expressions_line.
4102     APPEND sdf_expressions_line TO sdf_expressions.           "11102000
4103   ENDFORM.
4104   FORM get_co_pa_flag USING ibukrs LIKE t001-bukrs
4105                             xflag.
4106     DATA: l_rf048_a LIKE  rf048_a.
4107     DATA: gjahr LIKE bkpf-gjahr.
4108     gjahr = sy-datum(4).
4109     CALL FUNCTION 'BREAKDOWN_ACTIVITY_GET'
4110       EXPORTING
4111         i_bukrs           = ibukrs
4112         i_gjahr           = gjahr
4113       IMPORTING
4114         e_fields          = l_rf048_a
4115       EXCEPTIONS
4116         bukrs_not_defined = 1
4117         OTHERS            = 2.
4118     IF l_rf048_a-xprctr NE space.
4119       xflag = 'X'.
4120     ELSE.
4121       xflag = space.
4122     ENDIF.
4123   ENDFORM.
4124   *&---------------------------------------------------------------------*
4125   *&      Form  buffer_selection
4126   *&---------------------------------------------------------------------*
4127   *       text
4128   *----------------------------------------------------------------------*
4129   *  -->  p1        text
4130   *  <--  p2        text
4131   *----------------------------------------------------------------------*
4132   FORM buffer_selection.
4133
4134     DATA: wa_fcurr_val     TYPE zjv_fcurr_val,
4135           lt_fcurr_val     TYPE TABLE OF zjv_fcurr_val,
4136           l_time_stamp(15) TYPE c.
4137
4138     CLEAR wa_fcurr_val.
4139     SELECT SINGLE * FROM zjv_fcurr_val
4140       INTO wa_fcurr_val
4141      WHERE user_name = sy-uname.
4142
4143     wa_fcurr_val-vname = s_vname-low.
4144     wa_fcurr_val-bukrs = bukrs-low.
4145     wa_fcurr_val-recid = s_recid-low.
4146     wa_fcurr_val-egrup = s_egrup-low.
4147     wa_fcurr_val-crdate = sy-datum.
4148
4149     IF sy-subrc = 0.
4150
4151       CONCATENATE sy-datum sy-uzeit INTO l_time_stamp.
4152       wa_fcurr_val-time_stamp = l_time_stamp.
4153
4154       UPDATE zjv_fcurr_val FROM wa_fcurr_val.
4155
4156     ELSE.
4157
4158       wa_fcurr_val-user_name = sy-uname.
4159       CONCATENATE sy-datum sy-uzeit INTO l_time_stamp.
4160       wa_fcurr_val-time_stamp = l_time_stamp.
4161       wa_fcurr_val-mandt = sy-mandt.
4162
4163       APPEND wa_fcurr_val TO lt_fcurr_val.
4164
4165       INSERT zjv_fcurr_val FROM TABLE lt_fcurr_val.
4166
4167     ENDIF.
4168
4169
4170   ENDFORM.                    " buffer_selection
4171   *&---------------------------------------------------------------------*
4172   *&      Form  fill_custom_fields
4173   *&---------------------------------------------------------------------*
4174   *       text
4175   *----------------------------------------------------------------------*
4176   *  -->  p1        text
4177   *  <--  p2        text
4178   *----------------------------------------------------------------------*
4179   FORM fill_custom_fields.
4180
4181     IF s_vname IS INITIAL.
4182
4183       REFRESH: s_vname.
4184
4185       SELECT SINGLE vname FROM zjv_fcurr_val
4186          INTO s_vname-low
4187         WHERE user_name = sy-uname.
4188
4189       IF sy-subrc EQ 0.
4190
4191         APPEND: s_vname.
4192
4193       ENDIF.
4194
4195     ENDIF.
4196
4197     IF s_recid IS INITIAL.
4198
4199       REFRESH: s_recid.
4200
4201       SELECT SINGLE recid FROM zjv_fcurr_val
4202          INTO s_recid-low
4203         WHERE user_name = sy-uname.
4204
4205       IF sy-subrc EQ 0.
4206
4207         APPEND: s_recid.
4208
4209       ENDIF.
4210
4211     ENDIF.
4212
4213     IF s_egrup IS INITIAL.
4214
4215       REFRESH: s_egrup.
4216
4217       SELECT SINGLE egrup FROM zjv_fcurr_val
4218          INTO s_egrup-low
4219         WHERE user_name = sy-uname.
4220
4221       IF sy-subrc EQ 0.
4222
4223         APPEND: s_egrup.
4224
4225       ENDIF.
4226
4227     ENDIF.
4228
4229   ENDFORM.                    " fill_custom_fields
*--- End of ZJV_SAPF100 - 4229 lines ---

----------------------------------------------------------------------------------------------------
Include          FIUUMS40                                  Level 1    Page 2
Object           ZJV_SAPF100                               Lines 14
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:11
----------------------------------------------------------------------------------------------------
1      *-----------------------------------------------------------------------
2      *        INCLUDE FIUUMS40
3      *
4      *        Tabelle UMS40 mit den Buchungskreisen bei denen mindestens
5      *        ein Beleg bereits nach 4.0 umgesetzt wurde
6      *-----------------------------------------------------------------------
7
8      DATA:    BEGIN OF UMS40 OCCURS 10,
9                 BUKRS             LIKE BKPF-BUKRS,
10              END OF UMS40.
11
12
13
14
*--- End of FIUUMS40 - 14 lines ---

----------------------------------------------------------------------------------------------------
Include          RKASMAWF                                  Level 1    Page 3
Object           ZJV_SAPF100                               Lines 9
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:11
----------------------------------------------------------------------------------------------------
1      ***INCLUDE RKASMAWF .
2
3
4      *          Ablauf-ID
5      PARAMETERS: WF_WITEM LIKE SCMA_WITEM-WF_WITEM NO-DISPLAY,
6      *          Job-ID
7                 WF_OKEY  LIKE SWOTOBJID-OBJKEY NO-DISPLAY,
8      *          Worklist-ID
9                 WF_WLIST LIKE SCMA_WITEM-WF_WLIST NO-DISPLAY.
*--- End of RKASMAWF - 9 lines ---

----------------------------------------------------------------------------------------------------
Include          SCHEDMAN_EVENTS                           Level 1    Page 4
Object           ZJV_SAPF100                               Lines 7
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:11
----------------------------------------------------------------------------------------------------
1      *----------------------------------------------------------------------*
2      *   INCLUDE SCHEDMAN_EVENTS                                            *
3      *----------------------------------------------------------------------*
4      constants: begin of cs_wf_events,
5                 finished type swo_event value 'FINISHED',
6                 error    type swo_event value 'REPORTERROR',
7                 end   of cs_wf_events.
*--- End of SCHEDMAN_EVENTS - 7 lines ---

----------------------------------------------------------------------------------------------------
Include          ZSAPF100_I1_NEW                           Level 1    Page 5
Object           ZJV_SAPF100                               Lines 1205
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:11
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&  Include           ZSAPF100_I1_NEW
3      *&---------------------------------------------------------------------*
4      ***INCLUDE SAPF102_I1 .
5      ***********************************************************************
6      * Date        Transport     USERID       Description
7      * 06/10/2008  <RD1K960036>  SAB_PUNIT    1) Copied from program
8      *                                           SAPF100_I1
9      ***********************************************************************
10     *&---------------------------------------------------------------------*
11     *&       FORM log_almsg                                                *
12     *&---------------------------------------------------------------------*
13     *       ........                                                      *
14     *---------------------------------------------------------------------*
15     *  -->  I_PROBCLASS                                                   *
16     *---------------------------------------------------------------------*
17     FORM LOG_almsg USING VALUE(ISORT) TYPE BAL_S_msg-ALSORT.
18
19     data:  i_probclass type BAL_S_msg-probclass,
20            l_s_msg     type bal_s_msg.
21     * entry check
22       check sy-msgno ne 0.
23       check sy-msgid ne space.
24     * define data of message for Application Log
25       l_s_msg-msgty     = sy-msgty.
26       l_s_msg-msgid     = sy-msgid.
27       l_s_msg-msgno     = sy-msgno.
28       l_s_msg-msgv1     = sy-msgv1.
29       l_s_msg-msgv2     = sy-msgv2.
30       l_s_msg-msgv3     = sy-msgv3.
31       l_s_msg-msgv4     = sy-msgv4.
32     * sort the messages by isort
33       l_s_msg-alsort    = ISORT.
34     *
35       case sy-msgty.
36        when msgty_x.
37          i_probclass = probclass_very_high.  G_E_MSG = 'X'.
38        when msgty_a.
39          i_probclass = probclass_very_high.  G_E_MSG = 'X'.
40        when msgty_e.
41          i_probclass = probclass_high.       G_E_MSG = 'X'.
42        when msgty_w.
43          i_probclass = probclass_medium.
44        when msgty_i.
45          i_probclass = probclass_low.
46        when msgty_s.
47          i_probclass = probclass_low.
48        when msgty_none.
49          i_probclass = probclass_none.
50       endcase.
51     * bis hier temporär
52       l_s_msg-probclass = i_probclass.
53     * add this message to log file
54     * we do not specify I_LOG_HANDLE since we want to add this message
55     * to the default log. If it does not exist we do not care
56     * (EXCEPTIONS log_not_found = 0).
57
58       call function 'BAL_LOG_MSG_CUMULATE'
59            exporting
60                 i_s_msg       = l_s_msg
61     *           I_LOG_HANDLE  =
62     *      importing
63     *           E_MSG_WAS_LOGGED = G_E_MSG
64            exceptions
65                 log_not_found = 0
66                 others        = 1.
67       if sy-subrc <> 0.
68         message id sy-msgid type sy-msgty number sy-msgno
69                 with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
70       endif.
71       if not sy-batch is initial.
72         move-corresponding l_s_msg to fimsg.
73         FIMSG-MSORT = ISORT.
74         CALL FUNCTION 'FI_MESSAGE_COLLECT'
75            EXPORTING
76                 I_FIMSG = FIMSG
77                 I_XAPPN = ' '
78            EXCEPTIONS
79                 OTHERS  = 01.
80       endif.
81
82     endform.
83     *&--------------------------------------------------------------------*
84     *&      FORM LOG_POSTING_ERRORS                                       *
85     *&--------------------------------------------------------------------*
86     *       ........                                                      *
87     *---------------------------------------------------------------------*
88     form log_posting_errors.
89       loop at bu_waertab_err.
90         at first.
91           message I477(FR) with par_bnam
92                            into g_dummy.
93           perform log_almsg using '12'.
94     *     message e477.
95         endat.
96
97         fimsg-msgv1 = bu_waertab_err-bukrs.
98         write bu_waertab_err-hkont to
99          fimsg-msgv2 no-zero.
100        fimsg-msgv4 = bu_waertab_err-hwaer.
101        write bu_waertab_err-dmshb
102              currency
103              bu_waertab_err-hwaer to
104         fimsg-msgv3.
105
106        message E008(FR) with fimsg-msgv1
107                              fimsg-msgv2
108                              fimsg-msgv3
109                              fimsg-msgv4
110                         into g_dummy.
111        perform log_almsg using '13'.
112
113      endloop.
114    * move error messages to log                         .
115      if post_upd ne space.
116        if cnt_belg gt 0.
117          message I600(FR) with text-245
118                                cnt_belg
119                           into g_dummy.
120          perform log_almsg using '15'.
121          if p_bwber ne space.
122            message I600(FR) with text-070
123                                  p_bwber
124                                  text-071
125                                  p_curtp1
126                             into g_dummy.
127            perform log_almsg using '16'.
128          endif.
129        else.
130          message I600(FR) with text-246 into g_dummy.
131          perform log_almsg using '16'.
132        endif.
133      endif.
134    endform.
135    *&--------------------------------------------------------------------*
136    *&      FORM DRUCK_BUCHUNG                                            *
137    *&--------------------------------------------------------------------*
138    *       ........                                                      *
139    *---------------------------------------------------------------------*
140    form druck_buchung.
141
142      data: hd_txt type slis_listheader-info.
143    * table contains document header
144      data: begin of header.
145              include structure doc_hdr_alv.
146      data:
147            end of header.
148
149    * table contains doc lines (subset of bseg)
150      data: begin of item.
151              include structure doc_line_alv.
152      data: end of item.
153
154      data: t_header  like header occurs 10 with header line,
155            t_item   like item   occurs 10 with header line.
156
157
158      data: h_flag(1).
159
160      loop at buchung.
161        at new post.
162          h_flag = '1'.
163        endat.
164
165        if h_flag = '1'.
166          move-corresponding buchung to t_header.
167          t_header-selkey = buchung-post.
168          h_flag = '0'.
169        endif.
170
171        move-corresponding buchung to t_item.
172        t_item-selkey = t_header-selkey.
173        t_item-hkont = buchung-konto.
174
175    *   t_item-dmbe2 = buchung-bdiff_rem.
176
177          clear: t_item-dmbtr, t_item-dmbe2, t_item-dmbe3.
178          clear: t_header-hwaer, t_header-hwae2, t_header-hwae3.
179        if t033-CURTP2 = '10' or t033-curtp3 = '10'.
180          t_item-dmbtr = abs( buchung-dmbe1_t033 ).
181        endif.
182        t_item-dmbe2 = abs( buchung-dmbe2_t033 ).
183        t_item-dmbe3 = abs( buchung-dmbe3_t033 ).
184        case buchung-hwtyp.
185          when '1'.
186            t_item-dmbtr = abs( buchung-dmbtr ).
187            t_header-hwaer = buchung-hwaer.
188          when '2'.
189            t_item-dmbe2 = abs( buchung-dmbtr ).
190            t_header-hwae2 = buchung-hwaer.
191          when '3'.
192            t_item-dmbe3 = abs( buchung-dmbtr ).
193            t_header-hwae3 = buchung-hwaer.
194        endcase.
195
196        append t_item.
197        fimsg = buchung-fimsg.
198        if not fimsg-msgid is initial.
199          message id fimsg-msgid type fimsg-msgty number fimsg-msgno
200             with fimsg-msgv1 fimsg-msgv2 fimsg-msgv3 fimsg-msgv4
201             into t_header-txt100.
202        endif.
203
204
205        at end of post.
206          append t_header.
207        endat.
208
209      endloop.
210    * setup header line
211      if par_bi ne space and bi_open_flag ne space.
212        if par_bnam ne space and bi_filled_flag <> space.
213          hd_txt = text-243.      "postings in batch input session ...
214        else.
215          hd_txt = text-241.               "posting genereated
216        endif.
217      else.
218        hd_txt = text-242.                 "posting proposal
219      endif.
220
221      call function 'FI_POSTINGS_ALV'
222           EXPORTING
223                i_headline  = hd_txt
224                is_variant  = h_variant
225                is_layout   = t_slis_layout_alv
226           TABLES
227                t_doc_hdr   = t_header
228                t_doc_lines = t_item
229           CHANGING
230                ie_bhdgd    = gl_bhdgd.
231
232    endform.
233    *&--------------------------------------------------------------------*
234    *&      FORM DRUCK_MELDUNG                                            *
235    *&--------------------------------------------------------------------*
236    *       ........                                                      *
237    *---------------------------------------------------------------------*
238    form druck_meldung.
239    if not sy-batch is initial.
240    * print the messages in the same spool file additionally
241       perform druck_meldung_falv.
242    * Use standard log display only if errors occur. Otherwise, use
243    * meldung_falv list, which also contains the messages
244      DATA: ld_stats type BAL_S_SCNT.
245      CALL FUNCTION 'BAL_LOG_HDR_READ'
246        EXPORTING
247          I_LOG_HANDLE                   = g_log_handle
248        IMPORTING
249          E_STATISTICS                   = ld_stats.
250
251      if ld_stats-MSG_CNT_A = 0 AND ld_stats-MSG_CNT_E = 0.
252        exit.     " <<<<<<<<<<<<   E X I T >>>>>>>>>>>>>>
253      endif.
254    endif.
255
256    data: l_display_profile type BAL_S_PROF.
257    CALL FUNCTION 'BAL_DSP_PROFILE_STANDARD_GET'
258      IMPORTING
259        E_S_DISPLAY_PROFILE       = l_display_profile.
260    l_display_profile-disvariant-report = 'SAPF100'.
261    l_display_profile-show_all = 'X'.
262
263    call function 'BAL_DSP_LOG_DISPLAY'
264         EXPORTING
265    *         I_S_LOG_FILTER         =
266    *         I_T_LOG_CONTEXT_FILTER =
267    *         I_S_MSG_FILTER         =
268    *         I_T_MSG_CONTEXT_FILTER =
269    *         I_T_LOG_HANDLE         =
270    *         I_T_MSG_HANDLE         =
271              I_S_DISPLAY_PROFILE    = l_display_profile
272    *         I_AMODAL               = ' '
273        EXCEPTIONS
274             OTHERS                 = 1.
275
276    if sy-subrc <> 0.
277     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
278             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
279    endif.
280
281    endform.
282    form druck_meldung_falv.
283
284    CALL FUNCTION 'FI_MESSAGES_ALV'
285      EXPORTING
286        I_HEADLINE       = text-044
287        IS_VARIANT       = h_variant
288        IS_LAYOUT        = t_slis_layout_alv
289      CHANGING
290        IE_BHDGD         = BHDGD.
291
292
293    endform.
294    *&--------------------------------------------------------------------*
295    *&      FORM LOG_ALMSG_init                                           *
296    *&--------------------------------------------------------------------*
297    *       ........                                                      *
298    *---------------------------------------------------------------------*
299    form LOG_ALMSG_init.
300    data: l_s_log type BAL_S_LOG.
301
302    clear l_s_log.
303    l_s_log-aldate = sy-datlo.
304    l_s_log-altime = sy-timlo.
305    l_s_log-aluser = sy-uname.
306    l_s_log-alprog = sy-repid.
307
308    call function 'BAL_LOG_CREATE'
309         exporting
310              i_s_log                 = l_s_log
311         IMPORTING
312              E_LOG_HANDLE            = g_log_handle
313         EXCEPTIONS
314             LOG_HEADER_INCONSISTENT = 1
315             OTHERS                  = 2
316              .
317    if sy-subrc <> 0.
318     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
319             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
320    endif.
321
322    endform.
323    *&---------------------------------------------------------------------*
324    *&       FORM LIST_ITEM_FILL                                           *
325    *&---------------------------------------------------------------------*
326    *       ........                                                      *
327    *---------------------------------------------------------------------*
328    form list_item_fill.
329
330      move-corresponding belege to list_item.  "#EC CI_FLDEXT_OK[2610650]
331      list_item-konto = belege-konto.
332      list_item-zbukr   = belege-zbukr.
333      list_item-bewgp = dk_konzs.
334      list_item-konto = belege-konto.
335      add 1 to selkey.
336    **list_item-selkey = selkey.
337      list_item-bwwrt = list_item-dmbtr + list_item-bwdiff.
338    * post difference between new and old valuation difference
339      list_item-bubetr = list_item-bwdiff - list_item-bdiff.
340      list_item-hwaer  = haus-waers.
341    * calculate kursf
342      call function 'CALCULATE_EXCHANGE_RATE'
343           EXPORTING
344                date             = list_item-budat
345                foreign_amount   = list_item-wrbtr
346                foreign_currency = list_item-waers
347                local_amount     = list_item-dmbtr
348                local_currency   = list_item-hwaer
349                type_of_rate     = 'M'
350           IMPORTING
351                exchange_rate    = list_item-kursf
352           EXCEPTIONS
353                others           = 7.
354
355      clear: sy-msgno, sy-msgid, sy-msgty, sy-msgv1,
356             sy-msgv2, sy-msgv3, sy-msgv4.           "note-333917
357
358      if sy-subrc <> 0.
359        clear list_item-kursf.
360      endif.
361
362    * get text for gl account
363      CLEAR list_item-txt50.
364
365      CALL FUNCTION 'SKAT_SELECT'
366         EXPORTING
367           ktopl = t001-ktopl
368           saknr = list_item-hkont
369           SPRAS = SY-LANGU
370         IMPORTING
371           I_SKAT  = skat
372         EXCEPTIONS
373           OTHERS = 4.
374      IF sy-subrc = 0.
375         list_item-txt50 = skat-txt50.
376      ENDIF.
377
378    * get alternate account number if wanted
379      if not xaltkt is initial.
380        list_item-altkt = belege-hkont.
381        call function 'READ_SACHKONTO_ALTKT'
382             EXPORTING
383                  bukrs  = belege-bukrs
384                  saknr  = belege-hkont
385                  spras  = sy-langu
386                  xmass  = 'X'
387                  xskan  = 'X'
388                  xtext  = ' '
389             IMPORTING
390                  altkt  = skb1-altkt
391             EXCEPTIONS
392                  others = 1.
393        if sy-subrc = 0.
394          list_item-altkt = skb1-altkt.
395        endif.
396      endif.
397
398    *
399      if p_remon ne space.
400        list_item-hwaer_rem = bk_methode-hwaer_rem.
401      endif.
402      append list_item.
403    endform.
404    *&--------------------------------------------------------------------*
405    *&      FORM LISTE                                                    *
406    *&--------------------------------------------------------------------*
407    *       ........                                                      *
408    *---------------------------------------------------------------------*
409    form liste.
410
411    * ALV - save variant
412      h_variant-variant    = p_lvar.
413
414      caller = 'LISTE'.
415
416      h_variant-handle = '0001'.
417      h_repid = sy-repid.
418    * h_tabname_header = 'LIST_HEAD'.
419      h_tabname_item = 'LIST_ITEM'.
420
421      describe table t_fieldcat lines sy-tfill.
422      if sy-tfill = 0.
423
424    *   determine the fieldcat
425        perform list_fill_fieldcat tables   t_fieldcat
426                                   using   h_tabname_item
427                                           h_tabname_header.
428    *   register the exit events for user_command
429        perform list_register_exit_events tables t_event_exit.
430    *   register the list events
431        perform list_register_events tables t_events.
432    *   setup the new page for each cc
433        perform list_sortinfo_make changing t_slis_sort.
434        t_slis_layout_alv-get_selinfos ='X'. "get selopts
435        t_slis_layout_alv-group_change_edit ='X'.  "variable gruppenwechse
436      endif.
437      perform list_top_build  using gt_list_top_of_page[].
438      set pf-status 'LISTE'.
439    * geht nicht, ich kann die statistik nicht abschalten
440    * t_slis_print_alv-print          = 'X'.
441    * t_slis_print_alv-no_print_selinfos = 'X'.
442    * t_slis_print_alv-no_print_listinfos = 'X'.
443    * t_slis_print_alv-no_coverpage = 'X'.
444    * check for default variant '0SAP'.
445      perform check_default_variant(saplfalv) changing h_variant
446                                              if found.
447
448    *** Display list ***
449      call function 'REUSE_ALV_LIST_DISPLAY'
450           EXPORTING
451                i_callback_program       = h_repid
452                i_callback_pf_status_set = h_set_pf_status
453                i_callback_user_command  = h_user_command
454                i_default                = 'X'
455                is_layout                = t_slis_layout_alv
456                is_print                 = t_slis_print_alv
457                it_events                = t_events[]
458                it_fieldcat              = t_fieldcat[]
459                i_save                   = 'A'
460                is_variant               = h_variant
461           TABLES
462                t_outtab                 = list_item
463           EXCEPTIONS
464                program_error            = 1
465                others                   = 2.
466    * move error messages to log
467      if sy-subrc ne 0.
468        perform log_almsg using '15'.
469      endif.
470    endform.
471    *&--------------------------------------------------------------------*
472    *&      FORM LIST_FILL_FIELDCAT                                       *
473    *&--------------------------------------------------------------------*
474    *       Feldkatalog für die gewünschte Ausgabe fuellen                *
475    *---------------------------------------------------------------------*
476    *  -->  TI_FIELDCAT                                                   *
477    *  -->  I_ITEM                                                        *
478    *  -->  I_HEAD                                                        *
479    *---------------------------------------------------------------------*
480    form list_fill_fieldcat tables ti_fieldcat structure t_fieldcat
481                           using i_item   type slis_tabname
482                                 i_head   type slis_tabname.
483    * generate fieldcat
484      perform list_merge_fieldcat tables ti_fieldcat
485                                  using i_item.
486
487
488    * perform list_merge_fieldcat tables ti_fieldcat
489    *                             using i_head.
490
491    * currency local
492      perform:
493       list_set_field tables ti_fieldcat using i_item  'DMBTR' 'LC',
494       list_set_field tables ti_fieldcat using i_item  'BDIFF' 'LC',
495       list_set_field tables ti_fieldcat using i_item  'BWDIFF' 'LC',
496       list_set_field tables ti_fieldcat using i_item  'BWWRT' 'LC',
497       list_set_field tables ti_fieldcat using i_item  'BUBETR' 'LC'.
498    * transaction curreny
499      perform:
500       list_set_field tables ti_fieldcat using i_item  'WRBTR' 'TC',
501       list_set_field tables ti_fieldcat using i_item  'GBETR' 'TC'.
502    * hide the fields not to be shown
503      perform:
504       list_set_field tables ti_fieldcat using i_item  'ZBUKR' 'H',
505       list_set_field tables ti_fieldcat using i_item  'BEWGP' 'H',
506       list_set_field tables ti_fieldcat using i_item  'SELKEY' 'H',
507    *  head daten
508       list_set_field tables ti_fieldcat using i_head  'SELKEY' 'H'.
509
510    *  set tech fields already in standard.
511      perform:
512         list_set_field tables ti_fieldcat using i_item 'RTCUR' 'T',
513         list_set_field tables ti_fieldcat using i_item 'RBUSA' 'T'.
514
515    *  set key fiels (from ddic) to non keyfielsd
516      perform:
517         list_set_field tables ti_fieldcat using i_item 'BUKRS' 'NK',
518         list_set_field tables ti_fieldcat using i_item 'GJAHR' 'NK',
519         list_set_field tables ti_fieldcat using i_item 'BELNR' 'NK',
520         list_set_field tables ti_fieldcat using i_item 'BUKRS' 'NK',
521         list_set_field tables ti_fieldcat using i_item 'BUZEI' 'NK',
522         list_set_field tables ti_fieldcat using i_item 'HWAER' 'NK',
523         list_set_field tables ti_fieldcat using i_item 'bukrs' 'NK',
524    *    key fields (would be KY)
525         list_set_field tables ti_fieldcat using i_item 'ZBUKR' 'NK',
526         list_set_field tables ti_fieldcat using i_item 'HKONT' 'NK',
527         list_set_field tables ti_fieldcat using i_item 'KONTO' 'NK',
528         list_set_field tables ti_fieldcat using i_item 'WAERS' 'NK'.
529    * set all fields to tech fields, which are not selected.
530    * but are defined in list_item the include rfsbew_inc
531
532    *  loop at fieldtab_glu1.
533    *    loop at incl_fld where low  = fieldtab_glu1-fieldname.
534    *    endloop.
535    *    if sy-subrc <> 0.
536    *      perform:
537    *        list_set_field tables ti_fieldcat using i_item
538    *           fieldtab_glu1-fieldname 'T'.
539    *    endif.
540    *  endloop.
541
542    * setup the Text elements for the field not  dictionary
543      data: dd_name like DD04D-ROLLNAME.
544      case p_curtp1.
545        when '30'. dd_name = 'GROUP_CURR'.
546        when others.    dd_name = 'DMBTR'.
547      endcase.
548
549      perform:
550         list_set_text tables ti_fieldcat using i_item 'BWWRT' text-111,
551         list_set_text tables ti_fieldcat using i_item 'KURSR' text-112,
552         list_set_text tables ti_fieldcat using i_item 'BWDIFF' text-113,
553    *bau list_set_text tables ti_fieldcat using i_item 'DMBTR' text-114,
554         list_set_text tables ti_fieldcat using i_item 'WRBTR' text-115,
555         list_set_text tables ti_fieldcat using i_item 'BEZUGSNR' text-117,
556         list_set_text tables ti_fieldcat using i_item 'HWAER' text-118,
557         list_set_text tables ti_fieldcat using i_item 'BUBETR' text-119,
558         list_set_text tables ti_fieldcat using i_item 'HWAER_REM' text-132,
559        list_set_text tables ti_fieldcat using i_item 'BDIFF_REM' text-131.
560
561    * setup F1 Help
562      perform:
563         list_set_attribute  tables ti_fieldcat  "bewerteter Betrag
564           using  i_item 'BWWRT' 'ROLLNAME' 'BWWRT',
565         list_set_attribute  tables ti_fieldcat
566           using  i_item 'WRBTR' 'ROLLNAME' 'WRBTR',   "FW Betrag
567         list_set_attribute  tables ti_fieldcat
568    *      using  i_item 'DMBTR' 'ROLLNAME' 'DMBTR',   "HW Betrag
569           using  i_item 'DMBTR' 'ROLLNAME' dd_name,
570         list_set_attribute  tables ti_fieldcat
571           using  i_item 'BUBETR' 'ROLLNAME' 'DMSHB',   "zu buchender Betrag
572         list_set_attribute  tables ti_fieldcat
573           using  i_item 'KURS' 'ROLLNAME' 'KURSR',    "kurs
574         list_set_attribute  tables ti_fieldcat
575           using  i_item 'HWAER_REM' 'ROLLNAME' 'SBEWREMCURT',
576         list_set_attribute  tables ti_fieldcat
577           using  i_item 'BDIFF_REM' 'CFIELDNAME' 'HWAER_REM',
578         list_set_attribute  tables ti_fieldcat
579           using  i_item 'BDIFF_REM' 'ROLLNAME' 'SBEWREMCURT'.
580    * set rate fields to right justified
581      perform:
582         list_set_attribute  tables ti_fieldcat
583           using  i_item 'KURSRA' 'JUST' 'R',
584         list_set_attribute  tables ti_fieldcat
585           using  i_item 'KURSF' 'JUST' 'R',
586         list_set_attribute  tables ti_fieldcat
587           using  i_item 'KURSR' 'JUST' 'R'.
588
589    endform.                               " FILL_FIELDCAT_GEN
590    *&---------------------------------------------------------------------*
591    *&       FORM LIST_MERGE_FIELDCAT                                      *
592    *&---------------------------------------------------------------------*
593    *       ........                                                      *
594    *---------------------------------------------------------------------*
595    *  -->  TI_FIELDCAT                                                   *
596    *  -->  I_TAB                                                         *
597    *---------------------------------------------------------------------*
598    form list_merge_fieldcat tables ti_fieldcat structure t_fieldcat
599                             using i_tab    type slis_tabname.
600      call function 'REUSE_ALV_FIELDCATALOG_MERGE'
601           EXPORTING
602                i_program_name         = h_repid
603                i_internal_tabname     = i_tab
604                i_inclname             = h_repid                "
605                i_client_never_display = 'X'
606                I_BYPASSING_BUFFER     = 'X'
607           CHANGING
608                ct_fieldcat            = ti_fieldcat[]
609           EXCEPTIONS
610                others                 = 3.
611    * move error messages to log
612      if sy-subrc ne 0.
613        perform log_almsg using '15'.
614      endif.
615    endform.
616    *&---------------------------------------------------------------------*
617    *&       FORM LIST_SET_FIELD                                           *
618    *&---------------------------------------------------------------------*
619    *       ........                                                      *
620    *---------------------------------------------------------------------*
621    *  -->  TI_FIELDCAT                                                   *
622    *  -->  I_TABNAME                                                     *
623    *  -->  I_FIELDNAME                                                   *
624    *  -->  ACTION                                                        *
625    *---------------------------------------------------------------------*
626    form list_set_field tables ti_fieldcat structure t_fieldcat
627                        using  i_tabname   type slis_tabname
628                               i_fieldname type slis_fieldname
629                               action.
630      read table ti_fieldcat with key tabname   = i_tabname
631                                      fieldname = i_fieldname.
632      if sy-subrc = 0.
633        if action = 'T'.                   "set tech field
634          ti_fieldcat-tech = 'X'.
635        elseif action = 'NK'.              "no key field
636          ti_fieldcat-key = space.
637        elseif action = 'KY'.              "is key field
638          ti_fieldcat-key = 'X'.
639        elseif action = 'LC'.              "set currency
640          ti_fieldcat-cfieldname = 'HWAER'.
641          ti_fieldcat-outputlen  = 16.
642        elseif action = 'TC'.              "set currency
643          ti_fieldcat-cfieldname = 'WAERS'.
644          ti_fieldcat-outputlen  = 16.
645        elseif action = 'PC'.              "set currency
646          ti_fieldcat-cfieldname = 'HWAER2'.
647          ti_fieldcat-outputlen  = 16.
648        elseif action = 'S'.               "set field to display.
649          ti_fieldcat-no_out = space.
650        elseif action = 'H'.               "set field to NOT display.
651          t_fieldcat-no_out = 'X'.
652          if t_fieldcat-key = 'X'.
653            t_fieldcat-key = ' '.
654          endif.
655        endif.
656
657        modify ti_fieldcat index sy-tabix.
658      endif.
659
660    endform.                               " SET_TECH_FIELDS
661    *&---------------------------------------------------------------------*
662    *&       FORM LIST_SET_TEXT                                            *
663    *&---------------------------------------------------------------------*
664    *       ........                                                      *
665    *---------------------------------------------------------------------*
666    *  -->  TI_FIELDCAT                                                   *
667    *  -->  I_TABNAME                                                     *
668    *  -->  I_FIELDNAME                                                   *
669    *  -->  ITEXT                                                         *
670    *---------------------------------------------------------------------*
671    form list_set_text  tables ti_fieldcat structure t_fieldcat
672                        using  i_tabname   type slis_tabname
673                               i_fieldname type slis_fieldname
674                               itext.
675      read table ti_fieldcat with key tabname   = i_tabname
676                                      fieldname = i_fieldname.
677      if sy-subrc = 0.
678        ti_fieldcat-reptext_ddic  = itext.
679        ti_fieldcat-seltext_l = itext.
680        ti_fieldcat-seltext_m = itext.
681        ti_fieldcat-seltext_s = itext.
682
683        modify ti_fieldcat index sy-tabix.
684      endif.
685
686    endform.                               " SET_TECH_FIELDS
687    *&---------------------------------------------------------------------*
688    *& FORM list_set_attribute                                             *
689    *&---------------------------------------------------------------------*
690    *       ........                                                      *
691    *---------------------------------------------------------------------*
692    *  -->  TI_FIELDCAT                                                   *
693    *  -->  I_TABNAME                                                     *
694    *  -->  I_FIELDNAME                                                   *
695    *  -->  I_TARGET                                                      *
696    *  -->  I_VALUE                                                       *
697    *---------------------------------------------------------------------*
698    form list_set_attribute  tables ti_fieldcat structure t_fieldcat
699                        using  i_tabname   type slis_tabname
700                               i_fieldname type slis_fieldname
701                               i_target
702                               i_value.
703      field-symbols: <s>.
704
705      data: name(30) value 'ti_fieldcat-&'.
706    *REPLACE '&' WITH i_target INTO name.
707      read table ti_fieldcat with key tabname   = i_tabname
708                                      fieldname = i_fieldname.
709      if sy-subrc = 0.
710    *    ASSIGN (name) TO <s>.
711        assign component i_target of structure ti_fieldcat to <s>.
712        <s> = i_value.
713        modify ti_fieldcat index sy-tabix.
714      endif.
715
716    endform.
717    .
718    *&---------------------------------------------------------------------*
719    *&       FORM REGISTER_EVENTS                                          *
720    *&---------------------------------------------------------------------*
721    *       Definiton of Top-of-page                                      *
722    *                 end of list                                         *
723    *       ........                                                      *
724    *---------------------------------------------------------------------*
725    *  -->  T_EVENT                                                       *
726    *---------------------------------------------------------------------*
727    form list_register_events tables t_event type slis_t_event.
728
729    * determine the events
730      call function 'REUSE_ALV_EVENTS_GET'
731           EXPORTING
732                i_list_type     = 1
733           IMPORTING
734                et_events       = t_event[]
735           EXCEPTIONS
736                list_type_wrong = 1
737                others          = 2.
738    * move error messages to log
739      if sy-subrc ne 0.
740        perform log_almsg using '15'.
741      endif.
742
743    * form name for end of list
744      read table t_event with key name = slis_ev_top_of_list.
745      if sy-subrc eq 0.
746        t_event-form = 'LIST_TOP_OF_LIST'. modify t_event index sy-tabix.
747      endif.
748    * set top of list form
749      read table t_event with key name = slis_ev_top_of_page.
750      if sy-subrc = 0.
751        t_event-form = 'LIST_TOP_OF_PAGE'. modify t_event index sy-tabix.
752      endif.
753
754      read table t_event with key name = slis_ev_end_of_list.
755      if sy-subrc eq 0.
756        t_event-form = 'LIST_END_OF_LIST'. modify t_event index sy-tabix.
757      endif.
758    endform.
759    *&---------------------------------------------------------------------*
760    *&       FORM REGISTER_EXIT_EVENTS                                     *
761    *&---------------------------------------------------------------------*
762    *       ........                                                      *
763    *---------------------------------------------------------------------*
764    *  -->  T_EVENT                                                       *
765    *---------------------------------------------------------------------*
766    form list_register_exit_events tables t_event type slis_t_event_exit.
767      h_set_pf_status   = 'LIST_SET_PF_STATUS'.
768      h_user_command    = 'LIST_USER_COMMAND'.
769
770
771      t_event-ucomm  = '&F03'. t_event-before = 'X'. append t_event.
772      t_event-ucomm  = '&F15'. t_event-before = 'X'. append t_event.
773      t_event-ucomm  = '&F12'. t_event-before = 'X'. append t_event.
774    endform.                               " REGISTER_EXIT_EVENTS
775    *&---------------------------------------------------------------------*
776    *&       FORM LIST_top_OF_LIST                                         *
777    *&---------------------------------------------------------------------*
778    *       ........                                                      *
779    *---------------------------------------------------------------------*
780    form list_top_of_list.                 "#EC CALLED
781    *
782      bhdgd-inifl = '0'.
783    * Setzen Werte fuer Batch-Heading-Routine
784      bhdgd-lines =    sy-linsz.
785      if bhdgd-lines gt 254. bhdgd-lines = 254. endif.
786      bhdgd-uname =    sy-uname.
787      bhdgd-repid =    sy-repid.
788      bhdgd-line1 =    sy-title.
789      bhdgd-line2 =       title.
790      bhdgd-bukrs =       space.
791      gl_bhdgd    =    bhdgd.
792    * holen der sortinfo
793      call function 'REUSE_ALV_LIST_LAYOUT_INFO_GET'
794           IMPORTING
795                et_sort = t_slis_sort
796           EXCEPTIONS
797                others  = 0.
798    endform.
799    *&---------------------------------------------------------------------*
800    *&       FORM LIST_TOP_OF_PAGE                                         *
801    *&---------------------------------------------------------------------*
802    *       ........                                                      *
803    *---------------------------------------------------------------------*
804    form list_top_of_page.                "#EC CALLED
805    * Listenüberschrift: Typ H
806      data: ls_line type slis_listheader.
807      bhdgd-bukrs = list_item-zbukr.
808    * note: if zbukrs is empty H366763 may help
809      bhdgd-werte = bhdgd-bukrs.
810      perform batch-heading(rsbtchh0).
811
812      if 0 = 1.
813    * Kopfinfo:
814    *     text of account
815        clear ls_line.
816        ls_line-typ  = 'A'.
817    * account may be altkt or hkont
818        perform list_read_ska1.
819        ls_line-info = ska1-saknr.
820        write skat-txt50 to ls_line-info+20.
821    *
822        condense ls_line-info.
823        append ls_line to gt_list_top_of_page.
824      endif.
825
826      call function 'REUSE_ALV_COMMENTARY_WRITE'
827           EXPORTING
828                it_list_commentary = gt_list_top_of_page.
829    endform.
830    *&---------------------------------------------------------------------*
831    *&       FORM LIST_READ_SKA1                                           *
832    *&---------------------------------------------------------------------*
833    *       ........                                                      *
834    *---------------------------------------------------------------------*
835    form list_read_ska1.
836      if list_item-altkt is initial.
837        ska1-saknr = list_item-hkont.
838      else.
839        ska1-saknr = list_item-altkt.
840      endif.
841      call function 'READ_SKA1'
842           EXPORTING
843                xktopl = t001-ktopl
844                xsaknr = ska1-saknr
845           IMPORTING
846                xska1  = ska1
847                xskat  = skat
848           EXCEPTIONS
849                others = 4.
850      if sy-subrc <> 0. skat-txt50 = space. endif.
851
852    endform.
853    *&---------------------------------------------------------------------*
854    *&       FORM E04_COMMENT_BUILD                                        *
855    *&---------------------------------------------------------------------*
856    *       Top-of-page Aufbau                                            *
857    *---------------------------------------------------------------------*
858    *  -->  E04_LT_TOP_OF_PAGE                                            *
859    *---------------------------------------------------------------------*
860    form list_top_build using e04_lt_top_of_page type slis_t_listheader.
861      data: ls_line type slis_listheader.
862    *
863      loop at e04_lt_top_of_page into ls_line.
864        if ls_line-typ = 'A'. delete e04_lt_top_of_page. endif.
865      endloop.
866
867    * Listenüberschrift: Typ H
868
869      refresh e04_lt_top_of_page.
870      clear ls_line.
871    *     ls_line-typ  = 'H'.
872    *     ls_line-info = sy-title.
873    *     APPEND ls_line TO e04_lt_top_of_page.
874    * Kopfinfo: Typ S
875      clear ls_line.
876    *     ls_line-typ  = 'S'.
877    *     ls_line-key  = p_curtp1.
878      ls_line-typ  = 'A'.
879      ls_line-info = text-102.
880      write stichtag to ls_line-info+50  dd/mm/yy.  condense ls_line-info.
881      append ls_line to e04_lt_top_of_page.
882    * Bewertungsmethode schreiben.
883      perform check_curtp using p_curtp1.
884      ls_line-info = text-410.
885      ls_line-info+30 = tdd07v-ddtext.
886      condense ls_line-info.
887      write : '(&)' to ls_line-info+40.
888      replace '&' with p_curtp1 into ls_line-info.
889      condense ls_line-info.
890      append ls_line to e04_lt_top_of_page.
891      ls_line-info = TEXT-074.
892      write : bwmet1 to ls_line-info+40. condense ls_line-info.
893      write : t044b-ltext to ls_line-info+15. condense ls_line-info.
894      append ls_line to e04_lt_top_of_page.
895    *     IF NOT title IS INITIAL.
896    *       CLEAR ls_line.
897
898    *       ls_line-typ  = 'A'.
899    *       ls_line-info = title.  "bereits in Batch heading
900    *       APPEND ls_line TO e04_lt_top_of_page.
901    *     ENDIF.
902    endform.
903    *&---------------------------------------------------------------------*
904    *&       FORM LIST_END_OF_LIST                                         *
905    *&---------------------------------------------------------------------*
906    *       ........                                                      *
907    *---------------------------------------------------------------------*
908    form list_end_of_list.                 "#EC CALLED
909    *
910      if not sy-spono is initial.
911        if caller = 'LISTE' and not sy-batch is initial.
912          t_slis_layout_alv-list_append = 'X'.
913          perform druck_buchung.
914          if sy-batch <> space.
915
916            message s600     with  text-080 sy-spono.
917            perform log_almsg using '01'.
918          endif.
919          t_spono-SPOOLTXT  = text-080.
920          t_spono-sPOOLID   = sy-spono. append t_spono to gt_spono.
921          t_slis_layout_alv-list_append = 'X'.
922
923          perform druck_meldung.
924          t_spono-SPOOLTXT  = text-081.
925          t_spono-sPOOLID   = sy-spono. append t_spono to gt_spono.
926          if sy-batch <> space.
927            commit work.
928            message s600     with  text-081 sy-spono.
929          endif.
930        endif.
931      endif.
932    endform.
933    *&---------------------------------------------------------------------*
934    *&       FORM LIST_USER_COMMAND                                        *
935    *&---------------------------------------------------------------------*
936    *       ........                                                      *
937    *---------------------------------------------------------------------*
938    *  -->  I_UCOMM                                                       *
939    *  -->  I_SELFIELD                                                    *
940    *---------------------------------------------------------------------*
941    form list_user_command using i_ucomm     like sy-ucomm
942                                 i_selfield type slis_selfield. "#EC CALLED
943      case i_ucomm.
944
945        when 'POST'.
946          perform druck_buchung.
947        when 'LIST'.
948          clear i_ucomm.
949          exit.
950    *     perform liste.
951
952        when 'ERRL'.
953          perform druck_meldung.
954    *         Back      Exit      Cancel
955        when '&F03' or '&F15' or '&F12'.
956          clear i_ucomm.
957        when 'ZEIL'.
958          perform user_command_zeil using i_ucomm i_selfield.
959        when '&IC1'.
960          perform user_command_zeil using i_ucomm i_selfield.
961
962        when 'OB59'.
963          call transaction 'OB59'.
964    *   WHEN 'EXP'.
965    *     PERFORM list_store using 'E'.
966
967      endcase.
968    endform.                               " USER_COMMAND
969    *&---------------------------------------------------------------------*
970    *&       FORM LIST_SET_PFSTATUS                                        *
971    *&---------------------------------------------------------------------*
972    *        called from ALV                                               *
973    *----------------------------------------------------------------------*
974    form list_set_pf_status using i_extab type slis_t_extab. "#EC CALLED
975      refresh i_extab.
976      set pf-status 'LISTE' excluding i_extab.
977    endform.                               " list_set_pf_status
978    *&---------------------------------------------------------------------*
979    *&       FORM USER_COMMAND_ZEIL                                        *
980    *&---------------------------------------------------------------------*
981    *       ........                                                      *
982    *---------------------------------------------------------------------*
983    *  -->  I_UCOMM                                                       *
984    *  -->  I_SELFIELD                                                    *
985    *---------------------------------------------------------------------*
986    form user_command_zeil
987                      using i_ucomm     like sy-ucomm
988                            i_selfield type slis_selfield. "#EC CALLED
989      data:    begin of buztab occurs 30,
990                 bukrs             like bseg-bukrs,    " Buchungskreis
991                 belnr             like bseg-belnr,    " Belegnummer
992                 gjahr             like bseg-gjahr,    " Geschaeftsjahr
993                 buzei             like bseg-buzei,    " Buchungszeile
994                flaen(1)          type c,  " X = Posten geaendert
995               end   of buztab.
996
997      data:    buztab_line        like sy-tabix,      " anzuzeigende Zeile
998               x_commit(1)         type c. " Commit ausfuehren
999    * end for dialog
1000     refresh buztab.
1001
1002   *determine the current line
1003     if i_selfield-tabname = h_tabname_item.
1004       read table list_item  index   i_selfield-tabindex.
1005       if sy-subrc = 0.
1006         buztab_line = list_item-buzei.
1007         buztab-buzei = list_item-buzei.
1008         buztab-bukrs = list_item-bukrs.
1009         buztab-gjahr = list_item-gjahr.
1010         buztab-belnr = list_item-belnr.
1011         append buztab.
1012         buztab_line   = list_item-buzei."anzuzeigende zeile
1013
1014       endif.
1015     endif.
1016
1017     if buztab_line is initial.
1018       message e315(f4).
1019     endif.
1020     call dialog 'RF_ZEILEN_ANZEIGE'
1021          EXPORTING
1022               buztab
1023               buztab_line
1024               tcode        FROM 'FB03'
1025               x_commit
1026          IMPORTING
1027               buztab
1028               x_commit.
1029     IF X_COMMIT = 'X'.
1030       COMMIT WORK.
1031     ENDIF.
1032
1033
1034   endform.
1035
1036   *&---------------------------------------------------------------------*
1037   *&      Form  F4_FOR_s_lvar
1038   *&---------------------------------------------------------------------*
1039   *       text
1040   *----------------------------------------------------------------------*
1041   *      -->P_s_lvar  text
1042   *----------------------------------------------------------------------*
1043   form f4_for_s_lvar changing  i_variant like disvariant.
1044     data: exit.
1045     data: e_variant like disvariant.
1046
1047     i_variant-handle = '0001'.           "F4 für Liste !
1048
1049     call function 'REUSE_ALV_VARIANT_F4'
1050          EXPORTING
1051               is_variant    = i_variant
1052               i_save        = 'A'
1053          IMPORTING
1054               e_exit        = exit
1055               es_variant    = e_variant
1056          EXCEPTIONS
1057               program_error = 3
1058               others        = 3.
1059     if sy-subrc = 0 and exit = space.
1060       i_variant-variant = e_variant-variant.
1061     endif.
1062
1063   endform.                               " F4_FOR_s_lvar
1064
1065   *&---------------------------------------------------------------------*
1066   *&       FORM LIST_STORE_1                                             *
1067   *&---------------------------------------------------------------------*
1068   *       ........                                                      *
1069   *---------------------------------------------------------------------*
1070   *  -->  MODE                                                          *
1071   *---------------------------------------------------------------------*
1072   form list_store_1 using mode type c.
1073     data: begin of obj_tab occurs 5,
1074             name(30),
1075             programname(10),
1076           end   of obj_tab.
1077     obj_tab-name = 'LIST_ITEM'. append obj_tab.
1078
1079     if mode = 'E'.
1080       export (obj_tab) to database indx(al) id  stor_nam.
1081     else.
1082       import (obj_tab) from database indx(al) id  stor_nam.
1083     endif.
1084
1085   endform.
1086   *&---------------------------------------------------------------------*
1087   *&       FORM RESTORE                                                  *
1088   *&---------------------------------------------------------------------*
1089   *        not used !                                                    *
1090   *----------------------------------------------------------------------*
1091   form restore.
1092     exit.
1093   *zur Zeit keine Listenspeicherung !
1094     perform list_store using 'I'.        "fetch it
1095     loop at t_fimsg.
1096       fimsg = t_fimsg.
1097   *    perform log_almsg using fimsg-msort.
1098     endloop.
1099     perform liste.
1100   endform.
1101   *&---------------------------------------------------------------------*
1102   *&       FORM LIST_STORE                                               *
1103   *&---------------------------------------------------------------------*
1104   *       ........                                                      *
1105   *---------------------------------------------------------------------*
1106   *  -->  MODE                                                          *
1107   *---------------------------------------------------------------------*
1108   form list_store using mode type c.
1109     data: list_item_c like list_item occurs 10.
1110     data: begin of obj_tab occurs 5,
1111             name(30),
1112             programname(10),
1113           end   of obj_tab.
1114     obj_tab-name = 'LIST_ITEM_C'. append obj_tab.
1115   *  obj_tab-name = 'T_FIMSG'.  append obj_tab.
1116     obj_tab-name = 'BUCHUNG'.     append obj_tab.
1117   *
1118     catch system-exceptions
1119                       import_mismatch_errors = 1.
1120       if mode = 'E'.
1121         call function 'TABLE_COMPRESS'
1122              TABLES
1123                   in     = list_item "#EC CI_FLDEXT_OK[2610650]
1124                   out    = list_item_c "#EC CI_FLDEXT_OK[2610650]
1125              EXCEPTIONS
1126                   others = 4."#EC FB_OLDED
1127         if sy-subrc = 0.
1128           export (obj_tab) to database indx(al) id  stor_nam.
1129         else.
1130         endif.
1131       else.
1132         import (obj_tab) from database indx(al) id  stor_nam.
1133         call function 'TABLE_DECOMPRESS'
1134              TABLES
1135                   in     = list_item_c "#EC CI_FLDEXT_OK[2610650]
1136                   out    = list_item "#EC CI_FLDEXT_OK[2610650]
1137              EXCEPTIONS
1138                   others = 4."#EC FB_OLDED
1139         if sy-subrc = 0.
1140         else.
1141         endif.
1142       endif.
1143     endcatch.
1144     if sy-subrc ne 0.
1145       message i600 with 'Fehler bei Import / Export'(005).
1146     endif.
1147   endform.
1148   *&---------------------------------------------------------------------*
1149   *&       FORM LIST_SORTINFO_MAKE                                       *
1150   *&---------------------------------------------------------------------*
1151   *       ........                                                      *
1152   *---------------------------------------------------------------------*
1153   *  -->  IT_SLIS_SORT                                                  *
1154   *---------------------------------------------------------------------*
1155   form list_sortinfo_make changing it_slis_sort type slis_t_sortinfo_alv.
1156     data: rs_sort type slis_sortinfo_alv,
1157           spos like rs_sort-spos.
1158
1159     clear it_slis_sort.
1160     add 1 to spos. rs_sort-spos = spos.
1161     rs_sort-fieldname = 'ZBUKR'.
1162     rs_sort-up        = 'X'.
1163   *  rs_sort-subtot    = 'X'.
1164     rs_sort-group     = '* '.            "<<<new page
1165   *  rs_sort-group     = 'UL'.
1166     append rs_sort to it_slis_sort.
1167
1168   endform.                               " ALV_SORTINFO_MAKE
1169   *&---------------------------------------------------------------------*
1170   *&      Form  LIST_CONFIG_LIST
1171   *&---------------------------------------------------------------------*
1172   *       configure list
1173   *----------------------------------------------------------------------*
1174   *  -->  p1        text
1175   *  <--  p2        text
1176   *----------------------------------------------------------------------*
1177   FORM list_config_list USING  irepid  like sy-repid
1178                                iform_name type c.
1179     describe table list_item lines sy-tfill.
1180     if sy-tfill = 0.
1181       get parameter id 'BUK' field t001-bukrs.
1182       select single * from t001 where bukrs = t001-bukrs.
1183       if sy-subrc <> 0.
1184         select * from t001 where bukrs in bukrs.
1185           exit.  "#EC CI_NOORDER
1186         endselect.
1187         if sy-subrc <> 0.
1188           select single * from t001 where bukrs = '0000'.
1189         endif.
1190       endif.
1191         move-corresponding t001 to list_item.
1192        append list_item.
1193        append list_item.
1194     endif.
1195
1196      CALL FUNCTION 'FI_LIST_VARIANTS_PREVIEW_ALV'
1197           EXPORTING
1198                I_REPID     = irepid
1199                I_LIST_FORM = iform_name
1200           tables
1201                T_OUTTAB    = list_item.  "#EC CI_FLDEXT_OK[2610650]
1202   *            IS_VARIANT  =
1203      refresh list_item.
1204
1205   ENDFORM.                    " list_config_list
*--- End of ZSAPF100_I1_NEW - 1205 lines ---

----------------------------------------------------------------------------------------------------
Include          ZSAPF100_SBEW_NEW                         Level 1    Page 6
Object           ZJV_SAPF100                               Lines 440
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:11
----------------------------------------------------------------------------------------------------
1      ***INCLUDE SAPF100_SBEW .
2      ***********************************************************************
3      * Date        Transport     USERID       Description
4      * 06/10/2008  <RD1K960036>  SAB_PUNIT    1) Copied from program
5      *                                           SAPF100_SBEW
6      ***********************************************************************
7      *&---------------------------------------------------------------------*
8      *&      Form  S_BUILD_NOACC
9      *&---------------------------------------------------------------------*
10     *       text
11     *----------------------------------------------------------------------*
12     *  -->  p1        text
13     *  <--  p2        text
14     *----------------------------------------------------------------------*
15     form s_build_noacc.                    "copy from rfsbew00
16       ranges: s_no_acc for skb1-saknr.
17     * Nimmt die Korrekturkonten von der FW BEwertung
18     *  TABLES: T030U.
19     * describe table s_no_acc lines sy-tfill. check sy-tfill = 0.
20       describe table skonto   lines sy-tfill. check sy-tfill = 0.
21       describe table s_kdfsl  lines sy-tfill. check sy-tfill = 0.
22       select * from t001 where bukrs in bukrs.
23         select lkorr into s_no_acc-low
24                         from t030h
25                         where ktopl = t001-ktopl.  "#EC CI_NOORDER
26           collect s_no_acc.
27         endselect.
28       endselect.
29       select t030u~korrk into s_no_acc-low
30                       from t030u inner join t001
31                          on t030u~ktopl = t001~ktopl
32                       where t001~bukrs in bukrs
33                           and    ktosl = 'WRY'.    "Matledger
34         collect s_no_acc.
35       endselect.
36     * select option vollstaendig.
37       s_no_acc = space.
38       loop at s_no_acc.
39         if s_no_acc-low = space.
40           delete s_no_acc.
41         else.
42           s_no_acc-option = 'EQ'. s_no_acc-sign = 'I'.
43           modify s_no_acc.
44         endif.
45       endloop.
46       sort s_no_acc.
47
48     endform.                               " S_BUILD_NOACC
49     *&---------------------------------------------------------------------*
50     *&      Form  SDF_sbew00                                               *
51     *&---------------------------------------------------------------------*
52     *       text
53     *----------------------------------------------------------------------*
54     form SDF_sbew00.
55       data: it001 like t001 occurs 0.
56       clear belege.
57       select * from t001 into table it001 where bukrs in bukrs.
58     * seltab fuellen -----------
59
60       loop at skonto.
61         move-corresponding skonto to seltab.
62         seltab-selname = 'SD_SAKNR'. seltab-kind = 'S'.
63         append seltab.
64       endloop.
65
66     *   fill curtp
67       bk_methode-curt2 = x001-curt2.
68       bk_methode-curt3 = x001-curt3.
69       seltab-selname = 'XX_CURTP'. seltab-kind = 'S'.
70       delete seltab where selname = seltab-selname.
71       seltab-option = 'EQ'.
72       seltab-sign   = 'I'.
73       seltab-low = p_curtp1.    "lesen der entsprechenden Hauswährung
74       append seltab.
75       perform SDF_gt_callback_fill.
76     *   fuer alle Buchungskreise*
77       loop at it001 into t001.
78         seltab-selname = 'SD_BUKRS'. seltab-kind = 'S'.
79         delete seltab where selname = seltab-selname.
80         seltab-low = t001-bukrs.
81         seltab-option = 'EQ'.
82         seltab-sign   = 'I'.
83         append seltab.
84     *
85         seltab-selname = 'SD_GJAHR'. seltab-kind = 'S'.
86         delete seltab where selname = seltab-selname.
87     *   get year and assign values
88         perform build_bk_methode using t001-bukrs.
89         perform fwsaldo_assign changing seltab-low
90                                        sbew_special_periods.
91         seltab-option = 'EQ'.
92         seltab-sign   = 'I'.
93         append seltab.
94
95         call function 'LDB_PROCESS'
96            exporting
97                 ldbname                     = 'SDF'
98     *          VARIANT                     =
99                EXPRESSIONS                 =  sdf_expressions
100    *          FIELD_SELECTION             =
101    *          DYN_NODE_TYPES              =
102           tables
103                callback                    = gt_callback
104               SELECTIONS                  =  seltab
105           exceptions
106               ldb_not_reentrant           = 1
107               ldb_incorrect               = 2
108               ldb_already_running         = 3
109               ldb_error                   = 4
110               ldb_selections_error        = 5
111               ldb_selections_not_accepted = 6
112               variant_not_existent        = 7
113               variant_obsolete            = 8
114               variant_error               = 9
115               free_selections_error       = 10
116               callback_no_event           = 11
117               callback_node_duplicate     = 12
118               callback_no_program         = 13
119               callback_no_cbform          = 14
120               dyn_node_no_type            = 15
121               dyn_node_invalid_type       = 16
122               others                      = 17.
123
124        if sy-subrc <> 0.
125          MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
126                  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
127        endif.
128      endloop.
129    endform.
130    *&---------------------------------------------------------------------*
131    *&      Form SDF_gt_callback_fill
132    *&---------------------------------------------------------------------*
133    *       fill table for callback routines for 'LDB_PROCESS'
134    *----------------------------------------------------------------------*
135    *  -->  p1        text
136    *  <--  p2        text
137    *----------------------------------------------------------------------*
138    form SDF_gt_callback_fill.
139      gt_callback-ldbnode  = 'SKA1'.
140      gt_callback-get      = 'X'.
141      gt_callback-cb_prog  = 'SAPF100'.
142      gt_callback-cb_form  = 'CB_GET_SKA1'.
143      append gt_callback.
144    *
145      gt_callback-ldbnode  = 'SKB1'.
146      gt_callback-get      = 'X'.
147      gt_callback-cb_prog  = 'SAPF100'.
148      gt_callback-cb_form  = 'CB_GET_SKB1'.
149      append gt_callback.
150    *
151      gt_callback-ldbnode  = 'SKC1C'.
152      gt_callback-get      = 'X'.
153      gt_callback-cb_prog  = 'SAPF100'.
154      gt_callback-cb_form  = 'CB_GET_SKC1C'.
155      append gt_callback.
156    endform.                               " GT_CALLBACK_FILL
157    *&---------------------------------------------------------------------*
158    *&      Form  CB_GET_SKA1
159    *&---------------------------------------------------------------------*
160    *       text
161    *----------------------------------------------------------------------*
162    *  -->  p1        text
163    *  <--  p2        text
164    *----------------------------------------------------------------------*
165    form cb_get_ska1 using name like ldbn-ldbnode  " Name des Knotens
166                           workarea        " Daten
167                           mode     type c " G(et) oder L(ate)
168                           selected type c.                     "#EC CALLED
169
170      check mode = 'G'.
171      ska1 = workarea.
172      perform do_ska1 changing selected.
173    endform.
174    *&---------------------------------------------------------------------*
175    *&      Form DO_SKA1
176    *&---------------------------------------------------------------------*
177    *       get ska1
178    *----------------------------------------------------------------------*
179    *  -->  p1        text
180    *  <--  p2        text
181    *----------------------------------------------------------------------*
182    form do_ska1 changing selected type c.
183      clear selected.
184    * Verarbeitung nach get-Ereignis get ska1
185      if p_plcacc is initial.
186        check ska1-xbilk = 'X'.
187      endif.
188    * if s_no_acc-low ne space.
189    *   check: not ( ska1-saknr in s_no_acc ).
190    * endif.
191      selected = 'X'.
192    endform.                               " CB_GET_SKA1
193    *&---------------------------------------------------------------------*
194    *&      Form  CB_GET_SKB1
195    *&---------------------------------------------------------------------*
196    *       get skb1
197    *----------------------------------------------------------------------*
198    *  -->  p1        text
199    *  <--  p2        text
200    *----------------------------------------------------------------------*
201    form cb_get_skb1 using name like ldbn-ldbnode  " Name des Knotens
202                           workarea        " Daten
203                           mode     type c " G(et) oder L(ate)
204                           selected type c.                     "#EC CALLED
205      check mode = 'G'.
206      skb1 = workarea.
207      perform do_skb1 changing selected.
208    endform.
209    *&---------------------------------------------------------------------*
210    *&      Form  DO_SKB1
211    *&---------------------------------------------------------------------*
212    *       get skb1
213    *----------------------------------------------------------------------*
214    *  -->  p1        text
215    *  <--  p2        text
216    *----------------------------------------------------------------------*
217    form do_skb1 changing selected type c.
218    *
219      clear selected.
220      check:                               "BUCHUNGSKREIS
221             s_kdfsl.                      "Kursdifferenzenschluessel
222      check: skb1-xopvw ne 'X',
223             skb1-mitkz <> 'D',    "Translation also done with SAPF100
224             skb1-mitkz <> 'K'.    "Translation also done with SAPF100
225
226    * rec accounts from AM are allowed for translation
227      if p_transl is initial.
228        check:  skb1-mitkz = space.
229      endif.
230
231      selected = 'X'.
232
233      dk_konzs = space.
234      if t044a-gl_grup ne space.
235        perform get_dkonzs_GL changing dk_konzs.
236      endif.
237
238
239    endform.                               " CB_GET_SKB1
240    *&---------------------------------------------------------------------*
241    *&      Form  CB_GET_SKC1C
242    *&---------------------------------------------------------------------*
243    *       text
244    *----------------------------------------------------------------------*
245    *  -->  p1        text
246    *  <--  p2        text
247    *----------------------------------------------------------------------*
248    form cb_get_skc1c using name like ldbn-ldbnode  " Name des Knotens
249                            workarea       " Daten
250                            mode     type c" G(et) oder L(ate)
251                            selected type c.                    "#EC called
252      check mode = 'G'.
253      skc1c = workarea.  "#EC CI_FLDEXT_OK[2610650]
254      perform do_skc1c changing selected.
255    endform.
256    *&---------------------------------------------------------------------*
257    *&      Form  DO_SKC1C
258    *&---------------------------------------------------------------------*
259    *       read skc1c
260    *----------------------------------------------------------------------*
261    *  -->  p1        text
262    *  <--  p2        text
263    *----------------------------------------------------------------------*
264    form do_skc1c changing selected.                            "#EC CALLED
265    *
266      clear selected.
267      check: skc1c-gsber in s_gsber,
268             skc1c-fwaer in waehrung.
269    * is it in foreign currency
270      if p_transl = space.  "to allow TA curr = parallel CURR  02.12.99
271        check_currency skc1c-fwaer.
272      endif.
273      selected = 'X'.
274      if sbew_special_periods <> space.
275        <fwsaldo> = skc1c-wm12o + skc1c-wm13o + skc1c-wm14o
276                     + skc1c-wm15o + skc1c-wm16o.
277        <hwsaldo> = skc1c-um12o + skc1c-um13o + skc1c-um14o
278                     + skc1c-um15o + skc1c-um16o.
279      endif.
280      belege-wrbtr = <fwsaldo>.
281      belege-dmbtr = belege-dmbe2 = belege-dmbe3 = 0.
282      case p_curtp1.
283        when '10'.                         "first currency
284          belege-dmbtr = <hwsaldo>.
285        when bk_methode-curt2.
286          belege-dmbe2 = <hwsaldo>.
287          if bk_methode-curs2 = '2' or p_transl <> space.
288    * get first currency somehow.    belege-wrbtr = <fwsaldo>.
289            CALL FUNCTION 'READ_SKC1C'
290                 EXPORTING
291                      XBUKRS         = skc1c-bukrs
292                      XGJAHR         = SKC1C-GJAHR
293                      XGSBER         = skc1c-gsber
294                      XRTCUR         = skc1c-fwaer
295                      XSAKNR         = skc1c-saknr
296                 IMPORTING
297                      XSKC1C         = *SKC1C
298                 EXCEPTIONS
299                      KEY_INCOMPLETE = 1
300                      NOT_AUTHORIZED = 2
301                      NOT_FOUND      = 3
302                      OTHERS         = 4.
303            check sy-subrc = 0.
304            if sbew_special_periods <> space.
305              <hwsaldo1> = *skc1c-um12o + *skc1c-um13o + *skc1c-um14o
306                      + *skc1c-um15o + *skc1c-um16o.
307            endif.
308
309            belege-dmbtr = <hwsaldo1>.
310          endif.
311        when bk_methode-curt3.
312          belege-dmbe3 = <hwsaldo>.
313          if bk_methode-curs3 = '2' or p_transl <> space.
314            CALL FUNCTION 'READ_SKC1C'
315                 EXPORTING
316                      XBUKRS         = skc1c-bukrs
317                      XGJAHR         = SKC1C-GJAHR
318                      XGSBER         = skc1c-gsber
319                      XRTCUR         = skc1c-fwaer
320                      XSAKNR         = skc1c-saknr
321                 IMPORTING
322                      XSKC1C         = *SKC1C
323                 EXCEPTIONS
324                      KEY_INCOMPLETE = 1
325                      NOT_AUTHORIZED = 2
326                      NOT_FOUND      = 3
327                      OTHERS         = 4.
328            check sy-subrc = 0.
329            if sbew_special_periods <> space.
330              <hwsaldo> = *skc1c-um12o + *skc1c-um13o + *skc1c-um14o
331                      + *skc1c-um15o + *skc1c-um16o.
332            endif.
333            belege-dmbtr = <hwsaldo1>.
334          endif.
335        when others.
336          message e600 with 'wrong currency type detected'
337                            skb1-bukrs.
338
339      endcase.
340
341    *
342      belege-shkzg = 'S'.
343      if belege-wrbtr < 0.
344        belege-wrbtr =  0 - belege-wrbtr.
345        belege-dmbtr =  0 - belege-dmbtr.
346        belege-dmbe2 =  0 - belege-dmbe2.
347        belege-dmbe3 =  0 - belege-dmbe3.
348        belege-shkzg = 'H'.
349      endif.
350
351      belege-koart = 'S'.
352      belege-bukrs = skc1c-bukrs.
353      belege-waers   = skc1c-fwaer.
354      belege-konto = skb1-saknr.
355      belege-hkont = skb1-saknr.
356      belege-gsber = skc1c-gsber.
357      belege-gjahr = skc1c-gjahr.
358      belege-koart = 'S'.
359    *
360      perform extract.
361    endform.                               " CB_GET_SKC1C
362    *&---------------------------------------------------------------------*
363    *&      Form  FWSALDO_ASSIGN
364    *&---------------------------------------------------------------------*
365    *       assign sums in foreign currency
366    *----------------------------------------------------------------------*
367    *  -->  p1        text
368    *  <--  p2        text
369    *----------------------------------------------------------------------*
370    form fwsaldo_assign changing eyear
371                                 e_special_periods.
372      data: jahr like bkpf-gjahr.          "Jahr aus Bilanzstichtg
373      data: monat like bkpf-monat.         "Monat aus Bilanzsticht
374      data: last_month like monat.         "t aus Bilanzsticht
375      data: fw(20).
376      data: hw(20).
377    *  Pruefung: abweichendes Geschaeftsjahr
378      call function 'GET_CURRENT_YEAR'
379           EXPORTING
380                bukrs = t001-bukrs
381                date  = stichtag
382           IMPORTING
383                currm = monat
384                curry = jahr.
385      eyear = jahr.
386      e_special_periods = space.
387    * Sonderperioden bestimmen
388      select single * from t009 where periv = t001-periv.
389      last_month = t009-anzbp.
390    * Rumpfgeschäfstjahr
391      data: l_anzbp like T090L-AFPER.
392      CALL FUNCTION 'GET_ACCOUNT_OF_PERIODS'
393           EXPORTING
394                I_GJAHR    = jahr
395                I_PERIV    = T001-PERIV
396           IMPORTING
397                E_ANZBUPER = l_anzbp
398           EXCEPTIONS
399                OTHERS     = 4.
400      IF SY-SUBRC = 0.
401        last_month = l_anzbp.
402      ENDIF.
403
404    * do not use special periods if p_period is ON
405      if monat ge last_month.
406        last_month = '16'.
407        if p_period = 'X'.
408          e_special_periods = 'X'.
409        endif.
410      else.
411        last_month = monat.
412      endif.
413
414    * case monat.
415      if p_period <> space.
416        fw        = 'skc1c-wm01o'.
417        hw        = 'skc1c-um01o'.
418        replace '01' with last_month into fw.
419        replace '01' with last_month into hw.
420      else.
421        fw        = 'skc1c-wm01k'.
422        hw        = 'skc1c-um01k'.
423        replace '01' with last_month into fw.
424        replace '01' with last_month into hw.
425      endif.
426      assign (fw) to <fwsaldo>.
427      assign (hw) to <hwsaldo>.
428      case p_curtp1.
429        when bk_methode-curt2.
430          if bk_methode-curs2 = '2'.
431            concatenate '*' hw into fw.
432            assign (fw) to <hwsaldo1>.
433          endif.
434        when bk_methode-curt3.
435          if bk_methode-curs3 = '2'.
436            concatenate '*' hw into fw.
437            assign (fw) to <hwsaldo1>.
438          endif.
439      endcase.
440    endform.
*--- End of ZSAPF100_SBEW_NEW - 440 lines ---

----------------------------------------------------------------------------------------------------
Include          ZSAPF100_POSTINGS_NEW                     Level 1    Page 7
Object           ZJV_SAPF100                               Lines 1108
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:11
----------------------------------------------------------------------------------------------------
1      ***INCLUDE SAPF100_POSTINGS .
2      *&---------------------------------------------------------------------*
3      *&       FORM  posting_open_items                                      *
4      *&---------------------------------------------------------------------*
5      *       Buchen Fremdwaehrung                                          *
6      *---------------------------------------------------------------------*
7      form posting_open_items using mode
8                              changing ok_flag like ok.
9        data: bsch1 like t030b-bschs.
10       data: bsch2 like t030b-bschs.
11       data: bschx like t030b-bschs.
12
13       perFORM account_determination USING  t001-bukrs
14                             bu_waertab-ta_waers
15                             bu_waertab-hkont
16                             p_bwber
17                             bu_waertab-curtp
18                             bu_waertab-x_no_op.
19       ok_flag = ok.
20
21     * post it always in batch input
22     * CHECK ok_flag = 1.
23       move-corresponding bu_waertab to buchung.  "#EC CI_FLDEXT_OK[2610650]
24       clear: buchung-belnr, buchung-buzei.
25       if p_zbukrs ne space.
26         buchung-bukrs = p_zbukrs.
27       endif.
28       buchung-waers = bu_waertab-ta_waers.
29       buchung-hkont = bu_waertab-hkont. "damit klar ist woher die B. kommt
30       buchung-budat = p_bbudat.
31       buchung-monat = p_bbupem.
32     * buchung-hwaer = haus-waers.  ""H321879 already in bu_waertab
33       buchung-dmbtr = bu_waertab-dmshb.
34
35     * Korr. Forderung an KDF - Erloes oder Aufwandskonto ?
36     * if buchung-dmbtr  < 0.               "loss
37       if bu_waertab-aflag = 'X'.                                "H354635
38         buchung-konto = t030h-lsbew.
39         bsch1 =   t030b-bschs.
40         bsch2  =  t030b-bschh.
41         if buchung-dmbtr > 0.
42           bsch1 =   t030b-bschH.
43           bsch2  =  t030b-bschS.
44         endif.
45       else.
46         buchung-konto = t030h-lhbew.
47         bsch1 =   t030b-bschh.
48         bsch2  =  t030b-bschs.
49         if buchung-dmbtr < 0.
50           bsch2 =   t030b-bschh.
51           bsch1  =  t030b-bschs.
52         endif.
53       endif.
54
55     * for reset use opposite accounts
56       if t044a-xreset ne space.
57         if bu_waertab-aflag = ' '.                              "H354635
58     *   if buchung-dmbtr  > 0.
59           buchung-konto = t030h-lsbew.
60         else.
61           buchung-konto = t030h-lhbew.
62         endif.
63       endif.
64
65     * bilanzkorrektur an Erloese
66
67       buchung-bktxt =  text-019.
68     *
69       if t044a-xpost ne space.
70         buchung-sgtxt =  text-010.
71       else.
72         buchung-sgtxt =  text-008.
73       endif.
74       perform posting_sgtxt using buchung-sgtxt.
75     * haben
76       if mode = 'C'.
77         buchung-bschl = t030b-bschs.
78         bschx = bsch1.                     "change posting keys
79         bsch1 = bsch2.
80         bsch2 = bschx.
81         buchung-budat = st_budat.
82         buchung-monat = p_sbupem.
83         buchung-bktxt =  text-020.
84       endif.
85     *+++++
86     * Line 1
87
88       buchung-bschl = bsch1.
89       perform posting_linex using
90                            buchung-bschl
91                            buchung-konto
92                            changing post_line.
93
94     * line 2
95       buchung-bschl = bsch2.
96       buchung-konto  =  t030h-lkorr.
97       perform posting_linex using
98                            buchung-bschl
99                            buchung-konto
100                           changing post_line.
101
102      perform posting_document using 'POST'.
103      ok_flag = ok.
104
105    endform.
106    *&--------------------------------------------------------------------*
107    *&      FORM POSTING_CLEARED_ITEMS                                    *
108    *&--------------------------------------------------------------------*
109    *       ........                                                      *
110    *---------------------------------------------------------------------*
111    form posting_cleared_items.
112      data: bsch_s like t030b-bschs, bsch_h like bsch_s,
113            bsch_x like bsch_h.
114      move-corresponding bu_waertab_clear to buchung.  "#EC CI_FLDEXT_OK[2610650]
115      clear: buchung-belnr, buchung-buzei.
116      move-corresponding bu_waertab_clear to bu_waertab.
117
118      buchung-dmbtr = bu_waertab_clear-dmshb.
119      check buchung-dmbtr ne 0.
120
121      PERFORM account_determination_RXD USING t001-bukrs
122                               bu_waertab_clear-ta_waers
123                               bu_waertab_clear-hkont
124    *immer space               p_bwber
125                               bu_waertab_clear-curtp.
126
127
128      buchung-waers = bu_waertab_clear-ta_waers.
129      buchung-bukrs = bu_waertab_clear-bukrs.  "where it was
130      buchung-hkont = bu_waertab-hkont. "damit klar ist woher die B. kommt
131    * buchung-hwaer = haus-waers.         "H321879
132
133      bsch_S = t030b-bschs. bsch_h = t030b-bschh.
134
135    * abhaengig vom realisierten Kursdiff Konto waehlen !
136      case bu_waertab_clear-storno.
137
138        when 'R'.                          "Ruecknahme realiserte Differenz
139          buchung-sgtxt = text-209.
140          if buchung-dmbtr < 0.
141            buchung-konto = t030h-lsrea.
142            bsch_x = bsch_h. bsch_h = bsch_s. bsch_s = bsch_x.
143          else.
144            buchung-konto = t030h-lhrea.
145          endif.
146        when 'N'.                      "Buchen neue realisierte Differenz
147          bsch_x = bsch_h. bsch_h = bsch_s. bsch_s = bsch_x.
148          buchung-sgtxt = text-210.
149          if buchung-dmbtr > 0.
150            buchung-konto = t030h-lsrea.
151            bsch_x = bsch_h. bsch_h = bsch_s. bsch_s = bsch_x.
152          else.
153
154            buchung-konto = t030h-lhrea.
155          endif.
156      endcase.
157    * post in the clearing month
158    * BUCHUNG-BUDAT =     st_BUDAT.
159      buchung-budat =     bu_waertab_clear-augdt.
160    * BUCHUNG-MONAT =     P_SBUPEM.
161      buchung-bktxt =    text-020.
162    * PERFORM POSTING_SGTXT USING BUCHUNG-SGTXT.
163      replace '&AUGBL' with bu_waertab_clear-augbl into buchung-sgtxt.
164      buchung-bschl =    bsch_s.
165
166    * buchung-konto =    see above
167      perform posting_linex using
168                           buchung-bschl
169                           buchung-konto
170                           changing post_line.
171    *
172      buchung-bschl =    bsch_h.
173      buchung-konto =    t030h-lkorr.
174
175      perform posting_linex using
176                           buchung-bschl
177                           buchung-konto
178                           changing post_line.
179
180      perform posting_document using 'POST'.
181    * store in f100 bel because of FBRA
182    * save the documents which are linked to this posted document
183      if ok = 1 and t044a-xreset = space.
184        f100_bel-bukrs = buchung-bukrs.
185        f100_bel-augbl = bu_waertab_clear-augbl.
186        f100_bel-augdt = bu_waertab_clear-augdt.
187    *
188        if buchung-belnr co ' 0123456789'.
189          unpack buchung-belnr to buchung-belnr.
190        endif.
191        f100_bel-belnr = buchung-belnr.
192        f100_bel-budat = buchung-budat.
193        append f100_bel.
194      endif.
195    endform.
196    *&---------------------------------------------------------------------*
197    *&       FORM posting_sgtxt                                            *
198    *&---------------------------------------------------------------------*
199    *       ........                                                      *
200    *---------------------------------------------------------------------*
201    form posting_sgtxt using itext like buchung-sgtxt.
202      data: string(10).
203    * REPLACE '&BUKRS' WITH bu_waertab-bukrs INTO itext.
204    * REPLACE '&WAERS' WITH bu_waertab-ta_waers INTO itext.
205    * REPLACE '&WAERS' WITH bu_waertab-ta_waers INTO itext.
206      write:  bu_waertab-hkont to string no-zero.
207      replace '&HKONT' with string        into itext.
208      replace '&STCHG' with stichtag      into itext.
209      replace '&BUKRS' with bu_waertab-bukrs into itext.
210      replace '&BELNR' with bu_waertab-belnr into itext.
211      write bu_waertab-buzei to string no-zero.
212      replace '&BUZEI' with string    into itext.
213      condense itext.
214    endform.
215    *&---------------------------------------------------------------------*
216    *&       FORM FILE_APPEND                                              *
217    *&---------------------------------------------------------------------*
218    *       store specific data on sequential file
219    *----------------------------------------------------------------------*
220    form file_append.
221      data: log_ex like f100file.
222
223      move-corresponding belege to log_ex.
224      log_ex-hwtyp  = haus-field.
225      log_ex-oldbdiff =  belege-bdiff.     "old difference
226      log_ex-newbdiff  =  belege-bwdiff.   "new difference
227      transfer log_ex to filename.  "#EC CI_FLDEXT_OK[2610650]
228    * transfer the remeasured group currency differenc
229      if p_remon ne space and belege-bwdiff <> 0
230          and bk_methode-hwaer_rem ne space.
231        log_ex-hwtyp  = bk_methode-typ_rem.
232        log_ex-oldbdiff =  0.  "old difference is always 0
233        log_ex-newbdiff  =  belege-bdiff_rem.   "new difference
234        transfer log_ex to filename.  "#EC CI_FLDEXT_OK[2610650]
235     endif.
236    endform.
237
238    *&---------------------------------------------------------------------*
239    *&       FORM POSTING                                                  *
240    *&---------------------------------------------------------------------*
241    *       ........                                                      *
242    *---------------------------------------------------------------------*
243    * Generate Postings from table bu_waertab.
244    form posting.
245    * bestimmen der Buchungsschluessel fuer FW Bewertung
246      select single * from t030b where ktosl = 'KDF'.
247      if sy-subrc ne 0.
248    * wenn nicht definiert ist.
249        t030b-bschs = '40'.
250        t030b-bschh = '50'.
251      endif.
252
253    * perform posting_reduce_flex_fields tables bu_waertab
254    *                                            fieldtab_glu1.
255
256    *
257      perform posting_check_max.
258      if post_upd = space.
259        perform posting_loop_bu_waertab using 'P'.
260    * reverse all when no update
261        perform posting_loop_bu_waertab using 'C'.
262      else.
263    *   update
264        perform posting_loop_bu_waertab using 'P'.
265        perform posting_loop_bu_waertab using 'C'.
266        if p_bwber = space.
267          if grir_flag = space.
268            perform bseg_update.
269          endif.
270        else.
271          perform bsbw_update using p_curtp1
272                                    p_bwber '  '.
273        endif.
274        if p_remon ne space.
275    *     update for remeasurement
276          perform bsbw_update using curtp_rem
277                                    p_bwber2
278                                    'REM'.
279        endif.
280        refresh belege_upd.
281        anzup = 0.
282        perform posting_loop_bu_waertab_clear.
283      endif.
284      refresh bu_waertab.                  "immer loeschen
285
286      if post_upd <> space.
287        perform bsbw_update_db.
288        refresh: t_bsbw_new.
289      endif.
290
291      commit work.
292    endform.
293
294    *---------------------------------------------------------------------*
295    *       FORM posting_check_max                                        *
296    *---------------------------------------------------------------------*
297    *       ........                                                      *
298    *---------------------------------------------------------------------*
299    form posting_check_max.
300      data: bu_waertab_2 like bu_waertab occurs 0 with header line.
301    * splitting of overflow-values
302      data: dmshb_abs   like bu_waertab-dmshb,
303            dmshb_max   like bu_waertab-dmshb,
304            dmshb_rest  like bu_waertab-dmshb,
305            dmshb_sgn(2)   type c,
306            dmshb_times type i.
307      Data: bdiff_rem_rest like bu_waertab-bdiff_rem.
308
309    * initialization
310      dmshb_max = 9999999999999.           " maximum value for posting
311      clear bu_waertab_2.
312    * split up the overflow-values if necessary
313      loop at bu_waertab.
314        dmshb_abs = abs( bu_waertab-dmshb ).
315        dmshb_sgn = sign( bu_waertab-dmshb ).
316        if dmshb_abs > dmshb_max.
317          dmshb_times = dmshb_abs div dmshb_max.        " how many loops ?
318          dmshb_rest  = dmshb_abs mod dmshb_max.        " rest of division
319          bdiff_rem_rest = bu_waertab-bdiff_rem.
320          move-corresponding bu_waertab to bu_waertab_2.
321          bu_waertab_2-bdiff_rem = 0.
322          delete bu_waertab.               "replace entry of bu_waertab
323          do dmshb_times times.
324            bu_waertab_2-dmshb = dmshb_sgn * dmshb_max.
325            append bu_waertab_2 to bu_waertab.
326          enddo.
327          bu_waertab_2-dmshb = dmshb_sgn * dmshb_rest.
328          bu_waertab_2-bdiff_rem = bdiff_rem_rest.
329          append bu_waertab_2 to bu_waertab..
330        endif.
331      endloop.
332    endform.
333    *&--------------------------------------------------------------------*
334    *&      FORM POSTING_LOOP_BU_WAERTAB                                  *
335    *&--------------------------------------------------------------------*
336    *       ........                                                      *
337    *---------------------------------------------------------------------*
338    *  -->  MODE                                                          *
339    *---------------------------------------------------------------------*
340    form posting_loop_bu_waertab using mode type c.
341      data: error_flag.
342
343    * bu_waertab = space.
344      loop at bu_waertab.
345
346    * check if reversal is to be created for open item/acc.balance:
347    * 1. Open items:
348    *    - post_upd = 'X' and p_bwber =  '  '   -> no reversal
349    *    - post_upd = 'X' and p_bwber <> '  '   -> create reversal
350    *    - post_upd = ' '                       -> create reversal
351    * 2. Account Balances:
352    *    - p_storno = 'X'                       -> create reversal
353    *    - p_storno = ' '                       -> no reversal
354        IF mode = 'C'.                         "Reversal posting:
355          IF bu_waertab-x_no_op = SPACE.       "for open item in case
356            CHECK post_upd =  SPACE OR         "  when BDIFF or val.area
357                  p_bwber  <> SPACE.
358          ELSE.                                "for acc.balances in case
359            CHECK p_storno <> SPACE.           "  when flag is signed
360          ENDIF.
361        endif.
362
363        clear post_now.
364    * Sammelbuchungskreis bestimmen
365        if p_zbukrs ne space.
366          belege-bukrs = p_zbukrs.
367        else.
368          belege-bukrs = bu_waertab-bukrs.
369        endif.
370
371
372        at new bukrs.
373          select single * from t001 where bukrs = belege-bukrs.
374        endat.
375
376        at new curtp.
377          perform build_bk_methode using belege-bukrs.
378          perform posting_hwtyp2 using belege-bukrs
379                                       changing hwtyp2
380                                                hwtyp3.
381        endat.
382
383
384        at new hwtyp.
385          case bu_waertab-hwtyp.
386            when '1'.
387              t044a-bwmet = bk_methode-meth1.
388            when '2'.
389              t044a-bwmet = bk_methode-meth2.
390            when '3'.
391              t044a-bwmet = bk_methode-meth3.
392          endcase.
393          perform read_t044a using t044a-bwmet.
394        endat.
395
396        at end of vbund.
397          post_now = 'X'.
398        endat.
399    * number of lines per document
400
401        if post_line ge 300 and post_now = space. post_now = 'X'. endif.
402
403    * collecting lines and posting
404        if bu_waertab-storno = space.
405          perform posting_open_items using    mode
406                                     changing   ok.
407    *     stop this posting, if any error occured
408    *     the errornous postings are in a batchinput session
409          if post_upd ne space and ok ne 1.
410    *       message e473.
411    *       error_flag = 'X'.
412            bu_waertab_err = bu_waertab.
413            append bu_waertab_err.
414    *       CLEAR FIMSG.
415    *       FIMSG-MSGID = 'FR'.
416    *       FIMSG-MSGTY = 'E'.
417    *       FIMSG-MSGNO = '473'.
418    *       FIMSG-MSGV2 = BU_WAERTAB-BUKRS.
419    *       FIMSG-MSGV1 = BU_WAERTAB-HKONT.
420    *       FIMSG-MSGV3 = SPACE.
421    *       PERFORM log_almsg USING '13'.
422    *       EXIT.
423          endif.
424    *     <<<<<<<<exit if error <<<<<<<<<<<<<<
425
426        else.
427    *   reverse GR/IR accounts which are never updated (and cleared)
428          post_now = 'X'.
429          perform posting_open_items using 'C'
430                                     changing ok.
431        endif.
432
433        if post_now = 'X'.
434          post_now = space.
435          sy-subrc = post_count mod 10.
436          if sy-subrc = 0.
437            commit work.
438          endif.
439
440        endif.
441      endloop.
442
443    * data are stored in bi
444    * delete all documents for update and associated postings
445    * IF error_flag = 'X'.
446    *   REFRESH: belege_upd, bu_waertab, bu_waertab_clear.
447    * ENDIF.
448
449    endform.
450    *&---------------------------------------------------------------------*
451    *&       FORM posting_hwtyp2                                           *
452    *&---------------------------------------------------------------------*
453    *       ........                                                      *
454    *---------------------------------------------------------------------*
455    form posting_hwtyp2 using ibukrs
456                              changing ehwtyp2
457                                       ehwtyp3.
458      data: lhaus like haus.
459      data: ohaus like haus.
460
461      ehwtyp2 = space.
462      ehwtyp3 = space.
463      if t033-curtp2 <> space or t033-curtp3 ne space.
464        PERFORM DERIVE_HAUSWAERS USING ibukrs
465                                       T033-CURTP
466                                 changing ohaus.
467      endif.
468      if t033-curtp2 <> space.
469        PERFORM DERIVE_HAUSWAERS USING ibukrs
470                                       T033-CURTP2
471                                 changing lhaus.
472        if ohaus-waers = lhaus-waers.
473          ehwtyp2 = lhaus-field.
474        endif.
475      endif.
476      if t033-curtp3 ne space.
477        PERFORM DERIVE_HAUSWAERS USING ibukrs
478                                       T033-CURTP3
479                                 changing lhaus.
480        if ohaus-waers = lhaus-waers.
481          ehwtyp3 = lhaus-field.
482        endif.
483      endif.
484    endform.
485    *&--------------------------------------------------------------------*
486    *&      FORM POSTING_LINE_HWTYP2                                      *
487    *&--------------------------------------------------------------------*
488    *       ........                                                      *
489    *---------------------------------------------------------------------*
490    form post_line_hwtyp2 using ihwtyp like hwtyp2
491                                  text_dmbtr.
492      data: bseg_feld(12).
493      if ihwtyp ne space.
494        CASE ihwtyp.
495          WHEN '1'.
496            BSEG_FELD = 'BSEG-DMBTR'.
497            buchung-dmbe1_t033 = buchung-dmbtr.
498          WHEN '2'.
499            BSEG_FELD = 'BSEG-DMBE2'.
500            buchung-dmbe2_t033 = buchung-dmbtr.
501          WHEN '3'.
502            BSEG_FELD = 'BSEG-DMBE3'.
503            buchung-dmbe3_t033 = buchung-dmbtr.
504        ENDCASE.
505        PERFORM SETZEN USING  BSEG_FELD   TEXT_DMBTR.
506      endif.
507    endform.
508    *&---------------------------------------------------------------------*
509    *&       FORM POSTING_LOOP_BU_WAERTAB_CLEAR                            *
510    *&---------------------------------------------------------------------*
511    *       ........                                                      *
512    *---------------------------------------------------------------------*
513    form posting_loop_bu_waertab_clear.
514      data: error_flag.
515
516      if p_bldat is initial.
517        p_bldat = p_bbudat.
518      endif.
519
520      loop at bu_waertab_clear.
521
522        at new bukrs.
523          select single * from t001 where bukrs = bu_waertab_clear-bukrs.
524        endat.
525
526        at new curtp.
527          perform build_bk_methode using bu_waertab_clear-bukrs.
528        endat.
529
530        at new hwtyp.
531          case bu_waertab-hwtyp.
532            when '1'.
533              t044a-bwmet = bk_methode-meth1.
534            when '2'.
535              t044a-bwmet = bk_methode-meth2.
536            when '3'.
537              t044a-bwmet = bk_methode-meth3.
538          endcase.
539          perform read_t044a using t044a-bwmet.
540        endat.
541
542        at end of vbund.
543          post_now = 'X'.
544        endat.
545
546
547        post_now = 'X'.                    "single posting
548    *    if bu_waertab_clear-augbl = space.
549    *      bu_waertab_clear-augdt = st_budat.
550    *    endif.
551        perform posting_cleared_items.
552
553      endloop.
554      perform f100_bel_rfdt tables f100_bel.
555      refresh bu_waertab_clear.
556    endform.
557    *&--------------------------------------------------------------------*
558    *&      FORM posting_document                                         *
559    *&--------------------------------------------------------------------*
560    *       ........                                                      *
561    *---------------------------------------------------------------------*
562    form posting_document using i_mode type c.
563      statics:
564          func like rfipi-funct,
565          user like apqi-userid,
566          mode like rfpdo-allgazmd.
567      data:  text_datum(8).
568
569      data:   begin of xblntab  occurs 2.
570              include structure blntab.
571      data:   end of xblntab.
572      data:   begin of xfttax   occurs 2.
573              include structure fttax.
574      data:   end of xfttax.
575      data:   subrc like sy-subrc.
576      data:   docnr like bkpf-belnr.
577      ok = 0.
578
579
580      if bi_open_flag ne 'X' and  i_mode <> 'CLOSE'.
581    * Eroeffnen der Transaktion call
582    * Testmodus gewuenscht
583        if filename = text-400.
584          mode = 'A'.
585        else.
586          mode = 'N'.
587        endif.
588
589        if par_bi ne space.                "erst hier buchungen pruefen
590    * in Mappe ausgeben, falls eine Mappe angegeben wurde
591          if par_bnam ne space and
592            ( post_upd = space or p_bwber ne space ).
593            func = 'B'.
594            mode = 'N'.
595            user = sy-uname.
596          else.
597    *  direkt buchen bei update und wenn Bewertungsbereich leer !
598            func = 'C'.
599            user = sy-uname.
600            if par_bnam is initial.
601              par_bnam = sy-repid.
602            endif.
603          endif.
604    *>>note 333917
605          clear: sy-msgno, sy-msgid, sy-msgty, sy-msgv1,
606           sy-msgv2, sy-msgv3, sy-msgv4.
607    *<<note 333917
608          call function 'POSTING_INTERFACE_START'
609               exporting
610                    i_function         = func
611                    i_group            = par_bnam
612                    i_keep             = 'X'
613                    i_mode             = mode
614                    i_user             = user
615    * create batch input when update mode and error occurs
616                    i_xbdcc            = par_bi
617               exceptions
618                    error_message   = 1
619                    others             = 6.
620    *     move error messages to log
621    *     perform LOG_ALMSG using '20'.
622          if sy-subrc ne 0.
623            perform LOG_ALMSG using '20'.
624            exit.
625          endif.
626
627          bi_open_flag = 'X'.
628        endif.
629      endif.
630
631    *-----------------------------called at first line ---------------------
632    * create new document
633      if i_mode = 'NEW'.
634        add 1 to post_count.               "number of documents
635        post_line = 0.
636        refresh ftpost.
637    * document header
638        ftpost-stype = 'K'.
639        ftpost-count = '1'.
640
641        write buchung-budat to text_datum.
642        perform setzen using 'BKPF-BUDAT'  text_datum.
643        write p_bldat to text_datum.
644        perform: setzen using 'BKPF-BLDAT'  text_datum,
645                setzen using 'BKPF-BLART'  t044a-blart,
646                setzen using 'BKPF-MONAT'  buchung-monat,
647                setzen using 'BKPF-WAERS'  buchung-waers,
648                setzen using 'BKPF-BUKRS'  buchung-bukrs,
649                setzen using 'BKPF-BKTXT'  buchung-bktxt.
650    *           vbund always set in lines !
651        exit.                              "create head
652      endif.
653    *----------------------------------------------------------------------
654
655      if post_now ne space and i_mode = 'POST'
656        and post_line <> 0.
657
658
659        post_line = 0.                     "reset counter
660    * now post it
661        if par_bi ne space.
662          sy-subrc = 0.
663          set parameter id 'BLN' field space.
664    *>>note 333917
665          clear: sy-msgno, sy-msgid, sy-msgty, sy-msgv1,
666                 sy-msgv2, sy-msgv3, sy-msgv4.
667    *<<note 333917
668          call function 'POSTING_INTERFACE_DOCUMENT'
669               EXPORTING
670                    i_tcode       = 'FBB1'
671               IMPORTING
672                    e_msgid       = syst-msgid
673                    e_msgty       = syst-msgty
674                    e_msgno       = syst-msgno
675                    e_msgv1       = syst-msgv1
676                    e_msgv2       = syst-msgv2
677                    e_msgv3       = syst-msgv3
678                    e_msgv4       = syst-msgv4
679                    e_subrc       = subrc
680               TABLES
681                    t_ftpost      = ftpost
682                    t_blntab      = xblntab
683                    t_fttax       = xfttax
684               EXCEPTIONS
685                    error_message = 9
686                    others        = 9.
687
688          perform LOG_ALMSG using '20'.
689    *     move error messages to log
690          if  sy-subrc ne 0 or subrc ne 0.
691            ok = 0.
692    *        perform LOG_ALMSG using '20'.
693            docnr         = text-402.
694            docnr+7       = sy-msgno.
695    *       IF post_upd <> space.
696            bi_filled_flag = 'X'.
697    *       ENDIF.
698          else.
699            ok = 1.
700            get parameter id 'BLN' field docnr.
701    *       if docnr ne space.
702    *         message I312(F5) with docnr
703    *                               buchung-bukrs
704    *                          into g_dummy.
705    *         perform LOG_ALMSG using '20'.
706    *       endif.
707          endif.
708    *       fill the documentnumber in all lines of the document
709          loop at buchung where post = post_count.
710            buchung-fimsg = fimsg.
711            buchung-belnr = docnr.
712            modify buchung transporting belnr
713                                        fimsg.
714          endloop.
715        endif.
716    *   no document number when in batch input
717        if func = 'B'.
718          buchung-belnr = space.
719          bi_filled_flag = 'X'.
720        endif.
721      else.
722        ok = 1.
723
724      endif.
725
726    * close bi_session
727      if i_mode = 'CLOSE'
728                          and bi_open_flag = 'X'.
729        call function 'POSTING_INTERFACE_END'.
730
731        clear fimsg.
732        if par_bi ne space.
733          if bi_filled_flag <> space.
734            fimsg-msgv1 = text-243.
735            fimsg-msgv2 = par_bnam.
736          else.
737            fimsg-msgv1 = text-241.
738
739          endif.
740          message I600(FR) with fimsg-msgv1
741                                fimsg-msgv2
742                           into g_dummy.
743          perform log_almsg using '21'.
744        endif.
745      endif.
746    endform.
747    *&---------------------------------------------------------------------*
748    *&       FORM POSTING_LINEX                                            *
749    *&---------------------------------------------------------------------*
750    *       ........                                                      *
751    *---------------------------------------------------------------------*
752    *  -->  ILINE                                                         *
753    *  -->  IBSL                                                          *
754    *  -->  IKTO                                                          *
755    *---------------------------------------------------------------------*
756    form posting_linex using
757                     ibsl  like buchung-bschl
758                     ikto  like buchung-konto
759                     changing iline like post_line.
760
761      data: bseg_feld(12) type c,
762             text_dmbtr(16) type c.
763
764      if buchung-dmbtr = 0. ok = 1. exit. endif.
765      if no_post <> space. ok = 1. exit. endif.                 "JVA
766      case bu_waertab-hwtyp.
767        when '1'.
768          bseg_feld = 'BSEG-DMBTR'.
769        when '2'.
770          bseg_feld = 'BSEG-DMBE2'.
771        when '3'.
772          bseg_feld = 'BSEG-DMBE3'.
773      endcase.
774
775    * start a new document
776      if iline = 0.
777        perform posting_document using 'NEW'.
778      endif.
779
780      add 1 to ILINE.
781      buchung-buzei = ILINE.
782      buchung-post = post_count.
783    *
784      buchung-dmbtr = abs( buchung-dmbtr ).
785      buchung-bdiff_rem = abs( buchung-bdiff_rem ).
786      if ibsl = t030b-bschh.
787        buchung-dmbtr = 0 -  buchung-dmbtr.
788        buchung-bdiff_rem = 0 -  buchung-bdiff_rem.
789      endif.
790
791
792      ftpost-stype = 'P'.
793      ftpost-count = iline.
794      perform setzen using 'BSEG-BSCHL' ibsl.    "Buchungschl
795      if ikto cs '<' and ikto cs '>'.      "not a proper account H339094
796    *    was <Expense> will be <140000Expense>
797        data:  text like RF05A-NEWKO, lc(40) type c.
798        write bu_waertab-hkont to lc no-zero.
799        write ikto to lc+10. translate lc using '< '.
800        condense lc no-gaps.
801        concatenate '<' lc  into text.
802        perform setzen using 'BSEG-HKONT' text.
803      else.
804        perform setzen using 'BSEG-HKONT' ikto.
805      endif.
806
807    *
808      write buchung-dmbtr currency buchung-hwaer no-sign
809                              to text_dmbtr.
810      perform setzen using  bseg_feld   text_dmbtr.
811    * post additional parallel currency if wanted
812      buchung-dmbe2_t033 = buchung-dmbe3_t033 = 0.
813      buchung-dmbe1_t033 = 0.
814      perform post_line_hwtyp2 using hwtyp2 text_dmbtr.
815      perform post_line_hwtyp2 using hwtyp3 text_dmbtr.
816
817      perform setzen using 'BSEG-WRBTR'  0.
818      perform setzen using 'BSEG-SGTXT'  buchung-sgtxt.
819      perform setzen using  'COBL-GSBER' buchung-gsber.
820    * for FBB1 the VBUND field is always available (in rel 4.6
821      perform setzen using 'BSEG-VBUND'  bu_waertab-vbund.
822
823    * additional fields
824      perform posting_additional_fields using ibsl ikto
825                                              buchung-gsber.
826    * fill additional fields from ledger
827    *  perform posting_flex_fields.
828    *  create additional amount in parallel currency for remeasurement
829      if not p_remon is initial and buchung-bdiff_rem ne 0.
830        perform remsmt_posting using iline buchung.
831      endif.
832      append buchung.
833
834    endform.
835    *&---------------------------------------------------------------------*
836    *&       FORM SETZEN                                                   *
837    *&---------------------------------------------------------------------*
838    *       ........                                                      *
839    *---------------------------------------------------------------------*
840    *  -->  FELDNAME                                                      *
841    *  -->  FELDINHALT                                                    *
842    *---------------------------------------------------------------------*
843    form setzen       using feldname feldinhalt.
844      check feldinhalt ne space.
845      ftpost-fnam = feldname.
846      ftpost-fval = feldinhalt.
847      append  ftpost.
848    endform.
849    *&---------------------------------------------------------------------*
850    *&       FORM REMSMT_POSTING                                           *
851    *&---------------------------------------------------------------------*
852    *       ........                                                      *
853    *---------------------------------------------------------------------*
854    *  -->  ILINE                                                         *
855    *  -->  IBUCHUNG                                                      *
856    *---------------------------------------------------------------------*
857    form remsmt_posting using iline ibuchung structure buchung.
858      data: bseg_feld(12) type c,          "Feld fuer (Haus) Waehrungsbetrag
859            text_dmbtr(16) type c.
860
861      case bk_methode-typ_rem.
862        when '1'.
863          bseg_feld = 'BSEG-DMBTR'.
864          buchung-dmbe1_t033 = ibuchung-bdiff_rem.
865        when '2'.
866          bseg_feld = 'BSEG-DMBE2'.
867          buchung-dmbe2_t033 = ibuchung-bdiff_rem.
868       when '3'.
869          bseg_feld = 'BSEG-DMBE3'.
870          buchung-dmbe3_t033 = ibuchung-bdiff_rem.
871        when others.
872          exit.
873      endcase.
874    * do not post in same currency
875
876      check bk_methode-hwaer_rem ne space.
877      ibuchung-hwaer_rem = bk_methode-hwaer_rem.
878    * <<<always remeasuremnt >>
879    * CHECK ibuchung-hwaer_rem NE ibuchung-waers.
880    * add in line 1
881      ftpost-stype = 'P'.
882      ftpost-count = iline.
883      write ibuchung-bdiff_rem currency ibuchung-hwaer_rem no-sign
884                             to text_dmbtr.
885      perform setzen using  bseg_feld    text_dmbtr.
886
887      if not gd_t033_rem-curtp2 is initial.
888        select single * from t001a where
889                                      bukrs = buchung-bukrs.
890        case gd_t033_rem-curtp2.
891          when t001a-curtp.
892            bseg_feld = 'BSEG-DMBE2'.
893            buchung-dmbe2_t033 = ibuchung-bdiff_rem.
894          when t001a-curtp2.
895            bseg_feld = 'BSEG-DMBE3'.
896            buchung-dmbe3_t033 = ibuchung-bdiff_rem.
897        endcase.
898          perform setzen using  bseg_feld    text_dmbtr.
899      endif.
900      sort ftpost.
901    endform.
902    *&---------------------------------------------------------------------*
903    *&       FORM POSTING_ADDITIONAL_FIELDS                                *
904    *&---------------------------------------------------------------------*
905    *       ........                                                      *
906    *---------------------------------------------------------------------*
907    *  -->  POSTKEY                                                       *
908    *  -->  ACCOUNT                                                       *
909    *---------------------------------------------------------------------*
910    form posting_additional_fields using postkey account
911                                         igsber like bseg-gsber.
912      data: inhalt like ftpost-fval.
913      check account ne space.              "not when dummy account set
914      check account ne '?'.                "not when dummy account set
915
916      perform posting_add_selection using postkey
917        t001-bukrs account 'BSEG-VALUT'
918                              sy-subrc.
919      if sy-subrc = 0.
920        write stichtag to inhalt dd/mm/yy.
921        perform setzen using 'BSEG-VALUT' inhalt.
922      endif.
923
924      perform posting_add_selection using postkey
925      t001-bukrs account 'BSEG-ZUONR'
926                             sy-subrc.
927      if sy-subrc = 0.
928        perform setzen using 'BSEG-ZUONR'  stichtag.
929      endif.
930
931      perform posting_add_selection using postkey
932        t001-bukrs account 'BSEG-ABPER'
933                              sy-subrc.
934      if sy-subrc = 0.
935        perform setzen using 'BSEG-ABPER'  stichtag(6). "yyyymm
936      endif.
937
938      perform posting_add_selection using postkey
939        t001-bukrs account 'BSEG-PRCTR'
940                              sy-subrc.
941      if sy-subrc = 0.
942        perform setup_prctr using t001-bukrs account igsber.
943        perform setzen using 'COBL-PRCTR'  bseg-prctr.
944      endif.
945    *to open the saplkeak 0300
946      perform posting_add_selection using postkey
947        t001-bukrs account 'BSEG-RKE_BUKRS'
948                              sy-subrc.
949      if sy-subrc = 0.
950    *not yet   perform setzen using 'BSEG-RKE_BUKRS' t001-bukrs.
951      endif.
952
953    *
954      perform setup_mwskz using t001-bukrs account.
955    * perform posting_add_selection using postkey  Example
956    *  t001-bukrs account 'COBL-RMVCT'
957    *                         sy-subrc.
958    * if sy-subrc = 0.
959    *   perform setzen using 'COBL-RMVCT'  '001'.  "lUFTHANSA
960    *endif.
961    endform.
962    *&---------------------------------------------------------------------*
963    *& FORM posting_add_selection                                          *
964    *&---------------------------------------------------------------------*
965    *       ........                                                      *
966    *---------------------------------------------------------------------*
967    *  -->  PA_BUSCHL                                                     *
968    *  -->  PA_BUKRS                                                      *
969    *  -->  PA_SAKNR                                                      *
970    *  -->  PA_FELD                                                       *
971    *  -->  RETURN                                                        *
972    *---------------------------------------------------------------------*
973    form posting_add_selection using pa_buschl pa_bukrs pa_saknr pa_feld
974                               return.
975      data:char(1).
976      tables : tbsl.
977      check: pa_saknr ne space and pa_saknr ne '?'.
978
979      call function 'FI_FIELD_SELECTION_DETERMINE'
980           EXPORTING
981                i_bschl       = pa_buschl
982                i_bukrs       = pa_bukrs
983                i_saknr       = pa_saknr
984           IMPORTING
985                e_faus1       = tbsl-faus1
986                e_faus2       = tbsl-faus2
987           EXCEPTIONS
988                error_message = 4
989                others        = 4.
990      if sy-subrc ne 0.
991        return = 4.
992        exit.
993      endif.
994      return =  0.
995    * remember, you can find the offset in table TMODU
996      case pa_feld.
997        when 'BSEG-VALUT'. char = tbsl-faus1+5(1).
998        when 'BSEG-ABPER'. char = tbsl-faus1+2(1).
999    * use the default from the master record
1000       when 'BSEG-ZUONR'. char = tbsl-faus1+0(1).
1001             if char <> '+'. return = 4. endif. "H394937
1002       when 'COBL-RMVCT'. char = tbsl-faus1+26(1).
1003       when 'BSEG-PRCTR'. char = tbsl-faus1+41(1).
1004       when 'BSEG-RKE_BUKRS'.
1005         char = tbsl-faus1+42(1).
1006         if char <> '+'. return = 4. endif. "nur bei Mussfeld
1007       when others. return = 4.
1008     endcase.
1009   *     field not allowed
1010     if return = 0.
1011       if char = '-'. return = 4. endif.
1012     endif.
1013   endform.
1014   *&---------------------------------------------------------------------*
1015   *& FORM setup_mwskz                                                    *
1016   *&---------------------------------------------------------------------*
1017   * use default mwskz.
1018   FORM setup_mwskz USING ibukrs LIKE t001-bukrs
1019                          iaccount LIKE skb1-saknr.
1020
1021     statics: s_skb1 like skb1.
1022     IF s_skb1-saknr NE iaccount.
1023
1024       CALL FUNCTION 'READ_SACHKONTO'
1025            EXPORTING
1026                 buchungskreis = ibukrs
1027                 sachkonto     = iaccount
1028            IMPORTING
1029                 sachkonto_wa  = s_skb1
1030            EXCEPTIONS
1031                 OTHERS        = 0.
1032     ENDIF.
1033
1034     CHECK: s_skb1-mwskz NE space.
1035     CHECK: s_skb1-xmwno = space.
1036
1037     PERFORM SETZEN USING 'BSEG-TXJCD' T001-TXJCD.
1038     CASE s_skb1-mwskz.
1039       WHEN '<'.
1040         PERFORM setzen USING 'BSEG-MWSKZ' t001-mwskv.
1041       WHEN '>'.
1042         PERFORM setzen USING 'BSEG-MWSKZ' t001-mwska.
1043       WHEN '-'.
1044         PERFORM setzen USING 'BSEG-MWSKZ' t001-mwskv.
1045       WHEN OTHERS.
1046         select mwskz from t007a into skb1-mwskz
1047                       where mwskz = s_skb1-mwskz.
1048           PERFORM setzen USING 'BSEG-MWSKZ' s_skb1-mwskz.
1049           exit.
1050         endselect.
1051         check sy-subrc <> 0.
1052         PERFORM setzen USING 'BSEG-MWSKZ' t001-mwska.
1053     ENDCASE.
1054
1055     LOOP AT FTPOST WHERE COUNT = FTPOST-COUNT
1056                    AND   FNAM = 'BSEG-VALUT'.
1057       DELETE FTPOST.
1058     ENDLOOP.
1059     LOOP AT FTPOST WHERE COUNT = FTPOST-COUNT
1060                    AND   FNAM = 'COBL-PRCTR'.
1061       DELETE FTPOST.
1062     ENDLOOP.
1063
1064
1065   ENDFORM.
1066   *&---------------------------------------------------------------------*
1067   *& FORM setup_prctr                                                    *
1068   *&---------------------------------------------------------------------*
1069   FORM setup_prctr USING ibukrs LIKE t001-bukrs
1070                          iaccount LIKE skb1-saknr
1071                          igsber   like bseg-gsber.
1072     statics: s_account like skb1-saknr.
1073     clear bseg-prctr.
1074     CALL FUNCTION 'COPCA_GET_DEFAULT_PRCTR_T8A30'
1075          EXPORTING
1076               I_ACCOUNT      = iaccount
1077               I_COMPANY_CODE = ibukrs
1078               I_BUSINESS_AREA = igsber
1079          IMPORTING
1080               E_PRCTR        = bseg-prctr
1081          EXCEPTIONS
1082               error_message  = 0
1083               others         = 0.
1084
1085
1086     .
1087     check bseg-prctr is initial.
1088     IF s_account  NE iaccount.
1089       CALL FUNCTION 'K_ACCOUNT_ASSIGNMENT_GET'
1090            EXPORTING
1091                 BUKRS     = ibukrs
1092   *             BWKEY     = ' '
1093                 GSBER     = igsber
1094   *             I_PRCTR   = ' '
1095                 KSTAR     = iaccount
1096   *             WERKS     = ' '
1097   *             I_COBL    =
1098            IMPORTING
1099   *             AUFNR     =
1100   *             KOSTL     =
1101                 PRCTR     = bseg-prctr
1102   *             E_PAOBJNR =
1103   *             E_REGEL   =
1104   *             E_XGSBER  =
1105                 .
1106
1107     endif.
1108   endform.
*--- End of ZSAPF100_POSTINGS_NEW - 1108 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CCXTAB                                  Level 1    Page 8
Object           ZJV_SAPF100                               Lines 6
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:11
----------------------------------------------------------------------------------------------------
1      TYPE-POOL CXTAB .
2
3      TYPES:
4             CXTAB_COLUMN type scxtab_column,
5             CXTAB_CONTROL type scxtab_control,
6             CXTAB_TABSTRIP type scxtab_tabstrip.
*--- End of %_CCXTAB - 6 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CICON                                   Level 1    Page 9
Object           ZJV_SAPF100                               Lines 1246
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:11
----------------------------------------------------------------------------------------------------
1      TYPE-POOL ICON.
2      INCLUDE >ICON<.
3      *
4      *                     DEFINITION OF ICONS
5      *
6      *Icon_Length                           ID
7      *      Name                                     Quickinfo
8      ICON_2 ICON_DUMMY                     '@00@'."  PlaceholderIcon
9      ICON_2 ICON_CHECKED                   '@01@'."  Checked; OK
10     ICON_2 ICON_INCOMPLETE                '@02@'."  Incomplete
11     ICON_2 ICON_FAILURE                   '@03@'."  Failed
12     ICON_2 ICON_POSITIVE                  '@04@'."  Positive
13     ICON_2 ICON_NEGATIVE                  '@05@'."  Negative
14     ICON_2 ICON_LOCKED                    '@06@'."  Locked
15     ICON_2 ICON_UNLOCKED                  '@07@'."  Free; unlock
16     ICON_4 ICON_GREEN_LIGHT               '@08@'."  Green light; positive
17     ICON_4 ICON_YELLOW_LIGHT              '@09@'."  Yellow light; neutral
18     ICON_4 ICON_RED_LIGHT                 '@0A@'."  Red light; negative
19     ICON_2 ICON_TOTAL_LEFT                '@0B@'."  Extreme left; first ...
20     ICON_2 ICON_TOTAL_RIGHT               '@0C@'."  Extreme right; last ...
21     ICON_2 ICON_COLUMN_LEFT               '@0D@'."  Column left; previous ..
22     ICON_2 ICON_COLUMN_RIGHT              '@0E@'."  Column right; next ...
23     ICON_2 ICON_PAGE_RIGHT                '@0F@'."  Page right
24     ICON_2 ICON_PAGE_LEFT                 '@0G@'."  Page left
25     ICON_2 ICON_PREVIOUS_VALUE            '@0H@'."  Previous value; next ent
26     ICON_2 ICON_NEXT_VALUE                '@0I@'."  Next value; previous ent
27     ICON_2 ICON_ANNOTATION                '@0J@'."  Note; remark
28     ICON_2 ICON_CREATE_NOTE               '@0K@'."  Create note
29     ICON_2 ICON_DISPLAY_NOTE              '@0L@'."  Display note
30     ICON_2 ICON_CALCULATION               '@0M@'."  Costing
31     ICON_2 ICON_GRAPHICS                  '@0N@'."  Graphics
32     ICON_2 ICON_CREATE_TEXT               '@0O@'."  Create text
33     ICON_2 ICON_DISPLAY_TEXT              '@0P@'."  Display text
34     ICON_2 ICON_CHANGE_TEXT               '@0Q@'."  Text
35     ICON_2 ICON_VARIANTS                  '@0R@'."  Variants
36     ICON_2 ICON_INFORMATION               '@0S@'."  Information
37     ICON_2 ICON_ADDRESS                   '@0T@'."  Address
38     ICON_2 ICON_VIEWER_OPTICAL_ARCHIVE    '@0U@'."  Optical archive viewer
39     ICON_2 ICON_OKAY                      '@0V@'."  OK; Continue; Choose <va
40     ICON_2 ICON_CANCEL                    '@0W@'."  Cancel
41     ICON_2 ICON_PRINT                     '@0X@'."  Print
42     ICON_2 ICON_CREATE                    '@0Y@'."  Create
43     ICON_2 ICON_CHANGE                    '@0Z@'."  Change
44     ICON_2 ICON_DISPLAY                   '@10@'."  Display
45     ICON_2 ICON_DELETE                    '@11@'."  Delete
46     ICON_2 ICON_TEST                      '@12@'."  Test
47     ICON_2 ICON_SEARCH                    '@13@'."  Find
48     ICON_2 ICON_COPY_OBJECT               '@14@'."  Copy <object>
49     ICON_2 ICON_EXECUTE_OBJECT            '@15@'."  Execute <object>
50     ICON_2 ICON_SELECT_DETAIL             '@16@'."  Choose detail; detail sc
51     ICON_2 ICON_INSERT_ROW                '@17@'."  Insert line
52     ICON_2 ICON_DELETE_ROW                '@18@'."  Delete line
53     ICON_4 ICON_MESSAGE_INFORMATION       '@19@'."  Information message
54     ICON_4 ICON_MESSAGE_WARNING           '@1A@'."  Warning
55     ICON_4 ICON_MESSAGE_ERROR             '@1B@'."  Error message
56     ICON_4 ICON_MESSAGE_QUESTION          '@1C@'."  Question
57     ICON_4 ICON_MESSAGE_CRITICAL          '@1D@'."  Critical message
58     ICON_2 ICON_DISPLAY_MORE              '@1E@'."  Display/change more
59     ICON_2 ICON_ENTER_MORE                '@1F@'."  Create more
60     ICON_2 ICON_EQUAL                     '@1G@'."  Equal
61     ICON_2 ICON_NOT_EQUAL                 '@1H@'."  Not equal
62     ICON_2 ICON_GREATER                   '@1I@'."  Greater
63     ICON_2 ICON_LESS                      '@1J@'."  Less
64     ICON_2 ICON_GREATER_EQUAL             '@1K@'."  Greater/equal
65     ICON_2 ICON_LESS_EQUAL                '@1L@'."  Less than/equal
66     ICON_2 ICON_INTERVAL_INCLUDE          '@1M@'."  Include range
67     ICON_2 ICON_INTERVAL_EXCLUDE          '@1N@'."  Exclude range
68     ICON_2 ICON_PATTERN_INCLUDE           '@1O@'."  Include pattern
69     ICON_2 ICON_PATTERN_EXCLUDE           '@1P@'."  Exclude pattern
70     ICON_2 ICON_PHONE                     '@1Q@'."  Telephone number
71     ICON_2 ICON_FAX                       '@1R@'."  Fax number
72     ICON_2 ICON_MAIL                      '@1S@'."  Send message; mail
73     ICON_2 ICON_TIME                      '@1T@'."  Time
74     ICON_2 ICON_DATE                      '@1U@'."  Date
75     ICON_2 ICON_ALARM                     '@1V@'."  Alarm
76     ICON_2 ICON_PROSHARE                  '@1W@'."  Per share
77     ICON_2 ICON_VIDEO                     '@1X@'."  Video
78     ICON_2 ICON_VOICE_INPUT               '@1Y@'."  Language input
79     ICON_2 ICON_VOICE_OUTPUT              '@1Z@'."  Language output
80     ICON_2 ICON_EQUAL_GREEN               '@20@'."  Select: Equal
81     ICON_2 ICON_NOT_EQUAL_GREEN           '@21@'."  Select: Not equal
82     ICON_2 ICON_GREATER_GREEN             '@22@'."  Select: Greater than
83     ICON_2 ICON_LESS_GREEN                '@23@'."  Select: Less than
84     ICON_2 ICON_GREATER_EQUAL_GREEN       '@24@'."  Select: Greater than or
85     ICON_2 ICON_LESS_EQUAL_GREEN          '@25@'."  Select: Less than or equ
86     ICON_2 ICON_INTERVAL_INCLUDE_GREEN    '@26@'."  Select: Include range
87     ICON_2 ICON_INTERVAL_EXCLUDE_GREEN    '@27@'."  Select: Exclude range
88     ICON_2 ICON_PATTERN_INCLUDE_GREEN     '@28@'."  Select: Include pattern
89     ICON_2 ICON_PATTERN_EXCLUDE_GREEN     '@29@'."  Select: Exclude pattern
90     ICON_2 ICON_EQUAL_RED                 '@2A@'."  Do not select: Equal
91     ICON_2 ICON_NOT_EQUAL_RED             '@2B@'."  Do not select: Not equal
92     ICON_2 ICON_GREATER_RED               '@2C@'."  Do not select: Greater t
93     ICON_2 ICON_LESS_RED                  '@2D@'."  Do not select: Less than
94     ICON_2 ICON_GREATER_EQUAL_RED         '@2E@'."  Do not select: Greater/e
95     ICON_2 ICON_LESS_EQUAL_RED            '@2F@'."  Do not select: Less than
96     ICON_2 ICON_INTERVAL_INCLUDE_RED      '@2G@'."  Do not select: Include r
97     ICON_2 ICON_INTERVAL_EXCLUDE_RED      '@2H@'."  Do not select: Exclude r
98     ICON_2 ICON_PATTERN_INCLUDE_RED       '@2I@'."  Do not select: Include p
99     ICON_2 ICON_PATTERN_EXCLUDE_RED       '@2J@'."  Do not select: Exclude p
100    ICON_2 ICON_SYSTEM_OKAY               '@2K@'."  OK
101    ICON_2 ICON_SYSTEM_SAVE               '@2L@'."  Save
102    ICON_2 ICON_SYSTEM_BACK               '@2M@'."  Back
103    ICON_2 ICON_SYSTEM_END                '@2N@'."  Exit
104    ICON_2 ICON_SYSTEM_CANCEL             '@2O@'."  Cancel
105    ICON_2 ICON_SYSTEM_PRINT              '@2P@'."  Print
106    ICON_2 ICON_OTHER_OBJECT              '@2Q@'."  Other <object>
107    ICON_2 ICON_PREVIOUS_OBJECT           '@2R@'."  Previous screen
108    ICON_2 ICON_NEXT_OBJECT               '@2S@'."  Next screen
109    ICON_2 ICON_SYSTEM_CUT                '@2T@'."  Cut
110    ICON_2 ICON_SYSTEM_COPY               '@2U@'."  Copy
111    ICON_2 ICON_SYSTEM_PASTE              '@2V@'."  Paste
112    ICON_2 ICON_SYSTEM_UNDO               '@2W@'."  Undo
113    ICON_2 ICON_SYSTEM_MARK               '@2X@'."  Select mode; select
114    ICON_2 ICON_FIRST_PAGE                '@2Y@'."  First page
115    ICON_2 ICON_PREVIOUS_PAGE             '@2Z@'."  Prev. page
116    ICON_2 ICON_NEXT_PAGE                 '@30@'."  Next page
117    ICON_2 ICON_LAST_PAGE                 '@31@'."  Last page
118    ICON_2 ICON_SYSTEM_MODUS_CREATE       '@32@'."  Create session
119    ICON_2 ICON_SYSTEM_MODUS_DELETE       '@33@'."  Delete session
120    ICON_2 ICON_SYSTEM_USERMENU           '@34@'."  Session Manager
121    ICON_2 ICON_SYSTEM_HELP               '@35@'."  Help
122    ICON_2 ICON_TABLE_SETTINGS            '@36@'."  Report-report call
123    ICON_2 ICON_REPLACE                   '@37@'."  Replace
124    ICON_2 ICON_CHECK                     '@38@'."  Check
125    ICON_2 ICON_GENERATE                  '@39@'."  Generate
126    ICON_2 ICON_REFERENCE_LIST            '@3A@'."  Where-used list
127    ICON_2 ICON_STACK                     '@3B@'."  Stack
128    ICON_2 ICON_ACTIVATE                  '@3C@'."  Activate
129    ICON_2 ICON_ICON_LIST                 '@3D@'."  Icon list; key
130    ICON_2 ICON_SORT_UP                   '@3E@'."  Sort in ascending order
131    ICON_2 ICON_SORT_DOWN                 '@3F@'."  Sort in descending order
132    ICON_2 ICON_LAYOUT_CONTROL            '@3G@'."  Page view
133    ICON_2 ICON_CONVERT                   '@3H@'."  Convert
134    ICON_2 ICON_TOGGLE_DISPLAY_CHANGE     '@3I@'."  Display <-> Change
135    ICON_2 ICON_SET_STATE                 '@3J@'."  Set status
136    ICON_2 ICON_PREVIOUS_NODE             '@3K@'."  Previous node
137    ICON_2 ICON_NEXT_NODE                 '@3L@'."  Next node
138    ICON_2 ICON_TREE                      '@3M@'."  Hierarchy
139    ICON_2 ICON_INSERT_RELATION           '@3N@'."  Insert dependency
140    ICON_2 ICON_FINAL_DATE                '@3O@'."  End date
141    ICON_2 ICON_HEADER                    '@3P@'."  Header; basic data
142    ICON_2 ICON_OVERVIEW                  '@3Q@'."  Overview; overview; list
143    ICON_2 ICON_DETAIL                    '@3R@'."  Detail view
144    ICON_2 ICON_EXPAND                    '@3S@'."  Expand; enlarge
145    ICON_2 ICON_COLLAPSE                  '@3T@'."  Compress; reduce
146    ICON_2 ICON_BREAKPOINT                '@3U@'."  Breakpoint
147    ICON_2 ICON_FOREIGN_KEY               '@3V@'."  Foreign key
148    ICON_2 ICON_LIST                      '@3W@'."  List
149    ICON_2 ICON_CLOSE                     '@3X@'."  Close
150    ICON_2 ICON_POSITION                  '@3Y@'."  Position; other entry
151    ICON_2 ICON_SUM                       '@3Z@'."  Sum
152    ICON_2 ICON_MOVE                      '@40@'."  Move
153    ICON_2 ICON_RETRIEVE                  '@41@'."  Restore
154    ICON_2 ICON_REFRESH                   '@42@'."  Refresh
155    ICON_2 ICON_SKIP                      '@43@'."  Skip
156    ICON_2 ICON_SYSTEM_SETTINGS           '@44@'."  User settings
157    ICON_2 ICON_TOOLS                     '@45@'."  Tools
158    ICON_2 ICON_COMPARE                   '@46@'."  Compare
159    ICON_2 ICON_SHORT_MESSAGE             '@47@'."  Short message
160    ICON_2 ICON_IMPORT                    '@48@'."  Import
161    ICON_2 ICON_EXPORT                    '@49@'."  Export
162    ICON_2 ICON_TRANSPORT                 '@4A@'."  Transport
163    ICON_2 ICON_SELECT_ALL                '@4B@'."  Select all
164    ICON_2 ICON_SELECT_BLOCK              '@4C@'."  Select block
165    ICON_2 ICON_DESELECT_ALL              '@4D@'."  Deselect all
166    ICON_2 ICON_SEARCH_NEXT               '@4E@'."  Continue search
167    ICON_2 ICON_RENAME                    '@4F@'."  Rename
168    ICON_2 ICON_FILTER                    '@4G@'."  Filter
169    ICON_2 ICON_NEXT_HIERARCHY_LEVEL      '@4H@'."  Next hierarchy level
170    ICON_2 ICON_PREVIOUS_HIERARCHY_LEVEL  '@4I@'."  Previous hierarchy level
171    ICON_2 ICON_SYSTEM_POSSIBLE_ENTRIES   '@4J@'."  Possible entries
172    ICON_2 ICON_INTENSIFY                 '@4K@'."  Emphasize
173    ICON_2 ICON_PERSONAL_HELP             '@4L@'."  Individual help
174    ICON_2 ICON_VARIABLE                  '@4M@'."  Variable
175    ICON_2 ICON_SYSTEM_LOCAL_CUT          '@4N@'."  Cut (local)
176    ICON_2 ICON_SYSTEM_LOCAL_COPY         '@4O@'."  Copy (local)
177    ICON_2 ICON_SYSTEM_LOCAL_PASTE        '@4P@'."  Paste (local)
178    ICON_2 ICON_SYSTEM_LOCAL_MARK         '@4Q@'."  Selection mode (local)
179    ICON_2 ICON_SYSTEM_REDO               '@4R@'."  Repeat
180    ICON_2 ICON_BUSINAV_PROCESS           '@4S@'."  Process
181    ICON_2 ICON_BUSINAV_PROCESSMATRIX     '@4T@'."  Proc. sel. matrix
182    ICON_2 ICON_BUSINAV_SYSORGI           '@4U@'."  System chart
183    ICON_2 ICON_BUSINAV_SZENARIO          '@4V@'."  Scenario
184    ICON_2 ICON_BUSINAV_OBJECTS           '@4W@'."  Business objects
185    ICON_2 ICON_BUSINAV_INFODIAG          '@4X@'."  Info flow diagram
186    ICON_2 ICON_BUSINAV_ENTITY            '@4Y@'."  Entity type
187    ICON_2 ICON_BUSINAV_PROC_EXIST        '@4Z@'."  Process exists
188    ICON_2 ICON_BUSINAV_COMMDIAG          '@50@'."  Communication diagram
189    ICON_2 ICON_BUSINAV_DATAMODEL         '@51@'."  Data model
190    ICON_2 ICON_ALIGN                     '@52@'."  Align
191    ICON_2 ICON_CUT_RELATION              '@53@'."  Cancel link
192    ICON_2 ICON_FIX_COLUMN                '@54@'."  Fix columns
193    ICON_2 ICON_RELEASE_COLUMN            '@55@'."  Cancel column fix
194    ICON_2 ICON_NET_GRAPHIC               '@56@'."  Network graphics
195    ICON_2 ICON_PLANNING_TABLE            '@57@'."  Bar chart graphic; plan.
196    ICON_2 ICON_PERIOD                    '@58@'."  Period screen; time brea
197    ICON_2 ICON_ZOOM_IN                   '@59@'."  Maximize objects
198    ICON_2 ICON_ZOOM_OUT                  '@5A@'."  Minimize objects
199    ICON_2 ICON_LED_GREEN                 '@5B@'."  Go
200    ICON_2 ICON_LED_RED                   '@5C@'."  Stop
201    ICON_2 ICON_LED_YELLOW                '@5D@'."  Stop
202    ICON_2 ICON_SYSTEM_EXTENDED_HELP      '@5E@'."  Stop
203    ICON_2 ICON_SPACE                     '@5F@'."  Stop
204    ICON_2 ICON_BUSINAV_VALUE_CHAIN       '@5G@'."  Stop
205    ICON_2 ICON_WORKFLOW_ACTIVITY         '@5H@'."  Stop
206    ICON_2 ICON_WORKFLOW_CONDITION        '@5I@'."  Stop
207    ICON_2 ICON_WORKFLOW_DECISION         '@5J@'."  Stop
208    ICON_2 ICON_WORKFLOW_CONT_OPERATION   '@5K@'."  Stop
209    ICON_2 ICON_WORKFLOW_EXTERNAL_EVENT   '@5L@'."  Stop
210    ICON_2 ICON_WORKFLOW_INTERNAL_EVENT   '@5M@'."  Stop
211    ICON_2 ICON_WORKFLOW_MULT_CONDITION   '@5N@'."  Stop
212    ICON_2 ICON_WORKFLOW_FORK             '@5O@'."  Stop
213    ICON_2 ICON_WORKFLOW_EVENT_PRODUCER   '@5P@'."  Stop
214    ICON_2 ICON_WORKFLOW_FLOW_OF_CONTROL  '@5Q@'."  Stop
215    ICON_2 ICON_WORKFLOW_INDEFINITE_STEP  '@5R@'."  Stop
216    ICON_2 ICON_WORKFLOW_UNTIL            '@5S@'."  Stop
217    ICON_2 ICON_WORKFLOW_WAIT_FOR_EVENTS  '@5T@'."  Stop
218    ICON_2 ICON_WORKFLOW_WHILE            '@5U@'."  Stop
219    ICON_2 ICON_INTERMEDIATE_SUM          '@5V@'."  Stop
220    ICON_2 ICON_EMPLOYEE                  '@5W@'."  Stop
221    ICON_2 ICON_TIME_ZONE                 '@5X@'."  Stop
222    ICON_2 ICON_RELEASE                   '@5Y@'."  Stop
223    ICON_2 ICON_QUALIFY                   '@5Z@'."  Stop
224    ICON_2 ICON_ISO_CODE                  '@60@'."  Stop
225    ICON_2 ICON_MODIFY                    '@61@'."  Stop
226    ICON_2 ICON_GET_AREA                  '@62@'."  Stop
227    ICON_2 ICON_INTERFACE                 '@63@'."  Stop
228    ICON_2 ICON_ROUTING_OPERATION         '@64@'."  Stop
229    ICON_2 ICON_ROUTING_REF_OPERATION     '@65@'."  Stop
230    ICON_2 ICON_ROUTING_TASK              '@66@'."  Stop
231    ICON_2 ICON_ROUTING_TODO              '@67@'."  Stop
232    ICON_2 ICON_EXPAND_ALL                '@68@'."  Stop
233    ICON_2 ICON_COLLAPSE_ALL              '@69@'."  Stop
234    ICON_2 ICON_SYSTEM_SAP_MENU           '@6A@'."  Stop
235    ICON_2 ICON_SYSTEM_COMP_MENU          '@6B@'."  Stop
236    ICON_2 ICON_SYSTEM_USER_MENU          '@6C@'."  Stop
237    ICON_2 ICON_SYSTEM_FAVORITES          '@6D@'."  Stop
238    ICON_2 ICON_BIW_INFO_SOURCE           '@6E@'."  Stop
239    ICON_2 ICON_BIW_APPLICATION           '@6F@'."  Stop
240    ICON_2 ICON_BIW_INFO_AREA             '@6G@'."  Stop
241    ICON_2 ICON_BIW_INFO_CUBE             '@6H@'."  Stop
242    ICON_2 ICON_BIW_RULES_INA             '@6I@'."  Stop
243    ICON_2 ICON_BIW_SOURCE_SYS_GEN        '@6J@'."  Stop
244    ICON_2 ICON_BIW_SOURCE_SYS_R3         '@6K@'."  Stop
245    ICON_2 ICON_BIW_SOURCE_SYS_EXT        '@6L@'."  Stop
246    ICON_2 ICON_BIW_SOURCE_SYS_FILE       '@6M@'."  Stop
247    ICON_2 ICON_BIW_INFO_CATALOG          '@6N@'."  Stop
248    ICON_2 ICON_BIW_INFO_OBJECT           '@6O@'."  Stop
249    ICON_2 ICON_BIW_MONITOR               '@6P@'."  Stop
250    ICON_2 ICON_BIW_SCHEDULER             '@6Q@'."  Stop
251    ICON_2 ICON_BIW_FORMULA               '@6R@'."  Stop
252    ICON_2 ICON_BIW_REF_STRUCTURE         '@6S@'."  Stop
253    ICON_2 ICON_BIW_REPORT                '@6T@'."  Stop
254    ICON_2 ICON_BIW_REPORT_VIEW           '@6U@'."  Stop
255    ICON_2 ICON_MASTER_DATA_ACT           '@6V@'."  Stop
256    ICON_2 ICON_MASTER_DATA_INA           '@6W@'."  Stop
257    ICON_2 ICON_TEXT_ACT                  '@6X@'."  Stop
258    ICON_2 ICON_TEXT_INA                  '@6Y@'."  Stop
259    ICON_2 ICON_HIERARCHY_ACT             '@6Z@'."  Stop
260    ICON_2 ICON_HIERARCHY_INA             '@70@'."  Stop
261    ICON_2 ICON_MOVING_DATA_ACT           '@71@'."  Stop
262    ICON_2 ICON_MOVING_DATA_INA           '@72@'."  Stop
263    ICON_2 ICON_DEBUGGER_STEP_INTO        '@73@'."  Stop
264    ICON_2 ICON_DEBUGGER_STEP_OVER        '@74@'."  Stop
265    ICON_2 ICON_DEBUGGER_STEP_OUT         '@75@'."  Stop
266    ICON_2 ICON_DEBUGGER_CONTINUE         '@76@'."  Stop
267    ICON_2 ICON_PARAMETER                 '@77@'."  Stop
268    ICON_2 ICON_PARAMETER_IMPORT          '@78@'."  Stop
269    ICON_2 ICON_PARAMETER_EXPORT          '@79@'."  Stop
270    ICON_2 ICON_PARAMETER_CHANGING        '@7A@'."  Stop
271    ICON_2 ICON_PARAMETER_RESULT          '@7B@'."  Stop
272    ICON_2 ICON_OO_CLASS                  '@7C@'."  Stop
273    ICON_2 ICON_OO_INTERFACE              '@7D@'."  Stop
274    ICON_2 ICON_OO_ATTRIBUTE              '@7E@'."  Stop
275    ICON_2 ICON_OO_CLASS_ATTRIBUTE        '@7F@'."  Stop
276    ICON_2 ICON_OO_INST_ATTRIBUTE         '@7G@'."  Stop
277    ICON_2 ICON_OO_METHOD                 '@7H@'."  Stop
278    ICON_2 ICON_OO_CLASS_METHOD           '@7I@'."  Stop
279    ICON_2 ICON_OO_INST_METHOD            '@7J@'."  Stop
280    ICON_2 ICON_OO_EVENT                  '@7K@'."  Stop
281    ICON_2 ICON_OO_CONSTANT               '@7L@'."  Stop
282    ICON_2 ICON_OO_OVERWRITE              '@7M@'."  Stop
283    ICON_2 ICON_OO_CONNECTION             '@7N@'."  Stop
284    ICON_2 ICON_OO_INHERITANCE            '@7O@'."  Stop
285    ICON_2 ICON_OO_INTERFACE_IC           '@7P@'."  Stop
286    ICON_2 ICON_WS_TRUCK                  '@7Q@'."  Stop
287    ICON_2 ICON_WS_RAIL                   '@7R@'."  Stop
288    ICON_2 ICON_WS_SHIP                   '@7S@'."  Stop
289    ICON_2 ICON_WS_PLANE                  '@7T@'."  Stop
290    ICON_2 ICON_WS_POST                   '@7U@'."  Stop
291    ICON_2 ICON_WS_TRANSFER               '@7V@'."  Stop
292    ICON_2 ICON_WS_DOUANE                 '@7W@'."  Stop
293    ICON_2 ICON_SELECTION                 '@7X@'."  Stop
294    ICON_2 ICON_SYSTEM_STOP_RECORDING     '@7Y@'."  Stop
295    ICON_2 ICON_FENCING                   '@7Z@'."  Stop
296    ICON_2 ICON_BIW_RULES_ACT             '@80@'."  Stop
297    ICON_2 ICON_CHARACTERISTICS_ACT       '@81@'."  Stop
298    ICON_2 ICON_CHARACTERISTICS_INA       '@82@'."  Stop
299    ICON_2 ICON_KEYFIGURE_ACT             '@83@'."  Stop
300    ICON_2 ICON_KEYFIGURE_INA             '@84@'."  Stop
301    ICON_2 ICON_BIW_INFO_OBJECT_UNITS_ACT '@85@'."  Stop
302    ICON_2 ICON_BIW_INFO_OBJECT_UNITS_INA '@86@'."  Stop
303    ICON_2 ICON_WORKFLOW_INT_EVENT_DATE   '@87@'."  Stop
304    ICON_2 ICON_BIW_INFO_OBJECT_CATALOGUE '@88@'."  Stop
305    ICON_2 ICON_SET_A                     '@89@'."  Stop
306    ICON_2 ICON_SET_B                     '@8A@'."  Stop
307    ICON_2 ICON_SET_SUM                   '@8B@'."  Stop
308    ICON_2 ICON_SET_INTERSECTION          '@8C@'."  Stop
309    ICON_2 ICON_SET_A_MINUS_B             '@8D@'."  Stop
310    ICON_2 ICON_SET_B_MINUS_A             '@8E@'."  Stop
311    ICON_2 ICON_SET_COPY_IN_A             '@8F@'."  Stop
312    ICON_2 ICON_SET_COPY_IN_B             '@8G@'."  Stop
313    ICON_2 ICON_DANGEROUS_GOODS           '@8H@'."  Stop
314    ICON_2 ICON_DEACTIVATE                '@8I@'."  Stop
315    ICON_2 ICON_DESELECT_BLOCK            '@8J@'."  Stop
316    ICON_2 ICON_INVERT_COLUMN             '@8K@'."  Stop
317    ICON_2 ICON_INVERT_LINE               '@8L@'."  Stop
318    ICON_2 ICON_FOREIGN_TRADE             '@8M@'."  Stop
319    ICON_2 ICON_MESSAGE_CRITICAL_SMALL    '@8N@'."  Stop
320    ICON_2 ICON_MESSAGE_ERROR_SMALL       '@8O@'."  Stop
321    ICON_2 ICON_MESSAGE_INFORMATION_SMALL '@8P@'."  Stop
322    ICON_2 ICON_MESSAGE_QUESTION_SMALL    '@8Q@'."  Stop
323    ICON_2 ICON_MESSAGE_WARNING_SMALL     '@8R@'."  Stop
324    ICON_2 ICON_URL                       '@8S@'."  Stop
325    ICON_2 ICON_SYSTEM_SHORTCUT           '@8T@'."  Stop
326    ICON_2 ICON_PLANNING_IN               '@8U@'."  Stop
327    ICON_2 ICON_PLANNING_OUT              '@8V@'."  Stop
328    ICON_2 ICON_SUBMIT                    '@8W@'."  Stop
329    ICON_2 ICON_ALLOW                     '@8X@'."  Stop
330    ICON_2 ICON_REJECT                    '@8Y@'."  Stop
331    ICON_2 ICON_SIMULATE                  '@8Z@'."  Stop
332    ICON_2 ICON_TE_RECEIPTS               '@90@'."  Stop
333    ICON_2 ICON_TE_STOPOVER               '@91@'."  Stop
334    ICON_2 ICON_TE_KM_DIVISION            '@92@'."  Stop
335    ICON_2 ICON_TE_ADVANCE_PAYMENT        '@93@'."  Stop
336    ICON_2 ICON_TE_DEDUCTION              '@94@'."  Stop
337    ICON_2 ICON_TE_COSTS_ASSIGN           '@95@'."  Stop
338    ICON_2 ICON_HISTORY                   '@96@'."  Stop
339    ICON_2 ICON_MODIFICATION_CREATE       '@97@'."  Stop
340    ICON_2 ICON_MODIFICATION_OVERVIEW     '@98@'."  Stop
341    ICON_2 ICON_MODIFICATION_ORIGINAL     '@99@'."  Stop
342    ICON_2 ICON_MODIFICATION_RESET        '@9A@'."  Stop
343    ICON_2 ICON_ACTIVE_INACTIVE           '@9B@'."  Stop
344    ICON_2 ICON_BEN_OFFER                 '@9C@'."  Stop
345    ICON_2 ICON_BEN_OFFER_DEFAULT         '@9D@'."  Stop
346    ICON_2 ICON_BEN_OFFER_EVENT           '@9E@'."  Stop
347    ICON_2 ICON_BEN_OFFER_OPEN            '@9F@'."  Stop
348    ICON_2 ICON_BEN_WAIVE_COVERAGE        '@9G@'."  Stop
349    ICON_2 ICON_DEPENDENTS                '@9H@'."  Stop
350    ICON_2 ICON_BEN_CURRENT_BENEFITS      '@9I@'."  Stop
351    ICON_2 ICON_BEN_TERMINATION           '@9J@'."  Stop
352    ICON_2 ICON_WS_TRANSPORT              '@9K@'."  Stop
353    ICON_2 ICON_ODS_ACT                   '@9L@'."  Stop
354    ICON_2 ICON_ODS_INA                   '@9M@'."  Stop
355    ICON_2 ICON_BIW_INFO_PACKAGE          '@9N@'."  Stop
356    ICON_2 ICON_ACTION_FAULT              '@9O@'."  Stop
357    ICON_2 ICON_ACTION_SUCCESS            '@9P@'."  Stop
358    ICON_2 ICON_DIMENSION                 '@9Q@'."  Stop
359    ICON_2 ICON_TIME_INA                  '@9R@'."  Stop
360    ICON_2 ICON_ARROW_LEFT                '@9S@'."  Stop
361    ICON_2 ICON_ARROW_RIGHT               '@9T@'."  Stop
362    ICON_2 ICON_ABAP                      '@9U@'."  Stop
363    ICON_2 ICON_ABAP_LOCAL                '@9V@'."  Stop
364    ICON_2 ICON_TRANSFER_STRUCTURE        '@9W@'."  Stop
365    ICON_2 ICON_OPERATION                 '@9X@'."  Stop
366    ICON_2 ICON_ACTIVITY                  '@9Y@'."  Stop
367    ICON_2 ICON_ORDER                     '@9Z@'."  Stop
368    ICON_2 ICON_CUSTOMER                  '@A0@'."  Stop
369    ICON_2 ICON_WAREHOUSE                 '@A1@'."  Stop
370    ICON_2 ICON_DISPO_LEVEL               '@A2@'."  Stop
371    ICON_2 ICON_DISTRIBUTION              '@A3@'."  Stop
372    ICON_2 ICON_CUSTOMER_WAREHOUSE        '@A4@'."  Stop
373    ICON_2 ICON_TRANSPORT_POINT           '@A5@'."  Stop
374    ICON_2 ICON_MATERIAL                  '@A6@'."  Stop
375    ICON_2 ICON_MODEL                     '@A7@'."  Stop
376    ICON_2 ICON_PLANT                     '@A8@'."  Stop
377    ICON_2 ICON_PRODUCT_GROUP             '@A9@'."  Stop
378    ICON_2 ICON_RELATIONSHIP              '@AA@'."  Stop
379    ICON_2 ICON_RESOURCE                  '@AB@'."  Stop
380    ICON_2 ICON_STORE_LOCATION            '@AC@'."  Stop
381    ICON_2 ICON_SUPPLIER                  '@AD@'."  Stop
382    ICON_2 ICON_TRANSPORTATION_MODE       '@AE@'."  Stop
383    ICON_2 ICON_LOCATION                  '@AF@'."  Stop
384    ICON_2 ICON_ALERT                     '@AG@'."  Stop
385    ICON_2 ICON_WARNING                   '@AH@'."  Stop
386    ICON_2 ICON_HINT                      '@AI@'."  Stop
387    ICON_2 ICON_WORKING_PLAN              '@AJ@'."  Stop
388    ICON_2 ICON_MAINTENANCE_PLAN          '@AK@'."  Stop
389    ICON_2 ICON_REPORT                    '@AL@'."  Stop
390    ICON_2 ICON_WORKPLACE                 '@AM@'."  Stop
391    ICON_2 ICON_EQUIPMENT                 '@AN@'."  Stop
392    ICON_2 ICON_TECHNICAL_PLACE           '@AO@'."  Stop
393    ICON_2 ICON_BOM                       '@AP@'."  Stop
394    ICON_2 ICON_BOM_ITEM                  '@AQ@'."  Stop
395    ICON_2 ICON_DOCUMENT                  '@AR@'."  Stop
396    ICON_2 ICON_DOCUMENT_REVISION         '@AS@'."  Stop
397    ICON_2 ICON_MATERIAL_REVISION         '@AT@'."  Stop
398    ICON_2 ICON_CHANGE_NUMBER             '@AU@'."  Stop
399    ICON_2 ICON_FLIGHT                    '@AV@'."  Stop
400    ICON_2 ICON_CAR                       '@AW@'."  Stop
401    ICON_2 ICON_HOTEL                     '@AX@'."  Stop
402    ICON_2 ICON_RAILWAY                   '@AY@'."  Stop
403    ICON_2 ICON_MONEY                     '@AZ@'."  Stop
404    ICON_2 ICON_QUESTION                  '@B0@'."  Stop
405    ICON_2 ICON_BOOKING_OK                '@B1@'."  Stop
406    ICON_2 ICON_BOOKING_STOP              '@B2@'."  Stop
407    ICON_2 ICON_STATUS_OPEN               '@B3@'."  Stop
408    ICON_2 ICON_STATUS_BOOKED             '@B4@'."  Stop
409    ICON_2 ICON_STATUS_PARTLY_BOOKED      '@B5@'."  Stop
410    ICON_2 ICON_STATUS_REVERSE            '@B6@'."  Stop
411    ICON_2 ICON_PREFERENCE                '@B7@'."  Stop
412    ICON_2 ICON_NEXT_STEP                 '@B8@'."  Stop
413    ICON_2 ICON_PREVIOUS_STEP             '@B9@'."  Stop
414    ICON_2 ICON_STORNO                    '@BA@'."  Stop
415    ICON_2 ICON_INTERCHANGE               '@BB@'."  Stop
416    ICON_2 ICON_CASHING_UP                '@BC@'."  Stop
417    ICON_2 ICON_WORKLOAD                  '@BD@'."  Stop
418    ICON_2 ICON_PROPOSITION               '@BE@'."  Stop
419    ICON_2 ICON_PRESENCE                  '@BF@'."  Stop
420    ICON_2 ICON_ABSENCE                   '@BG@'."  Stop
421    ICON_2 ICON_TIME_CONTROL              '@BH@'."  Stop
422    ICON_2 ICON_POSITION_HR               '@BI@'."  Stop
423    ICON_2 ICON_PARAMETER_TABLE           '@BJ@'."  Stop
424    ICON_2 ICON_TASK                      '@BK@'."  Stop
425    ICON_2 ICON_COST_CENTER               '@BL@'."  Stop
426    ICON_2 ICON_MANAGER                   '@BM@'."  Stop
427    ICON_2 ICON_ORG_UNIT                  '@BN@'."  Stop
428    ICON_2 ICON_QUERY                     '@BO@'."  Stop
429    ICON_2 ICON_WORKFLOW_INBOX            '@BP@'."  Stop
430    ICON_2 ICON_FAST_ENTRY                '@BQ@'."  Stop
431    ICON_2 ICON_LIFE_EVENTS               '@BR@'."  Stop
432    ICON_2 ICON_WORK_CENTER               '@BS@'."  Stop
433    ICON_2 ICON_GRADUATE                  '@BT@'."  Stop
434    ICON_2 ICON_EXTRA                     '@BU@'."  Stop
435    ICON_2 ICON_CONVERT_ALL               '@BV@'."  Stop
436    ICON_2 ICON_RELATION                  '@BW@'."  Stop
437    ICON_2 ICON_CONFIGURATION             '@BX@'."  Stop
438    ICON_2 ICON_WIZARD                    '@BY@'."  Stop
439    ICON_2 ICON_LED_INACTIVE              '@BZ@'."  Stop
440    ICON_2 ICON_STORE                     '@C0@'."  Stop
441    ICON_2 ICON_LINK                      '@C1@'."  Stop
442    ICON_2 ICON_LATE_STORE                '@C2@'."  Stop
443    ICON_2 ICON_LATE_LINK                 '@C3@'."  Stop
444    ICON_2 ICON_EARLY_STORE               '@C4@'."  Stop
445    ICON_2 ICON_EARLY_LINK                '@C5@'."  Stop
446    ICON_2 ICON_OO_CLASS_EVENT            '@C6@'."  Stop
447    ICON_2 ICON_OO_INST_EVENT             '@C7@'."  Stop
448    ICON_2 ICON_OO_ALIAS                  '@C8@'."  Stop
449    ICON_2 ICON_OO_OBJECT                 '@C9@'."  Stop
450    ICON_2 ICON_JOB                       '@CA@'."  Stop
451    ICON_2 ICON_DELIVERY_DATE             '@CB@'."  Stop
452    ICON_2 ICON_DELIVERY_COMPLETE         '@CC@'."  Stop
453    ICON_2 ICON_DELIVERY_PROPOSAL         '@CD@'."  Stop
454    ICON_2 ICON_PDIR_BACK_SWITCH          '@CE@'."  Stop
455    ICON_2 ICON_PDIR_BACK                 '@CF@'."  Stop
456    ICON_2 ICON_PDIR_FOREWARD             '@CG@'."  Stop
457    ICON_2 ICON_PDIR_FOREWARD_SWITCH      '@CH@'."  Stop
458    ICON_2 ICON_FINITE                    '@CI@'."  Stop
459    ICON_2 ICON_NONWORK                   '@CJ@'."  Stop
460    ICON_2 ICON_PM_FREE                   '@CK@'."  Stop
461    ICON_2 ICON_PM_INSERT                 '@CL@'."  Stop
462    ICON_2 ICON_PM_PRESS                  '@CM@'."  Stop
463    ICON_2 ICON_PM_ORDER                  '@CN@'."  Stop
464    ICON_2 ICON_DANGEROUS_GOOD_CHECK      '@CO@'."  Stop
465    ICON_2 ICON_WORKFLOW_DOC_CREATE       '@CP@'."  Stop
466    ICON_2 ICON_WF_LINK                   '@CQ@'."  Stop
467    ICON_2 ICON_WF_UNLINK                 '@CR@'."  Stop
468    ICON_2 ICON_WF_WORKITEM_READY         '@CS@'."  Stop
469    ICON_2 ICON_WF_WORKITEM_RESERVED      '@CT@'."  Stop
470    ICON_2 ICON_WF_WORKITEM_STARTED       '@CU@'."  Stop
471    ICON_2 ICON_WF_WORKITEM_COMMITTED     '@CV@'."  Stop
472    ICON_2 ICON_WF_WORKITEM_WAITING       '@CW@'."  Stop
473    ICON_2 ICON_WF_WORKITEM_COMPLETED     '@CX@'."  Stop
474    ICON_2 ICON_WF_WORKITEM_ERROR         '@CY@'."  Stop
475    ICON_2 ICON_WF_WORKITEM_CANCEL        '@CZ@'."  Stop
476    ICON_2 ICON_WF_RESERVE_WORKITEM       '@D0@'."  Stop
477    ICON_2 ICON_WF_REPLACE_WORKITEM       '@D1@'."  Stop
478    ICON_2 ICON_PROFIT_CENTER             '@D2@'."  Stop
479    ICON_2 ICON_WF_RULE_SYSTEM            '@D3@'."  Stop
480    ICON_2 ICON_WF_PARAMETER              '@D4@'."  Stop
481    ICON_2 ICON_JAPAN                     '@D5@'."  Stop
482    ICON_2 ICON_SLS                       '@D6@'."  Stop
483    ICON_2 ICON_CUSTOMS                   '@D7@'."  Stop
484    ICON_2 ICON_LEGAL_REG                 '@D8@'."  Stop
485    ICON_2 ICON_COMPANY_CODE              '@D9@'."  Stop
486    ICON_2 ICON_UNIT_COSTING              '@DA@'."  Stop
487    ICON_2 ICON_BASE_PLANNING_OBJECT      '@DB@'."  Stop
488    ICON_2 ICON_ACTIVITY_TYPE             '@DC@'."  Stop
489    ICON_2 ICON_RENTAL_AGREEMENT          '@DD@'."  Stop
490    ICON_2 ICON_REAL_ESTATE_OBJECT        '@DE@'."  Stop
491    ICON_2 ICON_COMPLETE                  '@DF@'."  Stop
492    ICON_2 ICON_PARTNER                   '@DG@'."  Stop
493    ICON_2 ICON_PROTOCOL                  '@DH@'."  Stop
494    ICON_2 ICON_MAINTENANCE_OBJECT_LIST   '@DI@'."  Stop
495    ICON_2 ICON_XXL                       '@DJ@'."  Stop
496    ICON_2 ICON_WORD_PROCESSING           '@DK@'."  Stop
497    ICON_2 ICON_ABC                       '@DL@'."  Stop
498    ICON_2 ICON_ALV_VARIANT_CHOOSE        '@DM@'."  Stop
499    ICON_2 ICON_ALV_VARIANT_SAVE          '@DN@'."  Stop
500    ICON_2 ICON_EXCLUDED_CORRESPONDENCE   '@DO@'."  Stop
501    ICON_2 ICON_INCREASE_DECIMAL          '@DP@'."  Stop
502    ICON_2 ICON_DECREASE_DECIMAL          '@DQ@'."  Stop
503    ICON_2 ICON_ERROR_PROTOCOL            '@DR@'."  Stop
504    ICON_2 ICON_PARTNER_SALES_ACTIVITY    '@DS@'."  Stop
505    ICON_2 ICON_PHONE_CALL_IN             '@DT@'."  Stop
506    ICON_2 ICON_NAFTA                     '@DU@'."  Stop
507    ICON_2 ICON_EU                        '@DV@'."  Stop
508    ICON_2 ICON_PHONE_CALL_OUT            '@DW@'."  Stop
509    ICON_2 ICON_CONTROLLING_AREA          '@DX@'."  Stop
510    ICON_2 ICON_DISTRIBUTION_LIST         '@DY@'."  Stop
511    ICON_2 ICON_MAIL_SAP_UNREAD           '@DZ@'."  Stop
512    ICON_2 ICON_MAIL_SAP_READ             '@E0@'."  Stop
513    ICON_2 ICON_ENVELOPE_OPEN             '@E1@'."  Stop
514    ICON_2 ICON_ENVELOPE_CLOSED           '@E2@'."  Stop
515    ICON_2 ICON_OFFICE_DOCUMENT           '@E3@'."  Stop
516    ICON_4 ICON_INCLUDE_IN_SELECTION      '@E4@'."  Stop
517    ICON_2 ICON_WF_WORKITEM_OL            '@E5@'."  Stop
518    ICON_2 ICON_NEW_HANDLING_UNIT         '@E6@'."  Stop
519    ICON_2 ICON_NEW_HANDLING_IF_FULL      '@E7@'."  Stop
520    ICON_2 ICON_PACKING                   '@E8@'."  Stop
521    ICON_2 ICON_UNPACK                    '@E9@'."  Stop
522    ICON_2 ICON_EMPTY_HANDLING_UNIT       '@EA@'."  Stop
523    ICON_4 ICON_LIGHT_OUT                 '@EB@'."  Stop
524    ICON_2 ICON_PS_PROJECT_DEFINITION     '@EC@'."  Stop
525    ICON_2 ICON_PS_WBS_ELEMENT            '@ED@'."  Stop
526    ICON_2 ICON_PS_NETWORK_HEADER         '@EE@'."  Stop
527    ICON_2 ICON_PS_NETWORK_ACTIVITY       '@EF@'."  Stop
528    ICON_2 ICON_PS_ACTIVITY_ELEMENT       '@EG@'."  Stop
529    ICON_2 ICON_PS_RELATIONSHIP           '@EH@'."  Stop
530    ICON_2 ICON_STATUS                    '@EI@'."  Stop
531    ICON_2 ICON_BATCH                     '@EJ@'."  Stop
532    ICON_2 ICON_ADMINISTRATIVE_DATA       '@EK@'."  Stop
533    ICON_2 ICON_STOCK                     '@EL@'."  Stop
534    ICON_2 ICON_ACCOUNT_ASSIGNMENT        '@EM@'."  Stop
535    ICON_2 ICON_LOT_ORIGIN                '@EN@'."  Stop
536    ICON_2 ICON_INSPECTION_LOT            '@EO@'."  Stop
537    ICON_2 ICON_SHOW_EXTERNAL_JOBS        '@EP@'."  Stop
538    ICON_2 ICON_SPOOL_REQUEST             '@EQ@'."  Stop
539    ICON_2 ICON_OUTPUT_REQUEST            '@ER@'."  Stop
540    ICON_2 ICON_DELETE_FAVORITES          '@ES@'."  Stop
541    ICON_2 ICON_SHOW_EVENTS               '@ET@'."  Stop
542    ICON_2 ICON_SPOOL_STATUS              '@EU@'."  Stop
543    ICON_2 ICON_INSERT_FAVORITES          '@EV@'."  Stop
544    ICON_2 ICON_PRINT_WITH_PARAMETERS     '@EW@'."  Stop
545    ICON_2 ICON_USED_RELATION             '@EX@'."  Stop
546    ICON_2 ICON_MAPPED_RELATION           '@EY@'."  Stop
547    ICON_2 ICON_CREATE_COPY               '@EZ@'."  Stop
548    ICON_2 ICON_FLUSH                     '@F0@'."  Stop
549    ICON_2 ICON_DEFECT                    '@F1@'."  Stop
550    ICON_2 ICON_BW_GIS                    '@F2@'."  Stop
551    ICON_2 ICON_BW_INFO_CUBE_SAP          '@F3@'."  Stop
552    ICON_2 ICON_BW_INFO_CUBE_INA          '@F4@'."  Stop
553    ICON_2 ICON_BW_INFO_OBJECT_CATALOGUE  '@F5@'."  Stop
554    ICON_2 ICON_BW_SUGGEST_VALUE          '@F6@'."  Stop
555    ICON_2 ICON_DOC_POSITION_PROPOSAL     '@F7@'."  Stop
556    ICON_2 ICON_CUSTOMER_MASTER_DATA_LIST '@F8@'."  Stop
557    ICON_2 ICON_STATUS_OVERVIEW           '@F9@'."  Stop
558    ICON_2 ICON_DOC_HEADER_DETAIL         '@FA@'."  Stop
559    ICON_2 ICON_DOC_ITEM_DETAIL           '@FB@'."  Stop
560    ICON_2 ICON_AVAILABILITY_CHECK        '@FC@'."  Stop
561    ICON_2 ICON_PRICE                     '@FD@'."  Stop
562    ICON_2 ICON_SCHEDULE_LINE             '@FE@'."  Stop
563    ICON_2 ICON_AVAILABILITY_DISPLAY      '@FF@'."  Stop
564    ICON_2 ICON_STATISTICS                '@FG@'."  Stop
565    ICON_2 ICON_CLAIM                     '@FH@'."  Stop
566    ICON_2 ICON_PLANNING_SITUATION        '@FI@'."  Stop
567    ICON_2 ICON_CHANGE_ORDER              '@FJ@'."  Stop
568    ICON_2 ICON_PRODUCT_REQUIREMENTS      '@FK@'."  Stop
569    ICON_2 ICON_PRODUCT_RECEIPTS          '@FL@'."  Stop
570    ICON_2 ICON_ATTACHMENT                '@FM@'."  Stop
571    ICON_2 ICON_CLOSED_FOLDER             '@FN@'."  Stop
572    ICON_2 ICON_OPEN_FOLDER               '@FO@'."  Stop
573    ICON_2 ICON_OBJECT_FOLDER             '@FP@'."  Stop
574    ICON_2 ICON_OUTBOX                    '@FQ@'."  Stop
575    ICON_2 ICON_RESUBMISSION              '@FR@'."  Stop
576    ICON_2 ICON_PRIVATE_FILES             '@FS@'."  Stop
577    ICON_2 ICON_PUBLIC_FILES              '@FT@'."  Stop
578    ICON_2 ICON_SUBSCRIPTION              '@FU@'."  Stop
579    ICON_2 ICON_AVERAGE                   '@FV@'."  Stop
580    ICON_2 ICON_BOLD                      '@FW@'."  Stop
581    ICON_2 ICON_ITALIC                    '@FX@'."  Stop
582    ICON_2 ICON_UNDERLINE                 '@FY@'."  Stop
583    ICON_2 ICON_ALIGN_LEFT                '@FZ@'."  Stop
584    ICON_2 ICON_ALIGN_RIGHT               '@G0@'."  Stop
585    ICON_2 ICON_ALIGN_CENTER              '@G1@'."  Stop
586    ICON_2 ICON_JUSTIFIED                 '@G2@'."  Stop
587    ICON_2 ICON_COLOR                     '@G3@'."  Stop
588    ICON_2 ICON_DELETE_ALL_ATTRIBUTES     '@G4@'."  Stop
589    ICON_2 ICON_IDOC                      '@G5@'."  Stop
590    ICON_2 ICON_HOST                      '@G6@'."  Stop
591    ICON_2 ICON_SYM_SPOOL_SERVER          '@G7@'."  Stop
592    ICON_2 ICON_SYM_REAL_SERVER           '@G8@'."  Stop
593    ICON_2 ICON_SYM_LOG_SERVER            '@G9@'."  Stop
594    ICON_2 ICON_SYM_ALT_SERVER            '@GA@'."  Stop
595    ICON_2 ICON_CONNECT                   '@GB@'."  Stop
596    ICON_2 ICON_DISCONNECT                '@GC@'."  Stop
597    ICON_2 ICON_FILTER_UNDO               '@GD@'."  Stop
598    ICON_2 ICON_SET_SUM_UNDO              '@GE@'."  Stop
599    ICON_2 ICON_INTENSIFY_UNDO            '@GF@'."  Stop
600    ICON_2 ICON_SORT_UNDO                 '@GG@'."  Stop
601    ICON_2 ICON_BW_DATA_MARTS             '@GH@'."  Stop
602    ICON_4 ICON_REMOVE_FROM_SELECTION     '@GI@'."  Stop
603    ICON_2 ICON_BW_CHARACTERISTICS_SAP    '@GJ@'."  Stop
604    ICON_2 ICON_BW_KEYFIGURE_SAP          '@GK@'."  Stop
605    ICON_2 ICON_BW_INFO_OBJECT_UNITS_SAP  '@GL@'."  Stop
606    ICON_2 ICON_BW_TIME_SAP               '@GM@'."  Stop
607    ICON_2 ICON_BW_RULES_SAP              '@GN@'."  Stop
608    ICON_2 ICON_BW_REPORT_SAP             '@GO@'."  Stop
609    ICON_2 ICON_BW_VARIABLE_SAP           '@GP@'."  Stop
610    ICON_2 ICON_BW_REF_STRUCTURE_SAP      '@GQ@'."  Stop
611    ICON_2 ICON_BW_SELECTION_SAP          '@GR@'."  Stop
612    ICON_2 ICON_INSPECTION_METHOD         '@GS@'."  Stop
613    ICON_2 ICON_CATALOG                   '@GT@'."  Stop
614    ICON_2 ICON_INSERT_MULTIPLE_LINES     '@GU@'."  Stop
615    ICON_2 ICON_INSPECTION_CHARACTERISTIC '@GV@'."  Stop
616    ICON_2 ICON_PHYSICAL_SAMPLE           '@GW@'."  Stop
617    ICON_2 ICON_BW_FORMULA_SAP            '@GX@'."  Stop
618    ICON_2 ICON_BW_INFO_CATALOGUE_SAP     '@GY@'."  Stop
619    ICON_2 ICON_BUDGET_STRUCTURE_ELEMENT  '@GZ@'."  Stop
620    ICON_2 ICON_FINANCING                 '@H0@'."  Stop
621    ICON_2 ICON_RECLASSIFICATION_RULE     '@H1@'."  Stop
622    ICON_2 ICON_RECLASSIFICATION          '@H2@'."  Stop
623    ICON_2 ICON_REMOVE                    '@H3@'."  Stop
624    ICON_2 ICON_SPECIAL_PURPOSE           '@H4@'."  Stop
625    ICON_2 ICON_DEPUTY                    '@H5@'."  Stop
626    ICON_2 ICON_BUDGET_UPDATE             '@H6@'."  Stop
627    ICON_2 ICON_BUDGET_TRANSFER           '@H7@'."  Stop
628    ICON_2 ICON_BW_SEGMENT_ACT            '@H8@'."  Stop
629    ICON_2 ICON_BW_SEGMENT_INA            '@H9@'."  Stop
630    ICON_2 ICON_BW_SEGMENT_SAP            '@HA@'."  Stop
631    ICON_2 ICON_MASS_CHANGE               '@HB@'."  Stop
632    ICON_2 ICON_INTENSIFY_CRITICAL        '@HC@'."  Stop
633    ICON_2 ICON_INTENSIFY_UNCRITICAL      '@HD@'."  Stop
634    ICON_2 ICON_CHOOSE_COLUMNS            '@HE@'."  Stop
635    ICON_2 ICON_TOTAL_UP                  '@HF@'."  Stop
636    ICON_2 ICON_TOTAL_DOWN                '@HG@'."  Stop
637    ICON_2 ICON_PAGE_UP                   '@HH@'."  Stop
638    ICON_2 ICON_PAGE_DOWN                 '@HI@'."  Stop
639    ICON_2 ICON_READ_FILE                 '@HJ@'."  Stop
640    ICON_2 ICON_WRITE_FILE                '@HK@'."  Stop
641    ICON_2 ICON_EDIT_FILE                 '@HL@'."  Stop
642    ICON_2 ICON_PS_MILESTONE              '@HM@'."  Stop
643    ICON_2 ICON_PS_PROJECT_TEXT           '@HN@'."  Stop
644    ICON_2 ICON_ELEMENT                   '@HO@'."  Stop
645    ICON_2 ICON_STRUCTURE                 '@HP@'."  Stop
646    ICON_2 ICON_WS_WHSE_STOCK             '@HQ@'."  Stop
647    ICON_2 ICON_ROUTING                   '@HR@'."  Stop
648    ICON_2 ICON_MATERIAL_ROUTING_ALLOC    '@HS@'."  Stop
649    ICON_2 ICON_ROUTING_SUB_OPERATION     '@HT@'."  Stop
650    ICON_2 ICON_ROUTING_REF_SUB_OPERATION '@HU@'."  Stop
651    ICON_2 ICON_ROUTING_SEQUENCE          '@HV@'."  Stop
652    ICON_2 ICON_BOM_SUB_ITEM              '@HW@'."  Stop
653    ICON_2 ICON_EFFECTIVITY_PERIOD        '@HX@'."  Stop
654    ICON_2 ICON_KEY_DATE                  '@HY@'."  Stop
655    ICON_2 ICON_SELECTION_PERIOD          '@HZ@'."  Stop
656    ICON_2 ICON_EFF                       '@I0@'."  Stop
657    ICON_2 ICON_SUPPLY_AREA               '@I1@'."  Stop
658    ICON_2 ICON_REPORT_CALL               '@I2@'."  Stop
659    ICON_2 ICON_ASSIGN                    '@I3@'."  Stop
660    ICON_2 ICON_UNASSIGN                  '@I4@'."  Stop
661    ICON_2 ICON_SYSTEM_START_RECORDING    '@I5@'."  Stop
662    ICON_2 ICON_SYSTEM_PLAY               '@I6@'."  Stop
663    ICON_2 ICON_TRANSLATION               '@I7@'."  Stop
664    ICON_2 ICON_TRANSLATION_SHOW          '@I8@'."  Stop
665    ICON_2 ICON_CHANGE_PASSWORD           '@I9@'."  Stop
666    ICON_2 ICON_DISTRIBUTE                '@IA@'."  Stop
667    ICON_2 ICON_SYSTEMS                   '@IB@'."  Stop
668    ICON_2 ICON_ACTIVITY_GROUP            '@IC@'."  Stop
669    ICON_2 ICON_USERGROUP                 '@ID@'."  Stop
670    ICON_2 ICON_UNLINK                    '@IE@'."  Stop
671    ICON_2 ICON_CONTENT_OBJECT            '@IF@'."  Stop
672    ICON_2 ICON_OBJECT_LIST               '@IG@'."  Stop
673    ICON_2 ICON_FOLDER                    '@IH@'."  Stop
674    ICON_2 ICON_DIFFERENCE                '@II@'."  Stop
675    ICON_2 ICON_DIFFERENCE_BACK           '@IJ@'."  Stop
676    ICON_2 ICON_SYSTEM_DESELECT           '@IK@'."  Stop
677    ICON_2 ICON_ADOPT                     '@IL@'."  Stop
678    ICON_2 ICON_TERMINOLOGY               '@IM@'."  Stop
679    ICON_2 ICON_TRIANGULAR_RELATIONSHIP   '@IN@'."  Stop
680    ICON_2 ICON_AEW_PROJECT               '@IO@'."  Stop
681    ICON_2 ICON_SICKNESS                  '@IP@'."  Stop
682    ICON_2 ICON_HOLIDAY                   '@IQ@'."  Stop
683    ICON_2 ICON_ROLE                      '@IR@'."  Stop
684    ICON_2 ICON_PERSONNEL_ADMINISTRATION  '@IS@'."  Stop
685    ICON_2 ICON_PDF                       '@IT@'."  Stop
686    ICON_2 ICON_BMP                       '@IU@'."  Stop
687    ICON_2 ICON_FAX_DOC                   '@IV@'."  Stop
688    ICON_2 ICON_GIF                       '@IW@'."  Stop
689    ICON_2 ICON_HLP                       '@IX@'."  Stop
690    ICON_2 ICON_HTT                       '@IY@'."  Stop
691    ICON_2 ICON_ITS                       '@IZ@'."  Stop
692    ICON_2 ICON_JPG                       '@J0@'."  Stop
693    ICON_2 ICON_MSG                       '@J1@'."  Stop
694    ICON_2 ICON_XLS                       '@J2@'."  Stop
695    ICON_2 ICON_XLV                       '@J3@'."  Stop
696    ICON_2 ICON_HTM                       '@J4@'."  Stop
697    ICON_2 ICON_PPT                       '@J5@'."  Stop
698    ICON_2 ICON_DOT                       '@J6@'."  Stop
699    ICON_2 ICON_DOC                       '@J7@'."  Stop
700    ICON_2 ICON_EML                       '@J8@'."  Stop
701    ICON_2 ICON_RTF                       '@J9@'."  Stop
702    ICON_2 ICON_TIF                       '@JA@'."  Stop
703    ICON_2 ICON_WRI                       '@JB@'."  Stop
704    ICON_2 ICON_LWP                       '@JC@'."  Stop
705    ICON_2 ICON_LOTUS                     '@JD@'."  Stop
706    ICON_2 ICON_VSD                       '@JE@'."  Stop
707    ICON_2 ICON_DEFAULT_WINDOWS           '@JF@'."  Stop
708    ICON_2 ICON_DISPLAY_TREE              '@JG@'."  Stop
709    ICON_2 ICON_EXTENDED_SEARCH           '@JH@'."  Stop
710    ICON_2 ICON_CLOSE_OBJECT              '@JI@'."  Stop
711    ICON_2 ICON_OPEN                      '@JJ@'."  Stop
712    ICON_2 ICON_POLICY                    '@JK@'."  Stop
713    ICON_2 ICON_PAYMENT                   '@JL@'."  Stop
714    ICON_2 ICON_CATASTROPHE               '@JM@'."  Stop
715    ICON_2 ICON_AGGREGATE                 '@JN@'."  Stop
716    ICON_2 ICON_SUBCLAIM_PERSONAL_INJURY  '@JO@'."  Stop
717    ICON_2 ICON_SUB_INTELLECTUAL_PROPERTY '@JP@'."  Stop
718    ICON_2 ICON_SUBCLAIM_VEHICLE          '@JQ@'."  Stop
719    ICON_2 ICON_SUB_PERSONAL_PROPERTY     '@JR@'."  Stop
720    ICON_2 ICON_SUBCLAIM_BUILDING         '@JS@'."  Stop
721    ICON_2 ICON_SUB_BODILY_INJURY_TREAT   '@JT@'."  Stop
722    ICON_2 ICON_SUBCLAIM_BODILY_INJURY    '@JU@'."  Stop
723    ICON_2 ICON_SUB_ENVRONMENTAL_SITE     '@JV@'."  Stop
724    ICON_2 ICON_SUB_FINANCIAL_IMPAIRMENT  '@JW@'."  Stop
725    ICON_2 ICON_BW_PROCESS                '@JX@'."  Stop
726    ICON_2 ICON_BW_SIMULATE               '@JY@'."  Stop
727    ICON_2 ICON_BW_PROCESS_CANCEL         '@JZ@'."  Stop
728    ICON_2 ICON_BW_SIMULATE_CANCEL        '@K0@'."  Stop
729    ICON_2 ICON_DATA_AREA_EXPAND          '@K1@'."  Stop
730    ICON_2 ICON_DATA_AREA_COLLAPSE        '@K2@'."  Stop
731    ICON_2 ICON_SCRAP                     '@K3@'."  Stop
732    ICON_2 ICON_IMPORT_ALL_REQUESTS       '@K4@'."  Stop
733    ICON_2 ICON_IMPORT_TRANSPORT_REQUEST  '@K5@'."  Stop
734    ICON_2 ICON_TOGGLE_DISPLAY            '@K6@'."  Stop
735    ICON_2 ICON_TOGGLE_FUNCTION           '@K7@'."  Stop
736    ICON_2 ICON_PERSONAL_SETTINGS         '@K8@'."  Stop
737    ICON_2 ICON_PROJECT                   '@K9@'."  Stop
738    ICON_2 ICON_INCLUDE_OBJECTS           '@KA@'."  Stop
739    ICON_2 ICON_TRANSFER                  '@KB@'."  Stop
740    ICON_2 ICON_DISTRIBUTE_CONFIGURATION  '@KC@'."  Stop
741    ICON_2 ICON_ADJUST_CONFIGURATION      '@KD@'."  Stop
742    ICON_2 ICON_STANDARD_CONFIGURATION    '@KE@'."  Stop
743    ICON_2 ICON_MODIFIED_OBJECT           '@KF@'."  Stop
744    ICON_2 ICON_SELECT_WITH_CONDITION     '@KG@'."  Stop
745    ICON_2 ICON_ADDRESS_LIST              '@KH@'."  Stop
746    ICON_2 ICON_APPOINTMENT_COMPARISON    '@KI@'."  Stop
747    ICON_2 ICON_BUSINESS_PARTNER_MASTER_D '@KJ@'."  Stop
748    ICON_2 ICON_INCOMPLETION_LOG          '@KK@'."  Stop
749    ICON_2 ICON_MESSAGE                   '@KL@'."  Stop
750    ICON_2 ICON_TELEPHONE_CALL            '@KM@'."  Stop
751    ICON_2 ICON_VISIT                     '@KN@'."  Stop
752    ICON_2 ICON_LETTER                    '@KO@'."  Stop
753    ICON_2 ICON_OPERATOR                  '@KP@'."  Stop
754    ICON_2 ICON_SYSTEM_ADMINISTRATOR      '@KQ@'."  Stop
755    ICON_2 ICON_SAP                       '@KR@'."  Stop
756    ICON_2 ICON_PUBLIC                    '@KS@'."  Stop
757    ICON_2 ICON_SUMMARIZE                 '@KT@'."  Stop
758    ICON_2 ICON_SUMMARIZE_UNDO            '@KU@'."  Stop
759    ICON_2 ICON_SUM_RED                   '@KV@'."  Stop
760    ICON_2 ICON_UNSPECIFIED_ONE           '@KW@'."  Stop
761    ICON_2 ICON_UNSPECIFIED_TWO           '@KX@'."  Stop
762    ICON_2 ICON_UNSPECIFIED_THREE         '@KY@'."  Stop
763    ICON_2 ICON_UNSPECIFIED_FOUR          '@KZ@'."  Stop
764    ICON_2 ICON_UNSPECIFIED_FIVE          '@L0@'."  Stop
765    ICON_2 ICON_HR_MANAGER                '@L1@'."  Stop
766    ICON_2 ICON_TBH                       '@L2@'."  Stop
767    ICON_2 ICON_TBH_HOLD                  '@L3@'."  Stop
768    ICON_2 ICON_NEW_EMPLOYEE              '@L4@'."  Stop
769    ICON_2 ICON_INCOMING_EMPLOYEE         '@L5@'."  Stop
770    ICON_2 ICON_OUTGOING_EMPLOYEE         '@L6@'."  Stop
771    ICON_2 ICON_OBSOLETE_POSITION         '@L7@'."  Stop
772    ICON_2 ICON_TERMINATED_POSITION       '@L8@'."  Stop
773    ICON_2 ICON_SHARED_POSITION           '@L9@'."  Stop
774    ICON_2 ICON_OBSOLETE_SHARED_POSITION  '@LA@'."  Stop
775    ICON_2 ICON_TERMINATED_SHARED_POSITIO '@LB@'."  Stop
776    ICON_2 ICON_HR_POSITION               '@LC@'."  Stop
777    ICON_2 ICON_CREATE_POSITION           '@LD@'."  Stop
778    ICON_2 ICON_HR_ORG_UNIT               '@LE@'."  Stop
779    ICON_2 ICON_TERMINATED_ORG_UNIT       '@LF@'."  Stop
780    ICON_2 ICON_NEW_ORG_UNIT              '@LG@'."  Stop
781    ICON_2 ICON_OUTGOING_ORG_UNIT         '@LH@'."  Stop
782    ICON_2 ICON_INCOMING_ORG_UNIT         '@LI@'."  Stop
783    ICON_2 ICON_NEW_TASK                  '@LJ@'."  Stop
784    ICON_2 ICON_TERMINATED_TASK           '@LK@'."  Stop
785    ICON_2 ICON_OUTGOING_TASK             '@LL@'."  Stop
786    ICON_2 ICON_INCOMING_TASK             '@LM@'."  Stop
787    ICON_2 ICON_OUTGOING_JOB              '@LN@'."  Stop
788    ICON_2 ICON_INCOMING_JOB              '@LO@'."  Stop
789    ICON_2 ICON_NEW_JOB                   '@LP@'."  Stop
790    ICON_2 ICON_TERMINATED_JOB            '@LQ@'."  Stop
791    ICON_2 ICON_INCOMING_OBJECT           '@LR@'."  Stop
792    ICON_2 ICON_OUTGOING_OBJECT           '@LS@'."  Stop
793    ICON_2 ICON_WS_START_WHSE_PROC_BACKGR '@LT@'."  Stop
794    ICON_2 ICON_WS_START_WHSE_PROC_FOREGR '@LU@'."  Stop
795    ICON_2 ICON_WS_CONFIRM_WHSE_PROC_BACK '@LV@'."  Stop
796    ICON_2 ICON_WS_CONFIRM_WHSE_PROC_FORE '@LW@'."  Stop
797    ICON_2 ICON_HOLD                      '@LX@'."  Stop
798    ICON_2 ICON_HOLD_UNDO                 '@LY@'."  Stop
799    ICON_2 ICON_ALV_VARIANTS              '@LZ@'."  Stop
800    ICON_2 ICON_TE_FLAT_RATE              '@M0@'."  Stop
801    ICON_2 ICON_BIW_SOURCE_SYS_OWN        '@M1@'."  Stop
802    ICON_2 ICON_WORKFLOW_JOIN             '@M2@'."  Stop
803    ICON_2 ICON_WORKFLOW_PROCESS          '@M3@'."  Stop
804    ICON_2 ICON_BACKGROUND_JOB            '@M4@'."  Stop
805    ICON_2 ICON_JOB_DETAIL                '@M5@'."  Stop
806    ICON_2 ICON_SYSTEMTYPE                '@M6@'."  Stop
807    ICON_2 ICON_COMPOSITE_ACTIVITYGROUP   '@M7@'."  Stop
808    ICON_2 ICON_TREND_DOWN                '@M8@'."  Stop
809    ICON_2 ICON_TREND_DECREASING          '@M9@'."  Stop
810    ICON_2 ICON_TREND_UNCHANGED           '@MA@'."  Stop
811    ICON_2 ICON_TREND_RISING              '@MB@'."  Stop
812    ICON_2 ICON_TREND_UP                  '@MC@'."  Stop
813    ICON_2 ICON_STATUS_ALERT              '@MD@'."  Stop
814    ICON_2 ICON_STATUS_OK                 '@ME@'."  Stop
815    ICON_2 ICON_STATUS_BEST               '@MF@'."  Stop
816    ICON_2 ICON_NO_STATUS                 '@MG@'."  Stop
817    ICON_2 ICON_DRAW_SELECT               '@MH@'."  Stop
818    ICON_2 ICON_DRAW_FREEHAND             '@MI@'."  Stop
819    ICON_2 ICON_DRAW_ARROW                '@MJ@'."  Stop
820    ICON_2 ICON_DRAW_LINE                 '@MK@'."  Stop
821    ICON_2 ICON_DRAW_POLYLINE             '@ML@'."  Stop
822    ICON_2 ICON_DRAW_ELLIPSE              '@MM@'."  Stop
823    ICON_2 ICON_DRAW_POLYGON              '@MN@'."  Stop
824    ICON_2 ICON_DRAW_RECTANGLE            '@MO@'."  Stop
825    ICON_2 ICON_DRAW_ANGULAR              '@MP@'."  Stop
826    ICON_2 ICON_DRAW_LINEAR               '@MQ@'."  Stop
827    ICON_2 ICON_DRAW_RADIAL               '@MR@'."  Stop
828    ICON_2 ICON_BW_EXCEPTION_MONITOR      '@MS@'."  Stop
829    ICON_2 ICON_BOOKMARK                  '@MT@'."  Stop
830    ICON_2 ICON_TRANSFER_STRUCTURE_INA    '@MU@'."  Stop
831    ICON_2 ICON_EXCEPTION                 '@MV@'."  Stop
832    ICON_2 ICON_RANKING                   '@MW@'."  Stop
833    ICON_2 ICON_PPE_BHNODE                '@MX@'."  Stop
834    ICON_2 ICON_PPE_AENODE                '@MY@'."  Stop
835    ICON_2 ICON_PPE_ANODE                 '@MZ@'."  Stop
836    ICON_2 ICON_PPE_CVNODE                '@N0@'."  Stop
837    ICON_2 ICON_PPE_SNODE                 '@N1@'."  Stop
838    ICON_2 ICON_PPE_ENODE                 '@N2@'."  Stop
839    ICON_2 ICON_PPE_APNODE                '@N3@'."  Stop
840    ICON_2 ICON_PPE_VNODE                 '@N4@'."  Stop
841    ICON_2 ICON_PPE_MODNODE               '@N5@'."  Stop
842    ICON_2 ICON_PPE_AANODE                '@N6@'."  Stop
843    ICON_2 ICON_PPE_AAEXPNODE             '@N7@'."  Stop
844    ICON_2 ICON_PPE_OPNODE                '@N8@'."  Stop
845    ICON_2 ICON_PPE_ACTNODE               '@N9@'."  Stop
846    ICON_2 ICON_PPE_VACTNODE              '@NA@'."  Stop
847    ICON_2 ICON_PPE_VANODE                '@NB@'."  Stop
848    ICON_2 ICON_PPE_LSEG                  '@NC@'."  Stop
849    ICON_2 ICON_PPE_PLINE                 '@ND@'."  Stop
850    ICON_2 ICON_PPE_BPNODE                '@NE@'."  Stop
851    ICON_2 ICON_GIS_BAR                   '@NF@'."  Stop
852    ICON_2 ICON_GIS_COLOR_SHADING         '@NG@'."  Stop
853    ICON_2 ICON_GIS_DEMOTE                '@NH@'."  Stop
854    ICON_2 ICON_GIS_DOT_DENSITY           '@NI@'."  Stop
855    ICON_2 ICON_GIS_LAYER_PROPERTIES      '@NJ@'."  Stop
856    ICON_2 ICON_GIS_PAN                   '@NK@'."  Stop
857    ICON_2 ICON_GIS_PIE                   '@NL@'."  Stop
858    ICON_2 ICON_GIS_PROMOTE               '@NM@'."  Stop
859    ICON_2 ICON_GIS_SPATIAL_SELECT        '@NN@'."  Stop
860    ICON_2 ICON_GIS_SYMBOL                '@NO@'."  Stop
861    ICON_2 ICON_CALL_ANSWER               '@NP@'."  Stop
862    ICON_2 ICON_CALL_ALTERNATE            '@NQ@'."  Stop
863    ICON_2 ICON_CALL_HOLD                 '@NR@'."  Stop
864    ICON_2 ICON_CALL_DEFLECT              '@NS@'."  Stop
865    ICON_2 ICON_CALL_CONSULT              '@NT@'."  Stop
866    ICON_2 ICON_CALL_CONFERENCE           '@NU@'."  Stop
867    ICON_2 ICON_CALL_BLIND_TRANSFER       '@NV@'."  Stop
868    ICON_2 ICON_CALL_RECONNECT            '@NW@'."  Stop
869    ICON_2 ICON_CALL_RETRIEVE             '@NX@'."  Stop
870    ICON_2 ICON_CALL_WARM_TRANSFER        '@NY@'."  Stop
871    ICON_2 ICON_CREATE_CALLBACK           '@NZ@'."  Stop
872    ICON_2 ICON_PROCESS_CALLBACK          '@O0@'."  Stop
873    ICON_2 ICON_BW_RA_SETTING_ACTIVE      '@O1@'."  Stop
874    ICON_2 ICON_BW_RA_SETTING_INACTIVE    '@O2@'."  Stop
875    ICON_2 ICON_SNC_INFO                  '@O3@'."  Stop
876    ICON_2 ICON_DELIVERY                  '@O4@'."  Stop
877    ICON_2 ICON_PPE_ASSY_POS              '@O5@'."  Stop
878    ICON_2 ICON_PPE_ASSY_HEAD             '@O6@'."  Stop
879    ICON_2 ICON_PPE_PARTOF_ALT_ACT        '@O7@'."  Stop
880    ICON_2 ICON_BINARY_DOCUMENT           '@O8@'."  Stop
881    ICON_2 ICON_ANY_DOCUMENT              '@O9@'."  Stop
882    ICON_2 ICON_OTF_DOCUMENT              '@OA@'."  Stop
883    ICON_2 ICON_TEXT_FIELD                '@OB@'."  Stop
884    ICON_2 ICON_FIELD_WITH_TEXT           '@OC@'."  Stop
885    ICON_2 ICON_SIMPLE_FIELD              '@OD@'."  Stop
886    ICON_2 ICON_TRANSPORT_PROPOSAL        '@OE@'."  Stop
887    ICON_2 ICON_HELPASSISTENT_ON          '@OF@'."  Stop
888    ICON_2 ICON_HELPASSISTENT_OFF         '@OG@'."  Stop
889    ICON_2 ICON_DIALGHELP                 '@OH@'."  Stop
890    ICON_2 ICON_DIALOGHELPACTIV           '@OI@'."  Stop
891    ICON_2 ICON_STATUS_CRITICAL           '@OJ@'."  Stop
892    ICON_2 ICON_SYSTEM_SERVICE_FILLED     '@OK@'."  Stop
893    ICON_2 ICON_SYSTEM_SERVICE_OFF        '@OL@'."  Stop
894    ICON_2 ICON_SYSTEM_SERVICE_EMPTY      '@OM@'."  Stop
895    ICON_2 ICON_CONSUMPTION_ALTERNATIVE   '@ON@'."  Stop
896    ICON_2 ICON_PROCUREMENT_ALTERNATIVE   '@OO@'."  Stop
897    ICON_2 ICON_PROCUREMENT_PROCESS       '@OP@'."  Stop
898    ICON_2 ICON_WORKFLOW                  '@OQ@'."  Stop
899    ICON_2 ICON_DOCUMENT_MODEL_SPACE      '@OR@'."  Stop
900    ICON_2 ICON_RELATION_CLASS            '@OS@'."  Stop
901    ICON_2 ICON_IO_ATTRIBUTE              '@OT@'."  Stop
902    ICON_2 ICON_VIRTUAL_RELATION_CLASS    '@OU@'."  Stop
903    ICON_2 ICON_CLASS_CONNECTION_SPACE    '@OV@'."  Stop
904    ICON_2 ICON_IO_PREDEFINED_VALUE       '@OW@'."  Stop
905    ICON_2 ICON_CONTEXT_CLASS             '@OX@'."  Stop
906    ICON_2 ICON_LOIO_CLASS                '@OY@'."  Stop
907    ICON_2 ICON_VIRTUAL_LOIO_CLASS        '@OZ@'."  Stop
908    ICON_2 ICON_PHIO_CLASS                '@P0@'."  Stop
909    ICON_2 ICON_VIRTUAL_PHIO_CLASS        '@P1@'."  Stop
910    ICON_2 ICON_PARAGRAPH                 '@P2@'."  Stop
911    ICON_2 ICON_MC_CONTENTINDICATOR       '@P3@'."  Stop
912    ICON_2 ICON_BSC_CONTENTINDICATOR      '@P4@'."  Stop
913    ICON_2 ICON_RATING_MINUSMINUS         '@P5@'."  Stop
914    ICON_2 ICON_RATING_MINUS              '@P6@'."  Stop
915    ICON_2 ICON_RATING_NEUTRAL            '@P7@'."  Stop
916    ICON_2 ICON_RATING_POSITIVE           '@P8@'."  Stop
917    ICON_2 ICON_RATING_POSITIVEPOSITIVE   '@P9@'."  Stop
918    ICON_2 ICON_WORKFLOW_WEB_ACTIVITY     '@PA@'."  Stop
919    ICON_2 ICON_DELIVERY_NO_CONFIRMATION  '@PB@'."  Stop
920    ICON_2 ICON_SNAP_TO_GRID              '@PC@'."  Stop
921    ICON_2 ICON_GRID                      '@PD@'."  Stop
922    ICON_2 ICON_MAIN_GRID                 '@PE@'."  Stop
923    ICON_2 ICON_TARGET_GROUP              '@PF@'."  Stop
924    ICON_2 ICON_DELIVERY_INBOUND          '@PG@'."  Stop
925    ICON_2 ICON_PPE_LBAL                  '@PH@'."  Stop
926    ICON_2 ICON_PPE_ENTOBJ                '@PI@'."  Stop
927    ICON_2 ICON_PAW_TEST                  '@PJ@'."  Stop
928    ICON_2 ICON_PAW_SUBTEST               '@PK@'."  Stop
929    ICON_2 ICON_PAW_PU                    '@PL@'."  Stop
930    ICON_2 ICON_PAW_ITEM                  '@PM@'."  Stop
931    ICON_2 ICON_BUSINESS_AREA             '@PN@'."  Stop
932    ICON_2 ICON_DATABASE_TABLE            '@PO@'."  Stop
933    ICON_2 ICON_DATABASE_TABLE_INA        '@PP@'."  Stop
934    ICON_2 ICON_CONNECTION_OBJECT         '@PQ@'."  Stop
935    ICON_2 ICON_CONTRACT_ACCOUNT          '@PR@'."  Stop
936    ICON_2 ICON_REGISTER                  '@PS@'."  Stop
937    ICON_2 ICON_INSTALLATION              '@PT@'."  Stop
938    ICON_2 ICON_BORDER_TOP                '@PU@'."  Stop
939    ICON_2 ICON_BORDER_RIGHT              '@PV@'."  Stop
940    ICON_2 ICON_BORDER_OUTSIDE            '@PW@'."  Stop
941    ICON_2 ICON_BORDER_LEFT               '@PX@'."  Stop
942    ICON_2 ICON_BORDER_BOTTOM             '@PY@'."  Stop
943    ICON_2 ICON_BORDER_INSIDE             '@PZ@'."  Stop
944    ICON_2 ICON_DELETE_TEMPLATE           '@Q0@'."  Stop
945    ICON_2 ICON_SAVE_AS_TEMPLATE          '@Q1@'."  Stop
946    ICON_2 ICON_PATIENT_SMARTCARD         '@Q2@'."  Stop
947    ICON_2 ICON_INITIAL                   '@Q3@'."  Stop
948    ICON_2 ICON_GENERAL_RECIPE            '@Q4@'."  Stop
949    ICON_2 ICON_WORKFLOW_ADHOC_ANCHOR     '@Q5@'."  Stop
950    ICON_2 ICON_PRICE_ANALYSIS            '@Q6@'."  Stop
951    ICON_2 ICON_COST_COMPONENTS           '@Q7@'."  Stop
952    ICON_2 ICON_VAL_QUANTITY_STRUCTURE    '@Q8@'."  Stop
953    ICON_2 ICON_REVALUATED_CONS_ALTERNAT  '@Q9@'."  Stop
954    ICON_2 ICON_PACKAGE_QUERY             '@QA@'."  Stop
955    ICON_2 ICON_PACKAGE_DYNAMIC           '@QB@'."  Stop
956    ICON_2 ICON_PACKAGE_STANDARD          '@QC@'."  Stop
957    ICON_2 ICON_PACKAGE_APPLICATION       '@QD@'."  Stop
958    ICON_2 ICON_LINKED_DOCUMENT           '@QE@'."  Stop
959    ICON_2 ICON_CLOSED_LINKED_FOLDER      '@QF@'."  Stop
960    ICON_2 ICON_OPEN_LINKED_FOLDER        '@QG@'."  Stop
961    ICON_2 ICON_REPORT_TEMPLATE           '@QH@'."  Stop
962    ICON_2 ICON_INFOSET_ACT               '@QI@'."  Stop
963    ICON_2 ICON_INFOSET_INA               '@QJ@'."  Stop
964    ICON_2 ICON_CHARACTERISTICS_FML       '@QK@'."  Stop
965    ICON_2 ICON_CHARACTERISTICS_HIER      '@QL@'."  Stop
966    ICON_2 ICON_HIERARCHY_RED             '@QM@'."  Stop
967    ICON_2 ICON_HIERARCHY_VAR_GREEN       '@QN@'."  Stop
968    ICON_2 ICON_HIERARCHY_VAR_RED         '@QO@'."  Stop
969    ICON_2 ICON_KEYFIGURE_FML             '@QP@'."  Stop
970    ICON_2 ICON_VAR_EQUAL_GREEN           '@QQ@'."  Stop
971    ICON_2 ICON_VAR_EQUAL_RED             '@QR@'."  Stop
972    ICON_2 ICON_VAR_GR_EQUAL_GREEN        '@QS@'."  Stop
973    ICON_2 ICON_VAR_GREATER_GREEN         '@QT@'."  Stop
974    ICON_2 ICON_VAR_LESS_EQUAL_GREEN      '@QU@'."  Stop
975    ICON_2 ICON_VAR_LESS_GREEN            '@QV@'."  Stop
976    ICON_2 ICON_VAR_INT_INCLUDE_GREEN     '@QW@'."  Stop
977    ICON_2 ICON_VAR_INT_INCLUDE_RED       '@QX@'."  Stop
978    ICON_2 ICON_MULTI_DATA_PROVIDER       '@QY@'."  Stop
979    ICON_2 ICON_MULTI_DATA_PROVIDER_INA   '@QZ@'."  Stop
980    ICON_2 ICON_BW_SOURCE_SYS_DB          '@R0@'."  Stop
981    ICON_2 ICON_BW_SOURCE_SYS_WEB         '@R1@'."  Stop
982    ICON_2 ICON_BW_DATASOURCE             '@R2@'."  Stop
983    ICON_2 ICON_BW_WEB_REPORT             '@R3@'."  Stop
984    ICON_2 ICON_XML_DOC                   '@R4@'."  Stop
985    ICON_2 ICON_DROPDOWNLIST              '@R5@'."  Stop
986    ICON_2 ICON_RADIOBUTTON               '@R6@'."  Stop
987    ICON_2 ICON_CHECKBOX                  '@R7@'."  Stop
988    ICON_2 ICON_GEO_CHARACTERISTIC        '@R8@'."  Stop
989    ICON_2 ICON_GEO_CHARACTERISTIC_INA    '@R9@'."  Stop
990    ICON_2 ICON_MANIKIN_FEMALE            '@RA@'."  Stop
991    ICON_2 ICON_MANIKIN_MALE              '@RB@'."  Stop
992    ICON_2 ICON_MANIKIN_UNKNOWN_GENDER    '@RC@'."  Stop
993    ICON_2 ICON_SYMBOL_FEMALE             '@RD@'."  Stop
994    ICON_2 ICON_SYMBOL_MALE               '@RE@'."  Stop
995    ICON_2 ICON_DECEASED_PATIENT          '@RF@'."  Stop
996    ICON_2 ICON_WD_APPL_COMPONENT         '@RG@'."  Stop
997    ICON_2 ICON_WD_TAG_LIBRARY            '@RH@'."  Stop
998    ICON_2 ICON_WD_TAB_LIBRARY_REF        '@RI@'."  Stop
999    ICON_2 ICON_WD_WEB_PROJECT            '@RJ@'."  Stop
1000   ICON_2 ICON_WD_WEB_APPL_PROJECT       '@RK@'."  Stop
1001   ICON_2 ICON_WD_INBOUND_PLUG           '@RL@'."  Stop
1002   ICON_2 ICON_WD_OUTBOUND_PLUG          '@RM@'."  Stop
1003   ICON_2 ICON_WD_VIEW                   '@RN@'."  Stop
1004   ICON_2 ICON_WD_VIEWS                  '@RO@'."  Stop
1005   ICON_2 ICON_WD_INTERFACE_VIEW         '@RP@'."  Stop
1006   ICON_2 ICON_WD_INTERFACE_VIEWS        '@RQ@'."  Stop
1007   ICON_2 ICON_WD_VIEW_AREA              '@RR@'."  Stop
1008   ICON_2 ICON_WD_VIEW_SET_T_LAYOUT      '@RS@'."  Stop
1009   ICON_2 ICON_WD_VIEW_SET_T_LAYOUT_REV  '@RT@'."  Stop
1010   ICON_2 ICON_WD_VIEW_SET_T_LAYOUT_270  '@RU@'."  Stop
1011   ICON_2 ICON_WD_VIEW_SET_T_LAYOUT_90   '@RV@'."  Stop
1012   ICON_2 ICON_WD_VIEW_SET_TAB_LAYOUT    '@RW@'."  Stop
1013   ICON_2 ICON_WD_VIEW_SET_GRID          '@RX@'."  Stop
1014   ICON_2 ICON_WD_VIEW_CONTAINER         '@RY@'."  Stop
1015   ICON_2 ICON_WD_WINDOWS_COLLECTION     '@RZ@'."  Stop
1016   ICON_2 ICON_WD_WINDOW                 '@S0@'."  Stop
1017   ICON_2 ICON_WD_BUILD_ALL              '@S1@'."  Stop
1018   ICON_2 ICON_WD_BUILD_INCREMENTAL      '@S2@'."  Stop
1019   ICON_2 ICON_WD_COMPONENTS             '@S3@'."  Stop
1020   ICON_2 ICON_WD_COMPONENT              '@S4@'."  Stop
1021   ICON_2 ICON_WD_COMPONENT_INTERFACE    '@S5@'."  Stop
1022   ICON_2 ICON_WD_APPLICATION            '@S6@'."  Stop
1023   ICON_2 ICON_WD_APPLICATIONS           '@S7@'."  Stop
1024   ICON_2 ICON_WD_CONTEXT                '@S8@'."  Stop
1025   ICON_2 ICON_WD_VALUE_NODE             '@S9@'."  Stop
1026   ICON_2 ICON_WD_VALUE_ATTR             '@SA@'."  Stop
1027   ICON_2 ICON_WD_MAPPED_VALUE_NODE      '@SB@'."  Stop
1028   ICON_2 ICON_WD_MAPPED_VALUE_ATTR      '@SC@'."  Stop
1029   ICON_2 ICON_WD_MODEL_NODE             '@SD@'."  Stop
1030   ICON_2 ICON_WD_MODEL_ATTRIBUTE        '@SE@'."  Stop
1031   ICON_2 ICON_WD_MAPPED_MODEL_NODE      '@SF@'."  Stop
1032   ICON_2 ICON_WD_MAPPED_MODEL_ATTR      '@SG@'."  Stop
1033   ICON_2 ICON_WD_RECURSION_NODE         '@SH@'."  Stop
1034   ICON_2 ICON_WD_IMAGE                  '@SI@'."  Stop
1035   ICON_2 ICON_WD_CAPTION                '@SJ@'."  Stop
1036   ICON_2 ICON_WD_BUSINESS_GRAPHICS      '@SK@'."  Stop
1037   ICON_2 ICON_WD_LABEL                  '@SL@'."  Stop
1038   ICON_2 ICON_WD_INPUT_FIELD            '@SM@'."  Stop
1039   ICON_2 ICON_WD_NUMERIC_VALUE          '@SN@'."  Stop
1040   ICON_2 ICON_WD_TIME_VALUE             '@SO@'."  Stop
1041   ICON_2 ICON_WD_CHECK_BOX_INDEXED      '@SP@'."  Stop
1042   ICON_2 ICON_WD_CHECK_BOX_GROUP        '@SQ@'."  Stop
1043   ICON_2 ICON_WD_RADIO_BUTTON_EMPTY     '@SR@'."  Stop
1044   ICON_2 ICON_WD_RADIO_BUTTON_INDEX     '@SS@'."  Stop
1045   ICON_2 ICON_WD_RADIO_BUTTON_KEY       '@ST@'."  Stop
1046   ICON_2 ICON_WD_DROPDOWN_INDEX         '@SU@'."  Stop
1047   ICON_2 ICON_WD_DROPDOWN_KEY           '@SV@'."  Stop
1048   ICON_2 ICON_WD_LINK_TO_ACTION         '@SW@'."  Stop
1049   ICON_2 ICON_WD_LINK_TO_URL            '@SX@'."  Stop
1050   ICON_2 ICON_WD_TOOLBAR_BUTTON         '@SY@'."  Stop
1051   ICON_2 ICON_WD_TOOLBAR_DROPDOWN_IDX   '@SZ@'."  Stop
1052   ICON_2 ICON_WD_TOOLBAR_DROPDOWN_KEY   '@T0@'."  Stop
1053   ICON_2 ICON_WD_TOOLBAR_INPUT_FIELD    '@T1@'."  Stop
1054   ICON_2 ICON_WD_TOOLBAR_SEPARATOR      '@T2@'."  Stop
1055   ICON_2 ICON_WD_TOOLBAR_CAPTION        '@T3@'."  Stop
1056   ICON_2 ICON_WD_TABLE                  '@T4@'."  Stop
1057   ICON_2 ICON_WD_TABLE_COLUMN           '@T5@'."  Stop
1058   ICON_2 ICON_WD_TREE                   '@T6@'."  Stop
1059   ICON_2 ICON_WD_TREE_NODE              '@T7@'."  Stop
1060   ICON_2 ICON_WD_TREE_ITEM              '@T8@'."  Stop
1061   ICON_2 ICON_WD_IFRAME                 '@T9@'."  Stop
1062   ICON_2 ICON_WD_CHECK_BOX              '@TA@'."  Stop
1063   ICON_2 ICON_WD_RADIO_BUTTON           '@TB@'."  Stop
1064   ICON_2 ICON_WD_BUTTON                 '@TC@'."  Stop
1065   ICON_2 ICON_WD_TEXT_VIEW              '@TD@'."  Stop
1066   ICON_2 ICON_WD_TEXT_EDIT              '@TE@'."  Stop
1067   ICON_2 ICON_WD_TOOLBAR                '@TF@'."  Stop
1068   ICON_2 ICON_WD_TABSTRIP               '@TG@'."  Stop
1069   ICON_2 ICON_WD_TAB                    '@TH@'."  Stop
1070   ICON_2 ICON_WD_GROUP                  '@TI@'."  Stop
1071   ICON_2 ICON_WD_TRAY                   '@TJ@'."  Stop
1072   ICON_2 ICON_WD_TRANSPARENT_CONTAINER  '@TK@'."  Stop
1073   ICON_2 ICON_WD_SCROLL_CONTAINER       '@TL@'."  Stop
1074   ICON_2 ICON_WD_NAVIGATION_LINK        '@TM@'."  Stop
1075   ICON_2 ICON_WD_NAVLINK_BIDIRECTIONAL  '@TN@'."  Stop
1076   ICON_2 ICON_WD_NAVLINK_OUT            '@TO@'."  Stop
1077   ICON_2 ICON_WD_NAVLINK_IN             '@TP@'."  Stop
1078   ICON_2 ICON_WD_CONTROLLER             '@TQ@'."  Stop
1079   ICON_2 ICON_CONTEXT_MENU              '@TR@'."  Stop
1080   ICON_2 ICON_ERASE                     '@TS@'."  Stop
1081   ICON_2 ICON_RETAIL_PRODUCT            '@TT@'."  Stop
1082   ICON_2 ICON_RETAIL_STORE              '@TU@'."  Stop
1083   ICON_2 ICON_HANDLING_UNIT             '@TV@'."  Stop
1084   ICON_2 ICON_BW_DM                     '@TW@'."  Stop
1085   ICON_2 ICON_BW_APD_VISUALIZATION      '@TX@'."  Stop
1086   ICON_2 ICON_BW_APD_TARGET             '@TY@'."  Stop
1087   ICON_2 ICON_BW_APD_TRANSFORMATION     '@TZ@'."  Stop
1088   ICON_2 ICON_BW_APD_SOURCE             '@U0@'."  Stop
1089   ICON_2 ICON_BW_APD_COLUMN_TO_ROW      '@U1@'."  Stop
1090   ICON_2 ICON_BW_APD_ROW_TO_COLUMN      '@U2@'."  Stop
1091   ICON_2 ICON_BW_APD_DB                 '@U3@'."  Stop
1092   ICON_2 ICON_BW_APD                    '@U4@'."  Stop
1093   ICON_2 ICON_BW_DM_3RD                 '@U5@'."  Stop
1094   ICON_2 ICON_BW_DM_WST                 '@U6@'."  Stop
1095   ICON_2 ICON_BW_APD_REGRESSION         '@U7@'."  Stop
1096   ICON_2 ICON_BW_DM_CLUS                '@U8@'."  Stop
1097   ICON_2 ICON_BW_DM_AA                  '@U9@'."  Stop
1098   ICON_2 ICON_BW_DM_DT                  '@UA@'."  Stop
1099   ICON_2 ICON_BW_CONVERT_UNIT           '@UB@'."  Stop
1100   ICON_2 ICON_BW_PLANNING_LAYER         '@UC@'."  Stop
1101   ICON_2 ICON_BW_PLANNING_LAYER_INA     '@UD@'."  Stop
1102   ICON_2 ICON_BW_OPEN_HUB_DESTINATION   '@UE@'."  Stop
1103   ICON_2 ICON_BW_ROTATE_RIGHT           '@UF@'."  Stop
1104   ICON_2 ICON_BW_ROTATE_LEFT            '@UG@'."  Stop
1105   ICON_2 ICON_VIEW_FORM                 '@UH@'."  Stop
1106   ICON_2 ICON_VIEW_LIST                 '@UI@'."  Stop
1107   ICON_2 ICON_MEDIUM                    '@UJ@'."  Stop
1108   ICON_2 ICON_VIEW_MAXIMIZE             '@UK@'."  Stop
1109   ICON_2 ICON_VIEW_EXPAND_VERTICAL      '@UL@'."  Stop
1110   ICON_2 ICON_VIEW_EXPAND_HORIZONTAL    '@UM@'."  Stop
1111   ICON_2 ICON_VIEW_REFRESH              '@UN@'."  Stop
1112   ICON_2 ICON_VIEW_CREATE               '@UO@'."  Stop
1113   ICON_2 ICON_VIEW_CLOSE                '@UP@'."  Stop
1114   ICON_2 ICON_VIEW_SWITCH               '@UQ@'."  Stop
1115   ICON_2 ICON_BREAKPOINT_DISABLE        '@UR@'."  Stop
1116   ICON_2 ICON_WD_CUSTOM_CONTROLLER      '@US@'."  Stop
1117   ICON_2 ICON_WD_CUSTOM_CONTROLLERS     '@UT@'."  Stop
1118   ICON_2 ICON_WD_INPUT_MODEL_ATT        '@UU@'."  Stop
1119   ICON_2 ICON_WD_INPUT_MODEL_NODE       '@UV@'."  Stop
1120   ICON_2 ICON_WD_INPUT_VAL_ATT          '@UW@'."  Stop
1121   ICON_2 ICON_WD_INPUT_VAL_NODE         '@UX@'."  Stop
1122   ICON_2 ICON_WD_MAPPED_INPUT_MODEL_ATT '@UY@'."  Stop
1123   ICON_2 ICON_WD_MAPPED_INPUT_MODEL_NOD '@UZ@'."  Stop
1124   ICON_2 ICON_WD_MAPPED_INPUT_VAL_ATT   '@V0@'."  Stop
1125   ICON_2 ICON_WD_MAPPED_INPUT_VAL_NODE  '@V1@'."  Stop
1126   ICON_2 ICON_WD_COMPONENT_CTRL         '@V2@'."  Stop
1127   ICON_2 ICON_WD_COMPONENT_CTRL_USAGE   '@V3@'."  Stop
1128   ICON_2 ICON_WD_COMPONENT_IF_CTRL      '@V4@'."  Stop
1129   ICON_2 ICON_COMPONENT_IF_DEF          '@V5@'."  Stop
1130   ICON_2 ICON_COMPONENT_IF_DEFS         '@V6@'."  Stop
1131   ICON_2 ICON_WD_COMPONENT_USAGE        '@V7@'."  Stop
1132   ICON_2 ICON_WD_COMPONENT_USAGES       '@V8@'."  Stop
1133   ICON_2 ICON_WEBBREAKPOINT             '@V9@'."  Stop
1134   ICON_2 ICON_WEBBREAKPOINT_DISABLED    '@VA@'."  Stop
1135   ICON_2 ICON_USER_BREAKPOINT           '@VB@'."  Stop
1136   ICON_2 ICON_USER_BREAKPOINT_DISABLED  '@VC@'."  Stop
1137   ICON_2 ICON_CLIENT_BREAKPOINT         '@VD@'."  Stop
1138   ICON_2 ICON_CLIENT_BREAKPOINT_DIS     '@VE@'."  Stop
1139   ICON_2 ICON_ES_REPOSITORY             '@VF@'."  Stop
1140   ICON_2 ICON_RED_DASH                  '@VG@'."  Stop
1141   ICON_2 ICON_RED_SLASH                 '@VH@'."  Stop
1142   ICON_2 ICON_RED_XCIRCLE               '@VI@'."  Stop
1143   ICON_2 ICON_VALUE_HELP                '@VJ@'."  Stop
1144   ICON_2 ICON_BW_DTP_ACTIVE             '@VK@'."  Stop
1145   ICON_2 ICON_BW_DTP_INACTIVE           '@VL@'."  Stop
1146   ICON_2 ICON_BW_OPEN_HUB_INACTIVE      '@VM@'."  Stop
1147   ICON_2 ICON_OO_INTERFACE_MSGTP        '@VN@'."  Stop
1148   ICON_2 ICON_OO_INTERFACE_FAULT_MSGTP  '@VO@'."  Stop
1149   ICON_2 ICON_SEGMENTED_DATA_ACT        '@VP@'."  Stop
1150   ICON_2 ICON_SEGMENTED_DATA_INA        '@VQ@'."  Stop
1151   ICON_2 ICON_BIW_VIRTUAL_INFO_PROVIDER '@VR@'."  Stop
1152   ICON_2 ICON_BIW_VIRTUAL_INFO_PROV_INA '@VS@'."  Stop
1153   ICON_2 ICON_ALL_GREEN                 '@VT@'."  Stop
1154   ICON_2 ICON_BW_SOURCE_SYS_UDC         '@VU@'."  Stop
1155   ICON_2 ICON_AGENT                     '@VV@'."  Stop
1156   ICON_2 ICON_BIW_INFO_SOURCE_INA       '@VW@'."  BW Info Source Inactive
1157   ICON_2 ICON_CHECKED_OUT               '@VX@'."  Checked Out
1158   ICON_2 ICON_CHECKIN_REQUESTED         '@VY@'."  Request Check In
1159   ICON_2 ICON_CHECKOUT_REQUESTED        '@VZ@'."  Request Check Out
1160   ICON_2 ICON_MESSAGE_TYPE              '@W0@'."  Message
1161   ICON_2 ICON_MESSAGE_FAULTY            '@W1@'."  Error Message
1162   ICON_2 ICON_BUSINAV_OBJECTS_UPTODATE  '@W2@'."  Business Object (Current
1163   ICON_2 ICON_BUSINAV_OBJECTS_OUTDATE   '@W3@'."  Business Object (Old)
1164   ICON_2 ICON_BUSINAV_OBJECTS_ORPHAN    '@W4@'."  Business Object (Orphane
1165   ICON_2 ICON_CLOSED_FOLDER_UPTODATE    '@W5@'."  Folder (Current)
1166   ICON_2 ICON_CLOSED_FOLDER_OUTDATE     '@W6@'."  Folder (Old)
1167   ICON_2 ICON_CLOSED_FOLDER_ORPHANED    '@W7@'."  Folder (Orphaned)
1168   ICON_2 ICON_MESSAGE_UPTODATE          '@W8@'."  Message (Current)
1169   ICON_2 ICON_MESSAGE_OUTOFDATE         '@W9@'."  Message (Old)
1170   ICON_2 ICON_MESSAGE_ORPHANED          '@WA@'."  Message (Orphaned)
1171   ICON_2 ICON_MESSAGE_FAULTY_UPTODATE   '@WB@'."  Error Message (Current)
1172   ICON_2 ICON_MESSAGE_FAULTY_OUTDATE    '@WC@'."  Error Message (Old)
1173   ICON_2 ICON_MESSAGE_FAULTY_ORPHAN     '@WD@'."  Error Message (Orphaned)
1174   ICON_2 ICON_OO_INTERFACE_UPTODATE     '@WE@'."  Object Interface (Curren
1175   ICON_2 ICON_OO_INTERFACE_OUTDATE      '@WF@'."  Object Interface (Old)
1176   ICON_2 ICON_OO_INTERFACE_ORPHAN       '@WG@'."  Object Interface (Orphan
1177   ICON_2 ICON_DATATYPES_UPTODATE        '@WH@'."  Data Types (Current)
1178   ICON_2 ICON_DATATYPES_OUTDATE         '@WI@'."  Data Types (Old)
1179   ICON_2 ICON_DATATYPES_ORPHAN          '@WJ@'."  Data Types (Orphaned)
1180   ICON_2 ICON_DATATYPES_ENH_UPTODATE    '@WK@'."  Data Type Enhancement (C
1181   ICON_2 ICON_DATATYPES_ENH_OUTDATE     '@WL@'."  Data Type Enhancement (O
1182   ICON_2 ICON_DATATYPES_ENH_ORPHAN      '@WM@'."  Data Type Enhancement (O
1183   ICON_2 ICON_AGENT_UPTODATE            '@WN@'."  Agent (Current)
1184   ICON_2 ICON_AGENT_OUTDATE             '@WO@'."  Agent (Old)
1185   ICON_2 ICON_AGENT_ORPHAN              '@WP@'."  Agent (Orphaned)
1186   ICON_2 ICON_ENHANCED_BO               '@WQ@'."  Enhanced Business Object
1187   ICON_2 ICON_ENHANCED_BO_UPTODATE      '@WR@'."  Enh. Business Object (Cu
1188   ICON_2 ICON_ENHANCED_BO_OUTDATE       '@WS@'."  Enhance. Business Object
1189   ICON_2 ICON_ENHANCED_BO_ORPHAN        '@WT@'."  En. Business Object (Orp
1190   ICON_2 ICON_STORES                    '@WU@'."  Subsidiaries
1191   ICON_2 ICON_WAREHOUSES                '@WV@'."  Multiple Central Warehou
1192   ICON_2 ICON_CONDITION_BREAKPOINT      '@WW@'."  Multiple Central Warehou
1193   ICON_2 ICON_CONDITION_BREAKPOINT_DIS  '@WX@'."  Multiple Central Warehou
1194   ICON_2 ICON_JOB_FAMILY                '@WY@'."  Multiple Central Warehou
1195   ICON_2 ICON_INTELLECTUAL_PROPERTY     '@WZ@'."  Multiple Central Warehou
1196   ICON_2 ICON_PROPRIETARY               '@X0@'."  Multiple Central Warehou
1197   ICON_2 ICON_INSTALL_PACKAGE           '@X1@'."  Multiple Central Warehou
1198   ICON_2 ICON_SAP_LOGON                 '@X2@'."  Multiple Central Warehou
1199   ICON_2 ICON_SAP_SHORTCUT              '@X3@'."  Multiple Central Warehou
1200   ICON_2 ICON_SAP_GUI_SESSION           '@X4@'."  Multiple Central Warehou
1201   ICON_2 ICON_SAP_SERVER                '@X5@'."  Multiple Central Warehou
1202   ICON_2 ICON_SAP_LOGON_SERVER_SSO      '@X6@'."  Multiple Central Warehou
1203   ICON_2 ICON_SAP_LOGON_USERDEFINED     '@X7@'."  Multiple Central Warehou
1204   ICON_2 ICON_SAP_LOGON_USERDEFINED_SSO '@X8@'."  Multiple Central Warehou
1205   ICON_2 ICON_SAP_LOGON_GROUP           '@X9@'."  Multiple Central Warehou
1206   ICON_2 ICON_SAP_LOGON_GROUP_SSO       '@XA@'."  Multiple Central Warehou
1207   ICON_2 ICON_SAP_LOGON_GROUP_USER      '@XB@'."  Multiple Central Warehou
1208   ICON_2 ICON_SETTINGS                  '@XC@'."  Multiple Central Warehou
1209   ICON_2 ICON_VIEW_TABLE                '@XD@'."  Multiple Central Warehou
1210   ICON_2 ICON_VIEW_HIER_LIST            '@XE@'."  Multiple Central Warehou
1211   ICON_2 ICON_VIEW_TREE                 '@XF@'."  Multiple Central Warehou
1212   ICON_2 ICON_VIEW_THUMBNAILS           '@XG@'."  Multiple Central Warehou
1213   ICON_2 ICON_SAP_LOGON_GROUP_CERT      '@XH@'."  Multiple Central Warehou
1214   ICON_2 ICON_SAP_LOGON_GROUP_CERT_SSO  '@XI@'."  Multiple Central Warehou
1215   ICON_2 ICON_SAP_LOGON_GROUP_CERT_USER '@XJ@'."  Multiple Central Warehou
1216   ICON_2 ICON_LOGON_GROUP_CERT_SSO_USR  '@XK@'."  Multiple Central Warehou
1217   ICON_2 ICON_SAP_LOGON_SRV_CERT        '@XL@'."  Multiple Central Warehou
1218   ICON_2 ICON_SAP_LOGON_SRV_CERT_SSO    '@XM@'."  Multiple Central Warehou
1219   ICON_2 ICON_SAP_LOGON_SRV_CERT_USER   '@XN@'."  Multiple Central Warehou
1220   ICON_2 ICON_LOGON_SRV_CERT_SSO_USER   '@XO@'."  Multiple Central Warehou
1221   ICON_2 ICON_MASS_CHANGE_DONE          '@XP@'."  Multiple Central Warehou
1222   ICON_2 ICON_REMOVE_ROW                '@XQ@'."  Multiple Central Warehou
1223   ICON_2 ICON_ADD_ROW                   '@XR@'."  Multiple Central Warehou
1224   ICON_2 ICON_SAP_LOGON_GROUP_SSO_USR   '@XS@'."  Multiple Central Warehou
1225   ICON_2 ICON_APPLE_KEYNOTE             '@XT@'."  Multiple Central Warehou
1226   ICON_2 ICON_APPLE_NUMBERS             '@XU@'."  Multiple Central Warehou
1227   ICON_2 ICON_APPLE_PAGES               '@XV@'."  Multiple Central Warehou
1228   ICON_2 ICON_GOS_SERVICES              '@XW@'."  Multiple Central Warehou
1229   ICON_2 ICON_GOS_SERVICES_ATTACHMENT   '@XX@'."  Multiple Central Warehou
1230   ICON_2 ICON_GOS_SERVICES_RELATIONS    '@XY@'."  Multiple Central Warehou
1231   ICON_2 ICON_GOS_SERVICES_ATT_REL      '@XZ@'."  Multiple Central Warehou
1232   ICON_2 ICON_REBATE                    '@Y0@'."  Multiple Central Warehou
1233   ICON_2 ICON_CHARGE                    '@Y1@'."  Multiple Central Warehou
1234   ICON_2 ICON_START_VIEWER              '@Y2@'."  Multiple Central Warehou
1235   ICON_2 ICON_CLOUD                     '@Y3@'."  Multiple Central Warehou
1236   ICON_2 ICON_CLOUD_DOWNLOAD            '@Y4@'."  Multiple Central Warehou
1237   ICON_2 ICON_CLOUD_UPLOAD              '@Y5@'."  Multiple Central Warehou
1238   ICON_2 ICON_SHOPPINGCART              '@Y6@'."  Multiple Central Warehou
1239   ICON_2 ICON_ADD_SHOPPINGCART          '@Y7@'."  Multiple Central Warehou
1240   ICON_2 ICON_REMOVE_SHOPPINGCART       '@Y8@'."  Multiple Central Warehou
1241   ICON_2 ICON_DELETE_SHOPPINGCART       '@Y9@'."  Multiple Central Warehou
1242   ICON_2 ICON_ALV_COLLAPSE              '@YA@'."  Multiple Central Warehou
1243   ICON_2 ICON_ALV_EXPAND                '@YB@'."  Multiple Central Warehou
1244
1245   * bugfix for wrong usage of ICON_BW_SUGGEST_VALUE
1246   ICON_2 ICON_SUGGEST_VALUE             '@F6@'."  Stop
*--- End of %_CICON - 1246 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CRSDS                                   Level 1    Page 10
Object           ZJV_SAPF100                               Lines 46
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:11
----------------------------------------------------------------------------------------------------
1      TYPE-POOL RSDS .
2      * Type definitions for FREE SELECTIONS
3
4      * WHERE-clauses ------------------------------------------------------ *
5      TYPES: RSDS_WHERE_TAB LIKE RSDSWHERE OCCURS 5.
6
7      TYPES: BEGIN OF RSDS_WHERE,
8               TABLENAME LIKE RSDSTABS-PRIM_TAB,
9               WHERE_TAB TYPE RSDS_WHERE_TAB,
10            END OF RSDS_WHERE.
11
12     TYPES: RSDS_TWHERE TYPE RSDS_WHERE OCCURS 5.
13
14     * Expressions Polish notation ---------------------------------------- *
15     TYPES: RSDS_EXPR_TAB LIKE RSDSEXPR OCCURS 10.
16
17     TYPES: BEGIN OF RSDS_EXPR,
18              TABLENAME LIKE RSDSTABS-PRIM_TAB,
19              EXPR_TAB TYPE RSDS_EXPR_TAB,
20            END OF RSDS_EXPR.
21
22     TYPES: RSDS_TEXPR  TYPE RSDS_EXPR  OCCURS 10.
23
24     * Selections as RANGES-tables ---------------------------------------- *
25     TYPES: RSDS_SELOPT_T LIKE RSDSSELOPT OCCURS 10.
26
27     TYPES: BEGIN OF RSDS_FRANGE,
28              FIELDNAME LIKE RSDSTABS-PRIM_FNAME,
29              SELOPT_T TYPE RSDS_SELOPT_T,
30            END OF RSDS_FRANGE.
31
32     TYPES: RSDS_FRANGE_T TYPE RSDS_FRANGE OCCURS 10.
33
34     TYPES: BEGIN OF RSDS_RANGE,
35              TABLENAME LIKE RSDSTABS-PRIM_TAB,
36              FRANGE_T TYPE RSDS_FRANGE_T,
37            END OF RSDS_RANGE.
38
39     TYPES: RSDS_TRANGE TYPE RSDS_RANGE OCCURS 10.
40
41
42     TYPES: BEGIN OF RSDS_TYPE,
43              CLAUSES TYPE RSDS_TWHERE,
44              TEXPR   TYPE RSDS_TEXPR,
45              TRANGE  TYPE RSDS_TRANGE,
46            END   OF RSDS_TYPE.
*--- End of %_CRSDS - 46 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CSLIS                                   Level 1    Page 11
Object           ZJV_SAPF100                               Lines 543
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:11
----------------------------------------------------------------------------------------------------
1      type-pool slis .
2
3      types: slis_list_type(1) type n,
4             slis_char_1(1) type c,
5             slis_text40(40) type c.
6
7      types: slis_tabname(30) type c,
8             slis_fieldname(30) type c,
9             slis_sel_tab_field(60) type c,
10            slis_formname(30) type c,
11            slis_entry(60) type c,
12            slis_edit_mask(60) type c,
13            slis_coldesc(4) type c.
14
15     *Accessibility
16     types: slis_qinfo_alv type alv_s_qinf,
17            slis_t_qinfo_alv type slis_qinfo_alv occurs 0.
18
19     *types: begin of slis_filtered_entries,
20     *         index type i,
21     *       end of slis_filtered_entries.
22     types: slis_t_filtered_entries type i occurs 0.
23
24     *--- Structure for additional fieldcat
25     types: begin of slis_add_fieldcat,
26              fieldname type slis_fieldname,
27              web_field type slis_fieldname,
28              href_hndl type i,
29            end of slis_add_fieldcat.
30     types: slis_t_add_fieldcat type slis_add_fieldcat occurs 0.
31
32     *--- Structure for reprep-initialization
33     types: begin of slis_reprep_id,
34              tool(2) type c,
35              appl(4) type c,
36              subc(2) type c,
37              onam(54) type c,
38            end of slis_reprep_id.
39
40     types: begin of slis_reprep_communication,
41              stop(1) type c,
42            end of slis_reprep_communication.
43
44     *** Structure for colors
45     types: begin of slis_color,
46              col type i,
47              int type i,
48              inv type i,
49            end of slis_color.
50
51     types: begin of slis_coltypes,
52              heacolfir      type slis_color, " heading_cols_first
53              heacolnex      type slis_color, " heading_cols_nex
54              hearowfir      type slis_color, " heading_rows_first
55              hearownex      type slis_color, " heading_rows_next
56              lisbodfir      type slis_color, " list_body_first
57              lisbodnex      type slis_color, " list_body_next
58              lisbod         type slis_color, " list_body
59              higcolkey      type slis_color, " highlight_col_key
60              higcol         type slis_color, " highlight_col
61              higrow         type slis_color, " highlight_row
62              higsum         type slis_color, " highlight_sum
63              higsumhig      type slis_color, " highlight_sum_high
64              higsumlow      type slis_color, " highlight_sum_low
65              higins         type slis_color, " highlight_inserted
66              higpos         type slis_color, " highlight_positive
67              higneg         type slis_color, " highlight_negative
68              hig            type slis_color, " highlight
69              heahie         type slis_color, " heading_hier
70              lisbodhie      type slis_color, " list_body_hierinfo
71            end of slis_coltypes.
72
73     *** Fieldcat
74     types: begin of slis_fieldcat_main0,
75              row_pos        like sy-curow, " output in row
76              col_pos        like sy-cucol, " position of the column
77              fieldname      type slis_fieldname,
78              tabname        type slis_tabname,
79              currency(5)    type c,
80              cfieldname     type slis_fieldname, " field with currency unit
81              ctabname       type slis_tabname,   " and table
82              ifieldname     type slis_fieldname, " initial column
83              quantity(3)    type c,
84              qfieldname     type slis_fieldname, " field with quantity unit
85              qtabname       type slis_tabname,   " and table
86              round          type i,        " round in write statement
87              exponent(3)       type c,     " exponent for floats
88              key(1)         type c,        " column with key-color
89              icon(1)        type c,        " as icon
90              symbol(1)      type c,        " as symbol
91              checkbox(1)    type c,        " as checkbox
92              just(1)        type c,        " (R)ight (L)eft (C)ent.
93              lzero(1)       type c,        " leading zero
94              no_sign(1)     type c,        " write no-sign
95              no_zero(1)     type c,        " write no-zero
96              no_convext(1)  type c,
97              edit_mask      type slis_edit_mask,                "
98              emphasize(4)   type c,        " emphasize
99              fix_column(1)   type c,       " Spalte fixieren
100             do_sum(1)      type c,        " sum up
101             no_out(1)      type c,        " (O)blig.(X)no out
102             tech(1)        type c,        " technical field
103             outputlen      like dd03p-outputlen,
104             offset         type dd03p-outputlen,     " offset
105             seltext_l      like dd03p-scrtext_l, " long key word
106             seltext_m      like dd03p-scrtext_m, " middle key word
107             seltext_s      like dd03p-scrtext_s, " short key word
108             ddictxt(1)     type c,        " (S)hort (M)iddle (L)ong
109             rollname       like dd03p-rollname,
110             datatype       like dd03p-datatype,
111             inttype        like dd03p-inttype,
112             intlen         like dd03p-intlen,
113             lowercase      like dd03p-lowercase,
114             decfloat_style type outputstyle,          " B20K8A2GF0
115             parameter0     type char30,
116             parameter1     type char30,
117             parameter2     type char30,
118             parameter3     type char30,
119             parameter4     type char30,
120             parameter5     type int4,
121             parameter6     type int4,
122             parameter7     type int4,
123             parameter8     type int4,
124             parameter9     type int4,
125           end of slis_fieldcat_main0.
126
127    types: begin of slis_fieldcat_main1,
128             ref_fieldname  like dd03p-fieldname,
129             ref_tabname    like dd03p-tabname,
130             roundfieldname type slis_fieldname,
131             roundtabname   type slis_tabname,
132             decimalsfieldname type slis_fieldname,
133             decimalstabname   type slis_tabname,
134             decimals_out(6)   type c,     " decimals in write statement
135             text_fieldname type slis_fieldname,
136             reptext_ddic   like dd03p-reptext,   " heading (ddic)
137             ddic_outputlen like dd03p-outputlen,
138           end of slis_fieldcat_main1.
139
140    types: begin of slis_fieldcat_main.
141    include type slis_fieldcat_main0.
142    include type slis_fieldcat_main1.
143    types: end of slis_fieldcat_main.
144
145    types: begin of slis_fieldcat_alv_spec,
146             key_sel(1)     type c,        " field not obligatory
147             no_sum(1)      type c,        " do not sum up
148             sp_group(4)    type c,        " group specification
149             reprep(1)      type c,        " selection for rep/rep
150             input(1)       type c,        " input
151             edit(1)        type c,        " internal use only
152             hotspot(1)     type c,        " hotspot
153           end of slis_fieldcat_alv_spec.
154
155    types: begin of slis_fieldcat_alv.
156    include type slis_fieldcat_main.
157    include type slis_fieldcat_alv_spec.
158    types: end of slis_fieldcat_alv.
159
160    types: begin of slis_fieldcat_alv1.
161    include type slis_fieldcat_main1.
162    types: end of slis_fieldcat_alv1.
163
164    types: slis_t_fieldcat_alv type slis_fieldcat_alv occurs 1.
165
166    * Events for Callback
167    types: begin of slis_event_exit.
168    types:   ucomm like sy-ucomm,
169             before(1) type c,
170             after(1) type c,
171           end of slis_event_exit.
172    types: slis_t_event_exit type slis_event_exit occurs 1.
173
174    * Callback Interface structure for non display subtotals text
175    types: begin of slis_subtot_text,
176             criteria type slis_fieldname,
177             keyword  like dd03p-reptext,
178             criteria_text(255) type c,
179             max_len  like dd03p-outputlen,
180             display_text_for_subtotal(255) type c,
181           end of slis_subtot_text.
182
183    *** Layout
184    types: begin of slis_print_alv0,
185             print(1) type c,              " print to spool
186             prnt_title(1) type c,         " moment to print the title
187           end of slis_print_alv0.
188
189    types: begin of slis_print_alv1,
190             no_print_selinfos(1) type c,  " display no selection infos
191             no_coverpage(1) type c,                            "
192             no_new_page(1) type c,                             "
193             reserve_lines type i,         " lines reserved for end of page
194             no_print_listinfos(1) type c, " display no listinfos
195             no_change_print_params(1) type c,  " don't change linesize
196             no_print_hierseq_item(1) type c,  "don't expand item
197             print_ctrl type ALV_S_Pctl,
198           end of slis_print_alv1.
199
200    types: begin of slis_print_alv.
201    include type alv_s_prnt.
202    include type slis_print_alv1.
203    types: end of slis_print_alv.
204
205    types: begin of slis_layout_main,
206             dummy,
207           end of slis_layout_main.
208
209    types: begin of slis_layout_alv_spec0,
210             no_colhead(1) type c,         " no headings
211             no_hotspot(1) type c,         " headings not as hotspot
212             zebra(1) type c,              " striped pattern
213             no_vline(1) type c,           " columns separated by space
214             no_hline(1) type c,        "rows separated by space B20K8A0N5D
215             cell_merge(1) type c,         " not suppress field replication
216             edit(1) type c,               " for grid only
217             edit_mode(1) type c,          " for grid only
218             numc_sum(1)     type c,       " totals for NUMC-Fields possib.
219             no_input(1) type c,           " only display fields
220             f2code like sy-ucomm,                              "
221             reprep(1) type c,             " report report interface active
222             no_keyfix(1) type c,          " do not fix keycolumns
223             expand_all(1) type c,         " Expand all positions
224             no_author(1) type c,          " No standard authority check
225    *        PF-status
226             def_status(1) type c,         " default status  space or 'A'
227             item_text(20) type c,         " Text for item button
228             countfname type lvc_fname,
229           end of slis_layout_alv_spec0.
230
231    types: begin of slis_layout_alv_spec1,
232    *        Display options
233             colwidth_optimize(1) type c,
234             no_min_linesize(1) type c,    " line size = width of the list
235             min_linesize like sy-linsz,   " if initial min_linesize = 80
236             max_linesize like sy-linsz,   " Default 250
237             window_titlebar like sy-title,
238             no_uline_hs(1) type c,
239    *        Exceptions
240             lights_fieldname type slis_fieldname," fieldname for exception
241             lights_tabname type slis_tabname, " fieldname for exception
242             lights_rollname like dfies-rollname," rollname f. exceptiondocu
243             lights_condense(1) type c,    " fieldname for exception
244    *        Sums
245             no_sumchoice(1) type c,       " no choice for summing up
246             no_totalline(1) type c,       " no total line
247             no_subchoice(1) type c,       " no choice for subtotals
248             no_subtotals(1) type c,       " no subtotals possible
249             no_unit_splitting type c,     " no sep. tot.lines by inh.units
250             totals_before_items type c,   " diplay totals before the items
251             totals_only(1) type c,        " show only totals
252             totals_text(60) type c,       " text for 1st col. in total line
253             subtotals_text(60) type c,    " text for 1st col. in subtotals
254    *        Interaction
255             box_fieldname type slis_fieldname, " fieldname for checkbox
256             box_tabname type slis_tabname," tabname for checkbox
257             box_rollname like dd03p-rollname," rollname for checkbox
258             expand_fieldname type slis_fieldname, " fieldname flag 'expand'
259             hotspot_fieldname type slis_fieldname, " fieldname flag hotspot
260             confirmation_prompt,          " confirm. prompt when leaving
261             key_hotspot(1) type c,        " keys as hotspot " K_KEYHOT
262             flexible_key(1) type c,       " key columns movable,...
263             group_buttons(1) type c,      " buttons for COL1 - COL5
264             get_selinfos(1) type c,       " read selection screen
265             group_change_edit(1) type c,  " Settings by user for new group
266             no_scrolling(1) type c,       " no scrolling
267    *        Detailed screen
268             detail_popup(1) type c,       " show detail in popup
269             detail_initial_lines(1) type c, " show also initial lines
270             detail_titlebar like sy-title," Titlebar for detail
271    *        Display variants
272             header_text(20) type c,       " Text for header button
273             default_item(1) type c,       " Items as default
274    *        colour
275             info_fieldname type slis_fieldname, " infofield for listoutput
276             coltab_fieldname type slis_fieldname, " colors
277    *        others
278             list_append(1) type c,       " no call screen
279             xifunckey type aqs_xikey,    " eXtended interaction(SAPQuery)
280             xidirect type flag,          " eXtended INTeraction(SAPQuery)
281             dtc_layout type dtc_s_layo,  "Layout for configure the Tabstip
282             allow_switch_to_list(1) type c, "ACC: Switch from FullGrid to List
283           end of slis_layout_alv_spec1.
284
285    types: begin of slis_layout_alv_spec.
286    include type slis_layout_alv_spec0.
287    include type slis_layout_alv_spec1.
288    types: end of slis_layout_alv_spec.
289
290    types: begin of slis_layout_alv.
291    include type slis_layout_main.
292    include type slis_layout_alv_spec.
293    types: end of slis_layout_alv.
294
295    types: begin of slis_layout_alv1.
296    include type slis_layout_main.
297    include type slis_layout_alv_spec1.
298    types: end of slis_layout_alv1.
299
300    *--- Structure for the excluding table (function codes)
301    types: begin of slis_extab,
302             fcode like rsmpe-func,
303           end of slis_extab.
304    *--- Lineinfo before output
305    types: begin of slis_lineinfo,
306             tabname type slis_tabname,
307             tabindex like sy-tabix,
308             subtot(1) type c,
309             subtot_level(2) type n,
310             endsum(1) type c,
311             sumindex like sy-tabix,
312             linsz like sy-linsz,
313             linno like sy-linno,
314           end of slis_lineinfo.
315    *--- Structure for scrolling in list
316    types: begin of slis_list_scroll,
317             lsind like sy-lsind,
318             cpage like sy-cpage,
319             staro like sy-staro,
320             staco like sy-staco,
321             cursor_line like sy-curow,
322             cursor_offset like sy-cucol,
323           end of slis_list_scroll.
324    * information cursor position ALV
325    types: begin of slis_selfield,
326             tabname type slis_tabname,
327             tabindex like sy-tabix,
328             sumindex like sy-tabix,
329             endsum(1) type c,
330             sel_tab_field type slis_sel_tab_field,
331             value type slis_entry,
332             before_action(1) type c,
333             after_action(1) type c,
334             refresh(1) type c,
335             ignore_multi(1) type c, " ignore selection by checkboxes (F2)
336             col_stable(1) type c,
337             row_stable(1) type c,
338    *        colwidth_optimize(1) type c,
339             exit(1) type c,
340             fieldname type slis_fieldname,
341             grouplevel type i,
342             collect_from type i,
343             collect_to type i,
344           end of slis_selfield.
345
346    *--- excluding table
347    types: slis_t_extab type slis_extab occurs 1.
348    * special groups for column selection
349    types: begin of slis_sp_group_alv,
350             sp_group(4) type c,
351             text(40) type c,
352           end of slis_sp_group_alv.
353    types: slis_t_sp_group_alv type slis_sp_group_alv occurs 1.
354
355    * information for sort and subtotals
356    types: begin of slis_sortinfo_alv,
357    *        spos(2) type n,
358             spos like alvdynp-sortpos,
359             fieldname type slis_fieldname,
360             tabname type slis_fieldname,
361    *        up(1) type c,
362    *        down(1) type c,
363    *        group(2) type c,
364    *        subtot(1) type c,
365             up like alvdynp-sortup,
366             down like alvdynp-sortdown,
367             group like alvdynp-grouplevel,
368             subtot like alvdynp-subtotals,
369             comp(1) type c,
370             expa(1) type c,
371             obligatory(1) type c,
372           end of slis_sortinfo_alv.
373    types: slis_t_sortinfo_alv type slis_sortinfo_alv occurs 1.
374    * information for selections
375    types: begin of slis_seldis1_alv,
376             field like dfies-fieldname,
377             table like dfies-tabname,
378             stext(40),
379             valuf(80),
380             valut(80),
381             sign0(1),
382             optio(2),
383             ltext(40),
384             stype(1),
385             length type p,
386             no_text(1),
387             inttype like dfies-inttype,
388             fieldname type slis_fieldname,
389             tabname type slis_tabname,
390             org_selname type rsscr_name,  "introduced this FO 09.01.00
391           end of slis_seldis1_alv.
392
393    types: slis_seldis_alv type slis_seldis1_alv occurs 1.
394
395    * filter
396    types: begin of slis_filter_alv0,
397             fieldname type slis_fieldname,
398             tabname type slis_tabname,
399             seltext(40),
400             valuf(80),
401             valut(80),
402             valuf_int(80),
403             valut_int(80),
404             sign0(1),
405             sign_icon(4),
406             optio(2),
407             stype(1),
408             decimals like dfies-decimals,
409             intlen like dfies-intlen,
410             convexit like dfies-convexit,
411             edit_mask type slis_edit_mask,
412             lowercase like dfies-lowercase,
413             inttype like dfies-inttype,
414             datatype like dfies-datatype,
415             exception(1) type c,
416             no_sign(1) type c,
417             or(1) type c,
418             order type order,
419             cqvalue(5) type c,
420           end of slis_filter_alv0.
421
422    types: begin of slis_filter_alv1,
423             ref_fieldname like dfies-fieldname,
424             ref_tabname like dfies-tabname,
425             ddic_outputlen like dfies-outputlen,
426           end of slis_filter_alv1.
427
428    types: begin of slis_filter_alv.
429    include type slis_filter_alv0.
430    include type slis_filter_alv1.
431    types: end of slis_filter_alv.
432    types: slis_t_filter_alv type slis_filter_alv occurs 1.
433
434    * delete or add an entry in the select-option info
435    types: begin of slis_selentry_hide_alv,
436             mode(1) type c,               "(D)elete (A)dd
437             selname like rsparams-selname.
438    include type slis_seldis1_alv.
439    types  end of slis_selentry_hide_alv.
440    types: slis_t_selentry_hide_alv type slis_selentry_hide_alv occurs 1.
441
442    * delete or add an entry in the select-option info
443    types: begin of slis_sel_hide_alv,
444             mode(1) type c,               "(R)eplace or (C)hange
445             t_entries type slis_t_selentry_hide_alv,
446           end of slis_sel_hide_alv.
447    * Header table for top of page
448    types: begin of slis_listheader,
449             typ(1) type c,   " H = Header, S = Selection, A = Action
450             key(20) type c,
451             info type slis_entry,
452           end of slis_listheader.
453    types: slis_t_listheader type slis_listheader occurs 1.
454    *--- Structure for specific color settings
455    types: begin of slis_specialcol_alv,
456             fieldname type slis_fieldname,
457             color     type slis_color,
458             nokeycol(1) type c,
459           end of slis_specialcol_alv.
460    types: slis_t_specialcol_alv type slis_specialcol_alv occurs 1.
461    *--- Structure for event handling
462    types: begin of slis_alv_event,
463            name(30),
464            form(30),
465          end of slis_alv_event.
466    types: slis_t_event type slis_alv_event occurs 0.
467    *--- Structure for key information
468    types: begin of slis_keyinfo_alv,
469             header01 type slis_fieldname,
470             item01 type slis_fieldname,
471             header02 type slis_fieldname,
472             item02 type slis_fieldname,
473             header03 type slis_fieldname,
474             item03 type slis_fieldname,
475             header04 type slis_fieldname,
476             item04 type slis_fieldname,
477             header05 type slis_fieldname,
478             item05 type slis_fieldname,
479           end of slis_keyinfo_alv.
480    *--- Structure for callback CALLER_EXIT and REUSE_ALV_POPUP_TO_SELECT
481    types: begin of slis_data_caller_exit,
482            dummy like sy-repid,
483            without_load_variant(1),
484            callback_header_transport type slis_formname,
485            columnopt(1),
486          end of slis_data_caller_exit.
487
488    types: begin of slis_status,
489             callback_program like sy-repid,
490             callback_pf_status_set type slis_formname,
491             callback_user_command  type slis_formname,
492             counter_of_lists_added type i,
493             actual_list_to_display type i,
494             flg_to_be_refreshed,
495             it_excluding type slis_t_extab,
496             print type slis_print_alv,
497             flg_checkboxes_active,
498             flg_overview_active,
499             flg_intcheck(1) type c,
500           end of slis_status.
501    * Exporting structure
502    types: begin of slis_exit_by_user,
503             back(1) type c,
504             exit(1) type c,
505             cancel(1) type c,
506           end of slis_exit_by_user.
507
508    constants:
509    * Events
510    slis_ev_item_data_expand   type slis_formname value 'ITEM_DATA_EXPAND',
511    slis_ev_reprep_sel_modify  type slis_formname value 'REPREP_SEL_MODIFY',
512    slis_ev_caller_exit_at_start type slis_formname value 'CALLER_EXIT',
513    slis_ev_user_command       type slis_formname value 'USER_COMMAND',
514    slis_ev_top_of_page        type slis_formname value 'TOP_OF_PAGE',
515    slis_ev_data_changed       type slis_formname value 'DATA_CHANGED',
516    slis_ev_top_of_coverpage   type slis_formname value 'TOP_OF_COVERPAGE',
517    slis_ev_end_of_coverpage   type slis_formname value 'END_OF_COVERPAGE',
518    slis_ev_foreign_top_of_page type slis_formname
519                                           value 'FOREIGN_TOP_OF_PAGE',
520    slis_ev_foreign_end_of_page type slis_formname
521                                           value 'FOREIGN_END_OF_PAGE',
522    slis_ev_pf_status_set      type slis_formname value 'PF_STATUS_SET',
523    slis_ev_list_modify        type slis_formname value 'LIST_MODIFY',
524    slis_ev_top_of_list        type slis_formname value 'TOP_OF_LIST',
525    slis_ev_end_of_page        type slis_formname value 'END_OF_PAGE',
526    slis_ev_end_of_list        type slis_formname value 'END_OF_LIST',
527    slis_ev_after_line_output  type slis_formname value 'AFTER_LINE_OUTPUT',
528    slis_ev_before_line_output type slis_formname value
529                                                       'BEFORE_LINE_OUTPUT',
530    slis_ev_subtotal_text      type slis_formname value 'SUBTOTAL_TEXT',
531    slis_ev_grouplevel_change  type slis_formname value 'GROUPLEVEL_CHANGE',
532    slis_ev_context_menu       type slis_formname value 'CONTEXT_MENU',
533
534    slis_ev_print_top_of_list  type slis_formname value 'PRINT_TOP_OF_LIST',
535    slis_ev_print_end_of_list  type slis_formname value 'PRINT_END_OF_LIST'.
536
537    *lowercase for DDIC_SCAN
538    types: slis_fieldinfo type fieldinfo.
539    types: begin of slis_fieldinfo2.
540    types: lowercase type c.
541           include type slis_fieldinfo.
542    types: end of slis_fieldinfo2.
543    types: slis_t_fieldinfo2 type standard table of slis_fieldinfo2.
*--- End of %_CSLIS - 543 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CSSCR                                   Level 1    Page 12
Object           ZJV_SAPF100                               Lines 68
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:11
----------------------------------------------------------------------------------------------------
1      TYPE-POOL SSCR .
2
3      * One list of options
4      TYPES: BEGIN OF SSCR_OPT_LIST,
5               NAME    LIKE RSRESTRICT-OPTIONLIST,
6               OPTIONS LIKE RSOPTIONS,
7             END   OF SSCR_OPT_LIST.
8
9      * List of option lists
10     TYPES: SSCR_OPT_LIST_TAB TYPE SSCR_OPT_LIST OCCURS 5.
11
12     * One line of table associating selection screen object with opt. list
13     TYPES: BEGIN OF SSCR_ASS,
14              KIND LIKE RSSCR-KIND,         " A(ll), B(lock), S(elect-Option)
15              NAME LIKE RSRESTRICT-OBJECTNAME,  " Blockname, maximal 20
16              SG_MAIN LIKE RSRESTRICT-SIGN, " (only) I, SPACE = both
17              SG_ADDY LIKE RSRESTRICT-SIGN, " additional SIGN
18                                            " on multiple selection screen
19              OP_MAIN LIKE RSRESTRICT-OPTIONLIST, " name of option list for
20                                            " main selection screen
21              OP_ADDY LIKE RSRESTRICT-OPTIONLIST, " name of additional option
22                                     " list for multiple selection screen
23            END   OF SSCR_ASS.
24     * The association table
25     TYPES: SSCR_ASS_TAB TYPE SSCR_ASS OCCURS 20.
26     * The type for SELECT_OPTIONS_RESTRICT (to be extended)
27     TYPES: BEGIN OF SSCR_RESTRICT,
28              OPT_LIST_TAB TYPE SSCR_OPT_LIST_TAB,
29              ASS_TAB     TYPE SSCR_ASS_TAB,
30            END   OF SSCR_RESTRICT.
31     * Restrictions for one program
32     TYPES: BEGIN OF SSCR_RESTRICT_1_PROG,
33              PROGRAM LIKE SY-REPID,
34              RESTRICT TYPE SSCR_RESTRICT,
35            END   OF SSCR_RESTRICT_1_PROG.
36     * Restrictions for all programs
37     TYPES:  SSCR_RESTRICT_T TYPE SSCR_RESTRICT_1_PROG OCCURS 5.
38
39     * FREE SELECTIONS
40     * One line of table associating selection screen object with opt. list
41     TYPES: BEGIN OF SSCR_ASS_DS,
42              KIND LIKE RSSCR-KIND,         " A(ll), S(elect-Option)
43              TABLENAME LIKE RSDSTABS-PRIM_TAB,
44              FIELDNAME LIKE RSDSTABS-PRIM_FNAME,
45              SG_MAIN LIKE RSRESTRICT-SIGN, " (only) I, SPACE = both
46              SG_ADDY LIKE RSRESTRICT-SIGN, " additional SIGN
47                                            " on multiple selection screen
48              OP_MAIN LIKE RSRESTRICT-OPTIONLIST, " name of option list for
49                                            " main selection screen
50              OP_ADDY LIKE RSRESTRICT-OPTIONLIST, " name of additional option
51                                     " list for multiple selection screen
52            END   OF SSCR_ASS_DS.
53     * The association table
54     TYPES: SSCR_ASS_DS_TAB TYPE SSCR_ASS_DS OCCURS 20.
55     * The type for FREE_SELECTIONS_INIT (to be extended)
56     TYPES: BEGIN OF SSCR_RESTRICT_DS,
57              OPT_LIST_TAB TYPE SSCR_OPT_LIST_TAB,
58              ASS_TAB      TYPE SSCR_ASS_DS_TAB,
59            END   OF SSCR_RESTRICT_DS.
60
61     types: begin of sscr_curr_quan,
62             tablename like rsdstabs-prim_tab,
63             fieldname like rsdstabs-prim_fname,
64             reffield  like rsscr-dbfield,
65             def_value type sy-waers,
66            end of sscr_curr_quan.
67
68     types: sscr_curr_quan_t type sscr_curr_quan occurs 0.
*--- End of %_CSSCR - 68 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  <CONTRO>                                  Level 1    Page 13
Object           ZJV_SAPF100                               Lines 76
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:11
----------------------------------------------------------------------------------------------------
1      *----------------------------------------------------------------------*
2      * INCLUDE <CONTRO>                                                     *
3      * Definitions for control types                                        *
4      *----------------------------------------------------------------------*
5      TYPE-POOLS  CXTAB.
6
7      TYPES       CX_BOOL(1) TYPE C.
8      CONSTANTS:
9                  CX_TRUE  TYPE CX_BOOL VALUE 'X',
10                 CX_FALSE TYPE CX_BOOL VALUE ' '.
11
12     TYPES       %_CX_ID TYPE I.
13     CONSTANTS:  %_CX_GRID_ID      TYPE %_CX_ID VALUE 1,
14                 %_CX_TABLEVIEW_ID TYPE %_CX_ID VALUE 2,
15                 %_CX_TABSTRIP_ID  TYPE %_CX_ID VALUE 3.
16
17     TYPES       %_CX_VERSION TYPE I.
18     CONSTANTS:  %_CX_TABLEVIEW_VERSION VALUE 0,
19                 %_CX_TABSTRIP_VERSION VALUE  0.
20
21     DEFINE %_CX_HEAD.        "Cx_Name, %_CX_ID, %_CX_version,
22       DATA ID      TYPE %_CX_ID       VALUE &2.
23       DATA VERSION TYPE %_CX_version  VALUE &3.
24       DATA NAME    LIKE SCREEN-NAME   VALUE '&1'.
25     END-OF-DEFINITION.
26
27     DEFINE CX_SHOW.
28       CALL 'ab_SetVisibleCx' ID 'PROGRAM' FIELD SY-REPID
29                              ID 'CONTROL' FIELD &1
30                              ID 'VISIBLE' FIELD 1.
31     END-OF-DEFINITION.
32
33     DEFINE CX_HIDE.
34       CALL 'ab_SetVisibleCx' ID 'PROGRAM' FIELD SY-REPID
35                              ID 'CONTROL' FIELD &1
36                              ID 'VISIBLE' FIELD 0.
37     END-OF-DEFINITION.
38
39     DEFINE CX_LOAD_DEFAULT.
40       CALL FUNCTION 'INIT_TC'
41         EXPORTING PG     = SY-REPID
42                   TCNAME = '&1'
43         CHANGING  TC     = &1.
44     END-OF-DEFINITION.
45
46     *>>-------- TableView -----------------------------------------------
47     TYPES: CX_TABLEVIEW_COLUMN TYPE CXTAB_COLUMN,
48            CX_TABLEVIEW        TYPE CXTAB_CONTROL.
49
50     DEFINE %_CX_TABLEVIEW-*CX*. "Instanzname, Referenzdynpro
51       DATA: BEGIN OF &1-*CX*.
52       %_CX_HEAD &1 %_CX_TABLEVIEW_ID %_CX_TABLEVIEW_VERSION.
53       DATA: DYNNR(4) TYPE N VALUE &2.
54       DATA: TOP_LINE TYPE CX_TABLEVIEW-TOP_LINE VALUE 1.
55       DATA: FILL1(8).
56       DATA: END   OF &1-*CX*.
57       DATA: &1 TYPE CX_TABLEVIEW.
58     END-OF-DEFINITION.
59     *<<-------- TableView -----------------------------------------------
60
61     * TabStrip
62     TYPES:
63       CX_TABSTRIP TYPE CXTAB_TABSTRIP.
64
65
66     DEFINE %_CX_TABSTRIP-*CX*.
67       DATA: BEGIN OF &1-*CX*.
68       %_CX_HEAD &1 %_CX_TABSTRIP_ID %_CX_TABSTRIP_VERSION.
69       DATA: FILL(4).
70       DATA: END OF &1-*CX*.
71       DATA: &1 TYPE CX_TABSTRIP.
72     END-OF-DEFINITION.
73
74     *
75     * TabStrip
76     * **********************************************************************
*--- End of <CONTRO> - 76 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  <ICON>                                    Level 1    Page 14
Object           ZJV_SAPF100                               Lines 6
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:11
----------------------------------------------------------------------------------------------------
1      ***INCLUDE <icon> .
2      *-----------------------------------------------------------------------
3      *  Instead of statement 'INCLUDE <icon>.', please use
4      *  statement 'TYPE-POOLS: icon.' directly.
5      *-----------------------------------------------------------------------
6      TYPE-POOLS: icon.
*--- End of <ICON> - 6 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  <LINE>                                    Level 1    Page 15
Object           ZJV_SAPF100                               Lines 18
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:11
----------------------------------------------------------------------------------------------------
1      *** Include <LINE>.
2      *-----------------------------------------------------------------------
3      *  Instead of statement 'INCLUDE <line>.', please use
4      *  statement 'TYPE-POOLS: line.' directly.
5      *-----------------------------------------------------------------------
6      TYPE-POOLS: line.
7
8
9
10
11
12
13
14
15
16
17
18
*--- End of <LINE> - 18 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  <REPINI>                                  Level 1    Page 16
Object           ZJV_SAPF100                               Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:11
----------------------------------------------------------------------------------------------------
1      * ABAP/4 Logical Databases
2      *
3      *
4      MODULE %_pf_status OUTPUT.
5        PERFORM set_pf_status IN PROGRAM rsdbrunt.
6      ENDMODULE.
7      *
8      MODULE %_end_of_pbo OUTPUT.
9        PERFORM %_end_of_pbo IN PROGRAM rsdbrunt.
10     ENDMODULE.
11     *
12     MODULE %_init_pai.
13       PERFORM %_init_pai IN PROGRAM rsdbrunt.
14     ENDMODULE.
15     *
16     MODULE %_ok_code_1000.
17       PERFORM %_ok_code_1000 IN PROGRAM rsdbrunt.
18     ENDMODULE.
19     *
20     MODULE %_back.
21       PERFORM %_back_1000 IN PROGRAM rsdbrunt.
22     ENDMODULE.
23     *
*--- End of <REPINI> - 23 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  <SYSINI>                                  Level 1    Page 17
Object           ZJV_SAPF100                               Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:11
----------------------------------------------------------------------------------------------------
1      * ABAP System Include for all programs
2
3      constants SPACE value ' ' %_predefined.
4
5      * Access to SYST fields via SY
6      tables: SYST,
7              sy %%internal%%.
8
9      * Common Part for LOOP AT SCREEN and Printing
10     data: begin of common part %_SYS%%,
11             SCREEN    type SCREEN,
12             %_PRINT   type PRI_PARAMS,
13             %_ARCHIVE type ARC_PARAMS,
14           end   of common part.
15
16     *
17     system-exit.
18       perform (SY-XFORM) in program (SY-XPROG).
19
20     * Processing at the End of a Dynpro
21     module %_CTL_END input.
22       perform %_CTL_END in program SAPMSSYD using SY-REPID if found.
23     endmodule.
24
25     * Exit for Transaction Variants
26     module %_HDSYSPAI input.
27       perform %_HDSYSPAI in program SAPMSSYD using SY-REPID if found.
28     endmodule.
*--- End of <SYSINI> - 28 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  <SYSSEL>                                  Level 1    Page 18
Object           ZJV_SAPF100                               Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:11
----------------------------------------------------------------------------------------------------
1      * ABAP/4-System Include
2      * bei logischen Datenbanken in ABAP/4 und
3      * CALL SELECTION-SCREEN
4      *
5      *     Select-Options
6      DATA BEGIN OF COMMON PART %_SSCR.
7      DATA BEGIN OF %_SSCR OCCURS 1.
8      INCLUDE STRUCTURE RSSCR.
9      DATA END OF %_SSCR.
10     DATA END OF COMMON PART %_SSCR.
*--- End of <SYSSEL> - 10 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  >ICON<                                    Level 1    Page 19
Object           ZJV_SAPF100                               Lines 24
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:11
----------------------------------------------------------------------------------------------------
1      ***INCLUDE >ICON< .
2      *** INCLUDE for INCLUDE <ICON>, Definition of Icons                  ***
3
4      * Icon length 2
5      DEFINE ICON_2.
6      CONSTANTS:   &1 TYPE ICON_L2 VALUE  &2.
7      END-OF-DEFINITION.
8
9      * Icon length 4
10     DEFINE ICON_4.
11     CONSTANTS:   &1 TYPE ICON_L4 VALUE  &2.
12     END-OF-DEFINITION.
13
14
15     DEFINE ICON_PREPARE_FOR_MODIFY.
16     * trunkate ICON_ID, e.g.  '@3M@' --> '3M'
17       TRANSLATE &1 USING '@ '.
18       CONDENSE  &1 NO-GAPS.
19     END-OF-DEFINITION.
20
21
22
23
24
*--- End of >ICON< - 24 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  DBD$SSEL                                  Level 1    Page 20
Object           ZJV_SAPF100                               Lines 1
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:11
----------------------------------------------------------------------------------------------------
1      * INCLUDE DBD$SSEL
*--- End of DBD$SSEL - 1 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  OSQL_DYNAMIC_EXTERNAL_ENTITIESCCDEF       Level 1    Page 21
Object           ZJV_SAPF100                               Lines 4
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:11
----------------------------------------------------------------------------------------------------
1      *"* use this source file for any type of declarations (class
2      *"* definitions, interfaces or type declarations) you need for
3      *"* components in the private section
4
*--- End of OSQL_DYNAMIC_EXTERNAL_ENTITIESCCDEF - 4 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  OSQL_DYNAMIC_EXTERNAL_ENTITIESCI          Level 1    Page 22
Object           ZJV_SAPF100                               Lines 2
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:11
----------------------------------------------------------------------------------------------------
1        private section.
2          class-data: s_dynamic_entities type dynamic_entities.
*--- End of OSQL_DYNAMIC_EXTERNAL_ENTITIESCI - 2 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  OSQL_DYNAMIC_EXTERNAL_ENTITIESCO          Level 1    Page 23
Object           ZJV_SAPF100                               Lines 1
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:11
----------------------------------------------------------------------------------------------------
1        protected section.
*--- End of OSQL_DYNAMIC_EXTERNAL_ENTITIESCO - 1 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  OSQL_DYNAMIC_EXTERNAL_ENTITIESCU          Level 1    Page 24
Object           ZJV_SAPF100                               Lines 17
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:11
----------------------------------------------------------------------------------------------------
1      class osql_dynamic_external_entities definition
2        public
3        final
4        create private .
5
6        public section.
7           types: begin of dynamic_entity,
8                     client type mandt,
9                     name type dd_cds_entity_name,
10                    logical_schema type dd_les_name,
11                    db_name type dbviewname,
12                    db_name_terminator type C length 1,
13                    db_name_len type i,
14                 end of dynamic_entity,
15                 dynamic_entities type standard table of dynamic_entity with empty key without further secondary keys.
16         class-methods: check_and_create,
17                        test.
*--- End of OSQL_DYNAMIC_EXTERNAL_ENTITIESCU - 17 lines ---
