----------------------------------------------------------------------------------------------------
Main program     ZPY_LOAN_FI_BALANCE_TRANSFER              Level 0    Page 1
Object           ZPY_LOAN_FI_BALANCE_TRANSFER              Lines 1010
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:29
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *& Report  ZPY_LOAN_FI_BALANCE_TRANSFER
3      *&---------------------------------------------------------------------*
4      REPORT  ZPY_LOAN_FI_BALANCE_TRANSFER MESSAGE-ID ZPY_LOAN_FI.
5
6      *&---------------------------------------------------------------------*
7      *&  Developed By Jagmeet Singh On 07th June 2013
8      *&  Description: Loans and advances given to employees through payroll
9      *&               are transferred to FI module in employees vendor
10     *&               account with special GL indication. Each loan type in
11     *&               payroll is mapped to special GL indicator in FI. When
12     *&               employees is transferred from company code to another
13     *&               company code his loan balances appearing in FI also
14     *&               needs to be transferred to his new company code.
15     *&---------------------------------------------------------------------*
16
17     *&---------------------------------------------------------------------*
18     *& Class LOAN_TRANSFER Definition
19     *&---------------------------------------------------------------------*
20     CLASS LOAN_TRANSFER DEFINITION.
21       PUBLIC SECTION.
22         METHODS: PROCESS.
23
24       PRIVATE SECTION.
25         TYPE-POOLS: SLIS.
26
27         CONSTANTS: C_MARK TYPE C LENGTH 1 VALUE 'X'.
28
29         TYPES: BEGIN OF TY_ACTION,
30                  PERNR TYPE PERSNO,       "Personnel number
31                  BEGDA TYPE BEGDA,        "Start Date
32                END OF TY_ACTION,
33
34                BEGIN OF TY_ORG,
35                  PERNR TYPE PERSNO,       "Personnel number
36                  BEGDA TYPE BEGDA,        "Start Date
37                  BUKRS TYPE BUKRS,        "Company Code
38                  ENAME TYPE EMNAM,        "Formatted Name of Employee or Applicant
39                  LIFNR TYPE LIFNR,        "Account Number of Vendor or Creditor
40                END OF TY_ORG,
41
42                BEGIN OF TY_BUKRS,
43                  BUKRS TYPE BUKRS,        "Company Code
44                  BUTXT TYPE BUTXT,        "Name of Company Code or Company
45                END OF TY_BUKRS,
46
47                BEGIN OF TY_LOAN_FINAL,
48                  PERNR TYPE PERSNO,       "Personnel number
49                  ENAME TYPE EMNAM,        "Formatted Name of Employee or Applicant
50                  BEGDA TYPE DATUM,        "Start Date
51                  BUKRS TYPE BUKRS,        "Company Code
52                  BUKRS_T TYPE BUTXT,      "Text for Company Code
53                  LIFNR TYPE LIFNR,        "Account Number of Vendor or Creditor
54                  LBUKRS TYPE BUKRS,       "Company Code
55                  LBUKRS_T TYPE BUTXT,     "Text for Company Code
56                  GSBER TYPE GSBER,        "Business Area
57                  PRCTR TYPE PRCTR,        "Profit Center
58                  SHBKZ TYPE UMSKZ,        "Special G/L Indicator
59                  SHBKZ_T TYPE LTEXT_074T, "Long Text for Special G/L Indicators
60                  SHKZG TYPE SHKZG,        "Debit/Credit Indicator
61                  SHKZG_T TYPE CHAR6,      "Text for Debit/Credit Indicator
62                  SALDV TYPE SALDV,        "Balance Carried Forward in Local Currency
63                  SOLLL TYPE SOLLL,        "Total of the Debit Postings in the Current Year
64                  HABNL TYPE HABNL,        "Credit Postings Total in the Current Year
65                  NET_AMOUNT TYPE HABNL,   "Net Amount
66                  LFB1_STATUS TYPE C LENGTH 1, "LFB1 Status; X = Found, SPACE = Not Found
67                  LFB1_LOCK_STATUS TYPE C LENGTH 1, "LFB1 Status; X = Locked, SPACE = Open
68                  ZLSCH TYPE PCODE,        "Payment Method
69                  KOSTL TYPE KOSTL,        "Cost Center
70                  DOCUMENT_NO TYPE BELNR_D,"Accounting Document Number
71                  REMARKS TYPE STRING,     "Remarks
72                  S_LFB1 TYPE LFB1,
73                END OF TY_LOAN_FINAL.
74
75         DATA: GT_ACTION TYPE STANDARD TABLE OF TY_ACTION,
76               WA_ACTION TYPE TY_ACTION,
77               GT_ORG TYPE STANDARD TABLE OF TY_ORG,
78               WA_ORG TYPE TY_ORG,
79               GT_LFC3 TYPE STANDARD TABLE OF LFC3,
80               WA_LFC3 TYPE LFC3,
81               GT_LOAN_DISPLAY TYPE STANDARD TABLE OF TY_LOAN_FINAL,
82               GT_LOAN_DISPLAY2 TYPE STANDARD TABLE OF TY_LOAN_FINAL,
83               GT_LOAN_DISPLAY3 TYPE STANDARD TABLE OF TY_LOAN_FINAL,
84               WA_LOAND TYPE TY_LOAN_FINAL,
85               GT_T074T TYPE STANDARD TABLE OF T074T,
86               WA_T074T TYPE T074T,
87               GT_BUKRS TYPE STANDARD TABLE OF TY_BUKRS,
88               WA_BUKRS TYPE TY_BUKRS,
89               GT_BSIK TYPE STANDARD TABLE OF BSIK,
90               WA_BSIK TYPE BSIK,
91               BDCDATA TYPE STANDARD TABLE OF BDCDATA,
92               WA_BDC TYPE BDCDATA,
93               DOCUMENTHEADER TYPE BAPIACHE09,
94               ACCOUNTPAYABLE TYPE STANDARD TABLE OF BAPIACAP09,
95               WA_AP TYPE BAPIACAP09,
96               CURRENCYAMOUNT TYPE STANDARD TABLE OF BAPIACCR09,
97               WA_CA TYPE BAPIACCR09,
98               RETURN TYPE STANDARD TABLE OF BAPIRET2,
99               WA_RETURN TYPE BAPIRET2,
100
101              GV_GJAHR TYPE C LENGTH 4,
102              GV_LIFNR TYPE LIFNR,
103              GROUP TYPE APQI-GROUPID,
104              GV_POSNR TYPE POSNR_ACC,
105              GV_LINES TYPE I,
106              GV_INDEX TYPE SY-INDEX,
107              GV_PROGRESS_MESSAGE TYPE C LENGTH 60,
108              GV_PRCTR TYPE PRCTR,
109              GV_GSBER TYPE GSBER,
110              S_LFA1 TYPE LFA1,
111              S_LFM1 TYPE LFM1,
112              S_YLFA1 TYPE LFA1,
113              S_YLFB1 TYPE LFB1,
114              S_YLFM1 TYPE LFM1,
115              T_XLFAS TYPE STANDARD TABLE OF FLFAS,
116              T_XLFB5 TYPE STANDARD TABLE OF FLFB5,
117              T_XLFBK TYPE STANDARD TABLE OF FLFBK,
118              T_XLFZA TYPE STANDARD TABLE OF FLFZA,
119              T_YLFAS TYPE STANDARD TABLE OF FLFAS,
120              T_YLFB5 TYPE STANDARD TABLE OF FLFB5,
121              T_YLFBK TYPE STANDARD TABLE OF FLFBK,
122              T_YLFZA TYPE STANDARD TABLE OF FLFZA,
123
124              GT_FIELDCAT TYPE STANDARD TABLE OF SLIS_FIELDCAT_ALV,
125              GWA_FIELDCAT TYPE SLIS_FIELDCAT_ALV,
126              GT_SORT TYPE SLIS_T_SORTINFO_ALV,
127              GWA_SORT TYPE SLIS_SORTINFO_ALV,
128              GS_LAYOUT TYPE SLIS_LAYOUT_ALV,
129              GV_POS TYPE I VALUE 0.
130
131        METHODS: FETCH_LOAN_DATA,
132                 TRANSFER_LOAN,
133                 DISPLAY_ALV,
134                 PREPARE_ALV,
135                 VENDOR_CREATE
136                   IMPORTING I_VEND TYPE TY_LOAN_FINAL,
137                 VENDOR_UNLOCK
138                   IMPORTING I_VEND TYPE TY_LOAN_FINAL,
139                 BDC_DYNPRO
140                   IMPORTING PROGRAM TYPE BDC_PROG
141                             DYNPRO TYPE BDC_DYNR,
142                 BDC_FIELD
143                   IMPORTING FNAM TYPE FNAM_____4
144                             FVAL TYPE ANY,
145                 CREATE_SESSION,
146                 CLOSE_SESSION,
147                 INSERT_BDC_SESSION
148                  IMPORTING TCODE TYPE TSTC-TCODE,
149                 POST_FI.
150    ENDCLASS.                    "LOAN_TRANSFER DEFINITION
151
152    *&---------------------------------------------------------------------*
153    *& Global Declaration
154    *&---------------------------------------------------------------------*
155    TABLES: BSIK, PA0001.
156
157    DATA: O_TRANS TYPE REF TO LOAN_TRANSFER.
158
159    *&---------------------------------------------------------------------*
160    *& Selection Screen
161    *&---------------------------------------------------------------------*
162    "SELECTION SCREEN
163    SELECTION-SCREEN BEGIN OF BLOCK A1 WITH FRAME TITLE TEXT-001.
164    SELECT-OPTIONS: S_PERNR FOR PA0001-PERNR NO INTERVALS,             "Personnel number
165                    S_UMSKZ FOR BSIK-UMSKZ NO INTERVALS OBLIGATORY,    "Special G/L Indicator
166                    S_BUKRS FOR PA0001-BUKRS NO INTERVALS,             "Company Code
167                    S_PERSG	FOR PA0001-PERSG NO INTERVALS.             "Employee Group
168    PARAMETERS P_DATE TYPE SY-DATUM OBLIGATORY.                        "Date
169    SELECTION-SCREEN END OF BLOCK A1.
170    "PROCESSING OPTIONS
171    SELECTION-SCREEN BEGIN OF BLOCK A2 WITH FRAME TITLE TEXT-002.
172    PARAMETERS: R_DIS RADIOBUTTON GROUP RG1 DEFAULT 'X',               "Display Report
173                R_TRA RADIOBUTTON GROUP RG1.                           "Transfer Balances
174    SELECTION-SCREEN END OF BLOCK A2.
175
176    *&---------------------------------------------------------------------*
177    *& Events
178    *&---------------------------------------------------------------------*
179    INITIALIZATION.
180      P_DATE = SY-DATUM.
181
182    START-OF-SELECTION.
183      CREATE OBJECT O_TRANS.
184      CALL METHOD O_TRANS->PROCESS.
185
186    *&---------------------------------------------------------------------*
187    *& Class LOAN_TRANSFER Implementation
188    *&---------------------------------------------------------------------*
189    CLASS LOAN_TRANSFER IMPLEMENTATION.
190      METHOD PROCESS.
191        CALL METHOD FETCH_LOAN_DATA.
192
193        IF GT_LOAN_DISPLAY[] IS NOT INITIAL.
194          CALL METHOD PREPARE_ALV.
195          CASE C_MARK.
196            WHEN R_DIS. "DISPLAY
197              CALL METHOD DISPLAY_ALV.
198            WHEN R_TRA. "TRANSFER
199              CALL METHOD TRANSFER_LOAN.
200              CALL METHOD DISPLAY_ALV.
201          ENDCASE.
202        ELSE.
203          MESSAGE S000 DISPLAY LIKE 'E'.
204        ENDIF.
205      ENDMETHOD.                    "PROCESS
206
207      METHOD FETCH_LOAN_DATA.
208        REFRESH: GT_LFC3, GT_ACTION, GT_ORG, GT_T074T, GT_LOAN_DISPLAY, GT_BUKRS.
209        CLEAR: GV_GJAHR.
210
211    *    Get current fiscal year from system date
212        CALL FUNCTION 'GM_GET_FISCAL_YEAR'
213          EXPORTING
214            I_DATE = SY-DATUM
215            I_FYV  = 'V3'
216          IMPORTING
217            E_FY   = GV_GJAHR.
218
219    *    Get  employee's & company code
220        IF S_PERNR[] IS INITIAL.
221          SELECT PERNR BEGDA FROM PA0302 INTO TABLE GT_ACTION
222            WHERE MASSN EQ '06' AND   "Joining on Transfer
223                  AEDTM GE P_DATE.
224
225          IF GT_ACTION[] IS NOT INITIAL.
226            SORT GT_ACTION BY PERNR ASCENDING
227                              BEGDA DESCENDING.
228            DELETE ADJACENT DUPLICATES FROM GT_ACTION COMPARING PERNR.
229
230            SELECT PERNR BEGDA BUKRS ENAME FROM PA0001 INTO CORRESPONDING FIELDS OF TABLE GT_ORG
231              FOR ALL ENTRIES IN GT_ACTION
232              WHERE PERNR EQ GT_ACTION-PERNR AND
233                    BEGDA LE SY-DATUM AND
234                    ENDDA GE SY-DATUM AND
235                    BUKRS IN S_BUKRS AND
236                    PERSG	IN S_PERSG.
237          ENDIF.
238        ELSE.
239          SELECT PERNR BEGDA BUKRS ENAME FROM PA0001 INTO CORRESPONDING FIELDS OF TABLE GT_ORG
240            WHERE PERNR IN S_PERNR AND
241                  BEGDA LE SY-DATUM AND
242                  ENDDA GE SY-DATUM AND
243                  BUKRS IN S_BUKRS AND
244                  PERSG	IN S_PERSG.
245        ENDIF.
246
247        IF GT_ORG[] IS NOT INITIAL.
248    *      Evaluate vendor number from personnel number
249          LOOP AT GT_ORG INTO WA_ORG.
250            WA_ORG-LIFNR = 7000000 + WA_ORG-PERNR.
251            CONDENSE WA_ORG-LIFNR.
252            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
253              EXPORTING
254                INPUT  = WA_ORG-LIFNR
255              IMPORTING
256                OUTPUT = WA_ORG-LIFNR.
257            MODIFY GT_ORG FROM WA_ORG TRANSPORTING LIFNR.
258          ENDLOOP.
259
260    *      Get special G/L transaction figures
261          SELECT * FROM LFC3 INTO TABLE GT_LFC3
262            FOR ALL ENTRIES IN GT_ORG
263            WHERE LIFNR EQ GT_ORG-LIFNR AND
264                  BUKRS NE GT_ORG-BUKRS AND
265                  BUKRS NE 'OBV' AND
266                  GJAHR EQ GV_GJAHR AND
267                  SHBKZ IN S_UMSKZ.
268
269    *      Get Special G/L Indicator Names
270    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
271    *      SELECT * FROM T074T INTO TABLE GT_T074T
272    *        WHERE SPRAS EQ 'EN' AND
273    *              KOART EQ 'K' AND
274    *              SHBKZ IN S_UMSKZ.
275          SELECT * FROM T074T INTO TABLE GT_T074T
276            WHERE SPRAS EQ 'EN' AND
277                  KOART EQ 'K' AND
278    SHBKZ IN S_UMSKZ
279          ORDER BY PRIMARY KEY.
280    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
281
282          SELECT BUKRS BUTXT FROM T001 INTO TABLE GT_BUKRS
283            FOR ALL ENTRIES IN GT_ORG
284            WHERE BUKRS EQ GT_ORG-BUKRS AND
285                  SPRAS EQ 'EN'.
286        ELSE.
287          MESSAGE S001 DISPLAY LIKE 'E'.
288        ENDIF.
289
290        IF GT_LFC3[] IS NOT INITIAL.
291          SELECT BUKRS BUTXT FROM T001 APPENDING TABLE GT_BUKRS
292            FOR ALL ENTRIES IN GT_LFC3
293            WHERE BUKRS EQ GT_LFC3-BUKRS AND
294                  SPRAS EQ 'EN'.
295
296          SORT: GT_ORG BY LIFNR,
297                GT_T074T BY SHBKZ,
298                GT_BUKRS BY BUKRS.
299
300          DELETE ADJACENT DUPLICATES FROM GT_BUKRS COMPARING BUKRS.
301
302          CLEAR GV_LINES.
303          DESCRIBE TABLE GT_LFC3 LINES GV_LINES.
304
305          LOOP AT GT_LFC3 INTO WA_LFC3.
306            CLEAR: WA_LOAND, GV_LIFNR, GV_INDEX.
307            GV_INDEX = SY-INDEX.
308
309            READ TABLE GT_ORG INTO WA_ORG WITH KEY LIFNR = WA_LFC3-LIFNR
310                                                   BINARY SEARCH.
311            IF SY-SUBRC EQ 0.
312              CLEAR GV_PROGRESS_MESSAGE.
313              CONCATENATE 'Calculating SPL G/L balances for CPF No.' WA_ORG-PERNR INTO GV_PROGRESS_MESSAGE SEPARATED BY SPACE. "#EC NOTEXT
314
315              CALL FUNCTION 'PROGRESS_INDICATOR'
316                EXPORTING
317                  I_TEXT               = GV_PROGRESS_MESSAGE
318                  I_PROCESSED          = GV_INDEX
319                  I_TOTAL              = GV_LINES
320                  I_OUTPUT_IMMEDIATELY = C_MARK.
321
322              WA_LOAND-PERNR = WA_ORG-PERNR.  "Personnel number
323
324              IF S_PERNR[] IS INITIAL.
325                READ TABLE GT_ACTION INTO WA_ACTION WITH KEY PERNR = WA_ORG-PERNR.
326                IF SY-SUBRC EQ 0.
327                  WA_LOAND-BEGDA = WA_ACTION-BEGDA.  "Start Date
328                ENDIF.
329              ELSE.
330                WA_LOAND-BEGDA = WA_ORG-BEGDA.  "Start Date
331              ENDIF.
332
333              WA_LOAND-BUKRS = WA_ORG-BUKRS.  "Company Code
334
335              READ TABLE GT_BUKRS INTO WA_BUKRS WITH KEY BUKRS = WA_ORG-BUKRS
336                                                         BINARY SEARCH.
337              IF SY-SUBRC EQ 0.
338                WA_LOAND-BUKRS_T = WA_BUKRS-BUTXT.  "Text for Company Code
339              ENDIF.
340
341              WA_LOAND-ENAME = WA_ORG-ENAME.  "Formatted Name of Employee or Applicant
342            ENDIF.
343
344            WA_LOAND-LIFNR = WA_LFC3-LIFNR.   "Account Number of Vendor or Creditor
345            WA_LOAND-LBUKRS = WA_LFC3-BUKRS.  "Company Code
346
347            READ TABLE GT_BUKRS INTO WA_BUKRS WITH KEY BUKRS = WA_LFC3-BUKRS
348                                                       BINARY SEARCH.
349            IF SY-SUBRC EQ 0.
350              WA_LOAND-LBUKRS_T = WA_BUKRS-BUTXT.  "Text for Company Code
351            ENDIF.
352
353            WA_LOAND-SHBKZ = WA_LFC3-SHBKZ.   "Special G/L Indicator
354
355            READ TABLE GT_T074T INTO WA_T074T WITH KEY SHBKZ = WA_LFC3-SHBKZ
356                                                       BINARY SEARCH.
357            IF SY-SUBRC EQ 0.
358              WA_LOAND-SHBKZ_T = WA_T074T-LTEXT. "Long Text for Special G/L Indicators
359            ENDIF.
360
361            WA_LOAND-SALDV = WA_LFC3-SALDV.   "Balance Carried Forward in Local Currency
362            WA_LOAND-SOLLL = WA_LFC3-SOLLL.   "Total of the Debit Postings in the Current Year
363            WA_LOAND-HABNL = WA_LFC3-HABNL.   "Credit Postings Total in the Current Year
364            WA_LOAND-NET_AMOUNT = WA_LFC3-SALDV + WA_LFC3-SOLLL + ( WA_LFC3-HABNL * -1 ).  "Net Amount
365
366            IF WA_LOAND-NET_AMOUNT LT '0.00'.
367              WA_LOAND-SHKZG = 'H'.           "Debit/Credit Indicator
368              WA_LOAND-SHKZG_T = 'Credit'. "#EC NOTEXT "Text for Debit/Credit Indicator
369              WA_LOAND-NET_AMOUNT = WA_LOAND-NET_AMOUNT * -1. "To suppress -ve sign
370            ELSEIF WA_LOAND-NET_AMOUNT GT '0.00'.
371              WA_LOAND-SHKZG = 'S'.           "Debit/Credit Indicator
372              WA_LOAND-SHKZG_T = 'Debit'. "#EC NOTEXT "Text for Debit/Credit Indicator
373            ENDIF.
374
375    *        Check if Vendor for HR company code already exists or not
376    *        SELECT SINGLE LIFNR SPERR FROM LFB1 INTO (GV_LIFNR,WA_LOAND-LFB1_LOCK_STATUS)
377    *          WHERE LIFNR EQ WA_LOAND-LIFNR AND
378    *                BUKRS EQ WA_LOAND-BUKRS.
379    *
380    *        IF GV_LIFNR IS NOT INITIAL.
381    *          WA_LOAND-LFB1_STATUS = C_MARK.  "LFB1 Status; X = Found, SPACE = Not Found
382    *        ENDIF.
383
384            SELECT SINGLE * FROM LFB1 INTO WA_LOAND-S_LFB1
385              WHERE LIFNR EQ WA_LOAND-LIFNR AND
386                    BUKRS EQ WA_LOAND-BUKRS.
387
388            IF WA_LOAND-S_LFB1-LIFNR IS NOT INITIAL.
389              WA_LOAND-LFB1_STATUS = C_MARK.  "LFB1 Status; X = Found, SPACE = Not Found
390            ENDIF.
391
392    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
393    *        SELECT SINGLE KOSTL FROM PA9351 INTO WA_LOAND-KOSTL
394    *          WHERE PERNR EQ WA_LOAND-PERNR AND
395    *                BEGDA LE SY-DATUM AND
396    *                ENDDA GE SY-DATUM AND
397    *                SPRPS EQ SPACE.                             "#EC *
398     SELECT KOSTL FROM PA9351   UP TO 1 ROWS INTO WA_LOAND-KOSTL WHERE
399    PERNR EQ WA_LOAND-PERNR AND BEGDA LE SY-DATUM AND ENDDA GE SY-DATUM AND
400    SPRPS EQ SPACE  ORDER BY  PERNR SUBTY OBJPS SPRPS ENDDA BEGDA SEQNR .
401    ENDSELECT.
402    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
403
404    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
405    *        SELECT SINGLE PRCTR GSBER FROM CSKS INTO (WA_LOAND-PRCTR,WA_LOAND-GSBER)
406    *          WHERE KOSTL = WA_LOAND-KOSTL AND
407    *                DATBI GE SY-DATUM AND
408    *                DATAB LE SY-DATUM AND
409    *                BUKRS EQ WA_LOAND-BUKRS.
410     SELECT PRCTR GSBER FROM CSKS   UP TO 1 ROWS INTO (WA_LOAND-PRCTR ,
411    WA_LOAND-GSBER) WHERE KOSTL = WA_LOAND-KOSTL AND DATBI GE SY-DATUM AND
412    DATAB LE SY-DATUM AND BUKRS EQ WA_LOAND-BUKRS  ORDER BY  KOKRS KOSTL
413    DATBI .   ENDSELECT.
414    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
415
416    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
417    *        SELECT SINGLE ZLSCH FROM PA0009 INTO WA_LOAND-ZLSCH
418    *          WHERE PERNR EQ WA_LOAND-PERNR AND
419    *                BEGDA LE SY-DATUM AND
420    *                ENDDA GE SY-DATUM AND
421    *                SPRPS EQ SPACE AND
422    *                BNKSA EQ '0'.                               "#EC *
423     SELECT ZLSCH FROM PA0009   UP TO 1 ROWS INTO WA_LOAND-ZLSCH WHERE
424    PERNR EQ WA_LOAND-PERNR AND BEGDA LE SY-DATUM AND ENDDA GE SY-DATUM AND
425    SPRPS EQ SPACE AND BNKSA EQ '0'  ORDER BY  PERNR SUBTY OBJPS SPRPS
426    ENDDA BEGDA SEQNR .   ENDSELECT.
427    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
428
429            IF WA_LOAND-NET_AMOUNT NE '0.00'.
430              APPEND WA_LOAND TO GT_LOAN_DISPLAY.
431            ENDIF.
432          ENDLOOP.
433        ELSE.
434          MESSAGE S002 DISPLAY LIKE 'E'.
435        ENDIF.
436      ENDMETHOD.                    "FETCH_LOAN_DATA
437
438      METHOD TRANSFER_LOAN.
439    *    Create Vendor which does not exist in HR company code (BUKRS)
440        REFRESH: GT_LOAN_DISPLAY2, GT_LOAN_DISPLAY3.
441        CLEAR: GROUP, GV_LINES.
442        CONCATENATE 'FILOANVEND' SY-DATUM+6(2) INTO GROUP.
443
444        GT_LOAN_DISPLAY2[] = GT_LOAN_DISPLAY[].
445        SORT GT_LOAN_DISPLAY2 BY BUKRS LIFNR.
446        DELETE ADJACENT DUPLICATES FROM GT_LOAN_DISPLAY2 COMPARING BUKRS LIFNR.
447        GT_LOAN_DISPLAY3[] = GT_LOAN_DISPLAY2[].
448        DELETE GT_LOAN_DISPLAY2 WHERE LFB1_STATUS EQ C_MARK.
449        DELETE GT_LOAN_DISPLAY3 WHERE S_LFB1-SPERR EQ SPACE.
450
451        IF GT_LOAN_DISPLAY2[] IS NOT INITIAL.
452          CALL METHOD CREATE_SESSION.
453          LOOP AT GT_LOAN_DISPLAY2 INTO WA_LOAND.
454            CASE WA_LOAND-LFB1_STATUS.
455              WHEN C_MARK.  "Vendor Already Exists
456              WHEN SPACE.   "Vendor Does Not Exists
457                CALL METHOD VENDOR_CREATE
458                  EXPORTING
459                    I_VEND = WA_LOAND.
460
461                CALL METHOD INSERT_BDC_SESSION
462                  EXPORTING
463                    TCODE = 'FK01'.      "#EC CI_USAGE_OK[2226131]
464            ENDCASE.
465          ENDLOOP.
466          SUBMIT RSBDCSUB WITH MAPPE = GROUP AND RETURN.
467          CALL METHOD CLOSE_SESSION.
468          COMMIT WORK.
469        ENDIF.
470
471        IF GT_LOAN_DISPLAY3[] IS NOT INITIAL.
472          LOOP AT GT_LOAN_DISPLAY3 INTO WA_LOAND.
473            CLEAR WA_LOAND-S_LFB1-SPERR.
474            CALL FUNCTION 'VENDOR_UPDATE'
475              EXPORTING
476                I_LFA1  = S_LFA1
477                I_LFB1  = WA_LOAND-S_LFB1
478                I_LFM1  = S_LFM1
479                I_YLFA1 = S_YLFA1
480                I_YLFB1 = S_YLFB1
481                I_YLFM1 = S_YLFM1
482              TABLES
483                T_XLFAS = T_XLFAS
484                T_XLFB5 = T_XLFB5
485                T_XLFBK = T_XLFBK
486                T_XLFZA = T_XLFZA
487                T_YLFAS = T_YLFAS
488                T_YLFB5 = T_YLFB5
489                T_YLFBK = T_YLFBK
490                T_YLFZA = T_YLFZA.
491          ENDLOOP.
492        ENDIF.
493
494        WAIT UP TO 5 SECONDS.
495
496    *    Transfer Loan FI Balance
497        CLEAR GV_LINES.
498        DESCRIBE TABLE GT_LOAN_DISPLAY LINES GV_LINES.
499
500        LOOP AT GT_LOAN_DISPLAY INTO WA_LOAND.
501          IF WA_LOAND-PRCTR IS NOT INITIAL.
502            CLEAR: GV_PROGRESS_MESSAGE, GV_PRCTR, GV_GSBER.
503            CONCATENATE 'Getting line item details for CPF No.' WA_LOAND-PERNR INTO GV_PROGRESS_MESSAGE SEPARATED BY SPACE. "#EC NOTEXT
504
505            CALL FUNCTION 'PROGRESS_INDICATOR'
506              EXPORTING
507                I_TEXT               = GV_PROGRESS_MESSAGE
508                I_PROCESSED          = SY-INDEX
509                I_TOTAL              = GV_LINES
510                I_OUTPUT_IMMEDIATELY = C_MARK.
511
512            REFRESH: GT_BSIK, ACCOUNTPAYABLE, CURRENCYAMOUNT, RETURN.
513            CLEAR: DOCUMENTHEADER.
514            GV_POSNR = 0.
515
516    *      Fetch summary of loan FI document
517            SELECT * FROM BSIK INTO TABLE GT_BSIK
518              WHERE BUKRS EQ WA_LOAND-LBUKRS AND
519                    LIFNR EQ WA_LOAND-LIFNR AND
520                    UMSKZ EQ WA_LOAND-SHBKZ.
521
522            data: l_lines type i,
523                  no_times type i,
524                  l_count type i,
525                   GT_BSIK_tmp like  GT_BSIK.
526            DESCRIBE TABLE GT_BSIK LINES L_LINES.
527
528    ****        if l_lines gt 5.
529    ****          l_lines = 1.
530    ****          loop at GT_BSIK into wa_bsik.
531    ****            if l_lines gt 5.
532    ****              delete GT_BSIK  WHERE BUKRS = wa_bsik-BUKRS AND
533    ****LIFNR = wa_bsik-LIFNR AND
534    ****UMSKS = wa_bsik-UMSKS AND
535    ****UMSKZ = wa_bsik-UMSKZ AND
536    ****AUGDT = wa_bsik-AUGDT AND
537    ****AUGBL = wa_bsik-AUGBL AND
538    ****ZUONR = wa_bsik-ZUONR AND
539    ****GJAHR = wa_bsik-GJAHR AND
540    ****BELNR = wa_bsik-BELNR AND
541    ****BUZEI = wa_bsik-BUZEI.
542    ****            endif.
543    ****            l_lines = l_lines + 1.
544    ****          endloop.
545    ****        endif.
546
547
548
549
550            no_times = L_LINES / 950.
551
552            no_times = no_times + 1.
553
554            GT_BSIK_tmp[] = GT_BSIK[].
555
556
557            do no_times times.
558              clear WA_LOAND-NET_AMOUNT.
559              GV_POSNR = 0.
560              if no_times gt 1.
561                refresh GT_BSIK[].
562                l_count = 1.
563    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
564    SORT GT_BSIK_TMP .
565    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
566                loop at GT_BSIK_tmp into WA_BSIK.
567                  if l_count le 950.
568                    APPEND  WA_BSIK to GT_BSIK.
569                    delete GT_BSIK_tmp WHERE BUKRS = wa_bsik-BUKRS AND
570                                             LIFNR = wa_bsik-LIFNR AND
571                                             UMSKS = wa_bsik-UMSKS AND
572                                             UMSKZ = wa_bsik-UMSKZ AND
573                                             AUGDT = wa_bsik-AUGDT AND
574                                             AUGBL = wa_bsik-AUGBL AND
575                                             ZUONR = wa_bsik-ZUONR AND
576                                             GJAHR = wa_bsik-GJAHR AND
577                                             BELNR = wa_bsik-BELNR AND
578                                             BUZEI = wa_bsik-BUZEI.
579                  else.
580                    exit.
581                  endif.
582                  l_count = l_count + 1.
583                ENDLOOP.
584              endif.
585
586              SORT GT_BSIK BY BUDAT.
587
588              DOCUMENTHEADER-USERNAME = SY-UNAME.
589              CONCATENATE 'Tfr. from' WA_LOAND-LBUKRS 'to' WA_LOAND-BUKRS INTO DOCUMENTHEADER-HEADER_TXT SEPARATED BY SPACE. "#EC NOTEXT
590              DOCUMENTHEADER-COMP_CODE = WA_LOAND-BUKRS.
591              DOCUMENTHEADER-DOC_DATE = SY-DATUM.
592              IF WA_LOAND-BEGDA+0(6) EQ SY-DATUM+0(6).
593                DOCUMENTHEADER-PSTNG_DATE = WA_LOAND-BEGDA.
594              ELSE.
595                DOCUMENTHEADER-PSTNG_DATE = SY-DATUM.
596              ENDIF.
597              DOCUMENTHEADER-DOC_TYPE = 'IU'.
598              MOVE 'Inter CoCode Tfr' TO DOCUMENTHEADER-REF_DOC_NO. "#EC NOTEXT
599
600              LOOP AT GT_BSIK INTO WA_BSIK.
601                CLEAR: WA_AP, WA_CA, GV_PRCTR, GV_GSBER.
602
603                GV_POSNR = GV_POSNR + 1.
604                WA_AP-ITEMNO_ACC = GV_POSNR.
605                WA_AP-VENDOR_NO = WA_LOAND-LIFNR.
606                WA_AP-BLINE_DATE = SY-DATUM.
607                WA_AP-ITEM_TEXT = WA_BSIK-SGTXT.
608                WA_AP-ALLOC_NMBR = WA_BSIK-ZUONR.
609                WA_AP-SP_GL_IND = WA_BSIK-UMSKZ.
610                WA_AP-COMP_CODE = WA_LOAND-BUKRS.
611                WA_AP-REF_KEY_1 = WA_BSIK-BELNR.
612    *          WA_AP-REF_KEY_2 = WA_BSIK-XBLNR.
613                CONCATENATE WA_BSIK-BUDAT+6(2) WA_BSIK-BUDAT+4(2) WA_BSIK-BUDAT+0(4) INTO WA_AP-REF_KEY_2 SEPARATED BY '.'.
614                WA_AP-REF_KEY_3 = WA_BSIK-XBLNR.
615                WA_AP-BUS_AREA = WA_LOAND-GSBER.
616                WA_AP-PROFIT_CTR = WA_LOAND-PRCTR.
617                APPEND WA_AP TO ACCOUNTPAYABLE.
618
619                WA_CA-ITEMNO_ACC = GV_POSNR.
620                WA_CA-CURRENCY = WA_BSIK-WAERS.
621                CASE WA_BSIK-SHKZG.
622                  WHEN 'S'.
623                    WA_CA-AMT_DOCCUR = WA_BSIK-WRBTR.
624                  WHEN 'H'.
625                    WA_CA-AMT_DOCCUR = WA_BSIK-WRBTR * -1.
626                ENDCASE.
627                WA_LOAND-NET_AMOUNT =  WA_LOAND-NET_AMOUNT + WA_CA-AMT_DOCCUR.
628    *          IF WA_CA-AMT_DOCCUR NOT BETWEEN '0.9999-' AND '0.9999'.
629                APPEND WA_CA TO CURRENCYAMOUNT.
630    *          ENDIF.
631
632                GV_PRCTR = WA_BSIK-PRCTR.
633                GV_GSBER = WA_BSIK-GSBER.
634              ENDLOOP.
635
636              CLEAR: WA_AP, WA_CA.
637              GV_POSNR = GV_POSNR + 1.
638              WA_AP-ITEMNO_ACC = GV_POSNR.
639              WA_AP-VENDOR_NO = WA_LOAND-LIFNR.
640              WA_AP-BLINE_DATE = SY-DATUM.
641              CONCATENATE 'CPF' WA_LOAND-PERNR 'transferred from' WA_LOAND-LBUKRS 'to' WA_LOAND-BUKRS INTO WA_AP-ITEM_TEXT SEPARATED BY SPACE.
642              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
643                EXPORTING
644                  INPUT  = WA_LOAND-LIFNR
645                IMPORTING
646                  OUTPUT = WA_LOAND-LIFNR.
647              WA_AP-ALLOC_NMBR = WA_LOAND-LIFNR.
648
649              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
650                EXPORTING
651                  INPUT  = WA_LOAND-LIFNR
652                IMPORTING
653                  OUTPUT = WA_LOAND-LIFNR.
654
655              WA_AP-SP_GL_IND = WA_LOAND-SHBKZ.
656              WA_AP-COMP_CODE = WA_LOAND-LBUKRS.
657              WA_AP-BUS_AREA = GV_GSBER.
658              WA_AP-PROFIT_CTR = GV_PRCTR.
659              APPEND WA_AP TO ACCOUNTPAYABLE.
660
661              WA_CA-ITEMNO_ACC = GV_POSNR.
662              WA_CA-CURRENCY = 'INR'.
663    ****        CASE WA_LOAND-SHKZG.
664    ****          WHEN 'H'.
665    ****            WA_CA-AMT_DOCCUR = WA_LOAND-NET_AMOUNT.
666    ****          WHEN 'S'.
667    ****            WA_CA-AMT_DOCCUR = WA_LOAND-NET_AMOUNT * -1.
668    ****        ENDCASE.
669              WA_CA-AMT_DOCCUR = WA_LOAND-NET_AMOUNT * -1.
670              APPEND WA_CA TO CURRENCYAMOUNT.
671
672              CALL METHOD POST_FI.
673
674              CLEAR: WA_LOAND-DOCUMENT_NO, WA_LOAND-REMARKS.
675              LOOP AT RETURN INTO WA_RETURN WHERE TYPE EQ 'S' OR
676                                                  TYPE EQ 'E'.
677                CASE WA_RETURN-TYPE.
678                  WHEN 'E'.
679                    IF NOT ( WA_RETURN-ID EQ 'RW' AND
680                             WA_RETURN-NUMBER EQ '609' ).
681                      IF WA_LOAND-REMARKS IS NOT INITIAL.
682                        CONCATENATE WA_LOAND-REMARKS ',' INTO WA_LOAND-REMARKS SEPARATED BY SPACE.
683                        CONCATENATE WA_LOAND-REMARKS 'E' WA_RETURN-NUMBER '(' WA_RETURN-ID ')' INTO WA_LOAND-REMARKS.
684                        CONCATENATE WA_LOAND-REMARKS WA_RETURN-MESSAGE INTO WA_LOAND-REMARKS SEPARATED BY SPACE.
685                      ELSE.
686                        CONCATENATE 'E' WA_RETURN-NUMBER '(' WA_RETURN-ID ')' INTO WA_LOAND-REMARKS.
687                        CONCATENATE WA_LOAND-REMARKS WA_RETURN-MESSAGE INTO WA_LOAND-REMARKS SEPARATED BY SPACE.
688                      ENDIF.
689                      CONDENSE WA_LOAND-REMARKS.
690                    ENDIF.
691                  WHEN 'S'.
692                    IF WA_RETURN-ID EQ 'RW' AND
693                       WA_RETURN-NUMBER EQ '605'.
694                      MOVE WA_RETURN-MESSAGE+36(10) TO WA_LOAND-DOCUMENT_NO.
695                    ENDIF.
696    ****                SUBMIT SAPF124 USING SELECTION-SCREEN 1000
697    *****                      VIA SELECTION-SCREEN
698    ****                      WITH BUKRX = WA_LOAND-LBUKRS
699    ****                      WITH X_LIFNR = 'X'
700    ****                      WITH X_SHBLF = 'X'
701    ****                      WITH SHBKK = WA_LOAND-SHBKZ
702    ****                      WITH KONTK = WA_LOAND-LIFNR
703    ****                      WITH X_TESTL = ''
704    ****                      WITH XNAUSBEL = ''
705    ****                      WITH X_FEHLER = ''
706    ****                      AND RETURN.
707                ENDCASE.
708              ENDLOOP.
709
710              MODIFY GT_LOAN_DISPLAY FROM WA_LOAND TRANSPORTING DOCUMENT_NO REMARKS.
711
712              REFRESH:  ACCOUNTPAYABLE , CURRENCYAMOUNT , RETURN.
713            ENDDO.
714          ELSE.
715            CONCATENATE 'IT 9351 not maintained by' WA_LOAND-BUKRS INTO WA_LOAND-REMARKS SEPARATED BY SPACE.
716            MODIFY GT_LOAN_DISPLAY FROM WA_LOAND TRANSPORTING REMARKS.
717          ENDIF.
718
719
720
721        ENDLOOP.
722      ENDMETHOD.                    "TRANSFER_LOAN
723
724      METHOD POST_FI.
725    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
726        CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'"#EC CI_USAGE_OK[2628704]
727          "#EC CI_USAGE_OK[2438131]
728
729    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
730          EXPORTING
731            DOCUMENTHEADER = DOCUMENTHEADER
732          TABLES
733            ACCOUNTPAYABLE = ACCOUNTPAYABLE
734            CURRENCYAMOUNT = CURRENCYAMOUNT
735            RETURN         = RETURN.
736
737        COMMIT WORK.
738      ENDMETHOD.                    "POST_FI
739
740      METHOD VENDOR_CREATE.
741        REFRESH BDCDATA.
742
743        CALL METHOD BDC_DYNPRO
744          EXPORTING
745            PROGRAM = 'SAPMF02K'
746            DYNPRO  = '105'.
747        CALL METHOD BDC_FIELD
748          EXPORTING
749            FNAM = 'BDC_OKCODE'
750            FVAL = '/00'.
751        CALL METHOD BDC_FIELD
752          EXPORTING
753            FNAM = 'RF02K-LIFNR'
754            FVAL = I_VEND-LIFNR.
755        CALL METHOD BDC_FIELD
756          EXPORTING
757            FNAM = 'RF02K-BUKRS'
758            FVAL = I_VEND-BUKRS.
759        CALL METHOD BDC_FIELD
760          EXPORTING
761            FNAM = 'RF02K-REF_LIFNR'
762            FVAL = I_VEND-LIFNR.
763        CALL METHOD BDC_FIELD
764          EXPORTING
765            FNAM = 'RF02K-REF_BUKRS'
766            FVAL = I_VEND-LBUKRS.
767
768        CALL METHOD BDC_DYNPRO
769          EXPORTING
770            PROGRAM = 'SAPMF02K'
771            DYNPRO  = '210'.
772        CALL METHOD BDC_FIELD
773          EXPORTING
774            FNAM = 'BDC_OKCODE'
775            FVAL = '/00'.
776        CALL METHOD BDC_FIELD
777          EXPORTING
778            FNAM = 'LFB1-PERNR'
779            FVAL = I_VEND-PERNR.
780
781        CALL METHOD BDC_DYNPRO
782          EXPORTING
783            PROGRAM = 'SAPMF02K'
784            DYNPRO  = '215'.
785        CALL METHOD BDC_FIELD
786          EXPORTING
787            FNAM = 'BDC_OKCODE'
788            FVAL = '/00'.
789        CALL METHOD BDC_FIELD
790          EXPORTING
791            FNAM = 'LFB1-ZWELS'
792            FVAL = I_VEND-ZLSCH.
793
794        CALL METHOD BDC_DYNPRO
795          EXPORTING
796            PROGRAM = 'SAPMF02K'
797            DYNPRO  = '220'.
798        CALL METHOD BDC_FIELD
799          EXPORTING
800            FNAM = 'BDC_OKCODE'
801            FVAL = '/00'.
802        CALL METHOD BDC_FIELD
803          EXPORTING
804            FNAM = 'LFB1-KVERM'
805            FVAL = I_VEND-KOSTL.
806
807        CALL METHOD BDC_DYNPRO
808          EXPORTING
809            PROGRAM = 'SAPMF02K'
810            DYNPRO  = '610'.
811        CALL METHOD BDC_FIELD
812          EXPORTING
813            FNAM = 'BDC_OKCODE'
814            FVAL = '/00'.
815        CALL METHOD BDC_FIELD
816          EXPORTING
817            FNAM = 'BDC_SUBSCR'
818            FVAL = 'SAPMFWTV'.
819        CALL METHOD BDC_FIELD
820          EXPORTING
821            FNAM = 'LFB1-QLAND'
822            FVAL = 'IN'.
823        CALL METHOD BDC_FIELD
824          EXPORTING
825            FNAM = 'LFBW-WITHT(01)'
826            FVAL = '78'.
827        CALL METHOD BDC_FIELD
828          EXPORTING
829            FNAM = 'LFBW-WT_WITHCD(01)'
830            FVAL = 'I1'.
831        CALL METHOD BDC_FIELD
832          EXPORTING
833            FNAM = 'LFBW-QSREC(01)'
834            FVAL = 'NR'.
835
836        CALL METHOD BDC_DYNPRO
837          EXPORTING
838            PROGRAM = 'SAPMF02K'
839            DYNPRO  = '610'.
840        CALL METHOD BDC_FIELD
841          EXPORTING
842            FNAM = 'BDC_OKCODE'
843            FVAL = '=UPDA'.
844        CALL METHOD BDC_FIELD
845          EXPORTING
846            FNAM = 'BDC_SUBSCR'
847            FVAL = 'SAPMFWTV'.
848      ENDMETHOD.                    "PROCESS_BDC_CREATE
849
850      METHOD VENDOR_UNLOCK.
851        REFRESH BDCDATA.
852
853        CALL METHOD BDC_DYNPRO
854          EXPORTING
855            PROGRAM = 'ZMM_XK05'
856            DYNPRO  = '0500'.
857        CALL METHOD BDC_FIELD
858          EXPORTING
859            FNAM = 'BDC_OKCODE'
860            FVAL = '/00'.
861        CALL METHOD BDC_FIELD
862          EXPORTING
863            FNAM = 'RF02K-LIFNR'
864            FVAL = I_VEND-LIFNR.
865        CALL METHOD BDC_FIELD
866          EXPORTING
867            FNAM = 'RF02K-BUKRS'
868            FVAL = I_VEND-BUKRS.
869
870        CALL METHOD BDC_DYNPRO
871          EXPORTING
872            PROGRAM = 'SAPMF02K'
873            DYNPRO  = '0510'.
874        CALL METHOD BDC_FIELD
875          EXPORTING
876            FNAM = 'BDC_OKCODE'
877            FVAL = '=UPDA'.
878        CALL METHOD BDC_FIELD
879          EXPORTING
880            FNAM = 'LFB1-SPERR'
881            FVAL = ''.
882
883        CALL METHOD BDC_DYNPRO
884          EXPORTING
885            PROGRAM = 'SAPMF02K'
886            DYNPRO  = '0510'.
887        CALL METHOD BDC_FIELD
888          EXPORTING
889            FNAM = 'BDC_OKCODE'
890            FVAL = '=UPDA'.  "=BU'.
891      ENDMETHOD.                    "VENDOR_UNLOCK
892
893      METHOD CREATE_SESSION.
894        CALL FUNCTION 'BDC_OPEN_GROUP'
895          EXPORTING
896            CLIENT = SY-MANDT
897            GROUP  = GROUP
898            KEEP   = C_MARK
899            USER   = SY-UNAME.
900      ENDMETHOD.                    "CREATE_SESSION
901
902      METHOD INSERT_BDC_SESSION.
903        CALL FUNCTION 'BDC_INSERT'
904          EXPORTING
905            TCODE     = TCODE
906          TABLES
907            DYNPROTAB = BDCDATA.
908      ENDMETHOD.                    "INSERT_BDC_SESSION
909
910      METHOD CLOSE_SESSION.
911        CALL FUNCTION 'BDC_CLOSE_GROUP'.
912      ENDMETHOD.                    "CLOSE_SESSION
913
914      METHOD BDC_DYNPRO.
915        CLEAR WA_BDC.
916        WA_BDC-PROGRAM = PROGRAM.
917        WA_BDC-DYNPRO = DYNPRO.
918        WA_BDC-DYNBEGIN = 'X'.
919        APPEND WA_BDC TO BDCDATA.
920      ENDMETHOD.                    "BDC_DYNPRO
921
922      METHOD BDC_FIELD.
923        CLEAR WA_BDC.
924    *    IF FVAL IS NOT INITIAL.
925        WA_BDC-FNAM = FNAM.
926        WA_BDC-FVAL = FVAL.
927        APPEND WA_BDC TO BDCDATA.
928    *    ENDIF.
929      ENDMETHOD.                    "BDC_FIELD
930
931      METHOD DISPLAY_ALV.
932        CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
933          EXPORTING
934            I_CALLBACK_PROGRAM = SY-REPID
935            IT_FIELDCAT        = GT_FIELDCAT[]
936            IS_LAYOUT          = GS_LAYOUT
937            IT_SORT            = GT_SORT
938            I_SAVE             = 'A'
939          TABLES
940            T_OUTTAB           = GT_LOAN_DISPLAY.
941      ENDMETHOD.                    "DISPLAY_ALV
942
943      METHOD PREPARE_ALV.
944        REFRESH: GT_FIELDCAT, GT_SORT.
945        CLEAR GS_LAYOUT.
946
947        DEFINE MACRO_FIELDCAT.
948          CLEAR GWA_FIELDCAT.
949
950          ADD 1 TO GV_POS.
951          MOVE: GV_POS TO GWA_FIELDCAT-COL_POS,
952                &1 TO GWA_FIELDCAT-FIELDNAME,
953                &2 TO GWA_FIELDCAT-SELTEXT_L,
954                &3 TO GWA_FIELDCAT-SELTEXT_M,
955                &4 TO GWA_FIELDCAT-DO_SUM,
956                &5 TO GWA_FIELDCAT-KEY,
957                &6 TO GWA_FIELDCAT-NO_OUT,
958                'GT_LOAN_DISPLAY' TO GWA_FIELDCAT-TABNAME.
959
960          APPEND GWA_FIELDCAT TO GT_FIELDCAT.
961        END-OF-DEFINITION.
962
963        DEFINE MACRO_SORT.
964          CLEAR GWA_SORT.
965
966          ADD 1 TO GV_POS.
967          MOVE: GV_POS TO GWA_SORT-SPOS,
968                &1 TO GWA_SORT-FIELDNAME,
969                &2 TO GWA_SORT-UP,
970                &3 TO GWA_SORT-DOWN.
971
972          APPEND GWA_SORT TO GT_SORT.
973        END-OF-DEFINITION.
974
975        GV_POS = 0.
976        MACRO_SORT 'BUKRS' C_MARK ''.
977        MACRO_SORT 'PERNR' C_MARK ''.
978        MACRO_SORT 'SHBKZ' C_MARK ''.
979
980        GS_LAYOUT-COLWIDTH_OPTIMIZE = C_MARK.
981
982        GV_POS = 0.
983        MACRO_FIELDCAT 'PERNR' 'CPF No.' 'CPF No.' '' '' ''.    "#EC NOTEXT
984        MACRO_FIELDCAT 'ENAME' 'Complete Name' 'Complete Name' '' '' SY-BATCH. "#EC NOTEXT
985        MACRO_FIELDCAT 'BEGDA' 'Start Date' 'Start Date' '' '' SY-BATCH. "#EC NOTEXT
986        MACRO_FIELDCAT 'BUKRS' 'Company Code - HR' 'Co. Code - HR' '' '' ''. "#EC NOTEXT
987        MACRO_FIELDCAT 'BUKRS_T' 'Company Code Description - HR' 'Co. Code Desc. - HR' '' '' C_MARK. "#EC NOTEXT
988        MACRO_FIELDCAT 'LIFNR' 'Vendor Code' 'Vendor Code' '' '' ''. "#EC NOTEXT
989        MACRO_FIELDCAT 'LBUKRS' 'Company Code - FI' 'Co. Code - FI' '' '' ''. "#EC NOTEXT
990        MACRO_FIELDCAT 'LBUKRS_T' 'Company Code Description - FI' 'Co. Code Desc. - FI' '' '' C_MARK. "#EC NOTEXT
991        MACRO_FIELDCAT 'PRCTR' 'Profit Centre' 'Profit Centre' '' '' ''. "#EC NOTEXT
992        MACRO_FIELDCAT 'GSBER' 'Business Area' 'Business Area' '' '' ''. "#EC NOTEXT
993        MACRO_FIELDCAT 'SHBKZ' 'Special G/L Indicator' 'SPL G/L' '' '' ''. "#EC NOTEXT
994        MACRO_FIELDCAT 'SHBKZ_T' 'SPL G/L Description' 'SPL G/L Desc.' '' '' SY-BATCH. "#EC NOTEXT
995        MACRO_FIELDCAT 'SALDV' 'Balance Carried Forward in Local Currency' 'Balance Carried Forward' C_MARK '' C_MARK. "#EC NOTEXT
996        MACRO_FIELDCAT 'SOLLL' 'Total of the Debit Postings in the Current Year' 'Total Debit Postings' C_MARK '' C_MARK. "#EC NOTEXT
997        MACRO_FIELDCAT 'HABNL' 'Credit Postings Total in the Current Year' 'Credit Postings Total' C_MARK '' C_MARK. "#EC NOTEXT
998        MACRO_FIELDCAT 'NET_AMOUNT' 'Net Amount' 'Net Amount' C_MARK '' ''. "#EC NOTEXT
999        MACRO_FIELDCAT 'SHKZG' 'Debit/Credit Indicator' 'Debit/Credit Indicator' '' '' C_MARK. "#EC NOTEXT
1000       MACRO_FIELDCAT 'SHKZG_T' 'Text for Debit/Credit Indicator' 'Debit/Credit Indi Desc' '' '' ''. "#EC NOTEXT
1001       MACRO_FIELDCAT 'LFB1_STATUS' 'Vendor in HR Company Code Existence' 'Vendor Existence' '' '' SY-BATCH. "#EC NOTEXT
1002       MACRO_FIELDCAT 'S_LFB1-SPERR' 'Vendor Lock Indicator' 'Vendor Lock Indi.' '' '' SY-BATCH. "#EC NOTEXT
1003       CASE C_MARK.
1004         WHEN R_DIS.
1005         WHEN R_TRA.
1006           MACRO_FIELDCAT 'DOCUMENT_NO' 'Document Number' 'Document No.' '' '' ''. "#EC NOTEXT
1007           MACRO_FIELDCAT 'REMARKS' 'Remarks' 'Remarks' '' '' ''. "#EC NOTEXT
1008       ENDCASE.
1009     ENDMETHOD.                    "PREPARE_ALV
1010   ENDCLASS.                    "LOAN_TRANSFER IMPLEMENTATION
*--- End of ZPY_LOAN_FI_BALANCE_TRANSFER - 1010 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CSLIS                                   Level 1    Page 2
Object           ZPY_LOAN_FI_BALANCE_TRANSFER              Lines 543
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:29
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
Object           ZPY_LOAN_FI_BALANCE_TRANSFER              Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:29
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
Object           ZPY_LOAN_FI_BALANCE_TRANSFER              Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:29
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
Object           ZPY_LOAN_FI_BALANCE_TRANSFER              Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:29
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
Object           ZPY_LOAN_FI_BALANCE_TRANSFER              Lines 1
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:29
----------------------------------------------------------------------------------------------------
1      * INCLUDE DB__SSEL
*--- End of DB__SSEL - 1 lines ---
