----------------------------------------------------------------------------------------------------
Main program     ZF_FILL_MISSING_AUGGJ_NGLM                Level 0    Page 1
Object           ZF_FILL_MISSING_AUGGJ_NGLM                Lines 1382
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:59
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *& Report  ZF_FILL_MISSING_AUGGJ_NGLM
3      *& Version 002 : 02  May 2008
4      *&---------------------------------------------------------------------*
5      *& !!!!!!!!!!!!!! To be RUN by SAP / SAP Guidance Only !!!!!!!!!!!!!!!!!
6      *&----------------------------------------------------------------------
7      *& AUGGJ missing could cause trouble in processing of BSE_CLR during
8      *& of phase-1 documents in NewGL Migration.
9      *&
10     *& This program will,
11     *& Fill missing AUGGJ in BSEG;BSA* which could cause trouble in migration
12     *&
13     *& Migration date is taken as the basis of start of AUGDT selection for clearings
14     *&
15     *& BUKRS are obtained from Migration plan, these are ignored if the selection of
16     *& BUKRS is entered in the selections directly.
17     *&
18     *& Run in background in test mode first(default) and check the output before
19     *& running in update mode
20     *&
21     *& Limitations:
22     *& Does not correct BSEG if BSA* is alright
23     *& Not yet good for mass corrections, run in test mode first !
24     *& Special Features:
25     *& Export a back up to RFDT all the values of corrections ( But happens
26     *& at the end; Any manual termination in between may not export correctly)
27     *&---------------------------------------------------------------------*
28
29     REPORT  ZF_FILL_MISSING_AUGGJ_NGLM.
30
31     TYPE-POOLS: ABAP.
32
33     TABLES: T001,BKPF,BSEG,BSAS,BSAK,BSAD.
34
35     TYPES : T_BKPF TYPE BKPF.
36
37     DATA:  WA_BKPF TYPE BKPF.
38
39     DATA:  BEGIN OF WA_BSEG.
40     INCLUDE type BSEG.
41     DATA:  CORR TYPE CHAR1,
42            AUGGJ_NEW TYPE BSEG-AUGGJ,
43            END OF WA_BSEG.
44
45     DATA:  BEGIN OF WA_BSAS.
46     INCLUDE type BSAS.
47     DATA:  CORR TYPE CHAR1,
48            AUGGJ_NEW TYPE BSAS-AUGGJ,
49            END OF WA_BSAS.
50
51     DATA:  BEGIN OF WA_BSAD.
52     INCLUDE TYPE BSAD.
53     DATA:  CORR TYPE CHAR1,
54            AUGGJ_NEW TYPE BSAD-AUGGJ,
55            END OF WA_BSAD.
56
57     DATA:  BEGIN OF WA_BSAK.
58     INCLUDE type BSAK.
59     DATA:  CORR TYPE CHAR1,
60            AUGGJ_NEW TYPE BSAK-AUGGJ,
61            END OF WA_BSAK.
62
63     ** ITABs for selection/correction
64
65     DATA : IT_BKPF LIKE STANDARD table of WA_BKPF with header line,
66            IT_BSEG LIKE STANDARD table of WA_BSEG with header line,
67            IT_BSAS LIKE STANDARD table of WA_BSAS with header line,
68            IT_BSAD LIKE STANDARD table of WA_BSAD with header line,
69            IT_BSAK LIKE STANDARD table of WA_BSAK with header line.
70
71
72
73     ** Migration Data
74     DATA: T_BUKRS TYPE FAGL_T_BUKRS,              " Company Codes for Migration plan
75           T_MIG_DATA TYPE FAGL_T_MIG_MGPLN_EXT,   " Migration Status Data for the plan
76           S_MIG_DATA type FAGL_S_MIG_MGPLN_EXT,   " Migration Status Data for the plan
77           T_MIG_PLAN TYPE FAGL_T_MGPLN,           " Migration Plan
78           L_MIGDT TYPE FAGL_S_MIG_MGPLN_EXT-MIGDT." Migration Date : Date of Migration
79
80
81     DATA : Begin of WA_CLEARING_DOC,
82            BUKRS TYPE T001-BUKRS,
83            AUGDT TYPE BSAS-AUGDT,
84            AUGBL TYPE BSAS-AUGBL,
85            BELNR TYPE BSAS-BELNR,
86            GJAHR TYPE BSAS-GJAHR,
87            BUZEI TYPE BSAS-BUZEI,
88            AUGGJ TYPE BSAS-AUGGJ,
89            HKONT TYPE BSAS-HKONT,
90            LIFNR TYPE BSAK-LIFNR,
91            KUNNR TYPE BSAD-KUNNR,
92            CNT_UPD_BSAS TYPE I,
93            CNT_UPD_BSAK TYPE I,
94            CNT_UPD_BSAD TYPE I,
95            CNT_UPD_BSEG TYPE I,
96            CNT_UPD_CLR  TYPE I,
97            CORR  TYPE CHAR1,
98
99            End of WA_CLEARING_DOC.
100
101    DATA:  IT_CLEARING_DOC_BSAS LIKE TABLE OF WA_CLEARING_DOC WITH HEADER LINE.
102    DATA:  IT_CLEARING_DOC_BSAK LIKE TABLE OF WA_CLEARING_DOC WITH HEADER LINE.
103    DATA:  IT_CLEARING_DOC_BSAD LIKE TABLE OF WA_CLEARING_DOC WITH HEADER LINE.
104
105    DATA:  CNT_BSAS_OLD TYPE I,CNT_BSAS_NEW TYPE I,CNT_BSAD_OLD TYPE I ,CNT_BSAD_NEW TYPE I.
106    DATA:  CNT_BSAK_OLD TYPE I,CNT_BSAK_NEW TYPE I,CNT_BSEG_OLD TYPE I ,CNT_BSEG_NEW TYPE I.
107
108    DATA:  CNT_TEMP_BSAS TYPE I,CNT_TEMP_BSEG TYPE I,CNT_TEMP_BSAK TYPE I,CNT_TEMP_BSAD TYPE I,CNT_TEMP TYPE I,CNT_DISP_BSEG TYPE I.
109
110    ** Database update counters
111
112    DATA: CNT_UPD_BSAS TYPE I.
113    DATA: CNT_UPD_BSAK TYPE I.
114    DATA: CNT_UPD_BSAD TYPE I.
115    DATA: CNT_UPD_BSEG TYPE I.
116    DATA: CNT_UPD_CLR  TYPE I.
117    DATA: CNT_UPD_TOT  TYPE I.
118
119
120    ** export key for RFDT
121    DATA: exp_key(22) TYPE c.
122    DATA: BEGIN OF rfdt_key,
123          key1(7) TYPE c VALUE 'AUGJ_UP',
124          date    LIKE sy-datlo,
125          time    LIKE sy-timlo,
126          END OF rfdt_key.
127    DATA  EXP_TAB TYPE CHAR4.
128    ** Selections
129
130    SELECTION-SCREEN BEGIN OF BLOCK SEL WITH FRAME TITLE TEXT-SEL.
131
132    PARAMETERS:        P_BUKRS  TYPE T001-BUKRS.
133    SELECT-OPTIONS:    S_BELNR  FOR BKPF-BELNR,
134                       S_GJAHR  FOR BKPF-GJAHR,
135                       S_AUGBL  FOR BSAS-AUGBL,
136                       S_AUGDT  FOR BSAS-AUGDT.
137
138    PARAMETERS:        P_MG_PLN TYPE FAGL_MIG_001-MGPLN OBLIGATORY.
139
140    SELECTION-SCREEN END OF BLOCK SEL.
141
142    SELECTION-SCREEN BEGIN OF BLOCK UPD WITH FRAME TITLE TEXT-UPD.
143    PARAMETERS:     CHK_GL      AS CHECKBOX DEFAULT ABAP_TRUE,
144                    CHK_VEND    AS CHECKBOX DEFAULT ABAP_FALSE,
145                    CHK_CUST    AS CHECKBOX DEFAULT ABAP_FALSE,
146                    P_D_LIST   AS CHECKBOX DEFAULT ABAP_TRUE MODIF ID INC,
147                    P_E_RFDT AS CHECKBOX DEFAULT ABAP_TRUE MODIF ID INC,
148                    P_UPDATE   AS CHECKBOX DEFAULT ABAP_FALSE MODIF ID INC.
149    SELECTION-SCREEN END OF BLOCK UPD.
150
151    ***********************************************************************
152    *********** Start of selection****************************************
153
154    START-OF-SELECTION.
155
156      IF P_UPDATE = ABAP_TRUE.
157        WRITE  : / ' START OF RUN IN UPDATE MODE BY ', SY-UNAME , ' ON ', SY-DATUM,' AT ',SY-UZEIT.
158      ELSE.
159        WRITE  : / ' START OF RUN IN TEST MODE BY ', SY-UNAME , ' ON ', SY-DATUM,' AT ',SY-UZEIT.
160      ENDIF.
161      ULINE (120).
162
163    ** Check for migration company codes/date etc.
164      PERFORM MIGRATION_DATA_CHECK.
165
166    ** Select the data for correction
167
168      IF CHK_GL = ABAP_TRUE.
169        WRITE / : ' GL ACCOUNT CLEARINGS'.
170        NEW-LINE.
171        CLEAR CNT_UPD_TOT. " Clear Total count of updates / account type
172        PERFORM GET_DATA_BSAS.
173      ENDIF.
174
175      IF CHK_VEND = ABAP_TRUE.
176        WRITE / : ' VENDOR ACCOUNT CLEARINGS'.
177        NEW-LINE.
178        CLEAR CNT_UPD_TOT. " Clear Total count of updates / account type
179        PERFORM GET_DATA_BSAK.
180      ENDIF.
181
182      IF CHK_CUST = ABAP_TRUE.
183        WRITE / : ' CUSTOMER ACCOUNT CLEARINGS'.
184        NEW-LINE.
185        CLEAR CNT_UPD_TOT. " Clear Total count of updates / account type
186        PERFORM GET_DATA_BSAD.
187      ENDIF.
188
189      NEW-LINE.
190      ULINE (120).
191      FORMAT COLOR 3.
192      WRITE:/ sy-vline NO-GAP, 'CORR = X -> To be Corrected / Test   Mode   '.
193      FORMAT COLOR OFF.
194      WRITE:120 sy-vline NO-GAP.
195      FORMAT COLOR 3.
196      WRITE:/ sy-vline NO-GAP, '       U -> Updated         / Update Mode   '.
197      FORMAT COLOR OFF.
198      WRITE:120 sy-vline NO-GAP.
199      FORMAT COLOR 3.
200      WRITE:/ sy-vline NO-GAP, '       E -> Error in Update / To be Analyzed'.
201      FORMAT COLOR OFF.
202      WRITE:120 sy-vline NO-GAP.
203      FORMAT COLOR 3.
204      WRITE:/ sy-vline NO-GAP, '       N -> Could not get AUGGJ/ClearingYear'.
205      FORMAT COLOR OFF.
206      WRITE:120 sy-vline NO-GAP.
207      FORMAT COLOR OFF.
208      ULINE (120).
209
210      IF P_UPDATE = ABAP_TRUE.
211        WRITE  : / 'END OF RUN IN UPDATE MODE BY ', SY-UNAME , ' ON ', SY-DATUM,' AT ',SY-UZEIT.
212      ELSE.
213        WRITE  : / 'END OF RUN IN TEST MODE BY ', SY-UNAME , ' ON ', SY-DATUM,' AT ',SY-UZEIT.
214      ENDIF.
215      ULINE (120).
216    *********** All Over! *************************************************
217    ***********************************************************************
218
219
220    *&---------------------------------------------------------------------*
221    *&      Form  MIGRATION_DATA_CHECK
222    *&---------------------------------------------------------------------*
223    *       text
224    *----------------------------------------------------------------------*
225    *  -->  p1        text
226    *  <--  p2        text
227    *----------------------------------------------------------------------*
228    FORM MIGRATION_DATA_CHECK .
229
230    ** Get the company codes involved in the migration plan
231      CALL FUNCTION 'FAGL_GET_BUKRS_LEDGER_IN_MGPLN'
232        EXPORTING
233          I_MGPLN       = P_MG_PLN
234        IMPORTING
235          ET_BUKRS      = T_BUKRS
236        EXCEPTIONS
237          INVALID_INPUT = 1
238          NO_DATA_FOUND = 2
239          OTHERS        = 3.
240
241      IF SY-SUBRC <> 0.
242        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
243                 WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
244      ENDIF.
245
246    ** Clear out the selection of BUKRS if selected already in the parameters
247
248      IF NOT P_BUKRS IS INITIAL.
249        CLEAR T_BUKRS.
250        REFRESH T_BUKRS.
251        APPEND P_BUKRS TO T_BUKRS.
252      ENDIF.
253
254    ** End Filter
255
256    ** Get Migration Date
257      CLEAR T_MIG_PLAN.
258      REFRESH T_MIG_PLAN.
259
260      APPEND P_MG_PLN TO T_MIG_PLAN. "Next FM takes only IT of plans.
261
262      CALL FUNCTION 'FAGL_MIG_GET_ALL_MGPLN_DATA_EX'
263        EXPORTING
264          IT_MGPLN          = T_MIG_PLAN
265        IMPORTING
266          ET_MGPLN_DATA_EXT = T_MIG_DATA
267        EXCEPTIONS
268          INTERNAL_ERROR    = 1
269          NO_DATA_FOUND     = 2
270          OTHERS            = 3.
271
272      IF SY-SUBRC <> 0.
273        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
274                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
275      ENDIF.
276
277    ** Got the migration date for the Migration Plan selected.
278    *{   REPLACE        TNGK900040                                        1
279    *\  READ TABLE T_MIG_DATA WITH KEY MG_START = 'X' MG_END = ' ' MGPLN = P_MG_PLN INTO S_MIG_DATA.
280      READ TABLE T_MIG_DATA WITH KEY MGPLN = P_MG_PLN INTO S_MIG_DATA. "MG_START = 'X' MG_END = ' '
281    *}   REPLACE
282      L_MIGDT = S_MIG_DATA-MIGDT.
283
284
285    ENDFORM.                    " MIGRATION_DATA_CHECK
286    *&---------------------------------------------------------------------*
287    *&      Form  GET_DATA_BSAS
288    *&---------------------------------------------------------------------*
289    *       text
290    *----------------------------------------------------------------------*
291    *  -->  p1        text
292    *  <--  p2        text
293    *----------------------------------------------------------------------*
294    FORM GET_DATA_BSAS .
295
296      SELECT   DISTINCT BUKRS
297                        HKONT
298                        AUGDT
299                        AUGBL
300                  FROM bsas
301                  APPENDING CORRESPONDING FIELDS OF TABLE IT_CLEARING_DOC_BSAS
302                  FOR ALL ENTRIES IN T_BUKRS
303                    WHERE BUKRS EQ  T_BUKRS-BUKRS
304                      AND AUGDT GE  L_MIGDT
305                      AND AUGBL IN  S_AUGBL
306                      AND AUGDT IN  S_AUGDT
307                      AND BELNR IN  S_BELNR
308                      AND GJAHR IN  S_GJAHR
309    *{   REPLACE        TNGK900040                                        1
310    *\                  AND AUGGJ EQ  SPACE.
311                      AND ( AUGGJ =  SPACE OR AUGGJ = '' OR AUGGJ IS NULL ).
312    *}   REPLACE
313
314      CLEAR: IT_BSEG,WA_BSEG,IT_BSAS.
315      REFRESH: IT_BSEG,IT_BSAS.
316
317    ** Header
318      FORMAT COLOR 1.
319      ULINE (120).
320      WRITE:/ sy-vline NO-GAP,
321              'Clearings Involved in Correction',
322          120 sy-vline NO-GAP.
323      FORMAT COLOR OFF.
324      FORMAT COLOR 4.
325      WRITE:/ sy-vline NO-GAP,
326          (5) 'BUKRS',
327          (10) 'AUGDT',
328          (10) 'AUGBL',
329          (12) 'HKONT',
330          (5) 'AUGGJ',
331          (8) 'UPD_BSEG',
332         (8) 'UPD_BSAS',
333         (8) 'UPD_CLR',
334         (4) 'CORR'.
335      WRITE:120 sy-vline NO-GAP.
336      FORMAT COLOR OFF.
337      ULINE (120).
338
339
340      IF P_D_LIST = ABAP_TRUE.
341        FORMAT COLOR 2.
342        WRITE:/ sy-vline NO-GAP,
343            (5) 'BUKRS',
344            (10) 'BELNR',
345            (10) 'GJAHR',
346            (5)  'BUZEI',
347            (10) 'AUGDT',
348            (10) 'AUGBL',
349            (12) 'HKONT',
350            (9) 'AUGGJ_OLD',
351            (9) 'AUGGJ_NEW',
352            (5) 'TABLE',
353            (5) 'CORR'.
354        WRITE:120 sy-vline NO-GAP.
355        ULINE (120).
356        FORMAT COLOR OFF.
357
358      ENDIF.
359
360    ** End Header
361
362      LOOP AT IT_CLEARING_DOC_BSAS. " Loop at the set and get the lines for clearing
363
364        CLEAR : CNT_UPD_BSAS,CNT_UPD_BSEG,CNT_BSEG_OLD,CNT_BSAS_OLD,CNT_BSEG_NEW,CNT_BSAS_NEW.
365
366    ** Documentatoin of update or test mode
367        IF P_UPDATE = ABAP_TRUE.
368          IT_CLEARING_DOC_BSAS-CORR = 'U'.
369        ELSE.
370          IT_CLEARING_DOC_BSAS-CORR = 'X'.
371        ENDIF.
372
373        MODIFY IT_CLEARING_DOC_BSAS FROM IT_CLEARING_DOC_BSAS.
374    ** Documentatoin of update or test mode    CLEAR : CNT_UPD_CLR,CNT_UPD_BSAS,CNT_UPD_BSEG.
375
376        DESCRIBE TABLE IT_BSAS  LINES CNT_BSAS_OLD.
377
378        SELECT * FROM BSAS APPENDING CORRESPONDING FIELDS OF TABLE IT_BSAS
379                 WHERE BUKRS =  IT_CLEARING_DOC_BSAS-BUKRS
380                 AND   HKONT =  IT_CLEARING_DOC_BSAS-HKONT
381                 AND   AUGDT =  IT_CLEARING_DOC_BSAS-AUGDT
382                 AND   AUGBL =  IT_CLEARING_DOC_BSAS-AUGBL
383    *{   REPLACE        TNGK900040                                        2
384    *\             AND   AUGGJ EQ SPACE.
385                 AND ( AUGGJ =  SPACE OR AUGGJ = '' OR AUGGJ IS NULL ).
386    *}   REPLACE
387
388        IF SY-SUBRC = 0.
389
390          DESCRIBE TABLE IT_BSAS LINES CNT_BSAS_NEW.
391
392          CLEAR CNT_TEMP_BSAS.
393
394          CNT_TEMP_BSAS = CNT_BSAS_OLD.
395
396          WHILE CNT_TEMP_BSAS LT CNT_BSAS_NEW.
397
398            CNT_TEMP_BSAS = CNT_TEMP_BSAS + 1.
399            READ TABLE IT_BSAS INDEX CNT_TEMP_BSAS INTO WA_BSAS.  "#EC CI_NOORDER
400            IF SY-SUBRC = 0.
401              IF WA_BSAS-AUGBL = WA_BSAS-BELNR.
402                IT_CLEARING_DOC_BSAS-AUGGJ = WA_BSAS-GJAHR.
403                MODIFY IT_CLEARING_DOC_BSAS FROM IT_CLEARING_DOC_BSAS.
404    ** Update the internal table with the new value
405                EXIT. " Got the Required Clearing Year, exit while loop.
406              ENDIF.
407            ENDIF.
408
409    **  Try Finding AUGGJ with help from BKPF
410            IF IT_CLEARING_DOC_BSAS-AUGGJ EQ SPACE AND CNT_TEMP_BSAS = CNT_BSAS_NEW.
411              READ TABLE IT_BSAS INDEX CNT_BSAS_NEW INTO IT_BSAS.  "#EC CI_NOORDER
412              SELECT SINGLE * FROM BSEG INTO CORRESPONDING FIELDS OF WA_BSEG
413                  WHERE        BUKRS =  IT_BSAS-BUKRS
414                         AND   BELNR =  IT_BSAS-BELNR
415                         AND   GJAHR =  IT_BSAS-GJAHR
416                         AND   BUZEI =  IT_BSAS-BUZEI.
417              IF SY-SUBRC = 0.
418                SELECT SINGLE * FROM BKPF INTO WA_BKPF
419                     WHERE BUKRS = IT_CLEARING_DOC_BSAS-BUKRS
420                     AND   BELNR eq IT_CLEARING_DOC_BSAS-AUGBL
421                     AND   CPUDT eq WA_BSEG-AUGCP.  "#EC CI_NOORDER
422
423                IF SY-SUBRC = 0.
424                  IT_CLEARING_DOC_BSAS-AUGGJ = WA_BKPF-GJAHR.
425                  MODIFY IT_CLEARING_DOC_BSAS FROM IT_CLEARING_DOC_BSAS.
426                ENDIF.
427              ENDIF.
428            ENDIF.  " Try Finding AUGGJ with help from BKPF
429          ENDWHILE. " Try getting AUGGJ from BELNR = AUGBL condition
430
431
432          IF IT_CLEARING_DOC_BSAS-AUGGJ NE SPACE.
433
434    ** Modify the IT and update the database with new values.
435            CNT_TEMP = CNT_BSAS_OLD + 1.
436            LOOP AT IT_BSAS FROM  CNT_TEMP TO CNT_BSAS_NEW.  "#EC CI_NOORDER
437              IT_BSAS-AUGGJ_NEW = IT_CLEARING_DOC_BSAS-AUGGJ.
438              IT_BSAS-CORR  = 'X'.
439              MODIFY IT_BSAS FROM IT_BSAS.
440              IF P_UPDATE = ABAP_TRUE.
441    "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
442
443    *            UPDATE BSAS SET AUGGJ =  IT_CLEARING_DOC_BSAS-AUGGJ
444    *                       WHERE BUKRS = IT_BSAS-BUKRS
445    *                         AND HKONT = IT_BSAS-HKONT
446    *                         AND AUGDT = IT_BSAS-AUGDT
447    *                         AND AUGBL = IT_BSAS-AUGBL
448    *                         AND BELNR = IT_BSAS-BELNR
449    *                         AND GJAHR = IT_BSAS-GJAHR
450    *                         AND BUZEI = IT_BSAS-BUZEI.
451    "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
452                IF SY-SUBRC = 0.
453                  IT_BSAS-CORR = 'U'.
454                  CNT_UPD_BSAS = CNT_UPD_BSAS + sy-dbcnt.
455                ELSE.
456                  IT_BSAS-CORR = 'E'.
457                  IT_CLEARING_DOC_BSAS-CORR = 'E'.
458                  MODIFY IT_CLEARING_DOC_BSAS FROM IT_CLEARING_DOC_BSAS.
459                ENDIF.
460                MODIFY IT_BSAS FROM IT_BSAS.
461              ELSE.
462                CNT_UPD_BSAS = CNT_UPD_BSAS + 1.
463              ENDIF.
464            ENDLOOP.
465
466    ** Modify the IT and update database for BSEG with new AUGGJ
467            CNT_TEMP =  CNT_BSAS_OLD + 1.
468
469            DESCRIBE TABLE IT_BSEG LINES CNT_DISP_BSEG.
470            LOOP AT IT_BSAS FROM CNT_TEMP TO CNT_BSAS_NEW.  "#EC CI_NOORDER
471              DESCRIBE TABLE IT_BSEG LINES CNT_BSEG_OLD.
472
473              SELECT * FROM BSEG APPENDING CORRESPONDING FIELDS OF TABLE IT_BSEG
474                    WHERE BUKRS = IT_BSAS-BUKRS
475                    AND   BELNR = IT_BSAS-BELNR
476                    AND   GJAHR = IT_BSAS-GJAHR
477                    AND   BUZEI = IT_BSAS-BUZEI
478    *{   REPLACE        TNGK900040                                        3
479    *\                AND   AUGGJ EQ SPACE.
480                    AND ( AUGGJ =  SPACE OR AUGGJ = '' ).
481    *}   REPLACE
482
483              IF SY-SUBRC = 0.
484                DESCRIBE TABLE IT_BSEG LINES CNT_BSEG_NEW.
485                CNT_TEMP_BSEG = CNT_BSEG_OLD.
486
487                WHILE CNT_TEMP_BSEG LT CNT_BSEG_NEW.
488
489                  CNT_TEMP_BSEG = CNT_TEMP_BSEG + 1.
490                  READ TABLE IT_BSEG INDEX CNT_TEMP_BSEG INTO IT_BSEG.
491                  IF SY-SUBRC = 0.
492                    IT_BSEG-AUGGJ_NEW = IT_CLEARING_DOC_BSAS-AUGGJ.
493                    IT_BSEG-CORR  = 'X'.
494                    MODIFY IT_BSEG INDEX CNT_TEMP_BSEG FROM IT_BSEG.
495    ** Update the values to the internal table with new AUGGJ
496                    IF P_UPDATE = ABAP_TRUE.
497
498    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
499    * S/4: AUGGJ (clearing fiscal year) cannot be set by direct update - use standard reconciliation RFINDEX/FAGLF03 (Note 946596).
500    *                  UPDATE BSEG SET AUGGJ =  IT_CLEARING_DOC_BSAS-AUGGJ
501    *                             WHERE BUKRS = IT_BSEG-BUKRS
502    *                               AND BELNR = IT_BSEG-BELNR
503    *                               AND GJAHR = IT_BSEG-GJAHR
504    *                               AND BUZEI = IT_BSEG-BUZEI
505    **{   REPLACE        TNGK900040                                        4
506    **\                               AND AUGGJ EQ SPACE.
507                      MESSAGE 'Document not updated. Clearing year (AUGGJ) cannot be set by direct update - use RFINDEX/FAGLF03. Refer SAP Note 946596' TYPE 'E'.
508    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
509    *}   REPLACE
510                      IF SY-SUBRC = 0.
511                        IT_BSEG-CORR = 'U'.
512                        CNT_UPD_BSEG = CNT_UPD_BSEG + sy-dbcnt.
513                      ELSE.
514                        IT_BSEG-CORR = 'E'.
515                        IT_CLEARING_DOC_BSAS-CORR = 'E'.
516                        MODIFY IT_CLEARING_DOC_BSAS FROM IT_CLEARING_DOC_BSAS.
517                      ENDIF.
518                      MODIFY IT_BSEG INDEX CNT_TEMP_BSEG FROM IT_BSEG.
519                    ELSE.
520                      CNT_UPD_BSEG = CNT_UPD_BSEG + 1.
521                    ENDIF.
522                  ENDIF.
523                ENDWHILE.
524              ENDIF.
525            ENDLOOP.
526
527          ELSE.
528            IT_CLEARING_DOC_BSAS-CORR = 'N'.
529            MODIFY IT_CLEARING_DOC_BSAS FROM IT_CLEARING_DOC_BSAS.
530          ENDIF.
531
532          IT_CLEARING_DOC_BSAS-CNT_UPD_BSAS = CNT_UPD_BSAS.
533          IT_CLEARING_DOC_BSAS-CNT_UPD_BSEG = CNT_UPD_BSEG.
534
535          CNT_UPD_CLR =  CNT_UPD_BSAS + CNT_UPD_BSEG.
536
537          IT_CLEARING_DOC_BSAS-CNT_UPD_CLR  = CNT_UPD_CLR.
538          CNT_UPD_TOT = CNT_UPD_TOT + CNT_UPD_CLR.
539
540          MODIFY IT_CLEARING_DOC_BSAS FROM IT_CLEARING_DOC_BSAS.
541
542        ENDIF.      " Clearing Documents in a Clearing
543
544    ** Display the clearing info
545        FORMAT COLOR 4.
546        WRITE:/ sy-vline NO-GAP,
547            (5) IT_CLEARING_DOC_BSAS-BUKRS,
548           (10) IT_CLEARING_DOC_BSAS-AUGDT,
549           (10) IT_CLEARING_DOC_BSAS-AUGBL,
550            (12) IT_CLEARING_DOC_BSAS-HKONT,
551            (5) IT_CLEARING_DOC_BSAS-AUGGJ,
552            (8) CNT_UPD_BSEG,
553           (8)  CNT_UPD_BSAS,
554            (8) CNT_UPD_CLR.  "#EC CI_NOORDER
555        FORMAT COLOR 3.
556        WRITE : (4) IT_CLEARING_DOC_BSAS-CORR.  "#EC CI_NOORDER
557        FORMAT COLOR OFF.
558        WRITE:120 sy-vline NO-GAP.
559        FORMAT COLOR OFF.
560
561        IF P_D_LIST = ABAP_TRUE.
562
563          CNT_TEMP = CNT_DISP_BSEG + 1.
564          LOOP AT IT_BSEG FROM  CNT_TEMP TO CNT_BSEG_NEW.
565            FORMAT COLOR 2.
566            WRITE:/ sy-vline NO-GAP,
567                (5) IT_BSEG-BUKRS,
568                (10) IT_BSEG-BELNR,
569                (10) IT_BSEG-GJAHR,
570                (5)  IT_BSEG-BUZEI,
571                (10) IT_BSEG-AUGDT,
572                (10) IT_BSEG-AUGBL,
573                (12) IT_BSEG-HKONT,
574                (9) IT_BSEG-AUGGJ,
575                (9) IT_BSEG-AUGGJ_NEW,
576                (5) 'BSEG'.  "#EC CI_NOORDER
577            FORMAT COLOR 3.
578            WRITE: (5) IT_BSEG-CORR.
579            FORMAT COLOR OFF.
580            WRITE:120 sy-vline NO-GAP.
581            FORMAT COLOR OFF.
582
583          ENDLOOP.
584
585          CNT_TEMP = CNT_BSAS_OLD + 1.
586          LOOP AT IT_BSAS FROM  CNT_TEMP TO CNT_BSAS_NEW.  "#EC CI_NOORDER
587            FORMAT COLOR 2.
588            WRITE:/ sy-vline NO-GAP,
589                (5) IT_BSAS-BUKRS,
590                (10) IT_BSAS-BELNR,
591                (10) IT_BSAS-GJAHR,
592                (5)  IT_BSAS-BUZEI,
593                (10) IT_BSAS-AUGDT,
594                (10) IT_BSAS-AUGBL,
595                (12) IT_BSAS-HKONT,
596                (9) IT_BSAS-AUGGJ,
597                (9) IT_BSAS-AUGGJ_NEW,
598                (5) 'BSAS'.  "#EC CI_NOORDER
599            FORMAT COLOR 3.
600            WRITE: (5) IT_BSAS-CORR.
601            FORMAT COLOR OFF.
602            WRITE:120 sy-vline NO-GAP.
603            FORMAT COLOR OFF.
604          ENDLOOP.
605
606        ENDIF.
607        ULINE (120).
608
609      ENDLOOP.      " Clearing Document Set
610
611    ** Export to RFDT all the selected entries
612    ** Exporting only at the end to get even BSEG entries, may miss values if
613    ** Program terminates due to some error in between
614
615      EXP_TAB = 'BSAS'.
616      PERFORM EXPORT_RFDT USING EXP_TAB.
617
618    ** Display total count and legend
619      FORMAT COLOR 5.
620      WRITE:/ sy-vline NO-GAP, 'Total Count of Database Updates ', CNT_UPD_TOT.
621      FORMAT COLOR OFF.
622      WRITE:120 sy-vline NO-GAP.
623      ULINE (120).
624    ENDFORM.                    " GET_DATA_BSAS
625    *&---------------------------------------------------------------------*
626    *&      Form  EXPORT_RFDT
627    *&---------------------------------------------------------------------*
628    *       text
629    *----------------------------------------------------------------------*
630    *      -->P_EXP_TAB  text
631    *----------------------------------------------------------------------*
632    FORM EXPORT_RFDT  USING    P_EXP_TAB.
633      IF P_E_RFDT = ABAP_TRUE AND P_UPDATE = ABAP_TRUE.
634        rfdt_key-date = sy-datlo.
635        rfdt_key-time = sy-timlo.
636
637
638        CASE P_EXP_TAB.
639          WHEN 'BSAS'.
640            rfdt_key-key1(7) = 'AUGJ_AS'.
641            EXPORT
642            IT_CLEARING_DOC_BSAS
643            IT_BSAS
644            IT_BSEG
645          TO DATABASE rfdt(du) ID rfdt_key.  "#EC CI_FLDEXT_OK[2610650]
646            IF sy-subrc = 0.
647              CONCATENATE rfdt_key-key1 rfdt_key-date rfdt_key-time INTO
648            exp_key.
649              NEW-LINE.
650              ULINE (50).
651              FORMAT COLOR 3.
652              WRITE:/ sy-vline NO-GAP,
653                      'TABLE RFDT EXPORT FILE KEY:',
654                   50 sy-vline NO-GAP.
655              FORMAT COLOR 2 INTENSIFIED OFF.
656              WRITE:/ sy-vline NO-GAP,
657                      exp_key,
658                   50 sy-vline NO-GAP.
659              NEW-LINE.
660              ULINE (50).
661              FORMAT COLOR 2 INTENSIFIED ON.
662            ENDIF.
663          WHEN 'BSAD'.
664            rfdt_key-key1(7) = 'AUGJ_AD'.
665            EXPORT
666            IT_CLEARING_DOC_BSAD "#EC CI_FLDEXT_OK[2215424]
667            IT_BSAD "#EC CI_FLDEXT_OK[2215424]
668            IT_BSEG "#EC CI_FLDEXT_OK[2215424]
669          TO DATABASE rfdt(du) ID rfdt_key.  "#EC CI_FLDEXT_OK[2610650]
670            IF sy-subrc = 0.
671              CONCATENATE rfdt_key-key1 rfdt_key-date rfdt_key-time INTO
672            exp_key.
673              NEW-LINE.
674              ULINE (50).
675              FORMAT COLOR 3.
676              WRITE:/ sy-vline NO-GAP,
677                      'TABLE RFDT EXPORT FILE KEY:',
678                   50 sy-vline NO-GAP.
679              FORMAT COLOR 2 INTENSIFIED OFF.
680              WRITE:/ sy-vline NO-GAP,
681                      exp_key,
682                   50 sy-vline NO-GAP.
683              NEW-LINE.
684              ULINE (50).
685              FORMAT COLOR 2 INTENSIFIED ON.
686            ENDIF.
687          WHEN 'BSAK'.
688            rfdt_key-key1(7) = 'AUGJ_AK'.
689            EXPORT
690            IT_CLEARING_DOC_BSAK "#EC CI_FLDEXT_OK[2215424]
691            IT_BSAK "#EC CI_FLDEXT_OK[2215424]
692            IT_BSEG "#EC CI_FLDEXT_OK[2215424]
693          TO DATABASE rfdt(du) ID rfdt_key.  "#EC CI_FLDEXT_OK[2610650]
694            IF sy-subrc = 0.
695              CONCATENATE rfdt_key-key1 rfdt_key-date rfdt_key-time INTO
696            exp_key.
697              NEW-LINE.
698              ULINE (50).
699              FORMAT COLOR 3.
700              WRITE:/ sy-vline NO-GAP,
701                      'TABLE RFDT EXPORT FILE KEY:',
702                   50 sy-vline NO-GAP.
703              FORMAT COLOR 2 INTENSIFIED OFF.
704              WRITE:/ sy-vline NO-GAP,
705                      exp_key,
706                   50 sy-vline NO-GAP.
707              NEW-LINE.
708              ULINE (50).
709              FORMAT COLOR 2 INTENSIFIED ON.
710            ENDIF.
711        ENDCASE.
712      ENDIF.
713    ENDFORM.                    " EXPORT_RFDT
714    *&---------------------------------------------------------------------*
715    *&      Form  GET_DATA_BSAK
716    *&---------------------------------------------------------------------*
717    *       text
718    *----------------------------------------------------------------------*
719    *  -->  p1        text
720    *  <--  p2        text
721    *----------------------------------------------------------------------*
722    FORM GET_DATA_BSAK .
723
724      SELECT DISTINCT BUKRS
725                      LIFNR
726                      AUGDT
727                      AUGBL
728                 FROM bsak
729                  APPENDING CORRESPONDING FIELDS OF TABLE IT_CLEARING_DOC_BSAK
730                  FOR ALL ENTRIES IN T_BUKRS
731                    WHERE BUKRS EQ  T_BUKRS-BUKRS
732                      AND AUGDT GE  L_MIGDT
733                      AND AUGBL IN  S_AUGBL
734                      AND AUGDT IN  S_AUGDT
735                      AND BELNR IN  S_BELNR
736                      AND GJAHR IN  S_GJAHR
737    *{   REPLACE        TNGK900040                                        1
738    *\                  AND AUGGJ EQ  SPACE.
739                      AND ( AUGGJ =  SPACE OR AUGGJ = '' OR AUGGJ IS NULL ).
740    *}   REPLACE
741
742      CLEAR: IT_BSEG,WA_BSEG,IT_BSAK.
743      REFRESH: IT_BSEG,IT_BSAK.
744
745    ** Header
746      FORMAT COLOR 1.
747      ULINE (120).
748      WRITE:/ sy-vline NO-GAP,
749              'Clearings Involved in Correction',
750          120 sy-vline NO-GAP.
751      FORMAT COLOR OFF.
752      FORMAT COLOR 4.
753      WRITE:/ sy-vline NO-GAP,
754          (5) 'BUKRS',
755          (10) 'AUGDT',
756          (10) 'AUGBL',
757          (12) 'LIFNR',
758          (5) 'AUGGJ',
759          (8) 'UPD_BSEG',
760         (8) 'UPD_BSAK',
761         (8) 'UPD_CLR',
762         (4) 'CORR'.
763      WRITE:120 sy-vline NO-GAP.
764      FORMAT COLOR OFF.
765      ULINE (120).
766
767
768      IF P_D_LIST = ABAP_TRUE.
769        FORMAT COLOR 2.
770        WRITE:/ sy-vline NO-GAP,
771            (5) 'BUKRS',
772            (10) 'BELNR',
773            (10) 'GJAHR',
774            (5)  'BUZEI',
775            (10) 'AUGDT',
776            (10) 'AUGBL',
777            (12) 'LIFNR',
778            (9) 'AUGGJ_OLD',
779            (9) 'AUGGJ_NEW',
780            (5) 'TABLE',
781            (5) 'CORR'.
782        WRITE:120 sy-vline NO-GAP.
783        ULINE (120).
784        FORMAT COLOR OFF.
785
786      ENDIF.
787
788    ** End Header
789
790      LOOP AT IT_CLEARING_DOC_BSAK. " Loop at the set and get the lines for clearing
791
792        CLEAR : CNT_UPD_BSAK,CNT_UPD_BSEG,CNT_BSEG_OLD,CNT_BSAK_OLD,CNT_BSEG_NEW,CNT_BSAK_NEW.
793
794    ** Documentatoin of update or test mode
795        IF P_UPDATE = ABAP_TRUE.
796          IT_CLEARING_DOC_BSAK-CORR = 'U'.
797        ELSE.
798          IT_CLEARING_DOC_BSAK-CORR = 'X'.
799        ENDIF.
800        MODIFY IT_CLEARING_DOC_BSAK FROM IT_CLEARING_DOC_BSAK.
801    ** Documentatoin of update or test mode    CLEAR : CNT_UPD_CLR,CNT_UPD_BSAK,CNT_UPD_BSEG.
802
803        DESCRIBE TABLE IT_BSAK  LINES CNT_BSAK_OLD.
804
805        SELECT * FROM BSAK APPENDING CORRESPONDING FIELDS OF TABLE IT_BSAK
806                 WHERE BUKRS =  IT_CLEARING_DOC_BSAK-BUKRS
807                 AND   LIFNR =  IT_CLEARING_DOC_BSAK-LIFNR
808                 AND   AUGDT =  IT_CLEARING_DOC_BSAK-AUGDT
809                 AND   AUGBL =  IT_CLEARING_DOC_BSAK-AUGBL
810    *{   REPLACE        TNGK900040                                        2
811    *\             AND   AUGGJ EQ SPACE.
812                 AND ( AUGGJ =  SPACE OR AUGGJ = '' OR AUGGJ IS NULL ).
813    *}   REPLACE
814
815        IF SY-SUBRC = 0.
816
817          DESCRIBE TABLE IT_BSAK LINES CNT_BSAK_NEW.
818          CLEAR CNT_TEMP_BSAK.
819
820          CNT_TEMP_BSAK = CNT_BSAK_OLD.
821          WHILE CNT_TEMP_BSAK LT CNT_BSAK_NEW.
822            CNT_TEMP_BSAK = CNT_TEMP_BSAK + 1.
823            READ TABLE IT_BSAK INDEX CNT_TEMP_BSAK INTO WA_BSAK.  "#EC CI_NOORDER
824            IF SY-SUBRC = 0.
825              IF WA_BSAK-AUGBL = WA_BSAK-BELNR.
826                IT_CLEARING_DOC_BSAK-AUGGJ = WA_BSAK-GJAHR.
827                MODIFY IT_CLEARING_DOC_BSAK FROM IT_CLEARING_DOC_BSAK.
828    ** Update the internal table with the new value
829                EXIT. " Got the Required Clearing Year, exit while loop.
830              ENDIF.
831            ENDIF.
832
833    **  Try Finding AUGGJ with help from BKPF
834            IF IT_CLEARING_DOC_BSAK-AUGGJ EQ SPACE AND CNT_TEMP_BSAK = CNT_BSAK_NEW.
835              READ TABLE IT_BSAK INDEX CNT_BSAK_NEW INTO  IT_BSAK.  "#EC CI_NOORDER
836              SELECT SINGLE * FROM BSEG INTO CORRESPONDING FIELDS OF WA_BSEG
837                  WHERE        BUKRS =  IT_BSAK-BUKRS
838                         AND   BELNR =  IT_BSAK-BELNR
839                         AND   GJAHR =  IT_BSAK-GJAHR
840                         AND   BUZEI =  IT_BSAK-BUZEI.
841              IF SY-SUBRC = 0.
842                SELECT SINGLE * FROM BKPF INTO WA_BKPF
843                     WHERE BUKRS = IT_CLEARING_DOC_BSAK-BUKRS
844                     AND   BELNR = IT_CLEARING_DOC_BSAK-AUGBL
845                     AND   CPUDT = WA_BSEG-AUGCP.  "#EC CI_NOORDER
846
847                IF SY-SUBRC = 0.
848                  IT_CLEARING_DOC_BSAK-AUGGJ = WA_BKPF-GJAHR.
849                  MODIFY IT_CLEARING_DOC_BSAK FROM IT_CLEARING_DOC_BSAK.
850                ENDIF.
851              ENDIF.
852            ENDIF.  " Try Finding AUGGJ with help from BKPF
853          ENDWHILE. " Try getting AUGGJ from BELNR = AUGBL condition
854
855
856          IF IT_CLEARING_DOC_BSAK-AUGGJ NE SPACE.
857
858    ** Modify the IT and update the database with new values.
859            CNT_TEMP = CNT_BSAK_OLD + 1.
860            LOOP AT IT_BSAK FROM  CNT_TEMP TO CNT_BSAK_NEW.  "#EC CI_NOORDER
861              IT_BSAK-AUGGJ_NEW = IT_CLEARING_DOC_BSAK-AUGGJ.
862              IT_BSAK-CORR  = 'X'.
863              MODIFY IT_BSAK FROM IT_BSAK.
864              IF P_UPDATE = ABAP_TRUE.
865    "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
866    *            UPDATE BSAK SET AUGGJ =  IT_CLEARING_DOC_BSAK-AUGGJ
867    *                       WHERE BUKRS = IT_BSAK-BUKRS
868    *                         AND LIFNR = IT_BSAK-LIFNR
869    *                         AND AUGDT = IT_BSAK-AUGDT
870    *                         AND AUGBL = IT_BSAK-AUGBL
871    *                         AND BELNR = IT_BSAK-BELNR
872    *                         AND GJAHR = IT_BSAK-GJAHR
873    *                         AND BUZEI = IT_BSAK-BUZEI.
874    "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
875                IF SY-SUBRC = 0.
876                  IT_BSAK-CORR = 'U'.
877                  CNT_UPD_BSAK = CNT_UPD_BSAK + sy-dbcnt.
878                ELSE.
879                  IT_BSAK-CORR = 'E'.
880                  IT_CLEARING_DOC_BSAK-CORR = 'E'.
881                  MODIFY IT_CLEARING_DOC_BSAK FROM IT_CLEARING_DOC_BSAK.
882                ENDIF.
883                MODIFY IT_BSAK FROM IT_BSAK.
884              ELSE.
885                CNT_UPD_BSAK = CNT_UPD_BSAK + 1.
886              ENDIF.
887            ENDLOOP.
888
889    ** Modify the IT and update database for BSEG with new AUGGJ
890            CNT_TEMP =  CNT_BSAK_OLD + 1.
891
892            DESCRIBE TABLE IT_BSEG LINES CNT_DISP_BSEG.
893            LOOP AT IT_BSAK FROM CNT_TEMP TO CNT_BSAK_NEW.  "#EC CI_NOORDER
894              DESCRIBE TABLE IT_BSEG LINES CNT_BSEG_OLD.
895
896              SELECT * FROM BSEG APPENDING CORRESPONDING FIELDS OF TABLE IT_BSEG
897                    WHERE BUKRS = IT_BSAK-BUKRS
898                    AND   BELNR = IT_BSAK-BELNR
899                    AND   GJAHR = IT_BSAK-GJAHR
900                    AND   BUZEI = IT_BSAK-BUZEI
901    *{   REPLACE        TNGK900040                                        3
902    *\                AND   AUGGJ EQ SPACE.
903                    AND ( AUGGJ =  SPACE OR AUGGJ = '' ).
904    *}   REPLACE
905
906              IF SY-SUBRC = 0.
907                DESCRIBE TABLE IT_BSEG LINES CNT_BSEG_NEW.
908                CNT_TEMP_BSEG = CNT_BSEG_OLD.
909
910                WHILE CNT_TEMP_BSEG LT CNT_BSEG_NEW.
911
912                  CNT_TEMP_BSEG = CNT_TEMP_BSEG + 1.
913                  READ TABLE IT_BSEG INDEX CNT_TEMP_BSEG INTO IT_BSEG.
914                  IF SY-SUBRC = 0.
915                    IT_BSEG-AUGGJ_NEW = IT_CLEARING_DOC_BSAK-AUGGJ.
916                    IT_BSEG-CORR  = 'X'.
917                    MODIFY IT_BSEG INDEX CNT_TEMP_BSEG FROM IT_BSEG.
918    ** Update the values to the internal table with new AUGGJ
919                    IF P_UPDATE = ABAP_TRUE.
920
921    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
922    * S/4: AUGGJ (clearing fiscal year) cannot be set by direct update - use standard reconciliation RFINDEX/FAGLF03 (Note 946596).
923    *                  UPDATE BSEG SET AUGGJ =  IT_CLEARING_DOC_BSAK-AUGGJ
924    *                             WHERE BUKRS = IT_BSEG-BUKRS
925    *                               AND BELNR = IT_BSEG-BELNR
926    *                               AND GJAHR = IT_BSEG-GJAHR
927    *                               AND BUZEI = IT_BSEG-BUZEI
928    **{   REPLACE        TNGK900040                                        4
929    **\                               AND AUGGJ EQ SPACE.
930                      MESSAGE 'Document not updated. Clearing year (AUGGJ) cannot be set by direct update - use RFINDEX/FAGLF03. Refer SAP Note 946596' TYPE 'E'.
931    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
932
933                      IF SY-SUBRC = 0.
934                        IT_BSEG-CORR = 'U'.
935                        CNT_UPD_BSEG = CNT_UPD_BSEG + sy-dbcnt.
936                      ELSE.
937                        IT_BSEG-CORR = 'E'.
938                        IT_CLEARING_DOC_BSAK-CORR = 'E'.
939                        MODIFY IT_CLEARING_DOC_BSAK FROM IT_CLEARING_DOC_BSAK.
940                      ENDIF.
941                      MODIFY IT_BSEG INDEX CNT_TEMP_BSEG FROM IT_BSEG.
942                    ELSE.
943                      CNT_UPD_BSEG = CNT_UPD_BSEG + 1.
944                    ENDIF.
945                  ENDIF.
946                ENDWHILE.
947              ENDIF.
948            ENDLOOP.
949
950          ELSE.
951            IT_CLEARING_DOC_BSAK-CORR = 'N'.
952            MODIFY IT_CLEARING_DOC_BSAK FROM IT_CLEARING_DOC_BSAK.
953          ENDIF.
954
955          IT_CLEARING_DOC_BSAK-CNT_UPD_BSAK = CNT_UPD_BSAK.
956          IT_CLEARING_DOC_BSAK-CNT_UPD_BSEG = CNT_UPD_BSEG.
957
958          CNT_UPD_CLR =  CNT_UPD_BSAK + CNT_UPD_BSEG.
959
960          IT_CLEARING_DOC_BSAK-CNT_UPD_CLR  = CNT_UPD_CLR.
961          CNT_UPD_TOT = CNT_UPD_TOT + CNT_UPD_CLR.
962
963          MODIFY IT_CLEARING_DOC_BSAK FROM IT_CLEARING_DOC_BSAK.
964
965        ENDIF.      " Clearing Documents in a Clearing
966
967    ** Display the clearing info
968        FORMAT COLOR 4.
969        WRITE:/ sy-vline NO-GAP,
970            (5) IT_CLEARING_DOC_BSAK-BUKRS,   "#EC CI_NOORDER
971           (10) IT_CLEARING_DOC_BSAK-AUGDT,  "#EC CI_NOORDER
972           (10) IT_CLEARING_DOC_BSAK-AUGBL, "#EC CI_NOORDER
973            (12) IT_CLEARING_DOC_BSAK-LIFNR, "#EC CI_NOORDER
974            (5) IT_CLEARING_DOC_BSAK-AUGGJ, "#EC CI_NOORDER
975            (8) CNT_UPD_BSEG, "#EC CI_NOORDER
976           (8)  CNT_UPD_BSAK, "#EC CI_NOORDER
977            (8) CNT_UPD_CLR.  "#EC CI_NOORDER
978        FORMAT COLOR 3.
979        WRITE : (4) IT_CLEARING_DOC_BSAK-CORR.  "#EC CI_NOORDER
980        FORMAT COLOR OFF.
981        WRITE:120 sy-vline NO-GAP.
982        FORMAT COLOR OFF.
983
984        IF P_D_LIST = ABAP_TRUE.
985
986          CNT_TEMP = CNT_DISP_BSEG + 1.
987          LOOP AT IT_BSEG FROM  CNT_TEMP TO CNT_BSEG_NEW.
988            FORMAT COLOR 2.
989            WRITE:/ sy-vline NO-GAP,
990                (5) IT_BSEG-BUKRS, "#EC CI_NOORDER
991                (10) IT_BSEG-BELNR, "#EC CI_NOORDER
992                (10) IT_BSEG-GJAHR, "#EC CI_NOORDER
993                (5)  IT_BSEG-BUZEI, "#EC CI_NOORDER
994                (10) IT_BSEG-AUGDT, "#EC CI_NOORDER
995                (10) IT_BSEG-AUGBL, "#EC CI_NOORDER
996                (12) IT_BSEG-LIFNR, "#EC CI_NOORDER
997                (9) IT_BSEG-AUGGJ, "#EC CI_NOORDER
998                (9) IT_BSEG-AUGGJ_NEW, "#EC CI_NOORDER
999                (5) 'BSEG'.  "#EC CI_NOORDER
1000           FORMAT COLOR 3.
1001           WRITE: (5) IT_BSEG-CORR. "#EC CI_NOORDER
1002           FORMAT COLOR OFF.
1003           WRITE:120 sy-vline NO-GAP. "#EC CI_NOORDER
1004           FORMAT COLOR OFF.
1005
1006         ENDLOOP.
1007
1008         CNT_TEMP = CNT_BSAK_OLD + 1.
1009         LOOP AT IT_BSAK FROM  CNT_TEMP TO CNT_BSAK_NEW.  "#EC CI_NOORDER
1010           FORMAT COLOR 2.
1011           WRITE:/ sy-vline NO-GAP,
1012               (5) IT_BSAK-BUKRS, "#EC CI_NOORDER
1013               (10) IT_BSAK-BELNR, "#EC CI_NOORDER
1014               (10) IT_BSAK-GJAHR, "#EC CI_NOORDER
1015               (5)  IT_BSAK-BUZEI, "#EC CI_NOORDER
1016               (10) IT_BSAK-AUGDT, "#EC CI_NOORDER
1017               (10) IT_BSAK-AUGBL, "#EC CI_NOORDER
1018               (12) IT_BSAK-LIFNR, "#EC CI_NOORDER
1019               (9) IT_BSAK-AUGGJ, "#EC CI_NOORDER
1020               (9) IT_BSAK-AUGGJ_NEW, "#EC CI_NOORDER
1021               (5) 'BSAK'.  "#EC CI_NOORDER
1022           FORMAT COLOR 3.
1023           WRITE: (5) IT_BSAK-CORR.
1024           FORMAT COLOR OFF.
1025           WRITE:120 sy-vline NO-GAP.
1026           FORMAT COLOR OFF.
1027         ENDLOOP.
1028
1029       ENDIF.
1030       ULINE (120).
1031
1032     ENDLOOP.      " Clearing Document Set
1033
1034   ** Export to RFDT all the selected entries
1035   ** Exporting only at the end to get even BSEG entries, may miss values if
1036   ** Program terminates due to some error in between
1037
1038     EXP_TAB = 'BSAK'.
1039     PERFORM EXPORT_RFDT USING EXP_TAB.
1040
1041   ** Display total count and legend
1042     FORMAT COLOR 5.
1043     WRITE:/ sy-vline NO-GAP, 'Total Count of Database Updates ', CNT_UPD_TOT. "#EC CI_NOORDER
1044     FORMAT COLOR OFF.
1045     WRITE:120 sy-vline NO-GAP. "#EC CI_NOORDER
1046     ULINE (120).
1047   ENDFORM.                    " GET_DATA_BSAK
1048   *&---------------------------------------------------------------------*
1049   *&      Form  GET_DATA_BSAD
1050   *&---------------------------------------------------------------------*
1051   *       text
1052   *----------------------------------------------------------------------*
1053   *  -->  p1        text
1054   *  <--  p2        text
1055   *----------------------------------------------------------------------*
1056   FORM GET_DATA_BSAD .
1057
1058     SELECT DISTINCT BUKRS
1059                     KUNNR
1060                     AUGDT
1061                     AUGBL
1062                FROM BSAD
1063                 APPENDING CORRESPONDING FIELDS OF TABLE IT_CLEARING_DOC_BSAD
1064                 FOR ALL ENTRIES IN T_BUKRS
1065                   WHERE BUKRS EQ  T_BUKRS-BUKRS
1066                     AND AUGDT GE  L_MIGDT
1067                     AND AUGBL IN  S_AUGBL
1068                     AND AUGDT IN  S_AUGDT
1069                     AND BELNR IN  S_BELNR
1070                     AND GJAHR IN  S_GJAHR
1071   *{   REPLACE        TNGK900040                                        1
1072   *\                  AND AUGGJ EQ  SPACE.
1073                     AND ( AUGGJ =  SPACE OR AUGGJ = '' OR AUGGJ IS NULL ).
1074   *}   REPLACE
1075
1076     CLEAR: IT_BSEG,WA_BSEG,IT_BSAD.
1077     REFRESH: IT_BSEG,IT_BSAD.
1078
1079   ** Header
1080     FORMAT COLOR 1.
1081     ULINE (120).
1082     WRITE:/ sy-vline NO-GAP,
1083             'Clearings Involved in Correction',
1084         120 sy-vline NO-GAP.
1085     FORMAT COLOR OFF.
1086     FORMAT COLOR 4.
1087     WRITE:/ sy-vline NO-GAP,
1088         (5) 'BUKRS',
1089         (10) 'AUGDT',
1090         (10) 'AUGBL',
1091         (12) 'KUNNR',
1092         (5) 'AUGGJ',
1093         (8) 'UPD_BSEG',
1094        (8) 'UPD_BSAD',
1095        (8) 'UPD_CLR',
1096        (4) 'CORR'.
1097     WRITE:120 sy-vline NO-GAP.
1098     FORMAT COLOR OFF.
1099     ULINE (120).
1100
1101
1102     IF P_D_LIST = ABAP_TRUE.
1103       FORMAT COLOR 2.
1104       WRITE:/ sy-vline NO-GAP,
1105           (5) 'BUKRS',
1106           (10) 'BELNR',
1107           (10) 'GJAHR',
1108           (5)  'BUZEI',
1109           (10) 'AUGDT',
1110           (10) 'AUGBL',
1111           (12) 'KUNNR',
1112           (9) 'AUGGJ_OLD',
1113           (9) 'AUGGJ_NEW',
1114           (5) 'TABLE',
1115           (5) 'CORR'.
1116       WRITE:120 sy-vline NO-GAP.
1117       ULINE (120).
1118       FORMAT COLOR OFF.
1119
1120     ENDIF.
1121
1122   ** End Header
1123
1124     LOOP AT IT_CLEARING_DOC_BSAD. " Loop at the set and get the lines for clearing
1125
1126       CLEAR : CNT_UPD_BSAD,CNT_UPD_BSEG,CNT_BSEG_OLD,CNT_BSAD_OLD,CNT_BSEG_NEW,CNT_BSAD_NEW.
1127
1128   ** Documentatoin of update or test mode
1129       IF P_UPDATE = ABAP_TRUE.
1130         IT_CLEARING_DOC_BSAD-CORR = 'U'.
1131       ELSE.
1132         IT_CLEARING_DOC_BSAD-CORR = 'X'.
1133       ENDIF.
1134       MODIFY IT_CLEARING_DOC_BSAD FROM IT_CLEARING_DOC_BSAD.
1135   ** Documentatoin of update or test mode    CLEAR : CNT_UPD_CLR,CNT_UPD_BSAD,CNT_UPD_BSEG.
1136
1137       DESCRIBE TABLE IT_BSAD  LINES CNT_BSAD_OLD.
1138
1139       SELECT * FROM BSAD APPENDING CORRESPONDING FIELDS OF TABLE IT_BSAD
1140                WHERE BUKRS =  IT_CLEARING_DOC_BSAD-BUKRS
1141                AND   KUNNR =  IT_CLEARING_DOC_BSAD-KUNNR
1142                AND   AUGDT =  IT_CLEARING_DOC_BSAD-AUGDT
1143                AND   AUGBL =  IT_CLEARING_DOC_BSAD-AUGBL
1144   *{   REPLACE        TNGK900040                                        2
1145   *\             AND   AUGGJ EQ SPACE.
1146                AND ( AUGGJ =  SPACE OR AUGGJ = '' OR AUGGJ IS NULL ).
1147   *}   REPLACE
1148
1149       IF SY-SUBRC = 0.
1150
1151         DESCRIBE TABLE IT_BSAD LINES CNT_BSAD_NEW.
1152         CLEAR CNT_TEMP_BSAD.
1153
1154         CNT_TEMP_BSAD = CNT_BSAD_OLD.
1155         WHILE CNT_TEMP_BSAD LT CNT_BSAD_NEW.
1156           CNT_TEMP_BSAD = CNT_TEMP_BSAD + 1.
1157           READ TABLE IT_BSAD INDEX CNT_TEMP_BSAD INTO WA_BSAD.  "#EC CI_NOORDER
1158           IF SY-SUBRC = 0.
1159             IF WA_BSAD-AUGBL = WA_BSAD-BELNR.
1160               IT_CLEARING_DOC_BSAD-AUGGJ = WA_BSAD-GJAHR.
1161               MODIFY IT_CLEARING_DOC_BSAD FROM IT_CLEARING_DOC_BSAD.
1162   ** Update the internal table with the new value
1163               EXIT. " Got the Required Clearing Year, exit while loop.
1164             ENDIF.
1165           ENDIF.
1166
1167   **  Try Finding AUGGJ with help from BKPF
1168           IF IT_CLEARING_DOC_BSAD-AUGGJ EQ SPACE AND CNT_TEMP_BSAD = CNT_BSAD_NEW.
1169             READ TABLE IT_BSAD INDEX CNT_BSAD_NEW INTO IT_BSAD.  "#EC CI_NOORDER
1170             SELECT SINGLE * FROM BSEG INTO CORRESPONDING FIELDS OF WA_BSEG
1171                 WHERE        BUKRS =  IT_BSAD-BUKRS
1172                        AND   BELNR =  IT_BSAD-BELNR
1173                        AND   GJAHR =  IT_BSAD-GJAHR
1174                        AND   BUZEI =  IT_BSAD-BUZEI.
1175             IF SY-SUBRC = 0.
1176               SELECT SINGLE * FROM BKPF INTO WA_BKPF
1177                    WHERE BUKRS = IT_CLEARING_DOC_BSAD-BUKRS
1178                    AND   BELNR = IT_CLEARING_DOC_BSAD-AUGBL
1179                    AND   CPUDT = WA_BSEG-AUGCP.  "#EC CI_NOORDER
1180
1181               IF SY-SUBRC = 0.
1182                 IT_CLEARING_DOC_BSAD-AUGGJ = WA_BKPF-GJAHR.
1183                 MODIFY IT_CLEARING_DOC_BSAD FROM IT_CLEARING_DOC_BSAD.
1184               ENDIF.
1185             ENDIF.
1186           ENDIF.  " Try Finding AUGGJ with help from BKPF
1187         ENDWHILE. " Try getting AUGGJ from BELNR = AUGBL condition
1188
1189
1190         IF IT_CLEARING_DOC_BSAD-AUGGJ NE SPACE.
1191
1192   ** Modify the IT and update the database with new values.
1193           CNT_TEMP = CNT_BSAD_OLD + 1.
1194           LOOP AT IT_BSAD FROM  CNT_TEMP TO CNT_BSAD_NEW.  "#EC CI_NOORDER
1195             IT_BSAD-AUGGJ_NEW = IT_CLEARING_DOC_BSAD-AUGGJ.
1196             IT_BSAD-CORR  = 'X'.
1197             MODIFY IT_BSAD FROM IT_BSAD.
1198             IF P_UPDATE = ABAP_TRUE.
1199   "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
1200   *            UPDATE BSAD SET AUGGJ =  IT_CLEARING_DOC_BSAD-AUGGJ
1201   *                       WHERE BUKRS = IT_BSAD-BUKRS
1202   *                         AND KUNNR = IT_BSAD-KUNNR
1203   *                         AND AUGDT = IT_BSAD-AUGDT
1204   *                         AND AUGBL = IT_BSAD-AUGBL
1205   *                         AND BELNR = IT_BSAD-BELNR
1206   *                         AND GJAHR = IT_BSAD-GJAHR
1207   *                         AND BUZEI = IT_BSAD-BUZEI.
1208   "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
1209               IF SY-SUBRC = 0.
1210                 IT_BSAD-CORR = 'U'.
1211                 CNT_UPD_BSAD = CNT_UPD_BSAD + sy-dbcnt.
1212               ELSE.
1213                 IT_BSAD-CORR = 'E'.
1214                 IT_CLEARING_DOC_BSAD-CORR = 'E'.
1215                 MODIFY IT_CLEARING_DOC_BSAD FROM IT_CLEARING_DOC_BSAD.
1216               ENDIF.
1217               MODIFY IT_BSAD FROM IT_BSAD.
1218             ELSE.
1219               CNT_UPD_BSAD = CNT_UPD_BSAD + 1.
1220             ENDIF.
1221           ENDLOOP.
1222
1223   ** Modify the IT and update database for BSEG with new AUGGJ
1224           CNT_TEMP =  CNT_BSAD_OLD + 1.
1225
1226           DESCRIBE TABLE IT_BSEG LINES CNT_DISP_BSEG.
1227           LOOP AT IT_BSAD FROM CNT_TEMP TO CNT_BSAD_NEW.  "#EC CI_NOORDER
1228             DESCRIBE TABLE IT_BSEG LINES CNT_BSEG_OLD.
1229
1230             SELECT * FROM BSEG APPENDING CORRESPONDING FIELDS OF TABLE IT_BSEG
1231                   WHERE BUKRS = IT_BSAD-BUKRS
1232                   AND   BELNR = IT_BSAD-BELNR
1233                   AND   GJAHR = IT_BSAD-GJAHR
1234                   AND   BUZEI = IT_BSAD-BUZEI
1235   *{   REPLACE        TNGK900040                                        3
1236   *\                AND   AUGGJ EQ SPACE.
1237                   AND ( AUGGJ =  SPACE OR AUGGJ = '' ).
1238   *}   REPLACE
1239
1240             IF SY-SUBRC = 0.
1241               DESCRIBE TABLE IT_BSEG LINES CNT_BSEG_NEW.
1242               CNT_TEMP_BSEG = CNT_BSEG_OLD.
1243
1244               WHILE CNT_TEMP_BSEG LT CNT_BSEG_NEW.
1245
1246                 CNT_TEMP_BSEG = CNT_TEMP_BSEG + 1.
1247                 READ TABLE IT_BSEG INDEX CNT_TEMP_BSEG INTO IT_BSEG.
1248                 IF SY-SUBRC = 0.
1249                   IT_BSEG-AUGGJ_NEW = IT_CLEARING_DOC_BSAD-AUGGJ.
1250                   IT_BSEG-CORR  = 'X'.
1251                   MODIFY IT_BSEG INDEX CNT_TEMP_BSEG FROM IT_BSEG.
1252   ** Update the values to the internal table with new AUGGJ
1253                   IF P_UPDATE = ABAP_TRUE.
1254
1255   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1256   * S/4: AUGGJ (clearing fiscal year) cannot be set by direct update - use standard reconciliation RFINDEX/FAGLF03 (Note 946596).
1257   *                  UPDATE BSEG SET AUGGJ =  IT_CLEARING_DOC_BSAD-AUGGJ
1258   *                             WHERE BUKRS = IT_BSEG-BUKRS
1259   *                               AND BELNR = IT_BSEG-BELNR
1260   *                               AND GJAHR = IT_BSEG-GJAHR
1261   *                               AND BUZEI = IT_BSEG-BUZEI
1262   **{   REPLACE        TNGK900040                                        4
1263   **\                               AND AUGGJ EQ SPACE.
1264                     MESSAGE 'Document not updated. Clearing year (AUGGJ) cannot be set by direct update - use RFINDEX/FAGLF03. Refer SAP Note 946596' TYPE 'E'.
1265   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1266   *}   REPLACE
1267                     IF SY-SUBRC = 0.
1268                       IT_BSEG-CORR = 'U'.
1269                       CNT_UPD_BSEG = CNT_UPD_BSEG + sy-dbcnt.
1270                     ELSE.
1271                       IT_BSEG-CORR = 'E'.
1272                       IT_CLEARING_DOC_BSAD-CORR = 'E'.
1273                       MODIFY IT_CLEARING_DOC_BSAD FROM IT_CLEARING_DOC_BSAD.
1274                     ENDIF.
1275                     MODIFY IT_BSEG INDEX CNT_TEMP_BSEG FROM IT_BSEG.
1276                   ELSE.
1277                     CNT_UPD_BSEG = CNT_UPD_BSEG + 1.
1278                   ENDIF.
1279                 ENDIF.
1280               ENDWHILE.
1281             ENDIF.
1282           ENDLOOP.
1283
1284         ELSE.
1285           IT_CLEARING_DOC_BSAD-CORR = 'N'.
1286           MODIFY IT_CLEARING_DOC_BSAD FROM IT_CLEARING_DOC_BSAD.
1287         ENDIF.
1288
1289         IT_CLEARING_DOC_BSAD-CNT_UPD_BSAD = CNT_UPD_BSAD.
1290         IT_CLEARING_DOC_BSAD-CNT_UPD_BSEG = CNT_UPD_BSEG.
1291
1292         CNT_UPD_CLR =  CNT_UPD_BSAD + CNT_UPD_BSEG.
1293
1294         IT_CLEARING_DOC_BSAD-CNT_UPD_CLR  = CNT_UPD_CLR.
1295         CNT_UPD_TOT = CNT_UPD_TOT + CNT_UPD_CLR.
1296
1297         MODIFY IT_CLEARING_DOC_BSAD FROM IT_CLEARING_DOC_BSAD.
1298
1299       ENDIF.      " Clearing Documents in a Clearing
1300
1301   ** Display the clearing info
1302       FORMAT COLOR 4.
1303       WRITE:/ sy-vline NO-GAP,
1304           (5) IT_CLEARING_DOC_BSAD-BUKRS,
1305          (10) IT_CLEARING_DOC_BSAD-AUGDT,
1306          (10) IT_CLEARING_DOC_BSAD-AUGBL,
1307           (12) IT_CLEARING_DOC_BSAD-KUNNR,
1308           (5) IT_CLEARING_DOC_BSAD-AUGGJ,
1309           (8) CNT_UPD_BSEG,
1310          (8)  CNT_UPD_BSAD,
1311           (8) CNT_UPD_CLR.  "#EC CI_NOORDER
1312       FORMAT COLOR 3.
1313       WRITE : (4) IT_CLEARING_DOC_BSAD-CORR.  "#EC CI_NOORDER
1314       FORMAT COLOR OFF.
1315       WRITE:120 sy-vline NO-GAP.
1316       FORMAT COLOR OFF.
1317
1318       IF P_D_LIST = ABAP_TRUE.
1319
1320         CNT_TEMP = CNT_DISP_BSEG + 1.
1321         LOOP AT IT_BSEG FROM  CNT_TEMP TO CNT_BSEG_NEW.
1322           FORMAT COLOR 2.
1323           WRITE:/ sy-vline NO-GAP,
1324               (5) IT_BSEG-BUKRS,
1325               (10) IT_BSEG-BELNR,
1326               (10) IT_BSEG-GJAHR,
1327               (5)  IT_BSEG-BUZEI,
1328               (10) IT_BSEG-AUGDT,
1329               (10) IT_BSEG-AUGBL,
1330               (12) IT_BSEG-KUNNR,
1331               (9) IT_BSEG-AUGGJ,
1332               (9) IT_BSEG-AUGGJ_NEW,
1333               (5) 'BSEG'.  "#EC CI_NOORDER
1334           FORMAT COLOR 3.
1335           WRITE: (5) IT_BSEG-CORR.
1336           FORMAT COLOR OFF.
1337           WRITE:120 sy-vline NO-GAP.
1338           FORMAT COLOR OFF.
1339
1340         ENDLOOP.
1341
1342         CNT_TEMP = CNT_BSAD_OLD + 1.
1343         LOOP AT IT_BSAD FROM  CNT_TEMP TO CNT_BSAD_NEW.  "#EC CI_NOORDER
1344           FORMAT COLOR 2.
1345           WRITE:/ sy-vline NO-GAP,
1346               (5) IT_BSAD-BUKRS,
1347               (10) IT_BSAD-BELNR,
1348               (10) IT_BSAD-GJAHR,
1349               (5)  IT_BSAD-BUZEI,
1350               (10) IT_BSAD-AUGDT,
1351               (10) IT_BSAD-AUGBL,
1352               (12) IT_BSAD-KUNNR,
1353               (9) IT_BSAD-AUGGJ,
1354               (9) IT_BSAD-AUGGJ_NEW,
1355               (5) 'BSAD'.  "#EC CI_NOORDER
1356           FORMAT COLOR 3.
1357           WRITE: (5) IT_BSAD-CORR.
1358           FORMAT COLOR OFF.
1359           WRITE:120 sy-vline NO-GAP.
1360           FORMAT COLOR OFF.
1361         ENDLOOP.
1362
1363       ENDIF.
1364       ULINE (120).
1365
1366     ENDLOOP.      " Clearing Document Set
1367
1368   ** Export to RFDT all the selected entries
1369   ** Exporting only at the end to get even BSEG entries, may miss values if
1370   ** Program terminates due to some error in between
1371
1372     EXP_TAB = 'BSAD'.
1373     PERFORM EXPORT_RFDT USING EXP_TAB.
1374
1375   ** Display total count and legend
1376     FORMAT COLOR 5.
1377     WRITE:/ sy-vline NO-GAP, 'Total Count of Database Updates ', CNT_UPD_TOT.
1378     FORMAT COLOR OFF.
1379     WRITE:120 sy-vline NO-GAP.
1380     ULINE (120).
1381
1382   ENDFORM.                    " GET_DATA_BSAD
*--- End of ZF_FILL_MISSING_AUGGJ_NGLM - 1382 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CABAP                                   Level 1    Page 2
Object           ZF_FILL_MISSING_AUGGJ_NGLM                Lines 360
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:59
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
Generated incl.  <REPINI>                                  Level 1    Page 3
Object           ZF_FILL_MISSING_AUGGJ_NGLM                Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:59
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
Object           ZF_FILL_MISSING_AUGGJ_NGLM                Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:59
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
Object           ZF_FILL_MISSING_AUGGJ_NGLM                Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:59
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
Object           ZF_FILL_MISSING_AUGGJ_NGLM                Lines 1
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:59
----------------------------------------------------------------------------------------------------
1      * INCLUDE DB__SSEL
*--- End of DB__SSEL - 1 lines ---
