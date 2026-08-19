----------------------------------------------------------------------------------------------------
Main program     ZTR_FI_DOCUMENT_UPLOAD_BSIS               Level 0    Page 1
Object           ZTR_FI_DOCUMENT_UPLOAD_BSIS               Lines 409
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:18
----------------------------------------------------------------------------------------------------
1      REPORT  ztr_fi_document_upload_bsis NO STANDARD PAGE HEADING.
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
55     ** Selection-screen block.............................................
56     SELECT-OPTIONS: s_hkont FOR fs_bsis-hkont.
57     PARAMETERS:
58       p_bukrs TYPE bukrs,
59       p_xopvw TYPE xopvw AS CHECKBOX DEFAULT 'X',
60       p_dest TYPE rfcdest OBLIGATORY DEFAULT 'TRUST_RFC_PRD'.
61
62     *---------------------------------------------------------------------*
63     *   START-OF-SELECTION Block.                                         *
64     *---------------------------------------------------------------------*
65     START-OF-SELECTION.
66     ** Fetching data upload from older trust system(4.7)...................
67       CALL FUNCTION 'ZTRFI_GET' DESTINATION p_dest
68         EXPORTING
69           p_bukrs = p_bukrs
70           p_xopvw = p_xopvw
71         TABLES
72           s_hkont = s_hkont
73           it_bsis = it_bsis.
74
75     ** Get the no of records in a table...................................
76       DESCRIBE TABLE it_bsis LINES w_index.
77     ** Sort by GL Account.................................................
78       SORT it_bsis BY hkont.
79     ** Upload data........................................................
80       LOOP AT it_bsis INTO fs_bsis.
81         IF p_xopvw EQ 'X'.
82           PERFORM upload_fi_documents.     " Open Item Managed
83         ELSE.
84           PERFORM upload_fi_document_n.    " Open Item not Managed
85         ENDIF.
86       ENDLOOP.
87     *&---------------------------------------------------------------------*
88     *&      Form  UPLOAD_FI_DOCUMENTS
89     *&---------------------------------------------------------------------*
90     *   Subroutine to upload data BAPI Structures.
91     *----------------------------------------------------------------------*
92     *  No interface parameters passed.
93     *----------------------------------------------------------------------*
94     FORM upload_fi_documents .
95     ** Update header structure for bapi.....................................
96       fs_docu_headr-username = sy-uname.
97       fs_docu_headr-header_txt = 'INITIAL DATA UPLOAD'.
98       fs_docu_headr-comp_code = p_bukrs.
99       fs_docu_headr-doc_date =   fs_bsis-budat.
100      fs_docu_headr-pstng_date = '20090731'.
101    *    fs_docu_headr-trans_date = '20090731'.
102    *    fs_docu_headr-fisc_year = '2009'.
103      fs_docu_headr-doc_type = 'IB'.
104    ** Fill bapi interface tables.........................................
105    ** 1st Line Item.................
106      IF fs_bsis-shkzg EQ 'H'.
107        fs_bsis-dmbtr =  ( -1 )  * fs_bsis-dmbtr.
108      ENDIF.
109      CLEAR fs_amt.
110      fs_amt-itemno_acc  = '0000000001'.
111      fs_amt-currency    = 'INR'.
112    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
113    *  fs_amt-amt_doccur  = fs_bsis-dmbtr.
114      fs_amt-amt_doccur = CONV #( fs_bsis-dmbtr ).
115    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
116      APPEND fs_amt TO it_amt.
117    ** 2nd Line Item.................
118      fs_bsis-dmbtr =  ( -1 )  * fs_bsis-dmbtr.
119      CLEAR fs_amt.
120      fs_amt-itemno_acc  = '0000000002'.
121      fs_amt-currency    = 'INR'.
122    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
123    *  fs_amt-amt_doccur  = fs_bsis-dmbtr.
124      fs_amt-amt_doccur = CONV #( fs_bsis-dmbtr ).
125    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
126      APPEND fs_amt TO it_amt.
127
128    ** Update Account gl details table....................................
129    ** 1st Line Item.................
130      CLEAR fs_acctgl.
131      fs_acctgl-itemno_acc = '0000000002'.
132      fs_acctgl-gl_account = '0000990001'.
133      fs_acctgl-item_text = 'Closing Balance as on 31.07.2009'.
134      fs_acctgl-comp_code = p_bukrs.
135      fs_acctgl-alloc_nmbr = fs_bsis-zuonr.
136    ** Update Assignment allocation field.................................
137      CONCATENATE fs_bsis-gjahr '-' fs_bsis-belnr
138                                    INTO fs_acctgl-ref_key_3.
139      fs_acctgl-ref_key_2 = fs_bsis-bukrs.
140      APPEND fs_acctgl TO it_acctgl.
141      CLEAR fs_acctgl.
142    ** 2nd Line Item.................
143      fs_acctgl-itemno_acc = '0000000001'.
144      fs_acctgl-gl_account = fs_bsis-hkont.
145      fs_acctgl-item_text = fs_bsis-sgtxt.
146      fs_acctgl-comp_code = p_bukrs.
147    ** Update Assignment allocation field.................................
148      CONCATENATE fs_bsis-gjahr '-' fs_bsis-belnr
149                                    INTO fs_acctgl-ref_key_3.
150      fs_acctgl-ref_key_2 = fs_bsis-bukrs.
151      APPEND fs_acctgl TO it_acctgl.
152      PERFORM bapi_fi_docu_call .
153
154    ENDFORM.                    " UPLOAD_FI_DOCUMENTS
155    *&---------------------------------------------------------------------*
156    *&      Form  BAPI_FI_DOCU_CALL
157    *&---------------------------------------------------------------------*
158    *       text
159    *----------------------------------------------------------------------*
160    *  No interface parameter passed.
161    *----------------------------------------------------------------------*
162    FORM bapi_fi_docu_call .
163
164      DATA: it_bapiret2 TYPE
165                     TABLE OF bapiret2,
166            fs_bapiret2 TYPE bapiret2.
167      CLEAR it_bapiret2.
168      SORT it_amt BY itemno_acc.
169    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
170      CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'  "#EC CI_USAGE_OK
171        "#EC CI_USAGE_OK[2628704]
172      "#EC CI_USAGE_OK[2438131]
173    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
174        EXPORTING
175          documentheader          = fs_docu_headr
176    *   CUSTOMERCPD             =
177    *   CONTRACTHEADER          =
178    * IMPORTING
179    *   OBJ_TYPE                =
180    *   OBJ_KEY                 =
181    *   OBJ_SYS                 =
182        TABLES
183         accountgl               = it_acctgl
184    *     accountreceivable       = it_acct_rec
185    *   ACCOUNTPAYABLE          =
186    *   ACCOUNTTAX              =
187          currencyamount          = it_amt
188    *   CRITERIA                =
189    *   VALUEFIELD              =
190    *   EXTENSION1              =
191          return                  = it_bapiret2
192    *   PAYMENTCARD             =
193    *   CONTRACTITEM            =
194    *   EXTENSION2              =
195    *   REALESTATE              =
196    *   ACCOUNTWT               =
197                .
198
199      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
200       EXPORTING
201         wait          = 'X'
202    * IMPORTING
203    *   RETURN        =
204                .
205    ** Bapi return message.................................................
206      READ TABLE it_bapiret2 INTO fs_bapiret2 WITH KEY type = 'E'.
207      IF sy-subrc EQ 0.
208        READ TABLE it_bapiret2 INTO fs_bapiret2 INDEX 2.
209        WRITE:/ ' Could not be uploaded',
210                 fs_bapiret2-message.
211        ULINE.
212      ELSE.
213        READ TABLE it_bapiret2 INTO fs_bapiret2 INDEX 1.
214        WRITE:/ fs_bapiret2-message.
215        ULINE.
216      ENDIF.
217      CLEAR:
218            fs_docu_headr,
219             it_acctgl,
220             it_amt,
221              it_bapiret2.
222    ENDFORM.                               " BAPI_FI_DOCU_CALL
223    *&---------------------------------------------------------------------*
224    *&      Form  BAPI_INTRFACE_TAB_FILL
225    *&---------------------------------------------------------------------*
226    *  Subroutine to fill bapi table.
227    *----------------------------------------------------------------------*
228    *  No interface parameters passed.
229    *----------------------------------------------------------------------*
230    *FORM bapi_intrface_tab_fill USING fs_bsis TYPE ty_bsis .
231    *  ADD 1 TO w_itemno.
232    *  CLEAR fs_acct_rec.
233    *  fs_acct_rec-itemno_acc = w_itemno.
234    *  fs_acct_rec-customer = fs_bsis-kunnr.
235    **  fs_acct_rec-gl_account = fs_BSIS-hkont.
236    *  fs_acct_rec-comp_code = p_bukrs.
237    *  fs_acct_rec-sp_gl_ind = fs_bsis-umskz.
238    *  fs_acct_rec-item_text = fs_bsis-sgtxt.
239    *** Get fisical year...................................................
240    *  IF fs_bsis-budat+4(2) LT 4.
241    *    fs_bsis-budat+0(4) = fs_bsis-budat+0(4) - 1.
242    *  ENDIF.
243    *** Update Assignment allocation field.................................
244    *  CONCATENATE fs_bsis-belnr fs_bsis-bukrs fs_bsis-budat+0(4)
245    *                                   INTO fs_acct_rec-alloc_nmbr.
246    *** New Sp.GL Indicators changes.......................................
247    *  CASE  fs_bsis-umskz.
248    *    WHEN 'J'.
249    *      fs_acct_rec-sp_gl_ind = '+'.
250    *    WHEN 'K'.
251    *      fs_acct_rec-sp_gl_ind = '*'.
252    *    WHEN 'L'.
253    *      fs_acct_rec-sp_gl_ind = '/'.
254    *    WHEN 'S'.
255    *      fs_acct_rec-sp_gl_ind = '-'.
256    *    WHEN 'B'.
257    *      fs_acct_rec-sp_gl_ind = '8'.
258    *    WHEN 'C'.
259    *      fs_acct_rec-sp_gl_ind = '9'.
260    *    WHEN OTHERS.
261    *      fs_acct_rec-sp_gl_ind = fs_bsis-umskz.
262    *  ENDCASE.
263    *
264    *  APPEND fs_acct_rec TO it_acct_rec.
265    *** Update amount table for bapi......................................
266    *  CLEAR fs_amt.
267    *  fs_amt-itemno_acc  = w_itemno.
268    *  fs_amt-currency    = 'INR'.
269    *  fs_amt-amt_doccur  = fs_bsis-dmbtr.
270    *  fs_amt-amt_base    = fs_bsis-skfbt.
271    *  fs_amt-disc_base   = fs_bsis-sknto .
272    *  fs_amt-disc_amt    = fs_bsis-wskto.
273    *  APPEND fs_amt TO it_amt.
274    *ENDFORM.                               " BAPI_INTRFACE_TAB_FILL
275    *&---------------------------------------------------------------------*
276    *&      Form  UPLOAD_FI_DOCUMENT_N
277    *&---------------------------------------------------------------------*
278    *       text
279    *----------------------------------------------------------------------*
280    * No interface parameter passed.
281    *----------------------------------------------------------------------*
282    FORM upload_fi_document_n .
283    *  STATICS:w_credit TYPE dmbtr,
284    *        w_debit TYPE dmbtr,
285    *        w_hkont TYPE hkont.
286
287      SUBTRACT 1 FROM w_index.
288    *  CASE fs_bsis-shkzg.
289    *    WHEN 'H'.
290    *      fs_bsis-dmbtr =  ( -1 )  * fs_bsis-dmbtr.
291    *      w_credit = w_credit + fs_bsis-dmbtr.
292    *    WHEN 'S'.
293    *      w_debit = w_debit + fs_bsis-dmbtr.
294    *  ENDCASE.
295    *  IF fs_bsis-hkont NE w_hkont
296    *    AND sy-tabix GT 1.
297    *    fs_bsis-dmbtr =  w_credit + w_debit.
298      PERFORM get_account_gl_sum CHANGING fs_bsis-dmbtr.
299    *    CLEAR:  w_credit,
300    *            w_debit.
301      IF NOT fs_bsis-dmbtr IS INITIAL.
302        PERFORM upload_fi_docu_gl.
303      ENDIF.
304    *  ELSEIF w_index EQ 0.
305    **    fs_bsis-dmbtr =  w_credit + w_debit.
306    **    CLEAR: w_credit,
307    **           w_debit.
308    *    PERFORM get_account_gl_sum CHANGING fs_bsis-dmbtr.
309    *    PERFORM upload_fi_docu_gl.
310    *  ENDIF.
311    *  MOVE fs_bsis-hkont TO w_hkont.
312    ENDFORM.                             " UPLOAD_FI_DOCUMENT_N
313    *&---------------------------------------------------------------------*
314    *&      Form  UPLOAD_FI_DOCU_GL
315    *&---------------------------------------------------------------------*
316    *       text
317    *----------------------------------------------------------------------*
318    *  No interface parameter passed.
319    *----------------------------------------------------------------------*
320    FORM upload_fi_docu_gl .
321    ** Update header structure for bapi.....................................
322      fs_docu_headr-username = sy-uname.
323      fs_docu_headr-header_txt = 'INITIAL DATA UPLOAD'.
324      fs_docu_headr-comp_code = p_bukrs.
325      fs_docu_headr-doc_date =   '20090731'.       " Changed
326      fs_docu_headr-pstng_date = '20090731'.       " Changed
327    *    fs_docu_headr-trans_date = '20090731'.
328    *    fs_docu_headr-fisc_year = '2009'.
329      fs_docu_headr-doc_type = 'IB'.
330    ** Fill bapi interface tables.........................................
331    ** 1st Line Item.................
332      CLEAR fs_amt.
333      fs_amt-itemno_acc  = '0000000001'.
334      fs_amt-currency    = 'INR'.
335    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
336    *  fs_amt-amt_doccur  = fs_bsis-dmbtr.
337      fs_amt-amt_doccur = CONV #( fs_bsis-dmbtr ).
338    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
339      APPEND fs_amt TO it_amt.
340    ** 2nd Line Item.................
341      fs_bsis-dmbtr =  ( -1 )  * fs_bsis-dmbtr.
342      CLEAR fs_amt.
343      fs_amt-itemno_acc  = '0000000002'.
344      fs_amt-currency    = 'INR'.
345    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
346    *  fs_amt-amt_doccur  = fs_bsis-dmbtr.
347      fs_amt-amt_doccur = CONV #( fs_bsis-dmbtr ).
348    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
349      APPEND fs_amt TO it_amt.
350
351    ** Update Account gl details table....................................
352    ** 1st Line Item.................
353      CLEAR fs_acctgl.
354      fs_acctgl-itemno_acc = '0000000002'.
355      fs_acctgl-gl_account = '0000990001'.
356      fs_acctgl-item_text = 'INITIAL DATA UPLOAD'.
357      fs_acctgl-comp_code = p_bukrs.
358    ** Update Assignment allocation field.................................
359      IF p_xopvw EQ 'X'.
360        CONCATENATE fs_bsis-belnr '-'  fs_bsis-gjahr
361                                         INTO fs_acctgl-ref_key_3.
362        fs_acctgl-ref_key_2 = fs_bsis-bukrs.
363      ENDIF.
364      APPEND fs_acctgl TO it_acctgl.
365      CLEAR fs_acctgl.
366    ** 2nd Line Item.................
367      fs_acctgl-itemno_acc = '0000000001'.
368      fs_acctgl-gl_account = fs_bsis-hkont.
369      fs_acctgl-item_text = 'INITIAL DATA UPLOAD'.
370      fs_acctgl-comp_code = p_bukrs.
371    ** Update Assignment allocation field.................................
372      IF p_xopvw EQ 'X'.
373        CONCATENATE fs_bsis-belnr '-'  fs_bsis-gjahr
374                                         INTO fs_acctgl-ref_key_3.
375        fs_acctgl-ref_key_2 = fs_bsis-bukrs.
376      ENDIF.
377      APPEND fs_acctgl TO it_acctgl.
378      PERFORM bapi_fi_docu_call .
379    ENDFORM.                    " UPLOAD_FI_DOCU_GL
380    *&---------------------------------------------------------------------*
381    *&      Form  GET_ACCOUNT_GL_SUM
382    *&---------------------------------------------------------------------*
383    *       text
384    *----------------------------------------------------------------------*
385    *  -->  p1        text
386    *  <--  p2        text
387    *----------------------------------------------------------------------*
388    FORM get_account_gl_sum CHANGING p_amount.
389      DATA:fs_bapiret2 TYPE  bapireturn.
390      DATA: fs_bapi1028 TYPE bapi1028_3.
391
392    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
393      CALL FUNCTION 'BAPI_GL_GETGLACCBALANCE' DESTINATION p_dest"#EC CI_USAGE_OK[2628704]
394    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
395        EXPORTING
396          companycode     = p_bukrs
397          glacct          = fs_bsis-hkont
398          fiscalyear      = '2009'       " Changed
399          currencytype    = '10'
400        IMPORTING
401          account_balance = fs_bapi1028
402          return          = fs_bapiret2.
403
404      IF fs_bapiret2-type EQ 'E'.
405        WRITE:/ fs_bapiret2-message.
406      ELSE.
407        p_amount = fs_bapi1028-balance.
408      ENDIF.
409    ENDFORM.                    " GET_ACCOUNT_GL_SUM
*--- End of ZTR_FI_DOCUMENT_UPLOAD_BSIS - 409 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  <REPINI>                                  Level 1    Page 2
Object           ZTR_FI_DOCUMENT_UPLOAD_BSIS               Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:18
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
Object           ZTR_FI_DOCUMENT_UPLOAD_BSIS               Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:18
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
Object           ZTR_FI_DOCUMENT_UPLOAD_BSIS               Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:18
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
Object           ZTR_FI_DOCUMENT_UPLOAD_BSIS               Lines 1
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:18
----------------------------------------------------------------------------------------------------
1      * INCLUDE DB__SSEL
*--- End of DB__SSEL - 1 lines ---
