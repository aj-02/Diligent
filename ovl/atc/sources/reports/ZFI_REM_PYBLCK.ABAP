----------------------------------------------------------------------------------------------------
Main program     ZFI_REM_PYBLCK                            Level 0    Page 1
Object           ZFI_REM_PYBLCK                            Lines 4559
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:24
----------------------------------------------------------------------------------------------------
1      REPORT zfi_rem_pyblck .
2      *-----  PROGRAM FOR Removing payment blocks 'X'  ****
3      ***********************************************************************
4      * Program    :                                                        *
5      *                                                                     *
6      *                                                                     *
7      * Author     : S.R.Sudha                     Date : 14.03.2008
8      *
9      *                                                                     *
10     * Login Id   : CAB_SUDHA                                              *
11     *                                                                      *
12     * Description: For removing payment blocks in documents for vendor as *
13     *               per i/p
14     *  FS-no     : FS-FI-GL-41
15     *                                                                     *
16     * Tran.Code  : ZFIBLOCKX
17     *
18     *                                                                     *
19     ***********************************************************************
20     *Change History
21     *By            ID   Login       FS  given By           Description
22     *       Date
23     *S.R.Sudha   +001   CAB_SUDHA   N.Mallikarjun          Paymnt Ref Added
24     *       4.4.2008
25     *S.R.Sudha   +002   CAB_SUDHA   N.Mallikarjun          JV Cash call Sp
26     *      22.04.2008                                 glPayment method added
27     *
28     *            +003   CAB_SUDHA   N.Mallikarjun           Req. of new
29     *  payment blocks   R- rejection, S- stale cheque , D - old lineitems
30     *                   auth object added
31     ***********************************************************************
32     ************************************************************************
33     *  Date         Transport   USERID          Description
34     * 19/12/2008  <RD1K960891> CAB_SUDHA  Payment block for customers
35     * 25.02.09  cab_rama        FS-FI-AP-083_01 30000782    001
36     * 28.10.2009 RD1K967585  CAB_ALOK     CR30002778, various validations for line items
37     *                                         in 'Payment Block from X to Blank' option,
38     *                                         Separate ALV for exception items,
39     *                                         Addition of INV REF & Subtotal in Reports,
40     *                                        Creation of activity logs in separate Z table.
41     * 09.03.2010 RD1K970594 CAB_ALOK      CR30003739: Correction in Invoice ref. logic,
42     *                                            Addition of 'Curr key' in reports
43     * 26.03.2010               SAB_SUMAN      30003849.
44     * 07.10.2010 RD1K973788 CAB_ALOK      CR 30004826 - Condition on kunnr
45     * 20.04.2010 RD1K975843 CAB_ALOK      CR 30005441 - Validations in view of CVP:
46     *                                     Validations based on:
47     *                                     payment method,
48     *                                     Add column for field Base Line and validate,
49     *                                     payment method in all linked documents,
50     *                                     business area - send complete document to exceptions,
51     *                                     joint validation of liability doc and credit memo.
52     *                                     Addition of Doc. no. in selection,
53     *                                     conditon 'Inconsistent PM in Docs' to be checked before
54     *                                     conditon 'Diff Pymt Method in vendor master'.
55     *                                     base line date to be placed before posting date field
56     *                                     CHANGE in due date check condition: all linked documents to go
57     *                                     to 'Exception'  if 1. RD > CD > LD & 2. RD > LD > CD, where CD - Current date
58     *                                     RD - Due date in Recovery document, LD - Due date in Liability document,
59     *                                     'X/BLANK  to S' was not updating table BSEG
60     * 05.08.2011 RD1K975843 CAB_ALOK      add field for Due date in exception tab after posting date field
61     *
62     *18.12.2015 <RD1K999458> CAB_RAMA(ANAMIKA) Warning message to avoid excess payment CR 30013754*
63     *                                                                                  *
64     *05.05.2016 <RD1K9A00LE> CAB_RAMA(ANAMIKA) Changes as per CR 30014262              *
65     *                                                                                  *
66     ************************************************************************
67     *----------------------------------------------------------------------*
68     TYPE-POOLS : slis.
69     *Begin of <RD1K967585> CAB_ALOK 08.12.2009 CR30002778
70     *TABLES : bsik, t001, bkpf, bsid .
71     TABLES : bsik, t001, bkpf, bsid, zfi_rem_pyblck_l, vcnum . " ZFI_REM_PYBLCK_L for storing logs
72     *end of <RD1K967585> CAB_ALOK 08.12.2009 CR30002778
73     TYPES : BEGIN OF ST_budget,
74               row(30) type c,
75             END OF ST_budget.
76     data :ist_budget type standard table of st_budget,
77           wa_budget  type st_budget.
78     DATA : ist_bsik  TYPE TABLE OF bsik.
79     DATA : ist_bseg TYPE TABLE OF  bseg.
80     DATA : wa_bsik  TYPE bsik.
81     DATA : wa_bseg TYPE  bseg.
82
83     DATA : y_doc_nos LIKE zfi_docnos OCCURS 0 WITH HEADER LINE .
84     DATA : f_doc_nos LIKE zfi_docnos OCCURS 0 WITH HEADER LINE .
85
86     DATA: BEGIN OF ist_bkpf OCCURS 0,
87             blart LIKE bkpf-blart,
88             belnr LIKE bkpf-belnr,
89             bldat LIKE bkpf-bldat,
90             budat LIKE bkpf-budat,
91             waers LIKE bkpf-waers,
92             usnam LIKE bkpf-usnam,
93             ppnam LIKE bkpf-ppnam,
94             gjahr LIKE bkpf-gjahr, "Added PN
95             bukrs LIKE bkpf-bukrs, "Added PN
96           END OF ist_bkpf.
97
98     DATA : BEGIN OF ist_srcbsik OCCURS 0 ,
99              selcbox(1) TYPE c,
100             lifnr      LIKE bsik-lifnr , "Vendor no.
101             umskz      LIKE bsik-umskz,
102             bukrs      LIKE bsik-bukrs ,  " company code
103             gjahr      LIKE bsik-gjahr,
104             belnr      LIKE bsik-belnr,  "Doc No.
105             buzei      LIKE bsik-buzei,
106             budat      LIKE bsik-budat,
107             bschl      LIKE bsik-bschl,  " Posting Key
108             zlsch      LIKE bsik-zlsch,    "Payment Method                      "+002
109             zlspr      LIKE  bsik-zlspr,  " Payment Block Key
110             shkzg      LIKE bsik-shkzg,   "Debit/Credit Indicator
111             gsber      LIKE  bsik-gsber,
112             dmbtr      LIKE bsik-dmbtr,
113    * Begin of <RD1K967585> CAB_ALOK 29.10.2009 CR30002778
114             subtot     TYPE p  DECIMALS 2,
115    * end of <RD1K967585> CAB_ALOK 29.10.2009 CR30002778
116             wrbtr      LIKE bsik-wrbtr,
117    * begin of < RD1K970594> CAB_ALOK 10.03.2010 CR30003739
118             waers      LIKE bsik-waers, " Currency Key
119    * end of < RD1K970594> CAB_ALOK 10.03.2010 CR30003739
120             kidno      LIKE  bsik-kidno,     " Payment Ref.                        "+001
121             usnam      LIKE bkpf-usnam,
122             xref1_hd   LIKE bkpf-xref1_hd,
123             rebzg      LIKE bsik-rebzg,        " Invoice Ref.
124             reason     TYPE string,
125    * begin RD1K975843 CAB_ALOK CR 30005441
126             ZFBDT      type BSEG-ZFBDT, " due date/baseline date
127    * end RD1K975843 CAB_ALOK CR 30005441
128    *Begin of <RD1K967585> CAB_ALOK 02.11.2009 CR30002778
129    *       activ(1),   " ambiguous
130             inactiv(1),          " if X, then that line will be deactive
131             netamt     LIKE bsik-dmbtr,
132             serial_no  TYPE i,
133             subgrp     TYPE i ,     "
134
135    *end of <RD1K967585> CAB_ALOK 02.11.2009 CR30002778
136             rebzz      type bsik-rebzz,
137    *{30007662
138             blart      type bsik-blart,
139             fipos      type bsik-fipos,
140             fistl      type bsik-fistl,
141    *}30007662
142    *{
143             ebeln      type bsik-ebeln,
144             ebelp      type bsik-ebelp.
145    *}
146    *       include structure  bsis.
147    DATA:  END OF ist_srcbsik .
148    DATA : wa_srcbsik LIKE ist_srcbsik.
149    DATA : wa_srcbsik_l LIKE ist_srcbsik.
150
151
152
153    """""""Added by Anamika on 21/12/2015 for RD1K999458""""
154    DATA : ist_srcbsik_copy LIKE ist_srcbsik OCCURS 0 WITH HEADER LINE.
155    DATA : wa_srcbsik_copy LIKE ist_srcbsik.
156    """""""Added by Anamika on 21/12/2015 for RD1K999458""""
157
158    """""""Added by Anamika on 10/05/2016 for  RD1K9A00LE""""
159    DATA : ist_ZFI_PAYREF_CC  TYPE TABLE OF ZFI_PAYREF_CC.
160    """""""End of added by Anamika on 10/05/2016 for  RD1K9A00LE""""
161
162
163    *Begin of <RD1K967585> CAB_ALOK 25.11.2009 CR30002778
164    DATA : ist_srcbsik_orig LIKE STANDARD TABLE OF ist_srcbsik .
165    DATA : wa_srcbsik_orig LIKE LINE OF ist_srcbsik_orig .
166    DATA : ist_srcbsik_inactiv LIKE STANDARD TABLE OF ist_srcbsik .
167    DATA : wa_srcbsik_inactiv LIKE LINE OF ist_srcbsik_inactiv.
168    *end of <RD1K967585> CAB_ALOK 25.11.2009 CR30002778
169    DATA : ist_bsiks LIKE ist_srcbsik OCCURS 0 WITH HEADER LINE.
170    DATA : ist_debit LIKE ist_srcbsik OCCURS 0.
171    DATA : wa_debit  LIKE ist_srcbsik.
172    *-----------Start of <RD1K960891>
173    DATA : BEGIN OF ist_srcbsid OCCURS 0 ,
174             selcbox(1) TYPE c,
175             kunnr      LIKE bsid-kunnr ,   "customer no.
176             umskz      LIKE bsid-umskz,
177             bukrs      LIKE bsid-bukrs,
178             gjahr      LIKE bsid-gjahr,
179             belnr      LIKE bsid-belnr,    "Doc No.
180             buzei      LIKE bsid-buzei,
181             budat      LIKE bsid-budat,
182             bschl      LIKE bsid-bschl,   " Posting Key
183             zlsch      LIKE bsid-zlsch,   "Payment Method                            "+002
184             zlspr      LIKE  bsid-zlspr,  " Payment Block Key
185             shkzg      LIKE bsid-shkzg,   "Debit/Credit Indicator
186             gsber      LIKE  bsid-gsber,
187             dmbtr      LIKE bsid-dmbtr,
188    *Begin of <RD1K967585> CAB_ALOK 29.10.2009 CR30002778
189             subtot     TYPE p  DECIMALS 2,
190    *end of <RD1K967585> CAB_ALOK 29.10.2009 CR30002778
191             wrbtr      LIKE bsid-wrbtr,
192    * begin of < RD1K970594> CAB_ALOK 10.03.2010 CR30003739
193             waers      LIKE bsid-waers, " Currency Key
194    * end of < RD1K970594> CAB_ALOK 10.03.2010 CR30003739
195             kidno      LIKE  bsid-kidno,    " Payment Ref.                          "+001
196             usnam      LIKE bkpf-usnam,
197             xref1_hd   LIKE bkpf-xref1_hd,
198             rebzg      LIKE bsid-rebzg,  " Invoice Ref.
199             reason     TYPE string,
200    *Begin of <RD1K967585> CAB_ALOK 02.11.2009 CR30002778
201    *       activ(1),   " ambiguous
202             inactiv(1), " if X, then that line will be deactive
203             netamt     LIKE bsid-dmbtr,
204             serial_no  TYPE i,
205             subgrp     TYPE i .     "
206    *end of <RD1K967585> CAB_ALOK 02.11.2009 CR30002778
207    *       include structure  bsis.
208    DATA:  END OF ist_srcbsid .
209
210    DATA : wa_srcbsid LIKE ist_srcbsid.
211    *Begin of <RD1K967585> CAB_ALOK 25.11.2009 CR30002778
212    DATA : ist_srcbsid_orig LIKE STANDARD TABLE OF ist_srcbsid .
213    DATA : wa_srcbsid_orig LIKE LINE OF ist_srcbsid_orig .
214    DATA : ist_srcbsid_inactiv LIKE STANDARD TABLE OF ist_srcbsid .
215    DATA : wa_srcbsid_inactiv LIKE LINE OF ist_srcbsid_inactiv.
216    *end of <RD1K967585> CAB_ALOK 25.11.2009 CR30002778
217    DATA : ist_bsids LIKE ist_srcbsid OCCURS 0 WITH HEADER LINE.
218    DATA : ist_bsid  TYPE TABLE OF bsid.
219    DATA : wa_bsid  TYPE bsid.
220    *-----------End of <RD1K960891>
221
222    DATA : w_repid TYPE sy-repid.
223
224    DATA:  is_layout         TYPE  slis_layout_alv,
225    *begin of <RD1K967585> CAB_ALOK 03.12.2009 CR30002778
226           is_layout_inactiv TYPE  slis_layout_alv,
227    *end of <RD1K967585> CAB_ALOK 03.12.2009 CR30002778
228           ist_fieldcat      TYPE  slis_fieldcat_alv  , "line.
229           ist_fcat          TYPE  TABLE OF slis_fieldcat_alv,
230           lt_sorttab        TYPE slis_t_sortinfo_alv,
231           ls_sorttab        TYPE slis_sortinfo_alv. " sort structure for ALV
232    *begin of <RD1K967585> CAB_ALOK 26.11.2009 CR30002778
233    *  ALV of inactive items: Inactive items to be shown in separate list.
234    DATA: ist_fieldcat_inactiv TYPE  slis_fieldcat_alv  , "work area.
235          ist_fcat_inactiv     TYPE  TABLE OF slis_fieldcat_alv. "IST
236    *end of <RD1K967585> CAB_ALOK 26.11.2009 CR30002778
237    DATA  : mpos TYPE i .
238    DATA : gt_list_top_of_page TYPE slis_t_listheader,
239           gt_list_end_of_list TYPE slis_t_listheader,
240           gt_events           TYPE slis_t_event.
241    *begin of <RD1K967585> CAB_ALOK 27.11.2009 CR30002778
242    DATA : gt_events_inactiv   TYPE slis_t_event.
243    DATA : pmtblock_to TYPE bsik-zlspr.
244    *end of <RD1K967585> CAB_ALOK 14.12.2009 CR30002778
245
246    * begin RD1K975843 CAB_ALOK CR 30005441
247    data: t_days_diff type i.
248    types: begin of TY_MSG,
249             LIV_DOC(30),
250             CREDIT_MEMO(30),
251    *          LIV_LIFNR type LIFNR,
252    *          LIV_BUKRS type BUKRS,
253    *          LIV_GJAHR type GJAHR,
254    *          LIV_BELNR type BSIK-BELNR,
255    *          CR_MEMO_BUKRS type BUKRS,
256    *          CR_MEMO_LIFNR type LIFNR,
257    *          CR_MEMO_BELNR type BSIK-BELNR,
258           end of TY_MSG.
259    data: IST_MSG type STANDARD TABLE OF TY_MSG,
260          WA_MSG  type TY_MSG.
261    * end RD1K975843 CAB_ALOK CR 30005441
262    DATA : ist_srcbsik_l LIKE ist_srcbsik OCCURS 0 WITH HEADER LINE.
263    *{begin of 30007662
264    data :g_budget        type fmit-hsl16, "bseg-dmbtr,
265          g_budget_c(16)," type bseg-dmbtr,
266    *            l_budget type bseg-dmbtr,
267          g_dmbtr         type bseg-dmbtr,
268          g_budget_d(25),"g_budget_d(16)
269          g_budget_as(25),"g_budget_as(16)
270          g_budget_av(25)."g_budget_av(16).
271    *}end of 30007662
272    SELECTION-SCREEN : BEGIN OF BLOCK  blk1  WITH FRAME TITLE  text-001.
273
274    SELECT-OPTIONS : s_lifnr FOR bsik-lifnr ,  "<RD1K960891>
275                     s_kunnr FOR bsid-kunnr ,  "<RD1K960891>
276                     s_year  FOR bsik-gjahr,
277    *begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778    "business area removed
278    *                 s_gsber FOR bsik-gsber,
279    *end of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
280                     s_budat FOR bsik-budat,
281                     s_usnam FOR bkpf-usnam,
282    *  *Start of addition Prabu K on 06.07.2009
283                     s_xref1 FOR bkpf-xref1_hd ,
284    *  End of addition Prabu K on 06.07.2009
285    * begin RD1K975843 CAB_ALOK      CR 30005441
286                     S_BELNR FOR BSIK-BELNR.
287    * end RD1K975843 CAB_ALOK      CR 30005441
288    PARAMETERS : p_bukrs LIKE bsik-bukrs OBLIGATORY .
289
290    SKIP  2.
291
292    SELECTION-SCREEN : END OF BLOCK blk1.
293
294    SELECTION-SCREEN : BEGIN OF BLOCK  blk2 WITH FRAME.
295
296    SELECTION-SCREEN BEGIN OF  LINE .
297    SELECTION-SCREEN COMMENT 2(76) text-003 FOR FIELD p_x2sp.
298    PARAMETERS : p_x2sp RADIOBUTTON GROUP rad1 .
299    SELECTION-SCREEN END OF LINE.
300    SKIP.
301    SELECTION-SCREEN BEGIN OF  LINE .
302    SELECTION-SCREEN COMMENT 2(76) text-004 FOR FIELD p_sp2x.
303    PARAMETERS : p_sp2x RADIOBUTTON GROUP rad1 .
304    SELECTION-SCREEN END OF LINE.
305    SELECTION-SCREEN SKIP 1.
306    SELECTION-SCREEN ULINE.
307    SELECTION-SCREEN BEGIN OF  LINE .
308    SELECTION-SCREEN COMMENT 2(76) text-005 FOR FIELD p_sp2r.
309    PARAMETERS:  p_sp2r RADIOBUTTON GROUP rad1.
310    SELECTION-SCREEN END OF LINE.
311    SELECTION-SCREEN ULINE.
312    SELECTION-SCREEN SKIP 1.
313    SELECTION-SCREEN BEGIN OF  LINE .
314    SELECTION-SCREEN COMMENT 2(76) text-006 FOR FIELD p_x2s.
315    PARAMETERS:   p_x2s  RADIOBUTTON GROUP rad1.
316    SELECTION-SCREEN END OF LINE.
317    * Begin of RD1K971966 CAB_ALOK CR30004183
318    *SELECTION-SCREEN BEGIN OF  LINE .
319    *SELECTION-SCREEN COMMENT 2(76) text-007 FOR FIELD p_s2x.
320    *PARAMETERS:   p_s2x  RADIOBUTTON GROUP rad1.
321    *SELECTION-SCREEN END OF LINE.
322    * end of RD1K971966 CAB_ALOK CR30004183
323    *selection-screen begin of  line .
324    *SELECTION-SCREEN COMMENT 2(76) text-008 FOR FIELD p_sp2s.
325    *parameters:  p_sp2s RADIOBUTTON GROUP rad1.
326    *selection-screen end of line.
327    SELECTION-SCREEN : END OF BLOCK blk2.
328
329
330
331
332    CONSTANTS  : g_zlspr_x  LIKE bseg-zlspr  VALUE 'X',
333                 g_zlspr_sp LIKE bseg-zlspr VALUE ' ',
334                 g_zlspr_s  LIKE bseg-zlspr  VALUE 'S',
335                 g_zlspr_r  LIKE bseg-zlspr  VALUE 'R'.
336
337    * *Start of addition Prabu K on 11.07.2009
338    AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_xref1-low.
339
340
341      TYPES : BEGIN OF ty_t526,
342                sachx TYPE sachx,
343                werks TYPE sbmod,
344              END OF ty_t526.
345
346      TYPES: BEGIN OF ty_final,
347               bukrs TYPE bukrs,
348               persa TYPE persa,
349               sachx TYPE sachx,
350             END OF ty_final.
351      TYPES: BEGIN OF ty_t5009,
352               persa TYPE persa,
353               bukrs TYPE bukrs,
354             END OF ty_t5009.
355      DATA: lv_area TYPE STANDARD TABLE OF ty_t526,
356            wa_area LIKE LINE OF lv_area.
357
358      DATA: it_t5009 TYPE STANDARD TABLE OF ty_t5009,
359            wa_t5009 LIKE LINE OF  it_t5009.
360
361      DATA: it_final TYPE STANDARD TABLE OF ty_final,
362            wa_final LIKE LINE OF  it_final.
363
364      SELECT sachx werks FROM t526 INTO CORRESPONDING FIELDS OF TABLE lv_area.  "#EC CI_NOORDER
365
366      SORT lv_area BY sachx.
367      DELETE ADJACENT DUPLICATES FROM lv_area
368      COMPARING sachx.
369
370    *  select persa bukrs  from t500p into table it_t5009 for all entries
371    *                         in lv_area where persa = lv_area-sachx.
372
373      SELECT persa bukrs  FROM t500p INTO CORRESPONDING FIELDS OF TABLE it_t5009.
374
375      SORT it_t5009  BY persa.
376      DELETE ADJACENT DUPLICATES FROM it_t5009
377      COMPARING persa.
378
379      LOOP AT lv_area INTO wa_area.
380
381        READ TABLE it_t5009 INTO wa_t5009 WITH KEY persa = wa_area-werks.
382        wa_final-sachx = wa_area-sachx.
383        wa_final-persa = wa_t5009-persa.
384        wa_final-bukrs = wa_t5009-bukrs.
385        APPEND wa_final TO it_final.
386      ENDLOOP.
387      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
388        EXPORTING
389          retfield        = 'SACHX'
390          dynpprog        = 'ZFI_REM_PYBLCK'
391          dynpnr          = sy-dynnr
392          dynprofield     = 'S_XREF1-LOW'
393          value_org       = 'S'
394        TABLES
395          value_tab       = it_final
396        EXCEPTIONS
397          parameter_error = 1
398          no_values_found = 2
399          OTHERS          = 3.
400
401      IF sy-subrc <> 0.
402    *
403    *    message id sy-msgid type sy-msgty number sy-msgno
404    *            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
405
406      ENDIF.
407
408    AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_xref1-high.
409      TYPES : BEGIN OF ty_t526,
410                sachx TYPE sachx,
411                werks TYPE sbmod,
412              END OF ty_t526.
413
414      TYPES: BEGIN OF ty_final,
415               bukrs TYPE bukrs,
416               persa TYPE persa,
417               sachx TYPE sachx,
418             END OF ty_final.
419      TYPES: BEGIN OF ty_t5009,
420               persa TYPE persa,
421               bukrs TYPE bukrs,
422             END OF ty_t5009.
423      DATA: lv_area TYPE STANDARD TABLE OF ty_t526,
424            wa_area LIKE LINE OF lv_area.
425
426      DATA: it_t5009 TYPE STANDARD TABLE OF ty_t5009,
427            wa_t5009 LIKE LINE OF  it_t5009.
428
429      DATA: it_final TYPE STANDARD TABLE OF ty_final,
430            wa_final LIKE LINE OF  it_final.
431
432      SELECT sachx werks FROM t526 INTO CORRESPONDING FIELDS OF TABLE lv_area.  "#EC CI_NOORDER
433
434      SORT lv_area BY sachx.
435      DELETE ADJACENT DUPLICATES FROM lv_area
436      COMPARING sachx.
437
438    *  select persa bukrs  from t500p into table it_t5009 for all entries
439    *                         in lv_area where persa = lv_area-sachx.
440
441      SELECT persa bukrs  FROM t500p INTO CORRESPONDING FIELDS OF TABLE it_t5009.
442
443      SORT it_t5009  BY persa.
444      DELETE ADJACENT DUPLICATES FROM it_t5009
445      COMPARING persa.
446
447      LOOP AT lv_area INTO wa_area.
448
449        READ TABLE it_t5009 INTO wa_t5009 WITH KEY persa = wa_area-werks.
450        wa_final-sachx = wa_area-sachx.
451        wa_final-persa = wa_t5009-persa.
452        wa_final-bukrs = wa_t5009-bukrs.
453        APPEND wa_final TO it_final.
454      ENDLOOP.
455      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
456        EXPORTING
457          retfield        = 'SACHX'
458          dynpprog        = 'ZFI_REM_PYBLCK'
459          dynpnr          = sy-dynnr
460          dynprofield     = 'S_XREF1-HIGH'
461          value_org       = 'S'
462        TABLES
463          value_tab       = it_final
464        EXCEPTIONS
465          parameter_error = 1
466          no_values_found = 2
467          OTHERS          = 3.
468
469      IF sy-subrc <> 0.
470    *
471    *    message id sy-msgid type sy-msgty number sy-msgno
472    *            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
473
474      ENDIF.
475    * End of addition Prabu K on 11.07.2009
476
477
478    AT SELECTION-SCREEN ON p_bukrs .
479      SELECT SINGLE * FROM t001  WHERE bukrs = p_bukrs.
480      IF sy-subrc <> 0.
481        MESSAGE e010(fi) WITH p_bukrs.
482      ENDIF.
483    *---------Start of <RD1K960891>
484
485      AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
486                  ID 'ACTVT' FIELD '02'
487                  ID 'BUKRS' FIELD p_bukrs.
488
489      IF sy-subrc <> 0.
490        MESSAGE  e091(8b) WITH p_bukrs.
491      ENDIF.
492    *-----------End of <RD1K960891>
493
494    *------------------------------------------------------*
495    START-OF-SELECTION.
496    *------------------------------------------------------*
497    *---+003
498
499    * remove before TP
500    * IF NOT sy-uname = 'CAB_ALOK' .
501      IF p_sp2r = 'X'.
502        PERFORM authority_check USING '02' .
503      ENDIF.
504    * ENDIF.
505    *----+003
506    *---+004
507    * remove before TP
508    *  IF NOT sy-uname = 'CAB_ALOK' .
509      IF p_x2sp = 'X' OR  p_sp2x  = 'X'.
510        PERFORM authority_check_x USING '02' .
511      ENDIF.
512    *  ENDIF.
513    *---+004
514    *-----------Start of <RD1K960891>
515
516      IF NOT s_lifnr  IS INITIAL.
517        PERFORM get_docs.
518        PERFORM validate_docs.
519        PERFORM display_docs.
520    *Begin of <RD1K975843> CAB_ALOK CR 30005441
521        PERFORM display_messages.
522    *end of <RD1K975843> CAB_ALOK CR 30005441
523      ELSEIF  NOT s_kunnr IS INITIAL.
524        PERFORM get_docs_cust.
525        PERFORM validate_docs_cust.
526        PERFORM display_docs_cust.
527      ENDIF.
528    *-----------End of <RD1K960891>
529
530    *&---------------------------------------------------------------------*
531    *&      Form  display_docs
532    *&---------------------------------------------------------------------*
533    *       text
534    *----------------------------------------------------------------------*
535    *  -->  p1        text
536    *  <--  p2        text
537    *----------------------------------------------------------------------*
538    FORM display_docs.
539      PERFORM init_fieldcat.
540    *begin of <RD1K967585> CAB_ALOK 26.11.2009 CR30002778
541    *  make fieldcat for inactive items
542      PERFORM init_fieldcat_inactiv.
543    *end of <RD1K967585> CAB_ALOK 26.11.2009 CR30002778
544      PERFORM eventtab_build TABLES gt_events.
545      PERFORM comment_build TABLES gt_list_top_of_page.
546      PERFORM  sort_build .
547    *begin of <RD1K967585> CAB_ALOK 26.11.2009 CR30002778
548    *    PERFORM  print_alv.
549    *  display multiple list ALV
550      PERFORM print_multi_alv..
551    *end of <RD1K967585> CAB_ALOK 26.11.2009 CR30002778
552
553    ENDFORM.                    " display_docs
554    *&---------------------------------------------------------------------*
555    *&      Form  init_fieldcat
556    *&---------------------------------------------------------------------*
557    *       text
558    *----------------------------------------------------------------------*
559    *  -->  p1        text
560    *  <--  p2        text
561    *----------------------------------------------------------------------*
562    FORM init_fieldcat.
563      w_repid  = sy-repid.
564
565      mpos = 0.
566      mpos = mpos + 1.
567      ist_fieldcat-fieldname = 'SELCBOX'.
568      ist_fieldcat-tabname = 'IST_SRCBSIK'.
569    *  ist_fieldcat-ddictxt = 'M'.
570      ist_fieldcat-col_pos =  mpos.
571      ist_fieldcat-seltext_m  = 'Select'.
572    *  ist_fieldcat-lowercase  = 'Y'.
573      ist_fieldcat-checkbox = 'X'.
574      ist_fieldcat-input = 'X'.
575    *  ist_fieldcat-edit = 'X'.
576      APPEND ist_fieldcat TO ist_fcat.
577      CLEAR ist_fieldcat.
578
579      mpos = mpos + 1.
580      ist_fieldcat-fieldname = 'LIFNR'.
581      ist_fieldcat-tabname = 'IST_SRCBSIK'.
582      ist_fieldcat-ddictxt = 'M'.
583      ist_fieldcat-col_pos =  mpos.
584    *begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
585    *  ist_fieldcat-seltext_m  = 'VendorNumber.'.
586      ist_fieldcat-seltext_m  = 'Vendor No.'.
587    *end of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
588      ist_fieldcat-lowercase  = 'Y'.
589      APPEND ist_fieldcat TO ist_fcat.
590      CLEAR ist_fieldcat.
591
592      mpos = mpos + 1.
593      ist_fieldcat-fieldname = 'BELNR'.
594      ist_fieldcat-tabname = 'IST_SRCBSIK'.
595      ist_fieldcat-ddictxt = 'M'.
596      ist_fieldcat-col_pos =  mpos.
597      ist_fieldcat-seltext_m  = 'Doc. No.'.
598      ist_fieldcat-lowercase  = 'Y'.
599      APPEND ist_fieldcat TO ist_fcat.
600      CLEAR ist_fieldcat.
601
602    *begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
603    *  mpos = mpos + 1.
604    *  ist_fieldcat-fieldname = 'GSBER'.
605    *  ist_fieldcat-tabname = 'IST_SRCBSIK'.
606    *  ist_fieldcat-ddictxt = 'M'.
607    *  ist_fieldcat-col_pos =  mpos.
608    *  ist_fieldcat-seltext_m  = 'Business Area'.
609    *  ist_fieldcat-lowercase  = 'Y'.
610    *  APPEND ist_fieldcat TO ist_fcat.
611    *  CLEAR ist_fieldcat.
612    *end of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
613    *---+001
614
615      mpos = mpos + 1.
616      ist_fieldcat-fieldname = 'KIDNO'.
617      ist_fieldcat-tabname = 'IST_SRCBSIK'.
618      ist_fieldcat-ddictxt = 'M'.
619      ist_fieldcat-col_pos =  mpos.
620    *begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
621    *  ist_fieldcat-seltext_m  = 'Payment Reference'.
622      ist_fieldcat-seltext_m  = 'Pymt Ref'.
623    *end of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
624      ist_fieldcat-lowercase  = 'Y'.
625      APPEND ist_fieldcat TO ist_fcat.
626      CLEAR ist_fieldcat.
627    *-------+001
628    *---+002
629      mpos = mpos + 1.
630      ist_fieldcat-fieldname = 'REBZG'.
631      ist_fieldcat-tabname = 'IST_SRCBSIK'.
632      ist_fieldcat-ddictxt = 'M'.
633      ist_fieldcat-col_pos =  mpos.
634    *begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
635    *  ist_fieldcat-seltext_m  = 'Invoice Reference'.
636      ist_fieldcat-seltext_m  = 'Inv Ref'.
637    *end of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
638    *  ist_fieldcat-lowercase  = 'Y'.
639      APPEND ist_fieldcat TO ist_fcat.
640      CLEAR ist_fieldcat.
641
642    *begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
643    *  mpos = mpos + 1.
644    *  ist_fieldcat-fieldname = 'SHKZG'.
645    *  ist_fieldcat-tabname = 'IST_SRCBSIK'.
646    *  ist_fieldcat-ddictxt = 'M'.
647    *  ist_fieldcat-col_pos =  mpos.
648    *  ist_fieldcat-seltext_m  = 'Indicator'.
649    **  ist_fieldcat-lowercase  = 'Y'.
650    *  APPEND ist_fieldcat TO ist_fcat.
651    *  CLEAR ist_fieldcat.
652    *end of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
653    *-------+002
654
655    *begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
656    *  mpos = mpos + 1.
657    *  ist_fieldcat-fieldname = 'GJAHR'.
658    *  ist_fieldcat-tabname = 'IST_SRCBSIK'.
659    *  ist_fieldcat-ddictxt = 'M'.
660    *  ist_fieldcat-col_pos =  mpos.
661    *  ist_fieldcat-seltext_m  = 'Year'.
662    *  ist_fieldcat-lowercase  = 'Y'.
663    *  APPEND ist_fieldcat TO ist_fcat.
664    *  CLEAR ist_fieldcat.
665    *end of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
666
667      mpos = mpos + 1.
668      ist_fieldcat-fieldname = 'BUZEI'.
669      ist_fieldcat-tabname = 'IST_SRCBSIK'.
670      ist_fieldcat-ddictxt = 'M'.
671      ist_fieldcat-col_pos =  mpos.
672      ist_fieldcat-seltext_m  = 'Item.no.'.
673      ist_fieldcat-lowercase  = 'Y'.
674      APPEND ist_fieldcat TO ist_fcat.
675      CLEAR ist_fieldcat.
676
677    * begin RD1K975843 CAB_ALOK CR 30005441
678      mpos = mpos + 1.
679      ist_fieldcat-fieldname = 'REASON'.
680      ist_fieldcat-tabname = 'IST_SRCBSIK'.
681      ist_fieldcat-ddictxt = 'M'.
682      ist_fieldcat-col_pos =  mpos.
683      ist_fieldcat-seltext_m  = 'Caution'.
684      ist_fieldcat-lowercase  = 'Y'.
685      ist_fieldcat-emphasize = 'C31'.
686      APPEND ist_fieldcat TO ist_fcat.
687      CLEAR ist_fieldcat.
688    * end RD1K975843 CAB_ALOK CR 30005441
689
690      mpos = mpos + 1.
691      ist_fieldcat-fieldname = 'BSCHL'.
692      ist_fieldcat-tabname = 'IST_SRCBSIK'.
693      ist_fieldcat-ddictxt = 'M'.
694      ist_fieldcat-col_pos =  mpos.
695    *begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
696    *  ist_fieldcat-seltext_m  = 'Posting Key.'.
697      ist_fieldcat-seltext_m  = 'PK'.
698    *end of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
699      ist_fieldcat-lowercase  = 'Y'.
700      APPEND ist_fieldcat TO ist_fcat.
701      CLEAR ist_fieldcat.
702
703    * begin RD1K975843 CAB_ALOK CR 30005441
704      mpos = mpos + 1.
705      ist_fieldcat-fieldname = 'ZFBDT'.
706      ist_fieldcat-tabname = 'IST_SRCBSIK'.
707      ist_fieldcat-ddictxt = 'M'.
708      ist_fieldcat-col_pos =  mpos.
709      ist_fieldcat-seltext_m  = 'Due Dt.'.
710      ist_fieldcat-lowercase  = 'Y'.
711      APPEND ist_fieldcat TO ist_fcat.
712      CLEAR ist_fieldcat.
713    * end RD1K975843 CAB_ALOK CR 30005441
714
715      mpos = mpos + 1.
716      ist_fieldcat-fieldname = 'BUDAT'.
717      ist_fieldcat-tabname = 'IST_SRCBSIK'.
718      ist_fieldcat-ddictxt = 'M'.
719      ist_fieldcat-col_pos =  mpos.
720    *begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
721    *  ist_fieldcat-seltext_m  = 'Posting Date'.
722      ist_fieldcat-seltext_m  = 'Post Dt'.
723    *end of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
724      ist_fieldcat-lowercase  = 'Y'.
725      APPEND ist_fieldcat TO ist_fcat.
726      CLEAR ist_fieldcat.
727
728    *begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
729    *  mpos = mpos + 1.
730    *  ist_fieldcat-fieldname = 'DMBTR'.
731    *  ist_fieldcat-tabname = 'IST_SRCBSIK'.
732    *  ist_fieldcat-ddictxt = 'M'.
733    *  ist_fieldcat-col_pos =  mpos.
734    *  ist_fieldcat-seltext_m  = 'AmtInLclCurncy'.
735    *  ist_fieldcat-lowercase  = 'Y'.
736    *  APPEND ist_fieldcat TO ist_fcat.
737    *  CLEAR ist_fieldcat.
738    *end of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
739
740    *Begin of <RD1K967585> CAB_ALOK 29.10.2009 CR30002778
741      mpos = mpos + 1.
742      ist_fieldcat-fieldname = 'SUBTOT'.
743      ist_fieldcat-tabname = 'IST_SRCBSIK'.
744      ist_fieldcat-ddictxt = 'M'.
745      ist_fieldcat-col_pos =  mpos.
746      ist_fieldcat-seltext_m  = 'SubTotal'.
747      ist_fieldcat-lowercase  = 'Y'.
748      APPEND ist_fieldcat TO ist_fcat.
749      CLEAR ist_fieldcat.
750
751    *End of <RD1K967585> CAB_ALOK 29.10.2009 CR30002778
752      mpos = mpos + 1.
753      ist_fieldcat-fieldname = 'WRBTR'.
754      ist_fieldcat-tabname = 'IST_SRCBSIK'.
755      ist_fieldcat-ddictxt = 'M'.
756      ist_fieldcat-col_pos =  mpos.
757    *begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
758    *  ist_fieldcat-seltext_m  = 'AmtInDocCurncy'.
759      ist_fieldcat-seltext_m  = 'Amt In Doc Cur'.
760    *end of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
761      ist_fieldcat-lowercase  = 'Y'.
762      APPEND ist_fieldcat TO ist_fcat.
763      CLEAR ist_fieldcat.
764
765    * begin of < RD1K970594> CAB_ALOK 10.03.2010 CR30003739
766      mpos = mpos + 1.
767      ist_fieldcat-fieldname = 'WAERS'.
768      ist_fieldcat-tabname = 'IST_SRCBSIK'.
769      ist_fieldcat-ddictxt = 'M'.
770      ist_fieldcat-col_pos =  mpos.
771      ist_fieldcat-seltext_m  = 'Curr'.
772      ist_fieldcat-lowercase  = 'Y'.
773      APPEND ist_fieldcat TO ist_fcat.
774      CLEAR ist_fieldcat.
775    * end of < RD1K970594> CAB_ALOK 10.03.2010 CR30003739
776
777      mpos = mpos + 1.
778      ist_fieldcat-fieldname = 'ZLSCH'.
779      ist_fieldcat-tabname = 'IST_SRCBSIK'.
780      ist_fieldcat-ddictxt = 'M'.
781      ist_fieldcat-col_pos =  mpos.
782    *begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
783    *  ist_fieldcat-seltext_m  = 'PaymntMethod'.
784      ist_fieldcat-seltext_m  = 'PM'.
785    *end of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
786      ist_fieldcat-lowercase  = 'Y'.
787      APPEND ist_fieldcat TO ist_fcat.
788      CLEAR ist_fieldcat.
789
790      mpos = mpos + 1.
791      ist_fieldcat-fieldname = 'ZLSPR'.
792      ist_fieldcat-tabname = 'IST_SRCBSIK'.
793      ist_fieldcat-ddictxt = 'M'.
794      ist_fieldcat-col_pos =  mpos.
795    *begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
796    *  ist_fieldcat-seltext_m  = 'PaymntBlock'.
797      ist_fieldcat-seltext_m  = 'PB'.
798    *end of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
799      ist_fieldcat-lowercase  = 'Y'.
800      APPEND ist_fieldcat TO ist_fcat.
801      CLEAR ist_fieldcat.
802
803    *  *Start of addition Prabu K on 06.07.2009
804      mpos = mpos + 1.
805      ist_fieldcat-fieldname = 'XREF1_HD'.
806      ist_fieldcat-tabname = 'IST_SRCBSIK'.
807      ist_fieldcat-ddictxt = 'M'.
808      ist_fieldcat-col_pos =  mpos.
809    *begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
810    *  ist_fieldcat-seltext_m  = 'Location'.
811      ist_fieldcat-seltext_m  = 'Loc'.
812    *end of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
813      ist_fieldcat-lowercase  = 'Y'.
814      APPEND ist_fieldcat TO ist_fcat.
815      CLEAR ist_fieldcat.
816
817    * End of addition Prabu K on 06.07.2009
818    *begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778  IF NOT s_usnam IS INITIAL.
819    *    mpos = mpos + 1.
820    *    ist_fieldcat-fieldname = 'USNAM'.
821    *    ist_fieldcat-tabname = 'IST_SRCBSIK'.
822    *    ist_fieldcat-ddictxt = 'M'.
823    *    ist_fieldcat-col_pos =  mpos.
824    *    ist_fieldcat-seltext_m  = 'Created By'.
825    *    ist_fieldcat-lowercase  = 'Y'.
826    *    APPEND ist_fieldcat TO ist_fcat.
827    *    CLEAR ist_fieldcat.
828    *  ENDIF.
829    *end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
830    ENDFORM.                    " init_fieldcat
831    *&---------------------------------------------------------------------*
832    *&      Form  eventtab_build
833    *&---------------------------------------------------------------------*
834    *       text
835    *----------------------------------------------------------------------*
836    *      -->P_GT_EVENTS[]  text
837    *----------------------------------------------------------------------*
838    FORM eventtab_build TABLES  p_gt_events.
839      DATA : ls_event TYPE slis_alv_event.
840      CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
841        EXPORTING
842          i_list_type = 0
843        IMPORTING
844          et_events   = gt_events.
845
846      READ TABLE gt_events WITH KEY name =  slis_ev_user_command
847                                INTO ls_event.
848      IF sy-subrc <> 0.
849        MOVE slis_ev_user_command TO ls_event-name.
850        MOVE 'MAKE_COMMAND' TO ls_event-form.
851        APPEND ls_event TO gt_events.
852      ENDIF.
853      CLEAR ls_event.
854
855
856    *begin of <RD1K967585> CAB_ALOK 03.12.2009 CR30002778
857      CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
858        EXPORTING
859          i_list_type = 0
860        IMPORTING
861          et_events   = gt_events_inactiv.
862      CLEAR ls_event.
863    *end  of <RD1K967585> CAB_ALOK 03.12.2009 CR30002778
864    ENDFORM.                    " eventtab_build
865    *&---------------------------------------------------------------------*
866    *&      Form  comment_build
867    *&---------------------------------------------------------------------*
868    *       text
869    *----------------------------------------------------------------------*
870    *      -->P_GT_LIST_TOP_OF_PAGE[]  text
871    *----------------------------------------------------------------------*
872    FORM comment_build TABLES    p_gt_list_top_of_page.
873
874    ENDFORM.                    " comment_build
875    *&---------------------------------------------------------------------*
876    *&      Form  sort_build
877    *&---------------------------------------------------------------------*
878    *       text
879    *----------------------------------------------------------------------*
880    *  -->  p1        text
881    *  <--  p2        text
882    *----------------------------------------------------------------------*
883    FORM sort_build.
884
885      w_repid = sy-repid.
886      is_layout-key_hotspot = 'X'.
887      is_layout-colwidth_optimize = 'X'.
888    *begin of <RD1K967585> CAB_ALOK 03.12.2009 CR30002778
889      is_layout_inactiv-key_hotspot = 'X'.
890      is_layout_inactiv-colwidth_optimize = 'X'.
891    *end of <RD1K967585> CAB_ALOK 03.12.2009 CR30002778
892
893    *begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
894    *  ls_sorttab-fieldname = 'KIDNO'.
895    *  ls_sorttab-up = 'X'.
896    *  APPEND ls_sorttab TO lt_sorttab.
897    *end of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
898      ls_sorttab-fieldname = 'LIFNR'.
899      ls_sorttab-up = 'X'.
900      APPEND ls_sorttab TO lt_sorttab.
901    *begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
902    *  ls_sorttab-fieldname = 'BSCHL'.
903    *  ls_sorttab-up = 'X'.
904    *  APPEND ls_sorttab TO lt_sorttab.
905    *  ls_sorttab-fieldname = 'BELNR'.
906    *  ls_sorttab-up = 'X'.
907    *  APPEND ls_sorttab TO lt_sorttab.
908    *  ls_sorttab-fieldname = 'BUDAT'.
909    *  ls_sorttab-up = 'X'.
910    *  APPEND ls_sorttab TO lt_sorttab.
911    *begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
912
913    ENDFORM.                    " sort_build
914    *&---------------------------------------------------------------------*
915    *&      Form  print_alv
916    *&---------------------------------------------------------------------*
917    *       text
918    *----------------------------------------------------------------------*
919    *  -->  p1        text
920    *  <--  p2        text
921    *----------------------------------------------------------------------*
922    *begin of <RD1K967585> CAB_ALOK 27.11.2009 CR30002778
923    *FORM print_alv.
924    *
925    *  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
926    *       EXPORTING
927    *            i_callback_program       = w_repid
928    *            i_callback_pf_status_set = 'ALV_PFST'
929    *            i_callback_user_command  = 'MAKE_COMMAND'
930    *            is_layout                = is_layout
931    *            it_fieldcat              = ist_fcat[]
932    *            it_sort                  = lt_sorttab
933    *            it_events                = gt_events
934    *            i_save                   = 'A'
935    *       TABLES
936    *            t_outtab                 = ist_srcbsik.
937    *  IF sy-subrc <> 0.
938    **    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
939    **            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
940    *  ENDIF.
941    *
942    *
943    *ENDFORM.                    " print_alv
944    *End of <RD1K967585> CAB_ALOK 27.11.2009 CR30002778
945
946    *&---------------------------------------------------------------------*
947    *&      Form  PRINT_MULTI_ALV
948    *&---------------------------------------------------------------------*
949    *       text
950    *----------------------------------------------------------------------*
951    *  -->  p1        text
952    *  <--  p2        text
953    *----------------------------------------------------------------------*
954    *begin of <RD1K967585> CAB_ALOK 27.11.2009 CR30002778
955    FORM print_multi_alv .
956
957      CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
958        EXPORTING
959          i_callback_program       = w_repid
960          i_callback_pf_status_set = 'ALV_PFST'
961          i_callback_user_command  = 'MAKE_COMMAND'
962          is_layout                = is_layout
963          it_fieldcat              = ist_fcat[]
964    *     it_sort                  =            " data of ist_srcbsik already arranged in reqd grouping
965          it_events                = gt_events
966          i_save                   = 'A'
967        TABLES
968          t_outtab                 = ist_srcbsik
969    * Begin of Changes on 20-Jun-2013
970        EXCEPTIONS
971          PROGRAM_ERROR            = 1
972          OTHERS                   = 2.
973    * End of Changes on 20-Jun-2013
974      IF sy-subrc <> 0.
975    *    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
976    *            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
977      ENDIF.
978
979
980    ENDFORM.                    " PRINT_MULTI_ALV
981    *End of <RD1K967585> CAB_ALOK 27.11.2009 CR30002778
982
983    *---------------------------------------------------------------------*
984    *       FORM alv_pfst                                                 *
985    *---------------------------------------------------------------------*
986    *       ........                                                      *
987    *---------------------------------------------------------------------*
988    *  -->  RT_EXTAB                                                      *
989    *---------------------------------------------------------------------*
990    FORM alv_pfst USING rt_extab TYPE slis_t_extab.
991      IF  p_x2sp = 'X'.
992        SET PF-STATUS 'S100'.
993      ELSE.
994        SET PF-STATUS 'S200'.
995      ENDIF.
996    ENDFORM.                    "alv_pfst
997
998    *---------------------------------------------------------------------*
999    *       FORM make_command                                             *
1000   *---------------------------------------------------------------------*
1001   *       ........                                                      *
1002   *---------------------------------------------------------------------*
1003   *  -->  R_UCOMM                                                       *
1004   *  -->  RS_SELFIELD                                                   *
1005   *---------------------------------------------------------------------*
1006   FORM make_command USING r_ucomm LIKE sy-ucomm
1007                           rs_selfield TYPE slis_selfield.
1008   *-----------------------------------------------------*
1009   *-----------------------------------------------------*
1010     DATA : index_aux LIKE sy-tabix.
1011     index_aux = rs_selfield-tabindex.
1012
1013     CASE r_ucomm.
1014
1015       WHEN 'REL'.
1016
1017   *Begin of <RD1K981426> CAB_RAMA CR 30007673
1018         ist_srcbsik_l[] = ist_srcbsik[].
1019         IF p_x2sp = 'X'.
1020           loop at ist_srcbsik into wa_srcbsik where selcbox = 'X' AND KIDNO <> 'PERIOD END LIABILITY'.
1021             if  ( wa_srcbsik-bschl = '31' or wa_srcbsik-bschl = '34' or wa_srcbsik-bschl = '36'
1022               or wa_srcbsik-bschl = '39' or wa_srcbsik-bschl = '21' OR wa_srcbsik-bschl = '26').
1023
1024               """""""Added by Anamika on 21/12/2015 for RD1K999458""""
1025               DATA : l_text1(250).
1026               DATA: BEGIN OF ist_errmsg OCCURS 0,
1027                       text(100),
1028                     END OF ist_errmsg.
1029
1030     """""""Added by Anamika on 10/05/2016 for  RD1K9A00LE""""
1031      select * from  ZFI_PAYREF_CC into CORRESPONDING FIELDS OF table ist_ZFI_PAYREF_CC
1032        where BUKRS = p_BUKRS and CHECK_VALID = 'X'.
1033               IF sy-subrc eq 0.
1034   """""""End of added by Anamika on 10/05/2016 for  RD1K9A00LE""""
1035
1036
1037
1038               l_text1 = 'Kindly ensure recovery of below documents with same payment reference.' .
1039               move  l_text1 to ist_errmsg-text.
1040               append ist_errmsg.
1041
1042   """""""Added by Anamika on 10/05/2016 for  RD1K9A00LE""""
1043   LOOP AT ist_srcbsik_copy INTO wa_srcbsik_copy where belnr in S_BELNR .
1044
1045               IF sy-subrc eq 0.
1046
1047         delete ist_srcbsik_copy where BELNR = wa_srcbsik_copy-BELNR.
1048                                          ENDIF.
1049   endloop.
1050   """""""End of added by Anamika on 10/05/2016 for  RD1K9A00LE""""
1051
1052               if s_BELNR IS not INITIAL.
1053                 if ist_srcbsik_copy[] IS not INITIAL.
1054
1055                   LOOP AT ist_srcbsik_copy INTO wa_srcbsik_copy.
1056                     move WA_srcbsik_copy-BELNR to ist_errmsg-text.
1057                     append ist_errmsg.
1058                   ENDLOOP.
1059
1060
1061                   CALL FUNCTION 'ZPOPUP_WITH_TABLE_DISPLAY_OK'
1062                     EXPORTING
1063                       titletext    = 'Warning/Error'
1064                       endpos_col   = 100
1065                       endpos_row   = 25
1066                       startpos_col = 20
1067                       startpos_row = 05
1068                     TABLES
1069                       valuetab     = ist_errmsg
1070                     EXCEPTIONS
1071                       break_off    = 1
1072                       OTHERS       = 2.
1073
1074                   REFRESH ist_errmsg.
1075                   IF sy-subrc <> 0.
1076                     MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
1077                       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
1078                   endif.
1079
1080                   LEAVE to screen 0.
1081                 else.
1082                 endif.
1083
1084               endif.
1085
1086   """""""Added by Anamika on 10/05/2016 for  RD1K9A00LE""""
1087   else.
1088     endif.
1089   """""""End of added by Anamika on 10/05/2016 for  RD1K9A00LE""""
1090               """""""Added by Anamika on 21/12/2015 for RD1K999458""""
1091
1092
1093               loop at ist_srcbsik_l into wa_srcbsik_l
1094                 where selcbox <> 'X' and ( bschl = '31' or bschl = '34' or bschl = '36' or bschl = '39'
1095                 or bschl = '21'  or bschl = '26' )
1096                 and kidno = wa_srcbsik-kidno
1097                 AND KIDNO <> 'PERIOD END LIABILITY'
1098                 and lifnr = wa_srcbsik-lifnr.
1099
1100                 MESSAGE e100(zfi) WITH text-010.
1101               endloop.
1102             endif.
1103           endloop.
1104         ENDIF.
1105   *END of <RD1K981426> CAB_RAMA CR 30007673
1106   **{begin of 30007662
1107   *      data :g_budget type bseg-dmbtr,
1108   *            g_budget_c(16)," type bseg-dmbtr,
1109   **            l_budget type bseg-dmbtr,
1110   *            g_dmbtr type bseg-dmbtr.
1111         IF p_x2sp = 'X'.
1112   *        sort ist_srcbsik_l by lifnr bukrs gjahr belnr bschl zlsch fipos fistl.
1113           loop at ist_srcbsik_l into wa_srcbsik_l where selcbox = 'X' and
1114             shkzg = 'H' and
1115            ( ( BLART = 'NI' and BSCHL = '39' and UMSKZ = 'F' )
1116             or ( BELNR = wa_srcbsik_l-belnr and ZLSCH = 'L' ) ) .
1117             clear :g_budget,g_budget_c,g_dmbtr.
1118   *{
1119             DATA : wa_xbseg TYPE bseg.
1120
1121             DATA : l_eindt      TYPE sy-datum, "eket-eindt,
1122                    l_year_max   TYPE bkpf-gjahr,
1123                    l_year_budat TYPE bkpf-gjahr,
1124                    l_year_curr  TYPE bkpf-gjahr.
1125
1126             DATA : l_fikrs  TYPE fkrs-fikrs,
1127                    l_budget TYPE fmit-hsl16.
1128
1129             DATA : l_fistl TYPE fistl,    "ekpo-fistl
1130                    l_fipos TYPE fm_fipex. "ekpo-fipos.
1131
1132             DATA : l_bukrs      TYPE t001-bukrs,
1133                    l_budat      TYPE sy-datum,
1134                    ist_fmavc001 TYPE TABLE OF fmavc001,
1135                    wa_fmavc001  TYPE fmavc001.
1136
1137             DATA : l_dmbtr TYPE bseg-dmbtr.
1138
1139             loop at ist_srcbsik into wa_srcbsik
1140               where BELNR = wa_srcbsik_l-belnr
1141               and fipos = wa_srcbsik_l-fipos
1142               and fistl = wa_srcbsik_l-fistl
1143               and shkzg = 'H'.
1144
1145               if wa_srcbsik-shkzg = 'H'.
1146                 g_dmbtr = wa_srcbsik-dmbtr * ( -1 ) + g_dmbtr.
1147               elseif wa_srcbsik-shkzg = 'S'.
1148                 g_dmbtr = wa_srcbsik-dmbtr + g_dmbtr.
1149               endif.
1150             endloop.
1151
1152             SELECT MAX( gjahr ) FROM fmioi INTO l_year_max
1153                   WHERE refbn = wa_srcbsik_l-ebeln AND
1154                         rfpos = wa_srcbsik_l-ebelp AND
1155                         cfstat IN ('00','32').
1156             select single bukrs budat from bkpf
1157               into (l_bukrs,l_budat)
1158               where bukrs = wa_srcbsik_l-bukrs
1159                                  and belnr = wa_srcbsik_l-belnr
1160                                  and gjahr = wa_srcbsik_l-gjahr .
1161
1162             CALL FUNCTION 'FI_PERIOD_DETERMINE'
1163               EXPORTING
1164                 i_budat     = l_budat
1165                 i_periv     = 'V3'
1166               IMPORTING
1167                 e_gjahr     = l_year_budat
1168               EXCEPTIONS
1169                 fiscal_year = 1.
1170
1171             IF sy-subrc <> 0.
1172   *       MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
1173   *               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
1174             ENDIF.
1175
1176
1177             CALL FUNCTION 'FI_PERIOD_DETERMINE'
1178               EXPORTING
1179                 i_budat     = sy-datum
1180                 i_periv     = 'V3'
1181               IMPORTING
1182                 e_gjahr     = l_year_curr
1183               EXCEPTIONS
1184                 fiscal_year = 1.
1185
1186             if ( l_year_curr eq l_year_budat ) and ( l_year_budat eq l_year_max ).
1187   *no action
1188             elseif ( l_year_curr gt l_year_budat ) and  ( l_year_budat eq l_year_max ).
1189   *check FM for l_year_curr
1190               perform get_budget using 'ONGC' wa_srcbsik_l-fistl wa_srcbsik_l-fipos l_year_curr
1191                                      changing g_budget.
1192               if g_dmbtr > g_budget.
1193                 MESSAGE e100(zfi) WITH text-011 wa_srcbsik_l-fistl wa_srcbsik_l-fipos  .
1194               endif.
1195             elseif ( l_year_curr eq l_year_budat ) and ( l_year_budat gt l_year_max ).
1196   *check FM for l_year_curr
1197               perform get_budget using 'ONGC' wa_srcbsik_l-fistl wa_srcbsik_l-fipos l_year_curr
1198                                      changing g_budget.
1199               if g_dmbtr > g_budget.
1200                 MESSAGE e100(zfi) WITH text-011 wa_srcbsik_l-fistl wa_srcbsik_l-fipos  .
1201               endif.
1202             elseif ( l_year_curr GT l_year_budat ) and ( l_year_budat NE l_year_max ).
1203   *check FM for l_year_curr
1204               perform get_budget using 'ONGC' wa_srcbsik_l-fistl wa_srcbsik_l-fipos l_year_curr
1205                                      changing g_budget.
1206               if g_dmbtr > g_budget.
1207                 MESSAGE e100(zfi) WITH text-011 wa_srcbsik_l-fistl wa_srcbsik_l-fipos  .
1208               endif.
1209             ENDIF.
1210           endloop.
1211         endif.
1212
1213   *}end of 30007662
1214         DELETE ist_srcbsik WHERE  selcbox <> 'X'.
1215
1216
1217   *Begin of <RD1K975843> CAB_ALOK CR 30005441
1218   ** Validation for credit memo
1219         IF p_x2sp = 'X'.
1220           Perform validate_liab_doc_credit_memo.
1221         endif.
1222   *End of <RD1K975843> CAB_ALOK CR 30005441
1223         PERFORM   get_upd_bsik.
1224         PERFORM   get_upd_bseg.
1225   *Begin of <RD1K967585> CAB_ALOK 09.12.2009 CR30002778
1226         PERFORM   update_zfi_rem_pyblck_l.    "update logs
1227   *Begin of <RD1K967585> CAB_ALOK 09.12.2009 CR30002778
1228         LEAVE SCREEN.
1229
1230       WHEN 'ALL'.
1231         PERFORM  select_all.
1232       WHEN 'SAL'.
1233         PERFORM  deselect_all.
1234
1235       WHEN '&F03' OR 'BACK' .
1236         LEAVE  PROGRAM.
1237   *Begin of <RD1K967585> CAB_ALOK 03.12.2009 CR30002778
1238       WHEN 'REP'.
1239         PERFORM display_inactive_alv.
1240   *End of <RD1K967585> CAB_ALOK 03.12.2009 CR30002778
1241
1242     ENDCASE.
1243
1244   ENDFORM.                    "make_command
1245   *---------------------------------------------------------------------*
1246   *&      Form  select_all
1247   *&---------------------------------------------------------------------*
1248   *       text
1249   *----------------------------------------------------------------------*
1250   *  -->  p1        text
1251   *  <--  p2        text
1252   *----------------------------------------------------------------------*
1253   FORM select_all.
1254     LOOP AT ist_srcbsik.
1255       ist_srcbsik-selcbox = 'X'.
1256       MODIFY ist_srcbsik.
1257     ENDLOOP.
1258
1259   ENDFORM.                    " select_all
1260   *&---------------------------------------------------------------------*
1261   *&      Form  deselect_all
1262   *&---------------------------------------------------------------------*
1263   *       text
1264   *----------------------------------------------------------------------*
1265   *  -->  p1        text
1266   *  <--  p2        text
1267   *----------------------------------------------------------------------*
1268   FORM deselect_all.
1269     LOOP AT ist_srcbsik.
1270       ist_srcbsik-selcbox = ' '.
1271       MODIFY ist_srcbsik.
1272     ENDLOOP.
1273   ENDFORM.                    " deselect_all
1274   *&---------------------------------------------------------------------
1275   *&---------------------------------------------------------------------*
1276   *&      Form  get_upd_bsik
1277   *&---------------------------------------------------------------------*
1278   *       text
1279   *----------------------------------------------------------------------*
1280   *  -->  p1        text
1281   *  <--  p2        text
1282   *----------------------------------------------------------------------*
1283   FORM get_upd_bsik.
1284
1285     DATA : l_tabix  TYPE sy-tabix.
1286
1287     CHECK NOT ist_srcbsik[] IS INITIAL.
1288
1289     SELECT * INTO TABLE ist_bsik   FROM bsik
1290       FOR ALL ENTRIES  IN  ist_srcbsik
1291       WHERE   lifnr = ist_srcbsik-lifnr
1292             AND  bukrs  =  p_bukrs
1293              AND gjahr = ist_srcbsik-gjahr
1294              AND belnr = ist_srcbsik-belnr
1295              AND buzei = ist_srcbsik-buzei.
1296   *------------X  to blank
1297     IF NOT ist_bsik IS INITIAL.
1298       IF p_x2sp = 'X'.
1299         LOOP AT ist_bsik INTO wa_bsik.
1300           l_tabix =   sy-tabix .
1301           IF wa_bsik-zlspr =  g_zlspr_x.
1302             wa_bsik-zlspr =  space.
1303             MODIFY ist_bsik  FROM  wa_bsik INDEX l_tabix  TRANSPORTING zlspr.
1304           ENDIF.
1305         ENDLOOP.
1306   "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
1307   *      MODIFY  bsik FROM TABLE ist_bsik.
1308
1309   *      COMMIT WORK.
1310   "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
1311       ENDIF.
1312
1313   *---------------blank to X
1314       IF p_sp2x = 'X'.
1315         LOOP AT ist_bsik INTO wa_bsik.
1316           l_tabix =   sy-tabix .
1317           IF wa_bsik-zlspr =  g_zlspr_sp.
1318             wa_bsik-zlspr =  'X'.
1319             MODIFY ist_bsik  FROM  wa_bsik INDEX l_tabix  TRANSPORTING zlspr
1320      .
1321           ENDIF.
1322         ENDLOOP.
1323   *
1324   *      MODIFY  bsik FROM TABLE ist_bsik.
1325   *
1326   *      COMMIT WORK.
1327       ENDIF.
1328   *---------+003
1329   *------------------Blank to R
1330       IF p_sp2r = 'X'.
1331         LOOP AT ist_bsik INTO wa_bsik.
1332           l_tabix =   sy-tabix .
1333           IF wa_bsik-zlspr =  g_zlspr_sp.
1334             wa_bsik-zlspr =  g_zlspr_r.
1335             MODIFY ist_bsik  FROM  wa_bsik INDEX l_tabix  TRANSPORTING zlspr.
1336           ENDIF.
1337         ENDLOOP.
1338   "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
1339   *      MODIFY  bsik FROM TABLE ist_bsik.
1340
1341   *      COMMIT WORK.
1342   "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
1343       ENDIF.
1344
1345   *------------Blank to S
1346   *  IF p_sp2s = 'X'.
1347   *      LOOP AT ist_bsik INTO wa_bsik.
1348   *        l_tabix =   sy-tabix .
1349   *        IF wa_bsik-zlspr =  g_zlspr_sp.
1350   *          wa_bsik-zlspr =  g_zlspr_s.
1351   *       MODIFY ist_bsik  FROM  wa_bsik INDEX l_tabix  TRANSPORTING zlspr.
1352   *        ENDIF.
1353   *      ENDLOOP.
1354   *
1355   *      MODIFY  bsik FROM TABLE ist_bsik.
1356   *
1357   *      COMMIT WORK.
1358   *    ENDIF.
1359
1360   *----------------X to S
1361       IF p_x2s = 'X'.
1362         LOOP AT ist_bsik INTO wa_bsik.
1363           l_tabix =   sy-tabix .
1364           IF wa_bsik-zlspr =  g_zlspr_x  OR wa_bsik-zlspr =  g_zlspr_sp.
1365             wa_bsik-zlspr =  g_zlspr_s.
1366             MODIFY ist_bsik  FROM  wa_bsik INDEX l_tabix  TRANSPORTING zlspr.
1367           ENDIF.
1368         ENDLOOP.
1369
1370   "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
1371   *      MODIFY  bsik FROM TABLE ist_bsik.
1372
1373   *      COMMIT WORK.
1374   "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
1375       ENDIF.
1376
1377   * Begin of RD1K971966 CAB_ALOK CR30004183
1378   **-----------S to X
1379   *    IF p_s2x = 'X'.
1380   *      LOOP AT ist_bsik INTO wa_bsik.
1381   *        l_tabix =   sy-tabix .
1382   *        IF wa_bsik-zlspr =  g_zlspr_s.
1383   *          wa_bsik-zlspr =  g_zlspr_x.
1384   *          MODIFY ist_bsik  FROM  wa_bsik INDEX l_tabix  TRANSPORTING zlspr.
1385   *        ENDIF.
1386   *      ENDLOOP.
1387   *
1388   *      MODIFY  bsik FROM TABLE ist_bsik.
1389   *
1390   *      COMMIT WORK.
1391   *    ENDIF.
1392   * End of RD1K971966 CAB_ALOK CR30004183
1393
1394   *-------+003
1395     ENDIF.
1396   *  LEAVE SCREEN.
1397   ENDFORM.                    " get_upd_bsik
1398   *
1399   *&---------------------------------------------------------------------*
1400   *&      Form  get_upd_bseg
1401   *&---------------------------------------------------------------------*
1402   *       text
1403   *----------------------------------------------------------------------*
1404   *  -->  p1        text
1405   *  <--  p2        text
1406   *----------------------------------------------------------------------*
1407   FORM get_upd_bseg.
1408     DATA : l_tabix  TYPE sy-tabix.
1409
1410     CHECK NOT ist_srcbsik[] IS INITIAL.
1411
1412     SELECT * INTO TABLE ist_bseg   FROM bseg
1413       FOR ALL ENTRIES  IN  ist_srcbsik
1414       WHERE
1415              bukrs  =  p_bukrs
1416        AND   belnr = ist_srcbsik-belnr
1417        AND   gjahr = ist_srcbsik-gjahr
1418        AND   buzei = ist_srcbsik-buzei ORDER BY PRIMARY KEY.
1419
1420     IF NOT ist_bseg IS INITIAL.
1421   *---------------  X to Blank
1422       IF p_x2sp = 'X'.
1423         LOOP AT ist_bseg INTO wa_bseg.
1424           l_tabix =   sy-tabix .
1425           IF wa_bseg-zlspr =  g_zlspr_x.
1426             wa_bseg-zlspr =   g_zlspr_sp.
1427             MODIFY ist_bseg  FROM  wa_bseg INDEX l_tabix  TRANSPORTING zlspr.
1428           ENDIF.
1429         ENDLOOP.
1430
1431   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1432   * S/4: BSEG payment block (ZLSPR) via FI_DOCUMENT_CHANGE (FB02); direct write not allowed.
1433   *      MODIFY bseg FROM TABLE ist_bseg.
1434         LOOP AT ist_bseg INTO wa_bseg.
1435           PERFORM zz_s4_bseg_zlspr USING wa_bseg-bukrs wa_bseg-belnr wa_bseg-gjahr wa_bseg-buzei wa_bseg-zlspr.
1436         ENDLOOP.
1437         COMMIT WORK.
1438   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1439
1440       ENDIF.
1441   *------------space to X
1442       IF p_sp2x = 'X'.
1443         LOOP AT ist_bseg INTO wa_bseg.
1444           l_tabix =   sy-tabix .
1445           IF wa_bseg-zlspr =  g_zlspr_sp.
1446             wa_bseg-zlspr =  g_zlspr_x.
1447             MODIFY ist_bseg  FROM  wa_bseg INDEX l_tabix  TRANSPORTING zlspr.
1448           ENDIF.
1449         ENDLOOP.
1450
1451   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1452   * S/4: BSEG payment block (ZLSPR) via FI_DOCUMENT_CHANGE (FB02); direct write not allowed.
1453   *      MODIFY bseg FROM TABLE ist_bseg.
1454         LOOP AT ist_bseg INTO wa_bseg.
1455           PERFORM zz_s4_bseg_zlspr USING wa_bseg-bukrs wa_bseg-belnr wa_bseg-gjahr wa_bseg-buzei wa_bseg-zlspr.
1456         ENDLOOP.
1457         COMMIT WORK.
1458   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1459
1460       ENDIF.
1461   *----+003
1462   *------Blank to R
1463
1464
1465       IF p_sp2r = 'X'.
1466         LOOP AT ist_bseg INTO wa_bseg.
1467           l_tabix =   sy-tabix .
1468           IF wa_bseg-zlspr =  g_zlspr_sp.
1469             wa_bseg-zlspr =  g_zlspr_r.
1470             MODIFY ist_bseg  FROM  wa_bseg INDEX l_tabix  TRANSPORTING zlspr.
1471           ENDIF.
1472         ENDLOOP.
1473
1474   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1475   * S/4: BSEG payment block (ZLSPR) via FI_DOCUMENT_CHANGE (FB02); direct write not allowed.
1476   *      MODIFY  bseg FROM TABLE ist_bseg.
1477         LOOP AT ist_bseg INTO wa_bseg.
1478           PERFORM zz_s4_bseg_zlspr USING wa_bseg-bukrs wa_bseg-belnr wa_bseg-gjahr wa_bseg-buzei wa_bseg-zlspr.
1479         ENDLOOP.
1480         COMMIT WORK.
1481   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1482
1483         COMMIT WORK.
1484       ENDIF.
1485
1486   **------Blank to S
1487
1488   *  IF p_sp2s = 'X'.
1489   *      LOOP AT ist_bseg INTO wa_bseg.
1490   *        l_tabix =   sy-tabix .
1491   *        IF wa_bseg-zlspr =  g_zlspr_sp.
1492   *          wa_bseg-zlspr =  g_zlspr_s.
1493   *       MODIFY ist_bseg  FROM  wa_bseg INDEX l_tabix  TRANSPORTING zlspr.
1494   *        ENDIF.
1495   *      ENDLOOP.
1496   *
1497   *      MODIFY  bseg FROM TABLE ist_bseg.
1498   *
1499   *      COMMIT WORK.
1500   *    ENDIF.
1501
1502   *-------X  to S  and  Blank TO S
1503       IF p_x2s = 'X'.
1504         LOOP AT ist_bseg INTO wa_bseg.
1505           l_tabix =   sy-tabix .
1506   * begin RD1K975843 CAB_ALOK
1507   *        IF wa_bsik-zlspr =  g_zlspr_x  OR wa_bsik-zlspr =  g_zlspr_sp.
1508           IF wa_bseg-zlspr =  g_zlspr_x  OR wa_bseg-zlspr =  g_zlspr_sp.
1509   * end RD1K975843 CAB_ALOK
1510             wa_bseg-zlspr =  g_zlspr_s.
1511             MODIFY ist_bseg  FROM  wa_bseg INDEX l_tabix  TRANSPORTING zlspr.
1512           ENDIF.
1513         ENDLOOP.
1514
1515   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1516   * S/4: BSEG payment block (ZLSPR) via FI_DOCUMENT_CHANGE (FB02); direct write not allowed.
1517   *      MODIFY  bseg FROM TABLE ist_bseg.
1518         LOOP AT ist_bseg INTO wa_bseg.
1519           PERFORM zz_s4_bseg_zlspr USING wa_bseg-bukrs wa_bseg-belnr wa_bseg-gjahr wa_bseg-buzei wa_bseg-zlspr.
1520         ENDLOOP.
1521         COMMIT WORK.
1522   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1523
1524         COMMIT WORK.
1525       ENDIF.
1526   * Begin of RD1K971966 CAB_ALOK CR30004183
1527   **------------------------S To X
1528   *    IF p_s2x = 'X'.
1529   *      LOOP AT ist_bseg INTO wa_bseg.
1530   *        l_tabix =   sy-tabix .
1531   *        IF wa_bseg-zlspr =  g_zlspr_s.
1532   *          wa_bseg-zlspr =  g_zlspr_x.
1533   *          MODIFY ist_bseg  FROM  wa_bseg INDEX l_tabix  TRANSPORTING zlspr.
1534   *        ENDIF.
1535   *      ENDLOOP.
1536   *
1537   *      MODIFY  bseg FROM TABLE ist_bseg.
1538   *
1539   *      COMMIT WORK.
1540   *    ENDIF.
1541   * End of RD1K971966 CAB_ALOK CR30004183
1542   *------+003
1543     ENDIF.
1544
1545
1546
1547   ENDFORM.                    " get_upd_bseg
1548   *&---------------------------------------------------------------------*
1549   *&      Form  get_docs
1550   *&---------------------------------------------------------------------*
1551   *       text
1552   *----------------------------------------------------------------------*
1553   *  -->  p1        text
1554   *  <--  p2        text
1555   *----------------------------------------------------------------------*
1556   FORM get_docs.
1557     SELECT bukrs lifnr umskz gjahr belnr buzei budat bschl zlsch
1558   * begin of < RD1K970594> CAB_ALOK 10.03.2010 CR30003739
1559   *   zlspr shkzg gsber dmbtr wrbtr kidno rebzg APPENDING
1560      zlspr shkzg gsber dmbtr wrbtr waers kidno rebzg
1561   * end of < RD1K970594> CAB_ALOK 10.03.2010 CR30003739
1562   * begin RD1K975843 CAB_ALOK CR 30005441
1563      zfbdt rebzz
1564   * end RD1K975843 CAB_ALOK CR 30005441
1565   *{30007662
1566      blart fipos fistl
1567   *}30007662
1568   *{
1569       ebeln ebelp
1570   *}
1571    APPENDING CORRESPONDING FIELDS OF TABLE
1572                   ist_srcbsik  FROM bsik
1573                   WHERE bukrs  =  p_bukrs
1574                   AND lifnr  IN s_lifnr
1575                   AND gjahr IN s_year
1576   *begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
1577   *                AND gsber IN s_gsber
1578   *end of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
1579   * begin RD1K975843 CAB_ALOK      CR 30005441
1580                   AND BELNR in S_BELNR
1581   * end RD1K975843 CAB_ALOK      CR 30005441
1582                   AND budat IN  s_budat.
1583
1584
1585
1586     """""""Added by Anamika on 21/12/2015 for RD1K999458""""
1587     clear : ist_srcbsik_copy,wa_srcbsik_copy .
1588     refresh : ist_srcbsik_copy[].
1589     if s_BELNR IS not INITIAL.
1590       read TABLE ist_srcbsik into wa_srcbsik_copy index 1.  "#EC CI_NOORDER
1591
1592       SELECT bukrs lifnr umskz gjahr belnr buzei budat bschl
1593       zlsch zlspr shkzg gsber dmbtr wrbtr  rebzg kidno APPENDING
1594     CORRESPONDING FIELDS OF TABLE
1595                    ist_srcbsik_copy  FROM bsik
1596                    WHERE
1597                         bukrs  =  p_bukrs
1598                   AND lifnr  IN s_lifnr
1599                   AND  ZLSPR IN ('A','X','S','R')
1600                   AND BSCHL IN ('21','26')
1601                   AND SHKZG = 'S'
1602                   AND KIDNO ne 'PERIOD END LIABILITY '
1603                   AND KIDNO EQ wa_srcbsik_copy-KIDNO.
1604       SORT ist_srcbsik BY lifnr bschl belnr budat .
1605       SORT ist_srcbsik_copy.
1606       DELETE ADJACENT DUPLICATES  FROM ist_srcbsik_copy.  "#EC CI_NOORDER
1607     ENDIF.
1608     """""""Added by Anamika on 21/12/2015 for RD1K999458""""
1609
1610
1611     IF p_x2sp = 'X'.
1612       DELETE  ist_srcbsik WHERE zlspr <> g_zlspr_x.
1613     ELSEIF p_sp2x = 'X'.
1614       DELETE  ist_srcbsik WHERE NOT  zlspr IS INITIAL.
1615   *-----+003
1616     ELSEIF p_sp2r = 'X'.
1617       DELETE  ist_srcbsik WHERE NOT  zlspr IS INITIAL.
1618     ELSEIF p_x2s = 'X'.
1619       DELETE  ist_srcbsik WHERE ( zlspr <> g_zlspr_x AND zlspr  <>
1620   g_zlspr_sp ).
1621   * Begin of RD1K971966 CAB_ALOK CR30004183
1622   *  ELSEIF p_s2x = 'X'.
1623   *    DELETE  ist_srcbsik WHERE zlspr <> g_zlspr_s.
1624   * end of RD1K971966 CAB_ALOK CR30004183
1625
1626   *  ELSEIF p_sp2s = 'X'.
1627   *    DELETE  ist_srcbsik WHERE NOT  zlspr IS initial.
1628     ENDIF.
1629   *---+003
1630
1631
1632   */..Begin of Change CR :30012666
1633     data : WA_ZFI_BCM_PAYORDR TYPE ZFI_BCM_PAYORDR,
1634            l_tab              type sy-tabix.
1635     IF P_SP2X = 'X'.
1636       LOOP AT ist_srcbsik INTO wa_srcbsik.
1637         l_tab = sy-tabix.
1638         clear : WA_ZFI_BCM_PAYORDR.
1639
1640         SELECT SINGLE * FROM ZFI_BCM_PAYORDR
1641           INTO CORRESPONDING FIELDS OF WA_ZFI_BCM_PAYORDR
1642           WHERE bukrs =  wa_srcbsik-bukrs
1643           and belnr =  wa_srcbsik-belnr
1644           and lifnr =  wa_srcbsik-lifnr.  "#EC CI_NOORDER
1645
1646         if not WA_ZFI_BCM_PAYORDR-pyord is initial
1647           and ( WA_ZFI_BCM_PAYORDR-zstatus = '001' or WA_ZFI_BCM_PAYORDR-zstatus = '002' ) .
1648           wa_srcbsik-inactiv = 'X'.
1649           wa_srcbsik-reason = text-013.
1650           MODIFY ist_srcbsik FROM wa_srcbsik INDEX l_tab TRANSPORTING inactiv reason.
1651         endif.
1652         CLEAR: wa_srcbsik.
1653       endloop.
1654   * Again move inactive lines to ist_srcbsik_inactiv
1655       LOOP AT ist_srcbsik INTO wa_srcbsik WHERE inactiv = 'X'.
1656         APPEND wa_srcbsik TO ist_srcbsik_inactiv.
1657       ENDLOOP.
1658       DELETE ist_srcbsik WHERE inactiv = 'X'.
1659     ENDIF.
1660   */..End of Change CR :30012666
1661
1662   *  *Start of addition Prabu K on 03.07.2009
1663     DATA wa_bkpf TYPE bkpf.
1664     LOOP AT ist_srcbsik INTO wa_srcbsik.
1665
1666       SELECT SINGLE * FROM bkpf INTO wa_bkpf WHERE bukrs = wa_srcbsik-bukrs AND belnr = wa_srcbsik-belnr
1667          AND xref1_hd IN s_xref1.  "#EC CI_NOORDER
1668       IF sy-subrc NE 0.
1669         DELETE TABLE ist_srcbsik FROM wa_srcbsik.
1670       ELSE.
1671         wa_srcbsik-xref1_hd = wa_bkpf-xref1_hd.
1672         MODIFY ist_srcbsik FROM wa_srcbsik.
1673       ENDIF.
1674     ENDLOOP.
1675   *  End of addition Prabu K on 03.07.2009
1676     IF NOT s_usnam   IS INITIAL.
1677       IF NOT ist_srcbsik[] IS INITIAL.
1678         SELECT blart usnam ppnam belnr gjahr bldat budat waers bukrs
1679                           INTO CORRESPONDING FIELDS OF TABLE ist_bkpf
1680                            FROM  bkpf
1681                           FOR ALL ENTRIES IN ist_srcbsik
1682   *                     FROM bkpf
1683                    WHERE bukrs = ist_srcbsik-bukrs
1684                    AND  gjahr = ist_srcbsik-gjahr
1685                    AND  belnr = ist_srcbsik-belnr
1686                    AND  budat = ist_srcbsik-budat
1687                    AND ( usnam IN s_usnam  OR usnam EQ 'WF-BATCH' ).  "#EC CI_NOORDER
1688       ENDIF.
1689
1690       IF NOT ist_bkpf[] IS INITIAL.
1691
1692         LOOP AT ist_bkpf WHERE usnam = 'WF-BATCH' .
1693           MOVE-CORRESPONDING ist_bkpf TO y_doc_nos .
1694           MOVE ist_bkpf-usnam TO y_doc_nos-usrel .
1695           APPEND y_doc_nos .
1696         ENDLOOP.
1697
1698         CALL FUNCTION 'Z_FI_GET_REL_USERNAME'
1699           TABLES
1700             y_doc_nos = y_doc_nos
1701             f_doc_nos = f_doc_nos.
1702   *           EXCEPTIONS
1703   *                not_found = 1
1704   *                OTHERS    = 2.
1705
1706         LOOP AT ist_bkpf .
1707           READ TABLE y_doc_nos WITH KEY bukrs = ist_bkpf-bukrs
1708                                         belnr = ist_bkpf-belnr
1709                                         gjahr = ist_bkpf-gjahr.
1710           IF sy-subrc EQ 0 .
1711             ist_bkpf-usnam = y_doc_nos-usrel .
1712             MODIFY ist_bkpf TRANSPORTING usnam .
1713           ENDIF .
1714         ENDLOOP.
1715
1716
1717         LOOP AT ist_srcbsik.
1718           READ TABLE ist_bkpf WITH KEY bukrs = ist_srcbsik-bukrs
1719                                    belnr = ist_srcbsik-belnr
1720                                    gjahr = ist_srcbsik-gjahr .
1721           IF sy-subrc = 0.
1722             ist_srcbsik-usnam = ist_bkpf-usnam.
1723             MODIFY ist_srcbsik  TRANSPORTING usnam .
1724           ENDIF.
1725         ENDLOOP.
1726
1727         IF NOT s_usnam IS  INITIAL.
1728           DELETE ist_srcbsik WHERE  NOT usnam  IN s_usnam.
1729         ENDIF.
1730
1731       ENDIF.
1732
1733     ENDIF.
1734
1735     ist_bsiks[] = ist_srcbsik[].
1736
1737
1738     REFRESH ist_srcbsik.
1739     CLEAR ist_srcbsik.
1740
1741
1742     LOOP AT ist_bsiks .
1743       IF ist_bsiks-umskz = 'P' OR ist_bsiks-umskz = 'F'  OR ist_bsiks-umskz = 'H' or ist_bsiks-umskz = 'K' or
1744       ist_bsiks-umskz = ':' OR                                " +002
1745       ist_bsiks-umskz  IS INITIAL.
1746         ist_srcbsik = ist_bsiks.
1747         APPEND ist_srcbsik.
1748         CLEAR ist_srcbsik.
1749       ENDIF.
1750     ENDLOOP.
1751
1752
1753
1754     CHECK  NOT ist_srcbsik[] IS INITIAL.
1755
1756     LOOP AT ist_srcbsik.
1757       IF ist_srcbsik-shkzg = 'S'.
1758         ist_srcbsik-dmbtr = ist_srcbsik-dmbtr.
1759         ist_srcbsik-wrbtr = ist_srcbsik-wrbtr.
1760       ELSEIF ist_srcbsik-shkzg = 'H'.
1761         ist_srcbsik-dmbtr = - ist_srcbsik-dmbtr.
1762         ist_srcbsik-wrbtr = - ist_srcbsik-wrbtr.
1763       ENDIF.
1764       MODIFY ist_srcbsik .
1765     ENDLOOP.
1766
1767     ist_bsiks[] = ist_srcbsik[].
1768
1769     SORT ist_srcbsik BY lifnr bschl belnr budat.
1770
1771   ENDFORM.                    " get_docs
1772   *&---------------------------------------------------------------------*
1773   *&      Form  authority_check
1774   *&---------------------------------------------------------------------*
1775   *       text
1776   *----------------------------------------------------------------------*
1777   *      -->P_0446   text
1778   *----------------------------------------------------------------------*
1779   FORM authority_check USING    p_actvt.
1780     AUTHORITY-CHECK OBJECT 'ZFIBLOCKR'
1781                ID 'ACTVT' FIELD p_actvt.
1782     IF sy-subrc <> 0.
1783       MESSAGE  e077(s#) WITH 'ZFIBLOCKR' .
1784     ENDIF.
1785
1786   ENDFORM.                    " authority_check
1787   *&---------------------------------------------------------------------*
1788   *&      Form  authority_check_x
1789   *&---------------------------------------------------------------------*
1790   *       text
1791   *----------------------------------------------------------------------*
1792   *      -->P_0461   text
1793   *----------------------------------------------------------------------*
1794   FORM authority_check_x USING    value(p_0461).
1795     AUTHORITY-CHECK OBJECT 'ZFIBLOCKX'
1796                ID 'ACTVT' FIELD p_0461.
1797     IF sy-subrc <> 0.
1798       MESSAGE  e077(s#) WITH 'ZFIBLOCKX'.
1799     ENDIF.
1800   ENDFORM.                    " authority_check_x
1801   *----------Start of <RD1K960891>
1802
1803   *&---------------------------------------------------------------------*
1804   *&      Form  get_docs_cust
1805   *&---------------------------------------------------------------------*
1806   *       text
1807   *----------------------------------------------------------------------*
1808   *  -->  p1        text
1809   *  <--  p2        text
1810   *----------------------------------------------------------------------*
1811   FORM get_docs_cust.
1812     SELECT bukrs kunnr umskz gjahr belnr buzei budat bschl zlsch
1813   *begin of <RD1K967585> CAB_ALOK 26.11.2009 CR30002778
1814   *     zlspr shkzg gsber dmbtr wrbtr kidno APPENDING
1815   *  begin of < RD1K970594> CAB_ALOK 10.03.2010 CR30003739
1816   *     zlspr shkzg gsber dmbtr wrbtr kidno rebzg APPENDING
1817        zlspr shkzg gsber dmbtr wrbtr waers kidno rebzg APPENDING
1818   * end
1819   *end of <RD1K967585> CAB_ALOK 26.11.2009 CR30002778
1820       CORRESPONDING FIELDS OF TABLE
1821                     ist_srcbsid  FROM bsid
1822                     WHERE
1823                     bukrs  =  p_bukrs
1824                     AND kunnr  IN s_kunnr
1825                     AND gjahr IN s_year
1826   *begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
1827   *                  AND gsber IN s_gsber
1828   *end of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
1829   * begin RD1K975843 CAB_ALOK      CR 30005441
1830                    AND BELNR in S_BELNR
1831   * end RD1K975843 CAB_ALOK      CR 30005441
1832                     AND budat IN  s_budat.  "#EC CI_NOORDER
1833
1834
1835
1836     IF p_x2sp = 'X'.
1837       DELETE  ist_srcbsid WHERE zlspr <> g_zlspr_x.
1838     ELSEIF p_sp2x = 'X'.
1839       DELETE  ist_srcbsid WHERE NOT  zlspr IS INITIAL.
1840   *-----+003
1841     ELSEIF p_sp2r = 'X'.
1842       DELETE  ist_srcbsid WHERE NOT  zlspr IS INITIAL.
1843     ELSEIF p_x2s = 'X'.
1844       DELETE  ist_srcbsid WHERE ( zlspr <> g_zlspr_x AND zlspr  <>
1845   g_zlspr_sp ).
1846   * Begin of RD1K971966 CAB_ALOK CR30004183
1847   *  ELSEIF p_s2x = 'X'.
1848   *    DELETE  ist_srcbsid WHERE zlspr <> g_zlspr_s.
1849   * End of RD1K971966 CAB_ALOK CR30004183
1850   *  ELSEIF p_sp2s = 'X'.
1851   *    DELETE  ist_srcbsid WHERE NOT  zlspr IS initial.
1852     ENDIF.
1853   *---+003
1854
1855   *  *Start of addition Prabu K on 03.07.2009
1856     DATA wa_bkpf TYPE bkpf.
1857     LOOP AT ist_srcbsid INTO wa_srcbsid.
1858
1859       SELECT SINGLE * FROM bkpf INTO wa_bkpf WHERE bukrs = wa_srcbsid-bukrs AND belnr = wa_srcbsid-belnr
1860          AND xref1_hd IN s_xref1.  "#EC CI_NOORDER
1861       IF sy-subrc NE 0.
1862         DELETE TABLE ist_srcbsid FROM wa_srcbsid.
1863       ELSE.
1864         wa_srcbsid-xref1_hd = wa_bkpf-xref1_hd.
1865         MODIFY ist_srcbsid FROM wa_srcbsid.
1866       ENDIF.
1867
1868     ENDLOOP.
1869   *  End  of addition Prabu K on 03.07.2009
1870     IF NOT s_usnam   IS INITIAL.
1871       IF NOT ist_srcbsid[] IS INITIAL.
1872         SELECT blart usnam ppnam belnr gjahr bldat budat waers bukrs
1873                           INTO CORRESPONDING FIELDS OF TABLE ist_bkpf
1874                            FROM  bkpf
1875                           FOR ALL ENTRIES IN ist_srcbsid
1876   *                     FROM bkpf
1877                    WHERE bukrs = ist_srcbsid-bukrs
1878                    AND  gjahr = ist_srcbsid-gjahr
1879                    AND  belnr = ist_srcbsid-belnr
1880                    AND  budat = ist_srcbsid-budat
1881                    AND ( usnam IN s_usnam  OR usnam EQ 'WF-BATCH' ).  "#EC CI_NOORDER
1882       ENDIF.
1883
1884       IF NOT ist_bkpf[] IS INITIAL.
1885
1886         LOOP AT ist_bkpf WHERE usnam = 'WF-BATCH' .
1887           MOVE-CORRESPONDING ist_bkpf TO y_doc_nos .
1888           MOVE ist_bkpf-usnam TO y_doc_nos-usrel .
1889           APPEND y_doc_nos .
1890         ENDLOOP.
1891
1892         CALL FUNCTION 'Z_FI_GET_REL_USERNAME'
1893           TABLES
1894             y_doc_nos = y_doc_nos
1895             f_doc_nos = f_doc_nos.
1896   *           EXCEPTIONS
1897   *                not_found = 1
1898   *                OTHERS    = 2.
1899
1900         LOOP AT ist_bkpf .
1901           READ TABLE y_doc_nos WITH KEY bukrs = ist_bkpf-bukrs
1902                                         belnr = ist_bkpf-belnr
1903                                         gjahr = ist_bkpf-gjahr.
1904           IF sy-subrc EQ 0 .
1905             ist_bkpf-usnam = y_doc_nos-usrel .
1906             MODIFY ist_bkpf TRANSPORTING usnam .
1907           ENDIF .
1908         ENDLOOP.
1909
1910
1911         LOOP AT ist_srcbsid.
1912           READ TABLE ist_bkpf WITH KEY bukrs = ist_srcbsid-bukrs
1913                                    belnr = ist_srcbsid-belnr
1914                                    gjahr = ist_srcbsid-gjahr .
1915           IF sy-subrc = 0.
1916             ist_srcbsid-usnam = ist_bkpf-usnam.
1917             MODIFY ist_srcbsid  TRANSPORTING usnam .
1918           ENDIF.
1919         ENDLOOP.
1920
1921         IF NOT s_usnam IS  INITIAL.
1922           DELETE ist_srcbsid WHERE  NOT usnam  IN s_usnam.
1923         ENDIF.
1924
1925       ENDIF.
1926
1927     ENDIF.
1928
1929     ist_bsids[] = ist_srcbsid[].
1930
1931
1932     REFRESH ist_srcbsid.
1933     CLEAR ist_srcbsid.
1934
1935
1936     LOOP AT ist_bsids .
1937   *{001
1938   *    IF ist_bsids-umskz = 'K' OR ist_bsids-umskz = 'H'.
1939       IF ( ist_bsids-umskz = 'K' OR ist_bsids-umskz = 'H'  OR ist_bsids-umskz = 'O') OR
1940   *Start of changes by SOGET - 003
1941   *( ist_bsids-umskz = ' ' and ist_bsids-zlsch = 'P' ).
1942          ( ist_bsids-umskz = ' ' and ist_bsids-zlsch = 'P' ) or ( ist_bsids-umskz = ' ' and ist_bsids-zlsch = 'Q' )
1943   * Begin of <RD1K973788>  CAB_ALOK CR 30004826
1944   * OR   ist_bsids-kunnr BETWEEN 'DS000000001' and 'DS999999999' "Commented, as told by Mr. Kalia
1945   * End of <RD1K973788>  CAB_ALOK CR 30004826
1946         .
1947   *End of changes by SOGET - 003
1948   *}001
1949         ist_srcbsid = ist_bsids.
1950         APPEND ist_srcbsid.
1951         CLEAR ist_srcbsid.
1952       ENDIF.
1953     ENDLOOP.
1954
1955
1956
1957     CHECK  NOT ist_srcbsid[] IS INITIAL.
1958
1959     LOOP AT ist_srcbsid.
1960       IF ist_srcbsid-shkzg = 'S'.
1961         ist_srcbsid-dmbtr = ist_srcbsid-dmbtr.
1962         ist_srcbsid-wrbtr = ist_srcbsid-wrbtr.
1963       ELSEIF ist_srcbsid-shkzg = 'H'.
1964         ist_srcbsid-dmbtr = - ist_srcbsid-dmbtr.
1965         ist_srcbsid-wrbtr = - ist_srcbsid-wrbtr.
1966       ENDIF.
1967       MODIFY ist_srcbsid .
1968     ENDLOOP.
1969
1970     ist_bsids[] = ist_srcbsid[].
1971
1972     SORT ist_srcbsid BY kunnr bschl belnr budat.
1973
1974
1975   ENDFORM.                    " get_docs_cust
1976   *&---------------------------------------------------------------------*
1977   *&      Form  display_docs_cust
1978   *&---------------------------------------------------------------------*
1979   *       text
1980   *----------------------------------------------------------------------*
1981   *  -->  p1        text
1982   *  <--  p2        text
1983   *----------------------------------------------------------------------*
1984   FORM display_docs_cust.
1985     PERFORM init_fieldcat_cust.
1986   *begin of <RD1K967585> CAB_ALOK 26.11.2009 CR30002778
1987   *  make fieldcat for inactive items
1988     PERFORM init_fieldcat_inactiv_cust.
1989   *end of <RD1K967585> CAB_ALOK 26.11.2009 CR30002778
1990     PERFORM eventtab_build_cust TABLES gt_events.
1991   *  PERFORM comment_build USING gt_list_top_of_page[].
1992     PERFORM  sort_build_cust .
1993   *begin of <RD1K967585> CAB_ALOK 26.11.2009 CR30002778
1994   *    PERFORM  print_alv_cust.
1995   *  display multiple list ALV
1996     PERFORM print_multi_alv_cust.
1997   *end of <RD1K967585> CAB_ALOK 26.11.2009 CR30002778
1998
1999
2000
2001   ENDFORM.                    " display_docs_cust
2002   *&---------------------------------------------------------------------*
2003   *&      Form  init_fieldcat_cust
2004   *&---------------------------------------------------------------------*
2005   *       text
2006   *----------------------------------------------------------------------*
2007   *  -->  p1        text
2008   *  <--  p2        text
2009   *----------------------------------------------------------------------*
2010   FORM init_fieldcat_cust.
2011     w_repid  = sy-repid.
2012
2013     mpos = 0.
2014     mpos = mpos + 1.
2015     ist_fieldcat-fieldname = 'SELCBOX'.
2016     ist_fieldcat-tabname = 'IST_SRCBSID'.
2017     ist_fieldcat-ddictxt = 'M'.
2018     ist_fieldcat-col_pos =  mpos.
2019     ist_fieldcat-seltext_m  = 'Select'.
2020     ist_fieldcat-lowercase  = 'Y'.
2021     ist_fieldcat-checkbox = 'X'.
2022     ist_fieldcat-input = 'X'.
2023     APPEND ist_fieldcat TO ist_fcat.
2024     CLEAR ist_fieldcat.
2025
2026     mpos = mpos + 1.
2027     ist_fieldcat-fieldname = 'KUNNR'.
2028     ist_fieldcat-tabname = 'IST_SRCBSID'.
2029     ist_fieldcat-ddictxt = 'M'.
2030     ist_fieldcat-col_pos =  mpos.
2031   *begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
2032   *  ist_fieldcat-seltext_m  = 'CustomerNumber'.
2033     ist_fieldcat-seltext_m  = 'Cstmr No.'.
2034   *end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
2035     ist_fieldcat-lowercase  = 'Y'.
2036     APPEND ist_fieldcat TO ist_fcat.
2037     CLEAR ist_fieldcat.
2038
2039     mpos = mpos + 1.
2040     ist_fieldcat-fieldname = 'BELNR'.
2041     ist_fieldcat-tabname = 'IST_SRCBSID'.
2042     ist_fieldcat-ddictxt = 'M'.
2043     ist_fieldcat-col_pos =  mpos.
2044     ist_fieldcat-seltext_m  = 'Doc.No.'.
2045     ist_fieldcat-lowercase  = 'Y'.
2046     APPEND ist_fieldcat TO ist_fcat.
2047     CLEAR ist_fieldcat.
2048
2049   *begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
2050   *    mpos = mpos + 1.
2051   *  ist_fieldcat-fieldname = 'GSBER'.
2052   *  ist_fieldcat-tabname = 'IST_SRCBSID'.
2053   *  ist_fieldcat-ddictxt = 'M'.
2054   *  ist_fieldcat-col_pos =  mpos.
2055   *  ist_fieldcat-seltext_m  = 'Business Area'.
2056   *  ist_fieldcat-lowercase  = 'Y'.
2057   *  APPEND ist_fieldcat TO ist_fcat.
2058   *  CLEAR ist_fieldcat.
2059   *end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
2060
2061   *---+001
2062     mpos = mpos + 1.
2063     ist_fieldcat-fieldname = 'KIDNO'.
2064     ist_fieldcat-tabname = 'IST_SRCBSID'.
2065     ist_fieldcat-ddictxt = 'M'.
2066     ist_fieldcat-col_pos =  mpos.
2067   *begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
2068   *    ist_fieldcat-seltext_m  = 'Payment Reference'.
2069     ist_fieldcat-seltext_m  = 'Pymt Ref'.
2070   *end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
2071     ist_fieldcat-lowercase  = 'Y'.
2072     APPEND ist_fieldcat TO ist_fcat.
2073     CLEAR ist_fieldcat.
2074   *-------+001
2075   *---+002
2076
2077     mpos = mpos + 1.
2078     ist_fieldcat-fieldname = 'REBZG'.
2079     ist_fieldcat-tabname = 'IST_SRCBSID'.
2080     ist_fieldcat-ddictxt = 'M'.
2081     ist_fieldcat-col_pos =  mpos.
2082   *begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
2083   *    ist_fieldcat-seltext_m  = 'Invoice Reference'.
2084     ist_fieldcat-seltext_m  = 'Inv Ref'.
2085   *end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
2086   *  ist_fieldcat-lowercase  = 'Y'.
2087     APPEND ist_fieldcat TO ist_fcat.
2088     CLEAR ist_fieldcat.
2089
2090   *begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
2091   *  *---testing purpose
2092   *    mpos = mpos + 1.
2093   *  ist_fieldcat-fieldname = 'SHKZG'.
2094   *  ist_fieldcat-tabname = 'IST_SRCBSID'.
2095   *  ist_fieldcat-ddictxt = 'M'.
2096   *  ist_fieldcat-col_pos =  mpos.
2097   *  ist_fieldcat-seltext_m  = 'INdicator'.
2098   **  ist_fieldcat-lowercase  = 'Y'.
2099   *  APPEND ist_fieldcat TO ist_fcat.
2100   *  CLEAR ist_fieldcat.
2101   **-------+002
2102   *    mpos = mpos + 1.
2103   *  ist_fieldcat-fieldname = 'GJAHR'.
2104   *  ist_fieldcat-tabname = 'IST_SRCBSID'.
2105   *  ist_fieldcat-ddictxt = 'M'.
2106   *  ist_fieldcat-col_pos =  mpos.
2107   *  ist_fieldcat-seltext_m  = 'Year'.
2108   *  ist_fieldcat-lowercase  = 'Y'.
2109   *  APPEND ist_fieldcat TO ist_fcat.
2110   *  CLEAR ist_fieldcat.
2111   *end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
2112
2113     mpos = mpos + 1.
2114     ist_fieldcat-fieldname = 'BUZEI'.
2115     ist_fieldcat-tabname = 'IST_SRCBSID'.
2116     ist_fieldcat-ddictxt = 'M'.
2117     ist_fieldcat-col_pos =  mpos.
2118     ist_fieldcat-seltext_m  = 'Item.no.'.
2119     ist_fieldcat-lowercase  = 'Y'.
2120     APPEND ist_fieldcat TO ist_fcat.
2121     CLEAR ist_fieldcat.
2122
2123     mpos = mpos + 1.
2124     ist_fieldcat-fieldname = 'BSCHL'.
2125     ist_fieldcat-tabname = 'IST_SRCBSID'.
2126     ist_fieldcat-ddictxt = 'M'.
2127     ist_fieldcat-col_pos =  mpos.
2128   *begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
2129   *  ist_fieldcat-seltext_m  = 'Posting Key.'.
2130     ist_fieldcat-seltext_m  = 'PK'.
2131   *end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
2132     ist_fieldcat-lowercase  = 'Y'.
2133     APPEND ist_fieldcat TO ist_fcat.
2134     CLEAR ist_fieldcat.
2135
2136     mpos = mpos + 1.
2137     ist_fieldcat-fieldname = 'BUDAT'.
2138     ist_fieldcat-tabname = 'IST_SRCBSID'.
2139     ist_fieldcat-ddictxt = 'M'.
2140     ist_fieldcat-col_pos =  mpos.
2141   *begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
2142   *  ist_fieldcat-seltext_m  = 'Posting Date'.
2143     ist_fieldcat-seltext_m  = 'Post Dt'.
2144   *end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
2145     ist_fieldcat-lowercase  = 'Y'.
2146     APPEND ist_fieldcat TO ist_fcat.
2147     CLEAR ist_fieldcat.
2148
2149   *begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
2150   *    mpos = mpos + 1.
2151   *  ist_fieldcat-fieldname = 'DMBTR'.
2152   *  ist_fieldcat-tabname = 'IST_SRCBSID'.
2153   *  ist_fieldcat-ddictxt = 'M'.
2154   *  ist_fieldcat-col_pos =  mpos.
2155   *  ist_fieldcat-seltext_m  = 'AmtInLclCurncy'.
2156   *  ist_fieldcat-lowercase  = 'Y'.
2157   *  APPEND ist_fieldcat TO ist_fcat.
2158   *  CLEAR ist_fieldcat.
2159   *end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
2160
2161     mpos = mpos + 1.
2162     ist_fieldcat-fieldname = 'WRBTR'.
2163     ist_fieldcat-tabname = 'IST_SRCBSID'.
2164     ist_fieldcat-ddictxt = 'M'.
2165     ist_fieldcat-col_pos =  mpos.
2166   *begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
2167   *  ist_fieldcat-seltext_m  = 'AmtInDocCurncy'.
2168     ist_fieldcat-seltext_m  = 'Amt In Doc Cur'.
2169   *end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
2170     ist_fieldcat-lowercase  = 'Y'.
2171     APPEND ist_fieldcat TO ist_fcat.
2172     CLEAR ist_fieldcat.
2173
2174   * begin of < RD1K970594> CAB_ALOK 10.03.2010 CR30003739
2175     mpos = mpos + 1.
2176     ist_fieldcat-fieldname = 'WAERS'.
2177     ist_fieldcat-tabname = 'IST_SRCBSID'.
2178     ist_fieldcat-ddictxt = 'M'.
2179     ist_fieldcat-col_pos =  mpos.
2180     ist_fieldcat-seltext_m  = 'Curr'.
2181     ist_fieldcat-lowercase  = 'Y'.
2182     APPEND ist_fieldcat TO ist_fcat.
2183     CLEAR ist_fieldcat.
2184   * end of < RD1K970594> CAB_ALOK 10.03.2010 CR30003739
2185
2186     mpos = mpos + 1.
2187     ist_fieldcat-fieldname = 'ZLSCH'.
2188     ist_fieldcat-tabname = 'IST_SRCBSID'.
2189     ist_fieldcat-ddictxt = 'M'.
2190     ist_fieldcat-col_pos =  mpos.
2191   *begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
2192   *  ist_fieldcat-seltext_m  = 'PaymntMethod'.
2193     ist_fieldcat-seltext_m  = 'PM'.
2194   *end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
2195     ist_fieldcat-lowercase  = 'Y'.
2196     APPEND ist_fieldcat TO ist_fcat.
2197     CLEAR ist_fieldcat.
2198
2199     mpos = mpos + 1.
2200     ist_fieldcat-fieldname = 'ZLSPR'.
2201     ist_fieldcat-tabname = 'IST_SRCBSID'.
2202     ist_fieldcat-ddictxt = 'M'.
2203     ist_fieldcat-col_pos =  mpos.
2204   *begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
2205   *  ist_fieldcat-seltext_m  = 'PaymntBlock'.
2206     ist_fieldcat-seltext_m  = 'PB'.
2207   *end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
2208     ist_fieldcat-lowercase  = 'Y'.
2209     APPEND ist_fieldcat TO ist_fcat.
2210     CLEAR ist_fieldcat.
2211
2212   *  *Start of addition Prabu K on 06.07.2009
2213     mpos = mpos + 1.
2214     ist_fieldcat-fieldname = 'XREF1_HD'.
2215     ist_fieldcat-tabname = 'IST_SRCBSID'.
2216     ist_fieldcat-ddictxt = 'M'.
2217     ist_fieldcat-col_pos =  mpos.
2218   *begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
2219   *  ist_fieldcat-seltext_m  = 'Location'.
2220     ist_fieldcat-seltext_m  = 'Loc'.
2221   *end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
2222     ist_fieldcat-lowercase  = 'Y'.
2223     APPEND ist_fieldcat TO ist_fcat.
2224     CLEAR ist_fieldcat.
2225
2226   * End of addition Prabu K on 06.07.2009
2227
2228   *begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
2229   *    IF NOT s_usnam IS INITIAL.
2230   *    mpos = mpos + 1.
2231   *    ist_fieldcat-fieldname = 'USNAM'.
2232   *    ist_fieldcat-tabname = 'IST_SRCBSID'.
2233   *    ist_fieldcat-ddictxt = 'M'.
2234   *    ist_fieldcat-col_pos =  mpos.
2235   *    ist_fieldcat-seltext_m  = 'Created By'.
2236   *    ist_fieldcat-lowercase  = 'Y'.
2237   *    APPEND ist_fieldcat TO ist_fcat.
2238   *    CLEAR ist_fieldcat.
2239   *  ENDIF.
2240   *end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
2241
2242
2243   ENDFORM.                    " init_fieldcat_cust
2244   *&---------------------------------------------------------------------*
2245   *&      Form  eventtab_build_cust
2246   *&---------------------------------------------------------------------*
2247   *       text
2248   *----------------------------------------------------------------------*
2249   *      -->P_GT_EVENTS[]  text
2250   *----------------------------------------------------------------------*
2251   FORM eventtab_build_cust TABLES   p_gt_events.
2252     DATA : ls_event TYPE slis_alv_event.
2253     CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
2254       EXPORTING
2255         i_list_type = 0
2256       IMPORTING
2257         et_events   = gt_events.
2258     READ TABLE gt_events WITH KEY name =  slis_ev_user_command
2259                               INTO ls_event.
2260     IF sy-subrc = 0.
2261       MOVE 'MAKEC_COMMAND' TO ls_event-form.
2262       APPEND ls_event TO gt_events.
2263     ENDIF.
2264     CLEAR ls_event.
2265   *begin of <RD1K967585> CAB_ALOK 03.12.2009 CR30002778
2266     CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
2267       EXPORTING
2268         i_list_type = 0
2269       IMPORTING
2270         et_events   = gt_events_inactiv.
2271     CLEAR ls_event.
2272   *end  of <RD1K967585> CAB_ALOK 03.12.2009 CR30002778
2273
2274   ENDFORM.                    " eventtab_build_cust
2275   *&---------------------------------------------------------------------*
2276   *&      Form  print_alv_cust
2277   *&---------------------------------------------------------------------*
2278   *       text
2279   *----------------------------------------------------------------------*
2280   *  -->  p1        text
2281   *  <--  p2        text
2282   *----------------------------------------------------------------------*
2283   *Begin  of <RD1K967585> CAB_ALOK 03.12.2009 CR30002778
2284   *FORM print_alv_cust.
2285   *  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
2286   *    EXPORTING
2287   *      i_callback_program       = w_repid
2288   *      i_callback_pf_status_set = 'ALV_PFSTS'
2289   *      i_callback_user_command  = 'MAKEC_COMMAND'
2290   *      is_layout                = is_layout
2291   *      it_fieldcat              = ist_fcat[]
2292   *      it_sort                  = lt_sorttab
2293   *      it_events                = gt_events
2294   *      i_save                   = 'A'
2295   *    TABLES
2296   *      t_outtab                 = ist_srcbsid.
2297   *  IF sy-subrc <> 0.
2298   **    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
2299   **            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
2300   *  ENDIF.
2301   *
2302   *
2303   *ENDFORM.                    " print_alv
2304   **---------------------------------------------------------------------*
2305   **       FORM alv_pfst                                                 *
2306   **---------------------------------------------------------------------*
2307   **       ........                                                      *
2308   **---------------------------------------------------------------------*
2309   **  -->  RT_EXTAB                                                      *
2310   **---------------------------------------------------------------------*
2311   *FORM alv_pfsts USING rt_extab TYPE slis_t_extab.
2312   *  SET PF-STATUS 'S100'.
2313   *ENDFORM.                    "alv_pfsts
2314   *end  of <RD1K967585> CAB_ALOK 07.12.2009 CR30002778
2315
2316   *---------------------------------------------------------------------*
2317   *       FORM makec_command                                             *
2318   *---------------------------------------------------------------------*
2319   *       ........                                                      *
2320   *---------------------------------------------------------------------*
2321   *  -->  R_UCOMM                                                       *
2322   *  -->  RS_SELFIELD                                                   *
2323   *---------------------------------------------------------------------*
2324   FORM makec_command USING r_ucomm LIKE sy-ucomm
2325                           rs_selfield TYPE slis_selfield.
2326   *-----------------------------------------------------*
2327   *-----------------------------------------------------*
2328     DATA : index_aux LIKE sy-tabix.
2329     index_aux = rs_selfield-tabindex.
2330     CASE r_ucomm.
2331
2332       WHEN 'REL'.
2333         DELETE ist_srcbsid WHERE  selcbox <> 'X'.
2334
2335         PERFORM   get_upd_bsid.
2336         PERFORM   get_upd_bsegc.
2337   *Begin of <RD1K967585> CAB_ALOK 09.12.2009 CR30002778
2338         PERFORM update_zfi_rem_pyblck_l .           "update logs
2339   *End of <RD1K967585> CAB_ALOK 09.12.2009 CR30002778
2340         LEAVE SCREEN.
2341       WHEN 'ALL'.
2342         PERFORM  select_allc.
2343       WHEN 'SAL'.
2344         PERFORM  deselect_allc.
2345
2346       WHEN '&F03' OR 'BACK' .
2347         LEAVE  PROGRAM.
2348   *Begin of <RD1K967585> CAB_ALOK 03.12.2009 CR30002778
2349       WHEN 'REP'.
2350         PERFORM display_inactive_alv_cust.
2351   *End of <RD1K967585> CAB_ALOK 03.12.2009 CR30002778
2352
2353     ENDCASE.
2354
2355   ENDFORM.                    "makec_command
2356   *---------------------------------------------------------------------*
2357   *&      Form  select_all
2358   *&---------------------------------------------------------------------*
2359   *       text
2360   *----------------------------------------------------------------------*
2361   *  -->  p1        text
2362   *  <--  p2        text
2363   *----------------------------------------------------------------------*
2364   FORM select_allc.
2365     LOOP AT ist_srcbsid.
2366       ist_srcbsid-selcbox = 'X'.
2367       MODIFY ist_srcbsid.
2368     ENDLOOP.
2369
2370   ENDFORM.                    " select_all
2371   *&---------------------------------------------------------------------*
2372   *&      Form  deselect_all
2373   *&---------------------------------------------------------------------*
2374   *       text
2375   *----------------------------------------------------------------------*
2376   *  -->  p1        text
2377   *  <--  p2        text
2378   *----------------------------------------------------------------------*
2379   FORM deselect_allc.
2380     LOOP AT ist_srcbsid.
2381       ist_srcbsid-selcbox = ' '.
2382       MODIFY ist_srcbsid.
2383     ENDLOOP.
2384   ENDFORM.                    " deselect_all
2385   *&---------------------------------------------------------------------
2386   *&---------------------------------------------------------------------*
2387   *&      Form  get_upd_BSID
2388   *&---------------------------------------------------------------------*
2389   *       text
2390   *----------------------------------------------------------------------*
2391   *  -->  p1        text
2392   *  <--  p2        text
2393   *----------------------------------------------------------------------*
2394   FORM get_upd_bsid.
2395
2396     DATA : l_tabix  TYPE sy-tabix.
2397
2398     CHECK NOT ist_srcbsid[] IS INITIAL.
2399
2400     SELECT * INTO TABLE ist_bsid   FROM bsid
2401       FOR ALL ENTRIES  IN  ist_srcbsid
2402       WHERE   kunnr = ist_srcbsid-kunnr
2403             AND  bukrs  =  p_bukrs
2404              AND gjahr = ist_srcbsid-gjahr
2405              AND belnr = ist_srcbsid-belnr
2406              AND buzei = ist_srcbsid-buzei.
2407   *------------X  to blank
2408     IF NOT ist_bsid IS INITIAL.
2409       IF p_x2sp = 'X'.
2410         LOOP AT ist_bsid INTO wa_bsid.
2411           l_tabix =   sy-tabix .
2412           IF wa_bsid-zlspr =  g_zlspr_x.
2413             wa_bsid-zlspr =  space.
2414             MODIFY ist_bsid  FROM  wa_bsid INDEX l_tabix  TRANSPORTING zlspr.
2415           ENDIF.
2416         ENDLOOP.
2417
2418   "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
2419   *      MODIFY  bsik FROM TABLE ist_bsik.
2420
2421   *      COMMIT WORK.
2422   "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
2423       ENDIF.
2424
2425   *---------------blank to X
2426       IF p_sp2x = 'X'.
2427         LOOP AT ist_bsid INTO wa_bsid.
2428           l_tabix =   sy-tabix .
2429           IF wa_bsid-zlspr =  g_zlspr_sp.
2430             wa_bsid-zlspr =  'X'.
2431             MODIFY ist_bsid  FROM  wa_bsid INDEX l_tabix  TRANSPORTING zlspr
2432         .
2433           ENDIF.
2434         ENDLOOP.
2435
2436   "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
2437   *      MODIFY  bsik FROM TABLE ist_bsik.
2438
2439   *      COMMIT WORK.
2440   "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
2441       ENDIF.
2442   *---------+003
2443   *------------------Blank to R
2444       IF p_sp2r = 'X'.
2445         LOOP AT ist_bsid INTO wa_bsid.
2446           l_tabix =   sy-tabix .
2447           IF wa_bsid-zlspr =  g_zlspr_sp.
2448             wa_bsid-zlspr =  g_zlspr_r.
2449             MODIFY ist_bsid  FROM  wa_bsid INDEX l_tabix  TRANSPORTING zlspr.
2450           ENDIF.
2451         ENDLOOP.
2452
2453   "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
2454   *      MODIFY  bsik FROM TABLE ist_bsik.
2455
2456   *      COMMIT WORK.
2457   "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
2458       ENDIF.
2459   *------------Blank to S
2460   *  IF p_sp2s = 'X'.
2461   *      LOOP AT ist_BSID INTO wa_BSID.
2462   *        l_tabix =   sy-tabix .
2463   *        IF wa_BSID-zlspr =  g_zlspr_sp.
2464   *          wa_BSID-zlspr =  g_zlspr_s.
2465   *       MODIFY ist_BSID  FROM  wa_BSID INDEX l_tabix  TRANSPORTING zlspr
2466   *.
2467   *        ENDIF.
2468   *      ENDLOOP.
2469   *
2470   *      MODIFY  BSID FROM TABLE ist_BSID.
2471   *
2472   *      COMMIT WORK.
2473   *    ENDIF.
2474
2475   *----------------X to S
2476
2477
2478
2479       IF p_x2s = 'X'.
2480         LOOP AT ist_bsid INTO wa_bsid.
2481           l_tabix =   sy-tabix .
2482           IF wa_bsid-zlspr =  g_zlspr_x  OR wa_bsid-zlspr =  g_zlspr_sp.
2483             wa_bsid-zlspr =  g_zlspr_s.
2484             MODIFY ist_bsid  FROM  wa_bsid INDEX l_tabix  TRANSPORTING zlspr.
2485           ENDIF.
2486         ENDLOOP.
2487
2488   "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
2489   *      MODIFY  bsik FROM TABLE ist_bsik.
2490
2491   *      COMMIT WORK.
2492   "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
2493       ENDIF.
2494
2495   * Begin of RD1K971966 CAB_ALOK CR30004183
2496   **-----------S to X
2497   *     IF p_s2x = 'X'.
2498   *      LOOP AT ist_bsid INTO wa_bsid.
2499   *        l_tabix =   sy-tabix .
2500   *        IF wa_bsid-zlspr =  g_zlspr_s.
2501   *          wa_bsid-zlspr =  g_zlspr_x.
2502   *          MODIFY ist_bsid  FROM  wa_bsid INDEX l_tabix  TRANSPORTING zlspr.
2503   *        ENDIF.
2504   *      ENDLOOP.
2505   *
2506   *      MODIFY  bsid FROM TABLE ist_bsid.
2507   *
2508   *      COMMIT WORK.
2509   *    ENDIF.
2510   * end of RD1K971966 CAB_ALOK CR30004183
2511
2512   *-------+003
2513     ENDIF.
2514   *  LEAVE SCREEN.
2515   ENDFORM.                    " get_upd_BSID
2516   *
2517   *&---------------------------------------------------------------------*
2518   *&      Form  get_upd_bseg
2519   *&---------------------------------------------------------------------*
2520   *       text
2521   *----------------------------------------------------------------------*
2522   *  -->  p1        text
2523   *  <--  p2        text
2524   *----------------------------------------------------------------------*
2525   FORM get_upd_bsegc.
2526     DATA : l_tabix  TYPE sy-tabix.
2527
2528     CHECK NOT ist_srcbsid[] IS INITIAL.
2529
2530     SELECT * INTO TABLE ist_bseg   FROM bseg
2531       FOR ALL ENTRIES  IN  ist_srcbsid
2532       WHERE
2533              bukrs  =  p_bukrs
2534        AND   belnr = ist_srcbsid-belnr
2535        AND   gjahr = ist_srcbsid-gjahr
2536        AND   buzei = ist_srcbsid-buzei ORDER BY PRIMARY KEY.
2537
2538     IF NOT ist_bseg IS INITIAL.
2539   *---------------  X to Blank
2540       IF p_x2sp = 'X'.
2541         LOOP AT ist_bseg INTO wa_bseg.
2542           l_tabix =   sy-tabix .
2543           IF wa_bseg-zlspr =  g_zlspr_x.
2544             wa_bseg-zlspr =   g_zlspr_sp.
2545             MODIFY ist_bseg  FROM  wa_bseg INDEX l_tabix  TRANSPORTING zlspr.
2546           ENDIF.
2547         ENDLOOP.
2548
2549   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
2550   * S/4: BSEG payment block (ZLSPR) via FI_DOCUMENT_CHANGE (FB02); direct write not allowed.
2551   *      MODIFY bseg FROM TABLE ist_bseg.
2552         LOOP AT ist_bseg INTO wa_bseg.
2553           PERFORM zz_s4_bseg_zlspr USING wa_bseg-bukrs wa_bseg-belnr wa_bseg-gjahr wa_bseg-buzei wa_bseg-zlspr.
2554         ENDLOOP.
2555         COMMIT WORK.
2556   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
2557
2558       ENDIF.
2559   *------------space to X
2560       IF p_sp2x = 'X'.
2561         LOOP AT ist_bseg INTO wa_bseg.
2562           l_tabix =   sy-tabix .
2563           IF wa_bseg-zlspr =  g_zlspr_sp.
2564             wa_bseg-zlspr =  g_zlspr_x.
2565             MODIFY ist_bseg  FROM  wa_bseg INDEX l_tabix  TRANSPORTING zlspr.
2566           ENDIF.
2567         ENDLOOP.
2568
2569   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
2570   * S/4: BSEG payment block (ZLSPR) via FI_DOCUMENT_CHANGE (FB02); direct write not allowed.
2571   *      MODIFY bseg FROM TABLE ist_bseg.
2572         LOOP AT ist_bseg INTO wa_bseg.
2573           PERFORM zz_s4_bseg_zlspr USING wa_bseg-bukrs wa_bseg-belnr wa_bseg-gjahr wa_bseg-buzei wa_bseg-zlspr.
2574         ENDLOOP.
2575         COMMIT WORK.
2576   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
2577
2578       ENDIF.
2579   *----+003
2580   *------Blank to R
2581
2582
2583       IF p_sp2r = 'X'.
2584         LOOP AT ist_bseg INTO wa_bseg.
2585           l_tabix =   sy-tabix .
2586           IF wa_bseg-zlspr =  g_zlspr_sp.
2587             wa_bseg-zlspr =  g_zlspr_r.
2588             MODIFY ist_bseg  FROM  wa_bseg INDEX l_tabix  TRANSPORTING zlspr.
2589           ENDIF.
2590         ENDLOOP.
2591
2592   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
2593   * S/4: BSEG payment block (ZLSPR) via FI_DOCUMENT_CHANGE (FB02); direct write not allowed.
2594   *      MODIFY  bseg FROM TABLE ist_bseg.
2595         LOOP AT ist_bseg INTO wa_bseg.
2596           PERFORM zz_s4_bseg_zlspr USING wa_bseg-bukrs wa_bseg-belnr wa_bseg-gjahr wa_bseg-buzei wa_bseg-zlspr.
2597         ENDLOOP.
2598         COMMIT WORK.
2599   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
2600
2601         COMMIT WORK.
2602       ENDIF.
2603
2604   **------Blank to S
2605   *
2606   *
2607   *    IF p_sp2s = 'X'.
2608   *      LOOP AT ist_bseg INTO wa_bseg.
2609   *        l_tabix =   sy-tabix .
2610   *        IF wa_bseg-zlspr =  g_zlspr_sp.
2611   *          wa_bseg-zlspr =  g_zlspr_s.
2612   *       MODIFY ist_bseg  FROM  wa_bseg INDEX l_tabix  TRANSPORTING zlspr
2613   *.
2614   *        ENDIF.
2615   *      ENDLOOP.
2616   *
2617   *      MODIFY  bseg FROM TABLE ist_bseg.
2618   *
2619   *      COMMIT WORK.
2620   *    ENDIF.
2621
2622
2623   *-------X  to S  and  Blank TO S
2624       IF p_x2s = 'X'.
2625         LOOP AT ist_bseg INTO wa_bseg.
2626           l_tabix =   sy-tabix .
2627           IF wa_bsid-zlspr =  g_zlspr_x  OR wa_bsid-zlspr =  g_zlspr_sp.
2628             wa_bseg-zlspr =  g_zlspr_s.
2629             MODIFY ist_bseg  FROM  wa_bseg INDEX l_tabix  TRANSPORTING zlspr.
2630           ENDIF.
2631         ENDLOOP.
2632
2633   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
2634   * S/4: BSEG payment block (ZLSPR) via FI_DOCUMENT_CHANGE (FB02); direct write not allowed.
2635   *      MODIFY  bseg FROM TABLE ist_bseg.
2636         LOOP AT ist_bseg INTO wa_bseg.
2637           PERFORM zz_s4_bseg_zlspr USING wa_bseg-bukrs wa_bseg-belnr wa_bseg-gjahr wa_bseg-buzei wa_bseg-zlspr.
2638         ENDLOOP.
2639         COMMIT WORK.
2640   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
2641
2642         COMMIT WORK.
2643       ENDIF.
2644
2645   * Begin of RD1K971966 CAB_ALOK CR30004183
2646   **------------------------S To X
2647   *    IF p_s2x = 'X'.
2648   *      LOOP AT ist_bseg INTO wa_bseg.
2649   *        l_tabix =   sy-tabix .
2650   *        IF wa_bseg-zlspr =  g_zlspr_s.
2651   *          wa_bseg-zlspr =  g_zlspr_x.
2652   *          MODIFY ist_bseg  FROM  wa_bseg INDEX l_tabix  TRANSPORTING zlspr.
2653   *        ENDIF.
2654   *      ENDLOOP.
2655   *
2656   *      MODIFY  bseg FROM TABLE ist_bseg.
2657   *
2658   *      COMMIT WORK.
2659   *    ENDIF.
2660   * end of RD1K971966 CAB_ALOK CR30004183
2661
2662   *------+003
2663     ENDIF.
2664
2665
2666
2667   ENDFORM.                    " print_alv_cust
2668   *&---------------------------------------------------------------------*
2669   *&      Form  sort_build_cust
2670   *&---------------------------------------------------------------------*
2671   *       text
2672   *----------------------------------------------------------------------*
2673   *  -->  p1        text
2674   *  <--  p2        text
2675   *----------------------------------------------------------------------*
2676   FORM sort_build_cust.
2677     w_repid = sy-repid.
2678     is_layout-key_hotspot = 'X'.
2679     is_layout-colwidth_optimize = 'X'.
2680   *begin of <RD1K967585> CAB_ALOK 03.12.2009 CR30002778
2681     is_layout_inactiv-key_hotspot = 'X'.
2682     is_layout_inactiv-colwidth_optimize = 'X'.
2683
2684   *  ls_sorttab-fieldname = 'KIDNO'.
2685   *  ls_sorttab-up = 'X'.
2686   *  APPEND ls_sorttab TO lt_sorttab.
2687   *end of <RD1K967585> CAB_ALOK 03.12.2009 CR30002778
2688     ls_sorttab-fieldname = 'KUNNR'.
2689     ls_sorttab-up = 'X'.
2690     APPEND ls_sorttab TO lt_sorttab.
2691   *begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
2692   *  ls_sorttab-fieldname = 'BSCHL'.
2693   *  ls_sorttab-up = 'X'.
2694   *  APPEND ls_sorttab TO lt_sorttab.
2695   *  ls_sorttab-fieldname = 'BELNR'.
2696   *  ls_sorttab-up = 'X'.
2697   *  APPEND ls_sorttab TO lt_sorttab.
2698   *  ls_sorttab-fieldname = 'BUDAT'.
2699   *  ls_sorttab-up = 'X'.
2700   *  APPEND ls_sorttab TO lt_sorttab.
2701   *end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
2702
2703   ENDFORM.                    " sort_build_cust
2704   *&---------------------------------------------------------------------*
2705   *&      Form  VALIDATE_DOCS
2706   *&---------------------------------------------------------------------*
2707   *       text
2708   *----------------------------------------------------------------------*
2709   *  -->  p1        text
2710   *  <--  p2        text
2711   *----------------------------------------------------------------------*
2712   FORM validate_docs .
2713     DATA : ist_kid LIKE  ist_srcbsik OCCURS 0.
2714     DATA : wa_kid LIKE  ist_srcbsik.
2715     DATA : g_actflag TYPE c.
2716     DATA :l_dmbtr TYPE bseg-dmbtr.
2717     DATA : l_lifnr TYPE bsik-lifnr,
2718            l_kidno TYPE bsik-kidno.
2719     DATA :l_tabix TYPE sy-tabix.
2720
2721   *Begin of <RD1K975843> CAB_ALOK CR 30005441
2722     data: WA_ZFI_C_N_B_CC1    TYPE  ZFI_C_N_B_CC1,
2723           WA_ZFI_C_B_BLOCKPM1 TYPE  ZFI_C_B_BLOCKPM1,
2724           WA_ZFI_C_N_B_CC2    TYPE  ZFI_C_N_B_CC2,
2725           WA_ZFI_C_B_BLOCKPM2 TYPE  ZFI_C_B_BLOCKPM2.
2726     if ist_srcbsik is not INITIAL.
2727   *End of <RD1K975843> CAB_ALOK CR 30005441
2728
2729       IF p_x2sp = 'X'.
2730
2731   *Begin of <RD1K967585> CAB_ALOK 26.11.2009 CR30002778
2732   *** Validate ist_srcbsik for different conditions and move inactive items into ist_srcbsik_inactiv
2733
2734   ** add serial no. to ist_srcbsik
2735         DATA srno TYPE i. "serial no.
2736         srno = 0.
2737         LOOP AT ist_srcbsik INTO wa_srcbsik.
2738           srno = srno + 1.
2739           wa_srcbsik-serial_no = srno.
2740           MODIFY ist_srcbsik FROM wa_srcbsik TRANSPORTING serial_no.
2741         ENDLOOP.
2742   ** save original ist_srcbsik
2743   *ist_srcbsik_orig = ist_srcbsik
2744         ist_srcbsik_orig[] = ist_srcbsik[].
2745   *** Check each line of ist_srcbsik:
2746   ** if Vendor is blocked or deleted or line posting key 26 put the reason and make the line item inactive
2747   *End of <RD1K967585> CAB_ALOK 02.11.2009 CR30002778
2748         SORT ist_srcbsik  BY lifnr kidno.
2749         TYPES :BEGIN OF ty_vend,
2750                  lifnr TYPE lfb1-lifnr,
2751                  bukrs TYPE lfb1-bukrs,
2752                  sperr TYPE lfb1-sperr,
2753                  zahls TYPE lfb1-zahls,
2754                  loevm TYPE lfb1-loevm,
2755   *Begin of <RD1K967585> CAB_ALOK 29.01.2010 CR30002778
2756                  bschl TYPE bsik-bschl,
2757                  rebzg TYPE bsik-rebzg,
2758   *End of <RD1K967585> CAB_ALOK 29.01.2010 CR30002778
2759   *Begin of <RD1K975843> CAB_ALOK CR 30005441
2760                  ZWELS type lfb1-zwels,  "payment method
2761   *End of <RD1K975843> CAB_ALOK CR 30005441
2762                END OF ty_vend.
2763
2764         DATA :ist_vend TYPE TABLE OF ty_vend.
2765         DATA :wa_vend TYPE ty_vend.
2766   *DATA :l_tabix TYPE sy-tabix.
2767   ** 1. For a given vendor, posting blocked or marked deleted for given company code?
2768         SELECT lifnr bukrs sperr zahls loevm
2769           FROM lfb1
2770           INTO CORRESPONDING FIELDS OF TABLE ist_vend
2771           FOR ALL ENTRIES IN ist_srcbsik
2772           WHERE lifnr = ist_srcbsik-lifnr
2773           AND bukrs = ist_srcbsik-bukrs.    " p_bukrs.
2774
2775         CLEAR: wa_srcbsik.
2776         LOOP AT ist_srcbsik INTO wa_srcbsik.
2777           l_tabix = sy-tabix.
2778   *Begin of <RD1K967585> CAB_ALOK 02.11.2009 CR30002778
2779   *      READ TABLE ist_vend INTO wa_vend WITH KEY lifnr = wa_srcbsik-lifnr.
2780           READ TABLE ist_vend INTO wa_vend WITH KEY lifnr = wa_srcbsik-lifnr
2781                                                      bukrs = wa_srcbsik-bukrs  .
2782   *end of <RD1K967585> CAB_ALOK 02.11.2009 CR30002778
2783           IF sy-subrc = 0.
2784             IF wa_vend-sperr = 'X'.
2785               wa_srcbsik-inactiv = 'X'.
2786               wa_srcbsik-reason = 'Posting blocked for company code'.
2787             ELSEIF wa_vend-zahls = 'X'.
2788               wa_srcbsik-inactiv = 'X'.
2789               wa_srcbsik-reason = 'Blocked for Payment'.
2790             ELSEIF wa_vend-loevm = 'X'.
2791               wa_srcbsik-inactiv = 'X'.
2792               wa_srcbsik-reason = 'Marked for Deletion-company code level'.
2793             ENDIF.
2794             MODIFY ist_srcbsik FROM wa_srcbsik INDEX l_tabix TRANSPORTING inactiv reason.
2795           ENDIF.
2796           CLEAR: wa_srcbsik.
2797         ENDLOOP.
2798   *Begin of <RD1K967585> CAB_ALOK 02.11.2009 CR30002778
2799   ** 2. For a given vendor, posting blocked or deleted for all company codes?
2800         REFRESH ist_vend.
2801         SELECT lifnr loevm sperr INTO CORRESPONDING FIELDS OF TABLE ist_vend
2802           FROM lfa1
2803           FOR ALL ENTRIES IN ist_srcbsik
2804           WHERE lifnr = ist_srcbsik-lifnr.  "#EC CI_NOORDER
2805         CLEAR: wa_srcbsik.
2806         LOOP AT ist_srcbsik INTO wa_srcbsik.
2807           l_tabix = sy-tabix.
2808           READ TABLE ist_vend INTO wa_vend WITH KEY lifnr = wa_srcbsik-lifnr.
2809           IF sy-subrc = 0.
2810             IF wa_vend-sperr = 'X'.
2811               wa_srcbsik-inactiv = 'X'.
2812               wa_srcbsik-reason = 'Central Posting block'.
2813             ELSEIF wa_vend-loevm = 'X'.
2814               wa_srcbsik-inactiv = 'X'.
2815               wa_srcbsik-reason = 'Central Deletion flag'.
2816             ENDIF.
2817             MODIFY ist_srcbsik FROM wa_srcbsik INDEX l_tabix TRANSPORTING inactiv reason.
2818           ENDIF.
2819           CLEAR: wa_srcbsik.
2820         ENDLOOP.
2821   *end of <RD1K967585> CAB_ALOK 02.11.2009 CR30002778
2822
2823   ** 3. Validation for posting key '26'
2824   *begin of <RD1K967585> CAB_ALOK 29.01.2010 CR30002778
2825   *     LOOP AT ist_srcbsik INTO wa_srcbsik.
2826   *      l_tabix = sy-tabix.
2827   **     IF sy-subrc = 0.
2828   **     IF wa_srcbsik-rebzg IS INITIAL.
2829   *      IF wa_srcbsik-bschl = '26' AND wa_srcbsik-rebzg IS INITIAL.
2830   *        wa_srcbsik-inactiv = 'X'.
2831   *        wa_srcbsik-reason = 'Inv Ref not upd'.
2832   *        MODIFY ist_srcbsik FROM wa_srcbsik INDEX l_tabix TRANSPORTING inactiv reason.
2833   *      ENDIF.
2834   *    ENDLOOP.
2835
2836   *	If vendor has any open item (BSIK) with Posting key(BSCHL) 26
2837   *    and blank value in Inv reference(REBZG). All line items of this vendor in ist_srcbsik should be inactive with reason.
2838   *  READ TABLE ist_srcbsik INTO wa_srcbsik  WITH KEY bschl = '26'.
2839         REFRESH ist_vend.
2840   *begin of < RD1K970594> CAB_ALOK 9.03.2010 CR30003739
2841   *    SELECT lifnr BSCHL REBZG INTO CORRESPONDING FIELDS OF TABLE ist_vend
2842         SELECT lifnr bukrs bschl rebzg INTO CORRESPONDING FIELDS OF TABLE ist_vend
2843   *end of < RD1K970594> CAB_ALOK 9.03.2010 CR30003739
2844           FROM bsik
2845           FOR ALL ENTRIES IN ist_srcbsik
2846           WHERE lifnr = ist_srcbsik-lifnr
2847           AND  bschl = '26'
2848           AND  rebzg = ''.
2849         CLEAR: wa_srcbsik.
2850         LOOP AT ist_srcbsik INTO wa_srcbsik.
2851           l_tabix = sy-tabix.
2852   *begin of < RD1K970594> CAB_ALOK 9.03.2010 CR30003739
2853   *     READ TABLE ist_vend INTO wa_vend WITH KEY lifnr = wa_srcbsik-lifnr.
2854           READ TABLE ist_vend INTO wa_vend WITH KEY lifnr = wa_srcbsik-lifnr bukrs = wa_srcbsik-bukrs.
2855   *end of < RD1K970594> CAB_ALOK 9.03.2010 CR30003739
2856
2857           IF sy-subrc = 0.
2858             wa_srcbsik-inactiv = 'X'.
2859             wa_srcbsik-reason = 'Inv Ref not upd'.
2860             MODIFY ist_srcbsik FROM wa_srcbsik INDEX l_tabix TRANSPORTING inactiv reason.
2861           ENDIF.
2862           CLEAR: wa_srcbsik.
2863         ENDLOOP.
2864   *end of <RD1K967585> CAB_ALOK 29.01.2010 CR30002778
2865   *4a, 5a moved down.
2866   *begin of <RD1K967585> CAB_ALOK 26.11.2009 CR30002778
2867   *Move inactive lines to ist_srcbsik_inactiv
2868         ist_srcbsik_inactiv[] = ist_srcbsik[].
2869         DELETE ist_srcbsik_inactiv WHERE inactiv <> 'X'. "ist_srcbsik_inactiv contains inactive items
2870         DELETE ist_srcbsik WHERE inactiv = 'X'.  "ist_srcbsik contains active items
2871
2872   ** 5. Validation on linked documents: Match Inv. Ref with Doc No.
2873   * Loop at lines of ist_srcbsik that hav some Inv. Ref.(rebzg )
2874   * Search this Inv Ref in Doc no. (belnr) of other Credit line items ( Credit indicator: shkzg  = 'H')
2875   * if matchig doc is found then
2876   *    temporarily update Pay Ref (kidno) of current line item with the Pay ref of matching Doc (this
2877   *                 will be needed later while sub-totaling on the basis of lifnr+kidno )
2878   *  else
2879   *   make the current line inactive.
2880         LOOP AT ist_srcbsik INTO wa_srcbsik WHERE rebzg IS NOT INITIAL.
2881           READ TABLE ist_srcbsik_orig
2882                      INTO wa_srcbsik_orig
2883                       WITH KEY lifnr = wa_srcbsik-lifnr
2884                                belnr  = wa_srcbsik-rebzg
2885                                shkzg  = 'H' .
2886           IF sy-subrc = 0.
2887             wa_srcbsik-kidno = wa_srcbsik_orig-kidno.
2888             MODIFY ist_srcbsik FROM wa_srcbsik TRANSPORTING kidno.
2889           ELSE.
2890             wa_srcbsik-inactiv = 'X'.
2891             MODIFY ist_srcbsik FROM wa_srcbsik TRANSPORTING inactiv.
2892           ENDIF.
2893         ENDLOOP.
2894
2895   *{30007486
2896         LOOP AT ist_srcbsik INTO wa_srcbsik WHERE rebzg IS NOT INITIAL.
2897           READ TABLE ist_srcbsik_orig
2898                      INTO wa_srcbsik_orig
2899                       WITH KEY lifnr = wa_srcbsik-lifnr
2900                                belnr  = wa_srcbsik-rebzg
2901                                shkzg  = 'H' .
2902           IF sy-subrc = 0.
2903             if wa_srcbsik_orig-bschl <> '39'. "31
2904               if wa_srcbsik_orig-bschl = '31'.
2905                 if ( wa_srcbsik-rebzz <> wa_srcbsik_orig-buzei ).
2906                   wa_srcbsik-inactiv = 'X'.
2907                   wa_srcbsik-reason = 'Incorrect Line Item Reference'.
2908                   MODIFY ist_srcbsik FROM wa_srcbsik INDEX l_tabix TRANSPORTING inactiv reason.
2909                   READ TABLE ist_srcbsik
2910                              INTO wa_srcbsik_l
2911                               WITH KEY lifnr = wa_srcbsik-lifnr
2912                                        belnr  = wa_srcbsik-belnr
2913                                        shkzg  = 'S' .
2914                   wa_srcbsik_l-inactiv = 'X'.
2915                   wa_srcbsik_l-reason = 'Incorrect Line Item Reference'.
2916                   MODIFY ist_srcbsik FROM wa_srcbsik_l TRANSPORTING inactiv reason.
2917                 endif.
2918               else. "39 and not F
2919
2920               endif.
2921             endif.
2922           endif.
2923         ENDLOOP.
2924   *}
2925   * Again move inactive lines to ist_srcbsik_inactiv
2926         LOOP AT ist_srcbsik INTO wa_srcbsik WHERE inactiv = 'X'.
2927           APPEND wa_srcbsik TO ist_srcbsik_inactiv.
2928         ENDLOOP.
2929         DELETE ist_srcbsik WHERE inactiv = 'X'.
2930
2931
2932   ** calculate sub total group by vendor, pay ref (i.e. lifnr, kidno)
2933   *end of <RD1K967585> CAB_ALOK 26.11.2009 CR30002778
2934         SORT ist_srcbsik  BY lifnr kidno rebzg.
2935   *read table ist_srcbsik  index 1 into wa_srcbsik.
2936   *if sy-subrc = 0.
2937   *  l_lifnr = wa_srcbsik-lifnr.
2938   *  l_kidno = wa_srcbsik-kidno.
2939   *endif.
2940         LOOP AT ist_srcbsik INTO wa_srcbsik.
2941           READ TABLE ist_kid INTO wa_kid
2942           WITH KEY lifnr = wa_srcbsik-lifnr
2943                 kidno = wa_srcbsik-kidno.
2944           IF sy-subrc = 0.
2945             l_dmbtr = l_dmbtr + wa_srcbsik-dmbtr .  "update sub total
2946             wa_kid-dmbtr = l_dmbtr.
2947             MODIFY ist_kid FROM wa_kid INDEX sy-tabix "wa_kid-dmbtr holds subtotal for {vendor, pay ref i.e. kidno} tupple.
2948             TRANSPORTING dmbtr.
2949           ELSE.
2950             CLEAR l_dmbtr.
2951             l_dmbtr = wa_srcbsik-dmbtr.
2952             APPEND wa_srcbsik TO ist_kid.
2953           ENDIF.
2954           CLEAR wa_srcbsik.
2955         ENDLOOP.
2956
2957   *begin of <RD1K967585> CAB_ALOK 26.11.2009 CR30002778
2958   ** assign a sub-group no. to each {vendor, pay ref} tupple of ist_kid, which will be subsequently
2959   * moved to {vendor, pay ref} tupple of ist_srcbsik ('ll be used for grouping of data when changed Pay Ref
2960   * have been restored back.
2961         DATA l_subgrp TYPE i.
2962         l_subgrp = 0.
2963         SORT ist_kid BY lifnr kidno rebzg.
2964         LOOP AT ist_kid INTO wa_kid.
2965           l_subgrp = l_subgrp + 1.
2966           wa_kid-subgrp = l_subgrp.
2967           MODIFY ist_kid FROM wa_kid TRANSPORTING subgrp.
2968         ENDLOOP.
2969   *end of <RD1K967585> CAB_ALOK 26.11.2009 CR30002778
2970
2971
2972   *Begin of <RD1K967585> CAB_ALOK 29.10.2009 CR30002778
2973   *loop at ist_kid into wa_kid.
2974   *  read table ist_srcbsik  into  wa_srcbsik
2975   *with key lifnr = wa_kid-lifnr   " Vendor
2976   *          kidno = wa_kid-kidno.   "pay ref.
2977   *if sy-subrc = 0.
2978   *  clear wa_srcbsik.
2979   *  wa_srcbsik-activ = 'X'.
2980   *  wa_srcbsik-lifnr = wa_kid-lifnr.
2981   *  wa_srcbsik-kidno = wa_kid-kidno.
2982   *  wa_srcbsik-reason = 'Subtotal'.
2983   *  wa_srcbsik-dmbtr =   wa_kid-dmbtr.
2984   *  append wA_srcbsik to ist_srcbsik.  "add sub total line item to ist_srcbsik
2985   *endif.
2986   *endloop.
2987
2988   ** update subtotal for all {vendor, pay ref i.e. kidno} tupple in SubTot column of ist_srcbsik,
2989   * note: {vendor, pay ref i.e. kidno} tupple is non-unique in ist_srcbsik
2990   * while it's unique in ist_kid.
2991         LOOP AT ist_srcbsik INTO wa_srcbsik.
2992           READ TABLE ist_kid INTO wa_kid
2993              WITH KEY lifnr = wa_srcbsik-lifnr
2994                       kidno = wa_srcbsik-kidno.
2995           IF sy-subrc = 0.
2996             wa_srcbsik-subtot = wa_kid-dmbtr.
2997             wa_srcbsik-subgrp = wa_kid-subgrp.
2998             IF wa_srcbsik-subtot => 0.   "if subtotal is +ve or zero then this sub-group will be inactive
2999               wa_srcbsik-inactiv = 'X'.
3000               wa_srcbsik-reason = 'Net receivable'.
3001             ENDIF.
3002             MODIFY ist_srcbsik FROM wa_srcbsik TRANSPORTING subtot inactiv subgrp reason.
3003           ENDIF.
3004           CLEAR: wa_srcbsik, wa_kid.
3005         ENDLOOP.
3006
3007   * Restore Pay Ref that were temporarily changed.
3008         SORT ist_srcbsik  BY lifnr kidno rebzg.  " before restoring kidno, sort tables in proper order for future use.
3009         SORT ist_srcbsik_inactiv  BY lifnr kidno rebzg.
3010         LOOP AT ist_srcbsik INTO wa_srcbsik WHERE rebzg IS NOT INITIAL.
3011           READ TABLE ist_srcbsik_orig INTO wa_srcbsik_orig
3012               WITH KEY serial_no = wa_srcbsik-serial_no.
3013           wa_srcbsik-kidno = wa_srcbsik_orig-kidno.
3014           MODIFY ist_srcbsik FROM wa_srcbsik TRANSPORTING kidno.
3015         ENDLOOP.
3016   *end of <RD1K967585> CAB_ALOK 01.12.2009 CR30002778
3017
3018   *Begin of <RD1K975843> CAB_ALOK CR 30005441
3019   ** 6. Warning for Due Date in future.
3020   * In case due date (ZFBDT) is greater than today's date by more than 7 days, give caution in main list.
3021         LOOP AT ist_srcbsik INTO wa_srcbsik .
3022           clear t_days_diff.
3023           t_days_diff = wa_srcbsik-zfbdt - sy-datum .
3024           if t_days_diff > 7.
3025             wa_srcbsik-reason = 'Due Date in future'.
3026             MODIFY ist_srcbsik FROM wa_srcbsik TRANSPORTING reason.
3027           endif.
3028         ENDLOOP.
3029
3030   ** 7. Validation on linked documents: Pymt Method in linked docs should be same
3031         DATA : ist_srcbsik_tmp       LIKE STANDARD TABLE OF ist_srcbsik,
3032                wa_srcbsik_tmp        LIKE line OF ist_srcbsik,
3033                zlsch_inconsistent(1) .
3034
3035         ist_srcbsik_tmp[] = ist_srcbsik[].
3036         sort ist_srcbsik_tmp by subgrp.
3037         delete ADJACENT DUPLICATES FROM ist_srcbsik_tmp comparing subgrp.
3038
3039         clear wa_srcbsik_tmp.
3040         loop at ist_srcbsik_tmp into wa_srcbsik_tmp .
3041           loop at ist_srcbsik into wa_srcbsik where subgrp = wa_srcbsik_tmp-subgrp.
3042             if wa_srcbsik_tmp-zlsch <> wa_srcbsik-zlsch.
3043               zlsch_inconsistent = 'X'. "at-least one mismatch of ZLSCH found, set Flag.
3044             endif.
3045           endloop.
3046           if zlsch_inconsistent = 'X'.
3047             loop at ist_srcbsik into wa_srcbsik where subgrp = wa_srcbsik_tmp-subgrp.
3048               wa_srcbsik-inactiv = 'X'.
3049               wa_srcbsik-reason = 'Inconsistent PM in Docs'.
3050               MODIFY ist_srcbsik FROM wa_srcbsik TRANSPORTING inactiv reason.
3051             endloop.
3052           endif.
3053           clear: zlsch_inconsistent, wa_srcbsik_tmp.
3054         endloop.
3055
3056
3057   *Begin of <RD1K975843> CAB_ALOK CR 30005441
3058   ** 4a.  In case P_BUKRS in table 'ZFI_C_N_B_CC1' (ONGC comp codes) and line-ZLSCH  in table 'ZFI_C_B_BLOCKPM1'
3059   *  check line-ZLSCH same as LFB1-ZWELS where LFB1-LIFNR = S_LIFNR-LOW and LFB1-BUKRS = P_BUKRS.
3060
3061         clear: WA_ZFI_C_N_B_CC1, WA_ZFI_C_B_BLOCKPM1.
3062
3063         select single * from ZFI_C_N_B_CC1
3064           into WA_ZFI_C_N_B_CC1
3065             where BUKRS = P_BUKRS.
3066
3067         if sy-subrc = 0. "comp. code found in table ZFI_C_N_B_CC1
3068
3069           REFRESH ist_vend.
3070           SELECT lifnr bukrs zwels  INTO CORRESPONDING FIELDS OF TABLE ist_vend
3071             FROM lfb1
3072               FOR ALL ENTRIES IN ist_srcbsik
3073                WHERE lifnr = ist_srcbsik-lifnr
3074                AND bukrs = p_bukrs.  "#EC CI_NOORDER
3075           CLEAR: wa_srcbsik.
3076
3077           LOOP AT ist_srcbsik INTO wa_srcbsik.
3078             l_tabix = sy-tabix.
3079
3080             select single * from ZFI_C_B_BLOCKPM1
3081                into WA_ZFI_C_B_BLOCKPM1
3082                  where ZLSCH = wa_srcbsik-zlsch.
3083
3084             if sy-subrc = 0. " paymt method zlsch found in table ZFI_C_B_BLOCKPM1
3085               READ TABLE ist_vend INTO wa_vend WITH KEY lifnr = wa_srcbsik-lifnr
3086                                                           bukrs = wa_srcbsik-bukrs  .
3087
3088               If  wa_srcbsik-zlsch <> wa_vend-zwels.
3089                 wa_srcbsik-inactiv = 'X'.
3090                 wa_srcbsik-reason = 'Diff Pymt Method in vendor master'. " 'Pymt Method Mismatch'.
3091                 MODIFY ist_srcbsik FROM wa_srcbsik INDEX l_tabix TRANSPORTING inactiv reason.
3092               Endif.
3093             endif." /sy-subrc = 0. " paymt method zlsch
3094
3095             CLEAR: wa_srcbsik.
3096           Endloop.
3097
3098         endif. " /sy-subrc = 0. "comp. code
3099
3100   ** 4b. In case P_BUKRS in table 'ZFI_C_N_B_CC2'(OVL comp codes) and line-ZLSCH  in table 'ZFI_C_B_BLOCKPM2',
3101   *  check line-ZLSCH same as LFB1-ZWELS where LFB1-LIFNR = S_LIFNR-LOW and LFB1-BUKRS = P_BUKRS.
3102         clear: WA_ZFI_C_N_B_CC2, WA_ZFI_C_B_BLOCKPM2.
3103
3104         select single * from ZFI_C_N_B_CC2
3105           into WA_ZFI_C_N_B_CC2
3106             where BUKRS = P_BUKRS.
3107
3108         if sy-subrc = 0. "comp. code found in table ZFI_C_N_B_CC2
3109
3110           REFRESH ist_vend.
3111           SELECT lifnr bukrs zwels  INTO CORRESPONDING FIELDS OF TABLE ist_vend
3112             FROM lfb1
3113               FOR ALL ENTRIES IN ist_srcbsik
3114                WHERE lifnr = ist_srcbsik-lifnr
3115                AND bukrs = p_bukrs.  "#EC CI_NOORDER
3116           CLEAR: wa_srcbsik.
3117
3118           LOOP AT ist_srcbsik INTO wa_srcbsik.
3119             l_tabix = sy-tabix.
3120
3121             select single * from ZFI_C_B_BLOCKPM2
3122                into WA_ZFI_C_B_BLOCKPM2
3123                  where ZLSCH = wa_srcbsik-zlsch.
3124
3125             if sy-subrc = 0. " paymt method zlsch found in table ZFI_C_B_BLOCKPM2
3126               READ TABLE ist_vend INTO wa_vend WITH KEY lifnr = wa_srcbsik-lifnr
3127                                                           bukrs = wa_srcbsik-bukrs  .
3128
3129               If  wa_srcbsik-zlsch <> wa_vend-zwels.
3130                 wa_srcbsik-inactiv = 'X'.
3131                 wa_srcbsik-reason = 'Diff Pymt Method in vendor master'.    " 'Pymt Method Mismatch'.
3132                 MODIFY ist_srcbsik FROM wa_srcbsik INDEX l_tabix TRANSPORTING inactiv reason.
3133               Endif.
3134             endif." /sy-subrc = 0. " paymt method zlsch
3135
3136             CLEAR: wa_srcbsik.
3137           Endloop.
3138
3139         endif. " /sy-subrc = 0. "comp. code
3140
3141   *End of <RD1K975843> CAB_ALOK CR 30005441
3142
3143
3144   ** 8. Validation on linked documents:
3145   * Send whole set of linked docs to exception, if
3146   *     a) due date in Rec doc > curr date
3147   *     OR b) due date in Rec doc > liab doc
3148   * above conditions modified:
3149   *     a1) RD > CD > LD
3150   *     OR b1) RD > LD > CD , where CD - Current system date, RD - Due date in Recovery document,
3151   *                              LD - Due date in Liability document
3152
3153         data: due_date_flag(1) .
3154         refresh ist_srcbsik_tmp.
3155         ist_srcbsik_tmp[] = ist_srcbsik[].
3156         sort ist_srcbsik_tmp by subgrp.
3157         delete  ist_srcbsik_tmp where SHKZG <> 'H'.  " store only Liab. docs.
3158   *    delete ADJACENT DUPLICATES FROM ist_srcbsik_tmp comparing subgrp.
3159         clear wa_srcbsik_tmp.
3160         loop at ist_srcbsik_tmp into wa_srcbsik_tmp .   " Liab docs
3161           loop at ist_srcbsik into wa_srcbsik where subgrp = wa_srcbsik_tmp-subgrp and SHKZG = 'S'.  "Recov. Docs of the same sub-grp as Liab doc
3162
3163   *       if ( wa_srcbsik-zfbdt > sy-datum ) or ( wa_srcbsik-zfbdt > wa_srcbsik_tmp-zfbdt ) .
3164             if ( ( wa_srcbsik-zfbdt > sy-datum ) and ( sy-datum > wa_srcbsik_tmp-zfbdt ) )  " modified conditions
3165               or ( ( wa_srcbsik-zfbdt > wa_srcbsik_tmp-zfbdt ) and ( wa_srcbsik_tmp-zfbdt > sy-datum ) ).
3166               due_date_flag = 'X'. "at-least one due date valiadation failed, set Flag.
3167             endif.
3168           endloop.
3169           if due_date_flag = 'X'.
3170             loop at ist_srcbsik into wa_srcbsik where subgrp = wa_srcbsik_tmp-subgrp.
3171               wa_srcbsik-inactiv = 'X'.
3172               wa_srcbsik-reason = 'Due date in future'.
3173               MODIFY ist_srcbsik FROM wa_srcbsik TRANSPORTING inactiv reason.
3174             endloop.
3175           endif.
3176           clear: due_date_flag, wa_srcbsik_tmp.
3177         endloop.
3178   *End of <RD1K975843> CAB_ALOK CR 30005441
3179
3180   * move inactive lines to ist_srcbsik_inactiv
3181         LOOP AT ist_srcbsik INTO wa_srcbsik WHERE inactiv = 'X'.
3182           APPEND wa_srcbsik TO ist_srcbsik_inactiv.
3183         ENDLOOP.
3184         DELETE ist_srcbsik WHERE inactiv = 'X'.
3185
3186       ENDIF.                                                  " p_x2sp
3187     endif. " ist_srcbsik
3188   ENDFORM.                    " VALIDATE_DOCS
3189   *&---------------------------------------------------------------------*
3190   *&      Form  VALIDATE_DOCS_CUST
3191   *&---------------------------------------------------------------------*
3192   *       text
3193   *----------------------------------------------------------------------*
3194   *  -->  p1        text
3195   *  <--  p2        text
3196   *----------------------------------------------------------------------*
3197   FORM validate_docs_cust .
3198   *BEGIN OF <rd1k967585> cab_alok 26.11.2009 cr30002778
3199     DATA : ist_kid LIKE  ist_srcbsid OCCURS 0.
3200   * end of <RD1K967585> CAB_ALOK 26.11.2009 CR30002778
3201     DATA : wa_kid LIKE ist_srcbsid.
3202     DATA : g_actflag TYPE c.
3203     DATA :l_dmbtr TYPE bseg-dmbtr.
3204   *BEGIN OF <rd1k967585> cab_alok 26.11.2009 cr30002778
3205     DATA :l_tabix TYPE sy-tabix.
3206   * end of <RD1K967585> CAB_ALOK 26.11.2009 CR30002778
3207     IF p_x2sp = 'X'.
3208   ** BEGIN OF <rd1k967585> cab_alok 04.12.2009 cr30002778
3209
3210   *  ENDIF.
3211   **----custor blocked ????
3212   *  TYPES :BEGIN OF ty_cust,
3213   *         kunnr TYPE knb1-kunnr ,
3214   *         bukrs TYPE knb1-bukrs,
3215   *         sperr TYPE knb1-sperr,
3216   *         zahls TYPE knb1-zahls,
3217   *         loevm TYPE knb1-loevm,
3218   *         END OF ty_cust.
3219   *
3220   *  DATA :ist_cust TYPE TABLE OF ty_cust.
3221   *  DATA :wa_cust TYPE ty_cust.
3222   *  DATA :l_tabix TYPE sy-tabix.
3223   *
3224   *  SELECT kunnr bukrs sperr zahls loevm  INTO TABLE ist_cust
3225   *    FROM knb1
3226   *    FOR ALL ENTRIES IN ist_srcbsid
3227   *    WHERE kunnr = ist_srcbsid-kunnr
3228   *    AND bukrs = p_bukrs.
3229   *
3230   *  LOOP AT ist_srcbsid INTO wa_srcbsid.
3231   *    l_tabix = sy-tabix.
3232   *    READ TABLE ist_cust INTO wa_cust WITH KEY kunnr = wa_srcbsid-kunnr.
3233   *    IF sy-subrc = 0.
3234   *      IF wa_cust-sperr = 'X'.
3235   *        wa_srcbsid-inactiv = 'X'.
3236   *        wa_srcbsid-reason = 'Posting block for compnay code'.
3237   *      ELSEIF wa_cust-zahls = 'X'.
3238   *        wa_srcbsid-inactiv = 'X'.
3239   *        wa_srcbsid-reason = 'Blocked for Payment'.
3240   *      ELSEIF wa_cust-loevm = 'X'.
3241   *        wa_srcbsid-inactiv = 'X'.
3242   *        wa_srcbsid-reason = 'Marked for Deletion'.
3243   *      ENDIF.
3244   *      MODIFY ist_srcbsid FROM wa_srcbsid INDEX l_tabix TRANSPORTING
3245   *            inactiv reason.
3246   *    ENDIF.
3247   *
3248   *  ENDLOOP.
3249   * =============
3250   *** Validate ist_srcbsid for different conditions and move inactive items into ist_srcbsid_inactiv
3251
3252   ** add serial no. to ist_srcbsid
3253       DATA srno TYPE i. "serial no.
3254       srno = 0.
3255       LOOP AT ist_srcbsid INTO wa_srcbsid.
3256         srno = srno + 1.
3257         wa_srcbsid-serial_no = srno.
3258         MODIFY ist_srcbsid FROM wa_srcbsid TRANSPORTING serial_no.
3259       ENDLOOP.
3260   ** save original ist_srcbsid
3261   *ist_srcbsid_orig = ist_srcbsid
3262       ist_srcbsid_orig[] = ist_srcbsid[].
3263   *** Check each line of ist_srcbsid:
3264   ** if customer is blocked or deleted, put the reason and make the line item inactive
3265
3266       SORT ist_srcbsid  BY kunnr kidno.
3267       TYPES :BEGIN OF ty_cust,
3268   *         kunnr TYPE kna1-kunnr ,  "char 10
3269                kunnr TYPE vcnum-ccnum,                          "char 25
3270                bukrs TYPE knb1-bukrs,
3271                sperr TYPE knb1-sperr,
3272                zahls TYPE knb1-zahls,
3273                loevm TYPE knb1-loevm,
3274                ktokd TYPE kna1-ktokd,     " account grp
3275              END OF ty_cust.
3276
3277       DATA : ist_cust TYPE TABLE OF ty_cust.
3278       DATA : wa_cust TYPE ty_cust.
3279
3280       TYPES :BEGIN OF ty_imprest,
3281                cardno TYPE zfiimprest-cardno,
3282                ackon  TYPE zfiimprest-ackon,
3283              END OF ty_imprest.
3284
3285       DATA : ist_imprest TYPE TABLE OF ty_imprest.
3286       DATA : wa_imprest TYPE ty_imprest.
3287
3288       TYPES :BEGIN OF ty_vcnum,
3289                ccnum TYPE vcnum-ccnum ,   "card no.,  char(25)
3290                datbi TYPE vcnum-datbi ,   " Exp. date
3291              END OF ty_vcnum.
3292
3293       DATA : ist_vcnum TYPE TABLE OF ty_vcnum.
3294       DATA : wa_vcnum TYPE ty_vcnum.
3295
3296       DATA : tmp_kunnr TYPE vcnum-ccnum.   "card no.,  char(25), temp holding.
3297
3298   ** 1. For a given customer, posting blocked or marked deleted for given company code?
3299       SELECT kunnr bukrs sperr zahls loevm  INTO TABLE ist_cust
3300         FROM knb1
3301         FOR ALL ENTRIES IN ist_srcbsid
3302         WHERE kunnr = ist_srcbsid-kunnr
3303         AND bukrs = p_bukrs.
3304   *{ Begin of CR 30007632
3305       data : ist_zfiimprest   type standard table of zfiimprest,
3306              ist_zfiimprest_l type standard table of zfiimprest,
3307              wa_zfiimprest    type zfiimprest.
3308       clear :ist_zfiimprest.
3309       refresh :ist_zfiimprest.
3310       select * from zfiimprest
3311         into corresponding fields of table ist_zfiimprest
3312         FOR ALL ENTRIES IN ist_srcbsid
3313             WHERE cardno = ist_srcbsid-kunnr.  "#EC CI_NOORDER
3314
3315
3316   *}End of CR 30007632
3317       CLEAR: wa_srcbsid.
3318       LOOP AT ist_srcbsid INTO wa_srcbsid.
3319         l_tabix = sy-tabix.
3320   *{ Begin of CR 30007632
3321         if wa_srcbsid-SHKZG = 'H'.
3322           if not ist_zfiimprest[] is initial.
3323             read table ist_zfiimprest into wa_zfiimprest index 1.  "#EC CI_NOORDER
3324             if wa_zfiimprest-reqstat = 'RET'.
3325               wa_srcbsid-inactiv = 'X'.
3326               wa_srcbsid-reason = 'Imprest card with RET status'.
3327             endif.
3328           endif.
3329         endif.
3330   *}End of CR 30007632
3331         data : l_stat(12) type c.
3332         clear l_stat.
3333         if not ist_zfiimprest[] is initial.
3334           loop at ist_zfiimprest into wa_zfiimprest where cardno = wa_srcbsid-kunnr.
3335             append wa_zfiimprest to ist_zfiimprest_l.
3336           endloop.
3337           if wa_srcbsid-shkzg = 'H'.
3338             if not ist_zfiimprest_l[] is initial.
3339   *            sort ist_zfiimprest_l by reqno descending.
3340               sort ist_zfiimprest_l by ACKON descending.
3341               read table ist_zfiimprest_l into wa_zfiimprest index 1.
3342   *{Begin of CR 30014106
3343               if wa_zfiimprest-REQSTAT = 'ACK'.
3344
3345               else.
3346                 wa_srcbsid-inactiv = 'X'.
3347                 concatenate 'Card no' wa_srcbsid-kunnr 'is not acknowledged by the employee in webice' into wa_srcbsid-reason.
3348               endif.
3349   *}End of CR 30014106
3350               if wa_zfiimprest-REQSTAT = 'RET' or wa_zfiimprest-REQSTAT = 'SUR'.
3351                 wa_srcbsid-inactiv = 'X'.
3352                 wa_srcbsid-reason = 'PREPAID CARD'.
3353                 if wa_zfiimprest-REQSTAT = 'RET'.
3354                   l_stat = 'Returned'.
3355                 elseif wa_zfiimprest-REQSTAT = 'SUR'.
3356                   l_stat = 'Surrendered'.
3357                 endif.
3358   *{Begin of CR 30014106
3359   *              concatenate wa_srcbsid-reason text-012 l_stat into wa_srcbsid-reason separated by space.
3360                               wa_srcbsid-reason = 'Recent Prepaid Card'.
3361                 concatenate wa_srcbsid-reason text-014 into wa_srcbsid-reason separated by space.
3362   *}End of CR 30014106
3363               endif.
3364             endif.
3365           endif.
3366         endif.
3367         READ TABLE ist_cust INTO wa_cust WITH KEY kunnr = wa_srcbsid-kunnr
3368                                                    bukrs = wa_srcbsid-bukrs  .
3369         IF sy-subrc = 0.
3370           IF wa_cust-sperr = 'X'.
3371             wa_srcbsid-inactiv = 'X'.
3372             wa_srcbsid-reason = 'Posting blocked for company code'.
3373           ELSEIF wa_cust-zahls = 'X'.
3374             wa_srcbsid-inactiv = 'X'.
3375             wa_srcbsid-reason = 'Blocked for Payment'.
3376           ELSEIF wa_cust-loevm = 'X'.
3377             wa_srcbsid-inactiv = 'X'.
3378             wa_srcbsid-reason = 'Marked for Deletion-company code level'.
3379           ENDIF.
3380           MODIFY ist_srcbsid FROM wa_srcbsid INDEX l_tabix TRANSPORTING inactiv reason.
3381         ENDIF.
3382         CLEAR: wa_srcbsid.
3383       ENDLOOP.
3384
3385   ** 2. For a given customer, posting blocked or deleted for all company codes?
3386       REFRESH ist_cust.
3387       SELECT kunnr loevm sperr INTO CORRESPONDING FIELDS OF TABLE ist_cust
3388         FROM kna1
3389         FOR ALL ENTRIES IN ist_srcbsid
3390         WHERE kunnr = ist_srcbsid-kunnr.  "#EC CI_NOORDER
3391       CLEAR: wa_srcbsid.
3392       LOOP AT ist_srcbsid INTO wa_srcbsid.
3393         l_tabix = sy-tabix.
3394         READ TABLE ist_cust INTO wa_cust WITH KEY kunnr = wa_srcbsid-kunnr.
3395         IF sy-subrc = 0.
3396           IF wa_cust-sperr = 'X'.
3397             wa_srcbsid-inactiv = 'X'.
3398             wa_srcbsid-reason = 'Central Posting blocked'.
3399           ELSEIF wa_cust-loevm = 'X'.
3400             wa_srcbsid-inactiv = 'X'.
3401             wa_srcbsid-reason = 'Central Deletion Flag'.
3402           ENDIF.
3403           MODIFY ist_srcbsid FROM wa_srcbsid INDEX l_tabix TRANSPORTING inactiv reason.
3404         ENDIF.
3405         CLEAR: wa_srcbsid.
3406       ENDLOOP.
3407
3408   ** 3. card customer? old logic: found in ZFIIMPREST table? if date ZFIIMPREST-ACKON = 00000000 => not acknowledged? => exception
3409   **  Revised logic for card customer
3410   *a. get Customer number with account group as IMPR
3411   *b. Concatenate 421687 to the customer number to get the card number
3412   *c. Search this card number in table VCNUM for record where Exp date is not blank and is greater than system date
3413   *d. All such sucessful lines shud be put in active list else in exception list
3414   ******** BOOK MARK
3415       SELECT kunnr ktokd INTO CORRESPONDING FIELDS OF TABLE ist_cust " select all card customers of ist_srcbsid
3416             FROM kna1                                                 " into ist_cust. (condition: corresponding  a/c grp KNA1-ktokd shud be 'IMPR'
3417             FOR ALL ENTRIES IN ist_srcbsid
3418             WHERE kunnr = ist_srcbsid-kunnr
3419                   AND ktokd = 'IMPR'.
3420
3421   *SELECT cardno ackon INTO CORRESPONDING FIELDS OF TABLE ist_imprest "  for all card customers (ist_cust)
3422   *      FROM zfiimprest                                                 " select data (Card No. i.e. kunnr & ACK Date) from ZFIIMPREST into ist_imprest.
3423   *      FOR ALL ENTRIES IN ist_cust
3424   *      WHERE cardno = ist_cust-kunnr.
3425   ***            and ackon <> ''.
3426
3427       LOOP AT ist_cust INTO wa_cust.
3428         l_tabix = sy-tabix.
3429         CONCATENATE '421687' wa_cust-kunnr INTO wa_cust-kunnr.
3430         MODIFY ist_cust FROM wa_cust INDEX l_tabix TRANSPORTING kunnr.
3431       ENDLOOP.
3432
3433       SELECT ccnum datbi INTO CORRESPONDING FIELDS OF TABLE ist_vcnum "  for all card customers (ist_cust)
3434             FROM vcnum
3435             FOR ALL ENTRIES IN ist_cust
3436             WHERE ccnum = ist_cust-kunnr.
3437
3438   *SORT ist_imprest BY cardno ASCENDING.
3439   *   DELETE ADJACENT DUPLICATES FROM ist_imprest COMPARING cardno.
3440
3441   *    CLEAR: wa_srcbsid.
3442   *    LOOP AT ist_srcbsid INTO wa_srcbsid.
3443   *      l_tabix = sy-tabix.
3444   *      READ TABLE ist_cust INTO wa_cust WITH KEY kunnr = wa_srcbsid-kunnr .
3445   *       IF sy-subrc = 0. " => kunnr is a card-customer. Now check whether it exists in ZFIIMPREST or not
3446   *         READ TABLE ist_imprest into wa_imprest with key cardno = wa_srcbsid-kunnr.
3447   *           if sy-subrc = 0. " => cardno found in ZFIIMPREST, now we need to check its ACKON
3448   *              if wa_imprest-ackon = 0.    "if ACKON date = 00000000, corresponding ist_srcbsid line shud be inactive
3449   *                  wa_srcbsid-inactiv = 'X'.
3450   *                  wa_srcbsid-reason = 'Card customer, no ACK'.
3451   *              endif.
3452   *           else.  "cardno not found in ZFIIMPREST, corresponding ist_srcbsid line shud be inactive.
3453   *             wa_srcbsid-inactiv = 'X'.
3454   *             wa_srcbsid-reason = 'Card customer, not in ZFIIMPREST'.
3455   *           endif.
3456   *           MODIFY ist_srcbsid FROM wa_srcbsid INDEX l_tabix TRANSPORTING inactiv reason.
3457   *       endif.
3458   *
3459   *    ENDLOOP.
3460
3461       CLEAR: wa_srcbsid.
3462       LOOP AT ist_srcbsid INTO wa_srcbsid.
3463         l_tabix = sy-tabix.
3464         CONCATENATE '421687' wa_srcbsid-kunnr INTO tmp_kunnr.
3465         READ TABLE ist_cust INTO wa_cust WITH KEY kunnr = tmp_kunnr .
3466         IF sy-subrc = 0. " => kunnr is a card-customer. Now check whether it exists in ZFIIMPREST or not
3467           READ TABLE ist_vcnum INTO wa_vcnum WITH KEY ccnum = tmp_kunnr.
3468           IF sy-subrc = 0. " => cardno found in VCNUM, now we need to check its Expiry Date (DATBI)
3469             IF wa_vcnum-datbi < sy-datum.    "if EXP date < current date, corresponding ist_srcbsid line shud be inactive
3470               wa_srcbsid-inactiv = 'X'.
3471               wa_srcbsid-reason = 'Card customer, curr date>Exp date '.
3472             ENDIF.
3473           ELSE.  "cardno not found in VCNUM, corresponding ist_srcbsid line shud be inactive.
3474             wa_srcbsid-inactiv = 'X'.
3475             wa_srcbsid-reason = 'Card customer, not in VCNUM'.
3476           ENDIF.
3477           MODIFY ist_srcbsid FROM wa_srcbsid INDEX l_tabix TRANSPORTING inactiv reason.
3478         ENDIF.
3479
3480       ENDLOOP.
3481
3482   *begin of <RD1K967585> CAB_ALOK 01.12.2009 CR30002778
3483   *Move inactive lines to ist_srcbsid_inactiv
3484       ist_srcbsid_inactiv[] = ist_srcbsid[].
3485       DELETE ist_srcbsid_inactiv WHERE inactiv <> 'X'. "ist_srcbsid_inactiv contains inactive items
3486       DELETE ist_srcbsid WHERE inactiv = 'X'.  "ist_srcbsid contains active items
3487   *end of <RD1K967585> CAB_ALOK 01.12.2009 CR30002778
3488
3489     ENDIF. "p_x2sp = 'X
3490   ** end OF <rd1k967585> cab_alok 04.12.2009 cr30002778
3491   ENDFORM.                    " VALIDATE_DOCS_CUST
3492   *&---------------------------------------------------------------------*
3493   *&      Form  INIT_FIELDCAT_INACTIV
3494   *&---------------------------------------------------------------------*
3495   *       text
3496   *----------------------------------------------------------------------*
3497   *  -->  p1        text
3498   *  <--  p2        text
3499   *----------------------------------------------------------------------*
3500   *begin of <RD1K967585> CAB_ALOK 26.11.2009 CR30002778
3501   FORM init_fieldcat_inactiv .
3502     w_repid  = sy-repid.
3503     mpos = 0.
3504
3505     mpos = mpos + 1.
3506     ist_fieldcat_inactiv-fieldname = 'SELCBOX'.
3507     ist_fieldcat_inactiv-tabname = 'IST_SRCBSIK_INACTIV'.
3508     ist_fieldcat_inactiv-ddictxt = 'M'.
3509     ist_fieldcat_inactiv-col_pos =  mpos.
3510     ist_fieldcat_inactiv-seltext_m  = 'Inactiv'.
3511     ist_fieldcat_inactiv-lowercase  = 'Y'.
3512     ist_fieldcat_inactiv-checkbox = 'X'.
3513   *  ist_fieldcat_inactiv-input = 'X'.  " no input allowed.
3514   *  ist_fieldcat_inactiv-edit = 'X'.
3515     APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3516     CLEAR ist_fieldcat_inactiv.
3517
3518     mpos = mpos + 1.
3519     ist_fieldcat_inactiv-fieldname = 'LIFNR'.
3520     ist_fieldcat_inactiv-tabname = 'IST_SRCBSIK_INACTIV'.
3521     ist_fieldcat_inactiv-ddictxt = 'M'.
3522     ist_fieldcat_inactiv-col_pos =  mpos.
3523   *begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
3524   *  ist_fieldcat_inactiv-seltext_m  = 'VendorNumber'.
3525     ist_fieldcat_inactiv-seltext_m  = 'Vendor No.'.
3526   *end of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
3527     ist_fieldcat_inactiv-lowercase  = 'Y'.
3528     APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3529     CLEAR ist_fieldcat_inactiv.
3530
3531     mpos = mpos + 1.
3532     ist_fieldcat_inactiv-fieldname = 'BELNR'.
3533     ist_fieldcat_inactiv-tabname = 'IST_SRCBSIK_INACTIV'.
3534     ist_fieldcat_inactiv-ddictxt = 'M'.
3535     ist_fieldcat_inactiv-col_pos =  mpos.
3536     ist_fieldcat_inactiv-seltext_m  = 'Doc.No.'.
3537     ist_fieldcat_inactiv-lowercase  = 'Y'.
3538     APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3539     CLEAR ist_fieldcat_inactiv.
3540
3541   *begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
3542   *  mpos = mpos + 1.
3543   *  ist_fieldcat_inactiv-fieldname = 'GSBER'.
3544   *  ist_fieldcat_inactiv-tabname = 'IST_SRCBSIK_INACTIV'.
3545   *  ist_fieldcat_inactiv-ddictxt = 'M'.
3546   *  ist_fieldcat_inactiv-col_pos =  mpos.
3547   *  ist_fieldcat_inactiv-seltext_m  = 'Business Area'.
3548   *  ist_fieldcat_inactiv-lowercase  = 'Y'.
3549   *  APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3550   *  CLEAR ist_fieldcat_inactiv.
3551   *end of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
3552
3553     mpos = mpos + 1.
3554     ist_fieldcat_inactiv-fieldname = 'KIDNO'.
3555     ist_fieldcat_inactiv-tabname = 'IST_SRCBSIK_INACTIV'.
3556     ist_fieldcat_inactiv-ddictxt = 'M'.
3557     ist_fieldcat_inactiv-col_pos =  mpos.
3558   *begin of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
3559   *  ist_fieldcat_inactiv-seltext_m  = 'Payment Reference'.
3560     ist_fieldcat_inactiv-seltext_m  = 'Pymt Ref'.
3561   *end of <RD1K967585> CAB_ALOK 23.12.2009 CR30002778
3562     ist_fieldcat_inactiv-lowercase  = 'Y'.
3563     APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3564     CLEAR ist_fieldcat_inactiv.
3565
3566     mpos = mpos + 1.
3567     ist_fieldcat_inactiv-fieldname = 'REASON'.
3568     ist_fieldcat_inactiv-tabname = 'IST_SRCBSIK_INACTIV'.
3569     ist_fieldcat_inactiv-ddictxt = 'M'.
3570     ist_fieldcat_inactiv-col_pos =  mpos.
3571     ist_fieldcat_inactiv-seltext_m  = 'Reason'.
3572   *  ist_fieldcat_inactiv-lowercase  = 'Y'.
3573     APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3574     CLEAR ist_fieldcat_inactiv.
3575
3576     mpos = mpos + 1.
3577     ist_fieldcat_inactiv-fieldname = 'REBZG'.
3578     ist_fieldcat_inactiv-tabname = 'IST_SRCBSIK_INACTIV'.
3579     ist_fieldcat_inactiv-ddictxt = 'M'.
3580     ist_fieldcat_inactiv-col_pos =  mpos.
3581   *begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
3582   *    ist_fieldcat_inactiv-seltext_m  = 'Invoice Reference'.
3583     ist_fieldcat_inactiv-seltext_m  = 'Inv Ref'.
3584   *end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
3585   *  ist_fieldcat_inactiv-lowercase  = 'Y'.
3586     APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3587     CLEAR ist_fieldcat_inactiv.
3588
3589   *begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
3590   *  mpos = mpos + 1.
3591   *  ist_fieldcat_inactiv-fieldname = 'SHKZG'.
3592   *  ist_fieldcat_inactiv-tabname = 'IST_SRCBSIK_INACTIV'.
3593   *  ist_fieldcat_inactiv-ddictxt = 'M'.
3594   *  ist_fieldcat_inactiv-col_pos =  mpos.
3595   *  ist_fieldcat_inactiv-seltext_m  = 'Indicator'.
3596   **  ist_fieldcat_inactiv-lowercase  = 'Y'.
3597   *  APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3598   *  CLEAR ist_fieldcat_inactiv.
3599   *  mpos = mpos + 1.
3600   *  ist_fieldcat_inactiv-fieldname = 'GJAHR'.
3601   *  ist_fieldcat_inactiv-tabname = 'IST_SRCBSIK_INACTIV'.
3602   *  ist_fieldcat_inactiv-ddictxt = 'M'.
3603   *  ist_fieldcat_inactiv-col_pos =  mpos.
3604   *  ist_fieldcat_inactiv-seltext_m  = 'Year'.
3605   *  ist_fieldcat_inactiv-lowercase  = 'Y'.
3606   *  APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3607   *  CLEAR ist_fieldcat_inactiv.
3608   *end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
3609
3610     mpos = mpos + 1.
3611     ist_fieldcat_inactiv-fieldname = 'BUZEI'.
3612     ist_fieldcat_inactiv-tabname = 'IST_SRCBSIK_INACTIV'.
3613     ist_fieldcat_inactiv-ddictxt = 'M'.
3614     ist_fieldcat_inactiv-col_pos =  mpos.
3615     ist_fieldcat_inactiv-seltext_m  = 'Item.no.'.
3616     ist_fieldcat_inactiv-lowercase  = 'Y'.
3617     APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3618     CLEAR ist_fieldcat_inactiv.
3619
3620     mpos = mpos + 1.
3621     ist_fieldcat_inactiv-fieldname = 'BSCHL'.
3622     ist_fieldcat_inactiv-tabname = 'IST_SRCBSIK_INACTIV'.
3623     ist_fieldcat_inactiv-ddictxt = 'M'.
3624     ist_fieldcat_inactiv-col_pos =  mpos.
3625   *begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
3626   *  ist_fieldcat_inactiv-seltext_m  = 'Posting Key.'.
3627     ist_fieldcat_inactiv-seltext_m  = 'PK'.
3628   *end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
3629     ist_fieldcat_inactiv-lowercase  = 'Y'.
3630     APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3631     CLEAR ist_fieldcat_inactiv.
3632
3633     mpos = mpos + 1.
3634     ist_fieldcat_inactiv-fieldname = 'BUDAT'.
3635     ist_fieldcat_inactiv-tabname = 'IST_SRCBSIK_INACTIV'.
3636     ist_fieldcat_inactiv-ddictxt = 'M'.
3637     ist_fieldcat_inactiv-col_pos =  mpos.
3638   *begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
3639   *  ist_fieldcat_inactiv-seltext_m  = 'Posting Date'.
3640     ist_fieldcat_inactiv-seltext_m  = 'Post Dt'.
3641   *end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
3642     ist_fieldcat_inactiv-lowercase  = 'Y'.
3643     APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3644     CLEAR ist_fieldcat_inactiv.
3645
3646   * begin RD1K975843 CAB_ALOK CR 30005441
3647     mpos = mpos + 1.
3648     ist_fieldcat_inactiv-fieldname = 'ZFBDT'.
3649     ist_fieldcat_inactiv-tabname = 'IST_SRCBSIK_INACTIV'.
3650     ist_fieldcat_inactiv-ddictxt = 'M'.
3651     ist_fieldcat_inactiv-col_pos =  mpos.
3652     ist_fieldcat_inactiv-seltext_m  = 'Due Dt.'.
3653     ist_fieldcat_inactiv-lowercase  = 'Y'.
3654     APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3655     CLEAR ist_fieldcat_inactiv.
3656   * end RD1K975843 CAB_ALOK CR 30005441
3657
3658   *begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
3659   *  mpos = mpos + 1.
3660   *  ist_fieldcat_inactiv-fieldname = 'DMBTR'.
3661   *  ist_fieldcat_inactiv-tabname = 'IST_SRCBSIK_INACTIV'.
3662   *  ist_fieldcat_inactiv-ddictxt = 'M'.
3663   *  ist_fieldcat_inactiv-col_pos =  mpos.
3664   *  ist_fieldcat_inactiv-seltext_m  = 'AmtInLclCurncy'.
3665   *  ist_fieldcat_inactiv-lowercase  = 'Y'.
3666   *  APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3667   *  CLEAR ist_fieldcat_inactiv.
3668   *end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
3669
3670     mpos = mpos + 1.
3671     ist_fieldcat_inactiv-fieldname = 'SUBTOT'.
3672     ist_fieldcat_inactiv-tabname = 'IST_SRCBSIK_INACTIV'.
3673     ist_fieldcat_inactiv-ddictxt = 'M'.
3674     ist_fieldcat_inactiv-col_pos =  mpos.
3675     ist_fieldcat_inactiv-seltext_m  = 'SubTotal'.
3676     ist_fieldcat_inactiv-lowercase  = 'Y'.
3677     APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3678     CLEAR ist_fieldcat_inactiv.
3679
3680     mpos = mpos + 1.
3681     ist_fieldcat_inactiv-fieldname = 'WRBTR'.
3682     ist_fieldcat_inactiv-tabname = 'IST_SRCBSIK_INACTIV'.
3683     ist_fieldcat_inactiv-ddictxt = 'M'.
3684     ist_fieldcat_inactiv-col_pos =  mpos.
3685   *begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
3686   *  ist_fieldcat_inactiv-seltext_m  = 'AmtInDocCurncy'.
3687     ist_fieldcat_inactiv-seltext_m  = 'Amt In Doc Cur'.
3688   *end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
3689     ist_fieldcat_inactiv-lowercase  = 'Y'.
3690     APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3691     CLEAR ist_fieldcat_inactiv.
3692
3693   * begin of < RD1K970594> CAB_ALOK 10.03.2010 CR30003739
3694     mpos = mpos + 1.
3695     ist_fieldcat_inactiv-fieldname = 'WAERS'.
3696     ist_fieldcat_inactiv-tabname = 'IST_SRCBSIK_INACTIV'.
3697     ist_fieldcat_inactiv-ddictxt = 'M'.
3698     ist_fieldcat_inactiv-col_pos =  mpos.
3699     ist_fieldcat_inactiv-seltext_m  = 'Curr'.
3700     ist_fieldcat_inactiv-lowercase  = 'Y'.
3701     APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3702     CLEAR ist_fieldcat_inactiv.
3703   * end of < RD1K970594> CAB_ALOK 10.03.2010 CR30003739
3704
3705     mpos = mpos + 1.
3706     ist_fieldcat_inactiv-fieldname = 'ZLSCH'.
3707     ist_fieldcat_inactiv-tabname = 'IST_SRCBSIK_INACTIV'.
3708     ist_fieldcat_inactiv-ddictxt = 'M'.
3709     ist_fieldcat_inactiv-col_pos =  mpos.
3710   *begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
3711   *  ist_fieldcat_inactiv-seltext_m  = 'PaymntMethod'.
3712     ist_fieldcat_inactiv-seltext_m  = 'PM'.
3713   *end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
3714     ist_fieldcat_inactiv-lowercase  = 'Y'.
3715     APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3716     CLEAR ist_fieldcat_inactiv.
3717
3718     mpos = mpos + 1.
3719     ist_fieldcat_inactiv-fieldname = 'ZLSPR'.
3720     ist_fieldcat_inactiv-tabname = 'IST_SRCBSIK_INACTIV'.
3721     ist_fieldcat_inactiv-ddictxt = 'M'.
3722     ist_fieldcat_inactiv-col_pos =  mpos.
3723   *begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
3724   *  ist_fieldcat_inactiv-seltext_m  = 'PaymntBlock'.
3725     ist_fieldcat_inactiv-seltext_m  = 'PB'.
3726   *end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
3727     ist_fieldcat_inactiv-lowercase  = 'Y'.
3728     APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3729     CLEAR ist_fieldcat_inactiv.
3730
3731     mpos = mpos + 1.
3732     ist_fieldcat_inactiv-fieldname = 'XREF1_HD'.
3733     ist_fieldcat_inactiv-tabname = 'IST_SRCBSIK_INACTIV'.
3734     ist_fieldcat_inactiv-ddictxt = 'M'.
3735     ist_fieldcat_inactiv-col_pos =  mpos.
3736   *begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
3737   *  ist_fieldcat_inactiv-seltext_m  = 'Location'.
3738     ist_fieldcat_inactiv-seltext_m  = 'Loc'.
3739   *end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
3740     ist_fieldcat_inactiv-lowercase  = 'Y'.
3741     APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3742     CLEAR ist_fieldcat_inactiv.
3743
3744   *begin of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
3745   * IF NOT s_usnam IS INITIAL.
3746   *    mpos = mpos + 1.
3747   *    ist_fieldcat_inactiv-fieldname = 'USNAM'.
3748   *    ist_fieldcat_inactiv-tabname = 'IST_SRCBSIK_INACTIV'.
3749   *    ist_fieldcat_inactiv-ddictxt = 'M'.
3750   *    ist_fieldcat_inactiv-col_pos =  mpos.
3751   *    ist_fieldcat_inactiv-seltext_m  = 'Created By'.
3752   *    ist_fieldcat_inactiv-lowercase  = 'Y'.
3753   *    APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3754   *    CLEAR ist_fieldcat_inactiv.
3755   *  ENDIF.
3756   *end of <RD1K967585> CAB_ALOK 28.12.2009 CR30002778
3757
3758
3759
3760   ENDFORM.                    " INIT_FIELDCAT_INACTIV
3761   *end of <RD1K967585> CAB_ALOK 26.11.2009 CR30002778
3762   *&---------------------------------------------------------------------*
3763   *&      Form  DISPLAY_INACTIVE_ALV
3764   *&---------------------------------------------------------------------*
3765   *       text
3766   *----------------------------------------------------------------------*
3767   *  -->  p1        text
3768   *  <--  p2        text
3769   *----------------------------------------------------------------------*
3770   *Begin of <RD1K967585> CAB_ALOK 03.12.2009 CR30002778
3771   FORM display_inactive_alv .    "inactive ALV of Vendors
3772     CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
3773       EXPORTING
3774         i_callback_program = w_repid
3775   *     i_callback_pf_status_set = 'ALV_PFST'
3776   *     i_callback_user_command  = 'MAKE_COMMAND'
3777         is_layout          = is_layout_inactiv
3778         it_fieldcat        = ist_fcat_inactiv
3779         it_sort            = lt_sorttab
3780         it_events          = gt_events_inactiv
3781         i_save             = 'A'
3782       TABLES
3783         t_outtab           = ist_srcbsik_inactiv
3784   * Begin of Changes on 20-Jun-2013
3785       EXCEPTIONS
3786         PROGRAM_ERROR      = 1
3787         OTHERS             = 2.
3788   * End of Changes on 20-Jun-2013
3789     IF sy-subrc <> 0.
3790   *    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
3791   *            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
3792     ENDIF.
3793   ENDFORM.                    " DISPLAY_INACTIVE_ALV
3794   *End of <RD1K967585> CAB_ALOK 03.12.2009 CR30002778
3795   *&---------------------------------------------------------------------*
3796   *&      Form  INIT_FIELDCAT_INACTIV_CUST
3797   *&---------------------------------------------------------------------*
3798   *       text
3799   *----------------------------------------------------------------------*
3800   *  -->  p1        text
3801   *  <--  p2        text
3802   *----------------------------------------------------------------------*
3803   *Begin of <RD1K967585> CAB_ALOK 03.12.2009 CR30002778
3804   FORM init_fieldcat_inactiv_cust .
3805
3806     w_repid  = sy-repid.
3807     mpos = 0.
3808
3809     mpos = mpos + 1.
3810     ist_fieldcat_inactiv-fieldname = 'SELCBOX'.
3811     ist_fieldcat_inactiv-tabname = 'IST_SRCBSID_INACTIV'.
3812     ist_fieldcat_inactiv-ddictxt = 'M'.
3813     ist_fieldcat_inactiv-col_pos =  mpos.
3814     ist_fieldcat_inactiv-seltext_m  = 'Select'.
3815     ist_fieldcat_inactiv-lowercase  = 'Y'.
3816     ist_fieldcat_inactiv-checkbox = 'X'.
3817   *  ist_fieldcat_inactiv-input = 'X'.
3818     APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3819     CLEAR ist_fieldcat_inactiv.
3820
3821     mpos = mpos + 1.
3822     ist_fieldcat_inactiv-fieldname = 'KUNNR'.
3823     ist_fieldcat_inactiv-tabname = 'IST_SRCBSID_INACTIV'.
3824     ist_fieldcat_inactiv-ddictxt = 'M'.
3825     ist_fieldcat_inactiv-col_pos =  mpos.
3826     ist_fieldcat_inactiv-seltext_m  = 'Cstmr No.'.
3827     ist_fieldcat_inactiv-lowercase  = 'Y'.
3828     APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3829     CLEAR ist_fieldcat_inactiv.
3830
3831     mpos = mpos + 1.
3832     ist_fieldcat_inactiv-fieldname = 'BELNR'.
3833     ist_fieldcat_inactiv-tabname = 'IST_SRCBSID_INACTIV'.
3834     ist_fieldcat_inactiv-ddictxt = 'M'.
3835     ist_fieldcat_inactiv-col_pos =  mpos.
3836     ist_fieldcat_inactiv-seltext_m  = 'Doc.No.'.
3837     ist_fieldcat_inactiv-lowercase  = 'Y'.
3838     APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3839     CLEAR ist_fieldcat_inactiv.
3840
3841   *  mpos = mpos + 1.
3842   *  ist_fieldcat_inactiv-fieldname = 'GSBER'.
3843   *  ist_fieldcat_inactiv-tabname = 'IST_SRCBSID_INACTIV'.
3844   *  ist_fieldcat_inactiv-ddictxt = 'M'.
3845   *  ist_fieldcat_inactiv-col_pos =  mpos.
3846   *  ist_fieldcat_inactiv-seltext_m  = 'Business Area'.
3847   *  ist_fieldcat_inactiv-lowercase  = 'Y'.
3848   *  APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3849   *  CLEAR ist_fieldcat_inactiv.
3850
3851     mpos = mpos + 1.
3852     ist_fieldcat_inactiv-fieldname = 'KIDNO'.
3853     ist_fieldcat_inactiv-tabname = 'IST_SRCBSID_INACTIV'.
3854     ist_fieldcat_inactiv-ddictxt = 'M'.
3855     ist_fieldcat_inactiv-col_pos =  mpos.
3856     ist_fieldcat_inactiv-seltext_m  = 'Pymt Ref'.
3857     ist_fieldcat_inactiv-lowercase  = 'Y'.
3858     APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3859     CLEAR ist_fieldcat_inactiv.
3860
3861     mpos = mpos + 1.
3862     ist_fieldcat_inactiv-fieldname = 'REASON'.
3863     ist_fieldcat_inactiv-tabname = 'IST_SRCBSID_INACTIV'.
3864     ist_fieldcat_inactiv-ddictxt = 'M'.
3865     ist_fieldcat_inactiv-col_pos =  mpos.
3866     ist_fieldcat_inactiv-seltext_m  = 'Reason'.
3867   *  ist_fieldcat_inactiv-lowercase  = 'Y'.
3868     APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3869     CLEAR ist_fieldcat_inactiv.
3870
3871     mpos = mpos + 1.
3872     ist_fieldcat_inactiv-fieldname = 'REBZG'.
3873     ist_fieldcat_inactiv-tabname = 'IST_SRCBSID_INACTIV'.
3874     ist_fieldcat_inactiv-ddictxt = 'M'.
3875     ist_fieldcat_inactiv-col_pos =  mpos.
3876     ist_fieldcat_inactiv-seltext_m  = 'Inv Ref'.
3877   *  ist_fieldcat_inactiv-lowercase  = 'Y'.
3878     APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3879     CLEAR ist_fieldcat_inactiv.
3880
3881   *  mpos = mpos + 1.
3882   *  ist_fieldcat_inactiv-fieldname = 'SHKZG'.
3883   *  ist_fieldcat_inactiv-tabname = 'IST_SRCBSID_INACTIV'.
3884   *  ist_fieldcat_inactiv-ddictxt = 'M'.
3885   *  ist_fieldcat_inactiv-col_pos =  mpos.
3886   *  ist_fieldcat_inactiv-seltext_m  = 'INdicator'.
3887   **  ist_fieldcat_inactiv-lowercase  = 'Y'.
3888   *  APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3889   *  CLEAR ist_fieldcat_inactiv.
3890   *
3891   *  mpos = mpos + 1.
3892   *  ist_fieldcat_inactiv-fieldname = 'GJAHR'.
3893   *  ist_fieldcat_inactiv-tabname = 'IST_SRCBSID_INACTIV'.
3894   *  ist_fieldcat_inactiv-ddictxt = 'M'.
3895   *  ist_fieldcat_inactiv-col_pos =  mpos.
3896   *  ist_fieldcat_inactiv-seltext_m  = 'Year'.
3897   *  ist_fieldcat_inactiv-lowercase  = 'Y'.
3898   *  APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3899   *  CLEAR ist_fieldcat_inactiv.
3900
3901     mpos = mpos + 1.
3902     ist_fieldcat_inactiv-fieldname = 'BUZEI'.
3903     ist_fieldcat_inactiv-tabname = 'IST_SRCBSID_INACTIV'.
3904     ist_fieldcat_inactiv-ddictxt = 'M'.
3905     ist_fieldcat_inactiv-col_pos =  mpos.
3906     ist_fieldcat_inactiv-seltext_m  = 'Item.no.'.
3907     ist_fieldcat_inactiv-lowercase  = 'Y'.
3908     APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3909     CLEAR ist_fieldcat_inactiv.
3910
3911     mpos = mpos + 1.
3912     ist_fieldcat_inactiv-fieldname = 'BSCHL'.
3913     ist_fieldcat_inactiv-tabname = 'IST_SRCBSID_INACTIV'.
3914     ist_fieldcat_inactiv-ddictxt = 'M'.
3915     ist_fieldcat_inactiv-col_pos =  mpos.
3916     ist_fieldcat_inactiv-seltext_m  = 'PK'.
3917     ist_fieldcat_inactiv-lowercase  = 'Y'.
3918     APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3919     CLEAR ist_fieldcat_inactiv.
3920
3921     mpos = mpos + 1.
3922     ist_fieldcat_inactiv-fieldname = 'BUDAT'.
3923     ist_fieldcat_inactiv-tabname = 'IST_SRCBSID_INACTIV'.
3924     ist_fieldcat_inactiv-ddictxt = 'M'.
3925     ist_fieldcat_inactiv-col_pos =  mpos.
3926     ist_fieldcat_inactiv-seltext_m  = 'Post Dt'.
3927     ist_fieldcat_inactiv-lowercase  = 'Y'.
3928     APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3929     CLEAR ist_fieldcat_inactiv.
3930
3931   *  mpos = mpos + 1.
3932   *  ist_fieldcat_inactiv-fieldname = 'DMBTR'.
3933   *  ist_fieldcat_inactiv-tabname = 'IST_SRCBSID_INACTIV'.
3934   *  ist_fieldcat_inactiv-ddictxt = 'M'.
3935   *  ist_fieldcat_inactiv-col_pos =  mpos.
3936   *  ist_fieldcat_inactiv-seltext_m  = 'AmtInLclCurncy'.
3937   *  ist_fieldcat_inactiv-lowercase  = 'Y'.
3938   *  APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3939   *  CLEAR ist_fieldcat_inactiv.
3940
3941     mpos = mpos + 1.
3942     ist_fieldcat_inactiv-fieldname = 'WRBTR'.
3943     ist_fieldcat_inactiv-tabname = 'IST_SRCBSID_INACTIV'.
3944     ist_fieldcat_inactiv-ddictxt = 'M'.
3945     ist_fieldcat_inactiv-col_pos =  mpos.
3946     ist_fieldcat_inactiv-seltext_m  = 'Amt In Doc Cur'.
3947     ist_fieldcat_inactiv-lowercase  = 'Y'.
3948     APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3949     CLEAR ist_fieldcat_inactiv.
3950
3951   *begin of < RD1K970594> CAB_ALOK 10.03.2010 CR30003739
3952     mpos = mpos + 1.
3953     ist_fieldcat_inactiv-fieldname = 'WAERS'.
3954     ist_fieldcat_inactiv-tabname = 'IST_SRCBSID_INACTIV'.
3955     ist_fieldcat_inactiv-ddictxt = 'M'.
3956     ist_fieldcat_inactiv-col_pos =  mpos.
3957     ist_fieldcat_inactiv-seltext_m  = 'Curr'.
3958     ist_fieldcat_inactiv-lowercase  = 'Y'.
3959     APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3960     CLEAR ist_fieldcat_inactiv.
3961   *end of < RD1K970594> CAB_ALOK 10.03.2010 CR30003739
3962
3963     mpos = mpos + 1.
3964     ist_fieldcat_inactiv-fieldname = 'ZLSCH'.
3965     ist_fieldcat_inactiv-tabname = 'IST_SRCBSID_INACTIV'.
3966     ist_fieldcat_inactiv-ddictxt = 'M'.
3967     ist_fieldcat_inactiv-col_pos =  mpos.
3968     ist_fieldcat_inactiv-seltext_m  = 'PM'.
3969     ist_fieldcat-lowercase  = 'Y'.
3970     APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3971     CLEAR ist_fieldcat_inactiv.
3972
3973     mpos = mpos + 1.
3974     ist_fieldcat_inactiv-fieldname = 'ZLSPR'.
3975     ist_fieldcat_inactiv-tabname = 'IST_SRCBSID_INACTIV'.
3976     ist_fieldcat_inactiv-ddictxt = 'M'.
3977     ist_fieldcat_inactiv-col_pos =  mpos.
3978     ist_fieldcat_inactiv-seltext_m  = 'PB'.
3979     ist_fieldcat_inactiv-lowercase  = 'Y'.
3980     APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3981     CLEAR ist_fieldcat_inactiv.
3982
3983     mpos = mpos + 1.
3984     ist_fieldcat_inactiv-fieldname = 'XREF1_HD'.
3985     ist_fieldcat_inactiv-tabname = 'IST_SRCBSID_INACTIV'.
3986     ist_fieldcat_inactiv-ddictxt = 'M'.
3987     ist_fieldcat_inactiv-col_pos =  mpos.
3988     ist_fieldcat_inactiv-seltext_m  = 'Loc'.
3989     ist_fieldcat_inactiv-lowercase  = 'Y'.
3990     APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
3991     CLEAR ist_fieldcat_inactiv.
3992
3993   *  IF NOT s_usnam IS INITIAL.
3994   *    mpos = mpos + 1.
3995   *    ist_fieldcat_inactiv-fieldname = 'USNAM'.
3996   *    ist_fieldcat_inactiv-tabname = 'IST_SRCBSID_INACTIV'.
3997   *    ist_fieldcat_inactiv-ddictxt = 'M'.
3998   *    ist_fieldcat_inactiv-col_pos =  mpos.
3999   *    ist_fieldcat_inactiv-seltext_m  = 'Created By'.
4000   *    ist_fieldcat_inactiv-lowercase  = 'Y'.
4001   *    APPEND ist_fieldcat_inactiv TO ist_fcat_inactiv.
4002   *    CLEAR ist_fieldcat_inactiv.
4003   *  ENDIF.
4004
4005   ENDFORM.                    " INIT_FIELDCAT_INACTIV_CUST
4006   *end of <RD1K967585> CAB_ALOK 03.12.2009 CR30002778
4007   *&---------------------------------------------------------------------*
4008   *&      Form  PRINT_MULTI_ALV_CUST
4009   *&---------------------------------------------------------------------*
4010   *       text
4011   *----------------------------------------------------------------------*
4012   *  -->  p1        text
4013   *  <--  p2        text
4014   *----------------------------------------------------------------------*
4015   *Begin of <RD1K967585> CAB_ALOK 07.12.2009 CR30002778
4016   FORM print_multi_alv_cust .
4017
4018     CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
4019       EXPORTING
4020         i_callback_program       = w_repid
4021         i_callback_pf_status_set = 'ALV_PFST'
4022         i_callback_user_command  = 'MAKEC_COMMAND'
4023         is_layout                = is_layout
4024         it_fieldcat              = ist_fcat[]
4025   *     it_sort                  =            " data of ist_srcbsik already arranged in reqd grouping
4026         it_events                = gt_events
4027         i_save                   = 'A'
4028       TABLES
4029         t_outtab                 = ist_srcbsid
4030   * Begin of Changes on 20-Jun-2013
4031       EXCEPTIONS
4032         PROGRAM_ERROR            = 1
4033         OTHERS                   = 2.
4034   * End of Changes on 20-Jun-2013
4035     IF sy-subrc <> 0.
4036   *    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
4037   *            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
4038     ENDIF.
4039
4040   ENDFORM.                    " PRINT_MULTI_ALV_CUST
4041   *&---------------------------------------------------------------------*
4042   *&      Form  DISPLAY_INACTIVE_ALV_CUST
4043   *&---------------------------------------------------------------------*
4044   *       text
4045   *----------------------------------------------------------------------*
4046   *  -->  p1        text
4047   *  <--  p2        text
4048   *----------------------------------------------------------------------*
4049   FORM display_inactive_alv_cust .
4050     CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
4051       EXPORTING
4052         i_callback_program = w_repid
4053   *     i_callback_pf_status_set = 'ALV_PFST'
4054   *     i_callback_user_command  = 'MAKE_COMMAND'
4055         is_layout          = is_layout_inactiv
4056         it_fieldcat        = ist_fcat_inactiv
4057         it_sort            = lt_sorttab
4058         it_events          = gt_events_inactiv
4059         i_save             = 'A'
4060       TABLES
4061         t_outtab           = ist_srcbsid_inactiv
4062   * Begin of Changes on 20-Jun-2013
4063       EXCEPTIONS
4064         PROGRAM_ERROR      = 1
4065         OTHERS             = 2.
4066   * End of Changes on 20-Jun-2013
4067     IF sy-subrc <> 0.
4068   *    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
4069   *            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
4070     ENDIF.
4071   ENDFORM.                    " DISPLAY_INACTIVE_ALV_CUST
4072
4073   *&---------------------------------------------------------------------*
4074   *&      Form  UPDATE_ZFI_REM_PYBLCK_L
4075   *&---------------------------------------------------------------------*
4076   *       text
4077   *----------------------------------------------------------------------*
4078   *  -->  p1        text
4079   *  <--  p2        text
4080   *----------------------------------------------------------------------*
4081   FORM update_zfi_rem_pyblck_l .
4082   * update Logs to table ZFI_REM_PYBLCK_L
4083     DATA: ist_zfi_rem_pyblck_l TYPE TABLE OF zfi_rem_pyblck_l,
4084           wa_zfi_rem_pyblck_l  TYPE zfi_rem_pyblck_l.
4085     DATA: count TYPE zfi_rem_pyblck_l-srno.
4086
4087   *begin of <RD1K967585> CAB_ALOK 10.12.2009 CR30002778
4088
4089     IF p_x2sp = 'X'.
4090       pmtblock_to = ' '.
4091     ELSEIF p_sp2x = 'X'.
4092       pmtblock_to = 'X'.
4093     ELSEIF p_sp2r = 'X'.
4094       pmtblock_to = 'R'.
4095     ELSEIF p_x2s = 'X'.
4096       pmtblock_to = 'S'.
4097   * Begin of RD1K971966 CAB_ALOK CR30004183
4098   *  ELSEIF p_s2x = 'X'.
4099   *    pmtblock_to = 'X'.
4100   * end of RD1K971966 CAB_ALOK CR30004183
4101     ENDIF.
4102
4103   *end of <RD1K967585> CAB_ALOK 10.12.2009 CR30002778
4104
4105     SELECT MAX( srno ) FROM zfi_rem_pyblck_l INTO count.
4106     IF NOT ist_srcbsik IS INITIAL.
4107
4108       LOOP AT ist_srcbsik INTO wa_srcbsik.
4109         count = count + 1.
4110
4111         wa_zfi_rem_pyblck_l-srno = count.
4112         wa_zfi_rem_pyblck_l-bukrs = wa_srcbsik-bukrs.
4113         wa_zfi_rem_pyblck_l-lifnr = wa_srcbsik-lifnr.
4114   *wa_ZFI_REM_PYBLCK_L-KUNNR = wa_srcbsik-KUNNR.
4115         wa_zfi_rem_pyblck_l-belnr = wa_srcbsik-belnr.
4116         wa_zfi_rem_pyblck_l-kidno = wa_srcbsik-kidno.
4117         wa_zfi_rem_pyblck_l-rebzg = wa_srcbsik-rebzg.
4118         wa_zfi_rem_pyblck_l-shkzg = wa_srcbsik-shkzg.
4119         wa_zfi_rem_pyblck_l-gjahr = wa_srcbsik-gjahr.
4120         wa_zfi_rem_pyblck_l-buzei = wa_srcbsik-buzei.
4121         wa_zfi_rem_pyblck_l-bschl = wa_srcbsik-bschl.
4122         wa_zfi_rem_pyblck_l-budat = wa_srcbsik-budat.
4123         wa_zfi_rem_pyblck_l-dmbtr = wa_srcbsik-dmbtr .
4124         wa_zfi_rem_pyblck_l-wrbtr = wa_srcbsik-wrbtr .
4125         wa_zfi_rem_pyblck_l-zlsch = wa_srcbsik-zlsch.
4126         wa_zfi_rem_pyblck_l-pmtblock_from = wa_srcbsik-zlspr.
4127         wa_zfi_rem_pyblck_l-pmtblock_to = pmtblock_to.
4128         wa_zfi_rem_pyblck_l-location = wa_srcbsik-xref1_hd.
4129         wa_zfi_rem_pyblck_l-uname = sy-uname.
4130         wa_zfi_rem_pyblck_l-usdate = sy-datum.
4131         wa_zfi_rem_pyblck_l-ustime = sy-uzeit.
4132
4133         INSERT zfi_rem_pyblck_l FROM wa_zfi_rem_pyblck_l.
4134       ENDLOOP.
4135       COMMIT WORK.
4136       REFRESH ist_srcbsik.
4137     ENDIF.
4138
4139     IF NOT ist_srcbsid IS INITIAL.
4140
4141       LOOP AT ist_srcbsid INTO wa_srcbsid.
4142         count = count + 1.
4143
4144         wa_zfi_rem_pyblck_l-srno = count.
4145         wa_zfi_rem_pyblck_l-bukrs = wa_srcbsid-bukrs.
4146   *   wa_ZFI_REM_PYBLCK_L-LIFNR = wa_srcbsid-LIFNR.
4147         wa_zfi_rem_pyblck_l-kunnr = wa_srcbsid-kunnr.
4148         wa_zfi_rem_pyblck_l-belnr = wa_srcbsid-belnr.
4149         wa_zfi_rem_pyblck_l-kidno = wa_srcbsid-kidno.
4150         wa_zfi_rem_pyblck_l-rebzg = wa_srcbsid-rebzg.
4151         wa_zfi_rem_pyblck_l-shkzg = wa_srcbsid-shkzg.
4152         wa_zfi_rem_pyblck_l-gjahr = wa_srcbsid-gjahr.
4153         wa_zfi_rem_pyblck_l-buzei = wa_srcbsid-buzei.
4154         wa_zfi_rem_pyblck_l-bschl = wa_srcbsid-bschl.
4155         wa_zfi_rem_pyblck_l-budat = wa_srcbsid-budat.
4156         wa_zfi_rem_pyblck_l-dmbtr = wa_srcbsid-dmbtr .
4157         wa_zfi_rem_pyblck_l-wrbtr = wa_srcbsid-wrbtr .
4158         wa_zfi_rem_pyblck_l-zlsch = wa_srcbsid-zlsch.
4159         wa_zfi_rem_pyblck_l-pmtblock_from = wa_srcbsid-zlspr.
4160         wa_zfi_rem_pyblck_l-pmtblock_to = pmtblock_to.
4161         wa_zfi_rem_pyblck_l-location = wa_srcbsid-xref1_hd.
4162         wa_zfi_rem_pyblck_l-uname = sy-uname.
4163         wa_zfi_rem_pyblck_l-usdate = sy-datum.
4164         wa_zfi_rem_pyblck_l-ustime = sy-uzeit.
4165
4166         INSERT zfi_rem_pyblck_l FROM wa_zfi_rem_pyblck_l.
4167       ENDLOOP.
4168       COMMIT WORK.
4169       REFRESH ist_srcbsid.
4170     ENDIF.
4171   ENDFORM.                    " UPDATE_ZFI_REM_PYBLCK_L
4172   *end of <RD1K967585> CAB_ALOK 09.12.2009 CR30002778
4173
4174   *Begin of <RD1K975843> CAB_ALOK CR 30005441
4175   FORM VALIDATE_LIAB_DOC_CREDIT_MEMO .
4176   ** In case credit memo exists against a PO, system should permit removal
4177   *  of block from liability document only if both liability doc and credit
4178   *   memo are selected for block removal.
4179     Tables: setleaf.
4180     data: T_AWKEY type BKPF-AWKEY,
4181           T_BELNR type RSEG-BELNR,
4182           T_GJAHR type RSEG-GJAHR,
4183           T_EBELN type RSEG-EBELN.
4184
4185     types: begin of TY_EKBE1.
4186             include STRUCTURE EKBE.
4187     types:  AWKEY1 type BKPF-AWKEY,
4188             end of TY_EKBE1.
4189
4190     data: IST_EKBE1 type STANDARD TABLE OF TY_EKBE1,
4191           WA_EKBE1  type TY_EKBE1,
4192           IST_BKPF1 type STANDARD TABLE OF BKPF,
4193           IST_BSIK1 type STANDARD TABLE OF BSIK,
4194           WA_BSIK1  type BSIK.
4195     DATA: ist_srcbsik_tmp LIKE STANDARD TABLE OF ist_srcbsik,
4196           wa_srcbsik_tmp  LIKE line of ist_srcbsik.
4197     data: del_flag(1),
4198           srcbsik_tabix type sy-tabix.
4199
4200     refresh: IST_MSG. "for storing msgs.
4201     clear: wa_srcbsik, WA_MSG.
4202   * currently ist_srcbsik contains only selected lines ( selcbox : 'X')
4203     Sort ist_srcbsik by LIFNR BUKRS BELNR.
4204
4205     loop at ist_srcbsik into wa_srcbsik where SHKZG = 'H'.
4206       clear:  T_AWKEY, T_BELNR, T_GJAHR, T_EBELN.
4207       srcbsik_tabix = sy-tabix.
4208   *get Reference Key(BKPF-AWKEY) from BKPF table for current line of ist_srcbsik,
4209       SELECT SINGLE AWKEY
4210         from BKPF
4211           into T_AWKEY
4212            where BUKRS = wa_srcbsik-BUKRS
4213              and BELNR = wa_srcbsik-BELNR
4214              and GJAHR = wa_srcbsik-GJAHR.
4215
4216       IF T_AWKEY+0(1) = '5'.
4217
4218         T_BELNR = T_AWKEY+0(10).  " Doc No.
4219         T_GJAHR = T_AWKEY+10(4).  " Year
4220   *Get Purchase doc No
4221         select single EBELN
4222           from RSEG
4223             into T_EBELN
4224               where BELNR = T_BELNR
4225                  and GJAHR = T_GJAHR.  "#EC CI_NOORDER
4226         if T_EBELN is not initial.
4227   *if this PO is not maintained in set "PO_Cr_memo" pass this value into Table EKBE
4228           select single * from SETLEAF
4229             where SETCLASS = '0000'
4230               and SETNAME  = 'PO_CR_MEMO'
4231               and VALFROM  = T_EBELN.
4232           if sy-subrc <> 0.
4233   * then check PO history in EKBE
4234   *   get  BELNR + GJAHR  = AWKEY1
4235             select * from EKBE
4236                into CORRESPONDING FIELDS OF TABLE IST_EKBE1
4237                  where EBELN = T_EBELN
4238                    and ( BEWTP = 'N' or BEWTP = 'P' or BEWTP = 'Q' or BEWTP = 'R' )
4239                    and SHKZG = 'H'.
4240
4241             if IST_EKBE1 is not initial.
4242               loop at IST_EKBE1 into WA_EKBE1.
4243                 CONCATENATE WA_EKBE1-BELNR WA_EKBE1-GJAHR into WA_EKBE1-AWKEY1.
4244                 modify IST_EKBE1 from WA_EKBE1 .
4245               endloop.
4246
4247   *          search Document Header BKPF for above AWKEYs, get Credit memos(BELNR,BUKRS,LIFNR).
4248               select * from BKPF
4249                 into CORRESPONDING FIELDS OF TABLE IST_BKPF1   " BELNR
4250                   FOR ALL ENTRIES IN IST_EKBE1
4251                     WHERE AWKEY = IST_EKBE1-AWKEY1
4252                       and BUKRS = P_BUKRS
4253                       and GJAHR = IST_EKBE1-GJAHR
4254                       and STGRD = ''  "leave reversed doc
4255                       and BSTAT = '' .  "#EC CI_NOORDER
4256
4257
4258   *          Check if open line items exist for above Credit Memos ( in same company code, same vendor) with payment block ='X'
4259               if IST_BKPF1 is not initial.
4260                 select * from BSIK
4261                   into CORRESPONDING FIELDS OF TABLE IST_BSIK1   " GJAHR
4262                     FOR ALL ENTRIES IN IST_BKPF1
4263                      WHERE LIFNR = WA_SRCBSIK-LIFNR
4264                        and BUKRS = IST_BKPF1-BUKRS
4265                        and BELNR = IST_BKPF1-BELNR
4266                        and ZLSPR = 'X'.  "#EC CI_NOORDER
4267                 if IST_BSIK1 is not initial. "open credit memo exists
4268   *               now check whether these Credit memo have been selected on ALV screen (i.e.exist in current IST_SRCBSIK)
4269                   loop at IST_BSIK1 into WA_BSIK1.
4270                     read TABLE ist_srcbsik INTO wa_srcbsik_tmp
4271                       WITH KEY LIFNR = WA_BSIK1-LIFNR
4272                                BUKRS = WA_BSIK1-BUKRS
4273                                BELNR = WA_BSIK1-BELNR
4274                             BINARY SEARCH.
4275                     if sy-subrc = 0. " credit-memo found in selected ALV lines, store for later deletion(if related Liab. doc. is being deleted) .
4276                       wa_srcbsik_tmp-inactiv = 'X'.
4277                       append wa_srcbsik_tmp to ist_srcbsik_tmp.
4278
4279                     else." credit-memo not found in selected ALV lines, store these LIV DOC - open Credit memo line items to Warning MSGs.
4280                       clear wa_msg.
4281                       concatenate wa_srcbsik-LIFNR ' ' wa_srcbsik-BUKRS wa_srcbsik-GJAHR ' ' wa_srcbsik-BELNR
4282                                   into wa_msg-LIV_DOC RESPECTING BLANKS.
4283                       concatenate WA_BSIK1-LIFNR ' ' WA_BSIK1-BUKRS WA_BSIK1-BELNR
4284                                   into wa_msg-CREDIT_MEMO RESPECTING BLANKS.
4285                       append wa_msg to ist_msg.
4286                       del_flag = 'X'. "atleast one credit-memo not found in selected ALV lines
4287                     endif.
4288                   endloop. "/at IST_BSIK1
4289
4290                   if del_flag = 'X'.
4291                     "delete current Liability Doc from ist_srcbsik(current line of loop at ist_srcbsik ).
4292                     delete ist_srcbsik index srcbsik_tabix.
4293                     clear del_flag.
4294                     "also mark related credit memos for deletion in ist_srcbsik
4295                     loop at ist_srcbsik_tmp into wa_srcbsik_tmp.
4296                       modify ist_srcbsik from wa_srcbsik_tmp TRANSPORTING inactiv
4297                                  where LIFNR = wa_srcbsik_tmp-LIFNR
4298                                    and BUKRS = wa_srcbsik_tmp-BUKRS
4299                                    and BELNR = wa_srcbsik_tmp-BELNR.
4300                     endloop.
4301                     refresh  ist_srcbsik_tmp.
4302                     clear wa_srcbsik_tmp.
4303                   endif.  "/del_flag
4304                 endif.                                        "/IST_BSIK1
4305               endif.                                          "/IST_BKPF1
4306             endif.                                            "/IST_EKBE1
4307           endif. "/sy-subrc
4308         endif. "/T_EBELN
4309       ENDIF. "/T_AWKEY
4310     endloop. "/ist_srcbsik
4311   * finally delete invalid credit memos from ist_srcbsik.
4312     DELETE ist_srcbsik WHERE inactiv = 'X'.
4313   ENDFORM.                    " VALIDATE_LIAB_DOC_CREDIT_MEMO
4314
4315   *&---------------------------------------------------------------------*
4316   *&      Form  DISPLAY_MESSAGES
4317   *&---------------------------------------------------------------------*
4318   *       text
4319   *----------------------------------------------------------------------*
4320   FORM DISPLAY_MESSAGES .
4321     if ist_msg is not initial.
4322       write:/ 'Following LIV docs were excluded from processing as related Credit memo(s) were not selected:'.
4323       write:/.
4324       write:/ '--------- LIV document -------       ------ Credit memo ------'.
4325   *          0000107291 MUM 2011 7111000010     0000107291 MUM 7111000007
4326
4327       loop at ist_msg into wa_msg.
4328         write:/ wa_msg-LIV_DOC, '     ', wa_msg-CREDIT_MEMO.
4329       endloop.
4330     endif.
4331     refresh ist_msg.
4332     clear wa_msg.
4333   ENDFORM.                    " DISPLAY_MESSAGES
4334   *end of <RD1K975843> CAB_ALOK CR 30005441
4335   *&---------------------------------------------------------------------*
4336   *&      Form  GET_BUDGET
4337   *&---------------------------------------------------------------------*
4338   *       text
4339   *----------------------------------------------------------------------*
4340   *      -->P_WA_SRCBSIK_L_BUKRS  text
4341   *      -->P_WA_SRCBSIK_L_FISTL  text
4342   *      -->P_WA_SRCBSIK_L_FIPOS  text
4343   *      -->P_WA_SRCBSIK_L_GJAHR  text
4344   *      <--P_G_BUDGET  text
4345   *----------------------------------------------------------------------*
4346   FORM GET_BUDGET  USING    P_BUKRS
4347                             P_FISTL
4348                             P_FIPOS
4349                             P_GJAHR
4350                    CHANGING P_BUDGET.
4351
4352     DATA : ist_abaplist TYPE STANDARD TABLE OF abaplist.
4353
4354     DATA: BEGIN OF ist_ascitab OCCURS 1,
4355             line(1000),
4356           END OF ist_ascitab.
4357
4358     DATA : wa_ascitab LIKE ist_ascitab.
4359
4360     DATA : l_menge TYPE eban-menge.
4361
4362     DATA : l_pr_concur(20),
4363            l_avl_budgt(30),
4364            l_dis_budgt(30),
4365            l_ass_budgt(30).
4366
4367
4368     DATA : wa_xbseg TYPE bseg.
4369
4370     DATA : l_eindt   TYPE sy-datum, "eket-eindt,
4371            l_year_po TYPE bkpf-gjahr,
4372            l_year_fi TYPE bkpf-gjahr.
4373
4374     DATA : l_fikrs     TYPE fkrs-fikrs,
4375            l_budget    TYPE fmit-hsl16,
4376            l_budget_d  TYPE fmit-hsl16,
4377            l_budget_as TYPE fmit-hsl16,
4378            l_budget_av TYPE fmit-hsl16.
4379
4380     DATA : l_fistl TYPE fistl,    "ekpo-fistl
4381            l_fipos TYPE fm_fipex. "ekpo-fipos.
4382
4383     DATA : l_bukrs      TYPE t001-bukrs,
4384            l_budat      TYPE sy-datum,
4385            ist_fmavc001 TYPE TABLE OF fmavc001,
4386            wa_fmavc001  TYPE fmavc001.
4387
4388     DATA : l_dmbtr TYPE bseg-dmbtr.
4389   * SELECT MAX( gjahr ) FROM fmioi INTO l_year_po
4390   *        WHERE refbn = bseg-ebeln AND
4391   *              rfpos = bseg-ebelp AND
4392   *              cfstat IN ('00','32').
4393   *  CALL FUNCTION 'FI_PERIOD_DETERMINE'
4394   *      EXPORTING
4395   *        i_budat     = bkpf-budat
4396   *        i_periv     = 'V3'
4397   *      IMPORTING
4398   *        e_gjahr     = l_year_fi
4399   *      EXCEPTIONS
4400   *        fiscal_year = 1.
4401   *
4402   *    IF sy-subrc <> 0.
4403   **       MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
4404   **               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
4405   *    ENDIF.
4406   *
4407   *
4408   *    IF l_year_po NE l_year_fi.
4409   *            IF NOT bseg-fistl IS INITIAL AND NOT bseg-fipos IS INITIAL.
4410   *        MOVE bkpf-bukrs TO l_bukrs.
4411   *        MOVE bseg-fistl TO l_fistl.
4412   *        MOVE bseg-fipos TO l_fipos.
4413   *        MOVE bkpf-budat TO l_budat.
4414   *
4415   *CALL FUNCTION 'FM_BUDGET_READ_BBP'
4416   *          EXPORTING
4417   *            i_bukrs       = l_bukrs
4418   *            i_date        = l_budat
4419   *            i_funds_ctr   = l_fistl
4420   *            i_commt_item  = l_fipos
4421   *          TABLES
4422   *            t_bp_obj      = ist_fmavc001
4423   *          EXCEPTIONS
4424   *            error_occured = 1
4425   *            OTHERS        = 2.
4426   *
4427   *        IF sy-subrc <> 0.
4428   **            MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
4429   **               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
4430   *        ENDIF.
4431   *
4432
4433   *        IF NOT ist_fmavc001[] IS INITIAL.
4434   *
4435   *          READ TABLE ist_fmavc001 INTO wa_fmavc001 INDEX 1.
4436   * l_dmbtr =  ( wa_fmavc001-distributable -
4437   *                       wa_fmavc001-assigned ) / 100.
4438   *
4439   *                  ENDIF.
4440     SUBMIT  zfifm_annual_budget
4441                    EXPORTING LIST TO MEMORY AND RETURN
4442                         WITH s_fikrs = P_BUKRS
4443                         WITH s_fictr = P_FISTL
4444                         WITH s_fipos = P_FIPOS
4445                         WITH s_gjahr = P_GJAHR.
4446
4447     CALL FUNCTION 'LIST_FROM_MEMORY'
4448       TABLES
4449         listobject = ist_abaplist
4450       EXCEPTIONS
4451         not_found  = 1
4452         OTHERS     = 2.
4453     IF sy-subrc <> 0.
4454       MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
4455               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
4456     ENDIF.
4457
4458     CALL FUNCTION 'LIST_TO_ASCI'
4459       TABLES
4460         listobject = ist_abaplist
4461         listasci   = ist_ascitab.
4462
4463     LOOP AT ist_ascitab INTO wa_ascitab.
4464       WRITE :/ wa_ascitab-line.
4465     ENDLOOP.
4466
4467     IF NOT ist_ascitab[] IS INITIAL.
4468       READ TABLE ist_ascitab INTO wa_ascitab INDEX 10.
4469   *    READ TABLE ist_ascitab INTO wa_ascitab INDEX 6.
4470   *{Begin of CR 30007900
4471       clear :ist_budget,
4472              wa_budget,
4473              l_dis_budgt,
4474              g_BUDGET_c,
4475              l_budget.
4476       refresh ist_budget.
4477
4478       SPLIT wa_ascitab AT '|' INTO TABLE ist_budget.
4479   *}end of CR 30007900
4480       IF sy-subrc = 0.
4481   *{Begin of CR 30007900
4482   *      l_pr_concur = wa_ascitab+141(20).
4483   *      l_avl_budgt = wa_ascitab+162(14).
4484
4485   *      READ TABLE ist_budget INTO wa_budget INDEX 11.
4486         READ TABLE ist_budget INTO wa_budget INDEX 7.
4487         if sy-subrc = 0.
4488           l_dis_budgt = wa_budget-row.
4489           condense l_dis_budgt.
4490         endif.
4491   *}end of CR 30007900
4492   *      WRITE :/ 'PRs Concurred by Finance :', l_pr_concur.
4493   *      WRITE :/ 'Available budget         :', l_avl_budgt.
4494
4495
4496         clear : l_ass_budgt.
4497         READ TABLE ist_budget INTO wa_budget INDEX 8.
4498         if sy-subrc = 0.
4499           l_ass_budgt = wa_budget-row.
4500           condense l_ass_budgt.
4501         endif.
4502
4503         clear : g_BUDGET_d.
4504         g_BUDGET_d = l_dis_budgt.
4505         condense g_BUDGET_d.
4506         perform convert_c_to_num using g_BUDGET_d changing l_budget_d.
4507
4508   *    l_avl_budgt = l_dis_budgt - l_ass_budgt.
4509
4510         clear : g_BUDGET_as.
4511         g_BUDGET_as = l_ass_budgt.
4512         condense g_BUDGET_as.
4513         perform convert_c_to_num using g_BUDGET_as changing l_budget_as.
4514
4515       ENDIF.
4516     endif.
4517     l_budget_av = l_budget_d - l_budget_as.
4518
4519     l_budget = l_budget_av.
4520     P_BUDGET = l_budget.
4521   ENDFORM.                    " GET_BUDGET
4522   *&---------------------------------------------------------------------*
4523   *&      Form  CONVERT_C_TO_NUM
4524   *&---------------------------------------------------------------------*
4525   *       text
4526   *----------------------------------------------------------------------*
4527   *      -->P_G_BUDGET_C  text
4528   *      <--P_L_BUDGET_D  text
4529   *----------------------------------------------------------------------*
4530   FORM CONVERT_C_TO_NUM  USING    P_G_BUDGET_C
4531                          CHANGING P_L_BUDGET_D.
4532
4533     CALL FUNCTION 'MOVE_CHAR_TO_NUM'
4534       EXPORTING
4535         CHR             = p_g_BUDGET_c
4536       IMPORTING
4537         NUM             = p_l_budget_d
4538   * Begin of Changes on 20-Jun-2013
4539       EXCEPTIONS
4540         CONVT_NO_NUMBER = 1
4541         CONVT_OVERFLOW  = 2
4542         OTHERS          = 3
4543   * End of Changes on 20-Jun-2013
4544       .
4545     IF SY-SUBRC <> 0.
4546   * MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
4547   *         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
4548     ENDIF.
4549   ENDFORM.                    " CONVERT_C_TO_NUM
4550
4551   *-- S/4 helper: change BSEG payment block via FI_DOCUMENT_CHANGE - SAP_ABAP 16.06.2026 --
4552   FORM zz_s4_bseg_zlspr USING p_bukrs p_belnr p_gjahr p_buzei p_zlspr.
4553     DATA: lt_acchg TYPE STANDARD TABLE OF accchg, ls_acchg TYPE accchg.
4554     REFRESH lt_acchg. CLEAR ls_acchg.
4555     ls_acchg-fdname = 'ZLSPR'. ls_acchg-newval = p_zlspr.
4556     APPEND ls_acchg TO lt_acchg.
4557     CALL FUNCTION 'FI_DOCUMENT_CHANGE' EXPORTING i_bukrs = p_bukrs i_belnr = p_belnr i_gjahr = p_gjahr
4558          i_buzei = p_buzei TABLES t_acchg = lt_acchg EXCEPTIONS OTHERS = 0.
4559   ENDFORM.
*--- End of ZFI_REM_PYBLCK - 4559 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CSLIS                                   Level 1    Page 2
Object           ZFI_REM_PYBLCK                            Lines 543
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:24
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
Object           ZFI_REM_PYBLCK                            Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:24
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
Object           ZFI_REM_PYBLCK                            Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:24
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
Object           ZFI_REM_PYBLCK                            Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:24
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
Object           ZFI_REM_PYBLCK                            Lines 1
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:24
----------------------------------------------------------------------------------------------------
1      * INCLUDE DB__SSEL
*--- End of DB__SSEL - 1 lines ---
