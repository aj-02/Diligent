----------------------------------------------------------------------------------------------------
Main program     ZFM_RFFMEP1BX_FOR3YEARS_CALL              Level 0    Page 1
Object           ZFM_RFFMEP1BX_FOR3YEARS_CALL              Lines 2093
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:50
----------------------------------------------------------------------------------------------------
1      ***********************************************************************
2      * Program    : ZFM_RFFMEP1B_FOR3YEARS                                 *
3      *                                                                     *
4      * Title      : Three year Budget Report                               *
5      *                                                                     *
6      *                                                                     *
7      * FS No.     : FS-FI-FM-006                                           *
8      *                                                                     *
9      * Author     : Punit                   Date : 10-Oct-2008             *
10     *                                                                     *
11     * Login Id   : SAB_PUNIT                                              *
12     *                                                                     *
13     * Description: This report gives budget report for 3 yrs - This report*
14     *              is called by ZFM_RFFMEP1B_FOR3YEARS . The report       *
15     *              fetches data and passes to ZFM_RFFMEP1B_FOR3YEARS.     *
16     *              The report is copied from program RFFMEP1BX            *
17     *                                                                     *
18     * Tran. Code : None                                                   *
19     *                                                                     *
20     ***********************************************************************
21
22     REPORT zfm_rffmep1bx_for3years_call.
23
24     TYPE-POOLS: fmfi, slis, sdydo, rsds.
25
26     * "/ Constants for budgeting
27     INCLUDE: lkbppequ.
28
29     * "/ Parameters for schedule manager
30     INCLUDE: rkasmawf.
31
32     TABLES: fkrs, fmaa, fmaarel, fvsn, bpbyx, epby,
33             bpdk, bpdkt, treasonst, fmsg_fmf.
34
35     CONSTANTS: con_repid LIKE sy-cprog VALUE 'RFFMEP1BX'.
36
37     * "/ Zusaetzliche Selektionskriterien
38     *SELECT-OPTIONS: S_GJAHR FOR BPBYX-GJAHR already in LDB
39     *                S_GJ_BUD
40
41     * "/ Summenzeile anzeigen
42     PARAMETERS: p_sum LIKE fmdy-xfeld NO-DISPLAY.
43     * "/ Kontierung nicht in den Zeilen
44     PARAMETERS: p_khead LIKE fmdy-xfeld NO-DISPLAY.
45     * "/ Jahr der Kassenwirksamkeit in Default-Variante
46     PARAMETERS: p_gnjhr LIKE fmdy-xfeld NO-DISPLAY.
47     * SUBMIT aus den Sichten, dann FMAAREL und P_GD aktiv
48     PARAMETERS: p_subrel LIKE fmdy-xfeld NO-DISPLAY.
49
50     TYPES : BEGIN OF ty_g_curr_gjahr,
51               fikrs      LIKE fkrs-fikrs,
52               fincode    LIKE ffnd-fincode,
53               fname      LIKE ffnd-fname,
54               sponsor    LIKE ffnd-sponsor,
55               finuse     LIKE ffnd-finuse,
56               type       LIKE ffnd-type,
57               fund_typet LIKE ffnd-fund_typet,
58               fictr      LIKE fctr-fictr,
59               cname      LIKE fctr-cname,
60               bossid     LIKE fctr-bossid,
61               fipos      LIKE fpos-fipos,
62               pname      LIKE fpos-pname,
63               knzaepo    LIKE fpos-potyp,
64               versn      LIKE fvsn-versn,
65               gjahf      LIKE bpby-gjahr,
66               gjahr      LIKE bpby-gjahr,
67               wrttp      LIKE bpby-wrttp,
68               wtext      LIKE bpby-wtext,
69               vorga      LIKE bpby-vorga,
70               vtext      LIKE bpby-vtext,
71               cf_flag    TYPE fm_cf_flag,
72               fwaer      LIKE bpby-fwaer,
73               belnr      LIKE epby-belnr,
74               buzei      LIKE epby-buzei,
75               wljhr      LIKE epby-wljhr,
76               cpudt      LIKE bpbk-cpudt,
77               usnam      LIKE bpbk-usnam,
78               sgtext     LIKE bpbk-sgtext,
79               sversn     LIKE bpbk-sversn,
80             END OF ty_g_curr_gjahr.
81
82     TYPES : BEGIN OF ty_g_2_gjahr ,
83               fikrs      LIKE fkrs-fikrs,
84               fincode    LIKE ffnd-fincode,
85               fname      LIKE ffnd-fname,
86               sponsor    LIKE ffnd-sponsor,
87               finuse     LIKE ffnd-finuse,
88               type       LIKE ffnd-type,
89               fund_typet LIKE ffnd-fund_typet,
90               fictr      LIKE fctr-fictr,
91               cname      LIKE fctr-cname,
92               bossid     LIKE fctr-bossid,
93               fipos      LIKE fpos-fipos,
94               pname      LIKE fpos-pname,
95               knzaepo    LIKE fpos-potyp,
96               versn      LIKE fvsn-versn,
97               gjahf      LIKE bpby-gjahr,
98               gjahr      LIKE bpby-gjahr,
99               wrttp      LIKE bpby-wrttp,
100              wtext      LIKE bpby-wtext,
101              vorga      LIKE bpby-vorga,
102              vtext      LIKE bpby-vtext,
103              cf_flag    TYPE FM_cf_flag,
104              fwaer      LIKE bpby-fwaer,
105              belnr      LIKE epby-belnr,
106              buzei      LIKE epby-buzei,
107              wljhr      LIKE epby-wljhr,
108              cpudt      LIKE bpbk-cpudt,
109              usnam      LIKE bpbk-usnam,
110              sgtext     LIKE bpbk-sgtext,
111              sversn     LIKE bpbk-sversn,
112            END OF ty_g_2_gjahr.
113
114    TYPES : BEGIN OF ty_g_3_gjahr ,
115              fikrs      LIKE fkrs-fikrs,
116              fincode    LIKE ffnd-fincode,
117              fname      LIKE ffnd-fname,
118              sponsor    LIKE ffnd-sponsor,
119              finuse     LIKE ffnd-finuse,
120              type       LIKE ffnd-type,
121              fund_typet LIKE ffnd-fund_typet,
122              fictr      LIKE fctr-fictr,
123              cname      LIKE fctr-cname,
124              bossid     LIKE fctr-bossid,
125              fipos      LIKE fpos-fipos,
126              pname      LIKE fpos-pname,
127              knzaepo    LIKE fpos-potyp,
128              versn      LIKE fvsn-versn,
129              gjahf      LIKE bpby-gjahr,
130              gjahr      LIKE bpby-gjahr,
131              wrttp      LIKE bpby-wrttp,
132              wtext      LIKE bpby-wtext,
133              vorga      LIKE bpby-vorga,
134              vtext      LIKE bpby-vtext,
135              cf_flag    TYPE fm_cf_flag,
136              fwaer      LIKE bpby-fwaer,
137              belnr      LIKE epby-belnr,
138              buzei      LIKE epby-buzei,
139              wljhr      LIKE epby-wljhr,
140              cpudt      LIKE bpbk-cpudt,
141              usnam      LIKE bpbk-usnam,
142              sgtext     LIKE bpbk-sgtext,
143              sversn     LIKE bpbk-sversn,
144            END OF ty_g_3_gjahr.
145
146    TYPES : BEGIN OF ty_g_curr_gjahr1 ,
147              fictr LIKE fctr-fictr,
148              cname LIKE fctr-cname,
149              fipos LIKE fpos-fipos,
150              pname LIKE fpos-pname,
151              vorga LIKE bpby-vorga,
152              vtext LIKE bpby-vtext,
153              wljhr LIKE epby-wljhr,
154            END OF ty_g_curr_gjahr1.
155
156    TYPES : BEGIN OF ty_g_2_gjahr1 ,
157              fictr LIKE fctr-fictr,
158              cname LIKE fctr-cname,
159              fipos LIKE fpos-fipos,
160              pname LIKE fpos-pname,
161              vorga LIKE bpby-vorga,
162              vtext LIKE bpby-vtext,
163              wljhr LIKE epby-wljhr,
164            END OF ty_g_2_gjahr1.
165
166    TYPES : BEGIN OF ty_g_3_gjahr1 ,
167              fictr LIKE fctr-fictr,
168              cname LIKE fctr-cname,
169              fipos LIKE fpos-fipos,
170              pname LIKE fpos-pname,
171              vorga LIKE bpby-vorga,
172              vtext LIKE bpby-vtext,
173              wljhr LIKE epby-wljhr,
174            END OF ty_g_3_gjahr1.
175
176    TYPES : BEGIN OF ty_g_curr_gjahr2 ,
177              fictr LIKE fctr-fictr,
178              cname LIKE fctr-cname,
179              fipos LIKE fpos-fipos,
180              pname LIKE fpos-pname,
181              wljhr LIKE epby-wljhr,
182            END OF ty_g_curr_gjahr2.
183
184    TYPES : BEGIN OF ty_g_2_gjahr2 ,
185              fictr LIKE fctr-fictr,
186              cname LIKE fctr-cname,
187              fipos LIKE fpos-fipos,
188              pname LIKE fpos-pname,
189              wljhr LIKE epby-wljhr,
190            END OF ty_g_2_gjahr2.
191
192    TYPES : BEGIN OF ty_g_3_gjahr2 ,
193              fictr LIKE fctr-fictr,
194              cname LIKE fctr-cname,
195              fipos LIKE fpos-fipos,
196              pname LIKE fpos-pname,
197              wljhr LIKE epby-wljhr,
198            END OF ty_g_3_gjahr2.
199
200    * - internal table for display
201    TYPES : BEGIN OF ty_tab_disp3,
202              fictr   LIKE fctr-fictr,
203              cname   LIKE fctr-cname,
204              fipos   LIKE fpos-fipos,
205              pname   LIKE fpos-pname,
206              wljhr_1 LIKE epby-wljhr, " Original Budget curr year
207              wljhr_2 LIKE epby-wljhr, " Current Budget curr year
208              wljhr_3 LIKE epby-wljhr, " Original Budget 2 year
209              wljhr_4 LIKE epby-wljhr, " Current Budget 2 year
210              wljhr_5 LIKE epby-wljhr, " Original Budget 3 year
211              wljhr_6 LIKE epby-wljhr, " Current Budget 3 year
212            END OF ty_tab_disp3.
213
214    DATA: g_flg_expsign,                    " Vorzeichen Ausgaben
215          g_flg_revsign,                   " Vorzeichen Einnahmen
216          g_flg_komm.                      " Kommunen Flag
217
218    * "/ Meta-Daten
219    DATA: g_t_fieldcat     TYPE slis_t_fieldcat_alv,
220          g_t_sort         TYPE slis_t_sortinfo_alv,
221          g_f_layout       TYPE slis_layout_alv,
222          g_t_sel_crit     TYPE slis_sel_hide_alv,
223          g_t_events       TYPE slis_t_event,
224          g_title          TYPE lvc_title,
225          g_background_id  TYPE sdydo_key,
226          g_t_object_info  TYPE fm_t_listheader_data,
227          g_t_top_messages TYPE fm_t_top_messages.
228    DATA: g_f_disvariant  TYPE disvariant.
229    DATA: g_flg_farea_active,
230          g_flg_fund_active.
231
232    * "/ Data for schedule manager
233    DATA: g_aplstat        TYPE smmain-aplstat,
234          g_f_schedman_key TYPE schedman_key.
235
236    * "/ Interne Tabelle fuer Einzelposten
237    DATA: BEGIN OF g_t_item OCCURS 100.
238            INCLUDE    STRUCTURE ifmrep1bx.
239    DATA:   bpdk_belnr LIKE  bpbk-bpdk_belnr,
240            bldat      LIKE  bpdk-bldat,
241            bstext     LIKE  fmdy-bstext,
242            rstat_t    LIKE  bpdy-rstat_t,
243            rev_docnr  LIKE  bpdk-rev_docnr,
244            vadat      LIKE  bpdk-vadat,
245            ttext      LIKE  fmdy-ttext,
246            verant     LIKE  bpdk-verant,
247            rtext      LIKE  fmdy-rtext,
248            valkey     LIKE  bpdk-valkey,
249            tech       LIKE  bpin-tech,
250            bstat      LIKE  bpdk-bstat,
251            rstat      LIKE  bpdk-rstat,
252            reason     LIKE  bpdk-reason,
253            namtext    LIKE  bpdkt-namtext,
254            rpublaw    LIKE  bpdk-rpublaw,
255            rlegis     LIKE  bpdk-rlegis,
256            rcohort    LIKE  bpdk-rcohort,
257            budat      LIKE  bpdk-budat,
258            doctype    LIKE  bpdk-doctype,
259            perio      LIKE  bpdk-perio,
260            fcode      LIKE  bpdk-fcode.
261    DATA: END OF g_t_item.
262
263    DATA: g_t_master_data LIKE fmaa OCCURS 300 WITH HEADER LINE.
264
265    *---------------------------------------------------------------------*
266    * Internal Table Declarations                                         *
267    *---------------------------------------------------------------------*
268    DATA: ist_g_t_item  LIKE TABLE OF g_t_item,
269          ist_tab_disp3 TYPE STANDARD TABLE OF ty_tab_disp3.
270    DATA : ist_g_curr_gjahr TYPE STANDARD TABLE OF ty_g_curr_gjahr.
271    DATA : ist_g_2_gjahr TYPE STANDARD TABLE OF ty_g_2_gjahr.
272    DATA : ist_g_3_gjahr TYPE STANDARD TABLE OF ty_g_3_gjahr.
273    DATA : ist_g_curr_gjahr1 TYPE STANDARD TABLE OF ty_g_curr_gjahr1.
274    DATA : ist_g_2_gjahr1 TYPE STANDARD TABLE OF ty_g_2_gjahr1.
275    DATA : ist_g_3_gjahr1 TYPE STANDARD TABLE OF ty_g_3_gjahr1.
276    DATA : ist_g_curr_gjahr2 TYPE STANDARD TABLE OF ty_g_curr_gjahr2.
277    DATA : ist_g_2_gjahr2 TYPE STANDARD TABLE OF ty_g_2_gjahr2.
278    DATA : ist_g_3_gjahr2 TYPE STANDARD TABLE OF ty_g_3_gjahr2.
279
280    *---------------------------------------------------------------------*
281    * Work Area Declarations                                              *
282    *---------------------------------------------------------------------*
283    DATA : wa_tab_disp3 TYPE ty_tab_disp3,
284           wa_g_t_item  LIKE g_t_item.
285    DATA : wa_g_2_gjahr TYPE ty_g_2_gjahr.
286    DATA : wa_g_3_gjahr TYPE ty_g_3_gjahr.
287    DATA : wa_g_curr_gjahr TYPE ty_g_curr_gjahr.
288    DATA : wa_g_curr_gjahr1 TYPE ty_g_curr_gjahr1.
289    DATA : wa_g_2_gjahr1 TYPE ty_g_2_gjahr1.
290    DATA : wa_g_3_gjahr1 TYPE ty_g_3_gjahr1.
291    DATA : wa_g_curr_gjahr2 TYPE ty_g_curr_gjahr2.
292    DATA : wa_g_2_gjahr2 TYPE ty_g_2_gjahr2.
293    DATA : wa_g_3_gjahr2 TYPE ty_g_3_gjahr2.
294
295    * "/ HHM-Kontierung fuer Anzeige als Header
296    DATA: BEGIN OF g_f_hhmkont,
297            fikrs LIKE fkrs-fikrs,
298            fonds LIKE fmaa-fonds,
299            fictr LIKE fmaa-fictr,
300            fipex LIKE fmaa-fipex,
301            farea LIKE fmaa-farea,
302          END OF g_f_hhmkont.
303
304    DATA: BEGIN OF g_t_fkrs OCCURS 10,
305            fikrs LIKE fkrs-fikrs,
306          END OF g_t_fkrs.
307
308    DATA : g_2gjahr LIKE bpby-gjahr.
309    DATA : g_3gjahr LIKE bpby-gjahr.
310    DATA: g_sav_fikrs            LIKE fkrs-fikrs,               "#EC NEEDED
311          g_sav_fcode_periv_actv LIKE fkrs-fcode_periv_actv.    "#EC NEEDED
312
313    * "/ Layout
314    *SELECTION-SCREEN BEGIN OF BLOCK dispvar WITH FRAME TITLE text-001.
315    ** "/ Parameter for display variant
316    *PARAMETERS: p_disvar   LIKE  disvariant-variant.
317    ** "/ Select header entry documents (Kopf des Erfasungsbelegs)
318    SELECTION-SCREEN BEGIN OF LINE.
319      PARAMETERS: p_entry LIKE fmdy-p_entry_header
320                  MEMORY ID hdr.
321      SELECTION-SCREEN COMMENT 3(34) TEXT-401 FOR FIELD p_entry.
322    SELECTION-SCREEN END OF LINE.
323    *SELECTION-SCREEN END   OF BLOCK dispvar.
324    ************************************************************************
325    AT SELECTION-SCREEN OUTPUT.
326
327    START-OF-SELECTION.
328
329    * "/ initialize schedman monitor
330      PERFORM init_schedman.
331
332    * "/ Set flags for LDB and sign
333      PERFORM set_flags.
334
335    * "/ Check assigned cover pool and set Parameter P_ONLY_R
336      IF NOT s_deck IS INITIAL.
337        CLEAR fmsg_fmf-xfmaarel.
338    * note 1014827
339      ELSE.
340        fmsg_fmf-xfmaarel = 'X'.
341    * end of note 1014827
342      ENDIF.
343
344      PERFORM check_p_only_r.
345
346    * "/ Read FM area from FMF
347    GET fkrs FIELDS fikrs.
348      g_t_fkrs-fikrs = fkrs-fikrs.
349      APPEND g_t_fkrs.
350      REFRESH g_t_master_data.
351
352    * "/ Read master data from FMF
353    GET fmaa FIELDS fonds   fname     sponsor finuse fund_type fund_typet
354                    fictr   ctr_objnr cname   bossid
355                    fipex   posit     pname   potyp   efictr
356                    efipex1 efipex2   efipex3 efipex4 efipex5
357                    farea ftext
358    *                 "/ Substrings
359                    fdstr_id   fdsub1     fdsub2
360                    fdsub1t_sh fdsub1t_lo fdsub2t_sh fdsub2t_lo
361                    fcstr_id   fcsub1     fcsub2     fcsub3
362                    fcsub1t_sh fcsub1t_lo fcsub2t_sh fcsub2t_lo
363                    fcsub3t_sh fcsub3t_lo
364                    cistr_id   cisub1     cisub2     cisub3 cisub4 cisub5
365                    cisub1t_sh cisub1t_lo cisub2t_sh
366                    cisub2t_lo cisub3t_sh cisub3t_lo cisub4t_sh
367                    cisub4t_lo cisub5t_sh cisub5t_lo
368                    fnstr_id   fnsub1
369                    fnsub2     fnsub3     fnsub1t_sh fnsub1t_lo fnsub2t_sh
370                    fnsub2t_lo fnsub3t_sh fnsub3t_lo.
371
372      MOVE-CORRESPONDING fmaa TO g_t_master_data.
373      COLLECT g_t_master_data.
374
375    * "/ Read master data from FMF
376    GET epby.
377      CLEAR g_t_item.
378      READ TABLE g_t_master_data WITH KEY fonds     = bpbyx-fonds
379                                          fictr     = bpbyx-fictr
380                                          fipex     = bpbyx-fipex
381                                          farea     = bpbyx-farea
382                                 BINARY SEARCH.
383      IF sy-subrc = 0.
384    *     "/ Move FM area
385        MOVE fkrs-fikrs          TO g_t_item-fikrs.
386    *     "/ Move Budget version
387        MOVE fvsn-versn          TO g_t_item-versn.
388    *     "/ Move master data
389        MOVE-CORRESPONDING g_t_master_data TO g_t_item.
390    *     "/ Move default text for Fund SPACE
391        IF g_t_master_data-fonds   IS INITIAL.
392          g_t_item-fname = TEXT-200.
393        ENDIF.
394    *     "/ Move transaction data
395        MOVE-CORRESPONDING bpbyx TO g_t_item.
396        MOVE-CORRESPONDING epby  TO g_t_item.
397    *     "/ Change sign of budget data
398        PERFORM set_sign_budget USING    g_t_master_data-potyp
399                                CHANGING g_t_item-wljhr.
400        PERFORM set_sign_budget USING    g_t_master_data-potyp
401                                CHANGING g_t_item-wljhv.
402        APPEND g_t_item.
403
404      ENDIF.
405
406    *  "/ Sort table for master data for binary search
407    GET fmaa LATE.
408      SORT g_t_master_data BY fonds fictr fipex farea.
409
410    *  "/ Sort table for master data for binary search
411    END-OF-SELECTION.
412
413      IF g_t_item[] IS INITIAL.
414    *  "/ Keine Saetze gefunden
415        MESSAGE s850(kw).
416    *   "/ Flag for schedman
417        g_aplstat = '2'.    "warning
418    *   "/ send info to schedman monitor
419        PERFORM close_schedman.
420        LEAVE PROGRAM.
421      ENDIF.
422
423      ist_g_t_item[] = g_t_item[].
424    * "/ Select header entry documents (Erfasungsbelege)
425      IF NOT p_entry IS INITIAL.
426        PERFORM read_header_entries TABLES g_t_item.
427      ENDIF.
428
429    * - seperate records into three years
430      PERFORM seperate_records.
431
432    * - sum at transaction level to keep sub totals
433      PERFORM sum_item_level.
434
435    * - Sum up the items at funds center / commitment item level.
436      PERFORM sum_gross_level.
437
438    * - build_disp_table.
439      PERFORM build_disp_table.
440
441      EXPORT ist_tab_disp3 TO MEMORY ID 'A1'.
442
443    *  "/ send info to schedman monitor
444      PERFORM close_schedman.
445
446    * "/ Form-Routinen die vom Tool aufgerufen werden
447
448    *&---------------------------------------------------------------------*
449    *&      Form  TOP_OF_PAGE
450    *&---------------------------------------------------------------------*
451    FORM top_of_page.                                           "#EC CALLED
452
453      TYPE-POOLS sdydo.
454
455      DATA  l_t_list_top_of_page TYPE slis_t_listheader.
456
457      DATA: ls_line TYPE slis_listheader.
458
459      DATA: l_date(20) TYPE c,
460            l_time(20) TYPE c,
461            l_key(20)  TYPE c.
462
463      DATA: l_t_sel_tab LIKE fmkbo_seltab OCCURS 0
464                    WITH HEADER LINE.
465
466      DATA : l_logo  TYPE sdydo_key.
467      DATA : l_t_header_data TYPE fm_t_listheader_data,
468             l_f_header_data TYPE ifm_listheader_data.
469
470      DATA: l_t_sel_field LIKE  fmkbo_selfield OCCURS 0
471                      WITH HEADER LINE.
472
473      CONSTANTS: con_logo     TYPE sdydo_key VALUE 'ENJOYSAP_LOGO',
474                 con_exitname TYPE exit_def VALUE 'FM_LIST_HEADER_ADDIN'.
475
476      STATICS:
477        st_ref_header_exit TYPE REF TO if_ex_fm_list_header_addin.
478
479    *----- instanciate/initiate user exit for wallpaper
480      IF st_ref_header_exit IS INITIAL.
481        CALL METHOD cl_exithandler=>get_instance
482          EXPORTING
483            exit_name              = con_exitname
484            null_instance_accepted = 'X'
485          CHANGING
486            instance               = st_ref_header_exit.
487      ENDIF.
488
489
490    * "/ Titel setzen
491      CLEAR ls_line.
492      ls_line-typ  = 'H'.
493      ls_line-info = g_title.
494      APPEND ls_line TO l_t_list_top_of_page.
495
496
497    * "/ Aufbau der Steuertabelle zur Aufbereitung
498    * "/ der Selektionszeilen
499      CLEAR l_t_sel_field.
500      l_t_sel_field-selname = 'S_FIKRS'.
501      APPEND l_t_sel_field.
502
503      CLEAR l_t_sel_field.
504      l_t_sel_field-selname = 'S_GJ_BUD'.
505      APPEND l_t_sel_field.
506
507      CLEAR l_t_sel_field.
508      l_t_sel_field-selname = 'S_FIPEX'.
509      APPEND l_t_sel_field.
510
511      CLEAR l_t_sel_field.
512      l_t_sel_field-selname = 'S_FICTR'.
513      APPEND l_t_sel_field.
514
515      CLEAR l_t_sel_field.
516      l_t_sel_field-selname = 'S_FONDS'.
517      APPEND l_t_sel_field.
518
519
520    * "/ Ermitteln der Selektionsinfos für Zeilenausgabe
521      CALL FUNCTION 'FMRP_UT_GET_SELLINE'
522        EXPORTING
523          i_report_name  = con_repid
524        TABLES
525          sel_field      = l_t_sel_field
526          e_t_listheader = l_t_list_top_of_page.
527
528    * "/ Leerzeile
529      CLEAR ls_line.
530      ls_line-typ  = 'S'.
531      ls_line-key  = ' '.
532      ls_line-info = ' '.
533      APPEND ls_line TO l_t_list_top_of_page.
534
535
536    * "/ Benutzer
537      CLEAR ls_line.
538      ls_line-typ  = 'S'.
539      MESSAGE i210(fmrp) INTO ls_line-key.
540      ls_line-info = sy-uname.
541      APPEND ls_line TO l_t_list_top_of_page.
542
543    * "/ Datum/Zeit
544      CLEAR ls_line.
545      ls_line-typ  = 'S'.
546      MESSAGE i211(fmrp) INTO ls_line-key.
547      WRITE sy-datlo TO l_date.
548      WRITE sy-uzeit TO l_time.
549      CONCATENATE l_date l_time
550        INTO ls_line-info
551        SEPARATED BY '   '.
552      APPEND ls_line TO l_t_list_top_of_page.
553
554
555    **----- get wallpaper according to user requirements and implementation
556      IF NOT st_ref_header_exit IS INITIAL.
557        CALL METHOD st_ref_header_exit->add_text_and_picture
558          IMPORTING
559    *       e_t_header_data     = l_t_header_data                   "#EC ENHOK
560            e_logo              = l_logo
561          CHANGING
562            c_t_list_commentary = l_t_list_top_of_page.
563      ENDIF.
564
565
566    ** "/ Logo aus BADI uebernehmen oder Defaulticon anzeigen.
567    *  IF l_logo IS INITIAL.
568    *    l_logo = con_logo.
569    *  ENDIF.
570
571      CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
572        EXPORTING
573          i_logo             = l_logo
574          it_list_commentary = l_t_list_top_of_page.
575
576      CALL METHOD cl_fm_listheader_create=>top_of_page
577        EXPORTING   " i_title = g_title
578          " i_t_object_info = g_t_object_info "Object information
579          i_t_top_messages = g_t_top_messages. "Message
580
581
582    ENDFORM.                    "top_of_page
583
584    *&---------------------------------------------------------------------*
585    *&      Form  HTML_TOP_OF_PAGE
586    *&---------------------------------------------------------------------*
587    FORM html_top_of_page USING r_top TYPE REF TO cl_dd_document. "#EC CALLED
588
589      CALL METHOD cl_fm_listheader_create=>html_top_of_page
590        EXPORTING
591          i_ref_top       = r_top             "Reference to header area
592          i_title         = g_title           "Title
593          i_t_object_info = g_t_object_info.  "Object information
594
595    ENDFORM.                    "html_top_of_page
596
597    *&---------------------------------------------------------------------*
598    *&      Form  PF_STATUS_SET
599    *&---------------------------------------------------------------------*
600    FORM pf_status_set USING extab TYPE slis_t_extab.           "#EC CALLED
601      DATA: l_f_extab    LIKE rsmpe-func,
602            l_flg_active.
603
604    *  "/ suppress icon for budgetary ledger if not active
605      LOOP AT g_t_fkrs.
606        CALL FUNCTION 'FM_LEDGER_CHECK_ACTIVE'
607          EXPORTING
608            i_fm_area    = g_t_fkrs-fikrs
609          IMPORTING
610            e_flg_active = l_flg_active.
611        IF NOT l_flg_active IS INITIAL.
612          EXIT.
613        ENDIF.
614      ENDLOOP.
615      IF l_flg_active IS INITIAL.
616        l_f_extab = 'FMBL'.
617        APPEND l_f_extab TO extab.
618      ENDIF.
619
620      SET PF-STATUS 'FULLSCREEN' EXCLUDING extab.
621    ENDFORM.                    "pf_status_set
622
623    **&---------------------------------------------------------------------*
624    **&      Form  FILL_SEL_CRIT
625    **&---------------------------------------------------------------------*
626    *FORM fill_sel_crit CHANGING c_t_sel_crit TYPE slis_sel_hide_alv.
627    *
628    **  "/ Workarea
629    *  DATA: l_f_entries LIKE LINE OF c_t_sel_crit-t_entries.
630    *
631    **  "/ 'C' = Aendern der Selektionskriterien
632    *  c_t_sel_crit-mode = 'C'.
633    *
634    **  "/ Loeschen der folgenden Felder aus der Anzeige
635    *  l_f_entries-mode = 'D'.
636    *  l_f_entries-selname = 'P_STAMM'.
637    *  APPEND l_f_entries TO c_t_sel_crit-t_entries.
638    *  l_f_entries-selname = 'P_SUM'.
639    *  APPEND l_f_entries TO c_t_sel_crit-t_entries.
640    *  l_f_entries-selname = 'P_KHEAD'.
641    *  APPEND l_f_entries TO c_t_sel_crit-t_entries.
642    *  l_f_entries-selname = 'P_FMBUD'.
643    *  APPEND l_f_entries TO c_t_sel_crit-t_entries.
644    *  l_f_entries-selname = 'P_BUDFM'.
645    *  APPEND l_f_entries TO c_t_sel_crit-t_entries.
646    *
647    *  IF NOT s_fipex IS INITIAL.
648    *    l_f_entries-selname = 'S_FIPOS'.
649    *    APPEND l_f_entries TO c_t_sel_crit-t_entries.
650    *  ENDIF.
651    *
652    *ENDFORM.                               " FILL_SEL_CRIT
653
654    *&---------------------------------------------------------------------*
655    *&      Form  USER_COMMAND
656    *&---------------------------------------------------------------------*
657    FORM user_command USING u_ucomm  LIKE sy-ucomm
658                            selfield TYPE slis_selfield.        "#EC CALLED
659
660      DATA: l_sav_awref LIKE fmfi-awref.
661      DATA: l_para LIKE tpara-paramid.
662      READ TABLE g_t_item INDEX selfield-tabindex.
663      CHECK sy-subrc = 0.
664
665      CASE u_ucomm.
666        WHEN 'PIC1'.
667    *     "/ Authority check
668          PERFORM authorisation_check_tcode USING 'FM2F'.
669    *     "/ Beleg anzeigen
670          SET PARAMETER ID 'BPB' FIELD g_t_item-belnr.
671          SET PARAMETER ID 'BPD' FIELD l_para.            "note 994406
672          CALL TRANSACTION 'FM2F' AND SKIP FIRST SCREEN.     "#EC CI_CALLTA
673
674        WHEN 'FMBL'.
675    *        "/ Beleg des Budgetary Ledger anzeigen
676          l_sav_awref = g_t_item-belnr.
677          CALL FUNCTION 'FM_DOCUMENT_DISPLAY_BL'
678            EXPORTING
679              i_fikrs = g_t_item-fikrs
680              i_awtyp = 'FMBHI'
681              i_awref = l_sav_awref.
682        WHEN 'ISEL'.
683    *       "/ Display of select-options
684          CALL FUNCTION 'FMRP_UT_GET_SELECTIONS'
685            EXPORTING
686              i_report_name = con_repid
687              i_dialog      = 'X'
688            EXCEPTIONS
689              no_entries    = 1.
690      ENDCASE.
691    ENDFORM.                    "user_command
692
693    *&---------------------------------------------------------------------*
694    *&      Form  AUTHORISATION_CHECK_TCODE
695    *&---------------------------------------------------------------------*
696    FORM authorisation_check_tcode USING u_tcode LIKE sy-tcode.
697
698      CALL FUNCTION 'AUTHORITY_CHECK_TCODE'
699        EXPORTING
700          tcode  = u_tcode
701        EXCEPTIONS
702          ok     = 0
703          not_ok = 2
704          OTHERS = 3.
705      IF sy-subrc <> 0.
706        MESSAGE e172(00) WITH u_tcode.
707      ENDIF.
708    ENDFORM.                                     " authorisation_check_tcode
709
710    **&---------------------------------------------------------------------*
711    **&      Form  FILL_FIELDCAT
712    **&---------------------------------------------------------------------*
713    *FORM fill_fieldcat
714    *          CHANGING c_t_fieldcat TYPE slis_t_fieldcat_alv.
715    *
716    *  DATA: l_f_fieldcat LIKE LINE OF c_t_fieldcat,
717    *        l_t_nametab  LIKE x031l OCCURS 50 WITH HEADER LINE,
718    *        l_cnt_colpos LIKE sy-index.
719    *
720    ** "/ Ermitteln der Felder der Struktur IFMREP1BX
721    *  CALL FUNCTION 'DDIF_NAMETAB_GET'
722    *    EXPORTING
723    *      tabname   = 'IFMREP1BX'
724    *    TABLES
725    *      x031l_tab = l_t_nametab
726    *    EXCEPTIONS
727    *      not_found = 1
728    *      OTHERS    = 2.
729    *
730    ** "/ Structure does not exists
731    *  IF NOT sy-subrc = 0.
732    *    MESSAGE e012(e2) WITH 'IFMREP1BX'.
733    *    LEAVE PROGRAM.
734    *  ENDIF.
735    *
736    ** "/ Uebernahme der Felder in den Feldkatalog
737    *  l_cnt_colpos = 300.
738    *  LOOP AT l_t_nametab.
739    *    l_cnt_colpos = l_cnt_colpos + 10.
740    *    CLEAR l_f_fieldcat.
741    *    l_f_fieldcat-fieldname   = l_t_nametab-fieldname.
742    *    l_f_fieldcat-ref_tabname = l_t_nametab-tabname.
743    *    l_f_fieldcat-col_pos     = l_cnt_colpos.
744    *    l_f_fieldcat-no_out      = 'X'.
745    *
746    *    CASE l_f_fieldcat-fieldname.
747    **       "/ Belegnummer
748    *      WHEN 'BELNR'.
749    *        l_f_fieldcat-col_pos     = 10.
750    *        l_f_fieldcat-key         = 'X'.
751    *        l_f_fieldcat-no_out      = ' '.
752    *        l_f_fieldcat-no_sum      = 'X'.
753    **       "/ Belegzeile
754    *      WHEN 'BUZEI'.
755    *        l_f_fieldcat-col_pos     = 20.
756    *        l_f_fieldcat-key         = 'X'.
757    *        l_f_fieldcat-no_out      = ' '.
758    *        l_f_fieldcat-no_sum      = 'X'.
759    **       "/ Geschaeftsjahr
760    *      WHEN 'GJAHR'.
761    *        l_f_fieldcat-col_pos     = 30.
762    *        l_f_fieldcat-no_out      = ' '.
763    *        l_f_fieldcat-no_sum      = 'X'.
764    **       "/ Jahr der Kassenwirksamkeit
765    *      WHEN 'GNJHR'.
766    *        l_f_fieldcat-col_pos     = 40.
767    *        l_f_fieldcat-no_out      = ' '.
768    *        IF p_gnjhr IS INITIAL.
769    *          l_f_fieldcat-no_out   = 'X'.
770    *        ELSE.
771    *          l_f_fieldcat-no_out   = space.
772    *        ENDIF.
773    **       "/ Werttyp-Text
774    *      WHEN 'WTEXT'.
775    *        l_f_fieldcat-col_pos     = 50.
776    *        l_f_fieldcat-no_out      = ' '.
777    **       "/ Vorgang-Text
778    *      WHEN 'VTEXT'.
779    *        l_f_fieldcat-col_pos     = 60.
780    *        l_f_fieldcat-no_out      = ' '.
781    **       "/ Budgetunterarten-Text
782    *      WHEN 'UTEXT'.
783    *        l_f_fieldcat-col_pos     = 70.
784    *        l_f_fieldcat-no_out      = ' '.
785    **       "/ Finanzkreiswaehrung
786    *      WHEN 'FWAER'.
787    *        l_f_fieldcat-col_pos     = 80.
788    *        l_f_fieldcat-no_out      = ' '.
789    **       "/ Betrag in Finanzkreiswaehrung
790    *      WHEN 'WLJHR'.
791    *        l_f_fieldcat-col_pos     = 90.
792    *        l_f_fieldcat-no_out      = ' '.
793    *        l_f_fieldcat-cfieldname  = 'FWAER'.
794    *        l_f_fieldcat-no_zero     = 'X'.
795    *        l_f_fieldcat-do_sum      = 'X'.
796    **       "/ Betrag (Verteilt) in Finanzkreiswaehrung
797    *      WHEN 'WLJHV'.
798    *        l_f_fieldcat-col_pos     = 100.
799    *        l_f_fieldcat-no_out      = 'X'.
800    *        l_f_fieldcat-cfieldname  = 'FWAER'.
801    *        l_f_fieldcat-no_zero     = 'X'.
802    *        l_f_fieldcat-do_sum      = 'X'.
803    **       "/ Finanzkreis
804    *      WHEN 'FIKRS'.
805    *        l_f_fieldcat-col_pos     = 110.
806    *        IF NOT p_khead IS INITIAL.
807    *          l_f_fieldcat-no_out   = 'X'.
808    *        ELSE.
809    *          l_f_fieldcat-no_out   = ' '.
810    *        ENDIF.
811    **       "/ Fonds
812    *      WHEN 'FONDS'.
813    *        IF NOT g_flg_fund_active IS INITIAL.
814    *          l_f_fieldcat-col_pos     = 120.
815    *          IF NOT p_khead IS INITIAL.
816    *            l_f_fieldcat-no_out   = 'X'.
817    *          ELSE.
818    *            l_f_fieldcat-no_out   = ' '.
819    *          ENDIF.
820    *        ELSE.
821    *          CONTINUE.
822    *        ENDIF.
823    **       "/ Finanzstelle
824    *      WHEN 'FICTR'.
825    *        l_f_fieldcat-col_pos     = 130.
826    *        IF NOT p_khead IS INITIAL.
827    *          l_f_fieldcat-no_out   = 'X'.
828    *        ELSE.
829    *          l_f_fieldcat-no_out   = ' '.
830    *        ENDIF.
831    **       "/ Finanzposition
832    *      WHEN 'FIPEX'.
833    *        l_f_fieldcat-col_pos     = 140.
834    *        IF NOT p_khead IS INITIAL.
835    *          l_f_fieldcat-no_out   = 'X'.
836    *        ELSE.
837    *          l_f_fieldcat-no_out   = ' '.
838    *        ENDIF.
839    **       "/ Belastungstyp
840    *      WHEN 'POTYP'.
841    *        l_f_fieldcat-col_pos     = l_cnt_colpos.
842    *        l_f_fieldcat-outputlen   = 1.
843    *        l_f_fieldcat-no_sum      = 'X'.
844    *        l_f_fieldcat-no_out      = 'X'.
845    **       "/ Erfassungsdatum
846    *      WHEN 'CPUDT'.
847    *        l_f_fieldcat-ref_tabname = 'BPBK'.
848    *        l_f_fieldcat-col_pos     = 150.
849    *        IF p_khead IS INITIAL.
850    *          l_f_fieldcat-no_out   = 'X'.
851    *        ELSE.
852    *          l_f_fieldcat-no_out   = ' '.
853    *        ENDIF.
854    **       "/ Username
855    *      WHEN 'USNAM'.
856    *        l_f_fieldcat-ref_tabname = 'BPBK'.
857    *        l_f_fieldcat-col_pos     = 160.
858    *        IF p_khead IS INITIAL.
859    *          l_f_fieldcat-no_out   = 'X'.
860    *        ELSE.
861    *          l_f_fieldcat-no_out   = ' '.
862    *        ENDIF.
863    **       "/ Belegtext
864    *      WHEN 'SGTEXT'.
865    *        l_f_fieldcat-ref_tabname = 'BPBK'.
866    *        l_f_fieldcat-col_pos     = 160.
867    *        IF p_khead IS INITIAL.
868    *          l_f_fieldcat-no_out   = 'X'.
869    *        ELSE.
870    *          l_f_fieldcat-no_out   = ' '.
871    *        ENDIF.
872    **       "/ Quellversion
873    *      WHEN 'SVERSN'.
874    *        l_f_fieldcat-ref_tabname = 'BPBK'.
875    *        l_f_fieldcat-col_pos     = 160.
876    *        IF p_khead IS INITIAL.
877    *          l_f_fieldcat-no_out   = 'X'.
878    *        ELSE.
879    *          l_f_fieldcat-no_out   = ' '.
880    *        ENDIF.
881    **       "/ Kommunenfelder
882    *      WHEN 'EFICTR'
883    *        OR 'EFIPEX1'
884    *        OR 'EFIPEX2'
885    *        OR 'EFIPEX3'
886    *        OR 'EFIPEX4'
887    *        OR 'EFIPEX5'.
888    *        IF NOT g_flg_komm IS INITIAL.
889    *          l_f_fieldcat-col_pos     = l_cnt_colpos.
890    *          l_f_fieldcat-no_out      = 'X'.
891    *        ELSE.
892    *          CONTINUE.
893    *        ENDIF.
894    **       "/ Remove all 'Fund releated' fields
895    *      WHEN 'FNAME' OR 'FUND_TYPE' OR 'FUND_TYPET' OR 'SPONSOR' OR
896    *           'FINUSE'.
897    *        IF g_flg_fund_active IS INITIAL.
898    *          CONTINUE.
899    *        ENDIF.
900    **       "/ Remove all 'Function releated' fields
901    *      WHEN 'FAREA' OR 'FTEXT'.
902    *        IF g_flg_farea_active IS INITIAL.
903    *          CONTINUE.
904    *        ENDIF.
905    *    ENDCASE.
906    *
907    *    APPEND l_f_fieldcat TO c_t_fieldcat.
908    *
909    *  ENDLOOP.
910    *
911    ** "/ Select header entry documents (Erfasungsbelege)
912    *  CHECK NOT p_entry IS INITIAL.
913    *  PERFORM fill_fieldcat_bpdk CHANGING l_cnt_colpos
914    *                                      c_t_fieldcat.
915    *
916    *ENDFORM.                               " FILL_FIELDCAT
917
918    **&---------------------------------------------------------------------*
919    **&      Form  FILL_LAYOUT
920    **&---------------------------------------------------------------------*
921    *FORM fill_layout
922    *          CHANGING c_f_layout TYPE slis_layout_alv.
923    *
924    *  CALL FUNCTION 'FM_ALV_LAYOUT'
925    *    CHANGING
926    *      c_f_layout = c_f_layout.
927    *
928    *  IF p_sum IS INITIAL.
929    *    c_f_layout-no_totalline      = 'X'.
930    *  ELSE.
931    *    c_f_layout-no_totalline      = ' '.
932    *  ENDIF.
933    *
934    *ENDFORM.                               " FILL_LAYOUT
935
936    **&---------------------------------------------------------------------*
937    **&      Form  FILL_SORT
938    **&---------------------------------------------------------------------*
939    *FORM fill_sort
940    *          CHANGING c_t_sort TYPE slis_t_sortinfo_alv.
941    *
942    **  "/ Workarea
943    *  DATA: l_f_sort LIKE LINE OF c_t_sort.
944    *
945    *  CLEAR l_f_sort.
946    *  l_f_sort-spos = 1.
947    *  l_f_sort-fieldname = 'GJAHR'.
948    *  l_f_sort-up = 'X'.
949    *  APPEND l_f_sort TO c_t_sort.
950    *
951    *  CLEAR l_f_sort.
952    *  l_f_sort-spos = 2.
953    *  l_f_sort-fieldname = 'WTEXT'.
954    *  l_f_sort-up = 'X'.
955    *  APPEND l_f_sort TO c_t_sort.
956    *
957    *  CLEAR l_f_sort.
958    *  l_f_sort-spos = 3.
959    *  l_f_sort-fieldname = 'BELNR'.
960    *  l_f_sort-up = 'X'.
961    *  APPEND l_f_sort TO c_t_sort.
962    *
963    *  CLEAR l_f_sort.
964    *  l_f_sort-spos = 4.
965    *  l_f_sort-fieldname = 'BUZEI'.
966    *  l_f_sort-up = 'X'.
967    *  APPEND l_f_sort TO c_t_sort.
968    *
969    *ENDFORM.                               " FILL_SORT
970    *
971    **&---------------------------------------------------------------------*
972    **&      Form  FILL_EVENTS
973    **&---------------------------------------------------------------------*
974    *FORM fill_events CHANGING c_t_events TYPE slis_t_event.
975    *
976    *  DATA: l_f_events LIKE LINE OF c_t_events.
977    *
978    *  l_f_events-name = 'TOP_OF_PAGE'.
979    *  l_f_events-form = 'TOP_OF_PAGE'.
980    *  APPEND l_f_events TO c_t_events.
981    *  l_f_events-name = 'HTML_TOP_OF_PAGE'.
982    *  l_f_events-form = 'HTML_TOP_OF_PAGE'.
983    *  APPEND l_f_events TO c_t_events.
984    *
985    *ENDFORM.                    " FILL_EVENTS
986
987
988    *&---------------------------------------------------------------------*
989    *&      Form  SET_FLAGS
990    *&---------------------------------------------------------------------*
991    FORM set_flags.
992
993    * "/ Ermittelt, ob Ausgaben positiv oder negativ im Reporting angezeigt
994    * "/ werden
995      CALL FUNCTION 'FM_SIGN_GET_FOR_EXPENDITURE'
996        IMPORTING
997          e_sign          = g_flg_expsign
998          e_sign_revenues = g_flg_revsign.
999
1000   * "/ Kommunenflag ermitteln
1001     CALL FUNCTION 'FM_GET_ACTIVE_DIMENSIONS'
1002       IMPORTING
1003         e_function_active = g_flg_farea_active
1004         e_fund_active     = g_flg_fund_active
1005         e_kom_active      = g_flg_komm.
1006
1007   * "/ Deactivate measure and grant
1008     fmsg_fmf-xfmas = 'X'.
1009     fmsg_fmf-xfgmg = 'X'.
1010
1011   ENDFORM.                  "SET_FLAGS
1012
1013   *&---------------------------------------------------------------------*
1014   *&      Form  SET_SIGN_BUDGET
1015   *&---------------------------------------------------------------------*
1016   FORM set_sign_budget USING    u_f_potyp LIKE fmaa-potyp
1017                        CHANGING p_value.
1018
1019
1020   *  "/ Pruefen, ob Originalvorzeichen in Kommunen-Reports
1021     IF NOT g_flg_komm IS INITIAL.
1022       CHECK p_sign_k IS INITIAL.
1023     ENDIF.
1024
1025     IF u_f_potyp = '3'.
1026       IF g_flg_expsign = '-'.
1027   *        "/ Ausgabenbudget negativ anzeigen
1028         p_value = p_value * -1.
1029       ENDIF.
1030     ENDIF.
1031     IF u_f_potyp = '2'.
1032       IF g_flg_revsign = '-'.
1033   *        "/ Einnahmenbudget negativ anzeigen
1034         p_value = p_value * -1.
1035       ENDIF.
1036     ENDIF.
1037   ENDFORM.                    " SET_SIGN_BUDGET
1038
1039   *&---------------------------------------------------------------------*
1040   *&      Form  READ_HEADER_ENTRIES
1041   *&---------------------------------------------------------------------*
1042   *       Select headers of entry documents
1043   *       Database tables BPBK and BPDK
1044   *----------------------------------------------------------------------*
1045   *  <-->  p1       U_T_ITEM
1046   *----------------------------------------------------------------------*
1047   FORM read_header_entries TABLES u_t_item STRUCTURE g_t_item.
1048
1049     FIELD-SYMBOLS: <u_f_item> LIKE g_t_item.
1050
1051     DATA: l_flg_subrc LIKE sy-subrc.
1052
1053   * "/ Internal table of header entry documents
1054     DATA: BEGIN OF l_t_bpdk OCCURS 10,
1055             belnr      LIKE  bpbk-belnr,
1056             bpdk_belnr LIKE  bpbk-bpdk_belnr,
1057             bldat      LIKE  bpdk-bldat,
1058             bstext     LIKE  fmdy-bstext,
1059             rstat_t    LIKE  bpdy-rstat_t,
1060             rev_docnr  LIKE  bpdk-rev_docnr,
1061             usnam      LIKE  bpdk-usnam,
1062             cpudt      LIKE  bpdk-cpudt,
1063             vadat      LIKE  bpdk-vadat,
1064             ttext      LIKE  fmdy-ttext,
1065             verant     LIKE  bpdk-verant,
1066             rtext      LIKE  fmdy-rtext,
1067             valkey     LIKE  bpdk-valkey,
1068             tech       LIKE  bpin-tech,
1069             bstat      LIKE  bpdk-bstat,
1070             rstat      LIKE  bpdk-rstat,
1071             reason     LIKE  bpdk-reason,
1072             sgtext     LIKE  bpdkt-sgtext,
1073             namtext    LIKE  bpdkt-namtext,
1074             rpublaw    LIKE  bpdk-rpublaw,
1075             rlegis     LIKE  bpdk-rlegis,
1076             rcohort    LIKE  bpdk-rcohort,
1077             budat      LIKE  bpdk-budat,
1078             doctype    LIKE  bpdk-doctype,
1079             perio      LIKE  bpdk-perio,
1080             fcode      LIKE  bpdk-fcode,
1081           END OF l_t_bpdk.
1082
1083   * "/ Select of heades of entries documents
1084   * "/ for all entries in U_T_ITEM
1085     " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 14.06.2026  for ATC
1086   *  SELECT a~belnr
1087     SELECT a~belnr
1088   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 14.06.2026 for ATC
1089            a~bpdk_belnr          " Erfasungsbeleg
1090            b~cpudt               " Erfassungsdatum des Beleges
1091            b~budat               " Buchungsdatum
1092            b~perio
1093            b~bldat               " Belegdatum
1094            b~vadat
1095            b~verant
1096            b~usnam
1097            b~valkey
1098            b~bstat
1099            b~fcode
1100            b~reason              " Entscheidungsgrund
1101            b~rstat               " Belegstatus
1102            b~rev_docnr           " Originalbeleg
1103            b~rpublaw             " Gesetzliche Grundlage
1104            b~rlegis              " Art der Gesetzgebung
1105            b~rcohort             " Meldejahr für Cohort
1106            b~doctype             " Art des Budgeterfassungsbelegs
1107            INTO CORRESPONDING FIELDS OF TABLE l_t_bpdk
1108            FROM
1109               bpbk AS a JOIN bpdk AS b
1110               ON a~bpdk_belnr = b~belnr
1111               FOR ALL ENTRIES IN u_t_item
1112               WHERE a~belnr   = u_t_item-belnr.  "#EC CI_DB_OPERATION_OK
1113
1114   *  "/ Sort by BELNR
1115     SORT u_t_item BY belnr.
1116
1117   *  "/ Move entries of BPDK into U_T_ITEM
1118     LOOP AT u_t_item ASSIGNING <u_f_item>.
1119       AT NEW belnr.
1120         READ TABLE l_t_bpdk WITH KEY belnr = <u_f_item>-belnr.
1121         l_flg_subrc = sy-subrc.
1122         CHECK l_flg_subrc = 0.
1123   *      "/ Read texts
1124         PERFORM get_tech USING l_t_bpdk-rev_docnr
1125                       CHANGING l_t_bpdk-fcode
1126                                l_t_bpdk-tech.
1127         CHECK NOT l_t_bpdk-fcode IS INITIAL.
1128         PERFORM get_tech_text USING l_t_bpdk-tech
1129                            CHANGING l_t_bpdk-ttext.
1130         PERFORM get_bstext USING l_t_bpdk-bstat
1131                         CHANGING l_t_bpdk-bstext.
1132         PERFORM get_rstat_t USING l_t_bpdk-rstat
1133                          CHANGING l_t_bpdk-rstat_t.
1134         PERFORM get_reason_text USING l_t_bpdk-reason
1135                              CHANGING l_t_bpdk-rtext.
1136         PERFORM get_sgtext USING l_t_bpdk-bpdk_belnr
1137                         CHANGING l_t_bpdk-sgtext
1138                                  l_t_bpdk-namtext.
1139       ENDAT.
1140       CHECK l_flg_subrc = 0.
1141       MOVE-CORRESPONDING l_t_bpdk TO <u_f_item>.
1142     ENDLOOP.
1143
1144   ENDFORM.                    " READ_HEADER_ENTRIES
1145
1146   *&---------------------------------------------------------------------*
1147   *&      Form  GET_TECH
1148   *&---------------------------------------------------------------------*
1149   FORM get_tech USING u_rev_docnr LIKE bpdk-rev_docnr
1150              CHANGING c_fcode     LIKE bpdk-fcode
1151                       c_tech      LIKE bpin-tech.
1152
1153     DATA: l_f_bpin     LIKE bpin,
1154           l_f_bpdk_new LIKE bpdk.
1155
1156   *  "/ If reversal document
1157   *  "/ Contstants from LKBPPEQU
1158     IF c_fcode = f_fuebebs OR c_fcode = f_fuebpbs.
1159   *    "/ Read FCODE of original document
1160       " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 14.06.2026  for ATC
1161   *    SELECT SINGLE * FROM bpdk INTO l_f_bpdk_new
1162       SELECT SINGLE * FROM bpdk INTO l_f_bpdk_new
1163   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 14.06.2026 for ATC
1164              WHERE belnr = bpdk-rev_docnr.  "#EC CI_DB_OPERATION_OK
1165       IF sy-subrc = 0.
1166         l_f_bpin-fcode = l_f_bpdk_new-fcode.
1167       ELSE.
1168         CLEAR l_f_bpin-fcode.
1169       ENDIF.
1170     ELSE.
1171       l_f_bpin-fcode = c_fcode.
1172     ENDIF.
1173
1174   *  "/ No fcode
1175     IF l_f_bpin-fcode IS INITIAL.
1176       c_fcode = l_f_bpin-fcode.
1177       EXIT.
1178     ENDIF.
1179
1180   *  "/ Aus FCODE Technik ermitteln
1181     CALL FUNCTION 'KBPS_INIT'
1182       EXPORTING
1183         bp_import = l_f_bpin
1184       IMPORTING
1185         bp_in     = l_f_bpin
1186       EXCEPTIONS
1187         OTHERS    = 1.
1188
1189     IF sy-subrc = 0.
1190       c_fcode = l_f_bpin-fcode.
1191       c_tech  = l_f_bpin-tech.
1192     ELSE.
1193       CLEAR: c_fcode, c_tech.
1194     ENDIF.
1195
1196   ENDFORM.                    " GET_TECH
1197
1198   *&---------------------------------------------------------------------*
1199   *&      Form  GET_TECH_TEXT
1200   *&---------------------------------------------------------------------*
1201   FORM get_tech_text USING u_tech  LIKE bpin-tech
1202                   CHANGING c_ttext LIKE fmdy-ttext.
1203
1204     DATA: l_sav_name  LIKE dd07v-domname,
1205           l_sav_value LIKE dd07v-domvalue_l,
1206           l_sav_text  LIKE dd07v-ddtext.
1207
1208     CLEAR c_ttext.
1209     l_sav_name  = 'BP_TECH'.
1210     l_sav_value = u_tech.
1211     CALL FUNCTION 'DOMAIN_VALUE_GET'
1212       EXPORTING
1213         i_domname  = l_sav_name
1214         i_domvalue = l_sav_value
1215       IMPORTING
1216         e_ddtext   = l_sav_text
1217       EXCEPTIONS
1218         not_exist  = 1
1219         OTHERS     = 2.
1220
1221     CHECK sy-subrc = 0.
1222     c_ttext = l_sav_text(20).
1223
1224   ENDFORM.                    " GET_TECH_TEXT
1225
1226   *&---------------------------------------------------------------------*
1227   *&      Form  GET_BSTEXT
1228   *&---------------------------------------------------------------------*
1229   FORM get_bstext USING u_bstat
1230                CHANGING c_bstext.
1231
1232     CLEAR c_bstext.
1233
1234   *  "/ Text zum Status ermitteln
1235     CALL FUNCTION 'KBPS_GET_TEXT_DOC_STATUS'
1236       EXPORTING
1237         ip_bstat            = u_bstat
1238       IMPORTING
1239         op_string_20        = c_bstext
1240       EXCEPTIONS
1241         status_type_invalid = 1
1242         OTHERS              = 2.
1243
1244   ENDFORM.                    " GET_BSTEXT
1245
1246   *&---------------------------------------------------------------------*
1247   *&      Form  GET_RSTAT_T
1248   *&---------------------------------------------------------------------*
1249   FORM get_rstat_t USING    p_i_rstat
1250                   CHANGING p_e_rstat_t.
1251
1252     CLEAR p_e_rstat_t.
1253
1254     CALL FUNCTION 'KBPS_GET_TEXT_REV_STATUS'
1255       EXPORTING
1256         ip_rstat            = p_i_rstat
1257       IMPORTING
1258         op_string_20        = p_e_rstat_t
1259       EXCEPTIONS
1260         status_type_invalid = 1
1261         OTHERS              = 2.
1262
1263
1264   ENDFORM.                    " GET_rstat_t
1265
1266   *&---------------------------------------------------------------------*
1267   *&      Form  GET_REASON_TEXT
1268   *&---------------------------------------------------------------------*
1269   FORM get_reason_text USING u_reason LIKE bpdk-reason
1270                     CHANGING c_rtext LIKE fmdy-rtext.
1271
1272     CLEAR c_rtext.
1273     SELECT SINGLE * FROM treasonst WHERE fmreason = u_reason
1274                                      AND spras    = sy-langu.
1275     CHECK sy-subrc = 0.
1276     c_rtext = treasonst-fmreasntxt.
1277
1278   ENDFORM.                    " GET_REASON_TEXT
1279
1280   *&---------------------------------------------------------------------*
1281   *&      Form  GET_SGTEXT
1282   *&---------------------------------------------------------------------*
1283   FORM get_sgtext USING u_belnr        LIKE bpdkt-belnr
1284                CHANGING c_sgtext       LIKE bpdkt-sgtext
1285                         c_namtext      LIKE bpdkt-namtext.
1286
1287     CLEAR: c_sgtext, c_namtext.
1288     " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 14.06.2026  for ATC
1289   *  SELECT SINGLE * FROM bpdkt WHERE belnr = u_belnr.
1290     SELECT SINGLE * FROM bpdkt WHERE belnr = u_belnr.  "#EC CI_DB_OPERATION_OK
1291     " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 14.06.2026 for ATC
1292     CHECK sy-subrc = 0.
1293     c_sgtext  = bpdkt-sgtext.
1294     c_namtext = bpdkt-namtext.
1295
1296   ENDFORM.                    " GET_SGTEXT
1297
1298   **&---------------------------------------------------------------------*
1299   **&      Form  FILL_FIELDCAT_BPDK
1300   **&---------------------------------------------------------------------*
1301   **       Fill fieldcatalog for table BPDK
1302   **----------------------------------------------------------------------*
1303   *FORM fill_fieldcat_bpdk CHANGING u_cnt_colpos LIKE sy-index
1304   *                                 c_t_fieldcat TYPE slis_t_fieldcat_alv.
1305   *
1306   *  DATA: l_f_fieldcat LIKE LINE OF c_t_fieldcat.
1307   *  DATA: ci_bpdk_active.
1308   *
1309   ** "/ Erfasungbelegnummer
1310   *  CLEAR l_f_fieldcat.
1311   *  u_cnt_colpos               =  u_cnt_colpos + 1.
1312   *  l_f_fieldcat-fieldname     = 'BPDK_BELNR'.
1313   *  l_f_fieldcat-ref_fieldname = 'BPDK_BELNR'.
1314   *  l_f_fieldcat-ref_tabname   = 'BPBK'.
1315   *  l_f_fieldcat-col_pos       =  u_cnt_colpos.
1316   *  l_f_fieldcat-seltext_l     = text-301.
1317   *  l_f_fieldcat-seltext_m     = text-301.
1318   *  l_f_fieldcat-seltext_s     = text-301.
1319   *  l_f_fieldcat-reptext_ddic  = text-301.
1320   *  l_f_fieldcat-no_sum        = 'X'.
1321   *  l_f_fieldcat-no_out        = 'X'.
1322   *  APPEND l_f_fieldcat TO c_t_fieldcat.
1323   *
1324   ** "/ Belegdatum
1325   *  CLEAR l_f_fieldcat.
1326   *  u_cnt_colpos              =  u_cnt_colpos + 1.
1327   *  l_f_fieldcat-fieldname    = 'BLDAT'.
1328   *  l_f_fieldcat-ref_tabname  = 'BPDK'.
1329   *  l_f_fieldcat-col_pos      =  u_cnt_colpos.
1330   *  l_f_fieldcat-no_out       = 'X'.
1331   *  APPEND l_f_fieldcat TO c_t_fieldcat.
1332   *
1333   ** "/ Status-Text
1334   *  CLEAR l_f_fieldcat.
1335   *  u_cnt_colpos             =  u_cnt_colpos + 1.
1336   *  l_f_fieldcat-fieldname   = 'BSTEXT'.
1337   *  l_f_fieldcat-ref_tabname = 'FMDY'.
1338   *  l_f_fieldcat-col_pos     =  u_cnt_colpos.
1339   *  l_f_fieldcat-no_out      = 'X'.
1340   *  APPEND l_f_fieldcat TO c_t_fieldcat.
1341   *
1342   ** "/ Status-Text
1343   *  CLEAR l_f_fieldcat.
1344   *  u_cnt_colpos             =  u_cnt_colpos + 1.
1345   *  l_f_fieldcat-fieldname   = 'RSTAT_T'.
1346   *  l_f_fieldcat-ref_tabname = 'BPDY'.
1347   *  l_f_fieldcat-col_pos     =  u_cnt_colpos.
1348   *  l_f_fieldcat-no_out      = 'X'.
1349   *  APPEND l_f_fieldcat TO c_t_fieldcat.
1350   *
1351   ** "/ Originalbeleg
1352   *  CLEAR l_f_fieldcat.
1353   *  u_cnt_colpos             =  u_cnt_colpos + 1.
1354   *  l_f_fieldcat-fieldname   = 'REV_DOCNR'.
1355   *  l_f_fieldcat-ref_tabname = 'BPDK'.
1356   *  l_f_fieldcat-col_pos     =  u_cnt_colpos.
1357   *  l_f_fieldcat-no_out      = 'X'.
1358   *  APPEND l_f_fieldcat TO c_t_fieldcat.
1359   *
1360   ** "/ Wertstellungsdatum
1361   *  CLEAR l_f_fieldcat.
1362   *  u_cnt_colpos             =  u_cnt_colpos + 1.
1363   *  l_f_fieldcat-fieldname   = 'VADAT'.
1364   *  l_f_fieldcat-ref_tabname = 'BPDK'.
1365   *  l_f_fieldcat-col_pos     =  u_cnt_colpos.
1366   *  l_f_fieldcat-no_out      = 'X'.
1367   *  APPEND l_f_fieldcat TO c_t_fieldcat.
1368   *
1369   ** "/ Technik-Text
1370   *  CLEAR l_f_fieldcat.
1371   *  u_cnt_colpos             =  u_cnt_colpos + 1.
1372   *  l_f_fieldcat-fieldname   = 'TTEXT'.
1373   *  l_f_fieldcat-ref_tabname = 'FMDY'.
1374   *  l_f_fieldcat-col_pos     =  u_cnt_colpos.
1375   *  l_f_fieldcat-no_out      = 'X'.
1376   *  APPEND l_f_fieldcat TO c_t_fieldcat.
1377   *
1378   ** "/ Verantwortlicher
1379   *  CLEAR l_f_fieldcat.
1380   *  u_cnt_colpos             =  u_cnt_colpos + 1.
1381   *  l_f_fieldcat-fieldname   = 'VERANT'.
1382   *  l_f_fieldcat-ref_tabname = 'BPDK'.
1383   *  l_f_fieldcat-col_pos     =  u_cnt_colpos.
1384   *  l_f_fieldcat-no_out      = 'X'.
1385   *  APPEND l_f_fieldcat TO c_t_fieldcat.
1386   *
1387   ** "/ Entscheidungsgrund-Text
1388   *  CLEAR l_f_fieldcat.
1389   *  u_cnt_colpos             =  u_cnt_colpos + 1.
1390   *  l_f_fieldcat-fieldname   = 'RTEXT'.
1391   *  l_f_fieldcat-ref_tabname = 'FMDY'.
1392   *  l_f_fieldcat-col_pos     =  u_cnt_colpos.
1393   *  l_f_fieldcat-no_out      = 'X'.
1394   *  APPEND l_f_fieldcat TO c_t_fieldcat.
1395   *
1396   ** "/ VALKEY
1397   *  CLEAR l_f_fieldcat.
1398   *  u_cnt_colpos             =  u_cnt_colpos + 1.
1399   *  l_f_fieldcat-fieldname   = 'VALKEY'.
1400   *  l_f_fieldcat-ref_tabname = 'BPDK'.
1401   *  l_f_fieldcat-col_pos     =  u_cnt_colpos.
1402   *  l_f_fieldcat-no_out      = 'X'.
1403   *  APPEND l_f_fieldcat TO c_t_fieldcat.
1404   *
1405   ** "/ Technik
1406   *  CLEAR l_f_fieldcat.
1407   *  u_cnt_colpos             =  u_cnt_colpos + 1.
1408   *  l_f_fieldcat-fieldname   = 'TECH'.
1409   *  l_f_fieldcat-ref_tabname = 'BPIN'.
1410   *  l_f_fieldcat-col_pos     =  u_cnt_colpos.
1411   *  l_f_fieldcat-no_out      = 'X'.
1412   *  APPEND l_f_fieldcat TO c_t_fieldcat.
1413   *
1414   ** "/ Belegstatus
1415   *  CLEAR l_f_fieldcat.
1416   *  u_cnt_colpos             =  u_cnt_colpos + 1.
1417   *  l_f_fieldcat-fieldname   = 'BSTAT'.
1418   *  l_f_fieldcat-ref_tabname = 'BPDK'.
1419   *  l_f_fieldcat-col_pos     =  u_cnt_colpos.
1420   *  l_f_fieldcat-no_out      = 'X'.
1421   *  APPEND l_f_fieldcat TO c_t_fieldcat.
1422   *
1423   ** "/ Belegstatus
1424   *  CLEAR l_f_fieldcat.
1425   *  u_cnt_colpos             =  u_cnt_colpos + 1.
1426   *  l_f_fieldcat-fieldname   = 'RSTAT'.
1427   *  l_f_fieldcat-ref_tabname = 'BPDK'.
1428   *  l_f_fieldcat-col_pos     =  u_cnt_colpos.
1429   *  l_f_fieldcat-no_out      = 'X'.
1430   *  APPEND l_f_fieldcat TO c_t_fieldcat.
1431   *
1432   ** "/ Entscheidungsgrund
1433   *  CLEAR l_f_fieldcat.
1434   *  u_cnt_colpos             =  u_cnt_colpos + 1.
1435   *  l_f_fieldcat-fieldname   = 'REASON'.
1436   *  l_f_fieldcat-ref_tabname = 'BPDK'.
1437   *  l_f_fieldcat-col_pos     =  u_cnt_colpos.
1438   *  l_f_fieldcat-no_out      = 'X'.
1439   *  APPEND l_f_fieldcat TO c_t_fieldcat.
1440   *
1441   ** "/ Textname
1442   *  CLEAR l_f_fieldcat.
1443   *  u_cnt_colpos             =  u_cnt_colpos + 1.
1444   *  l_f_fieldcat-fieldname   = 'NAMTEXT'.
1445   *  l_f_fieldcat-ref_tabname = 'BPDKT'.
1446   *  l_f_fieldcat-col_pos     =  u_cnt_colpos.
1447   *  l_f_fieldcat-no_out      = 'X'.
1448   *  APPEND l_f_fieldcat TO c_t_fieldcat.
1449   *
1450   ** "/ RPUBLAW
1451   *  CLEAR l_f_fieldcat.
1452   *  u_cnt_colpos             =  u_cnt_colpos + 1.
1453   *  l_f_fieldcat-fieldname   = 'RPUBLAW'.
1454   *  l_f_fieldcat-ref_tabname = 'BPDK'.
1455   *  l_f_fieldcat-col_pos     =  u_cnt_colpos.
1456   *  l_f_fieldcat-no_out      = 'X'.
1457   *  APPEND l_f_fieldcat TO c_t_fieldcat.
1458   *
1459   ** "/ RLEGIS
1460   *  CLEAR l_f_fieldcat.
1461   *  u_cnt_colpos             =  u_cnt_colpos + 1.
1462   *  l_f_fieldcat-fieldname   = 'RLEGIS'.
1463   *  l_f_fieldcat-ref_tabname = 'BPDK'.
1464   *  l_f_fieldcat-col_pos     =  u_cnt_colpos.
1465   *  l_f_fieldcat-no_out      = 'X'.
1466   *  APPEND l_f_fieldcat TO c_t_fieldcat.
1467   *
1468   ** "/ RCOHORT
1469   *  CLEAR l_f_fieldcat.
1470   *  u_cnt_colpos             =  u_cnt_colpos + 1.
1471   *  l_f_fieldcat-fieldname   = 'RCOHORT'.
1472   *  l_f_fieldcat-ref_tabname = 'BPDK'.
1473   *  l_f_fieldcat-col_pos     =  u_cnt_colpos.
1474   *  l_f_fieldcat-no_out      = 'X'.
1475   *  APPEND l_f_fieldcat TO c_t_fieldcat.
1476   *
1477   ** "/ Buchungsdatum
1478   *  CLEAR l_f_fieldcat.
1479   *  u_cnt_colpos             =  u_cnt_colpos + 1.
1480   *  l_f_fieldcat-fieldname   = 'BUDAT'.
1481   *  l_f_fieldcat-ref_tabname = 'BPDK'.
1482   *  l_f_fieldcat-col_pos     =  u_cnt_colpos.
1483   *  l_f_fieldcat-no_out      = 'X'.
1484   *  APPEND l_f_fieldcat TO c_t_fieldcat.
1485   *
1486   ** "/ Art des Erfassungsbeleges
1487   *  CLEAR l_f_fieldcat.
1488   *  u_cnt_colpos             =  u_cnt_colpos + 1.
1489   *  l_f_fieldcat-fieldname   = 'DOCTYPE'.
1490   *  l_f_fieldcat-ref_tabname = 'BPDK'.
1491   *  l_f_fieldcat-col_pos     =  u_cnt_colpos.
1492   *  l_f_fieldcat-no_out      = 'X'.
1493   *  APPEND l_f_fieldcat TO c_t_fieldcat.
1494   *
1495   ** "/ Check if customer extension of table BPDK exists
1496   *  CALL FUNCTION 'MODX_FUNCTION_ACTIVE_CHECK'
1497   *    EXPORTING
1498   *      cprogname  = 'SAPLKBPB'
1499   *      funcnumber = '004'
1500   *    IMPORTING
1501   *      active     = ci_bpdk_active.
1502   *
1503   ** "/ Add customer extension
1504   *  IF NOT ci_bpdk_active IS INITIAL.
1505   *    PERFORM fill_fieldcat_ci_bpdk CHANGING c_t_fieldcat.
1506   *  ENDIF.
1507   *
1508   *ENDFORM.                    " FILL_FIELDCAT_BPDK
1509   *
1510   **&---------------------------------------------------------------------*
1511   **&      Form  FILL_FIELDCAT_CI_BPDK
1512   **&---------------------------------------------------------------------*
1513   **       Fill fieldcatalog for user defined structure CI_BPDK
1514   **----------------------------------------------------------------------*
1515   *FORM fill_fieldcat_ci_bpdk
1516   *          CHANGING c_t_fieldcat TYPE slis_t_fieldcat_alv.
1517   *
1518   *  DATA: l_f_fieldcat LIKE LINE OF c_t_fieldcat.
1519   *  DATA: l_t_nametab  LIKE x031l OCCURS 50 WITH HEADER LINE.
1520   *  DATA: l_cnt_colpos LIKE sy-tabix.
1521   *
1522   *  CALL FUNCTION 'DDIF_NAMETAB_GET'
1523   *    EXPORTING
1524   *      tabname   = 'CI_BPDK'
1525   *    TABLES
1526   *      x031l_tab = l_t_nametab
1527   *    EXCEPTIONS
1528   *      not_found = 1
1529   *      OTHERS    = 2.
1530   *
1531   *  CHECK sy-subrc = 0.
1532   *
1533   *  l_cnt_colpos = 800.
1534   *  LOOP AT l_t_nametab.
1535   *
1536   *    l_cnt_colpos = l_cnt_colpos + 1.
1537   *
1538   *    CLEAR l_f_fieldcat.
1539   *
1540   *    l_f_fieldcat-fieldname   = l_t_nametab-fieldname.
1541   *    l_f_fieldcat-ref_tabname = l_t_nametab-tabname.
1542   *    l_f_fieldcat-col_pos     = l_cnt_colpos.
1543   *
1544   *    APPEND l_f_fieldcat TO c_t_fieldcat.
1545   *
1546   *  ENDLOOP.
1547   *
1548   *ENDFORM.                    " FILL_FIELDCAT_CI_BPDK
1549
1550   **&---------------------------------------------------------------------*
1551   **&      Form  FILL_HEADER
1552   **&---------------------------------------------------------------------*
1553   *FORM fill_header CHANGING  c_title          TYPE lvc_title
1554   *                           c_background_id  TYPE sdydo_key
1555   *                           c_t_object_info  TYPE fm_t_listheader_data
1556   *                           c_t_top_messages TYPE fm_t_top_messages.
1557   *
1558   *  DATA:
1559   *    l_date(20)   TYPE c,
1560   *    l_time(20)   TYPE c,
1561   *    l_sav_title  LIKE sy-title,
1562   *    l_f_top_data TYPE ifm_listheader_data.
1563   *
1564   *  CONSTANTS: con_exitname TYPE exit_def VALUE 'FM_LIST_HEADER_ADDIN'.
1565   *
1566   *  STATICS:
1567   *    st_ref_header_exit TYPE REF TO if_ex_fm_list_header_addin.
1568   *
1569   **----- instanciate/initiate user exit for wallpaper
1570   *  IF st_ref_header_exit IS INITIAL.
1571   *    CALL METHOD cl_exithandler=>get_instance
1572   *      EXPORTING
1573   *        exit_name              = con_exitname
1574   *        null_instance_accepted = 'X'
1575   *      CHANGING
1576   *        instance               = st_ref_header_exit.
1577   *  ENDIF.
1578   *
1579   **----- get wallpaper according to user requirements and implementation
1580   *  IF NOT st_ref_header_exit IS INITIAL.
1581   *    CALL METHOD st_ref_header_exit->change_background
1582   *      CHANGING
1583   *        c_background_id = c_background_id.
1584   *  ENDIF.
1585   *
1586   **  "/ List-Titel holen, falls vorhanden
1587   *  CALL FUNCTION 'FM_REPORT_TITLE_SET'
1588   *    IMPORTING
1589   *      e_title = l_sav_title.
1590   *
1591   *  IF NOT l_sav_title IS INITIAL.
1592   *    c_title = l_sav_title.
1593   *  ELSE.
1594   *    c_title = sy-title.
1595   *  ENDIF.
1596   *
1597   ** "/ Info message if P_MAXSEL has been arrived
1598   *  PERFORM maxsel_info_message TABLES c_t_top_messages.
1599   *
1600   *  WRITE sy-datlo TO l_date.
1601   *  WRITE sy-uzeit TO l_time.
1602   *  CONCATENATE l_date l_time
1603   *    INTO  l_f_top_data-data_key
1604   *    SEPARATED BY '   '.
1605   *  l_f_top_data-column = 1.
1606   *  APPEND l_f_top_data TO c_t_object_info.
1607   *
1608   *  IF NOT p_khead IS INITIAL.
1609   *    l_f_top_data-data_key  = text-210.
1610   *    l_f_top_data-data_info = g_f_hhmkont-fikrs.
1611   *    l_f_top_data-column = 1.
1612   *    APPEND l_f_top_data TO c_t_object_info.
1613   *
1614   *    IF NOT g_flg_fund_active IS INITIAL.
1615   *      l_f_top_data-data_key  = text-211.
1616   *      l_f_top_data-data_info = g_f_hhmkont-fonds.
1617   *      l_f_top_data-column = 1.
1618   *      APPEND l_f_top_data TO c_t_object_info.
1619   *    ENDIF.
1620   *
1621   *    l_f_top_data-data_key  = text-212.
1622   *    l_f_top_data-data_info = g_f_hhmkont-fictr.
1623   *    l_f_top_data-column = 1.
1624   *    APPEND l_f_top_data TO c_t_object_info.
1625   *
1626   *    l_f_top_data-data_key  = text-213.
1627   *    l_f_top_data-data_info = g_f_hhmkont-fipex.
1628   *    l_f_top_data-column = 1.
1629   *    APPEND l_f_top_data TO c_t_object_info.
1630   *
1631   *    IF NOT g_flg_farea_active IS INITIAL.
1632   *      l_f_top_data-data_key  = text-214.
1633   *      l_f_top_data-data_info = g_f_hhmkont-farea.
1634   *      l_f_top_data-column = 1.
1635   *      APPEND l_f_top_data TO c_t_object_info.
1636   *    ENDIF.
1637   *  ENDIF.
1638   *
1639   *ENDFORM.                    " FILL_HEADER
1640
1641   **&---------------------------------------------------------------------*
1642   **&      Form F4_DISPLAY_VARIANT
1643   **&---------------------------------------------------------------------*
1644   **&      F4 Help for display variant
1645   **&---------------------------------------------------------------------*
1646   *FORM f4_display_variant.
1647   *
1648   *  CLEAR g_f_disvariant.
1649   *  g_f_disvariant-report   =  sy-cprog.
1650   *  g_f_disvariant-username =  sy-uname.
1651   *
1652   *  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
1653   *    EXPORTING
1654   *      is_variant = g_f_disvariant
1655   *      i_save     = 'A'
1656   *    IMPORTING
1657   *      es_variant = g_f_disvariant.
1658   *  p_disvar = g_f_disvariant-variant.
1659   *
1660   *ENDFORM.                     " F4_DISPLAY_VARIANT
1661   **&---------------------------------------------------------------------*
1662   **&   Form CHECK_DISPLAY_VARIANT
1663   **&---------------------------------------------------------------------*
1664   **&   Check of display variant
1665   **&---------------------------------------------------------------------*
1666   *FORM check_display_variant.
1667   *
1668   *  CLEAR g_f_disvariant.
1669   *
1670   *  CHECK NOT p_disvar IS INITIAL.
1671   *
1672   *  g_f_disvariant-report   =  sy-cprog.
1673   *  g_f_disvariant-username =  sy-uname.
1674   *  g_f_disvariant-variant  =  p_disvar.
1675   ** "/ Read the variant
1676   *  CALL FUNCTION 'REUSE_ALV_VARIANT_SELECT'
1677   *    EXPORTING
1678   *      i_dialog            = space
1679   *      i_user_specific     = 'X'
1680   *      it_default_fieldcat = g_t_fieldcat
1681   *      i_layout            = g_f_layout
1682   *    CHANGING
1683   *      cs_variant          = g_f_disvariant
1684   *    EXCEPTIONS
1685   *      wrong_input         = 1
1686   *      fc_not_complete     = 2
1687   *      not_found           = 3
1688   *      program_error       = 4
1689   *      OTHERS              = 5.
1690   *  IF sy-subrc <> 0.
1691   **   "/ Variant doesn't exist
1692   *    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
1693   *          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
1694   *  ENDIF.
1695   *ENDFORM.                           " CHECK_DISPLAY_VARIANT
1696   *&---------------------------------------------------------------------*
1697   *&   Form INIT_SCHEDMAN
1698   *&---------------------------------------------------------------------*
1699   *&   initialize schedman monitor
1700   *&   note: commit work executed
1701   *&---------------------------------------------------------------------*
1702   FORM init_schedman.
1703
1704   *----- initialize schedman monitor
1705     CALL FUNCTION 'FM_FYC_SCHEDMAN_INIT'
1706       EXPORTING
1707         i_repid          = con_repid
1708         i_wfitem         = wf_witem
1709         i_wflist         = wf_wlist
1710       IMPORTING
1711         e_f_schedman_key = g_f_schedman_key.
1712
1713   ENDFORM.                           " INIT_SCHEDMAN
1714   *&---------------------------------------------------------------------*
1715   *&   Form CLOSE_SCHEDMAN
1716   *&---------------------------------------------------------------------*
1717   *&   send info to schedman monitor
1718   *&   note: commit work executed
1719   *&---------------------------------------------------------------------*
1720   FORM close_schedman.
1721
1722     DATA: l_f_lines LIKE sy-tfill.
1723
1724     DESCRIBE TABLE g_t_item LINES l_f_lines.
1725
1726   *----- send info to schedman monitor
1727     CALL FUNCTION 'FM_FYC_SCHEDMAN_CLOSE'
1728       EXPORTING
1729         i_f_schedman_key = g_f_schedman_key
1730         i_wfitem         = wf_witem
1731         i_wfokey         = wf_okey
1732         i_aplstat        = g_aplstat
1733         i_cnt_obj        = l_f_lines.
1734
1735   ENDFORM.                           " CLOSE_SCHEDMAN
1736
1737   **&---------------------------------------------------------------------*
1738   **&   Form MAXSEL_INFO_MESSAGE
1739   **&---------------------------------------------------------------------*
1740   **&   print info if P_MAXSEL has been arrived
1741   **&---------------------------------------------------------------------*
1742   *FORM maxsel_info_message TABLES c_t_top_messages.
1743   *
1744   *  DATA: l_f_top_messages TYPE ifm_top_message,
1745   *        l_msg_text       TYPE msg_txt,
1746   *        l_msgv           TYPE char10.
1747   *
1748   *  IF NOT p_maxsel IS INITIAL AND
1749   *         p_maxsel LE fmsg_fmf-cnt_selected_data.
1750   **  "/ Trefferzahl eingeschraenkt
1751   *    MOVE p_maxsel TO l_msgv.
1752   *    CALL FUNCTION 'MESSAGE_TEXT_BUILD'
1753   *      EXPORTING
1754   *        msgid               = 'FMRP'
1755   *        msgnr               = '100'
1756   *        msgv1               = l_msgv
1757   *      IMPORTING
1758   *        message_text_output = l_msg_text.
1759   *
1760   *    CONCATENATE l_msg_text '(FMRP' '100)' INTO l_f_top_messages-message
1761   *                                        SEPARATED BY space.
1762   *    CONDENSE l_f_top_messages-message.
1763   *    MOVE icon_message_information TO l_f_top_messages-icon.
1764   *
1765   *    APPEND l_f_top_messages TO c_t_top_messages.
1766   *  ENDIF.
1767   *ENDFORM.                               " MAXSEL_INFO_MESSAGE
1768
1769   GET fmaarel FIELDS fonds   fname     sponsor finuse fund_type fund_typet
1770                   fictr   ctr_objnr cname   bossid
1771                   fipex   posit     pname   potyp   efictr
1772                   efipex1 efipex2   efipex3 efipex4 efipex5
1773                   farea ftext
1774   *                 "/ Substrings
1775                   fdstr_id   fdsub1     fdsub2
1776                   fdsub1t_sh fdsub1t_lo fdsub2t_sh fdsub2t_lo
1777                   fcstr_id   fcsub1     fcsub2     fcsub3
1778                   fcsub1t_sh fcsub1t_lo fcsub2t_sh fcsub2t_lo
1779                   fcsub3t_sh fcsub3t_lo
1780                   cistr_id   cisub1     cisub2     cisub3 cisub4 cisub5
1781                   cisub1t_sh cisub1t_lo cisub2t_sh
1782                   cisub2t_lo cisub3t_sh cisub3t_lo cisub4t_sh
1783                   cisub4t_lo cisub5t_sh cisub5t_lo
1784                   fnstr_id   fnsub1
1785                   fnsub2     fnsub3     fnsub1t_sh fnsub1t_lo fnsub2t_sh
1786                   fnsub2t_lo fnsub3t_sh fnsub3t_lo.
1787
1788     MOVE-CORRESPONDING fmaarel TO g_t_master_data.
1789     COLLECT g_t_master_data.
1790
1791   *  "/ Read transaction data
1792   GET fmaarel LATE.
1793     SORT g_t_master_data BY fonds fictr fipex farea.
1794
1795   ************************************************************************
1796   *&---------------------------------------------------------------------*
1797   *&      Form  check_p_only_r
1798   *&---------------------------------------------------------------------*
1799   *       Check assigned cover pool and set Parameter P_ONLY_R
1800   *----------------------------------------------------------------------*
1801   FORM check_p_only_r.
1802
1803     DATA: l_t_trange     TYPE rsds_trange,
1804           l_f_dyn_range  TYPE rsds_range,
1805           l_f_dyn_frange TYPE rsds_frange,
1806           l_t_segments   TYPE rsds_trange,
1807           l_f_segments   LIKE LINE OF l_t_segments,
1808           l_f_fields     LIKE LINE OF l_f_segments-frange_t,
1809           l_f_selopt     LIKE LINE OF l_f_fields-selopt_t.
1810
1811
1812     CONSTANTS: con_fmaarel(7) TYPE c VALUE 'FMAAREL',
1813                con_deckrng(7) TYPE c VALUE 'DECKRNG'.
1814
1815   * "/ read dynamical selections
1816     CALL FUNCTION 'RS_REFRESH_FROM_DYNAMICAL_SEL'
1817       EXPORTING
1818         curr_report        = con_repid
1819         mode_write_or_move = 'M'
1820       IMPORTING
1821         p_trange           = l_t_trange
1822       EXCEPTIONS
1823         not_found          = 1
1824         wrong_type         = 2
1825         OTHERS             = 3.
1826
1827   * "/ Caution!!! The relevant information (value of free selection)
1828   * "/ of the internal table 'l_t_trange' is hidden in a deep structure.
1829     LOOP AT l_t_trange INTO l_f_dyn_range.
1830
1831       IF l_f_dyn_range-tablename = con_fmaarel.
1832   * "/ Is there any free selection for the cover pool ???
1833         READ TABLE l_f_dyn_range-frange_t INTO l_f_fields
1834                  WITH KEY fieldname = con_deckrng.
1835         IF sy-subrc = 0.
1836   * "/ Are there any (not initialized) values?
1837           LOOP AT l_f_fields-selopt_t INTO l_f_selopt.
1838             IF NOT l_f_selopt-low IS INITIAL.
1839   * "/ Then, set flag for 'Read only cover pool items'
1840               p_only_r = 'X'.
1841               CLEAR fmsg_fmf-xfmaarel.
1842
1843             ENDIF.
1844           ENDLOOP.
1845         ENDIF.
1846       ENDIF.
1847     ENDLOOP.
1848
1849   ENDFORM.                    " check_p_only_r
1850
1851   AT SELECTION-SCREEN.
1852   * Clear Flags for FMAAREL if not called per SUBMIT
1853     CLEAR p_ud.
1854     CLEAR p_ed.
1855     CLEAR p_rp.
1856     IF p_subrel IS INITIAL.
1857       IF p_only_r IS INITIAL.
1858         CLEAR p_gd.
1859         CLEAR p_gjrel.
1860       ENDIF.
1861     ENDIF.
1862
1863   *&---------------------------------------------------------------------*
1864   *&      Form  seperate_records
1865   *&---------------------------------------------------------------------*
1866   FORM seperate_records.
1867     g_2gjahr = p_gjahr + 1.
1868     g_3gjahr = p_gjahr + 2.
1869     DELETE ist_g_t_item WHERE versn NE '000'.
1870
1871     LOOP AT ist_g_t_item INTO wa_g_t_item WHERE gjahr EQ p_gjahr.
1872       MOVE-CORRESPONDING wa_g_t_item TO wa_g_curr_gjahr.
1873       APPEND wa_g_curr_gjahr TO ist_g_curr_gjahr.
1874     ENDLOOP.
1875
1876     LOOP AT ist_g_t_item INTO wa_g_t_item WHERE gjahr EQ g_2gjahr.
1877       MOVE-CORRESPONDING wa_g_t_item TO wa_g_2_gjahr.
1878       APPEND wa_g_2_gjahr TO ist_g_2_gjahr.
1879     ENDLOOP.
1880
1881     LOOP AT ist_g_t_item INTO wa_g_t_item WHERE gjahr EQ g_3gjahr.
1882       MOVE-CORRESPONDING wa_g_t_item TO wa_g_3_gjahr.
1883       APPEND wa_g_3_gjahr TO ist_g_3_gjahr.
1884     ENDLOOP.
1885
1886     CLEAR : wa_g_curr_gjahr, wa_g_2_gjahr, wa_g_3_gjahr.
1887
1888   ENDFORM.                    " seperate_records
1889
1890   FORM build_disp_table.
1891
1892   * - fill data for current year
1893     LOOP AT ist_g_curr_gjahr2 INTO wa_g_curr_gjahr2.
1894       wa_tab_disp3-fictr = wa_g_curr_gjahr2-fictr. " Fund center
1895       wa_tab_disp3-cname = wa_g_curr_gjahr2-cname. " Fund center text
1896       wa_tab_disp3-fipos = wa_g_curr_gjahr2-fipos. " Comm Item
1897       wa_tab_disp3-pname = wa_g_curr_gjahr2-pname. " Comm Item text
1898       wa_tab_disp3-wljhr_2 = wa_g_curr_gjahr2-wljhr. " Current Budget
1899
1900       LOOP AT ist_g_curr_gjahr1 INTO wa_g_curr_gjahr1
1901                 WHERE fictr EQ wa_g_curr_gjahr2-fictr
1902                 AND fipos EQ  wa_g_curr_gjahr2-fipos.
1903
1904         CASE wa_g_curr_gjahr1-vorga.
1905
1906           WHEN 'KBUD'.
1907             wa_tab_disp3-wljhr_1 = wa_g_curr_gjahr1-wljhr.
1908
1909         ENDCASE.
1910
1911       ENDLOOP.
1912       APPEND wa_tab_disp3 TO ist_tab_disp3.
1913       CLEAR wa_g_curr_gjahr1.
1914       CLEAR wa_tab_disp3.
1915
1916     ENDLOOP.
1917
1918   * - fill data for the next year
1919     SORT ist_tab_disp3 BY fictr fipos.
1920
1921
1922     LOOP AT ist_g_2_gjahr2 INTO wa_g_2_gjahr2.
1923
1924       READ TABLE ist_tab_disp3 INTO wa_tab_disp3
1925                  WITH KEY fictr = wa_g_2_gjahr2-fictr
1926                           fipos = wa_g_2_gjahr2-fipos.
1927
1928       IF sy-subrc EQ 0.
1929         wa_tab_disp3-wljhr_4 = wa_g_2_gjahr2-wljhr. " Current Budget
1930
1931         LOOP AT ist_g_2_gjahr1 INTO wa_g_2_gjahr1
1932                   WHERE fictr EQ wa_g_2_gjahr2-fictr
1933                   AND fipos EQ  wa_g_2_gjahr2-fipos.
1934
1935           CASE wa_g_2_gjahr1-vorga.
1936
1937             WHEN 'KBUD'.
1938               wa_tab_disp3-wljhr_3 = wa_g_2_gjahr1-wljhr.
1939
1940           ENDCASE.
1941
1942         ENDLOOP.
1943         MODIFY ist_tab_disp3 FROM wa_tab_disp3 INDEX sy-tabix.
1944         CLEAR wa_g_2_gjahr1.
1945         CLEAR wa_tab_disp3.
1946
1947       ELSE.
1948
1949         wa_tab_disp3-fictr = wa_g_2_gjahr2-fictr. " Fund center
1950         wa_tab_disp3-cname = wa_g_2_gjahr2-cname. " Fund center text
1951         wa_tab_disp3-fipos = wa_g_2_gjahr2-fipos. " Comm Item
1952         wa_tab_disp3-pname = wa_g_2_gjahr2-pname. " Comm Item text
1953         wa_tab_disp3-wljhr_3 = wa_g_2_gjahr2-wljhr. " Current Budget
1954
1955         LOOP AT ist_g_2_gjahr1 INTO wa_g_2_gjahr1
1956                   WHERE fictr EQ wa_g_2_gjahr2-fictr
1957                   AND fipos EQ  wa_g_2_gjahr2-fipos.
1958
1959           CASE wa_g_2_gjahr1-vorga.
1960
1961             WHEN 'KBUD'.
1962               wa_tab_disp3-wljhr_4 = wa_g_2_gjahr1-wljhr.
1963
1964           ENDCASE.
1965
1966         ENDLOOP.
1967         APPEND wa_tab_disp3 TO ist_tab_disp3.
1968         CLEAR wa_g_2_gjahr1.
1969         CLEAR wa_tab_disp3.
1970       ENDIF.
1971
1972     ENDLOOP.
1973
1974   * - fill data for the third year
1975     SORT ist_tab_disp3 BY fictr fipos.
1976
1977     LOOP AT ist_g_3_gjahr2 INTO wa_g_3_gjahr2.
1978
1979       READ TABLE ist_tab_disp3 INTO wa_tab_disp3
1980                  WITH KEY fictr = wa_g_3_gjahr2-fictr
1981                           fipos = wa_g_3_gjahr2-fipos.
1982
1983       IF sy-subrc EQ 0.
1984
1985         wa_tab_disp3-wljhr_6 = wa_g_3_gjahr2-wljhr. " Current Budget
1986
1987         LOOP AT ist_g_3_gjahr1 INTO wa_g_3_gjahr1
1988                   WHERE fictr EQ wa_g_3_gjahr2-fictr
1989                   AND fipos EQ  wa_g_3_gjahr2-fipos.
1990
1991           CASE wa_g_3_gjahr1-vorga.
1992
1993             WHEN 'KBUD'.
1994               wa_tab_disp3-wljhr_5 = wa_g_3_gjahr1-wljhr.
1995
1996           ENDCASE.
1997
1998         ENDLOOP.
1999         MODIFY ist_tab_disp3 FROM wa_tab_disp3 INDEX sy-tabix.
2000         CLEAR wa_g_3_gjahr1.
2001         CLEAR wa_tab_disp3.
2002
2003       ELSE.
2004
2005         wa_tab_disp3-fictr = wa_g_3_gjahr2-fictr. " Fund center
2006         wa_tab_disp3-cname = wa_g_3_gjahr2-cname. " Fund center text
2007         wa_tab_disp3-fipos = wa_g_3_gjahr2-fipos. " Comm Item
2008         wa_tab_disp3-pname = wa_g_3_gjahr2-pname. " Comm Item text
2009         wa_tab_disp3-wljhr_5 = wa_g_3_gjahr2-wljhr. " Current Budget
2010
2011         LOOP AT ist_g_3_gjahr1 INTO wa_g_3_gjahr1
2012                   WHERE fictr EQ wa_g_3_gjahr2-fictr
2013                   AND fipos EQ  wa_g_3_gjahr2-fipos.
2014
2015           CASE wa_g_3_gjahr1-vorga.
2016
2017             WHEN 'KBUD'.
2018               wa_tab_disp3-wljhr_6 = wa_g_3_gjahr1-wljhr.
2019
2020           ENDCASE.
2021
2022         ENDLOOP.
2023         APPEND wa_tab_disp3 TO ist_tab_disp3.
2024         CLEAR wa_g_3_gjahr1.
2025         CLEAR wa_tab_disp3.
2026       ENDIF.
2027
2028     ENDLOOP.
2029
2030   ENDFORM.                    " build_disp_table
2031
2032   *&---------------------------------------------------------------------*
2033   *&      Form  sum_item_level
2034   *&---------------------------------------------------------------------*
2035   FORM sum_item_level.
2036
2037   * - Sum for the current year
2038     LOOP AT ist_g_curr_gjahr INTO wa_g_curr_gjahr.
2039       MOVE-CORRESPONDING wa_g_curr_gjahr TO wa_g_curr_gjahr1.
2040       COLLECT wa_g_curr_gjahr1 INTO ist_g_curr_gjahr1.
2041     ENDLOOP.
2042
2043     CLEAR wa_g_curr_gjahr1.
2044
2045   * - Sum for second year
2046     LOOP AT ist_g_2_gjahr INTO wa_g_2_gjahr.
2047       MOVE-CORRESPONDING wa_g_2_gjahr TO wa_g_2_gjahr1.
2048       COLLECT wa_g_2_gjahr1 INTO ist_g_2_gjahr1.
2049     ENDLOOP.
2050
2051     CLEAR wa_g_2_gjahr1.
2052
2053   * - Sum for third year
2054     LOOP AT ist_g_3_gjahr INTO wa_g_3_gjahr.
2055       MOVE-CORRESPONDING wa_g_3_gjahr TO wa_g_3_gjahr1.
2056       COLLECT wa_g_3_gjahr1 INTO ist_g_3_gjahr1.
2057     ENDLOOP.
2058
2059     CLEAR wa_g_3_gjahr1.
2060
2061   ENDFORM.                    " sum_item_level
2062   *&---------------------------------------------------------------------*
2063   *&      Form  sum_gross_level
2064   *&---------------------------------------------------------------------*
2065   FORM sum_gross_level.
2066
2067   * - Sum for the current year
2068     LOOP AT ist_g_curr_gjahr1 INTO wa_g_curr_gjahr1.
2069       MOVE-CORRESPONDING wa_g_curr_gjahr1 TO wa_g_curr_gjahr2.
2070       COLLECT wa_g_curr_gjahr2 INTO ist_g_curr_gjahr2.
2071     ENDLOOP.
2072
2073     CLEAR wa_g_curr_gjahr2.
2074
2075   * - Sum for second year
2076     LOOP AT ist_g_2_gjahr1 INTO wa_g_2_gjahr1.
2077       MOVE-CORRESPONDING wa_g_2_gjahr1 TO wa_g_2_gjahr2.
2078       COLLECT wa_g_2_gjahr2 INTO ist_g_2_gjahr2.
2079     ENDLOOP.
2080
2081     CLEAR wa_g_2_gjahr2.
2082
2083   * - Sum for third year
2084     LOOP AT ist_g_3_gjahr1 INTO wa_g_3_gjahr1.
2085       MOVE-CORRESPONDING wa_g_3_gjahr1 TO wa_g_3_gjahr2.
2086       COLLECT wa_g_3_gjahr2 INTO ist_g_3_gjahr2.
2087     ENDLOOP.
2088
2089     CLEAR wa_g_3_gjahr2.
2090
2091   ENDFORM.                    " sum_gross_level
2092
2093   ************************************************************************
*--- End of ZFM_RFFMEP1BX_FOR3YEARS_CALL - 2093 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CRSDS                                   Level 1    Page 2
Object           ZFM_RFFMEP1BX_FOR3YEARS_CALL              Lines 46
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:50
----------------------------------------------------------------------------------------------------
1      TYPE-POOL RSDS .
2      * Type definitions for FREE SELECTIONS
3
4      * WHERE-clauses ------------------------------------------------------ *
5      TYPES: RSDS_WHERE_TAB LIKE RSDSWHERE OCCURS 5.
6
7      TYPES: BEGIN OF RSDS_WHERE,
8               TABLENAME LIKE RSDSTABS-PRIM_TAB,
9               WHERE_TAB TYPE RSDS_WHERE_TAB,
10            END OF RSDS_WHERE.
11
12     TYPES: RSDS_TWHERE TYPE RSDS_WHERE OCCURS 5.
13
14     * Expressions Polish notation ---------------------------------------- *
15     TYPES: RSDS_EXPR_TAB LIKE RSDSEXPR OCCURS 10.
16
17     TYPES: BEGIN OF RSDS_EXPR,
18              TABLENAME LIKE RSDSTABS-PRIM_TAB,
19              EXPR_TAB TYPE RSDS_EXPR_TAB,
20            END OF RSDS_EXPR.
21
22     TYPES: RSDS_TEXPR  TYPE RSDS_EXPR  OCCURS 10.
23
24     * Selections as RANGES-tables ---------------------------------------- *
25     TYPES: RSDS_SELOPT_T LIKE RSDSSELOPT OCCURS 10.
26
27     TYPES: BEGIN OF RSDS_FRANGE,
28              FIELDNAME LIKE RSDSTABS-PRIM_FNAME,
29              SELOPT_T TYPE RSDS_SELOPT_T,
30            END OF RSDS_FRANGE.
31
32     TYPES: RSDS_FRANGE_T TYPE RSDS_FRANGE OCCURS 10.
33
34     TYPES: BEGIN OF RSDS_RANGE,
35              TABLENAME LIKE RSDSTABS-PRIM_TAB,
36              FRANGE_T TYPE RSDS_FRANGE_T,
37            END OF RSDS_RANGE.
38
39     TYPES: RSDS_TRANGE TYPE RSDS_RANGE OCCURS 10.
40
41
42     TYPES: BEGIN OF RSDS_TYPE,
43              CLAUSES TYPE RSDS_TWHERE,
44              TEXPR   TYPE RSDS_TEXPR,
45              TRANGE  TYPE RSDS_TRANGE,
46            END   OF RSDS_TYPE.
*--- End of %_CRSDS - 46 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CRSFS                                   Level 1    Page 3
Object           ZFM_RFFMEP1BX_FOR3YEARS_CALL              Lines 12
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:50
----------------------------------------------------------------------------------------------------
1      TYPE-POOL RSFS .
2
3      * Name of the TYPEs must never be changed!
4
5      * Fields to be selected per table
6      TYPES: BEGIN OF RSFS_TAB_FIELDS,
7               TABLENAME LIKE RSDSTABS-PRIM_TAB,
8               FIELDS LIKE RSFS_STRUC OCCURS 10,
9             END OF RSFS_TAB_FIELDS.
10
11     * Fields to be selected for all tables
12     TYPES: RSFS_FIELDS TYPE RSFS_TAB_FIELDS OCCURS 10.
*--- End of %_CRSFS - 12 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CSCHEK                                  Level 1    Page 4
Object           ZFM_RFFMEP1BX_FOR3YEARS_CALL              Lines 9
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:50
----------------------------------------------------------------------------------------------------
1      TYPE-POOL SCHEK .
2
3      TYPES: BEGIN OF SCHEK_CORR,
4               NUMBER    TYPE I,
5               KIND      TYPE C,
6               LINNO     TYPE I,
7               COLNO     TYPE I,
8               WORD(255) TYPE C,
9             END OF SCHEK_CORR.
*--- End of %_CSCHEK - 9 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CSDYDO                                  Level 1    Page 5
Object           ZFM_RFFMEP1BX_FOR3YEARS_CALL              Lines 93
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:50
----------------------------------------------------------------------------------------------------
1      TYPE-POOL sdydo .
2
3      TYPES: sdydo_html_line LIKE w3html.
4      TYPES: sdydo_html_table TYPE sdydo_html_line OCCURS 10.
5
6      TYPES: sdydo_element_name(100) TYPE c.
7      TYPES: sdydo_element_name_table TYPE sdydo_element_name OCCURS 5.
8      TYPES: sdydo_wrapped_element_name(120) TYPE c.
9      TYPES: sdydo_area_cursor(11) TYPE c.   " do not use any longer
10
11     TYPES: sdydo_c1(1) TYPE c.
12     TYPES: sdydo_flag(1) TYPE c.
13     TYPES: sdydo_c100(100) TYPE c.         "Texte, Bitmapbezeichnungen
14     TYPES: sdydo_value TYPE w3_qvalue.     " Query table, Value
15     TYPES: sdydo_attribute(50) TYPE c.
16     TYPES: sdydo_info(100) TYPE c.         " Link_info
17
18     TYPES: sdydo_text_element(255) TYPE c.
19     TYPES: sdydo_text_table TYPE sdydo_text_element OCCURS 5.
20
21     TYPES: sdydo_progid LIKE sy-repid.
22     TYPES: sdydo_dynnr LIKE sy-dynnr.
23
24     TYPES: sdydo_url(256) TYPE c.
25     TYPES: sdydo_key LIKE bapibds01-objkey." Objekt-ID in BDS
26     TYPES: BEGIN OF sdydo_picture,
27              object_id       TYPE sdydo_key,
28              object_internal TYPE string,
29              got_object      TYPE i,
30            END OF sdydo_picture.
31     TYPES: sdydo_picture_table TYPE sdydo_picture OCCURS 0.
32
33     TYPES: BEGIN OF sdydo_graphic,         " do not use any longer
34              object_id(100),               "Objekt-ID in SAP-Web-Repository
35              object_url(100),     "relative URL zum Adressieren des Objekts
36            END OF sdydo_graphic.
37     TYPES: sdydo_graphic_table TYPE sdydo_graphic OCCURS 3.     "do not use
38
39     TYPES: BEGIN OF sdydo_style_class,
40              property(50),
41              value(50),     "relative URL zum Adressieren des O
42            END OF sdydo_style_class.
43     TYPES: sdydo_style_table TYPE sdydo_style_class OCCURS 3 .
44
45     TYPES: sdydo_icon_info TYPE icon.
46
47     TYPES: sdydo_object_table TYPE REF TO object OCCURS 5.
48
49     types: begin of sdydo_col_style_tab_entry_type,
50              class type string,                    " style class
51              style type string,                    " style string
52              alignment type string,                " alignment string
53            end of sdydo_col_style_tab_entry_type.
54     types: sdydo_col_style_tab type sdydo_col_style_tab_entry_type occurs 5.
55
56     TYPES: BEGIN OF sdydo_option,
57              value TYPE sdydo_value,
58              text TYPE string,
59            END OF sdydo_option.
60     TYPES: sdydo_option_tab TYPE sdydo_option OCCURS 0.
61
62     TYPES: BEGIN OF sdydo_act_gui_properties,
63              fore_color  TYPE sdydo_attribute,     " text
64              back_color  TYPE sdydo_attribute,     " control background
65              col_key     TYPE sdydo_attribute,     " list col key
66              col_success TYPE sdydo_attribute,     " list col positive
67              col_warning TYPE sdydo_attribute,     " list col negative
68              fontsize    TYPE sdydo_attribute,
69              fontstyle   TYPE sdydo_attribute,
70            END OF sdydo_act_gui_properties.
71
72     TYPES: BEGIN OF sdydo_col_value,
73                id        TYPE i,
74                state     TYPE i,
75                value     TYPE i,
76                code      TYPE sdydo_attribute,
77            END OF sdydo_col_value.
78     TYPES: sdydo_col_value_tab TYPE sdydo_col_value OCCURS 0.
79
80     TYPES: BEGIN OF sdydo_table_span,
81                col_start_span TYPE i,
82                span_width     TYPE i,
83                span_type,
84            END OF sdydo_table_span.
85     TYPES: sdydo_table_span_tab TYPE sdydo_table_span OCCURS 0.
86
87     TYPES: BEGIN OF sdydo_image_name,
88                image_id    TYPE sdydo_key,
89                bds_class   TYPE sdydo_key,
90                image_name  TYPE string,
91            END OF sdydo_image_name.
92     TYPES: sdydo_image_names TYPE HASHED TABLE OF sdydo_image_name
93            WITH UNIQUE KEY image_id bds_class.
*--- End of %_CSDYDO - 93 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CSEEX                                   Level 1    Page 6
Object           ZFM_RFFMEP1BX_FOR3YEARS_CALL              Lines 608
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:50
----------------------------------------------------------------------------------------------------
1      TYPE-POOL seex.
2
3      TYPE-POOLS: swbm, sxrt, seop.
4
5      TYPES: seex_role_type(12),
6             seex_access_mode(10),
7             seex_action(1),
8             seex_status(5),
9             seex_fcode TYPE fcode,
10            seex_rcode TYPE fcode,
11            seex_symbol_type TYPE sxrt_symbol_type,
12            seex_sp_group(3),
13            seex_prefix(10),
14            seex_imp_mode TYPE seex_fcode,
15            seex_switch(1) TYPE c,
16            seex_control(10),
17            seex_boolean TYPE sxrt_boolean,
18            seex_search_modus(15),
19            seex_eq_class LIKE tadir-object,
20            seex_eutype LIKE euobj-id,
21            seex_cls_type(10),
22            seex_intf_correct_type LIKE sy-subrc.
23     TYPES: seex_implementation TYPE seop_source_string,
24            BEGIN OF seex_method_implementation,
25              methodname TYPE seocmpname,
26              source TYPE seop_source_string,
27            END OF seex_method_implementation,
28            seex_class_implementation
29                  TYPE seex_method_implementation OCCURS 0.
30     TYPES: BEGIN OF seex_shlp_type,
31             name LIKE dd32p-shlpname,
32             field LIKE dd32p-fieldname,
33            END OF seex_shlp_type.
34     TYPES: BEGIN OF seex_fix_val_type,
35              existent TYPE seex_boolean,
36              values LIKE dd07v OCCURS 0,
37            END OF seex_fix_val_type.
38     TYPES: BEGIN OF seex_dbtable_type,
39              name TYPE entitytab,
40              field LIKE dd03p-fieldname,
41              offset TYPE doffset,
42              del_cl TYPE contflag,
43              client_dep TYPE seex_boolean,
44            END OF seex_dbtable_type.
45     TYPES: BEGIN OF seex_texts_type,
46              table TYPE tabname,
47              del_cl TYPE contflag,
48              client_dep TYPE seex_boolean,
49              field TYPE fieldname,
50              offset TYPE doffset,
51              leng TYPE ddleng,
52              lang_field TYPE fieldname,
53              lang_offset TYPE doffset,
54              lang_leng TYPE ddleng,
55              text_field TYPE fieldname,
56              text_offset TYPE doffset,
57              text_leng TYPE ddleng,
58              text_lower TYPE lowercase,
59              offset_alv TYPE doffset,
60            END OF seex_texts_type.
61     TYPES: BEGIN OF seex_filter_state_type,
62              field_desc TYPE scrtext_l,
63              leng TYPE ddleng,
64              shlp TYPE seex_shlp_type,
65              dbtab TYPE seex_dbtable_type,
66              fixed_values TYPE seex_fix_val_type,
67              texts TYPE seex_texts_type,
68            END OF seex_filter_state_type.
69     TYPES: BEGIN OF seex_filter_struc_type,
70              rollname TYPE rollname,
71              offset TYPE doffset,
72              fieldname TYPE fieldname,
73              fieldname_alv TYPE fieldname,
74              datatype TYPE dynptype,
75              atts TYPE seex_filter_state_type,
76            END OF seex_filter_struc_type.
77     TYPES seex_filter_struc_tab_type TYPE STANDARD TABLE OF
78                 seex_filter_struc_type.
79     *TYPES: BEGIN OF  seex_coco_runtime_struct,
80     *         coco_outer LIKE sxc_coco-coco_outer,
81     *         node_id    LIKE sxc_coco-node_id,
82     *         filter     TYPE filtname,
83     *       END OF  seex_coco_runtime_struct,
84     *       seex_coco_runtime_table_type TYPE
85     *             HASHED TABLE OF seex_coco_runtime_struct
86     *             WITH UNIQUE KEY coco_outer node_id.
87     TYPES seex_text_table TYPE STANDARD TABLE OF flt_text.
88     TYPES: BEGIN OF seex_itab_type ,
89              inhalt(60),
90            END OF seex_itab_type.
91     TYPES: BEGIN OF seex_method_parameter_type,
92              sconame    LIKE vseoparam-sconame,
93              cmptype    LIKE vseoparam-cmptype,
94              pardecltyp LIKE vseoparam-pardecltyp,
95            END OF seex_method_parameter_type.
96     TYPES: BEGIN OF seex_method_exception_type,
97              sconame    LIKE vseoexcep-sconame,
98            END OF seex_method_exception_type.
99     TYPES: BEGIN OF seex_method_head_type,
100             cmpname LIKE vseomethod-cmpname,
101             mtddecltyp LIKE vseomethod-mtddecltyp,
102           END OF seex_method_head_type.
103    TYPES: BEGIN OF seex_interface_method_type,
104             header TYPE seex_method_head_type,
105             parameters TYPE seex_method_parameter_type OCCURS 0,
106             exceptions TYPE seex_method_exception_type OCCURS 0,
107           END OF seex_interface_method_type.
108    TYPES: BEGIN OF seex_interface_head_type,
109             clsname LIKE vseointerf-clsname,
110           END OF seex_interface_head_type.
111    TYPES: BEGIN OF seex_interface_type,
112             header TYPE seex_interface_head_type,
113             methods TYPE seex_interface_method_type OCCURS 0,
114             def_clname TYPE seoclsname,
115           END OF seex_interface_type.
116    TYPES: BEGIN OF seex_exit_list_type,
117              imp_name LIKE sxc_exit-imp_name,
118              flt_val  LIKE sxc_exit-flt_val,
119              text     LIKE sxc_attrt-text,
120              active   LIKE sxc_attr-active,
121              layer    like sxc_attr-layer,
122           END OF seex_exit_list_type,
123           BEGIN OF seex_attr_list_type,
124             exit_name LIKE sxs_attr-exit_name,
125             flt_type  LIKE sxs_attr-flt_type,
126             mltp_use  LIKE sxs_attr-mltp_use,
127             text      LIKE sxs_attrt-text,
128           END OF seex_attr_list_type,
129           BEGIN OF seex_prog_list_type,
130             name LIKE d010sinf-prog,
131             text LIKE trdirt-text,
132           END OF seex_prog_list_type,
133           BEGIN OF seex_dynr_list_type,
134             dnum LIKE d020s-dnum,
135             dtxt LIKE d020t-dtxt,
136           END OF seex_dynr_list_type,
137           BEGIN OF seex_sscr_list_type,
138             name TYPE rpy_dycatt-name,
139           END OF seex_sscr_list_type,
140           BEGIN OF seex_intf_list_type,
141             clsname LIKE seoclass-clsname,
142             descript LIKE seoclasstx-descript,
143           END OF seex_intf_list_type.
144    TYPES: BEGIN OF seex_coco_badi_sav,
145             node_id   LIKE sxs_coco-node_id,
146             exit_name LIKE sxs_coco-exit_name,
147           END OF seex_coco_badi_sav,
148           seex_coco_badi_save TYPE STANDARD TABLE OF seex_coco_badi_sav
149               WITH KEY exit_name node_id.
150    TYPES: seex_exit_list_tab_type TYPE seex_exit_list_type OCCURS 0,
151           seex_attr_list_tab_type TYPE seex_attr_list_type OCCURS 0,
152           seex_prog_list_tab_type TYPE seex_prog_list_type OCCURS 0,
153           seex_dynr_list_tab_type TYPE seex_dynr_list_type OCCURS 0,
154           seex_sscr_list_tab_type TYPE seex_sscr_list_type OCCURS 0,
155           seex_intf_list_tab_type TYPE seex_intf_list_type OCCURS 0.
156    TYPES: seex_tcode TYPE sy-tcode.
157
158    TYPES: seex_clif_prefix TYPE seex_prefix,
159           seex_method_prefix TYPE seex_prefix.
160
161    TYPES: BEGIN OF seex_col_struct,
162             imp_name LIKE sxc_exit-imp_name,
163             flt_val LIKE sxc_exit-flt_val,
164           END OF seex_col_struct,
165           seex_col_table TYPE seex_col_struct OCCURS 0.
166    TYPES: seex_attr_struct LIKE sxs_attr,
167           seex_cls_struct LIKE v_ext_imp.
168
169    TYPES: BEGIN OF seex_obj_struct,
170             obj TYPE REF TO object,
171           END OF seex_obj_struct.
172    TYPES: seex_obj_tab TYPE seex_obj_struct OCCURS 0.
173    TYPES: BEGIN OF seex_mtd_struct,
174             metho_name LIKE rsexscrn-metho_name,
175             imp_switch  TYPE imp_switch,
176             metho_text TYPE seodescr,
177           END OF seex_mtd_struct.
178    TYPES seex_class_struct  LIKE sxc_class.
179    TYPES seex_inter_struct  LIKE sxs_inter.
180    TYPES seex_exit_struct   LIKE sxc_exit.
181    TYPES: BEGIN OF seex_fcode_struct,
182             exit_name LIKE v_c_fcode-exit_name,
183             gui_prog LIKE v_c_fcode-gui_prog,
184             gui_code LIKE v_c_fcode-gui_code,
185             sprsl LIKE v_c_fcode-sprsl,
186             gui_text LIKE v_c_fcode-gui_text,
187             menu_text LIKE v_c_fcode-menu_text,
188             icon_text LIKE v_c_fcode-icon_text,
189             quickinfo LIKE v_c_fcode-quickinfo,
190             imp_name LIKE v_c_fcode-imp_name,
191             icon_id LIKE v_c_fcode-icon_id,
192             icon_name LIKE v_c_fcode-icon_name,
193             text_type LIKE rsmpe_dfun-text_type,
194           END OF seex_fcode_struct.
195
196    TYPES seex_coco_struct TYPE str_coco.
197    TYPES seex_screen_struct LIKE v_c_scrn.
198    TYPES seex_table_struct TYPE str_table.
199    *TYPES: seex_ext_imp_struct LIKE v_ext_imp,
200    *       seex_ext_imp_tab TYPE seex_ext_imp_struct OCCURS 0.
201    TYPES: seex_ext_imp_struct TYPE sxrt_ext_imp_struct,
202           seex_ext_imp_tab TYPE sxrt_ext_imp_tab.
203    TYPES seex_exit_tab_struct TYPE sxrt_exit_tab_struct.
204    *TYPES: BEGIN OF seex_exit_tab_struct,
205    *         inter_name  LIKE v_ext_imp-inter_name,
206    *         flt_val     LIKE v_ext_imp-flt_val,
207    *         imp_class   LIKE v_ext_imp-imp_class,
208    *         active      LIKE v_ext_imp-active,
209    *         obj         TYPE REF TO object,
210    *       END OF seex_exit_tab_struct.
211    TYPES seex_exit_tab TYPE sxrt_exit_tab.
212    *TYPES: seex_exit_tab TYPE seex_exit_tab_struct OCCURS 0.
213    TYPES: BEGIN OF seex_interface,
214             clsname TYPE seoclsname,
215             refclsname TYPE seoclsname,
216           END OF seex_interface,
217           seex_interface_table TYPE STANDARD TABLE OF seex_interface.
218
219    TYPES seex_filter_struct TYPE sxrt_filter_struct.
220    *TYPES: BEGIN OF seex_filter_struct,
221    *         flt_val LIKE rsexscrn-flt_val,
222    *         fltval_txt TYPE flt_text,
223    *       END OF seex_filter_struct.
224
225    TYPES: seex_class_table   TYPE seex_class_struct  OCCURS 0,
226           seex_inter_table   TYPE seex_inter_struct  OCCURS 0,
227           seex_exit_table    TYPE seex_exit_struct   OCCURS 0,
228           seex_mtd_table     TYPE seex_mtd_struct    OCCURS 0,
229           seex_fcode_table   TYPE seex_fcode_struct  OCCURS 0,
230           seex_coco_table    TYPE seex_coco_struct   OCCURS 0,
231           seex_filter_table  TYPE sxrt_filter_table,
232           seex_screen_table  TYPE seex_screen_struct OCCURS 0,
233           seex_table_table   TYPE seex_table_struct  OCCURS 0.
234
235    TYPES: seex_comp_exit LIKE sxc_exit,
236           seex_comp_exits TYPE seex_comp_exit OCCURS 0.
237
238    TYPES: BEGIN OF seex_ccp_mtd_struc,
239             selline_1 LIKE sy-tabix,
240             selline_2 LIKE sy-tabix,
241             item_count LIKE sy-tabix,
242             marked_lines TYPE seex_mtd_table,
243           END OF seex_ccp_mtd_struc.
244
245    TYPES: BEGIN OF seex_ccp_filter_struc,
246             selline_1 LIKE sy-tabix,
247             selline_2 LIKE sy-tabix,
248             item_count LIKE sy-tabix,
249             marked_lines TYPE seex_filter_table,
250           END OF seex_ccp_filter_struc.
251
252    TYPES: BEGIN OF seex_ccp_fcode_struc,
253             selline_1 LIKE sy-tabix,
254             selline_2 LIKE sy-tabix,
255             item_count LIKE sy-tabix,
256             marked_lines TYPE seex_fcode_table,
257           END OF seex_ccp_fcode_struc.
258
259    TYPES: BEGIN OF seex_ccp_coco_struc,
260             selline_1 LIKE sy-tabix,
261             selline_2 LIKE sy-tabix,
262             item_count LIKE sy-tabix,
263             marked_lines TYPE seex_coco_table,
264           END OF seex_ccp_coco_struc.
265
266    TYPES: BEGIN OF seex_ccp_table_struc,
267             selline_1 LIKE sy-tabix,
268             selline_2 LIKE sy-tabix,
269             item_count LIKE sy-tabix,
270             marked_lines TYPE seex_table_table,
271           END OF seex_ccp_table_struc.
272
273    TYPES: BEGIN OF seex_generic_entry,
274              data(350),
275           END OF seex_generic_entry,
276           seex_component_table TYPE STANDARD TABLE OF seex_generic_entry.
277    TYPES: BEGIN OF seex_ccp_struc,
278             selline_1 LIKE sy-tabix,
279             selline_2 LIKE sy-tabix,
280             item_count LIKE sy-tabix,
281           END OF seex_ccp_struc.
282
283    * Strukturen für den aktuellen Transaktions-Status:
284    * Ist eine Exit-/Handler-Klasse selektiert/geladen/gesichert
285    TYPES: BEGIN OF seex_class_status,
286             selected TYPE seex_boolean,
287             load     TYPE seex_boolean,
288             saved    TYPE seex_boolean,
289           END OF seex_class_status.
290    TYPES: BEGIN OF seex_inactive_tabstrip,
291             dynr(30) TYPE c,
292           END OF seex_inactive_tabstrip,
293           seex_inactive_tabstrips TYPE seex_inactive_tabstrip OCCURS 0.
294    TYPES: BEGIN OF seex_imp_class_status,
295             imp              TYPE seex_class_status,
296             exit             TYPE seex_class_status,
297             activated        TYPE activity,
298             inactive_tabstrips TYPE seex_inactive_tabstrips,
299           END OF seex_imp_class_status.
300
301    TYPES: seex_tab_type TYPE tabname.
302    CONSTANTS: seex_intf_correct_no_correct TYPE seex_intf_correct_type
303               VALUE 0,
304               seex_intf_correct_exp_params TYPE seex_intf_correct_type
305               VALUE 1,
306               seex_intf_correct_write_attrs TYPE seex_intf_correct_type
307               VALUE 2,
308               seex_intf_correct_nest_interf TYPE seex_intf_correct_type
309               VALUE 3.
310    CONSTANTS: seex_look_for_imp
311                                  TYPE seex_search_modus VALUE 'SEARCH_IMP',
312               seex_look_for_exit
313                                  TYPE seex_search_modus VALUE 'SEARCH_EXT',
314               seex_look_for_scr_calling_prog
315                                  TYPE seex_search_modus VALUE 'SEARCH_CPR',
316               seex_look_for_scr_called_prog
317                                  TYPE seex_search_modus VALUE 'SEARCH_DPR',
318               seex_look_for_calling_dynr
319                                  TYPE seex_search_modus VALUE 'SEARCH_CDY',
320               seex_look_for_called_dynr
321                                  TYPE seex_search_modus VALUE 'SEARCH_DDY',
322               seex_look_for_subscreen
323                                  TYPE seex_search_modus VALUE 'SEARCH_SSC',
324              seex_look_for_include_table
325                                  TYPE seex_search_modus VALUE 'SEARCH_TAB',
326               seex_look_for_gui_program
327                                  TYPE seex_search_modus VALUE 'SEARCH_GPR',
328               seex_look_for_gui_fcode
329                                  TYPE seex_search_modus VALUE 'SEARCH_FCD',
330               seex_look_for_inter
331                                  TYPE seex_search_modus VALUE 'SEARCH_INT'.
332
333    CONSTANTS: seex_symbol_wildcard  TYPE seex_symbol_type VALUE '*',
334               seex_symbol_separator TYPE seex_symbol_type VALUE '|'.
335
336    CONSTANTS: seex_control_methods TYPE seex_control VALUE 'method',
337               seex_control_screens TYPE seex_control VALUE 'screen',
338               seex_control_fcodes TYPE seex_control VALUE 'fcode',
339               seex_control_tables TYPE seex_control VALUE 'table',
340               seex_control_filters TYPE seex_control VALUE 'filter'.
341
342    CONSTANTS: seex_true  TYPE seex_boolean VALUE 'X',
343               seex_false TYPE seex_boolean VALUE space,
344               seex_off   TYPE seex_switch  VALUE '0',
345               seex_on    TYPE seex_switch  VALUE '1',
346               seex_conflict          TYPE seex_switch VALUE 'C',
347               seex_no_conflict       TYPE seex_switch VALUE 'N',
348               seex_ddic_table        TYPE char4 VALUE 'TABL',
349               seex_ddic_searchhelp   TYPE char4 VALUE 'SHLP',
350               seex_ddic_domain       TYPE char4 VALUE 'DOMA',
351               seex_ddic_data_element TYPE char4 VALUE 'DTEL'.
352
353    CONSTANTS: seex_sorter_badi TYPE exit_def      VALUE 'BADI_LAYER',
354               seex_cust_sort_imp type exit_imp
355                                              value 'CUSTOMIZE_LAYER_IMP',
356               seex_simple_sort_imp type exit_imp
357                                              value 'SIMPLE_LAYER_IMP',
358               seex_par_name_flt_val(10)      VALUE 'FLT_VAL',
359               seex_par_name_flt_type(10)     VALUE 'FLT_TYPE',
360               seex_att_name_flt_pattern(12)  VALUE 'FLT_PATTERN',
361               seex_att_name_version(12)      VALUE 'VERSION',
362               seex_att_name_badi_table(10)   VALUE 'BADI_TABLE',
363               seex_att_name_flt_cache(10)    VALUE 'FLT_CACHE',
364               seex_att_type_badi_table TYPE rs38l_typ
365                                              VALUE 'SXRT_EXIT_TAB',
366               seex_att_type_flt_cache  TYPE rs38l_typ
367                                              VALUE 'SXRT_FLT_CACHE_TAB',
368               seex_att_type_flt_pattern TYPE rs38l_typ
369                                              VALUE 'FILTNAME',
370               seex_att_name_def_obj(10)      VALUE 'DEF_OBJ',
371               seex_att_name_prefix_inst(10)  VALUE 'INSTANCE_',
372               seex_att_name_prefix_stat(10)  VALUE 'STATIC_',
373               seex_att_name_dynpro_instance(20) VALUE 'DYNPRO_INSTANCE',
374               seex_att_name_singleton(20) VALUE 'SINGLETON',
375               seex_scr_num(10)               VALUE 'SCRADNUM',
376               seex_dynpro_structure(10)      VALUE 'RSEXSCRN',
377               seex_search_help_filters
378                                TYPE shlpname VALUE 'SSHLP_FLT',
379               seex_meth_name_dynpro_put(30)  VALUE 'PUT_DATA_TO_SCREEN',
380               seex_meth_name_dynpro_get(30)  VALUE 'GET_DATA_FROM_SCREEN',
381               seex_meth_name_set_change(30)  VALUE 'SET_LAYER_CHANGEABLE',
382               seex_meth_name_is_change(30)   VALUE 'IS_LAYER_CHANGEABLE',
383               seex_meth_name_set_instance(30) VALUE
384                             'SET_INSTANCE_FOR_SUBSCREEN',
385               seex_meth_name_get_instance(30) VALUE
386                             'GET_INSTANCE_FOR_SUBSCREEN'.
387
388    CONSTANTS: seex_nor_meth_prefix   TYPE sxrt_method_prefix VALUE
389               sxrt_nor_meth_prefix,
390               seex_exm_meth_prefix   TYPE sxrt_method_prefix VALUE
391               sxrt_exm_meth_prefix,
392               seex_def_meth_prefix   TYPE sxrt_method_prefix VALUE
393               sxrt_def_meth_prefix,
394               seex_exit_class_prefix TYPE sxrt_clif_prefix VALUE
395               sxrt_exit_class_prefix,
396               seex_exit_intf_prefix  TYPE sxrt_clif_prefix VALUE
397               sxrt_exit_intf_prefix,
398               seex_coco_class_prefix TYPE sxrt_clif_prefix VALUE
399               sxrt_coco_class_prefix,
400               seex_imp_class_prefix  TYPE sxrt_clif_prefix VALUE
401               sxrt_imp_class_prefix,
402               seex_def_imp_class_prefix  TYPE sxrt_clif_prefix VALUE
403               sxrt_def_imp_class_prefix,
404               seex_exm_imp_class_prefix  TYPE sxrt_clif_prefix VALUE
405               sxrt_exm_imp_class_prefix.
406
407    CONSTANTS: seex_mode_exit    LIKE rsex_navi-mode VALUE 'E',
408               seex_mode_insert  LIKE rsex_navi-mode VALUE 'I',
409               seex_mode_display LIKE rsex_navi-mode VALUE 'D',
410               seex_mode_modify  LIKE rsex_navi-mode VALUE 'M'.
411    CONSTANTS: seex_cls_type_default TYPE seex_cls_type VALUE 'DEF',
412               seex_cls_type_example TYPE seex_cls_type VALUE 'EXM',
413               seex_cls_type_coco    TYPE seex_cls_type VALUE 'COC',
414               seex_cls_type_normal  TYPE seex_cls_type VALUE 'IMP'.
415    CONSTANTS: seex_okay TYPE seex_rcode VALUE 'OKAY',
416               seex_cancel TYPE seex_rcode VALUE swbm_c_fc_cancel,
417               seex_exit   TYPE seex_rcode VALUE 'EXIT',
418               seex_rcode_add TYPE seex_rcode VALUE 'Add',
419               seex_rcode_no  TYPE seex_rcode VALUE 'No'.
420    CONSTANTS: seex_imp_mode_show TYPE seex_imp_mode VALUE
421                      'SHOW_INTERFACE',
422               seex_imp_mode_implement TYPE seex_imp_mode VALUE
423                      'IMPLEMENT_INTERFACE'.
424    CONSTANTS:
425         seex_insens_for_imp_read_mode  TYPE seex_sp_group VALUE 'IIR',
426         seex_insens_for_implementer    TYPE seex_sp_group VALUE 'IMI',
427         seex_sensitive_for_implementer TYPE seex_sp_group VALUE 'IMC',
428         seex_invisible_for_implementer TYPE seex_sp_group VALUE 'IMU',
429         seex_inv_for_imp_filter_dep    TYPE seex_sp_group VALUE 'IFU',
430         seex_inv_for_imp_and_def_inde  TYPE seex_sp_group VALUE 'IDI',
431         seex_invisible_for_imp_inact   TYPE seex_sp_group VALUE 'IMA',
432         seex_invisible_for_definer     TYPE seex_sp_group VALUE 'DEI',
433         seex_insens_when_implemented   TYPE seex_sp_group VALUE 'IWI',
434         seex_sensitive_for_definer     TYPE seex_sp_group VALUE 'DEC',
435         seex_implementation_mode_read  TYPE seex_sp_group VALUE 'IMR'.
436
437    CONSTANTS: seex_pgmid           LIKE tadir-pgmid      VALUE 'R3TR',
438               seex_def_ob_class    TYPE seex_eq_class    VALUE 'SXSD',
439               seex_imp_ob_class    TYPE seex_eq_class    VALUE 'SXCI',
440               seex_def_eu_type     TYPE seex_eutype      VALUE 'XD',
441               seex_imp_eu_type     TYPE seex_eutype      VALUE 'XI',
442               seex_docu_class_simg LIKE tdcld-dokclass   VALUE 'SIMG',
443               seex_docu_id_bi      LIKE dokhl-id         VALUE 'BI',
444               seex_docu_id_hy      LIKE dokhl-id         VALUE 'HY',
445               seex_docu_typ        LIKE dokhl-typ        VALUE 'E',
446               seex_imp_docu_template LIKE dokhl-object   VALUE
447                                                          'BADI_IMP_TEMP',
448               seex_access_modify   TYPE seex_access_mode VALUE 'MODIFY',
449               seex_access_show     TYPE seex_access_mode VALUE 'SHOW',
450               seex_access_insert   TYPE seex_access_mode VALUE 'INSERT',
451               seex_access_free     TYPE seex_access_mode VALUE 'FREE',
452               seex_access_delete   TYPE seex_access_mode VALUE 'DELETE',
453               seex_access_check    TYPE seex_access_mode VALUE 'CHECK'.
454
455    CONSTANTS:
456     seex_stat_read     TYPE seex_status    VALUE 'Read',       "#EC NOTEXT
457     seex_stat_write    TYPE seex_status    VALUE 'Write',      "#EC NOTEXT
458     seex_role_def      TYPE seex_role_type VALUE 'Definer',    "#EC NOTEXT
459     seex_role_imp      TYPE seex_role_type VALUE 'Implementer',"#EC NOTEXT
460     seex_action_insert TYPE seex_action    VALUE 'I',          "#EC NOTEXT
461     seex_action_delete TYPE seex_action    VALUE 'D'.          "#EC NOTEXT
462
463    * Konstanten für Dynpronummern
464    * ab Nummer 150: Subscreens
465    CONSTANTS: seex_dynnr_start_exit           LIKE sy-dynnr VALUE '0100',
466               seex_dynnr_start_imp            LIKE sy-dynnr VALUE '0120',
467               seex_dyn_popup_to_provide_imp   LIKE sy-dynnr VALUE '0115',
468               seex_dyn_popup_to_provide_doku  LIKE sy-dynnr VALUE '0105',
469               seex_dyn_popup_for_new_imp      LIKE sy-dynnr VALUE '0116',
470               seex_dyn_popup_for_new_imp_iso  LIKE sy-dynnr VALUE '0117',
471               seex_dyn_popup_to_provide_exit  LIKE sy-dynnr VALUE '0125',
472               seex_dyn_popup_for_new_exit     LIKE sy-dynnr VALUE '0126',
473               seex_dyn_popup_for_overview     LIKE sy-dynnr VALUE '0130',
474               seex_dyn_popup_for_colors       LIKE sy-dynnr VALUE '0131',
475               seex_dyn_popup_for_badi_name    LIKE sy-dynnr VALUE '0140',
476               seex_dyn_popup_for_imp_name     LIKE sy-dynnr VALUE '0145',
477               seex_dyn_popup_for_interface    LIKE sy-dynnr VALUE '0146',
478               seex_dyn_popup_for_class        LIKE sy-dynnr VALUE '0147',
479               seex_dyn_popup_for_defexm_clas  LIKE sy-dynnr VALUE '0148',
480               seex_dynnr_tabstrip             LIKE sy-dynnr VALUE '0150',
481               seex_dynnr_head                 LIKE sy-dynnr VALUE '0160',
482               seex_dyn_popup_filter           LIKE sy-dynnr VALUE '0161',
483               seex_dynnr_methods              LIKE sy-dynnr VALUE '0170',
484               seex_dynnr_docu                 LIKE sy-dynnr VALUE '0190',
485               seex_dynnr_comp_coco            LIKE sy-dynnr VALUE '0180',
486               seex_dynnr_comp_sscr            LIKE sy-dynnr VALUE '0200',
487               seex_dyn_popup_scr_a            LIKE sy-dynnr VALUE '0201',
488               seex_dyn_popup_scr_p            LIKE sy-dynnr VALUE '0202',
489               seex_dynnr_comp_fcod            LIKE sy-dynnr VALUE '0210',
490               seex_dyn_popup_fcod             LIKE sy-dynnr VALUE '0211',
491               seex_dynnr_comp_inta            LIKE sy-dynnr VALUE '0220',
492               seex_dynn_popup_inta            LIKE sy-dynnr VALUE '0221',
493               seex_dyn_popup_coco             LIKE sy-dynnr VALUE '0231',
494               seex_dynnr_fkt_codes            LIKE sy-dynnr VALUE '0300',
495               seex_dynnr_sorting              LIKE sy-dynnr VALUE '0400'.
496
497    * Konstanten für FCodes
498    CONSTANTS:seex_reference_list    TYPE seex_fcode VALUE
499                                             swbm_c_fc_where_used_list,
500              seex_color_list        TYPE seex_fcode VALUE 'COLS',
501              seex_mltp_akt_imps     TYPE seex_fcode VALUE 'MLTP_AKT',
502              seex_mltp_int_in_defs  TYPE seex_fcode VALUE 'MLTP_INT',
503              seex_mltp_fun_in_defs  TYPE seex_fcode VALUE 'MLTP_FUN',
504              seex_delete            TYPE seex_fcode VALUE swbm_c_fc_delete,
505              seex_test              TYPE seex_fcode VALUE 'TEST',
506              seex_goto_back         TYPE seex_fcode VALUE swbm_c_fc_back,
507              seex_goto_exit         TYPE seex_fcode VALUE swbm_c_fc_end,
508              seex_goto_canc         TYPE seex_fcode VALUE swbm_c_fc_cancel,
509              seex_goto_togg         TYPE seex_fcode VALUE
510                                              swbm_c_fc_disp_edit_toggle,
511              seex_goto_add          TYPE seex_fcode VALUE 'ADD',
512              seex_goto_upda         TYPE seex_fcode VALUE 'UPDA',
513              seex_goto_show         TYPE seex_fcode VALUE 'SHOW',
514              seex_goto_test         TYPE seex_fcode VALUE 'TEST',
515              seex_migrate           TYPE seex_fcode VALUE 'BADI_MIG',
516              seex_goto_save         TYPE seex_fcode VALUE swbm_c_fc_save,
517              seex_goto_imp_nor_code TYPE seex_fcode VALUE 'GOTO_IMP',
518              seex_def_imp_create    TYPE seex_fcode VALUE 'DEF_CREA',
519              seex_def_imp_show      TYPE seex_fcode VALUE 'DEF_SHOW',
520              seex_def_imp_update    TYPE seex_fcode VALUE 'DEF_UPDA',
521              seex_def_imp_delete    TYPE seex_fcode VALUE 'DEF_DELE',
522              seex_exm_imp_create    TYPE seex_fcode VALUE 'EXM_CREA',
523              seex_exm_imp_show      TYPE seex_fcode VALUE 'EXM_SHOW',
524              seex_exm_imp_update    TYPE seex_fcode VALUE 'EXM_UPDA',
525              seex_exm_imp_delete    TYPE seex_fcode VALUE 'EXM_DELE',
526              seex_exm_imp_take      TYPE seex_fcode VALUE 'EXM_TAKE',
527              seex_goto_interface    TYPE seex_fcode VALUE 'GOTO_INTF',
528              seex_goto_imp_class    TYPE seex_fcode VALUE 'GOTO_IMCL',
529              seex_goto_parameters   TYPE seex_fcode VALUE 'GOTO_PARA',
530              seex_goto_dynpro       TYPE seex_fcode VALUE 'GOTO_DYN',
531              seex_goto_gui_prog     TYPE seex_fcode VALUE 'GOTO_GUIP',
532              seex_goto_control_comp TYPE seex_fcode VALUE 'GOTO_COMP',
533              seex_goto_data_element TYPE seex_fcode VALUE 'GOTO_DTEL',
534              seex_goto_devclass     TYPE seex_fcode VALUE 'GOTO_DEVC',
535              seex_goto_inc_struct   TYPE seex_fcode VALUE 'GOTO_INC',
536              seex_goto_app_struct   TYPE seex_fcode VALUE 'GOTO_APP',
537              seex_goto_task         TYPE seex_fcode VALUE 'TASK',
538              seex_goto_tadir        TYPE seex_fcode VALUE 'TADIR',
539              seex_history           TYPE seex_fcode VALUE 'HIST',
540              seex_activate          TYPE seex_fcode VALUE
541                                              swbm_c_fc_activate,
542              seex_deactivate        TYPE seu_action VALUE 'DEACTIVATE',
543              seex_check             TYPE seex_fcode VALUE swbm_c_fc_check,
544              seex_line_deletion     TYPE seex_fcode VALUE 'LIDE',
545              seex_line_renaming     TYPE seex_fcode VALUE 'LIRENA',
546              seex_line_insertion    TYPE seex_fcode VALUE 'LIIN',
547              seex_line_cut          TYPE seex_fcode VALUE 'LICUT',
548              seex_line_cut_all      TYPE seex_fcode VALUE 'LICUTALL',
549              seex_line_copy         TYPE seex_fcode VALUE 'LICOPY',
550              seex_line_mark         TYPE seex_fcode VALUE 'LIMARK',
551              seex_line_paste        TYPE seex_fcode VALUE 'LIPASTE',
552              seex_line_refresh      TYPE seex_fcode VALUE 'REFRESH',
553              seex_demark            TYPE seex_fcode VALUE 'DEMARK',
554              seex_implement_inter   TYPE seex_fcode VALUE
555                                              seex_imp_mode_implement,
556              seex_show_inter        TYPE seex_fcode VALUE
557                                              seex_imp_mode_show,
558              seex_implement_show    TYPE seex_fcode VALUE 'IMP_SHOW',
559              seex_implement_upda    TYPE seex_fcode VALUE 'IMP_UPDA',
560              seex_implement_add     TYPE seex_fcode VALUE 'IMP_ADD',
561              seex_implement_delete  TYPE seex_fcode VALUE 'IMP_DELETE',
562              seex_implement_overview TYPE seex_fcode VALUE 'IMP_OVER',
563              seex_implement_show_for_badi
564                                     TYPE seex_fcode VALUE 'IMP_SHOWB',
565              seex_implement_upda_for_badi
566                                     TYPE seex_fcode VALUE 'IMP_UPDAB',
567              seex_implement_add_for_badi
568                                     TYPE seex_fcode VALUE 'IMP_ADDB',
569              seex_goto_text         TYPE seex_fcode VALUE 'TEXT',
570              seex_goto_okay         TYPE seex_fcode VALUE 'OKAY',
571              seex_class_generate    TYPE seex_fcode VALUE 'CLASS_GEN',
572              seex_sort              TYPE seex_fcode VALUE 'SORT',
573              seex_double            TYPE seex_fcode VALUE 'DOUBLE',
574              seex_copy              TYPE seex_fcode VALUE swbm_c_fc_copy,
575              seex_implement_copy    TYPE seex_fcode VALUE 'IMP_COPY',
576              seex_rename            TYPE seex_fcode VALUE swbm_c_fc_rename,
577              seex_implement_rename  TYPE seex_fcode VALUE 'IMP_RENAME',
578              seex_another_badi      TYPE seex_fcode VALUE 'ANOT',
579              seex_another_imp       TYPE seex_fcode VALUE 'ANOT_IMP',
580              seex_components        TYPE seex_fcode VALUE 'COMPS',
581              seex_implement_comps   TYPE seex_fcode VALUE 'IMP_COMPS',
582              seex_docu              TYPE seex_fcode VALUE 'DEF_DOCU',
583              seex_exit_docu_show    TYPE seex_fcode VALUE 'DOCU_EXIT_SHOW',
584              seex_exit_docu_edit    TYPE seex_fcode VALUE 'DOCU_EXIT_EDIT',
585              seex_imp_docu_show     TYPE seex_fcode VALUE 'DOCU_IMP_SHOW',
586              seex_imp_docu_edit     TYPE seex_fcode VALUE 'DOCU_IMP_EDIT',
587              seex_implement_docu    TYPE seex_fcode VALUE 'IMP_DOCU',
588              seex_badi_check        TYPE seex_fcode VALUE 'WB_CHECK',
589              seex_implement_check   TYPE seex_fcode VALUE 'IMP_CHECK',
590              seex_tab_strip_head      TYPE seex_fcode VALUE 'GOTO_HEAD',
591              seex_tab_strip_class     TYPE seex_fcode VALUE 'GOTO_CLASS',
592              seex_tab_strip_comp_sscr TYPE seex_fcode VALUE 'GOTO_SSCR',
593              seex_tab_strip_comp_fcod TYPE seex_fcode VALUE 'GOTO_FCOD',
594              seex_tab_strip_comp_coco TYPE seex_fcode VALUE 'GOTO_COCO',
595              seex_tab_strip_comp_inta TYPE seex_fcode VALUE 'GOTO_INTA'.
596
597    * Konstanten für Tab-Strip-Reiter-Namen
598    CONSTANTS:
599       seex_tab_strip_name_mtd(25)    TYPE c VALUE 'EXIT_TAB_STRIP_CLASS',
600       seex_tab_strip_name_screen(25) TYPE c VALUE 'EXIT_TAB_STRIP_CO_SSCR',
601       seex_tab_strip_name_fcode(25)  TYPE c VALUE 'EXIT_TAB_STRIP_CO_FCOD',
602       seex_tab_strip_name_coco(25)   TYPE c VALUE 'EXIT_TAB_STRIP_CO_COCO',
603       seex_tab_strip_name_table(25)  TYPE c VALUE 'EXIT_TAB_STRIP_CO_INTA'.
604
605    * Please increase this number always if you perform major changes
606    * to the generator unit consisting of function groups SXIF, SXCV
607    CONSTANTS:
608       seex_generator_version TYPE version VALUE '1'.
*--- End of %_CSEEX - 608 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CSEOP                                   Level 1    Page 7
Object           ZFM_RFFMEP1BX_FOR3YEARS_CALL              Lines 139
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:50
----------------------------------------------------------------------------------------------------
1      type-pool seop .
2
3      type-pools:
4        seox,
5        srext,
6        schek.
7
8      types:
9        seop_schek_corr_tab type schek_corr occurs 10,
10
11     * Types for Source Code ( sections/methods)
12       seop_source_line type edpline,
13       seop_source_line_string type rsline,
14       seop_source type edpline occurs 0,
15       seop_source_string type rswsourcet,
16
17     * method's source
18       begin of seop_method_source,
19         implementation type seop_source,
20       end of seop_method_source,
21       seop_method_sources type seop_method_source occurs 0,
22     * class' source
23       begin of seop_class_source,                   "CLASS-POOL.
24         locals type seop_source,                    "...
25         pre_public type seop_source,                "TYPE-POOLS, ...LOAD
26         header type seop_source,                    "CLASS c DEFINITION
27                                                     "... PUBLIC.
28         public type seop_source,                    "PUBLIC SECTION. ...
29         protected type seop_source,                 "PROTECTED SECTION. ...
30         private type seop_source,                   "PRIVATE SECTION. ...
31         package type seop_source,                   "PACKAGE SECTION. ...  !!! needed for VERIs
32                                                     "ENDCLASS.
33       end of seop_class_source,                     "ENDCLASS
34       begin of seop_method_w_source,
35         cpdname like seocpdkey-cpdname,
36         redefine type seox_boolean,
37         source type seop_source,
38       end of seop_method_w_source,
39       seop_methods_w_source type seop_method_w_source occurs 0,
40     * method generation info struct
41       begin of seop_method_source_gen,
42         cpdname like seocpdkey-cpdname,
43         begin of flags,
44           implementation type seox_boolean,
45         end of flags,
46         source type seop_method_source,
47       end of seop_method_source_gen,
48       seop_method_sources_gen type seop_method_source_gen occurs 0,
49     * class generation info struct
50       begin of seop_class_source_gen,
51         clsname like seoclskey-clsname,
52         begin of flags,
53           locals type seox_boolean,
54           header type seox_boolean,
55           pre_public type seox_boolean,
56           public type seox_boolean,
57           protected type seox_boolean,
58           private type seox_boolean,
59           package type seox_boolean,
60         end of flags,
61         source type seop_class_source,
62         methods type seop_method_sources_gen,
63       end of seop_class_source_gen,
64     * interface's source
65       begin of seop_interface_source,               "CLASS-POOL.INTERFACE i.
66         section type seop_source,                    "PUBLIC SECTION. ...
67                                                     "...
68       end of seop_interface_source,                 "ENDINTERFACE
69     * interface generation info struct
70       begin of seop_interface_source_gen,
71         clsname like seoclskey-clsname,
72         begin of flags,
73           section type seox_boolean,
74         end of flags,
75         source type seop_interface_source,
76       end of seop_interface_source_gen,
77       begin of seop_method_w_include,
78         cpdkey type seocpdkey,
79         incname type programm,
80       end of seop_method_w_include,
81       seop_methods_w_include type seop_method_w_include occurs 0,
82       begin of seop_editor_info,
83         begin of section,
84           clskey type seoclskey,
85           inctype(2) type c,
86         end of section,
87         begin of method,
88     *     mtdkey type seocmpkey,
89           mtdkey type seocpdkey,
90         end of method,
91         incname type programm,
92       end of seop_editor_info,
93       seop_class_includes type programm
94         occurs 0,
95       seop_include_category type progcateg,     "=progstruc-categorya
96       seop_include_code(1),                     "=progstruc-codea(1)
97       seop_include_extension(2),                "=category+code (see srext)
98       seop_include_appendage(3),                "=progstruc-codea+1(3)
99       seop_include_ext_app(5).                  "=programm+30(5)
100
101    constants:
102      seop_inctype_class type seop_include_category value 'C',
103      seop_inctype_interface type seop_include_category value 'I',
104      seop_inccode_pool value 'P',
105      seop_inccode_local value 'L',
106      seop_inccode_public value 'U',
107    *  seop_inccode_package value 'A',
108      seop_inccode_protected value 'O',
109      seop_inccode_private value 'I',
110      seop_inccode_method value 'M',
111      seop_inccode_typeref value 'T',
112      seop_inccode_include value 'C',
113      seop_incappend_definition type seop_include_appendage value 'DEF',
114      seop_incappend_implementation type seop_include_appendage value 'IMP',
115      seop_incappend_macros type seop_include_appendage value 'MAC',
116      seop_incappend_testclasses type seop_include_appendage value 'AU',
117
118      seop_incextapp_definition type seop_include_ext_app value 'CCDEF',
119      seop_incextapp_implementation type seop_include_ext_app value 'CCIMP',
120      seop_incextapp_macros type seop_include_ext_app value 'CCMAC',
121      seop_incextapp_testclasses type seop_include_ext_app value 'CCAU',
122
123      seop_ext_class_locals_def type seop_include_ext_app value 'CCDEF',
124      seop_ext_class_locals_imp type seop_include_ext_app value 'CCIMP',
125      seop_ext_class_macros type seop_include_ext_app value 'CCMAC',
126      seop_ext_class_testclasses type seop_include_ext_app value 'CCAU',
127      seop_ext_class_source type seop_include_extension value 'CS',
128
129
130    *** obsolete ***
131      seop_inccode_include_ext_def type seop_include_appendage value 'DEF',
132      seop_inccode_include_ext_imp type seop_include_appendage value 'IMP',
133      seop_inccode_include_ext_mac type seop_include_appendage value 'MAC',
134
135
136      seop_src_inactive_deleted type seop_source_line
137          value '*** inactive deleted ***',
138      seop_src_inactive_new type seop_source_line
139          value '*** inactive new ***'.
*--- End of %_CSEOP - 139 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CSEOX                                   Level 1    Page 8
Object           ZFM_RFFMEP1BX_FOR3YEARS_CALL              Lines 21
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:50
----------------------------------------------------------------------------------------------------
1      type-pool seox .
2
3      types:
4        seox_boolean type seoflag,
5        seox_index type syindex,
6        seox_tabix type sytabix,
7        seox_subrc type sysubrc,
8        seox_action(1) type c,
9        seox_unknown_error(20) type c.
10
11     constants:
12     * boolean
13       seox_true type seox_boolean
14         value 'X',
15       seox_false type seox_boolean
16         value ' ',
17     * actions
18       seox_action_create type seox_action
19         value 'C',
20       seox_action_modify type seox_action
21         value 'M'.
*--- End of %_CSEOX - 21 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CSLIS                                   Level 1    Page 9
Object           ZFM_RFFMEP1BX_FOR3YEARS_CALL              Lines 543
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:50
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
Generated incl.  %_CSWBM                                   Level 1    Page 10
Object           ZFM_RFFMEP1BX_FOR3YEARS_CALL              Lines 933
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:50
----------------------------------------------------------------------------------------------------
1      TYPE-POOL swbm.
2
3      TYPES swbm_dummy TYPE c LENGTH 1.
4
5      ************************************************************************
6      *********** Workbench Request: Type ************************************
7      ************************************************************************
8      CONSTANTS:
9
10     * browsers / lists
11       swbm_c_type_object_list        TYPE seu_objtyp VALUE 'REP',
12       swbm_c_type_infosystem_browser TYPE seu_objtyp VALUE 'RIS',
13       swbm_c_type_cts_request_list   TYPE seu_objtyp VALUE 'RL ',
14       swbm_c_type_o2_mime_repository TYPE seu_objtyp VALUE 'WMR',
15       swbm_c_type_o2_html_browser    TYPE seu_objtyp VALUE 'WHB',
16       swbm_c_type_esiservice_browser TYPE seu_objtyp VALUE 'ESI',
17       swbm_c_type_wdy_text_browser   TYPE seu_objtyp VALUE 'WTX',
18       swbm_c_type_enhmod_browser     TYPE seu_objtyp VALUE 'ENH',
19       swbm_c_type_aunit_test_browser TYPE seu_objtyp VALUE 'AUN',
20       swbm_c_type_atc_result_browser TYPE seu_objtyp VALUE 'ATC',
21       swbm_c_type_twbm_browser       TYPE seu_objtyp VALUE 'TWB',
22       swbm_c_type_cim_class_browser  TYPE seu_objtyp VALUE 'CIB',
23       swbm_c_type_eclipse_proj_expl  TYPE seu_objtyp VALUE 'ECL',
24       swbm_c_type_application_hier   TYPE seu_objtyp VALUE 'APH',
25
26     * a workbench type for demo and test purposes:
27       swbm_c_demo_type               TYPE seu_objtyp VALUE '00',
28
29       swbm_c_type_control_composite  TYPE seu_objtyp VALUE 'CC ',  " obsolete since release 7.12
30
31     * CUA
32       swbm_c_type_cua_tree           TYPE seu_objtyp VALUE 'PCA',
33       swbm_c_type_cua                TYPE seu_objtyp VALUE 'CUI',
34       swbm_c_type_cua_status         TYPE seu_objtyp VALUE 'PC ',
35       swbm_c_type_cua_menubar        TYPE seu_objtyp VALUE 'PCU',
36       swbm_c_type_cua_menu           TYPE seu_objtyp VALUE 'PCM',
37       swbm_c_type_cua_funcassignmnt  TYPE seu_objtyp VALUE 'PCP',
38       swbm_c_type_cua_pushbuttons    TYPE seu_objtyp VALUE 'PCB',
39       swbm_c_type_cua_title          TYPE seu_objtyp VALUE 'PZ ',
40       swbm_c_type_cua_title_list     TYPE seu_objtyp VALUE 'PZL',
41       swbm_c_type_cua_function       TYPE seu_objtyp VALUE 'PCF',
42       swbm_c_type_cua_whereusedlist  TYPE seu_objtyp VALUE 'PCR',
43
44     * Program
45       swbm_c_type_source             TYPE seu_objtyp VALUE 'INC',
46       swbm_c_type_prg_source         TYPE seu_objtyp VALUE 'P  ',
47       swbm_c_type_prg_include        TYPE seu_objtyp VALUE 'I  ',
48       swbm_c_type_prg_field          TYPE seu_objtyp VALUE 'PD ',
49       swbm_c_type_prg_event          TYPE seu_objtyp VALUE 'PE ',
50       swbm_c_type_prg_macro          TYPE seu_objtyp VALUE 'PK ',
51       swbm_c_type_prg_class_def      TYPE seu_objtyp VALUE 'PL ',
52       swbm_c_type_prg_class_attr     TYPE seu_objtyp VALUE 'PLA',
53       swbm_c_type_prg_class_method   TYPE seu_objtyp VALUE 'PLM',
54       swbm_c_type_prg_class_event    TYPE seu_objtyp VALUE 'PLE',
55       swbm_c_type_prg_class_typedef  TYPE seu_objtyp VALUE 'PLY',
56     *  swbm_c_type_prg_class_alias    TYPE seu_objtyp VALUE 'PLB', " just used by ADT
57       swbm_c_type_prg_pai_module     TYPE seu_objtyp VALUE 'PM ',
58       swbm_c_type_prg_intf_def       TYPE seu_objtyp VALUE 'PN ',
59       swbm_c_type_prg_intf_attr      TYPE seu_objtyp VALUE 'PNA',
60       swbm_c_type_prg_intf_method    TYPE seu_objtyp VALUE 'PNM',
61       swbm_c_type_prg_intf_event     TYPE seu_objtyp VALUE 'PNE',
62       swbm_c_type_prg_intf_typedef   TYPE seu_objtyp VALUE 'PNY',
63       swbm_c_type_prg_pbo_module     TYPE seu_objtyp VALUE 'PO ',
64       swbm_c_type_prg_class_impl     TYPE seu_objtyp VALUE 'PP ',
65       swbm_c_type_prg_test_seam      TYPE seu_objtyp VALUE 'PQ ',
66       swbm_c_type_prg_table          TYPE seu_objtyp VALUE 'PT ',
67       swbm_c_type_prg_subroutine     TYPE seu_objtyp VALUE 'PU ',
68       swbm_c_type_prg_subr_param     TYPE seu_objtyp VALUE 'PUP',
69       swbm_c_type_prg_type           TYPE seu_objtyp VALUE 'PY ',
70       swbm_c_type_prg_dynpro         TYPE seu_objtyp VALUE 'PS ',
71       swbm_c_type_prg_textelement    TYPE seu_objtyp VALUE 'PX ',
72       swbm_c_type_prg_type_group     TYPE seu_objtyp VALUE 'PG ',
73
74     * Function -use program constants with F prefix instead of P
75       swbm_c_type_function           TYPE seu_objtyp VALUE 'FF ',
76       swbm_c_type_function_pool      TYPE seu_objtyp VALUE 'F  ',
77
78     * Set/Get-Parameter
79       swbm_c_type_parameter_id       TYPE seu_objtyp VALUE 'R  ',
80
81     * Dialog Modules
82       swbm_c_type_dialog             TYPE seu_objtyp VALUE 'A  ',
83
84     * Transaction maintanance
85       swbm_c_type_transaction        TYPE seu_objtyp VALUE 'T  ',
86
87     * Dictionary
88       swbm_c_type_ddic_general_type  TYPE seu_objtyp VALUE 'DQ ',
89       swbm_c_type_ddic_tabletype     TYPE seu_objtyp VALUE 'DA ',
90       swbm_c_type_dic_table_2nd_key  TYPE seu_objtyp VALUE 'DT2', "secondary keys for table types
91       swbm_c_type_ddic_domain        TYPE seu_objtyp VALUE 'DD ',
92       swbm_c_type_ddic_dataelement   TYPE seu_objtyp VALUE 'DE ',
93       swbm_c_type_ddic_pool_cluster  TYPE seu_objtyp VALUE 'DX ',
94       swbm_c_type_ddic_searchhelp    TYPE seu_objtyp VALUE 'DH ',
95       swbm_c_type_ddic_typepool      TYPE seu_objtyp VALUE 'DG ',
96       swbm_c_type_ddic_type          TYPE seu_objtyp VALUE 'DGT',
97       swbm_c_type_ddic_enqueue       TYPE seu_objtyp VALUE 'DL ',
98       swbm_c_type_ddic_matchcode     TYPE seu_objtyp VALUE 'DM ',
99       swbm_c_type_ddic_structure     TYPE seu_objtyp VALUE 'DS ',
100      swbm_c_type_ddic_struc_field   TYPE seu_objtyp VALUE 'DSF',
101      swbm_c_type_ddic_db_table      TYPE seu_objtyp VALUE 'DT ',
102      swbm_c_type_ddic_db_tabfield   TYPE seu_objtyp VALUE 'DTF',
103      swbm_c_type_ddic_db_tabindex   TYPE seu_objtyp VALUE 'DTI',
104      swbm_c_type_ddic_db_tabxinx    TYPE seu_objtyp VALUE 'DTX',
105      swbm_c_type_ddic_db_tabsetting TYPE seu_objtyp VALUE 'DTT',
106      swbm_c_type_ddic_view          TYPE seu_objtyp VALUE 'DV ',
107      swbm_c_type_ddic_view_tset     TYPE seu_objtyp VALUE 'DVT',
108      swbm_c_type_ddic_view_field    TYPE seu_objtyp VALUE 'DVF',
109      swbm_c_type_ddic_db_sqlscript  TYPE seu_objtyp VALUE 'DU',
110      "! ABAP data definition language source DDLS
111      swbm_c_type_ddic_ddl_source    TYPE seu_objtyp VALUE 'DF ',
112      "! CDS table definition
113      swbm_c_type_ddic_table_entity  TYPE seu_objtyp VALUE 'TED',
114      "! WB Type for Entities created by DDL
115      swbm_c_type_structured_object  TYPE seu_objtyp VALUE 'DO ',
116      "! WB Type for Entity Fields created by DDL
117      swbm_c_type_struct_obj_field   TYPE seu_objtyp VALUE 'DOF',
118      "! WB Type for Associations of Entities
119      swbm_c_type_struc_obj_assoc    TYPE seu_objtyp VALUE 'DOA',
120      "! WB Type for View Parameter of View Entities
121      swbm_c_type_struc_obj_vw_param TYPE seu_objtyp VALUE 'DOP',
122      "! WB Type for extending View Entities of enhanced View Entities
123      "! from the point of view of the extended view entity
124      swbm_c_type_struc_obj_ext_vw   TYPE seu_objtyp VALUE 'DOE',
125      "! WB Type for secondary objects generated for STOB entities
126      "! defined in a DDLS from the point of view of the
127      "! originating view entity
128      swbm_c_type_struc_obj_sec_objs TYPE seu_objtyp VALUE 'DOS',
129      "! An entity which is a table function
130      swbm_c_type_struc_obj_tab_func TYPE seu_objtyp VALUE 'DOT',
131      "! Structured Objects are not transported when generated
132      "! by a DDL but for internal ADT communication it is defined
133      swbm_c_quasi_r3tr_struc_obj    TYPE trobjtype  VALUE 'STOB',
134
135    * Object types
136      swbm_c_type_cls_object_type    TYPE seu_objtyp VALUE 'O  ',
137
138    * class specific
139      swbm_c_type_class              TYPE seu_objtyp VALUE 'OC ',
140      swbm_c_type_cls_definition     TYPE seu_objtyp VALUE 'OCD',
141      swbm_c_type_cls_component      TYPE seu_objtyp VALUE 'OCC',
142      swbm_c_type_cls_signature      TYPE seu_objtyp VALUE 'OCS',
143      swbm_c_type_cls_attribute      TYPE seu_objtyp VALUE 'OA ',
144      swbm_c_type_cls_mtd_def        TYPE seu_objtyp VALUE 'OO ',
145      swbm_c_type_cls_mtd_param      TYPE seu_objtyp VALUE 'OOP',
146      swbm_c_type_cls_mtd_excep      TYPE seu_objtyp VALUE 'OOX',
147      swbm_c_type_cls_evt            TYPE seu_objtyp VALUE 'OE ',
148      swbm_c_type_cls_evt_param      TYPE seu_objtyp VALUE 'OEP',
149      swbm_c_type_cls_type           TYPE seu_objtyp VALUE 'OT ',
150      swbm_c_type_cls_intf_rel       TYPE seu_objtyp VALUE 'OR ',
151      swbm_c_type_cls_pers_mapping   TYPE seu_objtyp VALUE 'OCM',
152      swbm_c_type_cls_textelement    TYPE seu_objtyp VALUE 'OCX',
153      swbm_c_type_cls_test_seam      TYPE seu_objtyp VALUE 'OQ ',
154      swbm_c_type_cls_alias          TYPE seu_objtyp VALUE 'OB ', " just used in ADT
155
156    * source code
157      swbm_c_type_cls_pool           TYPE seu_objtyp VALUE 'OCP',
158      swbm_c_type_cls_section        TYPE seu_objtyp VALUE 'OS ',
159      swbm_c_type_cls_pri_section    TYPE seu_objtyp VALUE 'OSI',
160      swbm_c_type_cls_pro_section    TYPE seu_objtyp VALUE 'OSO',
161      swbm_c_type_cls_pub_section    TYPE seu_objtyp VALUE 'OSU',
162
163    * class implementation
164      swbm_c_type_cls_implementation TYPE seu_objtyp VALUE 'OCI',
165      swbm_c_type_cls_local          TYPE seu_objtyp VALUE 'OCL',
166      swbm_c_type_cls_include        TYPE seu_objtyp VALUE 'OCN',
167      swbm_c_type_cls_mtd_impl       TYPE seu_objtyp VALUE 'OM ',
168
169    * local classes in class-pools
170      swbm_c_type_cls_local_def      TYPE seu_objtyp VALUE 'OL ',    " local class (definition)
171      swbm_c_type_cls_local_impl     TYPE seu_objtyp VALUE 'OP ',    " local class (implementation)
172      swbm_c_type_cls_local_intf     TYPE seu_objtyp VALUE 'ON ',    " local interfaces
173      swbm_c_type_cls_local_type     TYPE seu_objtyp VALUE 'OY ',    " local types
174      swbm_c_type_cls_local_macro    TYPE seu_objtyp VALUE 'OK ',    " macro
175
176    * subcompnents of local classes
177      swbm_c_type_cls_loc_meth_def   TYPE seu_objtyp VALUE 'OLD',  " method definition in a local class
178      swbm_c_type_cls_loc_meth_impl  TYPE seu_objtyp VALUE 'OLI',  " method implementation in a local class
179      swbm_c_type_cls_local_attr     TYPE seu_objtyp VALUE 'OLA',  " attribute of a local class
180      swbm_c_type_cls_local_event    TYPE seu_objtyp VALUE 'OLE',  " event of a local class
181      swbm_c_type_cls_local_type2    TYPE seu_objtyp VALUE 'OLT',  " local type in a local class
182      swbm_c_type_cls_local_intf2    TYPE seu_objtyp VALUE 'OLN',  " local interface in a local class
183    *  swbm_c_type_cls_local_alias    TYPE seu_objtyp VALUE 'OLB',  " alias in a local class; just used in ADT
184
185    * subcompnents of local interfaces
186      swbm_c_type_cls_lintf_meth     TYPE seu_objtyp VALUE 'OND',  " method definition in a local interface
187      swbm_c_type_cls_lintf_attr     TYPE seu_objtyp VALUE 'ONA',  " attribute of a local interface
188      swbm_c_type_cls_lintf_event    TYPE seu_objtyp VALUE 'ONE',  " event of a local interface
189      swbm_c_type_cls_lintf_type     TYPE seu_objtyp VALUE 'ONT',  " type in a local interface
190      swbm_c_type_cls_lintf_intf     TYPE seu_objtyp VALUE 'ONN',  " interface in a local interface
191    *  swbm_c_type_cls_lintf_alias    TYPE seu_objtyp VALUE 'ONB',  " alias in a local class; just used in ADT
192
193    * (free/available 'O*' constants are currently: OF, OD, OU, OH, OJ, OV, OW, OX )
194
195    * oxygen
196      swbm_c_type_cls_o2_page        TYPE seu_objtyp VALUE 'OG ',
197      swbm_c_type_cls_o2_local_mime  TYPE seu_objtyp VALUE 'OLM',
198
199    * interface specific
200      swbm_c_type_interface          TYPE seu_objtyp VALUE 'OI ',
201      swbm_c_type_intf_component     TYPE seu_objtyp VALUE 'ICC',
202      swbm_c_type_intf_signature     TYPE seu_objtyp VALUE 'ICS',
203      swbm_c_type_intf_attribute     TYPE seu_objtyp VALUE 'IA ',
204      swbm_c_type_intf_mtd_def       TYPE seu_objtyp VALUE 'IO ',
205      swbm_c_type_intf_mtd_param     TYPE seu_objtyp VALUE 'IOP',
206      swbm_c_type_intf_mtd_excep     TYPE seu_objtyp VALUE 'IOX',
207      swbm_c_type_intf_evt           TYPE seu_objtyp VALUE 'IE ',
208      swbm_c_type_intf_evt_param     TYPE seu_objtyp VALUE 'IEP',
209      swbm_c_type_intf_type          TYPE seu_objtyp VALUE 'IT ',
210      swbm_c_type_intf_pool          TYPE seu_objtyp VALUE 'OIP',
211      swbm_c_type_intf_section       TYPE seu_objtyp VALUE 'ISU',
212      swbm_c_type_intf_alias         TYPE seu_objtyp VALUE 'IB ', " just used in ADT
213
214    * package builder
215      swbm_c_type_package            TYPE seu_objtyp VALUE 'K  ',
216      swbm_c_type_package_hierarchy  TYPE seu_objtyp VALUE 'KH',
217      swbm_c_type_package_interface  TYPE seu_objtyp VALUE 'KI',
218      swbm_c_type_permission_to_use  TYPE seu_objtyp VALUE 'KPU',
219      swbm_c_type_interface_element  TYPE seu_objtyp VALUE 'KIE',
220      swbm_c_type_interface_header   TYPE seu_objtyp VALUE 'KIH',
221
222    * classification tool
223      swbm_c_type_classification     TYPE seu_objtyp VALUE '8',
224      swbm_c_type_object_type_group  TYPE seu_objtyp VALUE '8A',
225      swbm_c_type_cls_attribute_def  TYPE seu_objtyp VALUE '8B',
226      swbm_c_type_cls_attribute_val  TYPE seu_objtyp VALUE '8BV',
227      swbm_c_type_cls_assignment     TYPE seu_objtyp VALUE '8C',
228      swbm_c_type_cls_report_def     TYPE seu_objtyp VALUE '8D',
229      swbm_c_type_cls_report_run     TYPE seu_objtyp VALUE '8E',
230      swbm_c_type_cls_report_runstat TYPE seu_objtyp VALUE '8ES',
231      swbm_c_type_browse_classfictns TYPE seu_objtyp VALUE 'CLS',
232
233    * web tools
234      swbm_c_type_service            TYPE seu_objtyp VALUE 'WS ',
235      swbm_c_type_miniapp            TYPE seu_objtyp VALUE 'WA ',
236      swbm_c_type_url                TYPE seu_objtyp VALUE 'WU ',
237
238    * enterprise service
239      swbm_c_type_business_obj_enh   TYPE seu_objtyp VALUE '3X',     " Business Object Enhancement
240      swbm_c_type_web_service        TYPE seu_objtyp VALUE '3S',
241      swbm_c_type_virt_interface     TYPE seu_objtyp VALUE '3I',     " Service Provider
242      swbm_c_type_server_proxy       TYPE seu_objtyp VALUE '3P',
243      swbm_c_type_client_proxy       TYPE seu_objtyp VALUE '3C',
244      swbm_c_type_servconsumer_group TYPE seu_objtyp VALUE '3G',     " Service Consumer Group
245      swbm_c_type_proxy_ddic         TYPE seu_objtyp VALUE '3D',
246      swbm_c_type_proxy_exception    TYPE seu_objtyp VALUE '3E',
247      swbm_c_type_proxy_agent        TYPE seu_objtyp VALUE '3A',     " obsolete!  (process agent)
248      swbm_c_type_task_agent         TYPE seu_objtyp VALUE '3A',
249      swbm_c_type_task_type          TYPE seu_objtyp VALUE '3Y',
250      swbm_c_type_process_agent_in   TYPE seu_objtyp VALUE '3O',
251      swbm_c_type_process_agent_out  TYPE seu_objtyp VALUE '3Q',
252      swbm_c_type_logical_port       TYPE seu_objtyp VALUE '3L',
253      swbm_c_type_logport_template   TYPE seu_objtyp VALUE '3T',
254      swbm_c_type_service_variant    TYPE seu_objtyp VALUE '3R',
255      swbm_c_type_event_provider     TYPE seu_objtyp VALUE '3V',     " Event Provider
256      swbm_c_type_mapping_facade     TYPE seu_objtyp VALUE '3M',
257      swbm_c_type_mapping_object     TYPE seu_objtyp VALUE '3N',
258      swbm_c_type_service_prov_enh   TYPE seu_objtyp VALUE '3F', "Service Provider Enhancement
259      swbm_c_type_service_cons_enh   TYPE seu_objtyp VALUE '3H', "Service Consumer Enhancement
260    *  swbm_c_type_proc_type_domain     TYPE seu_objtyp VALUE '3J', "Processing Type Domain
261
262    *  swbm_c_type_npm_semantic_contr   TYPE seu_objtyp VALUE '3K', "Semantic Contract
263    *  swbm_c_type_npm_contract         TYPE seu_objtyp VALUE '3Z', "Contract
264    *  swbm_c_type_npm_contract_usage   TYPE seu_objtyp VALUE '3U', "Contract Usage
265    *  swbm_c_type_npm_scenario_def     TYPE seu_objtyp VALUE '30', "Scenario Definition
266
267      swbm_c_type_pi_messagetype     TYPE seu_objtyp VALUE '31', "Messagetype
268      swbm_c_type_pi_cons_factory    TYPE seu_objtyp VALUE '32', "Consumer Factory
269      swbm_c_type_pi_proxy_enh       TYPE seu_objtyp VALUE '33', "Data Type Enhancements
270
271      swbm_c_type_api_state          TYPE seu_objtyp VALUE 'API', "R3TR APIS
272
273    * >>>>>>>>>>>>>>>>>>>>>>>>>
274    *** SCOOL -> obsolete: Do not use  / 2018
275      swbm_c_type_cool_aspect        TYPE seu_objtyp VALUE '4A',
276      swbm_c_type_cool_action        TYPE seu_objtyp VALUE '4C',
277      swbm_c_type_cool_service_mod   TYPE seu_objtyp VALUE '4S',
278      swbm_c_type_cool_business_ob   TYPE seu_objtyp VALUE '3B',     " business object (SPROXY)
279      swbm_c_type_cool_business_oc   TYPE seu_objtyp VALUE '3BC',    " business object (COOL)
280      swbm_c_type_cool_bo_node       TYPE seu_objtyp VALUE '3BN',
281    * <<<<<<<<<<<<<<<<<<<<<<<<<
282    * this is the re-use of the 4* values:   (rd 07/2008)
283      swbm_c_type_check_aspect       TYPE seu_objtyp VALUE '4A',
284      swbm_c_type_check_asp_group    TYPE seu_objtyp VALUE '4G',
285      swbm_c_type_check_asp_value    TYPE seu_objtyp VALUE '4V',
286      swbm_c_type_check_config       TYPE seu_objtyp VALUE '4C',
287      swbm_c_type_check_config_rule  TYPE seu_objtyp VALUE '4R',
288
289    * form object
290      swbm_c_type_formobject_form    TYPE seu_objtyp VALUE '5F',
291      swbm_c_type_formobject_intf    TYPE seu_objtyp VALUE '5I',
292
293    * switch framework
294      swbm_c_type_sf_switch          TYPE seu_objtyp VALUE '6S',
295      swbm_c_type_sf_function        TYPE seu_objtyp VALUE '6F',
296      swbm_c_type_sf_set             TYPE seu_objtyp VALUE '6T',
297      swbm_c_type_sf_bcset           TYPE seu_objtyp VALUE '6B',
298
299    * "generic fast search" (GFS) services
300      swbm_c_type_f_search_def       TYPE seu_objtyp VALUE '7S',
301      swbm_c_type_f_view_def         TYPE seu_objtyp VALUE '7V',
302
303    * reservation of a 'namespace' for AP/ByD Metadata Repository:
304      swbm_c_type_byd_mdr            TYPE seu_objtyp VALUE '9',
305
306      swbm_c_type_w3_service         TYPE seu_objtyp VALUE 'WS ',
307      swbm_c_type_w3_service_para    TYPE seu_objtyp VALUE 'WSP',
308      swbm_c_type_w3_service_intpara TYPE seu_objtyp VALUE 'WSI',
309      swbm_c_type_w3_template        TYPE seu_objtyp VALUE 'WT ',
310      swbm_c_type_w3_template_langu  TYPE seu_objtyp VALUE 'WK ',
311      swbm_c_type_w3_xml             TYPE seu_objtyp VALUE 'W2 ',
312      swbm_c_type_w3_mime            TYPE seu_objtyp VALUE 'WM ',
313      swbm_c_type_w3_mime_langu      TYPE seu_objtyp VALUE 'WL ',
314      swbm_c_type_w3_resource        TYPE seu_objtyp VALUE 'WP ',
315      swbm_c_type_w3_resource_para   TYPE seu_objtyp VALUE 'WPP',
316      swbm_c_type_w3_javascript      TYPE seu_objtyp VALUE 'WJ ', " obsolete since release 7.2 (7.12)
317      swbm_c_type_w3_miniapp         TYPE seu_objtyp VALUE 'WA ',
318      swbm_c_type_w3_bhtml_function  TYPE seu_objtyp VALUE 'WBF',
319      swbm_c_type_w3_bhtml_docu      TYPE seu_objtyp VALUE 'WBD',
320
321      swbm_c_type_o2_application     TYPE seu_objtyp VALUE 'WO ',
322      swbm_c_type_o2_page            TYPE seu_objtyp VALUE 'WG ',
323      swbm_c_type_o2_view            TYPE seu_objtyp VALUE 'WV ',
324      swbm_c_type_o2_controller      TYPE seu_objtyp VALUE 'WR ',
325      swbm_c_type_o2_page_attribute  TYPE seu_objtyp VALUE 'WGA',
326      swbm_c_type_o2_eventhandler    TYPE seu_objtyp VALUE 'WGE',
327      swbm_c_type_o2_type            TYPE seu_objtyp VALUE 'WGT',
328      swbm_c_type_o2_page_fragment   TYPE seu_objtyp VALUE 'W1 ', " 'WF' is possibly used for Flow Logics (Internet Services)
329      swbm_c_type_o2_local_mime      TYPE seu_objtyp VALUE 'WI ',
330      swbm_c_type_o2_xml_file        TYPE seu_objtyp VALUE 'WX ', " obsolete since release 7.2
331      swbm_c_type_o2_theme           TYPE seu_objtyp VALUE 'WH ',
332      swbm_c_type_o2_wcf_control     TYPE seu_objtyp VALUE 'WC ', " obsolete since release 7.2
333      swbm_c_type_o2_wcf_browser     TYPE seu_objtyp VALUE 'WCB', " obsolete since release 7.2
334      swbm_c_type_o2_taglibrary      TYPE seu_objtyp VALUE 'WB ',
335      swbm_c_type_o2_tag             TYPE seu_objtyp VALUE 'WD ',
336      swbm_c_type_o2_tag_attribute   TYPE seu_objtyp VALUE 'WDA',
337      swbm_c_type_o2_tag_variable    TYPE seu_objtyp VALUE 'WDV',
338
339    * Web Dynpro
340      swbm_c_type_wdy_application    TYPE seu_objtyp VALUE 'YY',  " changed from 'WY' (rd, 01/26/2005)
341      swbm_c_type_wdy_application_tm TYPE seu_objtyp VALUE 'YYT', " ('Text editor' mode)
342      swbm_c_type_wdy_cs_controller  TYPE seu_objtyp VALUE 'WQ',
343      swbm_c_type_wdy_view           TYPE seu_objtyp VALUE 'WZ',
344      swbm_c_type_wdy_view_tm        TYPE seu_objtyp VALUE 'WZT', " ('Text editor' mode)
345      swbm_c_type_wdy_window         TYPE seu_objtyp VALUE 'WW',
346      swbm_c_type_wdy_window_tm      TYPE seu_objtyp VALUE 'WWT', " ('Text editor' mode)
347      swbm_c_type_wdy_win_controller TYPE seu_objtyp VALUE 'WE',
348      swbm_c_type_wdy_component      TYPE seu_objtyp VALUE 'YC',
349      swbm_c_type_wdy_component_tm   TYPE seu_objtyp VALUE 'YCT', " ('Text editor' mode)
350      swbm_c_type_wdy_compusage      TYPE seu_objtyp VALUE 'YU',
351      swbm_c_type_wdy_contr_usage    TYPE seu_objtyp VALUE 'YZ',
352      swbm_c_type_wdy_comp_model     TYPE seu_objtyp VALUE 'YO',
353      swbm_c_type_wdy_cp_controller  TYPE seu_objtyp VALUE 'YT',
354      swbm_c_type_wdy_cp_interface   TYPE seu_objtyp VALUE 'YI',
355      swbm_c_type_wdy_cp_intf_view   TYPE seu_objtyp VALUE 'YV',
356      swbm_c_type_wdy_cf_controller  TYPE seu_objtyp VALUE 'YF',
357      swbm_c_type_wdy_cp_intf_def    TYPE seu_objtyp VALUE 'YD',
358      swbm_c_type_wdy_intf_view_def  TYPE seu_objtyp VALUE 'YW',
359      swbm_c_type_wdy_mime           TYPE seu_objtyp VALUE 'YM',
360      swbm_c_type_wdy_comp_config    TYPE seu_objtyp VALUE 'YG',
361      swbm_c_type_wdy_appl_config    TYPE seu_objtyp VALUE 'YA',
362      swbm_c_type_wdy_chip           TYPE seu_objtyp VALUE 'YP',
363      swbm_c_type_wdy_fpm_fp_conf    TYPE seu_objtyp VALUE 'Y10',
364      swbm_c_type_wdy_fpm_adapt_conf TYPE seu_objtyp VALUE 'Y11',
365      swbm_c_type_wdy_fpm_layout_cnf TYPE seu_objtyp VALUE 'Y12',
366      swbm_c_type_wdy_fpm_guibb_conf TYPE seu_objtyp VALUE 'Y13',
367      swbm_c_type_wdy_fpm_ruibb_conf TYPE seu_objtyp VALUE 'Y14',
368      swbm_c_type_wdy_fpm_applicatin TYPE seu_objtyp VALUE 'Y20',
369      swbm_c_type_wdy_fpm_appl_conf  TYPE seu_objtyp VALUE 'Y01',
370
371    * BAdIs
372      swbm_c_type_badi_def           TYPE seu_objtyp VALUE 'XD ',
373      swbm_c_type_badi_imp           TYPE seu_objtyp VALUE 'XI ',
374      swbm_c_type_badi_imp_cust      TYPE seu_objtyp VALUE 'XIA', "activate BAdI in customizing (SXCC/ENBC)
375
376    * kernel based BAdIs
377      swbm_c_type_cbadi_def          TYPE seu_objtyp VALUE 'XB ',
378      swbm_c_type_cbadi_imp          TYPE seu_objtyp VALUE 'XC ',
379
380    * enhancements
381      swbm_c_type_enhancement        TYPE seu_objtyp VALUE 'XH',
382      "  swbm_c_type_enh_dictionary     TYPE seu_objtyp VALUE 'XR',    "obsolete and therefore disabled
383      swbm_c_type_enh_composite      TYPE seu_objtyp VALUE 'XF',
384      swbm_c_type_enh_spot           TYPE seu_objtyp VALUE 'XS',
385      swbm_c_type_enh_spot_comp      TYPE seu_objtyp VALUE 'XT',
386      swbm_c_type_enh_comp_hierarchy TYPE seu_objtyp VALUE 'XY',
387      swbm_c_type_enh_subcomp        TYPE seu_objtyp VALUE 'XU',  " (a subordinate composite is in fact a composite: 'XF')
388      swbm_c_type_enh_subspotcomp    TYPE seu_objtyp VALUE 'XO',  " (a subordinate spot composite is in fact a spot composite: 'XT')
389      swbm_c_type_spau               TYPE seu_objtyp VALUE 'XSP', " 'SPAU object'
390      swbm_c_type_enh_undefined      TYPE seu_objtyp VALUE 'X?',
391
392    *  enhancement technology specific subtypes
393      swbm_c_type_enh_hook_impl      TYPE seu_objtyp VALUE 'XHH',
394      swbm_c_type_enh_badi_impl      TYPE seu_objtyp VALUE 'XHB',
395      swbm_c_type_enh_badi_def       TYPE seu_objtyp VALUE 'XSB',
396
397    * types within the 'Easy Enhancement Workbench' - 'Expert tool for extensibility'
398    *    (application development, system ABA):
399      swbm_c_type_easy_enh           TYPE seu_objtyp VALUE 'X_',  " (this denotes the namespace; individual types will be called 'X_A', 'X_B' etc.)
400
401    * XML support (object types starting with prefix V)
402    * DMC objecttypes
403      swbm_c_type_dmc_application    TYPE seu_objtyp VALUE 'VA ',
404      swbm_c_type_dmc_project        TYPE seu_objtyp VALUE 'VP ',
405      swbm_c_type_dmc_subproject     TYPE seu_objtyp VALUE 'VS ',
406      swbm_c_type_dmc_conv_object    TYPE seu_objtyp VALUE 'VO ',
407    * XSLT files
408      swbm_c_type_xslt_file          TYPE seu_objtyp VALUE 'VT ',
409      swbm_c_type_st_designer        TYPE seu_objtyp VALUE 'VD ',
410
411    * external types - WB
412      swbm_c_type_devclass           TYPE seu_objtyp VALUE 'K  ',
413      swbm_c_type_devclass_local     TYPE seu_objtyp VALUE '$TM',
414      swbm_c_type_message_id         TYPE seu_objtyp VALUE 'N  ',
415      swbm_c_type_message            TYPE seu_objtyp VALUE 'NN ',
416      swbm_c_type_area_menu          TYPE seu_objtyp VALUE 'E  ',
417      swbm_c_type_datamodel          TYPE seu_objtyp VALUE 'MD ',
418      swbm_c_type_entity             TYPE seu_objtyp VALUE 'ME ',
419      swbm_c_type_bor_objtype        TYPE seu_objtyp VALUE 'MO ',
420      swbm_c_type_project            TYPE seu_objtyp VALUE 'SP ',
421
422    * Workbench organizer integration
423      swbm_c_type_cts_request        TYPE seu_objtyp VALUE 'RQ ',
424      swbm_c_type_cts_client         TYPE seu_objtyp VALUE 'CTC',
425      swbm_c_type_cts_system         TYPE seu_objtyp VALUE 'CTS',
426      swbm_c_type_cts_reqtarget      TYPE seu_objtyp VALUE 'CTT',
427      swbm_c_type_cts_author         TYPE seu_objtyp VALUE 'CTA',
428
429    * external types - not WB
430      swbm_c_type_auth_object        TYPE seu_objtyp VALUE 'B  ',
431      swbm_c_type_logical_database   TYPE seu_objtyp VALUE 'L  ',
432      swbm_c_type_wf_task            TYPE seu_objtyp VALUE 'MA ',
433      swbm_c_type_wf_role            TYPE seu_objtyp VALUE 'MR ',
434      swbm_c_type_wf_workflow        TYPE seu_objtyp VALUE 'MM ',
435      swbm_c_type_proc_process       TYPE seu_objtyp VALUE 'MP ',
436      swbm_c_type_proc_procvar       TYPE seu_objtyp VALUE 'MV ',
437      swbm_c_type_proc_function      TYPE seu_objtyp VALUE 'MF ',
438      swbm_c_type_busconf_schema     TYPE seu_objtyp VALUE '{S ', " AP/A1S Business Configuration Content: Schema
439      swbm_c_type_busconf_smnode     TYPE seu_objtyp VALUE '{N ', " AP/A1S Business Configuration Content: Schema Node
440
441    * BOR migration
442      swbm_c_type_bor_mig_tree       TYPE seu_objtyp VALUE 'MOT',
443      swbm_c_type_bor_mig_impl       TYPE seu_objtyp VALUE 'MOI',
444
445    * CATT type
446      swbm_c_type_testcase           TYPE seu_objtyp VALUE 'GT',
447
448    * eCATT external types
449      swbm_c_type_ecatt_types        TYPE seu_objtyp VALUE 'E00',
450      swbm_c_type_ecatt_test_script  TYPE seu_objtyp VALUE 'GE',
451      swbm_c_type_ecatt_test_config  TYPE seu_objtyp VALUE 'GC',
452      swbm_c_type_ecatt_test_data    TYPE seu_objtyp VALUE 'GD',
453      swbm_c_type_ecatt_system_data  TYPE seu_objtyp VALUE 'GS',
454      swbm_c_type_ecatt_val_object   TYPE seu_objtyp VALUE 'GB',
455      swbm_c_type_ecatt_scen_object  TYPE seu_objtyp VALUE 'GZ',
456      swbm_c_type_ecatt_cobj_object  TYPE seu_objtyp VALUE 'GU',
457      swbm_c_type_ecatt_scen_sp      TYPE seu_objtyp VALUE 'GF',
458      swbm_c_type_ecatt_start_profil TYPE seu_objtyp VALUE 'GY',
459
460    * eCATT internal types
461      swbm_c_type_ecatt_scr_param    TYPE seu_objtyp VALUE 'GP',
462      swbm_c_type_ecatt_dat_param    TYPE seu_objtyp VALUE 'GQ',
463      swbm_c_type_ecatt_tsys         TYPE seu_objtyp VALUE 'GR',
464      swbm_c_type_ecatt_dat_variant  TYPE seu_objtyp VALUE 'GV',
465      swbm_c_type_ecatt_cfg_variant  TYPE seu_objtyp VALUE 'GW',
466      swbm_c_type_ecatt_vo_param     TYPE seu_objtyp VALUE 'GX',
467      swbm_c_type_ecatt_smud         TYPE seu_objtyp VALUE 'GM',  " eCATT SMUD branch
468      swbm_c_type_solman_project     TYPE seu_objtyp VALUE 'GJ',  " Solution Manager Project
469      swbm_c_type_solman_solution    TYPE seu_objtyp VALUE 'GO',  " Solution Manager Solution
470
471    * testworkbench types
472    * swbm_c_type_twbm_browser         TYPE seu_objtyp VALUE 'TWB',   " see above ('browsers')
473      swbm_c_type_twbm_none          TYPE seu_objtyp VALUE 'TWI',
474      swbm_c_type_twbm_testcase      TYPE seu_objtyp VALUE 'TWS',
475      swbm_c_type_twbm_testcatalog   TYPE seu_objtyp VALUE 'GK',
476      swbm_c_type_twbm_catt          TYPE seu_objtyp VALUE 'TWA',
477      swbm_c_type_twbm_external      TYPE seu_objtyp VALUE 'TWX',
478      swbm_c_type_twbm_obj_name      TYPE seu_objtyp VALUE 'TWN',
479      swbm_c_type_twbm_obj_type      TYPE seu_objtyp VALUE 'TWT',
480      swbm_c_type_twbm_testplan      TYPE seu_objtyp VALUE 'GL',
481      swbm_c_type_twbm_testpackage   TYPE seu_objtyp VALUE 'GA',
482
483    * Other types
484      swbm_c_type_activator          TYPE seu_objtyp VALUE 'ACT',
485      swbm_c_type_tool               TYPE seu_objtyp VALUE 'TOL',
486      swbm_c_type_syntax_error_list  TYPE seu_objtyp VALUE 'ER ',
487      swbm_c_type_worklist           TYPE seu_objtyp VALUE 'TDO',
488      swbm_c_type_edit_table         TYPE seu_objtyp VALUE 'TB ',
489      swbm_c_type_navigation_stack   TYPE seu_objtyp VALUE 'STK',
490      swbm_c_type_fcode              TYPE seu_objtyp VALUE 'FC ',
491      swbm_c_type_split_screen       TYPE seu_objtyp VALUE 'SSE',
492      swbm_c_type_no_object          TYPE seu_objtyp VALUE 'INI',
493      swbm_c_type_inactive_objects   TYPE seu_objtyp VALUE 'WIA',
494      swbm_c_type_shared_obj_area    TYPE seu_objtyp VALUE 'SH',   " shared objects
495      swbm_c_type_activation_id      TYPE seu_objtyp VALUE 'AD'.
496
497    TYPES:
498      swbm_type_list TYPE REF TO cl_wb_object_type OCCURS 0.
499
500    ************************************************************************
501    *********** Workbench Request: Operation *******************************
502    ************************************************************************
503    CONSTANTS:
504      swbm_c_op_activate             TYPE seu_action VALUE 'ACTIVATE',
505      swbm_c_op_activate_generate    TYPE seu_action VALUE 'ACTGEN',
506      swbm_c_op_add_objects          TYPE seu_action VALUE 'ADDOBJECTS',
507      swbm_c_op_adjust               TYPE seu_action VALUE 'ADJUST',
508      swbm_c_op_amo_generate         TYPE seu_action VALUE 'AMO_GEN',
509      swbm_c_op_atc_check            TYPE seu_action VALUE 'ATC_CHECK',
510      swbm_c_op_atc_check_default    TYPE seu_action VALUE 'ATC_CHECKD', " ABAP Test Cockpit with default settings
511      swbm_c_op_aunit_favorites      TYPE seu_action VALUE 'AUNIT_FAV',  " display ABAP Unit Favorites Editor
512      swbm_c_op_aunit_tag_assistant  TYPE seu_action VALUE 'AUNIT_TAGS', " display ABAP Unit Tag Assistant
513      swbm_c_op_browse               TYPE seu_action VALUE 'BROWSE',
514      swbm_c_op_callgr_called_by     TYPE seu_action VALUE 'CG_CALLED',
515      swbm_c_op_callgr_calls         TYPE seu_action VALUE 'CG_CALLS',
516      swbm_c_op_change_devcls        TYPE seu_action VALUE 'MOVE',     "this is the standard operation for package reassignment
517      swbm_c_op_reassign_package     TYPE seu_action VALUE 'MOVE_PKG', "this is the operation for type-specific package reassignment
518      swbm_c_op_change_owner         TYPE seu_action VALUE 'CHNGOWNER',
519      swbm_c_op_check                TYPE seu_action VALUE 'CHECK',
520      swbm_c_op_check_extended       TYPE seu_action VALUE 'CHKEXTEND',
521      swbm_c_op_check_genlimits      TYPE seu_action VALUE 'CHECKLIMIT',
522      swbm_c_op_check_remote         TYPE seu_action VALUE 'CHECKREMOT',
523      swbm_c_op_check_mainprog       TYPE seu_action VALUE 'CHECKMAIN',
524      swbm_c_op_check_mainprog_all   TYPE seu_action VALUE 'CHKMAINALL',
525      swbm_c_op_check_all            TYPE seu_action VALUE 'CHECKALL',
526      swbm_c_op_check_r2             TYPE seu_action VALUE 'CHECKR2',
527      swbm_c_op_package_explain      TYPE seu_action VALUE 'PACKEXPL',
528      swbm_c_op_package_explain_refr TYPE seu_action VALUE 'PACKEXPL_R',
529      swbm_c_op_package_explain_assi TYPE seu_action VALUE 'PACKASSI',
530      swbm_c_op_cl_append            TYPE seu_action VALUE 'CL_APPEND',
531      swbm_c_op_copy                 TYPE seu_action VALUE 'COPY',
532      swbm_c_op_correct              TYPE seu_action VALUE 'CORRECT',
533      swbm_c_op_create_as_enhancemnt TYPE seu_action VALUE 'CREATASENH',    " 'Create object as an enhancement'
534      swbm_c_op_create               TYPE seu_action VALUE 'CREATE',
535    *obsolete:  swbm_c_op_create_access_object TYPE seu_action VALUE 'CREATEACCO',    " (Package Builder)
536      swbm_c_op_create_no_edit       TYPE seu_action VALUE 'CREANOEDIT',
537      swbm_c_op_delete               TYPE seu_action VALUE 'DELETE',
538      swbm_c_op_delete_no_dialog     TYPE seu_action VALUE 'DELETEND',
539      swbm_c_op_delete_testclas      TYPE seu_action VALUE 'DELTESTCL',
540      swbm_c_op_display              TYPE seu_action VALUE 'DISPLAY',
541      swbm_c_op_display_only         TYPE seu_action VALUE 'DISPONLY',
542      swbm_c_op_disp_or_create       TYPE seu_action VALUE 'DISPCREATE',
543      swbm_c_op_disp_or_edit         TYPE seu_action VALUE 'DISPEDIT',
544      swbm_c_op_disp_classification  TYPE seu_action VALUE 'DISPCLS',
545      swbm_c_op_edit_classification  TYPE seu_action VALUE 'EDITCLS',
546      swbm_c_op_disp_access_object   TYPE seu_action VALUE 'DISPACCO', " (Package Builder)
547      swbm_c_op_disp_obj_propagation TYPE seu_action VALUE 'DISPPROP',
548      swbm_c_op_disp_package_browser TYPE seu_action VALUE 'DISPPACK',
549      swbm_c_op_package_check        TYPE seu_action VALUE 'PACKCHECK',
550      swbm_c_op_disp_properties      TYPE seu_action VALUE 'PROPERTIES',
551      swbm_c_op_docu_edit            TYPE seu_action VALUE 'DOCUEDIT',
552      swbm_c_op_docu_show            TYPE seu_action VALUE 'DOCUSHOW',
553      swbm_c_op_documentation        TYPE seu_action VALUE 'DOCU',
554      swbm_c_op_ktd_docu             TYPE seu_action VALUE 'KTD_DOCU',
555      swbm_c_op_download             TYPE seu_action VALUE 'DOWNLOAD',
556      swbm_c_op_edit                 TYPE seu_action VALUE 'EDIT',
557      swbm_c_op_edit_or_create       TYPE seu_action VALUE 'EDITCREATE',
558      swbm_c_op_edit_enhancement     TYPE seu_action VALUE 'EDITENH',
559      swbm_c_op_edit_no_enhancement  TYPE seu_action VALUE 'EDITNOENH',
560      swbm_c_op_enh_auto_repair      TYPE seu_action VALUE 'ENHAUTOREP',
561      swbm_c_op_form_edit            TYPE seu_action VALUE 'EDITFORM',
562      swbm_c_op_form_display         TYPE seu_action VALUE 'DISPFORM',
563      swbm_c_op_form_create          TYPE seu_action VALUE 'CREATEFORM',
564      swbm_c_op_form_delete          TYPE seu_action VALUE 'DELETEFORM',
565      swbm_c_op_form_public          TYPE seu_action VALUE 'PUBLICFORM',
566      swbm_c_op_enhance              TYPE seu_action VALUE 'ENHANCE',
567      swbm_c_op_enha_intf            TYPE seu_action VALUE 'ENHAINTF',
568      swbm_c_op_end                  TYPE seu_action VALUE 'END',
569      swbm_c_op_environment          TYPE seu_action VALUE 'ENVIRON',
570      swbm_c_op_exec_batch           TYPE seu_action VALUE 'EXECBTC',
571      swbm_c_op_exec_bc_html         TYPE seu_action VALUE 'EXECBCHTML', " execute in NetWeaver Business Client - HTML Client
572      swbm_c_op_exec_bc_desktop      TYPE seu_action VALUE 'EXECBCDESK', " execute in NetWeaver Business Client - Desktop Client
573      swbm_c_op_exec_debug           TYPE seu_action VALUE 'EXECDBG',
574      swbm_c_op_exec_ecatt_all       TYPE seu_action VALUE 'EXECECATTA', " execute eCATT testconfiguration: all (within a package)
575      swbm_c_op_exec_ecatt_sel       TYPE seu_action VALUE 'EXECECATTS', " execute eCATT testconfiguration: selected (within a package)
576      swbm_c_op_exec_runtime         TYPE seu_action VALUE 'EXECRT',
577      swbm_c_op_exec_sequence        TYPE seu_action VALUE 'EXECSEQ',
578      swbm_c_op_execute              TYPE seu_action VALUE 'EXECUTE',
579      swbm_c_op_exec_transaction     TYPE seu_action VALUE 'EXECTRANS',
580      swbm_c_op_find                 TYPE seu_action VALUE 'FIND', " find string within object
581      swbm_c_op_generate             TYPE seu_action VALUE 'GENERATE',
582      swbm_c_op_generate_template    TYPE seu_action VALUE 'GENTEMPL',
583      swbm_c_op_generate_itsxml      TYPE seu_action VALUE 'GENITSXML', " xml template for ITS html template
584      swbm_c_op_generate_testclas    TYPE seu_action VALUE 'GENTESTCL',
585      swbm_c_op_initial_screen       TYPE seu_action VALUE 'INITIAL',
586      swbm_c_op_log                  TYPE seu_action VALUE 'SHOWLOG',
587      swbm_c_op_modify               TYPE seu_action VALUE 'MODIFY',
588      swbm_c_op_insert               TYPE seu_action VALUE 'INSERT',
589      swbm_c_op_not_used_list        TYPE seu_action VALUE 'NOTUSED',
590      swbm_c_op_pack_intf_analysis   TYPE seu_action VALUE 'PINTFANL',
591      swbm_c_op_parameter_list       TYPE seu_action VALUE 'MTDPARAM',
592      swbm_c_op_print                TYPE seu_action VALUE 'PRINT',
593      swbm_c_op_realize              TYPE seu_action VALUE 'REALIZE',
594      swbm_c_op_realize_no_dialog    TYPE seu_action VALUE 'REALIZEND',
595      swbm_c_op_redefine             TYPE seu_action VALUE 'REDEFINE',
596      swbm_c_op_undo_redefine        TYPE seu_action VALUE 'UNDO_REDEF',
597      swbm_c_op_refresh              TYPE seu_action VALUE 'REFRESH',
598      swbm_c_op_rename               TYPE seu_action VALUE 'RENAME',
599      swbm_c_op_release              TYPE seu_action VALUE 'RELEASE',
600      swbm_c_op_req_add_user         TYPE seu_action VALUE 'RQADDUSER',
601      swbm_c_op_search               TYPE seu_action VALUE 'SEARCH', " search object
602      swbm_c_op_shift                TYPE seu_action VALUE 'SHIFT',
603      swbm_c_op_show_esi_browser     TYPE seu_action VALUE 'SHOWESIBRO',
604      swbm_c_op_show_object_list     TYPE seu_action VALUE 'SHOWOBJLST',
605      swbm_c_op_show_cue_card        TYPE seu_action VALUE 'CUECARD',
606      swbm_c_op_split_screen         TYPE seu_action VALUE 'SPLITSCRN',
607      swbm_c_op_st_design            TYPE seu_action VALUE 'ST_DESIGN',
608      swbm_c_op_st_display           TYPE seu_action VALUE 'ST_DISPLAY',
609      swbm_c_op_table_content        TYPE seu_action VALUE 'TABCONT',
610      swbm_c_op_tadir_edit           TYPE seu_action VALUE 'TADIREDT',
611      swbm_c_op_tadir_edit_with_doc  TYPE seu_action VALUE 'TADIREDTWD',
612      swbm_c_op_transport            TYPE seu_action VALUE 'TRANSPORT',
613      swbm_c_op_transport_with_doc   TYPE seu_action VALUE 'TRANSPWDOC',
614      swbm_c_op_version_create       TYPE seu_action VALUE 'NEWVERSION',
615      swbm_c_op_versions             TYPE seu_action VALUE 'VERSIONS',
616      swbm_c_op_dispvers             TYPE seu_action VALUE 'DISPVERS',
617      swbm_c_op_check_show_detail    TYPE seu_action VALUE 'CHKSHOWDET',
618      swbm_c_op_where_used_list      TYPE seu_action VALUE 'WHEREUSED',
619      swbm_c_op_pass_down_use_access TYPE seu_action VALUE 'PASS_DOWN',
620      swbm_c_op_propagate            TYPE seu_action VALUE 'PROPAGATE',
621      swbm_c_op_propagate_display    TYPE seu_action VALUE 'PROPAGDISP',
622      swbm_c_op_package_check_hier   TYPE seu_action VALUE 'PACKCHECKH',
623      swbm_c_op_publish              TYPE seu_action VALUE 'PUBLISH',
624      swbm_c_op_publish_all          TYPE seu_action VALUE 'PUBLISHALL',
625      swbm_c_op_abap_unit            TYPE seu_action VALUE 'MODULETEST',
626      swbm_c_op_abap_unit_with_cov   TYPE seu_action VALUE 'MODTESTCOV',
627      swbm_c_op_abap_unit_with_bch1  TYPE seu_action VALUE 'MODTESTBT1',
628      swbm_c_op_abap_unit_with_bch2  TYPE seu_action VALUE 'MODTESTBT2',
629      swbm_c_op_ws_wzd_start         TYPE seu_action VALUE 'WS_WIZARD',
630      swbm_c_op_wdy_wzd_start        TYPE seu_action VALUE 'WDY_WIZARD',
631      swbm_c_op_wdy_show_using       TYPE seu_action VALUE 'WDY_USING',  " (Web Dynpro Component Usage)
632      swbm_c_op_wdy_show_used        TYPE seu_action VALUE 'WDY_USED',   " (Web Dynpro Component Usage)
633      swbm_c_op_wdy_config_contr     TYPE seu_action VALUE 'WDY_CONFIG', " Web Dynpro: Set as Configuration Controller / Edit Configuration
634      swbm_c_op_workingarea_copy     TYPE seu_action VALUE 'WORKAREA_C', " copy the list of inactive objects
635      swbm_c_op_workingarea_delete   TYPE seu_action VALUE 'WORKAREA_D', " delete the list of inactive objects
636      swbm_c_op_col_disp_graphic     TYPE seu_action VALUE 'DISPGRAPH',  " Enterprise Services: Display Graphic for Business Object
637      swbm_c_op_col_edit_graphic     TYPE seu_action VALUE 'EDITGRAPH',  " Enterprise Services: Edit Graphic for Business Object
638      swbm_c_op_theme_customizing    TYPE seu_action VALUE 'THEMECUST',
639      swbm_c_op_record_ecatt         TYPE seu_action VALUE 'REC_ECATT',
640      swbm_c_op_implement            TYPE seu_action VALUE 'IMPLEMENT',
641      swbm_c_op_uml_generate         TYPE seu_action VALUE 'UML_GEN',
642      swbm_c_op_upload               TYPE seu_action VALUE 'UPLOAD',
643      swbm_c_op_pack_navigate_error  TYPE seu_action VALUE 'PACKNAVERR',
644      swbm_c_op_index_update         TYPE seu_action VALUE 'INDEX_UPD'.
645    * specials for ABAP Dictionary
646    CONSTANTS:
647      swbm_c_op_create_derived       TYPE seu_action VALUE 'CREDERIVED'.
648
649    ************************************************************************
650    *********** Workbench Request: Types dealing with requests *************
651    ************************************************************************
652    TYPES:
653      swbm_wb_request_set            TYPE REF TO cl_wb_request OCCURS 0.
654
655    ************************************************************************
656    *********** Workbench: OK-Codes ****************************************
657    ************************************************************************
658    CONSTANTS:
659      swbm_c_fc_act_inact_toggle     TYPE sy-ucomm VALUE 'WB_ACT_INACT_TOGGLE',
660      swbm_c_fc_act_inact_toggle_eh  TYPE sy-ucomm VALUE 'WB_ACT_INACT_TOG_ENH',
661      swbm_c_fc_activate             TYPE sy-ucomm VALUE 'WB_ACTIVATE',
662      swbm_c_fc_activate_enh         TYPE sy-ucomm VALUE 'WB_ACTIVATE_ENH',
663      swbm_c_fc_active_version       TYPE sy-ucomm VALUE 'WB_ACTIVE_VERSION',
664      swbm_c_fc_active_version_enh   TYPE sy-ucomm VALUE 'WB_ACTIVE_VERS_ENH',
665      swbm_c_fc_add_objects          TYPE sy-ucomm VALUE 'WB_ADD_OBJECTS',
666      swbm_c_fc_amo_generate         TYPE sy-ucomm VALUE 'WB_AMO_GENERATE',
667      swbm_c_fc_atc_check            TYPE sy-ucomm VALUE 'WB_ATC_CHECK',
668      swbm_c_fc_atc_check_default    TYPE sy-ucomm VALUE 'WB_ATC_CHECK_DEFAULT', " ATC Check with default settings
669      swbm_c_fc_aunit_favorites      TYPE sy-ucomm VALUE 'WB_AUNIT_FAVORITES',   " display ABAP Unit Favorites Editor
670      swbm_c_fc_aunit_tag_assist     TYPE sy-ucomm VALUE 'WB_AUNIT_TAG_ASSIST',  " display ABAP Unit Tag Assistant
671      swbm_c_fc_back                 TYPE sy-ucomm VALUE 'WB_BACK',
672      swbm_c_fc_back_tb              TYPE sy-ucomm VALUE 'WB_BACK_TB',
673      swbm_c_fc_blck_copy            TYPE sy-ucomm VALUE 'WB_BLCK_COPY',
674      swbm_c_fc_blck_cut             TYPE sy-ucomm VALUE 'WB_BLCK_CUT',
675      swbm_c_fc_blck_mark            TYPE sy-ucomm VALUE 'WB_BLCK_MARK',
676      swbm_c_fc_blck_paste           TYPE sy-ucomm VALUE 'WB_BLCK_PASTE',
677      swbm_c_fc_bookmark_create      TYPE sy-ucomm VALUE 'WB_BOOKMARK_CREATE',
678      swbm_c_fc_bookmark_select      TYPE sy-ucomm VALUE 'WB_BOOKMARK_SELECT',
679      swbm_c_fc_bookmarks_display    TYPE sy-ucomm VALUE 'WB_BOOKMARKS_DISPLAY',
680      swbm_c_fc_bookmarks_edit       TYPE sy-ucomm VALUE 'WB_BOOKMARKS_EDIT',
681      swbm_c_fc_callgr_called_by     TYPE sy-ucomm VALUE 'WB_CG_CALLED_BY',
682      swbm_c_fc_callgr_calls         TYPE sy-ucomm VALUE 'WB_CG_CALLS',
683      swbm_c_fc_cancel               TYPE sy-ucomm VALUE 'WB_CANCEL',
684      swbm_c_fc_change_devclass      TYPE sy-ucomm VALUE 'WB_CHANGE_DEVCLASS', "this is the standard function code for package reassignment
685      swbm_c_fc_reassign_package     TYPE sy-ucomm VALUE 'WB_MOVE_PKG',        "this is the function code for type-specific package reassignment
686      swbm_c_fc_change_owner         TYPE sy-ucomm VALUE 'WB_CHANGE_OWNER',
687      swbm_c_fc_check                TYPE sy-ucomm VALUE 'WB_CHECK',
688      swbm_c_fc_check_all_errors     TYPE sy-ucomm VALUE 'WB_CHECK_ALL_ERRORS',
689      swbm_c_fc_check_consist        TYPE sy-ucomm VALUE 'WB_CHECK_CONSIST',
690      swbm_c_fc_check_extended       TYPE sy-ucomm VALUE 'WB_CHECK_EXTENDED',
691      swbm_c_fc_check_genlimits      TYPE sy-ucomm VALUE 'WB_CHECK_GENLIMITS',
692      swbm_c_fc_check_layout         TYPE sy-ucomm VALUE 'WB_CHECK_LAYOUT',
693      swbm_c_fc_check_mainprog       TYPE sy-ucomm VALUE 'WB_CHECK_MAINPROG',
694      swbm_c_fc_code_inspector       TYPE sy-ucomm VALUE 'WB_CODE_INSPECTOR',
695      swbm_c_fc_check_remote         TYPE sy-ucomm VALUE 'WB_CHECK_REMOTE',
696      swbm_c_fc_check_r2             TYPE sy-ucomm VALUE 'WB_CHECK_R2',
697      swbm_c_fc_check_warnings       TYPE sy-ucomm VALUE 'WB_CHECK_WARNINGS',
698      swbm_c_fc_package_check        TYPE sy-ucomm VALUE 'WB_PACKAGE_CHECK',
699      swbm_c_fc_classification       TYPE sy-ucomm VALUE 'WB_CLASSIFICATION',
700      swbm_c_fc_comp_hier            TYPE sy-ucomm VALUE 'WB_COMP_HIER',
701      swbm_c_fc_comp_hier_cust       TYPE sy-ucomm VALUE 'WB_COMP_HIER_CUST',
702      swbm_c_fc_comp_hier_sap        TYPE sy-ucomm VALUE 'WB_COMP_HIER_SAP',
703      swbm_c_fc_copy                 TYPE sy-ucomm VALUE 'WB_COPY',
704      swbm_c_fc_create               TYPE sy-ucomm VALUE 'WB_CREATE',
705    *obsolete: swbm_c_fc_create_access_object TYPE sy-ucomm VALUE 'WB_CREATEACCO',     " (Package Builder)
706      swbm_c_fc_create_as_enhancemnt TYPE sy-ucomm VALUE 'WB_CREATASENH',     " 'Create object as an enhancement'
707      swbm_c_fc_data_browser         TYPE sy-ucomm VALUE 'WB_DATA_BROWSER',
708      swbm_c_fc_delete               TYPE sy-ucomm VALUE 'WB_DELETE',
709      swbm_c_fc_delete_all           TYPE sy-ucomm VALUE 'WB_DELETE_ALL',
710      swbm_c_fc_delete_line          TYPE sy-ucomm VALUE 'WB_DELETE_LINE',
711      swbm_c_fc_delete_block         TYPE sy-ucomm VALUE 'WB_DELETE_BLOCK',
712      swbm_c_fc_disp_access_object   TYPE sy-ucomm VALUE 'WB_DISPACCO',      " (Package Builder)
713      swbm_c_fc_disp_edit_toggle     TYPE sy-ucomm VALUE 'WB_DISP_EDIT_TOGGLE',
714      swbm_c_fc_disp_or_edit         TYPE sy-ucomm VALUE 'WB_DISP_OR_EDIT',
715      swbm_c_fc_disp_properties      TYPE sy-ucomm VALUE 'WB_DISP_PROPERTIES',
716      swbm_c_fc_display              TYPE sy-ucomm VALUE 'WB_DISPLAY',
717      swbm_c_fc_display_frame        TYPE sy-ucomm VALUE 'WB_SHOW_FRAME',
718      swbm_c_fc_display_nw           TYPE sy-ucomm VALUE 'NW_WB_DISPLAY',
719      swbm_c_fc_display_topincl      TYPE sy-ucomm VALUE 'WB_SHOW_TOPINCLUDE',
720      swbm_c_fc_docu_edit            TYPE sy-ucomm VALUE 'WB_DOCU_EDIT',
721      swbm_c_fc_docu_show            TYPE sy-ucomm VALUE 'WB_DOCU_SHOW',
722      swbm_c_fc_docu_tool            TYPE sy-ucomm VALUE 'WB_DOCU_TOOL',
723      swbm_c_fc_documentation        TYPE sy-ucomm VALUE 'WB_DOCUMENTATION',
724      swbm_c_fc_download             TYPE sy-ucomm VALUE 'WB_DOWNLOAD',
725      swbm_c_fc_edit                 TYPE sy-ucomm VALUE 'WB_EDIT',
726      swbm_c_fc_edit_enhancements    TYPE sy-ucomm VALUE 'WB_EDIT_ENH',
727      swbm_c_fc_edit_noenhancements  TYPE sy-ucomm VALUE 'WB_EDIT_NOENH',
728      swbm_c_fc_end                  TYPE sy-ucomm VALUE 'WB_END',
729      swbm_c_fc_enh_auto_repair      TYPE sy-ucomm VALUE 'WB_ENH_AUTO_REPAIR',
730      swbm_c_fc_environment          TYPE sy-ucomm VALUE 'WB_ENVIRONMENT',
731      swbm_c_fc_ex_controls          TYPE sy-ucomm VALUE 'WB_EX_CONTROLS',
732      swbm_c_fc_ex_demos             TYPE sy-ucomm VALUE 'WB_EX_DEMOS',
733      swbm_c_fc_ex_ergo_list         TYPE sy-ucomm VALUE 'WB_EX_ERGO_LIST',
734      swbm_c_fc_ex_ergo_dynpro       TYPE sy-ucomm VALUE 'WB_EX_ERGO_DYNPRO',
735      swbm_c_fc_ex_perf              TYPE sy-ucomm VALUE 'WB_EX_PERF',
736      swbm_c_fc_exec                 TYPE sy-ucomm VALUE 'WB_EXEC',
737      swbm_c_fc_exec_batch           TYPE sy-ucomm VALUE 'WB_EXEC_BATCH',
738      swbm_c_fc_exec_bc_html         TYPE sy-ucomm VALUE 'WB_EXEC_BC_HTML',  " execute in NetWeaver Business Client - HTML Client
739      swbm_c_fc_exec_bc_desktop      TYPE sy-ucomm VALUE 'WB_EXEC_BC_DESK',  " execute in NetWeaver Business Client - Desktop Client
740      swbm_c_fc_exec_catt            TYPE sy-ucomm VALUE 'WB_EXEC_CATT',
741      swbm_c_fc_exec_ecatt_all       TYPE sy-ucomm VALUE 'WB_EXEC_ECATT_A',  " execute eCATT testconfiguration: all (within a package)
742      swbm_c_fc_exec_ecatt_sel       TYPE sy-ucomm VALUE 'WB_EXEC_ECATT_S',  " execute eCATT testconfiguration: selected (within a package)
743      swbm_c_fc_exec_debug           TYPE sy-ucomm VALUE 'WB_EXEC_DEBUG',
744      swbm_c_fc_exec_runtime         TYPE sy-ucomm VALUE 'WB_EXEC_RUNTIME',
745      swbm_c_fc_exec_sequence        TYPE sy-ucomm VALUE 'WB_EXEC_SEQUENCE',
746      swbm_c_fc_find                 TYPE sy-ucomm VALUE 'WB_FIND',
747      swbm_c_fc_forward              TYPE sy-ucomm VALUE 'WB_FORWARD',
748      swbm_c_fc_fullscreen_toggle    TYPE sy-ucomm VALUE 'WB_FULLSCREEN',
749      swbm_c_fc_generate             TYPE sy-ucomm VALUE 'WB_GENERATE',
750      swbm_c_fc_generate_template    TYPE sy-ucomm VALUE 'WB_GENERATE_TEMPL',
751      swbm_c_fc_generate_testclass   TYPE sy-ucomm VALUE 'WB_GENERATE_TESTCL',
752      swbm_c_fc_html_tags            TYPE sy-ucomm VALUE 'WB_HTML_TAGS',
753      swbm_c_fc_inactive_objects     TYPE sy-ucomm VALUE 'WB_INACTIVE_OBJECTS',
754      swbm_c_fc_ia_activate          TYPE sy-ucomm VALUE 'WB_IA_ACTIVATE',
755      swbm_c_fc_ifr                  TYPE sy-ucomm VALUE 'WB_IFR',
756      swbm_c_fc_infosystem           TYPE sy-ucomm VALUE 'WB_INFOSYSTEM',
757      swbm_c_fc_info_channel         TYPE sy-ucomm VALUE 'WB_INFO_CHANNEL', "obsolet
758      swbm_c_fc_line_delete          TYPE sy-ucomm VALUE 'WB_LINE_DELETE',
759      swbm_c_fc_line_insert          TYPE sy-ucomm VALUE 'WB_LINE_INSERT',
760      swbm_c_fc_mime_repository      TYPE sy-ucomm VALUE 'WB_MIME_REP',
761      swbm_c_fc_mod_assistent_off    TYPE sy-ucomm VALUE 'WB_MOD_ASSISTENT_OFF',
762      swbm_c_fc_mod_browser          TYPE sy-ucomm VALUE 'WB_MOD_BROWSER',
763      swbm_c_fc_mod_create           TYPE sy-ucomm VALUE 'WB_MOD_CREATE',
764      swbm_c_fc_mod_display_orig     TYPE sy-ucomm VALUE 'WB_MOD_DISPLAY_ORIG',
765      swbm_c_fc_mod_overview         TYPE sy-ucomm VALUE 'WB_MOD_OVERVIEW',
766      swbm_c_fc_mod_reset            TYPE sy-ucomm VALUE 'WB_MOD_RESET',
767      swbm_c_fc_mod_sel_delete       TYPE sy-ucomm VALUE 'WB_MOD_SEL_DELETE',
768      swbm_c_fc_mod_sel_edit         TYPE sy-ucomm VALUE 'WB_MOD_SEL_EDIT',
769      swbm_c_fc_mod_sel_replace      TYPE sy-ucomm VALUE 'WB_MOD_SEL_REPLACE',
770      swbm_c_fc_mod_sub_edit         TYPE sy-ucomm VALUE 'WB_MOD_SUB_EDIT',
771      swbm_c_fc_mod_sub_orig         TYPE sy-ucomm VALUE 'WB_MOD_SUB_ORIG',
772      swbm_c_fc_mod_sub_overview     TYPE sy-ucomm VALUE 'WB_MOD_SUB_OVERVIEW',
773      swbm_c_fc_mod_undo             TYPE sy-ucomm VALUE 'WB_MOD_UNDO',
774      swbm_c_fc_mod_display_inter    TYPE sy-ucomm VALUE 'WB_MOD_DISPLAY_INTER',
775      swbm_c_fc_multi_object_next    TYPE sy-ucomm VALUE 'WB_MULTI_OBJECT_NEXT',
776      swbm_c_fc_multi_object_prev    TYPE sy-ucomm VALUE 'WB_MULTI_OBJECT_PREV',
777      swbm_c_fc_navstack_edit        TYPE sy-ucomm VALUE 'WB_NAVSTACK_EDIT',
778      swbm_c_fc_not_used_list        TYPE sy-ucomm VALUE 'WB_NOT_USED_LIST',
779      swbm_c_fc_object_list          TYPE sy-ucomm VALUE 'WB_OBJECT_LIST',  " there seems to be an inconsistency
780      " with database table WBACTIONS, where the value is 'WB_SHOW_OBJECT_LIST'
781      swbm_c_fc_okay                 TYPE sy-ucomm VALUE 'WB_OKAY',
782      swbm_c_fc_online_manual        TYPE sy-ucomm VALUE 'WB_ONLINE_MANUAL',
783      swbm_c_fc_options              TYPE sy-ucomm VALUE 'WB_OPTIONS',
784      swbm_c_fc_organizer            TYPE sy-ucomm VALUE 'WB_ORGANIZER',
785      swbm_c_fc_other_object         TYPE sy-ucomm VALUE 'WB_OTHER_OBJECT',
786      swbm_c_fc_print                TYPE sy-ucomm VALUE 'WB_PRINT',
787      swbm_c_fc_persistence          TYPE sy-ucomm VALUE 'WB_PERSISTENCE',
788      swbm_c_fc_propagate            TYPE sy-ucomm VALUE 'WB_PROPAGATE',
789      swbm_c_fc_proxy_editor         TYPE sy-ucomm VALUE 'WB_PROXY_EDITOR',
790      swbm_c_fc_proxy_generator      TYPE sy-ucomm VALUE 'WB_PROXY_GENERATOR',
791      swbm_c_fc_log                  TYPE sy-ucomm VALUE 'WB_SHOW_LOG',
792      swbm_c_fc_realize              TYPE sy-ucomm VALUE 'WB_REALIZE',
793      swbm_c_fc_realize_all          TYPE sy-ucomm VALUE 'WB_REALIZE_ALL',
794      swbm_c_fc_redefine             TYPE sy-ucomm VALUE 'WB_REDEFINE',
795      swbm_c_fc_undo_redefine        TYPE sy-ucomm VALUE 'WB_UNDO_REDEF',
796      swbm_c_fc_refresh              TYPE sy-ucomm VALUE 'WB_REFRESH',
797      swbm_c_fc_release              TYPE sy-ucomm VALUE 'WB_RELEASE',
798      swbm_c_fc_rename               TYPE sy-ucomm VALUE 'WB_RENAME',
799      swbm_c_fc_rep_browser          TYPE sy-ucomm VALUE 'WB_REP_BROWSER',
800      swbm_c_fc_req_add_user         TYPE sy-ucomm VALUE 'WB_REQ_ADD_USER',
801      swbm_c_fc_request_trace        TYPE sy-ucomm VALUE 'WB_REQ_TRACE',
802      swbm_c_fc_reuse_library        TYPE sy-ucomm VALUE 'WB_REUSE_LIB',
803      swbm_c_fc_save                 TYPE sy-ucomm VALUE 'WB_SAVE',
804      swbm_c_fc_save_enh             TYPE sy-ucomm VALUE 'WB_SAVE_ENH',
805      swbm_c_fc_save_as              TYPE sy-ucomm VALUE 'WB_SAVE_AS',
806      swbm_c_fc_search_object        TYPE sy-ucomm VALUE 'WB_SEARCH_OBJECT',
807      swbm_c_fc_send_request         TYPE sy-ucomm VALUE 'WB_SEND_REQUEST',
808      swbm_c_fc_select_object        TYPE sy-ucomm VALUE 'WB_SELECT_OBJECT',
809      swbm_c_fc_shift                TYPE sy-ucomm VALUE 'WB_SHIFT',
810      swbm_c_fc_show_cue_card        TYPE sy-ucomm VALUE 'WB_CUE_CARD',
811      swbm_c_fc_space                TYPE sy-ucomm VALUE '    ',
812      swbm_c_fc_st_design            TYPE sy-ucomm VALUE 'WB_ST_DESIGN',    " call simple transformation designer
813      swbm_c_fc_st_display           TYPE sy-ucomm VALUE 'WB_ST_DISPLAY',
814      swbm_c_fc_tadir_edit           TYPE sy-ucomm VALUE 'WB_TADIR_EDIT',
815      swbm_c_fc_tadir_edit_with_doc  TYPE sy-ucomm VALUE 'WB_TADIR_WITH_DOC',
816      swbm_c_fc_testworkbench        TYPE sy-ucomm VALUE 'WB_TESTMNGR',
817      swbm_c_fc_testcat              TYPE sy-ucomm VALUE 'WB_TESTCAT',
818      swbm_c_fc_testplan             TYPE sy-ucomm VALUE 'WB_TESTPLAN',
819      swbm_c_fc_translation          TYPE sy-ucomm VALUE 'WB_TRANSLATION',
820      swbm_c_fc_transport            TYPE sy-ucomm VALUE 'WB_TRANSPORT',
821      swbm_c_fc_transport_with_doc   TYPE sy-ucomm VALUE 'WB_TRANSP_WITH_DOC',
822      swbm_c_fc_tree_refresh         TYPE sy-ucomm VALUE 'WB_TREE_REFRESH',
823      swbm_c_fc_undo                 TYPE sy-ucomm VALUE 'WB_UNDO',
824      swbm_c_fc_upload               TYPE sy-ucomm VALUE 'WB_UPLOAD',
825      swbm_c_fc_uml_generate         TYPE sy-ucomm VALUE 'WB_UML_GENERATE',
826      swbm_c_fc_version_create       TYPE sy-ucomm VALUE 'WB_VERSION_CREATE',
827      swbm_c_fc_versions             TYPE sy-ucomm VALUE 'WB_VERSIONS',
828      swbm_c_fc_dispvers             TYPE sy-ucomm VALUE 'WB_DISPVERS',
829      swbm_c_fc_disp_pack_browser    TYPE sy-ucomm VALUE 'WB_DISPPACK',
830      swbm_c_fc_disp_obj_propag      TYPE sy-ucomm VALUE 'WB_DISPPROP',
831      swbm_c_fc_wcf_controls         TYPE sy-ucomm VALUE 'WB_WCF_CONTROLS',
832      swbm_c_fc_web_repository       TYPE sy-ucomm VALUE 'WB_WEB_REP',
833      swbm_c_fc_where_used_list      TYPE sy-ucomm VALUE 'WB_WHERE_USED_LIST',
834      swbm_c_fc_ppms                 TYPE sy-ucomm VALUE 'WB_PPMS',
835      swbm_c_fc_worklist_add_object  TYPE sy-ucomm VALUE 'WB_WL_ADD_OBJECT',
836      swbm_c_fc_worklist_edit        TYPE sy-ucomm VALUE 'WB_WL_SHOW',
837      swbm_c_fc_worklist_hide        TYPE sy-ucomm VALUE 'WB_WL_HIDE',
838      swbm_c_fc_workingarea_copy     TYPE sy-ucomm VALUE 'WB_WORKINGAREA_COPY',  " copy the list of inactive objects
839      swbm_c_fc_workingarea_dele     TYPE sy-ucomm VALUE 'WB_WORKINGAREA_DELE',  " delete the list of inactive objects
840      swbm_c_fc_abap_unit            TYPE sy-ucomm VALUE 'WB_MODULE_TEST',
841      swbm_c_fc_abap_unit_with_cov   TYPE sy-ucomm VALUE 'WB_MODULE_TEST_COV',
842      swbm_c_fc_abap_unit_with_bch1  TYPE sy-ucomm VALUE 'WB_MODULE_TEST_TRUN1',
843      swbm_c_fc_abap_unit_with_bch2  TYPE sy-ucomm VALUE 'WB_MODULE_TEST_TRUN2',
844      swbm_c_fc_wdy_wzd_start        TYPE sy-ucomm VALUE 'WB_WDY_WZD_START',
845      swbm_c_fc_wdy_show_using       TYPE sy-ucomm VALUE 'WB_WDY_SHOW_USING',   " test (Web Dynpro Component Usage)
846      swbm_c_fc_wdy_show_used        TYPE sy-ucomm VALUE 'WB_WDY_SHOW_USED',    " test (Web Dynpro Component Usage)
847      swbm_c_fc_wdy_config_contr     TYPE sy-ucomm VALUE 'WB_WDY_CONFIG_CONTR', " Web Dynpro: Set as Configuration Controller
848      swbm_c_fc_ws_wzd_start         TYPE sy-ucomm VALUE 'WB_WS_WZD_START',
849      swbm_c_fc_col_disp_graphic     TYPE sy-ucomm VALUE 'WB_DISPGRAPH',     " Enterprise Services: Display Graphic for Business Object
850      swbm_c_fc_col_edit_graphic     TYPE sy-ucomm VALUE 'WB_EDITGRAPH',     " Enterprise Services: Edit Graphic for Business Object
851      swbm_c_fc_ws_wizard_fugr       TYPE sy-ucomm VALUE 'WB_WS_WIZARD_FUGR',
852      swbm_c_fc_ws_wizard_func       TYPE sy-ucomm VALUE 'WB_WS_WIZARD_FUNC',
853      swbm_c_fc_wdy_next             TYPE sy-ucomm VALUE 'WB_WDY_NEXT',       " Web Dynpro Text Browser: show next object to be processed
854      swbm_c_fc_wdy_filter           TYPE sy-ucomm VALUE 'WB_WDY_FILTER',     " Web Dynpro Text Browser: only show objects to be processed
855      swbm_c_fc_enha_intf            TYPE sy-ucomm VALUE 'WB_ENHA_INTF',
856      swbm_c_fc_record_ecatt         TYPE sy-ucomm VALUE 'WB_RECORD_ECATT',
857      swbm_c_fc_implement            TYPE sy-ucomm VALUE 'WB_IMPLEMENT',
858      swbm_c_fc_enhance              TYPE sy-ucomm VALUE 'WB_ENHANCE',
859      swbm_c_fc_check_show_detail    TYPE sy-ucomm VALUE 'WB_CHKSHOWDET',
860      swbm_c_fc_rfac_rename          TYPE sy-ucomm VALUE 'WB_RFAC_RENAME',
861      swbm_c_fc_rfac_get_types       TYPE sy-ucomm VALUE 'WB_RFAC_GET_TYPES',
862      swbm_c_fc_rfac_undo            TYPE sy-ucomm VALUE 'WB_RFAC_UNDO',
863      swbm_c_fc_rfac_redo            TYPE sy-ucomm VALUE 'WB_RFAC_REDO',
864      swbm_c_fc_rfac_dele_datadecl   TYPE sy-ucomm VALUE 'WB_RFAC_DELE_DATADEC',
865      swbm_c_fc_rfac_show_preview    TYPE sy-ucomm VALUE 'WB_RFAC_SHOW_PREVIEW',
866      swbm_c_fc_upgrade              TYPE sy-ucomm VALUE 'WB_UPGRADE',
867      swbm_c_fc_upgrade_enh          TYPE sy-ucomm VALUE 'WB_UPGRADE_ENH',
868      swbm_c_fc_upgrade_spau         TYPE sy-ucomm VALUE 'WB_UPGRADE_SPAU',
869      swbm_c_fc_adjust_del_flag      TYPE sy-ucomm VALUE 'WB_DELFLAG',
870      swbm_c_fc_ide_actions          TYPE sy-ucomm VALUE 'WB_IDE_ACTIONS'
871      .
872
873    ************************************************************************
874    *******************ERROR-CODES for WB Programs**************************
875    ************************************************************************
876    CONSTANTS:
877      swbm_c_er_no_error            TYPE seu_ercode VALUE 0,
878      swbm_c_er_action_cancelled    TYPE seu_ercode VALUE 1,
879      swbm_c_er_object_not_found    TYPE seu_ercode VALUE 2,
880      swbm_c_er_op_not_supported    TYPE seu_ercode VALUE 3,
881      swbm_c_er_permission_failure  TYPE seu_ercode VALUE 4,
882      swbm_c_er_wrong_program_state TYPE seu_ercode VALUE 5,
883      swbm_c_er_error_occured       TYPE seu_ercode VALUE 6,
884      swbm_c_er_same_request        TYPE seu_ercode VALUE 7,
885      swbm_c_er_unknown_error       TYPE seu_ercode VALUE 99.
886
887    ************************************************************************
888    *******************ERROR-TYPES for CHECKLIST****************************
889    ************************************************************************
890
891    CONSTANTS:
892      swbm_c_message_type_error      TYPE c LENGTH 1 VALUE 'E',
893      swbm_c_message_type_warning    TYPE c LENGTH 1 VALUE 'W',
894      swbm_c_message_type_info       TYPE c LENGTH 1 VALUE 'I',
895      swbm_c_message_type_bapi_e     TYPE c LENGTH 1 VALUE 'B',
896      swbm_c_message_type_bapi_w     TYPE c LENGTH 1 VALUE 'C',
897      swbm_c_message_free_arrangemnt TYPE c LENGTH 1 VALUE '-'.
898
899    ************************************************************************
900    *******************Types of general use*********************************
901    ************************************************************************
902    CONSTANTS:
903      swbm_c_max_line_width     TYPE i VALUE 72,
904      swbm_version_active       TYPE r3state VALUE 'A',
905      swbm_version_party_active TYPE r3state VALUE 'P',
906      swbm_version_inactive     TYPE r3state VALUE 'I',
907      swbm_version_new          TYPE r3state VALUE 'N',
908      swbm_version_dirty        TYPE r3state VALUE 'D',
909      swbm_version_working_area TYPE r3state VALUE ' '.
910
911    ************************************************************************
912    *******************Activation environment*******************************
913    ************************************************************************
914    CONSTANTS:
915      BEGIN OF swbm_c_activation_environment,
916        aie                 TYPE string VALUE 'aie',
917        workbench           TYPE string VALUE space, "Default
918        force_db_conversion TYPE string VALUE 'force_db_conversion', "used for ADT DB utility
919      END OF swbm_c_activation_environment.
920    CONSTANTS:
921      BEGIN OF swbm_c_activation_phase,
922        dictionary     TYPE wb_activation_phase VALUE 'D',
923        non_dictionary TYPE wb_activation_phase VALUE space,
924      END OF swbm_c_activation_phase.
925
926    ***********************************************************************
927    **********************Lifecycle operation******************************
928    ***********************************************************************
929    CONSTANTS:
930      BEGIN OF swbm_c_op_lifecycle,
931        deletion   TYPE seu_lifecycle_operation VALUE 'DELETION',
932        activation TYPE seu_lifecycle_operation VALUE 'ACTIVATION',
933      END OF swbm_c_op_lifecycle.
*--- End of %_CSWBM - 933 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CSXRT                                   Level 1    Page 11
Object           ZFM_RFFMEP1BX_FOR3YEARS_CALL              Lines 65
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:50
----------------------------------------------------------------------------------------------------
1      TYPE-POOL sxrt .
2
3      TYPES:     sxrt_boolean(1) TYPE c,
4                 sxrt_prefix(10),
5                 sxrt_symbol_type(1),
6                 sxrt_clif_prefix TYPE sxrt_prefix,
7                 sxrt_method_prefix TYPE sxrt_prefix.
8
9      TYPES: BEGIN OF sxrt_flt_cache_struct,
10              flt_name    LIKE v_ext_imp-flt_val,
11              order_num   TYPE i,
12              method_name LIKE sxc_impswh-metho_name,
13              imp_class   LIKE sxc_class-imp_class,
14              imp_switch  LIKE sxc_impswh-imp_switch,
15              valid       TYPE sxrt_boolean,
16              obj         TYPE REF TO object,
17              eo_object   TYPE REF TO cl_fobu_method_evaluation,
18            END OF sxrt_flt_cache_struct.
19     TYPES: sxrt_flt_cache_tab TYPE SORTED TABLE OF
20                 sxrt_flt_cache_struct
21                 WITH UNIQUE KEY flt_name order_num method_name imp_class.
22     TYPES: BEGIN OF sxrt_exit_tab_struct,
23              imp_name    LIKE v_ext_imp-imp_name,
24              inter_name  LIKE v_ext_imp-inter_name,
25              flt_val     LIKE v_ext_imp-flt_val,
26              imp_class   LIKE v_ext_imp-imp_class,
27              method_name LIKE sxc_impswh-metho_name,
28              imp_switch  LIKE sxc_impswh-imp_switch,
29              active      LIKE v_ext_imp-active,
30              obj         TYPE REF TO object,
31              released    TYPE sxrt_boolean,
32              layer       LIKE sxc_attr-layer,
33              order_num   TYPE i,
34            END OF sxrt_exit_tab_struct.
35     TYPES: sxrt_exit_tab TYPE sxrt_exit_tab_struct OCCURS 0.
36     TYPES: sxrt_ext_imp_struct LIKE v_ext_imp,
37            sxrt_ext_imp_tab TYPE sxrt_ext_imp_struct OCCURS 0.
38
39     TYPES: BEGIN OF sxrt_filter_struct,
40              flt_val LIKE rsexscrn-flt_val,
41              fltval_txt TYPE flt_text,
42            END OF sxrt_filter_struct.
43     TYPES: sxrt_filter_table TYPE sxrt_filter_struct OCCURS 0.
44
45     TYPES: BEGIN OF sxrt_layer,
46              layer LIKE sxc_attr-layer,
47            END OF sxrt_layer.
48     TYPES: sxrt_layer_table TYPE STANDARD TABLE OF sxrt_layer
49           WITH KEY layer.
50
51     CONSTANTS: sxrt_true  TYPE sxrt_boolean VALUE 'X',
52                sxrt_false TYPE sxrt_boolean VALUE space.
53     CONSTANTS: sxrt_symbol_wildcard  TYPE sxrt_symbol_type VALUE '*',
54                sxrt_symbol_separator TYPE sxrt_symbol_type VALUE '|'.
55
56     CONSTANTS:
57         sxrt_nor_meth_prefix   TYPE sxrt_method_prefix VALUE 'ME_',
58         sxrt_exm_meth_prefix   TYPE sxrt_method_prefix VALUE 'EM_',
59         sxrt_def_meth_prefix   TYPE sxrt_method_prefix VALUE 'DF_',
60         sxrt_exit_class_prefix TYPE sxrt_clif_prefix VALUE 'CL_EX_',
61         sxrt_exit_intf_prefix  TYPE sxrt_clif_prefix VALUE 'IF_EX_',
62         sxrt_coco_class_prefix TYPE sxrt_clif_prefix VALUE 'CL_EX_CC_',
63         sxrt_imp_class_prefix  TYPE sxrt_clif_prefix VALUE 'CL_IM_',
64         sxrt_def_imp_class_prefix  TYPE sxrt_clif_prefix VALUE 'CL_DEF_IM_',
65         sxrt_exm_imp_class_prefix  TYPE sxrt_clif_prefix VALUE 'CL_EXM_IM_'.
*--- End of %_CSXRT - 65 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  <FIESEL>                                  Level 1    Page 12
Object           ZFM_RFFMEP1BX_FOR3YEARS_CALL              Lines 7
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:50
----------------------------------------------------------------------------------------------------
1      ***INCLUDE <FIESEL>.
2
3      TYPE-POOLS RSFS.
4
5      DATA: BEGIN OF COMMON PART %_FIELD_SEL.
6        DATA SELECT_FIELDS TYPE RSFS_FIELDS.
7      DATA: END   OF COMMON PART %_FIELD_SEL.
*--- End of <FIESEL> - 7 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  <REPINI>                                  Level 1    Page 13
Object           ZFM_RFFMEP1BX_FOR3YEARS_CALL              Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:50
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
Generated incl.  <SYSINI>                                  Level 1    Page 14
Object           ZFM_RFFMEP1BX_FOR3YEARS_CALL              Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:50
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
Generated incl.  <SYSSEL>                                  Level 1    Page 15
Object           ZFM_RFFMEP1BX_FOR3YEARS_CALL              Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:50
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
Generated incl.  DBFMFSEL                                  Level 1    Page 16
Object           ZFM_RFFMEP1BX_FOR3YEARS_CALL              Lines 641
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:50
----------------------------------------------------------------------------------------------------
1      *----------------------------------------------------------------------*
2      * INCLUDE DBFMFSEL
3      * It will be automatically included into the database program.
4      *----------------------------------------------------------------------*
5
6      * Enable DYNAMIC SELECTIONS for selected nodes:
7       selection-screen dynamic selections for table fkrs.
8       selection-screen dynamic selections for table ffnd.
9       selection-screen dynamic selections for table fctr.
10      selection-screen dynamic selections for table fpos.
11      selection-screen dynamic selections for table fnct.
12      selection-screen dynamic selections for table fmaa.
13      selection-screen dynamic selections for table fmaarel id rel.
14      selection-screen dynamic selections for table fmsnrel.
15      selection-screen dynamic selections for table fmtox.
16      selection-screen dynamic selections for table fmoix.
17      selection-screen dynamic selections for table fmfix.
18      selection-screen dynamic selections for table fmbkpf.
19      selection-screen dynamic selections for table fmcox.
20      selection-screen dynamic selections for table fmcfx.
21     * Budget
22      selection-screen dynamic selections for table fvsn.
23      selection-screen dynamic selections for table bpbpx.
24      selection-screen dynamic selections for table epbp.
25      selection-screen dynamic selections for table bpbyx.
26      selection-screen dynamic selections for table epby.
27      selection-screen dynamic selections for table bpbtx.
28      selection-screen dynamic selections for table epbt.
29
30     * Enable FIELD SELECTION for selected nodes:
31      selection-screen field selection for table fkrs.
32      selection-screen field selection for table ffnd.
33      selection-screen field selection for table fctr.
34      selection-screen field selection for table fpos.
35      selection-screen field selection for table fnct.
36      selection-screen field selection for table fmaa.
37      selection-screen field selection for table fmaarel.
38      selection-screen field selection for table fmsnrel.
39      selection-screen field selection for table fmtox.
40      selection-screen field selection for table fmoix.
41      selection-screen field selection for table fmfix.
42      selection-screen field selection for table fmbkpf.
43      selection-screen field selection for table fmcox.
44      selection-screen field selection for table fmcfx.
45
46     SELECTION-SCREEN FUNCTION KEY 1 FOR TABLE fmf_sel_screen.
47     SELECTION-SCREEN FUNCTION KEY 2 FOR TABLE fmf_sel_screen id 002.
48
49     * "/ Originalvorzeichen in Kommunen-Reports fuer Budget, wenn 'X'
50     parameters: p_sign_k like fmdy-xfeld for node fkrs
51                                          no-display.
52     *---------------------------------------------------------------------
53     * "/ Begin of block FM area
54     selection-screen begin of block fikrs with frame title text-299.
55
56        selection-screen begin of line.
57
58        selection-screen comment 1(20) text-031
59                                 for field s_fikrs
60                                 modif id fik.
61
62     *  "/ FM area
63        select-options: s_fikrs for fkrs-fikrs
64                                matchcode object fikr
65                                memory id fik
66                                modif id fik.
67
68        selection-screen end of line.
69
70     selection-screen end of block fikrs.
71     *---------------------------------------------------------------------
72
73     * "/ Block FM account assignment
74     selection-screen begin of block hhmk with frame title text-300.
75     * "/ Grant
76       selection-screen begin of block fgmg_gr.
77
78         selection-screen begin of line.
79
80         selection-screen comment 1(20) text-024
81                                  for field s_grant
82                                  modif id gmg.
83
84         select-options: s_grant  for fmf_sel_screen-grant_nbr
85                                  memory id gm_grant_nbr
86                                  modif id gmg.
87
88         selection-screen position 78 for node fmf_sel_screen.
89
90         selection-screen comment 79(11) text-019
91                                  for field  p_gr_grp
92                                  modif id gmg.
93
94         parameters: p_gr_grp     type grpname
95                                  for node fmf_sel_screen
96                                  memory id grant_group
97                                  modif id gmg
98                                  value-request.
99
100        selection-screen end of line.
101
102      selection-screen end of block fgmg_gr.
103
104    * "/ Fund
105      selection-screen begin of block ffnd_gr.
106
107        selection-screen begin of line.
108
109        selection-screen comment 1(20) text-020
110                                 for field s_fonds
111                                 modif id fic.
112
113        select-options: s_fonds  for fmf_sel_screen-fonds
114                                 value-request
115                                 memory id fic
116                                 modif id fic.
117
118        selection-screen position 78 for node fmf_sel_screen.
119
120        selection-screen comment 79(11) text-019
121                                 for field  p_fu_grp
122                                 modif id fic.
123
124        parameters: p_fu_grp     type grpname
125                                 for node fmf_sel_screen
126                                 memory id fog
127                                 modif id fic
128                                 value-request.
129
130        selection-screen end of line.
131
132        selection-screen skip 1  for table fmf_sel_screen id fic.
133
134      selection-screen end of block ffnd_gr.
135
136    * "/ Budget period
137      selection-screen begin of block fbpd_gr.
138
139        selection-screen begin of line.
140
141        selection-screen comment 1(20) text-041
142                                 for field s_budper
143                                 modif id bpd.
144
145        select-options: s_budper for fmf_sel_screen-budget_pd
146                                 memory id budper
147                                 modif id bpd.
148
149        selection-screen position 78 for node fmf_sel_screen.
150
151        selection-screen comment 79(11) text-019
152                                 for field  p_bp_grp
153                                 modif id bpd.
154
155        parameters: p_bp_grp     type grpname
156                                 for node fmf_sel_screen
157                                 memory id BUDGET_PERIOD_GROUP
158                                 modif id bpd
159                                 value-request.
160
161        selection-screen end of line.
162
163        selection-screen skip 1  for table fmf_sel_screen id bpd.
164
165      selection-screen end of block fbpd_gr.
166
167
168      selection-screen begin of block fund_center.
169    *   "/ Funds center
170        selection-screen begin of block fctr_gr.
171
172          selection-screen begin of line.
173
174          selection-screen comment 1(20) text-022
175                                   for field s_fictr
176                                   modif id fst.
177
178          select-options s_fictr   for fmf_sel_screen-fictr
179                                   value-request
180                                   memory id fis
181                                   modif id fst.
182
183          selection-screen position 78 for node fmf_sel_screen.
184
185          selection-screen comment 79(11) text-019
186                                   for field  p_fc_grp
187                                   modif id fst.
188
189          parameters: p_fc_grp     type grpname
190                                   for node fmf_sel_screen
191                                   memory id fictr_group
192                                   modif id fst
193                                   value-request.
194
195          selection-screen end of line.
196
197        selection-screen end of block fctr_gr.
198
199        selection-screen begin of line.
200
201        selection-screen comment 1(23) text-026
202                                 for field p_kdate
203                                 modif id fsk.
204
205    *   "/ Key date for fund center, measure and grant ( Stichtag )
206        PARAMETERS: p_kdate LIKE fmf_sel_screen-keydate
207                            FOR TABLE fmf_sel_screen
208                            MEMORY ID fsk
209                            MODIF ID fsk.
210
211        selection-screen end of line.
212
213        selection-screen begin of line.
214
215        selection-screen comment 1(23) text-027
216                                 for field p_cvarnt
217                                 modif id fsv.
218
219    *   "/ Funds center hierarchy variant
220        parameters p_cvarnt like fctr-hivarnt
221                            for table fmf_sel_screen
222                            memory id fhv
223                            modif id fsv.
224
225        selection-screen end of line.
226
227        selection-screen skip 1 for table fmf_sel_screen id fsv.
228
229      selection-screen end of block fund_center.
230
231      selection-screen begin of block commitment_item.
232    *   "/ Commitment item
233        selection-screen begin of block fpex_gr.
234
235          selection-screen begin of line.
236
237          selection-screen comment 1(20) text-021
238                                   for field s_fipex
239                                   modif id fpx.
240
241          select-options s_fipex   for fmf_sel_screen-fipex
242                                   value-request
243                                   memory id fps
244                                   modif id fpx.
245
246          selection-screen position 78 for node fmf_sel_screen.
247
248          selection-screen comment 79(11) text-019
249                                   for field  p_ci_grp
250                                   modif id fpx.
251
252          parameters: p_ci_grp     type grpname
253                                   for node fmf_sel_screen
254                                   memory id fipex_group
255                                   modif id fpx
256                                   value-request.
257
258          selection-screen end of line.
259
260        selection-screen end of block fpex_gr.
261
262        selection-screen begin of line.
263
264        selection-screen comment 1(23) text-028
265                                 for field p_gjahr
266                                 modif id fvj.
267
268    *   "/ Fiscal year of commitment items
269        parameters p_gjahr like fmf_sel_screen-gjahr
270                           for table fmf_sel_screen
271                           memory id fvj
272                           modif id fvj.
273    "                      obligatory.
274
275        selection-screen end of line.
276
277        selection-screen begin of line.
278
279        selection-screen comment 1(23) text-029
280                                 for field p_varnt
281                                 modif id fva.
282
283    *   "/ Commitment item variant
284        parameters p_varnt like fmf_sel_screen-varnt
285                           for table fmf_sel_screen
286                           matchcode object fm_varnt
287                           memory id fvt
288                           modif id fva
289                           default '000'.
290
291      selection-screen end of line.
292
293      selection-screen end of block commitment_item.
294
295      selection-screen skip 1 for table fmf_sel_screen.
296
297    * "/ Functional area
298      selection-screen begin of block fnct_gr.
299
300        selection-screen begin of line.
301
302        selection-screen comment 1(20) text-023
303                                 for field s_farea
304                                 modif id fbe.
305
306        select-options: s_farea  for fmf_sel_screen-farea
307                                 matchcode object h_tfkb
308                                 memory id fbe
309                                 modif id fbe.
310
311        selection-screen position 78 for node fmf_sel_screen.
312
313        selection-screen comment 79(11) text-019
314                                 for field  p_fa_grp
315                                 modif id fbe.
316
317        parameters: p_fa_grp     type grpname
318                                 for node fmf_sel_screen
319                                 memory id fug
320                                 modif id fbe
321                                 value-request.
322
323        selection-screen end of line.
324
325      selection-screen end of block fnct_gr.
326
327    * "/ Funded program
328      selection-screen begin of block fmas_gr.
329
330        selection-screen begin of line.
331
332        selection-screen comment 1(20) text-025
333                                 for field s_meas
334                                 modif id mas.
335
336        select-options: s_meas   for fmf_sel_screen-measure
337    *---------------F4-Help is integrated via search help on the field MEASURE in the structure FMAA
338    *                            matchcode object FM_MEASURE_GENERIC
339                                 memory id FM_MEASURE
340                                 modif id mas.
341
342        selection-screen position 78 for node fmf_sel_screen.
343
344        selection-screen comment 79(11) text-019
345                                 for field  p_fd_grp
346                                 modif id mas.
347
348        parameters: p_fd_grp     type grpname
349                                 for node fmf_sel_screen
350                                 memory id fdprg_group
351                                 modif id mas
352                                 value-request.
353
354        selection-screen end of line.
355
356      selection-screen end of block fmas_gr.
357
358      selection-screen begin of line.
359
360      selection-screen comment 1(20) text-030
361                               for field s_deck
362                               modif id fdr.
363    * "/ Cover pool
364      select-options: s_deck for fmf_sel_screen-deckrng
365                             memory id fdr
366                             modif id fdr.
367
368      selection-screen end of line.
369
370    * "/ Flag: uperordinate FM accounts assignments
371      parameters: p_fmaaup like fmdy-p_fmaaup
372                           for table fmaa
373                           modif id fup.
374    * "/ Flag: subordinate FM account assignments
375      parameters: p_fmaadn like fmdy-p_fmaadn
376                           for table fmaa
377                           modif id fdn.
378    * "/ Flag: hierarchy order
379      parameters: p_fmahie like fmdy-p_fmahie
380                           for table fmaa
381                           modif id fhs.
382    * "/ Flag: only booking master data
383      parameters p_stamm   like fmfdynpro-p_stamm
384                           for table fmaa default 'X'
385                           modif id sta.
386
387    selection-screen end of block hhmk.
388
389    *  "/ Flag: without authority check
390       parameters: p_noauth like fmdy-p_fmaaup
391                          for table fmf_sel_screen
392                          default SPACE
393                          no-display.
394    *  "/ Flag: only transaction data with selected master data
395       parameters: p_trans type xfeld
396                          for table fmf_sel_screen
397                          default 'X'
398                          no-display.
399    *  "/ Hidden selection criteria
400       parameters: p_others type xfeld
401                          for table fmf_sel_screen
402                          default SPACE
403                          no-display.
404    *--------------------------------------------------------------------*
405    *  Report currency                                                   *
406    *--------------------------------------------------------------------*
407    selection-screen begin of block curr with frame title text-301.
408       parameters: p_c_curr like fmdy-p_c_curr for table fmf_sel_screen
409                            modif id ccu,
410                   p_c_date like fmdy-p_c_date for table fmf_sel_screen
411                            modif id cda,
412                   p_c_type like tcurr-kurst   for table fmf_sel_screen
413                            modif id cty.
414    selection-screen end of block curr.
415    *--------------------------------------------------------------------*
416    * Commitment/Actuals - Totals and Line Items
417    *--------------------------------------------------------------------*
418    selection-screen begin of block charly with frame title text-304..
419
420       selection-screen begin of line.
421          selection-screen comment 1(31) text-040
422                                         for field p_fyr_fr
423    *                                     for table fmf_sel_screen
424                                         modif id sum.
425    *                 "/ Geschaeftsjahr von
426          parameters: p_fyr_fr type FM_GJAHR_AB
427                               for table fmf_sel_screen
428                               memory id FM_GJAHR_AB
429                               modif id sum,
430    *                 "/ Periode von
431                      p_per_fr like fmto-perio
432                               for table fmf_sel_screen
433                               memory id vpe
434                               modif id sum.
435          selection-screen comment 52(5) text-004
436                                         for field p_fyr_to
437    *                                     for table fmf_sel_screen
438                                         modif id sum.
439    *                 "/ Geschaeftsjahr bis
440          parameters: p_fyr_to type FM_GJAHR_BIS
441                               for table fmf_sel_screen
442                               memory id FM_GJAHR_BIS
443                               modif id sum,
444    *                 "/ Periode bis
445                      p_per_to like fmto-perio
446                               for table fmf_sel_screen
447                               memory id bpe
448                               modif id sum.
449       selection-screen end of line.
450    *  "/ Parameter for working without period in FMTOX
451    *  "/ P_PERTOT = SPACE  periods are filled in FMTOX
452    *  "/ P_PERTOT = 'X'    periodical amounts are summarized
453    *  "/                   period is always '000'
454    *  "/                   parameters p_per_fr, p_per_to are ignored
455       parameters: P_PERTOT like fmdy-xfeld
456                   for table fmtox
457                   no-display.
458    selection-screen end of block charly.
459
460    *--------------------------------------------------------------------*
461    *  Year end closing                                                  *
462    *--------------------------------------------------------------------*
463
464    *  "/ Fiscal year for year end closing
465    selection-screen skip 1 for table fmcfx.
466    parameters: p_cf_gja like fmcfx-gjahr
467                         for table fmcfx
468                         memory id gjr
469                         obligatory.
470
471    * "/ Auswahl: Echtlauf, Obligo Testlauf oder vorselektiertes Budget
472    selection-screen skip 1 for table fmcfx.
473    parameters: p_cf_ab  like fmdy-p_cf_ab
474                         radiobutton group fmcf default 'X'
475                         for table fmcfx
476                         modif id cf1,
477                p_cf_abt like fmdy-p_cf_abt
478                         radiobutton group fmcf
479                         for table fmcfx
480                         modif id cf2,
481                p_cf_abs like fmdy-p_cf_abs
482                         radiobutton group fmcf
483                         for table fmcfx
484                         modif id cf3.
485
486    *--------------------------------------------------------------------*
487    * FMAA Relationen
488    *--------------------------------------------------------------------*
489    selection-screen begin of block rel with frame title text-302.
490
491    *            "/ Fiscal year of assignment
492    parameters:  p_gjrel    like fmdeckhk-gjahr
493                            for table fmaarel
494                            modif id fjr
495                            memory id fvj.
496
497    * "/ Deckungsarten
498    *            "/ Budgeterhöhende Einnahmen
499     parameters: p_ud       like fmfdynpro-p_ud
500                            as checkbox
501                            for table fmaarel
502                            modif id da1
503                            default 'X',
504    *            "/ Einseitige DF
505                 p_ed       like fmfdynpro-p_ed
506                            as checkbox
507                            for table fmaarel
508                            modif id da2
509                            default 'X',
510    *            "/ Deckungsring
511                 p_gd       like fmfdynpro-p_gd
512                            as checkbox
513                            for table fmaarel
514                            modif id da3
515                            default 'X',
516    *            "/ Einnahmendeckungsring
517                 p_rp       like fmfdynpro-p_rp
518                            as checkbox
519                            for table fmaarel
520                            modif id da4
521                            default 'X'.
522
523    selection-screen end of block rel.
524
525    * "/ P_ONLY_R = 'X'   => Only master data from Deckungsfähigkeit tables
526    * "/ P_ONLY_R = SPACE => all master data
527    parameters: p_only_r   like fmfdynpro-p_only_r
528                           for table fmaa
529                           modif id dax
530                           default SPACE       " !!! Changed TP 08.08. 'X'
531                           no-display.
532
533    *--------------------------------------------------------------------*
534    * Zugeordnete HHM-Kontierungen zu Sammelnachweisen
535    *--------------------------------------------------------------------*
536    selection-screen begin of block cen with frame title text-307.
537    * Zentral oder Dezentral
538     parameters: p_cent     like fmfdynpro-p_cent
539                            radiobutton group cent
540                            for table fmsnrel,
541                 p_dec      like fmfdynpro-p_dec
542                            radiobutton group cent
543                            for table fmsnrel.
544
545     parameters: p_gjsn     like FMSNRULE-gjahr
546                            for table fmsnrel
547                            modif id fjr
548                            memory id fjr.
549
550    selection-screen end of block cen.
551
552    *--------------------------------------------------------------------*
553    *  Budgetversion und Geschäftsjahr für Jahresbudget
554    *--------------------------------------------------------------------*
555
556    selection-screen begin of block budg with frame title text-305.
557    *  "/ Budgetversion
558    select-options: s_versn for fvsn-versn
559                            memory id bp2
560                            modif id fvs
561                            default '000'.
562    *  "/ Fiscal year for Yeardependent budget
563    select-options: s_gj_bud for bpbyx-gjahr
564                             memory id fvs
565                             modif id fvs.
566
567    selection-screen end of block budg.
568
569    *---------------------------------------------------------------------
570    * Flags for change of structure of logical database
571    *---------------------------------------------------------------------
572    selection-screen begin of block opt with frame title text-306.
573    * "/ read at first master data and then transactions data
574    SELECTION-SCREEN BEGIN OF LINE.
575     parameters: p_fmbud    like fmf_sel_screen-p_fmbud
576                            default 'X'
577                            radiobutton group stru
578                            modif id opt
579                            for table fmf_sel_screen.
580     selection-screen comment 4(30) text-401
581                            for field p_fmbud
582    *                        for table fmf_sel_screen
583                            modif id opt.
584    SELECTION-SCREEN POSITION 35 for node fmf_sel_screen.
585     "/ read at first transactions and then data master data
586     parameters: p_budfm    like fmf_sel_screen-p_budfm
587                            radiobutton group stru
588                            modif id opt
589                            for table fmf_sel_screen.
590     selection-screen comment 38(30) text-400
591                            for field p_budfm
592    *                        for table fmf_sel_screen
593                            modif id opt.
594    SELECTION-SCREEN END OF LINE.
595    * selection-screen skip 1 for table fmf_sel_screen id opt.
596
597    *  "/ Restriction of selected data
598       parameters: p_maxsel type FMMAXSEL
599                          for table fmf_sel_screen
600                          modif id op1
601                          default 0.
602    selection-screen end of block opt.
603
604    *--------------------------------------------------------------------*
605    * Related to calls from drill down reports
606    *--------------------------------------------------------------------*
607
608    *  "/ Flag: subordinate fund centers
609       parameters: p_fctrdn like fmdy-p_fctrdn
610                            for table fmaa
611                            no-display.
612
613    *  "/ Flag: subordinate commitment items
614       parameters: p_fposdn like fmdy-p_fposdn
615                            for table fmaa
616                            no-display.
617
618    *----------------------------------------------------------------------*
619    * Selektionsbildversion TRD - for Commitments/Actuals and Budget data  *
620    *    without Cover pool                                                *
621    *----------------------------------------------------------------------*
622    selection-screen begin of version trd text-300.
623
624    selection-screen exclude parameters:     p_stamm, p_only_r, p_fmahie,
625    p_ud, p_ed, p_gd, p_rp.
626    selection-screen exclude select-options: s_deck.
627    selection-screen exclude blocks rel.
628    selection-screen exclude ids rel.
629
630    selection-screen end   of version trd.
631
632    *---------------------------------------------------------------------
633    * Selections for archive access
634    *---------------------------------------------------------------------
635    SELECTION-SCREEN FUNCTION KEY 5 for table FMF_SEL_SCREEN.
636    PARAMETERS: p_object TYPE arch_obj-object FOR TABLE FMF_SEL_SCREEN
637                                                               NO-DISPLAY,
638                p_usedb  TYPE boole_d FOR TABLE FMF_SEL_SCREEN NO-DISPLAY,
639                p_usear  TYPE boole_d FOR TABLE FMF_SEL_SCREEN NO-DISPLAY,
640                p_useas  TYPE boole_d FOR TABLE FMF_SEL_SCREEN NO-DISPLAY.
641    SELECT-OPTIONS: so_files FOR FMF_SEL_SCREEN-ARCHIVEKEY NO-DISPLAY.
*--- End of DBFMFSEL - 641 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  LKBPPEQU                                  Level 1    Page 17
Object           ZFM_RFFMEP1BX_FOR3YEARS_CALL              Lines 635
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:50
----------------------------------------------------------------------------------------------------
1      *KI4K034435:BARTHR Budgetierung: GJW - beantragen und genehmigen
2      *KI4K065178:BARTHR Remove include IFIFMCON_BL in LKBPPTOP (AL0/ALN)
3      *----------------------------------------------------------------------*
4      *   Equates                                                            *
5      *----------------------------------------------------------------------*
6      *            ACHTUNG:  Verwendet in SAPLKBPP und SAPLKBPT und SAPLKBPS *
7      *                                   ========     ========     ========
8      *                       und SAPLKBPH
9      *                           ========                                   *
10     *----------------------------------------------------------------------*
11     DATA: NEW_CURRENCY VALUE 'X',
12           NO_VIEW_IN_OW(1).        "Sichten in Objektwährung verboten
13
14     *-----Availability check
15     DATA: FIFM_AVA_CHECK VALUE 'X'.
16
17     *-----Periodenbudget
18     DATA: FIFM_PERIOD VALUE 'X'.
19
20     * 4.02A (April 99): Flag eliminated
21     *----Cover eligibility
22     *DATA: G_COVER_EL LIKE FMDY-XFELD VALUE 'X'.
23
24
25
26     DATA:
27
28     *-------Werttypen extern Budgetprozessor-------------------------------*
29      L_WPLAN       LIKE BPGE-WRTTP VALUE  '01',     "Planung
30      L_WSPLAN      LIKE BPGE-WRTTP VALUE  '10',     "Planung stat.
31      L_WBUDGET     LIKE BPGE-WRTTP VALUE  '41',     "Budget
32      L_WCOMMIT     LIKE BPGE-WRTTP VALUE  '42',     "Verfügt
33      L_WRELEASE    LIKE BPGE-WRTTP VALUE  '45',     "Freigabe
34      L_WFCAFOR     LIKE BPGE-WRTTP VALUE  '73',     "Finanz carry forward
35      L_WPCAFOR     LIKE BPGE-WRTTP VALUE  '74',     "Finanz carry forward
36      L_WIBUDGET    LIKE BPGE-WRTTP VALUE  '47',     "Invest.budget
37      L_WIPLAN      LIKE BPGE-WRTTP VALUE  '48',     "Invest.plan
38     * Maßnahmenanforderungen                           BEGIN "E40K000891
39      L_WQPLAN      LIKE BPGE-WRTTP VALUE  '39',     "Plan
40      L_WQRPLAN     LIKE BPGE-WRTTP VALUE  '40',     "Plan, davon echte Inv.
41     *                                                  END   "E40K000891
42     *---------------------------------------------------------------------*
43     *---------------------------------------------------------------------*
44     * Maßnahmenanforderungen  Cash Flow             "ALRK027735
45      L_WQCFPLAN    LIKE BPGE-WRTTP VALUE  '52',     "Cash Flow
46
47     *-----finance budget payments
48      L_WFBUDGET    LIKE BPGE-WRTTP VALUE  '43',     "Finanzbudget
49      L_WFBUDRES    LIKE BPGE-WRTTP VALUE  '85',     "FBud reserviert
50      L_WFBUDNOTE   LIKE BPGE-WRTTP VALUE  '86',     "FBud vorgemerkt
51      L_WFCOMMIT    LIKE BPGE-WRTTP VALUE  '44',     "Finanzverfügt
52      L_WFRELEASE   LIKE BPGE-WRTTP VALUE  '46',     "Finanzfreigabe
53      L_WFRELRES    LIKE BPGE-WRTTP VALUE  '87',     "FFreigabe reserviert
54      L_WFRELNOTE   LIKE BPGE-WRTTP VALUE  '88',     "FFreigabe vorgemerkt
55      L_WFHRINT     LIKE BPGE-WRTTP VALUE  '9D',     "HR Integration
56
57      L_WPBUDGET    LIKE BPGE-WRTTP VALUE  '70',     "FBud Verpfl.
58      L_WPBUDRES    LIKE BPGE-WRTTP VALUE  '89',     "FBud Verpfl. res.
59      L_WPBUDNOTE   LIKE BPGE-WRTTP VALUE  '90',     "FBud Verpfl. vor.
60      L_WPCOMMIT    LIKE BPGE-WRTTP VALUE  '71',     "Finanzverfügt Verpfl.
61      L_WPRELEASE   LIKE BPGE-WRTTP VALUE  '72',     "FFreigabe Verpfl.
62      L_WPRELRES    LIKE BPGE-WRTTP VALUE  '91',     "FFreigabe Verpfl. res.
63      L_WPRELNOTE   LIKE BPGE-WRTTP VALUE  '92',     "FFreigabe Verpfl. vor.
64
65      L_WFFINPLAN   LIKE BPGE-WRTTP VALUE  '93',     "Kommunen: Finanzplan
66      L_WFBUDSTAT   LIKE BPGE-WRTTP VALUE  '94',     "Kommunen: Stat. Budget
67      L_WFBUDRERG   LIKE BPGE-WRTTP VALUE  '99',     "Kommunen: Rechnungserg.
68      L_WFSTAT      LIKE BPGE-WRTTP VALUE  '4A',     "Kom: Stat. Zahlungsbud.
69      L_WFBALBUD    LIKE BPGE-WRTTP VALUE  '4B',     "Saldenbudget
70      L_WFEXPBUD    LIKE BPGE-WRTTP VALUE  '4C',     "ZB: Ausg. Bud auf Epos
71      L_WFEXCBUD    LIKE BPGE-WRTTP VALUE  '7C',     "VB: Ausg. Bud auf Epos
72      L_WFRERGSTAT  LIKE BPGE-WRTTP VALUE  '9A',     "Kom: Stat. Rechngserg.
73      L_WFFIPLSTAT  LIKE BPGE-WRTTP VALUE  '9B',     "Kom: Stat. Finanzplan
74      L_WFBALFINPL  LIKE BPGE-WRTTP VALUE  '9C',     "Kom: Saldenfinanzplan
75      L_WFBUDTOT    LIKE BPGE-WRTTP VALUE  '9E',     "Kom: gen. GesKosten
76
77     *---------------------------------------------------------------------*
78      L_WACTUAL     LIKE BPGE-WRTTP VALUE  '04',     "Ist
79      L_WSACTUAL    LIKE BPGE-WRTTP VALUE  '11',     "Ist stat.
80      L_WPREQ       LIKE BPGE-WRTTP VALUE  '21',     "BANF-Obligo
81      L_WPORDER     LIKE BPGE-WRTTP VALUE  '22',     "BE-Obligo
82      L_WMATRES     LIKE BPGE-WRTTP VALUE  '23',     "Materialres
83      L_WFUNRES     LIKE BPGE-WRTTP VALUE  '24',     "Manuelles Obl
84      L_WOUTORDER   LIKE BPGE-WRTTP VALUE  '25',     "Restplan Auftr
85      L_WFIXPRICE   LIKE BPGE-WRTTP VALUE  '26',     "Festpreisobligo
86      L_WBESTAND    LIKE BPGE-WRTTP VALUE  '31',     "Bestand
87      L_WRUECK      LIKE BPGE-WRTTP VALUE  '32',     "Rueckstellungen
88      L_WOFFER      LIKE BPGE-WRTTP VALUE  '28',"Kundenangebot #EC NO_M_RISC3
89      L_WCLIENT     LIKE BPGE-WRTTP VALUE  '29',"Kundenauftrag #EC NO_M_RISC3
90      L_WREVE       LIKE BPGE-WRTTP VALUE  '01',     "Planerlöse
91      L_WFPLAN      LIKE BPGE-WRTTP VALUE  '62',     "Zhlng Finanzplan
92      L_WFPLANDP    LIKE BPGE-WRTTP VALUE  '6A',     "AnZhlng Finanzplan
93      L_WZPREQ      LIKE BPGE-WRTTP VALUE  '50',     "Zhlng BANF
94      L_WZPORDER    LIKE BPGE-WRTTP VALUE  '51',     "Zhlng BE
95      L_WZDPRQ      LIKE BPGE-WRTTP VALUE  '58',     "Zhlng AA
96      L_WZKDP       LIKE BPGE-WRTTP VALUE  '61',     "Zhlng AZ
97      L_WZGORE      LIKE BPGE-WRTTP VALUE  '52',     "Zhlng WE
98      L_WZINVC      LIKE BPGE-WRTTP VALUE  '54',     "Zhlng RE / AV
99      L_WZPAYM      LIKE BPGE-WRTTP VALUE  '57',     "Zhlng ZA
100     L_WZMRES      LIKE BPGE-WRTTP VALUE  '65',     "Zhlng MR
101     L_WVMRES      LIKE BPGE-WRTTP VALUE  '69',     "VerpflErmaechtigung MR
102     L_WZCOSK      LIKE BPGE-WRTTP VALUE  '95',     "Sek. Kostenbuch. CO
103     L_WCOPARK     LIKE BPGE-WRTTP VALUE  '60',     "parked CO documents
104
105    *       Vorgaenge auf interne BP-Tabellen
106    *       Daten dieser Vorgaenge werden nicht auf BP-Datenbanken abgelegt
107    *       -             Kennung interner Vorgang
108     L_VINTERN                     VALUE  '*'   , "interne Daten
109     L_VKSTA       LIKE BPGE-VORGA VALUE  '*KOA', "Koarten intern
110    * nicht mehr benötigt ab Release 4.0A, (Erlösartenplanwerte werden
111    * ab 4.0A zusammen mit Gesamtplanung verbucht)
112    * L_VKSTAV      LIKE BPGE-VORGA VALUE  '*KOV', "Koarten verteilt
113     L_VKSTE       LIKE BPGE-VORGA VALUE  '*KOE', "Erloese intern
114    * nicht mehr benötigt ab Release 4.0A, (Kostenartenplanwerte werden
115    * ab 4.0A zusammen mit Gesamtplanung verbucht)
116    * L_VKSTEV      LIKE BPGE-VORGA VALUE  '*KVE', "Erloese intern verteilt
117     L_VKALI       LIKE BPGE-VORGA VALUE  '*KAL', "Kalkul  intern
118     L_VADD        LIKE BPGE-VORGA VALUE  '*ADD', "additive Aufträge
119     L_VADG        LIKE BPGE-VORGA VALUE  '*ADG', "add. Auftr. gesamt
120     L_VADK        LIKE BPGE-VORGA VALUE  '*ADK', "add. Auftr. kumuliert
121     L_VSTAT       LIKE BPGE-VORGA VALUE  '*STA', "stat. Kennzahlen
122     L_VCUORDER    LIKE BPGE-VORGA VALUE  '*SDI', "Kundenauftragswert
123     L_VBUD_CF     LIKE BPGE-VORGA VALUE  '*CFO', "InvPg CF org
124     L_VBN0_CF     LIKE BPGE-VORGA VALUE  '*CFS', "InvPg CF suppl
125     L_VBR0_CF     LIKE BPGE-VORGA VALUE  '*CFR', "InvPg CF ret
126     L_VFPL        LIKE BPGE-VORGA VALUE  '*FPL', "ab 4.0A Fakturierungsplan
127     L_VPREL       LIKE BPGE-VORGA VALUE  '*!xx', "Vorerfassung
128     L_VPRES       LIKE BPGE-VORGA VALUE  '*?xx', "Vorerfassung reserviert
129     L_VFMHR       LIKE BPGE-VORGA VALUE  '*FHR',
130
131    *       Vorgaenge auf BP-Dateien und interne BP-Tabellen
132    *       Daten dieser Vorgaenge werden auf BP-Datenbanken abgelegt
133    *       -             Budget
134     L_VBUD        LIKE BPGE-VORGA VALUE  'KBUD',
135    *       -             Budget anzeigen
136     L_VABUD       LIKE BPGE-VORGA VALUE  'ABUD',
137    *       -             Nachtrag
138     L_VBN0        LIKE BPGE-VORGA VALUE  'KBN0',
139    *       -             GJW-Rest manuell (Kommunen)                 "DKOM
140     L_VBNC        LIKE BPGE-VORGA VALUE  'KBNC',
141    *       -             Budgeterhöhende Einnahme
142     L_VBI0        LIKE BPGE-VORGA VALUE  'KBI0',  "manuell
143     L_VBI1        LIKE BPGE-VORGA VALUE  'KBI1',  "maschinell
144     L_VBI3        LIKE BPGE-VORGA VALUE  'KBI3',  "Abrufverf Sender   "DKOM
145     L_VBI4        LIKE BPGE-VORGA VALUE  'KBI4',  "Abrufverf Receiver "DKOM
146     L_VBI3_INT    LIKE BPGE-VORGA VALUE  '*BI3',  "Abrufverf INTERN   "DKOM
147    *       -             Rueckgabe
148     L_VBR0        LIKE BPGE-VORGA VALUE  'KBR0',
149    *       -             Rueckgabe aus Resten (Kommunen)             "DKOM
150     L_VBRC        LIKE BPGE-VORGA VALUE  'KBRC',
151    *       -             Mindereinnahmen      (Kommunen)             "DKOM
152     L_VBRD        LIKE BPGE-VORGA VALUE  'KBRD',
153    *       -             Freigabe
154     L_VBFR        LIKE BPGE-VORGA VALUE  'KBFR',
155     L_VBF1        LIKE BPGE-VORGA VALUE  'KBF1',                     "DKOM
156     L_VBF2        LIKE BPGE-VORGA VALUE  'KBF2',                     "DKOM
157     L_VBF3        LIKE BPGE-VORGA VALUE  'KBF3',                     "DKOM
158     L_VBF4        LIKE BPGE-VORGA VALUE  'KBF4',                     "DKOM
159     L_VBF5        LIKE BPGE-VORGA VALUE  'KBF5',                     "DKOM
160    *       -             Lokale Sperre
161     L_VBLR        LIKE BPGE-VORGA VALUE  'KBLR',                     "DKOM
162     L_VBL1        LIKE BPGE-VORGA VALUE  'KBL1',                     "DKOM
163     L_VBL2        LIKE BPGE-VORGA VALUE  'KBL2',                     "DKOM
164     L_VBL3        LIKE BPGE-VORGA VALUE  'KBL3',                     "DKOM
165     L_VBL4        LIKE BPGE-VORGA VALUE  'KBL4',                     "DKOM
166     L_VBL5        LIKE BPGE-VORGA VALUE  'KBL5',                     "DKOM
167    *       -             Umbuchungen
168     L_VBUF        LIKE BPGE-VORGA VALUE  'KBUF', "Umbu E->A send     "DKOM
169     L_VBUG        LIKE BPGE-VORGA VALUE  'KBUG', "Umbu E->A empf     "DKOM
170     L_VBUF_INT    LIKE BPGE-VORGA VALUE  '*KBF', "Umbu E->A intern   "DKOM
171     L_VBUB        LIKE BPGE-VORGA VALUE  '*KBU',
172     L_VBUE        LIKE BPGE-VORGA VALUE  'KBUE',
173     L_VBUS        LIKE BPGE-VORGA VALUE  'KBUS',
174     L_VBUT        LIKE BPGE-VORGA VALUE  'KBUT',
175    *       -             Verfuegbarkeitskontrolle
176     L_VCOM        LIKE BPGE-VORGA VALUE  'KBFC',
177     L_VBFS        LIKE BPGE-VORGA VALUE  'KBFS', "Soft-Commitments
178     L_VBFF        LIKE BPGE-VORGA VALUE  'KBFF', "Fremd-Verfügt
179    *       -             Budget Kalkulation
180     L_VBUC        LIKE BPGE-VORGA VALUE  'KBUC',
181    *       -             Strukturplanwert
182     L_VPLAN       LIKE BPGE-VORGA VALUE  'KSTP', "Kosten
183    *** L_VKPE        LIKE BPGE-VORGA VALUE  'RKP5', "Erloese
184     L_VKPE        LIKE BPGE-VORGA VALUE  'KSTR', "Erloese
185    *       -             Finanzplanwert
186     L_VFIPL       LIKE BPGE-VORGA VALUE  'FIPL',
187    *       -             Einzelkalkulation ohne Kostenart auf BP-Db abgeleg
188     L_VKALC       LIKE BPGE-VORGA VALUE  'KSTE',
189    *       Kostenartenplanung
190     L_VKPK        LIKE BPGE-VORGA VALUE  'RKP1', "Kostenartenplan
191     L_VKPL        LIKE BPGE-VORGA VALUE  'RKP3', "Leistungen
192     L_VKPS        LIKE BPGE-VORGA VALUE  'RKP4', "Statistik
193     L_VKP5        LIKE BPGE-VORGA VALUE  'RKP5', "Erloesarten
194     L_VKZPP       LIKE BPGE-VORGA VALUE  'KZPP', "Zuschlaege
195    *       Einzelkalkulation alt bis 3.0
196     L_VKEKB       LIKE BPGE-VORGA VALUE  'KEKB', "Einzelkalkulation
197     L_VKEKZ       LIKE BPGE-VORGA VALUE  'KEKZ', "Zuschlaege
198    *       Einzelkalkulation neu ab 3.0
199     L_VKEKP       LIKE BPGE-VORGA VALUE  'KEKP', "Einzelkalkulation
200     L_VKEKS       LIKE BPGE-VORGA VALUE  'KEKS', "Zuschlaege
201     L_VKEKE       LIKE BPGE-VORGA VALUE  'KEKE', "Einzelbestand     "579095
202    *       Einzelpostenvorgaenge (Statusverwaltung)
203     L_VKEPB       LIKE BPGE-VORGA VALUE  'KEPB', "EP's Budget
204     L_VKEPP       LIKE BPGE-VORGA VALUE  'KEPP', "EP's K/E-Plan
205
206    *       - Umbuchungen Uebertraege/Vorgriffe  manuell
207     L_VKBU1       LIKE BPGE-VORGA VALUE  'KBU1', "S. Uebertrag
208     L_VKBU2       LIKE BPGE-VORGA VALUE  'KBU2', "E. Uebertrag
209     L_VKBU1_INT   LIKE BPGE-VORGA VALUE  '*KB1', "Uebertrag
210     L_VKBU3       LIKE BPGE-VORGA VALUE  'KBU3', "S. Vorgriff
211     L_VKBU4       LIKE BPGE-VORGA VALUE  'KBU4', "E. Vorgriff
212     L_VKBU3_INT   LIKE BPGE-VORGA VALUE  '*KB3', "Vorgriff
213     L_VKBU5       LIKE BPGE-VORGA VALUE  'KBU5', "Transfer Ueb.
214     L_VKBU6       LIKE BPGE-VORGA VALUE  'KBU6', "Transfer Vorg.
215
216    *       - Umbuchung 'Übertragung maschinell'
217    *       (bisher nur im Standard; im ISPS noch nicht realisiert)
218     L_VKBV1       LIKE BPGE-VORGA VALUE  'KBV1', "Sender
219     L_VKBV2       LIKE BPGE-VORGA VALUE  'KBV2', "Empfänger (receiver)
220     L_VKBV3       LIKE BPGE-VORGA VALUE  'KBV3', "Transfer
221
222    *       - Umbuchungen Uebertraege/Vorgriffe  maschinell CARRY-OVER
223     L_VKBW1       LIKE BPGE-VORGA VALUE  'KBW1', "S. Uebertrag
224     L_VKBW2       LIKE BPGE-VORGA VALUE  'KBW2', "E. Uebertrag
225     L_VKBW1_INT   LIKE BPGE-VORGA VALUE  '*KBW', "Uebertrag
226     L_VKBW3       LIKE BPGE-VORGA VALUE  'KBW3', "S. Vorgriff
227     L_VKBW4       LIKE BPGE-VORGA VALUE  'KBW4', "E. Vorgriff
228     L_VKBW5       LIKE BPGE-VORGA VALUE  'KBW5', "Transfer Ueb.
229     L_VKBW6       LIKE BPGE-VORGA VALUE  'KBW6', "Transfer Vorg.
230
231    *----- Kommunen: Umbuchungen aus echter Df (Coverpool)            "DKOM
232     L_VKBW7       LIKE BPGE-VORGA VALUE  'KBW7', "S. Coverpool       "DKOM
233     L_VKBW8       LIKE BPGE-VORGA VALUE  'KBW8', "E. Coverpool       "DKOM
234     L_VKBW9       LIKE BPGE-VORGA VALUE  'KBW9', "Tr. Coverpool      "DKOM
235     L_VKBW9_INT   LIKE BPGE-VORGA VALUE  '*BW9', "Coverpool intern   "DKOM
236
237    *       Kommunen
238     L_VKBKR       LIKE BPGE-VORGA VALUE  'KBKR', "Rechnungsergebnis
239     L_VKBRA       LIKE BPGE-VORGA VALUE  'KBRA', "Budgsp. GJW  "KI4K034435
240
241    *       - Sammelnachweise
242     L_VKBU7       LIKE BPGE-VORGA VALUE  'KBU7', "Semder
243     L_VKBU8       LIKE BPGE-VORGA VALUE  'KBU8', "Empfaenger
244     L_VKBU9       LIKE BPGE-VORGA VALUE  'KBU9', "Transfer
245     L_VKBU7_INT   LIKE BPGE-VORGA VALUE  '*KB7', "Sammelnachweis
246
247    *       SD Integration
248     L_VSDOR       LIKE BPGE-VORGA VALUE  'SDOR',
249     L_VSDQU       LIKE BPGE-VORGA VALUE  'SDQU', "SD-Angebot
250     L_VPSFP       LIKE BPGE-VORGA VALUE  'PSFP', "ab 4.0A Fakturierungsplan
251    *       Korrektursätze für RW-Interface
252     L_VCORR       LIKE BPGE-VORGA VALUE  'CORR',
253     L_VEABR       LIKE BPGE-VORGA VALUE  'KOAR', "Entlastung aus Abrechn.
254    *       Finanzmittelrechnug
255     L_VNORM       LIKE BPGE-VORGA VALUE  'KAFM',
256     L_VAZOB       LIKE BPGE-VORGA VALUE  'KAZO', "Anzahlung ohne BE
257     L_VAZMB       LIKE BPGE-VORGA VALUE  'KAZM', "Anzahlung mit BE
258     L_VMWST       LIKE BPGE-VORGA VALUE  'KAVR', "Mehrwertsteuer
259
260    *-------Applikationen--------------------------------------------------*
261     L_FIPL        LIKE TBP1C-APPLIK VALUE  'A',  "Finanzplanung
262     L_IPROG       LIKE TBP1C-APPLIK VALUE  'I',  "Investitionsprogramme
263     L_IREQUEST    LIKE TBP1C-APPLIK VALUE  'Q',  "Maßn.Anf.    "E40K000891
264     L_COST        LIKE TBP1C-APPLIK VALUE  'C',  "Kostenstellen
265     L_PROJECT     LIKE TBP1C-APPLIK VALUE  'P',  "Projekt
266     L_ORDER       LIKE TBP1C-APPLIK VALUE  'O',  "Auftrag
267     L_COFA        LIKE TBP1C-APPLIK VALUE  'F',  "CO-Fertigungsauftrag
268     L_FUNDS       LIKE TBP1C-APPLIK VALUE  'M',  "Haushaltsmanagement
269
270    *-----Sub-Applikationen------------------------------------------------
271     L_FUNDS_DKOM  LIKE TBP1C-APPLIK VALUE  'K',  "Dt.Kommunen (in l_funds)
272
273    *-------Traegerkennzeichen---------------------------------------------*
274     L_ARCHIV      LIKE BPIN-TRGKZ VALUE  'A',
275     L_INV_CF      LIKE BPIN-TRGKZ VALUE  'B', "InvProgramm Vortrag
276     L_INV_FU      LIKE BPIN-TRGKZ VALUE  'C', "InvProgramm Vorausschau
277     L_NODE        LIKE BPIN-TRGKZ VALUE  'N',
278     L_TRGKZP      LIKE BPIN-TRGKZ VALUE  'P', "Projekt
279     L_SINGLE      LIKE BPIN-TRGKZ VALUE  'S',
280     L_TRGKZ1      LIKE BPIN-TRGKZ VALUE  '1', "AUFTRAG ADDITIV
281     L_TRGKZ2      LIKE BPIN-TRGKZ VALUE  '2', "AUFTRAG ADDITIV
282     L_TRGKZ3      LIKE BPIN-TRGKZ VALUE  '3', "AUFTRAG ADDITIV
283     L_TRGKZ4      LIKE BPIN-TRGKZ VALUE  '4', "AUFTRAG ADDITIV
284     L_TRGKZ5      LIKE BPIN-TRGKZ VALUE  '5', "AUFTRAG ADDITIV geloescht
285     L_TRGKZ6      LIKE BPIN-TRGKZ VALUE  '6', "AUFTRAG DISP.
286     L_TRGKZ7      LIKE BPIN-TRGKZ VALUE  '7', "AUFTRAG DISP.
287     L_TRGKZ8      LIKE BPIN-TRGKZ VALUE  '8', "AUFTRAG DISP.
288     L_TRGKZ9      LIKE BPIN-TRGKZ VALUE  '9', "AUFTRAG DISP.
289
290    *-------Funktionen-----------------------------------------------------*
291     F_CFPLOR LIKE BPIN-FCODE VALUE  'PFOR', "Plan   CO-Fertigung
292     F_ETCOOR LIKE BPIN-FCODE VALUE  'ECOR', "Etat   Stellen
293     F_BUPROR LIKE BPIN-FCODE VALUE  'BPOR', "Budget Projekt Orig.
294     F_BUPRFR LIKE BPIN-FCODE VALUE  'FPFR', "Freig. Projekt
295     F_BUPRUB LIKE BPIN-FCODE VALUE  'BPUB', "Umb.   Projekt
296     F_BUPRN0 LIKE BPIN-FCODE VALUE  'BPN0', "Nach.  Projekt
297     F_BUPRR0 LIKE BPIN-FCODE VALUE  'BPR0', "Rück.  Projekt
298     F_BUPRXX LIKE BPIN-FCODE VALUE  'BPXX', "Hier.  Proj. Budget
299     F_BUPRFX LIKE BPIN-FCODE VALUE  'FPXX', "Hier.  Proj. Freig.
300     F_BUPRBA LIKE BPIN-FCODE VALUE  'BPBA', "Index  Proj. Budget
301     F_BUPRCF LIKE BPIN-FCODE VALUE  'BPCF', "Proj carry forward
302     F_PLPROR LIKE BPIN-FCODE VALUE  'PPOR', "KostenPlan Projekt
303     F_PLPRYY LIKE BPIN-FCODE VALUE  'PPYY', "K.P.Projekt VersCpy
304     F_PLPRYR LIKE BPIN-FCODE VALUE  'RPYY', "Erloesplan Proj VersCpy
305     F_PLPRRE LIKE BPIN-FCODE VALUE  'RPRE', "ErloesPlan Projekt
306     F_PLPRFI LIKE BPIN-FCODE VALUE  'PPFI', "Finanzplan Projekt
307     F_PLPRXX LIKE BPIN-FCODE VALUE  'PPXX', "Hier.  Projekt
308    * Neuaufbau Budgetverteiltwerte Projekt                   "N"ALRK010965
309     F_BUPRVX LIKE BPIN-FCODE VALUE  'BPVX',                  "N"ALRK010965
310     F_BUPREU LIKE BPIN-FCODE VALUE  'BPEU', "EURO-Korrektur Projekt  "EURO
311     F_BUOREU LIKE BPIN-FCODE VALUE  'BOEU', "EURO-Korrektur Order    "EURO
312     F_PLOROR LIKE BPIN-FCODE VALUE  'POOR', "Plan   CO-Auftrag
313     F_PLORYY LIKE BPIN-FCODE VALUE  'POYY', "Plan CO-Auftrag VersCpy
314     F_BUOROR LIKE BPIN-FCODE VALUE  'BOOR', "Budget CO-Auftrag
315     F_BUORN0 LIKE BPIN-FCODE VALUE  'BON0', "Nach.  CO-Auftrag
316     F_BUORR0 LIKE BPIN-FCODE VALUE  'BOR0', "Rück.  CO-Auftrag
317     F_BUORBA LIKE BPIN-FCODE VALUE  'BOBA', "Index  CO-Auftrag
318     F_BUORCF LIKE BPIN-FCODE VALUE  'BOCF', "Carry forward CO-Auftrag
319    * Maßnahmenanforderungen                           BEGIN "E40K000891
320     F_PLPQOR LIKE BPIN-FCODE VALUE  'PQOR', "Plan Maßnahmenanforderungen
321     F_PLPQIN LIKE BPIN-FCODE VALUE  'PQIN', "Plan Invest Maßn.Anforderungen
322    *                                                  END   "E40K000891
323    * Cash Flow Maßnahmenanforderung [ALRK027734]
324     F_PLPQVR LIKE BPIN-FCODE VALUE  'PQVR', "Plan Cash Flow Maßn.Anf
325
326     F_FIPLAN LIKE BPIN-FCODE VALUE  'PAOR', "Plan   FIFM
327    *-----Finanzbudget - allgemein
328     F_FUBUCC LIKE BPIN-FCODE VALUE  'BMCC', "Budgettraeger FIFM
329     F_FUBUI1 LIKE BPIN-FCODE VALUE  'ZMI1', "Einn.  FIFM maschinell
330     F_FUBUCF LIKE BPIN-FCODE VALUE  'ZMCF', "CF     FIFM
331     F_FUBUTR LIKE BPIN-FCODE VALUE  'ZMTR', "Budgetübertragung masch.
332                                             "(general budget transfer)
333     F_FUBUEC LIKE BPIN-FCODE VALUE  'ZMCA', "Kalkulation FIFM
334     F_FUBUHR LIKE BPIN-FCODE VALUE  'ZMHR', "Positionsmanagement
335     F_FUBUEU LIKE BPIN-FCODE VALUE  'ZMEU', "EURO Korrekturprogramm
336    *-----Finanzbudget - Deutsche Kommunen
337     F_FUBUO1 LIKE BPIN-FCODE VALUE  'BMO1', "Budget FIFM HHPlan
338     F_FUBUO2 LIKE BPIN-FCODE VALUE  'BMO2', "Budget FIFM HHPlan Sammelnw
339     F_FUBUO3 LIKE BPIN-FCODE VALUE  'BMO3', "Budget FIFM RechErg
340     F_FUBUO4 LIKE BPIN-FCODE VALUE  'BMO4', "Budget FIFM RechErg Sammelnw
341     F_FUBUO5 LIKE BPIN-FCODE VALUE  'BMO5', "Budget FIFM NT-HHPlan
342     F_FUBUO6 LIKE BPIN-FCODE VALUE  'BMO6', "Budget FIFM NT-HHPlan Sammelnw
343     F_FUBUOA LIKE BPIN-FCODE VALUE  'BMOA', "SalHie FIFM Saldenbudget
344     F_FUBUM1 LIKE BPIN-FCODE VALUE  'BMM1', "Budget FIFM RechErg PJhr masch
345     F_FUBUM2 LIKE BPIN-FCODE VALUE  'BMM2', "Budget FIFM Vorjw uebern masch
346     F_FUBUMA LIKE BPIN-FCODE VALUE  'BMMA', "SalHie FIFM Saldenbudget masch
347     F_FUBUMB LIKE BPIN-FCODE VALUE  'BMMB', "SalHie FIFM SaldenfinPla masch
348     F_FUBUS1 LIKE BPIN-FCODE VALUE  'ZMS1', "Budget FIFM ZB-Org  stat masch
349     F_FUBUS2 LIKE BPIN-FCODE VALUE  'ZMS2', "Budget FIFM FiPl-Orgstat masch
350     F_FUBUS3 LIKE BPIN-FCODE VALUE  'ZMS3', "Budget FIFM RechErg stat masch
351     F_FUBUS4 LIKE BPIN-FCODE VALUE  'ZMS4', "Budget FIFM ZB-NT   stat masch
352     F_FUBUS5 LIKE BPIN-FCODE VALUE  'ZMS5', "Budget FIFM FiPl-Orgstat masch
353    * note 554015
354     F_FUBUS6 LIKE BPIN-FCODE VALUE  'ZMS6', "Budget FIFM Umbuchngstat masch
355     F_FUBUS7 LIKE BPIN-FCODE VALUE  'ZMS7', "Budget FIFM Umb emp stat masch
356    * end of note 554015
357     F_FUBUSA LIKE BPIN-FCODE VALUE  'ZMSA', "SalHie FIFM Ansatz  stat masch
358     F_FUBUSB LIKE BPIN-FCODE VALUE  'ZMSB', "SalHie FIFM RechErg stat masch
359     F_FUBUSC LIKE BPIN-FCODE VALUE  'ZMSC', "SalHie FIFM Nachtrg stat masch
360     F_FUBUY1 LIKE BPIN-FCODE VALUE  'BMY1', "Budget FIFM VersCpy DKOM
361     F_FUBUY2 LIKE BPIN-FCODE VALUE  'BMY2', "Budget FIFM Uebernehm ZB DKOM
362     F_FUBUY3 LIKE BPIN-FCODE VALUE  'BMY3', "Budget FIFM Ueberneh FiP DKOM
363     F_FUXUY2 LIKE BPIN-FCODE VALUE  'XMY2', "Budget FIFM Uebernehm VB DKOM
364     F_FUBUFI LIKE BPIN-FCODE VALUE  'WMOR', "Budget FIFM FIPL -> KBPT
365     F_FUBUFS LIKE BPIN-FCODE VALUE  'SMOR', "Budget FIFM Saldenbud -> KBPT
366     F_FUBUFT LIKE BPIN-FCODE VALUE  'TMOR', "Budget FIFM Saldenfipl -> KBPT
367     F_FUBUFH LIKE BPIN-FCODE VALUE  'HMOR', "Budget FIFM glob HHPlan-> KBPT
368     F_FUBUFP LIKE BPIN-FCODE VALUE  'PMOR', "Budget FIFM Komm PB Bew-> KBPT
369     F_FUBUFQ LIKE BPIN-FCODE VALUE  'QMOR', "Budget FIFM glob CB Bew-> KBPT
370     F_FUBUFM LIKE BPIN-FCODE VALUE  'MMOR', "Budget FIFM FGrp PB Bew-> KBPT
371     F_FUBUFN LIKE BPIN-FCODE VALUE  'NMOR', "Budget FIFM glob CB Bew-> KBPT
372
373    *-----Finanzbudget - Zahlungen
374     F_FUBUOR LIKE BPIN-FCODE VALUE  'BMOR', "Budget FIFM
375     F_FUBUUB LIKE BPIN-FCODE VALUE  'BMUB', "Umb.   FIFM
376     F_FUBUN0 LIKE BPIN-FCODE VALUE  'BMN0', "Nach.  FIFM
377     F_FUBUR0 LIKE BPIN-FCODE VALUE  'BMR0', "Rück.  FIFM
378     F_FUBUFR LIKE BPIN-FCODE VALUE  'FMFR', "Frei   FIFM
379     F_FUBUF1 LIKE BPIN-FCODE VALUE  'FMF1', "Frei   FIFM MassFr masch ZB
380     F_FUBUF2 LIKE BPIN-FCODE VALUE  'FMF2', "Frei   FIFM Neuaufb FrGrp ZB
381     F_FUBUF3 LIKE BPIN-FCODE VALUE  'FMF3', "Frei   FIFM Sammelfrei ZB
382     F_FUBUF4 LIKE BPIN-FCODE VALUE  'FMF4', "Frei   FIFM Sammelfrei VB
383     F_FUBUF5 LIKE BPIN-FCODE VALUE  'FML5', "Frei   FIFM Sammelsperre ZB
384     F_FUBUF6 LIKE BPIN-FCODE VALUE  'FML6', "Frei   FIFM Sammelsperre VB
385     F_FUBUF7 LIKE BPIN-FCODE VALUE  'FMF7', "Frei   FIFM Neuaufb FrGrp VB
386     F_FUBUF8 LIKE BPIN-FCODE VALUE  'FMF8', "Frei   FIFM MassFr masch VB
387     F_FUBUBA LIKE BPIN-FCODE VALUE  'BMBA', "Index  FIFM    Budget
388     F_FUBUCA LIKE BPIN-FCODE VALUE  'BMBB', "Index  FIFM    Carry-forw.
389     F_FUBUBS LIKE BPIN-FCODE VALUE  'BMXS', "DKOM PB,CB,Freig PRUEFEN
390     F_FUBUBT LIKE BPIN-FCODE VALUE  'BMXT', "DKOM Saldenbud.  PRUEFEN
391     F_FUBUBU LIKE BPIN-FCODE VALUE  'BMXU', "DKOM PB,CB,Freig Neua.Verteilt
392     F_FUBUBV LIKE BPIN-FCODE VALUE  'BMXV', "DKOM Saldenbud.  Naua.Verteilt
393     F_FUBUBX LIKE BPIN-FCODE VALUE  'BMXX', "Bu+Fre FIFM Neuaufbau Verteilt
394     F_FUBUBW LIKE BPIN-FCODE VALUE  'BMXW', "Bu+Fre FIFM Pruefen
395     F_FUBUBY LIKE BPIN-FCODE VALUE  'BMYY', "Budget FIFM    VersCpy
396     F_FUBUFY LIKE BPIN-FCODE VALUE  'FMYY', "Frei   FIFM    VersCpy
397     F_FUBUBY1 LIKE BPIN-FCODE VALUE  'ZMYB1', "Budget FIFM VersCpy reassign
398     F_FUBUFY1 LIKE BPIN-FCODE VALUE  'ZMYF1', "Frei   FIFM VersCpy reassign
399     F_FUBUBZ LIKE BPIN-FCODE VALUE  'BMZZ', "Bu     FIFM Hochsummieren
400     F_FUBUFZ LIKE BPIN-FCODE VALUE  'FMZZ', "Frei   FIFM Hochsummieren
401     F_FUBUBZY LIKE BPIN-FCODE VALUE 'BMZY', "Bu     FIFM Neuaufbau Budget
402     F_FUBUFZY LIKE BPIN-FCODE VALUE 'FMZY', "Frei   FIFM Neuaufbau Freigabe
403     F_FUBUBZR LIKE BPIN-FCODE VALUE 'BMZR', "Bu     FIFM Neuaufbau RIB
404    *-----Finanzbudget - Neuaufbau Budgetartengerecht, standard + Kommunen
405     F_FUBUBZX LIKE BPIN-FCODE VALUE 'BMZX', "Bu     FIFM Neuaufb Budgetart
406     F_FUBUFZX LIKE BPIN-FCODE VALUE 'FMZX', "Frei   FIFM Neuaufb Freigabe
407     F_FUPUAZX LIKE BPIN-FCODE VALUE 'BMZXP', "Bu    FIFM Neuaufb Finanzplan
408     F_FUOUBZX LIKE BPIN-FCODE VALUE 'BMZXO', "Bu    FIFM Neuaufb Rechngserg
409     F_FUAUBZX LIKE BPIN-FCODE VALUE 'BMZXA', "Bu    FIFM Neuaufb Saldenbud
410     F_FUAUAZX LIKE BPIN-FCODE VALUE 'BMZXAP', "Bu   FIFM Neuaufb Saldenfipl
411     F_FUXUBZX LIKE BPIN-FCODE VALUE 'XMZX', "Bu     FIFM Neuaufb Budgetart
412     F_FUXUFZX LIKE BPIN-FCODE VALUE 'YMZX', "Frei   FIFM Neuaufb Freigabe
413
414    *-----Finanzbudget - Verpflichtungen
415     F_FUXUOR LIKE BPIN-FCODE VALUE  'XMOR', "Budget FIFM
416     F_FUXUUB LIKE BPIN-FCODE VALUE  'XMUB', "Umb.   FIFM
417     F_FUXUN0 LIKE BPIN-FCODE VALUE  'XMN0', "Nach.  FIFM
418     F_FUXUR0 LIKE BPIN-FCODE VALUE  'XMR0', "Rück.  FIFM
419     F_FUXUFR LIKE BPIN-FCODE VALUE  'YMFR', "Frei   FIFM
420     F_FUXUBX LIKE BPIN-FCODE VALUE  'XMXX', "Bu+Fre FIFM Neuaufbau Verteilt
421     F_FUXUBY LIKE BPIN-FCODE VALUE  'XMYY', "Budget FIFM    VersCpy
422     F_FUXUFY LIKE BPIN-FCODE VALUE  'YMYY', "Frei   FIFM    VersCpy
423     F_FUXUBY1 LIKE BPIN-FCODE VALUE  'ZMYX1', "Budget FIFM    VersCpy
424     F_FUXUFY1 LIKE BPIN-FCODE VALUE  'ZMYY1', "Frei   FIFM    VersCpy
425     F_FUXUBZ LIKE BPIN-FCODE VALUE  'XMZZ', "Bu     FIFM Hochsummieren
426     F_FUXUFZ LIKE BPIN-FCODE VALUE  'YMZZ', "Frei   FIFM Hochsummieren
427     F_FUXUBZY LIKE BPIN-FCODE VALUE 'XMZY', "Bu     FIFM Neuaufbau Budget
428     F_FUXUFZY LIKE BPIN-FCODE VALUE 'YMZY', "Frei   FIFM Neuaufbau Freigabe
429     F_FUXUBZR LIKE BPIN-FCODE VALUE 'XMZR', "Bu     FIFM Neuaufbau RIB
430    *-----Investprogramme
431     F_BUIPOR LIKE BPIN-FCODE VALUE  'BIOR', "Budget IProg   Orig.
432     F_BUIPN0 LIKE BPIN-FCODE VALUE  'BIN0', "Budget IProg   Nachtr.
433     F_BUIPR0 LIKE BPIN-FCODE VALUE  'BIR0', "Budget IProg   Rueckg.
434     F_PLIPOR LIKE BPIN-FCODE VALUE  'PIOR', "Plan   IProg
435
436    * Aufbau 'ABCDE':
437    * A: Basiswerttyp, B: Applikation, C: Vorerfassung
438    * D: Vorgang, E: Technik
439      F_FUEBEOE LIKE BPIN-FCODE VALUE 'BMEOE', "FM Orig.bud. erfassen
440      F_FUEBEOV LIKE BPIN-FCODE VALUE 'BMEOV', "FM Orig.bud. verteilen
441      F_FUEBERE LIKE BPIN-FCODE VALUE 'BMERE', "FM Rückgabe  erfassen
442      F_FUEBERV LIKE BPIN-FCODE VALUE 'BMERV', "FM Rückgabe  verteilen
443      F_FUEBENE LIKE BPIN-FCODE VALUE 'BMENE', "FM Nachtrag  erfassen
444      F_FUEBENV LIKE BPIN-FCODE VALUE 'BMENV', "FM Nachtrag  verteilen
445    *-----KI3K033566
446      F_FUEBEFE LIKE BPIN-FCODE VALUE 'FMEFE', "FM Freigabe  erfassen
447      F_FUEBEFV LIKE BPIN-FCODE VALUE 'FMEFV', "FM Freigabe  verteilen
448    *-----KI3K033566
449      F_FUEBEUU LIKE BPIN-FCODE VALUE 'BMEUU', "FM Umbuchung
450      F_FUEBEBA LIKE BPIN-FCODE VALUE 'BMEBA', "FM Beleg anzeigen
451      F_FUEBEBC LIKE BPIN-FCODE VALUE 'BMEBC', "FM Beleg ändern
452      F_FUEBEBS LIKE BPIN-FCODE VALUE 'BMEBS', "FM Beleg reverse
453      F_FUEBPBA LIKE BPIN-FCODE VALUE 'BMPBA', "FM Beleg anzeigen      Vor.
454      F_FUEBPBC LIKE BPIN-FCODE VALUE 'BMPBC', "FM Beleg ändern        Vor.
455      F_FUEBPBS LIKE BPIN-FCODE VALUE 'BMPBS', "FM Beleg reverse       Vor.
456      F_FUEBPOE LIKE BPIN-FCODE VALUE 'BMPOE', "FM Orig.bud. erfassen  Vor.
457      F_FUEBPOV LIKE BPIN-FCODE VALUE 'BMPOV', "FM Orig.bud. verteilen Vor.
458      F_FUEBPRE LIKE BPIN-FCODE VALUE 'BMPRE', "FM Rückgabe  erfassen  Vor.
459      F_FUEBPRV LIKE BPIN-FCODE VALUE 'BMPRV', "FM Rückgabe  verteilen Vor.
460      F_FUEBPNE LIKE BPIN-FCODE VALUE 'BMPNE', "FM Nachtrag  erfassen  Vor.
461      F_FUEBPNV LIKE BPIN-FCODE VALUE 'BMPNV', "FM Nachtrag  verteilen Vor.
462      F_FUEBPFE LIKE BPIN-FCODE VALUE 'FMPFE', "FM Freigabe  erfassen  Vor.
463      F_FUEBPFV LIKE BPIN-FCODE VALUE 'FMPFV', "FM Freigabe  verteilen Vor.
464      F_FUEBPUU LIKE BPIN-FCODE VALUE 'BMPUU', "FM Umbuchung           Vor.
465
466      F_FUEBPBR LIKE BPIN-FCODE VALUE 'BMPBR', "FM Vor-Beleg zuruecknehmen
467      F_FUEBPBP LIKE BPIN-FCODE VALUE 'BMPBP', "FM Vor-Beleg buchen
468      F_FUEBPBT LIKE BPIN-FCODE VALUE 'BMPBT', "FM Vor-Beleg genehmigen
469      F_FUEBPBF LIKE BPIN-FCODE VALUE 'BMPBF', "FM Vor-Bel genehm abgeschlos
470      F_FUEBPBV LIKE BPIN-FCODE VALUE 'BMPBV', "FM Vor-Bel erf/vert mit Vorl
471
472      F_FUEBE1E LIKE BPIN-FCODE VALUE 'BME1E', "FM Abgang   ZB erfassen kom.
473      F_FUEBE2E LIKE BPIN-FCODE VALUE 'BME2E', "FM Rückgabe ZB erfassen kom.
474      F_FUEBE3E LIKE BPIN-FCODE VALUE 'BME3E', "FM Rückgabe VE erfassen kom.
475      F_FUEBE4E LIKE BPIN-FCODE VALUE 'BME4E', "FM Minderein. ZB erfas. kom.
476      F_FUEBEXE LIKE BPIN-FCODE VALUE 'BMEXE', "FM Erfassung (Dummy)    kom.
477
478      F_FUEBE5E LIKE BPIN-FCODE VALUE 'BME5E', "FM GJW-Rest ZB erfassen kom.
479      F_FUEBE6E LIKE BPIN-FCODE VALUE 'BME6E', "FM GJW-Rest VE erfassen kom.
480      F_FUEBE0E LIKE BPIN-FCODE VALUE 'BME0E', "FM GJW-Rest (Dummy)     kom.
481      F_FUEBE5T LIKE BPIN-FCODE VALUE 'BME5T', "FM GJW-R ZB gen."KI4K034435
482      F_FUEXE5T LIKE BPIN-FCODE VALUE 'XME5T', "FM GJW-R VE gen."KI4K034435
483
484      F_FUEBE1U LIKE BPIN-FCODE VALUE 'BME1U', "FM echte DF ZB umbuchen kom.
485      F_FUEBE2U LIKE BPIN-FCODE VALUE 'BME2U', "FM APL/UEPL ZB umbuchen kom.
486      F_FUEBE3U LIKE BPIN-FCODE VALUE 'BME3U', "FM APL/UEPL VE umbuchen kom.
487      F_FUEBE4U LIKE BPIN-FCODE VALUE 'BME4U', "FM unechte DF ZB umbu.  kom.
488      F_FUEBE5U LIKE BPIN-FCODE VALUE 'BME5U', "FM Budgetarterh. umbu "RB
489      F_FUEBEXU LIKE BPIN-FCODE VALUE 'BMEXU', "FM Umbuchung   (Dummy)  kom.
490
491      F_FUEBEXV LIKE BPIN-FCODE VALUE 'BMEXV', "FM Verteilen            kom.
492
493      F_FUEBEYE LIKE BPIN-FCODE VALUE 'FMEYE', "FM Freigabegr. erfassen kom.
494      F_FUEBEYV LIKE BPIN-FCODE VALUE 'FMEYV', "FM Freigabegr.  verteil kom.
495      F_FUEBEZE LIKE BPIN-FCODE VALUE 'FMEZE', "FM l. Sperre   erfassen kom.
496
497    *----------------------------------------------------------------------*
498     F_IMPORT1 LIKE BPIN-FCODE VALUE 'ZZ001',  "KBPP_IMPORT_DATA
499
500
501    *-------Nummernkreise Einzelposten-------------------------------------*
502     L_RANGE_PP     LIKE INRI-NRRANGENR VALUE '01',  "Projekt Planung
503     L_RANGE_PB     LIKE INRI-NRRANGENR VALUE '02',  "Projekt Budget
504     L_RANGE_OP     LIKE INRI-NRRANGENR VALUE '03',  "Auftrag Planung
505     L_RANGE_OB     LIKE INRI-NRRANGENR VALUE '04',  "Auftrag Budget
506     L_RANGE_MB     LIKE INRI-NRRANGENR VALUE '05',  "Finanzbudget
507    *-------Nummernkreise Einzelposten allgemein
508     L_RANGE_B      LIKE INRI-NRRANGENR VALUE '10',  "Budget allg.
509     L_RANGE_P      LIKE INRI-NRRANGENR VALUE '11',  "Plan   allg.
510
511    *-------Belegstatus
512     L_BSTAT_POST    LIKE BPDK-BSTAT VALUE '0',        "Gebucht
513     L_BSTAT_NOT_APP LIKE BPDK-BSTAT VALUE '1',        "Vorerfasst
514     L_BSTAT_APP     LIKE BPDK-BSTAT VALUE '2',        "Vor. genehmigt
515     L_BSTAT_V_POST  LIKE BPDK-BSTAT VALUE '3',        "Vor. gebucht
516     L_BSTAT_V_REVER LIKE BPDK-BSTAT VALUE '4',        "Vor. storniert
517    *-------nicht mehr verwenden
518     L_BSTAT_ERROR   LIKE BPDK-BSTAT VALUE 'E',        "Fehlerhaft
519     L_BSTAT_REF     LIKE BPDK-BSTAT VALUE 'R',        "Abgelehnt
520    *-------Reversalstatus
521     L_RSTAT_NORM    LIKE BPDK-RSTAT VALUE ' ',        "Normal doc
522     L_RSTAT_REVL    LIKE BPDK-RSTAT VALUE '1',        "Reversal
523     L_RSTAT_REVD    LIKE BPDK-RSTAT VALUE '2',        "Reversed
524     L_RSTAT_REVING  LIKE BPDK-RSTAT VALUE '3',        "Being Reversed
525    *-------Divers---------------------------------------------------------*
526
527    *    -- IN/OUT
528     BP_INP LIKE BPIN-BELTP VALUE '1',    "Input  - Kosten
529     BP_OUT LIKE BPIN-BELTP VALUE '2',    "Output - Erloese
530    *    -- Kursumrechnung
531     S_KURST       VALUE 'M',       "Standardkurs
532    *    -- Strukturzeile
533     O_STRUC(2)    VALUE '!!',      "Strukturzeile
534    *    -- Max. Saetze fuer Array-Fetch
535     MAX_FILE     TYPE I VALUE 50, "ARRAY-FETCH
536    *    -- Feldlaengen Wertfelder -
537     LEN_WT  LIKE SY-FLENG   VALUE '8',             "Waehrungswerte
538    *    -- Anzahl Perioden / Periodenbloecke
539     ANZ_RASTER TYPE I            VALUE 16,  "16Perioden/Block
540     ANZ_PERIOD   LIKE T009-ANZBP,  "Gesamtzahl Perio
541     ANZ_PERBL    LIKE BPPE-PERBL,  "Anzahl Bloecke
542    *    -- Initialisierung
543     INI_VERSN     LIKE BPIN-VERSN VALUE  '000',
544    *    -- CO-Ledger
545    *INI_CO_LEDGER TYPE COSS-LEDNR VALUE  '00',
546    *INI_CO_VERSN  TYPE COSS-VERSN VALUE  '000',
547     INI_CO_LEDGER TYPE LEDNR VALUE  '00',
548     INI_CO_VERSN  TYPE VERSN VALUE  '000',
549    *    -- Einzelkalkulation - Versionsnummer (fuer Versionen-Kopieren)
550     INI_UNITCOSTING_VERSN LIKE RK70F-TVERS VALUE 01,
551    *    -- Applikation Projekte: Teilprojektverarbeitung
552     SUBPR_ONE     LIKE BPIN-SUBPR VALUE '1',
553     SUBPR_ALL     LIKE BPIN-SUBPR VALUE 'X',
554    *    -- Applikation Treasury
555     FIFM_CBM VALUE 'C', "Finanzmittelrechnung
556     FIFM_CA  VALUE 'A', "Finanzbudgetueberwachung
557    *    -- divers
558     CON_GEN VALUE '*',  "generisch
559
560    *    -- Werte fuer Exportparameter EX_OVERWRITE_DIALOG des
561    *    -- FB KBPS_CHECK_VERSION
562     OVR_DIALOG_NO_DIALOG VALUE '0', "kein Popup angezeigt
563     OVR_DIALOG_ANSW_NO   VALUE '1', "Popup angezeigt, Antwort
564                                           "nicht ueberschr" oder "abbrech"
565     OVR_DIALOG_ANSW_YES  VALUE '2', "Popup angezeigt, Antwort
566                                           "ueberschreiben"
567
568    *    -- Werte fuer Importparameter IM_COPY_MODE des
569    *    -- FB KBPP_COPY_VERSION
570     VERSION_CMODE_DEST_KEEP   VALUE '0', "Zieldaten nicht aendern
571     VERSION_CMODE_DEST_OVERWR VALUE '1', "Zieldaten zuruecksetzen
572                                                 "und ueberschreiben
573     VERSION_CMODE_DEST_ADD    VALUE '2', "Sourcedaten zu Zieldaten
574                                           "addieren
575     VERSION_CMODE_DEST_SUB    VALUE '3'. "subtract source from dest
576                                          "(hidden option)
577
578    *-----Budgetierungsschluessel: Budgetierungstechniken (BP_TECH)
579     DATA: L_TECH_CREATE   VALUE '1',
580           L_TECH_DISTRIB  VALUE '2',
581           L_TECH_TRANSFER VALUE '3'.
582
583    *-----Budgeterfassungsbeleg: Zeilenart
584     DATA: L_ZEILART_SENDER VALUE '1',
585           L_ZEILART_EMPFGR VALUE '2'.
586
587    *-----Werttyp fuer Enqueue in Budgettraegerpflege           "KI3K067412
588     DATA: L_BUDCARR_ENQ_WT LIKE BPIN-WRTTP VALUE 'CA'.         "KI3K067412
589
590    *-----Werttyp fuer Budgettraeger-Gruppen-Verwaltungssatz          "CGRP
591     DATA: L_GRPCARR_WT    LIKE BPIN-WRTTP VALUE 'GR'.               "CGRP
592
593    *----Anzahl der Genehmigungsjahre bei den Kommunen          "KI3K077402
594     DATA: L_ANZ_GNJHR     TYPE I VALUE 4.                      "KI3K077402
595
596
597
598    * budget version activate mode in table FM01                "KI4K012398
599    DATA: G_CON_VERSIONBLOCK    LIKE FM01-VERSACT VALUE '0',    "KI4K012398
600          G_CON_VERSIONACTIVATE LIKE FM01-VERSACT VALUE '1'.    "KI4K012398
601
602
603    * activity types for budgeting                              "KI4K012398
604    DATA: G_CON_ACT_ORG LIKE FM01-VERSACT VALUE '1', "budget    "KI4K012398
605          G_CON_ACT_REL LIKE FM01-VERSACT VALUE '2', "release   "KI4K012398
606          G_CON_ACT_UPD LIKE FM01-VERSACT VALUE '3',"upd. budget"KI4K012398
607          G_CON_ACT_YCH LIKE FM01-VERSACT VALUE '4',"year change"KI4K012398
608          G_CON_ACT_SUP LIKE FM01-VERSACT VALUE '5',"suplement
609          G_CON_ACT_YST LIKE FM01-VERSACT VALUE '6'."year start activities
610
611
612    * constant values for budget texts (used in KBPP, KBPS)
613    CONSTANTS:
614    * Anwendungsobjekt in der Textverarbeitung: Konstant
615      G_CON_BPTX_TXOB  LIKE THEAD-TDOBJECT VALUE 'BPDK',
616    * Text-Id Variabel: Ersetze & durch Applikationskennzeichen
617    * G_CON_BPTX_TXID  LIKE THEAD-TDID     VALUE 'BP&S'.
618    * zur Zeit nur Applikation M
619      G_CON_BPTX_TXID  LIKE THEAD-TDID     VALUE 'BPMS'.
620
621    * constant values for budgety ledger                        "KI4K065178
622    CONSTANTS:                                                  "KI4K065178
623    * ----- constant line types for Budgetary Ledger interface
624      CON_LINE_TYP_NEW_BUDGET   LIKE IFMBLIN-LINE_TYPE VALUE 'N',
625      CON_LINE_TYP_LEAF_BUDGET  LIKE IFMBLIN-LINE_TYPE VALUE 'L',
626      CON_LINE_TYP_BOTH_BUDGET  LIKE IFMBLIN-LINE_TYPE VALUE 'B',
627      CON_LINE_TYP_AVAIL_CHECK  LIKE IFMBLIN-LINE_TYPE VALUE 'A',
628      CON_LINE_TYP_STATISTICAL  LIKE IFMBLIN-LINE_TYPE VALUE 'S',
629      CON_LINE_TYP_DISTRIBUTION LIKE IFMBLIN-LINE_TYPE VALUE 'D',
630      CON_LINE_TYP_RESOURCE     LIKE IFMBLIN-LINE_TYPE VALUE 'R',
631      CON_LINE_TYP_OPEN_ITEMS   LIKE IFMBLIN-LINE_TYPE VALUE 'O',
632
633    * ----- Constants for budget document object types          "KI4K065178
634      CON_OBJ_TYP_BUD_HIER       LIKE ACCIT-AWTYP VALUE 'FMBHI',
635      CON_OBJ_TYP_BUD_ENTRY      LIKE ACCIT-AWTYP VALUE 'FMBTR'.
*--- End of LKBPPEQU - 635 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  RKASMAWF                                  Level 1    Page 18
Object           ZFM_RFFMEP1BX_FOR3YEARS_CALL              Lines 9
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:50
----------------------------------------------------------------------------------------------------
1      ***INCLUDE RKASMAWF .
2
3
4      *          Ablauf-ID
5      PARAMETERS: WF_WITEM LIKE SCMA_WITEM-WF_WITEM NO-DISPLAY,
6      *          Job-ID
7                 WF_OKEY  LIKE SWOTOBJID-OBJKEY NO-DISPLAY,
8      *          Worklist-ID
9                 WF_WLIST LIKE SCMA_WITEM-WF_WLIST NO-DISPLAY.
*--- End of RKASMAWF - 9 lines ---
