----------------------------------------------------------------------------------------------------
Main program     ZFI_TAX_SEC42_AMORT_SCH                   Level 0    Page 1
Object           ZFI_TAX_SEC42_AMORT_SCH                   Lines 15
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:40
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *& Report ZFI_CIT_SEC42_AMORT
3      *&---------------------------------------------------------------------*
4      *& Description: Section 42 Deductions - Amortization Computation
5      *& Transaction: ZFI_CIT_AMORT
6      *& Module:      FI - Tax Accounting
7      *& Project:     OVL - ECC 6.0
8      *& Compatibility: SAP ECC 6.0 (EHP4+)
9      *&----------------------------------------------------------------------*
10
11     REPORT ZFI_TAX_SEC42_AMORT_SCH.
12
13     include ZFI_TAX_SEC42_AMORT_SCH_top.
14     include ZFI_TAX_SEC42_AMORT_SCH_e01.
15     include ZFI_TAX_SEC42_AMORT_SCH_f01.
*--- End of ZFI_TAX_SEC42_AMORT_SCH - 15 lines ---

----------------------------------------------------------------------------------------------------
Include          ZFI_TAX_SEC42_AMORT_SCH_TOP               Level 1    Page 2
Object           ZFI_TAX_SEC42_AMORT_SCH                   Lines 69
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:40
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&  Include           ZFI_TAX_SEC42_AMORT_SCH_TOP
3      *&---------------------------------------------------------------------*
4
5      *----------------------------------------------------------------------*
6      ** Type Definitions
7      **----------------------------------------------------------------------*
8      TYPES: BEGIN OF ty_current_deduction,
9               bukrs      TYPE bukrs,
10              venture    TYPE char10,
11              gjahr      TYPE gjahr,
12              hkont      TYPE hkont,
13              amount     TYPE wrbtr,
14              description TYPE char50,
15            END OF ty_current_deduction,
16
17            BEGIN OF ty_amort_instl,
18              bukrs      TYPE bukrs,
19              venture    TYPE char10,
20              gjahr      TYPE gjahr,          " Fiscal Year
21              hkont      TYPE hkont,          " GL Account
22              surr_date  TYPE dats,           " Date of Surrender
23              instl_amt  TYPE wrbtr,          " Installment Amount)
24            END OF ty_amort_instl.
25
26            TABLES: sscrfields.
27     DATA:
28           gt_fieldcat    TYPE slis_t_fieldcat_alv,
29           gs_fieldcat    TYPE slis_fieldcat_alv,
30           gs_layout      TYPE slis_layout_alv.
31     *----------------------------------------------------------------------*
32     * Internal Tables and Work Areas
33     *----------------------------------------------------------------------*
34     DATA: gt_block_master  TYPE TABLE OF ZFI_TAX_SEC42_1,
35           gs_block_master  TYPE ZFI_TAX_SEC42_1,
36           gt_gl_post_comm  TYPE TABLE OF ZFI_TAX_SEC42_2,
37           gs_gl_post_comm  TYPE ZFI_TAX_SEC42_2,
38           gt_gl_instl      TYPE TABLE OF ZFI_TAX_SEC42_3,
39           gs_gl_instl      TYPE ZFI_TAX_SEC42_3,
40           gt_amort_sch     TYPE TABLE OF ZFI_TAX_SEC42_4,
41           gs_amort_sch     TYPE ZFI_TAX_SEC42_4,
42           gt_amort_instl   TYPE TABLE OF ZFI_TAX_SEC42_5,
43           gs_amort_instl   TYPE ZFI_TAX_SEC42_5,
44           gt_current_ded   TYPE TABLE OF ty_current_deduction,
45           gs_current_ded   TYPE ty_current_deduction,
46           gt_alv type table of ty_amort_instl,
47           gs_alv type ty_amort_instl.
48
49     DATA: gv_total_balance TYPE wrbtr,
50           gv_instl_amount  TYPE wrbtr,
51           gv_instl_year    TYPE gjahr,
52           gv_counter       TYPE i.
53
54     *----------------------------------------------------------------------*
55     * Selection Screen
56     *----------------------------------------------------------------------*
57     SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
58       SELECTION-SCREEN FUNCTION KEY 1.
59       SELECTION-SCREEN FUNCTION KEY 2.
60       SELECTION-SCREEN FUNCTION KEY 3.
61       PARAMETERS:     p_jv    TYPE char6.    " Joint Venture
62       PARAMETERS:     p_bukrs TYPE bukrs.    " Company Code
63     *  PARAMETERS:     p_monat TYPE monat.    " Period
64     *  PARAMETERS:     p_gjahr TYPE gjahr.    " Fiscal Year
65     SELECTION-SCREEN END OF BLOCK b1.
66
67     SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-002.
68       PARAMETERS:     p_rev   TYPE char1 AS CHECKBOX.     " Reversal Flag
69     SELECTION-SCREEN END OF BLOCK b2.
*--- End of ZFI_TAX_SEC42_AMORT_SCH_TOP - 69 lines ---

----------------------------------------------------------------------------------------------------
Include          ZFI_TAX_SEC42_AMORT_SCH_E01               Level 1    Page 3
Object           ZFI_TAX_SEC42_AMORT_SCH                   Lines 42
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:40
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&  Include           ZFI_TAX_SEC42_AMORT_SCH_E01
3      *&---------------------------------------------------------------------*
4
5      INITIALIZATION.
6        sscrfields-functxt_01 = 'Block Master'.
7        sscrfields-functxt_02 = 'GL Master - PCP'.
8        sscrfields-functxt_03 = 'GL Master - installments'.
9
10     AT SELECTION-SCREEN.
11       CASE sscrfields-ucomm.
12         WHEN 'FC01'.
13           CALL TRANSACTION 'ZFI_TAX_SEC42_1'.
14         WHEN 'FC02'.
15           CALL TRANSACTION 'ZFI_TAX_SEC42_2'.
16         WHEN 'FC03'.
17           CALL TRANSACTION 'ZFI_TAX_SEC42_3'.
18       ENDCASE.
19     *  CLEAR sscrfields-ucomm.
20
21       IF sy-ucomm = 'CRET' or sy-ucomm = 'ONLI'.
22         IF p_bukrs IS INITIAL OR p_jv IS INITIAL .
23           MESSAGE: 'Please enter values in all the Fields' TYPE 'E'.
24         ENDIF.
25       ENDIF.
26     *  CALL SCREEN '1000'.
27
28
29     **----------------------------------------------------------------------*
30     ** Start of Selection
31     **----------------------------------------------------------------------*
32     START-OF-SELECTION.
33
34       PERFORM validate_input.
35
36       IF p_rev = 'X'.
37         PERFORM process_reversal.
38       ELSE.
39         PERFORM process_amortization.
40       ENDIF.
41
42       PERFORM display_output.
*--- End of ZFI_TAX_SEC42_AMORT_SCH_E01 - 42 lines ---

----------------------------------------------------------------------------------------------------
Include          ZFI_TAX_SEC42_AMORT_SCH_F01               Level 1    Page 4
Object           ZFI_TAX_SEC42_AMORT_SCH                   Lines 1058
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:40
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&  Include           ZFI_TAX_SEC42_AMORT_SCH_F01
3      *&---------------------------------------------------------------------*
4      *&---------------------------------------------------------------------*
5      *&      Form  F_FETCH_DATA
6      *&---------------------------------------------------------------------*
7      *       text
8      *----------------------------------------------------------------------*
9      *  -->  p1        text
10     *  <--  p2        text
11     *----------------------------------------------------------------------*
12
13     **&---------------------------------------------------------------------*
14     **& Form VALIDATE_INPUT
15     **&---------------------------------------------------------------------*
16     **& Validates selection screen input parameters
17     **&---------------------------------------------------------------------*
18     FORM validate_input.
19
20       DATA: lv_bukrs TYPE bukrs.
21
22       " Validate Company Code
23       SELECT SINGLE bukrs FROM t001
24         INTO lv_bukrs
25         WHERE bukrs = p_bukrs.
26       IF sy-subrc <> 0.
27     *    MESSAGE e001(zfi_sec42) WITH p_bukrs.
28         MESSAGE: |Company code { p_BUKRS } does not exist| type 'E'.
29         " Company code &1 does not exist
30       ENDIF.
31
32       " Validate Joint Venture exists in Block Master
33       SELECT SINGLE * FROM zfi_tax_sec42_1
34         INTO gs_block_master
35         WHERE venture_code = p_jv
36           AND bukrs        = p_bukrs.
37       IF sy-subrc <> 0.
38     *    MESSAGE e002(zfi_sec42) WITH p_jv p_bukrs.
39         MESSAGE: |Joint Venture { P_JV } not found in Block Master for company code { P_BUKRS }| TYPE 'E'.
40         " Joint Venture &1 not found in Block Master for company code &2
41       ENDIF.
42
43     ENDFORM.
44     *
45     **&---------------------------------------------------------------------*
46     **& Form PROCESS_AMORTIZATION
47     **&---------------------------------------------------------------------*
48     **& Main processing logic for amortization computation
49     **&---------------------------------------------------------------------*
50     FORM process_amortization.
51
52       " Read Block Master entries for the given JV and Company Code
53       SELECT * FROM zfi_tax_sec42_1
54         INTO TABLE gt_block_master
55         WHERE venture_code = p_jv
56           AND bukrs        = p_bukrs.
57
58       IF gt_block_master IS INITIAL.
59     *    MESSAGE s003(zfi_sec42) WITH p_jv.
60         MESSAGE: |No Block Master entries found for Joint Venture { p_JV }| type 'S'.
61         " No Block Master entries found for Joint Venture &1
62         RETURN.
63       ENDIF.
64
65       LOOP AT gt_block_master INTO gs_block_master.
66
67         CASE gs_block_master-claim_type.
68
69           WHEN 'E'.  " Exploration
70             PERFORM process_status_e.
71
72           WHEN 'P'.  " Post Commercial Production
73             PERFORM process_status_p.
74
75           WHEN OTHERS.
76     *        MESSAGE w004(zfi_sec42) WITH gs_block_master-venture_code
77     *                                     gs_block_master-claim_type.
78             MESSAGE: |Unknown claim type { gs_block_master-claim_type } for venture { gs_block_master-venture_code }| TYPE 'W'.
79             " Unknown claim type &2 for venture &1
80             CONTINUE.
81
82         ENDCASE.
83
84       ENDLOOP.
85
86     ENDFORM.
87     *
88     **&---------------------------------------------------------------------*
89     **& Form PROCESS_STATUS_E
90     **&---------------------------------------------------------------------*
91     **& Process ventures with Status E (Exploration)
92     **& Check if surrendered: if NO, skip. If YES, process.
93     **&---------------------------------------------------------------------*
94     FORM process_status_e.
95
96       DATA: lv_saknr TYPE saknr.
97
98       " If not surrendered, close the loop (skip)
99       IF gs_block_master-surrendered <> 'X'.
100        RETURN.
101      else.
102        PERFORM process_surrendered_venture.
103      ENDIF.
104    *
105    **   Venture is surrendered - read GL accounts from Table-2 (Post Commercial)
106    *  SELECT * FROM ZFI_TAX_SEC42_2
107    *    INTO TABLE gt_gl_post_comm
108    *    WHERE bukrs = p_bukrs.
109    *
110    *  IF gt_gl_post_comm IS INITIAL.
111    *    MESSAGE w005(zfi_sec42) WITH p_bukrs.
112    *    " No GL accounts found in Post Commercial table for company code &1
113    *    RETURN.
114    *  ENDIF.
115    *
116    *  " For each GL account, get balance using FAGLB03 logic
117    *  LOOP AT gt_gl_post_comm INTO gs_gl_post_comm.
118    *
119    *    " Validate GL account exists in SKB1
120    *    SELECT SINGLE saknr FROM skb1
121    *      INTO lv_saknr
122    *      WHERE bukrs = p_bukrs
123    *        AND saknr = gs_gl_post_comm-hkont.
124    *    IF sy-subrc <> 0.
125    *      MESSAGE w006(zfi_sec42) WITH gs_gl_post_comm-hkont p_bukrs.
126    *      " GL account &1 not valid in company code &2
127    *      CONTINUE.
128    *    ENDIF.
129    *
130    *    " Read GL balance from FAGLB03 (FAGLFLEXT)
131    *    PERFORM get_gl_balance
132    *      USING    gs_block_master-venture_code
133    *               gs_gl_post_comm-hkont
134    *               p_bukrs
135    *               p_gjahr
136    *               p_monat
137    *      CHANGING gv_total_balance.
138    *
139    *    " Store current year deduction in temp table
140    *    CLEAR gs_current_ded.
141    *    gs_current_ded-bukrs      = p_bukrs.
142    *    gs_current_ded-venture    = gs_block_master-venture_code.
143    *    gs_current_ded-gjahr      = p_gjahr.
144    *    gs_current_ded-hkont      = gs_gl_post_comm-hkont.
145    *    gs_current_ded-amount     = gv_total_balance.
146    *    gs_current_ded-description = 'Status E - Post Commercial GL Balance'.
147    *    APPEND gs_current_ded TO gt_current_ded.
148    *
149    *  ENDLOOP.
150
151    ENDFORM.
152    *
153    **&---------------------------------------------------------------------*
154    **& Form PROCESS_STATUS_P
155    **&---------------------------------------------------------------------*
156    **& Process ventures with Status P (Post Commercial Production)
157    **& If surrendered YES -> Table-3 (Installments), compute amort schedule
158    **& If surrendered NO  -> Table-2 (Post Commercial), get GL balances
159    **&---------------------------------------------------------------------*
160    FORM process_status_p.
161
162      IF gs_block_master-surrendered = 'X'.
163        " Surrendered: Use Table-3 GL Installments
164        PERFORM process_active_venture.
165
166    *    PERFORM process_surrendered_venture.
167      ELSE.
168        " Not surrendered: Use Table-2 GL Post Commercial
169        PERFORM process_active_venture.
170      ENDIF.
171
172    ENDFORM.
173    *
174    **&---------------------------------------------------------------------*
175    **& Form PROCESS_SURRENDERED_VENTURE
176    **&---------------------------------------------------------------------*
177    **& For surrendered ventures: compute amortization schedule
178    **& Installment = Total Amount / 10, spread over 10 years
179    **&---------------------------------------------------------------------*
180    FORM process_surrendered_venture.
181
182      DATA: lv_instl_year TYPE gjahr,
183            lv_instl_no   TYPE numc2,
184            lv_instl_amt  TYPE wrbtr,
185            lv_saknr      TYPE saknr.
186
187          IF gs_block_master-surr_date+4(2) <= '03'.
188         lv_instl_year = gs_block_master-surr_date+0(4) - 1.  " Year from surrender date
189        else.
190         lv_instl_year = gs_block_master-surr_date+0(4).  " Year from surrender date
191        ENDIF.
192
193      " Read GL accounts from Table-3 (Installments)
194      SELECT * FROM zfi_tax_sec42_3
195        INTO TABLE gt_gl_instl
196        WHERE bukrs = p_bukrs.
197
198      IF gt_gl_instl IS INITIAL.
199    *    MESSAGE w007(zfi_sec42) WITH p_bukrs.
200        MESSAGE: |No GL accounts in installment table for company code { P_BUKRS }| TYPE 'W'.
201        " No GL accounts in installment table for company code &1
202        RETURN.
203      ENDIF.
204
205      " Check if amortization schedule already exists
206    *  SELECT * FROM zfi_tax_sec42_4
207    *    INTO TABLE gt_amort_sch
208    *    WHERE venture = p_jv
209    *      AND bukrs   = p_bukrs.
210
211      " Check Date of Creation of schedule in Block Master
212    *  IF gs_block_master-sched_date IS INITIAL.
213
214      " Schedule does not exist - need to create it
215      select HKONT
216        from ZFI_TAX_SEC42_4
217        into table @data(lt_check)
218        where bukrs = @p_bukrs
219        and venture = @p_jv.
220
221    LOOP AT LT_CHECK INTO DATA(LS_CHECK).
222      DELETE GT_GL_INSTL WHERE HKONT = LS_CHECK-HKONT.
223    ENDLOOP.
224
225      LOOP AT gt_gl_instl INTO gs_gl_instl.
226     IF gs_block_master-surr_date+4(2) <= '03'.
227         lv_instl_year = gs_block_master-surr_date+0(4) - 1.  " Year from surrender date
228        else.
229         lv_instl_year = gs_block_master-surr_date+0(4).  " Year from surrender date
230        ENDIF.
231        " Validate GL in SKB1
232        SELECT SINGLE saknr FROM skb1
233          INTO lv_saknr
234          WHERE bukrs = p_bukrs
235            AND saknr = gs_gl_instl-hkont.
236        IF sy-subrc <> 0.
237          CONTINUE.
238        ENDIF.
239
240        " Get total amount from JVTO1 (JV Transaction sub-totals)
241        PERFORM get_jv_total
242          USING    gs_block_master-venture_code
243                   gs_gl_instl-hkont
244                   gs_gl_instl-flow_type
245                   p_bukrs
246                   gs_block_master-surr_date
247          CHANGING gv_total_balance.
248
249        " Compute installment: Total / 10
250        lv_instl_amt = gv_total_balance / 10.
251
252        " Create Amortization Schedule entry
253        CLEAR gs_amort_sch.
254        gs_amort_sch-bukrs     = p_bukrs.
255        gs_amort_sch-venture   = p_jv.
256        gs_amort_sch-gjahr     = lv_instl_year.
257        gs_amort_sch-hkont     = gs_gl_instl-hkont.
258        gs_amort_sch-surr_date = gs_block_master-surr_date.
259        gs_amort_sch-total_amt = gv_total_balance.
260        gs_amort_sch-instl_amt = lv_instl_amt.
261        gs_amort_sch-reversed  = ' '.
262        APPEND gs_amort_sch TO gt_amort_sch.
263    *      MODIFY ZFI_TAX_SEC42_4 FROM gs_amort_sch.
264
265        " Create 10 yearly installment entries
266
267
268        DO 10 TIMES.
269          lv_instl_no = sy-index.
270
271          CLEAR gs_amort_instl.
272          gs_amort_instl-bukrs     = p_bukrs.
273          gs_amort_instl-venture   = p_jv.
274          gs_amort_instl-gjahr     = lv_instl_year.
275          gs_amort_instl-hkont     = gs_gl_instl-hkont.
276          gs_amort_instl-surr_date = gs_block_master-surr_date.
277          gs_amort_instl-instl_amt = lv_instl_amt.
278          gs_amort_instl-instl_no  = lv_instl_no.
279          gs_amort_instl-executed  = ' '.
280          gs_amort_instl-reversed  = ' '.
281          gs_amort_instl-acct_upd  = ' '.
282
283          APPEND gs_amort_instl TO gt_amort_instl.
284    *        MODIFY ZFI_TAX_SEC42_5 FROM gs_amort_instl.
285
286          lv_instl_year = lv_instl_year + 1.
287        ENDDO.
288
289        data: lt_amort type table of ZFI_TAX_SEC42_5.
290
291      LOOP AT gt_amort_instl into gs_amort_instl.
292       READ TABLE lt_amort into data(ls_amort) with key instl_no = gs_amort_instl-instl_no hkont = gs_amort_instl-hkont.
293       IF sy-subrc is INITIAL.
294         ls_amort-instl_amt = ls_amort-instl_amt + gs_amort_instl-instl_amt.
295              modify lt_amort from ls_amort TRANSPORTING instl_amt where bukrs = gs_amort_instl-bukrs and gjahr = gs_amort_instl-gjahr and hkont = gs_amort_instl-hkont .
296       else.
297         MOVE-CORRESPONDING gs_amort_instl to ls_amort.
298         append ls_amort to lt_amort.
299       ENDIF.
300
301
302      ENDLOOP.
303
304      clear: gt_amort_instl.
305
306      ENDLOOP.
307
308
309        gt_amort_instl = lt_amort.
310
311
312
313
314
315    *    " Update Block Master with schedule creation date
316    *    gs_block_master-sched_date = sy-datum.
317    *    MODIFY ZFI_TAX_SEC42_1 FROM gs_block_master.
318    *    IF sy-subrc is INITIAL.
319    *      MESSAGE: 'Program Succesfully executed' type 'S'.
320    *    ENDIF.
321
322    *  ENDIF.
323
324    *   Pick current year installment for deduction
325    *  SELECT SINGLE * FROM zfi_tax_sec42_5
326    *    INTO gs_amort_instl
327    *    WHERE venture  = p_jv
328    *      AND bukrs    = p_bukrs
329    *      AND gjahr    = gs_block_master-sched_date+0(4)
330    *      AND executed = ' '
331    *      AND reversed = ' '.
332
333    *  IF sy-subrc = 0.
334    **     Store deduction
335    *    CLEAR gs_current_ded.
336    *    gs_current_ded-bukrs      = p_bukrs.
337    *    gs_current_ded-venture    = gs_block_master-venture_code.
338    *    gs_current_ded-gjahr      = p_gjahr.
339    *    gs_current_ded-hkont      = gs_amort_instl-hkont.
340    *    gs_current_ded-amount     = gs_amort_instl-instl_amt.
341    *    gs_current_ded-description = 'Status P - Surrendered Installment'.
342    *    APPEND gs_current_ded TO gt_current_ded.
343    *
344    **     Mark installment as executed
345    *    gs_amort_instl-executed = 'X'.
346    **    MODIFY ZFI_TAX_SEC42_5 FROM gs_amort_instl.
347    *  ENDIF.
348
349    ENDFORM.
350    *
351    **&---------------------------------------------------------------------*
352    **& Form PROCESS_ACTIVE_VENTURE
353    **&---------------------------------------------------------------------*
354    **& For active (not surrendered) Status P ventures
355    **& Read from Table-2 and get GL balances
356    **&---------------------------------------------------------------------*
357    FORM process_active_venture.
358
359      DATA: lv_saknr TYPE saknr.
360      DATA: lv_instl_year TYPE gjahr,
361            lv_instl_no   TYPE numc2,
362            lv_instl_amt  TYPE wrbtr.
363
364      " Read GL accounts from Table-2 (Post Commercial Production)
365      SELECT * FROM zfi_tax_sec42_2
366        INTO TABLE gt_gl_post_comm
367        WHERE bukrs = p_bukrs.
368
369      IF gt_gl_post_comm IS INITIAL.
370        RETURN.
371      ENDIF.
372
373        select HKONT
374        from ZFI_TAX_SEC42_4
375        into table @data(lt_check)
376        where bukrs = @p_bukrs
377        and venture = @p_jv.
378
379    LOOP AT LT_CHECK INTO DATA(LS_CHECK).
380      DELETE GT_GL_POST_COMM WHERE HKONT = LS_CHECK-HKONT.
381    ENDLOOP.
382
383      LOOP AT gt_gl_post_comm INTO gs_gl_post_comm.
384        IF gs_block_master-prod_date+4(2) <= '03'.
385         lv_instl_year = gs_block_master-prod_date+0(4) - 1.  " Year from surrender date
386        else.
387         lv_instl_year = gs_block_master-prod_date+0(4).  " Year from surrender date
388        ENDIF.
389        " Validate GL in SKB1
390        SELECT SINGLE saknr FROM skb1
391          INTO lv_saknr
392          WHERE bukrs = p_bukrs
393            AND saknr = gs_gl_post_comm-hkont.
394        IF sy-subrc <> 0.
395          CONTINUE.
396        ENDIF.
397
398        PERFORM get_jv_total
399          USING    gs_block_master-venture_code
400                   gs_gl_post_comm-hkont
401                   gs_gl_post_comm-flow_type
402                   p_bukrs
403                   gs_block_master-prod_date
404          CHANGING gv_total_balance.
405
406
407    *    DATA: LV_DATE TYPE DATS.
408    *    DATA(LV_MONTH) = GS_BLOCK_MASTER-prod_date+4(2).
409    *    LV_MONTH = LV_MONTH + 1.
410    *    CONCATENATE GS_BLOCK_MASTER-prod_date+0(4) LV_MONTH '01' INTO LV_DATE.
411    *    SELECT SUM( hsl ) AS HSL
412    *      FROM JVSO1
413    *      INTO @GV_TOTAL_BALANCE
414    *      WHERE rbukrs = @P_bukrs
415    *AND rjvnam = @p_jv
416    *AND racct  = @gs_gl_post_comm-hkont
417    *AND BUDAT  < @LV_DATE
418    *AND ranbwa = @gs_gl_post_comm-flow_type
419    *      AND RLDNR = '4A'
420    *      AND ryear = @lv_instl_year.
421    *
422    *        SELECT
423    *    sum( hslvt ) as hslvt
424    *          INTO @DATA(lv_total_balance)
425    *FROM jvto1
426    *WHERE rbukrs = @p_bukrs
427    *AND rjvnam = @p_jv
428    *AND racct  = @gs_gl_post_comm-hkont
429    *AND ryear  = @lv_instl_year
430    *AND ranbwa = @gs_gl_post_comm-flow_type
431    *    and RLDNR = '4A' and
432    *          ryear = @lv_instl_year.
433    *
434    *          gv_total_balance = gv_total_balance + lv_total_balance.
435              lv_instl_amt = gv_total_balance / 10.
436
437              CLEAR gs_amort_sch.
438        gs_amort_sch-bukrs     = p_bukrs.
439        gs_amort_sch-venture   = gs_block_master-venture_code.
440        gs_amort_sch-gjahr     = GS_BLOCK_MASTER-prod_date+0(4).
441        gs_amort_sch-hkont     = gs_gl_post_comm-hkont.
442        IF GS_BLOCK_MASTER-surr_date IS NOT INITIAL.
443        gs_amort_sch-surr_date = gs_block_master-surr_date.
444        ENDIF.
445        gs_amort_sch-total_amt = gv_total_balance.
446        gs_amort_sch-instl_amt = lv_instl_amt.
447        gs_amort_sch-reversed  = ' '.
448        APPEND gs_amort_sch TO gt_amort_sch.
449
450
451
452         DO 10 TIMES.
453          lv_instl_no = sy-index.
454
455          CLEAR gs_amort_instl.
456          gs_amort_instl-bukrs     = p_bukrs.
457          gs_amort_instl-venture   = gs_block_master-venture_code.
458          gs_amort_instl-gjahr     = lv_instl_year.
459          gs_amort_instl-hkont     = gs_gl_post_comm-hkont.
460        IF GS_BLOCK_MASTER-surr_date IS NOT INITIAL.
461          gs_amort_instl-surr_date = gs_block_master-surr_date.
462        ENDIF.
463          gs_amort_instl-instl_amt = lv_instl_amt.
464          gs_amort_instl-instl_no  = lv_instl_no.
465          gs_amort_instl-executed  = ' '.
466          gs_amort_instl-reversed  = ' '.
467          gs_amort_instl-acct_upd  = ' '.
468
469          APPEND gs_amort_instl TO gt_amort_instl.
470    *        MODIFY ZFI_TAX_SEC42_5 FROM gs_amort_instl.
471
472          lv_instl_year = lv_instl_year + 1.
473        ENDDO.
474
475        " Get GL balance via JVTO1
476    *    PERFORM get_jv_total
477    *      USING    gs_block_master-venture_code
478    *               gs_gl_post_comm-hkont
479    *               gs_gl_post_comm-flow_type
480    *               p_bukrs
481    *               gs_block_master-surr_date
482    *               p_gjahr
483    *               p_monat
484    *      CHANGING gv_total_balance.
485
486        " Store current year deduction
487          data: lt_amort type table of ZFI_TAX_SEC42_5.
488
489      LOOP AT gt_amort_instl into gs_amort_instl.
490       READ TABLE lt_amort into data(ls_amort) with key instl_no = gs_amort_instl-instl_no hkont = gs_amort_instl-hkont.
491       IF sy-subrc is INITIAL.
492         ls_amort-instl_amt = ls_amort-instl_amt + gs_amort_instl-instl_amt.
493         modify lt_amort from ls_amort TRANSPORTING instl_amt where bukrs = gs_amort_instl-bukrs and gjahr = gs_amort_instl-gjahr and hkont = gs_amort_instl-hkont .
494       else.
495         MOVE-CORRESPONDING gs_amort_instl to ls_amort.
496         append ls_amort to lt_amort.
497       ENDIF.
498      ENDLOOP.
499
500      clear:  gt_amort_instl.
501
502
503
504
505        CLEAR gs_current_ded.
506        gs_current_ded-bukrs      = p_bukrs.
507        gs_current_ded-venture    = gs_block_master-venture_code.
508        gs_current_ded-gjahr      = gs_block_master-prod_date+0(4).
509        gs_current_ded-hkont      = gs_gl_post_comm-hkont.
510        gs_current_ded-amount     = gv_total_balance.
511        gs_current_ded-description = 'Status P - Active GL Balance'.
512        APPEND gs_current_ded TO gt_current_ded.
513
514      ENDLOOP.
515      gt_amort_instl = lt_amort.
516    ENDFORM.
517    *
518    **&---------------------------------------------------------------------*
519    **& Form PROCESS_REVERSAL
520    **&---------------------------------------------------------------------*
521    **& Reversal of ZFI_CIT_AMORT entries
522    **& Marks installment rows as reversed and resets executed flags
523    **&---------------------------------------------------------------------*
524    FORM process_reversal.
525
526      DATA: lt_amort_instl TYPE TABLE OF zfi_tax_sec42_5.
527
528      " Read all installment entries for the venture/year
529      SELECT * FROM zfi_tax_sec42_5
530        INTO TABLE lt_amort_instl
531        WHERE venture = p_jv
532          AND bukrs   = p_bukrs.
533
534      IF lt_amort_instl IS INITIAL.
535        MESSAGE s008(zfi_sec42) WITH p_jv.
536        MESSAGE: |No amortization entries found for venture { P_JV }| TYPE 'S'.
537        " No amortization entries found for venture &1
538        RETURN.
539      ENDIF.
540
541      " Mark all rows as reversed, reset executed flag
542      LOOP AT lt_amort_instl INTO gs_amort_instl.
543        gs_amort_instl-reversed = 'X'.
544        gs_amort_instl-executed = ' '.
545        MODIFY zfi_tax_sec42_5 FROM gs_amort_instl.
546      ENDLOOP.
547
548      " Update Amortization Schedule - mark as reversed
549      SELECT * FROM zfi_tax_sec42_4
550        INTO TABLE gt_amort_sch
551        WHERE venture = p_jv
552          AND bukrs   = p_bukrs.
553
554      LOOP AT gt_amort_sch INTO gs_amort_sch.
555        gs_amort_sch-reversed = 'X'.
556        MODIFY zfi_tax_sec42_4 FROM gs_amort_sch.
557      ENDLOOP.
558
559    *  MESSAGE s009(zfi_sec42) WITH p_jv  gs_block_master-surr_date+0(4).
560      MESSAGE: |Reversal completed for venture { P_JV } fiscal year { gs_block_master-surr_date+0(4) }| TYPE 'S'.
561      " Reversal completed for venture &1 fiscal year &2
562
563    ENDFORM.
564    *
565    **&---------------------------------------------------------------------*
566    **& Form GET_GL_BALANCE
567    **&---------------------------------------------------------------------*
568    **& Read GL account balance (FAGLB03 equivalent)
569    **& Uses FAGLFLEXT for balance retrieval (ECC 6.0 New GL)
570    **&---------------------------------------------------------------------*
571    *FORM get_gl_balance
572    *  USING    iv_venture  TYPE char6
573    *           iv_hkont    TYPE hkont
574    *           iv_bukrs    TYPE bukrs
575    *           iv_gjahr    TYPE gjahr
576    *           iv_monat    TYPE monat
577    *  CHANGING cv_balance  TYPE wrbtr.
578    *
579    *  cv_balance = 0.
580    *
581    *  " Read from FAGLFLEXT (New GL totals table - ECC 6.0)
582    *  " Sum period columns up to the requested period
583    *  DATA: lv_hsl01 TYPE wrbtr, lv_hsl02 TYPE wrbtr,
584    *        lv_hsl03 TYPE wrbtr, lv_hsl04 TYPE wrbtr,
585    *        lv_hsl05 TYPE wrbtr, lv_hsl06 TYPE wrbtr,
586    *        lv_hsl07 TYPE wrbtr, lv_hsl08 TYPE wrbtr,
587    *        lv_hsl09 TYPE wrbtr, lv_hsl10 TYPE wrbtr,
588    *        lv_hsl11 TYPE wrbtr, lv_hsl12 TYPE wrbtr.
589    *
590    *  cv_balance = 0.
591    *
592    *  SELECT SUM( hsl01 ) SUM( hsl02 ) SUM( hsl03 )
593    *         SUM( hsl04 ) SUM( hsl05 ) SUM( hsl06 )
594    *         SUM( hsl07 ) SUM( hsl08 ) SUM( hsl09 )
595    *         SUM( hsl10 ) SUM( hsl11 ) SUM( hsl12 )
596    *    INTO (lv_hsl01, lv_hsl02, lv_hsl03,
597    *          lv_hsl04, lv_hsl05, lv_hsl06,
598    *          lv_hsl07, lv_hsl08, lv_hsl09,
599    *          lv_hsl10, lv_hsl11, lv_hsl12)
600    *    FROM faglflext
601    *    WHERE rbukrs = iv_bukrs
602    *      AND racct  = iv_hkont
603    *      AND gjahr  = iv_gjahr.
604    *
605    *  " Sum up to the requested period
606    *  IF iv_monat >= '01'. cv_balance = cv_balance + lv_hsl01. ENDIF.
607    *  IF iv_monat >= '02'. cv_balance = cv_balance + lv_hsl02. ENDIF.
608    *  IF iv_monat >= '03'. cv_balance = cv_balance + lv_hsl03. ENDIF.
609    *  IF iv_monat >= '04'. cv_balance = cv_balance + lv_hsl04. ENDIF.
610    *  IF iv_monat >= '05'. cv_balance = cv_balance + lv_hsl05. ENDIF.
611    *  IF iv_monat >= '06'. cv_balance = cv_balance + lv_hsl06. ENDIF.
612    *  IF iv_monat >= '07'. cv_balance = cv_balance + lv_hsl07. ENDIF.
613    *  IF iv_monat >= '08'. cv_balance = cv_balance + lv_hsl08. ENDIF.
614    *  IF iv_monat >= '09'. cv_balance = cv_balance + lv_hsl09. ENDIF.
615    *  IF iv_monat >= '10'. cv_balance = cv_balance + lv_hsl10. ENDIF.
616    *  IF iv_monat >= '11'. cv_balance = cv_balance + lv_hsl11. ENDIF.
617    *  IF iv_monat >= '12'. cv_balance = cv_balance + lv_hsl12. ENDIF.
618    *
619    *ENDFORM.
620    *
621    **&---------------------------------------------------------------------*
622    **& Form GET_JV_TOTAL
623    **&---------------------------------------------------------------------*
624    **& Get JV transaction sub-totals from JVTO1
625    **&---------------------------------------------------------------------*
626    FORM get_jv_total
627      USING    iv_venture   TYPE char6
628               iv_hkont     TYPE hkont
629               iv_flow_type TYPE char3
630               iv_bukrs     TYPE bukrs
631               iv_date TYPE datum
632      CHANGING cv_total     TYPE wrbtr.
633    data: iv_gjahr type int4.
634      TYPES: BEGIN OF ty_total,
635        hslvt type jvto1-hslvt,
636               hsl01 TYPE jvto1-hsl01,
637               hsl02 TYPE jvto1-hsl02,
638               hsl03 TYPE jvto1-hsl03,
639               hsl04 TYPE jvto1-hsl04,
640               hsl05 TYPE jvto1-hsl05,
641               hsl06 TYPE jvto1-hsl06,
642               hsl07 TYPE jvto1-hsl07,
643               hsl08 TYPE jvto1-hsl08,
644               hsl09 TYPE jvto1-hsl09,
645               hsl10 TYPE jvto1-hsl10,
646               hsl11 TYPE jvto1-hsl11,
647               hsl12 TYPE jvto1-hsl12,
648               hsl13 TYPE jvto1-hsl13,
649               hsl14 TYPE jvto1-hsl14,
650               hsl15 TYPE jvto1-hsl15,
651               hsl16 TYPE jvto1-hsl16,
652             END OF ty_total.
653      iv_gjahr = iv_date+0(4).
654      IF iv_date+4(2) < '4'.
655        iv_gjahr = iv_gjahr - 1.
656      ENDIF.
657
658      DATA: ls_total TYPE ty_total.
659      cv_total = 0.
660
661      " Read JV transaction totals from JVTO1
662
663      SELECT
664        sum( hslvt ) as hslvt,
665    SUM( hsl01 ) AS hsl01,
666    SUM( hsl02 ) AS hsl02,
667    SUM( hsl03 ) AS hsl03,
668    SUM( hsl04 ) AS hsl04,
669    SUM( hsl05 ) AS hsl05,
670    SUM( hsl06 ) AS hsl06,
671    SUM( hsl07 ) AS hsl07,
672    SUM( hsl08 ) AS hsl08,
673    SUM( hsl09 ) AS hsl09,
674    SUM( hsl10 ) AS hsl10,
675    SUM( hsl11 ) AS hsl11,
676    SUM( hsl12 ) AS hsl12,
677    SUM( hsl13 ) AS hsl13,
678    SUM( hsl14 ) AS hsl14,
679    SUM( hsl15 ) AS hsl15,
680    SUM( hsl16 ) AS hsl16
681    INTO CORRESPONDING FIELDS OF @ls_total
682    FROM jvto1
683    WHERE rbukrs = @iv_bukrs
684    AND rjvnam = @iv_venture
685    AND racct  = @iv_hkont
686    AND ryear  = @iv_gjahr
687    AND ranbwa = @iv_flow_type
688        and RLDNR = '4A'.
689
690      DATA: lv_count     TYPE numc2,
691            lv_fieldname TYPE string,
692            lv_loop type i.
693      FIELD-SYMBOLS: <fs_value> TYPE any.
694      lv_count = '01'.
695      lv_fieldname = |HSLVT|.
696
697        ASSIGN COMPONENT lv_fieldname OF STRUCTURE ls_total TO <fs_value>.
698        IF sy-subrc = 0.
699          cv_total = cv_total + <fs_value>.
700        ENDIF.
701
702        IF iv_date+4(2) > '03'.
703          lv_loop = iv_date+4(2) - 3.
704        else.
705          lv_loop = iv_date+4(2) + 9.
706        ENDIF.
707
708      DO lv_loop TIMES.
709        lv_fieldname = |HSL{ lv_count }|.
710
711        ASSIGN COMPONENT lv_fieldname OF STRUCTURE ls_total TO <fs_value>.
712        IF sy-subrc = 0.
713          cv_total = cv_total + <fs_value>.
714        ENDIF.
715        lv_count = lv_count + 1.
716      ENDDO.
717
718    ENDFORM.
719
720    *&---------------------------------------------------------------------*
721    *& Form DISPLAY_OUTPUT
722    *&---------------------------------------------------------------------*
723    *& Display Section 42 deduction results using ALV
724    *&---------------------------------------------------------------------*
725    FORM display_output.
726
727      DATA: lo_alv       TYPE REF TO cl_salv_table,
728            lo_columns   TYPE REF TO cl_salv_columns_table,
729            lo_column    TYPE REF TO cl_salv_column,
730            lo_functions TYPE REF TO cl_salv_functions_list,
731            lo_display   TYPE REF TO cl_salv_display_settings,
732            lx_msg       TYPE REF TO cx_salv_msg.
733
734      IF gt_amort_instl IS INITIAL.
735    *    MESSAGE s010(zfi_sec42).
736        MESSAGE: |No Section 42 deductions found for the given selection| TYPE 'S' DISPLAY LIKE 'E'.
737        " No Section 42 deductions found for the given selection
738        RETURN.
739      ELSE.
740        DELETE gt_amort_sch WHERE total_amt IS INITIAL.
741        DELETE gt_amort_instl WHERE instl_amt IS INITIAL.
742        MOVE-CORRESPONDING gt_amort_instl TO gt_alv.
743      ENDIF.
744      IF gt_amort_instl is INITIAL.
745        MESSAGE: |No Section 42 deductions found for the given selection| TYPE 'S' DISPLAY LIKE 'E'.
746        return.
747      ENDIF.
748
749      PERFORM build_fieldcat.
750
751    *--- Layout
752    *  gs_layout-zebra = 'X'.
753    *  gs_layout-colwidth_optimize = 'X'.
754
755    *--- Display ALV
756      CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
757        EXPORTING
758          i_callback_program       = sy-repid
759    *     i_callback_top_of_page   = 'TOP_OF_PAGE'
760          i_callback_pf_status_set = 'SET_PF_STATUS'
761          i_callback_user_command  = 'USER_COMMAND'
762    *     is_layout                = g_layout
763          it_fieldcat              = gt_fieldcat
764    *     it_events                = it_events
765          i_save                   = 'X'
766    *     is_variant               = l_wrk_variant
767        TABLES
768          t_outtab                 = gt_alv
769        EXCEPTIONS
770          program_error            = 1
771          OTHERS                   = 2.
772      IF sy-subrc <> 0.
773        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
774        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
775      ENDIF.
776    ENDFORM.
777    *---------------------------------------------------------------------*
778    * FORM BUILD FIELDCAT
779    *---------------------------------------------------------------------*
780    FORM build_fieldcat.
781
782      DEFINE add_field.
783        gs_fieldcat-fieldname = &1.
784        gs_fieldcat-seltext_m = &2.
785        APPEND gs_fieldcat TO gt_fieldcat.
786        CLEAR gs_fieldcat.
787      END-OF-DEFINITION.
788
789      add_field 'BUKRS'     'Company Code'.
790      add_field 'VENTURE'   'Joint Venture'.
791      add_field 'GJAHR'     'Fiscal Year'.
792      add_field 'HKONT'     'GL Account'.
793      add_field 'SURR_DATE' 'Date of Surrender'.
794      add_field 'INSTL_AMT' 'Installment Amount'.
795
796    ENDFORM.
797
798    *---------------------------------------------------------------------*
799    * FORM PF STATUS
800    *---------------------------------------------------------------------*
801    FORM set_pf_status USING rt_extab TYPE slis_t_extab.
802      SET PF-STATUS 'ZALV_STATUS'.
803    ENDFORM.
804
805    *---------------------------------------------------------------------*
806    * FORM USER COMMAND
807    *---------------------------------------------------------------------*
808    FORM user_command USING r_ucomm     LIKE sy-ucomm
809                            rs_selfield TYPE slis_selfield.
810
811      CASE r_ucomm.
812
813        WHEN 'APPROVE'.
814    *      MESSAGE 'Custom Button Clicked!' TYPE 'I'.
815          IF gs_block_master-sched_date IS NOT INITIAL.
816            MESSAGE: 'Venture already processed' TYPE 'E'.
817          ENDIF.
818
819          gs_block_master-sched_date = sy-datum.
820          MODIFY zfi_tax_sec42_1 FROM gs_block_master.
821          IF sy-subrc IS INITIAL.
822            MESSAGE: 'Program Succesfully executed' TYPE 'S'.
823          ENDIF.
824
825          MODIFY zfi_tax_sec42_5 FROM TABLE gt_amort_instl.
826          MODIFY zfi_tax_sec42_4 FROM TABLE gt_amort_sch.
827      ENDCASE.
828
829    ENDFORM.
830
831    *---------------------------------------------------------------------*
832    * FORM DUMMY DATA (REMOVE IN REAL CODE)
833    *---------------------------------------------------------------------*
834
835
836    *
837    *  TRY.
838    *      cl_salv_table=>factory(
839    *        IMPORTING r_salv_table = lo_alv
840    *        CHANGING  t_table      = gt_alv ).
841    *
842    **       Enable ALV functions (sort, filter, export)
843    *      lo_functions = lo_alv->get_functions( ).
844    *      lo_functions->set_all( abap_true ).
845    *
846    **       Set column texts
847    *      lo_columns = lo_alv->get_columns( ).
848    *      lo_columns->set_optimize( abap_true ).
849    *
850    *      lo_column = lo_columns->get_column( 'BUKRS' ).
851    *      lo_column->set_short_text( 'CoCd' ).
852    *      lo_column->set_medium_text( 'Company Code' ).
853    *
854    *      lo_column = lo_columns->get_column( 'VENTURE' ).
855    *      lo_column->set_short_text( 'JV' ).
856    *      lo_column->set_medium_text( 'Joint Venture' ).
857    *
858    *      lo_column = lo_columns->get_column( 'GJAHR' ).
859    *      lo_column->set_short_text( 'FY' ).
860    *      lo_column->set_medium_text( 'Fiscal Year' ).
861    *
862    *      lo_column = lo_columns->get_column( 'HKONT' ).
863    *      lo_column->set_short_text( 'GL Acct' ).
864    *      lo_column->set_medium_text( 'GL Account' ).
865    *
866    *      lo_column = lo_columns->get_column( 'SURR_DATE' ).
867    *      lo_column->set_short_text( 'Surr Date' ).
868    *      lo_column->set_medium_text( 'Date of Surrender' ).
869    *
870    *      lo_column = lo_columns->get_column( 'INSTL_AMT' ).
871    *      lo_column->set_short_text( 'Amount' ).
872    *      lo_column->set_medium_text( 'Installment Amount' ).
873    **       Set display title
874    *      lo_display = lo_alv->get_display_settings( ).
875    *      lo_display->set_list_header( 'Section 42 Deductions - Current Year' ).
876    *      lo_display->set_striped_pattern( abap_true ).
877    *
878    *      lo_alv->display( ).
879    *
880    *    CATCH cx_salv_msg INTO lx_msg.
881    *      MESSAGE lx_msg TYPE 'E'.
882    *  ENDTRY.
883
884    *ENDFORM.
885
886
887
888
889
890
891
892    *FORM f_fetch_data .
893    *
894    *  DATA: lt_sec42_1 TYPE TABLE OF zfi_tax_sec42_1,
895    *        lt_sec42_3 TYPE TABLE OF zfi_tax_sec42_3,
896    *        lt_jvto1   TYPE TABLE OF jvto1,
897    *        lt_amort   TYPE TABLE OF zfi_tax_sec42_4,
898    *        ls_amort   TYPE zfi_tax_sec42_4.
899    *
900    *  "--- Fetch master tables
901    *  SELECT *
902    *    FROM zfi_tax_sec42_1
903    *    INTO TABLE @lt_sec42_1
904    *    WHERE vname = @p_jv
905    *      AND bukrs = @p_bukrs.
906    *
907    *  SELECT *
908    *    FROM zfi_tax_sec42_3
909    *    INTO TABLE @lt_sec42_3
910    *    WHERE bukrs = @p_bukrs.
911    *
912    *    IF lt_sec42_3 IS NOT INITIAL.
913    *
914    *  SELECT rldnr, ranbwa, tsl01, ryear, rpmax, rjvnam
915    *    FROM jvto1
916    *    INTO TABLE @data(lt_jvto1_tmp)
917    *    FOR ALL ENTRIES IN @lt_sec42_3
918    *    WHERE rldnr = @lt_sec42_3-saknr
919    *      AND ranbwa = @lt_sec42_3-flow_type
920    *      AND rpmax <= @p_rpmax.
921    *
922    *ENDIF.
923    *
924    *  IF lt_sec42_1 IS INITIAL.
925    *    RETURN.
926    *  ENDIF.
927    *
928    *  LOOP AT lt_sec42_1 INTO DATA(ls_sec42_1).
929    *
930    *    "-------------------------------
931    *    " CASE 1: STATUS = E
932    *    "-------------------------------
933    *    IF ls_sec42_1-claim_type = 'E'.
934    *
935    *      IF ls_sec42_1-status IS INITIAL.
936    *        " Close loop
937    *        CONTINUE.
938    *      ENDIF.
939    *
940    *    "-------------------------------
941    *    " CASE 2: STATUS = P
942    *    "-------------------------------
943    *    ELSEIF ls_sec42_1-claim_type = 'P'.
944    *
945    *      IF ls_sec42_1-status = 'X'.
946    *
947    *        " Fetch JVTO1 data once per GL + Flow type
948    *        LOOP AT lt_sec42_3 INTO DATA(ls_sec42_3).
949    **
950    **          SELECT rldnr, ranbwa, TSL01, ryear, rpmax, RJVNAM
951    **            FROM jvto1
952    **            INTO TABLE @DATA(lt_jvto1_tmp)
953    **            WHERE rldnr = @ls_sec42_3-saknr
954    **              AND ranbwa = @ls_sec42_3-flow_type
955    **              and rpmax <= @p_rpmax.
956    *
957    *          " Filter up to surrender period
958    *          LOOP AT lt_jvto1_tmp INTO DATA(ls_jvto1)
959    *               WHERE rpmax <= p_rpmax.
960    *
961    *            CLEAR ls_amort.
962    *            ls_amort-bukrs      = p_bukrs.
963    *            ls_amort-VNAME         = lS_jvto1-rjvnam.
964    *            ls_amort-RYEAR      = p_gjahr.
965    *            ls_amort-RLDNR      = ls_jvto1-rldnr.
966    *            ls_amort-surrENDER_date  = ls_sec42_1-surrender_date.
967    *            ls_amort-tot_amnt    = ls_jvto1-TSL01.
968    *            APPEND ls_amort TO lt_amort.
969    *          ENDLOOP.
970    *        ENDLOOP.
971    *      ENDIF.
972    *    ENDIF.
973    *  ENDLOOP.
974    *
975    *  "-----------------------------------
976    *  " AGGREGATION (SUBTOTAL)
977    *  "-----------------------------------
978    *  SORT lt_amort BY bukrs VNAME.
979    *  DATA: lt_final TYPE TABLE OF ZFI_TAX_SEC42_4.
980    *  DATA: ls_final TYPE ZFI_TAX_SEC42_4.
981    **
982    *  LOOP AT lt_amort INTO DATA(ls_data).
983    *    ls_final-bukrs     = ls_data-bukrs.
984    *    ls_final-vname        = ls_data-VNAME.
985    *    ls_final-ryear     = ls_data-RYEAR.
986    *    ls_final-rldnr     = ls_data-RLDNR.
987    *    ls_final-surrender_date = ls_data-surrender_date.
988    *
989    *    READ TABLE lt_final TRANSPORTING NO FIELDS with key bukrs = ls_final-bukrs vname = ls_final-vname.
990    *    IF sy-subrc is INITIAL.
991    *      ls_final-tot_amnt = ls_final-tot_amnt + ls_data-RLDNR.
992    *      ls_final-installment = ls_final-tot_amnt / 10.
993    *      modify lt_final from ls_final.
994    *    else.
995    *      ls_final-tot_amnt = ls_data-RLDNR.
996    *      ls_final-installment = ls_final-tot_amnt / 10.
997    *      append ls_final to lt_final.
998    *
999    *    ENDIF.
1000   *  ENDLOOP.
1001   *
1002   **  "-----------------------------------
1003   **  " INSERT INTO FINAL TABLE
1004   **  "-----------------------------------
1005   *  IF lt_final IS NOT INITIAL.
1006   *
1007   *    MODIFY ZFI_TAX_SEC42_4 FROM TABLE lt_final.
1008   *
1009   *    COMMIT WORK.
1010   *
1011   *  ENDIF.
1012   **
1013   *
1014   *
1015   *
1016   *
1017   *
1018   **select *
1019   **  from ZFI_TAX_SEC42_1
1020   **  into table @data(lt_sec42_1)
1021   **  where VNAME = @p_jv and bukrs = p_bukrs.
1022   **
1023   **select *
1024   **  from ZFI_TAX_SEC42_3
1025   **  into table @data(lt_sec42_3)
1026   **  where bukrs = p_bukrs.
1027   **
1028   **  LOOP AT lt_sec42_1 into data(ls_sec42_1).
1029   **    IF ls_sec42_1-claim_type = 'E'.
1030   **      IF ls_sec42_1-status = ' '.
1031   **        EXIT.
1032   **      ENDIF.
1033   **    ELSEIF ls_sec42_1-claim_type = 'P'.
1034   **      IF ls_sec42_1-status = 'x'.
1035   **        LOOP AT lt_sec42_3 into data(ls_sec42_3).
1036   **          select *
1037   **            from jvto1
1038   **            into table @data(lt_jvto1)
1039   **            where rldnr = ls_sec42_3-saknr and
1040   **            RANBWA = ls_sec42_3-flow_type.
1041   **
1042   **        ENDLOOP.
1043   **      ENDIF.
1044   **    ENDIF.
1045   **  ENDLOOP.
1046   *
1047   *ENDFORM.
1048   **&---------------------------------------------------------------------*
1049   **&      Form  F_MANIPULATE_DATA
1050   **&---------------------------------------------------------------------*
1051   **       text
1052   **----------------------------------------------------------------------*
1053   **  -->  p1        text
1054   **  <--  p2        text
1055   **----------------------------------------------------------------------*
1056   *FORM f_manipulate_data .
1057   *
1058   *ENDFORM.
*--- End of ZFI_TAX_SEC42_AMORT_SCH_F01 - 1058 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CABAP                                   Level 1    Page 5
Object           ZFI_TAX_SEC42_AMORT_SCH                   Lines 360
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:40
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
Generated incl.  %_CSLIS                                   Level 1    Page 6
Object           ZFI_TAX_SEC42_AMORT_SCH                   Lines 543
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:40
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
Generated incl.  <REPINI>                                  Level 1    Page 7
Object           ZFI_TAX_SEC42_AMORT_SCH                   Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:40
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
Generated incl.  <SYSINI>                                  Level 1    Page 8
Object           ZFI_TAX_SEC42_AMORT_SCH                   Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:40
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
Generated incl.  <SYSSEL>                                  Level 1    Page 9
Object           ZFI_TAX_SEC42_AMORT_SCH                   Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:40
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
Generated incl.  DB__SSEL                                  Level 1    Page 10
Object           ZFI_TAX_SEC42_AMORT_SCH                   Lines 1
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:40
----------------------------------------------------------------------------------------------------
1      * INCLUDE DB__SSEL
*--- End of DB__SSEL - 1 lines ---
