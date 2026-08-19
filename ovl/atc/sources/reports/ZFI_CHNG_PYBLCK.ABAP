----------------------------------------------------------------------------------------------------
Main program     ZFI_CHNG_PYBLCK                           Level 0    Page 1
Object           ZFI_CHNG_PYBLCK                           Lines 2338
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:58
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
14     *               per i/p 'X' 'A'
15     *
16     *                                                                     *
17     * Tran.Code  : ZFIBLOCKA
18     *
19     ***********************************************************************
20     *Change History
21     *Date        ChID     Login        Description
22     *22.04.2008  +002     CAB_SUDHA    JV Cash call Sp gl added
23     *                                   Payment method added
24     *
25     *19.08.2008  +003     CAB_SUDHA     eq. of new     *  payment blocks
26     *R- rejection, S- stale cheque , D - old lineitems
27     *
28     ***********************************************************************
29     *  Date        Transport     USERID       Description                  *
30     * 24/11/2008   <RD1K960611>  CAB_SUDHA    Form call eventtab_build,
31     *                                         comment_build  sts  changed
32     *                                         After removing []
33     ************************************************************************
34     *  Date      Transport  USERID      Description
35     ** 19/12/2008 RD1K960891 CAB_SUDHA   Payment block for customers
36     * 25.02.09   cab_rama               FS-FI-AP-083_01 30000782    001
37     * 15.12.2009 RD1K967585 CAB_ALOK    CR30002778,Creation of activity logs
38     *                                   Addition of INV REF in Report,
39     *
40     * 26.03.2010            SAB_SUMAN   30003849      003
41     * 17.05.2010 RD1K971966 CAB_ALOK    CR 30004183: Addition of
42     *                                   'Payment block from S to X'
43     * 14.06.2011            CAB_SUDHIR  Message e410(ZFI) added
44     ************************************************************************
45     ***********************************************************************
46     * CHANGE HISTORY                                                      *
47     *                                                                     *
48     * Mod Date    Changed by    Description                 Chng ID       *
49     *                                                                     *
50     * 09.07.2014  CAB_SPYADAV   Changes as per CR No.        010          *
51     *                           30011027                                  *
52     *18.12.2015 CAB_RAMA(ANAMIKA) Warning message        <RD1K999458>     *
53     *                            as per CR 30013754                                                  *
54     *05.05.2016 CAB_RAMA(ANAMIKA) Changes as per         < RD1K9A00LE>    *
55     *                             CR 30014262                             *
56     ***********************************************************************
57
58     TYPE-POOLS : slis.
59
60     TABLES : bsik , t001 , bkpf, bsid, zhr_institute.
61
62     DATA : ist_bsik  TYPE TABLE OF bsik.
63     DATA : ist_bseg TYPE TABLE OF  bseg.
64     DATA : wa_bsik  TYPE bsik.
65     DATA : wa_bseg TYPE  bseg.
66
67     DATA: BEGIN OF ist_bkpf OCCURS 0,
68           blart LIKE bkpf-blart,
69           belnr LIKE bkpf-belnr,
70           bldat LIKE bkpf-bldat,
71           budat LIKE bkpf-budat,
72           waers LIKE bkpf-waers,
73           usnam LIKE bkpf-usnam,
74           ppnam LIKE bkpf-ppnam,
75           gjahr LIKE bkpf-gjahr, "Added PN
76           bukrs LIKE bkpf-bukrs, "Added PN
77
78           END OF ist_bkpf.
79
80     DATA : BEGIN OF ist_srcbsik OCCURS 0 ,
81            selcbox(1) TYPE c,
82            lifnr LIKE bsik-lifnr ,
83            umskz LIKE bsik-umskz,
84            bukrs LIKE bsik-bukrs ,
85            gjahr LIKE bsik-gjahr,
86            belnr  LIKE bsik-belnr,
87            buzei  LIKE bsik-buzei,
88            budat  LIKE bsik-budat,
89            bschl LIKE bsik-bschl,
90            zlsch LIKE bsik-zlsch,                               "+002
91            zlspr LIKE  bsik-zlspr,
92            shkzg LIKE bsik-shkzg,
93            gsber LIKE bsik-gsber,
94            dmbtr LIKE bsik-dmbtr,
95            wrbtr LIKE bsik-wrbtr,
96     *Begin of <RD1K967585> CAB_ALOK 15.12.2009 CR30002778
97            rebzg LIKE bsik-rebzg,        " Invoice Ref.
98     *end of <RD1K967585> CAB_ALOK 15.12.2009 CR30002778
99            usnam  LIKE bkpf-usnam,
100           xref1_hd LIKE bkpf-xref1_hd,
101    *Begin of <RD1K981426> CAB_rama CR30007673
102           kidno LIKE  bsik-kidno.
103    *end of <RD1K981426> CAB_rama CR30007673
104    DATA:  END OF ist_srcbsik .
105
106    DATA : wa_srcbsik LIKE ist_srcbsik.
107    DATA : ist_bsiks LIKE ist_srcbsik OCCURS 0 WITH HEADER LINE.
108    DATA : y_doc_nos LIKE zfi_docnos OCCURS 0 WITH HEADER LINE .
109    DATA : f_doc_nos LIKE zfi_docnos OCCURS 0 WITH HEADER LINE .
110
111
112    """""""Added by Anamika on 18/12/2015 for RD1K999458""""
113    DATA : ist_srcbsik_copy LIKE ist_srcbsik OCCURS 0 WITH HEADER LINE.
114    DATA : wa_srcbsik_copy LIKE ist_srcbsik.
115    """""""Added by Anamika on 18/12/2015 for RD1K999458""""
116
117    """""""Added by Anamika on 10/05/2016 for  RD1K9A00LE""""
118    DATA : ist_ZFI_PAYREF_CC  TYPE TABLE OF ZFI_PAYREF_CC.
119    """""""End of added by Anamika on 10/05/2016 for  RD1K9A00LE""""
120
121
122    *-----------Start of <RD1K960891>
123    DATA : BEGIN OF ist_srcbsid OCCURS 0 ,
124           selcbox(1) TYPE c,
125           kunnr LIKE bsid-kunnr ,
126           umskz LIKE bsid-umskz,
127           bukrs LIKE bsid-bukrs ,
128           gjahr LIKE bsid-gjahr,
129           belnr  LIKE bsid-belnr,
130           buzei  LIKE bsid-buzei,
131           budat  LIKE bsid-budat,
132           bschl LIKE bsid-bschl,
133           zlsch LIKE bsid-zlsch,                               "+002
134           zlspr LIKE  bsid-zlspr,
135           shkzg LIKE bsid-shkzg,
136           gsber LIKE  bsid-gsber,
137           dmbtr LIKE bsid-dmbtr,
138           wrbtr LIKE bsid-wrbtr,
139           kidno LIKE  bsid-kidno,                              "+001
140    *Begin of <RD1K967585> CAB_ALOK 15.12.2009 CR30002778
141           rebzg LIKE bsid-rebzg,        " Invoice Ref.
142    *end of <RD1K967585> CAB_ALOK 15.12.2009 CR30002778
143           usnam  LIKE bkpf-usnam,
144       xref1_hd LIKE bkpf-xref1_hd.
145    *       include structure  bsis.
146    DATA:  END OF ist_srcbsid .
147
148    DATA : wa_srcbsid LIKE ist_srcbsid.
149    DATA : ist_bsids LIKE ist_srcbsid OCCURS 0 WITH HEADER LINE.
150    DATA : ist_bsid  TYPE TABLE OF bsid.
151    DATA : wa_bsid  TYPE bsid.
152    *-----------End of <RD1K960891>
153
154    DATA : w_repid TYPE sy-repid.
155
156    DATA:  is_layout  TYPE  slis_layout_alv,
157           ist_fieldcat TYPE  slis_fieldcat_alv  , "line.
158           ist_fcat TYPE  TABLE OF slis_fieldcat_alv,
159            lt_sorttab TYPE slis_t_sortinfo_alv,
160           ls_sorttab TYPE slis_sortinfo_alv. " sort structure for ALV
161
162
163
164    DATA  : mpos TYPE i .
165    DATA : gt_list_top_of_page TYPE slis_t_listheader,
166           gt_list_end_of_list TYPE slis_t_listheader,
167           gt_events   TYPE slis_t_event.
168    *begin of <RD1K967585> CAB_ALOK 15.12.2009 CR30002778
169    DATA : pmtblock_to TYPE bsik-zlspr.
170    *end of <RD1K967585> CAB_ALOK 15.12.2009 CR30002778
171    DATA : ist_srcbsik_l LIKE ist_srcbsik OCCURS 0 WITH HEADER LINE.
172    DATA : ist_srcbsik_l2 LIKE ist_srcbsik OCCURS 0 WITH HEADER LINE.
173    DATA : wa_srcbsik_l LIKE ist_srcbsik.
174    DATA : l_err.
175    CONSTANTS: g_setclass LIKE setleaf-setclass VALUE '0000',
176               g_setname  LIKE setleaf-setname VALUE 'PCS_VENDOR'.
177
178
179    *Begin RD1K999618 CAB_ALOK Change in ZFIBLOCKA for APP Block Vendor-CR 30013820
180    TYPES: BEGIN OF TY_TAB,
181             LIFNR TYPE LFB1-LIFNR,
182           END  OF TY_TAB.
183    data: IST_TAB TYPE TABLE OF TY_TAB.
184    *End RD1K999618 CAB_ALOK Change in ZFIBLOCKA for APP Block Vendor-CR 30013820
185
186    *-------selection-screen---------------------*
187
188    SELECTION-SCREEN : BEGIN OF BLOCK  blk1  WITH FRAME TITLE  text-001.
189
190    SELECT-OPTIONS : s_lifnr FOR bsik-lifnr ,  "<RD1K960891>
191                     s_emp FOR bsik-lifnr ,  "<RD1K981426>
192                     s_kunnr FOR bsid-kunnr ,  "<RD1K960891>
193                     s_year  FOR bsik-gjahr OBLIGATORY,
194                     s_gsber FOR bsik-gsber,
195                     s_budat FOR bsik-budat,
196                     s_usnam FOR bkpf-usnam,
197    *    start of addition prabu k on 06.07.2009
198                     s_xref1 FOR bkpf-xref1_hd.
199
200
201    *  End of addition Prabu K on 06.07.2009
202
203    PARAMETERS :  p_bukrs LIKE bsik-bukrs OBLIGATORY .
204    SELECT-OPTIONS : s_docno FOR bsik-belnr.
205
206    SELECTION-SCREEN : END OF BLOCK blk1.
207    SELECTION-SCREEN : BEGIN OF BLOCK  blk2  WITH FRAME .
208    SELECTION-SCREEN BEGIN OF  LINE .
209    SELECTION-SCREEN COMMENT 2(70) text-002 FOR FIELD p_x2a .
210    PARAMETERS : p_x2a RADIOBUTTON GROUP rad1  .
211    SELECTION-SCREEN END OF LINE.
212    SELECTION-SCREEN BEGIN OF  LINE .
213    SELECTION-SCREEN COMMENT 2(70) text-003 FOR FIELD p_a2x.
214    PARAMETERS :  p_a2x RADIOBUTTON GROUP rad1   .
215    SELECTION-SCREEN END OF LINE.
216    SELECTION-SCREEN ULINE.
217    SELECTION-SCREEN BEGIN OF  LINE .
218    *-------+003
219    SELECTION-SCREEN COMMENT 2(70) text-004 FOR FIELD p_r2x.
220    PARAMETERS :  p_r2x RADIOBUTTON GROUP rad1.
221    SELECTION-SCREEN END OF LINE.
222    * Begin of RD1K971966 CAB_ALOK CR30004183
223    SELECTION-SCREEN BEGIN OF  LINE .
224    SELECTION-SCREEN COMMENT 2(70) text-007 FOR FIELD p_s2x.
225    PARAMETERS:   p_s2x  RADIOBUTTON GROUP rad1.
226    SELECTION-SCREEN END OF LINE.
227    * End of RD1K971966 CAB_ALOK CR30004183
228    SELECTION-SCREEN : END OF BLOCK blk2.
229
230    *------+003
231
232    *------------end selection screen--------------*
233
234    CONSTANTS  : g_zlspr_x   LIKE bseg-zlspr  VALUE 'X',
235                 g_zlspr_a   LIKE bseg-zlspr VALUE 'A',
236                 g_zlspr_r  LIKE bseg-zlspr  VALUE 'R',
237    * Begin of RD1K971966 CAB_ALOK CR30004183
238                 g_zlspr_s   LIKE bseg-zlspr  VALUE 'S'.
239    * End of RD1K971966 CAB_ALOK CR30004183
240
241    *---------------------events -----------------------*
242    RANGES: r_vendor FOR lfa1-lifnr.
243    r_vendor-low = '0007000000'.
244
245    r_vendor-high = '0007999999'.
246
247    r_vendor-option = 'BT'.
248
249    r_vendor-sign = 'I'.
250
251    APPEND r_vendor.
252    * *Start of addition Prabu K on 11.07.2009
253    AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_xref1-low.
254
255
256      TYPES : BEGIN OF ty_t526,
257              sachx TYPE sachx,
258              werks TYPE sbmod,
259              END OF ty_t526.
260
261      TYPES: BEGIN OF ty_final,
262             bukrs TYPE bukrs,
263             persa TYPE persa,
264             sachx TYPE sachx,
265             END OF ty_final.
266      TYPES: BEGIN OF ty_t5009,
267             persa TYPE persa,
268             bukrs TYPE bukrs,
269             END OF ty_t5009.
270      DATA: lv_area TYPE STANDARD TABLE OF ty_t526 ,
271              wa_area LIKE LINE OF lv_area.
272
273      DATA: it_t5009 TYPE STANDARD TABLE OF ty_t5009 ,
274              wa_t5009 LIKE LINE OF  it_t5009.
275
276      DATA: it_final TYPE STANDARD TABLE OF ty_final ,
277              wa_final LIKE LINE OF  it_final.
278
279      SELECT sachx werks FROM t526 INTO CORRESPONDING FIELDS OF TABLE lv_area.  "#EC CI_NOORDER
280
281      SORT lv_area BY sachx.
282      DELETE ADJACENT DUPLICATES FROM lv_area
283      COMPARING sachx.
284
285    *  select persa bukrs  from t500p into table it_t5009 for all entries
286    *                         in lv_area where persa = lv_area-sachx.
287
288      SELECT persa bukrs  FROM t500p INTO CORRESPONDING FIELDS OF TABLE it_t5009.
289
290      SORT it_t5009  BY persa.
291      DELETE ADJACENT DUPLICATES FROM it_t5009
292      COMPARING persa.
293
294      LOOP AT lv_area INTO wa_area.
295
296        READ TABLE it_t5009 INTO wa_t5009 WITH KEY persa = wa_area-werks.
297        wa_final-sachx = wa_area-sachx.
298        wa_final-persa = wa_t5009-persa.
299        wa_final-bukrs = wa_t5009-bukrs.
300        APPEND wa_final TO it_final.
301      ENDLOOP.
302      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
303        EXPORTING
304          retfield        = 'SACHX'
305          dynpprog        = 'ZFI_REM_PYBLCK'
306          dynpnr          = sy-dynnr
307          dynprofield     = 'S_XREF1-LOW'
308          value_org       = 'S'
309        TABLES
310          value_tab       = it_final
311        EXCEPTIONS
312          parameter_error = 1
313          no_values_found = 2
314          OTHERS          = 3.
315
316      IF sy-subrc <> 0.
317    *
318    *    message id sy-msgid type sy-msgty number sy-msgno
319    *            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
320
321      ENDIF.
322
323    AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_xref1-high.
324      TYPES : BEGIN OF ty_t526,
325              sachx TYPE sachx,
326              werks TYPE sbmod,
327              END OF ty_t526.
328
329      TYPES: BEGIN OF ty_final,
330             bukrs TYPE bukrs,
331             persa TYPE persa,
332             sachx TYPE sachx,
333             END OF ty_final.
334      TYPES: BEGIN OF ty_t5009,
335             persa TYPE persa,
336             bukrs TYPE bukrs,
337             END OF ty_t5009.
338      DATA: lv_area TYPE STANDARD TABLE OF ty_t526 ,
339              wa_area LIKE LINE OF lv_area.
340
341      DATA: it_t5009 TYPE STANDARD TABLE OF ty_t5009 ,
342              wa_t5009 LIKE LINE OF  it_t5009.
343
344      DATA: it_final TYPE STANDARD TABLE OF ty_final ,
345              wa_final LIKE LINE OF  it_final.
346
347      SELECT sachx werks FROM t526 INTO CORRESPONDING FIELDS OF TABLE lv_area.  "#EC CI_NOORDER
348
349      SORT lv_area BY sachx.
350      DELETE ADJACENT DUPLICATES FROM lv_area
351      COMPARING sachx.
352
353    *  select persa bukrs  from t500p into table it_t5009 for all entries
354    *                         in lv_area where persa = lv_area-sachx.
355
356      SELECT persa bukrs  FROM t500p INTO CORRESPONDING FIELDS OF TABLE it_t5009.
357
358      SORT it_t5009  BY persa.
359      DELETE ADJACENT DUPLICATES FROM it_t5009
360      COMPARING persa.
361
362      LOOP AT lv_area INTO wa_area.
363
364        READ TABLE it_t5009 INTO wa_t5009 WITH KEY persa = wa_area-werks.
365        wa_final-sachx = wa_area-sachx.
366        wa_final-persa = wa_t5009-persa.
367        wa_final-bukrs = wa_t5009-bukrs.
368        APPEND wa_final TO it_final.
369      ENDLOOP.
370      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
371        EXPORTING
372          retfield        = 'SACHX'
373          dynpprog        = 'ZFI_REM_PYBLCK'
374          dynpnr          = sy-dynnr
375          dynprofield     = 'S_XREF1-HIGH'
376          value_org       = 'S'
377        TABLES
378          value_tab       = it_final
379        EXCEPTIONS
380          parameter_error = 1
381          no_values_found = 2
382          OTHERS          = 3.
383
384      IF sy-subrc <> 0.
385    *
386    *    message id sy-msgid type sy-msgty number sy-msgno
387    *            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
388
389      ENDIF.
390    * End of addition Prabu K on 11.07.2009
391
392
393    AT SELECTION-SCREEN ON p_bukrs .
394      SELECT SINGLE * FROM t001  WHERE bukrs = p_bukrs.
395      IF sy-subrc <> 0.
396        MESSAGE e010(fi).
397      ENDIF.
398    *---------Start of <RD1K960891>
399      AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
400                  ID 'ACTVT' FIELD '02'
401                  ID 'BUKRS' FIELD p_bukrs.
402
403      IF sy-subrc <> 0.
404        MESSAGE  e091(8b) WITH p_bukrs.
405      ENDIF.
406    *-----------End of <RD1K960891>
407
408    *------------------------------------------------------*
409    START-OF-SELECTION.
410    *------------------------------------------------------*
411    *-----------Start of <RD1K960891>
412      IF s_lifnr IS INITIAL AND s_kunnr IS INITIAL AND s_emp IS INITIAL.
413        MESSAGE   e322(zfi).
414      ENDIF.
415      IF  NOT  s_lifnr IS INITIAL  AND  NOT s_kunnr IS INITIAL .
416        MESSAGE   e322(zfi).
417      ENDIF.
418
419    *remove before TP
420    *  IF NOT sy-uname = 'CAB_ALOK' .
421      IF NOT s_lifnr IS INITIAL.
422        DATA : ist_zhr_institute TYPE STANDARD TABLE OF zhr_institute,
423               wa_zhr_institute TYPE zhr_institute,
424               ist_setleaf  LIKE setleaf OCCURS 0 WITH HEADER LINE,
425               l_e TYPE c .
426
427        l_e = 'X'.
428        REFRESH : ist_setleaf,ist_zhr_institute.
429        CLEAR : ist_setleaf,ist_zhr_institute.
430        SELECT * FROM zhr_institute
431          INTO CORRESPONDING FIELDS OF TABLE ist_zhr_institute.  "#EC CI_NOORDER
432
433        SELECT * FROM setleaf
434        INTO CORRESPONDING FIELDS OF TABLE ist_setleaf
435        WHERE setclass = g_setclass
436          AND setname = g_setname.
437
438        AUTHORITY-CHECK OBJECT 'ZFIBLKVEND'
439                   ID 'ACTVT' FIELD '02'.
440        IF  sy-subrc <> 0.
441    * Begin of <RD1K976747> on 14062011
442          LOOP AT s_lifnr.
443            IF NOT s_lifnr-low IS INITIAL.
444              LOOP AT ist_zhr_institute INTO wa_zhr_institute
445                WHERE lifnr = s_lifnr-low.
446                CLEAR l_e.
447              ENDLOOP.
448              READ TABLE ist_setleaf WITH KEY setclass = g_setclass
449                                              setname  = g_setname
450                                              valfrom  = s_lifnr-low.
451              IF sy-subrc EQ 0.
452                CLEAR l_e.
453              ENDIF.
454            ENDIF.
455            IF NOT s_lifnr-high IS INITIAL.
456              LOOP AT ist_zhr_institute INTO wa_zhr_institute
457                WHERE lifnr = s_lifnr-high.
458                CLEAR l_e.
459              ENDLOOP.
460              READ TABLE ist_setleaf WITH KEY setclass = g_setclass
461                                              setname  = g_setname
462                                              valfrom  = s_lifnr-high.
463              IF sy-subrc EQ 0.
464                CLEAR l_e.
465              ENDIF.
466            ENDIF.
467          ENDLOOP.
468          IF l_e = 'X'.
469            MESSAGE e410(zfi) WITH text-005.
470          ENDIF.
471    *        MESSAGE e323(zfi) WITH text-005.
472    * End of <RD1K976747>
473        ENDIF.
474
475
476        LOOP AT s_lifnr.
477          IF NOT s_lifnr-low IS INITIAL.
478            IF s_lifnr-low IN r_vendor.
479              MESSAGE e425(zfi) WITH text-009.
480            ENDIF.
481          ENDIF.
482          IF NOT s_lifnr-high IS INITIAL.
483            IF s_lifnr-high IN r_vendor.
484              MESSAGE e425(zfi) WITH text-009.
485            ENDIF.
486          ENDIF.
487        ENDLOOP.
488
489      ELSEIF NOT s_kunnr IS INITIAL.
490        AUTHORITY-CHECK OBJECT 'ZFIBLKCUST'
491                   ID 'ACTVT' FIELD '02'.
492        IF sy-subrc <> 0.
493    * Begin of <RD1K976747> on 14062011
494          MESSAGE e410(zfi) WITH text-006.
495    *        MESSAGE e323(zfi) WITH text-006.
496    * End of <RD1K976747>
497        ENDIF.
498      ELSEIF NOT s_emp IS INITIAL.
499        PERFORM authority_check USING 'ZFIBLKVEMP' 'VEMP' .
500
501        IF NOT s_emp IS INITIAL.
502          LOOP AT s_emp.
503            IF NOT s_emp-low IS INITIAL.
504              IF s_emp-low NOT IN r_vendor.
505                MESSAGE e425(zfi) WITH text-011.
506              ENDIF.
507            ENDIF.
508            IF NOT s_emp-high IS INITIAL.
509              IF s_emp-high NOT IN r_vendor.
510                MESSAGE e425(zfi) WITH text-011.
511              ENDIF.
512            ENDIF.
513            IF s_lifnr IS INITIAL.
514              s_lifnr-sign = s_emp-sign.
515              s_lifnr-option = s_emp-option.
516              s_lifnr-low = s_emp-low.
517              s_lifnr-high = s_emp-high.
518            ENDIF.
519    *          append s_lifnr.
520    *        endif.
521          ENDLOOP.
522          s_lifnr[] = s_emp[].
523        ENDIF.
524      ENDIF.
525    *  ENDIF.
526
527
528      IF NOT s_lifnr  IS INITIAL.
529    *Begin RD1K998216       CAB_ALOK     Change in ZFIBLOCKA for APP Block Vendor-CR 30013154
530    if p_a2x = 'X'.
531        PERFORM VALIDATE_VENDOR.
532    endif.
533    *End RD1K998216       CAB_ALOK     Change in ZFIBLOCKA for APP Block Vendor-CR 30013154
534
535    *Begin RD1K999618 CAB_ALOK Change in ZFIBLOCKA for APP Block Vendor-CR 30013820
536    *    PERFORM   get_rel_docs.
537    *    PERFORM display_docs.
538        IF IST_TAB[] is INITIAL.
539          PERFORM   get_rel_docs.
540          PERFORM display_docs.
541        ENDIF.
542    *End RD1K999618 CAB_ALOK Change in ZFIBLOCKA for APP Block Vendor-CR 30013820
543
544
545      ELSEIF  NOT s_kunnr IS INITIAL.
546        PERFORM   get_rel_docs_cust.
547        PERFORM display_docs_cust.
548      ENDIF.
549    *-----------End of <RD1K960891>
550
551
552    *&---------------------------------------------------------------------*
553    *&      Form  display_docs
554    *&---------------------------------------------------------------------*
555    *       text
556    *----------------------------------------------------------------------*
557    *  -->  p1        text
558    *  <--  p2        text
559    *----------------------------------------------------------------------*
560    FORM display_docs.
561      PERFORM init_fieldcat.
562      PERFORM eventtab_build TABLES gt_events.
563      PERFORM comment_build TABLES gt_list_top_of_page.
564      PERFORM  sort_build .
565      PERFORM  print_alv.
566
567    ENDFORM.                    " display_docs
568    *&---------------------------------------------------------------------*
569    *&      Form  init_fieldcat
570    *&---------------------------------------------------------------------*
571    *       text
572    *----------------------------------------------------------------------*
573    *  -->  p1        text
574    *  <--  p2        text
575    *----------------------------------------------------------------------*
576    FORM init_fieldcat.
577      w_repid  = sy-repid.
578
579      mpos = 0.
580      mpos = mpos + 1.
581      ist_fieldcat-fieldname = 'SELCBOX'.
582      ist_fieldcat-tabname = 'IST_SRCBSIK'.
583      ist_fieldcat-ddictxt = 'M'.
584      ist_fieldcat-col_pos =  mpos.
585      ist_fieldcat-seltext_m  = 'Select'.
586      ist_fieldcat-lowercase  = 'Y'.
587      ist_fieldcat-checkbox = 'X'.
588      ist_fieldcat-input = 'X'.
589      APPEND ist_fieldcat TO ist_fcat.
590      CLEAR ist_fieldcat.
591
592
593
594      mpos = mpos + 1.
595      ist_fieldcat-fieldname = 'LIFNR'.
596      ist_fieldcat-tabname = 'IST_SRCBSIK'.
597      ist_fieldcat-ddictxt = 'M'.
598      ist_fieldcat-col_pos =  mpos.
599      ist_fieldcat-seltext_m  = 'VendorNumber '.
600      ist_fieldcat-lowercase  = 'Y'.
601      APPEND ist_fieldcat TO ist_fcat.
602      CLEAR ist_fieldcat.
603
604
605      mpos = mpos + 1.
606      ist_fieldcat-fieldname = 'BELNR'.
607      ist_fieldcat-tabname = 'IST_SRCBSIK'.
608      ist_fieldcat-ddictxt = 'M'.
609      ist_fieldcat-col_pos =  mpos.
610      ist_fieldcat-seltext_m  = 'Doc.No.'.
611      ist_fieldcat-lowercase  = 'Y'.
612      APPEND ist_fieldcat TO ist_fcat.
613      CLEAR ist_fieldcat.
614
615
616      mpos = mpos + 1.
617      ist_fieldcat-fieldname = 'BUZEI'.
618      ist_fieldcat-tabname = 'IST_SRCBSIK'.
619      ist_fieldcat-ddictxt = 'M'.
620      ist_fieldcat-col_pos =  mpos.
621      ist_fieldcat-seltext_m  = 'Item.no.'.
622      ist_fieldcat-lowercase  = 'Y'.
623      APPEND ist_fieldcat TO ist_fcat.
624      CLEAR ist_fieldcat.
625
626      mpos = mpos + 1.
627      ist_fieldcat-fieldname = 'GSBER'.
628      ist_fieldcat-tabname = 'IST_SRCBSIK'.
629      ist_fieldcat-ddictxt = 'M'.
630      ist_fieldcat-col_pos =  mpos.
631      ist_fieldcat-seltext_m  = 'Business Area'.
632      ist_fieldcat-lowercase  = 'Y'.
633      APPEND ist_fieldcat TO ist_fcat.
634      CLEAR ist_fieldcat.
635
636    *BEGIN of <RD1K967585> CAB_ALOK 15.12.2009 CR30002778
637      mpos = mpos + 1.
638      ist_fieldcat-fieldname = 'REBZG'.
639      ist_fieldcat-tabname = 'IST_SRCBSIK'.
640      ist_fieldcat-ddictxt = 'M'.
641      ist_fieldcat-col_pos =  mpos.
642      ist_fieldcat-seltext_m  = 'Invoice Reference'.
643    *  ist_fieldcat-lowercase  = 'Y'.
644      APPEND ist_fieldcat TO ist_fcat.
645      CLEAR ist_fieldcat.
646    *end of <RD1K967585> CAB_ALOK 15.12.2009 CR30002778
647
648    *BEGIN of <RD1K967585> CAB_RAMA 09.08.2012 CR30007559
649      mpos = mpos + 1.
650      ist_fieldcat-fieldname = 'KIDNO'.
651      ist_fieldcat-tabname = 'IST_SRCBSIK'.
652      ist_fieldcat-ddictxt = 'M'.
653      ist_fieldcat-col_pos =  mpos.
654      ist_fieldcat-seltext_m  = 'Payment Reference'.
655    *  ist_fieldcat-lowercase  = 'Y'.
656      APPEND ist_fieldcat TO ist_fcat.
657      CLEAR ist_fieldcat.
658    *end of <RD1K967585> CAB_RAMA 09.08.2012 CR30007559
659
660      mpos = mpos + 1.
661      ist_fieldcat-fieldname = 'BSCHL'.
662      ist_fieldcat-tabname = 'IST_SRCBSIK'.
663      ist_fieldcat-ddictxt = 'M'.
664      ist_fieldcat-col_pos =  mpos.
665      ist_fieldcat-seltext_m  = 'Posting Key.'.
666      ist_fieldcat-lowercase  = 'Y'.
667      APPEND ist_fieldcat TO ist_fcat.
668      CLEAR ist_fieldcat.
669
670
671
672
673      mpos = mpos + 1.
674      ist_fieldcat-fieldname = 'BUDAT'.
675      ist_fieldcat-tabname = 'IST_SRCBSIK'.
676      ist_fieldcat-ddictxt = 'M'.
677      ist_fieldcat-col_pos =  mpos.
678      ist_fieldcat-seltext_m  = 'Posting Date'.
679      ist_fieldcat-lowercase  = 'Y'.
680      APPEND ist_fieldcat TO ist_fcat.
681      CLEAR ist_fieldcat.
682
683
684      mpos = mpos + 1.
685      ist_fieldcat-fieldname = 'DMBTR'.
686      ist_fieldcat-tabname = 'IST_SRCBSIK'.
687      ist_fieldcat-ddictxt = 'M'.
688      ist_fieldcat-col_pos =  mpos.
689      ist_fieldcat-seltext_m  = 'AmtInLclCurncy'.
690      ist_fieldcat-lowercase  = 'Y'.
691      APPEND ist_fieldcat TO ist_fcat.
692      CLEAR ist_fieldcat.
693
694
695
696      mpos = mpos + 1.
697      ist_fieldcat-fieldname = 'WRBTR'.
698      ist_fieldcat-tabname = 'IST_SRCBSIK'.
699      ist_fieldcat-ddictxt = 'M'.
700      ist_fieldcat-col_pos =  mpos.
701      ist_fieldcat-seltext_m  = 'AmtInDocCurncy'.
702      ist_fieldcat-lowercase  = 'Y'.
703      APPEND ist_fieldcat TO ist_fcat.
704      CLEAR ist_fieldcat.
705
706
707      mpos = mpos + 1.
708      ist_fieldcat-fieldname = 'ZLSCH'.
709      ist_fieldcat-tabname = 'IST_SRCBSIK'.
710      ist_fieldcat-ddictxt = 'M'.
711      ist_fieldcat-col_pos =  mpos.
712      ist_fieldcat-seltext_m  = 'PaymntMethod'.
713      ist_fieldcat-lowercase  = 'Y'.
714      APPEND ist_fieldcat TO ist_fcat.
715      CLEAR ist_fieldcat.
716
717
718
719      mpos = mpos + 1.
720      ist_fieldcat-fieldname = 'ZLSPR'.
721      ist_fieldcat-tabname = 'IST_SRCBSIK'.
722      ist_fieldcat-ddictxt = 'M'.
723      ist_fieldcat-col_pos =  mpos.
724      ist_fieldcat-seltext_m  = 'PaymntBlock'.
725      ist_fieldcat-lowercase  = 'Y'.
726      APPEND ist_fieldcat TO ist_fcat.
727      CLEAR ist_fieldcat.
728    *  *Start of addition Prabu K on 06.07.2009
729      mpos = mpos + 1.
730      ist_fieldcat-fieldname = 'XREF1_HD'.
731      ist_fieldcat-tabname = 'IST_SRCBSIK'.
732      ist_fieldcat-ddictxt = 'M'.
733      ist_fieldcat-col_pos =  mpos.
734      ist_fieldcat-seltext_m  = 'Location'.
735      ist_fieldcat-lowercase  = 'Y'.
736      APPEND ist_fieldcat TO ist_fcat.
737      CLEAR ist_fieldcat.
738
739    * End of addition Prabu K on 06.07.2009
740
741      IF NOT s_usnam[] IS INITIAL.
742        mpos = mpos + 1.
743        ist_fieldcat-fieldname = 'USNAM'.
744        ist_fieldcat-tabname = 'IST_SRCBSIK'.
745        ist_fieldcat-ddictxt = 'M'.
746        ist_fieldcat-col_pos =  mpos.
747        ist_fieldcat-seltext_m  = 'Created By'.
748        ist_fieldcat-lowercase  = 'Y'.
749        APPEND ist_fieldcat TO ist_fcat.
750        CLEAR ist_fieldcat.
751      ENDIF.
752
753
754    ENDFORM.                    " init_fieldcat
755    *&---------------------------------------------------------------------*
756    *&      Form  eventtab_build
757    *&---------------------------------------------------------------------*
758    *       text
759    *----------------------------------------------------------------------*
760    *      -->P_GT_EVENTS[]  text
761    *----------------------------------------------------------------------*
762    *Begin of <RD1K960611>
763    *FORM eventtab_build USING    p_gt_events[].
764    FORM eventtab_build TABLES  p_gt_events.
765    *End of <RD1K960611>
766
767      DATA : ls_event TYPE slis_alv_event.
768      CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
769        EXPORTING
770          i_list_type = 0
771        IMPORTING
772          et_events   = gt_events.
773      READ TABLE gt_events WITH KEY name =  slis_ev_user_command
774                                INTO ls_event.
775      IF sy-subrc = 0.
776        MOVE 'MAKE_COMMAND' TO ls_event-form.
777        APPEND ls_event TO gt_events.
778      ENDIF.
779      CLEAR ls_event.
780
781
782    ENDFORM.                    " eventtab_build
783    *&---------------------------------------------------------------------*
784    *&      Form  comment_build
785    *&---------------------------------------------------------------------*
786    *       text
787    *----------------------------------------------------------------------*
788    *      -->P_GT_LIST_TOP_OF_PAGE[]  text
789    *----------------------------------------------------------------------*
790    *Begin of <RD1K960611>
791    *FORM comment_build USING    p_gt_list_top_of_page[].
792    FORM comment_build TABLES  p_gt_list_top_of_page.
793    *End of <RD1K960611>
794
795    ENDFORM.                    " comment_build
796    *&---------------------------------------------------------------------*
797    *&      Form  sort_build
798    *&---------------------------------------------------------------------*
799    *       text
800    *----------------------------------------------------------------------*
801    *  -->  p1        text
802    *  <--  p2        text
803    *----------------------------------------------------------------------*
804    FORM sort_build.
805      w_repid = sy-repid.
806      is_layout-key_hotspot = 'X'.
807      is_layout-colwidth_optimize = 'X'.
808      ls_sorttab-fieldname = 'LIFNR'.
809      ls_sorttab-up = 'X'.
810      APPEND ls_sorttab TO lt_sorttab.
811      ls_sorttab-fieldname = 'BSCHL'.
812      ls_sorttab-up = 'X'.
813      APPEND ls_sorttab TO lt_sorttab.
814      ls_sorttab-fieldname = 'BELNR'.
815      ls_sorttab-up = 'X'.
816      APPEND ls_sorttab TO lt_sorttab.
817      ls_sorttab-fieldname = 'BUDAT'.
818      ls_sorttab-up = 'X'.
819      APPEND ls_sorttab TO lt_sorttab.
820
821
822
823    ENDFORM.                    " sort_build
824    *&---------------------------------------------------------------------*
825    *&      Form  print_alv
826    *&---------------------------------------------------------------------*
827    *       text
828    *----------------------------------------------------------------------*
829    *  -->  p1        text
830    *  <--  p2        text
831    *----------------------------------------------------------------------*
832    FORM print_alv.
833      CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
834        EXPORTING
835          i_callback_program       = w_repid
836          i_callback_pf_status_set = 'ALV_PFST'
837          i_callback_user_command  = 'MAKE_COMMAND'
838          is_layout                = is_layout
839          it_fieldcat              = ist_fcat[]
840          it_sort                  = lt_sorttab
841          it_events                = gt_events
842          i_save                   = 'A'
843        TABLES
844          t_outtab                 = ist_srcbsik
845    * Begin of Changes on 20-Jun-2013
846        EXCEPTIONS
847          program_error = 1
848          OTHERS        = 2.
849    * End of Changes on 20-Jun-2013
850      IF sy-subrc <> 0.
851    *    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
852    *            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
853      ENDIF.
854
855
856    ENDFORM.                    " print_alv
857    *---------------------------------------------------------------------*
858    *       FORM alv_pfst                                                 *
859    *---------------------------------------------------------------------*
860    *       ........                                                      *
861    *---------------------------------------------------------------------*
862    *  -->  RT_EXTAB                                                      *
863    *---------------------------------------------------------------------*
864    FORM alv_pfst USING rt_extab TYPE slis_t_extab.
865      SET PF-STATUS 'S100'.
866    ENDFORM.                    "alv_pfst
867
868    *---------------------------------------------------------------------*
869    *       FORM make_command                                             *
870    *---------------------------------------------------------------------*
871    *       ........                                                      *
872    *---------------------------------------------------------------------*
873    *  -->  R_UCOMM                                                       *
874    *  -->  RS_SELFIELD                                                   *
875    *---------------------------------------------------------------------*
876    FORM make_command USING r_ucomm LIKE sy-ucomm
877                            rs_selfield TYPE slis_selfield.
878    *-----------------------------------------------------*
879    *-----------------------------------------------------*
880      DATA : index_aux LIKE sy-tabix.
881      DATA : l_found(1). "+010
882
883      index_aux = rs_selfield-tabindex.
884
885      CASE r_ucomm.
886
887        WHEN 'REL'.
888    *+010 : Start
889
890          IF p_a2x = 'X'.
891
892            LOOP AT ist_srcbsik INTO wa_srcbsik WHERE selcbox = 'X'.
893
894              IF wa_srcbsik-kidno = text-013. "PERIOD END LIABILITY
895
896                l_found = 'X'.
897
898                EXIT.
899              ENDIF.
900
901            ENDLOOP.
902
903          ENDIF.
904
905          IF l_found IS INITIAL.
906    *+010 : End
907    *Begin of <RD1K981426> CAB_RAMA CR 30007673
908            IF ist_srcbsik_l[] IS INITIAL OR l_err = 'X'.
909              ist_srcbsik_l[] = ist_srcbsik[].
910            ENDIF.
911
912            IF ( p_a2x = 'X' OR p_r2x = 'X' OR p_s2x = 'X' ).
913              LOOP AT ist_srcbsik INTO wa_srcbsik WHERE selcbox = 'X' AND kidno <> 'PERIOD END LIABILITY'.
914                IF  ( wa_srcbsik-bschl = '31' OR wa_srcbsik-bschl = '34' OR wa_srcbsik-bschl = '36'
915                  OR wa_srcbsik-bschl = '39' OR wa_srcbsik-bschl = '21' OR wa_srcbsik-bschl = '26').
916
917                  """""""Added by Anamika on 18/12/2015 for RD1K999458""""
918                  DATA : l_text1(250).
919                  DATA: BEGIN OF ist_errmsg OCCURS 0,
920                        text(100),
921                        END OF ist_errmsg.
922    """""""Added by Anamika on 10/05/2016 for  RD1K9A00LE""""
923       select * from  ZFI_PAYREF_CC into CORRESPONDING FIELDS OF table ist_ZFI_PAYREF_CC
924         where BUKRS = p_BUKRS and CHECK_VALID = 'X'.
925                IF sy-subrc eq 0.
926    """""""End of added by Anamika on 10/05/2016 for  RD1K9A00LE""""
927
928
929                  l_text1 = 'Kindly ensure recovery of below documents with same payment reference.' .
930                  move  l_text1 to ist_errmsg-text.
931                  append ist_errmsg.
932    """""""Added by Anamika on 10/05/2016 for  RD1K9A00LE""""
933                  LOOP AT ist_srcbsik_copy INTO wa_srcbsik_copy where belnr in s_docno .
934
935                IF sy-subrc eq 0.
936
937          delete ist_srcbsik_copy where BELNR = wa_srcbsik_copy-BELNR.
938                                           ENDIF.
939    endloop.
940    """""""End of added by Anamika on 10/05/2016 for  RD1K9A00LE""""
941
942                  if s_docno IS not INITIAL.
943
944
945                    if ist_srcbsik_copy[] IS not INITIAL.
946                      l_err = 'X'.
947                      LOOP AT ist_srcbsik_copy INTO wa_srcbsik_copy.
948                        move WA_srcbsik_copy-BELNR to ist_errmsg-text.
949                        append ist_errmsg.
950                      ENDLOOP.
951
952                      CALL FUNCTION 'ZPOPUP_WITH_TABLE_DISPLAY_OK'
953                      EXPORTING
954                        titletext    = 'Warning/Error'
955                        endpos_col   = 100
956                        endpos_row   = 25
957                        startpos_col = 20
958                        startpos_row = 05
959                      TABLES
960                        valuetab     = ist_errmsg
961                      EXCEPTIONS
962                        break_off    = 1
963                        OTHERS       = 2.
964
965                    REFRESH ist_errmsg.
966                    IF sy-subrc <> 0.
967                      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
968                        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
969                    endif.
970
971                    LEAVE to screen 0.
972                  else.
973                  endif.
974
975                endif.
976
977    """""""Added by Anamika on 10/05/2016 for  RD1K9A00LE""""
978    else.
979      endif.
980    """""""End of added by Anamika on 10/05/2016 for  RD1K9A00LE""""
981
982                  """""""Added by Anamika on 18/12/2015 for RD1K999458""""
983
984                  LOOP AT ist_srcbsik_l INTO wa_srcbsik_l
985                    WHERE selcbox <> 'X' AND ( bschl = '31' OR bschl = '34' OR bschl = '36' OR bschl = '39'
986                    OR bschl = '21'  OR bschl = '26' )
987                    AND kidno = wa_srcbsik-kidno
988                    AND kidno <> 'PERIOD END LIABILITY'
989                    AND lifnr = wa_srcbsik-lifnr.
990                    l_err = 'X'.
991                    MESSAGE e100(zfi) WITH text-010.
992
993                  ENDLOOP.
994                ENDIF.
995              ENDLOOP.
996            ENDIF.
997
998            IF ( p_a2x = 'X' OR p_r2x = 'X' OR p_s2x = 'X' ).
999              LOOP AT ist_srcbsik INTO wa_srcbsik WHERE selcbox = 'X' ."AND KIDNO <> 'PERIOD END LIABILITY'.
1000               IF  ( wa_srcbsik-bschl = '31' OR wa_srcbsik-bschl = '34' OR wa_srcbsik-bschl = '36'
1001                 OR wa_srcbsik-bschl = '39' OR wa_srcbsik-bschl = '21' OR wa_srcbsik-bschl = '26').
1002                 LOOP AT ist_srcbsik_l INTO wa_srcbsik_l
1003                   WHERE selcbox <> 'X' AND ( bschl = '31' OR bschl = '34' OR bschl = '36' OR bschl = '39'
1004                   OR bschl = '21'  OR bschl = '26' )
1005                   AND belnr = wa_srcbsik-rebzg
1006   *              AND KIDNO <> 'PERIOD END LIABILITY'
1007                   AND lifnr = wa_srcbsik-lifnr.
1008                   l_err = 'X'.
1009                   MESSAGE e100(zfi) WITH text-012.
1010                 ENDLOOP.
1011
1012                 LOOP AT ist_srcbsik_l INTO wa_srcbsik_l
1013                          WHERE selcbox <> 'X' AND ( bschl = '31' OR bschl = '34' OR bschl = '36' OR bschl = '39'
1014                          OR bschl = '21'  OR bschl = '26' )
1015                          AND rebzg = wa_srcbsik-belnr
1016   *                     AND KIDNO <> 'PERIOD END LIABILITY'
1017                          AND lifnr = wa_srcbsik-lifnr.
1018                   l_err = 'X'.
1019                   MESSAGE e100(zfi) WITH text-012.
1020                 ENDLOOP.
1021               ENDIF.
1022             ENDLOOP.
1023           ENDIF.
1024   *END of <RD1K981426> CAB_RAMA CR 30007673
1025           DELETE ist_srcbsik WHERE  selcbox <> 'X'.
1026           PERFORM   get_upd_bsik.
1027           PERFORM   get_upd_bseg.
1028   *Begin of <RD1K967585> CAB_ALOK 09.12.2009 CR30002778
1029           PERFORM   update_zfi_rem_pyblck_l.    "update logs
1030   *end of <RD1K967585> CAB_ALOK 09.12.2009 CR30002778
1031           LEAVE SCREEN.
1032
1033   *+010 : Start
1034         ELSE.
1035
1036           MESSAGE i526(zfi).
1037
1038         ENDIF.
1039   *+010 : End
1040       WHEN 'ALL'.
1041         PERFORM  select_all.
1042       WHEN 'SAL'.
1043         PERFORM  deselect_all.
1044       WHEN '&F03' OR 'BACK' .
1045         LEAVE  PROGRAM.
1046
1047     ENDCASE.
1048
1049   ENDFORM.                    "make_command
1050   *---------------------------------------------------------------------*
1051   *&      Form  select_all
1052   *&---------------------------------------------------------------------*
1053   *       text
1054   *----------------------------------------------------------------------*
1055   *  -->  p1        text
1056   *  <--  p2        text
1057   *----------------------------------------------------------------------*
1058   FORM select_all.
1059     LOOP AT ist_srcbsik.
1060       ist_srcbsik-selcbox = 'X'.
1061       MODIFY ist_srcbsik.
1062     ENDLOOP.
1063
1064   ENDFORM.                    " select_all
1065   *&---------------------------------------------------------------------*
1066   *&      Form  deselect_all
1067   *&---------------------------------------------------------------------*
1068   *       text
1069   *----------------------------------------------------------------------*
1070   *  -->  p1        text
1071   *  <--  p2        text
1072   *----------------------------------------------------------------------*
1073   FORM deselect_all.
1074     LOOP AT ist_srcbsik.
1075       ist_srcbsik-selcbox = ' '.
1076       MODIFY ist_srcbsik.
1077     ENDLOOP.
1078   ENDFORM.                    " deselect_all
1079   *&---------------------------------------------------------------------
1080   *&---------------------------------------------------------------------*
1081   *&      Form  get_upd_bsik
1082   *&---------------------------------------------------------------------*
1083   *       text
1084   *----------------------------------------------------------------------*
1085   *  -->  p1        text
1086   *  <--  p2        text
1087   *----------------------------------------------------------------------*
1088   FORM get_upd_bsik.
1089
1090     DATA : l_tabix  TYPE sy-tabix.
1091
1092     CHECK NOT ist_srcbsik[] IS INITIAL.
1093
1094     SELECT * INTO TABLE ist_bsik   FROM bsik
1095       FOR ALL ENTRIES  IN  ist_srcbsik
1096       WHERE   lifnr = ist_srcbsik-lifnr
1097             AND  bukrs  =  p_bukrs
1098              AND gjahr = ist_srcbsik-gjahr
1099              AND belnr = ist_srcbsik-belnr
1100              AND buzei = ist_srcbsik-buzei.
1101
1102     IF NOT ist_bsik IS INITIAL.
1103       IF p_x2a = 'X'.
1104         LOOP AT ist_bsik INTO wa_bsik.
1105           l_tabix =   sy-tabix .
1106           IF wa_bsik-zlspr =  g_zlspr_x.
1107             wa_bsik-zlspr =  g_zlspr_a.
1108             MODIFY ist_bsik  FROM  wa_bsik INDEX l_tabix  TRANSPORTING zlspr.
1109           ENDIF.
1110         ENDLOOP.
1111   "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
1112
1113   *      MODIFY  bsik FROM TABLE ist_bsik.
1114   *      COMMIT WORK.
1115   "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
1116       ENDIF.
1117       IF p_a2x = 'X'.
1118         LOOP AT ist_bsik INTO wa_bsik.
1119           l_tabix =   sy-tabix .
1120           IF wa_bsik-zlspr =  g_zlspr_a.
1121             wa_bsik-zlspr =  g_zlspr_x.
1122             MODIFY ist_bsik  FROM  wa_bsik INDEX l_tabix  TRANSPORTING zlspr.
1123           ENDIF.
1124         ENDLOOP.
1125   "Code Remediation changes S4 2025 Conversion Beginof change SAP_ABAP and 15.06.2026
1126   *      MODIFY  bsik FROM TABLE ist_bsik.
1127   *      COMMIT WORK.
1128   "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
1129       ENDIF.
1130
1131   *--+003
1132       IF p_r2x = 'X'.
1133         LOOP AT ist_bsik INTO wa_bsik.
1134           l_tabix =   sy-tabix .
1135           IF wa_bsik-zlspr =  g_zlspr_r.
1136             wa_bsik-zlspr =  g_zlspr_x.
1137             MODIFY ist_bsik  FROM  wa_bsik INDEX l_tabix  TRANSPORTING zlspr.
1138           ENDIF.
1139         ENDLOOP.
1140   "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
1141   *      MODIFY  bsik FROM TABLE ist_bsik.
1142   *      COMMIT WORK.
1143   "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
1144       ENDIF.
1145   *---+003
1146   * Begin of RD1K971966 CAB_ALOK CR30004183
1147       IF p_s2x = 'X'.
1148         LOOP AT ist_bsik INTO wa_bsik.
1149           l_tabix =   sy-tabix .
1150           IF wa_bsik-zlspr =  g_zlspr_s.
1151             wa_bsik-zlspr =  g_zlspr_x.
1152             MODIFY ist_bsik  FROM  wa_bsik INDEX l_tabix  TRANSPORTING zlspr.
1153           ENDIF.
1154         ENDLOOP.
1155   "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
1156   *      MODIFY  bsik FROM TABLE ist_bsik.
1157   *
1158   *      COMMIT WORK.
1159    "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
1160       ENDIF.
1161   * End of RD1K971966 CAB_ALOK CR30004183
1162
1163     ENDIF.
1164   ENDFORM.                    " get_upd_bsik
1165   *
1166   *&---------------------------------------------------------------------*
1167   *&      Form  get_upd_bseg
1168   *&---------------------------------------------------------------------*
1169   *       text
1170   *----------------------------------------------------------------------*
1171   *  -->  p1        text
1172   *  <--  p2        text
1173   *----------------------------------------------------------------------*
1174   FORM get_upd_bseg.
1175     DATA : l_tabix  TYPE sy-tabix.
1176
1177     CHECK NOT ist_srcbsik[] IS INITIAL.
1178
1179     SELECT * INTO TABLE ist_bseg   FROM bseg
1180       FOR ALL ENTRIES  IN  ist_srcbsik
1181       WHERE
1182              bukrs  =  p_bukrs
1183        AND   belnr = ist_srcbsik-belnr
1184        AND   gjahr =  ist_srcbsik-gjahr
1185        AND   buzei = ist_srcbsik-buzei ORDER BY PRIMARY KEY.
1186
1187     CLEAR l_tabix.
1188     IF NOT ist_bseg IS INITIAL.
1189       IF p_x2a = 'X'.
1190         LOOP AT ist_bseg INTO wa_bseg.
1191           l_tabix =   sy-tabix .
1192           IF wa_bseg-zlspr =  g_zlspr_x.
1193             wa_bseg-zlspr =  g_zlspr_a.
1194             MODIFY ist_bseg  FROM  wa_bseg INDEX l_tabix  TRANSPORTING zlspr.
1195           ENDIF.
1196         ENDLOOP.
1197
1198   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1199   * S/4: BSEG payment block (ZLSPR) changed via FI_DOCUMENT_CHANGE (FB02 logic); direct write not allowed.
1200   *      MODIFY bseg FROM TABLE ist_bseg.
1201         LOOP AT ist_bseg INTO wa_bseg.
1202           PERFORM zz_s4_bseg_zlspr USING wa_bseg-bukrs wa_bseg-belnr wa_bseg-gjahr wa_bseg-buzei wa_bseg-zlspr.
1203         ENDLOOP.
1204         COMMIT WORK.
1205   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1206
1207       ENDIF.
1208       CLEAR l_tabix.
1209       IF p_a2x = 'X'.
1210         LOOP AT ist_bseg INTO wa_bseg.
1211           l_tabix =   sy-tabix .
1212           IF wa_bseg-zlspr =  g_zlspr_a.
1213             wa_bseg-zlspr =  g_zlspr_x.
1214             MODIFY ist_bseg  FROM  wa_bseg INDEX l_tabix  TRANSPORTING zlspr.
1215           ENDIF.
1216         ENDLOOP.
1217
1218   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1219   * S/4: BSEG payment block (ZLSPR) changed via FI_DOCUMENT_CHANGE (FB02 logic); direct write not allowed.
1220   *      MODIFY bseg FROM TABLE ist_bseg.
1221         LOOP AT ist_bseg INTO wa_bseg.
1222           PERFORM zz_s4_bseg_zlspr USING wa_bseg-bukrs wa_bseg-belnr wa_bseg-gjahr wa_bseg-buzei wa_bseg-zlspr.
1223         ENDLOOP.
1224         COMMIT WORK.
1225   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1226
1227       ENDIF.
1228   *----+003
1229       IF p_r2x = 'X'.
1230         LOOP AT ist_bseg INTO wa_bseg.
1231           l_tabix =   sy-tabix .
1232           IF wa_bseg-zlspr =  g_zlspr_r.
1233             wa_bseg-zlspr =  g_zlspr_x.
1234             MODIFY ist_bseg  FROM  wa_bseg INDEX l_tabix  TRANSPORTING zlspr.
1235           ENDIF.
1236         ENDLOOP.
1237
1238   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1239   * S/4: BSEG payment block (ZLSPR) changed via FI_DOCUMENT_CHANGE (FB02 logic); direct write not allowed.
1240   *      MODIFY bseg FROM TABLE ist_bseg.
1241         LOOP AT ist_bseg INTO wa_bseg.
1242           PERFORM zz_s4_bseg_zlspr USING wa_bseg-bukrs wa_bseg-belnr wa_bseg-gjahr wa_bseg-buzei wa_bseg-zlspr.
1243         ENDLOOP.
1244         COMMIT WORK.
1245   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1246
1247       ENDIF.
1248   *-------+003
1249
1250   * Begin of RD1K971966 CAB_ALOK CR30004183
1251       IF p_s2x = 'X'.
1252         LOOP AT ist_bseg INTO wa_bseg.
1253           l_tabix =   sy-tabix .
1254           IF wa_bseg-zlspr =  g_zlspr_s.
1255             wa_bseg-zlspr =  g_zlspr_x.
1256             MODIFY ist_bseg  FROM  wa_bseg INDEX l_tabix  TRANSPORTING zlspr.
1257           ENDIF.
1258         ENDLOOP.
1259
1260   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1261   * S/4: BSEG payment block (ZLSPR) changed via FI_DOCUMENT_CHANGE (FB02 logic); direct write not allowed.
1262   *      MODIFY  bseg FROM TABLE ist_bseg.
1263         LOOP AT ist_bseg INTO wa_bseg.
1264           PERFORM zz_s4_bseg_zlspr USING wa_bseg-bukrs wa_bseg-belnr wa_bseg-gjahr wa_bseg-buzei wa_bseg-zlspr.
1265         ENDLOOP.
1266         COMMIT WORK.
1267   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1268
1269         COMMIT WORK.
1270       ENDIF.
1271   * End of RD1K971966 CAB_ALOK CR30004183
1272
1273
1274     ENDIF.
1275
1276
1277   ENDFORM.                    " get_upd_bseg
1278   *&---------------------------------------------------------------------*
1279   *&      Form  get_rel_docs
1280   *&---------------------------------------------------------------------*
1281   *       text
1282   *----------------------------------------------------------------------*
1283   *  -->  p1        text
1284   *  <--  p2        text
1285   *----------------------------------------------------------------------*
1286   FORM get_rel_docs.
1287     SELECT bukrs lifnr umskz gjahr belnr buzei budat bschl
1288   *begin of <RD1K967585> CAB_rama  CR30007673
1289   **begin of <RD1K967585> CAB_ALOK 15.12.2009 CR30002778
1290   **   zlsch zlspr shkzg gsber dmbtr wrbtr  APPENDING
1291   *   zlsch zlspr shkzg gsber dmbtr wrbtr  rebzg APPENDING   "#### waers kidno
1292       zlsch zlspr shkzg gsber dmbtr wrbtr  rebzg kidno APPENDING   "#### waers kidno
1293   **end of <RD1K967585> CAB_ALOK 15.12.2009 CR30002778
1294   *end of <RD1K967585> CAB_rama  CR30007673
1295     CORRESPONDING FIELDS OF TABLE
1296                    ist_srcbsik  FROM bsik
1297                    WHERE
1298                         bukrs  =  p_bukrs
1299                   AND lifnr  IN s_lifnr
1300                   AND gjahr IN s_year
1301                   AND belnr IN s_docno " RD1K982186 CR 30007748
1302                   AND gsber IN s_gsber        "#### extra cond.
1303                   AND budat IN  s_budat.
1304
1305     """""""Added by Anamika on 18/12/2015 for RD1K999458""""
1306     clear : ist_srcbsik_copy,wa_srcbsik_copy .
1307     refresh : ist_srcbsik_copy[].
1308
1309     if s_DOCNO IS not INITIAL.
1310       read TABLE ist_srcbsik into wa_srcbsik_copy index 1.  "#EC CI_NOORDER
1311
1312       SELECT bukrs lifnr umskz gjahr belnr buzei budat bschl
1313       zlsch zlspr shkzg gsber dmbtr wrbtr  rebzg kidno APPENDING
1314     CORRESPONDING FIELDS OF TABLE
1315                    ist_srcbsik_copy  FROM bsik
1316                    WHERE
1317                         bukrs  =  p_bukrs
1318                   AND lifnr  IN s_lifnr
1319                   AND  ZLSPR IN ('A','R')
1320                   AND BSCHL IN ('21','26')
1321                   AND SHKZG = 'S'
1322                   AND KIDNO ne 'PERIOD END LIABILITY '
1323                   AND KIDNO EQ wa_srcbsik_copy-KIDNO.
1324       SORT ist_srcbsik BY lifnr bschl belnr budat .
1325       SORT ist_srcbsik_copy.
1326       DELETE ADJACENT DUPLICATES  FROM ist_srcbsik_copy.  "#EC CI_NOORDER
1327     ENDIF.
1328     """""""Added by Anamika on 18/12/2015 for RD1K999458""""
1329
1330     IF p_x2a = 'X'.
1331       DELETE  ist_srcbsik WHERE zlspr <> g_zlspr_x.
1332     ELSEIF p_a2x = 'X'.
1333       DELETE  ist_srcbsik WHERE zlspr <> g_zlspr_a.
1334   *----+003
1335     ELSEIF p_r2x = 'X'.
1336       DELETE  ist_srcbsik WHERE zlspr <> g_zlspr_r.
1337   * Begin of RD1K971966 CAB_ALOK CR30004183
1338     ELSEIF p_s2x = 'X'.
1339       DELETE  ist_srcbsik WHERE zlspr <> g_zlspr_s.
1340   * end of RD1K971966 CAB_ALOK CR30004183
1341     ENDIF.
1342   *-----+003
1343
1344   *  Start of addition Prabu K on 03.07.2009
1345     DATA wa_bkpf TYPE bkpf.
1346     LOOP AT ist_srcbsik INTO wa_srcbsik.
1347
1348       SELECT SINGLE * FROM bkpf INTO wa_bkpf WHERE bukrs = wa_srcbsik-bukrs AND belnr = wa_srcbsik-belnr
1349          AND xref1_hd IN s_xref1.  "#EC CI_NOORDER
1350       IF sy-subrc NE 0.
1351         DELETE TABLE ist_srcbsik FROM wa_srcbsik.
1352       ELSE.
1353         wa_srcbsik-xref1_hd = wa_bkpf-xref1_hd.
1354         MODIFY ist_srcbsik FROM wa_srcbsik.
1355       ENDIF.
1356     ENDLOOP.
1357   *  End  of addition Prabu K on 03.07.2009
1358     IF NOT s_usnam   IS INITIAL.
1359       IF NOT ist_srcbsik[] IS INITIAL.
1360         SELECT blart usnam ppnam belnr gjahr bldat budat waers bukrs
1361                           INTO CORRESPONDING FIELDS OF TABLE ist_bkpf
1362                            FROM  bkpf
1363                           FOR ALL ENTRIES IN ist_srcbsik
1364   *                     FROM bkpf
1365                    WHERE bukrs = ist_srcbsik-bukrs
1366                    AND  gjahr = ist_srcbsik-gjahr
1367                    AND  belnr = ist_srcbsik-belnr
1368                    AND  budat = ist_srcbsik-budat
1369                    AND ( usnam IN s_usnam  OR usnam EQ 'WF-BATCH' ).  "#EC CI_NOORDER
1370       ENDIF.
1371
1372       IF NOT ist_bkpf[] IS INITIAL.
1373
1374         LOOP AT ist_bkpf WHERE usnam = 'WF-BATCH' .
1375           MOVE-CORRESPONDING ist_bkpf TO y_doc_nos .
1376           MOVE ist_bkpf-usnam TO y_doc_nos-usrel .
1377           APPEND y_doc_nos .
1378         ENDLOOP.
1379
1380         CALL FUNCTION 'Z_FI_GET_REL_USERNAME'
1381           TABLES
1382             y_doc_nos = y_doc_nos
1383             f_doc_nos = f_doc_nos
1384           EXCEPTIONS
1385             not_found = 1
1386             OTHERS    = 2.
1387
1388         LOOP AT ist_bkpf .
1389           READ TABLE y_doc_nos WITH KEY bukrs = ist_bkpf-bukrs
1390                                         belnr = ist_bkpf-belnr
1391                                         gjahr = ist_bkpf-gjahr.
1392           IF sy-subrc EQ 0 .
1393             ist_bkpf-usnam = y_doc_nos-usrel .
1394             MODIFY ist_bkpf TRANSPORTING usnam .
1395           ENDIF .
1396         ENDLOOP.
1397
1398
1399         LOOP AT ist_srcbsik.
1400           READ TABLE ist_bkpf WITH KEY bukrs = ist_srcbsik-bukrs
1401                                    belnr = ist_srcbsik-belnr
1402                                    gjahr = ist_srcbsik-gjahr .
1403           IF sy-subrc = 0.
1404             ist_srcbsik-usnam = ist_bkpf-usnam.
1405             MODIFY ist_srcbsik  TRANSPORTING usnam .
1406           ENDIF.
1407         ENDLOOP.
1408
1409         IF NOT s_usnam[] IS  INITIAL.
1410           DELETE ist_srcbsik WHERE  NOT usnam  IN s_usnam.
1411         ENDIF.
1412
1413       ENDIF.
1414
1415     ENDIF.
1416
1417     ist_bsiks[] = ist_srcbsik[].
1418
1419
1420     REFRESH ist_srcbsik.
1421     CLEAR ist_srcbsik.
1422
1423
1424     LOOP AT ist_bsiks .
1425       IF ist_bsiks-umskz = 'P' OR ist_bsiks-umskz = 'F' or  ist_bsiks-umskz = 'K' OR ist_bsiks-umskz = 'H'
1426       OR ist_bsiks-umskz = ':'                                "+001
1427       OR ist_bsiks-umskz  IS INITIAL.
1428         ist_srcbsik = ist_bsiks.
1429         APPEND ist_srcbsik.
1430         CLEAR ist_srcbsik.
1431       ENDIF.
1432     ENDLOOP.
1433
1434
1435     SORT ist_srcbsik BY lifnr bschl belnr budat .
1436
1437     DELETE ADJACENT DUPLICATES  FROM ist_srcbsik.
1438
1439     CHECK  NOT ist_srcbsik[] IS INITIAL.
1440
1441     LOOP AT ist_srcbsik.
1442       IF ist_srcbsik-shkzg = 'S'.
1443         ist_srcbsik-dmbtr = ist_srcbsik-dmbtr.
1444         ist_srcbsik-wrbtr = ist_srcbsik-wrbtr.
1445       ELSEIF ist_srcbsik-shkzg = 'H'.
1446         ist_srcbsik-dmbtr = - ist_srcbsik-dmbtr.
1447         ist_srcbsik-wrbtr = - ist_srcbsik-wrbtr.
1448       ENDIF.
1449       MODIFY ist_srcbsik .
1450     ENDLOOP.
1451
1452   ENDFORM.                    " get_rel_docs
1453   *-----------start of <RD1K960891>
1454   *&---------------------------------------------------------------------*
1455   *&      Form  get_rel_docs_cust
1456   *&---------------------------------------------------------------------*
1457   *       text
1458   *----------------------------------------------------------------------*
1459   *  -->  p1        text
1460   *  <--  p2        text
1461   *----------------------------------------------------------------------*
1462   FORM get_rel_docs_cust.
1463     SELECT bukrs kunnr umskz gjahr belnr buzei budat bschl
1464   *begin of <RD1K967585> CAB_ALOK 14.12.2009 CR30002778
1465   *   zlsch zlspr shkzg gsber dmbtr wrbtr APPENDING
1466       zlsch zlspr shkzg gsber dmbtr wrbtr rebzg APPENDING
1467   *end of <RD1K967585> CAB_ALOK 14.12.2009 CR30002778
1468       CORRESPONDING FIELDS OF TABLE
1469                      ist_srcbsid  FROM bsid
1470                      WHERE
1471                           bukrs  =  p_bukrs
1472                     AND kunnr  IN s_kunnr
1473                     AND gjahr IN s_year
1474                   AND belnr IN s_docno " RD1K982186 CR 30007748
1475                     AND gsber IN s_gsber
1476                     AND budat IN  s_budat.  "#EC CI_NOORDER
1477
1478
1479     IF p_x2a = 'X'.
1480       DELETE  ist_srcbsid WHERE zlspr <> g_zlspr_x.
1481     ELSEIF p_a2x = 'X'.
1482       DELETE  ist_srcbsid WHERE zlspr <> g_zlspr_a.
1483   *----+003
1484     ELSEIF p_r2x = 'X'.
1485       DELETE  ist_srcbsid WHERE zlspr <> g_zlspr_r.
1486
1487   * Begin of RD1K971966 CAB_ALOK CR30004183
1488     ELSEIF p_s2x = 'X'.
1489       DELETE  ist_srcbsid WHERE zlspr <> g_zlspr_s.
1490   * End of RD1K971966 CAB_ALOK CR30004183
1491
1492     ENDIF.
1493   *-----+003
1494
1495   *  Start of addition Prabu K on 03.07.2009
1496     DATA wa_bkpf TYPE bkpf.
1497     LOOP AT ist_srcbsid INTO wa_srcbsid.
1498
1499       SELECT SINGLE * FROM bkpf INTO wa_bkpf WHERE bukrs = wa_srcbsid-bukrs AND belnr = wa_srcbsid-belnr
1500          AND xref1_hd IN s_xref1.  "#EC CI_NOORDER
1501       IF sy-subrc NE 0.
1502         DELETE TABLE ist_srcbsid FROM wa_srcbsid.
1503       ELSE.
1504         wa_srcbsid-xref1_hd = wa_bkpf-xref1_hd.
1505         MODIFY ist_srcbsid FROM wa_srcbsid.
1506       ENDIF.
1507
1508     ENDLOOP.
1509   *  End  of addition Prabu K on 03.07.2009
1510     IF NOT s_usnam   IS INITIAL.
1511       IF NOT ist_srcbsid[] IS INITIAL.
1512         SELECT blart usnam ppnam belnr gjahr bldat budat waers bukrs
1513                           INTO CORRESPONDING FIELDS OF TABLE ist_bkpf
1514                            FROM  bkpf
1515                           FOR ALL ENTRIES IN ist_srcbsid
1516                    WHERE bukrs = ist_srcbsid-bukrs
1517                    AND  gjahr = ist_srcbsid-gjahr
1518                    AND  belnr = ist_srcbsid-belnr
1519                    AND  budat = ist_srcbsid-budat
1520                    AND ( usnam IN s_usnam  OR usnam EQ 'WF-BATCH' ).  "#EC CI_NOORDER
1521       ENDIF.
1522
1523       IF NOT ist_bkpf[] IS INITIAL.
1524
1525         LOOP AT ist_bkpf WHERE usnam = 'WF-BATCH' .
1526           MOVE-CORRESPONDING ist_bkpf TO y_doc_nos .
1527           MOVE ist_bkpf-usnam TO y_doc_nos-usrel .
1528           APPEND y_doc_nos .
1529         ENDLOOP.
1530
1531         CALL FUNCTION 'Z_FI_GET_REL_USERNAME'
1532           TABLES
1533             y_doc_nos = y_doc_nos
1534             f_doc_nos = f_doc_nos
1535           EXCEPTIONS
1536             not_found = 1
1537             OTHERS    = 2.
1538
1539         LOOP AT ist_bkpf .
1540           READ TABLE y_doc_nos WITH KEY bukrs = ist_bkpf-bukrs
1541                                         belnr = ist_bkpf-belnr
1542                                         gjahr = ist_bkpf-gjahr.
1543           IF sy-subrc EQ 0 .
1544             ist_bkpf-usnam = y_doc_nos-usrel .
1545             MODIFY ist_bkpf TRANSPORTING usnam .
1546           ENDIF .
1547         ENDLOOP.
1548
1549
1550         LOOP AT ist_srcbsid.
1551           READ TABLE ist_bkpf WITH KEY bukrs = ist_srcbsid-bukrs
1552                                    belnr = ist_srcbsid-belnr
1553                                    gjahr = ist_srcbsid-gjahr .
1554           IF sy-subrc = 0.
1555             ist_srcbsid-usnam = ist_bkpf-usnam.
1556             MODIFY ist_srcbsid  TRANSPORTING usnam .
1557           ENDIF.
1558         ENDLOOP.
1559
1560         IF NOT s_usnam[] IS  INITIAL.
1561           DELETE ist_srcbsid WHERE  NOT usnam  IN s_usnam.
1562         ENDIF.
1563
1564       ENDIF.
1565
1566     ENDIF.
1567
1568     ist_bsids[] = ist_srcbsid[].
1569
1570     REFRESH ist_srcbsid.
1571     CLEAR ist_srcbsid.
1572
1573     LOOP AT ist_bsids .
1574   *{001
1575   *    IF ist_bsids-umskz = 'K' OR ist_bsids-umskz = 'H'.
1576       IF ( ist_bsids-umskz = 'K' OR ist_bsids-umskz = 'H' OR ist_bsids-umskz = 'O' ) OR
1577   *Start of changes by SOGET - 003
1578   *( ist_bsids-umskz = ' ' and ist_bsids-zlsch = 'P' ).
1579          ( ist_bsids-umskz = ' ' AND ist_bsids-zlsch = 'P' ) OR ( ist_bsids-umskz = ' ' AND ist_bsids-zlsch = 'Q' ).
1580   *End of changes by SOGET - 003
1581   *}001
1582         ist_srcbsid = ist_bsids.
1583         APPEND ist_srcbsid.
1584         CLEAR ist_srcbsid.
1585       ENDIF.
1586
1587     ENDLOOP.
1588
1589     SORT ist_srcbsid BY kunnr bschl belnr budat .
1590
1591     DELETE ADJACENT DUPLICATES  FROM ist_srcbsid.
1592
1593     CHECK  NOT ist_srcbsid[] IS INITIAL.
1594
1595     LOOP AT ist_srcbsid.
1596       IF ist_srcbsid-shkzg = 'S'.
1597         ist_srcbsid-dmbtr = ist_srcbsid-dmbtr.
1598         ist_srcbsid-wrbtr = ist_srcbsid-wrbtr.
1599       ELSEIF ist_srcbsid-shkzg = 'H'.
1600         ist_srcbsid-dmbtr = - ist_srcbsid-dmbtr.
1601         ist_srcbsid-wrbtr = - ist_srcbsid-wrbtr.
1602       ENDIF.
1603       MODIFY ist_srcbsid .
1604     ENDLOOP.
1605   ENDFORM.                    " get_rel_docs_cust
1606   *&---------------------------------------------------------------------*
1607   *&      Form  display_docs_cust
1608   *&---------------------------------------------------------------------*
1609   *       text
1610   *----------------------------------------------------------------------*
1611   *  -->  p1        text
1612   *  <--  p2        text
1613   *----------------------------------------------------------------------*
1614   FORM display_docs_cust.
1615     PERFORM init_fieldcat_cust.
1616     PERFORM eventtab_build_cust TABLES gt_events.
1617     PERFORM  sort_build_cust .
1618     PERFORM  print_alv_cust.
1619
1620   ENDFORM.                    " display_docs_cust
1621   *&---------------------------------------------------------------------*
1622   *&      Form  init_fieldcat_cust
1623   *&---------------------------------------------------------------------*
1624   *       text
1625   *----------------------------------------------------------------------*
1626   *  -->  p1        text
1627   *  <--  p2        text
1628   *----------------------------------------------------------------------*
1629   FORM init_fieldcat_cust.
1630     w_repid  = sy-repid.
1631
1632     mpos = 0.
1633     mpos = mpos + 1.
1634     ist_fieldcat-fieldname = 'SELCBOX'.
1635     ist_fieldcat-tabname = 'IST_SRCBSID'.
1636     ist_fieldcat-ddictxt = 'M'.
1637     ist_fieldcat-col_pos =  mpos.
1638     ist_fieldcat-seltext_m  = 'Select'.
1639     ist_fieldcat-lowercase  = 'Y'.
1640     ist_fieldcat-checkbox = 'X'.
1641     ist_fieldcat-input = 'X'.
1642     APPEND ist_fieldcat TO ist_fcat.
1643     CLEAR ist_fieldcat.
1644
1645     mpos = mpos + 1.
1646     ist_fieldcat-fieldname = 'KUNNR'.
1647     ist_fieldcat-tabname = 'IST_SRCBSID'.
1648     ist_fieldcat-ddictxt = 'M'.
1649     ist_fieldcat-col_pos =  mpos.
1650     ist_fieldcat-seltext_m  = 'CustomerNumber '.
1651     ist_fieldcat-lowercase  = 'Y'.
1652     APPEND ist_fieldcat TO ist_fcat.
1653     CLEAR ist_fieldcat.
1654
1655     mpos = mpos + 1.
1656     ist_fieldcat-fieldname = 'BELNR'.
1657     ist_fieldcat-tabname = 'IST_SRCBSID'.
1658     ist_fieldcat-ddictxt = 'M'.
1659     ist_fieldcat-col_pos =  mpos.
1660     ist_fieldcat-seltext_m  = 'Doc.No.'.
1661     ist_fieldcat-lowercase  = 'Y'.
1662     APPEND ist_fieldcat TO ist_fcat.
1663     CLEAR ist_fieldcat.
1664
1665
1666     mpos = mpos + 1.
1667     ist_fieldcat-fieldname = 'BUZEI'.
1668     ist_fieldcat-tabname = 'IST_SRCBSID'.
1669     ist_fieldcat-ddictxt = 'M'.
1670     ist_fieldcat-col_pos =  mpos.
1671     ist_fieldcat-seltext_m  = 'Item.no.'.
1672     ist_fieldcat-lowercase  = 'Y'.
1673     APPEND ist_fieldcat TO ist_fcat.
1674     CLEAR ist_fieldcat.
1675
1676     mpos = mpos + 1.
1677     ist_fieldcat-fieldname = 'GSBER'.
1678     ist_fieldcat-tabname = 'IST_SRCBSID'.
1679     ist_fieldcat-ddictxt = 'M'.
1680     ist_fieldcat-col_pos =  mpos.
1681     ist_fieldcat-seltext_m  = 'Business Area'.
1682     ist_fieldcat-lowercase  = 'Y'.
1683     APPEND ist_fieldcat TO ist_fcat.
1684     CLEAR ist_fieldcat.
1685
1686   *begin of <RD1K967585> CAB_ALOK 15.12.2009 CR30002778
1687     mpos = mpos + 1.
1688     ist_fieldcat-fieldname = 'REBZG'.
1689     ist_fieldcat-tabname = 'IST_SRCBSID'.
1690     ist_fieldcat-ddictxt = 'M'.
1691     ist_fieldcat-col_pos =  mpos.
1692     ist_fieldcat-seltext_m  = 'Invoice Reference'.
1693   *  ist_fieldcat-lowercase  = 'Y'.
1694     APPEND ist_fieldcat TO ist_fcat.
1695     CLEAR ist_fieldcat.
1696   *end of <RD1K967585> CAB_ALOK 15.12.2009 CR30002778
1697
1698     mpos = mpos + 1.
1699     ist_fieldcat-fieldname = 'BSCHL'.
1700     ist_fieldcat-tabname = 'IST_SRCBSID'.
1701     ist_fieldcat-ddictxt = 'M'.
1702     ist_fieldcat-col_pos =  mpos.
1703     ist_fieldcat-seltext_m  = 'Posting Key.'.
1704     ist_fieldcat-lowercase  = 'Y'.
1705     APPEND ist_fieldcat TO ist_fcat.
1706     CLEAR ist_fieldcat.
1707
1708     mpos = mpos + 1.
1709     ist_fieldcat-fieldname = 'BUDAT'.
1710     ist_fieldcat-tabname = 'IST_SRCBSID'.
1711     ist_fieldcat-ddictxt = 'M'.
1712     ist_fieldcat-col_pos =  mpos.
1713     ist_fieldcat-seltext_m  = 'Posting Date'.
1714     ist_fieldcat-lowercase  = 'Y'.
1715     APPEND ist_fieldcat TO ist_fcat.
1716     CLEAR ist_fieldcat.
1717
1718
1719     mpos = mpos + 1.
1720     ist_fieldcat-fieldname = 'DMBTR'.
1721     ist_fieldcat-tabname = 'IST_SRCBSID'.
1722     ist_fieldcat-ddictxt = 'M'.
1723     ist_fieldcat-col_pos =  mpos.
1724     ist_fieldcat-seltext_m  = 'AmtInLclCurncy'.
1725     ist_fieldcat-lowercase  = 'Y'.
1726     APPEND ist_fieldcat TO ist_fcat.
1727     CLEAR ist_fieldcat.
1728
1729     mpos = mpos + 1.
1730     ist_fieldcat-fieldname = 'WRBTR'.
1731     ist_fieldcat-tabname = 'IST_SRCBSID'.
1732     ist_fieldcat-ddictxt = 'M'.
1733     ist_fieldcat-col_pos =  mpos.
1734     ist_fieldcat-seltext_m  = 'AmtInDocCurncy'.
1735     ist_fieldcat-lowercase  = 'Y'.
1736     APPEND ist_fieldcat TO ist_fcat.
1737     CLEAR ist_fieldcat.
1738
1739     mpos = mpos + 1.
1740     ist_fieldcat-fieldname = 'ZLSCH'.
1741     ist_fieldcat-tabname = 'IST_SRCBSID'.
1742     ist_fieldcat-ddictxt = 'M'.
1743     ist_fieldcat-col_pos =  mpos.
1744     ist_fieldcat-seltext_m  = 'PaymntMethod'.
1745     ist_fieldcat-lowercase  = 'Y'.
1746     APPEND ist_fieldcat TO ist_fcat.
1747     CLEAR ist_fieldcat.
1748
1749     mpos = mpos + 1.
1750     ist_fieldcat-fieldname = 'ZLSPR'.
1751     ist_fieldcat-tabname = 'IST_SRCBSID'.
1752     ist_fieldcat-ddictxt = 'M'.
1753     ist_fieldcat-col_pos =  mpos.
1754     ist_fieldcat-seltext_m  = 'PaymntBlock'.
1755     ist_fieldcat-lowercase  = 'Y'.
1756     APPEND ist_fieldcat TO ist_fcat.
1757     CLEAR ist_fieldcat.
1758
1759   *Start of addition Prabu K on 06.07.2009
1760     mpos = mpos + 1.
1761     ist_fieldcat-fieldname = 'XREF1_HD'.
1762     ist_fieldcat-tabname = 'IST_SRCBSID'.
1763     ist_fieldcat-ddictxt = 'M'.
1764     ist_fieldcat-col_pos =  mpos.
1765     ist_fieldcat-seltext_m  = 'Location'.
1766     ist_fieldcat-lowercase  = 'Y'.
1767     APPEND ist_fieldcat TO ist_fcat.
1768     CLEAR ist_fieldcat.
1769   * End  of addition Prabu K on 06.07.2009
1770
1771     IF NOT s_usnam[] IS INITIAL.
1772       mpos = mpos + 1.
1773       ist_fieldcat-fieldname = 'USNAM'.
1774       ist_fieldcat-tabname = 'IST_SRCBSID'.
1775       ist_fieldcat-ddictxt = 'M'.
1776       ist_fieldcat-col_pos =  mpos.
1777       ist_fieldcat-seltext_m  = 'Created By'.
1778       ist_fieldcat-lowercase  = 'Y'.
1779       APPEND ist_fieldcat TO ist_fcat.
1780       CLEAR ist_fieldcat.
1781     ENDIF.
1782
1783   ENDFORM.                    " init_fieldcat_cust
1784   *&---------------------------------------------------------------------*
1785   *&      Form  eventtab_build_cust
1786   *&---------------------------------------------------------------------*
1787   *       text
1788   *----------------------------------------------------------------------*
1789   *      -->P_GT_EVENTS[]  text
1790   *----------------------------------------------------------------------*
1791   FORM eventtab_build_cust TABLES  p_gt_events.
1792     DATA : ls_event TYPE slis_alv_event.
1793     CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
1794       EXPORTING
1795         i_list_type = 0
1796       IMPORTING
1797         et_events   = gt_events.
1798     READ TABLE gt_events WITH KEY name =  slis_ev_user_command
1799                               INTO ls_event.
1800     IF sy-subrc = 0.
1801       MOVE 'MAKEC_COMMAND' TO ls_event-form.
1802       APPEND ls_event TO gt_events.
1803     ENDIF.
1804     CLEAR ls_event.
1805
1806
1807   ENDFORM.                    " eventtab_build_cust
1808   *&---------------------------------------------------------------------*
1809   *&      Form  sort_build_cust
1810   *&---------------------------------------------------------------------*
1811   *       text
1812   *----------------------------------------------------------------------*
1813   *  -->  p1        text
1814   *  <--  p2        text
1815   *----------------------------------------------------------------------*
1816   FORM sort_build_cust.
1817     w_repid = sy-repid.
1818     is_layout-key_hotspot = 'X'.
1819     is_layout-colwidth_optimize = 'X'.
1820     ls_sorttab-fieldname = 'KUNNR'.
1821     ls_sorttab-up = 'X'.
1822     APPEND ls_sorttab TO lt_sorttab.
1823     ls_sorttab-fieldname = 'BSCHL'.
1824     ls_sorttab-up = 'X'.
1825     APPEND ls_sorttab TO lt_sorttab.
1826     ls_sorttab-fieldname = 'BELNR'.
1827     ls_sorttab-up = 'X'.
1828     APPEND ls_sorttab TO lt_sorttab.
1829     ls_sorttab-fieldname = 'BUDAT'.
1830     ls_sorttab-up = 'X'.
1831     APPEND ls_sorttab TO lt_sorttab.
1832
1833   ENDFORM.                    " sort_build_cust
1834   *&---------------------------------------------------------------------*
1835   *&      Form  print_alv_cust
1836   *&---------------------------------------------------------------------*
1837   *       text
1838   *----------------------------------------------------------------------*
1839   *  -->  p1        text
1840   *  <--  p2        text
1841   *----------------------------------------------------------------------*
1842   FORM print_alv_cust.
1843     CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
1844       EXPORTING
1845         i_callback_program       = w_repid
1846         i_callback_pf_status_set = 'ALV_PFSTS'
1847         i_callback_user_command  = 'MAKEC_COMMAND'
1848         is_layout                = is_layout
1849         it_fieldcat              = ist_fcat[]
1850         it_sort                  = lt_sorttab
1851         it_events                = gt_events
1852         i_save                   = 'A'
1853       TABLES
1854         t_outtab                 = ist_srcbsid
1855   * Begin of Changes on 20-Jun-2013
1856       EXCEPTIONS
1857         program_error = 1
1858         OTHERS        = 2.
1859   * End of Changes on 20-Jun-2013
1860     IF sy-subrc <> 0.
1861   *    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
1862   *            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
1863     ENDIF.
1864
1865
1866   ENDFORM.                    " print_alv_cust
1867   *---------------------------------------------------------------------*
1868   *       FORM alv_pfst                                                 *
1869   *---------------------------------------------------------------------*
1870   *       ........                                                      *
1871   *---------------------------------------------------------------------*
1872   *  -->  RT_EXTAB                                                      *
1873   *---------------------------------------------------------------------*
1874   FORM alv_pfsts USING rt_extab TYPE slis_t_extab.
1875     SET PF-STATUS 'S100'.
1876   ENDFORM.                    "alv_pfsts
1877
1878   *---------------------------------------------------------------------*
1879   *       FORM make_command                                             *
1880   *---------------------------------------------------------------------*
1881   *       ........                                                      *
1882   *---------------------------------------------------------------------*
1883   *  -->  R_UCOMM                                                       *
1884   *  -->  RS_SELFIELD                                                   *
1885   *---------------------------------------------------------------------*
1886   FORM makec_command USING r_ucomm LIKE sy-ucomm
1887                           rs_selfield TYPE slis_selfield.
1888   *-----------------------------------------------------*
1889   *-----------------------------------------------------*
1890     DATA : index_aux LIKE sy-tabix.
1891     index_aux = rs_selfield-tabindex.
1892     CASE r_ucomm.
1893
1894       WHEN 'REL'.
1895         DELETE ist_srcbsid WHERE  selcbox <> 'X'.
1896         PERFORM   get_upd_bsid.
1897         PERFORM   get_upd_bsegc.
1898   *Begin of <RD1K967585> CAB_ALOK 15.12.2009 CR30002778
1899         PERFORM   update_zfi_rem_pyblck_l.    "update logs
1900   *end of <RD1K967585> CAB_ALOK 15.12.2009 CR30002778
1901         LEAVE SCREEN.
1902       WHEN 'ALL'.
1903         PERFORM  select_allc.
1904       WHEN 'SAL'.
1905         PERFORM  deselect_allc.
1906       WHEN '&F03' OR 'BACK' .
1907         LEAVE  PROGRAM.
1908
1909     ENDCASE.
1910
1911   ENDFORM.                    "makec_command
1912   *---------------------------------------------------------------------*
1913   *&      Form  select_all
1914   *&---------------------------------------------------------------------*
1915   *       text
1916   *----------------------------------------------------------------------*
1917   *  -->  p1        text
1918   *  <--  p2        text
1919   *----------------------------------------------------------------------*
1920   FORM select_allc.
1921     LOOP AT ist_srcbsid.
1922       ist_srcbsid-selcbox = 'X'.
1923       MODIFY ist_srcbsid.
1924     ENDLOOP.
1925
1926   ENDFORM.                    " select_all
1927   *&---------------------------------------------------------------------*
1928   *&      Form  deselect_all
1929   *&---------------------------------------------------------------------*
1930   *       text
1931   *----------------------------------------------------------------------*
1932   *  -->  p1        text
1933   *  <--  p2        text
1934   *----------------------------------------------------------------------*
1935   FORM deselect_allc.
1936     LOOP AT ist_srcbsid.
1937       ist_srcbsid-selcbox = ' '.
1938       MODIFY ist_srcbsid.
1939     ENDLOOP.
1940   ENDFORM.                    " deselect_all
1941   *&---------------------------------------------------------------------
1942   *&---------------------------------------------------------------------*
1943   *&      Form  get_upd_bsid
1944   *&---------------------------------------------------------------------*
1945   *       text
1946   *----------------------------------------------------------------------*
1947   *  -->  p1        text
1948   *  <--  p2        text
1949   *----------------------------------------------------------------------*
1950   FORM get_upd_bsid.
1951
1952     DATA : l_tabix  TYPE sy-tabix.
1953
1954     CHECK NOT ist_srcbsid[] IS INITIAL.
1955
1956     SELECT * INTO TABLE ist_bsid   FROM bsid
1957       FOR ALL ENTRIES  IN  ist_srcbsid
1958       WHERE   kunnr = ist_srcbsid-kunnr
1959             AND  bukrs  =  p_bukrs
1960              AND gjahr = ist_srcbsid-gjahr
1961              AND belnr = ist_srcbsid-belnr
1962              AND buzei = ist_srcbsid-buzei.
1963
1964     IF NOT ist_bsid IS INITIAL.
1965       IF p_x2a = 'X'.
1966         LOOP AT ist_bsid INTO wa_bsid.
1967           l_tabix =   sy-tabix .
1968           IF wa_bsid-zlspr =  g_zlspr_x.
1969             wa_bsid-zlspr =  g_zlspr_a.
1970             MODIFY ist_bsid  FROM  wa_bsid INDEX l_tabix  TRANSPORTING zlspr.
1971           ENDIF.
1972         ENDLOOP.
1973   "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
1974   *      MODIFY  bsid FROM TABLE ist_bsid.
1975   *      COMMIT WORK.
1976   "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
1977       ENDIF.
1978       IF p_a2x = 'X'.
1979         LOOP AT ist_bsid INTO wa_bsid.
1980           l_tabix =   sy-tabix .
1981           IF wa_bsid-zlspr =  g_zlspr_a.
1982             wa_bsid-zlspr =  g_zlspr_x.
1983             MODIFY ist_bsid  FROM  wa_bsid INDEX l_tabix  TRANSPORTING zlspr.
1984           ENDIF.
1985         ENDLOOP.
1986   "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
1987   *      MODIFY  bsid FROM TABLE ist_bsid.
1988   *      COMMIT WORK.
1989   "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
1990       ENDIF.
1991
1992   *--+003
1993       IF p_r2x = 'X'.
1994         LOOP AT ist_bsid INTO wa_bsid.
1995           l_tabix =   sy-tabix .
1996           IF wa_bsid-zlspr =  g_zlspr_r.
1997             wa_bsid-zlspr =  g_zlspr_x.
1998             MODIFY ist_bsid  FROM  wa_bsid INDEX l_tabix  TRANSPORTING zlspr.
1999           ENDIF.
2000         ENDLOOP.
2001   "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
2002   *      MODIFY  bsid FROM TABLE ist_bsid.
2003   *      COMMIT WORK.
2004   "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
2005       ENDIF.
2006   *---+003
2007
2008   * Begin of RD1K971966 CAB_ALOK CR30004183
2009       IF p_s2x = 'X'.
2010         LOOP AT ist_bsid INTO wa_bsid.
2011           l_tabix =   sy-tabix .
2012           IF wa_bsid-zlspr =  g_zlspr_s.
2013             wa_bsid-zlspr =  g_zlspr_x.
2014             MODIFY ist_bsid  FROM  wa_bsid INDEX l_tabix  TRANSPORTING zlspr.
2015           ENDIF.
2016         ENDLOOP.
2017   "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
2018   *      MODIFY  bsid FROM TABLE ist_bsid.
2019   *
2020   *      COMMIT WORK.
2021   "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
2022       ENDIF.
2023   * End of RD1K971966 CAB_ALOK CR30004183
2024
2025     ENDIF.
2026   ENDFORM.                    " get_upd_bsid
2027   *
2028   *&---------------------------------------------------------------------*
2029   *&      Form  get_upd_bseg
2030   *&---------------------------------------------------------------------*
2031   *       text
2032   *----------------------------------------------------------------------*
2033   *  -->  p1        text
2034   *  <--  p2        text
2035   *----------------------------------------------------------------------*
2036   FORM get_upd_bsegc.
2037     DATA : l_tabix  TYPE sy-tabix.
2038
2039     CHECK NOT ist_srcbsid[] IS INITIAL.
2040
2041     SELECT * INTO TABLE ist_bseg   FROM bseg
2042       FOR ALL ENTRIES  IN  ist_srcbsid
2043       WHERE
2044              bukrs  =  p_bukrs
2045        AND   belnr = ist_srcbsid-belnr
2046        AND   gjahr =  ist_srcbsid-gjahr
2047        AND   buzei = ist_srcbsid-buzei ORDER BY PRIMARY KEY.
2048
2049     CLEAR l_tabix.
2050     IF NOT ist_bseg IS INITIAL.
2051       IF p_x2a = 'X'.
2052         LOOP AT ist_bseg INTO wa_bseg.
2053           l_tabix =   sy-tabix .
2054           IF wa_bseg-zlspr =  g_zlspr_x.
2055             wa_bseg-zlspr =  g_zlspr_a.
2056             MODIFY ist_bseg  FROM  wa_bseg INDEX l_tabix  TRANSPORTING zlspr.
2057           ENDIF.
2058         ENDLOOP.
2059
2060   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
2061   * S/4: BSEG payment block (ZLSPR) changed via FI_DOCUMENT_CHANGE (FB02 logic); direct write not allowed.
2062   *      MODIFY bseg FROM TABLE ist_bseg.
2063         LOOP AT ist_bseg INTO wa_bseg.
2064           PERFORM zz_s4_bseg_zlspr USING wa_bseg-bukrs wa_bseg-belnr wa_bseg-gjahr wa_bseg-buzei wa_bseg-zlspr.
2065         ENDLOOP.
2066         COMMIT WORK.
2067   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
2068
2069       ENDIF.
2070       CLEAR l_tabix.
2071       IF p_a2x = 'X'.
2072         LOOP AT ist_bseg INTO wa_bseg.
2073           l_tabix =   sy-tabix .
2074           IF wa_bseg-zlspr =  g_zlspr_a.
2075             wa_bseg-zlspr =  g_zlspr_x.
2076             MODIFY ist_bseg  FROM  wa_bseg INDEX l_tabix  TRANSPORTING zlspr.
2077           ENDIF.
2078         ENDLOOP.
2079
2080   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
2081   * S/4: BSEG payment block (ZLSPR) changed via FI_DOCUMENT_CHANGE (FB02 logic); direct write not allowed.
2082   *      MODIFY bseg FROM TABLE ist_bseg.
2083         LOOP AT ist_bseg INTO wa_bseg.
2084           PERFORM zz_s4_bseg_zlspr USING wa_bseg-bukrs wa_bseg-belnr wa_bseg-gjahr wa_bseg-buzei wa_bseg-zlspr.
2085         ENDLOOP.
2086         COMMIT WORK.
2087   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
2088
2089       ENDIF.
2090   *----+003
2091       IF p_r2x = 'X'.
2092         LOOP AT ist_bseg INTO wa_bseg.
2093           l_tabix =   sy-tabix .
2094           IF wa_bseg-zlspr =  g_zlspr_r.
2095             wa_bseg-zlspr =  g_zlspr_x.
2096             MODIFY ist_bseg  FROM  wa_bseg INDEX l_tabix  TRANSPORTING zlspr.
2097           ENDIF.
2098         ENDLOOP.
2099
2100   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
2101   * S/4: BSEG payment block (ZLSPR) changed via FI_DOCUMENT_CHANGE (FB02 logic); direct write not allowed.
2102   *      MODIFY bseg FROM TABLE ist_bseg.
2103         LOOP AT ist_bseg INTO wa_bseg.
2104           PERFORM zz_s4_bseg_zlspr USING wa_bseg-bukrs wa_bseg-belnr wa_bseg-gjahr wa_bseg-buzei wa_bseg-zlspr.
2105         ENDLOOP.
2106         COMMIT WORK.
2107   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
2108
2109       ENDIF.
2110   *-------+003
2111
2112   * Begin of RD1K971966 CAB_ALOK CR30004183
2113       IF p_s2x = 'X'.
2114         LOOP AT ist_bseg INTO wa_bseg.
2115           l_tabix =   sy-tabix .
2116           IF wa_bseg-zlspr =  g_zlspr_s.
2117             wa_bseg-zlspr =  g_zlspr_x.
2118             MODIFY ist_bseg  FROM  wa_bseg INDEX l_tabix  TRANSPORTING zlspr.
2119           ENDIF.
2120         ENDLOOP.
2121
2122   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
2123   * S/4: BSEG payment block (ZLSPR) changed via FI_DOCUMENT_CHANGE (FB02 logic); direct write not allowed.
2124   *      MODIFY  bseg FROM TABLE ist_bseg.
2125         LOOP AT ist_bseg INTO wa_bseg.
2126           PERFORM zz_s4_bseg_zlspr USING wa_bseg-bukrs wa_bseg-belnr wa_bseg-gjahr wa_bseg-buzei wa_bseg-zlspr.
2127         ENDLOOP.
2128         COMMIT WORK.
2129   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
2130
2131         COMMIT WORK.
2132       ENDIF.
2133   * End of RD1K971966 CAB_ALOK CR30004183
2134
2135     ENDIF.
2136   ENDFORM.                    " get_upd_bsegc
2137   *-----------End of <RD1K960891>
2138
2139   *&---------------------------------------------------------------------*
2140   *&      Form  UPDATE_ZFI_REM_PYBLCK_L
2141   *&---------------------------------------------------------------------*
2142   *       text
2143   *----------------------------------------------------------------------*
2144   *  -->  p1        text
2145   *  <--  p2        text
2146   *----------------------------------------------------------------------*
2147   *begin of <RD1K967585> CAB_ALOK 14.12.2009 CR30002778
2148   * update Logs to table ZFI_REM_PYBLCK_L
2149
2150   FORM update_zfi_rem_pyblck_l .
2151     DATA: ist_zfi_rem_pyblck_l TYPE TABLE OF zfi_rem_pyblck_l,
2152           wa_zfi_rem_pyblck_l TYPE zfi_rem_pyblck_l.
2153     DATA: count TYPE zfi_rem_pyblck_l-srno.
2154
2155     IF p_x2a = 'X'.
2156       pmtblock_to = 'A'.
2157     ELSEIF p_a2x  = 'X'.
2158       pmtblock_to = 'X'.
2159     ELSEIF p_r2x = 'X'.
2160       pmtblock_to = 'X'.
2161   * Begin of RD1K971966 CAB_ALOK CR30004183
2162     ELSEIF p_s2x = 'X'.
2163       pmtblock_to = 'X'.
2164   * End of RD1K971966 CAB_ALOK CR30004183
2165     ENDIF.
2166
2167     SELECT MAX( srno ) FROM zfi_rem_pyblck_l INTO count.
2168     IF NOT ist_srcbsik IS INITIAL.
2169
2170       LOOP AT ist_srcbsik INTO wa_srcbsik.
2171         count = count + 1.
2172
2173         wa_zfi_rem_pyblck_l-srno = count.
2174         wa_zfi_rem_pyblck_l-bukrs = wa_srcbsik-bukrs.
2175         wa_zfi_rem_pyblck_l-lifnr = wa_srcbsik-lifnr.
2176   *wa_ZFI_REM_PYBLCK_L-KUNNR = wa_srcbsik-KUNNR.
2177         wa_zfi_rem_pyblck_l-belnr = wa_srcbsik-belnr.
2178   *   wa_ZFI_REM_PYBLCK_L-KIDNO = wa_srcbsik-KIDNO.
2179         wa_zfi_rem_pyblck_l-rebzg = wa_srcbsik-rebzg.
2180         wa_zfi_rem_pyblck_l-shkzg = wa_srcbsik-shkzg.
2181         wa_zfi_rem_pyblck_l-gjahr = wa_srcbsik-gjahr.
2182         wa_zfi_rem_pyblck_l-buzei = wa_srcbsik-buzei.
2183         wa_zfi_rem_pyblck_l-bschl = wa_srcbsik-bschl.
2184         wa_zfi_rem_pyblck_l-budat = wa_srcbsik-budat.
2185         wa_zfi_rem_pyblck_l-dmbtr = wa_srcbsik-dmbtr .
2186         wa_zfi_rem_pyblck_l-wrbtr = wa_srcbsik-wrbtr .
2187         wa_zfi_rem_pyblck_l-zlsch = wa_srcbsik-zlsch.
2188         wa_zfi_rem_pyblck_l-pmtblock_from = wa_srcbsik-zlspr.
2189         wa_zfi_rem_pyblck_l-pmtblock_to = pmtblock_to.
2190         wa_zfi_rem_pyblck_l-location = wa_srcbsik-xref1_hd.
2191         wa_zfi_rem_pyblck_l-uname = sy-uname.
2192         wa_zfi_rem_pyblck_l-usdate = sy-datum.
2193         wa_zfi_rem_pyblck_l-ustime = sy-uzeit.
2194
2195         INSERT zfi_rem_pyblck_l FROM wa_zfi_rem_pyblck_l.
2196       ENDLOOP.
2197
2198       COMMIT WORK.
2199       REFRESH ist_srcbsik.
2200     ENDIF.
2201
2202     IF NOT ist_srcbsid IS INITIAL.
2203
2204       LOOP AT ist_srcbsid INTO wa_srcbsid.
2205         count = count + 1.
2206
2207         wa_zfi_rem_pyblck_l-srno = count.
2208         wa_zfi_rem_pyblck_l-bukrs = wa_srcbsid-bukrs.
2209   *   wa_ZFI_REM_PYBLCK_L-LIFNR = wa_srcbsid-LIFNR.
2210         wa_zfi_rem_pyblck_l-kunnr = wa_srcbsid-kunnr.
2211         wa_zfi_rem_pyblck_l-belnr = wa_srcbsid-belnr.
2212   *   wa_ZFI_REM_PYBLCK_L-KIDNO = wa_srcbsid-KIDNO.
2213         wa_zfi_rem_pyblck_l-rebzg = wa_srcbsid-rebzg.
2214         wa_zfi_rem_pyblck_l-shkzg = wa_srcbsid-shkzg.
2215         wa_zfi_rem_pyblck_l-gjahr = wa_srcbsid-gjahr.
2216         wa_zfi_rem_pyblck_l-buzei = wa_srcbsid-buzei.
2217         wa_zfi_rem_pyblck_l-bschl = wa_srcbsid-bschl.
2218         wa_zfi_rem_pyblck_l-budat = wa_srcbsid-budat.
2219         wa_zfi_rem_pyblck_l-dmbtr = wa_srcbsid-dmbtr .
2220         wa_zfi_rem_pyblck_l-wrbtr = wa_srcbsid-wrbtr .
2221         wa_zfi_rem_pyblck_l-zlsch = wa_srcbsid-zlsch.
2222         wa_zfi_rem_pyblck_l-pmtblock_from = wa_srcbsid-zlspr.
2223         wa_zfi_rem_pyblck_l-pmtblock_to = pmtblock_to.
2224         wa_zfi_rem_pyblck_l-location = wa_srcbsid-xref1_hd.
2225         wa_zfi_rem_pyblck_l-uname = sy-uname.
2226         wa_zfi_rem_pyblck_l-usdate = sy-datum.
2227         wa_zfi_rem_pyblck_l-ustime = sy-uzeit.
2228
2229         INSERT zfi_rem_pyblck_l FROM wa_zfi_rem_pyblck_l.
2230       ENDLOOP.
2231       COMMIT WORK.
2232       REFRESH ist_srcbsid.
2233     ENDIF.
2234   ENDFORM.                    " UPDATE_ZFI_REM_PYBLCK_L
2235   *end of <RD1K967585> CAB_ALOK 14.12.2009 CR30002778
2236   *&---------------------------------------------------------------------*
2237   *&      Form  AUTHORITY_CHECK
2238   *&---------------------------------------------------------------------*
2239   *       text
2240   *----------------------------------------------------------------------*
2241   *      -->P_1057   text
2242   *      -->P_1058   text
2243   *----------------------------------------------------------------------*
2244   FORM authority_check USING p_object p_ktokk.
2245     AUTHORITY-CHECK OBJECT p_object
2246            ID 'KTOKK' FIELD p_ktokk.
2247     IF sy-subrc NE 0.
2248       MESSAGE e018(s#).
2249     ENDIF.
2250
2251   ENDFORM.            " AUTHORITY_CHECK
2252   *&---------------------------------------------------------------------*
2253   *&      Form  VALIDATE_VENDOR
2254   *&---------------------------------------------------------------------*
2255   *       text
2256   *----------------------------------------------------------------------*
2257   *  -->  p1        text
2258   *  <--  p2        text
2259   *----------------------------------------------------------------------*
2260   FORM VALIDATE_VENDOR .
2261
2262   *Begin RD1K999618 CAB_ALOK Change in ZFIBLOCKA for APP Block Vendor-CR 30013820
2263
2264     data: WA_LFB1 TYPE LFB1.
2265
2266   *  SELECT single * from LFB1
2267   *    into WA_LFB1
2268   *      WHERE LIFNR IN S_LIFNR
2269   *            AND BUKRS = P_BUKRS
2270   *            AND ZAHLS = 'X'.
2271   *
2272   *  IF WA_LFB1 IS NOT INITIAL.
2273   *   MESSAGE E552(ZFI) with WA_LFB1-LIFNR.
2274   *
2275   *  ENDIF.
2276
2277   BREAK CAB_ALOK.
2278
2279     data: IST_LFB1 TYPE TABLE OF LFB1.
2280     data: WA_TAB TYPE TY_TAB  .
2281
2282     clear  WA_LFB1.
2283
2284     SELECT * from LFB1
2285       into CORRESPONDING FIELDS OF TABLE IST_LFB1
2286         WHERE LIFNR IN S_LIFNR
2287               AND BUKRS = P_BUKRS
2288               AND ZAHLS = 'X'.
2289
2290   if IST_LFB1[] is NOT INITIAL.
2291
2292   REFRESH  IST_TAB.
2293    LOOP at IST_LFB1 INTO WA_LFB1.
2294      WA_TAB-LIFNR =  WA_LFB1-LIFNR.
2295      APPEND WA_TAB to  IST_TAB.
2296
2297    ENDLOOP.
2298
2299   CALL FUNCTION 'POPUP_WITH_TABLE_DISPLAY'
2300     EXPORTING
2301       ENDPOS_COL         = 0
2302       ENDPOS_ROW         = 0
2303       STARTPOS_COL       = 0
2304       STARTPOS_ROW       = 0
2305       TITLETEXT          = 'Following Vendors are Blocked for APP'
2306   * IMPORTING
2307   *   CHOISE             =
2308     TABLES
2309       VALUETAB           = IST_TAB
2310    EXCEPTIONS
2311      BREAK_OFF          = 1
2312      OTHERS             = 2
2313             .
2314   *IF SY-SUBRC <> 0.
2315   ** Implement suitable error handling here
2316   *ENDIF.
2317
2318   ENDIF.
2319
2320
2321   *End RD1K999618 CAB_ALOK  Change in ZFIBLOCKA for APP Block Vendor-CR 30013820
2322
2323
2324
2325
2326   ENDFORM.                    " VALIDATE_VENDOR
2327
2328   *-- S/4 helper FORM: change BSEG payment block via FI_DOCUMENT_CHANGE - SAP_ABAP 16.06.2026 --
2329   FORM zz_s4_bseg_zlspr USING p_bukrs p_belnr p_gjahr p_buzei p_zlspr.
2330     DATA: lt_acchg TYPE STANDARD TABLE OF accchg, ls_acchg TYPE accchg.
2331     REFRESH lt_acchg. CLEAR ls_acchg.
2332     ls_acchg-fdname = 'ZLSPR'. ls_acchg-newval = p_zlspr.
2333     APPEND ls_acchg TO lt_acchg.
2334     CALL FUNCTION 'FI_DOCUMENT_CHANGE'
2335       EXPORTING i_bukrs = p_bukrs i_belnr = p_belnr i_gjahr = p_gjahr i_buzei = p_buzei
2336       TABLES    t_acchg = lt_acchg
2337       EXCEPTIONS OTHERS = 0.
2338   ENDFORM.
*--- End of ZFI_CHNG_PYBLCK - 2338 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CSLIS                                   Level 1    Page 2
Object           ZFI_CHNG_PYBLCK                           Lines 543
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:58
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
Object           ZFI_CHNG_PYBLCK                           Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:58
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
Object           ZFI_CHNG_PYBLCK                           Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:58
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
Object           ZFI_CHNG_PYBLCK                           Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:58
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
Object           ZFI_CHNG_PYBLCK                           Lines 1
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:58
----------------------------------------------------------------------------------------------------
1      * INCLUDE DB__SSEL
*--- End of DB__SSEL - 1 lines ---
