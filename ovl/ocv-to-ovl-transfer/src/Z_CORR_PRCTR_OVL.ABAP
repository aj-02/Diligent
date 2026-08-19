----------------------------------------------------------------------------------------------------
Main program     Z_CORR_PRCTR_OVL                          Level 0    Page 1
Object           Z_CORR_PRCTR_OVL                          Lines 647
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:31
----------------------------------------------------------------------------------------------------
1      REPORT z_corr_prctr .
2      TABLES: bseg,
3      *        bkpf,
4      *        bvor,
5              bsid,
6              bsik,
7              bsis,
8              bsad,
9              bsak,
10             bsas,
11             t8a30,
12             glpca.
13
14     PARAMETER: p_bukrs LIKE glpca-rbukrs OBLIGATORY,
15                p_year  LIKE glpca-ryear OBLIGATORY,
16                p_period LIKE glpca-poper OBLIGATORY.
17
18     SELECT-OPTIONS s_refdoc FOR glpca-refdocnr OBLIGATORY.
19
20     PARAMETER: real_run LIKE boole-boole DEFAULT 'X'.
21     RANGES: r_awkey FOR bkpf-awkey,
22             r_hkont FOR glpca-racct,
23             r_belnr FOR bseg-belnr.
24
25     DATA: it_bseg  LIKE bseg OCCURS 100 WITH HEADER LINE,
26           it_glpca LIKE glpca OCCURS 100 WITH HEADER LINE,
27           it_final LIKE glpca OCCURS 100 WITH HEADER LINE,
28           it_bkpf  LIKE bkpf OCCURS 100 WITH HEADER LINE,
29           it_bkpf1  LIKE bkpf OCCURS 100 WITH HEADER LINE,
30           it_bkpf2  LIKE bkpf OCCURS 100 WITH HEADER LINE,
31           it_bkpf3  LIKE bkpf OCCURS 100 WITH HEADER LINE,
32           it_zpc_coba LIKE zpc_coba OCCURS 100 WITH HEADER LINE.
33     DATA:   bdcdata LIKE bdcdata    OCCURS 0 WITH HEADER LINE.
34     DATA:   messtab LIKE bdcmsgcoll OCCURS 0 WITH HEADER LINE.
35
36     DATA: BEGIN OF it_doc OCCURS 0,
37           docnr LIKE glpca-docnr,
38           refdocnr LIKE glpca-refdocnr,
39          refryear LIKE glpca-refryear,
40          refdocln LIKE glpca-refdocln ,
41          awtyp   LIKE glpca-awtyp,
42          refactiv LIKE glpca-refactiv,
43          docct  LIKE glpca-docct,
44          aworg LIKE glpca-aworg,
45           END OF it_doc.
46
47
48
49     *DATA: l_prctr  LIKE bseg-prctr.
50     *      dbfields TYPE TABLE OF dbfield WITH HEADER LINE,
51     *      l_condi  TYPE string.
52     *      l_subrc  TYPE sy-subrc.
53     *      l_tabname TYPE dd02l-tabname.
54     DATA: wa_bseg LIKE bseg.
55     DATA: wa_glpca1 LIKE glpca.
56     DATA: wa_glpca2 LIKE glpca.
57     DATA: db_change TYPE i.
58     DATA: c_max TYPE i VALUE 1000.
59     DATA:l_tsl(19).
60     DATA: last_day LIKE sy-datum.
61     DATA: l_day1(10).
62     DATA: msg(256).
63     DATA: l_docnr LIKE glpca-docnr.
64     DATA: g_sirid TYPE glpca-gl_sirid.
65     DATA: g_monat TYPE monat.
66
67
68     g_monat = p_period+1(2).
69     SELECT * FROM glpca INTO TABLE it_glpca
70        WHERE rbukrs  = p_bukrs
71          AND ryear  = p_year
72          AND poper = p_period
73          AND refdocnr IN s_refdoc
74          AND rprctr = 'OVL_DUMMY'.
75
76     LOOP AT it_glpca.
77       CLEAR r_awkey.
78       r_awkey-sign = 'I'.
79       r_awkey-option = 'EQ'.
80       CONCATENATE it_glpca-refdocnr '%' INTO r_awkey-low .
81       APPEND r_awkey.
82
83       CLEAR r_hkont.
84       r_hkont-sign = 'I'.
85       r_hkont-option = 'EQ'.
86       r_hkont-low = it_glpca-racct.
87       APPEND r_hkont.
88     ENDLOOP.
89
90     SORT r_awkey BY low.
91     DELETE ADJACENT DUPLICATES FROM r_awkey COMPARING  low.
92
93     LOOP AT r_awkey.
94       SELECT * FROM bkpf APPENDING TABLE it_bkpf1
95          WHERE bukrs  = p_bukrs
96            AND gjahr  = p_year
97            AND monat = g_monat "p_period
98            AND awtyp IN ('VBRK','HRPAY','BKPF','MKPF' , 'AMBU' )
99            AND awkey LIKE r_awkey-low."IN r_awkey.
100      IF sy-subrc <> 0.
101        SELECT * FROM bkpf APPENDING TABLE it_bkpf2
102           WHERE bukrs  = p_bukrs
103             AND gjahr  = p_year
104             AND monat = g_monat "p_period
105             AND   awtyp = 'RMRP'
106             AND awkey LIKE r_awkey-low."IN r_awkey.
107        IF sy-subrc <> 0.
108          SELECT * FROM bkpf APPENDING TABLE it_bkpf3
109             WHERE bukrs  = p_bukrs
110               AND gjahr  = p_year
111               AND monat = g_monat " p_period
112               AND   awtyp = 'AUAK'
113               AND awkey LIKE r_awkey-low."IN r_awkey.
114        ENDIF.
115      ENDIF.
116    ENDLOOP.
117
118    APPEND LINES OF it_bkpf1[] TO it_bkpf[].
119    APPEND LINES OF it_bkpf2[] TO it_bkpf[].
120    APPEND LINES OF it_bkpf3[] TO it_bkpf[].
121
122    LOOP AT it_bkpf.
123      CLEAR r_belnr.
124      r_belnr-sign = 'I'.
125      r_belnr-option = 'EQ'.
126      r_belnr-low = it_bkpf-belnr.
127      APPEND r_belnr.
128    ENDLOOP.
129
130    SELECT * FROM zpc_coba INTO TABLE it_zpc_coba
131         WHERE bukrs = p_bukrs.
132
133    SELECT * FROM bseg INTO TABLE it_bseg
134       WHERE bukrs  = p_bukrs
135        AND belnr IN r_belnr
136         AND gjahr  = p_year
137         AND hkont  IN r_hkont.
138    *Start Changes by SAB_RAMESH on 09.10.2006
139    *     AND ( koart = 'S' OR koart = 'A' )
140    *     AND (  prctr = 'ONGC_DUMMY' OR prctr = '' ).
141
142
143    DELETE it_bseg WHERE ( koart <> 'S' OR koart <> 'A' ).
144    DELETE it_bseg WHERE ( prctr <> 'OVL_DUMMY' OR prctr <> '' ).
145    *End  Changes by SAB_RAMESH on 09.10.2006
146
147    IF real_run = 'X'.
148      LOOP AT it_bseg INTO wa_bseg.
149
150    *    SELECT SINGLE * FROM t8a30
151    *      WHERE kokrs     = wa_bseg-kokrs
152    *      AND   konto_von <= wa_bseg-hkont
153    *      AND   konto_bis >= wa_bseg-hkont.
154        SELECT * FROM t8a30 UP TO 1 ROWS
155          WHERE kokrs     = wa_bseg-kokrs
156          AND   konto_von <= wa_bseg-hkont
157          AND   konto_bis >= wa_bseg-hkont ORDER BY PRIMARY KEY. ENDSELECT.
158        IF sy-subrc <> 0.
159
160          WRITE: / 'document', bseg-belnr,
161      ': No T8A30 entry found FOR ACCOUNT', bseg-hkont.
162
163        ELSE.
164
165          IF t8a30-prctr = 'OVL_DUMMY'.
166
167    *      CLEAR l_prctr.
168
169    *      SELECT SINGLE prctr INTO l_prctr FROM zpc_coba
170    *        WHERE bukrs = wa_bseg-bukrs AND
171    *              gsber = wa_bseg-gsber.
172            CLEAR it_zpc_coba.
173            READ TABLE it_zpc_coba WITH KEY bukrs = wa_bseg-bukrs
174                                            gsber = wa_bseg-gsber.
175            IF sy-subrc = 0.
176    *        wa_bseg-prctr = l_prctr.
177              wa_bseg-prctr = it_zpc_coba-prctr.
178              UPDATE bseg FROM wa_bseg.
179              COMMIT WORK.
180
181              IF wa_bseg-xkres = 'X'.
182                PERFORM correct_index.
183              ENDIF.
184
185            ENDIF.
186
187          ENDIF.
188
189
190          ADD 1 TO db_change.
191          IF db_change >= c_max.
192            CALL FUNCTION 'DB_COMMIT'.
193            db_change = 0.
194          ENDIF.
195
196        ENDIF.
197
198      ENDLOOP.
199
200      LOOP AT it_glpca.
201        CLEAR : it_zpc_coba,wa_glpca1,wa_glpca2.
202
203        wa_glpca1 = wa_glpca2 = it_glpca.
204
205        wa_glpca1-hsl = wa_glpca1-hsl * -1.
206        APPEND wa_glpca1 TO it_final.
207
208        READ TABLE it_zpc_coba WITH KEY bukrs = wa_glpca2-rbukrs
209                                        gsber = wa_glpca2-gsber.
210        IF sy-subrc = 0.
211          wa_glpca2-rprctr = it_zpc_coba-prctr.
212          APPEND wa_glpca2 TO it_final.
213        ELSE.
214        WRITE:/ 'No Profit Center for' , wa_glpca2-rbukrs, wa_glpca2-gsber , "#EC CI_NOORDER
215                    'In Table ZPC_COBA'.  "#EC CI_NOORDER
216          APPEND wa_glpca2 TO it_final.
217        ENDIF.
218
219      ENDLOOP.
220
221      LOOP AT it_bseg INTO wa_bseg.
222        WRITE: / wa_bseg-bukrs, wa_bseg-belnr, wa_bseg-buzei,  "#EC CI_NOORDER
223                 wa_bseg-prctr, wa_bseg-dmbtr CURRENCY ''. "#EC CI_FLDEXT_OK[2610650]
224      ENDLOOP.
225
226      CALL FUNCTION 'BAPI_COAREA_GETPERIODLIMITS'
227        EXPORTING
228          controllingareaid         = 'ONGC'
229          fiscal_period             = g_monat
230          fiscal_year               = p_year
231       IMPORTING
232    *   FIRST_DAY_OF_PERIOD       =
233         last_day_of_period        = last_day
234    *   LAST_NORMAL_PERIOD        =
235    *   RETURN                    =
236                .
237
238      WRITE last_day TO l_day1 DD/MM/YYYY.
239
240      LOOP AT it_final.
241        REFRESH messtab.
242        CLEAR l_tsl.
243        l_tsl = it_final-hsl.
244        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
245             EXPORTING
246                  input  = l_tsl
247             IMPORTING
248                  output = l_tsl.
249        CONDENSE l_tsl NO-GAPS.
250
251        PERFORM bdc_dynpro      USING 'SAPMGBUK' '0202'.
252        PERFORM bdc_field       USING 'BDC_CURSOR'
253                                      'GLU1-RTCUR'.
254        PERFORM bdc_field       USING 'BDC_OKCODE'
255                                      '/00'.
256        PERFORM bdc_field       USING 'GLU1-BUKRS'
257                                      it_final-rbukrs.
258        PERFORM bdc_field       USING 'GLU1-DOCTY'
259                                      'MA'.
260        PERFORM bdc_field       USING 'GLU1-RTCUR'
261                                      'INR'.
262        PERFORM bdc_field       USING 'RGBUK-DATE'
263                                      l_day1.
264
265        PERFORM bdc_dynpro      USING 'SAPMGBUK' '0110'.
266        PERFORM bdc_field       USING 'BDC_CURSOR'
267                                      'RGBUK-O_V02'.
268        PERFORM bdc_field       USING 'BDC_OKCODE'
269                                      '=DOWN'.
270        PERFORM bdc_field       USING 'GLU1-TSL'
271                                      l_tsl.
272        PERFORM bdc_field       USING 'RGBUK-O_V01'
273                                      it_final-rprctr.
274        PERFORM bdc_field       USING 'RGBUK-O_V02'
275                                      it_final-racct.
276        PERFORM bdc_field       USING 'RGBUK-O_V04'
277                                      '00'.
278        PERFORM bdc_field       USING 'RGBUK-O_V07'
279                                      '00'.
280
281        PERFORM bdc_dynpro      USING 'SAPMGBUK' '0110'.
282        PERFORM bdc_field       USING 'BDC_CURSOR'
283                                      'GLU1-SGTXT'.
284        PERFORM bdc_field       USING 'BDC_OKCODE'
285                                      '/00'.
286        PERFORM bdc_field       USING 'GLU1-TSL'
287                                      l_tsl.
288        PERFORM bdc_field       USING 'RGBUK-O_V01'
289                                      '00'.
290        PERFORM bdc_field       USING 'RGBUK-O_V04'
291                                      '00'.
292        PERFORM bdc_field       USING 'RGBUK-O_V08'
293                                      '00.00.0000'.
294        PERFORM bdc_field       USING 'GLU1-SGTXT'
295                                      'Entries to tally GL to PCA'.
296
297        PERFORM bdc_dynpro      USING 'SAPMGBUK' '0110'.
298        PERFORM bdc_field       USING 'BDC_CURSOR'
299                                      'GLU1-TSL'.
300        PERFORM bdc_field       USING 'BDC_OKCODE'
301                                      '=BOOK'.
302        PERFORM bdc_field       USING 'GLU1-TSL'
303                                      l_tsl.
304        PERFORM bdc_field       USING 'RGBUK-O_V01'
305                                      '00'.
306        PERFORM bdc_field       USING 'RGBUK-O_V04'
307                                      '00'.
308        PERFORM bdc_field       USING 'RGBUK-O_V08'
309                                      '00.00.0000'.
310        PERFORM bdc_field       USING 'GLU1-SGTXT'
311                                      'Entries to tally GL to PCA'.
312        PERFORM bdc_transaction USING '1KEL'.
313        REFRESH bdcdata.
314        IF NOT messtab[] IS INITIAL.
315          LOOP AT messtab." WHERE msgtyp = 'E'.
316
317            CALL FUNCTION 'FORMAT_MESSAGE'
318                 EXPORTING
319                      id        = messtab-msgid
320                      lang      = 'EN'
321                      no        = messtab-msgnr
322                      v1        = messtab-msgv1
323                      v2        = messtab-msgv2
324                      v3        = messtab-msgv3
325                      v4        = messtab-msgv4
326                 IMPORTING
327                      msg       = msg
328                 EXCEPTIONS
329                      not_found = 1
330                      OTHERS    = 2.
331            IF sy-subrc <> 0.
332              MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
333                      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
334            ENDIF.
335            IF messtab-msgtyp = 'E'.
336              WRITE:/ msg.
337            ENDIF.
338            IF msg+0(38) = 'Document posted under document number '.
339              l_docnr = msg+38(10).
340              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
341                   EXPORTING
342                        input  = l_docnr
343                   IMPORTING
344                        output = l_docnr.
345
346              it_doc-docnr = l_docnr.
347              it_doc-refdocnr = it_final-refdocnr.
348              it_doc-refryear = it_final-refryear.
349              it_doc-refdocln = it_final-refdocln.
350              it_doc-awtyp   = it_final-awtyp.
351              it_doc-refactiv = it_final-refactiv.
352              it_doc-docct   = it_final-docct.
353              it_doc-aworg   = it_final-aworg.
354              APPEND it_doc.
355            ENDIF.
356          ENDLOOP.
357        ENDIF.
358      ENDLOOP.
359
360      LOOP AT it_doc.
361        CLEAR:g_sirid.
362
363    *    SELECT SINGLE gl_sirid INTO g_sirid FROM glpca
364    *     WHERE docnr = it_doc-docnr
365    *       AND rbukrs = p_bukrs
366    *       AND ryear  = p_year.
367        SELECT gl_sirid INTO g_sirid FROM glpca UP TO 1 ROWS
368         WHERE docnr = it_doc-docnr
369           AND rbukrs = p_bukrs
370           AND ryear  = p_year ORDER BY PRIMARY KEY. ENDSELECT.
371        IF sy-subrc = 0.
372          UPDATE glpca SET refdocnr = it_doc-refdocnr
373                           refryear = it_doc-refryear
374                           refdocln = it_doc-refdocln
375                           awtyp    = it_doc-awtyp
376                           refactiv = it_doc-refactiv
377                           docct    = it_doc-docct
378                           aworg    = it_doc-aworg
379           WHERE gl_sirid = g_sirid.
380          COMMIT WORK.
381        ENDIF.
382      ENDLOOP.
383    ENDIF.
384    *---------------------------------------------------------------------*
385    *       FORM correct_index                                            *
386    *---------------------------------------------------------------------*
387    *       ........                                                      *
388    *---------------------------------------------------------------------*
389    FORM correct_index.
390
391    IF bseg-augbl = '  '.
392      CASE bseg-koart.
393        WHEN 'D'.
394          SELECT SINGLE * FROM bsid
395                                WHERE bukrs = wa_bseg-bukrs
396                                AND   kunnr = wa_bseg-kunnr
397                                AND   umsks = wa_bseg-umsks
398                                AND   umskz = wa_bseg-umskz
399                                AND   augdt = wa_bseg-augdt
400                                AND   augbl = wa_bseg-augbl
401                                AND   zuonr = wa_bseg-zuonr
402                                AND   gjahr = wa_bseg-gjahr
403                                AND   belnr = wa_bseg-belnr
404                                AND   buzei = wa_bseg-buzei.
405          IF sy-subrc = 0.
406            MOVE-CORRESPONDING wa_bseg TO bsid.
407    *        UPDATE bsid.
408            IF sy-dbcnt <> 1.
409              MESSAGE a500(fe) WITH 'Fehler'.
410            ENDIF.
411          ELSE.
412            WRITE: / 'BSID entry for BELNR ', bseg-belnr, 'not found!'.
413          ENDIF.
414          IF wa_bseg-xhres = 'X'.
415            PERFORM sonderhauptbuch_bsis_index.
416          ENDIF.
417        WHEN 'K'.
418          SELECT SINGLE * FROM bsik
419                                WHERE bukrs = wa_bseg-bukrs
420                                AND   lifnr = wa_bseg-lifnr
421                                AND   umsks = wa_bseg-umsks
422                                AND   umskz = wa_bseg-umskz
423                                AND   augdt = wa_bseg-augdt
424                                AND   augbl = wa_bseg-augbl
425                                AND   zuonr = wa_bseg-zuonr
426                                AND   gjahr = wa_bseg-gjahr
427                                AND   belnr = wa_bseg-belnr
428                                AND   buzei = wa_bseg-buzei.
429          IF sy-subrc = 0.
430            MOVE-CORRESPONDING wa_bseg TO bsik.
431    *        UPDATE bsik.
432            IF sy-dbcnt <> 1.
433              MESSAGE a500(fe) WITH 'Fehler'.
434            ENDIF.
435          ELSE.
436            WRITE: / 'BSIK entry for BELNR ', wa_bseg-belnr, 'not found!'.
437          ENDIF.
438          IF wa_bseg-xhres = 'X'.
439            PERFORM sonderhauptbuch_bsis_index.
440          ENDIF.
441        WHEN 'S'.
442          SELECT SINGLE * FROM bsis
443                                WHERE bukrs = wa_bseg-bukrs
444                                AND   hkont = wa_bseg-hkont
445                                AND   augdt = wa_bseg-augdt
446                                AND   augbl = wa_bseg-augbl
447                                AND   zuonr = wa_bseg-zuonr
448                                AND   gjahr = wa_bseg-gjahr
449                                AND   belnr = wa_bseg-belnr
450                                AND   buzei = wa_bseg-buzei.
451          IF sy-subrc = 0.
452            MOVE-CORRESPONDING wa_bseg TO bsis.
453    *        UPDATE bsis.
454            IF sy-dbcnt <> 1.
455              MESSAGE a500(fe) WITH 'Fehler'.
456            ENDIF.
457          ELSE.
458            WRITE: / 'BSIS entry for BELNR ', wa_bseg-belnr, 'not found!'.
459          ENDIF.
460      ENDCASE.
461    ELSE.
462      CASE wa_bseg-koart.
463        WHEN 'D'.
464          SELECT SINGLE * FROM bsad
465                                WHERE bukrs = wa_bseg-bukrs
466                                AND   kunnr = wa_bseg-kunnr
467                                AND   umsks = wa_bseg-umsks
468                                AND   umskz = wa_bseg-umskz
469                                AND   augdt = wa_bseg-augdt
470                                AND   augbl = wa_bseg-augbl
471                                AND   zuonr = wa_bseg-zuonr
472                                AND   gjahr = wa_bseg-gjahr
473                                AND   belnr = wa_bseg-belnr
474                                AND   buzei = wa_bseg-buzei.
475          IF sy-subrc = 0.
476            MOVE-CORRESPONDING wa_bseg TO bsad.
477    *        UPDATE bsad.
478            IF sy-dbcnt <> 1.
479              MESSAGE a500(fe) WITH 'Fehler'.
480            ENDIF.
481          ELSE.
482            WRITE: / 'BSAD entry for BELNR ', wa_bseg-belnr, 'not found!'.
483          ENDIF.
484          IF wa_bseg-xhres = 'X'.
485            PERFORM sonderhauptbuch_bsas_index.
486          ENDIF.
487        WHEN 'K'.
488          SELECT SINGLE * FROM bsak
489                                WHERE bukrs = wa_bseg-bukrs
490                                AND   lifnr = wa_bseg-lifnr
491                                AND   umsks = wa_bseg-umsks
492                                AND   umskz = wa_bseg-umskz
493                                AND   augdt = wa_bseg-augdt
494                                AND   augbl = wa_bseg-augbl
495                                AND   zuonr = wa_bseg-zuonr
496                                AND   gjahr = wa_bseg-gjahr
497                                AND   belnr = wa_bseg-belnr
498                                AND   buzei = wa_bseg-buzei.
499          IF sy-subrc = 0.
500            MOVE-CORRESPONDING wa_bseg TO bsak.
501    *        UPDATE bsak.
502            IF sy-dbcnt <> 1.
503              MESSAGE a500(fe) WITH 'Fehler'.
504            ENDIF.
505          ELSE.
506            WRITE: / 'BSAK entry for BELNR ', wa_bseg-belnr, 'not found!'.
507          ENDIF.
508          IF wa_bseg-xhres = 'X'.
509            PERFORM sonderhauptbuch_bsas_index.
510          ENDIF.
511        WHEN 'S'.
512          SELECT SINGLE * FROM bsas
513                                WHERE bukrs = wa_bseg-bukrs
514                                AND   hkont = wa_bseg-hkont
515                                AND   augdt = wa_bseg-augdt
516                                AND   augbl = wa_bseg-augbl
517                                AND   zuonr = wa_bseg-zuonr
518                                AND   gjahr = wa_bseg-gjahr
519                                AND   belnr = wa_bseg-belnr
520                                AND   buzei = wa_bseg-buzei.
521          IF sy-subrc = 0.
522            MOVE-CORRESPONDING wa_bseg TO bsas.
523    *        UPDATE bsas.
524            IF sy-dbcnt <> 1.
525              MESSAGE a500(fe) WITH 'Fehler'.
526            ENDIF.
527          ELSE.
528            WRITE: / 'BSAS entry for BELNR ', wa_bseg-belnr, 'not found!'.
529          ENDIF.
530      ENDCASE.
531    ENDIF.
532    ENDFORM.
533    *---------------------------------------------------------------------*
534    *       FORM sonderhauptbuch_bsis_index                               *
535    *---------------------------------------------------------------------*
536    *       ........                                                      *
537    *---------------------------------------------------------------------*
538    FORM sonderhauptbuch_bsis_index.
539      SELECT SINGLE * FROM bsis
540                            WHERE bukrs = wa_bseg-bukrs
541                            AND   hkont = wa_bseg-hkont
542                            AND   augdt = wa_bseg-augdt
543                            AND   augbl = wa_bseg-augbl
544                            AND   zuonr = wa_bseg-hzuon
545                            AND   gjahr = wa_bseg-gjahr
546                            AND   belnr = wa_bseg-belnr
547                            AND   buzei = wa_bseg-buzei.
548      IF sy-subrc = 0.
549        MOVE-CORRESPONDING wa_bseg TO bsis.
550        bsis-zuonr = wa_bseg-hzuon.
551    *    UPDATE bsis.
552        IF sy-dbcnt <> 1.
553          MESSAGE a500(fe) WITH 'Fehler'.
554        ENDIF.
555      ELSE.
556        WRITE: / 'BSIS entry for BELNR ', wa_bseg-belnr, 'not found!'.
557      ENDIF.
558    ENDFORM.
559    *---------------------------------------------------------------------*
560    *       FORM sonderhauptbuch_bsas_index                               *
561    *---------------------------------------------------------------------*
562    *       ........                                                      *
563    *---------------------------------------------------------------------*
564    FORM sonderhauptbuch_bsas_index.
565      SELECT SINGLE * FROM bsas
566                            WHERE bukrs = wa_bseg-bukrs
567                            AND   hkont = wa_bseg-hkont
568                            AND   augdt = wa_bseg-augdt
569                            AND   augbl = wa_bseg-augbl
570                            AND   zuonr = wa_bseg-hzuon
571                            AND   gjahr = wa_bseg-gjahr
572                            AND   belnr = wa_bseg-belnr
573                            AND   buzei = wa_bseg-buzei.
574      IF sy-subrc = 0.
575        MOVE-CORRESPONDING wa_bseg TO bsas.
576        bsas-zuonr = wa_bseg-hzuon.
577    *    UPDATE bsas.
578        IF sy-dbcnt <> 1.
579          MESSAGE a500(fe) WITH 'Fehler'.
580        ENDIF.
581      ELSE.
582        WRITE: / 'BSAS entry for BELNR ', wa_bseg-belnr, 'not found!'.
583      ENDIF.
584    ENDFORM.
585
586    *---------------------------------------------------------------------*
587    *       FORM bdc_dynpro                                               *
588    *---------------------------------------------------------------------*
589    *       ........                                                      *
590    *---------------------------------------------------------------------*
591    *  -->  PROGRAM                                                       *
592    *  -->  DYNPRO                                                        *
593    *---------------------------------------------------------------------*
594    FORM bdc_dynpro USING program dynpro.
595      CLEAR bdcdata.
596      bdcdata-program  = program.
597      bdcdata-dynpro   = dynpro.
598      bdcdata-dynbegin = 'X'.
599      APPEND bdcdata.
600    ENDFORM.
601
602    *----------------------------------------------------------------------*
603    *        Insert field                                                  *
604    *----------------------------------------------------------------------*
605    FORM bdc_field USING fnam fval.
606      CLEAR bdcdata.
607      bdcdata-fnam = fnam.
608      bdcdata-fval = fval.
609      APPEND bdcdata.
610    ENDFORM.
611
612    *&---------------------------------------------------------------------*
613    *&      Form  bdc_transaction
614    *&---------------------------------------------------------------------*
615    FORM bdc_transaction USING tcode.
616    *  DATA: l_mstring(480).
617    *  DATA: l_subrc LIKE sy-subrc.
618    *  DATA: l_mode VALUE 'N'.
619    *  DATA: l_upd VALUE 'S'.
620      DATA:wa_ctu_params TYPE ctu_params.
621      wa_ctu_params-dismode = 'N'.
622      wa_ctu_params-updmode = 'S'.
623      wa_ctu_params-cattmode = ''.
624      wa_ctu_params-defsize = 'X'.
625      wa_ctu_params-racommit = 'X'.
626      wa_ctu_params-nobinpt = ''.
627      wa_ctu_params-nobiend = ''.
628      CALL TRANSACTION tcode USING bdcdata
629    *                   UPDATE l_upd
630    *                   MODE   l_mode
631                       OPTIONS FROM wa_ctu_params
632                       MESSAGES INTO messtab.
633    *  CALL FUNCTION 'BDC_INSERT'
634    *       EXPORTING
635    *            tcode            = tcode
636    *       TABLES
637    *            dynprotab        = bdcdata
638    *       EXCEPTIONS
639    *            internal_error   = 1
640    *            not_open         = 2
641    *            queue_error      = 3
642    *            tcode_invalid    = 4
643    *            printing_invalid = 5
644    *            posting_invalid  = 6
645    *            OTHERS           = 7.
646
647    ENDFORM.                    " bdc_transaction
*--- End of Z_CORR_PRCTR_OVL - 647 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  <REPINI>                                  Level 1    Page 2
Object           Z_CORR_PRCTR_OVL                          Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:31
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
Generated incl.  <SYSINI>                                  Level 1    Page 3
Object           Z_CORR_PRCTR_OVL                          Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:31
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
Generated incl.  <SYSSEL>                                  Level 1    Page 4
Object           Z_CORR_PRCTR_OVL                          Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:31
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
Generated incl.  DB__SSEL                                  Level 1    Page 5
Object           Z_CORR_PRCTR_OVL                          Lines 1
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:31
----------------------------------------------------------------------------------------------------
1      * INCLUDE DB__SSEL
*--- End of DB__SSEL - 1 lines ---
