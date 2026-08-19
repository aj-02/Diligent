----------------------------------------------------------------------------------------------------
Main program     ZPM_ILLUMINATION_LIST_NEW                 Level 0    Page 1
Object           ZPM_ILLUMINATION_LIST_NEW                 Lines 1025
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:23
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
26     INCLUDE zpm_illumination_list_new_top.
27     *INCLUDE ZPM_NOISE_LIST_NEW_TOP.
28     *INCLUDE zpm_ambient_list_new_top.
29     *INCLUDE zpm_ambient_list_top.
30
31     SELECTION-SCREEN BEGIN OF BLOCK emd WITH FRAME TITLE text-001.
32     ***CODE ADDED BY CAB_AMITMOZA ON 25.09.2012 TO INCLUDE F4 ELEMENT FOR S_WERKS*******
33     SELECT-OPTIONS:   s_werks FOR zhseair_h-werks MEMORY ID wrk NO INTERVALS NO-EXTENSION DEFAULT '90R1',
34     *******CODE END BY CAB_AMITMOZA*************
35     *                  s_tplnr FOR zhseair_h-tplnr ,
36                       s_bunit FOR zhseair_h-bunit,
37                       s_proj  FOR zhseair_h-porj,
38     *       s_tplnr FOR zhseair_h-tplnr MATCHCODE OBJECT zhse_eff_ep,
39                       s_date  FOR zhseair_h-dpr_dt.
40
41     SELECTION-SCREEN END OF BLOCK emd.
42     *---------------------------------------------------------------------*
43     *      END OF  INPUT   SELECTION SCREEN                               *
44     *---------------------------------------------------------------------*
45
46     *AT SELECTION-SCREEN .
47     *  PERFORM check_data .
48
49     *AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_werks-low.
50     *  PERFORM help_werks .
51     *
52     *AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_werks-high.
53     *  PERFORM help_werks .
54     *
55     *AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_tplnr-low.
56     *  PERFORM help_tplnr .
57
58     *AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_tplnr-high.
59     *  PERFORM help_tplnr .
60
61     AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_bunit-low.
62       PERFORM help_p_bunit  .
63
64     AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_bunit-high.
65       PERFORM help_p_bunit_high  .
66
67     AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_proj-low.
68       PERFORM help_s_proj .
69
70     AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_proj-high.
71       PERFORM help_s_proj_hig .
72
73     INITIALIZATION.
74       g_repid = sy-repid.
75
76     START-OF-SELECTION.
77       PERFORM fetch_inst_details.
78       PERFORM call_alv.
79
80     END-OF-SELECTION.
81
82     *&---------------------------------------------------------------------*
83     *&      Form  fetch_inst_details
84     *&---------------------------------------------------------------------*
85     *&  FETCH DATA FROM ZHSEAIR                                            *
86     *----------------------------------------------------------------------*
87     FORM fetch_inst_details.
88       REFRESH : ist_zhseair.
89       CLEAR   : wa_zhseair.
90
91       SELECT * FROM zhseair_h INTO CORRESPONDING FIELDS OF TABLE
92       ist_zhseair
93       WHERE werks IN s_werks
94       AND bunit IN s_bunit
95       AND porj IN s_proj"tplnr IN s_tplnr
96       AND dpr_dt IN s_date
97          AND znpi  EQ 'ILL'.
98
99       IF sy-subrc <> 0.
100        PERFORM callerr USING text-003.
101        STOP.
102      ELSE.
103
104        SELECT * FROM zohse_illum_d
105        INTO CORRESPONDING FIELDS OF TABLE ist_zhseair_d
106        FOR ALL ENTRIES IN ist_zhseair
107        WHERE docno = ist_zhseair-docno.
108
109        LOOP AT ist_zhseair INTO wa_zhseair.
110          CLEAR : name1, l_pltxt.
111          SELECT SINGLE name1 INTO name1 FROM t001w
112          WHERE werks = wa_zhseair-werks.
113          CONDENSE name1.
114          wa_zhseair-name1 = name1.
115    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
116    *      SELECT SINGLE pltxt INTO l_pltxt FROM iflotx
117    *      WHERE tplnr = wa_zhseair-tplnr.
118     SELECT PLTXT FROM IFLOTX   UP TO 1 ROWS INTO L_PLTXT WHERE TPLNR =
119    WA_ZHSEAIR-TPLNR  ORDER BY  TPLNR SPRAS .   ENDSELECT.
120    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
121          wa_zhseair-pltxt = l_pltxt.
122          MODIFY ist_zhseair FROM wa_zhseair TRANSPORTING name1 pltxt.
123
124        ENDLOOP.
125      ENDIF.
126      SORT ist_zhseair BY dpr_dt.
127
128    ENDFORM.                    " fetch_inst_details
129
130    *&---------------------------------------------------------------------*
131    *&      Form  callerr
132    *&---------------------------------------------------------------------*
133    *       text
134    *----------------------------------------------------------------------*
135    *      -->P_TEXT_003  text
136    *----------------------------------------------------------------------*
137    FORM callerr USING l_text.
138      MESSAGE: L_TEXT TYPE 'E'.
139    *  CALL FUNCTION 'FC_POPUP_ERR_WARN_MESSAGE'
140    *    EXPORTING
141    *      popup_title  = text-002
142    *      is_error     = 'X'
143    *      message_text = l_text
144    *      start_column = 30
145    *      start_row    = 8.
146      STOP.
147    ENDFORM.                    " callerr
148
149    *&---------------------------------------------------------------------*
150    *&      Form  check_calno
151    *&---------------------------------------------------------------------*
152    *       text
153    *----------------------------------------------------------------------*
154    *  -->  p1        text
155    *  <--  p2        text
156    *----------------------------------------------------------------------*
157    FORM check_data.
158
159    *  DATA: l_text TYPE string.
160    **  IF NOT P_WERKS IS INITIAL AND NOT P_TPLNR IS INITIAL
161    **  OR NOT P_DATE IS INITIAL.
162    *  CLEAR: p_tplnr, s_date.
163
164    *  SELECT SINGLE * FROM zhseair INTO CORRESPONDING FIELDS OF wa_zhseair
165    *  WHERE docno = p_docno.
166    *  IF sy-subrc <> 0.
167    *    l_text = 'data'.
168    *    MESSAGE e238(zpm) WITH l_text.
169    *    CLEAR l_text.
170    *  ENDIF.
171    *  p_werks = wa_zhseair-werks.
172    *  p_tplnr = wa_zhseair-tplnr.
173    *  p_date = wa_zhseair-sydate.
174    **  SELECT SINGLE * FROM zhseair INTO CORRESPONDING FIELDS OF wa_zhseair
175    **  WHERE werks = p_werks
176    **  AND tplnr = p_tplnr
177    **  AND sydate = p_date.
178    *
179
180    *  ENDIF.
181    ENDFORM.                    " check_calno
182    *&---------------------------------------------------------------------*
183    *&      Form  help_tplnr
184    *&---------------------------------------------------------------------*
185    *       text
186    *----------------------------------------------------------------------*
187    *  -->  p1        text
188    *  <--  p2        text
189    *----------------------------------------------------------------------*
190    FORM help_tplnr.
191      DATA: wa_tplnr  TYPE zhseair_h,
192            ist_tplnr LIKE STANDARD TABLE OF zhseair_h.
193      DATA : l_index TYPE sy-index,
194             l_werks TYPE zhseair_h-werks.
195      DATA : ist_dyfields LIKE dynpread OCCURS 1 WITH HEADER LINE.
196
197
198      ist_dyfields-fieldname = 'S_WERKS-LOW'.
199      APPEND ist_dyfields.
200
201      CALL FUNCTION 'DYNP_VALUES_READ'
202        EXPORTING
203          dyname     = sy-cprog
204          dynumb     = sy-dynnr
205        TABLES
206          dynpfields = ist_dyfields.
207
208      l_werks = ist_dyfields-fieldvalue.
209
210      IF NOT l_werks IS INITIAL.
211
212        SELECT werks tplnr from_dat to_dat FROM zhse_eff_ep
213            INTO CORRESPONDING FIELDS OF TABLE ist_floc_help
214               WHERE werks = l_werks.
215
216    * LOOP AT ist_tplnr into wa_tplnr.
217    *
218    *      l_index = sy-tabix.
219    *
220    *      IF ZHSE_ACCDT_N-INCDT_DATE GE wa_tplnr-FROM_DAT and
221    *         ZHSE_ACCDT_N-INCDT_DATE LE wa_tplnr-TO_DAT.
222    *
223    **    Do Nothing.
224    *
225    *      else.
226    *
227    *        DELETE ist_tplnr INDEX l_index.
228    *
229    *      endif.
230    *
231    *    ENDLOOP.
232
233        LOOP AT ist_floc_help INTO wa_floc_help.
234
235    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
236    *      SELECT SINGLE pltxt INTO wa_floc_help-pltxt FROM iflotx
237    *        WHERE tplnr = wa_floc_help-tplnr.
238     SELECT PLTXT FROM IFLOTX   UP TO 1 ROWS INTO WA_FLOC_HELP-PLTXT WHERE
239    TPLNR = WA_FLOC_HELP-TPLNR  ORDER BY  TPLNR SPRAS .   ENDSELECT.
240    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
241
242          IF sy-subrc = 0.
243            MODIFY ist_floc_help FROM wa_floc_help TRANSPORTING pltxt.
244          ENDIF.
245        ENDLOOP.
246
247        IF NOT ist_floc_help IS INITIAL.
248          CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
249            EXPORTING
250              retfield        = 'TPLNR'
251              dynpprog        = 'ZPM_AMBIENT_LIST_NEW'
252              dynpnr          = sy-dynnr
253              dynprofield     = 'S_TPLNR-LOW'
254              value_org       = 'S'
255            TABLES
256              value_tab       = ist_floc_help
257              return_tab      = ist_return_tab
258            EXCEPTIONS
259              parameter_error = 1
260              no_values_found = 2
261              OTHERS          = 3.
262
263          IF sy-subrc <> 0.
264
265            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
266                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
267
268          ENDIF.
269        ENDIF.
270      ENDIF.
271
272    *  IF ist_dyfields-fieldname = 'S_WERKS-LOW'.
273    *    s_tplnr-low =  ist_return_tab-fieldval.
274    *  ELSEIF ist_dyfields-fieldname = 'S_WERKS-HIGH'.
275    *    s_tplnr-high =  ist_return_tab-fieldval.
276    *  ENDIF.
277
278    *  SELECT werks tplnr dpr_dt docno  FROM zhseair_h
279    *                  INTO  CORRESPONDING  FIELDS  OF  TABLE  ist_tplnr.
280    *
281    *  IF  sy-subrc  EQ  0.
282    *
283    *    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
284    *         EXPORTING
285    *              retfield        = 'TPLNR'
286    *              dynpprog        = 'ZPM_AMBIENT_AIR_NEW'
287    *              dynpnr          = sy-dynnr
288    *              dynprofield     = 'TPLNR'
289    *              value_org       = 'S'
290    *         TABLES
291    *              value_tab       = ist_tplnr
292    *              return_tab      = ist_return_tab
293    *         EXCEPTIONS
294    *              parameter_error = 1
295    *              no_values_found = 2
296    *              OTHERS          = 3.
297    *
298    *    IF sy-subrc <> 0.
299    *
300    *      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
301    *              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
302    *
303    *    ENDIF.
304    *  ENDIF.
305
306    ENDFORM.                    " help_tplnr
307    *&---------------------------------------------------------------------*
308    *&      Form  call_ALV
309    *&---------------------------------------------------------------------*
310    *       text
311    *----------------------------------------------------------------------*
312    *  -->  p1        text
313    *  <--  p2        text
314    *----------------------------------------------------------------------*
315    FORM call_alv.
316    *  PERFORM event_get .
317      g_repid = sy-repid.
318      g_tabname_header = 'IST_ZHSEAIR'.
319      g_tabname_item   = 'IST_ZHSEAIR_D'.
320    * define keyinfo
321      CLEAR gs_keyinfo.
322      gs_keyinfo-header01 = 'DOCNO'.
323      gs_keyinfo-item01   = 'DOCNO'.
324
325      PERFORM list_events_h ."USING gt_events_h[].
326      PERFORM fill_header ."USING gt_list_top_of_page[].
327      PERFORM fill_footer ."USING gt_list_end_of_list[].
328
329      PERFORM e01_fieldcat_init  USING gt_fieldcat[].
330
331      PERFORM call_func_reuse_alv_list_disp.
332      PERFORM freeitab.
333
334    ENDFORM.                    " call_ALV
335    *&---------------------------------------------------------------------*
336    *&      Form  event_get
337    *&---------------------------------------------------------------------*
338    *       text
339    *----------------------------------------------------------------------*
340    *  -->  p1        text
341    *  <--  p2        text
342    *----------------------------------------------------------------------*
343    FORM event_get.
344      g_repid = sy-repid.
345      it_events-name = slis_ev_top_of_page.
346      it_events-form = 'OUTPUT_HEADER'.
347      APPEND it_events TO ls_events.
348      CLEAR it_events.
349
350    ENDFORM.                    " event_get
351    *&---------------------------------------------------------------------*
352    *&      Form  e01_fieldcat_init
353    *&---------------------------------------------------------------------*
354    *       text
355    *----------------------------------------------------------------------*
356    *      -->P_GT_FIELDCAT[]  text
357    *----------------------------------------------------------------------*
358    FORM e01_fieldcat_init USING e01_lt_fieldcat TYPE slis_t_fieldcat_alv.
359
360      REFRESH : gt_fieldcat.
361
362      CLEAR gs_fieldcat.
363      gs_fieldcat-tabname     = 'IST_ZHSEAIR'.
364      gs_fieldcat-fieldname   = 'DOCNO'.
365      gs_fieldcat-ref_tabname = 'ZHSEAIR'.
366      gs_fieldcat-seltext_m   = text-004.
367      gs_fieldcat-outputlen   = 11.
368      gs_fieldcat-fix_column  = 'X'.
369      gs_fieldcat-key             =  'X'.
370      APPEND gs_fieldcat TO e01_lt_fieldcat.
371
372      CLEAR gs_fieldcat.
373      gs_fieldcat-tabname     = 'IST_ZHSEAIR'.
374      gs_fieldcat-fieldname   = 'NAME1'.
375      gs_fieldcat-ref_tabname = 'IST_ZHSEAIR'.
376      gs_fieldcat-seltext_m   = text-006.
377      gs_fieldcat-outputlen   = 40.
378      gs_fieldcat-fix_column  = 'X'.
379      gs_fieldcat-key             =  'X'.
380      APPEND gs_fieldcat TO e01_lt_fieldcat.
381
382      CLEAR gs_fieldcat.
383      gs_fieldcat-tabname     = 'IST_ZHSEAIR'.
384      gs_fieldcat-fieldname   = 'PORJ'.
385      gs_fieldcat-ref_tabname = 'IST_ZHSEAIR'.
386      gs_fieldcat-seltext_m   = text-008.
387      gs_fieldcat-outputlen   = 40.
388      gs_fieldcat-key             =  'X'.
389      APPEND gs_fieldcat TO e01_lt_fieldcat.
390
391      CLEAR gs_fieldcat.
392      gs_fieldcat-tabname     = 'IST_ZHSEAIR'.
393      gs_fieldcat-fieldname   = 'BUNIT'.
394      gs_fieldcat-ref_tabname = 'IST_ZHSEAIR'.
395      gs_fieldcat-seltext_m   = text-027.
396      gs_fieldcat-outputlen   = 40.
397      gs_fieldcat-key             =  'X'.
398      APPEND gs_fieldcat TO e01_lt_fieldcat.
399
400
401      CLEAR gs_fieldcat.
402      gs_fieldcat-tabname     = 'IST_ZHSEAIR_D'.
403      gs_fieldcat-fieldname   = 'SAMPL_STATN'.
404      gs_fieldcat-ref_tabname = 'IST_ZHSEAIR_D'.
405      gs_fieldcat-seltext_m   = text-018.
406      gs_fieldcat-outputlen   = 16.
407    *  GS_fieldcat-key             =  'X'.
408    *  gs_fieldcat-fix_column  = 'X'.
409      APPEND gs_fieldcat TO e01_lt_fieldcat.
410
411
412      CLEAR gs_fieldcat.
413      gs_fieldcat-tabname     = 'IST_ZHSEAIR_D'.
414      gs_fieldcat-fieldname   = 'ILLUM'.
415      gs_fieldcat-ref_tabname = 'IST_ZHSEAIR_D'.
416      gs_fieldcat-seltext_m   = text-016.
417      gs_fieldcat-outputlen   = 12.
418    *  gs_fieldcat-fix_column  = 'X'.
419      gs_fieldcat-no_zero     = 'X'.
420      APPEND gs_fieldcat TO e01_lt_fieldcat.
421
422      CLEAR gs_fieldcat.
423      gs_fieldcat-tabname     = 'IST_ZHSEAIR_D'.
424      gs_fieldcat-fieldname   = 'DUE_DATE'.
425      gs_fieldcat-ref_tabname = 'IST_ZHSEAIR_D'.
426      gs_fieldcat-seltext_m   = text-023.
427      gs_fieldcat-outputlen   = 12.
428    *  gs_fieldcat-fix_column  = 'X'.
429      gs_fieldcat-no_zero     = 'X'.
430      APPEND gs_fieldcat TO e01_lt_fieldcat.
431
432    *CO
433
434
435    ENDFORM.                    " e01_fieldcat_init
436
437    *---------------------------------------------------------------------*
438    *       FORM top_of_page                                              *
439    *---------------------------------------------------------------------*
440    *       ........                                                      *
441    *---------------------------------------------------------------------*
442    FORM top_of_page.
443
444      CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
445        EXPORTING
446          it_list_commentary = gt_list_top_of_page
447          i_logo             = 'ZONGC'.
448
449    ENDFORM.
450
451    *---------------------------------------------------------------------*
452    *       FORM end_of_list                                              *
453    *---------------------------------------------------------------------*
454    *       ........                                                      *
455    *---------------------------------------------------------------------*
456    FORM end_of_list.
457
458      CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
459        EXPORTING
460          it_list_commentary = gt_list_end_of_list
461          i_end_of_list_grid = gt_list_end_of_list.
462
463    ENDFORM.
464
465    *&---------------------------------------------------------------------*
466    *&      Form  list_events_h
467    *&---------------------------------------------------------------------*
468    *       text
469    *----------------------------------------------------------------------*
470    *      -->P_GT_EVENTS_H[]  text
471    *----------------------------------------------------------------------*
472    FORM list_events_h ."USING e03_lt_events TYPE slis_t_event.
473      DATA : g_status_set  TYPE slis_formname VALUE 'PF_STATUS_SET',
474             g_top_of_page TYPE slis_formname VALUE 'TOP_OF_PAGE',
475             g_top_of_list TYPE slis_formname VALUE 'TOP_OF_LIST',
476             g_end_of_list TYPE slis_formname VALUE 'END_OF_LIST'.
477
478      CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
479        EXPORTING
480          i_list_type = 0
481        IMPORTING
482          et_events   = gt_events_h.
483
484      READ TABLE gt_events_h WITH KEY name =  slis_ev_top_of_page
485                               INTO ls_event.
486      IF sy-subrc = 0.
487        MOVE g_top_of_page TO ls_event-form.
488        APPEND ls_event TO gt_events_h.
489      ENDIF.
490      READ TABLE gt_events_h WITH KEY name =  slis_ev_end_of_list
491                                 INTO ls_event.
492      IF sy-subrc = 0.
493
494        MOVE g_end_of_list TO ls_event-form.
495        APPEND ls_event TO gt_events_h.
496      ENDIF.
497
498    *  READ TABLE gt_events_h WITH KEY name = slis_ev_user_command
499    *                           INTO ls_event.
500    *  IF sy-subrc = 0.
501    *    MOVE 'PROCESS_COMMAND' TO ls_event-form.
502    *    APPEND ls_event TO gt_events_h.
503    *  ENDIF.
504
505    ENDFORM.                    " list_events_det
506    *&---------------------------------------------------------------------*
507    *&      Form  call_func_reuse_alv_list_disp
508    *&---------------------------------------------------------------------*
509    *       text
510    *----------------------------------------------------------------------*
511    *  -->  p1        text
512    *  <--  p2        text
513    *----------------------------------------------------------------------*
514    FORM call_func_reuse_alv_list_disp.
515      g_repid = 'ZPM_ILLUMINATION_LIST_NEW'.
516    *  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
517    *       EXPORTING
518    *            i_callback_program = g_repid
519    *            it_fieldcat        = gt_fieldcat[]
520    *            it_events          = gt_events_h[]
521    *       TABLES
522    *            t_outtab           = ist_zhseair.
523    * Set Options: save variants userspecific or general
524      g_save = 'A'.
525    *        PERFORM variant_init.
526    ** Get default variant
527    **        gx_variant = g_variant.
528    *        CALL FUNCTION 'REUSE_ALV_VARIANT_DEFAULT_GET'
529    *             EXPORTING
530    *                  i_save     = g_save
531    *             CHANGING
532    *                  cs_variant = gx_variant
533    *             EXCEPTIONS
534    *                  not_found  = 2.
535    *        IF sy-subrc = 0.
536    **      p_vari = gx_variant-variant.
537    *        ENDIF.
538
539
540      CALL FUNCTION 'REUSE_ALV_HIERSEQ_LIST_DISPLAY'
541        EXPORTING
542          i_callback_program = g_repid
543    *     I_CALLBACK_PF_STATUS_SET = ' '
544    *     I_CALLBACK_USER_COMMAND  = ' '
545    *     is_layout          = gs_layout
546          it_fieldcat        = gt_fieldcat[]
547    *     IT_EXCLUDING       =
548    *     it_special_groups  = gt_sp_group[]
549    *     IT_SORT            =
550    *     IT_FILTER          =
551    *     IS_SEL_HIDE        =
552    *     I_SCREEN_START_COLUMN    = 0
553    *     I_SCREEN_START_LINE      = 0
554    *     I_SCREEN_END_COLUMN      = 0
555    *     I_SCREEN_END_LINE  = 0
556    *     i_default          = g_default
557          i_save             = g_save
558    *     is_variant         = g_variant
559          it_events          = gt_events_h[]
560    *     IT_EVENT_EXIT      =
561          i_tabname_header   = g_tabname_header
562          i_tabname_item     = g_tabname_item
563          is_keyinfo         = gs_keyinfo
564    *     IS_PRINT           =
565    *      IMPORTING
566    *     E_EXIT_CAUSED_BY_CALLER  =
567        TABLES
568          t_outtab_header    = ist_zhseair
569          t_outtab_item      = ist_zhseair_d.
570
571    ENDFORM.                    " call_func_reuse_alv_list_disp
572    *&---------------------------------------------------------------------*
573    *&      Form  freeitab
574    *&---------------------------------------------------------------------*
575    *       text
576    *----------------------------------------------------------------------*
577    *  -->  p1        text
578    *  <--  p2        text
579    *----------------------------------------------------------------------*
580    FORM freeitab.
581
582    ENDFORM.                    " freeitab
583    *&---------------------------------------------------------------------*
584    *&      Form  help_WERKS
585    *&---------------------------------------------------------------------*
586    *       text
587    *----------------------------------------------------------------------*
588    *  -->  p1        text
589    *  <--  p2        text
590    *----------------------------------------------------------------------*
591    FORM help_werks.
592      DATA: wa_tplnr  TYPE zhseair_h,
593            ist_tplnr LIKE STANDARD TABLE OF zhseair_h.
594
595      SELECT werks tplnr dpr_dt docno  FROM zhseair_h
596                      INTO  CORRESPONDING  FIELDS  OF  TABLE  ist_tplnr.
597
598      IF  sy-subrc  EQ  0.
599
600        CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
601          EXPORTING
602            retfield        = 'WERKS'
603            dynpprog        = 'ZPM_AMBIENT_AIR_NEW'
604            dynpnr          = sy-dynnr
605            dynprofield     = 'WERKS'
606            value_org       = 'S'
607          TABLES
608            value_tab       = ist_tplnr
609            return_tab      = ist_return_tab
610          EXCEPTIONS
611            parameter_error = 1
612            no_values_found = 2
613            OTHERS          = 3.
614
615        IF sy-subrc <> 0.
616
617          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
618                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
619
620        ENDIF.
621      ENDIF.
622
623    ENDFORM.                    " help_WERKS
624
625
626    *&---------------------------------------------------------------------*
627    *&      Form  fill_header
628    *&---------------------------------------------------------------------*
629    *       text
630    *----------------------------------------------------------------------*
631    *      -->P_GT_LIST_TOP_OF_PAGE[]  text
632    *----------------------------------------------------------------------*
633    FORM fill_header." USING gt_list_top_of_page[].
634
635      DATA: ls_line TYPE slis_listheader.
636
637      CLEAR gt_list_top_of_page.
638      CLEAR ls_line.
639      ls_line-typ  = 'H'.
640      ls_line-info = text-019.
641      APPEND ls_line TO gt_list_top_of_page.
642
643    ENDFORM.                    " fill_header
644    *&---------------------------------------------------------------------*
645    *&      Form  fill_footer
646    *&---------------------------------------------------------------------*
647    *       text
648    *----------------------------------------------------------------------*
649    *      -->P_GT_LIST_END_OF_LIST[]  text
650    *----------------------------------------------------------------------*
651    FORM fill_footer ."USING gt_list_end_of_list[].
652
653      DATA: ls_line TYPE slis_listheader.
654
655      DATA: l_text(50)   TYPE c.
656      DATA: l_date(10)   TYPE c.
657
658      CLEAR gt_list_end_of_list.
659      CLEAR ls_line.
660      ls_line-typ  = 'S'.
661      ls_line-key  = text-020.
662      ls_line-info = sy-uname.
663      APPEND ls_line TO gt_list_end_of_list.
664
665      WRITE sy-datum TO l_date  DD/MM/YYYY.
666
667      CLEAR ls_line.
668      ls_line-typ  = 'S'.
669      ls_line-key  = text-021.
670      ls_line-info = l_date.
671      APPEND ls_line TO gt_list_end_of_list.
672
673    ENDFORM.                    " fill_footer
674    *&---------------------------------------------------------------------*
675    *&      Form  HELP_P_BUNIT
676    *&---------------------------------------------------------------------*
677    *       text
678    *----------------------------------------------------------------------*
679    *  -->  p1        text
680    *  <--  p2        text
681    *----------------------------------------------------------------------*
682    FORM help_p_bunit .
683
684
685
686    *  DATA : ist_return_tab      LIKE STANDARD TABLE OF ddshretval
687    *                             WITH  HEADER LINE.
688
689      REFRESH: it_return_bu,lit_bu_fcat, lit_acc_bu.
690      CLEAR: ist_return_tab, ls_tabix_bu,lv_row_bu.
691
692
693      lwa_bu_fcat-fieldname  = 'BUNIT'.    " Fieldname in the data table
694      lwa_bu_fcat-seltext_m  = 'Business Unit'.    " Column description in the output
695      APPEND lwa_bu_fcat TO lit_bu_fcat.
696      CLEAR lwa_bu_fcat.
697
698      lwa_bu_fcat-fieldname  = 'BU_TXT'.    " Fieldname in the data table
699      lwa_bu_fcat-seltext_l  = 'Description'.    " Column description in the output
700      lwa_bu_fcat-outputlen = 32.
701      APPEND lwa_bu_fcat TO lit_bu_fcat.
702      CLEAR lwa_bu_fcat.
703
704
705      SELECT * FROM zohse_eff_ep INTO CORRESPONDING FIELDS OF TABLE lit_acc_bu.
706      IF lit_acc_bu IS NOT INITIAL..
707        LOOP AT lit_acc_bu INTO lwa_acc_bu.
708
709    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
710    *      SELECT SINGLE pltxt FROM iflotx INTO lwa_acc_bu-bu_txt WHERE tplnr = lwa_acc_bu-bunit.
711     SELECT PLTXT FROM IFLOTX   UP TO 1 ROWS INTO LWA_ACC_BU-BU_TXT WHERE
712    TPLNR = LWA_ACC_BU-BUNIT  ORDER BY  TPLNR SPRAS .   ENDSELECT.
713    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
714          MODIFY lit_acc_bu FROM lwa_acc_bu TRANSPORTING bu_txt .
715          CLEAR lwa_acc_bu.
716        ENDLOOP.
717        " BREAK-POINT.
718    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
719    SORT LIT_ACC_BU BY BUNIT .
720    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
721        DELETE ADJACENT DUPLICATES FROM lit_acc_bu COMPARING bunit.
722
723
724        CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
725          EXPORTING
726            i_title       = 'Business Unit'
727            i_selection   = 'X'
728            i_zebra       = 'X'
729            i_tabname     = 'LIT_ACC_DOC'
730            it_fieldcat   = lit_bu_fcat
731          IMPORTING
732            es_selfield   = i_selfield
733          TABLES
734            t_outtab      = lit_acc_bu
735          EXCEPTIONS
736            program_error = 1
737            OTHERS        = 2.
738        IF i_selfield IS NOT INITIAL.
739    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
740          READ TABLE lit_acc_bu INTO lwa_acc_bu INDEX i_selfield-tabindex. "#EC CI_NOORDER
741    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
742          s_bunit-low = lwa_acc_bu-bunit.
743
744
745          CLEAR i_selfield.
746
747        ENDIF.
748
749
750      ENDIF.
751
752    ENDFORM.
753    *&---------------------------------------------------------------------*
754    *&      Form  HELP_S_PROJ
755    *&---------------------------------------------------------------------*
756    *       text
757    *----------------------------------------------------------------------*
758    *  -->  p1        text
759    *  <--  p2        text
760    *----------------------------------------------------------------------*
761    FORM help_s_proj .
762      TYPES: BEGIN OF lt_acc_proj,
763               proj_txt TYPE pltxt,
764               proj     TYPE tplnr,
765
766             END OF lt_acc_proj.
767      DATA: lit_acc_proj TYPE STANDARD TABLE OF lt_acc_proj,
768            lwa_acc_proj TYPE lt_acc_proj.
769
770      DATA : lt_project      TYPE TABLE OF zohse_eff_ep,
771             ls_project      TYPE zohse_eff_ep,
772             lt_text         TYPE TABLE OF iflotx,
773             lit_return_proj TYPE TABLE OF ddshretval,
774             ls_text         TYPE  iflotx.
775
776      DATA : "lt_read    TYPE STANDARD TABLE OF dynpread,
777    *         ls_read    TYPE dynpread,
778             ls_read_rb TYPE dynpread.
779
780      gls_read-fieldname = 'S_BUNIT-LOW'.  "p_case s_bunit-low
781      APPEND gls_read TO glt_read.
782
783      CALL FUNCTION 'DYNP_VALUES_READ'
784        EXPORTING
785          dyname               = sy-cprog
786          dynumb               = sy-dynnr
787        TABLES
788          dynpfields           = glt_read
789        EXCEPTIONS
790          invalid_abapworkarea = 1
791          invalid_dynprofield  = 2
792          invalid_dynproname   = 3
793          invalid_dynpronummer = 4
794          invalid_request      = 5
795          no_fielddescription  = 6
796          invalid_parameter    = 7
797          undefind_error       = 8
798          double_conversion    = 9
799          stepl_not_found      = 10
800          OTHERS               = 11.
801      IF sy-subrc <> 0.
802    * Implement suitable error handling here
803      ENDIF.
804
805      READ TABLE glt_read INTO gls_read INDEX 1.
806
807      SELECT * FROM zohse_eff_ep INTO TABLE lt_project
808           WHERE bunit = gls_read-fieldvalue.
809
810      IF sy-subrc = 0.
811
812        SELECT * FROM iflotx INTO TABLE lt_text
813          FOR ALL ENTRIES IN lt_project
814          WHERE tplnr = lt_project-bunit.
815
816
817
818
819        LOOP AT lt_project INTO ls_project.
820
821
822          lwa_acc_proj-proj = ls_project-proj.
823
824          READ TABLE lt_text INTO ls_text WITH KEY tplnr = ls_project-bunit.
825
826          IF sy-subrc = 0.
827            lwa_acc_proj-proj_txt = ls_text-pltxt.
828          ENDIF.
829          APPEND lwa_acc_proj TO lit_acc_proj.
830        ENDLOOP.
831
832        CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
833          EXPORTING
834            retfield         = 'PROJ' "'FUNC_LOC'
835            dynpprog         = sy-repid
836            dynpnr           = sy-dynnr
837            dynprofield      = 'S_PROJ-LOW' "s_docno
838            value_org        = 'S'
839            callback_program = sy-repid
840          TABLES
841            value_tab        = lit_acc_proj
842            return_tab       = lit_return_proj
843          EXCEPTIONS
844            parameter_error  = 1
845            no_values_found  = 2
846            OTHERS           = 3.
847        IF sy-subrc <> 0.
848    * Implement suitable error handling here
849        ENDIF.
850      ENDIF.
851
852    ENDFORM.
853    *&---------------------------------------------------------------------*
854    *&      Form  HELP_P_BUNIT_HIGH
855    *&---------------------------------------------------------------------*
856    *       text
857    *----------------------------------------------------------------------*
858    *  -->  p1        text
859    *  <--  p2        text
860    *----------------------------------------------------------------------*
861    FORM help_p_bunit_high .
862      REFRESH: it_return_bu,lit_bu_fcat, lit_acc_bu.
863      CLEAR: ist_return_tab, ls_tabix_bu,lv_row_bu.
864
865
866      lwa_bu_fcat-fieldname  = 'BUNIT'.    " Fieldname in the data table
867      lwa_bu_fcat-seltext_m  = 'Business Unit'.    " Column description in the output
868      APPEND lwa_bu_fcat TO lit_bu_fcat.
869      CLEAR lwa_bu_fcat.
870
871      lwa_bu_fcat-fieldname  = 'BU_TXT'.    " Fieldname in the data table
872      lwa_bu_fcat-seltext_l  = 'Description'.    " Column description in the output
873      lwa_bu_fcat-outputlen = 32.
874      APPEND lwa_bu_fcat TO lit_bu_fcat.
875      CLEAR lwa_bu_fcat.
876
877
878      SELECT * FROM zohse_eff_ep INTO CORRESPONDING FIELDS OF TABLE lit_acc_bu.
879      IF lit_acc_bu IS NOT INITIAL..
880        LOOP AT lit_acc_bu INTO lwa_acc_bu.
881
882    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
883    *      SELECT SINGLE pltxt FROM iflotx INTO lwa_acc_bu-bu_txt WHERE tplnr = lwa_acc_bu-bunit.
884     SELECT PLTXT FROM IFLOTX   UP TO 1 ROWS INTO LWA_ACC_BU-BU_TXT WHERE
885    TPLNR = LWA_ACC_BU-BUNIT  ORDER BY  TPLNR SPRAS .   ENDSELECT.
886    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
887          MODIFY lit_acc_bu FROM lwa_acc_bu TRANSPORTING bu_txt .
888          CLEAR lwa_acc_bu.
889        ENDLOOP.
890        " BREAK-POINT.
891    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
892    SORT LIT_ACC_BU BY BUNIT .
893    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
894        DELETE ADJACENT DUPLICATES FROM lit_acc_bu COMPARING bunit.
895
896
897        CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
898          EXPORTING
899            i_title       = 'Business Unit'
900            i_selection   = 'X'
901            i_zebra       = 'X'
902            i_tabname     = 'LIT_ACC_DOC'
903            it_fieldcat   = lit_bu_fcat
904          IMPORTING
905            es_selfield   = i_selfield
906          TABLES
907            t_outtab      = lit_acc_bu
908          EXCEPTIONS
909            program_error = 1
910            OTHERS        = 2.
911        IF i_selfield IS NOT INITIAL.
912    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
913          READ TABLE lit_acc_bu INTO lwa_acc_bu INDEX i_selfield-tabindex. "#EC CI_NOORDER
914    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
915          s_bunit-high = lwa_acc_bu-bunit.
916
917
918          CLEAR i_selfield.
919
920        ENDIF.
921
922
923      ENDIF.
924
925    ENDFORM.
926    *&---------------------------------------------------------------------*
927    *&      Form  HELP_S_PROJ_HIG
928    *&---------------------------------------------------------------------*
929    *       text
930    *----------------------------------------------------------------------*
931    *  -->  p1        text
932    *  <--  p2        text
933    *----------------------------------------------------------------------*
934    FORM help_s_proj_hig .
935      TYPES: BEGIN OF lt_acc_proj,
936               proj_txt TYPE pltxt,
937               proj     TYPE tplnr,
938
939             END OF lt_acc_proj.
940      DATA: lit_acc_proj TYPE STANDARD TABLE OF lt_acc_proj,
941            lwa_acc_proj TYPE lt_acc_proj.
942
943      DATA : lt_project      TYPE TABLE OF zohse_eff_ep,
944             ls_project      TYPE zohse_eff_ep,
945             lt_text         TYPE TABLE OF iflotx,
946             lit_return_proj TYPE TABLE OF ddshretval,
947             ls_text         TYPE  iflotx.
948
949      DATA : "lt_read    TYPE STANDARD TABLE OF dynpread,
950    *         ls_read    TYPE dynpread,
951             ls_read_rb TYPE dynpread.
952
953      gls_read-fieldname = 'S_BUNIT-HIGH'.  "p_case s_bunit-low
954      APPEND gls_read TO glt_read.
955
956      CALL FUNCTION 'DYNP_VALUES_READ'
957        EXPORTING
958          dyname               = sy-cprog
959          dynumb               = sy-dynnr
960        TABLES
961          dynpfields           = glt_read
962        EXCEPTIONS
963          invalid_abapworkarea = 1
964          invalid_dynprofield  = 2
965          invalid_dynproname   = 3
966          invalid_dynpronummer = 4
967          invalid_request      = 5
968          no_fielddescription  = 6
969          invalid_parameter    = 7
970          undefind_error       = 8
971          double_conversion    = 9
972          stepl_not_found      = 10
973          OTHERS               = 11.
974      IF sy-subrc <> 0.
975    * Implement suitable error handling here
976      ENDIF.
977
978      READ TABLE glt_read INTO gls_read INDEX 1.
979
980      SELECT * FROM zohse_eff_ep INTO TABLE lt_project
981           WHERE bunit = gls_read-fieldvalue.
982
983      IF sy-subrc = 0.
984
985        SELECT * FROM iflotx INTO TABLE lt_text
986          FOR ALL ENTRIES IN lt_project
987          WHERE tplnr = lt_project-bunit.
988
989
990
991
992        LOOP AT lt_project INTO ls_project.
993
994
995          lwa_acc_proj-proj = ls_project-proj.
996
997          READ TABLE lt_text INTO ls_text WITH KEY tplnr = ls_project-bunit.
998
999          IF sy-subrc = 0.
1000           lwa_acc_proj-proj_txt = ls_text-pltxt.
1001         ENDIF.
1002         APPEND lwa_acc_proj TO lit_acc_proj.
1003       ENDLOOP.
1004
1005       CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
1006         EXPORTING
1007           retfield         = 'PROJ' "'FUNC_LOC'
1008           dynpprog         = sy-repid
1009           dynpnr           = sy-dynnr
1010           dynprofield      = 'S_PROJ-HIGH' "s_docno
1011           value_org        = 'S'
1012           callback_program = sy-repid
1013         TABLES
1014           value_tab        = lit_acc_proj
1015           return_tab       = lit_return_proj
1016         EXCEPTIONS
1017           parameter_error  = 1
1018           no_values_found  = 2
1019           OTHERS           = 3.
1020       IF sy-subrc <> 0.
1021   * Implement suitable error handling here
1022       ENDIF.
1023     ENDIF.
1024
1025   ENDFORM.
*--- End of ZPM_ILLUMINATION_LIST_NEW - 1025 lines ---

----------------------------------------------------------------------------------------------------
Include          ZPM_ILLUMINATION_LIST_NEW_TOP             Level 1    Page 2
Object           ZPM_ILLUMINATION_LIST_NEW                 Lines 121
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:23
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
33     TYPES: BEGIN OF lt_acc_bu,
34              bunit  TYPE zbunit_d,
35              bu_txt	TYPE pltxt,
36            END OF lt_acc_bu.
37
38     DATA: it_return_bu  LIKE STANDARD TABLE OF ddshretval,
39           gwa_return_bu LIKE ddshretval.
40     DATA  :  ist_return_tab LIKE STANDARD TABLE OF ddshretval
41                                                WITH  HEADER LINE.
42     DATA: lit_acc_bu TYPE STANDARD TABLE OF lt_acc_bu,
43           lwa_acc_bu TYPE lt_acc_bu.
44
45     DATA: lit_bu_fcat TYPE slis_t_fieldcat_alv,
46           lwa_bu_fcat TYPE slis_fieldcat_alv.
47
48     DATA:  ls_tabix_bu TYPE slis_selfield,
49            lv_row_bu   TYPE i.
50     DATA: i_selfield TYPE slis_selfield.
51     DATA:  g_repid          TYPE sy-repid,
52            g_tabname_header TYPE slis_tabname,
53            g_tabname_item   TYPE slis_tabname,
54            gs_keyinfo       TYPE slis_keyinfo_alv,
55            g_save(1)        TYPE c,
56            l_matnr          TYPE mara-matnr.
57     DATA:  gt_events_h TYPE   slis_t_event,
58            gt_events_d TYPE   slis_t_event,
59            ls_event    TYPE   slis_alv_event.
60     DATA :e01_lt_fieldcat TYPE slis_t_fieldcat_alv.
61     DATA :e03_lt_events TYPE slis_t_event.
62     DATA : ist_floc_help TYPE STANDARD TABLE OF ty_floc_help,
63            wa_floc_help  TYPE ty_floc_help.
64     DATA : glt_read TYPE STANDARD TABLE OF dynpread,
65            gls_read TYPE dynpread.
66     *---------------------------------------------------------------------*
67     *                Constants                                            *
68     *---------------------------------------------------------------------*
69     CONSTANTS gc_formname_top_of_page TYPE slis_formname VALUE
70      'TOP_OF_PAGE'.
71
72     *---------------------------------------------------------------------*
73     *        WORK AREA DECLRATION                                         *
74     *---------------------------------------------------------------------*
75
76     *DATA : l_tplnr TYPE itob-tplnr,
77     *       l_pltxt TYPE iflo-pltxt.
78
79
80     *DATA: ist_return_tab TYPE STANDARD TABLE OF ddshretval WITH HEADER LINE.
81     *
82     *TYPES:  BEGIN OF ty_vbap .
83     *        INCLUDE STRUCTURE vbap.
84     *TYPES:  bukrs_vf TYPE vbak-bukrs_vf.
85     *TYPES:  vkorg TYPE vbak-vkorg.
86     *TYPES:  knumv TYPE vbak-knumv.
87     *TYPES: END OF ty_vbap.
88
89     TYPES: BEGIN OF ty_zhseair.
90             INCLUDE STRUCTURE zhseair_h.
91     TYPES:        name1 TYPE t001w-name1.
92     TYPES:        pltxt TYPE iflotx-pltxt.
93     TYPES  END   OF ty_zhseair.
94
95     TYPES: BEGIN OF ty_zhseair_d.
96             INCLUDE STRUCTURE zohse_illum_d.
97     TYPES  END   OF ty_zhseair_d.
98     ************************ Begin of code by avtar on 22.11.2016 **************
99     TYPES: BEGIN OF ty_final,
100             docno       TYPE zhseair_h-docno,
101             name1       TYPE t001w-name1,
102             porj        TYPE zhseair_h-porj,
103             max_lmt     TYPE zohse_ill_lmt-max_limit,
104             porj_d      TYPE char50,
105             bunit       TYPE zhseair_h-bunit,
106             bunit_d     TYPE char50,
107             sampl_statn TYPE zohse_illum_d-sampl_statn,
108             illum       TYPE zohse_illum_d-illum,
109             due_date    TYPE zohse_illum_d-due_date,
110             samp_date   TYPE zhseair_h-dpr_dt,
111           END OF ty_final.
112
113    DATA: gt_final TYPE TABLE OF ty_final.
114    ************************ End of code by avtar on 22.11.2016 ***************
115
116    DATA : wa_zhseair TYPE ty_zhseair.
117    DATA: ist_zhseair TYPE STANDARD TABLE OF ty_zhseair.
118    DATA : wa_zhseair_d TYPE ty_zhseair_d.
119    DATA: ist_zhseair_d TYPE STANDARD TABLE OF ty_zhseair_d.
120    DATA  l_pltxt TYPE iflo-pltxt.
121    DATA: name1 TYPE t001w-name1.
*--- End of ZPM_ILLUMINATION_LIST_NEW_TOP - 121 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CSLIS                                   Level 1    Page 3
Object           ZPM_ILLUMINATION_LIST_NEW                 Lines 543
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:23
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
Object           ZPM_ILLUMINATION_LIST_NEW                 Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:23
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
Object           ZPM_ILLUMINATION_LIST_NEW                 Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:23
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
Object           ZPM_ILLUMINATION_LIST_NEW                 Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:23
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
Object           ZPM_ILLUMINATION_LIST_NEW                 Lines 1
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:23
----------------------------------------------------------------------------------------------------
1      * INCLUDE DB__SSEL
*--- End of DB__SSEL - 1 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CABAP                                   Level 1    Page 8
Object           ZPM_ILLUMINATION_LIST_NEW                 Lines 360
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:23
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
