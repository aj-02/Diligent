----------------------------------------------------------------------------------------------------
Main program     ZFI_JV_TB                                 Level 0    Page 1
Object           ZFI_JV_TB                                 Lines 2059
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:18
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      * Program    : ZFI_JV_TB                                              *
3      * Title      : Trail balance joint venture wise                       *
4      * FS No.     :                                                        *
5      * Author     : Hrishikesh Nikam                                       *
6      * Date       : 22-03-22                                               *
7      * Login Id   : ABAPUSER01                                             *
8      * Description: Report for Trail balance joint venture wise            *
9      * Tran. Code : ZJVTB                                                  *
10     *                                                                     *
11     ***********************************************************************
12     * Change History:-                                                    *
13     *                                                                     *
14     * Changed on  Changed by        TR No.     Description                *
15     * 01-11-2022  Hrishikesh Nikam  OCDK906236 ZJVTB Layout change        *
16     *                                                                     *
17     * 15-02-2023 Hrishikesh Nikam   OCDK906479 Rec indi & report of GT 10 JVs *                                                                   *
18     *                                                                     *
19     * 13-03-2023 Hrishikesh Nikam      Display closing balance of all JVs *
20
21     * 19-02-2023 Aparna Anand        USD AND INR BOTH ADDITION                                                                  *
22     *                                                                     *
23     * ADD HERE IF ANY CHANGE DONE IN THE PROGRAM                          *
24     *                                                                     *
25     *&---------------------------------------------------------------------*
26     REPORT zzjvtb_test.
27
28     TYPE-POOLS: vrm.
29
30     TABLES : jvto1,
31              sscrfields,
32              smp_dyntxt.
33
34     TYPES : BEGIN OF ty_jvto13,
35               ryear  TYPE  jvto1-ryear,
36               rtcur  TYPE  jvto1-rtcur,
37               drcrk  TYPE  jvto1-drcrk,
38               rbukrs TYPE jvto1-rbukrs,
39               rjvnam TYPE jvto1-rjvnam,
40               racct  TYPE jvto1-racct,
41               hslvt  TYPE jvto1-hslvt,
42               kslvt  TYPE jvto1-kslvt,
43             END OF ty_jvto13.
44
45     TYPES : BEGIN OF ty_jvto1,
46               ryear  TYPE  jvto1-ryear,
47               rtcur  TYPE  jvto1-rtcur,
48               drcrk  TYPE  jvto1-drcrk,
49               rbukrs TYPE jvto1-rbukrs,
50               rjvnam TYPE jvto1-rjvnam,
51               racct  TYPE jvto1-racct,
52               hslvt  TYPE jvto1-hslvt,
53               kslvt  TYPE jvto1-kslvt,
54             END OF ty_jvto1.
55
56     TYPES : BEGIN OF ty_jvto2,
57               ryear  TYPE  jvto1-ryear,
58               rtcur  TYPE  jvto1-rtcur,
59               drcrk  TYPE  jvto1-drcrk,
60               rbukrs TYPE jvto1-rbukrs,
61               rjvnam TYPE jvto1-rjvnam,
62               racct  TYPE jvto1-racct,
63               kslvt  TYPE  jvto1-kslvt,
64             END OF ty_jvto2.
65
66     TYPES : BEGIN OF ty_jvt,
67               racct  TYPE jvto1-racct,
68               ryear  TYPE  jvto1-ryear,
69               rbukrs TYPE jvto1-rbukrs,
70               rjvnam TYPE jvto1-rjvnam,
71             END OF ty_jvt.
72
73     TYPES : BEGIN OF ty_jvso1,
74               ryear  TYPE jvso1-ryear,
75               rtcur  TYPE jvso1-rtcur,
76               drcrk  TYPE jvso1-drcrk,
77               poper  TYPE jvso1-poper,
78               rbukrs TYPE jvso1-rbukrs,
79               rjvnam TYPE jvso1-rjvnam,
80               racct  TYPE jvso1-racct,
81               hsl    TYPE jvso1-hsl,
82               ksl    TYPE jvso1-ksl,
83             END OF ty_jvso1.
84
85     TYPES : BEGIN OF ty_ska1,
86               ktopl TYPE ska1-ktopl,
87               saknr TYPE ska1-saknr,
88               xbilk TYPE ska1-xbilk,
89               sakan TYPE ska1-sakan,
90               txt20 TYPE skat-txt20,
91               txt50 TYPE skat-txt50,
92             END OF ty_ska1.
93
94     TYPES : BEGIN OF ty_skat,
95               saknr TYPE ska1-saknr,
96               txt50 TYPE skat-txt50,
97             END OF ty_skat.
98
99     TYPES : BEGIN OF ty_final,
100              rjvnam    TYPE jvto1-rjvnam,
101              racct     TYPE jvto1-racct,
102              txt50     TYPE skat-txt50,
103              bal_opn   TYPE decfloat34,
104              bal_opn_i TYPE decfloat34,
105              bal_opn_u TYPE decfloat34,
106              bal_cre   TYPE decfloat34,
107              bal_cre_i TYPE decfloat34,
108              bal_cre_u TYPE decfloat34,
109              bal_deb   TYPE decfloat34,
110              bal_deb_i TYPE decfloat34,
111              bal_deb_u TYPE decfloat34,
112              bal_clo   TYPE decfloat34,
113              bal_clo_i TYPE decfloat34,
114              bal_clo_u TYPE decfloat34,
115            END OF ty_final.
116
117    TYPES : BEGIN OF ty_final2,
118              rjvnam        TYPE jvto1-rjvnam,
119              racct         TYPE jvto1-racct,
120              txt50         TYPE skat-txt50,
121              bal_opn(20)   TYPE c,
122              bal_opn_i(20) TYPE c,
123              bal_opn_u(20) TYPE c,
124              bal_cre(20)   TYPE c,
125              bal_cre_i(20) TYPE c,
126              bal_cre_u(20) TYPE c,
127              bal_deb(20)   TYPE c,
128              bal_deb_i(20) TYPE c,
129              bal_deb_u(20) TYPE c,
130              bal_clo(20)   TYPE c,
131              bal_clo_i(20) TYPE c,
132              bal_clo_u(20) TYPE c,
133            END OF ty_final2.
134
135    TYPES : BEGIN OF ty_final3,
136              racct TYPE jvto1-racct,
137              txt50 TYPE skat-txt50,
138            END OF ty_final3.
139
140    TYPES : BEGIN OF ty_final4,
141              racct     TYPE jvto1-racct,
142              txt50     TYPE skat-txt50,
143              bal_opn1  TYPE jvto1-hslvt,
144              bal_cre1  TYPE jvto1-hslvt,
145              bal_deb1  TYPE jvto1-hslvt,
146              bal_clo1  TYPE jvto1-hslvt,
147
148              bal_opn2  TYPE jvto1-hslvt,
149              bal_cre2  TYPE jvto1-hslvt,
150              bal_deb2  TYPE jvto1-hslvt,
151              bal_clo2  TYPE jvto1-hslvt,
152
153              bal_opn3  TYPE jvto1-hslvt,
154              bal_cre3  TYPE jvto1-hslvt,
155              bal_deb3  TYPE jvto1-hslvt,
156              bal_clo3  TYPE jvto1-hslvt,
157
158              bal_opn4  TYPE jvto1-hslvt,
159              bal_cre4  TYPE jvto1-hslvt,
160              bal_deb4  TYPE jvto1-hslvt,
161              bal_clo4  TYPE jvto1-hslvt,
162
163              bal_opn5  TYPE jvto1-hslvt,
164              bal_cre5  TYPE jvto1-hslvt,
165              bal_deb5  TYPE jvto1-hslvt,
166              bal_clo5  TYPE jvto1-hslvt,
167
168              bal_opn6  TYPE jvto1-hslvt,
169              bal_cre6  TYPE jvto1-hslvt,
170              bal_deb6  TYPE jvto1-hslvt,
171              bal_clo6  TYPE jvto1-hslvt,
172
173              bal_opn7  TYPE jvto1-hslvt,
174              bal_cre7  TYPE jvto1-hslvt,
175              bal_deb7  TYPE jvto1-hslvt,
176              bal_clo7  TYPE jvto1-hslvt,
177
178              bal_opn8  TYPE jvto1-hslvt,
179              bal_cre8  TYPE jvto1-hslvt,
180              bal_deb8  TYPE jvto1-hslvt,
181              bal_clo8  TYPE jvto1-hslvt,
182
183              bal_opn9  TYPE jvto1-hslvt,
184              bal_cre9  TYPE jvto1-hslvt,
185              bal_deb9  TYPE jvto1-hslvt,
186              bal_clo9  TYPE jvto1-hslvt,
187
188              bal_opn10 TYPE jvto1-hslvt,
189              bal_cre10 TYPE jvto1-hslvt,
190              bal_deb10 TYPE jvto1-hslvt,
191              bal_clo10 TYPE jvto1-hslvt,
192
193            END OF ty_final4.
194
195    TYPES : BEGIN OF ty_alljv,
196              rjvnam TYPE jvto1-racct,
197            END OF ty_alljv.
198
199    DATA : lt_jvto1_ad  TYPE STANDARD TABLE OF ty_jvto13.
200
201    DATA : lt_jvto1    TYPE STANDARD TABLE OF ty_jvto1,
202           lt_jvto2    TYPE STANDARD TABLE OF ty_jvto2,
203           lt_jvt      TYPE STANDARD TABLE OF ty_jvt,
204           lt_jvso1_1  TYPE STANDARD TABLE OF ty_jvso1,
205           lt_jvso1_2  TYPE STANDARD TABLE OF ty_jvso1,
206           lt_ska1     TYPE STANDARD TABLE OF ty_ska1,
207           lt_skat     TYPE STANDARD TABLE OF ty_skat,
208           lt_final    TYPE STANDARD TABLE OF ty_final,
209           lt_bfinal   TYPE STANDARD TABLE OF ty_final,
210           lt_alljv    TYPE STANDARD TABLE OF ty_alljv,
211           lt_final2   TYPE STANDARD TABLE OF ty_final2,
212           lt_final3   TYPE STANDARD TABLE OF ty_final3,
213           lt_final4   TYPE STANDARD TABLE OF ty_final4,
214
215           ls_jvto1    TYPE ty_jvto1,
216           ls_jvto1_1  TYPE ty_jvto1,
217           ls_jvto1_2  TYPE ty_jvto1,
218           ls_jvto2    TYPE ty_jvto2,
219           ls_jvt      TYPE ty_jvt,
220           ls_jvt_1    TYPE ty_jvt,
221           ls_jvso1_1  TYPE ty_jvso1,
222           ls_jvso1_11 TYPE ty_jvso1,
223           ls_jvso1_2  TYPE ty_jvso1,
224           ls_jvso1_22 TYPE ty_jvso1,
225           ls_ska1     TYPE ty_ska1,
226           ls_skat     TYPE ty_skat,
227           ls_final    TYPE ty_final,
228           ls_final_1  TYPE ty_final,
229           ls_final_2  TYPE ty_final,
230           ls_bfinal   TYPE ty_final,
231           ls_alljv    TYPE ty_alljv,
232           ls_final2   TYPE ty_final2,
233           ls_final3   TYPE ty_final3,
234           ls_final4   TYPE ty_final4.
235
236    DATA : lt_fcat   TYPE slis_t_fieldcat_alv,
237           wa_fcat   TYPE slis_fieldcat_alv,
238           it_header TYPE slis_t_listheader,
239           wa_header TYPE slis_listheader,
240           wa_layout TYPE slis_layout_alv.
241
242    TYPES : BEGIN OF ty_final5,
243              racct       TYPE jvto1-racct,
244              txt50       TYPE skat-txt50,
245              bal_clo(20) TYPE c,
246            END OF ty_final5.
247
248    TYPES : BEGIN OF ty_tcurr,
249              kurst TYPE tcurr-kurst,
250              fcurr TYPE tcurr-fcurr,
251              tcurr TYPE tcurr-tcurr,
252              gdatu TYPE tcurr-gdatu,
253              ukurs TYPE tcurr-ukurs,
254            END OF ty_tcurr.
255
256    DATA : it_curr TYPE STANDARD TABLE OF ty_tcurr.
257
258    DATA lt_fieldcat TYPE lvc_t_fcat.
259    DATA ls_lay      TYPE lvc_s_layo.
260    DATA ls_fieldcat LIKE LINE OF lt_fieldcat.
261    DATA lr_itab     TYPE REF TO data.
262    DATA lv_string   TYPE string.
263
264    FIELD-SYMBOLS <fs_itab> TYPE STANDARD TABLE .
265
266    DATA: gt_list    TYPE vrm_values.
267    DATA: gwa_list   TYPE vrm_value.
268    DATA: gt_values  TYPE TABLE OF dynpread,
269          gwa_values TYPE dynpread.
270
271    DATA: gv_selected_value(20) TYPE c.
272
273    DATA:int_header TYPE slis_t_listheader,
274         fs_header  TYPE slis_listheader,
275         t_line     LIKE fs_header-info.
276
277    DATA : zperiod     TYPE  rpmax,
278           zjv_nam     TYPE jvto1-rjvnam,
279           lv_diff     TYPE num,
280           lv_sumc     TYPE jvto1-hslvt,
281           lv_opnbal   TYPE jvto1-hslvt,
282           lv_opnbal_i TYPE jvto1-hslvt,
283           lv_opnbal_u TYPE jvto1-hslvt,
284           lv_clobal   TYPE jvto1-hslvt,
285           lv_clobal_i TYPE jvto1-hslvt,
286           lv_clobal_u TYPE jvto1-hslvt,
287           lv_debbal   TYPE jvto1-hslvt,
288           lv_debbal_i TYPE jvto1-hslvt,
289           lv_debbal_u TYPE jvto1-hslvt,
290           lv_crebal   TYPE jvto1-hslvt,
291           lv_crebal_i TYPE jvto1-hslvt,
292           lv_crebal_u TYPE jvto1-hslvt.
293
294    DATA : col_count TYPE i,
295           row_jv(6) TYPE c,
296           row_count TYPE i,
297           flg1      TYPE c.
298
299    DATA : gv_ukurs TYPE string.
300    DATA : lv_ukurs TYPE string.
301
302    DATA : gt_dynpread TYPE STANDARD TABLE OF dynpread,
303           gs_dynpread TYPE dynpread.
304
305    DATA: gt_return TYPE ddshretval OCCURS 0 WITH HEADER LINE.
306    *--------------------------------------------------------------*
307    *SELECTION SCREEN
308    *--------------------------------------------------------------*
309    SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME.
310
311    PARAMETERS : p_year  TYPE gjahr ,     "remove mandatory
312                 p_bukrs TYPE bukrs .  "remove mandatory
313
314    SELECT-OPTIONS p_jvnam FOR zjv_nam  .    "remove mandatory
315
316    PARAMETERS: s_curr TYPE c AS LISTBOX VISIBLE LENGTH 20 .  "remove mandatory
317
318    SELECT-OPTIONS s_period FOR zperiod NO-EXTENSION.
319
320    SELECT-OPTIONS p_rrecin FOR jvto1-rrecin.
321
322    SELECTION-SCREEN END OF BLOCK b1.
323
324    SELECTION-SCREEN:  FUNCTION KEY 1 .  " code ADDED on 27.12.2023 by sandeep rauthan
325
326    *--------------------------------------------------------------*
327    *At Selection Screen
328    *--------------------------------------------------------------*
329
330    * AT SELECTION-SCREEN.
331    *******code ADDED on 27.12.2023 by sandeep rauthan********
332    *   CASE sscrfields-ucomm.  " code ADDED on 27.12.2023 by sandeep rauthan
333    *   WHEN 'FC01'.
334    *     PERFORM processguide.
335    *  ENDCASE.
336
337    *******code ADDED on 27.12.2023 by sandeep rauthan********
338
339
340
341
342
343    AT SELECTION-SCREEN OUTPUT.
344      LOOP AT SCREEN.
345        IF screen-name = 'S_PERIOD-LOW'.
346          screen-input = 0.
347          MODIFY SCREEN.
348        ENDIF.
349      ENDLOOP.
350
351
352    AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_jvnam-low.
353      gs_dynpread-fieldname = 'P_BUKRS'.
354      APPEND gs_dynpread TO gt_dynpread.
355
356      CALL FUNCTION 'DYNP_VALUES_READ'
357        EXPORTING
358          dyname               = sy-cprog
359          dynumb               = sy-dynnr
360          translate_to_upper   = 'X'
361        TABLES
362          dynpfields           = gt_dynpread
363        EXCEPTIONS
364          invalid_abapworkarea = 1
365          invalid_dynprofield  = 2
366          invalid_dynproname   = 3
367          invalid_dynpronummer = 4
368          invalid_request      = 5
369          no_fielddescription  = 6
370          invalid_parameter    = 7
371          undefind_error       = 8
372          double_conversion    = 9
373          stepl_not_found      = 10
374          OTHERS               = 11.
375
376      CLEAR gs_dynpread.
377      READ TABLE gt_dynpread INTO gs_dynpread INDEX 1.
378
379      SELECT bukrs,
380             vname,
381             vtext
382        FROM t8jvt INTO TABLE @DATA(lt_jvf4)
383        WHERE bukrs = @gs_dynpread-fieldvalue.
384      IF gs_dynpread-fieldvalue IS INITIAL.
385        SELECT bukrs,
386               vname,
387               vtext
388          FROM t8jvt INTO TABLE @lt_jvf4.
389      ENDIF.
390
391
392      IF lt_jvf4 IS NOT INITIAL.
393        CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
394          EXPORTING
395            retfield        = 'P_JVNAM'
396            value_org       = 'S'
397          TABLES
398            value_tab       = lt_jvf4
399            return_tab      = gt_return
400          EXCEPTIONS
401            parameter_error = 1
402            no_values_found = 2
403            OTHERS          = 3.
404        IF sy-subrc <> 0.
405    * Implement suitable error handling here
406        ENDIF.
407      ENDIF.
408
409
410    AT SELECTION-SCREEN ON s_curr.
411      CLEAR: gwa_values, gt_values.
412      REFRESH gt_values.
413      gwa_values-fieldname = 'S_CURR'.
414      APPEND gwa_values TO gt_values.
415      CALL FUNCTION 'DYNP_VALUES_READ'
416        EXPORTING
417          dyname             = sy-cprog
418          dynumb             = sy-dynnr
419          translate_to_upper = 'X'
420        TABLES
421          dynpfields         = gt_values.
422
423      READ TABLE gt_values INDEX 1 INTO gwa_values.
424      IF sy-subrc = 0 AND gwa_values-fieldvalue IS NOT INITIAL.
425        READ TABLE gt_list INTO gwa_list
426                          WITH KEY key = gwa_values-fieldvalue.
427        IF sy-subrc = 0.
428          gv_selected_value = gwa_list-text.
429        ENDIF.
430      ENDIF.
431
432    AT SELECTION-SCREEN .
433    *******code ADDED on 27.12.2023 by sandeep rauthan********
434      CASE sscrfields-ucomm.  " code ADDED on 27.12.2023 by sandeep rauthan
435        WHEN 'FC01'.
436          PERFORM processguide.
437      ENDCASE.
438
439    *******code ADDED on 27.12.2023 by sandeep rauthan********
440
441      CLEAR:row_count,flg1.
442      REFRESH lt_alljv[].
443      SELECT rjvnam FROM jvto1 INTO TABLE lt_alljv
444         WHERE ryear = p_year
445           AND rbukrs = p_bukrs
446           AND rjvnam IN p_jvnam
447           AND rldnr = '4A'
448           AND rrcty = '0'
449           AND rrecin IN  p_rrecin.
450
451      SORT lt_alljv BY rjvnam ASCENDING.
452      DELETE ADJACENT DUPLICATES FROM lt_alljv.
453
454      DESCRIBE TABLE lt_alljv LINES row_count.
455      IF row_count GT 10.
456        flg1 = 'X'.
457        MESSAGE 'For more than 10 ventures only closing balance will be displayed' TYPE 'W'.
458      ENDIF.
459
460
461
462
463
464    *--------------------------------------------------------------*
465    *Initialization
466    *--------------------------------------------------------------*
467    INITIALIZATION.
468
469    ***************** code added by sandeep on 27.12.2023****************
470      smp_dyntxt-icon_id = icon_pdf .
471      smp_dyntxt-quickinfo = 'Manual'.
472      smp_dyntxt-icon_text = 'Process Guide'.
473      sscrfields-functxt_01 = smp_dyntxt.
474      CLEAR smp_dyntxt.
475    *****************code added by sandeep on 27.12.2023**********************
476
477
478      gwa_list-key = '1'.
479      gwa_list-text = 'Company Code INR'.
480      APPEND gwa_list TO gt_list.
481      gwa_list-key = '2'.
482      gwa_list-text = 'Index Based USD'.
483      APPEND gwa_list TO gt_list.
484    *  CODE ADDED BY APARNA '' 19.02.2024
485      gwa_list-key = '3'.
486      gwa_list-text = 'USD & INR'.
487      APPEND gwa_list TO gt_list.
488    * CODE ENDED BY APARNA '' 19.02.2024
489      CALL FUNCTION 'VRM_SET_VALUES'
490        EXPORTING
491          id              = 'S_CURR'
492          values          = gt_list
493        EXCEPTIONS
494          id_illegal_name = 1
495          OTHERS          = 2.
496
497      MOVE: 'I' TO s_period-sign,
498            'EQ' TO s_period-option,
499            '1' TO s_period-low.
500      APPEND s_period.
501
502    *--------------------------------------------------------------*
503    *START-OF-SELECTION.
504    *--------------------------------------------------------------*
505
506    START-OF-SELECTION.
507
508
509    ******************* C0DE ADDED ON 31.12.2023 BY SANDEEP R**********
510
511      DATA : lv_error_msg TYPE string.
512
513      IF p_year IS INITIAL.
514        MESSAGE : 'fill the fiscal year,company code,joint venture and currency field' TYPE 'E'.
515
516      ELSEIF p_bukrs IS INITIAL.
517        MESSAGE : 'fill the company code field' TYPE 'E'.
518
519
520      ELSEIF p_jvnam IS INITIAL.
521        MESSAGE : 'fill the joint venture field' TYPE 'E'.
522
523
524      ELSEIF s_period IS INITIAL.
525        MESSAGE : 'fill the currency field' TYPE 'E'.
526
527      ENDIF.
528
529    ******************* C0DE ADDED ON 31.12.2023 BY SANDEEP R**********
530
531      PERFORM get_data.
532      PERFORM set_data.
533      PERFORM disp_data.
534
535    END-OF-SELECTION.
536
537    *--------------------------------------------------------------*
538    *FORM get_data.
539    *--------------------------------------------------------------*
540    FORM get_data.
541      break abapuser02.
542      SELECT racct
543       FROM jvto1 INTO CORRESPONDING FIELDS OF TABLE lt_jvt
544          WHERE ryear = p_year
545            AND rbukrs = p_bukrs
546            AND rjvnam IN p_jvnam
547            AND rldnr = '4A'
548            AND rrcty = '0'
549      AND rrecin IN p_rrecin.
550
551      SORT lt_jvt BY racct ASCENDING.
552      DELETE ADJACENT DUPLICATES FROM lt_jvt COMPARING racct .
553      READ TABLE lt_jvt INTO DATA(ls_jvt) WITH KEY racct = '0000160206'.
554      IF ls_jvt IS INITIAL.
555        ls_jvt-racct = '0000160206'.
556        APPEND ls_jvt TO lt_jvt.
557        CLEAR ls_jvt.
558      ENDIF.
559
560      IF lt_jvt IS NOT INITIAL.
561
562        SELECT a~ktopl
563               a~saknr
564               a~xbilk
565               a~sakan
566               b~txt20
567               b~txt50
568          FROM ska1 AS a
569          INNER JOIN skat AS b ON b~saknr = a~saknr
570          INTO CORRESPONDING FIELDS OF TABLE lt_ska1
571          FOR ALL ENTRIES IN lt_jvt
572          WHERE a~saknr = lt_jvt-racct
573            AND a~ktopl = 'ONGC'
574            AND a~xbilk = ' '
575            AND b~spras = 'EN'
576        AND b~ktopl = 'ONGC'.
577
578        SELECT saknr
579               txt50
580          FROM skat
581        INTO TABLE lt_skat
582        FOR ALL ENTRIES IN lt_jvt
583        WHERE saknr = lt_jvt-racct
584        AND spras = 'E'.
585
586      ENDIF.
587
588      IF gv_selected_value  = 'Company Code INR'.
589
590        SELECT SUM( hslvt ) AS hslvt rjvnam racct
591          FROM jvto1 INTO CORRESPONDING FIELDS OF TABLE lt_jvto1
592          WHERE ryear = p_year
593            AND rbukrs = p_bukrs
594            AND rjvnam IN p_jvnam
595            AND rldnr = '4A'
596            AND rrcty = '0'
597            AND rrecin IN  p_rrecin
598        GROUP BY rjvnam racct.
599
600        SELECT SUM( hsl ) AS hsl rjvnam racct
601          FROM jvso1 INTO CORRESPONDING FIELDS OF TABLE lt_jvso1_1
602          WHERE ryear = p_year
603            AND rbukrs = p_bukrs
604            AND rjvnam IN p_jvnam
605            AND poper BETWEEN s_period-low AND s_period-high
606            AND rldnr = '4A'
607            AND rrcty = '0'
608            AND drcrk = 'H'
609            AND rrecin IN p_rrecin
610        GROUP BY rjvnam racct.
611
612        SELECT SUM( hsl ) AS hsl rjvnam racct
613          FROM jvso1 INTO CORRESPONDING FIELDS OF TABLE lt_jvso1_2
614          WHERE ryear = p_year
615            AND rbukrs = p_bukrs
616            AND rjvnam IN p_jvnam
617            AND poper BETWEEN s_period-low AND s_period-high
618            AND rldnr = '4A'
619            AND rrcty = '0'
620            AND drcrk = 'S'
621            AND rrecin IN p_rrecin
622        GROUP BY rjvnam racct.
623
624      ELSEIF gv_selected_value  = 'Index Based USD'.
625
626        SELECT SUM( kslvt ) AS hslvt rjvnam racct
627           FROM jvto1 INTO CORRESPONDING FIELDS OF TABLE lt_jvto1
628           WHERE ryear = p_year
629             AND rbukrs = p_bukrs
630             AND rjvnam IN p_jvnam
631             AND rldnr = '4A'
632             AND rrcty = '0'
633             AND rrecin IN  p_rrecin
634        GROUP BY rjvnam racct.
635
636        SELECT SUM( ksl ) AS ksl rjvnam racct
637           FROM jvso1 INTO CORRESPONDING FIELDS OF TABLE lt_jvso1_1
638           WHERE ryear = p_year
639             AND rbukrs = p_bukrs
640             AND rjvnam IN p_jvnam
641             AND poper BETWEEN s_period-low AND s_period-high
642             AND rldnr = '4A'
643             AND rrcty = '0'
644             AND drcrk = 'H'
645             AND rrecin IN p_rrecin
646        GROUP BY rjvnam racct.
647
648        SELECT SUM( ksl ) AS ksl rjvnam racct
649          FROM jvso1 INTO CORRESPONDING FIELDS OF TABLE lt_jvso1_2
650          WHERE ryear = p_year
651            AND rbukrs = p_bukrs
652            AND rjvnam IN p_jvnam
653            AND poper BETWEEN s_period-low AND s_period-high
654            AND rldnr = '4A'
655            AND rrcty = '0'
656            AND drcrk = 'S'
657            AND rrecin IN p_rrecin
658        GROUP BY rjvnam racct.
659
660    ************************************* CODE BEGIN BY APARNA ANAND 19.02.2024     ADDITION USD + INR
661
662      ELSEIF gv_selected_value  = 'USD & INR'.
663
664
665
666        SELECT SUM( hslvt  ) AS  hslvt  SUM( kslvt ) AS   kslvt rjvnam racct
667          FROM jvto1 INTO CORRESPONDING FIELDS OF TABLE lt_jvto1
668          WHERE ryear = p_year
669            AND rbukrs = p_bukrs
670            AND rjvnam IN p_jvnam
671            AND rldnr = '4A'
672            AND rrcty = '0'
673            AND rrecin IN  p_rrecin
674        GROUP BY rjvnam racct .
675
676        SELECT SUM( hsl ) AS hsl SUM( ksl )  AS ksl rjvnam racct
677      FROM jvso1 INTO CORRESPONDING FIELDS OF TABLE lt_jvso1_1
678      WHERE ryear = p_year
679        AND rbukrs = p_bukrs
680        AND rjvnam IN p_jvnam
681        AND poper BETWEEN s_period-low AND s_period-high
682        AND rldnr = '4A'
683        AND rrcty = '0'
684        AND drcrk = 'H'
685        AND rrecin IN p_rrecin
686    GROUP BY rjvnam racct.
687
688
689
690        SELECT SUM( hsl ) AS hsl SUM( ksl )  AS ksl rjvnam racct
691           FROM jvso1 INTO CORRESPONDING FIELDS OF TABLE lt_jvso1_2
692           WHERE ryear = p_year
693             AND rbukrs = p_bukrs
694             AND rjvnam IN p_jvnam
695             AND poper BETWEEN s_period-low AND s_period-high
696             AND rldnr = '4A'
697             AND rrcty = '0'
698             AND drcrk = 'S'
699             AND rrecin IN p_rrecin
700         GROUP BY rjvnam racct.
701
702    **************************************** CODE ENDED APARNA ANAND 19.02.2024    ADDITION USD + INR
703
704      ENDIF.
705
706
707    ENDFORM.
708    *--------------------------------------------------------------*
709    *FORM set_data.
710    *--------------------------------------------------------------*
711    FORM set_data.
712
713      SORT lt_jvt BY racct ASCENDING.
714      SORT lt_jvto1 BY racct  ASCENDING.
715      SORT lt_jvso1_1 BY racct  ASCENDING.
716      SORT lt_jvso1_2 BY racct  ASCENDING.
717      SORT lt_jvto1_ad BY racct  ASCENDING.
718
719      IF gv_selected_value  = 'Company Code INR'.
720
721        LOOP AT lt_jvt INTO ls_jvt .
722          LOOP AT lt_alljv INTO ls_alljv.
723            ls_final-rjvnam = ls_alljv-rjvnam.
724            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
725              EXPORTING
726                input  = ls_jvt-racct
727              IMPORTING
728                output = ls_final-racct.
729
730            READ TABLE lt_jvso1_1 INTO ls_jvso1_1 WITH KEY racct = ls_jvt-racct rjvnam = ls_alljv-rjvnam.
731            IF ls_jvso1_1-hsl IS NOT INITIAL.
732              ls_final-bal_cre =  ls_jvso1_1-hsl * -1 .
733            ENDIF.
734
735            READ TABLE lt_jvso1_2 INTO ls_jvso1_2 WITH KEY racct = ls_jvt-racct rjvnam = ls_alljv-rjvnam.
736            IF ls_jvso1_2-hsl IS NOT INITIAL.
737              ls_final-bal_deb =  ls_jvso1_2-hsl.
738            ENDIF.
739
740            READ TABLE lt_jvto1 INTO ls_jvto1 WITH KEY racct = ls_jvt-racct rjvnam = ls_alljv-rjvnam.
741            READ TABLE lt_ska1 INTO ls_ska1 WITH KEY saknr = ls_jvto1-racct.
742            IF sy-subrc EQ 0.
743              ls_final-bal_opn = '0'.
744            ELSEIF sy-subrc NE 0.
745              ls_final-bal_opn = ls_jvto1-hslvt.
746            ENDIF.
747
748            READ TABLE lt_skat INTO ls_skat WITH KEY saknr = ls_jvt-racct.
749            ls_final-txt50 = ls_skat-txt50.
750
751            ls_final-bal_clo = ls_final-bal_clo + ls_final-bal_opn + ls_final-bal_deb - ls_final-bal_cre.
752
753            IF ls_final IS NOT INITIAL.
754              IF ( ls_final-bal_clo NE '0.00' ) OR ( ls_final-bal_opn NE '0.00') OR ( ls_final-bal_deb NE '0.00' ) OR ( ls_final-bal_cre NE '0.00' ).
755                APPEND ls_final TO lt_final.
756              ENDIF.
757            ENDIF.
758
759            IF ls_final-racct = '160206'.
760              APPEND ls_final TO lt_final.
761            ENDIF.
762
763            IF ls_final-racct = '120170'." add by rohit on 16.07.2025
764              APPEND ls_final TO lt_final.
765            ENDIF.
766
767            CLEAR : ls_final,ls_jvso1_1,ls_jvto1,ls_ska1,ls_skat,ls_jvt_1,ls_alljv,ls_jvso1_2.
768          ENDLOOP.
769          CLEAR ls_jvt.
770        ENDLOOP.
771
772      ELSEIF gv_selected_value  = 'Index Based USD'.
773
774        LOOP AT lt_jvt INTO ls_jvt .
775          LOOP AT lt_alljv INTO ls_alljv.
776            ls_final-rjvnam = ls_alljv-rjvnam.
777            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
778              EXPORTING
779                input  = ls_jvt-racct
780              IMPORTING
781                output = ls_final-racct.
782
783            READ TABLE lt_jvso1_1 INTO ls_jvso1_1 WITH KEY racct = ls_jvt-racct rjvnam = ls_alljv-rjvnam.
784            IF ls_jvso1_1-ksl IS NOT INITIAL.
785              ls_final-bal_cre =  ls_jvso1_1-ksl * -1 .
786            ENDIF.
787
788            READ TABLE lt_jvso1_2 INTO ls_jvso1_2 WITH KEY racct = ls_jvt-racct rjvnam = ls_alljv-rjvnam.
789            IF ls_jvso1_2-ksl IS NOT INITIAL.
790              ls_final-bal_deb =  ls_jvso1_2-ksl.
791            ENDIF.
792
793            READ TABLE lt_jvto1 INTO ls_jvto1 WITH KEY racct = ls_jvt-racct rjvnam = ls_alljv-rjvnam.
794            READ TABLE lt_ska1 INTO ls_ska1 WITH KEY saknr = ls_jvto1-racct.
795            IF sy-subrc EQ 0.
796              ls_final-bal_opn = '0'.
797            ELSEIF sy-subrc NE 0.
798              ls_final-bal_opn = ls_jvto1-hslvt.
799            ENDIF.
800
801            READ TABLE lt_skat INTO ls_skat WITH KEY saknr = ls_jvt-racct.
802            ls_final-txt50 = ls_skat-txt50.
803
804            ls_final-bal_clo = ls_final-bal_clo + ls_final-bal_opn + ls_final-bal_deb - ls_final-bal_cre.
805
806            IF ls_final IS NOT INITIAL.
807              IF ( ls_final-bal_clo NE '0.00' ) OR ( ls_final-bal_opn NE '0.00') OR ( ls_final-bal_deb NE '0.00' ) OR ( ls_final-bal_cre NE '0.00' ).
808                APPEND ls_final TO lt_final.
809              ENDIF.
810            ENDIF.
811
812            IF ls_final-racct = '160206'.
813              APPEND ls_final TO lt_final.
814            ENDIF.
815            IF ls_final-racct = '120170'." add by rohit on 16.07.2025
816              APPEND ls_final TO lt_final.
817            ENDIF.
818            CLEAR : ls_final,ls_jvso1_1,ls_jvto1,ls_ska1,ls_skat,ls_jvt_1,ls_alljv,ls_jvso1_2.
819          ENDLOOP.
820          CLEAR ls_jvt.
821        ENDLOOP.
822    ************************************************************************************************************
823      ELSEIF gv_selected_value  = 'USD & INR'.
824
825        LOOP AT lt_jvt INTO ls_jvt .
826          LOOP AT lt_alljv INTO ls_alljv.
827            ls_final-rjvnam = ls_alljv-rjvnam.
828            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
829              EXPORTING
830                input  = ls_jvt-racct
831              IMPORTING
832                output = ls_final-racct.
833
834            READ TABLE lt_jvso1_1 INTO ls_jvso1_1 WITH KEY racct = ls_jvt-racct rjvnam = ls_alljv-rjvnam.
835            IF ls_jvso1_1-hsl IS NOT INITIAL.
836              ls_final-bal_cre_i =  ls_jvso1_1-hsl * -1 .
837              ls_final-bal_cre_u =  ls_jvso1_1-ksl * -1 .
838            ENDIF.
839
840            READ TABLE lt_jvso1_2 INTO ls_jvso1_2 WITH KEY racct = ls_jvt-racct rjvnam = ls_alljv-rjvnam.
841            IF ls_jvso1_2-hsl IS NOT INITIAL.
842              ls_final-bal_deb_i =  ls_jvso1_2-hsl.
843              ls_final-bal_deb_u =  ls_jvso1_2-ksl.
844            ENDIF.
845
846            READ TABLE lt_jvto1 INTO ls_jvto1 WITH KEY racct = ls_jvt-racct rjvnam = ls_alljv-rjvnam.
847            READ TABLE lt_ska1 INTO ls_ska1 WITH KEY saknr = ls_jvto1-racct.
848            IF sy-subrc EQ 0.
849              ls_final-bal_opn = '0'.
850            ELSEIF sy-subrc NE 0.
851              ls_final-bal_opn_i = ls_jvto1-hslvt.
852              ls_final-bal_opn_u = ls_jvto1-kslvt.
853            ENDIF.
854
855            READ TABLE lt_skat INTO ls_skat WITH KEY saknr = ls_jvt-racct.
856            ls_final-txt50 = ls_skat-txt50.
857
858            ls_final-bal_clo_i = ls_final-bal_clo_i + ls_final-bal_opn_i + ls_final-bal_deb_i - ls_final-bal_cre_i.
859            ls_final-bal_clo_u = ls_final-bal_clo_u + ls_final-bal_opn_u + ls_final-bal_deb_u - ls_final-bal_cre_u.
860
861            IF ls_final IS NOT INITIAL.
862              IF ( ls_final-bal_clo_i NE '0.00' )  OR ( ls_final-bal_clo_u NE '0.00' ) OR ( ls_final-bal_opn_i NE '0.00') OR ( ls_final-bal_opn_u NE '0.00')  OR ( ls_final-bal_deb_i NE '0.00' )  OR ( ls_final-bal_deb_u NE '0.00' )
863               OR ( ls_final-bal_cre_i NE '0.00' ) OR ( ls_final-bal_cre_u NE '0.00' ).
864                APPEND ls_final TO lt_final.
865              ENDIF.
866            ENDIF.
867
868            IF ls_final-racct = '160206'.
869              APPEND ls_final TO lt_final.
870            ENDIF.
871
872            IF ls_final-racct = '120170'." add by rohit on 16.07.2025
873              APPEND ls_final TO lt_final.
874            ENDIF.
875
876            CLEAR : ls_final,ls_jvso1_1,ls_jvto1,ls_ska1,ls_skat,ls_jvt_1,ls_alljv,ls_jvso1_2.
877          ENDLOOP.
878          CLEAR ls_jvt.
879        ENDLOOP.
880
881      ENDIF.
882    ***********************************************************************
883
884
885      DATA lv_160206 TYPE skat-txt50.
886      CLEAR lv_160206.
887
888      SELECT SINGLE txt50 FROM skat INTO lv_160206 WHERE saknr = '0000160206'
889                                                            AND ktopl = 'ONGC'
890      AND spras = 'EN'.
891
892      CLEAR : lv_opnbal, lv_crebal,lv_clobal,lv_debbal , lv_opnbal_i, lv_crebal_i ,lv_clobal_i ,lv_debbal_i  ,lv_opnbal_u , lv_crebal_u ,lv_clobal_u ,lv_debbal_u.
893      break abapuser02.
894      LOOP AT lt_alljv INTO ls_alljv.
895        LOOP AT lt_ska1 INTO ls_ska1.
896
897          READ TABLE lt_jvto1 INTO ls_jvto1 WITH KEY racct = ls_ska1-saknr rjvnam = ls_alljv-rjvnam.
898          IF sy-subrc = 0.
899            IF gv_selected_value  = 'USD & INR'.
900    *           lv_opnbal   = ls_jvto1-kslvt.
901              lv_opnbal_i = ls_jvto1-hslvt.
902              lv_opnbal_u = ls_jvto1-kslvt.
903            ELSE.
904              lv_opnbal   = ls_jvto1-hslvt.
905            ENDIF.
906            DATA(flag_ad) = 'X'.
907            DATA(flag) = 'X'.
908          ENDIF.
909    *  ENDLOOP.
910
911          IF gv_selected_value  = 'Company Code INR'.
912            READ TABLE lt_jvso1_1 INTO ls_jvso1_1 WITH KEY racct = ls_ska1-saknr rjvnam = ls_alljv-rjvnam.
913            IF ls_jvso1_1-hsl IS NOT INITIAL.
914              lv_crebal = ls_jvso1_2-hsl * -1.
915              flag = 'X'.
916            ENDIF.
917            READ TABLE lt_jvso1_2 INTO ls_jvso1_2 WITH KEY racct = ls_ska1-saknr rjvnam = ls_alljv-rjvnam.
918            IF ls_jvso1_2-hsl IS NOT INITIAL.
919              lv_debbal = ls_jvso1_1-hsl.
920              flag = 'X'.
921            ENDIF.
922
923          ELSEIF gv_selected_value  = 'Index Based USD'.
924
925            READ TABLE lt_jvso1_1 INTO ls_jvso1_1 WITH KEY racct = ls_ska1-saknr rjvnam = ls_alljv-rjvnam.
926            IF ls_jvso1_1-hsl IS NOT INITIAL.
927              lv_crebal = ls_jvso1_2-hsl * -1.
928              flag = 'X'.
929            ENDIF.
930            READ TABLE lt_jvso1_2 INTO ls_jvso1_2 WITH KEY racct = ls_ska1-saknr rjvnam = ls_alljv-rjvnam.
931            IF ls_jvso1_2-hsl IS NOT INITIAL.
932              lv_debbal = ls_jvso1_1-hsl.
933              flag = 'X'.
934            ENDIF.
935          ELSEIF gv_selected_value  = 'USD & INR'.
936
937            READ TABLE lt_jvso1_1 INTO ls_jvso1_1 WITH KEY racct = ls_ska1-saknr rjvnam = ls_alljv-rjvnam.
938            IF sy-subrc = 0..
939              lv_crebal_i = ls_jvso1_2-hsl * -1.
940              lv_crebal_u = ls_jvso1_2-ksl * -1.
941              flag = 'X'.
942            ENDIF.
943            READ TABLE lt_jvso1_2 INTO ls_jvso1_2 WITH KEY racct = ls_ska1-saknr rjvnam = ls_alljv-rjvnam.
944            IF sy-subrc = 0.
945              lv_debbal_i = ls_jvso1_1-hsl.
946              lv_debbal_u = ls_jvso1_1-ksl.
947              flag = 'X'.
948            ENDIF.
949          ENDIF.
950
951    *BREAK abapuser02.
952          IF flag_ad = 'X'.
953            READ TABLE lt_final INTO ls_final WITH KEY racct = '160206' rjvnam = ls_alljv-rjvnam.
954            IF sy-subrc = 0.
955              lv_clobal          = ls_final-bal_clo.
956              lv_clobal_i        = ls_final-bal_clo_i.
957              lv_clobal_u        = ls_final-bal_clo_u.
958              ls_final-bal_clo   = lv_opnbal .
959              ls_final-bal_clo_i = lv_opnbal_i.
960              ls_final-bal_clo_u = lv_opnbal_u .
961              ls_final-bal_clo   = ls_final-bal_clo   +  lv_clobal.
962              ls_final-bal_clo_i = ls_final-bal_clo_i +  lv_clobal_i.
963              ls_final-bal_clo_u = ls_final-bal_clo_u +  lv_clobal_u.
964              ls_final-bal_opn   = ls_final-bal_opn   +  lv_opnbal.
965              ls_final-bal_opn_i = ls_final-bal_opn_i +  lv_opnbal_i.
966              ls_final-bal_opn_u = ls_final-bal_opn_u +  lv_opnbal_u.
967              ls_final-bal_deb   = ls_final-bal_opn   +  lv_debbal.
968              ls_final-bal_deb_i = ls_final-bal_opn_i +  lv_debbal_i.
969              ls_final-bal_deb_u = ls_final-bal_opn_u +  lv_debbal_u.
970              ls_final-bal_cre   = ls_final-bal_opn   +  lv_crebal.
971              ls_final-bal_cre_i = ls_final-bal_opn_i +  lv_crebal_i.
972              ls_final-bal_cre_u = ls_final-bal_opn_u +  lv_crebal_u.
973              ls_final-txt50     = lv_160206.
974
975              IF flag = 'X'.
976                MODIFY lt_final FROM ls_final TRANSPORTING bal_opn bal_clo txt50 WHERE racct = '160206' AND rjvnam = ls_alljv-rjvnam.
977              ENDIF.
978              IF flag = 'X' AND  gv_selected_value  = 'USD & INR'.
979                MODIFY lt_final FROM ls_final TRANSPORTING bal_opn_i  bal_opn_u  bal_clo_i  bal_clo_u  txt50 WHERE racct = '160206' AND rjvnam = ls_alljv-rjvnam.
980              ENDIF.
981            ELSEIF ls_final IS INITIAL.
982
983            ENDIF.
984          ENDIF.
985
986
987          CLEAR : ls_final,ls_jvto1,lv_opnbal,ls_ska1,lv_debbal,lv_debbal_i , lv_debbal_u ,lv_crebal, lv_crebal_i ,lv_crebal_u ,lv_clobal ,
988                  lv_crebal_i ,lv_crebal_u, flag_ad, lv_opnbal_i, lv_opnbal_u, lv_clobal_i, lv_clobal_u.
989        ENDLOOP.
990        CLEAR ls_alljv.
991      ENDLOOP.
992
993      PERFORM after_set_data.
994
995      CLEAR : lv_opnbal, lv_crebal,lv_crebal_i ,lv_crebal_u ,lv_clobal, lv_crebal_i ,lv_crebal_u ,lv_debbal ,lv_debbal_i , lv_debbal_u,
996              lv_opnbal_i, lv_opnbal_u.
997      break abapuser02.
998      LOOP AT lt_alljv INTO ls_alljv.
999        LOOP AT lt_bfinal INTO ls_bfinal WHERE rjvnam = ls_alljv-rjvnam.
1000
1001         IF ls_bfinal IS NOT INITIAL.
1002
1003           lv_opnbal   =  lv_opnbal   + ls_bfinal-bal_opn.
1004           lv_opnbal_i =  lv_opnbal_i + ls_bfinal-bal_opn_i.
1005           lv_opnbal_u =  lv_opnbal_u + ls_bfinal-bal_opn_u.
1006           lv_clobal   =  lv_clobal   + ls_bfinal-bal_clo.
1007           lv_clobal_i =  lv_clobal_i + ls_bfinal-bal_clo_i.
1008           lv_clobal_u =  lv_clobal_u + ls_bfinal-bal_clo_u.
1009           lv_crebal   =  lv_crebal   + ls_bfinal-bal_cre.
1010           lv_crebal_i =  lv_crebal_i + ls_bfinal-bal_cre_i.
1011           lv_crebal_u =  lv_crebal_u + ls_bfinal-bal_cre_u.
1012           lv_debbal   =  lv_debbal   + ls_bfinal-bal_deb.
1013           lv_debbal_i =  lv_debbal_i + ls_bfinal-bal_deb_i.
1014           lv_debbal_u =  lv_debbal_i + ls_bfinal-bal_deb_u.
1015
1016           CLEAR ls_bfinal.
1017         ENDIF.
1018
1019         DATA(flag2) = 'X'.
1020       ENDLOOP.
1021
1022       IF flag = 'X'.
1023         READ TABLE lt_final INTO ls_final WITH KEY racct = '120170' rjvnam = ls_alljv-rjvnam.
1024         ls_final-bal_opn   = ls_final-bal_opn   + lv_opnbal.
1025         ls_final-bal_opn_i = ls_final-bal_opn_i + lv_opnbal_i.
1026         ls_final-bal_opn_u = ls_final-bal_opn_u + lv_opnbal_u.
1027         ls_final-bal_clo   = ls_final-bal_clo   + lv_clobal.
1028         ls_final-bal_clo_i = ls_final-bal_clo_i + lv_clobal_i.
1029         ls_final-bal_clo_u = ls_final-bal_clo_u + lv_clobal_u.
1030         ls_final-bal_cre   = ls_final-bal_cre   + lv_crebal.
1031         ls_final-bal_cre_i = ls_final-bal_cre_i + lv_crebal_i.
1032         ls_final-bal_cre_u = ls_final-bal_cre_u + lv_crebal_u.
1033         ls_final-bal_deb   = ls_final-bal_deb   + lv_debbal.
1034         ls_final-bal_deb_i = ls_final-bal_deb_i + lv_debbal_i.
1035         ls_final-bal_deb_u = ls_final-bal_deb_u + lv_debbal_u.
1036
1037         IF ls_final IS NOT INITIAL.
1038           MODIFY lt_final FROM ls_final TRANSPORTING bal_opn bal_clo bal_cre bal_deb
1039            bal_opn_i  bal_opn_u  bal_clo_i  bal_clo_u  WHERE rjvnam = ls_alljv-rjvnam AND racct = '120170'.
1040         ENDIF.
1041   *      IF flag = 'X' AND  gv_selected_value  = 'USD & INR'.
1042   *        MODIFY lt_final FROM ls_final TRANSPORTING bal_opn_i  bal_opn_u  bal_clo_i  bal_clo_u  txt50 WHERE racct = '120170' AND rjvnam = ls_alljv-rjvnam.
1043   *      ENDIF.
1044       ENDIF.
1045
1046       CLEAR : ls_alljv ,ls_final ,lv_clobal ,lv_clobal_i,lv_clobal_u,lv_crebal ,lv_crebal_i ,lv_crebal_u ,lv_opnbal ,lv_opnbal_i ,lv_opnbal_u ,lv_debbal ,lv_debbal_i ,lv_debbal_u.
1047     ENDLOOP.
1048
1049     CLEAR : ls_final,ls_jvto1,ls_ska1,lv_opnbal, lv_opnbal_i ,lv_opnbal_u ,  lv_clobal ,lv_clobal_i,lv_clobal_u ,lv_crebal, lv_crebal_i ,lv_crebal_u ,lv_debbal ,lv_debbal_i ,lv_debbal_u.
1050
1051     SORT lt_final BY rjvnam racct ASCENDING.
1052     DELETE ADJACENT DUPLICATES FROM lt_final COMPARING rjvnam racct.
1053
1054     IF gv_selected_value  = 'USD & INR'.
1055       flg1 = 'X'.
1056     ENDIF.
1057   ENDFORM.
1058   *--------------------------------------------------------------*
1059   *FORM disp_data.
1060   *--------------------------------------------------------------*
1061   FORM disp_data .
1062   ******************************************Added on 01.11.2022 by hrishi n*****************************
1063     IF lt_final IS NOT INITIAL.
1064       MOVE-CORRESPONDING lt_final[] TO lt_final2[].
1065       MOVE-CORRESPONDING lt_final[] TO lt_final3[].
1066     ENDIF.
1067
1068     IF lt_final3 IS NOT INITIAL.
1069       SORT lt_final3 BY racct ASCENDING.
1070       DELETE ADJACENT DUPLICATES FROM lt_final3 COMPARING racct.
1071     ENDIF.
1072
1073     IF lt_final3 IS NOT INITIAL.
1074       SORT lt_final3 BY racct ASCENDING.
1075
1076       LOOP AT lt_final3 INTO ls_final3.
1077         ls_final4-racct = ls_final3-racct.
1078         ls_final4-txt50 = ls_final3-txt50.
1079
1080         APPEND ls_final4 TO lt_final4.
1081         CLEAR ls_final4.
1082       ENDLOOP.
1083     ENDIF.
1084
1085
1086     IF flg1 NE 'X'.
1087
1088       CLEAR col_count.
1089       SORT lt_final2 BY rjvnam racct ASCENDING.
1090       READ TABLE lt_alljv INTO DATA(ls_jvnam) INDEX 1.
1091
1092       IF ls_jvnam IS NOT INITIAL.
1093         col_count = col_count + 1.
1094
1095         LOOP AT lt_final4 INTO ls_final4 .
1096           LOOP AT lt_final2 INTO ls_final2 WHERE racct = ls_final4-racct AND rjvnam = ls_jvnam-rjvnam.
1097             ls_final4-bal_clo1 = ls_final2-bal_clo.
1098             ls_final4-bal_opn1 = ls_final2-bal_opn.
1099             ls_final4-bal_deb1 = ls_final2-bal_deb.
1100             ls_final4-bal_cre1 = ls_final2-bal_cre.
1101             MODIFY lt_final4 FROM ls_final4 TRANSPORTING bal_clo1
1102                                                          bal_opn1
1103                                                          bal_deb1
1104                                                          bal_cre1 WHERE racct = ls_final2-racct.
1105           ENDLOOP.
1106         ENDLOOP.
1107       ENDIF.
1108
1109       CLEAR ls_jvnam.
1110       READ TABLE lt_alljv INTO ls_jvnam INDEX 2.
1111
1112       IF ls_jvnam IS NOT INITIAL.
1113         col_count = col_count + 1.
1114
1115         LOOP AT lt_final4 INTO ls_final4 .
1116           LOOP AT lt_final2 INTO ls_final2 WHERE racct = ls_final4-racct AND rjvnam = ls_jvnam-rjvnam.
1117             ls_final4-bal_clo2 = ls_final2-bal_clo.
1118             ls_final4-bal_opn2 = ls_final2-bal_opn.
1119             ls_final4-bal_deb2 = ls_final2-bal_deb.
1120             ls_final4-bal_cre2 = ls_final2-bal_cre.
1121             MODIFY lt_final4 FROM ls_final4 TRANSPORTING bal_clo2
1122                                                          bal_opn2
1123                                                          bal_deb2
1124                                                          bal_cre2 WHERE racct = ls_final2-racct.
1125           ENDLOOP.
1126         ENDLOOP.
1127       ENDIF.
1128
1129       CLEAR ls_jvnam.
1130       READ TABLE lt_alljv INTO ls_jvnam INDEX 3.
1131
1132       IF ls_jvnam IS NOT INITIAL.
1133         col_count = col_count + 1.
1134
1135         LOOP AT lt_final4 INTO ls_final4 .
1136           LOOP AT lt_final2 INTO ls_final2 WHERE racct = ls_final4-racct AND rjvnam = ls_jvnam-rjvnam.
1137             ls_final4-bal_clo3 = ls_final2-bal_clo.
1138             ls_final4-bal_opn3 = ls_final2-bal_opn.
1139             ls_final4-bal_deb3 = ls_final2-bal_deb.
1140             ls_final4-bal_cre3 = ls_final2-bal_cre.
1141             MODIFY lt_final4 FROM ls_final4 TRANSPORTING bal_clo3
1142                                                          bal_opn3
1143                                                          bal_deb3
1144                                                          bal_cre3 WHERE racct = ls_final2-racct.
1145           ENDLOOP.
1146         ENDLOOP.
1147       ENDIF.
1148
1149       CLEAR ls_jvnam.
1150       READ TABLE lt_alljv INTO ls_jvnam INDEX 4.
1151
1152       IF ls_jvnam IS NOT INITIAL.
1153         col_count = col_count + 1.
1154
1155         LOOP AT lt_final4 INTO ls_final4 .
1156           LOOP AT lt_final2 INTO ls_final2 WHERE racct = ls_final4-racct AND rjvnam = ls_jvnam-rjvnam.
1157             ls_final4-bal_clo4 = ls_final2-bal_clo.
1158             ls_final4-bal_opn4 = ls_final2-bal_opn.
1159             ls_final4-bal_deb4 = ls_final2-bal_deb.
1160             ls_final4-bal_cre4 = ls_final2-bal_cre.
1161             MODIFY lt_final4 FROM ls_final4 TRANSPORTING bal_clo4
1162                                                          bal_opn4
1163                                                          bal_deb4
1164                                                          bal_cre4 WHERE racct = ls_final2-racct.
1165           ENDLOOP.
1166         ENDLOOP.
1167       ENDIF.
1168
1169       CLEAR ls_jvnam.
1170       READ TABLE lt_alljv INTO ls_jvnam INDEX 5.
1171
1172       IF ls_jvnam IS NOT INITIAL.
1173         col_count = col_count + 1.
1174
1175         LOOP AT lt_final4 INTO ls_final4 .
1176           LOOP AT lt_final2 INTO ls_final2 WHERE racct = ls_final4-racct AND rjvnam = ls_jvnam-rjvnam.
1177             ls_final4-bal_clo5 = ls_final2-bal_clo.
1178             ls_final4-bal_opn5 = ls_final2-bal_opn.
1179             ls_final4-bal_deb5 = ls_final2-bal_deb.
1180             ls_final4-bal_cre5 = ls_final2-bal_cre.
1181             MODIFY lt_final4 FROM ls_final4 TRANSPORTING bal_clo5
1182                                                          bal_opn5
1183                                                          bal_deb5
1184                                                          bal_cre5 WHERE racct = ls_final2-racct.
1185           ENDLOOP.
1186         ENDLOOP.
1187       ENDIF.
1188
1189       CLEAR ls_jvnam.
1190       READ TABLE lt_alljv INTO ls_jvnam INDEX 6.
1191
1192       IF ls_jvnam IS NOT INITIAL.
1193         col_count = col_count + 1.
1194
1195         LOOP AT lt_final4 INTO ls_final4 .
1196           LOOP AT lt_final2 INTO ls_final2 WHERE racct = ls_final4-racct AND rjvnam = ls_jvnam-rjvnam.
1197             ls_final4-bal_clo6 = ls_final2-bal_clo.
1198             ls_final4-bal_opn6 = ls_final2-bal_opn.
1199             ls_final4-bal_deb6 = ls_final2-bal_deb.
1200             ls_final4-bal_cre6 = ls_final2-bal_cre.
1201             MODIFY lt_final4 FROM ls_final4 TRANSPORTING bal_clo6
1202                                                          bal_opn6
1203                                                          bal_deb6
1204                                                          bal_cre6 WHERE racct = ls_final2-racct.
1205           ENDLOOP.
1206         ENDLOOP.
1207       ENDIF.
1208
1209       CLEAR ls_jvnam.
1210       READ TABLE lt_alljv INTO ls_jvnam INDEX 7.
1211
1212       IF ls_jvnam IS NOT INITIAL.
1213         col_count = col_count + 1.
1214
1215         LOOP AT lt_final4 INTO ls_final4 .
1216           LOOP AT lt_final2 INTO ls_final2 WHERE racct = ls_final4-racct AND rjvnam = ls_jvnam-rjvnam.
1217             ls_final4-bal_clo7 = ls_final2-bal_clo.
1218             ls_final4-bal_opn7 = ls_final2-bal_opn.
1219             ls_final4-bal_deb7 = ls_final2-bal_deb.
1220             ls_final4-bal_cre7 = ls_final2-bal_cre.
1221             MODIFY lt_final4 FROM ls_final4 TRANSPORTING bal_clo7
1222                                                          bal_opn7
1223                                                          bal_deb7
1224                                                          bal_cre7 WHERE racct = ls_final2-racct.
1225           ENDLOOP.
1226         ENDLOOP.
1227       ENDIF.
1228
1229       CLEAR ls_jvnam.
1230       READ TABLE lt_alljv INTO ls_jvnam INDEX 8.
1231
1232       IF ls_jvnam IS NOT INITIAL.
1233         col_count = col_count + 1.
1234
1235         LOOP AT lt_final4 INTO ls_final4 .
1236           LOOP AT lt_final2 INTO ls_final2 WHERE racct = ls_final4-racct AND rjvnam = ls_jvnam-rjvnam.
1237             ls_final4-bal_clo8 = ls_final2-bal_clo.
1238             ls_final4-bal_opn8 = ls_final2-bal_opn.
1239             ls_final4-bal_deb8 = ls_final2-bal_deb.
1240             ls_final4-bal_cre8 = ls_final2-bal_cre.
1241             MODIFY lt_final4 FROM ls_final4 TRANSPORTING bal_clo8
1242                                                          bal_opn8
1243                                                          bal_deb8
1244                                                          bal_cre8 WHERE racct = ls_final2-racct.
1245           ENDLOOP.
1246         ENDLOOP.
1247       ENDIF.
1248
1249       CLEAR ls_jvnam.
1250       READ TABLE lt_alljv INTO ls_jvnam INDEX 9.
1251
1252       IF ls_jvnam IS NOT INITIAL.
1253         col_count = col_count + 1.
1254
1255         LOOP AT lt_final4 INTO ls_final4 .
1256           LOOP AT lt_final2 INTO ls_final2 WHERE racct = ls_final4-racct AND rjvnam = ls_jvnam-rjvnam.
1257             ls_final4-bal_clo9 = ls_final2-bal_clo.
1258             ls_final4-bal_opn9 = ls_final2-bal_opn.
1259             ls_final4-bal_deb9 = ls_final2-bal_deb.
1260             ls_final4-bal_cre9 = ls_final2-bal_cre.
1261             MODIFY lt_final4 FROM ls_final4 TRANSPORTING bal_clo9
1262                                                          bal_opn9
1263                                                          bal_deb9
1264                                                          bal_cre9 WHERE racct = ls_final2-racct.
1265           ENDLOOP.
1266         ENDLOOP.
1267       ENDIF.
1268
1269       CLEAR ls_jvnam.
1270       READ TABLE lt_alljv INTO ls_jvnam INDEX 10.
1271
1272       IF ls_jvnam IS NOT INITIAL.
1273         col_count = col_count + 1.
1274
1275         LOOP AT lt_final4 INTO ls_final4 .
1276           LOOP AT lt_final2 INTO ls_final2 WHERE racct = ls_final4-racct AND rjvnam = ls_jvnam-rjvnam.
1277             ls_final4-bal_clo10 = ls_final2-bal_clo.
1278             ls_final4-bal_opn10 = ls_final2-bal_opn.
1279             ls_final4-bal_deb10 = ls_final2-bal_deb.
1280             ls_final4-bal_cre10 = ls_final2-bal_cre.
1281             MODIFY lt_final4 FROM ls_final4 TRANSPORTING bal_clo10
1282                                                          bal_opn10
1283                                                          bal_deb10
1284                                                          bal_cre10 WHERE racct = ls_final2-racct.
1285           ENDLOOP.
1286         ENDLOOP.
1287       ENDIF.
1288
1289   ***************************************End of addn by hrishi n on 01.11.2022**************************************
1290
1291       PERFORM fcat_fill.
1292       PERFORM alv_display.
1293     ELSEIF flg1 EQ 'X' .
1294
1295
1296       DATA clo_jvnam1 TYPE string.
1297       DATA clo_jvnam2 TYPE string.
1298       DATA col_nam TYPE string.
1299       DATA col_nam2 TYPE string.
1300
1301
1302       ls_fieldcat-fieldname = 'RACCT'.
1303       ls_fieldcat-col_pos   = '1'.
1304       ls_fieldcat-coltext   = 'G/L account'.
1305       APPEND ls_fieldcat TO lt_fieldcat.
1306
1307       ls_fieldcat-fieldname = 'TXT50'.
1308       ls_fieldcat-col_pos   = '2'.
1309       ls_fieldcat-outputlen = '50'.
1310       ls_fieldcat-coltext   = 'G/L Description'.
1311       APPEND ls_fieldcat TO lt_fieldcat.
1312   *******************************************************    APARNA
1313       IF gv_selected_value  = 'USD & INR'.
1314         LOOP AT lt_alljv INTO DATA(ls_jvnam1).
1315           CLEAR : clo_jvnam1,clo_jvnam2.
1316           clo_jvnam1 = sy-tabix.
1317           CONCATENATE 'BAL_CLO_U' clo_jvnam1 INTO clo_jvnam1.
1318           CONCATENATE 'Closing Bal USD' ls_jvnam1-rjvnam INTO clo_jvnam2 SEPARATED BY space.
1319           ls_fieldcat-fieldname = clo_jvnam1.
1320           ls_fieldcat-col_pos   = sy-tabix + 2.
1321           ls_fieldcat-coltext   = clo_jvnam2.
1322           ls_fieldcat-outputlen = '20'.
1323           ls_fieldcat-do_sum    = abap_true.
1324   *      LS_FIELDCAT-NO_ZERO   = ABAP_TRUE.
1325           ls_fieldcat-inttype   = 'P'.
1326           ls_fieldcat-decimals  = '3'.
1327           APPEND ls_fieldcat TO lt_fieldcat.
1328         ENDLOOP.
1329         DATA(lt_fcat_tmp) = lt_fieldcat.
1330         SORT lt_fcat_tmp DESCENDING BY col_pos.
1331         TRY.
1332             DATA(lv_cat) =  lt_fcat_tmp[ 1 ]-col_pos.
1333           CATCH cx_sy_itab_line_not_found.
1334         ENDTRY.
1335
1336         LOOP AT lt_alljv INTO ls_jvnam1.
1337           CLEAR : clo_jvnam1,clo_jvnam2.
1338           clo_jvnam1 = sy-tabix.
1339           CONCATENATE 'BAL_CLO_I' clo_jvnam1 INTO clo_jvnam1.
1340           CONCATENATE 'Closing Bal INR' ls_jvnam1-rjvnam INTO clo_jvnam2 SEPARATED BY space.
1341           ls_fieldcat-fieldname = clo_jvnam1.
1342           .
1343           ls_fieldcat-col_pos = lv_cat + sy-tabix.
1344           ls_fieldcat-coltext   = clo_jvnam2.
1345           ls_fieldcat-outputlen = '20'.
1346           ls_fieldcat-do_sum    = abap_true.
1347   *      LS_FIELDCAT-NO_ZERO   = ABAP_TRUE.
1348           ls_fieldcat-inttype   = 'P'.
1349           ls_fieldcat-decimals  = '3'.
1350           APPEND ls_fieldcat TO lt_fieldcat.
1351           CLEAR  : ls_fieldcat .
1352         ENDLOOP.
1353         CLEAR  lv_cat.
1354       ELSE.
1355   *******************************************************APARNA
1356         LOOP AT lt_alljv INTO ls_jvnam1.
1357           CLEAR : clo_jvnam1,clo_jvnam2.
1358           clo_jvnam1 = sy-tabix.
1359           CONCATENATE 'BAL_CLO' clo_jvnam1 INTO clo_jvnam1.
1360           CONCATENATE 'Closing Bal' ls_jvnam1-rjvnam INTO clo_jvnam2 SEPARATED BY space.
1361           ls_fieldcat-fieldname = clo_jvnam1.
1362           ls_fieldcat-col_pos   = sy-tabix + 2.
1363           ls_fieldcat-coltext   = clo_jvnam2.
1364           ls_fieldcat-outputlen = '20'.
1365           ls_fieldcat-do_sum    = abap_true.
1366   *      LS_FIELDCAT-NO_ZERO   = ABAP_TRUE.
1367           ls_fieldcat-inttype   = 'P'.
1368           ls_fieldcat-decimals  = '3'.
1369           APPEND ls_fieldcat TO lt_fieldcat.
1370         ENDLOOP.
1371       ENDIF.
1372       CALL METHOD cl_alv_table_create=>create_dynamic_table
1373         EXPORTING
1374           it_fieldcatalog = lt_fieldcat
1375         IMPORTING
1376           ep_table        = lr_itab.
1377
1378       ASSIGN lr_itab->* TO <fs_itab>.
1379
1380       DATA lr_itab_line TYPE REF TO data.
1381       DATA lt_final5 TYPE REF TO data.
1382   *
1383       FIELD-SYMBOLS <fs_itab_line> TYPE any.
1384       FIELD-SYMBOLS <fs_itab2> TYPE STANDARD TABLE.
1385   *
1386       CREATE DATA lr_itab_line LIKE LINE OF <fs_itab>.
1387       ASSIGN lr_itab_line->* TO <fs_itab_line>.
1388
1389
1390
1391       CREATE DATA lr_itab LIKE STANDARD TABLE OF <fs_itab_line>.
1392       ASSIGN lr_itab->* TO <fs_itab2>.
1393
1394       FIELD-SYMBOLS: <fs1>,
1395                      <fs2>,
1396                      <fs3>,
1397                      <fs4>,
1398                      <fs5>.
1399       .
1400       DATA col_no TYPE i.
1401       ASSIGN COMPONENT 1 OF STRUCTURE <fs_itab_line> TO <fs1>.
1402       ASSIGN COMPONENT 2 OF STRUCTURE <fs_itab_line> TO <fs2>.
1403
1404       CLEAR ls_final3.
1405       CLEAR ls_final.
1406       SORT lt_final BY racct.
1407       break abapuser02.
1408       LOOP AT lt_final3 INTO ls_final3.
1409
1410         col_no = 3.
1411
1412         <fs1> = ls_final3-racct.
1413         <fs2> = ls_final3-txt50.
1414         IF gv_selected_value  = 'USD & INR'.
1415           LOOP AT lt_final INTO ls_final WHERE racct = ls_final3-racct.
1416             CONCATENATE 'Closing Bal USD' ls_final-rjvnam INTO col_nam SEPARATED BY space.
1417             CONCATENATE 'Closing Bal INR' ls_final-rjvnam INTO col_nam2 SEPARATED BY space.
1418             READ TABLE lt_fieldcat INTO ls_fieldcat WITH KEY coltext = col_nam.
1419             IF sy-subrc = 0.
1420               col_no = ls_fieldcat-col_pos.
1421               ASSIGN COMPONENT col_no OF STRUCTURE <fs_itab_line> TO <fs5>.
1422
1423               <fs5> = ls_final-bal_clo_u.
1424
1425               UNASSIGN <fs5>.
1426             ENDIF.
1427             READ TABLE lt_fieldcat INTO ls_fieldcat WITH KEY coltext = col_nam2.
1428             IF sy-subrc = 0.
1429               col_no = ls_fieldcat-col_pos.
1430
1431               ASSIGN COMPONENT col_no OF STRUCTURE <fs_itab_line> TO <fs5>.
1432
1433               <fs5> = ls_final-bal_clo_i.
1434
1435               UNASSIGN <fs5>.
1436             ENDIF.
1437
1438
1439           ENDLOOP.
1440         ELSE.
1441           LOOP AT lt_final INTO ls_final WHERE racct = ls_final3-racct.
1442             CONCATENATE 'Closing Bal' ls_final-rjvnam INTO col_nam SEPARATED BY space.
1443             READ TABLE lt_fieldcat INTO ls_fieldcat WITH KEY coltext = col_nam.
1444             col_no = ls_fieldcat-col_pos.
1445             ASSIGN COMPONENT col_no OF STRUCTURE <fs_itab_line> TO <fs5>.
1446
1447             <fs5> = ls_final-bal_clo.
1448
1449             UNASSIGN <fs5>.
1450           ENDLOOP.
1451         ENDIF.
1452         INSERT <fs_itab_line> INTO TABLE <fs_itab> .
1453         CLEAR <fs_itab_line>.
1454         CLEAR:col_no.
1455       ENDLOOP.
1456       UNASSIGN <fs1>.
1457       UNASSIGN <fs2>.
1458
1459       IF <fs_itab> IS NOT INITIAL.
1460         <fs_itab2> = <fs_itab> .
1461
1462         CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
1463           EXPORTING
1464             i_callback_program     = sy-cprog
1465             i_callback_top_of_page = 'TOP_OF_PAGE'
1466             is_layout_lvc          = ls_lay
1467             it_fieldcat_lvc        = lt_fieldcat
1468             i_default              = 'X'
1469             i_save                 = 'A'
1470           TABLES
1471             t_outtab               = <fs_itab>
1472           EXCEPTIONS
1473             program_error          = 1
1474             OTHERS                 = 2.
1475         IF sy-subrc <> 0.
1476   * Implement suitable error handling here
1477         ENDIF.
1478   *        DATA: lo_alv       TYPE REF TO cl_salv_table,
1479   *              lo_columns   TYPE REF TO cl_salv_columns_table,
1480   *              lo_layout    TYPE REF TO cl_salv_layout,
1481   *              lo_disp_set  TYPE REF TO cl_salv_display_settings,
1482   *              lo_column    TYPE REF TO cl_salv_column_table,
1483   *              lo_functions TYPE REF TO cl_salv_functions,
1484   *              lo_agr       TYPE REF TO cl_salv_aggregations,
1485   *              style        TYPE outputstyle.
1486   *
1487   *        DATA ls_layout_key TYPE salv_s_layout_key.
1488   *
1489   *       TRY.
1490   *           cl_salv_table=>factory(
1491   *             IMPORTING
1492   *               r_salv_table = lo_alv
1493   *             CHANGING
1494   *               t_table = <fs_itab> ).
1495   *        CATCH cx_salv_msg .
1496   *       ENDTRY.
1497   *
1498   *        LO_COLUMNS = LO_ALV->GET_COLUMNS( ).
1499   *        LO_COLUMNS->SET_OPTIMIZE( ABAP_TRUE ).
1500   *
1501   *        LOOP AT LT_FIELDCAT INTO LS_FIELDCAT.
1502   *         TRY.
1503   *          LO_COLUMN ?= LO_COLUMNS->GET_COLUMN( LS_FIELDCAT-FIELDNAME ).
1504   *          LO_COLUMN->SET_LONG_TEXT( LS_FIELDCAT-COLTEXT ).
1505   *
1506   *          CATCH cx_salv_not_found.
1507   *         ENDTRY.
1508   *        ENDLOOP.
1509   *
1510   *       lo_layout = lo_alv->get_layout( ).
1511   *       lo_layout->set_default( abap_true ).
1512   *
1513   *       ls_layout_key-report = sy-repid.
1514   *       lo_layout->set_key( ls_layout_key ).
1515   *
1516   *       lo_layout->set_save_restriction( if_salv_c_layout=>restrict_none ).
1517   *
1518   *       lo_functions = lo_alv->get_functions( ).
1519   *       lo_functions->set_all( abap_true ).
1520   *
1521   *       lo_disp_set = lo_alv->get_display_settings( ).
1522   *       lo_disp_set->set_striped_pattern( abap_true ).
1523   *
1524   *       lo_alv->display( ).
1525   *
1526       ENDIF.
1527
1528     ENDIF.
1529
1530   ENDFORM.
1531   *--------------------------------------------------------------*
1532   *FORM fcat_fill .
1533   FORM fcat_fill .
1534   *--------------------------------------------------------------*
1535   ******************************************Added on 01.11.2022 by hrishi n*****************************
1536     DATA : h_opbal TYPE string,
1537            h_clbal TYPE string,
1538            h_crbal TYPE string,
1539            h_dbbal TYPE string.
1540
1541     READ TABLE lt_alljv INTO DATA(ls_jvnam) INDEX 1.
1542     CLEAR : h_opbal, h_clbal, h_crbal, h_dbbal.
1543     CONCATENATE : 'Opening Balance (' ls_jvnam-rjvnam ')' INTO h_opbal SEPARATED BY space,
1544                   'Closing Balance (' ls_jvnam-rjvnam ')' INTO h_clbal SEPARATED BY space,
1545                   'Credit Balance ('  ls_jvnam-rjvnam ')' INTO h_crbal SEPARATED BY space,
1546                   'Debit Balance ('   ls_jvnam-rjvnam ')' INTO h_dbbal SEPARATED BY space.
1547
1548     PERFORM alv_fcat USING :   'RACCT'      'G/L account'       ' ' ,
1549                                'TXT50'      'G/L Description'   ' ' ,
1550                                'BAL_OPN1'    h_opbal   'X' ,
1551                                'BAL_DEB1'    h_dbbal   'X' ,
1552                                'BAL_CRE1'    h_crbal   'X' ,
1553                                'BAL_CLO1'    h_clbal   'X' .
1554
1555     IF col_count GE 2.
1556       CLEAR : h_opbal, h_clbal, h_crbal, h_dbbal, ls_jvnam.
1557       READ TABLE lt_alljv INTO ls_jvnam INDEX 2.
1558       CONCATENATE : 'Opening Balance (' ls_jvnam-rjvnam ')' INTO h_opbal SEPARATED BY space,
1559                     'Closing Balance (' ls_jvnam-rjvnam ')' INTO h_clbal SEPARATED BY space,
1560                     'Credit Balance ('  ls_jvnam-rjvnam ')' INTO h_crbal SEPARATED BY space,
1561                     'Debit Balance ('   ls_jvnam-rjvnam ')' INTO h_dbbal SEPARATED BY space.
1562
1563       PERFORM alv_fcat USING :  'BAL_OPN2'    h_opbal   'X' ,
1564                                 'BAL_DEB2'    h_dbbal   'X' ,
1565                                 'BAL_CRE2'    h_crbal   'X' ,
1566                                 'BAL_CLO2'    h_clbal   'X' .
1567     ENDIF.
1568
1569     IF col_count GE 3.
1570       CLEAR : h_opbal, h_clbal, h_crbal, h_dbbal, ls_jvnam.
1571       READ TABLE lt_alljv INTO ls_jvnam INDEX 3.
1572       CONCATENATE : 'Opening Balance (' ls_jvnam-rjvnam ')' INTO h_opbal SEPARATED BY space,
1573                     'Closing Balance (' ls_jvnam-rjvnam ')' INTO h_clbal SEPARATED BY space,
1574                     'Credit Balance ('  ls_jvnam-rjvnam ')' INTO h_crbal SEPARATED BY space,
1575                     'Debit Balance ('   ls_jvnam-rjvnam ')' INTO h_dbbal SEPARATED BY space.
1576
1577       PERFORM alv_fcat USING :   'BAL_OPN3'   h_opbal   'X' ,
1578                                  'BAL_DEB3'   h_dbbal   'X' ,
1579                                  'BAL_CRE3'   h_crbal   'X' ,
1580                                  'BAL_CLO3'   h_clbal   'X' .
1581     ENDIF.
1582
1583     IF col_count GE 4.
1584       CLEAR : h_opbal, h_clbal, h_crbal, h_dbbal, ls_jvnam.
1585       READ TABLE lt_alljv INTO ls_jvnam INDEX 4.
1586       CONCATENATE : 'Opening Balance (' ls_jvnam-rjvnam ')' INTO h_opbal SEPARATED BY space,
1587                     'Closing Balance (' ls_jvnam-rjvnam ')' INTO h_clbal SEPARATED BY space,
1588                     'Credit Balance ('  ls_jvnam-rjvnam ')' INTO h_crbal SEPARATED BY space,
1589                     'Debit Balance ('   ls_jvnam-rjvnam ')' INTO h_dbbal SEPARATED BY space.
1590
1591       PERFORM alv_fcat USING : 'BAL_OPN4'    h_opbal   'X' ,
1592                                'BAL_DEB4'    h_dbbal   'X' ,
1593                                'BAL_CRE4'    h_crbal   'X' ,
1594                                'BAL_CLO4'    h_clbal   'X' .
1595     ENDIF.
1596
1597     IF col_count GE 5.
1598       CLEAR : h_opbal, h_clbal, h_crbal, h_dbbal, ls_jvnam.
1599       READ TABLE lt_alljv INTO ls_jvnam INDEX 5.
1600       CONCATENATE : 'Opening Balance (' ls_jvnam-rjvnam ')' INTO h_opbal SEPARATED BY space,
1601                     'Closing Balance (' ls_jvnam-rjvnam ')' INTO h_clbal SEPARATED BY space,
1602                     'Credit Balance ('  ls_jvnam-rjvnam ')' INTO h_crbal SEPARATED BY space,
1603                     'Debit Balance ('   ls_jvnam-rjvnam ')' INTO h_dbbal SEPARATED BY space.
1604
1605       PERFORM alv_fcat USING :   'BAL_OPN5'    h_opbal   'X' ,
1606                                  'BAL_DEB5'    h_dbbal   'X' ,
1607                                  'BAL_CRE5'    h_crbal   'X' ,
1608                                  'BAL_CLO5'    h_clbal   'X' .
1609     ENDIF.
1610
1611     IF col_count GE 6.
1612       CLEAR : h_opbal, h_clbal, h_crbal, h_dbbal, ls_jvnam.
1613       READ TABLE lt_alljv INTO ls_jvnam INDEX 6.
1614       CONCATENATE : 'Opening Balance (' ls_jvnam-rjvnam ')' INTO h_opbal SEPARATED BY space,
1615                     'Closing Balance (' ls_jvnam-rjvnam ')' INTO h_clbal SEPARATED BY space,
1616                     'Credit Balance ('  ls_jvnam-rjvnam ')' INTO h_crbal SEPARATED BY space,
1617                     'Debit Balance ('   ls_jvnam-rjvnam ')' INTO h_dbbal SEPARATED BY space.
1618
1619       PERFORM alv_fcat USING :   'BAL_OPN6'    h_opbal   'X' ,
1620                                  'BAL_DEB6'    h_dbbal   'X' ,
1621                                  'BAL_CRE6'    h_crbal   'X' ,
1622                                  'BAL_CLO6'    h_clbal   'X' .
1623     ENDIF.
1624
1625     IF col_count GE 7.
1626       CLEAR : h_opbal, h_clbal, h_crbal, h_dbbal, ls_jvnam.
1627       READ TABLE lt_alljv INTO ls_jvnam INDEX 7.
1628       CONCATENATE : 'Opening Balance (' ls_jvnam-rjvnam ')' INTO h_opbal SEPARATED BY space,
1629                     'Closing Balance (' ls_jvnam-rjvnam ')' INTO h_clbal SEPARATED BY space,
1630                     'Credit Balance ('  ls_jvnam-rjvnam ')' INTO h_crbal SEPARATED BY space,
1631                     'Debit Balance ('   ls_jvnam-rjvnam ')' INTO h_dbbal SEPARATED BY space.
1632
1633       PERFORM alv_fcat USING :   'BAL_OPN7'    h_opbal   'X' ,
1634                                  'BAL_DEB7'    h_dbbal   'X' ,
1635                                  'BAL_CRE7'    h_crbal   'X' ,
1636                                  'BAL_CLO7'    h_clbal   'X' .
1637     ENDIF.
1638
1639     IF col_count GE 8.
1640       CLEAR : h_opbal, h_clbal, h_crbal, h_dbbal, ls_jvnam.
1641       READ TABLE lt_alljv INTO ls_jvnam INDEX 8.
1642       CONCATENATE : 'Opening Balance (' ls_jvnam-rjvnam ')' INTO h_opbal SEPARATED BY space,
1643                     'Closing Balance (' ls_jvnam-rjvnam ')' INTO h_clbal SEPARATED BY space,
1644                     'Credit Balance ('  ls_jvnam-rjvnam ')' INTO h_crbal SEPARATED BY space,
1645                     'Debit Balance ('   ls_jvnam-rjvnam ')' INTO h_dbbal SEPARATED BY space.
1646
1647       PERFORM alv_fcat USING :   'BAL_OPN8'    h_opbal   'X' ,
1648                                  'BAL_DEB8'    h_dbbal   'X' ,
1649                                  'BAL_CRE8'    h_crbal   'X' ,
1650                                  'BAL_CLO8'    h_clbal   'X' .
1651     ENDIF.
1652
1653     IF col_count GE 9.
1654       CLEAR : h_opbal, h_clbal, h_crbal, h_dbbal, ls_jvnam.
1655       READ TABLE lt_alljv INTO ls_jvnam INDEX 9.
1656       CONCATENATE : 'Opening Balance (' ls_jvnam-rjvnam ')' INTO h_opbal SEPARATED BY space,
1657                     'Closing Balance (' ls_jvnam-rjvnam ')' INTO h_clbal SEPARATED BY space,
1658                     'Credit Balance ('  ls_jvnam-rjvnam ')' INTO h_crbal SEPARATED BY space,
1659                     'Debit Balance ('   ls_jvnam-rjvnam ')' INTO h_dbbal SEPARATED BY space.
1660
1661       PERFORM alv_fcat USING :   'BAL_OPN9'    h_opbal   'X' ,
1662                                  'BAL_DEB9'    h_dbbal   'X' ,
1663                                  'BAL_CRE9'    h_crbal   'X' ,
1664                                  'BAL_CLO9'    h_clbal   'X' .
1665     ENDIF.
1666
1667     IF col_count GE 10.
1668       CLEAR : h_opbal, h_clbal, h_crbal, h_dbbal, ls_jvnam.
1669       READ TABLE lt_alljv INTO ls_jvnam INDEX 10.
1670       CONCATENATE : 'Opening Balance (' ls_jvnam-rjvnam ')' INTO h_opbal SEPARATED BY space,
1671                     'Closing Balance (' ls_jvnam-rjvnam ')' INTO h_clbal SEPARATED BY space,
1672                     'Credit Balance ('  ls_jvnam-rjvnam ')' INTO h_crbal SEPARATED BY space,
1673                     'Debit Balance ('   ls_jvnam-rjvnam ')' INTO h_dbbal SEPARATED BY space.
1674
1675       PERFORM alv_fcat USING :   'BAL_OPN10'    h_opbal   'X' ,
1676                                  'BAL_DEB10'    h_dbbal   'X' ,
1677                                  'BAL_CRE10'    h_crbal   'X' ,
1678                                  'BAL_CLO10'    h_clbal   'X' .
1679     ENDIF.
1680
1681   ***************************************End of addn by hrishi n on 01.11.2022**************************************
1682   ENDFORM.
1683   *--------------------------------------------------------------*
1684   *FORM  alv_fcat  .
1685   *--------------------------------------------------------------*
1686   FORM alv_fcat  USING    VALUE(p_011)
1687                           VALUE(p_012)
1688                           VALUE(p_013).
1689
1690     wa_fcat-fieldname   = p_011.
1691     wa_fcat-seltext_l   = p_012.
1692     IF wa_fcat-fieldname EQ 'TXT50' OR wa_fcat-fieldname EQ 'RACCT'.
1693     ELSE.
1694       wa_fcat-do_sum      = 'X'.
1695     ENDIF.
1696
1697     APPEND wa_fcat TO lt_fcat.
1698     CLEAR wa_fcat.
1699   ENDFORM.
1700   *--------------------------------------------------------------*
1701   *FORM alv_display .
1702   *--------------------------------------------------------------*
1703   FORM alv_display .
1704     wa_layout-info_fieldname     = 'LINE_COLOR'.
1705     wa_layout-colwidth_optimize  = 'X'.
1706     wa_layout-zebra              = 'X'.
1707
1708     CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
1709       EXPORTING
1710         i_callback_program     = sy-cprog
1711         i_callback_top_of_page = 'TOP_OF_PAGE'
1712         is_layout              = wa_layout
1713         it_fieldcat            = lt_fcat
1714         i_default              = 'X'
1715         i_save                 = 'A'
1716       TABLES
1717         t_outtab               = lt_final4
1718       EXCEPTIONS
1719         program_error          = 1
1720         OTHERS                 = 2.
1721     IF sy-subrc <> 0.
1722   * Implement suitable error handling here
1723     ENDIF.
1724
1725   ENDFORM.
1726   *--------------------------------------------------------------*
1727   *FORM top_of_page.
1728   *--------------------------------------------------------------*
1729   FORM top_of_page.
1730     PERFORM ex_change.
1731     REFRESH int_header[].
1732     fs_header-typ = 'H'.
1733     fs_header-info = 'Joint Venture Trial Balance'.
1734     APPEND fs_header TO int_header.
1735     CLEAR fs_header.
1736
1737     fs_header-typ = 'S'.
1738     fs_header-info =  p_year .
1739     APPEND fs_header TO int_header.
1740     CLEAR fs_header.
1741
1742     fs_header-typ = 'S'.
1743     fs_header-info =  p_bukrs .
1744     APPEND fs_header TO int_header.
1745     CLEAR fs_header.
1746
1747     fs_header-typ = 'S'.
1748     fs_header-info = gwa_list-text .
1749     APPEND fs_header TO int_header.
1750     CLEAR fs_header.
1751
1752     fs_header-typ = 'S'.
1753     CONCATENATE  s_period-low+1(2) ' To ' space s_period-high+1(2) INTO fs_header-info SEPARATED BY space.
1754     APPEND fs_header TO int_header.
1755     CLEAR fs_header.
1756
1757     fs_header-typ = 'S'.
1758     fs_header-info = gv_ukurs .
1759     APPEND fs_header TO int_header.
1760     CLEAR fs_header.
1761
1762     fs_header-typ = 'S'.
1763     fs_header-info = lv_ukurs .
1764     APPEND fs_header TO int_header.
1765     CLEAR fs_header.
1766
1767     CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
1768       EXPORTING
1769         it_list_commentary = int_header.
1770
1771   ENDFORM.
1772   *--------------------------------------------------------------*
1773   *FORM after_set_data.
1774   *--------------------------------------------------------------*
1775   FORM after_set_data.
1776
1777     CLEAR : ls_final.
1778     LOOP AT lt_final INTO ls_final.
1779       IF ls_final-racct GE 500000 AND ls_final-racct LE 599999.
1780         APPEND ls_final TO lt_bfinal.
1781         DELETE TABLE lt_final FROM ls_final.
1782         CLEAR ls_final.
1783       ENDIF.
1784     ENDLOOP.
1785
1786     SORT lt_bfinal BY racct ASCENDING.
1787
1788   ENDFORM.
1789   *&---------------------------------------------------------------------*
1790   *&      Form  PROCESSGUIDE
1791   *&---------------------------------------------------------------------*
1792   *       text
1793   *----------------------------------------------------------------------*
1794   *  -->  p1        text
1795   *  <--  p2        text
1796   *----------------------------------------------------------------------*
1797   FORM processguide .
1798
1799     DATA : la_gos_dis  TYPE sibflporb.
1800
1801   *variable to attachment
1802     DATA: lv_attano TYPE string.
1803
1804
1805
1806
1807     IF sy-uname CA sy-abcde.
1808
1809       DATA lv_ip_mode TYPE c.
1810       CLEAR : lv_attano,la_gos_dis.
1811
1812       la_gos_dis-objtype = 'ZGOS3'.
1813       lv_attano = 'ZJVTBPROCESSGUIDE'.
1814       la_gos_dis-instid  = lv_attano.
1815       la_gos_dis-catid  = 'BO'.
1816       lv_ip_mode = 'C'. "create/change/display/delete
1817
1818       CALL FUNCTION 'GOS_ATTACHMENT_LIST_POPUP'
1819         EXPORTING
1820           is_object      = la_gos_dis
1821           ip_attachments = 'X'
1822           ip_mode        = lv_ip_mode.
1823
1824     ELSE.
1825
1826       MESSAGE 'To update attachment list contact SAP core team. Continue to view process guide.' TYPE 'S'.
1827
1828       CLEAR : lv_attano,la_gos_dis.
1829
1830       la_gos_dis-objtype = 'ZGOS3'.
1831       lv_attano = 'ZJVTBPROCESSGUIDE'.
1832       la_gos_dis-instid  = lv_attano.
1833       la_gos_dis-catid  = 'BO'.
1834
1835       CALL FUNCTION 'GOS_ATTACHMENT_LIST_POPUP'
1836         EXPORTING
1837           is_object = la_gos_dis.
1838
1839     ENDIF.
1840
1841   ENDFORM.
1842
1843   *&---------------------------------------------------------------------*
1844   *&      Form  EX_CHANGE
1845   *&---------------------------------------------------------------------*
1846   *       text
1847   *----------------------------------------------------------------------*
1848   *  -->  p1        text
1849   *  <--  p2        text
1850   *----------------------------------------------------------------------*
1851   FORM ex_change .
1852
1853     DATA: t_year  TYPE gjahr.
1854     DATA  gv_ukurs2 TYPE tcurr-ukurs.
1855     DATA lv_month TYPE i.
1856     DATA lv_days(2) TYPE c.
1857     DATA lv_month1 TYPE rpmax.
1858     DATA lv_month2 TYPE rpmax.
1859     DATA lv_budat TYPE sy-datum.
1860     DATA lv_budat2 TYPE sy-datum.
1861     DATA lv_budat3 TYPE sy-datum.
1862     CLEAR : gv_ukurs2 , lv_month1 , lv_month2,  lv_ukurs , lv_budat3.
1863
1864
1865   *********************************************
1866     lv_month1+1(2) = s_period-high+1(2) .
1867     lv_month2+1(2) = s_period-low+1(2) .
1868
1869     "soc by rohit on 01.05.2026.
1870
1871     IF lv_month1 GT 9.
1872
1873       t_year =  p_year + 1.
1874
1875     ELSE .
1876       t_year = p_year.
1877
1878     ENDIF.
1879
1880     "eoc by rohit on 01.05.2026.
1881
1882
1883
1884     IF  lv_month1+1(2)      = '01'.
1885       lv_month1+1(2) = '04'.
1886     ELSEIF   lv_month1+1(2)   = '02'.
1887       lv_month1+1(2) = '05'.
1888     ELSEIF  lv_month1+1(2) = '03'.
1889       lv_month1+1(2) = '06'.
1890     ELSEIF   lv_month1+1(2) = '04'.
1891       lv_month1+1(2) = '07'.
1892     ELSEIF  lv_month1+1(2) = '05'.
1893       lv_month1+1(2) = '08'.
1894     ELSEIF lv_month1+1(2) = '06'.
1895       lv_month1+1(2) = '09'.
1896     ELSEIF  lv_month1+1(2) = '07'.
1897       lv_month1+1(2) = '10'.
1898     ELSEIF  lv_month1+1(2) = '08'.
1899       lv_month1+1(2) = '11'.
1900     ELSEIF  lv_month1+1(2) = '09'.
1901       lv_month1+1(2) = '12'.
1902     ELSEIF  lv_month1+1(2) = '10'.
1903       lv_month1+1(2) = '01'.
1904     ELSEIF  lv_month1+1(2)  = '11'.
1905       lv_month1+1(2) = '02'.
1906     ELSEIF  lv_month1+1(2) = '12'.
1907       lv_month1+1(2) = '03'.
1908     ENDIF.
1909
1910   **************************************
1911     IF  lv_month2+1(2)      = '01'.
1912       lv_month2+1(2) = '04'.
1913     ELSEIF   lv_month2+1(2)   = '02'.
1914       lv_month2+1(2) = '05'.
1915     ELSEIF  lv_month2+1(2) = '03'.
1916       lv_month2+1(2) = '06'.
1917     ELSEIF   lv_month2+1(2) = '04'.
1918       lv_month2+1(2) = '07'.
1919     ELSEIF  lv_month2+1(2) = '05'.
1920       lv_month2+1(2) = '08'.
1921     ELSEIF lv_month2+1(2) = '06'.
1922       lv_month2+1(2) = '09'.
1923     ELSEIF  lv_month2+1(2) = '07'.
1924       lv_month2+1(2) = '10'.
1925     ELSEIF  lv_month2+1(2) = '08'.
1926       lv_month2+1(2) = '11'.
1927     ELSEIF  lv_month2+1(2) = '09'.
1928       lv_month2+1(2) = '12'.
1929     ELSEIF  lv_month2+1(2) = '10'.
1930       lv_month2+1(2) = '01'.
1931     ELSEIF  lv_month2+1(2)  = '11'.
1932       lv_month2+1(2) = '02'.
1933     ELSEIF  lv_month2+1(2) = '12'.
1934       lv_month2+1(2) = '03'.
1935     ENDIF.
1936   *****************************************************************
1937     IF s_period-high IS NOT INITIAL.
1938
1939       CLEAR lv_days.
1940       IF  lv_month1+1(2)  = '02'.
1941         lv_days = '28'.
1942       ELSEIF (  lv_month1+1(2)  = '04' OR  lv_month1+1(2)  = '06' OR  lv_month1+1(2)  = '09' OR   lv_month1+1(2)  = '11' ).
1943         lv_days = '30'.
1944       ELSE.
1945         lv_days = '31'.
1946       ENDIF.
1947
1948       IF p_year NE t_year.   " SOC BY ROHIT ON 01.05.2026
1949         CONCATENATE   lv_days lv_month1+1(2) t_year  INTO lv_budat.
1950         CONCATENATE   '01' lv_month1+1(2) t_year   INTO lv_budat3.
1951
1952       ELSE .
1953         CONCATENATE   lv_days lv_month1+1(2) p_year  INTO lv_budat.
1954         CONCATENATE   '01' lv_month1+1(2) p_year   INTO lv_budat3.
1955
1956       ENDIF.    " EOC BY ROHIT ON 01.05.2026
1957
1958       CONDENSE lv_budat.
1959       CALL FUNCTION 'CONVERSION_EXIT_INVDT_INPUT'
1960         EXPORTING
1961           input  = lv_budat
1962         IMPORTING
1963           output = lv_budat.
1964
1965       CALL FUNCTION 'CONVERSION_EXIT_INVDT_INPUT'
1966         EXPORTING
1967           input  = lv_budat3
1968         IMPORTING
1969           output = lv_budat3.
1970
1971   *    SELECT SINGLE ukurs
1972   *          FROM tcurr
1973   *          INTO gv_ukurs2
1974   *         WHERE kurst = 'CLT'
1975   *           AND fcurr = 'USD'
1976   *           AND tcurr = 'INR'
1977   *           AND gdatu BETWEEN lv_budat AND lv_budat3.
1978       SELECT ukurs
1979             FROM tcurr UP TO 1 ROWS
1980             INTO gv_ukurs2
1981            WHERE kurst = 'CLT'
1982              AND fcurr = 'USD'
1983              AND tcurr = 'INR'
1984              AND gdatu BETWEEN lv_budat AND lv_budat3 ORDER BY PRIMARY KEY. ENDSELECT.
1985       gv_ukurs = gv_ukurs2.
1986
1987     ELSE.
1988       CLEAR lv_days.
1989       IF s_period-low+1(2)  = '02'.
1990         lv_days = '28'.
1991       ELSEIF ( s_period-low+1(2)  = '04' OR s_period-low+1(2)  = '06' OR s_period-low+1(2)  = '09' OR s_period-low+1(2)  = '11' ).
1992         lv_days = '30'.
1993       ELSE.
1994         lv_days = '31'.
1995       ENDIF.
1996
1997
1998       CONCATENATE lv_days lv_month2+1(2) p_year    INTO lv_budat.
1999
2000       CONDENSE lv_budat.
2001       CALL FUNCTION 'CONVERSION_EXIT_INVDT_INPUT'
2002         EXPORTING
2003           input  = lv_budat
2004         IMPORTING
2005           output = lv_budat.
2006   *
2007
2008       SELECT SINGLE ukurs
2009             FROM tcurr
2010             INTO gv_ukurs2
2011            WHERE kurst = 'CLT'
2012              AND fcurr = 'USD'
2013              AND tcurr = 'INR'
2014              AND gdatu = lv_budat.
2015
2016     ENDIF.
2017     gv_ukurs = gv_ukurs2.
2018   *************************************************************************************** avarage rate
2019
2020   *  DO.
2021
2022     CLEAR :lv_days ,  gv_ukurs2 .
2023
2024     IF   lv_month2+1(2)  = '02'.
2025       lv_days = '28'.
2026     ELSEIF (   lv_month2+1(2)  = '04' OR   lv_month2+1(2)  = '06' OR  lv_month2+1(2)  = '09' OR   lv_month2+1(2) = '11' ).
2027       lv_days = '30'.
2028     ELSE.
2029       lv_days = '31'.
2030     ENDIF.
2031
2032     CONCATENATE  '01' lv_month2+1(2) p_year  INTO lv_budat2.
2033
2034     CONDENSE lv_budat2.
2035     CALL FUNCTION 'CONVERSION_EXIT_INVDT_INPUT'
2036       EXPORTING
2037         input  = lv_budat2
2038       IMPORTING
2039         output = lv_budat2.
2040
2041     SELECT kurst
2042           fcurr
2043           tcurr
2044           gdatu
2045            ukurs
2046           FROM tcurr
2047           INTO TABLE it_curr
2048          WHERE kurst = 'NTA'
2049            AND fcurr = 'USD'
2050            AND tcurr = 'INR'
2051            AND gdatu BETWEEN  lv_budat AND lv_budat2.
2052
2053     LOOP AT it_curr INTO DATA(wa_curr).
2054       lv_ukurs = lv_ukurs + wa_curr-ukurs.
2055     ENDLOOP.
2056
2057     lv_ukurs =  lv_ukurs /  s_period-high+1(2).
2058
2059   ENDFORM.
*--- End of ZFI_JV_TB - 2059 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CABAP                                   Level 1    Page 2
Object           ZFI_JV_TB                                 Lines 360
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:18
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
Generated incl.  %_CICON                                   Level 1    Page 3
Object           ZFI_JV_TB                                 Lines 1246
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:18
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
Generated incl.  %_CSLIS                                   Level 1    Page 4
Object           ZFI_JV_TB                                 Lines 543
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:18
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
Generated incl.  %_CVRM                                    Level 1    Page 5
Object           ZFI_JV_TB                                 Lines 30
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:18
----------------------------------------------------------------------------------------------------
1      TYPE-POOL VRM .
2
3      TYPES:
4      *-- Single Value in Value Set
5             BEGIN OF VRM_VALUE,
6               KEY(40) TYPE C,
7               TEXT(80) TYPE C,
8             END OF VRM_VALUE,
9      *-- Table of Values
10            VRM_VALUES TYPE VRM_VALUE OCCURS 0,
11     *-- Id of Value Set
12            VRM_ID TYPE VRM_VALUE-TEXT,
13     *-- table of Ids of Value Set
14            VRM_IDS TYPE VRM_ID OCCURS 0,
15     *-- QueueRow
16            BEGIN OF VRM_QUEUEROW,
17              TAG,
18              VALUE TYPE VRM_VALUE,
19            END   OF VRM_QUEUEROW,
20     *-- Queue
21            VRM_QUEUE TYPE VRM_QUEUEROW OCCURS 0.
22
23     CONSTANTS:
24       VRM_TYPE(20)                          VALUE 'application',
25       VRM_SUBTYPE(20)                       VALUE 'x-sapvaluesets',
26       VRM_QUEUE_TAG_HEADER                  VALUE 'T',
27       VRM_QUEUE_TAG_SUBHEADER               VALUE 'X',
28       VRM_QUEUE_TAG_ENTRY                   VALUE ' ',
29       VRM_QUEUE_KEY_TYPE TYPE VRM_VALUE-KEY VALUE 'TYPE',
30       VRM_QUEUE_KEY_NAME TYPE VRM_VALUE-KEY VALUE 'NAME'.
*--- End of %_CVRM - 30 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  <REPINI>                                  Level 1    Page 6
Object           ZFI_JV_TB                                 Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:18
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
Generated incl.  <SYSINI>                                  Level 1    Page 7
Object           ZFI_JV_TB                                 Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:18
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
Generated incl.  <SYSSEL>                                  Level 1    Page 8
Object           ZFI_JV_TB                                 Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:18
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
Generated incl.  >ICON<                                    Level 1    Page 9
Object           ZFI_JV_TB                                 Lines 24
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:18
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
Generated incl.  DB__SSEL                                  Level 1    Page 10
Object           ZFI_JV_TB                                 Lines 1
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:18
----------------------------------------------------------------------------------------------------
1      * INCLUDE DB__SSEL
*--- End of DB__SSEL - 1 lines ---
