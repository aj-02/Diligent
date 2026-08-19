----------------------------------------------------------------------------------------------------
Main program     ZGR_SDR_CAP                               Level 0    Page 1
Object           ZGR_SDR_CAP                               Lines 1938
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:07
----------------------------------------------------------------------------------------------------
1      ***********************************************************************
2      * Program    : ZGR_SDR_CAP                                            *
3      *                                                                     *
4      * Title      :                                                        *
5      *                                                                     *
6      * FS No.     :                                                        *
7      *                                                                     *
8      * Author     : Lalit Rawat              Date :  00.00.2006            *
9      *                                                                     *
10     * Login Id   : SAB_LALIT                                              *
11     *                                                                     *
12     * Description:                                                        *
13     *                                                                     *
14     * Tran. Code : ZGR_SDR_CAP                                            *
15     *                                                                     *
16     ***********************************************************************
17     * Change History                                                      *
18     *                                                                     *
19     * Mod Date    Changed by    Description                 Chng ID       *
20     *                                                                     *
21     *                                                                     *
22     ***********************************************************************
23
24
25
26     PROGRAM zgr_sdr_cap.
27
28     **************** Data Declaration ***************
29
30     TABLES : ekbe.
31
32     *****screen 200
33     DATA : Del_Num   LIKE likp-vbeln,
34            Post_Date LIKE bapi2017_gm_head_01-pstng_date,
35            gi_matdoc LIKE ekbe-belnr,
36            s_werks   LIKE mseg-werks..
37
38     DATA   BEGIN OF items_po OCCURS 0.
39     INCLUDE STRUCTURE bapiekpo.
40     DATA   END OF items_po.
41
42
43     DATA : BEGIN OF itab_ekbe OCCURS 0,
44              chk_box,
45              ebeln        LIKE ekbe-ebeln,
46              ebelp        LIKE ekbe-ebelp,
47              vgabe        LIKE ekbe-vgabe,
48              belnr        LIKE ekbe-belnr,
49              buzei        LIKE ekbe-buzei,
50              bewtp        LIKE ekbe-bewtp,
51              bwart        LIKE ekbe-bwart,
52              xblnr        LIKE ekbe-xblnr,
53              matnr        LIKE ekbe-matnr,
54              werks        LIKE ekbe-werks,
55              lgort        LIKE ltap-lgort,
56              charg        LIKE ekbe-charg,
57              menge        LIKE ekbe-menge,
58              fin_qty      LIKE ekbe-menge,
59              scan_qty     LIKE ekbe-menge,
60              lsmeh        LIKE ekbe-lsmeh,
61              shkzg        LIKE ekbe-shkzg,
62              unload_pt    LIKE bapi2017_gm_item_show-unload_pt,
63              item_text    LIKE bapi2017_gm_item_show-item_text,
64              censno       LIKE zaa_gis_cios-censusno,
65
66              atnam_mat    LIKE api_vali-atnam,
67              atnam_ser    LIKE api_vali-atnam,
68              atnam_make   LIKE api_vali-atnam,
69              atnam_model  LIKE api_vali-atnam,
70              atnam_vend   LIKE api_vali-atnam,
71              atnam_date   LIKE api_vali-atnam,
72
73              atbez_mat    LIKE api_vali-atbez,
74              atbez_ser    LIKE api_vali-atbez,
75              atbez_make   LIKE api_vali-atbez,
76              atbez_model  LIKE api_vali-atbez,
77              atbez_vend   LIKE api_vali-atbez,
78              atbez_date   LIKE api_vali-atbez,
79
80              atwrt_mat    LIKE api_vali-atwrt,
81              atwrt_ser    LIKE api_vali-atwrt,
82              atwrt_make   LIKE api_vali-atwrt,
83              atwrt_model  LIKE api_vali-atwrt,
84              atwrt_vend   LIKE api_vali-atwrt,
85              atwrt_date   LIKE api_vali-atwrt,
86              batch_flg(1),
87
88
89            END OF itab_ekbe.
90
91     DATA : BEGIN OF itab_mseg OCCURS 0,
92              matnr LIKE mseg-matnr,
93              bwart LIKE ekbe-bwart,
94              smbln LIKE mseg-smbln,
95              menge LIKE mseg-menge,
96            END OF itab_mseg.
97
98
99     DATA : itab_ekbe1       LIKE itab_ekbe OCCURS 0 WITH HEADER LINE,
100           itab_ekbe_canc   LIKE itab_ekbe OCCURS 0 WITH HEADER LINE,
101           itab_ekbe_gr     LIKE itab_ekbe OCCURS 0 WITH HEADER LINE,
102           itab_ekbe_gr_102 LIKE itab_ekbe OCCURS 0 WITH HEADER LINE,
103           itab_ekbe_fn     LIKE itab_ekbe OCCURS 0 WITH HEADER LINE,
104           itab_ekbe_642    LIKE itab_ekbe OCCURS 0 WITH HEADER LINE,
105           wa_ekbe_canc     LIKE itab_ekbe_canc,
106           wa_ekbe_gr       LIKE itab_ekbe_canc,
107           wa_ekbe          LIKE itab_ekbe_canc,
108           wa_final         LIKE itab_ekbe_canc,
109           itab_mseg_641    LIKE mseg OCCURS 0 WITH HEADER LINE,
110           wa_mseg_641      LIKE mseg,
111           itab_mseg_642    LIKE itab_mseg OCCURS 0 WITH HEADER LINE,
112           itab_ekbe220     LIKE itab_ekbe OCCURS 0 WITH HEADER LINE.
113
114    CONSTANTS : c_vgabe     LIKE ekbe-vgabe VALUE '6',
115                c_bwart_101 TYPE ekbe-bwart VALUE '101',
116                c_bwart_102 TYPE ekbe-bwart VALUE '102',
117                c_shkzg_h   TYPE ekbe-shkzg VALUE 'H',
118                c_shkzg_s   TYPE ekbe-shkzg VALUE 'S'.
119
120    DATA : Po_Num LIKE ekbe-ebeln,
121           gi_num LIKE ekbe-belnr.
122
123    *-----------------------INTERNAL TABLE FOR ORG_MAT DOC.--------------*
124    DATA : BEGIN OF items_doc OCCURS 0  ,
125             xauto LIKE mseg-xauto,
126             matnr LIKE mseg-matnr,
127             werks LIKE mseg-werks,
128             lgort LIKE mseg-lgort,
129             charg LIKE mseg-charg,
130           END OF items_doc.
131
132    *-------------------Database tables for serial no.---------------------*
133    TABLES : objk, ser01.
134
135    *----------------------internal tables for serial no.------------------*
136
137    DATA : BEGIN OF itab_objk OCCURS 0 .
138             INCLUDE STRUCTURE objk .
139    DATA :   matdoc_itm LIKE bapi2017_gm_item_show-matdoc_itm,
140             werks      LIKE ser03-werk,
141             charge     LIKE ser03-charge,
142             lagerort   LIKE ser03-lagerort,
143           END OF itab_objk .
144
145    DATA : itab_ser03 LIKE ser03 OCCURS 0 WITH HEADER LINE.
146    DATA : wa_objk LIKE itab_objk.
147    DATA : dtl_objk LIKE objk OCCURS 0 WITH HEADER LINE.
148
149
150
151    ******screen 210
152
153    DATA : gt_inp_210 TYPE i,
154           indx       TYPE i,
155           stepl_cnt  TYPE i VALUE 0,
156           ekbe_fill  TYPE i,
157           save_fill.
158
159
160    ******Screen 215
161    *---------------------Internal Table For Original GR------------------*
162
163
164    DATA : itab_gr LIKE zgr_dtl_original OCCURS 0 WITH HEADER LINE.
165    DATA : BEGIN OF itab_scan_gr .
166             INCLUDE STRUCTURE zgr_dtl_original.
167    DATA fin_qty LIKE eket-menge.
168    DATA : END OF itab_scan_gr.
169
170    DATA : text6(33)    TYPE c,
171           items_ok(1),
172           val_type(10),
173           ok_code      LIKE sy-ucomm.
174
175    DATA : items_post LIKE itab_ekbe OCCURS 0 WITH HEADER LINE.
176
177    *--------------------Serial No. Table for posting----------------------*
178
179    DATA : BEGIN OF SERIAl OCCURS 0.
180             INCLUDE STRUCTURE bapi2017_gm_serialnumber.
181    DATA : END OF serial.
182
183    ******screen 220
184    DATA : flag,
185           gt_inp_220 TYPE i.
186
187    DATA : itab_ekbe_save LIKE itab_ekbe OCCURS 0 WITH HEADER LINE,
188           itab_ekbe_230  LIKE itab_ekbe OCCURS 0 WITH HEADER LINE.
189
190
191    *-----------------Decleration For Batch Characteristics.---------------*
192
193
194    *---------Batch Characteristics Display-----
195    DATA: BEGIN OF itab_v_val_tab OCCURS 0.
196            INCLUDE STRUCTURE  api_vali.
197    DATA :  matdoc_itm LIKE itab_ekbe-ebelp,
198            matnr      LIKE ltbp-matnr,
199            werks      LIKE vbdpl-werks,
200            charg      LIKE vbdpl-charg.
201    DATA  END OF  itab_v_val_tab.
202
203
204
205    DATA: BEGIN OF itab_batch_dtl OCCURS 0.
206            INCLUDE STRUCTURE  api_vali.
207    DATA :  matdoc_itm LIKE itab_ekbe-ebelp,
208            matnr      LIKE ltbp-matnr,
209            werks      LIKE vbdpl-werks,
210            charg      LIKE vbdpl-charg.
211    DATA  END OF  itab_batch_dtl.
212
213
214
215    DATA: v_val_tab  LIKE api_vali OCCURS 0 WITH HEADER LINE,
216          v_char_tab LIKE api_char OCCURS 0 WITH HEADER LINE,
217          v_att_tab  LIKE api_ch_att OCCURS 0 WITH HEADER LINE.
218
219    DATA : bn    TYPE i VALUE 0,
220           bfill TYPE i.
221
222    *---------Batch Characteristics Update-----
223
224    DATA : classnum LIKE bapi1003_key-classnum,
225           clstype  LIKE bapi1003_key-classtype.
226
227    DATA: itab_VALUESNUMNEW LIKE  bapi1003_alloc_values_num OCCURS 0 WITH
228          HEADER LINE.                                 " Table without Data
229
230    DATA:  BEGIN OF iCHARNEW OCCURS 0.
231             INCLUDE STRUCTURE bapi1003_alloc_values_char.
232    DATA:  END OF iCHARNEW.
233
234    DATA:  itab_CURRNEW LIKE bapi1003_alloc_values_curr OCCURS 0 WITH
235           HEADER LINE.                                " Table without Data
236
237
238    DATA:   classif_status LIKE bapi1003_key-status OCCURS 0 WITH
239            HEADER LINE.                              " Table without Data
240
241
242    DATA : BEGIN OF error2 OCCURS 0.
243             INCLUDE STRUCTURE bapiret2.
244    DATA : END OF error2.
245
246    DATA : BEGIN OF error3 OCCURS 0.
247             INCLUDE STRUCTURE bapiret2.
248    DATA : END OF error3.
249
250
251    DATA :  iOBJECTKEY_CONC LIKE bapi1003_key-object.
252    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
253    *Data : itab_batch_mcha like BAPI1003_KEY-OBJECTTABLE value 'MCHA'.
254    DATA : itab_batch_mcha LIKE bapi1003_key-objecttable VALUE 'MCHA'. "#EC CI_USAGE_OK[2370131]
255    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
256    DATA : batch_post LIKE itab_ekbe OCCURS 0 WITH HEADER LINE.
257
258    DATA  : itab_matdtl LIKE bapi1003_object_keys OCCURS 0 WITH HEADER LINE.
259
260    ******screen 230
261    DATA : gt_inp_230 TYPE i,
262           stepl_cnt1 TYPE i VALUE 0.
263
264    DATA : wa_itab_ekbe_save LIKE itab_ekbe_save,
265           itab_ekbe_231     LIKE itab_ekbe OCCURS 0 WITH HEADER LINE,
266           itab_ekbe_post    LIKE itab_ekbe OCCURS 0 WITH HEADER LINE.
267
268    ******screen 231
269    DATA : gt_inp_231 TYPE i.
270
271    ******Screen 240
272    CONSTANTS : c_mvt_ind TYPE kzbew VALUE 'B',
273                c_gm_code TYPE gm_code VALUE '01'.
274
275    DATA : wa_mvt_header LIKE bapi2017_gm_head_01,
276           wa_mvt_code   LIKE bapi2017_gm_code,
277           gr_matdoc     LIKE bapi2017_gm_head_ret-mat_doc,
278           gr_year       LIKE bapi2017_gm_head_ret-doc_year.
279
280    DATA : BEGIN OF itab_item OCCURS 0.
281             INCLUDE STRUCTURE bapi2017_gm_item_create.
282    DATA : END OF itab_item.
283
284    DATA : BEGIN OF itab_ser_num OCCURS 0.
285             INCLUDE STRUCTURE bapi2017_gm_serialnumber.
286    DATA : END OF itab_ser_num.
287
288    DATA : BEGIN OF itab_return OCCURS 0.
289             INCLUDE STRUCTURE bapiret2.
290    DATA : END OF itab_return.
291
292
293
294    *************End of Data declaration***************
295
296    *&---------------------------------------------------------------------*
297    *&      Module  STATUS_0200  OUTPUT
298    *&---------------------------------------------------------------------*
299    *       text
300    *----------------------------------------------------------------------*
301    MODULE status_0200 OUTPUT.
302      SET PF-STATUS 'ZSDR_GR'.
303    *  SET TITLEBAR 'xxx'.
304      CLEAR del_num.
305      CLEAR gi_matdoc.
306      MOVE sy-datum TO post_date.
307    ENDMODULE.                 " STATUS_0200  OUTPUT
308    *&---------------------------------------------------------------------*
309    *&      Module  USER_COMMAND_0200  INPUT
310    *&---------------------------------------------------------------------*
311    *       text
312    *----------------------------------------------------------------------*
313    MODULE user_command_0200 INPUT.
314
315      CASE sy-ucomm.
316        WHEN 'BACK'.
317          LEAVE TO TRANSACTION 'ZMENU_GR_CAP'.
318        WHEN OTHERS.
319          SET SCREEN 200.
320
321      ENDCASE.
322
323      PERFORM get_details.
324      PERFORM get_org_doc_dtl.       " For Maintaining Original Doc. No.
325      PERFORM serial_no_detail.      " For Maintaining Census Number.
326
327      LEAVE TO SCREEN 210.
328
329    ENDMODULE.                 " USER_COMMAND_0200  INPUT
330    *&---------------------------------------------------------------------*
331    *&      Module  STATUS_0210  OUTPUT
332    *&---------------------------------------------------------------------*
333    *       text
334    *----------------------------------------------------------------------*
335    MODULE status_0210 OUTPUT.
336      SET PF-STATUS 'ZSDR_GR'.
337    *  SET TITLEBAR 'xxx'.
338
339      stepl_cnt = stepl_cnt + 1.
340
341      DESCRIBE TABLE itab_ekbe LINES ekbe_fill.
342
343      IF stepl_cnt LE ekbe_fill AND stepl_cnt GT 0.
344        READ TABLE itab_ekbe INDEX stepl_cnt.
345      ELSE.
346        EXIT FROM STEP-LOOP.
347      ENDIF.
348
349    ENDMODULE.                 " STATUS_0210  OUTPUT
350    *&---------------------------------------------------------------------*
351    *&      Module  USER_COMMAND_0210  INPUT
352    *&---------------------------------------------------------------------*
353    *       text
354    *----------------------------------------------------------------------*
355    MODULE user_command_0210 INPUT.
356
357    ENDMODULE.                 " USER_COMMAND_0210  INPUT
358    *&---------------------------------------------------------------------*
359    *&      Module  BUTTONS  INPUT
360    *&---------------------------------------------------------------------*
361    *       text
362    *----------------------------------------------------------------------*
363    MODULE buttons INPUT.
364      CASE sy-ucomm.
365
366        WHEN 'BACK'.
367          stepl_cnt = 0.
368          LEAVE TO SCREEN 200.
369          CLEAR sy-ucomm.
370
371        WHEN 'PD'.
372
373          IF stepl_cnt = ekbe_fill.
374            stepl_cnt = stepl_cnt - 5.
375          ELSE.
376            stepl_cnt = 1.
377          ENDIF.
378
379          CLEAR sy-ucomm.
380
381        WHEN 'PU'.
382          stepl_cnt = stepl_cnt - 9.
383          CLEAR sy-ucomm.
384
385        WHEN 'PRD'.
386          indx = 1.
387          LEAVE TO SCREEN 215.
388          CLEAR sy-ucomm.
389
390        WHEN 'GT'.
391          IF gt_inp_210 > ekbe_fill.
392            MESSAGE i001(0) WITH 'Enter value less than total items'.
393            stepl_cnt =  ekbe_fill - 5.
394          ELSE.
395            stepl_cnt = GT_inp_210 - 1.
396          ENDIF.
397          CLEAR sy-ucomm.
398        WHEN OTHERS.
399          stepl_cnt = 1.
400
401      ENDCASE.
402
403      IF stepl_cnt < 0.
404        stepl_cnt = 0.
405      ENDIF.
406
407      IF stepl_cnt > ekbe_fill.
408        stepl_cnt = stepl_cnt - 5.
409      ENDIF.
410
411    ENDMODULE.                 " BUTTONS  INPUT
412
413
414
415    *&---------------------------------------------------------------------*
416    *&      Module  STATUS_0215  OUTPUT
417    *&---------------------------------------------------------------------*
418    *       text
419    *----------------------------------------------------------------------*
420    MODULE status_0215 OUTPUT.
421    *  SET PF-STATUS 'xxxxxxxx'.
422    *  SET TITLEBAR 'xxx'.
423
424    ENDMODULE.                 " STATUS_0215  OUTPUT
425
426
427    *&---------------------------------------------------------------------*
428    *&      Module  USER_COMMAND_0215  INPUT
429    *&---------------------------------------------------------------------*
430    *       text
431    *----------------------------------------------------------------------*
432    MODULE user_command_0215 INPUT.
433
434
435      CASE ok_code.
436
437        WHEN 'BACK'.
438          CLEAR ok_code.
439          stepl_cnt = 0.
440          LEAVE TO SCREEN 210.
441
442        WHEN 'PRD'.
443          CLEAR ok_code.
444          CLEAR   itab_ekbe220.
445          REFRESH itab_ekbe220 .
446    *-------------------------Clubing Quantity-----------------------------*
447          LOOP AT itab_ekbe.
448            itab_ekbe-fin_qty = 0.
449            MODIFY itab_ekbe TRANSPORTING  fin_qty.
450          ENDLOOP.
451
452          LOOP AT items_post .
453            LOOP AT itab_ekbe WHERE ebelp = items_post-ebelp.
454              itab_ekbe-fin_qty = itab_ekbe-fin_qty + 1.
455              itab_ekbe-chk_box       = 'X'.
456              MODIFY itab_ekbe TRANSPORTING fin_qty chk_box.
457            ENDLOOP.
458          ENDLOOP.
459
460          LOOP AT itab_ekbe.
461            IF itab_ekbe-chk_box = 'X'.
462              MOVE itab_ekbe TO itab_ekbe220.
463              APPEND itab_ekbe220.
464            ENDIF.
465          ENDLOOP.
466    *-------------------------Filling Serial Table-------------------------*
467          CLEAR   serial.
468          REFRESH serial.
469          LOOP AT items_post .
470            serial-matdoc_itm = items_post-ebelp.
471            serial-serialno   = items_post-censno.
472            APPEND serial.
473          ENDLOOP.
474
475    *------------------------- Batch-Characteristic------------------------*
476
477          IF itab_ekbe220[] IS INITIAL.
478            MESSAGE i001(0) WITH 'Records not Saved'.
479            LEAVE TO SCREEN 215.
480          ELSE.
481            LOOP AT itab_ekbe220.
482              IF itab_ekbe220-atwrt_vend = ''.
483                PERFORM batch_characteristic.
484              ENDIF.
485            ENDLOOP.
486            LEAVE TO SCREEN 220.
487          ENDIF.
488
489        WHEN OTHERS.
490
491          CLEAR ok_code.
492          IF itab_scan_gr-zcharg+8(2) = '**'.
493            val_type = itab_scan_gr-zcharg+0(8).
494            itab_scan_gr-zcharg = val_type.
495          ENDIF.
496
497          items_ok = 'F'.
498
499    *-----------------------ITEMS_OK-------------------------*
500
501    ********** ADDED TO CORRECT THE PROBLEM ON THE MATSCAN SCREEN SPK/MAJAZ.
502
503    * LOOP AT ITEMS_po.
504    *
505    *        IF ITAB_SCAN_GR-ZMATNR NE ITEMS_po-MATerial.
506    *          TEXT6 = 'MATERIAL DETAILS NOT OK.'.
507    *
508    *        ELSEif   ITAB_SCAN_GR-ZCHARG NE ITEMS_po-val_type.
509    *          TEXT6 = 'VALUATION DETAILS NOT  OK.'.
510    *
511    *        ELSEif   ITAB_SCAN_GR-ZLGORT NE ITEMS_po-store_loc.
512    *          TEXT6 = 'STORAGE LOCATION DETAILS NOT  OK.'.
513    *
514    *        ELSEif  ITAB_SCAN_GR-ZWERKS NE ITEMS_po-plant.
515    *          TEXT6 = 'PLANT DETAILS NOT OK.'.
516    *
517    *          ITEMS_OK = 'F'.
518    *        ELSE .
519    *          TEXT6 = ' MATERIAL DETAILS OK.'.
520    *          ITEMS_OK = 'T'.
521    *          EXIT.
522    *        ENDIF.
523    *      ENDLOOP.
524
525    ********** ADDED TO CORRECT THE PROBLEM ON THE MATSCAN SCREEN SPK/MAJAZ.
526
527          LOOP AT items_doc.
528
529            IF itab_scan_gr-zmatnr NE items_doc-matnr.
530              text6 = 'MATERIAL DETAILS NOT OK.'.
531
532            ELSEIF   itab_scan_gr-zcharg NE items_doc-charg .
533              text6 = 'VALUATION DETAILS NOT  OK.'.
534
535            ELSEIF   itab_scan_gr-zlgort NE items_doc-lgort .
536              text6 = 'STORAGE LOCATION DETAILS NOT  OK.'.
537
538            ELSEIF  itab_scan_gr-zwerks NE items_doc-werks.
539              text6 = 'PLANT DETAILS NOT OK.'.
540
541              items_ok = 'F'.
542            ELSE .
543              text6 = ' MATERIAL DETAILS OK.'.
544              items_ok = 'T'.
545              EXIT.
546            ENDIF.
547          ENDLOOP.
548
549    *-----------------------------SAVING DATA------------------------------*
550
551          DATA : sernr_ok(1).
552          CLEAR sernr_ok.
553    *----------Census Number Validation--------*
554          IF items_ok = 'T'.
555            LOOP AT itab_objk WHERE sernr = itab_scan_gr-zcensno   AND
556                                     matnr = itab_scan_gr-zmatnr AND
557                                    charge = itab_scan_gr-zcharg.
558              sernr_ok = 'T'.
559            ENDLOOP.
560
561            IF sernr_ok <> 'T'.                          " 1 if sernr_ok
562              MESSAGE i001(0) WITH 'Census Number is not Correct'.
563              text6 = 'Census Number is not Correct'.
564              itab_scan_gr-fin_qty = 0.
565              LEAVE TO SCREEN 215.
566            ELSE.
567              LOOP AT items_post.
568                IF items_post-censno = itab_scan_gr-zCENSNO.    " 2if
569                  MESSAGE i001(0) WITH 'Census Number is Already Scanned'.
570                  text6 = 'Census Number is Already Scanned'.
571                  sernr_ok = 'F'.
572                  itab_scan_gr-fin_qty = 0.
573                  EXIT.
574                ENDIF.                                          " 2 ENDIF
575              ENDLOOP.
576
577              IF sernr_ok = 'T'.                                " 3 if
578
579                LOOP AT itab_objk WHERE sernr = itab_scan_gr-zcensno   AND
580                                         matnr = itab_scan_gr-zmatnr AND
581                                        charge = itab_scan_gr-zcharg.
582                  LOOP AT itab_ekbe.
583                    IF itab_ekbe-ebelp = itab_objk-matdoc_itm.
584                      IF itab_ekbe-menge > itab_ekbe-scan_qty.
585                        items_post-matnr   = itab_ekbe-matnr.
586                        items_post-werks   = itab_ekbe-werks.
587                        items_post-lgort   = itab_ekbe-lgort.
588                        items_post-charg   = itab_ekbe-charg.
589                        items_post-censno  = itab_objk-sernr.
590                        items_post-ebelp   = itab_ekbe-ebelp.
591                        APPEND items_post.
592                        itab_ekbe-scan_qty = itab_ekbe-scan_qty + 1.
593                        itab_scan_gr-fin_qty = itab_ekbe-scan_qty.
594                        MODIFY itab_ekbe TRANSPORTING scan_qty.
595                        text6 = 'Serial Number Saved'.
596    *-------- Table For Maintaining Original Material Doc.----------------*
597                        itab_gr-zser_no = itab_gr-zser_no + 1.
598                        itab_gr-zmblnr  = itab_scan_gr-zmblnr.
599                        itab_gr-zdate   = itab_scan_gr-zdate.
600                        itab_gr-zmatnr  = itab_scan_gr-zmatnr.
601                        itab_gr-zwerks  = itab_scan_gr-zwerks.
602                        itab_gr-zlgort  = itab_scan_gr-zlgort.
603                        itab_gr-zcharg  = itab_scan_gr-zcharg.
604                        itab_gr-zcensno = itab_scan_gr-zCENSNO.
605
606                        APPEND itab_gr.
607    *----------------------------------------------------------------------*
608                        EXIT.
609                      ELSE.
610                        MESSAGE i001(0) WITH 'Quantity Exceed Avail. Quantity'
611                                                               itab_ekbe-menge.
612                        text6 = 'Quantity Exceeds Available Quantity'.
613
614                      ENDIF.
615                    ENDIF.
616                  ENDLOOP.
617                ENDLOOP.
618              ENDIF.                                            " 3 endif
619
620            ENDIF.                                        "1 endif of sernr_ok
621          ELSE.
622            itab_scan_gr-fin_qty = 0.
623
624          ENDIF.
625
626
627      ENDCASE.
628
629
630
631    ENDMODULE.                 " USER_COMMAND_0215  INPUT
632
633
634
635    *&---------------------------------------------------------------------*
636    *&      Module  STATUS_0220  OUTPUT
637    *&---------------------------------------------------------------------*
638    *       text
639    *----------------------------------------------------------------------*
640    MODULE status_0220 OUTPUT.
641      SET PF-STATUS 'ZSDR_GR220'.
642    *  SET TITLEBAR 'xxx'.
643
644      DESCRIBE TABLE itab_ekbe220 LINES ekbe_fill.
645      READ TABLE itab_ekbe220     INDEX indx.
646    *  READ TABLE itab_ekbe_qty INDEX indx.
647
648    ENDMODULE.                 " STATUS_0220  OUTPUT
649
650
651    *&---------------------------------------------------------------------*
652    *&      Module  USER_COMMAND_0220  INPUT
653    *&---------------------------------------------------------------------*
654    *       text
655    *----------------------------------------------------------------------*
656    MODULE user_command_0220 INPUT.
657
658
659      MODIFY itab_ekbe220 INDEX iNDX TRANSPORTING chk_box item_text
660                                                           unload_pt.
661
662      IF itab_ekbe220-chk_box = 'X'.
663        MODIFY itab_ekbe220 INDEX iNDX TRANSPORTING item_text unload_pt
664                                                                 lgort.
665      ENDIF.
666
667      CASE sy-ucomm.
668        WHEN 'BACK'.
669          stepl_cnt = 0.
670          LEAVE TO SCREEN 210.
671
672        WHEN 'NEXT'.
673          IF indx < ekbe_fill.
674            indx = indx + 1.
675            READ TABLE itab_ekbe220     INDEX indx.
676    *          READ TABLE itab_ekbe_qty INDEX indx.
677          ENDIF.
678          SET SCREEN 220.
679          CLEAR sy-ucomm.
680
681        WHEN 'PRV'.
682          IF indx > 1.
683            indx = indx - 1.
684            READ TABLE itab_ekbe INDEX indx.
685    *          READ TABLE itab_ekbe_qty INDEX indx.
686          ENDIF.
687          SET SCREEN 220.
688          CLEAR sy-ucomm.
689
690        WHEN 'GT'.
691          IF gt_inp_220 IS INITIAL.
692            SET SCREEN 220.
693          ELSE.
694            indx = gt_inp_220.
695            SET SCREEN 220.
696          ENDIF.
697          CLEAR sy-ucomm.
698
699        WHEN 'SUM'.
700
701          CLEAR itab_ekbe_save.
702          REFRESH itab_ekbe_save.
703          CLEAR itab_ekbe_230.
704          REFRESH itab_ekbe_230.
705
706          LOOP AT itab_ekbe220.
707            IF itab_ekbe220-chk_box = 'X'.
708              MOVE-CORRESPONDING itab_ekbe220 TO itab_ekbe_save.
709              MOVE-CORRESPONDING itab_ekbe220 TO itab_ekbe_230.
710              APPEND itab_ekbe_save.
711              APPEND itab_ekbe_230.
712            ENDIF.
713          ENDLOOP.
714          IF itab_ekbe_save IS INITIAL.
715            SET SCREEN 220.
716          ELSE.
717            LEAVE TO SCREEN 230.
718          ENDIF.
719
720          CLEAR sy-ucomm.
721
722        WHEN OTHERS.
723          SET SCREEN 220.
724          CLEAR sy-ucomm.
725
726
727
728
729      ENDCASE.
730
731    ENDMODULE.                 " USER_COMMAND_0220  INPUT
732    *&---------------------------------------------------------------------*
733    *&      Module  STATUS_0230  OUTPUT
734    *&---------------------------------------------------------------------*
735    *       text
736    *----------------------------------------------------------------------*
737    MODULE status_0230 OUTPUT.
738      SET PF-STATUS 'ZSDR_GR230'.
739    *  SET TITLEBAR 'xxx'.
740      DESCRIBE TABLE itab_ekbe_save LINES ekbe_fill.
741      DESCRIBE TABLE itab_ekbe_230 LINES  save_fill.
742      READ TABLE itab_ekbe_230 INDEX sy-stepl.
743      IF sy-stepl > save_fill.
744        EXIT FROM STEP-LOOP.
745      ENDIF.
746
747    ENDMODULE.                 " STATUS_0230  OUTPUT
748    *&---------------------------------------------------------------------*
749    *&      Module  USER_COMMAND_0230  INPUT
750    *&---------------------------------------------------------------------*
751    *       text
752    *----------------------------------------------------------------------*
753    MODULE user_command_0230 INPUT.
754
755      IF sy-stepl > save_fill.
756        EXIT FROM STEP-LOOP.
757      ENDIF.
758
759      MODIFY itab_ekbe_230 INDEX sy-stepl TRANSPORTING lgort chk_box.
760
761    *  LOOP AT itab_ekbe WHERE ebelp = itab_ekbe_230-ebelp.
762    *
763    *    IF itab_ekbe_230-menge >  itab_ekbe_qty-menge .
764    *      MESSAGE I001(0) WITH itab_ekbe_230-ebelp
765    *       'Quantity exceeded than available Quantity' itab_ekbe_qty-menge.
766    *      MESSAGE E001(0) WITH 'Quantity entered is not correct'.
767    *    ELSE.
768    *   MODIFY itab_ekbe_230 INDEX SY-STEPL transporting menge LGORT CHK_BOX
769    *.
770    *
771    *    ENDIF.
772    *
773    *  ENDLOOP.
774
775    ENDMODULE.                 " USER_COMMAND_0230  INPUT
776    *&---------------------------------------------------------------------*
777    *&      Module  BUTTONS_230  INPUT
778    *&---------------------------------------------------------------------*
779    *       text
780    *----------------------------------------------------------------------*
781    MODULE buttons_230 INPUT.
782
783      LOOP AT itab_ekbe_230.
784        MOVE-CORRESPONDING itab_ekbe_230 TO wa_itab_ekbe_save.
785        LOOP AT itab_ekbe_save.
786          IF wa_itab_ekbe_save-ebelp = itab_ekbe_save-ebelp.
787            MODIFY itab_ekbe_save FROM wa_itab_ekbe_save.
788          ENDIF.
789        ENDLOOP.
790      ENDLOOP.
791
792      CASE sy-ucomm.
793
794        WHEN 'BACK'.
795          CLEAR sy-ucomm.
796          REFRESH itab_ekbe_save.
797          REFRESH itab_ekbe_230.
798          REFRESH itab_ekbe_231.
799          SET SCREEN 220.
800          CLEAR sy-ucomm.
801
802        WHEN 'PD'.
803          stepl_cnt1 = ekbe_fill - save_fill + 6.
804          IF stepl_cnt1 <= ekbe_fill.
805            REFRESH itab_ekbe_231.
806            LOOP AT itab_ekbe_save FROM stepl_cnt1 TO ekbe_fill.
807              MOVE-CORRESPONDING itab_ekbe_save TO itab_ekbe_231.
808              APPEND itab_ekbe_231.
809            ENDLOOP.
810            CALL SCREEN 231.
811          ELSE.
812            REFRESH itab_ekbe_231.
813            stepl_cnt1 = ekbe_fill - 4.
814            LOOP AT itab_ekbe_save FROM stepl_cnt1 TO ekbe_fill.
815              MOVE-CORRESPONDING itab_ekbe_save TO itab_ekbe_231.
816              APPEND itab_ekbe_231.
817            ENDLOOP.
818            SET SCREEN 231.
819          ENDIF.
820          CLEAR sy-ucomm.
821
822    *----------------------------------PageUp------------------------------*
823        WHEN 'PU'.
824          stepl_cnt1 = ekbe_fill - save_fill - 4.
825          IF stepl_cnt1 > 0.
826            REFRESH itab_ekbe_231.
827            LOOP AT itab_ekbe_save FROM stepl_cnt1 TO ekbe_fill.
828              MOVE-CORRESPONDING itab_ekbe_save TO itab_ekbe_231.
829              APPEND itab_ekbe_231.
830            ENDLOOP.
831            CALL SCREEN 231.
832          ELSE.
833            REFRESH itab_ekbe_231.
834            LOOP AT itab_ekbe_save FROM 1 TO ekbe_fill.
835              MOVE-CORRESPONDING itab_ekbe_save TO itab_ekbe_231.
836              APPEND itab_ekbe_231.
837            ENDLOOP.
838            SET SCREEN 231.
839          ENDIF.
840          CLEAR sy-ucomm.
841    *----------------------------------GoTo------------------------------*
842
843        WHEN 'GT'.
844          IF gt_inp_230 > ekbe_fill.
845            MESSAGE i001(0) WITH
846                           'Value should not be greater than Total Items'.
847            SET SCREEN 230.
848          ELSEIF gt_inp_230 = ''.
849            MESSAGE i001(0) WITH 'Specify a value'.
850            LEAVE TO SCREEN 230.
851          ENDIF.
852
853          REFRESH itab_ekbe_231.
854          LOOP AT itab_ekbe_save FROM gt_inp_230 TO ekbe_fill.
855            MOVE-CORRESPONDING itab_ekbe_save TO itab_ekbe_231.
856            APPEND itab_ekbe_231.
857          ENDLOOP.
858          CLEAR gt_inp_231.
859          CALL SCREEN 231.
860          CLEAR sy-ucomm.
861    *---------------------------------Post---------------------------------*
862        WHEN 'POST'.
863          LOOP AT itab_ekbe_save.
864            IF itab_ekbe_save-chk_box = 'X'.
865              MOVE-CORRESPONDING itab_ekbe_save TO itab_ekbe_post.
866              APPEND itab_ekbe_post.
867            ENDIF.
868          ENDLOOP.
869          IF itab_ekbe_post IS INITIAL.
870            SET SCREEN 230.
871          ELSE.
872    *------------Internal table for update batch chr.
873
874            LOOP AT itab_ekbe_post.
875              MOVE-CORRESPONDING itab_ekbe_post TO batch_post.
876              APPEND batch_post.
877            ENDLOOP.
878
879            PERFORM batch_update.
880            PERFORM post_bapi.
881            REFRESH : error2,error3.
882            CLEAR : error2,error3.
883
884
885            PERFORM batch_update.
886            COMMIT WORK AND WAIT.
887            LOOP AT itab_return.
888              IF itab_return-id = 'LB' AND
889                   itab_return-number = '045' .
890
891                CLEAR itab_return.
892                REFRESH itab_return.
893
894                PERFORM post_bapi.
895                COMMIT WORK AND WAIT.
896              ENDIF.
897            ENDLOOP.
898            LOOP AT itab_return.
899              IF itab_return-id = 'M3' AND
900                 itab_return-number = '682'.
901
902                CLEAR itab_return.
903                REFRESH itab_return.
904
905                PERFORM post_bapi.
906                COMMIT WORK AND WAIT.
907              ENDIF.
908            ENDLOOP.
909
910
911    *        PERFORM BATCH_UPDATE.
912    **-------------------------------------------------
913    *        perform post_bapi.
914            CALL SCREEN 240.
915          ENDIF.
916          CLEAR sy-ucomm.
917
918      ENDCASE.
919
920    ENDMODULE.                 " BUTTONS_230  INPUT
921
922    *&---------------------------------------------------------------------*
923    *&      Module  STATUS_0231  OUTPUT
924    *&---------------------------------------------------------------------*
925    *       text
926    *----------------------------------------------------------------------*
927    MODULE status_0231 OUTPUT.
928      SET PF-STATUS 'ZSDR_GR230'.
929    *  SET TITLEBAR 'xxx'.
930
931      DESCRIBE TABLE itab_ekbe_save LINES ekbe_fill.
932      DESCRIBE TABLE itab_ekbe_231  LINES save_fill.
933      READ TABLE itab_ekbe_231 INDEX sy-stepl.
934
935      IF sy-stepl > save_fill.
936        EXIT FROM STEP-LOOP.
937      ENDIF.
938
939    ENDMODULE.                 " STATUS_0231  OUTPUT
940    *&---------------------------------------------------------------------*
941    *&      Module  USER_COMMAND_0231  INPUT
942    *&---------------------------------------------------------------------*
943    *       text
944    *----------------------------------------------------------------------*
945    MODULE user_command_0231 INPUT.
946
947      IF sy-stepl > save_fill.
948        EXIT FROM STEP-LOOP.
949      ENDIF.
950
951
952      MODIFY itab_ekbe_231 INDEX sy-stepl TRANSPORTING lgort chk_box.
953
954    *  LOOP AT itab_ekbe WHERE ebelp = itab_ekbe_231-ebelp.
955    *
956    *    IF itab_ekbe_231-menge > Itab_ekbe_qty-menge.
957    *      MESSAGE I001(0) WITH itab_ekbe_231-ebelp
958    *        'Quantity exceeded than available Quantity' itab_ekbe_qty-menge
959    *.
960    *
961    *      MESSAGE E001(0) WITH 'Quantity entered is not correct'.
962    *    ELSE.
963    *   MODIFY itab_ekbe_230 INDEX SY-STEPL transporting menge LGORT CHK_BOX
964    *.
965    *    ENDIF.
966    *
967    *  ENDLOOP.
968
969    ENDMODULE.                 " USER_COMMAND_0231  INPUT
970
971    *&---------------------------------------------------------------------*
972    *&      Module  BUTTONS_231  INPUT
973    *&---------------------------------------------------------------------*
974    *       text
975    *----------------------------------------------------------------------*
976    MODULE buttons_231 INPUT.
977
978      CLEAR wa_itab_ekbe_save.
979      LOOP AT itab_ekbe_231.
980        MOVE-CORRESPONDING itab_ekbe_231 TO wa_itab_ekbe_save.
981        LOOP AT itab_ekbe_save.
982          IF wa_itab_ekbe_save-ebelp = itab_ekbe_save-ebelp.
983            MODIFY itab_ekbe_save FROM wa_itab_ekbe_save.
984          ENDIF.
985        ENDLOOP.
986      ENDLOOP.
987
988
989      CASE sy-ucomm.
990
991        WHEN 'BACK'.
992          CLEAR sy-ucomm.
993          REFRESH itab_ekbe_save.
994          REFRESH itab_ekbe_230.
995          REFRESH itab_ekbe_231.
996          SET SCREEN 220.
997          CLEAR sy-ucomm.
998    *----------------------------------PageDn------------------------------*
999        WHEN 'PD'.
1000         stepl_cnt1 = ekbe_fill - save_fill + 6.
1001         IF stepl_cnt1 <= ekbe_fill.
1002           REFRESH itab_ekbe_230.
1003           LOOP AT itab_ekbe_save FROM stepl_cnt1 TO ekbe_fill.
1004             MOVE-CORRESPONDING itab_ekbe_save TO itab_ekbe_230.
1005             APPEND itab_ekbe_230.
1006           ENDLOOP.
1007           CALL SCREEN 230.
1008         ELSE.
1009           REFRESH itab_ekbe_230.
1010           stepl_cnt1 = ekbe_fill - 4.
1011           LOOP AT itab_ekbe_save FROM stepl_cnt1 TO ekbe_fill.
1012             MOVE-CORRESPONDING itab_ekbe_save TO itab_ekbe_230.
1013             APPEND itab_ekbe_230.
1014           ENDLOOP.
1015           SET SCREEN 230.
1016         ENDIF.
1017         CLEAR sy-ucomm.
1018   *----------------------------------PageUp------------------------------*
1019       WHEN 'PU'.
1020         stepl_cnt1 = ekbe_fill - save_fill - 4.
1021         IF stepl_cnt1 > 0.
1022           REFRESH itab_ekbe_230.
1023           LOOP AT itab_ekbe_save FROM stepl_cnt1 TO ekbe_fill.
1024             MOVE-CORRESPONDING itab_ekbe_save TO itab_ekbe_230.
1025             APPEND itab_ekbe_230.
1026           ENDLOOP.
1027           CALL SCREEN 230.
1028         ELSE.
1029           REFRESH itab_ekbe_230.
1030           LOOP AT itab_ekbe_save FROM 1 TO ekbe_fill.
1031             MOVE-CORRESPONDING itab_ekbe_save TO itab_ekbe_230.
1032             APPEND itab_ekbe_230.
1033           ENDLOOP.
1034
1035           SET SCREEN 230.
1036         ENDIF.
1037         CLEAR sy-ucomm.
1038
1039   *----------------------------------GoTo------------------------------*
1040
1041       WHEN 'GT'.
1042         IF ekbe_fill < gt_inp_231.
1043           MESSAGE i001(0) WITH 'Enter value less than Total Items'.
1044           SET SCREEN 231.
1045
1046         ELSEIF gt_inp_231 = ''.
1047           MESSAGE i001(0) WITH 'Specify a value'.
1048           LEAVE TO SCREEN 231.
1049
1050         ENDIF.
1051
1052         REFRESH itab_ekbe_230.
1053         LOOP AT itab_ekbe_save FROM gt_inp_231 TO ekbe_fill.
1054           MOVE-CORRESPONDING itab_ekbe_save TO itab_ekbe_230.
1055           APPEND itab_ekbe_230.
1056         ENDLOOP.
1057         CLEAR gt_inp_231.
1058         CALL SCREEN 230.
1059         CLEAR sy-ucomm.
1060
1061   *---------------------------------Post---------------------------------*
1062
1063       WHEN 'POST'.
1064         LOOP AT itab_ekbe_save.
1065           IF itab_ekbe_save-chk_box = 'X'.
1066             MOVE-CORRESPONDING itab_ekbe_save TO itab_ekbe_post.
1067             APPEND itab_ekbe_post.
1068           ENDIF.
1069         ENDLOOP.
1070         IF itab_ekbe_post IS INITIAL.
1071           SET SCREEN 231.
1072         ELSE.
1073   *------------Internal table for update batch chr.
1074
1075           LOOP AT itab_ekbe_post.
1076             MOVE-CORRESPONDING itab_ekbe_post TO batch_post.
1077             APPEND batch_post.
1078           ENDLOOP.
1079
1080           PERFORM batch_update.
1081           COMMIT WORK AND WAIT.
1082           PERFORM post_bapi.
1083           COMMIT WORK AND WAIT.
1084           REFRESH : error2,error3.
1085           CLEAR : error2,error3.
1086
1087
1088           PERFORM batch_update.
1089           COMMIT WORK AND WAIT.
1090           LOOP AT itab_return.
1091             IF itab_return-id = 'LB'.
1092               itab_return-number = '045'.
1093
1094               CLEAR itab_return.
1095               REFRESH itab_return.
1096
1097               PERFORM post_bapi.
1098               COMMIT WORK AND WAIT.
1099             ENDIF.
1100           ENDLOOP.
1101           LOOP AT itab_return.
1102             IF itab_return-id = 'M3'.
1103               itab_return-number = '682'.
1104
1105               CLEAR itab_return.
1106               REFRESH itab_return.
1107
1108               PERFORM post_bapi.
1109               COMMIT WORK AND WAIT.
1110             ENDIF.
1111           ENDLOOP.
1112
1113   *        PERFORM BATCH_UPDATE.
1114   **-------------------------------------------------
1115   *        perform post_bapi.
1116           CALL SCREEN 240.
1117         ENDIF.
1118         CLEAR sy-ucomm.
1119
1120     ENDCASE.
1121
1122   ENDMODULE.                 " BUTTONS_231  INPUT
1123
1124   *&---------------------------------------------------------------------*
1125   *&      Module  STATUS_0240  OUTPUT
1126   *&---------------------------------------------------------------------*
1127   *       text
1128   *----------------------------------------------------------------------*
1129   MODULE status_0240 OUTPUT.
1130     SET PF-STATUS 'ZSDR_GR240'.
1131   *  SET TITLEBAR 'xxx'.
1132
1133   ENDMODULE.                 " STATUS_0240  OUTPUT
1134   *&---------------------------------------------------------------------*
1135   *&      Module  USER_COMMAND_0240  INPUT
1136   *&---------------------------------------------------------------------*
1137   *       text
1138   *----------------------------------------------------------------------*
1139   MODULE user_command_0240 INPUT.
1140
1141     CASE sy-ucomm.
1142       WHEN 'BACK'.
1143         LEAVE TO TRANSACTION 'ZGR_SDR_CAP'.
1144
1145       WHEN 'MAIN'.
1146         LEAVE TO TRANSACTION 'ZIMBARCODE_CAP'.
1147
1148       WHEN 'TO'.
1149         LEAVE TO TRANSACTION 'ZTO_GR_CAP'.
1150
1151
1152       WHEN 'PREVSCR'.
1153         IF gr_matdoc IS INITIAL.
1154           CLEAR batch_post.
1155           REFRESH batch_post.
1156           CLEAR itab_item.
1157           REFRESH itab_item.
1158           CLEAR itab_ekbe_post.
1159           REFRESH itab_ekbe_post.
1160           LEAVE TO SCREEN 230.
1161         ELSE.
1162
1163           SET SCREEN 240.
1164         ENDIF.
1165
1166         CLEAR sy-ucomm.
1167
1168     ENDCASE.
1169
1170   ENDMODULE.                 " USER_COMMAND_0240  INPUT
1171
1172
1173
1174   *&---------------------------------------------------------------------*
1175   *&      Form  get_details
1176   *&---------------------------------------------------------------------*
1177   *       text
1178   *----------------------------------------------------------------------*
1179   *  -->  p1        text
1180   *  <--  p2        text
1181   *----------------------------------------------------------------------*
1182   FORM get_details.
1183
1184
1185
1186     DATA: ebeln LIKE mseg-ebeln.
1187     DATA : belnr LIKE ekbe-belnr.
1188     " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1189   *  SELECT SINGLE BELNR  FROM EKBE INTO BELNR
1190   *      WHERE XBLNR = DEL_NUM.
1191     SELECT belnr FROM ekbe   UP TO 1 ROWS INTO belnr WHERE xblnr = del_num
1192     ORDER BY  ebeln ebelp zekkn vgabe gjahr belnr buzei .   ENDSELECT.
1193     " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
1194   *                            XAUTO = '' .
1195     MOVE belnr TO gi_matdoc.
1196
1197     IF Del_Num IS INITIAL.
1198       MESSAGE i001(0) WITH 'Enter the Delivery number'.
1199       CALL SCREEN 200.
1200     ELSEIF gi_matdoc IS INITIAL.
1201       MESSAGE i001(0) WITH 'Enter the GI document number'.
1202       CALL SCREEN 200.
1203     ENDIF.
1204
1205     " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1206   *  SELECT SINGLE ebeln
1207   *           INTO po_num
1208   *           FROM ekbe
1209   *          WHERE belnr = del_num.
1210     SELECT ebeln FROM ekbe   UP TO 1 ROWS INTO po_num WHERE belnr =
1211    del_num  ORDER BY  ebeln ebelp zekkn vgabe gjahr belnr buzei .
1212     ENDSELECT.
1213     " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
1214     IF sy-subrc <> 0.
1215       MESSAGE i001(0) WITH del_num 'delivery number is not valid'.
1216       CALL SCREEN 200.
1217     ENDIF.
1218
1219
1220
1221
1222     SELECT ebeln ebelp werks charg vgabe belnr buzei
1223            bewtp bwart xblnr matnr menge lsmeh shkzg
1224             FROM ekbe
1225             INTO CORRESPONDING FIELDS OF TABLE itab_ekbe
1226            WHERE ebeln = po_num
1227   *           AND vgabe = 1
1228              AND vgabe = c_vgabe
1229              AND xblnr = del_num
1230              AND bwart = '641'.
1231
1232
1233     SELECT smbln matnr menge bwart
1234             FROM mseg
1235             INTO CORRESPONDING FIELDS OF TABLE itab_mseg_642
1236            WHERE ebeln = po_num
1237            AND bwart = '642'
1238            AND xauto = ''.
1239
1240     LOOP AT  itab_mseg_642.
1241       LOOP AT itab_ekbe.
1242         DELETE itab_ekbe WHERE belnr = itab_mseg_642-smbln.
1243       ENDLOOP.
1244     ENDLOOP.
1245
1246
1247
1248
1249
1250
1251
1252
1253
1254     SELECT ebeln ebelp werks charg vgabe belnr buzei
1255            bewtp bwart xblnr matnr menge lsmeh shkzg
1256             FROM ekbe
1257             INTO CORRESPONDING FIELDS OF TABLE itab_ekbe_gr
1258            WHERE ebeln = po_num
1259            AND bwart = '101'.
1260
1261
1262     SELECT ebeln ebelp werks charg vgabe belnr buzei
1263            bewtp bwart xblnr matnr menge lsmeh shkzg
1264             FROM ekbe
1265             INTO CORRESPONDING FIELDS OF TABLE itab_ekbe_gr_102
1266            WHERE ebeln = po_num
1267            AND bwart = '102'.
1268
1269     LOOP AT itab_ekbe_gr_102.
1270       DELETE itab_ekbe_gr WHERE matnr = itab_ekbe_gr_102-matnr.
1271     ENDLOOP.
1272
1273
1274
1275
1276
1277
1278     LOOP AT itab_ekbe_gr.
1279       DELETE itab_ekbe WHERE matnr = itab_ekbe_gr-matnr.
1280     ENDLOOP.
1281
1282
1283
1284
1285
1286
1287
1288
1289
1290     " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1291     READ TABLE itab_ekbe INDEX 1.                         "#EC CI_NOORDER
1292     " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1293
1294     MOVE itab_ekbe-belnr TO gi_num.
1295
1296
1297
1298     SELECT ebeln ebelp matnr menge bwart shkzg
1299             FROM ekbe
1300             INTO CORRESPONDING FIELDS OF TABLE itab_ekbe1
1301            WHERE ebeln = po_num.
1302   *          AND bwart = '101'
1303   *           AND xblnr = gi_matdoc.
1304
1305     SORT itab_ekbe1 BY ebeln ebelp.
1306     CLEAR indx.
1307
1308     LOOP AT itab_ekbe.
1309       indx = sy-tabix.
1310       LOOP AT  itab_ekbe1 WHERE ebeln = itab_ekbe-ebeln
1311                             AND ebelp = itab_ekbe-ebelp
1312                             AND matnr = itab_ekbe-matnr.
1313         IF itab_ekbe1-bwart = c_bwart_102 AND
1314            itab_ekbe1-shkzg = c_shkzg_h.
1315
1316           itab_ekbe-menge = itab_ekbe-menge - itab_ekbe1-menge.
1317           MODIFY itab_ekbe INDEX indx .
1318
1319         ELSEIF itab_ekbe1-bwart = c_bwart_101 AND
1320                itab_ekbe1-shkzg = c_shkzg_s.
1321
1322           itab_ekbe-menge = itab_ekbe-menge + itab_ekbe1-menge.
1323           MODIFY itab_ekbe INDEX indx .
1324
1325         ENDIF.
1326       ENDLOOP.
1327     ENDLOOP.
1328
1329     " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 14.06.2026  for ATC
1330   *  CALL FUNCTION 'BAPI_PO_GETDETAIL'
1331     CALL FUNCTION 'BAPI_PO_GETDETAIL1'  "#EC CI_USAGE_OK[2438131]
1332       " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 14.06.2026 for ATC
1333       EXPORTING
1334         purchaseorder = po_num
1335   **    ITEMS                            = 'X'
1336   *     ACCOUNT_ASSIGNMENT               = ' '
1337   *     SCHEDULES     = ' '
1338   *     HISTORY       = ' '
1339   *     ITEM_TEXTS    = ' '
1340   *     HEADER_TEXTS  = ' '
1341   *     SERVICES      = ' '
1342   *     CONFIRMATIONS = ' '
1343   *     SERVICE_TEXTS = ' '
1344   *     EXTENSIONS    = ' '
1345   *  IMPORTING
1346   *     PO_HEADER     =
1347   *     PO_ADDRESS    =
1348       TABLES
1349   *     PO_HEADER_TEXTS                  =
1350         po_items      = items_po
1351   *     PO_ITEM_ACCOUNT_ASSIGNMENT       =
1352   *     PO_ITEM_SCHEDULES                =
1353   *     PO_ITEM_CONFIRMATIONS            =
1354   *     PO_ITEM_TEXTS =
1355   *     PO_ITEM_HISTORY                  =
1356   *     PO_ITEM_HISTORY_TOTALS           =
1357   *     PO_ITEM_LIMITS                   =
1358   *     PO_ITEM_CONTRACT_LIMITS          =
1359   *     PO_ITEM_SERVICES                 =
1360   *     PO_ITEM_SRV_ACCASS_VALUES        =
1361   *     RETURN        =
1362   *     PO_SERVICES_TEXTS                =
1363   *     EXTENSIONOUT  =
1364       .
1365
1366     LOOP AT items_po.
1367       LOOP AT itab_ekbe WHERE ebeln = items_po-po_number
1368                           AND ebelp = items_po-po_item
1369                           AND matnr = items_po-material.
1370         IF itab_ekbe-menge EQ 0.
1371           DELETE itab_ekbe.
1372         ELSE.
1373           itab_ekbe-werks = items_po-plant.
1374           itab_ekbe-matnr = items_po-material.
1375           itab_ekbe-lgort = items_po-store_loc.
1376           itab_ekbe-charg = items_po-val_type.
1377           itab_ekbe-lsmeh = items_po-unit.
1378           MODIFY itab_ekbe TRANSPORTING matnr werks lgort charg lsmeh.
1379         ENDIF.
1380       ENDLOOP.
1381     ENDLOOP.
1382
1383     IF itab_ekbe[] IS INITIAL.
1384       MESSAGE i001(0) WITH gi_matdoc
1385                          'document does not contain any selectable items'.
1386       LEAVE TO SCREEN 200.
1387     ENDIF.
1388
1389     LOOP AT itab_ekbe.
1390       itab_ekbe-fin_qty  = 0.
1391       itab_ekbe-scan_qty = 0.
1392       MODIFY itab_ekbe TRANSPORTING fin_qty scan_qty.
1393     ENDLOOP.
1394
1395
1396   ENDFORM.                    " get_details
1397
1398
1399
1400   *----------------------------------------------------------------------*
1401   *----------------------FORM GET_ORG_DOC_DTL----------------------------*
1402   *----------------------------------------------------------------------*
1403
1404
1405   FORM get_org_doc_dtl.
1406
1407     SELECT xauto matnr werks lgort charg FROM mseg
1408         INTO CORRESPONDING FIELDS OF TABLE items_doc
1409                         WHERE mblnr = gi_matdoc AND
1410                               xauto = '' .
1411
1412     " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1413     SORT items_doc. .
1414     " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
1415     LOOP AT items_doc.
1416       s_werks = items_doc-werks.
1417       EXIT.
1418     ENDLOOP.
1419
1420   ENDFORM.                     " Get_Org_Doc_Dtl
1421
1422
1423
1424   *&---------------------------------------------------------------------*
1425   *&      Form  serial_no_detail
1426   *&---------------------------------------------------------------------*
1427   *       text
1428   *----------------------------------------------------------------------*
1429   *  -->  p1        text
1430   *  <--  p2        text
1431   *----------------------------------------------------------------------*
1432   FORM serial_no_detail.
1433
1434
1435   *------------------------serial_no-------------------------------------*
1436
1437     REFRESH dtl_objk.
1438     REFRESH itab_ser03.
1439     REFRESH itab_objk.
1440     SELECT * FROM objk INTO TABLE dtl_objk.
1441
1442     SELECT  * INTO TABLE itab_ser03 FROM ser03
1443                                  WHERE mblnr = gi_matdoc
1444                                  AND   shkzg = 'H'.
1445
1446     LOOP AT itab_ser03.
1447       LOOP AT dtl_objk WHERE obknr = itab_ser03-obknr.
1448         itab_objk-sernr    = dtl_objk-sernr.
1449         itab_objk-matnr    = dtl_objk-matnr.
1450         itab_objk-werks    = itab_ser03-werk.
1451         itab_objk-charge   = itab_ser03-charge.
1452         itab_objk-lagerort = itab_ser03-lagerort.
1453         APPEND  itab_objk.
1454       ENDLOOP.
1455     ENDLOOP.
1456
1457   *------------------------Putting Serial no in Items--------------------*
1458
1459     LOOP AT itab_ekbe.
1460       LOOP AT itab_objk WHERE
1461                        matnr    = itab_ekbe-matnr  AND
1462   *                     WERKS    = itab_ekbe-werks  and
1463                        charge   = itab_ekbe-charg  .
1464         "  LAGERORT = itab_ekbe-STORE_LOC.
1465   *      itab_objk-CHARGE = itab_ekbe-charg.
1466         itab_objk-matdoc_itm = itab_ekbe-ebelp.
1467         MODIFY itab_objk TRANSPORTING matdoc_itm.
1468       ENDLOOP.
1469     ENDLOOP.
1470
1471     LOOP AT itab_objk WHERE matdoc_itm = 0.
1472       DELETE itab_objk.
1473     ENDLOOP.
1474
1475
1476   ENDFORM.                    " serial_no_detail
1477
1478
1479
1480   *&---------------------------------------------------------------------*
1481   *&      Form  batch_characteristic
1482   *&---------------------------------------------------------------------*
1483   *       text
1484   *----------------------------------------------------------------------*
1485   *  -->  p1        text
1486   *  <--  p2        text
1487   *----------------------------------------------------------------------*
1488   FORM batch_characteristic.
1489
1490     DATA batch_flg(1).
1491
1492
1493     CALL FUNCTION 'QC01_BATCH_VALUES_READ'
1494       EXPORTING
1495         i_val_matnr    = itab_ekbe220-matnr
1496         i_val_werks    = s_werks
1497         i_val_charge   = itab_ekbe220-charg
1498   *     I_LANGUAGE     = SY-LANGU
1499   *     I_DATE         = SY-DATUM
1500   * IMPORTING
1501   *     E_CLASS        =
1502   *     E_CLASS_TYPE   =
1503       TABLES
1504         t_val_tab      = v_val_tab
1505         t_char_tab     = v_char_tab
1506         t_att_tab      = v_att_tab
1507       EXCEPTIONS
1508         no_class       = 1
1509         internal_error = 2
1510         no_values      = 3
1511         no_chars       = 4
1512         OTHERS         = 5.
1513     IF sy-subrc <> 0.
1514   * MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
1515   *         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
1516     ELSE.
1517       batch_flg = 'F'.
1518       LOOP AT v_val_tab .
1519         IF v_val_tab-atnam = 'Z_ONGC_MATDESC'.
1520           batch_flg = 'T'.
1521           EXIT.
1522         ENDIF.
1523       ENDLOOP.
1524       IF batch_flg = 'F'.
1525         v_val_tab-atnam = 'Z_ONGC_MATDESC'.
1526         v_val_tab-atbez = 'MATERIAL DESCRIPTION'.
1527         v_val_tab-atwrt = ''.
1528         APPEND v_val_tab.
1529       ENDIF.
1530
1531
1532       batch_flg = 'F'.
1533       LOOP AT v_val_tab .
1534   *      IF v_val_tab-ATNAM = 'Z_VENDOR_SERIAL_NO'.  "in 200 client
1535         IF v_val_tab-atnam = 'ZMM_ONGC_MFR_SERIAL'.   "In 400 client
1536
1537           batch_flg = 'T'.
1538           EXIT.
1539         ENDIF.
1540       ENDLOOP.
1541       IF batch_flg = 'F'.
1542         v_val_tab-atnam = 'ZMM_ONGC_MFR_SERIAL'.     "In 400 Client
1543   *      v_val_tab-ATNAM = 'Z_VENDOR_SERIAL_NO'. in 200 client
1544         v_val_tab-atbez = 'SERIAL NUMBER SPECIFY -VENDOR'.
1545         v_val_tab-atwrt = ''.
1546         APPEND v_val_tab.
1547       ENDIF.
1548
1549
1550       batch_flg = 'F'.
1551       LOOP AT v_val_tab .
1552         IF v_val_tab-atnam = 'ZMM_ONGC_MAKE'.
1553           batch_flg = 'T'.
1554           EXIT.
1555         ENDIF.
1556       ENDLOOP.
1557       IF batch_flg = 'F'.
1558         v_val_tab-atnam = 'ZMM_ONGC_MAKE'.
1559         v_val_tab-atbez = 'MAKE OF THE MATERIAL'.
1560         v_val_tab-atwrt = ''.
1561         APPEND v_val_tab.
1562       ENDIF.
1563
1564
1565
1566       batch_flg = 'F'.
1567       LOOP AT v_val_tab .
1568         IF v_val_tab-atnam = 'ZMM_ONGC_MODEL'.
1569           batch_flg = 'T'.
1570           EXIT.
1571         ENDIF.
1572       ENDLOOP.
1573       IF batch_flg = 'F'.
1574         v_val_tab-atnam = 'ZMM_ONGC_MODEL'.
1575         v_val_tab-atbez = 'MODEL OF THE MATERIAL'.
1576         v_val_tab-atwrt = ''.
1577         APPEND v_val_tab.
1578       ENDIF.
1579
1580
1581       LOOP AT v_val_tab.
1582         itab_batch_dtl-atnam      =   v_val_tab-atnam.
1583         itab_batch_dtl-atbez      =   v_val_tab-atbez.
1584         itab_batch_dtl-atwrt      =   v_val_tab-atwrt.
1585         itab_batch_dtl-matdoc_itm =   itab_ekbe220-ebelp.
1586         itab_batch_dtl-matnr      =   itab_ekbe220-matnr.
1587         itab_batch_dtl-werks      =   itab_ekbe220-werks.
1588         itab_batch_dtl-charg      =   itab_ekbe220-charg.
1589         APPEND itab_batch_dtl.
1590       ENDLOOP.
1591
1592     ENDIF.
1593
1594   *---------------------Updating batch data into items------------------*
1595
1596     LOOP AT  itab_batch_dtl.
1597       IF itab_batch_dtl-atnam = 'Z_ONGC_MATDESC'.
1598         itab_ekbe220-atnam_mat  =  itab_batch_dtl-atnam .
1599         itab_ekbe220-atbez_mat  =  itab_batch_dtl-ATbez.
1600         itab_ekbe220-atwrt_mat  =  itab_batch_dtl-ATwrt.
1601         MODIFY itab_ekbe220  TRANSPORTING atnam_mat atbez_mat atwrt_mat
1602                              WHERE ebelp = itab_batch_dtl-matdoc_itm.
1603       ENDIF  .
1604
1605   *    IF itab_batch_dtl-ATNAM = 'Z_VENDOR_SERIAL_NO'. in 200 client
1606       IF itab_batch_dtl-atnam = 'ZMM_ONGC_MFR_SERIAL'.  "In 400 Client
1607         itab_ekbe220-atnam_ser  =  itab_batch_dtl-atnam .
1608         itab_ekbe220-atbez_ser  =  itab_batch_dtl-ATbez.
1609         itab_ekbe220-atwrt_ser  =  itab_batch_dtl-ATwrt.
1610         MODIFY itab_ekbe220 TRANSPORTING atnam_ser atbez_ser atwrt_ser
1611                            WHERE ebelp = itab_batch_dtl-matdoc_itm.
1612       ENDIF.
1613
1614       IF itab_batch_dtl-atnam = 'Z_ONGC_VENDNO'.
1615         itab_ekbe220-atnam_vend  =  itab_batch_dtl-atnam .
1616         itab_ekbe220-atbez_vend  =  itab_batch_dtl-ATbez.
1617         itab_ekbe220-atwrt_vend  =  itab_batch_dtl-ATwrt.
1618         MODIFY itab_ekbe220  TRANSPORTING atnam_vend atbez_vend
1619                    atwrt_vend WHERE ebelp = itab_batch_dtl-matdoc_itm.
1620       ENDIF  .
1621
1622       IF itab_batch_dtl-atnam = 'Z_ONGC_GRDATE'.
1623         itab_ekbe220-atnam_date  =  itab_batch_dtl-atnam .
1624         itab_ekbe220-atbez_date  =  itab_batch_dtl-ATbez.
1625         itab_ekbe220-atwrt_date  =  itab_batch_dtl-ATwrt.
1626         MODIFY itab_ekbe220  TRANSPORTING atnam_date atbez_date
1627                     atwrt_date WHERE ebelp = itab_batch_dtl-matdoc_itm.
1628       ENDIF  .
1629
1630       IF itab_batch_dtl-atnam = 'ZMM_ONGC_MAKE'.
1631         itab_ekbe220-atnam_make  =  itab_batch_dtl-atnam .
1632         itab_ekbe220-atbez_make  =  itab_batch_dtl-ATbez.
1633         itab_ekbe220-atwrt_make  =  itab_batch_dtl-ATwrt.
1634         MODIFY itab_ekbe220 TRANSPORTING atnam_make atbez_make atwrt_make
1635                                  WHERE ebelp = itab_batch_dtl-matdoc_itm.
1636       ENDIF .
1637
1638       IF itab_batch_dtl-atnam = 'ZMM_ONGC_MODEL'.
1639         itab_ekbe220-atnam_model  =  itab_batch_dtl-atnam .
1640         itab_ekbe220-atbez_model  =  itab_batch_dtl-ATbez.
1641         itab_ekbe220-atwrt_model  =  itab_batch_dtl-ATwrt.
1642         MODIFY itab_ekbe220 TRANSPORTING atnam_model atbez_model
1643                      atwrt_model WHERE ebelp = itab_batch_dtl-matdoc_itm.
1644       ENDIF .
1645
1646     ENDLOOP.
1647
1648
1649
1650
1651     CLEAR v_val_tab.
1652     REFRESH v_val_tab.
1653     CLEAR itab_batch_dtl.
1654     REFRESH itab_batch_dtl.
1655
1656   *-------------------------------------------------------
1657
1658   ENDFORM.                    " batch_characteristic
1659
1660
1661   *----------------------------------------------------------------------*
1662   *-------------------------------post_bapi------------------------------*
1663   *----------------------------------------------------------------------*
1664
1665   FORM post_bapi.
1666
1667
1668
1669   *----------------------Serial Number validation------------------------*
1670     DATA : BEGIN OF serial_no OCCURS 0.
1671              INCLUDE STRUCTURE bapi2017_gm_serialnumber.
1672     DATA : END OF serial_no.
1673     DATA : serial_final LIKE serial OCCURS 0 WITH HEADER LINE.
1674     DATA count TYPE i VALUE 0.
1675
1676     CLEAR   serial_no.
1677     REFRESH serial_no.
1678     CLEAR   sernr_ok.
1679
1680     LOOP AT serial.
1681       sernr_ok = 'F'.
1682       LOOP AT itab_ekbe_post .
1683         IF itab_ekbe_post-ebelp = serial-matdoc_itm.
1684           sernr_ok = 'T'.
1685           EXIT.
1686         ENDIF.
1687       ENDLOOP.
1688       IF sernr_ok <> 'T'.
1689         DELETE serial.
1690       ENDIF.
1691     ENDLOOP.
1692
1693     CLEAR sernr_ok.
1694     SORT serial BY matdoc_itm.
1695
1696
1697     LOOP AT serial.
1698       AT NEW matdoc_itm.
1699         count = count + 1.
1700       ENDAT.
1701       MOVE serial TO serial_no.
1702       serial_no-matdoc_itm = count.
1703       APPEND serial_no.
1704     ENDLOOP.
1705
1706
1707
1708
1709   *--------------------------------------header data--------------------*
1710
1711     wa_mvt_header-pstng_date  = post_date.
1712     wa_mvt_header-doc_date    = post_date.
1713     wa_mvt_header-pr_uname    = sy-uname.
1714     wa_mvt_header-ref_doc_no  = gi_matdoc.
1715     wa_mvt_code-gm_code       = c_gm_code.
1716     REFRESH: itab_item,Serial_final,itab_return.
1717     CLEAR :itab_item,serial_final,itab_return.
1718     LOOP AT itab_ekbe_post.
1719       itab_item-material      = itab_ekbe_post-matnr.
1720       itab_item-plant         = itab_ekbe_post-werks.
1721       itab_item-stge_loc      = itab_ekbe_post-lgort.
1722       itab_item-batch         = itab_ekbe_post-charg.
1723       itab_item-val_type      = itab_ekbe_post-charg.
1724       itab_item-entry_qnt     = itab_ekbe_post-fin_qty.
1725       itab_item-entry_uom     = itab_ekbe_post-lsmeh.
1726       itab_item-entry_uom_iso = itab_ekbe_post-lsmeh.
1727       itab_item-po_item       = itab_ekbe_post-ebelp.
1728
1729       itab_item-item_text     = itab_ekbe_post-item_text.
1730       itab_item-unload_pt     = itab_ekbe_post-unload_pt.
1731
1732       itab_item-po_number     = po_num.
1733       itab_item-ref_doc       = gi_matdoc.
1734       itab_item-move_type     = c_bwart_101.
1735       itab_item-mvt_ind       = c_mvt_ind.
1736       itab_item-deliv_numb_to_search = del_num.
1737       APPEND itab_item.
1738     ENDLOOP.
1739
1740     SORT itab_item BY material.
1741     LOOP AT itab_item.
1742       READ TABLE itab_item INDEX sy-tabix.
1743       itab_item-res_item = sy-tabix.
1744       MODIFY itab_item TRANSPORTING res_item.
1745     ENDLOOP.
1746
1747
1748
1749     LOOP AT itab_item.
1750       LOOP AT serial WHERE matdoc_itm   = itab_item-po_item.
1751         serial_final-matdoc_itm = itab_item-res_item.
1752         Serial_final-serialno = serial-serialno.
1753         APPEND Serial_final.
1754       ENDLOOP.
1755     ENDLOOP.
1756
1757     " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1758     CALL FUNCTION 'BAPI_GOODSMVT_CREATE' "#EC CI_USAGE_OK[2438131]
1759       " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
1760       EXPORTING
1761         goodsmvt_header       = wa_mvt_header
1762         goodsmvt_code         = wa_mvt_code
1763   *     TESTRUN               = ' '
1764       IMPORTING
1765   *     GOODSMVT_HEADRET      =
1766         materialdocument      = gr_matdoc
1767         matdocumentyear       = gr_year
1768       TABLES
1769         goodsmvt_item         = itab_item
1770         goodsmvt_serialnumber = Serial_final
1771         return                = itab_return.
1772
1773     CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
1774     COMMIT WORK AND WAIT.
1775     SET PARAMETER ID 'GRMATDOC' FIELD gr_matdoc.
1776     SET PARAMETER ID 'GRYEAR'   FIELD gr_year.
1777
1778
1779   ENDFORM.                    "post_bapi
1780
1781
1782   *&---------------------------------------------------------------------*
1783   *&      Form  BATCH_UPDATE
1784   *&---------------------------------------------------------------------*
1785   *       text
1786   *----------------------------------------------------------------------*
1787   *  -->  p1        text
1788   *  <--  p2        text
1789   *----------------------------------------------------------------------*
1790   FORM batch_update.
1791
1792     LOOP AT batch_post.
1793
1794       CLEAR itab_matdtl.
1795       REFRESH itab_matdtl.
1796
1797       CLEAR iCHARNEW.
1798       REFRESH iCHARNEW.
1799
1800   *-----------------------------for Object Key--------------------------*
1801
1802
1803       itab_matdtl-key_field = 'MATNR'.
1804       itab_matdtl-value_ext =  batch_post-matnr.
1805       APPEND itab_matdtl.
1806
1807       itab_matdtl-key_field = 'WERKS'.
1808       itab_matdtl-value_ext =  batch_post-werks.
1809       APPEND itab_matdtl.
1810
1811       itab_matdtl-key_field = 'CHARG'.
1812       itab_matdtl-value_ext =  batch_post-charg.
1813       APPEND itab_matdtl.
1814
1815
1816       CALL FUNCTION 'BAPI_OBJCL_CONCATENATEKEY'
1817         EXPORTING
1818           objecttable    = itab_batch_mcha
1819         IMPORTING
1820           objectkey_conc = iOBJECTKEY_CONC
1821         TABLES
1822           objectkeytable = itab_matdtl
1823           return         = error2.
1824
1825
1826   *-------------------------for Update Function module------------------*
1827
1828       iCHARNEW-charact       = batch_post-atnam_mat.
1829       " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1830   *    iCHARNEW-VALUE_NEUTRAL = BATCH_POST-atwrt_mat.
1831       iCHARNEW-value_neutral = CONV #( batch_post-atwrt_mat ) .
1832       " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
1833       iCHARNEW-charact_descr = batch_post-atbez_mat.
1834       APPEND iCHARNEW.
1835
1836       iCHARNEW-charact       = batch_post-atnam_ser.
1837       " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1838   *    iCHARNEW-VALUE_NEUTRAL = BATCH_POST-atwrt_ser.
1839       iCHARNEW-value_neutral = CONV #( batch_post-atwrt_ser ) .
1840       " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
1841       iCHARNEW-charact_descr = batch_post-atbez_ser.
1842       APPEND iCHARNEW.
1843
1844       iCHARNEW-charact       = batch_post-atnam_make.
1845       " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1846   *    iCHARNEW-VALUE_NEUTRAL = BATCH_POST-atwrt_make.
1847       iCHARNEW-value_neutral = CONV #( batch_post-atwrt_make ) .
1848       " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
1849       iCHARNEW-charact_descr = batch_post-atbez_make.
1850       APPEND iCHARNEW.
1851
1852       iCHARNEW-charact       = batch_post-atnam_model.
1853       " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1854   *    iCHARNEW-VALUE_NEUTRAL = BATCH_POST-atwrt_model.
1855       iCHARNEW-value_neutral = CONV #( batch_post-atwrt_model ) .
1856       " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
1857       iCHARNEW-charact_descr = batch_post-atbez_model.
1858       APPEND iCHARNEW.
1859
1860       iCHARNEW-charact       = batch_post-atnam_vend.
1861       " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1862   *    iCHARNEW-VALUE_NEUTRAL = BATCH_POST-atwrt_vend.
1863       iCHARNEW-value_neutral = CONV #( batch_post-atwrt_vend ) .
1864       " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
1865       iCHARNEW-charact_descr = batch_post-atbez_vend.
1866       APPEND iCHARNEW.
1867
1868
1869       classnum = 'Z_ONGC_CAPITAL'.
1870       clstype  = '022'.
1871       WAIT UP TO 1 SECONDS.
1872
1873   *************************************************************************
1874   ************    ADDED TO FACILITATE THE INTER PLANT TRANSFER BY SPK/MAJAZ
1875       " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1876       CALL FUNCTION 'BAPI_BATCH_CREATE' "#EC CI_USAGE_OK[2438131]
1877         " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
1878         EXPORTING
1879           " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 14.06.2026  for ATC
1880   *       MATERIAL      = BATCH_POST-MATNR
1881           material_long = batch_post-matnr
1882           " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 14.06.2026 for ATC
1883           batch         = batch_post-charg
1884           plant         = batch_post-werks
1885   *       BATCHATTRIBUTES            =
1886   *       BATCHCONTROLFIELDS         =
1887   *       BATCHSTORAGELOCATION       =
1888   *       INTERNALNUMBERCOM          =
1889   *       EXTENSION1    =
1890   *       MATERIAL_EVG  =
1891   * IMPORTING
1892   *       BATCH         =
1893   *       BATCHATTRIBUTES            =
1894         TABLES
1895           return        = error3.
1896
1897
1898
1899   ************    ADDED TO FACILITATE THE INTER PLANT TRANSFER BY SPK/MAJAZ
1900
1901
1902       " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1903       CALL FUNCTION 'BAPI_OBJCL_CHANGE' "#EC CI_USAGE_OK[2438131]
1904         " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
1905         EXPORTING
1906           objectkey          = iOBJECTKEY_CONC
1907           objecttable        = itab_batch_mcha
1908           classnum           = classnum
1909           classtype          = clstype
1910           status             = '1'
1911   *       STANDARDCLASS      =
1912   *       CHANGENUMBER       =
1913           keydate            = sy-datum
1914           no_default_values  = ' '
1915         IMPORTING
1916           classif_status     = classif_status
1917         TABLES
1918           allocvaluesnumnew  = itab_VALUESNUMNEW
1919           allocvaluescharnew = iCHARNEW
1920           allocvaluescurrnew = itab_CURRNEW
1921           return             = error3.
1922
1923
1924
1925       CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
1926   * EXPORTING
1927   *   WAIT          =
1928   * IMPORTING
1929   *   RETURN        =
1930         .
1931
1932
1933     ENDLOOP.
1934
1935     COMMIT WORK AND WAIT.
1936
1937
1938   ENDFORM.                    " BATCH_UPDATE
*--- End of ZGR_SDR_CAP - 1938 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  <SYSINI>                                  Level 1    Page 2
Object           ZGR_SDR_CAP                               Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:07
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
