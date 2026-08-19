----------------------------------------------------------------------------------------------------
Main program     Z_CORR_PRCTR2                             Level 0    Page 1
Object           Z_CORR_PRCTR2                             Lines 645
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:29
----------------------------------------------------------------------------------------------------
1      REPORT z_corr_prctr2 .
2
3      TABLES: bseg,
4              bkpf,
5              bvor,
6              bsid,
7              bsik,
8              bsis,
9              bsad,
10             bsak,
11             bsas,
12             t8a30,
13             glpca.
14
15     DATA: ibseg LIKE bseg OCCURS 100 WITH HEADER LINE.
16     DATA: kbseg LIKE bseg OCCURS 100 WITH HEADER LINE.
17     DATA: bbseg LIKE bseg OCCURS 100 WITH HEADER LINE.
18     DATA: it_tkedrs LIKE tkedrs OCCURS 20 WITH HEADER LINE.
19     DATA: s_bvorg LIKE bvor-bvorg.
20     DATA: counter TYPE i VALUE IS INITIAL.
21     DATA: c_max TYPE i VALUE 1000.
22     DATA: db_change TYPE i.
23
24     *----------------------------------------------------------------------*
25     *   data definition
26     *----------------------------------------------------------------------*
27     *       Batchinputdata of single transaction
28     DATA:   BDCDATA LIKE BDCDATA    OCCURS 0 WITH HEADER LINE.
29     *       messages of call transaction
30     DATA:   MESSTAB LIKE BDCMSGCOLL OCCURS 0 WITH HEADER LINE.
31     *       error session opened (' ' or 'X')
32     DATA:   E_GROUP_OPENED.
33     *       message texts
34     TABLES: T100.
35
36     *Selection fields for GLPCA documents
37     SELECT-OPTIONS s_rbukrs FOR glpca-rbukrs.
38     SELECT-OPTIONS s_ryear  FOR glpca-ryear.
39     SELECT-OPTIONS s_refdoc FOR glpca-refdocnr.
40
41     PARAMETER: overwrt LIKE boole-boole DEFAULT space.
42     PARAMETER: real_run LIKE boole-boole DEFAULT space.
43
44     SELECT * FROM glpca
45           WHERE rbukrs   IN s_rbukrs
46           AND   ryear    IN s_ryear
47           AND   rldnr    = '8A'
48           AND   refdocnr IN s_refdoc.
49     *      AND   STFLG    = SPACE
50     *      AND   STOKZ    NE SPACE.
51
52     *FI line item
53       SELECT SINGLE * FROM bkpf
54           WHERE belnr = glpca-refdocnr
55           AND   bukrs = glpca-aworg+00(04)
56           AND   gjahr = glpca-aworg+04(04).
57       IF bkpf-bvorg NE space.              "Cross company Posting
58     *    SELECT SINGLE * FROM bvor
59     *        WHERE bvorg = bkpf-bvorg
60     *          AND bukrs = glpca-rbukrs.
61             SELECT * FROM bvor UP TO 1 ROWS
62             WHERE bvorg = bkpf-bvorg
63               AND bukrs = glpca-rbukrs ORDER BY PRIMARY KEY. ENDSELECT.
64         SELECT * FROM bseg
65           WHERE belnr = bvor-belnr
66           AND   bukrs = bvor-bukrs
67           AND   gjahr = bvor-gjahr.
68           glpca-hsl = abs( glpca-hsl ).
69           IF bseg-hkont = glpca-racct
70           AND bseg-fkber = glpca-rfarea
71           AND bseg-gsber = glpca-gsber
72           AND bseg-shkzg = glpca-drcrk
73           AND bseg-dmbtr = glpca-hsl.
74             MOVE-CORRESPONDING bseg TO bbseg.
75             APPEND bbseg.
76           ENDIF.
77         ENDSELECT.
78         IF sy-subrc <> 0.
79           WRITE: / 'No BVOR entry found'.
80         ENDIF.
81         DESCRIBE TABLE bbseg LINES sy-tfill.
82         IF sy-tfill NE 1.
83           WRITE: / 'BSEG entry from cross company doc', bvor-bvorg,
84           'is not unique. Special analysis required!'.
85         ELSE.
86           LOOP AT bbseg.
87             MOVE-CORRESPONDING bbseg TO bseg.
88             PERFORM get_profit_center_crosscomp.
89           ENDLOOP.
90         ENDIF.
91         REFRESH bbseg.
92       ELSE.
93         SELECT SINGLE * FROM  bseg
94                WHERE  bukrs       = bkpf-bukrs
95                AND    belnr       = bkpf-belnr
96                AND    gjahr       = bkpf-gjahr
97                AND    buzei       = glpca-refdocln.
98         IF sy-subrc <> 0.
99           WRITE: / 'No BSEG entry found'.
100        ELSE.
101          PERFORM get_profit_center.
102        ENDIF.
103      ENDIF.
104    ENDSELECT.
105    IF sy-subrc <> 0.
106      WRITE: / 'No GLPCA entry found'.
107      EXIT.
108    ENDIF.
109
110    *List or update
111    IF real_run = 'X'.
112      PERFORM update_line_items.
113      ULINE.
114      WRITE: /'Corrected line items:', counter.
115      ULINE.
116
117      IF NOT kbseg[] IS INITIAL.
118
119    *    SUBMIT rgurec10 VIA SELECTION-SCREEN
120    *             WITH bukrs IN s_rbukrs
121    *             WITH gjahr IN s_ryear
122    *             WITH rbelnr IN s_refdoc
123    *             WITH test EQ ' '
124    *             WITH list EQ 'X'
125    *             WITH pruefen EQ ' '
126    *             WITH storno EQ 'X'
127    *             WITH mm_sd EQ 'X' AND RETURN.
128
129        LOOP AT kbseg.
130
131        refresh bdcdata.
132
133        perform bdc_dynpro      using 'RGUREC10' '1000'.
134        perform bdc_field       using 'BDC_CURSOR'
135                                      'MM_SD'.
136        perform bdc_field       using 'BDC_OKCODE'
137                                      '=ONLI'.
138        perform bdc_field       using 'BUKRS-LOW'
139                                      kbseg-bukrs.  "'MUM'.
140        perform bdc_field       using 'GJAHR-LOW'
141                                      kbseg-gjahr.  "'2004'.
142        perform bdc_field       using 'RBELNR-LOW'
143                                      kbseg-BELNR.  "'1003000001'.
144        perform bdc_field       using 'TEST'
145                                      ''.
146        perform bdc_field       using 'LIST'
147                                      'X'.
148        perform bdc_field       using 'PRUEFEN'
149                                      ''.
150        perform bdc_field       using 'STORNO'
151                                      'X'.
152        perform bdc_field       using 'MM_SD'
153                                      'X'.
154        perform bdc_transaction using '1KE8'.
155
156
157
158        ENDLOOP.
159
160      ENDIF.
161
162    ELSE.
163      PERFORM print_line_items.
164      ULINE.
165      WRITE: /'Line items for correction:', counter.
166      ULINE.
167    ENDIF.
168
169    *   *
170    *	       FORM Get_profit_center	*
171    *   *
172    *	       ........	*
173    *   *
174    FORM get_profit_center.
175
176    *Get profit center (prctr) from PCA document corrected with 1KE8
177    SELECT SINGLE * FROM glpca
178    WHERE rbukrs = bseg-bukrs
179    AND   ryear  = bseg-gjahr
180    AND   refdocnr = bseg-belnr
181    AND   refdocln = bseg-buzei
182    AND   aworg    = glpca-aworg
183    AND   stflg    = space
184    AND   stokz    = space
185    AND   rprctr   NE space.
186      IF sy-subrc <> 0.
187        WRITE: / 'FI line item', bseg-bukrs, bseg-belnr, bseg-buzei,
188    ': No valid entry found in GLPCA'.
189      ELSE.
190        PERFORM check_and_move_prctr.
191      ENDIF.
192    ENDFORM.
193
194    *   *
195    *	       FORM Get_profit_center_crosscomp	*
196    *   *
197    *	       ........	*
198    *   *
199
200    FORM get_profit_center_crosscomp.
201    *Get profit center (prctr) from PCA document corrected with 1KE8
202    SELECT SINGLE * FROM glpca
203          WHERE rbukrs = bseg-bukrs
204           AND   ryear  = bseg-gjahr
205                AND   refdocnr = glpca-refdocnr
206                AND   refdocln = bseg-buzei
207                AND   racct    = bseg-hkont
208                AND   aworg    = glpca-aworg
209                AND   stflg    = space
210                AND   stokz    = space
211                AND   rprctr   NE space.
212    IF sy-subrc <> 0.
213      WRITE: / 'FI line item', bseg-bukrs, bseg-belnr,
214                bseg-buzei, ': No valid entry found in GLPCA'.
215    ELSE.
216      PERFORM check_and_move_prctr.
217    ENDIF.
218
219    ENDFORM.
220
221
222    *---------------------------------------------------------------------*
223    *       FORM correct_index                                            *
224    *---------------------------------------------------------------------*
225    *       ........                                                      *
226    *---------------------------------------------------------------------*
227    FORM correct_index.
228
229    IF bseg-augbl = '  '.
230      CASE bseg-koart.
231        WHEN 'D'.
232          SELECT SINGLE * FROM bsid
233                                WHERE bukrs = bseg-bukrs
234                                AND   kunnr = bseg-kunnr
235                                AND   umsks = bseg-umsks
236                                AND   umskz = bseg-umskz
237                                AND   augdt = bseg-augdt
238                                AND   augbl = bseg-augbl
239                                AND   zuonr = bseg-zuonr
240                                AND   gjahr = bseg-gjahr
241                                AND   belnr = bseg-belnr
242                                AND   buzei = bseg-buzei.
243          IF sy-subrc = 0.
244            MOVE-CORRESPONDING bseg TO bsid.
245    *        UPDATE bsid.
246            IF sy-dbcnt <> 1.
247              MESSAGE a500(fe) WITH 'Fehler'.
248            ENDIF.
249          ELSE.
250            WRITE: / 'BSID entry for BELNR ', bseg-belnr, 'not found!'.
251          ENDIF.
252          IF bseg-xhres = 'X'.
253            PERFORM sonderhauptbuch_bsis_index.
254          ENDIF.
255        WHEN 'K'.
256          SELECT SINGLE * FROM bsik
257                                WHERE bukrs = bseg-bukrs
258                                AND   lifnr = bseg-lifnr
259                                AND   umsks = bseg-umsks
260                                AND   umskz = bseg-umskz
261                                AND   augdt = bseg-augdt
262                                AND   augbl = bseg-augbl
263                                AND   zuonr = bseg-zuonr
264                                AND   gjahr = bseg-gjahr
265                                AND   belnr = bseg-belnr
266                                AND   buzei = bseg-buzei.
267          IF sy-subrc = 0.
268            MOVE-CORRESPONDING bseg TO bsik.
269    *        UPDATE bsik.
270            IF sy-dbcnt <> 1.
271              MESSAGE a500(fe) WITH 'Fehler'.
272            ENDIF.
273          ELSE.
274            WRITE: / 'BSIK entry for BELNR ', bseg-belnr, 'not found!'.
275          ENDIF.
276          IF bseg-xhres = 'X'.
277            PERFORM sonderhauptbuch_bsis_index.
278          ENDIF.
279        WHEN 'S'.
280          SELECT SINGLE * FROM bsis
281                                WHERE bukrs = bseg-bukrs
282                                AND   hkont = bseg-hkont
283                                AND   augdt = bseg-augdt
284                                AND   augbl = bseg-augbl
285                                AND   zuonr = bseg-zuonr
286                                AND   gjahr = bseg-gjahr
287                                AND   belnr = bseg-belnr
288                                AND   buzei = bseg-buzei.
289          IF sy-subrc = 0.
290            MOVE-CORRESPONDING bseg TO bsis.
291    *        UPDATE bsis.
292            IF sy-dbcnt <> 1.
293              MESSAGE a500(fe) WITH 'Fehler'.
294            ENDIF.
295          ELSE.
296            WRITE: / 'BSIS entry for BELNR ', bseg-belnr, 'not found!'.
297          ENDIF.
298      ENDCASE.
299    ELSE.
300      CASE bseg-koart.
301        WHEN 'D'.
302          SELECT SINGLE * FROM bsad
303                                WHERE bukrs = bseg-bukrs
304                                AND   kunnr = bseg-kunnr
305                                AND   umsks = bseg-umsks
306                                AND   umskz = bseg-umskz
307                                AND   augdt = bseg-augdt
308                                AND   augbl = bseg-augbl
309                                AND   zuonr = bseg-zuonr
310                                AND   gjahr = bseg-gjahr
311                                AND   belnr = bseg-belnr
312                                AND   buzei = bseg-buzei.
313          IF sy-subrc = 0.
314            MOVE-CORRESPONDING bseg TO bsad.
315    *        UPDATE bsad.
316            IF sy-dbcnt <> 1.
317              MESSAGE a500(fe) WITH 'Fehler'.
318            ENDIF.
319          ELSE.
320            WRITE: / 'BSAD entry for BELNR ', bseg-belnr, 'not found!'.
321          ENDIF.
322          IF bseg-xhres = 'X'.
323            PERFORM sonderhauptbuch_bsas_index.
324          ENDIF.
325        WHEN 'K'.
326          SELECT SINGLE * FROM bsak
327                                WHERE bukrs = bseg-bukrs
328                                AND   lifnr = bseg-lifnr
329                                AND   umsks = bseg-umsks
330                                AND   umskz = bseg-umskz
331                                AND   augdt = bseg-augdt
332                                AND   augbl = bseg-augbl
333                                AND   zuonr = bseg-zuonr
334                                AND   gjahr = bseg-gjahr
335                                AND   belnr = bseg-belnr
336                                AND   buzei = bseg-buzei.
337          IF sy-subrc = 0.
338            MOVE-CORRESPONDING bseg TO bsak.
339    *        UPDATE bsak.
340            IF sy-dbcnt <> 1.
341              MESSAGE a500(fe) WITH 'Fehler'.
342            ENDIF.
343          ELSE.
344            WRITE: / 'BSAK entry for BELNR ', bseg-belnr, 'not found!'.
345          ENDIF.
346          IF bseg-xhres = 'X'.
347            PERFORM sonderhauptbuch_bsas_index.
348          ENDIF.
349        WHEN 'S'.
350          SELECT SINGLE * FROM bsas
351                                WHERE bukrs = bseg-bukrs
352                                AND   hkont = bseg-hkont
353                                AND   augdt = bseg-augdt
354                                AND   augbl = bseg-augbl
355                                AND   zuonr = bseg-zuonr
356                                AND   gjahr = bseg-gjahr
357                                AND   belnr = bseg-belnr
358                                AND   buzei = bseg-buzei.
359          IF sy-subrc = 0.
360            MOVE-CORRESPONDING bseg TO bsas.
361    *        UPDATE bsas.
362            IF sy-dbcnt <> 1.
363              MESSAGE a500(fe) WITH 'Fehler'.
364            ENDIF.
365          ELSE.
366            WRITE: / 'BSAS entry for BELNR ', bseg-belnr, 'not found!'.
367          ENDIF.
368      ENDCASE.
369    ENDIF.
370    ENDFORM.
371
372    * FORM SONDERHAUPTBUCH_BSIS_INDEX
373    FORM sonderhauptbuch_bsis_index.
374      SELECT SINGLE * FROM bsis
375                            WHERE bukrs = bseg-bukrs
376                            AND   hkont = bseg-hkont
377                            AND   augdt = bseg-augdt
378                            AND   augbl = bseg-augbl
379                            AND   zuonr = bseg-hzuon
380                            AND   gjahr = bseg-gjahr
381                            AND   belnr = bseg-belnr
382                            AND   buzei = bseg-buzei.
383      IF sy-subrc = 0.
384        MOVE-CORRESPONDING bseg TO bsis.
385        bsis-zuonr = bseg-hzuon.
386    *    UPDATE bsis.
387        IF sy-dbcnt <> 1.
388          MESSAGE a500(fe) WITH 'Fehler'.
389        ENDIF.
390      ELSE.
391        WRITE: / 'BSIS entry for BELNR ', bseg-belnr, 'not found!'.
392      ENDIF.
393    ENDFORM.
394
395    * FORM SONDERHAUPTBUCH_BSAS_INDEX
396    FORM sonderhauptbuch_bsas_index.
397      SELECT SINGLE * FROM bsas
398                            WHERE bukrs = bseg-bukrs
399                            AND   hkont = bseg-hkont
400                            AND   augdt = bseg-augdt
401                            AND   augbl = bseg-augbl
402                            AND   zuonr = bseg-hzuon
403                            AND   gjahr = bseg-gjahr
404                            AND   belnr = bseg-belnr
405                            AND   buzei = bseg-buzei.
406      IF sy-subrc = 0.
407        MOVE-CORRESPONDING bseg TO bsas.
408        bsas-zuonr = bseg-hzuon.
409    *    UPDATE bsas.
410        IF sy-dbcnt <> 1.
411          MESSAGE a500(fe) WITH 'Fehler'.
412        ENDIF.
413      ELSE.
414        WRITE: / 'BSAS entry for BELNR ', bseg-belnr, 'not found!'.
415      ENDIF.
416    ENDFORM.
417
418    * form update_line_items.
419    * update and print of line items.
420    FORM update_line_items.
421      CHECK real_run = 'X'.
422      WRITE: / 'Corrected entries:'.
423      ULINE.
424      WRITE: / 'Table', 15 'BUKRS', 22 'BELNR', 35 'BUZEI'.
425      ULINE.
426      LOOP AT ibseg.
427        counter = counter + 1.
428        CLEAR bseg.
429        MOVE-CORRESPONDING ibseg TO bseg.
430        UPDATE bseg.
431        IF sy-dbcnt <> 1.
432    *      MESSAGE a500(fe) WITH 'Fehler'.
433        ELSE.
434          WRITE: / 'BSEG', 15 bseg-bukrs, 22 bseg-belnr, 35 bseg-buzei,
435                   40 bseg-prctr, 52 bseg-hkont.
436
437          MOVE-CORRESPONDING ibseg TO kbseg.
438          APPEND kbseg.
439        ENDIF.
440        IF bseg-xkres = 'X'.
441          PERFORM correct_index.
442        ENDIF.
443
444        ADD 1 TO db_change.
445        IF db_change >= c_max.
446          CALL FUNCTION 'DB_COMMIT'.
447          db_change = 0.
448        ENDIF.
449
450      ENDLOOP.
451    ENDFORM.
452
453    * form print_line_items.
454    FORM print_line_items.
455      ULINE. "#EC CI_NOORDER
456      WRITE: / 'Entries for correction:'. "#EC CI_NOORDER
457      ULINE. "#EC CI_NOORDER
458      WRITE: / 'Table', 15 'BUKRS', 22 'BELNR', 35 'BUZEI', 42 'PRCTR'. "#EC CI_NOORDER
459      ULINE. "#EC CI_NOORDER
460      LOOP AT ibseg.
461        counter = counter + 1.
462        WRITE: / 'BSEG', 15 ibseg-bukrs, 22 ibseg-belnr, 35 ibseg-buzei, "#EC CI_NOORDER
463          40 ibseg-prctr.
464      ENDLOOP.
465    ENDFORM.
466
467
468    *---------------------------------------------------------------------*
469    *       FORM check_and_move_prctr                                     *
470    *---------------------------------------------------------------------*
471    *       ........                                                      *
472    *---------------------------------------------------------------------*
473    FORM check_and_move_prctr.
474
475    glpca-hsl = abs( glpca-hsl ).
476      IF bseg-dmbtr NE glpca-hsl.
477        WRITE: / 'FI line item', bseg-bukrs, bseg-belnr, bseg-buzei,
478       ': Entry found in GLPCA does not fit!'.
479      ELSE.
480        PERFORM move_prctr.
481      ENDIF.
482    ENDFORM.                               " CHECK_AND_MOVE_PRCTR
483
484    *---------------------------------------------------------------------*
485    *       FORM move_prctr                                               *
486    *---------------------------------------------------------------------*
487    *       ........                                                      *
488    *---------------------------------------------------------------------*
489    FORM move_prctr.
490
491      MOVE-CORRESPONDING bseg TO ibseg.
492    * IBSEG-PRCTR = GLPCA-RPRCTR.
493      PERFORM fill_from_t8a30.
494      APPEND ibseg.
495
496    ENDFORM.
497
498    *---------------------------------------------------------------------*
499    *       FORM fill_from_t8a30                                          *
500    *---------------------------------------------------------------------*
501    *       ........                                                      *
502    *---------------------------------------------------------------------*
503    FORM fill_from_t8a30.
504
505    DATA: l_prctr  LIKE ibseg-prctr,
506          dbfields TYPE TABLE OF dbfield WITH HEADER LINE,
507          l_condi  TYPE string,
508          l_subrc  TYPE sy-subrc,
509          l_tabname TYPE dd02l-tabname.
510
511    *only from from table T8A30!!!!!
512    *  SELECT SINGLE * FROM t8a30
513    *    WHERE kokrs     = bseg-kokrs
514    *    AND   konto_von <= bseg-hkont
515    *    AND   konto_bis >= bseg-hkont.
516      SELECT * FROM t8a30 UP TO 1 ROWS
517        WHERE kokrs     = bseg-kokrs
518        AND   konto_von <= bseg-hkont
519        AND   konto_bis >= bseg-hkont ORDER BY PRIMARY KEY. ENDSELECT.
520
521      IF sy-subrc <> 0.
522
523        WRITE: / 'document', bseg-belnr,
524    ': No T8A30 entry found FOR ACCOUNT', bseg-hkont.
525
526      ELSE.
527
528        IF t8a30-prctr = 'ONGC_DUMMY'.
529
530          CLEAR l_prctr.
531
532          SELECT SINGLE prctr INTO l_prctr FROM zpc_coba
533            WHERE bukrs = bseg-bukrs AND
534                  gsber = bseg-gsber.
535
536          IF sy-subrc = 0.
537            ibseg-prctr = l_prctr.
538          ENDIF.
539
540        ENDIF.
541
542      ENDIF.
543
544    *      REFRESH it_tkedrs.
545    *
546    *      SELECT * FROM tkedrs
547    *          INTO TABLE it_tkedrs
548    *          WHERE applclass = 'PCA' AND
549    *                kedrenv = t8a30-kokrs.
550    *
551    *      IF NOT it_tkedrs[] IS INITIAL.
552    *
553    *        LOOP AT it_tkedrs.
554    *
555    *          l_tabname = it_tkedrs-param_1.
556    *
557    *          CALL FUNCTION 'DB_GET_TABLE_FIELDS'
558    *            EXPORTING
559    **             FIELD_INFO       = 'A'
560    *              tabname          = l_tabname
561    *            IMPORTING
562    *              subrc            = l_subrc
563    *            TABLES
564    *              dbfields         = dbfields.
565    *
566    *          IF l_subrc = 0.
567    *
568    *            READ TABLE dbfields WITH KEY name = 'SOUR3_FROM'.
569    *
570    *            CLEAR l_prctr.
571    *
572    *            IF sy-subrc = 0.
573    *
574    *              SELECT SINGLE target1 INTO l_prctr
575    *                    FROM (it_tkedrs-param_1)
576    *                    WHERE sour1_from <= bseg-hkont AND
577    *                          sour1_to   >= bseg-hkont AND
578    *                          sour2_from = bseg-bukrs AND
579    *                          sour3_from = bseg-gsber.
580    *
581    *            ELSE.
582    *
583    *              SELECT SINGLE target1 INTO l_prctr
584    *                    FROM (it_tkedrs-param_1)
585    *                    WHERE sour1_from <= bseg-hkont AND
586    *                          sour1_to   >= bseg-hkont AND
587    *                          sour2_from = bseg-bukrs.
588    *
589    *            ENDIF.
590    *
591    *            IF sy-subrc = 0.
592    *
593    *              ibseg-prctr = l_prctr.
594    *              exit.
595    *
596    *            ENDIF.
597    *
598    *          ENDIF.
599    *
600    *        ENDLOOP.
601    *
602    *      ENDIF. " Commented By Kalpesh
603
604    *      ENDIF.
605    *
606    *    ENDIF.
607
608    ENDFORM.
609
610
611    *----------------------------------------------------------------------*
612    *        Start new screen                                              *
613    *----------------------------------------------------------------------*
614    FORM BDC_DYNPRO USING PROGRAM DYNPRO.
615      CLEAR BDCDATA.
616      BDCDATA-PROGRAM  = PROGRAM.
617      BDCDATA-DYNPRO   = DYNPRO.
618      BDCDATA-DYNBEGIN = 'X'.
619      APPEND BDCDATA.
620    ENDFORM.
621
622    *----------------------------------------------------------------------*
623    *        Insert field                                                  *
624    *----------------------------------------------------------------------*
625    FORM BDC_FIELD USING FNAM FVAL.
626      CLEAR BDCDATA.
627      BDCDATA-FNAM = FNAM.
628      BDCDATA-FVAL = FVAL.
629      APPEND BDCDATA.
630    ENDFORM.
631
632    *&---------------------------------------------------------------------*
633    *&      Form  bdc_transaction
634    *&---------------------------------------------------------------------*
635    form bdc_transaction using tcode.
636      data: l_mstring(480).
637      data: l_subrc like sy-subrc.
638      data: l_mode value 'N'.
639      data: l_upd value 'S'.
640      call transaction tcode using bdcdata
641                       update l_upd
642                       mode   l_mode
643                       messages into messtab.
644
645    endform.                    " bdc_transaction
*--- End of Z_CORR_PRCTR2 - 645 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  <REPINI>                                  Level 1    Page 2
Object           Z_CORR_PRCTR2                             Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:29
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
Object           Z_CORR_PRCTR2                             Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:29
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
Object           Z_CORR_PRCTR2                             Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:29
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
Object           Z_CORR_PRCTR2                             Lines 1
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:29
----------------------------------------------------------------------------------------------------
1      * INCLUDE DB__SSEL
*--- End of DB__SSEL - 1 lines ---
