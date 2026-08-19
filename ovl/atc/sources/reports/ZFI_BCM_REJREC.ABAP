----------------------------------------------------------------------------------------------------
Main program     ZFI_BCM_REJREC                            Level 0    Page 1
Object           ZFI_BCM_REJREC                            Lines 4413
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:54
----------------------------------------------------------------------------------------------------
1      REPORT zfi_bcm_rejrec .
2      ***********************************************************************
3      ** Program Copied from 'ZFI_REM_PYBLCK' TCODE -'ZFIBLOCKX'
4      ** By SAB_ARJUN Dt : 18-Sept-2013
5      ** CR : 30009692 - Payment order processing
6      ** Processing Rejected files from SBI
7      ** Using this program updating Tables BSIK and BSEG
8      ***********************************************************************
9
10
11     *-----  PROGRAM FOR Removing payment blocks 'X'  ****
12     ***********************************************************************
13     * Program    :                                                        *
14     *                                                                     *
15     *                                                                     *
16     * Author     : S.R.Sudha                     Date : 14.03.2008
17     *
18     *                                                                     *
19     * Login Id   : CAB_SUDHA                                              *
20     *                                                                      *
21     * Description: For removing payment blocks in documents for vendor as *
22     *               per i/p
23     *  FS-no     : FS-FI-GL-41
24     *                                                                     *
25     * Tran.Code  : ZFIBLOCKX
26     *
27     *                                                                     *
28     ***********************************************************************
29     *Change History
30     *By            ID   Login       FS  given By           Description
31     *       Date
32     *S.R.Sudha   +001   CAB_SUDHA   N.Mallikarjun          Paymnt Ref Added
33     *       4.4.2008
34     *S.R.Sudha   +002   CAB_SUDHA   N.Mallikarjun          JV Cash call Sp
35     *      22.04.2008                                 glPayment method added
36     *
37     *            +003   CAB_SUDHA   N.Mallikarjun           Req. of new
38     *  payment blocks   R- rejection, S- stale cheque , D - old lineitems
39     *                   auth object added
40     ***********************************************************************
41     ************************************************************************
42     *  Date         Transport   USERID          Description
43     * 19/12/2008  <RD1K960891> CAB_SUDHA  Payment block for customers
44     * 25.02.09  cab_rama        FS-FI-AP-083_01 30000782    001
45     * 28.10.2009 RD1K967585  CAB_ALOK     CR30002778, various validations for line items
46     *                                         in 'Payment Block from X to Blank' option,
47     *                                         Separate ALV for exception items,
48     *                                         Addition of INV REF & Subtotal in Reports,
49     *                                        Creation of activity logs in separate Z table.
50     * 09.03.2010 RD1K970594 CAB_ALOK      CR30003739: Correction in Invoice ref. logic,
51     *                                            Addition of 'Curr key' in reports
52     * 26.03.2010               SAB_SUMAN      30003849.
53     * 07.10.2010 RD1K973788 CAB_ALOK      CR 30004826 - Condition on kunnr
54     * 20.04.2010 RD1K975843 CAB_ALOK      CR 30005441 - Validations in view of CVP:
55     *                                     Validations based on:
56     *                                     payment method,
57     *                                     Add column for field Base Line and validate,
58     *                                     payment method in all linked documents,
59     *                                     business area - send complete document to exceptions,
60     *                                     joint validation of liability doc and credit memo.
61     *                                     Addition of Doc. no. in selection,
62     *                                     conditon 'Inconsistent PM in Docs' to be checked before
63     *                                     conditon 'Diff Pymt Method in vendor master'.
64     *                                     base line date to be placed before posting date field
65     *                                     CHANGE in due date check condition: all linked documents to go
66     *                                     to 'Exception'  if 1. RD > CD > LD & 2. RD > LD > CD, where CD - Current date
67     *                                     RD - Due date in Recovery document, LD - Due date in Liability document,
68     *                                     'X/BLANK  to S' was not updating table BSEG
69     * 05.08.2011 RD1K975843 CAB_ALOK      add field for Due date in exception tab after posting date field
70     *
71     ************************************************************************
72     *----------------------------------------------------------------------*
73     TYPE-POOLS : slis.
74     *Begin of <RD1K967585> CAB_ALOK 08.12.2009 CR30002778
75     *TABLES : bsik, t001, bkpf, bsid .
76     TABLES : bsik, t001, bkpf, bsid, zfi_rem_pyblck_l, vcnum . " ZFI_REM_PYBLCK_L for storing logs
77     *end of <RD1K967585> CAB_ALOK 08.12.2009 CR30002778
78     TYPES : BEGIN OF st_budget,
79             row(30) TYPE c,
80               END OF st_budget.
81     DATA :ist_budget TYPE STANDARD TABLE OF st_budget,
82           wa_budget TYPE st_budget.
83     DATA : ist_bsik  TYPE TABLE OF bsik.
84     DATA : ist_bseg TYPE TABLE OF  bseg.
85     DATA : wa_bsik  TYPE bsik.
86     DATA : wa_bseg TYPE  bseg.
87
88     DATA : y_doc_nos LIKE zfi_docnos OCCURS 0 WITH HEADER LINE .
89     DATA : f_doc_nos LIKE zfi_docnos OCCURS 0 WITH HEADER LINE .
90
91     DATA: BEGIN OF ist_bkpf OCCURS 0,
92           blart LIKE bkpf-blart,
93           belnr LIKE bkpf-belnr,
94           bldat LIKE bkpf-bldat,
95           budat LIKE bkpf-budat,
96           waers LIKE bkpf-waers,
97           usnam LIKE bkpf-usnam,
98           ppnam LIKE bkpf-ppnam,
99           gjahr LIKE bkpf-gjahr, "Added PN
100          bukrs LIKE bkpf-bukrs, "Added PN
101          END OF ist_bkpf.
102
103    DATA : BEGIN OF ist_srcbsik OCCURS 0 ,
104           selcbox(1) TYPE c,
105           lifnr LIKE bsik-lifnr , "Vendor no.
106           umskz LIKE bsik-umskz,
107           bukrs LIKE bsik-bukrs ,  " company code
108           gjahr LIKE bsik-gjahr,
109           belnr  LIKE bsik-belnr,  "Doc No.
110           buzei  LIKE bsik-buzei,
111           budat  LIKE bsik-budat,
112           bschl LIKE bsik-bschl,  " Posting Key
113           zlsch LIKE bsik-zlsch,    "Payment Method                      "+002
114           zlspr LIKE  bsik-zlspr,  " Payment Block Key
115           shkzg LIKE bsik-shkzg,   "Debit/Credit Indicator
116           gsber LIKE  bsik-gsber,
117           dmbtr LIKE bsik-dmbtr,
118    * Begin of <RD1K967585> CAB_ALOK 29.10.2009 CR30002778
119           subtot TYPE p  DECIMALS 2 ,
120    * end of <RD1K967585> CAB_ALOK 29.10.2009 CR30002778
121           wrbtr LIKE bsik-wrbtr,
122    * begin of < RD1K970594> CAB_ALOK 10.03.2010 CR30003739
123           waers LIKE bsik-waers, " Currency Key
124    * end of < RD1K970594> CAB_ALOK 10.03.2010 CR30003739
125           kidno LIKE  bsik-kidno,     " Payment Ref.                        "+001
126           usnam  LIKE bkpf-usnam,
127           xref1_hd LIKE bkpf-xref1_hd,
128           rebzg LIKE bsik-rebzg,        " Invoice Ref.
129           reason TYPE string,
130    * begin RD1K975843 CAB_ALOK CR 30005441
131           zfbdt  TYPE bseg-zfbdt, " due date/baseline date
132    * end RD1K975843 CAB_ALOK CR 30005441
133    *Begin of <RD1K967585> CAB_ALOK 02.11.2009 CR30002778
134    *       activ(1),   " ambiguous
135            inactiv(1),          " if X, then that line will be deactive
136            netamt LIKE bsik-dmbtr,
137            serial_no TYPE i,
138            subgrp TYPE i ,     "
139
140    *end of <RD1K967585> CAB_ALOK 02.11.2009 CR30002778
141      rebzz TYPE bsik-rebzz,
142    *{30007662
143    blart TYPE bsik-blart,
144      fipos TYPE bsik-fipos,
145      fistl TYPE bsik-fistl,
146    *}30007662
147    *{
148      ebeln TYPE bsik-ebeln,
149      ebelp TYPE bsik-ebelp.
150    *}
151    *       include structure  bsis.
152    DATA:  END OF ist_srcbsik .
153    DATA : wa_srcbsik LIKE ist_srcbsik.
154    DATA : wa_srcbsik_l LIKE ist_srcbsik.
155    *Begin of <RD1K967585> CAB_ALOK 25.11.2009 CR30002778
156    DATA : ist_srcbsik_orig LIKE STANDARD TABLE OF ist_srcbsik .
157    DATA : wa_srcbsik_orig LIKE LINE OF ist_srcbsik_orig .
158    DATA : ist_srcbsik_inactiv LIKE STANDARD TABLE OF ist_srcbsik .
159    DATA : wa_srcbsik_inactiv LIKE LINE OF ist_srcbsik_inactiv.
160    *end of <RD1K967585> CAB_ALOK 25.11.2009 CR30002778
161    DATA : ist_bsiks LIKE ist_srcbsik OCCURS 0 WITH HEADER LINE.
162    DATA : ist_debit LIKE ist_srcbsik OCCURS 0.
163    DATA : wa_debit  LIKE ist_srcbsik.
164    *-----------Start of <RD1K960891>
165    DATA : BEGIN OF ist_srcbsid OCCURS 0 ,
166           selcbox(1) TYPE c,
167           kunnr LIKE bsid-kunnr ,   "customer no.
168           umskz LIKE bsid-umskz,
169           bukrs LIKE bsid-bukrs ,
170           gjahr LIKE bsid-gjahr,
171           belnr  LIKE bsid-belnr,    "Doc No.
172           buzei  LIKE bsid-buzei,
173           budat  LIKE bsid-budat,
174           bschl LIKE bsid-bschl,   " Posting Key
175           zlsch LIKE bsid-zlsch,   "Payment Method                            "+002
176           zlspr LIKE  bsid-zlspr,  " Payment Block Key
177           shkzg LIKE bsid-shkzg,   "Debit/Credit Indicator
178           gsber LIKE  bsid-gsber,
179           dmbtr LIKE bsid-dmbtr,
180    *Begin of <RD1K967585> CAB_ALOK 29.10.2009 CR30002778
181           subtot TYPE p  DECIMALS 2 ,
182    *end of <RD1K967585> CAB_ALOK 29.10.2009 CR30002778
183           wrbtr LIKE bsid-wrbtr,
184    * begin of < RD1K970594> CAB_ALOK 10.03.2010 CR30003739
185           waers LIKE bsid-waers, " Currency Key
186    * end of < RD1K970594> CAB_ALOK 10.03.2010 CR30003739
187           kidno LIKE  bsid-kidno,    " Payment Ref.                          "+001
188           usnam  LIKE bkpf-usnam,
189      xref1_hd LIKE bkpf-xref1_hd,
190             rebzg LIKE bsid-rebzg,  " Invoice Ref.
191           reason TYPE string,
192    *Begin of <RD1K967585> CAB_ALOK 02.11.2009 CR30002778
193    *       activ(1),   " ambiguous
194            inactiv(1), " if X, then that line will be deactive
195            netamt LIKE bsid-dmbtr,
196            serial_no TYPE i,
197            subgrp TYPE i .     "
198    *end of <RD1K967585> CAB_ALOK 02.11.2009 CR30002778
199    *       include structure  bsis.
200    DATA:  END OF ist_srcbsid .
201
202    DATA : wa_srcbsid LIKE ist_srcbsid.
203    *Begin of <RD1K967585> CAB_ALOK 25.11.2009 CR30002778
204    DATA : ist_srcbsid_orig LIKE STANDARD TABLE OF ist_srcbsid .
205    DATA : wa_srcbsid_orig LIKE LINE OF ist_srcbsid_orig .
206    DATA : ist_srcbsid_inactiv LIKE STANDARD TABLE OF ist_srcbsid .
207    DATA : wa_srcbsid_inactiv LIKE LINE OF ist_srcbsid_inactiv.
208    *end of <RD1K967585> CAB_ALOK 25.11.2009 CR30002778
209    DATA : ist_bsids LIKE ist_srcbsid OCCURS 0 WITH HEADER LINE.
210    DATA : ist_bsid  TYPE TABLE OF bsid.
211    DATA : wa_bsid  TYPE bsid.
212    *-----------End of <RD1K960891>
213
214    DATA : w_repid TYPE sy-repid.
215
216    DATA:  is_layout  TYPE  slis_layout_alv,
217    *begin of <RD1K967585> CAB_ALOK 03.12.2009 CR30002778
218          is_layout_inactiv  TYPE  slis_layout_alv,
219    *end of <RD1K967585> CAB_ALOK 03.12.2009 CR30002778
220           ist_fieldcat TYPE  slis_fieldcat_alv  , "line.
221           ist_fcat TYPE  TABLE OF slis_fieldcat_alv,
222            lt_sorttab TYPE slis_t_sortinfo_alv,
223           ls_sorttab TYPE slis_sortinfo_alv. " sort structure for ALV
224    *begin of <RD1K967585> CAB_ALOK 26.11.2009 CR30002778
225    *  ALV of inactive items: Inactive items to be shown in separate list.
226    DATA: ist_fieldcat_inactiv TYPE  slis_fieldcat_alv  , "work area.
227          ist_fcat_inactiv TYPE  TABLE OF slis_fieldcat_alv. "IST
228    *end of <RD1K967585> CAB_ALOK 26.11.2009 CR30002778
229    DATA  : mpos TYPE i .
230    DATA : gt_list_top_of_page TYPE slis_t_listheader,
231           gt_list_end_of_list TYPE slis_t_listheader,
232           gt_events   TYPE slis_t_event.
233    *begin of <RD1K967585> CAB_ALOK 27.11.2009 CR30002778
234    DATA : gt_events_inactiv   TYPE slis_t_event.
235    DATA : pmtblock_to TYPE bsik-zlspr.
236    *end of <RD1K967585> CAB_ALOK 14.12.2009 CR30002778
237
238    * begin RD1K975843 CAB_ALOK CR 30005441
239    DATA: t_days_diff TYPE i.
240    TYPES: BEGIN OF ty_msg,
241             liv_doc(30),
242             credit_memo(30),
243    *          LIV_LIFNR type LIFNR,
244    *          LIV_BUKRS type BUKRS,
245    *          LIV_GJAHR type GJAHR,
246    *          LIV_BELNR type BSIK-BELNR,
247    *          CR_MEMO_BUKRS type BUKRS,
248    *          CR_MEMO_LIFNR type LIFNR,
249    *          CR_MEMO_BELNR type BSIK-BELNR,
250            END OF ty_msg.
251    DATA: ist_msg TYPE STANDARD TABLE OF ty_msg,
252          wa_msg TYPE ty_msg.
253    * end RD1K975843 CAB_ALOK CR 30005441
254    DATA : ist_srcbsik_l LIKE ist_srcbsik OCCURS 0 WITH HEADER LINE.
255    *{begin of 30007662
256    DATA :g_budget TYPE fmit-hsl16,"bseg-dmbtr,
257          g_budget_c(16)," type bseg-dmbtr,
258    *            l_budget type bseg-dmbtr,
259          g_dmbtr TYPE bseg-dmbtr,
260          g_budget_d(25),"g_budget_d(16)
261          g_budget_as(25),"g_budget_as(16)
262          g_budget_av(25)."g_budget_av(16).
263    *}end of 30007662
264    SELECTION-SCREEN : BEGIN OF BLOCK  blk1  WITH FRAME TITLE  text-001.
265
266    SELECT-OPTIONS : s_lifnr FOR bsik-lifnr ,  "<RD1K960891>
267                     s_kunnr FOR bsid-kunnr ,  "<RD1K960891>
268                     s_year  FOR bsik-gjahr,
269    *begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778    "business area removed
270    *                 s_gsber FOR bsik-gsber,
271    *end of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
272                     s_budat FOR bsik-budat,
273                     s_usnam FOR bkpf-usnam,
274    *  *Start of addition Prabu K on 06.07.2009
275                     s_xref1 FOR bkpf-xref1_hd ,
276    *  End of addition Prabu K on 06.07.2009
277    * begin RD1K975843 CAB_ALOK      CR 30005441
278                     s_belnr FOR bsik-belnr.
279    * end RD1K975843 CAB_ALOK      CR 30005441
280    PARAMETERS : p_bukrs LIKE bsik-bukrs OBLIGATORY .
281
282    SKIP  2.
283
284    SELECTION-SCREEN : END OF BLOCK blk1.
285
286    SELECTION-SCREEN : BEGIN OF BLOCK  blk2 WITH FRAME.
287
288    SELECTION-SCREEN BEGIN OF  LINE .
289    SELECTION-SCREEN COMMENT 2(76) text-003 FOR FIELD p_x2sp.
290    PARAMETERS : p_x2sp RADIOBUTTON GROUP rad1 .
291    SELECTION-SCREEN END OF LINE.
292    SKIP.
293    SELECTION-SCREEN BEGIN OF  LINE .
294    SELECTION-SCREEN COMMENT 2(76) text-004 FOR FIELD p_sp2x.
295    PARAMETERS : p_sp2x RADIOBUTTON GROUP rad1 .
296    SELECTION-SCREEN END OF LINE.
297    SELECTION-SCREEN SKIP 1.
298    SELECTION-SCREEN ULINE.
299    SELECTION-SCREEN BEGIN OF  LINE .
300    SELECTION-SCREEN COMMENT 2(76) text-005 FOR FIELD p_sp2r.
301    PARAMETERS:  p_sp2r RADIOBUTTON GROUP rad1.
302    SELECTION-SCREEN END OF LINE.
303    SELECTION-SCREEN ULINE.
304    SELECTION-SCREEN SKIP 1.
305    SELECTION-SCREEN BEGIN OF  LINE .
306    SELECTION-SCREEN COMMENT 2(76) text-006 FOR FIELD p_x2s.
307    PARAMETERS:   p_x2s  RADIOBUTTON GROUP rad1.
308    SELECTION-SCREEN END OF LINE.
309    * Begin of RD1K971966 CAB_ALOK CR30004183
310    *SELECTION-SCREEN BEGIN OF  LINE .
311    *SELECTION-SCREEN COMMENT 2(76) text-007 FOR FIELD p_s2x.
312    *PARAMETERS:   p_s2x  RADIOBUTTON GROUP rad1.
313    *SELECTION-SCREEN END OF LINE.
314    * end of RD1K971966 CAB_ALOK CR30004183
315    *selection-screen begin of  line .
316    *SELECTION-SCREEN COMMENT 2(76) text-008 FOR FIELD p_sp2s.
317    *parameters:  p_sp2s RADIOBUTTON GROUP rad1.
318    *selection-screen end of line.
319    SELECTION-SCREEN : END OF BLOCK blk2.
320
321
322
323
324    CONSTANTS  : g_zlspr_x   LIKE bseg-zlspr  VALUE 'X',
325                 g_zlspr_sp   LIKE bseg-zlspr VALUE ' ',
326                 g_zlspr_s  LIKE bseg-zlspr  VALUE 'S',
327                 g_zlspr_r  LIKE bseg-zlspr  VALUE 'R'.
328
329    * *Start of addition Prabu K on 11.07.2009
330    AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_xref1-low.
331
332
333      TYPES : BEGIN OF ty_t526,
334              sachx TYPE sachx,
335              werks TYPE sbmod,
336              END OF ty_t526.
337
338      TYPES: BEGIN OF ty_final,
339             bukrs TYPE bukrs,
340             persa TYPE persa,
341             sachx TYPE sachx,
342             END OF ty_final.
343      TYPES: BEGIN OF ty_t5009,
344             persa TYPE persa,
345             bukrs TYPE bukrs,
346             END OF ty_t5009.
347      DATA: lv_area TYPE STANDARD TABLE OF ty_t526 ,
348              wa_area LIKE LINE OF lv_area.
349
350      DATA: it_t5009 TYPE STANDARD TABLE OF ty_t5009 ,
351              wa_t5009 LIKE LINE OF  it_t5009.
352
353      DATA: it_final TYPE STANDARD TABLE OF ty_final ,
354              wa_final LIKE LINE OF  it_final.
355
356      SELECT sachx werks FROM t526 INTO CORRESPONDING FIELDS OF TABLE lv_area.  "#EC CI_NOORDER
357
358      SORT lv_area BY sachx.
359      DELETE ADJACENT DUPLICATES FROM lv_area
360      COMPARING sachx.
361
362    *  select persa bukrs  from t500p into table it_t5009 for all entries
363    *                         in lv_area where persa = lv_area-sachx.
364
365      SELECT persa bukrs  FROM t500p INTO CORRESPONDING FIELDS OF TABLE it_t5009.
366
367      SORT it_t5009  BY persa.
368      DELETE ADJACENT DUPLICATES FROM it_t5009
369      COMPARING persa.
370
371      LOOP AT lv_area INTO wa_area.
372
373        READ TABLE it_t5009 INTO wa_t5009 WITH KEY persa = wa_area-werks.
374        wa_final-sachx = wa_area-sachx.
375        wa_final-persa = wa_t5009-persa.
376        wa_final-bukrs = wa_t5009-bukrs.
377        APPEND wa_final TO it_final.
378      ENDLOOP.
379      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
380        EXPORTING
381          retfield        = 'SACHX'
382          dynpprog        = 'ZFI_REM_PYBLCK'
383          dynpnr          = sy-dynnr
384          dynprofield     = 'S_XREF1-LOW'
385          value_org       = 'S'
386        TABLES
387          value_tab       = it_final
388        EXCEPTIONS
389          parameter_error = 1
390          no_values_found = 2
391          OTHERS          = 3.
392
393      IF sy-subrc <> 0.
394    *
395    *    message id sy-msgid type sy-msgty number sy-msgno
396    *            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
397
398      ENDIF.
399
400    AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_xref1-high.
401      TYPES : BEGIN OF ty_t526,
402              sachx TYPE sachx,
403              werks TYPE sbmod,
404              END OF ty_t526.
405
406      TYPES: BEGIN OF ty_final,
407             bukrs TYPE bukrs,
408             persa TYPE persa,
409             sachx TYPE sachx,
410             END OF ty_final.
411      TYPES: BEGIN OF ty_t5009,
412             persa TYPE persa,
413             bukrs TYPE bukrs,
414             END OF ty_t5009.
415      DATA: lv_area TYPE STANDARD TABLE OF ty_t526 ,
416              wa_area LIKE LINE OF lv_area.
417
418      DATA: it_t5009 TYPE STANDARD TABLE OF ty_t5009 ,
419              wa_t5009 LIKE LINE OF  it_t5009.
420
421      DATA: it_final TYPE STANDARD TABLE OF ty_final ,
422              wa_final LIKE LINE OF  it_final.
423
424      SELECT sachx werks FROM t526 INTO CORRESPONDING FIELDS OF TABLE lv_area.  "#EC CI_NOORDER
425
426      SORT lv_area BY sachx.
427      DELETE ADJACENT DUPLICATES FROM lv_area
428      COMPARING sachx.
429
430    *  select persa bukrs  from t500p into table it_t5009 for all entries
431    *                         in lv_area where persa = lv_area-sachx.
432
433      SELECT persa bukrs  FROM t500p INTO CORRESPONDING FIELDS OF TABLE it_t5009.
434
435      SORT it_t5009  BY persa.
436      DELETE ADJACENT DUPLICATES FROM it_t5009
437      COMPARING persa.
438
439      LOOP AT lv_area INTO wa_area.
440
441        READ TABLE it_t5009 INTO wa_t5009 WITH KEY persa = wa_area-werks.
442        wa_final-sachx = wa_area-sachx.
443        wa_final-persa = wa_t5009-persa.
444        wa_final-bukrs = wa_t5009-bukrs.
445        APPEND wa_final TO it_final.
446      ENDLOOP.
447      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
448        EXPORTING
449          retfield        = 'SACHX'
450          dynpprog        = 'ZFI_REM_PYBLCK'
451          dynpnr          = sy-dynnr
452          dynprofield     = 'S_XREF1-HIGH'
453          value_org       = 'S'
454        TABLES
455          value_tab       = it_final
456        EXCEPTIONS
457          parameter_error = 1
458          no_values_found = 2
459          OTHERS          = 3.
460
461      IF sy-subrc <> 0.
462    *
463    *    message id sy-msgid type sy-msgty number sy-msgno
464    *            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
465
466      ENDIF.
467    * End of addition Prabu K on 11.07.2009
468
469
470    AT SELECTION-SCREEN ON p_bukrs .
471      SELECT SINGLE * FROM t001  WHERE bukrs = p_bukrs.
472      IF sy-subrc <> 0.
473        MESSAGE e010(fi) WITH p_bukrs.
474      ENDIF.
475    *---------Start of <RD1K960891>
476
477      AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
478                  ID 'ACTVT' FIELD '02'
479                  ID 'BUKRS' FIELD p_bukrs.
480
481      IF sy-subrc <> 0.
482        MESSAGE  e091(8b) WITH p_bukrs.
483      ENDIF.
484    *-----------End of <RD1K960891>
485
486    *------------------------------------------------------*
487    START-OF-SELECTION.
488    *------------------------------------------------------*
489    *---+003
490
491    * remove before TP
492    * IF NOT sy-uname = 'CAB_ALOK' .
493      IF p_sp2r = 'X'.
494        PERFORM authority_check USING '02' .
495      ENDIF.
496    * ENDIF.
497    *----+003
498    *---+004
499    * remove before TP
500    *  IF NOT sy-uname = 'CAB_ALOK' .
501      IF p_x2sp = 'X' OR  p_sp2x  = 'X'.
502        PERFORM authority_check_x USING '02' .
503      ENDIF.
504    *  ENDIF.
505    *---+004
506    *-----------Start of <RD1K960891>
507
508      IF NOT s_lifnr  IS INITIAL.
509        PERFORM get_docs.
510        PERFORM validate_docs.
511    ** Begin -By SAB_ARJUN
512        DATA r_ucomm LIKE sy-ucomm.
513        DATA rs_selfield TYPE slis_selfield.
514        r_ucomm = 'REL'.
515        PERFORM make_command USING r_ucomm rs_selfield.
516        EXIT.
517    ** End of -By SAB_ARJUN
518        PERFORM display_docs.
519    *Begin of <RD1K975843> CAB_ALOK CR 30005441
520        PERFORM display_messages.
521    *end of <RD1K975843> CAB_ALOK CR 30005441
522      ELSEIF  NOT s_kunnr IS INITIAL.
523        PERFORM get_docs_cust.
524        PERFORM validate_docs_cust.
525        PERFORM display_docs_cust.
526      ENDIF.
527    *-----------End of <RD1K960891>
528
529    *&---------------------------------------------------------------------*
530    *&      Form  display_docs
531    *&---------------------------------------------------------------------*
532    *       text
533    *----------------------------------------------------------------------*
534    *  -->  p1        text
535    *  <--  p2        text
536    *----------------------------------------------------------------------*
537    FORM display_docs.
538      PERFORM init_fieldcat.
539    *begin of <RD1K967585> CAB_ALOK 26.11.2009 CR30002778
540    *  make fieldcat for inactive items
541      PERFORM init_fieldcat_inactiv.
542    *end of <RD1K967585> CAB_ALOK 26.11.2009 CR30002778
543      PERFORM eventtab_build TABLES gt_events.
544      PERFORM comment_build TABLES gt_list_top_of_page.
545      PERFORM  sort_build .
546    *begin of <RD1K967585> CAB_ALOK 26.11.2009 CR30002778
547    *    PERFORM  print_alv.
548    *  display multiple list ALV
549      PERFORM print_multi_alv..
550    *end of <RD1K967585> CAB_ALOK 26.11.2009 CR30002778
551
552    ENDFORM.                    " display_docs
553    *&---------------------------------------------------------------------*
554    *&      Form  init_fieldcat
555    *&---------------------------------------------------------------------*
556    *       text
557    *----------------------------------------------------------------------*
558    *  -->  p1        text
559    *  <--  p2        text
560    *----------------------------------------------------------------------*
561    FORM init_fieldcat.
562      w_repid  = sy-repid.
563
564      mpos = 0.
565      mpos = mpos + 1.
566      ist_fieldcat-fieldname = 'SELCBOX'.
567      ist_fieldcat-tabname = 'IST_SRCBSIK'.
568    *  ist_fieldcat-ddictxt = 'M'.
569      ist_fieldcat-col_pos =  mpos.
570      ist_fieldcat-seltext_m  = 'Select'.
571    *  ist_fieldcat-lowercase  = 'Y'.
572      ist_fieldcat-checkbox = 'X'.
573      ist_fieldcat-input = 'X'.
574    *  ist_fieldcat-edit = 'X'.
575      APPEND ist_fieldcat TO ist_fcat.
576      CLEAR ist_fieldcat.
577
578      mpos = mpos + 1.
579      ist_fieldcat-fieldname = 'LIFNR'.
580      ist_fieldcat-tabname = 'IST_SRCBSIK'.
581      ist_fieldcat-ddictxt = 'M'.
582      ist_fieldcat-col_pos =  mpos.
583    *begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
584    *  ist_fieldcat-seltext_m  = 'VendorNumber.'.
585      ist_fieldcat-seltext_m  = 'Vendor No.'.
586    *end of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
587      ist_fieldcat-lowercase  = 'Y'.
588      APPEND ist_fieldcat TO ist_fcat.
589      CLEAR ist_fieldcat.
590
591      mpos = mpos + 1.
592      ist_fieldcat-fieldname = 'BELNR'.
593      ist_fieldcat-tabname = 'IST_SRCBSIK'.
594      ist_fieldcat-ddictxt = 'M'.
595      ist_fieldcat-col_pos =  mpos.
596      ist_fieldcat-seltext_m  = 'Doc. No.'.
597      ist_fieldcat-lowercase  = 'Y'.
598      APPEND ist_fieldcat TO ist_fcat.
599      CLEAR ist_fieldcat.
600
601    *begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
602    *  mpos = mpos + 1.
603    *  ist_fieldcat-fieldname = 'GSBER'.
604    *  ist_fieldcat-tabname = 'IST_SRCBSIK'.
605    *  ist_fieldcat-ddictxt = 'M'.
606    *  ist_fieldcat-col_pos =  mpos.
607    *  ist_fieldcat-seltext_m  = 'Business Area'.
608    *  ist_fieldcat-lowercase  = 'Y'.
609    *  APPEND ist_fieldcat TO ist_fcat.
610    *  CLEAR ist_fieldcat.
611    *end of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
612    *---+001
613
614      mpos = mpos + 1.
615      ist_fieldcat-fieldname = 'KIDNO'.
616      ist_fieldcat-tabname = 'IST_SRCBSIK'.
617      ist_fieldcat-ddictxt = 'M'.
618      ist_fieldcat-col_pos =  mpos.
619    *begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
620    *  ist_fieldcat-seltext_m  = 'Payment Reference'.
621      ist_fieldcat-seltext_m  = 'Pymt Ref'.
622    *end of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
623      ist_fieldcat-lowercase  = 'Y'.
624      APPEND ist_fieldcat TO ist_fcat.
625      CLEAR ist_fieldcat.
626    *-------+001
627    *---+002
628      mpos = mpos + 1.
629      ist_fieldcat-fieldname = 'REBZG'.
630      ist_fieldcat-tabname = 'IST_SRCBSIK'.
631      ist_fieldcat-ddictxt = 'M'.
632      ist_fieldcat-col_pos =  mpos.
633    *begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
634    *  ist_fieldcat-seltext_m  = 'Invoice Reference'.
635      ist_fieldcat-seltext_m  = 'Inv Ref'.
636    *end of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
637    *  ist_fieldcat-lowercase  = 'Y'.
638      APPEND ist_fieldcat TO ist_fcat.
639      CLEAR ist_fieldcat.
640
641    *begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
642    *  mpos = mpos + 1.
643    *  ist_fieldcat-fieldname = 'SHKZG'.
644    *  ist_fieldcat-tabname = 'IST_SRCBSIK'.
645    *  ist_fieldcat-ddictxt = 'M'.
646    *  ist_fieldcat-col_pos =  mpos.
647    *  ist_fieldcat-seltext_m  = 'Indicator'.
648    **  ist_fieldcat-lowercase  = 'Y'.
649    *  APPEND ist_fieldcat TO ist_fcat.
650    *  CLEAR ist_fieldcat.
651    *end of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
652    *-------+002
653
654    *begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
655    *  mpos = mpos + 1.
656    *  ist_fieldcat-fieldname = 'GJAHR'.
657    *  ist_fieldcat-tabname = 'IST_SRCBSIK'.
658    *  ist_fieldcat-ddictxt = 'M'.
659    *  ist_fieldcat-col_pos =  mpos.
660    *  ist_fieldcat-seltext_m  = 'Year'.
661    *  ist_fieldcat-lowercase  = 'Y'.
662    *  APPEND ist_fieldcat TO ist_fcat.
663    *  CLEAR ist_fieldcat.
664    *end of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
665
666      mpos = mpos + 1.
667      ist_fieldcat-fieldname = 'BUZEI'.
668      ist_fieldcat-tabname = 'IST_SRCBSIK'.
669      ist_fieldcat-ddictxt = 'M'.
670      ist_fieldcat-col_pos =  mpos.
671      ist_fieldcat-seltext_m  = 'Item.no.'.
672      ist_fieldcat-lowercase  = 'Y'.
673      APPEND ist_fieldcat TO ist_fcat.
674      CLEAR ist_fieldcat.
675
676    * begin RD1K975843 CAB_ALOK CR 30005441
677      mpos = mpos + 1.
678      ist_fieldcat-fieldname = 'REASON'.
679      ist_fieldcat-tabname = 'IST_SRCBSIK'.
680      ist_fieldcat-ddictxt = 'M'.
681      ist_fieldcat-col_pos =  mpos.
682      ist_fieldcat-seltext_m  = 'Caution'.
683      ist_fieldcat-lowercase  = 'Y'.
684      ist_fieldcat-emphasize = 'C31'.
685      APPEND ist_fieldcat TO ist_fcat.
686      CLEAR ist_fieldcat.
687    * end RD1K975843 CAB_ALOK CR 30005441
688
689      mpos = mpos + 1.
690      ist_fieldcat-fieldname = 'BSCHL'.
691      ist_fieldcat-tabname = 'IST_SRCBSIK'.
692      ist_fieldcat-ddictxt = 'M'.
693      ist_fieldcat-col_pos =  mpos.
694    *begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
695    *  ist_fieldcat-seltext_m  = 'Posting Key.'.
696      ist_fieldcat-seltext_m  = 'PK'.
697    *end of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
698      ist_fieldcat-lowercase  = 'Y'.
699      APPEND ist_fieldcat TO ist_fcat.
700      CLEAR ist_fieldcat.
701
702    * begin RD1K975843 CAB_ALOK CR 30005441
703      mpos = mpos + 1.
704      ist_fieldcat-fieldname = 'ZFBDT'.
705      ist_fieldcat-tabname = 'IST_SRCBSIK'.
706      ist_fieldcat-ddictxt = 'M'.
707      ist_fieldcat-col_pos =  mpos.
708      ist_fieldcat-seltext_m  = 'Due Dt.'.
709      ist_fieldcat-lowercase  = 'Y'.
710      APPEND ist_fieldcat TO ist_fcat.
711      CLEAR ist_fieldcat.
712    * end RD1K975843 CAB_ALOK CR 30005441
713
714      mpos = mpos + 1.
715      ist_fieldcat-fieldname = 'BUDAT'.
716      ist_fieldcat-tabname = 'IST_SRCBSIK'.
717      ist_fieldcat-ddictxt = 'M'.
718      ist_fieldcat-col_pos =  mpos.
719    *begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
720    *  ist_fieldcat-seltext_m  = 'Posting Date'.
721      ist_fieldcat-seltext_m  = 'Post Dt'.
722    *end of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
723      ist_fieldcat-lowercase  = 'Y'.
724      APPEND ist_fieldcat TO ist_fcat.
725      CLEAR ist_fieldcat.
726
727    *begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
728    *  mpos = mpos + 1.
729    *  ist_fieldcat-fieldname = 'DMBTR'.
730    *  ist_fieldcat-tabname = 'IST_SRCBSIK'.
731    *  ist_fieldcat-ddictxt = 'M'.
732    *  ist_fieldcat-col_pos =  mpos.
733    *  ist_fieldcat-seltext_m  = 'AmtInLclCurncy'.
734    *  ist_fieldcat-lowercase  = 'Y'.
735    *  APPEND ist_fieldcat TO ist_fcat.
736    *  CLEAR ist_fieldcat.
737    *end of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
738
739    *Begin of <RD1K967585> CAB_ALOK 29.10.2009 CR30002778
740      mpos = mpos + 1.
741      ist_fieldcat-fieldname = 'SUBTOT'.
742      ist_fieldcat-tabname = 'IST_SRCBSIK'.
743      ist_fieldcat-ddictxt = 'M'.
744      ist_fieldcat-col_pos =  mpos.
745      ist_fieldcat-seltext_m  = 'SubTotal'.
746      ist_fieldcat-lowercase  = 'Y'.
747      APPEND ist_fieldcat TO ist_fcat.
748      CLEAR ist_fieldcat.
749
750    *End of <RD1K967585> CAB_ALOK 29.10.2009 CR30002778
751      mpos = mpos + 1.
752      ist_fieldcat-fieldname = 'WRBTR'.
753      ist_fieldcat-tabname = 'IST_SRCBSIK'.
754      ist_fieldcat-ddictxt = 'M'.
755      ist_fieldcat-col_pos =  mpos.
756    *begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
757    *  ist_fieldcat-seltext_m  = 'AmtInDocCurncy'.
758      ist_fieldcat-seltext_m  = 'Amt In Doc Cur'.
759    *end of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
760      ist_fieldcat-lowercase  = 'Y'.
761      APPEND ist_fieldcat TO ist_fcat.
762      CLEAR ist_fieldcat.
763
764    * begin of < RD1K970594> CAB_ALOK 10.03.2010 CR30003739
765      mpos = mpos + 1.
766      ist_fieldcat-fieldname = 'WAERS'.
767      ist_fieldcat-tabname = 'IST_SRCBSIK'.
768      ist_fieldcat-ddictxt = 'M'.
769      ist_fieldcat-col_pos =  mpos.
770      ist_fieldcat-seltext_m  = 'Curr'.
771      ist_fieldcat-lowercase  = 'Y'.
772      APPEND ist_fieldcat TO ist_fcat.
773      CLEAR ist_fieldcat.
774    * end of < RD1K970594> CAB_ALOK 10.03.2010 CR30003739
775
776      mpos = mpos + 1.
777      ist_fieldcat-fieldname = 'ZLSCH'.
778      ist_fieldcat-tabname = 'IST_SRCBSIK'.
779      ist_fieldcat-ddictxt = 'M'.
780      ist_fieldcat-col_pos =  mpos.
781    *begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
782    *  ist_fieldcat-seltext_m  = 'PaymntMethod'.
783      ist_fieldcat-seltext_m  = 'PM'.
784    *end of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
785      ist_fieldcat-lowercase  = 'Y'.
786      APPEND ist_fieldcat TO ist_fcat.
787      CLEAR ist_fieldcat.
788
789      mpos = mpos + 1.
790      ist_fieldcat-fieldname = 'ZLSPR'.
791      ist_fieldcat-tabname = 'IST_SRCBSIK'.
792      ist_fieldcat-ddictxt = 'M'.
793      ist_fieldcat-col_pos =  mpos.
794    *begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
795    *  ist_fieldcat-seltext_m  = 'PaymntBlock'.
796      ist_fieldcat-seltext_m  = 'PB'.
797    *end of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
798      ist_fieldcat-lowercase  = 'Y'.
799      APPEND ist_fieldcat TO ist_fcat.
800      CLEAR ist_fieldcat.
801
802    *  *Start of addition Prabu K on 06.07.2009
803      mpos = mpos + 1.
804      ist_fieldcat-fieldname = 'XREF1_HD'.
805      ist_fieldcat-tabname = 'IST_SRCBSIK'.
806      ist_fieldcat-ddictxt = 'M'.
807      ist_fieldcat-col_pos =  mpos.
808    *begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
809    *  ist_fieldcat-seltext_m  = 'Location'.
810      ist_fieldcat-seltext_m  = 'Loc'.
811    *end of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
812      ist_fieldcat-lowercase  = 'Y'.
813      APPEND ist_fieldcat TO ist_fcat.
814      CLEAR ist_fieldcat.
815
816    * End of addition Prabu K on 06.07.2009
817    *begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778  IF NOT s_usnam IS INITIAL.
818    *    mpos = mpos + 1.
819    *    ist_fieldcat-fieldname = 'USNAM'.
820    *    ist_fieldcat-tabname = 'IST_SRCBSIK'.
821    *    ist_fieldcat-ddictxt = 'M'.
822    *    ist_fieldcat-col_pos =  mpos.
823    *    ist_fieldcat-seltext_m  = 'Created By'.
824    *    ist_fieldcat-lowercase  = 'Y'.
825    *    APPEND ist_fieldcat TO ist_fcat.
826    *    CLEAR ist_fieldcat.
827    *  ENDIF.
828    *end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
829    ENDFORM.                    " init_fieldcat
830    *&---------------------------------------------------------------------*
831    *&      Form  eventtab_build
832    *&---------------------------------------------------------------------*
833    *       text
834    *----------------------------------------------------------------------*
835    *      -->P_GT_EVENTS[]  text
836    *----------------------------------------------------------------------*
837    FORM eventtab_build TABLES  p_gt_events.
838      DATA : ls_event TYPE slis_alv_event.
839      CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
840        EXPORTING
841          i_list_type = 0
842        IMPORTING
843          et_events   = gt_events.
844
845      READ TABLE gt_events WITH KEY name =  slis_ev_user_command
846                                INTO ls_event.
847      IF sy-subrc <> 0.
848        MOVE slis_ev_user_command TO ls_event-name.
849        MOVE 'MAKE_COMMAND' TO ls_event-form.
850        APPEND ls_event TO gt_events.
851      ENDIF.
852      CLEAR ls_event.
853
854
855    *begin of <RD1K967585> CAB_ALOK 03.12.2009 CR30002778
856      CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
857        EXPORTING
858          i_list_type = 0
859        IMPORTING
860          et_events   = gt_events_inactiv.
861      CLEAR ls_event.
862    *end  of <RD1K967585> CAB_ALOK 03.12.2009 CR30002778
863    ENDFORM.                    " eventtab_build
864    *&---------------------------------------------------------------------*
865    *&      Form  comment_build
866    *&---------------------------------------------------------------------*
867    *       text
868    *----------------------------------------------------------------------*
869    *      -->P_GT_LIST_TOP_OF_PAGE[]  text
870    *----------------------------------------------------------------------*
871    FORM comment_build TABLES    p_gt_list_top_of_page.
872
873    ENDFORM.                    " comment_build
874    *&---------------------------------------------------------------------*
875    *&      Form  sort_build
876    *&---------------------------------------------------------------------*
877    *       text
878    *----------------------------------------------------------------------*
879    *  -->  p1        text
880    *  <--  p2        text
881    *----------------------------------------------------------------------*
882    FORM sort_build.
883
884      w_repid = sy-repid.
885      is_layout-key_hotspot = 'X'.
886      is_layout-colwidth_optimize = 'X'.
887    *begin of <RD1K967585> CAB_ALOK 03.12.2009 CR30002778
888      is_layout_inactiv-key_hotspot = 'X'.
889      is_layout_inactiv-colwidth_optimize = 'X'.
890    *end of <RD1K967585> CAB_ALOK 03.12.2009 CR30002778
891
892    *begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
893    *  ls_sorttab-fieldname = 'KIDNO'.
894    *  ls_sorttab-up = 'X'.
895    *  APPEND ls_sorttab TO lt_sorttab.
896    *end of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
897      ls_sorttab-fieldname = 'LIFNR'.
898      ls_sorttab-up = 'X'.
899      APPEND ls_sorttab TO lt_sorttab.
900    *begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
901    *  ls_sorttab-fieldname = 'BSCHL'.
902    *  ls_sorttab-up = 'X'.
903    *  APPEND ls_sorttab TO lt_sorttab.
904    *  ls_sorttab-fieldname = 'BELNR'.
905    *  ls_sorttab-up = 'X'.
906    *  APPEND ls_sorttab TO lt_sorttab.
907    *  ls_sorttab-fieldname = 'BUDAT'.
908    *  ls_sorttab-up = 'X'.
909    *  APPEND ls_sorttab TO lt_sorttab.
910    *begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
911
912    ENDFORM.                    " sort_build
913    *&---------------------------------------------------------------------*
914    *&      Form  print_alv
915    *&---------------------------------------------------------------------*
916    *       text
917    *----------------------------------------------------------------------*
918    *  -->  p1        text
919    *  <--  p2        text
920    *----------------------------------------------------------------------*
921    *begin of <RD1K967585> CAB_ALOK 27.11.2009 CR30002778
922    *FORM print_alv.
923    *
924    *  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
925    *       EXPORTING
926    *            i_callback_program       = w_repid
927    *            i_callback_pf_status_set = 'ALV_PFST'
928    *            i_callback_user_command  = 'MAKE_COMMAND'
929    *            is_layout                = is_layout
930    *            it_fieldcat              = ist_fcat[]
931    *            it_sort                  = lt_sorttab
932    *            it_events                = gt_events
933    *            i_save                   = 'A'
934    *       TABLES
935    *            t_outtab                 = ist_srcbsik.
936    *  IF sy-subrc <> 0.
937    **    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
938    **            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
939    *  ENDIF.
940    *
941    *
942    *ENDFORM.                    " print_alv
943    *End of <RD1K967585> CAB_ALOK 27.11.2009 CR30002778
944
945    *&---------------------------------------------------------------------*
946    *&      Form  PRINT_MULTI_ALV
947    *&---------------------------------------------------------------------*
948    *       text
949    *----------------------------------------------------------------------*
950    *  -->  p1        text
951    *  <--  p2        text
952    *----------------------------------------------------------------------*
953    *begin of <RD1K967585> CAB_ALOK 27.11.2009 CR30002778
954    FORM print_multi_alv .
955
956      CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
957            EXPORTING
958                 i_callback_program       = w_repid
959                 i_callback_pf_status_set = 'ALV_PFST'
960                 i_callback_user_command  = 'MAKE_COMMAND'
961                 is_layout                = is_layout
962                 it_fieldcat              = ist_fcat[]
963    *            it_sort                  =            " data of ist_srcbsik already arranged in reqd grouping
964                 it_events                = gt_events
965                 i_save                   = 'A'
966            TABLES
967                 t_outtab                 = ist_srcbsik
968    * Begin of Changes on 20-Jun-2013
969           EXCEPTIONS
970                program_error = 1
971                OTHERS        = 2.
972    * End of Changes on 20-Jun-2013
973      IF sy-subrc <> 0.
974    *    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
975    *            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
976      ENDIF.
977
978
979    ENDFORM.                    " PRINT_MULTI_ALV
980    *End of <RD1K967585> CAB_ALOK 27.11.2009 CR30002778
981
982    *---------------------------------------------------------------------*
983    *       FORM alv_pfst                                                 *
984    *---------------------------------------------------------------------*
985    *       ........                                                      *
986    *---------------------------------------------------------------------*
987    *  -->  RT_EXTAB                                                      *
988    *---------------------------------------------------------------------*
989    FORM alv_pfst USING rt_extab TYPE slis_t_extab.
990      IF  p_x2sp = 'X'.
991        SET PF-STATUS 'S100'.
992      ELSE.
993        SET PF-STATUS 'S200'.
994      ENDIF.
995    ENDFORM.                    "alv_pfst
996
997    *---------------------------------------------------------------------*
998    *       FORM make_command                                             *
999    *---------------------------------------------------------------------*
1000   *       ........                                                      *
1001   *---------------------------------------------------------------------*
1002   *  -->  R_UCOMM                                                       *
1003   *  -->  RS_SELFIELD                                                   *
1004   *---------------------------------------------------------------------*
1005   FORM make_command USING r_ucomm LIKE sy-ucomm
1006                           rs_selfield TYPE slis_selfield.
1007   *-----------------------------------------------------*
1008   *-----------------------------------------------------*
1009   *  break cab_alok.
1010     DATA : index_aux LIKE sy-tabix.
1011     index_aux = rs_selfield-tabindex.
1012
1013     CASE r_ucomm.
1014
1015       WHEN 'REL'.
1016   *Begin of <RD1K981426> CAB_RAMA CR 30007673
1017         ist_srcbsik_l[] = ist_srcbsik[].
1018         IF p_x2sp = 'X'.
1019           LOOP AT ist_srcbsik INTO wa_srcbsik WHERE selcbox = 'X' AND kidno <> 'PERIOD END LIABILITY'.
1020             IF  ( wa_srcbsik-bschl = '31' OR wa_srcbsik-bschl = '34' OR wa_srcbsik-bschl = '36'
1021               OR wa_srcbsik-bschl = '39' OR wa_srcbsik-bschl = '21' OR wa_srcbsik-bschl = '26').
1022               LOOP AT ist_srcbsik_l INTO wa_srcbsik_l
1023                 WHERE selcbox <> 'X' AND ( bschl = '31' OR bschl = '34' OR bschl = '36' OR bschl = '39'
1024                 OR bschl = '21'  OR bschl = '26' )
1025                 AND kidno = wa_srcbsik-kidno
1026                 AND kidno <> 'PERIOD END LIABILITY'
1027                 AND lifnr = wa_srcbsik-lifnr.
1028
1029                 MESSAGE e100(zfi) WITH text-010.
1030               ENDLOOP.
1031             ENDIF.
1032           ENDLOOP.
1033         ENDIF.
1034   *END of <RD1K981426> CAB_RAMA CR 30007673
1035   **{begin of 30007662
1036   *      data :g_budget type bseg-dmbtr,
1037   *            g_budget_c(16)," type bseg-dmbtr,
1038   **            l_budget type bseg-dmbtr,
1039   *            g_dmbtr type bseg-dmbtr.
1040         IF p_x2sp = 'X'.
1041   *        sort ist_srcbsik_l by lifnr bukrs gjahr belnr bschl zlsch fipos fistl.
1042           LOOP AT ist_srcbsik_l INTO wa_srcbsik_l WHERE selcbox = 'X' AND
1043             shkzg = 'H' AND
1044            ( ( blart = 'NI' AND bschl = '39' AND umskz = 'F' )
1045             OR ( belnr = wa_srcbsik_l-belnr AND zlsch = 'L' ) ) .
1046             CLEAR :g_budget,g_budget_c,g_dmbtr.
1047   *{
1048             DATA : wa_xbseg TYPE bseg.
1049
1050             DATA : l_eindt   TYPE sy-datum, "eket-eindt,
1051                    l_year_max TYPE bkpf-gjahr,
1052                    l_year_budat TYPE bkpf-gjahr,
1053                    l_year_curr TYPE bkpf-gjahr.
1054
1055             DATA : l_fikrs  TYPE fkrs-fikrs,
1056                    l_budget TYPE fmit-hsl16.
1057
1058             DATA : l_fistl TYPE fistl,    "ekpo-fistl
1059                    l_fipos TYPE fm_fipex. "ekpo-fipos.
1060
1061             DATA : l_bukrs TYPE t001-bukrs,
1062                    l_budat TYPE sy-datum,
1063                    ist_fmavc001 TYPE TABLE OF fmavc001,
1064                    wa_fmavc001  TYPE fmavc001.
1065
1066             DATA : l_dmbtr TYPE bseg-dmbtr.
1067
1068             LOOP AT ist_srcbsik INTO wa_srcbsik
1069               WHERE belnr = wa_srcbsik_l-belnr
1070               AND fipos = wa_srcbsik_l-fipos
1071               AND fistl = wa_srcbsik_l-fistl
1072               AND shkzg = 'H'.
1073
1074               IF wa_srcbsik-shkzg = 'H'.
1075                 g_dmbtr = wa_srcbsik-dmbtr * ( -1 ) + g_dmbtr.
1076               ELSEIF wa_srcbsik-shkzg = 'S'.
1077                 g_dmbtr = wa_srcbsik-dmbtr + g_dmbtr.
1078               ENDIF.
1079             ENDLOOP.
1080
1081             SELECT MAX( gjahr ) FROM fmioi INTO l_year_max
1082                   WHERE refbn = wa_srcbsik_l-ebeln AND
1083                         rfpos = wa_srcbsik_l-ebelp AND
1084                         cfstat IN ('00','32').
1085             SELECT SINGLE bukrs budat FROM bkpf
1086               INTO (l_bukrs,l_budat)
1087               WHERE bukrs = wa_srcbsik_l-bukrs
1088                                  AND belnr = wa_srcbsik_l-belnr
1089                                  AND gjahr = wa_srcbsik_l-gjahr .
1090
1091             CALL FUNCTION 'FI_PERIOD_DETERMINE'
1092               EXPORTING
1093                 i_budat     = l_budat
1094                 i_periv     = 'V3'
1095               IMPORTING
1096                 e_gjahr     = l_year_budat
1097               EXCEPTIONS
1098                 fiscal_year = 1.
1099
1100             IF sy-subrc <> 0.
1101   *       MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
1102   *               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
1103             ENDIF.
1104
1105
1106             CALL FUNCTION 'FI_PERIOD_DETERMINE'
1107               EXPORTING
1108                 i_budat     = sy-datum
1109                 i_periv     = 'V3'
1110               IMPORTING
1111                 e_gjahr     = l_year_curr
1112               EXCEPTIONS
1113                 fiscal_year = 1.
1114
1115             IF ( l_year_curr EQ l_year_budat ) AND ( l_year_budat EQ l_year_max ).
1116   *no action
1117             ELSEIF ( l_year_curr GT l_year_budat ) AND  ( l_year_budat EQ l_year_max ).
1118   *check FM for l_year_curr
1119               PERFORM get_budget USING 'ONGC' wa_srcbsik_l-fistl wa_srcbsik_l-fipos l_year_curr
1120                                      CHANGING g_budget.
1121               IF g_dmbtr > g_budget.
1122                 MESSAGE e100(zfi) WITH text-011 wa_srcbsik_l-fistl wa_srcbsik_l-fipos  .
1123               ENDIF.
1124             ELSEIF ( l_year_curr EQ l_year_budat ) AND ( l_year_budat GT l_year_max ).
1125   *check FM for l_year_curr
1126               PERFORM get_budget USING 'ONGC' wa_srcbsik_l-fistl wa_srcbsik_l-fipos l_year_curr
1127                                      CHANGING g_budget.
1128               IF g_dmbtr > g_budget.
1129                 MESSAGE e100(zfi) WITH text-011 wa_srcbsik_l-fistl wa_srcbsik_l-fipos  .
1130               ENDIF.
1131             ELSEIF ( l_year_curr GT l_year_budat ) AND ( l_year_budat NE l_year_max ).
1132   *check FM for l_year_curr
1133               PERFORM get_budget USING 'ONGC' wa_srcbsik_l-fistl wa_srcbsik_l-fipos l_year_curr
1134                                      CHANGING g_budget.
1135               IF g_dmbtr > g_budget.
1136                 MESSAGE e100(zfi) WITH text-011 wa_srcbsik_l-fistl wa_srcbsik_l-fipos  .
1137               ENDIF.
1138             ENDIF.
1139           ENDLOOP.
1140         ENDIF.
1141
1142   *}end of 30007662
1143         DELETE ist_srcbsik WHERE  selcbox <> 'X'.
1144
1145
1146   *Begin of <RD1K975843> CAB_ALOK CR 30005441
1147   ** Validation for credit memo
1148         IF p_x2sp = 'X'.
1149           PERFORM validate_liab_doc_credit_memo.
1150         ENDIF.
1151   *End of <RD1K975843> CAB_ALOK CR 30005441
1152         PERFORM   get_upd_bsik.
1153         PERFORM   get_upd_bseg.
1154   *Begin of <RD1K967585> CAB_ALOK 09.12.2009 CR30002778
1155         PERFORM   update_zfi_rem_pyblck_l.    "update logs
1156   *Begin of <RD1K967585> CAB_ALOK 09.12.2009 CR30002778
1157         LEAVE SCREEN.
1158
1159       WHEN 'ALL'.
1160         PERFORM  select_all.
1161       WHEN 'SAL'.
1162         PERFORM  deselect_all.
1163
1164       WHEN '&F03' OR 'BACK' .
1165         LEAVE  PROGRAM.
1166   *Begin of <RD1K967585> CAB_ALOK 03.12.2009 CR30002778
1167       WHEN 'REP'.
1168         PERFORM display_inactive_alv.
1169   *End of <RD1K967585> CAB_ALOK 03.12.2009 CR30002778
1170
1171     ENDCASE.
1172
1173   ENDFORM.                    "make_command
1174   *---------------------------------------------------------------------*
1175   *&      Form  select_all
1176   *&---------------------------------------------------------------------*
1177   *       text
1178   *----------------------------------------------------------------------*
1179   *  -->  p1        text
1180   *  <--  p2        text
1181   *----------------------------------------------------------------------*
1182   FORM select_all.
1183     LOOP AT ist_srcbsik.
1184       ist_srcbsik-selcbox = 'X'.
1185       MODIFY ist_srcbsik.
1186     ENDLOOP.
1187
1188   ENDFORM.                    " select_all
1189   *&---------------------------------------------------------------------*
1190   *&      Form  deselect_all
1191   *&---------------------------------------------------------------------*
1192   *       text
1193   *----------------------------------------------------------------------*
1194   *  -->  p1        text
1195   *  <--  p2        text
1196   *----------------------------------------------------------------------*
1197   FORM deselect_all.
1198     LOOP AT ist_srcbsik.
1199       ist_srcbsik-selcbox = ' '.
1200       MODIFY ist_srcbsik.
1201     ENDLOOP.
1202   ENDFORM.                    " deselect_all
1203   *&---------------------------------------------------------------------
1204   *&---------------------------------------------------------------------*
1205   *&      Form  get_upd_bsik
1206   *&---------------------------------------------------------------------*
1207   *       text
1208   *----------------------------------------------------------------------*
1209   *  -->  p1        text
1210   *  <--  p2        text
1211   *----------------------------------------------------------------------*
1212   FORM get_upd_bsik.
1213
1214     DATA : l_tabix  TYPE sy-tabix.
1215
1216     CHECK NOT ist_srcbsik[] IS INITIAL.
1217
1218     SELECT * INTO TABLE ist_bsik   FROM bsik
1219       FOR ALL ENTRIES  IN  ist_srcbsik
1220       WHERE   lifnr = ist_srcbsik-lifnr
1221             AND  bukrs  =  p_bukrs
1222              AND gjahr = ist_srcbsik-gjahr
1223              AND belnr = ist_srcbsik-belnr
1224              AND buzei = ist_srcbsik-buzei.
1225   *------------X  to blank
1226     IF NOT ist_bsik IS INITIAL.
1227       IF p_x2sp = 'X'.
1228         LOOP AT ist_bsik INTO wa_bsik.
1229           l_tabix =   sy-tabix .
1230           IF wa_bsik-zlspr =  g_zlspr_x.
1231             wa_bsik-zlspr =  space.
1232             MODIFY ist_bsik  FROM  wa_bsik INDEX l_tabix  TRANSPORTING zlspr.
1233           ENDIF.
1234         ENDLOOP.
1235   "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
1236
1237   *      MODIFY  bsik FROM TABLE ist_bsik.
1238   "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
1239         COMMIT WORK.
1240       ENDIF.
1241
1242   *---------------blank to X
1243       IF p_sp2x = 'X'.
1244         LOOP AT ist_bsik INTO wa_bsik.
1245           l_tabix =   sy-tabix .
1246           IF wa_bsik-zlspr =  g_zlspr_sp.
1247             wa_bsik-zlspr =  'X'.
1248             MODIFY ist_bsik  FROM  wa_bsik INDEX l_tabix  TRANSPORTING zlspr
1249      .
1250           ENDIF.
1251         ENDLOOP.
1252   "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
1253   *      MODIFY  bsik FROM TABLE ist_bsik.
1254   "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
1255         COMMIT WORK.
1256       ENDIF.
1257   *---------+003
1258   *------------------Blank to R
1259       IF p_sp2r = 'X'.
1260         LOOP AT ist_bsik INTO wa_bsik.
1261           l_tabix =   sy-tabix .
1262           IF wa_bsik-zlspr =  g_zlspr_sp.
1263             wa_bsik-zlspr =  g_zlspr_r.
1264             MODIFY ist_bsik  FROM  wa_bsik INDEX l_tabix  TRANSPORTING zlspr.
1265           ENDIF.
1266         ENDLOOP.
1267
1268   "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
1269   *      MODIFY  bsik FROM TABLE ist_bsik.
1270   "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
1271         COMMIT WORK.
1272       ENDIF.
1273
1274   *------------Blank to S
1275   *  IF p_sp2s = 'X'.
1276   *      LOOP AT ist_bsik INTO wa_bsik.
1277   *        l_tabix =   sy-tabix .
1278   *        IF wa_bsik-zlspr =  g_zlspr_sp.
1279   *          wa_bsik-zlspr =  g_zlspr_s.
1280   *       MODIFY ist_bsik  FROM  wa_bsik INDEX l_tabix  TRANSPORTING zlspr.
1281   *        ENDIF.
1282   *      ENDLOOP.
1283   *
1284   *      MODIFY  bsik FROM TABLE ist_bsik.
1285   *
1286   *      COMMIT WORK.
1287   *    ENDIF.
1288
1289   *----------------X to S
1290       IF p_x2s = 'X'.
1291         LOOP AT ist_bsik INTO wa_bsik.
1292           l_tabix =   sy-tabix .
1293           IF wa_bsik-zlspr =  g_zlspr_x  OR wa_bsik-zlspr =  g_zlspr_sp.
1294             wa_bsik-zlspr =  g_zlspr_s.
1295             MODIFY ist_bsik  FROM  wa_bsik INDEX l_tabix  TRANSPORTING zlspr.
1296           ENDIF.
1297         ENDLOOP.
1298   "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
1299   *      MODIFY  bsik FROM TABLE ist_bsik.
1300   "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
1301         COMMIT WORK.
1302       ENDIF.
1303
1304   * Begin of RD1K971966 CAB_ALOK CR30004183
1305   **-----------S to X
1306   *    IF p_s2x = 'X'.
1307   *      LOOP AT ist_bsik INTO wa_bsik.
1308   *        l_tabix =   sy-tabix .
1309   *        IF wa_bsik-zlspr =  g_zlspr_s.
1310   *          wa_bsik-zlspr =  g_zlspr_x.
1311   *          MODIFY ist_bsik  FROM  wa_bsik INDEX l_tabix  TRANSPORTING zlspr.
1312   *        ENDIF.
1313   *      ENDLOOP.
1314   *
1315   *      MODIFY  bsik FROM TABLE ist_bsik.
1316   *
1317   *      COMMIT WORK.
1318   *    ENDIF.
1319   * End of RD1K971966 CAB_ALOK CR30004183
1320
1321   *-------+003
1322     ENDIF.
1323   *  LEAVE SCREEN.
1324   ENDFORM.                    " get_upd_bsik
1325   *
1326   *&---------------------------------------------------------------------*
1327   *&      Form  get_upd_bseg
1328   *&---------------------------------------------------------------------*
1329   *       text
1330   *----------------------------------------------------------------------*
1331   *  -->  p1        text
1332   *  <--  p2        text
1333   *----------------------------------------------------------------------*
1334   FORM get_upd_bseg.
1335     DATA : l_tabix  TYPE sy-tabix.
1336
1337     CHECK NOT ist_srcbsik[] IS INITIAL.
1338
1339     SELECT * INTO TABLE ist_bseg   FROM bseg
1340       FOR ALL ENTRIES  IN  ist_srcbsik
1341       WHERE
1342              bukrs  =  p_bukrs
1343        AND   belnr = ist_srcbsik-belnr
1344        AND   gjahr = ist_srcbsik-gjahr
1345        AND   buzei = ist_srcbsik-buzei ORDER BY PRIMARY KEY.
1346
1347     IF NOT ist_bseg IS INITIAL.
1348   *---------------  X to Blank
1349       IF p_x2sp = 'X'.
1350         LOOP AT ist_bseg INTO wa_bseg.
1351           l_tabix =   sy-tabix .
1352           IF wa_bseg-zlspr =  g_zlspr_x.
1353             wa_bseg-zlspr =   g_zlspr_sp.
1354             MODIFY ist_bseg  FROM  wa_bseg INDEX l_tabix  TRANSPORTING zlspr.
1355           ENDIF.
1356         ENDLOOP.
1357
1358   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1359   * S/4: BSEG payment block (ZLSPR) via FI_DOCUMENT_CHANGE (FB02); direct write not allowed.
1360   *      MODIFY bseg FROM TABLE ist_bseg.
1361         LOOP AT ist_bseg INTO wa_bseg.
1362           PERFORM zz_s4_bseg_zlspr USING wa_bseg-bukrs wa_bseg-belnr wa_bseg-gjahr wa_bseg-buzei wa_bseg-zlspr.
1363         ENDLOOP.
1364         COMMIT WORK.
1365   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1366
1367       ENDIF.
1368   *------------space to X
1369       IF p_sp2x = 'X'.
1370         LOOP AT ist_bseg INTO wa_bseg.
1371           l_tabix =   sy-tabix .
1372           IF wa_bseg-zlspr =  g_zlspr_sp.
1373             wa_bseg-zlspr =  g_zlspr_x.
1374             MODIFY ist_bseg  FROM  wa_bseg INDEX l_tabix  TRANSPORTING zlspr.
1375           ENDIF.
1376         ENDLOOP.
1377
1378   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1379   * S/4: BSEG payment block (ZLSPR) via FI_DOCUMENT_CHANGE (FB02); direct write not allowed.
1380   *      MODIFY bseg FROM TABLE ist_bseg.
1381         LOOP AT ist_bseg INTO wa_bseg.
1382           PERFORM zz_s4_bseg_zlspr USING wa_bseg-bukrs wa_bseg-belnr wa_bseg-gjahr wa_bseg-buzei wa_bseg-zlspr.
1383         ENDLOOP.
1384         COMMIT WORK.
1385   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1386
1387       ENDIF.
1388   *----+003
1389   *------Blank to R
1390
1391
1392       IF p_sp2r = 'X'.
1393         LOOP AT ist_bseg INTO wa_bseg.
1394           l_tabix =   sy-tabix .
1395           IF wa_bseg-zlspr =  g_zlspr_sp.
1396             wa_bseg-zlspr =  g_zlspr_r.
1397             MODIFY ist_bseg  FROM  wa_bseg INDEX l_tabix  TRANSPORTING zlspr.
1398           ENDIF.
1399         ENDLOOP.
1400
1401   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1402   * S/4: BSEG payment block (ZLSPR) via FI_DOCUMENT_CHANGE (FB02); direct write not allowed.
1403   *      MODIFY  bseg FROM TABLE ist_bseg.
1404         LOOP AT ist_bseg INTO wa_bseg.
1405           PERFORM zz_s4_bseg_zlspr USING wa_bseg-bukrs wa_bseg-belnr wa_bseg-gjahr wa_bseg-buzei wa_bseg-zlspr.
1406         ENDLOOP.
1407         COMMIT WORK.
1408   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1409
1410         COMMIT WORK.
1411       ENDIF.
1412
1413   **------Blank to S
1414
1415   *  IF p_sp2s = 'X'.
1416   *      LOOP AT ist_bseg INTO wa_bseg.
1417   *        l_tabix =   sy-tabix .
1418   *        IF wa_bseg-zlspr =  g_zlspr_sp.
1419   *          wa_bseg-zlspr =  g_zlspr_s.
1420   *       MODIFY ist_bseg  FROM  wa_bseg INDEX l_tabix  TRANSPORTING zlspr.
1421   *        ENDIF.
1422   *      ENDLOOP.
1423   *
1424   *      MODIFY  bseg FROM TABLE ist_bseg.
1425   *
1426   *      COMMIT WORK.
1427   *    ENDIF.
1428
1429   *-------X  to S  and  Blank TO S
1430       IF p_x2s = 'X'.
1431         LOOP AT ist_bseg INTO wa_bseg.
1432           l_tabix =   sy-tabix .
1433   * begin RD1K975843 CAB_ALOK
1434   *        IF wa_bsik-zlspr =  g_zlspr_x  OR wa_bsik-zlspr =  g_zlspr_sp.
1435           IF wa_bseg-zlspr =  g_zlspr_x  OR wa_bseg-zlspr =  g_zlspr_sp.
1436   * end RD1K975843 CAB_ALOK
1437             wa_bseg-zlspr =  g_zlspr_s.
1438             MODIFY ist_bseg  FROM  wa_bseg INDEX l_tabix  TRANSPORTING zlspr.
1439           ENDIF.
1440         ENDLOOP.
1441
1442   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1443   * S/4: BSEG payment block (ZLSPR) via FI_DOCUMENT_CHANGE (FB02); direct write not allowed.
1444   *      MODIFY  bseg FROM TABLE ist_bseg.
1445         LOOP AT ist_bseg INTO wa_bseg.
1446           PERFORM zz_s4_bseg_zlspr USING wa_bseg-bukrs wa_bseg-belnr wa_bseg-gjahr wa_bseg-buzei wa_bseg-zlspr.
1447         ENDLOOP.
1448         COMMIT WORK.
1449   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1450
1451         COMMIT WORK.
1452       ENDIF.
1453   * Begin of RD1K971966 CAB_ALOK CR30004183
1454   **------------------------S To X
1455   *    IF p_s2x = 'X'.
1456   *      LOOP AT ist_bseg INTO wa_bseg.
1457   *        l_tabix =   sy-tabix .
1458   *        IF wa_bseg-zlspr =  g_zlspr_s.
1459   *          wa_bseg-zlspr =  g_zlspr_x.
1460   *          MODIFY ist_bseg  FROM  wa_bseg INDEX l_tabix  TRANSPORTING zlspr.
1461   *        ENDIF.
1462   *      ENDLOOP.
1463   *
1464   *      MODIFY  bseg FROM TABLE ist_bseg.
1465   *
1466   *      COMMIT WORK.
1467   *    ENDIF.
1468   * End of RD1K971966 CAB_ALOK CR30004183
1469   *------+003
1470     ENDIF.
1471
1472
1473
1474   ENDFORM.                    " get_upd_bseg
1475   *&---------------------------------------------------------------------*
1476   *&      Form  get_docs
1477   *&---------------------------------------------------------------------*
1478   *       text
1479   *----------------------------------------------------------------------*
1480   *  -->  p1        text
1481   *  <--  p2        text
1482   *----------------------------------------------------------------------*
1483   FORM get_docs.
1484     SELECT bukrs lifnr umskz gjahr belnr buzei budat bschl zlsch
1485   * begin of < RD1K970594> CAB_ALOK 10.03.2010 CR30003739
1486   *   zlspr shkzg gsber dmbtr wrbtr kidno rebzg APPENDING
1487      zlspr shkzg gsber dmbtr wrbtr waers kidno rebzg
1488   * end of < RD1K970594> CAB_ALOK 10.03.2010 CR30003739
1489   * begin RD1K975843 CAB_ALOK CR 30005441
1490      zfbdt rebzz
1491   * end RD1K975843 CAB_ALOK CR 30005441
1492   *{30007662
1493      blart fipos fistl
1494   *}30007662
1495   *{
1496       ebeln ebelp
1497   *}
1498    APPENDING CORRESPONDING FIELDS OF TABLE
1499                   ist_srcbsik  FROM bsik
1500                   WHERE bukrs  =  p_bukrs
1501                   AND lifnr  IN s_lifnr
1502                   AND gjahr IN s_year
1503   *begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
1504   *                AND gsber IN s_gsber
1505   *end of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
1506   * begin RD1K975843 CAB_ALOK      CR 30005441
1507                   AND belnr IN s_belnr
1508   * end RD1K975843 CAB_ALOK      CR 30005441
1509                   AND budat IN  s_budat.  "#EC CI_NOORDER
1510
1511
1512
1513     IF p_x2sp = 'X'.
1514       DELETE  ist_srcbsik WHERE zlspr <> g_zlspr_x.
1515     ELSEIF p_sp2x = 'X'.
1516       DELETE  ist_srcbsik WHERE NOT  zlspr IS INITIAL.
1517   *-----+003
1518     ELSEIF p_sp2r = 'X'.
1519       DELETE  ist_srcbsik WHERE NOT  zlspr IS INITIAL.
1520     ELSEIF p_x2s = 'X'.
1521       DELETE  ist_srcbsik WHERE ( zlspr <> g_zlspr_x AND zlspr  <>
1522   g_zlspr_sp ).
1523   * Begin of RD1K971966 CAB_ALOK CR30004183
1524   *  ELSEIF p_s2x = 'X'.
1525   *    DELETE  ist_srcbsik WHERE zlspr <> g_zlspr_s.
1526   * end of RD1K971966 CAB_ALOK CR30004183
1527
1528   *  ELSEIF p_sp2s = 'X'.
1529   *    DELETE  ist_srcbsik WHERE NOT  zlspr IS initial.
1530     ENDIF.
1531   *---+003
1532   *  *Start of addition Prabu K on 03.07.2009
1533     DATA wa_bkpf TYPE bkpf.
1534     LOOP AT ist_srcbsik INTO wa_srcbsik.
1535
1536       SELECT SINGLE * FROM bkpf INTO wa_bkpf WHERE bukrs = wa_srcbsik-bukrs AND belnr = wa_srcbsik-belnr
1537          AND xref1_hd IN s_xref1.  "#EC CI_NOORDER
1538       IF sy-subrc NE 0.
1539         DELETE TABLE ist_srcbsik FROM wa_srcbsik.
1540       ELSE.
1541         wa_srcbsik-xref1_hd = wa_bkpf-xref1_hd.
1542         MODIFY ist_srcbsik FROM wa_srcbsik.
1543       ENDIF.
1544     ENDLOOP.
1545   *  End of addition Prabu K on 03.07.2009
1546     IF NOT s_usnam   IS INITIAL.
1547       IF NOT ist_srcbsik[] IS INITIAL.
1548         SELECT blart usnam ppnam belnr gjahr bldat budat waers bukrs
1549                           INTO CORRESPONDING FIELDS OF TABLE ist_bkpf
1550                            FROM  bkpf
1551                           FOR ALL ENTRIES IN ist_srcbsik
1552   *                     FROM bkpf
1553                    WHERE bukrs = ist_srcbsik-bukrs
1554                    AND  gjahr = ist_srcbsik-gjahr
1555                    AND  belnr = ist_srcbsik-belnr
1556                    AND  budat = ist_srcbsik-budat
1557                    AND ( usnam IN s_usnam  OR usnam EQ 'WF-BATCH' ).  "#EC CI_NOORDER
1558       ENDIF.
1559
1560       IF NOT ist_bkpf[] IS INITIAL.
1561
1562         LOOP AT ist_bkpf WHERE usnam = 'WF-BATCH' .
1563           MOVE-CORRESPONDING ist_bkpf TO y_doc_nos .
1564           MOVE ist_bkpf-usnam TO y_doc_nos-usrel .
1565           APPEND y_doc_nos .
1566         ENDLOOP.
1567
1568         CALL FUNCTION 'Z_FI_GET_REL_USERNAME'
1569           TABLES
1570             y_doc_nos = y_doc_nos
1571             f_doc_nos = f_doc_nos.
1572   *           EXCEPTIONS
1573   *                not_found = 1
1574   *                OTHERS    = 2.
1575
1576         LOOP AT ist_bkpf .
1577           READ TABLE y_doc_nos WITH KEY bukrs = ist_bkpf-bukrs
1578                                         belnr = ist_bkpf-belnr
1579                                         gjahr = ist_bkpf-gjahr.
1580           IF sy-subrc EQ 0 .
1581             ist_bkpf-usnam = y_doc_nos-usrel .
1582             MODIFY ist_bkpf TRANSPORTING usnam .
1583           ENDIF .
1584         ENDLOOP.
1585
1586
1587         LOOP AT ist_srcbsik.
1588           READ TABLE ist_bkpf WITH KEY bukrs = ist_srcbsik-bukrs
1589                                    belnr = ist_srcbsik-belnr
1590                                    gjahr = ist_srcbsik-gjahr .
1591           IF sy-subrc = 0.
1592             ist_srcbsik-usnam = ist_bkpf-usnam.
1593             MODIFY ist_srcbsik  TRANSPORTING usnam .
1594           ENDIF.
1595         ENDLOOP.
1596
1597         IF NOT s_usnam IS  INITIAL.
1598           DELETE ist_srcbsik WHERE  NOT usnam  IN s_usnam.
1599         ENDIF.
1600
1601       ENDIF.
1602
1603     ENDIF.
1604
1605     ist_bsiks[] = ist_srcbsik[].
1606
1607
1608     REFRESH ist_srcbsik.
1609     CLEAR ist_srcbsik.
1610
1611
1612     LOOP AT ist_bsiks .
1613       IF ist_bsiks-umskz = 'P' OR ist_bsiks-umskz = 'F'  OR
1614       ist_bsiks-umskz = ':' OR                                " +002
1615       ist_bsiks-umskz  IS INITIAL.
1616         ist_srcbsik = ist_bsiks.
1617         APPEND ist_srcbsik.
1618         CLEAR ist_srcbsik.
1619       ENDIF.
1620     ENDLOOP.
1621
1622
1623
1624     CHECK  NOT ist_srcbsik[] IS INITIAL.
1625
1626     LOOP AT ist_srcbsik.
1627       IF ist_srcbsik-shkzg = 'S'.
1628         ist_srcbsik-dmbtr = ist_srcbsik-dmbtr.
1629         ist_srcbsik-wrbtr = ist_srcbsik-wrbtr.
1630       ELSEIF ist_srcbsik-shkzg = 'H'.
1631         ist_srcbsik-dmbtr = - ist_srcbsik-dmbtr.
1632         ist_srcbsik-wrbtr = - ist_srcbsik-wrbtr.
1633       ENDIF.
1634       MODIFY ist_srcbsik .
1635     ENDLOOP.
1636
1637     ist_bsiks[] = ist_srcbsik[].
1638
1639     SORT ist_srcbsik BY lifnr bschl belnr budat.
1640
1641   ENDFORM.                    " get_docs
1642   *&---------------------------------------------------------------------*
1643   *&      Form  authority_check
1644   *&---------------------------------------------------------------------*
1645   *       text
1646   *----------------------------------------------------------------------*
1647   *      -->P_0446   text
1648   *----------------------------------------------------------------------*
1649   FORM authority_check USING    p_actvt.
1650     AUTHORITY-CHECK OBJECT 'ZFIBLOCKR'
1651                ID 'ACTVT' FIELD p_actvt.
1652     IF sy-subrc <> 0.
1653       MESSAGE  e077(s#) WITH 'ZFIBLOCKR' .
1654     ENDIF.
1655
1656   ENDFORM.                    " authority_check
1657   *&---------------------------------------------------------------------*
1658   *&      Form  authority_check_x
1659   *&---------------------------------------------------------------------*
1660   *       text
1661   *----------------------------------------------------------------------*
1662   *      -->P_0461   text
1663   *----------------------------------------------------------------------*
1664   FORM authority_check_x USING    value(p_0461).
1665     AUTHORITY-CHECK OBJECT 'ZFIBLOCKX'
1666                ID 'ACTVT' FIELD p_0461.
1667     IF sy-subrc <> 0.
1668       MESSAGE  e077(s#) WITH 'ZFIBLOCKX'.
1669     ENDIF.
1670   ENDFORM.                    " authority_check_x
1671   *----------Start of <RD1K960891>
1672
1673   *&---------------------------------------------------------------------*
1674   *&      Form  get_docs_cust
1675   *&---------------------------------------------------------------------*
1676   *       text
1677   *----------------------------------------------------------------------*
1678   *  -->  p1        text
1679   *  <--  p2        text
1680   *----------------------------------------------------------------------*
1681   FORM get_docs_cust.
1682     SELECT bukrs kunnr umskz gjahr belnr buzei budat bschl zlsch
1683   *begin of <RD1K967585> CAB_ALOK 26.11.2009 CR30002778
1684   *     zlspr shkzg gsber dmbtr wrbtr kidno APPENDING
1685   *  begin of < RD1K970594> CAB_ALOK 10.03.2010 CR30003739
1686   *     zlspr shkzg gsber dmbtr wrbtr kidno rebzg APPENDING
1687        zlspr shkzg gsber dmbtr wrbtr waers kidno rebzg APPENDING
1688   * end
1689   *end of <RD1K967585> CAB_ALOK 26.11.2009 CR30002778
1690       CORRESPONDING FIELDS OF TABLE
1691                     ist_srcbsid  FROM bsid
1692                     WHERE
1693                     bukrs  =  p_bukrs
1694                     AND kunnr  IN s_kunnr
1695                     AND gjahr IN s_year
1696   *begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
1697   *                  AND gsber IN s_gsber
1698   *end of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
1699   * begin RD1K975843 CAB_ALOK      CR 30005441
1700                    AND belnr IN s_belnr
1701   * end RD1K975843 CAB_ALOK      CR 30005441
1702                     AND budat IN  s_budat.  "#EC CI_NOORDER
1703
1704
1705
1706     IF p_x2sp = 'X'.
1707       DELETE  ist_srcbsid WHERE zlspr <> g_zlspr_x.
1708     ELSEIF p_sp2x = 'X'.
1709       DELETE  ist_srcbsid WHERE NOT  zlspr IS INITIAL.
1710   *-----+003
1711     ELSEIF p_sp2r = 'X'.
1712       DELETE  ist_srcbsid WHERE NOT  zlspr IS INITIAL.
1713     ELSEIF p_x2s = 'X'.
1714       DELETE  ist_srcbsid WHERE ( zlspr <> g_zlspr_x AND zlspr  <>
1715   g_zlspr_sp ).
1716   * Begin of RD1K971966 CAB_ALOK CR30004183
1717   *  ELSEIF p_s2x = 'X'.
1718   *    DELETE  ist_srcbsid WHERE zlspr <> g_zlspr_s.
1719   * End of RD1K971966 CAB_ALOK CR30004183
1720   *  ELSEIF p_sp2s = 'X'.
1721   *    DELETE  ist_srcbsid WHERE NOT  zlspr IS initial.
1722     ENDIF.
1723   *---+003
1724
1725   *  *Start of addition Prabu K on 03.07.2009
1726     DATA wa_bkpf TYPE bkpf.
1727     LOOP AT ist_srcbsid INTO wa_srcbsid.
1728
1729       SELECT SINGLE * FROM bkpf INTO wa_bkpf WHERE bukrs = wa_srcbsid-bukrs AND belnr = wa_srcbsid-belnr
1730          AND xref1_hd IN s_xref1.  "#EC CI_NOORDER
1731       IF sy-subrc NE 0.
1732         DELETE TABLE ist_srcbsid FROM wa_srcbsid.
1733       ELSE.
1734         wa_srcbsid-xref1_hd = wa_bkpf-xref1_hd.
1735         MODIFY ist_srcbsid FROM wa_srcbsid.
1736       ENDIF.
1737
1738     ENDLOOP.
1739   *  End  of addition Prabu K on 03.07.2009
1740     IF NOT s_usnam   IS INITIAL.
1741       IF NOT ist_srcbsid[] IS INITIAL.
1742         SELECT blart usnam ppnam belnr gjahr bldat budat waers bukrs
1743                           INTO CORRESPONDING FIELDS OF TABLE ist_bkpf
1744                            FROM  bkpf
1745                           FOR ALL ENTRIES IN ist_srcbsid
1746   *                     FROM bkpf
1747                    WHERE bukrs = ist_srcbsid-bukrs
1748                    AND  gjahr = ist_srcbsid-gjahr
1749                    AND  belnr = ist_srcbsid-belnr
1750                    AND  budat = ist_srcbsid-budat
1751                    AND ( usnam IN s_usnam  OR usnam EQ 'WF-BATCH' ).  "#EC CI_NOORDER
1752       ENDIF.
1753
1754       IF NOT ist_bkpf[] IS INITIAL.
1755
1756         LOOP AT ist_bkpf WHERE usnam = 'WF-BATCH' .
1757           MOVE-CORRESPONDING ist_bkpf TO y_doc_nos .
1758           MOVE ist_bkpf-usnam TO y_doc_nos-usrel .
1759           APPEND y_doc_nos .
1760         ENDLOOP.
1761
1762         CALL FUNCTION 'Z_FI_GET_REL_USERNAME'
1763           TABLES
1764             y_doc_nos = y_doc_nos
1765             f_doc_nos = f_doc_nos.
1766   *           EXCEPTIONS
1767   *                not_found = 1
1768   *                OTHERS    = 2.
1769
1770         LOOP AT ist_bkpf .
1771           READ TABLE y_doc_nos WITH KEY bukrs = ist_bkpf-bukrs
1772                                         belnr = ist_bkpf-belnr
1773                                         gjahr = ist_bkpf-gjahr.
1774           IF sy-subrc EQ 0 .
1775             ist_bkpf-usnam = y_doc_nos-usrel .
1776             MODIFY ist_bkpf TRANSPORTING usnam .
1777           ENDIF .
1778         ENDLOOP.
1779
1780
1781         LOOP AT ist_srcbsid.
1782           READ TABLE ist_bkpf WITH KEY bukrs = ist_srcbsid-bukrs
1783                                    belnr = ist_srcbsid-belnr
1784                                    gjahr = ist_srcbsid-gjahr .
1785           IF sy-subrc = 0.
1786             ist_srcbsid-usnam = ist_bkpf-usnam.
1787             MODIFY ist_srcbsid  TRANSPORTING usnam .
1788           ENDIF.
1789         ENDLOOP.
1790
1791         IF NOT s_usnam IS  INITIAL.
1792           DELETE ist_srcbsid WHERE  NOT usnam  IN s_usnam.
1793         ENDIF.
1794
1795       ENDIF.
1796
1797     ENDIF.
1798
1799     ist_bsids[] = ist_srcbsid[].
1800
1801
1802     REFRESH ist_srcbsid.
1803     CLEAR ist_srcbsid.
1804
1805
1806     LOOP AT ist_bsids .
1807   *{001
1808   *    IF ist_bsids-umskz = 'K' OR ist_bsids-umskz = 'H'.
1809       IF ( ist_bsids-umskz = 'K' OR ist_bsids-umskz = 'H'  OR ist_bsids-umskz = 'O') OR
1810   *Start of changes by SOGET - 003
1811   *( ist_bsids-umskz = ' ' and ist_bsids-zlsch = 'P' ).
1812          ( ist_bsids-umskz = ' ' AND ist_bsids-zlsch = 'P' ) OR ( ist_bsids-umskz = ' ' AND ist_bsids-zlsch = 'Q' )
1813   * Begin of <RD1K973788>  CAB_ALOK CR 30004826
1814   * OR   ist_bsids-kunnr BETWEEN 'DS000000001' and 'DS999999999' "Commented, as told by Mr. Kalia
1815   * End of <RD1K973788>  CAB_ALOK CR 30004826
1816         .
1817   *End of changes by SOGET - 003
1818   *}001
1819         ist_srcbsid = ist_bsids.
1820         APPEND ist_srcbsid.
1821         CLEAR ist_srcbsid.
1822       ENDIF.
1823     ENDLOOP.
1824
1825
1826
1827     CHECK  NOT ist_srcbsid[] IS INITIAL.
1828
1829     LOOP AT ist_srcbsid.
1830       IF ist_srcbsid-shkzg = 'S'.
1831         ist_srcbsid-dmbtr = ist_srcbsid-dmbtr.
1832         ist_srcbsid-wrbtr = ist_srcbsid-wrbtr.
1833       ELSEIF ist_srcbsid-shkzg = 'H'.
1834         ist_srcbsid-dmbtr = - ist_srcbsid-dmbtr.
1835         ist_srcbsid-wrbtr = - ist_srcbsid-wrbtr.
1836       ENDIF.
1837       MODIFY ist_srcbsid .
1838     ENDLOOP.
1839
1840     ist_bsids[] = ist_srcbsid[].
1841
1842     SORT ist_srcbsid BY kunnr bschl belnr budat.
1843
1844
1845   ENDFORM.                    " get_docs_cust
1846   *&---------------------------------------------------------------------*
1847   *&      Form  display_docs_cust
1848   *&---------------------------------------------------------------------*
1849   *       text
1850   *----------------------------------------------------------------------*
1851   *  -->  p1        text
1852   *  <--  p2        text
1853   *----------------------------------------------------------------------*
1854   FORM display_docs_cust.
1855     PERFORM init_fieldcat_cust.
1856   *begin of <RD1K967585> CAB_ALOK 26.11.2009 CR30002778
1857   *  make fieldcat for inactive items
1858     PERFORM init_fieldcat_inactiv_cust.
1859   *end of <RD1K967585> CAB_ALOK 26.11.2009 CR30002778
1860     PERFORM eventtab_build_cust TABLES gt_events.
1861   *  PERFORM comment_build USING gt_list_top_of_page[].
1862     PERFORM  sort_build_cust .
1863   *begin of <RD1K967585> CAB_ALOK 26.11.2009 CR30002778
1864   *    PERFORM  print_alv_cust.
1865   *  display multiple list ALV
1866     PERFORM print_multi_alv_cust.
1867   *end of <RD1K967585> CAB_ALOK 26.11.2009 CR30002778
1868
1869
1870
1871   ENDFORM.                    " display_docs_cust
1872   *&---------------------------------------------------------------------*
1873   *&      Form  init_fieldcat_cust
1874   *&---------------------------------------------------------------------*
1875   *       text
1876   *----------------------------------------------------------------------*
1877   *  -->  p1        text
1878   *  <--  p2        text
1879   *----------------------------------------------------------------------*
1880   FORM init_fieldcat_cust.
1881     w_repid  = sy-repid.
1882
1883     mpos = 0.
1884     mpos = mpos + 1.
1885     ist_fieldcat-fieldname = 'SELCBOX'.
1886     ist_fieldcat-tabname = 'IST_SRCBSID'.
1887     ist_fieldcat-ddictxt = 'M'.
1888     ist_fieldcat-col_pos =  mpos.
1889     ist_fieldcat-seltext_m  = 'Select'.
1890     ist_fieldcat-lowercase  = 'Y'.
1891     ist_fieldcat-checkbox = 'X'.
1892     ist_fieldcat-input = 'X'.
1893     APPEND ist_fieldcat TO ist_fcat.
1894     CLEAR ist_fieldcat.
1895
1896     mpos = mpos + 1.
1897     ist_fieldcat-fieldname = 'KUNNR'.
1898     ist_fieldcat-tabname = 'IST_SRCBSID'.
1899     ist_fieldcat-ddictxt = 'M'.
1900     ist_fieldcat-col_pos =  mpos.
1901   *begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
1902   *  ist_fieldcat-seltext_m  = 'CustomerNumber'.
1903     ist_fieldcat-seltext_m  = 'Cstmr No.'.
1904   *end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
1905     ist_fieldcat-lowercase  = 'Y'.
1906     APPEND ist_fieldcat TO ist_fcat.
1907     CLEAR ist_fieldcat.
1908
1909     mpos = mpos + 1.
1910     ist_fieldcat-fieldname = 'BELNR'.
1911     ist_fieldcat-tabname = 'IST_SRCBSID'.
1912     ist_fieldcat-ddictxt = 'M'.
1913     ist_fieldcat-col_pos =  mpos.
1914     ist_fieldcat-seltext_m  = 'Doc.No.'.
1915     ist_fieldcat-lowercase  = 'Y'.
1916     APPEND ist_fieldcat TO ist_fcat.
1917     CLEAR ist_fieldcat.
1918
1919   *begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
1920   *    mpos = mpos + 1.
1921   *  ist_fieldcat-fieldname = 'GSBER'.
1922   *  ist_fieldcat-tabname = 'IST_SRCBSID'.
1923   *  ist_fieldcat-ddictxt = 'M'.
1924   *  ist_fieldcat-col_pos =  mpos.
1925   *  ist_fieldcat-seltext_m  = 'Business Area'.
1926   *  ist_fieldcat-lowercase  = 'Y'.
1927   *  APPEND ist_fieldcat TO ist_fcat.
1928   *  CLEAR ist_fieldcat.
1929   *end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
1930
1931   *---+001
1932     mpos = mpos + 1.
1933     ist_fieldcat-fieldname = 'KIDNO'.
1934     ist_fieldcat-tabname = 'IST_SRCBSID'.
1935     ist_fieldcat-ddictxt = 'M'.
1936     ist_fieldcat-col_pos =  mpos.
1937   *begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
1938   *    ist_fieldcat-seltext_m  = 'Payment Reference'.
1939     ist_fieldcat-seltext_m  = 'Pymt Ref'.
1940   *end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
1941     ist_fieldcat-lowercase  = 'Y'.
1942     APPEND ist_fieldcat TO ist_fcat.
1943     CLEAR ist_fieldcat.
1944   *-------+001
1945   *---+002
1946
1947     mpos = mpos + 1.
1948     ist_fieldcat-fieldname = 'REBZG'.
1949     ist_fieldcat-tabname = 'IST_SRCBSID'.
1950     ist_fieldcat-ddictxt = 'M'.
1951     ist_fieldcat-col_pos =  mpos.
1952   *begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
1953   *    ist_fieldcat-seltext_m  = 'Invoice Reference'.
1954     ist_fieldcat-seltext_m  = 'Inv Ref'.
1955   *end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
1956   *  ist_fieldcat-lowercase  = 'Y'.
1957     APPEND ist_fieldcat TO ist_fcat.
1958     CLEAR ist_fieldcat.
1959
1960   *begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
1961   *  *---testing purpose
1962   *    mpos = mpos + 1.
1963   *  ist_fieldcat-fieldname = 'SHKZG'.
1964   *  ist_fieldcat-tabname = 'IST_SRCBSID'.
1965   *  ist_fieldcat-ddictxt = 'M'.
1966   *  ist_fieldcat-col_pos =  mpos.
1967   *  ist_fieldcat-seltext_m  = 'INdicator'.
1968   **  ist_fieldcat-lowercase  = 'Y'.
1969   *  APPEND ist_fieldcat TO ist_fcat.
1970   *  CLEAR ist_fieldcat.
1971   **-------+002
1972   *    mpos = mpos + 1.
1973   *  ist_fieldcat-fieldname = 'GJAHR'.
1974   *  ist_fieldcat-tabname = 'IST_SRCBSID'.
1975   *  ist_fieldcat-ddictxt = 'M'.
1976   *  ist_fieldcat-col_pos =  mpos.
1977   *  ist_fieldcat-seltext_m  = 'Year'.
1978   *  ist_fieldcat-lowercase  = 'Y'.
1979   *  APPEND ist_fieldcat TO ist_fcat.
1980   *  CLEAR ist_fieldcat.
1981   *end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
1982
1983     mpos = mpos + 1.
1984     ist_fieldcat-fieldname = 'BUZEI'.
1985     ist_fieldcat-tabname = 'IST_SRCBSID'.
1986     ist_fieldcat-ddictxt = 'M'.
1987     ist_fieldcat-col_pos =  mpos.
1988     ist_fieldcat-seltext_m  = 'Item.no.'.
1989     ist_fieldcat-lowercase  = 'Y'.
1990     APPEND ist_fieldcat TO ist_fcat.
1991     CLEAR ist_fieldcat.
1992
1993     mpos = mpos + 1.
1994     ist_fieldcat-fieldname = 'BSCHL'.
1995     ist_fieldcat-tabname = 'IST_SRCBSID'.
1996     ist_fieldcat-ddictxt = 'M'.
1997     ist_fieldcat-col_pos =  mpos.
1998   *begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
1999   *  ist_fieldcat-seltext_m  = 'Posting Key.'.
2000     ist_fieldcat-seltext_m  = 'PK'.
2001   *end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
2002     ist_fieldcat-lowercase  = 'Y'.
2003     APPEND ist_fieldcat TO ist_fcat.
2004     CLEAR ist_fieldcat.
2005
2006     mpos = mpos + 1.
2007     ist_fieldcat-fieldname = 'BUDAT'.
2008     ist_fieldcat-tabname = 'IST_SRCBSID'.
2009     ist_fieldcat-ddictxt = 'M'.
2010     ist_fieldcat-col_pos =  mpos.
2011   *begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
2012   *  ist_fieldcat-seltext_m  = 'Posting Date'.
2013     ist_fieldcat-seltext_m  = 'Post Dt'.
2014   *end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
2015     ist_fieldcat-lowercase  = 'Y'.
2016     APPEND ist_fieldcat TO ist_fcat.
2017     CLEAR ist_fieldcat.
2018
2019   *begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
2020   *    mpos = mpos + 1.
2021   *  ist_fieldcat-fieldname = 'DMBTR'.
2022   *  ist_fieldcat-tabname = 'IST_SRCBSID'.
2023   *  ist_fieldcat-ddictxt = 'M'.
2024   *  ist_fieldcat-col_pos =  mpos.
2025   *  ist_fieldcat-seltext_m  = 'AmtInLclCurncy'.
2026   *  ist_fieldcat-lowercase  = 'Y'.
2027   *  APPEND ist_fieldcat TO ist_fcat.
2028   *  CLEAR ist_fieldcat.
2029   *end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
2030
2031     mpos = mpos + 1.
2032     ist_fieldcat-fieldname = 'WRBTR'.
2033     ist_fieldcat-tabname = 'IST_SRCBSID'.
2034     ist_fieldcat-ddictxt = 'M'.
2035     ist_fieldcat-col_pos =  mpos.
2036   *begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
2037   *  ist_fieldcat-seltext_m  = 'AmtInDocCurncy'.
2038     ist_fieldcat-seltext_m  = 'Amt In Doc Cur'.
2039   *end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
2040     ist_fieldcat-lowercase  = 'Y'.
2041     APPEND ist_fieldcat TO ist_fcat.
2042     CLEAR ist_fieldcat.
2043
2044   * begin of < RD1K970594> CAB_ALOK 10.03.2010 CR30003739
2045     mpos = mpos + 1.
2046     ist_fieldcat-fieldname = 'WAERS'.
2047     ist_fieldcat-tabname = 'IST_SRCBSID'.
2048     ist_fieldcat-ddictxt = 'M'.
2049     ist_fieldcat-col_pos =  mpos.
2050     ist_fieldcat-seltext_m  = 'Curr'.
2051     ist_fieldcat-lowercase  = 'Y'.
2052     APPEND ist_fieldcat TO ist_fcat.
2053     CLEAR ist_fieldcat.
2054   * end of < RD1K970594> CAB_ALOK 10.03.2010 CR30003739
2055
2056     mpos = mpos + 1.
2057     ist_fieldcat-fieldname = 'ZLSCH'.
2058     ist_fieldcat-tabname = 'IST_SRCBSID'.
2059     ist_fieldcat-ddictxt = 'M'.
2060     ist_fieldcat-col_pos =  mpos.
2061   *begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
2062   *  ist_fieldcat-seltext_m  = 'PaymntMethod'.
2063     ist_fieldcat-seltext_m  = 'PM'.
2064   *end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
2065     ist_fieldcat-lowercase  = 'Y'.
2066     APPEND ist_fieldcat TO ist_fcat.
2067     CLEAR ist_fieldcat.
2068
2069     mpos = mpos + 1.
2070     ist_fieldcat-fieldname = 'ZLSPR'.
2071     ist_fieldcat-tabname = 'IST_SRCBSID'.
2072     ist_fieldcat-ddictxt = 'M'.
2073     ist_fieldcat-col_pos =  mpos.
2074   *begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
2075   *  ist_fieldcat-seltext_m  = 'PaymntBlock'.
2076     ist_fieldcat-seltext_m  = 'PB'.
2077   *end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
2078     ist_fieldcat-lowercase  = 'Y'.
2079     APPEND ist_fieldcat TO ist_fcat.
2080     CLEAR ist_fieldcat.
2081
2082   *  *Start of addition Prabu K on 06.07.2009
2083     mpos = mpos + 1.
2084     ist_fieldcat-fieldname = 'XREF1_HD'.
2085     ist_fieldcat-tabname = 'IST_SRCBSID'.
2086     ist_fieldcat-ddictxt = 'M'.
2087     ist_fieldcat-col_pos =  mpos.
2088   *begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
2089   *  ist_fieldcat-seltext_m  = 'Location'.
2090     ist_fieldcat-seltext_m  = 'Loc'.
2091   *end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
2092     ist_fieldcat-lowercase  = 'Y'.
2093     APPEND ist_fieldcat TO ist_fcat.
2094     CLEAR ist_fieldcat.
2095
2096   * End of addition Prabu K on 06.07.2009
2097
2098   *begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
2099   *    IF NOT s_usnam IS INITIAL.
2100   *    mpos = mpos + 1.
2101   *    ist_fieldcat-fieldname = 'USNAM'.
2102   *    ist_fieldcat-tabname = 'IST_SRCBSID'.
2103   *    ist_fieldcat-ddictxt = 'M'.
2104   *    ist_fieldcat-col_pos =  mpos.
2105   *    ist_fieldcat-seltext_m  = 'Created By'.
2106   *    ist_fieldcat-lowercase  = 'Y'.
2107   *    APPEND ist_fieldcat TO ist_fcat.
2108   *    CLEAR ist_fieldcat.
2109   *  ENDIF.
2110   *end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
2111
2112
2113   ENDFORM.                    " init_fieldcat_cust
2114   *&---------------------------------------------------------------------*
2115   *&      Form  eventtab_build_cust
2116   *&---------------------------------------------------------------------*
2117   *       text
2118   *----------------------------------------------------------------------*
2119   *      -->P_GT_EVENTS[]  text
2120   *----------------------------------------------------------------------*
2121   FORM eventtab_build_cust TABLES   p_gt_events.
2122     DATA : ls_event TYPE slis_alv_event.
2123     CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
2124       EXPORTING
2125         i_list_type = 0
2126       IMPORTING
2127         et_events   = gt_events.
2128     READ TABLE gt_events WITH KEY name =  slis_ev_user_command
2129                               INTO ls_event.
2130     IF sy-subrc = 0.
2131       MOVE 'MAKEC_COMMAND' TO ls_event-form.
2132       APPEND ls_event TO gt_events.
2133     ENDIF.
2134     CLEAR ls_event.
2135   *begin of <RD1K967585> CAB_ALOK 03.12.2009 CR30002778
2136     CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
2137       EXPORTING
2138         i_list_type = 0
2139       IMPORTING
2140         et_events   = gt_events_inactiv.
2141     CLEAR ls_event.
2142   *end  of <RD1K967585> CAB_ALOK 03.12.2009 CR30002778
2143
2144   ENDFORM.                    " eventtab_build_cust
2145   *&---------------------------------------------------------------------*
2146   *&      Form  print_alv_cust
2147   *&---------------------------------------------------------------------*
2148   *       text
2149   *----------------------------------------------------------------------*
2150   *  -->  p1        text
2151   *  <--  p2        text
2152   *----------------------------------------------------------------------*
2153   *Begin  of <RD1K967585> CAB_ALOK 03.12.2009 CR30002778
2154   *FORM print_alv_cust.
2155   *  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
2156   *    EXPORTING
2157   *      i_callback_program       = w_repid
2158   *      i_callback_pf_status_set = 'ALV_PFSTS'
2159   *      i_callback_user_command  = 'MAKEC_COMMAND'
2160   *      is_layout                = is_layout
2161   *      it_fieldcat              = ist_fcat[]
2162   *      it_sort                  = lt_sorttab
2163   *      it_events                = gt_events
2164   *      i_save                   = 'A'
2165   *    TABLES
2166   *      t_outtab                 = ist_srcbsid.
2167   *  IF sy-subrc <> 0.
2168   **    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
2169   **            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
2170   *  ENDIF.
2171   *
2172   *
2173   *ENDFORM.                    " print_alv
2174   **---------------------------------------------------------------------*
2175   **       FORM alv_pfst                                                 *
2176   **---------------------------------------------------------------------*
2177   **       ........                                                      *
2178   **---------------------------------------------------------------------*
2179   **  -->  RT_EXTAB                                                      *
2180   **---------------------------------------------------------------------*
2181   *FORM alv_pfsts USING rt_extab TYPE slis_t_extab.
2182   *  SET PF-STATUS 'S100'.
2183   *ENDFORM.                    "alv_pfsts
2184   *end  of <RD1K967585> CAB_ALOK 07.12.2009 CR30002778
2185
2186   *---------------------------------------------------------------------*
2187   *       FORM makec_command                                             *
2188   *---------------------------------------------------------------------*
2189   *       ........                                                      *
2190   *---------------------------------------------------------------------*
2191   *  -->  R_UCOMM                                                       *
2192   *  -->  RS_SELFIELD                                                   *
2193   *---------------------------------------------------------------------*
2194   FORM makec_command USING r_ucomm LIKE sy-ucomm
2195                           rs_selfield TYPE slis_selfield.
2196   *-----------------------------------------------------*
2197   *-----------------------------------------------------*
2198     DATA : index_aux LIKE sy-tabix.
2199     index_aux = rs_selfield-tabindex.
2200     CASE r_ucomm.
2201
2202       WHEN 'REL'.
2203         DELETE ist_srcbsid WHERE  selcbox <> 'X'.
2204
2205         PERFORM   get_upd_bsid.
2206         PERFORM   get_upd_bsegc.
2207   *Begin of <RD1K967585> CAB_ALOK 09.12.2009 CR30002778
2208         PERFORM update_zfi_rem_pyblck_l .           "update logs
2209   *End of <RD1K967585> CAB_ALOK 09.12.2009 CR30002778
2210         LEAVE SCREEN.
2211       WHEN 'ALL'.
2212         PERFORM  select_allc.
2213       WHEN 'SAL'.
2214         PERFORM  deselect_allc.
2215
2216       WHEN '&F03' OR 'BACK' .
2217         LEAVE  PROGRAM.
2218   *Begin of <RD1K967585> CAB_ALOK 03.12.2009 CR30002778
2219       WHEN 'REP'.
2220         PERFORM display_inactive_alv_cust.
2221   *End of <RD1K967585> CAB_ALOK 03.12.2009 CR30002778
2222
2223     ENDCASE.
2224
2225   ENDFORM.                    "makec_command
2226   *---------------------------------------------------------------------*
2227   *&      Form  select_all
2228   *&---------------------------------------------------------------------*
2229   *       text
2230   *----------------------------------------------------------------------*
2231   *  -->  p1        text
2232   *  <--  p2        text
2233   *----------------------------------------------------------------------*
2234   FORM select_allc.
2235     LOOP AT ist_srcbsid.
2236       ist_srcbsid-selcbox = 'X'.
2237       MODIFY ist_srcbsid.
2238     ENDLOOP.
2239
2240   ENDFORM.                    " select_all
2241   *&---------------------------------------------------------------------*
2242   *&      Form  deselect_all
2243   *&---------------------------------------------------------------------*
2244   *       text
2245   *----------------------------------------------------------------------*
2246   *  -->  p1        text
2247   *  <--  p2        text
2248   *----------------------------------------------------------------------*
2249   FORM deselect_allc.
2250     LOOP AT ist_srcbsid.
2251       ist_srcbsid-selcbox = ' '.
2252       MODIFY ist_srcbsid.
2253     ENDLOOP.
2254   ENDFORM.                    " deselect_all
2255   *&---------------------------------------------------------------------
2256   *&---------------------------------------------------------------------*
2257   *&      Form  get_upd_BSID
2258   *&---------------------------------------------------------------------*
2259   *       text
2260   *----------------------------------------------------------------------*
2261   *  -->  p1        text
2262   *  <--  p2        text
2263   *----------------------------------------------------------------------*
2264   FORM get_upd_bsid.
2265
2266     DATA : l_tabix  TYPE sy-tabix.
2267
2268     CHECK NOT ist_srcbsid[] IS INITIAL.
2269
2270     SELECT * INTO TABLE ist_bsid   FROM bsid
2271       FOR ALL ENTRIES  IN  ist_srcbsid
2272       WHERE   kunnr = ist_srcbsid-kunnr
2273             AND  bukrs  =  p_bukrs
2274              AND gjahr = ist_srcbsid-gjahr
2275              AND belnr = ist_srcbsid-belnr
2276              AND buzei = ist_srcbsid-buzei.
2277   *------------X  to blank
2278     IF NOT ist_bsid IS INITIAL.
2279       IF p_x2sp = 'X'.
2280         LOOP AT ist_bsid INTO wa_bsid.
2281           l_tabix =   sy-tabix .
2282           IF wa_bsid-zlspr =  g_zlspr_x.
2283             wa_bsid-zlspr =  space.
2284             MODIFY ist_bsid  FROM  wa_bsid INDEX l_tabix  TRANSPORTING zlspr.
2285           ENDIF.
2286         ENDLOOP.
2287   "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
2288   *      MODIFY  bsid FROM TABLE ist_bsid.
2289   "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
2290   *      COMMIT WORK.
2291       ENDIF.
2292
2293   *---------------blank to X
2294       IF p_sp2x = 'X'.
2295         LOOP AT ist_bsid INTO wa_bsid.
2296           l_tabix =   sy-tabix .
2297           IF wa_bsid-zlspr =  g_zlspr_sp.
2298             wa_bsid-zlspr =  'X'.
2299             MODIFY ist_bsid  FROM  wa_bsid INDEX l_tabix  TRANSPORTING zlspr
2300         .
2301           ENDIF.
2302         ENDLOOP.
2303   "Code Remediation changes S4 2025 Conversion begin of change SAP_ABAP and 15.06.2026
2304   *      MODIFY  bsid FROM TABLE ist_bsid.
2305   *      COMMIT WORK.
2306   "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
2307
2308       ENDIF.
2309   *---------+003
2310   *------------------Blank to R
2311       IF p_sp2r = 'X'.
2312         LOOP AT ist_bsid INTO wa_bsid.
2313           l_tabix =   sy-tabix .
2314           IF wa_bsid-zlspr =  g_zlspr_sp.
2315             wa_bsid-zlspr =  g_zlspr_r.
2316             MODIFY ist_bsid  FROM  wa_bsid INDEX l_tabix  TRANSPORTING zlspr.
2317           ENDIF.
2318         ENDLOOP.
2319   "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
2320
2321   *      MODIFY  bsid FROM TABLE ist_bsid.
2322   *
2323   *      COMMIT WORK.
2324   "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
2325       ENDIF.
2326   *------------Blank to S
2327   *  IF p_sp2s = 'X'.
2328   *      LOOP AT ist_BSID INTO wa_BSID.
2329   *        l_tabix =   sy-tabix .
2330   *        IF wa_BSID-zlspr =  g_zlspr_sp.
2331   *          wa_BSID-zlspr =  g_zlspr_s.
2332   *       MODIFY ist_BSID  FROM  wa_BSID INDEX l_tabix  TRANSPORTING zlspr
2333   *.
2334   *        ENDIF.
2335   *      ENDLOOP.
2336   *
2337   *      MODIFY  BSID FROM TABLE ist_BSID.
2338   *
2339   *      COMMIT WORK.
2340   *    ENDIF.
2341
2342   *----------------X to S
2343
2344
2345
2346       IF p_x2s = 'X'.
2347         LOOP AT ist_bsid INTO wa_bsid.
2348           l_tabix =   sy-tabix .
2349           IF wa_bsid-zlspr =  g_zlspr_x  OR wa_bsid-zlspr =  g_zlspr_sp.
2350             wa_bsid-zlspr =  g_zlspr_s.
2351             MODIFY ist_bsid  FROM  wa_bsid INDEX l_tabix  TRANSPORTING zlspr.
2352           ENDIF.
2353         ENDLOOP.
2354   "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
2355   *      MODIFY  bsid FROM TABLE ist_bsid.
2356   *
2357   *      COMMIT WORK.
2358   "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
2359       ENDIF.
2360
2361   * Begin of RD1K971966 CAB_ALOK CR30004183
2362   **-----------S to X
2363   *     IF p_s2x = 'X'.
2364   *      LOOP AT ist_bsid INTO wa_bsid.
2365   *        l_tabix =   sy-tabix .
2366   *        IF wa_bsid-zlspr =  g_zlspr_s.
2367   *          wa_bsid-zlspr =  g_zlspr_x.
2368   *          MODIFY ist_bsid  FROM  wa_bsid INDEX l_tabix  TRANSPORTING zlspr.
2369   *        ENDIF.
2370   *      ENDLOOP.
2371   *
2372   *      MODIFY  bsid FROM TABLE ist_bsid.
2373   *
2374   *      COMMIT WORK.
2375   *    ENDIF.
2376   * end of RD1K971966 CAB_ALOK CR30004183
2377
2378   *-------+003
2379     ENDIF.
2380   *  LEAVE SCREEN.
2381   ENDFORM.                    " get_upd_BSID
2382   *
2383   *&---------------------------------------------------------------------*
2384   *&      Form  get_upd_bseg
2385   *&---------------------------------------------------------------------*
2386   *       text
2387   *----------------------------------------------------------------------*
2388   *  -->  p1        text
2389   *  <--  p2        text
2390   *----------------------------------------------------------------------*
2391   FORM get_upd_bsegc.
2392     DATA : l_tabix  TYPE sy-tabix.
2393
2394     CHECK NOT ist_srcbsid[] IS INITIAL.
2395
2396     SELECT * INTO TABLE ist_bseg   FROM bseg
2397       FOR ALL ENTRIES  IN  ist_srcbsid
2398       WHERE
2399              bukrs  =  p_bukrs
2400        AND   belnr = ist_srcbsid-belnr
2401        AND   gjahr = ist_srcbsid-gjahr
2402        AND   buzei = ist_srcbsid-buzei ORDER BY PRIMARY KEY.
2403
2404     IF NOT ist_bseg IS INITIAL.
2405   *---------------  X to Blank
2406       IF p_x2sp = 'X'.
2407         LOOP AT ist_bseg INTO wa_bseg.
2408           l_tabix =   sy-tabix .
2409           IF wa_bseg-zlspr =  g_zlspr_x.
2410             wa_bseg-zlspr =   g_zlspr_sp.
2411             MODIFY ist_bseg  FROM  wa_bseg INDEX l_tabix  TRANSPORTING zlspr.
2412           ENDIF.
2413         ENDLOOP.
2414
2415   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
2416   * S/4: BSEG payment block (ZLSPR) via FI_DOCUMENT_CHANGE (FB02); direct write not allowed.
2417   *      MODIFY bseg FROM TABLE ist_bseg.
2418         LOOP AT ist_bseg INTO wa_bseg.
2419           PERFORM zz_s4_bseg_zlspr USING wa_bseg-bukrs wa_bseg-belnr wa_bseg-gjahr wa_bseg-buzei wa_bseg-zlspr.
2420         ENDLOOP.
2421         COMMIT WORK.
2422   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
2423
2424       ENDIF.
2425   *------------space to X
2426       IF p_sp2x = 'X'.
2427         LOOP AT ist_bseg INTO wa_bseg.
2428           l_tabix =   sy-tabix .
2429           IF wa_bseg-zlspr =  g_zlspr_sp.
2430             wa_bseg-zlspr =  g_zlspr_x.
2431             MODIFY ist_bseg  FROM  wa_bseg INDEX l_tabix  TRANSPORTING zlspr.
2432           ENDIF.
2433         ENDLOOP.
2434
2435   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
2436   * S/4: BSEG payment block (ZLSPR) via FI_DOCUMENT_CHANGE (FB02); direct write not allowed.
2437   *      MODIFY bseg FROM TABLE ist_bseg.
2438         LOOP AT ist_bseg INTO wa_bseg.
2439           PERFORM zz_s4_bseg_zlspr USING wa_bseg-bukrs wa_bseg-belnr wa_bseg-gjahr wa_bseg-buzei wa_bseg-zlspr.
2440         ENDLOOP.
2441         COMMIT WORK.
2442   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
2443
2444       ENDIF.
2445   *----+003
2446   *------Blank to R
2447
2448
2449       IF p_sp2r = 'X'.
2450         LOOP AT ist_bseg INTO wa_bseg.
2451           l_tabix =   sy-tabix .
2452           IF wa_bseg-zlspr =  g_zlspr_sp.
2453             wa_bseg-zlspr =  g_zlspr_r.
2454             MODIFY ist_bseg  FROM  wa_bseg INDEX l_tabix  TRANSPORTING zlspr.
2455           ENDIF.
2456         ENDLOOP.
2457
2458   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
2459   * S/4: BSEG payment block (ZLSPR) via FI_DOCUMENT_CHANGE (FB02); direct write not allowed.
2460   *      MODIFY  bseg FROM TABLE ist_bseg.
2461         LOOP AT ist_bseg INTO wa_bseg.
2462           PERFORM zz_s4_bseg_zlspr USING wa_bseg-bukrs wa_bseg-belnr wa_bseg-gjahr wa_bseg-buzei wa_bseg-zlspr.
2463         ENDLOOP.
2464         COMMIT WORK.
2465   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
2466
2467         COMMIT WORK.
2468       ENDIF.
2469
2470   **------Blank to S
2471   *
2472   *
2473   *    IF p_sp2s = 'X'.
2474   *      LOOP AT ist_bseg INTO wa_bseg.
2475   *        l_tabix =   sy-tabix .
2476   *        IF wa_bseg-zlspr =  g_zlspr_sp.
2477   *          wa_bseg-zlspr =  g_zlspr_s.
2478   *       MODIFY ist_bseg  FROM  wa_bseg INDEX l_tabix  TRANSPORTING zlspr
2479   *.
2480   *        ENDIF.
2481   *      ENDLOOP.
2482   *
2483   *      MODIFY  bseg FROM TABLE ist_bseg.
2484   *
2485   *      COMMIT WORK.
2486   *    ENDIF.
2487
2488
2489   *-------X  to S  and  Blank TO S
2490       IF p_x2s = 'X'.
2491         LOOP AT ist_bseg INTO wa_bseg.
2492           l_tabix =   sy-tabix .
2493           IF wa_bsid-zlspr =  g_zlspr_x  OR wa_bsid-zlspr =  g_zlspr_sp.
2494             wa_bseg-zlspr =  g_zlspr_s.
2495             MODIFY ist_bseg  FROM  wa_bseg INDEX l_tabix  TRANSPORTING zlspr.
2496           ENDIF.
2497         ENDLOOP.
2498
2499   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
2500   * S/4: BSEG payment block (ZLSPR) via FI_DOCUMENT_CHANGE (FB02); direct write not allowed.
2501   *      MODIFY  bseg FROM TABLE ist_bseg.
2502         LOOP AT ist_bseg INTO wa_bseg.
2503           PERFORM zz_s4_bseg_zlspr USING wa_bseg-bukrs wa_bseg-belnr wa_bseg-gjahr wa_bseg-buzei wa_bseg-zlspr.
2504         ENDLOOP.
2505         COMMIT WORK.
2506   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
2507
2508         COMMIT WORK.
2509       ENDIF.
2510
2511   * Begin of RD1K971966 CAB_ALOK CR30004183
2512   **------------------------S To X
2513   *    IF p_s2x = 'X'.
2514   *      LOOP AT ist_bseg INTO wa_bseg.
2515   *        l_tabix =   sy-tabix .
2516   *        IF wa_bseg-zlspr =  g_zlspr_s.
2517   *          wa_bseg-zlspr =  g_zlspr_x.
2518   *          MODIFY ist_bseg  FROM  wa_bseg INDEX l_tabix  TRANSPORTING zlspr.
2519   *        ENDIF.
2520   *      ENDLOOP.
2521   *
2522   *      MODIFY  bseg FROM TABLE ist_bseg.
2523   *
2524   *      COMMIT WORK.
2525   *    ENDIF.
2526   * end of RD1K971966 CAB_ALOK CR30004183
2527
2528   *------+003
2529     ENDIF.
2530
2531
2532
2533   ENDFORM.                    " print_alv_cust
2534   *&---------------------------------------------------------------------*
2535   *&      Form  sort_build_cust
2536   *&---------------------------------------------------------------------*
2537   *       text
2538   *----------------------------------------------------------------------*
2539   *  -->  p1        text
2540   *  <--  p2        text
2541   *----------------------------------------------------------------------*
2542   FORM sort_build_cust.
2543     w_repid = sy-repid.
2544     is_layout-key_hotspot = 'X'.
2545     is_layout-colwidth_optimize = 'X'.
2546   *begin of <RD1K967585> CAB_ALOK 03.12.2009 CR30002778
2547     is_layout_inactiv-key_hotspot = 'X'.
2548     is_layout_inactiv-colwidth_optimize = 'X'.
2549
2550   *  ls_sorttab-fieldname = 'KIDNO'.
2551   *  ls_sorttab-up = 'X'.
2552   *  APPEND ls_sorttab TO lt_sorttab.
2553   *end of <RD1K967585> CAB_ALOK 03.12.2009 CR30002778
2554     ls_sorttab-fieldname = 'KUNNR'.
2555     ls_sorttab-up = 'X'.
2556     APPEND ls_sorttab TO lt_sorttab.
2557   *begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
2558   *  ls_sorttab-fieldname = 'BSCHL'.
2559   *  ls_sorttab-up = 'X'.
2560   *  APPEND ls_sorttab TO lt_sorttab.
2561   *  ls_sorttab-fieldname = 'BELNR'.
2562   *  ls_sorttab-up = 'X'.
2563   *  APPEND ls_sorttab TO lt_sorttab.
2564   *  ls_sorttab-fieldname = 'BUDAT'.
2565   *  ls_sorttab-up = 'X'.
2566   *  APPEND ls_sorttab TO lt_sorttab.
2567   *end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
2568
2569   ENDFORM.                    " sort_build_cust
2570   *&---------------------------------------------------------------------*
2571   *&      Form  VALIDATE_DOCS
2572   *&---------------------------------------------------------------------*
2573   *       text
2574   *----------------------------------------------------------------------*
2575   *  -->  p1        text
2576   *  <--  p2        text
2577   *----------------------------------------------------------------------*
2578   FORM validate_docs .
2579     DATA : ist_kid LIKE  ist_srcbsik OCCURS 0.
2580     DATA : wa_kid LIKE  ist_srcbsik.
2581     DATA : g_actflag TYPE c.
2582     DATA :l_dmbtr TYPE bseg-dmbtr.
2583     DATA : l_lifnr TYPE bsik-lifnr,
2584            l_kidno TYPE bsik-kidno.
2585     DATA :l_tabix TYPE sy-tabix.
2586
2587   *Begin of <RD1K975843> CAB_ALOK CR 30005441
2588     DATA: wa_zfi_c_n_b_cc1 TYPE  zfi_c_n_b_cc1,
2589           wa_zfi_c_b_blockpm1 TYPE  zfi_c_b_blockpm1,
2590           wa_zfi_c_n_b_cc2 TYPE  zfi_c_n_b_cc2,
2591           wa_zfi_c_b_blockpm2 TYPE  zfi_c_b_blockpm2.
2592     IF ist_srcbsik IS NOT INITIAL.
2593   *End of <RD1K975843> CAB_ALOK CR 30005441
2594
2595       IF p_x2sp = 'X'.
2596
2597   *Begin of <RD1K967585> CAB_ALOK 26.11.2009 CR30002778
2598   *** Validate ist_srcbsik for different conditions and move inactive items into ist_srcbsik_inactiv
2599
2600   ** add serial no. to ist_srcbsik
2601         DATA srno TYPE i. "serial no.
2602         srno = 0.
2603         LOOP AT ist_srcbsik INTO wa_srcbsik.
2604           srno = srno + 1.
2605           wa_srcbsik-serial_no = srno.
2606           MODIFY ist_srcbsik FROM wa_srcbsik TRANSPORTING serial_no.
2607         ENDLOOP.
2608   ** save original ist_srcbsik
2609   *ist_srcbsik_orig = ist_srcbsik
2610         ist_srcbsik_orig[] = ist_srcbsik[].
2611   *** Check each line of ist_srcbsik:
2612   ** if Vendor is blocked or deleted or line posting key 26 put the reason and make the line item inactive
2613   *End of <RD1K967585> CAB_ALOK 02.11.2009 CR30002778
2614         SORT ist_srcbsik  BY lifnr kidno.
2615         TYPES :BEGIN OF ty_vend,
2616                lifnr TYPE lfb1-lifnr,
2617                bukrs TYPE lfb1-bukrs,
2618                sperr TYPE lfb1-sperr,
2619                zahls TYPE lfb1-zahls,
2620                loevm TYPE lfb1-loevm,
2621   *Begin of <RD1K967585> CAB_ALOK 29.01.2010 CR30002778
2622                bschl TYPE bsik-bschl,
2623                rebzg TYPE bsik-rebzg,
2624   *End of <RD1K967585> CAB_ALOK 29.01.2010 CR30002778
2625   *Begin of <RD1K975843> CAB_ALOK CR 30005441
2626                zwels TYPE lfb1-zwels,  "payment method
2627   *End of <RD1K975843> CAB_ALOK CR 30005441
2628                END OF ty_vend.
2629
2630         DATA :ist_vend TYPE TABLE OF ty_vend.
2631         DATA :wa_vend TYPE ty_vend.
2632   *DATA :l_tabix TYPE sy-tabix.
2633   ** 1. For a given vendor, posting blocked or marked deleted for given company code?
2634         SELECT lifnr bukrs sperr zahls loevm
2635           FROM lfb1
2636           INTO CORRESPONDING FIELDS OF TABLE ist_vend
2637           FOR ALL ENTRIES IN ist_srcbsik
2638           WHERE lifnr = ist_srcbsik-lifnr
2639           AND bukrs = ist_srcbsik-bukrs.    " p_bukrs.
2640
2641         CLEAR: wa_srcbsik.
2642         LOOP AT ist_srcbsik INTO wa_srcbsik.
2643           l_tabix = sy-tabix.
2644   *Begin of <RD1K967585> CAB_ALOK 02.11.2009 CR30002778
2645   *      READ TABLE ist_vend INTO wa_vend WITH KEY lifnr = wa_srcbsik-lifnr.
2646           READ TABLE ist_vend INTO wa_vend WITH KEY lifnr = wa_srcbsik-lifnr
2647                                                      bukrs = wa_srcbsik-bukrs  .
2648   *end of <RD1K967585> CAB_ALOK 02.11.2009 CR30002778
2649           IF sy-subrc = 0.
2650             IF wa_vend-sperr = 'X'.
2651               wa_srcbsik-inactiv = 'X'.
2652               wa_srcbsik-reason = 'Posting blocked for company code'.
2653             ELSEIF wa_vend-zahls = 'X'.
2654               wa_srcbsik-inactiv = 'X'.
2655               wa_srcbsik-reason = 'Blocked for Payment'.
2656             ELSEIF wa_vend-loevm = 'X'.
2657               wa_srcbsik-inactiv = 'X'.
2658               wa_srcbsik-reason = 'Marked for Deletion-company code level'.
2659             ENDIF.
2660             MODIFY ist_srcbsik FROM wa_srcbsik INDEX l_tabix TRANSPORTING inactiv reason.
2661           ENDIF.
2662           CLEAR: wa_srcbsik.
2663         ENDLOOP.
2664   *Begin of <RD1K967585> CAB_ALOK 02.11.2009 CR30002778
2665   ** 2. For a given vendor, posting blocked or deleted for all company codes?
2666         REFRESH ist_vend.
2667         SELECT lifnr loevm sperr INTO CORRESPONDING FIELDS OF TABLE ist_vend
2668           FROM lfa1
2669           FOR ALL ENTRIES IN ist_srcbsik
2670           WHERE lifnr = ist_srcbsik-lifnr.  "#EC CI_NOORDER
2671         CLEAR: wa_srcbsik.
2672         LOOP AT ist_srcbsik INTO wa_srcbsik.
2673           l_tabix = sy-tabix.
2674           READ TABLE ist_vend INTO wa_vend WITH KEY lifnr = wa_srcbsik-lifnr.
2675           IF sy-subrc = 0.
2676             IF wa_vend-sperr = 'X'.
2677               wa_srcbsik-inactiv = 'X'.
2678               wa_srcbsik-reason = 'Central Posting block'.
2679             ELSEIF wa_vend-loevm = 'X'.
2680               wa_srcbsik-inactiv = 'X'.
2681               wa_srcbsik-reason = 'Central Deletion flag'.
2682             ENDIF.
2683             MODIFY ist_srcbsik FROM wa_srcbsik INDEX l_tabix TRANSPORTING inactiv reason.
2684           ENDIF.
2685           CLEAR: wa_srcbsik.
2686         ENDLOOP.
2687   *end of <RD1K967585> CAB_ALOK 02.11.2009 CR30002778
2688
2689   ** 3. Validation for posting key '26'
2690   *begin of <RD1K967585> CAB_ALOK 29.01.2010 CR30002778
2691   *     LOOP AT ist_srcbsik INTO wa_srcbsik.
2692   *      l_tabix = sy-tabix.
2693   **     IF sy-subrc = 0.
2694   **     IF wa_srcbsik-rebzg IS INITIAL.
2695   *      IF wa_srcbsik-bschl = '26' AND wa_srcbsik-rebzg IS INITIAL.
2696   *        wa_srcbsik-inactiv = 'X'.
2697   *        wa_srcbsik-reason = 'Inv Ref not upd'.
2698   *        MODIFY ist_srcbsik FROM wa_srcbsik INDEX l_tabix TRANSPORTING inactiv reason.
2699   *      ENDIF.
2700   *    ENDLOOP.
2701
2702   *	If vendor has any open item (BSIK) with Posting key(BSCHL) 26
2703   *    and blank value in Inv reference(REBZG). All line items of this vendor in ist_srcbsik should be inactive with reason.
2704   *  READ TABLE ist_srcbsik INTO wa_srcbsik  WITH KEY bschl = '26'.
2705         REFRESH ist_vend.
2706   *begin of < RD1K970594> CAB_ALOK 9.03.2010 CR30003739
2707   *    SELECT lifnr BSCHL REBZG INTO CORRESPONDING FIELDS OF TABLE ist_vend
2708         SELECT lifnr bukrs bschl rebzg INTO CORRESPONDING FIELDS OF TABLE ist_vend
2709   *end of < RD1K970594> CAB_ALOK 9.03.2010 CR30003739
2710           FROM bsik
2711           FOR ALL ENTRIES IN ist_srcbsik
2712           WHERE lifnr = ist_srcbsik-lifnr
2713           AND  bschl = '26'
2714           AND  rebzg = ''.
2715         CLEAR: wa_srcbsik.
2716         LOOP AT ist_srcbsik INTO wa_srcbsik.
2717           l_tabix = sy-tabix.
2718   *begin of < RD1K970594> CAB_ALOK 9.03.2010 CR30003739
2719   *     READ TABLE ist_vend INTO wa_vend WITH KEY lifnr = wa_srcbsik-lifnr.
2720           READ TABLE ist_vend INTO wa_vend WITH KEY lifnr = wa_srcbsik-lifnr bukrs = wa_srcbsik-bukrs.
2721   *end of < RD1K970594> CAB_ALOK 9.03.2010 CR30003739
2722
2723           IF sy-subrc = 0.
2724             wa_srcbsik-inactiv = 'X'.
2725             wa_srcbsik-reason = 'Inv Ref not upd'.
2726             MODIFY ist_srcbsik FROM wa_srcbsik INDEX l_tabix TRANSPORTING inactiv reason.
2727           ENDIF.
2728           CLEAR: wa_srcbsik.
2729         ENDLOOP.
2730   *end of <RD1K967585> CAB_ALOK 29.01.2010 CR30002778
2731   *4a, 5a moved down.
2732   *begin of <RD1K967585> CAB_ALOK 26.11.2009 CR30002778
2733   *Move inactive lines to ist_srcbsik_inactiv
2734         ist_srcbsik_inactiv[] = ist_srcbsik[].
2735         DELETE ist_srcbsik_inactiv WHERE inactiv <> 'X'. "ist_srcbsik_inactiv contains inactive items
2736         DELETE ist_srcbsik WHERE inactiv = 'X'.  "ist_srcbsik contains active items
2737
2738   ** 5. Validation on linked documents: Match Inv. Ref with Doc No.
2739   * Loop at lines of ist_srcbsik that hav some Inv. Ref.(rebzg )
2740   * Search this Inv Ref in Doc no. (belnr) of other Credit line items ( Credit indicator: shkzg  = 'H')
2741   * if matchig doc is found then
2742   *    temporarily update Pay Ref (kidno) of current line item with the Pay ref of matching Doc (this
2743   *                 will be needed later while sub-totaling on the basis of lifnr+kidno )
2744   *  else
2745   *   make the current line inactive.
2746         LOOP AT ist_srcbsik INTO wa_srcbsik WHERE rebzg IS NOT INITIAL.
2747           READ TABLE ist_srcbsik_orig
2748                      INTO wa_srcbsik_orig
2749                       WITH KEY lifnr = wa_srcbsik-lifnr
2750                                belnr  = wa_srcbsik-rebzg
2751                                shkzg  = 'H' .
2752           IF sy-subrc = 0.
2753             wa_srcbsik-kidno = wa_srcbsik_orig-kidno.
2754             MODIFY ist_srcbsik FROM wa_srcbsik TRANSPORTING kidno.
2755           ELSE.
2756             wa_srcbsik-inactiv = 'X'.
2757             MODIFY ist_srcbsik FROM wa_srcbsik TRANSPORTING inactiv.
2758           ENDIF.
2759         ENDLOOP.
2760
2761   *{30007486
2762         LOOP AT ist_srcbsik INTO wa_srcbsik WHERE rebzg IS NOT INITIAL.
2763           READ TABLE ist_srcbsik_orig
2764                      INTO wa_srcbsik_orig
2765                       WITH KEY lifnr = wa_srcbsik-lifnr
2766                                belnr  = wa_srcbsik-rebzg
2767                                shkzg  = 'H' .
2768           IF sy-subrc = 0.
2769             IF wa_srcbsik_orig-bschl <> '39'. "31
2770               IF wa_srcbsik_orig-bschl = '31'.
2771                 IF ( wa_srcbsik-rebzz <> wa_srcbsik_orig-buzei ).
2772                   wa_srcbsik-inactiv = 'X'.
2773                   wa_srcbsik-reason = 'Incorrect Line Item Reference'.
2774                   MODIFY ist_srcbsik FROM wa_srcbsik INDEX l_tabix TRANSPORTING inactiv reason.
2775                   READ TABLE ist_srcbsik
2776                              INTO wa_srcbsik_l
2777                               WITH KEY lifnr = wa_srcbsik-lifnr
2778                                        belnr  = wa_srcbsik-belnr
2779                                        shkzg  = 'S' .
2780                   wa_srcbsik_l-inactiv = 'X'.
2781                   wa_srcbsik_l-reason = 'Incorrect Line Item Reference'.
2782                   MODIFY ist_srcbsik FROM wa_srcbsik_l TRANSPORTING inactiv reason.
2783                 ENDIF.
2784               ELSE. "39 and not F
2785
2786               ENDIF.
2787             ENDIF.
2788           ENDIF.
2789         ENDLOOP.
2790   *}
2791   * Again move inactive lines to ist_srcbsik_inactiv
2792         LOOP AT ist_srcbsik INTO wa_srcbsik WHERE inactiv = 'X'.
2793           APPEND wa_srcbsik TO ist_srcbsik_inactiv.
2794         ENDLOOP.
2795         DELETE ist_srcbsik WHERE inactiv = 'X'.
2796
2797
2798   ** calculate sub total group by vendor, pay ref (i.e. lifnr, kidno)
2799   *end of <RD1K967585> CAB_ALOK 26.11.2009 CR30002778
2800         SORT ist_srcbsik  BY lifnr kidno rebzg.
2801   *read table ist_srcbsik  index 1 into wa_srcbsik.
2802   *if sy-subrc = 0.
2803   *  l_lifnr = wa_srcbsik-lifnr.
2804   *  l_kidno = wa_srcbsik-kidno.
2805   *endif.
2806         LOOP AT ist_srcbsik INTO wa_srcbsik.
2807           READ TABLE ist_kid INTO wa_kid
2808           WITH KEY lifnr = wa_srcbsik-lifnr
2809                 kidno = wa_srcbsik-kidno.
2810           IF sy-subrc = 0.
2811             l_dmbtr = l_dmbtr + wa_srcbsik-dmbtr .  "update sub total
2812             wa_kid-dmbtr = l_dmbtr.
2813             MODIFY ist_kid FROM wa_kid INDEX sy-tabix "wa_kid-dmbtr holds subtotal for {vendor, pay ref i.e. kidno} tupple.
2814             TRANSPORTING dmbtr.
2815           ELSE.
2816             CLEAR l_dmbtr.
2817             l_dmbtr = wa_srcbsik-dmbtr.
2818             APPEND wa_srcbsik TO ist_kid.
2819           ENDIF.
2820           CLEAR wa_srcbsik.
2821         ENDLOOP.
2822
2823   *begin of <RD1K967585> CAB_ALOK 26.11.2009 CR30002778
2824   ** assign a sub-group no. to each {vendor, pay ref} tupple of ist_kid, which will be subsequently
2825   * moved to {vendor, pay ref} tupple of ist_srcbsik ('ll be used for grouping of data when changed Pay Ref
2826   * have been restored back.
2827         DATA l_subgrp TYPE i.
2828         l_subgrp = 0.
2829         SORT ist_kid BY lifnr kidno rebzg.
2830         LOOP AT ist_kid INTO wa_kid.
2831           l_subgrp = l_subgrp + 1.
2832           wa_kid-subgrp = l_subgrp.
2833           MODIFY ist_kid FROM wa_kid TRANSPORTING subgrp.
2834         ENDLOOP.
2835   *end of <RD1K967585> CAB_ALOK 26.11.2009 CR30002778
2836
2837
2838   *Begin of <RD1K967585> CAB_ALOK 29.10.2009 CR30002778
2839   *loop at ist_kid into wa_kid.
2840   *  read table ist_srcbsik  into  wa_srcbsik
2841   *with key lifnr = wa_kid-lifnr   " Vendor
2842   *          kidno = wa_kid-kidno.   "pay ref.
2843   *if sy-subrc = 0.
2844   *  clear wa_srcbsik.
2845   *  wa_srcbsik-activ = 'X'.
2846   *  wa_srcbsik-lifnr = wa_kid-lifnr.
2847   *  wa_srcbsik-kidno = wa_kid-kidno.
2848   *  wa_srcbsik-reason = 'Subtotal'.
2849   *  wa_srcbsik-dmbtr =   wa_kid-dmbtr.
2850   *  append wA_srcbsik to ist_srcbsik.  "add sub total line item to ist_srcbsik
2851   *endif.
2852   *endloop.
2853
2854   ** update subtotal for all {vendor, pay ref i.e. kidno} tupple in SubTot column of ist_srcbsik,
2855   * note: {vendor, pay ref i.e. kidno} tupple is non-unique in ist_srcbsik
2856   * while it's unique in ist_kid.
2857         LOOP AT ist_srcbsik INTO wa_srcbsik.
2858           READ TABLE ist_kid INTO wa_kid
2859              WITH KEY lifnr = wa_srcbsik-lifnr
2860                       kidno = wa_srcbsik-kidno.
2861           IF sy-subrc = 0.
2862             wa_srcbsik-subtot = wa_kid-dmbtr.
2863             wa_srcbsik-subgrp = wa_kid-subgrp.
2864             IF wa_srcbsik-subtot => 0.   "if subtotal is +ve or zero then this sub-group will be inactive
2865               wa_srcbsik-inactiv = 'X'.
2866               wa_srcbsik-reason = 'Net receivable'.
2867             ENDIF.
2868             MODIFY ist_srcbsik FROM wa_srcbsik TRANSPORTING subtot inactiv subgrp reason.
2869           ENDIF.
2870           CLEAR: wa_srcbsik, wa_kid.
2871         ENDLOOP.
2872
2873   * Restore Pay Ref that were temporarily changed.
2874         SORT ist_srcbsik  BY lifnr kidno rebzg.  " before restoring kidno, sort tables in proper order for future use.
2875         SORT ist_srcbsik_inactiv  BY lifnr kidno rebzg.
2876         LOOP AT ist_srcbsik INTO wa_srcbsik WHERE rebzg IS NOT INITIAL.
2877           READ TABLE ist_srcbsik_orig INTO wa_srcbsik_orig
2878               WITH KEY serial_no = wa_srcbsik-serial_no.
2879           wa_srcbsik-kidno = wa_srcbsik_orig-kidno.
2880           MODIFY ist_srcbsik FROM wa_srcbsik TRANSPORTING kidno.
2881         ENDLOOP.
2882   *end of <RD1K967585> CAB_ALOK 01.12.2009 CR30002778
2883
2884   *Begin of <RD1K975843> CAB_ALOK CR 30005441
2885   ** 6. Warning for Due Date in future.
2886   * In case due date (ZFBDT) is greater than today's date by more than 7 days, give caution in main list.
2887         LOOP AT ist_srcbsik INTO wa_srcbsik .
2888           CLEAR t_days_diff.
2889           t_days_diff = wa_srcbsik-zfbdt - sy-datum .
2890           IF t_days_diff > 7.
2891             wa_srcbsik-reason = 'Due Date in future'.
2892             MODIFY ist_srcbsik FROM wa_srcbsik TRANSPORTING reason.
2893           ENDIF.
2894         ENDLOOP.
2895
2896   ** 7. Validation on linked documents: Pymt Method in linked docs should be same
2897         DATA : ist_srcbsik_tmp  LIKE STANDARD TABLE OF ist_srcbsik,
2898                wa_srcbsik_tmp  LIKE LINE OF ist_srcbsik,
2899                zlsch_inconsistent(1) .
2900
2901         ist_srcbsik_tmp[] = ist_srcbsik[].
2902         SORT ist_srcbsik_tmp BY subgrp.
2903         DELETE ADJACENT DUPLICATES FROM ist_srcbsik_tmp COMPARING subgrp.
2904
2905         CLEAR wa_srcbsik_tmp.
2906         LOOP AT ist_srcbsik_tmp INTO wa_srcbsik_tmp .
2907           LOOP AT ist_srcbsik INTO wa_srcbsik WHERE subgrp = wa_srcbsik_tmp-subgrp.
2908             IF wa_srcbsik_tmp-zlsch <> wa_srcbsik-zlsch.
2909               zlsch_inconsistent = 'X'. "at-least one mismatch of ZLSCH found, set Flag.
2910             ENDIF.
2911           ENDLOOP.
2912           IF zlsch_inconsistent = 'X'.
2913             LOOP AT ist_srcbsik INTO wa_srcbsik WHERE subgrp = wa_srcbsik_tmp-subgrp.
2914               wa_srcbsik-inactiv = 'X'.
2915               wa_srcbsik-reason = 'Inconsistent PM in Docs'.
2916               MODIFY ist_srcbsik FROM wa_srcbsik TRANSPORTING inactiv reason.
2917             ENDLOOP.
2918           ENDIF.
2919           CLEAR: zlsch_inconsistent, wa_srcbsik_tmp.
2920         ENDLOOP.
2921
2922
2923   *Begin of <RD1K975843> CAB_ALOK CR 30005441
2924   ** 4a.  In case P_BUKRS in table 'ZFI_C_N_B_CC1' (ONGC comp codes) and line-ZLSCH  in table 'ZFI_C_B_BLOCKPM1'
2925   *  check line-ZLSCH same as LFB1-ZWELS where LFB1-LIFNR = S_LIFNR-LOW and LFB1-BUKRS = P_BUKRS.
2926
2927         CLEAR: wa_zfi_c_n_b_cc1, wa_zfi_c_b_blockpm1.
2928
2929         SELECT SINGLE * FROM zfi_c_n_b_cc1
2930           INTO wa_zfi_c_n_b_cc1
2931             WHERE bukrs = p_bukrs.
2932
2933         IF sy-subrc = 0. "comp. code found in table ZFI_C_N_B_CC1
2934
2935           REFRESH ist_vend.
2936           SELECT lifnr bukrs zwels  INTO CORRESPONDING FIELDS OF TABLE ist_vend
2937             FROM lfb1
2938               FOR ALL ENTRIES IN ist_srcbsik
2939                WHERE lifnr = ist_srcbsik-lifnr
2940                AND bukrs = p_bukrs.  "#EC CI_NOORDER
2941           CLEAR: wa_srcbsik.
2942
2943           LOOP AT ist_srcbsik INTO wa_srcbsik.
2944             l_tabix = sy-tabix.
2945
2946             SELECT SINGLE * FROM zfi_c_b_blockpm1
2947                INTO wa_zfi_c_b_blockpm1
2948                  WHERE zlsch = wa_srcbsik-zlsch.
2949
2950             IF sy-subrc = 0. " paymt method zlsch found in table ZFI_C_B_BLOCKPM1
2951               READ TABLE ist_vend INTO wa_vend WITH KEY lifnr = wa_srcbsik-lifnr
2952                                                           bukrs = wa_srcbsik-bukrs  .
2953
2954               IF  wa_srcbsik-zlsch <> wa_vend-zwels.
2955                 wa_srcbsik-inactiv = 'X'.
2956                 wa_srcbsik-reason = 'Diff Pymt Method in vendor master'. " 'Pymt Method Mismatch'.
2957                 MODIFY ist_srcbsik FROM wa_srcbsik INDEX l_tabix TRANSPORTING inactiv reason.
2958               ENDIF.
2959             ENDIF." /sy-subrc = 0. " paymt method zlsch
2960
2961             CLEAR: wa_srcbsik.
2962           ENDLOOP.
2963
2964         ENDIF. " /sy-subrc = 0. "comp. code
2965
2966   ** 4b. In case P_BUKRS in table 'ZFI_C_N_B_CC2'(OVL comp codes) and line-ZLSCH  in table 'ZFI_C_B_BLOCKPM2',
2967   *  check line-ZLSCH same as LFB1-ZWELS where LFB1-LIFNR = S_LIFNR-LOW and LFB1-BUKRS = P_BUKRS.
2968         CLEAR: wa_zfi_c_n_b_cc2, wa_zfi_c_b_blockpm2.
2969
2970         SELECT SINGLE * FROM zfi_c_n_b_cc2
2971           INTO wa_zfi_c_n_b_cc2
2972             WHERE bukrs = p_bukrs.
2973
2974         IF sy-subrc = 0. "comp. code found in table ZFI_C_N_B_CC2
2975
2976           REFRESH ist_vend.
2977           SELECT lifnr bukrs zwels  INTO CORRESPONDING FIELDS OF TABLE ist_vend
2978             FROM lfb1
2979               FOR ALL ENTRIES IN ist_srcbsik
2980                WHERE lifnr = ist_srcbsik-lifnr
2981                AND bukrs = p_bukrs.  "#EC CI_NOORDER
2982           CLEAR: wa_srcbsik.
2983
2984           LOOP AT ist_srcbsik INTO wa_srcbsik.
2985             l_tabix = sy-tabix.
2986
2987             SELECT SINGLE * FROM zfi_c_b_blockpm2
2988                INTO wa_zfi_c_b_blockpm2
2989                  WHERE zlsch = wa_srcbsik-zlsch.
2990
2991             IF sy-subrc = 0. " paymt method zlsch found in table ZFI_C_B_BLOCKPM2
2992               READ TABLE ist_vend INTO wa_vend WITH KEY lifnr = wa_srcbsik-lifnr
2993                                                           bukrs = wa_srcbsik-bukrs  .
2994
2995               IF  wa_srcbsik-zlsch <> wa_vend-zwels.
2996                 wa_srcbsik-inactiv = 'X'.
2997                 wa_srcbsik-reason = 'Diff Pymt Method in vendor master'.    " 'Pymt Method Mismatch'.
2998                 MODIFY ist_srcbsik FROM wa_srcbsik INDEX l_tabix TRANSPORTING inactiv reason.
2999               ENDIF.
3000             ENDIF." /sy-subrc = 0. " paymt method zlsch
3001
3002             CLEAR: wa_srcbsik.
3003           ENDLOOP.
3004
3005         ENDIF. " /sy-subrc = 0. "comp. code
3006
3007   *End of <RD1K975843> CAB_ALOK CR 30005441
3008
3009
3010   ** 8. Validation on linked documents:
3011   * Send whole set of linked docs to exception, if
3012   *     a) due date in Rec doc > curr date
3013   *     OR b) due date in Rec doc > liab doc
3014   * above conditions modified:
3015   *     a1) RD > CD > LD
3016   *     OR b1) RD > LD > CD , where CD - Current system date, RD - Due date in Recovery document,
3017   *                              LD - Due date in Liability document
3018
3019         DATA: due_date_flag(1) .
3020         REFRESH ist_srcbsik_tmp.
3021         ist_srcbsik_tmp[] = ist_srcbsik[].
3022         SORT ist_srcbsik_tmp BY subgrp.
3023         DELETE  ist_srcbsik_tmp WHERE shkzg <> 'H'.  " store only Liab. docs.
3024   *    delete ADJACENT DUPLICATES FROM ist_srcbsik_tmp comparing subgrp.
3025         CLEAR wa_srcbsik_tmp.
3026         LOOP AT ist_srcbsik_tmp INTO wa_srcbsik_tmp .   " Liab docs
3027           LOOP AT ist_srcbsik INTO wa_srcbsik WHERE subgrp = wa_srcbsik_tmp-subgrp AND shkzg = 'S'.  "Recov. Docs of the same sub-grp as Liab doc
3028
3029   *       if ( wa_srcbsik-zfbdt > sy-datum ) or ( wa_srcbsik-zfbdt > wa_srcbsik_tmp-zfbdt ) .
3030             IF ( ( wa_srcbsik-zfbdt > sy-datum ) AND ( sy-datum > wa_srcbsik_tmp-zfbdt ) )  " modified conditions
3031               OR ( ( wa_srcbsik-zfbdt > wa_srcbsik_tmp-zfbdt ) AND ( wa_srcbsik_tmp-zfbdt > sy-datum ) ).
3032               due_date_flag = 'X'. "at-least one due date valiadation failed, set Flag.
3033             ENDIF.
3034           ENDLOOP.
3035           IF due_date_flag = 'X'.
3036             LOOP AT ist_srcbsik INTO wa_srcbsik WHERE subgrp = wa_srcbsik_tmp-subgrp.
3037               wa_srcbsik-inactiv = 'X'.
3038               wa_srcbsik-reason = 'Due date in future'.
3039               MODIFY ist_srcbsik FROM wa_srcbsik TRANSPORTING inactiv reason.
3040             ENDLOOP.
3041           ENDIF.
3042           CLEAR: due_date_flag, wa_srcbsik_tmp.
3043         ENDLOOP.
3044   *End of <RD1K975843> CAB_ALOK CR 30005441
3045
3046   * move inactive lines to ist_srcbsik_inactiv
3047         LOOP AT ist_srcbsik INTO wa_srcbsik WHERE inactiv = 'X'.
3048           APPEND wa_srcbsik TO ist_srcbsik_inactiv.
3049         ENDLOOP.
3050         DELETE ist_srcbsik WHERE inactiv = 'X'.
3051
3052       ENDIF.                                                  " p_x2sp
3053     ENDIF. " ist_srcbsik
3054   ENDFORM.                    " VALIDATE_DOCS
3055   *&---------------------------------------------------------------------*
3056   *&      Form  VALIDATE_DOCS_CUST
3057   *&---------------------------------------------------------------------*
3058   *       text
3059   *----------------------------------------------------------------------*
3060   *  -->  p1        text
3061   *  <--  p2        text
3062   *----------------------------------------------------------------------*
3063   FORM validate_docs_cust .
3064   *BEGIN OF <rd1k967585> cab_alok 26.11.2009 cr30002778
3065     DATA : ist_kid LIKE  ist_srcbsid OCCURS 0.
3066   * end of <RD1K967585> CAB_ALOK 26.11.2009 CR30002778
3067     DATA : wa_kid LIKE ist_srcbsid.
3068     DATA : g_actflag TYPE c.
3069     DATA :l_dmbtr TYPE bseg-dmbtr.
3070   *BEGIN OF <rd1k967585> cab_alok 26.11.2009 cr30002778
3071     DATA :l_tabix TYPE sy-tabix.
3072   * end of <RD1K967585> CAB_ALOK 26.11.2009 CR30002778
3073     IF p_x2sp = 'X'.
3074   ** BEGIN OF <rd1k967585> cab_alok 04.12.2009 cr30002778
3075
3076   *  ENDIF.
3077   **----custor blocked ????
3078   *  TYPES :BEGIN OF ty_cust,
3079   *         kunnr TYPE knb1-kunnr ,
3080   *         bukrs TYPE knb1-bukrs,
3081   *         sperr TYPE knb1-sperr,
3082   *         zahls TYPE knb1-zahls,
3083   *         loevm TYPE knb1-loevm,
3084   *         END OF ty_cust.
3085   *
3086   *  DATA :ist_cust TYPE TABLE OF ty_cust.
3087   *  DATA :wa_cust TYPE ty_cust.
3088   *  DATA :l_tabix TYPE sy-tabix.
3089   *
3090   *  SELECT kunnr bukrs sperr zahls loevm  INTO TABLE ist_cust
3091   *    FROM knb1
3092   *    FOR ALL ENTRIES IN ist_srcbsid
3093   *    WHERE kunnr = ist_srcbsid-kunnr
3094   *    AND bukrs = p_bukrs.
3095   *
3096   *  LOOP AT ist_srcbsid INTO wa_srcbsid.
3097   *    l_tabix = sy-tabix.
3098   *    READ TABLE ist_cust INTO wa_cust WITH KEY kunnr = wa_srcbsid-kunnr.
3099   *    IF sy-subrc = 0.
3100   *      IF wa_cust-sperr = 'X'.
3101   *        wa_srcbsid-inactiv = 'X'.
3102   *        wa_srcbsid-reason = 'Posting block for compnay code'.
3103   *      ELSEIF wa_cust-zahls = 'X'.
3104   *        wa_srcbsid-inactiv = 'X'.
3105   *        wa_srcbsid-reason = 'Blocked for Payment'.
3106   *      ELSEIF wa_cust-loevm = 'X'.
3107   *        wa_srcbsid-inactiv = 'X'.
3108   *        wa_srcbsid-reason = 'Marked for Deletion'.
3109   *      ENDIF.
3110   *      MODIFY ist_srcbsid FROM wa_srcbsid INDEX l_tabix TRANSPORTING
3111   *            inactiv reason.
3112   *    ENDIF.
3113   *
3114   *  ENDLOOP.
3115   * =============
3116   *** Validate ist_srcbsid for different conditions and move inactive items into ist_srcbsid_inactiv
3117
3118   ** add serial no. to ist_srcbsid
3119       DATA srno TYPE i. "serial no.
3120       srno = 0.
3121       LOOP AT ist_srcbsid INTO wa_srcbsid.
3122         srno = srno + 1.
3123         wa_srcbsid-serial_no = srno.
3124         MODIFY ist_srcbsid FROM wa_srcbsid TRANSPORTING serial_no.
3125       ENDLOOP.
3126   ** save original ist_srcbsid
3127   *ist_srcbsid_orig = ist_srcbsid
3128       ist_srcbsid_orig[] = ist_srcbsid[].
3129   *** Check each line of ist_srcbsid:
3130   ** if customer is blocked or deleted, put the reason and make the line item inactive
3131
3132       SORT ist_srcbsid  BY kunnr kidno.
3133       TYPES :BEGIN OF ty_cust,
3134   *         kunnr TYPE kna1-kunnr ,  "char 10
3135              kunnr TYPE vcnum-ccnum,                          "char 25
3136              bukrs TYPE knb1-bukrs,
3137              sperr TYPE knb1-sperr,
3138              zahls TYPE knb1-zahls,
3139              loevm TYPE knb1-loevm,
3140              ktokd TYPE kna1-ktokd,     " account grp
3141              END OF ty_cust.
3142
3143       DATA : ist_cust TYPE TABLE OF ty_cust.
3144       DATA : wa_cust TYPE ty_cust.
3145
3146       TYPES :BEGIN OF ty_imprest,
3147              cardno TYPE zfiimprest-cardno ,
3148              ackon TYPE zfiimprest-ackon ,
3149              END OF ty_imprest.
3150
3151       DATA : ist_imprest TYPE TABLE OF ty_imprest.
3152       DATA : wa_imprest TYPE ty_imprest.
3153
3154       TYPES :BEGIN OF ty_vcnum,
3155              ccnum TYPE vcnum-ccnum ,   "card no.,  char(25)
3156              datbi TYPE vcnum-datbi ,   " Exp. date
3157              END OF ty_vcnum.
3158
3159       DATA : ist_vcnum TYPE TABLE OF ty_vcnum.
3160       DATA : wa_vcnum TYPE ty_vcnum.
3161
3162       DATA : tmp_kunnr TYPE vcnum-ccnum.   "card no.,  char(25), temp holding.
3163
3164   ** 1. For a given customer, posting blocked or marked deleted for given company code?
3165       SELECT kunnr bukrs sperr zahls loevm  INTO TABLE ist_cust
3166         FROM knb1
3167         FOR ALL ENTRIES IN ist_srcbsid
3168         WHERE kunnr = ist_srcbsid-kunnr
3169         AND bukrs = p_bukrs.
3170   *{ Begin of CR 30007632
3171       DATA : ist_zfiimprest TYPE STANDARD TABLE OF zfiimprest,
3172             ist_zfiimprest_l TYPE STANDARD TABLE OF zfiimprest,
3173             wa_zfiimprest TYPE zfiimprest.
3174       CLEAR :ist_zfiimprest.
3175       REFRESH :ist_zfiimprest.
3176       SELECT * FROM zfiimprest
3177         INTO CORRESPONDING FIELDS OF TABLE ist_zfiimprest
3178         FOR ALL ENTRIES IN ist_srcbsid
3179             WHERE cardno = ist_srcbsid-kunnr.  "#EC CI_NOORDER
3180
3181
3182   *}End of CR 30007632
3183       CLEAR: wa_srcbsid.
3184       LOOP AT ist_srcbsid INTO wa_srcbsid.
3185         l_tabix = sy-tabix.
3186   *{ Begin of CR 30007632
3187         IF wa_srcbsid-shkzg = 'H'.
3188           IF NOT ist_zfiimprest[] IS INITIAL.
3189             READ TABLE ist_zfiimprest INTO wa_zfiimprest INDEX 1.  "#EC CI_NOORDER
3190             IF wa_zfiimprest-reqstat = 'RET'.
3191               wa_srcbsid-inactiv = 'X'.
3192               wa_srcbsid-reason = 'Imprest card with RET status'.
3193             ENDIF.
3194           ENDIF.
3195         ENDIF.
3196   *}End of CR 30007632
3197         DATA : l_stat(12) TYPE c.
3198         CLEAR l_stat.
3199         IF NOT ist_zfiimprest[] IS INITIAL.
3200           LOOP AT ist_zfiimprest INTO wa_zfiimprest WHERE cardno = wa_srcbsid-kunnr.
3201             APPEND wa_zfiimprest TO ist_zfiimprest_l.
3202           ENDLOOP.
3203           IF wa_srcbsid-shkzg = 'H'.
3204             IF NOT ist_zfiimprest_l[] IS INITIAL.
3205   *            sort ist_zfiimprest_l by reqno descending.
3206               SORT ist_zfiimprest_l BY ackon DESCENDING.
3207               READ TABLE ist_zfiimprest_l INTO wa_zfiimprest INDEX 1.
3208               IF wa_zfiimprest-reqstat = 'RET' OR wa_zfiimprest-reqstat = 'SUR'.
3209                 wa_srcbsid-inactiv = 'X'.
3210                 wa_srcbsid-reason = 'PREPAID CARD'.
3211                 IF wa_zfiimprest-reqstat = 'RET'.
3212                   l_stat = 'Returned'.
3213                 ELSEIF wa_zfiimprest-reqstat = 'SUR'.
3214                   l_stat = 'Surrendered'.
3215                 ENDIF.
3216                 CONCATENATE wa_srcbsid-reason text-012 l_stat INTO wa_srcbsid-reason SEPARATED BY space.
3217               ENDIF.
3218             ENDIF.
3219           ENDIF.
3220         ENDIF.
3221         READ TABLE ist_cust INTO wa_cust WITH KEY kunnr = wa_srcbsid-kunnr
3222                                                    bukrs = wa_srcbsid-bukrs  .
3223         IF sy-subrc = 0.
3224           IF wa_cust-sperr = 'X'.
3225             wa_srcbsid-inactiv = 'X'.
3226             wa_srcbsid-reason = 'Posting blocked for company code'.
3227           ELSEIF wa_cust-zahls = 'X'.
3228             wa_srcbsid-inactiv = 'X'.
3229             wa_srcbsid-reason = 'Blocked for Payment'.
3230           ELSEIF wa_cust-loevm = 'X'.
3231             wa_srcbsid-inactiv = 'X'.
3232             wa_srcbsid-reason = 'Marked for Deletion-company code level'.
3233           ENDIF.
3234           MODIFY ist_srcbsid FROM wa_srcbsid INDEX l_tabix TRANSPORTING inactiv reason.
3235         ENDIF.
3236         CLEAR: wa_srcbsid.
3237       ENDLOOP.
3238
3239   ** 2. For a given customer, posting blocked or deleted for all company codes?
3240       REFRESH ist_cust.
3241       SELECT kunnr loevm sperr INTO CORRESPONDING FIELDS OF TABLE ist_cust
3242         FROM kna1
3243         FOR ALL ENTRIES IN ist_srcbsid
3244         WHERE kunnr = ist_srcbsid-kunnr.  "#EC CI_NOORDER
3245       CLEAR: wa_srcbsid.
3246       LOOP AT ist_srcbsid INTO wa_srcbsid.
3247         l_tabix = sy-tabix.
3248         READ TABLE ist_cust INTO wa_cust WITH KEY kunnr = wa_srcbsid-kunnr.
3249         IF sy-subrc = 0.
3250           IF wa_cust-sperr = 'X'.
3251             wa_srcbsid-inactiv = 'X'.
3252             wa_srcbsid-reason = 'Central Posting blocked'.
3253           ELSEIF wa_cust-loevm = 'X'.
3254             wa_srcbsid-inactiv = 'X'.
3255             wa_srcbsid-reason = 'Central Deletion Flag'.
3256           ENDIF.
3257           MODIFY ist_srcbsid FROM wa_srcbsid INDEX l_tabix TRANSPORTING inactiv reason.
3258         ENDIF.
3259         CLEAR: wa_srcbsid.
3260       ENDLOOP.
3261
3262   ** 3. card customer? old logic: found in ZFIIMPREST table? if date ZFIIMPREST-ACKON = 00000000 => not acknowledged? => exception
3263   **  Revised logic for card customer
3264   *a. get Customer number with account group as IMPR
3265   *b. Concatenate 421687 to the customer number to get the card number
3266   *c. Search this card number in table VCNUM for record where Exp date is not blank and is greater than system date
3267   *d. All such sucessful lines shud be put in active list else in exception list
3268   ******** BOOK MARK
3269       SELECT kunnr ktokd INTO CORRESPONDING FIELDS OF TABLE ist_cust " select all card customers of ist_srcbsid
3270             FROM kna1                                                 " into ist_cust. (condition: corresponding  a/c grp KNA1-ktokd shud be 'IMPR'
3271             FOR ALL ENTRIES IN ist_srcbsid
3272             WHERE kunnr = ist_srcbsid-kunnr
3273                   AND ktokd = 'IMPR'.
3274
3275   *SELECT cardno ackon INTO CORRESPONDING FIELDS OF TABLE ist_imprest "  for all card customers (ist_cust)
3276   *      FROM zfiimprest                                                 " select data (Card No. i.e. kunnr & ACK Date) from ZFIIMPREST into ist_imprest.
3277   *      FOR ALL ENTRIES IN ist_cust
3278   *      WHERE cardno = ist_cust-kunnr.
3279   ***            and ackon <> ''.
3280
3281       LOOP AT ist_cust INTO wa_cust.
3282         l_tabix = sy-tabix.
3283         CONCATENATE '421687' wa_cust-kunnr INTO wa_cust-kunnr.
3284         MODIFY ist_cust FROM wa_cust INDEX l_tabix TRANSPORTING kunnr.
3285       ENDLOOP.
3286
3287       SELECT ccnum datbi INTO CORRESPONDING FIELDS OF TABLE ist_vcnum "  for all card customers (ist_cust)
3288             FROM vcnum
3289             FOR ALL ENTRIES IN ist_cust
3290             WHERE ccnum = ist_cust-kunnr.
3291
3292   *SORT ist_imprest BY cardno ASCENDING.
3293   *   DELETE ADJACENT DUPLICATES FROM ist_imprest COMPARING cardno.
3294
3295   *    CLEAR: wa_srcbsid.
3296   *    LOOP AT ist_srcbsid INTO wa_srcbsid.
3297   *      l_tabix = sy-tabix.
3298   *      READ TABLE ist_cust INTO wa_cust WITH KEY kunnr = wa_srcbsid-kunnr .
3299   *       IF sy-subrc = 0. " => kunnr is a card-customer. Now check whether it exists in ZFIIMPREST or not
3300   *         READ TABLE ist_imprest into wa_imprest with key cardno = wa_srcbsid-kunnr.
3301   *           if sy-subrc = 0. " => cardno found in ZFIIMPREST, now we need to check its ACKON
3302   *              if wa_imprest-ackon = 0.    "if ACKON date = 00000000, corresponding ist_srcbsid line shud be inactive
3303   *                  wa_srcbsid-inactiv = 'X'.
3304   *                  wa_srcbsid-reason = 'Card customer, no ACK'.
3305   *              endif.
3306   *           else.  "cardno not found in ZFIIMPREST, corresponding ist_srcbsid line shud be inactive.
3307   *             wa_srcbsid-inactiv = 'X'.
3308   *             wa_srcbsid-reason = 'Card customer, not in ZFIIMPREST'.
3309   *           endif.
3310   *           MODIFY ist_srcbsid FROM wa_srcbsid INDEX l_tabix TRANSPORTING inactiv reason.
3311   *       endif.
3312   *
3313   *    ENDLOOP.
3314
3315       CLEAR: wa_srcbsid.
3316       LOOP AT ist_srcbsid INTO wa_srcbsid.
3317         l_tabix = sy-tabix.
3318         CONCATENATE '421687' wa_srcbsid-kunnr INTO tmp_kunnr.
3319         READ TABLE ist_cust INTO wa_cust WITH KEY kunnr = tmp_kunnr .
3320         IF sy-subrc = 0. " => kunnr is a card-customer. Now check whether it exists in ZFIIMPREST or not
3321           READ TABLE ist_vcnum INTO wa_vcnum WITH KEY ccnum = tmp_kunnr.
3322           IF sy-subrc = 0. " => cardno found in VCNUM, now we need to check its Expiry Date (DATBI)
3323             IF wa_vcnum-datbi < sy-datum.    "if EXP date < current date, corresponding ist_srcbsid line shud be inactive
3324               wa_srcbsid-inactiv = 'X'.
3325               wa_srcbsid-reason = 'Card customer, curr date>Exp date '.
3326             ENDIF.
3327           ELSE.  "cardno not found in VCNUM, corresponding ist_srcbsid line shud be inactive.
3328             wa_srcbsid-inactiv = 'X'.
3329             wa_srcbsid-reason = 'Card customer, not in VCNUM'.
3330           ENDIF.
3331           MODIFY ist_srcbsid FROM wa_srcbsid INDEX l_tabix TRANSPORTING inactiv reason.
3332         ENDIF.
3333
3334       ENDLOOP.
3335
3336   *begin of <RD1K967585> CAB_ALOK 01.12.2009 CR30002778
3337   *Move inactive lines to ist_srcbsid_inactiv
3338       ist_srcbsid_inactiv[] = ist_srcbsid[].
3339       DELETE ist_srcbsid_inactiv WHERE inactiv <> 'X'. "ist_srcbsid_inactiv contains inactive items
3340       DELETE ist_srcbsid WHERE inactiv = 'X'.  "ist_srcbsid contains active items
3341   *end of <RD1K967585> CAB_ALOK 01.12.2009 CR30002778
3342
3343     ENDIF. "p_x2sp = 'X
3344   ** end OF <rd1k967585> cab_alok 04.12.2009 cr30002778
3345   ENDFORM.                    " VALIDATE_DOCS_CUST
3346   *&---------------------------------------------------------------------*
3347   *&      Form  INIT_FIELDCAT_INACTIV
3348   *&---------------------------------------------------------------------*
3349   *       text
3350   *----------------------------------------------------------------------*
3351   *  -->  p1        text
3352   *  <--  p2        text
3353   *----------------------------------------------------------------------*
3354   *begin of <RD1K967585> CAB_ALOK 26.11.2009 CR30002778
3355   FORM init_fieldcat_inactiv .
3356     w_repid  = sy-repid.
3357     mpos = 0.
3358
3359     mpos = mpos + 1.
3360     ist_fieldcat_inactiv-fieldname = 'SELCBOX'.
3361     ist_fieldcat_inactiv-tabname = 'IST_SRCBSIK_INACTIV'.
3362     ist_fieldcat_inactiv-ddictxt = 'M'.
3363     ist_fieldcat_inactiv-col_pos =  mpos.
3364     ist_fieldcat_inactiv-seltext_m  = 'Inactiv'.
3365     ist_fieldcat_inactiv-lowercase  = 'Y'.
3366     ist_fieldcat_inactiv-checkbox = 'X'.
3367   *  ist_fieldcat_inactiv-input = 'X'.  " no input allowed.
3368   *  ist_fieldcat_inactiv-edit = 'X'.
3369     APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3370     CLEAR ist_fieldcat_inactiv.
3371
3372     mpos = mpos + 1.
3373     ist_fieldcat_inactiv-fieldname = 'LIFNR'.
3374     ist_fieldcat_inactiv-tabname = 'IST_SRCBSIK_INACTIV'.
3375     ist_fieldcat_inactiv-ddictxt = 'M'.
3376     ist_fieldcat_inactiv-col_pos =  mpos.
3377   *begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
3378   *  ist_fieldcat_inactiv-seltext_m  = 'VendorNumber'.
3379     ist_fieldcat_inactiv-seltext_m  = 'Vendor No.'.
3380   *end of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
3381     ist_fieldcat_inactiv-lowercase  = 'Y'.
3382     APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3383     CLEAR ist_fieldcat_inactiv.
3384
3385     mpos = mpos + 1.
3386     ist_fieldcat_inactiv-fieldname = 'BELNR'.
3387     ist_fieldcat_inactiv-tabname = 'IST_SRCBSIK_INACTIV'.
3388     ist_fieldcat_inactiv-ddictxt = 'M'.
3389     ist_fieldcat_inactiv-col_pos =  mpos.
3390     ist_fieldcat_inactiv-seltext_m  = 'Doc.No.'.
3391     ist_fieldcat_inactiv-lowercase  = 'Y'.
3392     APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3393     CLEAR ist_fieldcat_inactiv.
3394
3395   *begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
3396   *  mpos = mpos + 1.
3397   *  ist_fieldcat_inactiv-fieldname = 'GSBER'.
3398   *  ist_fieldcat_inactiv-tabname = 'IST_SRCBSIK_INACTIV'.
3399   *  ist_fieldcat_inactiv-ddictxt = 'M'.
3400   *  ist_fieldcat_inactiv-col_pos =  mpos.
3401   *  ist_fieldcat_inactiv-seltext_m  = 'Business Area'.
3402   *  ist_fieldcat_inactiv-lowercase  = 'Y'.
3403   *  APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3404   *  CLEAR ist_fieldcat_inactiv.
3405   *end of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
3406
3407     mpos = mpos + 1.
3408     ist_fieldcat_inactiv-fieldname = 'KIDNO'.
3409     ist_fieldcat_inactiv-tabname = 'IST_SRCBSIK_INACTIV'.
3410     ist_fieldcat_inactiv-ddictxt = 'M'.
3411     ist_fieldcat_inactiv-col_pos =  mpos.
3412   *begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
3413   *  ist_fieldcat_inactiv-seltext_m  = 'Payment Reference'.
3414     ist_fieldcat_inactiv-seltext_m  = 'Pymt Ref'.
3415   *end of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
3416     ist_fieldcat_inactiv-lowercase  = 'Y'.
3417     APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3418     CLEAR ist_fieldcat_inactiv.
3419
3420     mpos = mpos + 1.
3421     ist_fieldcat_inactiv-fieldname = 'REASON'.
3422     ist_fieldcat_inactiv-tabname = 'IST_SRCBSIK_INACTIV'.
3423     ist_fieldcat_inactiv-ddictxt = 'M'.
3424     ist_fieldcat_inactiv-col_pos =  mpos.
3425     ist_fieldcat_inactiv-seltext_m  = 'Reason'.
3426   *  ist_fieldcat_inactiv-lowercase  = 'Y'.
3427     APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3428     CLEAR ist_fieldcat_inactiv.
3429
3430     mpos = mpos + 1.
3431     ist_fieldcat_inactiv-fieldname = 'REBZG'.
3432     ist_fieldcat_inactiv-tabname = 'IST_SRCBSIK_INACTIV'.
3433     ist_fieldcat_inactiv-ddictxt = 'M'.
3434     ist_fieldcat_inactiv-col_pos =  mpos.
3435   *begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
3436   *    ist_fieldcat_inactiv-seltext_m  = 'Invoice Reference'.
3437     ist_fieldcat_inactiv-seltext_m  = 'Inv Ref'.
3438   *end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
3439   *  ist_fieldcat_inactiv-lowercase  = 'Y'.
3440     APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3441     CLEAR ist_fieldcat_inactiv.
3442
3443   *begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
3444   *  mpos = mpos + 1.
3445   *  ist_fieldcat_inactiv-fieldname = 'SHKZG'.
3446   *  ist_fieldcat_inactiv-tabname = 'IST_SRCBSIK_INACTIV'.
3447   *  ist_fieldcat_inactiv-ddictxt = 'M'.
3448   *  ist_fieldcat_inactiv-col_pos =  mpos.
3449   *  ist_fieldcat_inactiv-seltext_m  = 'Indicator'.
3450   **  ist_fieldcat_inactiv-lowercase  = 'Y'.
3451   *  APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3452   *  CLEAR ist_fieldcat_inactiv.
3453   *  mpos = mpos + 1.
3454   *  ist_fieldcat_inactiv-fieldname = 'GJAHR'.
3455   *  ist_fieldcat_inactiv-tabname = 'IST_SRCBSIK_INACTIV'.
3456   *  ist_fieldcat_inactiv-ddictxt = 'M'.
3457   *  ist_fieldcat_inactiv-col_pos =  mpos.
3458   *  ist_fieldcat_inactiv-seltext_m  = 'Year'.
3459   *  ist_fieldcat_inactiv-lowercase  = 'Y'.
3460   *  APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3461   *  CLEAR ist_fieldcat_inactiv.
3462   *end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
3463
3464     mpos = mpos + 1.
3465     ist_fieldcat_inactiv-fieldname = 'BUZEI'.
3466     ist_fieldcat_inactiv-tabname = 'IST_SRCBSIK_INACTIV'.
3467     ist_fieldcat_inactiv-ddictxt = 'M'.
3468     ist_fieldcat_inactiv-col_pos =  mpos.
3469     ist_fieldcat_inactiv-seltext_m  = 'Item.no.'.
3470     ist_fieldcat_inactiv-lowercase  = 'Y'.
3471     APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3472     CLEAR ist_fieldcat_inactiv.
3473
3474     mpos = mpos + 1.
3475     ist_fieldcat_inactiv-fieldname = 'BSCHL'.
3476     ist_fieldcat_inactiv-tabname = 'IST_SRCBSIK_INACTIV'.
3477     ist_fieldcat_inactiv-ddictxt = 'M'.
3478     ist_fieldcat_inactiv-col_pos =  mpos.
3479   *begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
3480   *  ist_fieldcat_inactiv-seltext_m  = 'Posting Key.'.
3481     ist_fieldcat_inactiv-seltext_m  = 'PK'.
3482   *end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
3483     ist_fieldcat_inactiv-lowercase  = 'Y'.
3484     APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3485     CLEAR ist_fieldcat_inactiv.
3486
3487     mpos = mpos + 1.
3488     ist_fieldcat_inactiv-fieldname = 'BUDAT'.
3489     ist_fieldcat_inactiv-tabname = 'IST_SRCBSIK_INACTIV'.
3490     ist_fieldcat_inactiv-ddictxt = 'M'.
3491     ist_fieldcat_inactiv-col_pos =  mpos.
3492   *begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
3493   *  ist_fieldcat_inactiv-seltext_m  = 'Posting Date'.
3494     ist_fieldcat_inactiv-seltext_m  = 'Post Dt'.
3495   *end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
3496     ist_fieldcat_inactiv-lowercase  = 'Y'.
3497     APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3498     CLEAR ist_fieldcat_inactiv.
3499
3500   * begin RD1K975843 CAB_ALOK CR 30005441
3501     mpos = mpos + 1.
3502     ist_fieldcat_inactiv-fieldname = 'ZFBDT'.
3503     ist_fieldcat_inactiv-tabname = 'IST_SRCBSIK_INACTIV'.
3504     ist_fieldcat_inactiv-ddictxt = 'M'.
3505     ist_fieldcat_inactiv-col_pos =  mpos.
3506     ist_fieldcat_inactiv-seltext_m  = 'Due Dt.'.
3507     ist_fieldcat_inactiv-lowercase  = 'Y'.
3508     APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3509     CLEAR ist_fieldcat_inactiv.
3510   * end RD1K975843 CAB_ALOK CR 30005441
3511
3512   *begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
3513   *  mpos = mpos + 1.
3514   *  ist_fieldcat_inactiv-fieldname = 'DMBTR'.
3515   *  ist_fieldcat_inactiv-tabname = 'IST_SRCBSIK_INACTIV'.
3516   *  ist_fieldcat_inactiv-ddictxt = 'M'.
3517   *  ist_fieldcat_inactiv-col_pos =  mpos.
3518   *  ist_fieldcat_inactiv-seltext_m  = 'AmtInLclCurncy'.
3519   *  ist_fieldcat_inactiv-lowercase  = 'Y'.
3520   *  APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3521   *  CLEAR ist_fieldcat_inactiv.
3522   *end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
3523
3524     mpos = mpos + 1.
3525     ist_fieldcat_inactiv-fieldname = 'SUBTOT'.
3526     ist_fieldcat_inactiv-tabname = 'IST_SRCBSIK_INACTIV'.
3527     ist_fieldcat_inactiv-ddictxt = 'M'.
3528     ist_fieldcat_inactiv-col_pos =  mpos.
3529     ist_fieldcat_inactiv-seltext_m  = 'SubTotal'.
3530     ist_fieldcat_inactiv-lowercase  = 'Y'.
3531     APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3532     CLEAR ist_fieldcat_inactiv.
3533
3534     mpos = mpos + 1.
3535     ist_fieldcat_inactiv-fieldname = 'WRBTR'.
3536     ist_fieldcat_inactiv-tabname = 'IST_SRCBSIK_INACTIV'.
3537     ist_fieldcat_inactiv-ddictxt = 'M'.
3538     ist_fieldcat_inactiv-col_pos =  mpos.
3539   *begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
3540   *  ist_fieldcat_inactiv-seltext_m  = 'AmtInDocCurncy'.
3541     ist_fieldcat_inactiv-seltext_m  = 'Amt In Doc Cur'.
3542   *end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
3543     ist_fieldcat_inactiv-lowercase  = 'Y'.
3544     APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3545     CLEAR ist_fieldcat_inactiv.
3546
3547   * begin of < RD1K970594> CAB_ALOK 10.03.2010 CR30003739
3548     mpos = mpos + 1.
3549     ist_fieldcat_inactiv-fieldname = 'WAERS'.
3550     ist_fieldcat_inactiv-tabname = 'IST_SRCBSIK_INACTIV'.
3551     ist_fieldcat_inactiv-ddictxt = 'M'.
3552     ist_fieldcat_inactiv-col_pos =  mpos.
3553     ist_fieldcat_inactiv-seltext_m  = 'Curr'.
3554     ist_fieldcat_inactiv-lowercase  = 'Y'.
3555     APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3556     CLEAR ist_fieldcat_inactiv.
3557   * end of < RD1K970594> CAB_ALOK 10.03.2010 CR30003739
3558
3559     mpos = mpos + 1.
3560     ist_fieldcat_inactiv-fieldname = 'ZLSCH'.
3561     ist_fieldcat_inactiv-tabname = 'IST_SRCBSIK_INACTIV'.
3562     ist_fieldcat_inactiv-ddictxt = 'M'.
3563     ist_fieldcat_inactiv-col_pos =  mpos.
3564   *begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
3565   *  ist_fieldcat_inactiv-seltext_m  = 'PaymntMethod'.
3566     ist_fieldcat_inactiv-seltext_m  = 'PM'.
3567   *end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
3568     ist_fieldcat_inactiv-lowercase  = 'Y'.
3569     APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3570     CLEAR ist_fieldcat_inactiv.
3571
3572     mpos = mpos + 1.
3573     ist_fieldcat_inactiv-fieldname = 'ZLSPR'.
3574     ist_fieldcat_inactiv-tabname = 'IST_SRCBSIK_INACTIV'.
3575     ist_fieldcat_inactiv-ddictxt = 'M'.
3576     ist_fieldcat_inactiv-col_pos =  mpos.
3577   *begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
3578   *  ist_fieldcat_inactiv-seltext_m  = 'PaymntBlock'.
3579     ist_fieldcat_inactiv-seltext_m  = 'PB'.
3580   *end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
3581     ist_fieldcat_inactiv-lowercase  = 'Y'.
3582     APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3583     CLEAR ist_fieldcat_inactiv.
3584
3585     mpos = mpos + 1.
3586     ist_fieldcat_inactiv-fieldname = 'XREF1_HD'.
3587     ist_fieldcat_inactiv-tabname = 'IST_SRCBSIK_INACTIV'.
3588     ist_fieldcat_inactiv-ddictxt = 'M'.
3589     ist_fieldcat_inactiv-col_pos =  mpos.
3590   *begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
3591   *  ist_fieldcat_inactiv-seltext_m  = 'Location'.
3592     ist_fieldcat_inactiv-seltext_m  = 'Loc'.
3593   *end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
3594     ist_fieldcat_inactiv-lowercase  = 'Y'.
3595     APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3596     CLEAR ist_fieldcat_inactiv.
3597
3598   *begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
3599   * IF NOT s_usnam IS INITIAL.
3600   *    mpos = mpos + 1.
3601   *    ist_fieldcat_inactiv-fieldname = 'USNAM'.
3602   *    ist_fieldcat_inactiv-tabname = 'IST_SRCBSIK_INACTIV'.
3603   *    ist_fieldcat_inactiv-ddictxt = 'M'.
3604   *    ist_fieldcat_inactiv-col_pos =  mpos.
3605   *    ist_fieldcat_inactiv-seltext_m  = 'Created By'.
3606   *    ist_fieldcat_inactiv-lowercase  = 'Y'.
3607   *    APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3608   *    CLEAR ist_fieldcat_inactiv.
3609   *  ENDIF.
3610   *end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
3611
3612
3613
3614   ENDFORM.                    " INIT_FIELDCAT_INACTIV
3615   *end of <RD1K967585> CAB_ALOK 26.11.2009 CR30002778
3616   *&---------------------------------------------------------------------*
3617   *&      Form  DISPLAY_INACTIVE_ALV
3618   *&---------------------------------------------------------------------*
3619   *       text
3620   *----------------------------------------------------------------------*
3621   *  -->  p1        text
3622   *  <--  p2        text
3623   *----------------------------------------------------------------------*
3624   *Begin of <RD1K967585> CAB_ALOK 03.12.2009 CR30002778
3625   FORM display_inactive_alv .    "inactive ALV of Vendors
3626     CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
3627        EXPORTING
3628             i_callback_program       = w_repid
3629   *            i_callback_pf_status_set = 'ALV_PFST'
3630   *            i_callback_user_command  = 'MAKE_COMMAND'
3631             is_layout                = is_layout_inactiv
3632             it_fieldcat              = ist_fcat_inactiv
3633             it_sort                  = lt_sorttab
3634             it_events                = gt_events_inactiv
3635             i_save                   = 'A'
3636        TABLES
3637             t_outtab                 = ist_srcbsik_inactiv
3638   * Begin of Changes on 20-Jun-2013
3639          EXCEPTIONS
3640               program_error = 1
3641               OTHERS        = 2.
3642   * End of Changes on 20-Jun-2013
3643     IF sy-subrc <> 0.
3644   *    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
3645   *            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
3646     ENDIF.
3647   ENDFORM.                    " DISPLAY_INACTIVE_ALV
3648   *End of <RD1K967585> CAB_ALOK 03.12.2009 CR30002778
3649   *&---------------------------------------------------------------------*
3650   *&      Form  INIT_FIELDCAT_INACTIV_CUST
3651   *&---------------------------------------------------------------------*
3652   *       text
3653   *----------------------------------------------------------------------*
3654   *  -->  p1        text
3655   *  <--  p2        text
3656   *----------------------------------------------------------------------*
3657   *Begin of <RD1K967585> CAB_ALOK 03.12.2009 CR30002778
3658   FORM init_fieldcat_inactiv_cust .
3659
3660     w_repid  = sy-repid.
3661     mpos = 0.
3662
3663     mpos = mpos + 1.
3664     ist_fieldcat_inactiv-fieldname = 'SELCBOX'.
3665     ist_fieldcat_inactiv-tabname = 'IST_SRCBSID_INACTIV'.
3666     ist_fieldcat_inactiv-ddictxt = 'M'.
3667     ist_fieldcat_inactiv-col_pos =  mpos.
3668     ist_fieldcat_inactiv-seltext_m  = 'Select'.
3669     ist_fieldcat_inactiv-lowercase  = 'Y'.
3670     ist_fieldcat_inactiv-checkbox = 'X'.
3671   *  ist_fieldcat_inactiv-input = 'X'.
3672     APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3673     CLEAR ist_fieldcat_inactiv.
3674
3675     mpos = mpos + 1.
3676     ist_fieldcat_inactiv-fieldname = 'KUNNR'.
3677     ist_fieldcat_inactiv-tabname = 'IST_SRCBSID_INACTIV'.
3678     ist_fieldcat_inactiv-ddictxt = 'M'.
3679     ist_fieldcat_inactiv-col_pos =  mpos.
3680     ist_fieldcat_inactiv-seltext_m  = 'Cstmr No.'.
3681     ist_fieldcat_inactiv-lowercase  = 'Y'.
3682     APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3683     CLEAR ist_fieldcat_inactiv.
3684
3685     mpos = mpos + 1.
3686     ist_fieldcat_inactiv-fieldname = 'BELNR'.
3687     ist_fieldcat_inactiv-tabname = 'IST_SRCBSID_INACTIV'.
3688     ist_fieldcat_inactiv-ddictxt = 'M'.
3689     ist_fieldcat_inactiv-col_pos =  mpos.
3690     ist_fieldcat_inactiv-seltext_m  = 'Doc.No.'.
3691     ist_fieldcat_inactiv-lowercase  = 'Y'.
3692     APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3693     CLEAR ist_fieldcat_inactiv.
3694
3695   *  mpos = mpos + 1.
3696   *  ist_fieldcat_inactiv-fieldname = 'GSBER'.
3697   *  ist_fieldcat_inactiv-tabname = 'IST_SRCBSID_INACTIV'.
3698   *  ist_fieldcat_inactiv-ddictxt = 'M'.
3699   *  ist_fieldcat_inactiv-col_pos =  mpos.
3700   *  ist_fieldcat_inactiv-seltext_m  = 'Business Area'.
3701   *  ist_fieldcat_inactiv-lowercase  = 'Y'.
3702   *  APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3703   *  CLEAR ist_fieldcat_inactiv.
3704
3705     mpos = mpos + 1.
3706     ist_fieldcat_inactiv-fieldname = 'KIDNO'.
3707     ist_fieldcat_inactiv-tabname = 'IST_SRCBSID_INACTIV'.
3708     ist_fieldcat_inactiv-ddictxt = 'M'.
3709     ist_fieldcat_inactiv-col_pos =  mpos.
3710     ist_fieldcat_inactiv-seltext_m  = 'Pymt Ref'.
3711     ist_fieldcat_inactiv-lowercase  = 'Y'.
3712     APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3713     CLEAR ist_fieldcat_inactiv.
3714
3715     mpos = mpos + 1.
3716     ist_fieldcat_inactiv-fieldname = 'REASON'.
3717     ist_fieldcat_inactiv-tabname = 'IST_SRCBSID_INACTIV'.
3718     ist_fieldcat_inactiv-ddictxt = 'M'.
3719     ist_fieldcat_inactiv-col_pos =  mpos.
3720     ist_fieldcat_inactiv-seltext_m  = 'Reason'.
3721   *  ist_fieldcat_inactiv-lowercase  = 'Y'.
3722     APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3723     CLEAR ist_fieldcat_inactiv.
3724
3725     mpos = mpos + 1.
3726     ist_fieldcat_inactiv-fieldname = 'REBZG'.
3727     ist_fieldcat_inactiv-tabname = 'IST_SRCBSID_INACTIV'.
3728     ist_fieldcat_inactiv-ddictxt = 'M'.
3729     ist_fieldcat_inactiv-col_pos =  mpos.
3730     ist_fieldcat_inactiv-seltext_m  = 'Inv Ref'.
3731   *  ist_fieldcat_inactiv-lowercase  = 'Y'.
3732     APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3733     CLEAR ist_fieldcat_inactiv.
3734
3735   *  mpos = mpos + 1.
3736   *  ist_fieldcat_inactiv-fieldname = 'SHKZG'.
3737   *  ist_fieldcat_inactiv-tabname = 'IST_SRCBSID_INACTIV'.
3738   *  ist_fieldcat_inactiv-ddictxt = 'M'.
3739   *  ist_fieldcat_inactiv-col_pos =  mpos.
3740   *  ist_fieldcat_inactiv-seltext_m  = 'INdicator'.
3741   **  ist_fieldcat_inactiv-lowercase  = 'Y'.
3742   *  APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3743   *  CLEAR ist_fieldcat_inactiv.
3744   *
3745   *  mpos = mpos + 1.
3746   *  ist_fieldcat_inactiv-fieldname = 'GJAHR'.
3747   *  ist_fieldcat_inactiv-tabname = 'IST_SRCBSID_INACTIV'.
3748   *  ist_fieldcat_inactiv-ddictxt = 'M'.
3749   *  ist_fieldcat_inactiv-col_pos =  mpos.
3750   *  ist_fieldcat_inactiv-seltext_m  = 'Year'.
3751   *  ist_fieldcat_inactiv-lowercase  = 'Y'.
3752   *  APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3753   *  CLEAR ist_fieldcat_inactiv.
3754
3755     mpos = mpos + 1.
3756     ist_fieldcat_inactiv-fieldname = 'BUZEI'.
3757     ist_fieldcat_inactiv-tabname = 'IST_SRCBSID_INACTIV'.
3758     ist_fieldcat_inactiv-ddictxt = 'M'.
3759     ist_fieldcat_inactiv-col_pos =  mpos.
3760     ist_fieldcat_inactiv-seltext_m  = 'Item.no.'.
3761     ist_fieldcat_inactiv-lowercase  = 'Y'.
3762     APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3763     CLEAR ist_fieldcat_inactiv.
3764
3765     mpos = mpos + 1.
3766     ist_fieldcat_inactiv-fieldname = 'BSCHL'.
3767     ist_fieldcat_inactiv-tabname = 'IST_SRCBSID_INACTIV'.
3768     ist_fieldcat_inactiv-ddictxt = 'M'.
3769     ist_fieldcat_inactiv-col_pos =  mpos.
3770     ist_fieldcat_inactiv-seltext_m  = 'PK'.
3771     ist_fieldcat_inactiv-lowercase  = 'Y'.
3772     APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3773     CLEAR ist_fieldcat_inactiv.
3774
3775     mpos = mpos + 1.
3776     ist_fieldcat_inactiv-fieldname = 'BUDAT'.
3777     ist_fieldcat_inactiv-tabname = 'IST_SRCBSID_INACTIV'.
3778     ist_fieldcat_inactiv-ddictxt = 'M'.
3779     ist_fieldcat_inactiv-col_pos =  mpos.
3780     ist_fieldcat_inactiv-seltext_m  = 'Post Dt'.
3781     ist_fieldcat_inactiv-lowercase  = 'Y'.
3782     APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3783     CLEAR ist_fieldcat_inactiv.
3784
3785   *  mpos = mpos + 1.
3786   *  ist_fieldcat_inactiv-fieldname = 'DMBTR'.
3787   *  ist_fieldcat_inactiv-tabname = 'IST_SRCBSID_INACTIV'.
3788   *  ist_fieldcat_inactiv-ddictxt = 'M'.
3789   *  ist_fieldcat_inactiv-col_pos =  mpos.
3790   *  ist_fieldcat_inactiv-seltext_m  = 'AmtInLclCurncy'.
3791   *  ist_fieldcat_inactiv-lowercase  = 'Y'.
3792   *  APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3793   *  CLEAR ist_fieldcat_inactiv.
3794
3795     mpos = mpos + 1.
3796     ist_fieldcat_inactiv-fieldname = 'WRBTR'.
3797     ist_fieldcat_inactiv-tabname = 'IST_SRCBSID_INACTIV'.
3798     ist_fieldcat_inactiv-ddictxt = 'M'.
3799     ist_fieldcat_inactiv-col_pos =  mpos.
3800     ist_fieldcat_inactiv-seltext_m  = 'Amt In Doc Cur'.
3801     ist_fieldcat_inactiv-lowercase  = 'Y'.
3802     APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3803     CLEAR ist_fieldcat_inactiv.
3804
3805   *begin of < RD1K970594> CAB_ALOK 10.03.2010 CR30003739
3806     mpos = mpos + 1.
3807     ist_fieldcat_inactiv-fieldname = 'WAERS'.
3808     ist_fieldcat_inactiv-tabname = 'IST_SRCBSID_INACTIV'.
3809     ist_fieldcat_inactiv-ddictxt = 'M'.
3810     ist_fieldcat_inactiv-col_pos =  mpos.
3811     ist_fieldcat_inactiv-seltext_m  = 'Curr'.
3812     ist_fieldcat_inactiv-lowercase  = 'Y'.
3813     APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3814     CLEAR ist_fieldcat_inactiv.
3815   *end of < RD1K970594> CAB_ALOK 10.03.2010 CR30003739
3816
3817     mpos = mpos + 1.
3818     ist_fieldcat_inactiv-fieldname = 'ZLSCH'.
3819     ist_fieldcat_inactiv-tabname = 'IST_SRCBSID_INACTIV'.
3820     ist_fieldcat_inactiv-ddictxt = 'M'.
3821     ist_fieldcat_inactiv-col_pos =  mpos.
3822     ist_fieldcat_inactiv-seltext_m  = 'PM'.
3823     ist_fieldcat-lowercase  = 'Y'.
3824     APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3825     CLEAR ist_fieldcat_inactiv.
3826
3827     mpos = mpos + 1.
3828     ist_fieldcat_inactiv-fieldname = 'ZLSPR'.
3829     ist_fieldcat_inactiv-tabname = 'IST_SRCBSID_INACTIV'.
3830     ist_fieldcat_inactiv-ddictxt = 'M'.
3831     ist_fieldcat_inactiv-col_pos =  mpos.
3832     ist_fieldcat_inactiv-seltext_m  = 'PB'.
3833     ist_fieldcat_inactiv-lowercase  = 'Y'.
3834     APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3835     CLEAR ist_fieldcat_inactiv.
3836
3837     mpos = mpos + 1.
3838     ist_fieldcat_inactiv-fieldname = 'XREF1_HD'.
3839     ist_fieldcat_inactiv-tabname = 'IST_SRCBSID_INACTIV'.
3840     ist_fieldcat_inactiv-ddictxt = 'M'.
3841     ist_fieldcat_inactiv-col_pos =  mpos.
3842     ist_fieldcat_inactiv-seltext_m  = 'Loc'.
3843     ist_fieldcat_inactiv-lowercase  = 'Y'.
3844     APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3845     CLEAR ist_fieldcat_inactiv.
3846
3847   *  IF NOT s_usnam IS INITIAL.
3848   *    mpos = mpos + 1.
3849   *    ist_fieldcat_inactiv-fieldname = 'USNAM'.
3850   *    ist_fieldcat_inactiv-tabname = 'IST_SRCBSID_INACTIV'.
3851   *    ist_fieldcat_inactiv-ddictxt = 'M'.
3852   *    ist_fieldcat_inactiv-col_pos =  mpos.
3853   *    ist_fieldcat_inactiv-seltext_m  = 'Created By'.
3854   *    ist_fieldcat_inactiv-lowercase  = 'Y'.
3855   *    APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3856   *    CLEAR ist_fieldcat_inactiv.
3857   *  ENDIF.
3858
3859   ENDFORM.                    " INIT_FIELDCAT_INACTIV_CUST
3860   *end of <RD1K967585> CAB_ALOK 03.12.2009 CR30002778
3861   *&---------------------------------------------------------------------*
3862   *&      Form  PRINT_MULTI_ALV_CUST
3863   *&---------------------------------------------------------------------*
3864   *       text
3865   *----------------------------------------------------------------------*
3866   *  -->  p1        text
3867   *  <--  p2        text
3868   *----------------------------------------------------------------------*
3869   *Begin of <RD1K967585> CAB_ALOK 07.12.2009 CR30002778
3870   FORM print_multi_alv_cust .
3871
3872     CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
3873            EXPORTING
3874                 i_callback_program       = w_repid
3875                 i_callback_pf_status_set = 'ALV_PFST'
3876                 i_callback_user_command  = 'MAKEC_COMMAND'
3877                 is_layout                = is_layout
3878                 it_fieldcat              = ist_fcat[]
3879   *            it_sort                  =            " data of ist_srcbsik already arranged in reqd grouping
3880                 it_events                = gt_events
3881                 i_save                   = 'A'
3882            TABLES
3883                 t_outtab                 = ist_srcbsid
3884   * Begin of Changes on 20-Jun-2013
3885          EXCEPTIONS
3886               program_error = 1
3887               OTHERS        = 2.
3888   * End of Changes on 20-Jun-2013
3889     IF sy-subrc <> 0.
3890   *    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
3891   *            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
3892     ENDIF.
3893
3894   ENDFORM.                    " PRINT_MULTI_ALV_CUST
3895   *&---------------------------------------------------------------------*
3896   *&      Form  DISPLAY_INACTIVE_ALV_CUST
3897   *&---------------------------------------------------------------------*
3898   *       text
3899   *----------------------------------------------------------------------*
3900   *  -->  p1        text
3901   *  <--  p2        text
3902   *----------------------------------------------------------------------*
3903   FORM display_inactive_alv_cust .
3904     CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
3905            EXPORTING
3906                 i_callback_program       = w_repid
3907   *            i_callback_pf_status_set = 'ALV_PFST'
3908   *            i_callback_user_command  = 'MAKE_COMMAND'
3909                 is_layout                = is_layout_inactiv
3910                 it_fieldcat              = ist_fcat_inactiv
3911                 it_sort                  = lt_sorttab
3912                 it_events                = gt_events_inactiv
3913                 i_save                   = 'A'
3914            TABLES
3915                 t_outtab                 = ist_srcbsid_inactiv
3916   * Begin of Changes on 20-Jun-2013
3917          EXCEPTIONS
3918               program_error = 1
3919               OTHERS        = 2.
3920   * End of Changes on 20-Jun-2013
3921     IF sy-subrc <> 0.
3922   *    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
3923   *            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
3924     ENDIF.
3925   ENDFORM.                    " DISPLAY_INACTIVE_ALV_CUST
3926
3927   *&---------------------------------------------------------------------*
3928   *&      Form  UPDATE_ZFI_REM_PYBLCK_L
3929   *&---------------------------------------------------------------------*
3930   *       text
3931   *----------------------------------------------------------------------*
3932   *  -->  p1        text
3933   *  <--  p2        text
3934   *----------------------------------------------------------------------*
3935   FORM update_zfi_rem_pyblck_l .
3936   * update Logs to table ZFI_REM_PYBLCK_L
3937     DATA: ist_zfi_rem_pyblck_l TYPE TABLE OF zfi_rem_pyblck_l,
3938           wa_zfi_rem_pyblck_l TYPE zfi_rem_pyblck_l.
3939     DATA: count TYPE zfi_rem_pyblck_l-srno.
3940
3941   *begin of <RD1K967585> CAB_ALOK 10.12.2009 CR30002778
3942
3943     IF p_x2sp = 'X'.
3944       pmtblock_to = ' '.
3945     ELSEIF p_sp2x = 'X'.
3946       pmtblock_to = 'X'.
3947     ELSEIF p_sp2r = 'X'.
3948       pmtblock_to = 'R'.
3949     ELSEIF p_x2s = 'X'.
3950       pmtblock_to = 'S'.
3951   * Begin of RD1K971966 CAB_ALOK CR30004183
3952   *  ELSEIF p_s2x = 'X'.
3953   *    pmtblock_to = 'X'.
3954   * end of RD1K971966 CAB_ALOK CR30004183
3955     ENDIF.
3956
3957   *end of <RD1K967585> CAB_ALOK 10.12.2009 CR30002778
3958
3959     SELECT MAX( srno ) FROM zfi_rem_pyblck_l INTO count.
3960     IF NOT ist_srcbsik IS INITIAL.
3961
3962       LOOP AT ist_srcbsik INTO wa_srcbsik.
3963         count = count + 1.
3964
3965         wa_zfi_rem_pyblck_l-srno = count.
3966         wa_zfi_rem_pyblck_l-bukrs = wa_srcbsik-bukrs.
3967         wa_zfi_rem_pyblck_l-lifnr = wa_srcbsik-lifnr.
3968   *wa_ZFI_REM_PYBLCK_L-KUNNR = wa_srcbsik-KUNNR.
3969         wa_zfi_rem_pyblck_l-belnr = wa_srcbsik-belnr.
3970         wa_zfi_rem_pyblck_l-kidno = wa_srcbsik-kidno.
3971         wa_zfi_rem_pyblck_l-rebzg = wa_srcbsik-rebzg.
3972         wa_zfi_rem_pyblck_l-shkzg = wa_srcbsik-shkzg.
3973         wa_zfi_rem_pyblck_l-gjahr = wa_srcbsik-gjahr.
3974         wa_zfi_rem_pyblck_l-buzei = wa_srcbsik-buzei.
3975         wa_zfi_rem_pyblck_l-bschl = wa_srcbsik-bschl.
3976         wa_zfi_rem_pyblck_l-budat = wa_srcbsik-budat.
3977         wa_zfi_rem_pyblck_l-dmbtr = wa_srcbsik-dmbtr .
3978         wa_zfi_rem_pyblck_l-wrbtr = wa_srcbsik-wrbtr .
3979         wa_zfi_rem_pyblck_l-zlsch = wa_srcbsik-zlsch.
3980         wa_zfi_rem_pyblck_l-pmtblock_from = wa_srcbsik-zlspr.
3981         wa_zfi_rem_pyblck_l-pmtblock_to = pmtblock_to.
3982         wa_zfi_rem_pyblck_l-location = wa_srcbsik-xref1_hd.
3983         wa_zfi_rem_pyblck_l-uname = sy-uname.
3984         wa_zfi_rem_pyblck_l-usdate = sy-datum.
3985         wa_zfi_rem_pyblck_l-ustime = sy-uzeit.
3986
3987         INSERT zfi_rem_pyblck_l FROM wa_zfi_rem_pyblck_l.
3988       ENDLOOP.
3989       COMMIT WORK.
3990       REFRESH ist_srcbsik.
3991     ENDIF.
3992
3993     IF NOT ist_srcbsid IS INITIAL.
3994
3995       LOOP AT ist_srcbsid INTO wa_srcbsid.
3996         count = count + 1.
3997
3998         wa_zfi_rem_pyblck_l-srno = count.
3999         wa_zfi_rem_pyblck_l-bukrs = wa_srcbsid-bukrs.
4000   *   wa_ZFI_REM_PYBLCK_L-LIFNR = wa_srcbsid-LIFNR.
4001         wa_zfi_rem_pyblck_l-kunnr = wa_srcbsid-kunnr.
4002         wa_zfi_rem_pyblck_l-belnr = wa_srcbsid-belnr.
4003         wa_zfi_rem_pyblck_l-kidno = wa_srcbsid-kidno.
4004         wa_zfi_rem_pyblck_l-rebzg = wa_srcbsid-rebzg.
4005         wa_zfi_rem_pyblck_l-shkzg = wa_srcbsid-shkzg.
4006         wa_zfi_rem_pyblck_l-gjahr = wa_srcbsid-gjahr.
4007         wa_zfi_rem_pyblck_l-buzei = wa_srcbsid-buzei.
4008         wa_zfi_rem_pyblck_l-bschl = wa_srcbsid-bschl.
4009         wa_zfi_rem_pyblck_l-budat = wa_srcbsid-budat.
4010         wa_zfi_rem_pyblck_l-dmbtr = wa_srcbsid-dmbtr .
4011         wa_zfi_rem_pyblck_l-wrbtr = wa_srcbsid-wrbtr .
4012         wa_zfi_rem_pyblck_l-zlsch = wa_srcbsid-zlsch.
4013         wa_zfi_rem_pyblck_l-pmtblock_from = wa_srcbsid-zlspr.
4014         wa_zfi_rem_pyblck_l-pmtblock_to = pmtblock_to.
4015         wa_zfi_rem_pyblck_l-location = wa_srcbsid-xref1_hd.
4016         wa_zfi_rem_pyblck_l-uname = sy-uname.
4017         wa_zfi_rem_pyblck_l-usdate = sy-datum.
4018         wa_zfi_rem_pyblck_l-ustime = sy-uzeit.
4019
4020         INSERT zfi_rem_pyblck_l FROM wa_zfi_rem_pyblck_l.
4021       ENDLOOP.
4022       COMMIT WORK.
4023       REFRESH ist_srcbsid.
4024     ENDIF.
4025   ENDFORM.                    " UPDATE_ZFI_REM_PYBLCK_L
4026   *end of <RD1K967585> CAB_ALOK 09.12.2009 CR30002778
4027
4028   *Begin of <RD1K975843> CAB_ALOK CR 30005441
4029   FORM validate_liab_doc_credit_memo .
4030   ** In case credit memo exists against a PO, system should permit removal
4031   *  of block from liability document only if both liability doc and credit
4032   *   memo are selected for block removal.
4033     TABLES: setleaf.
4034     DATA: t_awkey TYPE bkpf-awkey,
4035           t_belnr TYPE rseg-belnr,
4036           t_gjahr TYPE rseg-gjahr,
4037           t_ebeln TYPE rseg-ebeln.
4038
4039     TYPES: BEGIN OF ty_ekbe1.
4040             INCLUDE STRUCTURE ekbe.
4041     TYPES:  awkey1 TYPE bkpf-awkey,
4042            END OF ty_ekbe1.
4043
4044     DATA: ist_ekbe1 TYPE STANDARD TABLE OF ty_ekbe1,
4045           wa_ekbe1 TYPE ty_ekbe1,
4046           ist_bkpf1 TYPE STANDARD TABLE OF bkpf,
4047           ist_bsik1 TYPE STANDARD TABLE OF bsik,
4048           wa_bsik1 TYPE bsik.
4049     DATA: ist_srcbsik_tmp LIKE STANDARD TABLE OF ist_srcbsik,
4050           wa_srcbsik_tmp LIKE LINE OF ist_srcbsik.
4051     DATA: del_flag(1),
4052           srcbsik_tabix TYPE sy-tabix.
4053
4054     REFRESH: ist_msg. "for storing msgs.
4055     CLEAR: wa_srcbsik, wa_msg.
4056   * currently ist_srcbsik contains only selected lines ( selcbox : 'X')
4057     SORT ist_srcbsik BY lifnr bukrs belnr.
4058
4059     LOOP AT ist_srcbsik INTO wa_srcbsik WHERE shkzg = 'H'.
4060       CLEAR:  t_awkey, t_belnr, t_gjahr, t_ebeln.
4061       srcbsik_tabix = sy-tabix.
4062   *get Reference Key(BKPF-AWKEY) from BKPF table for current line of ist_srcbsik,
4063       SELECT SINGLE awkey
4064         FROM bkpf
4065           INTO t_awkey
4066            WHERE bukrs = wa_srcbsik-bukrs
4067              AND belnr = wa_srcbsik-belnr
4068              AND gjahr = wa_srcbsik-gjahr.
4069
4070       IF t_awkey+0(1) = '5'.
4071
4072         t_belnr = t_awkey+0(10).  " Doc No.
4073         t_gjahr = t_awkey+10(4).  " Year
4074   *Get Purchase doc No
4075         SELECT SINGLE ebeln
4076           FROM rseg
4077             INTO t_ebeln
4078               WHERE belnr = t_belnr
4079                  AND gjahr = t_gjahr.  "#EC CI_NOORDER
4080         IF t_ebeln IS NOT INITIAL.
4081   *if this PO is not maintained in set "PO_Cr_memo" pass this value into Table EKBE
4082           SELECT SINGLE * FROM setleaf
4083             WHERE setclass = '0000'
4084               AND setname  = 'PO_CR_MEMO'
4085               AND valfrom  = t_ebeln.
4086           IF sy-subrc <> 0.
4087   * then check PO history in EKBE
4088   *   get  BELNR + GJAHR  = AWKEY1
4089             SELECT * FROM ekbe
4090                INTO CORRESPONDING FIELDS OF TABLE ist_ekbe1
4091                  WHERE ebeln = t_ebeln
4092                    AND ( bewtp = 'N' OR bewtp = 'P' OR bewtp = 'Q' OR bewtp = 'R' )
4093                    AND shkzg = 'H'.
4094
4095             IF ist_ekbe1 IS NOT INITIAL.
4096               LOOP AT ist_ekbe1 INTO wa_ekbe1.
4097                 CONCATENATE wa_ekbe1-belnr wa_ekbe1-gjahr INTO wa_ekbe1-awkey1.
4098                 MODIFY ist_ekbe1 FROM wa_ekbe1 .
4099               ENDLOOP.
4100
4101   *          search Document Header BKPF for above AWKEYs, get Credit memos(BELNR,BUKRS,LIFNR).
4102               SELECT * FROM bkpf
4103                 INTO CORRESPONDING FIELDS OF TABLE ist_bkpf1   " BELNR
4104                   FOR ALL ENTRIES IN ist_ekbe1
4105                     WHERE awkey = ist_ekbe1-awkey1
4106                       AND bukrs = p_bukrs
4107                       AND gjahr = ist_ekbe1-gjahr
4108                       AND stgrd = ''  "leave reversed doc
4109                       AND bstat = '' .  "#EC CI_NOORDER
4110
4111
4112   *          Check if open line items exist for above Credit Memos ( in same company code, same vendor) with payment block ='X'
4113               IF ist_bkpf1 IS NOT INITIAL.
4114                 SELECT * FROM bsik
4115                   INTO CORRESPONDING FIELDS OF TABLE ist_bsik1   " GJAHR
4116                     FOR ALL ENTRIES IN ist_bkpf1
4117                      WHERE lifnr = wa_srcbsik-lifnr
4118                        AND bukrs = ist_bkpf1-bukrs
4119                        AND belnr = ist_bkpf1-belnr
4120                        AND zlspr = 'X'.  "#EC CI_NOORDER
4121                 IF ist_bsik1 IS NOT INITIAL. "open credit memo exists
4122   *               now check whether these Credit memo have been selected on ALV screen (i.e.exist in current IST_SRCBSIK)
4123                   LOOP AT ist_bsik1 INTO wa_bsik1.
4124                     READ TABLE ist_srcbsik INTO wa_srcbsik_tmp
4125                       WITH KEY lifnr = wa_bsik1-lifnr
4126                                bukrs = wa_bsik1-bukrs
4127                                belnr = wa_bsik1-belnr
4128                             BINARY SEARCH.
4129                     IF sy-subrc = 0. " credit-memo found in selected ALV lines, store for later deletion(if related Liab. doc. is being deleted) .
4130                       wa_srcbsik_tmp-inactiv = 'X'.
4131                       APPEND wa_srcbsik_tmp TO ist_srcbsik_tmp.
4132
4133                     ELSE." credit-memo not found in selected ALV lines, store these LIV DOC - open Credit memo line items to Warning MSGs.
4134                       CLEAR wa_msg.
4135                       CONCATENATE wa_srcbsik-lifnr ' ' wa_srcbsik-bukrs wa_srcbsik-gjahr ' ' wa_srcbsik-belnr
4136                                   INTO wa_msg-liv_doc RESPECTING BLANKS.
4137                       CONCATENATE wa_bsik1-lifnr ' ' wa_bsik1-bukrs wa_bsik1-belnr
4138                                   INTO wa_msg-credit_memo RESPECTING BLANKS.
4139                       APPEND wa_msg TO ist_msg.
4140                       del_flag = 'X'. "atleast one credit-memo not found in selected ALV lines
4141                     ENDIF.
4142                   ENDLOOP. "/at IST_BSIK1
4143
4144                   IF del_flag = 'X'.
4145                     "delete current Liability Doc from ist_srcbsik(current line of loop at ist_srcbsik ).
4146                     DELETE ist_srcbsik INDEX srcbsik_tabix.
4147                     CLEAR del_flag.
4148                     "also mark related credit memos for deletion in ist_srcbsik
4149                     LOOP AT ist_srcbsik_tmp INTO wa_srcbsik_tmp.
4150                       MODIFY ist_srcbsik FROM wa_srcbsik_tmp TRANSPORTING inactiv
4151                                  WHERE lifnr = wa_srcbsik_tmp-lifnr
4152                                    AND bukrs = wa_srcbsik_tmp-bukrs
4153                                    AND belnr = wa_srcbsik_tmp-belnr.
4154                     ENDLOOP.
4155                     REFRESH  ist_srcbsik_tmp.
4156                     CLEAR wa_srcbsik_tmp.
4157                   ENDIF.  "/del_flag
4158                 ENDIF.                                        "/IST_BSIK1
4159               ENDIF.                                          "/IST_BKPF1
4160             ENDIF.                                            "/IST_EKBE1
4161           ENDIF. "/sy-subrc
4162         ENDIF. "/T_EBELN
4163       ENDIF. "/T_AWKEY
4164     ENDLOOP. "/ist_srcbsik
4165   * finally delete invalid credit memos from ist_srcbsik.
4166     DELETE ist_srcbsik WHERE inactiv = 'X'.
4167   ENDFORM.                    " VALIDATE_LIAB_DOC_CREDIT_MEMO
4168
4169   *&---------------------------------------------------------------------*
4170   *&      Form  DISPLAY_MESSAGES
4171   *&---------------------------------------------------------------------*
4172   *       text
4173   *----------------------------------------------------------------------*
4174   FORM display_messages .
4175     IF ist_msg IS NOT INITIAL.
4176       WRITE:/ 'Following LIV docs were excluded from processing as related Credit memo(s) were not selected:'.
4177       WRITE:/.
4178       WRITE:/ '--------- LIV document -------       ------ Credit memo ------'.
4179   *          0000107291 MUM 2011 7111000010     0000107291 MUM 7111000007
4180
4181       LOOP AT ist_msg INTO wa_msg.
4182         WRITE:/ wa_msg-liv_doc, '     ', wa_msg-credit_memo.
4183       ENDLOOP.
4184     ENDIF.
4185     REFRESH ist_msg.
4186     CLEAR wa_msg.
4187   ENDFORM.                    " DISPLAY_MESSAGES
4188   *end of <RD1K975843> CAB_ALOK CR 30005441
4189   *&---------------------------------------------------------------------*
4190   *&      Form  GET_BUDGET
4191   *&---------------------------------------------------------------------*
4192   *       text
4193   *----------------------------------------------------------------------*
4194   *      -->P_WA_SRCBSIK_L_BUKRS  text
4195   *      -->P_WA_SRCBSIK_L_FISTL  text
4196   *      -->P_WA_SRCBSIK_L_FIPOS  text
4197   *      -->P_WA_SRCBSIK_L_GJAHR  text
4198   *      <--P_G_BUDGET  text
4199   *----------------------------------------------------------------------*
4200   FORM get_budget  USING    p_bukrs
4201                             p_fistl
4202                             p_fipos
4203                             p_gjahr
4204                    CHANGING p_budget.
4205
4206     DATA : ist_abaplist TYPE STANDARD TABLE OF abaplist.
4207
4208     DATA: BEGIN OF ist_ascitab OCCURS 1,
4209            line(1000),
4210           END OF ist_ascitab.
4211
4212     DATA : wa_ascitab LIKE ist_ascitab.
4213
4214     DATA : l_menge TYPE eban-menge.
4215
4216     DATA : l_pr_concur(20),
4217            l_avl_budgt(30),
4218            l_dis_budgt(30),
4219            l_ass_budgt(30).
4220
4221
4222     DATA : wa_xbseg TYPE bseg.
4223
4224     DATA : l_eindt   TYPE sy-datum, "eket-eindt,
4225            l_year_po TYPE bkpf-gjahr,
4226            l_year_fi TYPE bkpf-gjahr.
4227
4228     DATA : l_fikrs  TYPE fkrs-fikrs,
4229            l_budget TYPE fmit-hsl16,
4230            l_budget_d TYPE fmit-hsl16,
4231            l_budget_as TYPE fmit-hsl16,
4232            l_budget_av TYPE fmit-hsl16.
4233
4234     DATA : l_fistl TYPE fistl,    "ekpo-fistl
4235            l_fipos TYPE fm_fipex. "ekpo-fipos.
4236
4237     DATA : l_bukrs TYPE t001-bukrs,
4238            l_budat TYPE sy-datum,
4239            ist_fmavc001 TYPE TABLE OF fmavc001,
4240            wa_fmavc001  TYPE fmavc001.
4241
4242     DATA : l_dmbtr TYPE bseg-dmbtr.
4243   * SELECT MAX( gjahr ) FROM fmioi INTO l_year_po
4244   *        WHERE refbn = bseg-ebeln AND
4245   *              rfpos = bseg-ebelp AND
4246   *              cfstat IN ('00','32').
4247   *  CALL FUNCTION 'FI_PERIOD_DETERMINE'
4248   *      EXPORTING
4249   *        i_budat     = bkpf-budat
4250   *        i_periv     = 'V3'
4251   *      IMPORTING
4252   *        e_gjahr     = l_year_fi
4253   *      EXCEPTIONS
4254   *        fiscal_year = 1.
4255   *
4256   *    IF sy-subrc <> 0.
4257   **       MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
4258   **               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
4259   *    ENDIF.
4260   *
4261   *
4262   *    IF l_year_po NE l_year_fi.
4263   *            IF NOT bseg-fistl IS INITIAL AND NOT bseg-fipos IS INITIAL.
4264   *        MOVE bkpf-bukrs TO l_bukrs.
4265   *        MOVE bseg-fistl TO l_fistl.
4266   *        MOVE bseg-fipos TO l_fipos.
4267   *        MOVE bkpf-budat TO l_budat.
4268   *
4269   *CALL FUNCTION 'FM_BUDGET_READ_BBP'
4270   *          EXPORTING
4271   *            i_bukrs       = l_bukrs
4272   *            i_date        = l_budat
4273   *            i_funds_ctr   = l_fistl
4274   *            i_commt_item  = l_fipos
4275   *          TABLES
4276   *            t_bp_obj      = ist_fmavc001
4277   *          EXCEPTIONS
4278   *            error_occured = 1
4279   *            OTHERS        = 2.
4280   *
4281   *        IF sy-subrc <> 0.
4282   **            MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
4283   **               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
4284   *        ENDIF.
4285   *
4286
4287   *        IF NOT ist_fmavc001[] IS INITIAL.
4288   *
4289   *          READ TABLE ist_fmavc001 INTO wa_fmavc001 INDEX 1.
4290   * l_dmbtr =  ( wa_fmavc001-distributable -
4291   *                       wa_fmavc001-assigned ) / 100.
4292   *
4293   *                  ENDIF.
4294     SUBMIT  zfifm_annual_budget
4295                    EXPORTING LIST TO MEMORY AND RETURN
4296                         WITH s_fikrs = p_bukrs
4297                         WITH s_fictr = p_fistl
4298                         WITH s_fipos = p_fipos
4299                         WITH s_gjahr = p_gjahr.
4300
4301     CALL FUNCTION 'LIST_FROM_MEMORY'
4302       TABLES
4303         listobject = ist_abaplist
4304       EXCEPTIONS
4305         not_found  = 1
4306         OTHERS     = 2.
4307     IF sy-subrc <> 0.
4308       MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
4309               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
4310     ENDIF.
4311
4312     CALL FUNCTION 'LIST_TO_ASCI'
4313       TABLES
4314         listobject = ist_abaplist
4315         listasci   = ist_ascitab.
4316
4317     LOOP AT ist_ascitab INTO wa_ascitab.
4318       WRITE :/ wa_ascitab-line.
4319     ENDLOOP.
4320
4321     IF NOT ist_ascitab[] IS INITIAL.
4322       READ TABLE ist_ascitab INTO wa_ascitab INDEX 10.
4323   *    READ TABLE ist_ascitab INTO wa_ascitab INDEX 6.
4324   *{Begin of CR 30007900
4325       CLEAR :ist_budget,
4326              wa_budget,
4327              l_dis_budgt,
4328              g_budget_c,
4329              l_budget.
4330       REFRESH ist_budget.
4331
4332       SPLIT wa_ascitab AT '|' INTO TABLE ist_budget.
4333   *}end of CR 30007900
4334       IF sy-subrc = 0.
4335   *{Begin of CR 30007900
4336   *      l_pr_concur = wa_ascitab+141(20).
4337   *      l_avl_budgt = wa_ascitab+162(14).
4338
4339   *      READ TABLE ist_budget INTO wa_budget INDEX 11.
4340         READ TABLE ist_budget INTO wa_budget INDEX 7.
4341         IF sy-subrc = 0.
4342           l_dis_budgt = wa_budget-row.
4343           CONDENSE l_dis_budgt.
4344         ENDIF.
4345   *}end of CR 30007900
4346   *      WRITE :/ 'PRs Concurred by Finance :', l_pr_concur.
4347   *      WRITE :/ 'Available budget         :', l_avl_budgt.
4348
4349
4350         CLEAR : l_ass_budgt.
4351         READ TABLE ist_budget INTO wa_budget INDEX 8.
4352         IF sy-subrc = 0.
4353           l_ass_budgt = wa_budget-row.
4354           CONDENSE l_ass_budgt.
4355         ENDIF.
4356
4357         CLEAR : g_budget_d.
4358         g_budget_d = l_dis_budgt.
4359         CONDENSE g_budget_d.
4360         PERFORM convert_c_to_num USING g_budget_d CHANGING l_budget_d.
4361
4362   *    l_avl_budgt = l_dis_budgt - l_ass_budgt.
4363
4364         CLEAR : g_budget_as.
4365         g_budget_as = l_ass_budgt.
4366         CONDENSE g_budget_as.
4367         PERFORM convert_c_to_num USING g_budget_as CHANGING l_budget_as.
4368
4369       ENDIF.
4370     ENDIF.
4371     l_budget_av = l_budget_d - l_budget_as.
4372
4373     l_budget = l_budget_av.
4374     p_budget = l_budget.
4375   ENDFORM.                    " GET_BUDGET
4376   *&---------------------------------------------------------------------*
4377   *&      Form  CONVERT_C_TO_NUM
4378   *&---------------------------------------------------------------------*
4379   *       text
4380   *----------------------------------------------------------------------*
4381   *      -->P_G_BUDGET_C  text
4382   *      <--P_L_BUDGET_D  text
4383   *----------------------------------------------------------------------*
4384   FORM convert_c_to_num  USING    p_g_budget_c
4385                          CHANGING p_l_budget_d.
4386
4387     CALL FUNCTION 'MOVE_CHAR_TO_NUM'
4388       EXPORTING
4389         chr                   = p_g_budget_c
4390      IMPORTING
4391        num                   = p_l_budget_d
4392   * Begin of Changes on 20-Jun-2013
4393                EXCEPTIONS
4394                  convt_no_number       = 1
4395                  convt_overflow        = 2
4396                  OTHERS                = 3
4397   * End of Changes on 20-Jun-2013
4398               .
4399     IF sy-subrc <> 0.
4400   * MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
4401   *         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
4402     ENDIF.
4403   ENDFORM.                    " CONVERT_C_TO_NUM
4404
4405   *-- S/4 helper: change BSEG payment block via FI_DOCUMENT_CHANGE - SAP_ABAP 16.06.2026 --
4406   FORM zz_s4_bseg_zlspr USING p_bukrs p_belnr p_gjahr p_buzei p_zlspr.
4407     DATA: lt_acchg TYPE STANDARD TABLE OF accchg, ls_acchg TYPE accchg.
4408     REFRESH lt_acchg. CLEAR ls_acchg.
4409     ls_acchg-fdname = 'ZLSPR'. ls_acchg-newval = p_zlspr.
4410     APPEND ls_acchg TO lt_acchg.
4411     CALL FUNCTION 'FI_DOCUMENT_CHANGE' EXPORTING i_bukrs = p_bukrs i_belnr = p_belnr i_gjahr = p_gjahr
4412          i_buzei = p_buzei TABLES t_acchg = lt_acchg EXCEPTIONS OTHERS = 0.
4413   ENDFORM.
*--- End of ZFI_BCM_REJREC - 4413 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CSLIS                                   Level 1    Page 2
Object           ZFI_BCM_REJREC                            Lines 543
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:54
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
Object           ZFI_BCM_REJREC                            Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:54
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
Object           ZFI_BCM_REJREC                            Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:54
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
Object           ZFI_BCM_REJREC                            Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:54
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
Object           ZFI_BCM_REJREC                            Lines 1
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:54
----------------------------------------------------------------------------------------------------
1      * INCLUDE DB__SSEL
*--- End of DB__SSEL - 1 lines ---
