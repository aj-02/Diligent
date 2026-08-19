----------------------------------------------------------------------------------------------------
Main program     ZSD_INVOICE_VAPEXP_DP                     Level 0    Page 1
Object           ZSD_INVOICE_VAPEXP_DP                     Lines 2580
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:09
----------------------------------------------------------------------------------------------------
1      REPORT zsd_invoice_vapexp_dp  LINE-COUNT 100 MESSAGE-ID vn.
2      *----------------------------------------------------------------------*
3      *              Print of an invoice by SAPscript                        *
4      *----------------------------------------------------------------------*
5
6
7      **************************************************************
8      *PROGRAM: ZSD_INVOICE_VAPEXP_DP
9      *
10     *TITLE:Value added products driver program( invoice for foreign
11     *customers )
12     *
13     *FS No: FS-SD-OUT-016
14     *
15     *Author: Madhukar   Date :21.12.2004
16     *
17     *Description:
18     *
19     *This Driver program ZSD_INVOICE_VAPEXP_DP is to print the Invoice for
20     *foriegn customers,for the given Billing Document no through
21     *Tcode VF03 using SAP script ZSD_INVC_VAP_EXP
22     *
23     *Tran Code :VF03
24     **************************************************************
25     *
26     *Change History
27     *
28     *Mod Date     Changed By     Description           Chng ID
29     *28.01.2005   Sudhir Sharma  Change for USD curr.  CAB_SUHDIR
30     *
31     **************************************************************
32     ***********************************************************************
33     * Date        Transport     USERID          Description
34     * 24/11/2008  <RD1K960611>  SAB_SURJIT    1) Commented Break Statements
35     ***********************************************************************
36     ***********************************************************************
37     * Definition of tables                                                *
38     ***********************************************************************
39
40     INCLUDE zsd_invoice_vapexp_dp_invdclr.
41     *INCLUDE zsd_invoice_vap_dp_invdclr.
42
43     ***********************************************************************
44     * Definition of internal tables                                       *
45     ***********************************************************************
46
47     DATA: BEGIN OF tvbdpr OCCURS 100.      "Internal table for items
48             INCLUDE STRUCTURE vbdpr.
49     DATA: END OF tvbdpr.
50
51     DATA: BEGIN OF tkomv OCCURS 50.
52             INCLUDE STRUCTURE komv.
53     DATA: END OF tkomv.
54
55     DATA: BEGIN OF tkomvd OCCURS 50.
56             INCLUDE STRUCTURE komvd.
57     DATA: END OF tkomvd.
58
59     DATA: BEGIN OF hkomvd OCCURS 50.
60             INCLUDE STRUCTURE komvd.
61     DATA: END OF hkomvd.
62
63     DATA: BEGIN OF tkomcon OCCURS 50.
64             INCLUDE STRUCTURE conf_out.
65     DATA: END   OF tkomcon.
66
67     TYPES: BEGIN OF intab1 .
68             INCLUDE STRUCTURE tline.
69     TYPES: END OF intab1.
70     DATA BEGIN OF it_name OCCURS 0 .
71             INCLUDE STRUCTURE tline.
72     DATA END OF it_name.
73
74     DATA: intab      TYPE intab1 OCCURS 10  WITH HEADER LINE,
75           it_supply  TYPE intab1 OCCURS 10  WITH HEADER LINE,
76           it_sign    TYPE intab1 OCCURS 10  WITH HEADER LINE,
77           it_vessel  TYPE intab1 OCCURS 10  WITH HEADER LINE,
78           it_comment TYPE intab1 OCCURS 10  WITH HEADER LINE,
79           textab     TYPE intab1 OCCURS 10  WITH HEADER LINE,
80           ist_lipso2 LIKE lipso2 OCCURS 0 WITH HEADER LINE.
81
82     ***********************************************************************
83     * Definition of internal variables                                    *
84     ***********************************************************************
85
86     DATA: retcode   LIKE sy-subrc.         "Returncode
87     DATA: repeat(1) TYPE c.
88     DATA: xscreen(1) TYPE c.               "Output on printer or screen
89     DATA: pr_kappl(01)   TYPE c VALUE 'V'. "Application for pricing
90     DATA: print_mwskz.                     "Mehrwertsteuer-Kz drucken
91
92     ***********************************************************************
93     * Definition of variables for calling customer subroutines dynamically*
94     ***********************************************************************
95
96     DATA : header_userexit       LIKE tnapr-ronam,
97            item_userexit         LIKE tnapr-ronam,
98            header_print_userexit LIKE tnapr-ronam,
99            item_print_userexit   LIKE tnapr-ronam,
100           get_data_userexit     LIKE tnapr-ronam.
101
102
103
104    **********************************************************************
105    *TYPES
106    **********************************************************************
107    DATA print_local_curr_ch.
108    DATA: komvdk_ch LIKE komvd OCCURS 10 WITH HEADER LINE.
109    DATA: komvdp_ch LIKE komvd OCCURS 10 WITH HEADER LINE.
110    counter1 = 0.
111    tabix = 0.
112    DATA:  total1        LIKE tkomvd-kwert,
113           t_fkimg       LIKE vbdpr-fkimg,
114           zocr(1),
115           jmod(1),
116           zin1(1),
117           zin2(1),
118           zin4(1),
119           zin5(1),
120           zin6(1),
121           zscg(1),
122           zfrt(1),
123           zasv(1),
124           zaed(1),
125           zedc(1),
126           jecx(1),
127           jces(1),
128           jmod_kbetr    LIKE komvd-kbetr , "(6) type p decimals 3,
129           zocr_kbetr(6) TYPE p DECIMALS 2,
130           g_cmpre(8)    TYPE p DECIMALS 3,
131           g_cmpre1(8)   TYPE p DECIMALS 3,
132           g_fk_mg       LIKE vbrp-fkimg,
133           g_br_mg       LIKE vbrp-brgew,  "MGO Qty
134           g_flg_mg,                   "MGO Flag
135           zin1_kbetr    LIKE  jmod_kbetr,
136           zin2_kbetr    LIKE  jmod_kbetr,
137           zin4_kbetr    LIKE  jmod_kbetr,
138           zin5_kbetr    LIKE  jmod_kbetr,
139           zin6_kbetr    LIKE  jmod_kbetr,
140           cess_kbetr    LIKE  jmod_kbetr,
141           excise_kbetr  LIKE  jmod_kbetr,
142           educess_kbetr LIKE  jmod_kbetr,
143           zintotal      LIKE tkomv-kwert,
144           zdif          LIKE tkomv-kwert,
145           jmodtotal     LIKE tkomv-kwert,
146           tot_zasv      LIKE tkomvd-kwert,
147           tot_zfrt      LIKE tkomvd-kwert,
148           tot_zscg      LIKE tkomvd-kwert,
149           total2        LIKE tkomvd-kwert,
150           tot_edr       LIKE tkomvd-kwert,
151           tot_ocr       LIKE tkomvd-kwert,
152           tot_zin       LIKE tkomvd-kwert,
153           val_zin1      LIKE tkomvd-kwert,
154           val_zin4      LIKE tkomvd-kwert,
155           val_zin5      LIKE tkomvd-kwert,
156           val_zin6      LIKE tkomvd-kwert,
157           val_zin2      LIKE tkomvd-kwert,
158           val_cess      LIKE tkomvd-kwert,
159           val_excise    LIKE tkomvd-kwert,
160           val_educess   LIKE tkomvd-kwert,
161           poscnt1       TYPE i VALUE 0,
162           wrk_tabix     LIKE sy-tabix,
163           g_fkimg       LIKE tvbdpr-fkimg,
164           g_kzwi1       LIKE tvbdpr-kzwi1,
165           g_volum       LIKE tvbdpr-volum,
166           g_pr01flag.
167
168
169    DATA:  period(38),
170           count1(3),
171           count2(3),
172           count3(3),
173           count4(3),
174           count5(3),
175           count6(3),
176           sign(30),
177           vessel(30),
178           iecno(30),
179           refno(30),
180           count7(3),
181           count8(3),
182           count9(3),
183           count10(3),
184           count11(3),
185           count12(3),
186           count13(3),
187           comments(30),
188           text6(40),
189           text7(40),
190           text8(40),
191           text9(40),
192           text10(40),
193           text11(35),
194           countsko(3),
195           roundoff     LIKE komv-kwert,
196           tempdate     LIKE sy-datum,
197           dtyp         LIKE vbdkr-vbtyp,
198           kls          LIKE lipso2-adqntp,
199           kln          LIKE lipso2-adqntp,
200           lto          LIKE lipso2-adqntp,
201           bb6          LIKE lipso2-adqntp,
202           ug6          LIKE lipso2-adqntp,
203           g_hzr_flg,
204           region       LIKE t005u-bezei,
205           street2,
206           street3,
207           street4,
208           g_ocountry   LIKE t005t-landx,
209           g_ocountry1  LIKE t005t-landx,
210           dest(20),
211           sorg(10),
212           len(3),
213           len1(3),
214           word1(36),
215           word2(36),
216           wordcurr(12),
217           l_kpein      LIKE komv-kpein.
218
219
220    ***********************************************************************
221    *
222    *                                                                     *
223    * Standard Routine ENTRY                                              *
224    *                                                                     *
225    ***********************************************************************
226    TABLES: t685t,
227            t005u,
228            lipso2,
229            adrc,
230            j_1imocomp,
231            eikp,  "#EC CI_USAGE_OK[2223144]
232            eipo,  "#EC CI_USAGE_OK[2223144]
233            t005t,
234            t615t.
235    *---------------------------------------------------------------------*
236    *       FORM entry                                                    *
237    *---------------------------------------------------------------------*
238    *       ........                                                      *
239    *---------------------------------------------------------------------*
240    *  -->  RETURN_CODE                                                   *
241    *  -->  US_SCREEN                                                     *
242    *---------------------------------------------------------------------*
243    FORM entry USING return_code us_screen.
244      CLEAR retcode.
245      xscreen = us_screen.
246      PERFORM processing USING us_screen.
247      CASE retcode.
248        WHEN 0.
249          return_code = 0.
250        WHEN 3.
251          return_code = 3.
252        WHEN OTHERS.
253          return_code = 1.
254      ENDCASE.
255
256    ENDFORM.
257
258    ***********************************************************************
259    *                                                                     *
260    * Standard Routine ENTRY_ESR                                          *
261    *                                                                     *
262    ***********************************************************************
263
264    FORM entry_esr USING return_code us_screen.
265
266      CLEAR retcode.
267      xscreen = us_screen.
268      PERFORM processing_esr USING us_screen.
269      CASE retcode.
270        WHEN 0.
271          return_code = 0.
272        WHEN 3.
273          return_code = 3.
274        WHEN OTHERS.
275          return_code = 1.
276      ENDCASE.
277
278    ENDFORM.
279
280    ***********************************************************************
281    *                                                                     *
282    * Standard Routine ENTRY_ITALY                                        *
283    *                                                                     *
284    ***********************************************************************
285
286    FORM entry_italy USING return_code us_screen.
287
288      CLEAR retcode.
289      xscreen = us_screen.
290      PERFORM processing_italy USING us_screen.
291      CASE retcode.
292        WHEN 0.
293          return_code = 0.
294        WHEN 3.
295          return_code = 3.
296        WHEN OTHERS.
297          return_code = 1.
298      ENDCASE.
299
300    ENDFORM.
301
302    ***********************************************************************
303    *                                                                     *
304    * Standard Routine ENTRY_CH                                           *
305    *                                                                     *
306    ***********************************************************************
307
308    FORM entry_ch USING return_code us_screen.
309      CLEAR retcode.
310      xscreen = us_screen.
311      header_userexit = 'HEADER_CH'.
312      item_userexit = 'ITEM_CH'.
313      header_print_userexit = 'HEADER_PRINT_CH'.
314      item_print_userexit = 'ITEM_PRINT_CH'.
315      PERFORM processing USING us_screen.
316      CASE retcode.
317        WHEN 0.
318          return_code = 0.
319        WHEN 3.
320          return_code = 3.
321        WHEN OTHERS.
322          return_code = 1.
323      ENDCASE.
324    ENDFORM.
325
326    ***********************************************************************
327    *                                                                     *
328    * Customer Entry-Routines                                             *
329    *                                                                     *
330    ***********************************************************************
331
332
333
334    ***********************************************************************
335    *                                                                     *
336    * Standard Routine PROCESSING                                         *
337    *                                                                     *
338    ***********************************************************************
339
340    FORM processing USING proc_screen.
341      PERFORM get_data.
342      CHECK retcode = 0.
343      SELECT * FROM lipso2 INTO TABLE ist_lipso2 WHERE vbeln =
344    vbdkr-vbeln_vl.
345              DATA lv_exnum TYPE exnum.
346    "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
347
348          SELECT SINGLE exnum
349            FROM vbrk
350            INTO @lv_exnum
351            WHERE vbeln = @vbdkr-vbeln.
352
353    *  SELECT SINGLE * FROM eikp WHERE exnum = vbdkr-exnum.
354      SELECT SINGLE * FROM eikp WHERE exnum = lv_exnum. "#EC CI_USAGE_OK[2223144]
355      SELECT SINGLE * FROM t005t WHERE land1 = eikp-stgbe "#EC CI_USAGE_OK[2223144]
356                                   AND spras = 'EN'.
357      CONCATENATE eikp-kzgbe ' ' t005t-landx INTO dest. "#EC CI_USAGE_OK[2223144]
358      SELECT SINGLE * FROM t005t WHERE land1 = eikp-aland  "#EC CI_USAGE_OK[2223144]
359                                   AND spras = 'EN'.
360      g_ocountry = t005t-landx.
361    *  SELECT SINGLE * FROM eipo WHERE exnum = vbdkr-exnum.
362      SELECT SINGLE * FROM eipo WHERE exnum = lv_exnum. "#EC CI_USAGE_OK[2223144]
363    "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
364      SELECT SINGLE * FROM t005t WHERE land1 = eikp-lazl1 "#EC CI_USAGE_OK[2223144]
365                                   AND spras = 'EN'.
366      g_ocountry1 = t005t-landx.
367      SELECT SINGLE * FROM t615t WHERE spras = 'EN'
368                                   AND land1 = 'IN'
369                                   AND zolla = eikp-zolla. "#EC CI_USAGE_OK[2223144]
370
371      LOOP AT ist_lipso2.
372        CASE ist_lipso2-msehi.
373          WHEN 'KLS'.
374            kls = ist_lipso2-adqntp.
375          WHEN 'KLN'.
376            kln = ist_lipso2-adqntp.
377          WHEN 'LTO'.
378            lto = ist_lipso2-adqntp.
379          WHEN 'BB6'.
380            bb6 = ist_lipso2-adqntp.
381          WHEN 'UG6'.
382            ug6 = ist_lipso2-adqntp.
383        ENDCASE.
384      ENDLOOP.
385      pname = vbdkr-vbeln.
386      CALL FUNCTION 'READ_TEXT'
387        EXPORTING
388          client                  = sy-mandt
389          id                      = 'ZSHP'
390          language                = sy-langu
391          name                    = pname
392          object                  = 'VBBK'
393        TABLES
394          lines                   = it_vessel
395        EXCEPTIONS
396          id                      = 1
397          language                = 2
398          name                    = 3
399          not_found               = 4
400          object                  = 5
401          reference_check         = 6
402          wrong_access_to_archive = 7
403          OTHERS                  = 8.
404      IF sy-subrc NE 0.
405        PERFORM protocol_update.
406      ENDIF.
407
408
409      IF sy-subrc = 0.
410        READ TABLE it_vessel INDEX 1.
411        IF sy-subrc = 0.
412          vessel = it_vessel-tdline.
413        ENDIF.
414      ENDIF.
415
416      CALL FUNCTION 'READ_TEXT'
417        EXPORTING
418          client                  = sy-mandt
419          id                      = 'Z002'
420          language                = sy-langu
421          name                    = pname
422          object                  = 'VBBK'
423        TABLES
424          lines                   = it_sign
425        EXCEPTIONS
426          id                      = 1
427          language                = 2
428          name                    = 3
429          not_found               = 4
430          object                  = 5
431          reference_check         = 6
432          wrong_access_to_archive = 7
433          OTHERS                  = 8.
434      IF sy-subrc NE 0.
435        PERFORM protocol_update.
436      ENDIF.
437
438
439      IF sy-subrc = 0.
440        READ TABLE it_sign INDEX 1.
441        IF sy-subrc = 0.
442          iecno = it_sign-tdline.
443        ENDIF.
444      ENDIF.
445
446      REFRESH it_sign.
447      CLEAR pname.
448      PERFORM form_open USING proc_screen vbdkr-land1.
449      CHECK retcode = 0.
450      PERFORM form_title_print.
451      CHECK retcode = 0.
452      PERFORM header_consgnee.
453      CHECK retcode = 0.
454      PERFORM reference_number.
455      CHECK retcode = 0.
456      PERFORM get_fkwrt.
457
458      IF vbdkr-vkorg = 'URNS'.
459        READ TABLE tkomv WITH KEY kschl = 'PR01'.
460        IF sy-subrc = 0.
461          g_pr01flag = 'X'.
462          fkwrt = komk-fkwrt.
463          WRITE komk-fkwrt TO fkwrt1 CURRENCY reguh-waers.
464          CONDENSE fkwrt1.
465        ELSE.
466          IF vbdkr-vtweg = 'RD'.
467            komk-fkwrt = komk-fkwrt - zintotal.
468            fkwrt = komk-fkwrt.
469
470            WRITE komk-fkwrt TO fkwrt1 CURRENCY reguh-waers.
471            CONDENSE fkwrt1.
472          ELSE.
473            fkwrt = komk-fkwrt.
474            WRITE komk-fkwrt TO fkwrt1 CURRENCY reguh-waers.
475            CONDENSE fkwrt1.
476          ENDIF.
477        ENDIF.
478      ELSE.
479        fkwrt = komk-fkwrt.
480        WRITE komk-fkwrt TO fkwrt1 CURRENCY reguh-waers.
481        CONDENSE fkwrt1.
482      ENDIF.
483
484      CALL FUNCTION 'ZFI_AMT_WRDS_CONVERT'
485        EXPORTING
486          amt    = fkwrt1
487          curren = komk-waerk
488        IMPORTING
489          word   = word
490        EXCEPTIONS
491          OTHERS = 1.
492      IF sy-subrc NE 0.
493        PERFORM protocol_update.
494      ENDIF.
495      CONDENSE word.
496      TRANSLATE word TO LOWER CASE.
497
498
499      len1 = strlen( word ).
500      IF komk-waerk = 'INR'.
501        wordcurr = word+0(7).
502        len1 = len1 - 7.
503        word = word+7(len1).
504        TRANSLATE word+6(1) TO UPPER CASE.
505      ELSEIF komk-waerk = 'USD'.
506        TRANSLATE word+10(1) TO UPPER CASE.
507        wordcurr = word+0(10).
508        len1 = len1 - 10.
509        word = word+10(len1).
510      ENDIF.
511
512      TRANSLATE wordcurr TO UPPER CASE.
513      CONCATENATE wordcurr ':' word INTO word.
514    *  len = strlen( word ).
515    *  if len > 35.
516    *    word1 = word+37(36).
517    *    endif.
518    *  if len > 74.
519    *    word2 = word+73(len).
520    *  endif.
521
522
523      CONDENSE word.
524      SELECT SINGLE * FROM stxh WHERE tdobject = 'VBBK'
525             AND tdid = '0002' AND
526             tdspras = 'E' AND
527             tdname = vbdkr-vbeln.
528      GET PARAMETER ID 'VF' FIELD vbeln.
529      SELECT SINGLE * FROM vbrk WHERE vbeln = vbeln.
530      pname = vbrk-vbeln.
531      CALL FUNCTION 'READ_TEXT'
532        EXPORTING
533          client                  = sy-mandt
534          id                      = '0001'
535          language                = stxh-tdspras
536          name                    = pname
537          object                  = 'VBBK'
538        IMPORTING
539          header                  = phead
540        TABLES
541          lines                   = intab
542        EXCEPTIONS
543          id                      = 1
544          language                = 2
545          name                    = 3
546          not_found               = 4
547          object                  = 5
548          reference_check         = 6
549          wrong_access_to_archive = 7
550          OTHERS                  = 8.
551      IF sy-subrc NE 0.
552        PERFORM protocol_update.
553      ENDIF.
554      CLEAR pname.
555      CONCATENATE vbdkr-vbeln tvbdpr-posnr INTO pname.
556      CALL FUNCTION 'READ_TEXT'
557        EXPORTING
558          client                  = sy-mandt
559          id                      = '0001'
560          language                = sy-langu
561          name                    = pname
562          object                  = 'VBBP'
563        TABLES
564          lines                   = it_supply
565        EXCEPTIONS
566          id                      = 1
567          language                = 2
568          name                    = 3
569          not_found               = 4
570          object                  = 5
571          reference_check         = 6
572          wrong_access_to_archive = 7
573          OTHERS                  = 8.
574      IF sy-subrc NE 0.
575        PERFORM protocol_update.
576      ENDIF.
577
578
579      IF sy-subrc = 0.
580        READ TABLE it_supply INDEX 1.
581        IF sy-subrc = 0.
582          period = it_supply-tdline.
583        ENDIF.
584      ENDIF.
585      pname = vbdkr-vbeln.
586      CALL FUNCTION 'READ_TEXT'
587        EXPORTING
588          client                  = sy-mandt
589          id                      = 'ZPTT'
590          language                = sy-langu
591          name                    = pname
592          object                  = 'VBBK'
593        IMPORTING
594          header                  = phead
595        TABLES
596          lines                   = textab
597        EXCEPTIONS
598          id                      = 1
599          language                = 2
600          name                    = 3
601          not_found               = 4
602          object                  = 5
603          reference_check         = 6
604          wrong_access_to_archive = 7
605          OTHERS                  = 8.
606      IF sy-subrc NE 0.
607        PERFORM protocol_update.
608      ENDIF.
609
610      IF sy-subrc = 0.
611        READ TABLE textab INDEX 1.
612        IF sy-subrc = 0.
613          text6 = textab-tdline.
614        ENDIF.
615        READ TABLE textab INDEX 2.
616        IF sy-subrc = 0.
617          text7 = textab-tdline.
618        ENDIF.
619        READ TABLE textab INDEX 3.
620        IF sy-subrc = 0.
621          text8 = textab-tdline.
622        ENDIF.
623        READ TABLE textab INDEX 4.
624        IF sy-subrc = 0.
625          text9 = textab-tdline.
626        ENDIF.
627        READ TABLE textab INDEX 5.
628        IF sy-subrc = 0.
629          text10 = textab-tdline.
630        ENDIF.
631
632        READ TABLE textab INDEX 6.
633        IF sy-subrc = 0.
634          text11 = textab-tdline.
635        ENDIF.
636
637      ENDIF.
638
639      CALL FUNCTION 'READ_TEXT'
640        EXPORTING
641          client                  = sy-mandt
642          id                      = 'ZREF'
643          language                = sy-langu
644          name                    = pname
645          object                  = 'VBBK'
646        TABLES
647          lines                   = it_sign
648        EXCEPTIONS
649          id                      = 1
650          language                = 2
651          name                    = 3
652          not_found               = 4
653          object                  = 5
654          reference_check         = 6
655          wrong_access_to_archive = 7
656          OTHERS                  = 8.
657      IF sy-subrc NE 0.
658        PERFORM protocol_update.
659      ENDIF.
660
661
662      IF sy-subrc = 0.
663        READ TABLE it_sign INDEX 1.
664        IF sy-subrc = 0.
665          refno = it_sign-tdline.
666        ENDIF.
667      ENDIF.
668      dtyp = vbdkr-vbtyp.
669      TRANSLATE dtyp TO UPPER CASE.
670      IF dtyp = 'O'.
671        text_element = 'CREDIT_MEMO'.
672      ELSEIF dtyp = 'P'.
673        text_element = 'DEBIT_MEMO'.
674      ELSEIF dtyp = 'M'.
675        text_element = 'INVOICE'.
676      ENDIF.
677      SELECT SINGLE * FROM vbrp WHERE vbeln = vbeln
678                                  AND posnr = tvbdpr-posnr.
679      augru = vbrp-augru_auft.
680      mdesc = vbrp-arktx.
681      SELECT SINGLE * FROM t001w WHERE werks = vbrp-werks.   "plants
682      SELECT SINGLE * FROM vbak WHERE vbeln = vbrp-vbeln.
683      SELECT SINGLE * FROM tvtwt WHERE vtweg = vbdkr-vtweg AND spras = 'EN'.
684      " ditribution channel
685      SELECT SINGLE * FROM t005u WHERE spras = 'EN' AND land1 = 'IN' AND
686      bland = vbdkr-regio_we.
687      region = t005u-bezei.
688      SELECT SINGLE * FROM t005u WHERE spras = 'EN' AND land1 = 'IN' AND
689      bland = vbdkr-regio.
690      SELECT SINGLE * FROM tvaut WHERE augru = augru
691      AND spras = 'EN'.                     "order reason
692      PERFORM tax_text_print USING text_element.
693      CHECK retcode = 0.
694      PERFORM header_data_print.
695      CHECK retcode = 0.
696      SELECT SINGLE * FROM vbrk WHERE vbeln = vbeln.
697      zterm = vbrk-zterm.
698      SELECT SINGLE * FROM t052 WHERE zterm = zterm.  " payment terms
699      SELECT SINGLE * FROM j_1imocomp WHERE bukrs = vbdkr-bukrs
700                                        AND werks = vbrp-werks.
701
702      PERFORM header_text_print.
703      CHECK retcode = 0.
704      tempdate = vbdkr-fkdat.
705      PERFORM item_print.
706      CHECK retcode = 0.
707      PERFORM form_close.
708      CHECK retcode = 0.
709
710    ENDFORM.
711
712    ***********************************************************************
713    *                                                                     *
714    * Standard Routine PROCESSING_ESR                                     *
715    *                                                                     *
716    ***********************************************************************
717
718    FORM processing_esr USING proc_screen.
719
720      PERFORM get_data.
721      PERFORM get_data_esr.
722      CHECK retcode = 0.
723      PERFORM form_open USING proc_screen vbdkr-land1.
724      CHECK retcode = 0.
725      PERFORM start_form.
726      CHECK retcode = 0.
727      CHECK retcode = 0.
728      CHECK retcode = 0.
729      PERFORM item_print.
730      CHECK retcode = 0.
731      PERFORM end_print.
732      CHECK retcode = 0.
733      PERFORM form_close.
734      CHECK retcode = 0.
735
736    ENDFORM.
737
738    ***********************************************************************
739    *                                                                     *
740    * Standard Routine PROCESSING_ITALY                                   *
741    *                                                                     *
742    ***********************************************************************
743
744    FORM processing_italy USING proc_screen.
745
746      PERFORM get_data.
747      PERFORM get_data_italy USING proc_screen.
748      CHECK retcode = 0.
749      PERFORM form_open USING proc_screen vbdkr-land1.
750      CHECK retcode = 0.
751      PERFORM form_title_print.
752      CHECK retcode = 0.
753      PERFORM header_consgnee.
754      CHECK retcode = 0.
755      PERFORM reference_number.
756      CHECK retcode = 0.
757      PERFORM tax_text_print USING text_element.
758      CHECK retcode = 0.
759      PERFORM header_data_print.
760      CHECK retcode = 0.
761      PERFORM header_text_print.
762      CHECK retcode = 0.
763      PERFORM item_print.
764      CHECK retcode = 0.
765      PERFORM end_print.
766      CHECK retcode = 0.
767      PERFORM form_close.
768      CHECK retcode = 0.
769
770    ENDFORM.
771
772    ***********************************************************************
773    *       SAP STANDARD-SUBROUTINES                                      *
774    ***********************************************************************
775
776    *---------------------------------------------------------------------*
777    *       FORM AMOUNT_FOR_CASH_DISCOUNT                                 *
778    *---------------------------------------------------------------------*
779    *       This routine prints the amount qualifying for cash discount.  *
780    *---------------------------------------------------------------------*
781
782    FORM amount_for_cash_discount.
783
784      CHECK vbdkr-skfbk NE 0.
785      CALL FUNCTION 'WRITE_FORM'
786        EXPORTING
787          element = 'AMOUNT_QUALIFYING_FOR_CASH_DISCOUNT'
788        EXCEPTIONS
789          element = 1
790          window  = 2.
791      IF sy-subrc NE 0.
792        PERFORM protocol_update.
793      ENDIF.
794
795    ENDFORM.
796
797    *---------------------------------------------------------------------*
798    *       FORM PAYMENT_SPLIT                                            *
799    *---------------------------------------------------------------------*
800    *       This routine prints the payment split                         *
801    *---------------------------------------------------------------------*
802    FORM payment_split.
803
804      DATA: h_skfbt LIKE acccr-skfbt.
805      DATA: h_fkdat LIKE vbrk-fkdat.
806      DATA: h_fkwrt LIKE acccr-wrbtr.
807      DATA : BEGIN OF payment_split OCCURS 3.
808              INCLUDE STRUCTURE vtopis.
809      DATA : END OF payment_split.
810
811
812      CHECK vbdkr-zterm NE space.
813
814      h_skfbt = vbdkr-skfbk.
815      h_fkwrt = komk-fkwrt.
816      h_fkdat = vbdkr-fkdat.
817      IF vbdkr-valdt NE 0.
818        h_fkdat = vbdkr-valdt.
819      ENDIF.
820      IF vbdkr-valtg NE 0.
821        h_fkdat = vbdkr-fkdat + vbdkr-valtg.
822      ENDIF.
823      CALL FUNCTION 'SD_PRINT_TERMS_OF_PAYMENT_SPLI'
824        EXPORTING
825          bldat                         = vbdkr-fkdat
826          budat                         = h_fkdat
827          cpudt                         = vbdkr-erdat
828          language                      = vbco3-spras
829          terms_of_payment              = vbdkr-zterm
830          wert                          = h_fkwrt  "Warenwert + Tax
831          waerk                         = vbdkr-waerk
832          fkdat                         = vbdkr-fkdat
833          skfbt                         = h_skfbt
834        TABLES
835          top_text_split                = payment_split
836        EXCEPTIONS
837          terms_of_payment_not_in_t052  = 01
838          terms_of_payment_not_in_t052s = 02.
839      IF sy-subrc NE 0.
840        PERFORM protocol_update.
841      ENDIF.
842
843
844      LOOP AT payment_split.
845
846        AT FIRST.
847          CALL FUNCTION 'CONTROL_FORM'
848            EXPORTING
849              command = 'PROTECT'.
850          CALL FUNCTION 'WRITE_FORM'
851            EXPORTING
852              element = 'TERMS_OF_PAYMENT_SPLIT_HEADER'.
853        ENDAT.
854
855        vbdkr-text = payment_split-line.
856        CALL FUNCTION 'WRITE_FORM'
857          EXPORTING
858            element = 'TERMS_OF_PAYMENT_SPLIT'
859          EXCEPTIONS
860            element = 1
861            window  = 2.
862        IF sy-subrc NE 0.
863          PERFORM protocol_update.
864        ENDIF.
865
866        AT LAST.
867          CALL FUNCTION 'CONTROL_FORM'
868            EXPORTING
869              command = 'ENDPROTECT'.
870        ENDAT.
871
872      ENDLOOP.
873
874    ENDFORM.
875
876    *---------------------------------------------------------------------*
877    *       FORM CHECK_REPEAT                                             *
878    *---------------------------------------------------------------------*
879    *       A text is printed, if it is a repeat print for the document.  *
880    *---------------------------------------------------------------------*
881
882    FORM check_repeat.
883
884      CLEAR repeat.
885      SELECT * INTO *nast FROM nast WHERE kappl = nast-kappl
886                                    AND   objky = nast-objky
887                                    AND   kschl = nast-kschl
888                                    AND   spras = nast-spras
889                                    AND   parnr = nast-parnr
890                                    AND   parvw = nast-parvw
891                                    AND   nacha BETWEEN '1' AND '4'.
892        CHECK *nast-vstat = '1'.
893        repeat = 'X'.
894        EXIT.   "#EC CI_NOORDER
895      ENDSELECT.
896
897    ENDFORM.
898
899    *---------------------------------------------------------------------*
900    *       FORM DIFFERENT_CONSIGNEE                                      *
901    *---------------------------------------------------------------------*
902    *       If the consignee in the item is different to the header con-  *
903    *       signee, it is printed by this routine.                        *
904    *---------------------------------------------------------------------*
905
906    FORM different_consignee.
907
908      CHECK vbdkr-name1_we NE vbdpr-name1_we
909        OR  vbdkr-name2_we NE vbdpr-name2_we
910        OR  vbdkr-name3_we NE vbdpr-name3_we
911        OR  vbdkr-name4_we NE vbdpr-name4_we.
912      CHECK vbdpr-name1_we NE space
913        OR  vbdpr-name2_we NE space
914        OR  vbdpr-name3_we NE space
915        OR  vbdpr-name4_we NE space.
916      CALL FUNCTION 'WRITE_FORM'
917        EXPORTING
918          element = 'ITEM_CONSIGNEE'
919        EXCEPTIONS
920          element = 1
921          window  = 2.
922      IF sy-subrc NE 0.
923        PERFORM protocol_update.
924      ENDIF.
925
926    ENDFORM.
927
928    *---------------------------------------------------------------------*
929    *       FORM DIFFERENT_DELIVERY_NO                                    *
930    *---------------------------------------------------------------------*
931    *       If the delivery number is different to number in the header,  *
932    *       it is printed by this routine.                                *
933    *---------------------------------------------------------------------*
934
935    FORM different_delivery_no.
936
937      CHECK vbdkr-vbtyp CA 'MUN'.
938      CHECK vbdpr-vbeln_vl NE vbdpr-vbeln_vauf.
939      CHECK vbdkr-vbeln_vl NE vbdpr-vbeln_vl.
940      CALL FUNCTION 'WRITE_FORM'
941        EXPORTING
942          element = 'ITEM_DELIVERY_NO'
943        EXCEPTIONS
944          element = 1
945          window  = 2.
946      IF sy-subrc NE 0.
947        PERFORM protocol_update.
948      ENDIF.
949
950    ENDFORM.
951
952    *---------------------------------------------------------------------*
953    *       FORM DIFFERENT_ORDER_NO                                       *
954    *---------------------------------------------------------------------*
955    *       If the order number is different to number in the header,     *
956    *       it is printed by this routine.                                *
957    *---------------------------------------------------------------------*
958
959    FORM different_order_no.
960
961      CHECK vbdkr-vbtyp CA 'MUN'.
962      CHECK vbdkr-vbeln_vauf NE vbdpr-vbeln_vauf.
963      CALL FUNCTION 'WRITE_FORM'
964        EXPORTING
965          element = 'ITEM_ORDER_NO'
966        EXCEPTIONS
967          element = 1
968          window  = 2.
969      IF sy-subrc NE 0.
970        PERFORM protocol_update.
971      ENDIF.
972
973    ENDFORM.
974
975    *---------------------------------------------------------------------*
976    *       FORM DIFFERENT_EXTERN_NO                                      *
977    *---------------------------------------------------------------------*
978    *       If the extern number is different to number in the header,    *
979    *       it is printed by this routine.                                *
980    *---------------------------------------------------------------------*
981
982    FORM different_extern_no.
983
984      CHECK vbdkr-vbtyp CA 'MUN'.
985      CHECK vbdkr-vbeln_vauf EQ space.
986      CHECK vbdkr-vbeln_vl   EQ space.
987      CHECK vbdpr-vbeln_vauf EQ space.
988      CHECK vbdpr-vbeln_vl   EQ space.
989      CHECK vbdkr-vgbel NE vbdpr-vgbel.
990      CALL FUNCTION 'WRITE_FORM'
991        EXPORTING
992          element = 'ITEM_EXTERN_NO'
993        EXCEPTIONS
994          element = 1
995          window  = 2.
996      IF sy-subrc NE 0.
997        PERFORM protocol_update.
998      ENDIF.
999
1000   ENDFORM.
1001   *---------------------------------------------------------------------*
1002   *       FORM DIFFERENT_PURCHASE_ORDER_NO                              *
1003   *---------------------------------------------------------------------*
1004   *       If the purchase order number is different to number in the    *
1005   *       header, it is printed by this routine.                        *
1006   *---------------------------------------------------------------------*
1007
1008   FORM different_purchase_order_no.
1009
1010     CHECK vbdkr-vbtyp CA 'MUN'.
1011     CHECK vbdkr-bstnk NE vbdpr-bstnk
1012       OR  vbdkr-bstdk NE vbdpr-bstdk.
1013     CALL FUNCTION 'WRITE_FORM'
1014       EXPORTING
1015         element = 'ITEM_PURCHASE_ORDER_NO'
1016       EXCEPTIONS
1017         element = 1
1018         window  = 2.
1019     IF sy-subrc NE 0.
1020       PERFORM protocol_update.
1021     ENDIF.
1022
1023   ENDFORM.
1024
1025   *---------------------------------------------------------------------*
1026   *       FORM END_PRINT                                                *
1027   *---------------------------------------------------------------------*
1028   *                                                                     *
1029   *---------------------------------------------------------------------*
1030
1031   FORM end_print.
1032
1033     CALL FUNCTION 'CONTROL_FORM'
1034       EXPORTING
1035         command = 'PROTECT'.
1036     PERFORM header_price_print.
1037   * Begin of  <RD1K960611>
1038   *  break cab_sudhir.
1039   * End of    <RD1K960611>
1040     fkwrt = g_pp1_kwert + komk-fkwrt .
1041     CALL FUNCTION 'Y_FI_AMT_WRDS_CONVERT'
1042       EXPORTING
1043         amt    = fkwrt
1044       IMPORTING
1045         word   = word
1046       EXCEPTIONS
1047         OTHERS = 1.
1048     IF sy-subrc NE 0.
1049       PERFORM protocol_update.
1050     ENDIF.
1051
1052     CALL FUNCTION 'CONTROL_FORM'
1053       EXPORTING
1054         command = 'ENDPROTECT'.
1055
1056
1057   ENDFORM.
1058
1059   *---------------------------------------------------------------------*
1060   *       FORM FORM_CLOSE                                               *
1061   *---------------------------------------------------------------------*
1062   *       End of printing the form                                      *
1063   *---------------------------------------------------------------------*
1064
1065   FORM form_close.
1066
1067     CALL FUNCTION 'CLOSE_FORM'
1068       EXCEPTIONS
1069         OTHERS = 1.
1070     IF sy-subrc NE 0.
1071       retcode = sy-subrc.
1072       PERFORM protocol_update.
1073     ENDIF.
1074     CLEAR g_fkimg.
1075     CLEAR : g_hzr_flg,g_kzwi1.
1076     CLEAR vbdkr-vbeln.
1077   * Change on dated 10 October 2003 at 6 PM
1078     REFRESH :  tvbdpr.
1079     CLEAR : vbdpr,
1080             g_fk_mg,
1081             g_br_mg.
1082
1083     REFRESH :             tkomv.
1084     REFRESH :             tkomvd.
1085     REFRESH :             hkomvd.
1086     REFRESH :             tkomcon.
1087     SET COUNTRY space.
1088
1089   ENDFORM.
1090
1091   *----------------------------------------------------?----------------*
1092   *       FORM FORM_OPEN                                                *
1093   *---------------------------------------------------------------------*
1094   *       Start of printing the form                                    *
1095   *---------------------------------------------------------------------*
1096   *  -->  US_SCREEN  Output on screen                                   *
1097   *                  ' ' = Printer                                      *
1098   *                  'X' = Screen                                       *
1099   *  -->  US_COUNTRY County for telecommunication and SET COUNTRY       *
1100   *---------------------------------------------------------------------*
1101
1102   FORM form_open USING us_screen us_country.
1103
1104     INCLUDE zsd_invoice_vaexpp_dp_rvadopg.
1105   *  INCLUDE zsd_invoice_vap_dp_rvadopg.
1106
1107   ENDFORM.
1108
1109   *---------------------------------------------------------------------*
1110   *       FORM FORM_TITLE_PRINT                                         *
1111   *---------------------------------------------------------------------*
1112   *       Printing of the form title depending of the field VBTYP       *
1113   *---------------------------------------------------------------------*
1114
1115   FORM form_title_print.
1116     dtyp = vbdkr-vbtyp.
1117     CASE dtyp.
1118       WHEN 'M'.
1119         CALL FUNCTION 'WRITE_FORM'
1120           EXPORTING
1121             element = 'TITLE_M'
1122             window  = 'TITLE'
1123           EXCEPTIONS
1124             element = 1
1125             window  = 2.
1126         IF sy-subrc NE 0.
1127           PERFORM protocol_update.
1128         ENDIF.
1129       WHEN 'N'.
1130         CALL FUNCTION 'WRITE_FORM'
1131           EXPORTING
1132             element = 'TITLE_N'
1133             window  = 'TITLE'
1134           EXCEPTIONS
1135             element = 1
1136             window  = 2.
1137         IF sy-subrc NE 0.
1138           PERFORM protocol_update.
1139         ENDIF.
1140       WHEN 'O'.
1141         CALL FUNCTION 'WRITE_FORM'
1142           EXPORTING
1143             element = 'TITLE_O'
1144             window  = 'TITLE'
1145           EXCEPTIONS
1146             element = 1
1147             window  = 2.
1148         IF sy-subrc NE 0.
1149           PERFORM protocol_update.
1150         ENDIF.
1151       WHEN 'P'.
1152         CALL FUNCTION 'WRITE_FORM'
1153           EXPORTING
1154             element = 'TITLE_P'
1155             window  = 'TITLE'
1156           EXCEPTIONS
1157             element = 1
1158             window  = 2.
1159         IF sy-subrc NE 0.
1160           PERFORM protocol_update.
1161         ENDIF.
1162       WHEN 'S'.
1163         CALL FUNCTION 'WRITE_FORM'
1164           EXPORTING
1165             element = 'TITLE_S'
1166             window  = 'TITLE'
1167           EXCEPTIONS
1168             element = 1
1169             window  = 2.
1170         IF sy-subrc NE 0.
1171           PERFORM protocol_update.
1172         ENDIF.
1173
1174       WHEN 'U'.
1175         CALL FUNCTION 'WRITE_FORM'
1176           EXPORTING
1177             element = 'TITLE_U'
1178             window  = 'TITLE'
1179           EXCEPTIONS
1180             element = 1
1181             window  = 2.
1182         IF sy-subrc NE 0.
1183           PERFORM protocol_update.
1184         ENDIF.
1185       WHEN OTHERS.
1186         CALL FUNCTION 'WRITE_FORM'
1187           EXPORTING
1188             element = 'TITLE_M'
1189             window  = 'TITLE'
1190           EXCEPTIONS
1191             element = 1
1192             window  = 2.
1193         IF sy-subrc NE 0.
1194           PERFORM protocol_update.
1195         ENDIF.
1196     ENDCASE.
1197     IF repeat NE space.
1198       CALL FUNCTION 'WRITE_FORM'
1199         EXPORTING
1200           element = 'REPEAT'
1201           window  = 'REPEAT'
1202         EXCEPTIONS
1203           element = 1
1204           window  = 2.
1205       IF sy-subrc NE 0.
1206         PERFORM protocol_update.
1207       ENDIF.
1208     ENDIF.
1209
1210   ENDFORM.
1211
1212
1213   *---------------------------------------------------------------------*
1214   *       FORM GET_DATA                                                 *
1215   *---------------------------------------------------------------------*
1216   *       General provision of data for the form                        *
1217   *---------------------------------------------------------------------*
1218
1219   FORM get_data.
1220
1221     CALL FUNCTION 'RV_PRICE_PRINT_REFRESH'
1222       TABLES
1223         tkomv = tkomv.
1224     CLEAR komk.
1225     CLEAR komp.
1226
1227     IF nast-objky+10(6) NE space.
1228       vbco3-vbeln = nast-objky+16(10).
1229     ELSE.
1230       vbco3-vbeln = nast-objky.
1231     ENDIF.
1232
1233     vbco3-mandt = sy-mandt.
1234     vbco3-spras = nast-spras.
1235     vbco3-kunde = nast-parnr.
1236     vbco3-parvw = nast-parvw.
1237
1238
1239     CALL FUNCTION 'RV_BILLING_PRINT_VIEW'
1240       EXPORTING
1241         comwa                        = vbco3
1242       IMPORTING
1243         kopf                         = vbdkr
1244       TABLES
1245         pos                          = tvbdpr
1246       EXCEPTIONS
1247         terms_of_payment_not_in_t052 = 1
1248         error_message                = 5
1249         OTHERS                       = 4.
1250     IF NOT sy-subrc IS INITIAL.
1251       IF sy-subrc = 1.
1252         syst-msgty = 'I'.
1253         PERFORM protocol_update.
1254       ENDIF.
1255     ENDIF.
1256     SELECT SINGLE * FROM vbrp WHERE vbeln = vbdkr-vbeln.
1257     PERFORM sender.
1258     PERFORM check_repeat.
1259     PERFORM get_header_prices.
1260
1261     LOOP AT tkomv.
1262       CASE tkomv-kschl.
1263   *&------- Begin of TR ---------&*
1264   *  break cab_sudhir.
1265   *&------- End of TR ---------&*
1266         WHEN 'PR00' OR 'ZPP1' OR 'ZDP1'.                      "080708
1267           IF tkomv-kschl = 'PR00'.
1268             l_kpein = tkomv-kpein.
1269           ENDIF.
1270           IF tkomv-kschl = 'ZPP1' OR tkomv-kschl = 'ZDP1'.
1271             g_pp1_kwert = g_pp1_kwert + tkomv-kwert.
1272           ENDIF.
1273           g_cmpre = g_cmpre + tkomv-kbetr .
1274       ENDCASE.
1275     ENDLOOP.
1276     g_cmpre = g_cmpre / l_kpein.
1277
1278   *  read table tkomv with key kschl = 'PR00'.
1279   *  g_cmpre = tkomv-kbetr / tkomv-kpein.
1280
1281     IF tvbdpr-brgew > 0.
1282       g_flg_mg = 'X'.
1283       READ TABLE tkomv WITH KEY kschl = 'ZMGG'.
1284       g_cmpre1 = tkomv-kbetr / tkomv-kpein.
1285       g_br_mg = tvbdpr-brgew - tvbdpr-ntgew.
1286       g_fk_mg = tkomv-kwert.
1287
1288     ENDIF.
1289   * Calling customer subroutine dynamically for additional data transfer
1290     IF NOT get_data_userexit IS INITIAL.
1291       PERFORM (get_data_userexit) IN PROGRAM rvadin01 IF FOUND.
1292     ENDIF.
1293   *  SELECT SINGLE * FROM adrc WHERE addrnumber = vbdkr-adrnr.
1294       SELECT * FROM adrc UP TO 1 rows WHERE addrnumber = vbdkr-adrnr ORDER BY PRIMARY KEY. ENDSELECT.
1295     IF NOT adrc-str_suppl1 IS INITIAL.
1296       street2 = 'X'.
1297     ENDIF.
1298     IF NOT adrc-str_suppl2 IS INITIAL.
1299       street3 = 'X'.
1300     ENDIF.
1301     IF NOT adrc-str_suppl3 IS INITIAL.
1302       street4 = 'X'.
1303     ENDIF.
1304   ENDFORM.
1305
1306
1307   *---------------------------------------------------------------------*
1308   *       FORM GET_ITEM_CHARACTERISTICS                                 *
1309   *---------------------------------------------------------------------*
1310   *       In this routine the configuration da?a item is fetched from   *
1311   *       the database.                                                 *
1312   *---------------------------------------------------------------------*
1313
1314   FORM get_item_characteristics.
1315
1316     REFRESH tkomcon.
1317     CHECK NOT vbdpr-cuobj IS INITIAL.
1318
1319     CALL FUNCTION 'CUD0_GET_CONFIGURATION'
1320       EXPORTING
1321         instance      = vbdpr-cuobj
1322         language      = nast-spras
1323       TABLES
1324         configuration = tkomcon
1325       EXCEPTIONS
1326         OTHERS        = 4.
1327     IF sy-subrc NE 0.
1328       PERFORM protocol_update.
1329     ENDIF.
1330
1331   ENDFORM.
1332
1333   *---------------------------------------------------------------------*
1334   *       FORM GET_ITEM_PRICES                                          *
1335   *---------------------------------------------------------------------*
1336   *       In this routine the price data for the item is fetched from   *
1337   *       the database.                                                 *
1338   *---------------------------------------------------------------------*
1339
1340   FORM get_item_prices.
1341
1342     CLEAR: komp,
1343            tkomv.
1344     IF komk-knumv NE vbdkr-knumv.
1345       CLEAR komk.
1346       komk-mandt = sy-mandt.
1347       komk-kalsm = vbdkr-kalsm.
1348       komk-fkart = vbdkr-fkart.
1349       komk-kappl = pr_kappl.
1350       IF vbdkr-kappl NE space.
1351         komk-kappl = vbdkr-kappl.
1352       ENDIF.
1353       komk-waerk = vbdkr-waerk.
1354       komk-knumv = vbdkr-knumv.
1355       komk-vbtyp = vbdkr-vbtyp.
1356     ENDIF.
1357     komp-kposn = vbdpr-posnr.
1358
1359     CALL FUNCTION 'RV_PRICE_PRINT_ITEM'
1360       EXPORTING
1361         comm_head_i = komk
1362         comm_item_i = komp
1363         language    = nast-spras
1364       IMPORTING
1365         comm_head_e = komk
1366         comm_item_e = komp
1367       TABLES
1368         tkomv       = tkomv
1369         tkomvd      = tkomvd.
1370
1371   * Calling customer subroutine dynamically for handling item prices
1372     IF NOT item_userexit IS INITIAL.
1373       PERFORM (item_userexit) IN PROGRAM rvadin01 IF FOUND.
1374     ENDIF.
1375
1376   ENDFORM.
1377
1378   *---------------------------------------------------------------------*
1379   *       FORM GET_HEADER_PRICES                                        *
1380   *---------------------------------------------------------------------*
1381   *       In this routine the price data for the header is fetched from *
1382   *       the database.                                                 *
1383   *---------------------------------------------------------------------*
1384
1385   FORM get_header_prices.
1386
1387     IF komk-knumv NE vbdkr-knumv.
1388       CLEAR komk.
1389       komk-mandt = sy-mandt.
1390       komk-kalsm = vbdkr-kalsm.
1391       komk-fkart = vbdkr-fkart.
1392       komk-kappl = pr_kappl.
1393       IF vbdkr-kappl NE space.
1394         komk-kappl = vbdkr-kappl.
1395       ENDIF.
1396       komk-waerk = vbdkr-waerk.
1397       komk-knumv = vbdkr-knumv.
1398       komk-vbtyp = vbdkr-vbtyp.
1399       komk-knuma = vbdkr-knuma.
1400     ENDIF.
1401     CALL FUNCTION 'RV_PRICE_PRINT_HEAD'
1402       EXPORTING
1403         comm_head_i = komk
1404         language    = nast-spras
1405       IMPORTING
1406         comm_head_e = komk
1407         comm_mwskz  = print_mwskz
1408       TABLES
1409         tkomv       = tkomv
1410         tkomvd      = hkomvd.
1411   * Calling customer subroutine dynamically for handling header prices
1412     IF NOT header_userexit IS INITIAL.
1413       PERFORM (header_userexit) IN PROGRAM rvadin01 IF FOUND.
1414     ENDIF.
1415
1416   ENDFORM.
1417
1418   *---------------------------------------------------------------------*
1419   *       FORM HEADER_PRICE_PRINT                                       *
1420   *---------------------------------------------------------------------*
1421   *       Printout of the header prices                                 *
1422   *---------------------------------------------------------------------*
1423
1424   FORM header_price_print.
1425
1426     LOOP AT hkomvd.
1427
1428       AT FIRST.
1429         IF komk-supos NE 0.
1430           CALL FUNCTION 'WRITE_FORM'
1431             EXPORTING
1432               element = 'ITEM_SUM'.
1433         ELSE.
1434           IF sy-subrc NE 0.
1435             PERFORM protocol_update.
1436           ENDIF.
1437         ENDIF.
1438       ENDAT.
1439
1440       komvd = hkomvd.
1441       IF print_mwskz = space.
1442         CLEAR komvd-mwskz.
1443       ENDIF.
1444     ENDLOOP.
1445     DESCRIBE TABLE hkomvd LINES sy-tfill.
1446     IF sy-tfill = 0.
1447       IF sy-subrc NE 0.
1448         PERFORM protocol_update.
1449       ENDIF.
1450     ENDIF.
1451   * Calling customer subroutine dynamic0ally for handling header price
1452   * printing
1453     IF NOT header_print_userexit IS INITIAL.
1454       PERFORM (header_print_userexit) IN PROGRAM rvadin01 IF FOUND.
1455     ENDIF.
1456
1457   ENDFORM.
1458
1459   *---------------------------------------------------------------------*
1460   *       FORM HEADER_TEXT_PRINT                                        *
1461   *---------------------------------------------------------------------*
1462   *       Printout of the headertexts                                   *
1463   *---------------------------------------------------------------------*
1464
1465   FORM header_text_print.
1466
1467     CALL FUNCTION 'WRITE_FORM'
1468       EXPORTING
1469         element = 'HEADER_TEXT'
1470       EXCEPTIONS
1471         element = 1
1472         window  = 2.
1473     IF sy-subrc NE 0.
1474       PERFORM protocol_update.
1475     ENDIF.
1476
1477   ENDFORM.
1478
1479   *---------------------------------------------------------------------*
1480   *       FORM ITEM_CHARACERISTICS_PRINT                                *
1481   *---------------------------------------------------------------------*
1482   *       Printout of the item characteristics -> configuration         *
1483   *---------------------------------------------------------------------*
1484
1485   FORM item_characteristics_print.
1486
1487     LOOP AT tkomcon.
1488       conf_out = tkomcon.
1489       IF sy-tabix = 1.
1490         CALL FUNCTION 'WRITE_FORM'
1491           EXPORTING
1492             element = 'ITEM_LINE_CONFIGURATION_HEADER'
1493           EXCEPTIONS
1494             OTHERS  = 1.
1495         IF sy-subrc NE 0.
1496           PERFORM protocol_update.
1497         ENDIF.
1498       ELSE.
1499         CALL FUNCTION 'WRITE_FORM'
1500           EXPORTING
1501             element = 'ITEM_LINE_CONFIGURATION'
1502           EXCEPTIONS
1503             OTHERS  = 1.
1504         IF sy-subrc NE 0.
1505           PERFORM protocol_update.
1506         ENDIF.
1507       ENDIF.
1508     ENDLOOP.
1509
1510   ENDFORM.
1511
1512   *---------------------------------------------------------------------*
1513   *       FORM ITEM_PRICE_PRINT                                         *
1514   *---------------------------------------------------------------------*
1515   *       Printout of the item prices                                   *
1516   *---------------------------------------------------------------------*
1517
1518   FORM item_price_print.
1519   *  read table tkomv with key kschl = 'PR01'.
1520     IF g_pr01flag = 'X'.
1521       READ TABLE tkomv WITH KEY kschl = 'PR01' kposn = vbdpr-posnr.
1522       total1 = total1 + tkomv-kwert.
1523     ELSE.
1524       READ TABLE tkomv WITH KEY kschl = 'PR00'.
1525       total1 = total1 + vbdpr-kzwi1.
1526     ENDIF.
1527     t_fkimg = t_fkimg + vbdpr-fkimg.
1528
1529
1530     CLEAR pname.
1531     CONCATENATE vbrk-vbeln vbdpr-posnr INTO pname.
1532   *  CALL FUNCTION 'READ_TEXT'
1533   *       EXPORTING
1534   *            client                  = sy-mandt
1535   *            id                      = '0006'
1536   *            language                = sy-langu
1537   *            name                    = pname
1538   *            object                  = 'VBBP'
1539   *       TABLES
1540   *            lines                   = it_name
1541   *       EXCEPTIONS
1542   *            id                      = 1
1543   *            language                = 2
1544   *            name                    = 3
1545   *            not_found               = 4
1546   *            object                  = 5
1547   *            reference_check         = 6
1548   *            wrong_access_to_archive = 7
1549   *            OTHERS                  = 8.
1550   *  IF sy-subrc NE 0.
1551   *    PERFORM protocol_update.
1552   *  ENDIF.
1553
1554
1555     IF sy-subrc = 0.
1556       READ TABLE it_name INDEX 1.
1557       IF sy-subrc = 0.
1558         vbdkr-fkdat = it_name-tdline.
1559       ENDIF.
1560     ENDIF.
1561
1562
1563     CALL FUNCTION 'WRITE_FORM'
1564       EXPORTING
1565         element = 'ITEM_LINE_PRICE_QUANTITY'.
1566
1567     g_hzr_flg = 'X'.
1568
1569
1570     DATA: BEGIN OF tkomv_1 OCCURS 50.
1571             INCLUDE STRUCTURE komv.
1572     DATA: END OF tkomv_1.
1573     REFRESH tkomv_1.
1574     CLEAR   tkomv_1.
1575     tkomv_1[] = tkomv[].
1576   * Calling customer subroutine dynamically for handling item price
1577   * printing
1578     IF NOT item_print_userexit IS INITIAL.
1579       PERFORM (item_print_userexit) IN PROGRAM rvadin01 IF FOUND.
1580     ENDIF.
1581
1582   ENDFORM.
1583
1584   *---------------------------------------------------------------------*
1585   *       FORM ITEM_PRINT                                               *
1586   *---------------------------------------------------------------------*
1587   *       Printout of the items                                         *
1588   *---------------------------------------------------------------------*
1589
1590   FORM item_print.
1591
1592
1593     CALL FUNCTION 'WRITE_FORM'           "First header
1594       EXPORTING
1595         element = 'ITEM_HEADER'
1596       EXCEPTIONS
1597         OTHERS  = 1.
1598     IF sy-subrc NE 0.
1599       PERFORM protocol_update.
1600     ENDIF.
1601     CALL FUNCTION 'WRITE_FORM'           "Activate header
1602       EXPORTING
1603         element = 'ITEM_HEADER'
1604         type    = 'TOP'
1605       EXCEPTIONS
1606         OTHERS  = 1.
1607     IF sy-subrc NE 0.
1608       PERFORM protocol_update.
1609     ENDIF.
1610   * Change on dated 9 October 2003
1611     LOOP AT tvbdpr.
1612
1613       g_fkimg = g_fkimg + tvbdpr-fkimg.
1614       g_kzwi1 = g_kzwi1 + tvbdpr-kzwi1.
1615   * Change on dated 10 Octber 2003
1616       g_volum = g_volum + tvbdpr-volum.
1617   * end of change
1618     ENDLOOP.
1619
1620
1621   * End of Change
1622     LOOP AT tvbdpr.
1623
1624       vbdpr = tvbdpr.
1625   **************For ISOIL DATA Added on 19/09/03
1626       SELECT SINGLE * FROM lipso2 WHERE vbeln = vbdkr-vbeln_vl
1627                                     AND msehi = 'KLN'
1628                                     AND posnr = vbdpr-posnr.
1629       kln = kln + lipso2-adqntp.
1630
1631   **********************************
1632
1633       IF tvbdpr-uecha EQ vbdpr-posnr OR
1634          tvbdpr-uecha IS INITIAL.
1635         PERFORM get_item_prices.
1636         PERFORM get_item_characteristics.
1637         fkimg =   vbdpr-fkimg + fkimg.   " QUANTITY TOTAL
1638
1639         CALL FUNCTION 'CONTROL_FORM'
1640           EXPORTING
1641             command = 'PROTECT'.
1642         IF counter1 = 0.
1643           IF sy-tabix > 1.
1644             sy-tabix = 1.
1645             tabix = sy-tabix.
1646           ENDIF.
1647         ELSE.
1648           sy-tabix = tabix .
1649           sy-tabix = sy-tabix + 1.
1650         ENDIF.
1651         counter1 = counter1 + 1.
1652         CALL FUNCTION 'CONTROL_FORM'
1653           EXPORTING
1654             command = 'ENDPROTECT'.
1655       ELSE.
1656         IF NOT tvbdpr-fkimg IS INITIAL.
1657           PERFORM get_item_prices.
1658           CALL FUNCTION 'WRITE_FORM'
1659             EXPORTING
1660               element = 'ITEM_LINE_BATCH'
1661             EXCEPTIONS
1662               OTHERS  = 1.
1663           IF sy-subrc NE 0.
1664             PERFORM protocol_update.
1665           ENDIF.
1666         ENDIF.
1667       ENDIF.
1668       PERFORM item_price_print.
1669       IF counter1 = 1.
1670         LOOP AT tkomv.
1671   ****    Start of UCCheck change 17.06.2016
1672   *              KOMVD = TKOMV.
1673           MOVE-CORRESPONDING komvd TO tkomv.
1674   ****    End of UCCheck change 17.06.2016
1675
1676           IF print_mwskz EQ space.
1677             CLEAR komvd-mwskz.
1678           ENDIF.
1679           IF tkomvd-kstat EQ space.
1680             kwert = tkomv-kwert + kwert.
1681           ENDIF.
1682
1683           CASE  tkomv-kschl.
1684
1685             WHEN 'ZASV'.
1686               tot_zasv =  tkomv-kbetr.
1687             WHEN 'ZFRT'.
1688               tot_zfrt =  tkomv-kbetr.
1689             WHEN 'ZSCG'.
1690               tot_zscg =  tkomv-kbetr.
1691             WHEN 'JMOD'.
1692               jmod_kbetr = tkomv-kbetr / 10.
1693               tot_edr =  tot_edr + tkomv-kwert.
1694             WHEN 'ZOCR'.
1695               zocr_kbetr = tkomv-kbetr / 10.
1696               tot_ocr = tot_ocr + tkomv-kwert.
1697
1698             WHEN 'JIN1'.
1699               poscnt1 = poscnt1 + 1.
1700               tot_zin = tot_zin + tkomv-kwert.
1701               val_zin1 = val_zin1 + tkomv-kwert.
1702               zin1_kbetr = tkomv-kbetr / 10.
1703
1704             WHEN 'JIN2'.
1705               poscnt1 = poscnt1 + 1.
1706               tot_zin = tot_zin + tkomv-kwert.
1707               val_zin2 = val_zin2 + tkomv-kwert.
1708               zin2_kbetr = tkomv-kbetr / 10.
1709
1710             WHEN 'JIN4'.
1711               poscnt1 = poscnt1 + 1.
1712               tot_zin = tot_zin + tkomv-kwert.
1713               val_zin4 = val_zin4 + tkomv-kwert.
1714               zin4_kbetr = tkomv-kbetr / 10.
1715             WHEN 'JIN5'.
1716               poscnt1 = poscnt1 + 1.
1717               tot_zin = tot_zin + tkomv-kwert.
1718               val_zin5 = val_zin5 + tkomv-kwert.
1719               zin5_kbetr = tkomv-kbetr / 10.
1720             WHEN 'JIN6'.
1721               poscnt1 = poscnt1 + 1.
1722               tot_zin = tot_zin + tkomv-kwert.
1723               val_zin6 = val_zin6 + tkomv-kwert.
1724               zin6_kbetr = tkomv-kbetr / 10.
1725             WHEN 'JCES'.
1726               poscnt1 = poscnt1 + 1.
1727               tot_zin = tot_zin + tkomv-kwert.
1728               val_cess = val_cess + tkomv-kwert.
1729               cess_kbetr = tkomv-kbetr / 10.
1730             WHEN 'ZAED'.
1731               poscnt1 = poscnt1 + 1.
1732               tot_zin = tot_zin + tkomv-kwert.
1733               val_excise = val_excise + tkomv-kwert.
1734               .
1735               excise_kbetr = tkomv-kbetr.
1736             WHEN 'ZEDC' OR 'JECX'.
1737               poscnt1 = poscnt1 + 1.
1738               tot_zin = tot_zin + tkomv-kwert.
1739               val_educess = val_educess + tkomv-kwert.
1740               .
1741               educess_kbetr = 2. "tkomv-kbetr.
1742           ENDCASE.
1743           wrk_tabix = sy-tabix.
1744         ENDLOOP.
1745       ENDIF.
1746       PERFORM end_print.
1747       AT LAST.
1748
1749         CALL FUNCTION 'WRITE_FORM'
1750           EXPORTING
1751             element = 'TOTAL_TEST1'.
1752
1753       ENDAT.
1754
1755     ENDLOOP.
1756     CLEAR total1.
1757     LOOP AT tkomv.
1758   ***    UC Check Start of change 17.06.2016
1759   *    komvd = tkomv.
1760       MOVE-CORRESPONDING komvd TO tkomv.
1761   ***    End of Change UCCheck
1762
1763       IF vbdkr-spart = 'SK' OR vbdkr-spart = 'HS' OR vbdkr-spart = 'LS'.
1764         countsko = countsko + 1.
1765         IF countsko = 1.
1766           SELECT SINGLE * FROM lipso2 WHERE vbeln = vbdkr-vbeln_vl
1767                                         AND msehi = 'KLN'
1768                                         AND posnr = vbdpr-posnr.
1769           CALL FUNCTION 'WRITE_FORM'
1770             EXPORTING
1771               element = 'ITEM_LINE_PRICE_ZSKO'.
1772
1773         ENDIF.
1774       ENDIF.
1775       IF tkomv-kschl = 'ZASV'.
1776         count1 = count1 + 1.
1777         IF zasv <> 'X'.
1778           zasv = 'X'.
1779           IF count1 = 1.
1780             SELECT SINGLE * FROM t685t WHERE   spras = sy-langu
1781                                         AND   kschl = tkomv-kschl
1782                                         AND   kvewe = 'A'
1783                                          AND   kappl = 'V'.
1784
1785
1786             CALL FUNCTION 'WRITE_FORM'
1787               EXPORTING
1788                 element = 'ITEM_LINE_PRICE_ZASV'.
1789
1790           ENDIF.
1791         ENDIF.
1792
1793       ENDIF.
1794       IF tkomv-kschl = 'ZFRT'.
1795         count2 = count2 + 1.
1796         IF zfrt <> 'X'.
1797           zfrt = 'X'.
1798           IF count2 = 1.
1799             SELECT SINGLE * FROM t685t WHERE   spras = sy-langu
1800                                          AND   kschl = tkomv-kschl
1801                                         AND   kvewe = 'A'
1802                                          AND   kappl = 'V'.
1803
1804
1805             CALL FUNCTION 'WRITE_FORM'
1806               EXPORTING
1807                 element = 'ITEM_LINE_PRICE_ZFRT'.
1808
1809           ENDIF.
1810         ENDIF.
1811
1812       ENDIF.
1813       IF tkomv-kschl = 'ZSCG'.
1814         count3 = count3 + 1.
1815         IF zscg <> 'X'.
1816           zscg = 'X'.
1817           IF tkomv-kschl = 'ZASV' OR tkomv-kschl = 'ZFRT' OR
1818           tkomv-kschl = 'ZSCG'.
1819             IF count3 = 1 .
1820               SELECT SINGLE * FROM t685t WHERE spras = sy-langu
1821                                             AND   kschl = tkomv-kschl
1822                                             AND   kvewe = 'A'
1823                                             AND   kappl = 'V'.
1824
1825
1826               CALL FUNCTION 'WRITE_FORM'
1827                 EXPORTING
1828                   element = 'ITEM_LINE_PRICE_ZSCG'.
1829
1830               total1 = tot_zasv + tot_zfrt + tot_zscg.
1831               CALL FUNCTION 'WRITE_FORM'
1832                 EXPORTING
1833                   element = 'TOTAL_TEST'.
1834
1835             ENDIF.
1836           ENDIF.
1837
1838         ENDIF.
1839       ENDIF.
1840
1841
1842       IF tkomv-kschl = 'JMOD'.
1843         count4 = count4 + 1.
1844         IF jmod <> 'X'.
1845           jmod = 'X'.
1846           IF count4 = 1 AND tot_edr > 0.
1847
1848             SELECT SINGLE * FROM t685t WHERE   spras = sy-langu
1849                                          AND   kschl = tkomv-kschl
1850                                             AND   kvewe = 'A'
1851                                          AND   kappl = 'V'.
1852
1853
1854             jmod_kbetr = tkomv-kbetr / 10.
1855
1856             CALL FUNCTION 'WRITE_FORM'
1857               EXPORTING
1858                 element = 'ITEM_LINE_PRICE_ZEDR'.
1859
1860           ENDIF.
1861         ENDIF.
1862       ENDIF.
1863
1864
1865
1866       IF tkomv-kschl = 'ZAED'.
1867         count5 = count5 + 1.
1868         IF zaed <> 'X'.
1869           zaed = 'X'.
1870           IF count5 = 1 AND val_excise > 0.
1871
1872             SELECT SINGLE * FROM t685t WHERE   spras = sy-langu
1873                                          AND   kschl = tkomv-kschl
1874                                             AND   kvewe = 'A'
1875                                          AND   kappl = 'V'.
1876
1877
1878
1879             CALL FUNCTION 'WRITE_FORM'
1880               EXPORTING
1881                 element = 'ITEM_LINE_PRICE_ZAED'.
1882
1883           ENDIF.
1884         ENDIF.
1885       ENDIF.
1886
1887
1888
1889       IF tkomv-kschl = 'JCES'.
1890         count6 = count6 + 1.
1891         IF jces <> 'X'.
1892           jces = 'X'.
1893           IF count6 = 1 AND val_cess > 0.
1894
1895             SELECT SINGLE * FROM t685t WHERE   spras = sy-langu
1896                                          AND   kschl = tkomv-kschl
1897                                             AND   kvewe = 'A'
1898                                          AND   kappl = 'V'.
1899
1900
1901
1902             CALL FUNCTION 'WRITE_FORM'
1903               EXPORTING
1904                 element = 'ITEM_LINE_PRICE_JCES'.
1905
1906           ENDIF.
1907         ENDIF.
1908       ENDIF.
1909
1910       IF tkomv-kschl = 'ZOCR'.
1911         count7 = count7 + 1.
1912         IF zocr <> 'X'.
1913           zocr = 'X'.
1914           IF count7 = 1.
1915             SELECT SINGLE * FROM t685t WHERE   spras = sy-langu
1916                                          AND   kvewe = 'A'
1917                                         AND   kappl = 'V'
1918                                          AND   kschl = tkomv-kschl.
1919
1920             CALL FUNCTION 'WRITE_FORM'
1921               EXPORTING
1922                 element = 'ITEM_LINE_PRICE_ZOCR'.
1923
1924           ENDIF.
1925         ENDIF.
1926
1927       ENDIF.
1928
1929       SELECT SINGLE * FROM vbrp WHERE vbeln = vbdkr-vbeln
1930                                   AND posnr = vbdpr-posnr.
1931       IF vbdkr-vkorg <> 'URNS' OR vbrp-werks <> '10K2'.
1932         IF tkomv-kschl = 'JIN1'.
1933           count8 = count8 + 1.
1934           IF zin1 <> 'X'.
1935             zin1 = 'X'.
1936             IF count8 = 1 AND val_zin1 > 0.
1937               SELECT SINGLE * FROM t685t WHERE   spras = sy-langu
1938                                            AND   kvewe = 'A'
1939                                           AND   kappl = 'V'
1940                                            AND   kschl = tkomv-kschl.
1941
1942               CALL FUNCTION 'WRITE_FORM'
1943                 EXPORTING
1944                   element = 'ITEM_ZIN1'.
1945
1946             ENDIF.
1947           ENDIF.
1948         ENDIF.
1949         IF tkomv-kschl = 'JIN2'.
1950           count9 = count9 + 1.
1951           IF zin2 <> 'X'.
1952             zin2 = 'X'.
1953             IF count9 = 1 AND val_zin2 > 0.
1954               SELECT SINGLE * FROM t685t WHERE   spras = 'EN'
1955                                            AND   kschl = tkomv-kschl
1956                                             AND   kvewe = 'A'
1957                                            AND   kappl = 'V'.
1958
1959               CALL FUNCTION 'WRITE_FORM'
1960                 EXPORTING
1961                   element = 'ITEM_ZIN2'.
1962
1963             ENDIF.
1964           ENDIF.
1965         ENDIF.
1966         IF tkomv-kschl = 'JIN4'.
1967           count10 = count10 + 1.
1968           IF zin4 <> 'X'.
1969             zin4 = 'X'.
1970             IF count10 = 1 AND val_zin4 > 0.
1971               SELECT SINGLE * FROM t685t WHERE   spras = sy-langu
1972                                            AND   kvewe = 'A'
1973                                            AND   kappl = 'V'
1974                                            AND   kschl = tkomv-kschl.
1975
1976               CALL FUNCTION 'WRITE_FORM'
1977                 EXPORTING
1978                   element = 'ITEM_ZIN4'.
1979
1980             ENDIF.
1981           ENDIF.
1982         ENDIF.
1983         IF tkomv-kschl = 'JIN5'.
1984           count11 = count11 + 1.
1985           IF zin5 <> 'X'.
1986             zin5 = 'X'.
1987             IF count11 = 1 AND val_zin5 > 0.
1988               SELECT SINGLE * FROM t685t WHERE   spras = sy-langu
1989                                            AND   kvewe = 'A'
1990                                            AND   kappl = 'V'
1991                                            AND   kschl = tkomv-kschl.
1992
1993               CALL FUNCTION 'WRITE_FORM'
1994                 EXPORTING
1995                   element = 'ITEM_ZIN5'.
1996
1997             ENDIF.
1998           ENDIF.
1999         ENDIF.
2000         IF tkomv-kschl = 'JIN6'.
2001           count12 = count12 + 1.
2002           IF zin6 <> 'X'.
2003             zin6 = 'X'.
2004             IF count12 = 1 AND val_zin6 > 0.
2005               SELECT SINGLE * FROM t685t WHERE   spras = 'EN'
2006                                            AND   kschl = tkomv-kschl
2007                                             AND   kvewe = 'A'
2008                                            AND   kappl = 'V'.
2009
2010
2011               CALL FUNCTION 'WRITE_FORM'
2012                 EXPORTING
2013                   element = 'ITEM_ZIN6'.
2014
2015             ENDIF.
2016           ENDIF.
2017         ENDIF.
2018       ENDIF.
2019       IF tkomv-kschl = 'ZEDC' OR tkomv-kschl = 'JECX' .
2020         count13 = count13 + 1.
2021         IF zedc <> 'X'.
2022           zedc = 'X'.
2023           IF count13 = 1 AND val_educess > 0.
2024
2025             SELECT SINGLE * FROM t685t WHERE   spras = sy-langu
2026                                          AND   kschl = tkomv-kschl
2027                                             AND   kvewe = 'A'
2028                                          AND   kappl = 'V'.
2029
2030
2031
2032             CALL FUNCTION 'WRITE_FORM'
2033               EXPORTING
2034                 element = 'ITEM_LINE_PRICE_ZEDC'.
2035
2036           ENDIF.
2037         ENDIF.
2038       ENDIF.
2039
2040     ENDLOOP.
2041
2042     IF g_pr01flag = 'X'.
2043       LOOP AT tkomv WHERE kschl = 'PR01'.
2044         total1 = total1 + tkomv-kwert .
2045       ENDLOOP.
2046       IF vbdkr-vtweg  = 'RD'.
2047         total1 = total1 - zintotal.
2048       ENDIF.
2049     ELSE.
2050       total1 = g_kzwi1.
2051     ENDIF.
2052
2053     LOOP AT tkomv WHERE kschl = 'ZDIF'.
2054       roundoff = roundoff + tkomv-kwert.
2055     ENDLOOP.
2056   **Total2 contains Invoice final value komk-fkwrt
2057     IF vbdkr-vkorg = 'HZRS'.
2058       total2 = tot_zin + tot_edr + tot_ocr + g_kzwi1 + roundoff.
2059     ELSE.
2060       total2 = tot_zin + tot_edr + tot_ocr + total1 + roundoff.
2061     ENDIF.
2062     CALL FUNCTION 'WRITE_FORM'
2063       EXPORTING
2064         element = 'TOTAL_TEST_TAX'.
2065     CALL FUNCTION 'Y_FI_AMT_WRDS_CONVERT'
2066       EXPORTING
2067         amt    = fkwrt
2068       IMPORTING
2069         word   = word
2070       EXCEPTIONS
2071         OTHERS = 1.
2072     IF sy-subrc NE 0.
2073       PERFORM protocol_update.
2074     ENDIF.
2075
2076     CALL FUNCTION 'WRITE_FORM'
2077       EXPORTING
2078         element = 'END_VALUES'.
2079     CALL FUNCTION 'WRITE_FORM'           "Deactivate Header
2080       EXPORTING
2081         element  = 'ITEM_HEADER'
2082         function = 'DELETE'
2083         type     = 'TOP'
2084       EXCEPTIONS
2085         OTHERS   = 1.
2086     IF sy-subrc NE 0.
2087       PERFORM protocol_update.
2088     ENDIF.
2089     CALL FUNCTION 'WRITE_FORM'
2090       EXPORTING
2091         element = 'SUPPLEMENT_TEXT'
2092       EXCEPTIONS
2093         element = 1
2094         window  = 2.
2095     IF sy-subrc NE 0.
2096       PERFORM protocol_update.
2097     ENDIF.
2098     CLEAR roundoff.
2099   ENDFORM.
2100
2101   *---------------------------------------------------------------------*
2102   *       FORM ITEM_TEXT_PRINT                                          *
2103   *---------------------------------------------------------------------*
2104   *       Printout of the item texts                                    *
2105   *---------------------------------------------------------------------*
2106
2107   FORM item_text_print.
2108
2109     CALL FUNCTION 'WRITE_FORM'
2110       EXPORTING
2111         element = 'ITEM_TEXT'
2112       EXCEPTIONS
2113         element = 1
2114         window  = 2.
2115     IF sy-subrc NE 0.
2116       PERFORM protocol_update.
2117     ENDIF.
2118
2119   ENDFORM.
2120
2121   *---------------------------------------------------------------------*
2122   *       FORM PROTOCOL_UPDATE                                          *
2123   *---------------------------------------------------------------------*
2124   *       The messages are collected for the processing protocol.       *
2125   *---------------------------------------------------------------------*
2126
2127   FORM protocol_update.
2128
2129     CHECK xscreen = space.
2130     CALL FUNCTION 'NAST_PROTOCOL_UPDATE'
2131       EXPORTING
2132         msg_arbgb = syst-msgid
2133         msg_nr    = syst-msgno
2134         msg_ty    = syst-msgty
2135         msg_v1    = syst-msgv1
2136         msg_v2    = syst-msgv2
2137         msg_v3    = syst-msgv3
2138         msg_v4    = syst-msgv4
2139       EXCEPTIONS
2140         OTHERS    = 1.
2141     IF sy-subrc NE 0.
2142       PERFORM protocol_update.
2143     ENDIF.
2144
2145
2146   ENDFORM.
2147
2148   *---------------------------------------------------------------------*
2149   *       FORM REFERENCE_NUMBER                                         *
2150   *---------------------------------------------------------------------*
2151   *       Printing of the reference numbers                             *
2152   *---------------------------------------------------------------------*
2153
2154   FORM reference_number.
2155
2156     CALL FUNCTION 'WRITE_FORM'
2157       EXPORTING
2158         element = 'REFERENCE_NUMBER'
2159         window  = 'REFNUMB'
2160       EXCEPTIONS
2161         element = 1
2162         window  = 2.
2163     IF sy-subrc NE 0.
2164       PERFORM protocol_update.
2165     ENDIF.
2166
2167   ENDFORM.
2168
2169   *---------------------------------------------------------------------*
2170   *       FORM SENDER                                                   *
2171   *---------------------------------------------------------------------*
2172   *       This routine determines the address of the sender (Table VKO) *
2173   *---------------------------------------------------------------------*
2174
2175   FORM sender.
2176
2177     SELECT SINGLE * FROM tvko  WHERE vkorg = vbdkr-vkorg.
2178     IF sy-subrc NE 0.
2179       syst-msgid = 'VN'.
2180       syst-msgno = '203'.
2181       syst-msgty = 'E'.
2182       syst-msgv1 = 'TVKO'.
2183       syst-msgv2 = syst-subrc.
2184       PERFORM protocol_update.
2185       EXIT.
2186     ENDIF.
2187   *  SELECT SINGLE * FROM sadr WHERE adrnr = tvko-adrnr
2188   *                            AND   natio = space.
2189     vbdkr-sland = sadr-land1.
2190     IF sy-subrc NE 0.
2191       syst-msgid = 'VN'.
2192       syst-msgno = '203'.
2193       syst-msgty = 'E'.
2194       syst-msgv1 = 'SADR'.
2195       syst-msgv2 = syst-subrc.
2196       PERFORM protocol_update.
2197     ENDIF.
2198
2199     IF vbdkr-vbtyp CA '56'.
2200       CLEAR t001g.
2201       SELECT SINGLE * FROM t001g WHERE bukrs = vbdkr-bukrs
2202                                    AND programm EQ sy-repid
2203                                    AND txtid EQ 'SD'.
2204     ENDIF.
2205
2206   ENDFORM.
2207
2208   *&---------------------------------------------------------------------*
2209   *&      Form  HEADER_CONSGNEE
2210   *&---------------------------------------------------------------------*
2211   *       text                                                           *
2212   *----------------------------------------------------------------------*
2213   *  -->  p1        text
2214   *  <--  p2        text
2215   *----------------------------------------------------------------------*
2216   FORM header_consgnee.
2217
2218     IF vbdkr-name1 NE vbdkr-name1_we OR
2219        vbdkr-name2 NE vbdkr-name2_we OR
2220        vbdkr-name3 NE vbdkr-name3_we OR
2221        vbdkr-name4 NE vbdkr-name4_we   .
2222       CALL FUNCTION 'WRITE_FORM'
2223         EXPORTING
2224           element = 'HEADER_CONSGNEE'
2225           window  = 'CONSGNEE'
2226         EXCEPTIONS
2227           element = 1
2228           window  = 2.
2229       IF sy-subrc NE 0.
2230         PERFORM protocol_update.
2231       ENDIF.
2232
2233       CALL FUNCTION 'WRITE_FORM'
2234         EXPORTING
2235           element = 'HEADER_CONSGNEE'
2236           window  = 'INFO1'
2237         EXCEPTIONS
2238           element = 1
2239           window  = 2.
2240       IF sy-subrc NE 0.
2241         PERFORM protocol_update.
2242       ENDIF.
2243
2244     ENDIF.
2245   ENDFORM.                               " HEADER_CONSGNEE
2246   *&---------------------------------------------------------------------*
2247   *&      Form  DIFFERENT_REFERENCE_NO
2248   *&---------------------------------------------------------------------*
2249   *       text                                                           *
2250   *----------------------------------------------------------------------*
2251   *  -->  p1        text
2252   *  <--  p2        text
2253   *----------------------------------------------------------------------*
2254   FORM different_reference_no.
2255
2256     CHECK vbdkr-vbtyp CA 'OP'.
2257     CHECK vbdkr-vbeln_vg2 NE vbdpr-vbeln_vg2.
2258     CALL FUNCTION 'WRITE_FORM'
2259       EXPORTING
2260         element = 'ITEM_REFERENCE_NO'
2261       EXCEPTIONS
2262         element = 1
2263         window  = 2.
2264     IF sy-subrc NE 0.
2265       PERFORM protocol_update.
2266     ENDIF.
2267
2268   ENDFORM.                               " DIFFERENT_REFERENCE_NO
2269   *&---------------------------------------------------------------------*
2270   *&      Form  HEADER_DATA_PRINT
2271   *&---------------------------------------------------------------------*
2272   *       text                                                           *
2273   *----------------------------------------------------------------------*
2274   *  -->  p1        text
2275   *  <--  p2        text
2276   *----------------------------------------------------------------------*
2277   FORM header_data_print.
2278
2279     CALL FUNCTION 'WRITE_FORM'
2280       EXPORTING
2281         element = 'HEADER_DATA'
2282       EXCEPTIONS
2283         element = 1
2284         window  = 2.
2285     IF sy-subrc NE 0.
2286       PERFORM protocol_update.
2287     ENDIF.
2288
2289   ENDFORM.                               " HEADER_DATA_PRINT
2290   *&---------------------------------------------------------------------*
2291   *&      Form  GET_DATA_ESR
2292   *&---------------------------------------------------------------------*
2293   *       text                                                           *
2294   *----------------------------------------------------------------------*
2295   *  -->  p1        text
2296   *  <--  p2        text
2297   *----------------------------------------------------------------------*
2298   FORM get_data_esr.
2299
2300     CALL FUNCTION 'SD_ESR_GET_DATA'
2301       EXPORTING
2302         vbdkr_bukrs                   = vbdkr-bukrs
2303         vbdkr_vkorg                   = vbdkr-vkorg
2304         komk_fkwrt                    = komk-fkwrt
2305         vbdkr_vbeln                   = vbdkr-vbeln
2306         vbdkr_kunrg                   = vbdkr-kunrg
2307         vbdkr_waerk                   = vbdkr-waerk
2308       CHANGING
2309         ivbdre                        = vbdre
2310       EXCEPTIONS
2311         t049e_no_entry                = 1
2312         t001_no_entry                 = 2
2313         bnka_no_entry                 = 3
2314         sadr_no_entry                 = 4
2315         fkwrt_not_valid               = 5
2316         esr_digits_to_check_not_valid = 6
2317         esr_check_method_not_valid    = 7
2318         OTHERS                        = 8.
2319
2320     IF sy-subrc NE 0.
2321       retcode = sy-subrc.
2322       PERFORM protocol_update.
2323     ENDIF.
2324
2325   ENDFORM.                               " GET_DATA_ESR
2326
2327   *----------------------------------------------------------------------*
2328   *       Form  GET_DATA_ITALY
2329   *----------------------------------------------------------------------*
2330   *                                                                      *
2331   *----------------------------------------------------------------------*
2332   *
2333   *
2334   *----------------------------------------------------------------------*
2335   FORM get_data_italy USING proc_screen.
2336
2337     CLEAR konh.
2338     CLEAR tlic.
2339     LOOP AT tkomv WHERE koaid = 'D'
2340                   AND   kntyp ='+'.
2341       SELECT SINGLE * FROM konh WHERE knumh = tkomv-knumh.
2342       IF sy-subrc EQ 0.
2343         IF NOT konh-licno IS INITIAL AND NOT konh-licdt IS INITIAL.
2344   *        SELECT SINGLE * FROM tlic WHERE licno = konh-licno.
2345           SELECT * FROM tlic UP TO 1 rows WHERE licno = konh-licno ORDER BY PRIMARY KEY. ENDSELECT.
2346           IF sy-subrc EQ 0.
2347             IF NOT tlic-prnum_nr IS INITIAL AND
2348                NOT tlic-prnum_dt IS INITIAL.
2349               MOVE:
2350                 konh-licno TO vbdkr-licno,
2351                 konh-licdt TO vbdkr-licdt.
2352             ENDIF.
2353           ENDIF.
2354         ENDIF.
2355       ENDIF.
2356       IF vbdkr-licno     IS INITIAL OR
2357          vbdkr-licdt     IS INITIAL OR
2358          tlic-prnum_nr   IS INITIAL OR
2359          tlic-prnum_dt   IS INITIAL.
2360         IF proc_screen = space.
2361           retcode = 3.
2362           syst-msgno = '205'.
2363           syst-msgid = 'VN'.
2364           syst-msgty = 'I'.
2365           PERFORM protocol_update.
2366         ELSE.
2367           MESSAGE i205.
2368         ENDIF.
2369       ENDIF.
2370       EXIT.
2371     ENDLOOP.
2372
2373
2374
2375   ENDFORM.                               " get_data_italy
2376
2377   *&---------------------------------------------------------------------*
2378   *&      Form  START_FORM
2379   *&---------------------------------------------------------------------*
2380   *       text                                                           *
2381   *----------------------------------------------------------------------*
2382   *  -->  p1        text
2383   *  <--  p2        text
2384   *----------------------------------------------------------------------*
2385   FORM start_form.
2386
2387     DATA : startseite(8)  VALUE 'FIRSTBSR'.
2388     DATA : sprache LIKE sy-langu.
2389
2390     IF vbdre-verfa = '04' OR vbdre-verfa = '08'.
2391
2392       CALL FUNCTION 'START_FORM'
2393         EXPORTING
2394           startpage = startseite
2395         IMPORTING
2396           language  = sprache
2397         EXCEPTIONS
2398           form      = 1
2399           format    = 2
2400           unended   = 3
2401           unopened  = 4
2402           unused    = 5
2403           OTHERS    = 6.
2404       IF sy-subrc NE 0.
2405         retcode = sy-subrc.
2406         PERFORM protocol_update.
2407       ENDIF.
2408
2409     ENDIF.
2410
2411   ENDFORM.                               " START_OPEN
2412   *&---------------------------------------------------------------------*
2413   *&      Form  TAX_TEXT_PRINT
2414   *&---------------------------------------------------------------------*
2415   *       text                                                           *
2416   *----------------------------------------------------------------------*
2417   *  -->  p1        text
2418   *  <--  p2        text
2419   *----------------------------------------------------------------------*
2420   FORM tax_text_print USING text_element.
2421
2422     CALL FUNCTION 'WRITE_FORM'
2423       EXPORTING
2424         element = text_element
2425       EXCEPTIONS
2426         element = 1
2427         window  = 2.
2428     IF sy-subrc NE 0.
2429       PERFORM protocol_update.
2430     ENDIF.
2431
2432   ENDFORM.                               " TAX_TEXT_PRINT
2433
2434   ***********************************************************************
2435   *                SUBROUTINES OF ENTRY_CH                              *
2436   ***********************************************************************
2437
2438   FORM header_ch.
2439     CLEAR print_local_curr_ch.
2440     SELECT SINGLE * FROM t001 WHERE bukrs EQ vbdkr-bukrs.
2441     CHECK sy-subrc = 0.
2442     CHECK t001-waers <> vbdkr-waerk.
2443     MOVE 'X' TO print_local_curr_ch.
2444     REFRESH komvdk_ch.
2445     LOOP AT hkomvd WHERE koaid = 'D'.
2446       CLEAR komvdk_ch.
2447       CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
2448         EXPORTING
2449           date             = vbdkr-fkdat
2450           foreign_amount   = hkomvd-kwert
2451           foreign_currency = vbdkr-waerk
2452           local_currency   = t001-waers
2453           rate             = vbdkr-kurrf
2454         IMPORTING
2455           local_amount     = komvdk_ch-kwert
2456         EXCEPTIONS
2457           no_rate_found    = 1
2458           overflow         = 2
2459           no_factors_found = 3
2460           no_spread_found  = 4
2461           OTHERS           = 5.
2462       CHECK sy-subrc = 0.
2463       MOVE: t001-waers TO komvdk_ch-awein,
2464             t001-waers TO komvdk_ch-awei1,
2465             hkomvd-vtext TO komvdk_ch-vtext,
2466             vbdkr-kurrf TO hkomvd-kkurs.
2467       APPEND komvdk_ch.
2468     ENDLOOP.
2469   ENDFORM.
2470
2471   *---------------------------------------------------------------------*
2472   *       FORM ITEM_CH                                                  *
2473   *---------------------------------------------------------------------*
2474   *       ........                                                      *
2475   *---------------------------------------------------------------------*
2476   FORM item_ch.
2477     CHECK print_local_curr_ch EQ 'X'.
2478     REFRESH komvdp_ch.
2479     LOOP AT tkomvd WHERE koaid = 'D'.
2480       CLEAR komvdp_ch.
2481       CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
2482         EXPORTING
2483           date             = vbdkr-fkdat
2484           foreign_amount   = tkomvd-kwert
2485           foreign_currency = vbdkr-waerk
2486           local_currency   = t001-waers
2487           rate             = vbdkr-kurrf
2488         IMPORTING
2489           local_amount     = komvdp_ch-kwert
2490         EXCEPTIONS
2491           no_rate_found    = 1
2492           overflow         = 2
2493           no_factors_found = 3
2494           no_spread_found  = 4
2495           OTHERS           = 5.
2496       CHECK sy-subrc = 0.
2497       MOVE: t001-waers TO komvdp_ch-awein,
2498             t001-waers TO komvdp_ch-awei1,
2499             tkomvd-vtext TO komvdp_ch-vtext,
2500             vbdkr-kurrf TO komvdp_ch-kkurs.
2501       APPEND komvdp_ch.
2502     ENDLOOP.
2503   ENDFORM.
2504
2505   *---------------------------------------------------------------------*
2506   *       FORM ITEM_PRINT_CH                                            *
2507   *---------------------------------------------------------------------*
2508   *       ........                                                      *
2509   *---------------------------------------------------------------------*
2510   FORM item_print_ch.
2511     LOOP AT komvdp_ch.
2512       komvd = komvdp_ch.
2513       IF print_mwskz EQ space.
2514         CLEAR komvd-mwskz.
2515
2516
2517       ENDIF.
2518       CALL FUNCTION 'WRITE_FORM'
2519         EXPORTING
2520           element = 'ITEM_LINE_TAX_HAUSWAEHRUNG'.
2521     ENDLOOP.
2522   ENDFORM.
2523
2524   *---------------------------------------------------------------------*
2525   *       FORM HEADER_PRINT_CH                                          *
2526   *---------------------------------------------------------------------*
2527   *       ........                                                      *
2528   *---------------------------------------------------------------------*
2529   FORM header_print_ch.
2530     LOOP AT komvdk_ch.
2531       komvd = komvdk_ch.
2532       IF print_mwskz = space.
2533         CLEAR komvd-mwskz.
2534       ENDIF.
2535       CALL FUNCTION 'WRITE_FORM'
2536         EXPORTING
2537           element = 'SUM_LINE_TAX_HAUSWAEHRUNG'.
2538     ENDLOOP.
2539   ENDFORM.
2540
2541   ***********************************************************************
2542   *       CUSTOMER SUBROUTINES                                          *
2543   ***********************************************************************
2544   *&---------------------------------------------------------------------*
2545   *&      Form  get_fkwrt
2546   *&---------------------------------------------------------------------*
2547   *       text
2548   *----------------------------------------------------------------------*
2549   *  -->  p1        text
2550   *  <--  p2        text
2551   *----------------------------------------------------------------------
2552   *&---------------------------------------------------------------------*
2553   *&      Form  get_fkwrt
2554   *&---------------------------------------------------------------------*
2555   *       text
2556   *----------------------------------------------------------------------*
2557   *  -->  p1        text
2558   *  <--  p2        text
2559   *----------------------------------------------------------------------*
2560   FORM get_fkwrt.
2561     LOOP AT tkomv.
2562       CASE  tkomv-kschl.
2563         WHEN 'JIN1'.
2564           zintotal =  zintotal + tkomv-kwert.
2565         WHEN 'JIN2'.
2566           zintotal = zintotal + tkomv-kwert.
2567         WHEN 'JIN4'.
2568           zintotal = zintotal + tkomv-kwert.
2569         WHEN 'JIN5'.
2570           zintotal = zintotal + tkomv-kwert.
2571         WHEN 'JIN6'.
2572           zintotal = zintotal + tkomv-kwert.
2573         WHEN 'JMOD'.
2574           jmodtotal = jmodtotal + tkomv-kwert.
2575         WHEN 'ZDIF'.
2576           zdif = zdif + tkomv-kwert.
2577       ENDCASE.
2578     ENDLOOP.
2579   ENDFORM.                    " get_fkwrt
2580   *
*--- End of ZSD_INVOICE_VAPEXP_DP - 2580 lines ---

----------------------------------------------------------------------------------------------------
Include          ZSD_INVOICE_VAPEXP_DP_INVDCLR             Level 1    Page 2
Object           ZSD_INVOICE_VAPEXP_DP                     Lines 49
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:09
----------------------------------------------------------------------------------------------------
1      *----------------------------------------------------------------------*
2      *   INCLUDE ZSD_INVOICE_VAP_DP_INVDCLR                                *
3      *----------------------------------------------------------------------*
4      TABLES: KOMK    ,
5              KOMP    ,
6              KOMVD   ,
7              t001w,
8              VBCO3   ,
9              VBDKR   ,
10             VBDPR   ,
11             VBDRE   ,
12             CONF_OUT,
13             SADR    ,
14             TVKO    ,
15             T001    ,
16             T001G,
17             KONH,
18             T052,
19             VBAK,
20             TLIC,
21             STXH,
22             REGUH,
23             tvtwt,
24             TVAUT,
25             vbrk,
26             vbrp.
27     **********************************************************************
28     *TYPES
29     **********************************************************************
30
31     DATA  WORD LIKE SPELL-WORD.
32     DATA  KWERT LIKE KOMVD-KWERT.
33     DATA: FKWRT like komk-fkwrt,
34           g_pp1_kwert like komv-kwert.   "080708
35     DATA: PHEAD LIKE THEAD, PNAME LIKE THEAD-TDNAME.
36     DATA  COUNTER1(3). " TYPE N.
37     DATA  TABIX TYPE N.
38     DATA  VBELN LIKE VBRK-VBELN.
39     DATA  TEXT_ELEMENT(15).
40     DATA  AUGRU LIKE VBAK-AUGRU.
41     DATA  ZTERM LIKE VBRK-ZTERM.
42     DATA  FKWRT1(18).
43     DATA  FKIMG LIKE VBDPR-FKIMG.
44     DATA:  MDESC LIKE VBDPR-ARKTX. "FITEM(1) VALUE 'X'.
45     ***********************************************************************
46     * Additional definitions of tables for general issues                 *
47     ***********************************************************************
48
49     INCLUDE zSD_INVOICE_VAPexp_DP_RVADTBL.
*--- End of ZSD_INVOICE_VAPEXP_DP_INVDCLR - 49 lines ---

----------------------------------------------------------------------------------------------------
Include          ZSD_INVOICE_VAPEXP_DP_RVADTBL             Level 2    Page 3
Object           ZSD_INVOICE_VAPEXP_DP                     Lines 9
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:09
----------------------------------------------------------------------------------------------------
1      *----------------------------------------------------------------------*
2      *   INCLUDE ZSD_INVOICE_VAP_DP_RVADTBL                                 *
3      *----------------------------------------------------------------------*
4      tables: nast,                          "Messages
5             *nast,                         "Messages
6             tnapr,                         "Programs & Forms
7             itcpo,                         "Communicationarea for Spool
8             arc_params,                    "Archive parameters
9             toa_dara.                      "Archive parameters
*--- End of ZSD_INVOICE_VAPEXP_DP_RVADTBL - 9 lines ---

----------------------------------------------------------------------------------------------------
Include          ZSD_INVOICE_VAEXPP_DP_RVADOPG             Level 1    Page 4
Object           ZSD_INVOICE_VAPEXP_DP                     Lines 64
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:09
----------------------------------------------------------------------------------------------------
1      *----------------------------------------------------------------------*
2      *   INCLUDE ZSD_INVOICE_VAP_DP_RVADOPG                                 *
3      *----------------------------------------------------------------------*
4       data: xdevice(8) type c.
5       clear itcpo.
6       move-corresponding nast to itcpo.
7
8       if vbdkr-vkorg = 'HZRS' or vbdkR-vkorg = 'URNS'.
9         itcpo-tdpageslct = '2'.
10      endif.
11
12      itcpo-tdcover   = nast-tdocover.
13      itcpo-tddest    = nast-ldest.
14      itcpo-tddataset = nast-dsnam.
15      itcpo-tdsuffix1 = nast-dsuf1.
16      itcpo-tdsuffix2 = nast-dsuf2.
17      itcpo-tdimmed   = nast-dimme.
18      itcpo-tddelete  = nast-delet.
19      itcpo-tdcopies  = nast-anzal.
20      itcpo-tdprogram = sy-repid.
21      if us_screen ne space.
22        itcpo-tdpreview = 'X'.
23        itcpo-tdnoprint = 'X'.
24      endif.
25      case nast-nacha.
26        when '1'.
27          xdevice = 'PRINTER'.
28        when '2'.
29          xdevice = 'TELEFAX'.
30          itcpo-tdtelenum = nast-telfx.
31          itcpo-tdteleland = us_country.
32          itcpo-tdsenddate = nast-vsdat.
33          itcpo-tdsendtime = nast-vsura.
34        when '3'.
35          xdevice = 'TELETEX'.
36          itcpo-tdtelenum = nast-teltx.
37          itcpo-tdteleland = us_country.
38          itcpo-tdsenddate = nast-vsdat.
39          itcpo-tdsendtime = nast-vsura.
40        when '4'.
41          xdevice = 'TELEX'.
42          itcpo-tdtelenum = nast-telx1.
43          itcpo-tdteleland = us_country.
44          itcpo-tdsenddate = nast-vsdat.
45          itcpo-tdsendtime = nast-vsura.
46        when others.
47          xdevice = 'PRINTER'.
48      endcase.
49      call function 'OPEN_FORM'
50           EXPORTING
51                form           = tnapr-fonam
52                language       = nast-spras
53                options        = itcpo
54                archive_index  = toa_dara
55                archive_params = arc_params
56                device         = xdevice
57                dialog         = ' '
58           EXCEPTIONS
59                others         = 1.
60      if sy-subrc ne 0.
61        retcode = sy-subrc.
62        perform protocol_update.
63      endif.
64      set country us_country.
*--- End of ZSD_INVOICE_VAEXPP_DP_RVADOPG - 64 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  <REPINI>                                  Level 1    Page 5
Object           ZSD_INVOICE_VAPEXP_DP                     Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:09
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
Generated incl.  <SYSINI>                                  Level 1    Page 6
Object           ZSD_INVOICE_VAPEXP_DP                     Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:09
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
Generated incl.  <SYSSEL>                                  Level 1    Page 7
Object           ZSD_INVOICE_VAPEXP_DP                     Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:09
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
Generated incl.  DB__SSEL                                  Level 1    Page 8
Object           ZSD_INVOICE_VAPEXP_DP                     Lines 1
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:09
----------------------------------------------------------------------------------------------------
1      * INCLUDE DB__SSEL
*--- End of DB__SSEL - 1 lines ---
