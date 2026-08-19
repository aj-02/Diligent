----------------------------------------------------------------------------------------------------
Main program     ZAIMBNEW                                  Level 0    Page 1
Object           ZAIMBNEW                                  Lines 957
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:29
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *& Report  ZAIMBNEW
3      *&
4      *&---------------------------------------------------------------------*
5      *&
6      *&
7      *&---------------------------------------------------------------------*
8
9      ***-------------------------------------------------------------------*
10     *** report attributes:                                                *
11     *** type = 1 ,                                                        *
12     *** application = A ,                                                 *
13     *** logical database = IM ,                                           *
14     *** from aplication  = A .                                            *
15     ***                                                                   *
16     REPORT zaimbnew.
17     ***                                                                   *
18     *** this program differs from program ZAIMCNEW                        *
19     *** only in the default settings of parameters DERIVE47/41.           *
20     ***                                                                   *
21     PARAMETERS: derive47 DEFAULT 'X' NO-DISPLAY,
22                 derive41 NO-DISPLAY.
23
24     TYPE-POOLS: im.                                            " 3.1
25
26     TABLES: streenode,
27     *       RAIPATTR,                                          " 4.0
28             bpge, bpja, bptr,                                  " 3.1
29             imtp,
30             impr.
31
32     INCLUDE lkbppequ.
33
34     TYPES: BEGIN OF l_obj_type,
35              objnr LIKE impr-objnr,
36              geber LIKE bpge-geber,
37            END   OF l_obj_type.
38     DATA: obj_wa  TYPE l_obj_type,
39           obj_tab LIKE obj_wa OCCURS 0.                      " 3.1
40     *      OBJ_TAB  TYPE STANDARD TABLE OF L_OBJ_TYPE          " 4.0
41     *               WITH DEFAULT KEY.                          " 4.0
42
43     TYPES: BEGIN OF l_comp_type,
44              lednr   LIKE bpja-lednr,
45              objnr   LIKE impr-objnr,
46              vorga   LIKE bpja-vorga,
47              geber   LIKE bpja-geber,
48              gjahr   LIKE bpja-gjahr,
49              lval_47 LIKE bpge-wlges,
50              lval_41 LIKE bpge-wlges,
51              tval_47 LIKE bpge-wlges,
52              tval_41 LIKE bpge-wlges,
53              twaer   LIKE bpja-twaer,
54            END   OF l_comp_type.
55
56     DATA: comp_wa  TYPE l_comp_type,
57           comp_tab LIKE comp_wa OCCURS 0.                     " 3.1
58     *      COMP_TAB TYPE STANDARD TABLE OF L_COMP_TYPE         " 4.0
59     *               WITH DEFAULT KEY.                          " 4.0
60
61     DATA: index TYPE i,
62           objnr LIKE impr-objnr,
63           subrc LIKE sy-subrc,
64           tabix LIKE sy-tabix.
65
66     DATA:  flg_get_ydist(1) TYPE c VALUE 'X'.
67     *      YDIST            LIKE IMTP-YDIST.                   " 4.0
68
69     DATA:  wrttp LIKE bpge-wrttp.
70
71     AT SELECTION-SCREEN OUTPUT.
72       LOOP AT SCREEN.
73         IF screen-name CS 'PA_PRNAM' OR
74            screen-name CS 'PA_POSID' OR
75            screen-name CS 'PA_GJAHR' .
76           CONTINUE.
77         ENDIF.
78         screen-active = '0'.
79         MODIFY SCREEN.
80       ENDLOOP.
81
82     START-OF-SELECTION.
83
84     * Derive 47 from 41 ...
85       IF     derive47 <> space.
86         wrttp = l_wibudget.
87     * Derive 41 from 47 ...
88       ELSEIF derive41 <> space.
89         wrttp = l_wbudget.
90       ENDIF.
91
92     GET streenode.
93
94     *GET RAIPATTR.                                             " 4.0
95
96     * Only orders and WBS-elements can be recievers of
97     * distributed budget.
98     * IF RAIPATTR-OBART <> 'OR' AND                            " 4.0
99     *    RAIPATTR-OBART <> 'PR' .                              " 4.0
100      IF streenode-name(2) <> 'OR' AND                         " 3.1
101         streenode-name(2) <> 'PR' .                           " 3.1
102        REJECT 'STREENODE'.
103      ENDIF.
104
105    GET imtp.
106
107    * IF FLG_GET_YDIST <> SPACE.                               " 4.0
108    *    FLG_GET_YDIST =  SPACE.                               " 4.0
109    *    YDIST = IMTP-YDIST.                                   " 4.0
110    * ENDIF.                                                   " 4.0
111
112    GET impr.
113
114    * Budget distribution in use?
115      IF impr-xaktb = space.
116        REJECT 'STREENODE'.
117      ENDIF.
118    * Get objectnumber.
119      MOVE streenode-name TO objnr.
120      READ TABLE obj_tab
121           TRANSPORTING NO FIELDS
122           WITH KEY objnr = objnr
123           BINARY SEARCH.
124      tabix = sy-tabix.
125      subrc = sy-subrc.
126      IF sy-subrc <> 0.
127        CLEAR obj_wa.
128        obj_wa-objnr = objnr.
129        IF derive47 <> space.
130          obj_wa-geber = impr-objnr(10).
131        ENDIF.
132        INSERT obj_wa INTO obj_tab INDEX tabix.
133        index = index + 1.
134      ENDIF.
135
136    * Process packages of at most100 objects each.
137      IF index > 100.
138        index = 0.
139        PERFORM compare_budgets.
140        REFRESH: obj_tab.
141      ENDIF.
142
143    END-OF-SELECTION.
144
145    * Process last uncompleted package.
146      IF NOT obj_tab[] IS INITIAL.
147        PERFORM compare_budgets.
148      ENDIF.
149
150      COMMIT WORK.
151      MESSAGE i012(ap).
152
153    *                                                                    *
154    FORM compare_budgets.
155
156      DATA: l_bpge LIKE bpge,
157            l_bpja LIKE bpja.
158
159    * DATA: T_BPGE        LIKE STANDARD TABLE OF BPGE          " 4.0
160    *                     WITH DEFAULT KEY,                    " 4.0
161    *       T_BPJA        LIKE STANDARD TABLE OF BPJA          " 4.0
162    *                     WITH DEFAULT KEY.                    " 4.0
163      DATA: t_bpge LIKE bpge OCCURS 0,                  " 3.1
164            t_bpja LIKE bpja OCCURS 0.                  " 3.1
165
166    * DATA: T_BPGE_ORG    LIKE STANDARD TABLE OF BPGE          " 4.0
167    *                     WITH DEFAULT KEY,                    " 4.0
168    *       T_BPJA_ORG    LIKE STANDARD TABLE OF BPJA          " 4.0
169    *                     WITH DEFAULT KEY.                    " 4.0
170      DATA: t_bpge_org LIKE bpge OCCURS 0,                  " 3.1
171            t_bpja_org LIKE bpja OCCURS 0.                  " 3.1
172
173    * DATA: T_BPGE_SUPPL  LIKE STANDARD TABLE OF BPGE          " 4.0
174    *                     WITH DEFAULT KEY,                    " 4.0
175    *       T_BPJA_SUPPL  LIKE STANDARD TABLE OF BPJA          " 4.0
176    *                     WITH DEFAULT KEY.                    " 4.0
177      DATA: t_bpge_suppl LIKE bpge OCCURS 0,                  " 3.1
178            t_bpja_suppl LIKE bpja OCCURS 0.                  " 3.1
179
180    * DATA: T_BPGE_RET    LIKE STANDARD TABLE OF BPGE          " 4.0
181    *                     WITH DEFAULT KEY,                    " 4.0
182    *       T_BPJA_RET    LIKE STANDARD TABLE OF BPJA          " 4.0
183    *                     WITH DEFAULT KEY.                    " 4.0
184      DATA: t_bpge_ret LIKE bpge OCCURS 0,                  " 3.1
185            t_bpja_ret LIKE bpja OCCURS 0.                  " 3.1
186
187      DATA: t_covob_org   TYPE im_covob_tab_type,
188            t_covob_suppl TYPE im_covob_tab_type,
189            t_covob_ret   TYPE im_covob_tab_type,
190            l_covob       TYPE im_covob_type.
191
192      DATA: l_tabix LIKE sy-tabix,
193            l_subrc LIKE sy-subrc.
194
195      DATA: l_ldiff LIKE bpge-wlges,
196            l_tdiff LIKE bpge-wlges,
197            l_sgtxt LIKE bpin-sgtext.
198
199      CHECK NOT obj_tab[] IS INITIAL.
200
201    * Select all 41-/47-records for objects concerned.
202      " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 14.06.2026  for ATC
203    *  SELECT * FROM BPGE
204      SELECT * FROM bpge
205    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 14.06.2026 for ATC
206        INTO TABLE t_bpge
207        FOR ALL ENTRIES IN obj_tab
208        WHERE   objnr = obj_tab-objnr
209        AND   ( wrttp = l_wibudget OR
210                wrttp = l_wbudget  ).  "#EC CI_DB_OPERATION_OK
211      SORT t_bpge BY objnr wrttp.
212    * IF YDIST <> SPACE.                                       " 4.0
213    *    SELECT * FROM BPJA                                    " 4.0
214    *      INTO TABLE T_BPJA                                   " 4.0
215    *      FOR ALL ENTRIES IN OBJ_TAB                          " 4.0
216    *      WHERE   OBJNR = OBJ_TAB-OBJNR                       " 4.0
217    *      AND   ( WRTTP = L_WIBUDGET OR                       " 4.0
218    *              WRTTP = L_WBUDGET  ).                       " 4.0
219    *    SORT T_BPJA BY OBJNR WRTTP.                           " 4.0
220    * ENDIF.                                                   " 4.0
221
222    * Build compare table.
223      REFRESH comp_tab.
224      LOOP AT obj_tab INTO obj_wa.
225    *   overall values.
226        READ TABLE t_bpge
227             TRANSPORTING NO FIELDS
228             WITH KEY objnr = obj_wa-objnr
229             BINARY SEARCH.
230        l_tabix = sy-tabix.
231        l_subrc = sy-subrc.
232        IF l_subrc = 0.
233          LOOP AT t_bpge INTO l_bpge
234            FROM l_tabix.
235            IF l_bpge-objnr <> obj_wa-objnr.
236              EXIT.
237            ENDIF.
238            CLEAR comp_wa.
239            comp_wa-lednr = l_bpge-lednr.
240            comp_wa-objnr = obj_wa-objnr.
241            comp_wa-vorga = l_bpge-vorga.
242    *        transaction type is not relevant in IM
243    *        (e.g. KBW1/KBW2 from carry over).
244            IF comp_wa-vorga <> l_vbud AND
245               comp_wa-vorga <> l_vbn0 AND
246               comp_wa-vorga <> l_vbr0 .
247    *           determine transaction type according
248    *           to sign of amount.
249              IF l_bpge-wlges >= 0.
250                comp_wa-vorga = l_vbn0.
251              ELSE.
252                comp_wa-vorga = l_vbr0.
253              ENDIF.
254
255            ENDIF.
256    *
257            comp_wa-geber = obj_wa-geber.
258            comp_wa-gjahr = '0000'.
259            CASE l_bpge-wrttp.
260              WHEN l_wibudget.
261                comp_wa-lval_47 = l_bpge-wlges.
262                comp_wa-tval_47 = l_bpge-wtges.
263              WHEN l_wbudget.
264                comp_wa-lval_41 = l_bpge-wlges.
265                comp_wa-tval_41 = l_bpge-wtges.
266            ENDCASE.
267            comp_wa-twaer = l_bpge-twaer.
268            COLLECT comp_wa INTO comp_tab.
269          ENDLOOP.
270        ENDIF.
271    *   annuall values.
272        READ TABLE t_bpja
273             TRANSPORTING NO FIELDS
274             WITH KEY objnr = obj_wa-objnr
275             BINARY SEARCH.
276        l_tabix = sy-tabix.
277        l_subrc = sy-subrc.
278        IF l_subrc = 0.
279          LOOP AT t_bpja INTO l_bpja
280            FROM l_tabix.
281            IF l_bpja-objnr <> obj_wa-objnr.
282              EXIT.
283            ENDIF.
284            CLEAR comp_wa.
285            comp_wa-lednr = l_bpja-lednr.
286            comp_wa-objnr = obj_wa-objnr.
287            comp_wa-vorga = l_bpja-vorga.
288    *        transaction type is not relevant in IM
289    *        (e.g. KBW1/KBW2 from carry over).
290            IF comp_wa-vorga <> l_vbud AND
291               comp_wa-vorga <> l_vbn0 AND
292               comp_wa-vorga <> l_vbr0 .
293    *           determine transaction type according
294    *           to sign of amount.
295              IF l_bpja-wljhr >= 0.
296                comp_wa-vorga = l_vbn0.
297              ELSE.
298                comp_wa-vorga = l_vbr0.
299              ENDIF.
300            ENDIF.
301    *
302            comp_wa-geber = obj_wa-geber.
303            comp_wa-gjahr = l_bpja-gjahr.
304            CASE l_bpja-wrttp.
305              WHEN l_wibudget.
306                comp_wa-lval_47 = l_bpja-wljhr.
307                comp_wa-tval_47 = l_bpja-wtjhr.
308              WHEN l_wbudget.
309                comp_wa-lval_41 = l_bpja-wljhr.
310                comp_wa-tval_41 = l_bpja-wtjhr.
311            ENDCASE.
312            comp_wa-twaer = l_bpja-twaer.
313            COLLECT comp_wa INTO comp_tab.
314          ENDLOOP.
315        ENDIF.
316      ENDLOOP.
317
318    * Compare 41- vs. 47-entries.
319      LOOP AT comp_tab INTO comp_wa.
320    *
321        AT NEW objnr.
322          REFRESH: t_bpge_org,   t_bpja_org,
323                   t_bpge_suppl, t_bpja_suppl,
324                   t_bpge_ret,   t_bpja_ret.
325        ENDAT.
326    *   Derive 47 from 41 ...
327        IF     derive47 <> space.
328          l_ldiff = comp_wa-lval_41 - comp_wa-lval_47.
329          l_tdiff = comp_wa-tval_41 - comp_wa-tval_47.
330    *   Derive 41 from 47 ...
331        ELSEIF derive41 <> space.
332          l_ldiff = comp_wa-lval_47 - comp_wa-lval_41.
333          l_tdiff = comp_wa-tval_47 - comp_wa-tval_41.
334        ENDIF.
335    *   Difference occured.
336        IF l_ldiff <> 0 OR
337           l_tdiff <> 0 .
338    *
339          IF comp_wa-gjahr = '0000'.
340            CLEAR l_bpge.
341            l_bpge-mandt = sy-mandt.
342            l_bpge-lednr = comp_wa-lednr.
343            l_bpge-objnr = comp_wa-objnr.
344            l_bpge-vorga = comp_wa-vorga.
345            l_bpge-geber = comp_wa-geber.
346            l_bpge-trgkz = l_node.
347            l_bpge-wrttp = wrttp.
348            l_bpge-versn = '000'.
349            l_bpge-twaer = comp_wa-twaer.
350            l_bpge-wtges = l_tdiff.
351            l_bpge-wlges = l_ldiff.
352    *
353            CASE l_bpge-vorga.
354              WHEN l_vbud.
355                COLLECT l_bpge INTO t_bpge_org.
356              WHEN l_vbn0.
357                COLLECT l_bpge INTO t_bpge_suppl.
358              WHEN l_vbr0.
359                COLLECT l_bpge INTO t_bpge_ret.
360              WHEN OTHERS.
361                IF     l_bpge-wlges > 0.
362                  l_bpge-vorga = l_vbn0.
363                  COLLECT l_bpge INTO t_bpge_suppl.
364                ELSEIF l_bpge-wlges < 0.
365                  l_bpge-vorga = l_vbr0.
366                  COLLECT l_bpge INTO t_bpge_ret.
367                ENDIF.
368            ENDCASE.
369          ELSE.
370            CLEAR l_bpja.
371            l_bpja-mandt = sy-mandt.
372            l_bpja-lednr = comp_wa-lednr.
373            l_bpja-objnr = comp_wa-objnr.
374            l_bpja-vorga = comp_wa-vorga.
375            l_bpja-geber = comp_wa-geber.
376            l_bpja-trgkz = l_node.
377            l_bpja-wrttp = wrttp.
378            l_bpja-gjahr = comp_wa-gjahr.
379            l_bpja-versn = '000'.
380            l_bpja-twaer = comp_wa-twaer.
381            l_bpja-wtjhr = l_tdiff.
382            l_bpja-wljhr = l_ldiff.
383    *
384            CASE l_bpja-vorga.
385              WHEN l_vbud.
386                COLLECT l_bpja INTO t_bpja_org.
387              WHEN l_vbn0.
388                COLLECT l_bpja INTO t_bpja_suppl.
389              WHEN l_vbr0.
390                COLLECT l_bpja INTO t_bpja_ret.
391              WHEN OTHERS.
392                IF     l_bpja-wljhr > 0.
393                  l_bpja-vorga = l_vbn0.
394                  COLLECT l_bpja INTO t_bpja_suppl.
395                ELSEIF l_bpja-wljhr < 0.
396                  l_bpja-vorga = l_vbr0.
397                  COLLECT l_bpja INTO t_bpja_ret.
398                ENDIF.
399            ENDCASE.
400          ENDIF.
401    *
402        ENDIF.
403
404        AT END OF objnr.
405          IF NOT t_bpge_org[]   IS INITIAL OR
406             NOT t_bpja_org[]   IS INITIAL .
407            CLEAR l_covob.
408            l_covob-objnr = comp_wa-objnr.
409            l_covob-bpge  = t_bpge_org.
410            l_covob-bpja  = t_bpja_org.
411            APPEND l_covob TO t_covob_org.
412          ENDIF.
413          IF NOT t_bpge_suppl[] IS INITIAL OR
414             NOT t_bpja_suppl[] IS INITIAL .
415            CLEAR l_covob.
416            l_covob-objnr = comp_wa-objnr.
417            l_covob-bpge  = t_bpge_suppl.
418            l_covob-bpja  = t_bpja_suppl.
419            APPEND l_covob TO t_covob_suppl.
420          ENDIF.
421          IF NOT t_bpge_ret[]   IS INITIAL OR
422             NOT t_bpja_ret[]   IS INITIAL .
423            CLEAR l_covob.
424            l_covob-objnr = comp_wa-objnr.
425            l_covob-bpge  = t_bpge_ret.
426            l_covob-bpja  = t_bpja_ret.
427            APPEND l_covob TO t_covob_ret.
428          ENDIF.
429        ENDAT.
430    *
431      ENDLOOP.
432
433      l_sgtxt = 'automatic adjmnt. due to SAP pgm error'.       "#EC NOTEXT
434
435      IF NOT t_covob_org[]   IS INITIAL.
436        PERFORM  aipa_budgproc_input_post
437             USING
438                  t_covob_org
439                  l_vbud
440                  wrttp
441                  l_node
442                  '000'
443                  ' '
444                  l_sgtxt
445                  ' '
446                  ' '
447                  ' '
448                  'X'.
449      ENDIF.
450
451      IF NOT t_covob_suppl[] IS INITIAL.
452        PERFORM  aipa_budgproc_input_post
453             USING
454                  t_covob_suppl
455                  l_vbn0
456                  wrttp
457                  l_node
458                  '000'
459                  ' '
460                  l_sgtxt
461                  ' '
462                  ' '
463                  ' '
464                  'X'.
465      ENDIF.
466
467      IF NOT t_covob_ret[]   IS INITIAL.
468        PERFORM  aipa_budgproc_input_post
469             USING
470                  t_covob_ret
471                  l_vbr0
472                  wrttp
473                  l_node
474                  '000'
475                  ' '
476                  l_sgtxt
477                  ' '
478                  ' '
479                  ' '
480                  'X'.
481      ENDIF.
482    ENDFORM.
483
484
485    FORM aipa_budgproc_input_post
486        USING
487           VALUE(it_covob) TYPE  im_covob_tab_type
488           VALUE(i_vorga) LIKE  bpge-vorga
489           VALUE(i_wrttp) LIKE  bpge-wrttp
490           VALUE(i_trgkz) LIKE  bpge-trgkz
491           VALUE(i_versn) LIKE  bpge-versn " DEFAULT '000'
492           VALUE(i_posit) LIKE  bpge-posit
493           VALUE(i_sgtxt) LIKE  bpin-sgtext" DEFAULT ' '
494           VALUE(i_flg_compute_delta) LIKE  sy-datar    " DEFAULT ' '
495           VALUE(i_flg_commit) LIKE  impr-xaktb " DEFAULT ' '
496           VALUE(i_flg_in_update_task) LIKE  sy-datar   " DEFAULT ' '
497           VALUE(i_flg_budg_dist) LIKE  sy-datar.       " DEFAULT ' '
498    *"
499
500      DATA: l_covob         TYPE im_covob_type,
501            l_dialog_update LIKE sy-datar,
502            l_bpin          LIKE bpin,
503    *       T_OBJ           LIKE TABLE OF RAIP_OBJ WITH HEADER LINE, " 4.0
504    *       T_BPGE          LIKE TABLE OF BPGE WITH HEADER LINE,     " 4.0
505    *       T_BPGE_DB       LIKE TABLE OF BPGE WITH HEADER LINE,     " 4.0
506    *       T_BPGE_ID       LIKE TABLE OF BPGE_ID WITH HEADER LINE,  " 4.0
507    *       T_BPJA          LIKE TABLE OF BPJA WITH HEADER LINE,     " 4.0
508    *       T_BPJA_DB       LIKE TABLE OF BPJA WITH HEADER LINE,     " 4.0
509    *       T_BPJA_ID       LIKE TABLE OF BPJA_ID WITH HEADER LINE,  " 4.0
510    *       T_BPTR          LIKE TABLE OF BPTR WITH HEADER LINE,     " 4.0
511    *       T_BPTR_DB       LIKE TABLE OF BPTR WITH HEADER LINE,     " 4.0
512    *       T_BPTR_ID       LIKE TABLE OF BPTR_ID WITH HEADER LINE.  " 4.0
513            t_obj           LIKE raip_obj OCCURS 0 WITH HEADER LINE, " 3.1
514            t_bpge          LIKE bpge OCCURS 0 WITH HEADER LINE,     " 3.1
515            t_bpge_db       LIKE bpge OCCURS 0 WITH HEADER LINE,     " 3.1
516            t_bpge_id       LIKE bpge_id OCCURS 0 WITH HEADER LINE,  " 3.1
517            t_bpja          LIKE bpja OCCURS 0 WITH HEADER LINE,     " 3.1
518            t_bpja_db       LIKE bpja OCCURS 0 WITH HEADER LINE,     " 3.1
519            t_bpja_id       LIKE bpja_id OCCURS 0 WITH HEADER LINE,  " 3.1
520            t_bptr          LIKE bptr OCCURS 0 WITH HEADER LINE,     " 3.1
521            t_bptr_db       LIKE bptr OCCURS 0 WITH HEADER LINE,     " 3.1
522            t_bptr_id       LIKE bptr_id OCCURS 0 WITH HEADER LINE.  " 3.1
523
524      DATA: BEGIN OF t_dummy OCCURS 1,
525              dummyfield,
526            END   OF t_dummy.
527
528      RANGES: l_rg_versn FOR bpge-versn.
529
530      IF i_wrttp = l_wiplan.
531        CLEAR l_rg_versn.
532        l_rg_versn-sign   = 'I'.
533        l_rg_versn-option = 'EQ'.
534        l_rg_versn-low    = i_versn.
535        APPEND l_rg_versn.
536      ENDIF.
537
538    * Unnötige Sätze wegwerfen.
539      LOOP AT it_covob INTO l_covob.
540        DELETE l_covob-bpge
541          WHERE NOT ( wrttp =  i_wrttp    AND
542                       vorga =  i_vorga    AND
543                       trgkz =  i_trgkz    AND
544                       posit =  i_posit    AND
545                       versn IN l_rg_versn ).
546        DELETE l_covob-bpja
547          WHERE NOT ( wrttp =  i_wrttp    AND
548                      vorga =  i_vorga    AND
549                      trgkz =  i_trgkz    AND
550                      posit =  i_posit    AND
551                      versn IN l_rg_versn ).
552        MODIFY it_covob FROM l_covob.
553      ENDLOOP.
554
555    * Alle beteiligten Objektnummern feststellen.
556    * Alle beteiligten BPTR-Sätze feststellen.
557      LOOP AT it_covob INTO l_covob.
558        LOOP AT l_covob-bpge INTO t_bpge.
559          COLLECT t_bpge.
560          t_obj-objnr = t_bpge-objnr. COLLECT t_obj.
561          CLEAR t_bptr.
562          MOVE-CORRESPONDING t_bpge TO t_bptr.
563          COLLECT t_bptr.
564        ENDLOOP.
565        LOOP AT l_covob-bpja INTO t_bpja.
566          COLLECT t_bpja.
567          t_obj-objnr = t_bpja-objnr. COLLECT t_obj.
568          CLEAR t_bptr.
569          MOVE-CORRESPONDING t_bpja TO t_bptr.
570          COLLECT t_bptr.
571        ENDLOOP.
572      ENDLOOP.
573
574    * Wenn das Delta erst noch berechnet werden soll, muß
575    * der DB-Stand aller Objektnummern in IT_COVOB eingelesen
576    * werden, um Sätze von Objektnummern auf der DB auf 0
577    * zu bringen, für die IT_COVOB-BPGE/BPJA initial.
578      IF i_flg_compute_delta <> space.
579        LOOP AT it_covob INTO l_covob.
580          t_obj-objnr = l_covob-objnr. COLLECT t_obj.
581        ENDLOOP.
582      ENDIF.
583
584    * BPGE/BPJA und BPTR im Zustand
585    * vor dem Update von der DB lesen
586    * und nach Primary Key sortiert vorhalten.
587      REFRESH: t_bpge_db, t_bpja_db, t_bptr_db.
588      " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 14.06.2026  for ATC
589    *  SELECT * FROM BPGE INTO TABLE T_BPGE_DB
590      SELECT * FROM bpge INTO TABLE t_bpge_db
591    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 14.06.2026 for ATC
592        FOR ALL ENTRIES IN t_obj
593        WHERE objnr =  t_obj-objnr
594        AND   wrttp =  i_wrttp
595        AND   vorga =  i_vorga
596        AND   trgkz =  i_trgkz
597        AND   posit =  i_posit
598        AND   versn IN l_rg_versn
599        ORDER BY PRIMARY KEY.  "#EC CI_DB_OPERATION_OK
600      " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 14.06.2026  for ATC
601    *  SELECT * FROM BPJA INTO TABLE T_BPJA_DB
602      SELECT * FROM bpja INTO TABLE t_bpja_db
603    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 14.06.2026 for ATC
604        FOR ALL ENTRIES IN t_obj
605        WHERE objnr = t_obj-objnr
606        AND   wrttp =  i_wrttp
607        AND   vorga =  i_vorga
608        AND   trgkz =  i_trgkz
609        AND   posit =  i_posit
610        AND   versn IN l_rg_versn
611        ORDER BY PRIMARY KEY.  "#EC CI_DB_OPERATION_OK
612      " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 14.06.2026  for ATC
613    *  SELECT * FROM BPTR INTO TABLE T_BPTR_DB
614      SELECT * FROM bptr INTO TABLE t_bptr_db
615    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 14.06.2026 for ATC
616        FOR ALL ENTRIES IN t_obj
617        WHERE objnr = t_obj-objnr
618        AND   wrttp =  i_wrttp
619        AND   trgkz =  i_trgkz
620        AND   posit =  i_posit
621        AND   versn IN l_rg_versn
622        ORDER BY PRIMARY KEY.  "#EC CI_DB_OPERATION_OK
623    * Update-Sätze bestimmen.
624      PERFORM aipa_compute_update_bp
625           TABLES
626                t_bpge_db
627                t_bpge
628                t_bpja_db
629                t_bpja
630                t_bptr_db
631                t_bptr
632                t_bpge_id
633                t_bpja_id
634                t_bptr_id
635           USING
636                i_flg_compute_delta.
637
638    * Überhaupt was zu tun?
639      CHECK NOT t_bpge_id[] IS INITIAL OR
640            NOT t_bpja_id[] IS INITIAL OR
641            NOT t_bptr_id[] IS INITIAL .
642
643    * Verbuchung vorbereiten.
644      CLEAR l_bpin.
645      CASE i_vorga.
646        WHEN l_vplan.
647          l_bpin-tcode = 'IM35'.
648        WHEN l_vbud.
649          l_bpin-tcode = 'IM32'.
650          IF i_flg_budg_dist <> space.
651            l_bpin-tcode = 'IM42'.
652          ENDIF.
653        WHEN l_vbr0.
654          l_bpin-tcode = 'IM38'.
655          IF i_flg_budg_dist <> space.
656            l_bpin-tcode = 'IM48'.
657          ENDIF.
658        WHEN l_vbn0.
659          l_bpin-tcode = 'IM30'.
660          IF i_flg_budg_dist <> space.
661            l_bpin-tcode = 'IM40'.
662          ENDIF.
663      ENDCASE.
664      l_bpin-delta = 'X'.
665      l_bpin-epos  = 'X'.
666
667      CALL FUNCTION 'KBPS_INIT'
668        EXPORTING
669          bp_import = l_bpin
670        IMPORTING
671          bp_in     = l_bpin
672        EXCEPTIONS
673          OTHERS    = 1.
674
675      l_bpin-sgtext = i_sgtxt.
676
677    * Verbuchung.
678      IF i_flg_in_update_task = space.
679        l_dialog_update = 'X'.             " Nicht in Update Task.
680      ELSE.
681        l_dialog_update = ' '.             " In Update Task.
682      ENDIF.
683    *
684      CALL FUNCTION 'KBPV_POST_DATA'
685        EXPORTING
686          delta_update  = 'X'
687          dialog_update = l_dialog_update
688          im_bpin       = l_bpin
689        TABLES
690          tab_bpch      = t_dummy
691          tab_bpge      = t_bpge_id
692          tab_bphi      = t_dummy
693          tab_bpig      = t_dummy
694          tab_bpij      = t_dummy
695          tab_bpja      = t_bpja_id
696          tab_bppe      = t_dummy
697          tab_bptr      = t_bptr_id
698        EXCEPTIONS
699          OTHERS        = 1.
700
701    * COMMIT wenn gewünscht.
702      IF i_flg_commit <> space.
703        COMMIT WORK.
704      ENDIF.
705
706    ENDFORM.
707
708
709    FORM aipa_compute_update_bp
710        TABLES
711            it_bpge_db STRUCTURE  bpge " OPTIONAL
712            it_bpge STRUCTURE  bpge " OPTIONAL
713            it_bpja_db STRUCTURE  bpja " OPTIONAL
714            it_bpja STRUCTURE  bpja " OPTIONAL
715            it_bptr_db STRUCTURE  bptr " OPTIONAL
716            it_bptr STRUCTURE  bptr " OPTIONAL
717            et_bpge_id STRUCTURE  bpge_id " OPTIONAL
718            et_bpja_id STRUCTURE  bpja_id " OPTIONAL
719            et_bptr_id STRUCTURE  bptr_id " OPTIONAL
720        USING
721           VALUE(i_flg_compute_delta) LIKE  sy-datar. " DEFAULT ' '
722
723    *"
724
725    * In IT_BPGE_DB, IT_BPJA_DB, IT_BPTR_DB wird der
726    * Stand auf der DB übergeben.
727    * In IT_BPGE, IT_BPJA, IT_BPTR wird übergeben
728    * -  wenn I_FLG_COMPUTE_DELTA = ' '
729    *    der Stand, der auf den DB-Stand dazu kommt
730    *    (Delta muß nicht eigens berechnet werden),
731    * -  wenn I_FLG_COMPUTE_DELTA = 'X'
732    *    der Stand, der nach dem Sichern auf
733    *    der DB stehen soll
734    *    (Delta soll erst noch berechnet werden).
735    * In den Tabellen ET_BPGE_ID, ET_BPJA_ID, ET_BPTR_ID
736    * werden in jedem Falle Delta-Sätze zurückgegeben
737    * mit den richtigen Update-Kennzeichen (Feld ID).
738
739    * Nur einen bestimmten Vorgang bearbeiten?
740    * IF NOT I_VORGA IS INITIAL.
741    *    DELETE IT_BPGE
742    *      WHERE VORGA <> I_VORGA.
743    *    DELETE IT_BPJA
744    *      WHERE VORGA <> I_VORGA.
745    *    DELETE IT_BPGE_DB
746    *      WHERE VORGA <> I_VORGA.
747    *    DELETE IT_BPJA_DB
748    *      WHERE VORGA <> I_VORGA.
749    * ENDIF.
750
751      REFRESH: et_bpge_id, et_bpja_id, et_bptr_id.
752
753    * Was soll an BPGE-Sätzen neu hinzukommen?
754      SORT it_bpge_db BY lednr
755                         objnr
756                         posit
757                         trgkz
758                         wrttp
759                         geber
760                         versn
761                         vorga
762                         twaer.
763      LOOP AT it_bpge.
764        CLEAR et_bpge_id.
765        et_bpge_id = it_bpge.
766        READ TABLE it_bpge_db
767             WITH KEY lednr = it_bpge-lednr
768                      objnr = it_bpge-objnr
769                      posit = it_bpge-posit
770                      trgkz = it_bpge-trgkz
771                      wrttp = it_bpge-wrttp
772                      geber = it_bpge-geber
773                      versn = it_bpge-versn
774                      vorga = it_bpge-vorga
775                      twaer = it_bpge-twaer
776             BINARY SEARCH.
777        IF sy-subrc = 0.
778          et_bpge_id-id = 'U'.
779    *      Delta bilden?
780          IF i_flg_compute_delta <> space.
781            et_bpge_id-wlges = et_bpge_id-wlges - it_bpge_db-wlges.
782            et_bpge_id-wtges = et_bpge_id-wtges - it_bpge_db-wtges.
783          ENDIF.
784        ELSE.
785          et_bpge_id-id = 'I'.
786        ENDIF.
787        et_bpge_id-epos = 'X'.
788        APPEND et_bpge_id.
789      ENDLOOP.
790
791    * Delta berechnen ...
792      IF i_flg_compute_delta <> space.
793    *    ... dann auch eventuell auf der DB
794    *    vorhandene Werte auf 0 bringen, wenn
795    *    sie nach dem Update 0 sein sollen.
796        SORT it_bpge BY lednr
797                        objnr
798                        posit
799                        trgkz
800                        wrttp
801                        geber
802                        versn
803                        vorga
804                        twaer.
805        LOOP AT it_bpge_db.
806          READ TABLE it_bpge
807               WITH KEY lednr = it_bpge_db-lednr
808                        objnr = it_bpge_db-objnr
809                        posit = it_bpge_db-posit
810                        trgkz = it_bpge_db-trgkz
811                        wrttp = it_bpge_db-wrttp
812                        geber = it_bpge_db-geber
813                        versn = it_bpge_db-versn
814                        vorga = it_bpge_db-vorga
815                        twaer = it_bpge_db-twaer
816               BINARY SEARCH.
817          CHECK sy-subrc <> 0.
818          CLEAR et_bpge_id.
819          et_bpge_id       = it_bpge_db.
820          et_bpge_id-wlges = 0 - it_bpge_db-wlges.
821          et_bpge_id-wtges = 0 - it_bpge_db-wtges.
822          et_bpge_id-id    = 'U'.
823          et_bpge_id-epos  = 'X'.
824          APPEND et_bpge_id.
825        ENDLOOP.
826      ENDIF.
827
828    * Was soll an BPJA-Sätzen neu hinzukommen?
829      SORT it_bpja_db BY lednr
830                         objnr
831                         posit
832                         trgkz
833                         wrttp
834                         gjahr
835                         geber
836                         versn
837                         vorga
838                         twaer.
839      LOOP AT it_bpja.
840        CLEAR et_bpja_id.
841        et_bpja_id = it_bpja.
842        READ TABLE it_bpja_db
843             WITH KEY lednr = it_bpja-lednr
844                      objnr = it_bpja-objnr
845                      posit = it_bpja-posit
846                      trgkz = it_bpja-trgkz
847                      wrttp = it_bpja-wrttp
848                      gjahr = it_bpja-gjahr
849                      geber = it_bpja-geber
850                      versn = it_bpja-versn
851                      vorga = it_bpja-vorga
852                      twaer = it_bpja-twaer
853             BINARY SEARCH.
854        IF sy-subrc = 0.
855          et_bpja_id-id = 'U'.
856    *      Delta bilden?
857          IF i_flg_compute_delta <> space.
858            et_bpja_id-wljhr = et_bpja_id-wljhr - it_bpja_db-wljhr.
859            et_bpja_id-wtjhr = et_bpja_id-wtjhr - it_bpja_db-wtjhr.
860          ENDIF.
861        ELSE.
862          et_bpja_id-id = 'I'.
863        ENDIF.
864        et_bpja_id-epos  = 'X'.
865        APPEND et_bpja_id.
866      ENDLOOP.
867
868    * Delta berechnen ...
869      IF i_flg_compute_delta <> space.
870    *    ... dann auch eventuell auf der DB
871    *    vorhandene Werte auf 0 bringen, wenn
872    *    sie nach dem Update 0 sein sollen.
873        SORT it_bpja BY lednr
874                        objnr
875                        posit
876                        trgkz
877                        wrttp
878                        gjahr
879                        geber
880                        versn
881                        vorga
882                        twaer.
883        LOOP AT it_bpja_db.
884          READ TABLE it_bpja
885               WITH KEY lednr = it_bpja_db-lednr
886                        objnr = it_bpja_db-objnr
887                        posit = it_bpja_db-posit
888                        trgkz = it_bpja_db-trgkz
889                        wrttp = it_bpja_db-wrttp
890                        gjahr = it_bpja_db-gjahr
891                        geber = it_bpja_db-geber
892                        versn = it_bpja_db-versn
893                        vorga = it_bpja_db-vorga
894                        twaer = it_bpja_db-twaer
895               BINARY SEARCH.
896          CHECK sy-subrc <> 0.
897          CLEAR et_bpja_id.
898          et_bpja_id       = it_bpja_db.
899          et_bpja_id-wljhr = 0 - it_bpja_db-wljhr.
900          et_bpja_id-wtjhr = 0 - it_bpja_db-wtjhr.
901          et_bpja_id-id    = 'U'.
902          et_bpja_id-epos  = 'X'.
903          APPEND et_bpja_id.
904        ENDLOOP.
905      ENDIF.
906
907    * Was soll an BPTR-Sätzen neu hinzukommen?
908      SORT it_bptr_db BY objnr
909                         posit
910                         trgkz
911                         wrttp
912                         geber
913                         versn.
914      LOOP AT it_bptr.
915        CLEAR et_bptr_id.
916        et_bptr_id = it_bptr.
917        CLEAR: et_bptr_id-ernam,
918               et_bptr_id-erdat,
919               et_bptr_id-aenam,
920               et_bptr_id-aedat.
921        READ TABLE it_bptr_db
922             TRANSPORTING NO FIELDS
923             WITH KEY objnr = it_bptr-objnr
924                      posit = it_bptr-posit
925                      trgkz = it_bptr-trgkz
926                      wrttp = it_bptr-wrttp
927                      geber = it_bptr-geber
928                      versn = it_bptr-versn
929             BINARY SEARCH.
930        IF sy-subrc = 0.
931          et_bptr_id-aenam = sy-uname.
932          et_bptr_id-aedat = sy-datlo.
933          et_bptr_id-id    = 'U'.
934        ELSE.
935          et_bptr_id-ernam = sy-uname.
936          et_bptr_id-erdat = sy-datlo.
937          et_bptr_id-aenam = sy-uname.
938          et_bptr_id-aedat = sy-datlo.
939          et_bptr_id-id    = 'I'.
940        ENDIF.
941        APPEND et_bptr_id.
942      ENDLOOP.
943
944      DELETE et_bpge_id
945        WHERE wlges = 0
946        AND   wtges = 0
947        AND   wlgev = 0
948        AND   wtgev = 0.
949
950      DELETE et_bpja_id
951        WHERE wljhr = 0
952        AND   wtjhr = 0
953        AND   wljhv = 0
954        AND   wtjhv = 0.
955
956    ENDFORM.
957    *>>>> END OF INSERTION <<<<<<
*--- End of ZAIMBNEW - 957 lines ---

----------------------------------------------------------------------------------------------------
Include          LKBPPEQU                                  Level 1    Page 2
Object           ZAIMBNEW                                  Lines 635
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:29
----------------------------------------------------------------------------------------------------
1      *KI4K034435:BARTHR Budgetierung: GJW - beantragen und genehmigen
2      *KI4K065178:BARTHR Remove include IFIFMCON_BL in LKBPPTOP (AL0/ALN)
3      *----------------------------------------------------------------------*
4      *   Equates                                                            *
5      *----------------------------------------------------------------------*
6      *            ACHTUNG:  Verwendet in SAPLKBPP und SAPLKBPT und SAPLKBPS *
7      *                                   ========     ========     ========
8      *                       und SAPLKBPH
9      *                           ========                                   *
10     *----------------------------------------------------------------------*
11     DATA: NEW_CURRENCY VALUE 'X',
12           NO_VIEW_IN_OW(1).        "Sichten in Objektwährung verboten
13
14     *-----Availability check
15     DATA: FIFM_AVA_CHECK VALUE 'X'.
16
17     *-----Periodenbudget
18     DATA: FIFM_PERIOD VALUE 'X'.
19
20     * 4.02A (April 99): Flag eliminated
21     *----Cover eligibility
22     *DATA: G_COVER_EL LIKE FMDY-XFELD VALUE 'X'.
23
24
25
26     DATA:
27
28     *-------Werttypen extern Budgetprozessor-------------------------------*
29      L_WPLAN       LIKE BPGE-WRTTP VALUE  '01',     "Planung
30      L_WSPLAN      LIKE BPGE-WRTTP VALUE  '10',     "Planung stat.
31      L_WBUDGET     LIKE BPGE-WRTTP VALUE  '41',     "Budget
32      L_WCOMMIT     LIKE BPGE-WRTTP VALUE  '42',     "Verfügt
33      L_WRELEASE    LIKE BPGE-WRTTP VALUE  '45',     "Freigabe
34      L_WFCAFOR     LIKE BPGE-WRTTP VALUE  '73',     "Finanz carry forward
35      L_WPCAFOR     LIKE BPGE-WRTTP VALUE  '74',     "Finanz carry forward
36      L_WIBUDGET    LIKE BPGE-WRTTP VALUE  '47',     "Invest.budget
37      L_WIPLAN      LIKE BPGE-WRTTP VALUE  '48',     "Invest.plan
38     * Maßnahmenanforderungen                           BEGIN "E40K000891
39      L_WQPLAN      LIKE BPGE-WRTTP VALUE  '39',     "Plan
40      L_WQRPLAN     LIKE BPGE-WRTTP VALUE  '40',     "Plan, davon echte Inv.
41     *                                                  END   "E40K000891
42     *---------------------------------------------------------------------*
43     *---------------------------------------------------------------------*
44     * Maßnahmenanforderungen  Cash Flow             "ALRK027735
45      L_WQCFPLAN    LIKE BPGE-WRTTP VALUE  '52',     "Cash Flow
46
47     *-----finance budget payments
48      L_WFBUDGET    LIKE BPGE-WRTTP VALUE  '43',     "Finanzbudget
49      L_WFBUDRES    LIKE BPGE-WRTTP VALUE  '85',     "FBud reserviert
50      L_WFBUDNOTE   LIKE BPGE-WRTTP VALUE  '86',     "FBud vorgemerkt
51      L_WFCOMMIT    LIKE BPGE-WRTTP VALUE  '44',     "Finanzverfügt
52      L_WFRELEASE   LIKE BPGE-WRTTP VALUE  '46',     "Finanzfreigabe
53      L_WFRELRES    LIKE BPGE-WRTTP VALUE  '87',     "FFreigabe reserviert
54      L_WFRELNOTE   LIKE BPGE-WRTTP VALUE  '88',     "FFreigabe vorgemerkt
55      L_WFHRINT     LIKE BPGE-WRTTP VALUE  '9D',     "HR Integration
56
57      L_WPBUDGET    LIKE BPGE-WRTTP VALUE  '70',     "FBud Verpfl.
58      L_WPBUDRES    LIKE BPGE-WRTTP VALUE  '89',     "FBud Verpfl. res.
59      L_WPBUDNOTE   LIKE BPGE-WRTTP VALUE  '90',     "FBud Verpfl. vor.
60      L_WPCOMMIT    LIKE BPGE-WRTTP VALUE  '71',     "Finanzverfügt Verpfl.
61      L_WPRELEASE   LIKE BPGE-WRTTP VALUE  '72',     "FFreigabe Verpfl.
62      L_WPRELRES    LIKE BPGE-WRTTP VALUE  '91',     "FFreigabe Verpfl. res.
63      L_WPRELNOTE   LIKE BPGE-WRTTP VALUE  '92',     "FFreigabe Verpfl. vor.
64
65      L_WFFINPLAN   LIKE BPGE-WRTTP VALUE  '93',     "Kommunen: Finanzplan
66      L_WFBUDSTAT   LIKE BPGE-WRTTP VALUE  '94',     "Kommunen: Stat. Budget
67      L_WFBUDRERG   LIKE BPGE-WRTTP VALUE  '99',     "Kommunen: Rechnungserg.
68      L_WFSTAT      LIKE BPGE-WRTTP VALUE  '4A',     "Kom: Stat. Zahlungsbud.
69      L_WFBALBUD    LIKE BPGE-WRTTP VALUE  '4B',     "Saldenbudget
70      L_WFEXPBUD    LIKE BPGE-WRTTP VALUE  '4C',     "ZB: Ausg. Bud auf Epos
71      L_WFEXCBUD    LIKE BPGE-WRTTP VALUE  '7C',     "VB: Ausg. Bud auf Epos
72      L_WFRERGSTAT  LIKE BPGE-WRTTP VALUE  '9A',     "Kom: Stat. Rechngserg.
73      L_WFFIPLSTAT  LIKE BPGE-WRTTP VALUE  '9B',     "Kom: Stat. Finanzplan
74      L_WFBALFINPL  LIKE BPGE-WRTTP VALUE  '9C',     "Kom: Saldenfinanzplan
75      L_WFBUDTOT    LIKE BPGE-WRTTP VALUE  '9E',     "Kom: gen. GesKosten
76
77     *---------------------------------------------------------------------*
78      L_WACTUAL     LIKE BPGE-WRTTP VALUE  '04',     "Ist
79      L_WSACTUAL    LIKE BPGE-WRTTP VALUE  '11',     "Ist stat.
80      L_WPREQ       LIKE BPGE-WRTTP VALUE  '21',     "BANF-Obligo
81      L_WPORDER     LIKE BPGE-WRTTP VALUE  '22',     "BE-Obligo
82      L_WMATRES     LIKE BPGE-WRTTP VALUE  '23',     "Materialres
83      L_WFUNRES     LIKE BPGE-WRTTP VALUE  '24',     "Manuelles Obl
84      L_WOUTORDER   LIKE BPGE-WRTTP VALUE  '25',     "Restplan Auftr
85      L_WFIXPRICE   LIKE BPGE-WRTTP VALUE  '26',     "Festpreisobligo
86      L_WBESTAND    LIKE BPGE-WRTTP VALUE  '31',     "Bestand
87      L_WRUECK      LIKE BPGE-WRTTP VALUE  '32',     "Rueckstellungen
88      L_WOFFER      LIKE BPGE-WRTTP VALUE  '28',"Kundenangebot #EC NO_M_RISC3
89      L_WCLIENT     LIKE BPGE-WRTTP VALUE  '29',"Kundenauftrag #EC NO_M_RISC3
90      L_WREVE       LIKE BPGE-WRTTP VALUE  '01',     "Planerlöse
91      L_WFPLAN      LIKE BPGE-WRTTP VALUE  '62',     "Zhlng Finanzplan
92      L_WFPLANDP    LIKE BPGE-WRTTP VALUE  '6A',     "AnZhlng Finanzplan
93      L_WZPREQ      LIKE BPGE-WRTTP VALUE  '50',     "Zhlng BANF
94      L_WZPORDER    LIKE BPGE-WRTTP VALUE  '51',     "Zhlng BE
95      L_WZDPRQ      LIKE BPGE-WRTTP VALUE  '58',     "Zhlng AA
96      L_WZKDP       LIKE BPGE-WRTTP VALUE  '61',     "Zhlng AZ
97      L_WZGORE      LIKE BPGE-WRTTP VALUE  '52',     "Zhlng WE
98      L_WZINVC      LIKE BPGE-WRTTP VALUE  '54',     "Zhlng RE / AV
99      L_WZPAYM      LIKE BPGE-WRTTP VALUE  '57',     "Zhlng ZA
100     L_WZMRES      LIKE BPGE-WRTTP VALUE  '65',     "Zhlng MR
101     L_WVMRES      LIKE BPGE-WRTTP VALUE  '69',     "VerpflErmaechtigung MR
102     L_WZCOSK      LIKE BPGE-WRTTP VALUE  '95',     "Sek. Kostenbuch. CO
103     L_WCOPARK     LIKE BPGE-WRTTP VALUE  '60',     "parked CO documents
104
105    *       Vorgaenge auf interne BP-Tabellen
106    *       Daten dieser Vorgaenge werden nicht auf BP-Datenbanken abgelegt
107    *       -             Kennung interner Vorgang
108     L_VINTERN                     VALUE  '*'   , "interne Daten
109     L_VKSTA       LIKE BPGE-VORGA VALUE  '*KOA', "Koarten intern
110    * nicht mehr benötigt ab Release 4.0A, (Erlösartenplanwerte werden
111    * ab 4.0A zusammen mit Gesamtplanung verbucht)
112    * L_VKSTAV      LIKE BPGE-VORGA VALUE  '*KOV', "Koarten verteilt
113     L_VKSTE       LIKE BPGE-VORGA VALUE  '*KOE', "Erloese intern
114    * nicht mehr benötigt ab Release 4.0A, (Kostenartenplanwerte werden
115    * ab 4.0A zusammen mit Gesamtplanung verbucht)
116    * L_VKSTEV      LIKE BPGE-VORGA VALUE  '*KVE', "Erloese intern verteilt
117     L_VKALI       LIKE BPGE-VORGA VALUE  '*KAL', "Kalkul  intern
118     L_VADD        LIKE BPGE-VORGA VALUE  '*ADD', "additive Aufträge
119     L_VADG        LIKE BPGE-VORGA VALUE  '*ADG', "add. Auftr. gesamt
120     L_VADK        LIKE BPGE-VORGA VALUE  '*ADK', "add. Auftr. kumuliert
121     L_VSTAT       LIKE BPGE-VORGA VALUE  '*STA', "stat. Kennzahlen
122     L_VCUORDER    LIKE BPGE-VORGA VALUE  '*SDI', "Kundenauftragswert
123     L_VBUD_CF     LIKE BPGE-VORGA VALUE  '*CFO', "InvPg CF org
124     L_VBN0_CF     LIKE BPGE-VORGA VALUE  '*CFS', "InvPg CF suppl
125     L_VBR0_CF     LIKE BPGE-VORGA VALUE  '*CFR', "InvPg CF ret
126     L_VFPL        LIKE BPGE-VORGA VALUE  '*FPL', "ab 4.0A Fakturierungsplan
127     L_VPREL       LIKE BPGE-VORGA VALUE  '*!xx', "Vorerfassung
128     L_VPRES       LIKE BPGE-VORGA VALUE  '*?xx', "Vorerfassung reserviert
129     L_VFMHR       LIKE BPGE-VORGA VALUE  '*FHR',
130
131    *       Vorgaenge auf BP-Dateien und interne BP-Tabellen
132    *       Daten dieser Vorgaenge werden auf BP-Datenbanken abgelegt
133    *       -             Budget
134     L_VBUD        LIKE BPGE-VORGA VALUE  'KBUD',
135    *       -             Budget anzeigen
136     L_VABUD       LIKE BPGE-VORGA VALUE  'ABUD',
137    *       -             Nachtrag
138     L_VBN0        LIKE BPGE-VORGA VALUE  'KBN0',
139    *       -             GJW-Rest manuell (Kommunen)                 "DKOM
140     L_VBNC        LIKE BPGE-VORGA VALUE  'KBNC',
141    *       -             Budgeterhöhende Einnahme
142     L_VBI0        LIKE BPGE-VORGA VALUE  'KBI0',  "manuell
143     L_VBI1        LIKE BPGE-VORGA VALUE  'KBI1',  "maschinell
144     L_VBI3        LIKE BPGE-VORGA VALUE  'KBI3',  "Abrufverf Sender   "DKOM
145     L_VBI4        LIKE BPGE-VORGA VALUE  'KBI4',  "Abrufverf Receiver "DKOM
146     L_VBI3_INT    LIKE BPGE-VORGA VALUE  '*BI3',  "Abrufverf INTERN   "DKOM
147    *       -             Rueckgabe
148     L_VBR0        LIKE BPGE-VORGA VALUE  'KBR0',
149    *       -             Rueckgabe aus Resten (Kommunen)             "DKOM
150     L_VBRC        LIKE BPGE-VORGA VALUE  'KBRC',
151    *       -             Mindereinnahmen      (Kommunen)             "DKOM
152     L_VBRD        LIKE BPGE-VORGA VALUE  'KBRD',
153    *       -             Freigabe
154     L_VBFR        LIKE BPGE-VORGA VALUE  'KBFR',
155     L_VBF1        LIKE BPGE-VORGA VALUE  'KBF1',                     "DKOM
156     L_VBF2        LIKE BPGE-VORGA VALUE  'KBF2',                     "DKOM
157     L_VBF3        LIKE BPGE-VORGA VALUE  'KBF3',                     "DKOM
158     L_VBF4        LIKE BPGE-VORGA VALUE  'KBF4',                     "DKOM
159     L_VBF5        LIKE BPGE-VORGA VALUE  'KBF5',                     "DKOM
160    *       -             Lokale Sperre
161     L_VBLR        LIKE BPGE-VORGA VALUE  'KBLR',                     "DKOM
162     L_VBL1        LIKE BPGE-VORGA VALUE  'KBL1',                     "DKOM
163     L_VBL2        LIKE BPGE-VORGA VALUE  'KBL2',                     "DKOM
164     L_VBL3        LIKE BPGE-VORGA VALUE  'KBL3',                     "DKOM
165     L_VBL4        LIKE BPGE-VORGA VALUE  'KBL4',                     "DKOM
166     L_VBL5        LIKE BPGE-VORGA VALUE  'KBL5',                     "DKOM
167    *       -             Umbuchungen
168     L_VBUF        LIKE BPGE-VORGA VALUE  'KBUF', "Umbu E->A send     "DKOM
169     L_VBUG        LIKE BPGE-VORGA VALUE  'KBUG', "Umbu E->A empf     "DKOM
170     L_VBUF_INT    LIKE BPGE-VORGA VALUE  '*KBF', "Umbu E->A intern   "DKOM
171     L_VBUB        LIKE BPGE-VORGA VALUE  '*KBU',
172     L_VBUE        LIKE BPGE-VORGA VALUE  'KBUE',
173     L_VBUS        LIKE BPGE-VORGA VALUE  'KBUS',
174     L_VBUT        LIKE BPGE-VORGA VALUE  'KBUT',
175    *       -             Verfuegbarkeitskontrolle
176     L_VCOM        LIKE BPGE-VORGA VALUE  'KBFC',
177     L_VBFS        LIKE BPGE-VORGA VALUE  'KBFS', "Soft-Commitments
178     L_VBFF        LIKE BPGE-VORGA VALUE  'KBFF', "Fremd-Verfügt
179    *       -             Budget Kalkulation
180     L_VBUC        LIKE BPGE-VORGA VALUE  'KBUC',
181    *       -             Strukturplanwert
182     L_VPLAN       LIKE BPGE-VORGA VALUE  'KSTP', "Kosten
183    *** L_VKPE        LIKE BPGE-VORGA VALUE  'RKP5', "Erloese
184     L_VKPE        LIKE BPGE-VORGA VALUE  'KSTR', "Erloese
185    *       -             Finanzplanwert
186     L_VFIPL       LIKE BPGE-VORGA VALUE  'FIPL',
187    *       -             Einzelkalkulation ohne Kostenart auf BP-Db abgeleg
188     L_VKALC       LIKE BPGE-VORGA VALUE  'KSTE',
189    *       Kostenartenplanung
190     L_VKPK        LIKE BPGE-VORGA VALUE  'RKP1', "Kostenartenplan
191     L_VKPL        LIKE BPGE-VORGA VALUE  'RKP3', "Leistungen
192     L_VKPS        LIKE BPGE-VORGA VALUE  'RKP4', "Statistik
193     L_VKP5        LIKE BPGE-VORGA VALUE  'RKP5', "Erloesarten
194     L_VKZPP       LIKE BPGE-VORGA VALUE  'KZPP', "Zuschlaege
195    *       Einzelkalkulation alt bis 3.0
196     L_VKEKB       LIKE BPGE-VORGA VALUE  'KEKB', "Einzelkalkulation
197     L_VKEKZ       LIKE BPGE-VORGA VALUE  'KEKZ', "Zuschlaege
198    *       Einzelkalkulation neu ab 3.0
199     L_VKEKP       LIKE BPGE-VORGA VALUE  'KEKP', "Einzelkalkulation
200     L_VKEKS       LIKE BPGE-VORGA VALUE  'KEKS', "Zuschlaege
201     L_VKEKE       LIKE BPGE-VORGA VALUE  'KEKE', "Einzelbestand     "579095
202    *       Einzelpostenvorgaenge (Statusverwaltung)
203     L_VKEPB       LIKE BPGE-VORGA VALUE  'KEPB', "EP's Budget
204     L_VKEPP       LIKE BPGE-VORGA VALUE  'KEPP', "EP's K/E-Plan
205
206    *       - Umbuchungen Uebertraege/Vorgriffe  manuell
207     L_VKBU1       LIKE BPGE-VORGA VALUE  'KBU1', "S. Uebertrag
208     L_VKBU2       LIKE BPGE-VORGA VALUE  'KBU2', "E. Uebertrag
209     L_VKBU1_INT   LIKE BPGE-VORGA VALUE  '*KB1', "Uebertrag
210     L_VKBU3       LIKE BPGE-VORGA VALUE  'KBU3', "S. Vorgriff
211     L_VKBU4       LIKE BPGE-VORGA VALUE  'KBU4', "E. Vorgriff
212     L_VKBU3_INT   LIKE BPGE-VORGA VALUE  '*KB3', "Vorgriff
213     L_VKBU5       LIKE BPGE-VORGA VALUE  'KBU5', "Transfer Ueb.
214     L_VKBU6       LIKE BPGE-VORGA VALUE  'KBU6', "Transfer Vorg.
215
216    *       - Umbuchung 'Übertragung maschinell'
217    *       (bisher nur im Standard; im ISPS noch nicht realisiert)
218     L_VKBV1       LIKE BPGE-VORGA VALUE  'KBV1', "Sender
219     L_VKBV2       LIKE BPGE-VORGA VALUE  'KBV2', "Empfänger (receiver)
220     L_VKBV3       LIKE BPGE-VORGA VALUE  'KBV3', "Transfer
221
222    *       - Umbuchungen Uebertraege/Vorgriffe  maschinell CARRY-OVER
223     L_VKBW1       LIKE BPGE-VORGA VALUE  'KBW1', "S. Uebertrag
224     L_VKBW2       LIKE BPGE-VORGA VALUE  'KBW2', "E. Uebertrag
225     L_VKBW1_INT   LIKE BPGE-VORGA VALUE  '*KBW', "Uebertrag
226     L_VKBW3       LIKE BPGE-VORGA VALUE  'KBW3', "S. Vorgriff
227     L_VKBW4       LIKE BPGE-VORGA VALUE  'KBW4', "E. Vorgriff
228     L_VKBW5       LIKE BPGE-VORGA VALUE  'KBW5', "Transfer Ueb.
229     L_VKBW6       LIKE BPGE-VORGA VALUE  'KBW6', "Transfer Vorg.
230
231    *----- Kommunen: Umbuchungen aus echter Df (Coverpool)            "DKOM
232     L_VKBW7       LIKE BPGE-VORGA VALUE  'KBW7', "S. Coverpool       "DKOM
233     L_VKBW8       LIKE BPGE-VORGA VALUE  'KBW8', "E. Coverpool       "DKOM
234     L_VKBW9       LIKE BPGE-VORGA VALUE  'KBW9', "Tr. Coverpool      "DKOM
235     L_VKBW9_INT   LIKE BPGE-VORGA VALUE  '*BW9', "Coverpool intern   "DKOM
236
237    *       Kommunen
238     L_VKBKR       LIKE BPGE-VORGA VALUE  'KBKR', "Rechnungsergebnis
239     L_VKBRA       LIKE BPGE-VORGA VALUE  'KBRA', "Budgsp. GJW  "KI4K034435
240
241    *       - Sammelnachweise
242     L_VKBU7       LIKE BPGE-VORGA VALUE  'KBU7', "Semder
243     L_VKBU8       LIKE BPGE-VORGA VALUE  'KBU8', "Empfaenger
244     L_VKBU9       LIKE BPGE-VORGA VALUE  'KBU9', "Transfer
245     L_VKBU7_INT   LIKE BPGE-VORGA VALUE  '*KB7', "Sammelnachweis
246
247    *       SD Integration
248     L_VSDOR       LIKE BPGE-VORGA VALUE  'SDOR',
249     L_VSDQU       LIKE BPGE-VORGA VALUE  'SDQU', "SD-Angebot
250     L_VPSFP       LIKE BPGE-VORGA VALUE  'PSFP', "ab 4.0A Fakturierungsplan
251    *       Korrektursätze für RW-Interface
252     L_VCORR       LIKE BPGE-VORGA VALUE  'CORR',
253     L_VEABR       LIKE BPGE-VORGA VALUE  'KOAR', "Entlastung aus Abrechn.
254    *       Finanzmittelrechnug
255     L_VNORM       LIKE BPGE-VORGA VALUE  'KAFM',
256     L_VAZOB       LIKE BPGE-VORGA VALUE  'KAZO', "Anzahlung ohne BE
257     L_VAZMB       LIKE BPGE-VORGA VALUE  'KAZM', "Anzahlung mit BE
258     L_VMWST       LIKE BPGE-VORGA VALUE  'KAVR', "Mehrwertsteuer
259
260    *-------Applikationen--------------------------------------------------*
261     L_FIPL        LIKE TBP1C-APPLIK VALUE  'A',  "Finanzplanung
262     L_IPROG       LIKE TBP1C-APPLIK VALUE  'I',  "Investitionsprogramme
263     L_IREQUEST    LIKE TBP1C-APPLIK VALUE  'Q',  "Maßn.Anf.    "E40K000891
264     L_COST        LIKE TBP1C-APPLIK VALUE  'C',  "Kostenstellen
265     L_PROJECT     LIKE TBP1C-APPLIK VALUE  'P',  "Projekt
266     L_ORDER       LIKE TBP1C-APPLIK VALUE  'O',  "Auftrag
267     L_COFA        LIKE TBP1C-APPLIK VALUE  'F',  "CO-Fertigungsauftrag
268     L_FUNDS       LIKE TBP1C-APPLIK VALUE  'M',  "Haushaltsmanagement
269
270    *-----Sub-Applikationen------------------------------------------------
271     L_FUNDS_DKOM  LIKE TBP1C-APPLIK VALUE  'K',  "Dt.Kommunen (in l_funds)
272
273    *-------Traegerkennzeichen---------------------------------------------*
274     L_ARCHIV      LIKE BPIN-TRGKZ VALUE  'A',
275     L_INV_CF      LIKE BPIN-TRGKZ VALUE  'B', "InvProgramm Vortrag
276     L_INV_FU      LIKE BPIN-TRGKZ VALUE  'C', "InvProgramm Vorausschau
277     L_NODE        LIKE BPIN-TRGKZ VALUE  'N',
278     L_TRGKZP      LIKE BPIN-TRGKZ VALUE  'P', "Projekt
279     L_SINGLE      LIKE BPIN-TRGKZ VALUE  'S',
280     L_TRGKZ1      LIKE BPIN-TRGKZ VALUE  '1', "AUFTRAG ADDITIV
281     L_TRGKZ2      LIKE BPIN-TRGKZ VALUE  '2', "AUFTRAG ADDITIV
282     L_TRGKZ3      LIKE BPIN-TRGKZ VALUE  '3', "AUFTRAG ADDITIV
283     L_TRGKZ4      LIKE BPIN-TRGKZ VALUE  '4', "AUFTRAG ADDITIV
284     L_TRGKZ5      LIKE BPIN-TRGKZ VALUE  '5', "AUFTRAG ADDITIV geloescht
285     L_TRGKZ6      LIKE BPIN-TRGKZ VALUE  '6', "AUFTRAG DISP.
286     L_TRGKZ7      LIKE BPIN-TRGKZ VALUE  '7', "AUFTRAG DISP.
287     L_TRGKZ8      LIKE BPIN-TRGKZ VALUE  '8', "AUFTRAG DISP.
288     L_TRGKZ9      LIKE BPIN-TRGKZ VALUE  '9', "AUFTRAG DISP.
289
290    *-------Funktionen-----------------------------------------------------*
291     F_CFPLOR LIKE BPIN-FCODE VALUE  'PFOR', "Plan   CO-Fertigung
292     F_ETCOOR LIKE BPIN-FCODE VALUE  'ECOR', "Etat   Stellen
293     F_BUPROR LIKE BPIN-FCODE VALUE  'BPOR', "Budget Projekt Orig.
294     F_BUPRFR LIKE BPIN-FCODE VALUE  'FPFR', "Freig. Projekt
295     F_BUPRUB LIKE BPIN-FCODE VALUE  'BPUB', "Umb.   Projekt
296     F_BUPRN0 LIKE BPIN-FCODE VALUE  'BPN0', "Nach.  Projekt
297     F_BUPRR0 LIKE BPIN-FCODE VALUE  'BPR0', "Rück.  Projekt
298     F_BUPRXX LIKE BPIN-FCODE VALUE  'BPXX', "Hier.  Proj. Budget
299     F_BUPRFX LIKE BPIN-FCODE VALUE  'FPXX', "Hier.  Proj. Freig.
300     F_BUPRBA LIKE BPIN-FCODE VALUE  'BPBA', "Index  Proj. Budget
301     F_BUPRCF LIKE BPIN-FCODE VALUE  'BPCF', "Proj carry forward
302     F_PLPROR LIKE BPIN-FCODE VALUE  'PPOR', "KostenPlan Projekt
303     F_PLPRYY LIKE BPIN-FCODE VALUE  'PPYY', "K.P.Projekt VersCpy
304     F_PLPRYR LIKE BPIN-FCODE VALUE  'RPYY', "Erloesplan Proj VersCpy
305     F_PLPRRE LIKE BPIN-FCODE VALUE  'RPRE', "ErloesPlan Projekt
306     F_PLPRFI LIKE BPIN-FCODE VALUE  'PPFI', "Finanzplan Projekt
307     F_PLPRXX LIKE BPIN-FCODE VALUE  'PPXX', "Hier.  Projekt
308    * Neuaufbau Budgetverteiltwerte Projekt                   "N"ALRK010965
309     F_BUPRVX LIKE BPIN-FCODE VALUE  'BPVX',                  "N"ALRK010965
310     F_BUPREU LIKE BPIN-FCODE VALUE  'BPEU', "EURO-Korrektur Projekt  "EURO
311     F_BUOREU LIKE BPIN-FCODE VALUE  'BOEU', "EURO-Korrektur Order    "EURO
312     F_PLOROR LIKE BPIN-FCODE VALUE  'POOR', "Plan   CO-Auftrag
313     F_PLORYY LIKE BPIN-FCODE VALUE  'POYY', "Plan CO-Auftrag VersCpy
314     F_BUOROR LIKE BPIN-FCODE VALUE  'BOOR', "Budget CO-Auftrag
315     F_BUORN0 LIKE BPIN-FCODE VALUE  'BON0', "Nach.  CO-Auftrag
316     F_BUORR0 LIKE BPIN-FCODE VALUE  'BOR0', "Rück.  CO-Auftrag
317     F_BUORBA LIKE BPIN-FCODE VALUE  'BOBA', "Index  CO-Auftrag
318     F_BUORCF LIKE BPIN-FCODE VALUE  'BOCF', "Carry forward CO-Auftrag
319    * Maßnahmenanforderungen                           BEGIN "E40K000891
320     F_PLPQOR LIKE BPIN-FCODE VALUE  'PQOR', "Plan Maßnahmenanforderungen
321     F_PLPQIN LIKE BPIN-FCODE VALUE  'PQIN', "Plan Invest Maßn.Anforderungen
322    *                                                  END   "E40K000891
323    * Cash Flow Maßnahmenanforderung [ALRK027734]
324     F_PLPQVR LIKE BPIN-FCODE VALUE  'PQVR', "Plan Cash Flow Maßn.Anf
325
326     F_FIPLAN LIKE BPIN-FCODE VALUE  'PAOR', "Plan   FIFM
327    *-----Finanzbudget - allgemein
328     F_FUBUCC LIKE BPIN-FCODE VALUE  'BMCC', "Budgettraeger FIFM
329     F_FUBUI1 LIKE BPIN-FCODE VALUE  'ZMI1', "Einn.  FIFM maschinell
330     F_FUBUCF LIKE BPIN-FCODE VALUE  'ZMCF', "CF     FIFM
331     F_FUBUTR LIKE BPIN-FCODE VALUE  'ZMTR', "Budgetübertragung masch.
332                                             "(general budget transfer)
333     F_FUBUEC LIKE BPIN-FCODE VALUE  'ZMCA', "Kalkulation FIFM
334     F_FUBUHR LIKE BPIN-FCODE VALUE  'ZMHR', "Positionsmanagement
335     F_FUBUEU LIKE BPIN-FCODE VALUE  'ZMEU', "EURO Korrekturprogramm
336    *-----Finanzbudget - Deutsche Kommunen
337     F_FUBUO1 LIKE BPIN-FCODE VALUE  'BMO1', "Budget FIFM HHPlan
338     F_FUBUO2 LIKE BPIN-FCODE VALUE  'BMO2', "Budget FIFM HHPlan Sammelnw
339     F_FUBUO3 LIKE BPIN-FCODE VALUE  'BMO3', "Budget FIFM RechErg
340     F_FUBUO4 LIKE BPIN-FCODE VALUE  'BMO4', "Budget FIFM RechErg Sammelnw
341     F_FUBUO5 LIKE BPIN-FCODE VALUE  'BMO5', "Budget FIFM NT-HHPlan
342     F_FUBUO6 LIKE BPIN-FCODE VALUE  'BMO6', "Budget FIFM NT-HHPlan Sammelnw
343     F_FUBUOA LIKE BPIN-FCODE VALUE  'BMOA', "SalHie FIFM Saldenbudget
344     F_FUBUM1 LIKE BPIN-FCODE VALUE  'BMM1', "Budget FIFM RechErg PJhr masch
345     F_FUBUM2 LIKE BPIN-FCODE VALUE  'BMM2', "Budget FIFM Vorjw uebern masch
346     F_FUBUMA LIKE BPIN-FCODE VALUE  'BMMA', "SalHie FIFM Saldenbudget masch
347     F_FUBUMB LIKE BPIN-FCODE VALUE  'BMMB', "SalHie FIFM SaldenfinPla masch
348     F_FUBUS1 LIKE BPIN-FCODE VALUE  'ZMS1', "Budget FIFM ZB-Org  stat masch
349     F_FUBUS2 LIKE BPIN-FCODE VALUE  'ZMS2', "Budget FIFM FiPl-Orgstat masch
350     F_FUBUS3 LIKE BPIN-FCODE VALUE  'ZMS3', "Budget FIFM RechErg stat masch
351     F_FUBUS4 LIKE BPIN-FCODE VALUE  'ZMS4', "Budget FIFM ZB-NT   stat masch
352     F_FUBUS5 LIKE BPIN-FCODE VALUE  'ZMS5', "Budget FIFM FiPl-Orgstat masch
353    * note 554015
354     F_FUBUS6 LIKE BPIN-FCODE VALUE  'ZMS6', "Budget FIFM Umbuchngstat masch
355     F_FUBUS7 LIKE BPIN-FCODE VALUE  'ZMS7', "Budget FIFM Umb emp stat masch
356    * end of note 554015
357     F_FUBUSA LIKE BPIN-FCODE VALUE  'ZMSA', "SalHie FIFM Ansatz  stat masch
358     F_FUBUSB LIKE BPIN-FCODE VALUE  'ZMSB', "SalHie FIFM RechErg stat masch
359     F_FUBUSC LIKE BPIN-FCODE VALUE  'ZMSC', "SalHie FIFM Nachtrg stat masch
360     F_FUBUY1 LIKE BPIN-FCODE VALUE  'BMY1', "Budget FIFM VersCpy DKOM
361     F_FUBUY2 LIKE BPIN-FCODE VALUE  'BMY2', "Budget FIFM Uebernehm ZB DKOM
362     F_FUBUY3 LIKE BPIN-FCODE VALUE  'BMY3', "Budget FIFM Ueberneh FiP DKOM
363     F_FUXUY2 LIKE BPIN-FCODE VALUE  'XMY2', "Budget FIFM Uebernehm VB DKOM
364     F_FUBUFI LIKE BPIN-FCODE VALUE  'WMOR', "Budget FIFM FIPL -> KBPT
365     F_FUBUFS LIKE BPIN-FCODE VALUE  'SMOR', "Budget FIFM Saldenbud -> KBPT
366     F_FUBUFT LIKE BPIN-FCODE VALUE  'TMOR', "Budget FIFM Saldenfipl -> KBPT
367     F_FUBUFH LIKE BPIN-FCODE VALUE  'HMOR', "Budget FIFM glob HHPlan-> KBPT
368     F_FUBUFP LIKE BPIN-FCODE VALUE  'PMOR', "Budget FIFM Komm PB Bew-> KBPT
369     F_FUBUFQ LIKE BPIN-FCODE VALUE  'QMOR', "Budget FIFM glob CB Bew-> KBPT
370     F_FUBUFM LIKE BPIN-FCODE VALUE  'MMOR', "Budget FIFM FGrp PB Bew-> KBPT
371     F_FUBUFN LIKE BPIN-FCODE VALUE  'NMOR', "Budget FIFM glob CB Bew-> KBPT
372
373    *-----Finanzbudget - Zahlungen
374     F_FUBUOR LIKE BPIN-FCODE VALUE  'BMOR', "Budget FIFM
375     F_FUBUUB LIKE BPIN-FCODE VALUE  'BMUB', "Umb.   FIFM
376     F_FUBUN0 LIKE BPIN-FCODE VALUE  'BMN0', "Nach.  FIFM
377     F_FUBUR0 LIKE BPIN-FCODE VALUE  'BMR0', "Rück.  FIFM
378     F_FUBUFR LIKE BPIN-FCODE VALUE  'FMFR', "Frei   FIFM
379     F_FUBUF1 LIKE BPIN-FCODE VALUE  'FMF1', "Frei   FIFM MassFr masch ZB
380     F_FUBUF2 LIKE BPIN-FCODE VALUE  'FMF2', "Frei   FIFM Neuaufb FrGrp ZB
381     F_FUBUF3 LIKE BPIN-FCODE VALUE  'FMF3', "Frei   FIFM Sammelfrei ZB
382     F_FUBUF4 LIKE BPIN-FCODE VALUE  'FMF4', "Frei   FIFM Sammelfrei VB
383     F_FUBUF5 LIKE BPIN-FCODE VALUE  'FML5', "Frei   FIFM Sammelsperre ZB
384     F_FUBUF6 LIKE BPIN-FCODE VALUE  'FML6', "Frei   FIFM Sammelsperre VB
385     F_FUBUF7 LIKE BPIN-FCODE VALUE  'FMF7', "Frei   FIFM Neuaufb FrGrp VB
386     F_FUBUF8 LIKE BPIN-FCODE VALUE  'FMF8', "Frei   FIFM MassFr masch VB
387     F_FUBUBA LIKE BPIN-FCODE VALUE  'BMBA', "Index  FIFM    Budget
388     F_FUBUCA LIKE BPIN-FCODE VALUE  'BMBB', "Index  FIFM    Carry-forw.
389     F_FUBUBS LIKE BPIN-FCODE VALUE  'BMXS', "DKOM PB,CB,Freig PRUEFEN
390     F_FUBUBT LIKE BPIN-FCODE VALUE  'BMXT', "DKOM Saldenbud.  PRUEFEN
391     F_FUBUBU LIKE BPIN-FCODE VALUE  'BMXU', "DKOM PB,CB,Freig Neua.Verteilt
392     F_FUBUBV LIKE BPIN-FCODE VALUE  'BMXV', "DKOM Saldenbud.  Naua.Verteilt
393     F_FUBUBX LIKE BPIN-FCODE VALUE  'BMXX', "Bu+Fre FIFM Neuaufbau Verteilt
394     F_FUBUBW LIKE BPIN-FCODE VALUE  'BMXW', "Bu+Fre FIFM Pruefen
395     F_FUBUBY LIKE BPIN-FCODE VALUE  'BMYY', "Budget FIFM    VersCpy
396     F_FUBUFY LIKE BPIN-FCODE VALUE  'FMYY', "Frei   FIFM    VersCpy
397     F_FUBUBY1 LIKE BPIN-FCODE VALUE  'ZMYB1', "Budget FIFM VersCpy reassign
398     F_FUBUFY1 LIKE BPIN-FCODE VALUE  'ZMYF1', "Frei   FIFM VersCpy reassign
399     F_FUBUBZ LIKE BPIN-FCODE VALUE  'BMZZ', "Bu     FIFM Hochsummieren
400     F_FUBUFZ LIKE BPIN-FCODE VALUE  'FMZZ', "Frei   FIFM Hochsummieren
401     F_FUBUBZY LIKE BPIN-FCODE VALUE 'BMZY', "Bu     FIFM Neuaufbau Budget
402     F_FUBUFZY LIKE BPIN-FCODE VALUE 'FMZY', "Frei   FIFM Neuaufbau Freigabe
403     F_FUBUBZR LIKE BPIN-FCODE VALUE 'BMZR', "Bu     FIFM Neuaufbau RIB
404    *-----Finanzbudget - Neuaufbau Budgetartengerecht, standard + Kommunen
405     F_FUBUBZX LIKE BPIN-FCODE VALUE 'BMZX', "Bu     FIFM Neuaufb Budgetart
406     F_FUBUFZX LIKE BPIN-FCODE VALUE 'FMZX', "Frei   FIFM Neuaufb Freigabe
407     F_FUPUAZX LIKE BPIN-FCODE VALUE 'BMZXP', "Bu    FIFM Neuaufb Finanzplan
408     F_FUOUBZX LIKE BPIN-FCODE VALUE 'BMZXO', "Bu    FIFM Neuaufb Rechngserg
409     F_FUAUBZX LIKE BPIN-FCODE VALUE 'BMZXA', "Bu    FIFM Neuaufb Saldenbud
410     F_FUAUAZX LIKE BPIN-FCODE VALUE 'BMZXAP', "Bu   FIFM Neuaufb Saldenfipl
411     F_FUXUBZX LIKE BPIN-FCODE VALUE 'XMZX', "Bu     FIFM Neuaufb Budgetart
412     F_FUXUFZX LIKE BPIN-FCODE VALUE 'YMZX', "Frei   FIFM Neuaufb Freigabe
413
414    *-----Finanzbudget - Verpflichtungen
415     F_FUXUOR LIKE BPIN-FCODE VALUE  'XMOR', "Budget FIFM
416     F_FUXUUB LIKE BPIN-FCODE VALUE  'XMUB', "Umb.   FIFM
417     F_FUXUN0 LIKE BPIN-FCODE VALUE  'XMN0', "Nach.  FIFM
418     F_FUXUR0 LIKE BPIN-FCODE VALUE  'XMR0', "Rück.  FIFM
419     F_FUXUFR LIKE BPIN-FCODE VALUE  'YMFR', "Frei   FIFM
420     F_FUXUBX LIKE BPIN-FCODE VALUE  'XMXX', "Bu+Fre FIFM Neuaufbau Verteilt
421     F_FUXUBY LIKE BPIN-FCODE VALUE  'XMYY', "Budget FIFM    VersCpy
422     F_FUXUFY LIKE BPIN-FCODE VALUE  'YMYY', "Frei   FIFM    VersCpy
423     F_FUXUBY1 LIKE BPIN-FCODE VALUE  'ZMYX1', "Budget FIFM    VersCpy
424     F_FUXUFY1 LIKE BPIN-FCODE VALUE  'ZMYY1', "Frei   FIFM    VersCpy
425     F_FUXUBZ LIKE BPIN-FCODE VALUE  'XMZZ', "Bu     FIFM Hochsummieren
426     F_FUXUFZ LIKE BPIN-FCODE VALUE  'YMZZ', "Frei   FIFM Hochsummieren
427     F_FUXUBZY LIKE BPIN-FCODE VALUE 'XMZY', "Bu     FIFM Neuaufbau Budget
428     F_FUXUFZY LIKE BPIN-FCODE VALUE 'YMZY', "Frei   FIFM Neuaufbau Freigabe
429     F_FUXUBZR LIKE BPIN-FCODE VALUE 'XMZR', "Bu     FIFM Neuaufbau RIB
430    *-----Investprogramme
431     F_BUIPOR LIKE BPIN-FCODE VALUE  'BIOR', "Budget IProg   Orig.
432     F_BUIPN0 LIKE BPIN-FCODE VALUE  'BIN0', "Budget IProg   Nachtr.
433     F_BUIPR0 LIKE BPIN-FCODE VALUE  'BIR0', "Budget IProg   Rueckg.
434     F_PLIPOR LIKE BPIN-FCODE VALUE  'PIOR', "Plan   IProg
435
436    * Aufbau 'ABCDE':
437    * A: Basiswerttyp, B: Applikation, C: Vorerfassung
438    * D: Vorgang, E: Technik
439      F_FUEBEOE LIKE BPIN-FCODE VALUE 'BMEOE', "FM Orig.bud. erfassen
440      F_FUEBEOV LIKE BPIN-FCODE VALUE 'BMEOV', "FM Orig.bud. verteilen
441      F_FUEBERE LIKE BPIN-FCODE VALUE 'BMERE', "FM Rückgabe  erfassen
442      F_FUEBERV LIKE BPIN-FCODE VALUE 'BMERV', "FM Rückgabe  verteilen
443      F_FUEBENE LIKE BPIN-FCODE VALUE 'BMENE', "FM Nachtrag  erfassen
444      F_FUEBENV LIKE BPIN-FCODE VALUE 'BMENV', "FM Nachtrag  verteilen
445    *-----KI3K033566
446      F_FUEBEFE LIKE BPIN-FCODE VALUE 'FMEFE', "FM Freigabe  erfassen
447      F_FUEBEFV LIKE BPIN-FCODE VALUE 'FMEFV', "FM Freigabe  verteilen
448    *-----KI3K033566
449      F_FUEBEUU LIKE BPIN-FCODE VALUE 'BMEUU', "FM Umbuchung
450      F_FUEBEBA LIKE BPIN-FCODE VALUE 'BMEBA', "FM Beleg anzeigen
451      F_FUEBEBC LIKE BPIN-FCODE VALUE 'BMEBC', "FM Beleg ändern
452      F_FUEBEBS LIKE BPIN-FCODE VALUE 'BMEBS', "FM Beleg reverse
453      F_FUEBPBA LIKE BPIN-FCODE VALUE 'BMPBA', "FM Beleg anzeigen      Vor.
454      F_FUEBPBC LIKE BPIN-FCODE VALUE 'BMPBC', "FM Beleg ändern        Vor.
455      F_FUEBPBS LIKE BPIN-FCODE VALUE 'BMPBS', "FM Beleg reverse       Vor.
456      F_FUEBPOE LIKE BPIN-FCODE VALUE 'BMPOE', "FM Orig.bud. erfassen  Vor.
457      F_FUEBPOV LIKE BPIN-FCODE VALUE 'BMPOV', "FM Orig.bud. verteilen Vor.
458      F_FUEBPRE LIKE BPIN-FCODE VALUE 'BMPRE', "FM Rückgabe  erfassen  Vor.
459      F_FUEBPRV LIKE BPIN-FCODE VALUE 'BMPRV', "FM Rückgabe  verteilen Vor.
460      F_FUEBPNE LIKE BPIN-FCODE VALUE 'BMPNE', "FM Nachtrag  erfassen  Vor.
461      F_FUEBPNV LIKE BPIN-FCODE VALUE 'BMPNV', "FM Nachtrag  verteilen Vor.
462      F_FUEBPFE LIKE BPIN-FCODE VALUE 'FMPFE', "FM Freigabe  erfassen  Vor.
463      F_FUEBPFV LIKE BPIN-FCODE VALUE 'FMPFV', "FM Freigabe  verteilen Vor.
464      F_FUEBPUU LIKE BPIN-FCODE VALUE 'BMPUU', "FM Umbuchung           Vor.
465
466      F_FUEBPBR LIKE BPIN-FCODE VALUE 'BMPBR', "FM Vor-Beleg zuruecknehmen
467      F_FUEBPBP LIKE BPIN-FCODE VALUE 'BMPBP', "FM Vor-Beleg buchen
468      F_FUEBPBT LIKE BPIN-FCODE VALUE 'BMPBT', "FM Vor-Beleg genehmigen
469      F_FUEBPBF LIKE BPIN-FCODE VALUE 'BMPBF', "FM Vor-Bel genehm abgeschlos
470      F_FUEBPBV LIKE BPIN-FCODE VALUE 'BMPBV', "FM Vor-Bel erf/vert mit Vorl
471
472      F_FUEBE1E LIKE BPIN-FCODE VALUE 'BME1E', "FM Abgang   ZB erfassen kom.
473      F_FUEBE2E LIKE BPIN-FCODE VALUE 'BME2E', "FM Rückgabe ZB erfassen kom.
474      F_FUEBE3E LIKE BPIN-FCODE VALUE 'BME3E', "FM Rückgabe VE erfassen kom.
475      F_FUEBE4E LIKE BPIN-FCODE VALUE 'BME4E', "FM Minderein. ZB erfas. kom.
476      F_FUEBEXE LIKE BPIN-FCODE VALUE 'BMEXE', "FM Erfassung (Dummy)    kom.
477
478      F_FUEBE5E LIKE BPIN-FCODE VALUE 'BME5E', "FM GJW-Rest ZB erfassen kom.
479      F_FUEBE6E LIKE BPIN-FCODE VALUE 'BME6E', "FM GJW-Rest VE erfassen kom.
480      F_FUEBE0E LIKE BPIN-FCODE VALUE 'BME0E', "FM GJW-Rest (Dummy)     kom.
481      F_FUEBE5T LIKE BPIN-FCODE VALUE 'BME5T', "FM GJW-R ZB gen."KI4K034435
482      F_FUEXE5T LIKE BPIN-FCODE VALUE 'XME5T', "FM GJW-R VE gen."KI4K034435
483
484      F_FUEBE1U LIKE BPIN-FCODE VALUE 'BME1U', "FM echte DF ZB umbuchen kom.
485      F_FUEBE2U LIKE BPIN-FCODE VALUE 'BME2U', "FM APL/UEPL ZB umbuchen kom.
486      F_FUEBE3U LIKE BPIN-FCODE VALUE 'BME3U', "FM APL/UEPL VE umbuchen kom.
487      F_FUEBE4U LIKE BPIN-FCODE VALUE 'BME4U', "FM unechte DF ZB umbu.  kom.
488      F_FUEBE5U LIKE BPIN-FCODE VALUE 'BME5U', "FM Budgetarterh. umbu "RB
489      F_FUEBEXU LIKE BPIN-FCODE VALUE 'BMEXU', "FM Umbuchung   (Dummy)  kom.
490
491      F_FUEBEXV LIKE BPIN-FCODE VALUE 'BMEXV', "FM Verteilen            kom.
492
493      F_FUEBEYE LIKE BPIN-FCODE VALUE 'FMEYE', "FM Freigabegr. erfassen kom.
494      F_FUEBEYV LIKE BPIN-FCODE VALUE 'FMEYV', "FM Freigabegr.  verteil kom.
495      F_FUEBEZE LIKE BPIN-FCODE VALUE 'FMEZE', "FM l. Sperre   erfassen kom.
496
497    *----------------------------------------------------------------------*
498     F_IMPORT1 LIKE BPIN-FCODE VALUE 'ZZ001',  "KBPP_IMPORT_DATA
499
500
501    *-------Nummernkreise Einzelposten-------------------------------------*
502     L_RANGE_PP     LIKE INRI-NRRANGENR VALUE '01',  "Projekt Planung
503     L_RANGE_PB     LIKE INRI-NRRANGENR VALUE '02',  "Projekt Budget
504     L_RANGE_OP     LIKE INRI-NRRANGENR VALUE '03',  "Auftrag Planung
505     L_RANGE_OB     LIKE INRI-NRRANGENR VALUE '04',  "Auftrag Budget
506     L_RANGE_MB     LIKE INRI-NRRANGENR VALUE '05',  "Finanzbudget
507    *-------Nummernkreise Einzelposten allgemein
508     L_RANGE_B      LIKE INRI-NRRANGENR VALUE '10',  "Budget allg.
509     L_RANGE_P      LIKE INRI-NRRANGENR VALUE '11',  "Plan   allg.
510
511    *-------Belegstatus
512     L_BSTAT_POST    LIKE BPDK-BSTAT VALUE '0',        "Gebucht
513     L_BSTAT_NOT_APP LIKE BPDK-BSTAT VALUE '1',        "Vorerfasst
514     L_BSTAT_APP     LIKE BPDK-BSTAT VALUE '2',        "Vor. genehmigt
515     L_BSTAT_V_POST  LIKE BPDK-BSTAT VALUE '3',        "Vor. gebucht
516     L_BSTAT_V_REVER LIKE BPDK-BSTAT VALUE '4',        "Vor. storniert
517    *-------nicht mehr verwenden
518     L_BSTAT_ERROR   LIKE BPDK-BSTAT VALUE 'E',        "Fehlerhaft
519     L_BSTAT_REF     LIKE BPDK-BSTAT VALUE 'R',        "Abgelehnt
520    *-------Reversalstatus
521     L_RSTAT_NORM    LIKE BPDK-RSTAT VALUE ' ',        "Normal doc
522     L_RSTAT_REVL    LIKE BPDK-RSTAT VALUE '1',        "Reversal
523     L_RSTAT_REVD    LIKE BPDK-RSTAT VALUE '2',        "Reversed
524     L_RSTAT_REVING  LIKE BPDK-RSTAT VALUE '3',        "Being Reversed
525    *-------Divers---------------------------------------------------------*
526
527    *    -- IN/OUT
528     BP_INP LIKE BPIN-BELTP VALUE '1',    "Input  - Kosten
529     BP_OUT LIKE BPIN-BELTP VALUE '2',    "Output - Erloese
530    *    -- Kursumrechnung
531     S_KURST       VALUE 'M',       "Standardkurs
532    *    -- Strukturzeile
533     O_STRUC(2)    VALUE '!!',      "Strukturzeile
534    *    -- Max. Saetze fuer Array-Fetch
535     MAX_FILE     TYPE I VALUE 50, "ARRAY-FETCH
536    *    -- Feldlaengen Wertfelder -
537     LEN_WT  LIKE SY-FLENG   VALUE '8',             "Waehrungswerte
538    *    -- Anzahl Perioden / Periodenbloecke
539     ANZ_RASTER TYPE I            VALUE 16,  "16Perioden/Block
540     ANZ_PERIOD   LIKE T009-ANZBP,  "Gesamtzahl Perio
541     ANZ_PERBL    LIKE BPPE-PERBL,  "Anzahl Bloecke
542    *    -- Initialisierung
543     INI_VERSN     LIKE BPIN-VERSN VALUE  '000',
544    *    -- CO-Ledger
545    *INI_CO_LEDGER TYPE COSS-LEDNR VALUE  '00',
546    *INI_CO_VERSN  TYPE COSS-VERSN VALUE  '000',
547     INI_CO_LEDGER TYPE LEDNR VALUE  '00',
548     INI_CO_VERSN  TYPE VERSN VALUE  '000',
549    *    -- Einzelkalkulation - Versionsnummer (fuer Versionen-Kopieren)
550     INI_UNITCOSTING_VERSN LIKE RK70F-TVERS VALUE 01,
551    *    -- Applikation Projekte: Teilprojektverarbeitung
552     SUBPR_ONE     LIKE BPIN-SUBPR VALUE '1',
553     SUBPR_ALL     LIKE BPIN-SUBPR VALUE 'X',
554    *    -- Applikation Treasury
555     FIFM_CBM VALUE 'C', "Finanzmittelrechnung
556     FIFM_CA  VALUE 'A', "Finanzbudgetueberwachung
557    *    -- divers
558     CON_GEN VALUE '*',  "generisch
559
560    *    -- Werte fuer Exportparameter EX_OVERWRITE_DIALOG des
561    *    -- FB KBPS_CHECK_VERSION
562     OVR_DIALOG_NO_DIALOG VALUE '0', "kein Popup angezeigt
563     OVR_DIALOG_ANSW_NO   VALUE '1', "Popup angezeigt, Antwort
564                                           "nicht ueberschr" oder "abbrech"
565     OVR_DIALOG_ANSW_YES  VALUE '2', "Popup angezeigt, Antwort
566                                           "ueberschreiben"
567
568    *    -- Werte fuer Importparameter IM_COPY_MODE des
569    *    -- FB KBPP_COPY_VERSION
570     VERSION_CMODE_DEST_KEEP   VALUE '0', "Zieldaten nicht aendern
571     VERSION_CMODE_DEST_OVERWR VALUE '1', "Zieldaten zuruecksetzen
572                                                 "und ueberschreiben
573     VERSION_CMODE_DEST_ADD    VALUE '2', "Sourcedaten zu Zieldaten
574                                           "addieren
575     VERSION_CMODE_DEST_SUB    VALUE '3'. "subtract source from dest
576                                          "(hidden option)
577
578    *-----Budgetierungsschluessel: Budgetierungstechniken (BP_TECH)
579     DATA: L_TECH_CREATE   VALUE '1',
580           L_TECH_DISTRIB  VALUE '2',
581           L_TECH_TRANSFER VALUE '3'.
582
583    *-----Budgeterfassungsbeleg: Zeilenart
584     DATA: L_ZEILART_SENDER VALUE '1',
585           L_ZEILART_EMPFGR VALUE '2'.
586
587    *-----Werttyp fuer Enqueue in Budgettraegerpflege           "KI3K067412
588     DATA: L_BUDCARR_ENQ_WT LIKE BPIN-WRTTP VALUE 'CA'.         "KI3K067412
589
590    *-----Werttyp fuer Budgettraeger-Gruppen-Verwaltungssatz          "CGRP
591     DATA: L_GRPCARR_WT    LIKE BPIN-WRTTP VALUE 'GR'.               "CGRP
592
593    *----Anzahl der Genehmigungsjahre bei den Kommunen          "KI3K077402
594     DATA: L_ANZ_GNJHR     TYPE I VALUE 4.                      "KI3K077402
595
596
597
598    * budget version activate mode in table FM01                "KI4K012398
599    DATA: G_CON_VERSIONBLOCK    LIKE FM01-VERSACT VALUE '0',    "KI4K012398
600          G_CON_VERSIONACTIVATE LIKE FM01-VERSACT VALUE '1'.    "KI4K012398
601
602
603    * activity types for budgeting                              "KI4K012398
604    DATA: G_CON_ACT_ORG LIKE FM01-VERSACT VALUE '1', "budget    "KI4K012398
605          G_CON_ACT_REL LIKE FM01-VERSACT VALUE '2', "release   "KI4K012398
606          G_CON_ACT_UPD LIKE FM01-VERSACT VALUE '3',"upd. budget"KI4K012398
607          G_CON_ACT_YCH LIKE FM01-VERSACT VALUE '4',"year change"KI4K012398
608          G_CON_ACT_SUP LIKE FM01-VERSACT VALUE '5',"suplement
609          G_CON_ACT_YST LIKE FM01-VERSACT VALUE '6'."year start activities
610
611
612    * constant values for budget texts (used in KBPP, KBPS)
613    CONSTANTS:
614    * Anwendungsobjekt in der Textverarbeitung: Konstant
615      G_CON_BPTX_TXOB  LIKE THEAD-TDOBJECT VALUE 'BPDK',
616    * Text-Id Variabel: Ersetze & durch Applikationskennzeichen
617    * G_CON_BPTX_TXID  LIKE THEAD-TDID     VALUE 'BP&S'.
618    * zur Zeit nur Applikation M
619      G_CON_BPTX_TXID  LIKE THEAD-TDID     VALUE 'BPMS'.
620
621    * constant values for budgety ledger                        "KI4K065178
622    CONSTANTS:                                                  "KI4K065178
623    * ----- constant line types for Budgetary Ledger interface
624      CON_LINE_TYP_NEW_BUDGET   LIKE IFMBLIN-LINE_TYPE VALUE 'N',
625      CON_LINE_TYP_LEAF_BUDGET  LIKE IFMBLIN-LINE_TYPE VALUE 'L',
626      CON_LINE_TYP_BOTH_BUDGET  LIKE IFMBLIN-LINE_TYPE VALUE 'B',
627      CON_LINE_TYP_AVAIL_CHECK  LIKE IFMBLIN-LINE_TYPE VALUE 'A',
628      CON_LINE_TYP_STATISTICAL  LIKE IFMBLIN-LINE_TYPE VALUE 'S',
629      CON_LINE_TYP_DISTRIBUTION LIKE IFMBLIN-LINE_TYPE VALUE 'D',
630      CON_LINE_TYP_RESOURCE     LIKE IFMBLIN-LINE_TYPE VALUE 'R',
631      CON_LINE_TYP_OPEN_ITEMS   LIKE IFMBLIN-LINE_TYPE VALUE 'O',
632
633    * ----- Constants for budget document object types          "KI4K065178
634      CON_OBJ_TYP_BUD_HIER       LIKE ACCIT-AWTYP VALUE 'FMBHI',
635      CON_OBJ_TYP_BUD_ENTRY      LIKE ACCIT-AWTYP VALUE 'FMBTR'.
*--- End of LKBPPEQU - 635 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CIM                                     Level 1    Page 3
Object           ZAIMBNEW                                  Lines 497
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:29
----------------------------------------------------------------------------------------------------
1      TYPE-POOL IM.
2
3      TYPE-POOLS: IMIS.
4
5      * Typ "Programmpositionen für Selektion".
6      TYPES: BEGIN OF IM_INVPGSEL_TYPE,
7               POSNR LIKE IMZO-POSNR,
8             END   OF IM_INVPGSEL_TYPE.
9
10     * Typ "Tabelle Programmpositionen für Selektion".
11     TYPES: IM_INVPGSEL_TAB_TYPE TYPE STANDARD TABLE OF IM_INVPGSEL_TYPE
12                                 WITH DEFAULT KEY.
13
14     * Typ "CO-Objekt".
15     TYPES: BEGIN OF IM_COOBJ_TYPE,
16              OBJNR             LIKE IMZO-OBJNR,
17            END   OF IM_COOBJ_TYPE.
18
19     * Typ "Tabelle CO-Objekte".
20     TYPES: IM_COOBJ_TAB_TYPE   TYPE IM_COOBJ_TYPE    OCCURS 100.
21
22     * Typ "CO-Objekt mit Werten".
23     TYPES: BEGIN OF IM_COVOB_TYPE,
24              OBJNR             LIKE IMZO-OBJNR,
25              BPGE              LIKE BPGE             OCCURS 10,
26              BPJA              LIKE BPJA             OCCURS 10,
27              BPCOSU            LIKE BPCOSU           OCCURS 10,
28              RAIMACT           LIKE RAIMACT          OCCURS 10,
29              RAIPWI            LIKE RAIPWI           OCCURS 10,
30            END   OF IM_COVOB_TYPE.
31
32     * Typ "Tabelle CO-Objekte mit Werten".
33     TYPES: IM_COVOB_TAB_TYPE   TYPE IM_COVOB_TYPE    OCCURS 100.
34
35     * Typ "CO-Hierarchieobjekt".
36     TYPES: BEGIN OF IM_COHYOBJ_TYPE,
37              OBJNR             LIKE IMZO-OBJNR,
38              OBJNR_UP          LIKE IMZO-OBJNR,
39              STUFE             TYPE I,
40            END   OF IM_COHYOBJ_TYPE.
41
42     * Typ "Tabelle CO-Hierarchieobjekte".
43     TYPES: IM_COHYOBJ_TAB_TYPE TYPE IM_COHYOBJ_TYPE  OCCURS 100.
44
45     * Typ "CO-Hierarchieobjekt mit Werten".
46     TYPES: BEGIN OF IM_COHYVOB_TYPE,
47              OBJNR             LIKE IMZO-OBJNR,
48              OBJNR_UP          LIKE IMZO-OBJNR,
49              STUFE             TYPE I,
50              BPGE              LIKE BPGE             OCCURS 10,
51              BPJA              LIKE BPJA             OCCURS 10,
52              BPCOSU            LIKE BPCOSU           OCCURS 10,
53              RAIMACT           LIKE RAIMACT          OCCURS 10,
54            END   OF IM_COHYVOB_TYPE.
55
56     * Typ "Tabelle CO-Hierarchieobjekte mit Werten".
57     TYPES: IM_COHYVOB_TAB_TYPE TYPE IM_COHYVOB_TYPE  OCCURS 100.
58
59     * Typ "CO-Objekt mit untergeordneten Objekten"
60     TYPES: BEGIN OF IM_SUBOBJ_TYPE,
61              OBJNR             LIKE IMZO-OBJNR,
62              SUB               TYPE IM_COOBJ_TYPE OCCURS 10,
63            END OF   IM_SUBOBJ_TYPE.
64
65     * Typ "Tabelle CO-Objekte mit untergeordneten Objekten"
66     TYPES: IM_SUBOBJ_TAB_TYPE TYPE IM_SUBOBJ_TYPE OCCURS 100.
67
68     TYPES: BEGIN OF IM_TKA01_TYPE,                             "pta_sol
69              KOKRS  LIKE TKA01-KOKRS,                          "pta_sol
70              WAERS  LIKE TKA01-WAERS,                          "pta_sol
71              LMONA  LIKE TKA01-LMONA,                          "pta_sol
72            END   OF IM_TKA01_TYPE.                             "pta_sol
73     TYPES: BEGIN OF IM_PRPS_TYPE,                              "pta_sol
74              PSPNR  LIKE PRPS-PSPNR,                           "pta_sol
75              PSPHI  LIKE PRPS-PSPHI,                           "pta_sol
76              POSID  LIKE PRPS-POSID,                           "pta_sol
77              POST1  LIKE PRPS-POST1,                           "pta_sol
78              PKOKR  LIKE PRPS-PKOKR,                           "pta_sol
79              PRCTR  LIKE PRPS-PRCTR,                           "pta_sol
80              VERNR  LIKE PRPS-VERNR,                           "pta_sol
81              PRART  LIKE PRPS-PRART,                           "pta_sol
82              FKOKR  LIKE PRPS-FKOKR,                           "pta_sol
83              FKSTL  LIKE PRPS-FKSTL,                           "pta_sol
84              WERKS  LIKE PRPS-WERKS,                           "daniel
85              IZWEK  LIKE PRPS-IZWEK,                           "daniel
86              IUMKZ  LIKE PRPS-IUMKZ,                           "daniel
87              PSPRI  LIKE PRPS-PSPRI,                           "daniel
88              ISIZE  LIKE PRPS-ISIZE,                           "daniel
89              USR00  LIKE PRPS-USR00,                           "daniel
90              USR01  LIKE PRPS-USR01,                           "daniel
91              USR02  LIKE PRPS-USR02,                           "daniel
92              USR03  LIKE PRPS-USR03,                           "daniel
93              USR04  LIKE PRPS-USR04,                           "daniel
94              USR05  LIKE PRPS-USR05,                           "daniel
95              USR06  LIKE PRPS-USR06,                           "daniel
96              USR07  LIKE PRPS-USR07,                           "daniel
97              USR08  LIKE PRPS-USR08,                           "daniel
98              USR09  LIKE PRPS-USR09,                           "daniel
99              USR10  LIKE PRPS-USR10,                           "daniel
100             USR11  LIKE PRPS-USR11,                           "daniel
101             USE04  LIKE PRPS-USE04,                           "daniel
102             USE05  LIKE PRPS-USE05,                           "daniel
103             USE06  LIKE PRPS-USE06,                           "daniel
104             USE07  LIKE PRPS-USE07,                           "daniel
105             ASTNR  LIKE PRPS-ASTNR,                           "n.424633
106             PBUKR  LIKE PRPS-PBUKR,                           "n.424633
107             PGSBR  LIKE PRPS-PGSBR,                           "n.424633
108             AKOKR  LIKE PRPS-AKOKR,                           "n.424633
109             AKSTL  LIKE PRPS-AKSTL,                           "n.424633
110             KOSTL  LIKE PRPS-KOSTL,                           "n.424633
111           END   OF IM_PRPS_TYPE.                              "pta_sol
112    TYPES: BEGIN OF IM_AUFKV_TYPE,                             "pta_sol
113             AUFNR  LIKE AUFKV-AUFNR,                          "pta_sol
114             KTEXT  LIKE AUFKV-KTEXT,                          "pta_sol
115             KOKRS  LIKE AUFKV-KOKRS,                          "pta_sol
116             AUART  LIKE AUFKV-AUART,                          "pta_sol
117             WERKS  LIKE AUFKV-WERKS,                          "daniel
118             IZWEK  LIKE AUFKV-IZWEK,                          "daniel
119             UMWKZ  LIKE AUFKV-UMWKZ,                          "daniel
120             SIZECL LIKE AUFKV-SIZECL,                         "daniel
121             USER0  LIKE AUFKV-USER0,                          "daniel
122             USER1  LIKE AUFKV-USER1,                          "daniel
123             USER2  LIKE AUFKV-USER2,                          "daniel
124             USER3  LIKE AUFKV-USER3,                          "daniel
125             USER4  LIKE AUFKV-USER4,                          "daniel
126             USER5  LIKE AUFKV-USER5,                          "daniel
127             USER6  LIKE AUFKV-USER6,                          "daniel
128             USER7  LIKE AUFKV-USER7,                          "daniel
129             USER8  LIKE AUFKV-USER8,                          "daniel
130             USER9  LIKE AUFKV-USER9,                          "daniel
131           END   OF IM_AUFKV_TYPE.                             "pta_sol
132    TYPES: BEGIN OF IM_IMAK_TYPE,                              "pta_sol
133             POSNR  LIKE IMAK-POSNR,                           "pta_sol
134             OBJNR  LIKE IMAK-OBJNR,                           "pta_sol
135             IVART  LIKE IMAK-IVART,                           "pta_sol
136             ABUKRS LIKE IMAK-ABUKRS,                          "pta_sol
137             VKOKRS LIKE IMAK-VKOKRS,                          "pta_sol
138             VKOSTL LIKE IMAK-VKOSTL,                          "pta_sol
139             VPRCTR LIKE IMAK-VPRCTR,                          "pta_sol
140             WERKS  LIKE IMAK-WERKS,                           "daniel
141             SIZECL LIKE IMAK-SIZECL,                          "daniel
142             PRIORI LIKE IMAK-PRIORI,                          "daniel
143             UMWKZ  LIKE IMAKPU-UMWKZ,                         "daniel
144             IZWEK  LIKE IMAKPI-IZWEK,                         "daniel
145             USR00  LIKE IMAK-USR00,                           "daniel
146             USR01  LIKE IMAK-USR01,                           "daniel
147             USR02  LIKE IMAK-USR02,                           "daniel
148             USR03  LIKE IMAK-USR03,                           "daniel
149             USR04  LIKE IMAK-USR04,                           "daniel
150             USR05  LIKE IMAK-USR05,                           "daniel
151             USR06  LIKE IMAK-USR06,                           "daniel
152             USR07  LIKE IMAK-USR07,                           "daniel
153             USR08  LIKE IMAK-USR08,                           "daniel
154             USR09  LIKE IMAK-USR09,                           "daniel
155             USR10  LIKE IMAK-USR10,                           "daniel
156             USR11  LIKE IMAK-USR11,                           "daniel
157             USR12  LIKE IMAK-USR12,                           "daniel
158             USR13  LIKE IMAK-USR13,                           "daniel
159             USE04  LIKE IMAK-USE04,                           "daniel
160             USE05  LIKE IMAK-USE05,                           "daniel
161             USE06  LIKE IMAK-USE06,                           "daniel
162             USE07  LIKE IMAK-USE07,                           "daniel
163           END   OF IM_IMAK_TYPE.                              "pta_sol
164    TYPES: BEGIN OF IM_IMAKT_TYPE,                             "pta_sol
165             TXT50  LIKE IMAKT-TXT50,                          "pta_sol
166           END   OF IM_IMAKT_TYPE.                             "pta_sol
167    TYPES: BEGIN OF IM_IMAV_TYPE,                              "pta_sol
168             POSNR  LIKE IMAV-POSNR,                           "pta_sol
169             VARNT  LIKE IMAV-VARNT,                           "pta_sol
170           END   OF IM_IMAV_TYPE.                              "pta_sol
171    TYPES: BEGIN OF IM_IMAVZ_TYPE,                             "pta_sol
172             GJAHR  LIKE IMAVZ-GJAHR,                          "pta_sol
173           END   OF IM_IMAVZ_TYPE.                             "pta_sol
174    *TYPES: BEGIN OF im_ania_plus_type.                         "vw
175    *        INCLUDE STRUCTURE ania.                           "vw
176    *TYPES:   zujhr   LIKE anlav-zujhr,                         "vw
177    *      END   OF im_ania_plus_type.                         "vw
178
179    TYPES: BEGIN OF IM_ANIA_PLUS_TYPE.                         "vw
180            INCLUDE STRUCTURE RAIPS_CTRL.                       "vw
181    TYPES: END OF IM_ANIA_PLUS_TYPE.                           "vw
182
183
184
185
186    * Typ "Endabgerechnete Ist-Werte"
187    TYPES: BEGIN OF IM_SETLVAL_TYPE,
188             GJAHR             LIKE ANLC-GJAHR,
189             WERT              LIKE ANLC-KANSW,
190           END   OF IM_SETLVAL_TYPE.
191
192    * Typ "AfA-Simulationsobjekt".
193    TYPES: BEGIN OF IM_AFAOBJ_TYPE,
194    *        TKA01             LIKE TKA01,                     "pta_sol
195             TKA01             TYPE IM_TKA01_TYPE,             "pta_sol
196             LEDNR             LIKE BPGE-LEDNR,
197             OBJNR             LIKE IMZO-OBJNR,
198             OBART             LIKE IMPS-OBART,
199             ASS_PRNAM         LIKE IMPR-PRNAM,                "vw7
200             ASS_GJAHR         LIKE IMPR-GJAHR,                "vw7
201             ASS_POSNR         LIKE IMPR-POSNR,                "vw7
202             IMTP              LIKE IMTP,
203             IMPR              LIKE IMPR,
204             IMPU              LIKE IMPU,
205    *        PROJ              LIKE PROJ,                      "pta_sol
206    *        PRPS              LIKE PRPS,                      "pta_sol
207             PRPS              TYPE IM_PRPS_TYPE,              "pta_sol
208    *        AUFKV             LIKE AUFKV,                     "pta_sol
209             AUFKV             TYPE IM_AUFKV_TYPE,             "pta_sol
210    *        IMAK              LIKE IMAK,                      "pta_sol
211             IMAK              TYPE IM_IMAK_TYPE,              "pta_sol
212    *        IMAKT             LIKE IMAKT,                     "pta_sol
213             IMAKT             TYPE IM_IMAKT_TYPE,             "pta_sol
214    *        IMAV              LIKE IMAV,                      "pta_sol
215             IMAV              TYPE IM_IMAV_TYPE,              "pta_sol
216    *        IMAVZ             LIKE IMAVZ,                     "pta_sol
217             IMAVZ             TYPE IM_IMAVZ_TYPE,             "pta_sol
218             IMAKPI            LIKE IMAKPI           OCCURS 10,"daniel
219             IMAKPU            LIKE IMAKPU           OCCURS 10,"daniel
220             IMAKPGES          LIKE RIMAKPGES        OCCURS 10,
221    *        Stufe innerhalb InvProgramm und/oder PSP.
222             STUFE             TYPE I,
223    *        Kz. "AfA-Simulationsdaten zu AfA-Objekt vorhanden".
224             FLG_ANIA(1)       TYPE C,
225    *        AfA-Simulations-Parameter.
226    *        ANIA              LIKE ANIA             OCCURS 10,     "vw
227             ANIA_PLUS         TYPE IM_ANIA_PLUS_TYPE               "vw
228                                                     OCCURS 10,     "vw
229             ANIB              LIKE ANIB             OCCURS 10,
230    *        Zuordnungen zu Programmposition(en).
231    *        IMZO              LIKE IMZO             OCCURS 10,
232    *        Werte.
233             BPJA              LIKE BPJA             OCCURS 10,
234    *        Endabgerechnete Werte.
235             BPJA_SETL         LIKE BPJA             OCCURS 10,
236    *        Kz. "Gesamtwerte sind Basis der AfA-Simulation".
237             FLG_BASIS_GES(1)  TYPE C,
238    *        Summe der ANIA-Beträge.                        "vw
239             SUM_BETRG         LIKE ANIA-BETRG,             "vw
240    *        Summe der ANIA-Äquivalenzziffern.              "vw
241             SUM_AQZIF         LIKE ANIA-AQZIF,             "vw
242           END   OF IM_AFAOBJ_TYPE.
243
244    * Typ "Tabelle AfA-Simulationsobjekte".
245    TYPES: IM_AFAOBJ_TAB_TYPE  TYPE IM_AFAOBJ_TYPE   OCCURS 100.
246
247    * Typ "AfA-Reduktionsobjekt".
248    TYPES: BEGIN OF IM_REDOBJ_TYPE,
249             OBJNR     LIKE IMZO-OBJNR,
250             STUFE     TYPE I,
251             INDEX_POS LIKE SY-TABIX,
252    *        BPJA      LIKE BPJA OCCURS 10,                    "reduce0
253             ania_plus LIKE raips_ctrl OCCURS 10,              "reduce0
254             SUM_BETRG LIKE ANIA-BETRG,                        "reduce0
255           END   OF IM_REDOBJ_TYPE.
256    * Typ "Tabelle AfA-Reduktionsobjekt".
257    TYPES: IM_REDOBJ_TAB_TYPE  TYPE IM_REDOBJ_TYPE   OCCURS 100.
258
259    * Typ "Maßnahmenanforderungsvariante für AfA-Simulation"
260    TYPES: BEGIN OF IM_REQVAR_TYPE,
261             POSNR             LIKE IMAK-POSNR,
262             OBJNR_REQ         LIKE IMAK-OBJNR,
263             VARNT             LIKE IMAVZ-VARNT,
264             OBJNR_VAR         LIKE IMAV-OBJNR,
265             GNJHR             LIKE IMAVZ-GJAHR,
266             VERSI             LIKE IMAVZ-VERSI,
267           END   OF IM_REQVAR_TYPE.
268
269    * Typ "Tabelle Maßnahmenanforderungsvarianten für AfA-Simulation"
270    TYPES: IM_REQVAR_TAB_TYPE  TYPE IM_REQVAR_TYPE   OCCURS 100.
271
272    * Typ "PSP-Element für Blockverarbeitung AfA-Simulation"
273    TYPES: BEGIN OF IM_PSPBLK_TYPE,
274              PSPID      LIKE PROJ-PSPID,
275              POSID      LIKE PRPS-POSID,
276              OBJNR      LIKE PRPS-OBJNR,
277           END   OF IM_PSPBLK_TYPE.
278
279    * Typ "Tabelle Maßnahmenanforderungsvarianten für AfA-Simulation"
280    TYPES: IM_PSPBLK_TAB_TYPE  TYPE IM_PSPBLK_TYPE   OCCURS 100.
281
282    * Typ "Abgerechnete Istwerte für AfA-Simulation".
283    TYPES: BEGIN OF IM_ANIA_SETL_TYPE,
284             OBJNR LIKE ANIA-OBJNR,
285             BUKRS LIKE ANIA-BUKRS,
286             ANLKL LIKE ANIA-ANLKL,
287             LSTAR LIKE ANIA-LSTAR,
288             MSFAK LIKE ANIA-MSFAK,
289             CAUFN LIKE ANIA-CAUFN,
290             KOSTL LIKE ANIA-KOSTL,
291             GSBER LIKE ANIA-GSBER,
292             BETRG LIKE ANIA-BETRG,
293             AKTIV LIKE ANEK-BUDAT,
294             GJAHR LIKE ANLC-GJAHR,
295           END   OF IM_ANIA_SETL_TYPE.
296
297    * Typ "Tabelle Abgerechnete Istwerte für AfA-Simulation".
298    TYPES: IM_ANIA_SETL_TAB_TYPE TYPE STANDARD TABLE OF IM_ANIA_SETL_TYPE.
299
300    * Typ "Batch-Input-Mappe".
301    TYPES: BEGIN OF IM_BDC_TYPE,
302             TCODE             LIKE TSTC-TCODE,
303             MODE(1)           TYPE C,
304             UPDATE(1)         TYPE C,
305             BDCDATA           LIKE BDCDATA          OCCURS 100,
306           END   OF IM_BDC_TYPE.
307
308    * Typ "Tabelle Batch-Input-Mappen".
309    TYPES: IM_BDC_TAB_TYPE     TYPE IM_BDC_TYPE      OCCURS 100.
310
311    * Typ "Maßnahmenpuffer Stammdaten"
312    TYPES: BEGIN OF IM_BUFFER_MEASURES_TYPE,
313             OBJNR             LIKE IMZO-OBJNR,
314             OBART             LIKE IMPS-OBART,
315             IMZO              LIKE IMZO              OCCURS 10,
316             AUFKV             LIKE AUFKV             OCCURS 1,
317             PRPS              LIKE PRPS              OCCURS 1,     "vw7
318             PROJ              LIKE PROJ              OCCURS 1,
319             IMAK              LIKE IMAK              OCCURS 1,
320             IMAKT             LIKE IMAKT             OCCURS 1,
321             IMAKPGES          LIKE RIMAKPGES         OCCURS 10,
322             ROPA              TYPE IMIS_TYPE_SX_ROPA OCCURS 10,
323    *        Charakter der Manf.
324             REQ_CH            TYPE IMA_REQ_CH,
325    *        Beziehung einer Maßnahme zu einer Manf.
326             MEAS_AS           TYPE IM_MEAS_AS,
327           END   OF IM_BUFFER_MEASURES_TYPE.
328
329    * Typ "Tabelle Maßnahmenpuffer Stammdaten"
330    TYPES: IM_BUFFER_MEASURES_TAB_TYPE
331                               TYPE IM_BUFFER_MEASURES_TYPE
332                               OCCURS 100.
333
334    * Typ "Maßnahmenpuffer Werte"
335    TYPES: BEGIN OF IM_BUFFER_VALUES_TYPE,
336             OBJNR             LIKE IMZO-OBJNR,
337             OBART             LIKE IMPS-OBART,
338             BPGE              LIKE BPGE             OCCURS 10,
339             BPJA              LIKE BPJA             OCCURS 10,
340             BPCOSU            LIKE BPCOSU           OCCURS 10,
341             RAIMACT           LIKE RAIMACT          OCCURS 10,
342             RAIPWI            LIKE RAIPWI           OCCURS 10,
343           END   OF IM_BUFFER_VALUES_TYPE.
344
345    * Typ "Tabelle Maßnahmenpuffer Stammdaten"
346    TYPES: IM_BUFFER_VALUES_TAB_TYPE
347                               TYPE IM_BUFFER_VALUES_TYPE
348                               OCCURS 100.
349
350    * Typ "Verbindung zu Programmposition".
351    TYPES: BEGIN OF IM_CONNECT_TYPE,
352             POSNR             LIKE IMZO-POSNR,
353             OBJNR             LIKE IMZO-OBJNR,
354             FLG_REALMEAS(1)   TYPE C,
355           END   OF IM_CONNECT_TYPE.
356
357    * Typ "Tabelle Verbindung zu Programmposition".
358    TYPES: IM_CONNECT_TAB_TYPE TYPE IM_CONNECT_TYPE OCCURS 100.
359
360    * Typ "Objektzuordnungen"
361    TYPES: BEGIN OF IM_OBJASSIGN_TYPE,
362             OBJNR             LIKE IMZO-OBJNR,
363             COOBJ             TYPE IM_COOBJ_TAB_TYPE,
364           END   OF IM_OBJASSIGN_TYPE.
365
366    * Typ "Tabelle Objektzuordnungen"
367    TYPES: IM_OBJASSIGN_TAB_TYPE
368                               TYPE IM_OBJASSIGN_TYPE
369                               OCCURS 100.
370
371    * Typ "Zugeordnete Position".
372    TYPES:   BEGIN OF IM_POSIT_TYPE,
373               IMTP   LIKE IMTP,
374               IMPR   LIKE IMPR,
375               TAI08  LIKE TAI08           OCCURS 10,
376               ZIMZO  LIKE IMZO            OCCURS 10,
377               XIMZO  LIKE IMZO            OCCURS 10,
378             END   OF IM_POSIT_TYPE.
379    * Typ "Tabelle zugeordnete Positionen".
380    TYPES:   IM_POSIT_TAB_TYPE TYPE STANDARD TABLE OF IM_POSIT_TYPE.
381
382    * Typ "Zugeordnete Positionen zu Maßnahme".
383    TYPES:   BEGIN OF IM_ALLOC_TYPE,
384               OBJNR        LIKE IMZO-OBJNR,
385               POSIT        TYPE IM_POSIT_TYPE   OCCURS 10,
386               POSIT_YRCHG  TYPE IM_POSIT_TYPE   OCCURS 10,
387               ZREALMEAS_IQ LIKE RAIP_OBJ        OCCURS 10,
388               XREALMEAS_IQ LIKE RAIP_OBJ        OCCURS 10,
389             END   OF IM_ALLOC_TYPE.
390
391    * Typ Dynprotabellenzeile für Dynpro SAPLAIPP 0200
392    * (Budgetartenprozentsätze).
393    TYPES: BEGIN OF IM_ALLOC_CATG_DYN_TYPE,
394             DYN_MARKED       TYPE C,
395             IPPOS            LIKE IMZO-IPPOS,
396             BAPRZ            LIKE IMZO-BAPRZ,
397           END   OF IM_ALLOC_CATG_DYN_TYPE.
398    * Typ Dynprotabelle für Dynpro SAPLAIPP 0200.
399    TYPES: IM_ALLOC_CATG_DYN_TAB_TYPE
400                              TYPE IM_ALLOC_CATG_DYN_TYPE OCCURS 10.
401
402    * Typ Dynprotabellenzeile für Dynpro SAPLAIPP 0100
403    * (Zuordnung Maßnahme/Anforderung --> Position(en) )
404    TYPES: BEGIN OF IM_ALLOC_DYN_TYPE,
405             DYN_MARKED       TYPE C,
406             PRNAM            LIKE IMTP-PRNAM,
407             POSID            LIKE IMPR-POSID,
408             GJAHR            LIKE IMTP-GJAHR,
409             PROZU            LIKE IMZO-PROZU,
410             D0200_DYNTAB     TYPE IM_ALLOC_CATG_DYN_TYPE OCCURS 10,
411           END   OF IM_ALLOC_DYN_TYPE.
412    * Typ Dynprotabelle für Dynpro SAPLAIPP 0100.
413    TYPES: IM_ALLOC_DYN_TAB_TYPE
414                              TYPE IM_ALLOC_DYN_TYPE OCCURS 10.
415
416    * Typ für Kennzeichen Authority-Check von Werten.
417    TYPES: BEGIN OF IM_AUTHFLG_TYPE,
418             POS_BUDG(1)   TYPE C,
419             POS_PLAN(1)   TYPE C,
420             MEAS_BUDG(1)  TYPE C,
421             MEAS_PLAN(1)  TYPE C,
422             MEAS_ACT(1)   TYPE C,
423             REQ_PLAN(1)   TYPE C,
424             REQ_PROFIT(1) TYPE C,
425           END   OF IM_AUTHFLG_TYPE.
426
427    * Typ für Message bei Authority-Check von Werten.
428    TYPES: BEGIN OF IM_AUTHMSG_TYPE,
429             POS_BUDG      LIKE SY-MSGTY,
430             POS_PLAN      LIKE SY-MSGTY,
431             MEAS_BUDG     LIKE SY-MSGTY,
432             MEAS_PLAN     LIKE SY-MSGTY,
433             MEAS_ACT      LIKE SY-MSGTY,
434             REQ_PLAN      LIKE SY-MSGTY,
435             REQ_PROFIT    LIKE SY-MSGTY,
436           END   OF IM_AUTHMSG_TYPE.
437
438    * Typ für SUBRCs bei Authority-Check von Werten.
439    TYPES: BEGIN OF IM_AUTHRC_TYPE,
440             POS_BUDG      LIKE SY-SUBRC,
441             POS_PLAN      LIKE SY-SUBRC,
442             MEAS_BUDG     LIKE SY-SUBRC,
443             MEAS_PLAN     LIKE SY-SUBRC,
444             MEAS_ACT      LIKE SY-SUBRC,
445             REQ_PLAN      LIKE SY-SUBRC,
446             REQ_PROFIT    LIKE SY-SUBRC,
447           END   OF IM_AUTHRC_TYPE.
448
449    * Temporär, bis Neue TabellenTypen funktionieren.
450    TYPES: BEGIN OF IM_TYPE_STRUC_BP_UPD_IN,
451             OBJNR TYPE IM_OBJNR,
452             TLEVEL TYPE SEU_LEVEL,
453             BPGE LIKE BPGE OCCURS 10,
454             BPJA LIKE BPJA OCCURS 10,
455           END   OF IM_TYPE_STRUC_BP_UPD_IN.
456    TYPES: IM_TYPE_TAB_BP_UPD_IN
457             TYPE IM_TYPE_STRUC_BP_UPD_IN OCCURS 100.
458    TYPES: BEGIN OF IM_TYPE_STRUC_BP_UPD_OUT,
459             OBJNR TYPE IM_OBJNR,
460             BPGE_ID LIKE BPGE_ID OCCURS 10,
461             BPJA_ID LIKE BPJA_ID OCCURS 10,
462           END   OF IM_TYPE_STRUC_BP_UPD_OUT.
463    TYPES: IM_TYPE_TAB_BP_UPD_OUT
464             TYPE IM_TYPE_STRUC_BP_UPD_OUT OCCURS 100.
465
466    * Typen für die Behandlung von Kostenstellenhierarchien im IM.
467    TYPES: BEGIN OF IM_CC_HIER_TYPE,
468            LEVEL       LIKE SETHIERPTR-LEVEL,
469            SHORTNAME   LIKE SETHIERPTR-SHORTNAME,
470            DESCRIPT    LIKE SETHIERPTR-DESCRIPT,
471            CSKS        LIKE CSKS                     OCCURS 10,
472            CSKT        LIKE CSKT                     OCCURS 10,
473           END   OF IM_CC_HIER_TYPE.
474    TYPES: IM_CC_HIER_TAB_TYPE
475                        TYPE STANDARD TABLE OF IM_CC_HIER_TYPE.
476
477    * Typen für die Behandlung von Profitcenterhierarchien im IM.
478    TYPES: BEGIN OF IM_PC_HIER_TYPE,
479            LEVEL       LIKE SETHIERPTR-LEVEL,
480            SHORTNAME   LIKE SETHIERPTR-SHORTNAME,
481            DESCRIPT    LIKE SETHIERPTR-DESCRIPT,
482            CEPC        LIKE CEPC                     OCCURS 10,
483            CEPCT       LIKE CEPCT                    OCCURS 10,
484           END   OF IM_PC_HIER_TYPE.
485    TYPES: IM_PC_HIER_TAB_TYPE
486                        TYPE STANDARD TABLE OF IM_PC_HIER_TYPE.
487
488    * Puffer für Einfachzuordnungskennzeichen
489    TYPES: BEGIN OF IM_SINGLE_ASSIGN_IQ,
490             IVART TYPE IMA_IVART,
491             X1ASS TYPE IM_SINGLE_ASSIGN,
492           END OF IM_SINGLE_ASSIGN_IQ.
493
494    TYPES: BEGIN OF IM_SINGLE_ASSIGN_IP,
495             PRART TYPE IM_PRART,
496             X1ASS TYPE IM_SINGLE_ASSIGN,
497           END OF IM_SINGLE_ASSIGN_IP.
*--- End of %_CIM - 497 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CIMIS                                   Level 1    Page 4
Object           ZAIMBNEW                                  Lines 1380
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:29
----------------------------------------------------------------------------------------------------
1      TYPE-POOL IMIS .
2
3      ************************************************************************
4      * Typen/Konstanten für Informationssysteme InvestManagement (IM-FA):
5      * -  Investitionsprogramme
6      * -  Verdichtung Investitionsprogramme
7      * -  Maßnahmenanforderungen
8      ************************************************************************
9      * Zum Anfang der jeweiligen Abschnitte kann man mit folgenden Kürzeln
10     * suchen:
11     *  >CON       Allgemeine Konstanten
12     *             (Konstanten nur für spezielle Gebiete / Typen sind bei
13     *             diesen abgelegt)!
14     *  >GEN       Allgemeine Typen.
15     *  >PROG      InvestProgramme.
16     *  >RECH      Recherche InvestProgramme/MaßnahmenAnforderungen.
17     *  >MEAS      Maßnahmen allgemein.
18     *  >ORD       Aufträge.
19     *  >PROJ      Projekte/PSP-Elemente.
20     *  >REQ       MaßnahmenAnforderungen.
21     *  >COMPR     Verdichtung.
22     ************************************************************************
23
24
25
26     ************************************************************************
27     * Konstanten
28     * >CON
29     ************************************************************************
30
31     *-----------------------------------------------------------------------
32     * Boole'sche Konstanten.
33     CONSTANTS:
34       IMIS_TRUE(1)  TYPE C VALUE 'X',
35       IMIS_FALSE(1) TYPE C VALUE ' '.
36
37
38     *-----------------------------------------------------------------------
39     * Nachrichtentypen.
40     CONSTANTS:
41       IMIS_CON_ABEND    LIKE  SY-MSGTY  VALUE 'A',
42       IMIS_CON_ERROR    LIKE  SY-MSGTY  VALUE 'E',
43       IMIS_CON_INFO     LIKE  SY-MSGTY  VALUE 'I',
44       IMIS_CON_SUCCESS  LIKE  SY-MSGTY  VALUE 'S',
45       IMIS_CON_WARNING  LIKE  SY-MSGTY  VALUE 'W',
46       IMIS_CON_EXIT     LIKE  SY-MSGTY  VALUE 'X'.
47
48
49     *-----------------------------------------------------------------------
50     * Objektarten.
51     CONSTANTS:
52       BEGIN OF IMIS_CON_S_OBART,
53     *   Programmdefinition
54         IPROG   LIKE IONRA-OBART VALUE 'ID',
55     *   Programmposition.
56         IPPOS   LIKE IONRA-OBART VALUE 'IP',
57     *   Anforderung.
58         REQUEST LIKE IONRA-OBART VALUE 'IQ',
59     *   Variante.
60         VARNT   LIKE IONRA-OBART VALUE 'IO',
61     *   Auftrag.
62         ORDER   LIKE IONRA-OBART VALUE 'OR',
63     *   PSP-Element.
64         WBSELM  LIKE IONRA-OBART VALUE 'PR',
65       END OF   IMIS_CON_S_OBART.
66
67     *-----------------------------------------------------------------------
68     * Wild_Cards fuer Selektion mit LIKE
69       CONSTANTS: IMIS_CON_WC VALUE '%'.
70
71     *   Anforderung.
72       CONSTANTS: BEGIN OF IMIS_CON_REQUEST_WC,
73                   OBART LIKE IONRA-OBART VALUE IMIS_CON_S_OBART-REQUEST,
74                   WILD_CARD              VALUE IMIS_CON_WC,
75                  END OF IMIS_CON_REQUEST_WC.
76
77     *-----------------------------------------------------------------------
78     * Auftragstypen.
79     CONSTANTS:
80       BEGIN OF IMIS_CON_S_ORDER_CATG,
81     *   Kein Auftrag.
82         NO_ORDER  LIKE  AUFK-AUTYP  VALUE '00',
83     *   Instandhaltungsauftrag.
84         PM_ORDER  LIKE  AUFK-AUTYP  VALUE '30',
85       END OF   IMIS_CON_S_ORDER_CATG.
86
87     *-----------------------------------------------------------------------
88     * Aktivitaetstypen fuer Berechtigungspruefung.
89     TYPES: IMIS_TYPE_ACTIVITY(2) TYPE C.
90
91     CONSTANTS:
92       BEGIN OF IMIS_CON_S_ACTIVITY,
93        CREATE             LIKE  AUTHA-IM_ACTVT      VALUE '01',
94        CHANGE             LIKE  AUTHA-IM_ACTVT      VALUE '02',
95        SHOW               LIKE  AUTHA-IM_ACTVT      VALUE '03',
96        LOG                LIKE  AUTHA-IM_ACTVT      VALUE '05',
97        DELETE             LIKE  AUTHA-IM_ACTVT      VALUE '06',
98        CHANGE_PLAN        LIKE  AUTHA-IM_ACTVT      VALUE '33',
99        SHOW_PLAN          LIKE  AUTHA-IM_ACTVT      VALUE '34',
100      END   OF IMIS_CON_S_ACTIVITY.
101
102    *-----------------------------------------------------------------------
103    * Relevante Hierarchieklassen.
104    CONSTANTS:
105      BEGIN OF IMIS_CON_S_HCLASS,
106    *   InvestProgramm.
107        PROG        LIKE  TRSTHC-HCLASS  VALUE 'IVPR',
108    *   InvestProgramm komplett (einschließlich Anforderungen und Maßnahmen)
109        PROG_ALL    LIKE  TRSTHC-HCLASS  VALUE 'IVPA',
110    *   InvestProgramm Verdichtung.
111        COMPR_PROG  LIKE  TRSTHC-HCLASS  VALUE 'ICPR',
112      END   OF IMIS_CON_S_HCLASS.
113
114
115    *-----------------------------------------------------------------------
116    * Fixer Hierarchiename für Recherche.
117    CONSTANTS:
118      IMIS_CON_HIENM_SAP  LIKE  TRSTHV-HIENM  VALUE '0SAP'.
119
120
121    *-----------------------------------------------------------------------
122    * Applikationsklassen Recherche.
123    CONSTANTS:
124      BEGIN OF IMIS_CON_S_APPLCLASS,
125    *   InvestProgramme.
126        AIP  LIKE  TRSTHV-APPL  VALUE 'AIP',
127    *   Verdichtung InvestProgramme.
128        AIC  LIKE  TRSTHV-APPL  VALUE 'AIC',
129    *   MaßnahmenAnforderungen.
130        AIR  LIKE  TRSTHV-APPL  VALUE 'AIR',
131      END   OF IMIS_CON_S_APPLCLASS.
132
133
134    *-----------------------------------------------------------------------
135    * Namen der Strukturen für die Recherche.
136    CONSTANTS:
137      BEGIN OF IMIS_CON_S_TABNM,
138    *   InvestProgramme.
139        AIP  LIKE  RSTHVKEY-TABNM  VALUE 'RIPASP',
140    *   Verdichtung InvestProgramme.
141        AIC  LIKE  RSTHVKEY-TABNM  VALUE 'RICASP',
142    *   MaßnahmenAnforderungen.
143        AIR  LIKE  RSTHVKEY-TABNM  VALUE 'RIRASP',
144      END   OF IMIS_CON_S_TABNM.
145
146    * Namen der Kundenerweiterung für die Recherche.
147    constants:
148     begin of imis_con_s_cust_tabnm,
149    *   Investitionsprogramm aktuelle Daten.
150         AIP  LIKE  RSTHVKEY-TABNM  VALUE 'CI_RIPASP_MDC',
151    *   MaßnahmenAnforderungen.
152         AIR  LIKE  RSTHVKEY-TABNM  VALUE 'CI_RIRASP_MDC',
153    *   Investitionsprogramm Verdichtung.
154         AIC  LIKE  RSTHVKEY-TABNM  VALUE 'CI_RICASP_MDC',
155     end   of imis_con_s_cust_tabnm.
156
157    *-----------------------------------------------------------------------
158    * Namen der DDIC-Strukturen, mit denen in der Verdichtung
159    * der Filetransfer bewerkstelligt wird.
160    * Diese Namen müssen im jeweiligen Verwaltungssatz im File benutzt
161    * werden. (Das sorgt für ein wenig mehr Sicherheit bei der Vielzahl
162    * von Files, so daß nicht versehentlich falsche Daten eingespielt
163    * werden.)
164    CONSTANTS:
165      BEGIN OF IMIS_CON_S_TABNAME,
166        IGNORE_CHARACT  LIKE   RAICFILE-TABNAME  VALUE  'BAPI1057CC',
167        IGNORE_SCALES   LIKE   RAICFILE-TABNAME  VALUE  'BAPI1057CS',
168        DATA            LIKE   RAICFILE-TABNAME  VALUE  'BAPI1057CD',
169        REQUESTS        LIKE   RAICFILE-TABNAME  VALUE  'BAPI1057C6',
170        MEASURES        LIKE   RAICFILE-TABNAME  VALUE  'BAPI1057C1',
171        PROFIT_CTR      LIKE   RAICFILE-TABNAME  VALUE  'BAPI1057C2',
172        COSTCENTER      LIKE   RAICFILE-TABNAME  VALUE  'BAPI1057C3',
173        PLANTS          LIKE   RAICFILE-TABNAME  VALUE  'BAPI1057C4',
174        FUNCTLOCS       LIKE   RAICFILE-TABNAME  VALUE  'BAPI1057C5',
175      END   OF IMIS_CON_S_TABNAME.
176
177
178    *-----------------------------------------------------------------------
179    * Beziehungen Maßnahme zur MAnf. Festwerte der Domaene IM_MEAS_AS
180    CONSTANTS:
181      BEGIN OF IMIS_CON_S_MEAS_ASSIGNMENT,
182    *   Keiner MAnf zugeordnet.
183        NOT_ASSIGNED     TYPE  IM_MEAS_AS  VALUE '1',
184    *   Zur Vorplanung zugeordnet.
185        FOR_PLANNING     TYPE  IM_MEAS_AS  VALUE '2',
186    *   Zur Realsierung zugeordnet.
187        FOR_REALIZATION  TYPE  IM_MEAS_AS  VALUE '3',
188      END   OF IMIS_CON_S_MEAS_ASSIGNMENT.
189
190    *-----------------------------------------------------------------------
191    * Konstanten für Character einer MANF. Festwerte der Domaene IMA_REQ_CH
192    CONSTANTS:
193      BEGIN OF IMIS_CON_S_CHARACTER,
194        WITHOUT_MEAS  TYPE  IMA_REQ_CH  VALUE '1',
195        WITH_MEAS     TYPE  IMA_REQ_CH  VALUE '2',
196        REPLACED      TYPE  IMA_REQ_CH  VALUE '3',
197      END   OF IMIS_CON_S_CHARACTER.
198
199
200    ************************************************************************
201    * Allgemeine Typen (evtl. mit zugehörigen Konstanten).
202    * >GEN
203    ************************************************************************
204
205    *-----------------------------------------------------------------------
206    * Flag: Ausprägungen sollten nur ' ' oder 'X' sein.
207    * Dient eher dokumentatorischen Zwecken bei Parameterübergaben.
208    TYPES: IMIS_TYPE_FLG(1)  TYPE  C.
209
210    *-----------------------------------------------------------------------
211    * CHARACTER-Typen.
212    TYPES: IMIS_TYPE_C24(24) TYPE C,
213           IMIS_TYPE_C12(12) TYPE C.
214
215    *-----------------------------------------------------------------------
216    * Verschiedenes.
217    TYPES:
218    * Fehlernummer.
219      IMIS_TYPE_ERROR_NUMBER(1)       TYPE  N,
220    * Tabellenname.
221      IMIS_TYPE_TABLENAME             LIKE  RSTHVKEY-TABNM,
222    * Filename.
223      IMIS_TYPE_FILENAME              LIKE  RAIC1-APPLPHFILE,
224    * Memory-ID.
225      IMIS_TYPE_MEMORY_ID(32)         TYPE  C.
226
227
228    *-----------------------------------------------------------------------
229    * Struktur zur Steuerung der Lesereihenfolge von Tabellen
230      TYPES:
231         BEGIN OF IMIS_TYPE_S_TABLE_ORDER,
232          TABNAM   TYPE IMIS_TYPE_TABLENAME,       "Tabellennam
233          SELECTIV TYPE IMIS_TYPE_FLG,             "Tabelle selektiv
234          SELECTIV_INITIAL TYPE IMIS_TYPE_FLG,     "Tabelle Initialwert sel.
235         END   OF IMIS_TYPE_S_TABLE_ORDER.
236
237    * Zugehorige Tabelle.
238      TYPES: IMIS_TYPE_T_TABLE_ORDER TYPE IMIS_TYPE_S_TABLE_ORDER OCCURS 10.
239
240    *-----------------------------------------------------------------------
241    * DDIC-Tabellen/-Strukturen als Strukturen.
242    TYPES:
243      IMIS_TYPE_S_RSTHIE       LIKE  RSTHIE,
244      IMIS_TYPE_S_RSTHINFO     LIKE  RSTHINFO,
245      IMIS_TYPE_S_RSTTYP       LIKE  RSTTYP,
246      IMIS_TYPE_S_STREENODE    LIKE  STREENODE,
247    *
248      IMIS_TYPE_S_BPJA         LIKE  BPJA,
249      IMIS_TYPE_S_BPGE         LIKE  BPGE,
250      IMIS_TYPE_S_BPCOSU       LIKE  BPCOSU,
251    *
252      IMIS_TYPE_S_RAIMACT      LIKE  RAIMACT,
253    *
254      IMIS_TYPE_S_CEDST        LIKE  CEDST,
255      IMIS_TYPE_S_CFBSF01      LIKE  CFBSF01,
256      IMIS_TYPE_S_CFBDP01      LIKE  CFBDP01,
257      IMIS_TYPE_S_RKB1X        LIKE  RKB1X,
258    *
259      IMIS_TYPE_S_TBDLST       LIKE  TBDLST,
260    *
261      IMIS_TYPE_S_BAPIRETURN1  LIKE  BAPIRETURN1,
262    *
263      IMIS_TYPE_S_DDSHSELOPT   LIKE  DDSHSELOPT,
264      IMIS_TYPE_S_DDSHRETVAL   LIKE  DDSHRETVAL,
265    *
266      imis_type_s_rkb1t        like  rkb1t.
267
268
269    *-----------------------------------------------------------------------
270    * DDIC-Tabellen/-Strukturen als Tabellen.
271    TYPES:
272      IMIS_TYPE_T_BPGE         LIKE  BPGE                     OCCURS 100,
273      IMIS_TYPE_T_BPJA         LIKE  BPJA                     OCCURS 100,
274      IMIS_TYPE_T_BPCOSU       LIKE  BPCOSU                   OCCURS 100,
275    *
276      IMIS_TYPE_T_RAIMACT      LIKE  RAIMACT                  OCCURS 100,
277    *
278      IMIS_TYPE_T_RSTHIE       TYPE  IMIS_TYPE_S_RSTHIE       OCCURS  50,
279      IMIS_TYPE_T_RSTTYP       TYPE  IMIS_TYPE_S_RSTTYP       OCCURS   5,
280      IMIS_TYPE_T_STREENODE    TYPE  IMIS_TYPE_S_STREENODE    OCCURS   0,
281    *
282      IMIS_TYPE_T_CEDST        TYPE  IMIS_TYPE_S_CEDST        OCCURS  10,
283      IMIS_TYPE_T_CFBSF01      TYPE  IMIS_TYPE_S_CFBSF01      OCCURS  10,
284      IMIS_TYPE_T_CFBDP01      TYPE  IMIS_TYPE_S_CFBDP01      OCCURS  10,
285    *
286      IMIS_TYPE_T_TBDLST       TYPE  IMIS_TYPE_S_TBDLST       OCCURS  10,
287    *
288      IMIS_TYPE_T_BAPIRETURN1  TYPE  IMIS_TYPE_S_BAPIRETURN1  OCCURS 10,
289    *
290      IMIS_TYPE_T_DDSHSELOPT   TYPE  IMIS_TYPE_S_DDSHSELOPT   OCCURS   1,
291      IMIS_TYPE_T_DDSHRETVAL   TYPE  IMIS_TYPE_S_DDSHRETVAL   OCCURS   1,
292    *
293      imis_type_t_rkb1t        type  imis_type_s_rkb1t        occurs 10.
294
295
296    *-----------------------------------------------------------------------
297    * Range für Geschäftsjahr als Tabelle.
298    TYPES:
299      IMIS_TYPE_R_GJAHR  LIKE  RNG_GJAHR  OCCURS  1.
300
301
302    *-----------------------------------------------------------------------
303    * Range für Werttyp  als Struktur und Tabelle
304    TYPES:
305      BEGIN OF IMIS_TYPE_R_S_WRTTP,
306       SIGN    LIKE  RNG_GJAHR-SIGN,
307       OPTION  LIKE  RNG_GJAHR-OPTION,
308       LOW     LIKE  BPGE-WRTTP,
309       HIGH    LIKE  BPGE-WRTTP,
310      END   OF IMIS_TYPE_R_S_WRTTP.
311
312    TYPES:
313      IMIS_TYPE_R_WRTTP  TYPE IMIS_TYPE_R_S_WRTTP  OCCURS  5.
314
315
316    *-----------------------------------------------------------------------
317    * Range für Version  als Struktur und Tabelle
318    TYPES:
319      BEGIN OF IMIS_TYPE_R_S_VERSN,
320       SIGN    LIKE  RNG_GJAHR-SIGN,
321       OPTION  LIKE  RNG_GJAHR-OPTION,
322       LOW     LIKE  BPGE-VERSN,
323       HIGH    LIKE  BPGE-VERSN,
324      END   OF IMIS_TYPE_R_S_VERSN.
325
326    TYPES:
327      IMIS_TYPE_R_VERSN  TYPE IMIS_TYPE_R_S_VERSN  OCCURS  5.
328
329    *(BEG INS)                                                   "ALRK138688
330    *-----------------------------------------------------------------------
331    * Range für Bewertung als Struktur und Tabelle
332    TYPES:
333      BEGIN OF IMIS_TYPE_R_S_VALUTYP,
334       SIGN    LIKE  RNG_GJAHR-SIGN,
335       OPTION  LIKE  RNG_GJAHR-OPTION,
336       LOW     LIKE  TKA09-VALUTYP,
337       HIGH    LIKE  TKA09-VALUTYP,
338      END   OF IMIS_TYPE_R_S_VALUTYP.
339
340    TYPES:
341      IMIS_TYPE_R_VALUTYP  TYPE IMIS_TYPE_R_S_VALUTYP OCCURS  5.
342
343    *-----------------------------------------------------------------------
344    * Range für Kostenrechnungskreis als Struktur und Tabelle
345    TYPES:
346      BEGIN OF IMIS_TYPE_R_S_KOKRS,
347       SIGN    TYPE  RALDB_SIGN,
348       OPTION  TYPE  RALDB_OPTI,
349       LOW     LIKE  IMPR-KOKRS,
350       HIGH    LIKE  IMPR-KOKRS,
351      END   OF IMIS_TYPE_R_S_KOKRS.
352
353    TYPES:
354      IMIS_TYPE_R_KOKRS   TYPE IMIS_TYPE_R_S_KOKRS   OCCURS  5.
355    *(END INS)                                                   "ALRK138688
356
357    *-----------------------------------------------------------------------
358    * Range für Status als Struktur und Tabelle
359    TYPES:
360      BEGIN OF IMIS_TYPE_R_S_STATUS,
361       SIGN    TYPE  RALDB_SIGN,
362       OPTION  TYPE  RALDB_OPTI,
363       LOW     TYPE  J_STATUS,
364       HIGH    TYPE  J_STATUS,
365      END   OF IMIS_TYPE_R_S_STATUS.
366
367    TYPES:
368      IMIS_TYPE_R_STATUS  TYPE IMIS_TYPE_R_S_STATUS  OCCURS  5.
369
370
371    *-----------------------------------------------------------------------
372    * Einzelstatus zu einem Objekt als Struktur und Tabelle.
373    TYPES:
374      BEGIN OF IMIS_TYPE_S_OBJ_STATUS,
375        OBJNR   TYPE  J_OBJNR,
376        STATUS  TYPE  J_STATUS,
377      END   OF IMIS_TYPE_S_OBJ_STATUS.
378
379    TYPES:
380      IMIS_TYPE_T_OBJ_STATUS  TYPE  IMIS_TYPE_S_OBJ_STATUS  OCCURS 0.
381
382
383    *-----------------------------------------------------------------------
384    * Logisches System als Struktur, Tabelle und Hash-Tabelle.
385    TYPES:
386      BEGIN OF IMIS_TYPE_S_LOGSYS,
387        LOGSYSTEM  LIKE  IMCH-LOGSYSTEM,
388      END   OF IMIS_TYPE_S_LOGSYS.
389
390    TYPES:
391      IMIS_TYPE_T_LOGSYS TYPE IMIS_TYPE_S_LOGSYS OCCURS 5.
392
393    TYPES:
394      IMIS_TYPE_TH_LOGSYS  TYPE  HASHED TABLE
395                           OF    IMIS_TYPE_S_LOGSYS
396                           WITH UNIQUE KEY LOGSYSTEM
397                           INITIAL SIZE 1.
398
399
400    *-----------------------------------------------------------------------
401    * Kostenrechnungskreis als  ....
402    TYPES:
403    * Struktur
404      BEGIN OF IMIS_TYPE_S_KOKRS,
405        KOKRS  LIKE  TKA01-KOKRS,
406      END   OF IMIS_TYPE_S_KOKRS.
407
408    TYPES:                                                       "ALRK138688
409    * Tabelle                                                    "ALRK138688
410      IMIS_TYPE_T_KOKRS TYPE IMIS_TYPE_S_KOKRS OCCURS 2.         "ALRK138688
411
412    TYPES:
413    * Hash-Tabelle
414      IMIS_TYPE_TH_KOKRS  TYPE  HASHED TABLE
415                          OF    IMIS_TYPE_S_KOKRS
416                          WITH UNIQUE KEY KOKRS
417                          INITIAL SIZE 1.
418
419
420    *-----------------------------------------------------------------------
421    * Gesellschaft als Struktur und Hash-Tabelle.
422    TYPES:
423      BEGIN OF IMIS_TYPE_S_RCOMP,
424        RCOMP  LIKE  T880-RCOMP,
425      END   OF IMIS_TYPE_S_RCOMP.
426
427    TYPES:
428      IMIS_TYPE_TH_RCOMP  TYPE  HASHED TABLE
429                          OF    IMIS_TYPE_S_RCOMP
430                          WITH UNIQUE KEY RCOMP
431                          INITIAL SIZE 1.
432
433
434    *-----------------------------------------------------------------------
435    * Codingzeilen als Struktur und Tabelle.
436    TYPES:
437      BEGIN OF IMIS_TYPE_S_LINE,
438        LINE(72)  TYPE  C,
439      END   OF IMIS_TYPE_S_LINE.
440
441    TYPES:
442      IMIS_TYPE_T_LINE  TYPE  IMIS_TYPE_S_LINE  OCCURS 10.
443
444
445    *-----------------------------------------------------------------------
446    * Messages als Struktur, Standardtabelle, Hash-Tabelle und beliebige
447    * Tabelle. (Der Schlüssel ist jeweils die ganze Tabellenzeile, da
448    * es nur Character-Felder gibt!).
449    TYPES: BEGIN OF IMIS_TYPE_S_MESSAGE.
450             INCLUDE  STRUCTURE  HIER_MESS.
451    TYPES: END   OF IMIS_TYPE_S_MESSAGE.
452
453    TYPES:
454      IMIS_TYPE_T_MESSAGES   TYPE  STANDARD TABLE
455                             OF    IMIS_TYPE_S_MESSAGE
456                             WITH  DEFAULT KEY
457                             INITIAL SIZE 10,
458    *
459      IMIS_TYPE_TH_MESSAGES  TYPE  HASHED TABLE
460                             OF    IMIS_TYPE_S_MESSAGE
461                             WITH UNIQUE DEFAULT KEY
462                             INITIAL SIZE 10,
463    *
464      IMIS_TYPE_TA_MESSAGES  TYPE  ANY TABLE
465                             OF    IMIS_TYPE_S_MESSAGE
466                             WITH  DEFAULT KEY
467                             INITIAL SIZE 10.
468
469
470    *-----------------------------------------------------------------------
471    * Aktionskennzeichen mit zugehörigen Konstanten.
472    * (benutzt für verschiedene Zwecke!)
473    TYPES:
474      IMIS_TYPE_ACTION(1) TYPE C.
475
476    CONSTANTS:
477      BEGIN OF IMIS_CON_S_ACTION,
478        INSERT   TYPE  IMIS_TYPE_ACTION  VALUE 'I',
479        UPDATE   TYPE  IMIS_TYPE_ACTION  VALUE 'U',
480        DELETE   TYPE  IMIS_TYPE_ACTION  VALUE 'D',
481    *
482        ENQUEUE  TYPE  IMIS_TYPE_ACTION  VALUE 'E',
483        DEQUEUE  TYPE  IMIS_TYPE_ACTION  VALUE 'D',
484      END   OF IMIS_CON_S_ACTION.
485
486
487
488
489    ************************************************************************
490    * Typen speziell für Investprogramme.
491    * >PROG
492    ************************************************************************
493
494    *-----------------------------------------------------------------------
495    * Inv. Programmname und logisches System als Struktur ...
496    TYPES: BEGIN OF IMIS_TYPE_S_PROG_LOGSYS,
497            LOGSYS     LIKE BAPI1057CD-LOGSYSTEM,
498            APPR_YEAR  LIKE BAPI1057CD-APPR_YEAR,
499            INV_PROG   LIKE BAPI1057CD-INV_PROG,
500           END OF IMIS_TYPE_S_PROG_LOGSYS.
501
502    * ... und HASHED-Tabelle.
503    TYPES: IMIS_TYPE_TH_PROG_LOGSYS TYPE HASHED TABLE
504           OF IMIS_TYPE_S_PROG_LOGSYS
505           WITH UNIQUE DEFAULT KEY
506           INITIAL SIZE 5.
507
508    *-----------------------------------------------------------------------
509    * DDIC-Strukturen/-Tabellen als Strukturen.
510    TYPES:
511      IMIS_TYPE_S_IMPR      LIKE  IMPR,
512      IMIS_TYPE_S_IMPU      LIKE  IMPU,
513      IMIS_TYPE_S_IMTP      LIKE  IMTP,
514      IMIS_TYPE_S_IMTT      LIKE  IMTT,
515      IMIS_TYPE_S_IMZO      LIKE  IMZO,
516      IMIS_TYPE_S_TAIF2     LIKE  TAIF2,
517    *
518      IMIS_TYPE_S_RAIPATTR  LIKE  RAIPATTR,
519    *
520      IMIS_TYPE_S_BPGE_IM   LIKE  BPGE_IM,
521      IMIS_TYPE_S_BPJA_IM   LIKE  BPJA_IM.
522
523    *-----------------------------------------------------------------------
524    * DDIC-Strukturen/-Tabellen als Tabelle.
525    TYPES:
526      IMIS_TYPE_T_IMTT   TYPE  IMIS_TYPE_S_IMTT   OCCURS  10,
527      IMIS_TYPE_T_IMPU   TYPE  IMIS_TYPE_S_IMPU   OCCURS   1,
528      IMIS_TYPE_T_IMZO   TYPE  IMIS_TYPE_S_IMZO   OCCURS  10,
529      IMIS_TYPE_T_TAIF2  TYPE  IMIS_TYPE_S_TAIF2  OCCURS   5.
530
531
532
533    *-----------------------------------------------------------------------
534    * BAPI-Strukturen als Strukturen.
535    TYPES:
536      IMIS_TYPE_S_BAPI1057CA  LIKE  BAPI1057CA,
537      IMIS_TYPE_S_BAPI1057CC  LIKE  BAPI1057CC,
538      IMIS_TYPE_S_BAPI1057CD  LIKE  BAPI1057CD,
539      IMIS_TYPE_S_BAPI1057CS  LIKE  BAPI1057CS,
540      IMIS_TYPE_S_BAPI1057C0  LIKE  BAPI1057C0,
541      IMIS_TYPE_S_BAPI1057C1  LIKE  BAPI1057C1,
542      IMIS_TYPE_S_BAPI1057C2  LIKE  BAPI1057C2,
543      IMIS_TYPE_S_BAPI1057C3  LIKE  BAPI1057C3,
544      IMIS_TYPE_S_BAPI1057C4  LIKE  BAPI1057C4,
545      IMIS_TYPE_S_BAPI1057C5  LIKE  BAPI1057C5,
546      IMIS_TYPE_S_BAPI1057C6  LIKE  BAPI1057C6.
547
548
549    *-----------------------------------------------------------------------
550    * BAPI-Strukturen als Tabellen.
551    TYPES:
552      IMIS_TYPE_T_BAPI1057CD  TYPE  IMIS_TYPE_S_BAPI1057CD  OCCURS 100,
553      IMIS_TYPE_T_BAPI1057CC  TYPE  IMIS_TYPE_S_BAPI1057CC  OCCURS  10,
554      IMIS_TYPE_T_BAPI1057CS  TYPE  IMIS_TYPE_S_BAPI1057CS  OCCURS  10,
555      IMIS_TYPE_T_BAPI1057C1  TYPE  IMIS_TYPE_S_BAPI1057C1  OCCURS  50,
556      IMIS_TYPE_T_BAPI1057C2  TYPE  IMIS_TYPE_S_BAPI1057C2  OCCURS  50,
557      IMIS_TYPE_T_BAPI1057C3  TYPE  IMIS_TYPE_S_BAPI1057C3  OCCURS  50,
558      IMIS_TYPE_T_BAPI1057C4  TYPE  IMIS_TYPE_S_BAPI1057C4  OCCURS  50,
559      IMIS_TYPE_T_BAPI1057C5  TYPE  IMIS_TYPE_S_BAPI1057C5  OCCURS  50,
560      IMIS_TYPE_T_BAPI1057C6  TYPE  IMIS_TYPE_S_BAPI1057C6  OCCURS  50.
561
562
563
564    ************************************************************************
565    * Typen speziell für Recherche Investitionsprogramme/Maßnahmen-
566    * Anforderungen
567    * >RECH
568    ************************************************************************
569
570    *-----------------------------------------------------------------------
571    * DDIC-Strukturen und Tabellen für Recherche InvProgramme
572    * als Strukturen und Tabellen.
573    TYPES:
574      IMIS_TYPE_S_RIPASP_SEL  LIKE  RIPASP_SEL,
575      IMIS_TYPE_T_RIPASP_SEL  TYPE  IMIS_TYPE_S_RIPASP_SEL  OCCURS   1,
576    *
577      IMIS_TYPE_S_RIPASP_KFC  LIKE  RIPASP_KFC,
578      IMIS_TYPE_T_RIPASP_KFC  TYPE  IMIS_TYPE_S_RIPASP_KFC  OCCURS  10,
579    *
580      IMIS_TYPE_S_RIPASP_KF   LIKE  RIPASP_KF ,
581      IMIS_TYPE_T_RIPASP_KF   TYPE  IMIS_TYPE_S_RIPASP_KF   OCCURS  10,
582    *
583      IMIS_TYPE_S_RIPASP_MDC  LIKE  RIPASP_MDC,
584      IMIS_TYPE_T_RIPASP_MDC  TYPE  IMIS_TYPE_S_RIPASP_MDC  OCCURS   1,
585    *
586      IMIS_TYPE_S_RIPASW      LIKE  RIPASW,
587      IMIS_TYPE_T_RIPASW      LIKE  RIPASW                  OCCURS 50.
588
589
590    *-----------------------------------------------------------------------
591    * Berichtsdaten InvProgramme als Struktur, Tabelle, Hash-Tabelle.
592    TYPES:
593      IMIS_TYPE_S_RIPASP  LIKE  RIPASP,
594    *
595      IMIS_TYPE_T_RIPASP  TYPE  STANDARD TABLE
596                          OF    IMIS_TYPE_S_RIPASP
597                          WITH  DEFAULT KEY
598                          INITIAL SIZE 100,
599    *
600      IMIS_TYPE_TH_RIPASP TYPE  HASHED TABLE
601                          OF    IMIS_TYPE_S_RIPASP
602                          WITH  UNIQUE DEFAULT KEY
603                          INITIAL SIZE 50.
604
605
606    *-----------------------------------------------------------------------
607    * Berichtsdaten MAnfen als Struktur, Tabelle.
608    TYPES:
609      IMIS_TYPE_S_RIRASP  LIKE  RIRASP,
610    *
611      IMIS_TYPE_T_RIRASP  TYPE  STANDARD TABLE
612                          OF    IMIS_TYPE_S_RIRASP
613                          WITH  DEFAULT KEY
614                          INITIAL SIZE 50.
615
616
617    *-----------------------------------------------------------------------
618    * Kennzeichen für die in einem Recherchebericht für
619    * - InvProgramme
620    * - MaßnahmenAnforderungen
621    * selektierten Merkmale und Kennzahlen als Struktur:
622    * - Zu jedem (potentiellen) Merkmal/jeder (potentiellen)
623    *   Kennzahl sollte es hier ein Kennzeichen GLEICHEN NAMENS geben!
624    *   (Wenn ein Kennzeichen nicht vorhanden ist, wird es einfach
625    *   ignoriert!)
626    * - Zu den reinen Selektionsfeldern in den Recherche-Strukturen muß es
627    *   hier nicht unbedingt ein Kennzeichen geben.
628    * - Im Prinzip sollten hier also für alle Felder der Strukturen
629    *   RIPASP und RIRASP ein Kennzeichen geben, mit Ausnahme der Felder
630    *   in den Unterstrukturen RIPASP_SEL und RIRASP_SEL.
631    * Mit dem Report RAIMREC1 kann geprüft werden, für welche Felder einer
632    * DDIC-Struktur es hier kein Kennzeichen gibt!
633    TYPES:
634      BEGIN OF IMIS_TYPE_S_FIELD_FLAGS,
635        HIEOBJ        TYPE IMIS_TYPE_FLG,
636        POSNR         TYPE IMIS_TYPE_FLG,
637        LEAF_POSNR    TYPE IMIS_TYPE_FLG,
638        REQ_POSNR     TYPE IMIS_TYPE_FLG,
639        MEASURE       TYPE IMIS_TYPE_FLG,
640        PS_POSID      TYPE IMIS_TYPE_FLG,
641        AUFNR         TYPE IMIS_TYPE_FLG,
642        WRTTP         TYPE IMIS_TYPE_FLG,
643        VALUTYP       TYPE IMIS_TYPE_FLG,                        "ALRK138688
644        VERSN         TYPE IMIS_TYPE_FLG,
645        GNJHR         TYPE IMIS_TYPE_FLG,
646        VARNT         TYPE IMIS_TYPE_FLG,
647        IPPOS         TYPE IMIS_TYPE_FLG,
648        TRGKZ         TYPE IMIS_TYPE_FLG,
649        VORGA         TYPE IMIS_TYPE_FLG,
650        GJAHR         TYPE IMIS_TYPE_FLG,
651        USERVAL       TYPE IMIS_TYPE_FLG,
652        CONGR         TYPE IMIS_TYPE_FLG,
653        RCOMP         TYPE IMIS_TYPE_FLG,
654        ARCOMP        TYPE IMIS_TYPE_FLG,
655        VRCOMP        TYPE IMIS_TYPE_FLG,
656        BUKRS         TYPE IMIS_TYPE_FLG,
657        ABUKRS        TYPE IMIS_TYPE_FLG,
658        VBUKRS        TYPE IMIS_TYPE_FLG,
659        GSBER         TYPE IMIS_TYPE_FLG,
660        AGSBER        TYPE IMIS_TYPE_FLG,
661        VGSBER        TYPE IMIS_TYPE_FLG,
662        KOKRS         TYPE IMIS_TYPE_FLG,
663        PRCTR         TYPE IMIS_TYPE_FLG,
664        APRCTR        TYPE IMIS_TYPE_FLG,
665        VPRCTR        TYPE IMIS_TYPE_FLG,
666        KOSTL         TYPE IMIS_TYPE_FLG,
667        AKOSTL        TYPE IMIS_TYPE_FLG,
668        VKOSTL        TYPE IMIS_TYPE_FLG,
669        FKBER         TYPE IMIS_TYPE_FLG,
670        ASPART        TYPE IMIS_TYPE_FLG,
671        AMATKL        TYPE IMIS_TYPE_FLG,
672        WERKS         TYPE IMIS_TYPE_FLG,
673        STORT         TYPE IMIS_TYPE_FLG,
674        BEBER         TYPE IMIS_TYPE_FLG,
675        TPLNR         TYPE IMIS_TYPE_FLG,
676        LAND1         TYPE IMIS_TYPE_FLG,
677        VERNR         TYPE IMIS_TYPE_FLG,
678        PARVW         TYPE IMIS_TYPE_FLG,
679        PARNR         TYPE IMIS_TYPE_FLG,
680        ERGSO         TYPE IMIS_TYPE_FLG,
681        IZWEK         TYPE IMIS_TYPE_FLG,
682        UMWKZ         TYPE IMIS_TYPE_FLG,
683        PPRIO         TYPE IMIS_TYPE_FLG,
684        STATUS_REQ    TYPE IMIS_TYPE_FLG,
685        STATUS        TYPE IMIS_TYPE_FLG,
686        OBART         TYPE IMIS_TYPE_FLG,
687        SIZECL        TYPE IMIS_TYPE_FLG,
688        XGNJ          TYPE IMIS_TYPE_FLG,
689        ORG_GNJHR     TYPE IMIS_TYPE_FLG,
690        GNJHR_REQ     TYPE IMIS_TYPE_FLG,
691        CHARAC_REQ    TYPE IMIS_TYPE_FLG,
692        MEAS_REQ      TYPE IMIS_TYPE_FLG,
693        SCOPE         TYPE IMIS_TYPE_FLG,
694        USR00         TYPE IMIS_TYPE_FLG,
695        USR01         TYPE IMIS_TYPE_FLG,
696        USR02         TYPE IMIS_TYPE_FLG,
697        USR03         TYPE IMIS_TYPE_FLG,
698        USR10         TYPE IMIS_TYPE_FLG,
699        USR11         TYPE IMIS_TYPE_FLG,
700        USR12         TYPE IMIS_TYPE_FLG,
701        USR13         TYPE IMIS_TYPE_FLG,
702        WGP           TYPE IMIS_TYPE_FLG,
703        WGPV          TYPE IMIS_TYPE_FLG,
704        WJP           TYPE IMIS_TYPE_FLG,
705        WJPV          TYPE IMIS_TYPE_FLG,
706        EWGP          TYPE IMIS_TYPE_FLG,
707        EWJP          TYPE IMIS_TYPE_FLG,
708        WGK           TYPE IMIS_TYPE_FLG,
709        WJK           TYPE IMIS_TYPE_FLG,
710        EWGK          TYPE IMIS_TYPE_FLG,
711        EWJK          TYPE IMIS_TYPE_FLG,
712        KAPWRT        TYPE IMIS_TYPE_FLG,
713        IZFUS         TYPE IMIS_TYPE_FLG,
714        AMORT         TYPE IMIS_TYPE_FLG,
715        GPCNT         TYPE IMIS_TYPE_FLG,
716        owaers        type imis_type_flg,
717      END   OF IMIS_TYPE_S_FIELD_FLAGS.
718
719
720    *-----------------------------------------------------------------------
721    * Globale Selektionen für einen Recherchebericht als Struktur.
722    TYPES:
723      BEGIN OF IMIS_TYPE_S_SEL_FLAGS,
724    *   Nur Blätter eines InvestitionsProgramms.
725        ONLY_LEAFS      TYPE IMIS_TYPE_FLG,
726    *   Planwerte MaßnahmenAnforderung.
727        RPLAN           TYPE IMIS_TYPE_FLG,
728    *   Kennzahlen Wirtschaftlichkeitsrechnung.
729        PROF_VALUES     TYPE IMIS_TYPE_FLG,
730    *   MaßnahmenAnforderungen.
731        REQUESTS        TYPE IMIS_TYPE_FLG,
732    *   Planwerte Maßnahmen.
733        MPLAN           TYPE IMIS_TYPE_FLG,
734    *   Budgetwerte Maßnahmen.
735        MBUDG           TYPE IMIS_TYPE_FLG,
736    *   Freigabewerte Maßnahmen.
737        MRELEASE        TYPE IMIS_TYPE_FLG,                      "ALRK138126
738    *   Verfügtwerte Maßnahmen (Ist oder Obligo oder Anzahlungen).
739        COSTS           TYPE IMIS_TYPE_FLG,
740    *   PSP-Elemente.
741        WBS_ELMS        TYPE IMIS_TYPE_FLG,
742    *   Aufträge.
743        ORDERS          TYPE IMIS_TYPE_FLG,
744    *   Gesamtwerte.
745        OVERALL_VALUES  TYPE IMIS_TYPE_FLG,
746    *   Jahreswerte.
747        ANNUAL_VALUES   TYPE IMIS_TYPE_FLG,
748    *   Alte Werte (InvProgramm) oder alte Maßnahmen.
749        OLDMS           TYPE IMIS_TYPE_FLG,
750    *   Zukünftige Werte (InvProgramm).
751        FUTMS           TYPE IMIS_TYPE_FLG,
752    *   Status.
753        MSTAT           TYPE IMIS_TYPE_FLG,
754      END   OF IMIS_TYPE_S_SEL_FLAGS.
755
756
757    *-----------------------------------------------------------------------
758    * Felder für Recherche-fremde Zusatzselektionen als Struktur, d.h.
759    * enthalten sind alle Selektionsfelder, die keine Merkmale sind,
760    * also i.w. die Felder aus RIPASP_SEL und RIRASP_SEL.
761    TYPES: BEGIN OF IMIS_TYPE_S_ADD_SEL.
762             INCLUDE     STRUCTURE RIPASP_SEL.
763    TYPES:   AB_POSID    LIKE      IMPR-POSID,    " Positions-ID Ab-Position
764             REQ_STATSL  LIKE      RIRASP-REQ_STATSL.
765    TYPES: END OF IMIS_TYPE_S_ADD_SEL.
766
767
768
769
770    ************************************************************************
771    * Typen speziell für MaßnahmenAnforderungen
772    * >REQ
773    ************************************************************************
774
775    *-----------------------------------------------------------------------
776    * DDIC-Tabellen/-Strukturen als Strukturen.
777    TYPES:
778      IMIS_TYPE_S_IHPA       LIKE  IHPA,
779      IMIS_TYPE_S_IMAK       LIKE  IMAK,
780      IMIS_TYPE_S_IMAKT      LIKE  IMAKT,
781      IMIS_TYPE_S_IMAKA      LIKE  IMAKA,
782      IMIS_TYPE_S_IMAKPA     LIKE  IMAKPA,
783      IMIS_TYPE_S_IMAKPI     LIKE  IMAKPI,
784      IMIS_TYPE_S_IMAKPS     LIKE  IMAKPS,
785      IMIS_TYPE_S_IMAKPU     LIKE  IMAKPU,
786      IMIS_TYPE_S_IMAKPW     LIKE  IMAKPW,
787      IMIS_TYPE_S_IMAV       LIKE  IMAV,
788      IMIS_TYPE_S_IMAVZ      LIKE  IMAVZ,
789      IMIS_TYPE_S_IMAKZS     LIKE  IMAKZS,
790      IMIS_TYPE_S_RAIPPASC   LIKE  RAIPPASC,
791      IMIS_TYPE_S_RAIPWI     LIKE  RAIPWI,
792      IMIS_TYPE_S_RIMAKPGES  LIKE  RIMAKPGES.
793
794
795    *-----------------------------------------------------------------------
796    * Tabellentypen  zu DDIC-Tabellen/-Strukturen.
797    TYPES:
798      IMIS_TYPE_T_IHPA       TYPE  IMIS_TYPE_S_IHPA       OCCURS  100,
799    *
800      IMIS_TYPE_T_IMAK       TYPE  IMIS_TYPE_S_IMAK       OCCURS  100,
801      IMIS_TYPE_T_IMAKT      LIKE  IMAKT                  OCCURS  100,
802      IMIS_TYPE_T_IMAKA      TYPE  IMIS_TYPE_S_IMAKA      OCCURS  100,
803      IMIS_TYPE_T_IMAKPA     TYPE  IMIS_TYPE_S_IMAKPA     OCCURS  100,
804      IMIS_TYPE_T_IMAKPI     TYPE  IMIS_TYPE_S_IMAKPI     OCCURS  100,
805      IMIS_TYPE_T_IMAKPS     TYPE  IMIS_TYPE_S_IMAKPS     OCCURS  100,
806      IMIS_TYPE_T_IMAKPU     TYPE  IMIS_TYPE_S_IMAKPU     OCCURS  100,
807      IMIS_TYPE_T_IMAKPW     TYPE  IMIS_TYPE_S_IMAKPW     OCCURS  100,
808      IMIS_TYPE_T_IMAV       TYPE  IMIS_TYPE_S_IMAV       OCCURS  100,
809      IMIS_TYPE_T_IMAVZ      TYPE  IMIS_TYPE_S_IMAVZ      OCCURS  100,
810      IMIS_TYPE_T_IMAKZ      LIKE  IMAKZ                  OCCURS  100,
811      IMIS_TYPE_T_IMAKZS     LIKE  IMAKZS                 OCCURS  100,
812      IMIS_TYPE_T_RAIPWI     TYPE  IMIS_TYPE_S_RAIPWI     OCCURS    5,
813      IMIS_TYPE_T_RIMAKPGES  TYPE  IMIS_TYPE_S_RIMAKPGES  OCCURS   10.
814
815    *-----------------------------------------------------------------------
816    * MAnf-Nummern intern/extern als Struktur und Tabelle.
817    TYPES: BEGIN OF IMIS_TYPE_S_REQUEST_NUMBERS,
818            POSID LIKE IMAK-POSID,
819            POSNR LIKE IMAK-POSNR,
820    *       pspnr LIKE imak-pspnr,
821           END   OF IMIS_TYPE_S_REQUEST_NUMBERS.
822
823    TYPES: IMIS_TYPE_T_REQUEST_NUMBERS TYPE IMIS_TYPE_S_REQUEST_NUMBERS
824           OCCURS 5.
825
826    *-----------------------------------------------------------------------
827    * RANGE an interne Nummer MaßnahmenAnforderung als Struktur und Tabelle.
828
829    TYPES: BEGIN OF IMIS_TYPE_R_S_POSNR,
830            SIGN(1)   TYPE C,
831            OPTION(2) TYPE C,
832            LOW       LIKE IMAK-POSNR,
833            HIGH      LIKE IMAK-POSNR,
834           END   OF IMIS_TYPE_R_S_POSNR.
835
836    TYPES: IMIS_TYPE_R_T_POSNR TYPE IMIS_TYPE_R_S_POSNR OCCURS 4.
837
838
839    *-----------------------------------------------------------------------
840    * Interne Nummer MaßnahmenAnforderung als Struktur und Tabelle.
841    TYPES:
842      BEGIN OF IMIS_TYPE_S_REQ_POSNR,
843        POSNR LIKE IMAK-POSNR,
844      END   OF IMIS_TYPE_S_REQ_POSNR.
845
846    TYPES:
847      IMIS_TYPE_T_REQ_POSNR TYPE IMIS_TYPE_S_REQ_POSNR OCCURS 10.
848
849
850    *-----------------------------------------------------------------------
851    * Prozentuale Aufteilung MaßnAnforderung als Strukur und Tabelle.
852    TYPES:
853      BEGIN OF IMIS_TYPE_SX_REQ_PSPLIT,
854        POSNR   LIKE  IMAK-POSNR,                 " Interne Nummer MAnf
855        OBJNR   LIKE  IMAK-OBJNR,                 " Objektnummer MAnf
856        T_PGES  LIKE  RIMAKPGES OCCURS 5,         " Tab. proz. Aufteilung
857      END   OF IMIS_TYPE_SX_REQ_PSPLIT.
858
859    TYPES:
860      IMIS_TYPE_TX_REQ_PSPLIT TYPE IMIS_TYPE_SX_REQ_PSPLIT OCCURS 100.
861
862    *-----------------------------------------------------------------------
863    * Beziehung MAnf zu ihren Varianten als Struktur und Tabelle
864    TYPES: BEGIN OF IMIS_TYPE_S_REQ_VARNT,
865            POSNR_REQ  LIKE IMAK-POSNR,
866            POSNR_VAR  LIKE IMAV-VARNT,
867            OBJNR_VAR  LIKE BPGE-OBJNR,
868          END   OF IMIS_TYPE_S_REQ_VARNT.
869
870    TYPES: IMIS_TYPE_T_REQ_VARNT TYPE IMIS_TYPE_S_REQ_VARNT OCCURS 100.
871
872    *-----------------------------------------------------------------------
873    * Zuordnung Variante - Anforderung - Planversion als Struktur und
874    * Tabelle.
875    TYPES:
876      BEGIN OF IMIS_TYPE_S_VARRQVERS,
877        OBJNR_VAR  LIKE IMAV-OBJNR,             " Objektnummer Variante
878        OBJNR_REQ  LIKE IMAK-OBJNR,             " Objektnummer MAnf
879        VERSI      LIKE IMAVZ-VERSI,            " Planversion
880      END   OF IMIS_TYPE_S_VARRQVERS.
881
882    TYPES:
883      IMIS_TYPE_T_VARRQVERS TYPE IMIS_TYPE_S_VARRQVERS OCCURS 100.
884
885
886    *-----------------------------------------------------------------------
887    * Partnernummer als interne Struktur und Tabelle.
888    TYPES:
889      BEGIN OF IMIS_TYPE_S_PARNR,
890        PARNR  LIKE  IHPA-PARNR,
891      END   OF IMIS_TYPE_S_PARNR.
892
893    TYPES:
894      IMIS_TYPE_T_PARNR  TYPE  IMIS_TYPE_S_PARNR  OCCURS  5.
895
896
897    *-----------------------------------------------------------------------
898    * Rolle mit zugehörigen Partnernummern als interne Struktur und Tabelle.
899    TYPES:
900      BEGIN OF IMIS_TYPE_SX_ROPA,
901        PARVW    LIKE  TPAR-PARVW,
902        T_PARNR  TYPE  IMIS_TYPE_T_PARNR,
903      END   OF IMIS_TYPE_SX_ROPA.
904
905    TYPES:
906      IMIS_TYPE_TX_ROPA  TYPE  IMIS_TYPE_SX_ROPA  OCCURS  3.
907
908
909    *-----------------------------------------------------------------------
910    * Partner zu MAnf als Struktur und Tabelle.
911    types:
912      BEGIN OF IMIS_TYPE_SX_REQ_PARTNER,
913        OBJNR   LIKE  IMAK-OBJNR,               " Objektnummer MAnf
914        T_ROPA  TYPE  IMIS_TYPE_TX_ROPA,        " Tab. Rollen mit Partnern.
915      END   OF IMIS_TYPE_SX_REQ_PARTNER.
916
917    TYPES:
918      IMIS_TYPE_TX_REQ_PARTNER  TYPE  IMIS_TYPE_SX_REQ_PARTNER  OCCURS 100.
919
920
921    *-----------------------------------------------------------------------
922    * Kennzahlen Wirtschaftlichkeitsrechnung pro Objekt als Struktur und
923    * Tabelle.
924    TYPES:
925      BEGIN OF IMIS_TYPE_SX_REQ_PROF,
926        POSNR     LIKE IMAK-POSNR,              " Interne Nummer MAnf
927        OBJNR     LIKE IMAK-OBJNR,              " Objektnummer MAnf
928        T_RAIPWI  TYPE IMIS_TYPE_T_RAIPWI,      " Tab. Kennzahlen Wi-Rechn.
929      END   OF IMIS_TYPE_SX_REQ_PROF.
930
931    TYPES:
932      IMIS_TYPE_TX_REQ_PROF  TYPE  IMIS_TYPE_SX_REQ_PROF  OCCURS 100.
933
934
935    *-----------------------------------------------------------------------
936    * Versionen, Varianten und Kennzahlen Wi-Rechnung als Struktur und
937    * Tabelle.
938    TYPES: BEGIN OF IMIS_TYPE_S_IMAVZ_PROF.
939             INCLUDE   TYPE  IMIS_TYPE_S_IMAVZ.
940             INCLUDE   TYPE  IMIS_TYPE_S_RAIPWI.
941    TYPES: END   OF IMIS_TYPE_S_IMAVZ_PROF.
942
943    TYPES:
944      IMIS_TYPE_T_IMAVZ_PROF  TYPE  IMIS_TYPE_S_IMAVZ_PROF  OCCURS 100.
945
946
947    *-----------------------------------------------------------------------
948    * Character einer MaßnahmenAnforderung als Struktur und Tabelle.
949    TYPES:
950      BEGIN OF IMIS_TYPE_S_REQ_CHARACTER,
951        POSNR      TYPE  IMA_POSNR,
952        CHARACTER  TYPE  IMA_REQ_CH,
953      END   OF IMIS_TYPE_S_REQ_CHARACTER.
954
955    TYPES:
956      IMIS_TYPE_T_REQ_CHARACTER  TYPE   IMIS_TYPE_S_REQ_CHARACTER
957                                 OCCURS 10.
958
959    *-----------------------------------------------------------------------
960    * Range für MAnf-Charakter als Struktur und Tabelle
961    TYPES:
962      BEGIN OF IMIS_TYPE_R_S_CHARAC_REQ,
963        SIGN    LIKE  RNG_GJAHR-SIGN,
964        OPTION  LIKE  RNG_GJAHR-OPTION,
965        LOW     LIKE  RIRASP-CHARAC_REQ,
966        HIGH    LIKE  RIRASP-CHARAC_REQ,
967      END   OF IMIS_TYPE_R_S_CHARAC_REQ.
968
969    TYPES:
970      IMIS_TYPE_R_CHARAC_REQ  TYPE IMIS_TYPE_R_S_CHARAC_REQ  OCCURS  5.
971
972
973    *-----------------------------------------------------------------------
974    * Range für Beziehung Massnahme zur MAnf als Struktur und Tabelle
975    TYPES:
976      BEGIN OF IMIS_TYPE_R_S_MEAS_REQ,
977        SIGN    LIKE  RNG_GJAHR-SIGN,
978        OPTION  LIKE  RNG_GJAHR-OPTION,
979        LOW     LIKE  RIRASP-MEAS_REQ,
980        HIGH    LIKE  RIRASP-MEAS_REQ,
981      END   OF IMIS_TYPE_R_S_MEAS_REQ.
982
983    TYPES:
984      IMIS_TYPE_R_MEAS_REQ  TYPE IMIS_TYPE_R_S_MEAS_REQ  OCCURS  5.
985
986
987    *-----------------------------------------------------------------------
988    * Hauptsystemstatus einer MaßnahmenAnforderung als Struktur und Tabelle.
989    TYPES:
990      BEGIN OF IMIS_TYPE_S_REQ_STATUS,
991        POSNR      TYPE  IMA_POSNR,
992        STATUS     TYPE  IMA_STATUS,
993      END   OF IMIS_TYPE_S_REQ_STATUS.
994
995    TYPES:
996      IMIS_TYPE_T_REQ_STATUS     TYPE   IMIS_TYPE_S_REQ_STATUS
997                                 OCCURS 10.
998
999
1000   ************************************************************************
1001   * Typen allgemein für Maßnahmen.
1002   * >MEAS
1003   ************************************************************************
1004
1005   *-----------------------------------------------------------------------
1006   * Range für Beziehung zu MAnfen.
1007   TYPES:
1008     BEGIN OF IMIS_TYPE_S_R_MEAS_REL,
1009       SIGN   TYPE  RALDB_SIGN,
1010       OPTION TYPE  RALDB_OPTI,
1011       LOW    TYPE  IM_MEAS_AS,
1012       HIGH   TYPE  IM_MEAS_AS,
1013     END   OF IMIS_TYPE_S_R_MEAS_REL.
1014
1015   TYPES:
1016     IMIS_TYPE_R_MEAS_REL  TYPE  IMIS_TYPE_S_R_MEAS_REL  OCCURS 1.
1017
1018   *-----------------------------------------------------------------------
1019   * Struktur und Tabelle fuer Erwartungswerte
1020   TYPES:
1021     BEGIN OF IMIS_TYPE_S_EXPECTATION_VAL,
1022       GJAHR    LIKE BPJA-GJAHR,
1023       VALUT    LIKE TKA09-VALUTYP,                             "ALRK138688
1024       VERSN    LIKE BPJA-VERSN,
1025   *   Erwartungswert: Kostenrechnungskreiswährung.
1026       VALUE    LIKE BPJA-WlJHR,
1027   *   Erwartungswert: Objektwährung.
1028       VALUE_O  like bpja-wljhr,
1029     END   OF IMIS_TYPE_S_EXPECTATION_VAL.
1030
1031   TYPES:
1032     IMIS_TYPE_T_EXPECTATION_VAL TYPE IMIS_TYPE_S_EXPECTATION_VAL
1033                                      OCCURS 100.
1034
1035   ************************************************************************
1036   * Typen speziell für Aufträge
1037   * >ORD
1038   ************************************************************************
1039
1040   *-----------------------------------------------------------------------
1041   * DDIC-Tabellen/-Strukturen als Strukturen.
1042   TYPES:
1043     IMIS_TYPE_S_AUFKV      LIKE  AUFKV,
1044     IMIS_TYPE_S_AUFKV_REQ  LIKE  AUFKV_REQ.
1045
1046
1047   *-----------------------------------------------------------------------
1048   * DDIC-Tabellen/-Strukturen als Tabellen.
1049   TYPES:
1050     IMIS_TYPE_T_AUFKV  TYPE  IMIS_TYPE_S_AUFKV  OCCURS 100.
1051
1052
1053   *-----------------------------------------------------------------------
1054   * Auftragsnummer als Struktur und Tabelle.
1055   TYPES:
1056     BEGIN OF IMIS_TYPE_S_AUFNR,
1057       AUFNR  LIKE  AUFKV-AUFNR,
1058     END   OF IMIS_TYPE_S_AUFNR.
1059
1060   TYPES:
1061     IMIS_TYPE_T_AUFNR  TYPE  IMIS_TYPE_S_AUFNR  OCCURS 100.
1062
1063
1064
1065   ************************************************************************
1066   * Typen speziell für Projekte/PSP-Elemente
1067   * >PROJ
1068   ************************************************************************
1069
1070   *-----------------------------------------------------------------------
1071   * DDIC-Tabellen/-Strukturen als Strukturen.
1072   TYPES:
1073     IMIS_TYPE_S_PRPS      LIKE  PRPS,
1074     IMIS_TYPE_S_PRPS_REQ  LIKE  PRPS_REQ.
1075
1076
1077   *-----------------------------------------------------------------------
1078   * DDIC-Tabellen/-Strukturen als Tabellen.
1079   TYPES:
1080     IMIS_TYPE_T_PRPS  TYPE  IMIS_TYPE_S_PRPS  OCCURS 100.
1081
1082
1083   *-----------------------------------------------------------------------
1084   * PSP-Elementnummer als Struktur und Tabelle.
1085   TYPES:
1086     BEGIN OF IMIS_TYPE_S_PSPNR,
1087       PSPNR  LIKE  PRPS-PSPNR,
1088     END   OF IMIS_TYPE_S_PSPNR.
1089
1090   TYPES:
1091     IMIS_TYPE_T_PSPNR  TYPE  IMIS_TYPE_S_PSPNR  OCCURS  100.
1092
1093
1094   *-----------------------------------------------------------------------
1095   * PSP-POSID als Struktur und Tabelle.
1096   TYPES:
1097     BEGIN OF IMIS_TYPE_S_PS_POSID,
1098       POSID  LIKE  PRPS-POSID,
1099     END   OF IMIS_TYPE_S_PS_POSID.
1100
1101   TYPES:
1102     IMIS_TYPE_T_PS_POSID  TYPE  IMIS_TYPE_S_PS_POSID  OCCURS  100.
1103
1104
1105
1106   ************************************************************************
1107   * Typen speziell für Verdichtung Investitionsmanagement.
1108   * >COMPR
1109   ************************************************************************
1110
1111   *-----------------------------------------------------------------------
1112   * DDIC-Tabellen/-Strukturen als Strukturen.
1113   TYPES:
1114     IMIS_TYPE_S_IMCC       LIKE   IMCC  ,
1115     IMIS_TYPE_S_IMCKF      LIKE   IMCKF ,
1116     IMIS_TYPE_S_IMCH       LIKE   IMCH  ,
1117     IMIS_TYPE_S_IMCHIE     LIKE   IMCHIE,
1118     IMIS_TYPE_S_IMCEM      LIKE   IMCEM,
1119     IMIS_TYPE_S_IMCEPPT    LIKE   IMCEPPT,
1120     IMIS_TYPE_S_IMCER      LIKE   IMCER,
1121     IMIS_TYPE_S_RAICFILE   LIKE   RAICFILE,
1122     IMIS_TYPE_S_RICASP     LIKE   RICASP,
1123     IMIS_TYPE_S_RIMCHC     LIKE   RIMCHC,
1124     IMIS_TYPE_S_RIMCKC     LIKE   RIMCKC,
1125     IMIS_TYPE_S_RIMCMC     LIKE   RIMCMC,
1126     IMIS_TYPE_S_RIMCV      LIKE   RIMCV,
1127     IMIS_TYPE_S_TAIC2T     LIKE   TAIC2T.
1128
1129
1130   *-----------------------------------------------------------------------
1131   * DDIC-Tabellen/-Strukturen als Tabellen.
1132   TYPES:
1133     IMIS_TYPE_T_IMCC       TYPE   IMIS_TYPE_S_IMCC     OCCURS   50,
1134     IMIS_TYPE_T_IMCECC     LIKE   IMCECC               OCCURS   50,
1135     IMIS_TYPE_T_IMCECCT    LIKE   IMCECCT              OCCURS   50,
1136     IMIS_TYPE_T_IMCEFL     LIKE   IMCEFL               OCCURS   50,
1137     IMIS_TYPE_T_IMCEFLT    LIKE   IMCEFLT              OCCURS   50,
1138     IMIS_TYPE_T_IMCEM      TYPE   IMIS_TYPE_S_IMCEM    OCCURS   50,
1139     IMIS_TYPE_T_IMCEMT     LIKE   IMCEMT               OCCURS   50,
1140     IMIS_TYPE_T_IMCEP      LIKE   IMCEP                OCCURS   50,
1141     IMIS_TYPE_T_IMCEPT     LIKE   IMCEPT               OCCURS   50,
1142     IMIS_TYPE_T_IMCEPC     LIKE   IMCEPC               OCCURS   50,
1143     IMIS_TYPE_T_IMCEPCT    LIKE   IMCEPCT              OCCURS   50,
1144     IMIS_TYPE_T_IMCEPPT    TYPE   IMIS_TYPE_S_IMCEPPT  OCCURS   50,
1145     IMIS_TYPE_T_IMCER      TYPE   IMIS_TYPE_S_IMCER    OCCURS   50,
1146     IMIS_TYPE_T_IMCERT     LIKE   IMCERT               OCCURS   50,
1147     IMIS_TYPE_T_IMCH       TYPE   IMIS_TYPE_S_IMCH     OCCURS    5,
1148     IMIS_TYPE_T_IMCHIE     TYPE   IMIS_TYPE_S_IMCHIE   OCCURS   50,
1149     IMIS_TYPE_T_IMCKF      LIKE   IMCKF                OCCURS  100,
1150     IMIS_TYPE_T_RICASP     TYPE   IMIS_TYPE_S_RICASP   OCCURS  100,
1151     IMIS_TYPE_T_RIMCHC     TYPE   IMIS_TYPE_S_RIMCHC   OCCURS    5,
1152     IMIS_TYPE_T_TAIC1      LIKE   TAIC1                OCCURS   10,
1153     IMIS_TYPE_T_TAIC2T     TYPE   IMIS_TYPE_S_TAIC2T   OCCURS   10.
1154
1155
1156   *-----------------------------------------------------------------------
1157   * Range-Struktur und Tabelle für Programmpositionen.
1158   TYPES:
1159     BEGIN OF IMIS_TYPE_S_POS_RANGE,
1160       SIGN(1)    TYPE  C,
1161       OPTION(2)  TYPE  C,
1162       LOW        LIKE  IMCHIE-PROG_POS,
1163       HIGH       LIKE  IMCHIE-PROG_POS,
1164     END   OF IMIS_TYPE_S_POS_RANGE.
1165
1166   TYPES:
1167     IMIS_TYPE_R_POS  TYPE  IMIS_TYPE_S_POS_RANGE  OCCURS 50.
1168
1169
1170   *-----------------------------------------------------------------------
1171   * Köpfe mit Aktionskennzeichen als Struktur und Hash-Tabelle.
1172   TYPES: BEGIN OF IMIS_TYPE_S_IMCH_ACT.
1173            INCLUDE  TYPE  IMIS_TYPE_S_IMCH.
1174   TYPES:   ACTION   TYPE  IMIS_TYPE_ACTION.
1175   TYPES: END   OF IMIS_TYPE_S_IMCH_ACT.
1176
1177   TYPES:
1178     IMIS_TYPE_TH_IMCH_ACT  TYPE  HASHED TABLE
1179                            OF    IMIS_TYPE_S_IMCH_ACT
1180                            WITH  UNIQUE KEY  COMPR_VRSN
1181                                              INV_PROG
1182                                              APPR_YEAR
1183                                              LOGSYSTEM
1184                            INITIAL SIZE 1.
1185
1186   *-----------------------------------------------------------------------
1187   * ALLE Merkmale mit Stammdatencharakter als Struktur.
1188   * (MDC = MasterData Characteristics)
1189   TYPES: BEGIN OF IMIS_TYPE_S_MDC.
1190            INCLUDE   TYPE  IMIS_TYPE_S_RIMCHC.
1191            INCLUDE   TYPE  IMIS_TYPE_S_RIMCMC.
1192   TYPES: END   OF IMIS_TYPE_S_MDC.
1193
1194
1195   *-----------------------------------------------------------------------
1196   * ALLE Merkmale mit Stammdatencharakter und Satznummer AM ENDE(!!!)
1197   * als Struktur und Tabelle.
1198   * (MDC_R =  MasterData Characteristics and Record number)
1199   TYPES: BEGIN OF IMIS_TYPE_S_MDC_R.
1200            INCLUDE   TYPE   IMIS_TYPE_S_MDC.
1201   TYPES:   RECNO     LIKE   IMCC-RECNO.
1202   TYPES: END   OF IMIS_TYPE_S_MDC_R.
1203
1204   TYPES:
1205     IMIS_TYPE_T_MDC_R  TYPE  IMIS_TYPE_S_MDC_R  OCCURS 100.
1206
1207
1208   *-----------------------------------------------------------------------
1209   * ALLE Merkmale als Struktur.
1210   TYPES: BEGIN OF IMIS_TYPE_S_ALL_CHARACT.
1211            INCLUDE   TYPE  IMIS_TYPE_S_MDC.
1212            INCLUDE   TYPE  IMIS_TYPE_S_RIMCKC.
1213   TYPES: END   OF IMIS_TYPE_S_ALL_CHARACT.
1214
1215
1216   *-----------------------------------------------------------------------
1217   * Bewegungdaten ohne Satznummer als Struktur und Tabelle.
1218   TYPES: BEGIN OF IMIS_TYPE_S_DATA.
1219            INCLUDE     TYPE  IMIS_TYPE_S_ALL_CHARACT.
1220            INCLUDE     TYPE  IMIS_TYPE_S_RIMCV.
1221   TYPES:   OWNSYS_FLG  LIKE       IMCC-OWNSYS_FLG.
1222   TYPES: END   OF IMIS_TYPE_S_DATA.
1223
1224   TYPES:
1225     IMIS_TYPE_T_DATA  TYPE  IMIS_TYPE_S_DATA  OCCURS 100.
1226
1227
1228   *-----------------------------------------------------------------------
1229   * Satznummer als Struktur und Tabelle.
1230   TYPES:
1231     BEGIN OF IMIS_TYPE_S_RECNO,
1232       RECNO    LIKE  IMCc-RECNO,
1233       prog_pos like  imcc-prog_pos,
1234     END   OF IMIS_TYPE_S_RECNO.
1235
1236   TYPES:
1237     IMIS_TYPE_T_RECNO  TYPE  IMIS_TYPE_S_RECNO  OCCURS 100.
1238
1239
1240   *-----------------------------------------------------------------------
1241   * Parameter für Selektion Bewegungsdaten als Struktur.
1242   TYPES:
1243     BEGIN OF IMIS_TYPE_S_SEL_PAR,
1244       COMPR_VRSN  LIKE  RIMCHC-COMPR_VRSN,
1245       S_VAL_SEL   TYPE  IMIS_TYPE_S_BAPI1057CA,
1246       PARTN_ROLE  LIKE  BAPI1057C0-PARTN_ROLE,
1247     END   OF IMIS_TYPE_S_SEL_PAR.
1248
1249   *-----------------------------------------------------------------------
1250   * Ein-/Ausgabedatei von PC als Struktur und Tabelle.
1251   TYPES: BEGIN OF IMIS_TYPE_S_RAW_DATA,
1252            LINE(1000) TYPE C,
1253          END   OF IMIS_TYPE_S_RAW_DATA.
1254
1255   TYPES: IMIS_TYPE_T_RAW_DATA TYPE IMIS_TYPE_S_RAW_DATA OCCURS 100.
1256
1257   *-----------------------------------------------------------------------
1258   * Verdichtungsversion als Struktur und Tabelle.
1259   TYPES:
1260     BEGIN OF IMIS_TYPE_S_COMPR_VRSN,
1261       COMPR_VRSN  LIKE  TAIC2-COMPR_VRSN,
1262     END   OF IMIS_TYPE_S_COMPR_VRSN.
1263
1264   TYPES:
1265     IMIS_TYPE_T_COMPR_VRSN  TYPE  IMIS_TYPE_S_COMPR_VRSN  OCCURS 3.
1266
1267
1268   *-----------------------------------------------------------------------
1269   * Interne Nummer Programmposition als Struktur und Tabelle.
1270   TYPES:
1271     BEGIN OF IMIS_TYPE_S_POSNO,
1272       POS_NO  LIKE  IMCHIE-POS_NO,
1273     END   OF IMIS_TYPE_S_POSNO.
1274
1275   TYPES:
1276     IMIS_TYPE_T_POSNO  TYPE  IMIS_TYPE_S_POSNO  OCCURS 100.
1277
1278
1279   *-----------------------------------------------------------------------
1280   * Programmpositions-ID mit Blatt-Kennzeichen als Struktur, Tabelle
1281   * und Hash-Tabelle.
1282   TYPES:
1283     BEGIN OF IMIS_TYPE_S_POS,
1284       PROG_POS  LIKE  IMCHIE-PROG_POS,
1285       FLG_LEAF  TYPE  IMIS_TYPE_FLG,
1286     END   OF IMIS_TYPE_S_POS.
1287
1288   TYPES:
1289     IMIS_TYPE_T_POS  TYPE  IMIS_TYPE_S_POS  OCCURS 100.
1290
1291   TYPES:
1292     IMIS_TYPE_TH_POS  TYPE  HASHED TABLE
1293                       OF    IMIS_TYPE_S_POS
1294                       WITH UNIQUE KEY  PROG_POS
1295                       INITIAL SIZE 100.
1296
1297
1298   *-----------------------------------------------------------------------
1299   * Anforderung in externer Darstellung mit Text als Struktur und Hash-
1300   * Tabelle.
1301   TYPES:
1302     BEGIN OF IMIS_TYPE_S_REQEXT_TXT,
1303       COMPANY  LIKE  IMCER-COMPANY,
1304       REQ_EXT  LIKE  IMCER-REQ_EXT,
1305       REQ_TXT  LIKE  IMCERT-REQ_TXT,
1306     END   OF IMIS_TYPE_S_REQEXT_TXT.
1307
1308   TYPES:
1309     IMIS_TYPE_TH_REQEXT_TXT  TYPE  HASHED TABLE
1310                              OF    IMIS_TYPE_S_REQEXT_TXT
1311                              WITH  UNIQUE KEY COMPANY
1312                                               REQ_EXT
1313                              INITIAL SIZE 50.
1314
1315
1316   *-----------------------------------------------------------------------
1317   * Anforderung in interner und externer Darstellung als Struktur und
1318   * Hash-Tabelle.
1319   TYPES:
1320     BEGIN OF IMIS_TYPE_S_REQ_INTEXT,
1321       COMPANY  LIKE  IMCER-COMPANY,
1322       REQUEST  LIKE  IMCER-REQUEST,
1323       REQ_EXT  LIKE  IMCER-REQ_EXT,
1324     END   OF IMIS_TYPE_S_REQ_INTEXT.
1325
1326   TYPES:
1327     IMIS_TYPE_TH_REQ_INTEXT  TYPE  HASHED TABLE
1328                              OF    IMIS_TYPE_S_REQ_INTEXT
1329                              WITH  UNIQUE KEY COMPANY
1330                                               REQUEST
1331                              INITIAL SIZE 50.
1332
1333
1334   *-----------------------------------------------------------------------
1335   * Maßnahme in externer Darstellung mit Text als Struktur und Hash-
1336   * Tabelle.
1337   TYPES:
1338     BEGIN OF IMIS_TYPE_S_MEASREXT_TXT,
1339       COMPANY    LIKE  IMCEM-COMPANY,
1340       MEASR_EXT  LIKE  IMCEM-MEASR_EXT,
1341       MEASR_TXT  LIKE  IMCEMT-MEASR_TXT,
1342     END   OF IMIS_TYPE_S_MEASREXT_TXT.
1343
1344   TYPES:
1345     IMIS_TYPE_TH_MEASREXT_TXT  TYPE  HASHED TABLE
1346                                OF    IMIS_TYPE_S_MEASREXT_TXT
1347                                WITH  UNIQUE KEY COMPANY
1348                                                 MEASR_EXT
1349                                INITIAL SIZE 50.
1350
1351
1352   *-----------------------------------------------------------------------
1353   * Maßnahme in interner und externer Darstellung als Struktur und
1354   * Hash-Tabelle.
1355   TYPES:
1356     BEGIN OF IMIS_TYPE_S_MEASR_INTEXT,
1357       COMPANY    LIKE  IMCEM-COMPANY,
1358       MEASURE    LIKE  IMCEM-MEASURE,
1359       MEASR_EXT  LIKE  IMCEM-MEASR_EXT,
1360     END   OF IMIS_TYPE_S_MEASR_INTEXT.
1361
1362   TYPES:
1363     IMIS_TYPE_TH_MEASR_INTEXT  TYPE  HASHED TABLE
1364                                OF    IMIS_TYPE_S_MEASR_INTEXT
1365                                WITH  UNIQUE KEY COMPANY
1366                                                 MEASURE
1367                                INITIAL SIZE 50.
1368
1369
1370   *-----------------------------------------------------------------------
1371   * Maßnahme mit Objektart und ID als Struktur.
1372   TYPES:
1373     BEGIN OF IMIS_TYPE_S_MEASR_DETAIL,
1374       OBART         LIKE  IONRA-OBART,
1375       MEASR_ID(24)  TYPE  C,
1376     END   OF  IMIS_TYPE_S_MEASR_DETAIL.
1377
1378
1379
1380   ************************************************************************
*--- End of %_CIMIS - 1380 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  <REPINI>                                  Level 1    Page 5
Object           ZAIMBNEW                                  Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:29
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
Generated incl.  <SYSINI>                                  Level 1    Page 6
Object           ZAIMBNEW                                  Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:29
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
Generated incl.  <SYSSEL>                                  Level 1    Page 7
Object           ZAIMBNEW                                  Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:29
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
Generated incl.  DBIMACOM                                  Level 1    Page 8
Object           ZAIMBNEW                                  Lines 19
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:29
----------------------------------------------------------------------------------------------------
1      *----------------------------------------------------------------------*
2      *   INCLUDE DBIMACOM                                                   *
3      *----------------------------------------------------------------------*
4      TYPE-POOLS: IM.
5      * Werttypen für die Obligos aus                            " n. 216098
6      * o  Mittelreservierung (2A) und                           " n. 216098
7      * o  Mittelvorbindung (2B)                                 " n. 216098
8      * aus dem Haushaltsmanagement                              " n. 216098
9      * (abgeschrieben aus LKAOITOP).                            " n. 216098
10     DATA: C_COSP_WRTTP_KRES   LIKE COSP-WRTTP  VALUE '2A',     " n. 216098
11           C_COSP_WRTTP_KPRE   LIKE COSP-WRTTP  VALUE '2B'.     " n. 216098
12     DATA: BEGIN OF COMMON PART DBIMACOM.
13     * DATA: AUTH_CHECK_BUDG(1) TYPE C,
14     *       AUTH_CHECK_PLAN(1) TYPE C,
15     *       AUTH_CHECK_IST(1)  TYPE C.
16       DATA: AUTHFLG TYPE IM_AUTHFLG_TYPE,
17             AUTHMSG TYPE IM_AUTHMSG_TYPE.
18       data: hierarchy_index type syindex.                      "n.151186
19     DATA: END   OF COMMON PART.
*--- End of DBIMACOM - 19 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  DBIMASEL                                  Level 1    Page 9
Object           ZAIMBNEW                                  Lines 248
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:29
----------------------------------------------------------------------------------------------------
1      *--------------------------------------------------------------------*
2      * INCLUDE DBIMASEL
3      * It will be automatically included into the database program.
4      *--------------------------------------------------------------------*
5      *
6      * If the source code is automatically generated,
7      * please perform the following steps:
8      * 1. Replace ? by suitable names (at most 8 characters).
9      * 2. Activate SELECT-OPTIONS and PARAMTERS (delete stars).
10     * 3. Save source code.
11     * 4. Edit database program
12     *
13     * Hint: Syntax-Check is not possible within this Include!
14     * It will be checked during syntax-check of database program.
15     *
16     *--------------------------------------------------------------------*
17
18     SELECTION-SCREEN BEGIN OF BLOCK IPR.
19     * Felder zum Investitionsprogramm blocken fuer PAI-Verarbeitung
20     PARAMETERS:
21     *                Programmname
22                      PA_PRNAM LIKE IMPR-PRNAM
23                               OBLIGATORY
24                               MEMORY ID IMT
25                               VALUE-REQUEST
26                               FOR TABLE STREENODE,
27     *                Position von
28                      PA_POSID LIKE IMPR-POSID
29                               MEMORY ID IMP
30                               VALUE-REQUEST
31                               FOR TABLE STREENODE,
32     *                Genehmigungsjahr
33                      PA_GJAHR LIKE IMPR-GJAHR
34                               OBLIGATORY
35                               MEMORY ID GJR
36                               FOR TABLE STREENODE.
37     SELECTION-SCREEN END   OF BLOCK IPR.
38
39     SELECTION-SCREEN          SKIP  1
40                               FOR TABLE STREENODE.
41     SELECTION-SCREEN          BEGIN OF BLOCK PRM
42                               WITH     FRAME
43                               TITLE    TEXT-T02.
44       SELECTION-SCREEN        BEGIN OF LINE.
45         PARAMETER:            PA_POSRM LIKE RAIP1-POSRQMS
46                               FOR TABLE STREENODE
47                               DEFAULT 'X'
48                               RADIOBUTTON GROUP PRM.
49         SELECTION-SCREEN      COMMENT 3(60) TEXT-P08
50                               FOR FIELD PA_POSRM.
51       SELECTION-SCREEN        END   OF LINE.
52       SELECTION-SCREEN        BEGIN OF LINE.
53         PARAMETER:            PA_POSRQ LIKE RAIP1-POSRQ
54                               FOR TABLE STREENODE
55                               RADIOBUTTON GROUP PRM.
56         SELECTION-SCREEN      COMMENT 3(60) TEXT-P09
57                               FOR FIELD PA_POSRQ.
58       SELECTION-SCREEN        END   OF LINE.
59       SELECTION-SCREEN        BEGIN OF LINE.
60         PARAMETER:            PA_POSIT LIKE RAIP1-POSIT
61                               FOR TABLE STREENODE
62                               RADIOBUTTON GROUP PRM.
63         SELECTION-SCREEN      COMMENT 3(60) TEXT-P10
64                               FOR FIELD PA_POSIT.
65       SELECTION-SCREEN        END   OF LINE.
66     SELECTION-SCREEN          END   OF BLOCK PRM.
67     SELECTION-SCREEN          BEGIN OF BLOCK INV
68                               WITH     FRAME
69                               TITLE    TEXT-T01.
70       SELECTION-SCREEN      BEGIN OF BLOCK JHR.
71     *   Block JHR
72       SELECTION-SCREEN        BEGIN OF LINE.
73         PARAMETER:            PA_OLDMS LIKE RAIP1-OLDMEAS
74                               FOR TABLE STREENODE.
75         SELECTION-SCREEN      COMMENT 3(30) TEXT-P02
76                               FOR FIELD PA_OLDMS.
77         SELECTION-SCREEN      POSITION 35
78                               FOR TABLE STREENODE.
79         PARAMETER:            PA_GESWT LIKE RAIP1-GESWT
80                               FOR TABLE STREENODE DEFAULT 'X'
81                               RADIOBUTTON GROUP WRT.
82         SELECTION-SCREEN      COMMENT 37(30) TEXT-P03
83                               FOR FIELD PA_GESWT.
84       SELECTION-SCREEN        END   OF LINE.
85       SELECTION-SCREEN        BEGIN OF LINE.
86         PARAMETER:            PA_FUTMS LIKE RAIP1-FUTMEAS
87                               FOR TABLE STREENODE.
88         SELECTION-SCREEN      COMMENT 3(30) TEXT-P07
89                               FOR FIELD PA_FUTMS.
90         SELECTION-SCREEN      POSITION 35
91                               FOR TABLE STREENODE.
92         PARAMETER:            PA_JHRWT LIKE RAIP1-JHRWT
93                               FOR TABLE STREENODE
94                               RADIOBUTTON GROUP WRT.
95         SELECTION-SCREEN      COMMENT 37(15) TEXT-P04
96                               FOR FIELD PA_JHRWT.
97         SELECTION-SCREEN      COMMENT 53(15) TEXT-P11
98                               FOR FIELD PA_JHR.
99         SELECTION-SCREEN      POSITION 69
100                              FOR TABLE STREENODE.
101        PARAMETER:            PA_JHR   LIKE BPJA-GJAHR
102                              FOR TABLE STREENODE.
103      SELECTION-SCREEN        END  OF LINE.
104      SELECTION-SCREEN      END   OF BLOCK JHR.
105      SELECTION-SCREEN        SKIP  1
106                              FOR TABLE STREENODE
107                              ID SK1.
108      PARAMETER:              PA_REPCU LIKE RAIP_DYNP-REPCUR
109                              FOR TABLE STREENODE.
110      PARAMETER:              PA_LGALL LIKE RAIP1-LGALL
111                              FOR TABLE STREENODE NO-DISPLAY.
112      SELECTION-SCREEN        BEGIN OF BLOCK ACT.
113      SELECTION-SCREEN        BEGIN OF LINE.
114      SELECTION-SCREEN        COMMENT 1(31) TEXT-P05
115                              FOR FIELD PA_ACTFY.
116      PARAMETERS:             PA_ACTFY LIKE RAIP3-ACTFY
117                              FOR TABLE STREENODE,
118                              PA_ACTFP LIKE RAIP3-ACTFP
119                              FOR TABLE STREENODE.
120      SELECTION-SCREEN        COMMENT 52(5) TEXT-P06
121                              FOR FIELD PA_ACTTY.
122      PARAMETERS:             PA_ACTTY LIKE RAIP3-ACTTY
123                              FOR TABLE STREENODE,
124                              PA_ACTTP LIKE RAIP3-ACTTP
125                              FOR TABLE STREENODE.
126      SELECTION-SCREEN        END OF LINE.
127      SELECTION-SCREEN        END   OF BLOCK ACT.
128      SELECT-OPTIONS:         SO_IPPOS FOR RIPASW-IPPOS.
129      PARAMETER:              PA_STSEL LIKE RAIP1-STATSEL    "statsel
130                              FOR TABLE STREENODE.           "statsel
131    * Allgemeine Parameter für Steuerung der Datenbeschaffung.
132      PARAMETER:              PA_WIST  LIKE RAIP1-XWIST
133                              FOR TABLE STREENODE NO-DISPLAY.
134      PARAMETER:              PA_RIST  LIKE RAIP1-XRIST
135                              FOR TABLE STREENODE NO-DISPLAY.
136      PARAMETER:              PA_WPLAN LIKE RAIP1-XWPLAN
137                              FOR TABLE STREENODE NO-DISPLAY.
138      PARAMETER:              PA_RPLAN LIKE RAIP1-XRPLAN
139                              FOR TABLE STREENODE NO-DISPLAY.
140      PARAMETER:              PA_WBUDG LIKE RAIP1-XWBUDG
141                              FOR TABLE STREENODE NO-DISPLAY.
142      PARAMETER:              PA_RBUDG LIKE RAIP1-XRBUDG
143                              FOR TABLE STREENODE NO-DISPLAY.
144      PARAMETER:              PA_WBREL LIKE RAIP1-XWBREL
145                              FOR TABLE STREENODE NO-DISPLAY.
146      PARAMETER:              PA_RBREL LIKE RAIP1-XRBREL
147                              FOR TABLE STREENODE NO-DISPLAY.
148      PARAMETER:              PA_WPROF LIKE RAIP1-XWPROF
149                              FOR TABLE STREENODE NO-DISPLAY.
150    * Spezielle Parameter nur für's EIS.
151      PARAMETER:              PA_ALLWT FOR TABLE STREENODE
152                              NO-DISPLAY.
153      PARAMETER:              PA_LEAFS FOR TABLE STREENODE
154                              NO-DISPLAY.
155      PARAMETER:              PA_SELSC FOR TABLE STREENODE
156                              NO-DISPLAY.
157      SELECT-OPTIONS:         SO_ALLGJ FOR IMTP-GJAHR
158                              NO-DISPLAY.
159      PARAMETER:              PA_VERSN LIKE RAIP3-VERSN
160                              DEFAULT '000'
161                              FOR TABLE STREENODE
162                              NO-DISPLAY.
163      PARAMETER:              PA_ALLVS FOR TABLE STREENODE
164                              NO-DISPLAY.
165      PARAMETER:              PA_VALTP LIKE RIPASW-VALUTYP
166                              DEFAULT '0'
167                              FOR TABLE STREENODE
168                              NO-DISPLAY.
169      PARAMETER:              PA_ALLVT FOR TABLE STREENODE
170                              NO-DISPLAY.
171      PARAMETER:              PA_MSTAT LIKE RAIP1-XMSTAT
172                              FOR TABLE STREENODE
173                              NO-DISPLAY.
174    SELECTION-SCREEN          END   OF BLOCK INV.
175    SELECTION-SCREEN          SKIP  1
176                              FOR TABLE STREENODE.
177
178    * Standardversion für's EIS.
179    SELECTION-SCREEN          BEGIN OF VERSION 100
180                              TEXT-V01.
181      SELECTION-SCREEN        EXCLUDE SELECT-OPTIONS:
182                              SO_IPPOS.
183      SELECTION-SCREEN        EXCLUDE IDS:                "statsel
184                              SK1.                        "statsel
185      SELECTION-SCREEN        EXCLUDE PARAMETERS:
186                              PA_POSIT,
187                              PA_POSRQ,
188                              PA_POSRM,
189                              PA_GESWT,
190                              PA_JHRWT,
191                              PA_OLDMS,
192                              PA_FUTMS,
193                              PA_JHR.
194    SELECTION-SCREEN          END   OF VERSION 100.
195
196
197    * Version für RAIMDOLD.
198    SELECTION-SCREEN          BEGIN OF VERSION 110
199                              TEXT-V03.
200      SELECTION-SCREEN        EXCLUDE SELECT-OPTIONS:
201                              SO_IPPOS.
202      SELECTION-SCREEN        EXCLUDE IDS:                "statsel
203                              SK1.                        "statsel
204      SELECTION-SCREEN        EXCLUDE PARAMETERS:
205                              PA_POSIT,
206                              PA_POSRQ,
207                              PA_POSRM,
208                              PA_STSEL,
209                              PA_GESWT,
210                              PA_JHRWT,
211                              PA_OLDMS,
212                              PA_FUTMS,
213                              PA_JHR.
214      SELECTION-SCREEN        EXCLUDE PARAMETERS:
215                              PA_ACTFY,
216                              PA_ACTFP,
217                              PA_ACTTY,
218                              PA_ACTTP.
219      SELECTION-SCREEN        EXCLUDE PARAMETERS:
220                              PA_REPCU.
221    SELECTION-SCREEN          END   OF VERSION 110.
222
223
224    * Version für RAIMHERCHK.
225    SELECTION-SCREEN          BEGIN OF VERSION 120
226                              TEXT-V04.
227      SELECTION-SCREEN        EXCLUDE SELECT-OPTIONS:
228                              SO_IPPOS.
229      SELECTION-SCREEN        EXCLUDE IDS:
230                              SK1.
231      SELECTION-SCREEN        EXCLUDE PARAMETERS:
232                              PA_POSIT,
233                              PA_POSRQ,
234                              PA_POSRM,
235                              PA_STSEL,
236                              PA_GESWT,
237                              PA_JHRWT,
238                              PA_OLDMS,
239                              PA_FUTMS,
240                              PA_JHR.
241      SELECTION-SCREEN        EXCLUDE PARAMETERS:
242                              PA_ACTFY,
243                              PA_ACTFP,
244                              PA_ACTTY,
245                              PA_ACTTP.
246      SELECTION-SCREEN        EXCLUDE PARAMETERS:
247                              PA_REPCU.
248    SELECTION-SCREEN          END   OF VERSION 120.
*--- End of DBIMASEL - 248 lines ---
