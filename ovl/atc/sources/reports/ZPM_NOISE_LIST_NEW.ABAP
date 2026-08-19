----------------------------------------------------------------------------------------------------
Main program     ZPM_NOISE_LIST_NEW                        Level 0    Page 1
Object           ZPM_NOISE_LIST_NEW                        Lines 1196
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:25
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
26     INCLUDE zpm_noise_list_new_top.
27
28
29     SELECTION-SCREEN BEGIN OF BLOCK emd WITH FRAME TITLE text-001.
30     ***CODE ADDED BY CAB_AMITMOZA ON 25.09.2012 TO INCLUDE F4 ELEMENT FOR S_WERKS*******
31     SELECT-OPTIONS:   s_werks FOR zhseair_h-werks MEMORY ID wrk DEFAULT '90R1',
32     *******CODE END BY CAB_AMITMOZA*************
33     *                  s_tplnr FOR zhseair_h-tplnr ,
34                       s_bunit  FOR zhseair_h-bunit,
35                       s_proj   FOR zhseair_h-porj,
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
53     AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_bunit-low.
54       PERFORM help_bunit .
55
56     AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_bunit-high.
57       PERFORM help_bunit_hig .
58
59     AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_proj-low.
60       PERFORM help_prj_low .
61
62     AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_proj-high.
63       PERFORM help_prj_high .
64
65     INITIALIZATION.
66       g_repid = sy-repid.
67
68     START-OF-SELECTION.
69       PERFORM fetch_inst_details.
70       PERFORM call_alv.
71
72     END-OF-SELECTION.
73
74     *&---------------------------------------------------------------------*
75     *&      Form  fetch_inst_details
76     *&---------------------------------------------------------------------*
77     *&  FETCH DATA FROM ZHSEAIR                                            *
78     *----------------------------------------------------------------------*
79     FORM fetch_inst_details.
80       REFRESH : ist_zhseair.
81       CLEAR   : wa_zhseair.
82
83       SELECT * FROM zhseair_h INTO CORRESPONDING FIELDS OF TABLE
84       ist_zhseair
85       WHERE werks IN s_werks
86     *  AND tplnr IN s_tplnr
87        AND bunit IN s_bunit
88       AND porj IN s_proj
89       AND dpr_dt IN s_date
90       AND znpi  EQ 'NOI'.
91
92       IF sy-subrc <> 0.
93         PERFORM callerr USING text-003.
94         STOP.
95       ELSE.
96
97         SELECT * FROM zohse_noise_d
98         INTO CORRESPONDING FIELDS OF TABLE ist_zhseair_d
99         FOR ALL ENTRIES IN ist_zhseair
100        WHERE docno = ist_zhseair-docno.
101
102        LOOP AT ist_zhseair INTO wa_zhseair.
103          CLEAR : name1, l_pltxt.
104          SELECT SINGLE name1 INTO name1 FROM t001w
105          WHERE werks = wa_zhseair-werks.
106          CONDENSE name1.
107          wa_zhseair-name1 = name1.
108    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
109    *      SELECT SINGLE pltxt INTO l_pltxt FROM iflotx
110    *      WHERE tplnr = wa_zhseair-tplnr.
111     SELECT PLTXT FROM IFLOTX   UP TO 1 ROWS INTO L_PLTXT WHERE TPLNR =
112    WA_ZHSEAIR-TPLNR  ORDER BY  TPLNR SPRAS .   ENDSELECT.
113    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
114          wa_zhseair-pltxt = l_pltxt.
115          MODIFY ist_zhseair FROM wa_zhseair TRANSPORTING name1 pltxt.
116
117        ENDLOOP.
118      ENDIF.
119      SORT ist_zhseair BY dpr_dt.
120
121    ENDFORM.                    " fetch_inst_details
122
123    *&---------------------------------------------------------------------*
124    *&      Form  callerr
125    *&---------------------------------------------------------------------*
126    *       text
127    *----------------------------------------------------------------------*
128    *      -->P_TEXT_003  text
129    *----------------------------------------------------------------------*
130    FORM callerr USING l_text.
131      MESSAGE: L_TEXT TYPE 'E'.
132    *  CALL FUNCTION 'FC_POPUP_ERR_WARN_MESSAGE'
133    *    EXPORTING
134    *      popup_title  = text-002
135    *      is_error     = 'X'
136    *      message_text = l_text
137    *      start_column = 30
138    *      start_row    = 8.
139      STOP.
140    ENDFORM.                    " callerr
141
142    *&---------------------------------------------------------------------*
143    *&      Form  check_calno
144    *&---------------------------------------------------------------------*
145    *       text
146    *----------------------------------------------------------------------*
147    *  -->  p1        text
148    *  <--  p2        text
149    *----------------------------------------------------------------------*
150    FORM check_data.
151
152    *  DATA: l_text TYPE string.
153    **  IF NOT P_WERKS IS INITIAL AND NOT P_TPLNR IS INITIAL
154    **  OR NOT P_DATE IS INITIAL.
155    *  CLEAR: p_tplnr, s_date.
156
157    *  SELECT SINGLE * FROM zhseair INTO CORRESPONDING FIELDS OF wa_zhseair
158    *  WHERE docno = p_docno.
159    *  IF sy-subrc <> 0.
160    *    l_text = 'data'.
161    *    MESSAGE e238(zpm) WITH l_text.
162    *    CLEAR l_text.
163    *  ENDIF.
164    *  p_werks = wa_zhseair-werks.
165    *  p_tplnr = wa_zhseair-tplnr.
166    *  p_date = wa_zhseair-sydate.
167    **  SELECT SINGLE * FROM zhseair INTO CORRESPONDING FIELDS OF wa_zhseair
168    **  WHERE werks = p_werks
169    **  AND tplnr = p_tplnr
170    **  AND sydate = p_date.
171    *
172
173    *  ENDIF.
174    ENDFORM.                    " check_calno
175    *&---------------------------------------------------------------------*
176    *&      Form  help_tplnr
177    *&---------------------------------------------------------------------*
178    *       text
179    *----------------------------------------------------------------------*
180    *  -->  p1        text
181    *  <--  p2        text
182    *----------------------------------------------------------------------*
183    FORM help_tplnr.
184      DATA: wa_tplnr  TYPE zhseair_h,
185            ist_tplnr LIKE STANDARD TABLE OF zhseair_h.
186      DATA : l_index TYPE sy-index,
187             l_werks TYPE zhseair_h-werks.
188      DATA : ist_dyfields LIKE dynpread OCCURS 1 WITH HEADER LINE.
189
190
191      ist_dyfields-fieldname = 'S_WERKS-LOW'.
192      APPEND ist_dyfields.
193
194      CALL FUNCTION 'DYNP_VALUES_READ'
195        EXPORTING
196          dyname     = sy-cprog
197          dynumb     = sy-dynnr
198        TABLES
199          dynpfields = ist_dyfields.
200
201      l_werks = ist_dyfields-fieldvalue.
202
203      IF NOT l_werks IS INITIAL.
204
205        SELECT werks tplnr from_dat to_dat FROM zhse_eff_ep
206            INTO CORRESPONDING FIELDS OF TABLE ist_floc_help
207               WHERE werks = l_werks.
208
209    * LOOP AT ist_tplnr into wa_tplnr.
210    *
211    *      l_index = sy-tabix.
212    *
213    *      IF ZHSE_ACCDT_N-INCDT_DATE GE wa_tplnr-FROM_DAT and
214    *         ZHSE_ACCDT_N-INCDT_DATE LE wa_tplnr-TO_DAT.
215    *
216    **    Do Nothing.
217    *
218    *      else.
219    *
220    *        DELETE ist_tplnr INDEX l_index.
221    *
222    *      endif.
223    *
224    *    ENDLOOP.
225
226        LOOP AT ist_floc_help INTO wa_floc_help.
227
228    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
229    *      SELECT SINGLE pltxt INTO wa_floc_help-pltxt FROM iflotx
230    *        WHERE tplnr = wa_floc_help-tplnr.
231     SELECT PLTXT FROM IFLOTX   UP TO 1 ROWS INTO WA_FLOC_HELP-PLTXT WHERE
232    TPLNR = WA_FLOC_HELP-TPLNR  ORDER BY  TPLNR SPRAS .   ENDSELECT.
233    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
234
235          IF sy-subrc = 0.
236            MODIFY ist_floc_help FROM wa_floc_help TRANSPORTING pltxt.
237          ENDIF.
238        ENDLOOP.
239
240        IF NOT ist_floc_help IS INITIAL.
241          CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
242            EXPORTING
243              retfield        = 'TPLNR'
244              dynpprog        = 'ZPM_AMBIENT_LIST_NEW'
245              dynpnr          = sy-dynnr
246              dynprofield     = 'S_TPLNR-LOW'
247              value_org       = 'S'
248            TABLES
249              value_tab       = ist_floc_help
250              return_tab      = ist_return_tab
251            EXCEPTIONS
252              parameter_error = 1
253              no_values_found = 2
254              OTHERS          = 3.
255
256          IF sy-subrc <> 0.
257
258            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
259                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
260
261          ENDIF.
262        ENDIF.
263      ENDIF.
264
265    *  IF ist_dyfields-fieldname = 'S_WERKS-LOW'.
266    *    s_tplnr-low =  ist_return_tab-fieldval.
267    *  ELSEIF ist_dyfields-fieldname = 'S_WERKS-HIGH'.
268    *    s_tplnr-high =  ist_return_tab-fieldval.
269    *  ENDIF.
270
271    *  SELECT werks tplnr dpr_dt docno  FROM zhseair_h
272    *                  INTO  CORRESPONDING  FIELDS  OF  TABLE  ist_tplnr.
273    *
274    *  IF  sy-subrc  EQ  0.
275    *
276    *    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
277    *         EXPORTING
278    *              retfield        = 'TPLNR'
279    *              dynpprog        = 'ZPM_AMBIENT_AIR_NEW'
280    *              dynpnr          = sy-dynnr
281    *              dynprofield     = 'TPLNR'
282    *              value_org       = 'S'
283    *         TABLES
284    *              value_tab       = ist_tplnr
285    *              return_tab      = ist_return_tab
286    *         EXCEPTIONS
287    *              parameter_error = 1
288    *              no_values_found = 2
289    *              OTHERS          = 3.
290    *
291    *    IF sy-subrc <> 0.
292    *
293    *      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
294    *              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
295    *
296    *    ENDIF.
297    *  ENDIF.
298
299    ENDFORM.                    " help_tplnr
300    *&---------------------------------------------------------------------*
301    *&      Form  call_ALV
302    *&---------------------------------------------------------------------*
303    *       text
304    *----------------------------------------------------------------------*
305    *  -->  p1        text
306    *  <--  p2        text
307    *----------------------------------------------------------------------*
308    FORM call_alv.
309    *  PERFORM event_get .
310      g_repid = sy-repid.
311      g_tabname_header = 'IST_ZHSEAIR'.
312      g_tabname_item   = 'IST_ZHSEAIR_D'.
313    * define keyinfo
314      CLEAR gs_keyinfo.
315      gs_keyinfo-header01 = 'DOCNO'.
316      gs_keyinfo-item01   = 'DOCNO'.
317
318      PERFORM list_events_h ."USING gt_events_h[].
319      PERFORM fill_header ."USING gt_list_top_of_page[].
320      PERFORM fill_footer ."USING gt_list_end_of_list[].
321
322      PERFORM e01_fieldcat_init  USING gt_fieldcat[].
323
324      PERFORM call_func_reuse_alv_list_disp.
325      PERFORM freeitab.
326
327    ENDFORM.                    " call_ALV
328    *&---------------------------------------------------------------------*
329    *&      Form  event_get
330    *&---------------------------------------------------------------------*
331    *       text
332    *----------------------------------------------------------------------*
333    *  -->  p1        text
334    *  <--  p2        text
335    *----------------------------------------------------------------------*
336    FORM event_get.
337      g_repid = sy-repid.
338      it_events-name = slis_ev_top_of_page.
339      it_events-form = 'OUTPUT_HEADER'.
340      APPEND it_events TO ls_events.
341      CLEAR it_events.
342
343    ENDFORM.                    " event_get
344    *&---------------------------------------------------------------------*
345    *&      Form  e01_fieldcat_init
346    *&---------------------------------------------------------------------*
347    *       text
348    *----------------------------------------------------------------------*
349    *      -->P_GT_FIELDCAT[]  text
350    *----------------------------------------------------------------------*
351    FORM e01_fieldcat_init USING e01_lt_fieldcat TYPE slis_t_fieldcat_alv.
352
353      REFRESH : gt_fieldcat.
354
355      CLEAR gs_fieldcat.
356      gs_fieldcat-tabname     = 'IST_ZHSEAIR'.
357      gs_fieldcat-fieldname   = 'DOCNO'.
358      gs_fieldcat-ref_tabname = 'ZHSEAIR'.
359      gs_fieldcat-seltext_m   = text-004.
360      gs_fieldcat-outputlen   = 11.
361      gs_fieldcat-fix_column  = 'X'.
362      gs_fieldcat-key             =  'X'.
363      APPEND gs_fieldcat TO e01_lt_fieldcat.
364
365
366
367      CLEAR gs_fieldcat.
368      gs_fieldcat-tabname     = 'IST_ZHSEAIR'.
369      gs_fieldcat-fieldname   = 'NAME1'.
370      gs_fieldcat-ref_tabname = 'IST_ZHSEAIR'.
371      gs_fieldcat-seltext_m   = text-006.
372      gs_fieldcat-outputlen   = 40.
373      gs_fieldcat-fix_column  = 'X'.
374      gs_fieldcat-key             =  'X'.
375      APPEND gs_fieldcat TO e01_lt_fieldcat.
376
377    *  CLEAR gs_fieldcat.
378    *  gs_fieldcat-tabname     = 'IST_ZHSEAIR'.
379    *  gs_fieldcat-fieldname   = 'PLTXT'.
380    *  gs_fieldcat-ref_tabname = 'IST_ZHSEAIR'.
381    *  gs_fieldcat-seltext_m   = text-008.
382    *  gs_fieldcat-outputlen   = 40.
383    *  gs_fieldcat-key             =  'X'.
384    *  APPEND gs_fieldcat TO e01_lt_fieldcat.
385
386       CLEAR gs_fieldcat.
387      gs_fieldcat-tabname     = 'IST_ZHSEAIR'.
388      gs_fieldcat-fieldname   = 'BUNIT'.
389      gs_fieldcat-ref_tabname = 'IST_ZHSEAIR'.
390      gs_fieldcat-seltext_m   = text-027.
391      gs_fieldcat-outputlen   = 40.
392      gs_fieldcat-key             =  'X'.
393      APPEND gs_fieldcat TO e01_lt_fieldcat.
394
395       CLEAR gs_fieldcat.
396      gs_fieldcat-tabname     = 'IST_ZHSEAIR'.
397      gs_fieldcat-fieldname   = 'PORJ'.
398      gs_fieldcat-ref_tabname = 'IST_ZHSEAIR'.
399      gs_fieldcat-seltext_m   = text-008.
400      gs_fieldcat-outputlen   = 40.
401      gs_fieldcat-key             =  'X'.
402      APPEND gs_fieldcat TO e01_lt_fieldcat.
403
404
405
406      CLEAR gs_fieldcat.
407      gs_fieldcat-tabname     = 'IST_ZHSEAIR_D'.
408      gs_fieldcat-fieldname   = 'SAMPL_STATN'.
409      gs_fieldcat-ref_tabname = 'IST_ZHSEAIR_D'.
410      gs_fieldcat-seltext_m   = text-018.
411      gs_fieldcat-outputlen   = 16.
412    *  GS_fieldcat-key             =  'X'.
413    *  gs_fieldcat-fix_column  = 'X'.
414      APPEND gs_fieldcat TO e01_lt_fieldcat.
415
416
417      CLEAR gs_fieldcat.
418      gs_fieldcat-tabname     = 'IST_ZHSEAIR_D'.
419      gs_fieldcat-fieldname   = 'N_LEVEL'.
420      gs_fieldcat-ref_tabname = 'IST_ZHSEAIR_D'.
421      gs_fieldcat-seltext_m   = text-016.
422      gs_fieldcat-outputlen   = 12.
423    *  gs_fieldcat-fix_column  = 'X'.
424      gs_fieldcat-no_zero     = 'X'.
425      APPEND gs_fieldcat TO e01_lt_fieldcat.
426    *
427    *   CLEAR gs_fieldcat.
428    *  gs_fieldcat-tabname     = 'IST_ZHSEAIR_D'.
429    *  gs_fieldcat-fieldname   = 'PORJ'.
430    *  gs_fieldcat-ref_tabname = 'IST_ZHSEAIR_D'.
431    *  gs_fieldcat-seltext_m   = text-023.
432    *  gs_fieldcat-outputlen   = 15.
433    **  gs_fieldcat-fix_column  = 'X'.
434    *  gs_fieldcat-no_zero     = 'X'.
435    *  APPEND gs_fieldcat TO e01_lt_fieldcat.
436
437    *CO
438      CLEAR gs_fieldcat.
439      gs_fieldcat-tabname     = 'IST_ZHSEAIR_D'.
440      gs_fieldcat-fieldname   = 'DUE_DATE'.
441      gs_fieldcat-ref_tabname = 'IST_ZHSEAIR_D'.
442      gs_fieldcat-seltext_m   = text-014.
443      gs_fieldcat-outputlen   = 11.
444      gs_fieldcat-no_zero     = 'X'.
445    *  gs_fieldcat-fix_column  = 'X'.
446      APPEND gs_fieldcat TO e01_lt_fieldcat.
447    *CH4
448
449
450    ENDFORM.                    " e01_fieldcat_init
451
452    *---------------------------------------------------------------------*
453    *       FORM top_of_page                                              *
454    *---------------------------------------------------------------------*
455    *       ........                                                      *
456    *---------------------------------------------------------------------*
457    FORM top_of_page.
458
459      CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
460        EXPORTING
461          it_list_commentary = gt_list_top_of_page
462          i_logo             = 'ZONGC'.
463
464    ENDFORM.
465
466    *---------------------------------------------------------------------*
467    *       FORM end_of_list                                              *
468    *---------------------------------------------------------------------*
469    *       ........                                                      *
470    *---------------------------------------------------------------------*
471    FORM end_of_list.
472
473      CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
474        EXPORTING
475          it_list_commentary = gt_list_end_of_list
476          i_end_of_list_grid = gt_list_end_of_list.
477
478    ENDFORM.
479
480    *&---------------------------------------------------------------------*
481    *&      Form  list_events_h
482    *&---------------------------------------------------------------------*
483    *       text
484    *----------------------------------------------------------------------*
485    *      -->P_GT_EVENTS_H[]  text
486    *----------------------------------------------------------------------*
487    FORM list_events_h ."USING e03_lt_events TYPE slis_t_event.
488      DATA : g_status_set  TYPE slis_formname VALUE 'PF_STATUS_SET',
489             g_top_of_page TYPE slis_formname VALUE 'TOP_OF_PAGE',
490             g_top_of_list TYPE slis_formname VALUE 'TOP_OF_LIST',
491             g_end_of_list TYPE slis_formname VALUE 'END_OF_LIST'.
492
493      CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
494        EXPORTING
495          i_list_type = 0
496        IMPORTING
497          et_events   = gt_events_h.
498
499      READ TABLE gt_events_h WITH KEY name =  slis_ev_top_of_page
500                               INTO ls_event.
501      IF sy-subrc = 0.
502        MOVE g_top_of_page TO ls_event-form.
503        APPEND ls_event TO gt_events_h.
504      ENDIF.
505      READ TABLE gt_events_h WITH KEY name =  slis_ev_end_of_list
506                                 INTO ls_event.
507      IF sy-subrc = 0.
508
509        MOVE g_end_of_list TO ls_event-form.
510        APPEND ls_event TO gt_events_h.
511      ENDIF.
512
513    *  READ TABLE gt_events_h WITH KEY name = slis_ev_user_command
514    *                           INTO ls_event.
515    *  IF sy-subrc = 0.
516    *    MOVE 'PROCESS_COMMAND' TO ls_event-form.
517    *    APPEND ls_event TO gt_events_h.
518    *  ENDIF.
519
520    ENDFORM.                    " list_events_det
521    *&---------------------------------------------------------------------*
522    *&      Form  call_func_reuse_alv_list_disp
523    *&---------------------------------------------------------------------*
524    *       text
525    *----------------------------------------------------------------------*
526    *  -->  p1        text
527    *  <--  p2        text
528    *----------------------------------------------------------------------*
529    FORM call_func_reuse_alv_list_disp.
530      g_repid = 'ZPM_NOISE_LIST_NEW'.
531    *  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
532    *       EXPORTING
533    *            i_callback_program = g_repid
534    *            it_fieldcat        = gt_fieldcat[]
535    *            it_events          = gt_events_h[]
536    *       TABLES
537    *            t_outtab           = ist_zhseair.
538    * Set Options: save variants userspecific or general
539      g_save = 'A'.
540    *        PERFORM variant_init.
541    ** Get default variant
542    **        gx_variant = g_variant.
543    *        CALL FUNCTION 'REUSE_ALV_VARIANT_DEFAULT_GET'
544    *             EXPORTING
545    *                  i_save     = g_save
546    *             CHANGING
547    *                  cs_variant = gx_variant
548    *             EXCEPTIONS
549    *                  not_found  = 2.
550    *        IF sy-subrc = 0.
551    **      p_vari = gx_variant-variant.
552    *        ENDIF.
553
554
555      CALL FUNCTION 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'
556        EXPORTING
557          i_callback_program = g_repid
558    *     I_CALLBACK_PF_STATUS_SET = ' '
559    *     I_CALLBACK_USER_COMMAND  = ' '
560    *     is_layout          = gs_layout
561          it_fieldcat        = gt_fieldcat[]
562    *     IT_EXCLUDING       =
563    *     it_special_groups  = gt_sp_group[]
564    *     IT_SORT            =
565    *     IT_FILTER          =
566    *     IS_SEL_HIDE        =
567    *     I_SCREEN_START_COLUMN    = 0
568    *     I_SCREEN_START_LINE      = 0
569    *     I_SCREEN_END_COLUMN      = 0
570    *     I_SCREEN_END_LINE  = 0
571    *     i_default          = g_default
572          i_save             = g_save
573    *     is_variant         = g_variant
574          it_events          = gt_events_h[]
575    *     IT_EVENT_EXIT      =
576          i_tabname_header   = g_tabname_header
577          i_tabname_item     = g_tabname_item
578          is_keyinfo         = gs_keyinfo
579    *     IS_PRINT           =
580    *      IMPORTING
581    *     E_EXIT_CAUSED_BY_CALLER  =
582        TABLES
583          t_outtab_header    = ist_zhseair
584          t_outtab_item      = ist_zhseair_d.
585
586    ENDFORM.                    " call_func_reuse_alv_list_disp
587    *&---------------------------------------------------------------------*
588    *&      Form  freeitab
589    *&---------------------------------------------------------------------*
590    *       text
591    *----------------------------------------------------------------------*
592    *  -->  p1        text
593    *  <--  p2        text
594    *----------------------------------------------------------------------*
595    FORM freeitab.
596
597    ENDFORM.                    " freeitab
598    *&---------------------------------------------------------------------*
599    *&      Form  help_WERKS
600    *&---------------------------------------------------------------------*
601    *       text
602    *----------------------------------------------------------------------*
603    *  -->  p1        text
604    *  <--  p2        text
605    *----------------------------------------------------------------------*
606    FORM help_werks.
607      DATA: wa_tplnr  TYPE zhseair_h,
608            ist_tplnr LIKE STANDARD TABLE OF zhseair_h.
609
610      SELECT werks tplnr dpr_dt docno  FROM zhseair_h
611                      INTO  CORRESPONDING  FIELDS  OF  TABLE  ist_tplnr.
612
613      IF  sy-subrc  EQ  0.
614
615        CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
616          EXPORTING
617            retfield        = 'WERKS'
618            dynpprog        = 'ZPM_AMBIENT_AIR_NEW'
619            dynpnr          = sy-dynnr
620            dynprofield     = 'WERKS'
621            value_org       = 'S'
622          TABLES
623            value_tab       = ist_tplnr
624            return_tab      = ist_return_tab
625          EXCEPTIONS
626            parameter_error = 1
627            no_values_found = 2
628            OTHERS          = 3.
629
630        IF sy-subrc <> 0.
631
632          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
633                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
634
635        ENDIF.
636      ENDIF.
637
638    ENDFORM.                    " help_WERKS
639
640
641    *&---------------------------------------------------------------------*
642    *&      Form  fill_header
643    *&---------------------------------------------------------------------*
644    *       text
645    *----------------------------------------------------------------------*
646    *      -->P_GT_LIST_TOP_OF_PAGE[]  text
647    *----------------------------------------------------------------------*
648    FORM fill_header." USING gt_list_top_of_page[].
649
650      DATA: ls_line TYPE slis_listheader.
651
652      CLEAR gt_list_top_of_page.
653      CLEAR ls_line.
654      ls_line-typ  = 'H'.
655      ls_line-info = text-019.
656      APPEND ls_line TO gt_list_top_of_page.
657
658    ENDFORM.                    " fill_header
659    *&---------------------------------------------------------------------*
660    *&      Form  fill_footer
661    *&---------------------------------------------------------------------*
662    *       text
663    *----------------------------------------------------------------------*
664    *      -->P_GT_LIST_END_OF_LIST[]  text
665    *----------------------------------------------------------------------*
666    FORM fill_footer ."USING gt_list_end_of_list[].
667
668      DATA: ls_line TYPE slis_listheader.
669
670      DATA: l_text(50)   TYPE c.
671      DATA: l_date(10)   TYPE c.
672
673      CLEAR gt_list_end_of_list.
674      CLEAR ls_line.
675      ls_line-typ  = 'S'.
676      ls_line-key  = text-020.
677      ls_line-info = sy-uname.
678      APPEND ls_line TO gt_list_end_of_list.
679
680      WRITE sy-datum TO l_date  DD/MM/YYYY.
681
682      CLEAR ls_line.
683      ls_line-typ  = 'S'.
684      ls_line-key  = text-021.
685      ls_line-info = l_date.
686      APPEND ls_line TO gt_list_end_of_list.
687
688    ENDFORM.                    " fill_footer
689    *&---------------------------------------------------------------------*
690    *&      Form  HELP_BUNIT
691    *&---------------------------------------------------------------------*
692    *       text
693    *----------------------------------------------------------------------*
694    *  -->  p1        text
695    *  <--  p2        text
696    *----------------------------------------------------------------------*
697    FORM help_bunit .
698
699      TYPES: BEGIN OF lt_acc_bu,
700               bunit  TYPE zbunit_d,
701               bu_txt	TYPE pltxt,
702             END OF lt_acc_bu.
703
704      DATA: it_return_bu  LIKE STANDARD TABLE OF ddshretval,
705            gwa_return_bu LIKE ddshretval.
706      DATA  :  ist_return_tab LIKE STANDARD TABLE OF ddshretval
707                                                 WITH  HEADER LINE.
708      DATA: lit_acc_bu TYPE STANDARD TABLE OF lt_acc_bu,
709            lwa_acc_bu TYPE lt_acc_bu.
710
711      DATA: lit_bu_fcat TYPE slis_t_fieldcat_alv,
712            lwa_bu_fcat TYPE slis_fieldcat_alv.
713
714      DATA:  ls_tabix_bu TYPE slis_selfield,
715             lv_row_bu   TYPE i.
716      DATA: i_selfield TYPE slis_selfield.
717
718    *  DATA : ist_return_tab      LIKE STANDARD TABLE OF ddshretval
719    *                             WITH  HEADER LINE.
720
721      REFRESH: it_return_bu,lit_bu_fcat, lit_acc_bu.
722      CLEAR: ist_return_tab, ls_tabix_bu,lv_row_bu.
723
724
725      lwa_bu_fcat-fieldname  = 'BUNIT'.    " Fieldname in the data table
726      lwa_bu_fcat-seltext_m  = 'Business Unit'.    " Column description in the output
727      APPEND lwa_bu_fcat TO lit_bu_fcat.
728      CLEAR lwa_bu_fcat.
729
730      lwa_bu_fcat-fieldname  = 'BU_TXT'.    " Fieldname in the data table
731      lwa_bu_fcat-seltext_l  = 'Description'.    " Column description in the output
732      lwa_bu_fcat-outputlen = 32.
733      APPEND lwa_bu_fcat TO lit_bu_fcat.
734      CLEAR lwa_bu_fcat.
735
736
737      SELECT * FROM zohse_eff_ep INTO CORRESPONDING FIELDS OF TABLE lit_acc_bu.
738      IF lit_acc_bu IS NOT INITIAL..
739        LOOP AT lit_acc_bu INTO lwa_acc_bu.
740
741    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
742    *      SELECT SINGLE pltxt FROM iflotx INTO lwa_acc_bu-bu_txt WHERE tplnr = lwa_acc_bu-bunit.
743     SELECT PLTXT FROM IFLOTX   UP TO 1 ROWS INTO LWA_ACC_BU-BU_TXT WHERE
744    TPLNR = LWA_ACC_BU-BUNIT  ORDER BY  TPLNR SPRAS .   ENDSELECT.
745    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
746          MODIFY lit_acc_bu FROM lwa_acc_bu TRANSPORTING bu_txt .
747          CLEAR lwa_acc_bu.
748        ENDLOOP.
749        " BREAK-POINT.
750    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
751    SORT LIT_ACC_BU BY BUNIT .
752    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
753        DELETE ADJACENT DUPLICATES FROM lit_acc_bu COMPARING bunit.
754
755
756        CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
757          EXPORTING
758            i_title       = 'Business Unit'
759            i_selection   = 'X'
760            i_zebra       = 'X'
761            i_tabname     = 'LIT_ACC_DOC'
762            it_fieldcat   = lit_bu_fcat
763          IMPORTING
764            es_selfield   = i_selfield
765          TABLES
766            t_outtab      = lit_acc_bu
767          EXCEPTIONS
768            program_error = 1
769            OTHERS        = 2.
770        IF i_selfield IS NOT INITIAL.
771    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
772          READ TABLE lit_acc_bu INTO lwa_acc_bu INDEX i_selfield-tabindex. "#EC CI_NOORDER
773    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
774          s_bunit-low = lwa_acc_bu-bunit.
775
776
777          CLEAR i_selfield.
778
779        ENDIF.
780
781
782      ENDIF.
783
784
785    ENDFORM.
786    *&---------------------------------------------------------------------*
787    *&      Form  HELP_BUNIT_HIG
788    *&---------------------------------------------------------------------*
789    *       text
790    *----------------------------------------------------------------------*
791    *  -->  p1        text
792    *  <--  p2        text
793    *----------------------------------------------------------------------*
794    FORM help_bunit_hig .
795
796      TYPES: BEGIN OF lt_acc_bu,
797               bunit  TYPE zbunit_d,
798               bu_txt	TYPE pltxt,
799             END OF lt_acc_bu.
800
801      DATA: it_return_bu  LIKE STANDARD TABLE OF ddshretval,
802            gwa_return_bu LIKE ddshretval.
803      DATA  :  ist_return_tab LIKE STANDARD TABLE OF ddshretval
804                                                 WITH  HEADER LINE.
805      DATA: lit_acc_bu TYPE STANDARD TABLE OF lt_acc_bu,
806            lwa_acc_bu TYPE lt_acc_bu.
807
808      DATA: lit_bu_fcat TYPE slis_t_fieldcat_alv,
809            lwa_bu_fcat TYPE slis_fieldcat_alv.
810
811      DATA:  ls_tabix_bu TYPE slis_selfield,
812             lv_row_bu   TYPE i.
813      DATA: i_selfield TYPE slis_selfield.
814
815    *  DATA : ist_return_tab      LIKE STANDARD TABLE OF ddshretval
816    *                             WITH  HEADER LINE.
817
818      REFRESH: it_return_bu,lit_bu_fcat, lit_acc_bu.
819      CLEAR: ist_return_tab, ls_tabix_bu,lv_row_bu.
820
821
822      lwa_bu_fcat-fieldname  = 'BUNIT'.    " Fieldname in the data table
823      lwa_bu_fcat-seltext_m  = 'Business Unit'.    " Column description in the output
824      APPEND lwa_bu_fcat TO lit_bu_fcat.
825      CLEAR lwa_bu_fcat.
826
827      lwa_bu_fcat-fieldname  = 'BU_TXT'.    " Fieldname in the data table
828      lwa_bu_fcat-seltext_l  = 'Description'.    " Column description in the output
829      lwa_bu_fcat-outputlen = 32.
830      APPEND lwa_bu_fcat TO lit_bu_fcat.
831      CLEAR lwa_bu_fcat.
832
833
834      SELECT * FROM zohse_eff_ep INTO CORRESPONDING FIELDS OF TABLE lit_acc_bu.
835      IF lit_acc_bu IS NOT INITIAL..
836        LOOP AT lit_acc_bu INTO lwa_acc_bu.
837
838    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
839    *      SELECT SINGLE pltxt FROM iflotx INTO lwa_acc_bu-bu_txt WHERE tplnr = lwa_acc_bu-bunit.
840     SELECT PLTXT FROM IFLOTX   UP TO 1 ROWS INTO LWA_ACC_BU-BU_TXT WHERE
841    TPLNR = LWA_ACC_BU-BUNIT  ORDER BY  TPLNR SPRAS .   ENDSELECT.
842    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
843          MODIFY lit_acc_bu FROM lwa_acc_bu TRANSPORTING bu_txt .
844          CLEAR lwa_acc_bu.
845        ENDLOOP.
846        " BREAK-POINT.
847    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
848    SORT LIT_ACC_BU BY BUNIT .
849    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
850        DELETE ADJACENT DUPLICATES FROM lit_acc_bu COMPARING bunit.
851
852
853        CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
854          EXPORTING
855            i_title       = 'Business Unit'
856            i_selection   = 'X'
857            i_zebra       = 'X'
858            i_tabname     = 'LIT_ACC_DOC'
859            it_fieldcat   = lit_bu_fcat
860          IMPORTING
861            es_selfield   = i_selfield
862          TABLES
863            t_outtab      = lit_acc_bu
864          EXCEPTIONS
865            program_error = 1
866            OTHERS        = 2.
867        IF i_selfield IS NOT INITIAL.
868    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
869          READ TABLE lit_acc_bu INTO lwa_acc_bu INDEX i_selfield-tabindex. "#EC CI_NOORDER
870    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
871          s_bunit-high = lwa_acc_bu-bunit.
872
873
874          CLEAR i_selfield.
875
876        ENDIF.
877
878
879      ENDIF.
880
881
882    ENDFORM.
883    *&---------------------------------------------------------------------*
884    *&      Form  HELP_PRJ_LOW
885    *&---------------------------------------------------------------------*
886    *       text
887    *----------------------------------------------------------------------*
888    *  -->  p1        text
889    *  <--  p2        text
890    *----------------------------------------------------------------------*
891    FORM help_prj_low .
892      TYPES: BEGIN OF lt_acc_proj,
893               proj     TYPE tplnr,
894               proj_txt TYPE pltxt,
895             END OF lt_acc_proj.
896
897      DATA: it_return_proj  LIKE STANDARD TABLE OF ddshretval,
898            gwa_return_proj LIKE ddshretval,
899
900            fl1(18)         TYPE c,
901            fl2(18)         TYPE c,
902            fl3(18)         TYPE c,
903            lv_cont(50)     TYPE c.
904
905      DATA: lit_acc_proj TYPE STANDARD TABLE OF lt_acc_proj,
906            lwa_acc_proj TYPE lt_acc_proj.
907
908      DATA:  ls_tabix_proh TYPE slis_selfield,
909             lv_row_proj   TYPE i.
910      DATA: dynfields TYPE TABLE OF dynpread WITH HEADER LINE.
911      DATA: povstepl  LIKE  sy-stepl.
912      DATA: p_selfield TYPE slis_selfield.
913    *  DATA: dynfields TYPE TABLE OF dynpread WITH HEADER LINE.
914
915
916      DATA: lit_proj_fcat TYPE slis_t_fieldcat_alv,
917            lwa_proj_fcat TYPE slis_fieldcat_alv.
918      REFRESH: it_return_proj, lit_proj_fcat.
919      CLEAR: gwa_return_proj,lv_row_proj,lwa_proj_fcat,p_selfield.
920
921      lwa_proj_fcat-fieldname  = 'PROJ'.    " Fieldname in the data table
922      lwa_proj_fcat-seltext_m  = 'Project'.    " Column description in the output
923      APPEND lwa_proj_fcat TO lit_proj_fcat.
924      CLEAR lwa_proj_fcat.
925
926      lwa_proj_fcat-fieldname  = 'PROJ_TXT'.    " Fieldname in the data table
927      lwa_proj_fcat-seltext_l  = 'Description'.    " Column description in the output
928      lwa_proj_fcat-outputlen = 32.
929      APPEND lwa_proj_fcat TO lit_proj_fcat.
930      CLEAR lwa_proj_fcat.
931
932
933      SELECT proj
934             pltxt
935
936         FROM zohse_eff_ep INTO  TABLE lit_acc_proj WHERE bunit = s_bunit-low.
937      IF lit_acc_proj IS NOT INITIAL.
938    *    LOOP AT lit_acc_proj INTO lwa_acc_proj.
939    *      AUTHORITY-CHECK OBJECT 'ZOHSE_ACN1'
940    *              ID 'ACTVT' FIELD '01'
941    *              ID 'WERKS_A' FIELD zohse_accdt_n-werks
942    *              ID 'BUNIT_A' FIELD zohse_accdt_n-bunit
943    *              ID 'PROJ_A' FIELD lwa_acc_proj-proj.
944    *      IF sy-subrc EQ 0.
945    *        SELECT SINGLE pltxt FROM iflotx INTO lwa_acc_proj-proj_txt WHERE tplnr = lwa_acc_proj-proj.
946    *        MODIFY lit_acc_proj FROM lwa_acc_proj TRANSPORTING proj_txt .
947    *        CLEAR lwa_acc_proj.
948    *      ELSE.
949    *        DELETE lit_acc_proj INDEX sy-tabix.
950    *      ENDIF.
951    *    ENDLOOP.
952
953    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
954    SORT LIT_ACC_PROJ BY PROJ .
955    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
956        DELETE ADJACENT DUPLICATES FROM lit_acc_proj COMPARING proj.
957
958        CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
959          EXPORTING
960            i_title       = 'Project'
961            i_selection   = 'X'
962            i_zebra       = 'X'
963            i_tabname     = 'LIT_ACC_PROJ'
964            it_fieldcat   = lit_proj_fcat
965          IMPORTING
966            es_selfield   = p_selfield
967          TABLES
968            t_outtab      = lit_acc_proj
969          EXCEPTIONS
970            program_error = 1
971            OTHERS        = 2.
972        IF p_selfield IS NOT INITIAL.
973    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
974          READ TABLE lit_acc_proj INTO lwa_acc_proj INDEX p_selfield-tabindex. "#EC CI_NOORDER
975    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
976          s_proj-low = lwa_acc_proj-proj.
977    *      iflotx-pltxt = lwa_acc_proj-proj_txt.
978          CLEAR p_selfield.
979
980          REFRESH dynfields.
981          CLEAR:   dynfields,povstepl.
982
983          CALL FUNCTION 'DYNP_GET_STEPL'
984            IMPORTING
985              povstepl        = povstepl
986            EXCEPTIONS
987              stepl_not_found = 1
988              OTHERS          = 2.
989          IF sy-subrc <> 0.
990    * Implement suitable error handling here
991          ENDIF.
992
993
994          dynfields-fieldname = 'S_FUNLOC-LOW'.
995          dynfields-fieldvalue = s_proj-low.
996          dynfields-stepl      = povstepl.
997          APPEND dynfields.
998
999          CALL FUNCTION 'DYNP_VALUES_UPDATE'
1000           EXPORTING
1001             dyname     = sy-cprog
1002             dynumb     = sy-dynnr
1003           TABLES
1004             dynpfields = dynfields
1005           EXCEPTIONS
1006             OTHERS     = 8.
1007         COMMIT WORK AND WAIT.
1008
1009         REFRESH dynfields.
1010         CLEAR:   dynfields.
1011
1012         dynfields-fieldname = 'IFLOTX-PLTXT'.
1013   *      dynfields-fieldvalue = iflotx-pltxt.
1014         dynfields-stepl      = povstepl.
1015         APPEND dynfields.
1016
1017         CALL FUNCTION 'DYNP_VALUES_UPDATE'
1018           EXPORTING
1019             dyname     = sy-cprog
1020             dynumb     = sy-dynnr
1021           TABLES
1022             dynpfields = dynfields
1023           EXCEPTIONS
1024             OTHERS     = 8.
1025         COMMIT WORK AND WAIT.
1026
1027         SPLIT s_proj-low AT '-' INTO fl1 fl2 fl3.
1028
1029         CONCATENATE fl1 fl2 INTO lv_cont SEPARATED BY '-'.
1030
1031
1032         REFRESH dynfields.
1033         CLEAR:   dynfields.
1034
1035
1036       ENDIF.
1037     ENDIF.
1038
1039   ENDFORM.
1040   *&---------------------------------------------------------------------*
1041   *&      Form  HELP_PRJ_HIGH
1042   *&---------------------------------------------------------------------*
1043   *       text
1044   *----------------------------------------------------------------------*
1045   *  -->  p1        text
1046   *  <--  p2        text
1047   *----------------------------------------------------------------------*
1048   FORM help_prj_high .
1049     TYPES: BEGIN OF lt_acc_proj,
1050              proj     TYPE tplnr,
1051              proj_txt TYPE pltxt,
1052            END OF lt_acc_proj.
1053
1054     DATA: it_return_proj  LIKE STANDARD TABLE OF ddshretval,
1055           gwa_return_proj LIKE ddshretval,
1056
1057           fl1(18)         TYPE c,
1058           fl2(18)         TYPE c,
1059           fl3(18)         TYPE c,
1060           lv_cont(50)     TYPE c.
1061
1062     DATA: lit_acc_proj TYPE STANDARD TABLE OF lt_acc_proj,
1063           lwa_acc_proj TYPE lt_acc_proj.
1064
1065     DATA:  ls_tabix_proh TYPE slis_selfield,
1066            lv_row_proj   TYPE i.
1067     DATA: dynfields TYPE TABLE OF dynpread WITH HEADER LINE.
1068     DATA: povstepl  LIKE  sy-stepl.
1069     DATA: p_selfield TYPE slis_selfield.
1070   *  DATA: dynfields TYPE TABLE OF dynpread WITH HEADER LINE.
1071
1072
1073     DATA: lit_proj_fcat TYPE slis_t_fieldcat_alv,
1074           lwa_proj_fcat TYPE slis_fieldcat_alv.
1075     REFRESH: it_return_proj, lit_proj_fcat.
1076     CLEAR: gwa_return_proj,lv_row_proj,lwa_proj_fcat,p_selfield.
1077
1078     lwa_proj_fcat-fieldname  = 'PROJ'.    " Fieldname in the data table
1079     lwa_proj_fcat-seltext_m  = 'Project'.    " Column description in the output
1080     APPEND lwa_proj_fcat TO lit_proj_fcat.
1081     CLEAR lwa_proj_fcat.
1082
1083     lwa_proj_fcat-fieldname  = 'PROJ_TXT'.    " Fieldname in the data table
1084     lwa_proj_fcat-seltext_l  = 'Description'.    " Column description in the output
1085     lwa_proj_fcat-outputlen = 32.
1086     APPEND lwa_proj_fcat TO lit_proj_fcat.
1087     CLEAR lwa_proj_fcat.
1088
1089
1090     SELECT proj
1091            pltxt
1092
1093        FROM zohse_eff_ep INTO  TABLE lit_acc_proj WHERE bunit = s_bunit-high.
1094     IF lit_acc_proj IS NOT INITIAL.
1095   *    LOOP AT lit_acc_proj INTO lwa_acc_proj.
1096   *      AUTHORITY-CHECK OBJECT 'ZOHSE_ACN1'
1097   *              ID 'ACTVT' FIELD '01'
1098   *              ID 'WERKS_A' FIELD zohse_accdt_n-werks
1099   *              ID 'BUNIT_A' FIELD zohse_accdt_n-bunit
1100   *              ID 'PROJ_A' FIELD lwa_acc_proj-proj.
1101   *      IF sy-subrc EQ 0.
1102   *        SELECT SINGLE pltxt FROM iflotx INTO lwa_acc_proj-proj_txt WHERE tplnr = lwa_acc_proj-proj.
1103   *        MODIFY lit_acc_proj FROM lwa_acc_proj TRANSPORTING proj_txt .
1104   *        CLEAR lwa_acc_proj.
1105   *      ELSE.
1106   *        DELETE lit_acc_proj INDEX sy-tabix.
1107   *      ENDIF.
1108   *    ENDLOOP.
1109
1110   " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1111   SORT LIT_ACC_PROJ BY PROJ .
1112   " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1113       DELETE ADJACENT DUPLICATES FROM lit_acc_proj COMPARING proj.
1114
1115       CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
1116         EXPORTING
1117           i_title       = 'Project'
1118           i_selection   = 'X'
1119           i_zebra       = 'X'
1120           i_tabname     = 'LIT_ACC_PROJ'
1121           it_fieldcat   = lit_proj_fcat
1122         IMPORTING
1123           es_selfield   = p_selfield
1124         TABLES
1125           t_outtab      = lit_acc_proj
1126         EXCEPTIONS
1127           program_error = 1
1128           OTHERS        = 2.
1129       IF p_selfield IS NOT INITIAL.
1130   " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1131         READ TABLE lit_acc_proj INTO lwa_acc_proj INDEX p_selfield-tabindex. "#EC CI_NOORDER
1132   " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1133         s_proj-high = lwa_acc_proj-proj.
1134   *      iflotx-pltxt = lwa_acc_proj-proj_txt.
1135         CLEAR p_selfield.
1136
1137         REFRESH dynfields.
1138         CLEAR:   dynfields,povstepl.
1139
1140         CALL FUNCTION 'DYNP_GET_STEPL'
1141           IMPORTING
1142             povstepl        = povstepl
1143           EXCEPTIONS
1144             stepl_not_found = 1
1145             OTHERS          = 2.
1146         IF sy-subrc <> 0.
1147   * Implement suitable error handling here
1148         ENDIF.
1149
1150
1151         dynfields-fieldname = 'S_FUNLOC-LOW'.
1152         dynfields-fieldvalue = s_proj-high.
1153         dynfields-stepl      = povstepl.
1154         APPEND dynfields.
1155
1156         CALL FUNCTION 'DYNP_VALUES_UPDATE'
1157           EXPORTING
1158             dyname     = sy-cprog
1159             dynumb     = sy-dynnr
1160           TABLES
1161             dynpfields = dynfields
1162           EXCEPTIONS
1163             OTHERS     = 8.
1164         COMMIT WORK AND WAIT.
1165
1166         REFRESH dynfields.
1167         CLEAR:   dynfields.
1168
1169         dynfields-fieldname = 'IFLOTX-PLTXT'.
1170   *      dynfields-fieldvalue = iflotx-pltxt.
1171         dynfields-stepl      = povstepl.
1172         APPEND dynfields.
1173
1174         CALL FUNCTION 'DYNP_VALUES_UPDATE'
1175           EXPORTING
1176             dyname     = sy-cprog
1177             dynumb     = sy-dynnr
1178           TABLES
1179             dynpfields = dynfields
1180           EXCEPTIONS
1181             OTHERS     = 8.
1182         COMMIT WORK AND WAIT.
1183
1184         SPLIT s_proj-high AT '-' INTO fl1 fl2 fl3.
1185
1186         CONCATENATE fl1 fl2 INTO lv_cont SEPARATED BY '-'.
1187
1188
1189         REFRESH dynfields.
1190         CLEAR:   dynfields.
1191
1192
1193       ENDIF.
1194     ENDIF.
1195
1196   ENDFORM.
*--- End of ZPM_NOISE_LIST_NEW - 1196 lines ---

----------------------------------------------------------------------------------------------------
Include          ZPM_NOISE_LIST_NEW_TOP                    Level 1    Page 2
Object           ZPM_NOISE_LIST_NEW                        Lines 103
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:25
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
21     DATA : gt_events           TYPE slis_t_event,
22            gt_sort             TYPE slis_t_sortinfo_alv,
23            gs_layout           TYPE slis_layout_alv,
24            gt_list_top_of_page TYPE slis_t_listheader,
25            gt_list_end_of_list TYPE slis_t_listheader,
26            gt_fieldcat         TYPE slis_t_fieldcat_alv,
27            gt_fieldcat0        TYPE slis_t_fieldcat_alv,
28            gs_fieldcat         TYPE slis_fieldcat_alv,
29            gs_fieldcat0        TYPE slis_fieldcat_alv,
30            gs_extab            TYPE slis_t_extab,
31            ls_events           TYPE slis_alv_event OCCURS 0,
32            it_events           TYPE slis_alv_event.
33     DATA:  g_repid          TYPE sy-repid,
34            g_tabname_header TYPE slis_tabname,
35            g_tabname_item   TYPE slis_tabname,
36            gs_keyinfo       TYPE slis_keyinfo_alv,
37            g_save(1)        TYPE c,
38            l_matnr          TYPE mara-matnr.
39     DATA:  gt_events_h TYPE   slis_t_event,
40            gt_events_d TYPE   slis_t_event,
41            ls_event    TYPE   slis_alv_event.
42     DATA :e01_lt_fieldcat TYPE slis_t_fieldcat_alv.
43     DATA :e03_lt_events TYPE slis_t_event.
44     DATA : ist_floc_help TYPE STANDARD TABLE OF ty_floc_help,
45            wa_floc_help  TYPE ty_floc_help.
46     *---------------------------------------------------------------------*
47     *                Constants                                            *
48     *---------------------------------------------------------------------*
49     CONSTANTS gc_formname_top_of_page TYPE slis_formname VALUE
50      'TOP_OF_PAGE'.
51
52     *---------------------------------------------------------------------*
53     *        WORK AREA DECLRATION                                         *
54     *---------------------------------------------------------------------*
55
56     *DATA : l_tplnr TYPE itob-tplnr,
57     *       l_pltxt TYPE iflo-pltxt.
58
59
60     DATA: ist_return_tab TYPE STANDARD TABLE OF ddshretval WITH HEADER LINE.
61     *
62     *TYPES:  BEGIN OF ty_vbap .
63     *        INCLUDE STRUCTURE vbap.
64     *TYPES:  bukrs_vf TYPE vbak-bukrs_vf.
65     *TYPES:  vkorg TYPE vbak-vkorg.
66     *TYPES:  knumv TYPE vbak-knumv.
67     *TYPES: END OF ty_vbap.
68
69     TYPES: BEGIN OF ty_zhseair.
70             INCLUDE STRUCTURE zhseair_h.
71     TYPES:        name1 TYPE t001w-name1.
72     TYPES:        pltxt TYPE iflotx-pltxt.
73     TYPES  END   OF ty_zhseair.
74
75     TYPES: BEGIN OF ty_zhseair_d.
76             INCLUDE STRUCTURE zohse_noise_d.
77     TYPES  END   OF ty_zhseair_d.
78     ************************ Begin of code by avtar on 22.11.2016 **************
79     TYPES: BEGIN OF ty_final,
80              docno       TYPE zhseair_h-docno,
81              name1       TYPE t001w-name1,
82              bunit       TYPE zhseair_h-bunit,
83              bunit_d     TYPE char30,
84              porj        TYPE zhseair_h-porj,
85              max_limit   TYPE zohse_nse_lmt-max_limit,
86              porj_d      TYPE char50,
87              sampl_statn TYPE zohse_noise_d-sampl_statn,
88              n_level     TYPE zohse_noise_d-n_level,
89              due_date    TYPE zohse_noise_d-due_date,
90              samp_date   TYPE zhseair_h-dpr_dt,
91              pltxt       TYPE iflotx-pltxt,
92            END OF ty_final.
93
94     DATA: gt_final TYPE TABLE OF ty_final.
95
96     ************************ End of code by avtar on 22.11.2016 ***************
97
98     DATA : wa_zhseair TYPE ty_zhseair.
99     DATA: ist_zhseair TYPE STANDARD TABLE OF ty_zhseair.
100    DATA : wa_zhseair_d TYPE ty_zhseair_d.
101    DATA: ist_zhseair_d TYPE STANDARD TABLE OF ty_zhseair_d.
102    DATA  l_pltxt TYPE iflo-pltxt.
103    DATA: name1 TYPE t001w-name1.
*--- End of ZPM_NOISE_LIST_NEW_TOP - 103 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CSLIS                                   Level 1    Page 3
Object           ZPM_NOISE_LIST_NEW                        Lines 543
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:25
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
Object           ZPM_NOISE_LIST_NEW                        Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:25
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
Object           ZPM_NOISE_LIST_NEW                        Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:25
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
Object           ZPM_NOISE_LIST_NEW                        Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:25
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
Object           ZPM_NOISE_LIST_NEW                        Lines 1
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:25
----------------------------------------------------------------------------------------------------
1      * INCLUDE DB__SSEL
*--- End of DB__SSEL - 1 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CABAP                                   Level 1    Page 8
Object           ZPM_NOISE_LIST_NEW                        Lines 360
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:25
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
