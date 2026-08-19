----------------------------------------------------------------------------------------------------
Main program     ZFI_REP_BLOCK                             Level 0    Page 1
Object           ZFI_REP_BLOCK                             Lines 1545
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:29
----------------------------------------------------------------------------------------------------
1      report zfi_rep_block .
2
3      *-----  PROGRAM FOR Removing payment blocks 'X'  ****
4      ***********************************************************************
5      * Program    :  zfi_rep_block
6      *                                                                     *
7      *                                                                     *
8      * Author     : S.R.Sudha                     Date : 16.0 .2008
9      *
10     *                                                                     *
11     * Login Id   : CAB_SUDHA                                              *
12     *                                                                      *
13     * Description:Only for coreteam   purposes  for changing any payemnt *
14     *                 methods  when the need  arises
15     *  FS-no     : FS-FI-GL-41
16     *                                                                     *
17     * Tran.Code  : ZFIBLOCK
18     *
19     *                                                                     *
20     *----------------------------------------------------------------------*
21     ***********************************************************************
22     *Change History
23     *Date        ChID     Login        Description
24     *22.04.2008  +002     CAB_SUDHA    JV Cahs call Sp gl added-
25     *                                   Payment method added
26     *18.12.08         CAB_SUDHA    JV Cahs call Sp gl added-
27     *                                   Payment method added
28
29     ***********************************************************************
30
31     ************************************************************************
32     *  Date         Transport       USERID          Description
33     * 03/09/2008  <RD1K960036>    CAB_DAVINDER   1)Replacement of USING
34     *                                              Keyword with TABLES in
35     *                                              Form name eventtab_build
36     *                                              & comment_build.
37     *                                            2)Raising of Exception
38     *                                              'PROGRAM_ERROR' & its
39     *                                              handling in function
40     *                                              'REUSE_ALV_LIST_DISPLAY'.
41     ************************************************************************
42     *  Date         Transport   USERID          Description
43     * 19/12/2008  <RD1K960891> CAB_SUDHA Payment block for customers
44     * 25.02.09    cab_rama        FS-FI-AP-083_01 30000782    001
45     * 10.12.2009    RD1K967585  CAB_ALOK     CR30002778
46     *                                        Addition of INV REF in Report,
47     *                                        Creation of activity logs in separate Z table.
48     *26.03.2010   SAB_SUMAN                 CR 30003849      003
49     ************************************************************************
50
51     type-pools : slis.
52
53     tables : bsik, t001, bkpf , bsid .
54
55
56     data : ist_bsik  type table of bsik.
57     data : ist_bseg type table of  bseg.
58     data : wa_bsik  type bsik.
59     data : wa_bseg type  bseg.
60
61     data : y_doc_nos like zfi_docnos occurs 0 with header line .
62     data : f_doc_nos like zfi_docnos occurs 0 with header line .
63
64     data: begin of ist_bkpf occurs 0,
65           blart like bkpf-blart,
66           belnr like bkpf-belnr,
67           bldat like bkpf-bldat,
68           budat like bkpf-budat,
69           waers like bkpf-waers,
70           usnam like bkpf-usnam,
71           ppnam like bkpf-ppnam,
72           gjahr like bkpf-gjahr, "Added PN
73           bukrs like bkpf-bukrs,"Added PN
74           xref  like bkpf-xref1_hd,
75           end of ist_bkpf.
76
77     data : begin of ist_srcbsik occurs 0 ,
78            selcbox(1) type c,
79            lifnr like bsik-lifnr ,
80            umskz like bsik-umskz,
81            bukrs like bsik-bukrs ,
82            gjahr like bsik-gjahr,
83            belnr  like bsik-belnr,
84            buzei  like bsik-buzei,
85            budat  like bsik-budat,
86            bschl like bsik-bschl,
87            zlsch like bsik-zlsch,                               "+002
88            zlspr like  bsik-zlspr,
89            shkzg like bsik-shkzg,
90            gsber like  bsik-gsber,
91            dmbtr like bsik-dmbtr,
92            wrbtr like bsik-wrbtr,
93            kidno like  bsik-kidno,                              "+001
94     *Begin of <RD1K967585> CAB_ALOK 10.12.2009 CR30002778
95            rebzg LIKE bsik-rebzg,        " Invoice Ref.
96     *end of <RD1K967585> CAB_ALOK 10.12.2009 CR30002778
97            usnam  like bkpf-usnam,
98       xref1_hd like bkpf-xref1_hd.
99     *       include structure  bsis.
100    data:  end of ist_srcbsik .
101
102    data : wa_srcbsik like ist_srcbsik.
103    data : ist_bsiks like ist_srcbsik occurs 0 with header line.
104    *-----Start <RD1K960891>
105    data : begin of ist_srcbsid occurs 0 ,
106           selcbox(1) type c,
107           kunnr like bsid-kunnr ,
108           umskz like bsid-umskz,
109           bukrs like bsid-bukrs ,
110           gjahr like bsid-gjahr,
111           belnr  like bsid-belnr,
112           buzei  like bsid-buzei,
113           budat  like bsid-budat,
114           bschl like bsid-bschl,
115           zlsch like bsid-zlsch,
116           zlspr like  bsid-zlspr,
117           shkzg like bsid-shkzg,
118           gsber like  bsid-gsber,
119           dmbtr like bsid-dmbtr,
120           wrbtr like bsid-wrbtr,
121           kidno like  bsid-kidno,
122           usnam  like bkpf-usnam,
123    *Begin of <RD1K967585> CAB_ALOK 10.12.2009 CR30002778
124           rebzg LIKE bsid-rebzg,        " Invoice Ref.
125    *end of <RD1K967585> CAB_ALOK 10.12.2009 CR30002778
126      xref1_hd like bkpf-xref1_hd.
127    data:  end of ist_srcbsid .
128
129    data : wa_srcbsid like ist_srcbsid.
130    data : ist_bsids like ist_srcbsid occurs 0 with header line.
131    data : ist_bsid  type table of bsid.
132    data : wa_bsid  type bsid.
133    *-----End of <RD1K960891>
134
135    data : w_repid type sy-repid.
136
137    data:  is_layout  type  slis_layout_alv,
138           ist_fieldcat type  slis_fieldcat_alv  , "line.
139           ist_fcat type  table of slis_fieldcat_alv,
140            lt_sorttab type slis_t_sortinfo_alv,
141           ls_sorttab type slis_sortinfo_alv. " sort structure for ALV
142
143    data  : mpos type i .
144    data : gt_list_top_of_page type slis_t_listheader,
145           gt_list_end_of_list type slis_t_listheader,
146           gt_events   type slis_t_event.
147
148
149    selection-screen : begin of block  blk1  with frame title  text-001.
150
151    select-options : s_lifnr for bsik-lifnr ,      "+<RD1K960891>
152                     s_kunnr for bsid-kunnr ,      "+<RD1K960891>
153                     s_year  for bsik-gjahr obligatory,
154                     s_gsber for bsik-gsber,
155                     s_budat for bsik-budat,
156    *   Start of addition Prabu K on 06.07.2009
157                     s_xref1 for bkpf-xref1_hd.
158    *  End of addition Prabu K on 06.07.2009
159
160    parameters : p_bukrs like bsik-bukrs obligatory .
161
162    skip  2.
163
164    selection-screen : end of block blk1.
165
166    parameters : p_zlsprf   like bseg-zlspr,   " obligatory,     cfi_kasHYAP RD1K993183
167                 p_zlsprt   like bseg-zlspr.   " obligatory .    cfi_kasHYAP RD1K993183
168
169    * *Start of addition Prabu K on 07.07.2009
170    at selection-screen on value-request for s_xref1-low.
171      types : begin of ty_t526,
172              sachx type sachx,
173              werks type SBMOD,
174              end of ty_t526.
175
176      types: begin of ty_final,
177             bukrs type bukrs,
178             persa type persa,
179             sachx type sachx,
180             end of ty_final.
181      types: begin of ty_t5009,
182             persa type persa,
183             bukrs type bukrs,
184             end of ty_t5009.
185      data: lv_area type standard table of ty_t526 ,
186              wa_area LIKE LINE OF lv_area.
187
188      data: it_t5009 type standard table of ty_t5009 ,
189              wa_t5009 like line of  it_t5009.
190
191      data: it_final type standard table of ty_final ,
192              wa_final like line of  it_final.
193
194      select sachx werks from t526 into corresponding fields of table lv_area.  "#EC CI_NOORDER
195
196      sort lv_area by sachx.
197      delete adjacent duplicates from lv_area
198      comparing sachx.
199
200    *  select persa bukrs  from t500p into table it_t5009 for all entries
201    *                         in lv_area where persa = lv_area-sachx.
202
203    select persa bukrs  from t500p into CORRESPONDING FIELDS OF TABLE it_t5009.
204
205       sort it_t5009  by persa.
206      delete adjacent duplicates from it_t5009
207      comparing persa.
208
209      loop at lv_area into wa_area.
210
211        read table it_t5009 into wa_t5009 WITH KEY persa = wa_area-werks.
212        wa_final-sachx = wa_area-sachx.
213        wa_final-persa = wa_t5009-persa.
214        wa_final-bukrs = wa_t5009-bukrs.
215        append wa_final to it_final.
216      endloop.
217      call function 'F4IF_INT_TABLE_VALUE_REQUEST'
218        exporting
219          retfield        = 'SACHX'
220          dynpprog        = 'ZFI_REM_PYBLCK'
221          dynpnr          = sy-dynnr
222          dynprofield     = 'S_XREF1-LOW'
223          value_org       = 'S'
224        tables
225          value_tab       = it_final
226        exceptions
227          parameter_error = 1
228          no_values_found = 2
229          others          = 3.
230
231      if sy-subrc <> 0.
232    *
233    *    message id sy-msgid type sy-msgty number sy-msgno
234    *            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
235
236      endif.
237
238    at selection-screen on value-request for s_xref1-high.
239      types : begin of ty_t526,
240              sachx type sachx,
241              werks type SBMOD,
242              end of ty_t526.
243
244      types: begin of ty_final,
245             bukrs type bukrs,
246             persa type persa,
247             sachx type sachx,
248             end of ty_final.
249      types: begin of ty_t5009,
250             persa type persa,
251             bukrs type bukrs,
252             end of ty_t5009.
253      data: lv_area type standard table of ty_t526 ,
254              wa_area LIKE LINE OF lv_area.
255
256      data: it_t5009 type standard table of ty_t5009 ,
257              wa_t5009 like line of  it_t5009.
258
259      data: it_final type standard table of ty_final ,
260              wa_final like line of  it_final.
261
262      select sachx werks from t526 into corresponding fields of table lv_area.  "#EC CI_NOORDER
263
264      sort lv_area by sachx.
265      delete adjacent duplicates from lv_area
266      comparing sachx.
267
268    *  select persa bukrs  from t500p into table it_t5009 for all entries
269    *                         in lv_area where persa = lv_area-sachx.
270
271    select persa bukrs  from t500p into CORRESPONDING FIELDS OF TABLE it_t5009.
272
273       sort it_t5009  by persa.
274      delete adjacent duplicates from it_t5009
275      comparing persa.
276
277      loop at lv_area into wa_area.
278
279        read table it_t5009 into wa_t5009 WITH KEY persa = wa_area-werks.
280        wa_final-sachx = wa_area-sachx.
281        wa_final-persa = wa_t5009-persa.
282        wa_final-bukrs = wa_t5009-bukrs.
283        append wa_final to it_final.
284      endloop.
285      call function 'F4IF_INT_TABLE_VALUE_REQUEST'
286        exporting
287          retfield        = 'SACHX'
288          dynpprog        = 'ZFI_REM_PYBLCK'
289          dynpnr          = sy-dynnr
290          dynprofield     = 'S_XREF1-HIGH'
291          value_org       = 'S'
292        tables
293          value_tab       = it_final
294        exceptions
295          parameter_error = 1
296          no_values_found = 2
297          others          = 3.
298
299      if sy-subrc <> 0.
300    *
301    *    message id sy-msgid type sy-msgty number sy-msgno
302    *            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
303
304      endif.
305
306    * End of addition Prabu K on 06.07.2009
307
308    at selection-screen on p_bukrs .
309      select single * from t001  where bukrs = p_bukrs.
310      if sy-subrc <> 0.
311        message e010(fi).
312      endif.
313    *----start of <RD1K960891>
314      authority-check object 'F_BKPF_BUK'
315                  id 'ACTVT' field '02'
316                  id 'BUKRS' field p_bukrs.
317
318      if sy-subrc <> 0.
319        message  e091(8b) with p_bukrs.
320      endif.
321
322    *---End of  <RD1K960891>
323
324    *------------------------------------------------------*
325    start-of-selection.
326    *------------------------------------------------------*
327    *----start of <RD1K960891>
328      if s_lifnr is initial and s_kunnr is initial.
329        message   e322(zfi).
330      endif.
331      if  not  s_lifnr is initial  and  not s_kunnr is initial .
332        message   e322(zfi).
333      endif.
334
335      if not s_lifnr  is initial.
336        perform get_docs.
337        perform display_docs.
338      elseif  not s_kunnr is initial.
339        perform get_docs_cust.
340        perform display_docs_cust.
341      endif.
342    *----End of <RD1K960891>
343
344    *&---------------------------------------------------------------------*
345    *&      Form  display_docs
346    *&---------------------------------------------------------------------*
347    *       text
348    *----------------------------------------------------------------------*
349    *  -->  p1        text
350    *  <--  p2        text
351    *----------------------------------------------------------------------*
352    form display_docs.
353      perform init_fieldcat.
354
355    * Begin of <RD1K960036>
356    *  PERFORM eventtab_build USING gt_events[].
357      perform eventtab_build tables gt_events.
358    * End of <RD1K960036>
359
360    * Begin of <RD1K960036>
361    *  PERFORM comment_build USING gt_list_top_of_page[].
362      perform comment_build tables gt_list_top_of_page.
363    * End of <RD1K960036>
364
365      perform  sort_build .
366      perform  print_alv.
367
368    endform.                    " display_docs
369    *&---------------------------------------------------------------------*
370    *&      Form  init_fieldcat
371    *&---------------------------------------------------------------------*
372    *       text
373    *----------------------------------------------------------------------*
374    *  -->  p1        text
375    *  <--  p2        text
376    *----------------------------------------------------------------------*
377    form init_fieldcat.
378      w_repid  = sy-repid.
379
380      mpos = 0.
381      mpos = mpos + 1.
382      ist_fieldcat-fieldname = 'SELCBOX'.
383      ist_fieldcat-tabname = 'IST_SRCBSIK'.
384      ist_fieldcat-ddictxt = 'M'.
385      ist_fieldcat-col_pos =  mpos.
386      ist_fieldcat-seltext_m  = 'Select'.
387      ist_fieldcat-lowercase  = 'Y'.
388      ist_fieldcat-checkbox = 'X'.
389      ist_fieldcat-input = 'X'.
390
391      append ist_fieldcat to ist_fcat.
392      clear ist_fieldcat.
393
394
395
396      mpos = mpos + 1.
397      ist_fieldcat-fieldname = 'LIFNR'.
398      ist_fieldcat-tabname = 'IST_SRCBSIK'.
399      ist_fieldcat-ddictxt = 'M'.
400      ist_fieldcat-col_pos =  mpos.
401      ist_fieldcat-seltext_m  = 'VendorNumber'.
402      ist_fieldcat-lowercase  = 'Y'.
403      append ist_fieldcat to ist_fcat.
404      clear ist_fieldcat.
405
406
407
408
409      mpos = mpos + 1.
410      ist_fieldcat-fieldname = 'BELNR'.
411      ist_fieldcat-tabname = 'IST_SRCBSIK'.
412      ist_fieldcat-ddictxt = 'M'.
413      ist_fieldcat-col_pos =  mpos.
414      ist_fieldcat-seltext_m  = 'Doc.No.'.
415      ist_fieldcat-lowercase  = 'Y'.
416      append ist_fieldcat to ist_fcat.
417      clear ist_fieldcat.
418
419      mpos = mpos + 1.
420      ist_fieldcat-fieldname = 'GSBER'.
421      ist_fieldcat-tabname = 'IST_SRCBSIK'.
422      ist_fieldcat-ddictxt = 'M'.
423      ist_fieldcat-col_pos =  mpos.
424      ist_fieldcat-seltext_m  = 'Business Area'.
425      ist_fieldcat-lowercase  = 'Y'.
426      append ist_fieldcat to ist_fcat.
427      clear ist_fieldcat.
428
429    *---+001
430      mpos = mpos + 1.
431      ist_fieldcat-fieldname = 'KIDNO'.
432      ist_fieldcat-tabname = 'IST_SRCBSIK'.
433      ist_fieldcat-ddictxt = 'M'.
434      ist_fieldcat-col_pos =  mpos.
435      ist_fieldcat-seltext_m  = 'Payment Reference'.
436      ist_fieldcat-lowercase  = 'Y'.
437      append ist_fieldcat to ist_fcat.
438      clear ist_fieldcat.
439
440    *-------+001
441    *BEGIN of <RD1K967585> CAB_ALOK 10.12.2009 CR30002778
442     mpos = mpos + 1.
443      ist_fieldcat-fieldname = 'REBZG'.
444      ist_fieldcat-tabname = 'IST_SRCBSIK'.
445      ist_fieldcat-ddictxt = 'M'.
446      ist_fieldcat-col_pos =  mpos.
447      ist_fieldcat-seltext_m  = 'Invoice Reference'.
448    *  ist_fieldcat-lowercase  = 'Y'.
449      APPEND ist_fieldcat TO ist_fcat.
450      CLEAR ist_fieldcat.
451    *end of <RD1K967585> CAB_ALOK 10.12.2009 CR30002778
452
453      mpos = mpos + 1.
454      ist_fieldcat-fieldname = 'GJAHR'.
455      ist_fieldcat-tabname = 'IST_SRCBSIK'.
456      ist_fieldcat-ddictxt = 'M'.
457      ist_fieldcat-col_pos =  mpos.
458      ist_fieldcat-seltext_m  = 'Year'.
459      ist_fieldcat-lowercase  = 'Y'.
460      append ist_fieldcat to ist_fcat.
461      clear ist_fieldcat.
462
463
464
465
466      mpos = mpos + 1.
467      ist_fieldcat-fieldname = 'BUZEI'.
468      ist_fieldcat-tabname = 'IST_SRCBSIK'.
469      ist_fieldcat-ddictxt = 'M'.
470      ist_fieldcat-col_pos =  mpos.
471      ist_fieldcat-seltext_m  = 'Item.no.'.
472      ist_fieldcat-lowercase  = 'Y'.
473      append ist_fieldcat to ist_fcat.
474      clear ist_fieldcat.
475
476      mpos = mpos + 1.
477      ist_fieldcat-fieldname = 'BSCHL'.
478      ist_fieldcat-tabname = 'IST_SRCBSIK'.
479      ist_fieldcat-ddictxt = 'M'.
480      ist_fieldcat-col_pos =  mpos.
481      ist_fieldcat-seltext_m  = 'Posting Key.'.
482      ist_fieldcat-lowercase  = 'Y'.
483      append ist_fieldcat to ist_fcat.
484      clear ist_fieldcat.
485
486      mpos = mpos + 1.
487      ist_fieldcat-fieldname = 'BUDAT'.
488      ist_fieldcat-tabname = 'IST_SRCBSIK'.
489      ist_fieldcat-ddictxt = 'M'.
490      ist_fieldcat-col_pos =  mpos.
491      ist_fieldcat-seltext_m  = 'Posting Date'.
492      ist_fieldcat-lowercase  = 'Y'.
493      append ist_fieldcat to ist_fcat.
494      clear ist_fieldcat.
495
496
497      mpos = mpos + 1.
498      ist_fieldcat-fieldname = 'DMBTR'.
499      ist_fieldcat-tabname = 'IST_SRCBSIK'.
500      ist_fieldcat-ddictxt = 'M'.
501      ist_fieldcat-col_pos =  mpos.
502      ist_fieldcat-seltext_m  = 'AmtInLclCurncy'.
503      ist_fieldcat-lowercase  = 'Y'.
504      append ist_fieldcat to ist_fcat.
505      clear ist_fieldcat.
506
507
508
509      mpos = mpos + 1.
510      ist_fieldcat-fieldname = 'WRBTR'.
511      ist_fieldcat-tabname = 'IST_SRCBSIK'.
512      ist_fieldcat-ddictxt = 'M'.
513      ist_fieldcat-col_pos =  mpos.
514      ist_fieldcat-seltext_m  = 'AmtInDocCurncy'.
515      ist_fieldcat-lowercase  = 'Y'.
516      append ist_fieldcat to ist_fcat.
517      clear ist_fieldcat.
518
519      mpos = mpos + 1.
520      ist_fieldcat-fieldname = 'ZLSCH'.
521      ist_fieldcat-tabname = 'IST_SRCBSIK'.
522      ist_fieldcat-ddictxt = 'M'.
523      ist_fieldcat-col_pos =  mpos.
524      ist_fieldcat-seltext_m  = 'PaymentMethod.'.
525      ist_fieldcat-lowercase  = 'Y'.
526      append ist_fieldcat to ist_fcat.
527      clear ist_fieldcat.
528
529
530      mpos = mpos + 1.
531      ist_fieldcat-fieldname = 'ZLSPR'.
532      ist_fieldcat-tabname = 'IST_SRCBSIK'.
533      ist_fieldcat-ddictxt = 'M'.
534      ist_fieldcat-col_pos =  mpos.
535      ist_fieldcat-seltext_m  = 'PaymntBlock'.
536      ist_fieldcat-lowercase  = 'Y'.
537      append ist_fieldcat to ist_fcat.
538      clear ist_fieldcat.
539
540    *  Start of addition Prabu K on 06.07.2009
541      mpos = mpos + 1.
542      ist_fieldcat-fieldname = 'XREF1_HD'.
543      ist_fieldcat-tabname = 'IST_SRCBSIK'.
544      ist_fieldcat-ddictxt = 'M'.
545      ist_fieldcat-col_pos =  mpos.
546      ist_fieldcat-seltext_m  = 'Location'.
547      ist_fieldcat-lowercase  = 'Y'.
548      append ist_fieldcat to ist_fcat.
549      clear ist_fieldcat.
550
551    * End of addition Prabu K on 06.07.2009
552
553
554
555    endform.                    " init_fieldcat
556    *&---------------------------------------------------------------------*
557    *&      Form  eventtab_build
558    *&---------------------------------------------------------------------*
559    *       text
560    *----------------------------------------------------------------------*
561    *      -->P_GT_EVENTS[]  text
562    *----------------------------------------------------------------------*
563    *Begin of <RD1K960036>
564    *FORM eventtab_build USING    p_gt_events[].
565    form eventtab_build tables   p_gt_events.
566    *End of <RD1K960036>
567
568      data : ls_event type slis_alv_event.
569      call function 'REUSE_ALV_EVENTS_GET'
570        exporting
571          i_list_type = 0
572        importing
573          et_events   = gt_events.
574      read table gt_events with key name =  slis_ev_user_command
575                                into ls_event.
576      if sy-subrc = 0.
577        move 'MAKE_COMMAND' to ls_event-form.
578        append ls_event to gt_events.
579      endif.
580      clear ls_event.
581
582
583    endform.                    " eventtab_build
584    *&---------------------------------------------------------------------*
585    *&      Form  comment_build
586    *&---------------------------------------------------------------------*
587    *       text
588    *----------------------------------------------------------------------*
589    *      -->P_GT_LIST_TOP_OF_PAGE[]  text
590    *----------------------------------------------------------------------*
591    * Begin of <RD1K960036>
592    *FORM comment_build USING    p_gt_list_top_of_page[].
593    form comment_build tables    p_gt_list_top_of_page.
594    * End of <RD1K960036>
595    endform.                    " comment_build
596    *&---------------------------------------------------------------------*
597    *&      Form  sort_build
598    *&---------------------------------------------------------------------*
599    *       text
600    *----------------------------------------------------------------------*
601    *  -->  p1        text
602    *  <--  p2        text
603    *----------------------------------------------------------------------*
604    form sort_build.
605
606      w_repid = sy-repid.
607      is_layout-key_hotspot = 'X'.
608      is_layout-colwidth_optimize = 'X'.
609
610      ls_sorttab-fieldname = 'KIDNO'.
611      ls_sorttab-up = 'X'.
612      append ls_sorttab to lt_sorttab.
613
614      ls_sorttab-fieldname = 'LIFNR'.
615      ls_sorttab-up = 'X'.
616      append ls_sorttab to lt_sorttab.
617      ls_sorttab-fieldname = 'BSCHL'.
618      ls_sorttab-up = 'X'.
619      append ls_sorttab to lt_sorttab.
620      ls_sorttab-fieldname = 'BELNR'.
621      ls_sorttab-up = 'X'.
622      append ls_sorttab to lt_sorttab.
623      ls_sorttab-fieldname = 'BUDAT'.
624      ls_sorttab-up = 'X'.
625      append ls_sorttab to lt_sorttab.
626
627
628
629
630    endform.                    " sort_build
631    *&---------------------------------------------------------------------*
632    *&      Form  print_alv
633    *&---------------------------------------------------------------------*
634    *       text
635    *----------------------------------------------------------------------*
636    *  -->  p1        text
637    *  <--  p2        text
638    *----------------------------------------------------------------------*
639    form print_alv.
640
641      call function 'REUSE_ALV_LIST_DISPLAY'
642           exporting
643                i_callback_program       = w_repid
644                i_callback_pf_status_set = 'ALV_PFST'
645                i_callback_user_command  = 'MAKE_COMMAND'
646                is_layout                = is_layout
647                it_fieldcat              = ist_fcat[]
648                it_sort                  = lt_sorttab
649                it_events                = gt_events
650                i_save                   = 'A'
651           tables
652                t_outtab                 = ist_srcbsik
653    * Begin of <RD1K960036>
654    *  IF sy-subrc <> 0.
655    **    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
656    **            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
657    *  ENDIF.
658           exceptions
659                program_error            = 1.
660      if sy-subrc <> 0.
661        message id sy-msgid type sy-msgty number sy-msgno
662                with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
663      endif.
664    * End of <RD1K960036>
665
666
667    endform.                    " print_alv
668    *---------------------------------------------------------------------*
669    *       FORM alv_pfst                                                 *
670    *---------------------------------------------------------------------*
671    *       ........                                                      *
672    *---------------------------------------------------------------------*
673    *  -->  RT_EXTAB                                                      *
674    *---------------------------------------------------------------------*
675    form alv_pfst using rt_extab type slis_t_extab.
676      set pf-status 'S100'.
677    endform.                    "alv_pfst
678
679    *---------------------------------------------------------------------*
680    *       FORM make_command                                             *
681    *---------------------------------------------------------------------*
682    *       ........                                                      *
683    *---------------------------------------------------------------------*
684    *  -->  R_UCOMM                                                       *
685    *  -->  RS_SELFIELD                                                   *
686    *---------------------------------------------------------------------*
687    form make_command using r_ucomm like sy-ucomm
688                            rs_selfield type slis_selfield.
689    *-----------------------------------------------------*
690    *-----------------------------------------------------*
691      data : index_aux like sy-tabix.
692      index_aux = rs_selfield-tabindex.
693      case r_ucomm.
694
695        when 'REL'.
696          delete ist_srcbsik where  selcbox <> 'X'.
697
698          perform   get_upd_bsik.
699          perform   get_upd_bseg.
700    *Begin of <RD1K967585> CAB_ALOK 09.12.2009 CR30002778
701          PERFORM   UPDATE_ZFI_REM_PYBLCK_L.    "update logs
702    *end of <RD1K967585> CAB_ALOK 09.12.2009 CR30002778
703          leave screen.
704        when 'ALL'.
705          perform  select_all.
706        when 'SAL'.
707          perform  deselect_all.
708
709        when '&F03' or 'BACK' .
710          leave  program.
711
712      endcase.
713
714    endform.                    "make_command
715    *---------------------------------------------------------------------*
716    *&      Form  select_all
717    *&---------------------------------------------------------------------*
718    *       text
719    *----------------------------------------------------------------------*
720    *  -->  p1        text
721    *  <--  p2        text
722    *----------------------------------------------------------------------*
723    form select_all.
724      loop at ist_srcbsik.
725        ist_srcbsik-selcbox = 'X'.
726        modify ist_srcbsik.
727      endloop.
728
729    endform.                    " select_all
730    *&---------------------------------------------------------------------*
731    *&      Form  deselect_all
732    *&---------------------------------------------------------------------*
733    *       text
734    *----------------------------------------------------------------------*
735    *  -->  p1        text
736    *  <--  p2        text
737    *----------------------------------------------------------------------*
738    form deselect_all.
739      loop at ist_srcbsik.
740        ist_srcbsik-selcbox = ' '.
741        modify ist_srcbsik.
742      endloop.
743    endform.                    " deselect_all
744    *&---------------------------------------------------------------------
745    *&---------------------------------------------------------------------*
746    *&      Form  get_upd_bsik
747    *&---------------------------------------------------------------------*
748    *       text
749    *----------------------------------------------------------------------*
750    *  -->  p1        text
751    *  <--  p2        text
752    *----------------------------------------------------------------------*
753    form get_upd_bsik.
754
755      data : l_tabix  type sy-tabix.
756
757      check not ist_srcbsik[] is initial.
758
759      select * into table ist_bsik   from bsik
760        for all entries  in  ist_srcbsik
761        where   lifnr = ist_srcbsik-lifnr
762              and  bukrs  =  p_bukrs
763               and gjahr = ist_srcbsik-gjahr
764               and belnr = ist_srcbsik-belnr
765               and buzei = ist_srcbsik-buzei.
766
767      if not ist_bsik is initial.
768        loop at ist_bsik into wa_bsik.
769          l_tabix =   sy-tabix .
770          if wa_bsik-zlspr =  p_zlsprf.
771            wa_bsik-zlspr =  p_zlsprt.
772            modify ist_bsik  from  wa_bsik index l_tabix  transporting zlspr.
773          endif.
774        endloop.
775    "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
776    "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
777    *    modify  bsik from table ist_bsik.
778    *
779    *    commit work.
780        "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
781      endif.
782
783    *  LEAVE SCREEN.
784    endform.                    " get_upd_bsik
785    *
786    *&---------------------------------------------------------------------*
787    *&      Form  get_upd_bseg
788    *&---------------------------------------------------------------------*
789    *       text
790    *----------------------------------------------------------------------*
791    *  -->  p1        text
792    *  <--  p2        text
793    *----------------------------------------------------------------------*
794    form get_upd_bseg.
795      data : l_tabix  type sy-tabix.
796
797      check not ist_srcbsik[] is initial.
798
799      select * into table ist_bseg   from bseg
800        for all entries  in  ist_srcbsik
801        where
802               bukrs  =  p_bukrs
803         and   belnr = ist_srcbsik-belnr
804         and   gjahr = ist_srcbsik-gjahr
805         and   buzei = ist_srcbsik-buzei ORDER BY PRIMARY KEY.
806
807      if not ist_bseg is initial.
808
809        loop at ist_bseg into wa_bseg.
810          l_tabix =   sy-tabix .
811          if wa_bseg-zlspr =  p_zlsprf.
812            wa_bseg-zlspr =   p_zlsprt.
813            modify ist_bseg  from  wa_bseg index l_tabix  transporting zlspr.
814          endif.
815        endloop.
816
817    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
818    * S/4: BSEG payment block (ZLSPR) via FI_DOCUMENT_CHANGE (FB02); direct write not allowed.
819    *    modify bseg from table ist_bseg.
820        LOOP AT ist_bseg INTO wa_bseg.
821          PERFORM zz_s4_bseg_zlspr USING wa_bseg-bukrs wa_bseg-belnr wa_bseg-gjahr wa_bseg-buzei wa_bseg-zlspr.
822        ENDLOOP.
823        COMMIT WORK.
824    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
825
826
827
828      endif.
829
830
831    endform.                    " get_upd_bseg
832    *&---------------------------------------------------------------------*
833    *&      Form  get_docs
834    *&---------------------------------------------------------------------*
835    *       text
836    *----------------------------------------------------------------------*
837    *  -->  p1        text
838    *  <--  p2        text
839    *----------------------------------------------------------------------*
840    form get_docs.
841      select bukrs lifnr umskz gjahr belnr buzei budat bschl
842    *begin of <RD1K967585> CAB_ALOK 10.12.2009 CR30002778
843    *  zlsch zlspr shkzg gsber dmbtr wrbtr kidno appending
844       zlsch zlspr shkzg gsber dmbtr wrbtr kidno rebzg appending
845    *end of <RD1K967585> CAB_ALOK 10.12.2009 CR30002778
846      corresponding fields of table
847                    ist_srcbsik  from bsik
848                    where
849                    bukrs  =  p_bukrs
850                    and lifnr  in s_lifnr
851                    and gjahr in s_year
852                    and gsber in s_gsber
853                    and budat in  s_budat.  "#EC CI_NOORDER
854
855
856
857
858      delete  ist_srcbsik where zlspr <> p_zlsprf.
859
860
861    *Start of addition Prabu K on 03.07.2009
862      data wa_bkpf type bkpf.
863      loop at ist_srcbsik into wa_srcbsik.
864
865        select single * from bkpf into wa_bkpf where bukrs = wa_srcbsik-bukrs and belnr = wa_srcbsik-belnr
866           and xref1_hd in s_xref1.  "#EC CI_NOORDER
867        if sy-subrc ne 0.
868          delete table ist_srcbsik from wa_srcbsik.
869        else.
870          wa_srcbsik-xref1_hd = wa_bkpf-xref1_hd.
871          modify ist_srcbsik from wa_srcbsik.
872        endif.
873
874      endloop.
875    *  End  of addition Prabu K on 03.07.2009
876      ist_bsiks[] = ist_srcbsik[].
877
878
879      refresh ist_srcbsik.
880      clear ist_srcbsik.
881
882
883      loop at ist_bsiks .
884        if ist_bsiks-umskz = 'P' or ist_bsiks-umskz = 'F'
885        or ist_bsiks-umskz = ':'    or                          "+002
886        ist_bsiks-umskz  is initial.
887          ist_srcbsik = ist_bsiks.
888          append ist_srcbsik.
889          clear ist_srcbsik.
890        endif.
891      endloop.
892
893
894
895      check  not ist_srcbsik[] is initial.
896
897      loop at ist_srcbsik.
898        if ist_srcbsik-shkzg = 'S'.
899          ist_srcbsik-dmbtr = ist_srcbsik-dmbtr.
900          ist_srcbsik-wrbtr = ist_srcbsik-wrbtr.
901        elseif ist_srcbsik-shkzg = 'H'.
902          ist_srcbsik-dmbtr = - ist_srcbsik-dmbtr.
903          ist_srcbsik-wrbtr = - ist_srcbsik-wrbtr.
904        endif.
905        modify ist_srcbsik .
906      endloop.
907
908      ist_bsiks[] = ist_srcbsik[].
909
910      sort ist_srcbsik by lifnr bschl belnr budat.
911
912    endform.                    " get_docs
913    *-----------------------start of <RD1K960891>
914    *&---------------------------------------------------------------------*
915    *&      Form  get_docs_cust
916    *&---------------------------------------------------------------------*
917    *       text
918    *----------------------------------------------------------------------*
919    *  -->  p1        text
920    *  <--  p2        text
921    *----------------------------------------------------------------------*
922    form get_docs_cust.
923      select bukrs kunnr umskz gjahr belnr buzei budat bschl
924    *begin of <RD1K967585> CAB_ALOK 10.12.2009 CR30002778
925    *  zlsch zlspr shkzg gsber dmbtr wrbtr kidno appending
926       zlsch zlspr shkzg gsber dmbtr wrbtr kidno rebzg appending
927    *end of <RD1K967585> CAB_ALOK 10.12.2009 CR30002778
928       corresponding fields of table
929                      ist_srcbsid  from bsid
930                      where
931                      bukrs  =  p_bukrs
932                      and kunnr  in s_kunnr
933                      and gjahr in s_year
934                      and gsber in s_gsber
935                      and budat in  s_budat.  "#EC CI_NOORDER
936
937
938
939      delete  ist_srcbsid where zlspr <> p_zlsprf.
940
941    *Start of addition Prabu K on 03.07.2009
942      data wa_bkpf type bkpf.
943      loop at ist_srcbsid into wa_srcbsid.
944
945        select single * from bkpf into wa_bkpf where bukrs = wa_srcbsid-bukrs and belnr = wa_srcbsid-belnr
946           and xref1_hd in s_xref1.  "#EC CI_NOORDER
947        if sy-subrc ne 0.
948          delete table ist_srcbsid from wa_srcbsid.
949        else.
950          wa_srcbsid-xref1_hd = wa_bkpf-xref1_hd.
951          modify ist_srcbsid from wa_srcbsid.
952        endif.
953
954      endloop.
955    *  End  of addition Prabu K on 03.07.2009
956      ist_bsids[] = ist_srcbsid[].
957
958
959      refresh ist_srcbsid.
960      clear ist_srcbsid.
961
962
963      loop at ist_bsids .
964    *{001
965    *    IF ist_bsids-umskz = 'K' OR ist_bsids-umskz = 'H'.
966        if ( ist_bsids-umskz = 'K' or ist_bsids-umskz = 'H' or ist_bsids-umskz = 'O') or
967    *Start of changes by SOGET - 003
968    *( ist_bsids-umskz = ' ' and ist_bsids-zlsch = 'P' ).
969           ( ist_bsids-umskz = ' ' and ist_bsids-zlsch = 'P' ) or ( ist_bsids-umskz = ' ' and ist_bsids-zlsch = 'Q' ).
970    *End of changes by SOGET - 003
971    *}001
972          ist_srcbsid = ist_bsids.
973          append ist_srcbsid.
974          clear ist_srcbsid.
975        endif.
976      endloop.
977
978
979
980      check  not ist_srcbsid[] is initial.
981
982      loop at ist_srcbsid.
983        if ist_srcbsid-shkzg = 'S'.
984          ist_srcbsid-dmbtr = ist_srcbsid-dmbtr.
985          ist_srcbsid-wrbtr = ist_srcbsid-wrbtr.
986        elseif ist_srcbsid-shkzg = 'H'.
987          ist_srcbsid-dmbtr = - ist_srcbsid-dmbtr.
988          ist_srcbsid-wrbtr = - ist_srcbsid-wrbtr.
989        endif.
990        modify ist_srcbsid .
991      endloop.
992
993      ist_bsids[] = ist_srcbsid[].
994
995      sort ist_srcbsid by kunnr bschl belnr budat.
996
997
998    endform.                    " get_docs_cust
999    *&---------------------------------------------------------------------*
1000   *&      Form  display_docs_cust
1001   *&---------------------------------------------------------------------*
1002   *       text
1003   *----------------------------------------------------------------------*
1004   *  -->  p1        text
1005   *  <--  p2        text
1006   *----------------------------------------------------------------------*
1007   form display_docs_cust.
1008     perform init_fieldcat_cust.
1009     perform eventtab_build_cust using gt_events[].
1010     perform  sort_build_cust .
1011     perform  print_alv_cust.
1012
1013   endform.                    " display_docs_cust
1014   *&---------------------------------------------------------------------*
1015   *&      Form  eventtab_build_cust
1016   *&---------------------------------------------------------------------*
1017   *       text
1018   *----------------------------------------------------------------------*
1019   *      -->P_GT_EVENTS[]  text
1020   *----------------------------------------------------------------------*
1021   form eventtab_build_cust using    p_gt_events.
1022     data : ls_event type slis_alv_event.
1023     call function 'REUSE_ALV_EVENTS_GET'
1024       exporting
1025         i_list_type = 0
1026       importing
1027         et_events   = gt_events.
1028     read table gt_events with key name =  slis_ev_user_command
1029                               into ls_event.
1030     if sy-subrc = 0.
1031       move 'MAKEC_COMMAND' to ls_event-form.
1032       append ls_event to gt_events.
1033     endif.
1034     clear ls_event.
1035
1036
1037   endform.                    " eventtab_build_cust
1038   *&---------------------------------------------------------------------*
1039   *&      Form  sort_build_cust
1040   *&---------------------------------------------------------------------*
1041   *       text
1042   *----------------------------------------------------------------------*
1043   *  -->  p1        text
1044   *  <--  p2        text
1045   *----------------------------------------------------------------------*
1046   form sort_build_cust.
1047
1048     w_repid = sy-repid.
1049     is_layout-key_hotspot = 'X'.
1050     is_layout-colwidth_optimize = 'X'.
1051
1052     ls_sorttab-fieldname = 'KIDNO'.
1053     ls_sorttab-up = 'X'.
1054     append ls_sorttab to lt_sorttab.
1055
1056     ls_sorttab-fieldname = 'KUNNR'.
1057     ls_sorttab-up = 'X'.
1058     append ls_sorttab to lt_sorttab.
1059     ls_sorttab-fieldname = 'BSCHL'.
1060     ls_sorttab-up = 'X'.
1061     append ls_sorttab to lt_sorttab.
1062     ls_sorttab-fieldname = 'BELNR'.
1063     ls_sorttab-up = 'X'.
1064     append ls_sorttab to lt_sorttab.
1065     ls_sorttab-fieldname = 'BUDAT'.
1066     ls_sorttab-up = 'X'.
1067     append ls_sorttab to lt_sorttab.
1068
1069   endform.                    " sort_build_cust
1070   *&---------------------------------------------------------------------*
1071   *&      Form  print_alv_cust
1072   *&---------------------------------------------------------------------*
1073   *       text
1074   *----------------------------------------------------------------------*
1075   *  -->  p1        text
1076   *  <--  p2        text
1077   *----------------------------------------------------------------------*
1078   form print_alv_cust.
1079     call function 'REUSE_ALV_LIST_DISPLAY'
1080       exporting
1081         i_callback_program       = w_repid
1082         i_callback_pf_status_set = 'ALV_PFSTS'
1083         i_callback_user_command  = 'MAKEC_COMMAND'
1084         is_layout                = is_layout
1085         it_fieldcat              = ist_fcat[]
1086         it_sort                  = lt_sorttab
1087         it_events                = gt_events
1088         i_save                   = 'A'
1089       tables
1090         t_outtab                 = ist_srcbsid
1091   * Begin of Changes on 20-Jun-2013
1092          EXCEPTIONS
1093               PROGRAM_ERROR = 1
1094               OTHERS        = 2.
1095   * End of Changes on 20-Jun-2013
1096     if sy-subrc <> 0.
1097   *    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
1098   *            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
1099     endif.
1100
1101   endform.                    " print_alv_cust
1102   *---------------------------------------------------------------------*
1103   *       FORM alv_pfst                                                 *
1104   *---------------------------------------------------------------------*
1105   *       ........                                                      *
1106   *---------------------------------------------------------------------*
1107   *  -->  RT_EXTAB                                                      *
1108   *---------------------------------------------------------------------*
1109   form alv_pfsts using rt_extab type slis_t_extab.
1110     set pf-status 'S100'.
1111   endform.                    "alv_pfsts
1112
1113   *---------------------------------------------------------------------*
1114   *       FORM make_command                                             *
1115   *---------------------------------------------------------------------*
1116   *       ........                                                      *
1117   *---------------------------------------------------------------------*
1118   *  -->  R_UCOMM                                                       *
1119   *  -->  RS_SELFIELD                                                   *
1120   *---------------------------------------------------------------------*
1121   form makec_command using r_ucomm like sy-ucomm
1122                           rs_selfield type slis_selfield.
1123   *-----------------------------------------------------*
1124   *-----------------------------------------------------*
1125     data : index_aux like sy-tabix.
1126     index_aux = rs_selfield-tabindex.
1127     case r_ucomm.
1128
1129       when 'REL'.
1130         delete ist_srcbsid where  selcbox <> 'X'.
1131
1132         perform   get_upd_bsid.
1133         perform   get_upd_bseg_c.
1134   *Begin of <RD1K967585> CAB_ALOK 09.12.2009 CR30002778
1135         PERFORM   UPDATE_ZFI_REM_PYBLCK_L.    "update logs
1136   *end of <RD1K967585> CAB_ALOK 09.12.2009 CR30002778
1137         leave screen.
1138       when 'ALL'.
1139         perform  select_allc.
1140       when 'SAL'.
1141         perform  deselect_allc.
1142
1143       when '&F03' or 'BACK' .
1144         leave  program.
1145
1146     endcase.
1147
1148   endform.                    "makec_command
1149   *---------------------------------------------------------------------*
1150   *&      Form  select_all
1151   *&---------------------------------------------------------------------*
1152   *       text
1153   *----------------------------------------------------------------------*
1154   *  -->  p1        text
1155   *  <--  p2        text
1156   *----------------------------------------------------------------------*
1157   form select_allc.
1158     loop at ist_srcbsid.
1159       ist_srcbsid-selcbox = 'X'.
1160       modify ist_srcbsid.
1161     endloop.
1162
1163   endform.                    " select_all
1164   *&---------------------------------------------------------------------*
1165   *&      Form  deselect_all
1166   *&---------------------------------------------------------------------*
1167   *       text
1168   *----------------------------------------------------------------------*
1169   *  -->  p1        text
1170   *  <--  p2        text
1171   *----------------------------------------------------------------------*
1172   form deselect_allc.
1173     loop at ist_srcbsid.
1174       ist_srcbsid-selcbox = ' '.
1175       modify ist_srcbsid.
1176     endloop.
1177   endform.                    " deselect_all
1178   *&---------------------------------------------------------------------
1179   *&---------------------------------------------------------------------*
1180   *&      Form  get_upd_bsid
1181   *&---------------------------------------------------------------------*
1182   *       text
1183   *----------------------------------------------------------------------*
1184   *  -->  p1        text
1185   *  <--  p2        text
1186   *----------------------------------------------------------------------*
1187   form get_upd_bsid.
1188
1189     data : l_tabix  type sy-tabix.
1190
1191     check not ist_srcbsid[] is initial.
1192
1193     select * into table ist_bsid   from bsid
1194       for all entries  in  ist_srcbsid
1195       where   kunnr = ist_srcbsid-kunnr
1196             and  bukrs  =  p_bukrs
1197              and gjahr = ist_srcbsid-gjahr
1198              and belnr = ist_srcbsid-belnr
1199              and buzei = ist_srcbsid-buzei.
1200
1201     if not ist_bsid is initial.
1202       loop at ist_bsid into wa_bsid.
1203         l_tabix =   sy-tabix .
1204         if wa_bsid-zlspr =  p_zlsprf.
1205           wa_bsid-zlspr =  p_zlsprt.
1206           modify ist_bsid  from  wa_bsid index l_tabix  transporting zlspr.
1207         endif.
1208       endloop.
1209   "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
1210   *    modify  bsid from table ist_bsid.
1211   *
1212   *    commit work.
1213   "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
1214     endif.
1215
1216   *  LEAVE SCREEN.
1217   endform.                    " get_upd_bsid
1218   *
1219   *&---------------------------------------------------------------------*
1220   *&      Form  get_upd_bseg
1221   *&---------------------------------------------------------------------*
1222   *       text
1223   *----------------------------------------------------------------------*
1224   *  -->  p1        text
1225   *  <--  p2        text
1226   *----------------------------------------------------------------------*
1227   form get_upd_bseg_c.
1228     data : l_tabix  type sy-tabix.
1229
1230     check not ist_srcbsid[] is initial.
1231
1232     select * into table ist_bseg   from bseg
1233       for all entries  in  ist_srcbsid
1234       where
1235              bukrs  =  p_bukrs
1236        and   belnr = ist_srcbsid-belnr
1237        and   gjahr = ist_srcbsid-gjahr
1238        and   buzei = ist_srcbsid-buzei ORDER BY PRIMARY KEY.
1239
1240     if not ist_bseg is initial.
1241
1242       loop at ist_bseg into wa_bseg.
1243         l_tabix =   sy-tabix .
1244         if wa_bseg-zlspr =  p_zlsprf.
1245           wa_bseg-zlspr =   p_zlsprt.
1246           modify ist_bseg  from  wa_bseg index l_tabix  transporting zlspr.
1247         endif.
1248       endloop.
1249
1250   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1251   * S/4: BSEG payment block (ZLSPR) via FI_DOCUMENT_CHANGE (FB02); direct write not allowed.
1252   *    modify bseg from table ist_bseg.
1253       LOOP AT ist_bseg INTO wa_bseg.
1254         PERFORM zz_s4_bseg_zlspr USING wa_bseg-bukrs wa_bseg-belnr wa_bseg-gjahr wa_bseg-buzei wa_bseg-zlspr.
1255       ENDLOOP.
1256       COMMIT WORK.
1257   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1258
1259
1260
1261     endif.
1262
1263
1264   endform.                    " get_upd_bseg_c
1265   *&---------------------------------------------------------------------*
1266   *&      Form  init_fieldcat_cust
1267   *&---------------------------------------------------------------------*
1268   *       text
1269   *----------------------------------------------------------------------*
1270   *  -->  p1        text
1271   *  <--  p2        text
1272   *----------------------------------------------------------------------*
1273   form init_fieldcat_cust.
1274     w_repid  = sy-repid.
1275
1276     mpos = 0.
1277     mpos = mpos + 1.
1278     ist_fieldcat-fieldname = 'SELCBOX'.
1279     ist_fieldcat-tabname = 'IST_SRCBSID'.
1280     ist_fieldcat-ddictxt = 'M'.
1281     ist_fieldcat-col_pos =  mpos.
1282     ist_fieldcat-seltext_m  = 'Select'.
1283     ist_fieldcat-lowercase  = 'Y'.
1284     ist_fieldcat-checkbox = 'X'.
1285     ist_fieldcat-input = 'X'.
1286
1287     append ist_fieldcat to ist_fcat.
1288     clear ist_fieldcat.
1289
1290
1291
1292     mpos = mpos + 1.
1293     ist_fieldcat-fieldname = 'KUNNR'.
1294     ist_fieldcat-tabname = 'IST_SRCBSID'.
1295     ist_fieldcat-ddictxt = 'M'.
1296     ist_fieldcat-col_pos =  mpos.
1297     ist_fieldcat-seltext_m  = 'CustomerNumber'.
1298     ist_fieldcat-lowercase  = 'Y'.
1299     append ist_fieldcat to ist_fcat.
1300     clear ist_fieldcat.
1301
1302
1303
1304
1305     mpos = mpos + 1.
1306     ist_fieldcat-fieldname = 'BELNR'.
1307     ist_fieldcat-tabname = 'IST_SRCBSID'.
1308     ist_fieldcat-ddictxt = 'M'.
1309     ist_fieldcat-col_pos =  mpos.
1310     ist_fieldcat-seltext_m  = 'Doc.No.'.
1311     ist_fieldcat-lowercase  = 'Y'.
1312     append ist_fieldcat to ist_fcat.
1313     clear ist_fieldcat.
1314
1315     mpos = mpos + 1.
1316     ist_fieldcat-fieldname = 'GSBER'.
1317     ist_fieldcat-tabname = 'IST_SRCBSID'.
1318     ist_fieldcat-ddictxt = 'M'.
1319     ist_fieldcat-col_pos =  mpos.
1320     ist_fieldcat-seltext_m  = 'Business Area'.
1321     ist_fieldcat-lowercase  = 'Y'.
1322     append ist_fieldcat to ist_fcat.
1323     clear ist_fieldcat.
1324
1325   *---+001
1326     mpos = mpos + 1.
1327     ist_fieldcat-fieldname = 'KIDNO'.
1328     ist_fieldcat-tabname = 'IST_SRCBSID'.
1329     ist_fieldcat-ddictxt = 'M'.
1330     ist_fieldcat-col_pos =  mpos.
1331     ist_fieldcat-seltext_m  = 'Payment Reference'.
1332     ist_fieldcat-lowercase  = 'Y'.
1333     append ist_fieldcat to ist_fcat.
1334     clear ist_fieldcat.
1335
1336   *-------+001
1337   *begin of <RD1K967585> CAB_ALOK 10.12.2009 CR30002778
1338     mpos = mpos + 1.
1339     ist_fieldcat-fieldname = 'REBZG'.
1340     ist_fieldcat-tabname = 'IST_SRCBSID'.
1341     ist_fieldcat-ddictxt = 'M'.
1342     ist_fieldcat-col_pos =  mpos.
1343     ist_fieldcat-seltext_m  = 'Invoice Reference'.
1344   *  ist_fieldcat-lowercase  = 'Y'.
1345     APPEND ist_fieldcat TO ist_fcat.
1346     CLEAR ist_fieldcat.
1347   *end of <RD1K967585> CAB_ALOK 10.12.2009 CR30002778
1348
1349     mpos = mpos + 1.
1350     ist_fieldcat-fieldname = 'GJAHR'.
1351     ist_fieldcat-tabname = 'IST_SRCBSID'.
1352     ist_fieldcat-ddictxt = 'M'.
1353     ist_fieldcat-col_pos =  mpos.
1354     ist_fieldcat-seltext_m  = 'Year'.
1355     ist_fieldcat-lowercase  = 'Y'.
1356     append ist_fieldcat to ist_fcat.
1357     clear ist_fieldcat.
1358
1359
1360
1361
1362     mpos = mpos + 1.
1363     ist_fieldcat-fieldname = 'BUZEI'.
1364     ist_fieldcat-tabname = 'IST_SRCBSID'.
1365     ist_fieldcat-ddictxt = 'M'.
1366     ist_fieldcat-col_pos =  mpos.
1367     ist_fieldcat-seltext_m  = 'Item.no.'.
1368     ist_fieldcat-lowercase  = 'Y'.
1369     append ist_fieldcat to ist_fcat.
1370     clear ist_fieldcat.
1371
1372     mpos = mpos + 1.
1373     ist_fieldcat-fieldname = 'BSCHL'.
1374     ist_fieldcat-tabname = 'IST_SRCBSID'.
1375     ist_fieldcat-ddictxt = 'M'.
1376     ist_fieldcat-col_pos =  mpos.
1377     ist_fieldcat-seltext_m  = 'Posting Key.'.
1378     ist_fieldcat-lowercase  = 'Y'.
1379     append ist_fieldcat to ist_fcat.
1380     clear ist_fieldcat.
1381
1382     mpos = mpos + 1.
1383     ist_fieldcat-fieldname = 'BUDAT'.
1384     ist_fieldcat-tabname = 'IST_SRCBSID'.
1385     ist_fieldcat-ddictxt = 'M'.
1386     ist_fieldcat-col_pos =  mpos.
1387     ist_fieldcat-seltext_m  = 'Posting Date'.
1388     ist_fieldcat-lowercase  = 'Y'.
1389     append ist_fieldcat to ist_fcat.
1390     clear ist_fieldcat.
1391
1392
1393     mpos = mpos + 1.
1394     ist_fieldcat-fieldname = 'DMBTR'.
1395     ist_fieldcat-tabname = 'IST_SRCBSID'.
1396     ist_fieldcat-ddictxt = 'M'.
1397     ist_fieldcat-col_pos =  mpos.
1398     ist_fieldcat-seltext_m  = 'AmtInLclCurncy'.
1399     ist_fieldcat-lowercase  = 'Y'.
1400     append ist_fieldcat to ist_fcat.
1401     clear ist_fieldcat.
1402
1403
1404
1405     mpos = mpos + 1.
1406     ist_fieldcat-fieldname = 'WRBTR'.
1407     ist_fieldcat-tabname = 'IST_SRCBSID'.
1408     ist_fieldcat-ddictxt = 'M'.
1409     ist_fieldcat-col_pos =  mpos.
1410     ist_fieldcat-seltext_m  = 'AmtInDocCurncy'.
1411     ist_fieldcat-lowercase  = 'Y'.
1412     append ist_fieldcat to ist_fcat.
1413     clear ist_fieldcat.
1414
1415     mpos = mpos + 1.
1416     ist_fieldcat-fieldname = 'ZLSCH'.
1417     ist_fieldcat-tabname = 'IST_SRCBSID'.
1418     ist_fieldcat-ddictxt = 'M'.
1419     ist_fieldcat-col_pos =  mpos.
1420     ist_fieldcat-seltext_m  = 'PaymentMethod.'.
1421     ist_fieldcat-lowercase  = 'Y'.
1422     append ist_fieldcat to ist_fcat.
1423     clear ist_fieldcat.
1424
1425
1426     mpos = mpos + 1.
1427     ist_fieldcat-fieldname = 'ZLSPR'.
1428     ist_fieldcat-tabname = 'IST_SRCBSID'.
1429     ist_fieldcat-ddictxt = 'M'.
1430     ist_fieldcat-col_pos =  mpos.
1431     ist_fieldcat-seltext_m  = 'PaymntBlock'.
1432     ist_fieldcat-lowercase  = 'Y'.
1433     append ist_fieldcat to ist_fcat.
1434     clear ist_fieldcat.
1435   *Start of addition Prabu K on 06.07.2009
1436
1437     mpos = mpos + 1.
1438     ist_fieldcat-fieldname = 'XREF1_HD'.
1439     ist_fieldcat-tabname = 'IST_SRCBSID'.
1440     ist_fieldcat-ddictxt = 'M'.
1441     ist_fieldcat-col_pos =  mpos.
1442     ist_fieldcat-seltext_m  = 'Location'.
1443     ist_fieldcat-lowercase  = 'Y'.
1444     append ist_fieldcat to ist_fcat.
1445     clear ist_fieldcat.
1446   *  End of addition Prabu K on 06.07.2009
1447   endform.                    " init_fieldcat_cust
1448   *-----end of +<RD1K960891>
1449
1450
1451   *&---------------------------------------------------------------------*
1452   *&      Form  UPDATE_ZFI_REM_PYBLCK_L
1453   *&---------------------------------------------------------------------*
1454   *       text
1455   *----------------------------------------------------------------------*
1456   *  -->  p1        text
1457   *  <--  p2        text
1458   *----------------------------------------------------------------------*
1459   *begin of <RD1K967585> CAB_ALOK 10.12.2009 CR30002778
1460   FORM UPDATE_ZFI_REM_PYBLCK_L .
1461   * update Logs to table ZFI_REM_PYBLCK_L
1462   data: ist_ZFI_REM_PYBLCK_L type table of ZFI_REM_PYBLCK_L,
1463         wa_ZFI_REM_PYBLCK_L type ZFI_REM_PYBLCK_L.
1464   data: count type ZFI_REM_PYBLCK_L-SRNO.
1465
1466
1467
1468   select max( SRNO ) from ZFI_REM_PYBLCK_L into count.
1469   if not ist_srcbsik is initial.
1470
1471    loop at ist_srcbsik into wa_srcbsik.
1472      count = count + 1.
1473
1474      wa_ZFI_REM_PYBLCK_L-SRNO = count.
1475      wa_ZFI_REM_PYBLCK_L-BUKRS = wa_srcbsik-BUKRS.
1476      wa_ZFI_REM_PYBLCK_L-LIFNR = wa_srcbsik-LIFNR.
1477   *wa_ZFI_REM_PYBLCK_L-KUNNR = wa_srcbsik-KUNNR.
1478      wa_ZFI_REM_PYBLCK_L-BELNR = wa_srcbsik-BELNR.
1479      wa_ZFI_REM_PYBLCK_L-KIDNO = wa_srcbsik-KIDNO.
1480      wa_ZFI_REM_PYBLCK_L-REBZG = wa_srcbsik-REBZG.
1481      wa_ZFI_REM_PYBLCK_L-SHKZG = wa_srcbsik-SHKZG.
1482      wa_ZFI_REM_PYBLCK_L-GJAHR = wa_srcbsik-GJAHR.
1483      wa_ZFI_REM_PYBLCK_L-BUZEI = wa_srcbsik-BUZEI.
1484      wa_ZFI_REM_PYBLCK_L-BSCHL = wa_srcbsik-BSCHL.
1485      wa_ZFI_REM_PYBLCK_L-BUDAT = wa_srcbsik-BUDAT.
1486      wa_ZFI_REM_PYBLCK_L-DMBTR = wa_srcbsik-DMBTR .
1487      wa_ZFI_REM_PYBLCK_L-WRBTR = wa_srcbsik-WRBTR .
1488      wa_ZFI_REM_PYBLCK_L-ZLSCH = wa_srcbsik-ZLSCH.
1489      wa_ZFI_REM_PYBLCK_L-PMTBLOCK_FROM = p_zlsprf.
1490      wa_ZFI_REM_PYBLCK_L-PMTBLOCK_TO = p_zlsprt.
1491      wa_ZFI_REM_PYBLCK_L-LOCATION = wa_srcbsik-XREF1_HD.
1492      wa_ZFI_REM_PYBLCK_L-UNAME = sy-UNAME.
1493      wa_ZFI_REM_PYBLCK_L-USDATE = sy-datum.
1494      wa_ZFI_REM_PYBLCK_L-USTIME = sy-uzeit.
1495
1496      insert ZFI_REM_PYBLCK_L from wa_ZFI_REM_PYBLCK_L.
1497    endloop.
1498     commit work.
1499     refresh ist_srcbsik.
1500   endif.
1501
1502   if not ist_srcbsid is initial.
1503
1504    loop at ist_srcbsid into wa_srcbsid.
1505      count = count + 1.
1506
1507      wa_ZFI_REM_PYBLCK_L-SRNO = count.
1508      wa_ZFI_REM_PYBLCK_L-BUKRS = wa_srcbsid-BUKRS.
1509   *   wa_ZFI_REM_PYBLCK_L-LIFNR = wa_srcbsid-LIFNR.
1510      wa_ZFI_REM_PYBLCK_L-KUNNR = wa_srcbsid-KUNNR.
1511      wa_ZFI_REM_PYBLCK_L-BELNR = wa_srcbsid-BELNR.
1512      wa_ZFI_REM_PYBLCK_L-KIDNO = wa_srcbsid-KIDNO.
1513      wa_ZFI_REM_PYBLCK_L-REBZG = wa_srcbsid-REBZG.
1514      wa_ZFI_REM_PYBLCK_L-SHKZG = wa_srcbsid-SHKZG.
1515      wa_ZFI_REM_PYBLCK_L-GJAHR = wa_srcbsid-GJAHR.
1516      wa_ZFI_REM_PYBLCK_L-BUZEI = wa_srcbsid-BUZEI.
1517      wa_ZFI_REM_PYBLCK_L-BSCHL = wa_srcbsid-BSCHL.
1518      wa_ZFI_REM_PYBLCK_L-BUDAT = wa_srcbsid-BUDAT.
1519      wa_ZFI_REM_PYBLCK_L-DMBTR = wa_srcbsid-DMBTR .
1520      wa_ZFI_REM_PYBLCK_L-WRBTR = wa_srcbsid-WRBTR .
1521      wa_ZFI_REM_PYBLCK_L-ZLSCH = wa_srcbsid-ZLSCH.
1522      wa_ZFI_REM_PYBLCK_L-PMTBLOCK_FROM = p_zlsprf.
1523      wa_ZFI_REM_PYBLCK_L-PMTBLOCK_TO = p_zlsprt.
1524      wa_ZFI_REM_PYBLCK_L-LOCATION = wa_srcbsid-XREF1_HD.
1525      wa_ZFI_REM_PYBLCK_L-UNAME = sy-UNAME.
1526      wa_ZFI_REM_PYBLCK_L-USDATE = sy-datum.
1527      wa_ZFI_REM_PYBLCK_L-USTIME = sy-uzeit.
1528
1529      insert ZFI_REM_PYBLCK_L from wa_ZFI_REM_PYBLCK_L.
1530    endloop.
1531     commit work.
1532     refresh ist_srcbsid.
1533   endif.
1534   ENDFORM.                    " UPDATE_ZFI_REM_PYBLCK_L
1535   *end of <RD1K967585> CAB_ALOK 14.12.2009 CR30002778
1536
1537   *-- S/4 helper: change BSEG payment block via FI_DOCUMENT_CHANGE - SAP_ABAP 16.06.2026 --
1538   FORM zz_s4_bseg_zlspr USING p_bukrs p_belnr p_gjahr p_buzei p_zlspr.
1539     DATA: lt_acchg TYPE STANDARD TABLE OF accchg, ls_acchg TYPE accchg.
1540     REFRESH lt_acchg. CLEAR ls_acchg.
1541     ls_acchg-fdname = 'ZLSPR'. ls_acchg-newval = p_zlspr.
1542     APPEND ls_acchg TO lt_acchg.
1543     CALL FUNCTION 'FI_DOCUMENT_CHANGE' EXPORTING i_bukrs = p_bukrs i_belnr = p_belnr i_gjahr = p_gjahr
1544          i_buzei = p_buzei TABLES t_acchg = lt_acchg EXCEPTIONS OTHERS = 0.
1545   ENDFORM.
*--- End of ZFI_REP_BLOCK - 1545 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CSLIS                                   Level 1    Page 2
Object           ZFI_REP_BLOCK                             Lines 543
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:29
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
Generated incl.  <REPINI>                                  Level 1    Page 3
Object           ZFI_REP_BLOCK                             Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:29
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
Object           ZFI_REP_BLOCK                             Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:29
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
Object           ZFI_REP_BLOCK                             Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:29
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
Generated incl.  DB__SSEL                                  Level 1    Page 6
Object           ZFI_REP_BLOCK                             Lines 1
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:29
----------------------------------------------------------------------------------------------------
1      * INCLUDE DB__SSEL
*--- End of DB__SSEL - 1 lines ---
