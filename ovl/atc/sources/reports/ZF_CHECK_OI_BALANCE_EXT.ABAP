----------------------------------------------------------------------------------------------------
Main program     ZF_CHECK_OI_BALANCE_EXT                   Level 0    Page 1
Object           ZF_CHECK_OI_BALANCE_EXT                   Lines 1226
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:54
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *& Report  ZF_CHECK_OI_BALANCE_EXT
3      *&
4      *&---------------------------------------------------------------------*
5      *&
6      *&
7      *&---------------------------------------------------------------------*
8
9      *REPORT  ZF_CHECK_OI_BALANCE_EXT.
10     *&---------------------------------------------------------------------*
11     *& Report  ZF_CHECK_OI_BALANCE_EXT
12     *&
13     *&---------------------------------------------------------------------*
14     *& GLT0: cumulated balances via
15     *& G_TOTALS_SELECT_WITH_CURRENCY
16     *& Change Log : ZF_CHECK_OI_BALANCE with extended collect amount fields to
17     *& avoid dump in collect !!
18     *&---------------------------------------------------------------------*
19
20     REPORT  zf_check_oi_balance_ext LINE-SIZE 150 NO STANDARD PAGE HEADING.
21
22     TYPES: BEGIN OF coll,
23            bukrs         TYPE bseg-bukrs,
24            koart         TYPE bseg-koart,
25            hkont         TYPE bseg-hkont,
26            gsber         TYPE bseg-gsber,
27            pswsl         TYPE bseg-pswsl,
28            dmbtr         TYPE glt0-HSLVT, " Sushil
29            dmbe2         TYPE glt0-KSLVT, " Sushil
30            dmbe3         TYPE glt0-KSLVT, " Sushil
31            pswbt         TYPE glt0-TSLVT, " Sushil
32            hsl           TYPE glu1-hsl,
33            ksl           TYPE glu1-ksl,
34            osl           TYPE glu1-osl,
35            tsl           TYPE glu1-tsl,
36            d_dmbtr       TYPE bseg-dmbtr,
37            d_dmbe2       TYPE bseg-dmbe2,
38            d_dmbe3       TYPE bseg-dmbe3,
39            d_pswbt       TYPE bseg-pswbt,
40            cnt           TYPE i,
41            xsalh         TYPE skb1-xsalh,
42            END OF coll.
43
44     DATA: it_coll TYPE TABLE OF coll WITH HEADER LINE,
45           it_corr TYPE SORTED TABLE OF coll WITH HEADER LINE
46           WITH UNIQUE KEY bukrs koart hkont gsber pswsl.
47
48     TYPES: BEGIN OF sum1,
49            bukrs   TYPE bseg-bukrs,
50            koart   TYPE bseg-koart,
51            hkont   TYPE bseg-hkont,
52            pswsl   TYPE bseg-pswsl,
53            d_dmbtr TYPE bseg-dmbtr,
54            d_dmbe2 TYPE bseg-dmbe2,
55            d_dmbe3 TYPE bseg-dmbe3,
56            d_pswbt TYPE bseg-pswbt,
57            END OF sum1.
58     DATA: it_sum1 TYPE TABLE OF sum1 WITH HEADER LINE.
59
60     TYPES: BEGIN OF sum2,
61            bukrs   TYPE bseg-bukrs,
62            koart   TYPE bseg-koart,
63            hkont   TYPE bseg-hkont,
64            gsber   TYPE bseg-gsber,
65            d_dmbtr TYPE bseg-dmbtr,
66            d_dmbe2 TYPE bseg-dmbe2,
67            d_dmbe3 TYPE bseg-dmbe3,
68            END OF sum2.
69     DATA: it_sum2 TYPE TABLE OF sum2 WITH HEADER LINE.
70
71     TYPES: BEGIN OF sum3,
72            bukrs   TYPE bseg-bukrs,
73            koart   TYPE bseg-koart,
74            hkont   TYPE bseg-hkont,
75            d_dmbtr TYPE bseg-dmbtr,
76            d_dmbe2 TYPE bseg-dmbe2,
77            d_dmbe3 TYPE bseg-dmbe3,
78            END OF sum3.
79     DATA: it_sum3 TYPE TABLE OF sum3 WITH HEADER LINE.
80
81     TYPES: BEGIN OF gltab,
82            rldnr    TYPE glt0-rldnr,
83            curr(1)  TYPE c,
84            curtp    TYPE t001a-curtp,
85            curt1    TYPE curt_hsl,
86            curt2    TYPE curt_ksl,
87            curt3    TYPE curt_osl,
88            fg_curt1 TYPE fg_curt,
89            fg_curt2 TYPE fg_curt,
90            fg_curt3 TYPE fg_curt,
91            END OF gltab.
92     DATA: it_ldglt0 TYPE SORTED TABLE OF gltab WITH HEADER LINE
93           WITH UNIQUE KEY rldnr curr.
94
95     TYPES: BEGIN OF skb1_change,
96            bukrs TYPE skb1-bukrs,
97            hkont TYPE skb1-saknr,
98            xsalh TYPE skb1-xsalh,
99            xloeb TYPE skb1-xloeb,
100           xspeb TYPE skb1-xspeb,
101           END OF skb1_change.
102    DATA: it_skb1_change TYPE TABLE OF skb1_change WITH HEADER LINE.
103
104    TYPES: BEGIN OF ska1_change,
105           ktopl TYPE ska1-ktopl,
106           hkont TYPE ska1-saknr,
107           xloev TYPE ska1-xloev,
108           xspeb TYPE ska1-xspeb,
109           END OF ska1_change.
110    DATA: it_ska1_change TYPE TABLE OF ska1_change WITH HEADER LINE,
111          wa_ska1 TYPE ska1.
112
113    DATA: it_org_info LIKE glx_org_info OCCURS 0 WITH HEADER LINE.
114
115    TYPES: BEGIN OF xskb1.
116            INCLUDE STRUCTURE skb1.
117    TYPES: mult_umskz(1) TYPE c,
118           umskz(1) TYPE c,
119           END OF xskb1.
120    DATA: it_skb1 TYPE TABLE OF xskb1 WITH HEADER LINE,
121          it_skb1_corr TYPE TABLE OF xskb1 WITH HEADER LINE.
122
123    DATA: it_ledtab TYPE TABLE OF gledtab WITH HEADER LINE,
124          wa_t001a TYPE t001a,
125          wa_t001 TYPE t001,
126          wa_bsas TYPE bsas,
127          wa_bsad TYPE bsad,
128          wa_bsak TYPE bsak,
129          cnt TYPE p,
130          head(1) TYPE c,
131          wa_koart TYPE bseg-koart.
132
133    DATA: x_gjahr TYPE bkpf-gjahr,
134          x_monat TYPE bkpf-monat.
135
136    DATA: key_date TYPE bkpf-budat,
137          wa_fday  TYPE budat.
138
139    *** RFDT_KEY for data export of IT_CORR to RFDT
140    DATA: exp_key(22) TYPE c.
141    DATA: BEGIN OF rfdt_key,
142          key1(7) TYPE c,
143          date    LIKE sy-datlo,
144          time    LIKE sy-timlo,
145          END OF rfdt_key.
146
147    SELECTION-SCREEN BEGIN OF BLOCK 001 WITH FRAME.
148    PARAMETERS: p_bukrs  TYPE bsas-bukrs OBLIGATORY,
149                p_year TYPE bsas-gjahr OBLIGATORY DEFAULT '2009'.
150    SELECTION-SCREEN SKIP.
151    PARAMETERS: koart_s RADIOBUTTON GROUP inc DEFAULT 'X',
152                koart_d RADIOBUTTON GROUP inc,
153                koart_k RADIOBUTTON GROUP inc.
154    SELECTION-SCREEN SKIP.
155    PARAMETERS: c_single AS CHECKBOX,
156                p_hkont TYPE bsis-hkont.
157    PARAMETERS: wr_rfdt AS CHECKBOX.
158    SELECTION-SCREEN END OF BLOCK 001.
159
160    START-OF-SELECTION.
161
162    *** get company code master data
163      SELECT SINGLE * FROM t001 INTO wa_t001
164        WHERE bukrs = p_bukrs.
165
166    *** determine key date for reconsiliation
167      PERFORM set_keydate.
168    *** get GLT0 ledgers
169      PERFORM get_ledgers.
170      PERFORM output_ledgers.
171    *** select G/L master data
172      PERFORM select_skb1.
173    *** process reconsiliation
174      IF koart_s EQ 'X'.
175        PERFORM collect_s.
176      ELSEIF koart_d EQ 'X'.
177        PERFORM collect_d.
178      ELSEIF koart_k EQ 'X'.
179        PERFORM collect_k.
180      ENDIF.
181    *** output results
182      IF cnt = 0.
183        WRITE:/ 'No differences found' COLOR 3.
184      ELSE.
185        PERFORM output.
186      ENDIF.
187
188    TOP-OF-PAGE.
189      PERFORM top.
190
191    *&---------------------------------------------------------------------*
192    *&      Form  COLLECT_S
193    *&---------------------------------------------------------------------*
194    *       text
195    *----------------------------------------------------------------------*
196    *  -->  p1        text
197    *  <--  p2        text
198    *----------------------------------------------------------------------*
199    FORM collect_s .
200      DATA: save_index TYPE sy-tabix.
201    *** set KOART for GLT0 collect
202      wa_koart = 'S'.
203
204      LOOP AT it_skb1.
205    *** BSIS
206        SELECT * FROM bsis INTO wa_bsas
207          WHERE bukrs EQ p_bukrs
208            AND hkont EQ it_skb1-saknr
209            AND budat LE key_date
210            AND bstat EQ space.
211          IF wa_bsas-shkzg = 'H'.
212            wa_bsas-dmbtr = wa_bsas-dmbtr * -1.
213            wa_bsas-dmbe2 = wa_bsas-dmbe2 * -1.
214            wa_bsas-dmbe3 = wa_bsas-dmbe3 * -1.
215            wa_bsas-pswbt = wa_bsas-pswbt * -1.
216          ENDIF.
217          CLEAR it_coll.
218          MOVE-CORRESPONDING wa_bsas TO it_coll.
219          it_coll-koart = 'S'.
220          COLLECT it_coll.
221        ENDSELECT.
222    *** BSAS
223        SELECT * FROM bsas INTO wa_bsas
224          WHERE bukrs EQ p_bukrs
225            AND hkont EQ it_skb1-saknr
226            AND augdt GT key_date
227            AND budat LE key_date
228            AND bstat EQ space.
229          IF wa_bsas-shkzg = 'H'.
230            wa_bsas-dmbtr = wa_bsas-dmbtr * -1.
231            wa_bsas-dmbe2 = wa_bsas-dmbe2 * -1.
232            wa_bsas-dmbe3 = wa_bsas-dmbe3 * -1.
233            wa_bsas-pswbt = wa_bsas-pswbt * -1.
234          ENDIF.
235          CLEAR it_coll.
236          MOVE-CORRESPONDING wa_bsas TO it_coll.
237          it_coll-koart = 'S'.
238          COLLECT it_coll.
239        ENDSELECT.
240    *** GLT0
241        PERFORM get_glt0.
242      ENDLOOP.
243    *** build-up DELTA
244      LOOP AT it_coll.
245        it_coll-d_pswbt = it_coll-tsl - it_coll-pswbt.
246        it_coll-d_dmbtr = it_coll-hsl - it_coll-dmbtr.
247        it_coll-d_dmbe2 = it_coll-ksl - it_coll-dmbe2.
248        it_coll-d_dmbe3 = it_coll-osl - it_coll-dmbe3.
249        MODIFY it_coll.
250      ENDLOOP.
251    *** error case: balance ne 0
252      CLEAR cnt.
253      LOOP AT it_coll
254        WHERE ( d_dmbtr NE 0 OR
255                d_dmbe2 NE 0 OR
256                d_dmbe3 NE 0 OR
257                d_pswbt NE 0 ).
258        ADD 1 TO cnt.
259        it_coll-cnt = cnt.
260    *** get XSALH
261        CLEAR it_skb1.
262        READ TABLE it_skb1 WITH KEY
263          saknr = it_coll-hkont.
264        it_coll-xsalh = it_skb1-xsalh.
265    *** write IT_CORR
266        INSERT it_coll INTO TABLE it_corr.
267    *** change XSALH if D_DMBTR ne D_PSWBT in case of XSALH = X
268        IF ( it_coll-xsalh = 'X' AND
269             it_coll-d_dmbtr NE it_coll-d_pswbt ).
270          CLEAR it_skb1_change.
271          MOVE-CORRESPONDING it_coll TO it_skb1_change.
272          COLLECT it_skb1_change.
273        ENDIF.
274    *** check XSPEB and XLOEB for G/L account in SKB1
275        IF it_skb1-xspeb = 'X' OR it_skb1-xloeb = 'X'.
276          READ TABLE it_skb1_change WITH KEY
277            bukrs = it_skb1-bukrs
278            hkont = it_skb1-saknr.
279          IF sy-subrc = 0.
280            save_index = sy-tabix.
281            it_skb1_change-xspeb = it_skb1-xspeb.
282            it_skb1_change-xloeb = it_skb1-xloeb.
283            MODIFY it_skb1_change INDEX save_index.
284          ELSE.
285            CLEAR it_skb1_change.
286            it_skb1_change-hkont = it_skb1-saknr.
287            MOVE-CORRESPONDING it_skb1 TO it_skb1_change.
288            APPEND it_skb1_change.
289          ENDIF.
290        ENDIF.
291    *** check XLOEV and XSPEB for G/L account in SKA1
292        CLEAR wa_ska1.
293    " " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
294        SELECT SINGLE * FROM ska1 INTO wa_ska1
295          WHERE ktopl = wa_t001-ktopl
296            AND saknr = it_coll-hkont.
297    " " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
298        IF wa_ska1-xloev = 'X' OR wa_ska1-xspeb = 'X'.
299          READ TABLE it_ska1_change WITH KEY
300            ktopl = wa_ska1-ktopl
301            hkont = wa_ska1-saknr.
302          IF sy-subrc NE 0.
303            CLEAR it_ska1_change.
304            it_ska1_change-hkont = wa_ska1-saknr.
305            MOVE-CORRESPONDING wa_ska1 TO it_ska1_change.
306            APPEND it_ska1_change.
307          ENDIF.
308        ENDIF.
309      ENDLOOP.
310    ENDFORM.                    " COLLECT_S
311    *&---------------------------------------------------------------------*
312    *&      Form  COLLECT_D
313    *&---------------------------------------------------------------------*
314    *       text
315    *----------------------------------------------------------------------*
316    *  -->  p1        text
317    *  <--  p2        text
318    *----------------------------------------------------------------------*
319    FORM collect_d .
320      DATA: save_index TYPE sy-tabix.
321    *** set KOART for GLT0 collect
322      wa_koart = 'D'.
323    *** BSID
324      SELECT * FROM bsid INTO wa_bsad
325        WHERE bukrs EQ p_bukrs
326          AND budat LE key_date
327          AND bstat EQ space.
328        IF wa_bsad-shkzg = 'H'.
329          wa_bsad-dmbtr = wa_bsad-dmbtr * -1.
330          wa_bsad-dmbe2 = wa_bsad-dmbe2 * -1.
331          wa_bsad-dmbe3 = wa_bsad-dmbe3 * -1.
332          wa_bsad-pswbt = wa_bsad-pswbt * -1.
333        ENDIF.
334        CLEAR it_coll.
335        MOVE-CORRESPONDING wa_bsad TO it_coll.
336        it_coll-koart = 'D'.
337        COLLECT it_coll.
338      ENDSELECT.
339    *** BSAD
340      SELECT * FROM bsad INTO wa_bsad
341        WHERE bukrs EQ p_bukrs
342          AND augdt GT key_date
343          AND budat LE key_date
344          AND bstat EQ space.
345        IF wa_bsad-shkzg = 'H'.
346          wa_bsad-dmbtr = wa_bsad-dmbtr * -1.
347          wa_bsad-dmbe2 = wa_bsad-dmbe2 * -1.
348          wa_bsad-dmbe3 = wa_bsad-dmbe3 * -1.
349          wa_bsad-pswbt = wa_bsad-pswbt * -1.
350        ENDIF.
351        CLEAR it_coll.
352        MOVE-CORRESPONDING wa_bsad TO it_coll.
353        it_coll-koart = 'D'.
354        COLLECT it_coll.
355      ENDSELECT.
356    *** get GLT0 balance
357      LOOP AT it_skb1.
358        PERFORM get_glt0.
359      ENDLOOP.
360    *** build-up DELTA
361      LOOP AT it_coll.
362        it_coll-d_pswbt = it_coll-tsl - it_coll-pswbt.
363        it_coll-d_dmbtr = it_coll-hsl - it_coll-dmbtr.
364        it_coll-d_dmbe2 = it_coll-ksl - it_coll-dmbe2.
365        it_coll-d_dmbe3 = it_coll-osl - it_coll-dmbe3.
366        MODIFY it_coll.
367      ENDLOOP.
368    *** error case: balance ne 0
369      CLEAR cnt.
370      LOOP AT it_coll
371        WHERE ( d_dmbtr NE 0 OR
372                d_dmbe2 NE 0 OR
373                d_dmbe3 NE 0 OR
374                d_pswbt NE 0 ).
375        ADD 1 TO cnt.
376        it_coll-cnt = cnt.
377        INSERT it_coll INTO TABLE it_corr.
378        READ TABLE it_skb1 WITH KEY
379          bukrs = it_coll-bukrs
380          saknr = it_coll-hkont.
381    *** check XSPEB and XLOEB for G/L account
382        IF it_skb1-xspeb = 'X' OR it_skb1-xloeb = 'X'.
383          READ TABLE it_skb1_change WITH KEY
384            bukrs = it_skb1-bukrs
385            hkont = it_skb1-saknr.
386          IF sy-subrc NE 0.
387            CLEAR it_skb1_change.
388            it_skb1_change-hkont = it_skb1-saknr.
389            MOVE-CORRESPONDING it_skb1 TO it_skb1_change.
390            APPEND it_skb1_change.
391          ENDIF.
392        ENDIF.
393    *** check XLOEV and XSPEB for G/L account in SKA1
394        CLEAR wa_ska1.
395    " " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
396        SELECT SINGLE * FROM ska1 INTO wa_ska1
397          WHERE ktopl = wa_t001-ktopl
398            AND saknr = it_coll-hkont.
399    " " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
400        IF wa_ska1-xloev = 'X' OR wa_ska1-xspeb = 'X'.
401          READ TABLE it_ska1_change WITH KEY
402            ktopl = wa_ska1-ktopl
403            hkont = wa_ska1-saknr.
404          IF sy-subrc NE 0.
405            CLEAR it_ska1_change.
406            it_ska1_change-hkont = wa_ska1-saknr.
407            MOVE-CORRESPONDING wa_ska1 TO it_ska1_change.
408            APPEND it_ska1_change.
409          ENDIF.
410        ENDIF.
411      ENDLOOP.
412    ENDFORM.                    " COLLECT_D
413    *&---------------------------------------------------------------------*
414    *&      Form  COLLECT_K
415    *&---------------------------------------------------------------------*
416    *       text
417    *----------------------------------------------------------------------*
418    *  -->  p1        text
419    *  <--  p2        text
420    *----------------------------------------------------------------------*
421    FORM collect_k .
422      DATA: save_index TYPE sy-tabix.
423    *** set KOART for GLT0 collect
424      wa_koart = 'K'.
425    *** BSIK
426      SELECT * FROM bsik INTO wa_bsak
427        WHERE bukrs EQ p_bukrs
428          AND budat LE key_date
429          AND bstat EQ space.
430        IF wa_bsak-shkzg = 'H'.
431          wa_bsak-dmbtr = wa_bsak-dmbtr * -1.
432          wa_bsak-dmbe2 = wa_bsak-dmbe2 * -1.
433          wa_bsak-dmbe3 = wa_bsak-dmbe3 * -1.
434          wa_bsak-pswbt = wa_bsak-pswbt * -1.
435        ENDIF.
436        CLEAR it_coll.
437        MOVE-CORRESPONDING wa_bsak TO it_coll.
438        it_coll-koart = 'K'.
439        COLLECT it_coll.
440      ENDSELECT.
441    *** BSAK
442      SELECT * FROM bsak INTO wa_bsak
443        WHERE bukrs EQ p_bukrs
444          AND augdt GT key_date
445          AND budat LE key_date
446          AND bstat EQ space.
447        IF wa_bsak-shkzg = 'H'.
448          wa_bsak-dmbtr = wa_bsak-dmbtr * -1.
449          wa_bsak-dmbe2 = wa_bsak-dmbe2 * -1.
450          wa_bsak-dmbe3 = wa_bsak-dmbe3 * -1.
451          wa_bsak-pswbt = wa_bsak-pswbt * -1.
452        ENDIF.
453        CLEAR it_coll.
454        MOVE-CORRESPONDING wa_bsak TO it_coll.
455        it_coll-koart = 'K'.
456        COLLECT it_coll.
457      ENDSELECT.
458    *** get GLT0
459      LOOP AT it_skb1.
460        PERFORM get_glt0.
461      ENDLOOP.
462    *** build-up DELTA
463      LOOP AT it_coll.
464        it_coll-d_pswbt = it_coll-tsl - it_coll-pswbt.
465        it_coll-d_dmbtr = it_coll-hsl - it_coll-dmbtr.
466        it_coll-d_dmbe2 = it_coll-ksl - it_coll-dmbe2.
467        it_coll-d_dmbe3 = it_coll-osl - it_coll-dmbe3.
468        MODIFY it_coll.
469      ENDLOOP.
470    *** error case: balance ne 0
471      CLEAR cnt.
472      LOOP AT it_coll
473        WHERE ( d_dmbtr NE 0 OR
474                d_dmbe2 NE 0 OR
475                d_dmbe3 NE 0 OR
476                d_pswbt NE 0 ).
477        ADD 1 TO cnt.
478        it_coll-cnt = cnt.
479        INSERT it_coll INTO TABLE it_corr.
480        READ TABLE it_skb1 WITH KEY
481          bukrs = it_coll-bukrs
482          saknr = it_coll-hkont.
483    *** check XSPEB and XLOEB for G/L account
484        IF it_skb1-xspeb = 'X' OR it_skb1-xloeb = 'X'.
485          READ TABLE it_skb1_change WITH KEY
486            bukrs = it_skb1-bukrs
487            hkont = it_skb1-saknr.
488          IF sy-subrc NE 0.
489            CLEAR it_skb1_change.
490            it_skb1_change-hkont = it_skb1-saknr.
491            MOVE-CORRESPONDING it_skb1 TO it_skb1_change.
492            APPEND it_skb1_change.
493          ENDIF.
494        ENDIF.
495    *** check XLOEV and XSPEB for G/L account in SKA1
496        CLEAR wa_ska1.
497    " " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
498        SELECT SINGLE * FROM ska1 INTO wa_ska1
499          WHERE ktopl = wa_t001-ktopl
500            AND saknr = it_coll-hkont.
501    " " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
502        IF wa_ska1-xloev = 'X' OR wa_ska1-xspeb = 'X'.
503          READ TABLE it_ska1_change WITH KEY
504            ktopl = wa_ska1-ktopl
505            hkont = wa_ska1-saknr.
506          IF sy-subrc NE 0.
507            CLEAR it_ska1_change.
508            it_ska1_change-hkont = wa_ska1-saknr.
509            MOVE-CORRESPONDING wa_ska1 TO it_ska1_change.
510            APPEND it_ska1_change.
511          ENDIF.
512        ENDIF.
513      ENDLOOP.
514    ENDFORM.                    " COLLECT_K
515    *&---------------------------------------------------------------------*
516    *&      Form  OUTPUT
517    *&---------------------------------------------------------------------*
518    *       text
519    *----------------------------------------------------------------------*
520    *  -->  p1        text
521    *  <--  p2        text
522    *----------------------------------------------------------------------*
523    FORM output .
524      NEW-PAGE.
525      head = 'C'.
526      LOOP AT it_corr.
527        FORMAT COLOR 2 INTENSIFIED OFF.
528        WRITE:/ sy-vline NO-GAP,
529            (5) it_corr-bukrs,
530            (5) it_corr-koart,
531           (10) it_corr-hkont,
532            (5) it_corr-gsber,
533            (5) it_corr-pswsl,
534    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 10.06.2026  for ATC
535    *        (15) it_corr-d_dmbtr,
536           (15) it_corr-d_dmbtr, "#EC CI_FLDEXT_OK[2610650]
537    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 10.06.2026 for ATC
538    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 10.06.2026  for ATC
539    *        (15) it_corr-d_dmbe2,
540           (15) it_corr-d_dmbe2, "#EC CI_FLDEXT_OK[2610650]
541    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 10.06.2026 for ATC
542    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 10.06.2026  for ATC
543    *        (15) it_corr-d_dmbe3,
544           (15) it_corr-d_dmbe3, "#EC CI_FLDEXT_OK[2610650]
545    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 10.06.2026 for ATC
546    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 10.06.2026  for ATC
547    *        (15) it_corr-d_pswbt,
548           (15) it_corr-d_pswbt, "#EC CI_FLDEXT_OK[2610650]
549    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 10.06.2026 for ATC
550           (10) it_corr-cnt,
551            130 sy-vline NO-GAP.
552      ENDLOOP.
553      NEW-LINE.
554      ULINE (130).
555    *** summarization level 1: eliminate GSBER
556      NEW-PAGE.
557      head = '1'.
558      LOOP AT it_corr.
559        CLEAR it_sum1.
560        MOVE-CORRESPONDING it_corr TO it_sum1.
561        COLLECT it_sum1.
562      ENDLOOP.
563      LOOP AT it_sum1.
564        FORMAT COLOR 2 INTENSIFIED OFF.
565        WRITE:/ sy-vline NO-GAP,
566            (5) it_sum1-bukrs,
567            (5) it_sum1-koart,
568           (10) it_sum1-hkont,
569            (5) '*****',
570            (5) it_sum1-pswsl,
571    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 10.06.2026  for ATC
572    *        (15) it_sum1-d_dmbtr,
573           (15) it_sum1-d_dmbtr, "#EC CI_FLDEXT_OK[2610650]
574    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 10.06.2026 for ATC
575    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 10.06.2026  for ATC
576    *        (15) it_sum1-d_dmbe2,
577           (15) it_sum1-d_dmbe2, "#EC CI_FLDEXT_OK[2610650]
578    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 10.06.2026 for ATC
579    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 10.06.2026  for ATC
580    *        (15) it_sum1-d_dmbe3,
581           (15) it_sum1-d_dmbe3, "#EC CI_FLDEXT_OK[2610650]
582    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 10.06.2026 for ATC
583    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 10.06.2026  for ATC
584    *        (15) it_sum1-d_pswbt,
585           (15) it_sum1-d_pswbt, "#EC CI_FLDEXT_OK[2610650]
586    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 10.06.2026 for ATC
587            130 sy-vline NO-GAP.
588      ENDLOOP.
589      NEW-LINE.
590      ULINE (130).
591    *** summarization level 2: eliminate PSWSL
592      NEW-PAGE.
593      head = '2'.
594      LOOP AT it_corr.
595        CLEAR it_sum2.
596        MOVE-CORRESPONDING it_corr TO it_sum2.
597        COLLECT it_sum2.
598      ENDLOOP.
599      LOOP AT it_sum2.
600        FORMAT COLOR 2 INTENSIFIED OFF.
601        WRITE:/ sy-vline NO-GAP,
602            (5) it_sum2-bukrs,
603            (5) it_sum2-koart,
604           (10) it_sum2-hkont,
605            (5) it_sum2-gsber,
606            (5) '*****',
607    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 10.06.2026  for ATC
608    *        (15) it_sum2-d_dmbtr,
609           (15) it_sum2-d_dmbtr, "#EC CI_FLDEXT_OK[2610650]
610    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 10.06.2026 for ATC
611    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 10.06.2026  for ATC
612    *        (15) it_sum2-d_dmbe2,
613           (15) it_sum2-d_dmbe2, "#EC CI_FLDEXT_OK[2610650]
614    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 10.06.2026 for ATC
615    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 10.06.2026  for ATC
616    *        (15) it_sum2-d_dmbe3,
617           (15) it_sum2-d_dmbe3, "#EC CI_FLDEXT_OK[2610650]
618    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 10.06.2026 for ATC
619           (15) '***************',
620            130 sy-vline NO-GAP.
621      ENDLOOP.
622      NEW-LINE.
623      ULINE (130).
624    *** summarization level 3: eliminate GSBER and PSWSL
625      NEW-PAGE.
626      head = '3'.
627      LOOP AT it_corr.
628        CLEAR it_sum3.
629        MOVE-CORRESPONDING it_corr TO it_sum3.
630        COLLECT it_sum3.
631      ENDLOOP.
632      LOOP AT it_sum3.
633        FORMAT COLOR 2 INTENSIFIED OFF.
634        WRITE:/ sy-vline NO-GAP,
635            (5) it_sum3-bukrs,
636            (5) it_sum3-koart,
637           (10) it_sum3-hkont,
638            (5) '*****',
639            (5) '*****',
640    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 10.06.2026  for ATC
641    *        (15) it_sum3-d_dmbtr,
642           (15) it_sum3-d_dmbtr, "#EC CI_FLDEXT_OK[2610650]
643    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 10.06.2026 for ATC
644    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 10.06.2026  for ATC
645    *        (15) it_sum3-d_dmbe2,
646           (15) it_sum3-d_dmbe2, "#EC CI_FLDEXT_OK[2610650]
647    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 10.06.2026 for ATC
648    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 10.06.2026  for ATC
649    *        (15) it_sum3-d_dmbe3,
650           (15) it_sum3-d_dmbe3, "#EC CI_FLDEXT_OK[2610650]
651    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 10.06.2026 for ATC
652           (15) '***************',
653            130 sy-vline NO-GAP.
654      ENDLOOP.
655      NEW-LINE.
656      ULINE (130).
657    *** output IT_SKB1_change
658      DESCRIBE TABLE it_skb1_change LINES sy-tfill.
659      IF sy-tfill > 0.
660        NEW-PAGE.
661        head = '4'.
662        LOOP AT it_skb1_change.
663          FORMAT COLOR 2 INTENSIFIED OFF.
664          WRITE:/ sy-vline NO-GAP,
665              (5) it_skb1_change-bukrs,
666             (10) it_skb1_change-hkont,
667              (5) it_skb1_change-xsalh,
668              130 sy-vline NO-GAP.
669        ENDLOOP.
670        NEW-LINE.
671        ULINE (130).
672      ENDIF.
673    *** write entries to rfdt
674      IF wr_rfdt = 'X' AND c_single EQ space.
675        PERFORM write_to_db.
676      ENDIF.
677    ENDFORM.                    " OUTPUT
678    *&---------------------------------------------------------------------*
679    *&      Form  TOP
680    *&---------------------------------------------------------------------*
681    *       text
682    *----------------------------------------------------------------------*
683    *  -->  p1        text
684    *  <--  p2        text
685    *----------------------------------------------------------------------*
686    FORM top .
687      CASE head.
688        WHEN 'C'.
689          FORMAT COLOR 1.
690          ULINE (130).
691          WRITE:/ sy-vline NO-GAP,
692                  'Differences in totals of open items vs. account balance:',
693              130 sy-vline NO-GAP.
694          WRITE:/ sy-vline NO-GAP,
695              (5) 'BUKRS',
696              (5) 'KOART',
697             (10) 'HKONT',
698              (5) 'GSBER',
699              (5) 'PSWSL',
700             (15) 'delta DMBTR',
701             (15) 'delta DMBE2',
702             (15) 'delta DMBE3',
703             (15) 'delta PSWBT',
704             (10) 'COUNTER',
705              130 sy-vline NO-GAP.
706          NEW-LINE.
707          ULINE (130).
708          FORMAT COLOR OFF.
709        WHEN '1'.
710          FORMAT COLOR 3.
711          ULINE (130).
712          WRITE:/ sy-vline NO-GAP,
713                  'Summarization level 1: GSBER',
714              130 sy-vline NO-GAP.
715          WRITE:/ sy-vline NO-GAP,
716              (5) 'BUKRS',
717              (5) 'KOART',
718             (10) 'HKONT',
719              (5) 'GSBER',
720              (5) 'PSWSL',
721             (15) 'delta DMBTR',
722             (15) 'delta DMBE2',
723             (15) 'delta DMBE3',
724             (15) 'delta PSWBT',
725              130 sy-vline NO-GAP.
726          NEW-LINE.
727          ULINE (130).
728          FORMAT COLOR OFF.
729        WHEN '2'.
730          FORMAT COLOR 3.
731          ULINE (130).
732          WRITE:/ sy-vline NO-GAP,
733                  'Summarization level 2: PSWSL',
734              130 sy-vline NO-GAP.
735          WRITE:/ sy-vline NO-GAP,
736              (5) 'BUKRS',
737              (5) 'KOART',
738             (10) 'HKONT',
739              (5) 'GSBER',
740              (5) 'PSWSL',
741             (15) 'delta DMBTR',
742             (15) 'delta DMBE2',
743             (15) 'delta DMBE3',
744             (15) 'delta PSWBT',
745              130 sy-vline NO-GAP.
746          NEW-LINE.
747          ULINE (130).
748          FORMAT COLOR OFF.
749        WHEN '3'.
750          FORMAT COLOR 3.
751          ULINE (130).
752          WRITE:/ sy-vline NO-GAP,
753                  'Summarization level 3: PSWSL and GSBER',
754              130 sy-vline NO-GAP.
755          WRITE:/ sy-vline NO-GAP,
756              (5) 'BUKRS',
757              (5) 'KOART',
758             (10) 'HKONT',
759              (5) 'GSBER',
760              (5) 'PSWSL',
761             (15) 'delta DMBTR',
762             (15) 'delta DMBE2',
763             (15) 'delta DMBE3',
764             (15) 'delta PSWBT',
765              130 sy-vline NO-GAP.
766          NEW-LINE.
767          ULINE (130).
768          FORMAT COLOR OFF.
769        WHEN '4'.
770          FORMAT COLOR 6.
771          ULINE (130).
772          WRITE:/ sy-vline NO-GAP,
773                  'G/L accounts for which XSALH needs to be deactivated:',
774              130 sy-vline NO-GAP.
775          WRITE:/ sy-vline NO-GAP,
776              (5) 'BUKRS',
777             (10) 'HKONT',
778              (5) 'XSALH',
779              130 sy-vline NO-GAP.
780          NEW-LINE.
781          ULINE (130).
782          FORMAT COLOR OFF.
783        WHEN 'L'.
784          FORMAT COLOR 1.
785          ULINE (130).
786          WRITE:/ sy-vline NO-GAP,
787                  'Involved GLT0 ledgers and currencies:',
788              130 sy-vline NO-GAP.
789          WRITE:/ sy-vline NO-GAP,
790              (5) 'RLDNR',
791              (5) 'CURno',
792              (5) 'CURTP',
793              (5) 'CURT1',
794              (5) 'CURT2',
795              (5) 'CURT3',
796              (5) 'FG_1',
797              (5) 'FG_2',
798              (5) 'FG_3',
799              130 sy-vline NO-GAP.
800          NEW-LINE.
801          ULINE (130).
802        WHEN OTHERS.
803      ENDCASE.
804    ENDFORM.                    " TOP
805    *&---------------------------------------------------------------------*
806    *&      Form  WRITE_TO_DB
807    *&---------------------------------------------------------------------*
808    *       text
809    *----------------------------------------------------------------------*
810    *  -->  p1        text
811    *  <--  p2        text
812    *----------------------------------------------------------------------*
813    FORM write_to_db .
814      DATA: x_acct(1) TYPE c.
815
816      CLEAR x_acct.
817      IF koart_s = 'X'.
818        x_acct = 'S'.
819      ELSEIF koart_d = 'X'.
820        x_acct = 'D'.
821      ELSEIF koart_k = 'X'.
822        x_acct = 'K'.
823      ENDIF.
824      CONCATENATE 'KOART_' x_acct INTO rfdt_key-key1.
825      rfdt_key-date = sy-datlo.
826      rfdt_key-time = sy-timlo.
827      EXPORT
828    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 14.06.2026  for ATC
829    *    it_corr
830        it_corr "#EC CI_FLDEXT_OK[2610650]
831    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 14.06.2026 for ATC
832        it_skb1_corr
833        it_skb1_change
834        it_ska1_change
835      TO DATABASE rfdt(eu) ID rfdt_key.
836      IF sy-subrc = 0.
837        CONCATENATE rfdt_key-key1 rfdt_key-date rfdt_key-time INTO exp_key.
838        SKIP 2.
839        NEW-LINE.
840        ULINE (50).
841        FORMAT COLOR 3.
842        WRITE:/ sy-vline NO-GAP,
843                'TABLE RFDT EXPORT FILE KEY:',
844             50 sy-vline NO-GAP.
845        FORMAT COLOR 2 INTENSIFIED OFF.
846        WRITE:/ sy-vline NO-GAP,
847                exp_key,
848             50 sy-vline NO-GAP.
849        NEW-LINE.
850        ULINE (50).
851        FORMAT COLOR 2 INTENSIFIED ON.
852      ENDIF.
853    ENDFORM.                    " WRITE_TO_DB
854    *&---------------------------------------------------------------------*
855    *&      Form  GET_GLT0
856    *&---------------------------------------------------------------------*
857    *       text
858    *----------------------------------------------------------------------*
859    *  -->  p1        text
860    *  <--  p2        text
861    *----------------------------------------------------------------------*
862    FORM get_glt0 .
863      DATA: lt_glt0 TYPE TABLE OF glt0 WITH HEADER LINE,
864            ls_pswbt TYPE bseg-pswbt,
865            ls_dmbtr TYPE bseg-dmbtr,
866            ls_dmbe2 TYPE bseg-dmbe2,
867            ls_dmbe3 TYPE bseg-dmbe3.
868
869    *** process ledger '00': TSL, HSL
870      READ TABLE it_ldglt0 WITH KEY
871        rldnr = '00'.
872    *** TSL and HSL in ledger '00' are always involved
873      REFRESH lt_glt0.
874      SELECT * FROM glt0 INTO TABLE lt_glt0
875        WHERE rrcty = '0'
876          AND rvers = '001'
877          AND bukrs = p_bukrs
878          AND ryear = p_year
879          AND racct = it_skb1-saknr.
880    *** check PSWBT and DMBTR
881      LOOP AT lt_glt0
882        WHERE rldnr = '00'.
883    *** build-up IT_COLL from GLT0
884        CLEAR it_coll.
885        it_coll-bukrs = lt_glt0-bukrs.
886        it_coll-koart = wa_koart.
887        it_coll-hkont = lt_glt0-racct.
888        it_coll-gsber = lt_glt0-rbusa.
889        it_coll-pswsl = lt_glt0-rtcur.
890        MOVE lt_glt0-tslvt TO it_coll-tsl.
891        MOVE lt_glt0-hslvt TO it_coll-hsl.
892        COLLECT it_coll.
893      ENDLOOP.
894    *** optional: check DMBE2
895      CLEAR it_ldglt0.
896      READ TABLE it_ldglt0 WITH KEY
897        curr = '2'.
898      IF sy-subrc = 0.
899        CLEAR: ls_dmbe2.
900        LOOP AT lt_glt0
901          WHERE rldnr = it_ldglt0-rldnr.
902    *** build-up IT_COLL from GLT0
903          CLEAR it_coll.
904          it_coll-bukrs = lt_glt0-bukrs.
905          it_coll-koart = wa_koart.
906          it_coll-hkont = lt_glt0-racct.
907          it_coll-gsber = lt_glt0-rbusa.
908          it_coll-pswsl = lt_glt0-rtcur.
909          IF it_ldglt0-curtp = it_ldglt0-curt1.
910            IF it_ldglt0-fg_curt1 = 'KSL'.
911              MOVE lt_glt0-kslvt TO it_coll-ksl.
912            ELSEIF it_ldglt0-fg_curt1 = 'HSL'.
913              MOVE lt_glt0-hslvt TO it_coll-ksl.
914            ENDIF.
915          ELSEIF it_ldglt0-curtp = it_ldglt0-curt2.
916            IF it_ldglt0-fg_curt2 = 'KSL'.
917              MOVE lt_glt0-kslvt TO it_coll-ksl.
918            ELSEIF it_ldglt0-fg_curt2 = 'HSL'.
919              MOVE lt_glt0-hslvt TO it_coll-ksl.
920            ENDIF.
921          ENDIF.
922          COLLECT it_coll.
923        ENDLOOP.
924      ENDIF.
925    *** optional: check DMBE3
926      CLEAR it_ldglt0.
927      READ TABLE it_ldglt0 WITH KEY
928        curr = '3'.
929      IF sy-subrc = 0.
930        LOOP AT lt_glt0
931          WHERE rldnr = it_ldglt0-rldnr.
932    *** build-up IT_COLL from GLT0
933          CLEAR it_coll.
934          it_coll-bukrs = lt_glt0-bukrs.
935          it_coll-koart = wa_koart.
936          it_coll-hkont = lt_glt0-racct.
937          it_coll-gsber = lt_glt0-rbusa.
938          it_coll-pswsl = lt_glt0-rtcur.
939          IF it_ldglt0-curtp = it_ldglt0-curt1.
940            IF it_ldglt0-fg_curt1 = 'KSL'.
941              MOVE lt_glt0-kslvt TO it_coll-osl.
942            ELSEIF it_ldglt0-fg_curt1 = 'HSL'.
943              MOVE lt_glt0-hslvt TO it_coll-osl.
944            ENDIF.
945          ELSEIF it_ldglt0-curtp = it_ldglt0-curt2.
946            IF it_ldglt0-fg_curt2 = 'KSL'.
947              MOVE lt_glt0-kslvt TO  it_coll-osl.
948            ELSEIF it_ldglt0-fg_curt2 = 'HSL'.
949              MOVE lt_glt0-hslvt TO  it_coll-osl.
950            ENDIF.
951          ENDIF.
952          COLLECT it_coll.
953        ENDLOOP.
954      ENDIF.
955    ENDFORM.                                                    " GET_GLT0
956    *&---------------------------------------------------------------------*
957    *&      Form  OUTPUT_LEDGERS
958    *&---------------------------------------------------------------------*
959    *       text
960    *----------------------------------------------------------------------*
961    *  -->  p1        text
962    *  <--  p2        text
963    *----------------------------------------------------------------------*
964    FORM output_ledgers .
965      NEW-PAGE.
966      head = 'L'.
967
968      LOOP AT it_ldglt0.
969        FORMAT COLOR 2 INTENSIFIED OFF.
970        WRITE:/ sy-vline NO-GAP,
971            (5) it_ldglt0-rldnr,
972            (5) it_ldglt0-curr,
973            (5) it_ldglt0-curtp,
974            (5) it_ldglt0-curt1,
975            (5) it_ldglt0-curt2,
976            (5) it_ldglt0-curt3,
977            (5) it_ldglt0-fg_curt1,
978            (5) it_ldglt0-fg_curt2,
979            (5) it_ldglt0-fg_curt3,
980            130 sy-vline NO-GAP.
981      ENDLOOP.
982      NEW-LINE.
983      ULINE (130).
984    ENDFORM.                    " OUTPUT_LEDGERS
985    *&---------------------------------------------------------------------*
986    *&      Form  SELECT_SKB1
987    *&---------------------------------------------------------------------*
988    *       text
989    *----------------------------------------------------------------------*
990    *  -->  p1        text
991    *  <--  p2        text
992    *----------------------------------------------------------------------*
993    FORM select_skb1 .
994      DATA: it_t074 TYPE TABLE OF t074 WITH HEADER LINE.
995    *** KOART S
996      IF koart_s = 'X'.
997    *** check all OI managed G/L accounts
998        IF c_single EQ space.
999    *** only open item managed accounts
1000         REFRESH it_skb1.
1001   " " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1002         SELECT * FROM skb1 INTO CORRESPONDING FIELDS OF TABLE it_skb1 "#EC CI_DB_OPERATION_OK[2431747]
1003           WHERE bukrs EQ p_bukrs
1004             AND xkres EQ 'X'
1005             AND xopvw EQ 'X'.
1006   " " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
1007       ELSE.
1008   *** check single G/L account
1009         IF p_hkont EQ space.
1010           WRITE:/ 'HKONT required!' COLOR 6.
1011           EXIT.
1012         ENDIF.
1013   *** only open item managed account
1014   " " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1015         SELECT * FROM skb1 INTO CORRESPONDING FIELDS OF TABLE it_skb1 "#EC CI_DB_OPERATION_OK[2431747]
1016           WHERE bukrs EQ p_bukrs
1017             AND saknr EQ p_hkont
1018             AND xkres EQ 'X'
1019             AND xopvw EQ 'X'.
1020   " " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
1021         DESCRIBE TABLE it_skb1 LINES sy-tfill.
1022         IF sy-tfill = 0.
1023           WRITE:/ 'No G/L account selected' COLOR 6.
1024           EXIT.
1025         ENDIF.
1026       ENDIF.
1027   *** store IT_SKB1_CORR
1028       APPEND LINES OF it_skb1 TO it_skb1_corr.
1029     ENDIF.
1030   *** KOART D
1031     IF koart_d = 'X'.
1032       REFRESH it_skb1.
1033   " " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1034       SELECT * FROM skb1 INTO CORRESPONDING FIELDS OF TABLE it_skb1 "#EC CI_DB_OPERATION_OK[2431747]
1035         WHERE bukrs EQ p_bukrs
1036           AND mitkz EQ 'D'.
1037   " " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
1038       LOOP AT it_skb1.
1039   *** check if special G/L account
1040         REFRESH it_t074.
1041         SELECT * FROM t074 INTO TABLE it_t074
1042           WHERE ktopl = wa_t001-ktopl
1043             AND koart = 'D'
1044             AND skont = it_skb1-saknr.
1045         DESCRIBE TABLE it_t074 LINES sy-tfill.
1046   *** no special G/L
1047         IF sy-tfill = 0.
1048           CONTINUE.
1049   *** special G/L for single UMSKZ
1050         ELSEIF sy-tfill = 1.
1051   " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1052           READ TABLE it_t074 INDEX 1. "#EC CI_NOORDER
1053   " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1054           it_skb1-umskz = it_t074-umskz.
1055           MODIFY it_skb1.
1056   *** special G/L for multiple UMSKZ
1057         ELSE.
1058   " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1059           READ TABLE it_t074 INDEX 1. "#EC CI_NOORDER
1060   " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1061           it_skb1-umskz = it_t074-umskz.
1062           it_skb1-mult_umskz = 'X'.
1063           MODIFY it_skb1.
1064         ENDIF.
1065       ENDLOOP.
1066   *** store IT_SKB1_CORR
1067       APPEND LINES OF it_skb1 TO it_skb1_corr.
1068     ENDIF.
1069   *** KOART K
1070     IF koart_k = 'X'.
1071       REFRESH it_skb1.
1072   " " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1073       SELECT * FROM skb1 INTO CORRESPONDING FIELDS OF TABLE it_skb1 "#EC CI_DB_OPERATION_OK[2431747]
1074         WHERE bukrs EQ p_bukrs
1075           AND mitkz EQ 'K'.
1076   " " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
1077       LOOP AT it_skb1.
1078   *** check if special G/L account
1079         REFRESH it_t074.
1080         SELECT * FROM t074 INTO TABLE it_t074
1081           WHERE ktopl = wa_t001-ktopl
1082             AND koart = 'K'
1083             AND skont = it_skb1-saknr.
1084         DESCRIBE TABLE it_t074 LINES sy-tfill.
1085   *** no special G/L
1086         IF sy-tfill = 0.
1087           CONTINUE.
1088   *** special G/L for single UMSKZ
1089         ELSEIF sy-tfill = 1.
1090   " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1091           READ TABLE it_t074 INDEX 1. "#EC CI_NOORDER
1092   " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1093           it_skb1-umskz = it_t074-umskz.
1094           MODIFY it_skb1.
1095   *** special G/L for multiple UMSKZ
1096         ELSE.
1097   " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1098           READ TABLE it_t074 INDEX 1. "#EC CI_NOORDER
1099   " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1100           it_skb1-umskz = it_t074-umskz.
1101           it_skb1-mult_umskz = 'X'.
1102           MODIFY it_skb1.
1103         ENDIF.
1104       ENDLOOP.
1105   *** store IT_SKB1_CORR
1106       APPEND LINES OF it_skb1 TO it_skb1_corr.
1107     ENDIF.
1108   ENDFORM.                    " SELECT_SKB1
1109   *&---------------------------------------------------------------------*
1110   *&      Form  SET_KEYDATE
1111   *&---------------------------------------------------------------------*
1112   *       text
1113   *----------------------------------------------------------------------*
1114   *  -->  p1        text
1115   *  <--  p2        text
1116   *----------------------------------------------------------------------*
1117   FORM set_keydate .
1118   *** create KEY_DATE
1119     CLEAR key_date.
1120     CLEAR wa_fday.
1121     CALL FUNCTION 'PERIOD_DAY_DETERMINE'
1122       EXPORTING
1123         i_gjahr                    = p_year
1124         i_monat                    = '01'
1125         i_periv                    = wa_t001-periv
1126       IMPORTING
1127         e_fday                     = wa_fday
1128   *   E_LDAY                     =
1129   *   E_SPERIOD                  =
1130   * EXCEPTIONS
1131   *   ERROR_PERIOD               = 1
1132   *   ERROR_PERIOD_VERSION       = 2
1133   *   FIRSTDAY_NOT_DEFINED       = 3
1134   *   PERIOD_NOT_DEFINED         = 4
1135   *   YEAR_INVALID               = 5
1136   *   OTHERS                     = 6
1137               .
1138     IF sy-subrc <> 0.
1139       MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
1140               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
1141     ENDIF.
1142   *** KEY_DATE
1143     key_date = wa_fday - 1.
1144   ENDFORM.                    " SET_KEYDATE
1145   *&---------------------------------------------------------------------*
1146   *&      Form  GET_LEDGERS
1147   *&---------------------------------------------------------------------*
1148   *       text
1149   *----------------------------------------------------------------------*
1150   *  -->  p1        text
1151   *  <--  p2        text
1152   *----------------------------------------------------------------------*
1153   FORM get_ledgers .
1154     SELECT SINGLE * FROM t001a INTO wa_t001a
1155       WHERE bukrs = p_bukrs.
1156     IF sy-subrc = 0.
1157   *** LC2 active?
1158       IF wa_t001a-curtp NE space.
1159         REFRESH it_ledtab.
1160         CALL FUNCTION 'G_GIVE_LEDGERS_FOR_GLT0'
1161           EXPORTING
1162             bukrs                          = wa_t001a-bukrs
1163             curtp                          = wa_t001a-curtp
1164   *   JOIN_OF_VALUTYP_AND_CURT       = 'X'
1165           TABLES
1166             ledtab                         = it_ledtab
1167                   .
1168         READ TABLE it_ledtab INDEX 1.
1169         CLEAR it_ldglt0.
1170         MOVE-CORRESPONDING it_ledtab TO it_ldglt0.
1171         it_ldglt0-curtp = wa_t001a-curtp.
1172         it_ldglt0-curr = '2'.
1173         INSERT it_ldglt0 INTO TABLE it_ldglt0.
1174       ENDIF.
1175   *** LC3 active?
1176       IF wa_t001a-curtp2 NE space.
1177         REFRESH it_ledtab.
1178         CALL FUNCTION 'G_GIVE_LEDGERS_FOR_GLT0'
1179           EXPORTING
1180             bukrs                          = wa_t001a-bukrs
1181             curtp                          = wa_t001a-curtp2
1182   *   JOIN_OF_VALUTYP_AND_CURT       = 'X'
1183           TABLES
1184             ledtab                         = it_ledtab
1185                   .
1186         READ TABLE it_ledtab INDEX 1.
1187         CLEAR it_ldglt0.
1188         MOVE-CORRESPONDING it_ledtab TO it_ldglt0.
1189         it_ldglt0-curtp = wa_t001a-curtp2.
1190         it_ldglt0-curr = '3'.
1191         INSERT it_ldglt0 INTO TABLE it_ldglt0.
1192       ENDIF.
1193   *** no parallel currencies defined
1194     ELSE.
1195       CLEAR it_ldglt0.
1196       it_ldglt0-rldnr = '00'.
1197       it_ldglt0-curtp = '10'.
1198       it_ldglt0-curr = '1'.
1199       INSERT it_ldglt0 INTO TABLE it_ldglt0.
1200     ENDIF.
1201   *** get update fields for ledgers
1202     LOOP AT it_ldglt0.
1203       CALL FUNCTION 'G_GET_ORGANIZATIONAL_DATA'
1204         EXPORTING
1205           i_rldnr                        = it_ldglt0-rldnr
1206           i_orgunit                      = p_bukrs
1207   *     JOIN_OF_VALUTYP_AND_CURT       = 'X'
1208   *     SEND_ERROR_WHEN_DEPLD          = ' '
1209         IMPORTING
1210           organizational_info            = it_org_info
1211   *   EXCEPTIONS
1212   *     NO_INFO_FOUND                  = 1
1213   *     ERROR_IN_SETUP                 = 2
1214   *     ERROR_IN_DEPLD                 = 3
1215   *     OTHERS                         = 4
1216                 .
1217       IF sy-subrc <> 0.
1218   * MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
1219   *         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
1220       ENDIF.
1221       READ TABLE it_org_info INDEX 1.
1222       MOVE-CORRESPONDING it_org_info TO it_ldglt0.
1223       MODIFY it_ldglt0.
1224     ENDLOOP.
1225
1226   ENDFORM.                    " GET_LEDGERS
*--- End of ZF_CHECK_OI_BALANCE_EXT - 1226 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  <REPINI>                                  Level 1    Page 2
Object           ZF_CHECK_OI_BALANCE_EXT                   Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:54
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
Object           ZF_CHECK_OI_BALANCE_EXT                   Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:54
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
Object           ZF_CHECK_OI_BALANCE_EXT                   Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:54
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
Object           ZF_CHECK_OI_BALANCE_EXT                   Lines 1
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:54
----------------------------------------------------------------------------------------------------
1      * INCLUDE DB__SSEL
*--- End of DB__SSEL - 1 lines ---
