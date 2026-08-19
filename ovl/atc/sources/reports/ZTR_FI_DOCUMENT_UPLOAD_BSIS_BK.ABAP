----------------------------------------------------------------------------------------------------
Main program     ZTR_FI_DOCUMENT_UPLOAD_BSIS_BK            Level 0    Page 1
Object           ZTR_FI_DOCUMENT_UPLOAD_BSIS_BK            Lines 438
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:19
----------------------------------------------------------------------------------------------------
1      REPORT  ztr_fi_document_upload_bsis_bk NO STANDARD PAGE HEADING.
2      *&--------------------------------------------------------------------*
3      * Report     : ZTR_FI_DOCUMENT_UPLOAD_BSIS                            *
4      *                                                                     *
5      * Title      : FI Document Upload(GL ACCOUNT)                         *
6      *                                                                     *
7      * FS No.     : NA                                                     *
8      *                                                                     *
9      * Author     : Gurpreet Singh                                         *
10     *                                                                      *
11     * Login Id   : SAB_ANAND                                              *
12     *                                                                     *
13     * Start date : 18th July 2009                                         *
14     *                                                                     *
15     * Description: Report to Upload FI Documents from Older Trust system  *
16     *                                                                     *
17     * Tran. Code : N/A                                                    *
18     *&--------------------------------------------------------------------*
19
20     *---------------------------------------------------------------------*
21     *               Data Decelaration part.                               *
22     *---------------------------------------------------------------------*
23     TYPES:
24          BEGIN OF ty_bsis,
25             bukrs TYPE bsis-bukrs,
26             hkont TYPE bsis-hkont,
27             zuonr TYPE bsis-zuonr,
28             gjahr TYPE bsis-gjahr,
29             belnr TYPE bsis-belnr,
30             budat TYPE bsis-budat,
31             bldat TYPE bsis-bldat,
32             waers TYPE bsis-waers,
33             blart TYPE bsis-blart,
34             dmbtr TYPE bsis-dmbtr,
35             shkzg  TYPE bsis-shkzg,
36             sgtxt TYPE bsis-sgtxt,
37           END OF ty_bsis.
38     DATA: fs_bsis TYPE ty_bsis.
39     DATA: it_bsis LIKE
40           STANDARD TABLE
41              OF fs_bsis.
42     DATA: w_index TYPE i.
43     ** field string & Tables for bapi....................................
44     DATA: fs_docu_headr TYPE bapiache09,
45           fs_amt        TYPE bapiaccr09,
46           fs_acctgl     TYPE bapiacgl09,
47           fs_acct_rec   TYPE bapiacar09.
48     DATA: it_amt TYPE
49                 TABLE OF bapiaccr09,
50           it_acctgl TYPE
51                 TABLE OF bapiacgl09,
52           it_acct_rec TYPE
53                 TABLE OF bapiacar09.
54     DATA:w_itemno(10) TYPE n VALUE 1.
55     **** Dulicate Entries check Field string & Internal Table..................
56     **DATA: BEGIN OF fs_glacct_check,
57     **        bukrs TYPE bsis-bukrs,
58     **        hkont TYPE bsis-hkont,
59     **         bldat TYPE bsis-bldat,
60     **        xref3 TYPE bsis-xref3,
61     **      END OF fs_glacct_check.
62     **DATA: it_glacct_check LIKE
63     **            STANDARD TABLE
64     **                  OF fs_glacct_check,
65     **      w_refkey3 TYPE bsis-xref3.
66     ** Selection-screen block.............................................
67     SELECT-OPTIONS: s_hkont FOR fs_bsis-hkont,
68                     s_date FOR sy-datum.
69     PARAMETERS:
70       p_bukrs TYPE bukrs,
71       p_xopvw TYPE xopvw AS CHECKBOX DEFAULT 'X',
72       p_dest TYPE rfcdest OBLIGATORY DEFAULT 'TRUST_RFC_PRD'.
73
74     *---------------------------------------------------------------------*
75     *   START-OF-SELECTION Block.                                         *
76     *---------------------------------------------------------------------*
77     START-OF-SELECTION.
78     ** Fetching data upload from older trust system(4.7)...................
79       CALL FUNCTION 'ZTRFI_GET' DESTINATION p_dest
80         EXPORTING
81           p_bukrs = p_bukrs
82           p_xopvw = p_xopvw
83         TABLES
84           s_hkont = s_hkont
85           it_bsis = it_bsis.
86     ** Fetch posted documents for duplicate check.........................
87     *  SELECT bukrs
88     *         hkont
89     *         bldat
90     *         xref3
91     *         FROM bsis
92     *         INTO TABLE it_glacct_check
93     *         WHERE bukrs EQ p_bukrs
94     *         AND hkont IN s_hkont
95     *         AND bldat IN s_date.
96     ** Get the no of records in a table...................................
97       DESCRIBE TABLE it_bsis LINES w_index.
98     ** Sort by GL Account.................................................
99       SORT it_bsis BY hkont.
100
101      DELETE it_bsis WHERE budat NOT IN s_date.
102    ** Upload data........................................................
103      LOOP AT it_bsis INTO fs_bsis.
104    *    CONCATENATE fs_bsis-gjahr '-' fs_bsis-belnr
105    *                               INTO w_refkey3.
106    *    READ TABLE it_glacct_check INTO fs_glacct_check
107    *                               WITH KEY bldat = fs_bsis-budat.
108    *    IF sy-subrc NE 0.
109          IF p_xopvw EQ 'X'.
110            PERFORM upload_fi_documents.     " Open Item Managed
111          ELSE.
112            PERFORM upload_fi_document_n.    " Open Item not Managed
113          ENDIF.
114    *    ENDIF.
115      ENDLOOP.
116    *&---------------------------------------------------------------------*
117    *&      Form  UPLOAD_FI_DOCUMENTS
118    *&---------------------------------------------------------------------*
119    *   Subroutine to upload data BAPI Structures.
120    *----------------------------------------------------------------------*
121    *  No interface parameters passed.
122    *----------------------------------------------------------------------*
123    FORM upload_fi_documents .
124    ** Update header structure for bapi.....................................
125      fs_docu_headr-username = sy-uname.
126      fs_docu_headr-header_txt = 'INITIAL DATA UPLOAD'.
127      fs_docu_headr-comp_code = p_bukrs.
128      fs_docu_headr-doc_date =   fs_bsis-budat.
129      fs_docu_headr-pstng_date = '20090731'.
130    *    fs_docu_headr-trans_date = '20090731'.
131    *    fs_docu_headr-fisc_year = '2009'.
132      fs_docu_headr-doc_type = 'IB'.
133    ** Fill bapi interface tables.........................................
134    ** 1st Line Item.................
135      IF fs_bsis-shkzg EQ 'H'.
136        fs_bsis-dmbtr =  ( -1 )  * fs_bsis-dmbtr.
137      ENDIF.
138      CLEAR fs_amt.
139      fs_amt-itemno_acc  = '0000000001'.
140      fs_amt-currency    = 'INR'.
141    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
142    *  fs_amt-amt_doccur  = fs_bsis-dmbtr.
143      fs_amt-amt_doccur = CONV #( fs_bsis-dmbtr ).
144    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
145      APPEND fs_amt TO it_amt.
146    ** 2nd Line Item.................
147      fs_bsis-dmbtr =  ( -1 )  * fs_bsis-dmbtr.
148      CLEAR fs_amt.
149      fs_amt-itemno_acc  = '0000000002'.
150      fs_amt-currency    = 'INR'.
151    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
152    *  fs_amt-amt_doccur  = fs_bsis-dmbtr.
153      fs_amt-amt_doccur = CONV #( fs_bsis-dmbtr ).
154    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
155      APPEND fs_amt TO it_amt.
156
157    ** Update Account gl details table....................................
158    ** 1st Line Item.................
159      CLEAR fs_acctgl.
160      fs_acctgl-itemno_acc = '0000000002'.
161      fs_acctgl-gl_account = '0000990001'.
162      fs_acctgl-item_text = 'Closing Balance as on 31.07.2009'.
163      fs_acctgl-comp_code = p_bukrs.
164      fs_acctgl-alloc_nmbr = fs_bsis-zuonr.
165    ** Update Assignment allocation field.................................
166      CONCATENATE fs_bsis-gjahr '-' fs_bsis-belnr
167                                    INTO fs_acctgl-ref_key_3.
168      fs_acctgl-ref_key_2 = fs_bsis-bukrs.
169      APPEND fs_acctgl TO it_acctgl.
170      CLEAR fs_acctgl.
171    ** 2nd Line Item.................
172      fs_acctgl-itemno_acc = '0000000001'.
173      fs_acctgl-gl_account = fs_bsis-hkont.
174      fs_acctgl-item_text = fs_bsis-sgtxt.
175      fs_acctgl-comp_code = p_bukrs.
176    ** Update Assignment allocation field.................................
177      CONCATENATE fs_bsis-gjahr '-' fs_bsis-belnr
178                                    INTO fs_acctgl-ref_key_3.
179      fs_acctgl-ref_key_2 = fs_bsis-bukrs.
180      APPEND fs_acctgl TO it_acctgl.
181      PERFORM bapi_fi_docu_call .
182
183    ENDFORM.                    " UPLOAD_FI_DOCUMENTS
184    *&---------------------------------------------------------------------*
185    *&      Form  BAPI_FI_DOCU_CALL
186    *&---------------------------------------------------------------------*
187    *       text
188    *----------------------------------------------------------------------*
189    *  No interface parameter passed.
190    *----------------------------------------------------------------------*
191    FORM bapi_fi_docu_call .
192
193      DATA: it_bapiret2 TYPE
194                     TABLE OF bapiret2,
195            fs_bapiret2 TYPE bapiret2.
196      CLEAR it_bapiret2.
197      SORT it_amt BY itemno_acc.
198    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
199      CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'  "#EC CI_USAGE_OK
200        "#EC CI_USAGE_OK[2628704]
201      "#EC CI_USAGE_OK[2438131]
202    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
203        EXPORTING
204          documentheader          = fs_docu_headr
205    *   CUSTOMERCPD             =
206    *   CONTRACTHEADER          =
207    * IMPORTING
208    *   OBJ_TYPE                =
209    *   OBJ_KEY                 =
210    *   OBJ_SYS                 =
211        TABLES
212         accountgl               = it_acctgl
213    *     accountreceivable       = it_acct_rec
214    *   ACCOUNTPAYABLE          =
215    *   ACCOUNTTAX              =
216          currencyamount          = it_amt
217    *   CRITERIA                =
218    *   VALUEFIELD              =
219    *   EXTENSION1              =
220          return                  = it_bapiret2
221    *   PAYMENTCARD             =
222    *   CONTRACTITEM            =
223    *   EXTENSION2              =
224    *   REALESTATE              =
225    *   ACCOUNTWT               =
226                .
227
228      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
229       EXPORTING
230         wait          = 'X'
231    * IMPORTING
232    *   RETURN        =
233                .
234    ** Bapi return message.................................................
235      READ TABLE it_bapiret2 INTO fs_bapiret2 WITH KEY type = 'E'.
236      IF sy-subrc EQ 0.
237        READ TABLE it_bapiret2 INTO fs_bapiret2 INDEX 2.
238        WRITE:/ ' Could not be uploaded',
239                 fs_bapiret2-message.
240        ULINE.
241      ELSE.
242        READ TABLE it_bapiret2 INTO fs_bapiret2 INDEX 1.
243        WRITE:/ fs_bapiret2-message.
244        ULINE.
245      ENDIF.
246      CLEAR:
247            fs_docu_headr,
248             it_acctgl,
249             it_amt,
250              it_bapiret2.
251    ENDFORM.                               " BAPI_FI_DOCU_CALL
252    *&---------------------------------------------------------------------*
253    *&      Form  BAPI_INTRFACE_TAB_FILL
254    *&---------------------------------------------------------------------*
255    *  Subroutine to fill bapi table.
256    *----------------------------------------------------------------------*
257    *  No interface parameters passed.
258    *----------------------------------------------------------------------*
259    *FORM bapi_intrface_tab_fill USING fs_bsis TYPE ty_bsis .
260    *  ADD 1 TO w_itemno.
261    *  CLEAR fs_acct_rec.
262    *  fs_acct_rec-itemno_acc = w_itemno.
263    *  fs_acct_rec-customer = fs_bsis-kunnr.
264    **  fs_acct_rec-gl_account = fs_BSIS-hkont.
265    *  fs_acct_rec-comp_code = p_bukrs.
266    *  fs_acct_rec-sp_gl_ind = fs_bsis-umskz.
267    *  fs_acct_rec-item_text = fs_bsis-sgtxt.
268    *** Get fisical year...................................................
269    *  IF fs_bsis-budat+4(2) LT 4.
270    *    fs_bsis-budat+0(4) = fs_bsis-budat+0(4) - 1.
271    *  ENDIF.
272    *** Update Assignment allocation field.................................
273    *  CONCATENATE fs_bsis-belnr fs_bsis-bukrs fs_bsis-budat+0(4)
274    *                                   INTO fs_acct_rec-alloc_nmbr.
275    *** New Sp.GL Indicators changes.......................................
276    *  CASE  fs_bsis-umskz.
277    *    WHEN 'J'.
278    *      fs_acct_rec-sp_gl_ind = '+'.
279    *    WHEN 'K'.
280    *      fs_acct_rec-sp_gl_ind = '*'.
281    *    WHEN 'L'.
282    *      fs_acct_rec-sp_gl_ind = '/'.
283    *    WHEN 'S'.
284    *      fs_acct_rec-sp_gl_ind = '-'.
285    *    WHEN 'B'.
286    *      fs_acct_rec-sp_gl_ind = '8'.
287    *    WHEN 'C'.
288    *      fs_acct_rec-sp_gl_ind = '9'.
289    *    WHEN OTHERS.
290    *      fs_acct_rec-sp_gl_ind = fs_bsis-umskz.
291    *  ENDCASE.
292    *
293    *  APPEND fs_acct_rec TO it_acct_rec.
294    *** Update amount table for bapi......................................
295    *  CLEAR fs_amt.
296    *  fs_amt-itemno_acc  = w_itemno.
297    *  fs_amt-currency    = 'INR'.
298    *  fs_amt-amt_doccur  = fs_bsis-dmbtr.
299    *  fs_amt-amt_base    = fs_bsis-skfbt.
300    *  fs_amt-disc_base   = fs_bsis-sknto .
301    *  fs_amt-disc_amt    = fs_bsis-wskto.
302    *  APPEND fs_amt TO it_amt.
303    *ENDFORM.                               " BAPI_INTRFACE_TAB_FILL
304    *&---------------------------------------------------------------------*
305    *&      Form  UPLOAD_FI_DOCUMENT_N
306    *&---------------------------------------------------------------------*
307    *       text
308    *----------------------------------------------------------------------*
309    * No interface parameter passed.
310    *----------------------------------------------------------------------*
311    FORM upload_fi_document_n .
312    *  STATICS:w_credit TYPE dmbtr,
313    *        w_debit TYPE dmbtr,
314    *        w_hkont TYPE hkont.
315
316      SUBTRACT 1 FROM w_index.
317    *  CASE fs_bsis-shkzg.
318    *    WHEN 'H'.
319    *      fs_bsis-dmbtr =  ( -1 )  * fs_bsis-dmbtr.
320    *      w_credit = w_credit + fs_bsis-dmbtr.
321    *    WHEN 'S'.
322    *      w_debit = w_debit + fs_bsis-dmbtr.
323    *  ENDCASE.
324    *  IF fs_bsis-hkont NE w_hkont
325    *    AND sy-tabix GT 1.
326    *    fs_bsis-dmbtr =  w_credit + w_debit.
327      PERFORM get_account_gl_sum CHANGING fs_bsis-dmbtr.
328    *    CLEAR:  w_credit,
329    *            w_debit.
330      IF NOT fs_bsis-dmbtr IS INITIAL.
331        PERFORM upload_fi_docu_gl.
332      ENDIF.
333    *  ELSEIF w_index EQ 0.
334    **    fs_bsis-dmbtr =  w_credit + w_debit.
335    **    CLEAR: w_credit,
336    **           w_debit.
337    *    PERFORM get_account_gl_sum CHANGING fs_bsis-dmbtr.
338    *    PERFORM upload_fi_docu_gl.
339    *  ENDIF.
340    *  MOVE fs_bsis-hkont TO w_hkont.
341    ENDFORM.                             " UPLOAD_FI_DOCUMENT_N
342    *&---------------------------------------------------------------------*
343    *&      Form  UPLOAD_FI_DOCU_GL
344    *&---------------------------------------------------------------------*
345    *       text
346    *----------------------------------------------------------------------*
347    *  No interface parameter passed.
348    *----------------------------------------------------------------------*
349    FORM upload_fi_docu_gl .
350    ** Update header structure for bapi.....................................
351      fs_docu_headr-username = sy-uname.
352      fs_docu_headr-header_txt = 'INITIAL DATA UPLOAD'.
353      fs_docu_headr-comp_code = p_bukrs.
354      fs_docu_headr-doc_date =   '20090731'.       " Changed
355      fs_docu_headr-pstng_date = '20090731'.       " Changed
356    *    fs_docu_headr-trans_date = '20090731'.
357    *    fs_docu_headr-fisc_year = '2009'.
358      fs_docu_headr-doc_type = 'IB'.
359    ** Fill bapi interface tables.........................................
360    ** 1st Line Item.................
361      CLEAR fs_amt.
362      fs_amt-itemno_acc  = '0000000001'.
363      fs_amt-currency    = 'INR'.
364    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
365    *  fs_amt-amt_doccur  = fs_bsis-dmbtr.
366      fs_amt-amt_doccur = CONV #( fs_bsis-dmbtr ).
367    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
368      APPEND fs_amt TO it_amt.
369    ** 2nd Line Item.................
370      fs_bsis-dmbtr =  ( -1 )  * fs_bsis-dmbtr.
371      CLEAR fs_amt.
372      fs_amt-itemno_acc  = '0000000002'.
373      fs_amt-currency    = 'INR'.
374    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
375    *  fs_amt-amt_doccur  = fs_bsis-dmbtr.
376      fs_amt-amt_doccur = CONV #( fs_bsis-dmbtr ).
377    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
378      APPEND fs_amt TO it_amt.
379
380    ** Update Account gl details table....................................
381    ** 1st Line Item.................
382      CLEAR fs_acctgl.
383      fs_acctgl-itemno_acc = '0000000002'.
384      fs_acctgl-gl_account = '0000990001'.
385      fs_acctgl-item_text = 'INITIAL DATA UPLOAD'.
386      fs_acctgl-comp_code = p_bukrs.
387    ** Update Assignment allocation field.................................
388      IF p_xopvw EQ 'X'.
389        CONCATENATE fs_bsis-belnr '-'  fs_bsis-gjahr
390                                         INTO fs_acctgl-ref_key_3.
391        fs_acctgl-ref_key_2 = fs_bsis-bukrs.
392      ENDIF.
393      APPEND fs_acctgl TO it_acctgl.
394      CLEAR fs_acctgl.
395    ** 2nd Line Item.................
396      fs_acctgl-itemno_acc = '0000000001'.
397      fs_acctgl-gl_account = fs_bsis-hkont.
398      fs_acctgl-item_text = 'INITIAL DATA UPLOAD'.
399      fs_acctgl-comp_code = p_bukrs.
400    ** Update Assignment allocation field.................................
401      IF p_xopvw EQ 'X'.
402        CONCATENATE fs_bsis-belnr '-'  fs_bsis-gjahr
403                                         INTO fs_acctgl-ref_key_3.
404        fs_acctgl-ref_key_2 = fs_bsis-bukrs.
405      ENDIF.
406      APPEND fs_acctgl TO it_acctgl.
407      PERFORM bapi_fi_docu_call .
408    ENDFORM.                    " UPLOAD_FI_DOCU_GL
409    *&---------------------------------------------------------------------*
410    *&      Form  GET_ACCOUNT_GL_SUM
411    *&---------------------------------------------------------------------*
412    *       text
413    *----------------------------------------------------------------------*
414    *  -->  p1        text
415    *  <--  p2        text
416    *----------------------------------------------------------------------*
417    FORM get_account_gl_sum CHANGING p_amount.
418      DATA:fs_bapiret2 TYPE  bapireturn.
419      DATA: fs_bapi1028 TYPE bapi1028_3.
420
421    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
422      CALL FUNCTION 'BAPI_GL_GETGLACCBALANCE' DESTINATION p_dest"#EC CI_USAGE_OK[2628704]
423    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
424        EXPORTING
425          companycode     = p_bukrs
426          glacct          = fs_bsis-hkont
427          fiscalyear      = '2009'       " Changed
428          currencytype    = '10'
429        IMPORTING
430          account_balance = fs_bapi1028
431          return          = fs_bapiret2.
432
433      IF fs_bapiret2-type EQ 'E'.
434        WRITE:/ fs_bapiret2-message.
435      ELSE.
436        p_amount = fs_bapi1028-balance.
437      ENDIF.
438    ENDFORM.                    " GET_ACCOUNT_GL_SUM
*--- End of ZTR_FI_DOCUMENT_UPLOAD_BSIS_BK - 438 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  <REPINI>                                  Level 1    Page 2
Object           ZTR_FI_DOCUMENT_UPLOAD_BSIS_BK            Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:19
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
Generated incl.  <SYSINI>                                  Level 1    Page 3
Object           ZTR_FI_DOCUMENT_UPLOAD_BSIS_BK            Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:19
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
Generated incl.  <SYSSEL>                                  Level 1    Page 4
Object           ZTR_FI_DOCUMENT_UPLOAD_BSIS_BK            Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:19
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
Generated incl.  DB__SSEL                                  Level 1    Page 5
Object           ZTR_FI_DOCUMENT_UPLOAD_BSIS_BK            Lines 1
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:19
----------------------------------------------------------------------------------------------------
1      * INCLUDE DB__SSEL
*--- End of DB__SSEL - 1 lines ---
