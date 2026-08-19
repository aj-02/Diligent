----------------------------------------------------------------------------------------------------
Main program     ZFM_RFFMEP1BX_CALL                        Level 0    Page 1
Object           ZFM_RFFMEP1BX_CALL                        Lines 1011
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:47
----------------------------------------------------------------------------------------------------
1      ***********************************************************************
2      * Program    : ZFM_RFFMEP1BX_CALL                                      *
3      *                                                                     *
4      * Title      : Budget Detail Report - called report                   *
5      *                                                                     *
6      *                                                                     *
7      * FS No.     : FS-FI-FM-005                                           *
8      *                                                                     *
9      * Author     : Punit                   Date : 10-Oct-2008             *
10     *                                                                     *
11     * Login Id   : SAB_PUNIT                                              *
12     *                                                                     *
13     * Description: This report gives budget detail - This report is       *
14     *              called by ZFM_RFFMEP1B . The report fetches data and   *
15     *              passes to ZFM_RFFMEP1B. The report is copied from      *
16     *              program RFFMEP1BX
17     *                                                                     *
18     * Tran. Code : None                                                   *
19     *                                                                     *
20     ***********************************************************************
21     ***********************************************************************
22     * Date        Transport     USERID       Description
23     * 10/10/2008  <RD1K960036>  SAB_PUNIT    1) Inital Development
24     ***********************************************************************
25
26     REPORT zfm_rffmep1bx_call.
27
28     TYPE-POOLS: fmfi, slis, sdydo, rsds.
29
30     * "/ Constants for budgeting
31     INCLUDE: lkbppequ.
32
33     * "/ Parameters for schedule manager
34     INCLUDE: rkasmawf.
35
36     TABLES: fkrs, fmaa, fmaarel, fvsn, bpbyx, epby,
37             bpdk, bpdkt, treasonst, fmsg_fmf.
38
39     CONSTANTS: con_repid LIKE sy-cprog VALUE 'RFFMEP1BX'.
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
50     *---------------------------------------------------------------------*
51     * Type Definitions                                                    *
52     *---------------------------------------------------------------------*
53     * "/ Interne Tabelle fuer Einzelposten
54     TYPES : BEGIN OF ty_g_t_item,
55               fikrs      LIKE fkrs-fikrs,
56               fincode    LIKE ffnd-fincode,
57               fname      LIKE ffnd-fname,
58               sponsor    LIKE ffnd-sponsor,
59               finuse     LIKE ffnd-finuse,
60               type       LIKE ffnd-type,
61               fund_typet LIKE ffnd-fund_typet,
62               fictr      LIKE fctr-fictr,
63               cname      LIKE fctr-cname,
64               bossid     LIKE fctr-bossid,
65               fipos      LIKE fpos-fipos,
66               pname      LIKE fpos-pname,
67               knzaepo    LIKE fpos-potyp,
68               versn      LIKE fvsn-versn,
69               gjahf      LIKE bpby-gjahr,
70               gjahr      LIKE bpby-gjahr,
71               wrttp      LIKE bpby-wrttp,
72               wtext      LIKE bpby-wtext,
73               vorga      LIKE bpby-vorga,
74               vtext      LIKE bpby-vtext,
75               cf_flag    TYPE fm_cf_flag,
76               fwaer      LIKE bpby-fwaer,
77               belnr      LIKE epby-belnr,
78               buzei      LIKE epby-buzei,
79               wljhr      LIKE epby-wljhr,
80               cpudt      LIKE bpbk-cpudt,
81               usnam      LIKE bpbk-usnam,
82               sgtext     LIKE bpbk-sgtext,
83               sversn     LIKE bpbk-sversn,
84             END OF ty_g_t_item.
85
86     * Internal table for summing up values
87     TYPES : BEGIN OF ty_g_t_item1,
88               fictr LIKE fctr-fictr,
89               cname LIKE fctr-cname,
90               fipos LIKE fpos-fipos,
91               pname LIKE fpos-pname,
92               gjahr LIKE bpby-gjahr,
93               vorga LIKE bpby-vorga,
94               vtext LIKE bpby-vtext,
95               wljhr LIKE epby-wljhr,
96             END OF ty_g_t_item1.
97
98     * Internal table for summing up values at funds center/ Comm item level
99     TYPES : BEGIN OF ty_g_t_item2,
100              fictr LIKE fctr-fictr,
101              cname LIKE fctr-cname,
102              fipos LIKE fpos-fipos,
103              pname LIKE fpos-pname,
104              gjahr LIKE bpby-gjahr,
105              wljhr LIKE epby-wljhr,
106            END OF ty_g_t_item2.
107
108    * - internal table for display
109    TYPES : BEGIN OF ty_tab_disp2,
110              fictr   LIKE fctr-fictr,
111              cname   LIKE fctr-cname,
112              fipos   LIKE fpos-fipos,
113              pname   LIKE fpos-pname,
114              gjahr   LIKE bpby-gjahr,
115              wljhr_1 LIKE epby-wljhr, " Original Budget
116              wljhr_2 LIKE epby-wljhr, " Supplement Budget
117              wljhr_3 LIKE epby-wljhr, " Retuns
118              wljhr_4 LIKE epby-wljhr, " Transfer Sender
119              wljhr_5 LIKE epby-wljhr, " Transfer Reciever
120              wljhr_6 LIKE epby-wljhr, " Transfer Sender Carry fwd
121              wljhr_7 LIKE epby-wljhr, " Transfer Reciever Carry fwd
122              wljhr   LIKE epby-wljhr, " Current Budget
123            END OF ty_tab_disp2.
124
125    *---------------------------------------------------------------------*
126    * Work Area Declarations                                              *
127    *---------------------------------------------------------------------*
128    DATA : wa_tab_disp2 TYPE ty_tab_disp2.
129    DATA : wa_g_t_item2 TYPE ty_g_t_item2.
130    DATA : wa_g_t_item1 TYPE ty_g_t_item1.
131    DATA : wa_g_t_item TYPE ty_g_t_item.
132
133    *---------------------------------------------------------------------*
134    * Internal Table Declarations                                         *
135    *---------------------------------------------------------------------*
136    DATA : ist_tab_disp2 TYPE STANDARD TABLE OF ty_tab_disp2.
137    DATA : ist_g_t_item2 TYPE STANDARD TABLE OF ty_g_t_item2.
138    DATA : ist_g_t_item1 TYPE STANDARD TABLE OF ty_g_t_item1.
139    DATA : ist_g_t_item  TYPE STANDARD TABLE OF ty_g_t_item
140                      WITH HEADER LINE.
141
142
143    DATA: g_flg_expsign,                    " Vorzeichen Ausgaben
144          g_flg_revsign,                   " Vorzeichen Einnahmen
145          g_flg_komm.                      " Kommunen Flag
146
147    * "/ Meta-Daten
148    DATA: g_t_fieldcat     TYPE slis_t_fieldcat_alv,
149          g_t_sort         TYPE slis_t_sortinfo_alv,
150          g_f_layout       TYPE slis_layout_alv,
151          g_t_sel_crit     TYPE slis_sel_hide_alv,
152          g_t_events       TYPE slis_t_event,
153          g_title          TYPE lvc_title,
154          g_background_id  TYPE sdydo_key,
155          g_t_object_info  TYPE fm_t_listheader_data,
156          g_t_top_messages TYPE fm_t_top_messages.
157    DATA: g_f_disvariant  TYPE disvariant.
158    DATA: g_flg_farea_active,
159          g_flg_fund_active.
160
161    * "/ Data for schedule manager
162    DATA: g_aplstat        TYPE smmain-aplstat,
163          g_f_schedman_key TYPE schedman_key.
164
165    * "/ Interne Tabelle fuer Einzelposten
166    DATA: BEGIN OF g_t_item OCCURS 0.
167            INCLUDE    STRUCTURE ifmrep1bx.
168    DATA:   bpdk_belnr LIKE  bpbk-bpdk_belnr,
169            bldat      LIKE  bpdk-bldat,
170            bstext     LIKE  fmdy-bstext,
171            rstat_t    LIKE  bpdy-rstat_t,
172            rev_docnr  LIKE  bpdk-rev_docnr,
173            vadat      LIKE  bpdk-vadat,
174            ttext      LIKE  fmdy-ttext,
175            verant     LIKE  bpdk-verant,
176            rtext      LIKE  fmdy-rtext,
177            valkey     LIKE  bpdk-valkey,
178            tech       LIKE  bpin-tech,
179            bstat      LIKE  bpdk-bstat,
180            rstat      LIKE  bpdk-rstat,
181            reason     LIKE  bpdk-reason,
182            namtext    LIKE  bpdkt-namtext,
183            rpublaw    LIKE  bpdk-rpublaw,
184            rlegis     LIKE  bpdk-rlegis,
185            rcohort    LIKE  bpdk-rcohort,
186            budat      LIKE  bpdk-budat,
187            doctype    LIKE  bpdk-doctype,
188            perio      LIKE  bpdk-perio,
189            fcode      LIKE  bpdk-fcode.
190    DATA: END OF g_t_item.
191
192    DATA: g_t_master_data LIKE fmaa OCCURS 300 WITH HEADER LINE.
193
194    * "/ HHM-Kontierung fuer Anzeige als Header
195    DATA: BEGIN OF g_f_hhmkont,
196            fikrs LIKE fkrs-fikrs,
197            fonds LIKE fmaa-fonds,
198            fictr LIKE fmaa-fictr,
199            fipex LIKE fmaa-fipex,
200            farea LIKE fmaa-farea,
201          END OF g_f_hhmkont.
202
203    DATA: BEGIN OF g_t_fkrs OCCURS 10,
204            fikrs LIKE fkrs-fikrs,
205          END OF g_t_fkrs.
206
207    PARAMETERS: p_entry LIKE fmdy-p_entry_header
208                MEMORY ID hdr.
209    ************************************************************************
210    AT SELECTION-SCREEN OUTPUT.
211    *****************************************************
212    START-OF-SELECTION.
213
214    * "/ initialize schedman monitor
215      PERFORM init_schedman.
216
217    * "/ Set flags for LDB and sign
218      PERFORM set_flags.
219
220    * "/ Check assigned cover pool and set Parameter P_ONLY_R
221      IF NOT s_deck IS INITIAL.
222        CLEAR fmsg_fmf-xfmaarel.
223      ELSE.
224        fmsg_fmf-xfmaarel = 'X'.
225      ENDIF.
226
227      PERFORM check_p_only_r.
228
229    * "/ Read FM area from FMF
230    GET fkrs FIELDS fikrs.
231      g_t_fkrs-fikrs = fkrs-fikrs.
232      APPEND g_t_fkrs.
233      REFRESH g_t_master_data.
234
235    * "/ Read master data from FMF
236    GET fmaa FIELDS fonds   fname     sponsor finuse fund_type fund_typet
237                    fictr   ctr_objnr cname   bossid
238                    fipex   posit     pname   potyp  fipos efictr
239                    efipex1 efipex2   efipex3 efipex4 efipex5
240                    farea ftext
241    *                 "/ Substrings
242                    fdstr_id   fdsub1     fdsub2
243                    fdsub1t_sh fdsub1t_lo fdsub2t_sh fdsub2t_lo
244                    fcstr_id   fcsub1     fcsub2     fcsub3
245                    fcsub1t_sh fcsub1t_lo fcsub2t_sh fcsub2t_lo
246                    fcsub3t_sh fcsub3t_lo
247                    cistr_id   cisub1     cisub2     cisub3 cisub4 cisub5
248                    cisub1t_sh cisub1t_lo cisub2t_sh
249                    cisub2t_lo cisub3t_sh cisub3t_lo cisub4t_sh
250                    cisub4t_lo cisub5t_sh cisub5t_lo
251                    fnstr_id   fnsub1
252                    fnsub2     fnsub3     fnsub1t_sh fnsub1t_lo fnsub2t_sh
253                    fnsub2t_lo fnsub3t_sh fnsub3t_lo.
254
255      MOVE-CORRESPONDING fmaa TO g_t_master_data.
256      COLLECT g_t_master_data.
257
258    * "/ Read master data from FMF
259    GET epby.
260      CLEAR g_t_item.
261      READ TABLE g_t_master_data WITH KEY fonds     = bpbyx-fonds
262                                          fictr     = bpbyx-fictr
263                                          fipex     = bpbyx-fipex
264                                          farea     = bpbyx-farea
265                                 BINARY SEARCH.
266      IF sy-subrc = 0.
267    *     "/ Move FM area
268        MOVE fkrs-fikrs          TO g_t_item-fikrs.
269    *     "/ Move Budget version
270        MOVE fvsn-versn          TO g_t_item-versn.
271    *     "/ Move master data
272        MOVE-CORRESPONDING g_t_master_data TO g_t_item.
273    *     "/ Move default text for Fund SPACE
274        IF g_t_master_data-fonds   IS INITIAL.
275          g_t_item-fname = TEXT-200.
276        ENDIF.
277    *     "/ Move transaction data
278        MOVE-CORRESPONDING bpbyx TO g_t_item.
279        MOVE-CORRESPONDING epby  TO g_t_item.
280    *     "/ Change sign of budget data
281        PERFORM set_sign_budget USING    g_t_master_data-potyp
282                                CHANGING g_t_item-wljhr.
283        PERFORM set_sign_budget USING    g_t_master_data-potyp
284                                CHANGING g_t_item-wljhv.
285        APPEND g_t_item.
286
287      ENDIF.
288
289    *  "/ Sort table for master data for binary search
290    GET fmaa LATE.
291      SORT g_t_master_data BY fonds fictr fipex farea.
292
293    *  "/ Sort table for master data for binary search
294    END-OF-SELECTION.
295
296      IF g_t_item[] IS INITIAL.
297    *  "/ Keine Saetze gefunden
298        MESSAGE s850(kw).
299    *   "/ Flag for schedman
300        g_aplstat = '2'.    "warning
301    *   "/ send info to schedman monitor
302        PERFORM close_schedman.
303        LEAVE PROGRAM.
304      ENDIF.
305
306      LOOP AT g_t_item INTO g_t_item.
307        MOVE: g_t_item-fikrs TO ist_g_t_item-fikrs,
308              g_t_item-fonds TO ist_g_t_item-fincode,
309              g_t_item-fname TO ist_g_t_item-fname,
310              g_t_item-sponsor TO ist_g_t_item-sponsor,
311              g_t_item-finuse TO ist_g_t_item-finuse,
312              g_t_item-fund_type TO ist_g_t_item-type,
313              g_t_item-fund_typet TO ist_g_t_item-fund_typet,
314              g_t_item-fictr  TO ist_g_t_item-fictr,
315              g_t_item-cname TO ist_g_t_item-cname,
316              g_t_item-bossid  TO ist_g_t_item-bossid,
317              g_t_item-fipex TO ist_g_t_item-fipos,
318              g_t_item-pname TO ist_g_t_item-pname,
319              g_t_item-potyp TO ist_g_t_item-knzaepo,
320              g_t_item-versn TO ist_g_t_item-versn,
321              g_t_item-gjahr  TO ist_g_t_item-gjahf,
322              g_t_item-gjahr TO ist_g_t_item-gjahr,
323              g_t_item-wrttp TO ist_g_t_item-wrttp,
324              g_t_item-wtext TO ist_g_t_item-wtext,
325              g_t_item-vorga TO ist_g_t_item-vorga,
326              g_t_item-vtext TO ist_g_t_item-vtext,
327              g_t_item-fwaer TO ist_g_t_item-fwaer,
328              g_t_item-belnr TO ist_g_t_item-belnr,
329              g_t_item-buzei TO ist_g_t_item-buzei,
330              g_t_item-wljhr TO ist_g_t_item-wljhr,
331              g_t_item-cpudt TO ist_g_t_item-cpudt,
332              g_t_item-usnam TO ist_g_t_item-usnam,
333              g_t_item-sgtext TO ist_g_t_item-sgtext,
334              g_t_item-sversn TO ist_g_t_item-sversn.
335
336        APPEND ist_g_t_item.
337      ENDLOOP.
338    * "/ Select header entry documents (Erfasungsbelege)
339      IF NOT p_entry IS INITIAL.
340        PERFORM read_header_entries TABLES ist_g_t_item.
341      ENDIF.
342
343      PERFORM delete_entries.
344
345    * - sum at transaction level to keep sub totals
346      PERFORM sum_item_level.
347
348    * - Sum up the items at funds center / commitment item level.
349      PERFORM sum_gross_level.
350
351    * - build_disp_table.
352      PERFORM build_disp_table.
353
354      PERFORM final_disp.
355
356
357      PERFORM close_schedman.
358
359    ** "/ Form-Routinen die vom Tool aufgerufen werden
360    *&---------------------------------------------------------------------*
361    *&      Form  PF_STATUS_SET
362    *&---------------------------------------------------------------------*
363    FORM pf_status_set USING extab TYPE slis_t_extab.           "#EC CALLED
364      DATA: l_f_extab    LIKE rsmpe-func,
365            l_flg_active.
366
367    *  "/ suppress icon for budgetary ledger if not active
368      LOOP AT g_t_fkrs.
369        CALL FUNCTION 'FM_LEDGER_CHECK_ACTIVE'
370          EXPORTING
371            i_fm_area    = g_t_fkrs-fikrs
372          IMPORTING
373            e_flg_active = l_flg_active.
374        IF NOT l_flg_active IS INITIAL.
375          EXIT.
376        ENDIF.
377      ENDLOOP.
378      IF l_flg_active IS INITIAL.
379        l_f_extab = 'FMBL'.
380        APPEND l_f_extab TO extab.
381      ENDIF.
382
383      SET PF-STATUS 'FULLSCREEN' EXCLUDING extab.
384    ENDFORM.                    "pf_status_set
385
386    *&---------------------------------------------------------------------*
387    *&      Form  USER_COMMAND
388    *&---------------------------------------------------------------------*
389    FORM user_command USING u_ucomm  LIKE sy-ucomm
390                            selfield TYPE slis_selfield.        "#EC CALLED
391
392      DATA: l_sav_awref LIKE fmfi-awref.
393      DATA: l_para LIKE tpara-paramid.
394      READ TABLE ist_g_t_item INTO DATA(l_t_item) INDEX selfield-tabindex.
395    *  READ TABLE ist_g_t_item INTO g_t_item INDEX selfield-tabindex.
396      MOVE-CORRESPONDING l_t_item TO g_t_item.
397      CHECK sy-subrc = 0.
398
399      CASE u_ucomm.
400        WHEN 'PIC1'.
401    *     "/ Authority check
402          PERFORM authorisation_check_tcode USING 'FM2F'.
403    *     "/ Beleg anzeigen
404          SET PARAMETER ID 'BPB' FIELD g_t_item-belnr.
405          SET PARAMETER ID 'BPD' FIELD l_para.            "note 994406
406          CALL TRANSACTION 'FM2F' AND SKIP FIRST SCREEN.     "#EC CI_CALLTA
407
408        WHEN 'FMBL'.
409    *        "/ Beleg des Budgetary Ledger anzeigen
410          l_sav_awref = g_t_item-belnr.
411          CALL FUNCTION 'FM_DOCUMENT_DISPLAY_BL'
412            EXPORTING
413              i_fikrs = g_t_item-fikrs
414              i_awtyp = 'FMBHI'
415              i_awref = l_sav_awref.
416        WHEN 'ISEL'.
417    *       "/ Display of select-options
418          CALL FUNCTION 'FMRP_UT_GET_SELECTIONS'
419            EXPORTING
420              i_report_name = con_repid
421              i_dialog      = 'X'
422            EXCEPTIONS
423              no_entries    = 1.
424      ENDCASE.
425    ENDFORM.                    "user_command
426
427    *&---------------------------------------------------------------------*
428    *&      Form  AUTHORISATION_CHECK_TCODE
429    *&---------------------------------------------------------------------*
430    FORM authorisation_check_tcode USING u_tcode LIKE sy-tcode.
431
432      CALL FUNCTION 'AUTHORITY_CHECK_TCODE'
433        EXPORTING
434          tcode  = u_tcode
435        EXCEPTIONS
436          ok     = 0
437          not_ok = 2
438          OTHERS = 3.
439      IF sy-subrc <> 0.
440        MESSAGE e172(00) WITH u_tcode.
441      ENDIF.
442    ENDFORM.                                     " authorisation_check_tcode
443
444
445
446
447    *&---------------------------------------------------------------------*
448    *&      Form  SET_FLAGS
449    *&---------------------------------------------------------------------*
450    FORM set_flags.
451
452    * "/ Ermittelt, ob Ausgaben positiv oder negativ im Reporting angezeigt
453    * "/ werden
454      CALL FUNCTION 'FM_SIGN_GET_FOR_EXPENDITURE'
455        IMPORTING
456          e_sign          = g_flg_expsign
457          e_sign_revenues = g_flg_revsign.
458
459    * "/ Kommunenflag ermitteln
460      CALL FUNCTION 'FM_GET_ACTIVE_DIMENSIONS'
461        IMPORTING
462          e_function_active = g_flg_farea_active
463          e_fund_active     = g_flg_fund_active
464          e_kom_active      = g_flg_komm.
465
466    * "/ Deactivate measure and grant
467      fmsg_fmf-xfmas = 'X'.
468      fmsg_fmf-xfgmg = 'X'.
469
470    ENDFORM.                  "SET_FLAGS
471
472    *&---------------------------------------------------------------------*
473    *&      Form  SET_SIGN_BUDGET
474    *&---------------------------------------------------------------------*
475    FORM set_sign_budget USING    u_f_potyp LIKE fmaa-potyp
476                         CHANGING p_value.
477
478
479    *  "/ Pruefen, ob Originalvorzeichen in Kommunen-Reports
480      IF NOT g_flg_komm IS INITIAL.
481        CHECK p_sign_k IS INITIAL.
482      ENDIF.
483
484      IF u_f_potyp = '3'.
485        IF g_flg_expsign = '-'.
486    *        "/ Ausgabenbudget negativ anzeigen
487          p_value = p_value * -1.
488        ENDIF.
489      ENDIF.
490      IF u_f_potyp = '2'.
491        IF g_flg_revsign = '-'.
492    *        "/ Einnahmenbudget negativ anzeigen
493          p_value = p_value * -1.
494        ENDIF.
495      ENDIF.
496    ENDFORM.                    " SET_SIGN_BUDGET
497
498    *&---------------------------------------------------------------------*
499    *&      Form  READ_HEADER_ENTRIES
500    *&---------------------------------------------------------------------*
501    *       Select headers of entry documents
502    *       Database tables BPBK and BPDK
503    *----------------------------------------------------------------------*
504    *  <-->  p1       U_T_ITEM
505    *----------------------------------------------------------------------*
506    FORM read_header_entries TABLES u_t_item STRUCTURE ist_g_t_item.
507
508      FIELD-SYMBOLS: <u_f_item> LIKE ist_g_t_item.
509
510      DATA: l_flg_subrc LIKE sy-subrc.
511
512    * "/ Internal table of header entry documents
513      DATA: BEGIN OF l_t_bpdk OCCURS 10,
514              belnr      LIKE  bpbk-belnr,
515              bpdk_belnr LIKE  bpbk-bpdk_belnr,
516              bldat      LIKE  bpdk-bldat,
517              bstext     LIKE  fmdy-bstext,
518              rstat_t    LIKE  bpdy-rstat_t,
519              rev_docnr  LIKE  bpdk-rev_docnr,
520              usnam      LIKE  bpdk-usnam,
521              cpudt      LIKE  bpdk-cpudt,
522              vadat      LIKE  bpdk-vadat,
523              ttext      LIKE  fmdy-ttext,
524              verant     LIKE  bpdk-verant,
525              rtext      LIKE  fmdy-rtext,
526              valkey     LIKE  bpdk-valkey,
527              tech       LIKE  bpin-tech,
528              bstat      LIKE  bpdk-bstat,
529              rstat      LIKE  bpdk-rstat,
530              reason     LIKE  bpdk-reason,
531              sgtext     LIKE  bpdkt-sgtext,
532              namtext    LIKE  bpdkt-namtext,
533              rpublaw    LIKE  bpdk-rpublaw,
534              rlegis     LIKE  bpdk-rlegis,
535              rcohort    LIKE  bpdk-rcohort,
536              budat      LIKE  bpdk-budat,
537              doctype    LIKE  bpdk-doctype,
538              perio      LIKE  bpdk-perio,
539              fcode      LIKE  bpdk-fcode,
540            END OF l_t_bpdk.
541
542    * "/ Select of heades of entries documents
543    * "/ for all entries in U_T_ITEM
544      " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 14.06.2026  for ATC
545    *  SELECT a~belnr
546      SELECT a~belnr                       "#EC CI_DB_OPERATION_OK[2226048]
547    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 14.06.2026 for ATC
548             a~bpdk_belnr          " Erfasungsbeleg
549             b~cpudt               " Erfassungsdatum des Beleges
550             b~budat               " Buchungsdatum
551             b~perio
552             b~bldat               " Belegdatum
553             b~vadat
554             b~verant
555             b~usnam
556             b~valkey
557             b~bstat
558             b~fcode
559             b~reason              " Entscheidungsgrund
560             b~rstat               " Belegstatus
561             b~rev_docnr           " Originalbeleg
562             b~rpublaw             " Gesetzliche Grundlage
563             b~rlegis              " Art der Gesetzgebung
564             b~rcohort             " Meldejahr für Cohort
565             b~doctype             " Art des Budgeterfassungsbelegs
566             INTO CORRESPONDING FIELDS OF TABLE l_t_bpdk
567             FROM
568                bpbk AS a JOIN bpdk AS b    "#EC CI_DB_OPERATION_OK[2226072]
569                ON a~bpdk_belnr = b~belnr
570                FOR ALL ENTRIES IN u_t_item
571                WHERE a~belnr   = u_t_item-belnr.
572
573    *  "/ Sort by BELNR
574      SORT u_t_item BY belnr.
575
576    *  "/ Move entries of BPDK into U_T_ITEM
577      LOOP AT u_t_item ASSIGNING <u_f_item>.
578        AT NEW belnr.
579          READ TABLE l_t_bpdk WITH KEY belnr = <u_f_item>-belnr.
580          l_flg_subrc = sy-subrc.
581          CHECK l_flg_subrc = 0.
582    *      "/ Read texts
583          PERFORM get_tech USING l_t_bpdk-rev_docnr
584                        CHANGING l_t_bpdk-fcode
585                                 l_t_bpdk-tech.
586          CHECK NOT l_t_bpdk-fcode IS INITIAL.
587          PERFORM get_tech_text USING l_t_bpdk-tech
588                             CHANGING l_t_bpdk-ttext.
589          PERFORM get_bstext USING l_t_bpdk-bstat
590                          CHANGING l_t_bpdk-bstext.
591          PERFORM get_rstat_t USING l_t_bpdk-rstat
592                           CHANGING l_t_bpdk-rstat_t.
593          PERFORM get_reason_text USING l_t_bpdk-reason
594                               CHANGING l_t_bpdk-rtext.
595          PERFORM get_sgtext USING l_t_bpdk-bpdk_belnr
596                          CHANGING l_t_bpdk-sgtext
597                                   l_t_bpdk-namtext.
598        ENDAT.
599        CHECK l_flg_subrc = 0.
600        MOVE-CORRESPONDING l_t_bpdk TO <u_f_item>.
601      ENDLOOP.
602
603    ENDFORM.                    " READ_HEADER_ENTRIES
604
605    *&---------------------------------------------------------------------*
606    *&      Form  GET_TECH
607    *&---------------------------------------------------------------------*
608    FORM get_tech USING u_rev_docnr LIKE bpdk-rev_docnr
609               CHANGING c_fcode     LIKE bpdk-fcode
610                        c_tech      LIKE bpin-tech.
611
612      DATA: l_f_bpin     LIKE bpin,
613            l_f_bpdk_new LIKE bpdk.
614
615    *  "/ If reversal document
616    *  "/ Contstants from LKBPPEQU
617      IF c_fcode = f_fuebebs OR c_fcode = f_fuebpbs.
618    *    "/ Read FCODE of original document
619        " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 14.06.2026  for ATC
620    *    SELECT SINGLE * FROM bpdk INTO l_f_bpdk_new
621        SELECT SINGLE * FROM bpdk INTO l_f_bpdk_new
622    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 14.06.2026 for ATC
623               WHERE belnr = bpdk-rev_docnr.  "#EC CI_DB_OPERATION_OK
624        IF sy-subrc = 0.
625          l_f_bpin-fcode = l_f_bpdk_new-fcode.
626        ELSE.
627          CLEAR l_f_bpin-fcode.
628        ENDIF.
629      ELSE.
630        l_f_bpin-fcode = c_fcode.
631      ENDIF.
632
633    *  "/ No fcode
634      IF l_f_bpin-fcode IS INITIAL.
635        c_fcode = l_f_bpin-fcode.
636        EXIT.
637      ENDIF.
638
639    *  "/ Aus FCODE Technik ermitteln
640      CALL FUNCTION 'KBPS_INIT'
641        EXPORTING
642          bp_import = l_f_bpin
643        IMPORTING
644          bp_in     = l_f_bpin
645        EXCEPTIONS
646          OTHERS    = 1.
647
648      IF sy-subrc = 0.
649        c_fcode = l_f_bpin-fcode.
650        c_tech  = l_f_bpin-tech.
651      ELSE.
652        CLEAR: c_fcode, c_tech.
653      ENDIF.
654
655    ENDFORM.                    " GET_TECH
656
657    *&---------------------------------------------------------------------*
658    *&      Form  GET_TECH_TEXT
659    *&---------------------------------------------------------------------*
660    FORM get_tech_text USING u_tech  LIKE bpin-tech
661                    CHANGING c_ttext LIKE fmdy-ttext.
662
663      DATA: l_sav_name  LIKE dd07v-domname,
664            l_sav_value LIKE dd07v-domvalue_l,
665            l_sav_text  LIKE dd07v-ddtext.
666
667      CLEAR c_ttext.
668      l_sav_name  = 'BP_TECH'.
669      l_sav_value = u_tech.
670      CALL FUNCTION 'DOMAIN_VALUE_GET'
671        EXPORTING
672          i_domname  = l_sav_name
673          i_domvalue = l_sav_value
674        IMPORTING
675          e_ddtext   = l_sav_text
676        EXCEPTIONS
677          not_exist  = 1
678          OTHERS     = 2.
679
680      CHECK sy-subrc = 0.
681      c_ttext = l_sav_text(20).
682
683    ENDFORM.                    " GET_TECH_TEXT
684
685    *&---------------------------------------------------------------------*
686    *&      Form  GET_BSTEXT
687    *&---------------------------------------------------------------------*
688    FORM get_bstext USING u_bstat
689                 CHANGING c_bstext.
690
691      CLEAR c_bstext.
692
693    *  "/ Text zum Status ermitteln
694      CALL FUNCTION 'KBPS_GET_TEXT_DOC_STATUS'
695        EXPORTING
696          ip_bstat            = u_bstat
697        IMPORTING
698          op_string_20        = c_bstext
699        EXCEPTIONS
700          status_type_invalid = 1
701          OTHERS              = 2.
702
703    ENDFORM.                    " GET_BSTEXT
704
705    *&---------------------------------------------------------------------*
706    *&      Form  GET_RSTAT_T
707    *&---------------------------------------------------------------------*
708    FORM get_rstat_t USING    p_i_rstat
709                    CHANGING p_e_rstat_t.
710
711      CLEAR p_e_rstat_t.
712
713      CALL FUNCTION 'KBPS_GET_TEXT_REV_STATUS'
714        EXPORTING
715          ip_rstat            = p_i_rstat
716        IMPORTING
717          op_string_20        = p_e_rstat_t
718        EXCEPTIONS
719          status_type_invalid = 1
720          OTHERS              = 2.
721
722
723    ENDFORM.                    " GET_rstat_t
724
725    *&---------------------------------------------------------------------*
726    *&      Form  GET_REASON_TEXT
727    *&---------------------------------------------------------------------*
728    FORM get_reason_text USING u_reason LIKE bpdk-reason
729                      CHANGING c_rtext LIKE fmdy-rtext.
730
731      CLEAR c_rtext.
732      SELECT SINGLE * FROM treasonst WHERE fmreason = u_reason
733                                       AND spras    = sy-langu.
734      CHECK sy-subrc = 0.
735      c_rtext = treasonst-fmreasntxt.
736
737    ENDFORM.                    " GET_REASON_TEXT
738
739    *&---------------------------------------------------------------------*
740    *&      Form  GET_SGTEXT
741    *&---------------------------------------------------------------------*
742    FORM get_sgtext USING u_belnr        LIKE bpdkt-belnr
743                 CHANGING c_sgtext       LIKE bpdkt-sgtext
744                          c_namtext      LIKE bpdkt-namtext.
745
746      CLEAR: c_sgtext, c_namtext.
747      " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 14.06.2026  for ATC
748    *  SELECT SINGLE * FROM bpdkt WHERE belnr = u_belnr.
749      SELECT SINGLE * FROM bpdkt WHERE belnr = u_belnr.  "#EC CI_DB_OPERATION_OK
750      " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 14.06.2026 for ATC
751      CHECK sy-subrc = 0.
752      c_sgtext  = bpdkt-sgtext.
753      c_namtext = bpdkt-namtext.
754
755    ENDFORM.                    " GET_SGTEXT
756
757    *&---------------------------------------------------------------------*
758    *&   Form INIT_SCHEDMAN
759    *&---------------------------------------------------------------------*
760    *&   initialize schedman monitor
761    *&   note: commit work executed
762    *&---------------------------------------------------------------------*
763    FORM init_schedman.
764
765    *----- initialize schedman monitor
766      CALL FUNCTION 'FM_FYC_SCHEDMAN_INIT'
767        EXPORTING
768          i_repid          = con_repid
769          i_wfitem         = wf_witem
770          i_wflist         = wf_wlist
771        IMPORTING
772          e_f_schedman_key = g_f_schedman_key.
773
774    ENDFORM.                           " INIT_SCHEDMAN
775    *&---------------------------------------------------------------------*
776    *&   Form CLOSE_SCHEDMAN
777    *&---------------------------------------------------------------------*
778    *&   send info to schedman monitor
779    *&   note: commit work executed
780    *&---------------------------------------------------------------------*
781    FORM close_schedman.
782
783      DATA: l_f_lines LIKE sy-tfill.
784
785      DESCRIBE TABLE ist_g_t_item LINES l_f_lines.
786
787    *----- send info to schedman monitor
788      CALL FUNCTION 'FM_FYC_SCHEDMAN_CLOSE'
789        EXPORTING
790          i_f_schedman_key = g_f_schedman_key
791          i_wfitem         = wf_witem
792          i_wfokey         = wf_okey
793          i_aplstat        = g_aplstat
794          i_cnt_obj        = l_f_lines.
795
796    ENDFORM.                           " CLOSE_SCHEDMAN
797
798
799    GET fmaarel FIELDS fonds   fname     sponsor finuse fund_type fund_typet
800                    fictr   ctr_objnr cname   bossid
801                    fipex   posit     pname   potyp   efictr
802                    efipex1 efipex2   efipex3 efipex4 efipex5
803                    farea ftext
804    *                 "/ Substrings
805                    fdstr_id   fdsub1     fdsub2
806                    fdsub1t_sh fdsub1t_lo fdsub2t_sh fdsub2t_lo
807                    fcstr_id   fcsub1     fcsub2     fcsub3
808                    fcsub1t_sh fcsub1t_lo fcsub2t_sh fcsub2t_lo
809                    fcsub3t_sh fcsub3t_lo
810                    cistr_id   cisub1     cisub2     cisub3 cisub4 cisub5
811                    cisub1t_sh cisub1t_lo cisub2t_sh
812                    cisub2t_lo cisub3t_sh cisub3t_lo cisub4t_sh
813                    cisub4t_lo cisub5t_sh cisub5t_lo
814                    fnstr_id   fnsub1
815                    fnsub2     fnsub3     fnsub1t_sh fnsub1t_lo fnsub2t_sh
816                    fnsub2t_lo fnsub3t_sh fnsub3t_lo.
817
818      MOVE-CORRESPONDING fmaarel TO g_t_master_data.
819      COLLECT g_t_master_data.
820
821    *  "/ Read transaction data
822    GET fmaarel LATE.
823      SORT g_t_master_data BY fonds fictr fipex farea.
824
825    ************************************************************************
826    *&---------------------------------------------------------------------*
827    *&      Form  check_p_only_r
828    *&---------------------------------------------------------------------*
829    *       Check assigned cover pool and set Parameter P_ONLY_R
830    *----------------------------------------------------------------------*
831    FORM check_p_only_r.
832
833      DATA: l_t_trange     TYPE rsds_trange,
834            l_f_dyn_range  TYPE rsds_range,
835            l_f_dyn_frange TYPE rsds_frange,
836            l_t_segments   TYPE rsds_trange,
837            l_f_segments   LIKE LINE OF l_t_segments,
838            l_f_fields     LIKE LINE OF l_f_segments-frange_t,
839            l_f_selopt     LIKE LINE OF l_f_fields-selopt_t.
840
841
842      CONSTANTS: con_fmaarel(7) TYPE c VALUE 'FMAAREL',
843                 con_deckrng(7) TYPE c VALUE 'DECKRNG'.
844
845    * "/ read dynamical selections
846      CALL FUNCTION 'RS_REFRESH_FROM_DYNAMICAL_SEL'
847        EXPORTING
848          curr_report        = con_repid
849          mode_write_or_move = 'M'
850        IMPORTING
851          p_trange           = l_t_trange
852        EXCEPTIONS
853          not_found          = 1
854          wrong_type         = 2
855          OTHERS             = 3.
856
857    * "/ Caution!!! The relevant information (value of free selection)
858    * "/ of the internal table 'l_t_trange' is hidden in a deep structure.
859      LOOP AT l_t_trange INTO l_f_dyn_range.
860
861        IF l_f_dyn_range-tablename = con_fmaarel.
862    * "/ Is there any free selection for the cover pool ???
863          READ TABLE l_f_dyn_range-frange_t INTO l_f_fields
864                   WITH KEY fieldname = con_deckrng.
865          IF sy-subrc = 0.
866    * "/ Are there any (not initialized) values?
867            LOOP AT l_f_fields-selopt_t INTO l_f_selopt.
868              IF NOT l_f_selopt-low IS INITIAL.
869    * "/ Then, set flag for 'Read only cover pool items'
870                p_only_r = 'X'.
871                CLEAR fmsg_fmf-xfmaarel.
872
873              ENDIF.
874            ENDLOOP.
875          ENDIF.
876        ENDIF.
877      ENDLOOP.
878
879    ENDFORM.                    " check_p_only_r
880
881    AT SELECTION-SCREEN.
882    * Clear Flags for FMAAREL if not called per SUBMIT
883      CLEAR p_ud.
884      CLEAR p_ed.
885      CLEAR p_rp.
886      IF p_subrel IS INITIAL.
887        IF p_only_r IS INITIAL.
888          CLEAR p_gd.
889          CLEAR p_gjrel.
890        ENDIF.
891      ENDIF.
892    ************************************************************************
893
894    *&---------------------------------------------------------------------*
895    *&      Form  delete_entries
896    *&---------------------------------------------------------------------*
897    *       text
898    *----------------------------------------------------------------------*
899    *  -->  p1        text
900    *  <--  p2        text
901    *----------------------------------------------------------------------*
902    FORM delete_entries.
903
904      DATA: l_date1 LIKE bpby-gjahr,
905            l_date2 LIKE bpby-gjahr.
906
907      MOVE s_gj_bud-low TO l_date1.
908      MOVE s_gj_bud-high TO l_date2.
909
910    *  move s_gjahr-low to l_date1.
911    *  move s_gjahr-high to l_date2.
912
913      DELETE ist_g_t_item WHERE gjahr < l_date1 AND
914                                gjahr > l_date2.
915
916
917
918    ENDFORM.                    " delete_entries
919
920    *&---------------------------------------------------------------------*
921    *&      Form  final_disp
922    *&---------------------------------------------------------------------*
923    FORM final_disp.
924
925      EXPORT ist_tab_disp2 ist_g_t_item TO MEMORY ID 'ID2'.
926
927    ENDFORM.                    " final_disp
928
929    *&---------------------------------------------------------------------*
930    *&      Form  build_disp_table
931    *&---------------------------------------------------------------------*
932    FORM build_disp_table.
933
934      LOOP AT ist_g_t_item2 INTO wa_g_t_item2.
935        wa_tab_disp2-fictr = wa_g_t_item2-fictr. " Fund center
936        wa_tab_disp2-cname = wa_g_t_item2-cname. " Fund center text
937        wa_tab_disp2-fipos = wa_g_t_item2-fipos. " Comm Item
938        wa_tab_disp2-pname = wa_g_t_item2-pname. " Comm Item text
939        wa_tab_disp2-gjahr = wa_g_t_item2-gjahr. " Fiscal Year
940        wa_tab_disp2-wljhr = wa_g_t_item2-wljhr. " Current Budget
941
942        LOOP AT ist_g_t_item1 INTO wa_g_t_item1
943                  WHERE fictr EQ wa_g_t_item2-fictr
944                  AND fipos EQ  wa_g_t_item2-fipos
945                  AND gjahr EQ  wa_g_t_item2-gjahr.
946
947          CASE wa_g_t_item1-vorga.
948
949            WHEN 'KBUD'.
950              wa_tab_disp2-wljhr_1 = wa_g_t_item1-wljhr.
951
952            WHEN 'KBN0'.
953              wa_tab_disp2-wljhr_2 = wa_g_t_item1-wljhr.
954
955            WHEN 'KBR0'.
956              wa_tab_disp2-wljhr_3 = wa_g_t_item1-wljhr.
957
958            WHEN 'KBUS'.
959              wa_tab_disp2-wljhr_4 = wa_g_t_item1-wljhr.
960
961            WHEN 'KBUE'.
962              wa_tab_disp2-wljhr_5 = wa_g_t_item1-wljhr.
963
964            WHEN 'KBU1'.
965              wa_tab_disp2-wljhr_6 = wa_g_t_item1-wljhr.
966
967            WHEN 'KBU2'.
968              wa_tab_disp2-wljhr_7 = wa_g_t_item1-wljhr.
969
970          ENDCASE.
971
972        ENDLOOP.
973        APPEND wa_tab_disp2 TO ist_tab_disp2.
974        CLEAR wa_g_t_item1.
975        CLEAR wa_tab_disp2.
976
977      ENDLOOP.
978
979    ENDFORM.                    " build_disp_table
980
981    *&---------------------------------------------------------------------*
982    *&      Form  sum_item_level
983    *&---------------------------------------------------------------------*
984    FORM sum_item_level.
985    * - Sum up the items.
986      CLEAR wa_g_t_item.
987      LOOP AT ist_g_t_item INTO wa_g_t_item.
988
989        MOVE-CORRESPONDING wa_g_t_item TO wa_g_t_item1.
990        COLLECT wa_g_t_item1 INTO ist_g_t_item1.
991
992      ENDLOOP.
993
994      CLEAR wa_g_t_item1.
995
996    ENDFORM.                    " sum_item_level
997    *&---------------------------------------------------------------------*
998    *&      Form  sum_gross_level
999    *&---------------------------------------------------------------------*
1000   FORM sum_gross_level.
1001
1002     LOOP AT ist_g_t_item1 INTO wa_g_t_item1.
1003
1004       MOVE-CORRESPONDING wa_g_t_item1 TO wa_g_t_item2.
1005       COLLECT wa_g_t_item2 INTO ist_g_t_item2.
1006
1007     ENDLOOP.
1008
1009     CLEAR wa_g_t_item2.
1010
1011   ENDFORM.                    " sum_gross_level
*--- End of ZFM_RFFMEP1BX_CALL - 1011 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CRSDS                                   Level 1    Page 2
Object           ZFM_RFFMEP1BX_CALL                        Lines 46
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:47
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
Object           ZFM_RFFMEP1BX_CALL                        Lines 12
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:47
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
Generated incl.  %_CSDYDO                                  Level 1    Page 4
Object           ZFM_RFFMEP1BX_CALL                        Lines 93
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:47
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
Generated incl.  %_CSLIS                                   Level 1    Page 5
Object           ZFM_RFFMEP1BX_CALL                        Lines 543
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:47
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
Generated incl.  <FIESEL>                                  Level 1    Page 6
Object           ZFM_RFFMEP1BX_CALL                        Lines 7
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:47
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
Generated incl.  <REPINI>                                  Level 1    Page 7
Object           ZFM_RFFMEP1BX_CALL                        Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:47
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
Generated incl.  <SYSINI>                                  Level 1    Page 8
Object           ZFM_RFFMEP1BX_CALL                        Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:47
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
Generated incl.  <SYSSEL>                                  Level 1    Page 9
Object           ZFM_RFFMEP1BX_CALL                        Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:47
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
Generated incl.  DBFMFSEL                                  Level 1    Page 10
Object           ZFM_RFFMEP1BX_CALL                        Lines 641
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:47
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
Generated incl.  LKBPPEQU                                  Level 1    Page 11
Object           ZFM_RFFMEP1BX_CALL                        Lines 635
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:47
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
Generated incl.  RKASMAWF                                  Level 1    Page 12
Object           ZFM_RFFMEP1BX_CALL                        Lines 9
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:47
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
