----------------------------------------------------------------------------------------------------
Main program     ZFI_TAX_POSTING                           Level 0    Page 1
Object           ZFI_TAX_POSTING                           Lines 606
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:38
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *& Report  ZFI_TAX_POSTING
3      *&---------------------------------------------------------------------*
4
5      REPORT zfi_tax_posting.
6
7      INCLUDE zfi_tax_posting_top.
8      INCLUDE zfi_tax_posting_sel.
9      INCLUDE zfi_tax_posting_e01.
10     INCLUDE zfi_tax_posting_f01.
11
12
13
14
15
16
17
18
19
20
21
22
23
24
25
26
27
28
29
30
31
32
33
34
35
36
37
38
39
40
41
42
43
44
45
46
47
48
49
50
51
52
53
54
55
56
57
58
59
60
61
62
63
64
65
66
67
68
69
70
71
72
73
74
75
76
77
78
79
80
81
82     *---------------------------------------------------------------------*
83     * DATA DECLARATION
84     *---------------------------------------------------------------------*
85     *DATA: ls_header    TYPE bapiache09,
86     *      lt_accountgl TYPE TABLE OF bapiacgl09,
87     *      ls_accountgl TYPE bapiacgl09,
88     *      lt_currency  TYPE TABLE OF bapiaccr09,
89     *      ls_currency  TYPE bapiaccr09,
90     *      lt_return    TYPE TABLE OF bapiret2,
91     *      ls_return    TYPE bapiret2.
92     *
93     *DATA: lv_obj_type TYPE bapiache09-obj_type,
94     *      lv_obj_key  TYPE bapiache09-obj_key,
95     *      lv_obj_sys  TYPE bapiache09-obj_sys.
96     *
97     *DATA: lv_date TYPE dats,
98     *      lv_fy   TYPE numc2,
99     *      lv_fy1  TYPE numc2,
100    *      lv_fy2  TYPE numc2.
101    *
102    *DATA: gt_block_master TYPE TABLE OF zfi_tax_sec42_1,
103    *      gs_block_master TYPE zfi_tax_sec42_1,
104    *      gt_gl_post_comm TYPE TABLE OF zfi_tax_sec42_2,
105    *      gs_gl_post_comm TYPE zfi_tax_sec42_2,
106    *      gt_amort_sch    TYPE TABLE OF zfi_tax_sec42_4,
107    *      gs_amort_sch    TYPE zfi_tax_sec42_4.
108    *
109    *DATA: gv_total_balance TYPE wrbtr.
110    *
111    **---------------------------------------------------------------------*
112    ** SELECTION SCREEN
113    **---------------------------------------------------------------------*
114    *PARAMETERS: p_bukrs TYPE bukrs,     " Company Code (INPUT)
115    *            p_gjahr TYPE gjahr,     " Fiscal Year (INPUT)
116    *            p_jv    TYPE jv_name.   " JV Name (INPUT)
117    *
118    **---------------------------------------------------------------------*
119    ** FETCH DATA (PROFIT CENTER FROM JV)
120    **---------------------------------------------------------------------*
121    **DATA: lt_jvto1 TYPE TABLE OF jvto1.
122    *
123    **
124    **SELECT SINGLE prctr
125    **  FROM ZFI_TAX_JV_PC
126    **  INTO @DATA(lv_jvto1)
127    **  WHERE venture = @p_jv.
128    *
129    *SELECT SINGLE *
130    *  FROM zfi_tax_sec42_4
131    *  INTO @DATA(ls_ammort)
132    *  WHERE bukrs = @p_bukrs
133    *  AND venture = @p_jv
134    *  AND gjahr = @p_gjahr.
135    *
136    *IF sy-subrc IS INITIAL.
137    *
138    *  SELECT SINGLE capex_gl, off_capex_gl
139    *    FROM zfi_tax_glpost
140    *    INTO @DATA(ls_gl)
141    *    WHERE hkont = @ls_ammort-hkont.
142    *
143    *ENDIF.
144    *
145    *SELECT SINGLE prctr
146    *  FROM zfi_tax_jv_pc
147    *  INTO @DATA(lv_prctr)
148    *  WHERE venture = @p_jv.
149    *
150    *
151    *
152    *
153    *
154    **---------------------------------------------------------------------*
155    ** START-OF-SELECTION
156    **---------------------------------------------------------------------*
157    *START-OF-SELECTION.
158    *
159    **---------------------------------------------------------------------*
160    ** 1. DOCUMENT HEADER
161    **---------------------------------------------------------------------*
162    *  DATA lv_gjahr TYPE numc4.
163    *  DATA(lv_item) = 1.
164    *  lv_gjahr = p_gjahr + 1.
165    *  CONCATENATE lv_gjahr '03' '31' INTO lv_date.
166    **
167    *  ls_header-username   = sy-uname.        " Current user
168    *  ls_header-comp_code  = p_bukrs.         " Company code (INPUT)
169    *  ls_header-doc_date = ls_header-pstng_date = ls_header-trans_date = lv_date.
170    *  ls_header-doc_type   = 'SA'.            " Document type (FI config)
171    *  ls_header-fisc_year  = p_gjahr.         " Fiscal year (INPUT)
172    *  ls_header-fis_period = '12'.   " Posting period (MM)
173    *  lv_fy = lv_date+1(2).
174    *  lv_fy1 =  lv_fy + 1.
175    *  lv_fy2 = lv_fy + 2.
176    *  CONCATENATE 'CIT - Capec Allow - AY' lv_fy1 '-' lv_fy2 INTO ls_header-header_txt.
177    **
178    ***---------------------------------------------------------------------*
179    *** 2. LOOP DATA (CREATE LINE ITEMS)
180    ***---------------------------------------------------------------------*
181    *
182    **
183    ***LOOP AT lt_ammort INTO DATA(ls_ammort).
184    **
185    **
186    *  "------------------ DEBIT LINE ------------------*
187    *  CLEAR ls_accountgl.
188    *  ls_accountgl-itemno_acc = lv_item.          " Line item number
189    *  ls_accountgl-gl_account = |{ ls_gl-capex_gl }0|..         " G/L Account (INPUT / CONFIG)
190    *  ls_accountgl-item_text = 'Capex Allow - Amorization of Exploration Cost'.
191    *  ls_accountgl-doc_type = 'SA'.
192    *  ls_accountgl-bus_area = 'JV'.
193    *  ls_accountgl-func_area = '0001'.
194    **  ls_accountgl-comp_code  = p_bukrs.
195    **  ls_accountgl-fis_period  = '12'.
196    **  ls_accountgl-fisc_year  = p_gjahr.
197    *  ls_accountgl-pstng_date = ls_accountgl-value_date = lv_date.
198    **  ls_accountgl-costcenter = LV_PRCTR.
199    **  ls_accountgl-profit_ctr  = lv_prctr.
200    **  ls_accountgl-de_cre_ind  = 'H'.
201    *  ls_accountgl-tr_part_ba  = 'JV'.
202    *  ls_accountgl-cs_trans_t  = '305'.
203    *  APPEND ls_accountgl TO lt_accountgl.
204    *
205    *  CLEAR ls_currency.
206    *  ls_currency-itemno_acc = lv_item.
207    *  ls_currency-currency   = 'INR'.             " Currency (Company Code)
208    *  ls_currency-amt_doccur = ls_ammort-instl_amt.            " Amount (POSITIVE = DEBIT)
209    *  APPEND ls_currency TO lt_currency.
210    **ENDLOOP.
211    *
212    *  lv_item = lv_item + 1.
213    *  CLEAR ls_accountgl.
214    *  ls_accountgl-itemno_acc = lv_item.          " Line item number
215    *  ls_accountgl-gl_account = ls_gl-off_capex_gl.         " G/L Account (INPUT / CONFIG)
216    *  ls_accountgl-item_text = 'Capex Allow - Amorization of Exploration Cost'.
217    *  ls_accountgl-doc_type = 'SA'.
218    *  ls_accountgl-bus_area = 'JV'.
219    *  ls_accountgl-func_area = '0001'.
220    *  ls_accountgl-comp_code  = p_bukrs.
221    *  ls_accountgl-fis_period  = '12'.
222    *  ls_accountgl-fisc_year  = p_gjahr.
223    *  ls_accountgl-pstng_date = ls_accountgl-value_date = lv_date.
224    **  ls_accountgl-costcenter = LV_PRCTR.
225    *  ls_accountgl-profit_ctr  = lv_prctr.
226    *  ls_accountgl-de_cre_ind  = 'S'.
227    *  ls_accountgl-tr_part_ba  = 'JV'.
228    *  ls_accountgl-cs_trans_t  = '305'.
229    *  APPEND ls_accountgl TO lt_accountgl.
230    *
231    *  CLEAR ls_currency.
232    *  ls_currency-itemno_acc = lv_item.
233    *  ls_currency-currency   = 'INR'.             " Currency (Company Code)
234    *  ls_currency-amt_doccur = ls_ammort-instl_amt * -1.            " Amount (POSITIVE = DEBIT)
235    *  APPEND ls_currency TO lt_currency.
236    **
237    **---------------------------------------------------------------------*
238    ** 3. OPTIONAL CHECK BEFORE POST
239    **---------------------------------------------------------------------*
240    *  CALL FUNCTION 'BAPI_ACC_DOCUMENT_CHECK'
241    *    EXPORTING
242    *      documentheader = ls_header
243    *    TABLES
244    *      accountgl      = lt_accountgl
245    *      currencyamount = lt_currency
246    *      return         = lt_return.
247    *
248    *  LOOP AT lt_return INTO ls_return WHERE type = 'E' OR type = 'A'.
249    *    WRITE: / 'CHECK ERROR:', ls_return-message.
250    *  ENDLOOP.
251    *
252    **---------------------------------------------------------------------*
253    ** 4. POST DOCUMENT
254    **---------------------------------------------------------------------*
255    *  CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
256    *    EXPORTING
257    *      documentheader = ls_header
258    *    IMPORTING
259    *      obj_type       = lv_obj_type
260    *      obj_key        = lv_obj_key
261    *      obj_sys        = lv_obj_sys
262    *    TABLES
263    *      accountgl      = lt_accountgl
264    *      currencyamount = lt_currency
265    *      return         = lt_return.
266    **---------------------------------------------------------------------*
267    ** 5. HANDLE RESPONSE
268    **---------------------------------------------------------------------*
269    *  READ TABLE lt_return INTO ls_return WITH KEY type = 'E'.
270    *
271    *  IF sy-subrc = 0.
272    *    WRITE: / 'ERROR IN POSTING:'.
273    *    LOOP AT lt_return INTO ls_return.
274    *      WRITE: / ls_return-type, ls_return-message.
275    *    ENDLOOP.
276    *
277    *    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
278    *
279    *  ELSE.
280    *    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
281    *      EXPORTING
282    *        wait = 'X'.
283    *
284    *    WRITE: / 'DOCUMENT POSTED SUCCESSFULLY'.
285    *    WRITE: / 'OBJ_KEY:', lv_obj_key.
286    *  ENDIF.
287    *
288    *
289    *
290    *  DATA: lv_saknr TYPE saknr.
291    *  DATA: lv_instl_year TYPE gjahr,
292    *        lv_instl_no   TYPE numc2,
293    *        lv_instl_amt  TYPE wrbtr.
294    *
295    *  SELECT * FROM zfi_tax_sec42_1
296    *      INTO TABLE gt_block_master
297    *      WHERE venture_code = p_jv
298    *        AND bukrs        = p_bukrs.
299    *
300    *  LOOP AT gt_block_master INTO gs_block_master.
301    *    " Read GL accounts from Table-2 (Post Commercial Production)
302    *    IF  gs_block_master-claim_type = 'P'.
303    *      SELECT * FROM zfi_tax_sec42_2
304    *        INTO TABLE gt_gl_post_comm
305    *        WHERE bukrs = p_bukrs.
306    *
307    *      IF gt_gl_post_comm IS INITIAL.
308    *        RETURN.
309    *      ENDIF.
310    *
311    *      LOOP AT gt_gl_post_comm INTO gs_gl_post_comm.
312    *        IF gs_block_master-prod_date+4(2) <= '03'.
313    *          lv_instl_year = gs_block_master-prod_date+0(4) - 1.  " Year from surrender date
314    *        ELSE.
315    *          lv_instl_year = gs_block_master-prod_date+0(4).  " Year from surrender date
316    *        ENDIF.
317    *        " Validate GL in SKB1
318    *        SELECT SINGLE saknr FROM skb1
319    *          INTO lv_saknr
320    *          WHERE bukrs = p_bukrs
321    *            AND saknr = gs_gl_post_comm-hkont.
322    *        IF sy-subrc <> 0.
323    *          CONTINUE.
324    *        ENDIF.
325    *
326    *        PERFORM get_jv_total
327    *          USING    gs_block_master-venture_code
328    *                   gs_gl_post_comm-hkont
329    *                   gs_gl_post_comm-flow_type
330    *                   p_bukrs
331    *                   gs_block_master-prod_date
332    *          CHANGING gv_total_balance.
333    *
334    *        lv_instl_amt = gv_total_balance / 10.
335    *
336    *        CLEAR gs_amort_sch.
337    *        gs_amort_sch-bukrs     = p_bukrs.
338    *        gs_amort_sch-venture   = gs_block_master-venture_code.
339    *        gs_amort_sch-gjahr     = gs_block_master-prod_date+0(4).
340    *        gs_amort_sch-hkont     = gs_gl_post_comm-hkont.
341    *        IF gs_block_master-surr_date IS NOT INITIAL.
342    *          gs_amort_sch-surr_date = gs_block_master-surr_date.
343    *        ENDIF.
344    *        gs_amort_sch-total_amt = gv_total_balance.
345    *        gs_amort_sch-instl_amt = lv_instl_amt.
346    *        gs_amort_sch-reversed  = ' '.
347    *        APPEND gs_amort_sch TO gt_amort_sch.
348    *      ENDLOOP.
349    *    ENDIF.
350    *  ENDLOOP.
351    *
352    *  DELETE gt_amort_sch WHERE instl_amt IS INITIAL.
353    *  READ TABLE gt_amort_sch INTO ls_ammort INDEX 1.
354    *  IF SY-SUBRC IS INITIAL.
355    *
356    *
357    *
358    *
359    **---------------------------------------------------------------------*
360    ** 1. DOCUMENT HEADER
361    **---------------------------------------------------------------------*
362    *  CLEAR: lt_accountgl, lt_currency.
363    **data lv_gjahr type numc4.
364    **DATA(lv_item) = 1.
365    *  lv_gjahr = p_gjahr + 1.
366    *  CONCATENATE lv_gjahr '03' '31' INTO lv_date.
367    **
368    *  ls_header-username   = sy-uname.        " Current user
369    *  ls_header-comp_code  = p_bukrs.         " Company code (INPUT)
370    *  ls_header-doc_date = ls_header-pstng_date = ls_header-trans_date = lv_date.
371    *  ls_header-doc_type   = 'SA'.            " Document type (FI config)
372    *  ls_header-fisc_year  = p_gjahr.         " Fiscal year (INPUT)
373    *  ls_header-fis_period = '12'.   " Posting period (MM)
374    *  lv_fy = lv_date+1(2).
375    *  lv_fy1 =  lv_fy + 1.
376    *  lv_fy2 = lv_fy + 2.
377    *  CONCATENATE 'CIT - Capec Allow - AY' lv_fy1 '-' lv_fy2 INTO ls_header-header_txt.
378    **
379    ***---------------------------------------------------------------------*
380    *** 2. LOOP DATA (CREATE LINE ITEMS)
381    ***---------------------------------------------------------------------*
382    *
383    **
384    ***LOOP AT lt_ammort INTO DATA(ls_ammort).
385    **
386    **
387    *  lv_item = 1.
388    *  "------------------ DEBIT LINE ------------------*
389    *  CLEAR ls_accountgl.
390    *  ls_accountgl-itemno_acc = lv_item.          " Line item number
391    *  ls_accountgl-gl_account = |{ ls_gl-capex_gl }0|..         " G/L Account (INPUT / CONFIG)
392    *  ls_accountgl-item_text = 'Capex Allow - Drilling exploration for production'.
393    *  ls_accountgl-doc_type = 'SA'.
394    *  ls_accountgl-bus_area = 'JV'.
395    *  ls_accountgl-func_area = '0001'.
396    *  ls_accountgl-comp_code  = p_bukrs.
397    *  ls_accountgl-fis_period  = '12'.
398    *  ls_accountgl-fisc_year  = p_gjahr.
399    *  ls_accountgl-pstng_date = ls_accountgl-value_date = lv_date.
400    **  ls_accountgl-costcenter = LV_PRCTR.
401    *  ls_accountgl-profit_ctr  = lv_prctr.
402    *  ls_accountgl-de_cre_ind  = 'H'.
403    *  ls_accountgl-tr_part_ba  = 'JV'.
404    *  ls_accountgl-cs_trans_t  = '305'.
405    *  APPEND ls_accountgl TO lt_accountgl.
406    *
407    *  CLEAR ls_currency.
408    *  ls_currency-itemno_acc = lv_item.
409    *  ls_currency-currency   = 'INR'.             " Currency (Company Code)
410    *  ls_currency-amt_doccur = ls_ammort-instl_amt.            " Amount (POSITIVE = DEBIT)
411    *  APPEND ls_currency TO lt_currency.
412    **ENDLOOP.
413    *
414    *  lv_item = lv_item + 1.
415    *  CLEAR ls_accountgl.
416    *  ls_accountgl-itemno_acc = lv_item.          " Line item number
417    *  ls_accountgl-gl_account = ls_gl-off_capex_gl.         " G/L Account (INPUT / CONFIG)
418    *  ls_accountgl-item_text = 'Capex Allow - Drilling exploration for production'.
419    *  ls_accountgl-doc_type = 'SA'.
420    *  ls_accountgl-bus_area = 'JV'.
421    *  ls_accountgl-func_area = '0001'.
422    *  ls_accountgl-comp_code  = p_bukrs.
423    *  ls_accountgl-fis_period  = '12'.
424    *  ls_accountgl-fisc_year  = p_gjahr.
425    *  ls_accountgl-pstng_date = ls_accountgl-value_date = lv_date.
426    **  ls_accountgl-costcenter = LV_PRCTR.
427    *  ls_accountgl-profit_ctr  = lv_prctr.
428    *  ls_accountgl-de_cre_ind  = 'S'.
429    *  ls_accountgl-tr_part_ba  = 'JV'.
430    *  ls_accountgl-cs_trans_t  = '305'.
431    *  APPEND ls_accountgl TO lt_accountgl.
432    *
433    *  CLEAR ls_currency.
434    *  ls_currency-itemno_acc = lv_item.
435    *  ls_currency-currency   = 'INR'.             " Currency (Company Code)
436    *  ls_currency-amt_doccur = ls_ammort-instl_amt * -1.            " Amount (POSITIVE = DEBIT)
437    *  APPEND ls_currency TO lt_currency.
438    **
439    **---------------------------------------------------------------------*
440    ** 3. OPTIONAL CHECK BEFORE POST
441    **---------------------------------------------------------------------*
442    *  CALL FUNCTION 'BAPI_ACC_DOCUMENT_CHECK'
443    *    EXPORTING
444    *      documentheader = ls_header
445    *    TABLES
446    *      accountgl      = lt_accountgl
447    *      currencyamount = lt_currency
448    *      return         = lt_return.
449    *
450    *  LOOP AT lt_return INTO ls_return WHERE type = 'E' OR type = 'A'.
451    *    WRITE: / 'CHECK ERROR:', ls_return-message.
452    *  ENDLOOP.
453    *
454    **---------------------------------------------------------------------*
455    ** 4. POST DOCUMENT
456    **---------------------------------------------------------------------*
457    *  CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
458    *    EXPORTING
459    *      documentheader = ls_header
460    *    IMPORTING
461    *      obj_type       = lv_obj_type
462    *      obj_key        = lv_obj_key
463    *      obj_sys        = lv_obj_sys
464    *    TABLES
465    *      accountgl      = lt_accountgl
466    *      currencyamount = lt_currency
467    *      return         = lt_return.
468    **---------------------------------------------------------------------*
469    ** 5. HANDLE RESPONSE
470    **---------------------------------------------------------------------*
471    *  READ TABLE lt_return INTO ls_return WITH KEY type = 'E'.
472    *
473    *  IF sy-subrc = 0.
474    *
475    *    data(flag1) = ' '.
476    *    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
477    *
478    *  ELSE.
479    *    FLAG1 = 'X'.
480    *    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
481    *      EXPORTING
482    *        wait = 'X'.
483    *
484    *    WRITE: / 'DOCUMENT POSTED SUCCESSFULLY'.
485    *    WRITE: / 'OBJ_KEY:', lv_obj_key.
486    *  ENDIF.
487    *  ENDIF.
488    *
489    *
490    *
491    *
492    *
493    *
494    *
495    *
496    *
497    *
498    *FORM get_jv_total
499    *  USING    iv_venture   TYPE char6
500    *           iv_hkont     TYPE hkont
501    *           iv_flow_type TYPE char3
502    *           iv_bukrs     TYPE bukrs
503    *           iv_date TYPE datum
504    *  CHANGING cv_total     TYPE wrbtr.
505    *  DATA: iv_gjahr TYPE int4.
506    *  TYPES: BEGIN OF ty_total,
507    *           hslvt TYPE jvto1-hslvt,
508    *           hsl01 TYPE jvto1-hsl01,
509    *           hsl02 TYPE jvto1-hsl02,
510    *           hsl03 TYPE jvto1-hsl03,
511    *           hsl04 TYPE jvto1-hsl04,
512    *           hsl05 TYPE jvto1-hsl05,
513    *           hsl06 TYPE jvto1-hsl06,
514    *           hsl07 TYPE jvto1-hsl07,
515    *           hsl08 TYPE jvto1-hsl08,
516    *           hsl09 TYPE jvto1-hsl09,
517    *           hsl10 TYPE jvto1-hsl10,
518    *           hsl11 TYPE jvto1-hsl11,
519    *           hsl12 TYPE jvto1-hsl12,
520    *           hsl13 TYPE jvto1-hsl13,
521    *           hsl14 TYPE jvto1-hsl14,
522    *           hsl15 TYPE jvto1-hsl15,
523    *           hsl16 TYPE jvto1-hsl16,
524    *         END OF ty_total.
525    *  iv_gjahr = iv_date+0(4).
526    *  IF iv_date+4(2) < '4'.
527    *    iv_gjahr = iv_gjahr - 1.
528    *  ENDIF.
529    *
530    *  DATA: ls_total TYPE ty_total.
531    *  cv_total = 0.
532    *
533    *  " Read JV transaction totals from JVTO1
534    *
535    *  SELECT
536    *    SUM( hslvt ) AS hslvt,
537    *SUM( hsl01 ) AS hsl01,
538    *SUM( hsl02 ) AS hsl02,
539    *SUM( hsl03 ) AS hsl03,
540    *SUM( hsl04 ) AS hsl04,
541    *SUM( hsl05 ) AS hsl05,
542    *SUM( hsl06 ) AS hsl06,
543    *SUM( hsl07 ) AS hsl07,
544    *SUM( hsl08 ) AS hsl08,
545    *SUM( hsl09 ) AS hsl09,
546    *SUM( hsl10 ) AS hsl10,
547    *SUM( hsl11 ) AS hsl11,
548    *SUM( hsl12 ) AS hsl12,
549    *SUM( hsl13 ) AS hsl13,
550    *SUM( hsl14 ) AS hsl14,
551    *SUM( hsl15 ) AS hsl15,
552    *SUM( hsl16 ) AS hsl16
553    *INTO CORRESPONDING FIELDS OF @ls_total
554    *FROM jvto1
555    *WHERE rbukrs = @iv_bukrs
556    *AND rjvnam = @iv_venture
557    *AND racct  = @iv_hkont
558    *AND ryear  = @iv_gjahr
559    *AND ranbwa = @iv_flow_type
560    *    AND rldnr = '4A'.
561    *
562    *  DATA: lv_count     TYPE numc2,
563    *        lv_fieldname TYPE string,
564    *        lv_loop      TYPE i.
565    *  FIELD-SYMBOLS: <fs_value> TYPE any.
566    **  lv_count = '01'.
567    **  lv_fieldname = |HSLVT|.
568    **
569    **    ASSIGN COMPONENT lv_fieldname OF STRUCTURE ls_total TO <fs_value>.
570    **    IF sy-subrc = 0.
571    **      cv_total = cv_total + <fs_value>.
572    **    ENDIF.
573    *
574    *  IF iv_date+4(2) > '03'.
575    *    lv_loop = iv_date+4(2) - 3.
576    *  ELSE.
577    *    lv_loop = iv_date+4(2) + 9.
578    *  ENDIF.
579    *
580    *
581    *  IF  iv_date <> p_gjahr.
582    *    lv_count = 1.
583    *    DO 16 TIMES.
584    *      lv_fieldname = |HSL{ lv_count }|.
585    *
586    *      ASSIGN COMPONENT lv_fieldname OF STRUCTURE ls_total TO <fs_value>.
587    *      IF sy-subrc = 0.
588    *        cv_total = cv_total + <fs_value>.
589    *      ENDIF.
590    *      lv_count = lv_count + 1.
591    *    ENDDO.
592    *  ELSE.
593    *    lv_count = lv_loop + 1.
594    *    DO 12 - lv_loop + 4 TIMES.
595    *      lv_fieldname = |HSL{ lv_count }|.
596    *
597    *      ASSIGN COMPONENT lv_fieldname OF STRUCTURE ls_total TO <fs_value>.
598    *      IF sy-subrc = 0.
599    *        cv_total = cv_total + <fs_value>.
600    *      ENDIF.
601    *      lv_count = lv_count + 1.
602    *    ENDDO.
603    *  ENDIF.
604    *
605    *
606    *ENDFORM.
*--- End of ZFI_TAX_POSTING - 606 lines ---

----------------------------------------------------------------------------------------------------
Include          ZFI_TAX_POSTING_TOP                       Level 1    Page 2
Object           ZFI_TAX_POSTING                           Lines 66
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:38
----------------------------------------------------------------------------------------------------
1      *---------------------------------------------------------------------*
2      *  TOP INCLUDE
3      *---------------------------------------------------------------------*
4      DATA: ls_header    TYPE bapiache09,
5            lt_accountgl TYPE TABLE OF bapiacgl09,
6            ls_accountgl TYPE bapiacgl09,
7            lt_currency  TYPE TABLE OF bapiaccr09,
8            ls_currency  TYPE bapiaccr09,
9            lt_return    TYPE TABLE OF bapiret2,
10           ls_return    TYPE bapiret2.
11
12     DATA: gv_obj_type TYPE bapiache09-obj_type,
13           gv_obj_key  TYPE bapiache09-obj_key,
14           gv_obj_sys  TYPE bapiache09-obj_sys.
15
16     DATA: gv_date    TYPE dats,
17           gv_prctr   TYPE prctr,
18           gv_gjahr   TYPE numc2,
19           gv_heading TYPE char25.
20
21     DATA: gv_item TYPE i.
22
23     DATA: gt_final_return TYPE TABLE OF bapiret2,
24           gs_final_return TYPE bapiret2.
25
26     DATA: gv_error TYPE abap_bool.
27
28     * Custom tables
29     DATA: gs_gl     TYPE zfi_tax_glpost.
30     DATA: gt_gl     TYPE table of zfi_tax_glpost.
31     DATA: gt_block_master TYPE TABLE OF zfi_tax_sec42_1,
32           gs_block_master TYPE zfi_tax_sec42_1,
33           gt_gl_post_comm TYPE TABLE OF zfi_tax_sec42_2,
34           gs_gl_post_comm TYPE zfi_tax_sec42_2,
35           gt_amort_sch    TYPE TABLE OF zfi_tax_sec42_5,
36           gs_amort_sch    TYPE zfi_tax_sec42_5.
37     DATA: gv_total_balance TYPE wrbtr.
38
39     *---------------------------------------------------------------------*
40     * DATA DECLARATION
41     *---------------------------------------------------------------------*
42     *DATA: ls_header    TYPE bapiache09,
43     *      lt_accountgl TYPE TABLE OF bapiacgl09,
44     *      ls_accountgl TYPE bapiacgl09,
45     *      lt_currency  TYPE TABLE OF bapiaccr09,
46     *      ls_currency  TYPE bapiaccr09,
47     *      lt_return    TYPE TABLE OF bapiret2,
48     *      ls_return    TYPE bapiret2.
49     *
50     *DATA: lv_obj_type TYPE bapiache09-obj_type,
51     *      lv_obj_key  TYPE bapiache09-obj_key,
52     *      lv_obj_sys  TYPE bapiache09-obj_sys.
53     *
54     *DATA: lv_date TYPE dats,
55     *      lv_fy   TYPE numc2,
56     *      lv_fy1  TYPE numc2,
57     *      lv_fy2  TYPE numc2.
58     *
59     *DATA: gt_block_master TYPE TABLE OF zfi_tax_sec42_1,
60     *      gs_block_master TYPE zfi_tax_sec42_1,
61     *      gt_gl_post_comm TYPE TABLE OF zfi_tax_sec42_2,
62     *      gs_gl_post_comm TYPE zfi_tax_sec42_2,
63     *      gt_amort_sch    TYPE TABLE OF zfi_tax_sec42_4,
64     *      gs_amort_sch    TYPE zfi_tax_sec42_4.
65     *
66     *DATA: gv_total_balance TYPE wrbtr.
*--- End of ZFI_TAX_POSTING_TOP - 66 lines ---

----------------------------------------------------------------------------------------------------
Include          ZFI_TAX_POSTING_SEL                       Level 1    Page 3
Object           ZFI_TAX_POSTING                           Lines 8
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:38
----------------------------------------------------------------------------------------------------
1      *---------------------------------------------------------------------*
2      *  SELECTION SCREEN
3      *---------------------------------------------------------------------*
4      SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME.
5      PARAMETERS: p_bukrs TYPE bukrs,
6                  p_gjahr TYPE gjahr,
7                  p_jv    TYPE jv_name.
8      SELECTION-SCREEN END OF BLOCK b1.
*--- End of ZFI_TAX_POSTING_SEL - 8 lines ---

----------------------------------------------------------------------------------------------------
Include          ZFI_TAX_POSTING_E01                       Level 1    Page 4
Object           ZFI_TAX_POSTING                           Lines 137
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:38
----------------------------------------------------------------------------------------------------
1      *---------------------------------------------------------------------*
2      *  START-OF-SELECTION
3      *---------------------------------------------------------------------*
4      START-OF-SELECTION.
5
6        DATA: lv_capex_gl   TYPE saknr,
7              lv_credit_amt TYPE wrbtr.
8        DATA: lv_gjahr1 TYPE numc2,
9              lv_gjahr2 TYPE numc2.
10
11     * Fetch data
12       PERFORM fetch_data.
13
14       IF gs_amort_sch IS INITIAL.
15         MESSAGE: 'No data found to process' TYPE 'E'.
16         RETURN.
17       ENDIF.
18
19       PERFORM prepare_date.
20       lv_capex_gl = gs_gl-capex_gl.
21       lv_credit_amt = gs_amort_sch-instl_amt * -1.
22
23     *---------------------------------------------------------------------*
24     * FIRST POSTING
25     *---------------------------------------------------------------------*
26       CLEAR: lt_accountgl, lt_currency.
27       gv_gjahr = gv_date+2(2).
28       lv_gjahr1 = gv_gjahr.
29       lv_gjahr2 = gv_gjahr + 1.
30       CONCATENATE 'CIT-Capex Allow-AY' lv_gjahr1 '-' lv_gjahr2 INTO GV_HEADING.
31       PERFORM build_header USING GV_HEADING.
32
33       gv_item = 1.
34
35       PERFORM add_gl_line USING gv_item
36             lv_capex_gl
37             gs_amort_sch-instl_amt
38             'H'
39             'Capex Allow - Amorization of Exploration Cost'.
40
41       gv_item = gv_item + 1.
42
43       PERFORM add_gl_line USING gv_item
44             gs_gl-off_capex_gl
45             lv_credit_amt
46             'S'
47             'Capex Allow - Amorization of Exploration Cost'.
48
49
50     DATA: lt_bkpf TYPE TABLE OF bkpf,
51           lt_bseg TYPE TABLE OF bseg,
52           ls_bkpf TYPE bkpf,
53           ls_bseg TYPE bseg.
54
55     * Step 1: Get headers
56     SELECT *
57       INTO TABLE lt_bkpf
58       FROM bkpf
59      WHERE blart = 'CO'
60        AND bukrs = p_bukrs
61        AND gjahr = p_gjahr.
62
63     IF lt_bkpf IS NOT INITIAL.
64
65     * Step 2: Get line items from BSEG
66       SELECT *
67         INTO TABLE lt_bseg
68         FROM bseg
69         FOR ALL ENTRIES IN lt_bkpf
70        WHERE belnr = lt_bkpf-belnr
71         AND vname = p_jv
72         AND bukrs = p_bukrs
73         AND gjahr = p_gjahr ORDER BY PRIMARY KEY.
74
75     ENDIF.
76
77     * Step 3: Check duplicate
78     LOOP AT lt_bseg INTO ls_bseg.
79
80       READ TABLE lt_bkpf INTO ls_bkpf
81            WITH KEY belnr = ls_bseg-belnr.
82
83       IF sy-subrc = 0.
84
85     * If reversed with reason 01 allow
86         IF ls_bkpf-stgrd = '01' AND LS_BSEG-sgtxt CS 'Capex Allow - Amorization of Exploration Cost'.
87           CONTINUE.
88         ELSEIF  LS_BSEG-sgtxt CS 'Capex Allow - Amorization of Exploration Cost'.
89           MESSAGE 'Duplicate document exists. Posting not allowed'
90           TYPE 'E'.
91         ENDIF.
92
93       ENDIF.
94
95     ENDLOOP.
96
97
98       PERFORM post_document.
99     *
100    **---------------------------------------------------------------------*
101    ** SECOND POSTING
102    **---------------------------------------------------------------------*
103    *  CLEAR: lt_accountgl, lt_currency.
104    *
105    *  PERFORM build_header USING GV_HEADING.
106    *
107    *  PERFORM calculate_jv_amort.
108    *
109    *  READ TABLE gt_amort_sch INTO gs_amort_sch INDEX 1.
110    *  IF sy-subrc <> 0.
111    *    MESSAGE: 'No Transactions for current Year' TYPE 'E'.
112    *    RETURN.
113    *  ENDIF.
114    *
115    *  gv_item = 1.
116    *
117    *  PERFORM add_gl_line USING gv_item
118    *        lv_capex_gl
119    *        gs_amort_sch-instl_amt
120    *        'H'
121    *        'Capex Allow - Drilling exploration for production'.
122    *
123    *  gv_item = gv_item + 1.
124    *  lv_credit_amt = gs_amort_sch-instl_amt * -1.
125    *
126    *  PERFORM add_gl_line USING gv_item
127    *        gs_gl-off_capex_gl
128    *        lv_credit_amt
129    *        'S'
130    *        'Capex Allow - Drilling exploration for production'.
131    *
132    *  PERFORM post_document.
133    *
134    *---------------------------------------------------------------------*
135    * FINAL RESULT
136    *---------------------------------------------------------------------*
137      PERFORM display_result.
*--- End of ZFI_TAX_POSTING_E01 - 137 lines ---

----------------------------------------------------------------------------------------------------
Include          ZFI_TAX_POSTING_F01                       Level 1    Page 5
Object           ZFI_TAX_POSTING                           Lines 357
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:38
----------------------------------------------------------------------------------------------------
1      *---------------------------------------------------------------------*
2      *  FORMS
3      *---------------------------------------------------------------------*
4
5      FORM fetch_data.
6      DATA: lv_first TYPE abap_bool VALUE abap_true.
7        SELECT *
8          FROM zfi_tax_sec42_5
9          INTO table gt_amort_sch
10         WHERE bukrs = p_bukrs
11           AND venture = p_jv
12           AND gjahr = p_gjahr.
13
14        LOOP AT gt_amort_sch INTO DATA(Ls_amort_sch).
15
16     * Capture first G/L only
17         IF lv_first = abap_true.
18           MOVE-CORRESPONDING ls_amort_sch TO gs_amort_sch.
19           LV_FIRST = ABAP_FALSE.
20         ELSE.
21           gs_amort_sch-instl_amt = gs_amort_sch-instl_amt + Ls_amort_sch-instl_amt.
22         ENDIF.
23
24       ENDLOOP.
25
26       IF sy-subrc IS INITIAL.
27         SELECT single *
28           FROM zfi_tax_glpost
29           INTO gs_gl
30           WHERE hkont = gs_amort_sch-hkont.
31       ENDIF.
32
33       SELECT SINGLE prctr
34         FROM zfi_tax_jv_pc
35         INTO gv_prctr
36         WHERE venture = p_jv.
37
38     ENDFORM.
39
40     *---------------------------------------------------------------------*
41     FORM prepare_date.
42
43       DATA lv_gjahr TYPE numc4.
44
45       lv_gjahr = p_gjahr + 1.
46       CONCATENATE lv_gjahr '0331' INTO gv_date.
47
48     ENDFORM.
49
50     *---------------------------------------------------------------------*
51     FORM build_header USING iv_text TYPE char25.
52
53       CLEAR ls_header.
54
55       ls_header-username   = sy-uname.
56       ls_header-comp_code  = p_bukrs.
57       ls_header-doc_date   = gv_date.
58       ls_header-pstng_date = gv_date.
59       ls_header-trans_date = gv_date.
60       ls_header-doc_type   = 'CO'.
61       ls_header-fisc_year  = p_gjahr.
62       ls_header-fis_period = '16'.
63       ls_header-header_txt = iv_text.
64       ls_header-ref_doc_no = 'Sec 42 Amort'.
65
66     ENDFORM.
67
68     *---------------------------------------------------------------------*
69     FORM add_gl_line USING iv_item iv_gl iv_amt iv_dc iv_text.
70
71       CLEAR ls_accountgl.
72       ls_accountgl-itemno_acc = iv_item.
73       ls_accountgl-gl_account = iv_gl.
74       ls_accountgl-item_text  = iv_text.
75       ls_accountgl-comp_code  = p_bukrs.
76       ls_accountgl-fis_period = '16'.
77       ls_accountgl-fisc_year  = p_gjahr.
78       ls_accountgl-pstng_date = gv_date.
79       ls_accountgl-profit_ctr = gv_prctr.
80       ls_accountgl-de_cre_ind = iv_dc.
81       ls_accountgl-doc_type = 'CO'.
82       ls_accountgl-bus_area = 'JV'.
83       ls_accountgl-func_area = '0001'.
84       ls_accountgl-value_date = gv_date.
85       ls_accountgl-tr_part_ba  = 'JV'.
86       ls_accountgl-cs_trans_t  = '305'.
87       APPEND ls_accountgl TO lt_accountgl.
88
89       CLEAR ls_currency.
90       ls_currency-itemno_acc = iv_item.
91       ls_currency-currency   = 'INR'.
92       ls_currency-amt_doccur = iv_amt.
93       APPEND ls_currency TO lt_currency.
94
95     ENDFORM.
96
97     *---------------------------------------------------------------------*
98     FORM post_document.
99
100      DATA: lt_return_local TYPE TABLE OF bapiret2,
101            ls_return_local TYPE bapiret2.
102
103      CALL FUNCTION 'BAPI_ACC_DOCUMENT_CHECK' "#EC CI_USAGE_OK[2628704]
104    "#EC CI_USAGE_OK[2438131]
105        EXPORTING
106          documentheader = ls_header
107        TABLES
108          accountgl      = lt_accountgl
109          currencyamount = lt_currency
110          return         = lt_return_local.
111
112      CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST' "#EC CI_USAGE_OK[2628704]
113    "#EC CI_USAGE_OK[2438131]
114        EXPORTING
115          documentheader = ls_header
116        IMPORTING
117          obj_type       = gv_obj_type
118          obj_key        = gv_obj_key
119          obj_sys        = gv_obj_sys
120        TABLES
121          accountgl      = lt_accountgl
122          currencyamount = lt_currency
123          return         = lt_return_local.
124
125      LOOP AT lt_return_local INTO ls_return_local.
126        APPEND ls_return_local TO gt_final_return.
127      ENDLOOP.
128
129    ENDFORM.
130
131    *---------------------------------------------------------------------*
132    FORM display_result.
133      DATA: lv_msg TYPE bapi_msg.
134      gv_error = abap_false.
135
136      LOOP AT gt_final_return INTO gs_final_return
137           WHERE type = 'E' OR type = 'A'.
138        gv_error = abap_true.
139      ENDLOOP.
140
141      IF gv_error = abap_true.
142
143        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
144
145        READ TABLE gt_final_return INTO gs_final_return WITH KEY type = 'E' row = '1'.
146        MESSAGE: gs_final_return-message TYPE 'E'.
147
148      ELSE.
149
150        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
151          EXPORTING
152            wait = 'X'.
153        LOOP AT gt_final_return INTO gs_final_return.
154          IF lv_msg IS INITIAL.
155            lv_msg = gs_final_return-message.
156          ELSE.
157            CONCATENATE lv_msg
158                        gs_final_return-message
159                   INTO lv_msg
160                   SEPARATED BY ','.
161          ENDIF.
162        ENDLOOP.
163        MESSAGE lv_msg TYPE 'S' DISPLAY LIKE 'I'.
164
165      ENDIF.
166
167    ENDFORM.
168
169    FORM calculate_jv_amort.
170
171      DATA: lv_saknr      TYPE saknr,
172            lv_instl_year TYPE gjahr,
173            lv_instl_amt  TYPE wrbtr.
174
175      CLEAR gt_amort_sch.
176
177    * Fetch Block Master
178      SELECT *
179        FROM zfi_tax_sec42_1
180        INTO TABLE gt_block_master
181        WHERE venture_code = p_jv
182          AND bukrs        = p_bukrs.
183
184      LOOP AT gt_block_master INTO gs_block_master.
185
186        IF gs_block_master-claim_type = 'P'.
187
188    * Fetch GL mapping
189          SELECT *
190            FROM zfi_tax_sec42_2
191            INTO TABLE gt_gl_post_comm
192            WHERE bukrs = p_bukrs.
193
194          IF gt_gl_post_comm IS INITIAL.
195            CONTINUE.
196          ENDIF.
197
198          LOOP AT gt_gl_post_comm INTO gs_gl_post_comm.
199
200    * Year Logic
201            IF gs_block_master-prod_date+4(2) <= '03'.
202              lv_instl_year = gs_block_master-prod_date+0(4) - 1.
203            ELSE.
204              lv_instl_year = gs_block_master-prod_date+0(4).
205            ENDIF.
206
207    * Validate GL
208            SELECT SINGLE saknr
209              INTO lv_saknr
210              FROM skb1
211              WHERE bukrs = p_bukrs
212                AND saknr = gs_gl_post_comm-hkont.
213
214            IF sy-subrc <> 0.
215              CONTINUE.
216            ENDIF.
217
218    * Get JV Balance
219            PERFORM get_jv_total
220              USING    gs_block_master-venture_code
221                       gs_gl_post_comm-hkont
222                       gs_gl_post_comm-flow_type
223                       p_bukrs
224                       gs_block_master-prod_date
225              CHANGING gv_total_balance.
226
227    * Installment Calculation
228            lv_instl_amt = gv_total_balance / 10.
229
230    * Fill amort table
231            CLEAR gs_amort_sch.
232
233            gs_amort_sch-bukrs   = p_bukrs.
234            gs_amort_sch-venture = gs_block_master-venture_code.
235            gs_amort_sch-gjahr   = lv_instl_year.
236            gs_amort_sch-hkont   = gs_gl_post_comm-hkont.
237
238            IF gs_block_master-surr_date IS NOT INITIAL.
239              gs_amort_sch-surr_date = gs_block_master-surr_date.
240            ENDIF.
241
242    *        gs_amort_sch-total_amt = gv_total_balance.
243            gs_amort_sch-instl_amt = lv_instl_amt.
244            gs_amort_sch-reversed  = space.
245
246            APPEND gs_amort_sch TO gt_amort_sch.
247
248          ENDLOOP.
249        ENDIF.
250
251      ENDLOOP.
252
253    * Remove zero entries
254      DELETE gt_amort_sch WHERE instl_amt IS INITIAL.
255
256    ENDFORM.
257
258    FORM get_jv_total
259      USING    iv_venture   TYPE char6
260               iv_hkont     TYPE hkont
261               iv_flow_type TYPE char3
262               iv_bukrs     TYPE bukrs
263               iv_date TYPE datum
264      CHANGING cv_total     TYPE wrbtr.
265
266      DATA: iv_gjahr TYPE int4.
267      DATA: lv_count     TYPE numc2,
268            lv_fieldname TYPE string,
269            lv_loop      TYPE i.
270
271      TYPES: BEGIN OF ty_total,
272               hslvt TYPE jvto1-hslvt,
273               hsl01 TYPE jvto1-hsl01,
274               hsl02 TYPE jvto1-hsl02,
275               hsl03 TYPE jvto1-hsl03,
276               hsl04 TYPE jvto1-hsl04,
277               hsl05 TYPE jvto1-hsl05,
278               hsl06 TYPE jvto1-hsl06,
279               hsl07 TYPE jvto1-hsl07,
280               hsl08 TYPE jvto1-hsl08,
281               hsl09 TYPE jvto1-hsl09,
282               hsl10 TYPE jvto1-hsl10,
283               hsl11 TYPE jvto1-hsl11,
284               hsl12 TYPE jvto1-hsl12,
285               hsl13 TYPE jvto1-hsl13,
286               hsl14 TYPE jvto1-hsl14,
287               hsl15 TYPE jvto1-hsl15,
288               hsl16 TYPE jvto1-hsl16,
289             END OF ty_total.
290      DATA: ls_total TYPE ty_total.
291      FIELD-SYMBOLS: <fs_value> TYPE any.
292
293      iv_gjahr = iv_date+0(4).
294      IF iv_date+4(2) < '4'.
295        iv_gjahr = iv_gjahr - 1.
296      ENDIF.
297      cv_total = 0.
298
299      " Read JV transaction totals from JVTO1
300      SELECT
301        SUM( hslvt ) AS hslvt,
302        SUM( hsl01 ) AS hsl01,
303        SUM( hsl02 ) AS hsl02,
304        SUM( hsl03 ) AS hsl03,
305        SUM( hsl04 ) AS hsl04,
306        SUM( hsl05 ) AS hsl05,
307        SUM( hsl06 ) AS hsl06,
308        SUM( hsl07 ) AS hsl07,
309        SUM( hsl08 ) AS hsl08,
310        SUM( hsl09 ) AS hsl09,
311        SUM( hsl10 ) AS hsl10,
312        SUM( hsl11 ) AS hsl11,
313        SUM( hsl12 ) AS hsl12,
314        SUM( hsl13 ) AS hsl13,
315        SUM( hsl14 ) AS hsl14,
316        SUM( hsl15 ) AS hsl15,
317        SUM( hsl16 ) AS hsl16
318      INTO CORRESPONDING FIELDS OF @ls_total
319      FROM jvto1
320      WHERE rbukrs = @iv_bukrs
321      AND rjvnam = @iv_venture
322      AND racct  = @iv_hkont
323      AND ryear  = @iv_gjahr
324      AND ranbwa = @iv_flow_type
325      AND rldnr = '4A'.
326
327
328      IF iv_date+4(2) > '03'.
329        lv_loop = iv_date+4(2) - 3.
330      ELSE.
331        lv_loop = iv_date+4(2) + 9.
332      ENDIF.
333
334      IF  iv_date+0(4) <> p_gjahr.
335        lv_count = 1.
336        DO 16 TIMES.
337          lv_fieldname = |HSL{ lv_count }|.
338
339          ASSIGN COMPONENT lv_fieldname OF STRUCTURE ls_total TO <fs_value>.
340          IF sy-subrc = 0.
341            cv_total = cv_total + <fs_value>.
342          ENDIF.
343          lv_count = lv_count + 1.
344        ENDDO.
345      ELSE.
346        lv_count = lv_loop + 1.
347        DO 12 - lv_loop + 4 TIMES.
348          lv_fieldname = |HSL{ lv_count }|.
349
350          ASSIGN COMPONENT lv_fieldname OF STRUCTURE ls_total TO <fs_value>.
351          IF sy-subrc = 0.
352            cv_total = cv_total + <fs_value>.
353          ENDIF.
354          lv_count = lv_count + 1.
355        ENDDO.
356      ENDIF.
357    ENDFORM.
*--- End of ZFI_TAX_POSTING_F01 - 357 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CABAP                                   Level 1    Page 6
Object           ZFI_TAX_POSTING                           Lines 360
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:38
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
Generated incl.  <REPINI>                                  Level 1    Page 7
Object           ZFI_TAX_POSTING                           Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:38
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
Object           ZFI_TAX_POSTING                           Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:38
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
Object           ZFI_TAX_POSTING                           Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:38
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
Object           ZFI_TAX_POSTING                           Lines 1
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:38
----------------------------------------------------------------------------------------------------
1      * INCLUDE DB__SSEL
*--- End of DB__SSEL - 1 lines ---
