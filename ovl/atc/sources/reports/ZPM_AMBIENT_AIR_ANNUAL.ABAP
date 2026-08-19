----------------------------------------------------------------------------------------------------
Main program     ZPM_AMBIENT_AIR_ANNUAL                    Level 0    Page 1
Object           ZPM_AMBIENT_AIR_ANNUAL                    Lines 1783
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:20
----------------------------------------------------------------------------------------------------
1      REPORT zpm_ambient_air .
2
3      ***********************************************************************
4      * Program    :  ZPM_AMBIENT_AIR                                       *
5      *                                                                     *
6      *                                                                     *
7      * Title      :  Ambient Air quality Report                            *
8      *                                                                     *
9      * FS No.     :  FS-HSE-AIR-001                                        *
10     *                                                                     *
11     * Author     :  S.Rama                          Date :  07.06.2005    *
12     *                                                                     *
13     * Login Id   :  CAB_RAMA                                              *
14     *                                                                     *
15     * Description:  For printing ambient air reports                      *
16     *                                                                     *
17     * Tran. Code :  ZPMAIRREP                                             *
18     *                                                                     *
19     ***********************************************************************
20
21     * CHANGE HISTORY                                                      *
22     *                                                                     *
23     * Mod Date    Changed by    Description                 Chng ID       *
24     ***********************************************************************
25     *  Date            Transport      USERID          Description
26     * 04/09/2008      <RD1K960036>    CAB_PAREEK 1) Exceptions declared
27     *                                     while calling FM FORMAT_TEXTLINES
28     ***********************************************************************
29     * CHANGE HISTORY                                                      *
30     *                                                                     *
31     * Mod Date    Changed by    Description                 Chng ID       *
32     ***********************************************************************
33     *  Date            Transport      USERID          Description
34     * 16/08/2012      <RD1K981276>    CAB_AMITMOZA 1) Attached F4 help
35     *                                          object ZHSE_AIR to p_docno
36     ***********************************************************************
37     TABLES: zhseair_h,zhseair_d, t001w, stxh.
38     *---------------------------------------------------------------------*
39     *        VARIABLE DECLRATION                                          *
40     *---------------------------------------------------------------------*
41     TYPES:  BEGIN OF ty_docno,
42               docno  TYPE zhseair_h-docno,
43               werks  TYPE zhseair_h-werks,
44               tplnr  TYPE zhseair_h-tplnr,
45     *          sstation TYPE zhseair-sstation,
46               dpr_dt TYPE zhseair_h-dpr_dt,
47             END OF ty_docno.
48     TYPES: BEGIN OF ty_floc_help,
49              werks    TYPE zhse_accdt_n-werks,
50              tplnr    TYPE zhse_accdt_n-func_loc,
51              pltxt    TYPE iflotx-pltxt,
52              from_dat LIKE zhse_eff_ep-from_dat,
53              to_dat   LIKE zhse_eff_ep-to_dat,
54            END OF ty_floc_help.
55
56     TYPES:  BEGIN OF ty_annual,
57               sstation  TYPE zhseair_d-sstation,
58               spm       TYPE zhseair_d-spm,
59               rspm      TYPE zhseair_d-rspm,
60               so2       TYPE zhseair_d-so2,
61               nox       TYPE zhseair_d-nox,
62               co        TYPE zhseair_d-co,
63               h2s       TYPE zhseair_d-h2s,
64               nh3       TYPE zhseair_d-nh3,
65               hc_met    TYPE zhseair_d-hc_met,
66               hc_nonmet TYPE zhseair_d-hc_nonmet,
67             END OF ty_annual.
68     DATA : ist_docno TYPE TABLE OF ty_docno.
69     DATA : ist_annual TYPE TABLE OF ty_annual.
70     DATA : g_docno    TYPE zmm_emdhdr-docno    .
71
72     DATA:  fm_name TYPE rs38l_fnam.  "Funct name holder for Smartform
73     DATA : g_text TYPE string.
74     *---------------------------------------------------------------------*
75     *        WORK AREA DECLRATION                                         *
76     *---------------------------------------------------------------------*
77     DATA: l_tabix TYPE sy-tabix.
78     DATA : l_tplnr TYPE itob-tplnr,
79            l_pltxt TYPE iflo-pltxt,
80            name1   TYPE t001w-name1.
81
82     DATA : ist_floc_help TYPE STANDARD TABLE OF ty_floc_help,
83            wa_floc_help  TYPE ty_floc_help.
84
85     DATA: ist_return_tab TYPE STANDARD TABLE OF ddshretval WITH HEADER LINE.
86
87     DATA: wa_zhseair_h        TYPE zhseair_h,
88           wa_zhseair_d        TYPE zhseair_d,
89           wa_zhseair_d_2      TYPE zhseair_d,
90           ist_zhseair_d       TYPE STANDARD TABLE OF zhseair_d,
91           wa_zhseair_d_a      TYPE zhseair_s,
92           wa_zhseair_d_a2     TYPE zhseair_ss,
93           wa_zhseair_sum      TYPE zhseair_s,
94           ist_zhseair_d_a     TYPE STANDARD TABLE OF zhseair_s,
95           ist_zhseair_f       TYPE STANDARD TABLE OF zhseair_ss,
96           ist_zhseair_h       TYPE STANDARD TABLE OF zhseair_h,
97           ist_zhseair_max     TYPE STANDARD TABLE OF zhseair_max,
98           ist_zhseair_max_new TYPE STANDARD TABLE OF zhseair_max_new,
99           l_name1             TYPE t001w-name1,
100          l_sstation          TYPE dd07v-domvalue_l,
101          g_value             TYPE dd07v-ddtext.
102
103    * Declartion of variables for long text
104    DATA : ist_thead LIKE thead OCCURS 0 WITH HEADER LINE. " text header
105
106    DATA : BEGIN OF ist_tline OCCURS 0.    "long text lines
107            INCLUDE STRUCTURE tline.
108    DATA: END OF ist_tline.
109    DATA : BEGIN OF ist_tline_f OCCURS 0.    "long text lines
110            INCLUDE STRUCTURE tline.
111    DATA: END OF ist_tline_f.
112    DATA : first_day_fyear TYPE sy-datum,
113           last_day_fyear  TYPE sy-datum.
114
115    DATA : l_spm           TYPE jvoh_rate, "zhseair_d-SPM,
116           l_rspm          TYPE jvoh_rate, "zhseair_d-RSPM,
117           l_so2           TYPE jvoh_rate, "zhseair_d-SO2,
118           l_nox           TYPE jvoh_rate, "zhseair_d-NOX,
119           l_co            TYPE jvoh_rate, "zhseair_d-CO,
120           l_h2s           TYPE jvoh_rate, "zhseair_d-H2S,
121           l_nh3           TYPE jvoh_rate, "zhseair_d-H2S,
122           l_hc_met        TYPE jvoh_rate, "zhseair_d-H2S,
123           l_hc_nonmet     TYPE jvoh_rate, "zhseair_d-H2S,
124           l_arsc          TYPE jvoh_rate, "zhseair_d-H2S,
125           l_pb            TYPE jvoh_rate,
126           l_ni            TYPE jvoh_rate,
127           l_ni_c          TYPE i,
128           l_pb_c          TYPE i,
129           l_arsc_c        TYPE i,
130           l_spm_c         TYPE i,
131           l_rspm_c        TYPE i,
132           l_so2_c         TYPE i,
133           l_nox_c         TYPE i,
134           l_co_c          TYPE i,
135           l_h2s_c         TYPE i,
136           l_nh3_c         TYPE i,
137           l_hc_met_c      TYPE i,
138           l_hc_nonmet_c   TYPE i,
139           l_ni_f_c        TYPE i,
140           l_pb_f_c        TYPE i,
141           l_arsc_f_c      TYPE i,
142           l_spm_f_c       TYPE i,
143           l_rspm_f_c      TYPE i,
144           l_so2_f_c       TYPE i,
145           l_nox_f_c       TYPE i,
146           l_co_f_c        TYPE i,
147           l_h2s_f_c       TYPE i,
148           l_nh3_f_c       TYPE i,
149           l_hc_met_f_c    TYPE i,
150           l_hc_nonmet_f_c TYPE i.
151
152    DATA : l_spm_av  TYPE jvoh_rate, "zhseair_d-SPM,
153           l_rspm_av TYPE jvoh_rate, "zhseair_d-RSPM,
154           l_so2_av  TYPE jvoh_rate, "zhseair_d-SO2,
155           l_nox_av  TYPE jvoh_rate, "zhseair_d-NOX,
156           l_nh3_av  TYPE jvoh_rate, "zhseair_d-H2S,
157           l_arsc_av TYPE jvoh_rate, "zhseair_d-H2S,
158           l_pb_av   TYPE jvoh_rate,
159           l_ni_av   TYPE jvoh_rate.
160
161    DATA : l_year(9)  TYPE c,
162           l_year2(4) TYPE c.
163    SELECTION-SCREEN BEGIN OF BLOCK emd WITH FRAME TITLE text-001.
164
165    SELECT-OPTIONS:   s_werks FOR zhseair_h-werks MEMORY ID wrk OBLIGATORY DEFAULT '90R1',
166    *s_tplnr FOR zhseair_h-tplnr .
167    s_bunit FOR zhseair_h-bunit,
168    s_proj FOR zhseair_h-porj.
169
170    ********code added by CAB_AMITMOZA**********16.08.2012
171    PARAMETERS :p_gjahr TYPE gjahr OBLIGATORY.
172    *SELECT-OPTIONS : s_DPR_DT for zhseair_h-DPR_DT.
173
174    *PARAMETERS : p_docno      TYPE zhseair_h-docno MATCHCODE OBJECT ZHSE_AIR.
175    ********code END by CAB_AMITMOZA**********16.08.2012
176
177
178    *PARAMETER:
179    *            p_docno      TYPE zhseair_h-docno.
180    DATA:       p_werks TYPE zhseair_h-werks,
181                p_tplnr TYPE zhseair_h-tplnr,
182                p_date  TYPE zhseair_h-dpr_dt.
183
184    SELECTION-SCREEN END OF BLOCK emd.
185    *SELECTION-SCREEN BEGIN OF BLOCK blk2 WITH FRAME TITLE text-001.
186    *SELECT-OPTIONS:   s_werks FOR zhseair_h-werks memory id WRK,
187    *             s_tplnr FOR zhseair_h-tplnr matchcode object ZHSE_EFF_EP,
188    *                  s_date  FOR zhseair_h-dpr_dt.
189    *
190    *SELECTION-SCREEN END OF BLOCK blk2.
191    *---------------------------------------------------------------------*
192    *      END OF  INPUT   SELECTION SCREEN                               *
193    *---------------------------------------------------------------------*
194    *AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_tplnr-low.
195    *  PERFORM help_tplnr .
196    AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_bunit-low.
197      PERFORM help_bunit .
198
199    AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_bunit-high.
200      PERFORM help_bunit_high .
201
202    AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_proj-low.
203      PERFORM help_proj.
204
205    AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_proj-high.
206      PERFORM help_proj_high.
207
208
209    *AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_tplnr-high.
210    *  PERFORM help_tplnr .
211
212    AT SELECTION-SCREEN .
213      PERFORM check_data .
214
215    *AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_tplnr.
216    *AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_docno.
217    *  PERFORM help_docno .
218
219    START-OF-SELECTION.
220      PERFORM get_period.
221      PERFORM fetch_details.
222    *  PERFORM fetch_remarks.
223    *  PERFORM read_long_text .
224    *  PERFORM fetch_zhseair_max.
225      PERFORM fetch_zhseair_max_new.
226      PERFORM call_smartforms.
227
228    END-OF-SELECTION.
229
230    *&---------------------------------------------------------------------*
231    *&      Form  fetch_inst_details
232    *&---------------------------------------------------------------------*
233    *       To fetch data from Header and Detail table ZMM_EMDHDR and      *
234    *       ZMM_EMDDTL for printing BC LC confirmation report              *
235    *----------------------------------------------------------------------*
236    *  -->  p1        text
237    *  <--  p2        text
238    *----------------------------------------------------------------------*
239    FORM fetch_details.
240
241      CLEAR   : wa_zhseair_h.
242
243    *  IF NOT p_docno IS INITIAL.
244      IF s_werks-low = '*'.
245        SELECT * FROM zhseair_h
246    INTO CORRESPONDING FIELDS OF TABLE ist_zhseair_h
247       WHERE dpr_dt >= first_day_fyear
248        AND dpr_dt <= last_day_fyear.
249      ELSE.
250        SELECT * FROM zhseair_h
251      INTO CORRESPONDING FIELDS OF TABLE ist_zhseair_h
252          WHERE werks IN s_werks
253    *      AND tplnr IN s_tplnr
254          AND bunit IN s_bunit
255          AND porj IN s_proj
256          AND dpr_dt >= first_day_fyear
257          AND dpr_dt <= last_day_fyear.
258      ENDIF.
259    *    WHERE docno = p_docno.
260    *  ELSE.
261    *    SELECT * FROM zhseair_h
262    *    INTO CORRESPONDING FIELDS OF TABLE ist_zhseair_h
263    *      WHERE werks IN s_werks
264    *        AND tplnr IN s_tplnr
265    *        AND dpr_dt IN s_date.
266    *  ENDIF.
267
268    *  IF NOT p_docno IS INITIAL.
269    *    SELECT * FROM zhseair_d
270    *    INTO CORRESPONDING FIELDS OF TABLE ist_zhseair_d
271    *    WHERE docno = p_docno.
272    *  ELSE.
273      IF ist_zhseair_h[] IS INITIAL.
274        MESSAGE e024(zpm) .
275      ENDIF.
276      SELECT * FROM zhseair_d
277      INTO CORRESPONDING FIELDS OF TABLE ist_zhseair_d
278      FOR ALL ENTRIES IN ist_zhseair_h
279      WHERE docno = ist_zhseair_h-docno.
280    *  ENDIF.
281    *  werks = p_werks
282    *  AND tplnr = p_tplnr
283    *  AND sydate = p_date.
284
285      IF sy-subrc <> 0.
286        PERFORM callerr USING text-003.
287        STOP.
288      ENDIF.
289
290    *  SELECT SINGLE name1 INTO name1 FROM t001w WHERE werks =
291    * zhseair_h-werks.
292
293    *  IF NOT p_docno IS INITIAL.
294      LOOP AT ist_zhseair_h INTO wa_zhseair_h.
295        PERFORM fetch_remarks.
296    *      SELECT SINGLE name1 INTO l_name1 FROM t001w
297    *       WHERE werks = wa_zhseair_h-werks.
298    *    CONDENSE name1.
299    *
300    *    SELECT SINGLE pltxt INTO l_pltxt FROM iflotx
301    *    WHERE tplnr = wa_zhseair_h-tplnr.
302      ENDLOOP.
303    *  ELSE.
304    *
305    *  ENDIF.
306    *  CLEAR : l_sstation.
307    *  IF NOT wa_zhseair-sstation IS INITIAL.
308    *    l_sstation = wa_zhseair_h-sstation.
309    *  ENDIF.
310
311    *IF sy-subrc <> 0.
312    *    l_text = 'data'.
313    *    MESSAGE e238(zpm) WITH l_text.
314    *    CLEAR l_text.
315    *  ENDIF.
316      SORT ist_zhseair_d BY sstation.
317    *  IF NOT ist_zhseair_d[] IS INITIAL.
318    *    loop at ist_zhseair_d into wa_zhseair_d.
319    *      loop at ist_zhseair_d into wa_zhseair_d_2
320    *        where sstation = wa_zhseair_d-sstation.
321    *        l_SPM = wa_zhseair_d-SPM + l_SPM.
322    *        IF wa_zhseair_d-SPM > 0 .
323    *          l_SPM_C = l_SPM_C + 1.
324    *        ENDIF.
325    *        L_RSPM = wa_zhseair_d-RSPM + l_RSPM.
326    *        IF wa_zhseair_d-RSPM > 0 .
327    *          l_RSPM_C = l_RSPM_C + 1.
328    *        ENDIF.
329    *        L_SO2 =  wa_zhseair_d-SO2 + l_SO2.
330    *        IF wa_zhseair_d-SO2 > 0 .
331    *          l_SO2_C = l_SO2_C + 1.
332    *        ENDIF.
333    *        L_NOX =  wa_zhseair_d-NOX + l_NOX.
334    *        IF wa_zhseair_d-NOX > 0 .
335    *          l_NOX_C = l_NOX_C + 1.
336    *        ENDIF.
337    *        L_CO =  wa_zhseair_d-CO + l_CO.
338    *        IF wa_zhseair_d-CO > 0 .
339    *          l_CO_C = l_CO_C + 1.
340    *        ENDIF.
341    *        L_H2S =  wa_zhseair_d-H2S + l_H2S.
342    *        IF wa_zhseair_d-H2S > 0 .
343    *          l_H2S_C = l_H2S_C + 1.
344    *        ENDIF.
345    *        L_NH3 =  wa_zhseair_d-NH3 + l_NH3.
346    *        IF wa_zhseair_d-NH3 > 0 .
347    *          l_NH3_C = l_NH3_C + 1.
348    *        ENDIF.
349    *        L_HC_MET =  wa_zhseair_d-HC_MET + l_HC_MET.
350    *        IF wa_zhseair_d-HC_MET > 0 .
351    *          l_HC_MET_C = l_HC_MET_C + 1.
352    *        ENDIF.
353    *        L_HC_NONMET =  wa_zhseair_d-HC_NONMET + l_HC_NONMET.
354    *        IF wa_zhseair_d-HC_NONMET > 0 .
355    *          l_HC_NONMET_C = l_HC_NONMET_C + 1.
356    *        ENDIF.
357    *
358    *        L_ni =  wa_zhseair_d-ni + l_ni.
359    *        IF wa_zhseair_d-ni > 0 .
360    *          l_ni_C = l_ni_C + 1.
361    *        ENDIF.
362    *        L_pb =  wa_zhseair_d-pb + l_pb.
363    *        IF wa_zhseair_d-pb > 0 .
364    *          l_pb_C = l_pb_C + 1.
365    *        ENDIF.
366    *        L_arsc =  wa_zhseair_d-arsc + l_arsc.
367    *        IF wa_zhseair_d-arsc > 0 .
368    *          l_arsc_C = l_arsc_C + 1.
369    *        ENDIF.
370    *      endloop.
371    *      MOVE-CORRESPONDING wa_zhseair_d to wa_zhseair_d_a.
372    *      wa_zhseair_d_a-SPM = l_SPM.
373    *      wa_zhseair_d_a-rSPM = l_rSPM.
374    *      wa_zhseair_d_a-SO2 = l_SO2.
375    *      wa_zhseair_d_a-NOX = l_NOX.
376    **      wa_zhseair_d_a-CO = l_CO.
377    *      wa_zhseair_d_a-H2S = l_H2S.
378    *      wa_zhseair_d_a-NH3 = l_NH3.
379    *      wa_zhseair_d_a-HC_MET = l_HC_MET.
380    *      wa_zhseair_d_a-HC_NONMET = l_HC_NONMET.
381    *      wa_zhseair_d_a-pb = l_pb.
382    *      wa_zhseair_d_a-ni = l_ni.
383    *      wa_zhseair_d_a-arsc = l_arsc.
384    *      append wa_zhseair_d_a to ist_zhseair_d_a.
385    *      clear : wa_zhseair_d_a,
386    *              l_pb,l_ni,l_arsc,l_SPM,l_rSPM,l_SO2,l_NOX,l_CO,l_H2S,l_NH3,l_HC_MET,l_HC_NONMET.
387    *    endloop.
388    *  endif.
389
390      CLEAR : wa_zhseair_d_a,
391            l_pb_c,l_ni_c,l_arsc_c,l_spm_c,l_rspm_c,l_so2_c,l_nox_c,l_co_c,l_h2s_c,l_nh3_c,l_hc_met_c,l_hc_nonmet_c.
392    *  IF NOT ist_zhseair_d_a[] IS INITIAL.
393    *    loop at ist_zhseair_d_a into wa_zhseair_d_a.
394    *      l_SPM = wa_zhseair_d-SPM + l_SPM.
395    *      IF wa_zhseair_d-SPM > 0 .
396    *        l_SPM_C = l_SPM_C + 1.
397    *      ENDIF.
398    *      L_RSPM = wa_zhseair_d-RSPM + l_RSPM.
399    *      IF wa_zhseair_d-RSPM > 0 .
400    *        l_RSPM_C = l_RSPM_C + 1.
401    *      ENDIF.
402    *      L_SO2 =  wa_zhseair_d-SO2 + l_SO2.
403    *      IF wa_zhseair_d-SO2 > 0 .
404    *        l_SO2_C = l_SO2_C + 1.
405    *      ENDIF.
406    *      L_NOX =  wa_zhseair_d-NOX + l_NOX.
407    *      IF wa_zhseair_d-NOX > 0 .
408    *        l_NOX_C = l_NOX_C + 1.
409    *      ENDIF.
410    *      L_CO =  wa_zhseair_d-CO + l_CO.
411    *      IF wa_zhseair_d-CO > 0 .
412    *        l_CO_C = l_CO_C + 1.
413    *      ENDIF.
414    *      L_H2S =  wa_zhseair_d-H2S + l_H2S.
415    *      IF wa_zhseair_d-H2S > 0 .
416    *        l_H2S_C = l_H2S_C + 1.
417    *      ENDIF.
418    *      L_NH3 =  wa_zhseair_d-NH3 + l_NH3.
419    *      IF wa_zhseair_d-NH3 > 0 .
420    *        l_NH3_C = l_NH3_C + 1.
421    *      ENDIF.
422    *      L_HC_MET =  wa_zhseair_d-HC_MET + l_HC_MET.
423    *      IF wa_zhseair_d-HC_MET > 0 .
424    *        l_HC_MET_C = l_HC_MET_C + 1.
425    *      ENDIF.
426    *      L_HC_NONMET =  wa_zhseair_d-HC_NONMET + l_HC_NONMET.
427    *      IF wa_zhseair_d-HC_NONMET > 0 .
428    *        l_HC_NONMET_C = l_HC_NONMET_C + 1.
429    *      ENDIF.
430    *      L_ni =  wa_zhseair_d-ni + l_ni.
431    *      IF wa_zhseair_d-ni > 0 .
432    *        l_ni_C = l_ni_C + 1.
433    *      ENDIF.
434    *      L_pb =  wa_zhseair_d-pb + l_pb.
435    *      IF wa_zhseair_d-pb > 0 .
436    *        l_pb_C = l_pb_C + 1.
437    *      ENDIF.
438    *      L_arsc =  wa_zhseair_d-arsc + l_arsc.
439    *      IF wa_zhseair_d-arsc > 0 .
440    *        l_arsc_C = l_arsc_C + 1.
441    *      ENDIF.
442    *    endloop.
443    *    wa_zhseair_d_a-SSTATION = 'AVERAGE'.
444    *    IF l_SPM_C > 0.
445    *      wa_zhseair_d_A-SPM = l_SPM / L_SPM_C.
446    *    ENDIF.
447    *    IF l_RSPM_C > 0.
448    *      wa_zhseair_d_A-RSPM = l_RSPM / l_RSPM_C.
449    *    ENDIF.
450    *    IF l_SO2_C > 0.
451    *      wa_zhseair_d_a-SO2 = l_SO2 / l_SO2_C.
452    *    ENDIF.
453    *    IF l_NOX_C > 0.
454    *      wa_zhseair_d_a-NOX = l_NOX / l_NOX_C.
455    *    ENDIF.
456    *    IF l_CO_C > 0.
457    *      wa_zhseair_d_a-CO = l_CO / l_CO_C.
458    *    ENDIF.
459    *    IF l_H2S_C > 0.
460    *      wa_zhseair_d_A-H2S = l_H2S / l_H2S_C.
461    *    ENDIF.
462    *    IF l_NH3_C > 0.
463    *      wa_zhseair_d_a-NH3 = l_NH3 / l_NH3_C.
464    *    ENDIF.
465    *    IF l_HC_MET_C > 0.
466    *      wa_zhseair_d_a-HC_MET = l_HC_MET / l_HC_MET_C.
467    *    ENDIF.
468    *    IF l_HC_NONMET_C > 0.
469    *      wa_zhseair_d_a-HC_NONMET = l_HC_NONMET / l_HC_NONMET_C.
470    *    ENDIF.
471    *    IF l_pb_C > 0.
472    *      wa_zhseair_d_A-pb = l_pb / L_pb_C.
473    *    ENDIF.
474    *    IF l_ni_C > 0.
475    *      wa_zhseair_d_A-ni = l_ni / L_ni_C.
476    *    ENDIF.
477    *    IF l_arsc_C > 0.
478    *      wa_zhseair_d_A-arsc = l_arsc / L_arsc_C.
479    *    ENDIF.
480    *    APPEND wa_zhseair_d_a TO ist_zhseair_d_a.
481    *  ENDIF.
482
483      LOOP AT ist_zhseair_d INTO wa_zhseair_d.
484        MOVE-CORRESPONDING wa_zhseair_d TO wa_zhseair_d_a.
485        APPEND wa_zhseair_d_a TO ist_zhseair_d_a.
486      ENDLOOP.
487
488      LOOP AT ist_zhseair_d_a INTO  wa_zhseair_d_a.
489        l_tabix = sy-tabix.
490        READ TABLE ist_zhseair_h INTO wa_zhseair_h
491        WITH KEY docno = wa_zhseair_d_a-docno.
492        IF sy-subrc = 0.
493          wa_zhseair_d_a-tplnr = wa_zhseair_h-tplnr.
494          wa_zhseair_d_a-bunit = wa_zhseair_h-bunit.
495          wa_zhseair_d_a-proj = wa_zhseair_h-porj.
496
497          MODIFY ist_zhseair_d_a FROM wa_zhseair_d_a
498          INDEX l_tabix.
499        ENDIF.
500      ENDLOOP.
501
502      SORT ist_zhseair_d_a BY tplnr.
503      IF NOT ist_zhseair_d_a[] IS INITIAL.
504        LOOP AT ist_zhseair_d_a INTO wa_zhseair_d_a.
505          MOVE-CORRESPONDING wa_zhseair_d_a TO wa_zhseair_d_a2.
506          COLLECT wa_zhseair_d_a2 INTO ist_zhseair_f.
507        ENDLOOP.
508      ENDIF.
509      CLEAR : wa_zhseair_d_a2,
510            l_pb_c,l_ni_c,l_arsc_c,l_spm_c,l_rspm_c,l_so2_c,l_nox_c,l_co_c,l_h2s_c,l_nh3_c,l_hc_met_c,l_hc_nonmet_c,
511            l_pb_f_c,l_ni_f_c,l_arsc_f_c,l_spm_f_c,l_rspm_f_c,l_so2_f_c,l_nox_f_c,l_co_f_c,l_h2s_f_c,l_nh3_f_c,l_hc_met_f_c,l_hc_nonmet_f_c.
512
513      LOOP AT ist_zhseair_f INTO wa_zhseair_d_a2.
514        l_tabix = sy-tabix.
515        IF wa_zhseair_d_a2-ni > 0.
516          l_ni_f_c = l_ni_f_c + 1.
517        ENDIF.
518        IF wa_zhseair_d_a2-pb > 0.
519          l_pb_f_c  = l_pb_f_c + 1.
520        ENDIF.
521        IF wa_zhseair_d_a2-arsc > 0.
522          l_arsc_f_c  = l_arsc_f_c + 1.
523        ENDIF.
524        IF wa_zhseair_d_a2-spm > 0.
525          l_spm_f_c  = l_spm_f_c + 1.
526        ENDIF.
527        IF wa_zhseair_d_a2-rspm > 0.
528          l_rspm_f_c  = l_rspm_f_c + 1.
529        ENDIF.
530        IF wa_zhseair_d_a2-so2 > 0.
531          l_so2_f_c  = l_so2_f_c + 1.
532        ENDIF.
533        IF wa_zhseair_d_a2-nox > 0.
534          l_nox_f_c  = l_nox_f_c + 1.
535        ENDIF.
536        IF wa_zhseair_d_a2-nh3 > 0.
537          l_nh3_f_c  = l_nh3_f_c + 1.
538        ENDIF.
539
540        MOVE-CORRESPONDING wa_zhseair_d_a2 TO wa_zhseair_sum.
541        LOOP AT ist_zhseair_d_a INTO wa_zhseair_d_a
542          WHERE tplnr = wa_zhseair_d_a2-tplnr.
543          IF wa_zhseair_d_a-spm > 0 .
544            l_spm_c = l_spm_c + 1.
545          ENDIF.
546          l_rspm = wa_zhseair_d_a-rspm + l_rspm.
547          IF wa_zhseair_d_a-rspm > 0 .
548            l_rspm_c = l_rspm_c + 1.
549          ENDIF.
550          l_so2 =  wa_zhseair_d_a-so2 + l_so2.
551          IF wa_zhseair_d_a-so2 > 0 .
552            l_so2_c = l_so2_c + 1.
553          ENDIF.
554          l_nox =  wa_zhseair_d_a-nox + l_nox.
555          IF wa_zhseair_d_a-nox > 0 .
556            l_nox_c = l_nox_c + 1.
557          ENDIF.
558          l_co =  wa_zhseair_d_a-co + l_co.
559          IF wa_zhseair_d_a-co > 0 .
560            l_co_c = l_co_c + 1.
561          ENDIF.
562          l_h2s =  wa_zhseair_d_a-h2s + l_h2s.
563          IF wa_zhseair_d_a-h2s > 0 .
564            l_h2s_c = l_h2s_c + 1.
565          ENDIF.
566          l_nh3 =  wa_zhseair_d_a-nh3 + l_nh3.
567          IF wa_zhseair_d_a-nh3 > 0 .
568            l_nh3_c = l_nh3_c + 1.
569          ENDIF.
570          l_hc_met =  wa_zhseair_d_a-hc_met + l_hc_met.
571          IF wa_zhseair_d_a-hc_met > 0 .
572            l_hc_met_c = l_hc_met_c + 1.
573          ENDIF.
574          l_hc_nonmet =  wa_zhseair_d_a-hc_nonmet + l_hc_nonmet.
575          IF wa_zhseair_d_a-hc_nonmet > 0 .
576            l_hc_nonmet_c = l_hc_nonmet_c + 1.
577          ENDIF.
578          l_ni =  wa_zhseair_d_a-ni + l_ni.
579          IF wa_zhseair_d_a-ni > 0 .
580            l_ni_c = l_ni_c + 1.
581          ENDIF.
582          l_pb =  wa_zhseair_d_a-pb + l_pb.
583          IF wa_zhseair_d_a-pb > 0 .
584            l_pb_c = l_pb_c + 1.
585          ENDIF.
586          l_arsc =  wa_zhseair_d_a-arsc + l_arsc.
587          IF wa_zhseair_d_a-arsc > 0 .
588            l_arsc_c = l_arsc_c + 1.
589          ENDIF.
590        ENDLOOP.
591
592
593        IF l_spm_c > 0.
594          wa_zhseair_d_a2-spm = wa_zhseair_d_a2-spm / l_spm_c.
595        ENDIF.
596        IF l_rspm_c > 0.
597          wa_zhseair_d_a2-rspm = wa_zhseair_d_a2-rspm / l_rspm_c.
598        ENDIF.
599        IF l_so2_c > 0.
600          wa_zhseair_d_a2-so2 = wa_zhseair_d_a2-so2 / l_so2_c.
601        ENDIF.
602        IF l_nox_c > 0.
603          wa_zhseair_d_a2-nox = wa_zhseair_d_a2-nox / l_nox_c.
604        ENDIF.
605        IF l_co_c > 0.
606          wa_zhseair_d_a2-co = wa_zhseair_d_a2-co / l_co_c.
607        ENDIF.
608        IF l_h2s_c > 0.
609          wa_zhseair_d_a2-h2s = wa_zhseair_d_a2-h2s / l_h2s_c.
610        ENDIF.
611        IF l_nh3_c > 0.
612          wa_zhseair_d_a2-nh3 = wa_zhseair_d_a2-nh3 / l_nh3_c.
613        ENDIF.
614        IF l_hc_met_c > 0.
615          wa_zhseair_d_a2-hc_met = wa_zhseair_d_a2-hc_met / l_hc_met_c.
616        ENDIF.
617        IF l_hc_nonmet_c > 0.
618          wa_zhseair_d_a2-hc_nonmet = wa_zhseair_d_a2-hc_nonmet / l_hc_nonmet_c.
619        ENDIF.
620        IF l_pb_c > 0.
621          wa_zhseair_d_a2-pb = wa_zhseair_d_a2-pb / l_pb_c.
622        ENDIF.
623        IF l_ni_c > 0.
624          wa_zhseair_d_a2-ni = wa_zhseair_d_a2-ni / l_ni_c.
625        ENDIF.
626        IF l_arsc_c > 0.
627          wa_zhseair_d_a2-arsc = wa_zhseair_d_a2-arsc / l_arsc_c.
628        ENDIF.
629
630        l_spm_av = wa_zhseair_d_a2-spm + l_spm_av.
631        l_rspm_av = wa_zhseair_d_a2-rspm + l_rspm_av.
632        l_so2_av = wa_zhseair_d_a2-so2 + l_so2_av.
633        l_nox_av  = wa_zhseair_d_a2-nox + l_nox_av.
634        l_nh3_av = wa_zhseair_d_a2-nh3 + l_nh3_av.
635        l_arsc_av = wa_zhseair_d_a2-arsc + l_arsc_av.
636        l_pb_av = wa_zhseair_d_a2-pb + l_pb_av.
637        l_ni_av = wa_zhseair_d_a2-ni + l_ni_av.
638
639        MODIFY ist_zhseair_f FROM wa_zhseair_d_a2
640        INDEX l_tabix TRANSPORTING spm rspm so2 nox co h2s nh3 hc_met hc_nonmet pb ni arsc.
641        CLEAR : wa_zhseair_d_a2,
642              l_pb_c,l_ni_c,l_arsc_c,l_spm_c,l_rspm_c,l_so2_c,l_nox_c,l_co_c,l_h2s_c,l_nh3_c,l_hc_met_c,l_hc_nonmet_c.
643      ENDLOOP.
644
645      CLEAR wa_zhseair_d_a2.
646    *  wa_zhseair_d_A2-tplnr = 'AVERAGE'.
647    *  IF l_spm_f_C > 0.
648    *    wa_zhseair_d_A2-SPM = l_SPM_av / L_SPM_f_C.
649    *  ENDIF.
650    *  IF l_RSPM_f_C > 0.
651    *    wa_zhseair_d_A2-RSPM = L_RSPM_av / l_RSPM_f_C.
652    *  ENDIF.
653    *  IF l_SO2_f_C > 0.
654    *    wa_zhseair_d_A2-SO2 = l_SO2_av / l_SO2_f_C.
655    *  ENDIF.
656    *  IF l_NOX_f_C > 0.
657    *    wa_zhseair_d_A2-NOX = l_NOX_av / l_NOX_f_C.
658    *  ENDIF.
659    *
660    *  IF l_pb_f_C > 0.
661    *    wa_zhseair_d_A2-pb = l_pb_av / l_pb_f_C.
662    *  ENDIF.
663    *
664    *  IF l_ni_f_C > 0.
665    *    wa_zhseair_d_A2-ni = l_ni_av / l_ni_f_C.
666    *  ENDIF.
667    *
668    *  IF l_arsc_f_C > 0.
669    *    wa_zhseair_d_A2-arsc = l_arsc_av / l_arsc_f_C.
670    *  ENDIF.
671    *
672    *  IF l_NH3_f_C > 0.
673    *    wa_zhseair_d_A2-NH3 = l_NH3_av / l_NH3_f_C.
674    *  ENDIF.
675    *
676    *  APPEND wa_zhseair_d_A2 TO ist_zhseair_f.
677    ENDFORM.                    " fetch_inst_details
678
679    *&---------------------------------------------------------------------*
680    *&      Form  call_smartforms                                          *
681    *&---------------------------------------------------------------------*
682    *       Call Smartforms ZMM_EMD_BGLC_CONF                              *
683    *----------------------------------------------------------------------*
684    *  -->  p1        Smartform layout ZMM_EMD_BGLC_CONF                   *
685    *  <--  p2        fm_name                                              *
686    *----------------------------------------------------------------------*
687    FORM call_smartforms.
688      DATA : l_form TYPE  tdsfname.
689
690
691      l_form = 'ZPM_AMBIENT_AIR_NEW_AN'.
692
693      CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
694        EXPORTING
695          formname           = l_form
696    *            'ZPM_CTMS_ORIFICE'
697        IMPORTING
698          fm_name            = fm_name
699        EXCEPTIONS
700          no_form            = 1
701          no_function_module = 2
702          OTHERS             = 3.
703
704      IF sy-subrc <> 0.
705        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
706                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
707      ENDIF.
708      SORT ist_zhseair_max_new BY zdur pollutant.
709    ************************************************************************\
710      IF s_werks-low = '*'.
711        l_name1 = '*'.
712      ENDIF.
713      CALL FUNCTION fm_name
714        IMPORTING
715          wa_zhseair_h        = wa_zhseair_h
716          l_name1             = l_name1
717          l_pltxt             = l_pltxt
718          l_year              = l_year
719    *     l_sstation          = l_sstation
720        TABLES
721          ist_zhseair_h       = ist_zhseair_h
722          ist_zhseair_d       = ist_zhseair_f
723          ist_tline           = ist_tline
724          ist_zhseair_max     = ist_zhseair_max
725          ist_zhseair_max_new = ist_zhseair_max_new
726        EXCEPTIONS
727          formatting_error    = 1
728          internal_error      = 2
729          send_error          = 3
730          user_canceled       = 4
731          OTHERS              = 5.
732      IF sy-subrc <> 0.
733        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
734                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
735      ENDIF.
736
737
738    ENDFORM.                    " call_smartforms
739    *&---------------------------------------------------------------------*
740    *&      Form  callerr
741    *&---------------------------------------------------------------------*
742    *       text
743    *----------------------------------------------------------------------*
744    *      -->P_TEXT_003  text
745    *----------------------------------------------------------------------*
746    FORM callerr USING l_text.
747      MESSAGE: L_TEXT TYPE 'E'.
748    *  CALL FUNCTION 'FC_POPUP_ERR_WARN_MESSAGE'
749    *    EXPORTING
750    *      popup_title  = text-002
751    *      is_error     = 'X'
752    *      message_text = l_text
753    *      start_column = 30
754    *      start_row    = 8.
755      STOP.
756    ENDFORM.                    " callerr
757    *&---------------------------------------------------------------------*
758    *&      Form  check_calno
759    *&---------------------------------------------------------------------*
760    *       text
761    *----------------------------------------------------------------------*
762    *  -->  p1        text
763    *  <--  p2        text
764    *----------------------------------------------------------------------*
765    FORM check_data.
766
767      DATA: l_text TYPE string.
768
769      CLEAR: p_tplnr,p_date.
770    *  if not p_docno is initial.
771    *    SELECT SINGLE * FROM zhseair_h
772    *    INTO CORRESPONDING FIELDS OF wa_zhseair_h
773    *    WHERE docno = p_docno.
774    *    IF sy-subrc <> 0.
775    *      l_text = 'data'.
776    *      MESSAGE e238(zpm) WITH l_text.
777    *      CLEAR l_text.
778    *    ENDIF.
779    *    p_werks = wa_zhseair_h-werks.
780    *    p_tplnr = wa_zhseair_h-tplnr.
781    *    p_date = wa_zhseair_h-dpr_dt.
782    *  endif.
783    ENDFORM.                    " check_calno
784    *&---------------------------------------------------------------------*
785    *&      Form  help_tplnr
786    *&---------------------------------------------------------------------*
787    *       text
788    *----------------------------------------------------------------------*
789    *  -->  p1        text
790    *  <--  p2        text
791    *----------------------------------------------------------------------*
792    FORM help_docno.
793
794      SELECT werks tplnr dpr_dt docno
795             FROM zhseair_h
796                INTO  CORRESPONDING  FIELDS  OF  TABLE  ist_docno.
797
798      IF  sy-subrc  EQ  0.
799        SORT ist_docno BY docno.
800        CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
801          EXPORTING
802            retfield        = 'DOCNO'
803            dynpprog        = 'ZPM_AMBIENT_AIR_NEW'
804            dynpnr          = sy-dynnr
805            dynprofield     = 'DOCNO'
806            value_org       = 'S'
807          TABLES
808            value_tab       = ist_docno
809            return_tab      = ist_return_tab
810          EXCEPTIONS
811            parameter_error = 1
812            no_values_found = 2
813            OTHERS          = 3.
814
815        IF sy-subrc <> 0.
816
817          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
818                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
819
820        ENDIF.
821      ENDIF.
822
823    ENDFORM.                    " help_tplnr
824    *&---------------------------------------------------------------------*
825    *&      Form  read_long_text
826    *&---------------------------------------------------------------------*
827    *       text
828    *----------------------------------------------------------------------*
829    *  -->  p1        text
830    *  <--  p2        text
831    *----------------------------------------------------------------------*
832    FORM read_long_text.
833    *  DATA : ist_text_lines     LIKE tline OCCURS 0 WITH HEADER LINE.
834    *
835    *  DATA : l_tdid     TYPE thead-tdid.
836    *  DATA : l_tdname   TYPE thead-tdname.
837    *  DATA : l_tdobject TYPE thead-tdobject.
838    *
839    *  l_tdname   = p_docno.
840    *  l_tdobject = 'ZPMHSE'.
841    *  l_tdid = 'H001'.
842    *
843    *  SELECT SINGLE * FROM stxh
844    *    WHERE tdobject = l_tdobject AND
845    *          tdname   = l_tdname AND
846    *          tdid     = l_tdid.
847    *
848    *  IF sy-subrc = 0.
849    *    CALL FUNCTION 'READ_TEXT'
850    *         EXPORTING
851    *              client   = sy-mandt
852    *              id       = l_tdid
853    *              language = 'E'
854    *              name     = l_tdname
855    *              object   = l_tdobject
856    *         TABLES
857    *              lines    = ist_text_lines.
858    *
859    **    READ TABLE ist_text_lines INDEX 1.
860    *    LOOP AT ist_text_lines.
861    **    MOVE ist_text_lines-tdline TO g_text.
862    *    concatenate g_text ist_text_lines-tdline INTO g_text
863    *    separated by space.
864    *    ENDLOOP.
865
866    *  ENDIF.
867
868    ENDFORM.                    " read_long_text
869    *&---------------------------------------------------------------------*
870    *&      Form  fetch_remarks
871    *&---------------------------------------------------------------------*
872    *       text
873    *----------------------------------------------------------------------*
874    *  -->  p1        text
875    *  <--  p2        text
876    *----------------------------------------------------------------------*
877    FORM fetch_remarks.
878      PERFORM set_remarks_header_text USING wa_zhseair_h-docno
879                                              wa_zhseair_h-dpr_dt.
880
881      SELECT SINGLE * FROM stxh
882          WHERE tdobject = ist_thead-tdobject AND
883                tdname   = ist_thead-tdname AND
884                tdid     = ist_thead-tdid.
885
886      IF sy-subrc = 0.
887        PERFORM  read_remarks_text.
888      ENDIF.
889
890    ENDFORM.                    " fetch_remarks
891    *&---------------------------------------------------------------------*
892    *&      Form  set_remarks_header_text
893    *&---------------------------------------------------------------------*
894    *       text
895    *----------------------------------------------------------------------*
896    *      -->P_WA_ZHSEAIR_DOCNO  text
897    *      -->P_WA_ZHSEAIR_DPR_DT  text
898    *----------------------------------------------------------------------*
899    FORM set_remarks_header_text USING p_docno
900                                       p_docdt.
901      DATA l_tdobject   LIKE thead-tdobject VALUE 'ZHSEAC'.
902    *  DATA l_tdobject   LIKE thead-tdobject VALUE 'ZTESTPM'.
903      DATA l_tdname     LIKE thead-tdname .
904      DATA l_tdid       LIKE thead-tdid VALUE '0005'.
905      DATA l_tdspras    LIKE thead-tdspras VALUE 'E'.
906      DATA l_tdlinesize LIKE thead-tdlinesize VALUE '132'.
907      DATA : l_docno(7) TYPE n,
908             l_docdt(8) TYPE n.
909
910      REFRESH : ist_thead.
911      CLEAR   : ist_thead.
912
913      MOVE p_docno  TO l_docno.
914      MOVE p_docdt  TO l_docdt.
915
916      CONCATENATE l_docno l_docdt INTO l_tdname.
917
918      ist_thead-tdobject   = l_tdobject.
919      ist_thead-tdname     = l_tdname.
920      ist_thead-tdid       = l_tdid.
921      ist_thead-tdspras    = l_tdspras.
922      ist_thead-tdlinesize = l_tdlinesize.
923
924      APPEND ist_thead.
925    ENDFORM.                    " set_remarks_header_text
926    *&---------------------------------------------------------------------*
927    *&      Form  read_remarks_text
928    *&---------------------------------------------------------------------*
929    *       text
930    *----------------------------------------------------------------------*
931    *  -->  p1        text
932    *  <--  p2        text
933    *----------------------------------------------------------------------*
934    FORM read_remarks_text.
935      CALL FUNCTION 'READ_TEXT'
936        EXPORTING
937          client   = sy-mandt
938          id       = ist_thead-tdid
939          language = ist_thead-tdspras
940          name     = ist_thead-tdname
941          object   = ist_thead-tdobject
942        TABLES
943          lines    = ist_tline.
944      CALL FUNCTION 'FORMAT_TEXTLINES'
945        EXPORTING
946    *     CURSOR_COLUMN           = 0
947    *     CURSOR_LINE = 0
948    *     ENDLINE     = 99999
949          formatwidth = 132
950    *     LINEWIDTH   = 132
951    *     STARTLINE   = 1
952    *     LANGUAGE    = SY-LANGU
953    * IMPORTING
954    *     NEW_CURSOR_COLUMN       =
955    *     NEW_CURSOR_LINE         =
956        TABLES
957          lines       = ist_tline
958    * Begin of <RD1K960036>
959        EXCEPTIONS
960          bound_error = 1
961          OTHERS      = 2.
962    * End of <RD1K960036>
963      IF sy-subrc <> 0.
964    * MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
965    *         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
966      ENDIF.
967
968      IF NOT ist_tline[] IS INITIAL.
969        APPEND LINES OF ist_tline TO ist_tline_f.
970      ENDIF.
971    ENDFORM.                    " read_remarks_text
972    *&---------------------------------------------------------------------*
973    *&      Form  fetch_zhseair_max
974    *&---------------------------------------------------------------------*
975    *       text
976    *----------------------------------------------------------------------*
977    *  -->  p1        text
978    *  <--  p2        text
979    *----------------------------------------------------------------------*
980    FORM fetch_zhseair_max.
981      SELECT * FROM zhseair_max
982      INTO CORRESPONDING FIELDS OF TABLE ist_zhseair_max.
983    ENDFORM.                    " fetch_zhseair_max
984    *&---------------------------------------------------------------------*
985    *&      Form  FETCH_ZHSEAIR_MAX_NEW
986    *&---------------------------------------------------------------------*
987    *       text
988    *----------------------------------------------------------------------*
989    *  -->  p1        text
990    *  <--  p2        text
991    *----------------------------------------------------------------------*
992    FORM fetch_zhseair_max_new .
993      SELECT * FROM zhseair_max_new
994      INTO CORRESPONDING FIELDS OF TABLE ist_zhseair_max_new
995        WHERE zdur = 'YR'.
996    ENDFORM.                    " FETCH_ZHSEAIR_MAX_NEW
997    *&---------------------------------------------------------------------*
998    *&      Form  GET_PERIOD
999    *&---------------------------------------------------------------------*
1000   *       text
1001   *----------------------------------------------------------------------*
1002   *  -->  p1        text
1003   *  <--  p2        text
1004   *----------------------------------------------------------------------*
1005   FORM get_period .
1006
1007     IF NOT p_gjahr IS INITIAL.
1008       CALL FUNCTION 'FIRST_AND_LAST_DAY_IN_YEAR_GET'
1009         EXPORTING
1010           i_gjahr        = p_gjahr
1011           i_periv        = 'V3'
1012         IMPORTING
1013           e_first_day    = first_day_fyear
1014           e_last_day     = last_day_fyear
1015         EXCEPTIONS
1016           input_false    = 1
1017           t009_notfound  = 2
1018           t009b_notfound = 3
1019           OTHERS         = 4.
1020       l_year2 = p_gjahr + 1.
1021       CONCATENATE p_gjahr '-' l_year2 INTO l_year.
1022     ELSE.
1023   *    first_day_fyear = s_DPR_DT-low.
1024   *    last_day_fyear = s_DPR_DT-high.
1025     ENDIF.
1026   ENDFORM.                    " GET_PERIOD
1027   *&---------------------------------------------------------------------*
1028   *&      Form  HELP_TPLNR
1029   *&---------------------------------------------------------------------*
1030   *       text
1031   *----------------------------------------------------------------------*
1032   *  -->  p1        text
1033   *  <--  p2        text
1034   *----------------------------------------------------------------------*
1035   FORM help_tplnr .
1036     DATA: wa_tplnr  TYPE zhseair_h,
1037           ist_tplnr LIKE STANDARD TABLE OF zhseair_h.
1038     DATA : l_index TYPE sy-index,
1039            l_werks TYPE zhseair_h-werks.
1040     DATA : ist_dyfields LIKE dynpread OCCURS 1 WITH HEADER LINE.
1041
1042
1043     CLEAR :ist_floc_help.
1044     REFRESH :ist_floc_help.
1045
1046     ist_dyfields-fieldname = 'S_WERKS-LOW'.
1047     APPEND ist_dyfields.
1048
1049     CALL FUNCTION 'DYNP_VALUES_READ'
1050       EXPORTING
1051         dyname     = sy-cprog
1052         dynumb     = sy-dynnr
1053       TABLES
1054         dynpfields = ist_dyfields.
1055
1056     l_werks = ist_dyfields-fieldvalue.
1057
1058     IF NOT l_werks IS INITIAL.
1059
1060       SELECT werks tplnr from_dat to_dat FROM zhse_eff_ep
1061           INTO CORRESPONDING FIELDS OF TABLE ist_floc_help
1062              WHERE werks = l_werks.
1063
1064
1065       LOOP AT ist_floc_help INTO wa_floc_help.
1066
1067   " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1068   *      SELECT SINGLE pltxt INTO wa_floc_help-pltxt FROM iflotx
1069   *        WHERE tplnr = wa_floc_help-tplnr.
1070    SELECT PLTXT FROM IFLOTX   UP TO 1 ROWS INTO WA_FLOC_HELP-PLTXT WHERE
1071   TPLNR = WA_FLOC_HELP-TPLNR  ORDER BY  TPLNR SPRAS .   ENDSELECT.
1072   " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
1073
1074         IF sy-subrc = 0.
1075           MODIFY ist_floc_help FROM wa_floc_help TRANSPORTING pltxt.
1076         ENDIF.
1077       ENDLOOP.
1078
1079       IF NOT ist_floc_help IS INITIAL.
1080         CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
1081           EXPORTING
1082             retfield        = 'TPLNR'
1083             dynpprog        = 'ZPM_AMBIENT_LIST_NEW'
1084             dynpnr          = sy-dynnr
1085             dynprofield     = 'S_TPLNR-LOW'
1086             value_org       = 'S'
1087           TABLES
1088             value_tab       = ist_floc_help
1089             return_tab      = ist_return_tab
1090           EXCEPTIONS
1091             parameter_error = 1
1092             no_values_found = 2
1093             OTHERS          = 3.
1094
1095         IF sy-subrc <> 0.
1096
1097           MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
1098                   WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
1099
1100         ENDIF.
1101       ENDIF.
1102     ENDIF.
1103
1104     IF ist_dyfields-fieldname = 'S_WERKS-LOW'.
1105   *    s_tplnr-low =  ist_return_tab-fieldval.
1106     ELSEIF ist_dyfields-fieldname = 'S_WERKS-HIGH'.
1107   *    s_tplnr-high =  ist_return_tab-fieldval.
1108     ENDIF.
1109   ENDFORM.                    " HELP_TPLNR
1110   *&---------------------------------------------------------------------*
1111   *&      Form  HELP_BUNIT
1112   *&---------------------------------------------------------------------*
1113   *       text
1114   *----------------------------------------------------------------------*
1115   *  -->  p1        text
1116   *  <--  p2        text
1117   *----------------------------------------------------------------------*
1118   FORM help_bunit .
1119     TYPES: BEGIN OF lt_acc_bu,
1120              bunit  TYPE zbunit_d,
1121              bu_txt	TYPE pltxt,
1122            END OF lt_acc_bu.
1123
1124     DATA: it_return_bu  LIKE STANDARD TABLE OF ddshretval,
1125           gwa_return_bu LIKE ddshretval.
1126
1127     DATA: lit_acc_bu TYPE STANDARD TABLE OF lt_acc_bu,
1128           lwa_acc_bu TYPE lt_acc_bu.
1129
1130     DATA: lit_bu_fcat TYPE slis_t_fieldcat_alv,
1131           lwa_bu_fcat TYPE slis_fieldcat_alv.
1132
1133     DATA:  ls_tabix_bu TYPE slis_selfield,
1134            lv_row_bu   TYPE i.
1135     DATA: i_selfield TYPE slis_selfield.
1136
1137   *  DATA : ist_return_tab      LIKE STANDARD TABLE OF ddshretval
1138   *                             WITH  HEADER LINE.
1139
1140     REFRESH: it_return_bu,lit_bu_fcat, lit_acc_bu.
1141     CLEAR: ist_return_tab, ls_tabix_bu,lv_row_bu.
1142
1143
1144     lwa_bu_fcat-fieldname  = 'BUNIT'.    " Fieldname in the data table
1145     lwa_bu_fcat-seltext_m  = 'Business Unit'.    " Column description in the output
1146     APPEND lwa_bu_fcat TO lit_bu_fcat.
1147     CLEAR lwa_bu_fcat.
1148
1149     lwa_bu_fcat-fieldname  = 'BU_TXT'.    " Fieldname in the data table
1150     lwa_bu_fcat-seltext_l  = 'Description'.    " Column description in the output
1151     lwa_bu_fcat-outputlen = 32.
1152     APPEND lwa_bu_fcat TO lit_bu_fcat.
1153     CLEAR lwa_bu_fcat.
1154
1155   *SELECT * FROM ZEHS_ACC_evnt INTO CORRESPONDING FIELDS OF TABLE lit_acc_evnt WHERE STATUS ne 'X'.
1156
1157   *  SELECT zohse_eff_ep~bunit iflotx~pltxt INTO TABLE lit_acc_bu
1158   *        FROM zohse_eff_ep LEFT OUTER JOIN iflotx ON zohse_eff_ep~bunit = iflotx~tplnr.
1159
1160
1161
1162
1163   *
1164   *  CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
1165   *    EXPORTING
1166   *      tabname           = 'ZOHSE_EFF_EP'
1167   *      fieldname         = 'BUNIT'
1168   *      searchhelp        = 'ZOFUNCL'
1169   **     SHLPPARAM         = ' '
1170   *      dynpprog          = sy-repid
1171   *      dynpnr            = sy-dynnr
1172   **     DYNPROFIELD       = ' '
1173   **     STEPL             = 0
1174   **     VALUE             = ' '
1175   **     MULTIPLE_CHOICE   = ' '
1176   **     DISPLAY           = ' '
1177   **     SUPPRESS_RECORDLIST       = ' '
1178   **     CALLBACK_PROGRAM  = ' '
1179   **     CALLBACK_FORM     = ' '
1180   **     CALLBACK_METHOD   =
1181   **     SELECTION_SCREEN  = ' '
1182   **   IMPORTING
1183   **     USER_RESET        =
1184   *    TABLES
1185   *      return_tab        = it_return_bu
1186   *    EXCEPTIONS
1187   *      field_not_found   = 1
1188   *      no_help_for_field = 2
1189   *      inconsistent_help = 3
1190   *      no_values_found   = 4
1191   *      OTHERS            = 5.
1192   *  IF sy-subrc <> 0.
1193   ** Implement suitable error handling here
1194   *  ENDIF.
1195
1196
1197   *  CALL FUNCTION 'DYNP_GET_STEPL'
1198   *    IMPORTING
1199   *      povstepl        = lv_row_bu
1200   *    EXCEPTIONS
1201   *      stepl_not_found = 1
1202   *      OTHERS          = 2.
1203   *  IF sy-subrc <> 0.
1204   ** Implement suitable error handling here
1205   *  ENDIF.
1206
1207     SELECT * FROM zohse_eff_ep INTO CORRESPONDING FIELDS OF TABLE lit_acc_bu.
1208     IF lit_acc_bu IS NOT INITIAL..
1209       LOOP AT lit_acc_bu INTO lwa_acc_bu.
1210
1211   " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1212   *      SELECT SINGLE pltxt FROM iflotx INTO lwa_acc_bu-bu_txt WHERE tplnr = lwa_acc_bu-bunit.
1213    SELECT PLTXT FROM IFLOTX   UP TO 1 ROWS INTO LWA_ACC_BU-BU_TXT WHERE
1214   TPLNR = LWA_ACC_BU-BUNIT  ORDER BY  TPLNR SPRAS .   ENDSELECT.
1215   " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
1216         MODIFY lit_acc_bu FROM lwa_acc_bu TRANSPORTING bu_txt .
1217         CLEAR lwa_acc_bu.
1218       ENDLOOP.
1219       " BREAK-POINT.
1220   " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1221   SORT LIT_ACC_BU BY BUNIT .
1222   " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1223       DELETE ADJACENT DUPLICATES FROM lit_acc_bu COMPARING bunit.
1224
1225
1226       CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
1227         EXPORTING
1228           i_title       = 'Business Unit'
1229           i_selection   = 'X'
1230           i_zebra       = 'X'
1231           i_tabname     = 'LIT_ACC_DOC'
1232           it_fieldcat   = lit_bu_fcat
1233         IMPORTING
1234           es_selfield   = i_selfield
1235         TABLES
1236           t_outtab      = lit_acc_bu
1237         EXCEPTIONS
1238           program_error = 1
1239           OTHERS        = 2.
1240       IF i_selfield IS NOT INITIAL.
1241   " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1242         READ TABLE lit_acc_bu INTO lwa_acc_bu INDEX i_selfield-tabindex. "#EC CI_NOORDER
1243   " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1244         s_bunit-low = lwa_acc_bu-bunit.
1245   *      gwa_iflo-bu_txt = lwa_acc_bu-bu_txt.
1246
1247         CLEAR i_selfield.
1248
1249       ENDIF.
1250
1251
1252     ENDIF.
1253
1254
1255
1256   ENDFORM.
1257   *&---------------------------------------------------------------------*
1258   *&      Form  HELP_PROJ
1259   *&---------------------------------------------------------------------*
1260   *       text
1261   *----------------------------------------------------------------------*
1262   *  -->  p1        text
1263   *  <--  p2        text
1264   *----------------------------------------------------------------------*
1265   FORM help_proj .
1266     TYPES: BEGIN OF lt_acc_proj,
1267              proj     TYPE tplnr,
1268              proj_txt TYPE pltxt,
1269            END OF lt_acc_proj.
1270     DATA: povstepl  LIKE  sy-stepl.
1271     DATA: dynfields TYPE TABLE OF dynpread WITH HEADER LINE.
1272
1273     DATA: it_return_proj  LIKE STANDARD TABLE OF ddshretval,
1274           gwa_return_proj LIKE ddshretval,
1275
1276           fl1(18)         TYPE c,
1277           fl2(18)         TYPE c,
1278           fl3(18)         TYPE c,
1279           lv_cont(50)     TYPE c.
1280
1281     DATA: lit_acc_proj TYPE STANDARD TABLE OF lt_acc_proj,
1282           lwa_acc_proj TYPE lt_acc_proj.
1283
1284     DATA:  ls_tabix_proh TYPE slis_selfield,
1285            lv_row_proj   TYPE i.
1286
1287     DATA: p_selfield TYPE slis_selfield.
1288   *  DATA: dynfields TYPE TABLE OF dynpread WITH HEADER LINE.
1289
1290
1291     DATA: lit_proj_fcat TYPE slis_t_fieldcat_alv,
1292           lwa_proj_fcat TYPE slis_fieldcat_alv.
1293     REFRESH: it_return_proj, lit_proj_fcat.
1294     CLEAR: gwa_return_proj,lv_row_proj,lwa_proj_fcat,p_selfield.
1295
1296     lwa_proj_fcat-fieldname  = 'PROJ'.    " Fieldname in the data table
1297     lwa_proj_fcat-seltext_m  = 'Project'.    " Column description in the output
1298     APPEND lwa_proj_fcat TO lit_proj_fcat.
1299     CLEAR lwa_proj_fcat.
1300
1301     lwa_proj_fcat-fieldname  = 'PROJ_TXT'.    " Fieldname in the data table
1302     lwa_proj_fcat-seltext_l  = 'Description'.    " Column description in the output
1303     lwa_proj_fcat-outputlen = 32.
1304     APPEND lwa_proj_fcat TO lit_proj_fcat.
1305     CLEAR lwa_proj_fcat.
1306
1307
1308     SELECT proj
1309            pltxt
1310
1311        FROM zohse_eff_ep INTO  TABLE lit_acc_proj WHERE bunit = s_bunit-low.
1312     IF lit_acc_proj IS NOT INITIAL.
1313   *    LOOP AT lit_acc_proj INTO lwa_acc_proj.
1314   *      AUTHORITY-CHECK OBJECT 'ZOHSE_ACN1'
1315   *              ID 'ACTVT' FIELD '01'
1316   *              ID 'WERKS_A' FIELD zohse_accdt_n-werks
1317   *              ID 'BUNIT_A' FIELD zohse_accdt_n-bunit
1318   *              ID 'PROJ_A' FIELD lwa_acc_proj-proj.
1319   *      IF sy-subrc EQ 0.
1320   *        SELECT SINGLE pltxt FROM iflotx INTO lwa_acc_proj-proj_txt WHERE tplnr = lwa_acc_proj-proj.
1321   *        MODIFY lit_acc_proj FROM lwa_acc_proj TRANSPORTING proj_txt .
1322   *        CLEAR lwa_acc_proj.
1323   *      ELSE.
1324   *        DELETE lit_acc_proj INDEX sy-tabix.
1325   *      ENDIF.
1326   *    ENDLOOP.
1327
1328   " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1329   SORT LIT_ACC_PROJ BY PROJ .
1330   " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1331       DELETE ADJACENT DUPLICATES FROM lit_acc_proj COMPARING proj.
1332
1333       CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
1334         EXPORTING
1335           i_title       = 'Project'
1336           i_selection   = 'X'
1337           i_zebra       = 'X'
1338           i_tabname     = 'LIT_ACC_PROJ'
1339           it_fieldcat   = lit_proj_fcat
1340         IMPORTING
1341           es_selfield   = p_selfield
1342         TABLES
1343           t_outtab      = lit_acc_proj
1344         EXCEPTIONS
1345           program_error = 1
1346           OTHERS        = 2.
1347       IF p_selfield IS NOT INITIAL.
1348   " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1349         READ TABLE lit_acc_proj INTO lwa_acc_proj INDEX p_selfield-tabindex. "#EC CI_NOORDER
1350   " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1351         s_proj-low = lwa_acc_proj-proj.
1352   *      iflotx-pltxt = lwa_acc_proj-proj_txt.
1353         CLEAR p_selfield.
1354
1355         REFRESH dynfields.
1356         CLEAR:   dynfields,povstepl.
1357
1358         CALL FUNCTION 'DYNP_GET_STEPL'
1359           IMPORTING
1360             povstepl        = povstepl
1361           EXCEPTIONS
1362             stepl_not_found = 1
1363             OTHERS          = 2.
1364         IF sy-subrc <> 0.
1365   * Implement suitable error handling here
1366         ENDIF.
1367
1368
1369         dynfields-fieldname = 'S_PROJ-LOW'.
1370         dynfields-fieldvalue = s_proj-low.
1371         dynfields-stepl      = povstepl.
1372         APPEND dynfields.
1373
1374         CALL FUNCTION 'DYNP_VALUES_UPDATE'
1375           EXPORTING
1376             dyname     = sy-cprog
1377             dynumb     = sy-dynnr
1378           TABLES
1379             dynpfields = dynfields
1380           EXCEPTIONS
1381             OTHERS     = 8.
1382         COMMIT WORK AND WAIT.
1383
1384         REFRESH dynfields.
1385         CLEAR:   dynfields.
1386
1387         dynfields-fieldname = 'IFLOTX-PLTXT'.
1388   *      dynfields-fieldvalue = iflotx-pltxt.
1389         dynfields-stepl      = povstepl.
1390         APPEND dynfields.
1391
1392         CALL FUNCTION 'DYNP_VALUES_UPDATE'
1393           EXPORTING
1394             dyname     = sy-cprog
1395             dynumb     = sy-dynnr
1396           TABLES
1397             dynpfields = dynfields
1398           EXCEPTIONS
1399             OTHERS     = 8.
1400         COMMIT WORK AND WAIT.
1401
1402         SPLIT s_proj-low AT '-' INTO fl1 fl2 fl3.
1403
1404         CONCATENATE fl1 fl2 INTO lv_cont SEPARATED BY '-'.
1405
1406   *      SELECT SINGLE pltxt FROM iflotx INTO gwa_iflo-cntry_txt WHERE tplnr = lv_cont.
1407   *      SELECT SINGLE MINES_N FROM zohse_eff_ep INTO zohse_accdt_n-MINES_N
1408   *                                             WHERE bunit = zohse_accdt_n-bunit
1409   *                                              AND PROJ = zohse_accdt_n-func_loc.
1410   *        if sy-subrc = 0.
1411   *          SELECT SINGLE DESCIR FROM ZEHS_ACC_CAT INTO ZOHSE_ACCDT_N-CAT_DES WHERE CATEGORY = zohse_accdt_n-MINES_N.
1412   *        endif.
1413
1414   *      ty_zhseair_h-country = lv_cont.
1415
1416   *      CLEAR: lv_cont, fl1, fl2, fl3.
1417   *
1418   *      REFRESH dynfields.
1419   *      CLEAR:   dynfields,povstepl.
1420   *
1421   *      CALL FUNCTION 'DYNP_GET_STEPL'
1422   *        IMPORTING
1423   *          povstepl        = povstepl
1424   *        EXCEPTIONS
1425   *          stepl_not_found = 1
1426   *          OTHERS          = 2.
1427   *      IF sy-subrc <> 0.
1428   ** Implement suitable error handling here
1429   *      ENDIF.
1430
1431   *      dynfields-fieldname = 'TY_ZHSEAIR_H-COUNTRY'.
1432   *      dynfields-fieldvalue = ty_zhseair_h-country.
1433   *      dynfields-stepl      = povstepl.
1434   *      APPEND dynfields.
1435
1436         CALL FUNCTION 'DYNP_VALUES_UPDATE'
1437           EXPORTING
1438             dyname     = sy-cprog
1439             dynumb     = sy-dynnr
1440           TABLES
1441             dynpfields = dynfields
1442           EXCEPTIONS
1443             OTHERS     = 8.
1444         COMMIT WORK AND WAIT.
1445         REFRESH dynfields.
1446         CLEAR:   dynfields.
1447   *       dynfields-fieldname = 'GWA_IFLO-CNTRY_TXT'.
1448   *      dynfields-fieldvalue = gwa_iflo-cntry_txt.
1449   *      dynfields-stepl      = povstepl.
1450   *      APPEND dynfields.
1451   *      CALL FUNCTION 'DYNP_VALUES_UPDATE'
1452   *        EXPORTING
1453   *          dyname     = sy-cprog
1454   *          dynumb     = sy-dynnr
1455   *        TABLES
1456   *          dynpfields = dynfields
1457   *        EXCEPTIONS
1458   *          OTHERS     = 8.
1459   * commit work and wait.
1460
1461   *      REFRESH dynfields.
1462   *      CLEAR:   dynfields,povstepl.
1463   *
1464   *      CALL FUNCTION 'DYNP_GET_STEPL'
1465   *        IMPORTING
1466   *          povstepl        = povstepl
1467   *        EXCEPTIONS
1468   *          stepl_not_found = 1
1469   *          OTHERS          = 2.
1470   *      IF sy-subrc <> 0.
1471   ** Implement suitable error handling here
1472   *      ENDIF.
1473   *
1474   *   dynfields-fieldname = 'ZOHSE_ACCDT_N-MINES_N'.
1475   *      dynfields-fieldvalue = zohse_accdt_n-mines_n.
1476   *      dynfields-stepl      = povstepl.
1477   *      APPEND dynfields.
1478   *
1479   *      CALL FUNCTION 'DYNP_VALUES_UPDATE'
1480   *        EXPORTING
1481   *          dyname     = sy-cprog
1482   *          dynumb     = sy-dynnr
1483   *        TABLES
1484   *          dynpfields = dynfields
1485   *        EXCEPTIONS
1486   *          OTHERS     = 8.
1487   *
1488   *      REFRESH dynfields.
1489   *      CLEAR:   dynfields,povstepl.
1490   *
1491   *      CALL FUNCTION 'DYNP_GET_STEPL'
1492   *        IMPORTING
1493   *          povstepl        = povstepl
1494   *        EXCEPTIONS
1495   *          stepl_not_found = 1
1496   *          OTHERS          = 2.
1497   *      IF sy-subrc <> 0.
1498   ** Implement suitable error handling here
1499   *      ENDIF.
1500   *
1501   *   dynfields-fieldname = 'ZOHSE_ACCDT_N-CAT_DES'.
1502   *      dynfields-fieldvalue = ZOHSE_ACCDT_N-CAT_DES.
1503   *      dynfields-stepl      = povstepl.
1504   *      APPEND dynfields.
1505   *
1506   *      CALL FUNCTION 'DYNP_VALUES_UPDATE'
1507   *        EXPORTING
1508   *          dyname     = sy-cprog
1509   *          dynumb     = sy-dynnr
1510   *        TABLES
1511   *          dynpfields = dynfields
1512   *        EXCEPTIONS
1513   *          OTHERS     = 8.
1514   * commit work and wait.
1515
1516
1517       ENDIF.
1518     ENDIF.
1519
1520
1521   ENDFORM.
1522   *&---------------------------------------------------------------------*
1523   *&      Form  HELP_BUNIT_HIGH
1524   *&---------------------------------------------------------------------*
1525   *       text
1526   *----------------------------------------------------------------------*
1527   *  -->  p1        text
1528   *  <--  p2        text
1529   *----------------------------------------------------------------------*
1530   FORM help_bunit_high .
1531     TYPES: BEGIN OF lt_acc_bu,
1532              bunit  TYPE zbunit_d,
1533              bu_txt	TYPE pltxt,
1534            END OF lt_acc_bu.
1535
1536     DATA: it_return_bu  LIKE STANDARD TABLE OF ddshretval,
1537           gwa_return_bu LIKE ddshretval.
1538
1539     DATA: lit_acc_bu TYPE STANDARD TABLE OF lt_acc_bu,
1540           lwa_acc_bu TYPE lt_acc_bu.
1541
1542     DATA: lit_bu_fcat TYPE slis_t_fieldcat_alv,
1543           lwa_bu_fcat TYPE slis_fieldcat_alv.
1544
1545     DATA:  ls_tabix_bu TYPE slis_selfield,
1546            lv_row_bu   TYPE i.
1547     DATA: i_selfield TYPE slis_selfield.
1548
1549   *  DATA : ist_return_tab      LIKE STANDARD TABLE OF ddshretval
1550   *                             WITH  HEADER LINE.
1551
1552     REFRESH: it_return_bu,lit_bu_fcat, lit_acc_bu.
1553     CLEAR: ist_return_tab, ls_tabix_bu,lv_row_bu.
1554
1555
1556     lwa_bu_fcat-fieldname  = 'BUNIT'.    " Fieldname in the data table
1557     lwa_bu_fcat-seltext_m  = 'Business Unit'.    " Column description in the output
1558     APPEND lwa_bu_fcat TO lit_bu_fcat.
1559     CLEAR lwa_bu_fcat.
1560
1561     lwa_bu_fcat-fieldname  = 'BU_TXT'.    " Fieldname in the data table
1562     lwa_bu_fcat-seltext_l  = 'Description'.    " Column description in the output
1563     lwa_bu_fcat-outputlen = 32.
1564     APPEND lwa_bu_fcat TO lit_bu_fcat.
1565     CLEAR lwa_bu_fcat.
1566
1567
1568
1569     SELECT * FROM zohse_eff_ep INTO CORRESPONDING FIELDS OF TABLE lit_acc_bu.
1570     IF lit_acc_bu IS NOT INITIAL..
1571       LOOP AT lit_acc_bu INTO lwa_acc_bu.
1572
1573   " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1574   *      SELECT SINGLE pltxt FROM iflotx INTO lwa_acc_bu-bu_txt WHERE tplnr = lwa_acc_bu-bunit.
1575    SELECT PLTXT FROM IFLOTX   UP TO 1 ROWS INTO LWA_ACC_BU-BU_TXT WHERE
1576   TPLNR = LWA_ACC_BU-BUNIT  ORDER BY  TPLNR SPRAS .   ENDSELECT.
1577   " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
1578         MODIFY lit_acc_bu FROM lwa_acc_bu TRANSPORTING bu_txt .
1579         CLEAR lwa_acc_bu.
1580       ENDLOOP.
1581       " BREAK-POINT.
1582   " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1583   SORT LIT_ACC_BU BY BUNIT .
1584   " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1585       DELETE ADJACENT DUPLICATES FROM lit_acc_bu COMPARING bunit.
1586
1587
1588       CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
1589         EXPORTING
1590           i_title       = 'Business Unit'
1591           i_selection   = 'X'
1592           i_zebra       = 'X'
1593           i_tabname     = 'LIT_ACC_DOC'
1594           it_fieldcat   = lit_bu_fcat
1595         IMPORTING
1596           es_selfield   = i_selfield
1597         TABLES
1598           t_outtab      = lit_acc_bu
1599         EXCEPTIONS
1600           program_error = 1
1601           OTHERS        = 2.
1602       IF i_selfield IS NOT INITIAL.
1603   " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1604         READ TABLE lit_acc_bu INTO lwa_acc_bu INDEX i_selfield-tabindex. "#EC CI_NOORDER
1605   " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1606         s_bunit-high = lwa_acc_bu-bunit.
1607   *      gwa_iflo-bu_txt = lwa_acc_bu-bu_txt.
1608
1609         CLEAR i_selfield.
1610
1611       ENDIF.
1612
1613
1614     ENDIF.
1615
1616
1617   ENDFORM.
1618   *&---------------------------------------------------------------------*
1619   *&      Form  HELP_PROJ_HIGH
1620   *&---------------------------------------------------------------------*
1621   *       text
1622   *----------------------------------------------------------------------*
1623   *  -->  p1        text
1624   *  <--  p2        text
1625   *----------------------------------------------------------------------*
1626   FORM help_proj_high .
1627
1628     TYPES: BEGIN OF lt_acc_proj,
1629              proj     TYPE tplnr,
1630              proj_txt TYPE pltxt,
1631            END OF lt_acc_proj.
1632     DATA: povstepl  LIKE  sy-stepl.
1633     DATA: dynfields TYPE TABLE OF dynpread WITH HEADER LINE.
1634
1635     DATA: it_return_proj  LIKE STANDARD TABLE OF ddshretval,
1636           gwa_return_proj LIKE ddshretval,
1637
1638           fl1(18)         TYPE c,
1639           fl2(18)         TYPE c,
1640           fl3(18)         TYPE c,
1641           lv_cont(50)     TYPE c.
1642
1643     DATA: lit_acc_proj TYPE STANDARD TABLE OF lt_acc_proj,
1644           lwa_acc_proj TYPE lt_acc_proj.
1645
1646     DATA:  ls_tabix_proh TYPE slis_selfield,
1647            lv_row_proj   TYPE i.
1648
1649     DATA: p_selfield TYPE slis_selfield.
1650   *  DATA: dynfields TYPE TABLE OF dynpread WITH HEADER LINE.
1651
1652
1653     DATA: lit_proj_fcat TYPE slis_t_fieldcat_alv,
1654           lwa_proj_fcat TYPE slis_fieldcat_alv.
1655     REFRESH: it_return_proj, lit_proj_fcat.
1656     CLEAR: gwa_return_proj,lv_row_proj,lwa_proj_fcat,p_selfield.
1657
1658     lwa_proj_fcat-fieldname  = 'PROJ'.    " Fieldname in the data table
1659     lwa_proj_fcat-seltext_m  = 'Project'.    " Column description in the output
1660     APPEND lwa_proj_fcat TO lit_proj_fcat.
1661     CLEAR lwa_proj_fcat.
1662
1663     lwa_proj_fcat-fieldname  = 'PROJ_TXT'.    " Fieldname in the data table
1664     lwa_proj_fcat-seltext_l  = 'Description'.    " Column description in the output
1665     lwa_proj_fcat-outputlen = 32.
1666     APPEND lwa_proj_fcat TO lit_proj_fcat.
1667     CLEAR lwa_proj_fcat.
1668
1669
1670     SELECT proj
1671            pltxt
1672
1673        FROM zohse_eff_ep INTO  TABLE lit_acc_proj WHERE bunit = s_bunit-high.
1674     IF lit_acc_proj IS NOT INITIAL.
1675   *    LOOP AT lit_acc_proj INTO lwa_acc_proj.
1676   *      AUTHORITY-CHECK OBJECT 'ZOHSE_ACN1'
1677   *              ID 'ACTVT' FIELD '01'
1678   *              ID 'WERKS_A' FIELD zohse_accdt_n-werks
1679   *              ID 'BUNIT_A' FIELD zohse_accdt_n-bunit
1680   *              ID 'PROJ_A' FIELD lwa_acc_proj-proj.
1681   *      IF sy-subrc EQ 0.
1682   *        SELECT SINGLE pltxt FROM iflotx INTO lwa_acc_proj-proj_txt WHERE tplnr = lwa_acc_proj-proj.
1683   *        MODIFY lit_acc_proj FROM lwa_acc_proj TRANSPORTING proj_txt .
1684   *        CLEAR lwa_acc_proj.
1685   *      ELSE.
1686   *        DELETE lit_acc_proj INDEX sy-tabix.
1687   *      ENDIF.
1688   *    ENDLOOP.
1689
1690   " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1691   SORT LIT_ACC_PROJ BY PROJ .
1692   " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1693       DELETE ADJACENT DUPLICATES FROM lit_acc_proj COMPARING proj.
1694
1695       CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
1696         EXPORTING
1697           i_title       = 'Project'
1698           i_selection   = 'X'
1699           i_zebra       = 'X'
1700           i_tabname     = 'LIT_ACC_PROJ'
1701           it_fieldcat   = lit_proj_fcat
1702         IMPORTING
1703           es_selfield   = p_selfield
1704         TABLES
1705           t_outtab      = lit_acc_proj
1706         EXCEPTIONS
1707           program_error = 1
1708           OTHERS        = 2.
1709       IF p_selfield IS NOT INITIAL.
1710   " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1711         READ TABLE lit_acc_proj INTO lwa_acc_proj INDEX p_selfield-tabindex. "#EC CI_NOORDER
1712   " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1713         s_proj-high = lwa_acc_proj-proj.
1714   *      iflotx-pltxt = lwa_acc_proj-proj_txt.
1715         CLEAR p_selfield.
1716
1717         REFRESH dynfields.
1718         CLEAR:   dynfields,povstepl.
1719
1720         CALL FUNCTION 'DYNP_GET_STEPL'
1721           IMPORTING
1722             povstepl        = povstepl
1723           EXCEPTIONS
1724             stepl_not_found = 1
1725             OTHERS          = 2.
1726         IF sy-subrc <> 0.
1727   * Implement suitable error handling here
1728         ENDIF.
1729
1730
1731         dynfields-fieldname = 'S_PROJ-HIGH'.
1732         dynfields-fieldvalue = s_proj-high.
1733         dynfields-stepl      = povstepl.
1734         APPEND dynfields.
1735
1736         CALL FUNCTION 'DYNP_VALUES_UPDATE'
1737           EXPORTING
1738             dyname     = sy-cprog
1739             dynumb     = sy-dynnr
1740           TABLES
1741             dynpfields = dynfields
1742           EXCEPTIONS
1743             OTHERS     = 8.
1744         COMMIT WORK AND WAIT.
1745
1746         REFRESH dynfields.
1747         CLEAR:   dynfields.
1748
1749         dynfields-fieldname = 'IFLOTX-PLTXT'.
1750
1751         dynfields-stepl      = povstepl.
1752         APPEND dynfields.
1753
1754         CALL FUNCTION 'DYNP_VALUES_UPDATE'
1755           EXPORTING
1756             dyname     = sy-cprog
1757             dynumb     = sy-dynnr
1758           TABLES
1759             dynpfields = dynfields
1760           EXCEPTIONS
1761             OTHERS     = 8.
1762         COMMIT WORK AND WAIT.
1763
1764         SPLIT s_proj-high AT '-' INTO fl1 fl2 fl3.
1765
1766         CONCATENATE fl1 fl2 INTO lv_cont SEPARATED BY '-'.
1767
1768
1769         CALL FUNCTION 'DYNP_VALUES_UPDATE'
1770           EXPORTING
1771             dyname     = sy-cprog
1772             dynumb     = sy-dynnr
1773           TABLES
1774             dynpfields = dynfields
1775           EXCEPTIONS
1776             OTHERS     = 8.
1777         COMMIT WORK AND WAIT.
1778         REFRESH dynfields.
1779         CLEAR:   dynfields.
1780
1781       ENDIF.
1782     ENDIF.
1783   ENDFORM.
*--- End of ZPM_AMBIENT_AIR_ANNUAL - 1783 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CSLIS                                   Level 1    Page 2
Object           ZPM_AMBIENT_AIR_ANNUAL                    Lines 543
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:20
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
Object           ZPM_AMBIENT_AIR_ANNUAL                    Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:20
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
Object           ZPM_AMBIENT_AIR_ANNUAL                    Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:20
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
Object           ZPM_AMBIENT_AIR_ANNUAL                    Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:20
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
Object           ZPM_AMBIENT_AIR_ANNUAL                    Lines 1
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:20
----------------------------------------------------------------------------------------------------
1      * INCLUDE DB__SSEL
*--- End of DB__SSEL - 1 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CABAP                                   Level 1    Page 7
Object           ZPM_AMBIENT_AIR_ANNUAL                    Lines 360
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:16:20
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
