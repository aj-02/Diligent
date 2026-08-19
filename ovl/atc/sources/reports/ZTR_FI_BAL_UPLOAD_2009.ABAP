----------------------------------------------------------------------------------------------------
Main program     ZTR_FI_BAL_UPLOAD_2009                    Level 0    Page 1
Object           ZTR_FI_BAL_UPLOAD_2009                    Lines 339
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:15
----------------------------------------------------------------------------------------------------
1      REPORT  ztr_fi_bal_upload_2009 NO STANDARD PAGE HEADING.
2      *&--------------------------------------------------------------------*
3      * Report     : ZTR_FI_BAL_UPLOAD_2009                                 *
4      *                                                                     *
5      * Title      : FI Line items Upload(2009)                             *
6      *                                                                     *
7      * FS No.     : NA                                                     *
8      *                                                                     *
9      * Author     : Gurpreet Singh                                         *
10     *                                                                     *
11     * Login Id   : SAB_ANAND                                              *
12     *                                                                     *
13     * Start date : 20th July 2009                                         *
14     *                                                                     *
15     * Description: Report to upload account line items for 2009.          *
16     *                                                                     *
17     * Tran. Code : N/A                                                    *
18     *&--------------------------------------------------------------------*
19
20     *---------------------------------------------------------------------*
21     *               Data Decelaration part.                               *
22     *---------------------------------------------------------------------*
23     ** field string & Tables for bapi......................................
24     DATA: fs_docu_headr TYPE bapiache09,
25           fs_amt        TYPE bapiaccr09,
26           fs_acctgl     TYPE bapiacgl09,
27           fs_acct_rec   TYPE bapiacar09,
28           fs_acct_pay    TYPE bapiacap09.
29     DATA: it_amt TYPE
30                 TABLE OF bapiaccr09,
31           it_acctgl TYPE
32                 TABLE OF bapiacgl09,
33           it_acct_rec TYPE
34                 TABLE OF bapiacar09,
35           it_acct_pay TYPE
36                 TABLE OF bapiacap09.
37     ** Account table......................................................
38     DATA:BEGIN OF fs_docu,
39          bukrs TYPE bkpf-bukrs,
40          belnr TYPE bkpf-belnr,
41          gjahr TYPE bkpf-gjahr,
42          augbl TYPE bseg-augbl,
43          blart TYPE bkpf-blart,
44          budat TYPE bkpf-budat,
45          bldat TYPE bkpf-bldat,
46          koart TYPE bseg-koart,
47          umskz TYPE bseg-umskz,
48          dmbtr TYPE bseg-dmbtr,
49          zuonr TYPE bseg-zuonr,
50          sgtxt TYPE bseg-sgtxt,
51          hkont TYPE bseg-hkont,
52          kunnr TYPE bseg-kunnr,
53          lifnr TYPE bseg-lifnr,
54          waers(5) TYPE c,
55          xblnr(16) TYPE c,
56          shkzg TYPE bseg-shkzg,
57          skfbt TYPE bseg-skfbt,
58          sknto TYPE bseg-sknto,
59          wskto TYPE bseg-wskto,
60          END OF fs_docu.
61     *data:w_docu_old TYPE bkpf-belnr.
62     DATA:it_docu LIKE STANDARD TABLE OF fs_docu,
63          w_index TYPE i.
64     ** Coversion rule table & field string................................
65     DATA: it_cust_comp TYPE TABLE OF ztrcust_nmbr_chk,
66           fs_cust_comp TYPE ztrcust_nmbr_chk.
67     ** Selection-screen block.............................................
68     SELECT-OPTIONS: s_docu FOR fs_docu_headr-ac_doc_no.
69     PARAMETERS:
70     *    p_koart TYPE  koart OBLIGATORY,
71         p_bukrs TYPE bukrs OBLIGATORY,
72         p_dest TYPE rfcdest OBLIGATORY DEFAULT 'TRUST_RFC_PRD'.
73
74     *---------------------------------------------------------------------*
75     *   START-OF-SELECTION Block.                                         *
76     *---------------------------------------------------------------------*
77     START-OF-SELECTION.
78     ** Fetching data upload from older trust system(4.7)...................
79       CALL FUNCTION 'ZTR_FI_GET' DESTINATION p_dest
80         EXPORTING
81           p_bukrs   = p_bukrs
82     *      p_koart  = p_koart
83         TABLES
84           s_docu    = s_docu
85           it_docu   = it_docu
86           EXCEPTIONS
87          no_data       = 1
88          OTHERS        = 2.
89
90     ** Sort data by document number........................................
91       SORT it_docu BY belnr.
92     ** Ulpoad line items...................................................
93       LOOP AT it_docu INTO fs_docu.
94         ADD 1 TO w_index.
95         PERFORM upload_header_details.
96     ** Amount Upload.......................................................
97         PERFORM upload_amount.
98         CASE fs_docu-koart.
99           WHEN 'S'.                          " GL ACCOUNT....................
100    ** Update Account gl details table....................................
101            CLEAR fs_acctgl.
102            fs_acctgl-itemno_acc = w_index.
103            fs_acctgl-gl_account = fs_docu-hkont.
104            fs_acctgl-item_text = fs_docu-sgtxt.
105            fs_acctgl-comp_code = p_bukrs.
106    ** Check for clearing document number..................................
107            IF fs_docu-augbl IS INITIAL.
108              fs_acctgl-alloc_nmbr = fs_docu-zuonr.
109            ELSE.
110              fs_acctgl-alloc_nmbr = fs_docu-augbl.
111            ENDIF.
112    ** Update refkey field field.................................
113            CONCATENATE '2009' '-' fs_docu-belnr
114                                             INTO fs_acctgl-ref_key_3.
115           fs_acctgl-ref_key_2 = p_bukrs.
116            APPEND fs_acctgl TO it_acctgl.
117          WHEN 'D'.                          " Customer......................
118    ** Account receviable table upload.....................................
119            CLEAR fs_acct_rec.
120            fs_acct_rec-itemno_acc = w_index.
121    ** Coversion rule......................................................
122            READ TABLE it_cust_comp INTO fs_cust_comp
123                                    WITH KEY old_customer = fs_docu-kunnr.
124            IF sy-subrc EQ 0.
125              MOVE fs_cust_comp-new_customer TO fs_acct_rec-customer.
126            ELSE.
127              MOVE fs_docu-kunnr TO fs_acct_rec-customer.
128            ENDIF.
129    *  fs_acct_rec-gl_account = fs_docu-hkont.
130            fs_acct_rec-comp_code = p_bukrs.
131            fs_acct_rec-sp_gl_ind = fs_docu-umskz.
132            fs_acct_rec-item_text = fs_docu-sgtxt.
133    ** Check for clearing document number..................................
134            IF fs_docu-augbl IS INITIAL.
135            fs_acct_rec-alloc_nmbr = fs_docu-zuonr.
136            else.
137            fs_acct_rec-alloc_nmbr = fs_docu-augbl.
138            endif.
139    ** Update Assignment allocation field.................................
140            CONCATENATE fs_docu-gjahr '-' fs_docu-belnr
141                                             INTO fs_acct_rec-ref_key_3.
142            fs_acct_rec-ref_key_2 = fs_docu-bukrs.
143    ** New Sp.GL Indicators changes.......................................
144            CASE  fs_docu-umskz.
145              WHEN 'J'.
146                fs_acct_rec-sp_gl_ind = '+'.
147              WHEN 'K'.
148                fs_acct_rec-sp_gl_ind = '*'.
149              WHEN 'L'.
150                fs_acct_rec-sp_gl_ind = '/'.
151              WHEN 'S'.
152                fs_acct_rec-sp_gl_ind = '-'.
153              WHEN 'B'.
154                fs_acct_rec-sp_gl_ind = '8'.
155              WHEN 'C'.
156                fs_acct_rec-sp_gl_ind = '9'.
157              WHEN OTHERS.
158                fs_acct_rec-sp_gl_ind = fs_docu-umskz.
159            ENDCASE.
160            APPEND fs_acct_rec TO it_acct_rec.
161          WHEN 'K'.                          " Vendor......................
162    ** Update account payable table........................................
163            fs_acct_pay-itemno_acc = w_index.
164            fs_acct_pay-vendor_no = fs_docu-lifnr.
165            fs_acct_pay-gl_account = fs_docu-hkont.
166            fs_acct_pay-comp_code = p_bukrs.
167            fs_acct_pay-item_text = fs_docu-sgtxt.
168    ** Check for clearing document number..................................
169            IF fs_docu-augbl IS INITIAL.
170            fs_acct_pay-alloc_nmbr = fs_docu-zuonr.
171            else.
172              fs_acct_pay-alloc_nmbr = fs_docu-augbl.
173            endif.
174
175    ** New Sp.GL Indicators changes.......................................
176            CASE  fs_docu-umskz.
177              WHEN 'J'.
178                fs_acct_pay-sp_gl_ind = '+'.
179              WHEN 'K'.
180                fs_acct_pay-sp_gl_ind = '*'.
181              WHEN 'L'.
182                fs_acct_pay-sp_gl_ind = '/'.
183              WHEN 'S'.
184                fs_acct_pay-sp_gl_ind = '-'.
185              WHEN 'B'.
186                fs_acct_pay-sp_gl_ind = '8'.
187              WHEN 'C'.
188                fs_acct_pay-sp_gl_ind = '9'.
189              WHEN OTHERS.
190                fs_acct_pay-sp_gl_ind = fs_docu-umskz.
191            ENDCASE.
192    ** Update Assignment allocation field.................................
193            CONCATENATE fs_docu-belnr fs_docu-bukrs fs_docu-gjahr
194                                             INTO fs_acct_pay-ref_key_3.
195            APPEND fs_acct_pay TO it_acct_pay.
196        ENDCASE.
197        AT END OF belnr.
198          PERFORM bapi_fi_docu_call.
199        ENDAT.
200      ENDLOOP.
201    ***
202    *      LOOP AT it_docu INTO fs_docu.
203    *        ADD 1 TO w_index.
204    *        PERFORM upload_header_details.
205    *** Amount Upload.......................................................
206    *        PERFORM upload_amount.
207    *        AT END OF belnr.
208    *          PERFORM bapi_fi_docu_call_cust.
209    *        ENDAT.
210    *      ENDLOOP.
211    *
212    *      LOOP AT it_docu INTO fs_docu.
213    *        ADD 1 TO w_index.
214    *        PERFORM upload_header_details.
215    *** Amount Upload.......................................................
216    *        PERFORM upload_amount.
217    *
218    *        AT END OF belnr.
219    *          PERFORM bapi_fi_docu_call_vendor.
220    *        ENDAT.
221    *      ENDLOOP.
222
223
224    *&---------------------------------------------------------------------*
225    *&      Form  UPLOAD_HEADER_DETAILS
226    *&---------------------------------------------------------------------*
227    *       text
228    *----------------------------------------------------------------------*
229    *  No interface parameters passed.
230    *----------------------------------------------------------------------*
231    FORM upload_header_details .
232    ** Update header structure for bapi.....................................
233      fs_docu_headr-username = sy-uname.
234      fs_docu_headr-header_txt = 'INITIAL DATA UPLOAD'.
235      fs_docu_headr-comp_code = p_bukrs.
236      fs_docu_headr-doc_date =   fs_docu-budat.
237      fs_docu_headr-pstng_date = fs_docu-bldat.
238    *    fs_docu_headr-trans_date = '20090731'.
239      fs_docu_headr-fisc_year = '2009'.
240      fs_docu_headr-doc_type = 'IB'.
241    ENDFORM.                    " UPLOAD_HEADER_DETAILS
242    *&---------------------------------------------------------------------*
243    *&      Form  UPLOAD_AMOUNT
244    *&---------------------------------------------------------------------*
245    *       text
246    *----------------------------------------------------------------------*
247    *  No interface parameters passed.
248    *----------------------------------------------------------------------*
249    FORM upload_amount .
250      IF fs_docu-shkzg EQ 'H'.
251        fs_docu-dmbtr = ( -1 ) * fs_docu-dmbtr.
252      ENDIF.
253      fs_amt-itemno_acc  = w_index.
254      fs_amt-currency    = 'INR'.
255    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
256    *  fs_amt-amt_doccur  = fs_docu-dmbtr.
257      fs_amt-amt_doccur = CONV #( fs_docu-dmbtr ).
258    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
259    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
260    *  fs_amt-amt_base    = fs_docu-skfbt.
261      fs_amt-amt_base = CONV #( fs_docu-skfbt ).
262    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
263      fs_amt-disc_base   = fs_docu-sknto .
264      fs_amt-disc_amt    = fs_docu-wskto.
265      APPEND fs_amt TO it_amt.
266      CLEAR fs_amt.
267    ENDFORM.                    " UPLOAD_AMOUNT
268    *&---------------------------------------------------------------------*
269    *&      Form  BAPI_FI_DOCU_CALL
270    *&---------------------------------------------------------------------*
271    *       text
272    *----------------------------------------------------------------------*
273    *  No interface parameter passed.
274    *----------------------------------------------------------------------*
275    FORM bapi_fi_docu_call .
276
277      DATA: it_bapiret2 TYPE
278                     TABLE OF bapiret2,
279            fs_bapiret2 TYPE bapiret2.
280      CLEAR it_bapiret2.
281      SORT it_amt BY itemno_acc.
282    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
283      CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'  "#EC CI_USAGE_OK
284          "#EC CI_USAGE_OK[2628704]
285      "#EC CI_USAGE_OK[2438131]
286
287    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
288        EXPORTING
289          documentheader          = fs_docu_headr
290    *   CUSTOMERCPD             =
291    *   CONTRACTHEADER          =
292    * IMPORTING
293    *   OBJ_TYPE                =
294    *   OBJ_KEY                 =
295    *   OBJ_SYS                 =
296        TABLES
297         accountgl               = it_acctgl
298         accountreceivable       = it_acct_rec
299       accountpayable            = it_acct_pay
300    *   ACCOUNTTAX              =
301          currencyamount          = it_amt
302    *   CRITERIA                =
303    *   VALUEFIELD              =
304    *   EXTENSION1              =
305          return                  = it_bapiret2
306    *   PAYMENTCARD             =
307    *   CONTRACTITEM            =
308    *   EXTENSION2              =
309    *   REALESTATE              =
310    *   ACCOUNTWT               =
311                .
312
313      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
314       EXPORTING
315         wait          = 'X'
316    * IMPORTING
317    *   RETURN        =
318                .
319    ** Bapi return message.................................................
320      READ TABLE it_bapiret2 INTO fs_bapiret2 WITH KEY type = 'E'.
321      IF sy-subrc EQ 0.
322        READ TABLE it_bapiret2 INTO fs_bapiret2 INDEX 2.
323        WRITE:/ 'Old system Document:',fs_docu-belnr,' Could not be uploaded',
324               / fs_bapiret2-message.
325        ULINE.
326      ELSE.
327        READ TABLE it_bapiret2 INTO fs_bapiret2 INDEX 1.
328        WRITE:/ 'Old system Document:',fs_docu-belnr,fs_bapiret2-message.
329        ULINE.
330      ENDIF.
331      CLEAR:
332            fs_docu_headr,
333             it_acctgl,
334             it_acct_rec,
335             it_amt,
336              it_bapiret2,
337              it_acct_pay,
338              w_index.
339    ENDFORM.                               " BAPI_FI_DOCU_CALL
*--- End of ZTR_FI_BAL_UPLOAD_2009 - 339 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  <REPINI>                                  Level 1    Page 2
Object           ZTR_FI_BAL_UPLOAD_2009                    Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:15
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
Object           ZTR_FI_BAL_UPLOAD_2009                    Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:15
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
Object           ZTR_FI_BAL_UPLOAD_2009                    Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:15
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
Object           ZTR_FI_BAL_UPLOAD_2009                    Lines 1
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:15
----------------------------------------------------------------------------------------------------
1      * INCLUDE DB__SSEL
*--- End of DB__SSEL - 1 lines ---
