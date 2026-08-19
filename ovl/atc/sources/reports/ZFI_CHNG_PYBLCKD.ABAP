----------------------------------------------------------------------------------------------------
Main program     ZFI_CHNG_PYBLCKD                          Level 0    Page 1
Object           ZFI_CHNG_PYBLCKD                          Lines 1798
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:01
----------------------------------------------------------------------------------------------------
1      REPORT zfi_chng_pyblck .
2
3      *-----  PROGRAM FOR Changing payment blocks 'X'  ****
4      ***********************************************************************
5      * Program    :                                                        *
6      *                                                                     *
7      *                                                                     *
8      * Author     : S.R.Sudha                     Date : 14.03.2008
9      *
10     *                                                                     *
11     * Login Id   : CAB_SUDHA                                              *
12     *                                                                      *
13     * Description: For Changing payment blocks in documents for vendor as *
14     *               per i/p 'A'
15     *
16     *                                                                     *
17     * Tran.Code  : ZFIBLOCKA
18     *
19     ***********************************************************************
20     ***********************************************************************
21     *  Date        Transport     USERID       Description                  *
22     * 24/11/2008   <RD1K960611>  CAB_SUDHA    Form call eventtab_build,
23     *                                         comment_build  sts  changed
24     *                                         After removing []
25     * 11.12.2009    RD1K967585  CAB_ALOK     CR30002778
26     *                                         Addition of INV REF in Report,
27     *                                         Creation of activity logs
28     ***********************************************************************
29
30     TYPE-POOLS : slis.
31
32     TABLES : bsik , t001 , bkpf, bsid.
33
34
35     DATA : ist_bsik  TYPE TABLE OF bsik.
36     DATA : ist_bseg TYPE TABLE OF  bseg.
37     DATA : wa_bsik  TYPE bsik.
38     DATA : wa_bseg TYPE  bseg.
39
40     DATA: BEGIN OF ist_bkpf OCCURS 0,
41           blart LIKE bkpf-blart,
42           belnr LIKE bkpf-belnr,
43           bldat LIKE bkpf-bldat,
44           budat LIKE bkpf-budat,
45           waers LIKE bkpf-waers,
46           usnam LIKE bkpf-usnam,
47           ppnam LIKE bkpf-ppnam,
48           gjahr LIKE bkpf-gjahr, "Added PN
49           bukrs LIKE bkpf-bukrs, "Added PN
50           END OF ist_bkpf.
51
52     DATA : BEGIN OF ist_srcbsik OCCURS 0 ,
53            selcbox(1) TYPE c,
54            lifnr LIKE bsik-lifnr ,
55            umskz LIKE bsik-umskz,
56            bukrs LIKE bsik-bukrs ,
57            gjahr LIKE bsik-gjahr,
58            belnr  LIKE bsik-belnr,
59            buzei  LIKE bsik-buzei,
60            budat  LIKE bsik-budat,
61            bschl LIKE bsik-bschl,
62            zlsch like bsik-zlsch,                               "+002
63            zlspr LIKE  bsik-zlspr,
64            shkzg LIKE bsik-shkzg,
65            gsber LIKE bsik-gsber,
66            dmbtr LIKE bsik-dmbtr,
67            wrbtr LIKE bsik-wrbtr,
68     *Begin of <RD1K967585> CAB_ALOK 10.12.2009 CR30002778
69            rebzg LIKE bsik-rebzg,        " Invoice Ref.
70     *end of <RD1K967585> CAB_ALOK 10.12.2009 CR30002778
71            usnam  LIKE bkpf-usnam,
72         xref1_hd like bkpf-xref1_hd,
73     *Begin of <RD1K981735> CAB_RAMA CR 30007748
74     kidno LIKE  bsik-kidno.     " Payment Ref.
75     *End of <RD1K981735> CAB_RAMA CR 30007748
76     DATA:  END OF ist_srcbsik .
77
78     DATA : wa_srcbsik LIKE ist_srcbsik.
79     DATA : ist_bsiks LIKE ist_srcbsik OCCURS 0 WITH HEADER LINE.
80     DATA : y_doc_nos LIKE zfi_docnos OCCURS 0 WITH HEADER LINE .
81     DATA : f_doc_nos LIKE zfi_docnos OCCURS 0 WITH HEADER LINE .
82
83     *------Start of  <RD1K960891>
84     DATA : BEGIN OF ist_srcbsid OCCURS 0 ,
85            selcbox(1) TYPE c,
86            kunnr LIKE bsid-kunnr ,
87            umskz LIKE bsid-umskz,
88            bukrs LIKE bsid-bukrs ,
89            gjahr LIKE bsid-gjahr,
90            belnr  LIKE bsid-belnr,
91            buzei  LIKE bsid-buzei,
92            budat  LIKE bsid-budat,
93            bschl LIKE bsid-bschl,
94            zlsch LIKE bsid-zlsch,                               "+002
95            zlspr LIKE  bsid-zlspr,
96            shkzg LIKE bsid-shkzg,
97            gsber LIKE  bsid-gsber,
98            dmbtr LIKE bsid-dmbtr,
99            wrbtr LIKE bsid-wrbtr,
100           kidno LIKE  bsid-kidno,                              "+001
101    *Begin of <RD1K967585> CAB_ALOK 10.12.2009 CR30002778
102           rebzg LIKE bsid-rebzg,        " Invoice Ref.
103    *end of <RD1K967585> CAB_ALOK 10.12.2009 CR30002778
104           usnam  LIKE bkpf-usnam,
105        xref1_hd like bkpf-xref1_hd.
106    *       include structure  bsis.
107    DATA:  END OF ist_srcbsid .
108
109    DATA : wa_srcbsid LIKE ist_srcbsid.
110    DATA : ist_bsids LIKE ist_srcbsid OCCURS 0 WITH HEADER LINE.
111    DATA : ist_bsid  TYPE TABLE OF bsid.
112    DATA : wa_bsid  TYPE bsid.
113    *----End of <RD1K960891>
114
115    DATA : w_repid TYPE sy-repid.
116
117    DATA:  is_layout  TYPE  slis_layout_alv,
118           ist_fieldcat TYPE  slis_fieldcat_alv  , "line.
119           ist_fcat TYPE  TABLE OF slis_fieldcat_alv,
120            lt_sorttab TYPE slis_t_sortinfo_alv,
121           ls_sorttab TYPE slis_sortinfo_alv. " sort structure for ALV
122
123
124
125    DATA  : mpos TYPE i .
126    DATA : gt_list_top_of_page TYPE slis_t_listheader,
127           gt_list_end_of_list TYPE slis_t_listheader,
128           gt_events   TYPE slis_t_event.
129    *begin of <RD1K967585> CAB_ALOK 14.12.2009 CR30002778
130    data : PMTBLOCK_TO type bsik-zlspr.
131    *end of <RD1K967585> CAB_ALOK 14.12.2009 CR30002778
132    *-------selection-screen---------------------*
133    *Begin of <RD1K981735> CAB_RAMA CR 30007748
134    DATA : ist_srcbsik_l LIKE ist_srcbsik OCCURS 0 WITH HEADER LINE.
135    DATA : wa_srcbsik_l LIKE ist_srcbsik.
136    data : l_err.
137    *End of <RD1K981735> CAB_RAMA CR 30007748
138    SELECTION-SCREEN : BEGIN OF BLOCK  blk1  WITH FRAME TITLE  text-001.
139
140    SELECT-OPTIONS : s_lifnr FOR bsik-lifnr ,   "<RD1K960891>
141                     s_kunnr FOR bsid-kunnr ,   "<RD1K960891>
142                     s_year  FOR bsik-gjahr OBLIGATORY,
143                     s_gsber FOR bsik-gsber,
144                     s_budat FOR bsik-budat,
145                     s_usnam FOR bkpf-usnam,
146    *  Start of addition Prabu K on 06.07.2009
147                     s_xref1 for bkpf-xref1_hd.
148
149    *  End of addition Prabu K on 06.07.2009
150    PARAMETERS :  p_bukrs LIKE bsik-bukrs OBLIGATORY .
151    SELECT-OPTIONS : S_DOCNO FOR BSIK-BELNR.
152
153    SELECTION-SCREEN : END OF BLOCK blk1.
154    SELECTION-SCREEN : BEGIN OF BLOCK  blk2  WITH FRAME .
155    selection-screen begin of  line .
156    SELECTION-SCREEN COMMENT 2(40) text-002 FOR FIELD p_any2D .
157    PARAMETERS : p_any2D RADIOBUTTON GROUP rad1  .
158    selection-screen end of line.
159    selection-screen begin of  line .
160    SELECTION-SCREEN COMMENT 2(40) text-003 FOR FIELD p_d2x.
161    PARAMETERS :  p_d2x RADIOBUTTON GROUP rad1   .
162    selection-screen end of line.
163    *selection-screen begin of  line .
164    **-------+003
165    *SELECTION-SCREEN COMMENT 2(70) text-004 FOR FIELD p_r2x.
166    *PARAMETERS :  p_r2x RADIOBUTTON GROUP rad1.
167    *selection-screen end of line.
168    *SELECTION-SCREEN : END OF BLOCK blk2.
169    **------+003
170    SELECTION-SCREEN : END OF BLOCK blk2.
171
172    *------------end selection screen--------------*
173
174    CONSTANTS  : g_zlspr_x   LIKE bseg-zlspr  VALUE 'X',
175                 g_zlspr_d   LIKE bseg-zlspr VALUE 'D'.
176    *             g_zlspr_r  LIKE bseg-zlspr  VALUE 'R'.
177
178
179    *---------------------events -----------------------*
180
181    * *Start of addition Prabu K on 11.07.2009
182    AT SELECTION-SCREEN on VALUE-REQUEST FOR s_xref1-low.
183
184
185      types : begin of ty_t526,
186              sachx type sachx,
187              werks type SBMOD,
188              end of ty_t526.
189
190      types: begin of ty_final,
191             bukrs type bukrs,
192             persa type persa,
193             sachx type sachx,
194             end of ty_final.
195      types: begin of ty_t5009,
196             persa type persa,
197             bukrs type bukrs,
198             end of ty_t5009.
199      data: lv_area type standard table of ty_t526 ,
200              wa_area LIKE LINE OF lv_area.
201
202      data: it_t5009 type standard table of ty_t5009 ,
203              wa_t5009 like line of  it_t5009.
204
205      data: it_final type standard table of ty_final ,
206              wa_final like line of  it_final.
207
208      select sachx werks from t526 into corresponding fields of table lv_area.  "#EC CI_NOORDER
209
210      sort lv_area by sachx.
211      delete adjacent duplicates from lv_area
212      comparing sachx.
213
214    *  select persa bukrs  from t500p into table it_t5009 for all entries
215    *                         in lv_area where persa = lv_area-sachx.
216
217      select persa bukrs  from t500p into CORRESPONDING FIELDS OF TABLE it_t5009.
218
219      sort it_t5009  by persa.
220      delete adjacent duplicates from it_t5009
221      comparing persa.
222
223      loop at lv_area into wa_area.
224
225        read table it_t5009 into wa_t5009 WITH KEY persa = wa_area-werks.
226        wa_final-sachx = wa_area-sachx.
227        wa_final-persa = wa_t5009-persa.
228        wa_final-bukrs = wa_t5009-bukrs.
229        append wa_final to it_final.
230      endloop.
231      call function 'F4IF_INT_TABLE_VALUE_REQUEST'
232        EXPORTING
233          retfield        = 'SACHX'
234          dynpprog        = 'ZFI_REM_PYBLCK'
235          dynpnr          = sy-dynnr
236          dynprofield     = 'S_XREF1-LOW'
237          value_org       = 'S'
238        TABLES
239          value_tab       = it_final
240        EXCEPTIONS
241          parameter_error = 1
242          no_values_found = 2
243          others          = 3.
244
245      if sy-subrc <> 0.
246    *
247    *    message id sy-msgid type sy-msgty number sy-msgno
248    *            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
249
250      endif.
251
252    at selection-screen on value-request for s_xref1-high.
253      types : begin of ty_t526,
254              sachx type sachx,
255              werks type SBMOD,
256              end of ty_t526.
257
258      types: begin of ty_final,
259             bukrs type bukrs,
260             persa type persa,
261             sachx type sachx,
262             end of ty_final.
263      types: begin of ty_t5009,
264             persa type persa,
265             bukrs type bukrs,
266             end of ty_t5009.
267      data: lv_area type standard table of ty_t526 ,
268              wa_area LIKE LINE OF lv_area.
269
270      data: it_t5009 type standard table of ty_t5009 ,
271              wa_t5009 like line of  it_t5009.
272
273      data: it_final type standard table of ty_final ,
274              wa_final like line of  it_final.
275
276      select sachx werks from t526 into corresponding fields of table lv_area.  "#EC CI_NOORDER
277
278      sort lv_area by sachx.
279      delete adjacent duplicates from lv_area
280      comparing sachx.
281
282    *  select persa bukrs  from t500p into table it_t5009 for all entries
283    *                         in lv_area where persa = lv_area-sachx.
284
285      select persa bukrs  from t500p into CORRESPONDING FIELDS OF TABLE it_t5009.
286
287      sort it_t5009  by persa.
288      delete adjacent duplicates from it_t5009
289      comparing persa.
290
291      loop at lv_area into wa_area.
292
293        read table it_t5009 into wa_t5009 WITH KEY persa = wa_area-werks.
294        wa_final-sachx = wa_area-sachx.
295        wa_final-persa = wa_t5009-persa.
296        wa_final-bukrs = wa_t5009-bukrs.
297        append wa_final to it_final.
298      endloop.
299      call function 'F4IF_INT_TABLE_VALUE_REQUEST'
300        EXPORTING
301          retfield        = 'SACHX'
302          dynpprog        = 'ZFI_REM_PYBLCK'
303          dynpnr          = sy-dynnr
304          dynprofield     = 'S_XREF1-HIGH'
305          value_org       = 'S'
306        TABLES
307          value_tab       = it_final
308        EXCEPTIONS
309          parameter_error = 1
310          no_values_found = 2
311          others          = 3.
312
313      if sy-subrc <> 0.
314    *
315    *    message id sy-msgid type sy-msgty number sy-msgno
316    *            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
317
318      endif.
319    * End of addition Prabu K on 11.07.2009
320
321    AT SELECTION-SCREEN ON p_bukrs .
322      SELECT SINGLE * FROM t001  WHERE bukrs = p_bukrs.
323      IF sy-subrc <> 0.
324        MESSAGE e010(fi).
325      ENDIF.
326    *----Start of <RD1K960891>
327
328      AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
329                   ID 'ACTVT' FIELD '02'
330                   ID 'BUKRS' FIELD p_bukrs.
331
332      IF sy-subrc <> 0.
333        MESSAGE  e091(8B) WITH p_bukrs.
334      ENDIF.
335
336    *----End of <RD1K960891>
337
338
339
340    *------------------------------------------------------*
341    START-OF-SELECTION.
342    *------------------------------------------------------*
343    *----Start of <RD1K960891>
344      IF s_lifnr IS INITIAL AND s_kunnr IS INITIAL.
345        MESSAGE   e322(zfi).
346      ENDIF.
347      IF  NOT  s_lifnr IS INITIAL  AND  NOT s_kunnr IS INITIAL .
348        MESSAGE   e322(zfi).
349      ENDIF.
350
351      IF NOT s_lifnr  IS INITIAL.
352        PERFORM   get_rel_docs.
353        PERFORM   display_docs.
354      ELSEIF  NOT s_kunnr IS INITIAL.
355        PERFORM get_docs_cust.
356        PERFORM display_docs_cust.
357      ENDIF.
358
359    *----End of <RD1K960891>
360    *&---------------------------------------------------------------------*
361    *&      Form  display_docs
362    *&---------------------------------------------------------------------*
363    *       text
364    *----------------------------------------------------------------------*
365    *  -->  p1        text
366    *  <--  p2        text
367    *----------------------------------------------------------------------*
368    FORM display_docs.
369      PERFORM init_fieldcat.
370      PERFORM eventtab_build USING gt_events[].
371      PERFORM comment_build USING gt_list_top_of_page[].
372      PERFORM  sort_build .
373      PERFORM  print_alv.
374
375    ENDFORM.                    " display_docs
376    *&---------------------------------------------------------------------*
377    *&      Form  init_fieldcat
378    *&---------------------------------------------------------------------*
379    *       text
380    *----------------------------------------------------------------------*
381    *  -->  p1        text
382    *  <--  p2        text
383    *----------------------------------------------------------------------*
384    FORM init_fieldcat.
385      w_repid  = sy-repid.
386
387      mpos = 0.
388      mpos = mpos + 1.
389      ist_fieldcat-fieldname = 'SELCBOX'.
390      ist_fieldcat-tabname = 'IST_SRCBSIK'.
391      ist_fieldcat-ddictxt = 'M'.
392      ist_fieldcat-col_pos =  mpos.
393      ist_fieldcat-seltext_m  = 'Select'.
394      ist_fieldcat-lowercase  = 'Y'.
395      ist_fieldcat-checkbox = 'X'.
396      ist_fieldcat-input = 'X'.
397      APPEND ist_fieldcat TO ist_fcat.
398      CLEAR ist_fieldcat.
399
400
401
402      mpos = mpos + 1.
403      ist_fieldcat-fieldname = 'LIFNR'.
404      ist_fieldcat-tabname = 'IST_SRCBSIK'.
405      ist_fieldcat-ddictxt = 'M'.
406      ist_fieldcat-col_pos =  mpos.
407      ist_fieldcat-seltext_m  = 'VendorNumber '.
408      ist_fieldcat-lowercase  = 'Y'.
409      APPEND ist_fieldcat TO ist_fcat.
410      CLEAR ist_fieldcat.
411
412
413      mpos = mpos + 1.
414      ist_fieldcat-fieldname = 'BELNR'.
415      ist_fieldcat-tabname = 'IST_SRCBSIK'.
416      ist_fieldcat-ddictxt = 'M'.
417      ist_fieldcat-col_pos =  mpos.
418      ist_fieldcat-seltext_m  = 'Doc.No.'.
419      ist_fieldcat-lowercase  = 'Y'.
420      APPEND ist_fieldcat TO ist_fcat.
421      CLEAR ist_fieldcat.
422
423
424      mpos = mpos + 1.
425      ist_fieldcat-fieldname = 'BUZEI'.
426      ist_fieldcat-tabname = 'IST_SRCBSIK'.
427      ist_fieldcat-ddictxt = 'M'.
428      ist_fieldcat-col_pos =  mpos.
429      ist_fieldcat-seltext_m  = 'Item.no.'.
430      ist_fieldcat-lowercase  = 'Y'.
431      APPEND ist_fieldcat TO ist_fcat.
432      CLEAR ist_fieldcat.
433
434      mpos = mpos + 1.
435      ist_fieldcat-fieldname = 'GSBER'.
436      ist_fieldcat-tabname = 'IST_SRCBSIK'.
437      ist_fieldcat-ddictxt = 'M'.
438      ist_fieldcat-col_pos =  mpos.
439      ist_fieldcat-seltext_m  = 'Business Area'.
440      ist_fieldcat-lowercase  = 'Y'.
441      APPEND ist_fieldcat TO ist_fcat.
442      CLEAR ist_fieldcat.
443
444    *BEGIN of <RD1K967585> CAB_ALOK 14.12.2009 CR30002778
445      mpos = mpos + 1.
446      ist_fieldcat-fieldname = 'REBZG'.
447      ist_fieldcat-tabname = 'IST_SRCBSIK'.
448      ist_fieldcat-ddictxt = 'M'.
449      ist_fieldcat-col_pos =  mpos.
450      ist_fieldcat-seltext_m  = 'Invoice Reference'.
451    *  ist_fieldcat-lowercase  = 'Y'.
452      APPEND ist_fieldcat TO ist_fcat.
453      CLEAR ist_fieldcat.
454
455      mpos = mpos + 1.
456      ist_fieldcat-fieldname = 'KIDNO'.
457      ist_fieldcat-tabname = 'IST_SRCBSIK'.
458      ist_fieldcat-ddictxt = 'M'.
459      ist_fieldcat-col_pos =  mpos.
460      ist_fieldcat-seltext_m  = 'Payment Reference'.
461    *  ist_fieldcat-lowercase  = 'Y'.
462      APPEND ist_fieldcat TO ist_fcat.
463      CLEAR ist_fieldcat.
464    *end of <RD1K967585> CAB_ALOK 14.12.2009 CR30002778
465
466      mpos = mpos + 1.
467      ist_fieldcat-fieldname = 'BSCHL'.
468      ist_fieldcat-tabname = 'IST_SRCBSIK'.
469      ist_fieldcat-ddictxt = 'M'.
470      ist_fieldcat-col_pos =  mpos.
471      ist_fieldcat-seltext_m  = 'Posting Key.'.
472      ist_fieldcat-lowercase  = 'Y'.
473      APPEND ist_fieldcat TO ist_fcat.
474      CLEAR ist_fieldcat.
475
476
477
478
479      mpos = mpos + 1.
480      ist_fieldcat-fieldname = 'BUDAT'.
481      ist_fieldcat-tabname = 'IST_SRCBSIK'.
482      ist_fieldcat-ddictxt = 'M'.
483      ist_fieldcat-col_pos =  mpos.
484      ist_fieldcat-seltext_m  = 'Posting Date'.
485      ist_fieldcat-lowercase  = 'Y'.
486      APPEND ist_fieldcat TO ist_fcat.
487      CLEAR ist_fieldcat.
488
489
490      mpos = mpos + 1.
491      ist_fieldcat-fieldname = 'DMBTR'.
492      ist_fieldcat-tabname = 'IST_SRCBSIK'.
493      ist_fieldcat-ddictxt = 'M'.
494      ist_fieldcat-col_pos =  mpos.
495      ist_fieldcat-seltext_m  = 'AmtInLclCurncy'.
496      ist_fieldcat-lowercase  = 'Y'.
497      APPEND ist_fieldcat TO ist_fcat.
498      CLEAR ist_fieldcat.
499
500
501
502      mpos = mpos + 1.
503      ist_fieldcat-fieldname = 'WRBTR'.
504      ist_fieldcat-tabname = 'IST_SRCBSIK'.
505      ist_fieldcat-ddictxt = 'M'.
506      ist_fieldcat-col_pos =  mpos.
507      ist_fieldcat-seltext_m  = 'AmtInDocCurncy'.
508      ist_fieldcat-lowercase  = 'Y'.
509      APPEND ist_fieldcat TO ist_fcat.
510      CLEAR ist_fieldcat.
511
512
513      mpos = mpos + 1.
514      ist_fieldcat-fieldname = 'ZLSCH'.
515      ist_fieldcat-tabname = 'IST_SRCBSIK'.
516      ist_fieldcat-ddictxt = 'M'.
517      ist_fieldcat-col_pos =  mpos.
518      ist_fieldcat-seltext_m  = 'PaymntMethod'.
519      ist_fieldcat-lowercase  = 'Y'.
520      APPEND ist_fieldcat TO ist_fcat.
521      CLEAR ist_fieldcat.
522
523
524
525      mpos = mpos + 1.
526      ist_fieldcat-fieldname = 'ZLSPR'.
527      ist_fieldcat-tabname = 'IST_SRCBSIK'.
528      ist_fieldcat-ddictxt = 'M'.
529      ist_fieldcat-col_pos =  mpos.
530      ist_fieldcat-seltext_m  = 'PaymntBlock'.
531      ist_fieldcat-lowercase  = 'Y'.
532      APPEND ist_fieldcat TO ist_fcat.
533      CLEAR ist_fieldcat.
534
535
536    *  *Start of addition Prabu K on 06.07.2009
537      mpos = mpos + 1.
538      ist_fieldcat-fieldname = 'XREF1_HD'.
539      ist_fieldcat-tabname = 'IST_SRCBSIK'.
540      ist_fieldcat-ddictxt = 'M'.
541      ist_fieldcat-col_pos =  mpos.
542      ist_fieldcat-seltext_m  = 'Location'.
543      ist_fieldcat-lowercase  = 'Y'.
544      APPEND ist_fieldcat TO ist_fcat.
545      CLEAR ist_fieldcat.
546
547    * End of addition Prabu K on 06.07.2009
548
549      if not s_usnam[] is initial.
550        mpos = mpos + 1.
551        ist_fieldcat-fieldname = 'USNAM'.
552        ist_fieldcat-tabname = 'IST_SRCBSIK'.
553        ist_fieldcat-ddictxt = 'M'.
554        ist_fieldcat-col_pos =  mpos.
555        ist_fieldcat-seltext_m  = 'Created By'.
556        ist_fieldcat-lowercase  = 'Y'.
557        APPEND ist_fieldcat TO ist_fcat.
558        CLEAR ist_fieldcat.
559      endif.
560
561
562    ENDFORM.                    " init_fieldcat
563    *&---------------------------------------------------------------------*
564    *&      Form  eventtab_build
565    *&---------------------------------------------------------------------*
566    *       text
567    *----------------------------------------------------------------------*
568    *      -->P_GT_EVENTS[]  text
569    *----------------------------------------------------------------------*
570    *Begin of <RD1K960611>
571    *FORM eventtab_build USING    p_gt_events[].
572    FORM eventtab_build USING    p_gt_events.
573    *End of <RD1K960611>
574      DATA : ls_event TYPE slis_alv_event.
575      CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
576        EXPORTING
577          i_list_type = 0
578        IMPORTING
579          et_events   = gt_events.
580      READ TABLE gt_events WITH KEY name =  slis_ev_user_command
581                                INTO ls_event.
582      IF sy-subrc = 0.
583        MOVE 'MAKE_COMMAND' TO ls_event-form.
584        APPEND ls_event TO gt_events.
585      ENDIF.
586      CLEAR ls_event.
587
588
589    ENDFORM.                    " eventtab_build
590    *&---------------------------------------------------------------------*
591    *&      Form  comment_build
592    *&---------------------------------------------------------------------*
593    *       text
594    *----------------------------------------------------------------------*
595    *      -->P_GT_LIST_TOP_OF_PAGE[]  text
596    *----------------------------------------------------------------------*
597    *Begin of <RD1K960611>
598    *FORM comment_build USING    p_gt_list_top_of_page[].
599    FORM comment_build USING    p_gt_list_top_of_page.
600    *End of <RD1K960611>
601
602
603    ENDFORM.                    " comment_build
604    *&---------------------------------------------------------------------*
605    *&      Form  sort_build
606    *&---------------------------------------------------------------------*
607    *       text
608    *----------------------------------------------------------------------*
609    *  -->  p1        text
610    *  <--  p2        text
611    *----------------------------------------------------------------------*
612    FORM sort_build.
613      w_repid = sy-repid.
614      is_layout-key_hotspot = 'X'.
615      is_layout-colwidth_optimize = 'X'.
616      ls_sorttab-fieldname = 'LIFNR'.
617      ls_sorttab-up = 'X'.
618      APPEND ls_sorttab TO lt_sorttab.
619      ls_sorttab-fieldname = 'BSCHL'.
620      ls_sorttab-up = 'X'.
621      APPEND ls_sorttab TO lt_sorttab.
622      ls_sorttab-fieldname = 'BELNR'.
623      ls_sorttab-up = 'X'.
624      APPEND ls_sorttab TO lt_sorttab.
625      ls_sorttab-fieldname = 'BUDAT'.
626      ls_sorttab-up = 'X'.
627      APPEND ls_sorttab TO lt_sorttab.
628
629
630
631    ENDFORM.                    " sort_build
632    *&---------------------------------------------------------------------*
633    *&      Form  print_alv
634    *&---------------------------------------------------------------------*
635    *       text
636    *----------------------------------------------------------------------*
637    *  -->  p1        text
638    *  <--  p2        text
639    *----------------------------------------------------------------------*
640    FORM print_alv.
641      CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
642        EXPORTING
643          i_callback_program       = w_repid
644          i_callback_pf_status_set = 'ALV_PFST'
645          i_callback_user_command  = 'MAKE_COMMAND'
646          is_layout                = is_layout
647          it_fieldcat              = ist_fcat[]
648          it_sort                  = lt_sorttab
649          it_events                = gt_events
650          i_save                   = 'A'
651        TABLES
652          t_outtab                 = ist_srcbsik
653    * Begin of Changes on 20-Jun-2013
654        EXCEPTIONS
655          PROGRAM_ERROR = 1
656          OTHERS        = 2.
657    * End of Changes on 20-Jun-2013
658      IF sy-subrc <> 0.
659    *    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
660    *            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
661      ENDIF.
662
663
664    ENDFORM.                    " print_alv
665    *---------------------------------------------------------------------*
666    *       FORM alv_pfst                                                 *
667    *---------------------------------------------------------------------*
668    *       ........                                                      *
669    *---------------------------------------------------------------------*
670    *  -->  RT_EXTAB                                                      *
671    *---------------------------------------------------------------------*
672    FORM alv_pfst USING rt_extab TYPE slis_t_extab.
673      SET PF-STATUS 'S100'.
674    ENDFORM.                    "alv_pfst
675
676    *---------------------------------------------------------------------*
677    *       FORM make_command                                             *
678    *---------------------------------------------------------------------*
679    *       ........                                                      *
680    *---------------------------------------------------------------------*
681    *  -->  R_UCOMM                                                       *
682    *  -->  RS_SELFIELD                                                   *
683    *---------------------------------------------------------------------*
684    FORM make_command USING r_ucomm LIKE sy-ucomm
685                            rs_selfield TYPE slis_selfield.
686    *-----------------------------------------------------*
687    *-----------------------------------------------------*
688      DATA : index_aux LIKE sy-tabix.
689      index_aux = rs_selfield-tabindex.
690    *  break cab_alok.
691
692      CASE r_ucomm.
693        WHEN 'REL'.
694    *      if ist_srcbsik_l[] is initial.
695          if ist_srcbsik_l[] is initial or l_err = 'X'.
696            ist_srcbsik_l[] = ist_srcbsik[].
697          endif.
698
699    *      DELETE ist_srcbsik WHERE  selcbox <> 'X'.
700    *Begin of <RD1K981735> CAB_RAMA CR 30007748
701
702          IF p_d2x = 'X'.
703            loop at ist_srcbsik into wa_srcbsik where selcbox = 'X' AND KIDNO <> 'PERIOD END LIABILITY'.
704              if  ( wa_srcbsik-bschl = '31' or wa_srcbsik-bschl = '34' or wa_srcbsik-bschl = '36'
705                or wa_srcbsik-bschl = '39' or wa_srcbsik-bschl = '21' OR wa_srcbsik-bschl = '26').
706                loop at ist_srcbsik_l into wa_srcbsik_l
707                  where selcbox <> 'X' and ( bschl = '31' or bschl = '34' or bschl = '36' or bschl = '39'
708                  or bschl = '21'  or bschl = '26' )
709                  and kidno = wa_srcbsik-kidno
710                  AND KIDNO <> 'PERIOD END LIABILITY'
711                  and lifnr = wa_srcbsik-lifnr.
712                  l_err = 'X'.
713                  MESSAGE e100(zfi) WITH text-004.
714                endloop.
715              endif.
716            endloop.
717          ENDIF.
718    *{begin of CR 30007748
719
720          IF p_d2x = 'X'.
721            loop at ist_srcbsik into wa_srcbsik where selcbox = 'X' AND KIDNO <> 'PERIOD END LIABILITY'.
722              if  ( wa_srcbsik-bschl = '31' or wa_srcbsik-bschl = '34' or wa_srcbsik-bschl = '36'
723                or wa_srcbsik-bschl = '39' or wa_srcbsik-bschl = '21' OR wa_srcbsik-bschl = '26').
724                loop at ist_srcbsik_l into wa_srcbsik_l
725                  where selcbox <> 'X' and ( bschl = '31' or bschl = '34' or bschl = '36' or bschl = '39'
726                  or bschl = '21'  or bschl = '26' )
727                  and belnr = wa_srcbsik-rebzg
728                  AND KIDNO <> 'PERIOD END LIABILITY'
729                  and lifnr = wa_srcbsik-lifnr.
730                  l_err = 'X'.
731                  MESSAGE e100(zfi) WITH text-004.
732                endloop.
733
734    *            loop at ist_srcbsik_l into wa_srcbsik_l
735    *              where selcbox <> 'X' and ( bschl = '31' or bschl = '34' or bschl = '36' or bschl = '39'
736    *              or bschl = '21'  or bschl = '26' )
737    *              and rebzg = wa_srcbsik-belnr
738    **              AND KIDNO <> 'PERIOD END LIABILITY'
739    *              and lifnr = wa_srcbsik-lifnr.
740    *
741    *              MESSAGE e100(zfi) WITH text-004.
742    *            endloop.
743              endif.
744            endloop.
745            loop at ist_srcbsik into wa_srcbsik where selcbox = 'X'.
746              if  ( wa_srcbsik-bschl = '31' or wa_srcbsik-bschl = '34' or wa_srcbsik-bschl = '36'
747                or wa_srcbsik-bschl = '39' or wa_srcbsik-bschl = '21' OR wa_srcbsik-bschl = '26').
748                loop at ist_srcbsik_l into wa_srcbsik_l
749                    where selcbox <> 'X' and ( bschl = '31' or bschl = '34' or bschl = '36' or bschl = '39'
750                    or bschl = '21'  or bschl = '26' )
751                    and rebzg = wa_srcbsik-belnr
752    *              AND KIDNO <> 'PERIOD END LIABILITY'
753                    and lifnr = wa_srcbsik-lifnr.
754                  l_err = 'X'.
755                  MESSAGE e100(zfi) WITH text-005.
756                endloop.
757                loop at ist_srcbsik_l into wa_srcbsik_l
758                     where selcbox <> 'X' and ( bschl = '31' or bschl = '34' or bschl = '36' or bschl = '39'
759                     or bschl = '21'  or bschl = '26' )
760                     and belnr = wa_srcbsik-rebzg
761    *              AND KIDNO <> 'PERIOD END LIABILITY'
762                     and lifnr = wa_srcbsik-lifnr.
763                  l_err = 'X'.
764                  MESSAGE e100(zfi) WITH text-005.
765                endloop.
766              endif.
767            endloop.
768          ENDIF.
769          DELETE ist_srcbsik WHERE  selcbox <> 'X'.
770
771    *{end of CR 30007748
772    *END of <RD1K981735> CAB_RAMA CR 30007748
773          PERFORM   get_upd_bsik.
774          PERFORM   get_upd_bseg.
775    *Begin of <RD1K967585> CAB_ALOK 09.12.2009 CR30002778
776          PERFORM   UPDATE_ZFI_REM_PYBLCK_L.    "update logs
777    *end of <RD1K967585> CAB_ALOK 09.12.2009 CR30002778
778          LEAVE SCREEN.
779        WHEN 'ALL'.
780          PERFORM  select_all.
781        WHEN 'SAL'.
782          PERFORM  deselect_all.
783        WHEN '&F03' OR 'BACK' .
784          LEAVE  PROGRAM.
785
786      ENDCASE.
787
788    ENDFORM.                    "make_command
789    *---------------------------------------------------------------------*
790    *&      Form  select_all
791    *&---------------------------------------------------------------------*
792    *       text
793    *----------------------------------------------------------------------*
794    *  -->  p1        text
795    *  <--  p2        text
796    *----------------------------------------------------------------------*
797    FORM select_all.
798      LOOP AT ist_srcbsik.
799        ist_srcbsik-selcbox = 'X'.
800        MODIFY ist_srcbsik.
801      ENDLOOP.
802
803    ENDFORM.                    " select_all
804    *&---------------------------------------------------------------------*
805    *&      Form  deselect_all
806    *&---------------------------------------------------------------------*
807    *       text
808    *----------------------------------------------------------------------*
809    *  -->  p1        text
810    *  <--  p2        text
811    *----------------------------------------------------------------------*
812    FORM deselect_all.
813      LOOP AT ist_srcbsik.
814        ist_srcbsik-selcbox = ' '.
815        MODIFY ist_srcbsik.
816      ENDLOOP.
817    ENDFORM.                    " deselect_all
818    *&---------------------------------------------------------------------
819    *&---------------------------------------------------------------------*
820    *&      Form  get_upd_bsik
821    *&---------------------------------------------------------------------*
822    *       text
823    *----------------------------------------------------------------------*
824    *  -->  p1        text
825    *  <--  p2        text
826    *----------------------------------------------------------------------*
827    FORM get_upd_bsik.
828
829      DATA : l_tabix  TYPE sy-tabix.
830
831      CHECK NOT ist_srcbsik[] IS INITIAL.
832
833      SELECT * INTO TABLE ist_bsik   FROM bsik
834        FOR ALL ENTRIES  IN  ist_srcbsik
835        WHERE   lifnr = ist_srcbsik-lifnr
836              AND  bukrs  =  p_bukrs
837               AND gjahr = ist_srcbsik-gjahr
838               AND belnr = ist_srcbsik-belnr
839               AND buzei = ist_srcbsik-buzei.
840
841      IF NOT ist_bsik IS INITIAL.
842        IF p_any2D = 'X'.
843          LOOP AT ist_bsik INTO wa_bsik.
844            l_tabix =   sy-tabix .
845    *        IF wa_bsik-zlspr =  g_zlspr_x.
846            wa_bsik-zlspr =  g_zlspr_d.
847            MODIFY ist_bsik  FROM  wa_bsik INDEX l_tabix  TRANSPORTING zlspr.
848    *        ENDIF.
849          ENDLOOP.
850    "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
851
852    *      MODIFY  bsik FROM TABLE ist_bsik.
853    *      COMMIT WORK.
854    "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
855        ENDIF.
856        IF p_d2x = 'X'.
857          LOOP AT ist_bsik INTO wa_bsik.
858            l_tabix =   sy-tabix .
859            IF wa_bsik-zlspr =  g_zlspr_d.
860              wa_bsik-zlspr =  g_zlspr_x.
861              MODIFY ist_bsik  FROM  wa_bsik INDEX l_tabix  TRANSPORTING zlspr.
862            ENDIF.
863          ENDLOOP.
864    "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
865    *      MODIFY  bsik FROM TABLE ist_bsik.
866    *      COMMIT WORK.
867    "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
868        ENDIF.
869
870
871
872      ENDIF.
873    ENDFORM.                    " get_upd_bsik
874    *
875    *&---------------------------------------------------------------------*
876    *&      Form  get_upd_bseg
877    *&---------------------------------------------------------------------*
878    *       text
879    *----------------------------------------------------------------------*
880    *  -->  p1        text
881    *  <--  p2        text
882    *----------------------------------------------------------------------*
883    FORM get_upd_bseg.
884      DATA : l_tabix  TYPE sy-tabix.
885
886      CHECK NOT ist_srcbsik[] IS INITIAL.
887
888      SELECT * INTO TABLE ist_bseg   FROM bseg
889        FOR ALL ENTRIES  IN  ist_srcbsik
890        WHERE
891               bukrs  =  p_bukrs
892         AND   belnr = ist_srcbsik-belnr
893         AND   gjahr =  ist_srcbsik-gjahr
894         AND   buzei = ist_srcbsik-buzei ORDER BY PRIMARY KEY.
895
896      CLEAR l_tabix.
897      IF NOT ist_bseg IS INITIAL.
898        IF p_any2D = 'X'.
899          LOOP AT ist_bseg INTO wa_bseg.
900            l_tabix =   sy-tabix .
901    *        IF wa_bseg-zlspr =  g_zlspr_x.
902            wa_bseg-zlspr =  g_zlspr_d.
903            MODIFY ist_bseg  FROM  wa_bseg INDEX l_tabix  TRANSPORTING zlspr.
904    *        ENDIF.
905          ENDLOOP.
906
907    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
908    * S/4: BSEG payment block (ZLSPR) via FI_DOCUMENT_CHANGE (FB02); direct write not allowed.
909    *      MODIFY bseg FROM TABLE ist_bseg.
910          LOOP AT ist_bseg INTO wa_bseg.
911            PERFORM zz_s4_bseg_zlspr USING wa_bseg-bukrs wa_bseg-belnr wa_bseg-gjahr wa_bseg-buzei wa_bseg-zlspr.
912          ENDLOOP.
913          COMMIT WORK.
914    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
915
916        ENDIF.
917        CLEAR l_tabix.
918        IF p_d2x = 'X'.
919          LOOP AT ist_bseg INTO wa_bseg.
920            l_tabix =   sy-tabix .
921            IF wa_bseg-zlspr =  g_zlspr_d.
922              wa_bseg-zlspr =  g_zlspr_x.
923              MODIFY ist_bseg  FROM  wa_bseg INDEX l_tabix  TRANSPORTING zlspr.
924            ENDIF.
925          ENDLOOP.
926
927    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
928    * S/4: BSEG payment block (ZLSPR) via FI_DOCUMENT_CHANGE (FB02); direct write not allowed.
929    *      MODIFY bseg FROM TABLE ist_bseg.
930          LOOP AT ist_bseg INTO wa_bseg.
931            PERFORM zz_s4_bseg_zlspr USING wa_bseg-bukrs wa_bseg-belnr wa_bseg-gjahr wa_bseg-buzei wa_bseg-zlspr.
932          ENDLOOP.
933          COMMIT WORK.
934    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
935
936        ENDIF.
937      ENDIF.
938
939    ENDFORM.                    " get_upd_bseg
940    *&---------------------------------------------------------------------*
941    *&      Form  get_rel_docs
942    *&---------------------------------------------------------------------*
943    *       text
944    *----------------------------------------------------------------------*
945    *  -->  p1        text
946    *  <--  p2        text
947    *----------------------------------------------------------------------*
948    FORM get_rel_docs.
949      SELECT bukrs lifnr umskz gjahr belnr buzei budat bschl
950    *Begin of <RD1K981735> CAB_RAMA CR 30007748
951    **begin of <RD1K967585> CAB_ALOK 14.12.2009 CR30002778
952    **   zlsch zlspr shkzg gsber dmbtr wrbtr  APPENDING
953    *   zlsch zlspr shkzg gsber dmbtr wrbtr  rebzg APPENDING
954    **end of <RD1K967585> CAB_ALOK 14.12.2009 CR30002778
955        zlsch zlspr shkzg gsber dmbtr wrbtr rebzg kidno APPENDING
956    *End of <RD1K981735> CAB_RAMA CR 30007748
957      CORRESPONDING FIELDS OF TABLE
958                     ist_srcbsik  FROM bsik
959                     WHERE
960                          bukrs  =  p_bukrs
961                    AND lifnr  IN s_lifnr
962                    AND gjahr IN s_year
963                    AND BELNR IN S_DOCNO " RD1K982186 CR 30007748
964                    AND gsber IN s_gsber
965                    AND budat IN  s_budat.  "#EC CI_NOORDER
966
967
968      IF p_d2x = 'X'.
969        DELETE  ist_srcbsik WHERE zlspr <> g_zlspr_d.
970      endif.
971      IF p_any2d = 'X'.
972        DELETE  ist_srcbsik WHERE zlspr = g_zlspr_d.
973      endif.
974    *Start of addition Prabu K on 03.07.2009
975      data wa_bkpf type bkpf.
976      loop at ist_srcbsik into wa_srcbsik.
977
978        select single * from bkpf into wa_bkpf where bukrs = wa_srcbsik-bukrs and belnr = wa_srcbsik-belnr
979           and xref1_hd in s_xref1.  "#EC CI_NOORDER
980        if sy-subrc ne 0.
981          delete table ist_srcbsik from wa_srcbsik.
982        else.
983          wa_srcbsik-xref1_hd = wa_bkpf-xref1_hd.
984          modify IST_SRCBSIK from wa_srcbsik.
985        endif.
986
987      endloop.
988    *  End  of addition Prabu K on 03.07.2009
989    *----+003
990    *  elseif p_r2x = 'X'.
991    *     DELETE  ist_srcbsik WHERE zlspr <> g_zlspr_r.
992    *  ENDIF.
993    *-----+003
994      IF NOT s_usnam   IS INITIAL.
995        IF NOT ist_srcbsik[] IS INITIAL.
996          SELECT blart usnam ppnam belnr gjahr bldat budat waers bukrs
997                            INTO CORRESPONDING FIELDS OF TABLE ist_bkpf
998                             FROM  bkpf
999                            FOR ALL ENTRIES IN ist_srcbsik
1000   *                     FROM bkpf
1001                    WHERE bukrs = ist_srcbsik-bukrs
1002                    AND  gjahr = ist_srcbsik-gjahr
1003                    AND  belnr = ist_srcbsik-belnr
1004                    AND  budat = ist_srcbsik-budat
1005                    AND ( usnam IN s_usnam  OR usnam EQ 'WF-BATCH' ).  "#EC CI_NOORDER
1006       ENDIF.
1007
1008       IF NOT ist_bkpf[] IS INITIAL.
1009
1010         LOOP AT ist_bkpf WHERE usnam = 'WF-BATCH' .
1011           MOVE-CORRESPONDING ist_bkpf TO y_doc_nos .
1012           MOVE ist_bkpf-usnam TO y_doc_nos-usrel .
1013           APPEND y_doc_nos .
1014         ENDLOOP.
1015
1016         CALL FUNCTION 'Z_FI_GET_REL_USERNAME'
1017           TABLES
1018             y_doc_nos = y_doc_nos
1019             f_doc_nos = f_doc_nos
1020           EXCEPTIONS
1021             not_found = 1
1022             OTHERS    = 2.
1023
1024         LOOP AT ist_bkpf .
1025           READ TABLE y_doc_nos WITH KEY bukrs = ist_bkpf-bukrs
1026                                         belnr = ist_bkpf-belnr
1027                                         gjahr = ist_bkpf-gjahr.
1028           IF sy-subrc EQ 0 .
1029             ist_bkpf-usnam = y_doc_nos-usrel .
1030             MODIFY ist_bkpf TRANSPORTING usnam .
1031           ENDIF .
1032         ENDLOOP.
1033
1034
1035         LOOP AT ist_srcbsik.
1036           READ TABLE ist_bkpf WITH KEY bukrs = ist_srcbsik-bukrs
1037                                    belnr = ist_srcbsik-belnr
1038                                    gjahr = ist_srcbsik-gjahr .
1039           IF sy-subrc = 0.
1040             ist_srcbsik-usnam = ist_bkpf-usnam.
1041             MODIFY ist_srcbsik  TRANSPORTING usnam .
1042           ENDIF.
1043         ENDLOOP.
1044
1045         IF NOT s_usnam[] IS  INITIAL.
1046           DELETE ist_srcbsik WHERE  NOT usnam  IN s_usnam.
1047         ENDIF.
1048
1049       ENDIF.
1050
1051     ENDIF.
1052
1053
1054     ist_bsiks[] = ist_srcbsik[].
1055
1056     REFRESH ist_srcbsik.
1057     CLEAR ist_srcbsik.
1058
1059
1060     LOOP AT ist_bsiks .
1061       IF ist_bsiks-umskz = 'P' OR ist_bsiks-umskz = 'F'
1062       OR ist_bsiks-umskz = ':'
1063       OR ist_bsiks-umskz  IS INITIAL.
1064         ist_srcbsik = ist_bsiks.
1065         APPEND ist_srcbsik.
1066         CLEAR ist_srcbsik.
1067       ENDIF.
1068     ENDLOOP.
1069
1070
1071     SORT ist_srcbsik BY lifnr bschl belnr budat .
1072
1073     DELETE ADJACENT DUPLICATES  FROM ist_srcbsik.
1074
1075     CHECK  NOT ist_srcbsik[] IS INITIAL.
1076
1077     LOOP AT ist_srcbsik.
1078       IF ist_srcbsik-shkzg = 'S'.
1079         ist_srcbsik-dmbtr = ist_srcbsik-dmbtr.
1080         ist_srcbsik-wrbtr = ist_srcbsik-wrbtr.
1081       ELSEIF ist_srcbsik-shkzg = 'H'.
1082         ist_srcbsik-dmbtr = - ist_srcbsik-dmbtr.
1083         ist_srcbsik-wrbtr = - ist_srcbsik-wrbtr.
1084       ENDIF.
1085       MODIFY ist_srcbsik .
1086     ENDLOOP.
1087
1088
1089
1090   ENDFORM.                    " get_rel_docs
1091   *----Start of <RD1K960891>
1092   *&---------------------------------------------------------------------*
1093   *&      Form  get_docs_cust
1094   *&---------------------------------------------------------------------*
1095   *       text
1096   *----------------------------------------------------------------------*
1097   *  -->  p1        text
1098   *  <--  p2        text
1099   *----------------------------------------------------------------------*
1100   form get_docs_cust.
1101     SELECT bukrs kunnr umskz gjahr belnr buzei budat bschl
1102   *begin of <RD1K967585> CAB_ALOK 14.12.2009 CR30002778
1103   *   zlsch zlspr shkzg gsber dmbtr wrbtr APPENDING
1104        zlsch zlspr shkzg gsber dmbtr wrbtr rebzg APPENDING
1105   *end of <RD1K967585> CAB_ALOK 14.12.2009 CR30002778
1106      CORRESPONDING FIELDS OF TABLE
1107                     ist_srcbsid  FROM bsid
1108                     WHERE
1109                          bukrs  =  p_bukrs
1110                    AND kunnr  IN s_kunnr
1111                    AND gjahr IN s_year
1112                   AND BELNR IN S_DOCNO " RD1K982186 CR 30007748
1113                    AND gsber IN s_gsber
1114                    AND budat IN  s_budat.  "#EC CI_NOORDER
1115
1116
1117     IF p_d2x = 'X'.
1118       DELETE  ist_srcbsid WHERE zlspr <> g_zlspr_d.
1119     elseif p_any2D = 'X'.
1120       DELETE  ist_srcbsid WHERE zlspr = g_zlspr_d.
1121     endif.
1122
1123   *Start of addition Prabu K on 03.07.2009
1124     data wa_bkpf type bkpf.
1125     loop at ist_srcbsid into wa_srcbsid.
1126
1127       select single * from bkpf into wa_bkpf where bukrs = wa_srcbsid-bukrs and belnr = wa_srcbsid-belnr
1128          and xref1_hd in s_xref1.  "#EC CI_NOORDER
1129       if sy-subrc ne 0.
1130         delete table ist_srcbsid from wa_srcbsid.
1131       else.
1132         wa_srcbsid-xref1_hd = wa_bkpf-xref1_hd.
1133         modify IST_SRCBSId from wa_srcbsid.
1134       endif.
1135
1136     endloop.
1137   *  End  of addition Prabu K on 03.07.2009
1138     IF NOT s_usnam   IS INITIAL.
1139       IF NOT ist_srcbsid[] IS INITIAL.
1140         SELECT blart usnam ppnam belnr gjahr bldat budat waers bukrs
1141                           INTO CORRESPONDING FIELDS OF TABLE ist_bkpf
1142                            FROM  bkpf
1143                           FOR ALL ENTRIES IN ist_srcbsid
1144                    WHERE bukrs = ist_srcbsid-bukrs
1145                    AND  gjahr = ist_srcbsid-gjahr
1146                    AND  belnr = ist_srcbsid-belnr
1147                    AND  budat = ist_srcbsid-budat
1148                    AND ( usnam IN s_usnam  OR usnam EQ 'WF-BATCH' ).  "#EC CI_NOORDER
1149       ENDIF.
1150
1151       IF NOT ist_bkpf[] IS INITIAL.
1152
1153         LOOP AT ist_bkpf WHERE usnam = 'WF-BATCH' .
1154           MOVE-CORRESPONDING ist_bkpf TO y_doc_nos .
1155           MOVE ist_bkpf-usnam TO y_doc_nos-usrel .
1156           APPEND y_doc_nos .
1157         ENDLOOP.
1158
1159         CALL FUNCTION 'Z_FI_GET_REL_USERNAME'
1160           TABLES
1161             y_doc_nos = y_doc_nos
1162             f_doc_nos = f_doc_nos
1163           EXCEPTIONS
1164             not_found = 1
1165             OTHERS    = 2.
1166
1167         LOOP AT ist_bkpf .
1168           READ TABLE y_doc_nos WITH KEY bukrs = ist_bkpf-bukrs
1169                                         belnr = ist_bkpf-belnr
1170                                         gjahr = ist_bkpf-gjahr.
1171           IF sy-subrc EQ 0 .
1172             ist_bkpf-usnam = y_doc_nos-usrel .
1173             MODIFY ist_bkpf TRANSPORTING usnam .
1174           ENDIF .
1175         ENDLOOP.
1176
1177
1178         LOOP AT ist_srcbsid.
1179           READ TABLE ist_bkpf WITH KEY bukrs = ist_srcbsid-bukrs
1180                                    belnr = ist_srcbsid-belnr
1181                                    gjahr = ist_srcbsid-gjahr .
1182           IF sy-subrc = 0.
1183             ist_srcbsid-usnam = ist_bkpf-usnam.
1184             MODIFY ist_srcbsid  TRANSPORTING usnam .
1185           ENDIF.
1186         ENDLOOP.
1187
1188         IF NOT s_usnam[] IS  INITIAL.
1189           DELETE ist_srcbsid WHERE  NOT usnam  IN s_usnam.
1190         ENDIF.
1191
1192       ENDIF.
1193
1194     ENDIF.
1195
1196
1197     ist_bsids[] = ist_srcbsid[].
1198
1199     REFRESH ist_srcbsid.
1200     CLEAR ist_srcbsid.
1201
1202
1203     LOOP AT ist_bsids .
1204       IF ist_bsids-umskz = 'K' OR ist_bsids-umskz = 'H' or ist_bsids-umskz = 'O'.
1205         ist_srcbsid = ist_bsids.
1206         APPEND ist_srcbsid.
1207         CLEAR ist_srcbsid.
1208       ENDIF.
1209     ENDLOOP.
1210
1211
1212     SORT ist_srcbsid BY kunnr bschl belnr budat .
1213
1214     DELETE ADJACENT DUPLICATES  FROM ist_srcbsid.
1215
1216     CHECK  NOT ist_srcbsid[] IS INITIAL.
1217
1218     LOOP AT ist_srcbsid.
1219       IF ist_srcbsid-shkzg = 'S'.
1220         ist_srcbsid-dmbtr = ist_srcbsid-dmbtr.
1221         ist_srcbsid-wrbtr = ist_srcbsid-wrbtr.
1222       ELSEIF ist_srcbsid-shkzg = 'H'.
1223         ist_srcbsid-dmbtr = - ist_srcbsid-dmbtr.
1224         ist_srcbsid-wrbtr = - ist_srcbsid-wrbtr.
1225       ENDIF.
1226       MODIFY ist_srcbsid .
1227     ENDLOOP.
1228
1229   endform.                    " get_docs_cust
1230   *&---------------------------------------------------------------------*
1231   *&      Form  display_docs_cust
1232   *&---------------------------------------------------------------------*
1233   *       text
1234   *----------------------------------------------------------------------*
1235   *  -->  p1        text
1236   *  <--  p2        text
1237   *----------------------------------------------------------------------*
1238   form display_docs_cust.
1239     PERFORM init_fieldcat_cust.
1240     PERFORM eventtab_build_cust tables gt_events.
1241     PERFORM  sort_build_cust .
1242     PERFORM  print_alv_cust.
1243
1244   endform.                    " display_docs_cust
1245   *&---------------------------------------------------------------------*
1246   *&      Form  init_fieldcat_cust
1247   *&---------------------------------------------------------------------*
1248   *       text
1249   *----------------------------------------------------------------------*
1250   *  -->  p1        text
1251   *  <--  p2        text
1252   *----------------------------------------------------------------------*
1253   FORM init_fieldcat_CUST.
1254     w_repid  = sy-repid.
1255
1256     mpos = 0.
1257     mpos = mpos + 1.
1258     ist_fieldcat-fieldname = 'SELCBOX'.
1259     ist_fieldcat-tabname = 'IST_SRCBSID'.
1260     ist_fieldcat-ddictxt = 'M'.
1261     ist_fieldcat-col_pos =  mpos.
1262     ist_fieldcat-seltext_m  = 'Select'.
1263     ist_fieldcat-lowercase  = 'Y'.
1264     ist_fieldcat-checkbox = 'X'.
1265     ist_fieldcat-input = 'X'.
1266     APPEND ist_fieldcat TO ist_fcat.
1267     CLEAR ist_fieldcat.
1268
1269
1270
1271     mpos = mpos + 1.
1272     ist_fieldcat-fieldname = 'KUNNR'.
1273     ist_fieldcat-tabname = 'IST_SRCBSID'.
1274     ist_fieldcat-ddictxt = 'M'.
1275     ist_fieldcat-col_pos =  mpos.
1276     ist_fieldcat-seltext_m  = 'CustomerNumber '.
1277     ist_fieldcat-lowercase  = 'Y'.
1278     APPEND ist_fieldcat TO ist_fcat.
1279     CLEAR ist_fieldcat.
1280
1281
1282     mpos = mpos + 1.
1283     ist_fieldcat-fieldname = 'BELNR'.
1284     ist_fieldcat-tabname = 'IST_SRCBSID'.
1285     ist_fieldcat-ddictxt = 'M'.
1286     ist_fieldcat-col_pos =  mpos.
1287     ist_fieldcat-seltext_m  = 'Doc.No.'.
1288     ist_fieldcat-lowercase  = 'Y'.
1289     APPEND ist_fieldcat TO ist_fcat.
1290     CLEAR ist_fieldcat.
1291
1292
1293     mpos = mpos + 1.
1294     ist_fieldcat-fieldname = 'BUZEI'.
1295     ist_fieldcat-tabname = 'IST_SRCBSID'.
1296     ist_fieldcat-ddictxt = 'M'.
1297     ist_fieldcat-col_pos =  mpos.
1298     ist_fieldcat-seltext_m  = 'Item.no.'.
1299     ist_fieldcat-lowercase  = 'Y'.
1300     APPEND ist_fieldcat TO ist_fcat.
1301     CLEAR ist_fieldcat.
1302
1303     mpos = mpos + 1.
1304     ist_fieldcat-fieldname = 'GSBER'.
1305     ist_fieldcat-tabname = 'IST_SRCBSID'.
1306     ist_fieldcat-ddictxt = 'M'.
1307     ist_fieldcat-col_pos =  mpos.
1308     ist_fieldcat-seltext_m  = 'Business Area'.
1309     ist_fieldcat-lowercase  = 'Y'.
1310     APPEND ist_fieldcat TO ist_fcat.
1311     CLEAR ist_fieldcat.
1312
1313   *begin of <RD1K967585> CAB_ALOK 14.12.2009 CR30002778
1314     mpos = mpos + 1.
1315     ist_fieldcat-fieldname = 'REBZG'.
1316     ist_fieldcat-tabname = 'IST_SRCBSID'.
1317     ist_fieldcat-ddictxt = 'M'.
1318     ist_fieldcat-col_pos =  mpos.
1319     ist_fieldcat-seltext_m  = 'Invoice Reference'.
1320   *  ist_fieldcat-lowercase  = 'Y'.
1321     APPEND ist_fieldcat TO ist_fcat.
1322     CLEAR ist_fieldcat.
1323   *end of <RD1K967585> CAB_ALOK 14.12.2009 CR30002778
1324
1325     mpos = mpos + 1.
1326     ist_fieldcat-fieldname = 'BSCHL'.
1327     ist_fieldcat-tabname = 'IST_SRCBSID'.
1328     ist_fieldcat-ddictxt = 'M'.
1329     ist_fieldcat-col_pos =  mpos.
1330     ist_fieldcat-seltext_m  = 'Posting Key.'.
1331     ist_fieldcat-lowercase  = 'Y'.
1332     APPEND ist_fieldcat TO ist_fcat.
1333     CLEAR ist_fieldcat.
1334
1335
1336
1337
1338     mpos = mpos + 1.
1339     ist_fieldcat-fieldname = 'BUDAT'.
1340     ist_fieldcat-tabname = 'IST_SRCBSID'.
1341     ist_fieldcat-ddictxt = 'M'.
1342     ist_fieldcat-col_pos =  mpos.
1343     ist_fieldcat-seltext_m  = 'Posting Date'.
1344     ist_fieldcat-lowercase  = 'Y'.
1345     APPEND ist_fieldcat TO ist_fcat.
1346     CLEAR ist_fieldcat.
1347
1348
1349     mpos = mpos + 1.
1350     ist_fieldcat-fieldname = 'DMBTR'.
1351     ist_fieldcat-tabname = 'IST_SRCBSID'.
1352     ist_fieldcat-ddictxt = 'M'.
1353     ist_fieldcat-col_pos =  mpos.
1354     ist_fieldcat-seltext_m  = 'AmtInLclCurncy'.
1355     ist_fieldcat-lowercase  = 'Y'.
1356     APPEND ist_fieldcat TO ist_fcat.
1357     CLEAR ist_fieldcat.
1358
1359
1360
1361     mpos = mpos + 1.
1362     ist_fieldcat-fieldname = 'WRBTR'.
1363     ist_fieldcat-tabname = 'IST_SRCBSID'.
1364     ist_fieldcat-ddictxt = 'M'.
1365     ist_fieldcat-col_pos =  mpos.
1366     ist_fieldcat-seltext_m  = 'AmtInDocCurncy'.
1367     ist_fieldcat-lowercase  = 'Y'.
1368     APPEND ist_fieldcat TO ist_fcat.
1369     CLEAR ist_fieldcat.
1370
1371
1372     mpos = mpos + 1.
1373     ist_fieldcat-fieldname = 'ZLSCH'.
1374     ist_fieldcat-tabname = 'IST_SRCBSID'.
1375     ist_fieldcat-ddictxt = 'M'.
1376     ist_fieldcat-col_pos =  mpos.
1377     ist_fieldcat-seltext_m  = 'PaymntMethod'.
1378     ist_fieldcat-lowercase  = 'Y'.
1379     APPEND ist_fieldcat TO ist_fcat.
1380     CLEAR ist_fieldcat.
1381
1382
1383
1384     mpos = mpos + 1.
1385     ist_fieldcat-fieldname = 'ZLSPR'.
1386     ist_fieldcat-tabname = 'IST_SRCBSID'.
1387     ist_fieldcat-ddictxt = 'M'.
1388     ist_fieldcat-col_pos =  mpos.
1389     ist_fieldcat-seltext_m  = 'PaymntBlock'.
1390     ist_fieldcat-lowercase  = 'Y'.
1391     APPEND ist_fieldcat TO ist_fcat.
1392     CLEAR ist_fieldcat.
1393
1394   *  *Start of addition Prabu K on 06.07.2009
1395     mpos = mpos + 1.
1396     ist_fieldcat-fieldname = 'XREF1_HD'.
1397     ist_fieldcat-tabname = 'IST_SRCBSID'.
1398     ist_fieldcat-ddictxt = 'M'.
1399     ist_fieldcat-col_pos =  mpos.
1400     ist_fieldcat-seltext_m  = 'Location'.
1401     ist_fieldcat-lowercase  = 'Y'.
1402     APPEND ist_fieldcat TO ist_fcat.
1403     CLEAR ist_fieldcat.
1404   * End of addition Prabu K on 06.07.2009
1405
1406     if not s_usnam[] is initial.
1407       mpos = mpos + 1.
1408       ist_fieldcat-fieldname = 'USNAM'.
1409       ist_fieldcat-tabname = 'IST_SRCBSID'.
1410       ist_fieldcat-ddictxt = 'M'.
1411       ist_fieldcat-col_pos =  mpos.
1412       ist_fieldcat-seltext_m  = 'Created By'.
1413       ist_fieldcat-lowercase  = 'Y'.
1414       APPEND ist_fieldcat TO ist_fcat.
1415       CLEAR ist_fieldcat.
1416     endif.
1417
1418
1419   ENDFORM.                    " init_fieldcat
1420   *&---------------------------------------------------------------------*
1421   *&      Form  eventtab_build
1422   *&---------------------------------------------------------------------*
1423   *       text
1424   *----------------------------------------------------------------------*
1425   *      -->P_GT_EVENTS[]  text
1426   *----------------------------------------------------------------------*
1427   FORM eventtab_build_CUST tables   p_gt_events.
1428     DATA : ls_event TYPE slis_alv_event.
1429     CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
1430       EXPORTING
1431         i_list_type = 0
1432       IMPORTING
1433         et_events   = gt_events.
1434     READ TABLE gt_events WITH KEY name =  slis_ev_user_command
1435                               INTO ls_event.
1436     IF sy-subrc = 0.
1437       MOVE 'MAKEC_COMMAND' TO ls_event-form.
1438       APPEND ls_event TO gt_events.
1439     ENDIF.
1440     CLEAR ls_event.
1441
1442
1443   ENDFORM.                    " eventtab_build
1444   *&---------------------------------------------------------------------*
1445   *&      Form  sort_build
1446   *&---------------------------------------------------------------------*
1447   *       text
1448   *----------------------------------------------------------------------*
1449   *  -->  p1        text
1450   *  <--  p2        text
1451   *----------------------------------------------------------------------*
1452   FORM sort_build_CUST.
1453     w_repid = sy-repid.
1454     is_layout-key_hotspot = 'X'.
1455     is_layout-colwidth_optimize = 'X'.
1456     ls_sorttab-fieldname = 'KUNNR'.
1457     ls_sorttab-up = 'X'.
1458     APPEND ls_sorttab TO lt_sorttab.
1459     ls_sorttab-fieldname = 'BSCHL'.
1460     ls_sorttab-up = 'X'.
1461     APPEND ls_sorttab TO lt_sorttab.
1462     ls_sorttab-fieldname = 'BELNR'.
1463     ls_sorttab-up = 'X'.
1464     APPEND ls_sorttab TO lt_sorttab.
1465     ls_sorttab-fieldname = 'BUDAT'.
1466     ls_sorttab-up = 'X'.
1467     APPEND ls_sorttab TO lt_sorttab.
1468
1469
1470
1471   ENDFORM.                    " sort_build
1472   *&---------------------------------------------------------------------*
1473   *&      Form  print_alv
1474   *&---------------------------------------------------------------------*
1475   *       text
1476   *----------------------------------------------------------------------*
1477   *  -->  p1        text
1478   *  <--  p2        text
1479   *----------------------------------------------------------------------*
1480   FORM print_alv_CUST.
1481     CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
1482       EXPORTING
1483         i_callback_program       = w_repid
1484         i_callback_pf_status_set = 'ALV_PFSTS'
1485         i_callback_user_command  = 'MAKEC_COMMAND'
1486         is_layout                = is_layout
1487         it_fieldcat              = ist_fcat[]
1488         it_sort                  = lt_sorttab
1489         it_events                = gt_events
1490         i_save                   = 'A'
1491       TABLES
1492         t_outtab                 = ist_srcBSID
1493   * Begin of Changes on 20-Jun-2013
1494       EXCEPTIONS
1495         PROGRAM_ERROR = 1
1496         OTHERS        = 2.
1497   * End of Changes on 20-Jun-2013
1498     IF sy-subrc <> 0.
1499   *    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
1500   *            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
1501     ENDIF.
1502
1503
1504   ENDFORM.                    " print_alv_CUST
1505   *---------------------------------------------------------------------*
1506   *       FORM alv_pfst                                                 *
1507   *---------------------------------------------------------------------*
1508   *       ........                                                      *
1509   *---------------------------------------------------------------------*
1510   *  -->  RT_EXTAB                                                      *
1511   *---------------------------------------------------------------------*
1512   FORM alv_pfstS USING rt_extab TYPE slis_t_extab.
1513     SET PF-STATUS 'S100'.
1514   ENDFORM.                    "alv_pfstS
1515
1516   *---------------------------------------------------------------------*
1517   *       FORM make_command                                             *
1518   *---------------------------------------------------------------------*
1519   *       ........                                                      *
1520   *---------------------------------------------------------------------*
1521   *  -->  R_UCOMM                                                       *
1522   *  -->  RS_SELFIELD                                                   *
1523   *---------------------------------------------------------------------*
1524   FORM makec_command USING r_ucomm LIKE sy-ucomm
1525                           rs_selfield TYPE slis_selfield.
1526   *-----------------------------------------------------*
1527   *-----------------------------------------------------*
1528     DATA : index_aux LIKE sy-tabix.
1529     index_aux = rs_selfield-tabindex.
1530     CASE r_ucomm.
1531
1532       WHEN 'REL'.
1533         DELETE ist_srcBSID WHERE  selcbox <> 'X'.
1534         PERFORM   get_upd_BSID.
1535         PERFORM   get_upd_bsegC.
1536   *Begin of <RD1K967585> CAB_ALOK 14.12.2009 CR30002778
1537         PERFORM   UPDATE_ZFI_REM_PYBLCK_L.    "update logs
1538   *end of <RD1K967585> CAB_ALOK 14.12.2009 CR30002778
1539         LEAVE SCREEN.
1540       WHEN 'ALL'.
1541         PERFORM  select_allC.
1542       WHEN 'SAL'.
1543         PERFORM  deselect_allC.
1544       WHEN '&F03' OR 'BACK' .
1545         LEAVE  PROGRAM.
1546
1547     ENDCASE.
1548
1549   ENDFORM.                    "makec_command
1550   *---------------------------------------------------------------------*
1551   *&      Form  select_all
1552   *&---------------------------------------------------------------------*
1553   *       text
1554   *----------------------------------------------------------------------*
1555   *  -->  p1        text
1556   *  <--  p2        text
1557   *----------------------------------------------------------------------*
1558   FORM select_allC.
1559     LOOP AT ist_srcBSID.
1560       ist_srcBSID-selcbox = 'X'.
1561       MODIFY ist_srcBSID.
1562     ENDLOOP.
1563
1564   ENDFORM.                    " select_all
1565   *&---------------------------------------------------------------------*
1566   *&      Form  deselect_all
1567   *&---------------------------------------------------------------------*
1568   *       text
1569   *----------------------------------------------------------------------*
1570   *  -->  p1        text
1571   *  <--  p2        text
1572   *----------------------------------------------------------------------*
1573   FORM deselect_allC.
1574     LOOP AT ist_srcBSID.
1575       ist_srcBSID-selcbox = ' '.
1576       MODIFY ist_srcBSID.
1577     ENDLOOP.
1578   ENDFORM.                    " deselect_all
1579   *&---------------------------------------------------------------------
1580   *&---------------------------------------------------------------------*
1581   *&      Form  get_upd_BSID
1582   *&---------------------------------------------------------------------*
1583   *       text
1584   *----------------------------------------------------------------------*
1585   *  -->  p1        text
1586   *  <--  p2        text
1587   *----------------------------------------------------------------------*
1588   FORM get_upd_BSID.
1589
1590     DATA : l_tabix  TYPE sy-tabix.
1591
1592     CHECK NOT ist_srcBSID[] IS INITIAL.
1593
1594     SELECT * INTO TABLE ist_BSID   FROM BSID
1595       FOR ALL ENTRIES  IN  ist_srcBSID
1596       WHERE   KUNNR = ist_srcBSID-KUNNR
1597             AND  bukrs  =  p_bukrs
1598              AND gjahr = ist_srcBSID-gjahr
1599              AND belnr = ist_srcBSID-belnr
1600              AND buzei = ist_srcBSID-buzei.
1601
1602     IF NOT ist_BSID IS INITIAL.
1603       IF p_any2D = 'X'.
1604         LOOP AT ist_BSID INTO wa_BSID.
1605           l_tabix =   sy-tabix .
1606   *        IF wa_BSID-zlspr =  g_zlspr_x.
1607           wa_BSID-zlspr =  g_zlspr_d.
1608           MODIFY ist_BSID  FROM  wa_BSID INDEX l_tabix  TRANSPORTING zlspr.
1609   *        ENDIF.
1610         ENDLOOP.
1611   "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
1612   *      MODIFY  BSID FROM TABLE ist_BSID.
1613   *      COMMIT WORK.
1614   "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
1615       ENDIF.
1616       IF p_d2x = 'X'.
1617         LOOP AT ist_BSID INTO wa_BSID.
1618           l_tabix =   sy-tabix .
1619           IF wa_BSID-zlspr =  g_zlspr_d.
1620             wa_BSID-zlspr =  g_zlspr_x.
1621             MODIFY ist_BSID  FROM  wa_BSID INDEX l_tabix  TRANSPORTING zlspr.
1622           ENDIF.
1623         ENDLOOP.
1624   "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
1625   *      MODIFY  BSID FROM TABLE ist_BSID.
1626   *      COMMIT WORK.
1627   "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
1628       ENDIF.
1629
1630
1631
1632     ENDIF.
1633   ENDFORM.                    " get_upd_BSID
1634   *
1635   *&---------------------------------------------------------------------*
1636   *&      Form  get_upd_bseg
1637   *&---------------------------------------------------------------------*
1638   *       text
1639   *----------------------------------------------------------------------*
1640   *  -->  p1        text
1641   *  <--  p2        text
1642   *----------------------------------------------------------------------*
1643   FORM get_upd_bsegC.
1644     DATA : l_tabix  TYPE sy-tabix.
1645
1646     CHECK NOT ist_srcBSID[] IS INITIAL.
1647
1648     SELECT * INTO TABLE ist_bseg   FROM bseg
1649       FOR ALL ENTRIES  IN  ist_srcBSID
1650       WHERE
1651              bukrs  =  p_bukrs
1652        AND   belnr = ist_srcBSID-belnr
1653        AND   gjahr =  ist_srcBSID-gjahr
1654        AND   buzei = ist_srcBSID-buzei ORDER BY PRIMARY KEY.
1655
1656     CLEAR l_tabix.
1657     IF NOT ist_bseg IS INITIAL.
1658       IF p_any2D = 'X'.
1659         LOOP AT ist_bseg INTO wa_bseg.
1660           l_tabix =   sy-tabix .
1661           wa_bseg-zlspr =  g_zlspr_d.
1662           MODIFY ist_bseg  FROM  wa_bseg INDEX l_tabix  TRANSPORTING zlspr.
1663         ENDLOOP.
1664
1665   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1666   * S/4: BSEG payment block (ZLSPR) via FI_DOCUMENT_CHANGE (FB02); direct write not allowed.
1667   *      MODIFY bseg FROM TABLE ist_bseg.
1668         LOOP AT ist_bseg INTO wa_bseg.
1669           PERFORM zz_s4_bseg_zlspr USING wa_bseg-bukrs wa_bseg-belnr wa_bseg-gjahr wa_bseg-buzei wa_bseg-zlspr.
1670         ENDLOOP.
1671         COMMIT WORK.
1672   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1673
1674       ENDIF.
1675       CLEAR l_tabix.
1676       IF p_d2x = 'X'.
1677         LOOP AT ist_bseg INTO wa_bseg.
1678           l_tabix =   sy-tabix .
1679           IF wa_bseg-zlspr =  g_zlspr_d.
1680             wa_bseg-zlspr =  g_zlspr_x.
1681             MODIFY ist_bseg  FROM  wa_bseg INDEX l_tabix  TRANSPORTING zlspr.
1682           ENDIF.
1683         ENDLOOP.
1684
1685   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1686   * S/4: BSEG payment block (ZLSPR) via FI_DOCUMENT_CHANGE (FB02); direct write not allowed.
1687   *      MODIFY bseg FROM TABLE ist_bseg.
1688         LOOP AT ist_bseg INTO wa_bseg.
1689           PERFORM zz_s4_bseg_zlspr USING wa_bseg-bukrs wa_bseg-belnr wa_bseg-gjahr wa_bseg-buzei wa_bseg-zlspr.
1690         ENDLOOP.
1691         COMMIT WORK.
1692   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1693
1694       ENDIF.
1695     ENDIF.
1696   endform.                    "get_upd_bsegC
1697   *----End of <RD1K960891>
1698
1699   *&---------------------------------------------------------------------*
1700   *&      Form  UPDATE_ZFI_REM_PYBLCK_L
1701   *&---------------------------------------------------------------------*
1702   *       text
1703   *----------------------------------------------------------------------*
1704   *  -->  p1        text
1705   *  <--  p2        text
1706   *----------------------------------------------------------------------*
1707   *begin of <RD1K967585> CAB_ALOK 14.12.2009 CR30002778
1708   * update Logs to table ZFI_REM_PYBLCK_L
1709   FORM UPDATE_ZFI_REM_PYBLCK_L .
1710     data: ist_ZFI_REM_PYBLCK_L type table of ZFI_REM_PYBLCK_L,
1711           wa_ZFI_REM_PYBLCK_L type ZFI_REM_PYBLCK_L.
1712     data: count type ZFI_REM_PYBLCK_L-SRNO.
1713
1714     IF p_any2D = 'X'.
1715       PMTBLOCK_TO = 'D'.
1716     elseif p_d2x = 'X'.
1717       PMTBLOCK_TO = 'X'.
1718     endif.
1719
1720     select max( SRNO ) from ZFI_REM_PYBLCK_L into count.
1721     if not ist_srcbsik is initial.
1722
1723       loop at ist_srcbsik into wa_srcbsik.
1724         count = count + 1.
1725
1726         wa_ZFI_REM_PYBLCK_L-SRNO = count.
1727         wa_ZFI_REM_PYBLCK_L-BUKRS = wa_srcbsik-BUKRS.
1728         wa_ZFI_REM_PYBLCK_L-LIFNR = wa_srcbsik-LIFNR.
1729   *wa_ZFI_REM_PYBLCK_L-KUNNR = wa_srcbsik-KUNNR.
1730         wa_ZFI_REM_PYBLCK_L-BELNR = wa_srcbsik-BELNR.
1731   *   wa_ZFI_REM_PYBLCK_L-KIDNO = wa_srcbsik-KIDNO.
1732         wa_ZFI_REM_PYBLCK_L-REBZG = wa_srcbsik-REBZG.
1733         wa_ZFI_REM_PYBLCK_L-SHKZG = wa_srcbsik-SHKZG.
1734         wa_ZFI_REM_PYBLCK_L-GJAHR = wa_srcbsik-GJAHR.
1735         wa_ZFI_REM_PYBLCK_L-BUZEI = wa_srcbsik-BUZEI.
1736         wa_ZFI_REM_PYBLCK_L-BSCHL = wa_srcbsik-BSCHL.
1737         wa_ZFI_REM_PYBLCK_L-BUDAT = wa_srcbsik-BUDAT.
1738         wa_ZFI_REM_PYBLCK_L-DMBTR = wa_srcbsik-DMBTR .
1739         wa_ZFI_REM_PYBLCK_L-WRBTR = wa_srcbsik-WRBTR .
1740         wa_ZFI_REM_PYBLCK_L-ZLSCH = wa_srcbsik-ZLSCH.
1741         wa_ZFI_REM_PYBLCK_L-PMTBLOCK_FROM = wa_srcbsik-ZLSPR.
1742         wa_ZFI_REM_PYBLCK_L-PMTBLOCK_TO = PMTBLOCK_TO.
1743         wa_ZFI_REM_PYBLCK_L-LOCATION = wa_srcbsik-XREF1_HD.
1744         wa_ZFI_REM_PYBLCK_L-UNAME = sy-UNAME.
1745         wa_ZFI_REM_PYBLCK_L-USDATE = sy-datum.
1746         wa_ZFI_REM_PYBLCK_L-USTIME = sy-uzeit.
1747
1748         insert ZFI_REM_PYBLCK_L from wa_ZFI_REM_PYBLCK_L.
1749       endloop.
1750
1751       commit work.
1752       refresh ist_srcbsik.
1753     endif.
1754
1755     if not ist_srcbsid is initial.
1756
1757       loop at ist_srcbsid into wa_srcbsid.
1758         count = count + 1.
1759
1760         wa_ZFI_REM_PYBLCK_L-SRNO = count.
1761         wa_ZFI_REM_PYBLCK_L-BUKRS = wa_srcbsid-BUKRS.
1762   *   wa_ZFI_REM_PYBLCK_L-LIFNR = wa_srcbsid-LIFNR.
1763         wa_ZFI_REM_PYBLCK_L-KUNNR = wa_srcbsid-KUNNR.
1764         wa_ZFI_REM_PYBLCK_L-BELNR = wa_srcbsid-BELNR.
1765   *   wa_ZFI_REM_PYBLCK_L-KIDNO = wa_srcbsid-KIDNO.
1766         wa_ZFI_REM_PYBLCK_L-REBZG = wa_srcbsid-REBZG.
1767         wa_ZFI_REM_PYBLCK_L-SHKZG = wa_srcbsid-SHKZG.
1768         wa_ZFI_REM_PYBLCK_L-GJAHR = wa_srcbsid-GJAHR.
1769         wa_ZFI_REM_PYBLCK_L-BUZEI = wa_srcbsid-BUZEI.
1770         wa_ZFI_REM_PYBLCK_L-BSCHL = wa_srcbsid-BSCHL.
1771         wa_ZFI_REM_PYBLCK_L-BUDAT = wa_srcbsid-BUDAT.
1772         wa_ZFI_REM_PYBLCK_L-DMBTR = wa_srcbsid-DMBTR .
1773         wa_ZFI_REM_PYBLCK_L-WRBTR = wa_srcbsid-WRBTR .
1774         wa_ZFI_REM_PYBLCK_L-ZLSCH = wa_srcbsid-ZLSCH.
1775         wa_ZFI_REM_PYBLCK_L-PMTBLOCK_FROM = wa_srcbsid-ZLSPR.
1776         wa_ZFI_REM_PYBLCK_L-PMTBLOCK_TO = PMTBLOCK_TO.
1777         wa_ZFI_REM_PYBLCK_L-LOCATION = wa_srcbsid-XREF1_HD.
1778         wa_ZFI_REM_PYBLCK_L-UNAME = sy-UNAME.
1779         wa_ZFI_REM_PYBLCK_L-USDATE = sy-datum.
1780         wa_ZFI_REM_PYBLCK_L-USTIME = sy-uzeit.
1781
1782         insert ZFI_REM_PYBLCK_L from wa_ZFI_REM_PYBLCK_L.
1783       endloop.
1784       commit work.
1785       refresh ist_srcbsid.
1786     endif.
1787   ENDFORM.                    " UPDATE_ZFI_REM_PYBLCK_L
1788   *end of <RD1K967585> CAB_ALOK 14.12.2009 CR30002778
1789
1790   *-- S/4 helper: change BSEG payment block via FI_DOCUMENT_CHANGE - SAP_ABAP 16.06.2026 --
1791   FORM zz_s4_bseg_zlspr USING p_bukrs p_belnr p_gjahr p_buzei p_zlspr.
1792     DATA: lt_acchg TYPE STANDARD TABLE OF accchg, ls_acchg TYPE accchg.
1793     REFRESH lt_acchg. CLEAR ls_acchg.
1794     ls_acchg-fdname = 'ZLSPR'. ls_acchg-newval = p_zlspr.
1795     APPEND ls_acchg TO lt_acchg.
1796     CALL FUNCTION 'FI_DOCUMENT_CHANGE' EXPORTING i_bukrs = p_bukrs i_belnr = p_belnr i_gjahr = p_gjahr
1797          i_buzei = p_buzei TABLES t_acchg = lt_acchg EXCEPTIONS OTHERS = 0.
1798   ENDFORM.
*--- End of ZFI_CHNG_PYBLCKD - 1798 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CSLIS                                   Level 1    Page 2
Object           ZFI_CHNG_PYBLCKD                          Lines 543
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:01
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
Object           ZFI_CHNG_PYBLCKD                          Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:01
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
Object           ZFI_CHNG_PYBLCKD                          Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:01
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
Object           ZFI_CHNG_PYBLCKD                          Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:01
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
Object           ZFI_CHNG_PYBLCKD                          Lines 1
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:01
----------------------------------------------------------------------------------------------------
1      * INCLUDE DB__SSEL
*--- End of DB__SSEL - 1 lines ---
