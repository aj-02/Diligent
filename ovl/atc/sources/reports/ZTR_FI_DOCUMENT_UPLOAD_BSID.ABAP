----------------------------------------------------------------------------------------------------
Main program     ZTR_FI_DOCUMENT_UPLOAD_BSID               Level 0    Page 1
Object           ZTR_FI_DOCUMENT_UPLOAD_BSID               Lines 443
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:16
----------------------------------------------------------------------------------------------------
1      REPORT  ztr_fi_document_upload_bsid NO STANDARD PAGE HEADING.
2      *&--------------------------------------------------------------------*
3      * Report     : ZTR_FI_DOCUMENT_UPLOAD                                 *
4      *                                                                     *
5      * Title      : FI Document Upload                                     *
6      *                                                                     *
7      * FS No.     : NA                                                     *
8      *                                                                     *
9      * Author     : Gurpreet Singh                                         *
10     *                                                                     *
11     * Login Id   : SAB_ANAND                                              *
12     *                                                                     *
13     * Start date : 16th July 2009                                         *
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
24          BEGIN OF ty_bsid,
25             bukrs TYPE bsid-bukrs,
26             kunnr TYPE bsid-kunnr,
27             umskz TYPE bsid-umskz,
28             zuonr TYPE bsid-zuonr,
29             gjahr TYPE bsid-gjahr,
30             belnr TYPE bsid-belnr,
31             budat TYPE bsid-budat,
32             bldat TYPE bsid-bldat,
33             waers TYPE bsid-waers,
34             blart TYPE bsid-blart,
35             xblnr TYPE bsid-xblnr,
36             bschl TYPE bsid-bschl,
37            shkzg  TYPE bsid-shkzg,
38             dmbtr TYPE bsid-dmbtr,
39             sgtxt TYPE bsid-sgtxt,
40             saknr TYPE bsid-saknr,
41             hkont TYPE bsid-hkont,
42             skfbt TYPE bsid-skfbt,
43             sknto TYPE bsid-sknto,
44             wskto TYPE bsid-wskto,
45           END OF ty_bsid.
46     DATA: fs_bsid TYPE ty_bsid.
47     DATA: it_bsid LIKE
48           STANDARD TABLE
49              OF fs_bsid.
50     DATA: w_index TYPE i.
51     ** field string & Tables for bapi....................................
52     DATA: fs_docu_headr TYPE bapiache09,
53           fs_amt        TYPE bapiaccr09,
54           fs_acctgl     TYPE bapiacgl09,
55           fs_acct_rec   TYPE bapiacar09.
56     DATA: it_amt TYPE
57                 TABLE OF bapiaccr09,
58           it_acctgl TYPE
59                 TABLE OF bapiacgl09,
60           it_acct_rec TYPE
61                 TABLE OF bapiacar09.
62     DATA:w_itemno(10) TYPE n VALUE 1,
63          w_kunnr TYPE kunnr.
64     ** Conversion Table upload............................................
65     DATA: BEGIN OF fs_conv,
66                old_customer TYPE ztrcust_nmbr_chk-old_customer,
67                new_customer TYPE ztrcust_nmbr_chk-new_customer,
68              END OF fs_conv.
69     DATA:
70           it_conv LIKE
71                   STANDARD
72                   TABLE OF fs_conv.
73     ** Selection-screen block.............................................
74     SELECT-OPTIONS: s_kunnr FOR fs_bsid-kunnr.
75     PARAMETERS:
76       p_dest TYPE rfcdest OBLIGATORY DEFAULT 'TRUST_RFC_PRD',
77       p_bukrs TYPE bukrs.
78
79     *---------------------------------------------------------------------*
80     *   START-OF-SELECTION Block.                                         *
81     *---------------------------------------------------------------------*
82     START-OF-SELECTION.
83     ** Fetching data upload from older trust system(4.7)...................
84       CALL FUNCTION 'ZTRFI_LINE_ITEMS' DESTINATION p_dest
85         EXPORTING
86           p_bukrs = p_bukrs
87         TABLES
88           s_kunnr = s_kunnr
89           it_bsid = it_bsid
90         EXCEPTIONS
91           no_data = 1.
92
93       SORT it_bsid BY kunnr gjahr DESCENDING.
94     ** Get the no of records in a table...................................
95       DESCRIBE TABLE it_bsid LINES w_index.
96     ** Get Conversion ....................................................
97       SELECT old_customer
98              new_customer
99              FROM ztrcust_nmbr_chk
100             INTO TABLE it_conv.
101    ** Upload data........................................................
102      LOOP AT it_bsid INTO fs_bsid.
103    *    SUBTRACT 1 FROM w_index.
104    *    IF fs_bsid-gjahr LT '2009'.
105    *** till 31.07.2009.....................................................
106    *      PERFORM upload_fi_documents USING w_kunnr.
107    *    ELSE.
108    ** Current Fisical Year................................................
109        PERFORM upload_fi_documents_curr.
110    *    ENDIF.
111    *    MOVE fs_bsid-kunnr  TO w_kunnr.
112      ENDLOOP.
113    *&---------------------------------------------------------------------*
114    *&      Form  UPLOAD_FI_DOCUMENTS
115    *&---------------------------------------------------------------------*
116    *   Subroutine to upload data BAPI Structures.
117    *----------------------------------------------------------------------*
118    *  No interface parameters passed.
119    *----------------------------------------------------------------------*
120    **FORM upload_fi_documents USING w_kunnr.
121    **  STATICS:"w_kunnr TYPE kunnr,
122    **          w_credit TYPE dmbtr,
123    **          w_debit TYPE dmbtr,
124    **          fs_bsid_tmp TYPE ty_bsid.
125    **
126    **** Comparing customers................................................
127    **  IF fs_bsid-kunnr NE  w_kunnr
128    **  AND sy-tabix GT 1.
129    **    fs_bsid_tmp-dmbtr =  w_debit + w_credit .
130    **    fs_bsid_tmp-dmbtr =  ( -1 )  * fs_bsid_tmp-dmbtr.
131    **    CLEAR: w_credit,
132    **       w_debit.
133    **** Update header structure for bapi.....................................
134    **    fs_docu_headr-username = sy-uname.
135    **    fs_docu_headr-header_txt = 'INITIAL DATA UPLOAD'.
136    **    fs_docu_headr-comp_code = p_bukrs.
137    **    fs_docu_headr-doc_date =   '20090331'.
138    **    fs_docu_headr-pstng_date = '20090331'.
139    ***    fs_docu_headr-trans_date = '20090731'.
140    ***    fs_docu_headr-fisc_year = '2009'.
141    **    fs_docu_headr-doc_type = 'IB'.
142    **** Update Account gl details table....................................
143    **    CLEAR fs_acctgl.
144    **    fs_acctgl-itemno_acc = '0000000001'.
145    **    fs_acctgl-gl_account = '0000990001'.
146    **    fs_acctgl-item_text = 'INITIAL DATA UPLOAD'.
147    **    fs_acctgl-comp_code = p_bukrs.
148    **    APPEND fs_acctgl TO it_acctgl.
149    **** Fill bapi interface tables.........................................
150    ***    PERFORM bapi_intrface_tab_fill USING fs_bsid_tmp.
151    **    CLEAR fs_amt.
152    **    fs_amt-itemno_acc  = '0000000001'.
153    **    fs_amt-currency    = 'INR'.
154    **    fs_amt-amt_doccur  = fs_bsid_tmp-dmbtr.
155    **    fs_amt-amt_base    = fs_bsid_tmp-skfbt.
156    **    fs_amt-disc_base   = fs_bsid_tmp-sknto .
157    **    fs_amt-disc_amt    = fs_bsid_tmp-wskto.
158    **    APPEND fs_amt TO it_amt.
159    **    PERFORM bapi_fi_docu_call USING fs_bsid_tmp-kunnr.
160    **    CLEAR fs_bsid_tmp.
161    **  ENDIF.
162    **** Sum credit & Debit amount...........................................
163    **  CASE fs_bsid-shkzg.
164    **    WHEN 'H'.
165    **      fs_bsid-dmbtr =  ( -1 )  * fs_bsid-dmbtr.
166    **      w_credit = w_credit + fs_bsid-dmbtr.
167    **    WHEN 'S'.
168    **      w_debit = w_debit + fs_bsid-dmbtr.
169    **  ENDCASE.
170    ***  MOVE fs_bsid-kunnr  TO w_kunnr.
171    **  MOVE fs_bsid TO fs_bsid_tmp.
172    **** Fill bapi interface tables..........................................
173    **  PERFORM bapi_intrface_tab_fill USING fs_bsid.
174    **  IF w_index EQ 0 .
175    **    fs_bsid_tmp-dmbtr =  w_debit + w_credit .
176    **    fs_bsid_tmp-dmbtr =  ( -1 )  * fs_bsid_tmp-dmbtr.
177    **** Update header structure for bapi.....................................
178    **    fs_docu_headr-username = sy-uname.
179    **    fs_docu_headr-header_txt = 'INITIAL DATA UPLOAD'.
180    **    fs_docu_headr-comp_code = p_bukrs.
181    **    fs_docu_headr-doc_date =   '20090331'.
182    **    fs_docu_headr-pstng_date = '20090331'.
183    ***    fs_docu_headr-trans_date = '20090731'.
184    ***    fs_docu_headr-fisc_year = '2009'.
185    **    fs_docu_headr-doc_type = 'IB'.
186    **** Update Account gl details table....................................
187    **    CLEAR fs_acctgl.
188    **    fs_acctgl-itemno_acc = '0000000001'.
189    **    fs_acctgl-gl_account = '0000990001'.
190    **    fs_acctgl-item_text = 'INITIAL DATA UPLOAD'.
191    **    fs_acctgl-comp_code = p_bukrs.
192    **    APPEND fs_acctgl TO it_acctgl.
193    **    CLEAR: w_credit,
194    **           w_debit.
195    **** Fill bapi interface tables.........................................
196    ***    PERFORM bapi_intrface_tab_fill USING fs_bsid_tmp.
197    **    CLEAR fs_amt.
198    **    fs_amt-itemno_acc  = '0000000001'.
199    **    fs_amt-currency    = 'INR'.
200    **    fs_amt-amt_doccur  = fs_bsid_tmp-dmbtr.
201    **    fs_amt-amt_base    = fs_bsid_tmp-skfbt.
202    **    fs_amt-disc_base   = fs_bsid_tmp-sknto .
203    **    fs_amt-disc_amt    = fs_bsid_tmp-wskto.
204    **    APPEND fs_amt TO it_amt.
205    **    PERFORM bapi_fi_docu_call USING fs_bsid_tmp-kunnr.
206    **    CLEAR fs_bsid_tmp.
207    **  ENDIF.
208    **ENDFORM.                    " UPLOAD_FI_DOCUMENTS
209    *&---------------------------------------------------------------------*
210    *&      Form  BAPI_FI_DOCU_CALL
211    *&---------------------------------------------------------------------*
212    *       text
213    *----------------------------------------------------------------------*
214    *  No interface parameter passed.
215    *----------------------------------------------------------------------*
216    FORM bapi_fi_docu_call USING w_kunnr.
217
218      DATA: it_bapiret2 TYPE
219                     TABLE OF bapiret2,
220            fs_bapiret2 TYPE bapiret2.
221      CLEAR it_bapiret2.
222      SORT it_amt BY itemno_acc.
223    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
224      CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'  "#EC CI_USAGE_OK
225        "#EC CI_USAGE_OK[2628704]
226      "#EC CI_USAGE_OK[2438131]
227    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
228        EXPORTING
229          documentheader          = fs_docu_headr
230    *   CUSTOMERCPD             =
231    *   CONTRACTHEADER          =
232    * IMPORTING
233    *   OBJ_TYPE                =
234    *   OBJ_KEY                 =
235    *   OBJ_SYS                 =
236        TABLES
237         accountgl               = it_acctgl
238         accountreceivable       = it_acct_rec
239    *   ACCOUNTPAYABLE          =
240    *   ACCOUNTTAX              =
241          currencyamount          = it_amt
242    *   CRITERIA                =
243    *   VALUEFIELD              =
244    *   EXTENSION1              =
245          return                  = it_bapiret2
246    *   PAYMENTCARD             =
247    *   CONTRACTITEM            =
248    *   EXTENSION2              =
249    *   REALESTATE              =
250    *   ACCOUNTWT               =
251                .
252
253      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
254       EXPORTING
255         wait          = 'X'
256    * IMPORTING
257    *   RETURN        =
258                .
259    ** Bapi return message.................................................
260      READ TABLE it_bapiret2 INTO fs_bapiret2 WITH KEY type = 'E'.
261      IF sy-subrc EQ 0.
262        READ TABLE it_bapiret2 INTO fs_bapiret2 INDEX 2.
263        WRITE:/ 'Fi document for Custome.no:',
264                 w_kunnr
265                 ,' Could not be uploaded',
266                 fs_bapiret2-message.
267        ULINE.
268      ELSE.
269        READ TABLE it_bapiret2 INTO fs_bapiret2 INDEX 1.
270        WRITE:/ 'Fi document for Custome.no:',
271              w_kunnr,
272              fs_bapiret2-message.
273        ULINE.
274      ENDIF.
275      CLEAR:
276            fs_docu_headr,
277             it_acctgl,
278             it_acct_rec,
279             it_amt,
280              it_bapiret2.
281      w_itemno = 1.
282    ENDFORM.                               " BAPI_FI_DOCU_CALL
283    *&---------------------------------------------------------------------*
284    *&      Form  BAPI_INTRFACE_TAB_FILL
285    *&---------------------------------------------------------------------*
286    *  Subroutine to fill bapi table.
287    *----------------------------------------------------------------------*
288    *  No interface parameters passed.
289    *----------------------------------------------------------------------*
290    FORM bapi_intrface_tab_fill USING fs_bsid TYPE ty_bsid .
291      ADD 1 TO w_itemno.
292      CLEAR fs_acct_rec.
293      fs_acct_rec-itemno_acc = w_itemno.
294      fs_acct_rec-customer = fs_bsid-kunnr.
295    *  fs_acct_rec-gl_account = fs_bsid-hkont.
296      fs_acct_rec-comp_code = p_bukrs.
297      fs_acct_rec-sp_gl_ind = fs_bsid-umskz.
298      fs_acct_rec-item_text = fs_bsid-sgtxt.
299      fs_acct_rec-alloc_nmbr = fs_bsid-zuonr.
300    ** Get fisical year...................................................
301      IF fs_bsid-budat+4(2) LT 4.
302        fs_bsid-budat+0(4) = fs_bsid-budat+0(4) - 1.
303      ENDIF.
304    ** Update Assignment allocation field.................................
305      CONCATENATE fs_bsid-budat+0(4) '-' fs_bsid-belnr
306                                       INTO fs_acct_rec-ref_key_3.
307      fs_acct_rec-ref_key_2 = fs_bsid-bukrs .
308    ** New Sp.GL Indicators changes.......................................
309      CASE  fs_bsid-umskz.
310        WHEN 'J'.
311          fs_acct_rec-sp_gl_ind = '+'.
312        WHEN 'K'.
313          fs_acct_rec-sp_gl_ind = '*'.
314        WHEN 'L'.
315          fs_acct_rec-sp_gl_ind = '/'.
316        WHEN 'S'.
317          fs_acct_rec-sp_gl_ind = '-'.
318        WHEN 'B'.
319          fs_acct_rec-sp_gl_ind = '8'.
320        WHEN 'C'.
321          fs_acct_rec-sp_gl_ind = '9'.
322        WHEN OTHERS.
323          fs_acct_rec-sp_gl_ind = fs_bsid-umskz.
324      ENDCASE.
325
326      APPEND fs_acct_rec TO it_acct_rec.
327    ** Update amount table for bapi......................................
328      CLEAR fs_amt.
329      fs_amt-itemno_acc  = w_itemno.
330      fs_amt-currency    = 'INR'.
331    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
332    *  fs_amt-amt_doccur  = fs_bsid-dmbtr.
333      fs_amt-amt_doccur = CONV #( fs_bsid-dmbtr ).
334    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
335    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
336    *  fs_amt-amt_base    = fs_bsid-skfbt.
337      fs_amt-amt_base = CONV #( fs_bsid-skfbt ).
338    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
339      fs_amt-disc_base   = fs_bsid-sknto .
340      fs_amt-disc_amt    = fs_bsid-wskto.
341      APPEND fs_amt TO it_amt.
342    ENDFORM.                               " BAPI_INTRFACE_TAB_FILL
343    *&---------------------------------------------------------------------*
344    *&      Form  UPLOAD_FI_DOCUMENTS_CURR
345    *&---------------------------------------------------------------------*
346    *       text
347    *----------------------------------------------------------------------*
348    *  No interface parameters passed
349    *----------------------------------------------------------------------*
350    FORM upload_fi_documents_curr .
351    ** Conversion Rule .....................................................
352      READ TABLE it_conv INTO fs_conv
353                         WITH KEY old_customer = fs_bsid-kunnr.
354      IF sy-subrc EQ 0.
355        fs_bsid-kunnr = fs_conv-new_customer.
356      ENDIF.
357    ** Update header structure for bapi.....................................
358      fs_docu_headr-username = sy-uname.
359      fs_docu_headr-header_txt = 'INITIAL DATA UPLOAD'.
360      fs_docu_headr-comp_code = p_bukrs.
361      fs_docu_headr-doc_date =   fs_bsid-budat.
362      fs_docu_headr-pstng_date = '20090731'.
363    *    fs_docu_headr-trans_date = '20090731'.
364    *    fs_docu_headr-fisc_year = '2009'.
365      fs_docu_headr-doc_type = 'IB'.
366    ** Gl acc details........................................................
367      fs_acct_rec-itemno_acc = '0000000002'.
368      fs_acct_rec-customer = fs_bsid-kunnr.
369    *  fs_acct_rec-gl_account = fs_bsid-hkont.
370      fs_acct_rec-comp_code = p_bukrs.
371      fs_acct_rec-sp_gl_ind = fs_bsid-umskz.
372      fs_acct_rec-item_text = fs_bsid-sgtxt.
373      fs_acct_rec-alloc_nmbr = fs_bsid-zuonr.
374    ** Update ref key 3 field.................................
375      CONCATENATE  fs_bsid-gjahr '-' fs_bsid-belnr
376                                       INTO fs_acct_rec-ref_key_3.
377      fs_acct_rec-ref_key_2 = fs_bsid-bukrs .
378    ** New Sp.GL Indicators changes.......................................
379      CASE  fs_bsid-umskz.
380        WHEN 'J'.
381          fs_acct_rec-sp_gl_ind = '+'.
382        WHEN 'K'.
383          fs_acct_rec-sp_gl_ind = '*'.
384        WHEN 'L'.
385          fs_acct_rec-sp_gl_ind = '/'.
386        WHEN 'S'.
387          fs_acct_rec-sp_gl_ind = '-'.
388        WHEN 'B'.
389          fs_acct_rec-sp_gl_ind = '8'.
390        WHEN 'C'.
391          fs_acct_rec-sp_gl_ind = '9'.
392        WHEN OTHERS.
393          fs_acct_rec-sp_gl_ind = fs_bsid-umskz.
394      ENDCASE.
395
396      APPEND fs_acct_rec TO it_acct_rec.
397    ** Update Account gl details table....................................
398      CLEAR fs_acctgl.
399      fs_acctgl-itemno_acc = '0000000001'.
400      fs_acctgl-gl_account = '0000990001'.
401      fs_acctgl-item_text = 'INITIAL DATA UPLOAD'.
402      fs_acctgl-comp_code = p_bukrs.
403      APPEND fs_acctgl TO it_acctgl.
404    ** Fill bapi interface tables..........................................
405      CLEAR fs_amt.
406    ** Sum credit & Debit amount...........................................
407      CASE fs_bsid-shkzg.
408        WHEN 'H'.
409          fs_bsid-dmbtr =  ( -1 )  * fs_bsid-dmbtr.
410      ENDCASE.
411    ** 2nd line item.......................................................
412      fs_amt-itemno_acc  = '0000000002'.
413      fs_amt-currency    = 'INR'.
414    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
415    *  fs_amt-amt_doccur  = fs_bsid-dmbtr.
416      fs_amt-amt_doccur = CONV #( fs_bsid-dmbtr ).
417    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
418    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
419    *  fs_amt-amt_base    = fs_bsid-skfbt.
420      fs_amt-amt_base = CONV #( fs_bsid-skfbt ).
421    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
422      fs_amt-disc_base   = fs_bsid-sknto .
423      fs_amt-disc_amt    = fs_bsid-wskto.
424      APPEND fs_amt TO it_amt.
425      CLEAR fs_amt.
426    ** 1st line item.......................................................
427      fs_bsid-dmbtr =  ( -1 )  * fs_bsid-dmbtr.
428      fs_amt-itemno_acc  = '0000000001'.
429      fs_amt-currency    = 'INR'.
430    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
431    *  fs_amt-amt_doccur  = fs_bsid-dmbtr.
432      fs_amt-amt_doccur = CONV #( fs_bsid-dmbtr ).
433    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
434    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
435    *  fs_amt-amt_base    = fs_bsid-skfbt.
436      fs_amt-amt_base = CONV #( fs_bsid-skfbt ).
437    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
438      fs_amt-disc_base   = fs_bsid-sknto .
439      fs_amt-disc_amt    = fs_bsid-wskto.
440      APPEND fs_amt TO it_amt.
441    ** Bapi fi document upload for current fiscal year......................
442      PERFORM bapi_fi_docu_call USING fs_bsid-kunnr.
443    ENDFORM.                    " UPLOAD_FI_DOCUMENTS_CURR
*--- End of ZTR_FI_DOCUMENT_UPLOAD_BSID - 443 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  <REPINI>                                  Level 1    Page 2
Object           ZTR_FI_DOCUMENT_UPLOAD_BSID               Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:16
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
Object           ZTR_FI_DOCUMENT_UPLOAD_BSID               Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:16
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
Object           ZTR_FI_DOCUMENT_UPLOAD_BSID               Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:16
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
Object           ZTR_FI_DOCUMENT_UPLOAD_BSID               Lines 1
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:16
----------------------------------------------------------------------------------------------------
1      * INCLUDE DB__SSEL
*--- End of DB__SSEL - 1 lines ---
