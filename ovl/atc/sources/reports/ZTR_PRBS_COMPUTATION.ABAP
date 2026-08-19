----------------------------------------------------------------------------------------------------
Main program     ZTR_PRBS_COMPUTATION                      Level 0    Page 1
Object           ZTR_PRBS_COMPUTATION                      Lines 1257
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:23
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *& Report  ZTR_PRBS_COMPUTATION
3      *&---------------------------------------------------------------------*
4      REPORT  ZTR_PRBS_COMPUTATION MESSAGE-ID ZTR_PRBS.
5
6      *&---------------------------------------------------------------------*
7      *&  Developed By Jagmeet Singh on 13th June 2013
8      *&---------------------------------------------------------------------*
9
10     *----------------------------------------------------------------------*
11     *       CLASS PRBS DEFINITION
12     *----------------------------------------------------------------------*
13     CLASS PRBS DEFINITION.
14       PUBLIC SECTION.
15         METHODS: PROCESS.
16       PRIVATE SECTION.
17         TYPE-POOLS SLIS.
18
19         TYPES: BEGIN OF TY_PA0000,
20                 PERNR TYPE PERSNO,
21                 STAT2 TYPE STAT2,
22                 GBDAT TYPE GBDAT,
23                 SEPDAT TYPE DATUM,
24                END OF TY_PA0000,
25
26                BEGIN OF TY_JOINING,
27                  PERNR TYPE PERSNO,
28                  MASSN TYPE MASSN,
29                  BEGDA TYPE BEGDA,
30                END OF TY_JOINING,
31
32                BEGIN OF TY_BASIC,
33                  PERNR TYPE PERSNO,
34                  BEGDA TYPE BEGDA,
35                  BET01 TYPE PAD_AMT7S,
36                END OF TY_BASIC,
37
38                BEGIN OF TY_PERNR,
39                  PERNR TYPE PERSNO, "Personnel number
40                  KONTRH TYPE TB_KUNNR_NEW,  "Business Partner Number
41                END OF TY_PERNR,
42
43                BEGIN OF TY_VTBFHA,
44                  RFHA TYPE TB_RFHA, "Financial Transaction
45                  KONTRH TYPE TB_KUNNR_NEW,  "Business Partner Number
46                END OF TY_VTBFHA,
47
48                BEGIN OF TY_VTBFHAPO,
49                  RFHA TYPE TB_RFHA, "Financial Transaction
50                  RFHAZB	TYPE TB_RFHAZB, "Transaction flow
51                  BZBETR TYPE TB_BZBETR, "Payment amount in payment currency
52                  SSIGN TYPE TB_SSIGN, "Direction of flow
53                  DZTERM TYPE TB_DZTERM, "Payment or Delivery Date
54                END OF TY_VTBFHAPO,
55
56                BEGIN OF TY_DARNS,
57                  PERNR TYPE PERSNO, "Personnel number
58                  DOJDT TYPE DATUM,  "Date of join of PRBS
59                END OF TY_DARNS,
60
61                BEGIN OF TY_PAID_BENEFIT,
62                  PARTNR TYPE BU_PARTNER,    "Business Partner Number
63                  V_C TYPE ZV_C,             "Commutation
64                  V_NETC TYPE ZV_NETC,       "Net Corpus
65                  TYP_ANNU TYPE ZTYP_ANNU,   "Type Of Annuity
66                  SETT_DATE TYPE ZSETT_DATE, "Settlement Date
67                  DT_JOIN_TRUST TYPE DATUM,  "Date of Joining PRBS
68                  ROI TYPE ZROI,             "Rate of Interest
69                  V_C_ADD TYPE ZV_C_ADD,
70                  V_NET_LIC TYPE ZTRAMT,
71                  V_NET_LIC_ADD TYPE ZTRAMT,
72                  V_PAS_CONT TYPE ZV_PAS_CONT,
73                  V_FUT_CONT TYPE ZV_FUT_CONT,
74                  INT_ON_PSC TYPE ZINT_ON_PSC,
75                END OF TY_PAID_BENEFIT,
76
77                BEGIN OF TY_PRBS_SUMMARY,
78                  PERNR TYPE PERSNO,         "Personnel number
79                  CALC_TYPE TYPE ZCALC_TYPE, "PRBS Calculation Type
80                  TOTAL TYPE ZTOTAL2,        "Total
81                END OF TY_PRBS_SUMMARY,
82
83                BEGIN OF TY_PERSNO,
84                  SIGN TYPE C LENGTH 1,
85                  OPTION TYPE C LENGTH 2,
86                  LOW TYPE PERSNO,
87                  HIGH TYPE PERSNO,
88                END OF TY_PERSNO,
89
90                BEGIN OF TY_FINAL,
91                  PERNR TYPE PERSNO, "Personnel number
92                  ENAME TYPE EMNAM,  "Field name
93                  PERSG TYPE PERSG,  "Employee Group
94                  PERSG_T TYPE PGTXT,  "Name of Employee Group
95                  PERSK TYPE PERSK,  "Employee Subgroup
96                  STAT2 TYPE STAT2,  "Employment Status
97                  STAT2_T TYPE TEXT40, "Employment Status Text
98                  WERKS TYPE PERSA,  "Personnel Area
99                  SACHP TYPE SACHP,  "Establishment Head
100                 MASSN TYPE MASSN,  "Action Type
101                 MASSG TYPE MASSG,  "Reason for Action
102                 MASSG_T TYPE MGTXT, "Reason for Action Text
103                 GBDAT TYPE GBDAT,  "Date of Birth
104                 SEPDAT TYPE DATUM, "Seperation Date
105                 JDATE TYPE DATUM,  "Joining Date
106                 DOJS TYPE DATUM,   "Date of Joining Scheme
107                 BASICD TYPE DATUM, "Basic as on
108                 BET01 TYPE PAD_AMT7S,  "Basic Pay
109                 PAST_SERVICE TYPE PEA_SCRYY,  "Past Service
110                 FUTURE_SERVICE TYPE PEA_SCRYY,  "Future Service
111                 RPAST_SERVICE TYPE PEA_SCRYY, "Recknable Past Service
112                 RFUTURE_SERVICE TYPE PEA_SCRYY,  "Recknable Future Service
113                 RTOTAL_SERVICE TYPE PEA_SCRYY,  "Total Recknable Service
114                 RMAX_SERVICE TYPE PEA_SCRYY,  "Max Recknable Service
115                 MAX_BENEFIT TYPE C LENGTH 3, "PEA_SCRYY, "Max Benefit
116                 PENSION TYPE BYZTR, "Pension Percentage
117                 PENSION_PERCENT TYPE C LENGTH 8, "Pension Percentage
118                 PENSION_AMOUNT TYPE P LENGTH 13 DECIMALS 2,  "Pension Amount
119                 LICAR TYPE P LENGTH 8 DECIMALS 5, "LIC AR
120                 CORPUS TYPE P LENGTH 13 DECIMALS 2, "Corpus
121                 DIS_PERIOD TYPE PEA_SCRYY, "Discount Period
122                 DIS_RATE TYPE C LENGTH 5,   "Discounting Rate
123                 NPV TYPE P LENGTH 13 DECIMALS 2, "Net Present Value
124                 ESC_FACTOR TYPE PEA_SCRYY, "Escalation Factor
125                 ESC_AMOUNT TYPE P LENGTH 13 DECIMALS 2, "Escalated Amount
126                 OWN_CONT TYPE P LENGTH 13 DECIMALS 2, "Own Contribution
127                 TYP_ANNU TYPE ZTYP_ANNU, "Type Of Annuity
128                 V_C_N TYPE ZV_C,  "Commutation New
129                 V_NETC_N TYPE ZV_NETC, "Net Corpus New
130                 BENEFIT TYPE P LENGTH 13 DECIMALS 2, "Benefit
131                 V_C TYPE ZV_C,  "Commutation Old
132                 V_NETC TYPE ZV_NETC, "Net Corpus Old
133                 APAID TYPE P LENGTH 13 DECIMALS 2, "Already Paid
134                 V_C_D TYPE ZV_C,  "Commutation Difference
135                 V_NETC_D TYPE ZV_NETC, "Net Corpus Difference
136    *             TPAID_WOI TYPE P LENGTH 12 DECIMALS 2, "Difference To be Paid w/o interest
137                 ROI TYPE ZROI, "Rate of Interest
138                 MONTHS TYPE C LENGTH 4,  "Months
139                 V_NETC_INTEREST TYPE P LENGTH 12 DECIMALS 2, "Net Corpus Interest
140                 TPAID_WTI TYPE P LENGTH 12 DECIMALS 2, "Difference To be Paid w/t interest
141                 SHORT_EXCESS TYPE P LENGTH 12 DECIMALS 2, "Short/Excess
142                 TOT_PAYMENT TYPE P LENGTH 12 DECIMALS 2, "Total Payment
143                 ETYPE TYPE C LENGTH 1, "A = Active, S = Seperated
144               END OF TY_FINAL.
145
146        DATA: GT_PA0000 TYPE STANDARD TABLE OF TY_PA0000,
147              WA_00 TYPE TY_PA0000,
148              GT_PA0302 TYPE STANDARD TABLE OF PA0302,
149              WA_302 TYPE PA0302,
150              GT_PA0001 TYPE STANDARD TABLE OF PA0001,
151              WA_01 TYPE PA0001,
152              GT_JOIN TYPE STANDARD TABLE OF TY_JOINING,
153              WA_JOIN TYPE TY_JOINING,
154              GT_BASIC TYPE STANDARD TABLE OF TY_BASIC,
155              WA_BASIC TYPE TY_BASIC,
156              GT_FINAL TYPE STANDARD TABLE OF TY_FINAL,
157              WA_FINAL TYPE TY_FINAL,
158              GT_PERNR TYPE STANDARD TABLE OF TY_PERNR,
159              WA_PERNR TYPE TY_PERNR,
160              GT_T530T TYPE STANDARD TABLE OF T530T,
161              WA_T530T TYPE T530T,
162              GT_T501T TYPE STANDARD TABLE OF T501T,
163              WA_T501T TYPE T501T,
164              GT_VT TYPE STANDARD TABLE OF TY_VTBFHA,
165              WA_VT TYPE TY_VTBFHA,
166              GT_VTPO TYPE STANDARD TABLE OF TY_VTBFHAPO,
167              WA_VTPO TYPE TY_VTBFHAPO,
168              GT_DARNS TYPE STANDARD TABLE OF TY_DARNS,
169              WA_DARNS TYPE TY_DARNS,
170              GT_PAID TYPE STANDARD TABLE OF TY_PAID_BENEFIT,
171              WA_PAID TYPE TY_PAID_BENEFIT,
172              GT_STORE TYPE STANDARD TABLE OF ZTRPRBS_SUMM,
173              WA_STORE TYPE ZTRPRBS_SUMM,
174              GT_PERSNO TYPE STANDARD TABLE OF TY_PERSNO,
175              WA_PERSNO TYPE TY_PERSNO,
176              GT_PRBS_SUMMARY TYPE STANDARD TABLE OF TY_PRBS_SUMMARY,
177              WA_PRBS TYPE TY_PRBS_SUMMARY,
178
179              GV_TPERNR TYPE I,
180              GV_PROGRESS_TEXT TYPE C LENGTH 60,
181              GV_FY TYPE C LENGTH 4,
182              GV_FY_FRD TYPE C LENGTH 4,
183              GV_FY2 TYPE T009B-BDATJ,
184              GV_FY_FIRST_DAY TYPE DATUM,
185              GV_FY_LAST_DAY TYPE DATUM,
186              GV_DAYS_YEAR TYPE PEA_SCRDD,
187              GV_MONTHS_FRD TYPE PEA_SCRMM,
188              GV_MONTHS TYPE C LENGTH 12,
189              GV_MONTHS_DECIMAL TYPE C LENGTH 4,
190              GV_CFY TYPE C LENGTH 4,
191              GV_CFY2 TYPE T009B-BDATJ,
192              GV_DAYS_FRD TYPE PEA_SCRDD,
193              GV_CFY_FIRST_DAY TYPE DATUM,
194              GV_CFY_LAST_DAY TYPE DATUM,
195              GV_DAYS_CYEAR TYPE PEA_SCRDD,
196              GV_LCOUNT TYPE I,
197              GV_DOC TYPE DATUM,
198
199              GT_FIELDCAT TYPE STANDARD TABLE OF SLIS_FIELDCAT_ALV,
200              GWA_FIELDCAT TYPE SLIS_FIELDCAT_ALV,
201              GT_SORT TYPE SLIS_T_SORTINFO_ALV,
202              GWA_SORT TYPE SLIS_SORTINFO_ALV,
203              GS_LAYOUT TYPE SLIS_LAYOUT_ALV,
204              GV_POS TYPE I VALUE 0,
205              GV_TEXT TYPE C LENGTH 60,
206              GV_TEXT1 TYPE C LENGTH 60.
207
208        METHODS: GET_ACTIVE_LIST,
209                 GET_SEPERATED_LIST,
210                 GET_TREASURY_MONEY,
211                 CONSOLIDATE_LIST,
212                 CALCULATE_INTEREST
213                  IMPORTING I_SEPDATE TYPE DATUM
214                            I_TPAID_WOI TYPE ANY
215                            I_ROI TYPE ZROI
216                            I_FRD TYPE DATUM
217                            I_INT TYPE C
218                            I_INTD TYPE DATUM
219                  CHANGING  EC_TPAID_WTI TYPE ANY,
220                 CALCULATE_INTEREST_NEW
221                  IMPORTING I_SETT_DATE TYPE DATUM
222                            I_TPAID_WOI TYPE ANY
223                            I_ROI TYPE ZROI
224                            I_FRD TYPE DATUM
225                            I_INT TYPE C
226                            I_INTD TYPE DATUM
227                  EXPORTING E_MONTHS TYPE CHAR4
228                            E_V_NETC_INTEREST TYPE ANY
229                            E_TPAID_WTI TYPE ANY,
230                 DISPLAY_ALV,
231                 PREPARE_ALV,
232                 ALV_HEADER_BUILD.
233
234    ENDCLASS.                    "PRBS DEFINITION
235
236    *&---------------------------------------------------------------------*
237    *& Global Declaration
238    *&---------------------------------------------------------------------*
239    TABLES: PA0001, PA0302, VTBFHAPO.
240
241    CONSTANTS C_MARK TYPE C LENGTH 1 VALUE 'X'.
242
243    DATA: O_PRBS TYPE REF TO PRBS,
244          GT_LISTHEADER TYPE SLIS_T_LISTHEADER,
245          WA_LISTHEADER TYPE SLIS_LISTHEADER.
246
247
248    *&---------------------------------------------------------------------*
249    *& Selection Screen
250    *&---------------------------------------------------------------------*
251    SELECTION-SCREEN BEGIN OF BLOCK A1 WITH FRAME TITLE TEXT-001.
252    SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-002.
253    PARAMETERS: R_ACTIV RADIOBUTTON GROUP RG1 USER-COMMAND UCOMM DEFAULT 'X',
254                R_SEPER RADIOBUTTON GROUP RG1.
255    SELECTION-SCREEN END OF BLOCK B1.
256    SELECTION-SCREEN BEGIN OF BLOCK B2 WITH FRAME TITLE TEXT-003.
257    SELECT-OPTIONS: S_PERNR FOR PA0001-PERNR NO INTERVALS,  "Personnel number
258                    S_WERKS FOR PA0001-WERKS NO INTERVALS,  "Personnel Area
259                    S_MASSN FOR PA0302-MASSN NO INTERVALS MODIF ID SEP NO-DISPLAY, "Action Type
260                    S_MASSG FOR PA0302-MASSG NO INTERVALS MODIF ID SEP, "Reason for Action
261                    S_PERSG FOR PA0001-PERSG NO INTERVALS OBLIGATORY,  "Employee Group
262    *                S_SACHP FOR PA0001-SACHP NO INTERVALS,  "Administrator for HR Master Data
263                    S_FTYPE FOR VTBFHAPO-SFHAZBA NO INTERVALS.  "Flow Type
264    SELECTION-SCREEN SKIP 1.
265    PARAMETERS: P_INT AS CHECKBOX MODIF ID SEP,  "Calculate interest on post FRD seperations
266                P_INTD TYPE DATUM MODIF ID SEP OBLIGATORY.  "Interest Upto (for above)
267    SELECTION-SCREEN END OF BLOCK B2.
268    SELECTION-SCREEN BEGIN OF BLOCK B3 WITH FRAME TITLE TEXT-004.
269    PARAMETERS: P_DOC TYPE DATUM OBLIGATORY, "Date of Conversion
270                P_FRD TYPE DATUM OBLIGATORY, "Fund Reckoning Date
271                P_LICAR TYPE P LENGTH 8 DECIMALS 5 OBLIGATORY, "LIC AR
272                P_MBEN TYPE  AGKPZ OBLIGATORY,  "Max Benefit
273                P_MSERV TYPE I OBLIGATORY, "Max Service
274                P_DRATE TYPE  AGKPZ OBLIGATORY. "Discounting Rate
275    *            P_ROI TYPE ZROI OBLIGATORY MODIF ID SEP.  "Rate of Interest
276    SELECTION-SCREEN END OF BLOCK B3.
277    SELECTION-SCREEN END OF BLOCK A1.
278
279    *&---------------------------------------------------------------------*
280    *& Events
281    *&---------------------------------------------------------------------*
282    INITIALIZATION.
283      S_MASSN-SIGN = 'I'.
284      S_MASSN-OPTION = 'EQ'.
285      S_MASSN-LOW = '40'.
286      S_MASSN-HIGH = ''.
287      APPEND S_MASSN. "Action Type
288      S_MASSN-SIGN = 'I'.
289      S_MASSN-OPTION = 'EQ'.
290      S_MASSN-LOW = '11'.
291      S_MASSN-HIGH = ''.
292      APPEND S_MASSN. "Action Type
293      P_DOC = '20070101'. "Date of Conversion
294      P_FRD = '20120331'. "Fund Reckoning Date
295      P_LICAR = '132.59669'.  "LIC AR
296      P_MBEN = '50'.  "Max Benefit
297      P_MSERV = '33'. "Max Service
298      P_DRATE = '9.5'.  "Discounting Rate
299    *  P_ROI = '9.5'. "Rate of Interest
300      P_INTD = SY-DATUM.  "Interest Upto
301
302    AT SELECTION-SCREEN OUTPUT.
303      LOOP AT SCREEN.
304        CASE C_MARK.
305          WHEN R_ACTIV.
306            CASE SCREEN-GROUP1.
307              WHEN 'SEP'.
308                SCREEN-ACTIVE = 0.
309            ENDCASE.
310          WHEN R_SEPER.
311            CASE SCREEN-GROUP1.
312              WHEN 'SEP'.
313                SCREEN-ACTIVE = 1.
314            ENDCASE.
315        ENDCASE.
316        MODIFY SCREEN.
317      ENDLOOP.
318
319    START-OF-SELECTION.
320      IF P_DOC GE P_FRD.
321        MESSAGE S002 DISPLAY LIKE 'E'.
322      ELSE.
323        CREATE OBJECT O_PRBS.
324        CALL METHOD O_PRBS->PROCESS.
325      ENDIF.
326
327    *----------------------------------------------------------------------*
328    *       CLASS PRBS IMPLEMENTATION
329    *----------------------------------------------------------------------*
330    CLASS PRBS IMPLEMENTATION.
331      METHOD PROCESS.
332        CASE C_MARK.
333          WHEN R_ACTIV.
334            CALL METHOD GET_ACTIVE_LIST.
335          WHEN R_SEPER.
336            IF S_MASSG[] IS NOT INITIAL.
337              CALL METHOD GET_SEPERATED_LIST.
338            ELSE.
339              MESSAGE S001 DISPLAY LIKE 'E'.
340            ENDIF.
341        ENDCASE.
342        IF GT_PERNR[] IS NOT INITIAL.
343          CALL METHOD GET_TREASURY_MONEY.
344          CALL METHOD CONSOLIDATE_LIST.
345        ENDIF.
346        IF GT_FINAL[] IS NOT INITIAL.
347          CALL METHOD PREPARE_ALV.
348          CALL METHOD ALV_HEADER_BUILD.
349          CALL METHOD DISPLAY_ALV.
350        ELSE.
351          MESSAGE S000 DISPLAY LIKE 'E'.
352        ENDIF.
353      ENDMETHOD.                    "PROCESS
354
355      METHOD GET_ACTIVE_LIST.
356        REFRESH: GT_PA0000, GT_PA0001, GT_JOIN, GT_BASIC, GT_PERNR.
357
358        SELECT A~PERNR A~STAT2 B~GBDAT FROM PA0000 AS A
359          INNER JOIN PA0002 AS B ON B~PERNR = A~PERNR
360          INTO TABLE GT_PA0000
361          WHERE A~PERNR IN S_PERNR AND
362                A~ENDDA GE SY-DATUM AND
363                A~BEGDA LE SY-DATUM AND
364                A~STAT2 EQ '3'.
365
366        LOOP AT GT_PA0000 INTO WA_00.
367          CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
368            EXPORTING
369              DATE      = WA_00-GBDAT
370              DAYS      = '00'
371              MONTHS    = '00'
372              SIGNUM    = '+'
373              YEARS     = '60'
374            IMPORTING
375              CALC_DATE = WA_00-SEPDAT.
376
377          IF WA_00-SEPDAT+6(2) EQ '01'.
378            WA_00-SEPDAT = WA_00-SEPDAT - 1.
379          ELSE.
380    *        CALL FUNCTION 'LAST_DAY_OF_MONTHS'
381    *          EXPORTING
382    *            DAY_IN            = WA_00-SEPDAT
383    *          IMPORTING
384    *            LAST_DAY_OF_MONTH = WA_00-SEPDAT.
385            CALL FUNCTION 'OIL_LAST_DAY_OF_MONTH'
386              EXPORTING
387                i_date           = WA_00-SEPDAT
388             IMPORTING
389               E_LAST_DAY       = WA_00-SEPDAT
390                      .
391
392          ENDIF.
393
394          MODIFY GT_PA0000 FROM WA_00 TRANSPORTING SEPDAT.
395        ENDLOOP.
396
397        DELETE GT_PA0000 WHERE SEPDAT LT P_DOC. "'20070101'.
398
399        IF GT_PA0000[] IS NOT INITIAL.
400          SELECT PERNR ENAME WERKS SACHP PERSG PERSK FROM PA0001 INTO CORRESPONDING FIELDS OF TABLE GT_PA0001
401            FOR ALL ENTRIES IN GT_PA0000
402            WHERE PERNR EQ GT_PA0000-PERNR AND
403                  ENDDA GE SY-DATUM AND
404                  BEGDA LE SY-DATUM AND
405                  WERKS IN S_WERKS AND
406                  PERSG IN S_PERSG AND
407                  PERSK NE 'TR' AND
408                  BUKRS NE 'OBV'.
409
410          SELECT PERNR MASSN BEGDA FROM PA0302 INTO CORRESPONDING FIELDS OF TABLE GT_JOIN
411            FOR ALL ENTRIES IN GT_PA0000
412            WHERE PERNR EQ GT_PA0000-PERNR AND
413                  MASSN IN ('01','ZA','Z2').
414
415          SORT GT_JOIN BY PERNR ASCENDING
416                          BEGDA DESCENDING.
417          DELETE ADJACENT DUPLICATES FROM GT_JOIN COMPARING PERNR.
418          DELETE GT_JOIN WHERE BEGDA GE P_DOC.  "'20070101'.
419
420          SELECT PERNR BEGDA BET01 FROM PA0008 INTO TABLE GT_BASIC
421            FOR ALL ENTRIES IN GT_PA0000
422            WHERE PERNR EQ GT_PA0000-PERNR AND
423                  SUBTY EQ '0' AND
424                  ENDDA GE P_DOC AND  "'20070101' AND
425                  SPRPS EQ SPACE AND
426                  LGA01 EQ '9001'.
427
428          SORT GT_BASIC BY PERNR BEGDA.
429          DELETE ADJACENT DUPLICATES FROM GT_BASIC COMPARING PERNR.
430
431          LOOP AT GT_PA0000 INTO WA_00.
432            WA_PERNR-PERNR = WA_00-PERNR.
433
434            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
435              EXPORTING
436                INPUT  = WA_PERNR-PERNR
437              IMPORTING
438                OUTPUT = WA_PERNR-KONTRH.
439
440            APPEND WA_PERNR TO GT_PERNR.
441          ENDLOOP.
442
443          SORT GT_PERNR BY PERNR.
444          DELETE ADJACENT DUPLICATES FROM GT_PERNR COMPARING PERNR.
445        ENDIF.
446      ENDMETHOD.                    "GET_ACTIVE_LIST
447
448      METHOD GET_SEPERATED_LIST.
449        REFRESH: GT_PA0000, GT_PA0302, GT_PA0001, GT_JOIN, GT_BASIC, GT_PERNR, GT_T530T, GT_PAID.
450        CLEAR GV_DOC.
451
452        SELECT PERNR STAT2 FROM PA0000 INTO CORRESPONDING FIELDS OF TABLE GT_PA0000
453          WHERE PERNR IN S_PERNR AND
454                ENDDA GE SY-DATUM AND
455                BEGDA LE SY-DATUM AND
456                STAT2 EQ '0'.
457
458        IF GT_PA0000[] IS NOT INITIAL.
459          SELECT PERNR BEGDA MASSN MASSG FROM PA0302 INTO CORRESPONDING FIELDS OF TABLE GT_PA0302
460            FOR ALL ENTRIES IN GT_PA0000
461            WHERE PERNR EQ GT_PA0000-PERNR AND
462                  MASSN IN ('11','40','Z2') AND
463                  MASSG IN S_MASSG.
464
465          SORT GT_PA0302 BY PERNR ASCENDING
466                            BEGDA DESCENDING.
467          DELETE ADJACENT DUPLICATES FROM GT_PA0302 COMPARING PERNR.
468          DELETE GT_PA0302 WHERE MASSN EQ 'Z2'.
469          GV_DOC = P_DOC + 1.
470          DELETE GT_PA0302 WHERE BEGDA LT GV_DOC.  "'20070101'.
471
472          IF GT_PA0302[] IS NOT INITIAL.
473            SELECT PERNR ENAME WERKS SACHP PERSG PERSK FROM PA0001 INTO CORRESPONDING FIELDS OF TABLE GT_PA0001
474            FOR ALL ENTRIES IN GT_PA0302
475            WHERE PERNR EQ GT_PA0302-PERNR AND
476                  ENDDA GE SY-DATUM AND
477                  BEGDA LE SY-DATUM AND
478                  WERKS IN S_WERKS AND
479                  PERSG IN S_PERSG AND
480                  PERSK NE 'TR' AND
481                  BUKRS NE 'OBV'.
482
483            SELECT PERNR MASSN BEGDA FROM PA0302 INTO CORRESPONDING FIELDS OF TABLE GT_JOIN
484              FOR ALL ENTRIES IN GT_PA0302
485              WHERE PERNR EQ GT_PA0302-PERNR AND
486                    MASSN IN ('01','ZA','Z2').
487
488            SORT GT_JOIN BY PERNR ASCENDING
489                            BEGDA DESCENDING.
490            DELETE ADJACENT DUPLICATES FROM GT_JOIN COMPARING PERNR.
491            DELETE GT_JOIN WHERE BEGDA GE P_DOC.  "'20070101'.
492
493            SELECT PERNR BEGDA BET01 FROM PA0008 INTO TABLE GT_BASIC
494            FOR ALL ENTRIES IN GT_PA0302
495            WHERE PERNR EQ GT_PA0302-PERNR AND
496                  SUBTY EQ '0' AND
497                  SPRPS EQ SPACE AND
498                  ENDDA GE P_DOC AND  "'20070101' AND
499                  LGA01 EQ '9001'.
500
501            SORT GT_BASIC BY PERNR BEGDA.
502            DELETE ADJACENT DUPLICATES FROM GT_BASIC COMPARING PERNR.
503
504            SELECT * FROM T530T INTO TABLE GT_T530T
505              FOR ALL ENTRIES IN GT_PA0302
506              WHERE SPRSL EQ 'EN' AND
507                    MASSN EQ GT_PA0302-MASSN AND
508                    MASSG EQ GT_PA0302-MASSG.
509
510            LOOP AT GT_PA0302 INTO WA_302.
511              WA_PERNR-PERNR = WA_302-PERNR.
512
513              CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
514                EXPORTING
515                  INPUT  = WA_PERNR-PERNR
516                IMPORTING
517                  OUTPUT = WA_PERNR-KONTRH.
518
519              APPEND WA_PERNR TO GT_PERNR.
520            ENDLOOP.
521
522            SORT GT_PERNR BY PERNR.
523            DELETE ADJACENT DUPLICATES FROM GT_PERNR COMPARING PERNR.
524
525            IF GT_PERNR[] IS NOT INITIAL. "PRBS Settelement Claim
526              SELECT A~PARTNR A~V_C A~V_NETC A~TYP_ANNU A~SETT_DATE A~DT_JOIN_TRUST B~ROI
527                     A~V_C_ADD A~V_NET_LIC A~V_NET_LIC_ADD A~V_PAS_CONT A~V_FUT_CONT A~INT_ON_PSC
528                FROM ZTRPFBPPRBS AS A
529                LEFT OUTER JOIN ZPY_ANNUITY_ROI AS B ON B~TYP_ANNU = A~TYP_ANNU
530                INTO TABLE GT_PAID
531                FOR ALL ENTRIES IN GT_PERNR
532                WHERE A~PARTNR EQ GT_PERNR-KONTRH.
533            ENDIF.
534          ENDIF.
535        ENDIF.
536      ENDMETHOD.                    "GET_SEPERATED_LIST
537
538      METHOD CALCULATE_INTEREST.
539        CLEAR: GV_FY, GV_FY_FIRST_DAY, GV_FY_LAST_DAY, GV_DAYS_YEAR, GV_LCOUNT, GV_FY2,
540               GV_CFY, GV_DAYS_FRD, GV_CFY_FIRST_DAY, GV_CFY_LAST_DAY, GV_DAYS_CYEAR, GV_FY_FRD.
541
542        CALL FUNCTION 'ZGM_GET_FISCAL_YEAR'
543          EXPORTING
544            I_DATE = I_SEPDATE
545            I_FYV  = 'V3'
546          IMPORTING
547            E_FY   = GV_FY.
548
549        GV_FY2 = GV_FY.
550
551        CALL FUNCTION 'FIRST_AND_LAST_DAY_IN_YEAR_GET'
552          EXPORTING
553            I_GJAHR     = GV_FY2
554            I_PERIV     = 'V3'
555          IMPORTING
556            E_FIRST_DAY = GV_FY_FIRST_DAY
557            E_LAST_DAY  = GV_FY_LAST_DAY.
558
559        CALL FUNCTION 'HR_HK_DIFF_BT_2_DATES'
560          EXPORTING
561            DATE1         = GV_FY_LAST_DAY
562            DATE2         = GV_FY_FIRST_DAY
563            OUTPUT_FORMAT = '02'
564          IMPORTING
565            DAYS          = GV_DAYS_YEAR.
566
567        CALL FUNCTION 'ZGM_GET_FISCAL_YEAR'
568          EXPORTING
569            I_DATE = SY-DATUM
570            I_FYV  = 'V3'
571          IMPORTING
572            E_FY   = GV_CFY.
573
574        GV_CFY2 = GV_CFY.
575
576        CALL FUNCTION 'FIRST_AND_LAST_DAY_IN_YEAR_GET'
577          EXPORTING
578            I_GJAHR     = GV_CFY2
579            I_PERIV     = 'V3'
580          IMPORTING
581            E_FIRST_DAY = GV_CFY_FIRST_DAY
582            E_LAST_DAY  = GV_CFY_LAST_DAY.
583
584        CALL FUNCTION 'HR_HK_DIFF_BT_2_DATES'
585          EXPORTING
586            DATE1         = GV_CFY_LAST_DAY
587            DATE2         = GV_CFY_FIRST_DAY
588            OUTPUT_FORMAT = '02'
589          IMPORTING
590            DAYS          = GV_DAYS_CYEAR.
591
592        CASE C_MARK.
593          WHEN I_INT.
594            IF I_SEPDATE GE GV_CFY_FIRST_DAY.
595              CALL FUNCTION 'HR_HK_DIFF_BT_2_DATES'
596                EXPORTING
597                  DATE1         = I_INTD
598                  DATE2         = I_SEPDATE
599                  OUTPUT_FORMAT = '02'
600                IMPORTING
601                  DAYS          = GV_DAYS_FRD.
602
603              EC_TPAID_WTI =  ( ( I_TPAID_WOI * I_ROI * GV_DAYS_FRD ) / ( GV_DAYS_CYEAR * 100 ) ) + I_TPAID_WOI.
604            ENDIF.
605
606            IF I_SEPDATE GT P_FRD AND
607               I_SEPDATE LT GV_CFY_FIRST_DAY.
608              CLEAR GV_DAYS_FRD.
609              CALL FUNCTION 'HR_HK_DIFF_BT_2_DATES'
610                EXPORTING
611                  DATE1         = GV_FY_LAST_DAY
612                  DATE2         = I_SEPDATE
613                  OUTPUT_FORMAT = '02'
614                IMPORTING
615                  DAYS          = GV_DAYS_FRD.
616
617              EC_TPAID_WTI =  ( ( I_TPAID_WOI * I_ROI * GV_DAYS_FRD ) / ( GV_DAYS_YEAR * 100 ) ) + I_TPAID_WOI.
618
619              CLEAR GV_DAYS_FRD.
620              CALL FUNCTION 'HR_HK_DIFF_BT_2_DATES'
621                EXPORTING
622                  DATE1         = I_INTD
623                  DATE2         = GV_CFY_FIRST_DAY
624                  OUTPUT_FORMAT = '02'
625                IMPORTING
626                  DAYS          = GV_DAYS_FRD.
627
628              EC_TPAID_WTI =  ( ( I_TPAID_WOI * I_ROI * GV_DAYS_FRD ) / ( GV_DAYS_CYEAR * 100 ) ) + EC_TPAID_WTI.
629            ENDIF.
630          WHEN OTHERS.
631        ENDCASE.
632
633        IF I_SEPDATE LE P_FRD.
634          CLEAR GV_DAYS_FRD.
635          CALL FUNCTION 'HR_HK_DIFF_BT_2_DATES'
636            EXPORTING
637              DATE1         = GV_FY_LAST_DAY
638              DATE2         = I_SEPDATE
639              OUTPUT_FORMAT = '02'
640            IMPORTING
641              DAYS          = GV_DAYS_FRD.
642
643          EC_TPAID_WTI =  ( ( I_TPAID_WOI * I_ROI * GV_DAYS_FRD ) / ( GV_DAYS_YEAR * 100 ) ) + I_TPAID_WOI.
644
645          CALL FUNCTION 'ZGM_GET_FISCAL_YEAR'
646            EXPORTING
647              I_DATE = I_FRD
648              I_FYV  = 'V3'
649            IMPORTING
650              E_FY   = GV_FY_FRD.
651
652          GV_LCOUNT = GV_FY_FRD - GV_FY.
653
654          DO GV_LCOUNT TIMES.
655            EC_TPAID_WTI =  ( ( I_TPAID_WOI * I_ROI ) / 100 ) + EC_TPAID_WTI.
656          ENDDO.
657        ENDIF.
658      ENDMETHOD.                    "CALCULATE_INTEREST
659
660      METHOD CALCULATE_INTEREST_NEW.
661        CLEAR: GV_MONTHS_FRD, E_MONTHS, GV_MONTHS_DECIMAL, GV_MONTHS.
662
663        IF P_FRD GT I_SETT_DATE.
664          CALL FUNCTION 'HR_HK_DIFF_BT_2_DATES'
665            EXPORTING
666              DATE1         = I_FRD
667              DATE2         = I_SETT_DATE
668              OUTPUT_FORMAT = '04'
669            IMPORTING
670              MONTHS        = GV_MONTHS_FRD.
671        ELSE.
672          CASE C_MARK.
673            WHEN I_INT.
674              CALL FUNCTION 'HR_HK_DIFF_BT_2_DATES'
675                EXPORTING
676                  DATE1         = I_INTD
677                  DATE2         = I_SETT_DATE
678                  OUTPUT_FORMAT = '04'
679                IMPORTING
680                  MONTHS        = GV_MONTHS_FRD.
681            WHEN OTHERS.
682          ENDCASE.
683        ENDIF.
684
685        MOVE GV_MONTHS_FRD TO GV_MONTHS.
686        CONDENSE GV_MONTHS.
687        SPLIT GV_MONTHS AT '.' INTO E_MONTHS GV_MONTHS_DECIMAL.
688        CONDENSE: E_MONTHS, GV_MONTHS_DECIMAL.
689
690        E_V_NETC_INTEREST = ( ( I_TPAID_WOI * I_ROI * E_MONTHS ) / ( 1200 ) ).
691        E_TPAID_WTI = E_V_NETC_INTEREST + I_TPAID_WOI.
692      ENDMETHOD.                    "CALCULATE_INTEREST_NEW
693
694      METHOD GET_TREASURY_MONEY.
695        REFRESH: GT_VT, GT_VTPO.
696
697        CALL FUNCTION 'PROGRESS_INDICATOR'
698          EXPORTING
699            I_TEXT               = 'Computing employee''''s own contribution'
700            I_OUTPUT_IMMEDIATELY = C_MARK.                      "#EC NOTEXT
701
702    *      SELECT * FROM VTBFHA INTO TABLE GT_VT
703        SELECT RFHA KONTRH FROM VTBFHA INTO TABLE GT_VT
704          FOR ALL ENTRIES IN GT_PERNR
705          WHERE BUKRS EQ 'PRBS' AND
706                SGSART EQ 'Z54' AND
707                SFHAART EQ '200' AND
708                KONTRH EQ GT_PERNR-KONTRH AND
709                SAKTIV NE '3'.
710
711        IF GT_VT[] IS NOT INITIAL.
712    *      SELECT * FROM VTBFHAPO INTO TABLE GT_VTPO
713          SELECT RFHA RFHAZB BZBETR SSIGN DZTERM FROM VTBFHAPO INTO TABLE GT_VTPO
714            FOR ALL ENTRIES IN GT_VT
715            WHERE BUKRS EQ 'PRBS' AND
716                  RFHA EQ GT_VT-RFHA AND
717                  DZTERM LE '20061231' AND
718                  SFHAZBA IN S_FTYPE AND
719                  SBEWEBE IN ('1','2').
720        ENDIF.
721      ENDMETHOD.                    "GET_TREASURY_MONEY
722
723      METHOD CONSOLIDATE_LIST.
724        REFRESH: GT_FINAL, GT_T501T, GT_DARNS, GT_PRBS_SUMMARY, GT_STORE, GT_PERSNO.
725        CLEAR GV_TPERNR.
726
727        SELECT PERNR DOJDT FROM ZHR_PRBS_DARNS INTO TABLE GT_DARNS
728            FOR ALL ENTRIES IN GT_PERNR
729            WHERE PERNR EQ GT_PERNR-PERNR.
730
731        SELECT PERNR CALC_TYPE TOTAL FROM ZTRPRBS_SUMM INTO TABLE GT_PRBS_SUMMARY
732          FOR ALL ENTRIES IN GT_PERNR
733          WHERE PERNR EQ GT_PERNR-PERNR AND
734                CALC_TYPE EQ '1'.
735
736        IF GT_PA0001[] IS NOT INITIAL.
737          SELECT * FROM T501T INTO TABLE GT_T501T
738            FOR ALL ENTRIES IN GT_PA0001
739            WHERE SPRSL EQ 'EN' AND
740                  PERSG EQ GT_PA0001-PERSG.
741
742          LOOP AT GT_T501T INTO WA_T501T WHERE PERSG EQ '1'.
743            WA_T501T-PTEXT = 'Regular Employee'.                "#EC NOTEXT
744            MODIFY GT_T501T FROM WA_T501T TRANSPORTING PTEXT.
745          ENDLOOP.
746        ENDIF.
747
748        SORT: GT_PA0001 BY PERNR,
749              GT_PA0000 BY PERNR,
750              GT_PA0302 BY PERNR,
751              GT_JOIN BY PERNR,
752              GT_BASIC BY PERNR,
753              GT_T530T BY MASSN MASSG,
754              GT_T501T BY PERSG,
755              GT_DARNS BY PERNR,
756              GT_PAID BY PARTNR,
757              GT_PRBS_SUMMARY BY PERNR CALC_TYPE.
758
759        DESCRIBE TABLE GT_PERNR LINES GV_TPERNR.
760
761        LOOP AT GT_PERNR INTO WA_PERNR.
762          CLEAR GV_PROGRESS_TEXT.
763          CONCATENATE 'Processing for CPF No.' WA_PERNR-PERNR INTO GV_PROGRESS_TEXT SEPARATED BY SPACE. "#EC NOTEXT
764
765          CALL FUNCTION 'PROGRESS_INDICATOR'
766            EXPORTING
767              I_TEXT               = GV_PROGRESS_TEXT
768              I_PROCESSED          = SY-INDEX
769              I_TOTAL              = GV_TPERNR
770              I_OUTPUT_IMMEDIATELY = C_MARK.
771
772          CLEAR: WA_FINAL, WA_STORE, WA_PERSNO.
773
774          WA_FINAL-PERNR = WA_PERNR-PERNR.  "Personnel number
775
776          READ TABLE GT_PA0001 INTO WA_01 WITH KEY PERNR = WA_PERNR-PERNR
777                                                   BINARY SEARCH.
778          IF SY-SUBRC EQ 0.
779            WA_FINAL-ENAME = WA_01-ENAME. "Field name
780            WA_FINAL-PERSG = WA_01-PERSG. "Employee Group
781            WA_FINAL-PERSK = WA_01-PERSK. "Employee Subgroup
782            WA_FINAL-WERKS = WA_01-WERKS. "Personnel Area
783            WA_FINAL-SACHP = WA_01-SACHP. "Establishment Head
784
785            READ TABLE GT_T501T INTO WA_T501T WITH KEY PERSG = WA_FINAL-PERSG
786                                                       BINARY SEARCH.
787            IF SY-SUBRC EQ 0.
788              WA_FINAL-PERSG_T = WA_T501T-PTEXT.  "Name of Employee Group
789            ENDIF.
790          ELSE.
791            CONTINUE.
792          ENDIF.
793
794          READ TABLE GT_PA0000 INTO WA_00 WITH KEY PERNR = WA_PERNR-PERNR
795                                                   BINARY SEARCH.
796          IF SY-SUBRC EQ 0.
797            WA_FINAL-STAT2 = WA_00-STAT2. "Employment Status
798            CASE WA_FINAL-STAT2.
799              WHEN '3'.
800                WA_FINAL-STAT2_T = 'Active'. "#EC NOTEXT "Employment Status Text
801              WHEN '0'.
802                WA_FINAL-STAT2_T = 'Withdrawn'. "#EC NOTEXT "Employment Status Text
803            ENDCASE.
804            WA_FINAL-GBDAT = WA_00-GBDAT. "Date of Birth
805            CASE C_MARK.
806              WHEN R_ACTIV.
807                WA_FINAL-SEPDAT = WA_00-SEPDAT. "Seperation Date
808              WHEN R_SEPER.
809            ENDCASE.
810          ENDIF.
811
812          CASE C_MARK.
813            WHEN R_ACTIV.
814            WHEN R_SEPER.
815              READ TABLE GT_PA0302 INTO WA_302 WITH KEY PERNR = WA_PERNR-PERNR
816                                                        BINARY SEARCH.
817              IF SY-SUBRC EQ 0.
818                WA_FINAL-SEPDAT = WA_302-BEGDA - 1. "Seperation Date
819                WA_FINAL-MASSN = WA_302-MASSN.  "Action Type
820                WA_FINAL-MASSG = WA_302-MASSG.  "Reason for Action
821
822                READ TABLE GT_T530T INTO WA_T530T WITH KEY MASSN = WA_FINAL-MASSN
823                                                           MASSG = WA_FINAL-MASSG
824                                                           BINARY SEARCH.
825                IF SY-SUBRC EQ 0.
826                  WA_FINAL-MASSG_T = WA_T530T-MGTXT.  "Reason for Action Text
827                ENDIF.
828              ENDIF.
829          ENDCASE.
830
831          READ TABLE GT_JOIN INTO WA_JOIN WITH KEY PERNR = WA_PERNR-PERNR
832                                                   BINARY SEARCH.
833          IF SY-SUBRC EQ 0.
834            WA_FINAL-JDATE = WA_JOIN-BEGDA.  "Joining Date
835
836            READ TABLE GT_PAID INTO WA_PAID WITH KEY PARTNR = WA_PERNR-KONTRH
837                                                     BINARY SEARCH.
838
839            IF SY-SUBRC EQ 0.
840              WA_FINAL-DOJS = WA_PAID-DT_JOIN_TRUST. "Date of Joining Scheme
841            ELSE.
842              READ TABLE GT_DARNS INTO WA_DARNS WITH KEY PERNR = WA_PERNR-PERNR
843                                                       BINARY SEARCH.
844              IF SY-SUBRC EQ 0.
845                WA_FINAL-DOJS = WA_DARNS-DOJDT. "Date of Joining Scheme
846              ELSE.
847                IF WA_FINAL-JDATE LT '19900401'.
848                  WA_FINAL-DOJS = '19900401'. "Date of Joining Scheme
849                ELSE.
850                  WA_FINAL-DOJS = WA_JOIN-BEGDA. "Date of Joining Scheme
851                ENDIF.
852              ENDIF.
853            ENDIF.
854
855            IF WA_FINAL-JDATE LT WA_FINAL-DOJS.
856              CALL FUNCTION 'HR_HK_DIFF_BT_2_DATES'
857                EXPORTING
858                  DATE1         = WA_FINAL-DOJS
859                  DATE2         = WA_FINAL-JDATE
860                  OUTPUT_FORMAT = '01'
861                IMPORTING
862                  YEARS         = WA_FINAL-PAST_SERVICE. "Past Service
863
864              WA_FINAL-RPAST_SERVICE = ( 1 - ( WA_FINAL-PAST_SERVICE * 12 / 1000 ) ) * WA_FINAL-PAST_SERVICE.  "Recknable Past Service
865            ENDIF.
866
867            IF WA_FINAL-DOJS LT P_DOC.  "'20070101'.
868              CALL FUNCTION 'HR_HK_DIFF_BT_2_DATES'
869                EXPORTING
870                  DATE1         = P_DOC                         "'20070101'
871                  DATE2         = WA_FINAL-DOJS
872                  OUTPUT_FORMAT = '01'
873                IMPORTING
874                  YEARS         = WA_FINAL-FUTURE_SERVICE. "Future Service
875
876              WA_FINAL-RFUTURE_SERVICE = ( 1 + WA_FINAL-FUTURE_SERVICE * 6 / 1000 ) * WA_FINAL-FUTURE_SERVICE + '0.0002' * WA_FINAL-FUTURE_SERVICE ** 3.  "Recknable Future Service
877            ENDIF.
878
879            WA_FINAL-RTOTAL_SERVICE = WA_FINAL-RPAST_SERVICE + WA_FINAL-RFUTURE_SERVICE. "Total Recknable Service
880            IF WA_FINAL-RTOTAL_SERVICE GT P_MSERV.              "'33.0000'.
881              WA_FINAL-RTOTAL_SERVICE = P_MSERV.                "'33.0000'.
882            ENDIF.
883            WA_FINAL-RMAX_SERVICE = P_MSERV.  "'33'. "Max Recknable Service
884    *        WA_FINAL-MAX_BENEFIT = '50%'.  "Max Benefit
885            MOVE P_MBEN TO WA_FINAL-MAX_BENEFIT.
886            CONCATENATE WA_FINAL-MAX_BENEFIT '%' INTO WA_FINAL-MAX_BENEFIT.  "Max Benefit
887            CONDENSE WA_FINAL-MAX_BENEFIT.
888          ELSE.
889            CONTINUE.
890          ENDIF.
891
892          READ TABLE GT_BASIC INTO WA_BASIC WITH KEY PERNR = WA_PERNR-PERNR
893                                                     BINARY SEARCH.
894          IF SY-SUBRC EQ 0.
895            WA_FINAL-BASICD = WA_BASIC-BEGDA. "Basic as on
896            WA_FINAL-BET01 = WA_BASIC-BET01.  "Basic Pay
897
898            WA_FINAL-PENSION = WA_FINAL-RTOTAL_SERVICE / WA_FINAL-RMAX_SERVICE * P_MBEN. "C_MAX_BENEFIT.  "Pension Percentage
899
900            IF WA_FINAL-PENSION GT P_MBEN.
901              WA_FINAL-PENSION = P_MBEN.  "Pension Percentage
902            ENDIF.
903
904            MOVE WA_FINAL-PENSION TO WA_FINAL-PENSION_PERCENT.
905            CONCATENATE WA_FINAL-PENSION_PERCENT '%' INTO WA_FINAL-PENSION_PERCENT.
906            CONDENSE WA_FINAL-PENSION_PERCENT.  "Pension Percentage
907
908            WA_FINAL-PENSION_AMOUNT = ( WA_FINAL-PENSION * WA_FINAL-BET01 ) / 100. "Pension Amount
909            WA_FINAL-LICAR = P_LICAR. "C_LICAR.  "LIC AR
910            WA_FINAL-CORPUS = WA_FINAL-PENSION_AMOUNT * WA_FINAL-LICAR. "Corpus
911
912            CALL FUNCTION 'HR_HK_DIFF_BT_2_DATES'
913              EXPORTING
914                DATE1         = WA_FINAL-SEPDAT
915                DATE2         = P_DOC                           "'20070101'
916                OUTPUT_FORMAT = '01'
917              IMPORTING
918                YEARS         = WA_FINAL-DIS_PERIOD. "Discount Period
919
920            MOVE P_DRATE TO WA_FINAL-DIS_RATE.  "C_DIS_RATE
921            CONCATENATE WA_FINAL-DIS_RATE '%' INTO WA_FINAL-DIS_RATE.  "Discounting Rate
922            CONDENSE WA_FINAL-DIS_RATE.
923
924    *        WA_FINAL-NPV = WA_FINAL-CORPUS / ( 1 + ( C_DIS_RATE / 100 ) ) ** WA_FINAL-DIS_PERIOD.  "Net Present Value
925            WA_FINAL-NPV = WA_FINAL-CORPUS / ( 1 + ( P_DRATE / 100 ) ) ** WA_FINAL-DIS_PERIOD.  "Net Present Value
926
927            IF WA_FINAL-SEPDAT LT P_FRD.  "'20120331'.
928              CALL FUNCTION 'HR_HK_DIFF_BT_2_DATES'
929                EXPORTING
930                  DATE1         = WA_FINAL-SEPDAT
931                  DATE2         = P_DOC                         "'20070101'
932                  OUTPUT_FORMAT = '01'
933                IMPORTING
934                  YEARS         = WA_FINAL-ESC_FACTOR.  "Escalation Factor
935            ELSE.
936              CALL FUNCTION 'HR_HK_DIFF_BT_2_DATES'
937                EXPORTING
938                  DATE1         = P_FRD                         "'20120331'
939                  DATE2         = P_DOC                         "'20070101'
940                  OUTPUT_FORMAT = '01'
941                IMPORTING
942                  YEARS         = WA_FINAL-ESC_FACTOR.  "Escalation Factor
943            ENDIF.
944
945    *        WA_FINAL-ESC_AMOUNT = WA_FINAL-NPV * ( 1 + ( C_DIS_RATE / 100 ) ) ** WA_FINAL-ESC_FACTOR. "Escalated Amount
946            WA_FINAL-ESC_AMOUNT = WA_FINAL-NPV * ( 1 + ( P_DRATE / 100 ) ) ** WA_FINAL-ESC_FACTOR. "Escalated Amount
947
948            READ TABLE GT_VT INTO WA_VT WITH KEY KONTRH = WA_PERNR-KONTRH.
949            IF SY-SUBRC EQ 0.
950              LOOP AT GT_VTPO INTO WA_VTPO WHERE RFHA EQ WA_VT-RFHA.
951                CASE WA_VTPO-SSIGN.
952                  WHEN '+'.
953                    WA_FINAL-OWN_CONT = WA_FINAL-OWN_CONT + WA_VTPO-BZBETR . "Own Contribution
954                  WHEN '-'.
955                    WA_FINAL-OWN_CONT = WA_FINAL-OWN_CONT - WA_VTPO-BZBETR . "Own Contribution
956                ENDCASE.
957              ENDLOOP.
958            ENDIF.
959
960            IF WA_FINAL-ESC_AMOUNT GT WA_FINAL-OWN_CONT.
961              WA_FINAL-BENEFIT = WA_FINAL-ESC_AMOUNT.  "Benefit
962            ELSE.
963              WA_FINAL-BENEFIT = WA_FINAL-OWN_CONT.  "Benefit
964            ENDIF.
965          ENDIF.
966
967          IF WA_FINAL-OWN_CONT EQ '0.00'. "If Own Contribution is ZERO then leave the record
968            CONTINUE.
969          ENDIF.
970
971          CASE C_MARK.
972            WHEN R_ACTIV.
973              WA_FINAL-ETYPE = 'A'. "A = Active, S = Seperated
974            WHEN R_SEPER.
975              WA_FINAL-ETYPE = 'S'. "A = Active, S = Seperated
976
977              LOOP AT GT_PAID INTO WA_PAID WHERE PARTNR EQ WA_PERNR-KONTRH.
978                WA_FINAL-V_C = WA_FINAL-V_C + WA_PAID-V_C + WA_PAID-V_C_ADD.  "Commutation Old
979                WA_FINAL-V_NETC = WA_FINAL-V_NETC + WA_PAID-V_NETC + WA_PAID-V_NET_LIC + WA_PAID-V_NET_LIC_ADD. "Net Corpus Old
980                IF WA_FINAL-V_C EQ '0.00'.
981                  WA_FINAL-V_NETC = WA_FINAL-V_NETC + WA_PAID-V_PAS_CONT + WA_PAID-V_FUT_CONT + WA_PAID-INT_ON_PSC.
982                ENDIF.
983                WA_FINAL-TYP_ANNU = WA_PAID-TYP_ANNU. "Type Of Annuity
984                WA_FINAL-ROI = WA_PAID-ROI. "Rate of Interest
985              ENDLOOP.
986
987              WA_FINAL-APAID = WA_FINAL-V_C + WA_FINAL-V_NETC. "Already Paid
988
989              IF WA_FINAL-BENEFIT GT WA_FINAL-APAID.
990                WA_FINAL-V_C_N = ( WA_FINAL-V_C * WA_FINAL-BENEFIT ) / WA_FINAL-APAID. "Commutation New
991                WA_FINAL-V_NETC_N = WA_FINAL-BENEFIT - WA_FINAL-V_C_N.  "Net Corpus New
992                WA_FINAL-V_C_D = WA_FINAL-V_C_N - WA_FINAL-V_C. "Commutation Difference
993                WA_FINAL-V_NETC_D = WA_FINAL-V_NETC_N - WA_FINAL-V_NETC. "Net Corpus Difference
994    *            WA_FINAL-TPAID_WOI = WA_FINAL-V_NETC_D. "Difference To be Paid w/o interest
995
996    *            CALL METHOD CALCULATE_INTEREST
997    *              EXPORTING
998    *                I_SEPDATE    = WA_FINAL-SEPDAT
999    *                I_TPAID_WOI  = WA_FINAL-V_NETC_D
1000   *                I_ROI        = WA_FINAL-ROI
1001   *                I_FRD        = P_FRD
1002   *                I_INT        = P_INT
1003   *                I_INTD       = P_INTD
1004   *              CHANGING
1005   *                EC_TPAID_WTI = WA_FINAL-TPAID_WTI.  "Difference To be Paid w/t interest "Net Corpus Difference to be paid w/t interest
1006
1007               CALL METHOD CALCULATE_INTEREST_NEW
1008                 EXPORTING
1009                   I_SETT_DATE       = WA_PAID-SETT_DATE
1010                   I_TPAID_WOI       = WA_FINAL-V_NETC_D
1011                   I_ROI             = WA_FINAL-ROI
1012                   I_FRD             = P_FRD
1013                   I_INT             = P_INT
1014                   I_INTD            = P_INTD
1015                 IMPORTING
1016                   E_MONTHS          = WA_FINAL-MONTHS      "Months
1017                   E_V_NETC_INTEREST = WA_FINAL-V_NETC_INTEREST  "Net Corpus Interest
1018                   E_TPAID_WTI       = WA_FINAL-TPAID_WTI.  "Net Corpus Difference to be paid w/t interest
1019
1020               WA_FINAL-TOT_PAYMENT = WA_FINAL-V_C_D + WA_FINAL-TPAID_WTI.  "Total Payment
1021             ENDIF.
1022         ENDCASE.
1023
1024         READ TABLE GT_PRBS_SUMMARY INTO WA_PRBS WITH KEY PERNR = WA_FINAL-PERNR
1025                                                          CALC_TYPE = '1'
1026                                                          BINARY SEARCH.
1027         IF SY-SUBRC EQ 0.
1028           WA_FINAL-SHORT_EXCESS = WA_PRBS-TOTAL.
1029           WA_FINAL-TOT_PAYMENT = WA_FINAL-TOT_PAYMENT + WA_FINAL-SHORT_EXCESS.
1030         ENDIF.
1031
1032         APPEND WA_FINAL TO GT_FINAL.
1033
1034         WA_PERSNO-SIGN = 'I'.
1035         WA_PERSNO-OPTION = 'EQ'.
1036         WA_PERSNO-LOW = WA_FINAL-PERNR.
1037         WA_PERSNO-HIGH = SPACE.
1038         WA_STORE-PERNR = WA_FINAL-PERNR.
1039         WA_STORE-CALC_TYPE = '2'.
1040         WA_STORE-REPORT_DATE = '20070101'.
1041
1042         CASE C_MARK.
1043           WHEN R_ACTIV.
1044             WA_STORE-CORPUS = WA_FINAL-BENEFIT.
1045           WHEN R_SEPER.
1046             WA_STORE-COMMUTATION = WA_FINAL-V_C_D.
1047             WA_STORE-CORPUS = WA_FINAL-V_NETC_D.
1048             WA_STORE-INTEREST = WA_FINAL-V_NETC_INTEREST.
1049         ENDCASE.
1050
1051         IF WA_STORE-CORPUS IS INITIAL AND
1052            WA_STORE-COMMUTATION IS INITIAL AND
1053            WA_STORE-INTEREST IS INITIAL.
1054         ELSE.
1055           WA_STORE-TOTAL = WA_STORE-COMMUTATION + WA_STORE-CORPUS + WA_STORE-INTEREST.
1056           WA_STORE-CREATED_BY = SY-UNAME.
1057           WA_STORE-CREATED_ON = SY-DATUM.
1058
1059           APPEND WA_PERSNO TO GT_PERSNO.
1060           APPEND WA_STORE TO GT_STORE.
1061         ENDIF.
1062       ENDLOOP.
1063
1064       IF GT_PERSNO[] IS NOT INITIAL.
1065         DELETE FROM ZTRPRBS_SUMM WHERE PERNR IN GT_PERSNO AND
1066                                        CALC_TYPE EQ '2' AND
1067                                        REPORT_DATE EQ '20070101'.
1068         CALL FUNCTION 'DB_COMMIT'.
1069       ENDIF.
1070       IF GT_STORE[] IS NOT INITIAL.
1071         INSERT ZTRPRBS_SUMM FROM TABLE GT_STORE.
1072         CALL FUNCTION 'DB_COMMIT'.
1073       ENDIF.
1074     ENDMETHOD.                    "CONSOLIDATE_LIST
1075
1076     METHOD DISPLAY_ALV.
1077       CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
1078         EXPORTING
1079           I_CALLBACK_PROGRAM     = SY-REPID
1080           I_CALLBACK_TOP_OF_PAGE = 'TOP_OF_PAGE'
1081           IT_FIELDCAT            = GT_FIELDCAT[]
1082           IS_LAYOUT              = GS_LAYOUT
1083           IT_SORT                = GT_SORT
1084           I_SAVE                 = 'A'
1085         TABLES
1086           T_OUTTAB               = GT_FINAL.
1087     ENDMETHOD.                    "DISPLAY_ALV
1088
1089     METHOD ALV_HEADER_BUILD.
1090       REFRESH GT_LISTHEADER.
1091
1092       DEFINE MACRO_HEADER.
1093         CLEAR WA_LISTHEADER.
1094         MOVE: &1 TO WA_LISTHEADER-TYP,
1095               &2 TO WA_LISTHEADER-INFO.
1096         APPEND WA_LISTHEADER TO GT_LISTHEADER.
1097       END-OF-DEFINITION.
1098
1099       CASE C_MARK.
1100         WHEN R_ACTIV.
1101           MACRO_HEADER 'H' 'Calculation for active employees'. "#EC NOTEXT
1102         WHEN R_SEPER.
1103           MACRO_HEADER 'H' 'Calculation for seperated employees'. "#EC NOTEXT
1104       ENDCASE.
1105
1106       MACRO_HEADER 'S' ''.
1107
1108       CLEAR GV_TEXT.
1109       CONCATENATE P_DOC+6(2) P_DOC+4(2) P_DOC+2(2) INTO GV_TEXT SEPARATED BY '.'.
1110       CONCATENATE  'Date of Conversion -' GV_TEXT INTO GV_TEXT SEPARATED BY SPACE. "#EC NOTEXT
1111       CONDENSE GV_TEXT.
1112
1113       CLEAR GV_TEXT1.
1114       CONCATENATE P_FRD+6(2) P_FRD+4(2) P_FRD+2(2) INTO GV_TEXT1 SEPARATED BY '.'.
1115       CONCATENATE GV_TEXT 'Fund Reckoning Date -' GV_TEXT1 INTO GV_TEXT SEPARATED BY SPACE. "#EC NOTEXT
1116       CONDENSE GV_TEXT.
1117       MACRO_HEADER 'S' GV_TEXT.
1118
1119       CLEAR GV_TEXT.
1120       MOVE P_LICAR TO GV_TEXT.
1121       CONDENSE GV_TEXT.
1122       CONCATENATE  'LIC AR -' GV_TEXT INTO GV_TEXT SEPARATED BY SPACE.
1123       CONDENSE GV_TEXT.
1124
1125       CLEAR GV_TEXT1.
1126       MOVE P_MBEN TO GV_TEXT1.
1127       CONDENSE GV_TEXT1.
1128       CONCATENATE GV_TEXT 'Max Benefit -' GV_TEXT1 '%' INTO GV_TEXT SEPARATED BY SPACE. "#EC NOTEXT
1129       CONDENSE GV_TEXT.
1130
1131       CLEAR GV_TEXT1.
1132       MOVE P_MSERV TO GV_TEXT1.
1133       CONDENSE GV_TEXT1.
1134       CONCATENATE GV_TEXT 'Max Service -' GV_TEXT1 INTO GV_TEXT SEPARATED BY SPACE. "#EC NOTEXT
1135       CONDENSE GV_TEXT.
1136       MACRO_HEADER 'S' GV_TEXT.
1137
1138       CLEAR GV_TEXT.
1139       MOVE P_DRATE TO GV_TEXT.
1140       CONDENSE GV_TEXT.
1141       CONCATENATE  'Discounting Rate -' GV_TEXT '%' INTO GV_TEXT SEPARATED BY SPACE. "#EC NOTEXT
1142       CONDENSE GV_TEXT.
1143
1144   *    CASE C_MARK.
1145   *      WHEN R_ACTIV.
1146       MACRO_HEADER 'S' GV_TEXT.
1147   *      WHEN R_SEPER.
1148   *        CLEAR GV_TEXT1.
1149   *        MOVE P_ROI TO GV_TEXT1.
1150   *        CONDENSE GV_TEXT1.
1151   *        CONCATENATE GV_TEXT 'Rate of Interest -' GV_TEXT1 '%' INTO GV_TEXT SEPARATED BY SPACE. "#EC NOTEXT
1152   *        CONDENSE GV_TEXT.
1153   *        MACRO_HEADER 'S' GV_TEXT.
1154   *    ENDCASE.
1155     ENDMETHOD.                    "ALV_HEADER_BUILD
1156
1157     METHOD PREPARE_ALV.
1158       REFRESH: GT_FIELDCAT, GT_SORT.
1159       CLEAR GS_LAYOUT.
1160
1161       DEFINE MACRO_FIELDCAT.
1162         CLEAR GWA_FIELDCAT.
1163
1164         ADD 1 TO GV_POS.
1165         MOVE: GV_POS TO GWA_FIELDCAT-COL_POS,
1166               &1 TO GWA_FIELDCAT-FIELDNAME,
1167               &2 TO GWA_FIELDCAT-SELTEXT_L,
1168               &3 TO GWA_FIELDCAT-SELTEXT_M,
1169               &4 TO GWA_FIELDCAT-DO_SUM,
1170               &5 TO GWA_FIELDCAT-KEY,
1171               &6 TO GWA_FIELDCAT-NO_OUT,
1172               'GT_FINAL' TO GWA_FIELDCAT-TABNAME.
1173
1174         APPEND GWA_FIELDCAT TO GT_FIELDCAT.
1175       END-OF-DEFINITION.
1176
1177       DEFINE MACRO_SORT.
1178         CLEAR GWA_SORT.
1179
1180         ADD 1 TO GV_POS.
1181         MOVE: GV_POS TO GWA_SORT-SPOS,
1182               &1 TO GWA_SORT-FIELDNAME,
1183               &2 TO GWA_SORT-UP,
1184               &3 TO GWA_SORT-DOWN.
1185
1186         APPEND GWA_SORT TO GT_SORT.
1187       END-OF-DEFINITION.
1188
1189       GV_POS = 0.
1190       MACRO_SORT 'PERNR' C_MARK ''.
1191
1192       GS_LAYOUT-COLWIDTH_OPTIMIZE = C_MARK.
1193
1194       GV_POS = 0.
1195       MACRO_FIELDCAT 'WERKS' 'Personnel Area' 'Personnel Area' '' C_MARK C_MARK. "#EC NOTEXT
1196       MACRO_FIELDCAT 'SACHP' 'E. Head' 'E. Head' '' C_MARK C_MARK. "#EC NOTEXT
1197       MACRO_FIELDCAT 'PERNR' 'CPF Number' 'CPF Number' '' C_MARK ''. "#EC NOTEXT
1198       MACRO_FIELDCAT 'ENAME' 'Complete Name' 'Complete Name' '' '' ''. "#EC NOTEXT
1199       MACRO_FIELDCAT 'PERSG' 'Employee Group' 'Employee Group' '' '' C_MARK. "#EC NOTEXT
1200       MACRO_FIELDCAT 'PERSK' 'Level' 'Level' '' '' ''.        "#EC NOTEXT
1201       MACRO_FIELDCAT 'STAT2' 'Employment Status' 'Employment Status' '' '' C_MARK. "#EC NOTEXT
1202       MACRO_FIELDCAT 'STAT2_T' 'Employment Status Description' 'Employment Status Desc.' '' '' C_MARK. "#EC NOTEXT
1203       MACRO_FIELDCAT 'MASSN' 'Action ' 'Action ' '' '' C_MARK. "#EC NOTEXT
1204       MACRO_FIELDCAT 'MASSG' 'Reason for Action' 'Reason for Action' '' '' C_MARK. "#EC NOTEXT
1205       MACRO_FIELDCAT 'PERSG_T' 'Employee Group Description' 'Employee Group Desc' '' '' ''. "#EC NOTEXT
1206       MACRO_FIELDCAT 'MASSG_T' 'Action Reason' 'Action Reason' '' '' R_ACTIV. "#EC NOTEXT
1207       MACRO_FIELDCAT 'GBDAT' 'Date of Birth' 'Date of Birth' '' '' R_SEPER. "#EC NOTEXT
1208       MACRO_FIELDCAT 'JDATE' 'Joining Date' 'Joining Date' '' '' ''. "#EC NOTEXT
1209       MACRO_FIELDCAT 'DOJS' 'DOJ Scheme' 'DOJ Scheme' '' '' ''. "#EC NOTEXT
1210       MACRO_FIELDCAT 'SEPDAT' 'Seperation Date' 'Seperation Date' '' '' ''. "#EC NOTEXT
1211       MACRO_FIELDCAT 'BASICD' 'Basic as on' 'Basic as on' '' '' ''. "#EC NOTEXT
1212       MACRO_FIELDCAT 'BET01' 'Basic Pay' 'Basic Pay' '' '' ''. "#EC NOTEXT
1213       MACRO_FIELDCAT 'PAST_SERVICE' 'Past Service' 'Past Service' '' '' ''. "#EC NOTEXT
1214       MACRO_FIELDCAT 'FUTURE_SERVICE' 'Future Service' 'Future Service' '' '' ''. "#EC NOTEXT
1215       MACRO_FIELDCAT 'RPAST_SERVICE' 'Recknable Past Service' 'Recknable Past Service' '' '' ''. "#EC NOTEXT
1216       MACRO_FIELDCAT 'RFUTURE_SERVICE' 'Recknable Future Service' 'Recknable Future Service' '' '' ''. "#EC NOTEXT
1217       MACRO_FIELDCAT 'RTOTAL_SERVICE' 'Total Recknable Service' 'Total Recknable Service' '' '' ''. "#EC NOTEXT
1218       MACRO_FIELDCAT 'RMAX_SERVICE' 'Max Recknable Service' 'Max Recknable Service' '' '' C_MARK. "#EC NOTEXT
1219       MACRO_FIELDCAT 'MAX_BENEFIT' 'Max Benefit' 'Max Benefit' '' '' C_MARK. "#EC NOTEXT
1220       MACRO_FIELDCAT 'PENSION_PERCENT' 'Pension Percentage' 'Pension Percentage' '' '' ''. "#EC NOTEXT
1221       MACRO_FIELDCAT 'PENSION_AMOUNT' 'Pension Amount' 'Pension Amount' '' '' ''. "#EC NOTEXT
1222       MACRO_FIELDCAT 'LICAR' 'LIC AR' 'LIC AR' '' '' C_MARK.  "#EC NOTEXT
1223       MACRO_FIELDCAT 'CORPUS' 'Corpus' 'Corpus' '' '' ''.     "#EC NOTEXT
1224       MACRO_FIELDCAT 'DIS_PERIOD' 'Discount Period' 'Discount Period' '' '' ''. "#EC NOTEXT
1225       MACRO_FIELDCAT 'DIS_RATE' 'Discounting Rate' 'Discounting Rate' '' '' C_MARK. "#EC NOTEXT
1226       MACRO_FIELDCAT 'NPV' 'Net Present Value' 'Net Present Value' '' '' ''. "#EC NOTEXT
1227       MACRO_FIELDCAT 'ESC_FACTOR' 'Escalation Factor' 'Escalation Factor' '' '' ''. "#EC NOTEXT
1228       MACRO_FIELDCAT 'ESC_AMOUNT' 'Escalated Amount' 'Escalated Amount' '' '' ''. "#EC NOTEXT
1229       MACRO_FIELDCAT 'OWN_CONT' 'Own Contribution' 'Own Contribution' '' '' ''. "#EC NOTEXT
1230       MACRO_FIELDCAT 'BENEFIT' 'Benefit' 'Benefit' '' '' ''.  "#EC NOTEXT
1231       MACRO_FIELDCAT 'V_C' 'Commutation Paid' 'Commutation Paid' '' '' R_ACTIV. "#EC NOTEXT
1232       MACRO_FIELDCAT 'V_NETC' 'Net Corpus Paid' 'Net Corpus Paid' '' '' R_ACTIV. "#EC NOTEXT
1233       MACRO_FIELDCAT 'APAID' 'Total Paid' 'Total Paid' '' '' R_ACTIV. "#EC NOTEXT
1234       MACRO_FIELDCAT 'V_C_N' 'Commutation New' 'Commutation New' '' '' R_ACTIV. "#EC NOTEXT
1235       MACRO_FIELDCAT 'V_NETC_N' 'Net Corpus New' 'Net Corpus New' '' '' R_ACTIV. "#EC NOTEXT
1236       MACRO_FIELDCAT 'V_C_D' 'Commutation Diff.' 'Commutation Diff.' '' '' R_ACTIV. "#EC NOTEXT
1237       MACRO_FIELDCAT 'V_NETC_D' 'Net Corpus Diff.' 'Net Corpus Diff.' '' '' R_ACTIV. "#EC NOTEXT
1238       MACRO_FIELDCAT 'TYP_ANNU' 'Type Of Annuity' 'Type Of Annuity' '' '' R_ACTIV. "#EC NOTEXT
1239       MACRO_FIELDCAT 'ROI' 'Rate of Int.' 'Rate of Int.' '' '' R_ACTIV. "#EC NOTEXT
1240       MACRO_FIELDCAT 'MONTHS' 'Months' 'Months' '' '' R_ACTIV. "#EC NOTEXT
1241       MACRO_FIELDCAT 'V_NETC_INTEREST' 'Interest' 'Interest' '' '' R_ACTIV. "#EC NOTEXT
1242       MACRO_FIELDCAT 'TPAID_WTI' 'Net Corpus Diff. with int.' 'Net Corpus Diff. with int.' '' '' C_MARK. "#EC NOTEXT
1243       MACRO_FIELDCAT 'SHORT_EXCESS' 'Adjustments' 'Adjustments' '' '' ''. "#EC NOTEXT
1244       MACRO_FIELDCAT 'TOT_PAYMENT' 'Total Payment' 'Total Payment' '' '' R_ACTIV. "#EC NOTEXT
1245       MACRO_FIELDCAT 'ETYPE' 'Employee Type' 'Employee Type' '' '' C_MARK. "#EC NOTEXT
1246     ENDMETHOD.                    "PREPARE_ALV
1247   ENDCLASS.                    "PRBS IMPLEMENTATION
1248
1249   *&---------------------------------------------------------------------*
1250   *&      Form  TOP_OF_PAGE
1251   *&---------------------------------------------------------------------*
1252   FORM TOP_OF_PAGE.                                           "#EC CALLED
1253     CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
1254       EXPORTING
1255         IT_LIST_COMMENTARY = GT_LISTHEADER
1256         I_LOGO             = 'ZONGC'.
1257   ENDFORM.                    "TOP_OF_PAGE
*--- End of ZTR_PRBS_COMPUTATION - 1257 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CSLIS                                   Level 1    Page 2
Object           ZTR_PRBS_COMPUTATION                      Lines 543
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:23
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
Object           ZTR_PRBS_COMPUTATION                      Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:23
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
Object           ZTR_PRBS_COMPUTATION                      Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:23
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
Object           ZTR_PRBS_COMPUTATION                      Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:23
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
Object           ZTR_PRBS_COMPUTATION                      Lines 1
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:23
----------------------------------------------------------------------------------------------------
1      * INCLUDE DB__SSEL
*--- End of DB__SSEL - 1 lines ---
