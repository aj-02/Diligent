----------------------------------------------------------------------------------------------------
Main program     Z_DEL_HIST_ENTRIES                        Level 0    Page 1
Object           Z_DEL_HIST_ENTRIES                        Lines 340
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:32
----------------------------------------------------------------------------------------------------
1      *REPORT Z_DEL_HIST_ENTRIES.
2      *      Delta 001
3      *      Context Block
4      *
5      *
6      *      Delete Block
7      *
8      *
9      *      Insert Block
10     ************************************************************************
11     * Date        Transport     USERID       Description
12     * 13/09/2008  <RD1K960036>  SAB_PUNIT    1) Added include MM13QF50 to
13     *                                           remove syntax error FORM
14     *                                           'APPEND_COMMENTRY' does not
15     *                                           exists.
16     ************************************************************************
17
18     include mm13qtop.
19
20     selection-screen skip 2.
21
22     parameters: i_vbukr like rm03q-vbukr obligatory.
23
24     data        i_bbukr like rm03q-bbukr.
25     data:       i_lfmon like rm03q-nperi,
26                 i_lfgja like rm03q-lfgja.
27     data:       i_xcomp like rm03q-xcomp value 'X',
28                 i_xinco like rm03q-xinco,
29                 i_xmove like rm03q-xmove.
30     data:       i_kzinv like rm03q-kzinv value 'X'.
31
32     at selection-screen.
33
34       select single *  from marv where bukrs = i_vbukr.
35       if sy-subrc = 0.
36         i_lfmon = marv-lfmon.
37         i_lfgja = marv-lfgja.
38       else.
39         exit.
40       endif.
41       rm03q-vbukr = i_vbukr.
42       rm03q-bbukr = i_bbukr.
43       rm03q-lfmon = i_lfmon.
44       rm03q-lfgja = i_lfgja.
45       rm03q-kzinv = i_kzinv.
46
47       if i_bbukr is initial.
48         i_bbukr = rm03q-bbukr = i_vbukr.
49       endif.
50
51       if i_kzinv ne space.
52     *   Sitzt der Benuterparameter?
53         get parameter id 'MMPI_READ_NOTE' field mmpi_read_note.
54         if mmpi_read_note ne sy-datlo.
55           message e016(mm).
56         endif.
57       endif.
58
59     *--------------------------------------------------------
60     start-of-selection.
61
62       berecht_akt = '51'.      "Initialisieren
63       authority-check object 'M_MATE_PER'
64            id 'AKTPR' field berecht_akt
65            id 'BUKRS' dummy.
66       if sy-subrc ne 0.
67         berecht_akt = '03'.      "Initialisieren
68         authority-check object 'M_MATE_PER'
69            id 'AKTPR' field berecht_akt
70            id 'BUKRS' dummy.
71         if sy-subrc ne 0.
72           message e865.
73         endif.
74       endif.
75
76       perform bukrs_tab_fuellen.
77
78       describe table bukrs_tab lines zaehler1.
79       if zaehler1 = 0.                      "kein Buchungskreis gefunden
80         move '01' to ausnahme_tab.
81         append ausnahme_tab.
82         exit.
83       endif.
84
85       perform lesen_marv_seq.
86
87       loop at bukrs_tab.
88         perform periode_ermitteln.
89         if fehlerflag ne space.     "im Up PERIODE_ERMITTELN gesetzt
90           check sy-subrc ne sy-subrc.
91         endif.
92         perform periode_pruefen.
93         if fehlerflag ne space.     "im Up PERIODE_PRUEFEN gesetzt
94           check sy-subrc ne sy-subrc.
95         endif.
96     * neu zu 4.6a: Prüfen, ob Warenbewegungen vorhanden sind, zu denen
97     *                      die Werte noch fortzuschreiben sind.
98         call function 'MB_STATUS_SEPERATE_VALUATION'
99           exporting
100            bukrs                      = bukrs_tab-bukrs
101          exceptions
102            exception_internal_error   = 1
103            exception_entries_found    = 2
104            exception_no_entries_found = 3
105            others                     = 4.
106        if sy-subrc = 2.
107          clear ausnahme_tab.
108          move '97' to ausnahme_tab-ausna.
109          move bukrs_tab-bukrs to ausnahme_tab-bukrs.
110          append ausnahme_tab.
111          move '98' to ausnahme_tab-ausna.
112          append ausnahme_tab.
113          if sy-msgty = 'E'.
114            fehlerflag = 'X'.
115            move '91' to ausnahme_tab-ausna.
116            append ausnahme_tab.
117          endif.
118        endif.
119
120        bukrs_tab-relevantflag = 'X'.
121        modify bukrs_tab.
122      endloop.
123
124      loop at bukrs_tab.
125        check bukrs_tab-relevantflag ne space.
126
127        perform in_bwkey_ermitteln.
128        read table in_bwkey_all index 1.
129        if sy-subrc = 0  and in_bwkey_all-low is initial.
130          continue.
131        endif.
132        perform in_werks_ermitteln.
133        read table in_werks_all index 1.
134        if sy-subrc = 0  and in_werks_all-low is initial.
135          continue.
136        endif.
137        marv-bukrs = bukrs_tab-bukrs.
138        perform marvcd_zaehler.
139        marvcd-mandt = sy-mandt.
140        marvcd-bukrs = bukrs_tab-bukrs.
141        marvcd-lfgja = bukrs_tab-jahr.
142        marvcd-lfmon = bukrs_tab-monat.
143        marvcd-aenam = sy-uname.
144        marvcd-laeda = sy-datum.
145        marvcd-uzeit = sy-uzeit.
146        clear marvcd-lfgja_old.
147        clear marvcd-lfmon_old.
148        perform marvcd_insert.
149        clear flg_no_bwkey.
150        do.
151          perform in_bwkey_teil_ermitteln.
152          if flg_no_bwkey = xwert.
153            exit.
154          endif.
155          if  ( bukrs_tab-lfgja > bukrs_tab-jahr )
156          or  (   bukrs_tab-lfgja = bukrs_tab-jahr
157              and bukrs_tab-lfmon >= bukrs_tab-monat ).
158            delete from mbewh
159                   where bwkey in in_bwkey
160                   and ( lfgja > bukrs_tab-jahr
161                       or (   lfgja = bukrs_tab-jahr
162                          and lfmon >= bukrs_tab-monat ) ).
163            delete from ebewh
164                   where bwkey in in_bwkey
165                   and ( lfgja > bukrs_tab-jahr
166                       or (   lfgja = bukrs_tab-jahr
167                          and lfmon >= bukrs_tab-monat ) ).
168            delete from qbewh
169                   where bwkey in in_bwkey
170                   and ( lfgja > bukrs_tab-jahr
171                       or (   lfgja = bukrs_tab-jahr
172                          and lfmon >= bukrs_tab-monat ) ).
173            delete from obewh
174                   where bwkey in in_bwkey
175                   and ( lfgja > bukrs_tab-jahr
176                       or (   lfgja = bukrs_tab-jahr
177                          and lfmon >= bukrs_tab-monat ) ).
178          endif.
179        enddo.
180
181        clear flg_no_werks.
182        do.
183          perform in_werks_teil_ermitteln.
184          if flg_no_werks = xwert.
185            exit.
186          endif.
187          if  ( bukrs_tab-lfgja > bukrs_tab-jahr )
188          or  (   bukrs_tab-lfgja = bukrs_tab-jahr
189              and bukrs_tab-lfmon >= bukrs_tab-monat ).
190            delete from mardh
191                   where werks in in_werks
192                   and ( lfgja > bukrs_tab-jahr
193                       or (   lfgja = bukrs_tab-jahr
194                          and lfmon >= bukrs_tab-monat ) ).
195            delete from mchbh
196                   where werks in in_werks
197                   and ( lfgja > bukrs_tab-jahr
198                       or (   lfgja = bukrs_tab-jahr
199                          and lfmon >= bukrs_tab-monat ) ).
200            delete from mkolh
201                   where werks in in_werks
202                   and ( lfgja > bukrs_tab-jahr
203                       or (   lfgja = bukrs_tab-jahr
204                          and lfmon >= bukrs_tab-monat ) ).
205            delete from mscah
206                   where werks in in_werks
207                   and ( lfgja > bukrs_tab-jahr
208                       or (   lfgja = bukrs_tab-jahr
209                          and lfmon >= bukrs_tab-monat ) ).
210            delete from mskah
211                   where werks in in_werks
212                   and ( lfgja > bukrs_tab-jahr
213                       or (   lfgja = bukrs_tab-jahr
214                          and lfmon >= bukrs_tab-monat ) ).
215            delete from mskuh
216                   where werks in in_werks
217                   and ( lfgja > bukrs_tab-jahr
218                       or (   lfgja = bukrs_tab-jahr
219                          and lfmon >= bukrs_tab-monat ) ).
220            delete from mslbh
221                   where werks in in_werks
222                   and ( lfgja > bukrs_tab-jahr
223                       or (   lfgja = bukrs_tab-jahr
224                          and lfmon >= bukrs_tab-monat ) ).
225            delete from msprh
226                   where werks in in_werks
227                   and ( lfgja > bukrs_tab-jahr
228                       or (   lfgja = bukrs_tab-jahr
229                          and lfmon >= bukrs_tab-monat ) ).
230            delete from mssah
231                   where werks in in_werks
232                   and ( lfgja > bukrs_tab-jahr
233                       or (   lfgja = bukrs_tab-jahr
234                          and lfmon >= bukrs_tab-monat ) ).
235            delete from mssqh
236                   where werks in in_werks
237                   and ( lfgja > bukrs_tab-jahr
238                       or (   lfgja = bukrs_tab-jahr
239                          and lfmon >= bukrs_tab-monat ) ).
240          endif.
241        enddo.
242
243        EXEC      "#EC CI_EXECSQL
244           SQL.
245          COMMIT
246        ENDEXEC.
247
248    *-------- Meldung Buchungskreis umgesetzt
249        clear ausnahme_tab.
250        move '32' to ausnahme_tab-ausna.
251        move bukrs_tab-bukrs to ausnahme_tab-bukrs.
252        append ausnahme_tab.
253      endloop.
254
255
256    end-of-selection.
257
258      loop at ausnahme_tab.
259        select single * from t139a
260                 where ausna = ausnahme_tab-ausna.
261        if sy-subrc = 0.
262          move t139a-sortf to ausnahme_tab-sortf.
263          modify ausnahme_tab.
264        endif.
265      endloop.
266      sort ausnahme_tab by sortf.
267
268      skip.
269      write 'L O G'.
270      skip.
271      write : 'client: ', sy-mandt.
272      write: / 'deletion run for all history table entries >= (month/year)',
273               rm03q-lfmon, rm03q-lfgja.
274
275      skip 2.
276
277      loop at ausnahme_tab.
278        select single * from t139a
279                    where ausna = ausnahme_tab-ausna.
280        if t139a-abbru ne space.
281          write 'A B E N D'.
282          skip.
283        endif.
284        if ausnahme_tab-ausna = '32'.
285          concatenate 'history table entries for company code'
286                      '$$$$ deleted' into t139a-ktext separated by space.
287        endif.
288    *-- Buchungskreis im Kurztext einsetzen
289        if t139a-ktext ca '$'.
290          replace '$$$$' with ausnahme_tab-bukrs into t139a-ktext.
291        endif.
292    *-- Text in der sprachabhängigen Tabelle suchen und ausgeben
293        select single * from t139b
294                  where spras = sy-langu
295                  and   ausna = ausnahme_tab-ausna.
296        if sy-subrc = 0.
297          if ausnahme_tab-ausna = '32'.
298            concatenate 'history table entries for company code'
299                        '$$$$ deleted' into t139b-ktext separated by space.
300          endif.
301          if t139b-ktext ca '$'.
302            replace '$$$$' with ausnahme_tab-bukrs into t139b-ktext.
303          endif.
304          write t139b-ktext.
305        else.
306          write t139a-ktext.
307        endif.
308    *-- Zusätzliche Angaben
309        if ausnahme_tab-ausna = '05'.    "Falsche Periode in MARV
310          write: 'The current period (month/year) of the control record is',
311                 ausnahme_tab-lfmon, ausnahme_tab-lfgja.
312        endif.
313      endloop.
314    ** Ende der Ausgabe
315
316      skip 3.
317      write 'E N D'.
318
319
320      if t139a-abbru ne space
321      or t139a-ausna eq '93'.
322        clear cattaktiv.
323        import cattaktiv from memory id 'CATT'.
324        if cattaktiv = 'X' and sy-subrc = 0.
325          message e705.     "Periodenverschiebung ist abgebrochen
326        else.
327          message s705.     "Periodenverschiebung ist abgebrochen
328        endif.
329      endif.
330
331
332
333      include mm13qf00.
334      include mm13qfsq.
335
336      include mm13qf40.                "neu zu 4.0 -> EBEW/QBEW-Routinen
337    * begin of <RD1K960036>
338      include MM13QF50.
339    * end of <RD1K960036>
340    *       Back
*--- End of Z_DEL_HIST_ENTRIES - 340 lines ---

----------------------------------------------------------------------------------------------------
Include          MM13QTOP                                  Level 1    Page 2
Object           Z_DEL_HIST_ENTRIES                        Lines 368
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:32
----------------------------------------------------------------------------------------------------
1      PROGRAM SAVEPERI MESSAGE-ID M3.
2
3
4      *------------------------------------------------------------------
5      *           Tabellen
6      *------------------------------------------------------------------
7
8      TABLES: MARD,                          "Lagerorttabelle
9              MARV,                          "Materialverwaltungssatz
10             MARVCD,                        "ÄndBeleg bei Initialisierung
11             MBEW,                          "Bewertungstabelle
12             EBEW,                          "Bew. Kundenauftragsbestand
13             QBEW,                          "Bew. Projektbestand
14             OBEW,                          "ch/4.6A (wg. OBEW)
15             WBEW,                          "Bew. Wirkstoffanteile
16             MCHB,                          "Chargentabelle
17             MKOL,                          "Lieferantenkonsignation
18             MSCA,                          "K.Auftragsbestand beim Lieferant
19             MSKA,                          "Kundenauftragsbestand
20             MSKU,                          "K.Leergut und K.Konsignation
21             MSLB,                          "Lieferantenbeistellung
22             MSOA,                          "Summe K.AuftrBestände beim Lief.
23             MSPR,                          "Projektbestände
24             MSSQ,                          "Summe Projektbestände
25             MSSA,                          "Summe Kundenauftragsbestände
26             MSSL,                          "Summe Lieferantenbeistellungen
27             J_1AINFMBW,                    "Inflationsfelder
28             MARDH,                         "Historie-Tabellen
29             MBEWH,
30             EBEWH,
31             QBEWH,
32             OBEWH,                         "ch/4.6A (wg. OBEW)
33             MCHBH,
34             MKOLH,
35             MSCAH,
36             MSKAH,
37             MSKUH,
38             MSLBH,
39             MSPRH,
40             RM03Q,                         "Ein/Ausgabe-Felder
41             TSTCT,                         "Transaktionstexte
42             T000,                          "Mandanten
43             T001,                          "Buchungskreise
44             T001K,                         "Bewertungsebene/Buchungskreis
45             T001W,                         "Werkstabelle
46             T130S,                         "Allgemeine Parameter
47             T139A,                         "Ausnahmemeldungen
48             T139B.                         "Ausnahmemeldungen
49
50     *------------------------------------------------------------------
51     *           interne Tabellen
52     *------------------------------------------------------------------
53
54     DATA:   BEGIN OF AUSNAHME_TAB OCCURS 20, "Ausnahmemeldungen
55               AUSNA LIKE T139A-AUSNA,
56               SORTF LIKE T139A-SORTF,
57               BUKRS LIKE T001-BUKRS,
58               LFMON           LIKE MARV-LFMON,
59               LFGJA           LIKE MARV-LFGJA,
60             END OF AUSNAHME_TAB.
61
62     DATA:   BEGIN OF AUSNAHME_SATZ OCCURS 100, "Einzelne Materialstammsätze,
63                                                "die nicht umgesetzt werden
64               BUKRS LIKE T001-BUKRS,           "konnten
65               AUSNA(2) TYPE C,          "Ausnahmeart
66               MATNR LIKE MBEW-MATNR,
67               BWKEY LIKE MBEW-BWKEY,
68               BWTAR LIKE MBEW-BWTAR,
69               WERKS LIKE MARD-WERKS,
70               LGORT LIKE MARD-LGORT,
71               CHARG LIKE MCHB-CHARG,
72               SOBKZ LIKE MKOL-SOBKZ,
73               LIFNR LIKE MKOL-LIFNR,
74               KUNNR LIKE MSKU-KUNNR,
75               VBELN LIKE MSKA-VBELN,
76               POSNR LIKE MSKA-POSNR,
77     *         ETENR LIKE MSKA-ETENR,
78               PSPNR LIKE MSPR-PSPNR,
79               MEINH LIKE WBEW-MEINH,
80             END OF AUSNAHME_SATZ.
81
82     DATA:   BEGIN OF AUSNAHME_NEG  OCCURS 100, "Einzelne Materialstammsätze,
83                                                "die negativen Bestand zurn
84               BUKRS LIKE T001-BUKRS,           "Vorperiode haben
85               SAART(2) TYPE C,          "Satzart (=TEXT-2xx - 200)
86               MATNR LIKE MBEW-MATNR,
87               BWKEY LIKE MBEW-BWKEY,
88               BWTAR LIKE MBEW-BWTAR,
89               WERKS LIKE MARD-WERKS,
90               LGORT LIKE MARD-LGORT,
91               CHARG LIKE MCHB-CHARG,
92               SOBKZ LIKE MKOL-SOBKZ,
93               LIFNR LIKE MKOL-LIFNR,
94               KUNNR LIKE MSKU-KUNNR,
95               VBELN LIKE MSKA-VBELN,
96               POSNR LIKE MSKA-POSNR,
97               PSPNR LIKE MSPR-PSPNR,
98               MEINH LIKE WBEW-MEINH,
99             END OF AUSNAHME_NEG.
100
101    DATA:   BEGIN OF BUKRS_TAB OCCURS 10,  "Relevante Buchungskreise
102              BUKRS LIKE T001-BUKRS,
103              RELEVANTFLAG(1) TYPE C,                "Flag: ist umzusetzen
104              VJMONAT         LIKE MARV-LFMON,       "Monat: let.Per. Vorj.
105              VJJAHR          LIKE MARV-LFGJA,       "Jahr:  Vorjahr
106              VORMONAT        LIKE MARV-LFMON,       "Monat: Vorperiode
107              VORJAHR         LIKE MARV-LFGJA,       "Jahr:  Vorperiode
108              MONAT           LIKE MARV-LFMON,       "Monat: neuer Stand
109              JAHR            LIKE MARV-LFGJA,       "Jahr:  neuer Stand
110              LFMON           LIKE MARV-LFMON,
111              LFGJA           LIKE MARV-LFGJA,
112              VMMON           LIKE MARV-VMMON,
113              VMGJA           LIKE MARV-VMGJA,
114              VJMON           LIKE MARV-VJMON,
115              VJGJA           LIKE MARV-VJGJA,
116              VVMJAHR         LIKE MARV-LFGJA,
117              VVMMONAT        LIKE MARV-LFMON,
118              VVJJAHR         LIKE MARV-LFGJA,
119              VVJMONAT        LIKE MARV-LFMON,
120              VVMGJ           LIKE MARV-VVMGJ,
121              VVMMO           LIKE MARV-VVMMO,
122              VVJGJ           LIKE MARV-VVJGJ,
123              VVJMO           LIKE MARV-VVJMO,
124              GJA_40C         LIKE MARV-GJA_40C,    "ch zu 4.0C
125              MON_40C         LIKE MARV-MON_40C,    "ch zu 4.0C
126              GJA_46C         LIKE MARV-GJA_46C,    "ch zu 4.6b
127              MON_46C         LIKE MARV-MON_46C,    "ch zu 4.6b
128              MARVFLAG(1)     TYPE C,                "Flag: MARV existiert
129              XRUEV           LIKE MARV-XRUEV,       "ch zu 3.0C
130            END OF BUKRS_TAB.
131
132    DATA:   BEGIN OF IN_BUKRS OCCURS 10,   "Normierte int. Tabelle für
133    *                                      "komplexen Lesezugriff
134              METYP(1) TYPE C,             "Mengentyp: I(nclusive),E(xcl.)
135              MEOPR(2) TYPE C,             "Mengenoperation
136              VBUKR    LIKE T001-BUKRS,    "Von-Buchungskreis
137              BBUKR    LIKE T001-BUKRS,    "Bis-Buchungskreis
138            END OF IN_BUKRS.
139
140    DATA:   BEGIN OF IN_BWKEY OCCURS 10,   "Normierte int. Tabelle für
141    *                                      "komplexen Lesezugriff
142              METYP(1) TYPE C,             "Mengentyp: I(nclusive),E(xcl.)
143              MEOPR(2) TYPE C,             "Mengenoperation
144              VBWKE    LIKE T001K-BWKEY,
145              BBWKE    LIKE T001K-BWKEY,
146            END OF IN_BWKEY.
147
148    * Range-Tab für BewKreise, in denen negative Bestände vorkommen können
149    RANGES: NB_BWKEY FOR T001K-BWKEY,
150    * Range-Tab für alle BewKreise eines Buchungskreis
151            IN_BWKEY_ALL FOR T001K-BWKEY,
152    * Range-Tab für alle BewKreise eines Bukrs, in denen neg. Bestände v.k.
153            NB_BWKEY_ALL FOR T001K-BWKEY.
154
155    *ATA:   BEGIN OF IN_BWKEY_2 OCCURS 10, "Tabelle für EXEC-SQL-Zugriff
156    *         BWKEY    LIKE T001K-BWKEY,
157    *       END OF IN_BWKEY_2.
158    DATA:   IN_BWKEY_2(100) TYPE C.
159
160    DATA:   BEGIN OF IN_WERKS OCCURS 10,   "Normierte int. Tabelle für
161    *                                      "komplexen Lesezugriff
162              METYP(1) TYPE C,             "Mengentyp: I(nclusive),E(xcl.)
163              MEOPR(2) TYPE C,             "Mengenoperation
164              VWERK    LIKE T001W-WERKS,
165              BWERK    LIKE T001W-WERKS,
166            END OF IN_WERKS.
167
168    * Range-Tab für Werks, in denen negative Bestände vorkommen können
169    RANGES: NB_WERKS FOR T001W-WERKS,
170    * Range-Tab für alle Werke eines Buchungskreises
171            IN_WERKS_ALL FOR T001W-WERKS,
172    * Range-Tab für alle Werke eines Bukrs, in denen neg. Bestände v.k.
173            NB_WERKS_ALL FOR T001W-WERKS.
174
175    *ATA:   BEGIN OF IN_WERKS_2 OCCURS 10,   "Normierte int. Tabelle für
176    *         WERKS    LIKE T001W-WERKS,
177    *       END OF IN_WERKS_2.
178
179    DATA:  BEGIN OF INT_PPER OCCURS 2.        "Buchhaltungsperioden
180             INCLUDE STRUCTURE PPER.
181    DATA:  END OF INT_PPER.
182
183    * Interne Tabelle mit MSCA-Sätzen
184    DATA: BEGIN OF MSCA_ITAB OCCURS 100.
185            INCLUDE STRUCTURE MSCA.
186    DATA: END OF MSCA_ITAB.
187
188    * Interne Tabelle mit MSKA-Sätzen
189    DATA: BEGIN OF MSKA_ITAB OCCURS 100.
190            INCLUDE STRUCTURE MSKA.
191    DATA: END OF MSKA_ITAB.
192
193    * Interne Tabelle mit MSKU-Sätzen
194    DATA: BEGIN OF MSKU_ITAB OCCURS 100.
195            INCLUDE STRUCTURE MSKU.
196    DATA: END OF MSKU_ITAB.
197
198    * Interne Tabelle mit MSLB-Sätzen
199    DATA: BEGIN OF MSLB_ITAB OCCURS 100.
200            INCLUDE STRUCTURE MSLB.
201    DATA: END OF MSLB_ITAB.
202
203    * Interne Tabelle mit MSPR-Sätzen      "neu zu 3.0/br16.1.95
204    DATA: BEGIN OF MSPR_ITAB OCCURS 100.
205            INCLUDE STRUCTURE MSPR.
206    DATA: END OF MSPR_ITAB.
207
208    *ATA:   BEGIN OF PERIO,            "Periode
209    *         JAHR  LIKE MARV-LFGJA,
210    *         MONAT LIKE MARV-LFMON,
211    *       END OF PERIO.
212
213    *ATA:   BEGIN OF SCHLUESSEL,     "Key der Bukrs_tab
214    *         MANDT LIKE T000-MANDT,
215    *         BUKRS LIKE T001-BUKRS,
216    *       END OF SCHLUESSEL.
217
218    * Interne Tabelle mit den Bewertungskreisen, für die keine ML-Initial.
219    * möglich war                       (neu zu 3.0    ch/23.02.95)
220    DATA: BEGIN OF BWKEY_ML_ERROR OCCURS 10,
221            BUKRS LIKE T001-BUKRS,
222            BWKEY LIKE T001K-BWKEY,
223          END OF BWKEY_ML_ERROR.
224
225
226    *------------------------------------------------------------------
227    *           Datenfelder
228    *------------------------------------------------------------------
229
230    DATA:   BERECHT_AKT(2)         TYPE C, "Berechtigungsaktivitäten
231            CHAR(2)          TYPE C,       "Hilfsfeld
232            DATUM            LIKE SY-DATUM,"Hilfsfeld
233            FEHLERFLAG(1)    TYPE C,       "Hilfsfeld
234            FLG_ML_ERROR(1)  TYPE C,       "KZ: Fehler bei ML-Initialisierg.
235            FLG_ERROR_80(1)  TYPE C,       "note 1383341
236            FLG_NO_BWKEY(1)  TYPE C,       "KZ: keine BWKEYs mehr vorhanden
237            FLG_NO_WERKS(1)  TYPE C,       "KZ: keine Werke  mehr vorhanden
238    *       OK-CODE(4)       TYPE C,
239            SAART_ALT(2),                  "Hilfsfeld bisherige Satzart
240            TABLINES LIKE SY-TABIX,        "Hilfsfeld für Tabellenzeilen
241    *       TAG(2)           TYPE C,       "Tag
242    *       VORJAHR(4)       TYPE C,       "Vorjahr
243    *       VORMONAT(2)      TYPE C,       "Vormonat
244            WEITERFLAG(1)    TYPE C,       "Hilfsfeld
245            CATTAKTIV        TYPE C,       "Hilfsfeld für CATT-Abläufe
246            MMPI_READ_NOTE   TYPE SY-DATUM,"note 487381
247    *
248    * zu 3.0 die ZAEHLER* - Definitionen von Type P auf SY-TABIX geändert
249    *    br 16.1.1995
250    *
251         ZAEHLER1            LIKE SY-TABIX, "Hilfsfeld
252         ZAEHLER2            LIKE SY-TABIX, "Hilfsfeld
253         ZAEHLER_MARD        LIKE SY-TABIX, "Anzahl umgesetzter MARD-Sätze
254         ZAEHLER_MARD_SCHIEF LIKE SY-TABIX, "Anz. MARD-Sätze mit Schiefstand
255         ZAEHLER_MBEW        LIKE SY-TABIX, "Anzahl umgesetzter MBEW-Sätze
256         ZAEHLER_MBEW_SCHIEF LIKE SY-TABIX, "Anz. MBEW-Sätze mit Schiefstand
257         ZAEHLER_EBEW        LIKE SY-TABIX, "Anzahl umgesetzter EBEW-Sätze
258         ZAEHLER_EBEW_SCHIEF LIKE SY-TABIX, "Anz. EBEW-Sätze mit Schiefstand
259         ZAEHLER_QBEW        LIKE SY-TABIX, "Anzahl umgesetzter QBEW-Sätze
260         ZAEHLER_QBEW_SCHIEF LIKE SY-TABIX, "Anz. QBEW-Sätze mit Schiefstand
261         ZAEHLER_OBEW        LIKE SY-TABIX, "ch/4.6A (wg. OBEW)
262         ZAEHLER_OBEW_SCHIEF LIKE SY-TABIX, "ch/4.6A (wg. OBEW)
263         ZAEHLER_WBEW        LIKE SY-TABIX, "Anzahl umgesetzter WBEW-Sätze
264         ZAEHLER_MCHB        LIKE SY-TABIX, "Anzahl umgesetzter MCHB-Sätze
265         ZAEHLER_MCHB_SCHIEF LIKE SY-TABIX, "Anz. MCHB-Sätze mit Schiefstand
266         ZAEHLER_MKOL        LIKE SY-TABIX, "Anzahl umgesetzter MCHB-Sätze
267         ZAEHLER_MKOL_SCHIEF LIKE SY-TABIX, "Anz. MCHB-Sätze mit Schiefstand
268         ZAEHLER_MSCA        LIKE SY-TABIX, "Anzahl umgesetzter MSCA-Sätze
269         ZAEHLER_MSCA_SCHIEF LIKE SY-TABIX, "Anz. MSCA-Sätze mit Schiefstand
270         ZAEHLER_MSKA        LIKE SY-TABIX, "Anzahl umgesetzter MSKA-Sätze
271         ZAEHLER_MSKA_SCHIEF LIKE SY-TABIX, "Anz. MSKA-Sätze mit Schiefstand
272         ZAEHLER_MSKU        LIKE SY-TABIX, "Anzahl umgesetzter MSKU-Sätze
273         ZAEHLER_MSKU_SCHIEF LIKE SY-TABIX, "Anz. MSKU-Sätze mit Schiefstand
274         ZAEHLER_MSLB        LIKE SY-TABIX, "Anzahl umgesetzter MSLB-Sätze
275         ZAEHLER_MSLB_SCHIEF LIKE SY-TABIX, "Anz. MSLB-Sätze mit Schiefstand
276         ZAEHLER_MSPR        LIKE SY-TABIX, "Anzahl umgesetzter MSPR-Sätze
277         ZAEHLER_MSPR_SCHIEF LIKE SY-TABIX, "Anz. MSPR-Sätze mit Schiefstand
278         ZAEHLER_MSOA        LIKE SY-TABIX, "Anzahl umgesetzter MSOA-Sätze
279         ZAEHLER_MSSA        LIKE SY-TABIX, "Anzahl umgesetzter MSSA-Sätze
280         ZAEHLER_MSSL        LIKE SY-TABIX, "Anzahl umgesetzter MSSL-Sätze
281         ZAEHLER_MSSQ        LIKE SY-TABIX, "Anzahl umgesetzter MSSQ-Sätze
282         ZAEHLER_J_1AINFMBW        LIKE SY-TABIX.   "Inflationsfelder
283
284    *------------------------------------------------------------------
285    *           Definitionen
286    *------------------------------------------------------------------
287
288    DATA:   AKTYPH LIKE T130M-AKTYP VALUE 'H',  "Hinzufuegen
289            AKTYPA LIKE T130M-AKTYP VALUE 'A',  "Anzeigen
290            GRENZE LIKE SY-TABIX    VALUE 200,  "Max. Zeilenzahl für DB-Zugr
291            RESET_INV   LIKE MARD-KZILL,        "Reset Inventurkennzeichen
292            RESET_DATS  LIKE RM03Q-DATUM,       "Reset Inventurkennzeichen
293            RESET_CHAR1 LIKE RM03Q-KZINV,       "Reset Inventurkennzeichen
294            SAPMM03M(8) VALUE 'SAPMM03M',       "Für Zugriff auf T130S
295            XWERT(1)    VALUE 'X',              "X-Flag
296    *--     Performance-Tuning defaultmäßig eingeschaltet ab 4.5B:
297    *       note 3118178
298            SWITCH_ON_TUNE(1) VALUE ' ',        "Performance-Tuning-Flag
299    *       SWITCH_ON_TUNE(1) VALUE 'X',        "Performance-Tuning-Flag
300            MARD_UPD,                           "Kennz, ob MARD/MBEW/MCHB
301            MBEW_UPD,                           "zum Buchungskreis
302            MCHB_UPD,                           "bereits upgedated.
303            MKOL_UPD,
304            MSKA_UPD,
305            MSKU_UPD,
306            MSLB_UPD,
307            MSPR_UPD,
308            MSSQ_UPD,
309            MSSA_UPD,
310            EBEW_UPD,
311            QBEW_UPD,
312            OBEW_UPD,                       "ch/4.6A (wg. OBEW)
313            MSSL_UPD,
314            WBEW_UPD,
315            J_1AINFMBW_UPD,
316            MBEW_LOCK,                      "ch zu 4.0c
317            MARC_LOCK.                      "
318
319
320    * ALV-convertions...
321
322    type-pools: slis.
323
324    constants:
325      gc_y              type c             value 'Y',
326      gc_save           type c             value 'A',
327      gc_sbal_fields    type dd02l-tabname VALUE 'MMRMDATING1',
328      gc_ausnahme_satz  type dd02l-tabname value 'RMMMPERI_AUSNAHME_SATZ',
329      gc_bwkey_ml_error type dd02l-tabname value 'RMMMPERI_BWKEY_ML_ERROR',
330      gc_ausnahme_neg   type dd02l-tabname value 'RMMMPERI_AUSNAHME_NEG'.
331
332
333    data: gt_fieldcat_sbal         type slis_t_fieldcat_alv,
334          gt_fieldcat_a_satz       type slis_t_fieldcat_alv,
335          gt_fieldcat_bwkey_ml_err type slis_t_fieldcat_alv,
336          gt_fieldcat_ausnahme_neg type slis_t_fieldcat_alv,
337          gs_layout_sbal           type slis_layout_alv,
338          gt_eventtab_sbal         type slis_t_event,
339          gt_eventtab_appends      type slis_t_event,
340          gt_AUSNAHME_NEG          like ausnahme_neg occurs 0.
341
342    types: tt_log1 type TAB_MMRMDATING1.
343    types: begin of tt_log3 ,
344              t type TAB_MMRMDATING1,
345           end of tt_log3.
346    types: tt_log2 type tt_log3 occurs 0.
347    data: gt_log type TAB_MMRMDATING1.
348    data: gtt_log type table of tt_log3.
349
350    data: gt_commentary type SLIS_T_LISTHEADER.
351
352    data: gv_repid type syst-repid.
353    data: gt_start_index type syst-tabix.
354
355    * note 1161524 schedule manager
356     INCLUDE RKASMAWF.
357     INCLUDE SCHEDMAN_EVENTS.
358     DATA: GS_KEY     LIKE SCHEDMAN_KEY.
359     DATA: LS_DETAIL  LIKE SCHEDMAN_DETAIL_USER.
360     DATA: LT_SELKRIT LIKE SCHEDMAN_SELKRIT OCCURS 0 WITH HEADER LINE.
361     DATA: LS_CUST    LIKE SCHEDMAN_CUSTOMER.
362
363     DATA: LS_WITEM   LIKE SCMA_WITEM.
364     DATA: LD_APLSTAT    LIKE SMMAIN-APLSTAT VALUE '0'.
365     DATA: LS_SCMA_EVENT LIKE SCMA_EVENT.
366
367     "note 2186338
368     DATA: gd_ident   LIKE sy-uzeit.
*--- End of MM13QTOP - 368 lines ---

----------------------------------------------------------------------------------------------------
Include          RKASMAWF                                  Level 2    Page 3
Object           Z_DEL_HIST_ENTRIES                        Lines 9
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:32
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
Include          SCHEDMAN_EVENTS                           Level 2    Page 4
Object           Z_DEL_HIST_ENTRIES                        Lines 7
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:32
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
Include          MM13QF00                                  Level 1    Page 5
Object           Z_DEL_HIST_ENTRIES                        Lines 2316
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:32
----------------------------------------------------------------------------------------------------
1      *----------------------------------------------------------------------
2      *  Up BERECHTIGUNGEN
3      *  Grundlegende Berechtigungsprüfung
4      *-----------------------------------------------------------------------
5      FORM BERECHTIGUNGEN.
6
7        IF RM03Q-KZINV = SPACE.
8             BERECHT_AKT = '50'.      "Perioden verschieben  neu
9        ELSE.
10            BERECHT_AKT = '51'.      "Initialisieren        neu
11       ENDIF.
12       AUTHORITY-CHECK OBJECT 'M_MATE_PER'
13            ID 'AKTPR' FIELD BERECHT_AKT
14            ID 'BUKRS' DUMMY.
15       IF SY-SUBRC NE 0.
16     *--- Keine Berechtigung mit neuen Berechtigungs-Aktivitäten
17     *
18     *---- Berechtigung mit veralteten Aktivitätstypen überprüfen mk/27.07.93
19     *--- (notwendig, da alte Aktivitäten nicht ordentlich dokumentierbar)
20         IF RM03Q-KZINV = SPACE.
21            BERECHT_AKT = '02'.      "Perioden verschieben  alt
22         ELSE.
23            BERECHT_AKT = '03'.      "Initialisieren        alt
24         ENDIF.
25         AUTHORITY-CHECK OBJECT 'M_MATE_PER'
26            ID 'AKTPR' FIELD BERECHT_AKT
27            ID 'BUKRS' DUMMY.
28         IF SY-SUBRC NE 0 AND RM03Q-KZINV = SPACE.
29           MESSAGE E864.
30         ENDIF.
31         IF SY-SUBRC NE 0 AND RM03Q-KZINV NE SPACE.
32            MESSAGE E865.
33         ENDIF.
34       ENDIF.
35
36     ENDFORM.
37     *-----------------------------------------------------------------------
38     *  Up ARBEITEN
39     * Hauptunterprogramm, das die Verarbeitung steuert
40     *-----------------------------------------------------------------------
41     FORM ARBEITEN.
42
43     *IF SY-DBSYS(3) NE 'ORA' OR SY-DBSYS(3) NE 'INF'
44     *OR SY-DBSYS(3) NE 'DB2' OR SY-DBSYS(3) NE 'DB4'
45     *OR SY-DBSYS(3) NE 'ABA' OR SY-DBSYS(3) NE 'SQL'
46     *OR SY-DBSYS(3) NE 'DB6' OR SY-DBSYS(3) NE 'MSS'.
47     *  CLEAR SWITCH_ON_TUNE.
48     *ENDIF.
49
50     *******************************************************************
51     IF I_XINCO EQ SPACE.   "d.h. verschieben        /ch zu 3.0F ->H: 50389
52       PERFORM SPERREN.
53     ENDIF.
54
55     IF FEHLERFLAG NE SPACE.
56        EXIT.
57     ENDIF.
58
59     SELECT SINGLE * FROM T130S
60               WHERE PGNAM = SAPMM03M.
61     IF SY-SUBRC NE 0
62     OR T130S-ANZUM = 0.   "ch/4.5b vorsichtshalber, da aus Custom. entfernt
63                                "Schiefstände können ja nicht mehr auftreten
64        T130S-ANZUM = 100.
65     ENDIF.
66
67     PERFORM BUKRS_TAB_FUELLEN.
68
69     DESCRIBE TABLE BUKRS_TAB LINES ZAEHLER1.
70     IF ZAEHLER1 = 0.                      "kein Buchungskreis gefunden
71        MOVE '01' TO AUSNAHME_TAB.
72        APPEND AUSNAHME_TAB.
73        EXIT.
74     ENDIF.
75
76     IF RM03Q-DATUM = 0 AND ( RM03Q-LFGJA = 0 OR RM03Q-LFMON = 0 ).
77        MOVE '02' TO AUSNAHME_TAB.
78        APPEND AUSNAHME_TAB.
79        EXIT.
80     ENDIF.
81
82     IF RM03Q-DATUM NE 0 AND ( RM03Q-LFGJA NE 0 OR RM03Q-LFMON NE 0 ).
83        MOVE '06' TO AUSNAHME_TAB.
84        APPEND AUSNAHME_TAB.
85        EXIT.
86     ENDIF.
87
88     *F RM03Q-KZINV = SPACE.         "dakt. zu 4.0c
89        PERFORM LESEN_MARV_SEQ.
90     *NDIF.                          "dakt. zu 4.0c
91
92     CLEAR FEHLERFLAG.
93     ZAEHLER_MARD = 0.
94     ZAEHLER_MARD_SCHIEF = 0.
95     ZAEHLER_MBEW = 0.
96     ZAEHLER_MBEW_SCHIEF = 0.
97     ZAEHLER_EBEW = 0.                 "neu zu 4.0
98     ZAEHLER_EBEW_SCHIEF = 0.          "
99     ZAEHLER_QBEW = 0.                 "
100    ZAEHLER_QBEW_SCHIEF = 0.          "
101    ZAEHLER_OBEW = 0.                 "ch/4.6A (wg. OBEW)
102    ZAEHLER_OBEW_SCHIEF = 0.          "ch/4.6A (wg. OBEW)
103    ZAEHLER_MCHB = 0.
104    ZAEHLER_MCHB_SCHIEF = 0.
105    ZAEHLER_MKOL = 0.
106    ZAEHLER_MKOL_SCHIEF = 0.
107    ZAEHLER_MSCA = 0.
108    ZAEHLER_MSCA_SCHIEF = 0.
109    ZAEHLER_MSKA = 0.
110    ZAEHLER_MSKA_SCHIEF = 0.
111    ZAEHLER_MSKU = 0.
112    ZAEHLER_MSKU_SCHIEF = 0.
113    ZAEHLER_MSLB = 0.
114    ZAEHLER_MSLB_SCHIEF = 0.
115    ZAEHLER_MSPR = 0.
116    ZAEHLER_MSPR_SCHIEF = 0.
117    ZAEHLER_MSOA = 0.
118    ZAEHLER_MSSA = 0.
119    ZAEHLER_MSSL = 0.
120    ZAEHLER_MSSQ = 0.
121    ZAEHLER_J_1AINFMBW = 0.                 "neu zu 4.0
122
123    LOOP AT BUKRS_TAB.
124    *--Zuerst werden die relevanten Buchungskreise ermittelt und die
125    *--Stammsätze ermittelt, in denen eine falsche Periode steht
126    *--Ab Release 3.0 werden auch die Sätze ermittelt, die einen
127    *--negativen Bestand zur Vorperiode haben               CH/23.08.94
128         IF BUKRS_TAB-MARVFLAG = SPACE AND RM03Q-KZINV = SPACE.
129              CLEAR AUSNAHME_TAB.
130              MOVE '03' TO AUSNAHME_TAB-AUSNA.
131              MOVE BUKRS_TAB-BUKRS TO AUSNAHME_TAB-BUKRS.
132              APPEND AUSNAHME_TAB.
133              CHECK SY-SUBRC NE SY-SUBRC.
134         ENDIF.
135         PERFORM PERIODE_ERMITTELN.
136         IF FEHLERFLAG NE SPACE.     "im Up PERIODE_ERMITTELN gesetzt
137            CHECK SY-SUBRC NE SY-SUBRC.
138         ENDIF.
139         PERFORM PERIODE_PRUEFEN.
140         IF FEHLERFLAG NE SPACE.     "im Up PERIODE_PRUEFEN gesetzt
141            CHECK SY-SUBRC NE SY-SUBRC.
142         ENDIF.
143
144    *****   NOTE 1082841 BEGIN   *****
145        IF RM03Q-KZINV IS INITIAL.       " ONLY FOR MMPV, NOT MMPI
146          CALL FUNCTION 'MMPV_DATE_CHECK'
147            EXPORTING
148                I_NEW_LFGJA  = BUKRS_TAB-JAHR
149                I_NEW_LFMON  = BUKRS_TAB-MONAT
150                I_BUKRS      = ''               " BUKRS_TAB-BUKRS
151                I_FY_VARIANT = T001-PERIV
152            EXCEPTIONS
153              MMPV_BLOCKED   = 1
154              ERROR_OCCURRED = 2.
155
156    *      if date check fails in one BUKRS, then terminate program
157           IF SY-SUBRC <> 0.
158              CLEAR AUSNAHME_TAB.
159              MOVE '99' TO AUSNAHME_TAB-AUSNA.
160              APPEND AUSNAHME_TAB.
161              WEITERFLAG = 'X'.
162              EXIT.                                   " EXIT LOOP
163           ENDIF.
164         ENDIF.
165    *****   NOTE 1082841 END   *****
166
167    * neu zu 4.6a: Prüfen, ob Warenbewegungen vorhanden sind, zu denen
168    *                      die Werte noch fortzuschreiben sind.
169         CALL FUNCTION 'MB_STATUS_SEPERATE_VALUATION'
170              EXPORTING
171                   BUKRS                      = bukrs_tab-bukrs
172    *         IMPORTING
173    *              STATUS                     =
174    *              ALL_COUNT                  =
175              EXCEPTIONS
176                   EXCEPTION_INTERNAL_ERROR   = 1
177                   EXCEPTION_ENTRIES_FOUND    = 2
178                   EXCEPTION_NO_ENTRIES_FOUND = 3
179                   OTHERS                     = 4 .
180         IF SY-SUBRC = 2.
181           CLEAR AUSNAHME_TAB.
182           MOVE '97' TO AUSNAHME_TAB-AUSNA.
183           MOVE BUKRS_TAB-BUKRS TO AUSNAHME_TAB-BUKRS.
184           APPEND AUSNAHME_TAB.
185           MOVE '98' TO AUSNAHME_TAB-AUSNA.
186           APPEND AUSNAHME_TAB.
187           if sy-msgty = 'E'.
188             FEHLERFLAG = 'X'.
189             if i_kzinv = space.
190               MOVE '93' TO AUSNAHME_TAB-AUSNA.
191               APPEND AUSNAHME_TAB.
192             else.
193               MOVE '91' TO AUSNAHME_TAB-AUSNA.
194               APPEND AUSNAHME_TAB.
195             endif.
196           endif.            "sy-msgty = 'E'.
197         ENDIF.              "EXCEPTION_ENTRIES_FOUND
198
199    *    neu zu 4.0C: Inventursperre bei Jahreswechsel
200         IF  I_KZINV = SPACE
201         AND BUKRS_TAB-JAHR NE BUKRS_TAB-VORJAHR.
202           PERFORM INVENTUR_SPERREN.
203         ENDIF.
204         IF FEHLERFLAG NE SPACE.     "im Up INVENTUR_SPERREN gesetzt
205            CHECK SY-SUBRC NE SY-SUBRC.
206         ENDIF.
207         PERFORM RELEVANTFLAG_SETZEN.
208         CHECK I_XMOVE EQ SPACE.     "d.h. prüfen     /ch zu 3.0F ->H: 50389
209         IF RM03Q-KZINV = SPACE.
210            PERFORM IN_BWKEY_ERMITTELN.
211            PERFORM IN_WERKS_ERMITTELN.            "CH/18.10.94
212            CLEAR FLG_NO_BWKEY.                    "CH/18.10.94
213            DO.                                    "CH/18.10.94
214              PERFORM IN_BWKEY_TEIL_ERMITTELN.     "CH/18.10.94
215              IF FLG_NO_BWKEY = XWERT.             "CH/18.10.94
216                EXIT.                              "CH/18.10.94
217              ENDIF.                               "CH/18.10.94
218              PERFORM MBEW_SCHIEF.
219              PERFORM EBEW_SCHIEF.      "neu zu 4.0
220              PERFORM QBEW_SCHIEF.      "neu zu 4.0
221              PERFORM OBEW_SCHIEF.      "ch/4.6A (wg. OBEW)
222    *         PERFORM WBEW_SCHIEF.      "entf. zu 4.0C, da keine WBEWH
223              "keine schiefstandermittlung für J_1AINFMBW    4.0
224            ENDDO.                                 "CH/18.10.94
225    *       PERFORM IN_WERKS_ERMITTELN.            "CH/18.10.94  s.o.
226            CLEAR FLG_NO_WERKS.                    "CH/18.10.94
227            DO.                                    "CH/18.10.94
228              PERFORM IN_WERKS_TEIL_ERMITTELN.     "CH/18.10.94
229              IF FLG_NO_WERKS = XWERT.             "CH/18.10.94
230                EXIT.                              "CH/18.10.94
231              ENDIF.                               "CH/18.10.94
232              PERFORM MARD_SCHIEF.
233              PERFORM MCHB_SCHIEF.
234              PERFORM MKOL_SCHIEF.
235              PERFORM MSCA_SCHIEF.
236              PERFORM MSKA_SCHIEF.
237              PERFORM MSKU_SCHIEF.
238              PERFORM MSLB_SCHIEF.
239              PERFORM MSPR_SCHIEF.
240            ENDDO.                                 "CH/18.10.94
241    *---- gibt es zu viele schiefe Stammsätze wird abgebrochen
242            ZAEHLER1 = ZAEHLER_MBEW_SCHIEF + ZAEHLER_MARD_SCHIEF +
243                       ZAEHLER_EBEW_SCHIEF + ZAEHLER_QBEW_SCHIEF +    "4.0
244                       ZAEHLER_OBEW_SCHIEF +            "ch/4.6A (wg. OBEW)
245    *                  ZAEHLER_WBEW_SCHIEF +                 "deakt zu 4.0C
246                       ZAEHLER_MCHB_SCHIEF + ZAEHLER_MKOL_SCHIEF +
247                       ZAEHLER_MSCA_SCHIEF + ZAEHLER_MSKA_SCHIEF +
248                       ZAEHLER_MSKU_SCHIEF + ZAEHLER_MSLB_SCHIEF +
249                       ZAEHLER_MSPR_SCHIEF.
250            IF ZAEHLER1 GT T130S-ANZUM.
251               CLEAR AUSNAHME_TAB.
252               MOVE '07' TO AUSNAHME_TAB-AUSNA.
253               APPEND AUSNAHME_TAB.
254               WEITERFLAG = 'X'.
255               EXIT.
256            ENDIF.
257         ENDIF.
258    ENDLOOP.
259
260    IF RM03Q-KZINV IS INITIAL.
261      DESCRIBE TABLE AUSNAHME_NEG LINES ZAEHLER1.
262      IF ZAEHLER1 > 0.
263    *-- Es gibt negative Bestandsfelder zur Vorperiode
264        CLEAR AUSNAHME_TAB.
265        MOVE '94' TO AUSNAHME_TAB-AUSNA.
266        APPEND AUSNAHME_TAB.
267        WEITERFLAG = 'X'.
268      ENDIF.
269    ENDIF.
270
271    IF WEITERFLAG NE SPACE.   " zu viele Stammsätze mit falscher Periode
272       PERFORM ENTSPERREN.
273       EXIT.
274    ENDIF.
275
276    "v note 3009750
277    IF i_xinco EQ space.
278      LOOP AT bukrs_tab.
279        CHECK bukrs_tab-relevantflag NE space.
280
281        "will be dequeued in next BUKRS_TAB loop accordingly
282        CALL FUNCTION 'ENQUEUE_E_NSDM_PERIOD'
283          EXPORTING
284            bukrs          = bukrs_tab-bukrs
285            _wait          = 15
286          EXCEPTIONS
287            foreign_lock   = 1
288            system_failure = 2
289            OTHERS         = 3.
290        IF sy-subrc <> 0.
291          CLEAR ausnahme_tab.
292          MOVE '72' TO ausnahme_tab-ausna.
293          MOVE bukrs_tab-bukrs TO ausnahme_tab-bukrs.
294          APPEND ausnahme_tab.
295
296          bukrs_tab-relevantflag = space.
297          MODIFY bukrs_tab.
298        ENDIF.
299      ENDLOOP.
300    ENDIF.
301    "^ note 3009750
302
303    IF I_XINCO EQ SPACE.        "d.h. verschieben     /ch zu 3.0F ->H: 50389
304      LOOP AT BUKRS_TAB.
305         CLEAR: MARD_UPD,      "ch 01.02.96 zu 3.0D, damit die entspr.
306                MBEW_UPD,      "Update-Routinen nur einmal ausgeführt
307                MCHB_UPD,      "werden.
308                MKOL_UPD,      "ab hier neu zu 3.1H /ch
309                MSKA_UPD,
310                MSKU_UPD,
311                MSLB_UPD,
312                MSPR_UPD,
313                MSSQ_UPD,
314                MSSA_UPD,
315                MSSL_UPD,
316                EBEW_UPD,          "4.0
317                QBEW_UPD,          "4.0
318                OBEW_UPD,          "ch/4.6A (wg. OBEW)
319                WBEW_UPD,          "4.0
320                J_1AINFMBW_UPD.    "4.0
321         CLEAR FLG_ML_ERROR.                              "ch/23.02.95 s.o.
322         CHECK BUKRS_TAB-RELEVANTFLAG NE SPACE.
323    *-----  die noch relevanten Buchungskreise werden umgesetzt
324    *-----  die MBEW umsetzen
325    *    PERFORM MARV_UMSETZEN.  "zu 3.0F n.u. verlagert wg ML-Fehlermeldung
326                                 "  in IN_BWKEY_ERMITELN           /ch
327         PERFORM IN_BWKEY_ERMITTELN.
328         PERFORM IN_WERKS_ERMITTELN.            "CH/18.10.94
329         PERFORM MARV_UMSETZEN.       "s.o.
330         CLEAR FLG_NO_BWKEY.                    "CH/18.10.94
331         DO.                                    "CH/18.10.94
332           PERFORM IN_BWKEY_TEIL_ERMITTELN.     "CH/18.10.94
333           IF FLG_NO_BWKEY = XWERT.             "CH/18.10.94
334             EXIT.                              "CH/18.10.94
335           ENDIF.                               "CH/18.10.94
336           IF RM03Q-KZINV NE SPACE.
337    *        Initialisierung der Bestandssegmente nur noch notwendig, wenn
338    *        bisherige Periode > neue Periode
339             IF  ( BUKRS_TAB-LFGJA > BUKRS_TAB-JAHR )
340             OR  (   BUKRS_TAB-LFGJA = BUKRS_TAB-JAHR
341                 AND BUKRS_TAB-LFMON > BUKRS_TAB-MONAT ).
342               PERFORM MBEW_UPDATE_INI.
343               PERFORM EBEW_UPDATE_INI.
344               PERFORM QBEW_UPDATE_INI.
345               PERFORM OBEW_UPDATE_INI.         "ch/4.6A (wg. OBEW)
346               PERFORM WBEW_UPDATE_INI.
347               "kein init für J_1AINFMBW
348             ENDIF.
349           ENDIF.
350    *      Neu ab 3.0: Es werden jetzt auch die ML-Sätze pro Bewertungskreis
351    *      berücksichtigt                          CH/23.02.95
352    *      Neu ab 4.5B: ML wird jetzt nur noch dynamisch verschoben
353    *      --> ML-Verschiebung hier deaktivieren   CH/26.01.99
354    *      LOOP AT IN_BWKEY.
355    *       IF IN_BWKEY-VBWKE NE SPACE.
356    *        SELECT SINGLE * FROM T001K                "ch zu 3.0F, da
357    *               WHERE BWKEY = IN_BWKEY-VBWKE.      "sonst Fehlermeldung
358    *        CHECK SY-SUBRC = 0 AND T001K-MLBWA NE SPACE.    "im Protokoll
359    *        CALL FUNCTION 'CKML_F_CKML1_PERIOD_APPEND_BWK'
360    *             EXPORTING
361    *                  BWKEY = IN_BWKEY-VBWKE
362    *                  LFMON = BUKRS_TAB-MONAT
363    *                  LFGJA = BUKRS_TAB-JAHR
364    *                  VMMON = BUKRS_TAB-VORMONAT  "neu zu 4.0/ch
365    *                  VMGJA = BUKRS_TAB-VORJAHR       "
366    *                  VJMON = BUKRS_TAB-VJMONAT       "
367    *                  VJGJA = BUKRS_TAB-VJJAHR       "
368    *                  KZINV = RM03Q-KZINV            "
369    *             EXCEPTIONS
370    *                   OTHERS = 1.
371    *        IF SY-SUBRC NE 0.
372    *          CLEAR BWKEY_ML_ERROR.
373    *          BWKEY_ML_ERROR-BUKRS = BUKRS_TAB-BUKRS.
374    *          BWKEY_ML_ERROR-BWKEY = IN_BWKEY-VBWKE.
375    *          APPEND BWKEY_ML_ERROR.
376    *          FLG_ML_ERROR = XWERT.
377    *        ENDIF.
378    *       ENDIF.
379    *      ENDLOOP.
380           LOOP AT IN_BWKEY.
381             SELECT SINGLE * FROM T001K                         "note 743246
382                    WHERE BWKEY = IN_BWKEY-VBWKE.               "
383             CHECK SY-SUBRC = 0 AND T001K-MLBWA NE SPACE.       "
384
385             CALL FUNCTION 'MLCCS_CLOSE_PERIOD'
386                  EXPORTING
387                       I_BWKEY        = IN_BWKEY-VBWKE
388                       I_NEW_LFGJA    = bUKRS_TAB-JAHR
389                       I_NEW_LFMON    = bUKRS_TAB-MONAT
390                  EXCEPTIONS
391                       ERROR_OCCURRED = 1
392                       OTHERS         = 2 .
393             IF SY-SUBRC <> 0.
394               BWKEY_ML_ERROR-BUKRS = BUKRS_TAB-BUKRS.          "note 743246
395               BWKEY_ML_ERROR-BWKEY = IN_BWKEY-VBWKE.           "note 743246
396               APPEND BWKEY_ML_ERROR.
397               FLG_ML_ERROR = XWERT.
398             ENDIF.
399           endloop.
400         ENDDO.                                 "CH/18.10.94
401    *-------- Meldung falls ML-Sätze nicht initialisiert:  "ch/23.02.95 s.o.
402    *-------- wieder deakt. zu 4.5B                        "ch/26.01.99 s.o.
403    *-------- zu 4.6 wieder aktiviert, da jetzt protokolliert wird, wenn
404    *-------- ein Fehler in der ML-Verwaltungstabelle aufgetreten ist.
405    *    note 1383341: add AUSNAHME 80 only once to avoid repeated printout of
406    *    collected entries in BWKEY_ML_ERROR
407         IF FLG_ML_ERROR = XWERT AND FLG_ERROR_80 IS INITIAL.
408           FLG_ERROR_80 = XWERT.
409           CLEAR AUSNAHME_TAB.
410           MOVE '80' TO AUSNAHME_TAB-AUSNA.
411           MOVE BUKRS_TAB-BUKRS TO AUSNAHME_TAB-BUKRS.
412           APPEND AUSNAHME_TAB.
413         ENDIF.
414    *------- die MARD, MCHB, und Sonderbestandstabellen umsetzen
415    *    PERFORM IN_WERKS_ERMITTELN.            "CH/18.10.94
416         CLEAR FLG_NO_WERKS.                    "CH/18.10.94
417         DO.                                    "CH/18.10.94
418           PERFORM IN_WERKS_TEIL_ERMITTELN.     "CH/18.10.94
419           IF FLG_NO_WERKS = XWERT.             "CH/18.10.94
420             EXIT.                              "CH/18.10.94
421           ENDIF.                               "CH/18.10.94
422           IF RM03Q-KZINV = SPACE.
423    *       IF BUKRS_TAB-JAHR NE BUKRS_TAB-VORJAHR. "Jahreswechsel
424    *          PERFORM MARD_UPDATE_JW.
425    *          PERFORM MCHB_UPDATE_JW.
426    *          PERFORM MKOL_UPDATE_JW.
427    *          PERFORM MSCA_UPDATE_JW.
428    *          PERFORM MSKA_UPDATE_JW.
429    *          PERFORM MSKU_UPDATE_JW.
430    *          PERFORM MSLB_UPDATE_JW.
431    *          PERFORM MSPR_UPDATE_JW.
432    *       ENDIF.
433           ELSE.
434    *        Initialisierung der Bestandssegmente nur noch notwendig, wenn
435    *        bisherige Periode > neue Periode
436             IF  ( BUKRS_TAB-LFGJA > BUKRS_TAB-JAHR )
437             OR  (   BUKRS_TAB-LFGJA = BUKRS_TAB-JAHR
438                 AND BUKRS_TAB-LFMON > BUKRS_TAB-MONAT ).
439               PERFORM MARD_UPDATE_INI.
440               PERFORM MCHB_UPDATE_INI.
441               PERFORM MKOL_UPDATE_INI.
442               PERFORM MSCA_UPDATE_INI.
443               PERFORM MSKA_UPDATE_INI.
444               PERFORM MSKU_UPDATE_INI.
445               PERFORM MSLB_UPDATE_INI.
446               PERFORM MSOA_UPDATE_INI.
447               PERFORM MSPR_UPDATE_INI.
448               PERFORM MSSA_UPDATE_INI.
449               PERFORM MSSL_UPDATE_INI.
450               PERFORM MSSQ_UPDATE_INI.
451               PERFORM MARC_UPDATE_INI.                       "note 1645304
452               PERFORM MSTB_UPDATE_INI.                       "note 1645304
453               PERFORM MSTE_UPDATE_INI.                       "note 1645304
454               PERFORM MSTQ_UPDATE_INI.                       "note 1645304
455             ENDIF.
456           ENDIF.
457         ENDDO.                                 "CH/18.10.94
458
459    * create new period record in material transaction table
460         CALL FUNCTION 'NSDM_MTDCSA_PERIODS'
461           EXPORTING
462             iv_bukrs = bukrs_tab-bukrs.
463
464    *------ Datenbankcommit, der Sperren läßt ( Theo, 15.06.1992 )
465         EXEC SQL.
466            COMMIT
467         ENDEXEC.
468
469    * precompact material transaction table for closed period
470         CALL FUNCTION 'NSDM_MTDCSA_PRECOMP'
471             STARTING NEW TASK 'SLOG_PRE'
472           EXPORTING
473             iv_bukrs = bukrs_tab-bukrs
474             iv_vvmgj = bukrs_tab-vmgja
475             iv_vvmmo = bukrs_tab-vmmon.
476
477    * precompact table ACDOCA_M_EXTRACT for closed period (2016.06.11)
478         CALL FUNCTION 'FML_ACDOCA_M_EXTRACT_PRECOMP'
479             STARTING NEW TASK 'FML_PRE'
480           EXPORTING
481             iv_bukrs = bukrs_tab-bukrs.
482
483    * compress tables MLDOC_EXTRAC and MLDOCCCS_EXTRACT
484    *  (only relevant when Material Ledger Actual Costing is activated)
485         CALL FUNCTION 'FCML4H_MLDOC_EXTRACT_COMPRESS'
486             STARTING NEW TASK 'FCML_ACT'
487           EXPORTING
488             iv_bukrs               = bukrs_tab-bukrs
489             iv_vmmon               = bukrs_tab-vmmon
490             iv_vmgja               = bukrs_tab-vmgja.
491
492    *KUGL, 5.11.95: Lock table again after COMMIT     "ch zu 3.0C
493         IF SWITCH_ON_TUNE = 'X'.                                  "KUGL
494           PERFORM DB_SPERRE.                                      "KUGL
495         ENDIF. "IF SWITCH_ON_TUNE = 'X'.                          "KUGL
496
497         "v note 3009750
498    *    release lock for company code
499         CALL FUNCTION 'DEQUEUE_E_NSDM_PERIOD'
500           EXPORTING
501             bukrs = bukrs_tab-bukrs.
502         "^ note 3009750
503
504    *-------- Meldung Buchungskreis umgesetzt
505         CLEAR AUSNAHME_TAB.
506         IF RM03Q-KZINV = SPACE.
507            MOVE '31' TO AUSNAHME_TAB-AUSNA.
508         ELSE.
509            MOVE '32' TO AUSNAHME_TAB-AUSNA.
510         ENDIF.
511         MOVE BUKRS_TAB-BUKRS TO AUSNAHME_TAB-BUKRS.
512         APPEND AUSNAHME_TAB.
513      ENDLOOP.
514    ENDIF.   "I_XINCO EQ SPACE. "d.h. verschieben     /ch zu 3.0F ->H: 50389
515
516    IF ZAEHLER_MBEW_SCHIEF = 0.
517    *-- alle relevanten MBEW-Sätze erfolgreich umgesetzt/initialisiert;
518    *-- die Anzahl steht im Feld ZAEHLER_MBEW
519      IF ZAEHLER_MBEW GT 0.
520       IF RM03Q-KZINV = SPACE.
521          CLEAR AUSNAHME_TAB.
522          MOVE '08' TO AUSNAHME_TAB-AUSNA.
523          APPEND AUSNAHME_TAB.
524       ELSE.
525          CLEAR AUSNAHME_TAB.
526          MOVE '17' TO AUSNAHME_TAB-AUSNA.
527          APPEND AUSNAHME_TAB.
528       ENDIF.
529      ENDIF.
530    ELSE.
531    *-- nicht alle relevanten MBEW-Sätze erfolgreich umgesetzt;
532    *-- die Anzahl der fehlgeschlagenen MBEW-Umsetzungen steht im Feld
533    *-- ZAEHLER_MBEW_SCHIEF, die Sätze in der Tabelle AUSNAHME_SATZ;
534    *-- die Anzahl Sätze,die korrekt umgesetzt wurden,steht in ZAEHLER_MBEW;
535       CLEAR AUSNAHME_TAB.
536       MOVE '09' TO AUSNAHME_TAB-AUSNA.
537       APPEND AUSNAHME_TAB.
538    ENDIF.
539
540    IF ZAEHLER_MARD_SCHIEF = 0.
541    *-- alle relevanten MARD-Sätze erfolgreich umgesetzt/initialisiert;
542    *-- die Anzahl steht im Feld ZAEHLER_MARD
543      IF ZAEHLER_MARD GT 0.
544       IF RM03Q-KZINV = SPACE.
545          CLEAR AUSNAHME_TAB.
546          MOVE '10' TO AUSNAHME_TAB-AUSNA.
547          APPEND AUSNAHME_TAB.
548       ELSE.
549          CLEAR AUSNAHME_TAB.
550          MOVE '18' TO AUSNAHME_TAB-AUSNA.
551          APPEND AUSNAHME_TAB.
552       ENDIF.
553      ENDIF.
554    ELSE.
555    *-- nicht alle relevanten MARD-Sätze erfolgreich umgesetzt;
556    *-- die Anzahl der fehlgeschlagenen MARD-Umsetzungen steht im Feld
557    *-- ZAEHLER_MARD_SCHIEF, die Sätze in der Tabelle AUSNAHME_SATZ;
558    *-- die Anzahl Sätze,die korrekt umgesetzt wurden,steht in ZAEHLER_MARD;
559       CLEAR AUSNAHME_TAB.
560       MOVE '11' TO AUSNAHME_TAB-AUSNA.
561       APPEND AUSNAHME_TAB.
562    ENDIF.
563
564    IF ZAEHLER_MCHB_SCHIEF = 0.
565    *-- alle relevanten MCHB-Sätze erfolgreich umgesetzt;
566    *-- die Anzahl steht im Feld ZAEHLER_MCHB
567      IF ZAEHLER_MCHB GT 0.
568       IF RM03Q-KZINV = SPACE.
569          CLEAR AUSNAHME_TAB.
570          MOVE '12' TO AUSNAHME_TAB-AUSNA.
571          APPEND AUSNAHME_TAB.
572       ELSE.
573          CLEAR AUSNAHME_TAB.
574          MOVE '19' TO AUSNAHME_TAB-AUSNA.
575          APPEND AUSNAHME_TAB.
576       ENDIF.
577      ENDIF.
578    ELSE.
579    *-- nicht alle relevanten MCHB-Sätze erfolgreich umgesetzt;
580    *-- die Anzahl der fehlgeschlagenen MCHB-Umsetzungen steht im Feld
581    *-- ZAEHLER_MCHB_SCHIEF, die Sätze in der Tabelle AUSNAHME_SATZ;
582    *-- die Anzahl Sätze,die korrekt umgesetzt wurden,steht in ZAEHLER_MCHB;
583       CLEAR AUSNAHME_TAB.
584       MOVE '13' TO AUSNAHME_TAB-AUSNA.
585       APPEND AUSNAHME_TAB.
586    ENDIF.
587
588    IF ZAEHLER_MKOL_SCHIEF = 0.
589    *-- alle relevanten MKOL-Sätze erfolgreich umgesetzt;
590    *-- die Anzahl steht im Feld ZAEHLER_MKOL
591      IF ZAEHLER_MKOL GT 0.
592       IF RM03Q-KZINV = SPACE.
593          CLEAR AUSNAHME_TAB.
594          MOVE '24' TO AUSNAHME_TAB-AUSNA.
595          APPEND AUSNAHME_TAB.
596       ELSE.
597          CLEAR AUSNAHME_TAB.
598          MOVE '25' TO AUSNAHME_TAB-AUSNA.
599          APPEND AUSNAHME_TAB.
600       ENDIF.
601      ENDIF.
602    ELSE.
603    *-- nicht alle relevanten MKOL-Sätze erfolgreich umgesetzt;
604    *-- die Anzahl der fehlgeschlagenen MKOL-Umsetzungen steht im Feld
605    *-- ZAEHLER_MKOL_SCHIEF, die Sätze in der Tabelle AUSNAHME_SATZ;
606    *-- die Anzahl Sätze,die korrekt umgesetzt wurden,steht in ZAEHLER_MKOL;
607       CLEAR AUSNAHME_TAB.
608       MOVE '26' TO AUSNAHME_TAB-AUSNA.
609       APPEND AUSNAHME_TAB.
610    ENDIF.
611
612    IF ZAEHLER_MSCA_SCHIEF = 0.
613    *-- alle relevanten MSCA-Sätze erfolgreich umgesetzt/initialisiert;
614    *-- die Anzahl steht im Feld ZAEHLER_MSCA
615      IF ZAEHLER_MSCA GT 0.
616       IF RM03Q-KZINV = SPACE.
617          CLEAR AUSNAHME_TAB.
618          MOVE '48' TO AUSNAHME_TAB-AUSNA.
619          APPEND AUSNAHME_TAB.
620       ELSE.
621          CLEAR AUSNAHME_TAB.
622          MOVE '49' TO AUSNAHME_TAB-AUSNA.
623          APPEND AUSNAHME_TAB.
624       ENDIF.
625      ENDIF.
626    ELSE.
627    *-- nicht alle relevanten MSCA-Sätze erfolgreich umgesetzt;
628    *-- die Anzahl der fehlgeschlagenen MSCA-Umsetzungen steht im Feld
629    *-- ZAEHLER_MSCA_SCHIEF, die Sätze in der Tabelle AUSNAHME_SATZ;
630    *-- die Anzahl Sätze,die korrekt umgesetzt wurden,steht in ZAEHLER_MSCA;
631       CLEAR AUSNAHME_TAB.
632       MOVE '50' TO AUSNAHME_TAB-AUSNA.
633       APPEND AUSNAHME_TAB.
634    ENDIF.
635
636    IF ZAEHLER_MSKA_SCHIEF = 0.
637    *-- alle relevanten MSKA-Sätze erfolgreich umgesetzt/initialisiert;
638    *-- die Anzahl steht im Feld ZAEHLER_MSKA
639      IF ZAEHLER_MSKA GT 0.
640       IF RM03Q-KZINV = SPACE.
641          CLEAR AUSNAHME_TAB.
642          MOVE '42' TO AUSNAHME_TAB-AUSNA.
643          APPEND AUSNAHME_TAB.
644       ELSE.
645          CLEAR AUSNAHME_TAB.
646          MOVE '43' TO AUSNAHME_TAB-AUSNA.
647          APPEND AUSNAHME_TAB.
648       ENDIF.
649      ENDIF.
650    ELSE.
651    *-- nicht alle relevanten MSKA-Sätze erfolgreich umgesetzt;
652    *-- die Anzahl der fehlgeschlagenen MSKA-Umsetzungen steht im Feld
653    *-- ZAEHLER_MSKA_SCHIEF, die Sätze in der Tabelle AUSNAHME_SATZ;
654    *-- die Anzahl Sätze,die korrekt umgesetzt wurden,steht in ZAEHLER_MSKA;
655       CLEAR AUSNAHME_TAB.
656       MOVE '44' TO AUSNAHME_TAB-AUSNA.
657       APPEND AUSNAHME_TAB.
658    ENDIF.
659
660    IF ZAEHLER_MSKU_SCHIEF = 0.
661    *-- alle relevanten MSKU-Sätze erfolgreich umgesetzt/initialisiert;
662    *-- die Anzahl steht im Feld ZAEHLER_MSKU
663      IF ZAEHLER_MSKU GT 0.
664       IF RM03Q-KZINV = SPACE.
665          CLEAR AUSNAHME_TAB.
666          MOVE '39' TO AUSNAHME_TAB-AUSNA.
667          APPEND AUSNAHME_TAB.
668       ELSE.
669          CLEAR AUSNAHME_TAB.
670          MOVE '40' TO AUSNAHME_TAB-AUSNA.
671          APPEND AUSNAHME_TAB.
672       ENDIF.
673      ENDIF.
674    ELSE.
675    *-- nicht alle relevanten MSKU-Sätze erfolgreich umgesetzt;
676    *-- die Anzahl der fehlgeschlagenen MARD-Umsetzungen steht im Feld
677    *-- ZAEHLER_MSKU_SCHIEF, die Sätze in der Tabelle AUSNAHME_SATZ;
678    *-- die Anzahl Sätze,die korrekt umgesetzt wurden,steht in ZAEHLER_MSKU;
679       CLEAR AUSNAHME_TAB.
680       MOVE '41' TO AUSNAHME_TAB-AUSNA.
681       APPEND AUSNAHME_TAB.
682    ENDIF.
683
684    IF ZAEHLER_MSLB_SCHIEF = 0.
685    *-- alle relevanten MSLB-Sätze erfolgreich umgesetzt/initialisiert;
686    *-- die Anzahl steht im Feld ZAEHLER_MSLB
687      IF ZAEHLER_MSLB GT 0.
688       IF RM03Q-KZINV = SPACE.
689          CLEAR AUSNAHME_TAB.
690          MOVE '33' TO AUSNAHME_TAB-AUSNA.
691          APPEND AUSNAHME_TAB.
692       ELSE.
693          CLEAR AUSNAHME_TAB.
694          MOVE '34' TO AUSNAHME_TAB-AUSNA.
695          APPEND AUSNAHME_TAB.
696       ENDIF.
697      ENDIF.
698    ELSE.
699    *-- nicht alle relevanten MSLB-Sätze erfolgreich umgesetzt;
700    *-- die Anzahl der fehlgeschlagenen MSLB-Umsetzungen steht im Feld
701    *-- ZAEHLER_MSLB_SCHIEF, die Sätze in der Tabelle AUSNAHME_SATZ;
702    *-- die Anzahl Sätze,die korrekt umgesetzt wurden,steht in ZAEHLER_MSLB;
703       CLEAR AUSNAHME_TAB.
704       MOVE '35' TO AUSNAHME_TAB-AUSNA.
705       APPEND AUSNAHME_TAB.
706    ENDIF.
707
708    *F ZAEHLER_MSOA_SCHIEF = 0.      "deakt. zu 4.0C
709    *-- alle relevanten MSOA-Sätze erfolgreich umgesetzt/initialisiert;
710    *-- die Anzahl steht im Feld ZAEHLER_MSOA
711      IF ZAEHLER_MSOA GT 0.
712       IF RM03Q-KZINV = SPACE.
713          CLEAR AUSNAHME_TAB.
714          MOVE '51' TO AUSNAHME_TAB-AUSNA.
715          APPEND AUSNAHME_TAB.
716       ELSE.
717          CLEAR AUSNAHME_TAB.
718          MOVE '52' TO AUSNAHME_TAB-AUSNA.
719          APPEND AUSNAHME_TAB.
720       ENDIF.
721      ENDIF.
722    *LSE.
723    *-- nicht alle relevanten MSOA-Sätze erfolgreich umgesetzt;
724    *-- die Anzahl der fehlgeschlagenen MSOA-Umsetzungen steht im Feld
725    *-- ZAEHLER_MSOA_SCHIEF, die Sätze in der Tabelle AUSNAHME_SATZ;
726    *-- die Anzahl Sätze,die korrekt umgesetzt wurden,steht in ZAEHLER_MSOA;
727    *  CLEAR AUSNAHME_TAB.
728    *  MOVE '53' TO AUSNAHME_TAB-AUSNA.
729    *  APPEND AUSNAHME_TAB.
730    *NDIF.
731
732    IF ZAEHLER_MSPR_SCHIEF = 0.
733    *-- alle relevanten MSPR-Sätze erfolgreich umgesetzt/initialisiert;
734    *-- die Anzahl steht im Feld ZAEHLER_MSPR --- neu zu 3.0 br 15.1.95
735      IF ZAEHLER_MSPR GT 0.
736       IF RM03Q-KZINV = SPACE.
737          CLEAR AUSNAHME_TAB.
738          MOVE '54' TO AUSNAHME_TAB-AUSNA.
739          APPEND AUSNAHME_TAB.
740       ELSE.
741          CLEAR AUSNAHME_TAB.
742          MOVE '55' TO AUSNAHME_TAB-AUSNA.
743          APPEND AUSNAHME_TAB.
744       ENDIF.
745      ENDIF.
746    ELSE.
747    *-- nicht alle relevanten MSPR-Sätze erfolgreich umgesetzt;
748    *-- die Anzahl der fehlgeschlagenen MSPR-Umsetzungen steht im Feld
749    *-- ZAEHLER_MSPR_SCHIEF, die Sätze in der Tabelle AUSNAHME_SATZ;
750    *-- die Anzahl Sätze,die korrekt umgesetzt wurden,steht in ZAEHLER_MSPR;
751       CLEAR AUSNAHME_TAB.
752       MOVE '56' TO AUSNAHME_TAB-AUSNA.
753       APPEND AUSNAHME_TAB.
754    ENDIF.
755
756    *F ZAEHLER_MSSA_SCHIEF = 0.     "deakt. zu 4.0C
757    *-- alle relevanten MSSA-Sätze erfolgreich umgesetzt/initialisiert;
758    *-- die Anzahl steht im Feld ZAEHLER_MSSA
759      IF ZAEHLER_MSSA GT 0.
760       IF RM03Q-KZINV = SPACE.
761          CLEAR AUSNAHME_TAB.
762          MOVE '45' TO AUSNAHME_TAB-AUSNA.
763          APPEND AUSNAHME_TAB.
764       ELSE.
765          CLEAR AUSNAHME_TAB.
766          MOVE '46' TO AUSNAHME_TAB-AUSNA.
767          APPEND AUSNAHME_TAB.
768       ENDIF.
769      ENDIF.
770    *LSE.
771    *-- nicht alle relevanten MSSA-Sätze erfolgreich umgesetzt;
772    *-- die Anzahl der fehlgeschlagenen MSSA-Umsetzungen steht im Feld
773    *-- ZAEHLER_MSSA_SCHIEF, die Sätze in der Tabelle AUSNAHME_SATZ;
774    *-- die Anzahl Sätze,die korrekt umgesetzt wurden,steht in ZAEHLER_MSSA;
775    *  CLEAR AUSNAHME_TAB.
776    *  MOVE '47' TO AUSNAHME_TAB-AUSNA.
777    *  APPEND AUSNAHME_TAB.
778    *NDIF.
779
780    *F ZAEHLER_MSSL_SCHIEF = 0.     "deakt. zu 4.0C
781    *-- alle relevanten MSSL-Sätze erfolgreich umgesetzt/initialisiert;
782    *-- die Anzahl steht im Feld ZAEHLER_MSSL
783      IF ZAEHLER_MSSL GT 0.
784       IF RM03Q-KZINV = SPACE.
785          CLEAR AUSNAHME_TAB.
786          MOVE '36' TO AUSNAHME_TAB-AUSNA.
787          APPEND AUSNAHME_TAB.
788       ELSE.
789          CLEAR AUSNAHME_TAB.
790          MOVE '37' TO AUSNAHME_TAB-AUSNA.
791          APPEND AUSNAHME_TAB.
792       ENDIF.
793      ENDIF.
794    *LSE.
795    *-- nicht alle relevanten MSSL-Sätze erfolgreich umgesetzt;
796    *-- die Anzahl der fehlgeschlagenen MSSL-Umsetzungen steht im Feld
797    *-- ZAEHLER_MSSL_SCHIEF, die Sätze in der Tabelle AUSNAHME_SATZ;
798    *-- die Anzahl Sätze,die korrekt umgesetzt wurden,steht in ZAEHLER_MSSL;
799    *  CLEAR AUSNAHME_TAB.
800    *  MOVE '38' TO AUSNAHME_TAB-AUSNA.
801    *  APPEND AUSNAHME_TAB.
802    *NDIF.
803
804    *F ZAEHLER_MSSQ_SCHIEF = 0.   "deakt. zu 4.0C
805    *-- alle relevanten MSSQ-Sätze erfolgreich umgesetzt/initialisiert;
806    *-- die Anzahl steht im Feld ZAEHLER_MSSQ  -- neu zu 3.0 br 15.1.95
807      IF ZAEHLER_MSSQ GT 0.
808       IF RM03Q-KZINV = SPACE.
809          CLEAR AUSNAHME_TAB.
810          MOVE '57' TO AUSNAHME_TAB-AUSNA.
811          APPEND AUSNAHME_TAB.
812       ELSE.
813          CLEAR AUSNAHME_TAB.
814          MOVE '58' TO AUSNAHME_TAB-AUSNA.
815          APPEND AUSNAHME_TAB.
816       ENDIF.
817      ENDIF.
818    *LSE.
819    *-- nicht alle relevanten MSSQ-Sätze erfolgreich umgesetzt;
820    *-- die Anzahl der fehlgeschlagenen MSSQ-Umsetzungen steht im Feld
821    *-- ZAEHLER_MSSQ_SCHIEF, die Sätze in der Tabelle AUSNAHME_SATZ;
822    *-- die Anzahl Sätze,die korrekt umgesetzt wurden,steht in ZAEHLER_MSSQ;
823    *  CLEAR AUSNAHME_TAB.
824    *  MOVE '59' TO AUSNAHME_TAB-AUSNA.
825    *  APPEND AUSNAHME_TAB.
826    *NDIF.
827
828    IF ZAEHLER_EBEW_SCHIEF = 0.
829    *-- alle relevanten EBEW-Sätze erfolgreich umgesetzt/initialisiert;
830    *-- die Anzahl steht im Feld ZAEHLER_EBEW  -- neu zu 4.0 / ch
831      IF ZAEHLER_EBEW GT 0.
832       IF RM03Q-KZINV = SPACE.
833          CLEAR AUSNAHME_TAB.
834          MOVE '60' TO AUSNAHME_TAB-AUSNA.      "erfolgr. umgesetzt
835          APPEND AUSNAHME_TAB.
836       ELSE.
837          CLEAR AUSNAHME_TAB.
838          MOVE '61' TO AUSNAHME_TAB-AUSNA.      "erfolgr. initialisiert
839          APPEND AUSNAHME_TAB.
840       ENDIF.
841      ENDIF.
842    ELSE.
843    *-- nicht alle relevanten EBEW-Sätze erfolgreich umgesetzt;
844       CLEAR AUSNAHME_TAB.
845       MOVE '62' TO AUSNAHME_TAB-AUSNA.         "nicht erf. umgesetzt
846       APPEND AUSNAHME_TAB.
847    ENDIF.
848
849    IF ZAEHLER_QBEW_SCHIEF = 0.
850    *-- alle relevanten QBEW-Sätze erfolgreich umgesetzt/initialisiert;
851    *-- die Anzahl steht im Feld ZAEHLER_QBEW  -- neu zu 4.0 / ch
852      IF ZAEHLER_QBEW GT 0.
853       IF RM03Q-KZINV = SPACE.
854          CLEAR AUSNAHME_TAB.
855          MOVE '63' TO AUSNAHME_TAB-AUSNA.      "erfolgr. umgesetzt
856          APPEND AUSNAHME_TAB.
857       ELSE.
858          CLEAR AUSNAHME_TAB.
859          MOVE '64' TO AUSNAHME_TAB-AUSNA.      "erfolgr. initialisiert
860          APPEND AUSNAHME_TAB.
861       ENDIF.
862      ENDIF.
863    ELSE.
864    *-- nicht alle relevanten QBEW-Sätze erfolgreich umgesetzt;
865       CLEAR AUSNAHME_TAB.
866       MOVE '65' TO AUSNAHME_TAB-AUSNA.         "nicht erf. umgesetzt
867       APPEND AUSNAHME_TAB.
868    ENDIF.
869
870    IF ZAEHLER_OBEW_SCHIEF = 0.                 "ch/4.6A (wg. OBEW)
871    *-- alle relevanten OBEW-S#tze erfolgreich umgesetzt/initialisiert;
872    *-- die Anzahl steht im Feld ZAEHLER_OBEW
873      IF ZAEHLER_OBEW GT 0.
874       IF RM03Q-KZINV = SPACE.
875          CLEAR AUSNAHME_TAB.
876          MOVE '69' TO AUSNAHME_TAB-AUSNA.      "erfolgr. umgesetzt
877          APPEND AUSNAHME_TAB.
878       ELSE.
879          CLEAR AUSNAHME_TAB.
880          MOVE '70' TO AUSNAHME_TAB-AUSNA.      "erfolgr. initialisiert
881          APPEND AUSNAHME_TAB.
882       ENDIF.
883      ENDIF.
884    ELSE.
885    *-- nicht alle relevanten OBEW-S#tze erfolgreich umgesetzt;
886       CLEAR AUSNAHME_TAB.
887       MOVE '71' TO AUSNAHME_TAB-AUSNA.         "nicht erf. umgesetzt
888       APPEND AUSNAHME_TAB.
889    ENDIF.                                      "ch/4.6A (wg. OBEW)
890
891    *F ZAEHLER_WBEW_SCHIEF = 0.
892    *-- alle relevanten WBEW-Sätze erfolgreich umgesetzt/initialisiert;
893    *-- die Anzahl steht im Feld ZAEHLER_WBEW  -- neu zu 4.0 / ch
894      IF ZAEHLER_WBEW GT 0.
895       IF RM03Q-KZINV = SPACE.
896          CLEAR AUSNAHME_TAB.
897          MOVE '66' TO AUSNAHME_TAB-AUSNA.      "erfolgr. umgesetzt
898          APPEND AUSNAHME_TAB.
899       ELSE.
900          CLEAR AUSNAHME_TAB.
901          MOVE '67' TO AUSNAHME_TAB-AUSNA.      "erfolgr. initialisiert
902          APPEND AUSNAHME_TAB.
903       ENDIF.
904      ENDIF.
905    *LSE.
906    *-- nicht alle relevanten WBEW-Sätze erfolgreich umgesetzt;
907    *  CLEAR AUSNAHME_TAB.
908    *  MOVE '68' TO AUSNAHME_TAB-AUSNA.         "nicht erf. umgesetzt
909    *  APPEND AUSNAHME_TAB.
910    *NDIF.
911
912    *-- alle relevanten J_1AINFMBW-Sätze erfolgreich umgesetzt;
913    *-- die Anzahl steht im Feld ZAEHLER_J_1AINFMBW        neu zu 4.0 / ch
914    *   (J_1AINFMBW wird bei Initialisierung und Schiefstandermittlung
915    *   nicht berücksichtigt)
916      IF ZAEHLER_EBEW GT 0.
917       IF RM03Q-KZINV = SPACE.
918          CLEAR AUSNAHME_TAB.
919          MOVE '85' TO AUSNAHME_TAB-AUSNA.      "erfolgr. umgesetzt
920          APPEND AUSNAHME_TAB.
921       ENDIF.
922      ENDIF.
923
924    *-- zusätzliche Abschlußinformation
925    IF RM03Q-KZINV = SPACE.
926       CLEAR AUSNAHME_TAB.
927       MOVE '14' TO AUSNAHME_TAB-AUSNA.
928       APPEND AUSNAHME_TAB.
929    ELSE.
930       CLEAR AUSNAHME_TAB.
931       MOVE '16' TO AUSNAHME_TAB-AUSNA.
932       APPEND AUSNAHME_TAB.
933    ENDIF.
934
935    ENDFORM.
936
937    *-----------------------------------------------------------------------
938    *  Up AUSGABE
939    * Hauptunterprogramm, das die Ausgabe steuert
940    *-----------------------------------------------------------------------
941    FORM AUSGABE.
942
943    data: l_log like line of gt_log,
944          l_KEY TYPE SLIS_LISTHEADER-KEY,       "Commentary key
945          L_TDLINE TYPE TLINE-TDLINE.
946    data: L_ERROR_FLAG(1).
947
948    IF gs_layout_sbal-list_append IS INITIAL.                  "note 1383341
949
950    PERFORM INITIALIZE_ALV_OUTPUT.
951
952    PERFORM ENTSPERREN.
953
954    "v note 2186338
955    CALL FUNCTION 'MESSAGES_INITIALIZE'
956      EXPORTING
957        I_NO_DUPLICATE_COUNT     = '0'
958      IMPORTING
959        E_IDENTIFICATION         = gd_ident.
960    "^ note 2186338
961
962    *-- Sortierung der Meldungen nach der Reihenfolge in der T139A
963    LOOP AT AUSNAHME_TAB.
964       SELECT SINGLE * FROM T139A
965                WHERE AUSNA = AUSNAHME_TAB-AUSNA.
966       IF SY-SUBRC = 0.
967          MOVE T139A-SORTF TO AUSNAHME_TAB-SORTF.
968          MODIFY AUSNAHME_TAB.
969       ENDIF.
970    ENDLOOP.
971    SORT AUSNAHME_TAB BY SORTF.
972
973    *EAVE TO LIST-PROCESSING.
974    SET PF-STATUS 'YYYY'.
975    *  perform skip.
976    *  write text-001 to l_log-msgtext.
977    *  append l_log to gt_log.
978    *  perform skip.
979    *Ausgabe des Modus (neu zu 3.0f/ch -> Hinweis: 50389)
980    IF I_KZINV = SPACE.
981      IF     I_XCOMP NE SPACE.
982        write text-090 to l_log-msgtext.
983        append l_log to gt_log.
984        "note 2186338
985        PERFORM message_store
986          USING 'MM' 'I' '899' l_log-msgtext ' ' ' ' ' '.
987      ELSEIF I_XINCO NE SPACE.
988        write text-091 to l_log-msgtext.
989        append l_log to gt_log.
990        "note 2186338
991        PERFORM message_store
992          USING 'MM' 'I' '899' l_log-msgtext ' ' ' ' ' '.
993      ELSEIF I_XMOVE NE SPACE.
994        write text-092 to l_log-msgtext.
995        append l_log to gt_log.
996        "note 2186338
997        PERFORM message_store
998          USING 'MM' 'I' '899' l_log-msgtext ' ' ' ' ' '.
999      ENDIF.
1000     perform skip.
1001   ENDIF.
1002
1003   concatenate text-015 sy-mandt into l_log-msgtext.
1004   append l_log to gt_log.
1005   "note 2186338
1006   PERFORM message_store
1007     USING 'MM' 'I' '899' l_log-msgtext ' ' ' ' ' '.
1008   IF ( NOT RM03Q-DATUM IS INITIAL ) AND ( RM03Q-LFMON IS INITIAL AND
1009        RM03Q-LFGJA IS INITIAL ).
1010          concatenate  text-017 rm03q-datum into l_log-msgtext.
1011          append l_log to gt_log.
1012          "note 2186338
1013          PERFORM message_store
1014            USING 'MM' 'I' '899' l_log-msgtext ' ' ' ' ' '.
1015   ENDIF.
1016
1017   IF ( RM03Q-DATUM IS INITIAL ) AND ( ( NOT RM03Q-LFMON IS INITIAL ) OR
1018    ( NOT RM03Q-LFGJA IS INITIAL ) ).
1019          concatenate TEXT-016 RM03Q-LFMON RM03Q-LFGJA into l_log-msgtext.
1020          append l_log to gt_log.
1021          "note 2186338
1022          PERFORM message_store
1023            USING 'MM' 'I' '899' l_log-msgtext ' ' ' ' ' '.
1024   ENDIF.
1025     perform skip.
1026     perform skip.
1027
1028   * note 1383341: call subroutine AUSGABE recursively to do all other
1029   * output into only one spool within event end of list.
1030     perform change_event_with_display using 'AUSGABE'.
1031     EXIT.
1032   ENDIF.                                                     "note 1383341
1033
1034     perform change_event using space.                        "note 1383341
1035     GS_LAYOUT_SBAL-LIST_APPEND = 'X'.                        "note 1383341
1036
1037     gt_start_index = 1.
1038   *-- Ausgabe der Meldungen eventuell mit Zusatzinformationen
1039   LOOP AT AUSNAHME_TAB from gt_start_index.
1040      gt_start_index = gt_start_index + 1.
1041      SELECT SINGLE * FROM T139A
1042                  WHERE AUSNA = AUSNAHME_TAB-AUSNA.
1043      IF T139A-ABBRU NE SPACE.
1044         write TEXT-002 to l_log-msgtext.
1045         append l_log to gt_log.
1046         "note 2186338
1047         PERFORM message_store
1048           USING 'MM' 'E' '899' l_log-msgtext ' ' ' ' ' '.
1049         L_ERROR_FLAG = 'X'.  "note 3153435
1050         perform skip.
1051      ENDIF.
1052   *-- Buchungskreis im Kurztext einsetzen
1053      IF T139A-KTEXT CA '$'.
1054         REPLACE '$$$$' WITH AUSNAHME_TAB-BUKRS INTO T139A-KTEXT.
1055      ENDIF.
1056   *-- Text in der sprachabhängigen Tabelle suchen und ausgeben
1057      SELECT SINGLE * FROM T139B
1058                WHERE SPRAS = SY-LANGU
1059                AND   AUSNA = AUSNAHME_TAB-AUSNA.
1060      IF SY-SUBRC = 0.
1061         IF T139B-KTEXT CA '$'.
1062            REPLACE '$$$$' WITH AUSNAHME_TAB-BUKRS INTO T139B-KTEXT.
1063         ENDIF.
1064         write T139B-KTEXT to l_log-msgtext.
1065         append l_log to gt_log.
1066         "note 2186338
1067         PERFORM message_store
1068           USING 'MM' 'I' '899' l_log-msgtext ' ' ' ' ' '.
1069      ELSE.
1070         write T139A-KTEXT to l_log-msgtext.
1071         append l_log to gt_log.
1072         "note 2186338
1073         PERFORM message_store
1074           USING 'MM' 'I' '899' l_log-msgtext ' ' ' ' ' '.
1075      ENDIF.
1076   *-- Zusätzliche Angaben
1077      IF AUSNAHME_TAB-AUSNA = '05'.    "Falsche Periode in MARV
1078         concatenate TEXT-018 AUSNAHME_TAB-LFMON AUSNAHME_TAB-LFGJA
1079                into l_log-msgtext.
1080         append l_log to gt_log.
1081         "note 2186338
1082         PERFORM message_store
1083           USING 'MM' 'E' '899' l_log-msgtext ' ' ' ' ' '.
1084         L_ERROR_FLAG = 'X'.
1085      ENDIF.
1086
1087      IF AUSNAHME_TAB-AUSNA = '07'.     "Abbr., da zu viele Materialien mit
1088   *      SKIP.                          "anderer laufender Periode
1089         perform change_event_with_display using 'AUSNA_07'.
1090         L_ERROR_FLAG = 'X'.
1091      ENDIF.
1092
1093   ** Meldungen zur erfolgreichen Umsetzung
1094      IF AUSNAHME_TAB-AUSNA = '08'.
1095   *      WRITE: (40) TEXT-006, ZAEHLER_MBEW.
1096         write: ZAEHLER_MBEW to l_log-msgtext.
1097         concatenate TEXT-006 l_log-msgtext into l_log-msgtext.
1098         append l_log to gt_log.
1099         "note 2186338
1100         PERFORM message_store
1101           USING 'MM' 'I' '899' l_log-msgtext ' ' ' ' ' '.
1102      ENDIF.
1103      IF AUSNAHME_TAB-AUSNA = '10'.
1104   *      WRITE: (40) TEXT-006, ZAEHLER_MARD.
1105         write: ZAEHLER_MARD to l_log-msgtext.
1106         concatenate TEXT-006 l_log-msgtext into l_log-msgtext.
1107         append l_log to gt_log.
1108         "note 2186338
1109         PERFORM message_store
1110           USING 'MM' 'I' '899' l_log-msgtext ' ' ' ' ' '.
1111      ENDIF.
1112      IF AUSNAHME_TAB-AUSNA = '12'.
1113   *      WRITE: (40) TEXT-006, ZAEHLER_MCHB.
1114         write ZAEHLER_MCHB to l_log-msgtext.
1115         concatenate TEXT-006 l_log-msgtext into l_log-msgtext.
1116         append l_log to gt_log.
1117         "note 2186338
1118         PERFORM message_store
1119           USING 'MM' 'I' '899' l_log-msgtext ' ' ' ' ' '.
1120      ENDIF.
1121      IF AUSNAHME_TAB-AUSNA = '24'.
1122   *      WRITE: (40) TEXT-006, ZAEHLER_MKOL.
1123         write ZAEHLER_MKOL to l_log-msgtext.
1124         concatenate TEXT-006 l_log-msgtext into l_log-msgtext.
1125         append l_log to gt_log.
1126         "note 2186338
1127         PERFORM message_store
1128           USING 'MM' 'I' '899' l_log-msgtext ' ' ' ' ' '.
1129      ENDIF.
1130      IF AUSNAHME_TAB-AUSNA = '33'.
1131   *      WRITE: (40) TEXT-006, ZAEHLER_MSLB.
1132         write ZAEHLER_MSLB to l_log-msgtext.
1133         concatenate TEXT-006 l_log-msgtext into l_log-msgtext.
1134         append l_log to gt_log.
1135         "note 2186338
1136         PERFORM message_store
1137           USING 'MM' 'I' '899' l_log-msgtext ' ' ' ' ' '.
1138      ENDIF.
1139      IF AUSNAHME_TAB-AUSNA = '36'.
1140   *      WRITE: (40) TEXT-006, ZAEHLER_MSSL.
1141         write ZAEHLER_MSSL to l_log-msgtext.
1142         concatenate TEXT-006 l_log-msgtext into l_log-msgtext.
1143         append l_log to gt_log.
1144         "note 2186338
1145         PERFORM message_store
1146           USING 'MM' 'I' '899' l_log-msgtext ' ' ' ' ' '.
1147      ENDIF.
1148      IF AUSNAHME_TAB-AUSNA = '39'.
1149   *      WRITE: (40) TEXT-006, ZAEHLER_MSKU.
1150         write ZAEHLER_MSKU to l_log-msgtext.
1151         concatenate TEXT-006 l_log-msgtext into l_log-msgtext.
1152         append l_log to gt_log.
1153         "note 2186338
1154         PERFORM message_store
1155           USING 'MM' 'I' '899' l_log-msgtext ' ' ' ' ' '.
1156      ENDIF.
1157      IF AUSNAHME_TAB-AUSNA = '42'.
1158   *      WRITE: (40) TEXT-006, ZAEHLER_MSKA.
1159         write ZAEHLER_MSKA to l_log-msgtext.
1160         concatenate TEXT-006 l_log-msgtext into l_log-msgtext.
1161         append l_log to gt_log.
1162         "note 2186338
1163         PERFORM message_store
1164           USING 'MM' 'I' '899' l_log-msgtext ' ' ' ' ' '.
1165      ENDIF.
1166      IF AUSNAHME_TAB-AUSNA = '45'.
1167   *      WRITE: (40) TEXT-006, ZAEHLER_MSSA.
1168         write ZAEHLER_MSSA to l_log-msgtext.
1169         concatenate TEXT-006 l_log-msgtext into l_log-msgtext.
1170         append l_log to gt_log.
1171         "note 2186338
1172         PERFORM message_store
1173           USING 'MM' 'I' '899' l_log-msgtext ' ' ' ' ' '.
1174      ENDIF.
1175      IF AUSNAHME_TAB-AUSNA = '48'.
1176   *      WRITE: (40) TEXT-006, ZAEHLER_MSCA.
1177         write ZAEHLER_MSCA to l_log-msgtext.
1178         concatenate TEXT-006 l_log-msgtext into l_log-msgtext.
1179         append l_log to gt_log.
1180         "note 2186338
1181         PERFORM message_store
1182           USING 'MM' 'I' '899' l_log-msgtext ' ' ' ' ' '.
1183      ENDIF.
1184      IF AUSNAHME_TAB-AUSNA = '51'.
1185   *      WRITE: (40) TEXT-006, ZAEHLER_MSOA.
1186         write ZAEHLER_MSOA to l_log-msgtext.
1187         concatenate TEXT-006 l_log-msgtext into l_log-msgtext.
1188         append l_log to gt_log.
1189         "note 2186338
1190         PERFORM message_store
1191           USING 'MM' 'I' '899' l_log-msgtext ' ' ' ' ' '.
1192      ENDIF.
1193      IF AUSNAHME_TAB-AUSNA = '54'.
1194   *      WRITE: (40) TEXT-006, ZAEHLER_MSPR.
1195         write ZAEHLER_MSPR to l_log-msgtext.
1196         concatenate TEXT-006 l_log-msgtext into l_log-msgtext.
1197         append l_log to gt_log.
1198         "note 2186338
1199         PERFORM message_store
1200           USING 'MM' 'I' '899' l_log-msgtext ' ' ' ' ' '.
1201      ENDIF.
1202      IF AUSNAHME_TAB-AUSNA = '57'.
1203   *      WRITE: (40) TEXT-006, ZAEHLER_MSSQ.
1204         write ZAEHLER_MSSQ to l_log-msgtext.
1205         concatenate TEXT-006 l_log-msgtext into l_log-msgtext.
1206         append l_log to gt_log.
1207         "note 2186338
1208         PERFORM message_store
1209           USING 'MM' 'I' '899' l_log-msgtext ' ' ' ' ' '.
1210      ENDIF.
1211      IF AUSNAHME_TAB-AUSNA = '60'.
1212   *      WRITE: (40) TEXT-006, ZAEHLER_EBEW.        "ch zu 4.0
1213         write ZAEHLER_EBEW to l_log-msgtext.
1214         concatenate TEXT-006 l_log-msgtext into l_log-msgtext.
1215         append l_log to gt_log.
1216         "note 2186338
1217         PERFORM message_store
1218           USING 'MM' 'I' '899' l_log-msgtext ' ' ' ' ' '.
1219      ENDIF.
1220      IF AUSNAHME_TAB-AUSNA = '63'.
1221   *      WRITE: (40) TEXT-006, ZAEHLER_QBEW.        "ch zu 4.0
1222         write ZAEHLER_QBEW to l_log-msgtext.
1223         concatenate TEXT-006 l_log-msgtext into l_log-msgtext.
1224         append l_log to gt_log.
1225         "note 2186338
1226         PERFORM message_store
1227           USING 'MM' 'I' '899' l_log-msgtext ' ' ' ' ' '.
1228      ENDIF.
1229      IF AUSNAHME_TAB-AUSNA = '69'.                 "ch/4.6A (wg. OBEW)
1230   *      WRITE: (40) TEXT-006, ZAEHLER_OBEW.
1231         write ZAEHLER_OBEW to l_log-msgtext.
1232         concatenate TEXT-006 l_log-msgtext into l_log-msgtext.
1233         append l_log to gt_log.
1234         "note 2186338
1235         PERFORM message_store
1236           USING 'MM' 'I' '899' l_log-msgtext ' ' ' ' ' '.
1237      ENDIF.
1238      IF AUSNAHME_TAB-AUSNA = '66'.
1239   *      WRITE: (40) TEXT-006, ZAEHLER_WBEW.        "ch zu 4.0
1240         write ZAEHLER_WBEW to l_log-msgtext.
1241         concatenate TEXT-006 l_log-msgtext into l_log-msgtext.
1242         append l_log to gt_log.
1243         "note 2186338
1244         PERFORM message_store
1245           USING 'MM' 'I' '899' l_log-msgtext ' ' ' ' ' '.
1246      ENDIF.
1247      IF AUSNAHME_TAB-AUSNA = '85'.
1248   *      WRITE: (40) TEXT-006, ZAEHLER_J_1AINFMBW.  "ch zu 4.0
1249         write ZAEHLER_J_1AINFMBW to l_log-msgtext.
1250         concatenate TEXT-006 l_log-msgtext into l_log-msgtext.
1251         append l_log to gt_log.
1252         "note 2186338
1253         PERFORM message_store
1254           USING 'MM' 'I' '899' l_log-msgtext ' ' ' ' ' '.
1255      ENDIF.
1256
1257   ** Meldungen zur erfolgreichen Initialisierung
1258      IF AUSNAHME_TAB-AUSNA = '17'.
1259   *      WRITE: (40) TEXT-012, ZAEHLER_MBEW.
1260         write ZAEHLER_MBEW to l_log-msgtext.
1261         concatenate TEXT-012 l_log-msgtext into l_log-msgtext.
1262         append l_log to gt_log.
1263         "note 2186338
1264         PERFORM message_store
1265           USING 'MM' 'I' '899' l_log-msgtext ' ' ' ' ' '.
1266      ENDIF.
1267      IF AUSNAHME_TAB-AUSNA = '18'.
1268   *      WRITE: (40) TEXT-012, ZAEHLER_MARD.
1269         write ZAEHLER_MARD to l_log-msgtext.
1270         concatenate TEXT-012 l_log-msgtext into l_log-msgtext.
1271         append l_log to gt_log.
1272         "note 2186338
1273         PERFORM message_store
1274           USING 'MM' 'I' '899' l_log-msgtext ' ' ' ' ' '.
1275      ENDIF.
1276      IF AUSNAHME_TAB-AUSNA = '19'.
1277   *      WRITE: (40) TEXT-012, ZAEHLER_MCHB.
1278         write ZAEHLER_MCHB to l_log-msgtext.
1279         concatenate TEXT-012 l_log-msgtext into l_log-msgtext.
1280         append l_log to gt_log.
1281         "note 2186338
1282         PERFORM message_store
1283           USING 'MM' 'I' '899' l_log-msgtext ' ' ' ' ' '.
1284      ENDIF.
1285      IF AUSNAHME_TAB-AUSNA = '25'.
1286   *      WRITE: (40) TEXT-012, ZAEHLER_MKOL.
1287         write ZAEHLER_MKOL to l_log-msgtext.
1288         concatenate TEXT-012 l_log-msgtext into l_log-msgtext.
1289         append l_log to gt_log.
1290         "note 2186338
1291         PERFORM message_store
1292           USING 'MM' 'I' '899' l_log-msgtext ' ' ' ' ' '.
1293      ENDIF.
1294      IF AUSNAHME_TAB-AUSNA = '34'.
1295   *      WRITE: (40) TEXT-012, ZAEHLER_MSLB.
1296         write ZAEHLER_MSLB to l_log-msgtext.
1297         concatenate TEXT-012 l_log-msgtext into l_log-msgtext.
1298         append l_log to gt_log.
1299         "note 2186338
1300         PERFORM message_store
1301           USING 'MM' 'I' '899' l_log-msgtext ' ' ' ' ' '.
1302      ENDIF.
1303      IF AUSNAHME_TAB-AUSNA = '37'.
1304   *      WRITE: (40) TEXT-012, ZAEHLER_MSSL.
1305         write ZAEHLER_MSSL to l_log-msgtext.
1306         concatenate TEXT-012 l_log-msgtext into l_log-msgtext.
1307         append l_log to gt_log.
1308         "note 2186338
1309         PERFORM message_store
1310           USING 'MM' 'I' '899' l_log-msgtext ' ' ' ' ' '.
1311     ENDIF.
1312      IF AUSNAHME_TAB-AUSNA = '40'.
1313   *      WRITE: (40) TEXT-012, ZAEHLER_MSKU.
1314         write ZAEHLER_MSKU to l_log-msgtext.
1315         concatenate TEXT-012 l_log-msgtext into l_log-msgtext.
1316         append l_log to gt_log.
1317         "note 2186338
1318         PERFORM message_store
1319           USING 'MM' 'I' '899' l_log-msgtext ' ' ' ' ' '.
1320      ENDIF.
1321      IF AUSNAHME_TAB-AUSNA = '43'.
1322   *      WRITE: (40) TEXT-012, ZAEHLER_MSKA.
1323         write ZAEHLER_MSKA to l_log-msgtext.
1324         concatenate TEXT-012 l_log-msgtext into l_log-msgtext.
1325         append l_log to gt_log.
1326         "note 2186338
1327         PERFORM message_store
1328           USING 'MM' 'I' '899' l_log-msgtext ' ' ' ' ' '.
1329      ENDIF.
1330      IF AUSNAHME_TAB-AUSNA = '46'.
1331   *      WRITE: (40) TEXT-012, ZAEHLER_MSSA.
1332         write ZAEHLER_MSSA to l_log-msgtext.
1333         concatenate TEXT-012 l_log-msgtext into l_log-msgtext.
1334         append l_log to gt_log.
1335         "note 2186338
1336         PERFORM message_store
1337           USING 'MM' 'I' '899' l_log-msgtext ' ' ' ' ' '.
1338      ENDIF.
1339      IF AUSNAHME_TAB-AUSNA = '49'.
1340   *      WRITE: (40) TEXT-012, ZAEHLER_MSCA.
1341         write ZAEHLER_MSCA to l_log-msgtext.
1342         concatenate TEXT-012 l_log-msgtext into l_log-msgtext.
1343         append l_log to gt_log.
1344         "note 2186338
1345         PERFORM message_store
1346           USING 'MM' 'I' '899' l_log-msgtext ' ' ' ' ' '.
1347      ENDIF.
1348      IF AUSNAHME_TAB-AUSNA = '52'.
1349   *      WRITE: (40) TEXT-012, ZAEHLER_MSOA.
1350         write ZAEHLER_MSOA to l_log-msgtext.
1351         concatenate TEXT-012 l_log-msgtext into l_log-msgtext.
1352         append l_log to gt_log.
1353         "note 2186338
1354         PERFORM message_store
1355           USING 'MM' 'I' '899' l_log-msgtext ' ' ' ' ' '.
1356     ENDIF.
1357      IF AUSNAHME_TAB-AUSNA = '55'.
1358   *      WRITE: (40) TEXT-012, ZAEHLER_MSPR.
1359         write ZAEHLER_MSPR to l_log-msgtext.
1360         concatenate TEXT-012 l_log-msgtext into l_log-msgtext.
1361         append l_log to gt_log.
1362         "note 2186338
1363         PERFORM message_store
1364           USING 'MM' 'I' '899' l_log-msgtext ' ' ' ' ' '.
1365      ENDIF.
1366      IF AUSNAHME_TAB-AUSNA = '58'.
1367   *      WRITE: (40) TEXT-012, ZAEHLER_MSSQ.
1368         write ZAEHLER_MSSQ to l_log-msgtext.
1369         concatenate TEXT-012 l_log-msgtext into l_log-msgtext.
1370         append l_log to gt_log.
1371         "note 2186338
1372         PERFORM message_store
1373           USING 'MM' 'I' '899' l_log-msgtext ' ' ' ' ' '.
1374      ENDIF.
1375      IF AUSNAHME_TAB-AUSNA = '61'.
1376   *      WRITE: (40) TEXT-012, ZAEHLER_EBEW.        "ch zu 4.0
1377         write ZAEHLER_EBEW to l_log-msgtext.
1378         concatenate TEXT-012 l_log-msgtext into l_log-msgtext.
1379         append l_log to gt_log.
1380         "note 2186338
1381         PERFORM message_store
1382           USING 'MM' 'I' '899' l_log-msgtext ' ' ' ' ' '.
1383     ENDIF.
1384      IF AUSNAHME_TAB-AUSNA = '64'.
1385   *      WRITE: (40) TEXT-012, ZAEHLER_QBEW.        "ch zu 4.0
1386         write ZAEHLER_QBEW to l_log-msgtext.
1387         concatenate TEXT-012 l_log-msgtext into l_log-msgtext.
1388         append l_log to gt_log.
1389         "note 2186338
1390         PERFORM message_store
1391           USING 'MM' 'I' '899' l_log-msgtext ' ' ' ' ' '.
1392     ENDIF.
1393      IF AUSNAHME_TAB-AUSNA = '70'.                 "ch/4.6A (wg. OBEW)
1394   *      WRITE: (40) TEXT-012, ZAEHLER_OBEW.
1395         write ZAEHLER_OBEW to l_log-msgtext.
1396         concatenate TEXT-012 l_log-msgtext into l_log-msgtext.
1397         append l_log to gt_log.
1398         "note 2186338
1399         PERFORM message_store
1400           USING 'MM' 'I' '899' l_log-msgtext ' ' ' ' ' '.
1401      ENDIF.
1402      IF AUSNAHME_TAB-AUSNA = '67'.
1403   *      WRITE: (40) TEXT-012, ZAEHLER_WBEW.        "ch zu 4.0
1404         write ZAEHLER_WBEW to l_log-msgtext.
1405         concatenate TEXT-012 l_log-msgtext into l_log-msgtext.
1406         append l_log to gt_log.
1407         "note 2186338
1408         PERFORM message_store
1409           USING 'MM' 'I' '899' l_log-msgtext ' ' ' ' ' '.
1410     ENDIF.
1411
1412   ** Meldungen, falls nicht umgesetzt werden konnte
1413      IF AUSNAHME_TAB-AUSNA = '09'.
1414         "Nicht alle Bewertungssätze konnten umgesetzt werden
1415         L_TDLINE = l_log-msgtext.
1416         PERFORM APPEND_COMMENTARY
1417                 USING 'S' L_KEY L_TDLINE
1418                 changing gt_commentary.
1419         perform change_event_with_display using 'AUSNA_09'.
1420         L_ERROR_FLAG = 'X'.
1421      ENDIF.
1422      IF AUSNAHME_TAB-AUSNA = '11'.
1423         "Nicht alle Lagerortsätze konnten umgesetzt werden
1424         L_TDLINE = l_log-msgtext.
1425         PERFORM APPEND_COMMENTARY
1426                 USING 'S' L_KEY L_TDLINE
1427                 changing gt_commentary.
1428         perform change_event_with_display using 'AUSNA_11'.
1429         L_ERROR_FLAG = 'X'.
1430      ENDIF.
1431      IF AUSNAHME_TAB-AUSNA = '13'.
1432          "Nicht alle Chargensätze konnten umgesetzt werden
1433         L_TDLINE = l_log-msgtext.
1434         PERFORM APPEND_COMMENTARY
1435                 USING 'S' L_KEY L_TDLINE
1436                 changing gt_commentary.
1437         perform change_event_with_display using 'AUSNA_13'.
1438         L_ERROR_FLAG = 'X'.
1439      ENDIF.
1440      IF AUSNAHME_TAB-AUSNA = '26'.
1441         "Nicht alle MTV/L.Konsisätze konnten umgesetzt werden
1442         L_TDLINE = l_log-msgtext.
1443         PERFORM APPEND_COMMENTARY
1444                 USING 'S' L_KEY L_TDLINE
1445                 changing gt_commentary.
1446         perform change_event_with_display using 'AUSNA_26'.
1447         L_ERROR_FLAG = 'X'.
1448      ENDIF.
1449      IF AUSNAHME_TAB-AUSNA = '35'.
1450         "Nicht alle L.Beistellungen konnten umgesetzt werden
1451         L_TDLINE = l_log-msgtext.
1452         PERFORM APPEND_COMMENTARY
1453                 USING 'S' L_KEY L_TDLINE
1454                 changing gt_commentary.
1455         perform change_event_with_display using 'AUSNA_35'.
1456         L_ERROR_FLAG = 'X'.
1457      ENDIF.
1458   *  IF AUSNAHME_TAB-AUSNA = '38'.         "deakt. zu 4.0C
1459   *     "Nicht alle Summen zu L.Beistellungen konnten umges. werden
1460   *     WRITE: (40) TEXT-006, ZAEHLER_MSSL.
1461   *     WRITE: (40) TEXT-007, ZAEHLER_MSSL_SCHIEF.
1462   *     WRITE TEXT-008.
1463   *     WRITE TEXT-022.
1464   *     LOOP AT AUSNAHME_SATZ.
1465   *      CHECK AUSNAHME_SATZ-AUSNA = '38'.
1466   *      WRITE: /4 AUSNAHME_SATZ-BUKRS,
1467   *                AUSNAHME_SATZ-MATNR , AUSNAHME_SATZ-WERKS,
1468   *                AUSNAHME_SATZ-LIFNR.
1469   *     ENDLOOP.
1470   *  ENDIF.
1471      IF AUSNAHME_TAB-AUSNA = '41'.
1472         "Nicht alle K.Konsignationssätze konnten umgesetzt werden
1473         L_TDLINE = l_log-msgtext.
1474         PERFORM APPEND_COMMENTARY
1475                 USING 'S' L_KEY L_TDLINE
1476                 changing gt_commentary.
1477         perform change_event_with_display using 'AUSNA_41'.
1478         L_ERROR_FLAG = 'X'.
1479      ENDIF.
1480      IF AUSNAHME_TAB-AUSNA = '44'.
1481         "Nicht alle K.Auftragsbestände konnten umgesetzt werden
1482         L_TDLINE = l_log-msgtext.
1483         PERFORM APPEND_COMMENTARY
1484                 USING 'S' L_KEY L_TDLINE
1485                 changing gt_commentary.
1486         perform change_event_with_display using 'AUSNA_44'.
1487         L_ERROR_FLAG = 'X'.
1488      ENDIF.
1489   *  IF AUSNAHME_TAB-AUSNA = '47'.  "deakt. zu 4.0C
1490   *     "Nicht alle Summen zu K.Auftragsbestände konnten umgesetzt werden
1491   *     WRITE: (40) TEXT-006, ZAEHLER_MSSA.
1492   *     WRITE: (40) TEXT-007, ZAEHLER_MSSA_SCHIEF.
1493   *     WRITE TEXT-008.
1494   *     WRITE TEXT-023.
1495   *     LOOP AT AUSNAHME_SATZ.
1496   *      CHECK AUSNAHME_SATZ-AUSNA = '47'.
1497   *      WRITE: /4 AUSNAHME_SATZ-BUKRS,
1498   *                AUSNAHME_SATZ-MATNR , AUSNAHME_SATZ-WERKS,
1499   *                AUSNAHME_SATZ-VBELN , AUSNAHME_SATZ-POSNR.
1500   *              " AUSNAHME_SATZ-ETENR.
1501   *     ENDLOOP.
1502   *  ENDIF.
1503      IF AUSNAHME_TAB-AUSNA = '50'.
1504         "Nicht alle K.Auftragsbestände beim Lief. konnten umgesetzt werden
1505         L_TDLINE = l_log-msgtext.
1506         PERFORM APPEND_COMMENTARY
1507                 USING 'S' L_KEY L_TDLINE
1508                 changing gt_commentary.
1509         perform change_event_with_display using 'AUSNA_50'.
1510         L_ERROR_FLAG = 'X'.
1511      ENDIF.
1512   *  IF AUSNAHME_TAB-AUSNA = '53'.  "deakt. zu 4.0C
1513   *     "Nicht alle Summen zu K.AuftrBestände beim Lief. konnten umges. w.
1514   *     WRITE: (40) TEXT-006, ZAEHLER_MSOA.
1515   *     WRITE: (40) TEXT-007, ZAEHLER_MSOA_SCHIEF.
1516   *     WRITE TEXT-008.
1517   *     WRITE TEXT-026.
1518   *     LOOP AT AUSNAHME_SATZ.
1519   *      CHECK AUSNAHME_SATZ-AUSNA = '53'.
1520   *      WRITE: /4 AUSNAHME_SATZ-BUKRS,
1521   *                AUSNAHME_SATZ-MATNR , AUSNAHME_SATZ-WERKS,
1522   *                AUSNAHME_SATZ-LIFNR , AUSNAHME_SATZ-VBELN,
1523   *                AUSNAHME_SATZ-POSNR ."AUSNAHME_SATZ-ETENR.
1524   *     ENDLOOP.
1525   *  ENDIF.
1526      IF AUSNAHME_TAB-AUSNA = '56'.
1527         "Nicht alle Projektbestände konnten umgesetzt werden
1528         L_TDLINE = l_log-msgtext.
1529         PERFORM APPEND_COMMENTARY
1530                 USING 'S' L_KEY L_TDLINE
1531                 changing gt_commentary.
1532         perform change_event_with_display using 'AUSNA_56'.
1533         L_ERROR_FLAG = 'X'.
1534      ENDIF.
1535   *  IF AUSNAHME_TAB-AUSNA = '59'.
1536   *     "Nicht alle Summen zu Projektbestände konnten umgesetzt werden
1537   *     WRITE: (40) TEXT-006, ZAEHLER_MSSQ.
1538   *     WRITE: (40) TEXT-007, ZAEHLER_MSSQ_SCHIEF.
1539   *     WRITE TEXT-008.
1540   *     WRITE TEXT-028.
1541   *     LOOP AT AUSNAHME_SATZ.
1542   *      CHECK AUSNAHME_SATZ-AUSNA = '59'.
1543   *      WRITE: /4 AUSNAHME_SATZ-BUKRS,
1544   *                AUSNAHME_SATZ-MATNR , AUSNAHME_SATZ-WERKS,
1545   *                AUSNAHME_SATZ-PSPNR.
1546   *     ENDLOOP.
1547   *  ENDIF.
1548
1549      IF AUSNAHME_TAB-AUSNA = '62'.                        "ch zu 4.0
1550         "Nicht alle Kundenauftrags-Bewertungen konnten umgesetzt werden
1551         L_TDLINE = l_log-msgtext.
1552         PERFORM APPEND_COMMENTARY
1553                 USING 'S' L_KEY L_TDLINE
1554                 changing gt_commentary.
1555         perform change_event_with_display using 'AUSNA_62'.
1556         L_ERROR_FLAG = 'X'.
1557      ENDIF.
1558      IF AUSNAHME_TAB-AUSNA = '65'.                        "ch zu 4.0
1559         "Nicht alle Projekt-Bewertungen konnten umgesetzt werden
1560         L_TDLINE = l_log-msgtext.
1561         PERFORM APPEND_COMMENTARY
1562                 USING 'S' L_KEY L_TDLINE
1563                 changing gt_commentary.
1564         perform change_event_with_display using 'AUSNA_65'.
1565         L_ERROR_FLAG = 'X'.
1566      ENDIF.
1567      IF AUSNAHME_TAB-AUSNA = '70'.                     "ch/4.6A (wg. OBEW)
1568         "Nicht alle Chargeable-Bewertungen konnten umgesetzt werden
1569         L_TDLINE = l_log-msgtext.
1570         PERFORM APPEND_COMMENTARY
1571                 USING 'S' L_KEY L_TDLINE
1572                 changing gt_commentary.
1573         perform change_event_with_display using 'AUSNA_70'.
1574         L_ERROR_FLAG = 'X'.
1575      ENDIF.                                            "ch/4.6A (wg. OBEW)
1576   *  IF AUSNAHME_TAB-AUSNA = '68'.      "deakt. zu 4.0C
1577   *     "Nicht alle Wirkstoff-Bewertungen konnten umgesetzt werden
1578   *     WRITE: (40) TEXT-006, ZAEHLER_WBEW.
1579   *     WRITE: (40) TEXT-007, ZAEHLER_WBEW_SCHIEF.
1580   *     WRITE TEXT-008.
1581   *     WRITE TEXT-031.                                 "#EC *
1582   *     LOOP AT AUSNAHME_SATZ.
1583   *      CHECK AUSNAHME_SATZ-AUSNA = '68'.
1584   *      WRITE: /4 AUSNAHME_SATZ-BUKRS,
1585   *                AUSNAHME_SATZ-MATNR , AUSNAHME_SATZ-BWKEY,
1586   *                AUSNAHME_SATZ-BWTAR , AUSNAHME_SATZ-MEINH.
1587   *     ENDLOOP.
1588   *  ENDIF.
1589
1590   *  Neu zu 3.0: ML-Initialisierung
1591      IF AUSNAHME_TAB-AUSNA = '80'.
1592         "Nicht alle ML-Sätze konnten initialisiert werden
1593         L_TDLINE = l_log-msgtext.
1594         PERFORM APPEND_COMMENTARY
1595                 USING 'S' L_KEY L_TDLINE
1596                 changing gt_commentary.
1597         perform change_event_with_display using 'AUSNA_80'.
1598      ENDIF.
1599      IF AUSNAHME_TAB-AUSNA = '94'.
1600        "Es sind negative Bestände zur Vorperiode vorhanden
1601         L_TDLINE = l_log-msgtext.
1602         PERFORM APPEND_COMMENTARY
1603                 USING 'S' L_KEY L_TDLINE
1604                 changing gt_commentary.
1605         perform change_event_with_display using 'AUSNA_94'.
1606      ENDIF.
1607      IF AUSNAHME_TAB-AUSNA NE '90' AND
1608         AUSNAHME_TAB-AUSNA NE '92'.
1609   *     SKIP 3.
1610         perform skip. perform skip. perform skip.
1611      ENDIF.
1612
1613      IF AUSNAHME_TAB-AUSNA = '99'.                "1082841
1614   *    note 1383341: output only using ALV list
1615   *     WRITE: TEXT-099.
1616        WRITE TEXT-099 to l_log-msgtext.
1617        append l_log to gt_log.
1618        "note 2186338
1619         PERFORM message_store
1620           USING 'MM' 'I' '899' l_log-msgtext ' ' ' ' ' '.
1621      ENDIF.
1622
1623   ENDLOOP.
1624   ** Ende der Ausgabe
1625
1626   *SKIP 3.
1627   perform skip. perform skip. perform skip.
1628
1629   WRITE TEXT-003 to l_log-msgtext.
1630   append l_log to gt_log.
1631   "note 2186338
1632   PERFORM message_store
1633     USING 'MM' 'I' '899' l_log-msgtext ' ' ' ' ' '.
1634
1635   * Falls die Periodenverschiebung abbricht, wird ab 3.0 eine entspr.
1636   * Informationsmeldung ausgegeben (Eine E- oder W-Meldung würde zum
1637   * Abbruch führen, ohne daß das Protokoll gedruckt wird.)   ch/06.02.1995
1638   IF T139A-ABBRU NE SPACE
1639   OR T139A-AUSNA EQ '93'.                   "ch zu 3.0E
1640     CLEAR CATTAKTIV.
1641     IMPORT CATTAKTIV FROM MEMORY ID 'CATT'.
1642     IF CATTAKTIV = 'X' AND SY-SUBRC = 0.
1643        "note 2186338
1644        PERFORM message_store
1645          USING 'M3' 'E' '705' ' ' ' ' ' ' ' '.
1646        MESSAGE E705.     "Periodenverschiebung ist abgebrochen
1647     ELSE.
1648        "note 2186338
1649        PERFORM message_store
1650          USING 'M3' 'E' '705' ' ' ' ' ' ' ' '.
1651        MESSAGE S705.     "Periodenverschiebung ist abgebrochen
1652     ENDIF.
1653   ENDIF.
1654
1655   perform display_alv.
1656
1657   *note 1161524
1658
1659   IF L_ERROR_FLAG = 'X'.
1660     LD_APLSTAT = '4'.       "Error-Message
1661   ELSE.
1662     LD_APLSTAT = '0'.       "Successful
1663   ENDIF.
1664   clear ls_scma_event.
1665   IF LD_APLSTAT = '4' OR LD_APLSTAT = 'A'.
1666     LS_SCMA_EVENT-WF_EVENT = CS_WF_EVENTS-ERROR.
1667   ELSE.
1668     LS_SCMA_EVENT-WF_EVENT = CS_WF_EVENTS-FINISHED.
1669   ENDIF.
1670   LS_SCMA_EVENT-WF_WITEM = WF_WITEM.
1671   LS_SCMA_EVENT-WF_OKEY  = WF_OKEY.
1672
1673   DATA: ls_message      LIKE  schedman_message.
1674   DATA: ld_balobject    TYPE  balobj_d  VALUE 'MATU'.
1675   DATA: ld_log_handle   TYPE  balloghndl.
1676
1677   "v note 2186338
1678   CALL FUNCTION 'MESSAGES_SAVE'
1679     EXPORTING
1680           i_balobject          = ld_balobject
1681           i_identification     = gd_ident
1682     IMPORTING
1683           e_log_handle         = ld_log_handle
1684     EXCEPTIONS
1685           NO_MESSAGES          = 1
1686           NOT_ACTIVE           = 2
1687           PROGRAM_ERROR        = 3
1688           SAVE_NOT_ALLOWED     = 4
1689           WRONG_IDENTIFICATION = 5.
1690
1691   if sy-subrc = 0.
1692     ls_message-log_handle = ld_log_handle.
1693   endif.
1694
1695   CALL FUNCTION 'MESSAGES_STOP'
1696     EXCEPTIONS
1697       OTHERS    = 4.
1698   IF SY-SUBRC <> 0.
1699   ENDIF.
1700   "^ note 2186338
1701
1702   CALL FUNCTION 'KPEP_MONI_CLOSE_RECORD'
1703          EXPORTING
1704              LS_KEY              = GS_KEY
1705              LS_SCMA_EVENT       = LS_SCMA_EVENT
1706              LS_MESSAGE          = LS_MESSAGE               "note 2186338
1707         CHANGING
1708              LD_APLSTAT  = LD_APLSTAT
1709         EXCEPTIONS
1710              NO_ID_GIVEN = 1
1711              OTHERS      = 2.
1712   Commit work.
1713
1714   ENDFORM.
1715
1716   AT USER-COMMAND.
1717    IF SY-UCOMM = 'BABA'.
1718       SUBMIT RMMMPERI VIA SELECTION-SCREEN.
1719    ENDIF.
1720
1721   * Hallo
1722   *-----------------------------------------------------------------------
1723   *  BUKRS_TAB_FUELLEN
1724   * BESTIMMEN DER RELEVANTEN BUCHUNGSKREISE, JE NACH BENUTZEREINGABE
1725   *-----------------------------------------------------------------------
1726   FORM BUKRS_TAB_FUELLEN.
1727
1728   *Loop über die T001 und schauen, ob die Bukrs-Einträge im Inter-
1729   *vall, das der Benutzer eingegeben hat.
1730
1731   *Zusätzlich wird die normierte Tabelle IN_BUKRS gefüllt, um einen
1732   *Massenzugriff absetzen zu können
1733   IN_BUKRS-METYP = 'I'.            "Inclusive
1734   IN_BUKRS-MEOPR = 'EQ'.           "Equal
1735
1736   SELECT * FROM T001.
1737
1738   PERFORM BERECHTIGUNG_BUKRS USING T001-BUKRS.
1739   CHECK SY-SUBRC = 0.
1740
1741   * Falls keine Einschränkung beim Buchungskreis -> alle Bukrs einlesen
1742   * ansonsten Selektionsparameter berücksichtigen
1743   IF ( NOT RM03Q-VBUKR IS INITIAL ) OR                    "K11K074462
1744      ( NOT RM03Q-BBUKR IS INITIAL ).                      "K11K074462
1745     IF RM03Q-BBUKR = SPACE.
1746        CHECK T001-BUKRS = RM03Q-VBUKR.
1747     ELSE.
1748        CHECK T001-BUKRS GE RM03Q-VBUKR             "#EC PORTABLE
1749          AND T001-BUKRS LE RM03Q-BBUKR.            "#EC PORTABLE
1750     ENDIF.
1751   ENDIF.                                                  "K11K074462
1752
1753   MOVE T001-BUKRS TO BUKRS_TAB-BUKRS.
1754   APPEND BUKRS_TAB.
1755
1756   MOVE T001-BUKRS TO IN_BUKRS-VBUKR.
1757   APPEND IN_BUKRS.
1758
1759   ENDSELECT.
1760
1761   SORT BUKRS_TAB BY BUKRS.
1762
1763   ENDFORM.
1764
1765   *-----------------------------------------------------------------------
1766   *    Berechtigung_Bukrs
1767   * Es wird geschaut, ob er den Bukrs verschieben/initialisieren darf
1768   *-----------------------------------------------------------------------
1769   FORM BERECHTIGUNG_BUKRS USING BUKRS.
1770
1771     IF RM03Q-KZINV = SPACE.
1772          BERECHT_AKT = '50'.      "Perioden verschieben  neu
1773     ELSE.
1774          BERECHT_AKT = '51'.      "Initialisieren        neu
1775     ENDIF.
1776     AUTHORITY-CHECK OBJECT 'M_MATE_PER'
1777          ID 'AKTPR' FIELD BERECHT_AKT
1778          ID 'BUKRS' FIELD BUKRS.
1779     IF SY-SUBRC NE 0.
1780   *--- Keine Berechtigung mit neuen Berechtigungs-Aktivitäten
1781   *---- Berechtigung mit veralteten Aktivitätstypen überprüfen mk/27.07.93
1782   *--- (notwendig, da alte Aktivitäten nicht ordentlich dokumentierbar)
1783       IF RM03Q-KZINV = SPACE.
1784          BERECHT_AKT = '02'.      "Perioden verschieben  alt
1785       ELSE.
1786          BERECHT_AKT = '03'.      "Initialisieren        alt
1787       ENDIF.
1788       AUTHORITY-CHECK OBJECT 'M_MATE_PER'
1789          ID 'AKTPR' FIELD BERECHT_AKT
1790          ID 'BUKRS' FIELD BUKRS.
1791     ENDIF.
1792
1793   ENDFORM.
1794
1795   *-----------------------------------------------------------------------
1796   *    IN_BWKEY_ERMITTELN
1797   * Die zum Buchungskreis gehörenden Bewertungskreise werden
1798   * ermittelt ( zum späteren Massenzugriff ).
1799   *
1800   * Ab Release 3.0: Die Bewertungskreise zum Buchungskreis werden in
1801   * IN_BWKEY_ALL eingelesen. IN_BWKEY wird jetzt in der Routine
1802   * IN_BWKEY_TEIL_ERMITTELN gefüllt und enthält diejenigen Bewertungs-
1803   * kreise, die für den nächsten DB-Zugriff relevant sind.
1804   *
1805   * Ab Release 3.0: Ermitteln derjenigen Bewertungskreise, die negative
1806   * Bestände ermöglichen und Festhalten in NB_BWKEY_ALL    CH/23.08.94
1807   *-----------------------------------------------------------------------
1808   FORM IN_BWKEY_ERMITTELN.
1809
1810   tables ckmlv.
1811   CLEAR:   IN_BWKEY_ALL, NB_BWKEY_ALL.
1812   REFRESH: IN_BWKEY_ALL, NB_BWKEY_ALL.
1813   IN_BWKEY_ALL-SIGN   = 'I'.
1814   IN_BWKEY_ALL-OPTION = 'EQ'.
1815   SELECT * FROM T001K
1816               WHERE BUKRS = BUKRS_TAB-BUKRS.
1817         MOVE T001K-BWKEY TO IN_BWKEY_ALL-LOW.
1818         APPEND IN_BWKEY_ALL.
1819   *     Prf., ob negative Bestände erlaubt sind
1820   *     ab 3.0d wird die interne Tabelle für die negtive-Bestand-Prf. nur
1821   *     aufgebaut, wenn negative Werte oder Mengen laut Einstiegsbild
1822   *     auch geprüft werden solllen.
1823         IF RM03Q-XNEGQ = SPACE OR RM03Q-XNEGV = SPACE.   "ch zu 3.0d
1824           IF T001K-XBKNG NE SPACE.
1825             NB_BWKEY_ALL = IN_BWKEY_ALL.
1826             APPEND NB_BWKEY_ALL.
1827           ENDIF.
1828         ENDIF.
1829         IF  RM03Q-KZINV NE SPACE
1830         AND T001K-MLBWA NE SPACE.
1831   *       no period initization if ML is productive in valuation area
1832           clear ckmlv.
1833           SELECT SINGLE * FROM  ckmlv
1834                 WHERE  bwkey       = T001K-BWKEY .
1835                 IF  ckmlv-mlbwi ne space.
1836                    MESSAGE E017(MM) WITH T001K-BWKEY.
1837                 endif.
1838         ENDIF.
1839   ENDSELECT.
1840
1841   DESCRIBE TABLE IN_BWKEY_ALL LINES ZAEHLER1.
1842     "sollte im realen System nicht vorkommen
1843   IF ZAEHLER1 = 0.
1844      APPEND IN_BWKEY_ALL.
1845   ENDIF.
1846
1847   SORT  IN_BWKEY_ALL.                    "CH/11.10.94
1848   SORT  NB_BWKEY_ALL.                    "CH/11.10.94
1849   *N_BWKEY_2 = ' ''0001'' , ''0003'' , ''0004'' '.
1850
1851   ENDFORM.
1852
1853   *-----------------------------------------------------------------------
1854   *    IN_BWKEY_TEIL_ERMITTELN           neu zu 3.0  -  CH/12.10.1994
1855   * Die Range-Tabellen IN_BWKEY_ALL und NB_BWKEY_ALL werden in kleinere
1856   * Häppchen für den DB-Zugriff aufgetilt.
1857   * Der DB-Zugriff erfolgt dann mittels IN_BWKEY und NB_BWKEY
1858   *-----------------------------------------------------------------------
1859   FORM IN_BWKEY_TEIL_ERMITTELN.
1860
1861   CLEAR:   IN_BWKEY, NB_BWKEY.
1862   REFRESH: IN_BWKEY, NB_BWKEY.
1863   CLEAR:   ZAEHLER2.
1864
1865   DESCRIBE TABLE IN_BWKEY_ALL LINES TABLINES.
1866   IF TABLINES > 0.
1867     LOOP AT IN_BWKEY_ALL.
1868       IN_BWKEY = IN_BWKEY_ALL.
1869       APPEND IN_BWKEY.
1870   *   Prüfen, ob negative Bestände vorkommen können.
1871   *   READ TABLE NB_BWKEY_ALL WITH KEY IN_BWKEY_ALL-low BINARY SEARCH.
1872       READ TABLE NB_BWKEY_ALL WITH KEY IN_BWKEY_ALL BINARY SEARCH. "zu 30d
1873       IF SY-SUBRC = 0.
1874         NB_BWKEY = NB_BWKEY_ALL.
1875         APPEND NB_BWKEY.
1876       ENDIF.
1877       DELETE IN_BWKEY_ALL.
1878       ZAEHLER2 = ZAEHLER2 + 1.
1879       IF ZAEHLER2 = GRENZE.
1880         EXIT.
1881       ENDIF.
1882     ENDLOOP.
1883   ELSE.
1884     FLG_NO_BWKEY = XWERT.
1885   ENDIF.
1886
1887   ENDFORM.
1888
1889   *-----------------------------------------------------------------------
1890   *    IN_WERKS_ERMITTELN
1891   * Die zum Buchungskreis gehörenden Werke werden
1892   * ermittelt ( zum späteren Massenzugriff ).
1893   *
1894   * Ab Release 3.0: Die Werke zum Buchungskreis werden in
1895   * IN_WERKS_ALL eingelesen. IN_WERKS wird jetzt in der Routine
1896   * IN_WERKS_TEIL_ERMITTELN gefüllt und enthält diejenigen Werke,
1897   * die für den nächsten DB-Zugriff relevant sind.
1898   *
1899   * Ab Release 3.0: Ermitteln der Werke, in denen negativer Bestand
1900   * erlaubt ist und Festhalten in NB_WERKS_ALL         CH/23.08.94
1901   *-----------------------------------------------------------------------
1902   FORM IN_WERKS_ERMITTELN.
1903
1904   CLEAR:   IN_WERKS_ALL, NB_WERKS_ALL.
1905   REFRESH: IN_WERKS_ALL, NB_WERKS_ALL.
1906   IN_WERKS_ALL-SIGN   = 'I'.
1907   IN_WERKS_ALL-OPTION = 'EQ'.
1908
1909   LOOP AT IN_BWKEY_ALL.
1910      SELECT * FROM T001W
1911                  WHERE BWKEY = IN_BWKEY_ALL-LOW.
1912            MOVE T001W-WERKS TO IN_WERKS_ALL-LOW.
1913            APPEND IN_WERKS_ALL.
1914   *        Festhalten der Werke, die negative Bestände erlauben
1915            IF ( T001W-BWKEY IN NB_BWKEY_ALL ) AND
1916               ( NOT NB_BWKEY_ALL[] IS INITIAL ).         "ch zu 3.0d
1917   *          ab 3.0d wird die interne Tabelle für die negtive-Bestand-Prf.
1918   *          nur aufgebaut, wenn negative Mengen laut
1919   *          Einstiegsbild auch geprüft werden solllen.
1920              IF RM03Q-XNEGQ = SPACE.                       "ch zu 3.0d
1921                NB_WERKS_ALL = IN_WERKS_ALL.
1922                APPEND NB_WERKS_ALL.
1923              ENDIF.
1924            ENDIF.
1925      ENDSELECT.
1926   ENDLOOP.
1927
1928   DESCRIBE TABLE IN_WERKS_ALL LINES ZAEHLER1. "sollte im realen System
1929   IF ZAEHLER1 = 0.                            "nicht vorkommen
1930      APPEND IN_WERKS_ALL.
1931   ENDIF.
1932
1933   ENDFORM.
1934
1935   *-----------------------------------------------------------------------
1936   *    IN_WERKS_TEIL_ERMITTELN           neu zu 3.0  -  CH/12.10.1994
1937   * Die Range-Tabellen IN_WERKS_ALL und NB_WERKS_ALL werden in kleinere
1938   * Häppchen für den DB-Zugriff aufgetilt.
1939   * Der DB-Zugriff erfolgt dann mittels IN_WERKS und NB_WERKS
1940   *-----------------------------------------------------------------------
1941   FORM IN_WERKS_TEIL_ERMITTELN.
1942
1943   CLEAR:   IN_WERKS, NB_WERKS.
1944   REFRESH: IN_WERKS, NB_WERKS.
1945   CLEAR:   ZAEHLER2.
1946
1947   DESCRIBE TABLE IN_WERKS_ALL LINES TABLINES.
1948   IF TABLINES > 0.
1949     LOOP AT IN_WERKS_ALL.
1950       IN_WERKS = IN_WERKS_ALL.
1951       APPEND IN_WERKS.
1952   *   Prüfen, ob negative Bestände vorkommen können.
1953   *   READ TABLE NB_WERKS_ALL WITH KEY IN_WERKS_ALL-LOW BINARY SEARCH.
1954       READ TABLE NB_WERKS_ALL WITH KEY IN_WERKS_ALL BINARY SEARCH. "zu 30d
1955       IF SY-SUBRC = 0.
1956         NB_WERKS = NB_WERKS_ALL.
1957         APPEND NB_WERKS.
1958       ENDIF.
1959       DELETE IN_WERKS_ALL.
1960       ZAEHLER2 = ZAEHLER2 + 1.
1961       IF ZAEHLER2 = GRENZE.
1962         EXIT.
1963       ENDIF.
1964     ENDLOOP.
1965   ELSE.
1966     FLG_NO_WERKS = XWERT.
1967   ENDIF.
1968
1969   ENDFORM.
1970
1971   *-----------------------------------------------------------------------
1972   *   PERIODE_ERMITTELN
1973   * Ermitteln der Periode, die nun gelten soll (nach Benutzereingabe).
1974   * Wurde ein Datum eingegeben müssen die Tabelle 009, 009B interpretiert
1975   * werden.
1976   *-----------------------------------------------------------------------
1977   FORM PERIODE_ERMITTELN.
1978
1979   DATA:  POPER LIKE T009B-POPER.
1980
1981   CLEAR FEHLERFLAG.
1982
1983   SELECT SINGLE * FROM T001                  "T001_PeriV
1984          WHERE BUKRS = BUKRS_TAB-BUKRS.
1985   IF ( RM03Q-LFGJA NE 0 AND RM03Q-LFMON NE 0 ).
1986      MOVE RM03Q-LFMON TO POPER.
1987      CALL FUNCTION 'PERIODENANFANG_ERMITTELN'
1988           EXPORTING
1989                EPERIV = T001-PERIV
1990                EPERJJ = RM03Q-LFGJA
1991                EPOPER = POPER
1992           IMPORTING
1993                IVONTG = DATUM       "Erster Tag der Periode
1994           EXCEPTIONS
1995                PERIODE_NICHT_VORHANDEN = 01
1996                T009_NICHT_GEFUNDEN = 02.
1997      IF SY-SUBRC NE 0.
1998          CLEAR AUSNAHME_TAB.
1999          IF RM03Q-KZINV = SPACE.
2000             MOVE '20' TO AUSNAHME_TAB-AUSNA.
2001          ELSE.
2002             MOVE '21' TO AUSNAHME_TAB-AUSNA.
2003          ENDIF.
2004          MOVE BUKRS_TAB-BUKRS TO AUSNAHME_TAB-BUKRS.
2005          APPEND AUSNAHME_TAB.
2006          FEHLERFLAG = 'X'.
2007      ELSE.
2008          MOVE RM03Q-LFMON TO BUKRS_TAB-MONAT.
2009          MOVE RM03Q-LFGJA TO BUKRS_TAB-JAHR.
2010      ENDIF.
2011   ENDIF.
2012   IF  NOT ( RM03Q-DATUM IS INITIAL ).
2013       CALL FUNCTION 'PROGNOSEPERIODEN_ERMITTELN'
2014            EXPORTING
2015                 EANZPR = 1
2016                 EDATUM = RM03Q-DATUM
2017                 EPERIV = T001-PERIV
2018            TABLES
2019                 PPERX = INT_PPER
2020            EXCEPTIONS
2021                 T009B_FEHLERHAFT = 01
2022                 T009_NICHT_GEFUNDEN = 02.
2023       IF SY-SUBRC = 0.
2024          READ TABLE INT_PPER INDEX 1.
2025          MOVE INT_PPER-PRPER(4) TO BUKRS_TAB-JAHR.
2026          MOVE INT_PPER-PRPER+4(2) TO BUKRS_TAB-MONAT.
2027          MOVE INT_PPER-VONTG TO DATUM.        "erster Tag der Periode
2028       ELSE.
2029          CLEAR AUSNAHME_TAB.
2030          IF RM03Q-KZINV = SPACE.
2031             MOVE '04' TO AUSNAHME_TAB-AUSNA.
2032          ELSE.
2033             MOVE '15' TO AUSNAHME_TAB-AUSNA.
2034          ENDIF.
2035          MOVE BUKRS_TAB-BUKRS TO AUSNAHME_TAB-BUKRS.
2036          APPEND AUSNAHME_TAB.
2037          FEHLERFLAG = 'X'.
2038       ENDIF.
2039   ENDIF.
2040
2041   IF FEHLERFLAG = SPACE.
2042      MODIFY BUKRS_TAB.
2043   ENDIF.
2044
2045   ENDFORM.
2046   *-----------------------------------------------------------------------
2047   *   PERIODE_PRUEFEN
2048   * In den Feldern MONAT, JAHR der internen Tabelle BUKRS_TAB
2049   *                            steht die Buchungsperiode, in die umgesetzt
2050   * werden soll. In der zugehörigen Vorperiode (VORMONAT, VORJAHR) muß
2051   * der aktuelle MARV-Verwaltungssatz stehen, sonst liegt ein Schiefstand
2052   * vor und die Umsetzung sollte nicht stattfinden.
2053   *-----------------------------------------------------------------------
2054   FORM PERIODE_PRUEFEN.
2055   DATA:  POPER LIKE T009B-POPER.
2056
2057   CLEAR FEHLERFLAG.
2058
2059   *--- Im Feld DATUM (gesetzt in Up PERIODE_ERMITTELN) steht der erste
2060   *--- Tag der Periode, in die verschoben werden soll.
2061   *--- Zur Bestimmung von VORMONAT, VORJAHR wird von diesem Datum ein Tag
2062   *--- abgezogen und mit Hilfe des FB die Vorperiode bestimmt.
2063   DATUM = DATUM - 1.
2064   CALL FUNCTION 'PROGNOSEPERIODEN_ERMITTELN'
2065        EXPORTING
2066             EANZPR = 1
2067             EDATUM = DATUM
2068             EPERIV = T001-PERIV
2069        TABLES
2070             PPERX = INT_PPER
2071        EXCEPTIONS
2072             T009B_FEHLERHAFT = 01
2073             T009_NICHT_GEFUNDEN = 02.
2074   IF SY-SUBRC NE 0.
2075      CLEAR AUSNAHME_TAB.
2076      IF RM03Q-KZINV = SPACE.
2077         MOVE '22' TO AUSNAHME_TAB-AUSNA.
2078      ELSE.
2079         MOVE '23' TO AUSNAHME_TAB-AUSNA.
2080      ENDIF.
2081      MOVE BUKRS_TAB-BUKRS TO AUSNAHME_TAB-BUKRS.
2082      APPEND AUSNAHME_TAB.
2083      FEHLERFLAG = 'X'.
2084      EXIT.
2085   ELSE.
2086      READ TABLE INT_PPER INDEX 1.
2087      MOVE INT_PPER-VONTG TO DATUM.    "erster Tag Vorperiode
2088      MOVE INT_PPER-PRPER(4) TO BUKRS_TAB-VORJAHR.
2089      MOVE INT_PPER-PRPER+4(2) TO BUKRS_TAB-VORMONAT.
2090   ENDIF.
2091
2092   IF RM03Q-KZINV = SPACE.
2093      IF BUKRS_TAB-VORMONAT NE BUKRS_TAB-LFMON OR
2094                           BUKRS_TAB-VORJAHR NE BUKRS_TAB-LFGJA.
2095         FEHLERFLAG = 'X'.
2096         CLEAR AUSNAHME_TAB.
2097         MOVE '05' TO AUSNAHME_TAB-AUSNA.
2098         MOVE BUKRS_TAB-BUKRS TO AUSNAHME_TAB-BUKRS.
2099         MOVE BUKRS_TAB-LFMON TO AUSNAHME_TAB-LFMON.
2100         MOVE BUKRS_TAB-LFGJA TO AUSNAHME_TAB-LFGJA.
2101         APPEND AUSNAHME_TAB.
2102         EXIT.
2103      ENDIF.
2104   *--- Vorvormonat setzen (ab 4.0C)
2105      MOVE BUKRS_TAB-VMGJA TO BUKRS_TAB-VVMJAHR.
2106      MOVE BUKRS_TAB-VMMON TO BUKRS_TAB-VVMMONAT.
2107
2108   *---- Bei Jahreswechsel VJJAHR VJMONAT neu setzen
2109   *---- ab 4.0C auch letzte Periode des Vorjahres neu setzen
2110      IF BUKRS_TAB-VORJAHR NE BUKRS_TAB-JAHR.
2111         MOVE BUKRS_TAB-VORJAHR  TO BUKRS_TAB-VJJAHR.
2112         MOVE BUKRS_TAB-VORMONAT TO BUKRS_TAB-VJMONAT.
2113         MOVE BUKRS_TAB-VJGJA    TO BUKRS_TAB-VVJJAHR.
2114         MOVE BUKRS_TAB-VJMON    TO BUKRS_TAB-VVJMONAT.
2115      ELSE.
2116         MOVE BUKRS_TAB-VJGJA TO BUKRS_TAB-VJJAHR.
2117         MOVE BUKRS_TAB-VJMON TO BUKRS_TAB-VJMONAT.
2118         MOVE BUKRS_TAB-VVJGJ TO BUKRS_TAB-VVJJAHR.
2119         MOVE BUKRS_TAB-VVJMO TO BUKRS_TAB-VVJMONAT.
2120   *     die letzte Periode des Vorvorjahres ermitteln, falls erste
2121   *     Verschiebung ab 4.0C
2122   *     Hierzu zunächst 1.Tag der letzten Periode des Vorjahres ermitteln
2123         IF BUKRS_TAB-GJA_40C IS INITIAL.
2124           POPER = BUKRS_TAB-VJMONAT.
2125           CALL FUNCTION 'PERIODENANFANG_ERMITTELN'
2126                EXPORTING
2127                     EPERIV = T001-PERIV
2128                     EPERJJ = BUKRS_TAB-VJJAHR
2129                     EPOPER = POPER
2130                IMPORTING
2131                     IVONTG = DATUM       "Erster Tag der Periode
2132                EXCEPTIONS
2133                     PERIODE_NICHT_VORHANDEN = 01
2134                     T009_NICHT_GEFUNDEN = 02.
2135           IF SY-SUBRC = 0.
2136             DO 99 TIMES.
2137                   DATUM = DATUM - 1.
2138                   CALL FUNCTION 'PROGNOSEPERIODEN_ERMITTELN'
2139                        EXPORTING
2140                             EANZPR = 1
2141                             EDATUM = DATUM
2142                             EPERIV = T001-PERIV
2143                        TABLES
2144                             PPERX = INT_PPER
2145                        EXCEPTIONS
2146                             T009B_FEHLERHAFT = 01
2147                             T009_NICHT_GEFUNDEN = 02.
2148                   IF SY-SUBRC NE 0.
2149                      EXIT.            "kein Fehler
2150                   ELSE.
2151                      READ TABLE INT_PPER INDEX 1.
2152                      MOVE INT_PPER-VONTG TO DATUM. "erster Tag Vorperiode
2153                      MOVE INT_PPER-PRPER(4) TO BUKRS_TAB-VVJJAHR.
2154                      MOVE INT_PPER-PRPER+4(2) TO BUKRS_TAB-VVJMONAT.
2155                      IF BUKRS_TAB-VVJJAHR NE BUKRS_TAB-VJJAHR.
2156                        EXIT.
2157                      ENDIF.
2158                   ENDIF.
2159             ENDDO.
2160           ENDIF.
2161         ENDIF.
2162      ENDIF.
2163   ELSE.
2164   *------ Bei Initialisierung letzte Periode des Vorjahres bestimmen
2165      CLEAR: BUKRS_TAB-VVJJAHR, BUKRS_TAB-VVJMONAT,    "neu zu 4.0C
2166             BUKRS_TAB-VVMJAHR, BUKRS_TAB-VVMMONAT.    "neu zu 4.0C
2167      MOVE BUKRS_TAB-VORJAHR TO BUKRS_TAB-VJJAHR.
2168      MOVE BUKRS_TAB-VORMONAT TO BUKRS_TAB-VJMONAT.
2169      DO.
2170            IF BUKRS_TAB-JAHR NE BUKRS_TAB-VJJAHR .
2171               EXIT.
2172            ENDIF.
2173            DATUM = DATUM - 1.
2174            CALL FUNCTION 'PROGNOSEPERIODEN_ERMITTELN'
2175                 EXPORTING
2176                      EANZPR = 1
2177                      EDATUM = DATUM
2178                      EPERIV = T001-PERIV
2179                 TABLES
2180                      PPERX = INT_PPER
2181                 EXCEPTIONS
2182                      T009B_FEHLERHAFT = 01
2183                      T009_NICHT_GEFUNDEN = 02.
2184            IF SY-SUBRC NE 0.
2185               CLEAR AUSNAHME_TAB.
2186               MOVE '23' TO AUSNAHME_TAB-AUSNA.
2187               MOVE BUKRS_TAB-BUKRS TO AUSNAHME_TAB-BUKRS.
2188               APPEND AUSNAHME_TAB.
2189               FEHLERFLAG = 'X'.
2190               EXIT.
2191            ELSE.
2192               READ TABLE INT_PPER INDEX 1.
2193               MOVE INT_PPER-VONTG TO DATUM.    "erster Tag Vorperiode
2194               MOVE INT_PPER-PRPER(4) TO BUKRS_TAB-VJJAHR.
2195               MOVE INT_PPER-PRPER+4(2) TO BUKRS_TAB-VJMONAT.
2196   *           Falls Vorvorperiode noch nicht gefüllt, wurde diese soeben
2197   *           ermittelt     (neu zu 4.0C)
2198               IF BUKRS_TAB-VVMJAHR IS INITIAL.
2199                 MOVE BUKRS_TAB-VJJAHR  TO BUKRS_TAB-VVMJAHR.
2200                 MOVE BUKRS_TAB-VJMONAT TO BUKRS_TAB-VVMMONAT.
2201               ENDIF.
2202            ENDIF.
2203      ENDDO.
2204   *  Ab 4.0C auch letzte Periode des Vorvorjahres bestimmen
2205      CHECK FEHLERFLAG = SPACE.
2206      DO 99 TIMES.
2207            DATUM = DATUM - 1.
2208            CALL FUNCTION 'PROGNOSEPERIODEN_ERMITTELN'
2209                 EXPORTING
2210                      EANZPR = 1
2211                      EDATUM = DATUM
2212                      EPERIV = T001-PERIV
2213                 TABLES
2214                      PPERX = INT_PPER
2215                 EXCEPTIONS
2216                      T009B_FEHLERHAFT = 01
2217                      T009_NICHT_GEFUNDEN = 02.
2218            IF SY-SUBRC NE 0.
2219               EXIT.            "kein Fehler
2220            ELSE.
2221               READ TABLE INT_PPER INDEX 1.
2222               MOVE INT_PPER-VONTG TO DATUM.    "erster Tag Vorperiode
2223               MOVE INT_PPER-PRPER(4) TO BUKRS_TAB-VVJJAHR.
2224               MOVE INT_PPER-PRPER+4(2) TO BUKRS_TAB-VVJMONAT.
2225   *           Falls Vorvorperiode noch nicht gefüllt, wurde diese soeben
2226   *           ermittelt     (neu zu 4.0C)
2227               IF BUKRS_TAB-VVMJAHR IS INITIAL.
2228                 MOVE BUKRS_TAB-VVJJAHR  TO BUKRS_TAB-VVMJAHR.
2229                 MOVE BUKRS_TAB-VVJMONAT TO BUKRS_TAB-VVMMONAT.
2230               ENDIF.
2231               IF BUKRS_TAB-VVJJAHR NE BUKRS_TAB-VJJAHR.
2232                 EXIT.
2233               ENDIF.
2234            ENDIF.
2235      ENDDO.
2236   ENDIF.
2237
2238   IF FEHLERFLAG = SPACE.
2239      MODIFY BUKRS_TAB.
2240   ENDIF.
2241
2242   ENDFORM.
2243
2244   *-----------------------------------------------------------------------
2245   *  MARV_UMSETZEN
2246   * MARV-Satz ändern oder bei Initialisierung evtl. hinzufügen
2247   *-----------------------------------------------------------------------
2248   FORM MARV_UMSETZEN.
2249
2250   MARV-BUKRS = BUKRS_TAB-BUKRS.
2251   MARV-LFGJA = BUKRS_TAB-JAHR..
2252   MARV-LFMON = BUKRS_TAB-MONAT.
2253   MARV-VMGJA = BUKRS_TAB-VORJAHR.
2254   MARV-VMMON = BUKRS_TAB-VORMONAT.
2255   MARV-VJGJA = BUKRS_TAB-VJJAHR.
2256   MARV-VJMON = BUKRS_TAB-VJMONAT.
2257   * Ab 4.0C auch Vorvorperiode und letzte Periode des Vorvorjahres
2258   MARV-VVMGJ = BUKRS_TAB-VVMJAHR.
2259   MARV-VVMMO = BUKRS_TAB-VVMMONAT.
2260   MARV-VVJGJ = BUKRS_TAB-VVJJAHR.
2261   MARV-VVJMO = BUKRS_TAB-VVJMONAT.
2262
2263   IF BUKRS_TAB-XRUEV = SPACE.           "ch zu 3.0C
2264   * D.h Rückbuchen soll generell nicht erlaubt sein
2265     MARV-XRUEM = 'X'.
2266     MARV-XRUEV = SPACE.                 "ch zu 3.1G ->H: 75039
2267   ELSE.                                 "ch zu 3.0C
2268   * D.h Rückbuchen soll in neuer Periode wieder erlaubt sein
2269     MARV-XRUEM = SPACE.                 "ch zu 3.1G ->H: 75039
2270     MARV-XRUEV = 'X'.                   "ch zu 3.0C
2271   ENDIF.                                "ch zu 3.0C
2272
2273   * Merken der ersten Periode ab Release >= 4.0C
2274   IF BUKRS_TAB-GJA_40C IS INITIAL.
2275     BUKRS_TAB-GJA_40C = MARV-LFGJA.
2276   ENDIF.
2277   IF BUKRS_TAB-MON_40C IS INITIAL.
2278     BUKRS_TAB-MON_40C = MARV-LFMON.
2279   ENDIF.
2280   MARV-GJA_40C =  BUKRS_TAB-GJA_40C.
2281   MARV-MON_40C =  BUKRS_TAB-MON_40C.
2282
2283   * Merken der ersten Periode ab Release >= 4.6B
2284   IF BUKRS_TAB-GJA_46C IS INITIAL.
2285     BUKRS_TAB-GJA_46C = MARV-LFGJA.
2286   ENDIF.
2287   IF BUKRS_TAB-MON_46C IS INITIAL.
2288     BUKRS_TAB-MON_46C = MARV-LFMON.
2289   ENDIF.
2290   MARV-GJA_46C =  BUKRS_TAB-GJA_46C.
2291   MARV-MON_46C =  BUKRS_TAB-MON_46C.
2292
2293   PERFORM MARV_UPDATE.
2294   IF SY-SUBRC NE 0 AND RM03Q-KZINV NE SPACE.
2295      PERFORM MARV_INSERT.
2296   ENDIF.
2297
2298   * Änderungsbeleg schreiben, falls Initialisierung  /ch zu 4.0C
2299   IF RM03Q-KZINV NE SPACE.
2300     PERFORM MARVCD_ZAEHLER.                "Ermitteln MARV-LFDNR
2301     MOVE-CORRESPONDING MARV TO MARVCD.
2302     MARVCD-LFGJA_OLD = BUKRS_TAB-LFGJA.
2303     MARVCD-LFMON_OLD = BUKRS_TAB-LFMON.
2304     PERFORM MARVCD_INSERT.
2305   ENDIF.
2306
2307   ENDFORM.
2308   *-----------------------------------------------------------------------
2309   *  RELEVANTFLAG_SETZEN
2310   *-----------------------------------------------------------------------
2311   FORM RELEVANTFLAG_SETZEN.
2312
2313     BUKRS_TAB-RELEVANTFLAG = 'X'.
2314     MODIFY BUKRS_TAB.
2315
2316   ENDFORM.
*--- End of MM13QF00 - 2316 lines ---

----------------------------------------------------------------------------------------------------
Include          MM13QFSQ                                  Level 1    Page 6
Object           Z_DEL_HIST_ENTRIES                        Lines 2548
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:32
----------------------------------------------------------------------------------------------------
1      *------------------------------------------------------------------
2      *      SPERREN
3      * Die Tabelle MBEW und Tabelle MARC mit allen abhängigen Tabellen
4      * werden komplett gesperrt.
5      * Änderungen zu 4.0C (ch)
6      * - die MARC-Sperre bleibt vorsichtshablber für den Fall der initiali-
7      *   sierung (ist notw., wenn Init mit früherer Periode)
8      * - die MBEW-Sperre bleibt vorerst noch wegen ML
9      *   ab 4.5B keine ML-Versch. mehr -> auch ML-Sperre nur noch bei Init.
10     * - bei Jahreswechsel wird mit EMMPV_INV gesperrt wg. Inventurfunktionen
11     *------------------------------------------------------------------
12     FORM SPERREN.
13
14     CLEAR FEHLERFLAG.
15     CLEAR: MBEW_LOCK, MARC_LOCK.                "ch zu 4.0C
16
17     IF RM03Q-KZINV NE SPACE.                    "ch zu 4.0C
18     * Nur noch bei Initialisierung sperren
19       CALL FUNCTION 'ENQUEUE_EMMARCE'    "MARC exklusiv für alle Materialien
20            EXCEPTIONS
21                   FOREIGN_LOCK     = 2
22                   SYSTEM_FAILURE   = 3.
23
24       IF SY-SUBRC = 2.
25          FEHLERFLAG = 'X'.
26          CLEAR AUSNAHME_TAB.
27          IF RM03Q-KZINV = SPACE.
28     *       MOVE '28' TO AUSNAHME_TAB-AUSNA. "benutzerfreundlichere Gestal-
29             MOVE '92' TO AUSNAHME_TAB-AUSNA.   "tung der Ausnahmemeldungen
30             APPEND AUSNAHME_TAB.               "ch/28.07.93
31             MOVE '93' TO AUSNAHME_TAB-AUSNA.
32          ELSE.
33     *       MOVE '27' TO AUSNAHME_TAB-AUSNA.
34             MOVE '90' TO AUSNAHME_TAB-AUSNA.
35             APPEND AUSNAHME_TAB.
36             MOVE '91' TO AUSNAHME_TAB-AUSNA.
37          ENDIF.
38          APPEND AUSNAHME_TAB.
39          EXIT.
40       ENDIF.
41       IF SY-SUBRC = 3.
42          FEHLERFLAG = 'X'.
43          CLEAR AUSNAHME_TAB.
44          IF RM03Q-KZINV = SPACE.
45             MOVE '30' TO AUSNAHME_TAB-AUSNA.
46          ELSE.
47             MOVE '29' TO AUSNAHME_TAB-AUSNA.
48          ENDIF.
49          APPEND AUSNAHME_TAB.
50          EXIT.
51       ENDIF.
52       MARC_LOCK = 'X'.
53     ENDIF.
54
55     * MBEW-Sperre nur noch bei Initialisierung oder wenn ML im Einsatz.
56     * -> zunächst prüfen, ob ein ML-relevanter BewKreis betroffen ist:
57     * Ab 4.5B keine ML-Verschiebung mehr
58     *LEAR T001K.
59     *F I_VBUKR IS INITIAL AND I_BBUKR IS INITIAL.
60     * SELECT * FROM T001K.
61     *   IF T001K-MLBWA NE SPACE.
62     *     EXIT.
63     *   ENDIF.
64     * ENDSELECT.
65     *LSE.
66     * SELECT * FROM T001K
67     *        WHERE BUKRS BETWEEN I_VBUKR AND I_BBUKR.     "#EC PORTABLE
68     *   IF T001K-MLBWA NE SPACE.
69     *     EXIT.
70     *   ENDIF.
71     * ENDSELECT.
72     *NDIF.
73
74     *F T001K-MLBWA NE SPACE OR RM03Q-KZINV NE SPACE.
75     IF RM03Q-KZINV NE SPACE.
76      CALL FUNCTION 'ENQUEUE_EMMBEWE'     "MBEW exclusiv für alle Materialien
77         EXCEPTIONS
78                   FOREIGN_LOCK     = 2
79                   SYSTEM_FAILURE   = 3.
80
81       IF SY-SUBRC = 2.
82          FEHLERFLAG = 'X'.
83          CLEAR AUSNAHME_TAB.
84          IF RM03Q-KZINV = SPACE.
85             MOVE '28' TO AUSNAHME_TAB-AUSNA.
86          ELSE.
87             MOVE '27' TO AUSNAHME_TAB-AUSNA.
88          ENDIF.
89          APPEND AUSNAHME_TAB.
90          EXIT.
91       ENDIF.
92       IF SY-SUBRC = 3.
93          FEHLERFLAG = 'X'.
94          CLEAR AUSNAHME_TAB.
95          IF RM03Q-KZINV = SPACE.
96             MOVE '30' TO AUSNAHME_TAB-AUSNA.
97          ELSE.
98             MOVE '29' TO AUSNAHME_TAB-AUSNA.
99          ENDIF.
100         APPEND AUSNAHME_TAB.
101         EXIT.
102      ENDIF.
103      MBEW_LOCK = 'X'.
104    ENDIF.                                                    "ch zu 3.0C
105
106    *KUGL, 5.11.95. Tuning of month end closing and year end closing
107    *Lock database tables exclusive so that no row locks are necessary
108    IF SWITCH_ON_TUNE = 'X'.                                         "KUGL
109     PERFORM DB_SPERRE.                                              "KUGL
110    ENDIF. "IF SWITCH_ON_TUNE = 'X'.                                 "KUGL
111
112    ENDFORM.
113
114
115    *KUGL, 5.11.95. Tuning of month end closing and year end closing
116    *Routine for locking table exclusive (not necessary for ORACLE)
117    *INFORMIX, ADABAS and DB2/6000 do all have the same syntax to lock table
118    FORM DB_SPERRE.                                                  "KUGL
119      IF SY-DBSYS(3) = 'INF' OR
120         SY-DBSYS(3) = 'SQL' OR
121         SY-DBSYS(3) = 'ADA' OR
122         SY-DBSYS(3) = 'DB6' OR
123         SY-DBSYS(3) = 'MSS' OR                               "ch zu 3.1I
124         SY-DBSYS(3) = 'DB2' .                                "ch zu 4.5B
125        IF MBEW_LOCK NE SPACE.                                "ch zu 4.0c
126          EXEC SQL.
127            LOCK TABLE MBEW IN EXCLUSIVE MODE
128          ENDEXEC.
129        ENDIF.
130        IF MARC_LOCK NE SPACE.                                "ch zu 4.0c
131          EXEC SQL.
132            LOCK TABLE MARD IN EXCLUSIVE MODE
133          ENDEXEC.
134          EXEC SQL.
135            LOCK TABLE MCHB IN EXCLUSIVE MODE
136          ENDEXEC.
137        ENDIF.
138      ENDIF. "IF SY-DBSYS(3) = 'INF' or ....
139    ENDFORM. "DB_SPERRE                                              "KUGL
140
141    *------------------------------------------------------------------
142    *      INVENTUR_SPERREN
143    * Beim Jahreswechsel wird eine Sperre abgesetzt, die verhindert, daß
144    * parallel Inventurtransaktionen ausgeführt werden
145    *------------------------------------------------------------------
146    FORM INVENTUR_SPERREN.
147
148      CALL FUNCTION 'ENQUEUE_EMMPV_INV'
149           EXPORTING
150                MODE_MARV      = 'E'
151                BUKRS          = BUKRS_TAB-BUKRS
152           EXCEPTIONS
153                FOREIGN_LOCK   = 2
154                SYSTEM_FAILURE = 3
155                OTHERS         = 3.
156      IF SY-SUBRC = 2.
157         FEHLERFLAG = 'X'.
158         CLEAR AUSNAHME_TAB.
159         MOVE '95' TO AUSNAHME_TAB-AUSNA.
160         MOVE BUKRS_TAB-BUKRS TO AUSNAHME_TAB-BUKRS.
161         APPEND AUSNAHME_TAB.
162      ENDIF.
163      IF SY-SUBRC = 3.
164         FEHLERFLAG = 'X'.
165         CLEAR AUSNAHME_TAB.
166         MOVE '96' TO AUSNAHME_TAB-AUSNA.
167         MOVE BUKRS_TAB-BUKRS TO AUSNAHME_TAB-BUKRS.
168         APPEND AUSNAHME_TAB.
169      ENDIF.
170
171    ENDFORM.
172
173    *------------------------------------------------------------------
174    *      ENTSPERREN
175    * Die Tabelle MBEW und Tabelle MARC mit allen abhängigen Tabellen
176    * werden wieder entsperrt.
177    *------------------------------------------------------------------
178    FORM ENTSPERREN.
179
180    CALL FUNCTION 'DEQUEUE_EMMARCE'.    "entsperren MARC
181
182    CALL FUNCTION 'DEQUEUE_EMMBEWE'.    "entsperren MBEW
183
184    CALL FUNCTION 'DEQUEUE_EMMPV_INV'.  "entsperren Inventurbelege
185
186    ENDFORM.
187
188    *------------------------------------------------------------------
189    *           Lesen der Tabelle MARD zur Ermittlung der Schiefstände
190    *
191    * Ab 3.0 wird hier auch geprüft, ob kein MARD-Satz mit negativem
192    * Vorperiodenbestand existiert.
193    *------------------------------------------------------------------
194    FORM MARD_SCHIEF.
195
196    *if sy-uname = 'LEBERER'. exit. endif.
197
198    * Da nur noch auf negative Mengen geprüft wird, wird hier erst mal
199    * das entsprechende Kennzeichen abgefragt          "ch/4.6
200    check rm03q-xnegq eq space.                        "
201    check ( NOT NB_WERKS[] IS INITIAL ).               "
202
203    *KUGL, 5.11.95: Remove client to fool optimizer. Then only get
204    *actual client. This tuning might hurt if customer has more than
205    *one client with many materials
206    IF SWITCH_ON_TUNE = 'X'.
207     SELECT * INTO MARDH
208        FROM MARDH CLIENT SPECIFIED
209    *  WHERE WERKS        IN IN_WERKS
210       WHERE WERKS        IN NB_WERKS               "ch/4.6
211       AND   LFGJA        =  BUKRS_TAB-VMGJA
212       AND   LFMON        =  BUKRS_TAB-VMMON
213       AND (  ( LABST < 0 )
214           OR ( UMLME < 0 )
215           OR ( INSME < 0 )
216           OR ( EINME < 0 )
217           OR ( SPEME < 0 )
218           OR ( RETME < 0 )
219           OR ( VKLAB < 0 )
220           OR ( VKUML < 0 ) ).         "#EC CI_NOFIRST
221        IF SY-MANDT = MARDH-MANDT.
222         PERFORM MARD_SCHIEF_AUSN.
223        ENDIF.
224     ENDSELECT.
225    ELSE.
226     SELECT * INTO MARDH
227        FROM MARDH
228    *  WHERE WERKS        IN IN_WERKS
229       WHERE WERKS        IN NB_WERKS               "ch/4.6
230       AND   LFGJA        =  BUKRS_TAB-VMGJA
231       AND   LFMON        =  BUKRS_TAB-VMMON
232       AND (  ( LABST < 0 )
233           OR ( UMLME < 0 )
234           OR ( INSME < 0 )
235           OR ( EINME < 0 )
236           OR ( SPEME < 0 )
237           OR ( RETME < 0 )
238           OR ( VKLAB < 0 )
239           OR ( VKUML < 0 ) ).       "#EC CI_NOFIRST
240         PERFORM MARD_SCHIEF_AUSN.
241     ENDSELECT.
242    ENDIF.
243
244    * CH/H:217577 Die Originaltabelle muß auch berücksichtigt werden
245    IF BUKRS_TAB-MON_40C IS INITIAL.      "d.h. 1. PeriWechsel nach Upgrade
246      SELECT MARD~MATNR MARD~WERKS MARD~LGORT
247             MARDH~MATNR
248          INTO (MARD-MATNR, MARD-WERKS, MARD-LGORT,
249                MARDH-MATNR)
250          FROM MARD LEFT OUTER JOIN MARDH
251          ON    MARD~MATNR  = MARDH~MATNR
252            AND MARD~WERKS  = MARDH~WERKS
253            AND MARD~LGORT  = MARDH~LGORT
254            AND MARDH~LFGJA  = BUKRS_TAB-VMGJA
255            AND MARDH~LFMON  = BUKRS_TAB-VMMON
256          WHERE MARD~WERKS  IN NB_WERKS
257            AND (  MARD~VMLAB < 0
258                OR MARD~VMUML < 0
259                OR MARD~VMINS < 0
260                OR MARD~VMEIN < 0
261                OR MARD~VMSPE < 0
262                OR MARD~VMRET < 0 ).
263        IF MARDH-MATNR IS INITIAL.       "d.h. kein MxxxH-Satz vorhanden
264          MOVE-CORRESPONDING MARD TO MARDH.
265          PERFORM MARD_SCHIEF_AUSN.
266        ENDIF.
267      ENDSELECT.
268    ELSE.
269      IF SWITCH_ON_TUNE = 'X'.
270       SELECT * INTO MARD
271          FROM MARD  CLIENT SPECIFIED
272         WHERE WERKS        IN NB_WERKS
273         AND   (  LFGJA < BUKRS_TAB-LFGJA
274               OR LFMON < BUKRS_TAB-LFMON )
275         AND (  ( LABST < 0 )
276             OR ( UMLME < 0 )
277             OR ( INSME < 0 )
278             OR ( EINME < 0 )
279             OR ( SPEME < 0 )
280             OR ( RETME < 0 )
281             OR ( VKLAB < 0 )
282             OR ( VKUML < 0 ) ).    "#EC CI_NOFIRST
283          IF SY-MANDT = MARD-MANDT.
284           MOVE-CORRESPONDING MARD TO MARDH.
285           PERFORM MARD_SCHIEF_AUSN.
286          ENDIF.
287       ENDSELECT.
288      ELSE.
289       SELECT * INTO MARD
290          FROM MARD
291         WHERE WERKS        IN NB_WERKS
292         AND   (  LFGJA <  BUKRS_TAB-LFGJA
293               OR LFMON <  BUKRS_TAB-LFMON )
294         AND (  ( LABST < 0 )
295             OR ( UMLME < 0 )
296             OR ( INSME < 0 )
297             OR ( EINME < 0 )
298             OR ( SPEME < 0 )
299             OR ( RETME < 0 )
300             OR ( VKLAB < 0 )
301             OR ( VKUML < 0 ) ).    "#EC CI_NOFIRST
302           MOVE-CORRESPONDING MARD TO MARDH.
303           PERFORM MARD_SCHIEF_AUSN.
304       ENDSELECT.
305      ENDIF.
306    ENDIF.
307
308
309    ENDFORM.
310    *------------------------------------------------------------------
311    *    FORM MARD_SCHIEF_AUSN.
312    * Füllen der Ausnahmetabelle, weil ein Schiefstand vorliegt.
313    *------------------------------------------------------------------
314    FORM MARD_SCHIEF_AUSN.
315           IF  ( MARDH-WERKS IN NB_WERKS )
316           AND ( NOT NB_WERKS[] IS INITIAL ).    "ch zu 3.0d  /23.02.96
317             CLEAR AUSNAHME_NEG.
318             MOVE '02'            TO AUSNAHME_NEG-SAART.
319                  "MARDs mit negativem Vorperiodenbestand existieren
320             MOVE BUKRS_TAB-BUKRS TO AUSNAHME_NEG-BUKRS.
321             MOVE MARDH-MATNR      TO AUSNAHME_NEG-MATNR.
322             MOVE MARDH-WERKS      TO AUSNAHME_NEG-WERKS.
323             MOVE MARDH-LGORT      TO AUSNAHME_NEG-LGORT.
324             APPEND AUSNAHME_NEG.
325           ENDIF.
326    ENDFORM.
327
328    *------------------------------------------------------------------
329    *           Update der Tabelle MARD  bei Jahreswechsel
330    *------------------------------------------------------------------
331    FORM MARD_UPDATE_JW.
332                                                       "ch zu 3.0C
333    *KUGL, 5.11.95: call specially tuned database forms
334    IF SWITCH_ON_TUNE = 'X'.                                       "KUGL
335      CHECK MARD_UPD IS INITIAL.                         "ch zu 3.0D
336      IF SY-DBSYS(3) = 'ORA'.
337    *   KUGL, 20.8.96:
338        PERFORM MARD_UPDATE_JW_ORA CHANGING ZAEHLER_MARD.
339    *  zaehler_mard = zaehler_mard + sy-dbcnt.
340      ELSEIF SY-DBSYS(3) = 'INF'.
341        PERFORM MARD_UPDATE_JW_INF CHANGING ZAEHLER_MARD.
342
343      ELSEIF ( SY-DBSYS(3) = 'DB2' OR SY-DBSYS(3) = 'DB4' ).
344        PERFORM MARD_UPDATE_JW_DB2DB4 CHANGING ZAEHLER_MARD.
345
346    *no SQL tuning for ADABAS, DB2/600 and MS SQL Server
347      ELSEIF ( SY-DBSYS(3) = 'ADA' OR SY-DBSYS(3) = 'SQL' OR
348               SY-DBSYS(3) = 'DB6' OR SY-DBSYS(3) = 'MSS' ).
349        PERFORM MARD_UPDATE_JW_NEUTRAL CHANGING ZAEHLER_MARD.
350
351      ENDIF. "IF SY-DBSYS(3) = 'ORA'.                              "KUGL
352    ELSE. " no optimize flag set. Do slower update per plant       "KUGL
353
354      LOOP AT IN_WERKS.
355        EXEC SQL.
356         UPDATE MARD
357            SET
358                 KZVLL         =  KZILL ,
359                 KZVLQ         =  KZILQ ,
360                 KZVLE         =  KZILE ,
361                 KZVLS         =  KZILS ,
362                 KZILL         =  :RESET_INV ,
363                 KZILQ         =  :RESET_INV ,
364                 KZILE         =  :RESET_INV ,
365                 KZILS         =  :RESET_INV ,
366                 MDJIN         =  :BUKRS_TAB-JAHR
367           WHERE MANDT         =  :SY-MANDT
368           AND   MDJIN        <> :BUKRS_TAB-JAHR
369           AND   WERKS         = :IN_WERKS-VWERK
370        ENDEXEC.
371
372        ZAEHLER_MARD = ZAEHLER_MARD + SY-DBCNT.
373      ENDLOOP.
374    ENDIF. "IF SWITCH_ON_TUNE = 'X'.                               "KUGL
375    MARD_UPD = 'X'.                                             "ch zu 3.0D
376
377    ENDFORM.
378
379
380    *------------------------------------------------------------------
381    *           Update der Tabelle MARD bei Initialisierung
382    *------------------------------------------------------------------
383    FORM MARD_UPDATE_INI.
384
385     UPDATE MARD
386        SET
387             LFGJA         =  BUKRS_TAB-JAHR
388             LFMON         =  BUKRS_TAB-MONAT
389       WHERE WERKS         IN IN_WERKS
390         AND ( LFGJA > BUKRS_TAB-JAHR
391             OR (   LFGJA = BUKRS_TAB-JAHR
392                AND LFMON > BUKRS_TAB-MONAT ) ).    "#EC CI_NOFIRST
393
394       ZAEHLER_MARD = ZAEHLER_MARD + SY-DBCNT.
395    * Nach Absprache mit der Bestandsführung sollen bei der Initialisierung
396    * keine Historiensätze mehr gelöscht werden
397    *   DELETE FROM MARDH
398    *          WHERE WERKS IN IN_WERKS
399    *          AND ( LFGJA > BUKRS_TAB-JAHR
400    *              OR (   LFGJA = BUKRS_TAB-JAHR
401    *                 AND LFMON >= BUKRS_TAB-MONAT ) ).
402
403    ENDFORM.
404
405    *------------------------------------------------------------------
406    *           Lesen der Tabelle MARV gemäß der int. Tabelle IN_BUKRS
407    *------------------------------------------------------------------
408    FORM LESEN_MARV_SEQ.
409
410    *---Lesen MARV --------------------------------------------------
411           SELECT * INTO         MARV
412                    FROM MARV
413                    WHERE BUKRS IN IN_BUKRS.
414              READ TABLE BUKRS_TAB WITH KEY MARV-BUKRS.
415              IF RM03Q-KZINV = SPACE.                      "ch zu 4.0
416                MOVE-CORRESPONDING MARV TO BUKRS_TAB.
417                BUKRS_TAB-MARVFLAG = 'X'.
418              ELSE.                                        "ch zu 4.0
419                MOVE-CORRESPONDING MARV TO BUKRS_TAB.
420              ENDIF.                                       "ch zu 4.0
421              MODIFY BUKRS_TAB INDEX SY-TABIX.             "ch zu 4.0
422           ENDSELECT.
423
424    ENDFORM.
425    *------------------------------------------------------------------
426    *        MARV_INSERT
427    *------------------------------------------------------------------
428    FORM MARV_INSERT.
429
430      MARV-AENAM = SY-UNAME.                  "ch zu 4.0
431      MARV-LAEDA = SY-DATUM.                  "ch zu 4.0
432      MARV-UZEIT = SY-UZEIT.                  "ch zu 4.0
433      MARV-KZINV = I_KZINV.                   "ch zu 4.0
434      INSERT INTO MARV VALUES MARV.
435
436    ENDFORM.
437    *------------------------------------------------------------------
438    *        MARV_UPDATE
439    *------------------------------------------------------------------
440    FORM MARV_UPDATE.
441
442      MARV-AENAM = SY-UNAME.                  "ch zu 4.0
443      MARV-LAEDA = SY-DATUM.                  "ch zu 4.0
444      MARV-UZEIT = SY-UZEIT.                  "ch zu 4.0
445      MARV-KZINV = I_KZINV.                   "ch zu 4.0
446      UPDATE MARV.
447
448    ENDFORM.
449
450    *------------------------------------------------------------------
451    *        MARVCD_ZAEHLER
452    * Ermitteln der nächsten LFDNR zum Buchungskreis
453    *------------------------------------------------------------------
454    FORM MARVCD_ZAEHLER .
455      MARVCD-LFDNR = 1.
456      SELECT * FROM MARVCD
457             WHERE BUKRS = MARV-BUKRS
458             ORDER BY LFDNR DESCENDING.
459        MARVCD-LFDNR = MARVCD-LFDNR + 1.
460        EXIT.
461      ENDSELECT.
462    ENDFORM.
463
464    *------------------------------------------------------------------
465    *        MARVCD_INSERT
466    * Einfügen Änderungsbeleg Periodeninitialisierung
467    *------------------------------------------------------------------
468    FORM MARVCD_INSERT.
469
470      INSERT MARVCD.
471
472    ENDFORM.
473
474
475    *------------------------------------------------------------------
476    *           Update der Tabelle MBEW bei Initialisierung
477    *------------------------------------------------------------------
478    FORM MBEW_UPDATE_INI.
479
480     UPDATE MBEW
481        SET
482             LFGJA         =  BUKRS_TAB-JAHR
483             LFMON         =  BUKRS_TAB-MONAT
484       WHERE BWKEY         IN IN_BWKEY
485         AND ( LFGJA > BUKRS_TAB-JAHR
486             OR (   LFGJA = BUKRS_TAB-JAHR
487                AND LFMON > BUKRS_TAB-MONAT ) ).   "#EC CI_NOFIRST
488
489
490       ZAEHLER_MBEW = ZAEHLER_MBEW + SY-DBCNT.
491    * Nach Absprache mit der Bestandsführung sollen bei der Initialisierung
492    * keine Historiensätze mehr gelöscht werden
493    *    DELETE FROM MBEWH
494    *          WHERE BWKEY IN IN_BWKEY
495    *          AND ( LFGJA > BUKRS_TAB-JAHR
496    *              OR (   LFGJA = BUKRS_TAB-JAHR
497    *                 AND LFMON >= BUKRS_TAB-MONAT ) ).
498
499    ENDFORM.
500
501    *------------------------------------------------------------------
502    *           Lesen der Tabelle MBEW zur Ermittlung der Schiefstände
503    *
504    * Ab 3.0 wird hier auch geprüft, ob kein MBEW-Satz mit negativem
505    * Vorperiodenbestand existiert.
506    *
507    * Ab 4.0C nur noch Prüfung negativer Werte zur Vorperiode
508    *------------------------------------------------------------------
509    FORM MBEW_SCHIEF.
510
511    * Da nur noch auf negative Mengen geprüft wird, wird hier erst mal
512    * das entsprechende Kennzeichen abgefragt          "ch/4.6
513    CHECK RM03Q-XNEGQ NE SPACE AND RM03Q-XNEGV EQ SPACE.
514    check ( NOT NB_BWKEY[] IS INITIAL ).               "
515
516    *KUGL, 5.11.95: Remove client to fool optimizer. Then only get
517    *actual client                                        ch zu 3.0C
518    *This tuning might hurt if customer has more than one client with many
519    *many materials
520
521    IF SWITCH_ON_TUNE = 'X'.
522     SELECT * INTO MBEWH
523        FROM MBEWH CLIENT SPECIFIED
524    *  WHERE BWKEY        IN IN_BWKEY
525       WHERE BWKEY        IN NB_BWKEY             "ch/4.6a
526       AND   LFGJA        =  BUKRS_TAB-VMGJA
527       AND   LFMON        =  BUKRS_TAB-VMMON
528       AND (  ( SALK3 < 0 )
529           OR ( VKSAL < 0 ) ).          "#EC CI_NOFIRST
530        IF SY-MANDT = MBEWH-MANDT.
531          PERFORM MBEW_SCHIEF_AUSN.
532        ENDIF.
533     ENDSELECT.
534    ELSE.
535     SELECT * INTO MBEWH
536        FROM MBEWH
537    *  WHERE BWKEY        IN IN_BWKEY
538       WHERE BWKEY        IN NB_BWKEY             "ch/4.6a
539       AND   LFGJA        =  BUKRS_TAB-VMGJA
540       AND   LFMON        =  BUKRS_TAB-VMMON
541       AND (  ( SALK3 < 0 )
542           OR ( VKSAL < 0 ) ).           "#EC CI_NOFIRST
543         PERFORM MBEW_SCHIEF_AUSN.
544     ENDSELECT.
545    ENDIF.
546
547    * CH/H:217577 Die Originaltabelle muß auch berücksichtigt werden
548    IF BUKRS_TAB-MON_40C IS INITIAL.      "d.h. 1. PeriWechsel nach Upgrade
549      SELECT MBEW~MATNR MBEW~BWKEY MBEW~BWTAR
550             MBEW~VMSAL MBEWH~MATNR
551          INTO (MBEW-MATNR, MBEW-BWKEY, MBEW-BWTAR,
552                MBEW-VMSAL, MBEWH-MATNR)
553          FROM MBEW LEFT OUTER JOIN MBEWH
554          ON    MBEW~MATNR  = MBEWH~MATNR
555            AND MBEW~BWKEY  = MBEWH~BWKEY
556            AND MBEW~BWTAR  = MBEWH~BWTAR
557            AND MBEWH~LFGJA  = BUKRS_TAB-VMGJA
558            AND MBEWH~LFMON  = BUKRS_TAB-VMMON
559          WHERE MBEW~BWKEY   IN NB_BWKEY
560            AND MBEW~VMSAL   <  0  .
561        IF MBEWH-MATNR IS INITIAL.       "d.h. kein MxxxH-Satz vorhanden
562          MOVE-CORRESPONDING MBEW TO MBEWH.
563          PERFORM MBEW_SCHIEF_AUSN.
564        ENDIF.
565      ENDSELECT.
566    ELSE.
567      IF SWITCH_ON_TUNE = 'X'.
568       SELECT * INTO MBEW
569          FROM MBEW CLIENT SPECIFIED
570         WHERE BWKEY        IN NB_BWKEY
571         AND (  LFGJA < BUKRS_TAB-LFGJA
572             OR LFMON < BUKRS_TAB-LFMON )
573         AND (  SALK3 < 0
574             OR VKSAL < 0 ).           "#EC CI_NOFIRST
575          IF SY-MANDT = MBEW-MANDT.
576            MOVE-CORRESPONDING MBEW TO MBEWH.
577            PERFORM MBEW_SCHIEF_AUSN.
578          ENDIF.
579       ENDSELECT.
580      ELSE.
581       SELECT * INTO MBEW
582          FROM MBEW
583         WHERE BWKEY        IN NB_BWKEY
584         AND (  LFGJA <  BUKRS_TAB-LFGJA
585             OR LFMON <  BUKRS_TAB-LFMON )
586         AND (  SALK3 < 0
587             OR VKSAL < 0 ).          "#EC CI_NOFIRST
588           MOVE-CORRESPONDING MBEW TO MBEWH.
589           PERFORM MBEW_SCHIEF_AUSN.
590       ENDSELECT.
591      ENDIF.
592    ENDIF.
593
594    ENDFORM.
595
596    *------------------------------------------------------------------
597    *    FORM MBEW_SCHIEF_AUSN.
598    * Füllen der Ausnahmetabelle, weil ein Schiefstand vorliegt.
599    *
600    * Ab 4.0C nur noch Prüfung negativer Werte zur Vorperiode
601    *------------------------------------------------------------------
602    FORM MBEW_SCHIEF_AUSN.
603    * Die MBEW-Prüfung auf negative Vorperioden-Bestände wurde vorerst mal
604    * ausgesternt, da die darunterliegenden bewerteten Einzelbestände
605    * in bestimmten Fällen negativ sein können.       CH/24.08.94
606    * -- zu 3.0D wurde diese Prüfung für den Fall, daß zwar negative
607    *    Mengen aber keine negativen Werte erlaubt sind, wieder aktiviert
608         IF RM03Q-XNEGQ NE SPACE AND RM03Q-XNEGV EQ SPACE.
609           IF  ( NOT NB_BWKEY[] IS INITIAL ).    "ch zu 3.0d  /23.02.96
610             IF MBEWH-BWKEY IN NB_BWKEY.
611               CLEAR AUSNAHME_NEG.
612               MOVE '01'            TO AUSNAHME_NEG-SAART.
613                  "MBEWs mit negativem Vorperiodenbestand existieren
614               MOVE BUKRS_TAB-BUKRS TO AUSNAHME_NEG-BUKRS.
615               MOVE MBEWH-MATNR     TO AUSNAHME_NEG-MATNR.
616               MOVE MBEWH-BWKEY     TO AUSNAHME_NEG-BWKEY.
617               MOVE MBEWH-BWTAR     TO AUSNAHME_NEG-BWTAR.
618               APPEND AUSNAHME_NEG.
619             ENDIF.
620           ENDIF.
621         ENDIF.
622
623    *    IF  ( MBEW-LFGJA        NE BUKRS_TAB-VORJAHR
624    *    OR  ( MBEW-LFGJA        =  BUKRS_TAB-VORJAHR  AND
625    *          MBEW-LFMON        NE BUKRS_TAB-VORMONAT ) ).
626    *      CLEAR AUSNAHME_SATZ.
627    *      MOVE '09'            TO AUSNAHME_SATZ-AUSNA.
628    *           "Nicht alle Bewertungssätze konnten umgesetzt werden
629    *      MOVE BUKRS_TAB-BUKRS TO AUSNAHME_SATZ-BUKRS.
630    *      MOVE MBEW-MATNR      TO AUSNAHME_SATZ-MATNR.
631    *      MOVE MBEW-BWKEY      TO AUSNAHME_SATZ-BWKEY.
632    *      MOVE MBEW-BWTAR      TO AUSNAHME_SATZ-BWTAR.
633    *      APPEND AUSNAHME_SATZ.
634    *      ADD 1 TO ZAEHLER_MBEW_SCHIEF.
635    *    ENDIF.
636    ENDFORM.
637
638    *------------------------------------------------------------------
639    *           Lesen der Tabelle MCHB zur Ermittlung der Schiefstände
640    *
641    * Ab 3.0 wird hier auch geprüft, ob kein MCHB-Satz mit negativem
642    * Vorperiodenbestand existiert.
643    *------------------------------------------------------------------
644    FORM MCHB_SCHIEF.
645
646    * Da nur noch auf negative Mengen geprüft wird, wird hier erst mal
647    * das entsprechende Kennzeichen abgefragt          "ch/4.6
648    check rm03q-xnegq eq space.                        "
649    check ( NOT NB_WERKS[] IS INITIAL ).               "
650
651    *KUGL, 5.11.95: Remove client to fool optimizer. Then only get
652    *actual client                                       ch zu 3.0C
653    *This tuning might hurt if customer has more than one client with many
654    *many materials
655    IF SWITCH_ON_TUNE = 'X'.
656     SELECT * INTO MCHBH
657        FROM MCHBH CLIENT SPECIFIED
658    *  WHERE WERKS        IN IN_WERKS
659       WHERE WERKS        IN NB_WERKS               "ch/4.6
660       AND   LFGJA        =  BUKRS_TAB-VMGJA
661       AND   LFMON        =  BUKRS_TAB-VMMON
662       AND (  ( CLABS < 0 )
663           OR ( CUMLM < 0 )
664           OR ( CINSM < 0 )
665           OR ( CEINM < 0 )
666           OR ( CSPEM < 0 )
667           OR ( CRETM < 0 )  ).       "#EC CI_NOFIRST
668        IF SY-MANDT = MCHBH-MANDT.
669         PERFORM MCHB_SCHIEF_AUSN.
670        ENDIF.
671     ENDSELECT.
672    ELSE.
673     SELECT * INTO MCHBH
674        FROM MCHBH
675    *  WHERE WERKS        IN IN_WERKS
676       WHERE WERKS        IN NB_WERKS               "ch/4.6
677       AND   LFGJA        =  BUKRS_TAB-VMGJA
678       AND   LFMON        =  BUKRS_TAB-VMMON
679       AND (  ( CLABS < 0 )
680           OR ( CUMLM < 0 )
681           OR ( CINSM < 0 )
682           OR ( CEINM < 0 )
683           OR ( CSPEM < 0 )
684           OR ( CRETM < 0 )  ).       "#EC CI_NOFIRST
685         PERFORM MCHB_SCHIEF_AUSN.
686     ENDSELECT.
687    ENDIF.
688
689    * CH/H:217577 Die Originaltabelle muß auch berücksichtigt werden
690    IF BUKRS_TAB-MON_40C IS INITIAL.      "d.h. 1. PeriWechsel nach Upgrade
691      SELECT MCHB~MATNR MCHB~WERKS MCHB~LGORT MCHB~CHARG
692             MCHBH~MATNR
693          INTO (MCHB-MATNR, MCHB-WERKS, MCHB-LGORT, MCHB-CHARG,
694                MCHBH-MATNR)
695          FROM MCHB LEFT OUTER JOIN MCHBH
696          ON    MCHB~MATNR  = MCHBH~MATNR
697            AND MCHB~WERKS  = MCHBH~WERKS
698            AND MCHB~LGORT  = MCHBH~LGORT
699            AND MCHB~CHARG  = MCHBH~CHARG
700            AND MCHBH~LFGJA  = BUKRS_TAB-VMGJA
701            AND MCHBH~LFMON  = BUKRS_TAB-VMMON
702          WHERE MCHB~WERKS  IN NB_WERKS
703            AND (  MCHB~CVMLA < 0
704                OR MCHB~CVMUM < 0
705                OR MCHB~CVMIN < 0
706                OR MCHB~CVMEI < 0
707                OR MCHB~CVMSP < 0
708                OR MCHB~CVMRE < 0 ).
709        IF MCHBH-MATNR IS INITIAL.       "d.h. kein MxxxH-Satz vorhanden
710          MOVE-CORRESPONDING MCHB TO MCHBH.
711          PERFORM MCHB_SCHIEF_AUSN.
712        ENDIF.
713      ENDSELECT.
714    ELSE.
715      IF SWITCH_ON_TUNE = 'X'.
716       SELECT * INTO MCHB
717          FROM MCHB  CLIENT SPECIFIED
718         WHERE WERKS        IN NB_WERKS
719         AND   (  LFGJA < BUKRS_TAB-LFGJA
720               OR LFMON < BUKRS_TAB-LFMON )
721         AND (  ( CLABS < 0 )
722             OR ( CUMLM < 0 )
723             OR ( CINSM < 0 )
724             OR ( CEINM < 0 )
725             OR ( CSPEM < 0 )
726             OR ( CRETM < 0 ) ).
727          IF SY-MANDT = MCHB-MANDT.
728           MOVE-CORRESPONDING MCHB TO MCHBH.
729           PERFORM MCHB_SCHIEF_AUSN.
730          ENDIF.
731       ENDSELECT.
732      ELSE.
733       SELECT * INTO MCHB
734          FROM MCHB
735         WHERE WERKS        IN NB_WERKS
736         AND   (  LFGJA <  BUKRS_TAB-LFGJA
737               OR LFMON <  BUKRS_TAB-LFMON )
738         AND (  ( CLABS < 0 )
739             OR ( CUMLM < 0 )
740             OR ( CINSM < 0 )
741             OR ( CEINM < 0 )
742             OR ( CSPEM < 0 )
743             OR ( CRETM < 0 ) ).
744           MOVE-CORRESPONDING MCHB TO MCHBH.
745           PERFORM MCHB_SCHIEF_AUSN.
746       ENDSELECT.
747      ENDIF.
748    ENDIF.
749
750
751    ENDFORM.
752
753    *------------------------------------------------------------------
754    *    FORM MCHB_SCHIEF_AUSN.
755    * Füllen der Ausnahmetabelle, weil ein Schiefstand vorliegt.
756    *------------------------------------------------------------------
757    FORM MCHB_SCHIEF_AUSN.
758           IF  ( MCHBH-WERKS IN NB_WERKS )
759           AND ( NOT NB_WERKS[] IS INITIAL ).    "ch zu 3.0d  /23.02.96
760             CLEAR AUSNAHME_NEG.
761             MOVE '03'            TO AUSNAHME_NEG-SAART.
762                  "MCHBs mit negativem Vorperiodenbestand existieren.
763             MOVE BUKRS_TAB-BUKRS TO AUSNAHME_NEG-BUKRS.
764             MOVE MCHBH-MATNR      TO AUSNAHME_NEG-MATNR. "note 360325
765             MOVE MCHBH-WERKS      TO AUSNAHME_NEG-WERKS.
766             MOVE MCHBH-LGORT      TO AUSNAHME_NEG-LGORT.
767             MOVE MCHBH-CHARG      TO AUSNAHME_NEG-CHARG.
768             APPEND AUSNAHME_NEG.
769           ENDIF.
770    ENDFORM.
771
772    *------------------------------------------------------------------
773    *           Update der Tabelle MCHB   bei Jahreswechsel
774    *------------------------------------------------------------------
775    FORM MCHB_UPDATE_JW.
776
777    *KUGL, 5.11.95: call specially tuned database forms
778    *                                                   ch zu 3.0C
779    IF SWITCH_ON_TUNE = 'X'.                                       "KUGL
780      CHECK MCHB_UPD IS INITIAL.                         "ch zu 3.0D
781      IF SY-DBSYS(3) = 'ORA'.
782       PERFORM MCHB_UPDATE_JW_ORA CHANGING ZAEHLER_MCHB.
783
784      ELSEIF SY-DBSYS(3) = 'INF'.
785       PERFORM MCHB_UPDATE_JW_INF CHANGING ZAEHLER_MCHB.
786
787      ELSEIF SY-DBSYS(3) = 'DB2' OR SY-DBSYS(3) = 'DB4'.
788       PERFORM MCHB_UPDATE_JW_DB2DB4 CHANGING ZAEHLER_MCHB.
789
790    *no SQL tuning for ADABAS, DB2/600 and MS SQL Server
791      ELSEIF SY-DBSYS(3) = 'ADA' OR SY-DBSYS(3) = 'SQL' OR
792             SY-DBSYS(3) = 'DB6' OR SY-DBSYS(3) = 'MSS'.
793       PERFORM MCHB_UPDATE_JW_NEUTRAL CHANGING ZAEHLER_MCHB.
794
795      ENDIF. "IF SY-DBSYS(3) = 'ORA'.
796    ELSE.
797
798      LOOP AT IN_WERKS.
799        EXEC SQL.
800         UPDATE MCHB
801            SET
802                 KZVCL         =  KZICL ,
803                 KZVCQ         =  KZICQ ,
804                 KZVCE         =  KZICE ,
805                 KZVCS         =  KZICS ,
806                 KZICL         =  :RESET_INV ,
807                 KZICQ         =  :RESET_INV ,
808                 KZICE         =  :RESET_INV ,
809                 KZICS         =  :RESET_INV ,
810                 CHJIN         =  :BUKRS_TAB-JAHR
811           WHERE MANDT         =  :SY-MANDT
812           AND   CHJIN        <> :BUKRS_TAB-JAHR
813           AND   WERKS         = :IN_WERKS-VWERK
814        ENDEXEC.
815
816        ZAEHLER_MCHB = ZAEHLER_MCHB + SY-DBCNT.
817      ENDLOOP.
818    ENDIF. "IF SWITCH_ON_TUNE = 'X'.                               "KUGL
819    MCHB_UPD = 'X'.                                             "ch zu 3.0D
820
821    ENDFORM.
822
823
824    *------------------------------------------------------------------
825    *           Update der Tabelle MCHB bei Initialisierung
826    *------------------------------------------------------------------
827    FORM MCHB_UPDATE_INI.
828
829     UPDATE MCHB
830        SET
831             LFGJA         =  BUKRS_TAB-JAHR
832             LFMON         =  BUKRS_TAB-MONAT
833       WHERE WERKS         IN IN_WERKS
834         AND ( LFGJA > BUKRS_TAB-JAHR
835             OR (   LFGJA = BUKRS_TAB-JAHR
836                AND LFMON > BUKRS_TAB-MONAT ) ).   "#EC CI_NOFIRST
837
838       ZAEHLER_MCHB = ZAEHLER_MCHB + SY-DBCNT.
839    * Nach Absprache mit der Bestandsführung sollen bei der Initialisierung
840    * keine Historiensätze mehr gelöscht werden
841    *   DELETE FROM MCHBH
842    *          WHERE WERKS IN IN_WERKS
843    *          AND ( LFGJA > BUKRS_TAB-JAHR
844    *              OR (   LFGJA = BUKRS_TAB-JAHR
845    *                 AND LFMON >= BUKRS_TAB-MONAT ) ).
846
847    ENDFORM.
848
849    *------------------------------------------------------------------
850    *           Lesen der Tabelle MKOL zur Ermittlung der Schiefstände
851    *
852    * Ab 3.0 wird hier auch geprüft, ob kein MKOL-Satz mit negativem
853    * Vorperiodenbestand existiert.
854    *------------------------------------------------------------------
855    FORM MKOL_SCHIEF.
856
857    * Da nur noch auf negative Mengen geprüft wird, wird hier erst mal
858    * das entsprechende Kennzeichen abgefragt          "ch/4.6
859    check rm03q-xnegq eq space.                        "
860    check ( NOT NB_WERKS[] IS INITIAL ).               "
861
862     SELECT * INTO MKOLH
863        FROM MKOLH
864    *  WHERE WERKS        IN IN_WERKS
865       WHERE WERKS        IN NB_WERKS               "ch/4.6
866       AND   LFGJA        =  BUKRS_TAB-VMGJA
867       AND   LFMON        =  BUKRS_TAB-VMMON
868       AND (  ( SLABS < 0 )
869           OR ( SINSM < 0 )
870           OR ( SEINM < 0 )
871           OR ( SSPEM < 0 ) ).
872           IF  ( MKOLH-WERKS IN NB_WERKS )
873           AND ( NOT NB_WERKS[] IS INITIAL ).    "ch zu 3.0d  /23.02.96
874             CLEAR AUSNAHME_NEG.
875             IF MKOLH-SOBKZ = 'K'.                               "br 15.1.95
876               MOVE '04'            TO AUSNAHME_NEG-SAART.  "L.Konsi
877             ELSE.
878               MOVE '11'            TO AUSNAHME_NEG-SAART.  "MTV br 15.1.95
879             ENDIF.
880                  "MKOLs mit negativem Vorperiodenbestand existieren
881             MOVE BUKRS_TAB-BUKRS TO AUSNAHME_NEG-BUKRS.
882             MOVE MKOLH-MATNR      TO AUSNAHME_NEG-MATNR.
883             MOVE MKOLH-WERKS      TO AUSNAHME_NEG-WERKS.
884             MOVE MKOLH-LGORT      TO AUSNAHME_NEG-LGORT.
885             MOVE MKOLH-CHARG      TO AUSNAHME_NEG-CHARG.
886             MOVE MKOLH-SOBKZ      TO AUSNAHME_NEG-SOBKZ.
887             MOVE MKOLH-LIFNR      TO AUSNAHME_NEG-LIFNR.
888             APPEND AUSNAHME_NEG.
889           ENDIF.
890     ENDSELECT.
891
892    * CH/H:217577 Die Originaltabelle muß auch berücksichtigt werden
893    IF BUKRS_TAB-MON_40C IS INITIAL.      "d.h. 1. PeriWechsel nach Upgrade
894      SELECT MKOL~MATNR MKOL~WERKS MKOL~LGORT MKOL~CHARG
895             MKOL~SOBKZ MKOL~LIFNR
896             MKOLH~MATNR
897          INTO (MKOL-MATNR, MKOL-WERKS, MKOL-LGORT, MKOL-CHARG,
898                MKOL-SOBKZ, MKOL-LIFNR,
899                MKOLH-MATNR)
900          FROM MKOL LEFT OUTER JOIN MKOLH
901          ON    MKOL~MATNR  = MKOLH~MATNR
902            AND MKOL~WERKS  = MKOLH~WERKS
903            AND MKOL~LGORT  = MKOLH~LGORT
904            AND MKOL~CHARG  = MKOLH~CHARG
905            AND MKOL~SOBKZ  = MKOLH~SOBKZ
906            AND MKOL~LIFNR  = MKOLH~LIFNR
907            AND MKOLH~LFGJA  = BUKRS_TAB-VMGJA
908            AND MKOLH~LFMON  = BUKRS_TAB-VMMON
909          WHERE MKOL~WERKS  IN NB_WERKS
910            AND (  MKOL~SVMLA < 0
911                OR MKOL~SVMIN < 0
912                OR MKOL~SVMEI < 0
913                OR MKOL~SVMSP < 0 ).
914        IF MKOLH-MATNR IS INITIAL.       "d.h. kein MxxxH-Satz vorhanden
915           IF  ( MKOL-WERKS IN NB_WERKS )
916           AND ( NOT NB_WERKS[] IS INITIAL ).    "ch zu 3.0d  /23.02.96
917             CLEAR AUSNAHME_NEG.
918             IF MKOL-SOBKZ = 'K'.                               "br 15.1.95
919               MOVE '04'            TO AUSNAHME_NEG-SAART.  "L.Konsi
920             ELSE.
921               MOVE '11'            TO AUSNAHME_NEG-SAART.  "MTV br 15.1.95
922             ENDIF.
923                  "MKOLs mit negativem Vorperiodenbestand existieren
924             MOVE BUKRS_TAB-BUKRS TO AUSNAHME_NEG-BUKRS.
925             MOVE MKOL-MATNR      TO AUSNAHME_NEG-MATNR.
926             MOVE MKOL-WERKS      TO AUSNAHME_NEG-WERKS.
927             MOVE MKOL-LGORT      TO AUSNAHME_NEG-LGORT.
928             MOVE MKOL-CHARG      TO AUSNAHME_NEG-CHARG.
929             MOVE MKOL-SOBKZ      TO AUSNAHME_NEG-SOBKZ.
930             MOVE MKOL-LIFNR      TO AUSNAHME_NEG-LIFNR.
931             APPEND AUSNAHME_NEG.
932           ENDIF.
933        ENDIF.
934      ENDSELECT.
935    ELSE.
936       SELECT * INTO MKOL
937          FROM MKOL
938         WHERE WERKS        IN NB_WERKS
939         AND   (  LFGJA <  BUKRS_TAB-LFGJA
940               OR LFMON <  BUKRS_TAB-LFMON )
941         AND (  ( SLABS < 0 )
942             OR ( SINSM < 0 )
943             OR ( SEINM < 0 )
944             OR ( SSPEM < 0 ) ).
945           IF  ( MKOL-WERKS IN NB_WERKS )
946           AND ( NOT NB_WERKS[] IS INITIAL ).    "ch zu 3.0d  /23.02.96
947             CLEAR AUSNAHME_NEG.
948             IF MKOL-SOBKZ = 'K'.                               "br 15.1.95
949               MOVE '04'            TO AUSNAHME_NEG-SAART.  "L.Konsi
950             ELSE.
951               MOVE '11'            TO AUSNAHME_NEG-SAART.  "MTV br 15.1.95
952             ENDIF.
953                  "MKOLs mit negativem Vorperiodenbestand existieren
954             MOVE BUKRS_TAB-BUKRS TO AUSNAHME_NEG-BUKRS.
955             MOVE MKOL-MATNR      TO AUSNAHME_NEG-MATNR.
956             MOVE MKOL-WERKS      TO AUSNAHME_NEG-WERKS.
957             MOVE MKOL-LGORT      TO AUSNAHME_NEG-LGORT.
958             MOVE MKOL-CHARG      TO AUSNAHME_NEG-CHARG.
959             MOVE MKOL-SOBKZ      TO AUSNAHME_NEG-SOBKZ.
960             MOVE MKOL-LIFNR      TO AUSNAHME_NEG-LIFNR.
961             APPEND AUSNAHME_NEG.
962           ENDIF.
963       ENDSELECT.
964    ENDIF.
965
966
967    ENDFORM.
968
969    *------------------------------------------------------------------
970    *           Update der Tabelle MKOL bei Jahreswechsel
971    *------------------------------------------------------------------
972    FORM MKOL_UPDATE_JW.
973
974
975    LOOP AT IN_WERKS.
976
977    EXEC SQL.
978     UPDATE MKOL
979        SET
980             KZVSL         =  KZISL ,
981             KZVSQ         =  KZISQ ,
982             KZVSE         =  KZISE ,
983             KZVSS         =  KZISS ,
984             KZISL         =  :RESET_INV ,
985             KZISQ         =  :RESET_INV ,
986             KZISE         =  :RESET_INV ,
987             KZISS         =  :RESET_INV ,
988             KOJIN         =  :BUKRS_TAB-JAHR
989       WHERE MANDT         =  :SY-MANDT
990       AND   LFGJA        <> :BUKRS_TAB-JAHR
991       AND   WERKS         = :IN_WERKS-VWERK
992    ENDEXEC.
993
994    ZAEHLER_MKOL = ZAEHLER_MKOL + SY-DBCNT.
995
996    ENDLOOP.
997
998    ENDFORM.
999
1000   *------------------------------------------------------------------
1001   *           Update der Tabelle MKOL bei Initialisierung
1002   *------------------------------------------------------------------
1003   FORM MKOL_UPDATE_INI.
1004
1005    UPDATE MKOL
1006       SET
1007            LFGJA         =  BUKRS_TAB-JAHR
1008            LFMON         =  BUKRS_TAB-MONAT
1009      WHERE WERKS         IN IN_WERKS
1010        AND ( LFGJA > BUKRS_TAB-JAHR
1011            OR (   LFGJA = BUKRS_TAB-JAHR
1012               AND LFMON > BUKRS_TAB-MONAT ) ).
1013
1014      ZAEHLER_MKOL = ZAEHLER_MKOL + SY-DBCNT.
1015
1016   * Nach Absprache mit der Bestandsführung sollen bei der Initialisierung
1017   * keine Historiensätze mehr gelöscht werden
1018   *   DELETE FROM MKOLH
1019   *          WHERE WERKS IN IN_WERKS
1020   *          AND ( LFGJA > BUKRS_TAB-JAHR
1021   *              OR (   LFGJA = BUKRS_TAB-JAHR
1022   *                 AND LFMON >= BUKRS_TAB-MONAT ) ).
1023
1024   ENDFORM.
1025
1026   *------------------------------------------------------------------
1027   *           Lesen der Tabelle MSCA zur Ermittlung der Schiefstände
1028   *
1029   * Ab 3.0 wird hier auch geprüft, ob kein MSCA-Satz mit negativem
1030   * Vorperiodenbestand existiert.
1031   *------------------------------------------------------------------
1032   FORM MSCA_SCHIEF.
1033
1034   * Da nur noch auf negative Mengen geprüft wird, wird hier erst mal
1035   * das entsprechende Kennzeichen abgefragt          "ch/4.6
1036   check rm03q-xnegq eq space.                        "
1037   check ( NOT NB_WERKS[] IS INITIAL ).               "
1038
1039    SELECT * INTO MSCAH
1040       FROM MSCAH
1041   *  WHERE WERKS        IN IN_WERKS
1042      WHERE WERKS        IN NB_WERKS               "ch/4.6
1043      AND   LFGJA        =  BUKRS_TAB-VMGJA
1044      AND   LFMON        =  BUKRS_TAB-VMMON
1045      AND (  ( CALAB < 0 )
1046          OR ( CAINS < 0 )
1047          OR ( CASPE < 0 ) ).
1048          IF  ( MSCAH-WERKS IN NB_WERKS )
1049          AND ( NOT NB_WERKS[] IS INITIAL ).    "ch zu 3.0d  /23.02.96
1050            CLEAR AUSNAHME_NEG.
1051            MOVE '08'            TO AUSNAHME_NEG-SAART.
1052                 "MSCAs mit negativem Vorperiodenbestand existieren.
1053            MOVE BUKRS_TAB-BUKRS TO AUSNAHME_NEG-BUKRS.
1054            MOVE MSCAH-MATNR      TO AUSNAHME_NEG-MATNR.
1055            MOVE MSCAH-WERKS      TO AUSNAHME_NEG-WERKS.
1056            MOVE MSCAH-CHARG      TO AUSNAHME_NEG-CHARG.
1057            MOVE MSCAH-LIFNR      TO AUSNAHME_NEG-LIFNR.
1058            MOVE MSCAH-VBELN      TO AUSNAHME_NEG-VBELN.
1059            MOVE MSCAH-POSNR      TO AUSNAHME_NEG-POSNR.
1060            APPEND AUSNAHME_NEG.
1061          ENDIF.
1062    ENDSELECT.
1063
1064   ENDFORM.
1065
1066   *------------------------------------------------------------------
1067   *           Update der Tabelle MSCA  bei Jahreswechsel
1068   *------------------------------------------------------------------
1069   FORM MSCA_UPDATE_JW.
1070
1071   ****   EXEC SQL ist nur bei transparenten Tabellen möglich !!    ****
1072   *OOP AT IN_WERKS.
1073   *
1074   * EXEC SQL.
1075   *   UPDATE MSCA
1076   *      SET
1077   *           CAVIN         =  CAINS ,
1078   *           CAVLA         =  CALAB ,
1079   *           CAVLL         =  CAILL ,
1080   *           CAILL         =  CAFLL ,
1081   *           CAVLQ         =  CAILQ ,
1082   *           CAILQ         =  CAFLQ ,
1083   *           CAFLL         =  :RESET_INV ,
1084   *           CAFLQ         =  :RESET_INV ,
1085   *           LFGJA         =  :BUKRS_TAB-JAHR ,
1086   *           LFMON         =  :BUKRS_TAB-MONAT
1087   *     WHERE MANDT         =  :SY-MANDT
1088   *     AND   LFGJA         = :BUKRS_TAB-VORJAHR
1089   *     AND   LFMON         = :BUKRS_TAB-VORMONAT
1090   *     AND   WERKS         = :IN_WERKS-VWERK
1091   * ENDEXEC.
1092   *
1093   * ZAEHLER_MSCA = ZAEHLER_MSCA + SY-DBCNT.
1094   *
1095   *NDLOOP.
1096
1097   SELECT * FROM MSCA INTO TABLE MSCA_ITAB
1098         WHERE CAJIN        <> BUKRS_TAB-JAHR
1099         AND   WERKS        IN IN_WERKS.
1100
1101   LOOP AT MSCA_ITAB.
1102     MSCA_ITAB-CAVLL  =  MSCA_ITAB-CAILL.
1103     MSCA_ITAB-CAILL  =  MSCA_ITAB-CAFLL.
1104     MSCA_ITAB-CAVLQ  =  MSCA_ITAB-CAILQ.
1105     MSCA_ITAB-CAILQ  =  MSCA_ITAB-CAFLQ.
1106     MSCA_ITAB-CAVLS  =  MSCA_ITAB-CAILS.                        "br17.1.95
1107     MSCA_ITAB-CAILS  =  MSCA_ITAB-CAFLS.                        "br17.1.95
1108     MSCA_ITAB-CAFLL  =  RESET_INV.
1109     MSCA_ITAB-CAFLQ  =  RESET_INV .
1110     MSCA_ITAB-CAFLS  =  RESET_INV .                             "br17.1.95
1111     MSCA_ITAB-CAJIN  =  BUKRS_TAB-JAHR.
1112     MODIFY MSCA_ITAB.
1113   ENDLOOP.
1114
1115   UPDATE MSCA FROM TABLE MSCA_ITAB.
1116   ZAEHLER_MSCA = ZAEHLER_MSCA + SY-DBCNT.
1117
1118   ENDFORM.
1119
1120   *------------------------------------------------------------------
1121   *           Update der Tabelle MSCA bei Initialisierung
1122   *------------------------------------------------------------------
1123   FORM MSCA_UPDATE_INI.
1124
1125    UPDATE MSCA
1126       SET
1127            LFGJA         =  BUKRS_TAB-JAHR
1128            LFMON         =  BUKRS_TAB-MONAT
1129      WHERE WERKS         IN IN_WERKS
1130        AND ( LFGJA > BUKRS_TAB-JAHR
1131            OR (   LFGJA = BUKRS_TAB-JAHR
1132               AND LFMON > BUKRS_TAB-MONAT ) ).
1133
1134      ZAEHLER_MSCA = ZAEHLER_MSCA + SY-DBCNT.
1135
1136   * Nach Absprache mit der Bestandsführung sollen bei der Initialisierung
1137   * keine Historiensätze mehr gelöscht werden
1138   *   DELETE FROM MSCAH
1139   *          WHERE WERKS IN IN_WERKS
1140   *          AND ( LFGJA > BUKRS_TAB-JAHR
1141   *              OR (   LFGJA = BUKRS_TAB-JAHR
1142   *                 AND LFMON >= BUKRS_TAB-MONAT ) ).
1143
1144   ENDFORM.
1145
1146   *------------------------------------------------------------------
1147   *           Lesen der Tabelle MSKA zur Ermittlung der Schiefstände
1148   *
1149   * Ab 3.0 wird hier auch geprüft, ob kein MSKA-Satz mit negativem
1150   * Vorperiodenbestand existiert.
1151   *------------------------------------------------------------------
1152   FORM MSKA_SCHIEF.
1153
1154   * Da nur noch auf negative Mengen geprüft wird, wird hier erst mal
1155   * das entsprechende Kennzeichen abgefragt          "ch/4.6
1156   check rm03q-xnegq eq space.                        "
1157   check ( NOT NB_WERKS[] IS INITIAL ).               "
1158
1159    SELECT * INTO MSKAH
1160       FROM MSKAH
1161   *  WHERE WERKS        IN IN_WERKS
1162      WHERE WERKS        IN NB_WERKS               "ch/4.6
1163      AND   LFGJA        =  BUKRS_TAB-VMGJA
1164      AND   LFMON        =  BUKRS_TAB-VMMON
1165      AND (  ( KALAB < 0 )
1166          OR ( KAINS < 0 )
1167          OR ( KASPE < 0 )
1168          OR ( KAEIN < 0 ) ).
1169        IF  ( MSKAH-WERKS IN NB_WERKS )
1170        AND ( NOT NB_WERKS[] IS INITIAL ).    "ch zu 3.0d  /23.02.96
1171          CLEAR AUSNAHME_NEG.
1172          MOVE '07'            TO AUSNAHME_NEG-SAART.
1173               "MSKAs mit negativem Vorperiodenbestand existieren
1174          MOVE BUKRS_TAB-BUKRS TO AUSNAHME_NEG-BUKRS.
1175          MOVE MSKAH-MATNR      TO AUSNAHME_NEG-MATNR.
1176          MOVE MSKAH-WERKS      TO AUSNAHME_NEG-WERKS.
1177          MOVE MSKAH-LGORT      TO AUSNAHME_NEG-LGORT.
1178          MOVE MSKAH-CHARG      TO AUSNAHME_NEG-CHARG.
1179          MOVE MSKAH-VBELN      TO AUSNAHME_NEG-VBELN.
1180          MOVE MSKAH-POSNR      TO AUSNAHME_NEG-POSNR.
1181          APPEND AUSNAHME_NEG.
1182        ENDIF.
1183    ENDSELECT.
1184
1185   * CH/H:217577 Die Originaltabelle muß auch berücksichtigt werden
1186   IF BUKRS_TAB-MON_40C IS INITIAL.      "d.h. 1. PeriWechsel nach Upgrade
1187     SELECT MSKA~MATNR MSKA~WERKS MSKA~LGORT MSKA~CHARG
1188            MSKA~SOBKZ MSKA~VBELN MSKA~POSNR
1189            MSKAH~MATNR
1190         INTO (MSKA-MATNR, MSKA-WERKS, MSKA-LGORT, MSKA-CHARG,
1191               MSKA-SOBKZ, MSKA-VBELN, MSKA-POSNR,
1192               MSKAH-MATNR)
1193         FROM MSKA LEFT OUTER JOIN MSKAH
1194         ON    MSKA~MATNR  = MSKAH~MATNR
1195           AND MSKA~WERKS  = MSKAH~WERKS
1196           AND MSKA~LGORT  = MSKAH~LGORT
1197           AND MSKA~CHARG  = MSKAH~CHARG
1198           AND MSKA~SOBKZ  = MSKAH~SOBKZ
1199           AND MSKA~VBELN  = MSKAH~VBELN
1200           AND MSKA~POSNR  = MSKAH~POSNR
1201           AND MSKAH~LFGJA  = BUKRS_TAB-VMGJA
1202           AND MSKAH~LFMON  = BUKRS_TAB-VMMON
1203         WHERE MSKA~WERKS  IN NB_WERKS
1204           AND (  MSKA~KAVLA < 0
1205               OR MSKA~KAVIN < 0
1206               OR MSKA~KAVEI < 0
1207               OR MSKA~KAVSP < 0 ).
1208       IF MSKAH-MATNR IS INITIAL.       "d.h. kein MxxxH-Satz vorhanden
1209          IF  ( MSKA-WERKS IN NB_WERKS )
1210          AND ( NOT NB_WERKS[] IS INITIAL ).    "ch zu 3.0d  /23.02.96
1211            CLEAR AUSNAHME_NEG.
1212            MOVE '07'           TO AUSNAHME_NEG-SAART.
1213                 "MSKAs mit negativem Vorperiodenbestand existieren
1214            MOVE BUKRS_TAB-BUKRS TO AUSNAHME_NEG-BUKRS.
1215            MOVE MSKA-MATNR      TO AUSNAHME_NEG-MATNR.
1216            MOVE MSKA-WERKS      TO AUSNAHME_NEG-WERKS.
1217            MOVE MSKA-LGORT      TO AUSNAHME_NEG-LGORT.
1218            MOVE MSKA-CHARG      TO AUSNAHME_NEG-CHARG.
1219            MOVE MSKA-SOBKZ      TO AUSNAHME_NEG-SOBKZ.
1220            MOVE MSKA-VBELN      TO AUSNAHME_NEG-VBELN.
1221            MOVE MSKA-POSNR      TO AUSNAHME_NEG-POSNR.
1222            APPEND AUSNAHME_NEG.
1223          ENDIF.
1224       ENDIF.
1225     ENDSELECT.
1226   ELSE.
1227      SELECT * INTO MSKA
1228         FROM MSKA
1229        WHERE WERKS        IN NB_WERKS
1230        AND   (  LFGJA <  BUKRS_TAB-LFGJA
1231              OR LFMON <  BUKRS_TAB-LFMON )
1232        AND (  ( KALAB < 0 )
1233            OR ( KAINS < 0 )
1234            OR ( KAEIN < 0 )
1235            OR ( KASPE < 0 ) ).
1236          IF  ( MSKA-WERKS IN NB_WERKS )
1237          AND ( NOT NB_WERKS[] IS INITIAL ).    "ch zu 3.0d  /23.02.96
1238            CLEAR AUSNAHME_NEG.
1239            MOVE '07'            TO AUSNAHME_NEG-SAART.
1240                 "MSKAs mit negativem Vorperiodenbestand existieren
1241            MOVE BUKRS_TAB-BUKRS TO AUSNAHME_NEG-BUKRS.
1242            MOVE MSKA-MATNR      TO AUSNAHME_NEG-MATNR.
1243            MOVE MSKA-WERKS      TO AUSNAHME_NEG-WERKS.
1244            MOVE MSKA-LGORT      TO AUSNAHME_NEG-LGORT.
1245            MOVE MSKA-CHARG      TO AUSNAHME_NEG-CHARG.
1246            MOVE MSKA-SOBKZ      TO AUSNAHME_NEG-SOBKZ.
1247            MOVE MSKA-VBELN      TO AUSNAHME_NEG-VBELN.
1248            MOVE MSKA-POSNR      TO AUSNAHME_NEG-POSNR.
1249            APPEND AUSNAHME_NEG.
1250          ENDIF.
1251      ENDSELECT.
1252   ENDIF.
1253
1254
1255   ENDFORM.
1256
1257   *------------------------------------------------------------------
1258   *           Update der Tabelle MSKA  bei Jahreswechsel
1259   *------------------------------------------------------------------
1260   FORM MSKA_UPDATE_JW.
1261
1262   IF SWITCH_ON_TUNE = 'X'.         "neu zu 3.1H/ch
1263     CHECK MSKA_UPD IS INITIAL.
1264     IF SY-DBSYS(3) = 'ORA'.
1265      PERFORM MSKA_UPDATE_JW_ORA CHANGING ZAEHLER_MSKA.
1266
1267     ELSEIF SY-DBSYS(3) = 'INF'.
1268      PERFORM MSKA_UPDATE_JW_INF CHANGING ZAEHLER_MSKA.
1269
1270     ELSEIF SY-DBSYS(3) = 'DB2' OR SY-DBSYS(3) = 'DB4'.
1271      PERFORM MSKA_UPDATE_JW_DB2DB4 CHANGING ZAEHLER_MSKA.
1272
1273   *no SQL tuning for ADABAS, DB2/600 and MS SQL Server
1274     ELSEIF SY-DBSYS(3) = 'ADA' OR SY-DBSYS(3) = 'SQL' OR
1275            SY-DBSYS(3) = 'DB6' OR SY-DBSYS(3) = 'MSS'.
1276      PERFORM MSKA_UPDATE_JW_NEUTRAL CHANGING ZAEHLER_MSKA.
1277
1278     ENDIF. "IF SY-DBSYS(3) = 'ORA'.
1279
1280   ELSE.
1281     SELECT * FROM MSKA INTO TABLE MSKA_ITAB
1282           WHERE KAJIN       <> BUKRS_TAB-JAHR
1283           AND   WERKS        IN IN_WERKS.
1284
1285     LOOP AT MSKA_ITAB.
1286       MSKA_ITAB-KAVLL  =  MSKA_ITAB-KAILL.
1287       MSKA_ITAB-KAILL  =  MSKA_ITAB-KAFLL.
1288       MSKA_ITAB-KAVLQ  =  MSKA_ITAB-KAILQ.
1289       MSKA_ITAB-KAILS  =  MSKA_ITAB-KAFLS.                      "br17.1.95
1290       MSKA_ITAB-KAVLS  =  MSKA_ITAB-KAILS.                      "br17.1.95
1291       MSKA_ITAB-KAILQ  =  MSKA_ITAB-KAFLQ.
1292       MSKA_ITAB-KAFLL  =  RESET_INV.
1293       MSKA_ITAB-KAFLQ  =  RESET_INV .
1294       MSKA_ITAB-KAFLS  =  RESET_INV .                           "br17.1.95
1295       MSKA_ITAB-KAJIN  =  BUKRS_TAB-JAHR.
1296       MODIFY MSKA_ITAB.
1297     ENDLOOP.
1298
1299     UPDATE MSKA FROM TABLE MSKA_ITAB.
1300     ZAEHLER_MSKA = ZAEHLER_MSKA + SY-DBCNT.
1301
1302   ENDIF. "IF SWITCH_ON_TUNE = 'X'.
1303   MSKA_UPD = 'X'.
1304
1305   ENDFORM.
1306
1307   *------------------------------------------------------------------
1308   *           Update der Tabelle MSKA bei Initialisierung
1309   *------------------------------------------------------------------
1310   FORM MSKA_UPDATE_INI.
1311
1312    UPDATE MSKA
1313       SET
1314            LFGJA         =  BUKRS_TAB-JAHR
1315            LFMON         =  BUKRS_TAB-MONAT
1316      WHERE WERKS         IN IN_WERKS
1317        AND ( LFGJA > BUKRS_TAB-JAHR
1318            OR (   LFGJA = BUKRS_TAB-JAHR
1319               AND LFMON > BUKRS_TAB-MONAT ) ).
1320
1321      ZAEHLER_MSKA = ZAEHLER_MSKA + SY-DBCNT.
1322
1323   * Nach Absprache mit der Bestandsführung sollen bei der Initialisierung
1324   * keine Historiensätze mehr gelöscht werden
1325   *     DELETE FROM MSKAH
1326   *          WHERE WERKS IN IN_WERKS
1327   *          AND ( LFGJA > BUKRS_TAB-JAHR
1328   *              OR (   LFGJA = BUKRS_TAB-JAHR
1329   *                 AND LFMON >= BUKRS_TAB-MONAT ) ).
1330
1331   ENDFORM.
1332
1333   *------------------------------------------------------------------
1334   *           Lesen der Tabelle MSKU zur Ermittlung der Schiefstände
1335   *
1336   * Ab 3.0 wird hier auch geprüft, ob kein MARD-Satz mit negativem
1337   * Vorperiodenbestand existiert.
1338   *------------------------------------------------------------------
1339   FORM MSKU_SCHIEF.
1340
1341   * Da nur noch auf negative Mengen geprüft wird, wird hier erst mal
1342   * das entsprechende Kennzeichen abgefragt          "ch/4.6
1343   check rm03q-xnegq eq space.                        "
1344   check ( NOT NB_WERKS[] IS INITIAL ).               "
1345
1346    SELECT * INTO MSKUH
1347       FROM MSKUH
1348   *  WHERE WERKS        IN IN_WERKS
1349      WHERE WERKS        IN NB_WERKS               "ch/4.6
1350      AND   LFGJA        =  BUKRS_TAB-VMGJA
1351      AND   LFMON        =  BUKRS_TAB-VMMON
1352      AND (  ( KULAB < 0 )
1353          OR ( KUINS < 0 )
1354          OR ( KUEIN < 0 ) ).
1355        IF  ( MSKUH-WERKS IN NB_WERKS )
1356        AND ( NOT NB_WERKS[] IS INITIAL ).    "ch zu 3.0d  /23.02.96
1357   *    Kein Abbruch bei Kundenleergut, wenn die Vorperiode nicht
1358   *    im Vorjahr liegt.
1359          IF NOT ( MSKUH-SOBKZ = 'V' AND
1360                 BUKRS_TAB-VMGJA NE BUKRS_TAB-VJGJA ).
1361            CLEAR AUSNAHME_NEG.
1362            IF MSKUH-SOBKZ = 'V'.
1363              MOVE '09'            TO AUSNAHME_NEG-SAART.
1364               "MSKUs die negative Vorperiodenbestände haben / K.Leergut
1365            ELSE.
1366              MOVE '06'            TO AUSNAHME_NEG-SAART.
1367               "MSKUs die negative Vorperiodenbestände haben / K.Konsi
1368            ENDIF.
1369            MOVE BUKRS_TAB-BUKRS TO AUSNAHME_NEG-BUKRS.
1370            MOVE MSKUH-MATNR      TO AUSNAHME_NEG-MATNR.
1371            MOVE MSKUH-WERKS      TO AUSNAHME_NEG-WERKS.
1372            MOVE MSKUH-CHARG      TO AUSNAHME_NEG-CHARG.
1373            MOVE MSKUH-KUNNR      TO AUSNAHME_NEG-KUNNR.
1374            APPEND AUSNAHME_NEG.
1375          ENDIF.
1376        ENDIF.
1377    ENDSELECT.
1378
1379   * CH/H:217577 Die Originaltabelle muß auch berücksichtigt werden
1380   IF BUKRS_TAB-MON_40C IS INITIAL.      "d.h. 1. PeriWechsel nach Upgrade
1381     SELECT MSKU~MATNR MSKU~WERKS MSKU~CHARG
1382            MSKU~SOBKZ MSKU~KUNNR
1383            MSKUH~MATNR
1384         INTO (MSKU-MATNR, MSKU-WERKS, MSKU-CHARG,
1385               MSKU-SOBKZ, MSKU-KUNNR,
1386               MSKUH-MATNR)
1387         FROM MSKU LEFT OUTER JOIN MSKUH
1388         ON    MSKU~MATNR  = MSKUH~MATNR
1389           AND MSKU~WERKS  = MSKUH~WERKS
1390           AND MSKU~CHARG  = MSKUH~CHARG
1391           AND MSKU~SOBKZ  = MSKUH~SOBKZ
1392           AND MSKU~KUNNR  = MSKUH~KUNNR
1393           AND MSKUH~LFGJA  = BUKRS_TAB-VMGJA
1394           AND MSKUH~LFMON  = BUKRS_TAB-VMMON
1395         WHERE MSKU~WERKS  IN NB_WERKS
1396           AND (  MSKU~KUVLA < 0
1397               OR MSKU~KUVIN < 0
1398               OR MSKU~KUVEI < 0 ).
1399       IF MSKUH-MATNR IS INITIAL.       "d.h. kein MxxxH-Satz vorhanden
1400          IF  ( MSKU-WERKS IN NB_WERKS )
1401          AND ( NOT NB_WERKS[] IS INITIAL ).    "ch zu 3.0d  /23.02.96
1402            CLEAR AUSNAHME_NEG.
1403            IF MSKUH-SOBKZ = 'V'.
1404              MOVE '09'            TO AUSNAHME_NEG-SAART.
1405               "MSKUs die negative Vorperiodenbestände haben / K.Leergut
1406            ELSE.
1407              MOVE '06'            TO AUSNAHME_NEG-SAART.
1408               "MSKUs die negative Vorperiodenbestände haben / K.Konsi
1409            ENDIF.
1410                 "MSKUs mit negativem Vorperiodenbestand existieren
1411            MOVE BUKRS_TAB-BUKRS TO AUSNAHME_NEG-BUKRS.
1412            MOVE MSKU-MATNR      TO AUSNAHME_NEG-MATNR.
1413            MOVE MSKU-WERKS      TO AUSNAHME_NEG-WERKS.
1414            MOVE MSKU-CHARG      TO AUSNAHME_NEG-CHARG.
1415            MOVE MSKU-SOBKZ      TO AUSNAHME_NEG-SOBKZ.
1416            MOVE MSKU-KUNNR     TO AUSNAHME_NEG-KUNNR.
1417            APPEND AUSNAHME_NEG.
1418          ENDIF.
1419       ENDIF.
1420     ENDSELECT.
1421   ELSE.
1422      SELECT * INTO MSKU
1423         FROM MSKU
1424        WHERE WERKS        IN NB_WERKS
1425        AND   (  LFGJA <  BUKRS_TAB-LFGJA
1426              OR LFMON <  BUKRS_TAB-LFMON )
1427        AND (  ( KULAB < 0 )
1428            OR ( KUINS < 0 )
1429            OR ( KUEIN < 0 ) ).
1430          IF  ( MSKU-WERKS IN NB_WERKS )
1431          AND ( NOT NB_WERKS[] IS INITIAL ).    "ch zu 3.0d  /23.02.96
1432            CLEAR AUSNAHME_NEG.
1433            IF MSKUH-SOBKZ = 'V'.
1434              MOVE '09'            TO AUSNAHME_NEG-SAART.
1435               "MSKUs die negative Vorperiodenbestände haben / K.Leergut
1436            ELSE.
1437              MOVE '06'            TO AUSNAHME_NEG-SAART.
1438               "MSKUs die negative Vorperiodenbestände haben / K.Konsi
1439            ENDIF.
1440                 "MSKUs mit negativem Vorperiodenbestand existieren
1441            MOVE BUKRS_TAB-BUKRS TO AUSNAHME_NEG-BUKRS.
1442            MOVE MSKU-MATNR      TO AUSNAHME_NEG-MATNR.
1443            MOVE MSKU-WERKS      TO AUSNAHME_NEG-WERKS.
1444            MOVE MSKU-CHARG      TO AUSNAHME_NEG-CHARG.
1445            MOVE MSKU-SOBKZ      TO AUSNAHME_NEG-SOBKZ.
1446            MOVE MSKU-KUNNR     TO AUSNAHME_NEG-KUNNR.
1447            APPEND AUSNAHME_NEG.
1448          ENDIF.
1449      ENDSELECT.
1450   ENDIF.
1451
1452   ENDFORM.
1453
1454   *------------------------------------------------------------------
1455   *           Update der Tabelle MSKU  bei Jahreswechsel
1456   *------------------------------------------------------------------
1457   FORM MSKU_UPDATE_JW.
1458
1459   IF SWITCH_ON_TUNE = 'X'.         "neu zu 3.1H/ch
1460     CHECK MSKU_UPD IS INITIAL.
1461     IF SY-DBSYS(3) = 'ORA'.
1462      PERFORM MSKU_UPDATE_JW_ORA CHANGING ZAEHLER_MSKU.
1463
1464     ELSEIF SY-DBSYS(3) = 'INF'.
1465      PERFORM MSKU_UPDATE_JW_INF CHANGING ZAEHLER_MSKU.
1466
1467     ELSEIF SY-DBSYS(3) = 'DB2' OR SY-DBSYS(3) = 'DB4'.
1468      PERFORM MSKU_UPDATE_JW_DB2DB4 CHANGING ZAEHLER_MSKU.
1469
1470   *no SQL tuning for ADABAS, DB2/600 and MS SQL Server
1471     ELSEIF SY-DBSYS(3) = 'ADA' OR SY-DBSYS(3) = 'SQL' OR
1472            SY-DBSYS(3) = 'DB6' OR SY-DBSYS(3) = 'MSS'.
1473      PERFORM MSKU_UPDATE_JW_NEUTRAL CHANGING ZAEHLER_MSKU.
1474
1475     ENDIF. "IF SY-DBSYS(3) = 'ORA'.
1476
1477   ELSE.
1478     SELECT * FROM MSKU INTO TABLE MSKU_ITAB
1479           WHERE KUJIN        <> BUKRS_TAB-JAHR
1480           AND   WERKS        IN IN_WERKS.
1481
1482     LOOP AT MSKU_ITAB.
1483       MSKU_ITAB-KUVLL  =  MSKU_ITAB-KUILL.
1484       MSKU_ITAB-KUILL  =  MSKU_ITAB-KUFLL.
1485       MSKU_ITAB-KUVLQ  =  MSKU_ITAB-KUILQ.
1486       MSKU_ITAB-KUILQ  =  MSKU_ITAB-KUFLQ.
1487       MSKU_ITAB-KUFLL  =  RESET_INV.
1488       MSKU_ITAB-KUFLQ  =  RESET_INV .
1489       MSKU_ITAB-KUJIN  =  BUKRS_TAB-JAHR.
1490       MODIFY MSKU_ITAB.
1491     ENDLOOP.
1492
1493     UPDATE MSKU FROM TABLE MSKU_ITAB.
1494     ZAEHLER_MSKU = ZAEHLER_MSKU + SY-DBCNT.
1495
1496   ENDIF. "IF SWITCH_ON_TUNE = 'X'.
1497   MSKU_UPD = 'X'.
1498
1499   ENDFORM.
1500
1501   *------------------------------------------------------------------
1502   *           Update der Tabelle MSKU bei Initialisierung
1503   *------------------------------------------------------------------
1504   FORM MSKU_UPDATE_INI.
1505
1506    UPDATE MSKU
1507       SET
1508            LFGJA         =  BUKRS_TAB-JAHR
1509            LFMON         =  BUKRS_TAB-MONAT
1510      WHERE WERKS         IN IN_WERKS
1511        AND ( LFGJA > BUKRS_TAB-JAHR
1512            OR (   LFGJA = BUKRS_TAB-JAHR
1513               AND LFMON > BUKRS_TAB-MONAT ) ).
1514
1515      ZAEHLER_MSKU = ZAEHLER_MSKU + SY-DBCNT.
1516
1517   * Nach Absprache mit der Bestandsführung sollen bei der Initialisierung
1518   * keine Historiensätze mehr gelöscht werden
1519   *       DELETE FROM MSKUH
1520   *          WHERE WERKS IN IN_WERKS
1521   *          AND ( LFGJA > BUKRS_TAB-JAHR
1522   *              OR (   LFGJA = BUKRS_TAB-JAHR
1523   *                 AND LFMON >= BUKRS_TAB-MONAT ) ).
1524
1525   ENDFORM.
1526
1527   *------------------------------------------------------------------
1528   *           Lesen der Tabelle MSLB zur Ermittlung der Schiefstände
1529   *
1530   * Ab 3.0 wird hier auch geprüft, ob kein MARD-Satz mit negativem
1531   * Vorperiodenbestand existiert.
1532   *------------------------------------------------------------------
1533   FORM MSLB_SCHIEF.
1534
1535   * Da nur noch auf negative Mengen geprüft wird, wird hier erst mal
1536   * das entsprechende Kennzeichen abgefragt          "ch/4.6
1537   check rm03q-xnegq eq space.                        "
1538   check ( NOT NB_WERKS[] IS INITIAL ).               "
1539
1540    SELECT * INTO MSLBH
1541       FROM MSLBH
1542   *  WHERE WERKS        IN IN_WERKS
1543      WHERE WERKS        IN NB_WERKS               "ch/4.6
1544      AND   LFGJA        =  BUKRS_TAB-VMGJA
1545      AND   LFMON        =  BUKRS_TAB-VMMON
1546      AND (  ( LBLAB < 0 )
1547          OR ( LBINS < 0 )
1548          OR ( LBEIN < 0 ) ).
1549        IF  ( MSLBH-WERKS IN NB_WERKS )
1550        AND ( NOT NB_WERKS[] IS INITIAL ).    "ch zu 3.0d  /23.02.96
1551          CLEAR AUSNAHME_NEG.
1552          MOVE '05'            TO AUSNAHME_NEG-SAART.
1553             "MSLBs mit negativem Vorperiodenbestand existieren
1554          MOVE BUKRS_TAB-BUKRS TO AUSNAHME_NEG-BUKRS.
1555          MOVE MSLBH-MATNR      TO AUSNAHME_NEG-MATNR.
1556          MOVE MSLBH-WERKS      TO AUSNAHME_NEG-WERKS.
1557          MOVE MSLBH-CHARG      TO AUSNAHME_NEG-CHARG.
1558          MOVE MSLBH-LIFNR      TO AUSNAHME_NEG-LIFNR.
1559          APPEND AUSNAHME_NEG.
1560        ENDIF.
1561    ENDSELECT.
1562
1563   * CH/H:217577 Die Originaltabelle muß auch berücksichtigt werden
1564   IF BUKRS_TAB-MON_40C IS INITIAL.      "d.h. 1. PeriWechsel nach Upgrade
1565     SELECT MSLB~MATNR MSLB~WERKS MSLB~CHARG
1566            MSLB~SOBKZ MSLB~LIFNR
1567            MSLBH~MATNR
1568         INTO (MSLB-MATNR, MSLB-WERKS, MSLB-CHARG,
1569               MSLB-SOBKZ, MSLB-LIFNR,
1570               MSLBH-MATNR)
1571         FROM MSLB LEFT OUTER JOIN MSLBH
1572         ON    MSLB~MATNR  = MSLBH~MATNR
1573           AND MSLB~WERKS  = MSLBH~WERKS
1574           AND MSLB~CHARG  = MSLBH~CHARG
1575           AND MSLB~SOBKZ  = MSLBH~SOBKZ
1576           AND MSLB~LIFNR  = MSLBH~LIFNR
1577           AND MSLBH~LFGJA  = BUKRS_TAB-VMGJA
1578           AND MSLBH~LFMON  = BUKRS_TAB-VMMON
1579         WHERE MSLB~WERKS  IN NB_WERKS
1580           AND (  MSLB~LBVLA < 0
1581               OR MSLB~LBVIN < 0
1582               OR MSLB~LBVEI < 0 ).
1583       IF MSLBH-MATNR IS INITIAL.       "d.h. kein MxxxH-Satz vorhanden
1584          IF  ( MSLB-WERKS IN NB_WERKS )
1585          AND ( NOT NB_WERKS[] IS INITIAL ).    "ch zu 3.0d  /23.02.96
1586            CLEAR AUSNAHME_NEG.
1587            MOVE '05'           TO AUSNAHME_NEG-SAART.
1588                 "MSLBs mit negativem Vorperiodenbestand existieren
1589            MOVE BUKRS_TAB-BUKRS TO AUSNAHME_NEG-BUKRS.
1590            MOVE MSLB-MATNR      TO AUSNAHME_NEG-MATNR.
1591            MOVE MSLB-WERKS      TO AUSNAHME_NEG-WERKS.
1592            MOVE MSLB-CHARG      TO AUSNAHME_NEG-CHARG.
1593            MOVE MSLB-SOBKZ      TO AUSNAHME_NEG-SOBKZ.
1594            MOVE MSLB-LIFNR      TO AUSNAHME_NEG-LIFNR.
1595            APPEND AUSNAHME_NEG.
1596          ENDIF.
1597       ENDIF.
1598     ENDSELECT.
1599   ELSE.
1600      SELECT * INTO MSLB
1601         FROM MSLB
1602        WHERE WERKS        IN NB_WERKS
1603        AND   (  LFGJA <  BUKRS_TAB-LFGJA
1604              OR LFMON <  BUKRS_TAB-LFMON )
1605        AND (  ( LBLAB < 0 )
1606            OR ( LBINS < 0 )
1607            OR ( LBEIN < 0 ) ).
1608          IF  ( MSLB-WERKS IN NB_WERKS )
1609          AND ( NOT NB_WERKS[] IS INITIAL ).    "ch zu 3.0d  /23.02.96
1610            CLEAR AUSNAHME_NEG.
1611              MOVE '05'            TO AUSNAHME_NEG-SAART.
1612               "MSLBs die negative Vorperiodenbestände haben / K.Leergut
1613            MOVE BUKRS_TAB-BUKRS TO AUSNAHME_NEG-BUKRS.
1614            MOVE MSLB-MATNR      TO AUSNAHME_NEG-MATNR.
1615            MOVE MSLB-WERKS      TO AUSNAHME_NEG-WERKS.
1616            MOVE MSLB-CHARG      TO AUSNAHME_NEG-CHARG.
1617            MOVE MSLB-SOBKZ      TO AUSNAHME_NEG-SOBKZ.
1618            MOVE MSLB-LIFNR      TO AUSNAHME_NEG-LIFNR.
1619            APPEND AUSNAHME_NEG.
1620          ENDIF.
1621      ENDSELECT.
1622   ENDIF.
1623
1624   ENDFORM.
1625
1626   *------------------------------------------------------------------
1627   *           Update der Tabelle MSLB  bei Jahreswechsel
1628   *------------------------------------------------------------------
1629   FORM MSLB_UPDATE_JW.
1630
1631   ****   EXEC SQL ist nur bei transparenten Tabellen möglich !!    ****
1632   *OOP AT IN_WERKS.
1633   *
1634   * EXEC SQL.
1635   *   UPDATE MSLB
1636   *      SET
1637   *           LBVIN         =  LBINS ,
1638   *           LBVLA         =  LBLAB ,
1639   *           LBVLL         =  LBILL ,
1640   *           LBILL         =  LBFLL ,
1641   *           LBVLQ         =  LBILQ ,
1642   *           LBILQ         =  LBFLQ ,
1643   *           LBFLL         =  :RESET_INV ,
1644   *           LBFLQ         =  :RESET_INV ,
1645   *           LFGJA         =  :BUKRS_TAB-JAHR ,
1646   *           LFMON         =  :BUKRS_TAB-MONAT
1647   *     WHERE MANDT         =  :SY-MANDT
1648   *     AND   LFGJA         = :BUKRS_TAB-VORJAHR
1649   *     AND   LFMON         = :BUKRS_TAB-VORMONAT
1650   *     AND   WERKS         = :IN_WERKS-VWERK
1651   * ENDEXEC.
1652   *
1653   * ZAEHLER_MSLB = ZAEHLER_MSLB + SY-DBCNT.
1654   *
1655   *NDLOOP.
1656
1657   SELECT * FROM MSLB INTO TABLE MSLB_ITAB
1658         WHERE LBJIN        <> BUKRS_TAB-JAHR
1659         AND   WERKS        IN IN_WERKS.
1660
1661   LOOP AT MSLB_ITAB.
1662     MSLB_ITAB-LBVLL  =  MSLB_ITAB-LBILL.
1663     MSLB_ITAB-LBILL  =  MSLB_ITAB-LBFLL.
1664     MSLB_ITAB-LBVLQ  =  MSLB_ITAB-LBILQ.
1665     MSLB_ITAB-LBILQ  =  MSLB_ITAB-LBFLQ.
1666     MSLB_ITAB-LBFLL  =  RESET_INV.
1667     MSLB_ITAB-LBFLQ  =  RESET_INV .
1668     MSLB_ITAB-LBJIN  =  BUKRS_TAB-JAHR.
1669     MODIFY MSLB_ITAB.
1670   ENDLOOP.
1671
1672   UPDATE MSLB FROM TABLE MSLB_ITAB.
1673   ZAEHLER_MSLB = ZAEHLER_MSLB + SY-DBCNT.
1674
1675   ENDFORM.
1676
1677   *------------------------------------------------------------------
1678   *           Update der Tabelle MSLB bei Initialisierung
1679   *------------------------------------------------------------------
1680   FORM MSLB_UPDATE_INI.
1681
1682    UPDATE MSLB
1683       SET
1684            LFGJA         =  BUKRS_TAB-JAHR
1685            LFMON         =  BUKRS_TAB-MONAT
1686      WHERE WERKS         IN IN_WERKS
1687        AND ( LFGJA > BUKRS_TAB-JAHR
1688            OR (   LFGJA = BUKRS_TAB-JAHR
1689               AND LFMON > BUKRS_TAB-MONAT ) ).
1690
1691      ZAEHLER_MSLB = ZAEHLER_MSLB + SY-DBCNT.
1692
1693   * Nach Absprache mit der Bestandsführung sollen bei der Initialisierung
1694   * keine Historiensätze mehr gelöscht werden
1695   *   DELETE FROM MSLBH
1696   *          WHERE WERKS IN IN_WERKS
1697   *          AND ( LFGJA > BUKRS_TAB-JAHR
1698   *              OR (   LFGJA = BUKRS_TAB-JAHR
1699   *                 AND LFMON >= BUKRS_TAB-MONAT ) ).
1700
1701   ENDFORM.
1702
1703   *------------------------------------------------------------------
1704   *           Update der Tabelle MSOA bei Initialisierung
1705   *------------------------------------------------------------------
1706   FORM MSOA_UPDATE_INI.
1707
1708    UPDATE MSOA
1709       SET
1710            LFGJA         =  BUKRS_TAB-JAHR
1711            LFMON         =  BUKRS_TAB-MONAT
1712      WHERE WERKS         IN IN_WERKS
1713        AND ( LFGJA > BUKRS_TAB-JAHR
1714            OR (   LFGJA = BUKRS_TAB-JAHR
1715               AND LFMON > BUKRS_TAB-MONAT ) ).
1716
1717      ZAEHLER_MSOA = ZAEHLER_MSOA + SY-DBCNT.
1718
1719   ENDFORM.
1720
1721   *------------------------------------------------------------------
1722   * Lesen der Tabelle MSPR zur Ermittlung der Schiefstände
1723   *
1724   *  neu zu 3.0 br13.1.95
1725   *
1726   * hier wird auch geprüft, ob kein MSPR-Satz mit negativem Vorperioden-
1727   * bestand existiert.
1728   *------------------------------------------------------------------
1729   FORM MSPR_SCHIEF.
1730
1731   * Da nur noch auf negative Mengen geprüft wird, wird hier erst mal
1732   * das entsprechende Kennzeichen abgefragt          "ch/4.6
1733   check rm03q-xnegq eq space.                        "
1734   check ( NOT NB_WERKS[] IS INITIAL ).               "
1735
1736    SELECT * INTO MSPRH
1737       FROM MSPRH
1738   *  WHERE WERKS        IN IN_WERKS
1739      WHERE WERKS        IN NB_WERKS               "ch/4.6
1740      AND   LFGJA        =  BUKRS_TAB-VMGJA
1741      AND   LFMON        =  BUKRS_TAB-VMMON
1742      AND (  ( PRLAB < 0 )
1743          OR ( PRINS < 0 )
1744          OR ( PRSPE < 0 )
1745          OR ( PREIN < 0 ) ).
1746        IF  ( MSPRH-WERKS IN NB_WERKS )
1747        AND ( NOT NB_WERKS[] IS INITIAL ).    "ch zu 3.0d  /23.02.96
1748          CLEAR AUSNAHME_NEG.
1749          MOVE '10'            TO AUSNAHME_NEG-SAART.
1750               "MSPRs mit negativem Vorperiodenbestand existieren
1751          MOVE BUKRS_TAB-BUKRS TO AUSNAHME_NEG-BUKRS.
1752          MOVE MSPRH-MATNR      TO AUSNAHME_NEG-MATNR.
1753          MOVE MSPRH-WERKS      TO AUSNAHME_NEG-WERKS.
1754          MOVE MSPRH-LGORT      TO AUSNAHME_NEG-LGORT.
1755          MOVE MSPRH-CHARG      TO AUSNAHME_NEG-CHARG.
1756          MOVE MSPRH-PSPNR      TO AUSNAHME_NEG-PSPNR.
1757          APPEND AUSNAHME_NEG.
1758        ENDIF.
1759    ENDSELECT.
1760
1761   * CH/H:217577 Die Originaltabelle muß auch berücksichtigt werden
1762   IF BUKRS_TAB-MON_40C IS INITIAL.      "d.h. 1. PeriWechsel nach Upgrade
1763     SELECT MSPR~MATNR MSPR~WERKS MSPR~LGORT MSPR~CHARG
1764            MSPR~SOBKZ MSPR~PSPNR
1765            MSPRH~MATNR
1766         INTO (MSPR-MATNR, MSPR-WERKS, MSPR-LGORT, MSPR-CHARG,
1767               MSPR-SOBKZ, MSPR-PSPNR,
1768               MSPRH-MATNR)
1769         FROM MSPR LEFT OUTER JOIN MSPRH
1770         ON    MSPR~MATNR  = MSPRH~MATNR
1771           AND MSPR~WERKS  = MSPRH~WERKS
1772           AND MSPR~LGORT  = MSPRH~LGORT
1773           AND MSPR~CHARG  = MSPRH~CHARG
1774           AND MSPR~SOBKZ  = MSPRH~SOBKZ
1775           AND MSPR~PSPNR  = MSPRH~PSPNR
1776           AND MSPRH~LFGJA  = BUKRS_TAB-VMGJA
1777           AND MSPRH~LFMON  = BUKRS_TAB-VMMON
1778         WHERE MSPR~WERKS  IN NB_WERKS
1779           AND (  MSPR~PRVLA < 0
1780               OR MSPR~PRVIN < 0
1781               OR MSPR~PRVEI < 0
1782               OR MSPR~PRVSP < 0 ).
1783       IF MSPRH-MATNR IS INITIAL.       "d.h. kein MxxxH-Satz vorhanden
1784          IF  ( MSPR-WERKS IN NB_WERKS )
1785          AND ( NOT NB_WERKS[] IS INITIAL ).    "ch zu 3.0d  /23.02.96
1786            CLEAR AUSNAHME_NEG.
1787            MOVE '10'           TO AUSNAHME_NEG-SAART.
1788                 "MSPRs mit negativem Vorperiodenbestand existieren
1789            MOVE BUKRS_TAB-BUKRS TO AUSNAHME_NEG-BUKRS.
1790            MOVE MSPR-MATNR      TO AUSNAHME_NEG-MATNR.
1791            MOVE MSPR-WERKS      TO AUSNAHME_NEG-WERKS.
1792            MOVE MSPR-LGORT      TO AUSNAHME_NEG-LGORT.
1793            MOVE MSPR-CHARG      TO AUSNAHME_NEG-CHARG.
1794            MOVE MSPR-SOBKZ      TO AUSNAHME_NEG-SOBKZ.
1795            MOVE MSPR-PSPNR      TO AUSNAHME_NEG-PSPNR.
1796            APPEND AUSNAHME_NEG.
1797          ENDIF.
1798       ENDIF.
1799     ENDSELECT.
1800   ELSE.
1801      SELECT * INTO MSPR
1802         FROM MSPR
1803        WHERE WERKS        IN NB_WERKS
1804        AND   (  LFGJA <  BUKRS_TAB-LFGJA
1805              OR LFMON <  BUKRS_TAB-LFMON )
1806        AND (  ( PRLAB < 0 )
1807            OR ( PRINS < 0 )
1808            OR ( PREIN < 0 )
1809            OR ( PRSPE < 0 ) ).               "#EC CI_NOFIRST
1810          IF  ( MSPR-WERKS IN NB_WERKS )
1811          AND ( NOT NB_WERKS[] IS INITIAL ).    "ch zu 3.0d  /23.02.96
1812            CLEAR AUSNAHME_NEG.
1813            MOVE '10'            TO AUSNAHME_NEG-SAART.
1814                 "MSPRs mit negativem Vorperiodenbestand existieren
1815            MOVE BUKRS_TAB-BUKRS TO AUSNAHME_NEG-BUKRS.
1816            MOVE MSPR-MATNR      TO AUSNAHME_NEG-MATNR.
1817            MOVE MSPR-WERKS      TO AUSNAHME_NEG-WERKS.
1818            MOVE MSPR-LGORT      TO AUSNAHME_NEG-LGORT.
1819            MOVE MSPR-CHARG      TO AUSNAHME_NEG-CHARG.
1820            MOVE MSPR-SOBKZ      TO AUSNAHME_NEG-SOBKZ.
1821            MOVE MSPR-PSPNR      TO AUSNAHME_NEG-PSPNR.
1822            APPEND AUSNAHME_NEG.
1823          ENDIF.
1824      ENDSELECT.
1825   ENDIF.
1826
1827   ENDFORM.                    " MSPR_SCHIEF
1828
1829   *------------------------------------------------------------------
1830   *  Update der Tabelle MSPR  bei Jahreswechsel
1831   *  neu zu 3.0 br13.1.95
1832   *------------------------------------------------------------------
1833   FORM MSPR_UPDATE_JW.
1834
1835   SELECT * FROM MSPR INTO TABLE MSPR_ITAB
1836         WHERE PRJIN        <> BUKRS_TAB-JAHR
1837         AND   WERKS        IN IN_WERKS.       "#EC CI_NOFIRST
1838
1839   LOOP AT MSPR_ITAB.
1840     MSPR_ITAB-PRVLL  =  MSPR_ITAB-PRILL.
1841     MSPR_ITAB-PRILL  =  MSPR_ITAB-PRFLL.
1842     MSPR_ITAB-PRVLQ  =  MSPR_ITAB-PRILQ.
1843     MSPR_ITAB-PRILQ  =  MSPR_ITAB-PRFLQ.
1844     MSPR_ITAB-PRVLS  =  MSPR_ITAB-PRILS.
1845     MSPR_ITAB-PRILS  =  MSPR_ITAB-PRFLS.
1846     MSPR_ITAB-PRFLL  =  RESET_INV.
1847     MSPR_ITAB-PRFLQ  =  RESET_INV .
1848     MSPR_ITAB-PRFLS  =  RESET_INV .
1849     MSPR_ITAB-PRVIN  =  BUKRS_TAB-JAHR.
1850     MODIFY MSPR_ITAB.
1851   ENDLOOP.
1852
1853   UPDATE MSPR FROM TABLE MSPR_ITAB.
1854   ZAEHLER_MSPR = ZAEHLER_MSPR + SY-DBCNT.
1855
1856   ENDFORM.
1857
1858   *------------------------------------------------------------------
1859   *  Update der Tabelle MSPR bei Initialisierung
1860   *  neu zu 3.0 br13.1.95
1861   *------------------------------------------------------------------
1862   FORM MSPR_UPDATE_INI.
1863
1864    UPDATE MSPR
1865       SET
1866            LFGJA         =  BUKRS_TAB-JAHR
1867            LFMON         =  BUKRS_TAB-MONAT
1868      WHERE WERKS         IN IN_WERKS
1869        AND ( LFGJA > BUKRS_TAB-JAHR
1870            OR (   LFGJA = BUKRS_TAB-JAHR
1871               AND LFMON > BUKRS_TAB-MONAT ) ).   "#EC CI_NOFIRST
1872
1873      ZAEHLER_MSPR = ZAEHLER_MSPR + SY-DBCNT.
1874
1875   * Nach Absprache mit der Bestandsführung sollen bei der Initialisierung
1876   * keine Historiensätze mehr gelöscht werden
1877   *   DELETE FROM MSPRH
1878   *          WHERE WERKS IN IN_WERKS
1879   *          AND ( LFGJA > BUKRS_TAB-JAHR
1880   *              OR (   LFGJA = BUKRS_TAB-JAHR
1881   *                 AND LFMON >= BUKRS_TAB-MONAT ) ).
1882
1883   ENDFORM.
1884
1885   *------------------------------------------------------------------
1886   *           Update der Tabelle MSSA bei Initialisierung
1887   *------------------------------------------------------------------
1888   FORM MSSA_UPDATE_INI.
1889
1890   * UPDATE MSSA
1891   *    SET
1892   *         LFGJA         =  BUKRS_TAB-JAHR
1893   *         LFMON         =  BUKRS_TAB-MONAT
1894   *   WHERE WERKS         IN IN_WERKS
1895   *     AND ( LFGJA > BUKRS_TAB-JAHR
1896   *         OR (   LFGJA = BUKRS_TAB-JAHR
1897   *            AND LFMON > BUKRS_TAB-MONAT ) ).
1898
1899   *   ZAEHLER_MSSA = ZAEHLER_MSSA + SY-DBCNT.
1900
1901   ENDFORM.
1902
1903   *------------------------------------------------------------------
1904   *           Update der Tabelle MSSL bei Initialisierung
1905   *------------------------------------------------------------------
1906   FORM MSSL_UPDATE_INI.
1907
1908   * UPDATE MSSL
1909   *    SET
1910   *         LFGJA         =  BUKRS_TAB-JAHR
1911   *         LFMON         =  BUKRS_TAB-MONAT
1912   *   WHERE WERKS         IN IN_WERKS
1913   *     AND ( LFGJA > BUKRS_TAB-JAHR
1914   *         OR (   LFGJA = BUKRS_TAB-JAHR
1915   *            AND LFMON > BUKRS_TAB-MONAT ) ).
1916   *
1917   *   ZAEHLER_MSSL = ZAEHLER_MSSL + SY-DBCNT.
1918
1919   ENDFORM.
1920
1921   *------------------------------------------------------------------
1922   *  Update der Tabelle MSSQ bei Initialisierung
1923   *  neu zu 3.0 br13.1.95
1924   *------------------------------------------------------------------
1925   FORM MSSQ_UPDATE_INI.
1926
1927   * UPDATE MSSQ
1928   *    SET
1929   *         LFGJA         =  BUKRS_TAB-JAHR
1930   *         LFMON         =  BUKRS_TAB-MONAT
1931   *   WHERE WERKS         IN IN_WERKS
1932   *     AND ( LFGJA > BUKRS_TAB-JAHR
1933   *         OR (   LFGJA = BUKRS_TAB-JAHR
1934   *            AND LFMON > BUKRS_TAB-MONAT ) ).
1935   *
1936   *   ZAEHLER_MSSQ = ZAEHLER_MSSQ + SY-DBCNT.
1937
1938   ENDFORM.
1939   *------------------------------------------------------------------
1940   *  Update der Tabelle MARC bei Initialisierung
1941   *  note 1645304
1942   *------------------------------------------------------------------
1943   FORM MARC_UPDATE_INI.
1944
1945    UPDATE MARC
1946       SET
1947            LFGJA         =  BUKRS_TAB-JAHR
1948            LFMON         =  BUKRS_TAB-MONAT
1949      WHERE WERKS         IN IN_WERKS
1950        AND ( LFGJA > BUKRS_TAB-JAHR
1951            OR (   LFGJA = BUKRS_TAB-JAHR
1952               AND LFMON > BUKRS_TAB-MONAT ) ).
1953
1954   ENDFORM.
1955   *------------------------------------------------------------------
1956   *  Update der Tabelle MSTB bei Initialisierung
1957   *  note 1645304
1958   *------------------------------------------------------------------
1959   FORM MSTB_UPDATE_INI.
1960
1961   * UPDATE MSTB
1962   *    SET
1963   *         LFGJA         =  BUKRS_TAB-JAHR
1964   *         LFMON         =  BUKRS_TAB-MONAT
1965   *   WHERE WERKS         IN IN_WERKS
1966   *     AND ( LFGJA > BUKRS_TAB-JAHR
1967   *         OR (   LFGJA = BUKRS_TAB-JAHR
1968   *            AND LFMON > BUKRS_TAB-MONAT ) ).
1969
1970   ENDFORM.
1971   *------------------------------------------------------------------
1972   *  Update der Tabelle MSTE bei Initialisierung
1973   *  note 1645304
1974   *------------------------------------------------------------------
1975   FORM MSTE_UPDATE_INI.
1976   *
1977   * UPDATE MSTE
1978   *    SET
1979   *         LFGJA         =  BUKRS_TAB-JAHR
1980   *         LFMON         =  BUKRS_TAB-MONAT
1981   *   WHERE WERKS         IN IN_WERKS
1982   *     AND ( LFGJA > BUKRS_TAB-JAHR
1983   *         OR (   LFGJA = BUKRS_TAB-JAHR
1984   *            AND LFMON > BUKRS_TAB-MONAT ) ).
1985
1986   ENDFORM.
1987   *------------------------------------------------------------------
1988   * Update der Tabelle MSTQ bei Initialisierung
1989   *  note 1645304
1990   *------------------------------------------------------------------
1991   FORM MSTQ_UPDATE_INI.
1992
1993   * UPDATE MSTQ
1994   *    SET
1995   *         LFGJA         =  BUKRS_TAB-JAHR
1996   *         LFMON         =  BUKRS_TAB-MONAT
1997   *   WHERE WERKS         IN IN_WERKS
1998   *     AND ( LFGJA > BUKRS_TAB-JAHR
1999   *         OR (   LFGJA = BUKRS_TAB-JAHR
2000   *            AND LFMON > BUKRS_TAB-MONAT ) ).
2001
2002   ENDFORM.
2003   *------------------------------------------------------------------
2004   * Year change Update (Jahreswechsel) of table MARD for ORACLE
2005   *------------------------------------------------------------------
2006   FORM MARD_UPDATE_JW_ORA CHANGING ZAEHLER_MARD.
2007   *KUGL, 20.8.96: Force full table scan by using optimizer hint and use
2008   *               nested selects instead of LOOPS
2009     EXEC SQL.
2010      UPDATE /*+ FULL(MARD)  */
2011      MARD
2012         SET
2013              KZVLL         =  KZILL ,
2014              KZVLQ         =  KZILQ ,
2015              KZVLE         =  KZILE ,
2016              KZVLS         =  KZILS ,
2017              KZILL         =  :RESET_INV ,
2018              KZILQ         =  :RESET_INV ,
2019              KZILE         =  :RESET_INV ,
2020              KZILS         =  :RESET_INV ,
2021              MDJIN         =  :BUKRS_TAB-JAHR
2022        WHERE MANDT         =  :SY-MANDT
2023        AND   MDJIN        <> :BUKRS_TAB-JAHR
2024        AND   WERKS         IN ( SELECT WERKS FROM T001W WHERE BWKEY IN
2025                               ( SELECT BWKEY FROM T001K WHERE BUKRS
2026                                 = :BUKRS_TAB-BUKRS ) )
2027     ENDEXEC.
2028
2029   *KUGL, 30.12.96: For parallel processing on multiprocessor machines.
2030   *Modify the sql statement by adding the degree of parallelism (n).
2031   *But before read your ORACLE manual about the benefits of parallel
2032   *query.
2033   *       exec sql.
2034   *          update /*+ full(mard) degree(n)          */
2035   *          mard
2036   *             ..........
2037     ZAEHLER_MARD = ZAEHLER_MARD + SY-DBCNT.                     "KUGL
2038   ENDFORM.  "mard_update_jw_ora
2039
2040
2041   *------------------------------------------------------------------
2042   * Year change Update (Jahreswechsel) of table MARD for INFORMIX
2043   *------------------------------------------------------------------
2044   FORM MARD_UPDATE_JW_INF CHANGING ZAEHLER_MARD.
2045   *KUGL, 20.8.96: Force full table scan by using trick with IS NOT NULL
2046   * (no optimizer hint available for INFORMIX) and use nested select
2047   * instead of LOOP
2048     EXEC SQL.
2049      UPDATE MARD
2050         SET
2051              KZVLL         =  KZILL ,
2052              KZVLQ         =  KZILQ ,
2053              KZVLE         =  KZILE ,
2054              KZVLS         =  KZILS ,
2055              KZILL         =  :RESET_INV ,
2056              KZILQ         =  :RESET_INV ,
2057              KZILE         =  :RESET_INV ,
2058              KZILS         =  :RESET_INV ,
2059              MDJIN         =  :BUKRS_TAB-JAHR
2060        WHERE ( MANDT IS NOT NULL AND MANDT = :SY-MANDT )
2061        AND   MDJIN        <> :BUKRS_TAB-JAHR
2062        AND   WERKS  IN ( SELECT WERKS FROM T001W WHERE BWKEY IN
2063                        ( SELECT BWKEY FROM T001K WHERE BUKRS
2064                                 = :BUKRS_TAB-BUKRS ) )
2065     ENDEXEC.
2066     ZAEHLER_MARD = ZAEHLER_MARD + SY-DBCNT.                     "KUGL
2067   ENDFORM. "mard_update_jw_inf
2068
2069
2070
2071   *------------------------------------------------------------------
2072   * Year change Update (Jahreswechsel) of table MARD for
2073   *         ADABAS, DB2/6000 and MS SQL SERVER
2074   *------------------------------------------------------------------
2075   FORM MARD_UPDATE_JW_NEUTRAL CHANGING ZAEHLER_MARD.
2076   *KUGL: For future use:
2077   *turn on special optimizer flag for DB2/6000 = 'DB6'
2078   *if sy-dbsys(3) = 'DB6'.
2079   * exec sql.
2080   *   set current query optimization 5
2081   * endexec.
2082   *endif.
2083
2084   *KUGL, 20.8.96:
2085   *           ADABAS, DB6 and MSSQL-Server code
2086   *           no tuning information was added at all (not necessary)
2087     EXEC SQL.
2088      UPDATE MARD
2089         SET
2090              KZVLL         =  KZILL ,
2091              KZVLQ         =  KZILQ ,
2092              KZVLE         =  KZILE ,
2093              KZVLS         =  KZILS ,
2094              KZILL         =  :RESET_INV ,
2095              KZILQ         =  :RESET_INV ,
2096              KZILE         =  :RESET_INV ,
2097              KZILS         =  :RESET_INV ,
2098              MDJIN         =  :BUKRS_TAB-JAHR
2099        WHERE MANDT         =  :SY-MANDT
2100        AND   MDJIN        <> :BUKRS_TAB-JAHR
2101        AND   WERKS         IN ( SELECT WERKS FROM T001W WHERE BWKEY IN
2102                               ( SELECT BWKEY FROM T001K WHERE BUKRS
2103                                 = :BUKRS_TAB-BUKRS ) )
2104     ENDEXEC.
2105     ZAEHLER_MARD = ZAEHLER_MARD + SY-DBCNT.
2106   *KUGL:For future use:
2107   *reset special optimizer flag for DB2/6000 = 'DB6' back to 0
2108   *if sy-dbsys(3) = 'DB6'.
2109   * exec sql.
2110   *   set current query optimization 0
2111   * endexec.
2112   *endif.
2113   ENDFORM. "mard_update_jw_neutral.
2114
2115
2116
2117   *------------------------------------------------------------------
2118   * Year change Update (Jahreswechsel) of table MARD for
2119   *                      DB2/MVS und DB/400
2120   *------------------------------------------------------------------
2121   FORM MARD_UPDATE_JW_DB2DB4 CHANGING ZAEHLER_MARD.
2122   *KUGL, 20.8.96: Force full table scan by using trick with (0=1)condition
2123   * (no optimizer hint available) and use nested select instead of LOOP
2124     EXEC SQL.
2125      UPDATE
2126      MARD
2127         SET
2128              KZVLL         =  KZILL ,
2129              KZVLQ         =  KZILQ ,
2130              KZVLE         =  KZILE ,
2131              KZVLS         =  KZILS ,
2132              KZILL         =  :RESET_INV ,
2133              KZILQ         =  :RESET_INV ,
2134              KZILE         =  :RESET_INV ,
2135              KZILS         =  :RESET_INV ,
2136              MDJIN         =  :BUKRS_TAB-JAHR
2137        WHERE ( MANDT         =  :SY-MANDT OR 0=1)
2138        AND   MDJIN        <> :BUKRS_TAB-JAHR
2139        AND   WERKS         IN ( SELECT WERKS FROM T001W WHERE BWKEY IN
2140                               ( SELECT BWKEY FROM T001K WHERE BUKRS
2141                                 = :BUKRS_TAB-BUKRS ) )
2142     ENDEXEC.
2143     ZAEHLER_MARD = ZAEHLER_MARD + SY-DBCNT.                     "KUGL
2144   ENDFORM. "mard_update_jw_db2db4
2145
2146
2147
2148   *------------------------------------------------------------------
2149   * Year change Update (Jahreswechsel) of table MCHB for ORACLE
2150   *------------------------------------------------------------------
2151   FORM MCHB_UPDATE_JW_ORA CHANGING ZAEHLER_MCHB.
2152   *KUGL, 20.8.96: Force full table scan by using optimizer hint and use
2153   *               nested selects instead of LOOPS
2154   *KUGL, 30.12.96:
2155   *If parallel query is required please look at sql modifications
2156   *of table MARD mchb_update_jw_ora
2157
2158     EXEC SQL.
2159      UPDATE /*+ FULL(MCHB)      */
2160      MCHB
2161         SET
2162              KZVCL         =  KZICL ,
2163              KZVCQ         =  KZICQ ,
2164              KZVCE         =  KZICE ,
2165              KZVCS         =  KZICS ,
2166              KZICL         =  :RESET_INV ,
2167              KZICQ         =  :RESET_INV ,
2168              KZICE         =  :RESET_INV ,
2169              KZICS         =  :RESET_INV ,
2170              CHJIN         =  :BUKRS_TAB-JAHR
2171        WHERE MANDT         =  :SY-MANDT
2172        AND   CHJIN        <> :BUKRS_TAB-JAHR
2173        AND   WERKS IN ( SELECT WERKS FROM T001W WHERE BWKEY IN
2174              ( SELECT BWKEY FROM T001K WHERE BUKRS
2175              = :BUKRS_TAB-BUKRS ) )
2176     ENDEXEC.
2177     ZAEHLER_MCHB = ZAEHLER_MCHB + SY-DBCNT.                     "KUGL
2178   ENDFORM. "mchb_update_jw_ora
2179
2180
2181   *------------------------------------------------------------------
2182   * Year change Update (Jahreswechsel) of table MCHB for INFORMIX
2183   *------------------------------------------------------------------
2184   *KUGL, 20.8.96: Force full table scan by using trick with IS NOT NULL
2185   * (no optimizer hint available for INFORMIX) and use nested select
2186   * instead of LOOP
2187   FORM MCHB_UPDATE_JW_INF CHANGING ZAEHLER_MCHB.
2188     EXEC SQL.
2189      UPDATE MCHB
2190         SET
2191              KZVCL         =  KZICL ,
2192              KZVCQ         =  KZICQ ,
2193              KZVCE         =  KZICE ,
2194              KZVCS         =  KZICS ,
2195              KZICL         =  :RESET_INV ,
2196              KZICQ         =  :RESET_INV ,
2197              KZICE         =  :RESET_INV ,
2198              KZICS         =  :RESET_INV ,
2199              CHJIN         =  :BUKRS_TAB-JAHR
2200        WHERE ( MANDT IS NOT NULL AND MANDT = :SY-MANDT )
2201        AND   CHJIN        <> :BUKRS_TAB-JAHR
2202        AND   WERKS IN ( SELECT WERKS FROM T001W WHERE BWKEY IN
2203              ( SELECT BWKEY FROM T001K WHERE BUKRS
2204              = :BUKRS_TAB-BUKRS ) )
2205     ENDEXEC.
2206     ZAEHLER_MCHB = ZAEHLER_MCHB + SY-DBCNT.                     "KUGL
2207   ENDFORM. "mchb_update_jw_inf
2208
2209
2210
2211   *------------------------------------------------------------------
2212   * Year change Update (Jahreswechsel) of table MCHB for ADABAS
2213   *                       DB2/6000 and MS SQL Server
2214   *------------------------------------------------------------------
2215   FORM MCHB_UPDATE_JW_NEUTRAL CHANGING ZAEHLER_MCHB.
2216   *For future use:
2217   *turn on special optimizer flag for DB2/6000 = 'DB6'
2218   *if sy-dbsys(3) = 'DB6'.
2219   * exec sql.
2220   *   set current query optimization 5
2221   * endexec.
2222   *endif.
2223
2224   *KUGL, 20.8.96:
2225   *           ADABAS, DB6 and MSSQL-Server code
2226   *           no tuning information was added at all (not necessary)
2227      EXEC SQL.
2228       UPDATE MCHB
2229          SET
2230               KZVCL         =  KZICL ,
2231               KZVCQ         =  KZICQ ,
2232               KZVCE         =  KZICE ,
2233               KZVCS         =  KZICS ,
2234               KZICL         =  :RESET_INV ,
2235               KZICQ         =  :RESET_INV ,
2236               KZICE         =  :RESET_INV ,
2237               KZICS         =  :RESET_INV ,
2238               CHJIN         =  :BUKRS_TAB-JAHR
2239         WHERE MANDT = :SY-MANDT
2240         AND   CHJIN        <> :BUKRS_TAB-JAHR
2241         AND   WERKS IN ( SELECT WERKS FROM T001W WHERE BWKEY IN
2242               ( SELECT BWKEY FROM T001K WHERE BUKRS
2243               = :BUKRS_TAB-BUKRS ) )
2244      ENDEXEC.
2245      ZAEHLER_MCHB = ZAEHLER_MCHB + SY-DBCNT.                     "KUGL
2246   *For future use:
2247   *reset special optimizer flag for DB2/6000 = 'DB6' back to 0
2248   *if sy-dbsys(3) = 'DB6'.
2249   * exec sql.
2250   *   set current query optimization 0
2251   * endexec.
2252   *endif.
2253   ENDFORM. "mchb_update_jw_neutral
2254
2255
2256
2257   *------------------------------------------------------------------
2258   * Year change Update (Jahreswechsel) of table MCHB for DB2/MVS and
2259   *                                                      DB2/400
2260   *------------------------------------------------------------------
2261   FORM MCHB_UPDATE_JW_DB2DB4 CHANGING ZAEHLER_MCHB.
2262   *KUGL, 20.8.96: Force full table scan by using trick with (0=1)condition
2263   * (no optimizer hint available) and use nested select instead of LOOP
2264     EXEC SQL.
2265      UPDATE MCHB
2266         SET
2267              KZVCL         =  KZICL ,
2268              KZVCQ         =  KZICQ ,
2269              KZVCE         =  KZICE ,
2270              KZVCS         =  KZICS ,
2271              KZICL         =  :RESET_INV ,
2272              KZICQ         =  :RESET_INV ,
2273              KZICE         =  :RESET_INV ,
2274              KZICS         =  :RESET_INV ,
2275              CHJIN         =  :BUKRS_TAB-JAHR
2276        WHERE ( MANDT = :SY-MANDT OR 0=1 )
2277        AND   CHJIN        <> :BUKRS_TAB-JAHR
2278        AND   WERKS IN ( SELECT WERKS FROM T001W WHERE BWKEY IN
2279              ( SELECT BWKEY FROM T001K WHERE BUKRS
2280              = :BUKRS_TAB-BUKRS ) )
2281     ENDEXEC.
2282     ZAEHLER_MCHB = ZAEHLER_MCHB + SY-DBCNT.                     "KUGL
2283   ENDFORM. "mchb_update_jw_db2db4
2284
2285
2286
2287   *------------------------------------------------------------------
2288   * Year change Update (Jahreswechsel) of table MSKA for ORACLE
2289   *------------------------------------------------------------------
2290   FORM MSKA_UPDATE_JW_ORA CHANGING ZAEHLER_MSKA.
2291   *KUGL, 20.8.96: Force full table scan by using optimizer hint and use
2292   *               nested selects instead of LOOPS
2293   *KUGL, 30.12.96:
2294   *If parallel query is required please look at sql modifications
2295   *of table MARD mska_update_jw_ora
2296
2297     EXEC SQL.
2298      UPDATE /*+ FULL(MSKA)      */
2299      MSKA
2300         SET
2301              KAVLL         =  KAILL ,
2302              KAILL         =  KAFLL ,
2303              KAVLQ         =  KAILQ ,
2304              KAILS         =  KAFLS ,
2305              KAVLS         =  KAILS ,
2306              KAILQ         =  KAFLQ ,
2307              KAFLL         =  :RESET_INV ,
2308              KAFLQ         =  :RESET_INV ,
2309              KAFLS         =  :RESET_INV ,
2310              KAJIN         =  :BUKRS_TAB-JAHR
2311        WHERE MANDT         =  :SY-MANDT
2312        AND   KAJIN        <> :BUKRS_TAB-JAHR
2313        AND   WERKS IN ( SELECT WERKS FROM T001W WHERE BWKEY IN
2314              ( SELECT BWKEY FROM T001K WHERE BUKRS
2315              = :BUKRS_TAB-BUKRS ) )
2316     ENDEXEC.
2317     ZAEHLER_MSKA = ZAEHLER_MSKA + SY-DBCNT.                     "KUGL
2318   ENDFORM. "mska_update_jw_ora
2319
2320   *------------------------------------------------------------------
2321   * Year change Update (Jahreswechsel) of table mska for INFORMIX
2322   *------------------------------------------------------------------
2323   *KUGL, 20.8.96: Force full table scan by using trick with IS NOT NULL
2324   * (no optimizer hint available for INFORMIX) and use nested select
2325   * instead of LOOP
2326   FORM MSKA_UPDATE_JW_INF CHANGING ZAEHLER_MSKA.
2327     EXEC SQL.
2328      UPDATE MSKA
2329         SET
2330              KAVLL         =  KAILL ,
2331              KAILL         =  KAFLL ,
2332              KAVLQ         =  KAILQ ,
2333              KAILS         =  KAFLS ,
2334              KAVLS         =  KAILS ,
2335              KAILQ         =  KAFLQ ,
2336              KAFLL         =  :RESET_INV ,
2337              KAFLQ         =  :RESET_INV ,
2338              KAFLS         =  :RESET_INV ,
2339              KAJIN         =  :BUKRS_TAB-JAHR
2340        WHERE ( MANDT IS NOT NULL AND MANDT = :SY-MANDT )
2341        AND   LFGJA        <> :BUKRS_TAB-JAHR
2342        AND   WERKS IN ( SELECT WERKS FROM T001W WHERE BWKEY IN
2343              ( SELECT BWKEY FROM T001K WHERE BUKRS
2344              = :BUKRS_TAB-BUKRS ) )
2345     ENDEXEC.
2346     ZAEHLER_MSKA = ZAEHLER_MSKA + SY-DBCNT.                     "KUGL
2347   ENDFORM. "mska_update_jw_inf
2348
2349   *------------------------------------------------------------------
2350   * Year change Update (Jahreswechsel) of table mska for ADABAS
2351   *                       DB2/6000 and MS SQL Server
2352   *------------------------------------------------------------------
2353   FORM MSKA_UPDATE_JW_NEUTRAL CHANGING ZAEHLER_MSKA.
2354   *For future use:
2355   *turn on special optimizer flag for DB2/6000 = 'DB6'
2356   *if sy-dbsys(3) = 'DB6'.
2357   * exec sql.
2358   *   set current query optimization 5
2359   * endexec.
2360   *endif.
2361
2362   *KUGL, 20.8.96:
2363   *           ADABAS, DB6 and MSSQL-Server code
2364   *           no tuning information was added at all (not necessary)
2365      EXEC SQL.
2366       UPDATE MSKA
2367          SET
2368              KAVLL         =  KAILL ,
2369              KAILL         =  KAFLL ,
2370              KAVLQ         =  KAILQ ,
2371              KAILS         =  KAFLS ,
2372              KAVLS         =  KAILS ,
2373              KAILQ         =  KAFLQ ,
2374              KAFLL         =  :RESET_INV ,
2375              KAFLQ         =  :RESET_INV ,
2376              KAFLS         =  :RESET_INV ,
2377              KAJIN         =  :BUKRS_TAB-JAHR
2378         WHERE MANDT = :SY-MANDT
2379         AND   KAJIN        <> :BUKRS_TAB-JAHR
2380         AND   WERKS IN ( SELECT WERKS FROM T001W WHERE BWKEY IN
2381               ( SELECT BWKEY FROM T001K WHERE BUKRS
2382               = :BUKRS_TAB-BUKRS ) )
2383      ENDEXEC.
2384      ZAEHLER_MSKA = ZAEHLER_MSKA + SY-DBCNT.                     "KUGL
2385   *For future use:
2386   *reset special optimizer flag for DB2/6000 = 'DB6' back to 0
2387   *if sy-dbsys(3) = 'DB6'.
2388   * exec sql.
2389   *   set current query optimization 0
2390   * endexec.
2391   *endif.
2392   ENDFORM. "mska_update_jw_neutral
2393
2394
2395
2396   *------------------------------------------------------------------
2397   * Year change Update (Jahreswechsel) of table mska for DB2/MVS and
2398   *                                                      DB2/400
2399   *------------------------------------------------------------------
2400   FORM MSKA_UPDATE_JW_DB2DB4 CHANGING ZAEHLER_MSKA.
2401   *KUGL, 20.8.96: Force full table scan by using trick with (0=1)condition
2402   * (no optimizer hint available) and use nested select instead of LOOP
2403     EXEC SQL.
2404      UPDATE MSKA
2405         SET
2406              KAVLL         =  KAILL ,
2407              KAILL         =  KAFLL ,
2408              KAVLQ         =  KAILQ ,
2409              KAILS         =  KAFLS ,
2410              KAVLS         =  KAILS ,
2411              KAILQ         =  KAFLQ ,
2412              KAFLL         =  :RESET_INV ,
2413              KAFLQ         =  :RESET_INV ,
2414              KAFLS         =  :RESET_INV ,
2415              KAJIN         =  :BUKRS_TAB-JAHR
2416        WHERE ( MANDT = :SY-MANDT OR 0=1 )
2417        AND   KAJIN        <> :BUKRS_TAB-JAHR
2418        AND   WERKS IN ( SELECT WERKS FROM T001W WHERE BWKEY IN
2419              ( SELECT BWKEY FROM T001K WHERE BUKRS
2420              = :BUKRS_TAB-BUKRS ) )
2421     ENDEXEC.
2422     ZAEHLER_MSKA = ZAEHLER_MSKA + SY-DBCNT.                     "KUGL
2423   ENDFORM. "mska_update_jw_db2db4
2424
2425
2426   *------------------------------------------------------------------
2427   * Year change Update (Jahreswechsel) of table msku for ORACLE
2428   *------------------------------------------------------------------
2429   FORM MSKU_UPDATE_JW_ORA CHANGING ZAEHLER_MSKU.
2430   *KUGL, 20.8.96: Force full table scan by using optimizer hint and use
2431   *               nested selects instead of LOOPS
2432   *KUGL, 30.12.96:
2433   *If parallel query is required please look at sql modifications
2434   *of table MARD msku_update_jw_ora
2435
2436     EXEC SQL.
2437      UPDATE /*+ FULL(MSKU)      */
2438      MSKU
2439         SET
2440              KUVLL         =  KUILL ,
2441              KUILL         =  KUFLL ,
2442              KUVLQ         =  KUILQ ,
2443              KUILQ         =  KUFLQ ,
2444              KUFLL         =  :RESET_INV ,
2445              KUFLQ         =  :RESET_INV ,
2446              KUJIN         =  :BUKRS_TAB-JAHR
2447        WHERE MANDT         =  :SY-MANDT
2448        AND   KUJIN        <> :BUKRS_TAB-JAHR
2449        AND   WERKS IN ( SELECT WERKS FROM T001W WHERE BWKEY IN
2450              ( SELECT BWKEY FROM T001K WHERE BUKRS
2451              = :BUKRS_TAB-BUKRS ) )
2452     ENDEXEC.
2453     ZAEHLER_MSKU = ZAEHLER_MSKU + SY-DBCNT.                     "KUGL
2454   ENDFORM. "msku_update_jw_ora
2455
2456   *------------------------------------------------------------------
2457   * Year change Update (Jahreswechsel) of table msku for INFORMIX
2458   *------------------------------------------------------------------
2459   *KUGL, 20.8.96: Force full table scan by using trick with IS NOT NULL
2460   * (no optimizer hint available for INFORMIX) and use nested select
2461   * instead of LOOP
2462   FORM MSKU_UPDATE_JW_INF CHANGING ZAEHLER_MSKU.
2463     EXEC SQL.
2464      UPDATE MSKU
2465         SET
2466              KUVLL         =  KUILL ,
2467              KUILL         =  KUFLL ,
2468              KUVLQ         =  KUILQ ,
2469              KUILQ         =  KUFLQ ,
2470              KUFLL         =  :RESET_INV ,
2471              KUFLQ         =  :RESET_INV ,
2472              KUJIN         =  :BUKRS_TAB-JAHR
2473        WHERE ( MANDT IS NOT NULL AND MANDT = :SY-MANDT )
2474        AND   KUJIN        <> :BUKRS_TAB-JAHR
2475        AND   WERKS IN ( SELECT WERKS FROM T001W WHERE BWKEY IN
2476              ( SELECT BWKEY FROM T001K WHERE BUKRS
2477              = :BUKRS_TAB-BUKRS ) )
2478     ENDEXEC.
2479     ZAEHLER_MSKU = ZAEHLER_MSKU + SY-DBCNT.                     "KUGL
2480   ENDFORM. "msku_update_jw_inf
2481
2482   *------------------------------------------------------------------
2483   * Year change Update (Jahreswechsel) of table msku for ADABAS
2484   *                       DB2/6000 and MS SQL Server
2485   *------------------------------------------------------------------
2486   FORM MSKU_UPDATE_JW_NEUTRAL CHANGING ZAEHLER_MSKU.
2487   *For future use:
2488   *turn on special optimizer flag for DB2/6000 = 'DB6'
2489   *if sy-dbsys(3) = 'DB6'.
2490   * exec sql.
2491   *   set current query optimization 5
2492   * endexec.
2493   *endif.
2494
2495   *KUGL, 20.8.96:
2496   *           ADABAS, DB6 and MSSQL-Server code
2497   *           no tuning information was added at all (not necessary)
2498      EXEC SQL.
2499       UPDATE MSKU
2500          SET
2501              KUVLL         =  KUILL ,
2502              KUILL         =  KUFLL ,
2503              KUVLQ         =  KUILQ ,
2504              KUILQ         =  KUFLQ ,
2505              KUFLL         =  :RESET_INV ,
2506              KUFLQ         =  :RESET_INV ,
2507              KUJIN         =  :BUKRS_TAB-JAHR
2508         WHERE MANDT = :SY-MANDT
2509         AND   KUJIN        <> :BUKRS_TAB-JAHR
2510         AND   WERKS IN ( SELECT WERKS FROM T001W WHERE BWKEY IN
2511               ( SELECT BWKEY FROM T001K WHERE BUKRS
2512               = :BUKRS_TAB-BUKRS ) )
2513      ENDEXEC.
2514      ZAEHLER_MSKU = ZAEHLER_MSKU + SY-DBCNT.                     "KUGL
2515   *For future use:
2516   *reset special optimizer flag for DB2/6000 = 'DB6' back to 0
2517   *if sy-dbsys(3) = 'DB6'.
2518   * exec sql.
2519   *   set current query optimization 0
2520   * endexec.
2521   *endif.
2522   ENDFORM. "msku_update_jw_neutral
2523
2524   *------------------------------------------------------------------
2525   * Year change Update (Jahreswechsel) of table msku for DB2/MVS and
2526   *                                                      DB2/400
2527   *------------------------------------------------------------------
2528   FORM MSKU_UPDATE_JW_DB2DB4 CHANGING ZAEHLER_MSKU.
2529   *KUGL, 20.8.96: Force full table scan by using trick with (0=1)condition
2530   * (no optimizer hint available) and use nested select instead of LOOP
2531     EXEC SQL.
2532      UPDATE MSKU
2533         SET
2534              KUVLL         =  KUILL ,
2535              KUILL         =  KUFLL ,
2536              KUVLQ         =  KUILQ ,
2537              KUILQ         =  KUFLQ ,
2538              KUFLL         =  :RESET_INV ,
2539              KUFLQ         =  :RESET_INV ,
2540              KUJIN         =  :BUKRS_TAB-JAHR
2541        WHERE ( MANDT = :SY-MANDT OR 0=1 )
2542        AND   KUJIN        <> :BUKRS_TAB-JAHR
2543        AND   WERKS IN ( SELECT WERKS FROM T001W WHERE BWKEY IN
2544              ( SELECT BWKEY FROM T001K WHERE BUKRS
2545              = :BUKRS_TAB-BUKRS ) )
2546     ENDEXEC.
2547     ZAEHLER_MSKU = ZAEHLER_MSKU + SY-DBCNT.                     "KUGL
2548   ENDFORM. "msku_update_jw_db2db4
*--- End of MM13QFSQ - 2548 lines ---

----------------------------------------------------------------------------------------------------
Include          MM13QF40                                  Level 1    Page 7
Object           Z_DEL_HIST_ENTRIES                        Lines 442
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:32
----------------------------------------------------------------------------------------------------
1
2      *------------------------------------------------------------------
3      *           Update der Tabelle ebew bei Initialisierung
4      *------------------------------------------------------------------
5      FORM EBEW_UPDATE_INI.
6
7       UPDATE EBEW
8          SET
9               LFGJA         =  BUKRS_TAB-JAHR
10              LFMON         =  BUKRS_TAB-MONAT
11        WHERE BWKEY         IN IN_BWKEY
12          AND ( LFGJA > BUKRS_TAB-JAHR
13              OR (   LFGJA = BUKRS_TAB-JAHR
14                 AND LFMON > BUKRS_TAB-MONAT ) ).
15
16        ZAEHLER_EBEW = ZAEHLER_EBEW + SY-DBCNT.
17     * Nach Absprache mit der Bestandsführung sollen bei der Initialisierung
18     * keine Historiensätze mehr gelöscht werden
19     *   DELETE FROM EBEWH
20     *          WHERE BWKEY IN IN_BWKEY
21     *          AND ( LFGJA > BUKRS_TAB-JAHR
22     *              OR (   LFGJA = BUKRS_TAB-JAHR
23     *                 AND LFMON >= BUKRS_TAB-MONAT ) ).
24
25     ENDFORM.
26
27     *------------------------------------------------------------------
28     *           Lesen der Tabelle ebew zur Ermittlung der Schiefstände
29     *
30     * Ab 3.0 wird hier auch geprüft, ob kein ebew-Satz mit negativem
31     * Vorperiodenbestand existiert.
32     *
33     * Ab 4.0C nur noch Prüfung negativer Werte zur Vorperiode
34     *------------------------------------------------------------------
35     FORM EBEW_SCHIEF.
36
37     * Da nur noch auf negative Mengen geprüft wird, wird hier erst mal
38     * das entsprechende Kennzeichen abgefragt          "ch/4.6
39     CHECK RM03Q-XNEGQ NE SPACE AND RM03Q-XNEGV EQ SPACE.
40     check ( NOT NB_BWKEY[] IS INITIAL ).               "
41
42     *KUGL, 5.11.95: Remove client to fool optimizer. Then only get
43     *actual client                                        ch zu 3.0C
44     *This tuning might hurt if customer has more than one client with many
45     *many materials
46
47     IF SWITCH_ON_TUNE = 'X'.
48      SELECT * INTO EBEWH
49         FROM EBEWH CLIENT SPECIFIED
50     *  WHERE BWKEY        IN IN_BWKEY
51        WHERE BWKEY        IN NB_BWKEY             "ch/4.6a
52        AND   LFGJA        =  BUKRS_TAB-VMGJA
53        AND   LFMON        =  BUKRS_TAB-VMMON
54        AND (  ( SALK3 < 0 )
55            OR ( VKSAL < 0 ) ).
56         IF SY-MANDT = EBEWH-MANDT.
57          PERFORM EBEW_SCHIEF_AUSN.
58         ENDIF.
59      ENDSELECT.
60     ELSE.
61      SELECT * INTO EBEWH
62         FROM EBEWH
63     *  WHERE BWKEY        IN IN_BWKEY
64        WHERE BWKEY        IN NB_BWKEY             "ch/4.6a
65        AND   LFGJA        =  BUKRS_TAB-VMGJA
66        AND   LFMON        =  BUKRS_TAB-VMMON
67        AND (  ( SALK3 < 0 )
68            OR ( VKSAL < 0 ) ).
69          PERFORM EBEW_SCHIEF_AUSN.
70      ENDSELECT.
71     ENDIF.
72
73     * CH/H:217577 Die Originaltabelle muß auch berücksichtigt werden
74     IF BUKRS_TAB-MON_40C IS INITIAL.      "d.h. 1. PeriWechsel nach Upgrade
75       SELECT EBEW~MATNR EBEW~BWKEY EBEW~BWTAR
76              EBEW~SOBKZ EBEW~VBELN EBEW~POSNR
77              EBEW~VMSAL EBEWH~MATNR
78           INTO (EBEW-MATNR, EBEW-BWKEY, EBEW-BWTAR,
79                 EBEW-SOBKZ, EBEW-VBELN, EBEW-POSNR,
80                 EBEW-VMSAL, EBEWH-MATNR)
81           FROM EBEW LEFT OUTER JOIN EBEWH
82           ON    EBEW~MATNR  = EBEWH~MATNR
83             AND EBEW~BWKEY  = EBEWH~BWKEY
84             AND EBEW~BWTAR  = EBEWH~BWTAR
85             AND EBEW~SOBKZ  = EBEWH~SOBKZ
86             AND EBEW~VBELN  = EBEWH~VBELN
87             AND EBEW~POSNR  = EBEWH~POSNR
88             AND EBEWH~LFGJA  = BUKRS_TAB-VMGJA
89             AND EBEWH~LFMON  = BUKRS_TAB-VMMON
90           WHERE EBEW~BWKEY   IN NB_BWKEY
91             AND EBEW~VMSAL   <  0  .
92         IF EBEWH-MATNR IS INITIAL.       "d.h. kein MxxxH-Satz vorhanden
93           MOVE-CORRESPONDING EBEW TO EBEWH.
94           PERFORM EBEW_SCHIEF_AUSN.
95         ENDIF.
96       ENDSELECT.
97     ELSE.
98       IF SWITCH_ON_TUNE = 'X'.
99        SELECT * INTO EBEW
100          FROM EBEW CLIENT SPECIFIED
101         WHERE BWKEY        IN NB_BWKEY
102         AND (  LFGJA < BUKRS_TAB-LFGJA
103             OR LFMON < BUKRS_TAB-LFMON )
104         AND (  SALK3 < 0
105             OR VKSAL < 0 ).
106          IF SY-MANDT = EBEW-MANDT.
107            MOVE-CORRESPONDING EBEW TO EBEWH.
108            PERFORM EBEW_SCHIEF_AUSN.
109          ENDIF.
110       ENDSELECT.
111      ELSE.
112       SELECT * INTO EBEW
113          FROM EBEW
114         WHERE BWKEY        IN NB_BWKEY
115         AND (  LFGJA <  BUKRS_TAB-LFGJA
116             OR LFMON <  BUKRS_TAB-LFMON )
117         AND (  SALK3 < 0
118             OR VKSAL < 0 ).
119           MOVE-CORRESPONDING EBEW TO EBEWH.
120           PERFORM EBEW_SCHIEF_AUSN.
121       ENDSELECT.
122      ENDIF.
123    ENDIF.
124
125    ENDFORM.
126
127    *------------------------------------------------------------------
128    *    FORM ebew_SCHIEF_AUSN.
129    * Füllen der Ausnahmetabelle, weil ein Schiefstand vorliegt.
130    *
131    * Ab 4.0C nur noch Prüfung negativer Werte zur Vorperiode
132    *------------------------------------------------------------------
133    FORM EBEW_SCHIEF_AUSN.
134    * -- Prüfung für den Fall, daß zwar negative
135    *    Mengen aber keine negativen Werte erlaubt sind, wieder aktiviert
136         IF RM03Q-XNEGQ NE SPACE AND RM03Q-XNEGV EQ SPACE.
137           IF  ( NOT NB_BWKEY[] IS INITIAL ).    "ch zu 3.0d  /23.02.96
138             IF EBEWH-BWKEY IN NB_BWKEY.
139               CLEAR AUSNAHME_NEG.
140               MOVE '12'            TO AUSNAHME_NEG-SAART.
141                  "ebews mit negativem Vorperiodenbestand existieren
142               MOVE BUKRS_TAB-BUKRS TO AUSNAHME_NEG-BUKRS.
143               MOVE EBEWH-MATNR      TO AUSNAHME_NEG-MATNR.
144               MOVE EBEWH-BWKEY      TO AUSNAHME_NEG-BWKEY.
145               MOVE EBEWH-BWTAR      TO AUSNAHME_NEG-BWTAR.
146               MOVE EBEWH-VBELN      TO AUSNAHME_NEG-VBELN.
147               MOVE EBEWH-POSNR      TO AUSNAHME_NEG-POSNR.
148               APPEND AUSNAHME_NEG.
149             ENDIF.
150           ENDIF.
151         ENDIF.
152
153    *    IF  ( EBEW-LFGJA        NE BUKRS_TAB-VORJAHR
154    *    OR  ( EBEW-LFGJA        =  BUKRS_TAB-VORJAHR  AND
155    *          EBEW-LFMON        NE BUKRS_TAB-VORMONAT ) ).
156    *      CLEAR AUSNAHME_SATZ.
157    *      MOVE '62'            TO AUSNAHME_SATZ-AUSNA.
158    *           "Nicht alle Bewertungssätze konnten umgesetzt werden
159    *      MOVE BUKRS_TAB-BUKRS TO AUSNAHME_SATZ-BUKRS.
160    *      MOVE EBEW-MATNR      TO AUSNAHME_SATZ-MATNR.
161    *      MOVE EBEW-BWKEY      TO AUSNAHME_SATZ-BWKEY.
162    *      MOVE EBEW-BWTAR      TO AUSNAHME_SATZ-BWTAR.
163    *      MOVE EBEW-VBELN      TO AUSNAHME_SATZ-VBELN.
164    *      MOVE EBEW-POSNR      TO AUSNAHME_SATZ-POSNR.
165    *      APPEND AUSNAHME_SATZ.
166    *      ADD 1 TO ZAEHLER_EBEW_SCHIEF.
167    *    ENDIF.
168    ENDFORM.
169
170
171
172    *------------------------------------------------------------------
173    *           Update der Tabelle qbew bei Initialisierung
174    *------------------------------------------------------------------
175    FORM QBEW_UPDATE_INI.
176
177     UPDATE QBEW
178        SET
179             LFGJA         =  BUKRS_TAB-JAHR
180             LFMON         =  BUKRS_TAB-MONAT
181       WHERE BWKEY         IN IN_BWKEY
182         AND ( LFGJA > BUKRS_TAB-JAHR
183             OR (   LFGJA = BUKRS_TAB-JAHR
184                AND LFMON > BUKRS_TAB-MONAT ) ).   "#EC CI_NOFIRST
185
186       ZAEHLER_QBEW = ZAEHLER_QBEW + SY-DBCNT.
187
188    * Nach Absprache mit der Bestandsführung sollen bei der Initialisierung
189    * keine Historiensätze mehr gelöscht werden
190    *   DELETE FROM QBEWH
191    *          WHERE BWKEY IN IN_BWKEY
192    *          AND ( LFGJA > BUKRS_TAB-JAHR
193    *              OR (   LFGJA = BUKRS_TAB-JAHR
194    *                 AND LFMON >= BUKRS_TAB-MONAT ) ).
195
196    ENDFORM.
197
198    *------------------------------------------------------------------
199    *           Lesen der Tabelle qbew zur Ermittlung der Schiefstände
200    *
201    * Ab 3.0 wird hier auch geprüft, ob kein qbew-Satz mit negativem
202    * Vorperiodenbestand existiert.
203    *
204    * Ab 4.0C nur noch Prüfung negativer Werte zur Vorperiode
205    *------------------------------------------------------------------
206    FORM QBEW_SCHIEF.
207
208    * Da nur noch auf negative Mengen geprüft wird, wird hier erst mal
209    * das entsprechende Kennzeichen abgefragt          "ch/4.6
210    CHECK RM03Q-XNEGQ NE SPACE AND RM03Q-XNEGV EQ SPACE.
211    check ( NOT NB_BWKEY[] IS INITIAL ).               "
212
213    *KUGL, 5.11.95: Remove client to fool optimizer. Then only get
214    *actual client                                        ch zu 3.0C
215    *This tuning might hurt if customer has more than one client with many
216    *many materials
217
218    IF SWITCH_ON_TUNE = 'X'.
219     SELECT * INTO QBEWH
220        FROM QBEWH CLIENT SPECIFIED
221    *  WHERE BWKEY        IN IN_BWKEY
222       WHERE BWKEY        IN NB_BWKEY             "ch/4.6a
223       AND   LFGJA        =  BUKRS_TAB-VMGJA
224       AND   LFMON        =  BUKRS_TAB-VMMON
225       AND (  ( SALK3 < 0 )
226           OR ( VKSAL < 0 ) ).
227        IF SY-MANDT = QBEWH-MANDT.
228         PERFORM QBEW_SCHIEF_AUSN.
229        ENDIF.
230     ENDSELECT.
231    ELSE.
232     SELECT * INTO QBEWH
233        FROM QBEWH
234    *  WHERE BWKEY        IN IN_BWKEY
235       WHERE BWKEY        IN NB_BWKEY             "ch/4.6a
236       AND   LFGJA        =  BUKRS_TAB-VMGJA
237       AND   LFMON        =  BUKRS_TAB-VMMON
238       AND (  ( SALK3 < 0 )
239           OR ( VKSAL < 0 ) ).
240         PERFORM QBEW_SCHIEF_AUSN.
241     ENDSELECT.
242    ENDIF.
243
244    * CH/H:217577 Die Originaltabelle muß auch berücksichtigt werden
245    IF BUKRS_TAB-MON_40C IS INITIAL.      "d.h. 1. PeriWechsel nach Upgrade
246      SELECT QBEW~MATNR QBEW~BWKEY QBEW~BWTAR
247             QBEW~SOBKZ QBEW~PSPNR
248             QBEW~VMSAL QBEWH~MATNR
249          INTO (QBEW-MATNR, QBEW-BWKEY, QBEW-BWTAR,
250                QBEW-SOBKZ, QBEW-PSPNR,
251                QBEW-VMSAL, QBEWH-MATNR)
252          FROM QBEW LEFT OUTER JOIN QBEWH
253          ON    QBEW~MATNR  = QBEWH~MATNR
254            AND QBEW~BWKEY  = QBEWH~BWKEY
255            AND QBEW~BWTAR  = QBEWH~BWTAR
256            AND QBEW~SOBKZ  = QBEWH~SOBKZ
257            AND QBEW~PSPNR  = QBEWH~PSPNR
258            AND QBEWH~LFGJA  = BUKRS_TAB-VMGJA
259            AND QBEWH~LFMON  = BUKRS_TAB-VMMON
260          WHERE QBEW~BWKEY   IN NB_BWKEY
261            AND QBEW~VMSAL   <  0  .
262        IF QBEWH-MATNR IS INITIAL.       "d.h. kein MxxxH-Satz vorhanden
263          MOVE-CORRESPONDING QBEW TO QBEWH.
264          PERFORM QBEW_SCHIEF_AUSN.
265        ENDIF.
266      ENDSELECT.
267    ELSE.
268      IF SWITCH_ON_TUNE = 'X'.
269       SELECT * INTO QBEW
270          FROM QBEW CLIENT SPECIFIED
271         WHERE BWKEY        IN NB_BWKEY
272         AND (  LFGJA < BUKRS_TAB-LFGJA
273             OR LFMON < BUKRS_TAB-LFMON )
274         AND (  SALK3 < 0
275             OR VKSAL < 0 ).             "#EC CI_NOFIRST
276          IF SY-MANDT = QBEW-MANDT.
277            MOVE-CORRESPONDING QBEW TO QBEWH.
278            PERFORM QBEW_SCHIEF_AUSN.
279          ENDIF.
280       ENDSELECT.
281      ELSE.
282       SELECT * INTO QBEW
283          FROM QBEW
284         WHERE BWKEY        IN NB_BWKEY
285         AND (  LFGJA <  BUKRS_TAB-LFGJA
286             OR LFMON <  BUKRS_TAB-LFMON )
287         AND (  SALK3 < 0
288             OR VKSAL < 0 ).             "#EC CI_NOFIRST
289           MOVE-CORRESPONDING QBEW TO QBEWH.
290           PERFORM QBEW_SCHIEF_AUSN.
291       ENDSELECT.
292      ENDIF.
293    ENDIF.
294
295    ENDFORM.
296
297    *------------------------------------------------------------------
298    *    FORM qbew_SCHIEF_AUSN.
299    * Füllen der Ausnahmetabelle, weil ein Schiefstand vorliegt.
300    *
301    * Ab 4.0C nur noch Prüfung negativer Werte zur Vorperiode
302    *------------------------------------------------------------------
303    FORM QBEW_SCHIEF_AUSN.
304    * -- Prüfung für den Fall, daß zwar negative
305    *    Mengen aber keine negativen Werte erlaubt sind, wieder aktiviert
306         IF RM03Q-XNEGQ NE SPACE AND RM03Q-XNEGV EQ SPACE.
307           IF  ( NOT NB_BWKEY[] IS INITIAL ).    "ch zu 3.0d  /23.02.96
308             IF QBEWH-BWKEY IN NB_BWKEY.
309               CLEAR AUSNAHME_NEG.
310               MOVE '13'            TO AUSNAHME_NEG-SAART.
311                  "qbews mit negativem Vorperiodenbestand existieren
312               MOVE BUKRS_TAB-BUKRS TO AUSNAHME_NEG-BUKRS.
313               MOVE QBEWH-MATNR      TO AUSNAHME_NEG-MATNR.
314               MOVE QBEWH-BWKEY      TO AUSNAHME_NEG-BWKEY.
315               MOVE QBEWH-BWTAR      TO AUSNAHME_NEG-BWTAR.
316               MOVE QBEWH-PSPNR      TO AUSNAHME_NEG-PSPNR.
317               APPEND AUSNAHME_NEG.
318             ENDIF.
319           ENDIF.
320         ENDIF.
321
322    *    IF  ( QBEW-LFGJA        NE BUKRS_TAB-VORJAHR
323    *    OR  ( QBEW-LFGJA        =  BUKRS_TAB-VORJAHR  AND
324    *          QBEW-LFMON        NE BUKRS_TAB-VORMONAT ) ).
325    *      CLEAR AUSNAHME_SATZ.
326    *      MOVE '65'            TO AUSNAHME_SATZ-AUSNA.
327    *           "Nicht alle Bewertungssätze konnten umgesetzt werden
328    *      MOVE BUKRS_TAB-BUKRS TO AUSNAHME_SATZ-BUKRS.
329    *      MOVE QBEW-MATNR      TO AUSNAHME_SATZ-MATNR.
330    *      MOVE QBEW-BWKEY      TO AUSNAHME_SATZ-BWKEY.
331    *      MOVE QBEW-BWTAR      TO AUSNAHME_SATZ-BWTAR.
332    *      MOVE QBEW-PSPNR      TO AUSNAHME_SATZ-PSPNR.
333    *      APPEND AUSNAHME_SATZ.
334    *      ADD 1 TO ZAEHLER_QBEW_SCHIEF.
335    *    ENDIF.
336    ENDFORM.
337
338    *------------------------------------------------------------------
339    *           Update der Tabelle obew bei Initialisierung
340    *------------------------------------------------------------------
341    FORM OBEW_UPDATE_INI.                                "ch/4.6A (wg. OBEW)
342
343     UPDATE OBEW
344        SET
345             LFGJA         =  BUKRS_TAB-JAHR
346             LFMON         =  BUKRS_TAB-MONAT
347       WHERE BWKEY         IN IN_BWKEY
348         AND ( LFGJA > BUKRS_TAB-JAHR
349             OR (   LFGJA = BUKRS_TAB-JAHR
350                AND LFMON > BUKRS_TAB-MONAT ) ).
351
352       ZAEHLER_OBEW = ZAEHLER_OBEW + SY-DBCNT.
353
354    * Nach Absprache mit der Bestandsführung sollen bei der Initialisierung
355    * keine Historiensätze mehr gelöscht werden
356    *   DELETE FROM OBEWH
357    *          WHERE BWKEY IN IN_BWKEY
358    *          AND ( LFGJA > BUKRS_TAB-JAHR
359    *              OR (   LFGJA = BUKRS_TAB-JAHR
360    *                 AND LFMON >= BUKRS_TAB-MONAT ) ).
361
362    ENDFORM.                                             "ch/4.6A (wg. OBEW)
363
364    *------------------------------------------------------------------
365    *    FORM OBEW_SCHIEF
366    *------------------------------------------------------------------
367    FORM OBEW_SCHIEF.                                    "ch/4.6A (wg. OBEW)
368
369    * Da nur noch auf negative Mengen geprüft wird, wird hier erst mal
370    * das entsprechende Kennzeichen abgefragt          "ch/4.6
371    CHECK RM03Q-XNEGQ NE SPACE AND RM03Q-XNEGV EQ SPACE.
372    check ( NOT NB_BWKEY[] IS INITIAL ).               "
373
374    IF SWITCH_ON_TUNE = 'X'.
375     SELECT * INTO OBEWH
376        FROM OBEWH CLIENT SPECIFIED
377    *  WHERE BWKEY        IN IN_BWKEY
378       WHERE BWKEY        IN NB_BWKEY             "ch/4.6a
379       AND   LFGJA        =  BUKRS_TAB-VMGJA
380       AND   LFMON        =  BUKRS_TAB-VMMON
381       AND (  ( SALK3 < 0 )
382           OR ( VKSAL < 0 ) ).
383        IF SY-MANDT = OBEWH-MANDT.
384         PERFORM OBEW_SCHIEF_AUSN.
385        ENDIF.
386     ENDSELECT.
387    ELSE.
388     SELECT * INTO OBEWH
389        FROM OBEWH
390    *  WHERE BWKEY        IN IN_BWKEY
391       WHERE BWKEY        IN NB_BWKEY             "ch/4.6a
392       AND   LFGJA        =  BUKRS_TAB-VMGJA
393       AND   LFMON        =  BUKRS_TAB-VMMON
394       AND (  ( SALK3 < 0 )
395           OR ( VKSAL < 0 ) ).
396         PERFORM OBEW_SCHIEF_AUSN.
397     ENDSELECT.
398    ENDIF.
399
400    ENDFORM.                                             "ch/4.6A (wg. OBEW)
401
402    *------------------------------------------------------------------
403    *    FORM OBEW_SCHIEF_AUSN
404    *------------------------------------------------------------------
405    FORM OBEW_SCHIEF_AUSN.                               "ch/4.6A (wg. OBEW)
406    * -- Pr#fung f#r den Fall, da# zwar negative
407    *    Mengen aber keine negativen Werte erlaubt sind, wieder aktiviert
408         IF RM03Q-XNEGQ NE SPACE AND RM03Q-XNEGV EQ SPACE.
409           IF  ( NOT NB_BWKEY[] IS INITIAL ).
410             IF OBEWH-BWKEY IN NB_BWKEY.
411               CLEAR AUSNAHME_NEG.
412               MOVE '15'            TO AUSNAHME_NEG-SAART.
413                  "obews mit negativem Vorperiodenbestand existieren
414               MOVE BUKRS_TAB-BUKRS TO AUSNAHME_NEG-BUKRS.
415               MOVE OBEWH-MATNR      TO AUSNAHME_NEG-MATNR.
416               MOVE OBEWH-BWKEY      TO AUSNAHME_NEG-BWKEY.
417               MOVE OBEWH-BWTAR      TO AUSNAHME_NEG-BWTAR.
418               MOVE OBEWH-LIFNR      TO AUSNAHME_NEG-LIFNR.
419               APPEND AUSNAHME_NEG.
420             ENDIF.
421           ENDIF.
422         ENDIF.
423
424    ENDFORM.                                             "ch/4.6A (wg. OBEW)
425
426    *------------------------------------------------------------------
427    *           Update der Tabelle wbew bei Initialisierung
428    *------------------------------------------------------------------
429    FORM WBEW_UPDATE_INI.
430
431     UPDATE WBEW
432        SET
433             LFGJA         =  BUKRS_TAB-JAHR
434             LFMON         =  BUKRS_TAB-MONAT
435       WHERE BWKEY         IN IN_BWKEY
436         AND ( LFGJA > BUKRS_TAB-JAHR
437             OR (   LFGJA = BUKRS_TAB-JAHR
438                AND LFMON > BUKRS_TAB-MONAT ) ).
439
440       ZAEHLER_WBEW = ZAEHLER_WBEW + SY-DBCNT.
441
442    ENDFORM.
*--- End of MM13QF40 - 442 lines ---

----------------------------------------------------------------------------------------------------
Include          MM13QF50                                  Level 1    Page 8
Object           Z_DEL_HIST_ENTRIES                        Lines 1955
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:32
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&  Include           MM13QF50
3      *&---------------------------------------------------------------------*
4      *&---------------------------------------------------------------------*
5      *&      Form  INITIALIZE_ALV_OUTPUT
6      *&---------------------------------------------------------------------*
7      *       text
8      *----------------------------------------------------------------------*
9      *  -->  p1        text
10     *  <--  p2        text
11     *----------------------------------------------------------------------*
12     FORM INITIALIZE_ALV_OUTPUT .
13     data: ls_fieldcat type slis_fieldcat_alv.
14     field-symbols: <ls_fieldcat> type SLIS_FIELDCAT_ALV.
15     field-symbols: <LS_EVENT> TYPE SLIS_ALV_EVENT.
16
17       move syst-repid to gv_repid.
18
19     ********
20     * "SBAL"
21     ********
22
23     * Rebuild layout of 'SBAL'
24       CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
25         EXPORTING
26           I_STRUCTURE_NAME       = GC_SBAL_FIELDS
27         CHANGING
28           CT_FIELDCAT            = GT_FIELDCAT_SBAL
29         EXCEPTIONS
30           INCONSISTENT_INTERFACE = 1
31           PROGRAM_ERROR          = 2
32           OTHERS                 = 3.
33       IF SY-SUBRC <> 0.
34         MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
35                 WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
36       ENDIF.
37
38     ** Customise Field Catalog.
39       LOOP AT GT_FIELDCAT_SBAL assigning <LS_FIELDCAT>.
40         CASE <LS_FIELDCAT>-FIELDNAME.
41            WHEN 'MSGTEXT'.
42                 <ls_fieldcat>-reptext_ddic = text-001.
43     *      WHEN OTHERS.
44     *        <LS_FIELDCAT>-TECH = GC_YES.
45         ENDCASE.
46       ENDLOOP.
47
48     * layout for ALV:  "to be identified dynamically!
49       GS_LAYOUT_SBAL-LIST_APPEND = 'Y'. "note 1267052
50
51     * ALV events table
52
53     * Get ALV events
54       CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
55         EXPORTING
56           I_LIST_TYPE = 0
57         IMPORTING
58           ET_EVENTS   = GT_EVENTTAB_SBAL.
59     ***************
60     * Append-tables
61     ***************
62     *AUSNAHME_SATZ
63       CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
64         EXPORTING
65           I_STRUCTURE_NAME       = GC_AUSNAHME_SATZ
66         CHANGING
67           CT_FIELDCAT            = GT_FIELDCAT_A_SATZ
68         EXCEPTIONS
69           INCONSISTENT_INTERFACE = 1
70           PROGRAM_ERROR          = 2
71           OTHERS                 = 3.
72       IF SY-SUBRC <> 0.
73         MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
74                 WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
75       ENDIF.
76     *BWKEY_ML_ERROR
77       CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
78         EXPORTING
79           I_STRUCTURE_NAME       = GC_BWKEY_ML_ERROR
80         CHANGING
81           CT_FIELDCAT            = GT_FIELDCAT_BWKEY_ML_ERR
82         EXCEPTIONS
83           INCONSISTENT_INTERFACE = 1
84           PROGRAM_ERROR          = 2
85           OTHERS                 = 3.
86       IF SY-SUBRC <> 0.
87         MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
88                 WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
89       ENDIF.
90
91     *AUSNAHME_NEG
92       CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
93         EXPORTING
94           I_STRUCTURE_NAME       = GC_AUSNAHME_NEG
95         CHANGING
96           CT_FIELDCAT            = gt_fieldcat_ausnahme_neg
97         EXCEPTIONS
98           INCONSISTENT_INTERFACE = 1
99           PROGRAM_ERROR          = 2
100          OTHERS                 = 3.
101      IF SY-SUBRC <> 0.
102        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
103                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
104      ENDIF.
105      gt_eventtab_appends[] = gt_eventtab_sbal[].
106    * END_OF_LIST
107      READ TABLE GT_EVENTTAB_appends
108        WITH KEY NAME = SLIS_EV_END_OF_LIST assigning <LS_EVENT>.
109
110    *  IF SY-SUBRC = 0.
111    *    MOVE 'LOOP_AT_DATA' TO <LS_EVENT>-FORM.
112    *  ENDIF.
113
114    ENDFORM.                    " INITIALIZE_ALV_OUTPUT
115
116
117    *&---------------------------------------------------------------------*
118    *&      Form  skip
119    *&---------------------------------------------------------------------*
120    *       text
121    *----------------------------------------------------------------------*
122    *      <--P  text
123    *----------------------------------------------------------------------*
124    FORM skip.
125      data: l_log like line of gt_log.
126      clear l_log.
127      append l_log to gt_log.
128      "note 2186338
129      PERFORM message_store
130        USING 'MM' 'I' '899' ' ' ' ' ' ' ' '.
131    ENDFORM.                    " skip
132    *&---------------------------------------------------------------------*
133    *&      Form  display_alv
134    *&---------------------------------------------------------------------*
135    *       text
136    *----------------------------------------------------------------------*
137    *  -->  p1        text
138    *  <--  p2        text
139    *----------------------------------------------------------------------*
140    FORM display_alv .
141    *DISPLAY ALV LIST.
142      field-symbols: <fs> like line of gtt_log.
143      data: ltt_log like line of gtt_log.
144    *  data: lt_eventtab_sbal like gt_eventtab_sbal.
145
146      ltt_log-t[] = gt_log[].
147      append ltt_log to gtt_log.
148      read table gtt_log index syst-tabix assigning <fs>.
149      clear: gt_log[].
150    *  lt_eventtab_sbal[] = gt_eventtab_sbal[].
151      CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
152        EXPORTING
153          I_CALLBACK_PROGRAM = GV_REPID
154          IS_LAYOUT          = GS_LAYOUT_sbal
155          IT_FIELDCAT        = GT_FIELDCAT_SBAL
156          I_SAVE             = GC_SAVE
157          IT_EVENTS          = GT_EVENTTAB_SBAL
158        TABLES
159          T_OUTTAB           = <fs>-t
160        EXCEPTIONS
161          PROGRAM_ERROR      = 1
162          OTHERS             = 2.
163
164      IF SY-SUBRC <> 0.
165         MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
166              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
167      ENDIF.
168
169      GS_LAYOUT_SBAL-LIST_APPEND = 'X'. "note 1267052
170
171    ENDFORM.                    " display_alv
172    *&---------------------------------------------------------------------*
173    *&      Form  ausna_07
174    *&---------------------------------------------------------------------*
175    *       text
176    *----------------------------------------------------------------------*
177    *  -->  p1        text
178    *  <--  p2        text
179    *----------------------------------------------------------------------*
180    FORM ausna_07 . "#EC CALLED
181      field-symbols: <fc> like line of gt_fieldcat_a_satz.
182    *  data: lt_eventtab_appends like gt_eventtab_appends.
183    *DISPLAY ALV GRID.
184      loop at gt_fieldcat_a_satz assigning <fc>.
185        case <fc>-fieldname.
186             when 'BUKRS' or
187                  'MATNR' or
188                  'BWKEY' or
189                  'BWTAR' or
190                  'WERKS' or
191                  'LGORT' or
192                  'CHARG' or
193                  'LIFNR' or
194                  'KUNNR' or
195                  'VELLN' or
196                  'POSNR'.
197                  <fc>-no_out = space.
198             when others.
199                  <fc>-no_out = 'X'.
200          endcase.
201      endloop.
202      perform change_event using space.
203      perform change_event_top_of_page using 'AUSNA_07_TOP'.
204      GS_LAYOUT_SBAL-LIST_APPEND = 'X'. "note 1267052
205      clear: gt_log[].
206      CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
207        EXPORTING
208          I_CALLBACK_PROGRAM = GV_REPID
209          IS_LAYOUT          = GS_LAYOUT_sbal
210          IT_FIELDCAT        = GT_FIELDCAT_a_satz
211          I_SAVE             = GC_SAVE      "'A'
212          IT_EVENTS          = GT_EVENTTAB_appends
213        TABLES
214          T_OUTTAB           = ausnahme_satz
215        EXCEPTIONS
216          PROGRAM_ERROR      = 1
217          OTHERS             = 2.
218
219      IF SY-SUBRC <> 0.
220         MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
221                 WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
222        ENDIF.
223
224    *      WRITE TEXT-004.
225    * first table; to be done....
226    *      SKIP.
227    *      WRITE TEXT-005.
228    *      WRITE / TEXT-013.
229    *      LOOP AT AUSNAHME_SATZ.
230    *       WRITE: /4 AUSNAHME_SATZ-BUKRS,
231    *                 AUSNAHME_SATZ-MATNR , AUSNAHME_SATZ-BWKEY,
232    *                 AUSNAHME_SATZ-BWTAR , AUSNAHME_SATZ-WERKS,
233    *                 AUSNAHME_SATZ-LGORT , AUSNAHME_SATZ-CHARG.
234    *       WRITE: /4 AUSNAHME_SATZ-LIFNR , AUSNAHME_SATZ-KUNNR,
235    *                 AUSNAHME_SATZ-VBELN , AUSNAHME_SATZ-POSNR.
236    *                "AUSNAHME_SATZ-ETENR.
237    *      ENDLOOP.
238    ENDFORM.                    " ausna_07
239    *&---------------------------------------------------------------------*
240    *&      Form  ausna_07_top
241    *&---------------------------------------------------------------------*
242    *       text
243    *----------------------------------------------------------------------*
244    *      -->   text
245    *----------------------------------------------------------------------*
246    FORM ausna_07_top. "#EC CALLED
247    data: lt_commentary type SLIS_T_LISTHEADER,
248          l_KEY TYPE SLIS_LISTHEADER-KEY,       "Commentary key
249          L_TDLINE TYPE TLINE-TDLINE.
250
251      lt_commentary[] = gt_commentary[].
252      clear gt_commentary[].
253    * borrowed from 'INIT_REP_TAB_OF_CONDITIONS_ALV'
254      MOVE  TEXT-004 TO L_TDLINE.
255      PERFORM APPEND_COMMENTARY
256              USING 'S' L_KEY L_TDLINE
257              changing lt_commentary.
258    * Write header at top of page.
259      CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
260        EXPORTING
261          IT_LIST_COMMENTARY = LT_COMMENTARY.
262
263    ENDFORM.                    " ausna_07_top
264    *&---------------------------------------------------------------------*
265    *&      Form  ausna_09
266    *&---------------------------------------------------------------------*
267    *       text
268    *----------------------------------------------------------------------*
269    *  -->  p1        text
270    *  <--  p2        text
271    *----------------------------------------------------------------------*
272    FORM ausna_09 . "#EC CALLED
273      field-symbols: <fc> like line of gt_fieldcat_a_satz.
274    *  data: lt_eventtab_appends like gt_eventtab_appends.
275    *DISPLAY ALV GRID.
276    *       WRITE: /4 AUSNAHME_SATZ-BUKRS,
277    *                 AUSNAHME_SATZ-MATNR , AUSNAHME_SATZ-BWKEY,
278    *                 AUSNAHME_SATZ-BWTAR .
279      data: lt_ausnahme_satz like ausnahme_satz occurs 100.
280      loop at gt_fieldcat_a_satz assigning <fc>.
281        case <fc>-fieldname.
282             when 'BUKRS' or
283                  'MATNR' or
284                  'BWKEY' or
285                  'BWTAR'.
286                  <fc>-no_out = space.
287             when others.
288                  <fc>-no_out = 'X'.
289          endcase.
290      endloop.
291      perform change_event using space.
292      perform change_event_top_of_page using 'AUSNA_09_TOP'.
293    * reduce data sets
294      LOOP AT AUSNAHME_SATZ
295           where AUSNA = '09' and
296                 BWKEY NE SPACE and
297                 WERKS = SPACE and
298                 LGORT = SPACE and
299                 CHARG = SPACE and
300                 LIFNR = SPACE.
301           append ausnahme_satz to lt_ausnahme_satz.
302      ENDLOOP.
303
304      clear: gt_log[].
305      GS_LAYOUT_SBAL-LIST_APPEND = 'X'. "note 1267052
306      CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
307        EXPORTING
308          I_CALLBACK_PROGRAM = GV_REPID
309          IS_LAYOUT          = GS_LAYOUT_sbal
310          IT_FIELDCAT        = GT_FIELDCAT_a_satz
311          I_SAVE             = GC_SAVE      "'A'
312          IT_EVENTS          = GT_EVENTTAB_appends
313        TABLES
314          T_OUTTAB           = lt_ausnahme_satz
315        EXCEPTIONS
316          PROGRAM_ERROR      = 1
317          OTHERS             = 2.
318
319      IF SY-SUBRC <> 0.
320         MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
321                 WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
322        ENDIF.
323
324
325    ENDFORM.                    " ausna_09
326    *&---------------------------------------------------------------------*
327    *&      Form  ausna_09_top
328    *&---------------------------------------------------------------------*
329    *       text
330    *----------------------------------------------------------------------*
331    *      -->   text
332    *----------------------------------------------------------------------*
333    FORM ausna_09_top. "#EC CALLED
334    data: lt_commentary type SLIS_T_LISTHEADER.
335    *      "Nicht alle Bewertungssätze konnten umgesetzt werden
336    **      WRITE: (40) TEXT-006, ZAEHLER_MBEW.
337    **      WRITE: (40) TEXT-007, ZAEHLER_MBEW_SCHIEF.
338      perform generate_ausna_xx_top
339             using ZAEHLER_MBEW ZAEHLER_MBEW_SCHIEF
340             changing lt_commentary.
341    * Write header at top of page.
342      CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
343        EXPORTING
344          IT_LIST_COMMENTARY = LT_COMMENTARY.
345
346    ENDFORM.                    " ausna_09_top
347
348    *&---------------------------------------------------------------------*
349    *&      Form  ausna_11
350    *&---------------------------------------------------------------------*
351    *       text
352    *----------------------------------------------------------------------*
353    *  -->  p1        text
354    *  <--  p2        text
355    *----------------------------------------------------------------------*
356    FORM ausna_11 . "#EC CALLED
357      field-symbols: <fc> like line of gt_fieldcat_a_satz.
358      data: lt_ausnahme_satz like ausnahme_satz occurs 100.
359    *      LOOP AT AUSNAHME_SATZ.
360    *       CHECK AUSNAHME_SATZ-AUSNA = '11'.
361    **      CHECK AUSNAHME_SATZ-BWKEY = SPACE.
362    **      CHECK AUSNAHME_SATZ-WERKS NE SPACE.
363    **      CHECK AUSNAHME_SATZ-LGORT NE SPACE.
364    **      CHECK AUSNAHME_SATZ-CHARG = SPACE.
365    **      CHECK AUSNAHME_SATZ-LIFNR = SPACE.
366    *       WRITE: /4 AUSNAHME_SATZ-BUKRS,
367    *                 AUSNAHME_SATZ-MATNR , AUSNAHME_SATZ-WERKS,
368    *                 AUSNAHME_SATZ-LGORT .
369    *      ENDLOOP.
370      loop at gt_fieldcat_a_satz assigning <fc>.
371        case <fc>-fieldname.
372             when 'BUKRS' or
373                  'MATNR' or
374                  'WERKS' or
375                  'LGORT'.
376                  <fc>-no_out = space.
377             when others.
378                  <fc>-no_out = 'X'.
379          endcase.
380      endloop.
381      perform change_event using space.
382      perform change_event_top_of_page using 'AUSNA_11_TOP'.
383    * reduce data sets
384      LOOP AT AUSNAHME_SATZ
385           where AUSNA =  '11'  and
386                 BWKEY =  SPACE and
387                 WERKS NE SPACE and
388                 LGORT NE SPACE and
389                 CHARG =  SPACE and
390                 LIFNR =  SPACE.
391           append ausnahme_satz to lt_ausnahme_satz.
392      ENDLOOP.
393
394      clear: gt_log[].
395      GS_LAYOUT_SBAL-LIST_APPEND = 'X'. "note 1267052
396      CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
397        EXPORTING
398          I_CALLBACK_PROGRAM = GV_REPID
399          IS_LAYOUT          = GS_LAYOUT_sbal
400          IT_FIELDCAT        = GT_FIELDCAT_a_satz
401          I_SAVE             = GC_SAVE      "'A'
402          IT_EVENTS          = GT_EVENTTAB_appends
403        TABLES
404          T_OUTTAB           = lt_ausnahme_satz
405        EXCEPTIONS
406          PROGRAM_ERROR      = 1
407          OTHERS             = 2.
408
409      IF SY-SUBRC <> 0.
410         MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
411                 WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
412        ENDIF.
413
414
415    ENDFORM.                    " ausna_11
416    *&---------------------------------------------------------------------*
417    *&      Form  ausna_11_top
418    *&---------------------------------------------------------------------*
419    *       text
420    *----------------------------------------------------------------------*
421    *      -->   text
422    *----------------------------------------------------------------------*
423    FORM ausna_11_top. "#EC CALLED
424    data: lt_commentary type SLIS_T_LISTHEADER.
425    **      WRITE: (40) TEXT-006, ZAEHLER_MARD.
426    **      WRITE: (40) TEXT-007, ZAEHLER_MARD_SCHIEF.
427      perform generate_ausna_xx_top
428             using ZAEHLER_MARD ZAEHLER_MARD_SCHIEF
429             changing lt_commentary.
430    * Write header at top of page.
431      CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
432        EXPORTING
433          IT_LIST_COMMENTARY = LT_COMMENTARY.
434
435    ENDFORM.                    " ausna_11_top
436
437    *&---------------------------------------------------------------------*
438    *&      Form  ausna_13
439    *&---------------------------------------------------------------------*
440    *       text
441    *----------------------------------------------------------------------*
442    *  -->  p1        text
443    *  <--  p2        text
444    *----------------------------------------------------------------------*
445    FORM ausna_13 . "#EC CALLED
446      field-symbols: <fc> like line of gt_fieldcat_a_satz.
447      data: lt_ausnahme_satz like ausnahme_satz occurs 100.
448    *      WRITE TEXT-011.
449    *      LOOP AT AUSNAHME_SATZ.
450    *       CHECK AUSNAHME_SATZ-AUSNA = '13'.
451    **      CHECK AUSNAHME_SATZ-BWKEY = SPACE.
452    **      CHECK AUSNAHME_SATZ-WERKS NE SPACE.
453    **      CHECK AUSNAHME_SATZ-LGORT NE SPACE.
454    **      CHECK AUSNAHME_SATZ-CHARG NE SPACE.
455    **      CHECK AUSNAHME_SATZ-LIFNR =  SPACE.
456    *       WRITE: /4 AUSNAHME_SATZ-BUKRS,
457    *                 AUSNAHME_SATZ-MATNR , AUSNAHME_SATZ-WERKS,
458    *                 AUSNAHME_SATZ-LGORT , AUSNAHME_SATZ-CHARG.
459    *      ENDLOOP.
460      loop at gt_fieldcat_a_satz assigning <fc>.
461        case <fc>-fieldname.
462             when 'BUKRS' or
463                  'MATNR' or
464                  'WERKS' or
465                  'LGORT' or
466                  'CHARG'.
467                  <fc>-no_out = space.
468             when others.
469                  <fc>-no_out = 'X'.
470          endcase.
471      endloop.
472      perform change_event using space.
473      perform change_event_top_of_page using 'AUSNA_13_TOP'.
474    * reduce data sets
475      LOOP AT AUSNAHME_SATZ
476           where AUSNA =  '13'  and
477                 BWKEY =  SPACE and
478                 WERKS NE SPACE and
479                 LGORT NE SPACE and
480                 CHARG NE SPACE and
481                 LIFNR =  SPACE.
482           append ausnahme_satz to lt_ausnahme_satz.
483      ENDLOOP.
484
485      clear: gt_log[].
486      GS_LAYOUT_SBAL-LIST_APPEND = 'X'. "note 1267052
487      CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
488        EXPORTING
489          I_CALLBACK_PROGRAM = GV_REPID
490          IS_LAYOUT          = GS_LAYOUT_sbal
491          IT_FIELDCAT        = GT_FIELDCAT_a_satz
492          I_SAVE             = GC_SAVE      "'A'
493          IT_EVENTS          = GT_EVENTTAB_appends
494        TABLES
495          T_OUTTAB           = lt_ausnahme_satz
496        EXCEPTIONS
497          PROGRAM_ERROR      = 1
498          OTHERS             = 2.
499
500      IF SY-SUBRC <> 0.
501         MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
502                 WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
503        ENDIF.
504
505
506    ENDFORM.                    " ausna_13
507    *&---------------------------------------------------------------------*
508    *&      Form  ausna_13_top
509    *&---------------------------------------------------------------------*
510    *       text
511    *----------------------------------------------------------------------*
512    *      -->   text
513    *----------------------------------------------------------------------*
514    FORM ausna_13_top. "#EC CALLED
515    data: lt_commentary type SLIS_T_LISTHEADER.
516    *      WRITE: (40) TEXT-006, ZAEHLER_MCHB.
517    *      WRITE: (40) TEXT-007, ZAEHLER_MCHB_SCHIEF.
518    *      WRITE TEXT-008.
519      perform generate_ausna_xx_top
520             using ZAEHLER_MCHB ZAEHLER_MCHB_SCHIEF
521             changing lt_commentary.
522    * Write header at top of page.
523      CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
524        EXPORTING
525          IT_LIST_COMMENTARY = LT_COMMENTARY.
526
527    ENDFORM.                    " ausna_13_top
528
529    *&---------------------------------------------------------------------*
530    *&      Form  ausna_26
531    *&---------------------------------------------------------------------*
532    *       text
533    *----------------------------------------------------------------------*
534    *  -->  p1        text
535    *  <--  p2        text
536    *----------------------------------------------------------------------*
537    FORM ausna_26 . "#EC CALLED
538      field-symbols: <fc> like line of gt_fieldcat_a_satz.
539      data: lt_ausnahme_satz like ausnahme_satz occurs 100.
540    *      WRITE TEXT-014.
541    *      LOOP AT AUSNAHME_SATZ.
542    *       CHECK AUSNAHME_SATZ-AUSNA = '26'.
543    **      CHECK AUSNAHME_SATZ-BWKEY = SPACE.
544    **      CHECK AUSNAHME_SATZ-WERKS NE SPACE.
545    **      CHECK AUSNAHME_SATZ-LGORT NE SPACE.
546    **      CHECK AUSNAHME_SATZ-LIFNR NE SPACE.
547    *       WRITE: /4 AUSNAHME_SATZ-BUKRS,
548    *                 AUSNAHME_SATZ-MATNR , AUSNAHME_SATZ-WERKS,
549    *                 AUSNAHME_SATZ-LGORT , AUSNAHME_SATZ-CHARG,
550    *                 AUSNAHME_SATZ-LIFNR .
551    *      ENDLOOP.
552      loop at gt_fieldcat_a_satz assigning <fc>.
553        case <fc>-fieldname.
554             when 'BUKRS' or
555                  'MATNR' or
556                  'WERKS' or
557                  'LGORT' or
558                  'CHARG' or
559                  'LIFNR'.
560                  <fc>-no_out = space.
561             when others.
562                  <fc>-no_out = 'X'.
563          endcase.
564      endloop.
565      perform change_event using space.
566      perform change_event_top_of_page using 'AUSNA_26_TOP'.
567    * reduce data sets
568      LOOP AT AUSNAHME_SATZ
569           where AUSNA =  '26'  and
570                 BWKEY =  SPACE and
571                 WERKS NE SPACE and
572                 LGORT NE SPACE and
573                 CHARG NE SPACE and
574                 LIFNR NE SPACE.
575           append ausnahme_satz to lt_ausnahme_satz.
576      ENDLOOP.
577
578      clear: gt_log[].
579      GS_LAYOUT_SBAL-LIST_APPEND = 'X'. "note 1267052
580      CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
581        EXPORTING
582          I_CALLBACK_PROGRAM = GV_REPID
583          IS_LAYOUT          = GS_LAYOUT_sbal
584          IT_FIELDCAT        = GT_FIELDCAT_a_satz
585          I_SAVE             = GC_SAVE      "'A'
586          IT_EVENTS          = GT_EVENTTAB_appends
587        TABLES
588          T_OUTTAB           = lt_ausnahme_satz
589        EXCEPTIONS
590          PROGRAM_ERROR      = 1
591          OTHERS             = 2.
592
593      IF SY-SUBRC <> 0.
594         MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
595                 WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
596        ENDIF.
597
598
599    ENDFORM.                    " ausna_26
600    *&---------------------------------------------------------------------*
601    *&      Form  ausna_26_top
602    *&---------------------------------------------------------------------*
603    *       text
604    *----------------------------------------------------------------------*
605    *      -->   text
606    *----------------------------------------------------------------------*
607    FORM ausna_26_top. "#EC CALLED
608    data: lt_commentary type SLIS_T_LISTHEADER.
609    *      WRITE: (40) TEXT-006, ZAEHLER_MKOL.
610    *      WRITE: (40) TEXT-007, ZAEHLER_MKOL_SCHIEF.
611    *      WRITE TEXT-008.
612      perform generate_ausna_xx_top
613             using ZAEHLER_MKOL ZAEHLER_MKOL_SCHIEF
614             changing lt_commentary.
615    * Write header at top of page.
616      CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
617        EXPORTING
618          IT_LIST_COMMENTARY = LT_COMMENTARY.
619
620    ENDFORM.                    " ausna_26_top
621
622
623    *&---------------------------------------------------------------------*
624    *&      Form  ausna_35
625    *&---------------------------------------------------------------------*
626    *       text
627    *----------------------------------------------------------------------*
628    *  -->  p1        text
629    *  <--  p2        text
630    *----------------------------------------------------------------------*
631    FORM ausna_35 . "#EC CALLED
632      field-symbols: <fc> like line of gt_fieldcat_a_satz.
633      data: lt_ausnahme_satz like ausnahme_satz occurs 100.
634    *      WRITE TEXT-019.
635    *      LOOP AT AUSNAHME_SATZ.
636    *       CHECK AUSNAHME_SATZ-AUSNA = '35'.
637    *       WRITE: /4 AUSNAHME_SATZ-BUKRS,
638    *                 AUSNAHME_SATZ-MATNR , AUSNAHME_SATZ-WERKS,
639    *                 AUSNAHME_SATZ-CHARG , AUSNAHME_SATZ-LIFNR.
640    *      ENDLOOP.
641      loop at gt_fieldcat_a_satz assigning <fc>.
642        case <fc>-fieldname.
643             when 'BUKRS' or
644                  'MATNR' or
645                  'WERKS' or
646                  'CHARG' or
647                  'LIFNR'.
648                  <fc>-no_out = space.
649             when others.
650                  <fc>-no_out = 'X'.
651          endcase.
652      endloop.
653      perform change_event using space.
654      perform change_event_top_of_page using 'AUSNA_35_TOP'.
655    * reduce data sets
656      LOOP AT AUSNAHME_SATZ
657           where AUSNA =  '35'.
658           append ausnahme_satz to lt_ausnahme_satz.
659      ENDLOOP.
660
661      clear: gt_log[].
662      GS_LAYOUT_SBAL-LIST_APPEND = 'X'. "note 1267052
663      CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
664        EXPORTING
665          I_CALLBACK_PROGRAM = GV_REPID
666          IS_LAYOUT          = GS_LAYOUT_sbal
667          IT_FIELDCAT        = GT_FIELDCAT_a_satz
668          I_SAVE             = GC_SAVE      "'A'
669          IT_EVENTS          = GT_EVENTTAB_appends
670        TABLES
671          T_OUTTAB           = lt_ausnahme_satz
672        EXCEPTIONS
673          PROGRAM_ERROR      = 1
674          OTHERS             = 2.
675
676      IF SY-SUBRC <> 0.
677         MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
678                 WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
679        ENDIF.
680
681
682    ENDFORM.                    " ausna_35
683    *&---------------------------------------------------------------------*
684    *&      Form  ausna_35_top
685    *&---------------------------------------------------------------------*
686    *       text
687    *----------------------------------------------------------------------*
688    *      -->   text
689    *----------------------------------------------------------------------*
690    FORM ausna_35_top. "#EC CALLED
691    data: lt_commentary type SLIS_T_LISTHEADER.
692    *      WRITE: (40) TEXT-006, ZAEHLER_MSLB.
693    *      WRITE: (40) TEXT-007, ZAEHLER_MSLB_SCHIEF.
694    *      WRITE TEXT-008.
695      perform generate_ausna_xx_top
696             using ZAEHLER_MSLB ZAEHLER_MSLB_SCHIEF
697             changing lt_commentary.
698    * Write header at top of page.
699      CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
700        EXPORTING
701          IT_LIST_COMMENTARY = LT_COMMENTARY.
702
703    ENDFORM.                    " ausna_35_top
704
705    *&---------------------------------------------------------------------*
706    *&      Form  ausna_41
707    *&---------------------------------------------------------------------*
708    *       text
709    *----------------------------------------------------------------------*
710    *  -->  p1        text
711    *  <--  p2        text
712    *----------------------------------------------------------------------*
713    FORM ausna_41 . "#EC CALLED
714      field-symbols: <fc> like line of gt_fieldcat_a_satz.
715      data: lt_ausnahme_satz like ausnahme_satz occurs 100.
716    *      WRITE TEXT-020.
717    *      LOOP AT AUSNAHME_SATZ.
718    *       CHECK AUSNAHME_SATZ-AUSNA = '41'.
719    *       WRITE: /4 AUSNAHME_SATZ-BUKRS,
720    *                 AUSNAHME_SATZ-MATNR , AUSNAHME_SATZ-WERKS,
721    *                 AUSNAHME_SATZ-CHARG , AUSNAHME_SATZ-KUNNR.
722    *      ENDLOOP.
723      loop at gt_fieldcat_a_satz assigning <fc>.
724        case <fc>-fieldname.
725             when 'BUKRS' or
726                  'MATNR' or
727                  'WERKS' or
728                  'CHARG' or
729                  'KUNNR'.
730                  <fc>-no_out = space.
731             when others.
732                  <fc>-no_out = 'X'.
733          endcase.
734      endloop.
735      perform change_event using space.
736      perform change_event_top_of_page using 'AUSNA_41_TOP'.
737    * reduce data sets
738      LOOP AT AUSNAHME_SATZ
739           where AUSNA =  '41'.
740           append ausnahme_satz to lt_ausnahme_satz.
741      ENDLOOP.
742
743      clear: gt_log[].
744      GS_LAYOUT_SBAL-LIST_APPEND = 'X'. "note 1267052
745      CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
746        EXPORTING
747          I_CALLBACK_PROGRAM = GV_REPID
748          IS_LAYOUT          = GS_LAYOUT_sbal
749          IT_FIELDCAT        = GT_FIELDCAT_a_satz
750          I_SAVE             = GC_SAVE      "'A'
751          IT_EVENTS          = GT_EVENTTAB_appends
752        TABLES
753          T_OUTTAB           = lt_ausnahme_satz
754        EXCEPTIONS
755          PROGRAM_ERROR      = 1
756          OTHERS             = 2.
757
758      IF SY-SUBRC <> 0.
759         MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
760                 WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
761        ENDIF.
762
763
764    ENDFORM.                    " ausna_41
765    *&---------------------------------------------------------------------*
766    *&      Form  ausna_41_top
767    *&---------------------------------------------------------------------*
768    *       text
769    *----------------------------------------------------------------------*
770    *      -->   text
771    *----------------------------------------------------------------------*
772    FORM ausna_41_top. "#EC CALLED
773    data: lt_commentary type SLIS_T_LISTHEADER.
774    *      WRITE: (40) TEXT-006, ZAEHLER_MSKU.
775    *      WRITE: (40) TEXT-007, ZAEHLER_MSKU_SCHIEF.
776    *      WRITE TEXT-008.
777      perform generate_ausna_xx_top
778             using ZAEHLER_MSKU ZAEHLER_MSKU_SCHIEF
779             changing lt_commentary.
780    * Write header at top of page.
781      CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
782        EXPORTING
783          IT_LIST_COMMENTARY = LT_COMMENTARY.
784
785    ENDFORM.                    " ausna_41_top
786
787    *&---------------------------------------------------------------------*
788    *&      Form  ausna_44
789    *&---------------------------------------------------------------------*
790    *       text
791    *----------------------------------------------------------------------*
792    *  -->  p1        text
793    *  <--  p2        text
794    *----------------------------------------------------------------------*
795    FORM ausna_44 . "#EC CALLED
796      field-symbols: <fc> like line of gt_fieldcat_a_satz.
797      data: lt_ausnahme_satz like ausnahme_satz occurs 100.
798    *      WRITE TEXT-021.
799    *      LOOP AT AUSNAHME_SATZ.
800    *       CHECK AUSNAHME_SATZ-AUSNA = '44'.
801    *       WRITE: /4 AUSNAHME_SATZ-BUKRS,
802    *                 AUSNAHME_SATZ-MATNR , AUSNAHME_SATZ-WERKS,
803    *                 AUSNAHME_SATZ-LGORT , AUSNAHME_SATZ-CHARG,
804    *                 AUSNAHME_SATZ-VBELN , AUSNAHME_SATZ-POSNR.
805    *               " AUSNAHME_SATZ-ETENR.
806    *      ENDLOOP.
807      loop at gt_fieldcat_a_satz assigning <fc>.
808        case <fc>-fieldname.
809             when 'BUKRS' or
810                  'MATNR' or
811                  'WERKS' or
812                  'LGORT' or
813                  'CHARG' or
814                  'VBELN' or
815                  'POSNR'.
816                  <fc>-no_out = space.
817             when others.
818                  <fc>-no_out = 'X'.
819          endcase.
820      endloop.
821      perform change_event using space.
822      perform change_event_top_of_page using 'AUSNA_44_TOP'.
823    * reduce data sets
824      LOOP AT AUSNAHME_SATZ
825           where AUSNA =  '44'.
826           append ausnahme_satz to lt_ausnahme_satz.
827      ENDLOOP.
828
829      clear: gt_log[].
830      GS_LAYOUT_SBAL-LIST_APPEND = 'X'. "note 1267052
831      CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
832        EXPORTING
833          I_CALLBACK_PROGRAM = GV_REPID
834          IS_LAYOUT          = GS_LAYOUT_sbal
835          IT_FIELDCAT        = GT_FIELDCAT_a_satz
836          I_SAVE             = GC_SAVE      "'A'
837          IT_EVENTS          = GT_EVENTTAB_appends
838        TABLES
839          T_OUTTAB           = lt_ausnahme_satz
840        EXCEPTIONS
841          PROGRAM_ERROR      = 1
842          OTHERS             = 2.
843
844      IF SY-SUBRC <> 0.
845         MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
846                 WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
847        ENDIF.
848
849
850    ENDFORM.                    " ausna_44
851    *&---------------------------------------------------------------------*
852    *&      Form  ausna_44_top
853    *&---------------------------------------------------------------------*
854    *       text
855    *----------------------------------------------------------------------*
856    *      -->   text
857    *----------------------------------------------------------------------*
858    FORM ausna_44_top. "#EC CALLED
859    data: lt_commentary type SLIS_T_LISTHEADER.
860    *      WRITE: (40) TEXT-006, ZAEHLER_MSKA.
861    *      WRITE: (40) TEXT-007, ZAEHLER_MSKA_SCHIEF.
862    *      WRITE TEXT-008.
863      perform generate_ausna_xx_top
864             using ZAEHLER_MSKA ZAEHLER_MSKA_SCHIEF
865             changing lt_commentary.
866    * Write header at top of page.
867      CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
868        EXPORTING
869          IT_LIST_COMMENTARY = LT_COMMENTARY.
870
871    ENDFORM.                    " ausna_44_top
872
873    *&---------------------------------------------------------------------*
874    *&      Form  ausna_50
875    *&---------------------------------------------------------------------*
876    *       text
877    *----------------------------------------------------------------------*
878    *  -->  p1        text
879    *  <--  p2        text
880    *----------------------------------------------------------------------*
881    FORM ausna_50 . "#EC CALLED
882      field-symbols: <fc> like line of gt_fieldcat_a_satz.
883      data: lt_ausnahme_satz like ausnahme_satz occurs 100.
884    *      WRITE TEXT-024.
885    *      WRITE / TEXT-025.
886    *      LOOP AT AUSNAHME_SATZ.
887    *       CHECK AUSNAHME_SATZ-AUSNA = '50'.
888    *       WRITE: /4 AUSNAHME_SATZ-BUKRS,
889    *                 AUSNAHME_SATZ-MATNR , AUSNAHME_SATZ-WERKS,
890    *                 AUSNAHME_SATZ-CHARG , AUSNAHME_SATZ-LIFNR.
891    *       WRITE: /6 AUSNAHME_SATZ-VBELN , AUSNAHME_SATZ-POSNR.
892    *               " AUSNAHME_SATZ-ETENR.
893    *      ENDLOOP.
894      loop at gt_fieldcat_a_satz assigning <fc>.
895        case <fc>-fieldname.
896             when 'BUKRS' or
897                  'MATNR' or
898                  'WERKS' or
899                  'CHARG' or
900                  'LIFNR' or
901                  'VBELN' or
902                  'POSNR'.
903                  <fc>-no_out = space.
904             when others.
905                  <fc>-no_out = 'X'.
906          endcase.
907      endloop.
908      perform change_event using space.
909      perform change_event_top_of_page using 'AUSNA_50_TOP'.
910    * reduce data sets
911      LOOP AT AUSNAHME_SATZ
912           where AUSNA =  '50'.
913           append ausnahme_satz to lt_ausnahme_satz.
914      ENDLOOP.
915
916      clear: gt_log[].
917      GS_LAYOUT_SBAL-LIST_APPEND = 'X'. "note 1267052
918      CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
919        EXPORTING
920          I_CALLBACK_PROGRAM = GV_REPID
921          IS_LAYOUT          = GS_LAYOUT_sbal
922          IT_FIELDCAT        = GT_FIELDCAT_a_satz
923          I_SAVE             = GC_SAVE      "'A'
924          IT_EVENTS          = GT_EVENTTAB_appends
925        TABLES
926          T_OUTTAB           = lt_ausnahme_satz
927        EXCEPTIONS
928          PROGRAM_ERROR      = 1
929          OTHERS             = 2.
930
931      IF SY-SUBRC <> 0.
932         MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
933                 WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
934        ENDIF.
935
936
937    ENDFORM.                    " ausna_50
938    *&---------------------------------------------------------------------*
939    *&      Form  ausna_50_top
940    *&---------------------------------------------------------------------*
941    *       text
942    *----------------------------------------------------------------------*
943    *      -->   text
944    *----------------------------------------------------------------------*
945    FORM ausna_50_top. "#EC CALLED
946    data: lt_commentary type SLIS_T_LISTHEADER.
947    *      WRITE: (40) TEXT-006, ZAEHLER_MSCA.
948    *      WRITE: (40) TEXT-007, ZAEHLER_MSCA_SCHIEF.
949    *      WRITE TEXT-008.
950      perform generate_ausna_xx_top
951             using ZAEHLER_MSCA ZAEHLER_MSCA_SCHIEF
952             changing lt_commentary.
953    * Write header at top of page.
954      CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
955        EXPORTING
956          IT_LIST_COMMENTARY = LT_COMMENTARY.
957
958    ENDFORM.                    " ausna_50_top
959
960    *&---------------------------------------------------------------------*
961    *&      Form  ausna_56
962    *&---------------------------------------------------------------------*
963    *       text
964    *----------------------------------------------------------------------*
965    *  -->  p1        text
966    *  <--  p2        text
967    *----------------------------------------------------------------------*
968    FORM ausna_56 . "#EC CALLED
969      field-symbols: <fc> like line of gt_fieldcat_a_satz.
970      data: lt_ausnahme_satz like ausnahme_satz occurs 100.
971    *      WRITE TEXT-027.
972    *      LOOP AT AUSNAHME_SATZ.
973    *       CHECK AUSNAHME_SATZ-AUSNA = '56'.
974    *       WRITE: /4 AUSNAHME_SATZ-BUKRS,
975    *                 AUSNAHME_SATZ-MATNR , AUSNAHME_SATZ-WERKS,
976    *                 AUSNAHME_SATZ-LGORT , AUSNAHME_SATZ-CHARG,
977    *                 AUSNAHME_SATZ-PSPNR.
978    *      ENDLOOP.
979      loop at gt_fieldcat_a_satz assigning <fc>.
980        case <fc>-fieldname.
981             when 'BUKRS' or
982                  'MATNR' or
983                  'WERKS' or
984                  'LGORT' or
985                  'CHARG' or
986                  'PSPNR'.
987                  <fc>-no_out = space.
988             when others.
989                  <fc>-no_out = 'X'.
990          endcase.
991      endloop.
992      perform change_event using space.
993      perform change_event_top_of_page using 'AUSNA_56_TOP'.
994    * reduce data sets
995      LOOP AT AUSNAHME_SATZ
996           where AUSNA =  '56'.
997           append ausnahme_satz to lt_ausnahme_satz.
998      ENDLOOP.
999
1000     clear: gt_log[].
1001     GS_LAYOUT_SBAL-LIST_APPEND = 'X'. "note 1267052
1002     CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
1003       EXPORTING
1004         I_CALLBACK_PROGRAM = GV_REPID
1005         IS_LAYOUT          = GS_LAYOUT_sbal
1006         IT_FIELDCAT        = GT_FIELDCAT_a_satz
1007         I_SAVE             = GC_SAVE      "'A'
1008         IT_EVENTS          = GT_EVENTTAB_appends
1009       TABLES
1010         T_OUTTAB           = lt_ausnahme_satz
1011       EXCEPTIONS
1012         PROGRAM_ERROR      = 1
1013         OTHERS             = 2.
1014
1015     IF SY-SUBRC <> 0.
1016        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
1017                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
1018       ENDIF.
1019
1020
1021   ENDFORM.                    " ausna_56
1022   *&---------------------------------------------------------------------*
1023   *&      Form  ausna_56_top
1024   *&---------------------------------------------------------------------*
1025   *       text
1026   *----------------------------------------------------------------------*
1027   *      -->   text
1028   *----------------------------------------------------------------------*
1029   FORM ausna_56_top. "#EC CALLED
1030   data: lt_commentary type SLIS_T_LISTHEADER.
1031   *      WRITE: (40) TEXT-006, ZAEHLER_MSPR.
1032   *      WRITE: (40) TEXT-007, ZAEHLER_MSPR_SCHIEF.
1033   *      WRITE TEXT-008.
1034     perform generate_ausna_xx_top
1035            using ZAEHLER_MSPR ZAEHLER_MSPR_SCHIEF
1036            changing lt_commentary.
1037   * Write header at top of page.
1038     CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
1039       EXPORTING
1040         IT_LIST_COMMENTARY = LT_COMMENTARY.
1041
1042   ENDFORM.                    " ausna_56_top
1043
1044   *&---------------------------------------------------------------------*
1045   *&      Form  ausna_62
1046   *&---------------------------------------------------------------------*
1047   *       text
1048   *----------------------------------------------------------------------*
1049   *  -->  p1        text
1050   *  <--  p2        text
1051   *----------------------------------------------------------------------*
1052   FORM ausna_62 . "#EC CALLED
1053     field-symbols: <fc> like line of gt_fieldcat_a_satz.
1054     data: lt_ausnahme_satz like ausnahme_satz occurs 100.
1055   *      WRITE TEXT-029.                            "#EC *
1056   *      LOOP AT AUSNAHME_SATZ.
1057   *       CHECK AUSNAHME_SATZ-AUSNA = '62'.
1058   *       WRITE: /4 AUSNAHME_SATZ-BUKRS,
1059   *                 AUSNAHME_SATZ-MATNR , AUSNAHME_SATZ-BWKEY,
1060   *                 AUSNAHME_SATZ-BWTAR ,
1061   *                 AUSNAHME_SATZ-VBELN , AUSNAHME_SATZ-POSNR.
1062   *      ENDLOOP.
1063     loop at gt_fieldcat_a_satz assigning <fc>.
1064       case <fc>-fieldname.
1065            when 'BUKRS' or
1066                 'MATNR' or
1067                 'BWKEY' or
1068                 'BWTAR' or
1069                 'VBELN' or
1070                 'POSNR'.
1071                 <fc>-no_out = space.
1072            when others.
1073                 <fc>-no_out = 'X'.
1074         endcase.
1075     endloop.
1076     perform change_event using space.
1077     perform change_event_top_of_page using 'AUSNA_62_TOP'.
1078   * reduce data sets
1079     LOOP AT AUSNAHME_SATZ
1080          where AUSNA =  '62'.
1081          append ausnahme_satz to lt_ausnahme_satz.
1082     ENDLOOP.
1083
1084     clear: gt_log[].
1085     GS_LAYOUT_SBAL-LIST_APPEND = 'X'. "note 1267052
1086     CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
1087       EXPORTING
1088         I_CALLBACK_PROGRAM = GV_REPID
1089         IS_LAYOUT          = GS_LAYOUT_sbal
1090         IT_FIELDCAT        = GT_FIELDCAT_a_satz
1091         I_SAVE             = GC_SAVE      "'A'
1092         IT_EVENTS          = GT_EVENTTAB_appends
1093       TABLES
1094         T_OUTTAB           = lt_ausnahme_satz
1095       EXCEPTIONS
1096         PROGRAM_ERROR      = 1
1097         OTHERS             = 2.
1098
1099     IF SY-SUBRC <> 0.
1100        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
1101                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
1102       ENDIF.
1103
1104
1105   ENDFORM.                    " ausna_62
1106   *&---------------------------------------------------------------------*
1107   *&      Form  ausna_62_top
1108   *&---------------------------------------------------------------------*
1109   *       text
1110   *----------------------------------------------------------------------*
1111   *      -->   text
1112   *----------------------------------------------------------------------*
1113   FORM ausna_62_top. "#EC CALLED
1114   data: lt_commentary type SLIS_T_LISTHEADER.
1115   *      WRITE: (40) TEXT-006, ZAEHLER_EBEW.
1116   *      WRITE: (40) TEXT-007, ZAEHLER_EBEW_SCHIEF.
1117   *      WRITE TEXT-008.
1118     perform generate_ausna_xx_top
1119            using ZAEHLER_EBEW ZAEHLER_EBEW_SCHIEF
1120            changing lt_commentary.
1121   * Write header at top of page.
1122     CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
1123       EXPORTING
1124         IT_LIST_COMMENTARY = LT_COMMENTARY.
1125
1126   ENDFORM.                    " ausna_62_top
1127
1128   *&---------------------------------------------------------------------*
1129   *&      Form  ausna_65
1130   *&---------------------------------------------------------------------*
1131   *       text
1132   *----------------------------------------------------------------------*
1133   *  -->  p1        text
1134   *  <--  p2        text
1135   *----------------------------------------------------------------------*
1136   FORM ausna_65. "#EC CALLED
1137     field-symbols: <fc> like line of gt_fieldcat_a_satz.
1138     data: lt_ausnahme_satz like ausnahme_satz occurs 100.
1139   *      WRITE TEXT-030.                               "#EC *
1140   *      LOOP AT AUSNAHME_SATZ.
1141   *       CHECK AUSNAHME_SATZ-AUSNA = '65'.
1142   *       WRITE: /4 AUSNAHME_SATZ-BUKRS,
1143   *                 AUSNAHME_SATZ-MATNR , AUSNAHME_SATZ-BWKEY,
1144   *                 AUSNAHME_SATZ-BWTAR , AUSNAHME_SATZ-PSPNR.
1145   *      ENDLOOP.
1146     loop at gt_fieldcat_a_satz assigning <fc>.
1147       case <fc>-fieldname.
1148            when 'BUKRS' or
1149                 'MATNR' or
1150                 'BWKEY' or
1151                 'BWTAR' or
1152                 'PSPNR'.
1153                 <fc>-no_out = space.
1154            when others.
1155                 <fc>-no_out = 'X'.
1156         endcase.
1157     endloop.
1158     perform change_event using space.
1159     perform change_event_top_of_page using 'AUSNA_65_TOP'.
1160   * reduce data sets
1161     LOOP AT AUSNAHME_SATZ
1162          where AUSNA =  '65'.
1163          append ausnahme_satz to lt_ausnahme_satz.
1164     ENDLOOP.
1165
1166     clear: gt_log[].
1167     GS_LAYOUT_SBAL-LIST_APPEND = 'X'. "note 1267052
1168     CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
1169       EXPORTING
1170         I_CALLBACK_PROGRAM = GV_REPID
1171         IS_LAYOUT          = GS_LAYOUT_sbal
1172         IT_FIELDCAT        = GT_FIELDCAT_a_satz
1173         I_SAVE             = GC_SAVE      "'A'
1174         IT_EVENTS          = GT_EVENTTAB_appends
1175       TABLES
1176         T_OUTTAB           = lt_ausnahme_satz
1177       EXCEPTIONS
1178         PROGRAM_ERROR      = 1
1179         OTHERS             = 2.
1180
1181     IF SY-SUBRC <> 0.
1182        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
1183                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
1184     ENDIF.
1185
1186   ENDFORM.                    " ausna_65
1187   *&---------------------------------------------------------------------*
1188   *&      Form  ausna_65_top
1189   *&---------------------------------------------------------------------*
1190   *       text
1191   *----------------------------------------------------------------------*
1192   *      -->   text
1193   *----------------------------------------------------------------------*
1194   FORM ausna_65_top. "#EC CALLED
1195   data: lt_commentary type SLIS_T_LISTHEADER.
1196   *      WRITE: (40) TEXT-006, ZAEHLER_QBEW.
1197   *      WRITE: (40) TEXT-007, ZAEHLER_QBEW_SCHIEF.
1198   *      WRITE TEXT-008.
1199     perform generate_ausna_xx_top
1200            using ZAEHLER_QBEW ZAEHLER_QBEW_SCHIEF
1201            changing lt_commentary.
1202   * Write header at top of page.
1203     CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
1204       EXPORTING
1205         IT_LIST_COMMENTARY = LT_COMMENTARY.
1206
1207   ENDFORM.                    " ausna_65_top
1208
1209   *&---------------------------------------------------------------------*
1210   *&      Form  ausna_70
1211   *&---------------------------------------------------------------------*
1212   *       text
1213   *----------------------------------------------------------------------*
1214   *  -->  p1        text
1215   *  <--  p2        text
1216   *----------------------------------------------------------------------*
1217   FORM ausna_70. "#EC CALLED
1218     field-symbols: <fc> like line of gt_fieldcat_a_satz.
1219     data: lt_ausnahme_satz like ausnahme_satz occurs 100.
1220   *      LOOP AT AUSNAHME_SATZ.
1221   *       CHECK AUSNAHME_SATZ-AUSNA = '70'.
1222   *       WRITE: /4 AUSNAHME_SATZ-BUKRS,
1223   *                 AUSNAHME_SATZ-MATNR , AUSNAHME_SATZ-BWKEY,
1224   *                 AUSNAHME_SATZ-BWTAR , AUSNAHME_SATZ-LIFNR.
1225   *      ENDLOOP.
1226     loop at gt_fieldcat_a_satz assigning <fc>.
1227       case <fc>-fieldname.
1228            when 'BUKRS' or
1229                 'MATNR' or
1230                 'BWKEY' or
1231                 'BWTAR' or
1232                 'LIFNR'.
1233                 <fc>-no_out = space.
1234            when others.
1235                 <fc>-no_out = 'X'.
1236         endcase.
1237     endloop.
1238     perform change_event using space.
1239     perform change_event_top_of_page using 'AUSNA_70_TOP'.
1240   * reduce data sets
1241     LOOP AT AUSNAHME_SATZ
1242          where AUSNA =  '70'.
1243          append ausnahme_satz to lt_ausnahme_satz.
1244     ENDLOOP.
1245
1246     clear: gt_log[].
1247     GS_LAYOUT_SBAL-LIST_APPEND = 'X'. "note 1267052
1248     CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
1249       EXPORTING
1250         I_CALLBACK_PROGRAM = GV_REPID
1251         IS_LAYOUT          = GS_LAYOUT_sbal
1252         IT_FIELDCAT        = GT_FIELDCAT_a_satz
1253         I_SAVE             = GC_SAVE      "'A'
1254         IT_EVENTS          = GT_EVENTTAB_appends
1255       TABLES
1256         T_OUTTAB           = lt_ausnahme_satz
1257       EXCEPTIONS
1258         PROGRAM_ERROR      = 1
1259         OTHERS             = 2.
1260
1261     IF SY-SUBRC <> 0.
1262        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
1263                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
1264     ENDIF.
1265
1266
1267   ENDFORM.                    " ausna_70
1268   *&---------------------------------------------------------------------*
1269   *&      Form  ausna_70_top
1270   *&---------------------------------------------------------------------*
1271   *       text
1272   *----------------------------------------------------------------------*
1273   *      -->   text
1274   *----------------------------------------------------------------------*
1275   FORM ausna_70_top. "#EC CALLED
1276   data: lt_commentary type SLIS_T_LISTHEADER.
1277   *      WRITE: (40) TEXT-006, ZAEHLER_OBEW.
1278   *      WRITE: (40) TEXT-007, ZAEHLER_OBEW_SCHIEF.
1279   *      WRITE TEXT-008.
1280     perform generate_ausna_xx_top
1281            using ZAEHLER_OBEW ZAEHLER_OBEW_SCHIEF
1282            changing lt_commentary.
1283   * Write header at top of page.
1284     CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
1285       EXPORTING
1286         IT_LIST_COMMENTARY = LT_COMMENTARY.
1287
1288   ENDFORM.                    " ausna_70_top
1289   *&---------------------------------------------------------------------*
1290   *&      Form  ausna_80
1291   *&---------------------------------------------------------------------*
1292   *       text
1293   *----------------------------------------------------------------------*
1294   *  -->  p1        text
1295   *  <--  p2        text
1296   *----------------------------------------------------------------------*
1297   FORM ausna_80. "#EC CALLED
1298     field-symbols: <fc> like line of gt_fieldcat_a_satz.
1299   *      WRITE: / TEXT-040.
1300   *      LOOP AT BWKEY_ML_ERROR.
1301   *        WRITE: /4 BWKEY_ML_ERROR-BUKRS, BWKEY_ML_ERROR-BWKEY.
1302   *      ENDLOOP.
1303     perform change_event using space.
1304     perform change_event_top_of_page using 'AUSNA_80_TOP'.
1305
1306     clear: gt_log[].
1307     GS_LAYOUT_SBAL-LIST_APPEND = 'X'. "note 1267052
1308     CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
1309       EXPORTING
1310         I_CALLBACK_PROGRAM = GV_REPID
1311         IS_LAYOUT          = GS_LAYOUT_sbal
1312         IT_FIELDCAT        = GT_FIELDCAT_bwkey_ml_err
1313         I_SAVE             = GC_SAVE      "'A'
1314         IT_EVENTS          = GT_EVENTTAB_appends
1315       TABLES
1316         T_OUTTAB           = bwkey_ml_error
1317       EXCEPTIONS
1318         PROGRAM_ERROR      = 1
1319         OTHERS             = 2.
1320
1321     IF SY-SUBRC <> 0.
1322        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
1323                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
1324     ENDIF.
1325   ENDFORM.                    " ausna_80
1326   *&---------------------------------------------------------------------*
1327   *&      Form  ausna_80_top
1328   *&---------------------------------------------------------------------*
1329   *       text
1330   *----------------------------------------------------------------------*
1331   *      -->   text
1332   *----------------------------------------------------------------------*
1333   FORM ausna_80_top. "#EC CALLED
1334   data: lt_commentary type SLIS_T_LISTHEADER.
1335     lt_commentary[] = gt_commentary[].
1336     clear: gt_commentary[].
1337   * Write header at top of page.
1338     CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
1339       EXPORTING
1340         IT_LIST_COMMENTARY = LT_COMMENTARY.
1341
1342   ENDFORM.                    " ausna_80_top
1343
1344   *&---------------------------------------------------------------------*
1345   *&      Form  ausna_94
1346   *&---------------------------------------------------------------------*
1347   *       text
1348   *----------------------------------------------------------------------*
1349   *  -->  p1        text
1350   *  <--  p2        text
1351   *----------------------------------------------------------------------*
1352   FORM ausna_94. "#EC CALLED
1353      SORT AUSNAHME_NEG BY SAART BUKRS MATNR BWKEY BWTAR WERKS LGORT
1354                             CHARG LIFNR KUNNR VBELN POSNR.
1355      LOOP AT AUSNAHME_NEG.
1356          IF SY-TABIX = 1 OR SAART_ALT NE AUSNAHME_NEG-SAART.
1357            if sy-tabix <> 1.
1358               perform ausnahme_neg using saart_alt.
1359            endif.
1360            SAART_ALT = AUSNAHME_NEG-SAART.
1361          endif.
1362          append ausnahme_neg to gt_ausnahme_neg.
1363        ENDLOOP.
1364        perform ausnahme_neg using saart_alt.
1365   ENDFORM.                    " ausna_94
1366   *&---------------------------------------------------------------------*
1367   *&      Form  change_event
1368   *&---------------------------------------------------------------------*
1369   *       text
1370   *----------------------------------------------------------------------*
1371   *      -->FORM_NAME   text
1372   *----------------------------------------------------------------------*
1373   FORM change_event  USING    FORM_NAME type any.
1374
1375   field-symbols: <ls_event> like line of gt_eventtab_sbal.
1376
1377     READ TABLE GT_EVENTTAB_SBAL
1378       WITH KEY NAME = SLIS_EV_END_OF_LIST
1379       assigning <LS_EVENT>.
1380     IF SY-SUBRC = 0.
1381       <LS_EVENT>-FORM = FORM_NAME.
1382     ENDIF.
1383
1384   ENDFORM.                    " change_event
1385   *&---------------------------------------------------------------------*
1386   *&      Form  change_event
1387   *&---------------------------------------------------------------------*
1388   *       text
1389   *----------------------------------------------------------------------*
1390   *      -->FORM_NAME   text
1391   *----------------------------------------------------------------------*
1392   FORM change_event_top_of_page  USING    FORM_NAME type any.
1393
1394   field-symbols: <ls_event> like line of gt_eventtab_sbal.
1395
1396     READ TABLE GT_EVENTTAB_APPENDS
1397       WITH KEY NAME = SLIS_EV_TOP_OF_PAGE
1398       assigning <LS_EVENT>.
1399     IF SY-SUBRC = 0.
1400       <LS_EVENT>-FORM = FORM_NAME.
1401     ENDIF.
1402
1403   ENDFORM.                    " change_event
1404   *&---------------------------------------------------------------------*
1405   *&      Form  change_event_with_display
1406   *&---------------------------------------------------------------------*
1407   *       text
1408   *----------------------------------------------------------------------*
1409   *      -->FORM_NAME   text
1410   *----------------------------------------------------------------------*
1411   FORM change_event_with_display  USING    FORM_NAME type any.
1412
1413     perform change_event using FORM_NAME.
1414     perform display_alv.
1415   ENDFORM.                    " change_event_with_display
1416   *&---------------------------------------------------------------------*
1417   *&      Form  append_commentary
1418   *&---------------------------------------------------------------------*
1419   *       Append text to the commentary_write table
1420   * borrowed from report 'INIT_REP_TAB_OF_CONDITIONS_ALV'
1421   *----------------------------------------------------------------------*
1422   *      -->I_TYP     Commentary type
1423   *      -->I_KEY     Commentary key
1424   *      -->I_TDLINE  Commenatry line
1425   *----------------------------------------------------------------------*
1426   FORM APPEND_COMMENTARY  USING I_TYP TYPE SLIS_LISTHEADER-TYP
1427                                 I_KEY TYPE SLIS_LISTHEADER-KEY
1428                                 I_TDLINE TYPE TLINE-TDLINE
1429        CHANGING PT_COMMENTARY TYPE SLIS_T_LISTHEADER.
1430
1431   data: ls_commentary like line of PT_COMMENTARY.
1432   data: LS_TLINE TYPE TLINE,
1433         Lt_TLINE TYPE TABLE OF TLINE,
1434         G_TDLINE TYPE TLINE-TDLINE.
1435
1436   * Check string length and wrap if necessary
1437     IF STRLEN( I_TDLINE ) > 60.
1438       CLEAR: LS_TLINE, Lt_TLINE.
1439       LS_TLINE-TDLINE = I_TDLINE.
1440       APPEND LS_TLINE TO Lt_TLINE.
1441   *   Wrap the 'info' line into separate lines
1442       CALL FUNCTION 'FORMAT_TEXTLINES'
1443         EXPORTING
1444           FORMATWIDTH = 60
1445           LINEWIDTH   = 132
1446           STARTLINE   = 1
1447         TABLES
1448           LINES       = Lt_TLINE
1449         EXCEPTIONS
1450           OTHERS      = 0.
1451   *   Get back string parts and append to commentary table
1452       LOOP AT Lt_TLINE INTO LS_TLINE.
1453         CLEAR LS_COMMENTARY.
1454         IF SY-TABIX = 1.
1455           LS_COMMENTARY-KEY = I_KEY.
1456         ENDIF.
1457         LS_COMMENTARY-TYP = I_TYP.
1458         LS_COMMENTARY-INFO = LS_TLINE-TDLINE.
1459         APPEND LS_COMMENTARY TO PT_COMMENTARY.
1460       ENDLOOP.
1461     ELSE.   "String length less than 60
1462       CLEAR LS_COMMENTARY.
1463       LS_COMMENTARY-TYP = I_TYP.
1464       LS_COMMENTARY-KEY = I_KEY.
1465       LS_COMMENTARY-INFO = I_TDLINE.
1466       APPEND LS_COMMENTARY TO PT_COMMENTARY.
1467     ENDIF.
1468
1469     "note 2186338
1470     PERFORM message_store
1471       USING 'MM' i_typ '899' i_tdline ' ' ' ' ' '.
1472
1473   ENDFORM.                    " append_commentary
1474   *&---------------------------------------------------------------------*
1475   *&      Form  generate_ausna_xx_top
1476   *&---------------------------------------------------------------------*
1477   *       text
1478   *----------------------------------------------------------------------*
1479   *      -->P_ZAEHLER text
1480   *      -->P_ZAEHLER_SCHIEF  text
1481   *----------------------------------------------------------------------*
1482   FORM generate_ausna_xx_top
1483        USING    P_ZAEHLER        like syst-tabix
1484                 P_ZAEHLER_SCHIEF like syst-tabix
1485        CHANGING PT_COMMENTARY    type SLIS_T_LISTHEADER.
1486
1487   data: l_KEY TYPE SLIS_LISTHEADER-KEY,       "Commentary key
1488         L_TDLINE TYPE TLINE-TDLINE.
1489
1490     pt_commentary[] = gt_commentary[].
1491     clear gt_commentary[].
1492
1493     if P_ZAEHLER is initial.
1494        L_TDLINE = '0'.
1495     else.
1496        write P_ZAEHLER to L_TDLINE.
1497     endif.
1498     concatenate TEXT-006 L_TDLINE into L_TDLINE separated by space.
1499     PERFORM APPEND_COMMENTARY
1500             USING 'S' L_KEY L_TDLINE
1501             changing pt_commentary.
1502   **      WRITE: (40) TEXT-007, ZAEHLER_..._SCHIEF.
1503     if P_ZAEHLER_SCHIEF is initial.
1504        L_TDLINE = '0'.
1505     else.
1506        write P_ZAEHLER_SCHIEF to L_TDLINE.
1507     endif.
1508     concatenate TEXT-007 L_TDLINE into L_TDLINE separated by space.
1509     PERFORM APPEND_COMMENTARY
1510             USING 'S' L_KEY L_TDLINE
1511             changing pt_commentary.
1512     write TEXT-008 to L_TDLINE.
1513     PERFORM APPEND_COMMENTARY
1514             USING 'S' L_KEY L_TDLINE
1515             changing pt_commentary.
1516
1517   ENDFORM.                    " generate_ausna_xx_top
1518   *&---------------------------------------------------------------------*
1519   *&      Form  ausnahme_neg
1520   *&---------------------------------------------------------------------*
1521   *       text
1522   *----------------------------------------------------------------------*
1523   *      -->P_SAART_ALT  text
1524   *----------------------------------------------------------------------*
1525   FORM ausnahme_neg  USING    P_SAART like saart_ALT.
1526
1527     field-symbols: <fc> like line of gt_fieldcat_a_satz.
1528
1529     check not gt_ausnahme_neg[] is initial.
1530     CASE P_SAART.
1531          WHEN '01'.   "MBEW-Sätze
1532                perform text_to_comment using text-201.
1533   *             perform text_to_comment using TEXT-009.
1534   *           WRITE: /4 AUSNAHME_NEG-BUKRS,
1535   *                 AUSNAHME_NEG-MATNR , AUSNAHME_NEG-BWKEY,
1536   *                 AUSNAHME_NEG-BWTAR .
1537                loop at gt_fieldcat_ausnahme_neg assigning <fc>.
1538                     case <fc>-fieldname.
1539                          when 'BUKRS' or
1540                               'MATNR' or
1541                               'BWKEY' or
1542                               'BWTAR'.
1543                               <fc>-no_out = space.
1544                          when others.
1545                               <fc>-no_out = 'X'.
1546                     endcase.
1547                   endloop.
1548
1549          WHEN '02'.   "MARD-Sätze
1550                perform text_to_comment using TEXT-202.
1551   *             perform text_to_comment using TEXT-010.
1552   *           WRITE: /4 AUSNAHME_NEG-BUKRS,
1553   *                 AUSNAHME_NEG-MATNR , AUSNAHME_NEG-WERKS,
1554   *                 AUSNAHME_NEG-LGORT .
1555                loop at gt_fieldcat_ausnahme_neg assigning <fc>.
1556                     case <fc>-fieldname.
1557                          when 'BUKRS' or
1558                               'MATNR' or
1559                               'WERKS' or
1560                               'LGORT'.
1561                               <fc>-no_out = space.
1562                          when others.
1563                               <fc>-no_out = 'X'.
1564                     endcase.
1565                   endloop.
1566
1567          WHEN '03'.   "MCHB-Sätze
1568                perform text_to_comment using TEXT-203.
1569   *             perform text_to_comment using TEXT-011.
1570   *           WRITE: /4 AUSNAHME_NEG-BUKRS,
1571   *                 AUSNAHME_NEG-MATNR , AUSNAHME_NEG-WERKS,
1572   *                 AUSNAHME_NEG-LGORT , AUSNAHME_NEG-CHARG.
1573                loop at gt_fieldcat_ausnahme_neg assigning <fc>.
1574                     case <fc>-fieldname.
1575                          when 'BUKRS' or
1576                               'MATNR' or
1577                               'WERKS' or
1578                               'LGORT' or
1579                               'CHARG'.
1580                               <fc>-no_out = space.
1581                          when others.
1582                               <fc>-no_out = 'X'.
1583                     endcase.
1584                   endloop.
1585
1586          WHEN '04'.   "MKOL-Sätze / L.Konsi
1587                perform text_to_comment using TEXT-204.
1588   *             perform text_to_comment using TEXT-014.
1589   *           WRITE: /4 AUSNAHME_NEG-BUKRS,
1590   *                 AUSNAHME_NEG-MATNR , AUSNAHME_NEG-WERKS,
1591   *                 AUSNAHME_NEG-LGORT , AUSNAHME_NEG-CHARG,
1592   *                 AUSNAHME_NEG-LIFNR .
1593                loop at gt_fieldcat_ausnahme_neg assigning <fc>.
1594                     case <fc>-fieldname.
1595                          when 'BUKRS' or
1596                               'MATNR' or
1597                               'WERKS' or
1598                               'LGORT' or
1599                               'CHARG' or
1600                               'LIFNR'.
1601                               <fc>-no_out = space.
1602                          when others.
1603                               <fc>-no_out = 'X'.
1604                     endcase.
1605                   endloop.
1606
1607          WHEN '05'.   "MSLB-Sätze
1608   *           WRITE: /4 AUSNAHME_NEG-BUKRS,
1609   *                 AUSNAHME_NEG-MATNR , AUSNAHME_NEG-WERKS,
1610   *                 AUSNAHME_NEG-CHARG , AUSNAHME_NEG-LIFNR.
1611                perform text_to_comment using TEXT-205.
1612   *             perform text_to_comment using TEXT-019.
1613                loop at gt_fieldcat_ausnahme_neg assigning <fc>.
1614                     case <fc>-fieldname.
1615                          when 'BUKRS' or
1616                               'MATNR' or
1617                               'WERKS' or
1618                               'CHARG' or
1619                               'LIFNR'.
1620                               <fc>-no_out = space.
1621                          when others.
1622                               <fc>-no_out = 'X'.
1623                     endcase.
1624                   endloop.
1625
1626          WHEN '06'.   "MSKU-Sätze / K.Konsi
1627                perform text_to_comment using TEXT-206.
1628   *             perform text_to_comment using TEXT-020.
1629   *           WRITE: /4 AUSNAHME_NEG-BUKRS,
1630   *                 AUSNAHME_NEG-MATNR , AUSNAHME_NEG-WERKS,
1631   *                 AUSNAHME_NEG-CHARG , AUSNAHME_NEG-KUNNR.
1632                loop at gt_fieldcat_ausnahme_neg assigning <fc>.
1633                     case <fc>-fieldname.
1634                          when 'BUKRS' or
1635                               'MATNR' or
1636                               'WERKS' or
1637                               'CHARG' or
1638                               'KUNNR'.
1639                               <fc>-no_out = space.
1640                          when others.
1641                               <fc>-no_out = 'X'.
1642                     endcase.
1643                   endloop.
1644
1645          WHEN '07'.   "MSKA-Sätze
1646                perform text_to_comment using TEXT-207.
1647   *             perform text_to_comment using TEXT-021.
1648   *           WRITE: /4 AUSNAHME_NEG-BUKRS,
1649   *                 AUSNAHME_NEG-MATNR , AUSNAHME_NEG-WERKS,
1650   *                 AUSNAHME_NEG-LGORT , AUSNAHME_NEG-CHARG,
1651   *                 AUSNAHME_NEG-VBELN , AUSNAHME_NEG-POSNR.
1652                loop at gt_fieldcat_ausnahme_neg assigning <fc>.
1653                     case <fc>-fieldname.
1654                          when 'BUKRS' or
1655                               'MATNR' or
1656                               'WERKS' or
1657                               'LGORT' or
1658                               'CHARG' or
1659                               'VBELN' or
1660                               'POSNR'.
1661                               <fc>-no_out = space.
1662                          when others.
1663                               <fc>-no_out = 'X'.
1664                     endcase.
1665                   endloop.
1666
1667          WHEN '08'.   "MSCA-Sätze
1668                perform text_to_comment using TEXT-208.
1669   *             perform text_to_comment using TEXT-024.
1670   *             perform text_to_comment using TEXT-025.
1671   *           WRITE: /4 AUSNAHME_NEG-BUKRS,
1672   *                 AUSNAHME_NEG-MATNR , AUSNAHME_NEG-WERKS,
1673   *                 AUSNAHME_NEG-CHARG , AUSNAHME_NEG-LIFNR.
1674   *           WRITE: /6 AUSNAHME_NEG-VBELN , AUSNAHME_NEG-POSNR.
1675                loop at gt_fieldcat_ausnahme_neg assigning <fc>.
1676                     case <fc>-fieldname.
1677                          when 'BUKRS' or
1678                               'MATNR' or
1679                               'WERKS' or
1680                               'CHARG' or
1681                               'LIFNR' or
1682                               'VBELN' or
1683                               'POSNR'.
1684                               <fc>-no_out = space.
1685                          when others.
1686                               <fc>-no_out = 'X'.
1687                     endcase.
1688                   endloop.
1689
1690          WHEN '09'.   "MSKU-Sätze / K.Leergut
1691                perform text_to_comment using TEXT-209.
1692   *             perform text_to_comment using TEXT-020.
1693   *           WRITE: /4 AUSNAHME_NEG-BUKRS,
1694   *                 AUSNAHME_NEG-MATNR , AUSNAHME_NEG-WERKS,
1695   *                 AUSNAHME_NEG-CHARG , AUSNAHME_NEG-KUNNR.
1696                loop at gt_fieldcat_ausnahme_neg assigning <fc>.
1697                     case <fc>-fieldname.
1698                          when 'BUKRS' or
1699                               'MATNR' or
1700                               'WERKS' or
1701                               'CHARG' or
1702                               'KUNNR'.
1703                               <fc>-no_out = space.
1704                          when others.
1705                               <fc>-no_out = 'X'.
1706                     endcase.
1707                   endloop.
1708
1709          WHEN '10'.   "MSPR-Sätze
1710                perform text_to_comment using TEXT-210.
1711   *             perform text_to_comment using TEXT-027.
1712   *           WRITE: /4 AUSNAHME_NEG-BUKRS,
1713   *                 AUSNAHME_NEG-MATNR , AUSNAHME_NEG-WERKS,
1714   *                 AUSNAHME_NEG-LGORT , AUSNAHME_NEG-CHARG,
1715   *                 AUSNAHME_NEG-PSPNR.
1716                loop at gt_fieldcat_ausnahme_neg assigning <fc>.
1717                     case <fc>-fieldname.
1718                          when 'BUKRS' or
1719                               'MATNR' or
1720                               'WERKS' or
1721                               'LGORT' or
1722                               'CHARG' or
1723                               'PSPNR'.
1724                               <fc>-no_out = space.
1725                          when others.
1726                               <fc>-no_out = 'X'.
1727                     endcase.
1728                   endloop.
1729
1730          WHEN '11'.   "MKOL-Sätze / MTV
1731                perform text_to_comment using TEXT-211.
1732   *             perform text_to_comment using TEXT-014.
1733   *           WRITE: /4 AUSNAHME_NEG-BUKRS,
1734   *                 AUSNAHME_NEG-MATNR , AUSNAHME_NEG-WERKS,
1735   *                 AUSNAHME_NEG-LGORT , AUSNAHME_NEG-CHARG,
1736   *                 AUSNAHME_NEG-LIFNR .
1737                loop at gt_fieldcat_ausnahme_neg assigning <fc>.
1738                     case <fc>-fieldname.
1739                          when 'BUKRS' or
1740                               'MATNR' or
1741                               'WERKS' or
1742                               'LGORT' or
1743                               'CHARG' or
1744                               'LIFNR'.
1745                               <fc>-no_out = space.
1746                          when others.
1747                               <fc>-no_out = 'X'.
1748                     endcase.
1749                   endloop.
1750
1751          WHEN '12'.   "EBEW-Sätze
1752                perform text_to_comment using TEXT-212.
1753   *             perform text_to_comment using TEXT-029.
1754   *           WRITE: /4 AUSNAHME_NEG-BUKRS,
1755   *                 AUSNAHME_NEG-MATNR , AUSNAHME_NEG-BWKEY,
1756   *                 AUSNAHME_NEG-BWTAR ,
1757   *                 AUSNAHME_NEG-VBELN , AUSNAHME_NEG-POSNR.
1758                loop at gt_fieldcat_ausnahme_neg assigning <fc>.
1759                     case <fc>-fieldname.
1760                          when 'BUKRS' or
1761                               'MATNR' or
1762                               'BWKEY' or
1763                               'BWTAR' or
1764                               'VBELN' or
1765                               'POSNR'.
1766                               <fc>-no_out = space.
1767                          when others.
1768                               <fc>-no_out = 'X'.
1769                     endcase.
1770                   endloop.
1771
1772          WHEN '13'.   "QBEW-Sätze
1773                perform text_to_comment using TEXT-213.
1774   *             perform text_to_comment using TEXT-030.
1775   *           WRITE: /4 AUSNAHME_NEG-BUKRS,
1776   *                 AUSNAHME_NEG-MATNR , AUSNAHME_NEG-BWKEY,
1777   *                 AUSNAHME_NEG-BWTAR , AUSNAHME_NEG-PSPNR.
1778                loop at gt_fieldcat_ausnahme_neg assigning <fc>.
1779                     case <fc>-fieldname.
1780                          when 'BUKRS' or
1781                               'MATNR' or
1782                               'BWKEY' or
1783                               'BWTAR' or
1784                               'PSPNR'.
1785                               <fc>-no_out = space.
1786                          when others.
1787                               <fc>-no_out = 'X'.
1788                     endcase.
1789                   endloop.
1790
1791          WHEN '14'.   "WBEW-Sätze
1792                perform text_to_comment using TEXT-214.
1793   *             perform text_to_comment using TEXT-031.
1794   *           WRITE: /4 AUSNAHME_NEG-BUKRS,
1795   *                 AUSNAHME_NEG-MATNR , AUSNAHME_NEG-BWKEY,
1796   *                 AUSNAHME_NEG-BWTAR , AUSNAHME_NEG-MEINH.
1797               loop at gt_fieldcat_ausnahme_neg assigning <fc>.
1798                     case <fc>-fieldname.
1799                          when 'BUKRS' or
1800                               'MATNR' or
1801                               'BWKEY' or
1802                               'BWTAR' or
1803                               'MEINH'.
1804                               <fc>-no_out = space.
1805                          when others.
1806                               <fc>-no_out = 'X'.
1807                     endcase.
1808                   endloop.
1809
1810          WHEN '15'.   "OBEW-S#tze               "ch/4.6A (wg. OBEW)
1811                perform text_to_comment using TEXT-215.
1812   *             perform text_to_comment using TEXT-032.
1813   *           WRITE: /4 AUSNAHME_NEG-BUKRS,
1814   *                 AUSNAHME_NEG-MATNR , AUSNAHME_NEG-BWKEY,
1815   *                 AUSNAHME_NEG-BWTAR , AUSNAHME_NEG-LIFNR.
1816                loop at gt_fieldcat_ausnahme_neg assigning <fc>.
1817                     case <fc>-fieldname.
1818                          when 'BUKRS' or
1819                               'MATNR' or
1820                               'BWKEY' or
1821                               'BWTAR' or
1822                               'LIFNR'.
1823                               <fc>-no_out = space.
1824                          when others.
1825                               <fc>-no_out = 'X'.
1826                     endcase.
1827                   endloop.
1828
1829     ENDCASE.
1830     perform change_event using space.
1831     perform change_event_top_of_page using 'AUSNA_80_TOP'.
1832
1833     clear: gt_log[].
1834     GS_LAYOUT_SBAL-LIST_APPEND = 'X'. "note 1267052
1835     CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
1836       EXPORTING
1837         I_CALLBACK_PROGRAM = GV_REPID
1838         IS_LAYOUT          = GS_LAYOUT_sbal
1839         IT_FIELDCAT        = gt_fieldcat_ausnahme_neg
1840         I_SAVE             = GC_SAVE      "'A'
1841         IT_EVENTS          = GT_EVENTTAB_appends
1842       TABLES
1843         T_OUTTAB           = gt_ausnahme_neg
1844       EXCEPTIONS
1845         PROGRAM_ERROR      = 1
1846         OTHERS             = 2.
1847
1848     IF SY-SUBRC <> 0.
1849        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
1850                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
1851     ENDIF.
1852
1853     clear gt_ausnahme_neg[].
1854   ENDFORM.                    " ausnahme_neg
1855   *&---------------------------------------------------------------------*
1856   *&      Form  text_to_comment
1857   *&---------------------------------------------------------------------*
1858   *       text
1859   *----------------------------------------------------------------------*
1860   *      -->P_TEXT  text
1861   *----------------------------------------------------------------------*
1862   FORM text_to_comment  USING    P_TEXT type any.
1863
1864   data: l_KEY TYPE SLIS_LISTHEADER-KEY,       "Commentary key
1865         L_TDLINE TYPE TLINE-TDLINE.
1866
1867     WRITE P_TEXT to l_tdline.
1868     PERFORM APPEND_COMMENTARY
1869             USING 'S' L_KEY L_TDLINE
1870             changing gt_commentary.
1871
1872   ENDFORM.                    " text_to_comment
1873   *-----------------------------------------------------------------------
1874   *  Note 2186338
1875   *  MESSAGE_STORE
1876   *-----------------------------------------------------------------------
1877   FORM message_store USING VALUE(arbgb)
1878                            VALUE(msgty)
1879                            VALUE(txtnr)
1880                            VALUE(msgv1)
1881                            VALUE(msgv2)
1882                            VALUE(msgv3)
1883                            VALUE(msgv4).
1884
1885     DATA lv_msgv1 TYPE sy-msgv1.
1886     DATA lv_msgv2 TYPE sy-msgv2.
1887     DATA lv_msgv3 TYPE sy-msgv3.
1888     DATA lv_msgv4 TYPE sy-msgv4.
1889
1890     IF arbgb = 'MM' AND txtnr = '899'.
1891       DATA lt_split TYPE TABLE OF char50.
1892       DATA lv_split TYPE char50.
1893       DATA lv_len TYPE int4.
1894       DATA lv_concate TYPE char50.
1895       SPLIT msgv1 AT space INTO TABLE lt_split.
1896
1897       LOOP AT lt_split INTO lv_split.
1898         lv_len = STRLEN( lv_concate ) + STRLEN( lv_split ).
1899         IF lv_len LT 50.
1900           IF lv_concate EQ space.
1901             lv_concate = lv_split.
1902           ELSE.
1903             CONCATENATE lv_concate lv_split INTO lv_concate SEPARATED BY space.
1904           ENDIF.
1905         ELSE.
1906           IF lv_concate EQ space.
1907             lv_concate = lv_split.
1908           ENDIF.
1909           IF lv_msgv1 EQ space.
1910             lv_msgv1 = lv_concate.
1911           ELSEIF lv_msgv2 EQ space.
1912             lv_msgv2 = lv_concate.
1913           ELSEIF lv_msgv3 EQ space.
1914             lv_msgv3 = lv_concate.
1915           ELSEIF lv_msgv4 EQ space.
1916             lv_msgv4 = lv_concate.
1917           ENDIF.
1918           lv_concate = lv_split.
1919         ENDIF.
1920       ENDLOOP.
1921       IF lv_concate NE space.
1922         IF lv_msgv1 EQ space.
1923           lv_msgv1 = lv_concate.
1924         ELSEIF lv_msgv2 EQ space.
1925           lv_msgv2 = lv_concate.
1926         ELSEIF lv_msgv3 EQ space.
1927           lv_msgv3 = lv_concate.
1928         ELSEIF lv_msgv4 EQ space.
1929           lv_msgv4 = lv_concate.
1930         ENDIF.
1931         CLEAR lv_concate.
1932       ENDIF.
1933     ELSE.
1934       lv_msgv1 = msgv1.
1935       lv_msgv2 = msgv2.
1936       lv_msgv3 = msgv3.
1937       lv_msgv4 = msgv4.
1938     ENDIF.
1939
1940      CALL FUNCTION 'MESSAGE_STORE'
1941        EXPORTING
1942          ARBGB                         = arbgb
1943          MSGTY                         = msgty
1944          MSGV1                         = lv_msgv1
1945          MSGV2                         = lv_msgv2
1946          MSGV3                         = lv_msgv3
1947          MSGV4                         = lv_msgv4
1948          TXTNR                         = txtnr
1949        EXCEPTIONS
1950          OTHERS                        = 1.
1951
1952      IF SY-SUBRC <> 0.
1953      ENDIF.
1954
1955   ENDFORM.                    " message_store
*--- End of MM13QF50 - 1955 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CSLIS                                   Level 1    Page 9
Object           Z_DEL_HIST_ENTRIES                        Lines 543
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:32
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
Generated incl.  <REPINI>                                  Level 1    Page 10
Object           Z_DEL_HIST_ENTRIES                        Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:32
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
Generated incl.  <SYSINI>                                  Level 1    Page 11
Object           Z_DEL_HIST_ENTRIES                        Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:32
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
Generated incl.  <SYSSEL>                                  Level 1    Page 12
Object           Z_DEL_HIST_ENTRIES                        Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:32
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
Generated incl.  DB__SSEL                                  Level 1    Page 13
Object           Z_DEL_HIST_ENTRIES                        Lines 1
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:32
----------------------------------------------------------------------------------------------------
1      * INCLUDE DB__SSEL
*--- End of DB__SSEL - 1 lines ---
