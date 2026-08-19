----------------------------------------------------------------------------------------------------
Main program     SAPMZFM06B                                Level 0    Page 1
Object           SAPMZFM06B                                Lines 53
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *{   INSERT         SO4K000142                                        1
2      * SO3K120926 cp SAP OIL & GAS amendment TDP
3      *}   INSERT
4      ************************************************************************
5      *        Listanzeige Bestellanforderungen                              *
6      ************************************************************************
7      ************************************************************************
8      * Date        Transport     USERID     Description
9      * 13/09/2008  <RD1K960036>  SAB_PUNIT  1) Change in the include
10     *                                         MZFM06BTOP.
11     *                                      2) Added include prog add form
12     *                                         defination
13     ************************************************************************
14     *-- Datenteil ---------------------------------------------------------*
15     INCLUDE MZFM06BTOP.
16     *INCLUDE FM06BTOP.
17
18     * begin of <RD1K960036>
19     * Added include prog to resolve the error "Form authority_beswk does
20     * not exists"
21     INCLUDE FM06B_AUTHORITY_BESWKF01.
22     * end of <RD1K960036>
23
24     *-- Routinen für die Listaufbereitung ---------------------------------*
25     INCLUDE MZFM06BF01.
26     *INCLUDE FM06BF01.
27
28     *-- User-Command-Routinen ---------------------------------------------*
29     INCLUDE FM06BF02.
30
31     *-- Routinen für interaktive Bearbeitung der Grundliste ---------------*
32     INCLUDE MZFM06BF03.
33     *INCLUDE FM06BF03.
34
35     *-- Allgemeine Unterroutinen ------------------------------------------*
36     INCLUDE FM06BF04.
37
38     *-- Routinen für interaktive Bearbeitung der Zuorddnungsliste ---------*
39     INCLUDE FM06BF05.
40
41     *-- Unterroutinen zur Tabelle ALF - Mehrere Lieferanten zur Anfragebear.
42     INCLUDE FM06BFAL.
43     *-- Unterroutinen zur Listaufbereitung der Grundliste -----------------*
44     INCLUDE FM06BFLI.
45     INCLUDE FM06BFLZ.             "Kundenspezifische Routinen
46     *-- Unterroutinen zur zusätzlichen Datenbeschaffung -------------------*
47     INCLUDE FM06BFDA.
48     INCLUDE FM06BFDZ.             "Kundenspezifische Routinen
49     *-- Unterroutinen aus Selektionsreports -------------------------------*
50     INCLUDE FM06BFSL.
51     *{   INSERT         SO4K000142                                        2
52     INCLUDE FM06BFOI.                                         "SO3K120926 cp
53     *}   INSERT
*--- End of SAPMZFM06B - 53 lines ---

----------------------------------------------------------------------------------------------------
Include          MZFM06BTOP                                Level 1    Page 2
Object           SAPMZFM06B                                Lines 596
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      ************************************************************************
2      *        Listanzeige Bestellanforderungen                              *
3      ************************************************************************
4      REPORT SAPFM06B MESSAGE-ID ME.
5      ************************************************************************
6      * Date        Transport     USERID     Description
7      * 13/09/2008  <RD1K960036>  SAB_PUNIT  1) Modifed the data declaration
8      *                                         as per the new include prog
9      *                                         FM06BTOP
10     ************************************************************************
11     *{   INSERT         SOGK021244                                        1
12     *3.1h to 4.0B migration 03.07.98 VB SO4K000089  Oil enhancement
13     *}   INSERT
14
15     *----------------------------------------------------------------------*
16     *        Tabellen                                                      *
17     *----------------------------------------------------------------------*
18     TABLES: T001W,                         "Werkstabelle
19             T001K,
20             T001,
21             EBAN,
22            *EBAN,
23             EBKN,
24             EKKO,
25             EKPO,
26            *EKKO,
27             EORD,
28             LFA1,
29             LFM1,
30             MEICO,
31             EINA,
32             EINE,
33             ESSR,
34             RM06E,
35             RM06B,
36             MT06E,
37             MTCOM,
38             MTCOR,
39             MT06K,
40             MT61D, *MT61D,
41             MAPRF, *MAPRF,
42             PROPF,
43             PROWF,
44             MARA,
45             MT61B,
46             MDSTA, *MDSTA,
47             MDKP, "#EC CI_USAGE_OK[2268085]
48             CM61X,
49             CM61M,
50             CM61W,
51             IVERB, *IVERB,
52             MDBS,
53             BQPIM,   "Bezugsquelle Export
54             BQPEX,   "Bezugsquelle Import
55             T002,
56             T006,
57             T024E,
58             T160,
59             T160M,
60             T160D, T160V,
61             T161,
62             T161T,
63             T161A,
64             T161S,
65             T161U,
66             T16FT,
67             T024W,   "Lieferantenbeurteilung 'Ermitteln Ekorg's pro Werk'
68             T16LA,
69            *T16LA,
70             T16LB,
71             T16LD,
72             T16LH,
73             T16LI,
74             T16LL,
75             T399D,
76             T438A, "#EC CI_USAGE_OK[3211383]
77             T438M,
78             TMPPF,                          "HTN-Abwicklung 4.0
79             TCURM.  "Konsi-Abwicklung 4.0
80
81     *... Ikonen ..........................................................*
82     INCLUDE <ICON>.
83     DATA: ICON_FIELD LIKE ICON_RED_LIGHT.
84
85     *----------------------------------------------------------------------*
86     *        Interne Tabellen                                              *
87     *----------------------------------------------------------------------*
88     *-- Tabelle der selektierten Banfs ------------------------------------*
89     DATA: BEGIN OF BAN OCCURS 100.
90              INCLUDE STRUCTURE EBAN.
91     DATA:    UPDK1 LIKE T16LA-UPDKZ,     "Status der Zuordnung
92              UPDK2 LIKE T16LA-UPDKZ,     "Status der Zuordnung (alt)
93              UPDK3 LIKE T16LA-UPDKZ,     "Sicherungsstatus
94              SELKF(2) TYPE P,            "Kz. für Sammelfreigabe
95              SELKZ,                      "Selektiert ja/nein
96              SZEIL LIKE SY-CUROW,        "Zeilennr. des Selektionskz.
97              ZEILE LIKE SY-CUROW,        "Zeilennr. der Zuordnungsinfo
98              PAGE  LIKE SY-PAGNO,        "Seite
99              AENDA,                      "Kz. Berecht. für Änderungsbeleg
100             BUKRS LIKE EKKO-BUKRS,      "Buchungskreis für Buchungskreisüb.
101             SLIEF LIKE EBAN-FLIEF,      "Lieferant für Sortierung
102             BKMKZ,                      "Art der Kontierung      "4.0C
103             KONT1(24),                  "Kontierungsfeld 1       "4.0C
104             KONT2(8),                   "Kontierungsfeld 2
105             BKUML,                      "Kz. Bukrs-übergreifende Umlagerung
106             AZ_POS TYPE I,              "Anzahl Pos. pro Banf
107             SL_POS TYPE I,              "Anzahl selektierter Pos. pro Banf
108             ARCH_DATE LIKE SY-DATLO,    "Archivierungsdatum "TK 4.0B EURO
109          END OF BAN.
110    *... Banf-Tabelle zum Sortieren bei Gesamtbanfen .....................*
111    DATA: BEGIN OF BAN_GS OCCURS 100.
112             INCLUDE STRUCTURE EBAN.
113    DATA:    UPDK1 LIKE T16LA-UPDKZ,     "Status der Zuordnung
114             UPDK2 LIKE T16LA-UPDKZ,     "Status der Zuordnung (alt)
115             UPDK3 LIKE T16LA-UPDKZ,     "Sicherungsstatus
116             SELKF(2) TYPE P,            "Kz. für Sammelfreigabe
117             SELKZ,                      "Selektiert ja/nein
118             SZEIL LIKE SY-CUROW,        "Zeilennr. des Selektionskz.
119             ZEILE LIKE SY-CUROW,        "Zeilennr. der Zuordnungsinfo
120             PAGE  LIKE SY-PAGNO,        "Seite
121             AENDA,                      "Kz. Berecht. für Änderungsbeleg
122             BUKRS LIKE EKKO-BUKRS,      "Buchungskreis für Buchungskreisüb.
123             SLIEF LIKE EBAN-FLIEF,      "Lieferant für Sortierung
124             BKMKZ,                      "Art der Kontierung        "4.0C
125             KONT1(24),                  "Kontierungsfeld 1         "4.0C
126             KONT2(8),                   "Kontierungsfeld 2
127             BKUML,                      "Kz. Bukrs-übergreifende Umlagerung
128             AZ_POS TYPE I,              "Anzahl Pos. pro Banf
129             SL_POS TYPE I,              "Anzahl selektierter Pos. pro Banf
130             ARCH_DATE LIKE SY-DATLO,    "Archivierungsdatum "TK 4.0B EURO
131          END OF BAN_GS.
132    DATA: BEGIN OF BAN2.
133             INCLUDE STRUCTURE EBAN.
134    DATA:    UPDK1 LIKE T16LA-UPDKZ,     "Status der Zuordnung
135             UPDK2 LIKE T16LA-UPDKZ,     "Status der Zuordnung (alt)
136             UPDK3 LIKE T16LA-UPDKZ,     "Sicherungsstatus
137             SELKF(2) TYPE P,            "Kz. für Sammelfreigabe
138             SELKZ,                      "Selektiert ja/nein
139             SZEIL LIKE SY-CUROW,        "Zeilennr. des Selektionskz.
140             ZEILE LIKE SY-CUROW,        "Zeilennr. der Zuordnungsinfo
141             PAGE  LIKE SY-PAGNO,        "Seite
142             AENDA,                      "Kz. Berecht. für Änderungsbeleg
143             SLIEF LIKE EBAN-FLIEF,      "Lieferant für Sortierung
144             BKMKZ,                      "Art der Kontierung        "4.0C
145             KONT1(24),                  "Kontierungsfeld 1         "4.0C
146             KONT2(8),                   "Kontierungsfeld 2
147             BKUML,                      "Kz. Bukrs-übergreifende Umlagerung
148             AZ_POS TYPE I,              "Anzahl Pos. pro Banf
149             SL_POS TYPE I,              "Anzahl selektierter Pos. pro Banf
150             ARCH_DATE LIKE SY-DATLO,    "Archivierungsdatum "TK 4.0B EURO
151          END OF BAN2.
152    DATA: ARCHIVE_DATE LIKE SY-DATLO.   "TK 4.0B EURO
153
154    *-- Direktwerte für UPDK1, UPDK2, UPDK3 -------------------------------*
155    DATA: ZNIX(2) VALUE '00',          "keine Zuordnung
156          ZNEW(2) VALUE '01',          "neue Bezugsquellenzuordnung
157          ZOLD(2) VALUE '02',          "bestehende Bezugsquellenzuordnung
158          ZRES(2) VALUE '03',          "zurückgestzte Zuordnung
159          AEND(2) VALUE '04',          "allgemeine Änderung
160          ZNER(2) VALUE '05',          "Lieferwerk geändert
161          ANFR(2) VALUE '11',          "Anfragezuordnung
162          ALIF(2) VALUE '12',          "Anfragezuordnung mit Lieferant
163          AMAN(2) VALUE '13',          "Anfragezuordnung mehrere Lieferanten
164          FRES(2) VALUE '31',          "Freigabe durchgeführt
165          FREE(2) VALUE '32',          "Einzelfreigabe durcchgeführt
166          BUBE(2) VALUE '33',          "Bestellung angelegt
167          BUAN(2) VALUE '34',          "Anfrage angelegt
168          BUBA(2) VALUE '35',          "Banf gesichert
169          SCHA(2) VALUE '36',    "Einzelfreigabe - nur geändert
170          NFRE(2) VALUE '37'.    "Freigabe wurde zurückgesetz
171
172
173    *-- Indices zu BAN ----------------------------------------------------*
174    DATA: B-AKTIND LIKE SY-TABIX,
175          B-LOPIND LIKE SY-TABIX,
176          B-MAXIND LIKE SY-TABIX,
177          B-PAGIND LIKE SY-TABIX,
178          B-LESIND LIKE SY-TABIX.
179
180    *-- Indices zu BAN bei Zuordnungsübersicht ----------------------------*
181    DATA: S-FIRSTIND LIKE SY-TABIX,
182          S-MAXIND   LIKE SY-TABIX,
183          S-AKTIND   LIKE SY-TABIX.
184
185    *-- Key zum Lesen BAN -------------------------------------------------*
186    DATA: BEGIN OF BANKEY,
187            MANDT LIKE EBAN-MANDT,
188            BANFN LIKE EBAN-BANFN,
189            BNFPO LIKE EBAN-BNFPO,
190          END OF BANKEY.
191
192    *-- Tabelle der Indices der Banfs zur Zuordnung -----------------------*
193    DATA: BEGIN OF BDT OCCURS 20,
194             INDEX LIKE SY-TABIX,
195          END OF BDT.
196
197    *-- Tabelle der Indices der für Detailbearbeitung selektierten Banfs---*
198    DATA: BEGIN OF BDE OCCURS 20,
199             INDEX LIKE SY-TABIX,
200          END OF BDE.
201
202    *-- Tabelle der selektierten Banfs - Stand der Datenbank --------------*
203    DATA: BEGIN OF OBA OCCURS 100.
204             INCLUDE STRUCTURE EBAN.
205    DATA: END OF OBA.
206
207    *-- Tabelle der zu bearbeitenden Banfs --------------------------------*
208    DATA: BEGIN OF BAT OCCURS 10.
209            INCLUDE STRUCTURE EBAN.
210    DATA:   UPDKZ.
211    DATA: END OF BAT.
212
213    *-- Struktur zum Abgleich der Banfstände ------------------------------*
214    *data: begin of sbat.
215    *        include structure eban.
216    *data: end of sbat.
217
218    *-- Dummytabellen für Banf-Verbuchung ---------------------------------*
219    DATA: BEGIN OF DIS OCCURS 0.
220             INCLUDE STRUCTURE EDISP.
221    DATA: END OF DIS.
222
223    *--- Tabelle der upgedateten Banfs durch Bestellung oder Einteilung ---*
224    DATA:    BEGIN OF BATU OCCURS 20.
225               INCLUDE STRUCTURE EBAN.
226    DATA:      OBSMG LIKE EBAN-BSMNG,
227             END OF BATU.
228
229    *-- Tabelle der Orderbuchsätze ----------------------------------------*
230    *-- Tabelle der Konsilieferanten --------------------------------------*
231    DATA: BEGIN OF KON OCCURS 10.
232             INCLUDE STRUCTURE MT06K.
233    DATA: END OF KON.
234
235    *-- Tabellen fuer Select-options---------------------------------------*
236    RANGES: SEL_BSART FOR EBAN-BSART,
237            SEL_PSTYP FOR EBAN-PSTYP,
238            SEL_KNTTP FOR EBAN-KNTTP,
239            SEL_WERKS FOR EBAN-WERKS,
240            SEL_MATNR FOR EBAN-MATNR,
241            SEL_MATKL FOR EBAN-MATKL.
242
243    *-- Tabelle der Lieferanten bei Anfragezuordnung - Übergabestruktur ---*
244    DATA: BEGIN OF ALFU OCCURS 5,
245            LIFNR LIKE EBAN-LIFNR,
246            EKORG LIKE EBAN-EKORG,
247          END OF ALFU.
248
249    *-- Tabelle der Lieferanten bei Anfragezuordnung - automatische -------*
250    DATA: BEGIN OF ALF OCCURS 5,
251            BANFN LIKE EBAN-BANFN,
252            BNFPO LIKE EBAN-BNFPO,
253            LIFNR LIKE EBAN-LIFNR,
254            EKORG LIKE EBAN-EKORG,
255            SELKZ LIKE RM06B-SELKZ,
256            VSELK LIKE RM06B-SELKZ,
257    * begin of <RD1K960036>
258            beswk LIKE eban-beswk,
259    * end of <RD1K960036>
260          END OF ALF.
261    *-- Key für Lieferantentabelle ----------------------------------------*
262    DATA: BEGIN OF ALFKEY,
263            BANFN LIKE EBAN-BANFN,
264            BNFPO LIKE EBAN-BNFPO,
265            LIFNR LIKE EBAN-LIFNR,
266            EKORG LIKE EBAN-EKORG,
267          END OF ALFKEY.
268    *------- Indices bei Tabellenbearbeitung Tabelle ALF ------------------*
269    DATA:   A-FIRSTIND(3) TYPE P,         "erster Index
270            A-AKTIND(3)   TYPE P,         "aktueller Index
271            A-MAXIND(3)   TYPE P,         "maximaler Index
272            A-PAGIND(3)   TYPE P.         "aktueller Index der Seite
273
274    *-- Tabelle für Material-Pre-Fetch ------------------------------------*
275    DATA: BEGIN OF XPRE01 OCCURS 20.
276            INCLUDE STRUCTURE PRE01.
277    DATA: END OF XPRE01.
278
279    *-- Tabelle der Listaufbereitungsroutinen -----------------------------*
280    DATA: BEGIN OF XT16LD OCCURS 10.
281             INCLUDE STRUCTURE T16LD.
282    DATA:    STATZ LIKE T16LL-STATZ.
283    DATA: END OF XT16LD.
284
285    *-- Tabelle der Datenbeschaffungssroutinen ----------------------------*
286    DATA: BEGIN OF XT16LI OCCURS 10.
287             INCLUDE STRUCTURE T16LI.
288    DATA: END OF XT16LI.
289
290    *------ EXCL ( Tabelle für GUI-PF-STATUS  )  --------------------------*
291     DATA:    BEGIN OF EXCL OCCURS 1,
292                FUNKTION(4),
293              END OF EXCL.
294
295    *------ Tabelle der Bestellungen --------------------------------------*
296    DATA BEGIN OF XMDBS OCCURS 10.
297       INCLUDE STRUCTURE MDBS.
298    DATA END OF XMDBS.
299    *------ Tabelle der Bestände ------------------------------------------*
300    DATA BEGIN OF XMT61B OCCURS 10.
301       INCLUDE STRUCTURE MT61B.
302    DATA END OF XMT61B.
303
304    *------ Tabelle der Verbräuche ----------------------------------------*
305    DATA BEGIN OF GVERB OCCURS 10.
306       INCLUDE STRUCTURE IVERB.
307    DATA END OF GVERB.
308    DATA BEGIN OF XVERB OCCURS 0.
309       INCLUDE STRUCTURE IVERB.
310    DATA END OF XVERB.
311    *------ Tabelle der Verbräuche zum Material ---------------------------*
312    DATA: BEGIN OF MVERB OCCURS 20,
313             MATNR LIKE EBAN-MATNR,
314             WERKS LIKE EBAN-WERKS.
315             INCLUDE STRUCTURE IVERB.
316    DATA: END OF MVERB.
317    *------ Tabelle der Prognosen zum Material ----------------------------*
318    DATA: BEGIN OF MPROG OCCURS 20,
319             MATNR LIKE EBAN-MATNR,
320             WERKS LIKE EBAN-WERKS,
321             PRIOD LIKE IVERB-PRIOD.
322             INCLUDE STRUCTURE PROWF.
323    DATA: END OF MPROG.
324    *------ Prognoseperioden ----------------------------------------------*
325    DATA:  BEGIN OF XPPER OCCURS 2.
326             INCLUDE STRUCTURE PPER.
327    DATA:  END OF XPPER.
328    *------ Porgnosewerte für ein Material --------------------------------*
329    DATA:  BEGIN OF XPROWF OCCURS 12.
330             INCLUDE STRUCTURE PROWF.
331    DATA:  END OF XPROWF.
332    *------ Tabelle der Kumulierten Bestände/Bedarfe zum Material ---------*
333    DATA: BEGIN OF MMDSA OCCURS 20,
334             MATNR LIKE EBAN-MATNR,
335             WERKS LIKE EBAN-WERKS.
336             INCLUDE STRUCTURE MDSTA.
337    DATA:    DSDAT LIKE MDKP-DSDAT, "#EC CI_USAGE_OK[2268085]
338             RBEST,
339             RBSTD,
340             RBEDA,
341             RDISP,
342          END OF MMDSA.  "#EC CI_USAGE_OK[2268085]
343    *------ Tabelle der Bedarfselementzeilen ------------------------------*
344    DATA BEGIN OF XMDPS OCCURS 50.
345            INCLUDE STRUCTURE MDPS.
346    DATA END OF XMDPS.
347
348    DATA: VINDEX LIKE SY-TABIX.
349    DATA: PINDEX LIKE SY-TABIX.
350    *------ Key zum Lesen der Material-Tabellen ---------------------------*
351    DATA: BEGIN OF MATKEY,
352            MATNR LIKE EBAN-MATNR,
353            WERKS LIKE EBAN-WERKS,
354          END OF MATKEY.
355    DATA: MINDEX LIKE SY-TABIX,
356          MSUBRC LIKE SY-SUBRC.
357
358    *----------------------------------------------------------------------*
359    *        Feldleisten                                                   *
360    *----------------------------------------------------------------------*
361    *-- Feldleiste für Anzeigen Rahmenverträge zur Materialklasse ---------*
362    DATA: BEGIN OF KLA,
363            MATKL LIKE EBAN-MATKL,
364            BSART LIKE EBAN-BSART,
365            PSTYP LIKE EBAN-PSTYP,
366            KNTTP LIKE EBAN-KNTTP,
367            WERKS LIKE EBAN-WERKS,
368          END OF KLA.
369
370    *-- Feldleiste für Anzeigen Konsilieferanten --------------------------*
371    DATA: BEGIN OF KNS,
372            MATNR LIKE EBAN-MATNR,
373            WERKS LIKE EBAN-WERKS,
374          END OF KNS.
375
376    *-- Feldleiste für Anzeigen Rahmenverträge zum Material ---------------*
377    DATA: BEGIN OF MAT,
378            MATNR LIKE EBAN-MATNR,
379            BSART LIKE EBAN-BSART,
380            PSTYP LIKE EBAN-PSTYP,
381            KNTTP LIKE EBAN-KNTTP,
382            WERKS LIKE EBAN-WERKS,
383          END OF MAT.
384
385    *-- Indizes zum Markieren Intervall -----------------------------------*
386    DATA: BEGIN OF MINT,
387            BEG LIKE SY-INDEX,
388            END LIKE SY-INDEX,
389            ACT LIKE SY-INDEX,
390          END OF MINT.
391
392    *-- Feldleiste für Anzeigen Infosätze ---------------------------------*
393    DATA: BEGIN OF INF,
394            MATNR LIKE EBAN-MATNR,
395            MATKL LIKE EBAN-MATKL,
396            WERKS LIKE EBAN-WERKS,
397          END OF INF.
398
399    *--- Hilfsfelder Lieferantenbeurteilung ------------------------------*
400    DATA: BEGIN OF LIBE,
401             EKORG LIKE EBAN-EKORG,
402             MATNR LIKE EBAN-MATNR,
403             MATKL LIKE EBAN-MATKL,
404          END OF LIBE.
405    DATA: L TYPE P.
406    DATA: BEGIN OF LIBE_EKO OCCURS 2.
407             INCLUDE STRUCTURE T024W.
408    DATA: END OF LIBE_EKO.
409
410    *-- Feldleiste der Zuordnung ------------------------------------------*
411    DATA: BEGIN OF ZUG,
412            EKORG LIKE EBAN-EKORG,
413            BSART LIKE EBAN-BSART,
414            FLIEF LIKE EBAN-FLIEF,
415            RESWK LIKE EBAN-RESWK,
416    * begin of <RD1K960036>
417            beswk LIKE eban-beswk,
418    * end of <RD1K960036>
419            KONNR LIKE EBAN-KONNR,
420            FORDN LIKE EBAN-FORDN,
421            BUKRS LIKE EKKO-BUKRS,
422            UPDKZ LIKE T16LA-UPDKZ,
423          END OF ZUG.
424
425    *-- Tabelle der Zuordnungen  ------------------------------------------*
426    DATA: BEGIN OF ZUG_TAB OCCURS 20,
427            EKORG LIKE EBAN-EKORG,
428            BSART LIKE EBAN-BSART,
429            SLIEF LIKE EBAN-FLIEF,
430            RESWK LIKE EBAN-RESWK,
431    * begin of <RD1K960036>
432            beswk LIKE eban-beswk,
433    * end of <RD1K960036>
434            KONNR LIKE EBAN-KONNR,
435            BUKRS LIKE EKKO-BUKRS,
436            A_ZAEHLER LIKE SY-TFILL,
437            B_ZAEHLER LIKE SY-TFILL,
438          END OF ZUG_TAB.
439
440    *------- Feldleiste für Banf-Liste aus Zuordnungsübersicht-------------*
441    DATA: BEGIN OF DET,
442            EKORG LIKE EBAN-EKORG,
443            BSART LIKE EBAN-BSART,
444            SLIEF LIKE EBAN-FLIEF,
445            RESWK LIKE EBAN-RESWK,
446    * begin of <RD1K960036>
447            beswk LIKE eban-beswk,
448    * end of <RD1K960036>
449            KONNR LIKE EBAN-KONNR,
450            FORDN LIKE EBAN-FORDN,
451            BUKRS LIKE EKKO-BUKRS,
452            UPDKZ LIKE T16LA-UPDKZ,
453          END OF DET.
454    *------- Feldleiste für Banf-Liste aus Zuordnungsübersicht (save) -----*
455    DATA: BEGIN OF S1DET,
456            EKORG LIKE EBAN-EKORG,
457            BSART LIKE EBAN-BSART,
458            SLIEF LIKE EBAN-FLIEF,
459            RESWK LIKE EBAN-RESWK,
460    * begin of <RD1K960036>
461            beswk LIKE eban-beswk,
462    * end of <RD1K960036>
463            KONNR LIKE EBAN-KONNR,
464            BUKRS LIKE EKKO-BUKRS,
465            UPDKZ LIKE T16LA-UPDKZ,
466          END OF S1DET.
467
468    *------- Feldleiste für Preisaufbereitung -----------------------------*
469    DATA: BEGIN OF APREIS,
470            NETPR(14),
471            SPAC1,
472            WAERS LIKE EINE-WAERS,
473            STRICH,
474            PEINH(6),
475            BPRME LIKE EINE-BPRME,
476          END OF APREIS.
477
478    *----------------------------------------------------------------------*
479    *  Hilfsfelder                                                         *
480    *----------------------------------------------------------------------*
481    *-- Hildfelder für Listaufbereitungsroutinen --------------------------*
482    DATA: HROUTN(30),
483          XSZEIL LIKE SY-TABIX,
484          XZEILE LIKE SY-TABIX,
485          GS_SZEIL LIKE SY-TABIX,    "Gesamtfreigabe
486          GS_ZEILE LIKE SY-TABIX,    "Gesamtfreigabe
487          XZLTYP,
488          XSZTYP.
489
490    *-- Hidebereich -------------------------------------------------------*
491    DATA: HIDE-INDEX LIKE SY-TABIX,
492          HIDE-ZEILE LIKE SY-CUROW,
493          HIDE-GSFRG LIKE EBAN-GSFRG,
494          HIDE-PAGE  LIKE SY-PAGNO,
495          HIDE-KOIND LIKE SY-TABIX.
496
497    *------- Zähler für Update-Protokoll ----------------------------------*
498    DATA: ZSICH LIKE SY-TABIX,             "gesichert
499          ZENQU LIKE SY-TABIX,             "gesperrt durch anderen Benutzer
500          ZAEND LIKE SY-TABIX,             "geändert durch anderen Benutzer
501          ZBERE LIKE SY-TABIX,             "Keine Berechitigung
502          ZNOUP LIKE SY-TABIX,             "Keine Änderung nötig
503          ZFREI LIKE SY-TABIX.             "Freigabe bereits erfolgt
504    *------- Hilfsfelder für Liststufenbearbeitung ------------------------*
505    DATA: LISTE,                           "G/Z Grundliste/Zuordnungen
506          LISTKZ,
507          S0LISTE,
508          S0SRTKZ,
509          S1LISTE,
510          S1SRTKZ,
511          ZPFKEY LIKE SY-PFKEY,
512          ZFMKEY(3),
513          GPFKEY LIKE SY-PFKEY,
514          GFMKEY(3).
515
516    *------- Direktwert zur Pruefung von Nettowertueberlaeufen ------------*
517    DATA: MAXWERT LIKE RM06B-GSWRT VALUE '9999999999999'.
518    DATA: REFE1(16) TYPE P.
519
520    *-- sonstige Hilfsfelder ----------------------------------------------*
521    DATA:
522          NOT_ALL_ORDB,                    "nicht alle wurden zugeordnet
523          O-DATUM LIKE BAN-FRGDT,          "Hilfsfeld Datum f. Orderb.zuord.
524          INDEX LIKE SY-TABIX,             "Hilfsfeld Tabellenindex
525          INDEX_BAN LIKE HIDE-INDEX,       "Tabellenindex in Banftabelle
526          LSIND LIKE SY-LSIND,             "Hilfsfeld Liststufe
527          LEERFLG,                         "Kennz. Funktion ausgeführt
528          CALL_UPDKZ,                      "Kennz. Verbuchung erfolgt
529          IZAEHL TYPE I,                   "Zaehler
530          BZAEHL TYPE I,                   "Zaehler
531          s-zaehler(5),                    "Zähler selektierte Banfs
532          b-zaehler(5),                    "Zähler bestellte Banfs
533          LZEILE,                          "Kz. Lieferantenzeile gedruckt
534          AUTO,                            "Kz. automatische Bearbeitung
535          EXITFLAG,                        "Kennzeichen Routine verlassen
536          LOOPEXIT,                        "Kennzeichen Routine verlassen
537          RETCO,                           "Returncode
538          XAUTH,                           "Kz. fehlende Berechtigung
539          AENDANZ,                         "Kz. Änderungen anzeigbar
540          EFUBE LIKE T160D-EFUBU,          "Funktionsberechtigung
541          EVOPA LIKE T160V-EVOPA,          "Vorschlagswerte
542          COUNTA LIKE SY-TABIX,            "Anzahl Tabelleneinträge alt
543          COUNTN LIKE SY-TABIX,            "Anzahl Tabelleneinträge neu
544          UEBKNT2(60),                     "Überschrift Kontierung
545          HKONT1(24),                      "Kontierung 1        "4.0C
546          HKONT2(8),                       "Kontierung 2
547          HNPLNR LIKE EBKN-NPLNR,          "Hilfsfeld Netzplan
548          HVORNR LIKE COBL-VORNR,          "Hilfsfeld Netzplan
549          COLFLAG,                         "Flag für Streifenmuster
550          HLINE(80),                       "Hilfsfeld für Sonderzeile
551          FLINE(80),                       "Hilfsfeld für Sonderzeile
552          HTITEL(30),                      "Titel Freigabepopup
553          XCALLD,                          "Flag Step-Loop-Bild gecalled
554          MERK LIKE BAN-UPDK1.             "Merker für Updk1
555
556    *... Felder für Gesamtfreigabe .......................................*
557    DATA: SL_POS TYPE I.      "Anzahl selektierter Pos. pro Banf
558
559    *------- Feldsymbole für Kontierungswechsel --------------------------*
560    * begin of <RD1K960036>
561    *FIELD-SYMBOLS: <SKF1>, <SKF2>,
562    *               <AKF1>, <AKF2>.
563    * end of <RD1K960036>
564    DATA: DUMMY.
565    DATA: SAVE_BANF LIKE EBAN-BANFN,
566          SAVE_SELKZ LIKE BAN-SELKZ.
567
568    * ehemalige FMMEXCOM-Felder
569      DATA: BIMUKONT, CATTKZ, AKTYP.
570    *{   INSERT         SOGK021244                                        2
571    INCLUDE FM06BTOI.          "Oil data                  "SO3K000727
572    *}   INSERT
573
574    * begin of <RD1K960036>
575      DATA: gf_factory TYPE REF TO if_table_manager_mm,
576            gf_tab     TYPE REF TO if_any_table_mm,
577            t_mesg LIKE mesg OCCURS 0 WITH HEADER LINE,
578            BEGIN OF t_excluded OCCURS 10,
579              banfn TYPE eban-banfn.
580              INCLUDE STRUCTURE t_mesg.
581      DATA: END OF t_excluded,
582             zacce LIKE sy-tabix.
583    * end of <RD1K960036>
584
585    INCLUDE FM06BCD1.
586
587    INCLUDE FM06BCDF.
588    INCLUDE FM06BCDV.   "kb
589    INCLUDE FM06BCDC.   "kb
590    *NCLUDE ZM06BCDV.    "kb
591    *NCLUDE ZM06BCDC.    "kb
592    INCLUDE FM06BU01.
593    INCLUDE FM06BU02.
594    INCLUDE FM06LCCD.
595    INCLUDE FMMEXDIR.
596    INCLUDE FM06LCIM.                   "4.6A CF
*--- End of MZFM06BTOP - 596 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BTOI                                  Level 2    Page 3
Object           SAPMZFM06B                                Lines 57
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *----------------------------------------------------------------------*
2      *   INCLUDE FM06BTOI                                                   *
3      *----------------------------------------------------------------------*
4      *------- Variable used for determining which table to read when
5      *------- creating PO without vendor unknown.
6
7      TABLES: OI001,
8              OIH10,
9              MARC.
10
11     * MMACCESS_2015W1_ADJUSTED
12     DATA: BEGIN OF OIH_MARC_MD.
13             INCLUDE STRUCTURE V_MARC_MD.
14     DATA: END OF OIH_MARC_MD.
15
16     DATA: BEGIN OF OIH_EINE.
17             INCLUDE STRUCTURE EINE.
18     DATA: END OF OIH_EINE.
19
20     *------- Communication structures for use with ext. performs (SAPFOIH2)
21     DATA: BEGIN OF OIH_STCT.
22             INCLUDE STRUCTURE OIH10.
23     DATA: END OF OIH_STCT.
24
25     DATA: BEGIN OF OIH_STCTX.
26             INCLUDE STRUCTURE OIH08.
27     DATA: END OF OIH_STCTX.
28
29     DATA: BEGIN OF OIH_STCTY.
30             INCLUDE STRUCTURE OIH4.
31     DATA: END OF OIH_STCTY.
32
33     DATA: BEGIN OF OIH_STCTZ.
34             INCLUDE STRUCTURE OIH16.
35     DATA: END OF OIH_STCTZ.
36
37     DATA:  BEGIN OF OIH_STCTU.
38              INCLUDE STRUCTURE OI001.
39     DATA:  END OF OIH_STCTU.
40
41     DATA:  TDP_FLAG(4) TYPE C.
42
43     DATA: G_EBELP     LIKE BAN-EBELP,
44           G_MATNR     LIKE BAN-MATNR,
45           G_WERKS     LIKE BAN-WERKS,
46           G_HANTYP    LIKE BAN-OIHANTYP,
47           G_INEX      LIKE BAN-OIINEX,
48           G_INF_HAN   LIKE EINE-OIHANTYP,
49           G_INF_BWTAR LIKE EBAN-BWTAR,
50           G_INF_INEX  LIKE EINE-OIINEX,
51           G_TAXGRP    LIKE EKPO-OITAXGRP,
52           G_BUKRS     LIKE EKPO-BUKRS,
53           G_OILCON    LIKE MARC-OIOILCON,
54           G_INFNR     LIKE EINE-INFNR,
55           G_VEN_HAN   LIKE LFM1-OIHANTYP,
56           G_DEF_BWTAR LIKE EBAN-BWTAR,
57           H-ESOKZ.                      "Einkaufssonderkennzeichen
*--- End of FM06BTOI - 57 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BCD1                                  Level 2    Page 4
Object           SAPMZFM06B                                Lines 59
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      ************************************************************************
2      *        Common-Part Listanzeigen Bestellanforderungen  Teil 1         *
3      ************************************************************************
4
5      DATA: BEGIN OF COMMON PART fm06bcd1.
6
7      DATA: flag_selk(2) TYPE p,
8            pfkeyp       LIKE sy-pfkey,            "PF-Status vor POP-UPs
9            reject,
10           answer,
11           gs_banf,          "Eigene Listaufbereitung für Gesamtbanfen
12           az_pos       TYPE i,    "Anzahl Positionen zur Banf f. Gesamtfreigabe
13           not_found,
14           sucomm       LIKE sy-ucomm,
15           ok-code(4).
16     *------- Struktur für Übergabe Selektion an Listaufbereitung ----------*
17     DATA: BEGIN OF com,
18             frgab     LIKE rm06b-frgab,
19             srtkz,
20             bkmkz,
21             lstub     LIKE t16ll-lstub,
22             zpfkey    LIKE sy-pfkey,
23             zfmkey(3),
24             gpfkey    LIKE sy-pfkey,
25             gfmkey(3),
26             calld     LIKE sy-calld,
27           END OF com.
28
29
30     "{ Begin ENHO AD_MPN_MD_FM06BCD1 IS-AD-MPN-MD AD_MPN }
31     *IF cl_adpic_switch_check=>get_ad_mpn_rba_2_switch_state( ) EQ abap_true.
32     * global variables for line control on reports
33     DATA  output_line_width TYPE i.
34     DATA  len TYPE i.
35     DATA  mat_len TYPE i.
36     DATA  manufacturer_len TYPE i.
37     DATA  pad TYPE i VALUE 4.                          "DI note 1073485
38     DATA  position TYPE i.
39     DATA  offset TYPE i.
40     DATA  conv_exit_check1 LIKE t130f-kzkma.
41     DATA  conv_exit_check2 LIKE tka53-sign.
42     DATA  show_ext_manufacturer LIKE  t130f-kzkma.
43     DATA: rxm0_23 TYPE i,                               "DI note 631575
44           rxm0_24 TYPE i,                               "   "
45           rxm0_65 TYPE i,                               "   "
46           rxm0_74 TYPE i.                               "DI note 631575
47     DATA: rxm0_diff      TYPE i,                        "DI note 720170
48           rxm0_cut       TYPE i,                        "   "
49           text(120)      TYPE c,                        "DI note 1073485
50           text_len       TYPE i,                        "   "
51           rxm0_ueb(120)  TYPE c,                        "   "
52           rxm2_pos_teil2 TYPE i VALUE 19,               "   "
53           rxm0_size      TYPE i.                        "DI note 720170
54     *ENDIF.
55     "{ End ENHO AD_MPN_MD_FM06BCD1 IS-AD-MPN-MD AD_MPN }
56
57
58     ENHANCEMENT-POINT fm06bcd1_01 SPOTS es_fm06bcd1 STATIC INCLUDE BOUND.
59     DATA: END OF COMMON PART fm06bcd1.
*--- End of FM06BCD1 - 59 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BCDF                                  Level 2    Page 5
Object           SAPMZFM06B                                Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      DATA: OBJECTID                TYPE CDHDR-OBJECTID,
2            TCODE                   TYPE CDHDR-TCODE,
3            PLANNED_CHANGE_NUMBER   TYPE CDHDR-PLANCHNGNR,
4            UTIME                   TYPE CDHDR-UTIME,
5            UDATE                   TYPE CDHDR-UDATE,
6            USERNAME                TYPE CDHDR-USERNAME,
7            CDOC_PLANNED_OR_REAL    TYPE CDHDR-CHANGE_IND,
8            CDOC_UPD_OBJECT         TYPE CDHDR-CHANGE_IND VALUE 'U',
9            CDOC_NO_CHANGE_POINTERS TYPE CDHDR-CHANGE_IND.
10
*--- End of FM06BCDF - 10 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BCDV                                  Level 2    Page 6
Object           SAPMZFM06B                                Lines 30
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      * declaration for the long text
2      DATA: BEGIN OF ICDTXT_BANF OCCURS 20.
3              INCLUDE STRUCTURE CDTXT.
4      DATA: END OF ICDTXT_BANF.
5      DATA: UPD_ICDTXT_BANF TYPE C.
6
7      * table with the NEW content of: EBAN
8      DATA: BEGIN OF XEBAN OCCURS 20.
9              INCLUDE STRUCTURE UEBAN.
10     DATA: END OF XEBAN.
11
12     * table with the OLD content of: EBAN
13     DATA: BEGIN OF YEBAN OCCURS 20.
14             INCLUDE STRUCTURE UEBAN.
15     DATA: END OF YEBAN.
16
17     DATA: UPD_EBAN TYPE C.
18
19     * table with the NEW content of: EBKN
20     DATA: BEGIN OF XEBKN OCCURS 20.
21             INCLUDE STRUCTURE UEBKN.
22     DATA: END OF XEBKN.
23
24     * table with the OLD content of: EBKN
25     DATA: BEGIN OF YEBKN OCCURS 20.
26             INCLUDE STRUCTURE UEBKN.
27     DATA: END OF YEBKN.
28
29     DATA: UPD_EBKN TYPE C.
30
*--- End of FM06BCDV - 30 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BCDC                                  Level 2    Page 7
Object           SAPMZFM06B                                Lines 40
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      FORM CD_CALL_BANF.
2        IF   ( UPD_EBAN NE SPACE )
3          OR ( UPD_EBKN NE SPACE )
4          OR ( UPD_ICDTXT_BANF NE SPACE )
5        .
6          CALL FUNCTION 'SWE_REQUESTER_TO_UPDATE'.
7          CALL FUNCTION 'BANF_WRITE_DOCUMENT' IN UPDATE TASK
8              EXPORTING
9                OBJECTID                = OBJECTID
10               TCODE                   = TCODE
11               UTIME                   = UTIME
12               UDATE                   = UDATE
13               USERNAME                = USERNAME
14               PLANNED_CHANGE_NUMBER   = PLANNED_CHANGE_NUMBER
15               OBJECT_CHANGE_INDICATOR = CDOC_UPD_OBJECT
16               PLANNED_OR_REAL_CHANGES = CDOC_PLANNED_OR_REAL
17               NO_CHANGE_POINTERS      = CDOC_NO_CHANGE_POINTERS
18     * updateflag of EBAN
19               UPD_EBAN
20                           = UPD_EBAN
21     * updateflag of EBKN
22               UPD_EBKN
23                           = UPD_EBKN
24               UPD_ICDTXT_BANF
25                           = UPD_ICDTXT_BANF
26             TABLES
27               ICDTXT_BANF
28                           = ICDTXT_BANF
29               XEBAN
30                           = XEBAN
31               YEBAN
32                           = YEBAN
33               XEBKN
34                           = XEBKN
35               YEBKN
36                           = YEBKN
37         .
38       ENDIF.
39       CLEAR PLANNED_CHANGE_NUMBER.
40     ENDFORM.
*--- End of FM06BCDC - 40 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BU01                                  Level 2    Page 8
Object           SAPMZFM06B                                Lines 27
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      ************************************************************************
2      *        Übergabestruktur für Zuordnung Bestellanforderungen           *
3      ************************************************************************
4
5      DATA: BEGIN OF COMMON PART fm06bu01.
6
7      DATA: BEGIN OF bueb,
8              calkz,
9              nrcfd,
10             flief LIKE eban-flief,
11             ekorg LIKE eban-ekorg,
12             konnr LIKE eban-konnr,
13             ktpnr LIKE eban-ktpnr,
14             vrtyp LIKE eban-vrtyp,
15             infnr LIKE eban-infnr,
16             menge LIKE eban-menge,
17             meins LIKE eban-meins,
18             datum LIKE eban-frgdt,
19             reswk LIKE eban-reswk,
20             ematn LIKE eban-ematn,
21             mfrnr LIKE eban-mfrnr,
22             mfrpn LIKE eban-mfrpn,
23             emnfr LIKE eban-emnfr,
24             beswk LIKE eban-beswk, " CCP
25           END OF bueb.
26
27     DATA: END OF COMMON PART.
*--- End of FM06BU01 - 27 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BU02                                  Level 2    Page 9
Object           SAPMZFM06B                                Lines 14
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      ************************************************************************
2      *        Übergabestruktur für Auswählen Bestellanforderungen           *
3      ************************************************************************
4
5      DATA: BEGIN OF COMMON PART FM06BU02.
6
7      DATA: BEGIN OF CUEB,
8              CALKZ,
9              NRCFD,
10             BANFN LIKE EBAN-BANFN,
11             BNFPO LIKE EBAN-BNFPO,
12           END OF CUEB.
13
14     DATA: END OF COMMON PART.
*--- End of FM06BU02 - 14 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06LCCD                                  Level 2    Page 10
Object           SAPMZFM06B                                Lines 57
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *--------------------------------------------------------------------*
3      *        COMMON DATA                                                 *
4      *--------------------------------------------------------------------*
5      *        Datenfelder fuer die Bearbeitung der Änderungsdoku          *
6      *--------------------------------------------------------------------*
7
8      DATA:    BEGIN OF COMMON PART FM06LCCD.
9
10     *------- Tabelle der Änderunsbelegzeilen (temporär) -------------------*
11     DATA: BEGIN OF EDIT OCCURS 50.             "Änderungsbelegzeilen temp.
12             INCLUDE STRUCTURE CDSHW.
13     DATA: END OF EDIT.
14
15     DATA: BEGIN OF EDITD OCCURS 50.             "Änderungsbelegzeilen temp.
16             INCLUDE STRUCTURE CDSHW.            "für Dienstleistungen
17     DATA: END OF EDITD.
18
19
20     *------- Tabelle der Änderunsbelegzeilen (Ausgabeform) ----------------*
21     DATA: BEGIN OF AUSG OCCURS 50.             "Änderungsbelegzeilen
22             INCLUDE STRUCTURE CDSHW.
23     DATA:   CHANGENR LIKE CDHDR-CHANGENR,
24             UDATE    LIKE CDHDR-UDATE,
25             UTIME    LIKE CDHDR-UTIME,
26           END OF AUSG.
27
28     *------- Tabelle der Änderunsbelegköpfe -------------------------------*
29     DATA: BEGIN OF ICDHDR OCCURS 50.           "Änderungbelegköpfe
30             INCLUDE STRUCTURE CDHDR.
31     DATA: END OF ICDHDR.
32
33     *------- Key Tabelle der Änderunsbelegköpfe --------------------------*
34     DATA: BEGIN OF HKEY,                       "Key für ICDHDR
35             MANDT LIKE CDHDR-MANDANT,
36             OBJCL LIKE CDHDR-OBJECTCLAS,
37             OBJID LIKE CDHDR-OBJECTID,
38             CHANG LIKE CDHDR-CHANGENR,
39           END OF HKEY.
40
41     *------- Key der geänderten Tabelle für Ausgabe ----------------------*
42     DATA: BEGIN OF EKKEY,                    "Tabellenkeyausgabe
43             EBELN LIKE EKKO-EBELN,
44             EBELP LIKE EKPO-EBELP,
45             ZEKKN LIKE EKKN-ZEKKN,
46             ETENR LIKE EKET-ETENR,
47             ABRUF LIKE EKEK-ABRUF,
48             EKORG LIKE EKPA-EKORG,           "Änderungsbelege Partner
49             LTSNR LIKE EKPA-LTSNR,           "Änderungsbelege Partner
50             WERKS LIKE EKPA-WERKS,           "Änderungsbelege Partner
51             PARVW LIKE EKPA-PARVW,           "Änderungsbelege Partner
52             PARZA LIKE EKPA-PARZA,           "Änderungsbelege Partner
53             CONSNUMBER LIKE ADR2-CONSNUMBER, "Änderungsbelege Adressen
54             COMM_TYPE  LIKE ADRT-COMM_TYPE,  "Änderungsbelege Adressen
55           END OF EKKEY.
56
57     DATA:    END OF COMMON PART.
*--- End of FM06LCCD - 57 lines ---

----------------------------------------------------------------------------------------------------
Include          FMMEXDIR                                  Level 2    Page 11
Object           SAPMZFM06B                                Lines 283
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      ************************************************************************
2      *          Direktwerte                                                 *
3      ************************************************************************
4      SET EXTENDED CHECK OFF.
5      CONSTANTS:
6      * Werte zu Trtyp und Aktyp:
7        hin        VALUE 'H',             "Hinzufuegen
8        ver        VALUE 'V',             "Veraendern
9        anz        VALUE 'A',             "Anzeigen
10       erw        VALUE 'E',             "Bestellerweiterung
11
12     * BSTYP
13       bstyp-info   VALUE 'I',
14       bstyp-ordr   VALUE 'W',
15       bstyp-banf   VALUE 'B',
16       bstyp-best   VALUE 'F',
17       bstyp-anfr   VALUE 'A',
18       bstyp-angb_2 VALUE 'O',
19       bstyp-anfr_2 VALUE 'R',
20       bstyp-kont   VALUE 'K',
21       bstyp-lfpl   VALUE 'L',
22       bstyp-lerf   VALUE 'Q',
23
24     * BSAKZ
25       bsakz-norm VALUE ' ',
26       bsakz-tran VALUE 'T',
27       bsakz-rahm VALUE 'R',
28
29     * PSTYP
30       pstyp-lagm VALUE '0',
31       pstyp-blnk VALUE '1',
32       pstyp-kons VALUE '2',
33       pstyp-lohn VALUE '3',
34       pstyp-munb VALUE '4',
35       pstyp-stre VALUE '5',
36       pstyp-text VALUE '6',
37       pstyp-umlg VALUE '7',
38       pstyp-wagr VALUE '8',
39       pstyp-dien VALUE '9',
40       pstyp-enhl VALUE 'A',                             "Enhanced Limit Item
41
42     * Kzvbr
43       kzvbr-anla VALUE 'A',
44       kzvbr-unbe VALUE 'U',
45       kzvbr-verb VALUE 'V',
46       kzvbr-einz VALUE 'E',
47       kzvbr-proj VALUE 'P',
48
49     * ESOKZ
50       esokz-pipe  VALUE 'P',
51       esokz-lohn  VALUE '3',
52       esokz-konsi VALUE '2',               "konsi
53       esokz-charg VALUE '1',               "sc-jp
54       esokz-norm  VALUE '0'.
55
56
57     "{ Begin FMMEXDIR_02 ENHO DIPCS_FMMEXDIR IS-AD-SUC AD_SUB }
58     CONSTANTS:
59     * DI A&D PCS Customer stock
60       pstyp-cust value 'C',
61     * DI A&D PCS Pooled stock
62       pstyp-pool value 'P'.
63
64     * DI A&D PCS Constants
65     CONSTANTS:
66       SOBKZ-CSTCK                   VALUE 'B',  "Kundenbeistellbestand
67       SOBKZ-VENDOR_CONSIGNMENT      VALUE 'K',  "Lieferantenkonsignation
68       SOBKZ-RTP                     VALUE 'M'.  "MTV
69     * SOBKZ-SC_PROJECT_STOCK        VALUE 'R',  "LB Projektbestand
70     * SOBKZ-SC_CUSTOMER_STOCK       VALUE 'C',  "LB Kundenbeistellbestand
71     * SOBKZ-SC_CUSTOMER_ORDER_STOCK VALUE 'F',  "LB Kundenauftragsbestand
72     * SOBKZ-SC_RTP                  VALUE 'I',  "LB MTV
73     * SOBKZ-SC_VENDOR_CONSIGNMENT   VALUE 'J'.  "LB Lieferantenkonsignation
74     "{ End FMMEXDIR_02 ENHO DIPCS_FMMEXDIR IS-AD-SUC AD_SUB }
75
76     ENHANCEMENT-POINT fmmexdir_02 SPOTS es_fmmexdir STATIC INCLUDE BOUND.
77     CONSTANTS:
78     * Handling von Unterpositionsdaten
79       sihan-nix  VALUE ' ',      "keine eigenen Daten
80       sihan-anz  VALUE '1',      "Daten aus Hauptposition kopiert, nicht änd
81       sihan-kop  VALUE '2',      "Daten aus Hauptposition kopiert, aber ände
82       sihan-eig  VALUE '3',      "eigene Daten (nicht aus Hauptposition kopi
83
84     * Unterpositionstypen
85       uptyp-hpo VALUE ' ',       "Hauptposition
86       uptyp-var VALUE '1',       "Variante
87       uptyp-nri VALUE '2',       "Naturalrabatt Inklusive (=Dreingabe)
88       uptyp-ler VALUE '3',       "Leergut
89       uptyp-nre VALUE '4',       "Naturalrabatt Exklusive (=Draufgabe)
90       uptyp-lot VALUE '5',       "Lot Position
91       uptyp-dis VALUE '6',       "Display Position
92       uptyp-vks VALUE '7',       "VK-Set Position
93       uptyp-mpn VALUE '8',       "Austauschposition (A&D)
94       uptyp-sls VALUE '9',       "Vorkommisionierungsposition (retail)
95       uptyp-fwe VALUE 'F',       "Forward Exchange (A&D) ERP2007
96       uptyp-gth VALUE 'H',       "Global Trade Header           "622794
97       uptyp-gti VALUE 'I',       "Global Trade Item             "622794
98       uptyp_pic VALUE 'P',       "APO Produktaustausch (Umlagerung)
99       uptyp-div VALUE 'X',       "HP hat UP's mit verschiedenen Typen
100      uptyp-sus VALUE 'S',       "TPOP supersession sub item type
101      uptyp-hir VALUE 'A',       "SRM deep hierarchies          "WP145920
102      uptyp-uid VALUE 'U',       "IUID Embedded items        "EHP603 IUID
103      uptyp_chs VALUE 'C',       "Complex hierarchies in S/4 HANA
104
105    * Artikeltypen
106      attyp-sam(2) VALUE '01',   "Sammelartikel
107      attyp-var(2) VALUE '02',   "Variante
108      attyp-we1(2) VALUE '20',   "Wertartikel
109      attyp-we2(2) VALUE '21',   "Wertartikel
110      attyp-we3(2) VALUE '22',   "Wertartikel
111      attyp-vks(2) VALUE '10',   "VK-Set
112      attyp-lot(2) VALUE '11',   "Lot-Artikel
113      attyp-dis(2) VALUE '12',   "Display
114
115    * Konfigurationsherkunft
116      kzkfg-fre VALUE ' ',       "Konfiguration sonst woher
117      kzkfg-kan VALUE '1',       "noch nicht konfiguriert
118      kzkfg-eig VALUE '2',       "Eigene Konfiguration
119
120    * Ja, Nein
121      c_ja   TYPE c VALUE 'X',
122      c_nein TYPE c VALUE ' ',
123
124    * Vorgangsart, welche Anwendung den Fkt-Baustein aufruft
125      cva_ab(1) VALUE 'B',     "Automatische bestellung (aus banfen)
126      cva_we(1) VALUE 'C',     "Wareneingang
127      cva_bu(1) VALUE 'D',     "Übernahme bestellungen aus fremdsystem
128      cva_au(1) VALUE 'E',     "Aufteiler
129      cva_kb(1) VALUE 'F',     "Kanban
130      cva_fa(1) VALUE 'G',     "Filialauftrag
131      cva_dr(1) VALUE 'H',     "DRP
132      cva_re(1) VALUE 'R',     "Rescheduling
133      cva_en(1) VALUE '9',     "Enjoy
134      cva_ap(1) VALUE '1',     "APO
135      cva_ed(1) VALUE 'T',     "EDI-Eingang Auftragsbestätigung Update Preis
136
137    * Status des Einkaufsbeleges (EKKO-STATU)
138      cks_ag(1) VALUE 'A',     "Angebot vorhanden für Anfrage
139      cks_ab(1) VALUE 'B',     "Automatische Bestellung (aus Banfen) ME59
140      cks_we(1) VALUE 'C',     "Bestellung aus Wareneingang
141      cks_bu(1) VALUE 'D',     "Bestellung aus Datenübernahme
142      cks_au(1) VALUE 'E',     "Bestellung aus Aufteiler (IS-Retail)
143      cks_kb(1) VALUE 'F',     "Bestellung aus Kanban
144      cks_fa(1) VALUE 'G',     "Bestellung aus Filialauftrag (IS-Retail)
145      cks_dr(1) VALUE 'H',     "Bestellung aus DRP
146      cks_ba(1) VALUE 'I',     "Bestellung aus BAPI
147      cks_al(1) VALUE 'J',     "Bestellung aus ALE-Szenario
148      cks_sb(1) VALUE 'S',     "Sammelbestellung (IS-Retail)
149      cks_ap(1) VALUE '1',     "APO
150      cks_en(1) VALUE '9',     "Enjoy Bestellung
151      cks_fb(1) VALUE 'X',     "Bestellung aus Funktionsbaustein
152      cks_crm LIKE ekko-statu VALUE 'L',   "Lieferplan aus CRM
153      cks_po_crm LIKE ekko-statu VALUE 'R',   "Bestellung aus CRM
154
155    * Status der Einkaufsbelegposition (ekpo-status)
156      cps_ccp LIKE ekpo-status VALUE 'C',  "Bestellpos. aus CrossCompProc
157
158    * Vorgang aus T160
159      vorga-angb(2) VALUE 'AG',   "Angebot zur Anfrage    ME47, ME48
160      vorga-lpet(2) VALUE 'LE',   "Lieferplaneinteilung   ME38, ME39
161      vorga-frge(2) VALUE 'EF',   "Einkaufsbelegfreigabe  ME28, ME35, ME45
162      vorga-frgs(2) VALUE 'ES',   "Einzelfreigabe
163      vorga-frgb(2) VALUE 'BF',   "Banffreigabe           ME54, ME55
164      vorga-bgen(2) VALUE 'BB',   "Best. Lief.unbekannt   ME25
165      vorga-anha(2) VALUE 'FT',   "Textanhang             ME24, ME26,...
166      vorga-banf(2) VALUE 'B ',   "Banf                   ME51, ME52, ME53
167      vorga-anfr(2) VALUE 'A ',   "Anfrage                ME41, ME42, ME43
168      vorga-best(2) VALUE 'F ',   "Bestellung             ME21, ME22, ME23
169      vorga-kont(2) VALUE 'K ',   "Kontrakt               ME31, ME32, ME33
170      vorga-lfpl(2) VALUE 'L ',   "Lieferplan             ME31, ME32, ME33
171      vorga-mahn(2) VALUE 'MA',   "Liefermahnung          ME91
172      vorga-aufb(2) VALUE 'AB'.   "Bestätigungsmahnung    ME92
173
174    * Felder für Feldauswahl (früher FMMEXCOM)
175    DATA: endmaske(490) TYPE c,
176          kmaske(140) TYPE c,
177          auswahl0 TYPE brefn,
178          auswahl1 TYPE brefn,
179          auswahl2 TYPE brefn,
180          auswahl3 TYPE brefn,
181          auswahl4 TYPE brefn,
182          auswahl5 TYPE brefn,
183          auswahl6 TYPE brefn.
184    "-->Check for Workflow Simulation
185    DATA: gv_wfl_sim_not_req TYPE boolean.
186
187    * Sonderbestandskennzeichen
188    CONSTANTS:
189      sobkz-kdein VALUE 'E',               "Kundeneinzel
190      sobkz-prein VALUE 'Q',               "Projekteinzel
191      sobkz-lohnb VALUE 'O'.               "Lohnbearbeiterbeistell
192
193    "{ Begin FMMEXDIR_03 ENHO AD_MPN_PUR2_FMMEXDIR IS-AD-SUC AD_SUB }
194    * ADCI MPN: Constants
195    CONSTANTS:
196      gc_create         TYPE sytcode              VALUE 'ME21N',
197      gc_change         TYPE sytcode              VALUE 'ME22N',
198      gc_display        TYPE sytcode              VALUE 'ME23N',
199      gc_me51n_cr       TYPE sytcode              VALUE 'ME51N',     "n2101477
200      gc_me51n_ch       TYPE sytcode              VALUE 'ME52N',
201      gc_me51n_ds       TYPE sytcode              VALUE 'ME53N',
202      gc_create_actvt   TYPE activ_auth           VALUE '01',
203      gc_change_actvt   TYPE activ_auth           VALUE '02',
204      gc_display_actvt  TYPE activ_auth           VALUE '03',
205      gc_sto_process    TYPE adpic_d_process_code VALUE 'STOME',
206      gc_sto_bapi       TYPE adpic_d_process_code VALUE 'STOBAPI',
207      gc_me_process     TYPE adpic_d_process_code VALUE 'ME'.
208
209    CONSTANTS:
210        UPTYP-VOR VALUE '9'.           "Vorkommisionierungsposition (retail)
211    "{ End FMMEXDIR_03 ENHO AD_MPN_PUR2_FMMEXDIR IS-AD-SUC AD_SUB }
212
213    ENHANCEMENT-POINT fmmexdir_03 SPOTS es_fmmexdir STATIC INCLUDE BOUND.
214
215    * Min-/Maxwerte für Datenelemente
216    CONSTANTS:
217    * offener Rechnungseingangswert / Feldlänge: 13 / Dezimalstellen: 2
218      c_max_orewr       LIKE rm06a-orewr  VALUE '99999999999.99',
219      c_max_orewr_f     TYPE f            VALUE '9999999999999.99',
220      c_max_orewr_x(15) TYPE c            VALUE '**************',
221
222      c_max_proz_p(3)   TYPE p DECIMALS 2 VALUE '999.99',
223      c_max_proz_x(6)   TYPE c            VALUE '******',
224
225      c_max_menge       LIKE ekpo-menge   VALUE '9999999999.999',
226      c_max_menge_f     TYPE f            VALUE '9999999999.999',
227
228      c_max_netwr       LIKE ekpo-netwr   VALUE '99999999999.99',
229      c_max_netwr_f     TYPE f            VALUE '99999999999.99',
230
231    * Status des Einkaufsbeleges (EKKO-STATU)
232      cks_bbp LIKE ekko-statu VALUE 'K',  "Bestellung über BBP
233      cks_es  LIKE ekko-statu VALUE 'M',  "Contract/SA replicated from ES
234
235    * Distribution Indicator Account assignment
236      c_dist_ind-single   VALUE ' ',      "no multiple = single
237      c_dist_ind-quantity VALUE '1',      "quantity distribution
238      c_dist_ind-percent  VALUE '2',      "percentag
239      c_dist_ind-amount   VALUE '3'.      "amount based distribution
240
241    * EHP5: FIR, changes in contract release info.
242    * Constants:
243    * Business transaction types
244    CONSTANTS:
245      gc_invoice             VALUE 1,
246      gc_credit_memo         VALUE 2,
247      gc_subsequent_debit    VALUE 3,
248      gc_subsequent_credit   VALUE 4,
249
250    * Type Codes
251      gc_typcd_invoice(4)             VALUE '004',
252      gc_typcd_credit_memo(4)         VALUE '005',
253      gc_typcd_subsequent_debit(4)    VALUE '005',
254      gc_typcd_subsequent_credit(4)   VALUE '006',
255
256    * Invoice status types
257      gc_post_space(1)      VALUE ' ',
258      gc_post_5(1)          VALUE '5',
259      gc_delete(1)          VALUE '2',
260      gc_parked(1)          VALUE 'A',
261      gc_parked_complete(1) VALUE 'B',
262      gc_parked_released(1) VALUE 'E',
263
264    * Ivoice action type
265      gc_act_create(2)      VALUE '01',
266      gc_act_change(2)      VALUE '02',
267      gc_act_delete(2)      VALUE '03',
268
269    * Update/delete flags
270      gc_liv_upd(1)          VALUE 'U',
271      gc_liv_del(1)          VALUE 'D',
272
273    * Debit/credit flags
274      gc_shkzg_debit(1)      VALUE 'S',
275      gc_shkzg_credit(1)     VALUE 'H',
276
277    * koart flag
278      gc_koart_po            VALUE ' ',
279      gc_koart_contract      VALUE 'C'.
280
281    * END OF EHP5: FIR, changes in contract release info.
282
283    SET EXTENDED CHECK ON.
*--- End of FMMEXDIR - 283 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06LCIM                                  Level 2    Page 12
Object           SAPMZFM06B                                Lines 11
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      ***INCLUDE FM06LCIM .
2
3      DATA:    BEGIN OF COMMON PART FM06LCIM.
4
5      * internal table with real estate objects corresponding to the
6      * selection criteria
7      DATA:    T_IMKEYS LIKE VIREKEY OCCURS 0 WITH HEADER LINE.
8      * flag: real estate selections used
9      DATA:    X_RESEL LIKE SY-CALLD. "#EC *
10
11     DATA:    END OF COMMON PART.
*--- End of FM06LCIM - 11 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06B_AUTHORITY_BESWKF01                  Level 1    Page 13
Object           SAPMZFM06B                                Lines 74
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *----------------------------------------------------------------------*
2      ***INCLUDE FM06B_AUTHORITY_BESWKF01 .
3      *----------------------------------------------------------------------*
4      *&---------------------------------------------------------------------*
5      *&      Form  authority_beswk
6      *&---------------------------------------------------------------------*
7      *       text
8      *----------------------------------------------------------------------*
9      *      -->P_EBAN  text
10     *      -->P_LS_EBAN_OLD  text
11     *----------------------------------------------------------------------*
12     FORM authority_beswk USING value(is_eban_new) TYPE eban
13                                value(is_eban_old) TYPE eban.
14
15       DATA: lo_auth       TYPE REF TO cl_auth_buf_mm,
16             lf_ccp_active TYPE c,
17             lf_auth       LIKE sy-subrc.
18
19       CALL FUNCTION 'ME_CCP_ACTIVE_CHECK'
20         IMPORTING
21           ef_ccp_active = lf_ccp_active.
22       CHECK NOT lf_ccp_active IS INITIAL.
23
24       CHECK NOT ( is_eban_new-beswk IS INITIAL AND
25                   is_eban_old-beswk IS INITIAL ).
26
27       lo_auth = cl_auth_buf_mm=>get_instance( ).
28
29       IF is_eban_old-beswk IS INITIAL.         " new proc. plant
30         IF lo_auth->execute( im_object = mmpur_auth_banf_bwk
31                              im_actvt  = '01'
32                              im_id1    = mmpur_beswk
33                              im_val1   = is_eban_new-beswk ) NE 0.
34     *    AUTHORITY-CHECK OBJECT 'M_BANF_BWK'
35     *          ID 'ACTVT' FIELD '01'
36     *          ID 'BESWK' FIELD is_eban_new-beswk.
37     *    IF sy-subrc NE 0.
38           MESSAGE e208(mepo) WITH is_eban_new-beswk text-c01.
39         ENDIF.
40       ELSEIF is_eban_new-beswk IS INITIAL.   "delete proc plant
41
42         IF lo_auth->execute( im_object = mmpur_auth_banf_bwk
43                              im_actvt  = '06'
44                              im_id1    = mmpur_beswk
45                              im_val1   = is_eban_old-beswk ) NE 0.
46           MESSAGE e208(mepo) WITH is_eban_old-beswk text-c06.
47         ENDIF.
48
49       ELSEIF is_eban_old-beswk NE eban-beswk.  "change
50
51         IF lo_auth->execute( im_object = mmpur_auth_banf_bwk
52                              im_actvt  = '02'
53                              im_id1    = mmpur_beswk
54                              im_val1   = is_eban_new-beswk ) NE 0.
55           MESSAGE e208(mepo) WITH is_eban_new-beswk text-c02.
56         ENDIF.
57       ELSEIF is_eban_old-beswk EQ is_eban_new-beswk AND
58         ( is_eban_new-flief NE is_eban_old-flief  OR
59           is_eban_new-ekorg NE is_eban_old-ekorg  OR
60           is_eban_new-infnr NE is_eban_old-infnr  OR
61           is_eban_new-konnr NE is_eban_old-konnr  OR
62           is_eban_new-ktpnr NE is_eban_old-ktpnr  OR
63           is_eban_new-reswk NE is_eban_old-reswk ).
64
65         IF lo_auth->execute( im_object = mmpur_auth_banf_bwk
66                              im_actvt  = '22'
67                              im_id1    = mmpur_beswk
68                              im_val1   = is_eban_new-beswk ) NE 0.
69           MESSAGE e207(mepo) WITH is_eban_new-beswk.
70         ENDIF.
71       ENDIF.
72
73
74     ENDFORM.                    " authority_beswk
*--- End of FM06B_AUTHORITY_BESWKF01 - 74 lines ---

----------------------------------------------------------------------------------------------------
Include          MZFM06BF01                                Level 1    Page 14
Object           SAPMZFM06B                                Lines 30
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1        INCLUDE FM06BF01_BAN_AUSGABE_VORBEREIT .  " BAN_AUSGABE_VORBEREITEN
2
3        INCLUDE FM06BF01_BAN_SORT .  " BAN_SORT
4
5        INCLUDE FM06BF01_BAN_DYNP_CALL .  " BAN_DYNP_CALL
6        INCLUDE FM06BF01_BAN_DYNP_LIST_EXIT .  " BAN_DYNP_LIST_EXIT
7
8        INCLUDE FM06BF01_BAN_DYNP_PBO .  " BAN_DYNP_PBO
9
10       INCLUDE FM06BF01_BAN_DYNP_PBO_LOOP .  " BAN_DYNP_PBO_LOOP
11       INCLUDE FM06BF01_BAN_DYNP_PAI_LOOP1 .  " BAN_DYNP_PAI_LOOP1
12
13       INCLUDE FM06BF01_BAN_DYNP_PAI_LOOP2 .  " BAN_DYNP_PAI_LOOP2
14
15       INCLUDE FM06BF01_BAN_DYNP_PAI .  " BAN_DYNP_PAI
16
17       INCLUDE FM06BF01_BAN_ZEILEN .  " BAN_ZEILEN
18
19       INCLUDE FM06BF01_BAN_KONT_WECHSEL .  " BAN_KONT_WECHSEL
20
21       INCLUDE FM06BF01_DIEN_LISTE .  " DIEN_LISTE
22
23       INCLUDE FM06BF01_KONSI_LISTE .  " KONSI_LISTE
24     *----Start---------Addded by Nitin Nemawarkar (SISL) 23/05/2003
25       INCLUDE ZMM_FM06BF01_BAN_ZUORD .  " BAN_ZUORD
26     *----End---------Addded by Nitin Nemawarkar (SISL) 23/05/2003
27
28       INCLUDE FM06BF01_SUBMIT .  " SUBMIT
29
30       INCLUDE FM06BF01_START .  " START
*--- End of MZFM06BF01 - 30 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF01_BAN_AUSGABE_VORBEREIT            Level 2    Page 15
Object           SAPMZFM06B                                Lines 34
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      ************************************************************************
2      *        Unterroutinen Listanzeige Banf                                *
3      ************************************************************************
4      *  82362  3.1I  10.10.1997  CF
5      *  91102        17.12.1997  SM ME56 nicht batchinputfähig
6      *eject
7      *----------------------------------------------------------------------*
8      *        Felder für BAN-Ausgabe vorbereiten                            *
9      *----------------------------------------------------------------------*
10     FORM BAN_AUSGABE_VORBEREITEN USING BAV_LFLAG.
11
12     *- Zusätzliche Daten bereitstellen ------------------------------------*
13       PERFORM BAN_DATEN USING BAV_LFLAG.
14
15     *- Datum in Ausgabeformat bringen -------------------------------------*
16       CALL FUNCTION 'PERIOD_AND_DATE_CONVERT_OUTPUT'
17            EXPORTING
18                 INTERNAL_DATE   = EBAN-LFDAT
19                 INTERNAL_PERIOD = EBAN-LPEIN
20            IMPORTING
21                 EXTERNAL_DATE   = RM06B-EEIND
22                 EXTERNAL_PERIOD = RM06B-LPEIN.
23
24     *- Positionstyp in Ausgabeformat bringen ------------------------------*
25       CALL FUNCTION 'ME_ITEM_CATEGORY_OUTPUT'
26            EXPORTING
27                 PSTYP = EBAN-PSTYP
28            IMPORTING
29                 EPSTP = RM06B-EPSTP.
30     *- Zuordnungsinformation ----------------------------------------------*
31       IF XZLTYP NE SPACE.
32         PERFORM BAN_ZUORD USING SPACE.
33       ENDIF.
34     ENDFORM.
*--- End of FM06BF01_BAN_AUSGABE_VORBEREIT - 34 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF01_BAN_SORT                         Level 2    Page 16
Object           SAPMZFM06B                                Lines 106
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *        BAN sortieren                                                 *
4      *----------------------------------------------------------------------*
5      FORM BAN_SORT.
6
7        CASE COM-SRTKZ.
8          WHEN 1.
9            IF NOT GS_BANF IS INITIAL.
10     *... Gesamtbanfen sollen eine eigene Listaufbereitung haben ..........*
11             SORT BAN BY GSFRG BANFN BNFPO.
12           ELSE.
13             SORT BAN BY BANFN BNFPO.
14           ENDIF.
15         WHEN 2.
16           IF NOT GS_BANF IS INITIAL.
17     *... Eine Sortierung ist nur für Positionsfreigabe möglich ...........*
18             BAN_GS[] = BAN[].
19             DELETE BAN_GS WHERE GSFRG EQ SPACE.
20             DELETE BAN    WHERE GSFRG NE SPACE.
21             SORT BAN BY EKGRP MATNR LFDAT BANFN BNFPO.
22             APPEND LINES OF BAN_GS TO BAN.
23           ELSE.
24             SORT BAN BY EKGRP MATNR LFDAT BANFN BNFPO.
25           ENDIF.
26         WHEN 3.
27           IF NOT GS_BANF IS INITIAL.
28     *... Eine Sortierung ist nur für Positionsfreigabe möglich ...........*
29             BAN_GS[] = BAN[].
30             DELETE BAN_GS WHERE GSFRG EQ SPACE.
31             DELETE BAN    WHERE GSFRG NE SPACE.
32             SORT BAN BY BEDNR EKGRP WERKS BANFN BNFPO.
33             APPEND LINES OF BAN_GS TO BAN.
34           ELSE.
35             SORT BAN BY BEDNR EKGRP WERKS BANFN BNFPO.
36           ENDIF.
37         WHEN 4.
38           IF NOT GS_BANF IS INITIAL.
39             BAN_GS[] = BAN[].
40             DELETE BAN_GS WHERE GSFRG EQ SPACE.
41             DELETE BAN    WHERE GSFRG NE SPACE.
42             SORT BAN BY FRGDT WERKS BANFN BNFPO.
43             APPEND LINES OF BAN_GS TO BAN.
44           ELSE.
45             SORT BAN BY FRGDT WERKS BANFN BNFPO.
46           ENDIF.
47         WHEN 5.
48           IF NOT GS_BANF IS INITIAL.
49             BAN_GS[] = BAN[].
50             DELETE BAN_GS WHERE GSFRG EQ SPACE.
51             DELETE BAN    WHERE GSFRG NE SPACE.
52             SORT BAN BY MATKL BANFN BNFPO.
53             APPEND LINES OF BAN_GS TO BAN.
54           ELSE.
55             SORT BAN BY MATKL BANFN BNFPO.
56           ENDIF.
57         WHEN 6.
58           IF NOT GS_BANF IS INITIAL.
59             BAN_GS[] = BAN[].
60             DELETE BAN_GS WHERE GSFRG EQ SPACE.
61             DELETE BAN    WHERE GSFRG NE SPACE.
62             SORT BAN BY WERKS DISPO BANFN BNFPO.
63             APPEND LINES OF BAN_GS TO BAN.
64           ELSE.
65             SORT BAN BY WERKS DISPO BANFN BNFPO.
66           ENDIF.
67         WHEN 7.
68     ENHANCEMENT-SECTION     FM06BF01_BAN_SORT_01 SPOTS ES_SAPFM06B.
69           IF NOT GS_BANF IS INITIAL.
70             BAN_GS[] = BAN[].
71             DELETE BAN_GS WHERE GSFRG EQ SPACE.
72             DELETE BAN    WHERE GSFRG NE SPACE.
73             SORT BAN BY MATNR BANFN BNFPO.
74             APPEND LINES OF BAN_GS TO BAN.
75           ELSE.
76             SORT BAN BY MATNR BANFN BNFPO.
77           ENDIF.
78     END-ENHANCEMENT-SECTION.
79         WHEN 8.
80           IF NOT GS_BANF IS INITIAL.
81             BAN_GS[] = BAN[].
82             DELETE BAN_GS WHERE GSFRG EQ SPACE.
83             DELETE BAN    WHERE GSFRG NE SPACE.
84             SORT BAN BY KONT1 KONT2 BANFN BNFPO.
85             APPEND LINES OF BAN_GS TO BAN.
86           ELSE.
87             SORT BAN BY KONT1 KONT2 BANFN BNFPO.
88           ENDIF.
89         WHEN 9.
90           IF NOT GS_BANF IS INITIAL.
91             BAN_GS[] = BAN[].
92             DELETE BAN_GS WHERE GSFRG EQ SPACE.
93             DELETE BAN    WHERE GSFRG NE SPACE.
94             SORT BAN BY RESWK SLIEF EKORG BSART KONNR UPDK1 BANFN BNFPO.
95             APPEND LINES OF BAN_GS TO BAN.
96           ELSE.
97     * Begin CCP
98     *        SORT BAN BY RESWK SLIEF EKORG BSART KONNR UPDK1 BANFN BNFPO.
99             SORT BAN BY RESWK SLIEF BESWK EKORG BSART KONNR
100                        UPDK1 BANFN BNFPO.
101    * End CCP
102          ENDIF.
103      ENDCASE.
104
105    ENHANCEMENT-POINT FM06BF01_BAN_SORT_02 SPOTS ES_SAPFM06B.
106    ENDFORM.
*--- End of FM06BF01_BAN_SORT - 106 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF01_BAN_DYNP_CALL                    Level 2    Page 17
Object           SAPMZFM06B                                Lines 41
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *        Dynpro für Banfbearbeitung aufrufen                           *
4      *----------------------------------------------------------------------*
5      FORM BAN_DYNP_CALL.
6
7        CLEAR: B-AKTIND, B-LOPIND, B-MAXIND, B-PAGIND, B-LESIND.
8        REFRESH BDT.
9        DESCRIBE TABLE BAN LINES B-MAXIND.
10     *- Indextabelle bei Detailanzeige aufbauen ----------------------------*
11       IF DET NE SPACE.
12         CLEAR B-MAXIND.
13         LOOP AT BAN.
14           PERFORM DET_CHECK.
15           CHECK SY-SUBRC EQ 0.
16           BDT-INDEX = SY-TABIX.
17           APPEND BDT.
18           B-MAXIND = B-MAXIND + 1.
19         ENDLOOP.
20       ENDIF.
21
22       CASE XCALLD.
23     *- Liste -> Loop oder Start mit Loop ----------------------------------*
24         WHEN SPACE.
25           XCALLD = 'X'.
26           CALL SCREEN T16LB-DYNPR.
27     *- Loop  -> Loop ------------------------------------------------------*
28         WHEN 'Y'.
29           XCALLD = 'X'.
30           SET SCREEN T16LB-DYNPR.
31     *- Loop  -> Liste -> gleiches Loop-Dynpro -----------------------------*
32         WHEN 'X'.
33           LEAVE.
34     *- Loop  -> Liste -> anderes Loop-Dynpro ------------------------------*
35         WHEN 'Z'.
36           XCALLD = 'X'.
37           SET SCREEN T16LB-DYNPR.
38           LEAVE.
39       ENDCASE.
40
41     ENDFORM.
*--- End of FM06BF01_BAN_DYNP_CALL - 41 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF01_BAN_DYNP_LIST_EXIT               Level 2    Page 18
Object           SAPMZFM06B                                Lines 13
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *        Dynpro für Banf-Bearbeitung PAI nach Loop.                   *
4      *----------------------------------------------------------------------*
5      FORM BAN_DYNP_LIST_EXIT USING BDL_OK.
6        CASE BDL_OK.
7          WHEN 'XIT'.
8            LOOPEXIT = '1'.
9          WHEN 'XIL'.
10           LOOPEXIT = '2'.
11           CLEAR BDL_OK.
12       ENDCASE.
13     ENDFORM.
*--- End of FM06BF01_BAN_DYNP_LIST_EXIT - 13 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF01_BAN_DYNP_PBO                     Level 2    Page 19
Object           SAPMZFM06B                                Lines 12
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *        Dynpro für Banf-Bearbeitung PBO vor Loop.                     *
4      *----------------------------------------------------------------------*
5      FORM BAN_DYNP_PBO.
6
7        SET PF-STATUS GPFKEY.
8        SET TITLEBAR GFMKEY.
9        B-PAGIND = 0.
10       CLEAR HIDE-INDEX.
11
12     ENDFORM.
*--- End of FM06BF01_BAN_DYNP_PBO - 12 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF01_BAN_DYNP_PBO_LOOP                Level 2    Page 20
Object           SAPMZFM06B                                Lines 72
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *        Dynpro für Banf-Bearbeitung PBO im  Loop.                     *
4      *----------------------------------------------------------------------*
5      FORM BAN_DYNP_PBO_LOOP.
6
7        B-LOPIND = SY-LOOPC.
8        DO.
9          B-AKTIND = B-AKTIND + 1.
10         CLEAR EBAN.
11         IF DET NE SPACE.
12           CLEAR BDT.
13           READ TABLE BDT INDEX B-AKTIND.
14           READ TABLE BAN INDEX BDT-INDEX.
15         ELSE.
16           READ TABLE BAN INDEX B-AKTIND.
17         ENDIF.
18
19         IF SY-SUBRC EQ 0.
20           EBAN = BAN.
21           RM06B-SELKZ = BAN-SELKZ.
22           PERFORM BAN_AUSGABE_VORBEREITEN USING 'G'.
23           B-PAGIND = B-PAGIND + 1.
24           EXIT.
25         ELSE.
26           B-AKTIND = B-AKTIND - 1.
27           EXIT FROM STEP-LOOP.
28         ENDIF.
29       ENDDO.
30
31     *- Modifizieren Eingabebereitsschaft Felder ---------------------------*
32       LOOP AT SCREEN.
33     *- Banf gelöscht - keine Felder eingabebereit -------------------------*
34         IF EBAN-LOEKZ NE SPACE AND
35            SCREEN-INPUT EQ 1.
36           SCREEN-INPUT = 0.
37           MODIFY SCREEN.
38         ENDIF.
39     *- Dienstleistungsposition - Menge nicht eingabebereit ----------------*
40         IF EBAN-PSTYP EQ '9' AND
41            SCREEN-GROUP3 EQ '001'.
42           SCREEN-INPUT = 0.
43           MODIFY SCREEN.
44         ENDIF.
45     *- DCM check blocking authority against ME52N/ME52NB authority of user
46         if screen-name eq 'EBAN-BLCKT'
47         or screen-name eq 'EBAN-BLCKD'.
48           if not eban-blckd is initial.
49             data: l_tcode type tstc-tcode.
50             if eban-blckd eq '1'.
51               l_tcode = 'ME52N'.  "originator block
52             else.
53               l_tcode = 'ME52NB'. "buyer block
54             endif.
55     *......authority check
56             CALL FUNCTION 'AUTHORITY_CHECK_TCODE'
57               EXPORTING
58                 tcode  = l_tcode
59               EXCEPTIONS
60                 ok     = 0
61                 not_ok = 1
62                 OTHERS = 2.
63             IF sy-subrc NE 0.
64               SCREEN-INPUT = 0.
65               MODIFY SCREEN.
66             endif.
67           endif.
68         endif.
69
70       ENDLOOP.
71
72     ENDFORM.                    "BAN_DYNP_PBO_LOOP
*--- End of FM06BF01_BAN_DYNP_PBO_LOOP - 72 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF01_BAN_DYNP_PAI_LOOP1               Level 2    Page 21
Object           SAPMZFM06B                                Lines 18
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *        Dynpro für Banf-Bearbeitung PAI im Loop (vor Feldtransport)  *
4      *----------------------------------------------------------------------*
5      FORM BAN_DYNP_PAI_LOOP1.
6
7        B-LESIND = B-AKTIND - B-PAGIND + SY-STEPL.
8        IF DET NE SPACE.
9          READ TABLE BDT INDEX B-LESIND.
10         CHECK SY-SUBRC EQ 0.
11         B-LESIND = BDT-INDEX.
12       ENDIF.
13
14       READ TABLE BAN INDEX B-LESIND.
15       CHECK SY-SUBRC EQ 0.
16       MOVE BAN TO EBAN.
17
18     ENDFORM.
*--- End of FM06BF01_BAN_DYNP_PAI_LOOP1 - 18 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF01_BAN_DYNP_PAI_LOOP2               Level 2    Page 22
Object           SAPMZFM06B                                Lines 102
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *        Dynpro für Banf-Bearbeitung PAI im Loop.                     *
4      *----------------------------------------------------------------------*
5      FORM BAN_DYNP_PAI_LOOP2.
6
7        DATA: FELD(20),
8              ZEILE LIKE SY-LINNO.
9
10     *- EXIT-Command berücksichtigen ---------------------------------------*
11       CASE LOOPEXIT.
12         WHEN '1'.
13           EXIT.
14         WHEN '2'.
15           CLEAR LOOPEXIT.
16           EXIT.
17       ENDCASE.
18
19     *- Nur definierte Felder übernehmen -----------------------------------*
20       MOVE EBAN TO *EBAN.
21       MOVE BAN TO EBAN.
22       EBAN-MENGE = *EBAN-MENGE.
23       EBAN-FLIEF = *EBAN-FLIEF.
24       EBAN-EKORG = *EBAN-EKORG.
25       EBAN-KONNR = *EBAN-KONNR.
26       EBAN-KTPNR = *EBAN-KTPNR.
27       EBAN-INFNR = *EBAN-INFNR.
28
29     *DCM blocking fields
30       data: l_tcode type tstc-tcode.
31       if eban-blckd ne *eban-blckd.
32         if *eban-blckd eq '2'
33         or ( *eban-blckd is initial and eban-blckd eq '2' ).
34           l_tcode = 'ME52NB'.
35         else.
36           l_tcode = 'ME52N'.
37         endif.
38     *...authority check
39         CALL FUNCTION 'AUTHORITY_CHECK_TCODE'
40           EXPORTING
41             tcode  = l_tcode
42           EXCEPTIONS
43             ok     = 0
44             not_ok = 1
45             OTHERS = 2.
46         IF sy-subrc NE 0.
47     *...blocking not allowed
48           if l_tcode eq 'ME52NB'.
49             message i015(MEDCM).
50           else.
51             message i016(medcm).
52           endif.
53         else.
54           eban-blckd = *eban-blckd.
55         endif.
56       endif.
57       if eban-blckd is initial.
58         clear eban-blckt.
59       else.
60         eban-blckt = *eban-blckt.
61         if eban-blckt is initial.
62           perform enaco(sapfmmex) using 'MEDCM' '024'.
63           CASE sy-subrc.
64             WHEN 02.  message e024(MEDCM).
65             WHEN 01.  message W024(MEDCM).
66           ENDCASE.
67         endif.
68       endif.
69
70       MOVE BAN TO *EBAN.
71
72     *- Lieferdatum prüfen -------------------------------------------------*
73       PERFORM AEND_LFDAT.
74       PERFORM AEND_MENGE.
75       IF EBAN-MENGE NE *EBAN-MENGE OR
76          EBAN-LFDAT NE *EBAN-LFDAT OR
77          EBAN-FLIEF NE *EBAN-FLIEF OR
78          EBAN-EKORG NE *EBAN-EKORG OR
79          EBAN-KONNR NE *EBAN-KONNR OR
80          EBAN-KTPNR NE *EBAN-KTPNR OR
81          EBAN-BESWK NE *EBAN-BESWK OR
82          EBAN-INFNR NE *EBAN-INFNR.
83         MOVE-CORRESPONDING EBAN TO BAN.
84         PERFORM AEND_BEZUG.
85       ENDIF.
86       IF EBAN NE *EBAN.
87         MOVE-CORRESPONDING EBAN TO BAN.
88         BAN-SELKZ = RM06B-SELKZ.
89         BAN-UPDK1 = AEND.
90         MODIFY BAN INDEX B-LESIND.
91       ELSE.
92         IF RM06B-SELKZ NE BAN-SELKZ.
93           BAN-SELKZ = RM06B-SELKZ.
94           MODIFY BAN INDEX B-LESIND.
95         ENDIF.
96       ENDIF.
97       GET CURSOR FIELD FELD LINE ZEILE.
98       IF SY-STEPL EQ ZEILE.
99         HIDE-INDEX = B-LESIND.
100      ENDIF.
101
102    ENDFORM.                    "BAN_DYNP_PAI_LOOP2
*--- End of FM06BF01_BAN_DYNP_PAI_LOOP2 - 102 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF01_BAN_DYNP_PAI                     Level 2    Page 23
Object           SAPMZFM06B                                Lines 33
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *        Dynpro für Banf-Bearbeitung PAI nach Loop.                   *
4      *----------------------------------------------------------------------*
5      FORM BAN_DYNP_PAI USING BDP_OK.
6
7        CLEAR LOOPEXIT.
8        CASE BDP_OK.
9          WHEN 'P+'.                         "eine Seite weiter
10           IF B-AKTIND = B-MAXIND.
11             B-AKTIND = B-AKTIND - B-PAGIND.
12           ENDIF.
13           CLEAR BDP_OK.
14         WHEN 'P-'.                         "eine Seite zurueck
15           B-AKTIND = B-AKTIND - B-PAGIND - B-LOPIND.
16           CLEAR BDP_OK.
17         WHEN 'P++'.                        "auf letzte Seite
18           B-AKTIND = B-MAXIND - B-LOPIND.
19           CLEAR BDP_OK.
20         WHEN 'P--'.                        "auf erste Seite
21           B-AKTIND = 0.
22           CLEAR BDP_OK.
23         WHEN OTHERS.
24           B-AKTIND = B-AKTIND - B-PAGIND.
25           SY-UCOMM = BDP_OK.
26           CLEAR BDP_OK.
27           PERFORM USER_COMMAND.
28       ENDCASE.
29
30       IF B-AKTIND LT 0.
31         B-AKTIND = 0.
32       ENDIF.
33     ENDFORM.
*--- End of FM06BF01_BAN_DYNP_PAI - 33 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF01_BAN_ZEILEN                       Level 2    Page 24
Object           SAPMZFM06B                                Lines 126
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *        Ausgabe der selektierten Bestellanforderungen                 *
4      *----------------------------------------------------------------------*
5      FORM BAN_ZEILEN.
6
7        DATA: L_BANFN LIKE EBAN-BANFN.
8
9      *-Test Test------------------------------------------------------------*
10     *-- bei Auswählfunktion Banf -    no-record-found-Kennzeichen resetten *
11       CLEAR CUEB-NRCFD.
12       CLEAR: HKONT1, HKONT2.
13
14       COLFLAG = 'X'.
15       LEAVE TO LIST-PROCESSING.
16     ENHANCEMENT-SECTION     BAN_ZEILEN_01 SPOTS ES_SAPFM06B.
17       NEW-PAGE LINE-SIZE 81.
18     END-ENHANCEMENT-SECTION.
19       CLEAR L_BANFN.
20
21     * for performance reasons fill buffer of vendor names
22       READ TABLE XT16LD TRANSPORTING NO FIELDS WITH KEY LLIST = '005'.
23       IF sy-subrc = 0 OR xzltyp NE SPACE.
24         PERFORM vendor_array_read.
25       ENDIF.
26
27       LOOP AT BAN.
28         IF NOT GS_BANF IS INITIAL.
29     *... Eigene Listaufbereitung für Gesamtbanfen ........................*
30           ON CHANGE OF BAN-GSFRG.
31     *... Neue Überschriften wenn es mit den Gesamtbanfen los geht ........*
32             NEW-PAGE.
33           ENDON.
34         ENDIF.
35     *- Prüfen Kriterien für Banfs zur Zuordnungsszeile -------------------*
36         PERFORM DET_CHECK.
37         CHECK SY-SUBRC EQ 0.
38
39         MOVE BAN TO EBAN.
40         HIDE-INDEX = SY-TABIX.
41         PERFORM BAN_KONT_WECHSEL.
42         PERFORM BAN_AUSGABE_VORBEREITEN USING 'G'.
43
44         IF NOT GS_BANF IS INITIAL.
45     *... Eigene Listaufbereitung für Gesamtbanfen ........................*
46           IF EBAN-BANFN NE L_BANFN.
47             L_BANFN = EBAN-BANFN.
48     *... 'Kopfzeile' für Banfen zur Gesamtfreigabe ausgeben ..............*
49             IF NOT EBAN-GSFRG IS INITIAL.
50     *... Zeilennummer bei Gesamtfreigabe merken ..........................*
51               WRITE: / ' '.
52               BAN-SZEIL = GS_SZEIL = SY-LINNO.
53               BAN-ZEILE = GS_ZEILE = SY-LINNO + 1.   "xzeile
54               BAN-PAGE  = SY-PAGNO.
55               MODIFY BAN.
56               FORMAT COLOR COL_GROUP INTENSIFIED.
57               CLEAR HROUTN.
58               HROUTN(14) = 'BAN_GSFRG_001'.
59               PERFORM (HROUTN) IN PROGRAM SAPFM06B.
60               FORMAT COLOR COL_GROUP INTENSIFIED OFF.
61             ENDIF.
62           ENDIF.
63
64           IF NOT EBAN-GSFRG IS INITIAL.
65             IF NOT GS_SZEIL IS INITIAL.
66     *... erste Zeile der Gesamtbanf merken ...............................*
67               BAN-SZEIL = GS_SZEIL.
68               BAN-ZEILE = GS_ZEILE.
69               BAN-PAGE  = SY-PAGNO.
70               MODIFY BAN.
71             ENDIF.
72           ELSE.
73     *- Zeilennummer merken ------------------------------------------------*
74             WRITE: / ' '.
75             BAN-SZEIL = SY-LINNO + XSZEIL.
76             BAN-ZEILE = SY-LINNO + XZEILE.
77             BAN-PAGE  = SY-PAGNO.
78             MODIFY BAN.
79           ENDIF.
80         ELSE.
81     *- Zeilennummer merken ------------------------------------------------*
82           WRITE: / ' '.
83           BAN-SZEIL = SY-LINNO + XSZEIL.
84           BAN-ZEILE = SY-LINNO + XZEILE.
85           BAN-PAGE  = SY-PAGNO.
86           MODIFY BAN.
87         ENDIF.
88
89     *- Zeilen ausgeben ----------------------------------------------------*
90         IF COLFLAG = 'X'.
91           FORMAT COLOR COL_NORMAL INTENSIFIED.
92         ELSE.
93           FORMAT COLOR COL_NORMAL INTENSIFIED OFF.
94         ENDIF.
95
96         CLEAR HROUTN.
97         HROUTN(10) = 'BAN_ZEILE_'.
98         LOOP AT XT16LD.
99           HROUTN+10(3) = XT16LD-LLIST.
100          PERFORM (HROUTN) IN PROGRAM SAPFM06B.
101
102    * Hide darf nicht ausgeführt werden in ME55, falls t16lb-gspos initial
103    * bei Banfen mit Gesamtfreigabe
104          IF GS_BANF EQ SPACE OR T16LB-GSPOS NE SPACE OR
105             EBAN-GSFRG EQ SPACE.
106            CLEAR HIDE-GSFRG.
107            HIDE: HIDE-INDEX, HIDE-GSFRG.
108          ENDIF.
109
110          IF GS_BANF IS INITIAL AND XT16LD-STATZ NE SPACE.
111             BAN-ZEILE = SY-LINNO.
112             MODIFY BAN.
113          ENDIF.
114        ENDLOOP.
115
116        IF COLFLAG = 'X'.
117          COLFLAG = ' '.
118        ELSE.
119          COLFLAG = 'X'.
120        ENDIF.
121        CLEAR: HIDE-INDEX.
122      ENDLOOP.
123    ENHANCEMENT-SECTION     BAN_ZEILEN_02 SPOTS ES_SAPFM06B.
124      ULINE.
125    END-ENHANCEMENT-SECTION.
126    ENDFORM.
*--- End of FM06BF01_BAN_ZEILEN - 126 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF01_BAN_KONT_WECHSEL                 Level 2    Page 25
Object           SAPMZFM06B                                Lines 63
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *        Gruppenwechsel Kontierung                                     *
4      *----------------------------------------------------------------------*
5      FORM BAN_KONT_WECHSEL.
6
7        DATA: L_OBJNR LIKE VIREKEY-OBJNR,
8              L_TEXT  LIKE SY-MSGV1.
9
10       COM-BKMKZ = BAN-BKMKZ.                               "4.0C
11       CHECK COM-BKMKZ NE SPACE.
12       CHECK COM-SRTKZ EQ '8'.
13
14       IF BAN-KONT1 NE HKONT1 OR
15          BAN-KONT2 NE HKONT2.
16         IF HKONT1 NE SPACE.
17           ULINE.
18     ENHANCEMENT-SECTION     FM06BF01_BAN_KONT_WECHSEL_01 SPOTS ES_SAPFM06B.
19           NEW-PAGE LINE-SIZE 81.
20     END-ENHANCEMENT-SECTION.
21         ENDIF.
22         HKONT1 = BAN-KONT1.
23         HKONT2 = BAN-KONT2.
24     *- Aufbereiten kontierungsüberschrift ---------------------------------*
25         CLEAR UEBKNT2.
26         CASE COM-BKMKZ.
27           WHEN '1' OR '2' OR '3'.
28             WRITE BAN-KONT1 TO UEBKNT2.
29           WHEN '4'.
30             WRITE BAN-KONT1 TO UEBKNT2.
31             WRITE BAN-KONT2 TO UEBKNT2+30.
32           WHEN '5'.
33             WRITE BAN-KONT1 TO UEBKNT2.
34             WRITE BAN-KONT2 TO UEBKNT2+30.
35           WHEN '6'.
36             MOVE BAN-KONT1(10) TO EBKN-AUFPL.
37             MOVE BAN-KONT2 TO EBKN-APLZL.
38             CALL FUNCTION 'READ_NETWORK_NPLNR_VORNR'
39                  EXPORTING
40                       APLZL     = EBKN-APLZL
41                       AUFPL     = EBKN-AUFPL
42                  IMPORTING
43                       NPLNR     = HNPLNR
44                       VORNR     = HVORNR
45                  EXCEPTIONS
46                       NOT_FOUND = 01.
47             WRITE HNPLNR TO UEBKNT2.
48             WRITE HVORNR TO UEBKNT2+30.
49           WHEN '7'.
50             L_OBJNR = BAN-KONT1.
51             CALL FUNCTION 'REMD_GET_TEXT_FOR_OBJECT'
52                  EXPORTING
53                       I_OBJNR     = L_OBJNR
54                       TEXT_WANTED = 'X'
55                  IMPORTING
56                       E_TEXT      = L_TEXT.
57             MOVE L_TEXT TO UEBKNT2.
58           WHEN '8'.                                             "602972
59             MOVE BAN-KONT1(12) TO UEBKNT2.
60         ENDCASE.
61         CONDENSE UEBKNT2.
62       ENDIF.
63     ENDFORM.
*--- End of FM06BF01_BAN_KONT_WECHSEL - 63 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF01_DIEN_LISTE                       Level 2    Page 26
Object           SAPMZFM06B                                Lines 42
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *        Ausgabe der Liste fuer Umsetzung Banf in Erfassungsblatt      *
4      *----------------------------------------------------------------------*
5      FORM DIEN_LISTE.
6
7       CHECK LISTE EQ 'Z'.
8
9       IF S-FIRSTIND EQ 0.
10        MESSAGE S201.
11        EXIT.
12      ENDIF.
13
14      PERFORM LISTE_MERKEN USING 'X'.
15      LISTE = 'G'.
16      COM-SRTKZ = '9'.
17
18      READ TABLE BAN INDEX S-FIRSTIND.
19     *set pf-status 'GERF' excluding excl.
20     *set titlebar  '015'.
21
22      CLEAR DET.
23      DET-UPDKZ = BAN-UPDK1.
24      DET-BSART = BAN-BSART.
25      DET-UPDKZ = 'XX'.
26      DET-EKORG = BAN-EKORG.
27      DET-SLIEF = BAN-SLIEF.
28      DET-RESWK = BAN-RESWK.
29      DET-KONNR = BAN-KONNR.
30      DET-FORDN = BAN-FORDN.
31      DET-BUKRS = BAN-BUKRS.
32
33      SY-LSIND = 0.
34      PERFORM ZUG_CLEAR.
35      PERFORM BAN_SORT.
36      IF T16LB-DYNPR EQ 0.
37        PERFORM BAN_ZEILEN.
38      ELSE.
39        PERFORM BAN_DYNP_CALL.
40      ENDIF.
41
42     ENDFORM.
*--- End of FM06BF01_DIEN_LISTE - 42 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF01_KONSI_LISTE                      Level 2    Page 27
Object           SAPMZFM06B                                Lines 111
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *        Ausgabe der Konsiliste                                        *
4      *----------------------------------------------------------------------*
5      FORM konsi_liste.
6
7        DATA: flag.
8        CLEAR kon.
9        REFRESH kon.
10     *-- Fuellen Materialstammview -----------------------------------------*
11       CLEAR mtcom.
12       mtcom-kenng = 'MT06K'.
13       mtcom-matnr = ban-matnr.
14       mtcom-werks = ban-werks.
15       PERFORM lesen_material_konsi.
16       IF mtcor-rmkop ne space.
17         MESSAGE s227.
18         EXIT.
19       ENDIF.
20
21     *-- Lesen Lieferantenstamm - fuellen Name in Konsitabelle -------------*
22       LOOP AT kon.
23         IF kon-lvorm eq space.
24           SELECT SINGLE * FROM lfa1 WHERE lifnr = kon-lifnr.
25     *     DP&P: Check for blocked vendor
26           INCLUDE mmpur_dpp_fm06bf01_konsi_liste IF FOUND.          "2119405
27           IF sy-subrc eq 0.
28             kon-name1 = lfa1-name1.
29             MODIFY kon INDEX sy-tabix.
30           ELSE.
31             DELETE kon.
32           ENDIF.
33         ELSE.
34           DELETE kon.
35         ENDIF.
36       ENDLOOP.
37
38     *-- Prüfen, ob überhaupt Eintrag in KON -------------------------------*
39       READ TABLE kon INDEX 1.
40       IF sy-subrc ne 0.
41         MESSAGE s227.
42         EXIT.
43       ENDIF.
44
45     *-- Ausgeben Konsiliste -----------------------------------------------*
46       LEAVE TO LIST-PROCESSING.
47       DATA: lpfkey LIKE sy-pfkey.          "TODO
48       DATA: ltitle LIKE sy-title.          "TODO
49       ltitle = '004'.
50       CASE sy-pfkey.
51         WHEN 'LIST'.
52           lpfkey = 'KONA'.
53         WHEN OTHERS.
54           lpfkey = 'KONS'.
55       ENDCASE.
56       SET PF-STATUS lpfkey.
57       NEW-PAGE LINE-SIZE 70.
58     * SET TITLEBAR '004' WITH BAN-MATNR.   "TODO
59       SET TITLEBAR ltitle WITH ban-matnr.
60
61     * Währung ermitteln 1                   "TODO
62       DATA: l_bwkey LIKE t001w-bwkey,
63             l_bukrs LIKE t001k-bukrs,
64             l_waers LIKE t001-waers.
65       CLEAR: l_bwkey, l_bukrs, l_waers.
66
67       CLEAR flag.
68       LOOP AT kon.
69
70     * Währung ermitteln 2                   "TODO
71         IF not kon-werks is initial.
72           SELECT SINGLE bwkey INTO l_bwkey FROM t001w
73                                            WHERE werks = kon-werks.
74           IF sy-subrc eq 0.
75             SELECT SINGLE bukrs INTO l_bukrs FROM t001k
76                                              WHERE bwkey = l_bwkey.
77             IF sy-subrc eq 0.
78               SELECT SINGLE waers INTO l_waers FROM t001
79                                                WHERE bukrs = l_bukrs.
80             ENDIF.
81           ENDIF.
82         ENDIF.
83         IF l_waers is initial.
84           l_waers = sy-waers.
85         ENDIF.
86
87         IF flag eq space.
88           FORMAT COLOR COL_NORMAL INTENSIFIED OFF.
89           flag = 'X'.
90         ELSE.
91           FORMAT COLOR COL_NORMAL INTENSIFIED.
92           CLEAR flag.
93         ENDIF.
94         WRITE: /  sy-vline,
95                 2 kon-lifnr,
96                12 sy-vline,
97                13 kon-name1,
98                43 sy-vline,
99                44 kon-konpr NO-SIGN NO-ZERO CURRENCY l_waers,
100               59 sy-vline,
101               60 kon-kopei NO-SIGN,
102               66 sy-vline,
103               67 ban-meins,
104               70 sy-vline.
105        hide-koind = sy-tabix.
106        HIDE hide-koind.
107        CLEAR hide-koind.
108      ENDLOOP.
109      ULINE.
110
111    ENDFORM.
*--- End of FM06BF01_KONSI_LISTE - 111 lines ---

----------------------------------------------------------------------------------------------------
Include          MMPUR_DPP_FM06BF01_KONSI_LISTE            Level 3    Page 28
Object           SAPMZFM06B                                Lines 25
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&  Include           MMPUR_DPP_FM06BF01_KONSI_LISTE
3      *&---------------------------------------------------------------------*
4
5      * Called from INCLUDE FM06BF01_KONSI_LISTE
6      * DP&P: Check for blocked vendor
7
8      DATA: lo_switch TYPE REF TO cl_mm_switch_check,
9            lv_tabix  TYPE sy-tabix.
10
11     lo_switch = cl_mm_switch_check=>get_instance( ).
12
13     IF lo_switch->mm_ddp_sfws_sc( ) IS NOT INITIAL.
14       lv_tabix = sy-tabix.
15       CALL METHOD cvp_cl_block_and_mask=>block_and_mask_generic
16         EXPORTING
17           iv_lifnr         = lfa1-lifnr
18           iv_set_to_buffer = cvp_cl_block_and_mask=>gc_true
19         CHANGING
20           cs_struct_w_cvp  = lfa1
21         EXCEPTIONS
22           lifnr_blocked    = 1
23           OTHERS           = 4.
24       sy-tabix = lv_tabix.
25     ENDIF.
*--- End of MMPUR_DPP_FM06BF01_KONSI_LISTE - 25 lines ---

----------------------------------------------------------------------------------------------------
Include          ZMM_FM06BF01_BAN_ZUORD                    Level 2    Page 29
Object           SAPMZFM06B                                Lines 251
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *        Zeile Bezugsquelle Rahmenvertrag                              *
4      *----------------------------------------------------------------------*
5      form ban_zuord using baz_flag.
6      * All Move-Instructions were replaced by Concatenate-Instructions, see
7      * note 448478
8        clear hline.
9      *- Text zm Status aus T16LA -------------------------------------------*
10       clear t16la.
11       if ban-updk1 ne space.
12         if ban-updk1 ne zner.
13           select single * from t16la where spras eq sy-langu
14                                        and updkz eq ban-updk1.
15         else.
16           select single * from t16la where spras eq sy-langu
17                                        and updkz eq znew.
18         endif.
19       endif.
20
21       if ban-updk1 eq znew or
22          ban-updk1 eq zold or
23          ban-updk1 eq zner.
24     *- Rahmenvertrag ------------------------------------------------------*
25         if ban-konnr ne space.
26     *     MOVE  text-052  TO hline(77).
27     *     MOVE  ban-konnr TO hline+19(10).
28     *     MOVE  ban-ktpnr TO hline+30(5).
29           concatenate space text-052 into hline(77).
30           concatenate space ban-konnr into hline(29) separated by hline(19).
31           concatenate space ban-ktpnr into hline(35) separated by hline(30).
32           if ban-flief ne space.
33     *        MOVE text-058 TO hline+36(10).
34     *        MOVE ban-flief TO hline+46(10).
35            concatenate space text-058 into hline(46) separated by hline(36).
36           concatenate space ban-flief into hline(56) separated by hline(46).
37           else.
38             if ban-reswk ne space.
39     *          MOVE text-062 TO hline+36(10).
40     *          MOVE ban-reswk TO hline+47(04).
41            concatenate space text-062 into hline(46) separated by hline(36).
42           concatenate space ban-reswk into hline(51) separated by hline(47).
43             endif.
44           endif.
45           if ban-ekorg ne space.
46     *        MOVE text-061 TO hline+57(12).
47     *        MOVE ban-ekorg TO hline+69(4).
48            concatenate space text-061 into hline(69) separated by hline(57).
49           concatenate space ban-ekorg into hline(73) separated by hline(69).
50           endif.
51     *- Infosatz -----------------------------------------------------------*
52         elseif ban-infnr ne space.
53     *      MOVE  text-051  TO hline(77).
54     *      MOVE  ban-infnr TO hline+19(10).
55     *      MOVE  text-058  TO hline+30(10).
56     *      MOVE  ban-flief TO hline+40(10).
57     *      MOVE  text-061  TO hline+51(12).
58     *      MOVE  ban-ekorg TO hline+63(4).
59           concatenate space text-051 into hline(77).
60           concatenate space ban-infnr into hline(29) separated by hline(19).
61           concatenate space text-058 into hline(40) separated by hline(30).
62           concatenate space ban-flief into hline(50) separated by hline(40).
63           concatenate space text-061 into hline(63) separated by hline(51).
64           concatenate space ban-ekorg into hline(67) separated by hline(63).
65
66     *- Rahmenbestellung ---------------------------------------------------*
67         elseif ban-fordn ne space.
68     *      MOVE  text-070  TO hline(77).
69     *      MOVE  ban-fordn TO hline+19(10).
70     *      MOVE  ban-fordp TO hline+30(5).
71           concatenate space text-070 into hline(77).
72           concatenate space ban-fordn into hline(29) separated by hline(19).
73           concatenate space ban-fordp into hline(35) separated by hline(30).
74
75           if ban-flief ne space.
76     *        MOVE text-058 TO hline+36(10).
77     *        MOVE ban-flief TO hline+46(10).
78            concatenate space text-058 into hline(46) separated by hline(36).
79           concatenate space ban-flief into hline(56) separated by hline(46).
80           endif.
81           if ban-ekorg ne space.
82     *        MOVE text-061 TO hline+57(12).
83     *        MOVE ban-ekorg TO hline+69(4).
84            concatenate space text-061 into hline(69) separated by hline(57).
85           concatenate space ban-ekorg into hline(73) separated by hline(69).
86           endif.
87     *- Fester Lieferant ---------------------------------------------------*
88         elseif ban-flief ne space.
89           clear lfa1-name1.
90     * ALRK021852 begin insert
91           call function 'WY_LFA1_GET_NAME'
92                exporting
93                     pi_lifnr         = ban-flief
94                importing
95                     po_name1         = lfa1-name1
96                exceptions
97                     no_records_found = 1
98                     others           = 2.
99     *ALRK021852 end insert - begin delete
100    *     call function 'ME_GET_SUPPLIER'
101    *       exporting
102    *         supplier   = ban-flief
103    *       importing
104    *         name       = lfa1-name1
105    *       exceptions
106    *         error_message = 01.
107    *ALRK021852 end delete
108    *       MOVE  text-050  TO hline(77).  "448478
109    *      MOVE  ban-flief TO hline+19(10). "448478
110    *      MOVE  lfa1-name1  TO hline+30(30). "448478
111          concatenate space text-050 into hline(77).
112          concatenate space ban-flief into hline(29) separated by hline(19).
113         concatenate space lfa1-name1 into hline(60) separated by hline(30).
114
115          if ban-ekorg ne space.
116    *        MOVE TEXT-061   TO HLINE+51(12).                   "448478
117    *        MOVE ban-ekorg TO hline+63(4).                     "448478
118           concatenate space text-061 into hline(63) separated by hline(51).
119          concatenate space ban-ekorg into hline(67) separated by hline(63).
120          endif.
121    *- Lieferwerk ---------------------------------------------------------*
122        else.
123          if ban-reswk ne space.                                "82362
124    *        MOVE  text-053 TO hline(77).
125    *        MOVE  ban-reswk TO hline+19(4).
126            concatenate space text-053 into hline(77).
127          concatenate space ban-reswk into hline(23) separated by hline(19).
128          endif.                                                "82362
129          if ban-ekorg ne space.
130    *        MOVE text-061   TO hline+51(12).
131    *        MOVE ban-ekorg TO hline+63(4).
132           concatenate space text-061 into hline(63) separated by hline(51).
133          concatenate space ban-ekorg into hline(67) separated by hline(63).
134          endif.
135        endif.
136        if baz_flag ne space.
137    *      MOVE text-063 TO hline+74(3).
138          concatenate space text-063 into hline(77) separated by hline(74).
139        endif.
140    *- Anfragezuordnung ---------------------------------------------------*
141      elseif ban-updk1 eq anfr.
142    *    MOVE  text-103 TO hline(77).
143        concatenate space text-103 into hline(77).
144    *- Anfragezuordnung mit Lieferant -------------------------------------*
145      elseif ban-updk1 eq alif.
146    *    MOVE  text-105 TO hline(77).
147    *    MOVE ban-slief TO hline+48(10).
148        concatenate space text-105 into hline(77).
149        concatenate space ban-slief into hline(58) separated by hline(48).
150
151    *- Anfragezuordnung mehrere Lieferanten -------------------------------*
152      elseif ban-updk1 eq aman.
153    *    MOVE  text-107 TO hline(77).
154        concatenate space text-107 into hline(77).
155
156    *- Zuordnung zurückgesetzt --------------------------------------------*
157      elseif ban-updk1 eq zres.
158    *    MOVE  text-115 TO hline(77).
159        concatenate space text-115 into hline(77).
160
161    *- allgemeine Änderung ------------------------------------------------*
162      elseif ban-updk1 eq aend.
163    *    MOVE  text-123 TO hline(77).
164        concatenate space text-123 into hline(77).
165      endif.
166
167    *- Freigabe -----------------------------------------------------------*
168      clear fline.
169    *- Text zm Status aus T16LA -------------------------------------------*
170      clear *t16la.
171      if ban-updk3 ne space.
172        select single * from t16la into *t16la
173                                   where spras eq sy-langu
174                                     and updkz eq ban-updk3.
175      endif.
176    *- Freigabe -----------------------------------------------------------*
177      if ban-frgst ne space.
178        if ban-frggr ne space.
179    *      fline(2) = ban-frggr.
180    *      fline+2(1) = '/'.
181    *      fline+3(2) = ban-frgst.
182          concatenate space ban-frggr into fline(2).
183          concatenate space '/' into fline(3) separated by fline(2).
184          concatenate space ban-frgst into fline(5) separated by fline(3).
185          if t16ft-frggr ne ban-frggr or
186             t16ft-frgsx ne ban-frgst.
187            select single * from t16ft where spras eq sy-langu
188                                         and frggr eq ban-frggr
189                                         and frgsx eq ban-frgst.
190          endif.
191    *      fline+6(20) = t16ft-frgxt.
192         concatenate space t16ft-frgxt into fline(26) separated by fline(6).
193        else.
194    *      fline(2) = ban-frgst.
195          concatenate space ban-frgst into fline(2).
196        endif.
197
198    *    fline+27(1) = ban-frgkz.
199        concatenate space ban-frgkz into fline(28) separated by fline(27).
200        if t161u-frgkz ne ban-frgkz.
201          select single * from t161u where spras eq sy-langu
202                                       and frgkz eq ban-frgkz.
203        endif.
204    *    fline+29(20) = t161u-fkztx.
205        concatenate space t161u-fkztx into fline(49) separated by fline(29).
206        if ban-updk3 eq fres.
207    *      MOVE  text-104 TO fline+50(27).
208          concatenate space text-104 into fline(77) separated by fline(50).
209          write icon_green_light to icon_field.
210    *- Einzelfreigabe -----------------------------------------------------*
211        elseif ban-updk3 eq free.
212    *      MOVE  text-106 TO fline+50(27).
213          concatenate space text-106 into fline(77) separated by fline(50).
214          write icon_green_light to icon_field.
215    *- Einzelfreigabe - nur Änderung ---------------
216        elseif ban-updk3 eq scha.
217    *      MOVE  text-117 TO fline+50(27).
218          concatenate space text-117 into fline(77) separated by fline(50).
219    *- Einzelfreigabe - Freigabe zurückgenommen ----
220        elseif ban-updk3 eq nfre.
221    *      MOVE  text-109 TO fline+50(27).
222          concatenate space text-109 into fline(77) separated by fline(50).
223        else.
224    *----Start---------Addded by Nitin Nemawarkar (SISL) 23/05/2003
225    *      IF sy-tcode EQ 'ME55' OR sy-tcode EQ 'ME5F'.
226          if sy-tcode eq 'ME55' or sy-tcode eq 'ME5F'
227                                or sy-tcode eq 'ZMMME55'.
228    *----End---------Addded by Nitin Nemawarkar (SISL) 23/05/2003INCLUDE
229            if ban-selkf eq 0.
230              if not ban-gsfrg is initial and
231                     ban-az_pos ne ban-sl_pos.
232    *... Banf ist nur über die Einzelfreigabe bearbeitbar, da nicht alle .*
233    *... Positionen selektiert wurden ....................................*
234    *            MOVE  text-110 TO fline+50(27).
235           concatenate space text-110 into fline(77) separated by fline(50).
236                write icon_red_light to icon_field.
237              else.
238                write icon_red_light to icon_field.
239    *            MOVE  text-108 TO fline+50(27).
240           concatenate space text-108 into fline(77) separated by fline(50).
241              endif.
242            else.
243    *          MOVE  text-109 TO fline+50(27).
244           concatenate space text-109 into fline(77) separated by fline(50).
245              write icon_yellow_light to icon_field.
246            endif.
247          endif.
248        endif.
249      endif.
250
251    endform.
*--- End of ZMM_FM06BF01_BAN_ZUORD - 251 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF01_SUBMIT                           Level 2    Page 30
Object           SAPMZFM06B                                Lines 85
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *        Listausgabereport aufrufen                                    *
4      *----------------------------------------------------------------------*
5      FORM submit USING hucomm.
6
7      * generic reporting: call framework
8        IF NOT gf_factory IS INITIAL.
9
10         IF com-gpfkey EQ 'ZUOR' OR com-gpfkey EQ 'BEAR' OR com-gpfkey EQ 'GBST'.
11
12           TYPE-POOLS: mmpur.
13           DATA: ls_initiator TYPE mepo_initiator.
14           CASE com-gpfkey.
15             WHEN 'ZUOR'. ls_initiator-initiator = mmpur_me56.
16             WHEN 'BEAR'. ls_initiator-initiator = mmpur_me57.
17             WHEN 'GBST'. ls_initiator-initiator = mmpur_me58.
18           ENDCASE.
19
20           CLEAR: ban[].
21
22           CALL FUNCTION 'MEGUI_ASSIGN_AND_PROCESS_REQS'
23             EXPORTING
24               im_table_manager = gf_factory
25               im_initiator     = ls_initiator.
26
27         ELSE.
28
29           DATA: lt_options TYPE mepo_initiator_options,
30                 ls_option  LIKE LINE OF lt_options.
31
32           IF com-gpfkey EQ 'FREI' OR com-gpfkey EQ 'FRER'.
33
34             IF com-gpfkey EQ 'FREI'.
35               ls_option-property = 'FRGAB'.
36               ls_option-value = com-frgab.
37               APPEND ls_option TO lt_options.
38             ENDIF.
39           ENDIF.
40
41           CLEAR: ban[].
42
43           CALL FUNCTION 'ME_REP_START_VIA_TABLE_MANAGER'
44             EXPORTING
45               im_table_manager = gf_factory
46               im_options       = lt_options.
47
48         ENDIF.
49         EXIT.
50       ENDIF.
51
52       DATA: params LIKE pri_params.
53       DATA: arcparams LIKE arc_params.                          "HW 202820
54
55       EXPORT ban com TO MEMORY ID 'ZYX'.
56       IF sy-binpt EQ space.                                   "<--- h91102
57         IF hucomm EQ 'PRIN' OR sy-batch NE space.
58
59           CALL FUNCTION 'GET_PRINT_PARAMETERS'
60             EXPORTING
61               mode                   = 'CURRENT'
62               no_dialog              = 'X'
63             IMPORTING
64               out_archive_parameters = arcparams                "HW 202820
65               out_parameters         = params
66             EXCEPTIONS
67               archive_info_not_found = 1
68               invalid_print_params   = 2
69               invalid_archive_params = 3
70               OTHERS                 = 4.
71
72           SUBMIT rm06bl00 TO SAP-SPOOL WITHOUT SPOOL DYNPRO
73                         ARCHIVE PARAMETERS arcparams            "HW 202820
74                         SPOOL PARAMETERS params AND RETURN.
75         ELSE. " hucomm NE 'PRIN' AND sy-batch EQ space
76     * it's not printing and not background
77           IF hucomm <> 'EXT_CALL'.
78             SUBMIT rm06bl00 AND RETURN.
79           ENDIF.
80         ENDIF.
81       ELSE. " sy-binpt NE space                               "<--- insert
82     * it's batch input
83         SUBMIT rm06bl00 AND RETURN.                           "<--- insert
84       ENDIF.                                                  "<--- insert
85     ENDFORM.                    "SUBMIT
*--- End of FM06BF01_SUBMIT - 85 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF01_START                            Level 2    Page 31
Object           SAPMZFM06B                                Lines 76
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *        Listausgabe starten                                           *
4      *----------------------------------------------------------------------*
5      FORM start.
6
7      *- Daten aus Selektionsreport holen -----------------------------------*
8        IMPORT gs_banf FROM MEMORY ID 'GSFRG'.
9        IMPORT cueb FROM MEMORY ID 'XYZ'.
10       IMPORT ban com FROM MEMORY ID 'ZYX'.
11       gpfkey = com-gpfkey.
12       gfmkey = com-gfmkey.
13       zpfkey = com-zpfkey.
14       zfmkey = com-zfmkey.
15
16     *- Message-Steuerung initialisieren -----------------------------------*
17       PERFORM init_enaco(sapfmmex).
18
19     *- Funktionsberechtigungen initialisieren -----------------------------*
20       PERFORM init_efube.
21
22     *- Listumfang ermitteln -----------------------------------------------*
23       PERFORM xt16ll_aufbauen.
24
25     *- Zusätzliche Daten lesen---------------------------------------------*
26       PERFORM ban_daten_pre.
27
28     *- Gelesenen Stand der Banfs sichern ----------------------------------*
29       IF gpfkey EQ 'BEAR' OR
30          gpfkey EQ 'ZUOR'.
31         PERFORM oba_aufbauen.
32       ENDIF.
33
34     *- Liste beginnt mit Zuordnungsliste ----------------------------------*
35       CLEAR t16lh.
36       SELECT SINGLE * FROM t16lh WHERE tcode EQ sy-tcode.
37
38       IF t16lh-xzuor NE space.
39     *... Neue Konsiabwicklung zu 4.0 .....................................*
40         IF tcurm IS INITIAL.
41           SELECT SINGLE * FROM tcurm.
42         ENDIF.
43         IF NOT tcurm-konsi IS INITIAL.
44     *... Konsiabwicklung über Infosatz ...................................*
45           SET PF-STATUS zpfkey EXCLUDING 'LKON'.
46         ELSE.
47           SET PF-STATUS zpfkey.
48         ENDIF.
49         SET TITLEBAR  zfmkey.
50         liste = 'Z'.
51         PERFORM zug_zeilen.
52     *- Liste beginnt mit Grundliste ---------------------------------------*
53       ELSE.
54     *... Neue Konsiabwicklung zu 4.0 .....................................*
55         IF tcurm IS INITIAL.
56           SELECT SINGLE * FROM tcurm.
57         ENDIF.
58         IF NOT tcurm-konsi IS INITIAL.
59     *... Konsiabwicklung über Infosatz ...................................*
60           excl-funktion = 'LKON'.
61           COLLECT excl.
62         ENDIF.
63         SET PF-STATUS gpfkey EXCLUDING excl.
64         SET TITLEBAR  gfmkey.
65         liste = 'G'.
66         PERFORM ban_sort.
67     *- Grundliste als Liste -----------------------------------------------*
68         IF t16lb-dynpr EQ 0.
69           PERFORM ban_zeilen.
70     *- Grundliste als SSTEP-Loop ------------------------------------------*
71         ELSE.
72           PERFORM ban_dynp_call.
73         ENDIF.
74       ENDIF.
75
76     ENDFORM.
*--- End of FM06BF01_START - 76 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF02                                  Level 1    Page 32
Object           SAPMZFM06B                                Lines 84
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      * Include-lokale Variablen
2      * Wird gesetzt in: selkz_input
3      *  und benutzt in: ucomm_zuru
4      DATA: LI_STARO LIKE SY-STARO.
5
6        INCLUDE FM06BF02_UCOMM_AAKT .  " UCOMM_AAKT
7
8        INCLUDE FM06BF02_UCOMM_AEND .  " UCOMM_AEND
9
10       INCLUDE FM06BF02_UCOMM_ANFL .  " UCOMM_ANFL
11
12       INCLUDE FM06BF02_UCOMM_ANFR .  " UCOMM_ANFR
13
14       INCLUDE FM06BF02_UCOMM_AUSW .  " UCOMM_AUSW
15
16       INCLUDE FM06BF02_UCOMM_BEST .  " UCOMM_BEST
17
18       INCLUDE FM06BF02_UCOMM_BUFR .  " UCOMM_BUFR
19
20       INCLUDE FM06BF02_UCOMM_DETA .  " UCOMM_DETA
21
22       INCLUDE FM06BF02_UCOMM_ENDE .  " UCOMM_ENDE
23
24       INCLUDE FM06BF02_UCOMM_FRST .  " UCOMM_FRST
25
26       INCLUDE FM06BF02_UCOMM_HICK .  " UCOMM_HICK
27
28       INCLUDE FM06BF02_UCOMM_KICK .  " UCOMM_KICK
29
30       INCLUDE FM06BF02_UCOMM_MAKT .  " UCOMM_MAKT
31
32       INCLUDE FM06BF02_UCOMM_MALL .  " UCOMM_MALL
33
34       INCLUDE FM06BF02_UCOMM_MARK .  " UCOMM_MARK
35
36       INCLUDE FM06BF02_UCOMM_MDEL .  " UCOMM_MDEL
37
38       INCLUDE FM06BF02_UCOMM_MINT .  " UCOMM_MINT
39
40       INCLUDE FM06BF02_UCOMM_MATN .  " UCOMM_MATN
41
42       INCLUDE FM06BF02_UCOMM_MMBE .  " UCOMM_MMBE
43
44       INCLUDE FM06BF02_UCOMM_MD04 .  " UCOMM_MD04
45
46       INCLUDE FM06BF02_UCOMM_ME54 .  " UCOMM_ME54
47
48       INCLUDE FM06BF02_UCOMM_LINF .  " UCOMM_LINF
49
50       INCLUDE FM06BF02_UCOMM_LIBE .  " UCOMM_LIBE
51
52       INCLUDE FM06BF02_UCOMM_LKON .  " UCOMM_LKON
53
54       INCLUDE FM06BF02_UCOMM_LRAC .  " UCOMM_LRAC
55
56       INCLUDE FM06BF02_UCOMM_LRAM .  " UCOMM_LRAM
57       INCLUDE FM06BF02_UCOMM_LUAE .  " UCOMM_LUAE
58
59       INCLUDE FM06BF02_UCOMM_ORDB .  " UCOMM_ORDB
60
61       INCLUDE FM06BF02_UCOMM_ORDM .  " UCOMM_ORDM
62
63       INCLUDE FM06BF02_UCOMM_SORT .  " UCOMM_SORT
64
65       INCLUDE FM06BF02_UCOMM_ZANZ .  " UCOMM_ZANZ
66
67       INCLUDE FM06BF02_UCOMM_ZBEA .  " UCOMM_ZBEA
68
69       INCLUDE FM06BF02_UCOMM_ZBUP .  " UCOMM_ZBUP
70
71       INCLUDE FM06BF02_UCOMM_ZLIS .  " UCOMM_ZLIS
72
73       INCLUDE FM06BF02_UCOMM_GLIS .  " UCOMM_GLIS
74       INCLUDE FM06BF02_UCOMM_GBUP .  " UCOMM_GBUP
75
76       INCLUDE FM06BF02_UCOMM_ZRES .  " UCOMM_ZRES
77
78       INCLUDE FM06BF02_UCOMM_ZURU .  " UCOMM_ZURU
79
80       INCLUDE FM06BF02_LISTE_MERKEN .  " LISTE_MERKEN
81
82       INCLUDE FM06BF02_SELKZ_INPUT .  " SELKZ_INPUT
83
84       INCLUDE FM06BF02_USER_COMMAND .  " USER_COMMAND
*--- End of FM06BF02 - 84 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF02_UCOMM_AAKT                       Level 2    Page 33
Object           SAPMZFM06B                                Lines 39
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      ************************************************************************
2      *        Usercommands                                                  *
3      ************************************************************************
4      *eject
5      *----------------------------------------------------------------------*
6      *        Arbeitsvorrat aktualisieren                                   *
7      *----------------------------------------------------------------------*
8      FORM ucomm_aakt.
9
10       IF liste EQ 'G'.
11         CHECK det EQ space.
12       ENDIF.
13       LOOP AT ban WHERE updk3 NE space.
14         IF ban-updk3 EQ bube.
15           CHECK ban-bsmng GE ban-menge OR
16                 ban-ebakz NE space.
17         ENDIF.
18     * Don't delete the PReq if the assignment is canceled and
19     * the document is not yet updated.
20         IF ban-updk1 EQ zres.                                   "359179
21           CHECK ban-updk3 EQ buba.
22         ENDIF.
23         DELETE ban.
24       ENDLOOP.
25
26       sy-lsind = 0.
27       IF liste EQ 'G'.
28         PERFORM ban_sort.
29         IF t16lb-dynpr EQ 0.
30           PERFORM ban_zeilen.
31         ELSE.
32           CLEAR: b-aktind, b-lopind, b-maxind, b-pagind, b-lesind.
33           DESCRIBE TABLE ban LINES b-maxind.
34         ENDIF.
35       ELSE.
36         PERFORM zug_zeilen.
37       ENDIF.
38
39     ENDFORM.                    "ucomm_aakt
*--- End of FM06BF02_UCOMM_AAKT - 39 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF02_UCOMM_AEND                       Level 2    Page 34
Object           SAPMZFM06B                                Lines 63
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *        Anzeigen Änderungen                                           *
4      *----------------------------------------------------------------------*
5      FORM UCOMM_AEND.
6
7        CHECK LISTE EQ 'G'.
8        LEERFLG = 'X'.
9
10     *- Suchen einer markierten Position -----------------------------------*
11       LOOP AT BAN WHERE SELKZ EQ 'X'.
12         CLEAR LEERFLG.
13         IF BAN-AENDA EQ SPACE.
14           MESSAGE S242.
15           EXIT.
16         ENDIF.
17         IF NOT BAN-GSFRG IS INITIAL AND NOT GS_BANF IS INITIAL.
18           LOOP AT BAN WHERE BANFN EQ BAN-BANFN.
19             BAN-SELKZ = '*'.
20             MODIFY BAN.
21           ENDLOOP.
22         ELSE.
23           BAN-SELKZ = '*'.
24           MODIFY BAN.
25         ENDIF.
26     *- Änderungen anzeigen ------------------------------------------------*
27         PERFORM AUFRUF_AENDERUNGEN.
28     *- Selektionskennzeichen modifizieren ---------------------------------*
29         PERFORM SEL_KENNZEICHNEN.
30     *- für eine Position ausgeführt - Schleife verlassen ------------------*
31         EXIT.
32       ENDLOOP.
33
34     *- Keine markierte Zeile gefunden -------------------------------------*
35       IF LEERFLG NE SPACE.
36     *- Prüfen auf Line-Selection ------------------------------------------*
37         IF HIDE-INDEX NE 0.
38           READ TABLE BAN INDEX HIDE-INDEX.
39           IF BAN-AENDA EQ SPACE.
40             MESSAGE S242.
41             EXIT.
42           ENDIF.
43     *- Änderungen anzeigen ------------------------------------------------*
44           PERFORM AUFRUF_AENDERUNGEN.
45           IF NOT BAN-GSFRG IS INITIAL AND NOT GS_BANF IS INITIAL.
46             LOOP AT BAN WHERE BANFN EQ BAN-BANFN.
47               BAN-SELKZ = '*'.
48               MODIFY BAN.
49             ENDLOOP.
50           ELSE.
51             BAN-SELKZ = '*'.
52             MODIFY BAN INDEX HIDE-INDEX.
53           ENDIF.
54     *- falls auch zusätzlich angekreuzt - Stern setzen --------------------*
55           PERFORM SEL_KENNZEICHNEN.
56         ELSE.
57     *- Funktion konnte für keine Zeile ausgeführt werden - vorher markieren*
58           MESSAGE S222.
59           EXIT.
60         ENDIF.
61       ENDIF.
62
63     ENDFORM.
*--- End of FM06BF02_UCOMM_AEND - 63 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF02_UCOMM_ANFL                       Level 2    Page 35
Object           SAPMZFM06B                                Lines 49
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *     Anfragezuordnung zu mehreren Lieferanten
4      *----------------------------------------------------------------------*
5      FORM UCOMM_ANFL.
6
7        CHECK SY-PFKEY EQ 'BEAR' OR
8              SY-PFKEY EQ 'DBEA'.
9        LEERFLG = 'X'.
10       CLEAR INDEX_BAN.
11
12     *- Suchen einer markierten Position -----------------------------------*
13       LOOP AT BAN WHERE SELKZ EQ 'X'.
14         PERFORM WARNING_UPDK3.
15         CLEAR LEERFLG.
16         BAN-SELKZ = '*'.
17         MODIFY BAN.
18         INDEX_BAN = SY-TABIX.
19     *- POP-UP für Lieferanteneingabe senden -------------------------------*
20         PERFORM ALF_INIT.
21         CALL SCREEN 103 STARTING AT 5 6
22                         ENDING   AT 60 14.
23     *- Zeile Zugeordnet ... aufbauen --------------------------------------*
24         PERFORM BAN_UPDATE_ANFL.
25     *- für eine Position ausgeführt - Schleife verlassen ------------------*
26         EXIT.
27       ENDLOOP.
28
29     *- Keine markierte Zeile gefunden -------------------------------------*
30       IF LEERFLG NE SPACE.
31     *- Prüfen auf Line-Selection ------------------------------------------*
32         IF HIDE-INDEX NE 0.
33           READ TABLE BAN INDEX HIDE-INDEX.
34           PERFORM WARNING_UPDK3.
35           INDEX_BAN = SY-TABIX.
36     *- POP-UP für Lieferanteneingabe senden -------------------------------*
37           PERFORM ALF_INIT.
38           CALL SCREEN 103 STARTING AT 5 6
39                           ENDING   AT 60 14.
40     *- Zeile Zugeordnet ... aufbauen --------------------------------------*
41           PERFORM BAN_UPDATE_ANFL.
42         ELSE.
43     *- Funktion konnte für keine Zeile ausgeführt werden - vorher markieren*
44           MESSAGE S222.
45           EXIT.
46         ENDIF.
47       ENDIF.
48
49     ENDFORM.
*--- End of FM06BF02_UCOMM_ANFL - 49 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF02_UCOMM_ANFR                       Level 2    Page 36
Object           SAPMZFM06B                                Lines 95
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *     Anfragezuordnung
4      *----------------------------------------------------------------------*
5      FORM UCOMM_ANFR.
6
7        CHECK SY-PFKEY EQ 'BEAR' OR
8              SY-PFKEY EQ 'DBEA'.
9        LEERFLG = 'X'.
10       CLEAR INDEX_BAN.
11       CLEAR REJECT.                                             "49610
12
13     *- Suchen einer markierten Position -----------------------------------*
14       LOOP AT BAN WHERE SELKZ EQ 'X'.
15         PERFORM DET_CHECK.
16         CHECK SY-SUBRC EQ 0.
17         PERFORM WARNING_UPDK3.
18         CLEAR LEERFLG.
19     *- Wunschlieferant/fester Lieferant vorhanden - Flag setzen -----------*
20         IF BAN-FLIEF NE SPACE OR
21            BAN-LIFNR NE SPACE.
22           LEERFLG = 'Y'.
23           EXIT.
24         ENDIF.
25       ENDLOOP.
26
27       CASE LEERFLG.
28     *- mind. 1 Banf hat festen Lieferanten oder Wunschlieferanten - POP-UP *
29         WHEN 'Y'.
30           CLEAR: REJECT, ANSWER.
31           CALL SCREEN 102 STARTING AT 10 6
32                           ENDING   AT 51 16.
33     *- Keine markierte Zeile gefunden -------------------------------------*
34         WHEN 'X'.
35     *- Prüfen auf Line-Selection ------------------------------------------*
36           IF HIDE-INDEX NE 0.
37             READ TABLE BAN INDEX HIDE-INDEX.
38             PERFORM WARNING_UPDK3.
39             INDEX_BAN = SY-TABIX.
40     *- Wunschlieferant in Bestellanforderung vorhanden - f.Zuordn. vorschlg*
41             IF BAN-FLIEF NE SPACE OR
42                BAN-LIFNR NE SPACE.
43               CLEAR: REJECT, ANSWER.
44               CALL SCREEN 102 STARTING AT 10 6
45                               ENDING   AT 51 16.
46               IF REJECT NE SPACE.
47                 EXIT.
48               ENDIF.
49               CASE ANSWER.
50     *- mit Lieferanten vormerken für Anfragebearbeitung -------------------*
51                 WHEN 'Y'.
52                   PERFORM BAN_UPDATE_ALIF.
53     *- ohne Lieferanten vormerken für Anfragebearbeitung ------------------*
54                 WHEN 'N'.
55                   PERFORM BAN_UPDATE_ANFR.
56               ENDCASE.
57     *- Kein Wunschlieferant in Bestellanforderung - Vormerken f. Anfrage --*
58             ELSE.
59               PERFORM BAN_UPDATE_ANFR.
60             ENDIF.
61             EXIT.
62           ELSE.
63     *- Funktion konnte für keine Zeile ausgeführt werden - vorher markieren*
64             MESSAGE S222.
65             EXIT.
66           ENDIF.
67       ENDCASE.
68
69     *- Markierte Banfs vormerken für Anfrage (mit oder ohne Lieferant) ----*
70       LOOP AT BAN WHERE SELKZ = 'X'.
71         PERFORM DET_CHECK.
72         CHECK SY-SUBRC EQ 0.
73         INDEX_BAN = SY-TABIX.
74     *- Window wurde abgebrochen - nicht vormerken, nächste Banf -----------*
75         IF REJECT NE SPACE.
76           CHECK REJECT EQ SPACE.
77         ENDIF.
78         IF BAN-FLIEF NE SPACE OR
79            BAN-LIFNR NE SPACE.
80     *- Banf enthält Lieferanten -------------------------------------------*
81           CASE ANSWER.
82     *- mit Lieferanten vormerken für Anfragebearbeitung -------------------*
83             WHEN 'Y'.
84               PERFORM BAN_UPDATE_ALIF.
85     *- ohne Lieferanten vormerken für Anfragebearbeitung ------------------*
86             WHEN 'N'.
87               PERFORM BAN_UPDATE_ANFR.
88           ENDCASE.
89     *- Banf enthält keinen Lieferanten ------------------------------------*
90         ELSE.
91           PERFORM BAN_UPDATE_ANFR.
92         ENDIF.
93       ENDLOOP.
94
95     ENDFORM.
*--- End of FM06BF02_UCOMM_ANFR - 95 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF02_UCOMM_AUSW                       Level 2    Page 37
Object           SAPMZFM06B                                Lines 30
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *  Auswählen Bestellanforderung                                       *
4      *----------------------------------------------------------------------*
5      FORM UCOMM_AUSW.
6
7        CHECK SY-PFKEY EQ 'LISA'.
8        LEERFLG = 'X'.
9
10     *- Suchen einer markierten Position -----------------------------------*
11       LOOP AT BAN WHERE SELKZ EQ 'X'.
12         CLEAR LEERFLG.
13         PERFORM CUEB_FUELLEN.
14       ENDLOOP.
15
16       IF LEERFLG NE SPACE.
17     *- Keine markierte Zeile gefunden - Prüfen auf Line-Selection ---------*
18         IF HIDE-INDEX NE 0.
19           PERFORM VALID_LINE.
20           CHECK EXITFLAG EQ SPACE.
21           READ TABLE BAN INDEX HIDE-INDEX.
22           PERFORM CUEB_FUELLEN.
23         ELSE.
24     *- Funktion konnte für keine Zeile ausgeführt werden - vorher markieren*
25           MESSAGE S222.
26           EXIT.
27         ENDIF.
28       ENDIF.
29
30     ENDFORM.
*--- End of FM06BF02_UCOMM_AUSW - 30 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF02_UCOMM_BEST                       Level 2    Page 38
Object           SAPMZFM06B                                Lines 58
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *     Anzeigen Bestellungen zur Banf
4      *----------------------------------------------------------------------*
5      FORM UCOMM_BEST.
6
7        CHECK LISTE EQ 'G'.
8        LEERFLG = 'X'.
9
10     *- Suchen einer markierten Position -----------------------------------*
11       LOOP AT BAN WHERE SELKZ EQ 'X'.
12         CLEAR LEERFLG.
13         IF NOT BAN-GSFRG IS INITIAL AND NOT GS_BANF IS INITIAL.
14           LOOP AT BAN WHERE BANFN EQ BAN-BANFN.
15             BAN-SELKZ = '*'.
16             MODIFY BAN.
17           ENDLOOP.
18         ELSE.
19           BAN-SELKZ = '*'.
20           MODIFY BAN.
21         ENDIF.
22     *- Bestellungen anzeigen ----------------------------------------------*
23         PERFORM AUFRUF_BESTELLUNGEN.
24         IF EXITFLAG NE SPACE.
25           EXIT.
26         ENDIF.
27     *- Selektionskennzeichen modifizieren ---------------------------------*
28         PERFORM SEL_KENNZEICHNEN.
29     *- für eine Position ausgeführt - Schleife verlassen ------------------*
30         EXIT.
31       ENDLOOP.
32
33       IF LEERFLG NE SPACE.
34     *- Line-Selektion -----------------------------------------------------*
35         IF HIDE-INDEX NE 0.
36           READ TABLE BAN INDEX HIDE-INDEX.
37     *- Bestellungen anzeigen ----------------------------------------------*
38           PERFORM AUFRUF_BESTELLUNGEN.
39           CHECK EXITFLAG EQ SPACE.
40           IF NOT BAN-GSFRG IS INITIAL AND NOT GS_BANF IS INITIAL.
41             LOOP AT BAN WHERE BANFN EQ BAN-BANFN.
42               BAN-SELKZ = '*'.
43               MODIFY BAN.
44             ENDLOOP.
45           ELSE.
46             BAN-SELKZ = '*'.
47             MODIFY BAN INDEX HIDE-INDEX.
48           ENDIF.
49     *- falls auch zusätzlich angekreuzt - Stern setzen --------------------*
50           PERFORM SEL_KENNZEICHNEN.
51         ELSE.
52     *- Funktion konnte für keine Zeile ausgeführt werden - vorher markieren*
53           MESSAGE S222.
54           EXIT.
55         ENDIF.
56       ENDIF.
57
58     ENDFORM.
*--- End of FM06BF02_UCOMM_BEST - 58 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF02_UCOMM_BUFR                       Level 2    Page 39
Object           SAPMZFM06B                                Lines 116
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *        Buchen Freigabe                                               *
4      *----------------------------------------------------------------------*
5      FORM UCOMM_BUFR.
6
7        CHECK SY-PFKEY EQ 'FREI'.
8        LEERFLG = 'X'.
9        CLEAR INDEX_BAN.
10       CLEAR ZFREI.
11       REFRESH BAT.
12
13     *- Suchen einer markierten Position -----------------------------------*
14       LOOP AT BAN WHERE SELKZ EQ 'X'.
15     *- Keine Freigabe möglich ---------------------------------------------*
16     *... weil schon freigegeben bzw. nicht freigebbar ....................*
17     *... oder bei Gesamtfreigabe aus ME55, falls nicht alle Positionen ...*
18     *... für die Liste selektiert wurden in diesem Fall ist selkf initial *
19         IF BAN-SELKF EQ 0 AND NOT BAN-UPDK3 IS INITIAL.
20           ZFREI = ZFREI + 1.
21           IF NOT BAN-GSFRG IS INITIAL AND NOT GS_BANF IS INITIAL.
22             LOOP AT BAN WHERE BANFN EQ BAN-BANFN.
23               BAN-SELKZ = '*'.
24               MODIFY BAN.
25             ENDLOOP.
26           ELSE.
27             BAN-SELKZ = '*'.
28             MODIFY BAN.
29           ENDIF.
30           PERFORM SEL_KENNZEICHNEN.
31         ELSE.
32           CLEAR LEERFLG.
33           PERFORM FREIGABE_SETZEN.
34         ENDIF.
35       ENDLOOP.
36
37     *- Keine markierte Zeile gefunden - Prüfen auf Line-Selection ---------*
38       IF LEERFLG NE SPACE.
39     *- Alle Markierten sind schon freigebenen -----------------------------*
40         IF ZFREI NE 0.
41           MESSAGE S234.
42           EXIT.
43         ENDIF.
44         IF HIDE-INDEX NE 0.
45           READ TABLE BAN INDEX HIDE-INDEX.
46           IF BAN-SELKF EQ 0.
47             CASE BAN-UPDK3.
48     *- Banf ist schon freigegeben -----------------------------------------*
49               WHEN FRES.
50                 MESSAGE S232.
51                 CLEAR HIDE-INDEX.
52                 EXIT.
53     *- Banf ist per Einzelfreigabe bearbeitet worden ----------------------*
54               WHEN FREE.
55                 MESSAGE S276.
56                 CLEAR HIDE-INDEX.
57                 EXIT.
58     *- Bei dieser Banf fehlt die Freigabevoraussetzung --------------------*
59               WHEN OTHERS.
60                 MESSAGE S233.
61                 CLEAR HIDE-INDEX.
62                 EXIT.
63             ENDCASE.
64           ENDIF.
65           IF BAN-GSFRG IS INITIAL OR GS_BANF IS INITIAL.
66             BAN-SELKZ = 'X'.
67             MODIFY BAN INDEX HIDE-INDEX.
68             PERFORM FREIGABE_SETZEN.
69           ELSE.
70             LOOP AT BAN WHERE BANFN EQ BAN-BANFN.
71               BAN-SELKZ = 'X'.
72               MODIFY BAN.
73               PERFORM FREIGABE_SETZEN.
74             ENDLOOP.
75           ENDIF.
76         ELSE.
77     *- Funktion konnte für keine Zeile ausgeführt werden - vorher markieren*
78           MESSAGE S222.
79           EXIT.
80         ENDIF.
81       ENDIF.
82
83       READ TABLE BAT INDEX 1.
84       CHECK SY-SUBRC EQ 0.
85       SORT BAT BY BANFN BNFPO.
86       SORT OBA BY BANFN BNFPO.
87       CLEAR: ZSICH, ZENQU, ZAEND, ZBERE, ZNOUP.
88       PERFORM AENDERN_BANFS.
89
90     *- Tabelle BAN mit erfolgreichen updates fortschreiben ----------------*
91       LOOP AT BAN WHERE SELKZ EQ 'X'.
92         MOVE-CORRESPONDING BAN TO BANKEY.
93         READ TABLE BAT WITH KEY BANKEY BINARY SEARCH.
94         IF SY-SUBRC EQ 0.
95           BAN-SELKZ = '*'.
96           BAN-SELKF = 0.
97           BAN-UPDK3 = FRES.
98           BAN-FRGZU = BAT-FRGZU.
99           BAN-FRGKZ = BAT-FRGKZ.
100          MODIFY BAN.
101          PERFORM BAN_MODIF_ZEILE USING SPACE.
102        ELSE.
103    *     if ban-gsfrg is initial or gs_banf is initial.
104          BAN-SELKZ = '*'.
105          MODIFY BAN.
106    *     else.
107    *       loop at ban where banfn eq ban-banfn.
108    *         ban-selkz = '*'.
109    *         modify ban.
110    *       endloop.
111    *     endif.
112          PERFORM SEL_KENNZEICHNEN.
113        ENDIF.
114      ENDLOOP.
115
116    ENDFORM.
*--- End of FM06BF02_UCOMM_BUFR - 116 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF02_UCOMM_DETA                       Level 2    Page 40
Object           SAPMZFM06B                                Lines 87
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *     Banf-Detail-Bearbeitung
4      *----------------------------------------------------------------------*
5      FORM UCOMM_DETA.
6
7        CHECK LISTE EQ 'G'.
8        LEERFLG = 'X'.
9        REFRESH BDE.
10
11       LOOP AT BAN WHERE SELKZ EQ 'X'.
12         IF NOT BAN-GSFRG IS INITIAL AND NOT GS_BANF IS INITIAL.
13     *... Suchen einer markierten Position nur für Banfen mit Positions- ..*
14     *... freigabe möglich und sinnvoll, da bei Gesamtbanfen nur auf 'Kopf-*
15     *... ebene selektiert werden kann und da eine Detailanzeige keinen ...*
16     *... Sinn macht ......................................................*
17           MESSAGE S198.
18           EXIT.
19         ELSE.
20           CLEAR LEERFLG.
21           BDE-INDEX = SY-TABIX.
22           APPEND BDE.
23           BAN-SELKZ = '*'.
24           MODIFY BAN.
25     *- Selektionskennzeichen modifizieren ---------------------------------*
26           PERFORM SEL_KENNZEICHNEN.
27         ENDIF.
28       ENDLOOP.
29
30       IF LEERFLG NE SPACE.
31     *- Line-Selektion -----------------------------------------------------*
32         IF HIDE-INDEX NE 0 AND HIDE-GSFRG IS INITIAL.
33           BDE-INDEX = HIDE-INDEX.
34           APPEND BDE.
35         ELSEIF NOT HIDE-GSFRG IS INITIAL.
36     *... Für Gesamtbanfen auf 'Kopfzeile' kein Detail möglich ............*
37           MESSAGE S198.
38           EXIT.
39         ELSE.
40     *- Funktion konnte für keine Zeile ausgeführt werden - vorher markieren*
41           MESSAGE S222.
42           EXIT.
43         ENDIF.
44       ENDIF.
45     *- Bearbeiten selektierte ---------------------------------------------*
46       LOOP AT BDE.
47         DO.
48     *- Dynpro aufrufen ----------------------------------------------------*
49           READ TABLE BAN INDEX BDE-INDEX.
50           HIDE-INDEX = BDE-INDEX.
51           MOVE BAN TO EBAN.
52           MOVE EBAN TO *EBAN.
53           PERFORM BAN_AUSGABE_VORBEREITEN USING 'D'.
54           CLEAR SY-UCOMM.
55           CALL SCREEN 300 STARTING AT 1 1.
56           IF OK-CODE NE 'XIT' AND
57             ( BAN-UPDK1 = AEND OR
58               BAN-UPDK1 = ZNER OR
59               BAN-UPDK1 = ZNEW ).
60             PERFORM BAN_MODIF_ZEILE USING SPACE.
61           ENDIF.
62     *- Nächste Banf -> nächster Eintrag BDE--------------------------------*
63           CLEAR REJECT.
64           CASE OK-CODE.
65             WHEN SPACE.
66               EXIT.
67             WHEN 'NEXD'.
68               CLEAR OK-CODE.
69               EXIT.
70     *- Abbrechen -> zurück in Grundliste ----------------------------------*
71             WHEN 'XIT'.
72               EXIT.
73     *- Andere Funktion -> Funktion ausführen und zurück aufs Dynpro -------*
74             WHEN OTHERS.
75               SY-UCOMM = OK-CODE.
76               CLEAR OK-CODE.
77               PERFORM USER_COMMAND.
78           ENDCASE.
79         ENDDO.
80         IF OK-CODE EQ 'XIT'.
81           REFRESH BDE.
82           CLEAR OK-CODE.
83           EXIT.
84         ENDIF.
85       ENDLOOP.
86
87     ENDFORM.
*--- End of FM06BF02_UCOMM_DETA - 87 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF02_UCOMM_ENDE                       Level 2    Page 41
Object           SAPMZFM06B                                Lines 64
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *        Beenden                                                       *
4      *----------------------------------------------------------------------*
5      FORM ucomm_ende.
6
7        CLEAR ban.
8      *- Prüfen, ob Bezugsquellen geändert wurden ---------------------------
9        LOOP AT ban WHERE updk1 EQ znew OR
10                         updk1 EQ zner OR
11                         updk1 EQ zres OR
12                         updk1 EQ aend.
13         EXIT.
14       ENDLOOP.
15
16     *- Wenn ja, Sicherungs-POP-UP senden ----------------------------------
17       IF sy-subrc EQ 0.
18         CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'                   "#EC *
19           EXPORTING
20             textline1 = text-201
21             textline2 = text-202
22             titel     = text-200
23           IMPORTING
24             answer    = answer.
25         CASE answer.
26           WHEN 'A'.
27             EXIT.
28           WHEN 'J'.
29             PERFORM ban_aendern.
30         ENDCASE.
31       ENDIF.
32
33       CLEAR ban.
34     *- Prüfen, ob Anfragezuordnung vorgenommen ----------------------------
35       LOOP AT ban WHERE updk1 EQ anfr OR
36                         updk1 EQ alif OR
37                         updk1 EQ aman.
38         EXIT.
39       ENDLOOP.
40
41     *- Wenn ja, Sicherungs-POP-UP senden ----------------------------------
42       IF sy-subrc EQ 0.
43         CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_MESSAGE'           "#EC *
44              EXPORTING
45                   defaultoption = 'N'
46                   diagnosetext1 = text-203
47                   diagnosetext2 = text-204
48                   textline1     = text-205
49                   textline2     = text-206
50                   titel         = text-200
51              IMPORTING
52                   answer        = answer.
53
54         CASE answer.
55           WHEN 'A'.
56             EXIT.
57           WHEN 'N'.
58             EXIT.
59         ENDCASE.
60       ENDIF.
61
62       PERFORM verlassen_liste.
63
64     ENDFORM.                    "UCOMM_ENDE
*--- End of FM06BF02_UCOMM_ENDE - 64 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF02_UCOMM_FRST                       Level 2    Page 42
Object           SAPMZFM06B                                Lines 121
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *        Anzeigen Freigabestrategie                                    *
4      *----------------------------------------------------------------------*
5      FORM UCOMM_FRST.
6
7        CHECK LISTE EQ 'G'.
8        LEERFLG = 'X'.
9
10     *- Suchen einer markierten Position -----------------------------------*
11       LOOP AT BAN WHERE SELKZ EQ 'X'.
12         IF NOT BAN-GSFRG IS INITIAL AND NOT GS_BANF IS INITIAL.
13           LOOP AT BAN WHERE BANFN EQ BAN-BANFN.
14             BAN-SELKZ = '*'.
15             MODIFY BAN.
16           ENDLOOP.
17         ELSE.
18           BAN-SELKZ = '*'.
19           MODIFY BAN.
20         ENDIF.
21         CLEAR LEERFLG.
22     *- Freigabestrategie anzeigen -----------------------------------------*
23         IF BAN-FRGST EQ SPACE.
24           MESSAGE S297 WITH BAN-BNFPO.
25           EXIT.
26         ENDIF.
27         IF BAN-FRGGR NE SPACE.
28           IF BAN-GSFRG IS INITIAL OR GS_BANF IS INITIAL.
29     *... Positionsfreigabe ...............................................*
30             HTITEL = TEXT-517.
31             REPLACE '&1' WITH BAN-BANFN INTO HTITEL.
32             REPLACE '&2' WITH BAN-BNFPO INTO HTITEL.
33           ELSE.
34     *... Gesamtfreigabe ..................................................*
35             HTITEL = TEXT-518.
36             REPLACE '&1' WITH BAN-BANFN INTO HTITEL.
37           ENDIF.
38           CALL FUNCTION 'ME_REL_INFO'
39                EXPORTING
40                     I_TITLE    = HTITEL
41                     I_FRGCO    = RM06B-FRGAB
42                     I_FRGKZ    = BAN-FRGKZ
43                     I_FRGGR    = BAN-FRGGR
44                     I_FRGST    = BAN-FRGST
45                     I_FRGZU    = BAN-FRGZU
46                     I_FRGOT    = '1'
47                EXCEPTIONS
48                     NOT_ACTIVE = 01.
49         ELSE.
50           CALL FUNCTION 'ME_INFO_RELEASE'
51                EXPORTING
52                     I_BNFPO = BAN-BNFPO
53                     I_FRGAB = RM06B-FRGAB
54                     I_FRGKZ = BAN-FRGKZ
55                     I_FRGST = BAN-FRGST
56                     I_FRGZU = BAN-FRGZU.
57         ENDIF.
58     *- Selektionskennzeichen modifizieren ---------------------------------*
59         PERFORM SEL_KENNZEICHNEN.
60     *- für eine Position ausgeführt - Schleife verlassen ------------------*
61         EXIT.
62       ENDLOOP.
63
64       IF LEERFLG NE SPACE.
65     *- Keine markierte Zeile gefunden - Prüfen auf Line-Selection ---------*
66         IF HIDE-INDEX NE 0.
67           READ TABLE BAN INDEX HIDE-INDEX.
68           IF BAN-FRGST EQ SPACE.
69             MESSAGE S297 WITH BAN-BNFPO.
70             EXIT.
71           ENDIF.
72           IF BAN-FRGGR NE SPACE.
73             IF BAN-GSFRG IS INITIAL OR GS_BANF IS INITIAL.
74     *... Positionsfreigabe ...............................................*
75               HTITEL = TEXT-517.
76               REPLACE '&1' WITH BAN-BANFN INTO HTITEL.
77               REPLACE '&2' WITH BAN-BNFPO INTO HTITEL.
78             ELSE.
79     *... Gesamtfreigabe ..................................................*
80               HTITEL = TEXT-518.
81               REPLACE '&1' WITH BAN-BANFN INTO HTITEL.
82             ENDIF.
83             CALL FUNCTION 'ME_REL_INFO'
84                  EXPORTING
85                       I_TITLE    = HTITEL
86                       I_FRGCO    = COM-FRGAB
87                       I_FRGKZ    = BAN-FRGKZ
88                       I_FRGGR    = BAN-FRGGR
89                       I_FRGST    = BAN-FRGST
90                       I_FRGZU    = BAN-FRGZU
91                       I_FRGOT    = '1'
92                  EXCEPTIONS
93                       NOT_ACTIVE = 01.
94           ELSE.
95             CALL FUNCTION 'ME_INFO_RELEASE'
96                  EXPORTING
97                       I_BNFPO = BAN-BNFPO
98                       I_FRGAB = COM-FRGAB
99                       I_FRGKZ = BAN-FRGKZ
100                      I_FRGST = BAN-FRGST
101                      I_FRGZU = BAN-FRGZU.
102          ENDIF.
103          IF BAN-GSFRG IS INITIAL OR GS_BANF IS INITIAL.
104            BAN-SELKZ = '*'.
105            MODIFY BAN INDEX HIDE-INDEX.
106          ELSE.
107            LOOP AT BAN WHERE BANFN EQ BAN-BANFN.
108              BAN-SELKZ = '*'.
109              MODIFY BAN.
110            ENDLOOP.
111          ENDIF.
112    *- falls auch zusätzlich angekreuzt - Stern setzen --------------------*
113          PERFORM SEL_KENNZEICHNEN.
114        ELSE.
115    *- Funktion konnte für keine Zeile ausgeführt werden - vorher markieren*
116          MESSAGE S222.
117          EXIT.
118        ENDIF.
119      ENDIF.
120
121    ENDFORM.
*--- End of FM06BF02_UCOMM_FRST - 121 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF02_UCOMM_HICK                       Level 2    Page 43
Object           SAPMZFM06B                                Lines 107
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *        Anzeigen Banf                                                 *
4      *----------------------------------------------------------------------*
5      FORM ucomm_hick.
6
7        DATA: l_display_only TYPE c VALUE ' '.
8        CHECK liste EQ 'G'.
9        leerflg = 'X'.
10
11       IF com-gpfkey EQ 'ZUOR' OR     "ME56
12          com-gpfkey EQ 'BEAR' OR     "ME57
13          com-gpfkey EQ 'FREI'.       "ME55
14         l_display_only = 'X'.
15       ENDIF.
16
17     *- Suchen einer markierten Position -----------------------------------*
18       LOOP AT ban WHERE selkz EQ 'X'.
19         IF NOT ban-gsfrg IS INITIAL AND NOT gs_banf IS INITIAL.
20           LOOP AT ban WHERE banfn EQ ban-banfn.
21             ban-selkz = '*'.
22             MODIFY ban.
23           ENDLOOP.
24     *... Bei Gesamtfreigabe die Positionsübersicht anzeigen ..............*
25           CALL FUNCTION 'MMPUR_REQUISITION_DISPLAY'
26                EXPORTING
27                     im_banfn     = ban-banfn
28                     im_display_only = l_display_only
29                EXCEPTIONS
30                     no_authority = 1
31                     OTHERS       = 2.
32           IF sy-subrc <> 0.
33             MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
34                     WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
35           ENDIF.
36         ELSE.
37           ban-selkz = '*'.
38           MODIFY ban.
39     *... Bei Positionsfreigabe die Banf-Position anzeigen ................*
40           CALL FUNCTION 'MMPUR_REQUISITION_DISPLAY'
41                EXPORTING
42                     im_banfn     = ban-banfn
43                     im_bnfpo     = ban-bnfpo
44                     im_display_only = l_display_only
45                EXCEPTIONS
46                     no_authority = 1
47                     OTHERS       = 2.
48           IF sy-subrc <> 0.
49             MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
50                     WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
51           ENDIF.
52         ENDIF.
53         CLEAR leerflg.
54     *- Selektionskennzeichen modifizieren ---------------------------------*
55         PERFORM sel_kennzeichnen.
56     *- für eine Position ausgeführt - Schleife verlassen ------------------*
57         EXIT.
58       ENDLOOP.
59
60       IF leerflg NE space.
61     *- Keine markierte Zeile gefunden - Prüfen auf Line-Selection ---------*
62         IF hide-index NE 0.
63           READ TABLE ban INDEX hide-index.
64           IF ban-gsfrg IS INITIAL OR hide-gsfrg IS INITIAL.
65     *... Bei Positionsfreigabe die Banf-Position anzeigen ................*
66             CALL FUNCTION 'MMPUR_REQUISITION_DISPLAY'
67                  EXPORTING
68                       im_banfn     = ban-banfn
69                       im_bnfpo     = ban-bnfpo
70                       im_display_only = l_display_only
71                  EXCEPTIONS
72                       no_authority = 1
73                       OTHERS       = 2.
74             IF sy-subrc <> 0.
75               MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
76                       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
77             ENDIF.
78             ban-selkz = '*'.
79             MODIFY ban INDEX hide-index.
80           ELSE.
81     *... Bei Gesamtfreigabe die Positionsübersicht anzeigen ..............*
82             CALL FUNCTION 'MMPUR_REQUISITION_DISPLAY'
83                  EXPORTING
84                       im_banfn     = ban-banfn
85                       im_display_only = l_display_only
86                  EXCEPTIONS
87                       no_authority = 1
88                       OTHERS       = 2.
89             IF sy-subrc <> 0.
90               MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
91                       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
92             ENDIF.
93             LOOP AT ban WHERE banfn EQ ban-banfn.
94               ban-selkz = '*'.
95               MODIFY ban.
96             ENDLOOP.
97           ENDIF.
98     *- falls auch zusätzlich angekreuzt - Stern setzen --------------------*
99           PERFORM sel_kennzeichnen.
100        ELSE.
101    *- Funktion konnte für keine Zeile ausgeführt werden - vorher markieren*
102          MESSAGE s222.
103          EXIT.
104        ENDIF.
105      ENDIF.
106
107    ENDFORM.
*--- End of FM06BF02_UCOMM_HICK - 107 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF02_UCOMM_KICK                       Level 2    Page 44
Object           SAPMZFM06B                                Lines 33
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *        Auswählen Konsilieferant                                     *
4      *----------------------------------------------------------------------*
5      FORM UCOMM_KICK.
6
7        CHECK SY-PFKEY EQ 'KONS'.
8        PERFORM VALID_LINE.
9        CHECK EXITFLAG EQ SPACE.
10       READ TABLE KON INDEX HIDE-KOIND.
11
12       IF INDEX_BAN EQ 0.
13     *- Mehrfachauswahl: Modifizieren Listzeilen mit Konsilieferanten ------*
14         LOOP AT BAN WHERE SELKZ EQ 'X'.
15           PERFORM BEZUGSQUELLE_5.          "zugelassen?
16           BAN-SELKZ = '*'.
17           INDEX_BAN = SY-TABIX.
18           LSIND = 0.
19           PERFORM BAN_UPDATE_KICK.
20         ENDLOOP.
21
22     *- Line-Selektion -----------------------------------------------------*
23       ELSE.
24         PERFORM BEZUGSQUELLE_5.            "zugelassen?
25     *- Modifizieren Banf-Tabelle mit Zuordnungsdaten ----------------------*
26         BAN-SELKZ = '*'.
27         LSIND = 0.
28         PERFORM BAN_UPDATE_KICK.
29       ENDIF.
30
31       SY-LSIND = 0.
32
33     ENDFORM.
*--- End of FM06BF02_UCOMM_KICK - 33 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF02_UCOMM_MAKT                       Level 2    Page 45
Object           SAPMZFM06B                                Lines 29
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *        Nochmal markieren                                             *
4      *----------------------------------------------------------------------*
5      FORM UCOMM_MAKT.
6
7        CHECK LISTE EQ 'G'.
8
9        LOOP AT BAN WHERE SELKZ EQ '*'.
10     *- Bei Sammelfreigabe nur die markieren, die Voraussetzung erfüllen ---*
11         IF SY-PFKEY EQ 'FREI'.
12           IF BAN-SELKF NE 0.
13             BAN-SELKZ = 'X'.
14             MODIFY BAN INDEX SY-TABIX.
15           ENDIF.
16         ELSE.
17     *- Nicht Sammelfreigabe - alle gesternten markieren -------------------*
18           PERFORM DET_CHECK.
19           CHECK SY-SUBRC EQ 0.
20           BAN-SELKZ = 'X'.
21           MODIFY BAN INDEX SY-TABIX.
22         ENDIF.
23       ENDLOOP.
24       SY-LSIND = 0.
25       IF T16LB-DYNPR EQ 0.
26         PERFORM BAN_ZEILEN.
27       ENDIF.
28
29     ENDFORM.
*--- End of FM06BF02_UCOMM_MAKT - 29 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF02_UCOMM_MALL                       Level 2    Page 46
Object           SAPMZFM06B                                Lines 31
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *        Alle markieren                                                *
4      *----------------------------------------------------------------------*
5      FORM UCOMM_MALL.
6
7        CHECK LISTE EQ 'G'.
8
9        LOOP AT BAN WHERE SELKZ NE 'X'.
10     *- Bei Sammelfreigabe nur die markieren, die Voraussetzung erfüllen ---*
11         IF SY-PFKEY EQ 'FREI'.
12           IF BAN-SELKF NE 0.
13             PERFORM DET_CHECK.
14             CHECK SY-SUBRC EQ 0.
15             BAN-SELKZ = 'X'.
16             MODIFY BAN INDEX SY-TABIX.
17           ENDIF.
18         ELSE.
19     *- Nicht Sammelfreigabe - alle markieren ------------------------------*
20           PERFORM DET_CHECK.
21           CHECK SY-SUBRC EQ 0.
22           BAN-SELKZ = 'X'.
23           MODIFY BAN INDEX SY-TABIX.
24         ENDIF.
25       ENDLOOP.
26       SY-LSIND = 0.
27       IF T16LB-DYNPR EQ 0.
28         PERFORM BAN_ZEILEN.
29       ENDIF.
30
31     ENDFORM.
*--- End of FM06BF02_UCOMM_MALL - 31 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF02_UCOMM_MARK                       Level 2    Page 47
Object           SAPMZFM06B                                Lines 106
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *        Einzelzeile markieren                                         *
4      *----------------------------------------------------------------------*
5      FORM ucomm_mark.
6
7        CHECK liste EQ 'G'.
8
9        PERFORM valid_line.
10       CHECK exitflag EQ space.
11
12       READ TABLE ban INDEX hide-index.
13       IF sy-subrc EQ 0.
14         IF ban-gsfrg IS INITIAL OR gs_banf IS INITIAL.             "157619
15           IF ban-selkz NE 'X'.
16             ban-selkz = 'X'.
17           ELSE.
18             ban-selkz = space.
19           ENDIF.
20           MODIFY ban INDEX hide-index.
21         ELSE.                                                      "157619
22           LOOP AT ban WHERE banfn EQ ban-banfn.                    "157619
23             IF ban-selkz NE 'X'.                                   "157619
24               ban-selkz = 'X'.                                     "157619
25             ELSE.                                                  "157619
26               ban-selkz = space.                                   "157619
27             ENDIF.                                                 "157619
28             MODIFY ban.                                            "157619
29           ENDLOOP.                                                 "157619
30         ENDIF.                                                     "157619
31       ENDIF.
32
33     *- Selektionskennzeichen modifizieren ---------------------------------*
34       PERFORM sel_kennzeichnen.
35
36     ENDFORM.                    "ucomm_mark
37     *-- Note 739690
38     *&---------------------------------------------------------------------*
39     *&      Form  UCOMM_LOG1
40     *&---------------------------------------------------------------------*
41     *       text
42     *----------------------------------------------------------------------*
43     *  -->  p1        text
44     *  <--  p2        text
45     *----------------------------------------------------------------------*
46     FORM ucomm_log1 .
47       TYPE-POOLS : slis.
48       DATA       : l_t_fieldcat_alv TYPE slis_t_fieldcat_alv,
49                    l_s_fieldcat_alv TYPE slis_fieldcat_alv.
50
51       CLEAR l_s_fieldcat_alv.
52       l_s_fieldcat_alv-fieldname     = 'BANFN'.
53       l_s_fieldcat_alv-ref_fieldname = 'BANFN'.
54       l_s_fieldcat_alv-ref_tabname   = 'EBAN'.
55       l_s_fieldcat_alv-key           = 'X'.
56       l_s_fieldcat_alv-hotspot       = ' '.
57       APPEND l_s_fieldcat_alv TO l_t_fieldcat_alv.
58
59       CLEAR l_s_fieldcat_alv.
60       l_s_fieldcat_alv-fieldname     = 'ARBGB'.
61       l_s_fieldcat_alv-ref_fieldname = 'ARBGB'.
62       l_s_fieldcat_alv-ref_tabname   = 'MESG'.
63       l_s_fieldcat_alv-key           = ' '.
64       l_s_fieldcat_alv-hotspot       = ' '.
65       APPEND l_s_fieldcat_alv TO l_t_fieldcat_alv.
66
67       CLEAR l_s_fieldcat_alv.
68       l_s_fieldcat_alv-fieldname     = 'MSGTY'.
69       l_s_fieldcat_alv-ref_fieldname = 'MSGTY'.
70       l_s_fieldcat_alv-ref_tabname   = 'MESG'.
71       l_s_fieldcat_alv-key           = ' '.
72       l_s_fieldcat_alv-hotspot       = ' '.
73       APPEND l_s_fieldcat_alv TO l_t_fieldcat_alv.
74
75       CLEAR l_s_fieldcat_alv.
76       l_s_fieldcat_alv-fieldname     = 'TXTNR'.
77       l_s_fieldcat_alv-ref_fieldname = 'TXTNR'.
78       l_s_fieldcat_alv-ref_tabname   = 'MESG'.
79       l_s_fieldcat_alv-key           = ' '.
80       l_s_fieldcat_alv-hotspot       = ' '.
81       APPEND l_s_fieldcat_alv TO l_t_fieldcat_alv.
82
83       CLEAR l_s_fieldcat_alv.
84       l_s_fieldcat_alv-fieldname     = 'TEXT'.
85       l_s_fieldcat_alv-ref_fieldname = 'TEXT'.
86       l_s_fieldcat_alv-ref_tabname   = 'MESG'.
87       l_s_fieldcat_alv-key           = ' '.
88       l_s_fieldcat_alv-hotspot       = ' '.
89       APPEND l_s_fieldcat_alv TO l_t_fieldcat_alv.
90
91       CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
92         EXPORTING
93           i_callback_program    = sy-repid
94           it_fieldcat           = l_t_fieldcat_alv
95           i_screen_start_column = '10'
96           i_screen_start_line   = '10'
97           i_screen_end_column   = '100'
98           i_screen_end_line     = '50'
99         TABLES
100          t_outtab              = t_excluded
101        EXCEPTIONS
102          program_error         = 1
103          OTHERS                = 2.
104
105    ENDFORM.                    " UCOMM_LOG1
106    *-- Note 739690
*--- End of FM06BF02_UCOMM_MARK - 106 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF02_UCOMM_MDEL                       Level 2    Page 48
Object           SAPMZFM06B                                Lines 21
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *        Alle Markierungen löschen                                     *
4      *----------------------------------------------------------------------*
5      FORM UCOMM_MDEL.
6
7        CHECK LISTE EQ 'G'.
8
9        LOOP AT BAN WHERE SELKZ NE SPACE.
10         PERFORM DET_CHECK.
11         CHECK SY-SUBRC EQ 0.
12         BAN-SELKZ = SPACE.
13         MODIFY BAN INDEX SY-TABIX.
14       ENDLOOP.
15
16       SY-LSIND = 0.
17       IF T16LB-DYNPR EQ 0.
18         PERFORM BAN_ZEILEN.
19       ENDIF.
20
21     ENDFORM.
*--- End of FM06BF02_UCOMM_MDEL - 21 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF02_UCOMM_MINT                       Level 2    Page 49
Object           SAPMZFM06B                                Lines 47
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *        Markieren Intervall (Block markieren)                         *
4      *----------------------------------------------------------------------*
5      FORM UCOMM_MINT.
6
7        CHECK LISTE EQ 'G'.
8
9      *- prüfen gültige Zeile -----------------------------------------------*
10       PERFORM VALID_LINE.
11       CHECK EXITFLAG EQ SPACE.
12       CLEAR MINT-ACT.
13
14     *- Blockende ----------------------------------------------------------*
15       IF MINT-BEG NE 0.
16     *- Blockanfang und -ende vertauschen, wenn Hide-Index kleiner Interv-Ind
17         IF HIDE-INDEX LT MINT-BEG.
18           MINT-ACT = MINT-BEG.
19           MINT-BEG = HIDE-INDEX.
20           MINT-END = MINT-ACT.
21         ELSE.
22           MINT-END = HIDE-INDEX.
23         ENDIF.
24         MINT-ACT = MINT-BEG.
25         DO.
26           IF MINT-ACT LE MINT-END.
27             READ TABLE BAN INDEX MINT-ACT.
28             PERFORM DET_CHECK.
29             IF SY-SUBRC EQ 0.
30               BAN-SELKZ = 'X'.
31               MODIFY BAN INDEX SY-TABIX.
32               PERFORM SEL_KENNZEICHNEN.
33             ENDIF.
34             MINT-ACT = MINT-ACT + 1.
35           ELSE.
36             CLEAR MINT.
37             EXIT.
38           ENDIF.
39         ENDDO.
40       ELSE.
41     *- Blockanfang - Blockende markieren ----------------------------------*
42         MINT-BEG = HIDE-INDEX.
43         MESSAGE S213.
44       ENDIF.
45       CLEAR HIDE-INDEX.
46
47     ENDFORM.
*--- End of FM06BF02_UCOMM_MINT - 47 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF02_UCOMM_MATN                       Level 2    Page 50
Object           SAPMZFM06B                                Lines 73
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *        Anzeigen Material                                             *
4      *----------------------------------------------------------------------*
5      FORM UCOMM_MATN.
6
7        CHECK LISTE EQ 'G'.
8        LEERFLG = 'X'.
9
10     *- Suchen einer markierten Position -----------------------------------*
11       LOOP AT BAN WHERE SELKZ EQ 'X'.
12     *- Zeile ohne Material geht nicht - zum nächsten markierten Eintrag ---*
13         IF BAN-MATNR EQ SPACE.
14           LEERFLG = 'Y'.
15           CHECK BAN-MATNR NE SPACE.
16         ENDIF.
17         CLEAR LEERFLG.
18         BAN-SELKZ = '*'.
19         MODIFY BAN.
20     *- Material anzeigen --------------------------------------------------*
21         SET PARAMETER ID 'MXX' FIELD 'E'.
22         SET PARAMETER ID 'MAT' FIELD BAN-MATNR.
23         SET PARAMETER ID 'WRK' FIELD BAN-WERKS.
24         SET PARAMETER ID 'LAG' FIELD BAN-LGORT.
25         CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
26     *- Selektionskennzeichen modifizieren ---------------------------------*
27         PERFORM SEL_KENNZEICHNEN.
28     *- für eine Position ausgeführt - Schleife verlassen ------------------*
29         EXIT.
30       ENDLOOP.
31
32       CASE LEERFLG.
33     *- Keine markierte Zeile gefunden - Prüfen auf Line-Selection ---------*
34         WHEN 'X'.
35           IF HIDE-INDEX NE 0.
36             READ TABLE BAN INDEX HIDE-INDEX.
37     *- Zeile ohne Material geht nicht - zum nächsten markierten Eintrag ---*
38             IF BAN-MATNR EQ SPACE.
39               MESSAGE S272.
40               CLEAR SY-UCOMM.
41               EXIT.
42             ENDIF.
43     *- Material anzeigen --------------------------------------------------*
44             SET PARAMETER ID 'MXX' FIELD 'E'.
45             SET PARAMETER ID 'MAT' FIELD BAN-MATNR.
46             SET PARAMETER ID 'WRK' FIELD BAN-WERKS.
47             SET PARAMETER ID 'LAG' FIELD BAN-LGORT.
48             CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
49             BAN-SELKZ = '*'.
50             MODIFY BAN INDEX HIDE-INDEX.
51     *- falls auch zusätzlich angekreuzt - Stern setzen --------------------*
52             PERFORM SEL_KENNZEICHNEN.
53             EXIT.
54           ELSE.
55     *- Funktion konnte für keine Zeile ausgeführt werden - vorher markieren*
56             MESSAGE S222.
57             EXIT.
58           ENDIF.
59     *- Es wurden nur Zeilen ohne Materialnummer markiert ------------------*
60         WHEN 'Y'.
61           MESSAGE S272.
62           EXIT.
63       ENDCASE.
64
65     *- alle Banfen kennzeichnen, die dieselbe Matnr haben u. selektiert sind
66       LOOP AT BAN WHERE SELKZ EQ 'X' AND
67                         MATNR EQ BAN-MATNR.
68         BAN-SELKZ = '*'.
69         MODIFY BAN.
70         PERFORM SEL_KENNZEICHNEN.
71       ENDLOOP.
72
73     ENDFORM.
*--- End of FM06BF02_UCOMM_MATN - 73 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF02_UCOMM_MMBE                       Level 2    Page 51
Object           SAPMZFM06B                                Lines 73
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *        Anzeigen Materialbestandsübersicht                            *
4      *----------------------------------------------------------------------*
5      FORM UCOMM_MMBE.
6
7        CHECK LISTE EQ 'G'.
8        LEERFLG = 'X'.
9
10     *- Suchen einer markierten Position -----------------------------------*
11       LOOP AT BAN WHERE SELKZ EQ 'X'.
12     *- Zeile ohne Material geht nicht - zum nächsten markierten Eintrag ---*
13         IF BAN-MATNR EQ SPACE.
14           LEERFLG = 'Y'.
15           CHECK BAN-MATNR NE SPACE.
16         ENDIF.
17         CLEAR LEERFLG.
18         BAN-SELKZ = '*'.
19         MODIFY BAN.
20     *- Bestandsübersicht --------------------------------------------------*
21         SET PARAMETER ID 'MAT' FIELD BAN-MATNR.
22         SET PARAMETER ID 'WRK' FIELD BAN-WERKS.
23         SET PARAMETER ID 'LAG' FIELD SPACE.
24         SET PARAMETER ID 'CHA' FIELD SPACE.
25         CALL TRANSACTION 'MMBE' AND SKIP FIRST SCREEN.
26     *- Selektionskennzeichen modifizieren ---------------------------------*
27         PERFORM SEL_KENNZEICHNEN.
28     *- für eine Position ausgeführt - Schleife verlassen ------------------*
29         EXIT.
30       ENDLOOP.
31
32       CASE LEERFLG.
33     *- Keine markierte Zeile gefunden - Prüfen auf Line-Selection ---------*
34         WHEN 'X'.
35           IF HIDE-INDEX NE 0.
36             READ TABLE BAN INDEX HIDE-INDEX.
37     *- Zeile ohne Material geht nicht - zum nächsten markierten Eintrag ---*
38             IF BAN-MATNR EQ SPACE.
39               MESSAGE S272.
40               CLEAR SY-UCOMM.
41               EXIT.
42             ENDIF.
43     *- Bestandsübersicht --------------------------------------------------*
44             SET PARAMETER ID 'MAT' FIELD BAN-MATNR.
45             SET PARAMETER ID 'WRK' FIELD BAN-WERKS.
46             SET PARAMETER ID 'LAG' FIELD SPACE.
47             SET PARAMETER ID 'CHA' FIELD SPACE.
48             CALL TRANSACTION 'MMBE' AND SKIP FIRST SCREEN.
49             BAN-SELKZ = '*'.
50             MODIFY BAN INDEX HIDE-INDEX.
51     *- falls auch zusätzlich angekreuzt - Stern setzen --------------------*
52             PERFORM SEL_KENNZEICHNEN.
53             EXIT.
54           ELSE.
55     *- Funktion konnte für keine Zeile ausgeführt werden - vorher markieren*
56             MESSAGE S222.
57             EXIT.
58           ENDIF.
59     *- Es wurden nur Zeilen ohne Materialnummer markiert ------------------*
60         WHEN 'Y'.
61           MESSAGE S272.
62           EXIT.
63       ENDCASE.
64
65     *- alle Banfen kennzeichnen, die dieselbe Matnr haben u. selektiert sind
66       LOOP AT BAN WHERE SELKZ EQ 'X' AND
67                         MATNR EQ BAN-MATNR.
68         BAN-SELKZ = '*'.
69         MODIFY BAN.
70         PERFORM SEL_KENNZEICHNEN.
71       ENDLOOP.
72
73     ENDFORM.
*--- End of FM06BF02_UCOMM_MMBE - 73 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF02_UCOMM_MD04                       Level 2    Page 52
Object           SAPMZFM06B                                Lines 71
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *        Anzeigen Aktuelle Bestands/Bedarfssituation                   *
4      *----------------------------------------------------------------------*
5      FORM UCOMM_MD04.
6
7        CHECK LISTE EQ 'G'.
8        LEERFLG = 'X'.
9
10     *- Suchen einer markierten Position -----------------------------------*
11       LOOP AT BAN WHERE SELKZ EQ 'X'.
12     *- Zeile ohne Material geht nicht - zum nächsten markierten Eintrag ---*
13         IF BAN-MATNR EQ SPACE.
14           LEERFLG = 'Y'.
15           CHECK BAN-MATNR NE SPACE.
16         ENDIF.
17         CLEAR LEERFLG.
18         BAN-SELKZ = '*'.
19         MODIFY BAN.
20     *- Bestands-/Bedarfs-Situation ----------------------------------------*
21         SET PARAMETER ID 'MAT' FIELD BAN-MATNR.
22         SET PARAMETER ID 'WRK' FIELD BAN-WERKS.
23         SET PARAMETER ID 'BERID' FIELD SPACE.                   "896768
24         CALL TRANSACTION 'MD04' AND SKIP FIRST SCREEN.
25     *- Selektionskennzeichen modifizieren ---------------------------------*
26         PERFORM SEL_KENNZEICHNEN.
27     *- für eine Position ausgeführt - Schleife verlassen ------------------*
28         EXIT.
29       ENDLOOP.
30
31       CASE LEERFLG.
32     *- Keine markierte Zeile gefunden - Prüfen auf Line-Selection ---------*
33         WHEN 'X'.
34           IF HIDE-INDEX NE 0.
35             READ TABLE BAN INDEX HIDE-INDEX.
36     *- Zeile ohne Material geht nicht - zum nächsten markierten Eintrag ---*
37             IF BAN-MATNR EQ SPACE.
38               MESSAGE S272.
39               CLEAR SY-UCOMM.
40               EXIT.
41             ENDIF.
42     *- Bestands-/Bedarfs-Situation ----------------------------------------*
43             SET PARAMETER ID 'MAT' FIELD BAN-MATNR.
44             SET PARAMETER ID 'WRK' FIELD BAN-WERKS.
45             SET PARAMETER ID 'BERID' FIELD SPACE.               "896768
46             CALL TRANSACTION 'MD04' AND SKIP FIRST SCREEN.
47             BAN-SELKZ = '*'.
48             MODIFY BAN INDEX HIDE-INDEX.
49     *- falls auch zusätzlich angekreuzt - Stern setzen --------------------*
50             PERFORM SEL_KENNZEICHNEN.
51             EXIT.
52           ELSE.
53     *- Funktion konnte für keine Zeile ausgeführt werden - vorher markieren*
54             MESSAGE S222.
55             EXIT.
56           ENDIF.
57     *- Es wurden nur Zeilen ohne Materialnummer markiert ------------------*
58         WHEN 'Y'.
59           MESSAGE S272.
60           EXIT.
61       ENDCASE.
62
63     *- alle Banfen kennzeichnen, die dieselbe Matnr haben u. selektiert sind
64       LOOP AT BAN WHERE SELKZ EQ 'X' AND
65                         MATNR EQ BAN-MATNR.
66         BAN-SELKZ = '*'.
67         MODIFY BAN.
68         PERFORM SEL_KENNZEICHNEN.
69       ENDLOOP.
70
71     ENDFORM.
*--- End of FM06BF02_UCOMM_MD04 - 71 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF02_UCOMM_ME54                       Level 2    Page 53
Object           SAPMZFM06B                                Lines 30
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *     Verzweigen in die Einzelfreigabe der Bestellanforderung
4      *----------------------------------------------------------------------*
5      FORM UCOMM_ME54.
6
7        CHECK SY-PFKEY EQ 'FREI'.
8        LEERFLG = 'X'.
9
10     *- Suchen einer markierten Position -----------------------------------*
11       LOOP AT BAN WHERE SELKZ EQ 'X'.
12         CLEAR LEERFLG.
13         PERFORM AUFRUF_EINZELFREIGABE.
14     *- für eine Position ausgeführt - Schleife verlassen ------------------*
15         EXIT.
16       ENDLOOP.
17
18       IF LEERFLG NE SPACE.
19     *- Keine markierte Zeile gefunden - Prüfen auf Line-Selection ---------*
20         IF HIDE-INDEX NE 0.
21           READ TABLE BAN INDEX HIDE-INDEX.
22           PERFORM AUFRUF_EINZELFREIGABE.
23         ELSE.
24     *- Funktion konnte für keine Zeile ausgeführt werden - vorher markieren*
25           MESSAGE S222.
26           EXIT.
27         ENDIF.
28       ENDIF.
29
30     ENDFORM.
*--- End of FM06BF02_UCOMM_ME54 - 30 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF02_UCOMM_LINF                       Level 2    Page 54
Object           SAPMZFM06B                                Lines 76
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *     Anzeigen Infosätze zum Material
4      *----------------------------------------------------------------------*
5      FORM UCOMM_LINF.
6
7        CHECK LISTE EQ 'G'.
8
9        LEERFLG = 'X'.
10       CLEAR: INF, INDEX_BAN, EXITFLAG.
11
12     *- Suchen einer markierten Position -----------------------------------*
13       LOOP AT BAN WHERE SELKZ EQ 'X'.
14         PERFORM WARNING_UPDK3.
15         CLEAR LEERFLG.
16         IF INF-MATNR NE SPACE.
17     *- Daten nicht gleich - Meldung ---------------------------------------*
18           IF BAN-MATNR NE INF-MATNR OR
19              BAN-WERKS NE INF-WERKS.
20             MESSAGE S225.
21             EXITFLAG = 'X'.
22             EXIT.
23           ENDIF.
24         ELSE.
25           IF INF-MATKL NE SPACE.
26             IF BAN-MATKL NE INF-MATKL OR
27                BAN-WERKS NE INF-WERKS.
28               MESSAGE S225.
29               EXITFLAG = 'X'.
30               EXIT.
31             ENDIF.
32           ENDIF.
33         ENDIF.
34     *- Daten gleich - ok. -------------------------------------------------*
35         MOVE-CORRESPONDING BAN TO INF.
36         INDEX_BAN = SY-TABIX.
37       ENDLOOP.
38
39     *- Verlassen Routine, wenn Fehler aufgetreten -------------------------*
40       CHECK EXITFLAG EQ SPACE.
41
42       IF LEERFLG NE SPACE.
43     *- Keine markierten Zeilen gefunden - Prüfen auf Line-Selection -------*
44         IF HIDE-INDEX NE 0.
45           PERFORM VALID_LINE.
46           CHECK EXITFLAG EQ SPACE.
47           READ TABLE BAN INDEX HIDE-INDEX.
48           PERFORM WARNING_UPDK3.
49           INDEX_BAN = SY-TABIX.
50     *- Aufruf Report ------------------------------------------------------*
51           PERFORM AUFRUF_INFOSAETZE.
52           CHECK EXITFLAG EQ SPACE.
53     *- Modifizieren Banf-Tabelle mit Zuordnungsdaten ----------------------*
54           PERFORM BAN_UPDATE_LINF.
55           EXIT.
56     *- Keine markierten Zeilen gefunden - bitte zuerst markieren ----------*
57         ELSE.
58           MESSAGE S222.
59           EXIT.
60         ENDIF.
61       ENDIF.
62
63     *- Aufruf Report ------------------------------------------------------*
64       READ TABLE BAN INDEX INDEX_BAN.
65       PERFORM AUFRUF_INFOSAETZE.
66       CHECK EXITFLAG EQ SPACE.
67     *- Modifizieren der Listzeilen mit zugeordnetem Rahmenvertrag ---------*
68       LOOP AT BAN WHERE SELKZ EQ 'X'.
69         INDEX_BAN = SY-TABIX.
70     *- Sonderzeile in Liste aufbauen --------------------------------------*
71         PERFORM BAN_UPDATE_LINF.
72       ENDLOOP.
73
74       CLEAR HIDE-INDEX.
75
76     ENDFORM.
*--- End of FM06BF02_UCOMM_LINF - 76 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF02_UCOMM_LIBE                       Level 2    Page 55
Object           SAPMZFM06B                                Lines 102
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *     Lieferantenbeurteilung zum Material oder zur Materialklasse
4      *----------------------------------------------------------------------*
5      FORM UCOMM_LIBE.
6
7        CHECK LISTE EQ 'G'.
8
9        LEERFLG = 'X'.
10       CLEAR: LIBE, LIBE_EKO, INDEX_BAN, EXITFLAG.
11       REFRESH: LIBE_EKO.
12     *- Suchen einer markierten Position -----------------------------------*
13       LOOP AT BAN WHERE SELKZ EQ 'X'.
14         CLEAR LEERFLG.
15         IF LIBE-MATNR NE SPACE.
16     *- Daten nicht gleich - Meldung ---------------------------------------*
17           IF BAN-MATNR NE LIBE-MATNR.
18             MESSAGE S225.
19             EXITFLAG = 'X'.
20             EXIT.
21           ENDIF.
22         ELSE.
23           IF LIBE-MATKL NE SPACE.
24             IF BAN-MATKL NE LIBE-MATKL.
25               MESSAGE S225.
26               EXITFLAG = 'X'.
27               EXIT.
28             ENDIF.
29           ENDIF.
30         ENDIF.
31     *- Daten gleich - ok. -------------------------------------------------*
32         MOVE-CORRESPONDING BAN TO LIBE.
33     *
34         IF NOT BAN-MATNR IS INITIAL.       "4.0C
35     *... Lagermaterial ...................................................*
36     *... Falls HTN-Abwicklung aktiv ist und die EK-Statistik auf dem HTN .*
37     *... fortgeschreiben wird, muß hier mit dem HTN (ematn) gearbeitet.werd.
38           CALL FUNCTION 'MB_READ_TMPPF'    "4.0C
39                EXPORTING                   "4.0C
40                     PROFILE        = BAN-MPROF                   "4.0C
41                IMPORTING                   "4.0C
42                     MPN_PARAMETERS = TMPPF "4.0C
43                EXCEPTIONS                  "4.0C
44                     NO_ENTRY       = 1     "4.0C
45                     OTHERS         = 2.    "4.0C
46           IF NOT TMPPF-MPLIS IS INITIAL AND"4.0C
47              NOT BAN-EMATN IS INITIAL.     "4.0C
48     *... HTN-Abwicklung und Statistik auf HTN ............................*
49             LIBE-MATNR     = BAN-EMATN.    "4.0C
50           ENDIF.                           "4.0C
51         ENDIF.                             "4.0C
52     *
53         INDEX_BAN = SY-TABIX.
54     *... Ermitteln der beteiligten Einkaufsorganisationen ................*
55         CALL FUNCTION 'ME_SELECT_EKORG_FOR_PLANT'                  "4.0C
56              EXPORTING                     "4.0C
57                   I_WERKS                    = BAN-WERKS           "4.0C
58                   I_STANDARD                 = 'X'                 "4.0C
59              IMPORTING                     "4.0C
60                   E_EKORG                    = LIBE_EKO-EKORG      "4.0C
61          exceptions                                            "4.0C
62               more_than_one_organization = 1                   "4.0C
63               no_entry_found             = 2                   "4.0C
64               no_default_found           = 3.                  "4.0C
65         LIBE-EKORG = LIBE_EKO-EKORG.
66       ENDLOOP.
67     *- Verlassen Routine, wenn Fehler aufgetreten -------------------------*
68       CHECK EXITFLAG EQ SPACE.
69
70       IF LEERFLG NE SPACE.
71     *- Keine markierten Zeilen gefunden - Prüfen auf Line-Selection -------*
72         IF HIDE-INDEX NE 0.
73           PERFORM VALID_LINE.
74           CHECK EXITFLAG EQ SPACE.
75           READ TABLE BAN INDEX HIDE-INDEX.
76           INDEX_BAN = SY-TABIX.
77     *- Aufruf Report ------------------------------------------------------*
78           PERFORM AUFRUF_LIBE.
79           CHECK EXITFLAG EQ SPACE.
80     *- Modifizieren Banf-Tabelle mit Zuordnungsdaten ----------------------*
81           INDEX_BAN = SY-TABIX.
82     *- Sonderzeile in Liste aufbauen --------------------------------------*
83           PERFORM BAN_UPDATE_LINF.
84           EXIT.
85     *- Keine markierten Zeilen gefunden - bitte zuerst markieren ----------*
86         ELSE.
87           MESSAGE S222.
88           EXIT.
89         ENDIF.
90       ENDIF.
91     *- Aufruf Report ------------------------------------------------------*
92       READ TABLE BAN INDEX INDEX_BAN.
93       PERFORM AUFRUF_LIBE.
94       CHECK EXITFLAG EQ SPACE.
95     *- Modifizieren der Listzeilen mit zugeordnetem Rahmenvertrag ---------*
96       LOOP AT BAN WHERE SELKZ EQ 'X'.
97         INDEX_BAN = SY-TABIX.
98     *- Sonderzeile in Liste aufbauen --------------------------------------*
99         PERFORM BAN_UPDATE_LINF.
100      ENDLOOP.
101      CLEAR HIDE-INDEX.
102    ENDFORM.
*--- End of FM06BF02_UCOMM_LIBE - 102 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF02_UCOMM_LKON                       Level 2    Page 56
Object           SAPMZFM06B                                Lines 79
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *     Anzeigen Konsilieferanten
4      *----------------------------------------------------------------------*
5      FORM UCOMM_LKON.
6
7        CHECK LISTE EQ 'G'.
8
9        LEERFLG = 'X'.
10       CLEAR: KNS, INDEX_BAN, EXITFLAG.
11
12     *- Suchen einer markierten Position -----------------------------------*
13       LOOP AT BAN WHERE SELKZ EQ 'X'.
14         CLEAR LEERFLG.
15     *- Banf ist keine Konsiposition ---------------------------------------*
16         IF BAN-PSTYP NE PSTYP-KONS.
17           IF KNS-MATNR EQ SPACE.
18             LEERFLG = 'Y'.
19           ENDIF.
20     *- Selektionskennzeichen zurücksetzen ---------------------------------*
21           BAN-SELKZ = SPACE.
22           MODIFY BAN.
23           PERFORM SEL_KENNZEICHNEN.
24           CHECK BAN-PSTYP EQ PSTYP-KONS.
25         ENDIF.
26         IF KNS-MATNR NE SPACE.
27     *- Daten nicht gleich - Meldung ---------------------------------------*
28           IF BAN-MATNR NE KNS-MATNR OR
29              BAN-WERKS NE KNS-WERKS.
30             MESSAGE S225.
31             EXITFLAG = 'X'.
32             EXIT.
33           ENDIF.
34     *- Daten gleich - ok. -------------------------------------------------*
35         ELSE.
36           MOVE-CORRESPONDING BAN TO KNS.
37           INDEX_BAN = SY-TABIX.
38           CLEAR LEERFLG.
39         ENDIF.
40       ENDLOOP.
41
42     *- Verlassen Routine, wenn Fehler aufgetreten -------------------------*
43       CHECK EXITFLAG EQ SPACE.
44
45       CASE LEERFLG.
46         WHEN 'X'.
47     *- Keine markierte Zeile gefunden - Prüfen auf Line-Selection ---------*
48           IF HIDE-INDEX NE 0.
49             PERFORM VALID_LINE.
50             CHECK EXITFLAG EQ SPACE.
51             READ TABLE BAN INDEX HIDE-INDEX.
52             IF BAN-PSTYP NE PSTYP-KONS.
53               MESSAGE S210.
54               CLEAR HIDE-INDEX.
55               EXIT.
56             ENDIF.
57             INDEX_BAN = SY-TABIX.
58     *- Ausgeben Konsiliste ------------------------------------------------*
59             PERFORM KONSI_LISTE.
60             EXIT.
61           ELSE.
62     *- Keine markierte Banf - Meldung: zuerst markieren -------------------*
63             MESSAGE S222.
64             EXIT.
65           ENDIF.
66     *- Keine markierte Banf mit Positionstyp 'K' - Meldung ----------------*
67         WHEN 'Y'.
68           MESSAGE S210.
69           EXIT.
70       ENDCASE.
71
72     *- Ausgabe Konsiliste für die markierten ------------------------------*
73       READ TABLE BAN INDEX INDEX_BAN.
74       CLEAR INDEX_BAN.
75       PERFORM KONSI_LISTE.
76
77       CLEAR HIDE-INDEX.
78
79     ENDFORM.
*--- End of FM06BF02_UCOMM_LKON - 79 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF02_UCOMM_LRAC                       Level 2    Page 57
Object           SAPMZFM06B                                Lines 65
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *     Anzeigen Rahmenvertraege zur Materialklasse
4      *----------------------------------------------------------------------*
5      FORM UCOMM_LRAC.
6
7        CHECK LISTE EQ 'G'.
8
9        LEERFLG = 'X'.
10       CLEAR: KLA, INDEX_BAN, EXITFLAG.
11
12     *- Suchen einer markierten Position -----------------------------------*
13       LOOP AT BAN WHERE SELKZ EQ 'X'.
14         CLEAR LEERFLG.
15         IF KLA-MATKL NE SPACE.
16     *- Daten nicht gleich - Meldung ---------------------------------------*
17           IF BAN-MATKL NE KLA-MATKL OR
18              BAN-BSART NE KLA-BSART OR
19              BAN-PSTYP NE KLA-PSTYP OR
20              BAN-KNTTP NE KLA-KNTTP OR
21              BAN-WERKS NE KLA-WERKS.
22             MESSAGE S225.
23             EXITFLAG = 'X'.
24             EXIT.
25           ENDIF.
26     *- Daten gleich - ok. -------------------------------------------------*
27         ELSE.
28           MOVE-CORRESPONDING BAN TO KLA.
29           INDEX_BAN = SY-TABIX.
30         ENDIF.
31       ENDLOOP.
32
33     *- Verlassen Routine, wenn Fehler aufgetreten -------------------------*
34       CHECK EXITFLAG EQ SPACE.
35
36       IF LEERFLG NE SPACE.
37     *- Keine markierte Zeile gefunden - Prüfen auf Line-Selection ---------*
38         IF HIDE-INDEX NE 0.
39           READ TABLE BAN INDEX HIDE-INDEX.
40           INDEX_BAN = SY-TABIX.
41     *- Aufruf Report ------------------------------------------------------*
42           PERFORM AUFRUF_MATERIALKLASSE.
43           CHECK EXITFLAG EQ SPACE.
44           PERFORM BAN_UPDATE_RAHM.
45           EXIT.
46         ELSE.
47     *- Keine markierte Banf - Meldung: zuerst markieren -------------------*
48           MESSAGE S222.
49           EXIT.
50         ENDIF.
51       ENDIF.
52
53     *- Aufruf Report für die markierten -----------------------------------*
54       READ TABLE BAN INDEX INDEX_BAN.
55       PERFORM AUFRUF_MATERIALKLASSE.
56       CHECK EXITFLAG EQ SPACE.
57     *- Modifizieren der Listzeilen mit zugeordnetem Rahmenvertrag ---------*
58       LOOP AT BAN WHERE SELKZ EQ 'X'.
59         INDEX_BAN = SY-TABIX.
60         PERFORM BAN_UPDATE_RAHM.
61       ENDLOOP.
62
63       CLEAR HIDE-INDEX.
64
65     ENDFORM.
*--- End of FM06BF02_UCOMM_LRAC - 65 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF02_UCOMM_LRAM                       Level 2    Page 58
Object           SAPMZFM06B                                Lines 87
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *     Anzeigen Rahmenvertraege zum Material                            *
4      *----------------------------------------------------------------------*
5      FORM UCOMM_LRAM.
6
7        CHECK LISTE EQ 'G'.
8
9        LEERFLG = 'X'.
10       CLEAR: MAT, INDEX_BAN, EXITFLAG.
11
12     *- Suchen einer markierten Position -----------------------------------*
13       LOOP AT BAN WHERE SELKZ EQ 'X'.
14         CLEAR LEERFLG.
15     *- Banf hat keine Materialnummer --------------------------------------*
16         IF BAN-MATNR EQ SPACE.
17           IF MAT-MATNR EQ SPACE.
18             LEERFLG = 'Y'.
19           ENDIF.
20     *- Selektionskennzeichen zurücksetzen      ----------------------------*
21           BAN-SELKZ = SPACE.
22           MODIFY BAN.
23           PERFORM SEL_KENNZEICHNEN.
24           CHECK BAN-MATNR NE SPACE.
25         ENDIF.
26         IF MAT-MATNR NE SPACE.
27     *- Daten nicht gleich - Meldung ---------------------------------------*
28           IF BAN-MATNR NE MAT-MATNR OR
29              BAN-BSART NE MAT-BSART OR
30              BAN-PSTYP NE MAT-PSTYP OR
31              BAN-KNTTP NE MAT-KNTTP OR
32              BAN-WERKS NE MAT-WERKS.
33             MESSAGE S225.
34             EXITFLAG = 'X'.
35             EXIT.
36           ENDIF.
37     *- Daten gleich - ok. -------------------------------------------------*
38         ELSE.
39           MOVE-CORRESPONDING BAN TO MAT.
40           INDEX_BAN = SY-TABIX.
41           CLEAR LEERFLG.
42         ENDIF.
43       ENDLOOP.
44
45     *- Verlassen Routine, wenn Fehler aufgetreten -------------------------*
46       CHECK EXITFLAG EQ SPACE.
47
48       CASE LEERFLG.
49         WHEN 'X'.
50     *- Keine markierte Zeile gefunden - Prüfen auf Line-Selection ---------*
51           IF HIDE-INDEX NE 0.
52             READ TABLE BAN INDEX HIDE-INDEX.
53             IF BAN-MATNR EQ SPACE.
54               MESSAGE S209.
55               CLEAR HIDE-INDEX.
56               EXIT.
57             ENDIF.
58             INDEX_BAN = SY-TABIX.
59     *- Aufruf Report ------------------------------------------------------*
60             PERFORM AUFRUF_MATERIALNUMMER.
61             CHECK EXITFLAG EQ SPACE.
62             PERFORM BAN_UPDATE_RAHM.
63             EXIT.
64           ELSE.
65     *- Keine markierte Banf - Meldung: zuerst markieren -------------------*
66             MESSAGE S222.
67             EXIT.
68           ENDIF.
69     *- Keine markierte Banf mit Material - Meldung: Pos. mit Material sel.-*
70         WHEN 'Y'.
71           MESSAGE S209.
72           EXIT.
73       ENDCASE.
74
75     *- Aufruf Report für die markierten -----------------------------------*
76       READ TABLE BAN INDEX INDEX_BAN.
77       PERFORM AUFRUF_MATERIALNUMMER.
78       CHECK EXITFLAG EQ SPACE.
79     *- Modifizieren der Listzeilen mit zugeordnetem Rahmenvertrag ---------*
80       LOOP AT BAN WHERE SELKZ EQ 'X'.
81         INDEX_BAN = SY-TABIX.
82         PERFORM BAN_UPDATE_RAHM.
83       ENDLOOP.
84
85       CLEAR HIDE-INDEX.
86
87     ENDFORM.
*--- End of FM06BF02_UCOMM_LRAM - 87 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF02_UCOMM_LUAE                       Level 2    Page 59
Object           SAPMZFM06B                                Lines 36
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *     Ändern Listumfang
4      *----------------------------------------------------------------------*
5      FORM UCOMM_LUAE.
6        DATA: SLSTUB LIKE T16LB-LSTUB.
7        DATA: SDYNPR LIKE T16LB-DYNPR.
8        CHECK LISTE EQ 'G'.
9        SLSTUB = COM-LSTUB.
10       SDYNPR = T16LB-DYNPR.
11       T16LL-LSTUB = COM-LSTUB.
12       CLEAR REJECT.
13       CALL SCREEN 105 STARTING AT 5 6
14                       ENDING   AT 35 8.
15       IF REJECT NE SPACE.
16         COM-LSTUB = SLSTUB.
17         EXIT.
18       ENDIF.
19       IF COM-LSTUB NE SLSTUB.
20         PERFORM XT16LL_AUFBAUEN.
21         SY-LSIND = 0.
22         IF T16LB-DYNPR EQ 0.
23           PERFORM BAN_ZEILEN.
24         ELSE.
25     *- Listumfang mehrfach geändert ---------------------------------------*
26           IF XCALLD EQ 'X'.
27             IF SDYNPR EQ 0.
28               XCALLD = 'Z'.
29             ELSE.
30               XCALLD = 'Y'.
31             ENDIF.
32           ENDIF.
33           PERFORM BAN_DYNP_CALL.
34         ENDIF.
35       ENDIF.
36     ENDFORM.
*--- End of FM06BF02_UCOMM_LUAE - 36 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF02_UCOMM_ORDB                       Level 2    Page 60
Object           SAPMZFM06B                                Lines 55
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *        Zuordnen nach Orderbuch                                       *
4      *----------------------------------------------------------------------*
5      FORM UCOMM_ORDB.
6
7        DATA: MSG_FLAG.
8
9        CHECK SY-PFKEY EQ 'BEAR' OR
10             SY-PFKEY EQ 'ZUOR' OR
11             SY-PFKEY EQ 'DBEA' OR
12             SY-PFKEY EQ 'DZUO'.
13
14       LEERFLG = 'X'.
15
16     *- Suchen einer markierten Position -----------------------------------*
17       LOOP AT BAN WHERE SELKZ EQ 'X'.
18         CLEAR LEERFLG.
19         INDEX_BAN = SY-TABIX.
20     *- Suchen einer gültigen Bezugsquelle ---------------------------------*
21         PERFORM BEZUGSQUELLE_3.
22         IF MSG_FLAG EQ SPACE AND BAN-RESWK EQ SPACE AND BAN-FLIEF EQ SPACE
23            AND BAN-BESWK EQ SPACE " CCP
24            AND BAN-KONNR EQ SPACE.
25           MESSAGE S577(06).                "nicht zu allen was gefunden
26           MSG_FLAG = 'X'.
27         ENDIF.
28         PERFORM BAN_UPDATE_ORDR.
29       ENDLOOP.
30
31       IF LEERFLG NE SPACE.
32     *- Keine markierte Zeile gefunden - Prüfen auf Line-Selection ---------*
33         IF HIDE-INDEX NE 0.
34           READ TABLE BAN INDEX HIDE-INDEX.
35           INDEX_BAN = SY-TABIX.
36     *- Suchen einer gültigen Bezugsquelle ---------------------------------*
37           PERFORM BEZUGSQUELLE_3.
38           PERFORM BAN_UPDATE_ORDR.
39           IF NOT_ALL_ORDB NE SPACE.
40             MESSAGE S553(06).
41           ENDIF.
42         ELSE.
43     *- Funktion konnte für keine Zeile ausgeführt werden - vorher markieren*
44           MESSAGE S222.
45           EXIT.
46         ENDIF.
47       ELSE.
48         IF NOT_ALL_ORDB NE SPACE.
49           MESSAGE S551(06).
50         ENDIF.
51       ENDIF.
52
53       CLEAR NOT_ALL_ORDB.
54
55     ENDFORM.
*--- End of FM06BF02_UCOMM_ORDB - 55 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF02_UCOMM_ORDM                       Level 2    Page 61
Object           SAPMZFM06B                                Lines 61
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *        Bezugsquelle manuell zuordnen                                 *
4      *----------------------------------------------------------------------*
5      FORM UCOMM_ORDM.
6
7        CHECK SY-PFKEY EQ 'BEAR' OR
8              SY-PFKEY EQ 'ZUOR' OR
9              SY-PFKEY EQ 'DBEA' OR
10             SY-PFKEY EQ 'DZUO'.
11
12       LEERFLG = 'X'.
13       CLEAR REJECT.
14       CLEAR EBAN.                                               "161369
15     *-SUCHEN EINER MARKIERTEN POSITION ------------------------------------*
16       LOOP AT BAN WHERE SELKZ EQ 'X'.
17         CLEAR LEERFLG.
18         CLEAR REJECT.
19         INDEX_BAN = SY-TABIX.
20     * das Füllen der BAN-Felder nicht mehr mit den Eingaben aus Dynpro 0104
21     * erfolgt in FORM BEZUGSQUELLE_MANUELL
22     * Position neu durchlaufen.                                 "161369
23     *   IF EBAN-MATKL EQ BAN-MATKL OR                           "161369
24     *      EBAN-MATNR EQ BAN-MATNR.                             "161369
25     *     IF EBAN-KONNR NE SPACE OR                             "161369
26     *        EBAN-FLIEF NE SPACE OR                             "161369
27     *        EBAN-INFNR NE SPACE OR                             "161369
28     *        EBAN-RESWK NE SPACE.                               "161369
29     *       BAN-KONNR = EBAN-KONNR.                             "161369
30     *       BAN-KTPNR = EBAN-KTPNR.                             "161369
31     *       BAN-FLIEF = EBAN-FLIEF.                             "161369
32     *       BAN-INFNR = EBAN-INFNR.                             "161369
33     *       BAN-EKORG = EBAN-EKORG.                             "161369
34     *       IF BAN-PSTYP EQ PSTYP-UMLG.                         "161369
35     *         BAN-RESWK = EBAN-RESWK.                           "161369
36     *       ENDIF.                                              "161369
37     *     ENDIF.                                                "161369
38     *   ENDIF.                                                  "161369
39         PERFORM BEZUGSQUELLE_MANUELL.
40     *- Sonderzeile in Liste aufbauen --------------------------------------*
41         CHECK REJECT EQ SPACE.
42         PERFORM BAN_UPDATE_ORDR.
43       ENDLOOP.
44
45       IF LEERFLG NE SPACE.
46     *- Keine markierte Zeile gefunden - Prüfen auf Line-Selection ---------*
47         IF HIDE-INDEX NE 0.
48           READ TABLE BAN INDEX HIDE-INDEX.
49           INDEX_BAN = HIDE-INDEX.
50           PERFORM BEZUGSQUELLE_MANUELL.
51     *- Sonderzeile in Liste aufbauen --------------------------------------*
52           CHECK REJECT EQ SPACE.
53           PERFORM BAN_UPDATE_ORDR.
54         ELSE.
55     *- Funktion konnte für keine Zeile ausgeführt werden - vorher markieren*
56           MESSAGE S222.
57           EXIT.
58         ENDIF.
59       ENDIF.
60
61     ENDFORM.
*--- End of FM06BF02_UCOMM_ORDM - 61 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF02_UCOMM_SORT                       Level 2    Page 62
Object           SAPMZFM06B                                Lines 56
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *        Sortkennzeichen setzen                                        *
4      *----------------------------------------------------------------------*
5      FORM UCOMM_SORT.
6
7        CHECK LISTE EQ 'G'.
8
9        CASE SY-UCOMM.
10         WHEN 'SRT1'.
11           CHECK COM-SRTKZ NE 1.
12           COM-SRTKZ = 1.                   "nach Banfn/Bnfpo/Matnr/Lfdat
13         WHEN 'SRT2'.
14           CHECK COM-SRTKZ NE 2.
15           COM-SRTKZ = 2.                   "nach Ekgrp/Matnr/Werks
16         WHEN 'SRT3'.
17           CHECK COM-SRTKZ NE 3.
18           COM-SRTKZ = 3.                   "nach Bednr/Ekgrp/Werks
19         WHEN 'SRT4'.
20           CHECK COM-SRTKZ NE 4.
21           COM-SRTKZ = 4.                   "nach Frgdt
22         WHEN 'SRT5'.
23           CHECK COM-SRTKZ NE 5.
24           COM-SRTKZ = 5.                   "nach Matkl
25         WHEN 'SRT6'.
26           CHECK COM-SRTKZ NE 6.
27           COM-SRTKZ = 6.                   "nach Werks/Dispo
28         WHEN 'SRT7'.
29           CHECK COM-SRTKZ NE 7.
30           COM-SRTKZ = 7.                   "nach Material
31         WHEN 'SRT8'.
32           CHECK COM-SRTKZ NE 8.
33           COM-SRTKZ = 8.                   "nach Kontierung
34         WHEN 'SRT9'.
35           CHECK COM-SRTKZ NE 9.
36           COM-SRTKZ = 9.                   "nach Bezugsquelle
37         WHEN OTHERS.
38     ENHANCEMENT-SECTION     FM06BF02_UCOMM_SORT_01 SPOTS ES_SAPFM06B.
39           EXIT.
40     END-ENHANCEMENT-SECTION.
41       ENDCASE.
42
43       SY-LSIND = 0.
44       PERFORM BAN_SORT.
45       IF T16LB-DYNPR EQ 0.
46         PERFORM BAN_ZEILEN.
47       ELSE.
48         CLEAR: B-AKTIND, B-LOPIND, B-MAXIND, B-PAGIND, B-LESIND.
49         DESCRIBE TABLE BAN LINES B-MAXIND.
50         IF xcalld EQ 'X'.
51           xcalld = 'Y'.
52         ENDIF.
53         PERFORM ban_dynp_call.
54       ENDIF.
55
56     ENDFORM.
*--- End of FM06BF02_UCOMM_SORT - 56 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF02_UCOMM_ZANZ                       Level 2    Page 63
Object           SAPMZFM06B                                Lines 20
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *    Anzeigen Zuordnung
4      *----------------------------------------------------------------------*
5      FORM UCOMM_ZANZ.
6
7        CHECK LISTE EQ 'G'.
8
9      *-- Listyp suchen, aktuellen Listtyp merken ---------------------------*
10       PERFORM LISTE_MERKEN USING 'Z'.
11     *-- Liste aufbauen ----------------------------------------------------*
12       LISTE = 'Z'.
13       COM-SRTKZ = '9'.
14       CLEAR DET.
15       SET PF-STATUS ZPFKEY.
16       SET TITLEBAR ZFMKEY.
17       SY-LSIND = 0.
18       PERFORM ZUG_ZEILEN.
19
20     ENDFORM.
*--- End of FM06BF02_UCOMM_ZANZ - 20 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF02_UCOMM_ZBEA                       Level 2    Page 64
Object           SAPMZFM06B                                Lines 20
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *    Bearbeiten Zuordnung
4      *----------------------------------------------------------------------*
5      FORM UCOMM_ZBEA.
6
7        CHECK SY-PFKEY EQ 'ZALL' OR
8              SY-PFKEY EQ 'ZBST'.
9
10       IF S-FIRSTIND EQ 0 OR
11          ZUG-UPDKZ EQ ZNIX OR
12          ZUG-UPDKZ EQ ZRES.
13         MESSAGE S201.
14         EXIT.
15       ENDIF.
16
17       PERFORM ZUG_BEARBEITEN.
18       PERFORM ZUG_CLEAR.
19
20     ENDFORM.
*--- End of FM06BF02_UCOMM_ZBEA - 20 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF02_UCOMM_ZBUP                       Level 2    Page 65
Object           SAPMZFM06B                                Lines 19
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *    Ändern Bestellanforderungen
4      *----------------------------------------------------------------------*
5      FORM UCOMM_ZBUP.
6
7        CHECK SY-PFKEY EQ 'ZALL' OR
8              SY-PFKEY EQ 'ZBUB'.
9        IF S-FIRSTIND EQ 0 OR
10          ZUG-UPDKZ EQ ANFR OR
11          ZUG-UPDKZ EQ ALIF.
12         MESSAGE S201.
13         EXIT.
14       ENDIF.
15
16       PERFORM ZUG_AENDERN.
17       PERFORM ZUG_CLEAR.
18
19     ENDFORM.
*--- End of FM06BF02_UCOMM_ZBUP - 19 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF02_UCOMM_ZLIS                       Level 2    Page 66
Object           SAPMZFM06B                                Lines 57
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *    Banfliste zur Zuordnungszeile
4      *----------------------------------------------------------------------*
5      FORM UCOMM_ZLIS.
6
7        CHECK LISTE EQ 'Z'.
8
9        IF S-FIRSTIND EQ 0.
10         MESSAGE S201.
11         EXIT.
12       ENDIF.
13
14       PERFORM LISTE_MERKEN USING 'X'.
15       LISTE = 'G'.
16       COM-SRTKZ = '9'.
17       READ TABLE BAN INDEX S-FIRSTIND.
18       IF BAN-UPDK1 EQ ALIF.
19         DATA: LPFKEY LIKE SY-PFKEY.
20         LPFKEY = 'BDET'.
21         SET PF-STATUS LPFKEY EXCLUDING EXCL.
22       ELSE.
23         SET PF-STATUS GPFKEY EXCLUDING EXCL.
24       ENDIF.
25       SET TITLEBAR  GFMKEY.
26       CLEAR DET.
27       DET-UPDKZ = BAN-UPDK1.
28       DET-BSART = BAN-BSART.
29       IF DET-UPDKZ EQ ALIF.
30         DET-EKORG = BAN-EKORG.
31         DET-SLIEF = BAN-SLIEF.
32         DET-BUKRS = BAN-BUKRS.
33       ELSE.
34         IF DET-UPDKZ EQ ANFR.
35           DET-EKORG = BAN-EKORG.
36           DET-BUKRS = BAN-BUKRS.
37         ELSE.
38           DET-UPDKZ = 'XX'.
39           DET-EKORG = BAN-EKORG.
40           DET-SLIEF = BAN-SLIEF.
41           DET-RESWK = BAN-RESWK.
42           DET-BESWK = BAN-BESWK. " CCP
43           DET-KONNR = BAN-KONNR.
44           DET-FORDN = BAN-FORDN.
45           DET-BUKRS = BAN-BUKRS.
46         ENDIF.
47       ENDIF.
48       SY-LSIND = 0.
49       PERFORM ZUG_CLEAR.
50       PERFORM BAN_SORT.
51       IF T16LB-DYNPR EQ 0.
52         PERFORM BAN_ZEILEN.
53       ELSE.
54         PERFORM BAN_DYNP_CALL.
55       ENDIF.
56
57     ENDFORM.
*--- End of FM06BF02_UCOMM_ZLIS - 57 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF02_UCOMM_GLIS                       Level 2    Page 67
Object           SAPMZFM06B                                Lines 24
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *    Gesamt-Banfliste aus Zuordnungen
4      *----------------------------------------------------------------------*
5      FORM UCOMM_GLIS.
6
7        CHECK LISTE EQ 'Z'.
8
9        PERFORM LISTE_MERKEN USING 'G'.
10       LISTE = 'G'.
11       COM-SRTKZ = '1'.
12       SET PF-STATUS GPFKEY EXCLUDING EXCL.
13       SET TITLEBAR  GFMKEY.
14       CLEAR DET.
15       SY-LSIND = 0.
16       PERFORM ZUG_CLEAR.
17       PERFORM BAN_SORT.
18       IF T16LB-DYNPR EQ 0.
19         PERFORM BAN_ZEILEN.
20       ELSE.
21         PERFORM BAN_DYNP_CALL.
22       ENDIF.
23
24     ENDFORM.
*--- End of FM06BF02_UCOMM_GLIS - 24 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF02_UCOMM_GBUP                       Level 2    Page 68
Object           SAPMZFM06B                                Lines 12
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *    Ändern Banfs aus Grundliste
4      *----------------------------------------------------------------------*
5      FORM UCOMM_GBUP.
6
7        CHECK LISTE EQ 'G'.
8        CHECK SY-PFKEY EQ 'ZUOR' OR
9              SY-PFKEY EQ 'BEAR'.
10       PERFORM BAN_AENDERN.
11
12     ENDFORM.
*--- End of FM06BF02_UCOMM_GBUP - 12 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF02_UCOMM_ZRES                       Level 2    Page 69
Object           SAPMZFM06B                                Lines 35
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *   Zuordnung rücksetzen
4      *----------------------------------------------------------------------*
5      FORM UCOMM_ZRES.
6
7        CHECK SY-PFKEY EQ 'ZUOR' OR
8              SY-PFKEY EQ 'BEAR' OR
9              SY-PFKEY EQ 'BDET' OR
10             SY-PFKEY EQ 'DBDE' OR
11             SY-PFKEY EQ 'DBEA' OR
12             SY-PFKEY EQ 'DZUO'.
13       LEERFLG = 'X'.
14
15     *- Suchen markierte Zeilen --------------------------------------------*
16       LOOP AT BAN WHERE SELKZ EQ 'X'.
17         CLEAR LEERFLG.
18         INDEX_BAN = SY-TABIX.
19         PERFORM BAN_UPDATE_ZRES.
20       ENDLOOP.
21
22       IF LEERFLG NE SPACE.
23     *- Keine markierte Zeile gefunden - Prüfen auf Line-Selection ---------*
24         IF HIDE-INDEX NE 0.
25           READ TABLE BAN INDEX HIDE-INDEX.
26           INDEX_BAN = SY-TABIX.
27           PERFORM BAN_UPDATE_ZRES.
28         ELSE.
29     *- Funktion konnte für keine Zeile ausgeführt werden - vorher markieren*
30           MESSAGE S222.
31           EXIT.
32         ENDIF.
33       ENDIF.
34
35     ENDFORM.
*--- End of FM06BF02_UCOMM_ZRES - 35 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF02_UCOMM_ZURU                       Level 2    Page 70
Object           SAPMZFM06B                                Lines 61
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *        Zurück                                                        *
4      *----------------------------------------------------------------------*
5      FORM UCOMM_ZURU.
6
7      *- Ausflug (Konsiliste): 1 Liststufe zurück ---------------------------*
8        IF SY-PFKEY EQ 'KONS' OR
9           SY-PFKEY EQ 'KONA'.
10         IF T16LB-DYNPR EQ 0.
11           SY-LSIND = 0.
12           EXIT.
13         ELSE.
14           LEAVE.
15         ENDIF.
16       ENDIF.
17     *- Grundliste: Bearbeitung beenden ------------------------------------*
18       IF S0LISTE EQ SPACE.
19         PERFORM UCOMM_ENDE.
20       ELSE.
21     *- 2. oder 3. Liste: Eine Liste zurück---------------------------------*
22         SY-LSIND = 0.
23         CLEAR ZUG.
24     *- Daten aus letzter Liststufe setzen ---------------------------------*
25         IF S1LISTE NE SPACE.
26           LISTE = S1LISTE.
27           COM-SRTKZ = S1SRTKZ.
28           DET = S1DET.
29           CLEAR: S1LISTE,
30                  S1SRTKZ,
31                  S1DET.
32         ELSE.
33           LISTE = S0LISTE.
34           COM-SRTKZ = S0SRTKZ.
35           CLEAR DET.
36           CLEAR: S0LISTE,
37                  S0SRTKZ.
38         ENDIF.
39     *- Mehrfachzuordnung Anfrage entfernen --------------------------------*
40         LOOP AT BAN WHERE UPDK2 EQ AMAN.
41           DELETE BAN.
42         ENDLOOP.
43
44         IF LISTE EQ 'G'.
45           SET PF-STATUS GPFKEY EXCLUDING EXCL.
46           SET TITLEBAR  GFMKEY.
47           PERFORM BAN_SORT.
48           IF T16LB-DYNPR EQ 0.
49             PERFORM BAN_ZEILEN.
50             SCROLL LIST INDEX 1 TO FIRST PAGE LINE LI_STARO.
51           ELSE.
52             LEAVE.
53           ENDIF.
54         ELSE.
55           SET PF-STATUS ZPFKEY.
56           SET TITLEBAR  ZFMKEY.
57           PERFORM ZUG_ZEILEN.
58         ENDIF.
59       ENDIF.
60
61     ENDFORM.
*--- End of FM06BF02_UCOMM_ZURU - 61 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF02_LISTE_MERKEN                     Level 2    Page 71
Object           SAPMZFM06B                                Lines 40
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      * Listtyp suchen in Sicherungsfelder und aktuellen Listtyp merken      *
4      *----------------------------------------------------------------------*
5      FORM LISTE_MERKEN USING LIM_LISTE.
6
7      *- Listtyp schon mal aufgerufen -> zurück -----------------------------*
8        IF S0LISTE EQ LIM_LISTE OR
9           S1LISTE EQ LIM_LISTE.
10     *- Listtyp in Grundliste ----------------------------------------------*
11         IF S0LISTE EQ LIM_LISTE.
12           COM-SRTKZ = S0SRTKZ.
13           CLEAR DET.
14           CLEAR: S0LISTE,
15                  S0SRTKZ,
16                  S1LISTE,
17                  S1SRTKZ,
18                  S1DET.
19     *- Listtyp in zweiter Liststufe ---------------------------------------*
20         ELSE.
21           COM-SRTKZ = S1SRTKZ.
22           DET = S1DET.
23           CLEAR: S1LISTE,
24                  S1SRTKZ,
25                  S1DET.
26         ENDIF.
27     *- Listtyp neu -> alten Listtyp merken --------------------------------*
28       ELSE.
29     *- Grundliste ---------------------------------------------------------*
30         IF S0LISTE EQ SPACE.
31           S0LISTE = LISTE.
32           S0SRTKZ = COM-SRTKZ.
33     *- 2. Liststufe -------------------------------------------------------*
34         ELSE.
35           S1LISTE = LISTE.
36           S1SRTKZ = COM-SRTKZ.
37           S1DET   = DET.
38         ENDIF.
39       ENDIF.
40     ENDFORM.
*--- End of FM06BF02_LISTE_MERKEN - 40 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF02_SELKZ_INPUT                      Level 2    Page 72
Object           SAPMZFM06B                                Lines 49
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      * Explizite Eingabe des Selektionskennezeichens übernehmen             *
4      *----------------------------------------------------------------------*
5      FORM SELKZ_INPUT.
6
7        DATA: SHIDE-INDEX LIKE SY-TABIX.
8        DATA: SHIDE-GSFRG LIKE BAN-GSFRG.
9        CHECK LISTE EQ 'G'.
10       CHECK T16LB-DYNPR EQ 0.
11       CHECK XSZTYP NE SPACE.
12       CHECK T16LH-XMKEX NE SPACE.
13
14     *... Hide-Felder der Cursorposition sichern, da sogleich ein .........*
15     *... 'read line ...' folgt ! .........................................*
16       SHIDE-INDEX = HIDE-INDEX.
17       SHIDE-GSFRG = HIDE-GSFRG.
18
19       CLEAR: SAVE_BANF, SAVE_SELKZ.
20       LOOP AT BAN.
21         IF BAN-BANFN EQ SAVE_BANF AND
22            SAVE_SELKZ NE BAN-SELKZ AND NOT GS_BANF IS INITIAL.
23     *... Bei Gesamtbanf alle Positionen markieren ........................*
24           BAN-SELKZ = SAVE_SELKZ.
25           MODIFY BAN.
26         ELSE.
27           READ LINE BAN-SZEIL OF PAGE BAN-PAGE INDEX LSIND.
28           CHECK SY-SUBRC EQ 0.
29           PERFORM DET_CHECK.
30           CHECK SY-SUBRC EQ 0.
31           IF SY-LISEL+1(1) NE BAN-SELKZ.
32             BAN-SELKZ = SY-LISEL+1(1).
33             MODIFY BAN.
34             IF NOT BAN-GSFRG IS INITIAL AND NOT GS_BANF IS INITIAL.
35     *... Bei Gesamtbanf alle Positionen markieren ........................*
36               SAVE_BANF = BAN-BANFN.
37               SAVE_SELKZ = SY-LISEL+1(1).
38             ELSE.
39               CLEAR: SAVE_BANF, SAVE_SELKZ.
40             ENDIF.
41           ENDIF.
42         ENDIF.
43       ENDLOOP.
44     *... Hide-Felder der Cursor-Position wieder setzen ...................*
45       HIDE-INDEX = SHIDE-INDEX.
46       HIDE-GSFRG = SHIDE-GSFRG.
47       LI_STARO = SY-STARO.
48
49     ENDFORM.
*--- End of FM06BF02_SELKZ_INPUT - 49 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF02_USER_COMMAND                     Level 2    Page 73
Object           SAPMZFM06B                                Lines 162
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *   User-Commands auswerten
4      *----------------------------------------------------------------------*
5      FORM USER_COMMAND.
6
7      *- tatsächliche Liststufe merken, da auch bei 'AT USER-COMMAND' eins --*
8      *- hochgezählt wird ---------------------------------------------------*
9        LSIND = SY-LSIND - 1.
10       IF LSIND LT 0.
11         LSIND = 0.
12       ENDIF.
13     *- Eingabe Selektionskennzeichen --------------------------------------*
14       PERFORM SELKZ_INPUT.
15
16     *- Liste sortieren ----------------------------------------------------*
17       PERFORM UCOMM_SORT.
18
19       CASE SY-UCOMM.
20     *- Nochmal markieren --------------------------------------------------*
21         WHEN 'MAKT'.
22           PERFORM UCOMM_MAKT.
23     *- Alle markieren -----------------------------------------------------*
24         WHEN 'MALL'.
25           PERFORM UCOMM_MALL.
26     *- Einzelzeile markieren ----------------------------------------------*
27         WHEN 'MARK'.
28           PERFORM UCOMM_MARK.
29     *- Alle Markierungen löschen ------------------------------------------*
30         WHEN 'MDEL'.
31           PERFORM UCOMM_MDEL.
32     *- Markieren Intervall ------------------------------------------------*
33         WHEN 'MINT'.
34           PERFORM UCOMM_MINT.
35     *- Anzeigen Änderungen ------------------------------------------------*
36         WHEN 'AEND'.
37           PERFORM UCOMM_AEND.
38     *- Anzeigen Bestellungen ----------------------------------------------*
39         WHEN 'BEST'.
40           PERFORM UCOMM_BEST.
41     *- Anzeigen Freigabestrategie -----------------------------------------*
42         WHEN 'FRST'.
43           PERFORM UCOMM_FRST.
44     *- Auswählen Bestellanforderung ---------------------------------------*
45         WHEN 'AUSW'.
46           PERFORM UCOMM_AUSW.
47     *- Anzeigen Material --------------------------------------------------*
48         WHEN 'MATN'.
49           PERFORM UCOMM_MATN.
50     *- Anzeigen Beleg -----------------------------------------------------*
51         WHEN 'HICK'.
52           PERFORM UCOMM_HICK.
53     *- Auswählen Konsilieferant -------------------------------------------*
54         WHEN 'KICK'.
55           PERFORM UCOMM_KICK.
56     *- springen in Dienstleistungspaket
57         WHEN 'DIEN'.
58           LEERFLG = 'X'.
59           LOOP AT BAN WHERE SELKZ EQ 'X'.
60             CLEAR LEERFLG.
61             BAN-SELKZ = '*'.
62             MODIFY BAN.
63             PERFORM READ_SERVICES(SAPFM06L) USING BAN-PACKNO BAN-BANFN
64                                                   BAN-BNFPO.
65             PERFORM SEL_KENNZEICHNEN.
66             EXIT.
67           ENDLOOP.
68           IF LEERFLG EQ 'X'.
69             IF HIDE-INDEX NE 0.
70               READ TABLE BAN INDEX HIDE-INDEX.
71               PERFORM READ_SERVICES(SAPFM06L) USING BAN-PACKNO
72                                                     BAN-BANFN BAN-BNFPO.
73               PERFORM SEL_KENNZEICHNEN.
74               EXIT.
75             ENDIF.
76           ENDIF.
77     *- Zurück -------------------------------------------------------------*
78         WHEN 'ZURU'.
79           PERFORM UCOMM_ZURU.
80     *- Beenden ------------------------------------------------------------*
81         WHEN 'EN  '.
82           PERFORM UCOMM_ENDE.
83     *- Abbrechen ----------------------------------------------------------*
84         WHEN 'XIT '.
85           PERFORM UCOMM_ZURU.
86     *- Vormerken für Anfragebearbeitung einfach ---------------------------*
87         WHEN 'ANFR'.
88           PERFORM UCOMM_ANFR.
89     *- Vormerken für Anfragebearbeitung mehrfach --------------------------*
90         WHEN 'ANFL'.
91           PERFORM UCOMM_ANFL.
92     *- Buchen Freigabe ----------------------------------------------------*
93         WHEN 'BU  '.
94           PERFORM UCOMM_BUFR.
95     *- In Einzelfreigabe verzweigen ---------------------------------------*
96         WHEN 'ME54'.
97           PERFORM UCOMM_ME54.
98     *- Eine Zeile zuordnen über Orderbuch ---------------------------------*
99         WHEN 'ORDB'.
100          PERFORM UCOMM_ORDB.
101    *- Eine Zeile manuell zuordnen  ---------------------------------------*
102        WHEN 'ORDM'.
103          PERFORM UCOMM_ORDM.
104    *- Übersicht Zuordnungen ansteuern ------------------------------------*
105        WHEN 'ZANZ'.
106          PERFORM UCOMM_ZANZ.
107    *- Zuordnung zurücknehmen ---------------------------------------------*
108        WHEN 'ZRES'.
109          PERFORM UCOMM_ZRES.
110    *- Zugeordnete bearbeiten ---------------------------------------------*
111        WHEN 'ZBEA'.
112          PERFORM UCOMM_ZBEA.
113    *- Banfs ändern -------------------------------------------------------*
114        WHEN 'ZBUP'.
115          PERFORM UCOMM_ZBUP.
116    *- Anzeigen Infosätze zum Material ------------------------------------*
117        WHEN 'LINF'.
118          PERFORM UCOMM_LINF.
119    *- Anzeigen Konsilieferanten ------------------------------------------*
120        WHEN 'LKON'.
121          PERFORM UCOMM_LKON.
122    *- Anzeigen Rahmenverträge zur Materialklasse -------------------------*
123        WHEN 'LRAC'.
124          PERFORM UCOMM_LRAC.
125    *- Anzeigen Rahmenverträge zum Material -------------------------------*
126        WHEN 'LRAM'.
127          PERFORM UCOMM_LRAM.
128    *- Anzeigen Lieferantenbeurteilungen ----------------------------------*
129        WHEN 'LIBE'.
130          PERFORM UCOMM_LIBE.
131    *- Banfs zur Zuordnungszeile ------------------------------------------*
132        WHEN 'ZLIS'.
133          PERFORM UCOMM_ZLIS.
134    *- Gesamtliste Banfs --------------------------------------------------*
135        WHEN 'GLIS'.
136          PERFORM UCOMM_GLIS.
137    *- Ändern Listumfang --------------------------------------------------*
138        WHEN 'LUAE'.
139          PERFORM UCOMM_LUAE.
140    *- Arbeitsvorrat aktualisieren ----------------------------------------*
141        WHEN 'AAKT'.
142          PERFORM UCOMM_AAKT.
143    *- Sichern Banf aus Grundliste ----------------------------------------*
144        WHEN 'GBUP'.
145          PERFORM UCOMM_GBUP.
146    *- Detail zur Banf ----------------------------------------------------*
147        WHEN 'DETA'.
148          PERFORM UCOMM_DETA.
149    *- Bestandsübersicht --------------------------------------------------*
150        WHEN 'MMBE'.
151          PERFORM UCOMM_MMBE.
152    *- Bestands-/Bedarfs-Situation-----------------------------------------*
153        WHEN 'MD04'.
154          PERFORM UCOMM_MD04.
155    *-- Note 739690
156    *- Accounting Errors - Log
157        WHEN 'LOG1'.
158          PERFORM UCOMM_LOG1.
159    *-- Note 739690
160      ENDCASE.
161      CLEAR HIDE-INDEX.
162    ENDFORM.
*--- End of FM06BF02_USER_COMMAND - 162 lines ---

----------------------------------------------------------------------------------------------------
Include          MZFM06BF03                                Level 1    Page 74
Object           SAPMZFM06B                                Lines 39
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1        INCLUDE FM06BF03_AUFRUF_AENDERUNGEN .  " AUFRUF_AENDERUNGEN
2
3        INCLUDE FM06BF03_AUFRUF_BESTELLUNGEN .  " AUFRUF_BESTELLUNGEN
4
5        INCLUDE FM06BF03_AUFRUF_EINZELFREIGABE .  " AUFRUF_EINZELFREIGABE
6
7        INCLUDE FM06BF03_AUFRUF_MATERIALKLASSE .  " AUFRUF_MATERIALKLASSE
8
9        INCLUDE FM06BF03_AUFRUF_MATERIALNUMMER .  " AUFRUF_MATERIALNUMMER
10
11       INCLUDE FM06BF03_AUFRUF_INFOSAETZE .  " AUFRUF_INFOSAETZE
12
13       INCLUDE FM06BF03_AUFRUF_LIBE .  " AUFRUF_LIBE
14
15       INCLUDE FM06BF03_BAN_MODIF_ZEILE .  " BAN_MODIF_ZEILE
16
17       INCLUDE FM06BF03_BAN_UPDATE_ALIF .  " BAN_UPDATE_ALIF
18
19       INCLUDE FM06BF03_BAN_UPDATE_ANFL .  " BAN_UPDATE_ANFL
20
21       INCLUDE FM06BF03_BAN_UPDATE_ANFR .  " BAN_UPDATE_ANFR
22
23       INCLUDE FM06BF03_BAN_UPDATE_KICK .  " BAN_UPDATE_KICK
24
25       INCLUDE FM06BF03_BAN_UPDATE_LINF .  " BAN_UPDATE_LINF
26
27       INCLUDE FM06BF03_BAN_UPDATE_ORDR .  " BAN_UPDATE_ORDR
28
29       INCLUDE FM06BF03_BAN_UPDATE_RAHM .  " BAN_UPDATE_RAHM
30
31       INCLUDE FM06BF03_BAN_UPDATE_ZRES .  " BAN_UPDATE_ZRES
32
33       INCLUDE FM06BF03_FREIGABE_SETZEN .  " FREIGABE_SETZEN
34
35       INCLUDE FM06BF03_SEL_KENNZEICHNEN .  " SEL_KENNZEICHNEN
36
37       INCLUDE FM06BF03_VERLASSEN_LISTE .  " VERLASSEN_LISTE
38
39       INCLUDE FM06BF03_WARNING_UPDK3 .  " WARNING_UPDK3
*--- End of MZFM06BF03 - 39 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF03_AUFRUF_AENDERUNGEN               Level 2    Page 75
Object           SAPMZFM06B                                Lines 37
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      ************************************************************************
2      *   Unterroutinen für die interaktive Bearbeitung der Grundliste       *
3      ************************************************************************
4      * 17.12.97 SM H91102  ME56 nicht batchinputfähig
5      * 12.01.98 SM H92315  call transaction
6      * 24.02.98 SM H96482  Änderungen aus Einzelfreigabe
7      * 96597 25.02.98 40B PH Warengruppe wurde initialisiert nach Zuordnung
8      *eject
9      *----------------------------------------------------------------------*
10     *        Aufruf Anzeigen Änderungen                                    *
11     *----------------------------------------------------------------------*
12     FORM AUFRUF_AENDERUNGEN.
13
14     *- Zurücksetzen Änderungstabellen -------------------------------------*
15       REFRESH: ICDHDR, AUSG, EDIT.
16       CLEAR:   ICDHDR, AUSG, EDIT.
17
18     *- DCM  call ALV list
19       IF NOT GS_BANF IS INITIAL AND
20          NOT BAN-GSFRG IS INITIAL AND
21          NOT HIDE-GSFRG IS INITIAL.
22     *...Bei Gesamtbanf alle Änderungen zur Banf anzeigen, falls die .....*
23     *...'Kopfzeile' selektiert wurde ....................................*
24         CALL FUNCTION 'ME_CHANGEDOC_SHOW'
25           EXPORTING
26             i_document_category = 'B'
27             i_document_number   = ban-banfn
28             I_ALL_ITEMS         = 'X'.
29       ELSE.
30         CALL FUNCTION 'ME_CHANGEDOC_SHOW'
31           EXPORTING
32             i_document_category = 'B'
33             i_document_number   = ban-banfn
34             i_document_item     = ban-bnfpo.
35       ENDIF.
36
37     ENDFORM.                    "AUFRUF_AENDERUNGEN
*--- End of FM06BF03_AUFRUF_AENDERUNGEN - 37 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF03_AUFRUF_BESTELLUNGEN              Level 2    Page 76
Object           SAPMZFM06B                                Lines 27
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *        Aufruf Anzeigen Bestellungen                                  *
4      *----------------------------------------------------------------------*
5      FORM AUFRUF_BESTELLUNGEN.
6
7        CLEAR EXITFLAG.
8      *- Sind überhaupt Bestellungen vorhanden? -----------------------------*
9        IF BAN-BSMNG EQ 0.
10         MESSAGE S229 WITH BAN-BNFPO.
11         EXITFLAG = 'X'.
12         EXIT.
13       ENDIF.
14     *- Aufruf Report ------------------------------------------------------*
15       IF NOT BAN-GSFRG IS INITIAL AND
16          NOT GS_BANF IS INITIAL   AND
17          NOT HIDE-GSFRG IS INITIAL.
18     *... Auf das Positionsübersichtsbild verzweigen, falls die ...........*
19     *... 'Kopfzeile' selektiert wurde ....................................*
20         SUBMIT RM06EE00 AND RETURN
21                WITH P_BANFN = BAN-BANFN.
22       ELSE.
23         SUBMIT RM06EE00 AND RETURN
24                WITH P_BANFN = BAN-BANFN
25                WITH P_BNFPO = BAN-BNFPO.
26       ENDIF.
27     ENDFORM.
*--- End of FM06BF03_AUFRUF_BESTELLUNGEN - 27 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF03_AUFRUF_EINZELFREIGABE            Level 2    Page 77
Object           SAPMZFM06B                                Lines 85
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *EJECT
2      *----------------------------------------------------------------------*
3      *        Verzweigen in Einzelfreigabe                                  *
4      *----------------------------------------------------------------------*
5      FORM aufruf_einzelfreigabe.
6
7        DATA: lt_requisitions TYPE mereq_t_eban_mem,
8              ls_requisition  LIKE LINE OF lt_requisitions,
9              l_bnfpo         TYPE eban-bnfpo.
10
11     *-- Füllen Übergabefelder ---------------------------------------------*
12       REFRESH bat.
13       CLEAR bat.
14       CLEAR call_updkz.
15
16       IF ban-gsfrg IS INITIAL.
17     * requisition subject to item release: navigate to the item detail
18         l_bnfpo = ban-bnfpo.
19       ELSE.
20         CLEAR l_bnfpo.
21       ENDIF.
22       CALL FUNCTION 'ME_RELEASE_REQUISITION'
23         EXPORTING
24           im_banfn        = ban-banfn
25           im_bnfpo        = l_bnfpo
26           im_frgco        = com-frgab
27           im_wf           = space
28         IMPORTING
29           ex_requisitions = lt_requisitions
30           ex_updkz        = call_updkz
31         EXCEPTIONS
32           no_authority    = 1
33           OTHERS          = 2.
34       IF sy-subrc <> 0.
35         MESSAGE ID sy-msgid TYPE 'S' NUMBER sy-msgno
36                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
37         EXIT.
38       ENDIF.
39       IF call_updkz EQ space.
40         EXIT.
41       ELSE.
42         LOOP AT lt_requisitions INTO ls_requisition.
43           MOVE-CORRESPONDING ls_requisition TO bat.
44           APPEND bat.
45         ENDLOOP.
46       ENDIF.
47
48     *-- Zeilen bei den freigegeben Positionen modifizieren ----------------*
49       LOOP AT bat.
50         LOOP AT ban WHERE banfn EQ bat-banfn
51                     AND   bnfpo EQ bat-bnfpo.
52     *-- Banf wurde über Einzelfreigabe geändert ---------------------------*
53           IF bat-updkz EQ 'V'.
54             IF bat-frggr NE ban-frggr OR
55                bat-frgst NE ban-frgst OR
56                bat-frgzu NE ban-frgzu.
57               ban-selkf = 0.
58             ENDIF.
59             MOVE-CORRESPONDING bat TO ban.
60             ban-selkz = '*'.
61             ban-updk3 = scha.
62             MODIFY ban INDEX sy-tabix.
63             PERFORM ban_modif_zeile USING space.
64     *-- Banf wurde über Einzelfreigabe freigegeben
65           ELSE.
66             IF bat-updkz EQ 'F'.
67               MOVE-CORRESPONDING bat TO ban.
68               ban-selkf = 0.
69               ban-selkz = '*'.
70               ban-updk3 = free.
71               MODIFY ban INDEX sy-tabix.
72               PERFORM ban_modif_zeile USING space.
73             ELSE.
74               MOVE-CORRESPONDING bat TO ban.
75               ban-selkf = 0.
76               ban-selkz = '*'.
77               ban-updk3 = nfre.
78               MODIFY ban INDEX sy-tabix.
79               PERFORM ban_modif_zeile USING space.
80             ENDIF.
81           ENDIF.
82         ENDLOOP.
83       ENDLOOP.
84
85     ENDFORM.                    "aufruf_einzelfreigabe
*--- End of FM06BF03_AUFRUF_EINZELFREIGABE - 85 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF03_AUFRUF_MATERIALKLASSE            Level 2    Page 78
Object           SAPMZFM06B                                Lines 56
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *        Aufruf Anzeigen Rahmenverträge zur Materialklasse             *
4      *----------------------------------------------------------------------*
5      FORM AUFRUF_MATERIALKLASSE.
6
7      *- Füllen gültige Vertragsarten und Positionstypen in Selektionstabelle*
8        PERFORM FUELLEN_SELOPT.
9        CHECK EXITFLAG EQ SPACE.
10       CLEAR EXITFLAG.
11
12     *- Export Calkz nur bei Zuordnungsfunktion ----------------------------*
13       CLEAR BUEB.
14       BUEB-NRCFD = 'X'.
15       IF ( SY-PFKEY EQ 'ZUOR' OR
16            SY-PFKEY EQ 'BEAR' ) AND
17          T160D-EBZKA NE SPACE.
18         BUEB-CALKZ = 'X'.
19         IF BAN-MATNR EQ SPACE AND
20            T160D-EBZOM EQ SPACE.
21           CLEAR BUEB-CALKZ.
22         ENDIF.
23         IF BAN-MATNR NE SPACE AND
24            T160D-EBZKM EQ SPACE AND
25            T160D-EBZKW EQ SPACE.
26           CLEAR BUEB-CALKZ.
27         ENDIF.
28       ENDIF.
29       SET PARAMETER ID 'EKO' FIELD SPACE.
30       EXPORT BUEB TO MEMORY ID 'BUEB'.
31
32     *- Aufruf Report: Anzeigen Rahmenverträge zur Materialklasse ----------*
33       SUBMIT RM06EC00 AND RETURN
34              WITH EC_MATKL EQ BAN-MATKL
35              WITH S_BSART IN SEL_BSART
36              WITH S_PSTYP IN SEL_PSTYP
37              WITH S_KNTTP IN SEL_KNTTP
38              WITH S_WERKS IN SEL_WERKS.
39
40     *- Holen Übergabestruktur aus Memory ----------------------------------*
41       IMPORT BUEB FROM MEMORY ID 'BUEB'.
42     *- Kein Rahmenvertrag gefunden ----------------------------------------*
43       IF BUEB-NRCFD NE SPACE.
44         MESSAGE S226.
45         EXITFLAG = 'X'.
46         EXIT.
47       ELSE.
48         IF BUEB-KONNR NE SPACE.
49     *- Festen Lieferanten überprüfen --------------------------------------
50           CLEAR SY-UCOMM.                  "nützt leider nichts
51           PERFORM BEZUGSQUELLE_1 USING SPACE.
52           PERFORM BEZUGSQUELLE_2.
53         ENDIF.
54       ENDIF.
55
56     ENDFORM.
*--- End of FM06BF03_AUFRUF_MATERIALKLASSE - 56 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF03_AUFRUF_MATERIALNUMMER            Level 2    Page 79
Object           SAPMZFM06B                                Lines 46
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *        Aufruf Anzeigen Rahmenverträge zum Material                   *
4      *----------------------------------------------------------------------*
5      FORM AUFRUF_MATERIALNUMMER.
6
7      *- Füllen gültige Vertragsarten und Pstypen in Selektionstabelle ------*
8        PERFORM FUELLEN_SELOPT.
9        CHECK EXITFLAG EQ SPACE.
10       CLEAR EXITFLAG.
11
12     *- Export Übergabestruktur für Zuordnung ------------------------------*
13       CLEAR BUEB.
14       BUEB-NRCFD = 'X'.
15       IF ( SY-PFKEY EQ 'ZUOR' OR
16            SY-PFKEY EQ 'BEAR' ) AND
17          T160D-EBZKA NE SPACE.
18         BUEB-CALKZ = 'X'.
19       ENDIF.
20       SET PARAMETER ID 'EKO' FIELD SPACE.
21       EXPORT BUEB TO MEMORY ID 'BUEB'.
22
23     *- Aufruf Report: Anzeigen Rahmenverträge zur Materialklasse ----------*
24       SUBMIT RM06EM00 AND RETURN
25              WITH EM_MATNR EQ BAN-MATNR
26              WITH S_BSART IN SEL_BSART
27              WITH S_PSTYP IN SEL_PSTYP
28              WITH S_KNTTP IN SEL_KNTTP
29              WITH EM_WERKS IN SEL_WERKS.
30
31     *- Holen Übergabestruktur aus Memory ----------------------------------*
32       IMPORT BUEB FROM MEMORY ID 'BUEB'.
33     *- Kein Rahmenvertrag gefunden ----------------------------------------*
34       IF BUEB-NRCFD NE SPACE.
35         MESSAGE S226.
36         EXITFLAG = 'X'.
37       ELSE.
38         IF BUEB-KONNR NE SPACE.
39     *- Festen Lieferanten überprüfen --------------------------------------
40           CLEAR SY-UCOMM.                  "nützt leider nichts
41           PERFORM BEZUGSQUELLE_1 USING SPACE.
42           PERFORM BEZUGSQUELLE_2.
43         ENDIF.
44       ENDIF.
45
46     ENDFORM.
*--- End of FM06BF03_AUFRUF_MATERIALNUMMER - 46 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF03_AUFRUF_INFOSAETZE                Level 2    Page 80
Object           SAPMZFM06B                                Lines 80
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *        Aufruf Anzeigen Infosätze                                     *
4      *----------------------------------------------------------------------*
5      FORM AUFRUF_INFOSAETZE.
6
7        DATA: H_PSTYP LIKE T163Y-EPSTP.
8
9      *- Export Übergabestruktur für Zuordnung ------------------------------*
10       CLEAR BUEB.
11       BUEB-NRCFD = 'X'.
12       IF ( SY-PFKEY EQ 'ZUOR' OR
13            SY-PFKEY EQ 'BEAR' ) AND
14          T160D-EBZIN NE SPACE.
15         BUEB-CALKZ = 'X'.
16         IF BAN-MATNR EQ SPACE AND
17            T160D-EBZOM EQ SPACE.
18           CLEAR BUEB-CALKZ.
19         ENDIF.
20       ENDIF.
21       BUEB-MENGE = BAN-MENGE.              "für Preissimulation
22       BUEB-MEINS = BAN-MEINS.
23       BUEB-DATUM = BAN-FRGDT.
24       EXPORT BUEB TO MEMORY ID 'BUEB'.
25
26     *- Setzen des Infotyps
27       IF BAN-PSTYP EQ PSTYP-LOHN.
28         H_PSTYP = PSTYP-LOHN.
29       ELSEIF BAN-PSTYP = PSTYP-KONS.
30         H_PSTYP = PSTYP-KONS.                 "Konsi 4.0
31       ELSE.
32         H_PSTYP = PSTYP-LAGM.
33       ENDIF.
34
35       IF BAN-MATNR NE SPACE.
36     *- Aufruf Report: Anzeigen Infosätze zum Material ---------------------*
37         RANGES: H_MATERIALS FOR EINA-MATNR.
38         CLEAR   H_MATERIALS.
39         H_MATERIALS-LOW = BAN-MATNR.
40         H_MATERIALS-SIGN = 'I'.
41         H_MATERIALS-OPTION = 'EQ'.
42         APPEND H_MATERIALS.
43         IF BAN-SATNR NE SPACE AND BAN-SATNR NE BAN-MATNR AND
44            BAN-ATTYP EQ ATTYP-VAR.
45     *  auch Infosätze für Sammelartikel der Variante
46           H_MATERIALS-LOW = BAN-SATNR.
47           H_MATERIALS-SIGN = 'I'.
48           H_MATERIALS-OPTION = 'EQ'.
49           APPEND H_MATERIALS.
50         ENDIF.
51         SUBMIT RM06IM00 AND RETURN
52                WITH IF_MATNR IN H_MATERIALS"EQ BAN-MATNR
53                WITH I_WERKS  EQ BAN-WERKS
54                WITH I_ESOKZ  EQ H_PSTYP
55                WITH P_RELEV  EQ 'X'.
56       ELSE.
57     *- Aufruf Report: Anzeigen Infosätze zur Materialklasse ---------------*
58         SUBMIT RM06IW00 AND RETURN
59                WITH IF_MATKL EQ BAN-MATKL
60                WITH I_WERKS  EQ BAN-WERKS
61                WITH I_ESOKZ  EQ H_PSTYP
62                WITH P_RELEV  EQ 'X'.
63       ENDIF.
64
65     *- Holen Übergabestruktur aus Memory ----------------------------------*
66       IMPORT BUEB FROM MEMORY ID 'BUEB'.
67     *- Kein Rahmenvertrag gefunden ----------------------------------------*
68       IF BUEB-NRCFD NE SPACE.
69         MESSAGE S228.
70         EXITFLAG = 'X'.
71       ELSE.
72         IF BUEB-FLIEF NE SPACE.
73     *- Festen Lieferanten überprüfen --------------------------------------
74           CLEAR SY-UCOMM.                  "nützt leider nichts
75           PERFORM BEZUGSQUELLE_1 USING SPACE.
76           PERFORM BEZUGSQUELLE_2.
77         ENDIF.
78       ENDIF.
79
80     ENDFORM.
*--- End of FM06BF03_AUFRUF_INFOSAETZE - 80 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF03_AUFRUF_LIBE                      Level 2    Page 81
Object           SAPMZFM06B                                Lines 46
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *     Aufruf der Lieferantenbeurteilung
4      *----------------------------------------------------------------------*
5      FORM AUFRUF_LIBE.
6        CHECK EXITFLAG EQ SPACE.
7        CLEAR EXITFLAG.
8      *- Export Übergabestruktur für Zuordnung ------------------------------*
9        CLEAR BUEB.
10       BUEB-NRCFD = 'X'.
11       IF ( SY-PFKEY EQ 'ZUOR' OR
12            SY-PFKEY EQ 'BEAR' ) AND
13          T160D-EBZIN NE SPACE.
14         BUEB-CALKZ = 'X'.
15       ENDIF.
16       SET PARAMETER ID 'EKO' FIELD LIBE_EKO-EKORG.
17       EXPORT BUEB TO MEMORY ID 'BUEB'.
18       IF BAN-MATNR NE SPACE.
19     *- Aufruf Report: Anzeigen Lieferantenbeurteilungen zum Material ------*
20         SUBMIT RM06LB00 AND RETURN
21                WITH P_EKORG EQ LIBE_EKO-EKORG
22                WITH P_MATNR EQ BAN-MATNR
23                WITH P_LISUM EQ SPACE.
24       ELSE.
25     *- Aufruf Report: Anzeigen Lieferantenbeurteilungen zur Materialklasse
26         SUBMIT RM06LB00 AND RETURN
27                WITH P_EKORG EQ LIBE_EKO-EKORG
28                WITH P_MATKL EQ BAN-MATKL
29                WITH P_LISUM EQ SPACE.
30       ENDIF.
31     *- Holen Übergabestruktur aus Memory ----------------------------------*
32       IMPORT BUEB FROM MEMORY ID 'BUEB'.
33     *- Keine Beurteilung gefunden  ----------------------------------------*
34       IF BUEB-NRCFD NE SPACE.
35         MESSAGE ID 'ML' TYPE 'E' NUMBER '053'.
36         EXITFLAG = 'X'.
37       ELSE.
38         IF BUEB-FLIEF NE SPACE.
39     *- Festen Lieferanten überprüfen --------------------------------------
40           CLEAR SY-UCOMM.                  "nützt leider nichts
41           PERFORM BEZUGSQUELLE_1 USING SPACE.
42           PERFORM BEZUGSQUELLE_2.
43         ENDIF.
44       ENDIF.
45
46     ENDFORM.
*--- End of FM06BF03_AUFRUF_LIBE - 46 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF03_BAN_MODIF_ZEILE                  Level 2    Page 82
Object           SAPMZFM06B                                Lines 37
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *  Zeile in Grundliste modifizieren                                    *
4      *----------------------------------------------------------------------*
5      FORM BAN_MODIF_ZEILE USING BMZ_FLAG.
6
7        IF XZLTYP NE SPACE.
8          PERFORM BAN_ZUORD USING BMZ_FLAG.
9          READ LINE BAN-ZEILE OF PAGE BAN-PAGE INDEX LSIND.
10         IF SY-PFKEY EQ 'FREI'.
11           HLINE = FLINE.
12           T16LA = *T16LA.
13         ENDIF.
14         CASE XZLTYP.
15           WHEN '1'.
16             MOVE HLINE TO SY-LISEL+3(77).
17             MODIFY LINE BAN-ZEILE OF PAGE BAN-PAGE INDEX LSIND
18                    LINE FORMAT COLOR COL_POSITIVE.
19             IF NOT ICON_FIELD IS INITIAL AND                   "96597
20                BAN-GSFRG NE SPACE.                                  "122700
21               READ LINE BAN-SZEIL OF PAGE BAN-PAGE INDEX LSIND.
22     *         WRITE icon_field TO sy-lisel+53 AS ICON.
23               WRITE ICON_FIELD+1(2) TO SY-LISEL+53(2).              "122700
24               MODIFY LINE BAN-SZEIL OF PAGE BAN-PAGE INDEX LSIND.
25             ENDIF.                                              "96597
26           WHEN '2'.
27             MOVE T16LA-UPDT2 TO SY-LISEL+70(10).
28             MODIFY LINE BAN-ZEILE OF PAGE BAN-PAGE INDEX LSIND.
29           WHEN '3'.
30             MOVE T16LA-UPDT1 TO SY-LISEL+76(4).
31             MODIFY LINE BAN-ZEILE OF PAGE BAN-PAGE INDEX LSIND.
32         ENDCASE.
33       ENDIF.
34
35       PERFORM SEL_KENNZEICHNEN.
36
37     ENDFORM.
*--- End of FM06BF03_BAN_MODIF_ZEILE - 37 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF03_BAN_UPDATE_ALIF                  Level 2    Page 83
Object           SAPMZFM06B                                Lines 24
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *   Vormerken für Anfragebearbeitung mit Lieferanten
4      *----------------------------------------------------------------------*
5      FORM BAN_UPDATE_ALIF.
6
7        BAN-SELKZ = '*'.
8      *- Bezugsquellenzuordnunge retten -------------------------------------*
9        IF BAN-UPDK1 NE AMAN AND
10          BAN-UPDK1 NE ALIF AND
11          BAN-UPDK1 NE ANFR.
12         BAN-UPDK2 = BAN-UPDK1.
13       ENDIF.
14       BAN-UPDK1 = ALIF.
15       IF BAN-FLIEF NE SPACE.
16         BAN-SLIEF = BAN-FLIEF.
17       ELSE.
18         BAN-SLIEF = BAN-LIFNR.
19       ENDIF.
20       MODIFY BAN INDEX INDEX_BAN.
21       PERFORM BAN_MODIF_ZEILE USING SPACE.
22       PERFORM ALF_LOESCHEN.
23
24     ENDFORM.
*--- End of FM06BF03_BAN_UPDATE_ALIF - 24 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF03_BAN_UPDATE_ANFL                  Level 2    Page 84
Object           SAPMZFM06B                                Lines 26
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *   Vormerken für Anfragebearbeitung bei mehreren Lieferanten
4      *----------------------------------------------------------------------*
5      FORM BAN_UPDATE_ANFL.
6
7      *- Prüfen, ob auch wirklich mind. ein Lieferant zugeordnet wurde ------*
8        LOOP AT ALF WHERE BANFN EQ BAN-BANFN
9                    AND   BNFPO EQ BAN-BNFPO
10                   AND   SELKZ NE SPACE.
11         EXIT.
12       ENDLOOP.
13       CHECK SY-SUBRC EQ 0.
14
15       BAN-SELKZ = '*'.
16     *- Bezugsquellenzuordnunge retten -------------------------------------*
17       IF BAN-UPDK1 NE AMAN AND
18          BAN-UPDK1 NE ALIF AND
19          BAN-UPDK1 NE ANFR.
20         BAN-UPDK2 = BAN-UPDK1.
21       ENDIF.
22       BAN-UPDK1 = AMAN.
23       MODIFY BAN INDEX INDEX_BAN.
24       PERFORM BAN_MODIF_ZEILE USING SPACE.
25
26     ENDFORM.
*--- End of FM06BF03_BAN_UPDATE_ANFL - 26 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF03_BAN_UPDATE_ANFR                  Level 2    Page 85
Object           SAPMZFM06B                                Lines 20
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *   Vormerken für Anfragebearbeitung
4      *----------------------------------------------------------------------*
5      FORM BAN_UPDATE_ANFR.
6
7        BAN-SELKZ = '*'.
8      *- Bezugsquellenzuordnunge retten -------------------------------------*
9        IF BAN-UPDK1 NE AMAN AND
10          BAN-UPDK1 NE ALIF AND
11          BAN-UPDK1 NE ANFR.
12         BAN-UPDK2 = BAN-UPDK1.
13       ENDIF.
14       BAN-UPDK1 = ANFR.
15       CLEAR BAN-SLIEF.
16       MODIFY BAN INDEX INDEX_BAN.
17       PERFORM BAN_MODIF_ZEILE USING SPACE.
18       PERFORM ALF_LOESCHEN.
19
20     ENDFORM.
*--- End of FM06BF03_BAN_UPDATE_ANFR - 20 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF03_BAN_UPDATE_KICK                  Level 2    Page 86
Object           SAPMZFM06B                                Lines 26
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *  Zugeordnet über Konsi-Liste                                         *
4      *----------------------------------------------------------------------*
5      FORM BAN_UPDATE_KICK.
6
7        BAN-FLIEF = KON-LIFNR.
8        BAN-SLIEF = KON-LIFNR.
9        CLEAR BAN-KONNR.
10       CLEAR BAN-KTPNR.
11       CLEAR BAN-VRTYP.
12       CLEAR BAN-INFNR.
13       IF BAN-RESWK NE SPACE.
14         IF BAN-UPDK1 NE AEND.
15           BAN-UPDK1 = ZNER.
16         ENDIF.
17       ENDIF.
18       CLEAR BAN-RESWK.
19       IF BAN-UPDK1 NE AEND AND BAN-UPDK1 NE ZNER.
20         BAN-UPDK1 = ZNEW.
21       ENDIF.
22       MODIFY BAN INDEX INDEX_BAN.
23       PERFORM BAN_MODIF_ZEILE USING SPACE.
24       PERFORM ALF_LOESCHEN.
25
26     ENDFORM.
*--- End of FM06BF03_BAN_UPDATE_KICK - 26 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF03_BAN_UPDATE_LINF                  Level 2    Page 87
Object           SAPMZFM06B                                Lines 37
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *  Zugeordnet über Infosatz/Lieferantenbeurteilung.                    *
4      *----------------------------------------------------------------------*
5      FORM BAN_UPDATE_LINF.
6
7        BAN-SELKZ = '*'.
8        IF BUEB-FLIEF NE SPACE.
9          BAN-FLIEF = BUEB-FLIEF.
10         BAN-EKORG = BUEB-EKORG.
11         BAN-INFNR = BUEB-INFNR.
12         IF BAN-RESWK NE BUEB-RESWK.
13           BAN-RESWK = BUEB-RESWK.
14           PERFORM BUKRS_UMLAG.
15           IF BAN-UPDK1 NE AEND.
16             BAN-UPDK1 = ZNER.
17           ENDIF.
18         ENDIF.
19         IF BAN-BKUML NE SPACE OR
20            BAN-RESWK EQ SPACE.
21           BAN-SLIEF = BUEB-FLIEF.
22         ENDIF.
23         CLEAR BAN-KONNR.
24         CLEAR BAN-KTPNR.
25         CLEAR BAN-VRTYP.
26         IF BAN-UPDK1 NE AEND AND BAN-UPDK1 NE ZNER.
27           BAN-UPDK1 = ZNEW.
28         ENDIF.
29         MODIFY BAN INDEX INDEX_BAN.
30         PERFORM BAN_MODIF_ZEILE USING SPACE.
31         PERFORM ALF_LOESCHEN.
32       ELSE.
33         MODIFY BAN INDEX INDEX_BAN.
34         PERFORM SEL_KENNZEICHNEN.
35       ENDIF.
36
37     ENDFORM.
*--- End of FM06BF03_BAN_UPDATE_LINF - 37 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF03_BAN_UPDATE_ORDR                  Level 2    Page 88
Object           SAPMZFM06B                                Lines 13
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *  Zugeordnet über Orderbuch                                           *
4      *----------------------------------------------------------------------*
5      FORM BAN_UPDATE_ORDR.
6
7        BAN-SELKZ = '*'.
8      ENHANCEMENT-POINT FM06BF03_BAN_UPDATE_ORDR_01 SPOTS ES_SAPFM06B.
9        MODIFY BAN INDEX INDEX_BAN.
10       PERFORM BAN_MODIF_ZEILE USING BQPEX-FESKZ.
11       PERFORM ALF_LOESCHEN.
12
13     ENDFORM.
*--- End of FM06BF03_BAN_UPDATE_ORDR - 13 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF03_BAN_UPDATE_RAHM                  Level 2    Page 89
Object           SAPMZFM06B                                Lines 37
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *  Zeile zugeordneter Rahmenvertrag                                    *
4      *----------------------------------------------------------------------*
5      FORM BAN_UPDATE_RAHM.
6
7        BAN-SELKZ = '*'.
8        IF BUEB-FLIEF NE SPACE.
9          BAN-FLIEF = BUEB-FLIEF.
10         BAN-EKORG = BUEB-EKORG.
11         BAN-KONNR = BUEB-KONNR.
12         BAN-KTPNR = BUEB-KTPNR.
13         BAN-VRTYP = BUEB-VRTYP.
14         IF BAN-RESWK NE BUEB-RESWK.
15           BAN-RESWK = BUEB-RESWK.
16           PERFORM BUKRS_UMLAG.
17           IF BAN-UPDK1 NE AEND.
18             BAN-UPDK1 = ZNER.
19           ENDIF.
20         ENDIF.
21         IF BAN-BKUML NE SPACE OR
22            BAN-RESWK EQ SPACE.
23           BAN-SLIEF = BUEB-FLIEF.
24         ENDIF.
25         CLEAR BAN-INFNR.
26         IF BAN-UPDK1 NE AEND AND BAN-UPDK1 NE ZNER.
27           BAN-UPDK1 = ZNEW.
28         ENDIF.
29         MODIFY BAN INDEX INDEX_BAN.
30         PERFORM BAN_MODIF_ZEILE USING SPACE.
31         PERFORM ALF_LOESCHEN.
32       ELSE.
33         MODIFY BAN INDEX INDEX_BAN.
34         PERFORM SEL_KENNZEICHNEN.
35       ENDIF.
36
37     ENDFORM.
*--- End of FM06BF03_BAN_UPDATE_RAHM - 37 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF03_BAN_UPDATE_ZRES                  Level 2    Page 90
Object           SAPMZFM06B                                Lines 62
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *  Zuordnung zurückgesetzt                                             *
4      *----------------------------------------------------------------------*
5      FORM BAN_UPDATE_ZRES.
6
7        BAN-SELKZ = '*'.
8        IF BAN-UPDK1 EQ ZNEW OR
9           BAN-UPDK1 EQ ZOLD OR
10          BAN-UPDK1 EQ ZNER OR
11          BAN-UPDK1 EQ AEND.
12         PERFORM BEZUGSQUELLE_6.
13         CLEAR BAN-FLIEF.
14         CLEAR BAN-SLIEF.
15         CLEAR BAN-EKORG.
16         CLEAR BAN-KONNR.
17         CLEAR BAN-KTPNR.
18         CLEAR BAN-VRTYP.      .
19         CLEAR BAN-INFNR.
20         IF BAN-UPDK1 NE AEND.
21           IF BAN-RESWK NE SPACE.
22             BAN-UPDK1 = ZOLD.
23           ELSE.
24             BAN-UPDK1 = ZRES.
25           ENDIF.
26         ENDIF.
27         MODIFY BAN INDEX INDEX_BAN.
28         PERFORM BAN_MODIF_ZEILE USING SPACE.
29       ELSEIF BAN-UPDK1 EQ ANFR OR
30              BAN-UPDK1 EQ ALIF OR
31              BAN-UPDK1 EQ AMAN.
32     *- Mehrfachvormerkung zur Anfrage löschen -----------------------------*
33         IF BAN-UPDK1 EQ ALIF AND
34            BAN-UPDK2 EQ AMAN.
35           PERFORM ALF_LOESCHEN_EINZEL.
36           BAN-UPDK1 = ZRES.
37         ELSE.
38           PERFORM ALF_LOESCHEN.
39     *- Bezugsquellenzuordnung zurückholen ---------------------------------*
40           IF BAN-UPDK2 <> SPACE.
41             BAN-UPDK1 = BAN-UPDK2.
42             CLEAR BAN-UPDK2.
43           ELSE.
44             BAN-UPDK1 = ZRES.
45           ENDIF.
46           CLEAR BAN-SLIEF.
47           IF BAN-FLIEF NE SPACE.
48             IF BAN-BKUML NE SPACE OR
49                BAN-RESWK EQ SPACE.
50               BAN-SLIEF = BUEB-FLIEF.
51             ENDIF.
52           ENDIF.
53         ENDIF.
54
55         MODIFY BAN INDEX INDEX_BAN.
56         PERFORM BAN_MODIF_ZEILE USING SPACE.
57       ELSE.
58         MODIFY BAN INDEX INDEX_BAN.
59         PERFORM SEL_KENNZEICHNEN.
60       ENDIF.
61
62     ENDFORM.
*--- End of FM06BF03_BAN_UPDATE_ZRES - 62 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF03_FREIGABE_SETZEN                  Level 2    Page 91
Object           SAPMZFM06B                                Lines 66
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *        Freigabe für die selektierten Banfs setzen                    *
4      *----------------------------------------------------------------------*
5      FORM FREIGABE_SETZEN.
6
7        CHECK BAN-SELKF GT 0.
8        MOVE BAN TO OBA.
9        APPEND OBA.
10       MOVE BAN TO BAT.
11       BAN-SELKF = BAN-SELKF - 1.
12       WRITE 'X' TO BAT-FRGZU+BAN-SELKF(1).
13       CALL FUNCTION 'ME_REL_FRGKZ'
14         EXPORTING
15           I_FRGOT = '1'
16           I_FRGGR = BAT-FRGGR
17           I_FRGST = BAT-FRGST
18           I_FRGKZ = BAT-FRGKZ
19           I_FRGRL = BAT-FRGRL
20           I_FRGZU = BAT-FRGZU
21         IMPORTING
22           E_FRGRL = BAT-FRGRL
23           E_FRGKZ = BAT-FRGKZ.
24
25     * DCM adapter
26       data: l_Eban      type eban,
27             l_Eban_old  type eban,
28             lt_ebkn     type mereq_t_Ebkn,                      "605263
29             lt_ebkn_old type mereq_t_ebkn.                      "605263
30
31
32       move bat to l_Eban.
33       move ban to l_Eban_old.
34       CALL FUNCTION 'MEDI_REQ_RELEASE'
35         EXPORTING
36           im_eban       = l_eban
37           im_eban_old   = l_eban_old
38           im_activity   = ver
39           IM_PERSISTENT = 'X'
40         IMPORTING
41           EX_BANPR      = l_eban-banpr
42           EX_RLWRT      = l_eban-rlwrt
43         EXCEPTIONS
44           error_message = 1
45           OTHERS        = 2.
46
47       CALL FUNCTION 'MEDI_REQ_BUYER_APPROVAL'
48         EXPORTING
49           im_eban       = l_eban
50           im_eban_old   = l_eban_old
51           im_ebkn       = lt_Ebkn
52           im_ebkn_old   = lt_ebkn_old
53           im_activity   = ver
54           IM_PERSISTENT = 'X'
55         IMPORTING
56           EX_BANPR      = l_eban-banpr
57         EXCEPTIONS
58           error_message = 1
59           OTHERS        = 2.
60
61       bat-banpr = l_eban-banpr.
62       bat-rlwrt = l_eban-rlwrt.
63
64       APPEND BAT.
65
66     ENDFORM.                    "FREIGABE_SETZEN
*--- End of FM06BF03_FREIGABE_SETZEN - 66 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF03_SEL_KENNZEICHNEN                 Level 2    Page 92
Object           SAPMZFM06B                                Lines 17
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *   Selektionskennzeichen auf Liste modifizieren
4      *----------------------------------------------------------------------*
5      FORM SEL_KENNZEICHNEN.
6
7        IF XSZTYP NE SPACE.
8          IF NOT BAN-GSFRG IS INITIAL AND NOT GS_BANF IS INITIAL.
9      *... Bei Gesamtbanfen auf erste Position gehen .......................*
10           READ TABLE BAN WITH KEY BANFN = BAN-BANFN.
11         ENDIF.
12         READ LINE BAN-SZEIL OF PAGE BAN-PAGE INDEX LSIND.
13         SY-LISEL+1(1) = BAN-SELKZ.
14         MODIFY LINE BAN-SZEIL OF PAGE BAN-PAGE INDEX LSIND.
15       ENDIF.
16
17     ENDFORM.
*--- End of FM06BF03_SEL_KENNZEICHNEN - 17 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF03_VERLASSEN_LISTE                  Level 2    Page 93
Object           SAPMZFM06B                                Lines 21
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *   Verlassen Liste nach Zurück oder Beenden
4      *----------------------------------------------------------------------*
5      FORM VERLASSEN_LISTE.
6
7        IF COM-CALLD NE SPACE.
8          LEAVE.
9        ELSE.
10         IF SY-UCOMM EQ 'EN  '.
11           LEAVE PROGRAM.
12         ELSE.
13           IF NOT sy-binpt IS INITIAL OR NOT sy-calld IS INITIAL. "895223
14             LEAVE.
15           ELSE.
16             LEAVE TO TRANSACTION sy-tcode.
17           ENDIF.
18         ENDIF.
19       ENDIF.
20
21     ENDFORM.                    "VERLASSEN_LISTE
*--- End of FM06BF03_VERLASSEN_LISTE - 21 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF03_WARNING_UPDK3                    Level 2    Page 94
Object           SAPMZFM06B                                Lines 16
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *        Warnung, wenn schon bearbeitet                                *
4      *----------------------------------------------------------------------*
5      FORM WARNING_UPDK3.
6
7        CASE BAN-UPDK3.
8          WHEN BUBE.
9            MESSAGE I290 WITH BAN-BANFN BAN-BNFPO.
10         WHEN BUBA.
11           MESSAGE I288 WITH BAN-BANFN BAN-BNFPO.
12         WHEN BUAN.
13           MESSAGE I289 WITH BAN-BANFN BAN-BNFPO.
14       ENDCASE.
15
16     ENDFORM.
*--- End of FM06BF03_WARNING_UPDK3 - 16 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF04                                  Level 1    Page 95
Object           SAPMZFM06B                                Lines 83
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1        INCLUDE fm06bf04_aend_deta .  " AEND_DETA
2
3        INCLUDE fm06bf04_aend_lfdat .  " AEND_LFDAT
4
5        INCLUDE fm06bf04_aend_menge .  " AEND_MENGE
6        INCLUDE fm06bf04_aend_bezug .  " AEND_BEZUG
7
8        INCLUDE fm06bf04_banf_aendern .  " BANF_AENDERN
9
10       INCLUDE fm06bf04_aendern_banfs .  " AENDERN_BANFS
11
12       INCLUDE fm06bf04_ban_aendern .  " BAN_AENDERN
13
14       INCLUDE fm06bf04_berechtigungen_banf .  " BERECHTIGUNGEN_BANF
15
16       INCLUDE fm06bf04_bezugsquelle .  " BEZUGSQUELLE
17
18       INCLUDE fm06bf04_bezugsquelle_1 .  " BEZUGSQUELLE_1
19
20       INCLUDE fm06bf04_bezugsquelle_2 .  " BEZUGSQUELLE_2
21
22       INCLUDE fm06bf04_bezugsquelle_3 .  " BEZUGSQUELLE_3
23
24       INCLUDE fm06bf04_bezugsquelle_4 .  " BEZUGSQUELLE_4
25
26
27       INCLUDE fm06bf04_bezugsquelle_5 .  " BEZUGSQUELLE_5
28
29
30       INCLUDE fm06bf04_bezugsquelle_6 .  " BEZUGSQUELLE_6
31
32       INCLUDE fm06bf04_bezugsquelle_manuell .  " BEZUGSQUELLE_MANUELL
33
34       INCLUDE fm06bf04_bezugsquelle_bezeichn .  " BEZUGSQUELLE_BEZEICHN
35
36       INCLUDE fm06bf04_bqpim_t160d_setzen .  " BQPIM_T160D_SETZEN
37
38       INCLUDE fm06bf04_bqpim_dien_setzen .  " BQPIM_DIEN_SETZEN
39
40       INCLUDE fm06bf04_bukrs_umlag .  " BUKRS_UMLAG
41
42       INCLUDE fm06bf04_det_check .  " DET_CHECK
43
44       INCLUDE fm06bf04_cueb_fuellen .  " CUEB_FUELLEN
45
46       INCLUDE fm06bf04_fuellen_selopt .  " FUELLEN_SELOPT
47
48       INCLUDE fm06bf04_help_ebeln .  " HELP_EBELN
49
50
51       INCLUDE fm06bf04_lesen_material_konsi .  " LESEN_MATERIAL_KONSI
52
53       INCLUDE fm06bf04_lesen_info .  " LESEN_INFO
54
55       INCLUDE fm06bf04_modify_screen .  " MODIFY_SCREEN
56
57       INCLUDE fm06bf04_pruefen_eingaben .  " PRUEFEN_EINGABEN
58
59       INCLUDE fm06bf04_pruefen_estkz .  " PRUEFEN_ESTKZ
60
61       INCLUDE fm06bf04_pruefen_freigabe_anf .  " PRUEFEN_FREIGABE_ANF
62
63       INCLUDE fm06bf04_pruefen_freigabe_best .  " PRUEFEN_FREIGABE_BEST
64
65       INCLUDE fm06bf04_top .  " TOP
66
67       INCLUDE fm06bf04_valid_line .  " VALID_LINE
68
69       INCLUDE fm06bf04_zuordnen .  " ZUORDNEN
70
71       INCLUDE fm06bf04_init_efube .  " INIT_EFUBE
72
73       INCLUDE fm06bf04_oba_aufbauen .  " OBA_AUFBAUEN
74
75       INCLUDE fm06bf04_oba_update_best .  " OBA_UPDATE_BEST
76
77       INCLUDE fm06bf04_pruefen_lstub .  " PRUEFEN_LSTUB
78
79       INCLUDE fm06bf04_vorschlagen_lstub .  " VORSCHLAGEN_LSTUB
80
81       INCLUDE fm06bf04_xt16ll_aufbauen .  " XT16LL_AUFBAUEN
82
83       INCLUDE fm06bf04_dien_read_po .  " DIEN_READ_PO
*--- End of FM06BF04 - 83 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF04_AEND_DETA                        Level 2    Page 96
Object           SAPMZFM06B                                Lines 36
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      ************************************************************************
2      *        Allgemeine Unterroutinen zur Listanzeige Banfs                *
3      ************************************************************************
4      * 76800 11.06.1997 3.1H GT : RM06BZ10 bringt ME 146 und ME 149
5      * 92105 08.01.1998 4.0C KB : SD-Banfen können teilbestellt werden
6      * 94637 04.02.1998 3.1I SM : RV-Banfen kein Lieferdatum - Probl.in ME5a
7      * 96790 03.03.1998 4.0C SM : ME56/ME57 Bezugsquellenzuordnung ->ME149
8      *eject
9      *----------------------------------------------------------------------*
10     *        Ändern vom Detailbild                                         *
11     *----------------------------------------------------------------------*
12     FORM AEND_DETA.
13
14     *- Quotierungsdaten neu ermitteln -------------------------------------*
15     *- erfolgt bei Bezugsquellenänderung im entsprechenden Subscreen ------*
16       IF ( EBAN-MENGE NE *EBAN-MENGE OR
17            EBAN-LFDAT NE *EBAN-LFDAT ) AND
18          EBAN-FLIEF EQ *EBAN-FLIEF AND
19          EBAN-EKORG EQ *EBAN-EKORG AND
20          EBAN-KONNR EQ *EBAN-KONNR AND
21          EBAN-KTPNR EQ *EBAN-KTPNR AND
22          EBAN-INFNR EQ *EBAN-INFNR.
23         PERFORM AEND_BEZUG.
24       ENDIF.
25       read table bde index 1 transporting no fields.
26       IF EBAN NE *EBAN AND HIDE-INDEX > 0 AND sy-subrc = 0.      "85554
27         MOVE-CORRESPONDING EBAN TO BAN.
28         BAN-UPDK1 = AEND.
29         MODIFY BAN INDEX HIDE-INDEX.
30       ENDIF.
31
32     ENDFORM.
33
34
35
36
*--- End of FM06BF04_AEND_DETA - 36 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF04_AEND_LFDAT                       Level 2    Page 97
Object           SAPMZFM06B                                Lines 63
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *----------------------------------------------------------------------*
2      *        Lieferdatum Ändern                                            *
3      *----------------------------------------------------------------------*
4      FORM aend_lfdat.
5
6        IF NOT ( rm06b-eeind IS INITIAL ).                        "H94637
7          CALL FUNCTION 'PERIOD_AND_DATE_CONVERT_INPUT'
8            EXPORTING
9              dialog_date_is_in_the_past = space
10             external_date              = rm06b-eeind
11             external_period            = rm06b-lpein
12           IMPORTING
13             internal_date              = eban-lfdat
14             internal_period            = eban-lpein.
15         IF eban-lfdat NE *eban-lfdat OR
16            eban-lpein NE *eban-lpein.
17           eban-lfdat = *eban-lfdat.
18           eban-lpein = *eban-lpein.
19             DATA: WA_T001W type T001W.       "2137002
20             SELECT SINGLE * from T001W into corresponding fields of WA_T001W where WERKS = EBAN-WERKS.
21           PERFORM eban-lfdat(sapfmmex) USING rm06b-eeind rm06b-lpein space
22                                             WA_T001W
23                                             mt06e
24                                             *eban
25                                             aktyp
26                                       CHANGING eban rm06b.
27
28           IF *eban-estkz EQ 'B' OR *eban-estkz EQ 'U'.          "116583
29             eban-fixkz = 'X'.                                   "116583
30           ENDIF.                                                "116583
31     * Anpassung Freigabedatum
32           IF eban-plifz IS INITIAL.
33             DATA: l_mt06e LIKE mt06e,
34                   l_mtcom LIKE mtcom.
35             IF eban-ematn IS INITIAL.
36               l_mtcom-matnr = eban-matnr.
37             ELSE.
38               l_mtcom-matnr = eban-ematn.
39             ENDIF.
40             l_mtcom-werks = eban-werks.
41             l_mtcom-kenng = 'MT06E'.                                       "sLog
42             l_mtcom-spras = sy-langu.
43             IF eban-pstyp EQ pstyp-umlg.
44               l_mtcom-pstat = 'D '.
45             ELSE.
46               l_mtcom-pstat = 'ED'.
47             ENDIF.
48             l_mtcom-kzmpn = 'X'.
49     * MMACCESS_2015W1_ADJUSTED
50             CALL FUNCTION 'MATERIAL_READ'
51               EXPORTING
52                 schluessel = l_mtcom
53               IMPORTING
54                 matdaten   = l_mt06e
55               EXCEPTIONS
56                 OTHERS     = 1.
57           ENDIF.
58           PERFORM ermitteln_freigabedatum(sapfmmex) USING t001w l_mt06e
59                                                     CHANGING rm06b eban.
60         ENDIF.
61       ENDIF.                                                    "H94637
62
63     ENDFORM.
*--- End of FM06BF04_AEND_LFDAT - 63 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF04_AEND_MENGE                       Level 2    Page 98
Object           SAPMZFM06B                                Lines 16
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *        Menge Ändern                                                  *
4      *----------------------------------------------------------------------*
5      FORM AEND_MENGE.
6
7        IF EBAN-MENGE NE *EBAN-MENGE.
8          IF EBAN-MENGE EQ 0.
9            MESSAGE E070(06).
10         ENDIF.
11         IF *EBAN-ESTKZ EQ 'B' OR *EBAN-ESTKZ EQ 'U'.             "116583
12           EBAN-FIXKZ = 'X'.                                      "116583
13         ENDIF.                                                   "116583
14       ENDIF.
15
16     ENDFORM.
*--- End of FM06BF04_AEND_MENGE - 16 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF04_AEND_BEZUG                       Level 2    Page 99
Object           SAPMZFM06B                                Lines 32
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *        Bezugsquelle Ändern                                           *
4      *----------------------------------------------------------------------*
5      FORM AEND_BEZUG.
6
7        CLEAR BUEB.
8        BUEB-FLIEF = EBAN-FLIEF.
9        BUEB-EKORG = EBAN-EKORG.
10       BUEB-INFNR = EBAN-INFNR.
11       BUEB-KONNR = EBAN-KONNR.
12       BUEB-KTPNR = EBAN-KTPNR.
13       BUEB-RESWK = EBAN-RESWK.
14       BUEB-BESWK = EBAN-BESWK. " CCP
15       BUEB-EMATN = EBAN-EMATN.
16       BUEB-MFRNR = EBAN-MFRNR.
17       BUEB-MFRPN = EBAN-MFRPN.
18       BUEB-EMNFR = EBAN-EMNFR.
19       MERK = BAN-UPDK1.
20       MOVE-CORRESPONDING EBAN TO BAN.
21       PERFORM BEZUGSQUELLE_1 USING 'X'.
22       PERFORM BEZUGSQUELLE_2.
23       MOVE BAN TO EBAN.
24       read table bde index 1 transporting no fields.
25       IF EBAN NE *EBAN AND HIDE-INDEX > 0 AND sy-subrc = 0.
26         IF MERK EQ AEND.
27           BAN-UPDK1 = AEND.
28         ENDIF.
29         MODIFY BAN INDEX HIDE-INDEX.
30       ENDIF.
31
32     ENDFORM.
*--- End of FM06BF04_AEND_BEZUG - 32 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF04_BANF_AENDERN                     Level 2    Page 100
Object           SAPMZFM06B                                Lines 347
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *        Ändern Bestellanforderungen                                   *
4      *----------------------------------------------------------------------*
5      FORM banf_aendern USING bae_compl.
6
7      *-- Schlusspruefung im Fall der Gesamtfreigabe ------------------------*
8        DATA: l_xeban  LIKE xeban,
9              l_ban    LIKE ban,
10             l_lines  LIKE sy-tabix.
11       READ TABLE xeban INTO l_xeban INDEX 1.
12       CHECK sy-subrc IS INITIAL.
13       IF gpfkey EQ 'FREI' AND l_xeban-gsfrg EQ 'X' AND gs_banf EQ 'X'.
14     * Pruefen auf Vollstaendigkeit
15         DESCRIBE TABLE xeban LINES l_lines.
16         READ TABLE ban INTO l_ban WITH KEY banfn = l_xeban-banfn
17                                            bnfpo = l_xeban-bnfpo.
18         IF l_ban-az_pos NE l_lines.
19           CLEAR: xeban, yeban.
20           REFRESH: xeban, yeban.
21           DELETE bat WHERE banfn EQ l_xeban-banfn.
22           zsich = zsich + l_lines - l_ban-az_pos.
23           EXIT.
24         ENDIF.
25       ENDIF.
26
27     *-- Note 739690
28     *-- Commitment Interface-----------------------------------------------*
29       DATA: fmeban LIKE eban OCCURS 0 WITH HEADER LINE,
30             fmebkn LIKE ebkn OCCURS 0 WITH HEADER LINE.
31
32       DATA: l_badi                TYPE REF TO me_commtmnt_req_rele,
33             l_badi_cust           TYPE REF TO me_commtmnt_req_re_c,
34             lo_context            TYPE REF TO cl_ex_me_commtmnt_req_rele,
35             lo_context_cust       TYPE REF TO cl_ex_me_commtmnt_req_re_c.
36
37       STATICS : l_internal_badi_act TYPE i,
38                 l_cust_badi_active  TYPE i.
39
40       IF l_internal_badi_act IS INITIAL AND
41          l_cust_badi_active  IS INITIAL.
42
43         CREATE OBJECT lo_context.
44         TRY.
45             GET BADI l_badi
46               CONTEXT
47                 lo_context.
48             l_internal_badi_act = 2.
49           CATCH cx_badi_not_implemented.
50             l_internal_badi_act = 1.
51         ENDTRY.
52
53         CREATE OBJECT lo_context_cust.
54         TRY.
55             GET BADI l_badi_cust
56               CONTEXT
57                 lo_context_cust.
58             l_cust_badi_active = 2.
59           CATCH cx_badi_not_implemented.
60             l_cust_badi_active = 1.
61         ENDTRY.
62       ENDIF.
63
64       IF ( l_internal_badi_act = 2 OR
65            l_cust_badi_active  = 2 ) AND
66          gpfkey = 'FREI'.
67         REFRESH : fmeban,
68                   fmebkn.
69         CLEAR : fmebkn,
70                 fmeban.
71
72         APPEND LINES OF xeban TO fmeban.
73         SELECT * FROM ebkn APPENDING TABLE fmebkn
74                            WHERE banfn = xeban-banfn.
75
76     *-- Prepare the message handler for new update
77         CALL FUNCTION 'MESSAGES_INITIALIZE'.
78
79         CALL FUNCTION 'ME_STATISTICS_EBAN_RKO'
80           EXPORTING
81             i_avc_pruefen = 'X'
82             i_first_call  = 'X'
83           TABLES
84             t_eban        = fmeban
85             t_ebkn        = fmebkn.
86
87         CLEAR t_mesg.
88         REFRESH t_mesg.
89         CALL FUNCTION 'MESSAGES_STOP'
90           EXCEPTIONS
91             a_message         = 1
92             e_message         = 2
93             w_message         = 3
94             i_message         = 4
95             s_message         = 5
96             deactivated_by_md = 6
97             OTHERS            = 7.
98
99     *-- Get all messages issued by updating interface
100        CALL FUNCTION 'MESSAGES_GIVE'
101          TABLES
102            t_mesg = t_mesg.
103
104    *-- If there is an error or abort message save the errors for log
105        LOOP AT t_mesg WHERE msgty = 'E'
106                          OR msgty = 'A'.
107          t_excluded-banfn = xeban-banfn.
108          t_excluded-msgty = t_mesg-msgty.
109          t_excluded-text  = t_mesg-text.
110          t_excluded-arbgb = t_mesg-arbgb.
111          t_excluded-txtnr = t_mesg-txtnr.
112          t_excluded-msgv1 = t_mesg-msgv1.
113          t_excluded-msgv2 = t_mesg-msgv2.
114          t_excluded-msgv3 = t_mesg-msgv3.
115          t_excluded-msgv4 = t_mesg-msgv4.
116          APPEND t_excluded.
117        ENDLOOP.
118        IF sy-subrc = 0.
119          CALL FUNCTION 'ME_STATISTICS_EBAN_RKO'
120            EXPORTING
121              i_refresh    = ' '
122              i_initialize = 'X'
123            TABLES
124              t_eban       = fmeban
125              t_ebkn       = fmebkn.
126
127          DESCRIBE TABLE xeban LINES l_lines.
128          DELETE bat WHERE banfn EQ xeban-banfn.
129          DELETE xeban WHERE banfn EQ xeban-banfn.
130          zsich = zsich - l_lines.
131          zacce = zacce + l_lines.
132          EXIT.
133        ENDIF.
134      ENDIF.
135    *-- Note 739690
136
137    *-- Verbuchen Änderungsbeleg ------------------------------------------*
138      objectid(10) = xeban-banfn.
139      tcode        = sy-tcode.
140      utime        = sy-uzeit.
141      udate        = sy-datum.
142      username     = sy-uname.
143      upd_icdtxt_banf   = 'U'.
144      upd_eban     = 'U'.
145      PERFORM cd_call_banf.
146
147      IF gpfkey EQ 'FREI'.
148    *-- Verbuchen freigaberelevante Felder --------------------------------*
149        CALL FUNCTION 'ME_UPDATE_REQUISITION_RELEASE' IN UPDATE TASK
150          TABLES
151            xeban = xeban
152            yeban = yeban.                                      "#124738
153
154    * DCM: Revisions
155        CALL FUNCTION 'MEDCMM_POST_REVISIONS'
156          EXPORTING
157            im_number = xeban-banfn
158          EXCEPTIONS
159            OTHERS    = 0.
160
161    * DCM: Workflows
162        DATA: lt_xeban TYPE mereq_t_eban,
163              lt_yeban TYPE mereq_t_eban,
164              lt_wfc   TYPE merel_t_wfc.
165        lt_xeban[] = xeban[].
166        lt_yeban[] = yeban[].
167        CALL FUNCTION 'MEREL_PREPARE_WFC_EBAN'
168          EXPORTING
169            im_number   = xeban-banfn
170            im_eban_new = lt_xeban
171            im_eban_old = lt_yeban
172          CHANGING
173            ch_wfc      = lt_wfc.
174
175        CALL FUNCTION 'ME_PREPARE_WFC_BUYER'
176          EXPORTING
177            im_eban_new = lt_xeban
178            im_eban_old = lt_yeban
179          CHANGING
180            ch_wfc      = lt_wfc.
181        IF NOT lt_wfc IS INITIAL.
182          CALL FUNCTION 'MEREL_POST_WFC' IN UPDATE TASK
183            EXPORTING
184              im_wfc = lt_wfc.
185        ENDIF.
186
187      ELSE.
188        IF bae_compl NE space.
189    *-- Disp-Satz-Erstellung ----------------------------------------------*
190    *      IF NOT DIS[] IS INITIAL.                                "201395
191          CALL FUNCTION 'ME_CREATE_MRPRECORD_REQ' IN UPDATE TASK
192            EXPORTING                                              "1918228
193              it_xebkn = xebkn[]
194              it_yebkn = yebkn[]
195            TABLES
196              dis      = dis
197              xeban    = xeban
198              yeban    = yeban.
199    *      ENDIF.                                                  "201395
200    *{   INSERT         OCQK901270                                        1
201    * Start : Generate PR log before calling function ME_UPDATE_REQUISITION
202    *         as required by SAP
203          CALL FUNCTION 'Z_ME_CREATE_REQ'
204               TABLES
205                    XEBAN = xeban.
206    * End
207    *}   INSERT
208    *-- Komplett-Verbuchung Banf bei Mengen/Termin-Änderung ---------------*
209          CALL FUNCTION 'ME_UPDATE_REQUISITION' IN UPDATE TASK
210            TABLES
211              xeban = xeban
212              xebkn = xebkn
213              yeban = yeban
214              yebkn = yebkn.
215        ELSE.
216    *-- Verbuchung Felder aus Zuordnung (sources of supply) ---------------*
217          CALL FUNCTION 'ME_UPDATE_REQUISITION_SOS' IN UPDATE TASK
218            TABLES
219              xeban = xeban
220              yeban = yeban.                                    "#124738
221    *- Update Quota                                                "361414
222          CALL FUNCTION 'ME_UPDATE_QUOTA_FROM_REQ' IN UPDATE TASK
223            TABLES
224              xeban = xeban
225              yeban = yeban.
226        ENDIF.
227    * LB-Positionen: Mengen-/Terminänderung an Komponenten weitergeben
228        DATA: l_eban LIKE eban,
229              l_eban_old LIKE eban,
230              l_ebkn LIKE ebkn,
231              l_mdlb LIKE mdlb,
232              l_vorga TYPE c,                                   "500635
233              l_mdpa LIKE mdpa,
234              l_mdpa_old LIKE mdpa,
235              lt_mdlb LIKE mdlb OCCURS 0.
236        CALL FUNCTION 'ME_COMPONENTS_REFRESH'.
237        LOOP AT xeban WHERE pstyp EQ pstyp-lohn.
238          MOVE-CORRESPONDING xeban TO l_eban.
239          CLEAR l_ebkn.
240          CLEAR l_vorga.                                        "500635
241    *     IF l_eban-sobkz EQ sobkz-kdein OR
242    *        l_eban-sobkz EQ sobkz-prein.
243          IF NOT l_eban-knttp IS INITIAL.                       "499632
244            SELECT SINGLE * FROM  ebkn INTO l_ebkn
245                   WHERE  banfn  = l_eban-banfn
246                   AND    bnfpo  = l_eban-bnfpo
247                   AND    zebkn  = 01.
248          ENDIF.
249          CALL FUNCTION 'ME_FILL_MDPA_FROM_EBAN'
250            EXPORTING
251              im_eban = l_eban
252              im_ebkn = l_ebkn
253            IMPORTING
254              ex_mdpa = l_mdpa.
255          CLEAR l_eban_old.
256          READ TABLE yeban WITH KEY banfn = xeban-banfn
257                                    bnfpo = xeban-bnfpo.
258          MOVE-CORRESPONDING yeban TO l_eban_old.
259          CALL FUNCTION 'ME_FILL_MDPA_FROM_EBAN'
260            EXPORTING
261              im_eban = l_eban_old
262              im_ebkn = l_ebkn
263            IMPORTING
264              ex_mdpa = l_mdpa_old.
265    ENHANCEMENT-SECTION FM06BF04_BANF_AENDERN_01 SPOTS ES_SAPFM06B02 INCLUDE BOUND .
266
267    "{ Begin FM06BF04_BANF_AENDERN_01 ENHO ADSUB_FM06BF04 IS-AD-SUC AD_SUB }
268    * GA1468804
269          DATA: ls_ekpo TYPE ekpo.
270          MOVE-CORRESPONDING l_eban TO ls_ekpo.
271          CALL FUNCTION 'ME_COMPONENTS_MAINTAIN'
272            EXPORTING
273              i_ebelp    = l_eban-bnfpo
274              i_mdpa     = l_mdpa
275              i_mdpa_old = l_mdpa_old
276              i_txz01    = l_eban-txz01
277              i_vorga    = 'C'
278              is_ekpo    = ls_ekpo.
279    "{ End FM06BF04_BANF_AENDERN_01 ENHO ADSUB_FM06BF04 IS-AD-SUC AD_SUB }
280
281    END-ENHANCEMENT-SECTION.
282          IF l_eban-ebakz EQ space AND                          "500635
283             l_eban_old-ebakz NE space.
284            l_vorga = 'E'.
285          ENDIF.
286          IF l_eban-ebakz NE space AND
287             l_eban_old-ebakz EQ space.
288            l_vorga = 'L'.
289          ENDIF.
290          IF NOT l_vorga IS INITIAL.
291    ENHANCEMENT-SECTION FM06BF04_BANF_AENDERN_02 SPOTS ES_SAPFM06B02 INCLUDE BOUND .
292            CALL FUNCTION 'ME_COMPONENTS_MAINTAIN'
293              EXPORTING
294                i_ebelp    = l_eban-bnfpo
295                i_mdpa     = l_mdpa
296                i_mdpa_old = l_mdpa_old
297                i_txz01    = l_eban-txz01
298                i_vorga    = l_vorga.
299    END-ENHANCEMENT-SECTION.
300          ENDIF.                                                "500635
301          CALL FUNCTION 'ME_FILL_MDLB_FROM_EBAN'
302            EXPORTING
303              im_eban = l_eban
304              im_ebkn = l_ebkn
305            IMPORTING
306              ex_mdlb = l_mdlb.
307          APPEND l_mdlb TO lt_mdlb.
308        ENDLOOP.
309        IF NOT l_eban-banfn IS INITIAL.
310    * Verbuchung der Komponenten
311          CALL FUNCTION 'ME_COMPONENTS_UPDATE_PREPARE'
312            EXPORTING
313              i_number = l_eban-banfn
314            TABLES
315              t_mdlb   = lt_mdlb.
316        ENDIF.
317      ENDIF.
318
319    *- BAdI ME_REQ_POSTED
320      CLASS cl_badi_mm DEFINITION LOAD.
321      DATA: badi_req_inst   TYPE REF TO if_ex_me_req_posted.
322      badi_req_inst ?= cl_badi_mm=>get_instance( 'ME_REQ_POSTED' ).
323
324      IF NOT badi_req_inst IS INITIAL.
325        DATA: lt_ueban     TYPE mereq_t_ueban,
326              lt_ueban_old TYPE mereq_t_ueban,
327              lt_uebkn     TYPE mereq_t_uebkn,
328              lt_uebkn_old TYPE mereq_t_uebkn.
329        lt_ueban[]     = xeban[].
330        lt_ueban_old[] = yeban[].
331        lt_uebkn[]     = xebkn[].
332        lt_uebkn_old[] = yebkn[].
333        CALL METHOD badi_req_inst->posted
334          EXPORTING
335            im_eban     = lt_ueban
336            im_eban_old = lt_ueban_old
337            im_ebkn     = lt_uebkn
338            im_ebkn_old = lt_uebkn_old
339          EXCEPTIONS
340            OTHERS      = 0.
341      ENDIF.
342
343      COMMIT WORK.
344      REFRESH: xeban, yeban.
345      CLEAR:   xeban, yeban.
346
347    ENDFORM.                    "banf_aendern
*--- End of FM06BF04_BANF_AENDERN - 347 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF04_AENDERN_BANFS                    Level 2    Page 101
Object           SAPMZFM06B                                Lines 207
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *    Ändern Bestellanforderungen aus Tabelle BAT
4      *----------------------------------------------------------------------*
5      FORM aendern_banfs.
6
7        DATA: ucompl.
8        DATA: obatabix LIKE sy-tabix.
9        SORT bat BY banfn bnfpo.
10       SORT oba BY banfn bnfpo.
11
12       CLEAR xeban.
13       CLEAR ucompl.
14
15       LOOP AT bat.
16     *-- Änderungsberechtigung ---------------------------------------------*
17         IF gpfkey NE 'ZUOR' AND
18            gpfkey NE 'FREI'.
19           PERFORM berechtigungen_banf USING bat-ekorg bat-ekgrp
20                                             bat-werks bat-bsart.
21           IF sy-subrc NE 0.
22             zbere = zbere + 1.
23             DELETE bat.
24             CHECK 1 EQ 2.
25           ENDIF.
26         ELSEIF gpfkey EQ 'ZUOR'.
27           PERFORM berechtigungen_banf_ekorg USING bat-ekorg.
28           IF sy-subrc NE 0.
29             zbere = zbere + 1.
30             DELETE bat.
31             CHECK 1 EQ 2.
32           ENDIF.
33
34         ENDIF.
35     *-- Sperren -----------------------------------------------------------*
36         CALL FUNCTION 'ENQUEUE_EMEBANE'
37              EXPORTING
38                   banfn  = bat-banfn
39                   bnfpo  = bat-bnfpo
40              EXCEPTIONS
41                   OTHERS = 1.
42         IF sy-subrc NE 0.
43           zenqu = zenqu + 1.
44           DELETE bat.
45           CHECK 1 EQ 2.
46         ENDIF.
47     *-- Datenbank nachlesen -----------------------------------------------*
48         MOVE-CORRESPONDING bat TO bankey.
49         READ TABLE oba WITH KEY bankey BINARY SEARCH.
50         obatabix = sy-tabix.
51         IF sy-subrc NE 0.
52           zaend = zaend + 1.
53           DELETE bat.
54           CHECK 1 EQ 2.
55         ENDIF.
56         SELECT SINGLE *
57                FROM eban
58                WHERE banfn = bat-banfn
59                AND   bnfpo = bat-bnfpo.
60         IF sy-subrc NE 0.
61           zaend = zaend + 1.
62           DELETE bat.
63           CHECK 1 EQ 2.
64         ENDIF.
65         eban-waers = oba-waers.                                 "153409
66     *   sbat-flief = oba-flief.
67     *   sbat-ekorg = oba-ekorg.
68     *   sbat-vrtyp = oba-vrtyp.
69     *   sbat-konnr = oba-konnr.
70     *   sbat-ktpnr = oba-ktpnr.
71     *   sbat-infnr = oba-infnr.
72     *   sbat-lifnr = oba-lifnr.
73     *   sbat-bmein = oba-bmein.
74     *   sbat-reswk = oba-reswk.
75     *   if eban ne sbat.
76         IF eban NE oba.
77           zaend = zaend + 1.
78           DELETE bat.
79           CHECK 1 EQ 2.
80         ENDIF.
81
82     *-- Gruppenwechsel Banfnummer -----------------------------------------*
83         IF bat-banfn NE xeban-banfn AND
84            xeban-banfn NE space.
85           PERFORM banf_aendern USING ucompl.
86           CLEAR ucompl.
87         ENDIF.
88
89     *-- Kennz. für Matchcode setzen ---------------------------------------*
90         PERFORM setzen_zugba(sapfmmex)
91                 USING bat-zugba bat-flief bat-loekz
92                       bat-bsmng bat-menge bat-frgkz
93                       bat-ekorg bat-reswk bat-mprof bat-ematn.
94
95         IF bat-reswk NE oba-reswk.
96     * für Einzelfertigung bei Umlagerung
97           CALL FUNCTION 'ME_UMSOK_SETZEN'
98                EXPORTING
99                     i_matnr = bat-matnr
100                    i_reswk = bat-reswk
101                    i_sobkz = bat-sobkz
102               IMPORTING
103                    e_umsok = bat-umsok.
104        ENDIF.
105        zsich = zsich + 1.
106
107    *-- Füllen XEBAN - Banf neuer Stand -----------------------------------*
108        IF bat-updkz NE space.
109          ucompl = 'X'.
110        ENDIF.
111        MOVE bat TO xeban.
112        xeban-kz = 'U'.
113        xeban-erdat = sy-datum.
114        APPEND xeban.
115    *-- Füllen YEBAN - Banf alter Stand -----------------------------------*
116        MOVE eban TO yeban.
117        APPEND yeban.
118        MOVE-CORRESPONDING xeban TO oba.
119        MODIFY oba INDEX obatabix.
120      ENDLOOP.
121      PERFORM banf_aendern USING ucompl.
122      CLEAR ucompl.
123
124    *-- Refresh DCM manager
125      CALL FUNCTION 'MEDCMM_REFRESH'.
126
127    *-- Nicht alles gesichert -> Message-Pop-UP ---------------------------*
128      IF zbere NE 0 OR
129         zaend NE 0 OR
130         zenqu NE 0 OR
131         zfrei NE 0 OR
132         znoup NE 0 OR
133         zacce NE 0.        "*-- Note 739690
134
135        CALL FUNCTION 'MESSAGES_INITIALIZE'.
136
137        IF zsich NE 0.
138          CALL FUNCTION 'MESSAGE_STORE'
139               EXPORTING
140                    arbgb = 'ME'
141                    msgty = 'I'
142                    msgv1 = zsich
143                    txtnr = '146'.
144        ENDIF.
145        IF zbere NE 0.
146          CALL FUNCTION 'MESSAGE_STORE'
147               EXPORTING
148                    arbgb = 'ME'
149                    msgty = 'I'
150                    msgv1 = zbere
151                    txtnr = '147'.
152        ENDIF.
153        IF zenqu NE 0.
154          CALL FUNCTION 'MESSAGE_STORE'
155               EXPORTING
156                    arbgb = 'ME'
157                    msgty = 'I'
158                    msgv1 = zenqu
159                    txtnr = '148'.
160        ENDIF.
161        IF zaend NE 0.
162          CALL FUNCTION 'MESSAGE_STORE'
163               EXPORTING
164                    arbgb = 'ME'
165                    msgty = 'I'
166                    msgv1 = zaend
167                    txtnr = '149'.
168        ENDIF.
169        IF znoup NE 0.
170          CALL FUNCTION 'MESSAGE_STORE'
171               EXPORTING
172                    arbgb = 'ME'
173                    msgty = 'I'
174                    msgv1 = znoup
175                    txtnr = '150'.
176        ENDIF.
177        IF zfrei NE 0.
178          CALL FUNCTION 'MESSAGE_STORE'
179               EXPORTING
180                    arbgb = 'ME'
181                    msgty = 'I'
182                    msgv1 = zfrei
183                    txtnr = '153'.
184        ENDIF.
185    *-- Note 739690
186        IF zacce NE 0.
187          CALL FUNCTION 'MESSAGE_STORE'
188            EXPORTING
189              arbgb = 'ME'
190              msgty = 'I'
191              msgv1 = zacce
192              txtnr = '677'.
193        ENDIF.
194    *-- Note 739690
195
196        CALL FUNCTION 'MESSAGES_SHOW'
197             EXPORTING
198                  object     = text-006
199                  show_linno = space.
200
201      ELSE.
202        IF zsich NE 0.
203          MESSAGE s203.
204        ENDIF.
205      ENDIF.
206
207    ENDFORM.                    "aendern_banfs
*--- End of FM06BF04_AENDERN_BANFS - 207 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF04_BAN_AENDERN                      Level 2    Page 102
Object           SAPMZFM06B                                Lines 34
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *        Ändern Bestellanforderungen aus Grundliste
4      *----------------------------------------------------------------------*
5      FORM BAN_AENDERN.
6
7        REFRESH BAT.
8        CLEAR BAT.
9
10     *- Prüfen Berechtigung für die Bestellanforderungen -------------------
11       LOOP AT BAN WHERE UPDK1 EQ ZNEW OR
12                         UPDK1 EQ ZNER OR
13                         UPDK1 EQ ZRES OR
14                         UPDK1 EQ AEND.
15         MOVE BAN TO BAT.
16         IF BAN-UPDK1 = AEND OR BAN-UPDK1 = ZNER.
17           BAT-UPDKZ = 'X'.
18         ELSE.
19           CLEAR BAT-UPDKZ.
20         ENDIF.
21
22         APPEND BAT.
23       ENDLOOP.
24       CLEAR: ZSICH, ZENQU, ZAEND, ZBERE, ZNOUP.
25       PERFORM AENDERN_BANFS.
26       LOOP AT BAN WHERE UPDK1 EQ ZNEW OR
27                         UPDK1 EQ ZNER OR
28                         UPDK1 EQ ZRES OR
29                         UPDK1 EQ AEND.
30         INDEX_BAN = SY-TABIX.
31         PERFORM BAN_UPDATE_AENDERN.
32       ENDLOOP.
33
34     ENDFORM.
*--- End of FM06BF04_BAN_AENDERN - 34 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF04_BERECHTIGUNGEN_BANF              Level 2    Page 103
Object           SAPMZFM06B                                Lines 60
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      * Berechtigungen prüfen Banf                                           *
4      *----------------------------------------------------------------------*
5      FORM berechtigungen_banf USING beb_ekorg beb_ekgrp beb_werks beb_bsart.
6
7      *- Belegart -----------------------------------------------------------*
8        AUTHORITY-CHECK OBJECT 'M_BANF_BSA'
9             ID 'ACTVT' FIELD '02'
10            ID 'BSART' FIELD beb_bsart.
11       IF sy-subrc NE 0.
12         xauth = 'X'.
13         EXIT.
14       ENDIF.
15
16     *- Einkaufsorganisation -----------------------------------------------*
17       PERFORM berechtigungen_banf_ekorg USING beb_ekorg.
18       IF sy-subrc NE 0.
19         EXIT.
20       ENDIF.
21
22     *- Einkäufergruppe ----------------------------------------------------*
23       IF beb_ekgrp NE space.
24         AUTHORITY-CHECK OBJECT 'M_BANF_EKG'
25              ID 'ACTVT' FIELD '02'
26              ID 'EKGRP' FIELD beb_ekgrp.
27         IF sy-subrc NE 0.
28           xauth = 'X'.
29           EXIT.
30         ENDIF.
31       ENDIF.
32
33     *- WERK ---------------------------------------------------------------*
34       IF beb_werks NE space.
35         AUTHORITY-CHECK OBJECT 'M_BANF_WRK'
36              ID 'ACTVT' FIELD '02'
37              ID 'WERKS' FIELD beb_werks.
38         IF sy-subrc NE 0.
39           xauth = 'X'.
40           EXIT.
41         ENDIF.
42       ENDIF.
43
44     ENDFORM.
45
46     *---------------------------------------------------------------------*
47     *       FORM berechtigungen_banf_ekorg                                *
48     *---------------------------------------------------------------------*
49     FORM berechtigungen_banf_ekorg USING im_ekorg LIKE eban-ekorg.
50
51       IF im_ekorg NE space.
52         AUTHORITY-CHECK OBJECT 'M_BANF_EKO'
53              ID 'ACTVT' FIELD '02'
54              ID 'EKORG' FIELD im_ekorg.
55         IF sy-subrc NE 0.
56           xauth = 'X'.
57         ENDIF.
58       ENDIF.
59
60     ENDFORM.
*--- End of FM06BF04_BERECHTIGUNGEN_BANF - 60 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF04_BEZUGSQUELLE                     Level 2    Page 104
Object           SAPMZFM06B                                Lines 51
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *---------------------------------------------------------------------*
3      *       Bezugsquellenprüfung für manuell eingegebene Bezugsquelle     *
4      *---------------------------------------------------------------------*
5      FORM bezugsquelle.
6
7      *- Lieferantenname und Bezeichnung Einkaufsorganisation lesen --------*
8        PERFORM bezugsquelle_bezeichn.
9      *- Prüfen Bezugsquelle -----------------------------------------------*
10       CLEAR bueb.
11
12     * Begin CCP
13       bueb-beswk = eban-beswk.
14     * authority check
15       DATA: ls_eban_old TYPE eban.
16       MOVE-CORRESPONDING ban TO ls_eban_old.
17       IF NOT eban-beswk IS INITIAL OR
18          NOT ban-beswk  IS INITIAL.
19         PERFORM authority_beswk USING eban
20                                       ls_eban_old.
21       ENDIF.
22     * End CCP
23
24       bueb-flief = eban-flief.
25       bueb-ekorg = eban-ekorg.
26       bueb-infnr = eban-infnr.
27       bueb-konnr = eban-konnr.
28       bueb-ktpnr = eban-ktpnr.
29       bueb-reswk = eban-reswk.
30       bueb-ematn = eban-ematn.
31       bueb-mfrnr = eban-mfrnr.
32       bueb-mfrpn = eban-mfrpn.
33       bueb-emnfr = eban-emnfr.
34       PERFORM bezugsquelle_1 USING space.
35       PERFORM bezugsquelle_2.
36       MOVE ban TO eban.
37     *- Lieferantenname und Bezeichnung Einkaufsorganisation lesen --------*
38       PERFORM bezugsquelle_bezeichn.
39
40     *- Bildfolge bestimmen -----------------------------------------------*
41       IF ok-code EQ 'ORDP'.
42         IF ban-updk1 NE aend AND ban-updk1 NE zner.
43           ban-updk1 = znew.
44         ENDIF.
45         MODIFY ban INDEX index_ban.
46     *- Bild verlassen -----------------------------------------------------*
47         SET SCREEN 0.
48         LEAVE SCREEN.
49       ENDIF.
50
51     ENDFORM.                    "BEZUGSQUELLE
*--- End of FM06BF04_BEZUGSQUELLE - 51 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF04_BEZUGSQUELLE_1                   Level 2    Page 105
Object           SAPMZFM06B                                Lines 100
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *---------------------------------------------------------------------*
3      *       Bezugsquellenprüfung Teil 1                                   *
4      *---------------------------------------------------------------------*
5      FORM bezugsquelle_1 USING bq1_kz.
6
7        CLEAR bqpim.
8        CLEAR bqpex.
9
10       DATA: l_eban_new LIKE eban,
11             l_eban_old LIKE eban.
12
13       DATA l_lfa1 TYPE lfa1.                                    "657617
14
15       MOVE-CORRESPONDING ban TO l_eban_new.
16       MOVE-CORRESPONDING ban TO l_eban_old.
17
18       CALL FUNCTION 'ME_FILL_BQPIM_FROM_EBAN'
19         EXPORTING
20           i_eban_new = l_eban_new
21           i_eban_old = l_eban_old
22           i_t160d    = t160d
23         CHANGING
24           c_bqpim    = bqpim.
25       bqpim-vorga = 'BZ'.
26       bqpim-usequ = '?'.
27       bqpim-noquu = 'X'.                                        "361414
28       bqpim-flief = bueb-flief.            "BAN-FLIEF.
29       IF NOT bqpim-lifnr IS INITIAL.                            "380323
30         CALL FUNCTION 'WY_LFA1_SINGLE_READ'                     "657617
31         EXPORTING
32              pi_lifnr            = bqpim-lifnr
33     *           PI_BYPASSING_BUFFER =
34     *           PI_REFRESH_BUFFER   =
35         IMPORTING
36              po_lfa1             = l_lfa1
37         EXCEPTIONS
38              no_records_found    = 1
39              OTHERS              = 2.
40
41         IF l_lfa1-loevm NE space OR l_lfa1-sperm NE space.
42           CLEAR bqpim-lifnr.
43         ENDIF.                                                  "657617
44
45       ENDIF.                                                    "380323
46       bqpim-bewrk = bueb-reswk.            "BAN-RESWK.
47       bqpim-ekorg = bueb-ekorg.            "BAN-EKORG.
48       bqpim-infnr = bueb-infnr.            "BAN-INFNR.
49       bqpim-konnr = bueb-konnr.            "BAN-KONNR.
50       bqpim-ktpnr = bueb-ktpnr.            "BAN-KTPNR.
51       bqpim-beswk = bueb-beswk. " CCP
52     *-Mengen/Terminänderung berücksichtigen ------------------------------*
53       IF bq1_kz NE space.
54         bqpim-oldat = *eban-lfdat.
55         bqpim-olmng = *eban-menge.
56       ENDIF.
57
58     *  CALL FUNCTION 'ME_CHECK_SOURCE_OF_SUPPLY_1' " CCP
59       CALL FUNCTION 'ME_CHECK_SOURCE_OF_SUPPLY_1_EX' " CCP
60         EXPORTING
61           is_comim = bqpim
62         IMPORTING
63           es_comex = bqpex.
64       IF sy-subrc EQ 0.                                         "#EC *
65         bqpim-plifz = bqpex-plifz.
66         bueb-ematn = bqpex-ematn.
67         bueb-mfrnr = bqpex-mfrnr.
68         bueb-mfrpn = bqpex-mfrpn.
69         bueb-emnfr = bqpex-emnfr.
70         IF bueb-konnr NE space.
71     * Aus dem Vertrag abzuleitende Daten müssen hier doch übergeben werden,
72     * da sie in der Prüfung Teil 2 nicht mehr neu gesetzt werden
73           bueb-flief = bqpex-flief.
74           bueb-ekorg = bqpex-ekorg.
75           bqpim-flief = bqpex-flief.
76           bqpim-ekorg = bqpex-ekorg.
77         ENDIF.
78         IF bueb-infnr NE space.
79     * Aus dem Infosatz abzuleitende Daten müssen hier doch übergeben werden,
80     * da sie in der Prüfung Teil 2 nicht mehr neu gesetzt werden
81           bueb-flief = bqpex-flief.
82           bqpim-flief = bqpex-flief.
83           IF bueb-ekorg EQ space AND bqpex-ekorg NE space.      "385298
84             bueb-ekorg = bqpex-ekorg.                           "385298
85             bqpim-ekorg = bqpex-ekorg.                          "385298
86           ENDIF.                                                "385298
87         ENDIF.
88         IF bueb-flief NE space.
89     * Aus dem Infosatz abzuleitende Daten müssen hier doch übergeben werden,
90     * da sie in der Prüfung Teil 2 nicht mehr neu gesetzt werden
91           bueb-infnr = bqpex-infnr.
92           bqpim-infnr = bqpex-infnr.
93           IF bueb-ekorg EQ space AND bqpex-ekorg NE space.      "385298
94             bueb-ekorg = bqpex-ekorg.                           "385298
95             bqpim-ekorg = bqpex-ekorg.                          "385298
96           ENDIF.                                                "385298
97         ENDIF.
98       ENDIF.
99
100    ENDFORM.                    "bezugsquelle_1
*--- End of FM06BF04_BEZUGSQUELLE_1 - 100 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF04_BEZUGSQUELLE_2                   Level 2    Page 106
Object           SAPMZFM06B                                Lines 62
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *---------------------------------------------------------------------*
2      *       Bezugsquelle prüfen mit Quotierung und Orderbuch              *
3      *---------------------------------------------------------------------*
4      FORM bezugsquelle_2.
5
6        IF ban-matnr NE space AND ban-werks NE space.
7      *-- nur in dem Fall auch der Clear BQPEX, da noch nicht in BAN übertrage
8          CLEAR bqpex.
9          CALL FUNCTION 'ME_CHECK_SOURCE_OF_SUPPLY_2'
10           EXPORTING
11             comim = bqpim
12           IMPORTING
13             comex = bqpex.
14       ENDIF.
15       IF sy-subrc EQ 0.                                         "#EC *
16         ban-qunum = bqpex-qunum.
17         ban-qupos = bqpex-qupos.
18         ban-vrtyp = bqpex-vrtyp.
19         ban-konnr = bqpex-konnr.
20         ban-ktpnr = bqpex-ktpnr.
21         ban-ekorg = bqpex-ekorg.
22         ban-infnr = bqpex-infnr.
23         ban-ematn = bqpex-ematn.
24         ban-mfrnr = bqpex-mfrnr.
25         ban-mfrpn = bqpex-mfrpn.
26         ban-emnfr = bqpex-emnfr.
27         ban-plifz = bqpex-plifz.
28
29     * BQPEX-EMATN may also be filled when generic articles are involved,
30     * but in this case the EBAN-EMATN must not be filled
31         IF ban-attyp EQ attyp-var AND                           " 509521
32            ban-ematn EQ ban-satnr AND                           " 509521
33            bqpex-mprof IS INITIAL AND                           " 509521
34            bqpex-mfrpn IS INITIAL.                              " 509521
35           CLEAR: ban-ematn.                                     " 509521
36         ENDIF.                                                  " 509521
37
38         ban-beswk = bqpex-beswk. " CCP
39         IF ban-updk1 NE aend.
40     * Enter auf Dynpro 0104 -> IF-Zweig wird durchlaufen, BAN-UPDK1 gleich
41     * ZNER gesetzt; 'Bez.quelle zuordnen' auf Dynpro 0104 -> IF-Zweig
42     * erneut durchlaufen, Wert ZNER muß für BAN-UPDK1 erhalten bleiben
43     *     IF BQPEX-BEWRK NE BAN-RESWK.                          "161369
44           IF bqpex-bewrk NE ban-reswk OR ban-updk1 EQ zner.     "161369
45     *           Lieferwerk hat sich geändert --> muß über normalen
46     *                                            Verbucher gehen
47             ban-reswk = bqpex-bewrk.
48             ban-flief = bqpex-flief.
49             PERFORM bukrs_umlag.
50             ban-updk1 = zner.
51           ELSE.
52             ban-updk1 = znew.
53           ENDIF.
54         ENDIF.
55         ban-flief = bqpex-flief.
56         IF ban-bkuml NE space OR
57            ban-reswk EQ space.
58           ban-slief = bqpex-flief.
59         ENDIF.
60       ENDIF.
61
62     ENDFORM.                    "BEZUGSQUELLE_2
*--- End of FM06BF04_BEZUGSQUELLE_2 - 62 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF04_BEZUGSQUELLE_3                   Level 2    Page 107
Object           SAPMZFM06B                                Lines 179
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *---------------------------------------------------------------------*
3      *       Bezugsquelle suchen über Quotierung und Orderbuch             *
4      *---------------------------------------------------------------------*
5      FORM bezugsquelle_3.
6
7      *- Übergabestruktur füllen --------------------------------------------*
8        CLEAR bqpim.
9        CLEAR bqpex.
10       DATA: l_eban_new LIKE eban,
11             l_eban_old LIKE eban.
12
13       MOVE-CORRESPONDING ban TO l_eban_new.
14       MOVE-CORRESPONDING ban TO l_eban_old.
15
16       CALL FUNCTION 'ME_FILL_BQPIM_FROM_EBAN'
17         EXPORTING
18           i_eban_new = l_eban_new
19           i_eban_old = l_eban_old
20           i_t160d    = t160d
21         CHANGING
22           c_bqpim    = bqpim.
23       bqpim-vorga = 'BZ'.
24       bqpim-usequ = '?'.
25       bqpim-noquu = 'X'.                                        "361414
26       bqpim-liste = 'X'.
27       bqpim-msgno = 'X'.
28       bqpim-cdelt = t160v-cdelt.
29       PERFORM bqpim_dien_setzen.
30
31     * Begin CCP
32       DATA: lf_ccp_active TYPE c.
33       CALL FUNCTION 'ME_CCP_ACTIVE_CHECK'
34         IMPORTING
35           ef_ccp_active = lf_ccp_active.
36
37       IF NOT bqpim-beswk IS INITIAL AND
38          NOT lf_ccp_active IS INITIAL.
39
40         DATA: l_eban_sim    TYPE eban,
41               l_transtime   LIKE bqpex-plifz.
42     * check authority for assigning sources in procuring plant
43         AUTHORITY-CHECK OBJECT 'M_BANF_BWK'
44           ID 'ACTVT' FIELD '22'
45           ID 'BESWK' FIELD bqpim-beswk.
46
47         IF sy-subrc NE 0.
48           MESSAGE e207(mepo) WITH bqpim-beswk.
49         ENDIF.
50
51         MOVE-CORRESPONDING ban TO l_eban_sim.
52         CLEAR: l_eban_sim-beswk, l_eban_sim-lifnr, l_eban_sim-flief,
53                l_eban_sim-reswk, l_eban_sim-ekorg, l_eban_sim-infnr,
54                l_eban_sim-konnr, l_eban_sim-ktpnr, l_eban_sim-lgort.
55         l_eban_sim-werks = bqpim-beswk.
56
57         MOVE-CORRESPONDING l_eban_sim TO l_eban_new.
58         MOVE-CORRESPONDING l_eban_sim TO l_eban_old.
59
60         CALL FUNCTION 'ME_FILL_BQPIM_FROM_EBAN'
61           EXPORTING
62             i_eban_new = l_eban_new
63             i_eban_old = l_eban_old
64             i_t160d    = t160d
65           CHANGING
66             c_bqpim    = bqpim.
67
68     * todo adjust delivery date.
69         PERFORM calculate_transport_time IN PROGRAM saplmeqr
70                 USING    ban-werks
71                          l_eban_sim-werks
72                          l_eban_sim-matnr
73                          l_eban_sim-banfn
74                          l_eban_sim-bnfpo
75                 CHANGING l_transtime.
76
77         bqpim-nedat = bqpim-nedat - l_transtime.
78         IF bqpim-nedat LT sy-datlo.
79           bqpim-nedat = sy-datlo.
80         ENDIF.
81     * End CCP
82
83     *- Aufruf Funktionsbaustein zum Feststellen Bezugsquelle --------------*
84         CALL FUNCTION 'ME_SEARCH_SOURCE_OF_SUPPLY'
85           EXPORTING
86             comim        = bqpim
87             banfnummer   = ban-banfn
88             banfposition = ban-bnfpo
89           IMPORTING
90             comex        = bqpex.
91
92     * Begin CCP
93         IF NOT bqpex IS INITIAL.
94           bqpex-beswk =  ban-beswk.
95         ENDIF.
96
97       ELSE.
98         CALL FUNCTION 'ME_SEARCH_SOURCE_OF_SUPPLY_EXP'
99           EXPORTING
100            is_comim     = bqpim
101            if_preq_no   = ban-banfn
102            if_preq_pos  = ban-bnfpo
103          IMPORTING
104            es_comex     = bqpex
105          EXCEPTIONS
106            no_authority = 1
107            error_message = 2                      "3516172
108            OTHERS        = 3.                     "3516172
109        IF sy-subrc EQ 1.
110          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
111                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
112        ENDIF.
113      ENDIF.
114    * End CCP
115
116
117    *- Bezugsquelle gefunden - Banftabelle modifizieren -------------------*
118      IF sy-subrc EQ 0.
119        IF bqpex-flief NE ban-flief OR bqpex-bewrk NE ban-reswk OR
120           bqpex-konnr NE ban-konnr OR bqpex-ktpnr NE ban-ktpnr OR
121           bqpex-ekorg NE ban-ekorg OR bqpex-infnr NE ban-infnr OR
122           bqpex-reslo NE ban-reslo OR            "SSLOC
123           bqpex-beswk NE ban-beswk OR " CCP
124           bqpex-meins NE ban-bmein.
125    *-- nur, wenn Abweichung von vorhandener Bezugsquelle ---------------
126          IF ban-updk1 NE aend.
127            IF bqpex-bewrk NE ban-reswk OR
128               bqpex-reslo NE ban-reslo.     " SSLOC
129    *           Lieferwerk hat sich geändert --> muß über normalen
130    *                                            Verbucher gehen
131              ban-reswk = bqpex-bewrk.
132              ban-reslo = bqpex-reslo.       " SSLOC
133              ban-flief = bqpex-flief.
134              PERFORM bukrs_umlag.
135              ban-updk1 = zner.
136            ELSE.
137              ban-updk1 = znew.
138            ENDIF.
139          ENDIF.
140        ENDIF.
141        ban-qunum = bqpex-qunum.
142        ban-qupos = bqpex-qupos.
143        ban-vrtyp = bqpex-vrtyp.
144        ban-konnr = bqpex-konnr.
145        ban-ktpnr = bqpex-ktpnr.
146        ban-ekorg = bqpex-ekorg.
147        ban-infnr = bqpex-infnr.
148        ban-flief = bqpex-flief.
149    * set SRM contract no.                                      "2244897
150        ban-srm_contract_id  = bqpex-srm_contract_id.
151        ban-srm_contract_itm = bqpex-srm_contract_itm.
152        ban-ematn = bqpex-ematn.
153        ban-mfrnr = bqpex-mfrnr.
154        ban-mfrpn = bqpex-mfrpn.
155        ban-emnfr = bqpex-emnfr.
156        ban-plifz = bqpex-plifz.
157
158    * BQPEX-EMATN may also be filled when generic articles are involved,
159    * but in this case the EBAN-EMATN must not be filled
160        IF ban-attyp EQ attyp-var AND                           " 509521
161           ban-ematn EQ ban-satnr AND                           " 509521
162           bqpex-mprof IS INITIAL AND                           " 509521
163           bqpex-mfrpn IS INITIAL.                              " 509521
164          CLEAR: ban-ematn.                                     " 509521
165        ENDIF.                                                  " 509521
166
167        ban-beswk = bqpex-beswk. " CCP
168        IF ban-bkuml NE space OR
169           ban-reswk EQ space.
170          ban-slief = bqpex-flief.
171        ENDIF.
172        ban-lifnr = bqpex-lifnr.
173        ban-bmein = bqpex-meins.
174        IF bqpex-retco EQ '1'.
175          not_all_ordb = 'X'.
176        ENDIF.
177      ENDIF.
178
179    ENDFORM.                    "bezugsquelle_3
*--- End of FM06BF04_BEZUGSQUELLE_3 - 179 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF04_BEZUGSQUELLE_4                   Level 2    Page 108
Object           SAPMZFM06B                                Lines 180
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *---------------------------------------------------------------------*
3      *       Bezugsquelle suchen über Quotierung und Orderbuch für Batch   *
4      *---------------------------------------------------------------------*
5      FORM bezugsquelle_4.
6
7      *- Übergabestruktur füllen --------------------------------------------*
8        CLEAR bqpim.
9        CLEAR bqpex.
10       DATA: l_eban_new LIKE eban,
11             l_eban_old LIKE eban.
12
13       MOVE-CORRESPONDING ban TO l_eban_new.
14       MOVE-CORRESPONDING ban TO l_eban_old.
15
16       CALL FUNCTION 'ME_FILL_BQPIM_FROM_EBAN'
17         EXPORTING
18           i_eban_new = l_eban_new
19           i_eban_old = l_eban_old
20           i_t160d    = t160d
21         CHANGING
22           c_bqpim    = bqpim.
23       bqpim-vorga = 'BZ'.
24       bqpim-usequ = '?'.
25       bqpim-noquu = 'X'.                                        "361414
26       bqpim-liste = 'X'.                                        "642448
27       bqpim-msgno = 'X'.
28       bqpim-calcpr = 'X'.                                       "553618
29       bqpim-noaus = 'X'.                   "keine Auswahl
30       bqpim-nomei = 'X'.                   "keine Mengeneinheiten    4.0
31       bqpim-cdelt = t160v-cdelt.
32
33     * Begin CCP
34       DATA: lf_ccp_active TYPE c.
35       CALL FUNCTION 'ME_CCP_ACTIVE_CHECK'
36         IMPORTING
37           ef_ccp_active = lf_ccp_active.
38
39       IF NOT bqpim-beswk IS INITIAL AND
40          NOT lf_ccp_active IS INITIAL.
41
42         DATA: l_eban_sim    TYPE eban,
43               l_transtime   LIKE bqpex-plifz,
44               lf_auth       LIKE sy-subrc.
45
46         AUTHORITY-CHECK OBJECT 'M_BANF_BWK'
47                 ID 'ACTVT' FIELD '22'
48                 ID 'BESWK' FIELD bqpim-beswk.
49
50         IF sy-subrc NE 0.
51           MESSAGE e107(meccp) WITH bqpim-beswk.
52         ENDIF.
53
54         MOVE-CORRESPONDING ban TO l_eban_sim.
55         CLEAR: l_eban_sim-beswk, l_eban_sim-lifnr, l_eban_sim-flief,
56                l_eban_sim-reswk, l_eban_sim-ekorg, l_eban_sim-infnr,
57                l_eban_sim-konnr, l_eban_sim-ktpnr, l_eban_sim-lgort.
58         l_eban_sim-werks = bqpim-beswk.
59
60         MOVE-CORRESPONDING l_eban_sim TO l_eban_new.
61         MOVE-CORRESPONDING l_eban_sim TO l_eban_old.
62
63         CALL FUNCTION 'ME_FILL_BQPIM_FROM_EBAN'
64           EXPORTING
65             i_eban_new = l_eban_new
66             i_eban_old = l_eban_old
67             i_t160d    = t160d
68           CHANGING
69             c_bqpim    = bqpim.
70
71     * todo adjust delivery date.
72         PERFORM calculate_transport_time IN PROGRAM saplmeqr
73                 USING    ban-werks
74                          l_eban_sim-werks
75                          l_eban_sim-matnr
76                          l_eban_sim-banfn
77                          l_eban_sim-bnfpo
78                 CHANGING l_transtime.
79
80         bqpim-nedat = bqpim-nedat - l_transtime.
81         IF bqpim-nedat LT sy-datlo.
82           bqpim-nedat = sy-datlo.
83         ENDIF.
84     * End CCP
85
86     *- Aufruf Funktionsbaustein zum Feststellen Bezugsquelle --------------*
87         CALL FUNCTION 'ME_SEARCH_SOURCE_OF_SUPPLY'
88           EXPORTING
89             comim        = bqpim
90             banfnummer   = ban-banfn
91             banfposition = ban-bnfpo
92           IMPORTING
93             comex        = bqpex
94           EXCEPTIONS                             "3516172
95             error_message = 1.                   "3516172
96     * Begin CCP
97         IF NOT bqpex IS INITIAL.
98           bqpex-beswk =  ban-beswk.
99         ENDIF.
100      ELSE.
101        CALL FUNCTION 'ME_SEARCH_SOURCE_OF_SUPPLY_EXP'
102          EXPORTING
103            is_comim    = bqpim
104            if_preq_no  = ban-banfn
105            if_preq_pos = ban-bnfpo
106          IMPORTING
107            es_comex    = bqpex
108          EXCEPTIONS                             "3516172
109            error_message = 1.                   "3516172
110      ENDIF.
111    * End CCP
112
113    *- Bezugsquelle gefunden - Banftabelle modifizieren -------------------*
114      IF sy-subrc EQ 0.                                         "#EC *
115        IF bqpex-flief NE ban-flief OR bqpex-bewrk NE ban-reswk OR
116           bqpex-konnr NE ban-konnr OR bqpex-ktpnr NE ban-ktpnr OR
117           bqpex-ekorg NE ban-ekorg OR bqpex-infnr NE ban-infnr OR
118           bqpex-reslo NE ban-reslo OR     " SSLOC
119           bqpex-beswk NE ban-beswk OR " CCP
120           bqpex-meins NE ban-bmein.
121    *-- nur, wenn Abweichung von vorhandener Bezugsquelle ---------------
122          MOVE ban TO oba.
123          APPEND oba.
124          IF ban-updk1 NE aend.
125            IF bqpex-bewrk NE ban-reswk OR
126               bqpex-reslo NE ban-reslo.   " SSLOC
127    *           Lieferwerk hat sich geändert --> muß über normalen
128    *                                            Verbucher gehen
129              ban-reswk = bqpex-bewrk.
130              ban-reslo = bqpex-reslo.    " SSLOC
131              ban-flief = bqpex-flief.
132              PERFORM bukrs_umlag.
133              ban-updk1 = zner.
134            ELSE.
135              ban-updk1 = znew.
136            ENDIF.
137          ENDIF.
138          ban-qunum = bqpex-qunum.
139          ban-qupos = bqpex-qupos.
140          ban-vrtyp = bqpex-vrtyp.
141          ban-konnr = bqpex-konnr.
142          ban-ktpnr = bqpex-ktpnr.
143          ban-ekorg = bqpex-ekorg.
144          ban-infnr = bqpex-infnr.
145          ban-flief = bqpex-flief.
146    * set SRM contract no.                                      "2244897
147          ban-srm_contract_id  = bqpex-srm_contract_id.
148          ban-srm_contract_itm = bqpex-srm_contract_itm.
149          ban-ematn = bqpex-ematn.
150          ban-mfrnr = bqpex-mfrnr.
151          ban-mfrpn = bqpex-mfrpn.
152          ban-emnfr = bqpex-emnfr.
153          ban-plifz = bqpex-plifz.
154
155    * BQPEX-EMATN may also be filled when generic articles are involved,
156    * but in this case the EBAN-EMATN must not be filled
157          IF ban-attyp EQ attyp-var AND                         " 509521
158             ban-ematn EQ ban-satnr AND                         " 509521
159             bqpex-mprof IS INITIAL AND                         " 509521
160             bqpex-mfrpn IS INITIAL.                            " 509521
161            CLEAR: ban-ematn.                                   " 509521
162          ENDIF.                                                " 509521
163
164          ban-beswk = bqpex-beswk. " CCP
165          IF ban-bkuml NE space OR
166             ban-reswk EQ space.
167            ban-slief = bqpex-flief.
168          ENDIF.
169          ban-lifnr = bqpex-lifnr.
170          ban-bmein = bqpex-meins.
171          IF bqpex-retco EQ '1'.
172            not_all_ordb = 'X'.
173          ENDIF.
174          MOVE ban TO bat.
175          APPEND bat.
176          MODIFY ban INDEX index_ban.
177        ENDIF.
178      ENDIF.
179
180    ENDFORM.                    "bezugsquelle_4
*--- End of FM06BF04_BEZUGSQUELLE_4 - 180 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF04_BEZUGSQUELLE_5                   Level 2    Page 109
Object           SAPMZFM06B                                Lines 62
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *---------------------------------------------------------------------*
3      *       Bezugsquelle prüfen Orderbuch + Quotierung für Konsi          *
4      *---------------------------------------------------------------------*
5      FORM bezugsquelle_5.
6
7      *HECK BAN-MATNR NE SPACE AND BAN-WERKS NE SPACE.
8        CHECK ( ban-matnr NE space AND ban-werks NE space ) OR
9              ( ban-matnr EQ space AND
10               ( ban-flief NE space OR ban-infnr NE space OR
11                 ban-reswk NE space ) ).    "wegen Rahmenvertragsmeldung
12       CLEAR bqpim.
13       CLEAR bqpex.
14       DATA: l_eban_new LIKE eban,
15             l_eban_old LIKE eban.
16
17       MOVE-CORRESPONDING ban TO l_eban_new.
18       MOVE-CORRESPONDING ban TO l_eban_old.
19
20       CALL FUNCTION 'ME_FILL_BQPIM_FROM_EBAN'
21         EXPORTING
22           i_eban_new = l_eban_new
23           i_eban_old = l_eban_old
24           i_t160d    = t160d
25         CHANGING
26           c_bqpim    = bqpim.
27       bqpim-vorga = 'BZ'.
28       bqpim-usequ = '?'.
29       bqpim-noquu = 'X'.                                        "361414
30       CALL FUNCTION 'ME_CHECK_SOURCE_OF_SUPPLY_2'
31         EXPORTING
32           comim = bqpim
33         IMPORTING
34           comex = bqpex.
35       IF sy-subrc EQ 0.                                         "#EC *
36         ban-qunum = bqpex-qunum.
37         ban-qupos = bqpex-qupos.
38         ban-vrtyp = bqpex-vrtyp.
39         ban-konnr = bqpex-konnr.
40         ban-ktpnr = bqpex-ktpnr.
41         ban-ekorg = bqpex-ekorg.
42         ban-infnr = bqpex-infnr.
43         ban-reswk = bqpex-bewrk.
44         ban-flief = bqpex-flief.
45         ban-slief = bqpex-flief.
46         ban-ematn = bqpex-ematn.
47         ban-mfrnr = bqpex-mfrnr.
48         ban-mfrpn = bqpex-mfrpn.
49         ban-emnfr = bqpex-emnfr.
50         ban-plifz = bqpex-plifz.
51
52     * BQPEX-EMATN may also be filled when generic articles are involved,
53     * but in this case the EBAN-EMATN must not be filled
54         IF ban-attyp EQ attyp-var AND                           " 509521
55            ban-ematn EQ ban-satnr AND                           " 509521
56            bqpex-mprof IS INITIAL AND                           " 509521
57            bqpex-mfrpn IS INITIAL.                              " 509521
58           CLEAR: ban-ematn.                                     " 509521
59         ENDIF.                                                  " 509521
60       ENDIF.
61
62     ENDFORM.                    "bezugsquelle_5
*--- End of FM06BF04_BEZUGSQUELLE_5 - 62 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF04_BEZUGSQUELLE_6                   Level 2    Page 110
Object           SAPMZFM06B                                Lines 55
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *---------------------------------------------------------------------*
3      *       fortschreiben quotierung bei rücksetzen Zuordnung             *
4      *---------------------------------------------------------------------*
5      FORM bezugsquelle_6.
6
7        CHECK ban-matnr NE space AND ban-werks NE space.
8        CLEAR bqpim.
9        CLEAR bqpex.
10       DATA: l_eban_new LIKE eban,
11             l_eban_old LIKE eban.
12
13       MOVE-CORRESPONDING ban TO l_eban_new.
14       MOVE-CORRESPONDING ban TO l_eban_old.
15
16       CALL FUNCTION 'ME_FILL_BQPIM_FROM_EBAN'
17         EXPORTING
18           i_eban_new = l_eban_new
19           i_eban_old = l_eban_old
20           i_t160d    = t160d
21         CHANGING
22           c_bqpim    = bqpim.
23       bqpim-vorga = 'BZ'.
24       bqpim-usequ = '?'.
25       bqpim-noquu = 'X'.                                        "361414
26       bqpim-flief = space.
27       bqpim-ekorg = space.
28       bqpim-infnr = space.
29       bqpim-konnr = space.
30       bqpim-ktpnr = space.
31       CALL FUNCTION 'ME_CHECK_SOURCE_OF_SUPPLY_2'
32         EXPORTING
33           comim = bqpim
34         IMPORTING
35           comex = bqpex.
36       IF sy-subrc EQ 0.                                         "#EC *
37         ban-qunum = bqpex-qunum.
38         ban-qupos = bqpex-qupos.
39         ban-ematn = bqpex-ematn.
40         ban-mfrnr = bqpex-mfrnr.
41         ban-mfrpn = bqpex-mfrpn.
42         ban-emnfr = bqpex-emnfr.
43         ban-plifz = bqpex-plifz.
44
45     * BQPEX-EMATN may also be filled when generic articles are involved,
46     * but in this case the EBAN-EMATN must not be filled
47         IF ban-attyp EQ attyp-var AND                           " 509521
48            ban-ematn EQ ban-satnr AND                           " 509521
49            bqpex-mprof IS INITIAL AND                           " 509521
50            bqpex-mfrpn IS INITIAL.                              " 509521
51           CLEAR: ban-ematn.                                     " 509521
52         ENDIF.                                                  " 509521
53       ENDIF.
54
55     ENDFORM.                    "bezugsquelle_6
*--- End of FM06BF04_BEZUGSQUELLE_6 - 55 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF04_BEZUGSQUELLE_MANUELL             Level 2    Page 111
Object           SAPMZFM06B                                Lines 86
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *---------------------------------------------------------------------*
3      *       Bezugsquelle manuell zuordnen                                 *
4      *---------------------------------------------------------------------*
5      FORM bezugsquelle_manuell.
6
7        DATA: s_eban-konnr LIKE eban-konnr,                       "161369
8              s_eban-ktpnr LIKE eban-ktpnr,                       "161369
9              s_eban-flief LIKE eban-flief,                       "161369
10             s_eban-infnr LIKE eban-infnr,                       "161369
11             s_eban-reswk LIKE eban-reswk,                       "161369
12             s_eban-beswk LIKE eban-beswk, " CCP
13             s_eban-ekorg LIKE eban-ekorg,                       "161369
14             s_eban-matkl LIKE eban-matkl,                       "161369
15             s_eban-matnr LIKE eban-matnr.                       "161369
16       DATA: llfa1_name1 type ad_name1.          "IAV
17       DATA: l_use_cam TYPE c. "IAV
18
19
20       CLEAR: lfa1, t024e.
21
22     * Sichern der Eingaben von Dynpro 0104 und anschließendes Rücksichern
23     * ansonsten werden die Eingabedaten mit den Werten in den entsprechenden
24     * BAN-Feldern überschrieben                                 "161369
25       MOVE eban-konnr TO s_eban-konnr.                          "161369
26       MOVE eban-ktpnr TO s_eban-ktpnr.                          "161369
27       MOVE eban-flief TO s_eban-flief.                          "161369
28       MOVE eban-infnr TO s_eban-infnr.                          "161369
29       MOVE eban-ekorg TO s_eban-ekorg.                          "161369
30       MOVE eban-reswk TO s_eban-reswk.                          "161369
31       MOVE eban-matkl TO s_eban-matkl.                          "161369
32       MOVE eban-matnr TO s_eban-matnr.                          "161369
33       MOVE eban-beswk TO s_eban-beswk. " CCP
34
35       MOVE-CORRESPONDING ban TO eban.
36
37     * die Dynprofelder (EBAN-Felder) werden nur unter bestimmten
38     * Voraussetzungen mit den Werten des vorherigen Durchlaufs gefüllt
39       IF ( s_eban-matnr EQ ban-matnr AND ban-matnr NE space ) OR
40          ( s_eban-matkl EQ ban-matkl AND ban-matkl NE space
41                                      AND ban-matnr EQ space
42                                      AND s_eban-matnr EQ space ).
43         MOVE s_eban-konnr TO eban-konnr.                        "161369
44         MOVE s_eban-ktpnr TO eban-ktpnr.                        "161369
45         MOVE s_eban-flief TO eban-flief.                        "161369
46         MOVE s_eban-infnr TO eban-infnr.                        "161369
47         MOVE s_eban-ekorg TO eban-ekorg.                        "161369
48         MOVE s_eban-beswk TO eban-beswk.    " CCP
49         IF ban-pstyp EQ pstyp-umlg.                             "161369
50           MOVE s_eban-reswk TO eban-reswk.                      "161369
51         ENDIF.                                                  "161369
52       ENDIF.
53
54       IF eban-flief NE space.
55         IF cl_iav_mapping_util=>is_iav_active( ) EQ 'X'. "IAV
56           l_use_cam = 'X'.
57         ENDIF.
58     * ALRK021854 begin insert
59         CALL FUNCTION 'WY_LFA1_GET_NAME'
60           EXPORTING
61             pi_lifnr         = eban-flief
62             PI_READ_CAM      = l_use_cam           "IAV
63           IMPORTING
64             po_name1         = lfa1-name1
65             PO_CAM_NAME1     = llfa1_name1         "IAV
66           EXCEPTIONS
67             no_records_found = 1
68             OTHERS           = 2.
69          if not llfa1_name1 is initial.            "IAV
70            lfa1-name1 = llfa1_name1.
71          endif.
72     * ALRK021854 end insert - begin delete
73     *   call function 'ME_GET_SUPPLIER'
74     *        exporting
75     *             supplier = eban-flief
76     *        importing
77     *             name = lfa1-name1.
78     * ALRK021854 end delete
79       ENDIF.
80       IF eban-ekorg NE space.
81         SELECT SINGLE * FROM t024e WHERE ekorg EQ eban-ekorg.
82       ENDIF.
83       CALL SCREEN 104 STARTING AT 12 10
84                       ENDING AT   65 17.
85
86     ENDFORM.                    "BEZUGSQUELLE_MANUELL
*--- End of FM06BF04_BEZUGSQUELLE_MANUELL - 86 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF04_BEZUGSQUELLE_BEZEICHN            Level 2    Page 112
Object           SAPMZFM06B                                Lines 48
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *---------------------------------------------------------------------*
3      *  Lieferantenname und Bezeichnung Ekorg lesen                        *
4      *---------------------------------------------------------------------*
5      FORM BEZUGSQUELLE_BEZEICHN.
6      DATA: llfa1_name1 type ad_name1,             "IAV
7            l_use_cam TYPE c.
8        CLEAR: LFA1, T024E.
9      *- Lieferantennummer ins richtige Format bringen ---------------------*
10       IF EBAN-FLIEF NE SPACE.
11         CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
12              EXPORTING
13                   INPUT  = EBAN-FLIEF
14              IMPORTING
15                   OUTPUT = EBAN-FLIEF.
16     *- Lieferantennamen besorgen -----------------------------------------*
17         IF cl_iav_mapping_util=>is_iav_active( ) EQ 'X'.
18           l_use_cam = 'X'.
19         endif.
20     * ALRK021854 begin insert
21         CALL FUNCTION 'WY_LFA1_GET_NAME'
22              EXPORTING
23                   PI_LIFNR         = EBAN-FLIEF
24                   PI_READ_CAM      = l_use_cam          "IAV
25              IMPORTING
26                   PO_NAME1         = LFA1-NAME1
27                   PO_CAM_NAME1     = Llfa1_name1  "IAV
28              EXCEPTIONS
29                   NO_RECORDS_FOUND = 1
30                   OTHERS           = 2.
31         IF not llfa1_name1 is initial.
32           lfa1-name1 = llfa1_name1.
33         ENDIF.
34     * ALRK021854 end insert - begin delete
35     *  call function 'ME_GET_SUPPLIER'
36     *       exporting
37     *            supplier = eban-flief
38     *       importing
39     *            name = lfa1-name1.
40     * ALRK021854 end delete
41       ENDIF.
42
43     *- Bezeichnung Einkaufsorganisation lesen ----------------------------*
44       IF EBAN-EKORG NE SPACE.
45         SELECT SINGLE * FROM T024E WHERE EKORG EQ EBAN-EKORG.
46       ENDIF.
47
48     ENDFORM.
*--- End of FM06BF04_BEZUGSQUELLE_BEZEICHN - 48 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF04_BQPIM_T160D_SETZEN               Level 2    Page 113
Object           SAPMZFM06B                                Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *---------------------------------------------------------------------*
3      *  T160D-Parameter setzen für Bezugsquellen                           *
4      *---------------------------------------------------------------------*
5      FORM BQPIM_T160D_SETZEN.
6
7        IF T160D-EBZKA EQ SPACE.             "Kontrakte zuordnen nicht erlaubt
8          BQPIM-EBZKA = 'X'.
9        ENDIF.
10       IF T160D-EBZKM EQ SPACE.  "Kontrakte Postyp M zuordnen nicht erlaubt
11         BQPIM-EBZKM = 'X'.
12       ENDIF.
13       IF T160D-EBZKW EQ SPACE.  "Kontrakte Postyp W zuordnen nicht erlaubt
14         BQPIM-EBZKW = 'X'.
15       ENDIF.
16       IF T160D-EBZIN EQ SPACE.             "Infosätze zuordnen nicht erlaubt
17         BQPIM-EBZIN = 'X'.
18       ENDIF.
19      IF T160D-EBZOM EQ SPACE.  "Pos ohne Material --> zuordnen nicht erlaubt
20         BQPIM-EBZOM = 'X'.
21       ENDIF.
22
23     ENDFORM.
*--- End of FM06BF04_BQPIM_T160D_SETZEN - 23 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF04_BQPIM_DIEN_SETZEN                Level 2    Page 114
Object           SAPMZFM06B                                Lines 21
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *---------------------------------------------------------------------*
2      *       FORM BQPIM_DIEN_SETZEN                                        *
3      *---------------------------------------------------------------------*
4      *       ........                                                      *
5      *---------------------------------------------------------------------*
6      FORM BQPIM_DIEN_SETZEN.
7
8        CHECK BAN-PSTYP = '9'.
9
10       IF BAN-BUKRS NE T001-BUKRS.
11         SELECT SINGLE * FROM T001 WHERE BUKRS EQ BAN-BUKRS.
12         CHECK SY-SUBRC = 0.
13       ENDIF.
14
15       IF NOT ( BAN-WAERS IS INITIAL ).
16         BQPIM-WAERS = BAN-WAERS.
17       ELSE.
18         BQPIM-WAERS = T001-WAERS.
19       ENDIF.
20
21     ENDFORM.
*--- End of FM06BF04_BQPIM_DIEN_SETZEN - 21 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF04_BUKRS_UMLAG                      Level 2    Page 115
Object           SAPMZFM06B                                Lines 32
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *  Prüfen buchungskreisübergreifende Umlagerung                        *
4      *----------------------------------------------------------------------*
5      FORM BUKRS_UMLAG.
6
7        DATA: HBUKRS LIKE T001K-BUKRS.
8        CLEAR BAN-BKUML.
9
10       IF BAN-WERKS NE T001W-WERKS.
11         SELECT SINGLE * FROM T001W WHERE WERKS EQ BAN-WERKS.
12       ENDIF.
13       IF T001K-BWKEY NE T001W-BWKEY.
14         SELECT SINGLE * FROM T001K WHERE BWKEY EQ T001W-BWKEY.
15       ENDIF.
16       HBUKRS = T001K-BUKRS.
17       BAN-BUKRS = HBUKRS.
18
19       CHECK BAN-RESWK NE SPACE.
20       CHECK BAN-FLIEF NE SPACE.
21       CHECK BAN-WERKS NE BAN-RESWK.
22       IF BAN-RESWK NE T001W-WERKS.
23         SELECT SINGLE * FROM T001W WHERE WERKS EQ BAN-RESWK.
24       ENDIF.
25       IF T001K-BWKEY NE T001W-BWKEY.
26         SELECT SINGLE * FROM T001K WHERE BWKEY EQ T001W-BWKEY.
27       ENDIF.
28       IF T001K-BUKRS NE HBUKRS.
29         BAN-BKUML = 'X'.
30       ENDIF.
31
32     ENDFORM.
*--- End of FM06BF04_BUKRS_UMLAG - 32 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF04_DET_CHECK                        Level 2    Page 116
Object           SAPMZFM06B                                Lines 37
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *  Selektionskriterien Banfs zur Zuorddnung prüfen                     *
4      *----------------------------------------------------------------------*
5      FORM det_check.
6
7        sy-subrc = 4.
8        IF det NE space.
9          CHECK ban-bsart EQ det-bsart.
10         IF det-updkz EQ 'XX'.
11           CHECK ban-updk1 NE alif AND
12                 ban-updk1 NE anfr.
13           CHECK ban-ekorg EQ det-ekorg.
14           CHECK ban-slief EQ det-slief.
15           CHECK ban-reswk EQ det-reswk.
16           CHECK ban-beswk EQ det-beswk.   " CCP
17           CHECK ban-konnr EQ det-konnr.
18           CHECK ban-fordn EQ det-fordn.
19           CHECK ban-bukrs EQ det-bukrs.
20         ELSE.
21           CHECK det-updkz EQ ban-updk1.
22         ENDIF.
23         IF det-updkz EQ alif.
24           CHECK ban-ekorg EQ det-ekorg.
25           CHECK ban-slief EQ det-slief.
26           CHECK ban-bukrs EQ det-bukrs.
27         ENDIF.
28         IF det-updkz EQ anfr.
29           CHECK ban-ekorg EQ det-ekorg.
30           CHECK ban-bukrs EQ det-bukrs.
31         ENDIF.
32       ELSE.
33         CHECK ban-updk2 NE aman.
34       ENDIF.
35       CLEAR sy-subrc.
36
37     ENDFORM.                    "DET_CHECK
*--- End of FM06BF04_DET_CHECK - 37 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF04_CUEB_FUELLEN                     Level 2    Page 117
Object           SAPMZFM06B                                Lines 13
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *        Übergabestruktur beim Auswählen füllen                        *
4      *----------------------------------------------------------------------*
5      FORM CUEB_FUELLEN.
6
7        CLEAR CUEB.
8        CUEB-BANFN = BAN-BANFN.
9        CUEB-BNFPO = BAN-BNFPO.
10       EXPORT CUEB TO MEMORY ID 'XYZ'.
11       LEAVE.
12
13     ENDFORM.
*--- End of FM06BF04_CUEB_FUELLEN - 13 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF04_FUELLEN_SELOPT                   Level 2    Page 118
Object           SAPMZFM06B                                Lines 100
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *        Select-Options für Rahmenverträge füllen                      *
4      *----------------------------------------------------------------------*
5      FORM FUELLEN_SELOPT.
6
7      *- Gültige Belegarten und Positionstypen ermitteln --------------------*
8        REFRESH: SEL_BSART, SEL_PSTYP.
9        CLEAR  : SEL_BSART, SEL_PSTYP.
10       SEL_BSART-SIGN = 'I'.
11       SEL_BSART-OPTION = 'EQ'.
12       SEL_PSTYP-SIGN = 'I'.
13       SEL_PSTYP-OPTION = 'EQ'.
14
15     * SELECT * FROM T161A WHERE BANBS EQ BAN-BSART
16     *                     AND   BANPT EQ BAN-PSTYP
17     *                     AND   LFPET NE SPACE.
18       SELECT * FROM T161A WHERE BANBS EQ BAN-BSART
19                           AND   BANPT EQ BAN-PSTYP.
20         IF BAN-KNTTP NE SPACE.
21           CHECK T161A-KONTI EQ SPACE.
22         ENDIF.
23         SEL_BSART-LOW = T161A-BSTBS.
24         COLLECT SEL_BSART.
25         SEL_PSTYP-LOW = T161A-BSTPT.
26         COLLECT SEL_PSTYP.
27       ENDSELECT.
28
29     *- Anz. RV zur Materialklasse und Materialnummer nicht initial
30     *- nur RVs mit Positionstyp 'M' oder 'W'
31       IF SY-UCOMM EQ 'LRAC' AND
32          BAN-MATNR NE SPACE.
33         REFRESH SEL_PSTYP.
34         CLEAR   SEL_PSTYP.
35         SEL_PSTYP-SIGN = 'I'.
36         SEL_PSTYP-OPTION = 'EQ'.
37         SEL_PSTYP-LOW = '4'. COLLECT SEL_PSTYP.
38         SEL_PSTYP-LOW = '8'. COLLECT SEL_PSTYP.
39       ENDIF.
40     *- Einschränken M/W nach Funktionsberechtigung ------------------------*
41       IF T160D-EBZKA NE SPACE.
42         IF BAN-MATNR NE SPACE AND
43            T160D-EBZKM EQ SPACE AND
44            T160D-EBZKW EQ SPACE.
45         ELSE.
46           IF T160D-EBZKM EQ SPACE.
47             LOOP AT SEL_PSTYP WHERE LOW EQ '4'.
48               DELETE SEL_PSTYP.
49             ENDLOOP.
50           ENDIF.
51           IF T160D-EBZKW EQ SPACE.
52             LOOP AT SEL_PSTYP WHERE LOW EQ '8'.
53               DELETE SEL_PSTYP.
54             ENDLOOP.
55           ENDIF.
56         ENDIF.
57       ENDIF.
58
59     *- Prüfen, ob Selektionstabelle wenigstens einen Eintrag hat ----------*
60       CLEAR EXITFLAG.
61       READ TABLE SEL_BSART INDEX 1.
62       IF SY-SUBRC EQ 0.
63         READ TABLE SEL_PSTYP INDEX 1.
64       ENDIF.
65       IF SY-SUBRC NE 0.
66         MESSAGE S208 WITH BAN-BSART BAN-PSTYP.
67         EXITFLAG = 'X'.
68         EXIT.
69       ENDIF.
70
71     *- Selopt für Positionstyp ins externe Format bringen -----------------*
72       CALL FUNCTION 'ME_ITEM_CATEGORY_SELOPT_OUTPUT'
73            TABLES
74                 SEL_PSTYP = SEL_PSTYP.
75
76     *- Füllen gültige Werke in Selektionstabelle --------------------------*
77       REFRESH SEL_WERKS.
78       SEL_WERKS-SIGN = 'I'.
79       SEL_WERKS-OPTION = 'EQ'.
80       SEL_WERKS-LOW = SPACE.
81       APPEND SEL_WERKS.
82       SEL_WERKS-LOW = BAN-WERKS.
83       APPEND SEL_WERKS.
84
85     *- Füllen gültige Kontierungstypen in Selektionstabelle ---------------*
86       REFRESH SEL_KNTTP.
87       SEL_KNTTP-SIGN = 'I'.
88       SEL_KNTTP-OPTION = 'EQ'.
89       IF BAN-KZVBR NE 'U'.
90         SEL_KNTTP-LOW = SPACE.
91         APPEND SEL_KNTTP.
92         IF BAN-KNTTP NE SPACE.
93           SEL_KNTTP-LOW = BAN-KNTTP.
94           APPEND SEL_KNTTP.
95           SEL_KNTTP-LOW = 'U'.
96           APPEND SEL_KNTTP.
97         ENDIF.
98       ENDIF.
99
100    ENDFORM.
*--- End of FM06BF04_FUELLEN_SELOPT - 100 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF04_HELP_EBELN                       Level 2    Page 119
Object           SAPMZFM06B                                Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *EJECT
2      *----------------------------------------------------------------------*
3      *        F4-Hilfe bei externer Belegnummer                             *
4      *----------------------------------------------------------------------*
5      FORM HELP_EBELN USING HEE_FELD.
6
7        MESSAGE S246(06).
8        SET CURSOR FIELD HEE_FELD.
9
10     ENDFORM.
*--- End of FM06BF04_HELP_EBELN - 10 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF04_LESEN_MATERIAL_KONSI             Level 2    Page 120
Object           SAPMZFM06B                                Lines 16
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *        Lesen Material-Konsipreissegment                              *
4      *----------------------------------------------------------------------*
5      FORM LESEN_MATERIAL_KONSI.
6
7        CALL FUNCTION 'MATERIAL_LESEN'
8             EXPORTING
9                  SCHLUESSEL = MTCOM
10            IMPORTING
11                 MATDATEN   = MT06K
12                 RETURN     = MTCOR
13            TABLES
14                 SEQMAT01   = KON.
15
16     ENDFORM.
*--- End of FM06BF04_LESEN_MATERIAL_KONSI - 16 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF04_LESEN_INFO                       Level 2    Page 121
Object           SAPMZFM06B                                Lines 67
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *
3      * 152367 12.05.1999 PH Banf zur Anfrage vormerken
4      *
5      *----------------------------------------------------------------------*
6      *        Lesen Infosätze zum Material zur Anfragezuordnung             *
7      *----------------------------------------------------------------------*
8      FORM lesen_info.
9
10     * PERFORM MATERIALNUMMER_SETZEN                       "152367
11     *             USING                                   "152367
12     *                BAN-MATNR                            "152367
13     *                BAN-EMATN                            "152367
14     *                BAN-MPROF                            "152367
15     *                SEL_MATNR.                           "152367
16
17       CLEAR bqpim.
18     * BQPIM-MATNR = SEL_MATNR.                            "152367
19       bqpim-matnr = ban-matnr.                                  "152367
20       bqpim-ematn = ban-ematn.                                  "152367
21       bqpim-mprof = ban-mprof.
22       bqpim-matkl = ban-matkl.
23       bqpim-satnr = ban-satnr.
24       bqpim-attyp = ban-attyp.
25       bqpim-pstyp = ban-pstyp.
26     * Begin CCP
27     *  BQPIM-WERKS = BAN-WERKS.
28       IF ban-beswk IS INITIAL.
29         bqpim-werks = ban-werks.
30       ELSE.
31         bqpim-werks = ban-beswk.
32       ENDIF.
33     * End CCP
34       bqpim-noaus = 'X'.
35
36       CALL FUNCTION 'ME_READ_INFORECORDS_MAT'
37         EXPORTING
38           comim     = bqpim
39         TABLES
40           xlief     = alfu
41         EXCEPTIONS
42           not_found = 01.
43
44       IF sy-subrc NE 0.
45         EXIT.
46       ENDIF.
47
48       CLEAR alf.
49       LOOP AT alfu.
50         alfkey-banfn = ban-banfn.
51         alfkey-bnfpo = ban-bnfpo.
52         alfkey-lifnr = alfu-lifnr.
53         alfkey-ekorg = alfu-ekorg.
54         READ TABLE alf WITH KEY alfkey BINARY SEARCH.
55         CASE sy-subrc.
56           WHEN 04.
57             MOVE-CORRESPONDING alfkey TO alf.
58             alf-beswk = bqpim-beswk. " CCP
59             INSERT alf INDEX sy-tabix.
60           WHEN 08.
61             MOVE-CORRESPONDING alfkey TO alf.
62             alf-beswk = bqpim-beswk. " CCP
63             APPEND alf.
64         ENDCASE.
65       ENDLOOP.
66
67     ENDFORM.                    "LESEN_INFO
*--- End of FM06BF04_LESEN_INFO - 67 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF04_MODIFY_SCREEN                    Level 2    Page 122
Object           SAPMZFM06B                                Lines 79
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *        Modifizieren Loop-Zeilen in Lieferanten-POP-UP                *
4      *----------------------------------------------------------------------*
5      FORM modify_screen.
6
7        DATA: lf_ccp_active TYPE c. " CCP
8
9        LOOP AT SCREEN.
10     *- Keine Eingabe bei Anzeigetransaktion  ------------------------------*
11         IF screen-group1 NE 'SEL'.
12           IF gpfkey NE 'BEAR' AND
13              gpfkey NE 'ZUOR'.
14             screen-input = 0.
15           ENDIF.
16         ENDIF.
17         CASE screen-group4.
18     *- Selektionskennzeichen bei mehreren Lieferanten - hier Lieferant eing.
19           WHEN '001'.
20             IF lfm1-lifnr EQ space.
21               screen-input = 0.
22             ENDIF.
23     *- Lieferant usw. nicht überschreibbar, wenn bereits vorhanden --------*
24           WHEN '002'.
25             IF lfm1-lifnr NE space.
26               screen-input = 0.
27             ENDIF.
28     *- Fester Lieferant und Ekorg bei Umlagerung nicht eingabebereit ------*
29     *     WHEN '003'.                     "ab 3.0 nicht mehr
30     *        IF BAN-PSTYP EQ '7'.
31     *           SCREEN-INPUT = 0.
32     *           SCREEN-INVISIBLE = 1.
33     *        ENDIF.
34     *- Lieferwerk nur bei Pstyp Umlagerung eingabebereit ------------------*
35     *     WHEN '004'.                       "ab 3.0 nicht mehr
36     *        IF BAN-PSTYP NE '7'.
37     *           SCREEN-INPUT = 0.
38     *           SCREEN-INVISIBLE = 1.
39     *        ENDIF.
40     *------- Funktionsberechtigung: kein Infosatz -------------------------*
41           WHEN '003'.                                           "395590
42             IF t160d-ebzin EQ space.
43               screen-input = '0'.
44             ELSE.
45               IF t160d-ebzom EQ space AND
46                  ban-matnr EQ space.
47                 screen-input = '0'.
48               ENDIF.
49             ENDIF.
50     *------- Funktionsberechtigung: kein Vertrag --------------------------*
51           WHEN '005'.                                           "395590
52             IF t160d-ebzka EQ space.
53               screen-input = '0'.
54             ELSE.
55               IF t160d-ebzom EQ space AND
56                  ban-matnr EQ space.
57                 screen-input = '0'.
58               ENDIF.
59             ENDIF.
60
61         ENDCASE.
62
63     * Begin CCP
64         IF sy-dynnr EQ '0104' AND
65            screen-name EQ 'EBAN-BESWK'.
66           CALL FUNCTION 'ME_CCP_ACTIVE_CHECK'
67             IMPORTING
68               ef_ccp_active = lf_ccp_active.
69           IF lf_ccp_active IS INITIAL.
70             screen-input = '0'.
71             screen-invisible = '1'.
72           ENDIF.
73         ENDIF.
74     * End CCP
75
76         MODIFY SCREEN.
77       ENDLOOP.
78
79     ENDFORM.                    "MODIFY_SCREEN
*--- End of FM06BF04_MODIFY_SCREEN - 79 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF04_PRUEFEN_EINGABEN                 Level 2    Page 123
Object           SAPMZFM06B                                Lines 139
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *        Eingaben auf POP-UPs prüfen                                   *
4      *----------------------------------------------------------------------*
5      FORM PRUEFEN_EINGABEN.
6
7        DATA: I_T024 LIKE T024.
8
9        CASE SY-DYNGR.
10     *- POP-UP: Generieren Bestellung --------------------------------------*
11         WHEN 'POPF'.
12     *- Prüfen Bestellart --------------------------------------------------*
13           EKKO-BSTYP = 'F'.
14     *     PERFORM BSART(SAPFMMEX) USING RM06E-BSART EKKO-BSTYP EKKO-BSAKZ
15     *                             CHANGING T161 T161T.
16
17           CALL FUNCTION 'MEXF_BSART'
18                EXPORTING
19                     I_BSART = RM06E-BSART
20                     I_BSTYP = EKKO-BSTYP
21                IMPORTING
22                     E_BSAKZ = EKKO-BSAKZ
23                     E_T161  = T161
24                     E_T161T = T161T
25                EXCEPTIONS
26                     OTHERS  = 1.
27
28     *- Prüfen Bestelldatum ------------------------------------------------*
29           IF RM06E-BEDAT NE 0.
30             IF RM06E-BEDAT < SY-DATLO.
31               MESSAGE W214.
32             ENDIF.
33           ELSE.
34             MESSAGE E220.
35           ENDIF.
36     *- Prüfen externe Nummer ----------------------------------------------*
37           IF RM06E-BSTNR NE SPACE.
38             PERFORM PRUEFEN_NUMMER(SAPFMMEX) USING RM06E-BSTNR SPACE T161.
39           ENDIF.
40
41     *- POP-UP: Generieren Anfrage -----------------------------------------*
42         WHEN 'POPA'.
43     *- Prüfen Anfrageart --------------------------------------------------*
44           EKKO-BSTYP = 'A'.
45     *     PERFORM BSART(SAPFMMEX) USING RM06E-ASART EKKO-BSTYP EKKO-BSAKZ
46     *                             CHANGING T161 T161T.
47           CALL FUNCTION 'MEXF_BSART'
48                EXPORTING
49                     I_BSART = RM06E-ASART
50                     I_BSTYP = EKKO-BSTYP
51                IMPORTING
52                     E_BSAKZ = EKKO-BSAKZ
53                     E_T161  = T161
54                     E_T161T = T161T
55                EXCEPTIONS
56                     OTHERS  = 1.
57     *- Prüfen Anfragedatum ------------------------------------------------*
58           IF RM06E-ANFDT NE 0.
59             IF RM06E-ANFDT < SY-DATLO.
60               MESSAGE W216.
61             ENDIF.
62           ELSE.
63             MESSAGE E219.
64           ENDIF.
65     *- Prüfen Angebotsdatum -----------------------------------------------*
66           IF EKKO-ANGDT < SY-DATLO.
67             MESSAGE W215.
68           ENDIF.
69     *- Prüfen externe Anfragenummer ---------------------------------------*
70           IF RM06E-ANFNR NE SPACE.
71             PERFORM PRUEFEN_NUMMER(SAPFMMEX) USING RM06E-ANFNR SPACE T161.
72           ENDIF.
73     *- Prüfen Sprache - Fremdschlüssel noch nicht aktiviert ---------------*
74           SELECT SINGLE * FROM T002 WHERE SPRAS EQ RM06E-SPRAS.
75           IF SY-SUBRC NE 0.
76             MESSAGE E221.                  "WITH RM06E-SPRAS.
77           ENDIF.
78     *- Prüfen Lieferant ---------------------------------------------------*
79           IF EKKO-LIFNR NE SPACE.
80             DATA: LS_LFM1 LIKE LFM1,
81                   LS_LFA1 LIKE LFA1.                                "682995
82             CALL FUNCTION 'VENDOR_MASTER_DATA_SELECT_00'
83                  EXPORTING
84                       I_LFA1_LIFNR               = EKKO-LIFNR
85                       I_LFM1_EKORG               = EKKO-EKORG
86                       I_DATA                     = 'X'
87                  IMPORTING
88                       A_LFA1                     = ls_lfa1           "682995
89                       A_LFM1                     = ls_lfm1
90                  EXCEPTIONS
91                       VENDOR_NOT_FOUND           = 01
92                       OTHERS                     = 02.
93     *      PERFORM LFM1_LESEN(SAPFMMEX) USING EKKO-LIFNR EKKO-EKORG
94     *                                   CHANGING *LFM1.
95             IF SY-SUBRC NE 0.
96               MESSAGE E321(06) WITH EKKO-LIFNR EKKO-EKORG.
97             ENDIF.
98     *         Supplier blocked or deleted: Same behaviuor like with ME41
99             IF LS_LFA1-SPERM NE SPACE.                              "682995
100              MESSAGE E022 WITH LS_LFA1-LIFNR.
101            Endif.
102            IF LS_LFA1-lOEVM NE SPACE.
103              PERFORM ENACO(SAPFMMEX) USING 'ME' '024'.
104              CASE SY-SUBRC.
105              WHEN 1.
106                MESSAGE W024 WITH LS_LFA1-LIFNR.
107              WHEN 2.
108                MESSAGE E024 WITH LS_LFA1-LIFNR.
109              ENDCASE.
110            ENDIF.
111            IF LS_LFM1-SPERM NE SPACE.
112              MESSAGE E023 WITH LS_LFM1-LIFNR LS_LFM1-EKORG.
113            ENDIF.
114            IF LS_LFM1-lOEVM NE SPACE.
115              PERFORM ENACO(SAPFMMEX) USING 'ME' '025'.
116              CASE SY-SUBRC.
117              WHEN 1.
118                MESSAGE W025 WITH LS_LFM1-LIFNR LS_LFM1-EKORG.
119              WHEN 2.
120                MESSAGE E025 WITH LS_LFM1-LIFNR LS_LFM1-EKORG.
121              ENDCASE.
122
123            ENDIF.                                                  "682995
124
125            IF EKKO-LIFNR NE LS_LFM1-LIFNR.
126              CLEAR LS_LFM1.
127              MESSAGE E027(06) WITH EKKO-LIFNR EKKO-EKORG.
128            ENDIF.
129          ENDIF.
130      ENDCASE.
131
132    *- Prüfen Einkaufsgruppe ----------------------------------------------*
133      PERFORM EKGRP(SAPFMMEX) USING EKKO-EKGRP
134                              CHANGING I_T024.
135    *- Prüfen Einkaufsorganisation ----------------------------------------*
136      PERFORM EKORG_CHECK(SAPFMMEX) USING EKKO-EKORG
137                                    CHANGING T024E.
138
139    ENDFORM.
*--- End of FM06BF04_PRUEFEN_EINGABEN - 139 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF04_PRUEFEN_ESTKZ                    Level 2    Page 124
Object           SAPMZFM06B                                Lines 31
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *        Pruefen Erstellungskennzeichen      92105   - neu zu 3.1I/4.0C*
4      *----------------------------------------------------------------------*
5      FORM PRUEFEN_ESTKZ.
6
7        CLEAR: COUNTA, COUNTN.
8      *- Ermitteln alten Tabellenindex --------------------------------------*
9        DESCRIBE TABLE BAT LINES COUNTA.
10
11     *- Bereinigen Übergabetabelle um die nicht teilbestellbaren Banfs -----*
12       LOOP AT BAT.
13         CHECK BAT-ESTKZ EQ 'V'.
14         IF BAT-BSMNG NE 0.
15           DELETE BAT.
16         ENDIF.
17       ENDLOOP.
18
19     *- Ermitteln neuen Tabellenindex --------------------------------------*
20       DESCRIBE TABLE BAT LINES COUNTN.
21       IF COUNTN LT COUNTA.
22     *- kein Eintrag mehr in Übergabetabelle -------------------------------*
23         IF COUNTN EQ 0.
24           MESSAGE E580.
25         ELSE.
26     *- einige sind rausgeflogen -------------------------------------------*
27           MESSAGE S579.
28         ENDIF.
29       ENDIF.
30
31     ENDFORM.
*--- End of FM06BF04_PRUEFEN_ESTKZ - 31 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF04_PRUEFEN_FREIGABE_ANF             Level 2    Page 125
Object           SAPMZFM06B                                Lines 32
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *        Pruefen, ob Banfs für Anfrage freigegeben                     *
4      *----------------------------------------------------------------------*
5      FORM PRUEFEN_FREIGABE_ANF.
6
7      *- Ermitteln alten Tabellenindex --------------------------------------*
8        DESCRIBE TABLE BAT LINES COUNTA.
9
10     *- Bereinigen Übergabetabelle um die nicht freigegebenen Banfs --------*
11       LOOP AT BAT.
12         IF BAT-FRGKZ NE SPACE.
13           SELECT SINGLE * FROM T161S WHERE FRGKZ EQ BAT-FRGKZ.
14           IF T161S-FRANG EQ SPACE.
15             DELETE BAT.
16           ENDIF.
17         ENDIF.
18       ENDLOOP.
19
20     *- Ermitteln neuen Tabellenindex --------------------------------------*
21       DESCRIBE TABLE BAT LINES COUNTN.
22       IF COUNTN LT COUNTA.
23     *- kein Eintrag mehr in Übergabetabelle -------------------------------*
24         IF COUNTN EQ 0.
25           MESSAGE E263.
26         ELSE.
27     *- einige sind rausgeflogen -------------------------------------------*
28           MESSAGE S262.
29         ENDIF.
30       ENDIF.
31
32     ENDFORM.
*--- End of FM06BF04_PRUEFEN_FREIGABE_ANF - 32 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF04_PRUEFEN_FREIGABE_BEST            Level 2    Page 126
Object           SAPMZFM06B                                Lines 32
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *        Pruefen, ob Banfs für Bestellung freigegeben                  *
4      *----------------------------------------------------------------------*
5      FORM PRUEFEN_FREIGABE_BEST.
6
7      *- Ermitteln alten Tabellenindex --------------------------------------*
8        DESCRIBE TABLE BAT LINES COUNTA.
9
10     *- Bereinigen Übergabetabelle um die nicht freigegebenen Banfs --------*
11       LOOP AT BAT.
12         IF BAT-FRGKZ NE SPACE.
13           SELECT SINGLE * FROM T161S WHERE FRGKZ EQ BAT-FRGKZ.
14           IF T161S-FRBST EQ SPACE.
15             DELETE BAT.
16           ENDIF.
17         ENDIF.
18       ENDLOOP.
19
20     *- Ermitteln neuen Tabellenindex --------------------------------------*
21       DESCRIBE TABLE BAT LINES COUNTN.
22       IF COUNTN LT COUNTA.
23     *- kein Eintrag mehr in Übergabetabelle -------------------------------*
24         IF COUNTN EQ 0.
25           MESSAGE E265.
26         ELSE.
27     *- einige sind rausgeflogen -------------------------------------------*
28           MESSAGE S264.
29         ENDIF.
30       ENDIF.
31
32     ENDFORM.
*--- End of FM06BF04_PRUEFEN_FREIGABE_BEST - 32 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF04_TOP                              Level 2    Page 127
Object           SAPMZFM06B                                Lines 161
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *        Überschrift                                                   *
4      *----------------------------------------------------------------------*
5      FORM TOP.
6      *- Überschrift Kontierung ---------------------------------------------*
7        IF COM-BKMKZ NE SPACE AND
8           COM-SRTKZ EQ '8'.
9          CASE COM-BKMKZ.
10           WHEN '1'. WRITE / TEXT-K01.
11           WHEN '2'. WRITE / TEXT-K02.
12           WHEN '3'. WRITE / TEXT-K03.
13           WHEN '4'. WRITE / TEXT-K04.
14           WHEN '5'. WRITE / TEXT-K05.
15           WHEN '6'. WRITE / TEXT-K06.
16           WHEN '8'. WRITE / TEXT-K06.                           "602972
17           WHEN '7'. WRITE /.
18         ENDCASE.
19         WRITE:   UEBKNT2 COLOR COL_BACKGROUND INTENSIFIED OFF.
20         SKIP.
21       ENDIF.
22     *- Überschrift Zuordnung ----------------------------------------------*
23       IF LISTE EQ 'G' AND
24          DET NE SPACE.
25         IF DET-RESWK NE SPACE.
26           WRITE: / TEXT-064,
27                    DET-RESWK COLOR COL_BACKGROUND INTENSIFIED OFF.
28           IF DET-SLIEF NE SPACE.
29             WRITE:  TEXT-058,
30                     DET-SLIEF COLOR COL_BACKGROUND INTENSIFIED OFF.
31           ENDIF.
32         ELSE.
33           IF DET-SLIEF NE SPACE.
34             WRITE: / TEXT-058,
35                      DET-SLIEF COLOR COL_BACKGROUND INTENSIFIED OFF.
36           ELSE.
37             WRITE: / TEXT-059.
38           ENDIF.
39         ENDIF.
40         IF DET-EKORG NE SPACE.
41           WRITE: TEXT-061,
42                  DET-EKORG COLOR COL_BACKGROUND INTENSIFIED OFF.
43         ENDIF.
44         CASE DET-UPDKZ.
45           WHEN 'XX'.
46             IF DET-KONNR NE SPACE.
47               WRITE:  TEXT-052,
48                       DET-KONNR COLOR COL_BACKGROUND INTENSIFIED OFF.
49             ENDIF.
50           WHEN ANFR.
51             WRITE TEXT-120.
52           WHEN ALIF.
53             WRITE TEXT-120.
54         ENDCASE.
55         SKIP.
56       ENDIF.
57
58     ENHANCEMENT-SECTION     TOP_01 SPOTS ES_SAPFM06B.
59       ULINE.
60     END-ENHANCEMENT-SECTION.
61       FORMAT COLOR COL_HEADING INTENSIFIED.
62       CASE SY-PFKEY.
63     *-- Liste der Zuordnungen --------------------------------------------*
64         WHEN ZPFKEY.
65           IF ZUG-RESWK NE SPACE.
66             WRITE: / TEXT-113.
67           ELSE.
68             WRITE: / TEXT-111.
69           ENDIF.
70     *-- Konsilieferanten aus Zuordnen ------------------------------------*
71         WHEN 'KONS'.
72           WRITE: / TEXT-005.
73     *-- Konsilieferanten aus Banfliste allgemein -------------------------*
74         WHEN 'KONA'.
75           WRITE: / TEXT-005.
76     *-- Grundliste --------------------------------------------------------*
77         WHEN OTHERS.
78           IF NOT BAN-GSFRG IS INITIAL AND NOT GS_BANF IS INITIAL.
79     ENHANCEMENT-SECTION     TOP_02 SPOTS ES_SAPFM06B.
80             WRITE: / TEXT-G01.
81             WRITE: / TEXT-U08.
82     END-ENHANCEMENT-SECTION.
83           ENDIF.
84           LOOP AT XT16LD WHERE LHEAD NE SPACE.
85             CASE XT16LD-LHEAD.
86               WHEN 'U01'.
87                 IF NOT BAN-GSFRG IS INITIAL AND NOT GS_BANF IS INITIAL.
88                   CHECK NOT T16LB-GSPOS IS INITIAL.
89                 ENDIF.
90     ENHANCEMENT-SECTION     TOP_03 SPOTS ES_SAPFM06B.
91                 WRITE: / TEXT-U01.
92     END-ENHANCEMENT-SECTION.
93               WHEN 'U02'.
94                 IF BAN-GSFRG IS INITIAL OR GS_BANF IS INITIAL.
95     ENHANCEMENT-SECTION     TOP_04 SPOTS ES_SAPFM06B.
96                   WRITE: / TEXT-U02.
97     END-ENHANCEMENT-SECTION.
98                 ELSEIF NOT T16LB-GSPOS IS INITIAL.
99                   WRITE: / TEXT-G02.
100                ENDIF.
101              WHEN 'U03'.
102                IF NOT BAN-GSFRG IS INITIAL AND NOT GS_BANF IS INITIAL.
103                  CHECK NOT T16LB-GSPOS IS INITIAL.
104                ENDIF.
105    ENHANCEMENT-SECTION     TOP_05 SPOTS ES_SAPFM06B.
106                WRITE: / TEXT-U03.
107    END-ENHANCEMENT-SECTION.
108              WHEN 'U04'.
109                IF NOT BAN-GSFRG IS INITIAL AND NOT GS_BANF IS INITIAL.
110                  CHECK NOT T16LB-GSPOS IS INITIAL.
111                ENDIF.
112    ENHANCEMENT-SECTION     TOP_06 SPOTS ES_SAPFM06B.
113                WRITE: / TEXT-U04.
114    END-ENHANCEMENT-SECTION.
115              WHEN 'U05'.
116                IF NOT BAN-GSFRG IS INITIAL AND NOT GS_BANF IS INITIAL.
117                  CHECK NOT T16LB-GSPOS IS INITIAL.
118                ENDIF.
119    ENHANCEMENT-SECTION     TOP_07 SPOTS ES_SAPFM06B.
120                WRITE: / TEXT-U05.
121    END-ENHANCEMENT-SECTION.
122              WHEN 'U06'.
123                IF NOT BAN-GSFRG IS INITIAL AND NOT GS_BANF IS INITIAL.
124                  CHECK NOT T16LB-GSPOS IS INITIAL.
125                ENDIF.
126    ENHANCEMENT-SECTION     TOP_08 SPOTS ES_SAPFM06B.
127                WRITE: / TEXT-U06.
128    END-ENHANCEMENT-SECTION.
129              WHEN 'U07'.
130                IF NOT BAN-GSFRG IS INITIAL AND NOT GS_BANF IS INITIAL.
131                  CHECK NOT T16LB-GSPOS IS INITIAL.
132                ENDIF.
133    ENHANCEMENT-SECTION     TOP_09 SPOTS ES_SAPFM06B.
134                WRITE: / TEXT-U07.
135    END-ENHANCEMENT-SECTION.
136              WHEN 'U08'.
137                IF BAN-GSFRG IS INITIAL.
138    ENHANCEMENT-SECTION     TOP_10 SPOTS ES_SAPFM06B.
139                  WRITE: / TEXT-U08.
140    END-ENHANCEMENT-SECTION.
141                ENDIF.
142              WHEN 'U21'.
143                IF NOT BAN-GSFRG IS INITIAL AND NOT GS_BANF IS INITIAL.
144                  CHECK NOT T16LB-GSPOS IS INITIAL.
145                ENDIF.
146    ENHANCEMENT-SECTION     TOP_11 SPOTS ES_SAPFM06B.
147                WRITE: / TEXT-U21.
148    END-ENHANCEMENT-SECTION.
149              WHEN OTHERS.
150    ENHANCEMENT-POINT TOP_12 SPOTS ES_SAPFM06B.
151
152            ENDCASE.
153          ENDLOOP.
154      ENDCASE.
155    ENHANCEMENT-SECTION     TOP_13 SPOTS ES_SAPFM06B.
156      ULINE.
157    END-ENHANCEMENT-SECTION.
158
159    ENDFORM.
160
161    ENHANCEMENT-POINT TOP_14 SPOTS ES_SAPFM06B STATIC .
*--- End of FM06BF04_TOP - 161 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF04_VALID_LINE                       Level 2    Page 128
Object           SAPMZFM06B                                Lines 14
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *   Check gültige Zeile
4      *----------------------------------------------------------------------*
5      FORM VALID_LINE.
6
7        CLEAR EXITFLAG.
8        IF HIDE-INDEX EQ 0.
9          MESSAGE S201.
10         EXITFLAG = 'X'.
11         CLEAR SY-UCOMM.
12       ENDIF.
13
14     ENDFORM.
*--- End of FM06BF04_VALID_LINE - 14 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF04_ZUORDNEN                         Level 2    Page 129
Object           SAPMZFM06B                                Lines 19
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *---------------------------------------------------------------------*
3      *  Durchführen der Zuordnung für Batch                                *
4      *---------------------------------------------------------------------*
5      FORM ZUORDNEN.
6
7        PERFORM INIT_EFUBE.
8        IF com-srtkz EQ '0'.                  "823004
9          SORT BAN BY MATNR WERKS ASCENDING.
10       ELSE.                                 "823004
11         PERFORM ban_sort.                   "823004
12       ENDIF.                                "823004
13       LOOP AT BAN.
14         INDEX_BAN = SY-TABIX.
15         PERFORM BEZUGSQUELLE_4.
16       ENDLOOP.
17       PERFORM BAN_AENDERN.
18
19     ENDFORM.
*--- End of FM06BF04_ZUORDNEN - 19 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF04_INIT_EFUBE                       Level 2    Page 130
Object           SAPMZFM06B                                Lines 39
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *  Funktionsberechtigung
4      *----------------------------------------------------------------------*
5      FORM INIT_EFUBE.
6
7        CLEAR T160D.
8        T160D-EPRSA = 'X'.
9        T160D-EPRSZ = 'X'.
10       T160D-EOHNM = 'X'.
11       T160D-ERFBL = 'X'.
12       T160D-ERFAN = 'X'.
13       T160D-ERFAG = 'X'.
14       T160D-ERFKA = 'X'.
15       T160D-ERFKM = 'X'.
16       T160D-ERFKW = 'X'.
17       T160D-ERFBA = 'X'.
18       T160D-ERFB1 = 'X'.
19       T160D-ERFB2 = 'X'.
20       T160D-ERFIN = 'X'.
21       T160D-EMANU = 'X'.
22       T160D-EBZKA = 'X'.
23       T160D-EBZKM = 'X'.
24       T160D-EBZKW = 'X'.
25       T160D-EBZIN = 'X'.
26       T160D-EBZOM = 'X'.
27       T160D-ERES1 = 'X'.
28       T160D-ERES2 = 'X'.
29       T160D-ERES3 = 'X'.
30       GET PARAMETER ID 'EFB' FIELD EFUBE.
31       SELECT SINGLE * FROM T160D WHERE EFUBU = EFUBE.
32
33     *- Steuerung Vorschlagswerte -----------------------------------------*
34       GET PARAMETER ID 'EVO' FIELD EVOPA.
35       IF EVOPA NE T160V-EVOPA.
36         SELECT SINGLE * FROM T160V WHERE EVOPA = EVOPA.
37       ENDIF.
38
39     ENDFORM.
*--- End of FM06BF04_INIT_EFUBE - 39 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF04_OBA_AUFBAUEN                     Level 2    Page 131
Object           SAPMZFM06B                                Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *----------------------------------------------------------------------*
2      *  Gelesenen Stand der Banfs sichern                                  *
3      *----------------------------------------------------------------------*
4      FORM OBA_AUFBAUEN.
5        LOOP AT BAN.
6          MOVE BAN TO OBA.
7          APPEND OBA.
8        ENDLOOP.
9        SORT OBA BY BANFN BNFPO.
10     ENDFORM.
*--- End of FM06BF04_OBA_AUFBAUEN - 10 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF04_OBA_UPDATE_BEST                  Level 2    Page 132
Object           SAPMZFM06B                                Lines 31
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *----------------------------------------------------------------------*
2      * Fortschreiben des gelesenen Standes OBA nach Anlegen einer Bestellung*
3      * oder Lieferplaneinteilung um folgende Felder:                        *
4      * STATU, BVDAT, BVDRK, EBELN, EBELP, BEDAT und BSMNG                   *
5      *----------------------------------------------------------------------*
6      FORM oba_update_best.
7
8        LOOP AT batu.
9          MOVE-CORRESPONDING batu TO bankey.
10         READ TABLE oba WITH KEY bankey.
11         IF sy-subrc IS INITIAL.
12           oba-statu = batu-statu.
13           oba-bvdat = batu-bvdat.
14           oba-bvdrk = batu-bvdrk.
15           IF batu-vrtyp EQ 'L'.
16             oba-ebeln = batu-konnr.
17           ELSE.
18             GET PARAMETER ID 'BES' FIELD oba-ebeln.
19           ENDIF.
20           oba-ebelp = batu-ebelp.
21           oba-bedat = batu-bedat.
22           oba-bsmng = batu-bsmng.
23           CASE batu-ebakz.                                      "319095
24             WHEN '0'. CLEAR oba-ebakz.
25             WHEN '1'. oba-ebakz = 'X'.
26             WHEN OTHERS. oba-ebakz = batu-ebakz.
27           ENDCASE.
28           MODIFY oba INDEX sy-tabix.
29         ENDIF.
30       ENDLOOP.
31     ENDFORM.
*--- End of FM06BF04_OBA_UPDATE_BEST - 31 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF04_PRUEFEN_LSTUB                    Level 2    Page 133
Object           SAPMZFM06B                                Lines 101
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *----------------------------------------------------------------------*
2      *  Prüfen Listumfang                                                  *
3      *----------------------------------------------------------------------*
4      FORM pruefen_lstub USING prl_lstub.
5
6        DATA: l_scope TYPE string40.
7
8        IF sy-tcode = 'ME56' OR sy-tcode = 'ME57'.
9
10         SELECT SINGLE * FROM t16lb WHERE lstub EQ prl_lstub.
11         IF sy-subrc NE 0.
12           MESSAGE e287 WITH prl_lstub.
13         ENDIF.
14         IF t16lb-dynpr EQ 0 AND t16lb-alvgr EQ space.
15           SELECT * FROM t16ll WHERE lstub EQ prl_lstub.
16             EXIT.
17           ENDSELECT.
18           IF sy-subrc NE 0.
19             MESSAGE e287 WITH prl_lstub.
20           ENDIF.
21         ENDIF.
22
23     * check whether generic reporting should be used ( hooks )
24         IF gpfkey NE space AND t16lb-alvgr NE space.
25     ** the report was started in the conventional mode and the user
26     ** decided to change lstub to the enjoy version: not possible
27     *    MESSAGE e287 WITH prl_lstub.
28         ELSE.
29           l_scope = prl_lstub.
30           CALL FUNCTION 'ME_REP_GET_TABLE_MANAGER'
31             EXPORTING
32               im_scope   = l_scope
33             IMPORTING
34               ex_manager = gf_factory.
35         ENDIF.
36
37       ELSE.
38
39         CALL FUNCTION 'ME_REP_GET_TABLE_MANAGER'
40           EXPORTING
41             im_scope   = l_scope
42           IMPORTING
43             ex_manager = gf_factory.
44
45       ENDIF.
46
47       IF gf_factory IS INITIAL.
48         IF prl_lstub IS INITIAL.
49           prl_lstub = 'A'.
50         ENDIF.
51         SELECT SINGLE * FROM t16lb WHERE lstub EQ prl_lstub.
52         IF sy-subrc NE 0.
53           MESSAGE e287 WITH prl_lstub.
54         ENDIF.
55         IF t16lb-dynpr EQ 0 AND t16lb-alvgr EQ space.
56           SELECT * FROM t16ll WHERE lstub EQ prl_lstub.
57             EXIT.
58           ENDSELECT.
59           IF sy-subrc NE 0.
60             MESSAGE e287 WITH prl_lstub.
61           ENDIF.
62         ENDIF.
63       ENDIF.
64
65     ENDFORM.                    "PRUEFEN_LSTUB
66
67     *----------------------------------------------------------------------*
68     *  FORCE_ALV: Forces ALV grid for output             new with ERP 1.0 PA
69     *----------------------------------------------------------------------*
70
71     FORM force_alv USING im_p_alv TYPE c.
72
73       CHECK NOT im_p_alv IS INITIAL.
74       CHECK gf_factory IS INITIAL.
75
76       CALL FUNCTION 'ME_REP_GET_TABLE_MANAGER'
77         IMPORTING
78           ex_manager = gf_factory.
79
80     ENDFORM.                    "force_alv
81
82     *----------------------------------------------------------------------*
83     *  COUNT_WORKLOAD: Count workload for purchasing agent
84     *                                                    new with ERP 1.0 PA
85     *----------------------------------------------------------------------*
86
87     FORM count_workload USING im_not_found TYPE c
88                               im_p_wlmem   TYPE memory_id.
89
90       CHECK NOT im_p_wlmem IS INITIAL.                "only in count mode
91
92       DATA: lf_count           TYPE workload.
93
94       IF im_not_found IS INITIAL.
95         lf_count = lines( ban[] ).                      "count workload
96       ENDIF.
97
98       EXPORT wl = lf_count TO MEMORY ID im_p_wlmem.
99       LEAVE PROGRAM.
100
101    ENDFORM.                    "COUNT_WORKLOAD
*--- End of FM06BF04_PRUEFEN_LSTUB - 101 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF04_VORSCHLAGEN_LSTUB                Level 2    Page 134
Object           SAPMZFM06B                                Lines 14
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *  Vorschlagen Listumfang                                             *
4      *----------------------------------------------------------------------*
5      FORM vorschlagen_lstub USING vol_lstub.
6
7        SELECT SINGLE * FROM t16lh WHERE tcode EQ sy-tcode.
8        IF sy-subrc EQ 0.
9          vol_lstub = t16lh-lstub.
10       ENDIF.
11     *-- Note 739690
12       REFRESH t_excluded.
13     *-- Note 739690
14     ENDFORM.                    "VORSCHLAGEN_LSTUB
*--- End of FM06BF04_VORSCHLAGEN_LSTUB - 14 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF04_XT16LL_AUFBAUEN                  Level 2    Page 135
Object           SAPMZFM06B                                Lines 66
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *  Tabelle der Routinen zum Listumfang aufbauen
4      *----------------------------------------------------------------------*
5      FORM XT16LL_AUFBAUEN.
6
7      *- Definition des Listumfangs -----------------------------------------*
8        SELECT SINGLE * FROM T16LB WHERE LSTUB = COM-LSTUB.
9        IF SY-SUBRC NE 0.
10         MESSAGE E287 WITH COM-LSTUB.
11       ENDIF.
12     *- Default für fehlende Detail-Subscreens setzen ----------------------*
13       IF T16LB-SDYN1 EQ 0.
14         T16LB-SDYN1 = 400.
15       ENDIF.
16       IF T16LB-SDYN2 EQ 0.
17         T16LB-SDYN2 = 400.
18       ENDIF.
19       IF T16LB-SDYN3 EQ 0.
20         T16LB-SDYN3 = 400.
21       ENDIF.
22     *- Zusätzliche Daten zum Listumfang -----------------------------------*
23       REFRESH XT16LI.
24       SELECT * FROM T16LI APPENDING TABLE XT16LI
25                           WHERE LSTUB EQ T16LB-LSTUB.
26
27     *- Zeilenaufbau zum Listumfang ----------------------------------------*
28       CLEAR: XZLTYP, XZEILE.
29       CLEAR: XSZEIL, XSZTYP.
30       REFRESH EXCL.
31       IF T16LB-DYNPR EQ 0.
32         REFRESH XT16LD.
33         SELECT * FROM T16LL WHERE LSTUB = COM-LSTUB.
34           SELECT SINGLE * FROM T16LD WHERE LLIST EQ T16LL-LLIST.
35           IF SY-SUBRC EQ 0.
36             XT16LD = T16LD.
37             XT16LD-STATZ = T16LL-STATZ.                         "gt
38             APPEND XT16LD.
39             IF T16LL-STATZ NE SPACE.
40               XZEILE = SY-TABIX - 1.
41               IF XZLTYP EQ SPACE.
42                 XZLTYP = T16LD-ZEILE.
43               ENDIF.
44             ENDIF.
45           ENDIF.
46         ENDSELECT.
47         IF SY-SUBRC NE 0.
48           MESSAGE E287 WITH COM-LSTUB.
49         ENDIF.
50     *- 'Abbrechen Zeile' nur bei Dynpro -----------------------------------*
51         EXCL-FUNKTION = 'EXIL'.
52         APPEND EXCL.
53
54     *- Zeilennummer der Selektions- und Zuorddnungszeile ermitteln --------*
55         LOOP AT XT16LD.
56           IF XT16LD-SZEIL NE SPACE.
57             IF XSZTYP EQ SPACE.
58               XSZEIL = SY-TABIX - 1.
59               XSZTYP = 'X'.
60             ENDIF.
61           ENDIF.
62         ENDLOOP.
63       ELSE.
64         XZLTYP = '4'.
65       ENDIF.
66     ENDFORM.
*--- End of FM06BF04_XT16LL_AUFBAUEN - 66 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF04_DIEN_READ_PO                     Level 2    Page 136
Object           SAPMZFM06B                                Lines 44
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&      Form  DIEN_READ_PO
3      *&---------------------------------------------------------------------*
4      *       Bestellung lesen/pruefen/sperren fuer Erstellen ErfBlatt
5      *----------------------------------------------------------------------*
6      FORM DIEN_READ_PO USING I_EBELN I_EBELP.
7
8      * Bestellung lesen
9        SELECT SINGLE * FROM EKKO WHERE EBELN EQ I_EBELN.
10       IF SY-SUBRC NE 0 or ekko-memory ne space or ekko-loekz ne space.
11         MESSAGE E505(SE) WITH EKKO-EBELN.
12       ENDIF.
13
14     * Pruefen ob noch freizugeben
15       IF EKKO-FRGRL NE SPACE.
16         SELECT SINGLE * FROM T160M WHERE MSGVS = '00'
17                                    AND   ARBGB = 'SE'
18                                    AND   MSGNR = '529'.
19         IF SY-SUBRC = 0 AND
20            T160M-MSGTP = 'E'.
21           MESSAGE E529(SE).
22         ENDIF.
23       ENDIF.
24
25     * Bestellposition lesen
26       IF EKPO-EBELN NE I_EBELN OR
27          EKPO-EBELP NE I_EBELP.
28         SELECT SINGLE * FROM EKPO
29                WHERE EBELN EQ I_EBELN
30                AND   EBELP EQ I_EBELP
31                AND   PSTYP EQ '9'
32                AND   LOEKZ EQ SPACE.
33         IF SY-SUBRC NE 0.
34           MESSAGE E506(SE).
35         ENDIF.
36       ENDIF.
37
38     * Bestellung sperren
39       CALL FUNCTION 'MM_ENQUEUE_DOCUMENT'
40            EXPORTING
41                 I_EBELN = I_EBELN
42                 I_BSTYP = BSTYP-BEST.
43
44     ENDFORM.                               " DIEN_READ_PO
*--- End of FM06BF04_DIEN_READ_PO - 44 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF05                                  Level 1    Page 137
Object           SAPMZFM06B                                Lines 44
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1        INCLUDE FM06BF05_BAN_UPDATE .  " BAN_UPDATE
2
3        INCLUDE FM06BF05_BAN_UPDATE_AENDERN .  " BAN_UPDATE_AENDERN
4
5        INCLUDE FM06BF05_BAT_AUFBAUEN .  " BAT_AUFBAUEN
6
7        INCLUDE FM06BF05_GENERIEREN_ANFRAGE .  " GENERIEREN_ANFRAGE
8
9        INCLUDE FM06BF05_GENERIEREN_BESTELLUNG .  " GENERIEREN_BESTELLUNG
10
11       INCLUDE FM06BF05_GENERIEREN_ERFASSUNGS .  " GENERIEREN_ERFASSUNGSBLATT
12
13       INCLUDE FM06BF05_GENERIEREN_EINTEILUNG .  " GENERIEREN_EINTEILUNG
14
15       INCLUDE FM06BF05_GENERIEREN_UMLAGBESTE .  " GENERIEREN_UMLAGBESTELLUNG
16
17       INCLUDE FM06BF05_ZUG_AENDERN .  " ZUG_AENDERN
18
19       INCLUDE FM06BF05_ZUG_BEARBEITEN .  " ZUG_BEARBEITEN
20
21       INCLUDE FM06BF05_ZUG_CLEAR .  " ZUG_CLEAR
22
23       INCLUDE FM06BF05_ZUG_HIDE .  " ZUG_HIDE
24
25       INCLUDE FM06BF05_ZUG_MODIF_ZEILE .  " ZUG_MODIF_ZEILE
26
27       INCLUDE FM06BF05_ZUG_SUMME .  " ZUG_SUMME
28
29       INCLUDE FM06BF05_ZUG_SUMME_ANFR .  " ZUG_SUMME_ANFR
30
31       INCLUDE FM06BF05_ZUG_SUMME_LIEF .  " ZUG_SUMME_LIEF
32
33       INCLUDE FM06BF05_ZUG_SUMME_OHNE .  " ZUG_SUMME_OHNE
34
35       INCLUDE FM06BF05_ZUG_SUMME_RAHM .  " ZUG_SUMME_RAHM
36
37       INCLUDE FM06BF05_ZUG_SUMME_BEST .  " ZUG_SUMME_BEST
38
39
40       INCLUDE FM06BF05_ZUG_ZEILEN .  " ZUG_ZEILEN
41
42       INCLUDE FM06BF05_ZUG_SUMME_ZNIX .  " ZUG_SUMME_ZNIX
43
44       INCLUDE FM06BF05_ZUG_SUMME_ZRES .  " ZUG_SUMME_ZRES
*--- End of FM06BF05 - 44 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF05_BAN_UPDATE                       Level 2    Page 138
Object           SAPMZFM06B                                Lines 116
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      ***INCLUDE FM06BF05 .
2      * 70908 11.06.1997 3.1H GT : ME57 Belegsprache für Anfragen = Anmeldespr
3      * 82801 10.10.1997 3.1I CF : ME57 Anfrage erzeugen: Popup mit Partnern f
4      * 92105 08.01.1998 4.0B KB : SD-Banfen können teilbestellt werden
5      * 92334 12.01.1998 4.0B GT : ME58 Vorschlagswerte Beleg anlegen
6      * 95860 17.02.1998 4.0C SM : Vorschlag Belegart aus T160
7      *eject
8      *----------------------------------------------------------------------*
9      *   Tabelle Ban updaten nach Zuodnung bearbeiten/Banf ändern
10     *----------------------------------------------------------------------*
11     FORM ban_update USING bup_kz.
12
13       s-aktind = s-firstind.
14       WHILE s-aktind GE s-firstind AND
15             s-aktind LE s-maxind.
16         READ TABLE ban INDEX s-aktind.
17         CASE bup_kz.
18     *- angefragt ----------------------------------------------------------*
19           WHEN 'A'.
20             MOVE-CORRESPONDING ban TO bankey.
21             READ TABLE batu WITH KEY bankey.
22             IF sy-subrc EQ 0.
23     *- Bearbeitungssstatus löschen ----------------------------------------*
24               CLEAR ban-updk1.
25               ban-updk3 = buan.
26     *- Lieferantenzuordnung löschen ---------------------------------------*
27               IF ban-updk2 EQ aman.
28                 PERFORM alf_loeschen_einzel.
29                 CLEAR ban-slief.
30               ELSE.
31     *- Bezugsquellenzuordnung zurückholen ---------------------------------*
32                 CLEAR ban-slief.
33                 IF ban-updk2 NE space.
34                   ban-updk1 = ban-updk2.
35                   CLEAR ban-updk2.
36                   IF ban-bkuml NE space OR
37                      ban-reswk EQ space.
38                     ban-slief = ban-flief.
39                   ENDIF.
40                 ENDIF.
41               ENDIF.
42               MODIFY ban INDEX s-aktind.
43               bzaehl = bzaehl + 1.
44     *- 'Mutter-Banf' updaten, wenn keine Lieferanten mehr übrig -----------*
45               LOOP AT alf WHERE banfn EQ bankey-banfn
46                             AND bnfpo EQ bankey-bnfpo
47                             AND selkz NE space.
48                 EXIT.
49               ENDLOOP.
50               IF sy-subrc NE 0.
51                 LOOP AT ban WHERE banfn EQ bankey-banfn
52                               AND bnfpo EQ bankey-bnfpo
53                               AND updk3 NE buan.
54                   CLEAR ban-updk1.
55                   ban-updk3 = buan.
56                   MODIFY ban.
57                 ENDLOOP.
58               ENDIF.
59             ENDIF.
60     *- geändert -----------------------------------------------------------*
61           WHEN 'B'.
62             index_ban = s-aktind.
63             PERFORM ban_update_aendern.
64             IF sy-subrc EQ 0.
65               bzaehl = bzaehl + 1.
66             ENDIF.
67     *- bestellt/eingeteilt ------------------------------------------------*
68           WHEN 'E'.
69             MOVE-CORRESPONDING ban TO bankey.
70             READ TABLE batu WITH KEY bankey.
71             IF sy-subrc EQ 0.
72     *- bestellte Menge fortschreiben --------------------------------------*
73               IF ban-bsmng NE batu-bsmng.
74                 ban-bsmng = batu-bsmng.
75                 ban-statu = batu-statu.
76                 IF ban-vrtyp EQ 'L'.
77                   ban-ebeln = ban-konnr.
78                 ELSEIF batu-ebeln EQ space.                     "451467
79                   GET PARAMETER ID 'BES' FIELD ban-ebeln.
80                 ELSE.
81                   ban-ebeln = batu-ebeln.
82                 ENDIF.
83                 ban-ebelp = batu-ebelp.
84                 ban-bedat = batu-bedat.
85                 CASE batu-ebakz.                                "319095
86                   WHEN '0'. CLEAR ban-ebakz.
87                   WHEN '1'. ban-ebakz = 'X'.
88                   WHEN OTHERS. ban-ebakz = batu-ebakz.
89                 ENDCASE.
90                 ban-updk3 = bube.
91                 MODIFY ban INDEX s-aktind.
92                 bzaehl = bzaehl + 1.
93               ENDIF.
94             ENDIF.
95     *- Erfassungsblatt erstellt -------------------------------------------*
96           WHEN 'S'.
97             MOVE-CORRESPONDING ban TO bankey.
98             READ TABLE batu WITH KEY bankey.
99             IF sy-subrc EQ 0.
100              IF ban-bsmng NE batu-bsmng.
101                ban-bsmng = batu-bsmng.
102                ban-statu = batu-statu.
103                ban-ebeln = batu-ebeln.
104                ban-ebelp = batu-ebelp.
105                ban-bedat = batu-bedat.
106                ban-lblni = batu-lblni.
107                ban-updk3 = bube.          "noch offen
108                MODIFY ban INDEX s-aktind.
109                bzaehl = bzaehl + 1.
110              ENDIF.
111            ENDIF.
112        ENDCASE.
113        s-aktind = s-aktind + 1.
114      ENDWHILE.
115
116    ENDFORM.                    "ban_update
*--- End of FM06BF05_BAN_UPDATE - 116 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF05_BAN_UPDATE_AENDERN               Level 2    Page 139
Object           SAPMZFM06B                                Lines 24
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *   Tabelle Ban updaten nach Banf ändern
4      *----------------------------------------------------------------------*
5      FORM BAN_UPDATE_AENDERN.
6
7      MOVE-CORRESPONDING BAN TO BANKEY.
8      READ TABLE BAT WITH KEY BANKEY BINARY SEARCH.
9      CHECK SY-SUBRC EQ 0.
10     IF BAN-UPDK1 NE ZOLD.
11        IF BAN-FLIEF EQ SPACE AND
12           BAN-BESWK EQ SPACE AND " CCP
13           BAN-RESWK EQ SPACE.
14           BAN-UPDK1 = SPACE.
15        ELSE.
16           BAN-UPDK1 = ZOLD.
17        ENDIF.
18        BAN-UPDK3 = BUBA.
19        MODIFY BAN INDEX INDEX_BAN.
20     ELSE.
21        SY-SUBRC = 1.
22     ENDIF.
23
24     ENDFORM.
*--- End of FM06BF05_BAN_UPDATE_AENDERN - 24 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF05_BAT_AUFBAUEN                     Level 2    Page 140
Object           SAPMZFM06B                                Lines 43
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *   Übergabetabelle fuellen                                            *
4      *----------------------------------------------------------------------*
5      FORM bat_aufbauen CHANGING ch_dirty LIKE sy-subrc.
6
7        CLEAR ch_dirty.                                           "489026
8        REFRESH BAT.
9        CLEAR BAT.
10       CLEAR XAUTH.
11       S-AKTIND = S-FIRSTIND.
12       WHILE S-AKTIND GE S-FIRSTIND AND
13             S-AKTIND LE S-MAXIND.
14         READ TABLE BAN INDEX S-AKTIND.
15         S-AKTIND = S-AKTIND + 1.
16         MOVE-CORRESPONDING BAN TO BAT.
17         IF BAN-BKUML EQ SPACE AND
18            BAN-RESWK NE SPACE.
19           CLEAR BAT-FLIEF.
20         ENDIF.
21     *-- Command: Banf-Update ----------------------------------------------*
22         IF SY-UCOMM EQ 'ZBUP'.
23           IF BAN-UPDK1 EQ ZOLD OR
24              BAN-UPDK1 EQ SPACE.
25             ZNOUP = ZNOUP + 1.
26             CHECK 1 EQ 2.
27           ENDIF.
28           IF BAN-UPDK1 = AEND OR BAN-UPDK1 = ZNER.
29             BAT-UPDKZ = 'X'.
30           ELSE.
31             CLEAR BAT-UPDKZ.
32           ENDIF.
33         ENDIF.
34         IF NOT ban-qunum IS INITIAL AND
35         ( ban-updk1 EQ znew OR
36             ban-updk1 EQ zner OR
37             ban-updk1 EQ zres OR
38             ban-updk1 EQ aend ).
39           ch_dirty = 1.
40         ENDIF.
41         APPEND bat.
42       ENDWHILE.
43     ENDFORM.                    "bat_aufbauen
*--- End of FM06BF05_BAT_AUFBAUEN - 43 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF05_GENERIEREN_ANFRAGE               Level 2    Page 141
Object           SAPMZFM06B                                Lines 101
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *EJECT
2      *----------------------------------------------------------------------*
3      *        Generieren Anfragen                                           *
4      *----------------------------------------------------------------------*
5      FORM generieren_anfrage.
6
7        PERFORM pruefen_freigabe_anf.
8        READ TABLE bat INDEX 1.                                   "92334
9        rm06e-anfdt = sy-datlo.
10       ekko-ekgrp = bat-ekgrp.
11       ekko-ekorg = bat-ekorg.
12       IF ekko-ekorg EQ space.
13         GET PARAMETER ID 'EKO' FIELD ekko-ekorg.
14       ENDIF.
15       SELECT SINGLE * FROM t160 WHERE tcode EQ 'ME41'.
16       rm06e-asart = t160-bsart.
17       IF ekko-lifnr NE space.                                   "70908
18         SELECT SINGLE spras INTO rm06e-spras FROM lfa1          "70908
19              WHERE lifnr = ekko-lifnr.                          "70908
20       ELSE.                                                     "70908
21         rm06e-spras = sy-langu.
22       ENDIF.                                                    "70908
23       ekko-bstyp = 'A'.
24       CLEAR reject.
25       CALL SCREEN 101 STARTING AT 9  9
26                       ENDING   AT 43 17.
27       CHECK reject EQ space.
28       CLEAR call_updkz.
29       CLEAR batu.
30       REFRESH batu.
31       auto = 'X'.
32
33       IF 1 = 1.
34
35         DATA: lt_eban TYPE mereq_t_eban_mem,
36               ls_eban LIKE LINE OF lt_eban,
37               lt_eban_upd TYPE mereq_t_eban_mem,
38               ls_eban_upd LIKE LINE OF lt_eban_upd.
39
40         LOOP AT bat.
41           MOVE-CORRESPONDING bat TO ls_eban.
42           APPEND ls_eban TO lt_eban.
43         ENDLOOP.
44         ekko-bedat = rm06e-anfdt.
45         ekko-ebeln = rm06e-anfnr.
46         ekko-bsart = rm06e-asart.
47         ekko-spras = rm06e-spras.
48         ekko-bstyp = 'A'.
49
50         CALL FUNCTION 'ME_PROCESS_REQUISITIONS'
51           EXPORTING
52             i_ekko                          = ekko
53             i_auto                          = auto
54             i_enqueue                       = ' '
55             i_requisitions                  = lt_eban
56     *  i_requisition_accountings       =
57           IMPORTING
58             e_requisitions                  = lt_eban_upd
59             e_updkz                         = call_updkz
60           EXCEPTIONS
61             no_authority                    = 1
62             invalid_call                    = 2
63             OTHERS                          = 3.
64
65         IF sy-subrc <> 0.
66           MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
67                   WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
68         ENDIF.
69
70         CLEAR: batu, batu[].
71         LOOP AT lt_eban_upd INTO ls_eban_upd where updkz ne space.
72           MOVE-CORRESPONDING ls_eban_upd TO batu.
73           APPEND batu.
74         ENDLOOP.
75
76       ELSE.
77
78     *-- Bereitstellen der erforderlichen Daten im Memory ------------------*
79         SORT bat BY banfn bnfpo.
80         EXPORT bat rm06e-asart rm06e-anfdt rm06e-anfnr rm06e-spras
81                ekko-lifnr ekko-ekorg ekko-ekgrp ekko-angdt auto call_updkz
82         TO MEMORY ID 'BAT'.
83
84     *-- Aufruf ME41 - hier per 'CALL TRANSACTION' wegen COMMIT ------------
85     *CALL TRANSACTION 'ME41' AND SKIP FIRST SCREEN.                  "82801
86         CALL TRANSACTION 'ME41' WITH AUTHORITY-CHECK.                "82801
87
88     *-- Holen der erforderlichen Daten aus dem Memory ---------------------
89         IMPORT batu call_updkz FROM MEMORY ID 'BATU'.
90
91     *-- Anfrage nicht gebucht - keine Fortschreibung der Banfs ------------*
92         IF call_updkz EQ space.
93           REFRESH batu.
94           CLEAR batu.
95         ENDIF.
96       ENDIF.
97
98       PERFORM ban_update USING 'A'.
99       PERFORM zug_modif_zeile USING text-119.
100
101    ENDFORM.
*--- End of FM06BF05_GENERIEREN_ANFRAGE - 101 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF05_GENERIEREN_BESTELLUNG            Level 2    Page 142
Object           SAPMZFM06B                                Lines 86
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *EJECT
2      *----------------------------------------------------------------------*
3      *        Generieren Bestellungen und Kontraktabrufe                    *
4      *----------------------------------------------------------------------*
5      FORM generieren_bestellung.
6
7        PERFORM pruefen_freigabe_best.
8        PERFORM pruefen_estkz.                                    "92105/4.0C
9        READ TABLE bat INDEX 1.                                   "92334
10       rm06e-bedat = sy-datlo.
11       ekko-ekgrp = bat-ekgrp.
12       ekko-ekorg = bat-ekorg.
13       SELECT SINGLE * FROM t160 WHERE tcode EQ sy-tcode.        "125969
14       IF sy-subrc EQ 0 AND NOT t160-bsart IS INITIAL.           "125969
15         rm06e-bsart = t160-bsart.                               "125969
16       ELSE.                                                     "125969
17         SELECT SINGLE * FROM t160 WHERE tcode EQ 'ME21N'.       "740981
18         IF sy-subrc EQ 0 AND NOT t160-bsart IS INITIAL.
19           rm06e-bsart = t160-bsart.
20         ELSE.
21           SELECT SINGLE * FROM t160 WHERE tcode EQ 'ME21'.      "125969
22         IF sy-subrc EQ 0 AND NOT t160-bsart IS INITIAL.         "125969
23           rm06e-bsart = t160-bsart.                             "125969
24         ELSE.                                                   "125969
25           rm06e-bsart = bat-bsart.                              "125969
26         ENDIF.                                                  "125969
27         ENDIF.                                                  "740981
28       ENDIF.                                                    "125969
29       ekko-bstyp = 'F'.
30     ENHANCEMENT-POINT FM06BF05_GENERIEREN_BESTELL_01 SPOTS ES_SAPFM06B.
31       CLEAR reject.
32       CALL SCREEN 100 STARTING AT 9  9
33                       ENDING   AT 43 15.
34       CHECK reject EQ space.
35
36       auto = 'X'.
37
38       CLEAR call_updkz.
39       CLEAR batu.
40       REFRESH batu.
41
42       DATA: lt_eban TYPE mereq_t_eban_mem,
43             ls_eban LIKE LINE OF lt_eban,
44             lt_eban_upd TYPE mereq_t_eban_mem,
45             ls_eban_upd LIKE LINE OF lt_eban_upd.
46
47       LOOP AT bat.
48         MOVE-CORRESPONDING bat TO ls_eban.
49         APPEND ls_eban TO lt_eban.
50       ENDLOOP.
51       ekko-bedat = rm06e-bedat.
52       ekko-ebeln = rm06e-bstnr.
53       ekko-bsart = rm06e-bsart.
54       ekko-bstyp = 'F'.
55
56       CALL FUNCTION 'ME_PROCESS_REQUISITIONS'
57         EXPORTING
58           i_ekko                          = ekko
59           i_auto                          = auto
60           i_enqueue                       = ' '
61           i_requisitions                  = lt_eban
62     *  i_requisition_accountings       =
63         IMPORTING
64           e_requisitions                  = lt_eban_upd
65           e_updkz                         = call_updkz
66         EXCEPTIONS
67           no_authority                    = 1
68           invalid_call                    = 2
69           OTHERS                          = 3.
70
71       IF sy-subrc <> 0.
72         MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
73                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
74       ENDIF.
75
76       CLEAR: batu, batu[].
77       LOOP AT lt_eban_upd INTO ls_eban_upd WHERE updkz NE space.
78         MOVE-CORRESPONDING ls_eban_upd TO batu.
79         APPEND batu.
80       ENDLOOP.
81
82       PERFORM ban_update USING 'E'.
83       PERFORM oba_update_best.
84       PERFORM zug_modif_zeile USING text-116.
85
86     ENDFORM.                    "generieren_bestellung
*--- End of FM06BF05_GENERIEREN_BESTELLUNG - 86 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF05_GENERIEREN_ERFASSUNGS            Level 2    Page 143
Object           SAPMZFM06B                                Lines 58
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *EJECT
2      *----------------------------------------------------------------------*
3      *        Generieren Erfassungsblatt zur Rahmenbestellung               *
4      *----------------------------------------------------------------------*
5      FORM GENERIEREN_ERFASSUNGSBLATT.
6
7      DATA: HEBAN LIKE EBAN OCCURS 0
8            WITH HEADER LINE.
9
10     EBAN = BAT.
11
12     * Nur zur Rahmenbestellung
13     CHECK NOT EBAN-FORDN IS INITIAL AND
14           NOT EBAN-FORDP IS INITIAL.
15
16     * Rahmenbestellung lesen/pruefen
17     PERFORM DIEN_READ_PO USING EBAN-FORDN EBAN-FORDP.
18
19     * Erfblaetter aus Banfliste erstellen
20     REFRESH: HEBAN.
21     LOOP AT BAT WHERE LBLNI IS INITIAL
22                 AND   BSMNG IS INITIAL.
23       HEBAN = BAT.
24       APPEND HEBAN.
25     ENDLOOP.
26
27     DESCRIBE TABLE HEBAN LINES SY-TFILL.
28     IF SY-TFILL > 0.
29       CALL FUNCTION 'MS_BANF_LIST'
30            EXPORTING
31                 I_EKKO  = EKKO
32                 I_EKPO  = EKPO
33            TABLES
34                 XEBAN   = HEBAN.
35     ELSE.
36       MESSAGE S132.
37     ENDIF.
38
39     * Bestellung entsperren
40     PERFORM ENTSPERREN_EKKO(SAPFMMEX) USING EKKO-EBELN.
41
42     * Update ban-Tabellen
43     CLEAR BATU.
44     REFRESH BATU.
45     LOOP AT HEBAN
46          WHERE NOT LBLNI IS INITIAL.
47       BATU = HEBAN.
48       BATU-OBSMG = 0.
49       APPEND BATU.
50     ENDLOOP.
51     IF SY-SUBRC NE 0.
52       EXIT.
53     ENDIF.
54
55     PERFORM BAN_UPDATE USING 'E'.
56     PERFORM ZUG_MODIF_ZEILE USING TEXT-124.
57
58     ENDFORM.
*--- End of FM06BF05_GENERIEREN_ERFASSUNGS - 58 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF05_GENERIEREN_EINTEILUNG            Level 2    Page 144
Object           SAPMZFM06B                                Lines 72
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *EJECT
2      *----------------------------------------------------------------------*
3      *        Generieren Lieferplaneinteilungen                             *
4      *----------------------------------------------------------------------*
5      FORM generieren_einteilung.
6
7        PERFORM pruefen_freigabe_best.
8        PERFORM pruefen_estkz.               "92105/4.0C
9        auto = 'X'.
10       CLEAR call_updkz.
11       CLEAR batu.
12       REFRESH batu.
13       SET PARAMETER ID 'BSP' FIELD '00000'.
14
15       IF 1 = 1.
16
17         DATA: lt_eban TYPE mereq_t_eban_mem,
18               ls_eban LIKE LINE OF lt_eban,
19               lt_eban_upd TYPE mereq_t_eban_mem,
20               ls_eban_upd LIKE LINE OF lt_eban_upd.
21
22         LOOP AT bat.
23           MOVE-CORRESPONDING bat TO ls_eban.
24           APPEND ls_eban TO lt_eban.
25         ENDLOOP.
26         ekko-bstyp = 'L'.
27
28         CALL FUNCTION 'ME_PROCESS_REQUISITIONS'
29           EXPORTING
30             i_ekko                          = ekko
31             i_auto                          = auto
32             i_enqueue                       = ' '
33             i_requisitions                  = lt_eban
34     *  i_requisition_accountings       =
35           IMPORTING
36             e_requisitions                  = lt_eban_upd
37             e_updkz                         = call_updkz
38           EXCEPTIONS
39             no_authority                    = 1
40             invalid_call                    = 2
41             OTHERS                          = 3.
42
43         IF sy-subrc <> 0.
44           MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
45                   WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
46         ENDIF.
47
48         CLEAR: batu, batu[].
49         LOOP AT lt_eban_upd INTO ls_eban_upd where updkz ne space.
50           MOVE-CORRESPONDING ls_eban_upd TO batu.
51           APPEND batu.
52         ENDLOOP.
53
54       ELSE.
55
56     *-- ab 3.0D über CALL TRANSACTION
57         SORT bat BY banfn bnfpo.
58         EXPORT bat auto call_updkz TO MEMORY ID 'BAT'.
59         CALL TRANSACTION 'ME38' AND SKIP FIRST SCREEN.
60         IMPORT    batu call_updkz FROM MEMORY ID 'BATU'.
61     *-- Einteilung nicht gebucht - keine Fortschreibung der Banfs ---------*
62         IF call_updkz EQ space.
63           REFRESH batu.
64           CLEAR batu.
65         ENDIF.
66       ENDIF.
67
68       PERFORM ban_update USING 'E'.
69       PERFORM oba_update_best.
70       PERFORM zug_modif_zeile USING text-118.
71
72     ENDFORM.
*--- End of FM06BF05_GENERIEREN_EINTEILUNG - 72 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF05_GENERIEREN_UMLAGBESTE            Level 2    Page 145
Object           SAPMZFM06B                                Lines 88
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *EJECT
2      *----------------------------------------------------------------------*
3      *        Generieren Umlagerungsbestellungen                            *
4      *----------------------------------------------------------------------*
5      FORM generieren_umlagbestellung.
6
7        PERFORM pruefen_freigabe_best.
8        PERFORM pruefen_estkz.               "92105/4.0C
9        SELECT SINGLE * FROM t160 WHERE tcode EQ 'ME27'.
10       READ TABLE bat INDEX 1.                                   "92334
11       rm06e-bedat = sy-datlo.
12       ekko-ekgrp = bat-ekgrp.
13       ekko-ekorg = bat-ekorg.
14       rm06e-bsart = t160-bsart.
15       ekko-bstyp = 'F'.
16       CLEAR reject.
17       CALL SCREEN 100 STARTING AT 9  9
18                       ENDING   AT 43 15.
19       CHECK reject EQ space.
20
21       auto = 'X'.
22
23       CLEAR call_updkz.
24       CLEAR batu.
25       REFRESH batu.
26
27       IF 1 = 1.
28
29         DATA: lt_eban TYPE mereq_t_eban_mem,
30               ls_eban LIKE LINE OF lt_eban,
31               lt_eban_upd TYPE mereq_t_eban_mem,
32               ls_eban_upd LIKE LINE OF lt_eban_upd.
33
34         LOOP AT bat.
35           MOVE-CORRESPONDING bat TO ls_eban.
36           APPEND ls_eban TO lt_eban.
37         ENDLOOP.
38         ekko-bedat = rm06e-bedat.
39         ekko-ebeln = rm06e-bstnr.
40         ekko-bsart = rm06e-bsart.
41         ekko-bstyp = 'F'.
42         ekko-bsakz = 'T'.
43
44         CALL FUNCTION 'ME_PROCESS_REQUISITIONS'
45           EXPORTING
46             i_ekko                          = ekko
47             i_auto                          = auto
48             i_enqueue                       = ' '
49             i_requisitions                  = lt_eban
50     *  i_requisition_accountings       =
51           IMPORTING
52             e_requisitions                  = lt_eban_upd
53             e_updkz                         = call_updkz
54           EXCEPTIONS
55             no_authority                    = 1
56             invalid_call                    = 2
57             OTHERS                          = 3.
58
59         IF sy-subrc <> 0.
60           MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
61                   WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
62         ENDIF.
63
64         CLEAR: batu, batu[].
65         LOOP AT lt_eban_upd INTO ls_eban_upd where updkz ne space.
66           MOVE-CORRESPONDING ls_eban_upd TO batu.
67           APPEND batu.
68         ENDLOOP.
69
70       ELSE.
71
72     * ab 3.0D über CALL TRANSACTION
73         SORT bat BY banfn bnfpo.
74         EXPORT bat rm06e-bedat rm06e-bstnr rm06e-bsart
75                ekko-ekgrp ekko-ekorg auto call_updkz TO MEMORY ID 'BAT'.
76         CALL TRANSACTION 'ME27' AND SKIP FIRST SCREEN.
77         IMPORT batu call_updkz FROM MEMORY ID 'BATU'.
78         IF call_updkz EQ space.
79           REFRESH batu.
80           CLEAR batu.
81         ENDIF.
82       ENDIF.
83
84       PERFORM ban_update USING 'E'.
85       PERFORM oba_update_best.
86       PERFORM zug_modif_zeile USING text-116.
87
88     ENDFORM.
*--- End of FM06BF05_GENERIEREN_UMLAGBESTE - 88 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF05_ZUG_AENDERN                      Level 2    Page 146
Object           SAPMZFM06B                                Lines 14
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *    Geänderte Zuordnung in Banf fortschreiben
4      *----------------------------------------------------------------------*
5      FORM ZUG_AENDERN.
6
7        DATA: lf_dirty LIKE sy-subrc.
8        CLEAR: zsich, zenqu, zaend, zbere, znoup.
9        PERFORM bat_aufbauen CHANGING lf_dirty.
10       PERFORM AENDERN_BANFS.
11       PERFORM BAN_UPDATE USING 'B'.
12       PERFORM ZUG_MODIF_ZEILE USING TEXT-117.
13
14     ENDFORM.                    "ZUG_AENDERN
*--- End of FM06BF05_ZUG_AENDERN - 14 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF05_ZUG_BEARBEITEN                   Level 2    Page 147
Object           SAPMZFM06B                                Lines 57
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *    Bearbeiten Zuordnung
4      *----------------------------------------------------------------------*
5      FORM ZUG_BEARBEITEN.
6
7        DATA: lf_dirty LIKE sy-subrc.
8      *-- Fuellen Banf-Übergabetabelle --------------------------------------*
9        PERFORM bat_aufbauen CHANGING lf_dirty.
10       IF NOT lf_dirty IS INITIAL.
11         MESSAGE i688(me).
12         EXIT.
13       ENDIF.
14     READ TABLE BAT INDEX 1.
15     IF SY-SUBRC NE 0.
16        MESSAGE I204.
17        EXIT.
18     ENDIF.
19
20     *-- Banfs bearbeiten --------------------------------------------------*
21     CASE ZUG-UPDKZ.
22     *-- Generieren Anfragen ohne Lieferant --------------------------------*
23        WHEN ANFR.
24           CLEAR EKKO-LIFNR.
25           PERFORM GENERIEREN_ANFRAGE.
26     *-- Generieren Anfragen mit Lieferant ---------------------------------*
27        WHEN ALIF.
28           EKKO-LIFNR = BAN-SLIEF.
29           PERFORM GENERIEREN_ANFRAGE.
30     *-- Bestellung/Lieferplaneinteilung/Erfassungsblatt -------------------*
31        WHEN ZOLD.
32     *-- Kontrakt sperren, falls im Spiel ----------------------------------*
33     *     IF BAT-KONNR NE SPACE AND BAT-VRTYP EQ 'K'.
34     *        PERFORM SPERREN_EKKO(SAPFMMEX) USING BAT-KONNR 'K' SPACE.
35     *        XENQUEUE = 'X'.
36     *     ENDIF.
37           IF BAT-VRTYP NE 'L'.
38     *-- Generieren Umlagerungsbestellungen --------------------------------*
39              IF BAT-PSTYP EQ PSTYP-UMLG AND
40                 BAT-RESWK NE SPACE AND
41                 BAT-FLIEF EQ SPACE.
42                 PERFORM GENERIEREN_UMLAGBESTELLUNG.
43     *-- Liste fuer generieren Erfassungsblatt -----------------------------*
44              ELSEIF BAT-PSTYP = '9' AND
45                     NOT BAT-FORDN IS INITIAL.
46                 PERFORM GENERIEREN_ERFASSUNGSBLATT.
47     *-- Generieren Bestellungen -------------------------------------------*
48              ELSE.
49                 PERFORM GENERIEREN_BESTELLUNG.
50              ENDIF.
51           ELSE.
52     *-- Generieren Lieferplaneinteilungen ---------------------------------*
53              PERFORM GENERIEREN_EINTEILUNG.
54           ENDIF.
55     ENDCASE.
56
57     ENDFORM.
*--- End of FM06BF05_ZUG_BEARBEITEN - 57 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF05_ZUG_CLEAR                        Level 2    Page 148
Object           SAPMZFM06B                                Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *   Hide-Daten ZUG löschen
4      *----------------------------------------------------------------------*
5      FORM ZUG_CLEAR.
6
7      CLEAR: S-FIRSTIND, S-MAXIND, B-ZAEHLER, ZUG-UPDKZ,
8             HIDE-ZEILE, HIDE-PAGE, BZAEHL.
9
10     ENDFORM.
*--- End of FM06BF05_ZUG_CLEAR - 10 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF05_ZUG_HIDE                         Level 2    Page 149
Object           SAPMZFM06B                                Lines 13
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *   Hide fuer Liste Zuordnungen
4      *----------------------------------------------------------------------*
5      FORM ZUG_HIDE.
6
7      HIDE-ZEILE = SY-LINNO.
8      HIDE-PAGE  = SY-PAGNO.
9      HIDE: S-FIRSTIND, S-MAXIND, ZUG-UPDKZ,
10           HIDE-ZEILE, HIDE-PAGE.
11     CLEAR: HIDE-ZEILE, HIDE-PAGE.
12
13     ENDFORM.
*--- End of FM06BF05_ZUG_HIDE - 13 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF05_ZUG_MODIF_ZEILE                  Level 2    Page 150
Object           SAPMZFM06B                                Lines 20
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *   Zeile in Zuordnungsüberssicht modifizieren
4      *----------------------------------------------------------------------*
5      FORM zug_modif_zeile USING zmz_text.
6
7        IF bzaehl GT 99999.
8          WRITE '99999' TO b-zaehler NO-SIGN.
9        ELSE.
10         WRITE bzaehl TO b-zaehler NO-SIGN.
11       ENDIF.
12       CLEAR bzaehl.
13
14       READ LINE hide-zeile OF PAGE hide-page INDEX lsind.
15       WRITE zmz_text TO sy-lisel+64(11).
16       WRITE b-zaehler TO sy-lisel+76(5).
17       MODIFY LINE hide-zeile OF PAGE hide-page INDEX lsind.
18       CLEAR b-zaehler.
19
20     ENDFORM.
*--- End of FM06BF05_ZUG_MODIF_ZEILE - 20 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF05_ZUG_SUMME                        Level 2    Page 151
Object           SAPMZFM06B                                Lines 64
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *  Ausgeben Zeile Zuordnungssumme                                      *
4      *----------------------------------------------------------------------*
5      FORM zug_summe.
6
7        IF izaehl GT 99999.
8          WRITE '99999' TO s-zaehler NO-SIGN.
9        ELSE.
10         WRITE izaehl TO s-zaehler NO-SIGN.
11       ENDIF.
12       CLEAR izaehl.
13
14       CASE zug-updkz.
15     *- Zugeordnete Banfs --------------------------------------------------*
16         WHEN zold.
17           IF zug-konnr NE space.                 "Kontrakt
18             IF lzeile EQ space.
19               PERFORM zug_summe_lief.
20             ENDIF.
21             PERFORM zug_summe_rahm.
22           ELSEIF zug-fordn NE space.             "Rahmenbestellung
23             IF lzeile EQ space.
24               PERFORM zug_summe_lief.
25             ENDIF.
26             PERFORM zug_summe_best.
27           ELSE.                                  "Fester Lieferant
28             IF lzeile EQ space.
29               PERFORM zug_summe_lief.
30             ENDIF.
31             PERFORM zug_summe_ohne.
32           ENDIF.
33
34     *- Zur Anfragebearbeitung vorgemerkte Banfs ---------------------------*
35         WHEN anfr.
36           IF lzeile EQ space.
37             PERFORM zug_summe_lief.
38           ENDIF.
39           PERFORM zug_summe_anfr.
40
41     *- Zuordnungen zurückgenommen -----------------------------------------*
42         WHEN zres.
43           IF lzeile EQ space.
44             PERFORM zug_summe_lief.
45           ENDIF.
46           PERFORM zug_summe_zres.
47
48     *- Zur Anfrage vorgemerkte - Zu mehreren Lieferanten ------------------*
49         WHEN alif.
50           IF lzeile EQ space.
51             PERFORM zug_summe_lief.
52           ENDIF.
53           PERFORM zug_summe_anfr.
54
55     *- Keine Zuordnung ----------------------------------------------------*
56         WHEN znix.
57           IF lzeile EQ space.
58             PERFORM zug_summe_lief.
59           ENDIF.
60           PERFORM zug_summe_znix.
61
62       ENDCASE.
63
64     ENDFORM.                    "zug_summe
*--- End of FM06BF05_ZUG_SUMME - 64 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF05_ZUG_SUMME_ANFR                   Level 2    Page 152
Object           SAPMZFM06B                                Lines 18
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *  Ausgeben Anfragezeile                                               *
4      *----------------------------------------------------------------------*
5      FORM zug_summe_anfr.
6
7        FORMAT COLOR COL_NORMAL INTENSIFIED OFF.
8        WRITE: /   sy-vline,
9                2  zug-ekorg,
10                  zug-bsart,
11                  zug-bukrs,
12               17 text-120,
13             58 S-ZAEHLER,
14               85 sy-vline.
15       CLEAR s-zaehler.
16       PERFORM zug_hide.
17
18     ENDFORM.
*--- End of FM06BF05_ZUG_SUMME_ANFR - 18 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF05_ZUG_SUMME_LIEF                   Level 2    Page 153
Object           SAPMZFM06B                                Lines 65
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *  Ausgeben Lieferantenzeile                                           *
4      *----------------------------------------------------------------------*
5      FORM zug_summe_lief.
6        DATA: l_use_cam TYPE c, "IAV
7              l_use_addr_ver TYPE c.
8
9        IF zug-reswk NE space.
10         SELECT SINGLE * FROM t001w WHERE werks EQ zug-reswk.
11         FORMAT COLOR COL_GROUP INTENSIFIED OFF.
12         WRITE: /  sy-vline,
13                 2(14) text-064 COLOR COL_GROUP INTENSIFIED,
14                17 zug-reswk,
15                28(26) t001w-name1.
16         IF zug-flief NE space.
17           WRITE: 54(14) text-058 COLOR COL_GROUP INTENSIFIED,
18                  68 zug-flief.
19         ENDIF.
20         WRITE: 85 sy-vline.
21       ELSE.
22         IF zug-flief NE space.
23     *      SELECT SINGLE * FROM lfa1 WHERE lifnr = zug-flief.  "IAV Comment out
24     *      Get LFA1 and corresponding address version
25           IF cl_iav_mapping_util=>is_iav_active( ) EQ 'X'.  "IAV
26             l_use_cam = 'X'.
27             l_use_addr_ver = 'X'.
28           ENDIF.
29           CALL FUNCTION 'WY_LFA1_SINGLE_READ'
30                EXPORTING
31                     PI_LIFNR            = zug-flief
32                     PI_READ_CAM         = l_use_cam      "IAV
33                     PI_ACCESS_TO_ADDR_VERSION = l_use_addr_ver "IAV
34                IMPORTING
35                     PO_LFA1             = LFA1
36                EXCEPTIONS
37                     NO_RECORDS_FOUND    = 1
38                     OTHERS              = 2.
39     *
40           FORMAT COLOR COL_GROUP INTENSIFIED OFF.
41           WRITE: /  sy-vline,
42                   2(14) text-058 COLOR COL_GROUP INTENSIFIED,
43                  17 zug-flief,
44                  28 lfa1-name1,
45                  85 sy-vline.
46     * Begin CCP
47         ELSEIF zug-beswk NE space.
48           SELECT SINGLE * FROM t001w WHERE werks EQ zug-beswk.
49           FORMAT COLOR COL_GROUP INTENSIFIED OFF.
50           WRITE: /  sy-vline,
51                   2(14) text-cc4 COLOR COL_GROUP INTENSIFIED,
52                  17 zug-beswk,
53                  28(26) t001w-name1.
54           WRITE: 85 sy-vline.
55     * End CCP
56         ELSE.
57           FORMAT COLOR COL_GROUP INTENSIFIED OFF.
58           WRITE: /  sy-vline,
59                   2 text-059 COLOR COL_GROUP INTENSIFIED,
60                  85 sy-vline.
61         ENDIF.
62       ENDIF.
63       lzeile = 'X'.
64
65     ENDFORM.                    "ZUG_SUMME_LIEF
*--- End of FM06BF05_ZUG_SUMME_LIEF - 65 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF05_ZUG_SUMME_OHNE                   Level 2    Page 154
Object           SAPMZFM06B                                Lines 18
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *  Ausgeben Zuordnungszeile ohne Rahmenvertrag                         *
4      *----------------------------------------------------------------------*
5      FORM zug_summe_ohne.
6
7        FORMAT COLOR COL_NORMAL INTENSIFIED OFF.
8        WRITE: /  sy-vline,
9                2  zug-ekorg,
10                  zug-bsart,
11                  zug-bukrs,
12               17 text-121,
13             58 S-ZAEHLER,
14               85 sy-vline.
15       CLEAR s-zaehler.
16       PERFORM zug_hide.
17
18     ENDFORM.
*--- End of FM06BF05_ZUG_SUMME_OHNE - 18 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF05_ZUG_SUMME_RAHM                   Level 2    Page 155
Object           SAPMZFM06B                                Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *  Ausgeben Rahmenvertragszeile                                        *
4      *----------------------------------------------------------------------*
5      FORM zug_summe_rahm.
6
7        SELECT SINGLE *
8               INTO :*ekko
9               FROM ekko
10              WHERE ebeln = zug-konnr.
11       FORMAT COLOR COL_NORMAL INTENSIFIED OFF.
12       WRITE: /   sy-vline,
13               2  zug-ekorg,
14                  zug-bsart,
15                  zug-bukrs,
16               17 zug-konnr, *ekko-bsart,
17                  *ekko-kdatb DD/MM/YYYY, *ekko-kdate DD/MM/YYYY,
18             58 S-ZAEHLER,
19               85 sy-vline.
20       CLEAR s-zaehler.
21       PERFORM zug_hide.
22
23     ENDFORM.
*--- End of FM06BF05_ZUG_SUMME_RAHM - 23 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF05_ZUG_SUMME_BEST                   Level 2    Page 156
Object           SAPMZFM06B                                Lines 22
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *----------------------------------------------------------------------*
2      *  Ausgeben Zeile Rahmenbestellung                                     *
3      *----------------------------------------------------------------------*
4      FORM zug_summe_best.
5
6        SELECT SINGLE *
7               INTO :*ekko
8               FROM ekko
9               WHERE ebeln = zug-fordn.
10       FORMAT COLOR COL_NORMAL INTENSIFIED OFF.
11       WRITE: /   sy-vline,
12               2  zug-ekorg,
13                  zug-bsart,
14                  zug-bukrs,
15               17 zug-fordn, *ekko-bsart,
16                  *ekko-kdatb DD/MM/YYYY, *ekko-kdate DD/MM/YYYY,
17             58 S-ZAEHLER,
18               85 sy-vline.
19       CLEAR s-zaehler.
20       PERFORM zug_hide.
21
22     ENDFORM.
*--- End of FM06BF05_ZUG_SUMME_BEST - 22 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF05_ZUG_ZEILEN                       Level 2    Page 157
Object           SAPMZFM06B                                Lines 104
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *  Liste der Zuordnungen aufbauen                                      *
4      *----------------------------------------------------------------------*
5      FORM zug_zeilen.
6
7        DATA: lv_tabix LIKE sy-tabix.
8
9        LEAVE TO LIST-PROCESSING.
10       NEW-PAGE LINE-SIZE 85.
11
12     *- Tabelle erweitern um mehrfach zur Anfrage vorgemerkte Banfs --------*
13       LOOP AT ban WHERE updk1 EQ aman.
14         LOOP AT alf WHERE banfn EQ ban-banfn
15                       AND bnfpo EQ ban-bnfpo
16                       AND selkz NE space.
17           LOOP AT ban WHERE banfn = alf-banfn
18                         AND bnfpo = alf-bnfpo
19                         AND slief = alf-lifnr
20                         AND ekorg = alf-ekorg
21                         AND updk1 = alif
22                         AND updk2 = aman.
23             EXIT.
24           ENDLOOP.
25           IF sy-subrc NE 0.
26             ban-slief = alf-lifnr.
27             ban-ekorg = alf-ekorg.
28             ban-updk1 = alif.
29             ban-updk2 = aman.
30             APPEND ban.
31           ENDIF.
32         ENDLOOP.
33       ENDLOOP.
34
35     * Begin CCP
36     *SORT BAN BY RESWK SLIEF EKORG BSART KONNR FORDN
37     *            BUKRS UPDK1 BANFN BNFPO.
38       SORT ban BY reswk slief beswk ekorg bsart konnr fordn
39                   bukrs updk1 banfn bnfpo.                      "2192576
40     * End CCP
41
42       CLEAR: zug, lzeile.
43       DATA: hupdkz LIKE t16la-updkz.
44       LOOP AT ban.
45         lv_tabix = sy-tabix.
46     *- 'Mutter-Banf' der Mehrfachzuordnung rauslassen ---------------------*
47         CHECK ban-updk1 NE aman.
48         hupdkz = ban-updk1.
49         IF hupdkz EQ aend.
50           IF ban-flief NE space OR
51              ban-reswk NE space.
52             hupdkz = zold.
53           ELSE.
54             hupdkz = znix.
55           ENDIF.
56         ENDIF.
57         IF hupdkz = znew OR hupdkz = zner.
58           hupdkz = zold.
59         ENDIF.
60         IF hupdkz EQ space OR
61            hupdkz EQ zres.
62           hupdkz = znix.
63         ENDIF.
64         IF zug-flief NE ban-slief OR
65            zug-reswk NE ban-reswk OR
66            zug-konnr NE ban-konnr OR
67            zug-fordn NE ban-fordn OR
68            zug-ekorg NE ban-ekorg OR
69            zug-beswk NE ban-beswk OR " CCP
70            zug-bsart NE ban-bsart OR
71            zug-bukrs NE ban-bukrs OR
72            zug-updkz NE hupdkz.
73           IF zug NE space.
74             PERFORM zug_summe.
75           ENDIF.
76           s-firstind = lv_tabix.
77           IF zug-reswk EQ space AND
78              ban-reswk NE space.
79             CLEAR lzeile.
80             ULINE.
81             NEW-PAGE LINE-SIZE 85.
82           ENDIF.
83         ENDIF.
84         MOVE-CORRESPONDING ban TO zug.
85         zug-flief = ban-slief.
86         zug-updkz = hupdkz.
87         izaehl = izaehl + 1.
88         s-maxind = lv_tabix.
89     * Begin CCP
90     *    ON CHANGE OF zug-flief OR zug-reswk.
91         ON CHANGE OF zug-flief OR zug-reswk OR zug-beswk.
92     * End CCP
93           IF lzeile NE space.
94             ULINE.
95           ENDIF.
96           CLEAR lzeile.
97         ENDON.
98       ENDLOOP.
99
100      PERFORM zug_summe.
101      CLEAR: s-firstind, s-maxind, b-zaehler, zug-updkz,
102             s-zaehler, hide-zeile, hide-page, bzaehl.
103      ULINE.
104    ENDFORM.                    "ZUG_ZEILEN
*--- End of FM06BF05_ZUG_ZEILEN - 104 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF05_ZUG_SUMME_ZNIX                   Level 2    Page 158
Object           SAPMZFM06B                                Lines 18
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *  Ausgeben Zeile ohne Zuordnung                                       *
4      *----------------------------------------------------------------------*
5      FORM zug_summe_znix.
6
7        FORMAT COLOR COL_NORMAL INTENSIFIED OFF.
8        WRITE: /  sy-vline,
9                2  zug-ekorg,
10                  zug-bsart,
11                  zug-bukrs,
12               17 text-122,
13             58 S-ZAEHLER,
14               85 sy-vline.
15       CLEAR s-zaehler.
16       PERFORM zug_hide.
17
18     ENDFORM.
*--- End of FM06BF05_ZUG_SUMME_ZNIX - 18 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BF05_ZUG_SUMME_ZRES                   Level 2    Page 159
Object           SAPMZFM06B                                Lines 18
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *  Ausgeben Zurückgesetzt-Zeile                                        *
4      *----------------------------------------------------------------------*
5      FORM zug_summe_zres.
6
7        FORMAT COLOR COL_NORMAL INTENSIFIED OFF.
8        WRITE: /   sy-vline,
9                2  zug-ekorg,
10                  zug-bsart,
11                  zug-bukrs,
12               17 text-115,
13             58 S-ZAEHLER,
14               85 sy-vline.
15       CLEAR s-zaehler.
16       PERFORM zug_hide.
17
18     ENDFORM.
*--- End of FM06BF05_ZUG_SUMME_ZRES - 18 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFAL                                  Level 1    Page 160
Object           SAPMZFM06B                                Lines 18
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      ************************************************************************
3      * Unterroutinen fuer Bearbeitung Tabelle ALF                           *
4      ************************************************************************
5
6        INCLUDE FM06BFAL_ALF_BLAETTERN .  " ALF_BLAETTERN
7
8        INCLUDE FM06BFAL_ALF_FIRST .  " ALF_FIRST
9
10       INCLUDE FM06BFAL_ALF_FUELLEN .  " ALF_FUELLEN
11
12       INCLUDE FM06BFAL_ALF_INIT .  " ALF_INIT
13
14       INCLUDE FM06BFAL_ALF_LESEN .  " ALF_LESEN
15
16       INCLUDE FM06BFAL_ALF_LOESCHEN .  " ALF_LOESCHEN
17
18       INCLUDE FM06BFAL_ALF_LOESCHEN_EINZEL .  " ALF_LOESCHEN_EINZEL
*--- End of FM06BFAL - 18 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFAL_ALF_BLAETTERN                    Level 2    Page 161
Object           SAPMZFM06B                                Lines 58
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *  Blaettern                                                           *
4      *----------------------------------------------------------------------*
5      FORM ALF_BLAETTERN.
6
7      CASE OK-CODE.
8      *- eine Seite weiter blättern -----------------------------------------*
9         WHEN 'VW'.
10           IF A-AKTIND = A-MAXIND.
11              A-AKTIND = A-AKTIND - A-PAGIND.
12           ENDIF.
13           CLEAR OK-CODE.
14     *- eine Seite zurück blättern -----------------------------------------*
15        WHEN 'RW'.
16           A-AKTIND = A-AKTIND - A-PAGIND - 5.
17           CLEAR OK-CODE.
18     *- auf letzte Seite blättern ------------------------------------------*
19        WHEN 'VS'.
20           A-AKTIND = A-MAXIND - 5.
21           CLEAR OK-CODE.
22     *- auf erste Seite blättern -------------------------------------------*
23        WHEN 'RS'.
24           A-AKTIND = A-FIRSTIND - 1.
25           CLEAR OK-CODE.
26     *- auf Bild stehenbleiben ---------------------------------------------*
27        WHEN 'ENTE'.
28           A-AKTIND = A-AKTIND - A-PAGIND.
29     *- Loop-Zeilen für weitere Lieferanteneingaben anbieten ---------------*
30        WHEN 'WLIF'.
31           A-AKTIND = A-AKTIND - A-PAGIND + 5.
32     *- Selektierte Lieferanten übernehmen und Bild verlassen --------------*
33        WHEN 'ANFM'.
34           LEERFLG  = 'X'.
35           LOOP AT ALF WHERE BANFN EQ BAN-BANFN
36                         AND BNFPO EQ BAN-BNFPO.
37              ALF-SELKZ = ALF-VSELK.
38              CLEAR ALF-VSELK.
39              IF ALF-SELKZ NE SPACE.
40                 CLEAR LEERFLG.
41              ENDIF.
42              MODIFY ALF INDEX SY-TABIX.
43           ENDLOOP.
44           IF LEERFLG  EQ SPACE.
45              SET PF-STATUS PFKEYP.
46              SET SCREEN 0.
47              LEAVE SCREEN.
48           ELSE.
49              A-AKTIND = A-AKTIND - A-PAGIND.
50              MESSAGE S269.
51           ENDIF.
52     ENDCASE.
53
54     IF A-AKTIND LT A-FIRSTIND.
55        A-AKTIND = A-FIRSTIND - 1.
56     ENDIF.
57
58     ENDFORM.
*--- End of FM06BFAL_ALF_BLAETTERN - 58 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFAL_ALF_FIRST                        Level 2    Page 162
Object           SAPMZFM06B                                Lines 9
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      * Zaehler Zeilen pro Seite initialisieren                              *
4      *----------------------------------------------------------------------*
5      FORM ALF_FIRST.
6
7      A-PAGIND = 0.
8
9      ENDFORM.
*--- End of FM06BFAL_ALF_FIRST - 9 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFAL_ALF_FUELLEN                      Level 2    Page 163
Object           SAPMZFM06B                                Lines 69
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      * Lieferanten in interne Tabelle füllen                                *
4      *----------------------------------------------------------------------*
5      FORM ALF_FUELLEN.
6
7        PERFORM EKORG_CHECK(SAPFMMEX) USING LFM1-EKORG
8                                      CHANGING T024E.
9      *ERFORM LFM1_LESEN(SAPFMMEX) USING LFM1-LIFNR LFM1-EKORG.
10
11       DATA: LS_LFM1 LIKE LFM1.                                  "161761
12       DATA: LS_LFA1 LIKE LFA1.                                  "181072
13
14       CALL FUNCTION 'VENDOR_MASTER_DATA_SELECT_00'
15            EXPORTING
16                 I_LFA1_LIFNR     = LFM1-LIFNR
17                 I_LFM1_EKORG     = LFM1-EKORG
18                 I_DATA           = 'X'
19            IMPORTING                                            "161761
20                 A_LFM1           = LS_LFM1                      "161761
21                 A_LFA1           = LS_LFA1                      "181072
22            EXCEPTIONS
23                 VENDOR_NOT_FOUND = 01.
24
25       IF SY-SUBRC NE 0.
26         MESSAGE E321(06) WITH LFM1-LIFNR LFM1-EKORG.
27       ENDIF.
28
29       IF LFM1-LIFNR NE LS_LFM1-LIFNR.                           "161761
30         MESSAGE E027(06) WITH LFM1-LIFNR LFM1-EKORG.            "181072
31       ENDIF.                                                    "181072
32
33     *- Prüfen ob Lieferant gesperrt ist                         "181072
34       PERFORM LFA1-STATUS-NEU(SAPFMMEX) USING 'X' LS_LFA1.      "181072
35       PERFORM LFM1-STATUS-NEU(SAPFMMEX) USING LS_LFM1.          "181072
36       CLEAR: LS_LFA1, LS_LFM1.                                  "181072
37
38       CLEAR ALF.
39     *- Lesen Tabelle - feststellen, ob Lieferant bereits vorhanden --------*
40       ALFKEY-BANFN = BAN-BANFN.
41       ALFKEY-BNFPO = BAN-BNFPO.
42       ALFKEY-LIFNR = LFM1-LIFNR.
43       ALFKEY-EKORG = LFM1-EKORG.
44       READ TABLE ALF WITH KEY ALFKEY BINARY SEARCH.
45
46       CASE SY-SUBRC.
47     *- Lieferant bereits in Tabelle - Selektionskennzeichen setzen --------*
48         WHEN 00.
49           ALF-VSELK = RM06B-SELKZ.
50           MODIFY ALF INDEX SY-TABIX.
51     *- Lieferant noch nicht zugeordnet - Einfügen -------------------------*
52         WHEN 04.
53           MOVE-CORRESPONDING ALFKEY TO ALF.
54           ALF-VSELK = 'X'.
55           INSERT ALF INDEX SY-TABIX.
56           A-MAXIND = A-MAXIND + 1.
57           A-AKTIND = A-AKTIND + 1.
58           A-PAGIND = A-PAGIND + 1.
59     *- Lieferant noch nicht zugeordnet - Anhängen -------------------------*
60         WHEN 08.
61           MOVE-CORRESPONDING ALFKEY TO ALF.
62           ALF-VSELK = 'X'.
63           APPEND ALF.
64           A-MAXIND = A-MAXIND + 1.
65           A-AKTIND = A-AKTIND + 1.
66           A-PAGIND = A-PAGIND + 1.
67       ENDCASE.
68
69     ENDFORM.
*--- End of FM06BFAL_ALF_FUELLEN - 69 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFAL_ALF_INIT                         Level 2    Page 164
Object           SAPMZFM06B                                Lines 49
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      * Lieferantentabelle Banfpositionsbezogen initialisieren               *
4      *----------------------------------------------------------------------*
5      FORM ALF_INIT.
6
7      CLEAR: A-MAXIND, A-PAGIND, A-AKTIND, A-FIRSTIND.
8      *- ermitteln erster und letzter Lieferant zur Banfpos in ALF
9      LOOP AT ALF.
10        IF ALF-BANFN EQ BAN-BANFN AND
11           ALF-BESWK EQ BAN-BESWK AND " CCP
12           ALF-BNFPO EQ BAN-BNFPO.
13           IF A-FIRSTIND EQ 0.
14              A-FIRSTIND = SY-TABIX.
15           ENDIF.
16           ALF-VSELK = ALF-SELKZ.
17           MODIFY ALF INDEX SY-TABIX.
18           A-MAXIND = SY-TABIX.
19        ELSE.
20           IF A-FIRSTIND NE 0.
21              EXIT.
22           ENDIF.
23        ENDIF.
24     ENDLOOP.
25
26     *- keine Lieferanten in ALF -> Infosätze lesen
27     IF A-FIRSTIND EQ 0.
28        PERFORM LESEN_INFO.
29     *- ermitteln erster und letzter Lieferant zur Pos in ALF
30        LOOP AT ALF.
31           IF ALF-BANFN EQ BAN-BANFN AND
32              ALF-BNFPO EQ BAN-BNFPO.
33              IF A-FIRSTIND EQ 0.
34                 A-FIRSTIND = SY-TABIX.
35              ENDIF.
36              A-MAXIND = SY-TABIX.
37           ELSE.
38              IF A-FIRSTIND NE 0.
39                 EXIT.
40              ENDIF.
41           ENDIF.
42        ENDLOOP.
43     ENDIF.
44
45     IF A-FIRSTIND NE 0.
46        A-AKTIND = A-FIRSTIND - 1.
47     ENDIF.
48
49     ENDFORM.
*--- End of FM06BFAL_ALF_INIT - 49 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFAL_ALF_LESEN                        Level 2    Page 165
Object           SAPMZFM06B                                Lines 44
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      * Lieferantentabelle lesen                                             *
4      * Eintrag wird in LFM1 (Loopzeile) uebertragen.                        *
5      *----------------------------------------------------------------------*
6      FORM ALF_LESEN.
7          DATA: l_use_cam TYPE c,
8                l_use_addr_ver TYPE c.
9
10     IF A-PAGIND IS INITIAL AND A-AKTIND LT 5.                      "^1063783
11       READ TABLE ALF WITH KEY BANFN = BAN-BANFN BNFPO = BAN-BNFPO.
12       A-AKTIND = SY-TABIX - 1.
13     ENDIF.                                                         "v1063783
14
15     A-AKTIND = A-AKTIND + 1.
16     READ TABLE ALF INDEX A-AKTIND.
17     IF SY-SUBRC  EQ 0 AND
18        ALF-BANFN EQ BAN-BANFN AND
19        ALF-BNFPO EQ BAN-BNFPO.
20        MOVE-CORRESPONDING ALF TO LFM1.
21        RM06B-SELKZ = ALF-VSELK.
22     *  SELECT SINGLE * FROM LFA1 WHERE LIFNR EQ LFM1-LIFNR.  "IAV comment out
23        IF cl_iav_mapping_util=>is_iav_active( ) EQ 'X'.
24         l_use_cam = 'X'.
25         l_use_addr_ver = 'X'.
26        ENDIF.
27        CALL FUNCTION 'WY_LFA1_SINGLE_READ'                   "IAV
28             EXPORTING
29                  PI_LIFNR            = LFM1-LIFNR
30                  PI_READ_CAM         = l_use_cam
31                  PI_ACCESS_TO_ADDR_VERSION = l_use_addr_ver
32             IMPORTING
33                  PO_LFA1             = LFA1
34             EXCEPTIONS
35                  NO_RECORDS_FOUND    = 1
36                  OTHERS              = 2.
37     *
38        A-PAGIND = A-PAGIND + 1.
39     ELSE.
40        A-AKTIND = A-AKTIND - 1.
41        CLEAR LFM1.
42     ENDIF.
43
44     ENDFORM.
*--- End of FM06BFAL_ALF_LESEN - 44 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFAL_ALF_LOESCHEN                     Level 2    Page 166
Object           SAPMZFM06B                                Lines 14
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      * Lieferantentabelle loeschen                                          *
4      * Bei Rücksetzen Zuordnung oder anderweitiger Zuordnung der Banf       *
5      *----------------------------------------------------------------------*
6      FORM ALF_LOESCHEN.
7
8      LOOP AT ALF WHERE BANFN EQ BAN-BANFN
9                  AND   BNFPO EQ BAN-BNFPO.
10        CLEAR ALF-SELKZ.
11        MODIFY ALF.
12     ENDLOOP.
13
14     ENDFORM.
*--- End of FM06BFAL_ALF_LOESCHEN - 14 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFAL_ALF_LOESCHEN_EINZEL              Level 2    Page 167
Object           SAPMZFM06B                                Lines 15
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      * Einzelnen Lieferant aus ALF loeschen                                 *
4      *----------------------------------------------------------------------*
5      FORM ALF_LOESCHEN_EINZEL.
6
7      LOOP AT ALF WHERE BANFN EQ BAN-BANFN
8                  AND   BNFPO EQ BAN-BNFPO
9                  AND   LIFNR EQ BAN-SLIEF
10                 AND   EKORG EQ BAN-EKORG.
11        CLEAR ALF-SELKZ.
12        MODIFY ALF.
13     ENDLOOP.
14
15     ENDFORM.
*--- End of FM06BFAL_ALF_LOESCHEN_EINZEL - 15 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFLI                                  Level 1    Page 168
Object           SAPMZFM06B                                Lines 39
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      ***INCLUDE FM06BFLI .
2
3      * Hinw. Datum    Rel. NN  Text
4      * 88389 25.11.97 4.0B KB: ME5A erledigte RV-Banfen
5
6        INCLUDE FM06BFLI_BAN_ZEILE_001 .  " BAN_ZEILE_001
7
8        INCLUDE FM06BFLI_BAN_ZEILE_002 .  " BAN_ZEILE_002
9
10       INCLUDE FM06BFLI_BAN_ZEILE_003 .  " BAN_ZEILE_003
11
12       INCLUDE FM06BFLI_BAN_ZEILE_004 .  " BAN_ZEILE_004
13
14       INCLUDE FM06BFLI_BAN_ZEILE_005 .  " BAN_ZEILE_005
15
16       INCLUDE FM06BFLI_BAN_ZEILE_006 .  " BAN_ZEILE_006
17
18       INCLUDE FM06BFLI_BAN_ZEILE_007 .  " BAN_ZEILE_007
19
20       INCLUDE FM06BFLI_BAN_ZEILE_008 .  " BAN_ZEILE_008
21
22       INCLUDE FM06BFLI_BAN_ZEILE_009 .  " BAN_ZEILE_009
23
24       INCLUDE FM06BFLI_BAN_ZEILE_010 .  " BAN_ZEILE_010
25
26       INCLUDE FM06BFLI_BAN_ZEILE_011 .  " BAN_ZEILE_011
27
28       INCLUDE FM06BFLI_BAN_ZEILE_012 .  " BAN_ZEILE_012
29
30       INCLUDE FM06BFLI_BAN_ZEILE_013 .  " BAN_ZEILE_013
31
32       INCLUDE FM06BFLI_BAN_ZEILE_014 .  " BAN_ZEILE_014
33
34       INCLUDE FM06BFLI_BAN_ZEILE_102 .  " BAN_ZEILE_102
35
36       INCLUDE FM06BFLI_BAN_ZEILE_201 .  " BAN_ZEILE_201
37
38
39       INCLUDE FM06BFLI_BAN_GSFRG_001 .  " BAN_GSFRG_001
*--- End of FM06BFLI - 39 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFLI_BAN_ZEILE_001                    Level 2    Page 169
Object           SAPMZFM06B                                Lines 52
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      * Zeile: Selektionskennzeichen, Material, Warengruppe                  *
4      *----------------------------------------------------------------------*
5      FORM ban_zeile_001.
6
7        DATA: lv_matnr_txz01 TYPE c LENGTH 80.
8
9        IF NOT eban-gsfrg IS INITIAL AND NOT gs_banf IS INITIAL.
10     ENHANCEMENT-POINT fm06bfli_ban_zeile_001_01 SPOTS es_sapfm06b STATIC.
11     *... Bei Gesamtfreigabe werden die Positionen nur ausgegeben, wenn dies
12     *... im Listumfang explizit angegeben wurde ..........................*
13         CHECK NOT t16lb-gspos IS INITIAL.
14       ENDIF.
15       WRITE: /  sy-vline.
16       IF eban-gsfrg IS INITIAL OR gs_banf IS INITIAL.
17     *... Die Zeile soll nur dann selektierbar sein, wenn es sich nicht um *
18     *... Banf-Positionen handelt, die der Gesamtfreigabe unterliegen, ....*
19     *... denn dann gibr es eine eigene 'Kopfzeile'. ......................*
20         IF t16lh-xmkex NE space.
21           WRITE 2 ban-selkz AS CHECKBOX.
22         ELSE.
23           WRITE 2 ban-selkz AS CHECKBOX INPUT OFF.
24         ENDIF.
25       ENDIF.
26     ENHANCEMENT-SECTION     fm06bfli_ban_zeile_001_02 SPOTS es_sapfm06b.
27
28       IF eban-matnr+18(22) IS INITIAL.
29         WRITE:  4 eban-matnr(18),
30                   eban-txz01,
31                   eban-ekgrp,
32                71 eban-matkl,
33                81 sy-vline.
34       ELSE.
35         CONCATENATE eban-matnr eban-txz01 INTO lv_matnr_txz01 IN CHARACTER MODE SEPARATED BY space.
36         IF NOT lv_matnr_txz01+58(22) IS INITIAL.
37           CLEAR lv_matnr_txz01+58(22).
38           lv_matnr_txz01+55(3) = text-207.
39         ENDIF.
40         WRITE:  4 lv_matnr_txz01(58),
41                   eban-ekgrp,
42                71 eban-matkl,
43                81 sy-vline.
44       ENDIF.
45
46     END-ENHANCEMENT-SECTION.
47       HIDE eban-packno.
48
49     ENDFORM.
50
51
52     ENHANCEMENT-POINT fm06bfli_ban_zeile_001_03 SPOTS es_sapfm06b STATIC.
*--- End of FM06BFLI_BAN_ZEILE_001 - 52 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFLI_BAN_ZEILE_002                    Level 2    Page 170
Object           SAPMZFM06B                                Lines 29
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      * Zeile: Banf, Menge, Lieferdatum                                      *
4      *----------------------------------------------------------------------*
5      FORM BAN_ZEILE_002.
6
7        IF NOT EBAN-GSFRG IS INITIAL AND NOT GS_BANF IS INITIAL.
8      *... Bei Gesamtfreigabe werden die Positionen nur ausgegeben, wenn dies
9      *... im Listumfang explizit angegeben wurde ..........................*
10         CHECK NOT T16LB-GSPOS IS INITIAL.
11       ENDIF.
12       WRITE: /  SY-VLINE.
13       IF EBAN-GSFRG IS INITIAL OR GS_BANF IS INITIAL.
14         WRITE:  4 EBAN-BANFN.
15       ENDIF.
16     ENHANCEMENT-SECTION     FM06BFLI_BAN_ZEILE_002_01 SPOTS ES_SAPFM06B.
17       WRITE: 15 EBAN-BNFPO,
18          22(18) EBAN-MENGE UNIT EBAN-MEINS,
19              40 EBAN-MEINS,
20              44 RM06B-LPEIN,
21                 RM06B-EEIND,
22                 EBAN-AFNAM,
23              71 EBAN-WERKS,
24                 EBAN-LGORT,
25              81 SY-VLINE.
26       HIDE EBAN-PACKNO.
27     END-ENHANCEMENT-SECTION.
28
29     ENDFORM.
*--- End of FM06BFLI_BAN_ZEILE_002 - 29 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFLI_BAN_ZEILE_003                    Level 2    Page 171
Object           SAPMZFM06B                                Lines 31
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      * Zeile: div. Kennzeichen, Bestellte Menge, Freigabedatum ect.         *
4      *----------------------------------------------------------------------*
5      FORM BAN_ZEILE_003.
6
7        IF NOT EBAN-GSFRG IS INITIAL AND NOT GS_BANF IS INITIAL.
8      *... Bei Gesamtfreigabe werden die Positionen nur ausgegeben, wenn dies
9      *... im Listumfang explizit angegeben wurde ..........................*
10         CHECK NOT T16LB-GSPOS IS INITIAL.
11       ENDIF.
12       WRITE: /  SY-VLINE,
13               4  EBAN-STATU,
14                  EBAN-ESTKZ,
15                  EBAN-FRGKZ,
16                  EBAN-BSART,
17                  RM06B-EPSTP,
18                  EBAN-KNTTP.
19       IF EBAN-BSMNG NE 0.
20         WRITE: 22(18) EBAN-BSMNG UNIT EBAN-MEINS,
21                40 EBAN-MEINS.
22       ENDIF.
23     ENHANCEMENT-SECTION     FM06BFLI_BAN_ZEILE_003_01 SPOTS ES_SAPFM06B.
24       WRITE:  46 EBAN-FRGDT DD/MM/YYYY,
25                  EBAN-BEDNR,
26               71 EBAN-RESWK,
27                  EBAN-DISPO,
28               81 SY-VLINE.
29       HIDE EBAN-PACKNO.
30     END-ENHANCEMENT-SECTION.
31     ENDFORM.
*--- End of FM06BFLI_BAN_ZEILE_003 - 31 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFLI_BAN_ZEILE_004                    Level 2    Page 172
Object           SAPMZFM06B                                Lines 40
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      * Zeile: Bezugsquellenzuordnung                                        *
4      *----------------------------------------------------------------------*
5      FORM BAN_ZEILE_004.
6
7        IF NOT EBAN-GSFRG IS INITIAL AND NOT GS_BANF IS INITIAL.
8      *... Bei Gesamtfreigabe werden die Positionen nur ausgegeben, wenn dies
9      *... im Listumfang explizit angegeben wurde ..........................*
10         CHECK NOT T16LB-GSPOS IS INITIAL.
11       ENDIF.
12     *- keine Zuordnung: Leerzeile nur bei aktiver Zurodnungsfunktion ------*
13       IF BAN-UPDK1 EQ SPACE.
14         CHECK SY-PFKEY EQ 'ZUOR' OR
15               SY-PFKEY EQ 'BEAR'.
16       ENDIF.
17
18       IF BAN-UPDK1 NE ZOLD AND
19          BAN-UPDK1 NE SPACE AND
20          XT16LD-ZEILE EQ XZLTYP.
21         IF COLFLAG = 'X'.
22           FORMAT COLOR COL_POSITIVE INTENSIFIED.
23         ELSE.
24           FORMAT COLOR COL_POSITIVE INTENSIFIED OFF.
25         ENDIF.
26       ENDIF.
27
28     ENHANCEMENT-SECTION     FM06BFLI_BAN_ZEILE_004_01 SPOTS ES_SAPFM06B.
29       WRITE: /  SY-VLINE,
30               4 HLINE,
31              81 SY-VLINE.
32     END-ENHANCEMENT-SECTION.
33
34       IF COLFLAG = 'X'.
35         FORMAT COLOR COL_NORMAL INTENSIFIED.
36       ELSE.
37         FORMAT COLOR COL_NORMAL INTENSIFIED OFF.
38       ENDIF.
39
40     ENDFORM.
*--- End of FM06BFLI_BAN_ZEILE_004 - 40 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFLI_BAN_ZEILE_005                    Level 2    Page 173
Object           SAPMZFM06B                                Lines 52
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      * Zeile: Wunschlieferant                                               *
4      *----------------------------------------------------------------------*
5      FORM BAN_ZEILE_005.
6        DATA: llfa1_name1 type AD_NAME1.          "IAV
7        DATA: l_use_cam TYPE c.
8        IF NOT EBAN-GSFRG IS INITIAL AND NOT GS_BANF IS INITIAL.
9      *... Bei Gesamtfreigabe werden die Positionen nur ausgegeben, wenn dies
10     *... im Listumfang explizit angegeben wurde ..........................*
11         CHECK NOT T16LB-GSPOS IS INITIAL.
12       ENDIF.
13
14       IF EBAN-LIFNR NE SPACE.
15         CLEAR LFA1.
16         IF cl_iav_mapping_util=>is_iav_active( ) EQ 'X'. "IAV
17           l_use_cam = 'X'.
18         ENDIF.
19     * ALRK021852 begin inser
20         CALL FUNCTION 'WY_LFA1_GET_NAME'
21              EXPORTING
22                   PI_LIFNR         = EBAN-LIFNR
23                   PI_READ_CAM      = l_use_cam          "IAV
24              IMPORTING
25                   PO_NAME1         = LFA1-NAME1
26                   PO_CAM_NAME1     = Llfa1_name1  "IAV
27              EXCEPTIONS
28                   NO_RECORDS_FOUND = 1
29                   OTHERS           = 2.
30         if not llfa1_name1 is initial.   "IAV
31           lfa1-name1 = llfa1_name1.
32         endif.
33     * ALRK021852 end insert - begin delete
34     *  call function 'ME_GET_SUPPLIER'
35     *       exporting
36     *         supplier   = eban-lifnr
37     *       importing
38     *         name       = lfa1-name1
39     *       exceptions
40     *            error_message = 01.
41     * ALRK021852 end delete
42     ENHANCEMENT-SECTION     FM06BFLI_BAN_ZEILE_005_01 SPOTS ES_SAPFM06B.
43         WRITE: /  SY-VLINE,
44                 4 TEXT-049,
45                23 EBAN-LIFNR,
46                34 LFA1-NAME1,
47                81 SY-VLINE.
48     END-ENHANCEMENT-SECTION.
49         HIDE EBAN-PACKNO.
50       ENDIF.
51
52     ENDFORM.
*--- End of FM06BFLI_BAN_ZEILE_005 - 52 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFLI_BAN_ZEILE_006                    Level 2    Page 174
Object           SAPMZFM06B                                Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      * Zeile: Unterdeckungsmenge                                            *
4      *----------------------------------------------------------------------*
5      FORM BAN_ZEILE_006.
6
7        IF NOT EBAN-GSFRG IS INITIAL AND NOT GS_BANF IS INITIAL.
8      *... Bei Gesamtfreigabe werden die Positionen nur ausgegeben, wenn dies
9      *... im Listumfang explizit angegeben wurde ..........................*
10         CHECK NOT T16LB-GSPOS IS INITIAL.
11       ENDIF.
12       IF EBAN-BUMNG NE 0.
13     ENHANCEMENT-SECTION     FM06BFLI_BAN_ZEILE_006_01 SPOTS ES_SAPFM06B.
14         WRITE: /  SY-VLINE,
15                 4 TEXT-054,
16            22(18) EBAN-BUMNG UNIT EBAN-MEINS NO-SIGN,
17                40 EBAN-MEINS,
18                81 SY-VLINE.
19     END-ENHANCEMENT-SECTION.
20         HIDE EBAN-PACKNO.
21       ENDIF.
22
23     ENDFORM.
*--- End of FM06BFLI_BAN_ZEILE_006 - 23 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFLI_BAN_ZEILE_007                    Level 2    Page 175
Object           SAPMZFM06B                                Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      * Zeile: Wiedervorlage                                                 *
4      *----------------------------------------------------------------------*
5      FORM BAN_ZEILE_007.
6
7        IF NOT EBAN-GSFRG IS INITIAL AND NOT GS_BANF IS INITIAL.
8      *... Bei Gesamtfreigabe werden die Positionen nur ausgegeben, wenn dies
9      *... im Listumfang explizit angegeben wurde ..........................*
10         CHECK NOT T16LB-GSPOS IS INITIAL.
11       ENDIF.
12       IF EBAN-BVDAT NE 0.
13     ENHANCEMENT-SECTION     FM06BFLI_BAN_ZEILE_007_01 SPOTS ES_SAPFM06B.
14         WRITE: /  SY-VLINE,
15                 4  TEXT-055,
16                    EBAN-BVDAT DD/MM/YYYY,
17                 44 TEXT-060,
18                    EBAN-BVDRK,
19                 81 SY-VLINE.
20     END-ENHANCEMENT-SECTION.
21       ENDIF.
22
23     ENDFORM.
*--- End of FM06BFLI_BAN_ZEILE_007 - 23 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFLI_BAN_ZEILE_008                    Level 2    Page 176
Object           SAPMZFM06B                                Lines 41
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      * Zeile: Letzte Bestellung                                             *
4      *----------------------------------------------------------------------*
5      FORM BAN_ZEILE_008.
6
7        IF NOT EBAN-GSFRG IS INITIAL AND NOT GS_BANF IS INITIAL.
8      *... Bei Gesamtfreigabe werden die Positionen nur ausgegeben, wenn dies
9      *... im Listumfang explizit angegeben wurde ..........................*
10         CHECK NOT T16LB-GSPOS IS INITIAL.
11       ENDIF.
12
13     * IF EBAN-EBELN NE SPACE.                                  "88389/KB
14     *   CHECK EBAN-STATU NE 'K'.                               "88389/KB
15       CHECK NOT EBAN-EBELN IS INITIAL.     "88389/KB
16     *  IF EBAN-BSAKZ EQ SPACE.              "88389/KB         "DEL 328411
17       IF EBAN-BSAKZ EQ SPACE OR EBAN-BSAKZ EQ 'T'.            "INS 328411
18     ENHANCEMENT-SECTION     FM06BFLI_BAN_ZEILE_008_01 SPOTS ES_SAPFM06B.
19         WRITE: /  SY-VLINE,
20                 4 TEXT-056,
21                23 EBAN-EBELN,
22                   EBAN-EBELP,
23                42 TEXT-057,
24                46 EBAN-BEDAT DD/MM/YYYY NO-ZERO,
25                81 SY-VLINE.
26     END-ENHANCEMENT-SECTION.
27         HIDE EBAN-PACKNO.
28       ELSE.                                "88389/KB
29     ENHANCEMENT-SECTION     FM06BFLI_BAN_ZEILE_008_02 SPOTS ES_SAPFM06B.
30         WRITE: /  SY-VLINE,                "88389/KB
31                 4 TEXT-069,                "88389/KB
32                23 EBAN-EBELN,              "88389/KB
33                   EBAN-EBELP,              "88389/KB
34                42 TEXT-057,                "88389/KB
35                46 EBAN-BEDAT DD/MM/YYYY NO-ZERO,                 "88389/KB
36                81 SY-VLINE.                "88389/KB
37     END-ENHANCEMENT-SECTION.
38         HIDE EBAN-PACKNO.                  "88389/KB
39       ENDIF.
40
41     ENDFORM.
*--- End of FM06BFLI_BAN_ZEILE_008 - 41 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFLI_BAN_ZEILE_009                    Level 2    Page 177
Object           SAPMZFM06B                                Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      * Zeile: Dispodaten aus Materialstamm                                  *
4      *----------------------------------------------------------------------*
5      FORM BAN_ZEILE_009.
6
7        IF NOT EBAN-GSFRG IS INITIAL AND NOT GS_BANF IS INITIAL.
8      *... Bei Gesamtfreigabe werden die Positionen nur ausgegeben, wenn dies
9      *... im Listumfang explizit angegeben wurde ..........................*
10         CHECK NOT T16LB-GSPOS IS INITIAL.
11       ENDIF.
12       CHECK EBAN-MATNR EQ MT61D-MATNR.
13       CHECK EBAN-WERKS EQ MT61D-WERKS.
14     ENHANCEMENT-SECTION     FM06BFLI_BAN_ZEILE_009_01 SPOTS ES_SAPFM06B.
15       WRITE: /  SY-VLINE,
16               4 MT61D-DISMM,
17               8 MT61D-DISLS,
18              11 MT61D-BESKZ,
19          14(17) MT61D-MINBE UNIT EBAN-MEINS NO-SIGN,
20                 EBAN-MEINS,
21          36(17) MT61D-EISBE UNIT EBAN-MEINS NO-SIGN,
22                 EBAN-MEINS,
23              59 MT61D-SOBSL,
24              64 MT61D-PLIFZ,
25              81 SY-VLINE.
26     END-ENHANCEMENT-SECTION.
27
28     ENDFORM.
*--- End of FM06BFLI_BAN_ZEILE_009 - 28 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFLI_BAN_ZEILE_010                    Level 2    Page 178
Object           SAPMZFM06B                                Lines 30
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      * Zeile: Freigabeinformation                                           *
4      *----------------------------------------------------------------------*
5      FORM BAN_ZEILE_010.
6        IF NOT GS_BANF IS INITIAL.
7      *... Eigene Listaufbereitung für Gesamtbanfen ........................*
8          CHECK EBAN-GSFRG IS INITIAL.
9        ENDIF.
10       IF BAN-UPDK3 NE SPACE.
11         IF COLFLAG = 'X'.
12           FORMAT COLOR COL_POSITIVE INTENSIFIED.
13         ELSE.
14           FORMAT COLOR COL_POSITIVE INTENSIFIED OFF.
15         ENDIF.
16       ENDIF.
17
18     ENHANCEMENT-SECTION     FM06BFLI_BAN_ZEILE_010_01 SPOTS ES_SAPFM06B.
19       WRITE: /  SY-VLINE,
20               4 FLINE,
21              81 SY-VLINE.
22     END-ENHANCEMENT-SECTION.
23
24       IF COLFLAG = 'X'.
25         FORMAT COLOR COL_NORMAL INTENSIFIED.
26       ELSE.
27         FORMAT COLOR COL_NORMAL INTENSIFIED OFF.
28       ENDIF.
29
30     ENDFORM.
*--- End of FM06BFLI_BAN_ZEILE_010 - 30 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFLI_BAN_ZEILE_011                    Level 2    Page 179
Object           SAPMZFM06B                                Lines 73
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      * Zeile: div. Kennzeichen, Positionswert, Freigabedatum ect.           *
4      *----------------------------------------------------------------------*
5      FORM BAN_ZEILE_011.
6
7        IF NOT EBAN-GSFRG IS INITIAL AND NOT GS_BANF IS INITIAL.
8      *... Bei Gesamtfreigabe werden die Positionen nur ausgegeben, wenn dies
9      *... im Listumfang explizit angegeben wurde ..........................*
10         CHECK NOT T16LB-GSPOS IS INITIAL.
11       ENDIF.
12     *--- Gesamtwert der Position berechnen --------------------------------*
13       IF EBAN-PEINH NE 0.
14         REFE1 = EBAN-PREIS * EBAN-MENGE / 1000 / EBAN-PEINH.
15       ELSE.
16         REFE1 = 0.
17       ENDIF.
18       IF REFE1 LE MAXWERT.
19         RM06B-GSWRT = REFE1.
20       ELSE.
21         RM06B-GSWRT = MAXWERT.
22       ENDIF.
23
24       IF EBAN-WERKS NE T001W-WERKS.
25         SELECT SINGLE * FROM T001W WHERE WERKS EQ EBAN-WERKS.
26       ENDIF.
27       IF T001K-BWKEY NE T001W-BWKEY.
28         SELECT SINGLE * FROM T001K WHERE BWKEY EQ T001W-BWKEY.
29       ENDIF.
30       IF T001K-BUKRS NE T001-BUKRS.
31         SELECT SINGLE * FROM T001 WHERE BUKRS EQ T001K-BUKRS.
32       ENDIF.
33
34       WRITE: /  SY-VLINE,
35               4  EBAN-STATU,
36                  EBAN-ESTKZ,
37                  EBAN-FRGKZ,
38                  EBAN-BSART,
39                  RM06B-EPSTP,
40                  EBAN-KNTTP.
41       IF NOT ( EBAN-WAERS IS INITIAL ).
42         WRITE:   22(17) RM06B-GSWRT CURRENCY EBAN-WAERS NO-SIGN,
43                  40 EBAN-WAERS.
44       ELSE.
45         IF NOT BAN-ARCH_DATE IS INITIAL.   "TK 4.0B EURO
46     * die zum Zeitpunkt der Archivierung gültige Hauswährung besorgen
47           DATA: L_WAERS LIKE T001-WAERS.
48           CALL FUNCTION 'EWU_GET_CUKEY_ORG'
49                EXPORTING
50                     WAEHRUNGSURSPRUNG   = '10'
51                     AUSPRAEGUNG         = T001-BUKRS
52                     GUELTIGKEITSDATUM   = BAN-ARCH_DATE
53                IMPORTING
54                     WAEHRUNGSSCHLUESSEL = L_WAERS
55                EXCEPTIONS
56                     OTHERS              = 1.
57           IF SY-SUBRC EQ 0 AND L_WAERS NE SPACE.
58             T001-WAERS = L_WAERS.
59           ELSE.
60     *  ??????? da gibt's wohl ein Problem
61           ENDIF.
62         ENDIF.                             "TK 4.0B EURO
63         WRITE:   22(17) RM06B-GSWRT CURRENCY T001-WAERS NO-SIGN,
64                  40 T001-WAERS.
65       ENDIF.
66     ENHANCEMENT-SECTION     FM06BFLI_BAN_ZEILE_011_01 SPOTS ES_SAPFM06B.
67       WRITE:  46 EBAN-FRGDT DD/MM/YYYY,
68                  EBAN-BEDNR,
69               71 EBAN-RESWK,
70                  EBAN-DISPO,
71               81 SY-VLINE.
72     END-ENHANCEMENT-SECTION.
73     ENDFORM.
*--- End of FM06BFLI_BAN_ZEILE_011 - 73 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFLI_BAN_ZEILE_012                    Level 2    Page 180
Object           SAPMZFM06B                                Lines 50
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      * Zeile: Infosatz/Rahmenvertragsdaten                                  *
4      *----------------------------------------------------------------------*
5      FORM BAN_ZEILE_012.
6        IF NOT EBAN-GSFRG IS INITIAL AND NOT GS_BANF IS INITIAL.
7      *... Bei Gesamtfreigabe werden die Positionen nur ausgegeben, wenn dies
8      *... im Listumfang explizit angegeben wurde ..........................*
9          CHECK NOT T16LB-GSPOS IS INITIAL.
10       ENDIF.
11       IF EBAN-INFNR NE SPACE.
12         CLEAR APREIS.
13         WRITE EINE-NETPR TO APREIS-NETPR CURRENCY EINE-WAERS NO-SIGN.
14         WRITE EINE-BPRME TO APREIS-BPRME.
15         IF EINE-PEINH NE 1.
16           WRITE EINE-PEINH TO APREIS-PEINH.
17         ENDIF.
18         APREIS-STRICH = '/'.
19         APREIS-WAERS  = EINE-WAERS.
20         CONDENSE APREIS.
21         WRITE: /  SY-VLINE,
22                 4  TEXT-065,
23                    APREIS.
24         IF EINE-MINBM NE 0.
25           WRITE: 45 TEXT-066,
26                     EINE-MINBM UNIT EINA-MEINS NO-SIGN,
27                     EINA-MEINS.
28         ENDIF.
29     ENHANCEMENT-POINT FM06BFLI_BAN_ZEILE_012_01 SPOTS ES_SAPFM06B.
30         WRITE 81 SY-VLINE.
31       ELSE.
32         IF EBAN-KONNR NE SPACE.
33           CLEAR APREIS.
34           WRITE EKPO-NETPR TO APREIS-NETPR CURRENCY EKKO-WAERS NO-SIGN.
35           WRITE EKPO-BPRME TO APREIS-BPRME.
36           IF EKPO-PEINH NE 1.
37             WRITE EKPO-PEINH TO APREIS-PEINH.
38           ENDIF.
39           APREIS-STRICH = '/'.
40           APREIS-WAERS  = EKKO-WAERS.
41           CONDENSE APREIS.
42     ENHANCEMENT-SECTION     FM06BFLI_BAN_ZEILE_012_02 SPOTS ES_SAPFM06B.
43           WRITE: /  SY-VLINE,
44                   4  TEXT-065,
45                      APREIS.
46           WRITE 81 SY-VLINE.
47     END-ENHANCEMENT-SECTION.
48         ENDIF.
49       ENDIF.
50     ENDFORM.
*--- End of FM06BFLI_BAN_ZEILE_012 - 50 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFLI_BAN_ZEILE_013                    Level 2    Page 181
Object           SAPMZFM06B                                Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      * Zeile: Lieferantenstammdaten                                         *
4      *----------------------------------------------------------------------*
5      FORM BAN_ZEILE_013.
6        IF NOT EBAN-GSFRG IS INITIAL AND NOT GS_BANF IS INITIAL.
7      *... Bei Gesamtfreigabe werden die Positionen nur ausgegeben, wenn dies
8      *... im Listumfang explizit angegeben wurde ..........................*
9          CHECK NOT T16LB-GSPOS IS INITIAL.
10       ENDIF.
11       CHECK EBAN-FLIEF NE SPACE.
12       CHECK LFM1-INCO1 NE SPACE OR
13             LFM1-MINBW NE 0.
14       WRITE /  SY-VLINE.
15       IF LFM1-INCO1 NE SPACE.
16         WRITE: 4  TEXT-068,
17                15 LFM1-INCO1,
18                   LFM1-INCO2.
19       ENDIF.
20       IF LFM1-MINBW NE 0.
21         WRITE: 45 TEXT-067,
22                   LFM1-MINBW CURRENCY LFM1-WAERS NO-SIGN,
23                   LFM1-WAERS.
24       ENDIF.
25     ENHANCEMENT-SECTION     FM06BFLI_BAN_ZEILE_013_01 SPOTS ES_SAPFM06B.
26       WRITE 81 SY-VLINE.
27     END-ENHANCEMENT-SECTION.
28     ENDFORM.
*--- End of FM06BFLI_BAN_ZEILE_013 - 28 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFLI_BAN_ZEILE_014                    Level 2    Page 182
Object           SAPMZFM06B                                Lines 32
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      * Zeile: Bestands-/Bedarfssituation                                    *
4      *----------------------------------------------------------------------*
5      FORM BAN_ZEILE_014.
6
7        IF NOT EBAN-GSFRG IS INITIAL AND NOT GS_BANF IS INITIAL.
8      *... Bei Gesamtfreigabe werden die Positionen nur ausgegeben, wenn dies
9      *... im Listumfang explizit angegeben wurde ..........................*
10         CHECK NOT T16LB-GSPOS IS INITIAL.
11       ENDIF.
12       CHECK EBAN-MATNR NE SPACE.
13       CHECK EBAN-WERKS NE SPACE.
14       WRITE: /  SY-VLINE.
15       IF MDKP-DSDAT NE 0.
16         WRITE 4  MDKP-DSDAT DD/MM/YY.
17       ENDIF.
18       WRITE:
19          14(17) MDSTA-SUM01 UNIT EBAN-MEINS NO-SIGN,
20                 EBAN-MEINS.
21       IF MDKP-DSDAT NE 0.
22         WRITE:
23         36(17) MDSTA-SUM02 UNIT EBAN-MEINS NO-SIGN,
24                EBAN-MEINS,
25         58(17) MDSTA-SUM04 UNIT EBAN-MEINS NO-SIGN,
26                EBAN-MEINS.
27       ENDIF.
28     ENHANCEMENT-SECTION     FM06BFLI_BAN_ZEILE_014_01 SPOTS ES_SAPFM06B.
29       WRITE 81 SY-VLINE.
30     END-ENHANCEMENT-SECTION.
31
32     ENDFORM.
*--- End of FM06BFLI_BAN_ZEILE_014 - 32 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFLI_BAN_ZEILE_102                    Level 2    Page 183
Object           SAPMZFM06B                                Lines 31
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      * Zeile: Selektionskennzeichen, Material, Werk, Lagerort               *
4      *----------------------------------------------------------------------*
5      FORM BAN_ZEILE_102.
6        IF NOT EBAN-GSFRG IS INITIAL AND NOT GS_BANF IS INITIAL.
7      *... Bei Gesamtfreigabe werden die Positionen nur ausgegeben, wenn dies
8      *... im Listumfang explizit angegeben wurde ..........................*
9          CHECK NOT T16LB-GSPOS IS INITIAL.
10       ENDIF.
11       WRITE: /  SY-VLINE,
12              4  EBAN-BSART,
13                 RM06B-EPSTP,
14                 EBAN-KNTTP,
15          14(17) EBAN-MENGE UNIT EBAN-MEINS NO-SIGN,
16                 EBAN-MEINS,
17                 RM06B-LPEIN,
18                 RM06B-EEIND,
19                 EBAN-WERKS,
20                 EBAN-LGORT,
21                 EBAN-RESWK,
22                 EBAN-DISPO.
23       IF XT16LD-ZEILE EQ XZLTYP.
24         WRITE: 71 T16LA-UPDT2 COLOR COL_POSITIVE.
25       ELSE.
26         WRITE: 71 T16LA-UPDT2.
27       ENDIF.
28     ENHANCEMENT-SECTION     FM06BFLI_BAN_ZEILE_102_01 SPOTS ES_SAPFM06B.
29       WRITE: 81 SY-VLINE.
30     END-ENHANCEMENT-SECTION.
31     ENDFORM.
*--- End of FM06BFLI_BAN_ZEILE_102 - 31 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFLI_BAN_ZEILE_201                    Level 2    Page 184
Object           SAPMZFM06B                                Lines 40
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      * Zeile: Sel., Material, Menge, Lieferdatum, Zuordnung                 *
4      *----------------------------------------------------------------------*
5      FORM BAN_ZEILE_201.
6
7
8      ENHANCEMENT-POINT FM06BFLI_BAN_ZEILE_201_02 SPOTS ES_SAPFM06B STATIC.
9
10     ENHANCEMENT-SECTION     FM06BFLI_BAN_ZEILE_201_01 SPOTS ES_SAPFM06B.
11       IF NOT EBAN-GSFRG IS INITIAL AND NOT GS_BANF IS INITIAL.
12     *... Bei Gesamtfreigabe werden die Positionen nur ausgegeben, wenn dies
13     *... im Listumfang explizit angegeben wurde ..........................*
14         CHECK NOT T16LB-GSPOS IS INITIAL.
15       ENDIF.
16       WRITE: /  SY-VLINE,
17               2 EBAN-MATNR,
18              42 SY-VLINE,
19          21(20) EBAN-TXZ01,
20              41 SY-VLINE,
21          42(17) EBAN-MENGE UNIT EBAN-MEINS NO-SIGN,
22              59 SY-VLINE,
23              60 EBAN-MEINS,
24              63 SY-VLINE,
25              64 RM06B-LPEIN,
26              66 RM06B-EEIND,
27              76 SY-VLINE.
28
29       IF XT16LD-ZEILE EQ XZLTYP.
30         WRITE: 77 T16LA-UPDT1 COLOR COL_POSITIVE.
31       ELSE.
32         WRITE: 77 T16LA-UPDT1.
33       ENDIF.
34       WRITE: 81 SY-VLINE.
35     END-ENHANCEMENT-SECTION.
36
37
38
39
40     ENDFORM.
*--- End of FM06BFLI_BAN_ZEILE_201 - 40 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFLI_BAN_GSFRG_001                    Level 2    Page 185
Object           SAPMZFM06B                                Lines 29
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *---------------------------------------------------------------------*
2      *       FORM BAN_GESAMTFRG_001                                        *
3      *---------------------------------------------------------------------*
4      *  'Kopfzeile' für Banfen, die der Gesamtfreigabe unterliegen          *
5      *---------------------------------------------------------------------*
6      FORM BAN_GSFRG_001.
7        CHECK NOT GS_BANF    IS INITIAL.
8        CHECK NOT EBAN-GSFRG IS INITIAL.
9      *... 'Kopfzeilen' der Banf bei Gesamtfreigabe kennzeichnen ...........*
10       HIDE-GSFRG = EBAN-GSFRG.
11       WRITE: /  SY-VLINE.
12       IF T16LH-XMKEX NE SPACE.
13         WRITE 2 BAN-SELKZ AS CHECKBOX.
14       ELSE.
15         WRITE 2 BAN-SELKZ AS CHECKBOX INPUT OFF.
16       ENDIF.
17     ENHANCEMENT-SECTION     FM06BFLI_BAN_GSFRG_001_01 SPOTS ES_SAPFM06B.
18       WRITE:  4 EBAN-BANFN,
19                 TEXT-077,
20              54 ICON_FIELD AS ICON,
21              81 SY-VLINE.
22     * write at 50 icon_yellow_light as icon.
23       HIDE: HIDE-INDEX, HIDE-GSFRG.
24       WRITE: / SY-VLINE,
25              4 FLINE,
26             81 SY-VLINE.
27     END-ENHANCEMENT-SECTION.
28       HIDE: HIDE-INDEX, HIDE-GSFRG.
29     ENDFORM.
*--- End of FM06BFLI_BAN_GSFRG_001 - 29 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFLZ                                  Level 1    Page 186
Object           SAPMZFM06B                                Lines 11
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      ***INCLUDE FM06BFLZ.
2      * INCLUDE für Kundenspezifische Listzeilen
3      *eject
4      *----------------------------------------------------------------------*
5      * Zeile: ??? Beispiel                                                  *
6      *----------------------------------------------------------------------*
7      FORM BAN_ZEILE_900.
8      WRITE: /  SY-VLINE.
9      * WRITE: ....
10     WRITE: 81 SY-VLINE.
11     ENDFORM.
*--- End of FM06BFLZ - 11 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFDA                                  Level 1    Page 187
Object           SAPMZFM06B                                Lines 37
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1        INCLUDE FM06BFDA_BAN_DATEN_PRE .  " BAN_DATEN_PRE
2        INCLUDE FM06BFDA_BAN_DATEN .  " BAN_DATEN
3
4        INCLUDE FM06BFDA_BAN_DATEN_PR1_001 .  " BAN_DATEN_PR1_001
5
6        INCLUDE FM06BFDA_BAN_DATEN_PR1_002 .  " BAN_DATEN_PR1_002
7
8        INCLUDE FM06BFDA_BAN_DATEN_PR1_003 .  " BAN_DATEN_PR1_003
9
10       INCLUDE FM06BFDA_BAN_DATEN_PR2_001 .  " BAN_DATEN_PR2_001
11
12       INCLUDE FM06BFDA_BAN_DATEN_PR2_002 .  " BAN_DATEN_PR2_002
13
14       INCLUDE FM06BFDA_BAN_DATEN_PR2_003 .  " BAN_DATEN_PR2_003
15
16       INCLUDE FM06BFDA_BAN_DATEN_001 .  " BAN_DATEN_001
17
18       INCLUDE FM06BFDA_BAN_DATEN_002 .  " BAN_DATEN_002
19
20       INCLUDE FM06BFDA_BAN_DATEN_003 .  " BAN_DATEN_003
21
22       INCLUDE FM06BFDA_BAN_DATEN_004 .  " BAN_DATEN_004
23       INCLUDE FM06BFDA_BAN_DATEN_005 .  " BAN_DATEN_005
24
25       INCLUDE FM06BFDA_BAN_DATEN_006 .  " BAN_DATEN_006
26
27       INCLUDE FM06BFDA_BAN_DATEN_007 .  " BAN_DATEN_007
28
29       INCLUDE FM06BFDA_BAN_DATEN_008 .  " BAN_DATEN_008
30
31       INCLUDE FM06BFDA_BAN_DATEN_009 .  " BAN_DATEN_009
32
33       INCLUDE FM06BFDA_BAN_DATEN_004_ANZEIGE .  " BAN_DATEN_004_ANZEIGEN
34
35       INCLUDE FM06BFDA_BAN_DATEN_009_ANZEIGE .  " BAN_DATEN_009_ANZEIGEN
36
37     *eject
*--- End of FM06BFDA - 37 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFDA_BAN_DATEN_PRE                    Level 2    Page 188
Object           SAPMZFM06B                                Lines 32
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      ***INCLUDE FM06BFDA.
2      *eject
3      *----------------------------------------------------------------------*
4      * Daten für Banfliste dazulesen
5      *----------------------------------------------------------------------*
6      FORM BAN_DATEN_PRE.
7
8      *- Prüfen ob überhaupt Zusatzdaten gelesen werden müssen --------------*
9      LOOP AT XT16LI WHERE XPREF NE SPACE.
10        EXIT.
11     ENDLOOP.
12     CHECK SY-SUBRC EQ 0.
13
14     *- Liste der Schlüssel aufbauen aus jeder Banf ------------------------*
15     REFRESH XPRE01.
16     CLEAR HROUTN.
17     HROUTN(14) = 'BAN_DATEN_PR1_'.
18     LOOP AT BAN.
19        LOOP AT XT16LI WHERE XPREF NE SPACE.
20           HROUTN+14(3) = XT16LI-LDATE.
21           PERFORM (HROUTN) IN PROGRAM SAPFM06B.
22        ENDLOOP.
23     ENDLOOP.
24     *- Pre-Fetch mit Liste der Schlüssel ----------------------------------*
25     CLEAR HROUTN.
26     HROUTN(14) = 'BAN_DATEN_PR2_'.
27     LOOP AT XT16LI WHERE XPREF NE SPACE.
28        HROUTN+14(3) = XT16LI-LDATE.
29        PERFORM (HROUTN) IN PROGRAM SAPFM06B.
30     ENDLOOP.
31
32     ENDFORM.
*--- End of FM06BFDA_BAN_DATEN_PRE - 32 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFDA_BAN_DATEN                        Level 2    Page 189
Object           SAPMZFM06B                                Lines 20
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      * Daten für Banfliste bereitstellen
4      *----------------------------------------------------------------------*
5      FORM BAN_DATEN USING BDA_LFLAG.
6
7      CLEAR HROUTN.
8      HROUTN(10) = 'BAN_DATEN_'.
9      LOOP AT XT16LI.
10        CASE BDA_LFLAG.
11           WHEN 'G'. CHECK XT16LI-XGRLI NE SPACE.
12           WHEN 'D'. CHECK XT16LI-XDELI NE SPACE.
13        ENDCASE.
14        HROUTN+10(3) = XT16LI-LDATE.
15        PERFORM (HROUTN) IN PROGRAM SAPFM06B.
16     ENDLOOP.
17     *- Für MDSTA-Mengenfelder ---------------------------------------------*
18     MARA-MEINS = EBAN-MEINS.
19
20     ENDFORM.
*--- End of FM06BFDA_BAN_DATEN - 20 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFDA_BAN_DATEN_PR1_001                Level 2    Page 190
Object           SAPMZFM06B                                Lines 22
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      * Materialstamm mit View MA61V lesen - Prefetch vorbereiten
4      *----------------------------------------------------------------------*
5      FORM BAN_DATEN_PR1_001.
6
7      CHECK BAN-MATNR NE SPACE.
8      CHECK BAN-WERKS NE SPACE.
9      XPRE01-MATNR = BAN-MATNR.
10     XPRE01-WERKS = BAN-WERKS.
11     READ TABLE XPRE01 BINARY SEARCH.
12     CASE SY-SUBRC.
13        WHEN 4.
14           IF SY-TABIX EQ 0.
15              SY-TABIX = 1.
16           ENDIF.
17           INSERT XPRE01 INDEX SY-TABIX.
18        WHEN 8.
19           APPEND XPRE01.
20     ENDCASE.
21
22     ENDFORM.
*--- End of FM06BFDA_BAN_DATEN_PR1_001 - 22 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFDA_BAN_DATEN_PR1_002                Level 2    Page 191
Object           SAPMZFM06B                                Lines 6
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      * Lieferantenstamm lesen - Prefetch vorbereiten
4      *----------------------------------------------------------------------*
5      FORM BAN_DATEN_PR1_002.
6      ENDFORM.
*--- End of FM06BFDA_BAN_DATEN_PR1_002 - 6 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFDA_BAN_DATEN_PR1_003                Level 2    Page 192
Object           SAPMZFM06B                                Lines 6
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      * Infosatz lesen - Prefetch vorbereiten
4      *----------------------------------------------------------------------*
5      FORM BAN_DATEN_PR1_003.
6      ENDFORM.
*--- End of FM06BFDA_BAN_DATEN_PR1_003 - 6 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFDA_BAN_DATEN_PR2_001                Level 2    Page 193
Object           SAPMZFM06B                                Lines 16
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      * Materialstamm mit View MA61V lesen - Prefetch durchführen
4      *----------------------------------------------------------------------*
5      FORM BAN_DATEN_PR2_001.
6
7      READ TABLE XPRE01 INDEX 1.
8      IF SY-SUBRC EQ 0.
9         CALL FUNCTION 'MATERIAL_PRE_READ_MA61V'
10             EXPORTING
11                  KZRFB = 'X'
12             TABLES
13                  MA61V_KEYTAB = XPRE01.
14     ENDIF.
15
16     ENDFORM.
*--- End of FM06BFDA_BAN_DATEN_PR2_001 - 16 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFDA_BAN_DATEN_PR2_002                Level 2    Page 194
Object           SAPMZFM06B                                Lines 6
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      * Lieferantenstamm lesen - Prefetch durchführen
4      *----------------------------------------------------------------------*
5      FORM BAN_DATEN_PR2_002.
6      ENDFORM.
*--- End of FM06BFDA_BAN_DATEN_PR2_002 - 6 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFDA_BAN_DATEN_PR2_003                Level 2    Page 195
Object           SAPMZFM06B                                Lines 6
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      * Infosatz lesen - Prefetch durchführen
4      *----------------------------------------------------------------------*
5      FORM BAN_DATEN_PR2_003.
6      ENDFORM.
*--- End of FM06BFDA_BAN_DATEN_PR2_003 - 6 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFDA_BAN_DATEN_001                    Level 2    Page 196
Object           SAPMZFM06B                                Lines 29
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      * Materialstamm mit View MT61D lesen
4      *----------------------------------------------------------------------*
5      FORM BAN_DATEN_001.
6
7      IF EBAN-MATNR EQ SPACE OR
8         EBAN-WERKS EQ SPACE.
9         CLEAR MT61D.
10        EXIT.
11     ENDIF.
12     IF EBAN-MATNR NE MT61D-MATNR OR
13        EBAN-WERKS NE MT61D-WERKS.
14        CLEAR MT61D.
15        CLEAR MTCOM.
16        MTCOM-KENNG = 'MT61D'.
17        MTCOM-NOVOR = 'X'.
18        MTCOM-MATNR = EBAN-MATNR.
19        MTCOM-WERKS = EBAN-WERKS.
20        CALL FUNCTION 'MATERIAL_READ'
21             EXPORTING
22                  SCHLUESSEL = MTCOM
23             IMPORTING
24                  MATDATEN = MT61D
25             TABLES
26                  SEQMAT01 = KON.
27     ENDIF.
28
29     ENDFORM.
*--- End of FM06BFDA_BAN_DATEN_001 - 29 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFDA_BAN_DATEN_002                    Level 2    Page 197
Object           SAPMZFM06B                                Lines 29
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      * Lieferantenstamm lesen
4      *----------------------------------------------------------------------*
5      FORM BAN_DATEN_002.
6      CLEAR: LFA1, LFM1.
7      CHECK EBAN-FLIEF NE SPACE.
8      SELECT SINGLE * FROM LFA1 WHERE LIFNR EQ EBAN-FLIEF.
9
10     * DP&P: Check for blocked vendor
11     INCLUDE MMPUR_DPP_FM06BFDA_BAN_DATEN_2 IF FOUND.              "2119405
12
13     CHECK EBAN-EKORG NE SPACE.
14     * Beginn \BE
15     *SELECT SINGLE * FROM LFM1 WHERE LIFNR EQ EBAN-FLIEF
16     *                            AND EKORG EQ EBAN-EKORG.
17     CALL FUNCTION 'VENDOR_MASTER_DATA_SELECT_12'
18          EXPORTING
19               PI_LIFNR       =  EBAN-FLIEF
20               PI_EKORG       =  EBAN-EKORG
21          IMPORTING
22               PE_LFM1        =  LFM1
23     *         PE_EKORZ       =
24          EXCEPTIONS
25               NO_ENTRY_FOUND = 1
26               OTHERS         = 2.
27     * Ende \BE
28
29     ENDFORM.
*--- End of FM06BFDA_BAN_DATEN_002 - 29 lines ---

----------------------------------------------------------------------------------------------------
Include          MMPUR_DPP_FM06BFDA_BAN_DATEN_2            Level 3    Page 198
Object           SAPMZFM06B                                Lines 22
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&  Include           MMPUR_DPP_FM06BFDA_BAN_DATEN_2
3      *&---------------------------------------------------------------------*
4
5      * Called from INCLUDE FM06BFDA_BAN_DATEN_002
6      * DP&P: Check for blocked vendor
7
8      DATA lo_switch TYPE REF TO cl_mm_switch_check.
9
10     lo_switch = cl_mm_switch_check=>get_instance( ).
11
12     IF lo_switch->mm_ddp_sfws_sc( ) IS NOT INITIAL.
13       CALL METHOD cvp_cl_block_and_mask=>block_and_mask_generic
14         EXPORTING
15           iv_lifnr         = lfa1-lifnr
16           iv_set_to_buffer = cvp_cl_block_and_mask=>gc_true
17         CHANGING
18           cs_struct_w_cvp  = lfa1
19         EXCEPTIONS
20           lifnr_blocked    = 1
21           OTHERS           = 4.
22     ENDIF.
*--- End of MMPUR_DPP_FM06BFDA_BAN_DATEN_2 - 22 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFDA_BAN_DATEN_003                    Level 2    Page 199
Object           SAPMZFM06B                                Lines 40
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      * Infosatz/Rahmenvertrag lesen
4      *----------------------------------------------------------------------*
5      FORM BAN_DATEN_003.
6
7      CLEAR: EINA, EINE.
8      CLEAR: EKKO, EKPO.
9      IF EBAN-INFNR NE SPACE.
10        MEICO-INFNR = EBAN-INFNR.
11        MEICO-EKORG = EBAN-EKORG.
12        MEICO-WERKS = EBAN-WERKS.
13        IF EBAN-PSTYP EQ PSTYP-LOHN.
14           MEICO-ESOKZ = EBAN-PSTYP.
15        ELSEIF EBAN-PSTYP EQ PSTYP-KONS.                       "172737
16           MEICO-ESOKZ = EBAN-PSTYP.                           "172737
17        ELSE.                                                  "172737
18           MEICO-ESOKZ = PSTYP-LAGM.                           "172737
19        ENDIF.
20        CALL FUNCTION 'ME_READ_INFORECORD'
21             EXPORTING
22                  INCOM = MEICO
23     *         INPREISSIM = E02
24             IMPORTING
25     *         DATEN = I01
26                  EINADATEN = EINA
27                  EINEDATEN = EINE
28     *         EXCOM = I04
29     *         EXPREISSIM = I05
30             EXCEPTIONS
31                  OTHERS = 01.
32     ELSE.
33        IF EBAN-KONNR NE SPACE.
34           SELECT SINGLE * FROM EKKO WHERE EBELN EQ EBAN-KONNR.
35           SELECT SINGLE * FROM EKPO WHERE EBELN EQ EBAN-KONNR
36                                       AND EBELP EQ EBAN-KTPNR.
37        ENDIF.
38     ENDIF.
39
40     ENDFORM.
*--- End of FM06BFDA_BAN_DATEN_003 - 40 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFDA_BAN_DATEN_004                    Level 2    Page 200
Object           SAPMZFM06B                                Lines 61
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      * Materialverbräuche
4      *----------------------------------------------------------------------*
5      FORM BAN_DATEN_004.
6
7      CLEAR VINDEX.
8      CHECK EBAN-MATNR NE SPACE.
9      CHECK EBAN-WERKS NE SPACE.
10
11     *- Verbräuche schon gelesen ? -----------------------------------------*
12     MATKEY-MATNR = EBAN-MATNR.
13     MATKEY-WERKS = EBAN-WERKS.
14     READ TABLE MVERB WITH KEY MATKEY BINARY SEARCH.
15     MINDEX = SY-TABIX.
16     VINDEX = SY-TABIX.
17     IF SY-SUBRC NE 0.
18     *- Materialstamm nachlesen --------------------------------------------*
19        IF MT61D-MATNR NE EBAN-MATNR OR
20           MT61D-WERKS NE EBAN-WERKS.
21           PERFORM BAN_DATEN_001.
22        ENDIF.
23        REFRESH GVERB.
24        CALL FUNCTION 'VERBRAUCH_LESEN'
25             EXPORTING
26     *         ABDATUM                  = '19000101'
27                  ANZAHL                   = 4
28     *         BISDATUM                 = SY-DATUM
29     *         FLAG_MATSTAMM            = ' '
30     *         KZGEK                    = ' '
31                  KZGES                    = 'X'
32     *         KZUNG                    = ' '
33     *         KZUNK                    = ' '
34                  MATNR                    = EBAN-MATNR
35                  PERIV                    = MT61D-PERIV
36                  PERKZ                    = MT61D-PERKZ
37                  WERKS                    = EBAN-WERKS
38             TABLES
39                  GES_VERB                 = GVERB
40                  GES_VERB_KOR             = XVERB
41                  UNG_VERB                 = XVERB
42                  UNG_VERB_KOR             = XVERB
43             EXCEPTIONS
44                  OTHERS = 01.
45        CLEAR MVERB.
46        MVERB-MATNR = EBAN-MATNR.
47        MVERB-WERKS = EBAN-WERKS.
48        IF SY-SUBRC EQ 0.
49           LOOP AT GVERB.
50              CHECK SY-TABIX LE 4.
51              MOVE-CORRESPONDING GVERB TO MVERB.
52              INSERT MVERB INDEX MINDEX.
53              MINDEX = MINDEX + 1.
54           ENDLOOP.
55        ELSE.
56           INSERT MVERB INDEX VINDEX.
57        ENDIF.
58
59     ENDIF.
60
61     ENDFORM.
*--- End of FM06BFDA_BAN_DATEN_004 - 61 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFDA_BAN_DATEN_005                    Level 2    Page 201
Object           SAPMZFM06B                                Lines 57
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      * Materialbestände
4      *----------------------------------------------------------------------*
5      FORM BAN_DATEN_005.
6
7      CLEAR MDSTA.
8      CLEAR MMDSA.
9      CHECK EBAN-MATNR NE SPACE.
10     CHECK EBAN-WERKS NE SPACE.
11
12     *- Bestände schon gelesen ? -------------------------------------------*
13     MATKEY-MATNR = EBAN-MATNR.
14     MATKEY-WERKS = EBAN-WERKS.
15     READ TABLE MMDSA WITH KEY MATKEY BINARY SEARCH.
16     MINDEX = SY-TABIX.
17     MSUBRC = SY-SUBRC.
18
19     *- Bestände lesen -----------------------------------------------------*
20     IF MSUBRC NE 0 OR
21        MMDSA-RBSTD EQ SPACE.
22        REFRESH XMT61B.
23        CLEAR MTCOM.
24        MTCOM-KENNG = 'MT61B'.
25        MTCOM-MATNR = EBAN-MATNR.
26        MTCOM-WERKS = EBAN-WERKS.
27        CALL FUNCTION 'MATERIAL_READ'
28             EXPORTING
29                  SCHLUESSEL = MTCOM
30             IMPORTING
31                  MATDATEN = MT61B
32             TABLES
33                  SEQMAT01 = XMT61B.
34       LOOP AT XMT61B.
35          MMDSA-LABST = MMDSA-LABST + XMT61B-LABST.
36          MMDSA-EINME = MMDSA-EINME + XMT61B-EINME.
37          MMDSA-SPEME = MMDSA-SPEME + XMT61B-SPEME.
38     *    MMDSA-RETME = MMDSA-RETME + XMT61B-RETME.
39          MMDSA-KLABS = MMDSA-KLABS + XMT61B-KLABS.
40     *    MMDSA-KEINM = MMDSA-KEINM + XMT61B-KEINM.
41     *    MMDSA-KSPEM = MMDSA-KSPEM + XMT61B-KSPEM.
42          MMDSA-INSME = MMDSA-INSME + XMT61B-INSME.
43          MMDSA-KINSM = MMDSA-KINSM + XMT61B-KINSM.
44       ENDLOOP.
45       MMDSA-SUM01 = MMDSA-LABST + MMDSA-KLABS.
46       MMDSA-MATNR = EBAN-MATNR.
47       MMDSA-WERKS = EBAN-WERKS.
48       MMDSA-RBSTD = 'X'.
49       IF MSUBRC EQ 0.
50          MODIFY MMDSA INDEX MINDEX.
51       ELSE.
52          INSERT MMDSA INDEX MINDEX.
53       ENDIF.
54     ENDIF.
55     MOVE-CORRESPONDING MMDSA TO MDSTA.
56
57     ENDFORM.
*--- End of FM06BFDA_BAN_DATEN_005 - 57 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFDA_BAN_DATEN_006                    Level 2    Page 202
Object           SAPMZFM06B                                Lines 54
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      * offene Bestellungen
4      *----------------------------------------------------------------------*
5      FORM BAN_DATEN_006.
6
7      DATA: F1 TYPE F.
8      CLEAR MDSTA.
9      CLEAR MMDSA.
10     CHECK EBAN-MATNR NE SPACE.
11     CHECK EBAN-WERKS NE SPACE.
12
13     *- Bestellungen schon gelesen ?----------------------------------------*
14     MATKEY-MATNR = EBAN-MATNR.
15     MATKEY-WERKS = EBAN-WERKS.
16     READ TABLE MMDSA WITH KEY MATKEY BINARY SEARCH.
17     MINDEX = SY-TABIX.
18     MSUBRC = SY-SUBRC.
19
20     *- Bestellungen lesen -------------------------------------------------*
21     IF SY-SUBRC NE 0 OR
22        MMDSA-RBEST EQ SPACE.
23        REFRESH XMDBS.
24        SELECT * FROM MDBS APPENDING TABLE XMDBS
25                           WHERE MATNR EQ EBAN-MATNR
26                             AND WERKS EQ EBAN-WERKS
27                             AND LOEKZ EQ SPACE
28                             AND ELIKZ EQ SPACE
29                             AND KNTTP EQ SPACE
30                             AND ( BSTYP EQ 'F'
31                                 OR BSTYP EQ 'L' ).
32        LOOP AT XMDBS.
33           IF XMDBS-WEMNG LT XMDBS-MENGE.
34              F1 = XMDBS-MENGE - XMDBS-WEMNG.
35              F1 = F1 * XMDBS-UMREZ / XMDBS-UMREN.
36              IF XMDBS-SOBKZ EQ 'K'.
37                 MMDSA-BEBSK = MMDSA-BEBSK + F1.
38              ELSE.
39                 MMDSA-BEBST = MMDSA-BEBST + F1.
40              ENDIF.
41           ENDIF.
42        ENDLOOP.
43        MMDSA-MATNR = EBAN-MATNR.
44        MMDSA-WERKS = EBAN-WERKS.
45        MMDSA-RBEST = 'X'.
46        IF MSUBRC EQ 0.
47           MODIFY MMDSA INDEX MINDEX.
48        ELSE.
49           INSERT MMDSA INDEX MINDEX.
50        ENDIF.
51     ENDIF.
52     MOVE-CORRESPONDING MMDSA TO MDSTA.
53
54     ENDFORM.
*--- End of FM06BFDA_BAN_DATEN_006 - 54 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFDA_BAN_DATEN_007                    Level 2    Page 203
Object           SAPMZFM06B                                Lines 104
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      * Aktuelle Bestands/Bedarfs-Situation                                  *
4      *----------------------------------------------------------------------*
5      FORM BAN_DATEN_007.
6
7      CLEAR MMDSA.
8      CLEAR MDSTA.
9      CLEAR MDKP.
10     CHECK EBAN-MATNR NE SPACE.
11     CHECK EBAN-WERKS NE SPACE.
12
13     *- Schon gelesen ? ----------------------------------------------------*
14     MATKEY-MATNR = EBAN-MATNR.
15     MATKEY-WERKS = EBAN-WERKS.
16     READ TABLE MMDSA WITH KEY MATKEY BINARY SEARCH.
17     MINDEX = SY-TABIX.
18     MSUBRC = SY-SUBRC.
19
20     *- Bestands-/Bedarfssituation ermitteln -------------------------------*
21     IF SY-SUBRC NE 0 OR
22        MMDSA-RBEDA EQ SPACE.
23     *- Materialstamm lesen ------------------------------------------------*
24        PERFORM BAN_DATEN_001.
25     *- Parameter setzen ---------------------------------------------------*
26        CLEAR CM61X.
27        CM61X-PLOBJ = 'B'.
28        CM61X-PLAUF = 'B4'.
29        CM61X-PLAKT = 'A'.
30        CM61X-DISPD = SY-DATLO.
31
32        CALL FUNCTION 'MD_READ_PLANT'
33             EXPORTING  EWERKS = EBAN-WERKS
34             IMPORTING  ICM61W = CM61W
35                        IT399D = T399D
36             EXCEPTIONS ERROR  = 01.
37       IF SY-SUBRC > 0.
38         MESSAGE ID SY-MSGID TYPE 'A' NUMBER SY-MSGNO
39                 WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
40       ENDIF.
41
42     *- Bestands-/Bedarfszeilen aufbauen -----------------------------------*
43        CALL FUNCTION 'AUFBAUEN_MDPSX_ANZEIGEN'
44             EXPORTING
45                  ECM61W = CM61W
46                  ECM61X = CM61X
47                  EMT61D = MT61D
48                  ET399D = T399D
49             IMPORTING
50                  ICM61M = CM61M
51                  IMDSTA = MDSTA
52             TABLES
53                  MDPSX  = XMDPS
54             EXCEPTIONS
55                  ERROR  = 01.
56        IF SY-SUBRC EQ 0.
57           MOVE : MDSTA-LABST TO *MDSTA-LABST,
58                  MDSTA-EINME TO *MDSTA-EINME,
59                  MDSTA-SPEME TO *MDSTA-SPEME,
60                  MDSTA-RETME TO *MDSTA-RETME,
61                  MDSTA-KLABS TO *MDSTA-KLABS,
62                  MDSTA-KEINM TO *MDSTA-KEINM,
63                  MDSTA-KSPEM TO *MDSTA-KSPEM,
64                  MDSTA-INSME TO *MDSTA-INSME,
65                  MDSTA-KINSM TO *MDSTA-KINSM.
66     *- Bestands-/Bedarfszeilen kumulieren ---------------------------------*
67           CALL FUNCTION 'MDSTA_AUFBAUEN'
68                EXPORTING
69                     EMDSTA = MDSTA
70                     EINITF = 'X'
71                IMPORTING
72                     IMDSTA = MDSTA
73                TABLES
74                     MDPSX  = XMDPS.
75           MOVE : *MDSTA-LABST TO MDSTA-LABST,
76                  *MDSTA-EINME TO MDSTA-EINME,
77                  *MDSTA-SPEME TO MDSTA-SPEME,
78                  *MDSTA-RETME TO MDSTA-RETME,
79                  *MDSTA-KLABS TO MDSTA-KLABS,
80                  *MDSTA-KEINM TO MDSTA-KEINM,
81                  *MDSTA-KSPEM TO MDSTA-KSPEM,
82                  *MDSTA-INSME TO MDSTA-INSME,
83                  *MDSTA-KINSM TO MDSTA-KINSM.
84           MDSTA-SUM01 = MDSTA-LABST + MDSTA-KLABS.
85        ENDIF.
86     *- Bestands-/Bedarfssituation merken ----------------------------------*
87        MMDSA-MATNR = EBAN-MATNR.
88        MMDSA-WERKS = EBAN-WERKS.
89        MOVE-CORRESPONDING MDSTA TO MMDSA.
90        MMDSA-DSDAT = SY-DATLO.
91        MMDSA-RBEST = 'X'.
92        MMDSA-RBSTD = 'X'.
93        MMDSA-RBEDA = 'X'.
94        MMDSA-RDISP = SPACE.
95        IF MSUBRC EQ 0.
96           MODIFY MMDSA INDEX MINDEX.
97        ELSE.
98           INSERT MMDSA INDEX MINDEX.
99        ENDIF.
100    ENDIF.
101    MOVE-CORRESPONDING MMDSA TO MDSTA.
102    MDKP-DSDAT = MMDSA-DSDAT.
103
104    ENDFORM.
*--- End of FM06BFDA_BAN_DATEN_007 - 104 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFDA_BAN_DATEN_008                    Level 2    Page 204
Object           SAPMZFM06B                                Lines 96
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      * Bestands-/Bedarfs-Situation aus Dispoliste                           *
4      *----------------------------------------------------------------------*
5      FORM ban_daten_008.
6
7        CLEAR mmdsa.
8        CLEAR mdsta.
9        CLEAR mdkp.
10       CHECK eban-matnr NE space.
11       CHECK eban-werks NE space.
12
13     *- schon gelesen ? ----------------------------------------------------*
14       matkey-matnr = eban-matnr.
15       matkey-werks = eban-werks.
16       READ TABLE mmdsa WITH KEY matkey BINARY SEARCH.
17       mindex = sy-tabix.
18       msubrc = sy-subrc.
19     *- Bestands-/Bedarfssituation ermitteln -------------------------------*
20       IF msubrc NE 0 OR
21          mmdsa-rdisp EQ space.
22         IF mmdsa-rbeda EQ space.
23     *- Bestände retten ----------------------------------------------------*
24           MOVE-CORRESPONDING mmdsa TO mdsta.
25           MOVE : mdsta-labst TO *mdsta-labst,
26                  mdsta-einme TO *mdsta-einme,
27                  mdsta-speme TO *mdsta-speme,
28                  mdsta-retme TO *mdsta-retme,
29                  mdsta-klabs TO *mdsta-klabs,
30                  mdsta-keinm TO *mdsta-keinm,
31                  mdsta-kspem TO *mdsta-kspem,
32                  mdsta-insme TO *mdsta-insme,
33                  mdsta-kinsm TO *mdsta-kinsm,
34                  mdsta-sum01 TO *mdsta-sum01,
35                  mdsta-bebst TO *mdsta-bebst,
36                  mdsta-bebsk TO *mdsta-bebsk.
37     *- Materialstamm lesen ------------------------------------------------*
38           PERFORM ban_daten_001.
39
40     *- Dispoliste lesen ---------------------------------------------------*
41           SELECT SINGLE * FROM mdkp WHERE dtart = 'MD'
42                                       AND matnr = eban-matnr
43                                       AND plwrk = eban-werks
44                                       AND plscn = '000'.
45           IF sy-subrc EQ 0.
46             CALL FUNCTION 'DISPOBELEG_LESEN'
47               EXPORTING
48                 dtnum = mdkp-dtnum
49                 cflag = mdkp-cflag
50                 mandt = sy-mandt
51               TABLES
52                 mdpsx = xmdps.
53             IF sy-subrc EQ 0.                                   "#EC *
54     *- Bestands-/Bedarfszeilen kumulieren ---------------------------------*
55               CALL FUNCTION 'MDSTA_AUFBAUEN'
56                 EXPORTING
57                   emdsta = mdsta
58                   einitf = 'X'
59                 IMPORTING
60                   imdsta = mdsta
61                 TABLES
62                   mdpsx  = xmdps.
63             ENDIF.
64           ENDIF.
65     *- Bestände rückladen -------------------------------------------------*
66           MOVE : *mdsta-labst TO mdsta-labst,
67                  *mdsta-einme TO mdsta-einme,
68                  *mdsta-speme TO mdsta-speme,
69                  *mdsta-retme TO mdsta-retme,
70                  *mdsta-klabs TO mdsta-klabs,
71                  *mdsta-keinm TO mdsta-keinm,
72                  *mdsta-kspem TO mdsta-kspem,
73                  *mdsta-insme TO mdsta-insme,
74                  *mdsta-kinsm TO mdsta-kinsm.
75           mdsta-sum01 = mdsta-labst + mdsta-klabs.
76           IF mmdsa-rbest NE space.
77             MOVE : *mdsta-bebst TO mdsta-bebst,
78                    *mdsta-bebsk TO mdsta-bebsk.
79           ENDIF.
80     *- Dispoliste merken --------------------------------------------------*
81           mmdsa-matnr = eban-matnr.
82           mmdsa-werks = eban-werks.
83           MOVE-CORRESPONDING mdsta TO mmdsa.
84           mmdsa-dsdat = mdkp-dsdat.
85           mmdsa-rdisp = 'X'.
86           IF msubrc EQ 0.
87             MODIFY mmdsa INDEX mindex.
88           ELSE.
89             INSERT mmdsa INDEX mindex.
90           ENDIF.
91         ENDIF.
92       ENDIF.
93       MOVE-CORRESPONDING mmdsa TO mdsta.
94       mdkp-dsdat = mmdsa-dsdat.
95
96     ENDFORM.                    "BAN_DATEN_008
*--- End of FM06BFDA_BAN_DATEN_008 - 96 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFDA_BAN_DATEN_009                    Level 2    Page 205
Object           SAPMZFM06B                                Lines 139
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      * Prognosedaten                                                        *
4      *----------------------------------------------------------------------*
5      FORM BAN_DATEN_009.
6
7      DATA ZINDEX.
8      DATA STARTD LIKE SY-DATUM.
9      DATA STARTW LIKE SCAL-WEEK.
10     CLEAR ZINDEX.
11     CLEAR PINDEX.
12     CHECK EBAN-MATNR NE SPACE.
13     CHECK EBAN-WERKS NE SPACE.
14
15     *- Prognose schon gelesen ? -------------------------------------------*
16     MATKEY-MATNR = EBAN-MATNR.
17     MATKEY-WERKS = EBAN-WERKS.
18     READ TABLE MPROG WITH KEY MATKEY BINARY SEARCH.
19     MINDEX = SY-TABIX.
20     PINDEX = SY-TABIX.
21     IF SY-SUBRC NE 0.
22     *- Materialstamm nachlesen --------------------------------------------*
23        PERFORM BAN_DATEN_001.
24
25     *- Prognosedaten lesen ------------------------------------------------*
26        MAPRF-MATNR = EBAN-MATNR.
27        MAPRF-WERKS = EBAN-WERKS.
28        MAPRF-PERKZ = MT61D-PERKZ.
29        MAPRF-PERIV = MT61D-PERIV.
30        REFRESH XPROWF.
31        CALL FUNCTION 'LESEN_PROGNOSE'
32             EXPORTING
33                  IMAPRF = MAPRF
34             IMPORTING
35                  EPROPF = PROPF
36             TABLES
37                  TPROWF = XPROWF
38             EXCEPTIONS
39                  OTHERS = 01.
40     *- Startdatum für Prognose bestimmen ----------------------------------*
41        CASE MT61D-PERKZ.
42           WHEN 'P'.
43           IF NOT XPROWF IS INITIAL.                        "426379
44             CALL FUNCTION 'PROGNOSEPERIODEN_ERMITTELN'
45                  EXPORTING
46                       EANZPR = 1
47                       EDATUM = XPROWF-ERTAG
48                       EPERIV = MT61D-PERIV
49                  TABLES
50                       PPERX = XPPER.
51             READ TABLE XPPER INDEX 1.
52             STARTD = XPPER-VONTG.
53           ENDIF.                                           "426379
54          WHEN 'M'.
55             STARTD = SY-DATLO.
56             STARTD+6(2) = '01'.
57          WHEN 'W'.
58             CALL FUNCTION 'DATE_GET_WEEK'
59                  EXPORTING
60                       DATE = SY-DATLO
61                  IMPORTING
62                       WEEK = STARTW
63                  EXCEPTIONS
64                       DATE_INVALID = 01.
65             CALL FUNCTION 'WEEK_GET_FIRST_DAY'
66                  EXPORTING
67                       WEEK = STARTW
68                  IMPORTING
69                       DATE = STARTD
70                  EXCEPTIONS
71                       WEEK_INVALID = 01.
72          WHEN 'T'.
73             STARTD = SY-DATLO.
74        ENDCASE.
75     *- Prognosedaten aufbereiten ------------------------------------------*
76        LOOP AT XPROWF.
77           IF XPROWF-ERTAG GE STARTD.
78              CLEAR MPROG.
79              MPROG-MATNR = EBAN-MATNR.
80              MPROG-WERKS = EBAN-WERKS.
81              MOVE-CORRESPONDING XPROWF TO MPROG.
82              CASE MT61D-PERKZ.
83                 WHEN 'P'.
84                   CALL FUNCTION 'PROGNOSEPERIODEN_ERMITTELN'
85                        EXPORTING
86                             EANZPR = 1
87                             EDATUM = XPROWF-ERTAG
88                             EPERIV = MT61D-PERIV
89                        TABLES
90                             PPERX = XPPER.
91                   READ TABLE XPPER INDEX 1.
92                   MOVE XPPER-PRPER+4(2)  TO MPROG-PRIOD.
93                   MOVE '/'               TO MPROG-PRIOD+2.
94                   MOVE XPPER-PRPER(4)    TO MPROG-PRIOD+3.
95                WHEN 'M'.
96                   CALL FUNCTION 'DATUMSAUFBEREITUNG'
97                        EXPORTING
98                             FLAGM = 'X'
99                             IDATE = XPROWF-ERTAG
100                       IMPORTING
101                            MDAT6 = MPROG-PRIOD
102                       EXCEPTIONS
103                            OTHERS = 01.
104               WHEN 'W'.
105                  CALL FUNCTION 'DATUMSAUFBEREITUNG'
106                       EXPORTING
107                            FLAGW = 'X'
108                            IDATE = XPROWF-ERTAG
109                       IMPORTING
110                            WDAT6 = MPROG-PRIOD
111                       EXCEPTIONS
112                            OTHERS = 01.
113               WHEN 'T'.
114                  CALL FUNCTION 'DATUMSAUFBEREITUNG'
115                       EXPORTING
116                            IDATE = XPROWF-ERTAG
117                       IMPORTING
118                            TDAT8 = MPROG-PRIOD
119                       EXCEPTIONS
120                            OTHERS = 01.
121             ENDCASE.
122             INSERT MPROG INDEX MINDEX.
123             MINDEX = MINDEX + 1.
124             ZINDEX = ZINDEX + 1.
125             IF ZINDEX GE 3.
126                EXIT.
127             ENDIF.
128          ENDIF.
129       ENDLOOP.
130    *- Leerer Satz, keine Prognose vorhanden ------------------------------*
131       IF ZINDEX EQ 0.
132          CLEAR MPROG.
133          MPROG-MATNR = EBAN-MATNR.
134          MPROG-WERKS = EBAN-WERKS.
135          INSERT MPROG INDEX MINDEX.
136       ENDIF.
137    ENDIF.
138
139    ENDFORM.
*--- End of FM06BFDA_BAN_DATEN_009 - 139 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFDA_BAN_DATEN_004_ANZEIGE            Level 2    Page 206
Object           SAPMZFM06B                                Lines 22
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      * Verbräuche anzeigen
4      *----------------------------------------------------------------------*
5      FORM BAN_DATEN_004_ANZEIGEN.
6
7      IF VINDEX EQ 0.
8         EXIT FROM STEP-LOOP.
9      ENDIF.
10     READ TABLE MVERB INDEX VINDEX.
11        IF SY-SUBRC NE 0 OR
12           MVERB-MATNR NE EBAN-MATNR OR
13           MVERB-WERKS NE EBAN-WERKS OR
14           MVERB-PRIOD EQ SPACE.
15           CLEAR IVERB.
16           EXIT FROM STEP-LOOP.
17        ELSE.
18           MOVE-CORRESPONDING MVERB TO IVERB.
19           MOVE MT61D-PERKZ TO MAPRF-PERKZ.
20           VINDEX = VINDEX + 1.
21        ENDIF.
22     ENDFORM.
*--- End of FM06BFDA_BAN_DATEN_004_ANZEIGE - 22 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFDA_BAN_DATEN_009_ANZEIGE            Level 2    Page 207
Object           SAPMZFM06B                                Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      * Prognosedaten anzeigen
4      *----------------------------------------------------------------------*
5      FORM BAN_DATEN_009_ANZEIGEN.
6
7      IF PINDEX EQ 0.
8         EXIT FROM STEP-LOOP.
9      ENDIF.
10     READ TABLE MPROG INDEX PINDEX.
11        IF SY-SUBRC NE 0 OR
12           MPROG-MATNR NE EBAN-MATNR OR
13           MPROG-WERKS NE EBAN-WERKS OR
14           MPROG-PRIOD EQ SPACE.
15           CLEAR MPROG.
16           EXIT FROM STEP-LOOP.
17        ELSE.
18           MOVE-CORRESPONDING MPROG TO PROWF.
19           MOVE MPROG-PRIOD TO *IVERB-PRIOD.
20           MOVE MT61D-PERKZ TO *MAPRF-PERKZ.
21           PINDEX = PINDEX + 1.
22        ENDIF.
23     ENDFORM.
*--- End of FM06BFDA_BAN_DATEN_009_ANZEIGE - 23 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFDZ                                  Level 1    Page 208
Object           SAPMZFM06B                                Lines 3
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1        INCLUDE FM06BFDZ_BAN_DATEN_PR1_900 .  " BAN_DATEN_PR1_900
2        INCLUDE FM06BFDZ_BAN_DATEN_PR2_900 .  " BAN_DATEN_PR2_900
3        INCLUDE FM06BFDZ_BAN_DATEN_900 .  " BAN_DATEN_900
*--- End of FM06BFDZ - 3 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFDZ_BAN_DATEN_PR1_900                Level 2    Page 209
Object           SAPMZFM06B                                Lines 8
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      ***INCLUDE FM06BFDZ.
2      * INCLUDE für Kundenspezifische Routinen
3      *eject
4      *----------------------------------------------------------------------*
5      * ??? lesen - Prefetch vorbereiten - Beispiel
6      *----------------------------------------------------------------------*
7      FORM BAN_DATEN_PR1_900.
8      ENDFORM.
*--- End of FM06BFDZ_BAN_DATEN_PR1_900 - 8 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFDZ_BAN_DATEN_PR2_900                Level 2    Page 210
Object           SAPMZFM06B                                Lines 6
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      * ??? lesen - Prefetch durchführen - Beispiel
4      *----------------------------------------------------------------------*
5      FORM BAN_DATEN_PR2_900.
6      ENDFORM.
*--- End of FM06BFDZ_BAN_DATEN_PR2_900 - 6 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFDZ_BAN_DATEN_900                    Level 2    Page 211
Object           SAPMZFM06B                                Lines 6
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      * ??? lesen
4      *----------------------------------------------------------------------*
5      FORM BAN_DATEN_900.
6      ENDFORM.
*--- End of FM06BFDZ_BAN_DATEN_900 - 6 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFSL                                  Level 1    Page 212
Object           SAPMZFM06B                                Lines 30
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      ***INCLUDE FM06BFSL.
2
3      * Hinw. Datum    Rel. NN  Text
4      * 88504 25.11.97 4.0B KB: erledigte RV-Banfen
5
6      *----------------------------------------------------------------------*
7      *        Allgemeine Select-Options und Parameter                       *
8      *----------------------------------------------------------------------*
9      INCLUDE FM06BCS1.
10     INCLUDE FM06BCS2.
11
12       INCLUDE FM06BFSL_AENDANZ_PRUEFEN .  " AENDANZ_PRUEFEN
13
14       INCLUDE FM06BFSL_BAN_AUFBAUEN .  " BAN_AUFBAUEN
15
16
17       INCLUDE FM06BFSL_KONTIERUNG .  " KONTIERUNG
18
19       INCLUDE FM06BFSL_CHECK_PARA1 .  " CHECK_PARA1
20
21       INCLUDE FM06BFSL_CHECK_PARA2 .  " CHECK_PARA2
22       INCLUDE FM06BFSL_ANZAHL_POS_BAN .  " ANZAHL_POS_BAN
23       INCLUDE FM06BFSL_MATERIALNUMMER_SETZEN .  " MATERIALNUMMER_SETZEN
24       INCLUDE FM06BFSL_CHECK_PARA3 .  " CHECK_PARA3
25       INCLUDE FM06BFSL_BAN_ARCHIVE_DATE_SET .  " BAN_ARCHIVE_DATE_SET
26
27       INCLUDE FM06BFSL_MODIFY_DYNFIE .
28       INCLUDE FM06BFSL_LDB_BAM .
29       INCLUDE FM06BFSL_VENDOR_ARRAY_READ .  "VENDOR_ARRAY_READ
30       INCLUDE FM06BFSL_OPT_AUT_BAN_XML.    "Export BAN in XML form to memory
*--- End of FM06BFSL - 30 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BCS1                                  Level 2    Page 213
Object           SAPMZFM06B                                Lines 42
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      ************************************************************************
2      *        Common-Part Listanzeigen Bestellanforderungen  Teil 1         *
3      ************************************************************************
4
5      DATA: BEGIN OF COMMON PART FM06BCS1.
6
7      *----------------------------------------------------------------------*
8      *        Parameters                                                    *
9      *----------------------------------------------------------------------*
10     PARAMETERS:
11        P_LSTUB LIKE T16LL-LSTUB DEFAULT 'A'. "Listumfang
12     *----------------------------------------------------------------------*
13     *        Select-Options                                                *
14     *----------------------------------------------------------------------*
15     SELECT-OPTIONS:
16        S_WERKS FOR EBAN-WERKS MEMORY ID WRK,                 "Werk
17        S_BSART FOR EBAN-BSART,                      "Bestellart
18        S_PSTYP FOR RM06B-EPSTP,                     "Positionstyp
19        S_KNTTP FOR EBAN-KNTTP,                      "Kontierungstyp
20        S_LFDAT FOR EBAN-LFDAT,                      "Lieferdatum
21        S_FRGDT FOR EBAN-FRGDT,                      "Freigabedatum
22        S_DISPO FOR EBAN-DISPO,                      "Disponent
23        S_STATU FOR EBAN-STATU,                      "Bearbeitungsstatus
24        S_FLIEF FOR EBAN-FLIEF MATCHCODE OBJECT KRED,
25
26        S_BESWK FOR EBAN-beswk MEMORY ID besw,       "CCP Besch. Werk
27        s_banpr for eban-banpr,                      "DCM Bearb.zustand
28        s_blckd for eban-blckd.                      "DCM Sperr-Kz
29     *
30
31     *----------------------------------------------------------------------*
32     *        Parameters                                                    *
33     *----------------------------------------------------------------------*
34     PARAMETERS:
35        P_AFNAM LIKE EBAN-AFNAM,            "Anforderer
36        P_TXZ01 LIKE EBAN-TXZ01,            "Kurztext
37        P_SRTKZ LIKE RM06A-P_SORTKZ DEFAULT '1'.      "Sortierkennzeichen
38
39     *- für Positionstyp im internen Format --------------------------------*
40     RANGES: R_PSTYP FOR EBAN-PSTYP.
41
42     DATA: END OF COMMON PART FM06BCS1.
*--- End of FM06BCS1 - 42 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BCS2                                  Level 2    Page 214
Object           SAPMZFM06B                                Lines 19
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      ************************************************************************
2      *        Common-Part Listanzeigen Bestellanforderungen  Teil 1         *
3      ************************************************************************
4
5      DATA: BEGIN OF COMMON PART FM06BCS2.
6
7      *----------------------------------------------------------------------*
8      *        Parameters                                                    *
9      *----------------------------------------------------------------------*
10     PARAMETERS:
11        P_ZUGBA LIKE RM06A-P_ZUGEORDN DEFAULT 'X',
12        P_MEMORY LIKE RM06A-P_MEMORY DEFAULT 'X',                "1781942
13        P_ERLBA LIKE RM06A-P_ERLEDIGT,
14        P_BSTBA LIKE RM06A-P_TEILBEST DEFAULT 'X',
15        P_FREIG LIKE RM06A-P_FREIGABE DEFAULT ' ',
16        P_SELGS LIKE RM06A-P_SELGS DEFAULT 'X',
17        P_SELPO LIKE RM06A-P_SELPO DEFAULT 'X'.
18
19     DATA: END OF COMMON PART FM06BCS2.
*--- End of FM06BCS2 - 19 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFSL_AENDANZ_PRUEFEN                  Level 2    Page 215
Object           SAPMZFM06B                                Lines 72
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *        Berechtigung Anzeigen Änderungen prüfen                       *
4      *----------------------------------------------------------------------*
5      FORM aendanz_pruefen.
6      * define local data object
7        DATA: lo_auth       TYPE REF TO cl_auth_buf_mm,
8              lf_ccp_active TYPE c.
9        aendanz = 'X'.
10
11       lo_auth = cl_auth_buf_mm=>get_instance( ).
12     *- Belegart -----------------------------------------------------------*
13       IF lo_auth->execute( im_object = mmpur_auth_banf_bsa
14                            im_actvt  = '08'
15                            im_id1    = mmpur_bsart
16                            im_val1   = eban-bsart ) NE 0.
17         CLEAR aendanz.
18         EXIT.
19       ENDIF.
20
21     *- Einkaufsorganisation -----------------------------------------------*
22       IF eban-ekorg NE space.
23         IF lo_auth->execute( im_object = mmpur_auth_banf_eko
24                              im_actvt  = '08'
25                              im_id1    = mmpur_ekorg
26                              im_val1   = eban-ekorg ) NE 0.
27           CLEAR aendanz.
28           EXIT.
29         ENDIF.
30       ENDIF.
31
32     *- Einkäufergruppe ----------------------------------------------------*
33       IF eban-ekgrp NE space.
34         IF lo_auth->execute( im_object = mmpur_auth_banf_ekg
35                              im_actvt  = '08'
36                              im_id1    = mmpur_ekgrp
37                              im_val1   = eban-ekgrp ) NE 0.
38           CLEAR aendanz.
39           EXIT.
40         ENDIF.
41       ENDIF.
42
43     *- WERK ---------------------------------------------------------------*
44       IF eban-werks NE space.
45         IF lo_auth->execute( im_object = mmpur_auth_banf_wrk
46                              im_actvt  = '08'
47                              im_id1    = 'WERKS'
48                              im_val1   = eban-werks ) NE 0.
49           CLEAR aendanz.
50           EXIT.
51         ENDIF.
52       ENDIF.
53
54     * Begin CCP
55     *- Beschaffendes Werk -------------------------------------------------*
56       CLEAR lf_ccp_active.
57       CALL FUNCTION 'ME_CCP_ACTIVE_CHECK'
58         IMPORTING
59           ef_ccp_active = lf_ccp_active.
60
61       IF eban-beswk IS NOT INITIAL AND lf_ccp_active IS NOT INITIAL.
62         IF lo_auth->execute( im_object = mmpur_auth_banf_bwk
63                              im_actvt  = '08'
64                              im_id1    = mmpur_beswk
65                              im_val1   = eban-beswk ) NE 0.
66           CLEAR aendanz.
67           EXIT.
68         ENDIF.
69       ENDIF.
70     * End CCP
71
72     ENDFORM.                    "AENDANZ_PRUEFEN
*--- End of FM06BFSL_AENDANZ_PRUEFEN - 72 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFSL_BAN_AUFBAUEN                     Level 2    Page 216
Object           SAPMZFM06B                                Lines 102
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *        Auswertung Banf-Selektion                                     *
4      *----------------------------------------------------------------------*
5      FORM ban_aufbauen.
6
7        PERFORM ban_aufbauen_mit_eban_tech USING 'X'.
8
9      ENDFORM.                    "BAN_AUFBAUEN
10
11
12     *----------------------------------------------------------------------*
13     *        Auswertung Banf-Selektion unter Berücksichtigung              *
14     *        der Tabelle EBAN_TECH                                         *
15     *----------------------------------------------------------------------*
16     * -->    P_CHECK_EBAN_TECH : Ist die Prüfung der Tabelle               *
17     *                            EBAN_TECH nötig?                          *
18     *                            'X' = Ja, ' ' = Nein                      *
19     *----------------------------------------------------------------------*
20     FORM ban_aufbauen_mit_eban_tech USING p_check_eban_tech TYPE xfeld.
21       DATA: lt_eban_tech TYPE eban_t_tech,
22             ls_eban_tech LIKE LINE OF lt_eban_tech.
23
24       IF NOT gs_banf IS INITIAL AND NOT eban-gsfrg IS INITIAL.
25         ON CHANGE OF eban-banfn.
26     *... Anzahl selektierter Positionen pro Banf ermitteln ...............*
27           LOOP AT ban WHERE banfn EQ save_banf
28                       AND   gsfrg NE space.
29             ban-sl_pos = sl_pos.
30             MODIFY ban.
31           ENDLOOP.
32           CLEAR sl_pos.
33           save_banf = eban-banfn.
34         ENDON.
35         sl_pos = sl_pos + 1.
36       ENDIF.
37
38       PERFORM aendanz_pruefen.
39       CLEAR ban.
40       ban-aenda = aendanz.
41       ban-selkf = flag_selk.
42       MOVE-CORRESPONDING eban TO ban.
43       PERFORM bukrs_umlag.
44       IF eban-flief NE space.
45         IF ban-bkuml NE space OR
46            ban-reswk EQ space.
47           ban-slief = ban-flief.
48         ENDIF.
49       ENDIF.
50       IF eban-flief NE space OR
51          eban-beswk NE space OR " CCP
52          eban-reswk NE space.
53         ban-updk1 = zold.
54       ENDIF.
55
56       ban-arch_date = archive_date.          "TK 4.0B EURO
57
58       PERFORM kontierung.
59
60     *--------------------------------------------------------------------*
61     * check for external sourcing status                         1620625
62     *--------------------------------------------------------------------*
63       IF cl_ops_switch_check=>mm_sfws_p2pse( ) IS NOT INITIAL.
64         IF p_check_eban_tech EQ abap_true.
65           CLEAR lt_eban_tech.
66           lt_eban_tech = cl_mmpur_mereq_db_utility=>get_eban_tech(
67                                               im_banfn = eban-banfn ).
68           CLEAR ls_eban_tech.
69           READ TABLE lt_eban_tech  WITH KEY   bnfpo = eban-bnfpo
70                                               banfn = eban-banfn
71                                               INTO ls_eban_tech.
72           IF ls_eban_tech-ext_proc_status CO '12' AND
73             cl_mmpur_bapi_po=>check_repid_loaded( 'RM06BF00' ) EQ abap_false.
74             RETURN.
75           ELSE.
76             APPEND ban.
77           ENDIF.
78         ELSE.
79           APPEND ban.
80         ENDIF.
81       ELSE.
82         APPEND ban.
83       ENDIF.
84
85     *- generic reporting: hook for eban -----------------------------------*
86       IF NOT gf_factory IS INITIAL.
87         gf_tab = gf_factory->lookup( 'EBAN' ).
88         MOVE-CORRESPONDING ban TO eban.
89         CALL METHOD gf_tab->insert_line( eban ).
90         IF eban-knttp NE space AND eban-kzvbr NE kzvbr-unbe.
91           IF ebkn-banfn EQ eban-banfn AND
92              ebkn-bnfpo EQ eban-bnfpo.
93             gf_tab = gf_factory->lookup( 'EBKN' ).
94             CALL METHOD gf_tab->insert_line( ebkn ).
95           ENDIF.
96         ENDIF.
97       ENDIF.
98
99     *------- no-record-found-Kennzeichen zurücksetzen ---------------------*
100      CLEAR not_found.
101
102    ENDFORM.                    "BAN_AUFBAUEN_MIT_EBAN_TECH
*--- End of FM06BFSL_BAN_AUFBAUEN - 102 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFSL_KONTIERUNG                       Level 2    Page 217
Object           SAPMZFM06B                                Lines 67
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *        Kontierungsfelder füllen                                      *
4      *----------------------------------------------------------------------*
5      FORM KONTIERUNG.
6
7      * CHECK COM-BKMKZ NE SPACE.
8        CLEAR: BAN-KONT1, BAN-KONT2, BAN-BKMKZ.
9        IF COM-BKMKZ EQ SPACE.
10         IF NOT EBKN-PS_PSP_PNR IS INITIAL.
11           BAN-BKMKZ = '2'.
12         ELSEIF NOT EBKN-NPLNR IS INITIAL AND
13         NOT EBKN-AUFPL IS INITIAL.                              "602972
14           BAN-BKMKZ = '6'.
15         ELSEIF NOT EBKN-NPLNR IS INITIAL.
16           BAN-BKMKZ = '8'.
17         ELSEIF NOT EBKN-AUFNR IS INITIAL.
18           BAN-BKMKZ = '3'.
19         ELSEIF NOT EBKN-ANLN1 IS INITIAL.
20           BAN-BKMKZ = '4'.
21         ELSEIF NOT EBKN-VBELN IS INITIAL.
22           BAN-BKMKZ = '5'.
23         ELSEIF NOT EBKN-KOSTL IS INITIAL.
24           BAN-BKMKZ = '1'.
25         ELSEIF NOT EBKN-IMKEY IS INITIAL.
26           BAN-BKMKZ = '7'.
27         ENDIF.
28       ELSE.
29         IF COM-BKMKZ = '6' AND EBKN-AUFPL IS INITIAL.           "602972
30           BAN-BKMKZ = '8'.
31         ELSE.
32           BAN-BKMKZ = COM-BKMKZ.
33         ENDIF.
34       ENDIF.
35       CHECK NOT BAN-BKMKZ IS INITIAL.
36
37       CASE BAN-BKMKZ.                                        "4.0C
38         WHEN '1'.
39           BAN-KONT1(10) = EBKN-KOSTL.
40         WHEN '2'.
41     *     BAN-KONT1(8) = EBKN-PS_PSP_PNR.                       "4.0C
42           WRITE EBKN-PS_PSP_PNR TO BAN-KONT1.                   "4.0C
43         WHEN '3'.
44           BAN-KONT1 = EBKN-AUFNR.
45         WHEN '4'.
46           BAN-KONT1 = EBKN-ANLN1.
47           BAN-KONT2(4) = EBKN-ANLN2.
48         WHEN '5'.
49           BAN-KONT1(10) = EBKN-VBELN.
50           BAN-KONT2(6) = EBKN-VBELP.
51         WHEN '6'.
52           BAN-KONT1(10) = EBKN-AUFPL.
53           BAN-KONT2 = EBKN-APLZL.
54         WHEN '7'.                                               "4.6A CF
55           READ TABLE T_IMKEYS WITH KEY IMKEY = EBKN-IMKEY.
56           IF SY-SUBRC EQ 0.
57             BAN-KONT1 = T_IMKEYS-OBJNR.
58           ENDIF.
59         WHEN '8'.                                               "602972
60           Write EBKN-NPLNR TO BAN-KONT1.
61       ENDCASE.
62
63       IF NOT EBKN-MENGE IS INITIAL.
64         BAN-MENGE = EBKN-MENGE.
65       ENDIF.
66
67     ENDFORM.
*--- End of FM06BFSL_KONTIERUNG - 67 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFSL_CHECK_PARA1                      Level 2    Page 218
Object           SAPMZFM06B                                Lines 34
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *        Pruefen Selektionsparameter                                   *
4      *----------------------------------------------------------------------*
5      FORM CHECK_PARA1.
6
7        REJECT = 'X'.
8      *------- Check Select-Options -----------------------------------------*
9        CHECK S_BSART.
10       check s_werks.                          "INSERT TK 4.6B
11       CHECK EBAN-PSTYP IN R_PSTYP.
12       CHECK S_KNTTP.
13       CHECK S_LFDAT.
14       CHECK S_FRGDT.
15       CHECK S_DISPO.
16       CHECK S_STATU.
17       CHECK S_FLIEF.
18
19     *------- Pruefen Kurztext ---------------------------------------------*
20       IF P_TXZ01 NE SPACE.
21         IF EBAN-TXZ01 NP P_TXZ01.
22           EXIT.
23         ENDIF.
24       ENDIF.
25
26     *------- Pruefen Anforderer -------------------------------------------*
27       IF P_AFNAM NE SPACE.
28         IF EBAN-AFNAM NP P_AFNAM.
29           EXIT.
30         ENDIF.
31       ENDIF.
32       CLEAR REJECT.
33
34     ENDFORM.
*--- End of FM06BFSL_CHECK_PARA1 - 34 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFSL_CHECK_PARA2                      Level 2    Page 219
Object           SAPMZFM06B                                Lines 69
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *eject
2      *----------------------------------------------------------------------*
3      *        Pruefen Zusatzparameter                                       *
4      *----------------------------------------------------------------------*
5      FORM CHECK_PARA2.
6
7        REJECT = 'X'.
8      *------- Check already assigned PReqs ---------------------------------*
9        IF P_ZUGBA IS INITIAL.
10         CHECK EBAN-ZUGBA IS INITIAL..
11         IF EBAN-FLIEF IS NOT INITIAL.
12           CHECK EBAN-EKORG IS INITIAL.
13         ENDIF.
14         IF EBAN-RESWK IS NOT INITIAL.
15           CHECK EBAN-EKORG IS INITIAL.
16         ENDIF.
17       ENDIF.
18
19     *------- CHECK parked/hold PReqs --------------------------------------*
20     * already filtered in me_read_eban_multiple                 "1981211
21
22     *------- Check open PReqs ---------------------------------------------*
23       IF P_ERLBA IS INITIAL.
24         CHECK EBAN-LOEKZ IS INITIAL.
25         CHECK EBAN-EBAKZ IS INITIAL.
26     *    CHECK eban-bsmng < eban-menge.                        "121920
27         IF eban-bsakz EQ 'R'.              "88504/KB
28           CHECK eban-statu NE 'K'.         "88504/KB
29           CHECK eban-statu NE 'L'.         "88504/KB
30         ELSE.
31           CHECK eban-bsmng LT eban-menge OR                     "121920
32           eban-pstyp EQ pstyp-wagr OR                           "121920
33           eban-pstyp EQ pstyp-enhl OR                           "Enhanced Limit Item
34           ( eban-menge EQ 0 AND p_memory IS NOT INITIAL ).      "2775443
35         ENDIF.                                                 "88504/KB
36       ENDIF.
37
38       IF P_MEMORY IS INITIAL.                                   "^2775443
39         CHECK eban-menge GT 0 OR
40         eban-pstyp EQ pstyp-enhl.                               " Enhanced Limit Item
41       ENDIF.                                                    "v2775443
42
43     *------- Check partly ordered PReqs -----------------------------------*
44       IF P_BSTBA IS INITIAL.
45         IF EBAN-LOEKZ IS INITIAL AND
46            EBAN-EBAKZ IS INITIAL AND
47            EBAN-BSMNG < EBAN-MENGE.
48           CHECK EBAN-BSMNG = 0.
49         ENDIF.
50       ENDIF.
51
52     *------- Check Release PReqs ------------------------------------------*
53       IF P_FREIG IS NOT INITIAL.
54         CHECK EBAN-FRGRL IS INITIAL.
55     * inclomplete PR´s (hold/park) should not be taken into account
56         CHECK EBAN-MEMORY IS INITIAL.                          "1449698
57       ENDIF.
58
59     *... Pruefen der Selektion von Bestellanforderungen zur Gesamtfreigabe
60     *... bzw. Bestellanforderungen zur Positionsfreigabe .................*
61       IF NOT P_SELGS IS INITIAL AND P_SELPO IS INITIAL.
62         CHECK NOT EBAN-GSFRG IS INITIAL.
63       ELSEIF P_SELGS IS INITIAL AND NOT P_SELPO IS INITIAL.
64         CHECK EBAN-GSFRG IS INITIAL.
65       ENDIF.
66
67       CLEAR REJECT.
68
69     ENDFORM.
*--- End of FM06BFSL_CHECK_PARA2 - 69 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFSL_ANZAHL_POS_BAN                   Level 2    Page 220
Object           SAPMZFM06B                                Lines 142
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&      Form  ANZAHL_POS_BAN
3      *&---------------------------------------------------------------------*
4      FORM anzahl_pos_ban.
5        TYPES: BEGIN OF ty_banfn_count,
6                banfn TYPE banfn,
7                count TYPE i,
8               END OF ty_banfn_count.
9
10       DATA:
11             lt_banfn          TYPE RANGE OF banfn,
12             ls_banfn          LIKE LINE OF lt_banfn,
13             lt_banfn_count    TYPE SORTED TABLE OF ty_banfn_count WITH UNIQUE KEY banfn,
14             lv_last_banfn     TYPE banfn,
15             lv_ban_counter    TYPE i,
16             lv_force_read     TYPE bool,
17             lv_sl_pos_modif   TYPE bool.
18
19       DATA:
20             ls_frgadd         TYPE merep_frgadd.
21       FIELD-SYMBOLS:
22             <fs_eban>         LIKE LINE OF ban,
23             <fs_banfn_count>  TYPE ty_banfn_count.
24
25
26       IF cl_mm_pur_aut_master=>get_old_db( ) EQ abap_true.
27
28         IF NOT gs_banf IS INITIAL AND NOT eban-gsfrg IS INITIAL.
29     *  ... Anzahl selektierter Positionen pro Banf ermitteln ...............*
30         LOOP AT ban WHERE banfn EQ save_banf
31                     AND   gsfrg NE space.
32
33           ban-sl_pos = sl_pos.
34           MODIFY ban.
35         ENDLOOP.
36         CLEAR sl_pos.
37       ENDIF.
38
39     *  - Anzahl Positionen pro Gesamtbanf ermitteln -------------------------*
40       DATA: count TYPE i.
41
42       LOOP AT ban.
43         IF ban-gsfrg NE space.
44           AT NEW banfn.                              "#EC CI_SORTED
45             SELECT COUNT( * ) INTO count FROM eban
46                    WHERE banfn = ban-banfn.
47           ENDAT.
48           ban-az_pos = count.
49           IF ban-az_pos NE ban-sl_pos AND gf_factory IS INITIAL.
50             CLEAR ban-selkf.
51           ENDIF.
52           MODIFY ban.
53         ENDIF.
54     *   generic reporting: hook for frgadd
55           IF NOT gf_factory IS INITIAL.
56             CLEAR ls_frgadd-blocked.                              "668940
57           gf_tab = gf_factory->lookup( 'FRGADD' ).
58           ls_frgadd-ebeln = ban-banfn.
59           ls_frgadd-ebelp = ban-bnfpo.
60           ls_frgadd-frgpo = ban-selkf.
61           IF ban-gsfrg NE space AND
62              ban-az_pos NE ban-sl_pos.
63               ls_frgadd-blocked = 'X'.
64             ENDIF.
65             CALL METHOD gf_tab->insert_line( ls_frgadd ).
66           ENDIF.
67         ENDLOOP.
68
69       ELSE.
70
71     *  *... Anzahl selektierter Positionen pro Banf ermitteln ...............*
72
73     *  - Anzahl Positionen pro Gesamtbanf ermitteln -------------------------*
74
75         IF NOT gs_banf IS INITIAL AND NOT eban-gsfrg IS INITIAL.
76           lv_sl_pos_modif = abap_true.
77         ELSE.
78           lv_sl_pos_modif = abap_false.
79         ENDIF.
80
81         CLEAR lv_last_banfn.
82         lv_force_read = abap_false.
83
84         LOOP AT ban ASSIGNING <fs_eban>.
85
86           AT LAST.
87             lv_force_read = abap_true.
88           ENDAT.
89
90           IF <fs_eban>-banfn NE lv_Last_banfn.
91             ls_banfn-low = <fs_eban>-banfn.
92             ls_banfn-option = 'EQ'.
93             ls_banfn-sign = 'I'.
94             APPEND ls_banfn TO lt_banfn.
95             lv_last_banfn = <fs_eban>-banfn.
96             ADD 1 TO lv_ban_counter.
97           ENDIF.
98
99           IF lv_ban_counter EQ 1000 OR lv_force_read EQ abap_true.
100            SELECT banfn COUNT( * ) APPENDING TABLE lt_banfn_count FROM eban WHERE banfn IN lt_banfn GROUP BY banfn.
101            CLEAR lt_banfn.
102            CLEAR lv_ban_counter.
103          ENDIF.
104
105          IF lv_sl_pos_modif EQ abap_true.
106            IF <fs_eban>-banfn EQ save_banf AND <fs_eban>-gsfrg NE space.
107              <fs_eban>-sl_pos = sl_pos.
108            ENDIF.
109          ENDIF.
110
111        ENDLOOP.
112
113        IF lv_sl_pos_modif EQ abap_true.
114          CLEAR sl_pos.
115        ENDIF.
116
117        LOOP AT ban ASSIGNING <fs_eban>.
118          IF <fs_eban>-gsfrg NE space.
119            AT NEW banfn.                       "#EC CI_SORTED
120              READ TABLE lt_banfn_count ASSIGNING <fs_banfn_count> WITH TABLE KEY banfn = <fs_eban>-banfn.
121            ENDAT.
122            <fs_eban>-az_pos = <fs_banfn_count>-count.
123            IF <fs_eban>-az_pos NE <fs_eban>-sl_pos AND gf_factory IS INITIAL.
124              CLEAR <fs_eban>-selkf.
125            ENDIF.
126          ENDIF.
127    *   generic reporting: hook for frgadd
128          IF NOT gf_factory IS INITIAL.
129            CLEAR ls_frgadd-blocked.                              "668940
130            gf_tab = gf_factory->lookup( 'FRGADD' ).
131            ls_frgadd-ebeln = <fs_eban>-banfn.
132            ls_frgadd-ebelp = <fs_eban>-bnfpo.
133            ls_frgadd-frgpo = <fs_eban>-selkf.
134            IF <fs_eban>-gsfrg NE space AND
135               <fs_eban>-az_pos NE <fs_eban>-sl_pos.
136              ls_frgadd-blocked = 'X'.
137            ENDIF.
138            CALL METHOD gf_tab->insert_line( ls_frgadd ).
139          ENDIF.
140        ENDLOOP.
141      ENDIF.
142    ENDFORM.                               " ANZAHL_POS_BAN
*--- End of FM06BFSL_ANZAHL_POS_BAN - 142 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFSL_MATERIALNUMMER_SETZEN            Level 2    Page 221
Object           SAPMZFM06B                                Lines 38
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&      Form  MATERIALNUMMER_SETZEN
3      *&---------------------------------------------------------------------*
4      *       text
5      *----------------------------------------------------------------------*
6      *      -->P_BAN_MATNR  text                                            *
7      *      -->P_BAN_EMATN  text                                            *
8      *      -->P_BAN_MPROF  text                                            *
9      *      -->P_SEL_MATNR  text                                            *
10     *----------------------------------------------------------------------*
11     FORM MATERIALNUMMER_SETZEN USING    P_BAN_MATNR
12                                         P_BAN_EMATN
13                                         P_BAN_MPROF
14                                         P_SEL_MATNR.
15
16      IF P_BAN_MPROF IS INITIAL.
17     *.. keine mpn-abwicklung für dieses material aktiv ..................*
18        P_SEL_MATNR = P_BAN_MATNR.
19      ELSE.
20        CALL FUNCTION 'MB_READ_TMPPF'
21             EXPORTING
22                  PROFILE        = P_BAN_MPROF
23             IMPORTING
24                  MPN_PARAMETERS = TMPPF
25             EXCEPTIONS
26                  OTHERS         = 0.
27        IF TMPPF-MPINF IS INITIAL.
28          P_SEL_MATNR = P_BAN_MATNR.
29        ELSEIF NOT P_BAN_EMATN IS INITIAL.
30          P_SEL_MATNR = P_BAN_EMATN.
31        ELSE.
32     *.. alle mpn's zum internen Material ermitteln und die Infosätze ....*
33     *. bereitstellen ...................................................*
34          CLEAR P_SEL_MATNR.
35        ENDIF.
36      ENDIF.
37
38     ENDFORM.                    " MATERIALNUMMER_SETZEN
*--- End of FM06BFSL_MATERIALNUMMER_SETZEN - 38 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFSL_CHECK_PARA3                      Level 2    Page 222
Object           SAPMZFM06B                                Lines 19
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&      Form  CHECK_PARA3
3      *&---------------------------------------------------------------------*
4      FORM CHECK_PARA3.
5
6        REJECT = 'X'.
7
8      * check s_kostl.
9      * check s_psext.
10     * check s_aufnr.
11     * check s_anln1.
12     * check s_anln2.
13     * check s_nplnr.
14     * check s_vbeln.
15     * check s_vbelp.
16
17       CLEAR REJECT.
18
19     ENDFORM.
*--- End of FM06BFSL_CHECK_PARA3 - 19 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFSL_BAN_ARCHIVE_DATE_SET             Level 2    Page 223
Object           SAPMZFM06B                                Lines 5
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      FORM BAN_ARCHIVE_DATE_SET USING I_ARCHIVE_DATE LIKE SY-DATLO. "TK 4.0B
2
3      ARCHIVE_DATE = I_ARCHIVE_DATE.    "TK 4.0B EURO
4
5      ENDFORM.  "Tk 4.0B EURO
*--- End of FM06BFSL_BAN_ARCHIVE_DATE_SET - 5 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFSL_MODIFY_DYNFIE                    Level 2    Page 224
Object           SAPMZFM06B                                Lines 21
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1
2        INCLUDE FM06BFSL_MODIFY_DYNFIE_BASE . "MODIFY_DYNFIE
3        INCLUDE FM06BFSL_MODIFY_DYNFIE_ALV .  "FILL_ALV_SEL_FIELDS
4        INCLUDE FM06BFSL_MODIFY_DYNFIE_TECH.  "MODIFY_DYNFIE_ADD_FIELDS_TECH
5        INCLUDE FM06BFSL_MODIFY_DYNFIE_001 .  "MODIFY_DYNFIE_ADD_FIELDS_001
6        INCLUDE FM06BFSL_MODIFY_DYNFIE_002 .  "MODIFY_DYNFIE_ADD_FIELDS_002
7        INCLUDE FM06BFSL_MODIFY_DYNFIE_003 .  "MODIFY_DYNFIE_ADD_FIELDS_003
8        INCLUDE FM06BFSL_MODIFY_DYNFIE_004 .  "MODIFY_DYNFIE_ADD_FIELDS_004
9        INCLUDE FM06BFSL_MODIFY_DYNFIE_005 .  "MODIFY_DYNFIE_ADD_FIELDS_005
10       INCLUDE FM06BFSL_MODIFY_DYNFIE_006 .  "MODIFY_DYNFIE_ADD_FIELDS_006
11       INCLUDE FM06BFSL_MODIFY_DYNFIE_007 .  "MODIFY_DYNFIE_ADD_FIELDS_007
12       INCLUDE FM06BFSL_MODIFY_DYNFIE_008 .  "MODIFY_DYNFIE_ADD_FIELDS_008
13       INCLUDE FM06BFSL_MODIFY_DYNFIE_009 .  "MODIFY_DYNFIE_ADD_FIELDS_009
14       INCLUDE FM06BFSL_MODIFY_DYNFIE_010 .  "MODIFY_DYNFIE_ADD_FIELDS_010
15       INCLUDE FM06BFSL_MODIFY_DYNFIE_011 .  "MODIFY_DYNFIE_ADD_FIELDS_011
16       INCLUDE FM06BFSL_MODIFY_DYNFIE_012 .  "MODIFY_DYNFIE_ADD_FIELDS_012
17       INCLUDE FM06BFSL_MODIFY_DYNFIE_013 .  "MODIFY_DYNFIE_ADD_FIELDS_013
18       INCLUDE FM06BFSL_MODIFY_DYNFIE_014 .  "MODIFY_DYNFIE_ADD_FIELDS_014
19       INCLUDE FM06BFSL_MODIFY_DYNFIE_102 .  "MODIFY_DYNFIE_ADD_FIELDS_102
20       INCLUDE FM06BFSL_MODIFY_DYNFIE_201 .  "MODIFY_DYNFIE_ADD_FIELDS_201
21       INCLUDE FM06BFSL_MODIFY_DYNFIE_301 .  "MODIFY_DYNFIE_ADD_FIELDS_301
*--- End of FM06BFSL_MODIFY_DYNFIE - 21 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFSL_MODIFY_DYNFIE_BASE               Level 3    Page 225
Object           SAPMZFM06B                                Lines 70
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&      Form  MODIFY_DYNFIE
3      *&---------------------------------------------------------------------*
4      *       Build table of fields to be selected
5      *----------------------------------------------------------------------*
6      FORM modify_dynfie USING pv_lstub         TYPE lstub
7                      CHANGING ct_select_fields TYPE rsfs_fields.
8
9        DATA:
10         ls_sel_field     TYPE rsfs_struc,
11         ls_seltab_fields TYPE rsfs_tab_fields,
12         lo_tab_mngr      TYPE REF TO if_table_manager_mm,
13         lv_scope         TYPE char40,
14
15         lt_list_scope    TYPE STANDARD TABLE OF t16ll,
16         lv_form_name     TYPE form_name.
17
18       FIELD-SYMBOLS:
19         <ls_list_scope>    LIKE LINE OF lt_list_scope,
20         <ls_select_fields> LIKE ls_seltab_fields.
21
22       lv_scope =  pv_lstub.
23       CALL FUNCTION 'ME_REP_GET_TABLE_MANAGER'
24         EXPORTING
25           im_scope   = lv_scope
26         IMPORTING
27           ex_manager = lo_tab_mngr.
28
29       IF lo_tab_mngr IS NOT INITIAL.
30     * ==> ALV scope ==> maintain fields for
31         perform fill_alv_sel_fields CHANGING ls_seltab_fields-fields.
32
33       ELSE.
34     * ==> Normal list output ==> maintain fields for
35         SELECT llist FROM t16ll INTO CORRESPONDING FIELDS OF TABLE lt_list_scope
36           WHERE lstub EQ pv_lstub.
37
38         IF lt_list_scope IS INITIAL.
39           " No entries found, let's select all the fields to be sure
40           ls_sel_field-line = '*'.
41           INSERT ls_sel_field INTO TABLE ls_seltab_fields-fields.
42         ELSE.
43           " Add fields relevant for list processing...
44           PERFORM modify_dynfie_add_fields_tech
45             CHANGING ls_seltab_fields-fields.
46
47           " Add fields relevant for list display...
48           "  each form carries the fields used in BAN_ZEILEN_<xxx>
49           LOOP AT lt_list_scope ASSIGNING <ls_list_scope>.
50             CONCATENATE 'MODIFY_DYNFIE_ADD_FIELDS_' <ls_list_scope>-llist INTO lv_form_name.
51             PERFORM (lv_form_name) IN PROGRAM (sy-repid) IF FOUND
52               CHANGING ls_seltab_fields-fields.
53           ENDLOOP.
54         ENDIF.
55       ENDIF.
56
57       " Merge field list into dynamic field list...
58       ls_seltab_fields-tablename = 'EBAN'.
59       READ TABLE ct_select_fields ASSIGNING <ls_select_fields>
60         WITH KEY tablename = 'EBAN'.
61       IF sy-subrc IS NOT INITIAL.
62         INSERT INITIAL LINE INTO TABLE ct_select_fields ASSIGNING <ls_select_fields>.
63         <ls_select_fields>-tablename = 'EBAN'.
64       ENDIF.
65
66       INSERT LINES OF ls_seltab_fields-fields INTO TABLE <ls_select_fields>-fields.
67       SORT <ls_select_fields>-fields BY line ASCENDING.
68       DELETE ADJACENT DUPLICATES FROM <ls_select_fields>-fields COMPARING line.
69
70     ENDFORM.                    " MODIFY_DYNFIE
*--- End of FM06BFSL_MODIFY_DYNFIE_BASE - 70 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFSL_MODIFY_DYNFIE_ALV                Level 3    Page 226
Object           SAPMZFM06B                                Lines 327
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&      Form  FILL_ALV_SEL_FIELDS
3      *&---------------------------------------------------------------------*
4      *       fill fields for selection when ALV list scope
5      *----------------------------------------------------------------------*
6      *      CT_SEL_FIELDS_FIELDS  - fields to be selected
7      *----------------------------------------------------------------------*
8      FORM fill_alv_sel_fields CHANGING ct_sel_fields type rsfs_tab_fields-fields.
9
10       DATA:
11         ls_sel_field     TYPE RSFS_STRUC.
12
13       ls_sel_field-line = 'BANFN'.
14       INSERT ls_sel_field INTO TABLE ct_sel_fields.
15
16       ls_sel_field-line = 'BNFPO'.
17       INSERT ls_sel_field INTO TABLE ct_sel_fields.
18
19       ls_sel_field-line = 'AFNAM'.
20       INSERT ls_sel_field INTO TABLE ct_sel_fields.
21
22       ls_sel_field-line = 'AKTNR'.
23       INSERT ls_sel_field INTO TABLE ct_sel_fields.
24
25       ls_sel_field-line = 'ARSNR'.
26       INSERT ls_sel_field INTO TABLE ct_sel_fields.
27
28       ls_sel_field-line = 'ARSPS'.
29       INSERT ls_sel_field INTO TABLE ct_sel_fields.
30
31       ls_sel_field-line = 'ATTYP'.
32       INSERT ls_sel_field INTO TABLE ct_sel_fields.
33
34       ls_sel_field-line = 'BADAT'.
35       INSERT ls_sel_field INTO TABLE ct_sel_fields.
36
37       ls_sel_field-line = 'BANPR'.
38       INSERT ls_sel_field INTO TABLE ct_sel_fields.
39
40       ls_sel_field-line = 'BEDAT'.
41       INSERT ls_sel_field INTO TABLE ct_sel_fields.
42
43       ls_sel_field-line = 'BEDNR'.
44       INSERT ls_sel_field INTO TABLE ct_sel_fields.
45
46       ls_sel_field-line = 'BESWK'.
47       INSERT ls_sel_field INTO TABLE ct_sel_fields.
48
49       ls_sel_field-line = 'BLCKD'.
50       INSERT ls_sel_field INTO TABLE ct_sel_fields.
51
52       ls_sel_field-line = 'BLCKT'.
53       INSERT ls_sel_field INTO TABLE ct_sel_fields.
54
55       ls_sel_field-line = 'BMEIN'.
56       INSERT ls_sel_field INTO TABLE ct_sel_fields.
57
58       ls_sel_field-line = 'BSAKZ'.
59       INSERT ls_sel_field INTO TABLE ct_sel_fields.
60
61       ls_sel_field-line = 'BSART'.
62       INSERT ls_sel_field INTO TABLE ct_sel_fields.
63
64       ls_sel_field-line = 'BSMNG'.
65       INSERT ls_sel_field INTO TABLE ct_sel_fields.
66
67       ls_sel_field-line = 'BSTYP'.
68       INSERT ls_sel_field INTO TABLE ct_sel_fields.
69
70       ls_sel_field-line = 'BUDGET_PD'.
71       INSERT ls_sel_field INTO TABLE ct_sel_fields.
72
73       ls_sel_field-line = 'BUMNG'.
74       INSERT ls_sel_field INTO TABLE ct_sel_fields.
75
76       ls_sel_field-line = 'BWTAR'.
77       INSERT ls_sel_field INTO TABLE ct_sel_fields.
78
79       ls_sel_field-line = 'CHARG'.
80       INSERT ls_sel_field INTO TABLE ct_sel_fields.
81
82       INSERT ls_sel_field INTO TABLE ct_sel_fields.
83
84       ls_sel_field-line = 'DISPO'.
85       INSERT ls_sel_field INTO TABLE ct_sel_fields.
86
87       ls_sel_field-line = 'EBAKZ'.
88       INSERT ls_sel_field INTO TABLE ct_sel_fields.
89
90       ls_sel_field-line = 'EBELN'.
91       INSERT ls_sel_field INTO TABLE ct_sel_fields.
92
93       ls_sel_field-line = 'EBELP'.
94       INSERT ls_sel_field INTO TABLE ct_sel_fields.
95
96       ls_sel_field-line = 'EKGRP'.
97       INSERT ls_sel_field INTO TABLE ct_sel_fields.
98
99       ls_sel_field-line = 'EKORG'.
100      INSERT ls_sel_field INTO TABLE ct_sel_fields.
101
102      ls_sel_field-line = 'EMATN'.
103      INSERT ls_sel_field INTO TABLE ct_sel_fields.
104
105      ls_sel_field-line = 'EMLIF'.
106      INSERT ls_sel_field INTO TABLE ct_sel_fields.
107
108      ls_sel_field-line = 'EMNFR'.
109      INSERT ls_sel_field INTO TABLE ct_sel_fields.
110
111      ls_sel_field-line = 'EPROFILE'.
112      INSERT ls_sel_field INTO TABLE ct_sel_fields.
113
114      ls_sel_field-line = 'ERDAT'.
115      INSERT ls_sel_field INTO TABLE ct_sel_fields.
116
117      ls_sel_field-line = 'ERNAM'.
118      INSERT ls_sel_field INTO TABLE ct_sel_fields.
119
120      ls_sel_field-line = 'ESTKZ'.
121      INSERT ls_sel_field INTO TABLE ct_sel_fields.
122
123      ls_sel_field-line = 'FIPOS'.
124      INSERT ls_sel_field INTO TABLE ct_sel_fields.
125
126      ls_sel_field-line = 'FISTL'.
127      INSERT ls_sel_field INTO TABLE ct_sel_fields.
128
129      ls_sel_field-line = 'FIXKZ'.
130      INSERT ls_sel_field INTO TABLE ct_sel_fields.
131
132      ls_sel_field-line = 'FLIEF'.
133      INSERT ls_sel_field INTO TABLE ct_sel_fields.
134
135      ls_sel_field-line = 'FORDN'.
136      INSERT ls_sel_field INTO TABLE ct_sel_fields.
137
138      ls_sel_field-line = 'FORDP'.
139      INSERT ls_sel_field INTO TABLE ct_sel_fields.
140
141      ls_sel_field-line = 'FRGDT'.
142      INSERT ls_sel_field INTO TABLE ct_sel_fields.
143
144      ls_sel_field-line = 'FRGGR'.
145      INSERT ls_sel_field INTO TABLE ct_sel_fields.
146
147      ls_sel_field-line = 'FRGKZ'.
148      INSERT ls_sel_field INTO TABLE ct_sel_fields.
149
150      ls_sel_field-line = 'FRGRL'.
151      INSERT ls_sel_field INTO TABLE ct_sel_fields.
152
153      ls_sel_field-line = 'FRGST'.
154      INSERT ls_sel_field INTO TABLE ct_sel_fields.
155
156      ls_sel_field-line = 'GEBER'.
157      INSERT ls_sel_field INTO TABLE ct_sel_fields.
158
159      ls_sel_field-line = 'GSFRG'.
160      INSERT ls_sel_field INTO TABLE ct_sel_fields.
161
162      ls_sel_field-line = 'IDNLF'.
163      INSERT ls_sel_field INTO TABLE ct_sel_fields.
164
165      ls_sel_field-line = 'INFNR'.
166      INSERT ls_sel_field INTO TABLE ct_sel_fields.
167
168      ls_sel_field-line = 'IPRKZ'.
169      INSERT ls_sel_field INTO TABLE ct_sel_fields.
170
171      ls_sel_field-line = 'IUID_RELEVANT'.
172      INSERT ls_sel_field INTO TABLE ct_sel_fields.
173
174      ls_sel_field-line = 'KNTTP'.
175      INSERT ls_sel_field INTO TABLE ct_sel_fields.
176
177      ls_sel_field-line = 'KONNR'.
178      INSERT ls_sel_field INTO TABLE ct_sel_fields.
179
180      ls_sel_field-line = 'KTPNR'.
181      INSERT ls_sel_field INTO TABLE ct_sel_fields.
182
183      ls_sel_field-line = 'KUNNR'.
184      INSERT ls_sel_field INTO TABLE ct_sel_fields.
185
186      ls_sel_field-line = 'KZBWS'.
187      INSERT ls_sel_field INTO TABLE ct_sel_fields.
188
189      ls_sel_field-line = 'KZKFG'.
190      INSERT ls_sel_field INTO TABLE ct_sel_fields.
191
192      ls_sel_field-line = 'KZVBR'.
193      INSERT ls_sel_field INTO TABLE ct_sel_fields.
194
195      ls_sel_field-line = 'LBLKZ'.
196      INSERT ls_sel_field INTO TABLE ct_sel_fields.
197
198      ls_sel_field-line = 'LBLNI'.
199      INSERT ls_sel_field INTO TABLE ct_sel_fields.
200
201      ls_sel_field-line = 'LFDAT'.
202      INSERT ls_sel_field INTO TABLE ct_sel_fields.
203
204      ls_sel_field-line = 'LGORT'.
205      INSERT ls_sel_field INTO TABLE ct_sel_fields.
206
207      ls_sel_field-line = 'LIFNR'.
208      INSERT ls_sel_field INTO TABLE ct_sel_fields.
209
210      ls_sel_field-line = 'LOEKZ'.
211      INSERT ls_sel_field INTO TABLE ct_sel_fields.
212
213      ls_sel_field-line = 'LPEIN'.
214      INSERT ls_sel_field INTO TABLE ct_sel_fields.
215
216      ls_sel_field-line = 'MATKL'.
217      INSERT ls_sel_field INTO TABLE ct_sel_fields.
218
219      ls_sel_field-line = 'MATNR'.
220      INSERT ls_sel_field INTO TABLE ct_sel_fields.
221
222      ls_sel_field-line = 'MEINS'.
223      INSERT ls_sel_field INTO TABLE ct_sel_fields.
224
225      ls_sel_field-line = 'MEMORY'.
226      INSERT ls_sel_field INTO TABLE ct_sel_fields.
227
228      ls_sel_field-line = 'MEMORYTYPE'.
229      INSERT ls_sel_field INTO TABLE ct_sel_fields.
230
231      ls_sel_field-line = 'MENGE'.
232      INSERT ls_sel_field INTO TABLE ct_sel_fields.
233
234      ls_sel_field-line = 'MFRNR'.
235      INSERT ls_sel_field INTO TABLE ct_sel_fields.
236
237      ls_sel_field-line = 'MFRPN'.
238      INSERT ls_sel_field INTO TABLE ct_sel_fields.
239
240      ls_sel_field-line = 'MHDRZ'.
241      INSERT ls_sel_field INTO TABLE ct_sel_fields.
242
243      ls_sel_field-line = 'MNG02'.
244      INSERT ls_sel_field INTO TABLE ct_sel_fields.
245
246      ls_sel_field-line = 'MPROF'.
247      INSERT ls_sel_field INTO TABLE ct_sel_fields.
248
249      ls_sel_field-line = 'PEINH'.
250      INSERT ls_sel_field INTO TABLE ct_sel_fields.
251
252      ls_sel_field-line = 'PLIFZ'.
253      INSERT ls_sel_field INTO TABLE ct_sel_fields.
254
255      ls_sel_field-line = 'PREIS'.
256      INSERT ls_sel_field INTO TABLE ct_sel_fields.
257
258      ls_sel_field-line = 'PRIO_REQ'.
259      INSERT ls_sel_field INTO TABLE ct_sel_fields.
260
261      ls_sel_field-line = 'PRIO_URG'.
262      INSERT ls_sel_field INTO TABLE ct_sel_fields.
263
264      ls_sel_field-line = 'PSTYP'.
265      INSERT ls_sel_field INTO TABLE ct_sel_fields.
266
267      ls_sel_field-line = 'REPOS'.
268      INSERT ls_sel_field INTO TABLE ct_sel_fields.
269
270      ls_sel_field-line = 'RESLO'.
271      INSERT ls_sel_field INTO TABLE ct_sel_fields.
272
273      ls_sel_field-line = 'RESWK'.
274      INSERT ls_sel_field INTO TABLE ct_sel_fields.
275
276      ls_sel_field-line = 'REVLV'.
277      INSERT ls_sel_field INTO TABLE ct_sel_fields.
278
279      ls_sel_field-line = 'RSNUM'.
280      INSERT ls_sel_field INTO TABLE ct_sel_fields.
281
282      ls_sel_field-line = 'SATNR'.
283      INSERT ls_sel_field INTO TABLE ct_sel_fields.
284
285      ls_sel_field-line = 'SOBKZ'.
286      INSERT ls_sel_field INTO TABLE ct_sel_fields.
287
288      ls_sel_field-line = 'SPRAS'.
289      INSERT ls_sel_field INTO TABLE ct_sel_fields.
290
291      ls_sel_field-line = 'SRM_CONTRACT_ID'.
292      INSERT ls_sel_field INTO TABLE ct_sel_fields.
293
294      ls_sel_field-line = 'SRM_CONTRACT_ITM'.
295      INSERT ls_sel_field INTO TABLE ct_sel_fields.
296
297      ls_sel_field-line = 'STATU'.
298      INSERT ls_sel_field INTO TABLE ct_sel_fields.
299
300      ls_sel_field-line = 'TWRKZ'.
301      INSERT ls_sel_field INTO TABLE ct_sel_fields.
302
303      ls_sel_field-line = 'TXZ01'.
304      INSERT ls_sel_field INTO TABLE ct_sel_fields.
305
306      ls_sel_field-line = 'VRTKZ'.
307      INSERT ls_sel_field INTO TABLE ct_sel_fields.
308
309      ls_sel_field-line = 'WAERS'.
310      INSERT ls_sel_field INTO TABLE ct_sel_fields.
311
312      ls_sel_field-line = 'WEBAZ'.
313      INSERT ls_sel_field INTO TABLE ct_sel_fields.
314
315      ls_sel_field-line = 'WEPOS'.
316      INSERT ls_sel_field INTO TABLE ct_sel_fields.
317
318      ls_sel_field-line = 'WERKS'.
319      INSERT ls_sel_field INTO TABLE ct_sel_fields.
320
321      ls_sel_field-line = 'WEUNB'.
322      INSERT ls_sel_field INTO TABLE ct_sel_fields.
323
324      ls_sel_field-line = 'ZUGBA'.
325      INSERT ls_sel_field INTO TABLE ct_sel_fields.
326
327    ENDFORM.                    " FILL_ALV_SEL_FIELDS
*--- End of FM06BFSL_MODIFY_DYNFIE_ALV - 327 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFSL_MODIFY_DYNFIE_TECH               Level 3    Page 227
Object           SAPMZFM06B                                Lines 48
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&      Form  modify_dynfie_add_fields_tech
3      *&---------------------------------------------------------------------*
4      *      -->CT_SEL_FIELD  text
5      *----------------------------------------------------------------------*
6      FORM modify_dynfie_add_fields_tech
7        CHANGING ct_sel_field TYPE rsfs_tab_fields-fields.
8
9        DATA:
10         ls_sel_field LIKE LINE OF ct_sel_field.
11
12       ls_sel_field-line = 'MANDT'. INSERT ls_sel_field INTO TABLE ct_sel_field.
13       ls_sel_field-line = 'AFNAM'. INSERT ls_sel_field INTO TABLE ct_sel_field.
14       ls_sel_field-line = 'BANFN'. INSERT ls_sel_field INTO TABLE ct_sel_field.
15       ls_sel_field-line = 'BESWK'. INSERT ls_sel_field INTO TABLE ct_sel_field.
16       ls_sel_field-line = 'BNFPO'. INSERT ls_sel_field INTO TABLE ct_sel_field.
17       ls_sel_field-line = 'BSAKZ'. INSERT ls_sel_field INTO TABLE ct_sel_field.
18       ls_sel_field-line = 'BSART'. INSERT ls_sel_field INTO TABLE ct_sel_field.
19       ls_sel_field-line = 'BSMNG'. INSERT ls_sel_field INTO TABLE ct_sel_field.
20       ls_sel_field-line = 'EBAKZ'. INSERT ls_sel_field INTO TABLE ct_sel_field.
21       ls_sel_field-line = 'EKGRP'. INSERT ls_sel_field INTO TABLE ct_sel_field.
22       ls_sel_field-line = 'EKORG'. INSERT ls_sel_field INTO TABLE ct_sel_field.
23       ls_sel_field-line = 'FLIEF'. INSERT ls_sel_field INTO TABLE ct_sel_field.
24       ls_sel_field-line = 'FORDN'. INSERT ls_sel_field INTO TABLE ct_sel_field.
25       ls_sel_field-line = 'FRGKZ'. INSERT ls_sel_field INTO TABLE ct_sel_field.
26       ls_sel_field-line = 'FRGRL'. INSERT ls_sel_field INTO TABLE ct_sel_field.
27       ls_sel_field-line = 'FRGGR'. INSERT ls_sel_field INTO TABLE ct_sel_field.
28       ls_sel_field-line = 'FRGST'. INSERT ls_sel_field INTO TABLE ct_sel_field.
29       ls_sel_field-line = 'GSFRG'. INSERT ls_sel_field INTO TABLE ct_sel_field.
30       ls_sel_field-line = 'INFNR'. INSERT ls_sel_field INTO TABLE ct_sel_field.
31       ls_sel_field-line = 'KNTTP'. INSERT ls_sel_field INTO TABLE ct_sel_field.
32       ls_sel_field-line = 'KONNR'. INSERT ls_sel_field INTO TABLE ct_sel_field.
33       ls_sel_field-line = 'KTPNR'. INSERT ls_sel_field INTO TABLE ct_sel_field.
34       ls_sel_field-line = 'KZVBR'. INSERT ls_sel_field INTO TABLE ct_sel_field.
35       ls_sel_field-line = 'LFDAT'. INSERT ls_sel_field INTO TABLE ct_sel_field.
36       ls_sel_field-line = 'LOEKZ'. INSERT ls_sel_field INTO TABLE ct_sel_field.
37       ls_sel_field-line = 'LPEIN'. INSERT ls_sel_field INTO TABLE ct_sel_field.
38       ls_sel_field-line = 'MEINS'. INSERT ls_sel_field INTO TABLE ct_sel_field.
39       ls_sel_field-line = 'MEMORY'. INSERT ls_sel_field INTO TABLE ct_sel_field.
40       ls_sel_field-line = 'MENGE'. INSERT ls_sel_field INTO TABLE ct_sel_field.
41       ls_sel_field-line = 'PSTYP'. INSERT ls_sel_field INTO TABLE ct_sel_field.
42       ls_sel_field-line = 'RESWK'. INSERT ls_sel_field INTO TABLE ct_sel_field.
43       ls_sel_field-line = 'STATU'. INSERT ls_sel_field INTO TABLE ct_sel_field.
44       ls_sel_field-line = 'TXZ01'. INSERT ls_sel_field INTO TABLE ct_sel_field.
45       ls_sel_field-line = 'WAERS'. INSERT ls_sel_field INTO TABLE ct_sel_field.
46       ls_sel_field-line = 'WERKS'. INSERT ls_sel_field INTO TABLE ct_sel_field.
47       ls_sel_field-line = 'ZUGBA'. INSERT ls_sel_field INTO TABLE ct_sel_field.
48     ENDFORM.                    "modify_dynfie_add_fields_tech
*--- End of FM06BFSL_MODIFY_DYNFIE_TECH - 48 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFSL_MODIFY_DYNFIE_001                Level 3    Page 228
Object           SAPMZFM06B                                Lines 21
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&      Form  modify_dynfie_add_fields_001
3      *&---------------------------------------------------------------------*
4      *       text
5      *----------------------------------------------------------------------*
6      *      -->CT_SEL_FIELD  text
7      *----------------------------------------------------------------------*
8      FORM modify_dynfie_add_fields_001
9        CHANGING ct_sel_field TYPE rsfs_tab_fields-fields.
10
11       DATA:
12         ls_sel_field LIKE LINE OF ct_sel_field.
13
14       ls_sel_field-line = 'GSFRG'. INSERT ls_sel_field INTO TABLE ct_sel_field.
15       ls_sel_field-line = 'MATNR'. INSERT ls_sel_field INTO TABLE ct_sel_field.
16       ls_sel_field-line = 'TXZ01'. INSERT ls_sel_field INTO TABLE ct_sel_field.
17       ls_sel_field-line = 'EKGRP'. INSERT ls_sel_field INTO TABLE ct_sel_field.
18       ls_sel_field-line = 'MATKL'. INSERT ls_sel_field INTO TABLE ct_sel_field.
19       ls_sel_field-line = 'PACKNO'. INSERT ls_sel_field INTO TABLE ct_sel_field.
20
21     ENDFORM.                    "modify_dynfie_add_fields_001
*--- End of FM06BFSL_MODIFY_DYNFIE_001 - 21 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFSL_MODIFY_DYNFIE_002                Level 3    Page 229
Object           SAPMZFM06B                                Lines 24
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&      Form  modify_dynfie_add_fields_002
3      *&---------------------------------------------------------------------*
4      *       text
5      *----------------------------------------------------------------------*
6      *      -->CT_SEL_FIELD  text
7      *----------------------------------------------------------------------*
8      FORM modify_dynfie_add_fields_002
9        CHANGING ct_sel_field TYPE rsfs_tab_fields-fields.
10
11       DATA:
12         ls_sel_field LIKE LINE OF ct_sel_field.
13
14       ls_sel_field-line = 'AFNAM'. INSERT ls_sel_field INTO TABLE ct_sel_field.
15       ls_sel_field-line = 'BANFN'. INSERT ls_sel_field INTO TABLE ct_sel_field.
16       ls_sel_field-line = 'BNFPO'. INSERT ls_sel_field INTO TABLE ct_sel_field.
17       ls_sel_field-line = 'GSFRG'. INSERT ls_sel_field INTO TABLE ct_sel_field.
18       ls_sel_field-line = 'LGORT'. INSERT ls_sel_field INTO TABLE ct_sel_field.
19       ls_sel_field-line = 'MEINS'. INSERT ls_sel_field INTO TABLE ct_sel_field.
20       ls_sel_field-line = 'MENGE'. INSERT ls_sel_field INTO TABLE ct_sel_field.
21       ls_sel_field-line = 'PACKNO'. INSERT ls_sel_field INTO TABLE ct_sel_field.
22       ls_sel_field-line = 'WERKS'. INSERT ls_sel_field INTO TABLE ct_sel_field.
23
24     ENDFORM.                    "modify_dynfie_add_fields_002
*--- End of FM06BFSL_MODIFY_DYNFIE_002 - 24 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFSL_MODIFY_DYNFIE_003                Level 3    Page 230
Object           SAPMZFM06B                                Lines 27
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&      Form  modify_dynfie_add_fields_003
3      *&---------------------------------------------------------------------*
4      *       text
5      *----------------------------------------------------------------------*
6      *      -->CT_SEL_FIELD  text
7      *----------------------------------------------------------------------*
8      FORM modify_dynfie_add_fields_003
9        CHANGING ct_sel_field TYPE rsfs_tab_fields-fields.
10
11       DATA:
12         ls_sel_field LIKE LINE OF ct_sel_field.
13
14       ls_sel_field-line = 'BEDNR'. INSERT ls_sel_field INTO TABLE ct_sel_field.
15       ls_sel_field-line = 'BSART'. INSERT ls_sel_field INTO TABLE ct_sel_field.
16       ls_sel_field-line = 'BSMNG'. INSERT ls_sel_field INTO TABLE ct_sel_field.
17       ls_sel_field-line = 'DISPO'. INSERT ls_sel_field INTO TABLE ct_sel_field.
18       ls_sel_field-line = 'ESTKZ'. INSERT ls_sel_field INTO TABLE ct_sel_field.
19       ls_sel_field-line = 'FRGDT'. INSERT ls_sel_field INTO TABLE ct_sel_field.
20       ls_sel_field-line = 'FRGKZ'. INSERT ls_sel_field INTO TABLE ct_sel_field.
21       ls_sel_field-line = 'GSFRG'. INSERT ls_sel_field INTO TABLE ct_sel_field.
22       ls_sel_field-line = 'KNTTP'. INSERT ls_sel_field INTO TABLE ct_sel_field.
23       ls_sel_field-line = 'MEINS'. INSERT ls_sel_field INTO TABLE ct_sel_field.
24       ls_sel_field-line = 'RESWK'. INSERT ls_sel_field INTO TABLE ct_sel_field.
25       ls_sel_field-line = 'STATU'. INSERT ls_sel_field INTO TABLE ct_sel_field.
26
27     ENDFORM.                    "modify_dynfie_add_fields_003
*--- End of FM06BFSL_MODIFY_DYNFIE_003 - 27 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFSL_MODIFY_DYNFIE_004                Level 3    Page 231
Object           SAPMZFM06B                                Lines 16
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&      Form  modify_dynfie_add_fields_004
3      *&---------------------------------------------------------------------*
4      *       text
5      *----------------------------------------------------------------------*
6      *      -->CT_SEL_FIELD  text
7      *----------------------------------------------------------------------*
8      FORM modify_dynfie_add_fields_004
9        CHANGING ct_sel_field TYPE rsfs_tab_fields-fields.
10
11       DATA:
12         ls_sel_field LIKE LINE OF ct_sel_field.
13
14       ls_sel_field-line = 'GSFRG'. INSERT ls_sel_field INTO TABLE ct_sel_field.
15
16     ENDFORM.                    "modify_dynfie_add_fields_004
*--- End of FM06BFSL_MODIFY_DYNFIE_004 - 16 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFSL_MODIFY_DYNFIE_005                Level 3    Page 232
Object           SAPMZFM06B                                Lines 18
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&      Form  modify_dynfie_add_fields_005
3      *&---------------------------------------------------------------------*
4      *       text
5      *----------------------------------------------------------------------*
6      *      -->CT_SEL_FIELD  text
7      *----------------------------------------------------------------------*
8      FORM modify_dynfie_add_fields_005
9        CHANGING ct_sel_field TYPE rsfs_tab_fields-fields.
10
11       DATA:
12         ls_sel_field LIKE LINE OF ct_sel_field.
13
14       ls_sel_field-line = 'GSFRG'. INSERT ls_sel_field INTO TABLE ct_sel_field.
15       ls_sel_field-line = 'LIFNR'. INSERT ls_sel_field INTO TABLE ct_sel_field.
16       ls_sel_field-line = 'PACKNO'. INSERT ls_sel_field INTO TABLE ct_sel_field.
17
18     ENDFORM.                    "modify_dynfie_add_fields_005
*--- End of FM06BFSL_MODIFY_DYNFIE_005 - 18 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFSL_MODIFY_DYNFIE_006                Level 3    Page 233
Object           SAPMZFM06B                                Lines 18
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&      Form  modify_dynfie_add_fields_006
3      *&---------------------------------------------------------------------*
4      *       text
5      *----------------------------------------------------------------------*
6      *      -->CT_SEL_FIELD  text
7      *----------------------------------------------------------------------*
8      FORM modify_dynfie_add_fields_006
9        CHANGING ct_sel_field TYPE rsfs_tab_fields-fields.
10
11       DATA:
12         ls_sel_field LIKE LINE OF ct_sel_field.
13
14       ls_sel_field-line = 'GSFRG'. INSERT ls_sel_field INTO TABLE ct_sel_field.
15       ls_sel_field-line = 'BUMNG'. INSERT ls_sel_field INTO TABLE ct_sel_field.
16       ls_sel_field-line = 'MEINS'. INSERT ls_sel_field INTO TABLE ct_sel_field.
17       ls_sel_field-line = 'PACKNO'. INSERT ls_sel_field INTO TABLE ct_sel_field.
18     ENDFORM.                    "modify_dynfie_add_fields_006
*--- End of FM06BFSL_MODIFY_DYNFIE_006 - 18 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFSL_MODIFY_DYNFIE_007                Level 3    Page 234
Object           SAPMZFM06B                                Lines 18
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&      Form  modify_dynfie_add_fields_007
3      *&---------------------------------------------------------------------*
4      *       text
5      *----------------------------------------------------------------------*
6      *      -->CT_SEL_FIELD  text
7      *----------------------------------------------------------------------*
8      FORM modify_dynfie_add_fields_007
9        CHANGING ct_sel_field TYPE rsfs_tab_fields-fields.
10
11       DATA:
12         ls_sel_field LIKE LINE OF ct_sel_field.
13
14       ls_sel_field-line = 'GSFRG'. INSERT ls_sel_field INTO TABLE ct_sel_field.
15       ls_sel_field-line = 'BVDAT'. INSERT ls_sel_field INTO TABLE ct_sel_field.
16       ls_sel_field-line = 'BVDRK'. INSERT ls_sel_field INTO TABLE ct_sel_field.
17
18     ENDFORM.                    "modify_dynfie_add_fields_007
*--- End of FM06BFSL_MODIFY_DYNFIE_007 - 18 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFSL_MODIFY_DYNFIE_008                Level 3    Page 235
Object           SAPMZFM06B                                Lines 22
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&      Form  modify_dynfie_add_fields_008
3      *&---------------------------------------------------------------------*
4      *       text
5      *----------------------------------------------------------------------*
6      *      -->CT_SEL_FIELD  text
7      *----------------------------------------------------------------------*
8      FORM modify_dynfie_add_fields_008
9        CHANGING ct_sel_field TYPE rsfs_tab_fields-fields.
10
11       DATA:
12         ls_sel_field LIKE LINE OF ct_sel_field.
13
14       ls_sel_field-line = 'GSFRG'. INSERT ls_sel_field INTO TABLE ct_sel_field.
15       ls_sel_field-line = 'EBELN'. INSERT ls_sel_field INTO TABLE ct_sel_field.
16       ls_sel_field-line = 'BSAKZ'. INSERT ls_sel_field INTO TABLE ct_sel_field.
17       ls_sel_field-line = 'EBELN'. INSERT ls_sel_field INTO TABLE ct_sel_field.
18       ls_sel_field-line = 'EBELP'. INSERT ls_sel_field INTO TABLE ct_sel_field.
19       ls_sel_field-line = 'BEDAT'. INSERT ls_sel_field INTO TABLE ct_sel_field.
20       ls_sel_field-line = 'PACKNO'. INSERT ls_sel_field INTO TABLE ct_sel_field.
21
22     ENDFORM.                    "modify_dynfie_add_fields_008
*--- End of FM06BFSL_MODIFY_DYNFIE_008 - 22 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFSL_MODIFY_DYNFIE_009                Level 3    Page 236
Object           SAPMZFM06B                                Lines 19
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&      Form  modify_dynfie_add_fields_009
3      *&---------------------------------------------------------------------*
4      *       text
5      *----------------------------------------------------------------------*
6      *      -->CT_SEL_FIELD  text
7      *----------------------------------------------------------------------*
8      FORM modify_dynfie_add_fields_009
9        CHANGING ct_sel_field TYPE rsfs_tab_fields-fields.
10
11       DATA:
12         ls_sel_field LIKE LINE OF ct_sel_field.
13
14       ls_sel_field-line = 'GSFRG'. INSERT ls_sel_field INTO TABLE ct_sel_field.
15       ls_sel_field-line = 'MATNR'. INSERT ls_sel_field INTO TABLE ct_sel_field.
16       ls_sel_field-line = 'WERKS'. INSERT ls_sel_field INTO TABLE ct_sel_field.
17       ls_sel_field-line = 'MEINS'. INSERT ls_sel_field INTO TABLE ct_sel_field.
18
19     ENDFORM.                    "modify_dynfie_add_fields_009
*--- End of FM06BFSL_MODIFY_DYNFIE_009 - 19 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFSL_MODIFY_DYNFIE_010                Level 3    Page 237
Object           SAPMZFM06B                                Lines 15
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&      Form  modify_dynfie_add_fields_010
3      *&---------------------------------------------------------------------*
4      *       text
5      *----------------------------------------------------------------------*
6      *      -->CT_SEL_FIELD  text
7      *----------------------------------------------------------------------*
8      FORM modify_dynfie_add_fields_010
9        CHANGING ct_sel_field TYPE rsfs_tab_fields-fields.
10
11       DATA:
12         ls_sel_field LIKE LINE OF ct_sel_field.
13
14       ls_sel_field-line = 'GSFRG'. INSERT ls_sel_field INTO TABLE ct_sel_field.
15     ENDFORM.                    "modify_dynfie_add_fields_010
*--- End of FM06BFSL_MODIFY_DYNFIE_010 - 15 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFSL_MODIFY_DYNFIE_011                Level 3    Page 238
Object           SAPMZFM06B                                Lines 30
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&      Form  modify_dynfie_add_fields_011
3      *&---------------------------------------------------------------------*
4      *       text
5      *----------------------------------------------------------------------*
6      *      -->CT_SEL_FIELD  text
7      *----------------------------------------------------------------------*
8      FORM modify_dynfie_add_fields_011
9        CHANGING ct_sel_field TYPE rsfs_tab_fields-fields.
10
11       DATA:
12         ls_sel_field LIKE LINE OF ct_sel_field.
13
14       ls_sel_field-line = 'GSFRG'. INSERT ls_sel_field INTO TABLE ct_sel_field.
15       ls_sel_field-line = 'PEINH'. INSERT ls_sel_field INTO TABLE ct_sel_field.
16       ls_sel_field-line = 'PREIS'. INSERT ls_sel_field INTO TABLE ct_sel_field.
17       ls_sel_field-line = 'MENGE'. INSERT ls_sel_field INTO TABLE ct_sel_field.
18       ls_sel_field-line = 'WERKS'. INSERT ls_sel_field INTO TABLE ct_sel_field.
19       ls_sel_field-line = 'STATU'. INSERT ls_sel_field INTO TABLE ct_sel_field.
20       ls_sel_field-line = 'ESTKZ'. INSERT ls_sel_field INTO TABLE ct_sel_field.
21       ls_sel_field-line = 'FRGKZ'. INSERT ls_sel_field INTO TABLE ct_sel_field.
22       ls_sel_field-line = 'BSART'. INSERT ls_sel_field INTO TABLE ct_sel_field.
23       ls_sel_field-line = 'KNTTP'. INSERT ls_sel_field INTO TABLE ct_sel_field.
24       ls_sel_field-line = 'WAERS'. INSERT ls_sel_field INTO TABLE ct_sel_field.
25       ls_sel_field-line = 'FRGDT'. INSERT ls_sel_field INTO TABLE ct_sel_field.
26       ls_sel_field-line = 'BEDNR'. INSERT ls_sel_field INTO TABLE ct_sel_field.
27       ls_sel_field-line = 'RESWK'. INSERT ls_sel_field INTO TABLE ct_sel_field.
28       ls_sel_field-line = 'DISPO'. INSERT ls_sel_field INTO TABLE ct_sel_field.
29
30     ENDFORM.                    "modify_dynfie_add_fields_011
*--- End of FM06BFSL_MODIFY_DYNFIE_011 - 30 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFSL_MODIFY_DYNFIE_012                Level 3    Page 239
Object           SAPMZFM06B                                Lines 17
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&      Form  modify_dynfie_add_fields_012
3      *&---------------------------------------------------------------------*
4      *       text
5      *----------------------------------------------------------------------*
6      *      -->CT_SEL_FIELD  text
7      *----------------------------------------------------------------------*
8      FORM modify_dynfie_add_fields_012
9        CHANGING ct_sel_field TYPE rsfs_tab_fields-fields.
10
11       DATA:
12         ls_sel_field LIKE LINE OF ct_sel_field.
13
14       ls_sel_field-line = 'GSFRG'. INSERT ls_sel_field INTO TABLE ct_sel_field.
15       ls_sel_field-line = 'INFNR'. INSERT ls_sel_field INTO TABLE ct_sel_field.
16       ls_sel_field-line = 'KONNR'. INSERT ls_sel_field INTO TABLE ct_sel_field.
17     ENDFORM.                    "modify_dynfie_add_fields_012
*--- End of FM06BFSL_MODIFY_DYNFIE_012 - 17 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFSL_MODIFY_DYNFIE_013                Level 3    Page 240
Object           SAPMZFM06B                                Lines 17
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&      Form  modify_dynfie_add_fields_013
3      *&---------------------------------------------------------------------*
4      *       text
5      *----------------------------------------------------------------------*
6      *      -->CT_SEL_FIELD  text
7      *----------------------------------------------------------------------*
8      FORM modify_dynfie_add_fields_013
9        CHANGING ct_sel_field TYPE rsfs_tab_fields-fields.
10
11       DATA:
12         ls_sel_field LIKE LINE OF ct_sel_field.
13
14       ls_sel_field-line = 'GSFRG'. INSERT ls_sel_field INTO TABLE ct_sel_field.
15       ls_sel_field-line = 'FLIEF'. INSERT ls_sel_field INTO TABLE ct_sel_field.
16
17     ENDFORM.                    "modify_dynfie_add_fields_013
*--- End of FM06BFSL_MODIFY_DYNFIE_013 - 17 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFSL_MODIFY_DYNFIE_014                Level 3    Page 241
Object           SAPMZFM06B                                Lines 19
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&      Form  modify_dynfie_add_fields_014
3      *&---------------------------------------------------------------------*
4      *       text
5      *----------------------------------------------------------------------*
6      *      -->CT_SEL_FIELD  text
7      *----------------------------------------------------------------------*
8      FORM modify_dynfie_add_fields_014
9        CHANGING ct_sel_field TYPE rsfs_tab_fields-fields.
10
11       DATA:
12         ls_sel_field LIKE LINE OF ct_sel_field.
13
14       ls_sel_field-line = 'GSFRG'. INSERT ls_sel_field INTO TABLE ct_sel_field.
15       ls_sel_field-line = 'MATNR'. INSERT ls_sel_field INTO TABLE ct_sel_field.
16       ls_sel_field-line = 'WERKS'. INSERT ls_sel_field INTO TABLE ct_sel_field.
17       ls_sel_field-line = 'MEINS'. INSERT ls_sel_field INTO TABLE ct_sel_field.
18
19     ENDFORM.                    "modify_dynfie_add_fields_014
*--- End of FM06BFSL_MODIFY_DYNFIE_014 - 19 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFSL_MODIFY_DYNFIE_102                Level 3    Page 242
Object           SAPMZFM06B                                Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&      Form  modify_dynfie_add_fields_102
3      *&---------------------------------------------------------------------*
4      *       text
5      *----------------------------------------------------------------------*
6      *      -->CT_SEL_FIELD  text
7      *----------------------------------------------------------------------*
8      FORM modify_dynfie_add_fields_102
9        CHANGING ct_sel_field TYPE rsfs_tab_fields-fields.
10
11       DATA:
12         ls_sel_field LIKE LINE OF ct_sel_field.
13
14       ls_sel_field-line = 'GSFRG'. INSERT ls_sel_field INTO TABLE ct_sel_field.
15       ls_sel_field-line = 'BSART'. INSERT ls_sel_field INTO TABLE ct_sel_field.
16       ls_sel_field-line = 'KNTTP'. INSERT ls_sel_field INTO TABLE ct_sel_field.
17       ls_sel_field-line = 'MENGE'. INSERT ls_sel_field INTO TABLE ct_sel_field.
18       ls_sel_field-line = 'MEINS'. INSERT ls_sel_field INTO TABLE ct_sel_field.
19       ls_sel_field-line = 'WERKS'. INSERT ls_sel_field INTO TABLE ct_sel_field.
20       ls_sel_field-line = 'LGORT'. INSERT ls_sel_field INTO TABLE ct_sel_field.
21       ls_sel_field-line = 'RESWK'. INSERT ls_sel_field INTO TABLE ct_sel_field.
22       ls_sel_field-line = 'DISPO'. INSERT ls_sel_field INTO TABLE ct_sel_field.
23     ENDFORM.                    "modify_dynfie_add_fields_102
*--- End of FM06BFSL_MODIFY_DYNFIE_102 - 23 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFSL_MODIFY_DYNFIE_201                Level 3    Page 243
Object           SAPMZFM06B                                Lines 20
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&      Form  modify_dynfie_add_fields_201
3      *&---------------------------------------------------------------------*
4      *       text
5      *----------------------------------------------------------------------*
6      *      -->CT_SEL_FIELD  text
7      *----------------------------------------------------------------------*
8      FORM modify_dynfie_add_fields_201
9        CHANGING ct_sel_field TYPE rsfs_tab_fields-fields.
10
11       DATA:
12         ls_sel_field LIKE LINE OF ct_sel_field.
13
14       ls_sel_field-line = 'GSFRG'. INSERT ls_sel_field INTO TABLE ct_sel_field.
15       ls_sel_field-line = 'MATNR'. INSERT ls_sel_field INTO TABLE ct_sel_field.
16       ls_sel_field-line = 'TXZ01'. INSERT ls_sel_field INTO TABLE ct_sel_field.
17       ls_sel_field-line = 'MENGE'. INSERT ls_sel_field INTO TABLE ct_sel_field.
18       ls_sel_field-line = 'MEINS'. INSERT ls_sel_field INTO TABLE ct_sel_field.
19
20     ENDFORM.                    "modify_dynfie_add_fields_201
*--- End of FM06BFSL_MODIFY_DYNFIE_201 - 20 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFSL_MODIFY_DYNFIE_301                Level 3    Page 244
Object           SAPMZFM06B                                Lines 20
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&      Form  modify_dynfie_add_fields_301
3      *&---------------------------------------------------------------------*
4      *       text
5      *----------------------------------------------------------------------*
6      *      -->CT_SEL_FIELD  text
7      *----------------------------------------------------------------------*
8      FORM modify_dynfie_add_fields_301
9        CHANGING ct_sel_field TYPE rsfs_tab_fields-fields.
10
11       DATA:
12         ls_sel_field LIKE LINE OF ct_sel_field.
13
14       ls_sel_field-line = 'GSFRG'. INSERT ls_sel_field INTO TABLE ct_sel_field.
15       ls_sel_field-line = 'GSFRG'. INSERT ls_sel_field INTO TABLE ct_sel_field.
16       ls_sel_field-line = 'MFRPN'. INSERT ls_sel_field INTO TABLE ct_sel_field.
17       ls_sel_field-line = 'EMNFR'. INSERT ls_sel_field INTO TABLE ct_sel_field.
18       ls_sel_field-line = 'MFRNR'. INSERT ls_sel_field INTO TABLE ct_sel_field.
19
20     ENDFORM.                    "modify_dynfie_add_fields_301
*--- End of FM06BFSL_MODIFY_DYNFIE_301 - 20 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFSL_LDB_BAM                          Level 2    Page 245
Object           SAPMZFM06B                                Lines 5
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1
2      INCLUDE FM06BFSL_LDB_BAM_DATEN_LESEN .   "BAM_DATEN_LESEN
3      INCLUDE FM06BFSL_LDB_BAM_MODIFY_DYNSEL . "MODIFY_DYNSEL
4      INCLUDE FM06BFSL_LDB_BAM_MOD_DYNSEL_AU . "MODIFY_DYNSEL_AUTH
5      INCLUDE FM06BFSL_LDB_BAM_WAERS_LESEN . "WAERS_LESEN
*--- End of FM06BFSL_LDB_BAM - 5 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFSL_LDB_BAM_DATEN_LESEN              Level 3    Page 246
Object           SAPMZFM06B                                Lines 205
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&      Form  bam_daten_lesen
3      *&---------------------------------------------------------------------*
4      *       This subroutine corresponds to the DATEN_LESEN subroutine
5      *       of the logical database program SAPDBBAM (LDB BAM). It is
6      *       called by programs where the logical database is not used
7      *       any more for retrieving the data from the database tables
8      *       (like trans. ME5A, ME57).
9      *----------------------------------------------------------------------*
10     FORM bam_daten_lesen TABLES it_eban
11                                 it_ebkn
12                                 ba_banfn
13                                 ba_matnr
14                                 ba_matkl
15                                 ba_werks
16                                 ba_ekgrp
17                                 ba_bsart
18                                 ba_pstyp
19                                 ba_knttp
20                                 ba_lfdat
21                                 ba_frgdt
22                                 ba_dispo
23                                 ba_statu
24                                 ba_flief
25                                 ba_banpr
26                                 ba_blckd
27                                 ba_beswk
28                                 ba_bednr
29                                 ba_txz01
30                                 ba_afnam
31                                 bk_kostl
32                                 bk_aufnr
33                                 bk_anln1
34                                 bk_anln2
35                                 bk_vbeln
36                                 bk_vbelp
37                                 bk_psint
38                                 bk_nplnr
39                                 bk_vornr
40                                 ba_memor                        "2065361
41                                 ba_loekz
42                                 bk_loekz
43                                 bk_psext
44                                 t_imkeys
45                           USING p_lstub
46                                 ebkn_sel
47                                 p_qcount
48                                 filter_by_eban_tech
49                                 p_dynfie
50                                 p_qerlba
51                                 p_qzugba
52                                 pba_ofba
53                                 p_qfreig
54                                 pba_ccp
55                                 iv_do_modify_dynsel_auth        "2348724
56                           RAISING cx_sql_exception.             "2348724
57
58       DATA: select_fields TYPE rsfs_fields.
59       DATA: lc_tfill LIKE sy-tfill.
60       DATA: dyn_sel TYPE rsds_type.
61       DATA: selopt_dyn_sel TYPE rsds_type.
62       DATA: it_tact LIKE tact OCCURS 1.
63
64       FIELD-SYMBOLS: <dyn_sel> TYPE rsds_type.
65       DATA: lf_name TYPE c LENGTH 32.
66       DATA: lv_sql_exception_occured TYPE abap_bool.             "2348724
67
68     * if logical db is used dyn_sel might be filled
69       TRY.
70           CONCATENATE '(' 'SAPDBBAM' ')DYN_SEL' INTO lf_name.
71           ASSIGN (lf_name) TO <dyn_sel>.
72           IF <dyn_sel> IS ASSIGNED.
73             dyn_sel = <dyn_sel>.
74           ENDIF.
75         CATCH cx_root.
76       ENDTRY.
77
78       PERFORM modify_dynsel TABLES ba_loekz
79                              USING dyn_sel
80                                    p_qerlba
81                                    p_qzugba
82                                    pba_ofba
83                                    p_qfreig
84                                    pba_ccp
85                           CHANGING selopt_dyn_sel.
86
87       IF sy-cprog EQ 'RM06BZ00' OR
88          sy-cprog EQ 'RM06BZ10'.
89         APPEND '02' TO it_tact.
90         IF iv_do_modify_dynsel_auth = abap_true.             "2348724
91           PERFORM modify_dynsel_auth USING '02'
92                                   CHANGING selopt_dyn_sel.
93         ENDIF.                                               "2348724
94       ELSE.
95         APPEND '03' TO it_tact.
96         IF iv_do_modify_dynsel_auth = abap_true.             "2348724
97           PERFORM modify_dynsel_auth USING '03'
98                                   CHANGING selopt_dyn_sel.
99         ENDIF.                                               "2348724
100      ENDIF.
101
102      IF p_dynfie EQ abap_true.
103       PERFORM modify_dynfie USING p_lstub
104                          CHANGING select_fields.
105      ENDIF.
106
107    *---------------------------------------------------------------------------*
108    * Processing selection of transaction documment of just genric articles
109    * user need to specify a pattern on selection screen) only when the fashion
110    * switch sfsw_fashion_04 is ON.
111    *---------------------------------------------------------------------------*
112
113    If cl_switch_check_fashion=>sfsw_fashion_04( ) EQ abap_true.
114      DATA: lo_utility  TYPE REF TO cl_fsh_util.
115
116      IF lo_utility IS BOUND.
117       FREE lo_utility.
118      ENDIF.
119
120      CREATE OBJECT lo_utility.
121
122      CALL METHOD lo_utility->populate_article_range
123       EXPORTING
124         "i_indicator_fill_satnr_rng = abap_true "3060067
125         it_article_range_appl      = ba_matnr[]
126       IMPORTING
127         ct_matnr = data(lt_matnr)
128         ct_satnr = DATA(lt_satnr) .
129
130      IF lt_matnr IS NOT INITIAL.
131        refresh ba_matnr.
132        APPEND LINES OF lt_matnr to ba_matnr.
133      ENDIF.
134    Endif.
135
136    ENHANCEMENT-SECTION FM06BFSL_LDB_BAM_DATEN_LES_01 SPOTS ES_SAPFM06B .
137      CALL FUNCTION 'ME_READ_EBAN_MULTIPLE'
138        EXPORTING
139          i_dynsel              = selopt_dyn_sel
140    *      i_dynfie              = select_fields
141          i_sel_ebkn            = ebkn_sel
142          i_selection_limit     = p_qcount                      "200950
143          i_filter_by_eban_tech = filter_by_eban_tech
144        IMPORTING
145          e_reqs_without_auth   = lc_tfill
146    *     E_LAST_ENTRY          =
147          e_sql_exception_occured = lv_sql_exception_occured    "2348724
148        TABLES
149          te_eban               = it_eban
150          te_ebkn               = it_ebkn
151          ti_tact               = it_tact
152    *     TI_FREIG_ZUS          =
153          ti_banfn_range        = ba_banfn
154          ti_matnr_range        = ba_matnr
155          ti_matkl_range        = ba_matkl
156          ti_werks_range        = ba_werks
157          ti_ekgrp_range        = ba_ekgrp
158    *     TI_BSAKZ_RANGE        = BA_WERKS
159          ti_bsart_range        = ba_bsart
160          ti_pstyp_range        = ba_pstyp
161          ti_knttp_range        = ba_knttp
162          ti_lfdat_range        = ba_lfdat
163          ti_frgdt_range        = ba_frgdt
164          ti_dispo_range        = ba_dispo
165          ti_statu_range        = ba_statu
166          ti_flief_range        = ba_flief
167          ti_banpr_range        = ba_banpr
168          ti_blckd_range        = ba_blckd
169          ti_beswk_range        = ba_beswk
170          ti_bednr_range        = ba_bednr
171    *     TI_KONNR_RANGE        = BA_ZUGBA
172    *     TI_RESWK_RANGE        =
173    *     TI_EKORG_RANGE        =
174    *     TI_VRTYP_RANGE        =
175          ti_txz01_range        = ba_txz01
176          ti_afnam_range        = ba_afnam
177    *     TI_FRGGR_RANGE        =
178    *     TI_FRGST_RANGE        =
179          ti_kostl_range        = bk_kostl
180          ti_aufnr_range        = bk_aufnr
181          ti_anln1_range        = bk_anln1
182          ti_anln2_range        = bk_anln2
183          ti_vbeln_range        = bk_vbeln
184          ti_vbelp_range        = bk_vbelp
185          ti_ps_psp_pnr_range   = bk_psint
186          ti_nplnr_range        = bk_nplnr
187          ti_vornr_range        = bk_vornr
188    *     TI_ZUGBA_RANGE        =
189          ti_memory_range       = ba_memor                      "2065361
190          ti_eban_loekz_range   = ba_loekz
191          ti_ebkn_loekz_range   = bk_loekz
192    *     TI_EBAKZ_RANGE        =
193    *     TI_FRGRL_RANGE        =
194    *     TI_GSFRG_RANGE        =
195          ti_satnr_range        = lt_satnr
196          ti_pspid_ext_range    = bk_psext
197          ti_imkeys             = t_imkeys.
198
199      IF lv_sql_exception_occured = abap_true.                  "2348724
200        RAISE EXCEPTION TYPE cx_sql_exception.                  "2348724
201      ENDIF.                                                    "2348724
202
203    END-ENHANCEMENT-SECTION.
204
205    ENDFORM.                    "bam_daten_lesen
*--- End of FM06BFSL_LDB_BAM_DATEN_LESEN - 205 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFSL_LDB_BAM_MODIFY_DYNSEL            Level 3    Page 247
Object           SAPMZFM06B                                Lines 142
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *---------------------------------------------------------------------*
2      *       FORM modify_dynsel                                            *
3      *---------------------------------------------------------------------*
4      *       This subroutine corresponds to the MODIFY_DYNSEL subroutine   *
5      *       of the logical database program SAPDBBAM (LDB BAM). It is     *
6      *       called by programs where the logical database is not used     *
7      *       any more for retrieving the data from the database tables     *
8      *       (like trans. ME5A, ME57).                                     *
9      *---------------------------------------------------------------------*
10     *      +FB Aufruf kann beliebig oft widerholt werden                  *
11     *      +dyn_sel wird von LDB ueberschrieben, daher in SELPT_DYN_SEL   *
12     *       kopiert.                                                      *
13     *      +Ist zB ekko-lifnr auch ueber die freien Abgrenzungen drin,so  *
14     *       wird so_lifnr dennoch ordungsgemaess an der richtigen Stelle  *
15     *       hinugefuegt -> null Problemo                                  *
16     *---------------------------------------------------------------------*
17     FORM modify_dynsel TABLES ba_loekz
18                         USING dyn_sel        TYPE rsds_type
19                               p_qerlba       TYPE offba
20                               p_qzugba       TYPE p_zugba
21                               pba_ofba       TYPE offba
22                               p_qfreig       TYPE frba
23                               pba_ccp        TYPE xfeld
24                      CHANGING selopt_dyn_sel TYPE rsds_type.
25
26
27       DATA: ls_clause TYPE rsds_where,
28             ls_where  TYPE rsdswhere,
29             l_tabix   TYPE sy-tabix.
30
31       APPEND LINES OF dyn_sel-clauses TO selopt_dyn_sel-clauses.
32       APPEND LINES OF dyn_sel-texpr   TO selopt_dyn_sel-texpr.
33       APPEND LINES OF dyn_sel-trange  TO selopt_dyn_sel-trange.
34
35       IF NOT p_qerlba IS INITIAL OR
36          NOT p_qzugba IS INITIAL OR                             "527318
37          NOT pba_ofba IS INITIAL.                               "311324
38         READ TABLE selopt_dyn_sel-clauses INTO ls_clause
39             WITH KEY tablename = 'EBAN'.
40         IF NOT sy-subrc IS INITIAL.
41           ls_clause-tablename = 'EBAN'.
42         ELSE.
43           l_tabix = sy-tabix.
44           IF NOT ls_clause-where_tab[] IS INITIAL.
45             ls_where = 'AND'.
46             APPEND ls_where TO ls_clause-where_tab.
47           ENDIF.
48         ENDIF.
49         ls_where = '( LOEKZ EQ '''' AND EBAKZ EQ '''' AND ('.
50         APPEND ls_where TO ls_clause-where_tab.
51         IF pba_ccp IS INITIAL.
52           ls_where = '( ( BSMNG LT EBAN~MENGE OR PSTYP EQ ''8'' OR MENGE EQ 0 ) AND'. "2775443
53           APPEND ls_where TO ls_clause-where_tab.
54           ls_where =
55             'BSAKZ NE ''R'' ) OR ( BSAKZ EQ ''R'' AND STATU NE ''K'' AND'.
56         ELSE.
57     * EHP5 -> CPR: allow pur. agreement requisitions
58           ls_where = '( ( BSMNG LT EBAN~MENGE OR PSTYP EQ ''8'' OR MENGE EQ 0 ) '.    "2775443
59           APPEND ls_where TO ls_clause-where_tab.
60           ls_where =
61            ' ) OR ( BSAKZ EQ ''R'' AND STATU NE ''K'' AND'.
62         ENDIF.
63         APPEND ls_where TO ls_clause-where_tab.
64         ls_where = 'STATU NE ''L'' ) ) )'.
65         APPEND ls_where TO ls_clause-where_tab.
66
67         IF l_tabix IS INITIAL.
68           APPEND ls_clause TO selopt_dyn_sel-clauses.
69         ELSE.
70           MODIFY selopt_dyn_sel-clauses FROM ls_clause INDEX l_tabix.
71         ENDIF.
72       ENDIF.
73
74       IF NOT p_qfreig IS INITIAL OR
75          NOT p_qzugba IS INITIAL.                               "527318
76         CLEAR l_tabix.
77         READ TABLE selopt_dyn_sel-clauses INTO ls_clause
78             WITH KEY tablename = 'EBAN'.
79         IF NOT sy-subrc IS INITIAL.
80           ls_clause-tablename = 'EBAN'.
81         ELSE.
82           l_tabix = sy-tabix.
83           IF NOT ls_clause-where_tab[] IS INITIAL.
84             ls_where = 'AND'.
85             APPEND ls_where TO ls_clause-where_tab.
86           ENDIF.
87         ENDIF.
88         ls_where = '( FRGRL EQ '''' AND MEMORY EQ '''' )'.                            "2775443
89         APPEND ls_where TO ls_clause-where_tab.
90         IF l_tabix IS INITIAL.
91           APPEND ls_clause TO selopt_dyn_sel-clauses.
92         ELSE.
93           MODIFY selopt_dyn_sel-clauses FROM ls_clause INDEX l_tabix.
94         ENDIF.
95       ENDIF.
96
97       IF NOT p_qzugba IS INITIAL.
98         CLEAR l_tabix.
99         READ TABLE selopt_dyn_sel-clauses INTO ls_clause
100            WITH KEY tablename = 'EBAN'.
101        IF NOT sy-subrc IS INITIAL.
102          ls_clause-tablename = 'EBAN'.
103        ELSE.
104          l_tabix = sy-tabix.
105          IF NOT ls_clause-where_tab[] IS INITIAL.
106            ls_where = 'AND'.
107            APPEND ls_where TO ls_clause-where_tab.
108          ENDIF.
109        ENDIF.
110        ls_where = '( ZUGBA EQ ''X'' )'.
111        APPEND ls_where TO ls_clause-where_tab.
112        IF l_tabix IS INITIAL.
113          APPEND ls_clause TO selopt_dyn_sel-clauses.
114        ELSE.
115          MODIFY selopt_dyn_sel-clauses FROM ls_clause INDEX l_tabix.
116        ENDIF.
117      ENDIF.
118
119      DATA: lt_trange LIKE LINE OF dyn_sel-trange,              "^_n_942106
120            lt_frange_t LIKE LINE OF lt_trange-frange_t,
121            var_type TYPE char10.
122      DATA: ba_field LIKE dd03l-fieldname.
123      FIELD-SYMBOLS: <ba_table> TYPE STANDARD TABLE.
124      READ TABLE dyn_sel-trange INTO lt_trange WITH KEY tablename ='EBAN'.
125      IF sy-subrc IS INITIAL.
126        LOOP AT lt_trange-frange_t INTO lt_frange_t.
127
128          CONCATENATE 'ba_' lt_frange_t-fieldname '[]' INTO ba_field.
129
130          ASSIGN (ba_field) TO <ba_table>.
131          IF sy-subrc = 0.
132            FREE <ba_table>.
133          ENDIF.
134        ENDLOOP.
135      ENDIF.
136      IF NOT p_qerlba IS INITIAL OR
137         NOT p_qzugba IS INITIAL OR
138         NOT pba_ofba IS INITIAL.
139        FREE ba_loekz.
140      ENDIF.                                                    "v_n_942106
141
142    ENDFORM.                    "modify_dynsel
*--- End of FM06BFSL_LDB_BAM_MODIFY_DYNSEL - 142 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFSL_LDB_BAM_MOD_DYNSEL_AU            Level 3    Page 248
Object           SAPMZFM06B                                Lines 92
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&      Form  MODIFY_DYNSEL_AUTH
3      *&---------------------------------------------------------------------*
4      *       dynamic select clauses with regards to authorization
5      *----------------------------------------------------------------------*
6      FORM modify_dynsel_auth USING iv_activity    TYPE activ_auth
7                           CHANGING selopt_dyn_sel TYPE rsds_type.
8
9        DATA:
10         lo_authcheck TYPE REF TO cl_authcheck_sql_mm,
11         ls_where     TYPE        rsdswhere,
12         ls_where_tab TYPE        rsds_where_tab.
13
14
15       FIELD-SYMBOLS:
16         <ls_clause> TYPE rsds_where.
17
18     * EBAN:
19     *------
20
21       CREATE OBJECT lo_authcheck.
22
23     *- Belegart -----------------------------------------------------------*
24       CALL METHOD lo_authcheck->add_auth_check
25         EXPORTING
26           iv_sel_object_name = 'M_BANF_BSA'
27           iv_activity        = iv_activity
28           iv_dbtablename     = 'EBAN'
29           iv_dbfieldname     = 'BSART'.
30
31     *- Einkaufsorganisation -----------------------------------------------*
32       CALL METHOD lo_authcheck->add_auth_check
33         EXPORTING
34           iv_sel_object_name = 'M_BANF_EKO'
35           iv_activity        = iv_activity
36           iv_dbtablename     = 'EBAN'
37           iv_dbfieldname     = 'EKORG'.
38
39     *- Einkäufergruppe ----------------------------------------------------*
40       CALL METHOD lo_authcheck->add_auth_check
41         EXPORTING
42           iv_sel_object_name = 'M_BANF_EKG'
43           iv_activity        = iv_activity
44           iv_dbtablename     = 'EBAN'
45           iv_dbfieldname     = 'EKGRP'.
46
47     *- WERK ---------------------------------------------------------------*
48       CALL METHOD lo_authcheck->add_auth_check
49         EXPORTING
50           iv_sel_object_name = 'M_BANF_WRK'
51           iv_activity        = iv_activity
52           iv_dbtablename     = 'EBAN'
53           iv_dbfieldname     = 'WERKS'.
54
55     *- CCP procuring plant ------------------------------------------------*
56       DATA: lf_ccp_active TYPE c.
57       CALL FUNCTION 'ME_CCP_ACTIVE_CHECK'
58         IMPORTING
59           ef_ccp_active = lf_ccp_active.
60
61       IF lf_ccp_active IS NOT INITIAL.
62         CALL METHOD lo_authcheck->add_auth_check
63           EXPORTING
64             iv_sel_object_name = 'M_BANF_BWK'
65             iv_activity        = iv_activity
66             iv_dbtablename     = 'EBAN'
67             iv_dbfieldname     = 'BESWK'.
68       ENDIF.
69
70       lo_authcheck->get_expression(
71         CHANGING
72           ct_where_tab = ls_where_tab
73           ).
74
75       IF ls_where_tab[] IS NOT INITIAL.
76     * ==> where clause deducted from authorization exists
77
78         READ TABLE selopt_dyn_sel-clauses ASSIGNING <ls_clause>
79             WITH KEY tablename = 'EBAN'.
80         IF sy-subrc <> 0.
81           APPEND INITIAL LINE TO selopt_dyn_sel-clauses ASSIGNING <ls_clause>.
82           <ls_clause>-tablename = 'EBAN'.
83         ELSE.
84           IF NOT <ls_clause>-where_tab[] IS INITIAL.
85             ls_where = 'AND'.
86             APPEND ls_where TO <ls_clause>-where_tab.
87           ENDIF.
88         ENDIF.
89         APPEND LINES OF ls_where_tab TO <ls_clause>-where_tab.
90       ENDIF.
91
92     ENDFORM.                    " MODIFY_DYNSEL_AUTH
*--- End of FM06BFSL_LDB_BAM_MOD_DYNSEL_AU - 92 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFSL_LDB_BAM_WAERS_LESEN              Level 3    Page 249
Object           SAPMZFM06B                                Lines 33
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *---------------------------------------------------------------------*
2      *       FORM WAERS_LESEN                                              *
3      *---------------------------------------------------------------------*
4      *       ........                                                      *
5      *---------------------------------------------------------------------*
6      *  -->  I_WERKS                                                       *
7      *  -->  C_WAERS                                                       *
8      *---------------------------------------------------------------------*
9      FORM waers_lesen USING    i_werks LIKE eban-werks
10                      CHANGING c_waers LIKE eban-waers.
11     "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
12
13     *  CHECK NOT i_werks IS INITIAL.
14     *  READ TABLE it_waers WITH KEY i_werks BINARY SEARCH.
15     *  IF sy-subrc EQ 0.
16     *    c_waers = it_waers-waers.
17     *    EXIT.
18     *  ENDIF.
19     *  DATA: l_tabix LIKE sy-tabix.
20     *  l_tabix = sy-tabix.
21     *  SELECT SINGLE * FROM t001w WHERE werks EQ i_werks.
22     *  CHECK sy-subrc EQ 0.
23     *  SELECT SINGLE * FROM t001k WHERE bwkey EQ t001w-bwkey.
24     *  CHECK sy-subrc EQ 0.
25     *  SELECT SINGLE * FROM t001  WHERE bukrs EQ t001k-bukrs.
26     *  CHECK sy-subrc EQ 0.
27     *
28     *  c_waers        = t001-waers.
29     *  it_waers-werks = i_werks.
30     *  it_waers-waers = t001-waers.
31     *  INSERT it_waers INDEX l_tabix.
32     "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
33     ENDFORM.                    "waers_lesen
*--- End of FM06BFSL_LDB_BAM_WAERS_LESEN - 33 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFSL_VENDOR_ARRAY_READ                Level 2    Page 250
Object           SAPMZFM06B                                Lines 46
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&      Form  VENDOR_ARRAY_READ
3      *&---------------------------------------------------------------------*
4      *       prefetch vendor master data to fill buffer
5      *----------------------------------------------------------------------*
6      *      -->IT_EBAN  table of purch.req. records
7      *----------------------------------------------------------------------*
8      FORM VENDOR_ARRAY_READ.
9        DATA:
10         ls_lfa1_key TYPE lfa1_key,
11         lt_lfa1_key TYPE TABLE OF lfa1_key.
12
13       FIELD-SYMBOLS:
14         <ls_ban> LIKE LINE OF ban.
15
16       LOOP AT ban ASSIGNING <ls_ban> WHERE lifnr IS NOT INITIAL
17                                         OR flief IS NOT INITIAL.
18
19          IF <ls_ban>-lifnr IS NOT INITIAL.
20            ls_lfa1_key-lifnr = <ls_ban>-lifnr.
21          ELSE.
22            ls_lfa1_key-lifnr = <ls_ban>-flief.
23          ENDIF.
24          APPEND ls_lfa1_key TO lt_lfa1_key.
25
26       ENDLOOP.
27
28       CALL FUNCTION 'WY_LFA1_ARRAY_READ'
29     *   EXPORTING
30     *     REFRESH_BUFFER                 =
31     *     PI_READ_CAM                    =
32         TABLES
33           PTI_LFA1_KEYTAB                = lt_lfa1_key
34     *     PTO_LFA1                       =
35     *     PTO_ADDRESS_VALUES             =
36         EXCEPTIONS
37           ERR_NO_RECORDS_REQUESTED       = 1
38           ERR_NO_RECORDS_FOUND           = 2
39           INTERNAL_ERROR                 = 3
40           OTHERS                         = 4
41                 .
42       IF SY-SUBRC <> 0.
43     * Implement suitable error handling here
44       ENDIF.
45
46     ENDFORM.                    " VENDOR_ARRAY_READ
*--- End of FM06BFSL_VENDOR_ARRAY_READ - 46 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFSL_OPT_AUT_BAN_XML                  Level 2    Page 251
Object           SAPMZFM06B                                Lines 27
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&      Form  AUT_EXPORT_RESULTS_XML_TO_MEM
3      *&---------------------------------------------------------------------*
4      *       export results (internal table BAN) to shared memory
5      *       in case of ABAP UNIT TEST run
6      *----------------------------------------------------------------------*
7      *      --> IV_MEM_ID : memory ID where the result is to be exported
8      *----------------------------------------------------------------------*
9      FORM aut_export_results_xml_to_mem USING iv_mem_id TYPE memory_id.
10
11       DATA: lv_xml TYPE string.
12
13       CALL FUNCTION 'EC_UTIL_ABAP_2_XML'
14         EXPORTING
15           i_direction = 'I'
16         CHANGING
17           ct_table    = ban[]
18           c_xml_str   = lv_xml.
19
20       CALL METHOD cl_mm_pur_aut_master=>export_memory
21         EXPORTING
22           iv_mem_id       = iv_mem_id
23           iv_check_mem_id = abap_true
24           it_result       = lv_xml.
25
26
27     ENDFORM.              " AUT_EXPORT_RESULTS_XML_TO_MEM
*--- End of FM06BFSL_OPT_AUT_BAN_XML - 27 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFOI                                  Level 1    Page 252
Object           SAPMZFM06B                                Lines 25
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1        INCLUDE FM06BFOI_OIH_TDP_DEFAULT .  " OIH_TDP_DEFAULT
2
3        INCLUDE FM06BFOI_POPULATE_TDP .  " POPULATE_TDP
4
5        INCLUDE FM06BFOI_READ_INFO_2 .  " READ_INFO_2
6        INCLUDE FM06BFOI_DEF_VAL_HANTYP .  " DEF_VAL_HANTYP
7
8        INCLUDE FM06BFOI_MARC_LOOKUP .  " MARC_LOOKUP
9
10       INCLUDE FM06BFOI_HANTYP_VALIDATION .  " HANTYP_VALIDATION
11       INCLUDE FM06BFOI_INFO_REC_DEFAULT .  " INFO_REC_DEFAULT
12       INCLUDE FM06BFOI_VENDOR_HANTYP_LOOKUP .  " VENDOR_HANTYP_LOOKUP
13
14       INCLUDE FM06BFOI_VENDOR_DEFAULT .  " VENDOR_DEFAULT
15
16       INCLUDE FM06BFOI_OIH08_DEFAULT .  " OIH08_DEFAULT
17       INCLUDE FM06BFOI_VAL_INEX_DEFAULT .  " VAL_INEX_DEFAULT
18
19       INCLUDE FM06BFOI_INFO_RECORD_DEFAULT .  " INFO_RECORD_DEFAULT
20
21       INCLUDE FM06BFOI_OI001_DEFAULT .  " OI001_DEFAULT
22
23       INCLUDE FM06BFOI_VAL_INEX .  " VAL_INEX
24
25       INCLUDE FM06BFOI_DEF_VAL_TYPE .  " DEF_VAL_TYPE
*--- End of FM06BFOI - 25 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFOI_OIH_TDP_DEFAULT                  Level 2    Page 253
Object           SAPMZFM06B                                Lines 35
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *-------------------------------------------------------------------
2      ***INCLUDE FM06BFOI .
3      *-------------------------------------------------------------------
4      *&---------------------------------------------------------------------*
5      *&      Form  OIH_TDP_DEFAULT
6      *&---------------------------------------------------------------------*
7      FORM OIH_TDP_DEFAULT.
8
9        CHECK NOT EBAN-OITAXGRP IS INITIAL.                     "1789149
10
11       IF BAN-FLIEF NE SPACE.
12     *-- Populate IS-Oil working variables
13         PERFORM POPULATE_TDP.
14
15     *-- Retrieve Handl. Type and Price Ind. form Info Rec
16         IF BAN-OIHANTYP EQ SPACE OR BAN-OIINEX EQ SPACE.
17           PERFORM READ_INFO_2.
18         ENDIF.
19
20     *-- Defaulting/Validation of Handling Type & ED Status
21         PERFORM DEF_VAL_HANTYP.
22
23     *-- Validation of Price Indicator
24         IF BAN-OIINEX EQ SPACE.
25            PERFORM VAL_INEX_DEFAULT.
26         ENDIF.
27          PERFORM VAL_INEX.
28
29     *-- Default Validation Type
30          PERFORM DEF_VAL_TYPE.
31       ELSE.
32         CLEAR: BAN-OIHANTYP, BAN-OIINEX, BAN-OITAXFROM.
33       ENDIF.
34
35     ENDFORM.                    " OIH_TDP_DEFAULT
*--- End of FM06BFOI_OIH_TDP_DEFAULT - 35 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFOI_POPULATE_TDP                     Level 2    Page 254
Object           SAPMZFM06B                                Lines 26
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&      Form  POPULATE_TDP
3      *&---------------------------------------------------------------------*
4      FORM POPULATE_TDP.
5
6         G_EBELP  = BAN-EBELP.
7         G_MATNR  = BAN-MATNR.
8         G_WERKS  = BAN-WERKS.
9         G_HANTYP = BAN-OIHANTYP.
10        G_INEX   = BAN-OIINEX.
11
12        SELECT SINGLE * FROM T024E
13                        WHERE EKORG = BAN-EKORG.
14        MOVE: T024E-BUKRS TO G_BUKRS.
15        IF G_BUKRS IS INITIAL.
16           IF NOT BAN-KONNR IS INITIAL.
17              SELECT SINGLE * FROM EKKO WHERE EBELN EQ BAN-KONNR.
18              MOVE EKKO-BUKRS TO G_BUKRS.
19              else.
20              if not ban-bukrs is initial.
21                 move ban-bukrs to g_bukrs.
22              else.
23              endif.
24           ENDIF.
25        ENDIF.
26     ENDFORM.                    " POPULATE_TDP
*--- End of FM06BFOI_POPULATE_TDP - 26 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFOI_READ_INFO_2                      Level 2    Page 255
Object           SAPMZFM06B                                Lines 45
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&      Form  READ_INFO_2
3      *&---------------------------------------------------------------------*
4      FORM READ_INFO_2.
5
6      *-- Relevant Item Category chosen for reading Info Record
7        IF BAN-PSTYP EQ PSTYP-LOHN.
8          H-ESOKZ = ESOKZ-LOHN.
9        ELSE.
10         H-ESOKZ = ESOKZ-NORM.
11       ENDIF.
12
13       CLEAR OIH_EINE.
14
15     *-- Read Info Record of item
16       SELECT * FROM EINA
17                          up to 1 rows          "up to 10xFaster KH 06.2000
18                          WHERE LIFNR = BAN-FLIEF    AND
19                                MATNR = BAN-MATNR.
20     *upto1 MOVE EINA-INFNR TO G_INFNR.
21     *upto1 EXIT.
22       ENDSELECT.
23       if sy-subrc eq 0.                        "up to 1 KH
24         MOVE EINA-INFNR TO G_INFNR.            "up to 1 KH
25       endif.                                   "up to 1 KH
26
27       SELECT SINGLE * FROM EINE INTO OIH_EINE
28                                 WHERE INFNR = G_INFNR     AND
29                                       EKORG = BAN-EKORG   AND
30                                       ESOKZ = H-ESOKZ     AND
31                                       WERKS = BAN-WERKS.
32
33       IF SY-SUBRC NE 0.
34         SELECT SINGLE * FROM EINE INTO OIH_EINE
35                                   WHERE INFNR = G_INFNR     AND
36                                         EKORG = BAN-EKORG  AND
37                                         ESOKZ = H-ESOKZ     AND
38                                         WERKS = SPACE.
39       ENDIF.
40
41       MOVE: OIH_EINE-OIHANTYP  TO  G_INF_HAN,
42             OIH_EINE-BWTAR     TO  G_INF_BWTAR,
43             OIH_EINE-OIINEX    TO  G_INF_INEX.
44
45     ENDFORM.                    " READ_INFO_2
*--- End of FM06BFOI_READ_INFO_2 - 45 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFOI_DEF_VAL_HANTYP                   Level 2    Page 256
Object           SAPMZFM06B                                Lines 60
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&      Form  DEF_VAL_HANTYP
3      *&---------------------------------------------------------------------*
4      FORM DEF_VAL_HANTYP.
5
6      * Check Vendor has been allocated
7        CHECK BAN-FLIEF NE SPACE.
8
9      *  if mt06e-oitaxgrp ne space.
10        PERFORM MARC_LOOKUP.
11        IF G_TAXGRP NE SPACE.
12
13         MOVE: G_OILCON        TO  BAN-OIOILCON,
14               G_TAXGRP        TO  BAN-OITAXGRP,
15               G_BUKRS         TO  OIH_STCT-BUKRS,
16               G_WERKS         TO  OIH_STCT-WERKS,
17               G_HANTYP        TO  OIH_STCT-HANTYP.
18
19     *-- Validate Handling Type if entered
20         IF G_HANTYP NE SPACE.
21           PERFORM HANTYP_VALIDATION.
22         ELSE.
23     *-- Han Type defaulted from Info Rec if value exists
24           IF G_INF_HAN NE SPACE.
25             PERFORM INFO_REC_DEFAULT.
26           ELSE.
27
28     *-- Check if handling type exists on the Vendor Master
29              PERFORM VENDOR_HANTYP_LOOKUP.
30
31     *-- Han Type defaulted from Vendor Master if value exists
32             IF G_VEN_HAN NE SPACE.
33                PERFORM VENDOR_DEFAULT.
34             ELSE.
35               MOVE: G_BUKRS    TO OIH_STCTX-BUKRS,
36                     G_WERKS    TO OIH_STCTX-WERKS,
37                     BAN-BSART  TO OIH_STCTX-BSART.
38               PERFORM LOOKUP_OIH08(SAPFOIH2) USING OIH_STCTX.
39     *-- Hand Type defaulted from OIH08 if value exists
40               IF OIH_STCTX-HANTYP NE SPACE.
41                  PERFORM OIH08_DEFAULT.
42               ELSE.
43     *-- Hand Type mandatory if dutiable material
44                 CLEAR: BAN-OIHANTYP, BAN-OITAXFROM, BAN-BWTAR.
45                 MESSAGE E011(OB).
46               ENDIF.
47             ENDIF.
48           ENDIF.
49         ENDIF.
50       ELSE.
51     *-- Hand Type not maintained for non-dutiable materials
52         IF G_HANTYP NE SPACE.
53           CLEAR: EKPO-OIHANTYP, EKPO-OITAXFROM, EKPO-BWTAR,
54                  EKPO-OIOILCON, EKPO-OITAXGRP.
55     *     message w010(ob).
56         ENDIF.
57       ENDIF.
58
59
60     ENDFORM.                    " DEF_VAL_HANTYP
*--- End of FM06BFOI_DEF_VAL_HANTYP - 60 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFOI_MARC_LOOKUP                      Level 2    Page 257
Object           SAPMZFM06B                                Lines 31
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&      Form  MARC_LOOKUP
3      *&---------------------------------------------------------------------*
4      FORM marc_lookup.
5
6        IF g_matnr NE space.
7      **  CLEAR OIH_MARC.                                         "del   KH5
8      **  SELECT SINGLE * FROM MARC INTO OIH_MARC                   "
9      **                  WHERE MATNR = G_MATNR                     "
10     **                  AND   WERKS = G_WERKS.                    "
11     *   Substitute single read by buffer read (so6k0013676)     begin  KH5
12         IF oih_marc_md-matnr NE g_matnr
13         OR oih_marc_md-werks NE g_werks.
14     *   clear not necessary; if RAISE then WA is initial
15     * MMACCESS_2015W1_ADJUSTED
16           CALL FUNCTION 'MARC_MD_SINGLE_READ'
17             EXPORTING
18               matnr    = g_matnr
19               werks    = g_werks
20             IMPORTING
21               wmarc_md = oih_marc_md
22             EXCEPTIONS
23               OTHERS   = 0.         "RC not used
24
25         ENDIF.                                                 "end    KH5
26
27         MOVE: oih_marc_md-oitaxgrp TO g_taxgrp,
28               oih_marc_md-oioilcon TO g_oilcon.
29       ENDIF.
30
31     ENDFORM.                    " MARC_LOOKUP
*--- End of FM06BFOI_MARC_LOOKUP - 31 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFOI_HANTYP_VALIDATION                Level 2    Page 258
Object           SAPMZFM06B                                Lines 43
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&      Form  HANTYP_VALIDATION
3      *&---------------------------------------------------------------------*
4      FORM HANTYP_VALIDATION.
5        MOVE   BAN-BWTAR TO G_DEF_BWTAR.
6
7        CLEAR: BAN-OITAXFROM,
8               BAN-BWTAR.
9
10     *-- Hand Type validated, Tax From & Val Type derived
11       PERFORM LOOKUP_OIH10(SAPFOIH2) USING OIH_STCT.
12
13       MOVE: OIH_STCT-HANTYP TO BAN-OIHANTYP,
14             OIH_STCT-TAXKEY TO BAN-OITAXFROM.
15     * default valuation type from p/o default table
16       MOVE: G_BUKRS         TO  OIH_STCTX-BUKRS,
17             G_WERKS         TO  OIH_STCTX-WERKS,
18             BAN-BSART       TO  OIH_STCTX-BSART.
19     * Val Type derived
20       PERFORM LOOKUP_OIH08(SAPFOIH2) USING OIH_STCTX.
21
22       IF NOT OIH_STCTX-BWTAR IS INITIAL AND
23          G_DEF_BWTAR     IS INITIAL.
24          MOVE: OIH_STCTX-BWTAR TO G_DEF_BWTAR.
25       ENDIF.
26
27     *-- Warning when Plant changed and defaulted HT is unchanged
28     * if g_werks   ne  g_werksx and
29     *    g_hantyp  eq  g_hantypx and
30     *    g_def_flg ca  g_def_plt.
31     *   g_def_flg =   'N'.
32     *   message w017(ob) with oih_stct-hantyp.
33     * endif.
34
35     *-- Warning when Material changed and defaulted HT is unchanged
36     * if g_matnr   ne  g_matnrx  and
37     *    g_hantyp  eq  g_hantypx and
38     *    g_def_flg ca  g_def_mat.
39     *   g_def_flg =   'N'.
40     *   message w041(ob) with oih_stct-hantyp.
41     * endif.
42
43     ENDFORM.                    " HANTYP_VALIDATION
*--- End of FM06BFOI_HANTYP_VALIDATION - 43 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFOI_INFO_REC_DEFAULT                 Level 2    Page 259
Object           SAPMZFM06B                                Lines 32
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&      Form  INFO_REC_DEFAULT
3      *&---------------------------------------------------------------------*
4      FORM INFO_REC_DEFAULT.
5
6        MOVE: G_INF_HAN  TO  BAN-OIHANTYP,
7              G_INF_HAN  TO  OIH_STCT-HANTYP.
8      *       g_inf_han  to  g_hantypx,
9      *       g_werks    to  g_werksx,
10     *       g_matnr    to  g_matnrx,
11     *       eban-ebelp to  g_ebelpx.
12
13     *-- Hand Type validated, Tax From & Val Type derived
14       PERFORM LOOKUP_OIH10(SAPFOIH2) USING OIH_STCT.
15
16       MOVE: OIH_STCT-TAXKEY TO BAN-OITAXFROM.
17     *       oih_stct-bwtar  to g_def_bwtar.
18     * default valuation type from p/o default table
19       MOVE: G_BUKRS         TO  OIH_STCTX-BUKRS,
20             G_WERKS         TO  OIH_STCTX-WERKS,
21             BAN-BSART       TO  OIH_STCTX-BSART.
22     * Val Type derived
23       PERFORM LOOKUP_OIH08(SAPFOIH2) USING OIH_STCTX.
24       MOVE: OIH_STCTX-BWTAR TO G_DEF_BWTAR.
25
26     *-- Flag indicating Hand Type is a default value from Info Record
27     * g_def_flg = 'I'.
28
29     * write text-oi1 to g_def_source_1.
30     * message w009(ob) with oih_stct-hantyp g_def_source_1.
31
32     ENDFORM.                    " INFO_REC_DEFAULT
*--- End of FM06BFOI_INFO_REC_DEFAULT - 32 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFOI_VENDOR_HANTYP_LOOKUP             Level 2    Page 260
Object           SAPMZFM06B                                Lines 20
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&      Form  VENDOR_HANTYP_LOOKUP
3      *&---------------------------------------------------------------------*
4      FORM VENDOR_HANTYP_LOOKUP.
5
6      * SELECT SINGLE * FROM LFM1 WHERE LIFNR = BAN-FLIEF       "SOCK001174 cp
7      *                           AND   EKORG = BAN-EKORG.
8      * Substitute single read by buffer read (so6k0013676)       begin  KH5
9        if lfm1-lifnr ne ban-flief
10       or lfm1-ekorg ne ban-ekorg.
11       CALL FUNCTION 'LFM1_SINGLE_READ'
12          EXPORTING I_LIFNR            = BAN-FLIEF
13                    I_EKORG            = BAN-EKORG
14          IMPORTING O_LFM1             = lfm1
15          EXCEPTIONS OTHERS            = 0.         "RC not used
16       endif.                                                   "end    KH5
17
18       MOVE LFM1-OIHANTYP TO G_VEN_HAN.
19
20     ENDFORM.                    " VENDOR_HANTYP_LOOKUP
*--- End of FM06BFOI_VENDOR_HANTYP_LOOKUP - 20 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFOI_VENDOR_DEFAULT                   Level 2    Page 261
Object           SAPMZFM06B                                Lines 31
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&      Form  VENDOR_DEFAULT
3      *&---------------------------------------------------------------------*
4      FORM VENDOR_DEFAULT.
5
6        MOVE: G_VEN_HAN  TO  BAN-OIHANTYP,
7              G_VEN_HAN  TO  OIH_STCT-HANTYP.
8      *       g_ven_han  to  g_hantypx,
9      *       g_werks    to  g_werksx,
10     *       g_matnr    to  g_matnrx,
11     *       eban-ebelp to  g_ebelpx.
12
13     *-- Hand Type validated, Tax From & Val Type derived
14       PERFORM LOOKUP_OIH10(SAPFOIH2) USING OIH_STCT.
15
16       MOVE: OIH_STCT-TAXKEY TO BAN-OITAXFROM.
17     *       oih_stct-bwtar  to g_def_bwtar.
18     * default valuation type from p/o default table
19       MOVE: G_BUKRS         TO  OIH_STCTX-BUKRS,
20             G_WERKS         TO  OIH_STCTX-WERKS,
21             BAN-BSART       TO  OIH_STCTX-BSART.
22     *       Hand Type validated, Tax From & Val Type derived
23       PERFORM LOOKUP_OIH08(SAPFOIH2) USING OIH_STCTX.
24       MOVE: OIH_STCTX-BWTAR TO G_DEF_BWTAR.
25
26     *-- Flag indicating Hand Type is a default value
27     * g_def_flg = 'V'.
28
29     * write text-oi2 to g_def_source_2.
30     * message w009(ob) with oih_stct-hantyp g_def_source_2.
31     ENDFORM.                    " VENDOR_DEFAULT
*--- End of FM06BFOI_VENDOR_DEFAULT - 31 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFOI_OIH08_DEFAULT                    Level 2    Page 262
Object           SAPMZFM06B                                Lines 32
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&      Form  OIH08_DEFAULT
3      *&---------------------------------------------------------------------*
4      FORM OIH08_DEFAULT.
5
6        MOVE: OIH_STCTX-HANTYP  TO  BAN-OIHANTYP,
7              OIH_STCTX-HANTYP  TO  OIH_STCT-HANTYP.
8      *       oih_stctx-hantyp  to  g_hantypx,
9      *       g_werks           to  g_werksx,
10     *       g_matnr           to  g_matnrx,
11     *       ekpo-ebelp        to  g_ebelpx.
12
13     *-- Hand Type validated, Tax From & Val Type derived
14       PERFORM LOOKUP_OIH10(SAPFOIH2) USING OIH_STCT.
15
16       MOVE: OIH_STCT-TAXKEY TO BAN-OITAXFROM.
17     *       oih_stct-bwtar  to g_def_bwtar.
18     * default valuation type from p/o default table
19       MOVE: G_BUKRS         TO  OIH_STCTX-BUKRS,
20             G_WERKS         TO  OIH_STCTX-WERKS,
21             BAN-BSART      TO  OIH_STCTX-BSART.
22     *       Hand Type validated, Tax From & Val Type derived
23       PERFORM LOOKUP_OIH08(SAPFOIH2) USING OIH_STCTX.
24       MOVE: OIH_STCTX-BWTAR TO G_DEF_BWTAR.
25
26     *-- Flag indicating Hand Type is a default value
27     * g_def_flg = 'T'.
28
29     * write text-oi3 to g_def_source_3.
30     * message w009(ob) with oih_stct-hantyp g_def_source_3.
31
32     ENDFORM.                    " OIH08_DEFAULT
*--- End of FM06BFOI_OIH08_DEFAULT - 32 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFOI_VAL_INEX_DEFAULT                 Level 2    Page 263
Object           SAPMZFM06B                                Lines 37
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&      Form  VAL_INEX_DEFAULT
3      *&---------------------------------------------------------------------*
4      FORM VAL_INEX_DEFAULT.
5
6        IF BAN-OITAXGRP NE SPACE.
7          MOVE BAN-OITAXFROM TO OIH_STCTY-TAXKEY.
8
9      *-- Derive 'Tax' Status of ED Status
10         PERFORM LOOKUP_OIH4(SAPFOIH2) USING OIH_STCTY.
11
12     *-- Price indicator defaulted from Info Rec if value exists.
13         IF G_INEX EQ SPACE.
14           IF OIH_STCTY-INDTAX NE SPACE.
15             IF G_INF_INEX NE SPACE.
16               PERFORM INFO_RECORD_DEFAULT.
17             ELSE.
18     *-- Price indicator defaulted from table oi001 if value exists.
19               IF T001K-BUKRS IS INITIAL.
20                  SELECT SINGLE * FROM T001W WHERE WERKS = BAN-WERKS.
21                  IF SY-SUBRC EQ 0.
22                    SELECT SINGLE * FROM T001K WHERE BWKEY = T001W-BWKEY.
23                  ENDIF.
24               ENDIF.
25               MOVE T001K-BUKRS TO OIH_STCTU-BUKRS.
26               if oi001 is initial or
27                  oi001-bukrs ne OIh_STCTu-BUKRS.
28                  PERFORM LOOKUP_OI001(SAPFOIH2) USING OIH_STCTU.
29               endif.
30               IF OIH_STCTU-INEXPO NE SPACE.
31                 PERFORM OI001_DEFAULT.
32               ENDIF.
33             ENDIF.
34           ENDIF.
35         ENDIF.
36       ENDIF.
37     ENDFORM.                    " VAL_INEX_DEFAULT
*--- End of FM06BFOI_VAL_INEX_DEFAULT - 37 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFOI_INFO_RECORD_DEFAULT              Level 2    Page 264
Object           SAPMZFM06B                                Lines 15
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&      Form  INFO_RECORD_DEFAULT
3      *&---------------------------------------------------------------------*
4      FORM INFO_RECORD_DEFAULT.
5
6        MOVE:  G_INF_INEX TO BAN-OIINEX,
7               G_INF_INEX TO G_INEX.
8
9      *-- Flag indicating Price Ind is a default value from Info Record
10     * g_def_flg = 'I'.
11
12     * write text-oi1 to g_def_source_1.
13     * message w076(ob) with g_inf_inex g_def_source_1.
14
15     ENDFORM.                    " INFO_RECORD_DEFAULT
*--- End of FM06BFOI_INFO_RECORD_DEFAULT - 15 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFOI_OI001_DEFAULT                    Level 2    Page 265
Object           SAPMZFM06B                                Lines 15
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&      Form  OI001_DEFAULT
3      *&---------------------------------------------------------------------*
4      FORM OI001_DEFAULT.
5
6        MOVE: OIH_STCTU-INEXPO TO BAN-OIINEX,
7              OIH_STCTU-INEXPO  TO G_INEX.
8
9      *-- Flag indicating Hand Type is a default value
10     * g_def_flg = 'T'.
11
12     * write text-oi4 to g_def_source_4.
13     * message w076(ob) with oih_stctu-inexpo g_def_source_4.
14
15     ENDFORM.                    " OI001_DEFAULT
*--- End of FM06BFOI_OI001_DEFAULT - 15 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFOI_VAL_INEX                         Level 2    Page 266
Object           SAPMZFM06B                                Lines 39
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&      Form  VAL_INEX
3      *&---------------------------------------------------------------------*
4      FORM VAL_INEX.
5
6        IF BAN-OITAXGRP NE SPACE.
7          MOVE BAN-OITAXFROM TO OIH_STCTY-TAXKEY.
8
9      *-- Derive 'Tax' Status of ED Status
10         PERFORM LOOKUP_OIH4(SAPFOIH2) USING OIH_STCTY.
11
12     *-- 1
13         IF G_INEX NE SPACE AND OIH_STCTY-INDTAX EQ SPACE.
14           CLEAR  BAN-OIINEX.
15           MESSAGE W035(OB).
16         ENDIF.
17
18     *-- 2
19         IF G_INEX EQ SPACE AND OIH_STCTY-INDTAX EQ 'X'.
20           MESSAGE E036(OB).
21         ENDIF.
22
23     *-- 3
24         IF G_INEX NE SPACE AND OIH_STCTY-INDTAX EQ 'X'.
25           MOVE BAN-OIINEX TO OIH_STCTZ-INEX.
26           PERFORM LOOKUP_OIH16(SAPFOIH2) USING OIH_STCTZ.
27           MOVE OIH_STCTZ-PRICIE TO BAN-OIPRICIE.
28         ENDIF.
29
30       ELSE.
31
32     *-- PRICE INDICATOR NOT MAINTAINED FOR NON-DUTIABLE MATERIALS
33         IF G_INEX NE SPACE.
34           CLEAR  BAN-OIINEX.
35           MESSAGE W034(OB).
36         ENDIF.
37
38       ENDIF.
39     ENDFORM.                    " VAL_INEX
*--- End of FM06BFOI_VAL_INEX - 39 lines ---

----------------------------------------------------------------------------------------------------
Include          FM06BFOI_DEF_VAL_TYPE                     Level 2    Page 267
Object           SAPMZFM06B                                Lines 18
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------
2      *&      FORM  DEF_VAL_TYPE
3      *&---------------------------------------------------------------------
4      FORM DEF_VAL_TYPE.
5
6      *-- DEFAULT VALUATION TYPE
7        IF G_INF_BWTAR NE SPACE.
8          MOVE G_INF_BWTAR TO BAN-BWTAR.
9        ELSEIF G_DEF_BWTAR NE SPACE.
10         MOVE G_DEF_BWTAR TO BAN-BWTAR.
11       ENDIF.
12
13       CLEAR: G_INF_BWTAR, G_DEF_BWTAR.
14
15     *-- Set table to read in SAPMM06E for PO for vendor unknown
16       MOVE 'EBAN' TO TDP_FLAG.
17
18     ENDFORM.                    " DEF_VAL_TYPE
*--- End of FM06BFOI_DEF_VAL_TYPE - 18 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CABAP                                   Level 1    Page 268
Object           SAPMZFM06B                                Lines 360
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      type-pool ABAP .
2
3
4      ************************************************************************
5      * WARNING!!!!! DO NOT CHANGE ANY OF THE FOLLOWING TYPES! WARNING !!!!! *
6      * !!!!!!!! All types have to synchronized with ABAP kernel types !!!!! *
7      ************************************************************************
8
9      ************************************************************************
10     * NAMES WITH PREFIX "ABAP_" DECLARED IN THE DDIC
11     * MUST NOT BE REDEFINED HERE!
12     ************************************************************************
13     * abap_encod
14     * abap_endia
15     * abap_repl
16
17     ************************************************************************
18     **** GENERAL ***********************************************************
19     types:
20       ABAP_BOOL type C length 1.
21     * constants for abap_bool
22     constants:
23       ABAP_TRUE      type ABAP_BOOL value 'X',
24       ABAP_FALSE     type ABAP_BOOL value ' ',
25       ABAP_UNDEFINED type ABAP_BOOL value '-',
26       ABAP_ON        type ABAP_BOOL value 'X',
27       ABAP_OFF       type ABAP_BOOL value ' '.
28
29
30     ************************************************************************
31     **** DESCRIBE   ********************************************************
32     constants:
33       ABAP_MAX_ABS_TYPE_NAME_LN   type I value        200,
34       ABAP_MAX_CLASS_NAME_LN      type I value         30,
35       ABAP_MAX_INTF_NAME_LN       type I value         30,
36       ABAP_MAX_COMP_NAME_LN       type I value         30,
37       ABAP_MAX_KEY_NAME_LN        type I value        255,
38       ABAP_MAX_CLASS_COMP_NAME_LN type I value         61,
39       ABAP_MAX_EDIT_MASK_LN       type I value          7,
40       ABAP_MAX_HELP_ID_LN         type I value         62,
41       ABAP_MAX_DB_STRING_LN       type I value  536870912,
42       ABAP_MAX_DB_RAWSTRING_LN    type I value 1073741824.
43
44
45
46     types:
47     * type kinds
48       ABAP_TYPEKIND     type C length 1, " check CL_ABAP_TYPEDESCR for values
49       ABAP_TYPECATEGORY type C length 1, " check CL_ABAP_TYPEDESCR for values
50       ABAP_TYPEPROPKIND type C length 1,
51       ABAP_STRUCTKIND   type C length 1,
52       ABAP_TABLEKIND    type C length 1,
53       ABAP_KEYDEFKIND   type C length 1,
54       ABAP_CLASSKIND    type C length 1,
55       ABAP_INTFKIND     type C length 1,
56       ABAP_PARMKIND     type C length 1,
57     * misc
58       ABAP_EDITMASK     type C length ABAP_MAX_EDIT_MASK_LN,
59       ABAP_HELPID       type C length ABAP_MAX_HELP_ID_LN,
60       ABAP_VISIBILITY   type C length 1,
61     * name types
62       ABAP_TYPENAME     type C length ABAP_MAX_CLASS_COMP_NAME_LN,
63       ABAP_ABSTYPENAME  type C length ABAP_MAX_ABS_TYPE_NAME_LN,
64       ABAP_COMPNAME     type C length ABAP_MAX_COMP_NAME_LN,
65       ABAP_KEYNAME      type C length ABAP_MAX_KEY_NAME_LN,
66       ABAP_KEYCOMPNAME  type          ABAP_KEYNAME,
67       ABAP_CLASSNAME    type C length ABAP_MAX_CLASS_NAME_LN,
68       ABAP_INTFNAME     type C length ABAP_MAX_INTF_NAME_LN,
69       ABAP_ATTRNAME     type C length ABAP_MAX_CLASS_COMP_NAME_LN,
70       ABAP_METHNAME     type C length ABAP_MAX_CLASS_COMP_NAME_LN,
71       ABAP_EVNTNAME     type C length ABAP_MAX_CLASS_COMP_NAME_LN,
72       ABAP_PARMNAME     type C length ABAP_MAX_COMP_NAME_LN,
73       ABAP_EXCPNAME     type C length ABAP_MAX_COMP_NAME_LN,
74     * structure component description
75       begin of ABAP_COMPDESCR,
76         LENGTH    type I,
77         DECIMALS  type I,
78         TYPE_KIND type ABAP_TYPEKIND,
79         NAME      type ABAP_COMPNAME,
80       end of ABAP_COMPDESCR,
81       ABAP_COMPDESCR_TAB type standard table of ABAP_COMPDESCR
82                          with key NAME,
83       begin of ABAP_COMPONENTDESCR,
84         NAME       type STRING,
85         TYPE       type ref to CL_ABAP_DATADESCR,
86         AS_INCLUDE type ABAP_BOOL,
87         SUFFIX     type STRING,
88       end of ABAP_COMPONENTDESCR,
89       ABAP_COMPONENT_TAB type standard table of ABAP_COMPONENTDESCR
90                          with key NAME,
91       begin of ABAP_SIMPLE_COMPONENTDESCR,
92         NAME type STRING,
93         TYPE type ref to CL_ABAP_DATADESCR,
94       end of ABAP_SIMPLE_COMPONENTDESCR,
95       ABAP_COMPONENT_SYMBOL_TAB type hashed table of ABAP_SIMPLE_COMPONENTDESCR
96                                 with unique key NAME,
97       ABAP_COMPONENT_VIEW_TAB   type standard table of ABAP_SIMPLE_COMPONENTDESCR
98                               with key NAME,
99     * key description of tables
100      begin of ABAP_KEYDESCR,
101        NAME type ABAP_KEYNAME,
102      end of ABAP_KEYDESCR,
103      ABAP_KEYDESCR_TAB type standard table of ABAP_KEYDESCR
104                        with key NAME,
105    * description of all secondary keys and primary key of tables
106      begin of ABAP_TABLE_KEYCOMPDESCR,
107        NAME type ABAP_KEYCOMPNAME,
108      end of ABAP_TABLE_KEYCOMPDESCR,
109      begin of ABAP_TABLE_KEYDESCR,
110        COMPONENTS  type standard table of ABAP_TABLE_KEYCOMPDESCR
111                             with non-unique default key
112                             initial size 4,
113        NAME        type ABAP_COMPNAME,
114        IS_PRIMARY  type ABAP_BOOL,
115        ACCESS_KIND type ABAP_TABLEKIND,
116        IS_UNIQUE   type ABAP_BOOL,
117        KEY_KIND    type ABAP_KEYDEFKIND,
118      end of ABAP_TABLE_KEYDESCR,
119      ABAP_TABLE_KEYDESCR_TAB type standard table of ABAP_TABLE_KEYDESCR
120                              with non-unique key NAME
121                              initial size 2,
122    * map for mapping table key names to table key aliases
123      begin of ABAP_KEY_ALIAS_PAIR,
124        NAME  type ABAP_COMPNAME,
125        ALIAS type ABAP_COMPNAME,
126      end of ABAP_KEY_ALIAS_PAIR,
127      ABAP_KEY_ALIAS_MAP type sorted table of ABAP_KEY_ALIAS_PAIR
128                              with non-unique key NAME
129                              with unique sorted key KEY_ALIAS components ALIAS
130                              initial size 2,
131    * parameter description (methods and event)
132      begin of ABAP_PARMDESCR,
133        LENGTH      type I,
134        DECIMALS    type I,
135        TYPE_KIND   type ABAP_TYPEKIND,
136        NAME        type ABAP_PARMNAME,
137        PARM_KIND   type ABAP_PARMKIND,
138        BY_VALUE    type ABAP_BOOL,
139        IS_OPTIONAL type ABAP_BOOL,
140      end of ABAP_PARMDESCR,
141      ABAP_PARMDESCR_TAB type standard table of ABAP_PARMDESCR
142                         with key NAME,
143    * exception description (method and event)
144      begin of ABAP_EXCPDESCR,
145        NAME         type ABAP_EXCPNAME,
146        IS_RESUMABLE type ABAP_BOOL, "abap_false for old exceptions,
147        "abap_true or abap_false for class based exceptions
148      end of ABAP_EXCPDESCR,
149      ABAP_EXCPDESCR_TAB type standard table of ABAP_EXCPDESCR
150                         with key NAME,
151    * exposed and access friend description
152      begin of ABAP_FRNDDESCR,
153        NAME type ABAP_CLASSNAME,
154      end of ABAP_FRNDDESCR,
155      ABAP_FRNDDESCR_TAB type standard table of ABAP_FRNDDESCR
156                         with key NAME,
157    * included interfaces / interface implementation description
158      begin of ABAP_INTFDESCR,
159        NAME         type ABAP_INTFNAME,
160        IS_INHERITED type ABAP_BOOL,
161      end of ABAP_INTFDESCR,
162      ABAP_INTFDESCR_TAB type standard table of ABAP_INTFDESCR
163                         with key NAME,
164    * type definition inside class / interface
165      begin of ABAP_TYPEDEF,
166        NAME         type ABAP_TYPENAME,
167        ALIAS_FOR    type ABAP_TYPENAME,
168        VISIBILITY   type ABAP_VISIBILITY,
169        IS_INTERFACE type ABAP_BOOL,
170        IS_INHERITED type ABAP_BOOL,
171      end of ABAP_TYPEDEF,
172      ABAP_TYPEDEF_TAB type standard table of ABAP_TYPEDEF
173                         with key NAME,
174    * attribute description
175      begin of ABAP_ATTRDESCR,
176        LENGTH       type I,
177        DECIMALS     type I,
178        NAME         type ABAP_ATTRNAME,
179        TYPE_KIND    type ABAP_TYPEKIND,
180        VISIBILITY   type ABAP_VISIBILITY,
181        IS_INTERFACE type ABAP_BOOL,
182        IS_INHERITED type ABAP_BOOL,
183        IS_CLASS     type ABAP_BOOL,
184        IS_CONSTANT  type ABAP_BOOL,
185        IS_VIRTUAL   type ABAP_BOOL,
186        IS_READ_ONLY type ABAP_BOOL,
187        ALIAS_FOR    type ABAP_ATTRNAME,
188      end of ABAP_ATTRDESCR,
189      ABAP_ATTRDESCR_TAB type standard table of ABAP_ATTRDESCR
190                         with key NAME,
191    * method description
192      begin of ABAP_METHDESCR,
193        PARAMETERS       type ABAP_PARMDESCR_TAB,
194        EXCEPTIONS       type ABAP_EXCPDESCR_TAB,
195        NAME             type ABAP_METHNAME,
196        FOR_EVENT        type ABAP_EVNTNAME,
197        OF_CLASS         type ABAP_CLASSNAME,
198        VISIBILITY       type ABAP_VISIBILITY,
199        IS_INTERFACE     type ABAP_BOOL,
200        IS_INHERITED     type ABAP_BOOL,
201        IS_REDEFINED     type ABAP_BOOL,
202        IS_ABSTRACT      type ABAP_BOOL,
203        IS_FINAL         type ABAP_BOOL,
204        IS_CLASS         type ABAP_BOOL,
205        ALIAS_FOR        type ABAP_METHNAME,
206        IS_RAISING_EXCPS type ABAP_BOOL, "abap_true if method declaration has a raising clause
207        "abap_false otherwise
208      end of ABAP_METHDESCR,
209      ABAP_METHDESCR_TAB type standard table of ABAP_METHDESCR
210                         with key NAME,
211    * event description
212      begin of ABAP_EVNTDESCR,
213        PARAMETERS   type ABAP_PARMDESCR_TAB,
214        NAME         type ABAP_EVNTNAME,
215        VISIBILITY   type ABAP_VISIBILITY,
216        IS_INTERFACE type ABAP_BOOL,
217        IS_INHERITED type ABAP_BOOL,
218        IS_CLASS     type ABAP_BOOL,
219        ALIAS_FOR    type ABAP_EVNTNAME,
220      end of ABAP_EVNTDESCR,
221      ABAP_EVNTDESCR_TAB type standard table of ABAP_EVNTDESCR
222                         with key NAME,
223
224    * table for get_friend_types
225      ABAP_FRNDTYPES_TAB type standard table of ref to CL_ABAP_TYPEDESCR
226                         with key TABLE_LINE.
227
228
229    ************************************************************************
230    ************* DYNAMIC CALL FUNCTION ************************************
231    types:
232    * CALL FUNCTION ... PARAMETER-TABLE
233      begin of ABAP_FUNC_PARMBIND,
234        VALUE     type ref to DATA,
235        TABLES_WA type ref to DATA,
236        KIND      type I,
237        NAME      type ABAP_PARMNAME,
238      end of ABAP_FUNC_PARMBIND,
239      ABAP_FUNC_PARMBIND_TAB type sorted table of ABAP_FUNC_PARMBIND
240                             with unique key KIND NAME,
241    * CALL FUNCTION ... EXCEPTION-TABLE
242      begin of ABAP_FUNC_EXCPBIND,
243        MESSAGE type ref to DATA,
244        VALUE   type I,
245        NAME    type ABAP_EXCPNAME,
246      end of ABAP_FUNC_EXCPBIND,
247      ABAP_FUNC_EXCPBIND_TAB type hashed table of ABAP_FUNC_EXCPBIND
248                             with unique key NAME.
249
250    constants:
251      ABAP_FUNC_EXPORTING type ABAP_FUNC_PARMBIND-KIND value 10,
252      ABAP_FUNC_IMPORTING type ABAP_FUNC_PARMBIND-KIND value 20,
253      ABAP_FUNC_TABLES    type ABAP_FUNC_PARMBIND-KIND value 30,
254      ABAP_FUNC_CHANGING  type ABAP_FUNC_PARMBIND-KIND value 40.
255
256    ************************************************************************
257    ************* DYNAMIC INVOKE *******************************************
258    types:
259    * PARAMETER-TABLE
260      begin of ABAP_PARMBIND,
261        NAME  type ABAP_PARMNAME,
262        KIND  type ABAP_PARMKIND,
263        VALUE type ref to DATA,
264      end of ABAP_PARMBIND,
265      ABAP_PARMBIND_TAB type hashed table of ABAP_PARMBIND
266                        with unique key NAME,
267    * EXCEPTION-TABLE
268      begin of ABAP_EXCPBIND,
269        NAME  type ABAP_EXCPNAME,
270        VALUE type I,
271      end of ABAP_EXCPBIND,
272      ABAP_EXCPBIND_TAB type hashed table of ABAP_EXCPBIND
273                        with unique key NAME.
274
275
276    ************************************************************************
277    **** Types for CL_ABAP_CHAR_UTILITIES **********************************
278    types:
279      ABAP_CHAR1(1)           type C,
280      ABAP_CR_LF(2)           type C,
281      ABAP_BYTE_ORDER_MARK(2) type X,
282      ABAP_BYTE_ORDER_UTF8(3) type X.
283
284
285    ************************************************************************
286    **** CONVERSION ********************************************************
287    types:
288      ABAP_ENCODING type ABAP_ENCOD,
289      ABAP_ENDIAN   type ABAP_ENDIA.
290
291    ************************************************************************
292    **** CALL TRANSFORMATION ***********************************************
293
294    * PARAMETER TABLE
295    types:
296      ABAP_TRANS_PARMNAME  type STRING,
297      ABAP_TRANS_PARMVALUE type STRING,
298      ABAP_TRANS_PARMREF   type ref to DATA.
299
300    types:
301      begin of ABAP_TRANS_PARMBIND,
302        NAME  type ABAP_TRANS_PARMNAME,
303        VALUE type ABAP_TRANS_PARMVALUE,
304      end of ABAP_TRANS_PARMBIND,
305      begin of ABAP_TRANS_PARM_OBJ_BIND,
306        NAME  type ABAP_TRANS_PARMNAME,
307        VALUE type ABAP_TRANS_PARMREF,
308      end of ABAP_TRANS_PARM_OBJ_BIND.
309
310    types:
311      ABAP_TRANS_PARMBIND_TAB
312          type standard table of ABAP_TRANS_PARMBIND with key NAME,
313      ABAP_TRANS_PARM_OBJ_BIND_TAB
314          type sorted table of ABAP_TRANS_PARM_OBJ_BIND with unique key NAME.
315
316    * OBJECT TABLE
317    types:
318      ABAP_TRANS_OBJNAME type STRING.
319
320    types:
321      begin of ABAP_TRANS_OBJBIND,
322        NAME  type ABAP_TRANS_OBJNAME,
323        VALUE type ref to OBJECT,
324      end of ABAP_TRANS_OBJBIND.
325
326    types:
327      ABAP_TRANS_OBJBIND_TAB
328          type standard table of ABAP_TRANS_OBJBIND with key NAME.
329
330    * SOURCE TABLE
331    types:
332      ABAP_TRANS_SRCNAME type STRING.
333
334    types:
335      begin of ABAP_TRANS_SRCBIND,
336        NAME  type ABAP_TRANS_SRCNAME,
337        VALUE type ref to DATA,
338      end of ABAP_TRANS_SRCBIND.
339
340    types:
341      ABAP_TRANS_SRCBIND_TAB
342           type standard table of ABAP_TRANS_SRCBIND with key NAME,
343      ABAP_TRANS_SRCBIND_TAB_SORTED
344           type sorted table of ABAP_TRANS_SRCBIND with unique key NAME.
345
346    * RESULT TABLE
347    types:
348      ABAP_TRANS_RESNAME type STRING.
349
350    types:
351      begin of ABAP_TRANS_RESBIND,
352        NAME  type ABAP_TRANS_RESNAME,
353        VALUE type ref to DATA,
354      end of ABAP_TRANS_RESBIND.
355
356    types:
357      ABAP_TRANS_RESBIND_TAB
358           type standard table of ABAP_TRANS_RESBIND with key NAME,
359      ABAP_TRANS_RESBIND_TAB_SORTED
360           type sorted table of ABAP_TRANS_RESBIND with unique key NAME.
*--- End of %_CABAP - 360 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CICON                                   Level 1    Page 269
Object           SAPMZFM06B                                Lines 1246
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
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
Generated incl.  %_CMMPUR                                  Level 1    Page 270
Object           SAPMZFM06B                                Lines 482
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      TYPE-POOL mmpur.
2
3      *---------------------------------------------------------------------*
4      * CONSTANTS with type of DDIC
5      *---------------------------------------------------------------------*
6      CONSTANTS:
7
8      *general
9        mmpur_yes                 TYPE c VALUE 'X',
10       mmpur_no                  TYPE c VALUE ' ',
11       mmpur_empty_dynpro_nr     TYPE sy-dynnr VALUE '1000',
12       mmpur_tc_button_dynpro    TYPE sy-dynnr VALUE '2001',
13       mmpur_tc_dynpro           TYPE sy-dynnr VALUE '2000',
14       mmpur_empty_prog          TYPE sy-repid VALUE 'SAPLMEVIEWS',
15       mmpur_plugin_active       TYPE i VALUE 1,
16       mmpur_plugin_inactive     TYPE i VALUE 0,
17       mmpur_custcat_po_docover  TYPE string40 VALUE 'PODocumentOverview',
18       mmpur_custcat_po_general  TYPE string40 VALUE 'POGeneralSettings',
19       mmpur_custcat_po_propose  TYPE string40 VALUE 'POProposals',
20       mmpur_custcat_req_propose TYPE string40 VALUE 'ReqProposals',
21
22     * temporary item number for reference handling
23       mmpur_default_number      TYPE ebeln VALUE '<INTERN>',
24
25     * processes
26       mmpur_po_process          TYPE mepo_process VALUE 'PO_PROCESS',
27       mmpur_req_process         TYPE mepo_process VALUE 'REQ_PROCESS',
28       mmpur_apr_process         TYPE mepo_process VALUE 'APR_PROCESS',
29       mmpur_out_process         TYPE mepo_process VALUE 'OUT_PROCESS',
30
31     * Initiators
32       mmpur_initiator_call      TYPE char40 VALUE 'CALLED',
33       mmpur_me58                TYPE char40 VALUE 'ME58',
34       mmpur_me57                TYPE char40 VALUE 'ME57',
35       mmpur_me56                TYPE char40 VALUE 'ME56',
36
37     *.SDP......DCM EXP
38       mmpur_initiator_ba        TYPE char40 VALUE 'BUYER',
39       mmpur_initiator_rel       TYPE char40 VALUE 'RELEASE',
40       mmpur_initiator_xpd       TYPE char40 VALUE 'EXPEDITOR',
41       mmpur_initiator_apo       TYPE char40 VALUE 'APO',
42       mmpur_initiator_ui        TYPE char40 VALUE 'UserInterface',
43
44     * option properties SDP
45       mmpur_requested_sched     TYPE char40 VALUE 'SCHEDULELINE',
46       mmpur_requested_meta      TYPE char40 VALUE 'METAFIELD',
47
48     * option properties
49       mmpur_requested_item      TYPE char40 VALUE 'ITEM',
50       mmpur_bedat               TYPE char40 VALUE 'BEDAT',
51       mmpur_ebeln               TYPE char40 VALUE 'EBELN',
52       mmpur_bsart               TYPE char40 VALUE 'BSART',
53       mmpur_ekgrp               TYPE char40 VALUE 'EKGRP',
54       mmpur_ekorg               TYPE char40 VALUE 'EKORG',
55       mmpur_lifnr               TYPE char40 VALUE 'LIFNR',
56       mmpur_reswk               TYPE char40 VALUE 'RESWK',
57       mmpur_beswk               TYPE char40 VALUE 'BESWK',
58
59     * authority
60     *           - purchase requisition
61       mmpur_auth_banf_bsa       TYPE xuobject VALUE 'M_BANF_BSA',
62       mmpur_auth_banf_eko       TYPE xuobject VALUE 'M_BANF_EKO',
63       mmpur_auth_banf_ekg       TYPE xuobject VALUE 'M_BANF_EKG',
64       mmpur_auth_banf_wrk       TYPE xuobject VALUE 'M_BANF_WRK',
65       mmpur_auth_banf_bwk       TYPE xuobject VALUE 'M_BANF_BWK',
66       mmpur_auth_banf_frg       TYPE xuobject VALUE 'M_BANF_FRG',
67       mmpur_auth_eink_frg       TYPE xuobject VALUE 'M_EINK_FRG',
68     *           - outline agreements
69       mmpur_auth_rahm_bsa       TYPE xuobject VALUE 'M_RAHM_BSA',
70       mmpur_auth_rahm_eko       TYPE xuobject VALUE 'M_RAHM_EKO',
71       mmpur_auth_rahm_ekg       TYPE xuobject VALUE 'M_RAHM_EKG',
72       mmpur_auth_rahm_wrk       TYPE xuobject VALUE 'M_RAHM_WRK',
73       mmpur_auth_rahm_lgo       TYPE xuobject VALUE 'M_RAHM_LGO',
74     *           - Central contracts
75       mmpur_auth_cctr_bsa       TYPE xuobject VALUE 'M_CCTR_BSA',
76       mmpur_auth_cctr_eko       TYPE xuobject VALUE 'M_CCTR_EKO',
77       mmpur_auth_cctr_ekg       TYPE xuobject VALUE 'M_CCTR_EKG',
78     *           - scheduling agreement call offs
79       mmpur_auth_lpet_bsa       TYPE xuobject VALUE 'M_LPET_BSA',
80       mmpur_auth_lpet_eko       TYPE xuobject VALUE 'M_LPET_EKO',
81       mmpur_auth_lpet_ekg       TYPE xuobject VALUE 'M_LPET_EKG',
82       mmpur_auth_lpet_wrk       TYPE xuobject VALUE 'M_LPET_WRK',
83       mmpur_auth_lpet_lgo       TYPE xuobject VALUE 'M_LPET_LGO',
84     *           - purchase order
85       mmpur_auth_best_bsa       TYPE xuobject VALUE 'M_BEST_BSA',
86       mmpur_auth_best_eko       TYPE xuobject VALUE 'M_BEST_EKO',
87       mmpur_auth_best_ekg       TYPE xuobject VALUE 'M_BEST_EKG',
88       mmpur_auth_best_wrk       TYPE xuobject VALUE 'M_BEST_WRK',
89       mmpur_auth_best_lgo       TYPE xuobject VALUE 'M_BEST_LGO',
90     *           - request for quotation
91       mmpur_auth_anfr_bsa       TYPE xuobject VALUE 'M_ANFR_BSA',
92       mmpur_auth_anfr_eko       TYPE xuobject VALUE 'M_ANFR_EKO',
93       mmpur_auth_anfr_ekg       TYPE xuobject VALUE 'M_ANFR_EKG',
94       mmpur_auth_anfr_wrk       TYPE xuobject VALUE 'M_ANFR_WRK',
95     *           - quotation
96       mmpur_auth_angb_bsa       TYPE xuobject VALUE 'M_ANGB_BSA',
97       mmpur_auth_angb_eko       TYPE xuobject VALUE 'M_ANGB_EKO',
98       mmpur_auth_angb_ekg       TYPE xuobject VALUE 'M_ANGB_EKG',
99       mmpur_auth_angb_wrk       TYPE xuobject VALUE 'M_ANGB_WRK',
100    *           - new request for quotation
101      mmpur_auth_rfq_bsa        TYPE xuobject VALUE 'M_RFQ_BSA',
102      mmpur_auth_rfq_eko        TYPE xuobject VALUE 'M_RFQ_EKO',
103      mmpur_auth_rfq_ekg        TYPE xuobject VALUE 'M_RFQ_EKG',
104      mmpur_auth_rfq_wrk        TYPE xuobject VALUE 'M_RFQ_WRK',
105      mmpur_auth_rfq_lgo        TYPE xuobject VALUE 'M_RFQ_LGO',
106    *           - new supplier quotation
107      mmpur_auth_qtn_bsa        TYPE xuobject VALUE 'M_QTN_BSA',
108      mmpur_auth_qtn_eko        TYPE xuobject VALUE 'M_QTN_EKO',
109      mmpur_auth_qtn_ekg        TYPE xuobject VALUE 'M_QTN_EKG',
110      mmpur_auth_qtn_wrk        TYPE xuobject VALUE 'M_QTN_WRK',
111      mmpur_auth_qtn_lgo        TYPE xuobject VALUE 'M_QTN_LGO',
112    *           - central supplier quotation
113      mmpur_auth_cqtn_bsa       TYPE xuobject VALUE 'M_CQTN_BSA',
114      mmpur_auth_cqtn_eko       TYPE xuobject VALUE 'M_CQTN_EKO',
115      mmpur_auth_cqtn_ekg       TYPE xuobject VALUE 'M_CQTN_EKG',
116    *           - purchase info record
117      mmpur_auth_inf_wrk        TYPE xuobject VALUE 'M_EINF_WRK',
118      mmpur_auth_inf_eko        TYPE xuobject VALUE 'M_EINF_EKO',
119      mmpur_auth_inf_ekg        TYPE xuobject VALUE 'M_EINF_EKG',
120
121      mmpur_auth_actvt_hin      TYPE activ_auth VALUE '01',
122      mmpur_auth_actvt_ver      TYPE activ_auth VALUE '02',
123      mmpur_auth_actvt_anz      TYPE activ_auth VALUE '03',
124      mmpur_auth_actvt_del      TYPE activ_auth VALUE '06',
125
126    * events
127      mmpur_event_s             TYPE i VALUE 10,
128      mmpur_event_i             TYPE i VALUE 11,
129      mmpur_event_w             TYPE i VALUE 12,
130      mmpur_event_e             TYPE i VALUE 13,
131      mmpur_event_a             TYPE i VALUE 14,
132      mmpur_event_x             TYPE i VALUE 15,
133
134    * Class-IDs for saplmequery
135      mmpur_dbl_po              TYPE mmpur_databl_classid VALUE 'PO_QUERY',
136      mmpur_dbl_rfq             TYPE mmpur_databl_classid VALUE 'RFQ_QUERY',
137      mmpur_dbl_agreemnt        TYPE mmpur_databl_classid VALUE 'AGREEMENT_QUERY',
138      mmpur_dbl_contract        TYPE mmpur_databl_classid VALUE 'CONTRACT_QUERY',
139      mmpur_dbl_schdlagrmnt     TYPE mmpur_databl_classid VALUE 'SCH_QUERY',
140      mmpur_dbl_purchdocs       TYPE mmpur_databl_classid VALUE 'PURDOCS_QUERY',
141      mmpur_dbl_req             TYPE mmpur_databl_classid VALUE 'REQ_QUERY',
142      mmpur_dbl_po_usr          TYPE mmpur_databl_classid VALUE 'POS_BY_USER_QUERY',
143      mmpur_dbl_parkedpo_usr
144                 TYPE mmpur_databl_classid VALUE 'PARKED_POS_BY_USER_QUERY',
145      mmpur_dbl_heldpo_usr                                    "Park&Hold
146                 TYPE mmpur_databl_classid VALUE 'HELD_POS_BY_USER_QUERY',
147      mmpur_dbl_req_usr         TYPE mmpur_databl_classid VALUE 'REQ_BY_USER_QUERY',
148      mmpur_dbl_parkedreq_usr                                 "Park&Hold
149                 TYPE mmpur_databl_classid VALUE 'PARKED_REQ_BY_USER_QUERY',
150      mmpur_dbl_heldreq_usr                                   "Park&Hold
151                 TYPE mmpur_databl_classid VALUE 'HELD_REQ_BY_USER_QUERY'.
152
153    *---------------------------------------------------------------------*
154    * TYPES
155    *---------------------------------------------------------------------*
156    TYPES:
157
158    * Fcode exclusion
159      BEGIN OF mmpur_pf_exclusion_rec,
160        function TYPE sy-ucomm,
161      END OF mmpur_pf_exclusion_rec,
162
163      mmpur_pf_excluding_tab TYPE SORTED TABLE OF mmpur_pf_exclusion_rec
164                                  WITH UNIQUE KEY function,
165
166      mmpur_plugin_state     TYPE i,
167
168    * Metafields
169      mmpur_fieldlist        TYPE mmpur_metafield OCCURS 0,
170
171    * Dynpro description
172      BEGIN OF mmpur_dynpro_entry,
173        screenname          TYPE scrfname,
174        fieldname           TYPE fieldname,
175        position            TYPE sy-index,
176        metafield           TYPE mmpur_metafield,
177        display_only        TYPE mmpur_bool,
178        initial_no_disp     TYPE mmpur_bool,
179        initial_is_inactive TYPE mmpur_bool,
180      END OF mmpur_dynpro_entry,
181
182      mmpur_dynpro_fields TYPE SORTED TABLE OF mmpur_dynpro_entry
183                               WITH UNIQUE KEY screenname,
184    * Class registry
185      BEGIN OF mmpur_class_registry_type,
186        class_id_long TYPE seoclsname,
187        class_id      TYPE i,
188      END OF mmpur_class_registry_type,
189
190      mmpur_class_registry TYPE SORTED TABLE OF mmpur_class_registry_type
191                                WITH UNIQUE KEY class_id_long,
192
193    * Messages
194      BEGIN OF mmpur_message_config_entry,
195        msgty   TYPE symsgty,
196        dialog,                                                 "#EC *
197        collect,                                                "#EC *
198      END OF mmpur_message_config_entry,
199
200      mmpur_message_config TYPE STANDARD TABLE OF mmpur_message_config_entry
201                                INITIAL SIZE 0,
202
203      mmpur_acc_tab        TYPE STANDARD TABLE OF ueskn INITIAL SIZE 1,
204
205      mmpur_tkomv          TYPE STANDARD TABLE OF komv INITIAL SIZE 1,
206      mmpur_tkomk          TYPE STANDARD TABLE OF komk INITIAL SIZE 1,
207      mmpur_tkomp          TYPE STANDARD TABLE OF komp INITIAL SIZE 1.
208
209    TYPES: BEGIN OF mmpur_konv_ext.                             "1012433
210             INCLUDE STRUCTURE konv.
211    TYPES:   change_id TYPE cdchngind,
212           END OF mmpur_konv_ext.
213
214    TYPES:
215      mmpur_tkonv_ext TYPE STANDARD TABLE OF mmpur_konv_ext,
216      mmpur_tkonv_x   TYPE STANDARD TABLE OF mepoconditionx,    "1012433
217
218      BEGIN OF mmpur_inactive_entry,
219        metafield TYPE mmpur_metafield,
220        inactive  TYPE mmpur_bool,
221      END OF mmpur_inactive_entry,
222
223      mmpur_inactive TYPE STANDARD TABLE OF mmpur_inactive_entry
224                         INITIAL SIZE 0,
225
226      BEGIN OF mmpur_partner_all,
227    *   MODEL TYPE REF TO CL_PO_PARTNER_HANDLE_MM,
228        data TYPE msgpa,
229      END OF mmpur_partner_all,
230
231      mmpur_partner_all_tab TYPE mmpur_partner_all OCCURS 0,
232
233    * types for Drag&Drop-Flavors
234      mmpur_flavor(64)      TYPE c,
235
236    * types for GENERIC TREE
237      BEGIN OF mmpur_gentree_record,
238        col1    TYPE string40,
239        col2    TYPE string40,
240        col3    TYPE string40,
241        col4    TYPE string40,
242        col5    TYPE string40,
243        col6    TYPE string40,
244        col7    TYPE string40,
245        col8    TYPE string40,
246        col9    TYPE string40,
247        col10   TYPE string40,
248        nodekey TYPE lvc_nkey,
249      END OF mmpur_gentree_record,
250
251      mmpur_gentree_table      TYPE STANDARD TABLE OF mmpur_gentree_record
252                               INITIAL SIZE 0,
253
254    * Text handling
255      mmpur_texttypes_table    TYPE STANDARD TABLE OF mmpur_texttypes
256                                 INITIAL SIZE 0,
257      mmpur_textlines_table    TYPE STANDARD TABLE OF mmpur_textlines
258                                 INITIAL SIZE 0,
259
260    * types for rulebase definitions
261      mmpur_ty_rule_scope      TYPE i,
262      mmpur_ty_rule_validation TYPE i,
263      mmpur_ty_rule_dependency TYPE i.
264
265
266    *---------------------------------------------------------------------*
267    * CONSTANTS with type of this include
268    *---------------------------------------------------------------------*
269    CONSTANTS:
270
271    * constants for Drag&Drop-Flavors
272      mmpur_flavor_pdocs          TYPE mmpur_flavor VALUE 'PDOCS',
273      mmpur_flavor_req            TYPE mmpur_flavor VALUE 'PREQ',
274
275    * constants for rulebase definitions
276      mmpur_scope_full            TYPE mmpur_ty_rule_scope VALUE 1,
277      mmpur_scope_read            TYPE mmpur_ty_rule_scope VALUE 2,
278      mmpur_scope_change          TYPE mmpur_ty_rule_scope VALUE 3,
279      mmpur_scope_on_demand       TYPE mmpur_ty_rule_scope VALUE 4,
280      mmpur_scope_late            TYPE mmpur_ty_rule_scope VALUE 5,
281      mmpur_scope_check           TYPE mmpur_ty_rule_scope VALUE 6,
282      mmpur_scope_exec_by_sys     TYPE mmpur_ty_rule_scope VALUE 7,
283
284      mmpur_rule_valid            TYPE mmpur_ty_rule_validation VALUE 1,
285      mmpur_rule_invalid          TYPE mmpur_ty_rule_validation VALUE 2,
286      mmpur_rule_valid_no_upd     TYPE mmpur_ty_rule_validation VALUE 3,
287
288      mmpur_rule_exec_imme        TYPE mmpur_rule_exec_mode VALUE 1,
289      mmpur_rule_exec_late        TYPE mmpur_rule_exec_mode VALUE 2,
290
291      mmpur_rule_dep_precondition TYPE mmpur_ty_rule_dependency VALUE 1,
292      mmpur_rule_dep_observer     TYPE mmpur_ty_rule_dependency VALUE 2,
293      mmpur_rule_dep_none         TYPE mmpur_ty_rule_dependency VALUE 3.
294
295    *---------------------------------------------------------------------*
296    * MACROS for syncing derivative data that might be altered from
297    * the first process (MEPO)
298    *---------------------------------------------------------------------*
299    * use: mmpur_sync_derivative_data reference_field (e.g. banfpo)
300    *      derivated by MEPO but still not changed in the current structure
301    * result:  We put in sync the current structure with the old one
302    *          might have been deviated by MEPO
303    DEFINE mmpur_sync_derivative_data.
304
305    *  ls_po_schedule_itemx-&1 = xsdbool( <my_schedule_item>-datax-&1 = abap_false
306    *                 AND <my_schedule_item>-data-&1 <> ls_po_schedule_item_old-&1 ).
307    *  IF ls_po_schedule_itemx-&1 = abap_true.
308    *    ls_po_schedule_item-&1 = ls_po_schedule_item_old-&1.
309    *  ENDIF.
310      IF <my_schedule_item>-datax-&1 = abap_false AND
311         <my_schedule_item>-data-&1 NE ls_po_schedule_item_old-&1.
312         ls_po_schedule_item-&1 = ls_po_schedule_item_old-&1.
313         ls_po_schedule_itemx-&1 = abap_true.
314      ENDIF.
315
316    END-OF-DEFINITION.
317
318    *---------------------------------------------------------------------*
319    * MACROS for Dynamic Cast
320    *---------------------------------------------------------------------*
321    * use: dynamic_cast reference_target_type reference_source_type
322    * result:  a) cast works (reference_target_type assigned)
323    *          b) cast doesn't work (reference_target_type cleared)
324    *             sy-subrc = 1
325
326    DEFINE mmpur_dynamic_cast.
327      CATCH SYSTEM-EXCEPTIONS move_cast_error = 1.
328        &1 ?= &2.
329      ENDCATCH.
330      IF sy-subrc = 1.
331        CLEAR: &1.
332      ENDIF.
333    END-OF-DEFINITION.
334
335    DEFINE mmpur_dynamic_cast1.
336      TRY.
337          &1 ?= &2.
338        CATCH cx_sy_move_cast_error.
339          CLEAR &1.
340      ENDTRY.
341    END-OF-DEFINITION.
342
343    *---------------------------------------------------------------------*
344    * MACROS for Mutual Exclusion
345    *---------------------------------------------------------------------*
346
347    * --------------------------------------------------------------------
348    * begin mutex
349    * --------------------------------------------------------------------
350    * starts a block of coding, which is protected from re-entrance
351    * use: mmpur_begin_mutex id
352    *    parameters: &1  id   An id (max. 40 char)
353    DEFINE mmpur_begin_mutex.
354      CALL METHOD cl_mutex_mm=>p
355        EXPORTING
356          im_obj = me
357          im_id  = '&1'
358        EXCEPTIONS
359          failed = 1.
360
361      IF sy-subrc EQ 0.
362    END-OF-DEFINITION.
363    * --------------------------------------------------------------------
364    * end mutex
365    * --------------------------------------------------------------------
366    * ends a block of coding, which is protected from re-entrance
367    * use: mmpur_end_mutex id
368    *    parameters: &1  id   An id (max. 40 char) the same id as begin!!!
369    DEFINE mmpur_end_mutex.
370      CALL METHOD cl_mutex_mm=>v
371        EXPORTING
372          im_obj = me
373          im_id  = '&1'.
374    ENDIF.
375    END-OF-DEFINITION.
376    *----------------------------------------------------------------------*
377    DEFINE mmpur_begin_mutex_2.
378      CALL METHOD cl_mutex_mm=>p
379        EXPORTING
380          im_obj = &1
381          im_id  = '&2'
382        EXCEPTIONS
383          failed = 1.
384    END-OF-DEFINITION.
385    *----------------------------------------------------------------------*
386    DEFINE mmpur_end_mutex_2.
387      CALL METHOD cl_mutex_mm=>v
388        EXPORTING
389          im_obj = &1
390          im_id  = '&2'
391        EXCEPTIONS
392          failed = 01.
393    END-OF-DEFINITION.
394
395    *---------------------------------------------------------------------*
396    * MACROS for transport fields
397    *---------------------------------------------------------------------*
398    DEFINE mmpur_transport_fields.
399
400      DO.
401        FIELD-SYMBOLS: <new> TYPE any,
402                       <old> TYPE any,
403                       <act> TYPE any.
404        DATA: l_dynpro_entry LIKE LINE OF my_dynpro_fields.
405
406        ASSIGN COMPONENT sy-index OF
407               STRUCTURE &1 TO <new>.
408        IF sy-subrc <> 0. EXIT. ENDIF.
409        ASSIGN COMPONENT sy-index OF
410               STRUCTURE &2 TO <old>.
411        IF sy-subrc <> 0. EXIT. ENDIF.
412        CHECK <new> NE <old>.
413        READ TABLE my_dynpro_fields INTO l_dynpro_entry
414                                WITH KEY position = sy-index.
415        CHECK sy-subrc IS INITIAL.
416        ASSIGN COMPONENT l_dynpro_entry-fieldname OF
417               STRUCTURE &3 TO <act>.
418        IF sy-subrc EQ 0.
419          <act> = <new>.
420        ENDIF.
421      ENDDO.
422
423    END-OF-DEFINITION.
424
425    DEFINE mmpur_transport_fields_x.
426
427      DO.
428        FIELD-SYMBOLS: <new> TYPE any,
429                       <old> TYPE any,
430                       <act> TYPE any,
431                       <x>   TYPE any.
432        DATA: l_dynpro_entry LIKE LINE OF my_dynpro_fields.
433
434        ASSIGN COMPONENT sy-index OF
435               STRUCTURE &1 TO <new>.
436        IF sy-subrc <> 0. EXIT. ENDIF.
437        ASSIGN COMPONENT sy-index OF
438               STRUCTURE &2 TO <old>.
439        IF sy-subrc <> 0. EXIT. ENDIF.
440        CHECK <new> NE <old>.
441        READ TABLE my_dynpro_fields INTO l_dynpro_entry
442                                WITH KEY position = sy-index.
443        CHECK sy-subrc IS INITIAL.
444        ASSIGN COMPONENT l_dynpro_entry-fieldname OF
445               STRUCTURE &3 TO <act>.
446        IF sy-subrc EQ 0.
447          <act> = <new>.
448        ENDIF.
449        ASSIGN COMPONENT l_dynpro_entry-fieldname OF
450               STRUCTURE &4 TO <x>.
451        IF sy-subrc EQ 0.
452          <x> = mmpur_yes.
453        ENDIF.
454      ENDDO.
455
456    END-OF-DEFINITION.
457
458    *---------------------------------------------------------------------*
459    * MACROS for build metafield
460    *---------------------------------------------------------------------*
461    DEFINE mmpur_build_metafield.
462      READ TABLE my_dynpro_fields INTO l_dynpro_field
463                                  WITH KEY screenname = &1.
464      IF sy-subrc IS INITIAL.
465        l_dynpro_field-metafield = &2.
466        MODIFY my_dynpro_fields FROM l_dynpro_field INDEX sy-tabix.
467      ENDIF.
468    END-OF-DEFINITION.
469
470    *---------------------------------------------------------------------*
471    * MACROS for dynprofield set option
472    *---------------------------------------------------------------------*
473    DEFINE mmpur_dynprofield_set_option.
474      READ TABLE my_dynpro_fields INTO l_dynpro_field
475                                  WITH KEY screenname = &1.
476      IF sy-subrc IS INITIAL.
477        l_dynpro_field-display_only = &2.
478        l_dynpro_field-initial_no_disp = &3.
479        l_dynpro_field-initial_is_inactive = &4.
480        MODIFY my_dynpro_fields FROM l_dynpro_field INDEX sy-tabix.
481      ENDIF.
482    END-OF-DEFINITION.
*--- End of %_CMMPUR - 482 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CRSDS                                   Level 1    Page 271
Object           SAPMZFM06B                                Lines 46
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
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
Generated incl.  %_CRSFS                                   Level 1    Page 272
Object           SAPMZFM06B                                Lines 12
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      TYPE-POOL RSFS .
2
3      * Name of the TYPEs must never be changed!
4
5      * Fields to be selected per table
6      TYPES: BEGIN OF RSFS_TAB_FIELDS,
7               TABLENAME LIKE RSDSTABS-PRIM_TAB,
8               FIELDS LIKE RSFS_STRUC OCCURS 10,
9             END OF RSFS_TAB_FIELDS.
10
11     * Fields to be selected for all tables
12     TYPES: RSFS_FIELDS TYPE RSFS_TAB_FIELDS OCCURS 10.
*--- End of %_CRSFS - 12 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CSLIS                                   Level 1    Page 273
Object           SAPMZFM06B                                Lines 543
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
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
Generated incl.  <ICON>                                    Level 1    Page 274
Object           SAPMZFM06B                                Lines 6
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      ***INCLUDE <icon> .
2      *-----------------------------------------------------------------------
3      *  Instead of statement 'INCLUDE <icon>.', please use
4      *  statement 'TYPE-POOLS: icon.' directly.
5      *-----------------------------------------------------------------------
6      TYPE-POOLS: icon.
*--- End of <ICON> - 6 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  <REPINI>                                  Level 1    Page 275
Object           SAPMZFM06B                                Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
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
Generated incl.  <SYSINI>                                  Level 1    Page 276
Object           SAPMZFM06B                                Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
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
Generated incl.  <SYSSEL>                                  Level 1    Page 277
Object           SAPMZFM06B                                Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
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
Generated incl.  >ICON<                                    Level 1    Page 278
Object           SAPMZFM06B                                Lines 24
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
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
Generated incl.  CVP_CL_READ_API_DEFLT_BEHAVIORCU          Level 1    Page 279
Object           SAPMZFM06B                                Lines 64
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      class CVP_CL_READ_API_DEFLT_BEHAVIOR definition
2        public
3        final
4        create public .
5
6      public section.
7
8        interfaces CVP_IF_CONST_DCPLD_I1 .
9        interfaces CVP_IF_CONSTANTS .
10
11       aliases GC_MASS_API
12         for CVP_IF_CONSTANTS~GC_MASS_API .
13       aliases GC_MASS_BEHAVIOR_DEFAULT
14         for CVP_IF_CONSTANTS~GC_MASS_BEHAVIOR_DEFAULT .
15       aliases GC_MASS_BEHAVIOR_FILTER
16         for CVP_IF_CONSTANTS~GC_MASS_BEHAVIOR_FILTER .
17       aliases GC_MASS_BEHAVIOR_FILTER_ALL
18         for CVP_IF_CONSTANTS~GC_MASS_BEHAVIOR_FILTER_ALL .
19       aliases GC_MASS_BEHAVIOR_NA
20         for CVP_IF_CONSTANTS~GC_MASS_BEHAVIOR_NA .
21       aliases GC_MASS_BEHAVIOR_NO_DPP
22         for CVP_IF_CONSTANTS~GC_MASS_BEHAVIOR_NO_DPP .
23       aliases GC_SINGLE_API
24         for CVP_IF_CONSTANTS~GC_SINGLE_API .
25       aliases GC_SINGLE_BEHAVIOR_DEFAULT
26         for CVP_IF_CONSTANTS~GC_SINGLE_BEHAVIOR_DEFAULT .
27       aliases GC_SINGLE_BEHAVIOR_EXCEPTION
28         for CVP_IF_CONSTANTS~GC_SINGLE_BEHAVIOR_EXCEPTION .
29       aliases GC_SINGLE_BEHAVIOR_NA
30         for CVP_IF_CONSTANTS~GC_SINGLE_BEHAVIOR_NA .
31       aliases GC_SINGLE_BEHAVIOR_NO_DPP
32         for CVP_IF_CONSTANTS~GC_SINGLE_BEHAVIOR_NO_DPP .
33
34       class-methods PUSH
35         importing
36           !IV_SINGLE_DEFAULT_BEHAVIOR type CVP_API_BEHAVIOR optional
37           !IV_MASS_DEFAULT_BEHAVIOR type CVP_API_BEHAVIOR optional
38         exceptions
39           BEHAVIOR_NOT_SUPPORTED
40           NO_BEHAVIOR_PROVIDED .
41       class-methods GET
42         importing
43           !IV_BEHAVIOR type CVP_API_BEHAVIOR optional
44           !IV_READ_API_TYPE type CVP_API_TYPE
45         returning
46           value(RV_BEHAVIOR) type CVP_API_BEHAVIOR .
47       class-methods PULL
48         exceptions
49           STACK_EMPTY .
50       class-methods CHECK2
51         importing
52           !IV_BEHAVIOR type CVP_API_BEHAVIOR optional
53         exporting
54           !EV_SINGLE_BEHAVIOR type CVP_API_BEHAVIOR
55           !EV_MASS_BEHAVIOR type CVP_API_BEHAVIOR
56           !EV_EXISTS type CVP_EXIST .
57       class-methods CHECK
58         importing
59           !IV_BEHAVIOR type CVP_API_BEHAVIOR optional
60         exporting
61           !EV_SINGLE_BEHAVIOR type CVP_API_BEHAVIOR
62           !EV_MASS_BEHAVIOR type CVP_API_BEHAVIOR
63         returning
64           value(RV_EXISTS) type CVP_EXIST .
*--- End of CVP_CL_READ_API_DEFLT_BEHAVIORCU - 64 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  DB__SSEL                                  Level 1    Page 280
Object           SAPMZFM06B                                Lines 1
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      * INCLUDE DB__SSEL
*--- End of DB__SSEL - 1 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  IF_MMPUR_CONSTANTS_EXT_RELEASEIU          Level 1    Page 281
Object           SAPMZFM06B                                Lines 7
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      *"* components of interface IF_MMPUR_CONSTANTS_EXT_RELEASE
2      interface IF_MMPUR_CONSTANTS_EXT_RELEASE
3        public .
4
5
6        constants EVENT_RELEASEREQUESTED type SWO_EVENT value 'RELEASEREQUESTED'. "#EC NOTEXT
7      endinterface.
*--- End of IF_MMPUR_CONSTANTS_EXT_RELEASEIU - 7 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  IF_MMPUR_CONSTANTS_FTRE_TOGGLEIU          Level 1    Page 282
Object           SAPMZFM06B                                Lines 7
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      interface IF_MMPUR_CONSTANTS_FTRE_TOGGLE
2        public .
3
4
5        constants FEATURE_TOGGLE_PR_ITM_HIER type SFTGL_FT_ID value 'MM_PUR_PR_ITM_HIER' ##NO_TEXT.
6        constants FEATURE_TOGGLE_PR_ITM_HIER_ADV type SFTGL_FT_ID value 'MM_PUR_PR_ITM_HIER_ADV_PR' ##NO_TEXT.
7      endinterface.
*--- End of IF_MMPUR_CONSTANTS_FTRE_TOGGLEIU - 7 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  IF_MMPUR_CONSTANTS_FUNC_SWITCHIU          Level 1    Page 283
Object           SAPMZFM06B                                Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      interface IF_MMPUR_CONSTANTS_FUNC_SWITCH
2        public .
3
4
5        constants OUTPUT_CONTROL_COND_TECHNIQUE type CHAR_01 value 'C' ##NO_TEXT.
6        constants OUTPUT_CONTROL_BRF_BOPF type CHAR_01 value 'B' ##NO_TEXT.
7        constants RELEASE_DET_CLASSIFICATION type CHAR_01 value 'C' ##NO_TEXT.
8        constants RELEASE_DET_SIMPLIFIED type CHAR_01 value 'S' ##NO_TEXT.
9        constants USE_USER_PARAMETER type CHAR_01 value 'X' ##NO_TEXT.
10     endinterface.
*--- End of IF_MMPUR_CONSTANTS_FUNC_SWITCHIU - 10 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  IF_MMPUR_CONSTANTS_SYSTEM_TYPEIU          Level 1    Page 284
Object           SAPMZFM06B                                Lines 11
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
1      interface IF_MMPUR_CONSTANTS_SYSTEM_TYPE
2        public .
3
4
5        constants ERP_BUSINESS_SUITE type CHAR_01 value '0' ##NO_TEXT.
6        constants S4_HANA_PUBLIC_CLOUD type CHAR_01 value '1' ##NO_TEXT.
7        constants S4_HANA_MANAGED_CLOUD type CHAR_01 value '2' ##NO_TEXT.
8        constants S4_HANA_ON_PREMISE type CHAR_01 value '4' ##NO_TEXT.
9        constants UNKNOWN_SYSTEM_TYPE type CHAR_01 value 'X' ##NO_TEXT.
10       constants S4_HANA_CLOUD type CHAR_01 value '3' ##NO_TEXT.
11     endinterface.
*--- End of IF_MMPUR_CONSTANTS_SYSTEM_TYPEIU - 11 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  LOG_SFWS_CMM_ANALYTICS_CUST_02P           Level 1    Page 285
Object           SAPMZFM06B                                Lines 0
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
*--- End of LOG_SFWS_CMM_ANALYTICS_CUST_02P - 0 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  LOG_SFWS_CMM_ANALYTICS_CUST_02S           Level 1    Page 286
Object           SAPMZFM06B                                Lines 0
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:53
----------------------------------------------------------------------------------------------------
*--- End of LOG_SFWS_CMM_ANALYTICS_CUST_02S - 0 lines ---
