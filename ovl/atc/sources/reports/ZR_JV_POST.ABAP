----------------------------------------------------------------------------------------------------
Main program     ZR_JV_POST                                Level 0    Page 1
Object           ZR_JV_POST                                Lines 2199
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:01
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *& Report  ZR_JV_POST
3      *& JV Transfer: Colombia OCV->OVL | Cutback | NB | Corporate Items
4      *& Z Tables:
5      *&   ZJV_MAP_COCODE - JV/Recovery Indicator -> Receiving Co.Code
6      *&   ZJV_MAP_GL     - GL Account Mapping
7      *&   ZJV_MAP_RCNTR  - Cost Center Mapping
8      *&   ZJV_MAP_WBS    - WBS Element Mapping
9      *&   ZJV_MAP_PRCTR  - Profit Center Mapping
10     *& Source Table:
11     *&   JVSO1          - JV Accounting (Ledgers 4A / 4C)
12     *&---------------------------------------------------------------------*
13     REPORT zr_jv_post.
14
15     *----------------------------------------------------------------------*
16     * TABLES
17     *----------------------------------------------------------------------*
18     TABLES: jvso1.
19
20     *----------------------------------------------------------------------*
21     * TYPES
22     *----------------------------------------------------------------------*
23     *TYPES: BEGIN OF ty_jv_map,
24     *         op_bukrs  TYPE bukrs,
25     *         op_vname  TYPE jv_name,
26     *         op_recid  TYPE jv_recind,
27     *         offset_gl TYPE zfi_offset_capexgl,
28     *         rec_bukrs TYPE bukrs,
29     *       END OF ty_jv_map.
30     TYPES: BEGIN OF ty_jv_map,
31              op_bukrs  TYPE zfi_de_send_bukrs,
32              op_vname  TYPE zfi_de_send_venture,
33              op_recid  TYPE jv_recind,
34              offset_gl TYPE allgkonto,
35              type      TYPE zfi_de_type,   " indicates whether OFFSET_GL is a vendor or GL account
36              rec_bukrs TYPE zfi_de_rec_bukrs,
37            END OF ty_jv_map.
38
39     *TYPES: BEGIN OF ty_gl_map,
40     *         op_bukrs  TYPE bukrs,
41     *         op_saknr  TYPE saknr,
42     *         rec_bukrs TYPE bukrs,
43     *         rec_saknr TYPE saknr,
44     *       END OF ty_gl_map.
45     TYPES: BEGIN OF ty_gl_map,
46              op_bukrs      TYPE bukrs,
47              op_saknr      TYPE saknr,
48              rec_bukrs     TYPE bukrs,
49              rec_saknr     TYPE saknr,
50              default_kostl TYPE kostl,   " NEW
51              default_prctr TYPE prctr,   " NEW
52            END OF ty_gl_map.
53
54     TYPES: BEGIN OF ty_rcntr_map,
55              op_bukrs  TYPE bukrs,
56              op_kostl  TYPE kostl,
57              rec_bukrs TYPE bukrs,
58              rec_kostl TYPE kostl,
59            END OF ty_rcntr_map.
60
61     TYPES: BEGIN OF ty_wbs_map,
62              op_bukrs  TYPE bukrs,
63              op_posid  TYPE ps_posid,
64              rec_bukrs TYPE bukrs,
65              rec_posid TYPE ps_posid,
66            END OF ty_wbs_map.
67
68     TYPES: BEGIN OF ty_prctr_map,
69              op_bukrs  TYPE bukrs,
70              op_prctr  TYPE prctr,
71              rec_bukrs TYPE bukrs,
72              rec_prctr TYPE prctr,
73            END OF ty_prctr_map.
74
75     TYPES: BEGIN OF ty_jvso1,
76       GL_SIRID type GU_RECID,
77              rldnr  TYPE rldnr,
78              rbukrs TYPE bukrs,
79              rrcty  TYPE rrcty,
80              rvers  TYPE rvers,
81              ryear  TYPE gjahr,
82              poper  TYPE poper,
83              rjvnam TYPE jv_name,
84              rrecin TYPE jv_recind,
85              racct  TYPE racct,
86              regrou TYPE jv_egroup,
87              rcntr  TYPE kostl,
88              rordnr TYPE aufnr,
89              rprojk TYPE ps_psp_pnr,
90              rprctr TYPE prctr,
91              budat  TYPE budat,
92              tsl    TYPE vtcur9,
93              hsl    TYPE vlcur9,
94              ksl    TYPE vgcur9,
95            END OF ty_jvso1.
96
97     *TYPES: BEGIN OF ty_subtotal,
98     *         rbukrs     TYPE bukrs,
99     *         rjvnam     TYPE jv_name,
100    *         rrecin     TYPE jv_recind,
101    *         racct      TYPE racct,
102    *         rcntr      TYPE kostl,
103    *         rordnr     TYPE aufnr,
104    *         rprojk     TYPE ps_psp_pnr,
105    *         rprctr     TYPE prctr,
106    *         budat      TYPE budat,
107    *         tsl        TYPE vtcur9,
108    *         hsl        TYPE vlcur9,
109    *         ksl        TYPE vgcur9,
110    *         recv_bukrs TYPE bukrs,
111    *         recv_saknr TYPE saknr,
112    *         recv_kostl TYPE kostl,
113    *         recv_posid TYPE ps_posid,
114    *         recv_prctr TYPE prctr,
115    *         send_curr  TYPE waers,
116    *         recv_curr  TYPE waers,
117    *         post_date  TYPE budat,
118    *       END OF ty_subtotal.
119    TYPES: BEGIN OF ty_subtotal,
120             rbukrs        TYPE bukrs,
121             rjvnam        TYPE jv_name,
122             rrecin        TYPE jv_recind,
123             racct         TYPE racct,
124             rcntr         TYPE kostl,
125             rordnr        TYPE aufnr,
126             rprojk        TYPE ps_psp_pnr,
127             rprctr        TYPE prctr,
128             budat         TYPE budat,
129             tsl           TYPE vtcur9,
130             hsl           TYPE vlcur9,
131             ksl           TYPE vgcur9,
132             recv_bukrs    TYPE bukrs,
133             recv_saknr    TYPE saknr,
134             recv_kostl    TYPE kostl,
135             recv_posid    TYPE ps_posid,
136             recv_prctr    TYPE prctr,
137             default_kostl TYPE kostl,   " NEW - carried from ZJV_MAP_GL
138             default_prctr TYPE prctr,   " NEW - carried from ZJV_MAP_GL
139             send_curr     TYPE waers,
140             recv_curr     TYPE waers,
141             post_date     TYPE budat,
142           END OF ty_subtotal.
143
144    TYPES: BEGIN OF ty_alv_result,
145             msgty      TYPE bapi_mtype,
146             comp_code  TYPE bukrs,
147             doc_number TYPE belnr_d,
148             message    TYPE string,
149           END OF ty_alv_result.
150
151    *----------------------------------------------------------------------*
152    * INTERNAL TABLES
153    *----------------------------------------------------------------------*
154    DATA: gt_jv_map     TYPE TABLE OF ty_jv_map,
155          gt_gl_map     TYPE TABLE OF ty_gl_map,
156          gt_rcntr_map  TYPE TABLE OF ty_rcntr_map,
157          gt_wbs_map    TYPE TABLE OF ty_wbs_map,
158          gt_prctr_map  TYPE TABLE OF ty_prctr_map,
159          gt_jvso1      TYPE TABLE OF ty_jvso1,
160          gt_subtotal   TYPE TABLE OF ty_subtotal,
161          gt_alv_result TYPE TABLE OF ty_alv_result.
162
163    DATA: GS_JV_MAP_TRF TYPE ZJV_MAP_TRF.
164
165    *----------------------------------------------------------------------*
166    * WORK AREAS
167    *----------------------------------------------------------------------*
168    DATA: gs_jvso1      TYPE ty_jvso1,
169          gs_jv_map     TYPE ty_jv_map,
170          gs_gl_map     TYPE ty_gl_map,
171          gs_rcntr_map  TYPE ty_rcntr_map,
172          gs_wbs_map    TYPE ty_wbs_map,
173          gs_prctr_map  TYPE ty_prctr_map,
174          gs_alv_result TYPE ty_alv_result.
175
176    *----------------------------------------------------------------------*
177    * BAPI Structures
178    *----------------------------------------------------------------------*
179    DATA: gs_doc_header     TYPE bapiache09,
180          gt_accountgl      TYPE TABLE OF bapiacgl09,
181          gt_currencyamount TYPE TABLE OF bapiaccr09,
182          gt_return         TYPE TABLE OF bapiret2,
183          gs_accountgl      TYPE bapiacgl09,
184          gs_currencyamount TYPE bapiaccr09,
185          gs_return         TYPE bapiret2,
186          gv_obj_type       TYPE bapiache09-obj_type,
187          gv_obj_key        TYPE bapiache09-obj_key,
188          gv_obj_sys        TYPE bapiache09-obj_sys.
189
190    DATA: gt_accountpayable TYPE STANDARD TABLE OF bapiacap09,
191          gs_accountpayable TYPE bapiacap09.
192
193    *----------------------------------------------------------------------*
194    * VARIABLES
195    *----------------------------------------------------------------------*
196    DATA: gv_test_run  TYPE abap_bool,
197          gv_post_date TYPE budat,         " posting date for the current batch
198          lt_racct     TYPE RANGE OF saknr,
199          ls_racct     LIKE LINE OF lt_racct.
200
201    *----------------------------------------------------------------------*
202    * SELECTION SCREEN
203    *----------------------------------------------------------------------*
204    SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE sel_par.
205    PARAMETERS:
206      p_bukrs TYPE bukrs OBLIGATORY,
207      p_gjahr TYPE gjahr OBLIGATORY,
208      p_poper TYPE poper OBLIGATORY,
209      p_jv    TYPE jv_name OBLIGATORY.
210    SELECTION-SCREEN END OF BLOCK b1.
211
212    SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE proc_op.
213    PARAMETERS:
214      p_test TYPE abap_bool AS CHECKBOX DEFAULT 'X'.
215    SELECTION-SCREEN END OF BLOCK b2.
216
217    *----------------------------------------------------------------------*
218    * INITIALIZATION
219    *----------------------------------------------------------------------*
220    INITIALIZATION.
221      sel_par = 'Selection Parameters'.
222      proc_op = 'Processing Options'.
223
224    *----------------------------------------------------------------------*
225    * START-OF-SELECTION
226    *----------------------------------------------------------------------*
227
228
229    START-OF-SELECTION.
230
231
232
233      gv_test_run = p_test.
234
235      PERFORM load_mapping_tables.
236      perform validate_posting.
237      PERFORM read_jvso1.
238      PERFORM aggregate_subtotals.
239      PERFORM apply_mappings.
240      PERFORM determine_cost_element.
241       PERFORM resolve_wbs_element.
242      PERFORM post_documents.
243      PERFORM display_summary.
244
245    *----------------------------------------------------------------------*
246    * FORM: LOAD_MAPPING_TABLES
247    *----------------------------------------------------------------------*
248    FORM load_mapping_tables.
249
250    *  SELECT op_bukrs op_vname op_recid offset_gl rec_bukrs
251    **    rec_vname rec_recid
252    *    FROM zjv_map_cocode
253    *    INTO TABLE gt_jv_map
254    *   WHERE op_bukrs = p_bukrs.
255    SELECT op_bukrs op_vname op_recid offset_gl type rec_bukrs
256      FROM zjv_map_cocode
257      INTO TABLE gt_jv_map
258     WHERE op_bukrs = p_bukrs.
259
260    *  SELECT op_bukrs op_saknr rec_bukrs rec_saknr
261    *    FROM zjv_map_gl
262    *    INTO TABLE gt_gl_map
263    *   WHERE op_bukrs = p_bukrs.
264    SELECT op_bukrs op_saknr rec_bukrs rec_saknr default_kostl default_prctr
265      FROM zjv_map_gl
266      INTO TABLE gt_gl_map
267     WHERE op_bukrs = p_bukrs.
268
269      " Build account range from the mapped GLs (FIX #5: was inside sy-subrc block;
270      " moved out so it is always built whenever gt_gl_map has data).
271      CLEAR lt_racct.
272      LOOP AT gt_gl_map INTO DATA(ls_gl).
273        CLEAR ls_racct.
274        ls_racct-sign   = 'I'.
275        ls_racct-option = 'EQ'.
276        ls_racct-low    = ls_gl-op_saknr.
277        APPEND ls_racct TO lt_racct.
278      ENDLOOP.
279
280      SELECT op_bukrs op_kostl rec_bukrs rec_kostl
281        FROM zjv_map_rcntr
282        INTO TABLE gt_rcntr_map
283       WHERE op_bukrs = p_bukrs.
284
285      SELECT op_bukrs op_posid rec_bukrs rec_posid
286        FROM zjv_map_wbs
287        INTO TABLE gt_wbs_map
288       WHERE op_bukrs = p_bukrs.
289
290      SELECT op_bukrs op_prctr rec_bukrs rec_prctr
291        FROM zjv_map_prctr
292        INTO TABLE gt_prctr_map
293       WHERE op_bukrs = p_bukrs.
294
295    ENDFORM.
296
297    *----------------------------------------------------------------------*
298    * FORM: READ_JVSO1
299    *----------------------------------------------------------------------*
300    FORM read_jvso1.
301
302      " FIX #5: Guard against empty driver tables. Empty FOR ALL ENTRIES
303      " or empty IN-range would otherwise pull the entire JVSO1 table.
304      IF gt_jv_map IS INITIAL OR lt_racct IS INITIAL.
305        APPEND VALUE #( msgty   = 'E'
306                        message = 'Mapping tables (JV / GL) are empty - nothing to read'
307                      ) TO gt_alv_result.
308        RETURN.
309      ENDIF.
310
311      SELECT GL_SIRID, rldnr, rbukrs, rrcty, rvers, ryear, poper, rjvnam, rrecin, racct,
312             regrou, rcntr, rordnr, rprojk, rprctr, budat, tsl, hsl, ksl
313        FROM jvso1
314        INTO TABLE @gt_jvso1
315        FOR ALL ENTRIES IN @gt_jv_map
316       WHERE rldnr  IN ('4A')
317         AND rrcty  =  '0'
318         AND rvers  =  '001'
319         AND rbukrs =  @p_bukrs
320         AND ryear  =  @p_gjahr
321         AND poper  =  @p_poper
322         AND rjvnam =  @p_jv
323         AND rrecin =  @gt_jv_map-op_recid
324         AND racct  IN @lt_racct.
325
326      IF gt_jvso1 IS INITIAL.
327        " FIX #6: do not raise an 'E' message inside S-O-S - it short dumps.
328        APPEND VALUE #( msgty   = 'I'
329                        message = 'No JVSO1 records found for the given selection'
330                      ) TO gt_alv_result.
331      ENDIF.
332
333    ENDFORM.
334
335    *----------------------------------------------------------------------*
336    * FORM: AGGREGATE_SUBTOTALS
337    *----------------------------------------------------------------------*
338    FORM aggregate_subtotals.
339      DATA: ls_sub TYPE ty_subtotal.
340      FIELD-SYMBOLS: <fs_sub> TYPE ty_subtotal.
341
342      SORT gt_jvso1 BY rbukrs rjvnam rrecin racct rcntr rordnr rprojk rprctr.
343
344      LOOP AT gt_jvso1 INTO gs_jvso1.
345        READ TABLE gt_subtotal ASSIGNING <fs_sub>
346          WITH KEY rbukrs = gs_jvso1-rbukrs
347                   rjvnam = gs_jvso1-rjvnam
348    **               rrecin = gs_jvso1-rrecin
349                   racct  = gs_jvso1-racct
350                   rcntr  = gs_jvso1-rcntr.
351    *               rordnr = gs_jvso1-rordnr
352    *               rprojk = gs_jvso1-rprojk
353    *               rprctr = gs_jvso1-rprctr.
354        IF sy-subrc = 0.
355          <fs_sub>-tsl = <fs_sub>-tsl + gs_jvso1-tsl.
356          <fs_sub>-hsl = <fs_sub>-hsl + gs_jvso1-hsl.
357          <fs_sub>-ksl = <fs_sub>-ksl + gs_jvso1-ksl.
358          " Keep the latest BUDAT in the same group so post_date calc is stable
359          IF gs_jvso1-budat > <fs_sub>-budat.
360            <fs_sub>-budat = gs_jvso1-budat.
361          ENDIF.
362        ELSE.
363          CLEAR ls_sub.
364          ls_sub-rbukrs = gs_jvso1-rbukrs.
365          ls_sub-rjvnam = gs_jvso1-rjvnam.
366          ls_sub-rrecin = gs_jvso1-rrecin.
367          ls_sub-racct  = gs_jvso1-racct.
368          ls_sub-rcntr  = gs_jvso1-rcntr.
369          ls_sub-rordnr = gs_jvso1-rordnr.
370          ls_sub-rprojk = gs_jvso1-rprojk.
371          ls_sub-rprctr = gs_jvso1-rprctr.
372          ls_sub-budat  = gs_jvso1-budat.
373          ls_sub-tsl    = gs_jvso1-tsl.
374          ls_sub-hsl    = gs_jvso1-hsl.
375          ls_sub-ksl    = gs_jvso1-ksl.
376          APPEND ls_sub TO gt_subtotal.
377        ENDIF.
378      ENDLOOP.
379    ENDFORM.
380    *FORM aggregate_subtotals.
381    *  DATA: ls_sub TYPE ty_subtotal.
382    *  FIELD-SYMBOLS: <fs_sub> TYPE ty_subtotal.
383    *
384    *  SORT gt_jvso1 BY rbukrs rjvnam rrecin racct rcntr rordnr rprojk rprctr.
385    *
386    *  LOOP AT gt_jvso1 INTO gs_jvso1.
387    *    READ TABLE gt_subtotal ASSIGNING <fs_sub>
388    *      WITH KEY rbukrs = gs_jvso1-rbukrs
389    *               rjvnam = gs_jvso1-rjvnam
390    *               rrecin = gs_jvso1-rrecin
391    *               racct  = gs_jvso1-racct
392    *               rcntr  = gs_jvso1-rcntr
393    *               rordnr = gs_jvso1-rordnr
394    *               rprojk = gs_jvso1-rprojk
395    *               rprctr = gs_jvso1-rprctr.
396    *    IF sy-subrc = 0.
397    *      <fs_sub>-tsl = <fs_sub>-tsl + gs_jvso1-tsl.
398    *      <fs_sub>-hsl = <fs_sub>-hsl + gs_jvso1-hsl.
399    *      <fs_sub>-ksl = <fs_sub>-ksl + gs_jvso1-ksl.
400    *      IF gs_jvso1-budat > <fs_sub>-budat.
401    *        <fs_sub>-budat = gs_jvso1-budat.
402    *      ENDIF.
403    *    ELSE.
404    *      CLEAR ls_sub.
405    *      ls_sub-rbukrs = gs_jvso1-rbukrs.
406    *      ls_sub-rjvnam = gs_jvso1-rjvnam.
407    *      ls_sub-rrecin = gs_jvso1-rrecin.
408    *      ls_sub-racct  = gs_jvso1-racct.
409    *      ls_sub-rcntr  = gs_jvso1-rcntr.
410    *      ls_sub-rordnr = gs_jvso1-rordnr.
411    *      ls_sub-rprojk = gs_jvso1-rprojk.
412    *      ls_sub-rprctr = gs_jvso1-rprctr.
413    *      ls_sub-budat  = gs_jvso1-budat.
414    *      ls_sub-tsl    = gs_jvso1-tsl.
415    *      ls_sub-hsl    = gs_jvso1-hsl.
416    *      ls_sub-ksl    = gs_jvso1-ksl.
417    *      APPEND ls_sub TO gt_subtotal.
418    *    ENDIF.
419    *  ENDLOOP.
420    *ENDFORM.
421
422    *----------------------------------------------------------------------*
423    * FORM: APPLY_MAPPINGS
424    *----------------------------------------------------------------------*
425    FORM apply_mappings.
426    *  DATA: lv_last_day TYPE d.
427    *  FIELD-SYMBOLS: <fs_sub> TYPE ty_subtotal.
428    *
429    *  LOOP AT gt_subtotal ASSIGNING <fs_sub>.
430    *
431    *    " JV / Recovery Indicator -> Receiving Co.Code
432    *    READ TABLE gt_jv_map INTO gs_jv_map
433    *      WITH KEY op_bukrs = <fs_sub>-rbukrs
434    *               op_vname = <fs_sub>-rjvnam
435    *               op_recid = <fs_sub>-rrecin.
436    *    IF sy-subrc <> 0.
437    *      CONTINUE.
438    *    ENDIF.
439    *    <fs_sub>-recv_bukrs = gs_jv_map-rec_bukrs.
440    *
441    *    " GL mapping
442    *    READ TABLE gt_gl_map INTO gs_gl_map
443    *      WITH KEY op_bukrs  = <fs_sub>-rbukrs
444    *               op_saknr  = <fs_sub>-racct
445    *               rec_bukrs = <fs_sub>-recv_bukrs.
446    *    IF sy-subrc = 0.
447    *      <fs_sub>-recv_saknr = gs_gl_map-rec_saknr.
448    *    ENDIF.
449    *
450    *    " Cost center mapping
451    *    IF <fs_sub>-rcntr IS NOT INITIAL.
452    *      READ TABLE gt_rcntr_map INTO gs_rcntr_map
453    *        WITH KEY op_bukrs  = <fs_sub>-rbukrs
454    *                 op_kostl  = <fs_sub>-rcntr
455    *                 rec_bukrs = <fs_sub>-recv_bukrs.
456    *      IF sy-subrc = 0.
457    *        <fs_sub>-recv_kostl = gs_rcntr_map-rec_kostl.
458    *      ENDIF.
459    *    ENDIF.
460    *
461    *    " WBS mapping
462    *    IF <fs_sub>-rprojk IS NOT INITIAL.
463    *      READ TABLE gt_wbs_map INTO gs_wbs_map
464    *        WITH KEY op_bukrs  = <fs_sub>-rbukrs
465    *                 op_posid  = <fs_sub>-rprojk
466    *                 rec_bukrs = <fs_sub>-recv_bukrs.
467    *      IF sy-subrc = 0.
468    *        <fs_sub>-recv_posid = gs_wbs_map-rec_posid.
469    *      ENDIF.
470    *    ENDIF.
471    *
472    *    " Profit center mapping
473    *    IF <fs_sub>-rprctr IS NOT INITIAL.
474    *      READ TABLE gt_prctr_map INTO gs_prctr_map
475    *        WITH KEY op_bukrs  = <fs_sub>-rbukrs
476    *                 op_prctr  = <fs_sub>-rprctr
477    *                 rec_bukrs = <fs_sub>-recv_bukrs.
478    *      IF sy-subrc = 0.
479    *        <fs_sub>-recv_prctr = gs_prctr_map-rec_prctr.
480    *      ENDIF.
481    *    ENDIF.
482    *
483    *    " Currencies (currently hardcoded USD - swap in JV_AND_FI_CURRENCIES later)
484    *    IF <fs_sub>-rbukrs IS NOT INITIAL.
485    *      <fs_sub>-send_curr = 'USD'.
486    *    ENDIF.
487    *    " FIX #9: was checking rbukrs - should test the receiver's company code
488    *    IF <fs_sub>-recv_bukrs IS NOT INITIAL.
489    *      <fs_sub>-recv_curr = 'USD'.
490    *    ENDIF.
491    *
492    *    " Posting date = last day of the BUDAT month
493    *    CHECK <fs_sub>-budat IS NOT INITIAL.
494    *
495    *    CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
496    *      EXPORTING
497    *        day_in            = <fs_sub>-budat
498    *      IMPORTING
499    *        last_day_of_month = lv_last_day
500    *      EXCEPTIONS
501    *        day_in_no_date    = 1
502    *        OTHERS            = 2.
503    *
504    *    <fs_sub>-post_date = COND #( WHEN sy-subrc = 0
505    *                                 THEN lv_last_day
506    *                                 ELSE <fs_sub>-budat ).
507    *
508    *  ENDLOOP.
509    *----------------------------------------------------------------------*
510    * FORM: APPLY_MAPPINGS
511    *----------------------------------------------------------------------*
512    *FORM apply_mappings.
513      DATA: lv_last_day  TYPE d,
514            lv_key_kostl TYPE char12.
515      FIELD-SYMBOLS: <fs_sub> TYPE ty_subtotal.
516
517      LOOP AT gt_subtotal ASSIGNING <fs_sub>.
518
519        " JV / Recovery Indicator -> Receiving Co.Code
520        READ TABLE gt_jv_map INTO gs_jv_map
521          WITH KEY op_bukrs = <fs_sub>-rbukrs
522                   op_vname = <fs_sub>-rjvnam
523                   op_recid = <fs_sub>-rrecin.
524        IF sy-subrc <> 0.
525          CONTINUE.
526        ENDIF.
527        <fs_sub>-recv_bukrs = gs_jv_map-rec_bukrs.
528
529        " GL mapping
530    *    READ TABLE gt_gl_map INTO gs_gl_map
531    *      WITH KEY op_bukrs  = <fs_sub>-rbukrs
532    *               op_saknr  = <fs_sub>-racct
533    *               rec_bukrs = <fs_sub>-recv_bukrs.
534    *    IF sy-subrc = 0.
535    *      <fs_sub>-recv_saknr = gs_gl_map-rec_saknr.
536    *    ENDIF.
537    " GL mapping
538    READ TABLE gt_gl_map INTO gs_gl_map
539      WITH KEY op_bukrs  = <fs_sub>-rbukrs
540               op_saknr  = <fs_sub>-racct
541               rec_bukrs = <fs_sub>-recv_bukrs.
542    IF sy-subrc = 0.
543      <fs_sub>-recv_saknr    = gs_gl_map-rec_saknr.
544      <fs_sub>-default_kostl = gs_gl_map-default_kostl.   " NEW
545      <fs_sub>-default_prctr = gs_gl_map-default_prctr.   " NEW
546    ENDIF.
547
548        " ---------------------------------------------------------------------
549        " Cost center mapping - ZJV_MAP_RCNTR-OP_KOSTL is CHAR12 and can hold
550        " EITHER an ALPHA-converted cost center OR an ALPHA-converted order
551        " number. Order-based lookup (via RORDNR) takes precedence; if it
552        " doesn't resolve, fall back to the direct cost center (RCNTR) lookup.
553        " ---------------------------------------------------------------------
554        CLEAR <fs_sub>-recv_kostl.
555
556        " 1) Try ORDER-based lookup first
557        IF <fs_sub>-rordnr IS NOT INITIAL.
558          CLEAR lv_key_kostl.
559          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
560            EXPORTING
561              input  = <fs_sub>-rordnr
562            IMPORTING
563              output = lv_key_kostl.
564
565          READ TABLE gt_rcntr_map INTO gs_rcntr_map
566            WITH KEY op_bukrs  = <fs_sub>-rbukrs
567                     op_kostl  = lv_key_kostl
568                     rec_bukrs = <fs_sub>-recv_bukrs.
569          IF sy-subrc = 0.
570            <fs_sub>-recv_kostl = gs_rcntr_map-rec_kostl.
571          ENDIF.
572        ENDIF.
573
574        " 2) Fall back to direct cost center (RCNTR) lookup if order lookup
575        "    didn't resolve one, or there was no order on the line at all.
576        IF <fs_sub>-recv_kostl IS INITIAL AND <fs_sub>-rcntr IS NOT INITIAL.
577          CLEAR lv_key_kostl.
578          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
579            EXPORTING
580              input  = <fs_sub>-rcntr
581            IMPORTING
582              output = lv_key_kostl.
583
584          READ TABLE gt_rcntr_map INTO gs_rcntr_map
585            WITH KEY op_bukrs  = <fs_sub>-rbukrs
586                     op_kostl  = lv_key_kostl
587                     rec_bukrs = <fs_sub>-recv_bukrs.
588          IF sy-subrc = 0.
589            <fs_sub>-recv_kostl = gs_rcntr_map-rec_kostl.
590          ENDIF.
591        ENDIF.
592
593        " 3) Flag if neither lookup produced a cost center but the line had
594        "    an order and/or a cost center to begin with.
595        IF <fs_sub>-recv_kostl IS INITIAL
596           AND ( <fs_sub>-rordnr IS NOT INITIAL OR <fs_sub>-rcntr IS NOT INITIAL ).
597          APPEND VALUE #(
598            msgty   = 'W'
599            message = |No cost center map found in ZJV_MAP_RCNTR for CoCd |
600                   && |{ <fs_sub>-rbukrs } (Order { <fs_sub>-rordnr }, |
601                   && |CC { <fs_sub>-rcntr })|
602          ) TO gt_alv_result.
603        ENDIF.
604        " ---------------------------------------------------------------------
605
606        " WBS mapping
607        IF <fs_sub>-rprojk IS NOT INITIAL.
608          READ TABLE gt_wbs_map INTO gs_wbs_map
609            WITH KEY op_bukrs  = <fs_sub>-rbukrs
610                     op_posid  = <fs_sub>-rprojk
611                     rec_bukrs = <fs_sub>-recv_bukrs.
612          IF sy-subrc = 0.
613            <fs_sub>-recv_posid = gs_wbs_map-rec_posid.
614          ENDIF.
615        ENDIF.
616
617        " Profit center mapping
618        IF <fs_sub>-rprctr IS NOT INITIAL.
619          READ TABLE gt_prctr_map INTO gs_prctr_map
620            WITH KEY op_bukrs  = <fs_sub>-rbukrs
621                     op_prctr  = <fs_sub>-rprctr
622                     rec_bukrs = <fs_sub>-recv_bukrs.
623          IF sy-subrc = 0.
624            <fs_sub>-recv_prctr = gs_prctr_map-rec_prctr.
625          ENDIF.
626        ENDIF.
627
628        " Currencies (currently hardcoded USD - swap in JV_AND_FI_CURRENCIES later)
629        IF <fs_sub>-rbukrs IS NOT INITIAL.
630          <fs_sub>-send_curr = 'USD'.
631        ENDIF.
632        " FIX #9: was checking rbukrs - should test the receiver's company code
633        IF <fs_sub>-recv_bukrs IS NOT INITIAL.
634          <fs_sub>-recv_curr = 'USD'.
635        ENDIF.
636
637        " Posting date = last day of the BUDAT month
638        CHECK <fs_sub>-budat IS NOT INITIAL.
639
640        CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
641          EXPORTING
642            day_in            = <fs_sub>-budat
643          IMPORTING
644            last_day_of_month = lv_last_day
645          EXCEPTIONS
646            day_in_no_date    = 1
647            OTHERS            = 2.
648
649        <fs_sub>-post_date = COND #( WHEN sy-subrc = 0
650                                     THEN lv_last_day
651                                     ELSE <fs_sub>-budat ).
652
653      ENDLOOP.
654    ENDFORM.
655
656
657
658    *----------------------------------------------------------------------*
659    * FORM: POST_DOCUMENTS
660    *----------------------------------------------------------------------*
661    FORM post_documents.
662      DATA: lv_curr_recv TYPE bukrs,
663            lv_linenum   TYPE i,
664            lv_amount    TYPE vgcur9,
665            lv_sum       TYPE vgcur9.
666      FIELD-SYMBOLS: <fs_sub> TYPE ty_subtotal.
667
668    *  SORT gt_subtotal BY recv_bukrs rjvnam rrecin racct.
669    *
670    *  CLEAR: lv_curr_recv, lv_linenum, gv_post_date.
671    *  REFRESH: gt_accountgl, gt_currencyamount.
672    *
673    **CALL FUNCTION 'FI_PERIOD_DETERMINE'
674    **
675    **  EXPORTING
676    **   i_budat              = gv_post_date
677    **   I_BUKRS              = ' '
678    **   I_RLDNR              = ' '
679    **   I_PERIV              = ' '
680    **   I_GJAHR              = 0000
681    **   I_MONAT              = 00
682    **   X_XMO16              = ' '
683    ** IMPORTING
684    **   E_GJAHR              = p_gjahr
685    **   E_MONAT              = p_poper
686    **   E_POPER              = p_poper
687    ** EXCEPTIONS
688    **   FISCAL_YEAR          = 1
689    **   PERIOD               = 2
690    **   PERIOD_VERSION       = 3
691    **   POSTING_PERIOD       = 4
692    **   SPECIAL_PERIOD       = 5
693    **   VERSION              = 6
694    **   POSTING_DATE         = 7
695    **   OTHERS               = 8.
696    *
697    **DATA gv_bukrs TYPE t001-bukrs.
698    *          .
699    *IF sy-subrc <> 0.
700    ** Implement suitable error handling here
701    *ENDIF.
702    *
703    *IF P_POPER < 3.
704    *  P_POPER = P_POPER + 9.
705    *ELSE.
706    *  P_POPER = P_POPER - 3.
707    *ENDIF.
708    *
709    *
710    *
711    *  LOOP AT gt_subtotal ASSIGNING <fs_sub>.
712    *    CHECK <fs_sub>-recv_bukrs IS NOT INITIAL.
713    *
714    *    " Co.Code break -> post the previous batch
715    **    IF lv_curr_recv <> <fs_sub>-recv_bukrs
716    **   AND lv_curr_recv IS NOT INITIAL.
717    **      PERFORM post_bapi_document USING lv_curr_recv.
718    **      REFRESH: gt_accountgl, gt_currencyamount.
719    **      lv_linenum   = 0.
720    **      CLEAR gv_post_date.
721    **    ENDIF.
722    **
723    **   CLEAR: lv_linenum.
724    **    DO 2 TIMES.
725    *
726    *
727    *
728    *
729    *    lv_curr_recv = <fs_sub>-recv_bukrs.
730    *    " FIX #13: capture posting date when we build the batch instead of
731    *    " re-reading inside POST_BAPI_DOCUMENT.
732    *    IF gv_post_date IS INITIAL.
733    *      gv_post_date = <fs_sub>-post_date.
734    *    ENDIF.
735    *
736    **    CALL FUNCTION 'FI_PERIOD_DETERMINE'
737    **  EXPORTING
738    **    i_budat = gv_post_date
739    **    i_bukrs = p_bukrs
740    **  IMPORTING
741    ***    e_gjahr = p_gjahr
742    **    e_poper = p_poper
743    **  EXCEPTIONS
744    **    OTHERS  = 1.
745    *
746    *    ADD 1 TO lv_linenum.
747    *
748    *    CLEAR gs_accountgl.
749    *    gs_accountgl-itemno_acc  = lv_linenum.
750    *    gs_accountgl-gl_account  = <fs_sub>-recv_saknr.
751    *    gs_accountgl-comp_code   = <fs_sub>-recv_bukrs.
752    *    gs_accountgl-costcenter  = <fs_sub>-recv_kostl.
753    *    gs_accountgl-orderid     = <fs_sub>-rordnr.
754    *    gs_accountgl-wbs_element = <fs_sub>-recv_posid.
755    *    gs_accountgl-profit_ctr  = <fs_sub>-recv_prctr.
756    **    gs_accountgl-func_area = 'PT01'.
757    *    gs_accountgl-FUNC_AREA_LONG = 'OPG000'.
758    *
759    *    " FIX #1: was '16' (year-end special period) - use the period parameter
760    *    gs_accountgl-fis_period  = p_poper.
761    *    " FIX #7: duplicate fisc_year assignment removed
762    *    gs_accountgl-fisc_year   = p_gjahr.
763    *
764    *    " FIX #2 + #3: Derive Debit/Credit from sign of KSL and feed an
765    *    " absolute amount to the BAPI. Hardcoding 'H' would leave the
766    *    " document unbalanced and BAPI returns "Balance in trans.curr. <> 0".
767    **    READ TABLE gt_accountgl into data(ls_accountgl) with key comp_code = gs_accountgl-comp_code costcenter = gs_accountgl-costcenter gl_account = gs_accountgl-gl_account.
768    **    IF sy-subrc is INITIAL.
769    **      gs_accountgl-de_cre_ind = 'S'.   " Credit
770    **      lv_amount               = lv_sum * -1.
771    **    else.
772    *    gs_accountgl-de_cre_ind = 'S'.   " Debit
773    *    lv_amount               = <fs_sub>-ksl.
774    *    lv_sum = lv_sum + lv_amount.
775    **    ENDIF.
776    *
777    *
778    *    " FIX #8: doc_type belongs on the header, not on each line - removed
779    *    " FIX #4: func_area '0001' is rarely a real value - leave blank or
780    *    " derive from cost object via substitution. Uncomment & map if needed.
781    *    " gs_accountgl-func_area = '0001'.
782    *
783    *    APPEND gs_accountgl TO gt_accountgl.
784    *
785    *    CLEAR gs_currencyamount.
786    *    gs_currencyamount-itemno_acc = lv_linenum.
787    *    gs_currencyamount-currency   = <fs_sub>-recv_curr.
788    *    gs_currencyamount-amt_doccur = lv_amount.
789    *    APPEND gs_currencyamount TO gt_currencyamount.
790    **    ENDDO.
791    *
792    *  ENDLOOP.
793    **  READ TABLE gt_accountgl INTO gs_accountgl INDEX 1.
794    **  IF sy-subrc IS INITIAL.
795    **    ADD 1 TO lv_linenum.
796    **    gs_accountgl-itemno_acc  = lv_linenum.
797    **    gs_accountgl-de_cre_ind = 'H'.
798    **    READ TABLE gt_jv_map INTO DATA(ls_jv_map) INDEX 1.
799    **    gs_accountgl-gl_account = ls_jv_map-offset_gl.
800    **    APPEND gs_accountgl TO gt_accountgl.
801    **
802    **    READ TABLE gt_currencyamount INTO gs_currencyamount INDEX 1.
803    **    gs_currencyamount-itemno_acc = lv_linenum.
804    **    gs_currencyamount-currency   = <fs_sub>-recv_curr.
805    **    gs_currencyamount-amt_doccur = lv_sum * -1.
806    **    APPEND gs_currencyamount TO gt_currencyamount.
807    **
808    **  ENDIF.
809    **  PERFORM post_bapi_document USING lv_curr_recv.
810    **  CLEAR: gt_currencyamount, gs_doc_header, gt_return, gt_accountgl.
811    *
812    **  READ TABLE gt_accountgl INTO gs_accountgl INDEX 1.
813    **  IF sy-subrc IS INITIAL.
814    **    ADD 1 TO lv_linenum.
815    **
816    **    READ TABLE gt_jv_map INTO DATA(ls_jv_map) INDEX 1.
817    **
818    **    " FIX: offsetting line now posts as a VENDOR line (account type K,
819    **    " de_cre_ind 'H') so it resolves to posting key 31 (Invoice/Credit
820    **    " vendor) instead of GL posting key 50. Per-subtotal lines above
821    **    " are unchanged and still post as GL (PK 40).
822    **    CLEAR gs_accountpayable.
823    **    gs_accountpayable-itemno_acc = lv_linenum.
824    **    gs_accountpayable-vendor_no  = ls_jv_map-offset_gl. " rename if field differs
825    **    gs_accountpayable-comp_code  = lv_curr_recv.
826    ***    gs_accountpayable-de_cre_ind = 'H'.
827    **    APPEND gs_accountpayable TO gt_accountpayable.
828    **
829    **    CLEAR gs_currencyamount.
830    **    gs_currencyamount-itemno_acc = lv_linenum.
831    **    gs_currencyamount-currency   = <fs_sub>-recv_curr.
832    **    gs_currencyamount-amt_doccur = lv_sum * -1.
833    **    APPEND gs_currencyamount TO gt_currencyamount.
834    **
835    **  ENDIF.
836    *
837    *READ TABLE gt_accountgl INTO gs_accountgl INDEX 1.
838    *  IF sy-subrc IS INITIAL.
839    *    ADD 1 TO lv_linenum.
840    *    READ TABLE gt_jv_map INTO DATA(ls_jv_map) INDEX 1.
841    *
842    *    IF ls_jv_map-type = 'V'.   " <-- confirm actual domain value for "Vendor"
843    *      " Offset account is a VENDOR -> post via BAPIACAP09 (PK 31/21)
844    *      CLEAR gs_accountpayable.
845    *      gs_accountpayable-itemno_acc = lv_linenum.
846    *      gs_accountpayable-vendor_no  = ls_jv_map-offset_gl.
847    *      gs_accountpayable-comp_code  = lv_curr_recv.
848    **      gs_accountpayable-de_cre_ind = 'H'.
849    *      APPEND gs_accountpayable TO gt_accountpayable.
850    *    ELSE.
851    *      " Offset account is a GL account -> post via BAPIACGL09 (PK 40/50)
852    *      CLEAR gs_accountgl.
853    *      gs_accountgl-itemno_acc = lv_linenum.
854    *      gs_accountgl-gl_account = ls_jv_map-offset_gl.
855    *      gs_accountgl-comp_code  = lv_curr_recv.
856    *      gs_accountgl-de_cre_ind = 'H'.
857    *      gs_accountgl-fis_period = p_poper.
858    *      gs_accountgl-fisc_year  = p_gjahr.
859    *      APPEND gs_accountgl TO gt_accountgl.
860    *    ENDIF.
861    *
862    *    CLEAR gs_currencyamount.
863    *    gs_currencyamount-itemno_acc = lv_linenum.
864    *    gs_currencyamount-currency   = <fs_sub>-recv_curr.
865    *    gs_currencyamount-amt_doccur = lv_sum * -1.
866    *    APPEND gs_currencyamount TO gt_currencyamount.
867    *  ENDIF.
868
869    SORT gt_subtotal BY recv_bukrs rjvnam rrecin racct.
870
871      CLEAR: lv_curr_recv, lv_linenum, gv_post_date, lv_sum.
872      REFRESH: gt_accountgl, gt_currencyamount, gt_accountpayable.
873
874      IF p_poper < 3.
875        p_poper = p_poper + 9.
876      ELSE.
877        p_poper = p_poper - 3.
878      ENDIF.
879
880      LOOP AT gt_subtotal ASSIGNING <fs_sub>.
881        CHECK <fs_sub>-recv_bukrs IS NOT INITIAL.
882
883        lv_curr_recv = <fs_sub>-recv_bukrs.
884
885        " FIX #13: capture posting date when we build the batch instead of
886        " re-reading inside POST_BAPI_DOCUMENT.
887        IF gv_post_date IS INITIAL.
888          gv_post_date = <fs_sub>-post_date.
889        ENDIF.
890
891        ADD 1 TO lv_linenum.
892
893        CLEAR gs_accountgl.
894        gs_accountgl-itemno_acc  = lv_linenum.
895        gs_accountgl-gl_account  = <fs_sub>-recv_saknr.
896        gs_accountgl-comp_code   = <fs_sub>-recv_bukrs.
897        gs_accountgl-costcenter  = <fs_sub>-recv_kostl.
898    *    gs_accountgl-orderid     = <fs_sub>-rordnr.
899        gs_accountgl-wbs_element = <fs_sub>-recv_posid.
900        gs_accountgl-profit_ctr  = <fs_sub>-recv_prctr.
901        gs_accountgl-func_area_long = 'OPG000'.
902
903        " FIX #1: was '16' (year-end special period) - use the period parameter
904        gs_accountgl-fis_period  = p_poper.
905        " FIX #7: duplicate fisc_year assignment removed
906        gs_accountgl-fisc_year   = p_gjahr.
907
908        " FIX #2 + #3 + NEW: Derive Debit/Credit from the sign of KSL and feed
909        " an ABSOLUTE amount to the BAPI. Hardcoding 'S' or 'H' would leave the
910        " document unbalanced whenever a line's natural sign flips, and now
911        " that we can have GL (40/50) OR Vendor (21/31) offsets, the indicator
912        " must be derived, not hardcoded, on both the detail lines and the
913        " offset line.
914        IF <fs_sub>-ksl >= 0.
915          gs_accountgl-de_cre_ind = 'S'.   " Debit
916        ELSE.
917          gs_accountgl-de_cre_ind = 'H'.   " Credit
918        ENDIF.
919
920        " Keep a SIGNED running total - this is what the offset line balances
921        " against. Do NOT take abs() here, only when writing amt_doccur.
922        lv_sum = lv_sum + <fs_sub>-ksl.
923
924        APPEND gs_accountgl TO gt_accountgl.
925
926        CLEAR gs_currencyamount.
927        gs_currencyamount-itemno_acc = lv_linenum.
928        gs_currencyamount-currency   = <fs_sub>-recv_curr.
929        gs_currencyamount-amt_doccur = <fs_sub>-ksl.   " BAPI requires unsigned amount
930        APPEND gs_currencyamount TO gt_currencyamount.
931
932      ENDLOOP.
933
934      " ---- Offset line: balances the whole batch, can be GL or Vendor ----
935    " ---- Offset line: balances the whole batch, can be GL or Vendor ----
936      READ TABLE gt_accountgl INTO gs_accountgl INDEX 1.
937      IF sy-subrc IS INITIAL.
938        ADD 1 TO lv_linenum.
939        READ TABLE gt_jv_map INTO DATA(ls_jv_map) INDEX 1.  "#EC CI_NOORDER
940
941        DATA: lv_offset_amt TYPE vgcur9,
942              lv_offset_ind TYPE bapiacgl09-de_cre_ind.
943
944        lv_offset_amt = lv_sum * -1.        " signed balancing amount
945
946        IF ls_jv_map-type = 'V'.            " <-- confirm actual domain value for "Vendor"
947          " Offset account is a VENDOR -> post via BAPIACAP09.
948          " No DE_CRE_IND field here - sign lives in amt_doccur itself:
949          " negative = credit/invoice (PK31), positive = debit (PK21).
950          CLEAR gs_accountpayable.
951          gs_accountpayable-itemno_acc = lv_linenum.
952          gs_accountpayable-vendor_no  = ls_jv_map-offset_gl.
953          gs_accountpayable-comp_code  = lv_curr_recv.
954          gs_accountpayable-profit_ctr  = 'CLCP5NB02P'.
955          APPEND gs_accountpayable TO gt_accountpayable.
956
957          CLEAR gs_currencyamount.
958          gs_currencyamount-itemno_acc = lv_linenum.
959          gs_currencyamount-currency   = <fs_sub>-recv_curr.
960          gs_currencyamount-amt_doccur = lv_offset_amt.   " SIGNED - do not take abs() for vendor lines
961          APPEND gs_currencyamount TO gt_currencyamount.
962
963        ELSE.
964          " Offset account is a GL account -> post via BAPIACGL09.
965          " GL lines DO need DE_CRE_IND, and amt_doccur must be unsigned.
966          IF lv_offset_amt >= 0.
967            lv_offset_ind = 'S'.
968          ELSE.
969            lv_offset_ind = 'H'.
970          ENDIF.
971
972          CLEAR gs_accountgl.
973          gs_accountgl-itemno_acc = lv_linenum.
974          gs_accountgl-gl_account = ls_jv_map-offset_gl.
975          gs_accountgl-comp_code  = lv_curr_recv.
976          gs_accountgl-fis_period = p_poper.
977          gs_accountgl-fisc_year  = p_gjahr.
978          gs_accountgl-de_cre_ind = lv_offset_ind.
979          APPEND gs_accountgl TO gt_accountgl.
980
981          CLEAR gs_currencyamount.
982          gs_currencyamount-itemno_acc = lv_linenum.
983          gs_currencyamount-currency   = <fs_sub>-recv_curr.
984          gs_currencyamount-amt_doccur = conv #( lv_offset_amt ).   " unsigned, sign lives in de_cre_ind
985          APPEND gs_currencyamount TO gt_currencyamount.
986        ENDIF.
987      ENDIF.
988
989
990
991
992
993
994      PERFORM post_bapi_document USING lv_curr_recv.
995      CLEAR: gt_currencyamount, gs_doc_header, gt_return, gt_accountgl, gt_accountpayable.
996
997      IF lv_curr_recv IS NOT INITIAL AND gt_accountgl IS NOT INITIAL.
998
999      ENDIF.
1000   ENDFORM.
1001
1002
1003
1004
1005   *----------------------------------------------------------------------*
1006   * FORM: POST_BAPI_DOCUMENT
1007   *----------------------------------------------------------------------*
1008   FORM post_bapi_document USING lv_recv_bukrs TYPE bukrs.
1009     DATA: lv_has_error TYPE abap_bool.
1010
1011     CLEAR gs_doc_header.
1012     gs_doc_header-bus_act    = 'RFBU'.
1013     gs_doc_header-username   = sy-uname.
1014     gs_doc_header-comp_code  = lv_recv_bukrs.
1015     gs_doc_header-doc_date   = gv_post_date.
1016     gs_doc_header-pstng_date = gv_post_date.
1017     gs_doc_header-trans_date = gv_post_date.
1018     gs_doc_header-doc_type   = 'CL'.
1019     gs_doc_header-ref_doc_no = 'ZR_JV_POST'.
1020     gs_doc_header-header_txt = 'JV Transfer Auto Post'.
1021     gs_doc_header-fis_period = p_poper.
1022     gs_doc_header-fisc_year  = p_gjahr.
1023
1024     REFRESH gt_return.
1025
1026   *  CALL FUNCTION 'BAPI_ACC_DOCUMENT_CHECK'
1027   *    EXPORTING
1028   *      documentheader = gs_doc_header
1029   *    TABLES
1030   *      accountgl      = gt_accountgl
1031   *      currencyamount = gt_currencyamount
1032   *      return         = gt_return.
1033     CALL FUNCTION 'BAPI_ACC_DOCUMENT_CHECK' "#EC CI_USAGE_OK[2628704]
1034   "#EC CI_USAGE_OK[2438131]
1035       EXPORTING
1036         documentheader = gs_doc_header
1037       TABLES
1038         accountgl      = gt_accountgl
1039         accountpayable = gt_accountpayable
1040         currencyamount = gt_currencyamount
1041         return         = gt_return.
1042
1043
1044
1045
1046     " If CHECK already returned errors, do not call POST
1047     lv_has_error = abap_false.
1048     LOOP AT gt_return INTO gs_return
1049          WHERE type = 'E' OR type = 'A'.
1050       lv_has_error = abap_true.
1051       EXIT.
1052     ENDLOOP.
1053
1054     IF lv_has_error = abap_false.
1055       CLEAR: gv_obj_type, gv_obj_key, gv_obj_sys.
1056   *    CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
1057   *      EXPORTING
1058   *        documentheader = gs_doc_header
1059   *      IMPORTING
1060   *        obj_type       = gv_obj_type
1061   *        obj_key        = gv_obj_key
1062   *        obj_sys        = gv_obj_sys
1063   *      TABLES
1064   *        accountgl      = gt_accountgl
1065   *        currencyamount = gt_currencyamount
1066   *        return         = gt_return.
1067       CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST' "#EC CI_USAGE_OK[2628704]
1068   "#EC CI_USAGE_OK[2438131]
1069         EXPORTING
1070           documentheader = gs_doc_header
1071         IMPORTING
1072           obj_type       = gv_obj_type
1073           obj_key        = gv_obj_key
1074           obj_sys        = gv_obj_sys
1075         TABLES
1076           accountgl      = gt_accountgl
1077           accountpayable = gt_accountpayable
1078           currencyamount = gt_currencyamount
1079           return         = gt_return.
1080
1081       LOOP AT gt_return INTO gs_return
1082            WHERE type = 'E' OR type = 'A'.
1083         lv_has_error = abap_true.
1084         EXIT.
1085       ENDLOOP.
1086     ENDIF.
1087
1088     " Commit / Rollback based on final error state
1089     IF lv_has_error = abap_false AND gv_test_run = abap_false.
1090       CALL FUNCTION 'BAPI_TRANSACTION_COMMIT' EXPORTING wait = 'X'.
1091       gs_jv_map_trf-test_run = 'X'.
1092       INSERT ZJV_MAP_TRF FROM gs_jv_map_trf.
1093     ELSE.
1094       CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
1095     ENDIF.
1096
1097     " FIX #10: write the ALV log AFTER the final error state is known so
1098     " every row of a successful posting shows the correct doc number, and
1099     " no row of a failed posting shows a doc number.
1100     LOOP AT gt_return INTO gs_return.
1101       CHECK gs_return-type = 'E'.
1102       CLEAR gs_alv_result.
1103       gs_alv_result-msgty     = gs_return-type.
1104       gs_alv_result-comp_code = lv_recv_bukrs.
1105       gs_alv_result-doc_number = COND #(
1106           WHEN lv_has_error = abap_false AND gv_test_run = abap_false
1107           THEN gv_obj_key
1108           ELSE space ).
1109       gs_alv_result-message   = gs_return-message.
1110       APPEND gs_alv_result TO gt_alv_result.
1111     ENDLOOP.
1112
1113     IF gv_test_run = abap_true.
1114       CLEAR gs_alv_result.
1115       gs_alv_result-msgty     = 'I'.
1116       gs_alv_result-comp_code = lv_recv_bukrs.
1117       gs_alv_result-message   = |Test Run - No FI document created for company code { lv_recv_bukrs }|.
1118       APPEND gs_alv_result TO gt_alv_result.
1119     ENDIF.
1120
1121   ENDFORM.
1122
1123   *----------------------------------------------------------------------*
1124   * FORM: DISPLAY_SUMMARY
1125   *----------------------------------------------------------------------*
1126   FORM display_summary.
1127
1128     DATA: lo_alv     TYPE REF TO cl_salv_table,
1129           lo_columns TYPE REF TO cl_salv_columns_table,
1130           lo_column  TYPE REF TO cl_salv_column_table,
1131           lo_display TYPE REF TO cl_salv_display_settings,
1132           lo_funcs   TYPE REF TO cl_salv_functions_list.
1133
1134     IF gt_alv_result IS INITIAL.
1135       APPEND VALUE #( msgty   = 'I'
1136                       message = 'Run completed - no result rows generated'
1137                     ) TO gt_alv_result.
1138     ENDIF.
1139
1140     TRY.
1141         cl_salv_table=>factory(
1142           IMPORTING
1143             r_salv_table = lo_alv
1144           CHANGING
1145             t_table      = gt_alv_result ).
1146       CATCH cx_salv_msg INTO DATA(lx_msg).
1147         MESSAGE |ALV Error: { lx_msg->get_text( ) }| TYPE 'E'.
1148         RETURN.
1149     ENDTRY.
1150
1151     lo_funcs = lo_alv->get_functions( ).
1152     lo_funcs->set_all( abap_true ).
1153
1154     lo_display = lo_alv->get_display_settings( ).
1155     lo_display->set_list_header( 'JV Transfer Posting Results' ).
1156     lo_display->set_striped_pattern( abap_true ).
1157
1158     lo_columns = lo_alv->get_columns( ).
1159     lo_columns->set_optimize( abap_true ).
1160
1161     TRY.
1162         lo_column ?= lo_columns->get_column( 'MSGTY' ).
1163         lo_column->set_long_text( 'Type' ).
1164         lo_column->set_medium_text( 'Type' ).
1165         lo_column->set_short_text( 'Type' ).
1166         lo_column->set_output_length( 5 ).
1167       CATCH cx_salv_not_found.                            "#EC NO_HANDLER
1168     ENDTRY.
1169
1170     TRY.
1171         lo_column ?= lo_columns->get_column( 'COMP_CODE' ).
1172         lo_column->set_long_text( 'Company Code' ).
1173         lo_column->set_medium_text( 'Comp.Code' ).
1174         lo_column->set_short_text( 'CoCd' ).
1175         lo_column->set_output_length( 10 ).
1176       CATCH cx_salv_not_found.                            "#EC NO_HANDLER
1177     ENDTRY.
1178
1179     TRY.
1180         lo_column ?= lo_columns->get_column( 'DOC_NUMBER' ).
1181         lo_column->set_long_text( 'Document Number' ).
1182         lo_column->set_medium_text( 'Doc. Number' ).
1183         lo_column->set_short_text( 'Doc.No.' ).
1184         lo_column->set_output_length( 15 ).
1185       CATCH cx_salv_not_found.                            "#EC NO_HANDLER
1186     ENDTRY.
1187
1188     TRY.
1189         lo_column ?= lo_columns->get_column( 'MESSAGE' ).
1190         lo_column->set_long_text( 'Message' ).
1191         lo_column->set_medium_text( 'Message' ).
1192         lo_column->set_short_text( 'Message' ).
1193         lo_column->set_output_length( 120 ).
1194       CATCH cx_salv_not_found.                            "#EC NO_HANDLER
1195     ENDTRY.
1196
1197     lo_alv->display( ).
1198   ENDFORM.
1199
1200
1201
1202
1203
1204
1205
1206
1207   **&---------------------------------------------------------------------*
1208   **& Report  ZR_JV_POST
1209   **& JV Transfer: Colombia OCV->OVL | Cutback | NB | Corporate Items
1210   **& Z Tables:
1211   **&   ZJV_MAP_COCODE - JV/Recovery Indicator -> Receiving Co.Code
1212   **&   ZJV_MAP_GL     - GL Account Mapping
1213   **&   ZJV_MAP_RCNTR  - Cost Center Mapping
1214   **&   ZJV_MAP_WBS    - WBS Element Mapping
1215   **&   ZJV_MAP_PRCTR  - Profit Center Mapping
1216   **& Source Table:
1217   **&   JVSO1          - JV Accounting (Ledgers 4A / 4C)
1218   **&---------------------------------------------------------------------*
1219   *REPORT zr_jv_post.
1220   *
1221   **----------------------------------------------------------------------*
1222   ** TABLES
1223   **----------------------------------------------------------------------*
1224   *TABLES: jvso1.
1225   *
1226   **----------------------------------------------------------------------*
1227   ** TYPES
1228   **----------------------------------------------------------------------*
1229   *" ZJV_MAP_COCODE: OP_BUKRS/OP_VNAME/OP_RECID -> REC_BUKRS/REC_VNAME/REC_RECID
1230   *TYPES: BEGIN OF ty_jv_map,
1231   *         op_bukrs  TYPE bukrs,
1232   *         op_vname  TYPE jv_name,
1233   *         op_recid  TYPE jv_recind,
1234   *         rec_bukrs TYPE bukrs,
1235   *         rec_vname TYPE jv_name,
1236   *         rec_recid TYPE jv_recind,
1237   *       END OF ty_jv_map.
1238   *
1239   *" ZJV_MAP_GL: OP_BUKRS/OP_SAKNR -> REC_BUKRS/REC_SAKNR
1240   *TYPES: BEGIN OF ty_gl_map,
1241   *         op_bukrs  TYPE bukrs,
1242   *         op_saknr  TYPE saknr,
1243   *         rec_bukrs TYPE bukrs,
1244   *         rec_saknr TYPE saknr,
1245   *       END OF ty_gl_map.
1246   *
1247   *" ZJV_MAP_RCNTR: OP_BUKRS/OP_KOSTL -> REC_BUKRS/REC_KOSTL
1248   *TYPES: BEGIN OF ty_rcntr_map,
1249   *         op_bukrs  TYPE bukrs,
1250   *         op_kostl  TYPE kostl,
1251   *         rec_bukrs TYPE bukrs,
1252   *         rec_kostl TYPE kostl,
1253   *       END OF ty_rcntr_map.
1254   *
1255   *" ZJV_MAP_WBS: OP_BUKRS/OP_POSID -> REC_BUKRS/REC_POSID
1256   *TYPES: BEGIN OF ty_wbs_map,
1257   *         op_bukrs  TYPE bukrs,
1258   *         op_posid  TYPE ps_posid,
1259   *         rec_bukrs TYPE bukrs,
1260   *         rec_posid TYPE ps_posid,
1261   *       END OF ty_wbs_map.
1262   *
1263   *" ZJV_MAP_PRCTR: OP_BUKRS/OP_PRCTR -> REC_BUKRS/REC_PRCTR
1264   *TYPES: BEGIN OF ty_prctr_map,
1265   *         op_bukrs  TYPE bukrs,
1266   *         op_prctr  TYPE prctr,
1267   *         rec_bukrs TYPE bukrs,
1268   *         rec_prctr TYPE prctr,
1269   *       END OF ty_prctr_map.
1270   *
1271   *" JVSO1 line items (Company Code = RBUKRS)
1272   *TYPES: BEGIN OF ty_jvso1,
1273   *         rldnr  TYPE rldnr,
1274   *         rbukrs TYPE bukrs,
1275   *         rrcty  TYPE rrcty,
1276   *         rvers  TYPE rvers,
1277   *         ryear  TYPE gjahr,
1278   *         poper  TYPE poper,
1279   *         rjvnam TYPE jv_name,
1280   *         rrecin TYPE jv_recind,
1281   *         racct  TYPE racct,
1282   *         regrou TYPE jv_egroup,
1283   *         rcntr  TYPE kostl,
1284   *         rordnr TYPE aufnr,
1285   *         rprojk TYPE ps_psp_pnr,
1286   *         rprctr TYPE prctr,
1287   *         budat  TYPE budat,
1288   *         tsl    TYPE VTCUR9,
1289   *         hsl    TYPE VLCUR9,
1290   *         ksl    TYPE VGCUR9,
1291   *       END OF ty_jvso1.
1292   *
1293   *" Aggregated Subtotal line
1294   *TYPES: BEGIN OF ty_subtotal,
1295   *         rbukrs      TYPE bukrs,
1296   *         rjvnam      TYPE jv_name,
1297   *         rrecin      TYPE jv_recind,
1298   *         racct       TYPE racct,
1299   *         rcntr       TYPE kostl,
1300   *         rordnr      TYPE aufnr,
1301   *         rprojk      TYPE ps_psp_pnr,
1302   *         rprctr      TYPE prctr,
1303   *         budat       TYPE budat,
1304   *         tsl         TYPE vtcur9,
1305   *         hsl         TYPE vlcur9,
1306   *         ksl         TYPE vgcur9,
1307   *         recv_bukrs  TYPE bukrs,
1308   *         recv_saknr  TYPE saknr,
1309   *         recv_kostl  TYPE kostl,
1310   *         recv_posid  TYPE ps_posid,
1311   *         recv_prctr  TYPE prctr,
1312   *         send_curr   TYPE waers,
1313   *         recv_curr   TYPE waers,
1314   *         post_date   TYPE budat,
1315   *       END OF ty_subtotal.
1316   *
1317   *" ALV Result Table Type
1318   *TYPES: BEGIN OF ty_alv_result,
1319   *         msgty       TYPE bapi_mtype,       " S / E / W / I
1320   *         comp_code   TYPE bukrs,            " Receiving Company Code
1321   *         doc_number  TYPE belnr_d,          " Posted Document Number
1322   *         message     TYPE string,           " Message Text
1323   *       END OF ty_alv_result.
1324   *
1325   **----------------------------------------------------------------------*
1326   ** INTERNAL TABLES
1327   **----------------------------------------------------------------------*
1328   *DATA: gt_jv_map    TYPE TABLE OF ty_jv_map,
1329   *      gt_gl_map    TYPE TABLE OF ty_gl_map,
1330   *      gt_rcntr_map TYPE TABLE OF ty_rcntr_map,
1331   *      gt_wbs_map   TYPE TABLE OF ty_wbs_map,
1332   *      gt_prctr_map TYPE TABLE OF ty_prctr_map,
1333   *      gt_jvso1     TYPE TABLE OF ty_jvso1,
1334   *      gt_subtotal  TYPE TABLE OF ty_subtotal,
1335   *      gt_alv_result TYPE TABLE OF ty_alv_result.   " ALV Results.
1336   *
1337   **----------------------------------------------------------------------*
1338   ** WORK AREAS
1339   **----------------------------------------------------------------------*
1340   *DATA: gs_jvso1      TYPE ty_jvso1,
1341   *      gs_jv_map     TYPE ty_jv_map,
1342   *      gs_gl_map     TYPE ty_gl_map,
1343   *      gs_rcntr_map  TYPE ty_rcntr_map,
1344   *      gs_wbs_map    TYPE ty_wbs_map,
1345   *      gs_prctr_map  TYPE ty_prctr_map,
1346   *      gs_alv_result TYPE ty_alv_result.
1347   *
1348   **----------------------------------------------------------------------*
1349   ** BAPI Structures
1350   **----------------------------------------------------------------------*
1351   *DATA: gs_doc_header     TYPE bapiache09,
1352   *      gt_accountgl      TYPE TABLE OF bapiacgl09,
1353   *      gt_currencyamount TYPE TABLE OF bapiaccr09,
1354   *      gt_return         TYPE TABLE OF bapiret2,
1355   *      gs_accountgl      TYPE bapiacgl09,
1356   *      gs_currencyamount TYPE bapiaccr09,
1357   *      gs_return         TYPE bapiret2,
1358   *      gv_obj_type       TYPE bapiache09-obj_type,
1359   *      gv_obj_key        TYPE bapiache09-obj_key,
1360   *      gv_obj_sys        TYPE bapiache09-obj_sys.
1361   *
1362   **----------------------------------------------------------------------*
1363   ** VARIABLES
1364   **----------------------------------------------------------------------*
1365   *DATA: gv_test_run  TYPE abap_bool,
1366   *      gv_lines_ok  TYPE i,
1367   *      gv_lines_err TYPE i,
1368   *      lt_racct TYPE RANGE OF saknr,
1369   *      ls_racct LIKE LINE OF lt_racct.
1370   *
1371   **----------------------------------------------------------------------*
1372   ** SELECTION SCREEN
1373   **----------------------------------------------------------------------*
1374   *SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE sel_par.
1375   *  PARAMETERS:
1376   *    p_bukrs TYPE bukrs OBLIGATORY,
1377   *    p_gjahr TYPE gjahr OBLIGATORY,
1378   *    p_poper TYPE poper OBLIGATORY.
1379   *SELECTION-SCREEN END OF BLOCK b1.
1380   *
1381   *SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE proc_op.
1382   *  PARAMETERS:
1383   *    p_test TYPE abap_bool AS CHECKBOX DEFAULT 'X'.
1384   *SELECTION-SCREEN END OF BLOCK b2.
1385   *
1386   **----------------------------------------------------------------------*
1387   ** INITIALIZATION
1388   **----------------------------------------------------------------------*
1389   *INITIALIZATION.
1390   *  sel_par = 'Selection Parameters'.
1391   *  proc_op = 'Processing Options'.
1392   *
1393   **----------------------------------------------------------------------*
1394   ** START-OF-SELECTION
1395   **----------------------------------------------------------------------*
1396   *START-OF-SELECTION.
1397   *
1398   *  gv_test_run = p_test.
1399   *
1400   *  PERFORM load_mapping_tables.
1401   *  PERFORM read_jvso1.
1402   *  PERFORM aggregate_subtotals.
1403   *  PERFORM apply_mappings.
1404   **  PERFORM set_posting_dates.
1405   *  PERFORM post_documents.
1406   *  PERFORM display_summary.
1407   *
1408   **----------------------------------------------------------------------*
1409   ** FORM: LOAD_MAPPING_TABLES
1410   **----------------------------------------------------------------------*
1411   *FORM load_mapping_tables.
1412   *
1413   *  SELECT op_bukrs op_vname op_recid rec_bukrs rec_vname rec_recid
1414   *    FROM zjv_map_cocode
1415   *    INTO TABLE gt_jv_map
1416   *    WHERE op_bukrs = p_bukrs.
1417   *    IF sy-subrc = 0.
1418   *    ENDIF.
1419   *
1420   *  SELECT op_bukrs op_saknr rec_bukrs rec_saknr
1421   *    FROM zjv_map_gl
1422   *    INTO TABLE gt_gl_map
1423   *    WHERE op_bukrs = p_bukrs.
1424   *    IF sy-subrc = 0.
1425   *CLEAR lt_racct.
1426   *LOOP AT gt_gl_map INTO DATA(ls_gl).
1427   *  CLEAR ls_racct.
1428   *  ls_racct-sign   = 'I'.
1429   *  ls_racct-option = 'EQ'.
1430   *  ls_racct-low    = ls_gl-op_saknr.
1431   *  APPEND ls_racct TO lt_racct.
1432   *ENDLOOP.
1433   *    ENDIF.
1434   *
1435   *  SELECT op_bukrs op_kostl rec_bukrs rec_kostl
1436   *    FROM zjv_map_rcntr
1437   *    INTO TABLE gt_rcntr_map
1438   *    WHERE op_bukrs = p_bukrs.
1439   *    IF sy-subrc = 0.
1440   *    ENDIF.
1441   *
1442   *  SELECT op_bukrs op_posid rec_bukrs rec_posid
1443   *    FROM zjv_map_wbs
1444   *    INTO TABLE gt_wbs_map
1445   *    WHERE op_bukrs = p_bukrs.
1446   *    IF sy-subrc = 0.
1447   *    ENDIF.
1448   *
1449   *  SELECT op_bukrs op_prctr rec_bukrs rec_prctr
1450   *    FROM zjv_map_prctr
1451   *    INTO TABLE gt_prctr_map
1452   *    WHERE op_bukrs = p_bukrs.
1453   *    IF sy-subrc = 0.
1454   *    ENDIF.
1455   *ENDFORM.
1456   *
1457   **----------------------------------------------------------------------*
1458   ** FORM: READ_JVSO1
1459   **----------------------------------------------------------------------*
1460   *FORM read_jvso1.
1461   *
1462   *IF gt_jv_map IS NOT INITIAL.
1463   *  SELECT rldnr, rbukrs, rrcty, rvers, ryear, poper, rjvnam, rrecin, racct,
1464   *         regrou, rcntr, rordnr, rprojk, rprctr, budat, tsl, hsl, ksl
1465   *    FROM jvso1
1466   *    INTO TABLE @gt_jvso1
1467   *    FOR ALL ENTRIES IN @gt_jv_map
1468   *    WHERE rldnr  IN ('4A', '4C')
1469   *      AND rrcty  =  '0'
1470   *      AND rvers  =  '001'
1471   *      AND ryear  =  @p_gjahr
1472   *      AND poper  =  @p_poper AND rjvnam = @gt_jv_map-op_vname AND rrecin = @gt_jv_map-op_recid
1473   *    AND racct IN @lt_racct.
1474   *  IF gt_jvso1 IS INITIAL.
1475   *    MESSAGE 'No JVSO1 records found' TYPE 'E'.
1476   *  ENDIF.
1477   *  ENDIF.
1478   *ENDFORM.
1479   *
1480   **----------------------------------------------------------------------*
1481   ** FORM: AGGREGATE_SUBTOTALS
1482   **----------------------------------------------------------------------*
1483   *FORM aggregate_subtotals.
1484   *  DATA: ls_sub TYPE ty_subtotal.
1485   *  FIELD-SYMBOLS: <fs_sub> TYPE ty_subtotal.
1486   *
1487   *  SORT gt_jvso1 BY rbukrs rjvnam rrecin racct rcntr rordnr rprojk rprctr.
1488   *
1489   *  LOOP AT gt_jvso1 INTO gs_jvso1.
1490   *    READ TABLE gt_subtotal ASSIGNING <fs_sub>
1491   *      WITH KEY rbukrs = gs_jvso1-rbukrs
1492   *               rjvnam = gs_jvso1-rjvnam
1493   *               rrecin = gs_jvso1-rrecin
1494   *               racct  = gs_jvso1-racct
1495   *               rcntr  = gs_jvso1-rcntr
1496   *               rordnr = gs_jvso1-rordnr
1497   *               rprojk = gs_jvso1-rprojk
1498   *               rprctr = gs_jvso1-rprctr.
1499   *    IF sy-subrc = 0.
1500   *      <fs_sub>-tsl = <fs_sub>-tsl + gs_jvso1-tsl.
1501   *      <fs_sub>-hsl = <fs_sub>-hsl + gs_jvso1-hsl.
1502   *      <fs_sub>-ksl = <fs_sub>-ksl + gs_jvso1-ksl.
1503   *    ELSE.
1504   *      CLEAR ls_sub.
1505   *      ls_sub-rbukrs = gs_jvso1-rbukrs.
1506   *      ls_sub-rjvnam = gs_jvso1-rjvnam.
1507   *      ls_sub-rrecin = gs_jvso1-rrecin.
1508   *      ls_sub-racct  = gs_jvso1-racct.
1509   *      ls_sub-rcntr  = gs_jvso1-rcntr.
1510   *      ls_sub-rordnr = gs_jvso1-rordnr.
1511   *      ls_sub-rprojk = gs_jvso1-rprojk.
1512   *      ls_sub-rprctr = gs_jvso1-rprctr.
1513   *      ls_sub-budat  = gs_jvso1-budat.
1514   *      ls_sub-tsl    = gs_jvso1-tsl.
1515   *      ls_sub-hsl    = gs_jvso1-hsl.
1516   *      ls_sub-ksl    = gs_jvso1-ksl.
1517   *      APPEND ls_sub TO gt_subtotal.
1518   *    ENDIF.
1519   *  ENDLOOP.
1520   *ENDFORM.
1521   *
1522   **----------------------------------------------------------------------*
1523   ** FORM: APPLY_MAPPINGS
1524   **----------------------------------------------------------------------*
1525   *FORM apply_mappings.
1526   *  DATA: lv_send_curr TYPE waers,
1527   *        lv_recv_curr TYPE waers,
1528   *        lv_last_day TYPE d.
1529   *  FIELD-SYMBOLS: <fs_sub> TYPE ty_subtotal.
1530   *
1531   *  LOOP AT gt_subtotal ASSIGNING <fs_sub>.
1532   *
1533   *    READ TABLE gt_jv_map INTO gs_jv_map
1534   *      WITH KEY op_bukrs = <fs_sub>-rbukrs
1535   *               op_vname = <fs_sub>-rjvnam
1536   *               op_recid = <fs_sub>-rrecin.
1537   *    IF sy-subrc <> 0.
1538   **      MESSAGE 'No JV map found for line' TYPE 'W'.
1539   *      CONTINUE.
1540   *    ENDIF.
1541   *    <fs_sub>-recv_bukrs = gs_jv_map-rec_bukrs.
1542   *
1543   *    READ TABLE gt_gl_map INTO gs_gl_map
1544   *      WITH KEY op_bukrs  = <fs_sub>-rbukrs
1545   *               op_saknr  = <fs_sub>-racct
1546   *               rec_bukrs = <fs_sub>-recv_bukrs.
1547   *    IF sy-subrc = 0.
1548   *      <fs_sub>-recv_saknr = gs_gl_map-rec_saknr.
1549   *    ELSE.
1550   **      MESSAGE 'WARN: No GL map found for line' TYPE 'W'.
1551   *    ENDIF.
1552   *
1553   *    IF <fs_sub>-rcntr IS NOT INITIAL.
1554   *      READ TABLE gt_rcntr_map INTO gs_rcntr_map
1555   *        WITH KEY op_bukrs  = <fs_sub>-rbukrs
1556   *                 op_kostl  = <fs_sub>-rcntr
1557   *                 rec_bukrs = <fs_sub>-recv_bukrs.
1558   *      IF sy-subrc = 0.
1559   *        <fs_sub>-recv_kostl = gs_rcntr_map-rec_kostl.
1560   *      ELSE.
1561   **        MESSAGE 'WARN: No CC map found for line' TYPE 'W'.
1562   *      ENDIF.
1563   *    ENDIF.
1564   *
1565   *    IF <fs_sub>-rprojk IS NOT INITIAL.
1566   *      READ TABLE gt_wbs_map INTO gs_wbs_map
1567   *        WITH KEY op_bukrs  = <fs_sub>-rbukrs
1568   *                 op_posid  = <fs_sub>-rprojk
1569   *                 rec_bukrs = <fs_sub>-recv_bukrs.
1570   *      IF sy-subrc = 0.
1571   *        <fs_sub>-recv_posid = gs_wbs_map-rec_posid.
1572   *      ENDIF.
1573   *    ENDIF.
1574   *
1575   *    IF <fs_sub>-rprctr IS NOT INITIAL.
1576   *      READ TABLE gt_prctr_map INTO gs_prctr_map
1577   *        WITH KEY op_bukrs  = <fs_sub>-rbukrs
1578   *                 op_prctr  = <fs_sub>-rprctr
1579   *                 rec_bukrs = <fs_sub>-recv_bukrs.
1580   *      IF sy-subrc = 0.
1581   *        <fs_sub>-recv_prctr = gs_prctr_map-rec_prctr.
1582   *      ELSE.
1583   **        MESSAGE 'WARN: No PC map found for line' TYPE 'W'.
1584   *      ENDIF.
1585   *    ENDIF.
1586   *
1587   **if <fs_sub>-rbukrs is not initial.
1588   **    CALL FUNCTION 'JV_AND_FI_CURRENCIES'
1589   **      EXPORTING
1590   **        i_bukrs    = <fs_sub>-rbukrs
1591   **      IMPORTING
1592   **        e_currency = lv_send_curr
1593   **      EXCEPTIONS
1594   **        OTHERS     = 1.
1595   **    IF sy-subrc = 0.
1596   **      <fs_sub>-send_curr = lv_send_curr.
1597   **     ENDIF.
1598   **
1599   **endif.
1600   *if <fs_sub>-rbukrs is not initial.
1601   *      <fs_sub>-send_curr = 'USD'.
1602   *endif.
1603   *
1604   *
1605   **if <fs_sub>-recv_bukrs is not initial.
1606   **    CALL FUNCTION 'JV_AND_FI_CURRENCIES'
1607   **      EXPORTING
1608   **        i_bukrs    = <fs_sub>-recv_bukrs
1609   **      IMPORTING
1610   **        e_currency = lv_recv_curr
1611   **      EXCEPTIONS
1612   **        OTHERS     = 1.
1613   **    IF sy-subrc = 0. <fs_sub>-recv_curr = lv_recv_curr. ENDIF.
1614   **
1615   **endif.
1616   *
1617   *if <fs_sub>-rbukrs is not initial.
1618   *      <fs_sub>-recv_curr = 'USD'.
1619   *endif.
1620   *
1621   *CHECK <fs_sub>-budat IS NOT INITIAL.
1622   *
1623   *    CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
1624   *      EXPORTING
1625   *        day_in            = <fs_sub>-budat
1626   *      IMPORTING
1627   *        last_day_of_month = lv_last_day
1628   *      EXCEPTIONS
1629   *        day_in_no_date    = 1
1630   *        OTHERS            = 2.
1631   *
1632   *    <fs_sub>-post_date = COND #( WHEN sy-subrc = 0
1633   *                                 THEN lv_last_day
1634   *                                 ELSE <fs_sub>-budat ).
1635   *
1636   *  ENDLOOP.
1637   *ENDFORM.
1638   *
1639   **----------------------------------------------------------------------*
1640   ** FORM: SET_POSTING_DATES
1641   **----------------------------------------------------------------------*
1642   **FORM set_posting_dates.
1643   **  DATA: lv_last_day TYPE d.
1644   **  FIELD-SYMBOLS: <fs_sub> TYPE ty_subtotal.
1645   **
1646   **  LOOP AT gt_subtotal ASSIGNING <fs_sub>.
1647   **    CHECK <fs_sub>-budat IS NOT INITIAL.
1648   **
1649   **    CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
1650   **      EXPORTING
1651   **        day_in            = <fs_sub>-budat
1652   **      IMPORTING
1653   **        last_day_of_month = lv_last_day
1654   **      EXCEPTIONS
1655   **        day_in_no_date    = 1
1656   **        OTHERS            = 2.
1657   **
1658   **    <fs_sub>-post_date = COND #( WHEN sy-subrc = 0
1659   **                                 THEN lv_last_day
1660   **                                 ELSE <fs_sub>-budat ).
1661   **  ENDLOOP.
1662   **ENDFORM.
1663   *
1664   **----------------------------------------------------------------------*
1665   ** FORM: POST_DOCUMENTS
1666   **----------------------------------------------------------------------*
1667   *FORM post_documents.
1668   *  DATA: lv_curr_recv TYPE bukrs,
1669   *        lv_linenum   TYPE i.
1670   *  FIELD-SYMBOLS: <fs_sub> TYPE ty_subtotal.
1671   *
1672   *  SORT gt_subtotal BY recv_bukrs rjvnam rrecin racct.
1673   *
1674   *  CLEAR: lv_curr_recv, lv_linenum.
1675   *  REFRESH: gt_accountgl, gt_currencyamount.
1676   *
1677   *  LOOP AT gt_subtotal ASSIGNING <fs_sub>.
1678   *    CHECK <fs_sub>-recv_bukrs IS NOT INITIAL.
1679   *
1680   *    IF lv_curr_recv <> <fs_sub>-recv_bukrs
1681   *    AND lv_curr_recv IS NOT INITIAL.
1682   *      PERFORM post_bapi_document USING lv_curr_recv.
1683   *      REFRESH: gt_accountgl, gt_currencyamount.
1684   *      lv_linenum = 0.
1685   *    ENDIF.
1686   *
1687   *    lv_curr_recv = <fs_sub>-recv_bukrs.
1688   *    ADD 1 TO lv_linenum.
1689   *
1690   *    CLEAR gs_accountgl.
1691   *    gs_accountgl-itemno_acc  = lv_linenum.
1692   *    gs_accountgl-gl_account  = <fs_sub>-recv_saknr.
1693   *    gs_accountgl-comp_code   = <fs_sub>-recv_bukrs.
1694   *    gs_accountgl-costcenter  = <fs_sub>-recv_kostl.
1695   *    gs_accountgl-orderid     = <fs_sub>-rordnr.
1696   *    gs_accountgl-wbs_element = <fs_sub>-recv_posid.
1697   *    gs_accountgl-profit_ctr  = <fs_sub>-recv_prctr.
1698   *
1699   *    Gs_accountgl-fis_period = '16'.
1700   *    Gs_accountgl-fisc_year  = p_gjahr.
1701   *    Gs_accountgl-fisc_year  = p_gjahr.
1702   *    Gs_accountgl-de_cre_ind = 'H'.
1703   *    Gs_accountgl-doc_type = 'SA'.
1704   *    Gs_accountgl-func_area = '0001'.
1705   *
1706   *
1707   *
1708   *
1709   *    APPEND gs_accountgl TO gt_accountgl.
1710   *
1711   *    CLEAR gs_currencyamount.
1712   *    gs_currencyamount-itemno_acc = lv_linenum.
1713   *    gs_currencyamount-currency   = <fs_sub>-recv_curr.
1714   *    gs_currencyamount-amt_doccur = <fs_sub>-ksl.
1715   *    APPEND gs_currencyamount TO gt_currencyamount.
1716   *
1717   *  ENDLOOP.
1718   *
1719   *  IF lv_curr_recv IS NOT INITIAL AND gt_accountgl IS NOT INITIAL.
1720   *    PERFORM post_bapi_document USING lv_curr_recv.
1721   *  ENDIF.
1722   *ENDFORM.
1723   *
1724   **----------------------------------------------------------------------*
1725   ** FORM: POST_BAPI_DOCUMENT
1726   **----------------------------------------------------------------------*
1727   *FORM post_bapi_document USING lv_recv_bukrs TYPE bukrs.
1728   *  DATA: lv_post_date TYPE budat,
1729   *        lv_has_error TYPE abap_bool.
1730   *  FIELD-SYMBOLS: <fs_s> TYPE ty_subtotal.
1731   *
1732   *  READ TABLE gt_subtotal ASSIGNING <fs_s>
1733   *    WITH KEY recv_bukrs = lv_recv_bukrs.
1734   *  IF sy-subrc = 0.
1735   *    lv_post_date = <fs_s>-post_date.
1736   *  ENDIF.
1737   *
1738   *  CLEAR gs_doc_header.
1739   *  gs_doc_header-bus_act    = 'RFBU'.
1740   *  gs_doc_header-username   = sy-uname.
1741   *  gs_doc_header-comp_code  = lv_recv_bukrs.
1742   *  gs_doc_header-doc_date   = lv_post_date.
1743   *  gs_doc_header-pstng_date = lv_post_date.
1744   *  GS_DOC_HEADER-trans_date = lv_post_date.
1745   *  gs_doc_header-doc_type   = 'SA'.
1746   *  gs_doc_header-ref_doc_no = 'ZR_JV_POST'.
1747   *  gs_doc_header-header_txt = 'JV Transfer Auto Post'.
1748   *  GS_DOC_HEADER-fis_period = p_poper.
1749   *  GS_DOC_HEADER-fisc_year = p_gjahr.
1750   *
1751   *  REFRESH gt_return.
1752   *
1753   **  CALL FUNCTION 'BAPI_ACCOUNTING_DOCUMENT_POST'
1754   **    EXPORTING
1755   **      documentheader = gs_doc_header
1756   **    IMPORTING
1757   **      obj_type       = gv_obj_type
1758   **      obj_key        = gv_obj_key
1759   **      obj_sys        = gv_obj_sys
1760   **    TABLES
1761   **      accountgl      = gt_accountgl
1762   **      currencyamount = gt_currencyamount
1763   **      return         = gt_return.
1764   *
1765   * CALL FUNCTION 'BAPI_ACC_DOCUMENT_CHECK'
1766   *    EXPORTING
1767   *      documentheader = gs_doc_header
1768   *    TABLES
1769   *      accountgl      = gt_accountgl
1770   *      currencyamount = gt_currencyamount
1771   *      return         = gt_return.
1772   *
1773   *  CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
1774   *    EXPORTING
1775   *      documentheader = gs_doc_header
1776   *    IMPORTING
1777   *      obj_type       = gv_obj_type
1778   *      obj_key        = gv_obj_key
1779   *      obj_sys        = gv_obj_sys
1780   *    TABLES
1781   *      accountgl      = gt_accountgl
1782   *      currencyamount = gt_currencyamount
1783   *      return         = gt_return.
1784   *
1785   *
1786   *
1787   *
1788   *
1789   *  " Collect ALL BAPI return messages into ALV result table
1790   * lv_has_error = abap_false.
1791   *  LOOP AT gt_return INTO gs_return.
1792   *
1793   *    CLEAR gs_alv_result.
1794   *    gs_alv_result-msgty      = gs_return-type.
1795   *    gs_alv_result-comp_code  = lv_recv_bukrs.
1796   *    gs_alv_result-doc_number = COND #( WHEN lv_has_error = abap_false
1797   *                                       THEN gv_obj_key
1798   *                                       ELSE space ).
1799   *    gs_alv_result-message    = gs_return-message.
1800   *    APPEND gs_alv_result TO gt_alv_result.
1801   *
1802   *    IF gs_alv_result-msgty = 'E' OR gs_alv_result-msgty = 'A'.
1803   *      lv_has_error = abap_true.
1804   *    ENDIF.
1805   *
1806   *  ENDLOOP.
1807   *
1808   *  IF lv_has_error = abap_false AND GV_TEST_RUN = abap_false.
1809   *    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
1810   *      EXPORTING wait = 'X'.
1811   **    ADD 1 TO gv_lines_ok.
1812   *  ELSE.
1813   *    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
1814   **    ADD 1 TO gv_lines_err.
1815   *  ENDIF.
1816   *
1817   *  IF GV_TEST_RUN = abap_true.
1818   *    CLEAR gs_alv_result.
1819   *    gs_alv_result-msgty     = 'I'.
1820   *    gs_alv_result-comp_code = lv_recv_bukrs.
1821   *    gs_alv_result-message   = |Test Run - No FI document created for company code { lv_recv_bukrs }|.
1822   *    APPEND gs_alv_result TO gt_alv_result.
1823   *  ENDIF.
1824   *ENDFORM.
1825   *
1826   **----------------------------------------------------------------------*
1827   ** FORM: DISPLAY_SUMMARY
1828   **----------------------------------------------------------------------*
1829   *FORM display_summary.
1830   *
1831   *DATA: lo_alv     TYPE REF TO cl_salv_table,
1832   *        lo_columns TYPE REF TO cl_salv_columns_table,
1833   *        lo_column  TYPE REF TO cl_salv_column_table,
1834   *        lo_display TYPE REF TO cl_salv_display_settings,
1835   *        lo_funcs   TYPE REF TO cl_salv_functions_list.
1836   *
1837   **  " Add summary lines at the end of ALV table
1838   **  CLEAR gs_alv_result.
1839   **  gs_alv_result-msgty   = 'I'.
1840   **  gs_alv_result-message = |Total Subtotal Lines : { lines( gt_subtotal ) }|.
1841   **  APPEND gs_alv_result TO gt_alv_result.
1842   **
1843   **  CLEAR gs_alv_result.
1844   **  gs_alv_result-msgty   = 'S'.
1845   **  gs_alv_result-message = |Documents Posted OK  : { gv_lines_ok }|.
1846   **  APPEND gs_alv_result TO gt_alv_result.
1847   **
1848   **  IF gv_lines_err > 0.
1849   **    CLEAR gs_alv_result.
1850   **    gs_alv_result-msgty   = 'E'.
1851   **    gs_alv_result-message = |Documents in ERROR   : { gv_lines_err }|.
1852   **    APPEND gs_alv_result TO gt_alv_result.
1853   **  ENDIF.
1854   **
1855   **  IF gv_test_run = abap_true.
1856   **    CLEAR gs_alv_result.
1857   **    gs_alv_result-msgty   = 'I'.
1858   **    gs_alv_result-message = 'TEST RUN - No FI documents were created'.
1859   **    APPEND gs_alv_result TO gt_alv_result.
1860   **  ENDIF.
1861   *
1862   *  " Create ALV instance
1863   *  TRY.
1864   *      cl_salv_table=>factory(
1865   *        IMPORTING
1866   *          r_salv_table = lo_alv
1867   *        CHANGING
1868   *          t_table      = gt_alv_result ).
1869   *
1870   *    CATCH cx_salv_msg INTO DATA(lx_msg).
1871   *      MESSAGE |ALV Error: { lx_msg->get_text( ) }| TYPE 'E'.
1872   *      RETURN.
1873   *  ENDTRY.
1874   *
1875   *  " Toolbar
1876   *  lo_funcs = lo_alv->get_functions( ).
1877   *  lo_funcs->set_all( abap_true ).
1878   *
1879   *  " Title & striped rows
1880   *  lo_display = lo_alv->get_display_settings( ).
1881   *  lo_display->set_list_header( 'JV Transfer Posting Results' ).
1882   *  lo_display->set_striped_pattern( abap_true ).
1883   *
1884   *  " Optimize all columns
1885   *  lo_columns = lo_alv->get_columns( ).
1886   *  lo_columns->set_optimize( abap_true ).
1887   *
1888   *  " Column: MSGTY
1889   *  TRY.
1890   *      lo_column ?= lo_columns->get_column( 'MSGTY' ).
1891   *      lo_column->set_long_text( 'Type' ).
1892   *      lo_column->set_medium_text( 'Type' ).
1893   *      lo_column->set_short_text( 'Type' ).
1894   *      lo_column->set_output_length( 5 ).
1895   *    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
1896   *  ENDTRY.
1897   *
1898   *  " Column: COMP_CODE
1899   *  TRY.
1900   *      lo_column ?= lo_columns->get_column( 'COMP_CODE' ).
1901   *      lo_column->set_long_text( 'Company Code' ).
1902   *      lo_column->set_medium_text( 'Comp.Code' ).
1903   *      lo_column->set_short_text( 'CoCd' ).
1904   *      lo_column->set_output_length( 10 ).
1905   *    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
1906   *  ENDTRY.
1907   *
1908   *  " Column: DOC_NUMBER
1909   *  TRY.
1910   *      lo_column ?= lo_columns->get_column( 'DOC_NUMBER' ).
1911   *      lo_column->set_long_text( 'Document Number' ).
1912   *      lo_column->set_medium_text( 'Doc. Number' ).
1913   *      lo_column->set_short_text( 'Doc.No.' ).
1914   *      lo_column->set_output_length( 15 ).
1915   *    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
1916   *  ENDTRY.
1917   *
1918   *  " Column: MESSAGE
1919   *  TRY.
1920   *      lo_column ?= lo_columns->get_column( 'MESSAGE' ).
1921   *      lo_column->set_long_text( 'Message' ).
1922   *      lo_column->set_medium_text( 'Message' ).
1923   *      lo_column->set_short_text( 'Message' ).
1924   *      lo_column->set_output_length( 120 ).
1925   *    CATCH cx_salv_not_found.                            "#EC NO_HANDLER
1926   *  ENDTRY.
1927   *
1928   *  lo_alv->display( ).
1929   *ENDFORM.
1930   *&---------------------------------------------------------------------*
1931   *&      Form  VALIDATE_POSTING
1932   *&---------------------------------------------------------------------*
1933   *       text
1934   *----------------------------------------------------------------------*
1935   *  -->  p1        text
1936   *  <--  p2        text
1937   *----------------------------------------------------------------------*
1938   FORM validate_posting .
1939     select single *
1940     from ZJV_MAP_TRF
1941     into @data(ls_map)
1942     where op_bukrs = @p_bukrs
1943       and op_vname = @p_jv
1944       and gjahr = @p_gjahr
1945       and period = @p_poper.
1946       IF sy-subrc is INITIAL and LS_MAP-test_run = 'X'.
1947         MESSAGE: 'Document already posted for the given selection' type 'E'.
1948       ENDIF.
1949
1950       gs_jv_map_trf-op_bukrs = P_BUKRS.
1951       gs_jv_map_trf-op_vname = P_JV.
1952       gs_jv_map_trf-gjahr = p_gjahr.
1953       gs_jv_map_trf-period = p_poper.
1954
1955
1956
1957   ENDFORM.
1958   *&---------------------------------------------------------------------*
1959   *&      Form  DETERMINE_COST_ELEMENT
1960   *&---------------------------------------------------------------------*
1961   *       text
1962   *----------------------------------------------------------------------*
1963   *  -->  p1        text
1964   *  <--  p2        text
1965   *----------------------------------------------------------------------*
1966   FORM determine_cost_element .
1967   *TYPES: BEGIN OF ty_cskb,
1968   *           kokrs TYPE kokrs,
1969   *           kstar TYPE kstar,
1970   *         END OF ty_cskb.
1971   *
1972   *  DATA: lt_cskb     TYPE HASHED TABLE OF ty_cskb
1973   *                     WITH UNIQUE KEY kokrs kstar,
1974   *        ls_cskb      TYPE ty_cskb,
1975   *        lt_saknr_rng TYPE RANGE OF saknr,
1976   *        ls_saknr_rng LIKE LINE OF lt_saknr_rng.
1977   *
1978   *  FIELD-SYMBOLS: <fs_sub> TYPE ty_subtotal.
1979   *
1980   *  CHECK gt_subtotal IS NOT INITIAL.
1981   *
1982   *  " Build a range of distinct receiver GL accounts already mapped
1983   *  LOOP AT gt_subtotal ASSIGNING <fs_sub> WHERE recv_saknr IS NOT INITIAL.
1984   *    CLEAR ls_saknr_rng.
1985   *    ls_saknr_rng-sign   = 'I'.
1986   *    ls_saknr_rng-option = 'EQ'.
1987   *    ls_saknr_rng-low    = <fs_sub>-recv_saknr.
1988   *    COLLECT ls_saknr_rng INTO lt_saknr_rng.
1989   *  ENDLOOP.
1990   *
1991   *  CHECK lt_saknr_rng IS NOT INITIAL.
1992   *
1993   *  " Bulk lookup: which of these GL accounts are Cost Elements in CO Area OVL
1994   *  SELECT DISTINCT kokrs kstar
1995   *    FROM cskb
1996   *    INTO TABLE lt_cskb
1997   *   WHERE kokrs = 'OVL'
1998   *     AND kstar IN lt_saknr_rng.
1999   *
2000   *  LOOP AT gt_subtotal ASSIGNING <fs_sub>.
2001   *    CHECK <fs_sub>-recv_saknr IS NOT INITIAL.
2002   *
2003   *    READ TABLE lt_cskb TRANSPORTING NO FIELDS
2004   *      WITH TABLE KEY kokrs = 'OVL'
2005   *                      kstar = <fs_sub>-recv_saknr.
2006   *
2007   *    IF sy-subrc = 0.
2008   *      " Cost Element -> must carry Cost Center or WBS.
2009   *      " (If your mapping can produce BOTH, decide precedence here.
2010   *      "  Currently: Cost Center wins if both are populated.)
2011   *      IF <fs_sub>-recv_kostl IS NOT INITIAL.
2012   *        CLEAR <fs_sub>-recv_posid.
2013   *      ENDIF.
2014   *      " If neither Cost Center nor WBS got mapped for a true cost element,
2015   *      " that's a data/config gap - flag it rather than silently posting
2016   *      " an incomplete CO assignment.
2017   *      IF <fs_sub>-recv_kostl IS INITIAL AND <fs_sub>-recv_posid IS INITIAL.
2018   *        APPEND VALUE #(
2019   *          msgty   = 'E'
2020   *          message = |Cost element { <fs_sub>-recv_saknr } for CoCd |
2021   *                 && |{ <fs_sub>-recv_bukrs } has no mapped Cost Center |
2022   *                 && |or WBS - posting line will be rejected|
2023   *        ) TO gt_alv_result.
2024   *      ENDIF.
2025   *    ELSE.
2026   *      " Not a Cost Element -> CO object not applicable, keep only Profit Center
2027   *      CLEAR: <fs_sub>-recv_kostl, <fs_sub>-recv_posid.
2028   *    ENDIF.
2029   *
2030   *  ENDLOOP.
2031     TYPES: BEGIN OF ty_cskb,
2032              kokrs TYPE kokrs,
2033              kstar TYPE kstar,
2034              datab TYPE datab,
2035              datbi TYPE datbi,
2036            END OF ty_cskb.
2037
2038     DATA: lt_cskb      TYPE STANDARD TABLE OF ty_cskb,   " CHANGED: no longer hashed/unique-key -
2039           ls_cskb      TYPE ty_cskb,                      " a KSTAR can have several validity segments
2040           lt_saknr_rng TYPE RANGE OF saknr,
2041           ls_saknr_rng LIKE LINE OF lt_saknr_rng,
2042           lv_check_date TYPE d,
2043           lv_found      TYPE abap_bool.
2044
2045     FIELD-SYMBOLS: <fs_sub> TYPE ty_subtotal.
2046
2047     CHECK gt_subtotal IS NOT INITIAL.
2048
2049     LOOP AT gt_subtotal ASSIGNING <fs_sub> WHERE recv_saknr IS NOT INITIAL.
2050       CLEAR ls_saknr_rng.
2051       ls_saknr_rng-sign   = 'I'.
2052       ls_saknr_rng-option = 'EQ'.
2053       ls_saknr_rng-low    = <fs_sub>-recv_saknr.
2054       COLLECT ls_saknr_rng INTO lt_saknr_rng.
2055     ENDLOOP.
2056
2057     CHECK lt_saknr_rng IS NOT INITIAL.
2058
2059     " Primary cost elements only (KATYP = '1'); pull ALL validity segments,
2060     " date filtering happens per-line below since each line can have a
2061     " different post_date.
2062     SELECT kokrs kstar datab datbi
2063       FROM cskb
2064       INTO TABLE lt_cskb
2065      WHERE kokrs = 'OVL'
2066        AND kstar IN lt_saknr_rng
2067        AND katyp = '01'.
2068
2069     LOOP AT gt_subtotal ASSIGNING <fs_sub>.
2070       CHECK <fs_sub>-recv_saknr IS NOT INITIAL.
2071
2072       " NEW: date the cost element must be valid on - use the line's own
2073       " posting date (already resolved in apply_mappings).
2074       lv_check_date = <fs_sub>-post_date.
2075       IF lv_check_date IS INITIAL.
2076         lv_check_date = <fs_sub>-budat.   " fallback, shouldn't normally hit
2077       ENDIF.
2078
2079       CLEAR lv_found.
2080       LOOP AT lt_cskb INTO ls_cskb
2081            WHERE kokrs = 'OVL'
2082              AND kstar = <fs_sub>-recv_saknr
2083              AND datab <= lv_check_date
2084              AND datbi >= lv_check_date.
2085         lv_found = abap_true.
2086         EXIT.
2087       ENDLOOP.
2088
2089       IF lv_found = abap_true.
2090         " Primary cost element, valid on the posting date -> must carry Cost Center or WBS.
2091         IF <fs_sub>-recv_kostl IS NOT INITIAL.
2092           CLEAR <fs_sub>-recv_posid.   " Cost Center wins if both are populated
2093         ENDIF.
2094
2095         IF <fs_sub>-recv_kostl IS INITIAL AND <fs_sub>-recv_posid IS INITIAL.
2096           IF <fs_sub>-default_kostl IS NOT INITIAL.
2097             <fs_sub>-recv_kostl = <fs_sub>-default_kostl.
2098             CLEAR <fs_sub>-recv_posid.
2099           ELSEIF <fs_sub>-default_prctr IS NOT INITIAL.
2100             <fs_sub>-recv_prctr = <fs_sub>-default_prctr.
2101           ENDIF.
2102         ENDIF.
2103
2104         IF <fs_sub>-recv_kostl IS INITIAL AND <fs_sub>-recv_posid IS INITIAL.
2105           APPEND VALUE #(
2106             msgty   = 'E'
2107             message = |Cost element { <fs_sub>-recv_saknr } for CoCd |
2108                    && |{ <fs_sub>-recv_bukrs } has no mapped or default |
2109                    && |Cost Center/WBS - posting line will be rejected|
2110           ) TO gt_alv_result.
2111         ENDIF.
2112
2113       ELSE.
2114         " Either not a primary cost element, or KSTAR exists but isn't
2115         " valid on the posting date -> CO object not applicable/expired,
2116         " keep only Profit Center.
2117         CLEAR: <fs_sub>-recv_kostl, <fs_sub>-recv_posid.
2118
2119         " Optional: flag when the account WAS mapped as a cost element
2120         " record elsewhere but just isn't valid on this date, so it doesn't
2121         " silently look identical to "not a cost element at all". Drop this
2122         " if you don't want the extra noise in the log.
2123         READ TABLE lt_cskb TRANSPORTING NO FIELDS
2124           WITH KEY kokrs = 'OVL' kstar = <fs_sub>-recv_saknr.
2125         IF sy-subrc = 0.
2126           APPEND VALUE #(
2127             msgty   = 'W'
2128             message = |Cost element { <fs_sub>-recv_saknr } exists in CSKB |
2129                    && |but has no validity segment covering { lv_check_date DATE = USER } |
2130                    && |for CoCd { <fs_sub>-recv_bukrs }|
2131           ) TO gt_alv_result.
2132         ENDIF.
2133       ENDIF.
2134
2135     ENDLOOP.
2136   ENDFORM.
2137   *&---------------------------------------------------------------------*
2138   *&      Form  RESOLVE_WBS_ELEMENT
2139   *&---------------------------------------------------------------------*
2140   *       text
2141   *----------------------------------------------------------------------*
2142   *  -->  p1        text
2143   *  <--  p2        text
2144   *----------------------------------------------------------------------*
2145   FORM resolve_wbs_element .
2146
2147     TYPES: BEGIN OF ty_prps,
2148              objnr TYPE j_objnr,
2149              posid TYPE ps_posid,
2150            END OF ty_prps.
2151
2152     DATA: lt_prps  TYPE HASHED TABLE OF ty_prps
2153                    WITH UNIQUE KEY objnr,
2154           lv_objnr TYPE j_objnr,
2155           lt_objnr_rng TYPE RANGE OF j_objnr,
2156           ls_objnr_rng LIKE LINE OF lt_objnr_rng.
2157
2158     FIELD-SYMBOLS: <fs_sub> TYPE ty_subtotal.
2159
2160     CHECK gt_subtotal IS NOT INITIAL.
2161
2162     " Build OBJNR range: 'PR' + internal WBS number, for every line
2163     " that currently carries a raw internal number in recv_posid.
2164     LOOP AT gt_subtotal ASSIGNING <fs_sub> WHERE recv_posid IS NOT INITIAL.
2165       CONCATENATE 'PR' <fs_sub>-recv_posid INTO lv_objnr.
2166
2167       CLEAR ls_objnr_rng.
2168       ls_objnr_rng-sign   = 'I'.
2169       ls_objnr_rng-option = 'EQ'.
2170       ls_objnr_rng-low    = lv_objnr.
2171       COLLECT ls_objnr_rng INTO lt_objnr_rng.
2172     ENDLOOP.
2173
2174     CHECK lt_objnr_rng IS NOT INITIAL.
2175
2176     SELECT objnr posid
2177       FROM prps
2178       INTO TABLE lt_prps
2179      WHERE objnr IN lt_objnr_rng.
2180
2181     LOOP AT gt_subtotal ASSIGNING <fs_sub> WHERE recv_posid IS NOT INITIAL.
2182       CONCATENATE 'PR' <fs_sub>-recv_posid INTO lv_objnr.
2183
2184       READ TABLE lt_prps INTO DATA(ls_prps)
2185         WITH TABLE KEY objnr = lv_objnr.
2186
2187       IF sy-subrc = 0.
2188         <fs_sub>-recv_posid = ls_prps-posid.   " overwrite internal no. with real WBS element
2189       ELSE.
2190         APPEND VALUE #(
2191           msgty   = 'E'
2192           message = |WBS internal no. { <fs_sub>-recv_posid } (OBJNR { lv_objnr }) |
2193                  && |not found in PRPS - line will be rejected|
2194         ) TO gt_alv_result.
2195         CLEAR <fs_sub>-recv_posid.
2196       ENDIF.
2197     ENDLOOP.
2198
2199   ENDFORM.
*--- End of ZR_JV_POST - 2199 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CABAP                                   Level 1    Page 2
Object           ZR_JV_POST                                Lines 360
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:01
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
Generated incl.  <REPINI>                                  Level 1    Page 3
Object           ZR_JV_POST                                Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:01
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
Generated incl.  <SYSINI>                                  Level 1    Page 4
Object           ZR_JV_POST                                Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:01
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
Generated incl.  <SYSSEL>                                  Level 1    Page 5
Object           ZR_JV_POST                                Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:01
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
Generated incl.  CL_ALV_GRID_VIEW_FRONTEND_DATACT          Level 1    Page 6
Object           ZR_JV_POST                                Lines 3
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:01
----------------------------------------------------------------------------------------------------
1      *"* dummy include to reduce generation dependencies between
2      *"* class CL_ALV_GRID_VIEW_FRONTEND_DATA and it's users.
3      *"* touched if any type reference has been changed
*--- End of CL_ALV_GRID_VIEW_FRONTEND_DATACT - 3 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  CL_SALV_FORMATTING_PROPS_UTILSCT          Level 1    Page 7
Object           ZR_JV_POST                                Lines 3
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:01
----------------------------------------------------------------------------------------------------
1      *"* dummy include to reduce generation dependencies between
2      *"* class CL_SALV_FORMATTING_PROPS_UTILS and it's users.
3      *"* touched if any type reference has been changed
*--- End of CL_SALV_FORMATTING_PROPS_UTILSCT - 3 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  CL_SALV_GUI_GRID_FIELD_CATALOGCT          Level 1    Page 8
Object           ZR_JV_POST                                Lines 3
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:01
----------------------------------------------------------------------------------------------------
1      *"* dummy include to reduce generation dependencies between
2      *"* class CL_SALV_GUI_GRID_FIELD_CATALOG and it's users.
3      *"* touched if any type reference has been changed
*--- End of CL_SALV_GUI_GRID_FIELD_CATALOGCT - 3 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  CL_SALV_GUI_TEST_F4_VALUE_HELPCT          Level 1    Page 9
Object           ZR_JV_POST                                Lines 3
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:01
----------------------------------------------------------------------------------------------------
1      *"* dummy include to reduce generation dependencies between
2      *"* class CL_SALV_GUI_TEST_F4_VALUE_HELP and it's users.
3      *"* touched if any type reference has been changed
*--- End of CL_SALV_GUI_TEST_F4_VALUE_HELPCT - 3 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  CX_SALV_API_CONTRACT_VIOLATIONCU          Level 1    Page 10
Object           ZR_JV_POST                                Lines 57
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:01
----------------------------------------------------------------------------------------------------
1      class CX_SALV_API_CONTRACT_VIOLATION definition
2        public
3        inheriting from CX_SALV_API_DYNAMIC
4        create public .
5
6      public section.
7
8        constants:
9          begin of CX_SALV_API_CONTRACT_VIOLATION,
10           msgid type symsgid value 'SALV_X_API',
11           msgno type symsgno value '021',
12           attr1 type scx_attrname value '',
13           attr2 type scx_attrname value '',
14           attr3 type scx_attrname value '',
15           attr4 type scx_attrname value '',
16         end of CX_SALV_API_CONTRACT_VIOLATION .
17       constants:
18         begin of SRC_DATA_CHANGED_W_O_NOTICE,
19           msgid type symsgid value 'SALV_X_API',
20           msgno type symsgno value '025',
21           attr1 type scx_attrname value '',
22           attr2 type scx_attrname value '',
23           attr3 type scx_attrname value '',
24           attr4 type scx_attrname value '',
25         end of SRC_DATA_CHANGED_W_O_NOTICE .
26       constants:
27         begin of SRC_REF_NOT_BOUND,
28           msgid type symsgid value 'SALV_X_API',
29           msgno type symsgno value '087',
30           attr1 type scx_attrname value '',
31           attr2 type scx_attrname value '',
32           attr3 type scx_attrname value '',
33           attr4 type scx_attrname value '',
34         end of SRC_REF_NOT_BOUND .
35       constants:
36         begin of CALL_CURRENTLY_NOT_ALLOWED,
37           msgid type symsgid value 'SALV_X_API',
38           msgno type symsgno value '094',
39           attr1 type scx_attrname value '',
40           attr2 type scx_attrname value '',
41           attr3 type scx_attrname value '',
42           attr4 type scx_attrname value '',
43         end of CALL_CURRENTLY_NOT_ALLOWED .
44       constants:
45         begin of FUNCTIONALITY_NOT_SUPPORTED,
46           msgid type symsgid value 'SALV_X_API',
47           msgno type symsgno value '130',
48           attr1 type scx_attrname value '',
49           attr2 type scx_attrname value '',
50           attr3 type scx_attrname value '',
51           attr4 type scx_attrname value '',
52         end of FUNCTIONALITY_NOT_SUPPORTED .
53
54       methods CONSTRUCTOR
55         importing
56           !TEXTID like IF_T100_MESSAGE=>T100KEY optional
57           !PREVIOUS like PREVIOUS optional .
*--- End of CX_SALV_API_CONTRACT_VIOLATIONCU - 57 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  CX_SALV_BS_SC_OBJECT_NOT_FOUNDCT          Level 1    Page 11
Object           ZR_JV_POST                                Lines 3
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:01
----------------------------------------------------------------------------------------------------
1      *"* dummy include to reduce generation dependencies between
2      *"* class CX_SALV_BS_SC_OBJECT_NOT_FOUND and it's users.
3      *"* touched if any type reference has been changed
*--- End of CX_SALV_BS_SC_OBJECT_NOT_FOUNDCT - 3 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  CX_SALV_CALL_AFTER_1ST_DISPLAYCT          Level 1    Page 12
Object           ZR_JV_POST                                Lines 3
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:01
----------------------------------------------------------------------------------------------------
1      *"* dummy include to reduce generation dependencies between
2      *"* class CX_SALV_CALL_AFTER_1ST_DISPLAY and it's users.
3      *"* touched if any type reference has been changed
*--- End of CX_SALV_CALL_AFTER_1ST_DISPLAYCT - 3 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  CX_SALV_FUNCTION_NOT_SUPPORTEDCT          Level 1    Page 13
Object           ZR_JV_POST                                Lines 3
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:01
----------------------------------------------------------------------------------------------------
1      *"* dummy include to reduce generation dependencies between
2      *"* class CX_SALV_FUNCTION_NOT_SUPPORTED and it's users.
3      *"* touched if any type reference has been changed
*--- End of CX_SALV_FUNCTION_NOT_SUPPORTEDCT - 3 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  CX_SALV_GUI_TB_WRONG_ITEM_TYPECT          Level 1    Page 14
Object           ZR_JV_POST                                Lines 3
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:01
----------------------------------------------------------------------------------------------------
1      *"* dummy include to reduce generation dependencies between
2      *"* class CX_SALV_GUI_TB_WRONG_ITEM_TYPE and it's users.
3      *"* touched if any type reference has been changed
*--- End of CX_SALV_GUI_TB_WRONG_ITEM_TYPECT - 3 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  CX_SALV_IDA_CONTRACT_VIOLATIONCT          Level 1    Page 15
Object           ZR_JV_POST                                Lines 3
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:01
----------------------------------------------------------------------------------------------------
1      *"* dummy include to reduce generation dependencies between
2      *"* class CX_SALV_IDA_CONTRACT_VIOLATION and it's users.
3      *"* touched if any type reference has been changed
*--- End of CX_SALV_IDA_CONTRACT_VIOLATIONCT - 3 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  CX_SALV_IDA_NO_SELECTION_AT_UICT          Level 1    Page 16
Object           ZR_JV_POST                                Lines 3
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:01
----------------------------------------------------------------------------------------------------
1      *"* dummy include to reduce generation dependencies between
2      *"* class CX_SALV_IDA_NO_SELECTION_AT_UI and it's users.
3      *"* touched if any type reference has been changed
*--- End of CX_SALV_IDA_NO_SELECTION_AT_UICT - 3 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  CX_SALV_INDEX_TABLE_NOT_SORTEDCT          Level 1    Page 17
Object           ZR_JV_POST                                Lines 3
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:01
----------------------------------------------------------------------------------------------------
1      *"* dummy include to reduce generation dependencies between
2      *"* class CX_SALV_INDEX_TABLE_NOT_SORTED and it's users.
3      *"* touched if any type reference has been changed
*--- End of CX_SALV_INDEX_TABLE_NOT_SORTEDCT - 3 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  CX_SALV_UNEXPECTED_PARAM_VALUECT          Level 1    Page 18
Object           ZR_JV_POST                                Lines 3
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:01
----------------------------------------------------------------------------------------------------
1      *"* dummy include to reduce generation dependencies between
2      *"* class CX_SALV_UNEXPECTED_PARAM_VALUE and it's users.
3      *"* touched if any type reference has been changed
*--- End of CX_SALV_UNEXPECTED_PARAM_VALUECT - 3 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  DB__SSEL                                  Level 1    Page 19
Object           ZR_JV_POST                                Lines 1
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:01
----------------------------------------------------------------------------------------------------
1      * INCLUDE DB__SSEL
*--- End of DB__SSEL - 1 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  IF_SALV_GRID_FRONTEND_ANALYSERIT          Level 1    Page 20
Object           ZR_JV_POST                                Lines 3
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:01
----------------------------------------------------------------------------------------------------
1      *"* dummy include to reduce generation dependencies between
2      *"* class IF_SALV_GRID_FRONTEND_ANALYSER and it's users.
3      *"* touched if any type reference has been changed
*--- End of IF_SALV_GRID_FRONTEND_ANALYSERIT - 3 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  IF_SALV_GUI_FIELD_DISPLAY_INFOIT          Level 1    Page 21
Object           ZR_JV_POST                                Lines 3
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:01
----------------------------------------------------------------------------------------------------
1      *"* dummy include to reduce generation dependencies between
2      *"* class IF_SALV_GUI_FIELD_DISPLAY_INFO and it's users.
3      *"* touched if any type reference has been changed
*--- End of IF_SALV_GUI_FIELD_DISPLAY_INFOIT - 3 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  IF_SALV_GUI_FIELD_INFO_MUTABLEIT          Level 1    Page 22
Object           ZR_JV_POST                                Lines 3
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:01
----------------------------------------------------------------------------------------------------
1      *"* dummy include to reduce generation dependencies between
2      *"* class IF_SALV_GUI_FIELD_INFO_MUTABLE and it's users.
3      *"* touched if any type reference has been changed
*--- End of IF_SALV_GUI_FIELD_INFO_MUTABLEIT - 3 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  IF_SALV_GUI_GRID_FIELD_CATALOGIT          Level 1    Page 23
Object           ZR_JV_POST                                Lines 3
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:01
----------------------------------------------------------------------------------------------------
1      *"* dummy include to reduce generation dependencies between
2      *"* class IF_SALV_GUI_GRID_FIELD_CATALOG and it's users.
3      *"* touched if any type reference has been changed
*--- End of IF_SALV_GUI_GRID_FIELD_CATALOGIT - 3 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  IF_SALV_GUI_GRID_FWK_CHANGELOGIT          Level 1    Page 24
Object           ZR_JV_POST                                Lines 3
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:01
----------------------------------------------------------------------------------------------------
1      *"* dummy include to reduce generation dependencies between
2      *"* class IF_SALV_GUI_GRID_FWK_CHANGELOG and it's users.
3      *"* touched if any type reference has been changed
*--- End of IF_SALV_GUI_GRID_FWK_CHANGELOGIT - 3 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  IF_SALV_GUI_GRID_LAYOUT_EDITORIT          Level 1    Page 25
Object           ZR_JV_POST                                Lines 3
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:01
----------------------------------------------------------------------------------------------------
1      *"* dummy include to reduce generation dependencies between
2      *"* class IF_SALV_GUI_GRID_LAYOUT_EDITOR and it's users.
3      *"* touched if any type reference has been changed
*--- End of IF_SALV_GUI_GRID_LAYOUT_EDITORIT - 3 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  IF_SALV_GUI_GRID_MODEL_UIPHASEIT          Level 1    Page 26
Object           ZR_JV_POST                                Lines 3
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:01
----------------------------------------------------------------------------------------------------
1      *"* dummy include to reduce generation dependencies between
2      *"* class IF_SALV_GUI_GRID_MODEL_UIPHASE and it's users.
3      *"* touched if any type reference has been changed
*--- End of IF_SALV_GUI_GRID_MODEL_UIPHASEIT - 3 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  IF_SALV_GUI_LAYOUT_PERSISTENCEIT          Level 1    Page 27
Object           ZR_JV_POST                                Lines 3
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:01
----------------------------------------------------------------------------------------------------
1      *"* dummy include to reduce generation dependencies between
2      *"* class IF_SALV_GUI_LAYOUT_PERSISTENCE and it's users.
3      *"* touched if any type reference has been changed
*--- End of IF_SALV_GUI_LAYOUT_PERSISTENCEIT - 3 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  IF_SALV_GUI_OM_EDIT_RESTRICTEDIT          Level 1    Page 28
Object           ZR_JV_POST                                Lines 3
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:01
----------------------------------------------------------------------------------------------------
1      *"* dummy include to reduce generation dependencies between
2      *"* class IF_SALV_GUI_OM_EDIT_RESTRICTED and it's users.
3      *"* touched if any type reference has been changed
*--- End of IF_SALV_GUI_OM_EDIT_RESTRICTEDIT - 3 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  IF_SALV_GUI_OM_EDIT_STRCT_LSTRIT          Level 1    Page 29
Object           ZR_JV_POST                                Lines 3
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:01
----------------------------------------------------------------------------------------------------
1      *"* dummy include to reduce generation dependencies between
2      *"* class IF_SALV_GUI_OM_EDIT_STRCT_LSTR and it's users.
3      *"* touched if any type reference has been changed
*--- End of IF_SALV_GUI_OM_EDIT_STRCT_LSTRIT - 3 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  IF_SALV_GUI_OM_EXTEND_GRID_APIIT          Level 1    Page 30
Object           ZR_JV_POST                                Lines 3
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:01
----------------------------------------------------------------------------------------------------
1      *"* dummy include to reduce generation dependencies between
2      *"* class IF_SALV_GUI_OM_EXTEND_GRID_API and it's users.
3      *"* touched if any type reference has been changed
*--- End of IF_SALV_GUI_OM_EXTEND_GRID_APIIT - 3 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  IF_SALV_GUI_TB_TOOLBAR_BUILDERIT          Level 1    Page 31
Object           ZR_JV_POST                                Lines 3
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:01
----------------------------------------------------------------------------------------------------
1      *"* dummy include to reduce generation dependencies between
2      *"* class IF_SALV_GUI_TB_TOOLBAR_BUILDER and it's users.
3      *"* touched if any type reference has been changed
*--- End of IF_SALV_GUI_TB_TOOLBAR_BUILDERIT - 3 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  IF_SALV_GUI_USER_ACTION_READERIT          Level 1    Page 32
Object           ZR_JV_POST                                Lines 3
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:01
----------------------------------------------------------------------------------------------------
1      *"* dummy include to reduce generation dependencies between
2      *"* class IF_SALV_GUI_USER_ACTION_READER and it's users.
3      *"* touched if any type reference has been changed
*--- End of IF_SALV_GUI_USER_ACTION_READERIT - 3 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  IF_SALV_IDA_CALC_FIELD_HANDLERIT          Level 1    Page 33
Object           ZR_JV_POST                                Lines 3
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:01
----------------------------------------------------------------------------------------------------
1      *"* dummy include to reduce generation dependencies between
2      *"* class IF_SALV_IDA_CALC_FIELD_HANDLER and it's users.
3      *"* touched if any type reference has been changed
*--- End of IF_SALV_IDA_CALC_FIELD_HANDLERIT - 3 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  IF_SALV_ITAB_VIEW_GROUPED_DATAIT          Level 1    Page 34
Object           ZR_JV_POST                                Lines 3
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:01
----------------------------------------------------------------------------------------------------
1      *"* dummy include to reduce generation dependencies between
2      *"* class IF_SALV_ITAB_VIEW_GROUPED_DATA and it's users.
3      *"* touched if any type reference has been changed
*--- End of IF_SALV_ITAB_VIEW_GROUPED_DATAIT - 3 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  IF_SALV_STI_TEXT_SEARCH_RESULTIT          Level 1    Page 35
Object           ZR_JV_POST                                Lines 3
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:01
----------------------------------------------------------------------------------------------------
1      *"* dummy include to reduce generation dependencies between
2      *"* class IF_SALV_STI_TEXT_SEARCH_RESULT and it's users.
3      *"* touched if any type reference has been changed
*--- End of IF_SALV_STI_TEXT_SEARCH_RESULTIT - 3 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  IF_WD_VIEW_ELEMENT_METHOD_HNDLIT          Level 1    Page 36
Object           ZR_JV_POST                                Lines 3
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:01
----------------------------------------------------------------------------------------------------
1      *"* dummy include to reduce generation dependencies between
2      *"* class IF_WD_VIEW_ELEMENT_METHOD_HNDL and it's users.
3      *"* touched if any type reference has been changed
*--- End of IF_WD_VIEW_ELEMENT_METHOD_HNDLIT - 3 lines ---
