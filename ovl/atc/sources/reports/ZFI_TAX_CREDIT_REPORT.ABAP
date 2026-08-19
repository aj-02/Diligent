----------------------------------------------------------------------------------------------------
Main program     ZFI_TAX_CREDIT_REPORT                     Level 0    Page 1
Object           ZFI_TAX_CREDIT_REPORT                     Lines 1064
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:35
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *& Report  ZFI_TAX_CREDIT_REPORT
3      *&
4      *&---------------------------------------------------------------------*
5      *&*---------------------------------------------------------------------*
6      * Program      : ZFI_TAX_CREDIT
7      * Author       : Rohit Yadav
8      * TR           : OCDK908501
9      * Date         : 18-11-2025
10     * Transaction  : ZFITAX
11     * Description  : Tax Credit Report Program
12     *---------------------------------------------------------------------*
13     *&
14     *&---------------------------------------------------------------------*
15     REPORT zfi_tax_credit_report.
16
17     INCLUDE zfi_cr_top.
18     *
19     *"<<< Added : Event Handler Class for ENTER refresh
20     *"==========================================================
21     CLASS lcl_event_handler DEFINITION.
22       PUBLIC SECTION.
23         METHODS handle_data_changed
24                       FOR EVENT data_changed OF cl_gui_alv_grid
25           IMPORTING er_data_changed.
26     ENDCLASS.
27
28     CLASS lcl_event_handler IMPLEMENTATION.
29       METHOD handle_data_changed.
30
31         LOOP AT er_data_changed->mt_mod_cells INTO DATA(ls_mod).
32
33           DATA(lv_row)   = ls_mod-row_id.
34           DATA(lv_field) = ls_mod-fieldname.
35
36           " Only when ADJ_AMOUNT changed
37           IF lv_field = 'ADJ_AMOUNT'.
38             READ TABLE lt_final INTO DATA(ls_final) INDEX lv_row.
39             IF sy-subrc = 0.
40               ls_final-adj_amount = ls_mod-value.
41               ls_final-final_amount = ls_final-amount_inr + ls_final-adj_amount.
42               MODIFY lt_final FROM ls_final INDEX lv_row.
43             ENDIF.
44           ENDIF.
45
46         ENDLOOP.
47
48         IF l_alv_grid IS BOUND.
49           l_alv_grid->refresh_table_display( ).
50         ENDIF.
51
52       ENDMETHOD.
53     ENDCLASS.
54
55     "==========================================================
56
57
58
59
60     CLASS lcl_tax_credit DEFINITION.
61
62       PUBLIC SECTION.
63         METHODS display_data.
64
65       PRIVATE SECTION.
66
67     ENDCLASS.
68
69     CLASS lcl_tax_credit IMPLEMENTATION.
70
71       METHOD display_data.
72
73         PERFORM process_data.
74         PERFORM process_print.
75
76       ENDMETHOD.
77
78     ENDCLASS.
79
80
81     START-OF-SELECTION.
82
83       DATA(lo_obj) = NEW lcl_tax_credit( ).
84       lo_obj->display_data( ).
85
86
87
88
89
90     FORM process_data.
91
92       SELECT * FROM zfitax_tran INTO TABLE @lt_data1  WHERE bukrs = @c_code AND period_from EQ @period-low AND period_to EQ @period-high AND zyear = @year.
93       IF sy-subrc IS INITIAL.
94         MESSAGE ' Creation not allowed. Data is already maintained'TYPE 'E'.
95       ENDIF .
96       SELECT capex_gl
97       FROM zfi_tax_glpost
98       INTO TABLE @DATA(lt_gl).
99     SORT LT_GL.
100      DELETE ADJACENT DUPLICATES FROM lt_gl.
101      SELECT * FROM ztax_cr_sheet INTO TABLE @lt_data WHERE bukrs = @c_code. "AND zyear = @year.
102      IF sy-subrc IS INITIAL.
103        SORT lt_data BY category sl_no.
104
105        LOOP AT lt_data INTO DATA(ls_data).
106          CLEAR: ls_final.
107          ls_final-category = ls_data-category.
108          ls_final-sl_no = ls_data-sl_no.
109          ls_final-zyear = year.
110          ls_final-bukrs = ls_data-bukrs.
111          ls_final-pariticulars = ls_data-pariticulars.
112          ls_final-acct_grp = ls_data-acct_grp.
113
114    *boc by arnav
115          IF ls_data-venture_code IS NOT INITIAL.
116
117
118            LOOP AT lt_gl INTO DATA(ls_gl).
119              SELECT SUM( hsl )
120                FROM jvso1
121                INTO @DATA(lv_amnt)
122                WHERE ryear = @year
123                AND rbukrs = @c_code
124                AND racct = @ls_gl-capex_gl
125                AND rjvnam = @ls_data-venture_code.
126            ENDLOOP.
127
128            ls_final-amount_inr = lv_amnt.
129
130
131          ENDIF.
132          CLEAR: lv_amnt.
133    *eoc by arnav
134
135
136
137
138          APPEND ls_final TO lt_final.
139        ENDLOOP.
140
141        SELECT * FROM setleaf INTO TABLE @DATA(lt_setleaf) FOR ALL ENTRIES IN @lt_data WHERE setname = @lt_data-acct_grp.
142
143        SELECT * FROM setnode INTO TABLE @DATA(lt_setnode) FOR ALL ENTRIES IN @lt_data  WHERE setname = @lt_data-acct_grp.
144        IF lt_setnode IS NOT INITIAL .
145          SELECT * FROM setleaf INTO TABLE @DATA(set_leaf1) FOR ALL ENTRIES IN @lt_setnode WHERE setname = @lt_setnode-subsetname.
146        ENDIF.
147
148
149        TYPES :BEGIN OF ls_racct,
150                 racct    TYPE faglflext-racct,
151                 acct_grp TYPE setname,
152                 subset   TYPE subsetname,
153               END OF ls_racct.
154
155        DATA: lt_racct   TYPE TABLE OF ls_racct.
156        DATA: st_racct   TYPE ls_racct.
157
158
159    *    DATA(set_leaf) = COND #( WHEN lt_setleaf IS NOT INITIAL THEN lt_setleaf ELSE set_leaf1 ).
160        LOOP AT set_leaf1 INTO DATA(ls_leaf).
161          IF ls_leaf-valsign = 'I'.
162            CASE ls_leaf-valoption.
163              WHEN 'EQ'.
164                READ TABLE lt_setnode INTO DATA(ls_node) WITH KEY subsetname = ls_leaf-setname.
165                IF sy-subrc EQ 0.
166                  st_racct-acct_grp = ls_node-setname.
167                ENDIF.
168                st_racct-subset = ls_leaf-setname.
169                st_racct-racct = ls_leaf-valfrom.
170                APPEND st_racct TO lt_racct.
171              WHEN 'BT'.
172                " Append all accounts in the range to internal table
173                DO.
174                  DATA(lv_acc) = ls_leaf-valfrom + sy-index - 1.
175                  IF lv_acc > ls_leaf-valto.
176                    EXIT.
177                  ENDIF.
178                  READ TABLE lt_setnode INTO DATA(ls_node1) WITH KEY subsetname = ls_leaf-setname.
179                  IF sy-subrc EQ 0.
180                    st_racct-acct_grp = ls_node1-setname.
181                  ENDIF.
182                  st_racct-subset = ls_leaf-setname.
183                  st_racct-racct = lv_acc.
184                  APPEND st_racct TO lt_racct.
185                ENDDO.
186            ENDCASE.
187          ENDIF.
188        ENDLOOP.
189
190
191
192        LOOP AT lt_setleaf INTO DATA(ls_leaf1).  ""2 loop
193          IF ls_leaf1-valsign = 'I'.
194            CASE ls_leaf1-valoption.
195              WHEN 'EQ'.
196    **        READ TABLE lt_setnode INTO DATA(ls_node2)
197    **             WITH KEY subsetname = ls_leaf1-setname.
198    **        IF sy-subrc = 0.
199                st_racct-acct_grp = ls_leaf1-setname..
200    **        ENDIF.
201
202                st_racct-subset = ls_leaf1-setname.
203                st_racct-racct  = ls_leaf1-valfrom.
204                APPEND st_racct TO lt_racct.
205
206              WHEN 'BT'.
207                DO.
208                  DATA(lv_acc1) = ls_leaf1-valfrom + sy-index - 1.
209                  IF lv_acc1 > ls_leaf1-valto.
210                    EXIT.
211                  ENDIF.
212
213    *          READ TABLE lt_setnode INTO DATA(ls_node3)
214    *               WITH KEY subsetname = ls_leaf1-setname.
215    *          IF sy-subrc = 0.
216                  st_racct-acct_grp = ls_leaf1-setname..
217    *          ENDIF.
218
219                  st_racct-subset = ls_leaf1-setname.
220                  st_racct-racct  = lv_acc1.
221                  APPEND st_racct TO lt_racct.
222                ENDDO.
223            ENDCASE.
224          ENDIF.
225        ENDLOOP.
226
227        break abapuser02.
228    *
229    *    LOOP AT lt_data INTO ls_data.
230    *
231    *      IF ls_data-acct_grp CP '0123456789*'.
232    *
233    *        st_racct-acct_grp = ls_data-acct_grp.
234    *        st_racct-racct = ls_data-acct_grp.
235    *        APPEND st_racct TO lt_racct.
236    *        CLEAR :st_racct , ls_data.
237    *      ENDIF.
238    *    ENDLOOP.
239
240        LOOP AT lt_racct ASSIGNING FIELD-SYMBOL(<fs_racct1>).
241
242          <fs_racct1>-racct = |{ <fs_racct1>-racct ALPHA = IN }|.
243
244        ENDLOOP.
245
246        SORT lt_racct BY acct_grp racct.
247
248
249
250        DATA: it_fl TYPE TABLE OF ty_fl.
251
252        SELECT  * FROM faglflext INTO CORRESPONDING FIELDS OF  TABLE @it_fl  FOR ALL ENTRIES IN @lt_racct WHERE racct EQ @lt_racct-racct AND ryear EQ @year AND rbukrs EQ @c_code AND rldnr EQ '0L'.
253
254        SORT it_fl BY racct.
255        SORT lt_racct BY racct.
256
257        LOOP AT it_fl ASSIGNING FIELD-SYMBOL(<fs_fl>).
258          READ TABLE lt_racct ASSIGNING FIELD-SYMBOL(<fs_racct>)
259               WITH KEY racct = <fs_fl>-racct
260               BINARY SEARCH.
261          IF sy-subrc = 0.
262            <fs_fl>-acct_grp = <fs_racct>-acct_grp.
263          ENDIF.
264        ENDLOOP.
265
266
267        SORT it_fl BY acct_grp racct.
268    *
269    *    DATA: lv_sum_hsl   TYPE faglflext-hsl01,
270    *          lv_sum_ksl   TYPE faglflext-hsl01,
271    *          lv_fieldname TYPE string.
272
273
274    *    LOOP AT it_fl INTO DATA(ls_fl).
275    *
276    *      " Initialize sum variables for this account group
277    **  CLEAR: lv_sum_hsl, lv_sum_ksl.
278    *
279    *      LOOP AT period INTO DATA(ls_range).
280    *        DATA(lv_low)  = ls_range-low.
281    *        DATA(lv_high) = ls_range-high.
282    *
283    *        IF lv_high IS INITIAL.
284    *          lv_high = lv_low.
285    *        ENDIF.
286    *
287    *        DO lv_high - lv_low + 1 TIMES.
288    *          DATA(lv_period) = lv_low + sy-index - 1.
289    *
290    *          " ---- HSL sum ----
291    *          DATA lv_hsl_field TYPE string.
292    *          IF lv_period < 10.
293    *            lv_hsl_field = |HSL0{ lv_period }|.
294    *          ELSE.
295    *            lv_hsl_field = |HSL{ lv_period }|.
296    *          ENDIF.
297    *
298    *          ASSIGN COMPONENT lv_hsl_field OF STRUCTURE ls_fl TO FIELD-SYMBOL(<fs_hsl>).
299    *          IF sy-subrc = 0 AND <fs_hsl> IS ASSIGNED.
300    *            lv_sum_hsl = lv_sum_hsl + <fs_hsl>.
301    *          ENDIF.
302    *
303    *          " ---- KSL sum ----
304    *          DATA lv_ksl_field TYPE string.
305    *          IF lv_period < 10.
306    *            lv_ksl_field = |KSL0{ lv_period }|.
307    *          ELSE.
308    *            lv_ksl_field = |KSL{ lv_period }|.
309    *          ENDIF.
310    *
311    *          ASSIGN COMPONENT lv_ksl_field OF STRUCTURE ls_fl TO FIELD-SYMBOL(<fs_ksl>).
312    *          IF sy-subrc = 0 AND <fs_ksl> IS ASSIGNED.
313    *            lv_sum_ksl = lv_sum_ksl + <fs_ksl>.
314    *          ENDIF.
315    *
316    *        ENDDO.
317    *      ENDLOOP.
318    *      " At end of account group, update total table
319    *      AT END OF acct_grp.
320    *
321    *        LOOP AT lt_final INTO DATA(ls_total) WHERE acct_grp = ls_fl-acct_grp.
322    *          ls_total-amount_inr = lv_sum_hsl. " HSL sum
323    *
324    *
325    *          MODIFY lt_final FROM ls_total.
326    *        ENDLOOP.
327    *
328    *      ENDAT.
329    *
330    *    ENDLOOP.
331
332        """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
333
334
335        SORT it_fl BY acct_grp racct.
336
337        "------------------------------------------------------
338        "  Declare sum variables and previous account group tracker
339        "------------------------------------------------------
340        DATA: lv_sum_hsl   TYPE faglflext-hsl01,
341              lv_sum_ksl   TYPE faglflext-hsl01,
342              lv_prev_acct TYPE ty_fl-acct_grp.
343
344        FIELD-SYMBOLS: <fs_hsl> TYPE faglflext-hsl01,
345                       <fs_ksl> TYPE faglflext-hsl01,
346                       <tot>    TYPE st_temp.
347
348        CLEAR: lv_sum_hsl, lv_sum_ksl, lv_prev_acct.
349
350        "------------------------------------------------------
351        "  Main LOOP over input table
352        "------------------------------------------------------
353        LOOP AT it_fl INTO DATA(ls_fl).
354
355          "-------------------------------------------
356          " Control break: if account group changed
357          "-------------------------------------------
358          IF lv_prev_acct IS NOT INITIAL AND lv_prev_acct <> ls_fl-acct_grp.
359
360    *        LOOP AT lt_total ASSIGNING <tot> WHERE acct_grp = lv_prev_acct.
361    *          <tot>-ecc_inr = lv_sum_hsl.
362    *          <tot>-ecc_usd = lv_sum_ksl.
363    *
364    *          IF <tot>-rate = 'INR_ACT'.
365    *            <tot>-final_inr = lv_sum_hsl.
366    *          ELSEIF <tot>-rate = 'AVG' AND lv_sum_hsl IS NOT INITIAL.
367    *            <tot>-final_inr = lv_sum_hsl * lv_ukurs.
368    *          ENDIF.
369    *        ENDLOOP.
370
371            LOOP AT lt_final INTO DATA(ls_total) WHERE acct_grp = lv_prev_acct.
372              ls_total-amount_inr = lv_sum_hsl. " HSL sum
373
374
375              MODIFY lt_final FROM ls_total.
376            ENDLOOP.
377
378            " Clear sums for new account group
379            CLEAR: lv_sum_hsl, lv_sum_ksl.
380
381          ENDIF.
382
383          "-------------------------------------------
384          "  HSL / KSL summation for current row
385          "-------------------------------------------
386          LOOP AT period INTO DATA(ls_range).
387            DATA(lv_low)  = ls_range-low.
388            DATA(lv_high) = ls_range-high.
389            IF lv_high IS INITIAL.
390              lv_high = lv_low.
391            ENDIF.
392
393            DO lv_high - lv_low + 1 TIMES.
394              DATA(lv_period) = lv_low + sy-index - 1.
395
396              " Build HSL field name (HSL01, HSL02 ...)
397              DATA lv_hsl_field TYPE string.
398              IF lv_period < 10.
399                lv_hsl_field = |HSL0{ lv_period }|.
400              ELSE.
401                lv_hsl_field = |HSL{ lv_period }|.
402              ENDIF.
403              ASSIGN COMPONENT lv_hsl_field OF STRUCTURE ls_fl TO <fs_hsl>.
404              IF sy-subrc = 0 AND <fs_hsl> IS ASSIGNED.
405                lv_sum_hsl = lv_sum_hsl + <fs_hsl>.
406              ENDIF.
407
408              " Build KSL field name (KSL01, KSL02 ...)
409              DATA lv_ksl_field TYPE string.
410              IF lv_period < 10.
411                lv_ksl_field = |KSL0{ lv_period }|.
412              ELSE.
413                lv_ksl_field = |KSL{ lv_period }|.
414              ENDIF.
415              ASSIGN COMPONENT lv_ksl_field OF STRUCTURE ls_fl TO <fs_ksl>.
416              IF sy-subrc = 0 AND <fs_ksl> IS ASSIGNED.
417                lv_sum_ksl = lv_sum_ksl + <fs_ksl>.
418              ENDIF.
419
420            ENDDO.
421          ENDLOOP.
422
423          "-------------------------------------------
424          "  Save current account group for next iteration
425          "-------------------------------------------
426          lv_prev_acct = ls_fl-acct_grp.
427
428        ENDLOOP.
429
430        "------------------------------------------------------
431        "  Update totals for the last account group
432        "------------------------------------------------------
433        IF lv_prev_acct IS NOT INITIAL.
434    *      LOOP AT lt_total ASSIGNING <tot> WHERE acct_grp = lv_prev_acct.
435    *        <tot>-ecc_inr = lv_sum_hsl.
436    *        <tot>-ecc_usd = lv_sum_ksl.
437    *
438    *        IF <tot>-rate = 'INR_ACT'.
439    *          <tot>-final_inr = lv_sum_hsl.
440    *        ELSEIF <tot>-rate = 'AVG' AND lv_sum_hsl IS NOT INITIAL.
441    *          <tot>-final_inr = lv_sum_hsl * lv_ukurs.
442    *        ENDIF.
443    *      ENDLOOP.
444
445          LOOP AT lt_final INTO DATA(ls_total2) WHERE acct_grp = lv_prev_acct.
446            ls_total2-amount_inr = lv_sum_hsl. " HSL sum
447
448
449            MODIFY lt_final FROM ls_total2.
450          ENDLOOP.
451
452        ENDIF.
453
454
455
456
457
458        """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""''''''''''''''''''''''''''''''''''''''''''''
459
460
461      ELSE .
462
463        MESSAGE ' Record not found' TYPE 'E'.
464
465
466      ENDIF.
467      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""''''''''''''
468
469
470      EXPORT a = a TO MEMORY ID 'ALV_RETURN1'.
471
472      SUBMIT zfitax_pbt_calc_prg
473        WITH c_code = c_code
474        WITH year   = year
475        WITH period IN period
476        AND RETURN.
477
478      IMPORT lt_total = lt_total FROM MEMORY ID 'ALV_RETURN'.
479      DATA : sum TYPE z_final_amt .
480    *  LOOP AT lt_total INTO DATA(ls_total1).
481
482      READ TABLE lt_total INTO DATA(ls_tot)  WITH KEY description = 'PROFIT/(LOSS) BEFORE TAX (V - VI)'.
483      IF sy-subrc EQ 0.
484
485        sum = ls_tot-final_inr.
486
487      ENDIF.
488
489
490    *  ENDLOOP.
491      ls_final-pariticulars = 'PROFIT'.
492    *ls_final-amount_inr  = lv_profit.   " if you have calculated profit
493      ls_final-adj_remark  = ''.
494      sum = sum * -1.
495      ls_final-amount_inr  = sum.
496      ls_final-final_amount = ''.
497      ls_final-sl_no = ' '.
498
499      ls_final-period_from = period-low.
500      ls_final-period_to = period-high.
501      ls_final-zyear =  year.
502      ls_final-bukrs = c_code.
503    *   ... fill only fields you need
504
505      INSERT ls_final INTO lt_final INDEX 1.
506      DATA: lv_amnt1 TYPE numc255.
507      data: lv_val type zdec16_5.
508      lv_amnt1 = sum.
509      CLEAR: ls_final.
510      LOOP AT lt_final ASSIGNING FIELD-SYMBOL(<ls_final>).
511    *    IF <ls_final>-category = 'M' AND <ls_final>-sl_no = '0'.
512    *      lv_amnt1 = lv_amnt1 + <ls_final>-amount_inr.
513    *    ENDIF.
514        IF <ls_final>-category = 'C' AND <ls_final>-sl_no = '20'.
515          SELECT SUM( exdiff )
516            FROM zfitax_dif
517            INTO @DATA(lv_sum1).
518          <ls_final>-amount_inr = lv_sum1.
519        ENDIF.
520        IF <ls_final>-category = 'A' OR <ls_final>-category = 'C'.
521
522          IF <ls_final>-category = 'A' AND <ls_final>-sl_no = '7'.
523
524            IF <ls_final>-amount_inr GT 0.
525              DATA(lv_flag) = 'X'.
526              CLEAR: <ls_final>-amount_inr.
527            ENDIF.
528          ENDIF.
529
530          IF <ls_final>-category = 'A'.
531            <ls_final>-amount_inr = <ls_final>-amount_inr * -1.
532          ENDIF.
533          lv_amnt1 = lv_amnt1 - <ls_final>-amount_inr.
534        ELSEIF <ls_final>-category = 'B'.
535          IF <ls_final>-sl_no = '22' AND lv_flag = ' '.
536            CLEAR: <ls_final>-amount_inr.
537          ENDIF.
538          lv_amnt1 = lv_amnt1 + <ls_final>-amount_inr.
539        ELSEIF <ls_final>-category = 'D' AND <ls_final>-sl_no = '2'.
540          <ls_final>-amount_inr = lv_amnt1.
541        ENDIF.
542      ENDLOOP.
543      UNASSIGN: <ls_final>.
544    *  CLEAR: LV_AMNT1.
545
546      SELECT *
547        FROM zfi_cit_rates
548        INTO TABLE @DATA(lt_rate1)
549        WHERE gjahr = @year.
550
551      SELECT *
552        FROM zfi_ltcg_rates
553        INTO TABLE @DATA(lt_rate2)
554        WHERE gjahr = @year.
555      SELECT *
556        FROM zfitax_tran_mat
557        INTO TABLE @DATA(lt_mat).
558
559      DATA: lv_sum2   TYPE zdec16_5,
560            lv_sum5   TYPE faglflexa-hsl,
561            ls_final1 TYPE zfi_tax_80m.
562      LOOP AT lt_final ASSIGNING <ls_final>.
563
564        IF <ls_final>-category = 'E' .
565          IF <ls_final>-sl_no = '1'.
566            DATA(lv_calc) = <ls_final>-amount_inr * -1.
567          lv_val = lv_val + <ls_final>-amount_inr.
568          ENDIF.
569          IF <ls_final>-sl_no = '2'.
570            DATA(lv_calc2) = <ls_final>-amount_inr * -1.
571          lv_val = lv_val + <ls_final>-amount_inr.
572          ENDIF.
573    *      <ls_final>-amount_inr = <ls_final>-amount_inr * -1.
574          lv_amnt1 = lv_amnt1 - <ls_final>-amount_inr.
575        ELSEIF <ls_final>-category = 'F' AND <ls_final>-sl_no = '1'.
576          <ls_final>-amount_inr = lv_amnt1.
577        ENDIF.
578        IF <ls_final>-category = 'G' AND <ls_final>-sl_no = '1'.
579          DATA: lv_date_from TYPE budat,
580                lv_date_to   TYPE budat.
581          lv_date_from = |{ year }0401|.           "01-Apr-FY
582          lv_date_to   = |{ year + 1 }1031|.       "31-Oct next year
583
584          SELECT belnr,
585                 ryear,
586                 rbukrs,
587                 hsl
588            INTO TABLE @DATA(lt_fagl)
589            FROM faglflexa
590           WHERE racct  = '0000160203'
591             AND rbukrs = @c_code
592            AND rldnr = '0L'
593             AND rassc  = 'ONGC'
594             AND budat BETWEEN @lv_date_from AND @lv_date_to.
595
596          IF sy-subrc IS INITIAL.
597            SELECT belnr,
598               gjahr,
599               bukrs,
600              BUZEI
601          INTO TABLE @DATA(lt_bseg_add)
602          FROM bseg
603          FOR ALL ENTRIES IN @lt_fagl
604         WHERE belnr = @lt_fagl-belnr
605           AND gjahr = @lt_fagl-ryear
606           AND bukrs = @lt_fagl-rbukrs
607           AND xref3 = 'DIVIDEND' ORDER BY PRIMARY KEY.
608            IF sy-subrc IS INITIAL.
609              LOOP AT lt_fagl INTO DATA(ls_fagl).
610
611                READ TABLE lt_bseg_add INTO DATA(ls_bseg)
612                     WITH KEY belnr = ls_fagl-belnr
613                              gjahr = ls_fagl-ryear
614                              bukrs = ls_fagl-rbukrs.
615
616                IF sy-subrc <> 0.
617                  CONTINUE.
618                ENDIF.
619
620                DELETE FROM zfi_tax_80m
621                 WHERE belnr = ls_fagl-belnr
622                   AND gjahr = ls_fagl-ryear
623                   AND bukrs = ls_fagl-rbukrs.
624
625                CLEAR ls_final1.
626
627                ls_final1-belnr = ls_fagl-belnr.
628                ls_final1-gjahr = ls_fagl-ryear.
629                ls_final1-bukrs = ls_fagl-rbukrs.
630                ls_final1-amnt   = ls_fagl-hsl.
631                ls_final1-claim_year = year.
632
633                INSERT zfi_tax_80m FROM ls_final1.
634
635                lv_sum5 = lv_sum5 + ls_fagl-hsl.
636
637              ENDLOOP.
638              <ls_final>-amount_inr = lv_sum5.
639            ENDIF.
640          ENDIF.
641
642
643        ENDIF.
644        IF <ls_final>-category = 'G' .
645          lv_amnt1 = lv_amnt1 - <ls_final>-amount_inr.
646        ELSEIF <ls_final>-category = 'H'.
647          <ls_final>-amount_inr = lv_amnt1.
648        ENDIF.
649        IF <ls_final>-category = 'I' AND <ls_final>-sl_no = '1'.
650          READ TABLE lt_rate1 INTO DATA(ls_rate1) INDEX 1.
651          LV_AMNT1 = LV_AMNT1 + LV_VAL.
652          <ls_final>-amount_inr = lv_amnt1 * ls_rate1-effective_cit / 100.
653          lv_sum2 = lv_sum2 + <ls_final>-amount_inr.
654        ENDIF.
655        IF <ls_final>-category = 'I' AND <ls_final>-sl_no = '10'.
656          READ TABLE lt_rate2 INTO DATA(ls_rate2) INDEX 1.
657          <ls_final>-amount_inr = lv_calc * ls_rate2-ltcg_rates / 100.
658          lv_sum2 = lv_sum2 + <ls_final>-amount_inr.
659        ENDIF.
660
661        IF <ls_final>-category = 'I' AND <ls_final>-sl_no = '20'.
662          READ TABLE lt_rate2 INTO ls_rate2 INDEX 1.
663          <ls_final>-amount_inr = lv_calc2 * ls_rate2-ltcg_rates_wi / 100.
664
665          lv_sum2 = lv_sum2 + <ls_final>-amount_inr.
666        ENDIF.
667        IF <ls_final>-category = 'J' AND <ls_final>-sl_no = '1'.
668          <ls_final>-amount_inr = lv_sum2.
669        ENDIF.
670        IF <ls_final>-category = 'J' AND <ls_final>-sl_no = '10'.
671          READ TABLE lt_mat INTO DATA(ls_mat) WITH KEY category = 'G' sl_no = '10'.
672          <ls_final>-amount_inr = ls_mat-final_amount.
673        ENDIF.
674      ENDLOOP.
675
676
677
678
679
680    ENDFORM.
681
682
683    FORM save_data .
684      DATA: lv_sum2 TYPE zdec16_5.
685      DATA: lv_sum3 TYPE zdec16_5.
686      DATA: lv_amnt1 TYPE numc255.
687      DATA: LV_VAL TYPE zdec16_5.
688    *  lv_amnt1 = sum.
689      SELECT *
690      FROM zfi_cit_rates
691      INTO TABLE @DATA(lt_rate1)
692      WHERE gjahr = @year.
693
694      SELECT *
695        FROM zfi_ltcg_rates
696        INTO TABLE @DATA(lt_rate2)
697        WHERE gjahr = @year.
698      SELECT *
699        FROM zfitax_tran_mat
700        INTO TABLE @DATA(lt_mat).
701      IF l_alv_grid IS BOUND.
702        l_alv_grid->check_changed_data(
703           IMPORTING
704             e_valid   = DATA(l_valid)                 " Entries are Consistent
705        ).
706        IF l_valid IS NOT INITIAL.
707          CALL METHOD l_alv_grid->get_selected_rows
708            IMPORTING
709              et_index_rows = it_index                 " Indexes of Selected Rows
710              et_row_no     = it_row.                " Numeric IDs of Selected Rows
711          IF it_index IS NOT INITIAL.
712            LOOP AT it_index INTO DATA(wa_index).
713              READ TABLE lt_final INTO DATA(wa_final) INDEX wa_index-index.
714              IF sy-subrc = 0.
715    *            IF wa_final-amount    IS INITIAL AND
716    *               wa_final-bukrs    IS INITIAL AND
717    *               wa_final-changes_amount    IS INITIAL AND
718    *               wa_final-gl_head   IS INITIAL AND
719    *               wa_final-zyear          IS INITIAL AND
720    *               wa_final-amount        IS INITIAL.
721    *
722    *              MESSAGE 'Please enter all details ' TYPE 'E'.
723    *            ENDIF.
724                wa_final-final_amount = wa_final-amount_inr + wa_final-adj_amount.
725                wa_final-period_from = period-low.
726                wa_final-period_to = period-high.
727                IF wa_final-category = 'M' AND wa_final-sl_no = '0'.
728                  lv_amnt1 = lv_amnt1 + wa_final-final_amount.
729                ENDIF.
730                IF wa_final-category = 'A' OR wa_final-category = 'C'.
731    *              IF wa_final-category = 'A' AND wa_final-sl_no = '7'.
732
733    *                IF wa_final-amount_inr GT 0.
734    *                  DATA(lv_flag) = 'X'.
735    *                  CLEAR: wa_final-amount_inr.
736    *                ENDIF.
737    *              ENDIF.
738
739    *              IF wa_final-category = 'A'.
740    *                wa_final-amount_inr = wa_final-amount_inr * -1.
741    *              ENDIF.
742                  lv_amnt1 = lv_amnt1 - wa_final-final_amount.
743                ELSEIF wa_final-category = 'B'.
744                  lv_amnt1 = lv_amnt1 + wa_final-final_amount.
745                ELSEIF wa_final-category = 'D' AND wa_final-sl_no = '2'.
746                  wa_final-final_amount = lv_amnt1.
747                ENDIF.
748                IF wa_final-category = 'C' AND wa_final-sl_no = '20'.
749    *              SELECT SUM( exdiff )
750    *          FROM zfitax_dif
751    *                INTO @DATA(lv_sum1).
752    *              wa_final-final_amount = lv_sum1.
753                ENDIF.
754                IF wa_final-category = 'E' .
755                  IF wa_final-sl_no = '1'.
756                    IF wa_final-final_amount < 0.
757                    DATA(lv_calc) = wa_final-final_amount * -1.
758          lv_val = lv_val + wa_final-final_amount.
759                    else.
760                    lv_calc = wa_final-final_amount * -1.
761          lv_val = lv_val + wa_final-final_amount.
762                    ENDIF.
763                  ENDIF.
764                  IF wa_final-sl_no = '2'.
765                    IF wa_final-final_amount < 0.
766                    DATA(lv_calc2) = wa_final-final_amount * -1.
767          lv_val = lv_val + WA_FINAL-final_amount.
768                    else.
769                    lv_calc2 = wa_final-final_amount * -1.
770          lv_val = lv_val + WA_FINAL-final_amount.
771                    ENDIF.
772                  ENDIF.
773    *              wa_final-final_amount = wa_final-final_amount * -1.
774                  lv_amnt1 = lv_amnt1 - wa_final-final_amount.
775                ELSEIF wa_final-category = 'F' AND wa_final-sl_no = '1'.
776                  wa_final-final_amount = lv_amnt1.
777                ENDIF.
778                IF wa_final-category = 'G' .
779                  lv_amnt1 = lv_amnt1 - wa_final-final_amount.
780                ELSEIF wa_final-category = 'H'.
781                  wa_final-final_amount = lv_amnt1.
782                ENDIF.
783                IF wa_final-category = 'I' AND wa_final-sl_no = '1'.
784                  READ TABLE lt_rate1 INTO DATA(ls_rate1) INDEX 1.
785                  LV_AMNT1 = LV_AMNT1 + LV_VAL.
786                  wa_final-final_amount = lv_amnt1 * ls_rate1-effective_cit / 100.
787                  lv_sum2 = lv_sum2 + wa_final-final_amount.
788                ENDIF.
789                IF wa_final-category = 'I' AND wa_final-sl_no = '10'.
790                  READ TABLE lt_rate2 INTO DATA(ls_rate2) INDEX 1.
791                  wa_final-final_amount = lv_calc * ls_rate2-ltcg_rates / 100.
792                  lv_sum2 = lv_sum2 + wa_final-final_amount.
793                ENDIF.
794
795                IF wa_final-category = 'I' AND wa_final-sl_no = '20'.
796                  READ TABLE lt_rate2 INTO ls_rate2 INDEX 1.
797                  wa_final-final_amount = lv_calc2 * ls_rate2-ltcg_rates_wi / 100.
798                  lv_sum2 = lv_sum2 + wa_final-final_amount.
799                ENDIF.
800                IF wa_final-category = 'J' AND wa_final-sl_no = '1'.
801                  wa_final-final_amount = lv_sum2.
802                ENDIF.
803                IF wa_final-category = 'J' AND wa_final-sl_no = '10'.
804                  READ TABLE lt_mat INTO DATA(ls_mat) WITH KEY category = 'G' sl_no = '10'.
805                  wa_final-final_amount = ls_mat-final_amount.
806                  lv_sum3 = wa_final-final_amount.
807                ENDIF.
808                IF wa_final-category = 'J' AND wa_final-sl_no = '20'.
809    *      READ TABLE lt_mat into data(ls_mat) with key category = 'G' sl_no = '10'.
810                  IF lv_sum3 > lv_sum2.
811                    wa_final-final_amount = lv_sum3.
812                  ELSE.
813                    wa_final-final_amount = lv_sum2.
814                  ENDIF.
815                ENDIF.
816
817                MODIFY zfitax_tran FROM wa_final.
818                MODIFY lt_final FROM wa_final INDEX wa_index-index.
819                IF sy-subrc = 0.
820                  COMMIT WORK AND WAIT.
821                  MESSAGE 'Data Saved Successfully' TYPE 'S'.
822                  CLEAR: wa_final, wa_index.
823                ENDIF.
824              ENDIF.
825            ENDLOOP.
826            CALL METHOD l_alv_grid->refresh_table_display
827              EXCEPTIONS
828                finished = 1                " Display was Ended (by Export)
829                OTHERS   = 2.
830          ELSE.
831            MESSAGE 'Please select all the records and then click the Save button' TYPE 'E' DISPLAY LIKE'I'.
832          ENDIF.
833        ENDIF.
834      ENDIF.
835    ENDFORM.
836
837
838    FORM process_print.
839
840      IMPORT original revised chng disp crea app FROM MEMORY ID 'ZFI_DATA'.
841
842      IF original = 'X'.
843        wa_fcat-fieldname = 'SL_NO'.
844        wa_fcat-coltext   = 'SL No'.
845    *  wa_fcat-edit      = 'X'.
846        wa_fcat-ref_table = 'ZFITAX_TRAN'.
847        wa_fcat-ref_field = 'SL_NO'.
848        APPEND wa_fcat TO it_fcat.
849        CLEAR  wa_fcat.
850
851
852        wa_fcat-fieldname = 'PARITICULARS'.
853        wa_fcat-coltext   = 'Pariticulars'.
854    *  wa_fcat-edit      = 'X'.
855        wa_fcat-ref_table = 'ZFITAX_TRAN'.
856        wa_fcat-ref_field = 'PARITICULARS'.
857        wa_fcat-outputlen = 80.
858        APPEND wa_fcat TO it_fcat.
859        CLEAR  wa_fcat.
860
861        wa_fcat-fieldname = 'AMOUNT_INR'.
862        wa_fcat-coltext   = 'Amount(in Rs)'.
863    *  wa_fcat-edit      = 'X'.
864        wa_fcat-ref_table = 'ZFITAX_TRAN'.
865        wa_fcat-ref_field = 'AMOUNT_INR'.
866        APPEND wa_fcat TO it_fcat.
867        CLEAR  wa_fcat.
868
869        wa_fcat-fieldname = 'ADJ_AMOUNT'.
870        wa_fcat-coltext   = 'Adj.Amount(in Rs)'.
871        IF disp NE 'X' AND app NE 'X'.
872          wa_fcat-edit      = 'X'.
873        ENDIF.
874        wa_fcat-ref_table = 'ZFITAX_TRAN'.
875        wa_fcat-ref_field = 'ADJ_AMOUNT'.
876        APPEND wa_fcat TO it_fcat.
877        CLEAR  wa_fcat.
878
879        wa_fcat-fieldname = 'FINAL_AMOUNT'.
880        wa_fcat-coltext   = 'Final.Amount(in Rs)'.
881    *  wa_fcat-edit      = 'X'.
882        wa_fcat-ref_table = 'ZFITAX_TRAN'.
883        wa_fcat-ref_field = 'FINAL_AMOUNT'.
884        APPEND wa_fcat TO it_fcat.
885        CLEAR  wa_fcat.
886
887
888
889    **    wa_fcat-fieldname = 'ADJ_REMARK'.
890    **    wa_fcat-coltext   = 'Adj.Remark'.
891    **    IF disp NE 'X' AND app NE 'X'.
892    **      wa_fcat-edit      = 'X'.
893    **    ENDIF.
894    **
895    **    wa_fcat-ref_table = 'ZFITAX_TRAN'.
896    **    wa_fcat-ref_field = 'ADJ_REMARK'.
897    **    wa_fcat-outputlen  = 120.
898    **    wa_fcat-col_opt = abap_false.
899    **    APPEND wa_fcat TO it_fcat.
900    **    CLEAR  wa_fcat.
901
902        wa_fcat-fieldname = 'ADJ_REMARK'.
903        wa_fcat-coltext   = 'Adj.Remark'.
904        wa_fcat-outputlen = 60.
905        IF disp NE 'X' AND app NE 'X'.
906          wa_fcat-edit      = 'X'.
907        ENDIF.
908
909    *    wa_fcat-ref_table = 'ZFITAX_TRAN'.
910    *    wa_fcat-ref_field = 'ADJ_REMARK'.
911    *    wa_fcat-outputlen  = 120.
912        wa_fcat-col_opt = abap_false.
913        APPEND wa_fcat TO it_fcat.
914        CLEAR  wa_fcat.
915
916
917
918
919      ENDIF.
920
921
922
923      IF revised = 'X'.
924        wa_fcat-fieldname = 'SL_NO'.
925        wa_fcat-coltext   = 'SL No'.
926    *  wa_fcat-edit      = 'X'.
927        wa_fcat-ref_table = 'ZFITAX_TRAN'.
928        wa_fcat-ref_field = 'SL_NO'.
929        APPEND wa_fcat TO it_fcat.
930        CLEAR  wa_fcat.
931
932
933        wa_fcat-fieldname = 'PARITICULARS'.
934        wa_fcat-coltext   = 'Pariticulars'.
935    *  wa_fcat-edit      = 'X'.
936        wa_fcat-ref_table = 'ZFITAX_TRAN'.
937        wa_fcat-ref_field = 'PARITICULARS'.
938        wa_fcat-outputlen = 40.
939        APPEND wa_fcat TO it_fcat.
940        CLEAR  wa_fcat.
941
942        wa_fcat-fieldname = 'AMOUNT_INR'.
943        wa_fcat-coltext   = 'Amount(in Rs)'.
944    *  wa_fcat-edit      = 'X'.
945        wa_fcat-ref_table = 'ZFITAX_TRAN'.
946        wa_fcat-ref_field = 'AMOUNT_INR'.
947        APPEND wa_fcat TO it_fcat.
948        CLEAR  wa_fcat.
949
950        wa_fcat-fieldname = 'ADJ_AMOUNT'.
951        wa_fcat-coltext   = 'Adj.Amount(in Rs)'.
952    *    IF disp NE 'X' AND app NE 'X'.
953    *      wa_fcat-edit      = 'X'.
954    *    ENDIF.
955        wa_fcat-ref_table = 'ZFITAX_TRAN'.
956        wa_fcat-ref_field = 'ADJ_AMOUNT'.
957        APPEND wa_fcat TO it_fcat.
958        CLEAR  wa_fcat.
959
960        wa_fcat-fieldname = 'FINAL_AMOUNT'.
961        wa_fcat-coltext   = 'Final.Amount(in Rs)'.
962    *  wa_fcat-edit      = 'X'.
963        wa_fcat-ref_table = 'ZFITAX_TRAN'.
964        wa_fcat-ref_field = 'FINAL_AMOUNT'.
965        APPEND wa_fcat TO it_fcat.
966        CLEAR  wa_fcat.
967
968
969
970        wa_fcat-fieldname = 'ADJ_REMARK'.
971        wa_fcat-coltext   = 'Adj.Remark'.
972    *    IF disp NE 'X' AND app NE 'X'.
973    *      wa_fcat-edit      = 'X'.
974    *   ENDIF.
975        wa_fcat-ref_table = 'ZFITAX_TRAN'.
976        wa_fcat-outputlen = 60.
977        wa_fcat-ref_field = 'ADJ_REMARK'.
978        APPEND wa_fcat TO it_fcat.
979        CLEAR  wa_fcat.
980
981
982
983        wa_fcat-fieldname = 'REVIS_AMT'.
984        wa_fcat-coltext   = 'Revision Amount'.
985        IF disp NE 'X' AND app NE 'X'.
986          wa_fcat-edit      = 'X'.
987        ENDIF.
988        wa_fcat-ref_table = 'ZFITAX_TRAN'.
989        wa_fcat-ref_field = 'REVIS_AMT'.
990        APPEND wa_fcat TO it_fcat.
991        CLEAR  wa_fcat.
992
993
994        wa_fcat-fieldname = 'REVIS_REMARK'.
995        wa_fcat-coltext   = 'Revision Remark'.
996        IF disp NE 'X' AND app NE 'X'.
997          wa_fcat-edit      = 'X'.
998        ENDIF.
999        wa_fcat-ref_table = 'ZFITAX_TRAN'.
1000       wa_fcat-ref_field = 'REVIS_REMARK'.
1001       APPEND wa_fcat TO it_fcat.
1002       CLEAR  wa_fcat.
1003
1004     ENDIF.
1005
1006     DATA :lv_date TYPE char10.
1007     lv_date = sy-datum.
1008     lv_date = |{ lv_date+6(2) }.{ lv_date+4(2) }.{ lv_date(4) }|.
1009
1010   *  wa_lay-grid_title = |Fiscal Year: { year }   Period: { period-low } to { period-high }   System Date: { lv_date } |.
1011     wa_lay-grid_title = |Company Code: { c_code }  Fiscal Year: { year }   Period: { period-low } to { period-high }  |.
1012
1013
1014
1015     IF lt_data IS NOT INITIAL.
1016       TRY.
1017           l_alv_grid = NEW cl_gui_alv_grid( i_parent = cl_gui_container=>default_screen  ).
1018           l_alv_grid->set_table_for_first_display(
1019                   EXPORTING
1020                     is_variant                    = wa_variant                 " Layout
1021                     i_save                        = l_alv_save_a               " Save Layout
1022                     i_default                     = 'X'                        " Default Display Variant
1023                     is_layout                     = wa_lay                     " Layout
1024                   CHANGING
1025                     it_outtab                     = lt_final                  " Output Table
1026                     it_fieldcatalog               = it_fcat                    " Field Catalog
1027                   EXCEPTIONS
1028                     invalid_parameter_combination = 1                           " Wrong Parameter
1029                     program_error                 = 2                           " Program Errors
1030                     too_many_lines                = 3                           " Too many Rows in Ready for Input Grid
1031                     OTHERS                        = 4
1032                 ).
1033
1034
1035   *        DATA(lo_event) = NEW lcl_event_handler( ).
1036   *        SET HANDLER lo_event->handle_data_changed FOR l_alv_grid.
1037
1038
1039           DATA(lo_event) = NEW lcl_event_handler( ).
1040           SET HANDLER lo_event->handle_data_changed FOR l_alv_grid.
1041
1042           l_alv_grid->register_edit_event(
1043             i_event_id = cl_gui_alv_grid=>mc_evt_enter
1044           ).
1045   *        "******************************************************
1046
1047           CALL SCREEN 100.
1048
1049
1050         CATCH cx_root.
1051           MESSAGE 'Error In Alv Creation' TYPE 'E'.
1052       ENDTRY.
1053
1054     ELSE.
1055
1056       MESSAGE 'Data not found ' TYPE 'E'.
1057
1058     ENDIF.
1059
1060
1061
1062   ENDFORM.
1063
1064   INCLUDE zfi_tax_credit_report_statuo01.
*--- End of ZFI_TAX_CREDIT_REPORT - 1064 lines ---

----------------------------------------------------------------------------------------------------
Include          ZFI_CR_TOP                                Level 1    Page 2
Object           ZFI_TAX_CREDIT_REPORT                     Lines 101
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:35
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&  Include           ZFI_CR_TOP
3      *&---------------------------------------------------------------------*
4
5
6      TABLES:ztax_cr_sheet , vbrk .
7
8      SELECTION-SCREEN BEGIN OF BLOCK b WITH FRAME TITLE text-001.
9      PARAMETERS: c_code TYPE bukrs,
10                 year   TYPE gjahr.
11     SELECT-OPTIONS:    period FOR vbrk-poper.
12     SELECTION-SCREEN END   OF BLOCK  b.
13
14
15     DATA : lt_data      TYPE TABLE OF ztax_cr_sheet,
16            it_fcat      TYPE lvc_t_fcat,
17            wa_fcat      LIKE LINE OF it_fcat,
18            wa_lay       TYPE lvc_s_layo,
19            wa_variant   TYPE disvariant,
20            l_alv_save_a TYPE char01 VALUE 'A',
21            l_alv_grid   TYPE REF TO cl_gui_alv_grid,
22            it_index     TYPE lvc_t_row,
23            it_row       TYPE lvc_t_roid.
24
25     DATA a TYPE c VALUE 'X'.
26     DATA : ls_final TYPE zfitax_tran.
27     DATA : lt_final TYPE STANDARD TABLE OF  zfitax_tran.
28     DATA : lt_final1 TYPE STANDARD TABLE OF  zfi_gl_pbt.
29     *DATA ls_new TYPE LINE OF  LT_FINAL.
30     DATA: original TYPE c,
31           revised  TYPE c.
32
33     DATA: chng TYPE c,
34           disp TYPE c,
35           app  TYPE c,
36           crea TYPE c.
37
38
39     TYPES: BEGIN OF ty_fl,
40              ryear    TYPE gjahr,      " fiscal year
41              racct    TYPE racct,      " GL account
42              rbukrs   TYPE bukrs,      " company code
43              hsl01    TYPE hslxx12,
44              hsl02    TYPE hslxx12,
45              hsl03    TYPE hslxx12,
46              hsl04    TYPE hslxx12,
47              hsl05    TYPE hslxx12,
48              hsl06    TYPE hslxx12,
49              hsl07    TYPE hslxx12,
50              hsl08    TYPE hslxx12,
51              hsl09    TYPE hslxx12,
52              hsl10    TYPE hslxx12,
53              hsl11    TYPE hslxx12,
54              hsl12    TYPE hslxx12,
55              hsl13    TYPE hslxx12,
56              hsl14    TYPE hslxx12,
57              hsl15    TYPE hslxx12,
58              hsl16    TYPE hslxx12,
59              ksl01    TYPE kslxx12,
60              ksl02    TYPE kslxx12,
61              ksl03    TYPE kslxx12,
62              ksl04    TYPE kslxx12,
63              ksl05    TYPE kslxx12,
64              ksl06    TYPE kslxx12,
65              ksl07    TYPE kslxx12,
66              ksl08    TYPE kslxx12,
67              ksl09    TYPE kslxx12,
68              ksl10    TYPE kslxx12,
69              ksl11    TYPE kslxx12,
70              ksl12    TYPE kslxx12,
71              ksl13    TYPE kslxx12,
72              ksl14    TYPE kslxx12,
73              ksl15    TYPE kslxx12,
74              ksl16    TYPE kslxx12,
75              acct_grp TYPE setname,
76            END OF ty_fl.
77
78
79     " Global total variable (sum of REVISED column)
80     DATA: gv_revised_total TYPE p DECIMALS 2.
81
82     DATA: lt_data1 TYPE TABLE OF zfitax_tran.
83
84
85     TYPES : BEGIN OF st_temp,
86
87               company_code TYPE	bukrs,
88               description  TYPE  zdes,
89               acct_grp     TYPE   zact_grp,
90               rate         TYPE zrate_des,
91               ecc_usd      TYPE  hslxx12,
92               ecc_inr      TYPE  hslxx12,
93               final_inr    TYPE  hslxx12,
94
95
96
97             END OF st_temp.
98
99
100    DATA: lt_total TYPE TABLE OF st_temp,
101          ls_total TYPE st_temp.
*--- End of ZFI_CR_TOP - 101 lines ---

----------------------------------------------------------------------------------------------------
Include          ZFI_TAX_CREDIT_REPORT_STATUO01            Level 1    Page 3
Object           ZFI_TAX_CREDIT_REPORT                     Lines 32
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:35
----------------------------------------------------------------------------------------------------
1      *----------------------------------------------------------------------*
2      ***INCLUDE ZFI_TAX_CREDIT_REPORT_STATUO01.
3      *----------------------------------------------------------------------*
4      *&---------------------------------------------------------------------*
5      *&      Module  STATUS_0100  OUTPUT
6      *&---------------------------------------------------------------------*
7      *       text
8      *----------------------------------------------------------------------*
9      MODULE status_0100 OUTPUT.
10       SET PF-STATUS 'ZASSET'.
11       SET TITLEBAR 'ZASSETT2'.
12     ENDMODULE.
13     *&---------------------------------------------------------------------*
14     *&      Module  USER_COMMAND_0100  INPUT
15     *&---------------------------------------------------------------------*
16     *       text
17     *----------------------------------------------------------------------*
18     MODULE user_command_0100 INPUT.
19
20       CASE sy-ucomm.
21         WHEN 'BACK'.
22           LEAVE to SCREEN 0.
23         WHEN 'CANCEL'.
24           LEAVE PROGRAM.
25         WHEN 'EXIT'.
26           LEAVE PROGRAM.
27         WHEN 'SAVE'.
28           PERFORM save_data.
29
30         WHEN 'EXECUTE'.
31       ENDCASE.
32     ENDMODULE.
*--- End of ZFI_TAX_CREDIT_REPORT_STATUO01 - 32 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CABAP                                   Level 1    Page 4
Object           ZFI_TAX_CREDIT_REPORT                     Lines 360
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:35
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
Generated incl.  %_CCNDD                                   Level 1    Page 5
Object           ZFI_TAX_CREDIT_REPORT                     Lines 31
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:35
----------------------------------------------------------------------------------------------------
1      TYPE-POOL CNDD .
2      * Flavor is just a string. It could be any string that identifies
3      * a data object type. The flvor may be seen as something similar
4      * to a class name resp. mime type
5
6      TYPES :  CNDD_FLAVOR(40) TYPE C.
7      TYPES :  CNDD_FLAVORS TYPE CNDD_FLAVOR OCCURS 0.
8
9      * simple Propertybag type. A propertybag consist of a table that
10     * associates name to values.
11
12     TYPES :  CNDD_PROPNAME(40) TYPE C.        " Name of Property
13     TYPES :  CNDD_PROPREMOTEVALUE TYPE SWC_VALUE.  " Value of Remote
14                                                     " Automation PROPERTY
15     TYPES :  CNDD_PROPVALUE TYPE STRING.      " Value of property
16     TYPES :  BEGIN OF CNDD_PROP,
17                 PROPNAME  TYPE CNDD_PROPNAME,    " Property Name
18                 PROPVALUE TYPE CNDD_PROPVALUE,  " Property Value
19              END OF CNDD_PROP.
20     * This structure is for transferring property bag through automation
21     * be carefull, the value is only 80 chars !
22     TYPES :  BEGIN OF CNDD_REMOTEPROP,
23                 PROPNAME  TYPE CNDD_PROPNAME,    " Property Name
24                 PROPVALUE TYPE CNDD_PROPREMOTEVALUE,  " Property Value
25              END OF CNDD_REMOTEPROP.
26
27     TYPES : CNDD_REMOTEPROPS TYPE CNDD_REMOTEPROP OCCURS 0.
28                                                     " Table of Properties
29     TYPES : CNDD_HASHEDPROPS TYPE HASHED TABLE OF CNDD_PROP
30                                      WITH UNIQUE KEY PROPNAME.
31     TYPES : CNDD_PROPS TYPE CNDD_HASHEDPROPS.
*--- End of %_CCNDD - 31 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CCNTL                                   Level 1    Page 6
Object           ZFI_TAX_CREDIT_REPORT                     Lines 138
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:35
----------------------------------------------------------------------------------------------------
1      TYPE-POOL CNTL .
2
3      * WARNING: Never(!) include references to Control framework here,
4      * i.e. CL_GUI_CFW, CL_GUI_OBJECT or classes using one of these
5
6      TYPES CNTL_TYPE(4).
7      *ypes cntl_clsid(30).                  "// see TOLE-APP ??  GL 3.8.97
8      TYPES CNTL_CLSID LIKE CNTLSTRLIS-NAME. "// 70 (see editor-line)
9      TYPES CNTL_METRIC(4).
10     TYPES CNTL_OBJ_TYPE(10).
11     TYPES: BEGIN OF CNTL_EVENT,
12              EVENTID TYPE I,
13              IS_SHELLEVENT TYPE C,
14              IS_SYSTEMEVENT TYPE C,
15              SHELLID        TYPE I,
16            END OF CNTL_EVENT.
17
18     TYPES CNTL_EVENTS TYPE TABLE OF CNTL_EVENT.
19
20     TYPES: BEGIN OF CNTL_SIMPLE_EVENT,
21              EVENTID TYPE I,
22              APPL_EVENT TYPE C,
23            END OF CNTL_SIMPLE_EVENT.
24
25     TYPES: CNTL_SIMPLE_EVENTS TYPE TABLE OF CNTL_SIMPLE_EVENT.
26
27     * Control-Types
28     CONSTANTS: CNTL_TYPE_TABCONTROL   TYPE CNTL_TYPE VALUE 'TABC'.
29     CONSTANTS: CNTL_TYPE_INTERACT     TYPE CNTL_TYPE VALUE 'IACT'.
30     CONSTANTS: CNTL_TYPE_TREE         TYPE CNTL_TYPE VALUE 'TREE'.
31     CONSTANTS: CNTL_TYPE_COMBOBOX     TYPE CNTL_TYPE VALUE 'COBX'.
32     CONSTANTS: CNTL_TYPE_RTF_EDIT     TYPE CNTL_TYPE VALUE 'RTFE'.
33     CONSTANTS: CNTL_TYPE_SOUND        TYPE CNTL_TYPE VALUE 'SOUN'.
34     CONSTANTS: CNTL_TYPE_BUSG         TYPE CNTL_TYPE VALUE 'BUSG'.
35     CONSTANTS: CNTL_TYPE_PORT         TYPE CNTL_TYPE VALUE 'PORT'.
36     CONSTANTS: CNTL_TYPE_OCX          TYPE CNTL_OBJ_TYPE VALUE 'OCX'.
37     CONSTANTS: CNTL_TYPE_NO_OCX       TYPE CNTL_OBJ_TYPE VALUE 'NO_OC'.
38
39     * Lifetime
40     CONSTANTS: CNTL_LIFETIME_DEFAULT     TYPE I VALUE 0.
41     CONSTANTS: CNTL_LIFETIME_DYNPRO      TYPE I VALUE 1.
42     CONSTANTS: CNTL_LIFETIME_IMODE       TYPE I VALUE 2.
43     CONSTANTS: CNTL_LIFETIME_TRANSACTION TYPE I VALUE 3.
44     CONSTANTS: CNTL_LIFETIME_SESSION     TYPE I VALUE 4.
45     * Other Constants
46     CONSTANTS: CNTL_METRIC_DYNPRO TYPE CNTL_METRIC VALUE 'DYNP'.
47
48     * Handle-Definition
49     TYPES: BEGIN OF CNTL_HANDLE,
50              OBJ LIKE OBJ_RECORD,
51              SHELLID TYPE I,
52              PARENTID TYPE I,
53              C_TYPE TYPE CNTL_TYPE,
54              CLSID  TYPE CNTL_CLSID,
55              ORIGIN LIKE SY-REPID,
56              HANDLE_TYPE TYPE CNTL_OBJ_TYPE, "// 'OCX', 'NO_OCX'
57              LIFETIME TYPE I,
58              PROGRAM LIKE SY-REPID,
59              DYNNR LIKE SY-DYNNR,
60              IMODE TYPE I,
61              DYNPRO_POS TYPE I,            " KS: Vorlaeufig
62              GUID TYPE I,
63            END OF CNTL_HANDLE.
64
65     * For interface definitions
66     TYPES: CNTL_HANDLE_TAB TYPE TABLE OF CNTL_HANDLE.
67
68     * constants: handle_type_ocx like cntl_handle-handle_type value 'OCX',
69     *       handle_type_no_ocx like cntl_handle-handle_type value 'NO_OCX'.
70
71     * Font-Properties
72     TYPES: BEGIN OF CNTL_FONT,
73              INIT(1) TYPE C,
74              F_TYPE  TYPE I,
75              BOLD    TYPE I,
76              ITALIC  TYPE I,
77              SIZE    TYPE I,
78            END OF CNTL_FONT.
79
80     * Default Constant for Font-Properties
81     CONSTANTS: BEGIN OF CNTL_FONT_DEFAULTS,
82                  INIT(1) TYPE C VALUE ' ',
83                  F_TYPE  TYPE I VALUE '-1',
84                  BOLD    TYPE I VALUE '-1',
85                  ITALIC  TYPE I VALUE '-1',
86                  SIZE    TYPE I VALUE '-1',
87                END OF CNTL_FONT_DEFAULTS.
88
89
90     * Types and Constants for ComboBox-Control
91     CONSTANTS: CNTL_CB_ITEM_MAX_LENGTH TYPE I VALUE 80.
92
93     TYPES: CNTL_ITEM(CNTL_CB_ITEM_MAX_LENGTH).
94     TYPES: CNTL_ITEM_TAB TYPE CNTL_ITEM OCCURS 0.
95
96     * Types for CL_GUI_RESSOURCES                 (BRP, 2/99)
97     TYPES: BEGIN OF CNTL_COL_VALUE,
98                ID        TYPE I,
99                STATE     TYPE I,
100               VALUE     TYPE I,
101           END OF CNTL_COL_VALUE.
102    TYPES: CNTL_COL_VALUE_TAB TYPE CNTL_COL_VALUE OCCURS 0.
103    * Eventparameter im DIAG r.h 03.05.99
104    TYPES: BEGIN OF CNTL_EVENT_PARAM,
105             PID TYPE I,                   "Index of Event
106             VALUE TYPE STRING,            "Value of Parameter
107           END OF CNTL_EVENT_PARAM.
108    TYPES: CNTL_EVENT_PARAM_TAB TYPE SORTED TABLE OF CNTL_EVENT_PARAM
109                                     WITH UNIQUE KEY PID.
110
111    * Struktur für Metrik-Umrechnungsfaktoren
112    TYPES: begin of cntl_m_factors,
113             x type i,
114             y type i,
115           end   of cntl_m_factors,
116           begin of cntl_metric_factors,
117             version type i,
118             char          type cntl_m_factors,
119             char_complete type cntl_m_factors,
120             dm            type cntl_m_factors,
121             screen        type cntl_m_factors,
122           end   of  cntl_metric_factors.
123    * Typ für Frontend-Farben
124    TYPES: begin of cntl_1_color,
125             index type i,          " redundant
126             rgb   type i,          " the value
127           end   of cntl_1_color,
128           cntl_colors type standard table of cntl_1_color.
129    * Typ für List-Dimension
130    types: begin of cntl_list_dim,
131             x type i,
132             y type i,
133           end   of cntl_list_dim.
134
135    * Structure for CL_GUI_DYNPRO_COMPANION (which is free of framework
136    * references)
137    types: cntl_dynpro_companions
138           type standard table of ref to cl_gui_dynpro_companion.
*--- End of %_CCNTL - 138 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CCNTO                                   Level 1    Page 7
Object           ZFI_TAX_CREDIT_REPORT                     Lines 15
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:35
----------------------------------------------------------------------------------------------------
1      TYPE-POOL CNTO .
2
3      *CLASS CL_GUI_CONTROL DEFINITION DEFERRED PUBLIC.
4      TYPES CNTO_CONTROL_LIST TYPE REF TO CL_GUI_CONTROL OCCURS 0.
5
6      * Type for lifetime description of a control
7      types: begin of cnto_lifetime_info,
8          LIFETIME TYPE I,
9          DYNPRO_PROGRAM TYPE SYREPID,
10         DYNPRO_NR TYPE SYDYNNR,
11         STACKLEVEL TYPE I,
12         IS_CONTAINER,
13         INVISIBLE,
14         TOP_PARENTID TYPE I,
15            end of cnto_lifetime_info.
*--- End of %_CCNTO - 15 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_COLE2                                   Level 1    Page 8
Object           ZFI_TAX_CREDIT_REPORT                     Lines 43
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:35
----------------------------------------------------------------------------------------------------
1      TYPE-POOL OLE2 .
2
3
4      TYPES:
5        OLE2_OBJECT LIKE   OBJ_RECORD.
6      *    Object handle initialization
7      CONSTANTS:
8        OLE2_OBJECT_HEADER TYPE OLE2_OBJECT-HEADER VALUE 'OBJH',
9        OLE2_OBJECT_TYPE   TYPE OLE2_OBJECT-TYPE   VALUE 'OLE2',
10       OLE2_OBJECT_HANDLE TYPE OLE2_OBJECT-HANDLE VALUE -1,
11       BEGIN OF OLE2_OBJECT_INITIAL,
12         HEADER   TYPE OLE2_OBJECT-HEADER    VALUE OLE2_OBJECT_HEADER,
13         TYPE     TYPE OLE2_OBJECT-TYPE      VALUE OLE2_OBJECT_TYPE,
14         HANDLE   TYPE OLE2_OBJECT-HANDLE    VALUE OLE2_OBJECT_HANDLE,
15         CB_INDEX TYPE OLE2_OBJECT-CB_INDEX  VALUE SPACE,
16         CLSID    TYPE OLE2_OBJECT-CLSID     VALUE SPACE,
17       END OF OLE2_OBJECT_INITIAL.
18
19     CONSTANTS: OLE2_%_POINTER POINTER.
20     TYPES: BEGIN OF OLE2_PCB,
21            PCBID TYPE I,
22            DATACB LIKE OLE2_%_POINTER,
23            END OF OLE2_PCB.
24
25     TYPES BEGIN OF OLE2_METH_PARMS.
26       INCLUDE STRUCTURE SWCONT.
27       TYPES POINTER TYPE OLE2_PCB.
28     TYPES END OF   OLE2_METH_PARMS.
29
30     TYPES:
31       OLE2_METH_PARMS_TAB TYPE OLE2_METH_PARMS OCCURS 0,
32     *    Method Parameter Table: contains the methoid parameter
33     *      types and values exporting and importing parameters.
34       OLE2_LCID TYPE I,
35     *    Locale Id: determines the language and other settings
36     *      (like value formats) of the automation server.
37     *      For more information see: Include OLE2LCID
38       OLE2_TYPE TYPE I.
39     *    OLE Variant Type: determines the "variant type" for the
40     *      parameters of Automation Controller requests.
41     *      For more information see: Include OLE2TYPE
42
43     TYPES: OLE2_PARAMETER LIKE SWCBCONT-VALUE.
*--- End of %_COLE2 - 43 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CSBDST                                  Level 1    Page 9
Object           ZFI_TAX_CREDIT_REPORT                     Lines 35
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:35
----------------------------------------------------------------------------------------------------
1      TYPE-POOL sbdst .
2
3      TYPES: sbdst_logical_system LIKE bapibds01-log_system,
4             sbdst_classname LIKE bapibds01-classname,
5             sbdst_classtype LIKE bapibds01-classtype,
6             sbdst_client LIKE bapibds01-client,
7             sbdst_object_key LIKE bapibds01-objkey,
8             sbdst_doc_id LIKE bapibds01-doc_id,
9             sbdst_doc_ver_no LIKE bapibds01-doc_ver_no,
10            sbdst_doc_var_id LIKE bapibds01-doc_var_id,
11            sbdst_doc_var_tg LIKE bapibds01-doc_var_tg,
12            sbdst_new_var_tg LIKE bapibds01-doc_var_tg,
13            sbdst_url LIKE bapibds01-uri,
14            sbdst_url_lifetime LIKE bapibds01-uri_life,
15            sbdst_x LIKE bapibds01-x,
16            sbdst_binary_flag LIKE bapibds01-x,
17            sbdst_mimetype LIKE bapibds01-mimetype.
18
19     TYPES: sbdst_signature LIKE bapisignat OCCURS 1,
20            sbdst_connections LIKE bapiconnec OCCURS 1,
21            sbdst_components LIKE bapicompon OCCURS 1,
22            sbdst_components2 LIKE bapicompo2 OCCURS 1,
23            sbdst_components3 like bapicompo3 occurs 1,
24            sbdst_content LIKE bapiconten OCCURS 1,
25            sbdst_ascii_content LIKE bapiascont OCCURS 1,
26            sbdst_files LIKE bapifiles OCCURS 1,
27            sbdst_uri LIKE bapiuri OCCURS 1,
28            sbdst_properties LIKE bapiproper OCCURS 1,
29            sbdst_dproperties LIKE bapidpropt OCCURS 1,
30            sbdst_lproperties LIKE bapiproptl OCCURS 1,
31            sbdst_relations LIKE bapirelat OCCURS 1,
32            sbdst_srelations LIKE bapisrelat OCCURS 1,
33            sbdst_excluding LIKE bdn_fkt OCCURS 1,
34            sbdst_commfile_entries LIKE bapicomfil OCCURS 1,
35            sbdst_query LIKE bapiquery OCCURS 1.
*--- End of %_CSBDST - 35 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CSLIS                                   Level 1    Page 10
Object           ZFI_TAX_CREDIT_REPORT                     Lines 543
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:35
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
Generated incl.  %_CSOI                                    Level 1    Page 11
Object           ZFI_TAX_CREDIT_REPORT                     Lines 328
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:35
----------------------------------------------------------------------------------------------------
1      TYPE-POOL SOI .
2
3      TYPES: SOI_CONTROL_PARAM_TYPE(256).
4
5      TYPES: SOI_RET_STRING(256) TYPE C, SOI_CUSTOM_PARAM(256) TYPE C.
6      TYPES: SOI_MESSAGE_PARAM(50) TYPE C.
7      TYPES: SOI_PROXY_ERROR_CODE TYPE I.
8      TYPES: SOI_BOOLEAN TYPE C.             " 'X' - TRUE, ' ' - FALSE
9
10     TYPES: SOI_FIELDS_TABLE TYPE STANDARD TABLE OF RFC_FIELDS.
11     TYPES: SOI_PROPERTIES_TABLE TYPE STANDARD TABLE OF DPPROPS.
12
13     TYPES: SOI_LINK_ITEM_NAME(128).
14     TYPES: SOI_STRING(64).
15
16     TYPES: BEGIN OF SOI_LINK_ITEM,
17                 ITEM_NAME         TYPE SOI_LINK_ITEM_NAME,
18                 ITEM_TITLE        TYPE SOI_LINK_ITEM_NAME,
19                 SUBITEMS_ALLOWED  TYPE C,
20                 SUBITEM_NAME      TYPE SOI_LINK_ITEM_NAME,
21            END OF SOI_LINK_ITEM.
22
23     TYPES: SOI_LINK_ITEM_TABLE TYPE TABLE OF SOI_LINK_ITEM.
24
25     TYPES: SOI_FIELD_NAME(256) TYPE C.
26
27     TYPES: BEGIN OF SOI_FIELDS,
28              ITEM_NAME TYPE SOI_FIELD_NAME,
29            END OF SOI_FIELDS.
30
31     TYPES: BEGIN OF SOI_SHEETS,
32              SHEET_NAME TYPE SOI_FIELD_NAME,
33            END OF SOI_SHEETS.
34
35     TYPES: BEGIN OF SOI_COLS,
36                COLINDEX TYPE I,
37            END OF SOI_COLS.
38
39     TYPES: SOI_COLS_TABLE TYPE STANDARD TABLE OF SOI_COLS
40                                  WITH DEFAULT KEY.
41
42     TYPES: BEGIN OF SOI_COL_NAMES,
43                COLNAME(256) TYPE C,
44            END OF SOI_COL_NAMES.
45
46     TYPES: SOI_COLNAMES_TABLE TYPE STANDARD TABLE OF SOI_COL_NAMES
47                                  WITH DEFAULT KEY.
48
49     TYPES: BEGIN OF SOI_TABLEINFO_ITEM,
50               ROWS TYPE I,
51               COLUMNS TYPE I,
52            END OF SOI_TABLEINFO_ITEM.
53
54     TYPES: SOI_TABLEINFO_TABLE TYPE STANDARD TABLE OF SOI_TABLEINFO_ITEM
55                                   WITH DEFAULT KEY.
56
57     TYPES: BEGIN OF SOI_TEMPLATE_INFO_ITEM,
58             NAME(128) TYPE C,
59             PATH(256) TYPE C,
60             FULLNAME(512) TYPE C,
61            END OF SOI_TEMPLATE_INFO_ITEM.
62
63     TYPES: SOI_TEMPLATE_INFO TYPE STANDARD TABLE OF SOI_TEMPLATE_INFO_ITEM
64                                 WITH DEFAULT KEY.
65
66     TYPES: SOI_FIELDS_NAME_TABLE TYPE STANDARD TABLE OF SOI_FIELDS
67                                  WITH DEFAULT KEY.
68
69     TYPES: SOI_SHEETS_TABLE TYPE STANDARD TABLE OF SOI_SHEETS
70                                  WITH DEFAULT KEY.
71
72     TYPES: BEGIN OF SOI_FORM_ITEM,
73              TYPE TYPE C,
74              NAME(128) TYPE C,
75              NUMBER(3) TYPE C,
76              VALUE(256) TYPE C,
77              CODE TYPE C,
78            END OF SOI_FORM_ITEM.
79
80     TYPES: SOI_FORM_LIST TYPE STANDARD TABLE OF SOI_FORM_ITEM
81                         WITH DEFAULT KEY.
82
83     TYPES: BEGIN OF SOI_RANGE_ITEM,
84              NAME(128) TYPE C,
85              ROWS(4) TYPE C,
86              COLUMNS(4) TYPE C,
87              CODE(1) TYPE C,
88            END OF SOI_RANGE_ITEM.
89
90     TYPES: SOI_RANGE_LIST TYPE STANDARD TABLE OF SOI_RANGE_ITEM
91                          WITH DEFAULT KEY.
92
93     TYPES: BEGIN OF SOI_FULL_RANGE_ITEM,
94              NAME(128) TYPE C,
95              TOP TYPE I,
96              LEFT TYPE I,
97              ROWS TYPE I,
98              COLUMNS TYPE I,
99              SHEET(128) TYPE C,
100           END OF SOI_FULL_RANGE_ITEM.
101
102    TYPES: SOI_FULL_RANGE_TABLE TYPE STANDARD TABLE OF SOI_FULL_RANGE_ITEM
103                         WITH DEFAULT KEY.
104
105    TYPES: BEGIN OF SOI_STYLE_ITEM,
106             NAME(128) TYPE C,
107             TOP TYPE I,
108             LEFT TYPE I,
109             ROWS TYPE I,
110             COLUMNS TYPE I,
111             STYLE(128) TYPE C,
112           END OF SOI_STYLE_ITEM.
113
114    TYPES: SOI_STYLE_TABLE TYPE STANDARD TABLE OF SOI_STYLE_ITEM
115                         WITH DEFAULT KEY.
116
117    TYPES: BEGIN OF SOI_GENERIC_ITEM,
118             ROW(4) TYPE C,
119             COLUMN(4) TYPE C,
120             VALUE(256) TYPE C,
121           END OF SOI_GENERIC_ITEM.
122
123    TYPES: SOI_GENERIC_TABLE TYPE STANDARD TABLE OF SOI_GENERIC_ITEM
124                          WITH DEFAULT KEY.
125
126    TYPES: BEGIN OF SOI_NAMECOL_ITEM,
127             NAME(256) TYPE C,
128             COLUMN TYPE I,
129           END OF SOI_NAMECOL_ITEM.
130
131    TYPES: SOI_NAMECOL_TABLE TYPE STANDARD TABLE OF SOI_NAMECOL_ITEM
132                          WITH DEFAULT KEY.
133
134    TYPES: BEGIN OF SOI_NAMETYPE_ITEM,
135             NAME(256) TYPE C,
136             TYPE TYPE I,
137           END OF SOI_NAMETYPE_ITEM.
138
139    TYPES: SOI_NAMETYPE_TABLE TYPE STANDARD TABLE OF SOI_NAMETYPE_ITEM
140                          WITH DEFAULT KEY.
141
142    TYPES: BEGIN OF SOI_COLTYPE_ITEM,
143             COL TYPE I,
144             TYPE TYPE I,
145           END OF SOI_COLTYPE_ITEM.
146
147    TYPES: SOI_COLTYPE_TABLE TYPE STANDARD TABLE OF SOI_COLTYPE_ITEM
148                          WITH DEFAULT KEY.
149
150    TYPES: BEGIN OF SOI_FORMAT_ITEM,
151             NAME(256) TYPE C,
152             FRONT TYPE I,
153             BACK TYPE I,
154             FONT(30) TYPE C,
155             SIZE TYPE I,
156             BOLD TYPE I,
157             ITALIC TYPE I,
158             ALIGN TYPE I,
159             FRAMETYP TYPE I,
160             FRAMECOLOR TYPE I,
161             CURRENCY(3) TYPE C,
162             NUMBER TYPE I,
163             DECIMALS TYPE I,
164           END OF SOI_FORMAT_ITEM.
165
166    TYPES: SOI_FORMAT_TABLE TYPE STANDARD TABLE OF SOI_FORMAT_ITEM
167                         WITH DEFAULT KEY.
168
169    TYPES: BEGIN OF SOI_CELL_ITEM,
170             TOP TYPE I,
171             LEFT TYPE I,
172             ROWS TYPE I,
173             COLUMNS TYPE I,
174             FRONT TYPE I,
175             BACK TYPE I,
176             FONT(30) TYPE C,
177             SIZE TYPE I,
178             BOLD TYPE I,
179             ITALIC TYPE I,
180             ALIGN TYPE I,
181             FRAMETYP TYPE I,
182             FRAMECOLOR TYPE I,
183             CURRENCY(3) TYPE C,
184             NUMBER TYPE I,
185             DECIMALS TYPE I,
186             INPUT TYPE I,
187           END OF SOI_CELL_ITEM.
188
189    TYPES: SOI_CELL_TABLE TYPE STANDARD TABLE OF SOI_CELL_ITEM
190                         WITH DEFAULT KEY.
191
192    TYPES: BEGIN OF SOI_DIMENSION_ITEM,
193             ROW TYPE I,
194             COLUMN TYPE I,
195             ROWS TYPE I,
196             COLUMNS TYPE I,
197           END OF SOI_DIMENSION_ITEM.
198
199    TYPES: SOI_DIMENSION_TABLE TYPE STANDARD TABLE OF SOI_DIMENSION_ITEM
200                            WITH DEFAULT KEY.
201
202    TYPES: SOI_SEMA_TABLE TYPE STANDARD TABLE OF GXXLT_S
203                            WITH DEFAULT KEY.
204
205    TYPES: SOI_HKEY_TABLE TYPE STANDARD TABLE OF GXXLT_H
206                            WITH DEFAULT KEY.
207
208    TYPES: SOI_VKEY_TABLE TYPE STANDARD TABLE OF GXXLT_V
209                            WITH DEFAULT KEY.
210
211    TYPES: SOI_ONLINE_TABLE TYPE STANDARD TABLE OF GXXLT_O
212                            WITH DEFAULT KEY.
213
214    TYPES: SOI_DOCUMENT_TYPE(70) TYPE C.
215
216    TYPES: BEGIN OF SOI_AREA_ITEM,
217             TOP TYPE I,
218             LEFT TYPE I,
219             ROWS TYPE I,
220             COLUMNS TYPE I,
221             INDEX TYPE C,
222           END OF SOI_AREA_ITEM.
223
224    TYPES: SOI_AREA_TABLE TYPE STANDARD TABLE OF SOI_AREA_ITEM
225                            WITH DEFAULT KEY.
226
227    TYPES: BEGIN OF SOI_MAP_ITEM,
228             ID TYPE I,
229             TYPE(128) TYPE C,
230             SUBTYPE(128) TYPE C,
231           END OF SOI_MAP_ITEM.
232
233    TYPES: SOI_MAP_TABLE TYPE STANDARD TABLE OF SOI_MAP_ITEM
234                            WITH DEFAULT KEY.
235
236    TYPES: BEGIN OF SOI_HEAD_ITEM,
237             TYP TYPE C,
238             KEY(20) TYPE C,
239             INFO(60) TYPE C,
240           END OF SOI_HEAD_ITEM.
241
242    TYPES: SOI_HEAD_TABLE TYPE STANDARD TABLE OF SOI_HEAD_ITEM
243                            WITH DEFAULT KEY.
244
245    TYPES: BEGIN OF SOI_HIERARCHY_ITEM,
246             FIRSTLINE TYPE I,
247             LENGTH TYPE I,
248             SHEET(128) TYPE C,
249             MODE TYPE I,
250           END OF SOI_HIERARCHY_ITEM.
251
252    TYPES: SOI_HIERARCHY_TABLE TYPE STANDARD TABLE OF SOI_HIERARCHY_ITEM
253                            WITH DEFAULT KEY.
254
255    TYPES: BEGIN OF SOI_DOCUMENT_TYPE_DESCR,
256              DOCUMENT_TYPE             TYPE SOI_DOCUMENT_TYPE, " prog id
257              TYPE_FULL_NAME(70)        TYPE C, " full name
258              TYPE_SHORT_NAME(20)       TYPE C, " short name
259              APPLICATION_NAME(50)      TYPE C, " application name
260              SUPPORTED_INTERFACES(256) TYPE C, " supported SAP interfaces
261              AVAILABLE(1)              TYPE C, " X on return when available
262           END OF SOI_DOCUMENT_TYPE_DESCR.
263
264    TYPES: SOI_DOCUMENT_TYPE_DESCR_LIST
265                       TYPE STANDARD TABLE OF SOI_DOCUMENT_TYPE_DESCR
266                                                           WITH DEFAULT KEY.
267
268    CONSTANTS:                                                "123456789012
269               SOI_TYPE_APPLICATION(11)  TYPE C VALUE 'application',
270               SOI_TYPE_IMAGE(5)         TYPE C VALUE 'image',
271               SOI_SUBTYPE_OLEOBJECT(11) TYPE C VALUE 'x-oleobject',
272               SOI_SUBTYPE_BITMAP(8)     TYPE C VALUE 'x-ms-bmp',
273               SOI_SUBTYPE_GIF(3)        TYPE C VALUE 'gif',
274               SOI_SUBTYPE_JPEG(4)       TYPE C VALUE 'jpeg',
275               SOI_SUBTYPE_RTF(5)        TYPE C VALUE 'x-rtf'.
276
277    CONSTANTS:
278               SOI_DOCTYPE_WORD_DOCUMENT(13) TYPE C
279                                                  VALUE 'Word.Document',
280               SOI_DOCTYPE_WORD95_DOCUMENT(15) TYPE C
281                                                  VALUE 'Word.Document.6',
282               SOI_DOCTYPE_WORD97_DOCUMENT(15) TYPE C
283                                                  VALUE 'Word.Document.8',
284               SOI_DOCTYPE_EXCEL_SHEET(11) TYPE C VALUE 'Excel.Sheet',
285               SOI_DOCTYPE_EXCEL_CHART(11) TYPE C VALUE 'Excel.Chart',
286               SOI_DOCTYPE_EXCEL95_SHEET(13) TYPE C VALUE 'Excel.Sheet.5',
287               SOI_DOCTYPE_EXCEL95_CHART(13) TYPE C VALUE 'Excel.Chart.5',
288               SOI_DOCTYPE_EXCEL97_SHEET(13) TYPE C VALUE 'Excel.Sheet.8',
289               SOI_DOCTYPE_EXCEL97_CHART(13) TYPE C VALUE 'Excel.Chart.8',
290
291               SOI_DOCTYPE_WORDPRO_DOCUMENT(16) TYPE C
292                                                   VALUE 'WordPro.Document',
293               SOI_DOCTYPE_LOTUS123_WORKBOOK(17) TYPE C
294                                                  VALUE 'Lotus123.Workbook',
295               SOI_DOCTYPE_LOTUS123_WORKBK97(20) TYPE C
296                                             VALUE 'Lotus123.Workbook.97',
297
298               SOI_DOCTYPE_WORDPERF7_DOCUMENT(6) TYPE C VALUE 'WP7Doc',
299               SOI_DOCTYPE_WORDPERF8_DOCUMENT(6) TYPE C VALUE 'WP8Doc',
300
301               SOI_DOCTYPE_SWRITER_DOCUMENT(26) TYPE C
302                                      VALUE 'soffice.StarWriterDocument',
303               SOI_DOCTYPE_SWRITER31_DOCUMENT(29) TYPE C
304                                      VALUE 'swriter3.StarWriterDocument.3',
305               SOI_DOCTYPE_SWRITER40_DOCUMENT(28) TYPE C
306                                      VALUE 'soffice.StarWriterDocument.4',
307
308               SOI_DOCTYPE_VISIO_DOCUMENT(13) TYPE C VALUE 'Visio.Drawing',
309               SOI_DOCTYPE_VISIO4_DOCUMENT(15) TYPE C
310                                                    VALUE 'Visio.Drawing.4'.
311
312    CONSTANTS:
313               SOI_DOCFORMAT_COMPOUND(3) TYPE C VALUE 'OLE',
314               SOI_DOCFORMAT_NATIVE(6)   TYPE C VALUE 'NATIVE',
315               SOI_DOCFORMAT_RTF(3)      TYPE C VALUE 'RTF',
316               SOI_DOCFORMAT_TEXT(4)     TYPE C VALUE 'TEXT'.
317
318    * Constants for I_OI_DOCUMENT_PROXY~GET_APPLICATION_PROPERTY
319    CONSTANTS:                                        "12345678901234567890
320        SOI_PROP_TEMPLATE_PATH(13)       TYPE C VALUE 'TEMPLATE_PATH',
321
322        SOI_PROP_INTERNATIONAL(13)       TYPE C VALUE 'INTERNATIONAL',
323        SOI_SUBP_INTERNAT_DECIMALSEP(17) TYPE C VALUE 'DECIMAL_SEPARATOR',
324        SOI_SUBP_INTERNAT_THOUSANDSSEP(19)
325                                         TYPE C VALUE 'THOUSANDS_SEPARATOR',
326        SOI_SUBP_INTERNAT_LISTSEP(14)    TYPE C VALUE 'LIST_SEPARATOR',
327        SOI_SUBP_INTERNAT_DATESEP(14)    TYPE C VALUE 'DATE_SEPARATOR',
328        SOI_SUBP_INTERNAT_TIMESEP(14)    TYPE C VALUE 'TIME_SEPARATOR'.
*--- End of %_CSOI - 328 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  <REPINI>                                  Level 1    Page 12
Object           ZFI_TAX_CREDIT_REPORT                     Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:35
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
Generated incl.  <SYSINI>                                  Level 1    Page 13
Object           ZFI_TAX_CREDIT_REPORT                     Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:35
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
Generated incl.  <SYSSEL>                                  Level 1    Page 14
Object           ZFI_TAX_CREDIT_REPORT                     Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:35
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
Generated incl.  CL_ALV_GRID_VIEW_FRONTEND_DATACT          Level 1    Page 15
Object           ZFI_TAX_CREDIT_REPORT                     Lines 3
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:35
----------------------------------------------------------------------------------------------------
1      *"* dummy include to reduce generation dependencies between
2      *"* class CL_ALV_GRID_VIEW_FRONTEND_DATA and it's users.
3      *"* touched if any type reference has been changed
*--- End of CL_ALV_GRID_VIEW_FRONTEND_DATACT - 3 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  CX_SALV_API_CONTRACT_VIOLATIONCT          Level 1    Page 16
Object           ZFI_TAX_CREDIT_REPORT                     Lines 3
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:35
----------------------------------------------------------------------------------------------------
1      *"* dummy include to reduce generation dependencies between
2      *"* class CX_SALV_API_CONTRACT_VIOLATION and it's users.
3      *"* touched if any type reference has been changed
*--- End of CX_SALV_API_CONTRACT_VIOLATIONCT - 3 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  CX_SALV_INDEX_TABLE_NOT_SORTEDCT          Level 1    Page 17
Object           ZFI_TAX_CREDIT_REPORT                     Lines 3
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:35
----------------------------------------------------------------------------------------------------
1      *"* dummy include to reduce generation dependencies between
2      *"* class CX_SALV_INDEX_TABLE_NOT_SORTED and it's users.
3      *"* touched if any type reference has been changed
*--- End of CX_SALV_INDEX_TABLE_NOT_SORTEDCT - 3 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  DB__SSEL                                  Level 1    Page 18
Object           ZFI_TAX_CREDIT_REPORT                     Lines 1
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:35
----------------------------------------------------------------------------------------------------
1      * INCLUDE DB__SSEL
*--- End of DB__SSEL - 1 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  IF_SALV_GRID_FRONTEND_ANALYSERIT          Level 1    Page 19
Object           ZFI_TAX_CREDIT_REPORT                     Lines 3
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:35
----------------------------------------------------------------------------------------------------
1      *"* dummy include to reduce generation dependencies between
2      *"* class IF_SALV_GRID_FRONTEND_ANALYSER and it's users.
3      *"* touched if any type reference has been changed
*--- End of IF_SALV_GRID_FRONTEND_ANALYSERIT - 3 lines ---
