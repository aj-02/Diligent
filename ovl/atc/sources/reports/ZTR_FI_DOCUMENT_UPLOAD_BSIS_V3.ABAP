----------------------------------------------------------------------------------------------------
Main program     ZTR_FI_DOCUMENT_UPLOAD_BSIS_V3            Level 0    Page 1
Object           ZTR_FI_DOCUMENT_UPLOAD_BSIS_V3            Lines 419
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:21
----------------------------------------------------------------------------------------------------
1      REPORT  ztr_fi_document_upload_bsis_v3 NO STANDARD PAGE HEADING.
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
56     DATA: BEGIN OF fs_glacct_check,
57             bukrs TYPE bsis-bukrs,
58             hkont TYPE bsis-hkont,
59              bldat TYPE bsis-bldat,
60             xref3 TYPE bsis-xref3,
61           END OF fs_glacct_check.
62     DATA: it_glacct_check LIKE
63                 STANDARD TABLE
64                       OF fs_glacct_check,
65           w_refkey3 TYPE bsis-xref3.
66     ** Selection-screen block.............................................
67     SELECT-OPTIONS: s_hkont FOR fs_bsis-hkont,
68                     s_bel FOR fs_bsis-belnr.
69     PARAMETERS:
70       p_bukrs TYPE bukrs,
71       p_year TYPE gjahr,
72       p_xopvw TYPE xopvw AS CHECKBOX DEFAULT 'X',
73       p_dest TYPE rfcdest OBLIGATORY DEFAULT 'TRUST_RFC_PRD'.
74
75     *---------------------------------------------------------------------*
76     *   START-OF-SELECTION Block.                                         *
77     *---------------------------------------------------------------------*
78     START-OF-SELECTION.
79     ** Fetching data upload from older trust system(4.7)...................
80       CALL FUNCTION 'ZTRFI_GET' DESTINATION p_dest
81         EXPORTING
82           p_bukrs = p_bukrs
83           p_xopvw = p_xopvw
84         TABLES
85           s_hkont = s_hkont
86           it_bsis = it_bsis.
87     ** Delete records.....................................................
88       DELETE it_bsis WHERE belnr NOT IN s_bel.
89       delete it_bsis where gjahr ne p_year.
90     ** Upload data........................................................
91       LOOP AT it_bsis INTO fs_bsis.
92           IF p_xopvw EQ 'X'.
93             PERFORM upload_fi_documents.     " Open Item Managed
94           ELSE.
95             PERFORM upload_fi_document_n.    " Open Item not Managed
96           ENDIF.
97       ENDLOOP.
98     *&---------------------------------------------------------------------*
99     *&      Form  UPLOAD_FI_DOCUMENTS
100    *&---------------------------------------------------------------------*
101    *   Subroutine to upload data BAPI Structures.
102    *----------------------------------------------------------------------*
103    *  No interface parameters passed.
104    *----------------------------------------------------------------------*
105    FORM upload_fi_documents .
106    ** Update header structure for bapi.....................................
107      fs_docu_headr-username = sy-uname.
108      fs_docu_headr-header_txt = 'INITIAL DATA UPLOAD'.
109      fs_docu_headr-comp_code = p_bukrs.
110      fs_docu_headr-doc_date =   fs_bsis-budat.
111      fs_docu_headr-pstng_date = '20090731'.
112    *    fs_docu_headr-trans_date = '20090731'.
113    *    fs_docu_headr-fisc_year = '2009'.
114      fs_docu_headr-doc_type = 'IB'.
115    ** Fill bapi interface tables.........................................
116    ** 1st Line Item.................
117      IF fs_bsis-shkzg EQ 'H'.
118        fs_bsis-dmbtr =  ( -1 )  * fs_bsis-dmbtr.
119      ENDIF.
120      CLEAR fs_amt.
121      fs_amt-itemno_acc  = '0000000001'.
122      fs_amt-currency    = 'INR'.
123    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
124    *  fs_amt-amt_doccur  = fs_bsis-dmbtr.
125      fs_amt-amt_doccur = CONV #( fs_bsis-dmbtr ).
126    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
127      APPEND fs_amt TO it_amt.
128    ** 2nd Line Item.................
129      fs_bsis-dmbtr =  ( -1 )  * fs_bsis-dmbtr.
130      CLEAR fs_amt.
131      fs_amt-itemno_acc  = '0000000002'.
132      fs_amt-currency    = 'INR'.
133    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
134    fs_amt-amt_doccur = CONV BAPIDOCCUR( fs_bsis-dmbtr ) .
135    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
136      APPEND fs_amt TO it_amt.
137
138    ** Update Account gl details table....................................
139    ** 1st Line Item.................
140      CLEAR fs_acctgl.
141      fs_acctgl-itemno_acc = '0000000002'.
142      fs_acctgl-gl_account = '0000990001'.
143      fs_acctgl-item_text = 'Closing Balance as on 31.07.2009'.
144      fs_acctgl-comp_code = p_bukrs.
145      fs_acctgl-alloc_nmbr = fs_bsis-zuonr.
146    ** Update Assignment allocation field.................................
147      CONCATENATE fs_bsis-gjahr '-' fs_bsis-belnr
148                                    INTO fs_acctgl-ref_key_3.
149      fs_acctgl-ref_key_2 = fs_bsis-bukrs.
150      APPEND fs_acctgl TO it_acctgl.
151      CLEAR fs_acctgl.
152    ** 2nd Line Item.................
153      fs_acctgl-itemno_acc = '0000000001'.
154      fs_acctgl-gl_account = fs_bsis-hkont.
155      fs_acctgl-item_text = fs_bsis-sgtxt.
156      fs_acctgl-comp_code = p_bukrs.
157    ** Update Assignment allocation field.................................
158      CONCATENATE fs_bsis-gjahr '-' fs_bsis-belnr
159                                    INTO fs_acctgl-ref_key_3.
160      fs_acctgl-ref_key_2 = fs_bsis-bukrs.
161      APPEND fs_acctgl TO it_acctgl.
162      PERFORM bapi_fi_docu_call .
163
164    ENDFORM.                    " UPLOAD_FI_DOCUMENTS
165    *&---------------------------------------------------------------------*
166    *&      Form  BAPI_FI_DOCU_CALL
167    *&---------------------------------------------------------------------*
168    *       text
169    *----------------------------------------------------------------------*
170    *  No interface parameter passed.
171    *----------------------------------------------------------------------*
172    FORM bapi_fi_docu_call .
173
174      DATA: it_bapiret2 TYPE
175                     TABLE OF bapiret2,
176            fs_bapiret2 TYPE bapiret2.
177      CLEAR it_bapiret2.
178      SORT it_amt BY itemno_acc.
179    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
180      CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'  "#EC CI_USAGE_OK
181      "#EC CI_USAGE_OK[2628704]
182      "#EC CI_USAGE_OK[2438131]
183    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
184        EXPORTING
185          documentheader          = fs_docu_headr
186    *   CUSTOMERCPD             =
187    *   CONTRACTHEADER          =
188    * IMPORTING
189    *   OBJ_TYPE                =
190    *   OBJ_KEY                 =
191    *   OBJ_SYS                 =
192        TABLES
193         accountgl               = it_acctgl
194    *     accountreceivable       = it_acct_rec
195    *   ACCOUNTPAYABLE          =
196    *   ACCOUNTTAX              =
197          currencyamount          = it_amt
198    *   CRITERIA                =
199    *   VALUEFIELD              =
200    *   EXTENSION1              =
201          return                  = it_bapiret2
202    *   PAYMENTCARD             =
203    *   CONTRACTITEM            =
204    *   EXTENSION2              =
205    *   REALESTATE              =
206    *   ACCOUNTWT               =
207                .
208
209      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
210       EXPORTING
211         wait          = 'X'
212    * IMPORTING
213    *   RETURN        =
214                .
215    ** Bapi return message.................................................
216      READ TABLE it_bapiret2 INTO fs_bapiret2 WITH KEY type = 'E'.
217      IF sy-subrc EQ 0.
218        READ TABLE it_bapiret2 INTO fs_bapiret2 INDEX 2.
219        WRITE:/ ' Could not be uploaded',
220                 fs_bapiret2-message.
221        ULINE.
222      ELSE.
223        READ TABLE it_bapiret2 INTO fs_bapiret2 INDEX 1.
224        WRITE:/ fs_bapiret2-message.
225        ULINE.
226      ENDIF.
227      CLEAR:
228            fs_docu_headr,
229             it_acctgl,
230             it_amt,
231              it_bapiret2.
232    ENDFORM.                               " BAPI_FI_DOCU_CALL
233    *&---------------------------------------------------------------------*
234    *&      Form  BAPI_INTRFACE_TAB_FILL
235    *&---------------------------------------------------------------------*
236    *  Subroutine to fill bapi table.
237    *----------------------------------------------------------------------*
238    *  No interface parameters passed.
239    *----------------------------------------------------------------------*
240    *FORM bapi_intrface_tab_fill USING fs_bsis TYPE ty_bsis .
241    *  ADD 1 TO w_itemno.
242    *  CLEAR fs_acct_rec.
243    *  fs_acct_rec-itemno_acc = w_itemno.
244    *  fs_acct_rec-customer = fs_bsis-kunnr.
245    **  fs_acct_rec-gl_account = fs_BSIS-hkont.
246    *  fs_acct_rec-comp_code = p_bukrs.
247    *  fs_acct_rec-sp_gl_ind = fs_bsis-umskz.
248    *  fs_acct_rec-item_text = fs_bsis-sgtxt.
249    *** Get fisical year...................................................
250    *  IF fs_bsis-budat+4(2) LT 4.
251    *    fs_bsis-budat+0(4) = fs_bsis-budat+0(4) - 1.
252    *  ENDIF.
253    *** Update Assignment allocation field.................................
254    *  CONCATENATE fs_bsis-belnr fs_bsis-bukrs fs_bsis-budat+0(4)
255    *                                   INTO fs_acct_rec-alloc_nmbr.
256    *** New Sp.GL Indicators changes.......................................
257    *  CASE  fs_bsis-umskz.
258    *    WHEN 'J'.
259    *      fs_acct_rec-sp_gl_ind = '+'.
260    *    WHEN 'K'.
261    *      fs_acct_rec-sp_gl_ind = '*'.
262    *    WHEN 'L'.
263    *      fs_acct_rec-sp_gl_ind = '/'.
264    *    WHEN 'S'.
265    *      fs_acct_rec-sp_gl_ind = '-'.
266    *    WHEN 'B'.
267    *      fs_acct_rec-sp_gl_ind = '8'.
268    *    WHEN 'C'.
269    *      fs_acct_rec-sp_gl_ind = '9'.
270    *    WHEN OTHERS.
271    *      fs_acct_rec-sp_gl_ind = fs_bsis-umskz.
272    *  ENDCASE.
273    *
274    *  APPEND fs_acct_rec TO it_acct_rec.
275    *** Update amount table for bapi......................................
276    *  CLEAR fs_amt.
277    *  fs_amt-itemno_acc  = w_itemno.
278    *  fs_amt-currency    = 'INR'.
279    *  fs_amt-amt_doccur  = fs_bsis-dmbtr.
280    *  fs_amt-amt_base    = fs_bsis-skfbt.
281    *  fs_amt-disc_base   = fs_bsis-sknto .
282    *  fs_amt-disc_amt    = fs_bsis-wskto.
283    *  APPEND fs_amt TO it_amt.
284    *ENDFORM.                               " BAPI_INTRFACE_TAB_FILL
285    *&---------------------------------------------------------------------*
286    *&      Form  UPLOAD_FI_DOCUMENT_N
287    *&---------------------------------------------------------------------*
288    *       text
289    *----------------------------------------------------------------------*
290    * No interface parameter passed.
291    *----------------------------------------------------------------------*
292    FORM upload_fi_document_n .
293    *  STATICS:w_credit TYPE dmbtr,
294    *        w_debit TYPE dmbtr,
295    *        w_hkont TYPE hkont.
296
297      SUBTRACT 1 FROM w_index.
298    *  CASE fs_bsis-shkzg.
299    *    WHEN 'H'.
300    *      fs_bsis-dmbtr =  ( -1 )  * fs_bsis-dmbtr.
301    *      w_credit = w_credit + fs_bsis-dmbtr.
302    *    WHEN 'S'.
303    *      w_debit = w_debit + fs_bsis-dmbtr.
304    *  ENDCASE.
305    *  IF fs_bsis-hkont NE w_hkont
306    *    AND sy-tabix GT 1.
307    *    fs_bsis-dmbtr =  w_credit + w_debit.
308      PERFORM get_account_gl_sum CHANGING fs_bsis-dmbtr.
309    *    CLEAR:  w_credit,
310    *            w_debit.
311      IF NOT fs_bsis-dmbtr IS INITIAL.
312        PERFORM upload_fi_docu_gl.
313      ENDIF.
314    *  ELSEIF w_index EQ 0.
315    **    fs_bsis-dmbtr =  w_credit + w_debit.
316    **    CLEAR: w_credit,
317    **           w_debit.
318    *    PERFORM get_account_gl_sum CHANGING fs_bsis-dmbtr.
319    *    PERFORM upload_fi_docu_gl.
320    *  ENDIF.
321    *  MOVE fs_bsis-hkont TO w_hkont.
322    ENDFORM.                             " UPLOAD_FI_DOCUMENT_N
323    *&---------------------------------------------------------------------*
324    *&      Form  UPLOAD_FI_DOCU_GL
325    *&---------------------------------------------------------------------*
326    *       text
327    *----------------------------------------------------------------------*
328    *  No interface parameter passed.
329    *----------------------------------------------------------------------*
330    FORM upload_fi_docu_gl .
331    ** Update header structure for bapi.....................................
332      fs_docu_headr-username = sy-uname.
333      fs_docu_headr-header_txt = 'INITIAL DATA UPLOAD'.
334      fs_docu_headr-comp_code = p_bukrs.
335      fs_docu_headr-doc_date =   '20090731'.       " Changed
336      fs_docu_headr-pstng_date = '20090731'.       " Changed
337    *    fs_docu_headr-trans_date = '20090731'.
338    *    fs_docu_headr-fisc_year = '2009'.
339      fs_docu_headr-doc_type = 'IB'.
340    ** Fill bapi interface tables.........................................
341    ** 1st Line Item.................
342      CLEAR fs_amt.
343      fs_amt-itemno_acc  = '0000000001'.
344      fs_amt-currency    = 'INR'.
345    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
346    *  fs_amt-amt_doccur  = fs_bsis-dmbtr.
347      fs_amt-amt_doccur = CONV #( fs_bsis-dmbtr ).
348    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
349      APPEND fs_amt TO it_amt.
350    ** 2nd Line Item.................
351      fs_bsis-dmbtr =  ( -1 )  * fs_bsis-dmbtr.
352      CLEAR fs_amt.
353      fs_amt-itemno_acc  = '0000000002'.
354      fs_amt-currency    = 'INR'.
355    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
356    *  fs_amt-amt_doccur  = fs_bsis-dmbtr.
357      fs_amt-amt_doccur = CONV #( fs_bsis-dmbtr ).
358    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
359      APPEND fs_amt TO it_amt.
360
361    ** Update Account gl details table....................................
362    ** 1st Line Item.................
363      CLEAR fs_acctgl.
364      fs_acctgl-itemno_acc = '0000000002'.
365      fs_acctgl-gl_account = '0000990001'.
366      fs_acctgl-item_text = 'INITIAL DATA UPLOAD'.
367      fs_acctgl-comp_code = p_bukrs.
368    ** Update Assignment allocation field.................................
369      IF p_xopvw EQ 'X'.
370        CONCATENATE fs_bsis-belnr '-'  fs_bsis-gjahr
371                                         INTO fs_acctgl-ref_key_3.
372        fs_acctgl-ref_key_2 = fs_bsis-bukrs.
373      ENDIF.
374      APPEND fs_acctgl TO it_acctgl.
375      CLEAR fs_acctgl.
376    ** 2nd Line Item.................
377      fs_acctgl-itemno_acc = '0000000001'.
378      fs_acctgl-gl_account = fs_bsis-hkont.
379      fs_acctgl-item_text = 'INITIAL DATA UPLOAD'.
380      fs_acctgl-comp_code = p_bukrs.
381    ** Update Assignment allocation field.................................
382      IF p_xopvw EQ 'X'.
383        CONCATENATE fs_bsis-belnr '-'  fs_bsis-gjahr
384                                         INTO fs_acctgl-ref_key_3.
385        fs_acctgl-ref_key_2 = fs_bsis-bukrs.
386      ENDIF.
387      APPEND fs_acctgl TO it_acctgl.
388      PERFORM bapi_fi_docu_call .
389    ENDFORM.                    " UPLOAD_FI_DOCU_GL
390    *&---------------------------------------------------------------------*
391    *&      Form  GET_ACCOUNT_GL_SUM
392    *&---------------------------------------------------------------------*
393    *       text
394    *----------------------------------------------------------------------*
395    *  -->  p1        text
396    *  <--  p2        text
397    *----------------------------------------------------------------------*
398    FORM get_account_gl_sum CHANGING p_amount.
399      DATA:fs_bapiret2 TYPE  bapireturn.
400      DATA: fs_bapi1028 TYPE bapi1028_3.
401
402    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
403      CALL FUNCTION 'BAPI_GL_GETGLACCBALANCE' DESTINATION p_dest"#EC CI_USAGE_OK[2628704]
404    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
405        EXPORTING
406          companycode     = p_bukrs
407          glacct          = fs_bsis-hkont
408          fiscalyear      = '2009'       " Changed
409          currencytype    = '10'
410        IMPORTING
411          account_balance = fs_bapi1028
412          return          = fs_bapiret2.
413
414      IF fs_bapiret2-type EQ 'E'.
415        WRITE:/ fs_bapiret2-message.
416      ELSE.
417        p_amount = fs_bapi1028-balance.
418      ENDIF.
419    ENDFORM.                    " GET_ACCOUNT_GL_SUM
*--- End of ZTR_FI_DOCUMENT_UPLOAD_BSIS_V3 - 419 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  <REPINI>                                  Level 1    Page 2
Object           ZTR_FI_DOCUMENT_UPLOAD_BSIS_V3            Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:21
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
Object           ZTR_FI_DOCUMENT_UPLOAD_BSIS_V3            Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:21
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
Object           ZTR_FI_DOCUMENT_UPLOAD_BSIS_V3            Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:21
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
Object           ZTR_FI_DOCUMENT_UPLOAD_BSIS_V3            Lines 1
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:21
----------------------------------------------------------------------------------------------------
1      * INCLUDE DB__SSEL
*--- End of DB__SSEL - 1 lines ---
