----------------------------------------------------------------------------------------------------
Main program     ZPM_POT_WATR_LIST_NEW                     Level 0    Page 1
Object           ZPM_POT_WATR_LIST_NEW                     Lines 1518
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:27
----------------------------------------------------------------------------------------------------
1      REPORT zpm_ambient_list .
2
3      ***********************************************************************
4      * Program    :  ZPM_AMBIENT_LIST                                       *
5      *                                                                     *
6      *                                                                     *
7      * Title      :  Ambient Air quality Report                            *
8      *                                                                     *
9      * FS No.     :  FS-HSE-AIR-001                                        *
10     *                                                                     *
11     * Author     :  S.Rama                          Date :  07.06.2005    *
12     *                                                                     *
13     * Login Id   :  CAB_RAMA                                              *
14     *                                                                     *
15     * Description:  For printing ambient air reports                      *
16     *                                                                     *
17     * Tran. Code :  ZPMAIRREP                                             *
18     *                                                                     *
19     ***********************************************************************
20
21     * CHANGE HISTORY                                                      *
22     *                                                                     *
23     * Mod Date    Changed by    Description                 Chng ID       *
24
25     ***********************************************************************
26     INCLUDE zpm_pot_watr_list_new_top.
27
28
29     SELECTION-SCREEN BEGIN OF BLOCK emd WITH FRAME TITLE text-001.
30     ***CODE ADDED BY CAB_AMITMOZA ON 25.09.2012 TO INCLUDE F4 ELEMENT FOR S_WERKS*******
31     SELECT-OPTIONS:   s_werks FOR zhseair_h-werks MEMORY ID wrk NO INTERVALS NO-EXTENSION DEFAULT '90R1',
32     *******CODE END BY CAB_AMITMOZA*************
33     *                  s_tplnr FOR zhseair_h-tplnr ,
34                       s_bunit FOR zhseair_h-bunit,
35                       s_proj FOR zhseair_h-porj,
36     *       s_tplnr FOR zhseair_h-tplnr MATCHCODE OBJECT zhse_eff_ep,
37     s_date  FOR zhseair_h-dpr_dt.
38
39     SELECTION-SCREEN END OF BLOCK emd.
40     *---------------------------------------------------------------------*
41     *      END OF  INPUT   SELECTION SCREEN                               *
42     *---------------------------------------------------------------------*
43
44     *AT SELECTION-SCREEN .
45     *  PERFORM check_data .
46
47     *AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_werks-low.
48     *  PERFORM help_werks .
49     *
50     *AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_werks-high.
51     *  PERFORM help_werks .
52
53     *AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_tplnr-low.
54     *  PERFORM help_tplnr .
55
56     *AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_tplnr-high.
57     *  PERFORM help_tplnr .
58
59     AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_bunit-low.
60       PERFORM help_p_bunit  .
61
62     AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_bunit-high.
63       PERFORM help_p_bunit_high  .
64
65     AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_proj-low.
66       PERFORM help_s_proj .
67
68     AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_proj-high.
69       PERFORM help_s_proj_hig .
70
71     INITIALIZATION.
72       g_repid = sy-repid.
73
74     START-OF-SELECTION.
75       PERFORM fetch_inst_details.
76       PERFORM call_alv.
77
78     END-OF-SELECTION.
79
80     *&---------------------------------------------------------------------*
81     *&      Form  fetch_inst_details
82     *&---------------------------------------------------------------------*
83     *&  FETCH DATA FROM ZHSEAIR                                            *
84     *----------------------------------------------------------------------*
85     FORM fetch_inst_details.
86       DATA: ls_final TYPE ty_final.
87       REFRESH : ist_zhseair.
88       CLEAR   : wa_zhseair.
89
90       SELECT * FROM zhseair_h INTO CORRESPONDING FIELDS OF  TABLE
91       ist_zhseair
92       WHERE werks IN s_werks
93     *  AND tplnr IN s_tplnr
94        AND bunit IN s_bunit
95        AND porj IN s_proj
96       AND dpr_dt IN s_date
97       AND znpi  EQ 'WAT'.
98
99       IF sy-subrc <> 0.
100        PERFORM callerr USING text-003.
101        STOP.
102      ELSE.
103
104        SELECT * FROM zohse_water_d
105        INTO CORRESPONDING FIELDS OF TABLE ist_zhseair_d
106        FOR ALL ENTRIES IN ist_zhseair
107        WHERE docno = ist_zhseair-docno.
108
109
110        LOOP AT ist_zhseair INTO wa_zhseair.
111
112          CLEAR : name1, l_pltxt.
113          SELECT SINGLE name1 INTO name1 FROM t001w
114          WHERE werks = wa_zhseair-werks.
115          CONDENSE name1.
116          wa_zhseair-name1 = name1.
117    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
118    *      SELECT SINGLE pltxt INTO l_pltxt FROM iflotx
119    *      WHERE tplnr = wa_zhseair-tplnr.
120     SELECT PLTXT FROM IFLOTX   UP TO 1 ROWS INTO L_PLTXT WHERE TPLNR =
121    WA_ZHSEAIR-TPLNR  ORDER BY  TPLNR SPRAS .   ENDSELECT.
122    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
123          wa_zhseair-pltxt = l_pltxt.
124          wa_zhseair-bunit = wa_zhseair-bunit.
125          wa_zhseair-porj = wa_zhseair-porj.
126          MODIFY ist_zhseair FROM wa_zhseair TRANSPORTING name1 pltxt.
127
128        ENDLOOP.
129      ENDIF.
130      SORT ist_zhseair BY dpr_dt.
131
132      LOOP AT ist_zhseair INTO wa_zhseair.
133        CLEAR: ls_final.
134    *    AT NEW porj.
135    *     Functional Location: Short Texts
136        DATA : lv_country TYPE tplnr,
137               lv_lmt     TYPE zohse_nse_lmt-max_limit.
138        CLEAR : lv_country,lv_lmt.
139    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
140    *    SELECT SINGLE country FROM zohse_eff_ep
141    *      INTO lv_country
142    *      WHERE
143    *      bunit EQ wa_zhseair-bunit
144    *      AND proj EQ wa_zhseair-porj.
145     SELECT COUNTRY FROM ZOHSE_EFF_EP   UP TO 1 ROWS INTO LV_COUNTRY WHERE
146    BUNIT EQ WA_ZHSEAIR-BUNIT AND PROJ EQ WA_ZHSEAIR-PORJ  ORDER BY  WERKS
147    BUNIT COUNTRY PROJ RIG FROM_DAT .   ENDSELECT.
148    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
149        IF sy-subrc EQ 0.
150    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
151    *      SELECT SINGLE max_limit FROM
152    *        zohse_wtr_lmt
153    *        INTO lv_lmt
154    *        WHERE country EQ lv_country.
155     SELECT MAX_LIMIT FROM ZOHSE_WTR_LMT   UP TO 1 ROWS INTO LV_LMT WHERE
156    COUNTRY EQ LV_COUNTRY  ORDER BY  POTABLE_WATR .   ENDSELECT.
157    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
158
159          IF sy-subrc EQ 0.
160            ls_final-max_limit = lv_lmt.
161          ENDIF.
162
163        ENDIF .
164        SELECT SINGLE pltxt FROM iflotx INTO ls_final-porj_d
165                    WHERE tplnr = wa_zhseair-porj
166                    AND spras = sy-langu.
167    *    ENDAT.
168
169    *    AT NEW bunit.
170        SELECT SINGLE pltxt FROM iflotx INTO ls_final-bunit_d
171                    WHERE tplnr = wa_zhseair-bunit
172                    AND spras = sy-langu.
173    *    ENDAT.
174
175        MOVE-CORRESPONDING wa_zhseair TO ls_final.
176        LOOP AT ist_zhseair_d INTO wa_zhseair_d WHERE docno = wa_zhseair-docno.
177
178
179
180
181          ls_final-color     = wa_zhseair_d-color.
182          ls_final-odor      = wa_zhseair_d-odor.
183          ls_final-taste     = wa_zhseair_d-taste.
184          ls_final-turbid    = wa_zhseair_d-turbid.
185          ls_final-ph        = wa_zhseair_d-ph.
186          ls_final-dis_solid = wa_zhseair_d-dis_solid.
187          ls_final-fe        = wa_zhseair_d-fe.
188          ls_final-hard      = wa_zhseair_d-hard.
189          ls_final-resi_cl   = wa_zhseair_d-resi_cl.
190          ls_final-so4       = wa_zhseair_d-so4.
191          ls_final-flori     = wa_zhseair_d-flori.
192          ls_final-coli      = wa_zhseair_d-coli.
193          ls_final-samp_date = wa_zhseair-dpr_dt.
194          ls_final-ecoli     = wa_zhseair_d-ecoli.
195          ls_final-next_due  = wa_zhseair_d-due_date.
196          ls_final-remark    = wa_zhseair_d-remark.
197
198          APPEND ls_final TO gt_final.
199
200          CLEAR: ls_final-color,
201                 ls_final-odor,
202                 ls_final-taste,
203                 ls_final-turbid,
204                 ls_final-ph,
205                 ls_final-dis_solid,
206                 ls_final-fe,
207                 ls_final-hard,
208                 ls_final-resi_cl,
209                 ls_final-so4,
210                 ls_final-flori,
211                 ls_final-coli,
212                 ls_final-ecoli,
213                 ls_final-remark.
214        ENDLOOP.
215      ENDLOOP.
216    ENDFORM.                    " fetch_inst_details
217
218    *&---------------------------------------------------------------------*
219    *&      Form  callerr
220    *&---------------------------------------------------------------------*
221    *       text
222    *----------------------------------------------------------------------*
223    *      -->P_TEXT_003  text
224    *----------------------------------------------------------------------*
225    FORM callerr USING l_text.
226      message: l_text type 'E'.
227    *  CALL FUNCTION 'FC_POPUP_ERR_WARN_MESSAGE'
228    *    EXPORTING
229    *      popup_title  = text-002
230    *      is_error     = 'X'
231    *      message_text = l_text
232    *      start_column = 30
233    *      start_row    = 8.
234      STOP.
235    ENDFORM.                    " callerr
236
237    *&---------------------------------------------------------------------*
238    *&      Form  check_calno
239    *&---------------------------------------------------------------------*
240    *       text
241    *----------------------------------------------------------------------*
242    *  -->  p1        text
243    *  <--  p2        text
244    *----------------------------------------------------------------------*
245    FORM check_data.
246
247    *  DATA: l_text TYPE string.
248    **  IF NOT P_WERKS IS INITIAL AND NOT P_TPLNR IS INITIAL
249    **  OR NOT P_DATE IS INITIAL.
250    *  CLEAR: p_tplnr, s_date.
251
252    *  SELECT SINGLE * FROM zhseair INTO CORRESPONDING FIELDS OF wa_zhseair
253    *  WHERE docno = p_docno.
254    *  IF sy-subrc <> 0.
255    *    l_text = 'data'.
256    *    MESSAGE e238(zpm) WITH l_text.
257    *    CLEAR l_text.
258    *  ENDIF.
259    *  p_werks = wa_zhseair-werks.
260    *  p_tplnr = wa_zhseair-tplnr.
261    *  p_date = wa_zhseair-sydate.
262    **  SELECT SINGLE * FROM zhseair INTO CORRESPONDING FIELDS OF wa_zhseair
263    **  WHERE werks = p_werks
264    **  AND tplnr = p_tplnr
265    **  AND sydate = p_date.
266    *
267
268    *  ENDIF.
269    ENDFORM.                    " check_calno
270    *&---------------------------------------------------------------------*
271    *&      Form  help_tplnr
272    *&---------------------------------------------------------------------*
273    *       text
274    *----------------------------------------------------------------------*
275    *  -->  p1        text
276    *  <--  p2        text
277    *----------------------------------------------------------------------*
278    FORM help_tplnr.
279      DATA: wa_tplnr  TYPE zhseair_h,
280            ist_tplnr LIKE STANDARD TABLE OF zhseair_h.
281      DATA : l_index TYPE sy-index,
282             l_werks TYPE zhseair_h-werks.
283      DATA : ist_dyfields LIKE dynpread OCCURS 1 WITH HEADER LINE.
284
285
286      ist_dyfields-fieldname = 'S_WERKS-LOW'.
287      APPEND ist_dyfields.
288
289      CALL FUNCTION 'DYNP_VALUES_READ'
290        EXPORTING
291          dyname     = sy-cprog
292          dynumb     = sy-dynnr
293        TABLES
294          dynpfields = ist_dyfields.
295
296      l_werks = ist_dyfields-fieldvalue.
297
298      IF NOT l_werks IS INITIAL.
299
300        SELECT werks tplnr from_dat to_dat FROM zhse_eff_ep
301            INTO CORRESPONDING FIELDS OF TABLE ist_floc_help
302               WHERE werks = l_werks.
303
304    * LOOP AT ist_tplnr into wa_tplnr.
305    *
306    *      l_index = sy-tabix.
307    *
308    *      IF ZHSE_ACCDT_N-INCDT_DATE GE wa_tplnr-FROM_DAT and
309    *         ZHSE_ACCDT_N-INCDT_DATE LE wa_tplnr-TO_DAT.
310    *
311    **    Do Nothing.
312    *
313    *      else.
314    *
315    *        DELETE ist_tplnr INDEX l_index.
316    *
317    *      endif.
318    *
319    *    ENDLOOP.
320
321        LOOP AT ist_floc_help INTO wa_floc_help.
322
323    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
324    *      SELECT SINGLE pltxt INTO wa_floc_help-pltxt FROM iflotx
325    *        WHERE tplnr = wa_floc_help-tplnr.
326     SELECT PLTXT FROM IFLOTX   UP TO 1 ROWS INTO WA_FLOC_HELP-PLTXT WHERE
327    TPLNR = WA_FLOC_HELP-TPLNR  ORDER BY  TPLNR SPRAS .   ENDSELECT.
328    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
329
330          IF sy-subrc = 0.
331            MODIFY ist_floc_help FROM wa_floc_help TRANSPORTING pltxt.
332          ENDIF.
333        ENDLOOP.
334
335        IF NOT ist_floc_help IS INITIAL.
336          CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
337            EXPORTING
338              retfield        = 'TPLNR'
339              dynpprog        = 'ZPM_AMBIENT_LIST_NEW'
340              dynpnr          = sy-dynnr
341              dynprofield     = 'S_TPLNR-LOW'
342              value_org       = 'S'
343            TABLES
344              value_tab       = ist_floc_help
345              return_tab      = ist_return_tab
346            EXCEPTIONS
347              parameter_error = 1
348              no_values_found = 2
349              OTHERS          = 3.
350
351          IF sy-subrc <> 0.
352
353            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
354                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
355
356          ENDIF.
357        ENDIF.
358      ENDIF.
359
360    *  IF ist_dyfields-fieldname = 'S_WERKS-LOW'.
361    *    s_tplnr-low =  ist_return_tab-fieldval.
362    *  ELSEIF ist_dyfields-fieldname = 'S_WERKS-HIGH'.
363    *    s_tplnr-high =  ist_return_tab-fieldval.
364    *  ENDIF.
365
366    *  SELECT werks tplnr dpr_dt docno  FROM zhseair_h
367    *                  INTO  CORRESPONDING  FIELDS  OF  TABLE  ist_tplnr.
368    *
369    *  IF  sy-subrc  EQ  0.
370    *
371    *    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
372    *         EXPORTING
373    *              retfield        = 'TPLNR'
374    *              dynpprog        = 'ZPM_AMBIENT_AIR_NEW'
375    *              dynpnr          = sy-dynnr
376    *              dynprofield     = 'TPLNR'
377    *              value_org       = 'S'
378    *         TABLES
379    *              value_tab       = ist_tplnr
380    *              return_tab      = ist_return_tab
381    *         EXCEPTIONS
382    *              parameter_error = 1
383    *              no_values_found = 2
384    *              OTHERS          = 3.
385    *
386    *    IF sy-subrc <> 0.
387    *
388    *      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
389    *              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
390    *
391    *    ENDIF.
392    *  ENDIF.
393
394    ENDFORM.                    " help_tplnr
395    *&---------------------------------------------------------------------*
396    *&      Form  call_ALV
397    *&---------------------------------------------------------------------*
398    *       text
399    *----------------------------------------------------------------------*
400    *  -->  p1        text
401    *  <--  p2        text
402    *----------------------------------------------------------------------*
403    FORM call_alv.
404    *  PERFORM event_get .
405      g_repid = sy-repid.
406      g_tabname_header = 'IST_ZHSEAIR'.
407      g_tabname_item   = 'IST_ZHSEAIR_D'.
408    * define keyinfo
409      CLEAR gs_keyinfo.
410      gs_keyinfo-header01 = 'DOCNO'.
411      gs_keyinfo-item01   = 'DOCNO'.
412
413      PERFORM list_events_h ."USING gt_events_h[].
414      PERFORM fill_header ."USING gt_list_top_of_page[].
415      PERFORM fill_footer ."USING gt_list_end_of_list[].
416
417      PERFORM e01_fieldcat_init  USING gt_fieldcat[].
418
419      PERFORM call_func_reuse_alv_list_disp.
420      PERFORM freeitab.
421
422    ENDFORM.                    " call_ALV
423    *&---------------------------------------------------------------------*
424    *&      Form  event_get
425    *&---------------------------------------------------------------------*
426    *       text
427    *----------------------------------------------------------------------*
428    *  -->  p1        text
429    *  <--  p2        text
430    *----------------------------------------------------------------------*
431    FORM event_get.
432      g_repid = sy-repid.
433      it_events-name = slis_ev_top_of_page.
434      it_events-form = 'OUTPUT_HEADER'.
435      APPEND it_events TO ls_events.
436      CLEAR it_events.
437
438    ENDFORM.                    " event_get
439    *&---------------------------------------------------------------------*
440    *&      Form  e01_fieldcat_init
441    *&---------------------------------------------------------------------*
442    *       text
443    *----------------------------------------------------------------------*
444    *      -->P_GT_FIELDCAT[]  text
445    *----------------------------------------------------------------------*
446    FORM e01_fieldcat_init USING e01_lt_fieldcat TYPE slis_t_fieldcat_alv.
447
448      REFRESH : gt_fieldcat.
449    *****
450    *****  CLEAR gs_fieldcat.
451    *****  gs_fieldcat-tabname     = 'IST_ZHSEAIR'.
452    *****  gs_fieldcat-fieldname   = 'DOCNO'.
453    *****  gs_fieldcat-ref_tabname = 'ZHSEAIR'.
454    *****  gs_fieldcat-seltext_m   = text-004.
455    *****  gs_fieldcat-outputlen   = 11.
456    *****  gs_fieldcat-fix_column  = 'X'.
457    *****  gs_fieldcat-key             =  'X'.
458    *****  APPEND gs_fieldcat TO e01_lt_fieldcat.
459    *****
460    *****  CLEAR gs_fieldcat.
461    *****  gs_fieldcat-tabname     = 'IST_ZHSEAIR'.
462    *****  gs_fieldcat-fieldname   = 'NAME1'.
463    *****  gs_fieldcat-ref_tabname = 'IST_ZHSEAIR'.
464    *****  gs_fieldcat-seltext_m   = text-006.
465    *****  gs_fieldcat-outputlen   = 40.
466    *****  gs_fieldcat-fix_column  = 'X'.
467    *****  gs_fieldcat-key             =  'X'.
468    *****  APPEND gs_fieldcat TO e01_lt_fieldcat.
469    *****
470    *****  CLEAR gs_fieldcat.
471    *****  gs_fieldcat-tabname     = 'IST_ZHSEAIR'.
472    *****  gs_fieldcat-fieldname   = 'BUNIT'.
473    *****  gs_fieldcat-ref_tabname = 'IST_ZHSEAIR'.
474    *****  gs_fieldcat-seltext_m   = text-029.
475    *****  gs_fieldcat-outputlen   = 40.
476    *****  gs_fieldcat-key             =  'X'.
477    *****  APPEND gs_fieldcat TO e01_lt_fieldcat.
478    *****
479    *****  CLEAR gs_fieldcat.
480    *****  gs_fieldcat-tabname     = 'IST_ZHSEAIR'.
481    *****  gs_fieldcat-fieldname   = 'PROJ'.
482    *****  gs_fieldcat-ref_tabname = 'IST_ZHSEAIR'.
483    *****  gs_fieldcat-seltext_m   = text-008.
484    *****  gs_fieldcat-outputlen   = 40.
485    *****  gs_fieldcat-key             =  'X'.
486    *****  APPEND gs_fieldcat TO e01_lt_fieldcat.
487    *****
488    *****  CLEAR gs_fieldcat.
489    *****  gs_fieldcat-tabname     = 'IST_ZHSEAIR_D'.
490    *****  gs_fieldcat-fieldname   = 'COLOR'.
491    *****  gs_fieldcat-ref_tabname = 'IST_ZHSEAIR_D'.
492    *****  gs_fieldcat-seltext_m   = text-009.
493    *****  gs_fieldcat-outputlen   = 10.
494    ******  gs_fieldcat-key             =  'X'.
495    ******  gs_fieldcat-fix_column  = 'X'.
496    *****  APPEND gs_fieldcat TO e01_lt_fieldcat.
497    *****
498    *****  CLEAR gs_fieldcat.
499    *****  gs_fieldcat-tabname     = 'IST_ZHSEAIR_D'.
500    *****  gs_fieldcat-fieldname   = 'ODOR'.
501    *****  gs_fieldcat-ref_tabname = 'IST_ZHSEAIR_D'.
502    *****  gs_fieldcat-seltext_m   = text-018.
503    *****  gs_fieldcat-outputlen   = 16.
504    ******  GS_fieldcat-key             =  'X'.
505    ******  gs_fieldcat-fix_column  = 'X'.
506    *****  APPEND gs_fieldcat TO e01_lt_fieldcat.
507    *****
508    *****
509    *****  CLEAR gs_fieldcat.
510    *****  gs_fieldcat-tabname     = 'IST_ZHSEAIR_D'.
511    *****  gs_fieldcat-fieldname   = 'TASTE'.
512    *****  gs_fieldcat-ref_tabname = 'IST_ZHSEAIR_D'.
513    *****  gs_fieldcat-seltext_m   = text-016.
514    *****  gs_fieldcat-outputlen   = 12.
515    ******  gs_fieldcat-fix_column  = 'X'.
516    *****  gs_fieldcat-no_zero     = 'X'.
517    *****  APPEND gs_fieldcat TO e01_lt_fieldcat.
518    *****
519    *****  CLEAR gs_fieldcat.
520    *****  gs_fieldcat-tabname     = 'IST_ZHSEAIR_D'.
521    *****  gs_fieldcat-fieldname   = 'TURBID'.
522    *****  gs_fieldcat-ref_tabname = 'IST_ZHSEAIR_D'.
523    *****  gs_fieldcat-seltext_m   = text-023.
524    *****  gs_fieldcat-outputlen   = 12.
525    ******  gs_fieldcat-fix_column  = 'X'.
526    *****  gs_fieldcat-no_zero     = 'X'.
527    *****  APPEND gs_fieldcat TO e01_lt_fieldcat.
528    *****
529    ******CO
530    *****  CLEAR gs_fieldcat.
531    *****  gs_fieldcat-tabname     = 'IST_ZHSEAIR'.
532    *****  gs_fieldcat-fieldname   = 'CO'.
533    *****  gs_fieldcat-ref_tabname = 'IST_ZHSEAIR'.
534    *****  gs_fieldcat-seltext_m   = text-014.
535    *****  gs_fieldcat-outputlen   = 11.
536    *****  gs_fieldcat-no_zero     = 'X'.
537    ******  gs_fieldcat-fix_column  = 'X'.
538    *****  APPEND gs_fieldcat TO e01_lt_fieldcat.
539    *****
540    *******Non CH4
541    *****  CLEAR gs_fieldcat.
542    *****  gs_fieldcat-tabname     = 'IST_ZHSEAIR'.
543    *****  gs_fieldcat-fieldname   = 'HC_NONMET'.
544    *****  gs_fieldcat-ref_tabname = 'IST_ZHSEAIR'.
545    *****  gs_fieldcat-seltext_m   = text-017.
546    *****  gs_fieldcat-outputlen   = 20.
547    *****  gs_fieldcat-no_zero     = 'X'.
548    *****  APPEND gs_fieldcat TO e01_lt_fieldcat.
549    *****
550    ******  *CH4
551    *****  CLEAR gs_fieldcat.
552    *****  gs_fieldcat-tabname     = 'IST_ZHSEAIR_D'.
553    *****  gs_fieldcat-fieldname   = 'PH'.
554    *****  gs_fieldcat-ref_tabname = 'IST_ZHSEAIR_D'.
555    *****  gs_fieldcat-seltext_m   = text-013.
556    *****  gs_fieldcat-outputlen   = 18.
557    *****  gs_fieldcat-no_zero     = 'X'.
558    *****  APPEND gs_fieldcat TO e01_lt_fieldcat.
559    *******H2s
560    *****  CLEAR gs_fieldcat.
561    *****  gs_fieldcat-tabname     = 'IST_ZHSEAIR_D'.
562    *****  gs_fieldcat-fieldname   = 'DIS_SOLID'.
563    *****  gs_fieldcat-ref_tabname = 'IST_ZHSEAIR_D'.
564    *****  gs_fieldcat-seltext_m   = text-015.
565    *****  gs_fieldcat-outputlen   = 10.
566    ******  gs_fieldcat-fix_column  = 'X'.
567    *****  gs_fieldcat-no_zero     = 'X'.
568    *****  APPEND gs_fieldcat TO e01_lt_fieldcat.
569    *******Pb
570    *****  CLEAR gs_fieldcat.
571    *****  gs_fieldcat-tabname     = 'IST_ZHSEAIR_D'.
572    *****  gs_fieldcat-fieldname   = 'FE'.
573    *****  gs_fieldcat-ref_tabname = 'IST_ZHSEAIR_D'.
574    *****  gs_fieldcat-seltext_m   = text-024.
575    *****  gs_fieldcat-outputlen   = 13.
576    ******  gs_fieldcat-fix_column  = 'X'.
577    *****  gs_fieldcat-no_zero     = 'X'.
578    *****  APPEND gs_fieldcat TO e01_lt_fieldcat.
579    *******Ni
580    *****  CLEAR gs_fieldcat.
581    *****  gs_fieldcat-tabname     = 'IST_ZHSEAIR_D'.
582    *****  gs_fieldcat-fieldname   = 'HARD'.
583    *****  gs_fieldcat-ref_tabname = 'IST_ZHSEAIR_D'.
584    *****  gs_fieldcat-seltext_m   = text-025.
585    *****  gs_fieldcat-outputlen   = 13.
586    ******  gs_fieldcat-fix_column  = 'X'.
587    *****  gs_fieldcat-no_zero     = 'X'.
588    *****  APPEND gs_fieldcat TO e01_lt_fieldcat.
589    *******No2
590    ******
591    ******  CLEAR gs_fieldcat.
592    ******  gs_fieldcat-tabname     = 'IST_ZHSEAIR_D'.
593    ******  gs_fieldcat-fieldname   = 'CL'.
594    ******  gs_fieldcat-ref_tabname = 'IST_ZHSEAIR_D'.
595    ******  gs_fieldcat-seltext_m   = text-012.
596    ******  gs_fieldcat-outputlen   = 13.
597    *******  gs_fieldcat-fix_column  = 'X'.
598    ******  gs_fieldcat-no_zero     = 'X'.
599    ******  APPEND gs_fieldcat TO e01_lt_fieldcat.
600    *******O3
601    *****  CLEAR gs_fieldcat.
602    *****  gs_fieldcat-tabname     = 'IST_ZHSEAIR_D'.
603    *****  gs_fieldcat-fieldname   = 'RESI_CL'.
604    *****  gs_fieldcat-ref_tabname = 'IST_ZHSEAIR_D'.
605    *****  gs_fieldcat-seltext_m   = text-026.
606    *****  gs_fieldcat-outputlen   = 13.
607    ******  gs_fieldcat-fix_column  = 'X'.
608    *****  gs_fieldcat-no_zero     = 'X'.
609    *****  APPEND gs_fieldcat TO e01_lt_fieldcat.
610    *******RPM
611    *****  CLEAR gs_fieldcat.
612    *****  gs_fieldcat-tabname     = 'IST_ZHSEAIR_D'.
613    *****  gs_fieldcat-fieldname   = 'SO4'.
614    *****  gs_fieldcat-ref_tabname = 'IST_ZHSEAIR_D'.
615    *****  gs_fieldcat-seltext_m   = text-022.
616    *****  gs_fieldcat-no_zero     = 'X'.
617    *****  gs_fieldcat-outputlen   = 11.
618    ******  gs_fieldcat-fix_column  = 'X'.
619    *****  APPEND gs_fieldcat TO e01_lt_fieldcat.
620    *******So2
621    *****  CLEAR gs_fieldcat.
622    *****  gs_fieldcat-tabname     = 'IST_ZHSEAIR_D'.
623    *****  gs_fieldcat-fieldname   = 'FLORI'.
624    *****  gs_fieldcat-ref_tabname = 'IST_ZHSEAIR_D'.
625    *****  gs_fieldcat-seltext_m   = text-011.
626    *****  gs_fieldcat-no_zero     = 'X'.
627    *****  gs_fieldcat-outputlen   = 11.
628    ******  gs_fieldcat-fix_column  = 'X'.
629    *****  APPEND gs_fieldcat TO e01_lt_fieldcat.
630    ******SPM
631    *****  CLEAR gs_fieldcat.
632    *****  gs_fieldcat-tabname     = 'IST_ZHSEAIR_D'.
633    *****  gs_fieldcat-fieldname   = 'COLI'.
634    *****  gs_fieldcat-ref_tabname = 'IST_ZHSEAIR_D'.
635    *****  gs_fieldcat-seltext_m   = text-010.
636    *****  gs_fieldcat-no_zero     = 'X'.
637    *****  gs_fieldcat-outputlen   = 12.
638    ******  gs_fieldcat-fix_column  = 'X'.
639    *****  APPEND gs_fieldcat TO e01_lt_fieldcat.
640    ******
641    *****  CLEAR gs_fieldcat.
642    *****  gs_fieldcat-tabname     = 'IST_ZHSEAIR_D'.
643    *****  gs_fieldcat-fieldname   = 'ECOLI'.
644    *****  gs_fieldcat-ref_tabname = 'IST_ZHSEAIR_D'.
645    *****  gs_fieldcat-seltext_m   = text-027.
646    *****  gs_fieldcat-no_zero     = 'X'.
647    *****  gs_fieldcat-outputlen   = 12.
648    ******  gs_fieldcat-fix_column  = 'X'.
649    *****  APPEND gs_fieldcat TO e01_lt_fieldcat.
650    ******
651    *****  CLEAR gs_fieldcat.
652    *****  gs_fieldcat-tabname     = 'IST_ZHSEAIR_D'.
653    *****  gs_fieldcat-fieldname   = 'REMARK'.
654    *****  gs_fieldcat-ref_tabname = 'IST_ZHSEAIR_D'.
655    *****  gs_fieldcat-seltext_m   = text-028.
656    *****  gs_fieldcat-no_zero     = 'X'.
657    *****  gs_fieldcat-outputlen   = 12.
658    ******  gs_fieldcat-fix_column  = 'X'.
659    *****  APPEND gs_fieldcat TO e01_lt_fieldcat.
660
661
662      CLEAR gs_fieldcat.
663      gs_fieldcat-tabname     = 'GT_FINAL'.
664      gs_fieldcat-fieldname   = 'DOCNO'.
665    ***  gs_fieldcat-ref_tabname = 'ZHSEAIR'.
666      gs_fieldcat-seltext_m   = text-004.
667      gs_fieldcat-outputlen   = 11.
668      gs_fieldcat-fix_column  = 'X'.
669      gs_fieldcat-key             =  'X'.
670      APPEND gs_fieldcat TO e01_lt_fieldcat.
671
672      CLEAR gs_fieldcat.
673      gs_fieldcat-tabname     = 'GT_FINAL'.
674      gs_fieldcat-fieldname   = 'NAME1'.
675    ***  gs_fieldcat-ref_tabname = 'IST_ZHSEAIR'.
676      gs_fieldcat-seltext_m   = text-006.
677      gs_fieldcat-outputlen   = 20.
678      gs_fieldcat-fix_column  = 'X'.
679      gs_fieldcat-key             =  'X'.
680      APPEND gs_fieldcat TO e01_lt_fieldcat.
681
682      CLEAR gs_fieldcat.
683      gs_fieldcat-tabname     = 'GT_FINAL'.
684      gs_fieldcat-fieldname   = 'BUNIT'.
685    ***  gs_fieldcat-ref_tabname = 'IST_ZHSEAIR'.
686      gs_fieldcat-seltext_m   = text-029.
687      gs_fieldcat-outputlen   = 20.
688      gs_fieldcat-key             =  'X'.
689      APPEND gs_fieldcat TO e01_lt_fieldcat.
690
691      CLEAR gs_fieldcat.
692      gs_fieldcat-tabname     = 'GT_FINAL'.
693      gs_fieldcat-fieldname   = 'BUNIT_D'.
694    ***  gs_fieldcat-ref_tabname = 'IST_ZHSEAIR'.
695      gs_fieldcat-seltext_m   = text-032.
696      gs_fieldcat-outputlen   = 40.
697    *  gs_fieldcat-key             =  'X'.
698      APPEND gs_fieldcat TO e01_lt_fieldcat.
699
700
701
702
703      CLEAR gs_fieldcat.
704      gs_fieldcat-tabname     = 'GT_FINAL'.
705      gs_fieldcat-fieldname   = 'PORJ'.
706    ***  gs_fieldcat-ref_tabname = 'IST_ZHSEAIR'.
707      gs_fieldcat-seltext_m   = text-008.
708      gs_fieldcat-outputlen   = 20.
709      gs_fieldcat-key             =  'X'.
710      APPEND gs_fieldcat TO e01_lt_fieldcat.
711
712      CLEAR gs_fieldcat.
713      gs_fieldcat-tabname     = 'GT_FINAL'.
714      gs_fieldcat-fieldname   = 'PORJ_D'.
715    ***  gs_fieldcat-ref_tabname = 'IST_ZHSEAIR'.
716      gs_fieldcat-seltext_m   = text-033.
717      gs_fieldcat-outputlen   = 40.
718    *  gs_fieldcat-key             =  'X'.
719      APPEND gs_fieldcat TO e01_lt_fieldcat.
720
721    *   CLEAR gs_fieldcat.
722    *  gs_fieldcat-tabname     = 'GT_FINAL'.
723    *  gs_fieldcat-fieldname   = 'MAX_LIMIT'.
724    ****  gs_fieldcat-ref_tabname = 'IST_ZHSEAIR'.
725    *  gs_fieldcat-seltext_m   = text-034.
726    *  gs_fieldcat-outputlen   = 40.
727    **  gs_fieldcat-key             =  'X'.
728    *  APPEND gs_fieldcat TO e01_lt_fieldcat.
729
730      CLEAR gs_fieldcat.
731      gs_fieldcat-tabname     = 'GT_FINAL'.
732      gs_fieldcat-fieldname   = 'COLOR'.
733    ***  gs_fieldcat-ref_tabname = 'IST_ZHSEAIR_D'.
734      gs_fieldcat-seltext_m   = text-009.
735      gs_fieldcat-outputlen   = 10.
736    *  gs_fieldcat-key             =  'X'.
737    *  gs_fieldcat-fix_column  = 'X'.
738      APPEND gs_fieldcat TO e01_lt_fieldcat.
739
740      CLEAR gs_fieldcat.
741      gs_fieldcat-tabname     = 'GT_FINAL'.
742      gs_fieldcat-fieldname   = 'ODOR'.
743    ***  gs_fieldcat-ref_tabname = 'IST_ZHSEAIR_D'.
744      gs_fieldcat-seltext_m   = text-018.
745      gs_fieldcat-outputlen   = 16.
746    *  GS_fieldcat-key             =  'X'.
747    *  gs_fieldcat-fix_column  = 'X'.
748      APPEND gs_fieldcat TO e01_lt_fieldcat.
749
750
751      CLEAR gs_fieldcat.
752      gs_fieldcat-tabname     = 'GT_FINAL'.
753      gs_fieldcat-fieldname   = 'TASTE'.
754    ***  gs_fieldcat-ref_tabname = 'IST_ZHSEAIR_D'.
755      gs_fieldcat-seltext_m   = text-016.
756      gs_fieldcat-outputlen   = 12.
757    *  gs_fieldcat-fix_column  = 'X'.
758      gs_fieldcat-no_zero     = 'X'.
759      APPEND gs_fieldcat TO e01_lt_fieldcat.
760
761      CLEAR gs_fieldcat.
762      gs_fieldcat-tabname     = 'GT_FINAL'.
763      gs_fieldcat-fieldname   = 'TURBID'.
764    ***  gs_fieldcat-ref_tabname = 'IST_ZHSEAIR_D'.
765      gs_fieldcat-seltext_m   = text-023.
766      gs_fieldcat-outputlen   = 12.
767    *  gs_fieldcat-fix_column  = 'X'.
768      gs_fieldcat-no_zero     = 'X'.
769      APPEND gs_fieldcat TO e01_lt_fieldcat.
770
771    *CO
772      CLEAR gs_fieldcat.
773      gs_fieldcat-tabname     = 'GT_FINAL'.
774      gs_fieldcat-fieldname   = 'CO'.
775    ***  gs_fieldcat-ref_tabname = 'IST_ZHSEAIR'.
776      gs_fieldcat-seltext_m   = text-014.
777      gs_fieldcat-outputlen   = 11.
778      gs_fieldcat-no_zero     = 'X'.
779    *  gs_fieldcat-fix_column  = 'X'.
780      APPEND gs_fieldcat TO e01_lt_fieldcat.
781
782    **Non CH4
783      CLEAR gs_fieldcat.
784      gs_fieldcat-tabname     = 'GT_FINAL'.
785      gs_fieldcat-fieldname   = 'HC_NONMET'.
786    ***  gs_fieldcat-ref_tabname = 'IST_ZHSEAIR'.
787      gs_fieldcat-seltext_m   = text-017.
788      gs_fieldcat-outputlen   = 20.
789      gs_fieldcat-no_zero     = 'X'.
790      APPEND gs_fieldcat TO e01_lt_fieldcat.
791
792    *  *CH4
793      CLEAR gs_fieldcat.
794      gs_fieldcat-tabname     = 'GT_FINAL'.
795      gs_fieldcat-fieldname   = 'PH'.
796    ***  gs_fieldcat-ref_tabname = 'IST_ZHSEAIR_D'.
797      gs_fieldcat-seltext_m   = text-013.
798      gs_fieldcat-outputlen   = 18.
799      gs_fieldcat-no_zero     = 'X'.
800      APPEND gs_fieldcat TO e01_lt_fieldcat.
801    **H2s
802      CLEAR gs_fieldcat.
803      gs_fieldcat-tabname     = 'GT_FINAL'.
804      gs_fieldcat-fieldname   = 'DIS_SOLID'.
805    ***  gs_fieldcat-ref_tabname = 'IST_ZHSEAIR_D'.
806      gs_fieldcat-seltext_m   = text-015.
807      gs_fieldcat-outputlen   = 10.
808    *  gs_fieldcat-fix_column  = 'X'.
809      gs_fieldcat-no_zero     = 'X'.
810      APPEND gs_fieldcat TO e01_lt_fieldcat.
811    **Pb
812      CLEAR gs_fieldcat.
813      gs_fieldcat-tabname     = 'GT_FINAL'.
814      gs_fieldcat-fieldname   = 'FE'.
815    ***  gs_fieldcat-ref_tabname = 'IST_ZHSEAIR_D'.
816      gs_fieldcat-seltext_m   = text-024.
817      gs_fieldcat-outputlen   = 13.
818    *  gs_fieldcat-fix_column  = 'X'.
819      gs_fieldcat-no_zero     = 'X'.
820      APPEND gs_fieldcat TO e01_lt_fieldcat.
821    **Ni
822      CLEAR gs_fieldcat.
823      gs_fieldcat-tabname     = 'GT_FINAL'.
824      gs_fieldcat-fieldname   = 'HARD'.
825    ***  gs_fieldcat-ref_tabname = 'IST_ZHSEAIR_D'.
826      gs_fieldcat-seltext_m   = text-025.
827      gs_fieldcat-outputlen   = 13.
828    *  gs_fieldcat-fix_column  = 'X'.
829      gs_fieldcat-no_zero     = 'X'.
830      APPEND gs_fieldcat TO e01_lt_fieldcat.
831    **No2
832    *
833    *  CLEAR gs_fieldcat.
834    *  gs_fieldcat-tabname     = 'IST_ZHSEAIR_D'.
835    *  gs_fieldcat-fieldname   = 'CL'.
836    *  gs_fieldcat-ref_tabname = 'IST_ZHSEAIR_D'.
837    *  gs_fieldcat-seltext_m   = text-012.
838    *  gs_fieldcat-outputlen   = 13.
839    **  gs_fieldcat-fix_column  = 'X'.
840    *  gs_fieldcat-no_zero     = 'X'.
841    *  APPEND gs_fieldcat TO e01_lt_fieldcat.
842    **O3
843      CLEAR gs_fieldcat.
844      gs_fieldcat-tabname     = 'GT_FINAL'.
845      gs_fieldcat-fieldname   = 'RESI_CL'.
846    ***  gs_fieldcat-ref_tabname = 'IST_ZHSEAIR_D'.
847      gs_fieldcat-seltext_m   = text-026.
848      gs_fieldcat-outputlen   = 13.
849    *  gs_fieldcat-fix_column  = 'X'.
850      gs_fieldcat-no_zero     = 'X'.
851      APPEND gs_fieldcat TO e01_lt_fieldcat.
852    **RPM
853      CLEAR gs_fieldcat.
854      gs_fieldcat-tabname     = 'GT_FINAL'.
855      gs_fieldcat-fieldname   = 'SO4'.
856    ***  gs_fieldcat-ref_tabname = 'IST_ZHSEAIR_D'.
857      gs_fieldcat-seltext_m   = text-022.
858      gs_fieldcat-no_zero     = 'X'.
859      gs_fieldcat-outputlen   = 11.
860    *  gs_fieldcat-fix_column  = 'X'.
861      APPEND gs_fieldcat TO e01_lt_fieldcat.
862    **So2
863      CLEAR gs_fieldcat.
864      gs_fieldcat-tabname     = 'GT_FINAL'.
865      gs_fieldcat-fieldname   = 'FLORI'.
866    ***  gs_fieldcat-ref_tabname = 'IST_ZHSEAIR_D'.
867      gs_fieldcat-seltext_m   = text-011.
868      gs_fieldcat-no_zero     = 'X'.
869      gs_fieldcat-outputlen   = 11.
870    *  gs_fieldcat-fix_column  = 'X'.
871      APPEND gs_fieldcat TO e01_lt_fieldcat.
872    *SPM
873      CLEAR gs_fieldcat.
874      gs_fieldcat-tabname     = 'GT_FINAL'.
875      gs_fieldcat-fieldname   = 'COLI'.
876    ***  gs_fieldcat-ref_tabname = 'IST_ZHSEAIR_D'.
877      gs_fieldcat-seltext_m   = text-010.
878      gs_fieldcat-no_zero     = 'X'.
879      gs_fieldcat-outputlen   = 12.
880    *  gs_fieldcat-fix_column  = 'X'.
881      APPEND gs_fieldcat TO e01_lt_fieldcat.
882    *
883      CLEAR gs_fieldcat.
884      gs_fieldcat-tabname     = 'GT_FINAL'.
885      gs_fieldcat-fieldname   = 'ECOLI'.
886    ***  gs_fieldcat-ref_tabname = 'IST_ZHSEAIR_D'.
887      gs_fieldcat-seltext_m   = text-027.
888      gs_fieldcat-no_zero     = 'X'.
889      gs_fieldcat-outputlen   = 12.
890    *  gs_fieldcat-fix_column  = 'X'.
891      APPEND gs_fieldcat TO e01_lt_fieldcat.
892    *
893      CLEAR gs_fieldcat.
894      gs_fieldcat-tabname     = 'GT_FINAL'.
895      gs_fieldcat-fieldname   = 'REMARK'.
896    ***  gs_fieldcat-ref_tabname = 'IST_ZHSEAIR_D'.
897      gs_fieldcat-seltext_m   = text-028.
898      gs_fieldcat-no_zero     = 'X'.
899      gs_fieldcat-outputlen   = 12.
900    *  gs_fieldcat-fix_column  = 'X'.
901      APPEND gs_fieldcat TO e01_lt_fieldcat.
902
903      CLEAR gs_fieldcat.
904      gs_fieldcat-tabname     = 'GT_FINAL'.
905      gs_fieldcat-fieldname   = 'NEXT_DUE'.
906    ***  gs_fieldcat-ref_tabname = 'IST_ZHSEAIR_D'.
907      gs_fieldcat-seltext_m   = text-030.
908      gs_fieldcat-no_zero     = 'X'.
909      gs_fieldcat-outputlen   = 12.
910    *  gs_fieldcat-fix_column  = 'X'.
911      APPEND gs_fieldcat TO e01_lt_fieldcat.
912
913      CLEAR gs_fieldcat.
914      gs_fieldcat-tabname     = 'GT_FINAL'.
915      gs_fieldcat-fieldname   = 'SAMP_DATE'.
916    ***  gs_fieldcat-ref_tabname = 'IST_ZHSEAIR_D'.
917      gs_fieldcat-seltext_m   = text-031.
918      gs_fieldcat-no_zero     = 'X'.
919      gs_fieldcat-outputlen   = 12.
920    *  gs_fieldcat-fix_column  = 'X'.
921      APPEND gs_fieldcat TO e01_lt_fieldcat.
922
923
924    ENDFORM.                    " e01_fieldcat_init
925
926    *---------------------------------------------------------------------*
927    *       FORM top_of_page                                              *
928    *---------------------------------------------------------------------*
929    *       ........                                                      *
930    *---------------------------------------------------------------------*
931    FORM top_of_page.
932
933      CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
934        EXPORTING
935          it_list_commentary = gt_list_top_of_page
936          i_logo             = 'ZONGC'.
937
938    ENDFORM.
939
940    *---------------------------------------------------------------------*
941    *       FORM end_of_list                                              *
942    *---------------------------------------------------------------------*
943    *       ........                                                      *
944    *---------------------------------------------------------------------*
945    FORM end_of_list.
946
947      CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
948        EXPORTING
949          it_list_commentary = gt_list_end_of_list
950          i_end_of_list_grid = gt_list_end_of_list.
951
952    ENDFORM.
953
954    *&---------------------------------------------------------------------*
955    *&      Form  list_events_h
956    *&---------------------------------------------------------------------*
957    *       text
958    *----------------------------------------------------------------------*
959    *      -->P_GT_EVENTS_H[]  text
960    *----------------------------------------------------------------------*
961    FORM list_events_h ."USING e03_lt_events TYPE slis_t_event.
962      DATA : g_status_set  TYPE slis_formname VALUE 'PF_STATUS_SET',
963             g_top_of_page TYPE slis_formname VALUE 'TOP_OF_PAGE',
964             g_top_of_list TYPE slis_formname VALUE 'TOP_OF_LIST',
965             g_end_of_list TYPE slis_formname VALUE 'END_OF_LIST'.
966
967      CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
968        EXPORTING
969          i_list_type = 0
970        IMPORTING
971          et_events   = gt_events_h.
972
973      READ TABLE gt_events_h WITH KEY name =  slis_ev_top_of_page
974                               INTO ls_event.
975      IF sy-subrc = 0.
976        MOVE g_top_of_page TO ls_event-form.
977        APPEND ls_event TO gt_events_h.
978      ENDIF.
979      READ TABLE gt_events_h WITH KEY name =  slis_ev_end_of_list
980                                 INTO ls_event.
981      IF sy-subrc = 0.
982
983        MOVE g_end_of_list TO ls_event-form.
984        APPEND ls_event TO gt_events_h.
985      ENDIF.
986
987    *  READ TABLE gt_events_h WITH KEY name = slis_ev_user_command
988    *                           INTO ls_event.
989    *  IF sy-subrc = 0.
990    *    MOVE 'PROCESS_COMMAND' TO ls_event-form.
991    *    APPEND ls_event TO gt_events_h.
992    *  ENDIF.
993
994    ENDFORM.                    " list_events_det
995    *&---------------------------------------------------------------------*
996    *&      Form  call_func_reuse_alv_list_disp
997    *&---------------------------------------------------------------------*
998    *       text
999    *----------------------------------------------------------------------*
1000   *  -->  p1        text
1001   *  <--  p2        text
1002   *----------------------------------------------------------------------*
1003   FORM call_func_reuse_alv_list_disp.
1004     g_repid = 'ZPM_POT_WATR_LIST_NEW'.
1005   *  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
1006   *       EXPORTING
1007   *            i_callback_program = g_repid
1008   *            it_fieldcat        = gt_fieldcat[]
1009   *            it_events          = gt_events_h[]
1010   *       TABLES
1011   *            t_outtab           = ist_zhseair.
1012   * Set Options: save variants userspecific or general
1013     g_save = 'A'.
1014   *        PERFORM variant_init.
1015   ** Get default variant
1016   **        gx_variant = g_variant.
1017   *        CALL FUNCTION 'REUSE_ALV_VARIANT_DEFAULT_GET'
1018   *             EXPORTING
1019   *                  i_save     = g_save
1020   *             CHANGING
1021   *                  cs_variant = gx_variant
1022   *             EXCEPTIONS
1023   *                  not_found  = 2.
1024   *        IF sy-subrc = 0.
1025   **      p_vari = gx_variant-variant.
1026   *        ENDIF.
1027
1028
1029   *****  CALL FUNCTION 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'
1030   *****    EXPORTING
1031   *****      i_callback_program = g_repid
1032   ******     I_CALLBACK_PF_STATUS_SET = ' '
1033   ******     I_CALLBACK_USER_COMMAND  = ' '
1034   ******     is_layout          = gs_layout
1035   *****      it_fieldcat        = gt_fieldcat[]
1036   ******     IT_EXCLUDING       =
1037   ******     it_special_groups  = gt_sp_group[]
1038   ******     IT_SORT            =
1039   ******     IT_FILTER          =
1040   ******     IS_SEL_HIDE        =
1041   ******     I_SCREEN_START_COLUMN    = 0
1042   ******     I_SCREEN_START_LINE      = 0
1043   ******     I_SCREEN_END_COLUMN      = 0
1044   ******     I_SCREEN_END_LINE  = 0
1045   ******     i_default          = g_default
1046   *****      i_save             = g_save
1047   ******     is_variant         = g_variant
1048   *****      it_events          = gt_events_h[]
1049   ******     IT_EVENT_EXIT      =
1050   *****      i_tabname_header   = g_tabname_header
1051   *****      i_tabname_item     = g_tabname_item
1052   *****      is_keyinfo         = gs_keyinfo
1053   ******     IS_PRINT           =
1054   ******      IMPORTING
1055   ******     E_EXIT_CAUSED_BY_CALLER  =
1056   *****    TABLES
1057   *****      t_outtab_header    = ist_zhseair
1058   *****      t_outtab_item      = ist_zhseair_d.
1059
1060     CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
1061       EXPORTING
1062         i_callback_program = g_repid
1063         it_fieldcat        = gt_fieldcat[]
1064   *     i_callback_user_command = 'USER_COMMAND'
1065   *     it_events          = i_events
1066       TABLES
1067         t_outtab           = gt_final.
1068   ENDFORM.                    " call_func_reuse_alv_list_disp
1069   *&---------------------------------------------------------------------*
1070   *&      Form  freeitab
1071   *&---------------------------------------------------------------------*
1072   *       text
1073   *----------------------------------------------------------------------*
1074   *  -->  p1        text
1075   *  <--  p2        text
1076   *----------------------------------------------------------------------*
1077   FORM freeitab.
1078
1079   ENDFORM.                    " freeitab
1080   *&---------------------------------------------------------------------*
1081   *&      Form  help_WERKS
1082   *&---------------------------------------------------------------------*
1083   *       text
1084   *----------------------------------------------------------------------*
1085   *  -->  p1        text
1086   *  <--  p2        text
1087   *----------------------------------------------------------------------*
1088   FORM help_werks.
1089     DATA: wa_tplnr  TYPE zhseair_h,
1090           ist_tplnr LIKE STANDARD TABLE OF zhseair_h.
1091
1092     SELECT werks tplnr dpr_dt docno  FROM zhseair_h
1093                     INTO  CORRESPONDING  FIELDS  OF  TABLE  ist_tplnr.
1094
1095     IF  sy-subrc  EQ  0.
1096
1097       CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
1098         EXPORTING
1099           retfield        = 'WERKS'
1100           dynpprog        = 'ZPM_AMBIENT_AIR_NEW'
1101           dynpnr          = sy-dynnr
1102           dynprofield     = 'WERKS'
1103           value_org       = 'S'
1104         TABLES
1105           value_tab       = ist_tplnr
1106           return_tab      = ist_return_tab
1107         EXCEPTIONS
1108           parameter_error = 1
1109           no_values_found = 2
1110           OTHERS          = 3.
1111
1112       IF sy-subrc <> 0.
1113
1114         MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
1115                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
1116
1117       ENDIF.
1118     ENDIF.
1119
1120   ENDFORM.                    " help_WERKS
1121
1122
1123   *&---------------------------------------------------------------------*
1124   *&      Form  fill_header
1125   *&---------------------------------------------------------------------*
1126   *       text
1127   *----------------------------------------------------------------------*
1128   *      -->P_GT_LIST_TOP_OF_PAGE[]  text
1129   *----------------------------------------------------------------------*
1130   FORM fill_header." USING gt_list_top_of_page[].
1131
1132     DATA: ls_line TYPE slis_listheader.
1133
1134     CLEAR gt_list_top_of_page.
1135     CLEAR ls_line.
1136     ls_line-typ  = 'H'.
1137     ls_line-info = text-019.
1138     APPEND ls_line TO gt_list_top_of_page.
1139
1140   ENDFORM.                    " fill_header
1141   *&---------------------------------------------------------------------*
1142   *&      Form  fill_footer
1143   *&---------------------------------------------------------------------*
1144   *       text
1145   *----------------------------------------------------------------------*
1146   *      -->P_GT_LIST_END_OF_LIST[]  text
1147   *----------------------------------------------------------------------*
1148   FORM fill_footer ."USING gt_list_end_of_list[].
1149
1150     DATA: ls_line TYPE slis_listheader.
1151
1152     DATA: l_text(50)   TYPE c.
1153     DATA: l_date(10)   TYPE c.
1154
1155     CLEAR gt_list_end_of_list.
1156     CLEAR ls_line.
1157     ls_line-typ  = 'S'.
1158     ls_line-key  = text-020.
1159     ls_line-info = sy-uname.
1160     APPEND ls_line TO gt_list_end_of_list.
1161
1162     WRITE sy-datum TO l_date  DD/MM/YYYY.
1163
1164     CLEAR ls_line.
1165     ls_line-typ  = 'S'.
1166     ls_line-key  = text-021.
1167     ls_line-info = l_date.
1168     APPEND ls_line TO gt_list_end_of_list.
1169
1170   ENDFORM.                    " fill_footer
1171   *&---------------------------------------------------------------------*
1172   *&      Form  HELP_P_BUNIT
1173   *&---------------------------------------------------------------------*
1174   *       text
1175   *----------------------------------------------------------------------*
1176   *  -->  p1        text
1177   *  <--  p2        text
1178   *----------------------------------------------------------------------*
1179   FORM help_p_bunit .
1180     REFRESH: it_return_bu,lit_bu_fcat, lit_acc_bu.
1181     CLEAR: ist_return_tab, ls_tabix_bu,lv_row_bu.
1182
1183
1184     lwa_bu_fcat-fieldname  = 'BUNIT'.    " Fieldname in the data table
1185     lwa_bu_fcat-seltext_m  = 'Business Unit'.    " Column description in the output
1186     APPEND lwa_bu_fcat TO lit_bu_fcat.
1187     CLEAR lwa_bu_fcat.
1188
1189     lwa_bu_fcat-fieldname  = 'BU_TXT'.    " Fieldname in the data table
1190     lwa_bu_fcat-seltext_l  = 'Description'.    " Column description in the output
1191     lwa_bu_fcat-outputlen = 32.
1192     APPEND lwa_bu_fcat TO lit_bu_fcat.
1193     CLEAR lwa_bu_fcat.
1194
1195
1196     SELECT * FROM zohse_eff_ep INTO CORRESPONDING FIELDS OF TABLE lit_acc_bu.
1197     IF lit_acc_bu IS NOT INITIAL..
1198       LOOP AT lit_acc_bu INTO lwa_acc_bu.
1199
1200   " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1201   *      SELECT SINGLE pltxt FROM iflotx INTO lwa_acc_bu-bu_txt WHERE tplnr = lwa_acc_bu-bunit.
1202    SELECT PLTXT FROM IFLOTX   UP TO 1 ROWS INTO LWA_ACC_BU-BU_TXT WHERE
1203   TPLNR = LWA_ACC_BU-BUNIT  ORDER BY  TPLNR SPRAS .   ENDSELECT.
1204   " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
1205         MODIFY lit_acc_bu FROM lwa_acc_bu TRANSPORTING bu_txt .
1206         CLEAR lwa_acc_bu.
1207       ENDLOOP.
1208       " BREAK-POINT.
1209   " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1210   SORT LIT_ACC_BU BY BUNIT .
1211   " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1212       DELETE ADJACENT DUPLICATES FROM lit_acc_bu COMPARING bunit.
1213
1214
1215       CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
1216         EXPORTING
1217           i_title       = 'Business Unit'
1218           i_selection   = 'X'
1219           i_zebra       = 'X'
1220           i_tabname     = 'LIT_ACC_DOC'
1221           it_fieldcat   = lit_bu_fcat
1222         IMPORTING
1223           es_selfield   = i_selfield
1224         TABLES
1225           t_outtab      = lit_acc_bu
1226         EXCEPTIONS
1227           program_error = 1
1228           OTHERS        = 2.
1229       IF i_selfield IS NOT INITIAL.
1230   " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1231         READ TABLE lit_acc_bu INTO lwa_acc_bu INDEX i_selfield-tabindex. "#EC CI_NOORDER
1232   " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1233         s_bunit-low = lwa_acc_bu-bunit.
1234
1235
1236         CLEAR i_selfield.
1237
1238       ENDIF.
1239
1240
1241     ENDIF.
1242
1243
1244   ENDFORM.
1245   *&---------------------------------------------------------------------*
1246   *&      Form  HELP_P_BUNIT_HIGH
1247   *&---------------------------------------------------------------------*
1248   *       text
1249   *----------------------------------------------------------------------*
1250   *  -->  p1        text
1251   *  <--  p2        text
1252   *----------------------------------------------------------------------*
1253   FORM help_p_bunit_high .
1254     REFRESH: it_return_bu,lit_bu_fcat, lit_acc_bu.
1255     CLEAR: ist_return_tab, ls_tabix_bu,lv_row_bu.
1256
1257
1258     lwa_bu_fcat-fieldname  = 'BUNIT'.    " Fieldname in the data table
1259     lwa_bu_fcat-seltext_m  = 'Business Unit'.    " Column description in the output
1260     APPEND lwa_bu_fcat TO lit_bu_fcat.
1261     CLEAR lwa_bu_fcat.
1262
1263     lwa_bu_fcat-fieldname  = 'BU_TXT'.    " Fieldname in the data table
1264     lwa_bu_fcat-seltext_l  = 'Description'.    " Column description in the output
1265     lwa_bu_fcat-outputlen = 32.
1266     APPEND lwa_bu_fcat TO lit_bu_fcat.
1267     CLEAR lwa_bu_fcat.
1268
1269
1270     SELECT * FROM zohse_eff_ep INTO CORRESPONDING FIELDS OF TABLE lit_acc_bu.
1271     IF lit_acc_bu IS NOT INITIAL..
1272       LOOP AT lit_acc_bu INTO lwa_acc_bu.
1273
1274   " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1275   *      SELECT SINGLE pltxt FROM iflotx INTO lwa_acc_bu-bu_txt WHERE tplnr = lwa_acc_bu-bunit.
1276    SELECT PLTXT FROM IFLOTX   UP TO 1 ROWS INTO LWA_ACC_BU-BU_TXT WHERE
1277   TPLNR = LWA_ACC_BU-BUNIT  ORDER BY  TPLNR SPRAS .   ENDSELECT.
1278   " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
1279         MODIFY lit_acc_bu FROM lwa_acc_bu TRANSPORTING bu_txt .
1280         CLEAR lwa_acc_bu.
1281       ENDLOOP.
1282       " BREAK-POINT.
1283   " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1284   SORT LIT_ACC_BU BY BUNIT .
1285   " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1286       DELETE ADJACENT DUPLICATES FROM lit_acc_bu COMPARING bunit.
1287
1288
1289       CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
1290         EXPORTING
1291           i_title       = 'Business Unit'
1292           i_selection   = 'X'
1293           i_zebra       = 'X'
1294           i_tabname     = 'LIT_ACC_DOC'
1295           it_fieldcat   = lit_bu_fcat
1296         IMPORTING
1297           es_selfield   = i_selfield
1298         TABLES
1299           t_outtab      = lit_acc_bu
1300         EXCEPTIONS
1301           program_error = 1
1302           OTHERS        = 2.
1303       IF i_selfield IS NOT INITIAL.
1304   " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1305         READ TABLE lit_acc_bu INTO lwa_acc_bu INDEX i_selfield-tabindex. "#EC CI_NOORDER
1306   " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1307         s_bunit-high = lwa_acc_bu-bunit.
1308
1309
1310         CLEAR i_selfield.
1311
1312       ENDIF.
1313
1314
1315     ENDIF.
1316
1317   ENDFORM.
1318   *&---------------------------------------------------------------------*
1319   *&      Form  HELP_S_PROJ
1320   *&---------------------------------------------------------------------*
1321   *       text
1322   *----------------------------------------------------------------------*
1323   *  -->  p1        text
1324   *  <--  p2        text
1325   *----------------------------------------------------------------------*
1326   FORM help_s_proj .
1327     TYPES: BEGIN OF lt_acc_proj,
1328              proj_txt TYPE pltxt,
1329              proj     TYPE tplnr,
1330
1331            END OF lt_acc_proj.
1332     DATA: lit_acc_proj TYPE STANDARD TABLE OF lt_acc_proj,
1333           lwa_acc_proj TYPE lt_acc_proj.
1334
1335     DATA : lt_project      TYPE TABLE OF zohse_eff_ep,
1336            ls_project      TYPE zohse_eff_ep,
1337            lt_text         TYPE TABLE OF iflotx,
1338            lit_return_proj TYPE TABLE OF ddshretval,
1339            ls_text         TYPE  iflotx.
1340
1341     DATA : "lt_read    TYPE STANDARD TABLE OF dynpread,
1342   *         ls_read    TYPE dynpread,
1343            ls_read_rb TYPE dynpread.
1344
1345     gls_read-fieldname = 'S_BUNIT-LOW'.  "p_case s_bunit-low
1346     APPEND gls_read TO glt_read.
1347
1348     CALL FUNCTION 'DYNP_VALUES_READ'
1349       EXPORTING
1350         dyname               = sy-cprog
1351         dynumb               = sy-dynnr
1352       TABLES
1353         dynpfields           = glt_read
1354       EXCEPTIONS
1355         invalid_abapworkarea = 1
1356         invalid_dynprofield  = 2
1357         invalid_dynproname   = 3
1358         invalid_dynpronummer = 4
1359         invalid_request      = 5
1360         no_fielddescription  = 6
1361         invalid_parameter    = 7
1362         undefind_error       = 8
1363         double_conversion    = 9
1364         stepl_not_found      = 10
1365         OTHERS               = 11.
1366     IF sy-subrc <> 0.
1367   * Implement suitable error handling here
1368     ENDIF.
1369
1370     READ TABLE glt_read INTO gls_read INDEX 1.
1371
1372     SELECT * FROM zohse_eff_ep INTO TABLE lt_project
1373          WHERE bunit = gls_read-fieldvalue.
1374
1375     IF sy-subrc = 0.
1376
1377       SELECT * FROM iflotx INTO TABLE lt_text
1378         FOR ALL ENTRIES IN lt_project
1379         WHERE tplnr = lt_project-bunit.
1380
1381
1382
1383
1384       LOOP AT lt_project INTO ls_project.
1385
1386
1387         lwa_acc_proj-proj = ls_project-proj.
1388
1389         READ TABLE lt_text INTO ls_text WITH KEY tplnr = ls_project-bunit.
1390
1391         IF sy-subrc = 0.
1392           lwa_acc_proj-proj_txt = ls_text-pltxt.
1393         ENDIF.
1394         APPEND lwa_acc_proj TO lit_acc_proj.
1395       ENDLOOP.
1396
1397       CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
1398         EXPORTING
1399           retfield         = 'PROJ' "'FUNC_LOC'
1400           dynpprog         = sy-repid
1401           dynpnr           = sy-dynnr
1402           dynprofield      = 'S_PROJ-LOW' "s_docno
1403           value_org        = 'S'
1404           callback_program = sy-repid
1405         TABLES
1406           value_tab        = lit_acc_proj
1407           return_tab       = lit_return_proj
1408         EXCEPTIONS
1409           parameter_error  = 1
1410           no_values_found  = 2
1411           OTHERS           = 3.
1412       IF sy-subrc <> 0.
1413   * Implement suitable error handling here
1414       ENDIF.
1415     ENDIF.
1416
1417   ENDFORM.
1418   *&---------------------------------------------------------------------*
1419   *&      Form  HELP_S_PROJ_HIG
1420   *&---------------------------------------------------------------------*
1421   *       text
1422   *----------------------------------------------------------------------*
1423   *  -->  p1        text
1424   *  <--  p2        text
1425   *----------------------------------------------------------------------*
1426   FORM help_s_proj_hig .
1427     TYPES: BEGIN OF lt_acc_proj,
1428              proj_txt TYPE pltxt,
1429              proj     TYPE tplnr,
1430
1431            END OF lt_acc_proj.
1432     DATA: lit_acc_proj TYPE STANDARD TABLE OF lt_acc_proj,
1433           lwa_acc_proj TYPE lt_acc_proj.
1434
1435     DATA : lt_project      TYPE TABLE OF zohse_eff_ep,
1436            ls_project      TYPE zohse_eff_ep,
1437            lt_text         TYPE TABLE OF iflotx,
1438            lit_return_proj TYPE TABLE OF ddshretval,
1439            ls_text         TYPE  iflotx.
1440
1441     DATA : "lt_read    TYPE STANDARD TABLE OF dynpread,
1442   *         ls_read    TYPE dynpread,
1443            ls_read_rb TYPE dynpread.
1444
1445     gls_read-fieldname = 'S_BUNIT-HIGH'.  "p_case s_bunit-low
1446     APPEND gls_read TO glt_read.
1447
1448     CALL FUNCTION 'DYNP_VALUES_READ'
1449       EXPORTING
1450         dyname               = sy-cprog
1451         dynumb               = sy-dynnr
1452       TABLES
1453         dynpfields           = glt_read
1454       EXCEPTIONS
1455         invalid_abapworkarea = 1
1456         invalid_dynprofield  = 2
1457         invalid_dynproname   = 3
1458         invalid_dynpronummer = 4
1459         invalid_request      = 5
1460         no_fielddescription  = 6
1461         invalid_parameter    = 7
1462         undefind_error       = 8
1463         double_conversion    = 9
1464         stepl_not_found      = 10
1465         OTHERS               = 11.
1466     IF sy-subrc <> 0.
1467   * Implement suitable error handling here
1468     ENDIF.
1469
1470     READ TABLE glt_read INTO gls_read INDEX 1.
1471
1472     SELECT * FROM zohse_eff_ep INTO TABLE lt_project
1473          WHERE bunit = gls_read-fieldvalue.
1474
1475     IF sy-subrc = 0.
1476
1477       SELECT * FROM iflotx INTO TABLE lt_text
1478         FOR ALL ENTRIES IN lt_project
1479         WHERE tplnr = lt_project-bunit.
1480
1481
1482
1483
1484       LOOP AT lt_project INTO ls_project.
1485
1486
1487         lwa_acc_proj-proj = ls_project-proj.
1488
1489         READ TABLE lt_text INTO ls_text WITH KEY tplnr = ls_project-bunit.
1490
1491         IF sy-subrc = 0.
1492           lwa_acc_proj-proj_txt = ls_text-pltxt.
1493         ENDIF.
1494         APPEND lwa_acc_proj TO lit_acc_proj.
1495       ENDLOOP.
1496
1497       CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
1498         EXPORTING
1499           retfield         = 'PROJ' "'FUNC_LOC'
1500           dynpprog         = sy-repid
1501           dynpnr           = sy-dynnr
1502           dynprofield      = 'S_PROJ-HIGH' "s_docno
1503           value_org        = 'S'
1504           callback_program = sy-repid
1505         TABLES
1506           value_tab        = lit_acc_proj
1507           return_tab       = lit_return_proj
1508         EXCEPTIONS
1509           parameter_error  = 1
1510           no_values_found  = 2
1511           OTHERS           = 3.
1512       IF sy-subrc <> 0.
1513   * Implement suitable error handling here
1514       ENDIF.
1515     ENDIF.
1516
1517
1518   ENDFORM.
*--- End of ZPM_POT_WATR_LIST_NEW - 1518 lines ---

----------------------------------------------------------------------------------------------------
Include          ZPM_POT_WATR_LIST_NEW_TOP                 Level 1    Page 2
Object           ZPM_POT_WATR_LIST_NEW                     Lines 140
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:27
----------------------------------------------------------------------------------------------------
1      *----------------------------------------------------------------------*
2      *   INCLUDE ZPM_AMBIENT_LIST_TOP                                       *
3      *----------------------------------------------------------------------*
4      TABLES: zhseair_h,zhseair_d.
5
6      *---------------------------------------------------------------------*
7      *                Type-Pools                                           *
8      *---------------------------------------------------------------------*
9      TYPE-POOLS: slis.
10     *---------------------------------------------------------------------*
11     *                Internal Tables for ALV                              *
12     *---------------------------------------------------------------------*
13
14     TYPES: BEGIN OF ty_floc_help,
15              werks    TYPE zhse_accdt_n-werks,
16              tplnr    TYPE zhse_accdt_n-func_loc,
17              pltxt    TYPE iflotx-pltxt,
18              from_dat LIKE zhse_eff_ep-from_dat,
19              to_dat   LIKE zhse_eff_ep-to_dat,
20            END OF ty_floc_help.
21
22     TYPES: BEGIN OF lt_acc_bu,
23              bunit  TYPE zbunit_d,
24              bu_txt	TYPE pltxt,
25            END OF lt_acc_bu.
26     DATA : glt_read TYPE STANDARD TABLE OF dynpread,
27            gls_read TYPE dynpread.
28
29     DATA: it_return_bu  LIKE STANDARD TABLE OF ddshretval,
30           gwa_return_bu LIKE ddshretval.
31     DATA  :  ist_return_tab LIKE STANDARD TABLE OF ddshretval
32                                                WITH  HEADER LINE.
33     DATA: lit_acc_bu TYPE STANDARD TABLE OF lt_acc_bu,
34           lwa_acc_bu TYPE lt_acc_bu.
35
36     DATA: lit_bu_fcat TYPE slis_t_fieldcat_alv,
37           lwa_bu_fcat TYPE slis_fieldcat_alv.
38
39     DATA:  ls_tabix_bu TYPE slis_selfield,
40            lv_row_bu   TYPE i.
41     DATA: i_selfield TYPE slis_selfield.
42     DATA : gt_events           TYPE slis_t_event,
43            gt_sort             TYPE slis_t_sortinfo_alv,
44            gs_layout           TYPE slis_layout_alv,
45            gt_list_top_of_page TYPE slis_t_listheader,
46            gt_list_end_of_list TYPE slis_t_listheader,
47            gt_fieldcat         TYPE slis_t_fieldcat_alv,
48            gt_fieldcat0        TYPE slis_t_fieldcat_alv,
49            gs_fieldcat         TYPE slis_fieldcat_alv,
50            gs_fieldcat0        TYPE slis_fieldcat_alv,
51            gs_extab            TYPE slis_t_extab,
52            ls_events           TYPE slis_alv_event OCCURS 0,
53            it_events           TYPE slis_alv_event.
54     DATA:  g_repid          TYPE sy-repid,
55            g_tabname_header TYPE slis_tabname,
56            g_tabname_item   TYPE slis_tabname,
57            gs_keyinfo       TYPE slis_keyinfo_alv,
58            g_save(1)        TYPE c,
59            l_matnr          TYPE mara-matnr.
60     DATA:  gt_events_h TYPE   slis_t_event,
61            gt_events_d TYPE   slis_t_event,
62            ls_event    TYPE   slis_alv_event.
63     DATA :e01_lt_fieldcat TYPE slis_t_fieldcat_alv.
64     DATA :e03_lt_events TYPE slis_t_event.
65     DATA : ist_floc_help TYPE STANDARD TABLE OF ty_floc_help,
66            wa_floc_help  TYPE ty_floc_help.
67     *---------------------------------------------------------------------*
68     *                Constants                                            *
69     *---------------------------------------------------------------------*
70     CONSTANTS gc_formname_top_of_page TYPE slis_formname VALUE
71      'TOP_OF_PAGE'.
72
73     *---------------------------------------------------------------------*
74     *        WORK AREA DECLRATION                                         *
75     *---------------------------------------------------------------------*
76
77     *DATA : l_tplnr TYPE itob-tplnr,
78     *       l_pltxt TYPE iflo-pltxt.
79
80
81     *DATA: ist_return_tab TYPE STANDARD TABLE OF ddshretval WITH HEADER LINE.
82     *
83     *TYPES:  BEGIN OF ty_vbap .
84     *        INCLUDE STRUCTURE vbap.
85     *TYPES:  bukrs_vf TYPE vbak-bukrs_vf.
86     *TYPES:  vkorg TYPE vbak-vkorg.
87     *TYPES:  knumv TYPE vbak-knumv.
88     *TYPES: END OF ty_vbap.
89
90     TYPES: BEGIN OF ty_zhseair.
91             INCLUDE STRUCTURE zhseair.
92     TYPES:        name1 TYPE t001w-name1.
93     TYPES:        pltxt TYPE iflotx-pltxt.
94     TYPES:        bunit TYPE zbunit_1.
95     TYPES:        porj  TYPE zproj_d.
96     TYPES  END   OF ty_zhseair.
97
98     TYPES: BEGIN OF ty_zhseair_d.
99             INCLUDE STRUCTURE zohse_water_d.
100    TYPES  END   OF ty_zhseair_d.
101
102    ************************ Begin of code by avtar on 22.11.2016 **************
103    TYPES: BEGIN OF ty_final,
104             docno     TYPE  zhseair-docno,
105             name1     TYPE  t001w-name1,
106             bunit     TYPE  zbunit_1,
107             bunit_d   TYPE  char30,
108             porj      TYPE  zproj_d,
109              max_limit TYPE zohse_nse_lmt-max_limit,
110             porj_d    TYPE char50,
111             co        TYPE  zhseair-co,
112             hc_nonmet TYPE  zhseair-hc_nonmet,
113             color     TYPE  zohse_water_d-color,
114             odor      TYPE zohse_water_d-odor,
115             taste     TYPE zohse_water_d-taste,
116             turbid    TYPE zohse_water_d-turbid,
117             ph        TYPE zohse_water_d-ph,
118             dis_solid TYPE zohse_water_d-dis_solid,
119             fe        TYPE zohse_water_d-fe,
120             hard      TYPE zohse_water_d-hard,
121             resi_cl   TYPE zohse_water_d-resi_cl,
122             so4       TYPE zohse_water_d-so4,
123             flori     TYPE zohse_water_d-flori,
124             coli      TYPE zohse_water_d-coli,
125             ecoli     TYPE zohse_water_d-ecoli,
126             remark    TYPE zohse_water_d-remark,
127             next_due  TYPE zohse_water_d-due_date,
128             samp_date TYPE zhseair_h-dpr_dt,
129
130           END OF ty_final.
131
132    DATA: gt_final TYPE TABLE OF ty_final.
133
134    ************************ End of code by avtar on 22.11.2016 ***************
135    DATA : wa_zhseair TYPE ty_zhseair.
136    DATA: ist_zhseair TYPE STANDARD TABLE OF ty_zhseair.
137    DATA : wa_zhseair_d TYPE ty_zhseair_d.
138    DATA: ist_zhseair_d TYPE STANDARD TABLE OF ty_zhseair_d.
139    DATA  l_pltxt TYPE iflo-pltxt.
140    DATA: name1 TYPE t001w-name1.
*--- End of ZPM_POT_WATR_LIST_NEW_TOP - 140 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CSLIS                                   Level 1    Page 3
Object           ZPM_POT_WATR_LIST_NEW                     Lines 543
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:27
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
Generated incl.  <REPINI>                                  Level 1    Page 4
Object           ZPM_POT_WATR_LIST_NEW                     Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:27
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
Generated incl.  <SYSINI>                                  Level 1    Page 5
Object           ZPM_POT_WATR_LIST_NEW                     Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:27
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
Generated incl.  <SYSSEL>                                  Level 1    Page 6
Object           ZPM_POT_WATR_LIST_NEW                     Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:27
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
Generated incl.  DB__SSEL                                  Level 1    Page 7
Object           ZPM_POT_WATR_LIST_NEW                     Lines 1
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:27
----------------------------------------------------------------------------------------------------
1      * INCLUDE DB__SSEL
*--- End of DB__SSEL - 1 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CABAP                                   Level 1    Page 8
Object           ZPM_POT_WATR_LIST_NEW                     Lines 360
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:27
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
