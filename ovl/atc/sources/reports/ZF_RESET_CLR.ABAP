----------------------------------------------------------------------------------------------------
Main program     ZF_RESET_CLR                              Level 0    Page 1
Object           ZF_RESET_CLR                              Lines 2632
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:05
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *& Report  ZF_RESET_CLR
3      *&
4      *&---------------------------------------------------------------------*
5      *& The report will allow to reset clearings without balance-0-check.
6      *& Ranges of clearing documents per account type are possible. It is
7      *& NOT possible to run the report without entering at least one AUGBL
8      *& to avoid an unwanted reset of ALL clearings for an account type!
9      *& In update mode a change document is written for each reset line.
10     *&
11     *& If the clearing document had BSTAT 'A' this would be automatically
12     *& changed to 'B' in update mode.
13     *& 'ALE-extern' is excluded as AUGBL.
14     *&
15     *& Duplicate clearings: If one item is cleared with a different clea-
16     *& ring information in BSEG only the index is deleted, BSEG is kept.
17     *&
18     *& As of version 2 it is also possible to handle reversals that will
19     *& be automatically reset once the respective flag is set on the
20     *& selection screen.
21     *&
22     *& As of version 3 the report will detect exchange rate differences
23     *& items in the clearing documents that require a reversal in the
24     *& original period. The respective keys are submitted to the report
25     *& SAPF080 for automatic reversal.
26     *&
27     *& As of version 5 ledgergroup-specific clearing is added for releases
28     *& as of EHP6.03 .
29     *&---------------------------------------------------------------------*
30     *& Change log:
31     *& UD280411 - reset reversal added
32     *& UD050913 - in presence of KDF lines the report will automatically
33     *&            reverse the reset clearing document via SAPF080
34     *& UD200416 - allow to suppress reversal by special flag
35     *& UD281016 - legdergroup-specific clearings processing added
36     *&          - reversal with different period is allowed, too
37     *&---------------------------------------------------------------------*
38     *& Version 5
39     *&---------------------------------------------------------------------*
40     *& Report in Q3A
41     *& Author: D033001
42     *&---------------------------------------------------------------------*
43
44     REPORT zf_reset_clr LINE-SIZE 150 NO STANDARD PAGE HEADING.
45
46     TABLES: bseg, bkpf, t001, bsis, bsas, bsik, bsak, bsid, bsad.
47     *** cleared items
48     TYPES: BEGIN OF index,
49            bukrs TYPE bseg-bukrs,
50            augdt TYPE bseg-augdt,
51            augbl TYPE bseg-augbl,
52            auggj TYPE bseg-auggj,
53            zuonr TYPE bseg-zuonr,                               "UD281016
54            belnr TYPE bseg-belnr,
55            gjahr TYPE bseg-gjahr,
56            buzei TYPE bseg-buzei,
57            xarch TYPE bsis-xarch,
58            koart TYPE bseg-koart,
59            konto TYPE bseg-hkont,
60            xhres TYPE bseg-xhres,
61            recon TYPE bseg-hkont,
62            xlgclr TYPE c,                                       "UD281016
63            bstat  TYPE c,                                       "UD281016
64            END OF index.
65     DATA: gt_index TYPE TABLE OF index WITH HEADER LINE.
66     DATA: expert TYPE c.
67     DATA: exp_arc TYPE c.
68     DATA: x_koart TYPE c.
69     *** data for change documents
70     TYPES: BEGIN OF bsegr.
71             INCLUDE STRUCTURE fbsegr.
72     TYPES: END OF bsegr.
73     DATA: gt_xbsegr TYPE TABLE OF bsegr WITH HEADER LINE.
74     DATA: gt_ybsegr TYPE TABLE OF bsegr WITH HEADER LINE.
75     DATA: upd_bsegr               TYPE c.
76     DATA: objectid                TYPE cdhdr-objectid.
77     DATA: tcode                   TYPE cdhdr-tcode.
78     DATA: planned_change_number   TYPE cdhdr-planchngnr.
79     DATA: utime                   TYPE cdhdr-utime.
80     DATA: udate                   TYPE cdhdr-udate.
81     DATA: username                TYPE cdhdr-username.
82     DATA: cdoc_planned_or_real    TYPE cdhdr-change_ind.
83     DATA: cdoc_upd_object         TYPE cdhdr-change_ind VALUE 'U'.
84     DATA: cdoc_no_change_pointers TYPE cdhdr-change_ind.
85     *** data for clearing key
86     TYPES: BEGIN OF key,
87            bukrs    TYPE bseg-bukrs,
88            augdt    TYPE bseg-augdt,
89            augbl    TYPE bseg-augbl,
90            auggj    TYPE bseg-auggj,
91            revdate  TYPE bkpf-budat,                            "UD281016
92            cnt_netb TYPE i,
93            cnt_arch TYPE i,
94            cl_bstat TYPE i,
95            reverse  TYPE i,                                     "UD280411
96            kdf      TYPE i,                                     "UD050913
97            xlgclr   TYPE i,                                     "UD281016
98            END OF key.
99     *DATA: gt_key TYPE SORTED TABLE OF KEY WITH HEADER LINE     "UD281016
100    *      WITH UNIQUE KEY bukrs augdt augbl auggj.             "UD281016
101    DATA: gt_key TYPE TABLE OF KEY WITH HEADER LINE.            "UD281016
102    DATA: count_clr TYPE i.
103    *DATA: gt_key_excl TYPE SORTED TABLE OF KEY WITH HEADER LINE"UD281016
104    *      WITH UNIQUE KEY bukrs augdt augbl auggj.             "UD281016
105    DATA: gt_key_excl TYPE TABLE OF KEY WITH HEADER LINE.       "UD281016
106    DATA: cnt_excl TYPE i.
107    *** message handling
108    TYPES: BEGIN OF message,
109           bukrs     TYPE bkpf-bukrs,
110           belnr     TYPE bkpf-belnr,
111           gjahr     TYPE bkpf-gjahr,
112           buzei     TYPE bseg-buzei,
113           bvorg     TYPE bkpf-bvorg,
114    *** type 0: update, 1: E, 2: W, 3: I
115           type      TYPE i,
116           class(10) TYPE c,
117           msg(90)   TYPE c,
118           END OF message.
119    DATA: gt_mess TYPE TABLE OF message WITH HEADER LINE.
120    *** drill-down
121    DATA: d_bukrs TYPE bkpf-bukrs.
122    DATA: d_belnr TYPE bkpf-belnr.
123    DATA: d_gjahr TYPE bkpf-gjahr.
124    *** reversal processing: header information                 "UD280411
125    TYPES: BEGIN OF rev_key,                                    "UD280411
126           bukrs   TYPE bkpf-bukrs,                             "UD280411
127           belnr_2 TYPE bkpf-belnr,                             "UD280411
128           gjahr_2 TYPE bkpf-gjahr,                             "UD280411
129           belnr_1 TYPE bkpf-belnr,                             "UD280411
130           gjahr_1 TYPE bkpf-gjahr,                             "UD280411
131           END OF rev_key.                                      "UD280411
132    DATA: gt_rev_key TYPE SORTED TABLE OF rev_key WITH HEADER LINE"UD2804
133          WITH UNIQUE KEY bukrs belnr_2 gjahr_2.                "UD280411
134    DATA: gt_bkpf_rev TYPE TABLE OF bkpf WITH HEADER LINE.      "UD280411
135
136
137    SELECTION-SCREEN BEGIN OF BLOCK 001 WITH FRAME TITLE text_001.
138
139    SELECTION-SCREEN BEGIN OF LINE.
140    SELECTION-SCREEN COMMENT 2(24) text_013 FOR FIELD p_bukrs.
141    SELECTION-SCREEN POSITION 27.
142    PARAMETERS:      p_bukrs TYPE bseg-bukrs OBLIGATORY.
143    SELECTION-SCREEN END OF LINE.
144
145    SELECTION-SCREEN SKIP.
146    SELECTION-SCREEN BEGIN OF BLOCK 002 WITH FRAME TITLE text_002.
147
148    SELECTION-SCREEN BEGIN OF LINE.
149    SELECTION-SCREEN POSITION 1.
150    PARAMETERS: p_gl RADIOBUTTON GROUP 001 DEFAULT 'X'.
151    SELECTION-SCREEN COMMENT 3(60) text_010 FOR FIELD p_gl.
152    SELECTION-SCREEN END OF LINE.
153
154    SELECTION-SCREEN BEGIN OF LINE.
155    SELECTION-SCREEN POSITION 1.
156    PARAMETERS: p_cust RADIOBUTTON GROUP 001.
157    SELECTION-SCREEN COMMENT 3(60) text_011 FOR FIELD p_cust.
158    SELECTION-SCREEN END OF LINE.
159
160    SELECTION-SCREEN BEGIN OF LINE.
161    SELECTION-SCREEN POSITION 1.
162    PARAMETERS: p_vend RADIOBUTTON GROUP 001.
163    SELECTION-SCREEN COMMENT 3(60) text_012 FOR FIELD p_vend.
164    SELECTION-SCREEN END OF LINE.
165
166    *************************************************************UD281016
167    *** add selection for ledger-specific clearing processes    "UD281016
168    SELECTION-SCREEN BEGIN OF LINE.                             "UD281016
169    SELECTION-SCREEN POSITION 1.                                "UD281016
170    PARAMETERS: p_xlgclr RADIOBUTTON GROUP 001.                 "UD281016
171    SELECTION-SCREEN COMMENT 3(60) text_021 FOR FIELD p_xlgclr. "UD281016
172    SELECTION-SCREEN END OF LINE.                               "UD281016
173    *************************************************************UD281016
174
175    SELECTION-SCREEN SKIP.
176    SELECTION-SCREEN BEGIN OF LINE.
177    SELECTION-SCREEN COMMENT 2(19) text_016 FOR FIELD s_konto.
178    SELECTION-SCREEN POSITION 22.
179    SELECT-OPTIONS:  s_konto FOR bseg-hkont.
180    SELECTION-SCREEN END OF LINE.
181
182    SELECTION-SCREEN END OF BLOCK 002.
183
184    SELECTION-SCREEN SKIP.
185    SELECTION-SCREEN BEGIN OF BLOCK 003 WITH FRAME TITLE text_003.
186
187    SELECTION-SCREEN BEGIN OF LINE.
188    SELECTION-SCREEN COMMENT 2(19) text_014 FOR FIELD s_augbl.
189    SELECTION-SCREEN POSITION 22.
190    SELECT-OPTIONS:  s_augbl FOR bseg-augbl.
191    SELECTION-SCREEN END OF LINE.
192
193    SELECTION-SCREEN BEGIN OF LINE.
194    SELECTION-SCREEN COMMENT 2(19) text_015 FOR FIELD s_augdt.
195    SELECTION-SCREEN POSITION 22.
196    SELECT-OPTIONS:  s_augdt FOR bseg-augdt.
197    SELECTION-SCREEN END OF LINE.
198
199    SELECTION-SCREEN END OF BLOCK 003.
200
201    *************************************************************UD050913
202    SELECTION-SCREEN SKIP.                                      "UD050913
203    SELECTION-SCREEN BEGIN OF BLOCK 004 WITH FRAME TITLE text_004."UD050
204                                                                "UD050913
205    SELECTION-SCREEN BEGIN OF LINE.                             "UD050913
206    SELECTION-SCREEN COMMENT 1(23) text_020 FOR FIELD p_stgrd.  "UD050913
207    SELECTION-SCREEN POSITION 25.                               "UD050913
208    PARAMETERS: p_stgrd TYPE bkpf-stgrd.                        "UD050913
209    SELECTION-SCREEN END OF LINE.                               "UD050913
210                                                                "UD050913
211    *************************************************************UD281016
212    *** allow different reversal date                           "UD281016
213    SELECTION-SCREEN BEGIN OF LINE.                             "UD281016
214    SELECTION-SCREEN COMMENT 1(23) text_023 FOR FIELD newdate.  "UD281016
215    SELECTION-SCREEN POSITION 25.                               "UD281016
216    PARAMETERS: newdate AS CHECKBOX.                            "UD281016
217    SELECTION-SCREEN END OF LINE.                               "UD281016
218                                                                "UD281016
219    SELECTION-SCREEN BEGIN OF LINE.                             "UD281016
220    SELECTION-SCREEN COMMENT 1(23) text_024 FOR FIELD revdate.  "UD281016
221    SELECTION-SCREEN POSITION 25.                               "UD281016
222    PARAMETERS: revdate TYPE bkpf-budat.                        "UD281016
223    SELECTION-SCREEN END OF LINE.                               "UD281016
224                                                                "UD281016
225    *************************************************************UD281016
226    SELECTION-SCREEN END OF BLOCK 004.                          "UD050913
227    *************************************************************UD050913
228
229    SELECTION-SCREEN BEGIN OF LINE.
230    SELECTION-SCREEN COMMENT 2(18) text_018 FOR FIELD ign_arch
231                                            MODIF ID arc.
232    SELECTION-SCREEN POSITION 27.
233    PARAMETERS: ign_arch AS CHECKBOX MODIF ID arc.
234    SELECTION-SCREEN END OF LINE.
235
236    SELECTION-SCREEN BEGIN OF LINE.                             "UD280411
237    SELECTION-SCREEN COMMENT 2(18) text_019 FOR FIELD x_revers. "UD280411
238    SELECTION-SCREEN POSITION 27.                               "UD280411
239    PARAMETERS:      x_revers AS CHECKBOX.                      "UD280411
240    SELECTION-SCREEN END OF LINE.                               "UD280411
241
242    *************************************************************UD200416
243    *** allow reset clearing without reversal                   "UD200416
244    SELECTION-SCREEN BEGIN OF LINE.                             "UD200416
245    SELECTION-SCREEN COMMENT 2(18) text_022 FOR FIELD no_rev.   "UD200416
246    SELECTION-SCREEN POSITION 27.                               "UD200416
247    PARAMETERS: no_rev AS CHECKBOX.                             "UD200416
248    SELECTION-SCREEN END OF LINE.                               "UD200416
249    *************************************************************UD200416
250
251    SELECTION-SCREEN BEGIN OF LINE.
252    SELECTION-SCREEN COMMENT 2(18) text_017 FOR FIELD update.
253    SELECTION-SCREEN POSITION 27.
254    PARAMETERS: update AS CHECKBOX.
255    SELECTION-SCREEN END OF LINE.
256
257    SELECTION-SCREEN END OF BLOCK 001.
258
259    INITIALIZATION.
260
261      text_001 = 'Clearing Document Selection'.
262      text_002 = 'Account Selection'.
263      text_003 = 'Clearing Details'.
264      text_004 = 'Reversal Reason For Automatic Reversals'.     "UD050913
265      text_010 = 'G/L Account'.
266      text_011 = 'Customer Account'.
267      text_012 = 'Vendor Account'.
268      text_013 = 'Company Code'.
269      text_014 = 'Clearing Document'.
270      text_015 = 'Clearing Date'.
271      text_016 = 'Account'.
272      text_017 = 'Update database'.
273      text_018 = 'Ignore Archiving'.
274      text_019 = 'Reset Reversal'.                              "UD280411
275      text_020 = 'Reversal Reason'.                             "UD050913
276      text_022 = 'Suppress SAPF080'.                            "UD200416
277    *************************************************************UD281016
278      text_021 = 'Ledgergroup-specific G/L Account (as of Release 603)'.
279      text_023 = 'Different Reversal Date'.
280      text_024 = 'Reversal Posting Date'.
281    *************************************************************UD281016
282
283    AT SELECTION-SCREEN.
284      PERFORM check_input.
285
286    AT SELECTION-SCREEN OUTPUT.
287      PERFORM screen.
288
289    AT LINE-SELECTION.
290      SET PARAMETER ID 'BUK' FIELD d_bukrs.
291      SET PARAMETER ID 'BLN' FIELD d_belnr.
292      SET PARAMETER ID 'GJR' FIELD d_gjahr.
293      CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
294
295    START-OF-SELECTION.
296    *** verify that S_AUGBL is not initial
297      PERFORM late_check_s_augbl.
298    *** get all involved cleared items per KOART
299      IF x_koart = 'D'.
300        PERFORM select_clearing_bsad.
301      ENDIF.
302      IF x_koart = 'K'.
303        PERFORM select_clearing_bsak.
304      ENDIF.
305      IF x_koart EQ 'S'.
306        PERFORM select_clearing_bsas.
307      ENDIF.
308    *************************************************************UD281016
309      IF x_koart EQ 'X'.                                        "UD281016
310        PERFORM select_clearing_faglbsas.                       "UD281016
311      ENDIF.                                                    "UD281016
312    *************************************************************UD281016
313    *** get BSTAT A headers
314      PERFORM get_bstat_a.
315    *** identify reversals, BVORG etc.
316      PERFORM check_clr_doc.
317    *** revise key using IGN_ARCH
318      PERFORM revise_key_arch.
319    *** processing of cleared items
320      PERFORM process_clearings.
321    *** output excluded cases
322      PERFORM output_excl.
323    *** output cases to be reset
324      PERFORM output.
325    *************************************************************UD050913
326    *** reverse those clearing documents containing KDF lines   "UD050913
327      PERFORM reverse_reset_clr.                                "UD050913
328    *************************************************************UD050913
329
330    *&---------------------------------------------------------------------*
331    *&      Form  CHECK_INPUT
332    *&---------------------------------------------------------------------*
333    FORM check_input .
334
335    *** does BUKRS exist?
336      SELECT SINGLE * FROM t001
337        WHERE bukrs EQ p_bukrs.
338      IF sy-subrc NE 0.
339        MESSAGE e016(gu)
340        WITH 'Company code' p_bukrs 'does not exist'.
341      ENDIF.
342    *** eliminate 'ALE-extern'
343      LOOP AT s_augbl
344        WHERE sign EQ 'I'
345          AND ( low  EQ 'ALE-EXTERN' OR
346                high EQ 'ALE-EXTERN' ).
347        DELETE s_augbl.
348        MESSAGE i016(gu)
349        WITH 'ALE-extern is not a valid clearing'.
350      ENDLOOP.
351    *** determine KOART
352      IF p_gl EQ 'X'.
353        x_koart = 'S'.
354    *************************************************************UD281016
355    *** ledgergroup-specific clearing                           "UD281016
356      ELSEIF p_xlgclr EQ 'X'.                                   "UD281016
357    *** verify that BSEG-xlgclr is existing                     "UD281016
358        DATA: ls_dd03l TYPE dd03l.                              "UD281016
359        SELECT SINGLE * FROM dd03l INTO ls_dd03l                "UD281016
360          WHERE tabname   EQ 'BSEG'                             "UD281016
361            AND fieldname EQ 'XLGCLR'.                          "UD281016
362        IF NOT sy-subrc EQ 0.                                   "UD281016
363          MESSAGE e016(gu)                                      "UD281016
364          WITH 'Ledgergroup-specific clearing not possible'     "UD281016
365               'in this release'.                               "UD281016
366        ENDIF.                                                  "UD281016
367        x_koart = 'X'.                                          "UD281016
368    *************************************************************UD281016
369      ELSEIF p_cust EQ 'X'.
370        x_koart = 'D'.
371      ELSE.
372        x_koart = 'K'.
373      ENDIF.
374      IF sy-ucomm EQ 'SAPONLY'. expert = 'X'. ENDIF.
375      IF sy-ucomm EQ 'IGN_ARCH'. exp_arc = 'X'. ENDIF.
376    ENDFORM.                    " CHECK_INPUT
377
378    *&---------------------------------------------------------------------*
379    *&      Form  SELECT_CLEARING_BSAD
380    *&---------------------------------------------------------------------*
381    FORM select_clearing_bsad .
382      DATA: ls_bsad TYPE bsad.
383      DATA: ls_xhres TYPE skb1-xkres.
384
385      SELECT * FROM bsad INTO ls_bsad
386        WHERE bukrs EQ p_bukrs
387          AND kunnr IN s_konto
388          AND augbl IN s_augbl
389          AND augdt IN s_augdt.
390        CLEAR gt_index.
391        MOVE-CORRESPONDING ls_bsad TO gt_index.
392        gt_index-koart = 'D'.
393        gt_index-konto = ls_bsad-kunnr.
394    *** check recon account
395        gt_index-recon = ls_bsad-hkont.
396        SELECT SINGLE xkres FROM skb1 INTO ls_xhres
397          WHERE bukrs EQ gt_index-bukrs
398            AND saknr EQ gt_index-recon.
399        IF sy-subrc EQ 0.
400          gt_index-xhres = ls_xhres.
401        ENDIF.
402        APPEND gt_index.
403        CLEAR gt_key.
404        MOVE-CORRESPONDING ls_bsad TO gt_key.
405        IF ls_bsad-xarch EQ 'X'.
406          gt_key-cnt_arch = 1.
407        ENDIF.
408        COLLECT gt_key.
409      ENDSELECT.
410    ENDFORM.                    " SELECT_CLEARING_BSAD
411
412    *&---------------------------------------------------------------------*
413    *&      Form  SELECT_CLEARING_BSAK
414    *&---------------------------------------------------------------------*
415    FORM select_clearing_bsak .
416      DATA: ls_bsak TYPE bsak.
417      DATA: ls_netb TYPE bkpf-xnetb.
418      DATA: ls_xhres TYPE skb1-xkres.
419
420      SELECT * FROM bsak INTO ls_bsak
421        WHERE bukrs EQ p_bukrs
422          AND lifnr IN s_konto
423          AND augbl IN s_augbl
424          AND augdt IN s_augdt.
425        CLEAR gt_index.
426        MOVE-CORRESPONDING ls_bsak TO gt_index.
427        gt_index-koart = 'K'.
428        gt_index-konto = ls_bsak-lifnr.
429    *** check recon account
430        gt_index-recon = ls_bsak-hkont.
431        SELECT SINGLE xkres FROM skb1 INTO ls_xhres
432          WHERE bukrs EQ gt_index-bukrs
433            AND saknr EQ gt_index-recon.
434        IF sy-subrc EQ 0.
435          gt_index-xhres = ls_xhres.
436        ENDIF.
437        APPEND gt_index.
438        CLEAR gt_key.
439        MOVE-CORRESPONDING ls_bsak TO gt_key.
440    *** special case: XNETB
441        IF ( ls_bsak-xnetb EQ 'X' OR
442             ls_bsak-xzahl EQ 'X' ).
443          CLEAR ls_netb.
444          PERFORM select_bsas_skv USING ls_bsak
445                                        ls_netb.
446    *** evaluate marker
447          IF ls_netb EQ 'X'.
448            gt_key-cnt_netb = 1.
449          ENDIF.
450        ENDIF.
451        IF ls_bsak-xarch EQ 'X'.
452          gt_key-cnt_arch = 1.
453        ENDIF.
454        COLLECT gt_key.
455      ENDSELECT.
456    ENDFORM.                    " SELECT_CLEARING_BSAK
457
458    *&---------------------------------------------------------------------*
459    *&      Form  SELECT_CLEARING_BSAS
460    *&---------------------------------------------------------------------*
461    FORM select_clearing_bsas .
462      DATA: ls_bsas TYPE bsas.
463
464      SELECT * FROM bsas INTO ls_bsas
465        WHERE bukrs EQ p_bukrs
466          AND hkont IN s_konto
467          AND augbl IN s_augbl
468          AND augdt IN s_augdt.
469        CLEAR gt_index.
470        MOVE-CORRESPONDING ls_bsas TO gt_index.
471        gt_index-koart = 'S'.
472        gt_index-konto = ls_bsas-hkont.
473        APPEND gt_index.
474        CLEAR gt_key.
475        MOVE-CORRESPONDING ls_bsas TO gt_key.
476        IF ls_bsas-xarch EQ 'X'.
477          gt_key-cnt_arch = 1.
478        ENDIF.
479        COLLECT gt_key.
480      ENDSELECT.
481    ENDFORM.                    " SELECT_CLEARING_BSAS
482
483    *&---------------------------------------------------------------------*
484    *&      Form  SELECT_BSAS_SKV
485    *&---------------------------------------------------------------------*
486    FORM select_bsas_skv  USING ls_bsak TYPE bsak
487                                ls_netb TYPE bkpf-xnetb.
488      DATA: ls_bseg TYPE bseg.
489      DATA: ls_bsas TYPE bsas.
490      DATA: lt_t030 TYPE TABLE OF t030 WITH HEADER LINE.
491
492      IF ls_bsak-xarch EQ space.
493        SELECT * FROM bseg INTO ls_bseg
494          WHERE bukrs EQ ls_bsak-bukrs
495            AND belnr EQ ls_bsak-belnr
496            AND gjahr EQ ls_bsak-gjahr
497            AND augdt EQ ls_bsak-augdt
498            AND augbl EQ ls_bsak-augbl
499            AND ktosl EQ 'SKV' ORDER BY PRIMARY KEY.
500          CHECK sy-subrc EQ 0.
501          SELECT SINGLE * FROM bsas INTO ls_bsas
502            WHERE bukrs EQ ls_bseg-bukrs
503              AND hkont EQ ls_bseg-hkont
504              AND augdt EQ ls_bseg-augdt
505              AND augbl EQ ls_bseg-augbl
506              AND gjahr EQ ls_bseg-gjahr
507              AND belnr EQ ls_bseg-belnr
508              AND buzei EQ ls_bseg-buzei.  "#EC CI_NOORDER
509          CLEAR gt_index.
510          MOVE-CORRESPONDING ls_bsas TO gt_index.
511          gt_index-koart = 'S'.
512          gt_index-konto = ls_bsas-hkont.
513          APPEND gt_index.
514    *** set flag for XNETB
515          ls_netb = 'X'.
516    *** info message
517          CLEAR gt_mess.
518          MOVE-CORRESPONDING gt_index TO gt_mess.
519          gt_mess-type = 3.
520          gt_mess-class = 'CASH DISC'.
521          CONCATENATE 'Cash discount clearing'
522                      'item, automatically selected'
523          INTO gt_mess-msg SEPARATED BY space.
524          APPEND gt_mess.
525        ENDSELECT.
526    *** archived cases
527      ELSE.
528        REFRESH lt_t030.
529        SELECT * FROM t030 INTO TABLE lt_t030
530          WHERE ktopl EQ t001-ktopl
531            AND ktosl EQ 'SKV'.  "#EC CI_NOORDER
532        LOOP AT lt_t030.
533          SELECT * FROM bsas INTO ls_bsas
534            WHERE bukrs EQ p_bukrs
535              AND hkont EQ lt_t030-konts
536              AND augbl EQ ls_bsak-augdt
537              AND augdt EQ ls_bsak-augbl.
538            CLEAR gt_index.
539            MOVE-CORRESPONDING ls_bsas TO gt_index.
540            gt_index-koart = 'S'.
541            gt_index-konto = ls_bsas-hkont.
542            APPEND gt_index.
543    *** set flag for XNETB
544            ls_netb = 'X'.
545    *** info message
546            CLEAR gt_mess.
547            MOVE-CORRESPONDING gt_index TO gt_mess.
548            gt_mess-type = 3.
549            gt_mess-class = 'CASH DISC'.
550            CONCATENATE 'Cash discount clearing'
551                        'item, automatically selected'
552            INTO gt_mess-msg SEPARATED BY space.
553            APPEND gt_mess.
554          ENDSELECT.
555        ENDLOOP.
556      ENDIF.
557    ENDFORM.                    " SELECT_BSAS_SKV
558
559    *&---------------------------------------------------------------------*
560    *&      Form  PROCESS_CLEARINGS
561    *&---------------------------------------------------------------------*
562    FORM process_clearings .
563    *** old: YBSEGR, new: XBSEGR
564      DATA: new_bseg TYPE bseg.
565      DATA: old_bseg TYPE bseg.
566      DATA: x_rb(1) TYPE c.
567    *************************************************************UD281016
568    *** XLGCLR cases                                            "UD281016
569      DATA: x_lg TYPE c.                                        "UD281016
570      DATA: table TYPE dd02l-tabname.                           "UD281016
571      DATA: l_bstat TYPE c.                                     "UD281016
572    *************************************************************UD281016
573
574      count_clr = LINES( gt_key ).
575      CHECK count_clr GT 0.
576    *** processing per key
577      LOOP AT gt_key.
578        CLEAR: x_rb.
579        LOOP AT gt_index
580          WHERE augdt EQ gt_key-augdt
581            AND augbl EQ gt_key-augbl
582            AND auggj EQ gt_key-auggj.
583    *************************************************************UD281016
584    *** set parameters for update with XLGCLR                   "UD281016
585          x_lg = gt_index-xlgclr.                               "UD281016
586          l_bstat = gt_index-bstat.                             "UD281016
587    *** set BSTAT and table name                                "UD281016
588          IF gt_index-bstat EQ 'L'.                             "UD281016
589            table = 'BSEG_ADD'.                                 "UD281016
590          ELSE.                                                 "UD281016
591            table = 'BSEG'.                                     "UD281016
592          ENDIF.                                                "UD281016
593    *************************************************************UD281016
594    *** if IGN_ARCH is set: ignore archived items
595          IF ign_arch EQ 'X'.
596            IF gt_index-xarch EQ 'X'.
597    *** message handling
598              CLEAR gt_mess.
599              MOVE-CORRESPONDING gt_index TO gt_mess.
600              gt_mess-type = 2.
601              gt_mess-class = 'UPDATE'.
602              gt_mess-msg = 'Archived item: no update'.
603              APPEND gt_mess.
604            ENDIF.
605            CHECK NOT gt_index-xarch EQ 'X'.
606          ENDIF.
607    *** select corresponding BSEG
608          CLEAR: new_bseg, old_bseg.
609    *      SELECT SINGLE * FROM bseg INTO old_bseg              "UD281016
610          SELECT SINGLE * FROM (table)                          "UD281016
611          INTO CORRESPONDING FIELDS OF old_bseg                 "UD281016
612            WHERE bukrs EQ gt_index-bukrs
613              AND belnr EQ gt_index-belnr
614              AND gjahr EQ gt_index-gjahr
615              AND buzei EQ gt_index-buzei.  "#EC CI_FLDEXT_OK[2610650]
616    *** BSEG found                                              "UD190111
617          IF sy-subrc EQ 0.                                     "UD190111
618    *** BSEG does contain other clearing information            "UD190111
619            IF NOT ( old_bseg-augdt EQ gt_index-augdt AND       "UD190111
620                     old_bseg-augbl EQ gt_index-augbl ).        "UD190111
621    *** message handling
622              CLEAR gt_mess.
623              MOVE-CORRESPONDING gt_index TO gt_mess.
624              gt_mess-type = 2.
625              gt_mess-class = 'UPDATE'.
626    *          gt_mess-msg = 'BSEG contains other clearing information'.
627              CONCATENATE                                       "UD281016
628                table 'contains other clearing information'     "UD281016
629              INTO gt_mess-msg SEPARATED BY space.              "UD281016
630              APPEND gt_mess.
631    *** delete duplicate index
632    *          PERFORM delete_index USING x_rb.                 "UD281016
633              PERFORM delete_index USING x_rb                   "UD281016
634                                         x_lg.                  "UD281016
635            ELSE.                                               "UD190111
636    *** create new BSEG
637              new_bseg = old_bseg.
638              CLEAR: new_bseg-augdt, new_bseg-augcp, new_bseg-augbl,
639                     new_bseg-auggj, new_bseg-agzei.
640    *** update BSEG
641              IF update EQ 'X'.
642                PERFORM update_bseg USING new_bseg
643                                          old_bseg
644    *                                      x_rb.                "UD281016
645                                          x_rb                  "UD281016
646                                          table                 "UD281016
647                                          x_lg.                 "UD281016
648              ENDIF.
649            ENDIF.                                              "UD190111
650    *** no BSEG found => delete index                           "UD190111
651          ELSE.                                                 "UD190111
652    *** message handling
653            CLEAR gt_mess.
654            MOVE-CORRESPONDING gt_index TO gt_mess.
655            gt_mess-type = 2.
656            gt_mess-class = 'UPDATE'.
657    *        gt_mess-msg = 'BSEG not found'.                    "UD281016
658            CONCATENATE                                         "UD281016
659              table 'not found'                                 "UD281016
660            INTO gt_mess-msg SEPARATED BY space.                "UD281016
661            APPEND gt_mess.
662    *** delete duplicate index
663    *        PERFORM delete_index USING x_rb.                   "UD281016
664            PERFORM delete_index USING x_rb                     "UD281016
665                                       x_lg.                    "UD281016
666          ENDIF.                                                "UD190111
667        ENDLOOP.
668    *** reset reversal: update header accordingly               "UD280411
669        IF gt_key-reverse GT 0.                                 "UD280411
670          PERFORM update_bkpf_reversal USING x_rb.              "UD280411
671        ENDIF.                                                  "UD280411
672        IF update EQ 'X'.
673    *** check BKPF-BSTAT update
674          IF gt_key-cl_bstat GT 0.
675            PERFORM update_bkpf USING x_rb.
676          ENDIF.
677    *** one commit work per key
678          IF x_rb EQ 'X'.
679            ROLLBACK WORK.
680    *** exclude KEY
681            INSERT gt_key INTO TABLE gt_key_excl.
682            DELETE gt_key.
683    *** message handling
684            CLEAR gt_mess.
685            MOVE-CORRESPONDING gt_key TO gt_mess.
686            gt_mess-belnr = gt_key-augbl.
687            gt_mess-gjahr = gt_key-auggj.
688            gt_mess-type = 1.
689            gt_mess-class = 'EXCLUDED'.
690            CONCATENATE 'ROLLBACK WORK performed for entire'
691                        'clearing because of update errors'
692            INTO gt_mess-msg SEPARATED BY space.
693            APPEND gt_mess.
694          ELSE.
695            COMMIT WORK.
696    *** message handling
697            CLEAR gt_mess.
698            MOVE-CORRESPONDING gt_key TO gt_mess.
699            gt_mess-belnr = gt_key-augbl.
700            gt_mess-gjahr = gt_key-auggj.
701            gt_mess-type = 3.
702            gt_mess-class = 'CLEARING'.
703            gt_mess-msg = 'COMMIT WORK performed'.
704            APPEND gt_mess.
705          ENDIF.
706        ENDIF.
707      ENDLOOP.
708    ENDFORM.                    " PROCESS_CLEARINGS
709
710    *&---------------------------------------------------------------------*
711    *&      Form  SCREEN
712    *&---------------------------------------------------------------------*
713    FORM screen .
714
715      IF sy-batch IS INITIAL.
716        CLEAR update.
717      ENDIF.
718      LOOP AT SCREEN.
719        IF screen-group1 = 'INC'.
720          IF expert = 'X'.
721            screen-invisible = 0.
722            screen-active = 1.
723          ELSE.
724            screen-invisible = 1.
725            screen-active = 0.
726          ENDIF.
727          MODIFY SCREEN.
728        ENDIF.
729        IF screen-group1 = 'ARC'.
730          IF exp_arc = 'X'.
731            screen-invisible = 0.
732            screen-active = 1.
733          ELSE.
734            screen-invisible = 1.
735            screen-active = 0.
736          ENDIF.
737          MODIFY SCREEN.
738        ENDIF.
739      ENDLOOP.
740    ENDFORM.                    " SCREEN
741
742    *&---------------------------------------------------------------------*
743    *&      Form  REVISE_KEY_ARCH
744    *&---------------------------------------------------------------------*
745    FORM revise_key_arch .
746
747    *** if flag is not set then clearings containing archived items are
748    *** excluded from processing
749      CHECK ign_arch EQ space.
750      LOOP AT gt_key
751        WHERE cnt_arch GT 0.
752    *** message handling
753        CLEAR gt_mess.
754        MOVE-CORRESPONDING gt_key TO gt_mess.
755        gt_mess-belnr = gt_key-augbl.
756        gt_mess-gjahr = gt_key-auggj.
757        gt_mess-type = 1.
758        gt_mess-class = 'EXCLUDED'.
759        gt_mess-msg = 'Clearing contains archived items'.
760        APPEND gt_mess.
761        INSERT gt_key INTO TABLE gt_key_excl.
762        DELETE gt_key.
763      ENDLOOP.
764    ENDFORM.                    " REVISE_KEY_ARCH
765
766    *&---------------------------------------------------------------------*
767    *&      Form  UPDATE_BSEG
768    *----------------------------------------------------------------------*
769    FORM update_bseg  USING    new_bseg TYPE bseg
770                               old_bseg TYPE bseg
771    *                           x_rb     TYPE c   .             "UD281016
772                               x_rb     TYPE c                  "UD281016
773                               tab      TYPE dd02l-tabname      "UD281016
774                               x_lg     TYPE c.                 "UD281016
775
776    *** write BSEG changes to DB
777    *  UPDATE bseg                                              "UD281016
778      UPDATE (tab)                                              "UD281016
779      SET   augdt = new_bseg-augdt
780            augcp = new_bseg-augcp
781            augbl = new_bseg-augbl
782            auggj = new_bseg-auggj
783            agzei = new_bseg-agzei
784      WHERE bukrs = new_bseg-bukrs
785      AND   belnr = new_bseg-belnr
786      AND   gjahr = new_bseg-gjahr
787      AND   buzei = new_bseg-buzei.
788      IF sy-subrc NE 0.
789    *** message handling
790        CLEAR gt_mess.
791        MOVE-CORRESPONDING new_bseg TO gt_mess.
792        gt_mess-type = 1.
793        gt_mess-class = 'UPDATE'.
794    *    gt_mess-msg = 'BSEG update failed'.                    "UD281016
795        CONCATENATE                                             "UD281016
796          tab 'update failed'                                   "UD281016
797        INTO gt_mess-msg SEPARATED BY space.                    "UD281016
798        APPEND gt_mess.
799    *** rollback indicator
800        x_rb = 'X'.
801      ELSE.
802    *** message handling
803        CLEAR gt_mess.
804        MOVE-CORRESPONDING new_bseg TO gt_mess.
805        gt_mess-type = 3.
806        gt_mess-class = 'UPDATE'.
807    *    gt_mess-msg = 'BSEG updated'.                          "UD281016
808        CONCATENATE                                             "UD281016
809          tab 'updated'                                         "UD281016
810        INTO gt_mess-msg SEPARATED BY space.                    "UD281016
811        APPEND gt_mess.
812    *** adjust indexes accordingly
813        PERFORM update_index USING new_bseg
814                                   old_bseg
815    *                               x_rb .                      "UD281016
816                                   x_rb                         "UD281016
817                                   x_lg.                        "UD281016
818        PERFORM write_cd USING new_bseg
819                               old_bseg
820                               x_rb .
821      ENDIF.
822    ENDFORM.                    " UPDATE_BSEG
823
824    *&---------------------------------------------------------------------*
825    *&      Form  UPDATE_INDEX
826    *&---------------------------------------------------------------------*
827    FORM update_index  USING    new_bseg TYPE bseg
828                                old_bseg TYPE bseg
829    *                            x_rb     TYPE c.               "UD281016
830                                x_rb     TYPE c                 "UD281016
831                                x_lg     TYPE c.                "UD281016
832      DATA: ls_bkpf TYPE bkpf.
833      DATA: ls_bsid TYPE bsid.
834      DATA: ls_bsik TYPE bsik.
835      DATA: ls_bsis TYPE bsis.
836      DATA: tab TYPE dd02l-tabname.                             "UD281016
837      FIELD-SYMBOLS: <ls_faglbsis> TYPE ANY.                    "UD281016
838      FIELD-SYMBOLS: <augdt> TYPE ANY.                          "UD281016
839      FIELD-SYMBOLS: <augbl> TYPE ANY.                          "UD281016
840      FIELD-SYMBOLS: <auggj> TYPE ANY.                          "UD281016
841      DATA: ls_faglbsis TYPE REF TO data.                       "UD281016
842
843      IF x_lg EQ space.                                         "UD281016
844    *** 1.: delete old cleared index
845        CASE old_bseg-koart.
846          WHEN 'D'.
847    *** delete BSAD
848    "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
849
850    *        DELETE FROM bsad
851    *          WHERE bukrs EQ old_bseg-bukrs
852    *            AND kunnr EQ old_bseg-kunnr
853    *            AND augdt EQ old_bseg-augdt
854    *            AND augbl EQ old_bseg-augbl
855    *            AND gjahr EQ old_bseg-gjahr
856    *            AND belnr EQ old_bseg-belnr
857    *            AND buzei EQ old_bseg-buzei.
858    "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
859            IF sy-subrc NE 0.
860    *** message handling
861              CLEAR gt_mess.
862              MOVE-CORRESPONDING old_bseg TO gt_mess.
863              gt_mess-type = 1.
864              gt_mess-class = 'UPDATE'.
865              gt_mess-msg = 'BSAD deletion failed'.
866              APPEND gt_mess.
867              x_rb = 'X'.
868            ELSE.
869              CLEAR gt_mess.
870              MOVE-CORRESPONDING old_bseg TO gt_mess.
871              gt_mess-type = 3.
872              gt_mess-class = 'UPDATE'.
873              gt_mess-msg = 'BSAD deleted'.
874              APPEND gt_mess.
875            ENDIF.
876    *** delete recon account BSAS
877            IF old_bseg-xhres EQ 'X'.
878    "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
879    *          DELETE FROM bsas
880    *            WHERE bukrs EQ old_bseg-bukrs
881    *              AND hkont EQ old_bseg-hkont
882    *              AND augdt EQ old_bseg-augdt
883    *              AND augbl EQ old_bseg-augbl
884    *              AND gjahr EQ old_bseg-gjahr
885    *              AND belnr EQ old_bseg-belnr
886    *              AND buzei EQ old_bseg-buzei.
887    "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
888              IF sy-subrc NE 0.
889    *** message handling
890                CLEAR gt_mess.
891                MOVE-CORRESPONDING old_bseg TO gt_mess.
892                gt_mess-type = 1.
893                gt_mess-class = 'UPDATE'.
894                gt_mess-msg = 'BSAS (recon acct) deletion failed'.
895                APPEND gt_mess.
896                x_rb = 'X'.
897              ELSE.
898                CLEAR gt_mess.
899                MOVE-CORRESPONDING old_bseg TO gt_mess.
900                gt_mess-type = 3.
901                gt_mess-class = 'UPDATE'.
902                gt_mess-msg = 'BSAS (recon acct) deleted'.
903                APPEND gt_mess.
904              ENDIF.
905            ENDIF.
906          WHEN 'K'.
907    *** delete BSAK
908    "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
909    *        DELETE FROM bsak
910    *          WHERE bukrs EQ old_bseg-bukrs
911    *            AND lifnr EQ old_bseg-lifnr
912    *            AND augdt EQ old_bseg-augdt
913    *            AND augbl EQ old_bseg-augbl
914    *            AND gjahr EQ old_bseg-gjahr
915    *            AND belnr EQ old_bseg-belnr
916    *            AND buzei EQ old_bseg-buzei.
917    "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
918            IF sy-subrc NE 0.
919    *** message handling
920              CLEAR gt_mess.
921              MOVE-CORRESPONDING old_bseg TO gt_mess.
922              gt_mess-type = 1.
923              gt_mess-class = 'UPDATE'.
924              gt_mess-msg = 'BSAK deletion failed'.
925              APPEND gt_mess.
926              x_rb = 'X'.
927            ELSE.
928              CLEAR gt_mess.
929              MOVE-CORRESPONDING old_bseg TO gt_mess.
930              gt_mess-type = 3.
931              gt_mess-class = 'UPDATE'.
932              gt_mess-msg = 'BSAK deleted'.
933              APPEND gt_mess.
934            ENDIF.
935    *** delete recon account BSAS
936            IF old_bseg-xhres EQ 'X'.
937    "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
938
939    *          DELETE FROM bsas
940    *            WHERE bukrs EQ old_bseg-bukrs
941    *              AND hkont EQ old_bseg-hkont
942    *              AND augdt EQ old_bseg-augdt
943    *              AND augbl EQ old_bseg-augbl
944    *              AND gjahr EQ old_bseg-gjahr
945    *              AND belnr EQ old_bseg-belnr
946    *              AND buzei EQ old_bseg-buzei.
947    "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
948              IF sy-subrc NE 0.
949    *** message handling
950                CLEAR gt_mess.
951                MOVE-CORRESPONDING old_bseg TO gt_mess.
952                gt_mess-type = 1.
953                gt_mess-class = 'UPDATE'.
954                gt_mess-msg = 'BSAS (recon acct) deletion failed'.
955                APPEND gt_mess.
956                x_rb = 'X'.
957              ELSE.
958                CLEAR gt_mess.
959                MOVE-CORRESPONDING old_bseg TO gt_mess.
960                gt_mess-type = 3.
961                gt_mess-class = 'UPDATE'.
962                gt_mess-msg = 'BSAS (recon acct) deleted'.
963                APPEND gt_mess.
964              ENDIF.
965            ENDIF.
966          WHEN 'S'.
967    *** delete BSAS
968    "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
969
970    *        DELETE FROM bsas
971    *          WHERE bukrs EQ old_bseg-bukrs
972    *            AND hkont EQ old_bseg-hkont
973    *            AND augdt EQ old_bseg-augdt
974    *            AND augbl EQ old_bseg-augbl
975    *            AND gjahr EQ old_bseg-gjahr
976    *            AND belnr EQ old_bseg-belnr
977    *            AND buzei EQ old_bseg-buzei.
978    "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
979            IF sy-subrc NE 0.
980    *** message handling
981              CLEAR gt_mess.
982              MOVE-CORRESPONDING old_bseg TO gt_mess.
983              gt_mess-type = 1.
984              gt_mess-class = 'UPDATE'.
985              gt_mess-msg = 'BSAS deletion failed'.
986              APPEND gt_mess.
987              x_rb = 'X'.
988            ELSE.
989              CLEAR gt_mess.
990              MOVE-CORRESPONDING old_bseg TO gt_mess.
991              gt_mess-type = 3.
992              gt_mess-class = 'UPDATE'.
993              gt_mess-msg = 'BSAS deleted'.
994              APPEND gt_mess.
995            ENDIF.
996        ENDCASE.
997    *** 2.: build open item index
998        SELECT SINGLE * FROM bkpf INTO ls_bkpf
999          WHERE bukrs EQ new_bseg-bukrs
1000           AND belnr EQ new_bseg-belnr
1001           AND gjahr EQ new_bseg-gjahr.
1002       CASE new_bseg-koart.
1003         WHEN 'D'.
1004   *** insert BSID
1005           CLEAR ls_bsid.
1006           MOVE-CORRESPONDING ls_bkpf TO ls_bsid.
1007           MOVE-CORRESPONDING new_bseg TO ls_bsid.
1008   *        INSERT bsid FROM ls_bsid.
1009           IF sy-subrc NE 0.
1010   *** message handling
1011             CLEAR gt_mess.
1012             MOVE-CORRESPONDING new_bseg TO gt_mess.
1013             gt_mess-type = 1.
1014             gt_mess-class = 'UPDATE'.
1015             gt_mess-msg = 'BSID insertion failed'.
1016             APPEND gt_mess.
1017             x_rb = 'X'.
1018           ELSE.
1019             CLEAR gt_mess.
1020             MOVE-CORRESPONDING new_bseg TO gt_mess.
1021             gt_mess-type = 3.
1022             gt_mess-class = 'UPDATE'.
1023             gt_mess-msg = 'BSID inserted'.
1024             APPEND gt_mess.
1025           ENDIF.
1026   ***  insert recon account BSIS
1027           IF new_bseg-xhres EQ 'X'.
1028             CLEAR ls_bsis.
1029             MOVE-CORRESPONDING ls_bkpf TO ls_bsis.
1030             MOVE-CORRESPONDING new_bseg TO ls_bsis.
1031             ls_bsis-zuonr = new_bseg-hzuon.
1032             ls_bsis-fkber = new_bseg-fkber_long.
1033   *** recon account: no XOPVW
1034             CLEAR ls_bsis-xopvw.
1035   *          INSERT bsis FROM ls_bsis.
1036             IF sy-subrc NE 0.
1037   *** message handling
1038               CLEAR gt_mess.
1039               MOVE-CORRESPONDING new_bseg TO gt_mess.
1040               gt_mess-type = 1.
1041               gt_mess-class = 'UPDATE'.
1042               gt_mess-msg = 'BSIS (recon acct) insertion failed'.
1043               APPEND gt_mess.
1044               x_rb = 'X'.
1045             ELSE.
1046               CLEAR gt_mess.
1047               MOVE-CORRESPONDING new_bseg TO gt_mess.
1048               gt_mess-type = 3.
1049               gt_mess-class = 'UPDATE'.
1050               gt_mess-msg = 'BSIS (recon acct) inserted'.
1051               APPEND gt_mess.
1052             ENDIF.
1053           ENDIF.
1054         WHEN 'K'.
1055   *** insert BSIK
1056           CLEAR ls_bsik.
1057           MOVE-CORRESPONDING ls_bkpf TO ls_bsik.
1058           MOVE-CORRESPONDING new_bseg TO ls_bsik.
1059   *        INSERT bsik FROM ls_bsik.
1060           IF sy-subrc NE 0.
1061   *** message handling
1062             CLEAR gt_mess.
1063             MOVE-CORRESPONDING new_bseg TO gt_mess.
1064             gt_mess-type = 1.
1065             gt_mess-class = 'UPDATE'.
1066             gt_mess-msg = 'BSIK insertion failed'.
1067             APPEND gt_mess.
1068             x_rb = 'X'.
1069           ELSE.
1070             CLEAR gt_mess.
1071             MOVE-CORRESPONDING new_bseg TO gt_mess.
1072             gt_mess-type = 3.
1073             gt_mess-class = 'UPDATE'.
1074             gt_mess-msg = 'BSIK inserted'.
1075             APPEND gt_mess.
1076           ENDIF.
1077   ***  insert recon account BSIS
1078           IF new_bseg-xhres EQ 'X'.
1079             CLEAR ls_bsis.
1080             MOVE-CORRESPONDING ls_bkpf TO ls_bsis.
1081             MOVE-CORRESPONDING new_bseg TO ls_bsis.
1082             ls_bsis-zuonr = new_bseg-hzuon.
1083             ls_bsis-fkber = new_bseg-fkber_long.
1084   *** recon account: no XOPVW
1085             CLEAR ls_bsis-xopvw.
1086   *          INSERT bsis FROM ls_bsis.
1087             IF sy-subrc NE 0.
1088   *** message handling
1089               CLEAR gt_mess.
1090               MOVE-CORRESPONDING new_bseg TO gt_mess.
1091               gt_mess-type = 1.
1092               gt_mess-class = 'UPDATE'.
1093               gt_mess-msg = 'BSIS (recon acct) insertion failed'.
1094               APPEND gt_mess.
1095               x_rb = 'X'.
1096             ELSE.
1097               CLEAR gt_mess.
1098               MOVE-CORRESPONDING new_bseg TO gt_mess.
1099               gt_mess-type = 3.
1100               gt_mess-class = 'UPDATE'.
1101               gt_mess-msg = 'BSIS (recon acct) inserted'.
1102               APPEND gt_mess.
1103             ENDIF.
1104           ENDIF.
1105         WHEN 'S'.
1106   ***  insert BSIS
1107           CLEAR ls_bsis.
1108           MOVE-CORRESPONDING ls_bkpf TO ls_bsis.
1109           MOVE-CORRESPONDING new_bseg TO ls_bsis.
1110   *        INSERT bsis FROM ls_bsis.
1111           IF sy-subrc NE 0.
1112   *** message handling
1113             CLEAR gt_mess.
1114             MOVE-CORRESPONDING new_bseg TO gt_mess.
1115             gt_mess-type = 1.
1116             gt_mess-class = 'UPDATE'.
1117             gt_mess-msg = 'BSIS insertion failed'.
1118             APPEND gt_mess.
1119             x_rb = 'X'.
1120           ELSE.
1121             CLEAR gt_mess.
1122             MOVE-CORRESPONDING new_bseg TO gt_mess.
1123             gt_mess-type = 3.
1124             gt_mess-class = 'UPDATE'.
1125             gt_mess-msg = 'BSIS inserted'.
1126             APPEND gt_mess.
1127           ENDIF.
1128       ENDCASE.
1129   *** FAGLBSAS/FAGLBSIS handling                              "UD281016
1130     ELSE.                                                     "UD281016
1131   *** select existing FAGLBSAS and delete                     "UD281016
1132       tab = 'FAGLBSAS'.                                       "UD281016
1133   *** create generic work area                                "UD281016
1134       CREATE DATA ls_faglbsis TYPE (tab).                     "UD281016
1135       ASSIGN ls_faglbsis->* TO <ls_faglbsis>.                 "UD281016
1136       SELECT SINGLE * FROM (tab) INTO <ls_faglbsis>           "UD281016
1137         WHERE bukrs EQ old_bseg-bukrs                         "UD281016
1138           AND hkont EQ old_bseg-hkont                         "UD281016
1139           AND augdt EQ old_bseg-augdt                         "UD281016
1140           AND augbl EQ old_bseg-augbl                         "UD281016
1141           AND gjahr EQ old_bseg-gjahr                         "UD281016
1142           AND belnr EQ old_bseg-belnr                         "UD281016
1143           AND buzei EQ old_bseg-buzei.                        "UD281016
1144       DELETE (tab) FROM <ls_faglbsis>.                        "UD281016
1145       IF sy-subrc NE 0.                                       "UD281016
1146   *** message handling                                        "UD281016
1147         CLEAR gt_mess.                                        "UD281016
1148         MOVE-CORRESPONDING old_bseg TO gt_mess.               "UD281016
1149         gt_mess-type = 1.                                     "UD281016
1150         gt_mess-class = 'UPDATE'.                             "UD281016
1151         gt_mess-msg = 'FAGLBSAS deletion failed'.             "UD281016
1152         APPEND gt_mess.                                       "UD281016
1153         x_rb = 'X'.                                           "UD281016
1154       ELSE.                                                   "UD281016
1155         CLEAR gt_mess.                                        "UD281016
1156         MOVE-CORRESPONDING old_bseg TO gt_mess.               "UD281016
1157         gt_mess-type = 3.                                     "UD281016
1158         gt_mess-class = 'UPDATE'.                             "UD281016
1159         gt_mess-msg = 'FAGLBSAS deleted'.                     "UD281016
1160         APPEND gt_mess.                                       "UD281016
1161       ENDIF.                                                  "UD281016
1162   *** create FAGLBSIS and insert                              "UD281016
1163       tab = 'FAGLBSIS'.                                       "UD281016
1164       ASSIGN COMPONENT 'AUGDT'                                "UD281016
1165         OF STRUCTURE <ls_faglbsis> TO <augdt>.                "UD281016
1166       CLEAR <augdt>.                                          "UD281016
1167       ASSIGN COMPONENT 'AUGBL'                                "UD281016
1168         OF STRUCTURE <ls_faglbsis> TO <augbl>.                "UD281016
1169       CLEAR <augbl>.                                          "UD281016
1170       ASSIGN COMPONENT 'AUGGJ'                                "UD281016
1171         OF STRUCTURE <ls_faglbsis> TO <auggj>.                "UD281016
1172       CLEAR <auggj>.                                          "UD281016
1173       INSERT (tab) FROM <ls_faglbsis>.                        "UD281016
1174       IF sy-subrc NE 0.                                       "UD281016
1175   *** message handling                                        "UD281016
1176         CLEAR gt_mess.                                        "UD281016
1177         MOVE-CORRESPONDING new_bseg TO gt_mess.               "UD281016
1178         gt_mess-type = 1.                                     "UD281016
1179         gt_mess-class = 'UPDATE'.                             "UD281016
1180         gt_mess-msg = 'FAGLBSIS insertion failed'.            "UD281016
1181         APPEND gt_mess.                                       "UD281016
1182         x_rb = 'X'.                                           "UD281016
1183       ELSE.                                                   "UD281016
1184         CLEAR gt_mess.                                        "UD281016
1185         MOVE-CORRESPONDING new_bseg TO gt_mess.               "UD281016
1186         gt_mess-type = 3.                                     "UD281016
1187         gt_mess-class = 'UPDATE'.                             "UD281016
1188         gt_mess-msg = 'FAGLBSIS inserted'.                    "UD281016
1189         APPEND gt_mess.                                       "UD281016
1190       ENDIF.                                                  "UD281016
1191     ENDIF.                                                    "UD281016
1192   ENDFORM.                    " UPDATE_INDEX
1193
1194   *&---------------------------------------------------------------------*
1195   *&      Form  WRITE_CD
1196   *&---------------------------------------------------------------------*
1197   FORM write_cd  USING    new_bseg TYPE bseg
1198                           old_bseg TYPE bseg
1199                           x_rb     TYPE c .
1200
1201   *** move data:
1202     REFRESH : gt_xbsegr, gt_ybsegr.
1203     CLEAR : gt_xbsegr, gt_ybsegr.
1204   *** ... old data
1205     MOVE-CORRESPONDING old_bseg TO gt_ybsegr.
1206     APPEND gt_ybsegr.
1207   *** ... new data
1208     MOVE-CORRESPONDING new_bseg TO gt_xbsegr.
1209     APPEND gt_xbsegr.
1210   *** build administrational data for FM
1211     upd_bsegr = 'U'.
1212     tcode     = sy-tcode.
1213     utime     = sy-uzeit.
1214     udate     = sy-datum.
1215     username  = sy-uname.
1216     objectid  = gt_xbsegr(21).
1217   *** call FM for writing change document in local update task
1218     SET UPDATE TASK LOCAL.
1219     CALL FUNCTION 'BELEGR_WRITE_DOCUMENT         '
1220       EXPORTING
1221         objectid                = objectid
1222         tcode                   = tcode
1223         utime                   = utime
1224         udate                   = udate
1225         username                = username
1226         planned_change_number   = planned_change_number
1227         object_change_indicator = cdoc_upd_object
1228         planned_or_real_changes = cdoc_planned_or_real
1229         no_change_pointers      = cdoc_no_change_pointers
1230         upd_bsegr               = upd_bsegr
1231       TABLES
1232         xbsegr                  = gt_xbsegr
1233         ybsegr                  = gt_ybsegr.
1234   *** message handling
1235     CLEAR gt_mess.
1236     MOVE-CORRESPONDING new_bseg TO gt_mess.
1237     gt_mess-type = 3.
1238     gt_mess-class = 'UPDATE'.
1239     gt_mess-msg = 'Change document created'.
1240     APPEND gt_mess.
1241   ENDFORM.                    " WRITE_CD
1242
1243   *&---------------------------------------------------------------------*
1244   *&      Form  OUTPUT
1245   *&---------------------------------------------------------------------*
1246   FORM output .
1247     DATA: ls_index TYPE index.
1248     DATA: detail TYPE c.                                      "UD280411
1249
1250     count_clr = LINES( gt_key ).
1251     IF count_clr EQ 0.
1252       WRITE:/2 'No clearing selected that could be reset' COLOR 3.
1253     ENDIF.
1254     CHECK count_clr GT 0.
1255     NEW-PAGE.
1256     PERFORM header_corr.
1257     LOOP AT gt_key.
1258   *** output key data
1259       PERFORM header_key.
1260       PERFORM output_key USING gt_key.
1261   *** check messages for key
1262       LOOP AT gt_mess
1263         WHERE   bukrs EQ gt_key-bukrs
1264           AND   belnr EQ gt_key-augbl
1265           AND   gjahr EQ gt_key-auggj
1266           AND ( class EQ 'CLEARING'   OR
1267                 class EQ 'UPDATE'     OR
1268                 class EQ 'FOREX'      OR                      "UD050913
1269                 class EQ 'CROSS CC' ).
1270         EXIT.
1271       ENDLOOP.
1272       IF sy-subrc EQ 0.
1273         detail = 'K'.
1274         PERFORM header_mess.
1275         CLEAR ls_index.
1276         ls_index-bukrs = gt_key-bukrs.
1277         ls_index-belnr = gt_key-augbl.
1278         ls_index-gjahr = gt_key-auggj.
1279         PERFORM output_mess USING ls_index
1280                                   detail.                     "UD280411
1281       ENDIF.
1282   *** reset reversal case
1283       IF gt_key-reverse GT 0.                                 "UD280411
1284         READ TABLE gt_rev_key WITH KEY                        "UD280411
1285           bukrs   = gt_key-bukrs                              "UD280411
1286           belnr_2 = gt_key-augbl                              "UD280411
1287           gjahr_2 = gt_key-auggj.                             "UD280411
1288   *** output reversal header
1289         READ TABLE gt_bkpf_rev WITH KEY                       "UD280411
1290           bukrs = gt_rev_key-bukrs                            "UD280411
1291           belnr = gt_rev_key-belnr_2                          "UD280411
1292           gjahr = gt_rev_key-gjahr_2.                         "UD280411
1293         PERFORM bkpf_header.                                  "UD280411
1294         PERFORM output_bkpf USING gt_bkpf_rev.                "UD280411
1295   *** check for header messages for reversal doc
1296         LOOP AT gt_mess                                       "UD280411
1297           WHERE   bukrs EQ gt_rev_key-bukrs                   "UD280411
1298             AND   belnr EQ gt_rev_key-belnr_2                 "UD280411
1299             AND   gjahr EQ gt_rev_key-gjahr_2                 "UD280411
1300             AND ( class EQ 'BKPFUPDATE' OR                    "UD280411
1301                   class EQ 'BKPFREVERS' ).                    "UD280411
1302           EXIT.                                               "UD280411
1303         ENDLOOP.                                              "UD280411
1304         IF sy-subrc EQ 0.                                     "UD280411
1305           detail = 'H'.                                       "UD280411
1306           PERFORM header_mess.                                "UD280411
1307           CLEAR ls_index.                                     "UD280411
1308           ls_index-bukrs = gt_rev_key-bukrs.                  "UD280411
1309           ls_index-belnr = gt_rev_key-belnr_2.                "UD280411
1310           ls_index-gjahr = gt_rev_key-gjahr_2.                "UD280411
1311           PERFORM output_mess USING ls_index                  "UD280411
1312                                     detail.                   "UD280411
1313         ENDIF.                                                "UD280411
1314   *** output reversed header
1315         READ TABLE gt_bkpf_rev WITH KEY                       "UD280411
1316           bukrs = gt_rev_key-bukrs                            "UD280411
1317           belnr = gt_rev_key-belnr_1                          "UD280411
1318           gjahr = gt_rev_key-gjahr_1.                         "UD280411
1319         PERFORM bkpf_header.                                  "UD280411
1320         PERFORM output_bkpf USING gt_bkpf_rev.                "UD280411
1321   *** check for header messages for reversed doc
1322         LOOP AT gt_mess                                       "UD280411
1323           WHERE   bukrs EQ gt_rev_key-bukrs                   "UD280411
1324             AND   belnr EQ gt_rev_key-belnr_1                 "UD280411
1325             AND   gjahr EQ gt_rev_key-gjahr_1                 "UD280411
1326             AND ( class EQ 'BKPFUPDATE' OR                    "UD280411
1327                   class EQ 'BKPFREVERS' ).                    "UD280411
1328           EXIT.                                               "UD280411
1329         ENDLOOP.                                              "UD280411
1330         IF sy-subrc EQ 0.                                     "UD280411
1331           detail = 'H'.                                       "UD280411
1332           PERFORM header_mess.                                "UD280411
1333           CLEAR ls_index.                                     "UD280411
1334           ls_index-bukrs = gt_rev_key-bukrs.                  "UD280411
1335           ls_index-belnr = gt_rev_key-belnr_1.                "UD280411
1336           ls_index-gjahr = gt_rev_key-gjahr_1.                "UD280411
1337           PERFORM output_mess USING ls_index                  "UD280411
1338                                     detail.                   "UD280411
1339         ENDIF.                                                "UD280411
1340       ENDIF.                                                  "UD280411
1341   *** output items
1342       LOOP AT gt_index
1343         WHERE bukrs EQ gt_key-bukrs
1344           AND augdt EQ gt_key-augdt
1345           AND augbl EQ gt_key-augbl
1346           AND auggj EQ gt_key-auggj.
1347         PERFORM header_index.
1348         PERFORM output_index USING gt_index.
1349   *** check for messages
1350         READ TABLE gt_mess WITH KEY
1351           bukrs = gt_index-bukrs
1352           belnr = gt_index-belnr
1353           gjahr = gt_index-gjahr
1354           buzei = gt_index-buzei
1355         TRANSPORTING NO FIELDS.
1356         IF sy-subrc EQ 0.
1357           detail = 'I'.
1358           PERFORM header_mess.
1359           PERFORM output_mess USING gt_index
1360                                     detail.
1361         ENDIF.
1362       ENDLOOP.
1363       AT END OF augbl.
1364         NEW-LINE.
1365         ULINE (120).
1366       ENDAT.
1367     ENDLOOP.
1368   ENDFORM.                    " OUTPUT
1369
1370   *&---------------------------------------------------------------------*
1371   *&      Form  OUTPUT_EXCL
1372   *&---------------------------------------------------------------------*
1373   FORM output_excl .
1374     DATA: ls_index TYPE index.
1375     DATA: detail TYPE c.
1376
1377     cnt_excl = LINES( gt_key_excl ).
1378     CHECK cnt_excl GT 0.
1379     NEW-PAGE.
1380     PERFORM header_excl.
1381     LOOP AT gt_key_excl.
1382   *** output key data
1383       PERFORM header_key.
1384       PERFORM output_key USING gt_key_excl.
1385   *** check messages for key
1386       READ TABLE gt_mess WITH KEY
1387         bukrs = gt_key_excl-bukrs
1388         belnr = gt_key_excl-augbl
1389         gjahr = gt_key_excl-auggj
1390       TRANSPORTING NO FIELDS.
1391       IF sy-subrc EQ 0.
1392         detail = 'K'.
1393         PERFORM header_mess.
1394         CLEAR ls_index.
1395         ls_index-bukrs = gt_key_excl-bukrs.
1396         ls_index-belnr = gt_key_excl-augbl.
1397         ls_index-gjahr = gt_key_excl-auggj.
1398         PERFORM output_mess USING ls_index
1399                                   detail.
1400       ENDIF.
1401   *** output items
1402       LOOP AT gt_index
1403         WHERE bukrs EQ gt_key_excl-bukrs
1404           AND augdt EQ gt_key_excl-augdt
1405           AND augbl EQ gt_key_excl-augbl
1406           AND auggj EQ gt_key_excl-auggj.
1407         PERFORM header_index.
1408         PERFORM output_index USING gt_index.
1409   *** check for messages
1410         READ TABLE gt_mess WITH KEY
1411           bukrs = gt_index-bukrs
1412           belnr = gt_index-belnr
1413           gjahr = gt_index-gjahr
1414           buzei = gt_index-buzei
1415         TRANSPORTING NO FIELDS.
1416         IF sy-subrc EQ 0.
1417           detail = 'I'.
1418           PERFORM header_mess.
1419           PERFORM output_mess USING gt_index
1420                                     detail.
1421         ENDIF.
1422       ENDLOOP.
1423       AT END OF augbl.
1424         NEW-LINE.
1425         ULINE (120).
1426       ENDAT.
1427     ENDLOOP.
1428   ENDFORM.                    " OUTPUT_EXCL
1429
1430   *&---------------------------------------------------------------------*
1431   *&      Form  HEADER_EXCL
1432   *&---------------------------------------------------------------------*
1433   FORM header_excl .
1434
1435     FORMAT COLOR 6 INTENSIFIED ON.
1436     ULINE (120).
1437     WRITE:/ sy-vline NO-GAP,
1438             'Excluded clearings:',
1439         120 sy-vline NO-GAP.
1440     ULINE (120).
1441     FORMAT COLOR 3 INTENSIFIED OFF.
1442     WRITE:/ sy-vline NO-GAP,
1443             'Number of cases:',
1444             cnt_excl,
1445         120 sy-vline NO-GAP.
1446     NEW-LINE.
1447     ULINE (120).
1448     FORMAT COLOR OFF.
1449   ENDFORM.                    " HEADER_EXCL
1450
1451   *&---------------------------------------------------------------------*
1452   *&      Form  HEADER_INDEX
1453   *&---------------------------------------------------------------------*
1454   FORM header_index .
1455
1456     FORMAT COLOR 1 INTENSIFIED OFF.
1457     WRITE:/ sy-vline NO-GAP,
1458        (10) 'ITEM',
1459         (5) 'BUKRS',
1460        (10) 'AUGDT',
1461        (10) 'AUGBL',
1462         (5) 'AUGGJ',
1463        (10) 'BELNR',
1464         (5) 'GJAHR',
1465         (5) 'BUZEI',
1466         (5) 'XARCH',
1467         (5) 'KOART',
1468        (10) 'ACCOUNT',
1469         120 sy-vline NO-GAP.
1470   ENDFORM.                    " HEADER_INDEX
1471
1472   *&---------------------------------------------------------------------*
1473   *&      Form  OUTPUT_KEY
1474   *&---------------------------------------------------------------------*
1475   FORM output_key  USING   p_key TYPE key.
1476
1477     FORMAT COLOR 7 INTENSIFIED OFF.
1478     WRITE:/ sy-vline NO-GAP,
1479        (10) 'KEY',
1480         (5) p_key-bukrs,
1481        (10) p_key-augdt,
1482        (10) p_key-augbl,
1483         (5) p_key-auggj,
1484   *      (5) p_key-cnt_netb,
1485   *      (5) p_key-cnt_arch,
1486         120 sy-vline NO-GAP.
1487   *** drill-down
1488     d_bukrs = p_key-bukrs.
1489     d_belnr = p_key-augbl.
1490     d_gjahr = p_key-auggj.
1491     HIDE: d_bukrs, d_belnr, d_gjahr.
1492   ENDFORM.                    " OUTPUT_KEY
1493
1494   *&---------------------------------------------------------------------*
1495   *&      Form  OUTPUT_INDEX
1496   *&---------------------------------------------------------------------*
1497   FORM output_index  USING    p_index TYPE index.
1498
1499     FORMAT COLOR 2 INTENSIFIED OFF.
1500     WRITE:/ sy-vline NO-GAP,
1501        (10) 'ITEM',
1502         (5) p_index-bukrs,
1503        (10) p_index-augdt,
1504        (10) p_index-augbl,
1505         (5) p_index-auggj,
1506        (10) p_index-belnr,
1507         (5) p_index-gjahr,
1508         (5) p_index-buzei.
1509     IF p_index-xarch NE space.
1510       WRITE: (5) p_index-xarch COLOR 6.
1511     ELSE.
1512       WRITE: (5) p_index-xarch.
1513     ENDIF.
1514     WRITE: (5) p_index-koart,
1515           (10) p_index-konto,
1516            120 sy-vline NO-GAP.
1517   *** drill-down
1518     d_bukrs = p_index-bukrs.
1519     d_belnr = p_index-belnr.
1520     d_gjahr = p_index-gjahr.
1521     HIDE: d_bukrs, d_belnr, d_gjahr.
1522   ENDFORM.                    " OUTPUT_INDEX
1523
1524   *&---------------------------------------------------------------------*
1525   *&      Form  HEADER_KEY
1526   *&---------------------------------------------------------------------*
1527   FORM header_key .
1528
1529     FORMAT COLOR 1 INTENSIFIED OFF.
1530     WRITE:/ sy-vline NO-GAP,
1531        (10) 'KEY',
1532         (5) 'BUKRS',
1533        (10) 'AUGDT',
1534        (10) 'AUGBL',
1535         (5) 'AUGGJ',
1536   *      (5) 'XNETB',
1537   *      (5) 'XARCH',
1538         120 sy-vline NO-GAP.
1539     NEW-LINE.
1540   ENDFORM.                    " HEADER_KEY
1541
1542   *&---------------------------------------------------------------------*
1543   *&      Form  HEADER_MESS
1544   *&---------------------------------------------------------------------*
1545   FORM header_mess .
1546
1547     FORMAT COLOR 1 INTENSIFIED OFF.
1548     WRITE:/ sy-vline NO-GAP,
1549        (10) 'MESSAGE',
1550   *      (5) 'BUZEI',
1551        (10) 'CLASS',
1552        (75) 'MSG',
1553         120 sy-vline NO-GAP.
1554   ENDFORM.                    " HEADER_MESS
1555
1556   *&---------------------------------------------------------------------*
1557   *&      Form  OUTPUT_MESS
1558   *&---------------------------------------------------------------------*
1559   FORM output_mess  USING    p_index  TYPE index
1560                              p_detail TYPE c.
1561     DATA: class(10) TYPE c.
1562     DATA: r_class TYPE RANGE OF class.
1563     DATA: l_class LIKE LINE OF r_class.
1564
1565     REFRESH r_class.
1566     CASE p_detail.
1567       WHEN 'K'.
1568         CLEAR l_class.
1569         l_class-sign = 'I'.
1570         l_class-option = 'EQ'.
1571         l_class-low = 'CLEARING'.
1572         APPEND l_class TO r_class.
1573         CLEAR l_class.
1574         l_class-sign = 'I'.
1575         l_class-option = 'EQ'.
1576         l_class-low = 'EXCLUDED'.
1577         APPEND l_class TO r_class.
1578         CLEAR l_class.
1579         l_class-sign = 'I'.
1580         l_class-option = 'EQ'.
1581         l_class-low = 'CROSS CC'.
1582         APPEND l_class TO r_class.
1583         CLEAR l_class.                                        "UD050913
1584         l_class-sign = 'I'.                                   "UD050913
1585         l_class-option = 'EQ'.                                "UD050913
1586         l_class-low = 'FOREX'.                                "UD050913
1587         APPEND l_class TO r_class.                            "UD050913
1588       WHEN 'H'.
1589         CLEAR l_class.
1590         l_class-sign = 'I'.
1591         l_class-option = 'EQ'.
1592         l_class-low = 'BKPFUPDATE'.
1593         APPEND l_class TO r_class.
1594         CLEAR l_class.
1595         l_class-sign = 'I'.
1596         l_class-option = 'EQ'.
1597         l_class-low = 'BKPFREVERS'.
1598         APPEND l_class TO r_class.
1599       WHEN 'I'.
1600         CLEAR l_class.
1601         l_class-sign = 'I'.
1602         l_class-option = 'EQ'.
1603         l_class-low = 'UPDATE'.
1604         APPEND l_class TO r_class.
1605         CLEAR l_class.
1606         l_class-sign = 'I'.
1607         l_class-option = 'EQ'.
1608         l_class-low = 'REVERSAL'.
1609         APPEND l_class TO r_class.
1610         CLEAR l_class.
1611         l_class-sign = 'I'.
1612         l_class-option = 'EQ'.
1613         l_class-low = 'CASH DISC'.
1614         APPEND l_class TO r_class.
1615     ENDCASE.
1616   *** select relevant messages
1617     LOOP AT gt_mess
1618       WHERE bukrs EQ p_index-bukrs
1619         AND belnr EQ p_index-belnr
1620         AND gjahr EQ p_index-gjahr
1621         AND buzei EQ p_index-buzei
1622         AND class IN r_class.
1623   *** set color
1624       CASE gt_mess-type.
1625         WHEN 0.
1626           FORMAT COLOR 7 INTENSIFIED OFF.
1627         WHEN 1.
1628           FORMAT COLOR 6 INTENSIFIED OFF.
1629         WHEN 2.
1630           FORMAT COLOR 3 INTENSIFIED OFF.
1631         WHEN 3.
1632           FORMAT COLOR 5 INTENSIFIED OFF.
1633         WHEN OTHERS.
1634       ENDCASE.
1635   *** message contents
1636       WRITE:/ sy-vline NO-GAP,
1637          (10) 'MESSAGE',
1638   *        (5) gt_mess-buzei,
1639          (10) gt_mess-class,
1640          (90) gt_mess-msg,
1641           120 sy-vline NO-GAP.
1642   *** drill-down
1643       d_bukrs = gt_mess-bukrs.
1644       d_belnr = gt_mess-belnr.
1645       d_gjahr = gt_mess-gjahr.
1646       HIDE: d_bukrs, d_belnr, d_gjahr.
1647     ENDLOOP.
1648   ENDFORM.                    " OUTPUT_MESS
1649
1650   *&---------------------------------------------------------------------*
1651   *&      Form  HEADER_CORR
1652   *&---------------------------------------------------------------------*
1653   FORM header_corr .
1654
1655     FORMAT COLOR 1 INTENSIFIED ON.
1656     ULINE (120).
1657     WRITE:/ sy-vline NO-GAP,
1658             'Clearings to be reset:',
1659         120 sy-vline NO-GAP.
1660     ULINE (120).
1661     FORMAT COLOR 3 INTENSIFIED OFF.
1662     WRITE:/ sy-vline NO-GAP,
1663             'Number of cases:',
1664             count_clr,
1665         120 sy-vline NO-GAP.
1666     NEW-LINE.
1667     ULINE (120).
1668     FORMAT COLOR OFF.
1669   ENDFORM.                    " HEADER_CORR
1670
1671   *&---------------------------------------------------------------------*
1672   *&      Form  GET_BSTAT_A
1673   *&---------------------------------------------------------------------*
1674   FORM get_bstat_a .
1675     DATA: ls_bkpf TYPE bkpf.
1676
1677     LOOP AT gt_key.
1678       SELECT SINGLE * FROM bkpf INTO ls_bkpf
1679         WHERE bukrs EQ gt_key-bukrs
1680           AND belnr EQ gt_key-augbl
1681           AND gjahr EQ gt_key-auggj.
1682       CHECK sy-subrc EQ 0.
1683       CHECK ls_bkpf-bstat EQ 'A'.
1684       gt_key-cl_bstat = 1.
1685       MODIFY gt_key.
1686     ENDLOOP.
1687   ENDFORM.                    " GET_BSTAT_A
1688
1689   *&---------------------------------------------------------------------*
1690   *&      Form  UPDATE_BKPF
1691   *&---------------------------------------------------------------------*
1692   FORM update_bkpf USING    x_rb TYPE c.
1693
1694   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1695   * S/4: reset clearing via standard posting interface (programmatic FBRA); direct UPDATE bkpf not allowed.
1696   *  UPDATE bkpf
1697   *  SET   bstat = 'B'
1698   *  WHERE bukrs = gt_key-bukrs
1699   *  AND   belnr = gt_key-augbl
1700   *  AND   gjahr = gt_key-auggj.
1701     CALL FUNCTION 'POSTING_INTERFACE_START' EXPORTING i_client = sy-mandt i_function = 'C'
1702          i_mode = 'N' i_update = 'S' i_user = sy-uname EXCEPTIONS OTHERS = 0.
1703     CALL FUNCTION 'POSTING_INTERFACE_RESET_CLEAR' EXPORTING i_bukrs = gt_key-bukrs
1704          i_augbl = gt_key-augbl i_gjahr = gt_key-auggj i_tcode = 'FBRA' EXCEPTIONS OTHERS = 0.
1705     CALL FUNCTION 'POSTING_INTERFACE_END' EXPORTING i_bdcimmed = 'X' EXCEPTIONS OTHERS = 0.
1706   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1707     IF sy-subrc NE 0.
1708   *** message handling
1709       CLEAR gt_mess.
1710       MOVE-CORRESPONDING gt_key TO gt_mess.
1711       gt_mess-belnr = gt_key-augbl.
1712       gt_mess-gjahr = gt_key-auggj.
1713       gt_mess-type = 1.
1714       gt_mess-class = 'UPDATE'.
1715       CONCATENATE 'BKPF-BSTAT update'
1716                   'failed'
1717       INTO gt_mess-msg SEPARATED BY space.
1718       APPEND gt_mess.
1719       x_rb = 'X'.
1720     ELSE.
1721       CLEAR gt_mess.
1722       MOVE-CORRESPONDING gt_key TO gt_mess.
1723       gt_mess-belnr = gt_key-augbl.
1724       gt_mess-gjahr = gt_key-auggj.
1725       gt_mess-type = 3.
1726       gt_mess-class = 'UPDATE'.
1727       gt_mess-msg = 'BKPF-BSTAT updated with B'.
1728       APPEND gt_mess.
1729     ENDIF.
1730   ENDFORM.                    " UPDATE_BKPF
1731
1732   *&---------------------------------------------------------------------*
1733   *&      Form  CHECK_CLR_DOC
1734   *&---------------------------------------------------------------------*
1735   FORM check_clr_doc .
1736     DATA: ls_bkpf TYPE bkpf.
1737     DATA: table TYPE dd02l-tabname.                           "UD281016
1738     DATA: date(10) TYPE c.                                    "281016
1739
1740     LOOP AT gt_key.
1741       SELECT SINGLE * FROM bkpf INTO ls_bkpf
1742         WHERE bukrs EQ gt_key-bukrs
1743           AND belnr EQ gt_key-augbl
1744           AND gjahr EQ gt_key-auggj.
1745       CHECK sy-subrc EQ 0.
1746       IF ls_bkpf-bstat EQ 'L'.                                "UD281016
1747         table = 'BSEG_ADD'.                                   "UD281016
1748       ELSE.                                                   "UD281016
1749         table = 'BSEG'.                                       "UD281016
1750       ENDIF.                                                  "UD281016
1751   *** if clearing document is a reversal => exclude if X_REVERS not set
1752   *** also exclude if reversal contains archived items
1753       IF ls_bkpf-stblg NE space.
1754         IF x_revers EQ space OR gt_key-cnt_arch GT 0.         "UD280411
1755           CLEAR gt_mess.
1756           MOVE-CORRESPONDING gt_key TO gt_mess.
1757           gt_mess-belnr = gt_key-augbl.
1758           gt_mess-gjahr = gt_key-auggj.
1759           gt_mess-type = 1.
1760           gt_mess-class = 'EXCLUDED'.
1761           gt_mess-msg = 'Clearing document is a reversal'.
1762           APPEND gt_mess.
1763           gt_key-reverse = 1.                                 "UD280411
1764   *        INSERT gt_key INTO TABLE gt_key_excl.              "UD281016
1765           APPEND gt_key TO gt_key_excl.                       "UD281016
1766           DELETE gt_key.
1767   *** process reversal                                        "UD280411
1768         ELSE.                                                 "UD280411
1769           PERFORM reset_reversal USING gt_key ls_bkpf.        "UD280411
1770           gt_key-reverse = 1.                                 "UD280411
1771           MODIFY gt_key.                                      "UD280411
1772           CLEAR gt_mess.                                      "UD280411
1773           MOVE-CORRESPONDING gt_key TO gt_mess.               "UD280411
1774           gt_mess-belnr = gt_key-augbl.                       "UD280411
1775           gt_mess-gjahr = gt_key-auggj.                       "UD280411
1776           gt_mess-type = 2.                                   "UD280411
1777           gt_mess-class = 'CLEARING'.                         "UD280411
1778           CONCATENATE 'Clearing document is a reversal.'      "UD280411
1779                       'Reversal info will be reset.'          "UD280411
1780                       INTO gt_mess-msg SEPARATED BY space.    "UD280411
1781           APPEND gt_mess.                                     "UD280411
1782         ENDIF.                                                "UD280411
1783       ENDIF.
1784   *** if BVORG is populated => warning
1785       IF ls_bkpf-bvorg NE space.
1786         CLEAR gt_mess.
1787         MOVE-CORRESPONDING gt_key TO gt_mess.
1788         gt_mess-belnr = gt_key-augbl.
1789         gt_mess-gjahr = gt_key-auggj.
1790         gt_mess-type = 2.
1791         gt_mess-class = 'CROSS CC'.
1792         CONCATENATE 'Clearing document belongs to cross-company posting'
1793                     ls_bkpf-bvorg
1794         INTO gt_mess-msg SEPARATED BY space.
1795         APPEND gt_mess.
1796       ENDIF.
1797   *************************************************************UD200416
1798   *** allow to disable the KDF check                          "UD200416
1799       CHECK NOT no_rev EQ 'X'.                                "UD200416
1800   *************************************************************UD200416
1801   *************************************************************UD050913
1802   *** check for KDF lines in payments => reversal required    "UD050913
1803       DATA: cnt_kdf TYPE i.                                   "UD050913
1804       DATA: ls_oper TYPE t001b-frpe1.                         "UD050913
1805       CLEAR cnt_kdf.                                          "UD050913
1806       CHECK gt_key-cl_bstat EQ 0.                             "UD050913
1807   *************************************************************UD281016
1808   *** do also check for BSTAT 'L' documents                   "UD281016
1809   *    SELECT COUNT( * ) FROM bseg INTO cnt_kdf     "UD050913/"UD281016
1810       SELECT COUNT( * ) FROM (table) INTO cnt_kdf             "UD281016
1811   *************************************************************UD281016
1812         WHERE bukrs EQ gt_key-bukrs                           "UD050913
1813           AND belnr EQ gt_key-augbl                           "UD050913
1814           AND gjahr EQ gt_key-auggj                           "UD050913
1815           AND ktosl EQ 'KDF'.                                 "UD050913
1816       CHECK cnt_kdf GT 0.                                     "UD050913
1817   *** message: KDF line detected => reversal mandatory        "UD050913
1818       CLEAR gt_mess.                                          "UD050913
1819       MOVE-CORRESPONDING gt_key TO gt_mess.                   "UD050913
1820       gt_mess-belnr = gt_key-augbl.                           "UD050913
1821       gt_mess-gjahr = gt_key-auggj.                           "UD050913
1822       gt_mess-type = 2.                                       "UD050913
1823       gt_mess-class = 'FOREX'.                                "UD050913
1824       CONCATENATE 'Exchange rate differences line detected.'  "UD050913
1825                   'Reversal is mandatory.'                    "UD050913
1826       INTO gt_mess-msg SEPARATED BY space.                    "UD050913
1827       APPEND gt_mess.                                         "UD050913
1828   *** first error: no reversal reason entered                 "UD050913
1829       IF p_stgrd EQ space.                                    "UD050913
1830         CLEAR gt_mess.                                        "UD050913
1831         MOVE-CORRESPONDING gt_key TO gt_mess.                 "UD050913
1832         gt_mess-belnr = gt_key-augbl.                         "UD050913
1833         gt_mess-gjahr = gt_key-auggj.                         "UD050913
1834         gt_mess-type = 1.                                     "UD050913
1835         gt_mess-class = 'FOREX'.                              "UD050913
1836         CONCATENATE 'Please enter'                            "UD050913
1837                     'a reversal reason'                       "UD050913
1838         INTO gt_mess-msg SEPARATED BY space.                  "UD050913
1839         APPEND gt_mess.                                       "UD050913
1840         gt_key-kdf = 1.                                       "UD050913
1841   *      INSERT gt_key INTO TABLE gt_key_excl.      "UD050913/"UD281016
1842         APPEND gt_key TO gt_key_excl.                         "UD281016
1843         DELETE gt_key.                                        "UD050913
1844         CONTINUE.                                             "UD050913
1845   *** next error: STGRD does not exist                        "UD050913
1846       ELSE.                                                   "UD050913
1847         DATA: ls_t041c TYPE t041c.                            "UD050913
1848         SELECT SINGLE * FROM t041c INTO ls_t041c              "UD050913
1849           WHERE stgrd EQ p_stgrd.                             "UD050913
1850         IF NOT sy-subrc EQ 0.                                 "UD050913
1851           CLEAR gt_mess.                                      "UD050913
1852           MOVE-CORRESPONDING gt_key TO gt_mess.               "UD050913
1853           gt_mess-belnr = gt_key-augbl.                       "UD050913
1854           gt_mess-gjahr = gt_key-auggj.                       "UD050913
1855           gt_mess-type = 1.                                   "UD050913
1856           gt_mess-class = 'FOREX'.                            "UD050913
1857           CONCATENATE 'KDF line found but no reversal possible.'"UD0509
1858                       'Reversal Reason not found.'            "UD050913
1859           INTO gt_mess-msg SEPARATED BY space.                "UD050913
1860           APPEND gt_mess.                                     "UD050913
1861           gt_key-kdf = 1.                                     "UD050913
1862   *        INSERT gt_key INTO TABLE gt_key_excl.    "UD050913/"UD281016
1863           APPEND gt_key TO gt_key_excl.                       "UD281016
1864           DELETE gt_key.                                      "UD050913
1865           CONTINUE.                                           "UD050913
1866   *************************************************************UD281016
1867   *** different reversal date?                                "UD281016
1868         ELSE.                                                 "UD281016
1869           IF newdate EQ 'X' AND NOT ls_t041c-xabwd EQ 'X'.    "UD281016
1870             CLEAR gt_mess.                                    "UD281016
1871             MOVE-CORRESPONDING gt_key TO gt_mess.             "UD281016
1872             gt_mess-belnr = gt_key-augbl.                     "UD281016
1873             gt_mess-gjahr = gt_key-auggj.                     "UD281016
1874             gt_mess-type = 1.                                 "UD281016
1875             gt_mess-class = 'FOREX'.                          "UD281016
1876             CONCATENATE 'Reversal reason' p_stgrd             "UD281016
1877                         'does not allow different date.'      "UD281016
1878             INTO gt_mess-msg SEPARATED BY space.              "UD281016
1879             APPEND gt_mess.                                   "UD281016
1880             gt_key-kdf = 1.                                   "UD281016
1881   *          INSERT gt_key INTO TABLE gt_key_excl.  "UD050913/"UD281016
1882             APPEND gt_key TO gt_key_excl.                     "UD281016
1883             DELETE gt_key.                                    "UD281016
1884             CONTINUE.                                         "UD281016
1885           ENDIF.                                              "UD281016
1886         ENDIF.                                                "UD050913
1887       ENDIF.                                                  "UD050913
1888   *** check if period is open for reversal                    "UD050913
1889       DATA: ls_poper TYPE glu1-poper.                         "UD050913
1890   *** pay attention to new reversal date                      "UD281016
1891       DATA: ls_gjahr TYPE bkpf-gjahr.                         "UD281016
1892       IF newdate EQ space.                                    "UD281016
1893         ls_gjahr = ls_bkpf-gjahr.                             "UD281016
1894         ls_poper = ls_bkpf-monat.                             "UD050913
1895         gt_key-revdate = ls_bkpf-budat.                       "UD281016
1896         CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'           "UD050913
1897           EXPORTING                                           "UD050913
1898             input         = ls_poper                          "UD050913
1899           IMPORTING                                           "UD050913
1900             output        = ls_poper.                         "UD050913
1901       ELSE.                                                   "UD281016
1902         CALL FUNCTION 'FI_PERIOD_DETERMINE'                   "UD281016
1903           EXPORTING                                           "UD281016
1904             i_budat        = revdate                          "UD281016
1905             i_bukrs        = gt_key-bukrs                     "UD281016
1906           IMPORTING                                           "UD281016
1907             e_gjahr        = ls_gjahr                         "UD281016
1908             e_poper        = ls_poper                         "UD281016
1909           EXCEPTIONS                                          "UD281016
1910             fiscal_year    = 1                                "UD281016
1911             period         = 2                                "UD281016
1912             period_version = 3                                "UD281016
1913             posting_period = 4                                "UD281016
1914             special_period = 5                                "UD281016
1915             version        = 6                                "UD281016
1916             posting_date   = 7                                "UD281016
1917             OTHERS         = 8.                               "UD281016
1918         IF sy-subrc NE 0.                                     "UD281016
1919           CLEAR gt_mess.                                      "UD281016
1920           MOVE-CORRESPONDING gt_key TO gt_mess.               "UD281016
1921           gt_mess-belnr = gt_key-augbl.                       "UD281016
1922           gt_mess-gjahr = gt_key-auggj.                       "UD281016
1923           gt_mess-type = 1.                                   "UD281016
1924           gt_mess-class = 'FOREX'.                            "UD281016
1925           CONCATENATE 'Error in period'                       "UD281016
1926                       'determination'                         "UD281016
1927           INTO gt_mess-msg SEPARATED BY space.                "UD281016
1928           APPEND gt_mess.                                     "UD281016
1929           gt_key-kdf = 1.                                     "UD281016
1930   *        INSERT gt_key INTO TABLE gt_key_excl.    "UD050913/"UD281016
1931           APPEND gt_key TO gt_key_excl.                       "UD281016
1932           DELETE gt_key.                                      "UD281016
1933           CONTINUE.                                           "UD281016
1934         ENDIF.                                                "UD281016
1935         gt_key-revdate = revdate.                             "UD281016
1936       ENDIF.                                                  "UD281016
1937       CALL FUNCTION 'FI_PERIOD_CHECK'                         "UD050913
1938         EXPORTING                                             "UD050913
1939           i_bukrs = ls_bkpf-bukrs                             "UD050913
1940   *        i_gjahr = ls_bkpf-gjahr                  "UD050913/"UD281016
1941           i_gjahr = ls_gjahr                                  "UD281016
1942           i_koart = '+'                                       "UD050913
1943           i_monat = ls_poper                                  "UD050913
1944         IMPORTING                                             "UD050913
1945   *        e_oper  = ls_oper.                                 "UD281016
1946           e_oper  = ls_oper                                   "UD281016
1947         EXCEPTIONS                                            "UD281016
1948           error_period     = 1                                "UD281016
1949           error_period_acc = 2                                "UD281016
1950           invalid_input    = 3                                "UD281016
1951           OTHERS           = 4.                               "UD281016
1952       IF sy-subrc NE 0.                                       "UD281016
1953   *** message: error from open period check                   "UD281016
1954         CLEAR gt_mess.                                        "UD281016
1955         MOVE-CORRESPONDING gt_key TO gt_mess.                 "UD281016
1956         gt_mess-belnr = gt_key-augbl.                         "UD281016
1957         gt_mess-gjahr = gt_key-auggj.                         "UD281016
1958         gt_mess-type = 1.                                     "UD281016
1959         gt_mess-class = 'FOREX'.                              "UD281016
1960         CONCATENATE 'Posting Period'                          "UD281016
1961                     'is not open'                             "UD281016
1962         INTO gt_mess-msg SEPARATED BY space.                  "UD281016
1963         APPEND gt_mess.                                       "UD281016
1964         gt_key-kdf = 1.                                       "UD281016
1965   *        INSERT gt_key INTO TABLE gt_key_excl.    "UD050913/"UD281016
1966         APPEND gt_key TO gt_key_excl.                         "UD281016
1967         DELETE gt_key.                                        "UD281016
1968         CONTINUE.                                             "UD281016
1969       ENDIF.                                                  "UD281016
1970       IF ls_oper GT ls_bkpf-monat.                            "UD050913
1971   *** message: KDF line but period not open => exclude        "UD050913
1972         CLEAR gt_mess.                                        "UD050913
1973         MOVE-CORRESPONDING gt_key TO gt_mess.                 "UD050913
1974         gt_mess-belnr = gt_key-augbl.                         "UD050913
1975         gt_mess-gjahr = gt_key-auggj.                         "UD050913
1976         gt_mess-type = 1.                                     "UD050913
1977         gt_mess-class = 'FOREX'.                              "UD050913
1978         CONCATENATE 'KDF line found but no reversal possible.'"UD050913
1979                     'Period ' ls_bkpf-monat 'is closed.'      "UD050913
1980         INTO gt_mess-msg SEPARATED BY space.                  "UD050913
1981         APPEND gt_mess.                                       "UD050913
1982         gt_key-kdf = 1.                                       "UD050913
1983   *        INSERT gt_key INTO TABLE gt_key_excl.    "UD050913/"UD281016
1984         APPEND gt_key TO gt_key_excl.                         "UD281016
1985         DELETE gt_key.                                        "UD050913
1986         CONTINUE.                                             "UD050913
1987   *** message: key is submitted to SAPF080                    "UD050913
1988       ELSE.                                                   "UD050913
1989         CLEAR gt_mess.                                        "UD050913
1990         MOVE-CORRESPONDING gt_key TO gt_mess.                 "UD050913
1991         gt_mess-belnr = gt_key-augbl.                         "UD050913
1992         gt_mess-gjahr = gt_key-auggj.                         "UD050913
1993         gt_mess-type = 3.                                     "UD050913
1994         gt_mess-class = 'FOREX'.                              "UD050913
1995         WRITE gt_key-revdate TO date DD/MM/YYYY.              "UD281016
1996         CONCATENATE 'Key is submitted to'                     "UD050913
1997                     'SAPF080 for automatic reversal.'         "UD050913
1998                     'Reversal date:' date                     "UD281016
1999         INTO gt_mess-msg SEPARATED BY space.                  "UD050913
2000         APPEND gt_mess.                                       "UD050913
2001         gt_key-kdf = 1.                                       "UD050913
2002   *      MODIFY gt_key TRANSPORTING kdf.            "UD050913/"UD281016
2003         MODIFY gt_key TRANSPORTING kdf revdate.               "UD281016
2004   *************************************************************UD281016
2005       ENDIF.                                                  "UD050913
2006   *************************************************************UD050913
2007     ENDLOOP.
2008   ENDFORM.                    " CHECK_CLR_DOC
2009
2010   *&---------------------------------------------------------------------*
2011   *&      Form  DELETE_INDEX
2012   *&---------------------------------------------------------------------*
2013   *FORM delete_index USING    x_rb TYPE c.                    "UD281016
2014   FORM delete_index USING    x_rb TYPE c                      "UD281016
2015                              x_lg TYPE c.                     "UD281016
2016     DATA: ls_bseg_recon TYPE bseg.
2017     DATA: tab TYPE dd02l-tabname VALUE 'FAGLBSAS'.            "UD281016
2018
2019     CHECK update EQ 'X'.
2020     IF x_lg EQ space.                                         "UD281016
2021       CASE gt_index-koart.
2022         WHEN 'D'.
2023   "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
2024
2025   *        DELETE FROM bsad
2026   *          WHERE bukrs EQ gt_index-bukrs
2027   *            AND kunnr EQ gt_index-konto
2028   *            AND augdt EQ gt_index-augdt
2029   *            AND augbl EQ gt_index-augbl
2030   *            AND gjahr EQ gt_index-gjahr
2031   *            AND belnr EQ gt_index-belnr
2032   *            AND buzei EQ gt_index-buzei.
2033   "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
2034           IF sy-subrc EQ 0.
2035   *** message handling
2036             CLEAR gt_mess.
2037             MOVE-CORRESPONDING gt_index TO gt_mess.
2038             gt_mess-type = 3.
2039             gt_mess-class = 'UPDATE'.
2040             gt_mess-msg = 'BSAD deleted'.
2041             APPEND gt_mess.
2042   *** check recon account
2043             IF gt_index-xhres EQ 'X'.
2044               PERFORM delete_recon USING x_rb.
2045             ENDIF.
2046           ELSE.
2047             x_rb = 'X'.
2048   *** message handling
2049             CLEAR gt_mess.
2050             MOVE-CORRESPONDING gt_index TO gt_mess.
2051             gt_mess-type = 1.
2052             gt_mess-class = 'UPDATE'.
2053             gt_mess-msg = 'BSAD deletion failed'.
2054             APPEND gt_mess.
2055           ENDIF.
2056         WHEN 'K'.
2057           "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
2058   *        DELETE FROM bsak
2059   *          WHERE bukrs EQ gt_index-bukrs
2060   *            AND lifnr EQ gt_index-konto
2061   *            AND augdt EQ gt_index-augdt
2062   *            AND augbl EQ gt_index-augbl
2063   *            AND gjahr EQ gt_index-gjahr
2064   *            AND belnr EQ gt_index-belnr
2065   *            AND buzei EQ gt_index-buzei.
2066           "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
2067           IF sy-subrc EQ 0.
2068   *** message handling
2069             CLEAR gt_mess.
2070             MOVE-CORRESPONDING gt_index TO gt_mess.
2071             gt_mess-type = 3.
2072             gt_mess-class = 'UPDATE'.
2073             gt_mess-msg = 'BSAK deleted'.
2074             APPEND gt_mess.
2075   *** check recon account
2076             IF gt_index-xhres EQ 'X'.
2077               PERFORM delete_recon USING x_rb.
2078             ENDIF.
2079           ELSE.
2080             x_rb = 'X'.
2081   *** message handling
2082             CLEAR gt_mess.
2083             MOVE-CORRESPONDING gt_index TO gt_mess.
2084             gt_mess-type = 1.
2085             gt_mess-class = 'UPDATE'.
2086             gt_mess-msg = 'BSAK deletion failed'.
2087             APPEND gt_mess.
2088           ENDIF.
2089         WHEN 'S'.
2090    "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
2091   *        DELETE FROM bsas
2092   *          WHERE bukrs EQ gt_index-bukrs
2093   *            AND hkont EQ gt_index-konto
2094   *            AND augdt EQ gt_index-augdt
2095   *            AND augbl EQ gt_index-augbl
2096   *            AND gjahr EQ gt_index-gjahr
2097   *            AND belnr EQ gt_index-belnr
2098   *            AND buzei EQ gt_index-buzei.
2099           "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
2100           IF sy-subrc EQ 0.
2101   *** message handling
2102             CLEAR gt_mess.
2103             MOVE-CORRESPONDING gt_index TO gt_mess.
2104             gt_mess-type = 3.
2105             gt_mess-class = 'UPDATE'.
2106             gt_mess-msg = 'BSAS deleted'.
2107             APPEND gt_mess.
2108           ELSE.
2109             x_rb = 'X'.
2110   *** message handling
2111             CLEAR gt_mess.
2112             MOVE-CORRESPONDING gt_index TO gt_mess.
2113             gt_mess-type = 1.
2114             gt_mess-class = 'UPDATE'.
2115             gt_mess-msg = 'BSAS deletion failed'.
2116             APPEND gt_mess.
2117           ENDIF.
2118         WHEN OTHERS.
2119       ENDCASE.
2120   *** XLGCLR case: delete FAGLBSAS                            "UD281016
2121     ELSE.                                                     "UD281016
2122       DELETE FROM (tab)                                       "UD281016
2123         WHERE bukrs EQ gt_index-bukrs                         "UD281016
2124           AND hkont EQ gt_index-konto                         "UD281016
2125           AND augdt EQ gt_index-augdt                         "UD281016
2126           AND augbl EQ gt_index-augbl                         "UD281016
2127           AND gjahr EQ gt_index-gjahr                         "UD281016
2128           AND belnr EQ gt_index-belnr                         "UD281016
2129           AND buzei EQ gt_index-buzei.                        "UD281016
2130       IF sy-subrc EQ 0.                                       "UD281016
2131   *** message handling                                        "UD281016
2132         CLEAR gt_mess.                                        "UD281016
2133         MOVE-CORRESPONDING gt_index TO gt_mess.               "UD281016
2134         gt_mess-type = 3.                                     "UD281016
2135         gt_mess-class = 'UPDATE'.                             "UD281016
2136         gt_mess-msg = 'FAGLBSAS deleted'.                     "UD281016
2137         APPEND gt_mess.                                       "UD281016
2138       ELSE.                                                   "UD281016
2139         x_rb = 'X'.                                           "UD281016
2140   *** message handling                                        "UD281016
2141         CLEAR gt_mess.                                        "UD281016
2142         MOVE-CORRESPONDING gt_index TO gt_mess.               "UD281016
2143         gt_mess-type = 1.                                     "UD281016
2144         gt_mess-class = 'UPDATE'.                             "UD281016
2145         gt_mess-msg = 'FAGLBSAS deletion failed'.             "UD281016
2146         APPEND gt_mess.                                       "UD281016
2147       ENDIF.                                                  "UD281016
2148     ENDIF.                                                    "UD281016
2149   ENDFORM.                    " DELETE_INDEX
2150
2151   *&---------------------------------------------------------------------*
2152   *&      Form  DELETE_RECON
2153   *&---------------------------------------------------------------------*
2154   FORM delete_recon  USING    x_rb TYPE c.
2155   "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
2156   *  DELETE FROM bsas
2157   *    WHERE bukrs EQ gt_index-bukrs
2158   *      AND hkont EQ gt_index-recon
2159   *      AND augdt EQ gt_index-augdt
2160   *      AND augbl EQ gt_index-augbl
2161   *      AND gjahr EQ gt_index-gjahr
2162   *      AND belnr EQ gt_index-belnr
2163   *      AND buzei EQ gt_index-buzei.
2164   "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
2165     IF sy-subrc EQ 0.
2166   *** message handling
2167       CLEAR gt_mess.
2168       MOVE-CORRESPONDING gt_index TO gt_mess.
2169       gt_mess-type = 3.
2170       gt_mess-class = 'UPDATE'.
2171       gt_mess-msg = 'BSAS(recon acct) deleted'.
2172       APPEND gt_mess.
2173     ELSE.
2174       x_rb = 'X'.
2175   *** message handling
2176       CLEAR gt_mess.
2177       MOVE-CORRESPONDING gt_index TO gt_mess.
2178       gt_mess-type = 1.
2179       gt_mess-class = 'UPDATE'.
2180       gt_mess-msg = 'BSAS(recon acct) deletion failed'.
2181       APPEND gt_mess.
2182     ENDIF.
2183   ENDFORM.                    " DELETE_RECON
2184
2185   *&---------------------------------------------------------------------*
2186   *&      Form  LATE_CHECK_S_AUGBL
2187   *&---------------------------------------------------------------------*
2188   FORM late_check_s_augbl .
2189
2190     LOOP AT s_augbl
2191       WHERE sign EQ 'I'.
2192       EXIT.
2193     ENDLOOP.
2194     IF sy-subrc NE 0.
2195       MESSAGE e016(gu)
2196       WITH 'Clearing document required'.
2197     ENDIF.
2198   ENDFORM.                    " LATE_CHECK_S_AUGBL
2199
2200   *&---------------------------------------------------------------------*
2201   *&      Form  RESET_REVERSAL
2202   *&---------------------------------------------------------------------*
2203   FORM reset_reversal  USING    i_key  TYPE key
2204                                 i_bkpf TYPE bkpf.
2205     DATA: lt_bseg TYPE TABLE OF bseg WITH HEADER LINE.
2206     DATA: ls_bkpf TYPE bkpf.
2207     DATA: table TYPE dd02l-tabname.                           "UD281016
2208
2209   *************************************************************UD281016
2210   *** ledgergroup-specific clearings                          "UD281016
2211     IF i_bkpf-bstat EQ 'L'.                                   "UD281016
2212       table = 'BSEG_ADD'.                                     "UD281016
2213     ELSE.                                                     "UD281016
2214       table = 'BSEG'.                                         "UD281016
2215     ENDIF.                                                    "UD281016
2216   *************************************************************UD281016
2217   *** select all cleared items from reversal doc
2218   *  SELECT * FROM bseg INTO TABLE lt_bseg                    "UD281016
2219     SELECT * FROM (table)                                     "UD281016
2220     INTO CORRESPONDING FIELDS OF TABLE lt_bseg                "UD281016
2221       WHERE bukrs EQ i_bkpf-bukrs
2222         AND belnr EQ i_bkpf-belnr
2223         AND gjahr EQ i_bkpf-gjahr
2224         AND augbl EQ i_bkpf-belnr
2225         AND auggj EQ i_bkpf-gjahr.  "#EC CI_FLDEXT_OK[2610650]
2226   *** add items from reversed doc
2227   *  SELECT * FROM bseg INTO lt_bseg                          "UD281016
2228     SELECT * FROM (table)                                     "UD281016
2229     INTO CORRESPONDING FIELDS OF lt_bseg                      "UD281016
2230       WHERE bukrs EQ i_bkpf-bukrs
2231         AND belnr EQ i_bkpf-stblg
2232         AND gjahr EQ i_bkpf-stjah
2233         AND augbl EQ i_bkpf-belnr
2234         AND auggj EQ i_bkpf-gjahr.  "#EC CI_FLDEXT_OK[2610650]
2235       APPEND lt_bseg.
2236     ENDSELECT.
2237   *** check if all involved cleared items are already selected
2238     LOOP AT lt_bseg.
2239       READ TABLE gt_index WITH KEY
2240         bukrs = lt_bseg-bukrs
2241         augdt = lt_bseg-augdt
2242         augbl = lt_bseg-augbl
2243         auggj = lt_bseg-auggj
2244         belnr = lt_bseg-belnr
2245         gjahr = lt_bseg-gjahr
2246         buzei = lt_bseg-buzei.
2247       CHECK NOT sy-subrc EQ 0.
2248   *** build index if not existing yet
2249       CLEAR gt_index.
2250       MOVE-CORRESPONDING lt_bseg TO gt_index.
2251       CASE lt_bseg-koart.
2252         WHEN 'K'.
2253           gt_index-konto = lt_bseg-lifnr.
2254           gt_index-recon = lt_bseg-hkont.
2255         WHEN 'D'.
2256           gt_index-konto = lt_bseg-kunnr.
2257           gt_index-recon = lt_bseg-hkont.
2258         WHEN 'S'.
2259           gt_index-konto = lt_bseg-hkont.
2260       ENDCASE.
2261       APPEND gt_index.
2262   *** info message
2263       CLEAR gt_mess.
2264       MOVE-CORRESPONDING gt_index TO gt_mess.
2265       gt_mess-type = 3.
2266       gt_mess-class = 'REVERSAL'.
2267       CONCATENATE 'Other cleared item,'
2268                   'automatically selected'
2269       INTO gt_mess-msg SEPARATED BY space.
2270       APPEND gt_mess.
2271     ENDLOOP.
2272   *** prepare header information for undoing reversal
2273     CLEAR gt_rev_key.
2274     gt_rev_key-bukrs = i_bkpf-bukrs.
2275     gt_rev_key-belnr_2 = i_bkpf-belnr.
2276     gt_rev_key-gjahr_2 = i_bkpf-gjahr.
2277     gt_rev_key-belnr_1 = i_bkpf-stblg.
2278     gt_rev_key-gjahr_1 = i_bkpf-stjah.
2279     INSERT gt_rev_key INTO TABLE gt_rev_key.
2280   *** append BKPF for output
2281     APPEND i_bkpf TO gt_bkpf_rev.
2282   *** info message
2283     CLEAR gt_mess.
2284     MOVE-CORRESPONDING i_bkpf TO gt_mess.
2285     gt_mess-type = 3.
2286     gt_mess-class = 'BKPFREVERS'.
2287     CONCATENATE 'Reversal information'
2288                 'to be reset'
2289     INTO gt_mess-msg SEPARATED BY space.
2290     APPEND gt_mess.
2291     SELECT SINGLE * FROM bkpf INTO ls_bkpf
2292       WHERE bukrs EQ gt_rev_key-bukrs
2293         AND belnr EQ gt_rev_key-belnr_1
2294         AND gjahr EQ gt_rev_key-gjahr_1.
2295     APPEND ls_bkpf TO gt_bkpf_rev.
2296   *** info message
2297     CLEAR gt_mess.
2298     MOVE-CORRESPONDING ls_bkpf TO gt_mess.
2299     gt_mess-type = 3.
2300     gt_mess-class = 'BKPFREVERS'.
2301     CONCATENATE 'Reversal information'
2302                 'to be reset'
2303     INTO gt_mess-msg SEPARATED BY space.
2304     APPEND gt_mess.
2305   ENDFORM.                    " RESET_REVERSAL
2306
2307   *&---------------------------------------------------------------------*
2308   *&      Form  UPDATE_BKPF_REVERSAL
2309   *----------------------------------------------------------------------*
2310   FORM update_bkpf_reversal  USING    x_rb TYPE c.            "UD280411
2311     DATA: lt_bkpf_new TYPE TABLE OF bkpf WITH HEADER LINE.    "UD280411
2312     DATA: lt_bkpf_old TYPE TABLE OF bkpf WITH HEADER LINE.    "UD280411
2313                                                               "UD280411
2314     CHECK update EQ 'X'.                                      "UD280411
2315   *** get affected headers via reversal key                   "UD280411
2316     REFRESH: lt_bkpf_old, lt_bkpf_new.                        "UD280411
2317     READ TABLE gt_rev_key WITH KEY                            "UD280411
2318       bukrs   = gt_key-bukrs                                  "UD280411
2319       belnr_2 = gt_key-augbl                                  "UD280411
2320       gjahr_2 = gt_key-auggj.                                 "UD280411
2321   *** select corresponding reversal BKPF                      "UD280411
2322     SELECT SINGLE * FROM bkpf INTO lt_bkpf_new                "UD280411
2323       WHERE bukrs EQ gt_rev_key-bukrs                         "UD280411
2324         AND belnr EQ gt_rev_key-belnr_2                       "UD280411
2325         AND gjahr EQ gt_rev_key-gjahr_2.                      "UD280411
2326     APPEND lt_bkpf_new TO lt_bkpf_old.                        "UD280411
2327     CLEAR: lt_bkpf_new-stblg,                                 "UD280411
2328            lt_bkpf_new-stjah,                                 "UD280411
2329            lt_bkpf_new-stgrd,                                 "UD280411
2330            lt_bkpf_new-xreversal.                             "UD280411
2331     APPEND lt_bkpf_new.                                       "UD280411
2332   *** select corresponding reversed BKPF                      "UD280411
2333     SELECT SINGLE * FROM bkpf INTO lt_bkpf_new                "UD280411
2334       WHERE bukrs EQ gt_rev_key-bukrs                         "UD280411
2335         AND belnr EQ gt_rev_key-belnr_1                       "UD280411
2336         AND gjahr EQ gt_rev_key-gjahr_1.                      "UD280411
2337     APPEND lt_bkpf_new TO lt_bkpf_old.                        "UD280411
2338     CLEAR: lt_bkpf_new-stblg,                                 "UD280411
2339            lt_bkpf_new-stjah,                                 "UD280411
2340            lt_bkpf_new-stgrd,                                 "UD280411
2341            lt_bkpf_new-xreversal.                             "UD280411
2342     APPEND lt_bkpf_new.                                       "UD280411
2343   *** update BKPF                                             "UD280411
2344     LOOP AT lt_bkpf_new.                                      "UD280411
2345   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
2346   * S/4: removal of reversal linkage (STBLG/STJAH/STGRD/XREVERSAL) has NO standard API - a posted
2347   *      reversal cannot be undone in S/4HANA (re-post required). Direct UPDATE bkpf not allowed.
2348   *    UPDATE bkpf                                             "UD280411
2349   *    SET   stblg = lt_bkpf_new-stblg                         "UD280411
2350   *          stjah = lt_bkpf_new-stjah                         "UD280411
2351   *          stgrd = lt_bkpf_new-stgrd                         "UD280411
2352   *      xreversal = lt_bkpf_new-xreversal                     "UD280411
2353   *    WHERE bukrs = lt_bkpf_new-bukrs                         "UD280411
2354   *    AND   belnr = lt_bkpf_new-belnr                         "UD280411
2355   *    AND   gjahr = lt_bkpf_new-gjahr.                        "UD280411
2356   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
2357       IF sy-subrc EQ 0.                                       "UD280411
2358   *** create message                                          "UD280411
2359         CLEAR gt_mess.                                        "UD280411
2360         MOVE-CORRESPONDING lt_bkpf_new TO gt_mess.            "UD280411
2361         gt_mess-type = 3.                                     "UD280411
2362         gt_mess-class = 'BKPFUPDATE'.                         "UD280411
2363         gt_mess-msg = 'Reversal case: BKPF updated'.          "UD280411
2364         APPEND gt_mess.                                       "UD280411
2365   *** write change document                                   "UD280411
2366         READ TABLE lt_bkpf_old WITH KEY                       "UD280411
2367           bukrs = lt_bkpf_new-bukrs                           "UD280411
2368           belnr = lt_bkpf_new-belnr                           "UD280411
2369           gjahr = lt_bkpf_new-gjahr.                          "UD280411
2370         PERFORM write_cd_bkpf_rev USING lt_bkpf_new           "UD280411
2371                                         lt_bkpf_old.          "UD280411
2372       ELSE.                                                   "UD280411
2373   *** create message                                          "UD280411
2374         CLEAR gt_mess.                                        "UD280411
2375         MOVE-CORRESPONDING lt_bkpf_new TO gt_mess.            "UD280411
2376         gt_mess-type = 1.                                     "UD280411
2377         gt_mess-class = 'BKPFUPDATE'.                         "UD280411
2378         gt_mess-msg = 'Reversal case: BKPF update failed'.    "UD280411
2379         APPEND gt_mess.                                       "UD280411
2380         x_rb = 'X'.                                           "UD280411
2381       ENDIF.                                                  "UD280411
2382     ENDLOOP.                                                  "UD280411
2383   ENDFORM.                    " UPDATE_BKPF_REVERSAL          "UD280411
2384
2385   *&---------------------------------------------------------------------*
2386   *&      Form  WRITE_CD_BKPF_REV
2387   *&---------------------------------------------------------------------*
2388   FORM write_cd_bkpf_rev  USING    i_bkpf_new TYPE bkpf
2389                                    i_bkpf_old TYPE bkpf.
2390     DATA: ls_objectid TYPE cdhdr-objectid.
2391
2392   *** create OBJECTID
2393     CLEAR ls_objectid.
2394     ls_objectid(3)    = i_bkpf_new-mandt.
2395     ls_objectid+3(4)  = i_bkpf_new-bukrs.
2396     ls_objectid+7(10) = i_bkpf_new-belnr.
2397     ls_objectid+17(4) = i_bkpf_new-gjahr.
2398   *** write CD in update task
2399     CALL FUNCTION 'BELEG_WRITE_DOCUMENT' IN UPDATE TASK
2400       EXPORTING
2401         objectid = ls_objectid
2402         utime    = sy-timlo
2403         udate    = sy-datlo
2404         username = sy-uname
2405         tcode    = sy-tcode
2406         n_bkpf   = i_bkpf_new
2407         o_bkpf   = i_bkpf_old
2408         upd_bkpf = 'U'.
2409   *** create message
2410     CLEAR gt_mess.
2411     MOVE-CORRESPONDING i_bkpf_new TO gt_mess.
2412     gt_mess-type = 3.
2413     gt_mess-class = 'BKPFUPDATE'.
2414     gt_mess-msg = 'Change document created for reversal BKPF'.
2415     APPEND gt_mess.
2416   ENDFORM.                    " WRITE_CD_BKPF_REV
2417
2418   *&---------------------------------------------------------------------*
2419   *&      Form  BKPF_HEADER
2420   *&---------------------------------------------------------------------*
2421   FORM bkpf_header .                                          "UD280411
2422                                                               "UD280411
2423     FORMAT COLOR 1 INTENSIFIED OFF.                           "UD280411
2424     WRITE:/ sy-vline NO-GAP,                                  "UD280411
2425        (10) 'BKPF',                                           "UD280411
2426         (5) 'BUKRS',                                          "UD280411
2427        (10) 'BELNR',                                          "UD280411
2428         (5) 'GJAHR',                                          "UD280411
2429        (10) 'BUDAT',                                          "UD280411
2430        (10) 'STBLG',                                          "UD280411
2431         (5) 'STJAH',                                          "UD280411
2432         (5) 'STGRD',                                          "UD280411
2433        (10) 'XREVERSAL',                                      "UD280411
2434         120 sy-vline NO-GAP.                                  "UD280411
2435     NEW-LINE.                                                 "UD280411
2436   ENDFORM.                    " BKPF_HEADER
2437
2438   *&---------------------------------------------------------------------*
2439   *&      Form  OUTPUT_BKPF
2440   *&---------------------------------------------------------------------*
2441   FORM output_bkpf  USING    i_bkpf_rev TYPE bkpf.            "UD280411
2442                                                               "UD280411
2443     FORMAT COLOR 2 INTENSIFIED OFF.                           "UD280411
2444     WRITE:/ sy-vline NO-GAP,                                  "UD280411
2445        (10) 'BKPF',                                           "UD280411
2446         (5) i_bkpf_rev-bukrs,                                 "UD280411
2447        (10) i_bkpf_rev-belnr,                                 "UD280411
2448         (5) i_bkpf_rev-gjahr,                                 "UD280411
2449        (10) i_bkpf_rev-budat,                                 "UD280411
2450        (10) i_bkpf_rev-stblg,                                 "UD280411
2451         (5) i_bkpf_rev-stjah,                                 "UD280411
2452         (5) i_bkpf_rev-stgrd,                                 "UD280411
2453        (10) i_bkpf_rev-xreversal,                             "UD280411
2454         120 sy-vline NO-GAP.                                  "UD280411
2455   *** drill-down                                              "UD280411
2456     d_bukrs = i_bkpf_rev-bukrs.                               "UD280411
2457     d_belnr = i_bkpf_rev-belnr.                               "UD280411
2458     d_gjahr = i_bkpf_rev-gjahr.                               "UD280411
2459     HIDE: d_bukrs, d_belnr, d_gjahr.                          "UD280411
2460   ENDFORM.                    " OUTPUT_BKPF                   "UD280411
2461
2462   *&---------------------------------------------------------------------*
2463   *&      Form  REVERSE_RESET_CLR                             "UD050913
2464   *&---------------------------------------------------------------------*
2465   FORM reverse_reset_clr .                                    "UD050913
2466     TYPES: BEGIN OF gjahrtab,                                 "UD050913
2467           bukrs TYPE bseg-bukrs,                              "UD050913
2468           auggj TYPE bseg-auggj,                              "UD050913
2469           END OF gjahrtab.                                    "UD050913
2470     DATA: lt_gjahrtab TYPE TABLE OF gjahrtab WITH HEADER LINE."UD050913
2471     RANGES: r_bukrs FOR bkpf-bukrs.                           "UD050913
2472     DATA: l_bukrs LIKE LINE OF r_bukrs.                       "UD050913
2473     RANGES: r_belnr FOR bkpf-belnr.                           "UD050913
2474     DATA: l_belnr LIKE LINE OF r_belnr.                       "UD050913
2475     RANGES: r_gjahr FOR bkpf-gjahr.                           "UD050913
2476     DATA: l_gjahr LIKE LINE OF r_gjahr.                       "UD050913
2477     DATA: spl TYPE TABLE OF abaplist WITH HEADER LINE.        "UD050913
2478     DATA: cnt_pack TYPE i.                                    "UD050913
2479     DATA: testflag TYPE c.                                    "UD050913
2480                                                               "UD050913
2481   *** set TESTFLAG for SUBMIT                                 "UD050913
2482     IF update EQ 'X'.                                         "UD050913
2483       CLEAR testflag.                                         "UD050913
2484     ELSE.                                                     "UD050913
2485       testflag = 'X'.                                         "UD050913
2486     ENDIF.                                                    "UD050913
2487   *** build up GJAHRTAB                                       "UD050913
2488     LOOP AT gt_key                                            "UD050913
2489       WHERE kdf GT 0.                                         "UD050913
2490       CLEAR lt_gjahrtab.                                      "UD050913
2491       MOVE-CORRESPONDING gt_key TO lt_gjahrtab.               "UD050913
2492       COLLECT lt_gjahrtab.                                    "UD050913
2493     ENDLOOP.                                                  "UD050913
2494   *** build ranges for submit to SAPF080                      "UD050913
2495     LOOP AT lt_gjahrtab.                                      "UD050913
2496       REFRESH: r_bukrs, r_belnr, r_gjahr.                     "UD050913
2497   *** build-up BUKRS range                                    "UD050913
2498       CLEAR l_bukrs.                                          "UD050913
2499       l_bukrs-sign = 'I'.                                     "UD050913
2500       l_bukrs-option = 'EQ'.                                  "UD050913
2501       l_bukrs-low = lt_gjahrtab-bukrs.                        "UD050913
2502       CLEAR l_bukrs-high.                                     "UD050913
2503       APPEND l_bukrs TO r_bukrs.                              "UD050913
2504   *** build-up GJAHR range                                    "UD050913
2505       CLEAR l_gjahr.                                          "UD050913
2506       l_gjahr-sign = 'I'.                                     "UD050913
2507       l_gjahr-option = 'EQ'.                                  "UD050913
2508       l_gjahr-low = lt_gjahrtab-auggj.                        "UD050913
2509       CLEAR l_gjahr-high.                                     "UD050913
2510       APPEND l_gjahr TO r_gjahr.                              "UD050913
2511   *** build-up BELNR range                                    "UD050913
2512       LOOP AT gt_key                                          "UD050913
2513         WHERE bukrs EQ lt_gjahrtab-bukrs                      "UD050913
2514           AND auggj EQ lt_gjahrtab-auggj.                     "UD050913
2515         CLEAR l_belnr.                                        "UD050913
2516         l_belnr-sign = 'I'.                                   "UD050913
2517         l_belnr-option = 'EQ'.                                "UD050913
2518         l_belnr-low = gt_key-augbl.                           "UD050913
2519         CLEAR l_belnr-high.                                   "UD050913
2520         APPEND l_belnr TO r_belnr.                            "UD050913
2521   ***********************************************************************
2522   *** package-wise SUBMIT to SAPF080                          "UD050913
2523         ADD 1 TO cnt_pack.                                    "UD050913
2524         IF cnt_pack EQ 100.                                   "UD050913
2525   *** submit SAPF080                                          "UD050913
2526   *************************************************************UD281016
2527   *** allow different reversal date                           "UD281016
2528           IF newdate EQ space.                                "UD281016
2529             SUBMIT sapf080                                    "UD050913
2530                WITH br_bukrs IN r_bukrs                       "UD050913
2531                WITH br_gjahr IN r_gjahr                       "UD050913
2532                WITH br_belnr IN r_belnr                       "UD050913
2533                WITH stogrd   EQ p_stgrd                       "UD050913
2534                WITH testlauf EQ testflag                      "UD050913
2535                EXPORTING LIST TO MEMORY                       "UD050913
2536                AND RETURN.                                    "UD050913
2537           ELSE.                                               "UD281016
2538             SUBMIT sapf080                                    "UD281016
2539                WITH br_bukrs IN r_bukrs                       "UD281016
2540                WITH br_gjahr IN r_gjahr                       "UD281016
2541                WITH br_belnr IN r_belnr                       "UD281016
2542                WITH stogrd   EQ p_stgrd                       "UD281016
2543   *** submit new reversal date                                "UD281016
2544                WITH stodat   EQ revdate                       "UD281016
2545                WITH testlauf EQ testflag                      "UD281016
2546                EXPORTING LIST TO MEMORY                       "UD281016
2547                AND RETURN.                                    "UD281016
2548           ENDIF.                                              "UD281016
2549   *** get spool                                               "UD050913
2550           REFRESH spl.                                        "UD050913
2551           CALL FUNCTION 'LIST_FROM_MEMORY'                    "UD050913
2552             TABLES                                            "UD050913
2553               listobject = spl                                "UD050913
2554             EXCEPTIONS                                        "UD050913
2555               not_found  = 1.                                 "UD050913
2556           IF sy-subrc = 0.                                    "UD050913
2557             CALL FUNCTION 'WRITE_LIST'                        "UD050913
2558               TABLES                                          "UD050913
2559                 listobject = spl.                             "UD050913
2560           ENDIF.                                              "UD050913
2561           REFRESH r_belnr.                                    "UD050913
2562           CLEAR cnt_pack.                                     "UD050913
2563         ENDIF.                                                "UD050913
2564       ENDLOOP.                                                "UD050913
2565   *** process residuals                                       "UD050913
2566       CHECK cnt_pack GT 0.                                    "UD050913
2567   ***********************************************************************
2568   *** submit SAPF080                                          "UD050913
2569       IF newdate EQ space.                                    "UD281016
2570         SUBMIT sapf080                                        "UD050913
2571            WITH br_bukrs IN r_bukrs                           "UD050913
2572            WITH br_gjahr IN r_gjahr                           "UD050913
2573            WITH br_belnr IN r_belnr                           "UD050913
2574            WITH stogrd   EQ p_stgrd                           "UD050913
2575            WITH testlauf EQ testflag                          "UD050913
2576            EXPORTING LIST TO MEMORY                           "UD050913
2577            AND RETURN.                                        "UD050913
2578       ELSE.                                                   "UD281016
2579         SUBMIT sapf080                                        "UD281016
2580            WITH br_bukrs IN r_bukrs                           "UD281016
2581            WITH br_gjahr IN r_gjahr                           "UD281016
2582            WITH br_belnr IN r_belnr                           "UD281016
2583            WITH stogrd   EQ p_stgrd                           "UD281016
2584   *** submit new reversal date                                "UD281016
2585            WITH stodat   EQ revdate                           "UD281016
2586            WITH testlauf EQ testflag                          "UD281016
2587            EXPORTING LIST TO MEMORY                           "UD281016
2588            AND RETURN.                                        "UD281016
2589       ENDIF.                                                  "UD281016
2590   *************************************************************UD281016
2591   *** get spool                                               "UD050913
2592       REFRESH spl.                                            "UD050913
2593       CALL FUNCTION 'LIST_FROM_MEMORY'                        "UD050913
2594         TABLES                                                "UD050913
2595           listobject = spl                                    "UD050913
2596         EXCEPTIONS                                            "UD050913
2597           not_found  = 1.                                     "UD050913
2598       IF sy-subrc = 0.                                        "UD050913
2599         CALL FUNCTION 'WRITE_LIST'                            "UD050913
2600           TABLES                                              "UD050913
2601             listobject = spl.                                 "UD050913
2602       ENDIF.                                                  "UD050913
2603     ENDLOOP.                                                  "UD050913
2604   ENDFORM.                    " REVERSE_RESET_CLR             "UD050913
2605
2606   *&---------------------------------------------------------------------*
2607   *&      Form  SELECT_CLEARING_FAGLBSAS
2608   *&---------------------------------------------------------------------*
2609   FORM select_clearing_faglbsas .                             "UD281016
2610     DATA: ls_bsas TYPE bsas.                                  "UD281016
2611     DATA: tab TYPE dd03l-tabname VALUE 'FAGLBSAS'.            "UD281016
2612                                                               "UD281016
2613     SELECT * FROM (tab) INTO CORRESPONDING FIELDS OF ls_bsas  "UD281016
2614       WHERE bukrs EQ p_bukrs                                  "UD281016
2615         AND hkont IN s_konto                                  "UD281016
2616         AND augbl IN s_augbl                                  "UD281016
2617         AND augdt IN s_augdt.  "#EC CI_FLDEXT_OK[2610650]  "UD281016
2618       CLEAR gt_index.                                         "UD281016
2619       MOVE-CORRESPONDING ls_bsas TO gt_index.                 "UD281016
2620       gt_index-koart = 'S'.                                   "UD281016
2621       gt_index-konto = ls_bsas-hkont.                         "UD281016
2622       gt_index-xlgclr = 'X'.                                  "UD281016
2623       APPEND gt_index.                                        "UD281016
2624       CLEAR gt_key.                                           "UD281016
2625       MOVE-CORRESPONDING ls_bsas TO gt_key.                   "UD281016
2626       gt_key-xlgclr = 1.                                      "UD281016
2627       IF ls_bsas-xarch EQ 'X'.                                "UD281016
2628         gt_key-cnt_arch = 1.                                  "UD281016
2629       ENDIF.                                                  "UD281016
2630       COLLECT gt_key.                                         "UD281016
2631     ENDSELECT.                                                "UD281016
2632   ENDFORM.                    " SELECT_CLEARING_FAGLBSAS      "UD281016
*--- End of ZF_RESET_CLR - 2632 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  <REPINI>                                  Level 1    Page 2
Object           ZF_RESET_CLR                              Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:05
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
Object           ZF_RESET_CLR                              Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:05
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
Object           ZF_RESET_CLR                              Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:05
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
Object           ZF_RESET_CLR                              Lines 1
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:05
----------------------------------------------------------------------------------------------------
1      * INCLUDE DB__SSEL
*--- End of DB__SSEL - 1 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  OSQL_DYNAMIC_EXTERNAL_ENTITIESCCDEF       Level 1    Page 6
Object           ZF_RESET_CLR                              Lines 4
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:05
----------------------------------------------------------------------------------------------------
1      *"* use this source file for any type of declarations (class
2      *"* definitions, interfaces or type declarations) you need for
3      *"* components in the private section
4
*--- End of OSQL_DYNAMIC_EXTERNAL_ENTITIESCCDEF - 4 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  OSQL_DYNAMIC_EXTERNAL_ENTITIESCI          Level 1    Page 7
Object           ZF_RESET_CLR                              Lines 2
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:05
----------------------------------------------------------------------------------------------------
1        private section.
2          class-data: s_dynamic_entities type dynamic_entities.
*--- End of OSQL_DYNAMIC_EXTERNAL_ENTITIESCI - 2 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  OSQL_DYNAMIC_EXTERNAL_ENTITIESCO          Level 1    Page 8
Object           ZF_RESET_CLR                              Lines 1
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:05
----------------------------------------------------------------------------------------------------
1        protected section.
*--- End of OSQL_DYNAMIC_EXTERNAL_ENTITIESCO - 1 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  OSQL_DYNAMIC_EXTERNAL_ENTITIESCU          Level 1    Page 9
Object           ZF_RESET_CLR                              Lines 17
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:05
----------------------------------------------------------------------------------------------------
1      class osql_dynamic_external_entities definition
2        public
3        final
4        create private .
5
6        public section.
7           types: begin of dynamic_entity,
8                     client type mandt,
9                     name type dd_cds_entity_name,
10                    logical_schema type dd_les_name,
11                    db_name type dbviewname,
12                    db_name_terminator type C length 1,
13                    db_name_len type i,
14                 end of dynamic_entity,
15                 dynamic_entities type standard table of dynamic_entity with empty key without further secondary keys.
16         class-methods: check_and_create,
17                        test.
*--- End of OSQL_DYNAMIC_EXTERNAL_ENTITIESCU - 17 lines ---
