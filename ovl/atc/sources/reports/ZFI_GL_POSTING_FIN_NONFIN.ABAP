----------------------------------------------------------------------------------------------------
Main program     ZFI_GL_POSTING_FIN_NONFIN                 Level 0    Page 1
Object           ZFI_GL_POSTING_FIN_NONFIN                 Lines 723
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:16
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *& Report  ZFI_GL_POSTING_FIN_NONFIN
3      *&
4      *&---------------------------------------------------------------------*
5      *&
6      *&
7      *----------------------------------------------------------------*
8      *Change History
9      ***********************************************************************
10     *Date        Transport       USERID        Description
11     *10.6.2016    <RD1K9A00WF>    CAB_RAMA     CR 30014453(LIPSY)          *
12     *----------------------------------------------------------------------
13
14     *&---------------------------------------------------------------------*
15     REPORT ZFI_GL_POSTING_FIN_NONFIN.
16
17     TABLES :t001,sscrfields.
18
19     types: begin of ty_log,
20              message_v2 type BAPIRET2-message_v2,
21              type       type BAPIRET2-type,
22              id         type BAPIRET2-id,
23              number     type BAPIRET2-number,
24              message    type BAPIRET2-message.
25     types: end of ty_log.
26
27     TYPES : BEGIN OF GTY_FIELDNAMES,
28               TITLE(100),
29             END   OF GTY_FIELDNAMES.
30     ** Internal table and Work area declarations
31
32     data : ist_log type STANDARD TABLE OF ty_log,
33            wa_log  type ty_log.
34
35     DATA : wa_documentheader    TYPE bapiache09,
36            it_accountgl         TYPE STANDARD TABLE OF bapiacgl09,
37            wa_accountgl         TYPE bapiacgl09,
38            it_accountreceivable TYPE STANDARD TABLE OF bapiacar09,
39            wa_accountreceivable TYPE bapiacar09,
40            it_currencyamount    TYPE STANDARD TABLE OF bapiaccr09,
41            wa_currencyamount    TYPE bapiaccr09,
42            it_return            TYPE STANDARD TABLE OF bapiret2,
43            it_return_dis        TYPE STANDARD TABLE OF bapiret2,
44            wa_return            TYPE bapiret2,
45            it_extension1        TYPE STANDARD TABLE OF bapiacextc,
46            wa_extension1        TYPE bapiacextc.
47
48     DATA : doc_amt_cr TYPE bapiwrbtr , "VALUE '50.00',
49            doc_amt_dr TYPE bapiwrbtr . "VALUE '-50.00'.
50
51     DATA:  lv_type TYPE bapiache09-obj_type,
52            lv_key  TYPE bapiache09-obj_key,
53            lv_sys  TYPE bapiache09-obj_sys.
54
55
56
57     DATA: GIT_FIELDNAMES TYPE STANDARD TABLE OF GTY_FIELDNAMES,
58           GWA_FIELDNAMES TYPE GTY_FIELDNAMES.
59
60     DATA : GD_FILENAME TYPE STRING,
61            GD_PATH     TYPE STRING,
62            GD_FULLPATH TYPE STRING,
63            GD_RESULT   TYPE I.
64
65     DATA : BEGIN OF ist_gl OCCURS 0,
66              BLDAT(10),
67              BLART     TYPE bkpf-blart,
68
69              bukrs     type bkpf-bukrs,
70              BUDAT(10),
71
72              """"""""""""""""""""""""""""""""
73              "added by lipsy 10.06.2016
74              period_new type MONAT,
75              "eadd by lipsy 10.06.2016
76              """""""""""""""""""""""""""""""""""
77              waers     type bkpf-waers,
78              XBLNR     type bkpf-XBLNR,     "Header Ref
79              bktxt     type bkpf-bktxt,
80
81              NEWBS_1   type RF05A-newbs,
82              NEWKO_1   type RF05A-newko,
83              NEWUM_1   type RF05A-NEWUM,
84
85              dmBTr(25)," TYPE P LENGTH 13 DECIMALS 2,"(20)    type c,
86              GSBER_1   type bseg-gsber,
87              prctr_1   type bseg-prctr,
88              ZFBDT(10),"     type bseg-ZFBDT,      "Due On
89              ZUONR     TYPE BSEG-ZUONR,    "Assignment
90              sgtxt     type bseg-sgtxt,
91              NEWBS_2   type RF05A-newbs,
92              NEWKO_2   type RF05A-newko,
93              NEWUM_2   type RF05A-NEWUM,
94
95              GSBER_2   type bseg-gsber,
96              prctr_2   type bseg-prctr,
97              f_dmBTr   TYPE P LENGTH 13 DECIMALS 2. "(20)    type c,
98     DATA: END OF ist_gl.
99     data : g_dmBTr TYPE P LENGTH 13 DECIMALS 2.
100    DATA: d_butt1(4).
101
102    data:  wa_gl like LINE OF ist_gl.
103    DATA : IT_FILE  LIKE ALSMEX_TABLINE OCCURS 0 WITH HEADER LINE.
104
105    DATA FILE_PATH LIKE  RLGRAP-FILENAME.
106    DATA l_tabix type sy-tabix.
107    DATA l_newko_n(10) type n.
108    *DATA l_dmbtr(13).
109    DATA l_dmbtr(25)." TYPE P LENGTH 13 DECIMALS 2.
110    DATA GV_STATUS TYPE C LENGTH 1.
111
112    data : DOCUMENTHEADER    TYPE BAPIACHE09,
113           ACCOUNTPAYABLE    TYPE STANDARD TABLE OF BAPIACAP09,
114           WA_AP             TYPE BAPIACAP09,
115           ACCOUNTRECEIVABLE TYPE STANDARD TABLE OF BAPIACAR09,
116           WA_AR             TYPE BAPIACAR09,
117           WA_CA             TYPE BAPIACCR09,
118           ACCOUNTWT         TYPE STANDARD TABLE OF BAPIACWT09,
119           WA_WT             TYPE BAPIACWT09,
120           ACCOUNTGL         TYPE STANDARD TABLE OF BAPIACGL09,
121           WA_GL_1           TYPE BAPIACGL09,
122           CURRENCYAMOUNT    TYPE STANDARD TABLE OF BAPIACCR09,
123           RETURN            TYPE STANDARD TABLE OF BAPIRET2,
124           WA_RET            TYPE BAPIRET2,
125           GW_RETURN         TYPE BAPIRETURN,
126           GV_POSNR          TYPE POSNR_ACC,
127           wa_accountpayable TYPE bapiacap09,
128           it_accountpayable LIKE STANDARD TABLE OF wa_accountpayable.
129
130    DATA :g_docdt  type sy-datum,
131          g_postdt type sy-datum,
132          g_bline  type sy-datum.
133
134    DATA g_vendor(10).
135    DATA :g_tabix    type sy-tabix,
136          g_line(10).
137    DATA wa_bkpf type bkpf.
138    SELECTION-SCREEN BEGIN OF BLOCK blk1
139
140                              WITH FRAME TITLE title.
141    SELECTION-SCREEN SKIP.
142
143    SELECTION-SCREEN BEGIN OF LINE.
144    *  SKIP 4.
145    SELECTION-SCREEN PUSHBUTTON (20) w_button USER-COMMAND BUT1.
146
147    SELECTION-SCREEN END OF LINE.
148    SELECTION-SCREEN SKIP.
149    SELECTION-SCREEN BEGIN OF LINE.
150    SELECTION-SCREEN PUSHBUTTON (20) w_but2 USER-COMMAND BUT2.
151    SELECTION-SCREEN END OF LINE.
152    SELECTION-SCREEN END OF BLOCK blk1.
153
154    INITIALIZATION.
155      MOVE 'SAMPLE of Excel File' TO sscrfields-functxt_01.
156      MOVE 'UPLOAD Excel File' TO sscrfields-functxt_02.
157      title = 'Make a selection'.
158      d_butt1 = 'NO'.
159    * Add displayed text string to buttons
160      w_button = 'SAMPLE of Excel File'.
161      w_but2 = 'UPLOAD Excel File'.
162
163    AT SELECTION-SCREEN.
164
165      CASE sscrfields-ucomm.
166
167        WHEN 'BUT1'.
168          perform download_sample_file.
169    *    WHEN 'CLI2' or 'BUT2'.
170        WHEN 'BUT2'.
171          Perform upload_file.
172    *      perform post_document.
173    *      perform display_log.
174        when 'OTHERS'.
175          message e100(zfi) with text-001.
176    ** clear internal table
177      ENDCASE.
178
179    AT SELECTION-SCREEN OUTPUT.
180
181    Start-of-selection.
182    *      perform post_document.
183      perform post_document.
184      perform display_log.
185
186    end-of-SELECTION.
187
188    *&---------------------------------------------------------------------*
189    *&      Form  UPLOAD_FILE
190    *&---------------------------------------------------------------------*
191    *       text
192    *----------------------------------------------------------------------*
193    *  -->  p1        text
194    *  <--  p2        text
195    *----------------------------------------------------------------------*
196    FORM UPLOAD_FILE .
197
198
199      CALL FUNCTION 'F4_FILENAME'
200        EXPORTING
201          field_name = 'FILE_LOC' "Here file_LOC is the text Element name on Screen.
202        IMPORTING
203          file_name  = FILE_PATH.
204
205      CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
206        EXPORTING
207          FILENAME                = FILE_PATH
208          I_BEGIN_COL             = '1'
209          I_BEGIN_ROW             = '1'
210          I_END_COL               =  '20' "'19'
211    *     I_END_COL               = '8'
212          I_END_ROW               = '10000'
213        TABLES
214          INTERN                  = IT_FILE
215        EXCEPTIONS
216          INCONSISTENT_PARAMETERS = 1
217          UPLOAD_OLE              = 2
218          OTHERS                  = 3.
219
220      IF SY-SUBRC NE SPACE.
221
222    *leave PROGRAM.
223
224      ENDIF.
225
226      " Now I use the following Logic to convert that IT_FILE table  into our own table format."
227
228      if not it_file[] is initial.
229        LOOP AT IT_FILE.
230          l_tabix = sy-tabix.
231          if IT_FILE-row <> '0001'.
232            CASE IT_FILE-COL.
233                condense IT_FILE-VALUE .
234              WHEN '0001'.
235
236                MOVE IT_FILE-VALUE TO IST_GL-BLDAT.
237
238              WHEN '0002'.
239                MOVE IT_FILE-VALUE TO IST_GL-BLART.
240
241
242              WHEN '0003'.
243
244                MOVE IT_FILE-VALUE TO IST_GL-bukrs.
245
246              WHEN '0004'.
247
248                MOVE IT_FILE-VALUE TO IST_GL-budat.
249
250
251    """""""""""""""""""""""""""""""""""""
252    "add by lipsy 10.06.2016
253       WHEN '0005'.
254
255                MOVE IT_FILE-VALUE TO IST_GL-period_new.
256    "eadd by lipsy 10.06.2016
257    """""""""""""""""""""""""""""""""""""""""""""""""
258
259
260              WHEN   '0006'.   "'0005'.
261                MOVE IT_FILE-VALUE TO IST_GL-waers.
262
263    ****************************Added by Anamika On 08.01.2015 RD1K995584*************************
264              WHEN   '0007'."    '0006'.
265
266                MOVE IT_FILE-VALUE TO IST_GL-xblnr.
267
268
269              WHEN  '0008'."'0007'.
270
271                MOVE IT_FILE-VALUE TO IST_GL-bktxt.
272
273
274
275              WHEN  '0009'."'0008'.
276
277                MOVE IT_FILE-VALUE TO IST_GL-NEWBS_1.
278
279              WHEN '0010'."'0009'.
280                MOVE IT_FILE-VALUE TO IST_GL-NEWKO_1.
281
282
283              WHEN '0011'."'0010'.
284
285                MOVE IT_FILE-VALUE TO IST_GL-NEWUM_1.
286
287              WHEN '0012'."'0011'.
288
289                MOVE IT_FILE-VALUE TO l_dmbtr.
290    *            MOVE IT_FILE-VALUE TO l_dmbtr.
291    *            condense l_dmbtr.
292                data :l_user_decimal type usr01-dcpfm.
293                SELECT SINGLE dcpfm         "Decimal notaion
294                FROM   usr01                "User master record (runtime data)
295                INTO   l_user_decimal
296                WHERE  bname EQ sy-uname.
297
298                CASE l_user_decimal.
299                  WHEN ' '.  " Decimal point is comma: N.NNN,NN
300                    TRANSLATE l_dmbtr USING '. '.
301                    TRANSLATE l_dmbtr USING ',.'.
302                  WHEN 'X'.  " Decimal point is period: N,NNN.NN
303                    TRANSLATE l_dmbtr USING ', '.
304                  WHEN 'Y'.  " Decimal point is N NNN NNN,NN
305                    TRANSLATE l_dmbtr USING ',.'.
306                ENDCASE.
307                CONDENSE l_dmbtr NO-GAPS.
308                IST_GL-f_dmBTr = l_dmbtr.
309
310
311
312    *            IST_GL-f_DMBTR = l_dmbtr.
313    *IST_GL-DMBTR = IT_FILE-VALUE.
314              WHEN '0013'."'0012'.
315
316                MOVE IT_FILE-VALUE TO IST_GL-GSBER_1.
317
318              WHEN '0014'."'0013'.
319
320                MOVE IT_FILE-VALUE TO IST_GL-prctr_1.
321
322              WHEN '0015'."'0014'.
323
324                MOVE IT_FILE-VALUE TO IST_GL-ZFBDT.
325
326              WHEN '0016'."'0015'.
327
328                MOVE IT_FILE-VALUE TO IST_GL-ZUONR.
329
330              WHEN '0017'."'0016'.
331
332                MOVE IT_FILE-VALUE TO IST_GL-SGTXT.
333
334    *****SECOND gl
335              WHEN '0018'."'0017'.
336
337                MOVE IT_FILE-VALUE TO IST_GL-NEWBS_2.
338
339              WHEN '0019'."'0018'.
340                MOVE IT_FILE-VALUE TO IST_GL-NEWKO_2.
341
342
343              WHEN '0020'."'0019'.
344
345                MOVE IT_FILE-VALUE TO IST_GL-NEWUM_2.
346
347            ENDCASE.
348
349            AT END OF ROW.
350
351              APPEND IST_GL.
352
353              CLEAR IST_GL.
354
355            ENDAT.
356
357    *  APPEND IST_UPLOAD.
358          endif.
359        ENDLOOP.
360      endif.
361
362      SSCRFIELDS-UCOMM = 'ONLI'.
363    ENDFORM.                    " UPLOAD_FILE
364    *&---------------------------------------------------------------------*
365    *&      Form  POST_DOCUMENT
366    *&---------------------------------------------------------------------*
367    *       text
368    *----------------------------------------------------------------------*
369    *  -->  p1        text
370    *  <--  p2        text
371    *----------------------------------------------------------------------*
372    FORM POST_DOCUMENT .
373
374
375      if not ist_gl[] is initial.
376
377        clear: wa_gl,it_return_dis.
378        refresh :it_return_dis.
379
380        LOOP at ist_gl into wa_gl.
381          g_tabix = sy-tabix.
382          g_line = g_tabix.
383          clear : wa_bkpf,wa_return.
384    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
385    *      select single * from bkpf
386    *        into wa_bkpf
387    *        where bukrs = wa_gl-bukrs
388    *          and xblnr = wa_gl-xblnr.
389     SELECT * FROM BKPF   UP TO 1 ROWS INTO WA_BKPF WHERE BUKRS =
390    WA_GL-BUKRS AND XBLNR = WA_GL-XBLNR  ORDER BY  BUKRS BELNR GJAHR .
391    ENDSELECT.
392    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
393          if sy-SUBRC = 0.
394            wa_return-TYPE = 'E'.
395            wa_return-ID = '001'.
396            concatenate 'Document Already posted against-' wa_bkpf-belnr into wa_return-MESSAGE.
397            wa_return-ROW = g_tabix.
398            append wa_return to it_return_dis.
399          else.
400            PERFORM PREPARE_FI_DOCUMENT CHANGING GV_STATUS.
401          endif.
402
403
404    ** display the output
405          LOOP AT it_return INTO wa_return.
406    *    WRITE :/ wa_return-type,
407    *             wa_return-id,
408    *             wa_return-number,
409    *             wa_return-message.
410            append wa_return to it_return_dis.
411          ENDLOOP.
412          READ TABLE it_return INTO wa_return WITH KEY type = 'E'.
413          IF sy-subrc NE 0.
414            CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
415          ENDIF.
416        endloop.
417
418    ** display the output
419    *  LOOP AT it_return_dis INTO wa_return.
420    *    WRITE :/ wa_return-type,
421    *             wa_return-id,
422    *             wa_return-number,
423    *             wa_return-message.
424    *  ENDLOOP.
425      ENDIF.
426    ENDFORM.                    " POST_DOCUMENT
427    *&---------------------------------------------------------------------*
428    *&      Form  POST_DOCUMENT_BAPI
429    *&---------------------------------------------------------------------*
430    *       text
431    *----------------------------------------------------------------------*
432    *  -->  p1        text
433    *  <--  p2        text
434    *----------------------------------------------------------------------*
435    FORM POST_DOCUMENT_BAPI .
436      clear wa_gl.
437    *  LOOP at ist_gl into wa_gl.
438    *     doc_amt_dr = wa_gl-wrbtr * -1.
439    *     doc_amt_cr = wa_gl-wrbtr.
440      REFRESH :it_accountgl,
441             it_accountreceivable,
442             it_currencyamount,
443             it_return,
444             it_extension1.
445    ** Fill header data.
446      CLEAR : wa_documentheader.
447      MOVE sy-uname  TO wa_documentheader-username.  "Username"
448      MOVE 'Test'    TO wa_documentheader-header_txt."Header Text"
449    * MOVE '0103'    TO wa_documentheader-comp_code. "Company Code"
450      MOVE 'DDN'    TO wa_documentheader-comp_code. "Company Code"
451      MOVE sy-datum  TO wa_documentheader-doc_date.  "Doc Date"
452      MOVE sy-datum  TO wa_documentheader-pstng_date."Posting Date"
453    * MOVE 'DZ'      TO wa_documentheader-doc_type.  "Doc Type"
454      MOVE 'SA'      TO wa_documentheader-doc_type.  "Doc Type"
455      MOVE 'Test'    TO wa_documentheader-ref_doc_no."Reference"
456      MOVE 'RFBU'    TO wa_documentheader-bus_act.
457      MOVE 'BKPFF'   TO wa_documentheader-obj_type.  "Comment for >= ECC5.0
458      MOVE '$'       TO wa_documentheader-obj_key.   "Comment for >= ECC5.0
459      MOVE sy-mandt  TO wa_documentheader-obj_sys.   "Comment for >= ECC5.0
460
461
462    **Fill GL Account Line item.
463      CLEAR : wa_accountgl, wa_currencyamount.
464      MOVE '0000000001' TO wa_accountgl-itemno_acc.  "Line Item No"
465      MOVE '0000100292' TO wa_accountgl-gl_account.  "G/L Account"
466
467    *    MOVE wa_gl-newko TO wa_accountgl-gl_account.  "G/L Account"
468      MOVE 'ZFITRFASSET_DACT'   TO wa_accountgl-item_text.   "Item Text"
469    * MOVE 'DDN'       TO wa_accountgl-comp_code.   "Company Code"
470    * MOVE '0000900390' TO wa_accountgl-profit_ctr.  "Profit Center"
471    * MOVE 'Assign1'    TO wa_accountgl-alloc_nmbr.  "Assignment"
472      APPEND wa_accountgl TO it_accountgl.
473
474
475      MOVE '0000000001' TO wa_currencyamount-itemno_acc.  "Line Item No"
476      MOVE '00'         TO wa_currencyamount-curr_type.  "Currency Type"
477      MOVE 'INR'        TO wa_currencyamount-currency.   "Currency"
478    *    if wa_gl-newbs = '50'.
479    *      MOVE doc_amt_dr   TO wa_currencyamount-amt_doccur. "Amount"
480    *    else.
481      MOVE doc_amt_cr   TO wa_currencyamount-amt_doccur. "Amount"
482    *    endif.
483      APPEND wa_currencyamount TO it_currencyamount.
484
485
486    **Fill GL Account Line item.
487      CLEAR : wa_accountgl, wa_currencyamount.
488      MOVE '0000000002' TO wa_accountgl-itemno_acc.  "Line Item No"
489
490    *    MOVE wa_gl-newko_2 TO wa_accountgl-gl_account.  "G/L Account"
491      MOVE '0000201525' TO wa_accountgl-gl_account.  "G/L Account"
492
493      MOVE 'ZFITRFASSET_DACT'   TO wa_accountgl-item_text.   "Item Text"
494    *  MOVE 'ItemTest2'   TO wa_accountgl-item_text.   "Item Text"
495    * MOVE 'DDN'       TO wa_accountgl-comp_code.   "Company Code"
496    * MOVE '0000900390' TO wa_accountgl-profit_ctr.  "Profit Center"
497    * MOVE 'Assign1'    TO wa_accountgl-alloc_nmbr.  "Assignment"
498      APPEND wa_accountgl TO it_accountgl.
499      MOVE '0000000002' TO wa_currencyamount-itemno_acc.  "Line Item No"
500      MOVE '00'         TO wa_currencyamount-curr_type.  "Currency Type"
501      MOVE 'INR'        TO wa_currencyamount-currency.   "Currency"
502    * MOVE doc_amt_dr   TO wa_currencyamount-amt_doccur. "Amount"
503    *    if wa_gl-newbs = '50'.
504      MOVE doc_amt_dr   TO wa_currencyamount-amt_doccur. "Amount"
505    *    else.
506    *      MOVE doc_amt_cr   TO wa_currencyamount-amt_doccur. "Amount"
507    *    endif.
508      APPEND wa_currencyamount TO it_currencyamount.
509
510    *** Fill Customer Line item
511    * CLEAR :wa_accountreceivable, wa_currencyamount.
512    * MOVE '0000000002' TO wa_accountreceivable-itemno_acc. "Item No"
513    ** MOVE '0001000076' TO wa_accountreceivable-customer.   "Customer"
514    * MOVE '0000201525' TO wa_accountreceivable-customer.   "Customer"
515    * MOVE 'ItemTest'   TO wa_accountreceivable-item_text.  "Item Text"
516    * MOVE 'DDN'       TO wa_accountreceivable-comp_code.  "Company Code"
517    * MOVE 'Assign2'    TO wa_accountreceivable-alloc_nmbr. "Assignment.
518    * APPEND wa_accountreceivable TO it_accountreceivable.
519    * MOVE '0000000002' TO wa_currencyamount-itemno_acc.  "Line Item No"
520    * MOVE '00'         TO wa_currencyamount-curr_type.  "Currency Type"
521    * MOVE 'INR'        TO wa_currencyamount-currency.   "Currency"
522    * MOVE doc_amt_dr   TO wa_currencyamount-amt_doccur. "Amount"
523    * APPEND wa_currencyamount TO it_currencyamount.
524    ***Fill Extension1 Structure used by BTE
525    **Posting key is to be changed for only for Customer line item (0000000002)
526    **Records in this internal table will be checked in BTE
527      CLEAR : wa_extension1.
528      MOVE '000000094338' TO wa_extension1-field1.
529    *    MOVE wa_gl-pernr TO wa_extension1-field1.
530      APPEND wa_extension1 TO it_extension1.
531    ** Call Bapi
532    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
533      CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'  "#EC CI_USAGE_OK
534          "#EC CI_USAGE_OK[2628704]
535      "#EC CI_USAGE_OK[2438131]
536
537    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
538        EXPORTING
539          documentheader    = wa_documentheader
540        IMPORTING                                "Comment for >=ECC5.0
541          obj_type          = lv_type             "Comment for >=ECC5.0
542          obj_key           = lv_key              "Comment for >=ECC5.0
543          obj_sys           = lv_sys              "Comment for >=ECC5.0
544        TABLES
545          accountgl         = it_accountgl
546          accountreceivable = it_accountreceivable
547          currencyamount    = it_currencyamount
548          extension1        = it_extension1
549          return            = it_return.
550    ** Check for errors.
551      CLEAR : wa_return.
552
553      READ TABLE it_return INTO wa_return WITH KEY type = 'E'.
554      IF sy-subrc NE 0.
555        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
556      ENDIF.
557    *  endloop.
558    ** display the output
559      LOOP AT it_return INTO wa_return.
560        WRITE :/ wa_return-type,
561                 wa_return-id,
562                 wa_return-number,
563                 wa_return-message.
564      ENDLOOP.
565    ENDFORM.                    " POST_DOCUMENT_BAPI
566    *&---------------------------------------------------------------------*
567    *&      Form  DOWNLOAD_SAMPLE_FILE
568    *&---------------------------------------------------------------------*
569    *       text
570    *----------------------------------------------------------------------*
571    *  -->  p1        text
572    *  <--  p2        text
573    *----------------------------------------------------------------------*
574    FORM DOWNLOAD_SAMPLE_FILE .
575      CLEAR GWA_FIELDNAMES.
576      GWA_FIELDNAMES-TITLE = 'DocumentDate(dd.mm.yyyy)'.
577      APPEND GWA_FIELDNAMES TO GIT_FIELDNAMES.
578
579      CLEAR GWA_FIELDNAMES.
580      GWA_FIELDNAMES-TITLE = 'Document Type (SA)'.
581      APPEND GWA_FIELDNAMES TO GIT_FIELDNAMES.
582
583      CLEAR GWA_FIELDNAMES.
584      GWA_FIELDNAMES-TITLE = 'Comp Code'.
585      APPEND GWA_FIELDNAMES TO GIT_FIELDNAMES.
586
587      CLEAR GWA_FIELDNAMES.
588      GWA_FIELDNAMES-TITLE = 'PostingDate(dd.mm.yyyy)'.
589      APPEND GWA_FIELDNAMES TO GIT_FIELDNAMES.
590
591      """"""""""""""""""""""""""""""""""""
592      "add by lipsy 10.06.2016
593        CLEAR GWA_FIELDNAMES.
594      GWA_FIELDNAMES-TITLE = 'Period'.
595      APPEND GWA_FIELDNAMES TO GIT_FIELDNAMES.
596
597      "eadd by lipsy 10.06.2016
598      """"""""""""""""""""""""""""""""""""
599
600      CLEAR GWA_FIELDNAMES.
601      GWA_FIELDNAMES-TITLE = 'Currency'.
602      APPEND GWA_FIELDNAMES TO GIT_FIELDNAMES.
603
604      CLEAR GWA_FIELDNAMES.
605      GWA_FIELDNAMES-TITLE = 'Header Refernce'.
606      APPEND GWA_FIELDNAMES TO GIT_FIELDNAMES.
607
608      CLEAR GWA_FIELDNAMES.
609      GWA_FIELDNAMES-TITLE = 'Doc Header Text'.
610      APPEND GWA_FIELDNAMES TO GIT_FIELDNAMES.
611
612      CLEAR GWA_FIELDNAMES.
613      GWA_FIELDNAMES-TITLE = 'Posting Key 1'.
614      APPEND GWA_FIELDNAMES TO GIT_FIELDNAMES.
615
616      CLEAR GWA_FIELDNAMES.
617      GWA_FIELDNAMES-TITLE = 'GL Account 1'.
618      APPEND GWA_FIELDNAMES TO GIT_FIELDNAMES.
619
620      CLEAR GWA_FIELDNAMES.
621      GWA_FIELDNAMES-TITLE = 'Sp/GL Indicator 1'.
622      APPEND GWA_FIELDNAMES TO GIT_FIELDNAMES.
623
624      CLEAR GWA_FIELDNAMES.
625      GWA_FIELDNAMES-TITLE = 'Amt for GL Account 1'.
626      APPEND GWA_FIELDNAMES TO GIT_FIELDNAMES.
627
628      CLEAR GWA_FIELDNAMES.
629      GWA_FIELDNAMES-TITLE = 'Business Area 1'.
630      APPEND GWA_FIELDNAMES TO GIT_FIELDNAMES.
631
632      CLEAR GWA_FIELDNAMES.
633      GWA_FIELDNAMES-TITLE = 'Profit Centre 1'.
634      APPEND GWA_FIELDNAMES TO GIT_FIELDNAMES.
635
636      CLEAR GWA_FIELDNAMES.
637      GWA_FIELDNAMES-TITLE = 'Due On 1'.
638      APPEND GWA_FIELDNAMES TO GIT_FIELDNAMES.
639
640      CLEAR GWA_FIELDNAMES.
641      GWA_FIELDNAMES-TITLE = 'Assignment 1'.
642      APPEND GWA_FIELDNAMES TO GIT_FIELDNAMES.
643
644      CLEAR GWA_FIELDNAMES.
645      GWA_FIELDNAMES-TITLE = 'Line Item Text 1'.
646      APPEND GWA_FIELDNAMES TO GIT_FIELDNAMES.
647
648      CLEAR GWA_FIELDNAMES.
649      GWA_FIELDNAMES-TITLE = 'Posting Key2'.
650      APPEND GWA_FIELDNAMES TO GIT_FIELDNAMES.
651
652      CLEAR GWA_FIELDNAMES.
653      GWA_FIELDNAMES-TITLE = 'GL Account2'.
654      APPEND GWA_FIELDNAMES TO GIT_FIELDNAMES.
655
656      CLEAR GWA_FIELDNAMES.
657      GWA_FIELDNAMES-TITLE = 'Sp/GL Indicator2'.
658      APPEND GWA_FIELDNAMES TO GIT_FIELDNAMES.
659
660
661
662
663
664    *Once you are done with it you can call up the save dialog
665    * Display save dialog window
666      CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG
667        EXPORTING
668          WINDOW_TITLE      = 'Save File As...'
669          DEFAULT_EXTENSION = 'XLS'
670          DEFAULT_FILE_NAME = 'format_upload'
671          INITIAL_DIRECTORY = 'C:\'
672        CHANGING
673          FILENAME          = GD_FILENAME
674          PATH              = GD_PATH
675          FULLPATH          = GD_FULLPATH
676          USER_ACTION       = GD_RESULT.
677
678    * Check user did not cancel request
679      CHECK GD_RESULT EQ '0'.
680
681      CALL FUNCTION 'GUI_DOWNLOAD'
682        EXPORTING
683          FILENAME              = GD_FULLPATH
684          FILETYPE              = 'ASC'
685    *     APPEND                = 'X'
686          WRITE_FIELD_SEPARATOR = 'X'
687    *     CONFIRM_OVERWRITE     = 'X'
688        TABLES
689          DATA_TAB              = ist_gl                  " Internal table having data
690          FIELDNAMES            = GIT_FIELDNAMES     " Internal table having headings
691        EXCEPTIONS
692          FILE_OPEN_ERROR       = 1                         "#EC ARGCHECKED
693          FILE_WRITE_ERROR      = 2
694          OTHERS                = 3.
695
696    ENDFORM.                    " DOWNLOAD_SAMPLE_FILE
697    *&---------------------------------------------------------------------*
698    *&      Form  DISPLAY_LOG
699    *&---------------------------------------------------------------------*
700    *       text
701    *----------------------------------------------------------------------*
702    *  -->  p1        text
703    *  <--  p2        text
704    *----------------------------------------------------------------------*
705    FORM DISPLAY_LOG .
706      data : l_message(100).
707      if not it_return_dis[] is INITIAL.
708        LOOP AT it_return_dis INTO wa_return.
709          l_message = wa_return-message.
710          condense l_message.
711          if ( wa_return-id = 'RW' and wa_return-type = 'E' ) .
712          else.
713            WRITE :/ wa_return-type,
714                     wa_return-id,
715                     wa_return-number,
716                     l_message,
717                     wa_return-row.
718          endif.
719        ENDLOOP.
720      endif.
721    ENDFORM.                    " DISPLAY_LOG
722
723    INCLUDE zfi_gl_posting_fin_nonfin_f01.
*--- End of ZFI_GL_POSTING_FIN_NONFIN - 723 lines ---

----------------------------------------------------------------------------------------------------
Include          ZFI_GL_POSTING_FIN_NONFIN_F01             Level 1    Page 2
Object           ZFI_GL_POSTING_FIN_NONFIN                 Lines 371
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:16
----------------------------------------------------------------------------------------------------
1      *----------------------------------------------------------------------*
2      ***INCLUDE ZFI_GL_POSTING_FIN_NONFIN_F01.
3      *----------------------------------------------------------------------*
4      *&---------------------------------------------------------------------*
5      *&      Form  PREPARE_FI_DOCUMENT
6      *&---------------------------------------------------------------------*
7      *       text
8      *----------------------------------------------------------------------*
9      *      <--P_GV_STATUS  text
10     *----------------------------------------------------------------------*
11     FORM prepare_fi_document  CHANGING p_gv_status.
12       DATA : l_gjahr TYPE t009b-bdatj,
13              l_monat TYPE t009b-poper.
14       REFRESH: it_accountpayable,accountpayable, accountreceivable, accountwt,
15                currencyamount, accountgl, return.
16       CLEAR: it_accountpayable,documentheader.
17       CLEAR : l_gjahr,l_monat,g_docdt,g_postdt,g_bline.
18
19       gv_posnr = 0.
20
21
22
23       IF NOT wa_gl-bldat IS INITIAL.
24         CLEAR g_docdt.
25         CALL FUNCTION 'Z_CONVERT_TO_INTERNAL_FORMAT'
26           EXPORTING
27             im_input  = wa_gl-bldat
28           IMPORTING
29             ex_output = g_docdt.
30       ENDIF.
31
32       IF NOT wa_gl-budat IS INITIAL.
33         CLEAR g_postdt.
34         CALL FUNCTION 'Z_CONVERT_TO_INTERNAL_FORMAT'
35           EXPORTING
36             im_input  = wa_gl-budat
37           IMPORTING
38             ex_output = g_postdt.
39       ENDIF.
40
41
42       IF NOT wa_gl-zfbdt IS INITIAL.
43         CLEAR g_bline.
44         CALL FUNCTION 'Z_CONVERT_TO_INTERNAL_FORMAT'
45           EXPORTING
46             im_input  = wa_gl-zfbdt
47           IMPORTING
48             ex_output = g_bline.
49       ENDIF.
50
51       CALL FUNCTION 'DATE_TO_PERIOD_CONVERT'
52         EXPORTING
53           i_date         = g_postdt
54           i_periv        = 'V3'
55         IMPORTING
56           e_gjahr        = l_gjahr
57           e_buper        = l_monat "current Period
58         EXCEPTIONS
59           input_false    = 1
60           t009_notfound  = 2
61           t009b_notfound = 3
62           OTHERS         = 4.
63
64       documentheader-username = sy-uname.
65       documentheader-comp_code = wa_gl-bukrs.
66       documentheader-pstng_date = g_postdt.
67       """""""""""""""""""""""""""""""""""""""""
68       "added by lipsy 10.6.2016
69       documentheader-fis_period = wa_gl-period_new .
70       "eadd by lipsy 10.6.2016
71       """"""""""""""""""""""""""""""""""""""""
72       documentheader-doc_date = g_docdt.
73       documentheader-doc_type = wa_gl-blart.
74       documentheader-header_txt = wa_gl-bktxt.
75       documentheader-ref_doc_no = wa_gl-xblnr .
76
77
78       DATA :g_DC_IND LIKE bseg-shkzg,
79             wa_tbsl  TYPE tbsl.
80
81       SELECT SINGLE * FROM tbsl
82         INTO CORRESPONDING FIELDS OF wa_tbsl
83          WHERE bschl = wa_gl-newbs_1.
84
85       g_DC_IND = wa_tbsl-shkzg.
86       IF g_DC_IND = 'H'.
87         doc_amt_dr = wa_gl-F_dmbtr * -1.
88         g_dmBTr = wa_gl-f_dmbtr * -1.
89       ELSE.
90         doc_amt_cr = wa_gl-F_dmbtr.
91         g_dmBTr = wa_gl-F_dmbtr .
92
93       ENDIF.
94
95       IF wa_tbsl-koart = 'K'.
96     *may have g/l indicator
97       ENDIF.
98       CLEAR: wa_ar, wa_ca.
99       ADD 1 TO gv_posnr.
100      DATA : it_bapiparex TYPE TABLE OF bapiparex,
101             wa_bapiparex TYPE bapiparex.
102
103    *     Populate the Extension table
104      wa_bapiparex-structure  = 'POSTING_KEY'.
105      wa_bapiparex-valuepart1 = gv_posnr.            " Item number
106      wa_bapiparex-valuepart2 = wa_gl-newbs_1.            " Posting Key
107      APPEND wa_bapiparex TO it_bapiparex.
108
109      wa_bapiparex-structure  = 'ZFBDT'.
110      wa_bapiparex-valuepart1 = gv_posnr.            " Item number
111      wa_bapiparex-valuepart2 = g_bline.            " Posting Key
112      APPEND wa_bapiparex TO it_bapiparex.
113
114      IF wa_tbsl-koart = 'K'.
115    *  if not wa_gl-NEWUM_1 is initial.
116    *    WA_AR-ITEMNO_ACC = GV_POSNR.
117    **  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
118    **    EXPORTING
119    **      INPUT  = WA_FINAL-PERNR
120    **    IMPORTING
121    **      OUTPUT = WA_AR-CUSTOMER.
122    *
123    *    WA_AR-CUSTOMER = wa_gl-NEWKO_1.
124    *    WA_AR-BLINE_DATE = SY-DATUM.
125    *    WA_AR-ITEM_TEXT = wa_gl-bktxt.
126    *    WA_AR-REF_KEY_1 = wa_gl-dmbtr.
127    **  WA_AR-REF_KEY_2 = WA_FINAL-ARREARS_PEN.
128    **  WA_AR-REF_KEY_3 = WA_FINAL-TSHORT_EXCESS.
129    *    WA_AR-SP_GL_IND = wa_gl-NEWUM_1.
130    *    APPEND WA_AR TO ACCOUNTRECEIVABLE.
131    *  endif.
132        CLEAR:g_vendor,wa_accountpayable.
133        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
134          EXPORTING
135            input  = wa_gl-newko_1
136          IMPORTING
137            output = g_vendor.
138        wa_accountpayable-vendor_no = g_vendor.
139        wa_accountpayable-itemno_acc = gv_posnr.
140        wa_accountpayable-alloc_nmbr = wa_gl-newko_1.
141    *    concatenate 'line1' '' into
142        wa_accountpayable-item_text = wa_gl-sgtxt.
143        wa_accountpayable-alloc_nmbr = wa_gl-zuonr.
144        wa_accountpayable-comp_code = wa_gl-bukrs.
145    *    wa_accountpayable-SECTIONCODE = p_secco. "'DLI'.
146        wa_accountpayable-bus_area = wa_gl-gsber_1.
147        wa_accountpayable-profit_ctr = wa_gl-prctr_1.
148        wa_accountpayable-sp_gl_ind = wa_gl-newum_1.
149        wa_accountpayable-bline_date = g_bline. "to be reviewed
150        wa_accountpayable-ref_key_1  = wa_gl-newko_1.
151        wa_accountpayable-ref_key_2 = wa_gl-newko_1.
152        wa_accountpayable-ref_key_3 = wa_gl-newko_1.
153        wa_accountpayable-profit_ctr = wa_gl-prctr_1.
154
155        APPEND wa_accountpayable TO it_accountpayable.
156      ENDIF.
157
158      CLEAR: wa_ar, wa_ca.
159      wa_ca-itemno_acc = gv_posnr.
160      wa_ca-currency = 'INR'.
161    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
162    *  wa_ca-amt_doccur = g_dmbtr .      " WA_OTHER-SEP_INT.
163      wa_ca-amt_doccur = CONV #( g_dmbtr )." WA_OTHER-SEP_INT.
164    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
165      APPEND wa_ca TO currencyamount.
166
167    **Fill GL Account Line item 1.
168      CLEAR : wa_accountgl, wa_currencyamount.
169      MOVE gv_posnr TO wa_accountgl-itemno_acc.  "Line Item No"
170      CLEAR l_newko_n.
171      l_newko_n = wa_gl-newko_1.
172      wa_gl-newko_1 = l_newko_n.
173      MOVE wa_gl-newko_1 TO wa_accountgl-gl_account. "G/L Account"
174    *  MOVE '0000100292' TO wa_accountgl-gl_account.  "G/L Account"
175      MOVE wa_gl-sgtxt   TO wa_accountgl-item_text.   "Item Text"
176      MOVE wa_gl-prctr_1 TO wa_accountgl-profit_ctr.  "Profit Center"
177      MOVE wa_gl-gsber_1 TO wa_accountgl-bus_area.  "Business Area"
178      MOVE  wa_gl-zuonr    TO wa_accountgl-alloc_nmbr.  "Assignment"
179      MOVE sy-datum TO wa_accountgl-value_date.
180      APPEND wa_accountgl TO accountgl.
181    **Fill GL Account Line item 1.
182
183      CLEAR: wa_ar, wa_ca.
184      ADD 1 TO gv_posnr.
185
186    *     Populate the Extension table
187      wa_bapiparex-structure  = 'POSTING_KEY'.
188      wa_bapiparex-valuepart1 = gv_posnr.            " Item number
189      wa_bapiparex-valuepart2 = wa_gl-newbs_1.            " Posting Key
190      APPEND wa_bapiparex TO it_bapiparex.
191    *     Populate the Extension table
192      wa_bapiparex-structure  = 'BLINE'.
193      wa_bapiparex-valuepart1 = gv_posnr.            " Item number
194      wa_bapiparex-valuepart2 = sy-datum.            " Posting Key
195      APPEND wa_bapiparex TO it_bapiparex.
196
197      IF NOT wa_gl-zfbdt IS INITIAL.
198        wa_bapiparex-structure  = 'ZFBDT'.
199        wa_bapiparex-valuepart1 = gv_posnr.            " Item number
200        wa_bapiparex-valuepart2 = g_bline.            " Posting Key
201        APPEND wa_bapiparex TO it_bapiparex.
202      ENDIF.
203
204      IF wa_tbsl-koart = 'K'.
205        IF NOT wa_gl-newum_2 IS INITIAL.
206    *      WA_AR-ITEMNO_ACC = GV_POSNR.
207    **  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
208    **    EXPORTING
209    **      INPUT  = WA_FINAL-PERNR
210    **    IMPORTING
211    **      OUTPUT = WA_AR-CUSTOMER.
212    *
213    *      WA_AR-CUSTOMER = wa_gl-NEWKO_2.
214    *      WA_AR-BLINE_DATE = SY-DATUM.
215    *      WA_AR-ITEM_TEXT = wa_gl-bktxt.
216    *      WA_AR-REF_KEY_1 = wa_gl-dmbtr.
217    **  WA_AR-REF_KEY_2 = WA_FINAL-ARREARS_PEN.
218    **  WA_AR-REF_KEY_3 = WA_FINAL-TSHORT_EXCESS.
219    *      WA_AR-SP_GL_IND = wa_gl-NEWUM_2.
220    *      APPEND WA_AR TO ACCOUNTRECEIVABLE.
221          CLEAR:g_vendor, wa_accountpayable.
222          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
223            EXPORTING
224              input  = wa_gl-newko_2
225            IMPORTING
226              output = g_vendor.
227          wa_accountpayable-vendor_no = g_vendor.
228          wa_accountpayable-itemno_acc = gv_posnr.
229
230          wa_accountpayable-comp_code = wa_gl-bukrs.
231    *    wa_accountpayable-SECTIONCODE = p_secco. "'DLI'.
232          wa_accountpayable-bus_area = wa_gl-gsber_1.
233          wa_accountpayable-sp_gl_ind = wa_gl-newum_2.
234
235          wa_accountpayable-item_text = wa_gl-sgtxt.
236          wa_accountpayable-alloc_nmbr = wa_gl-zuonr.
237
238          wa_accountpayable-bline_date = g_bline. "to be reviewed
239          wa_accountpayable-ref_key_1  = wa_gl-newko_2.
240          wa_accountpayable-ref_key_2 = wa_gl-newko_2.
241          wa_accountpayable-ref_key_3 = wa_gl-newko_2.
242          wa_accountpayable-profit_ctr = wa_gl-prctr_1.
243          APPEND wa_accountpayable TO it_accountpayable.
244        ENDIF.
245      ENDIF.
246
247    **Fill GL Account Line item.
248      CLEAR : wa_accountgl, wa_currencyamount.
249      MOVE gv_posnr TO wa_accountgl-itemno_acc.  "Line Item No"
250      CLEAR l_newko_n.
251      l_newko_n = wa_gl-newko_2.
252      wa_gl-newko_2 = l_newko_n.
253      MOVE wa_gl-newko_2 TO wa_accountgl-gl_account.  "G/L Account"
254      MOVE wa_gl-sgtxt   TO wa_accountgl-item_text.   "Item Text"
255      MOVE wa_gl-prctr_1 TO wa_accountgl-profit_ctr.  "Profit Center"
256      MOVE wa_gl-gsber_1 TO wa_accountgl-bus_area.  "Business Area"
257      MOVE  wa_gl-zuonr    TO wa_accountgl-alloc_nmbr.  "Assignment"
258      MOVE sy-datum TO wa_accountgl-value_date.
259      APPEND wa_accountgl TO accountgl.
260
261      CLEAR :g_DC_IND,g_dmBTr,wa_tbsl.
262      SELECT SINGLE * FROM tbsl
263        INTO CORRESPONDING FIELDS OF wa_tbsl
264         WHERE bschl = wa_gl-newbs_2.
265
266      g_DC_IND = wa_tbsl-shkzg.
267      IF g_DC_IND = 'H'.
268        doc_amt_dr = wa_gl-F_dmbtr * -1.
269        g_dmBTr = wa_gl-F_dmbtr * -1.
270      ELSE.
271        doc_amt_cr = wa_gl-F_dmbtr.
272        g_dmBTr = wa_gl-F_dmbtr .
273
274      ENDIF.
275      CLEAR: wa_ar, wa_ca.
276      wa_ca-itemno_acc = gv_posnr.
277      wa_ca-currency = 'INR'.
278    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
279    *  wa_ca-amt_doccur = g_dmbtr .      " WA_OTHER-SEP_INT.
280      wa_ca-amt_doccur = CONV #( g_dmbtr )." WA_OTHER-SEP_INT.
281    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
282      APPEND wa_ca TO currencyamount.
283
284      REFRESH return.
285
286
287
288    ***Fill Currency for Line item 1.
289    **{
290    *      MOVE '0000000001' TO wa_currencyamount-itemno_acc.  "Line Item No"
291    *      MOVE '00'         TO wa_currencyamount-curr_type.  "Currency Type"
292    *      MOVE wa_gl-waers        TO wa_currencyamount-currency.   "Currency"
293    *
294    **      if wa_gl-newbs = '50'.
295    **        MOVE doc_amt_dr   TO wa_currencyamount-amt_doccur. "-ve Amount"
296    **      else.
297    *        MOVE doc_amt_cr   TO wa_currencyamount-amt_doccur. " +  Amount"
298    **      endif.
299    *      APPEND wa_currencyamount TO it_currencyamount.
300    **}}}
301
302
303
304
305
306
307      IF NOT wa_gl-newum_1 IS INITIAL.
308    *     Call the Bapi to post the document
309        " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
310        CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'  "#EC CI_USAGE_OK
311            "#EC CI_USAGE_OK[2628704]
312      "#EC CI_USAGE_OK[2438131]
313
314          " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
315          EXPORTING
316            documentheader = documentheader
317          TABLES
318            accountpayable = it_accountpayable
319    *       accountgl      = ACCOUNTGL
320    *       accountpayable = it_bapiacap09
321            currencyamount = currencyamount
322            return         = it_RETURN
323            extension2     = it_bapiparex.
324
325    *  CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
326    *    EXPORTING
327    *      DOCUMENTHEADER    = DOCUMENTHEADER
328    *    TABLES
329    *      ACCOUNTRECEIVABLE = ACCOUNTRECEIVABLE
330    *      ACCOUNTPAYABLE    = ACCOUNTPAYABLE
331    *      CURRENCYAMOUNT    = CURRENCYAMOUNT
332    *      ACCOUNTWT         = ACCOUNTWT
333    *      ACCOUNTGL          = ACCOUNTGL
334    *      RETURN            = RETURN.
335      ELSE.
336        " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
337        CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'  "#EC CI_USAGE_OK
338            "#EC CI_USAGE_OK[2628704]
339      "#EC CI_USAGE_OK[2438131]
340
341          " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
342          EXPORTING
343            documentheader = documentheader
344          TABLES
345    *       ACCOUNTRECEIVABLE = ACCOUNTRECEIVABLE
346    *       ACCOUNTPAYABLE = ACCOUNTPAYABLE
347            currencyamount = currencyamount
348    *       ACCOUNTWT      = ACCOUNTWT
349            accountgl      = accountgl
350            return         = it_RETURN
351            extension2     = it_bapiparex.
352      ENDIF.
353
354      LOOP AT it_return INTO wa_return.
355    *    WRITE :/ wa_return-type,
356    *             wa_return-id,
357    *             wa_return-number,
358    *             wa_return-message.
359        wa_return-row = g_tabix.
360        APPEND wa_return TO it_return_dis.
361      ENDLOOP.
362      READ TABLE it_return INTO wa_return WITH KEY type = 'E'.
363      IF sy-subrc NE 0.
364        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
365      ENDIF.
366
367      CLEAR   :it_RETURN,documentheader,currencyamount,accountgl,it_bapiparex.
368      REFRESH : it_RETURN,currencyamount,accountgl,it_bapiparex.
369
370    *  COMMIT WORK.
371    ENDFORM.
*--- End of ZFI_GL_POSTING_FIN_NONFIN_F01 - 371 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CABAP                                   Level 1    Page 3
Object           ZFI_GL_POSTING_FIN_NONFIN                 Lines 360
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:16
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
Generated incl.  %_COLE2                                   Level 1    Page 4
Object           ZFI_GL_POSTING_FIN_NONFIN                 Lines 43
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:16
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
Generated incl.  %_CSFES                                   Level 1    Page 5
Object           ZFI_GL_POSTING_FIN_NONFIN                 Lines 75
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:16
----------------------------------------------------------------------------------------------------
1      TYPE-POOL SFES .
2
3      *--table structure definition for mapping xml content after parsing
4
5        TYPES SFES_OBJ_TYPE(32) TYPE C.
6        TYPES:
7          begin of sfes_features_record_type,
8            component(30) type c,
9            featurename(30) type c,
10           value(30) type c,
11       end of sfes_features_record_type.
12       TYPES sfes_features_tab_type type table of sfes_features_record_type with non-unique key component.
13
14
15     CONSTANTS:
16       SFES_OBJ_ACTIVEX
17         TYPE SFES_OBJ_TYPE
18         VALUE 'ACTX',
19       SFES_OBJ_JAVABEANS
20         TYPE SFES_OBJ_TYPE
21         VALUE 'JBEAN',
22       SFES_OBJ_OLE
23         TYPE SFES_OBJ_TYPE
24         VALUE 'OLE',
25       SFES_OBJ_SAP
26         TYPE SFES_OBJ_TYPE
27         VALUE 'SAP',
28       SFES_OBJ_HTML
29         TYPE SFES_OBJ_TYPE
30         VALUE 'HTML'.
31
32     * Constants for GUI_GET_DESKTOP_INFO
33     CONSTANTS:
34       SFES_INFO_SAPDIR
35         TYPE I
36         VALUE -1,
37       SFES_INFO_SAPSYSDIR
38         TYPE I
39         VALUE -2,
40       SFES_INFO_COMPUTER_NAME
41         TYPE I
42         VALUE 1,
43       SFES_INFO_WINDOWS_DIRECTORY
44         TYPE I
45         VALUE 2,
46       SFES_INFO_SYSTEM_DIRECTORY
47         TYPE I
48         VALUE 3,
49       SFES_INFO_TEMP_DIRECTORY
50         TYPE I
51         VALUE 4,
52       SFES_INFO_USER_NAME
53         TYPE I
54         VALUE 5,
55       SFES_INFO_WINDOWS_PLATFORM
56         TYPE I
57         VALUE 6,
58       SFES_INFO_WINDOWS_BUILDNO
59         TYPE I
60         VALUE 7,
61       SFES_INFO_WINDOWS_VERSION
62         TYPE I
63         VALUE 8,
64       SFES_INFO_PROGRAM_NAME
65         TYPE I
66         VALUE 9,
67       SFES_INFO_PROGRAM_PATH
68         TYPE I
69         VALUE 10,
70       SFES_INFO_CURRENT_DIRECTORY
71         TYPE I
72         VALUE 11,
73       SFES_INFO_DESKTOP_DIRECTORY
74         TYPE I
75         VALUE 12.
*--- End of %_CSFES - 75 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  <REPINI>                                  Level 1    Page 6
Object           ZFI_GL_POSTING_FIN_NONFIN                 Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:16
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
Object           ZFI_GL_POSTING_FIN_NONFIN                 Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:16
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
Object           ZFI_GL_POSTING_FIN_NONFIN                 Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:16
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
Generated incl.  DB__SSEL                                  Level 1    Page 9
Object           ZFI_GL_POSTING_FIN_NONFIN                 Lines 1
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:16
----------------------------------------------------------------------------------------------------
1      * INCLUDE DB__SSEL
*--- End of DB__SSEL - 1 lines ---
