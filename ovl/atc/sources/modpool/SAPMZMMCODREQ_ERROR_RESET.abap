----------------------------------------------------------------------------------------------------
Main program     SAPMZMMCODREQ_ERROR_RESET                 Level 0    Page 1
Object           SAPMZMMCODREQ_ERROR_RESET                 Lines 42
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:05
----------------------------------------------------------------------------------------------------
1      *&--------------------------------------------------------------------*
2      *& Module pool       SAPMZMMCODREQ                                    *
3      *                                                                     *
4      * Title      : Material Codification System                           *
5      *                                                                     *
6      * FS No.     : FS-MM-MAT-001                                          *
7      *                                                                     *
8      * Author     : Subodh Kumar           Date : 24/02/2005               *
9      *              G C Uniyal                                             *
10     *              Ajit Singh                                             *
11     *                                                                     *
12     * Login Id   : CAB_SUBODHK                                            *
13     *              CAB_UNIYAL                                             *
14     *              CAB_AJIT                                               *
15     *                                                                     *
16     * Description: This Program generates requests for material           *
17     *              codification + validation, approval, creation, change  *
18     *              deletion & flow is also handled through the system     *
19     *              along  with generation of the material code            *
20     *                                                                     *
21     * Tran. Code : ZMATRESERR                                             *
22     *                                                                     *
23     *                                                                     *
24     *                                                                     *
25     ***********************************************************************
26     ************************************************************************
27     *  Date            Transport      USERID        Description
28     * 30/09/2008      <RD1K960036>    SAB_SUMODH
29     *
30     *1) Change in INCLUDE MZMMCODREQ_ERROR_RESETF01.
31     *2) Change in INCLUDE MZMMCODREQ_ERROR_RESETI01.
32     *
33     *
34     ************************************************************************
35
36     INCLUDE MZMMCODREQ_ERROR_RESETTOP.
37
38     INCLUDE MZMMCODREQ_ERROR_RESETO01.
39
40     INCLUDE MZMMCODREQ_ERROR_RESETI01.
41
42     INCLUDE MZMMCODREQ_ERROR_RESETF01.
*--- End of SAPMZMMCODREQ_ERROR_RESET - 42 lines ---

----------------------------------------------------------------------------------------------------
Include          MZMMCODREQ_ERROR_RESETTOP                 Level 1    Page 2
Object           SAPMZMMCODREQ_ERROR_RESET                 Lines 663
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:05
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *& Include MZMMCODREQTOP                                               *
3      *&                                                                     *
4      *&---------------------------------------------------------------------*
5      PROGRAM  SAPMZMMCODREQ.
6      *******************Tables**********************************************
7      Tables: Mara, Makt, Zmm_cdhd,Zmm_modifier,ZMM_CDHD_ST,
8              ZMM_CODREQ_RSN,t001w,dd07t,zmm_cdcodifier. " zmm_mdl zmm_cditem
9      *******************Types************************************************
10     TYPES: BEGIN OF ty_zmm_mdl,
11       mandt type mandt,
12              reqno            TYPE zmatreqno,
13              srno             type numc3,
14              matcode          TYPE char9,
15              rej_flg          TYPE zrejflag,
16              comp_flg         TYPE zcompflag,
17              rsn              TYPE zrsn,
18              oth1             TYPE char1,
19              desc1            TYPE zdesc_1,
20              oth2             TYPE char1,
21              desc2            TYPE zdesc_2,
22              oth3             TYPE char1,
23              desc3            TYPE zdesc_3,
24              oth4             TYPE char1,
25              desc4            TYPE zdesc_4,
26              steuc            TYPE steuc,
27              user_desc        TYPE zdesc5,
28              desc_fin         TYPE zdesc88,
29              desc_cdcell      TYPE zdesc87,
30              uom              TYPE meins,
31              partno           TYPE mfrpn,
32              cap_code         TYPE zmatcod,
33              cap_name         TYPE zdesc88,
34              subass           TYPE zsubass,
35              spa_grp          TYPE char2,
36              oth_mdl          TYPE char1,
37              mdlno            TYPE ausp-atwrt,
38              manu             TYPE lifnr,
39              auth_vend_code   TYPE lifnr,
40              auth_vend_name   TYPE name1_gp,
41              haz              TYPE stoff,
42              haz_flg          TYPE zhaz,
43              st_cond          TYPE raube,
44              pack_cond        TYPE magrv,
45              grwgt            TYPE brgew,
46              wtunit           TYPE gewei,
47              grvol            TYPE volum,
48              volunit          TYPE voleh,
49              envmat           TYPE zyn,
50              tempcond         TYPE tempb,
51              shlf_life        TYPE zshlf,
52              shlf_life1       TYPE zshlf1,
53              insur_mat        TYPE zyn,
54              crc_mat          TYPE zyn,
55              dms              TYPE doknr,
56              codby            TYPE xubname,
57              coddt            TYPE sydatum,
58              codcrby          TYPE xubname,
59              codcrdt          TYPE sydatum,
60              deprt            TYPE afasl,
61              astcls           TYPE zastcls,
62              mat_life         TYPE zmatlife,
63              matcost          TYPE zmatcost,
64              matcatg          TYPE zmatcatg,
65              matloc           TYPE zmatloc,
66              valcls           TYPE bklas,
67              wrkng_life       TYPE zshlf,
68              matgp            TYPE char2,
69              lvorm            TYPE lvorm,
70              mat_fnd          type num4,
71              dsflag           TYPE zdsflag,
72              taxim            TYPE taxim1,
73            END OF ty_zmm_mdl.
74
75            data: zmm_mdl type ty_zmm_mdl.
76     TYPES: BEGIN OF ty_ZMM_CDITEM,
77       mandt type mandt,
78              reqno            TYPE zmatreqno,
79              srno             TYPE numc3,
80              matcode          TYPE char9,
81              rej_flg          TYPE zrejflag,
82              comp_flg         TYPE zcompflag,
83              rsn              TYPE zrsn,
84              oth1             TYPE char1,
85              desc1            TYPE zdesc_1,
86              oth2             TYPE char1,
87              desc2            TYPE zdesc_2,
88              oth3             TYPE char1,
89              desc3            TYPE zdesc_3,
90              oth4             TYPE char1,
91              desc4            TYPE zdesc_4,
92              steuc            TYPE steuc,
93              user_desc        TYPE zdesc5,
94              desc_fin         TYPE zdesc88,
95              desc_cdcell      TYPE zdesc87,
96              uom              TYPE meins,
97              partno           TYPE mfrpn,
98              cap_code         TYPE zmatcod,
99              cap_name         TYPE zdesc88,
100             subass           TYPE zsubass,
101             spa_grp          TYPE char2,
102             oth_mdl          TYPE char1,
103             mdlno            TYPE ausp-atwrt,
104             manu             TYPE lifnr,
105             auth_vend_code   TYPE lifnr,
106             auth_vend_name   TYPE name1_gp,
107             haz              TYPE stoff,
108             haz_flg          TYPE zhaz,
109             st_cond          TYPE raube,
110             pack_cond        TYPE magrv,
111             grwgt            TYPE brgew,
112             wtunit           TYPE gewei,
113             grvol            TYPE volum,
114             volunit          TYPE voleh,
115             envmat           TYPE zyn,
116             tempcond         TYPE tempb,
117             shlf_life        TYPE zshlf,
118             shlf_life1       TYPE zshlf1,
119             insur_mat        TYPE zyn,
120             crc_mat          TYPE zyn,
121             dms              TYPE doknr,
122             codby            TYPE xubname,
123             coddt            TYPE sydatum,
124             codcrby          TYPE xubname,
125             codcrdt          TYPE sydatum,
126             deprt            TYPE afasl,
127             astcls           TYPE zastcls,
128             mat_life         TYPE zmatlife,
129             matcost          TYPE zmatcost,
130             matcatg          TYPE ausp-atwrt,
131             matloc           TYPE ausp-atwrt,
132             valcls           TYPE bklas,
133             wrkng_life       TYPE zshlf,
134             matgp            TYPE char2,
135             lvorm            TYPE lvorm,
136             mat_fnd          TYPE numc4,
137             dsflag           TYPE zdsflag,
138             taxim            TYPE taxim1,
139          END OF ty_ZMM_CDITEM.
140          data: ZMM_CDITEM type ty_ZMM_CDITEM.
141    Types : Begin of ty_srchlp,
142              mark,
143              srno   type i,
144              matnr  like mara-matnr,
145              lineno type i,
146    *---------
147    *          maktx  like makt-maktx,
148              wrkst  like mara-wrkst,
149              maktg  like makt-maktg,
150              maktx(88),
151    *--------
152              meins  like mara-meins,
153              mfrpn  like mara-mfrpn,
154    *--------
155              mfrnr  like mara-MFRNR,  "Manufacturer
156              atwrt  like ausp-atwrt,  "capital equipment code
157              mdlno  like ausp-atwrt,  "model number
158              Filter_flag ,
159            End of ty_srchlp,
160
161            Begin of ty_message,
162              srno(3)  type c,
163              msgtype  type c,
164              msgcode  type c,
165              msgtext(80) type c,
166            End of ty_message,
167
168            Begin of ty_alpha_num1,
169              alpha type c,
170              number(3) type c,
171            End of ty_alpha_num1.
172
173    Data : wa_message type ty_message.
174    Data : ist_message like standard table of wa_message.
175    Data : it_alpha_num1 type standard table of ty_alpha_num1 with header
176    line.
177
178    data : begin of A,
179             mark,
180             A like zmm_cditem,
181           end of A.
182    Data: wa_spatbl like A.
183    Types : char20(20) type c.
184    ************************************************************************
185    ********Type define for displaying only selected option from the status.
186    ************************************************************************
187    Types: Begin of tab_type,
188             fcode like RSMPE-FUNC,
189           end of tab_type,
190           Begin of ty_alphanum,
191              alphanum(1) type c,
192           end of ty_alphanum.
193    Data: it_tab1 type standard table of tab_type with
194          non-unique default key initial size 10,
195          wa_tab type tab_type.
196
197    ******************Structures********************************************
198    Data: wa_srchlp type ty_srchlp,
199          wa_srchlpmk03 type ty_srchlp.
200    Data: wa_srchlp1 like wa_srchlp.
201    Data: wa_codmod  like zmm_modifier.
202    Data: wa_alphanum type ty_alphanum.
203    Data: wa_char type c.
204    Data: ist_alphanum type table of ty_alphanum.
205    DATA: alpha(26) type c value 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.
206    Data: ist_codmod like table of wa_codmod.
207    Data: ist_spatbl like table of wa_spatbl.
208    ******************Internal Tables***************************************
209    Data: ist_srchlp like standard table of wa_srchlp,
210          ist_srchlp_cp like standard table of wa_srchlp,
211          ist_srchlp_cpo like standard table of wa_srchlp,
212          it_cap_group1 like standard table of zmm_cap_group with header
213    line
214    .
215
216    data: OK_CODE      like sy-ucomm.
217    Data: G_OK_CODE115 like sy-ucomm.
218    Data: g_spr_par(3) type c.
219    *****************Data Screen-100*******************************
220    Data: g_mode(3)  type c,
221          okcode_100 like sy-ucomm.
222    DATA  dynnr like sy-dynnr.
223
224    Data : G_sel_col(30),
225           g_cursor_line like sy-stepl,
226           g_curr_line like sy-stepl.
227    Data : g_mattytext like DD07V-DDTEXT,
228           g_plantdesc like t001w-name1,
229           g_locdesc   like dd07v-ddtext.
230    *&spwizard: declaration of tablecontrol 'TABCTRL100' itself
231    controls: TABCTRL100 type tableview using screen 0100.
232    DATA cols LIKE LINE OF TABCTRL100-cols.
233
234    *&spwizard: lines of tablecontrol 'TABCTRL100'
235    data:     g_TABCTRL100_lines  like sy-loopc.
236
237    *&spwizard: type for the data of tablecontrol 'TABCTRL110'
238    types: begin of t_TABCTRL110,
239             FLAG,
240             SRNO like ZMM_CDITEM-SRNO,
241             MATCODE like ZMM_CDITEM-MATCODE,
242             rej_flg like ZMM_CDITEM-REJ_FLG,
243             COMP_FLG like ZMM_CDITEM-COMP_FLG,
244             RSN like ZMM_CDITEM-RSN,
245             OTH1 like ZMM_CDITEM-OTH1,
246             DESC1 like ZMM_CDITEM-DESC1,
247             OTH2 like ZMM_CDITEM-OTH2,
248             DESC2 like ZMM_CDITEM-DESC2,
249             OTH3 like ZMM_CDITEM-OTH3,
250             DESC3 like ZMM_CDITEM-DESC3,
251             OTH4 like ZMM_CDITEM-OTH4,
252             DESC4 like ZMM_CDITEM-DESC4,
253             USER_DESC like ZMM_CDITEM-USER_DESC,
254             DESC_FIN like ZMM_CDITEM-DESC_FIN,
255             UOM like ZMM_CDITEM-UOM,
256    *         HAZ like ZMM_CDITEM-HAZ,
257             HAZ_FLG like ZMM_CDITEM-HAZ_FLG,
258             ST_COND like ZMM_CDITEM-ST_COND,
259             PACK_COND like ZMM_CDITEM-PACK_COND,
260             GRWGT like ZMM_CDITEM-GRWGT,
261             WTUNIT like ZMM_CDITEM-WTUNIT,
262             GRVOL like ZMM_CDITEM-GRVOL,
263             VOLUNIT like ZMM_CDITEM-VOLUNIT,
264             ENVMAT like ZMM_CDITEM-ENVMAT,
265             TEMPCOND like ZMM_CDITEM-TEMPCOND,
266             SHLF_LIFE like ZMM_CDITEM-SHLF_LIFE,
267             INSUR_MAT like ZMM_CDITEM-INSUR_MAT,
268             CRC_MAT like ZMM_CDITEM-CRC_MAT,
269             DMS like ZMM_CDITEM-DMS,
270             CODBY like ZMM_CDITEM-CODBY,
271             CODDT like ZMM_CDITEM-CODDT,
272             matgp like ZMM_CDITEM-matgp,
273             req_lt,     " for requisitioner bush button
274    *         flag,       "flag for mark column
275             mat_fnd like zmm_cditem-mat_fnd,
276             dsflag type c,
277           end of t_TABCTRL110.
278
279    *&spwizard: internal table for tablecontrol 'TABCTRL110'
280    data:     g_TABCTRL110_itab   type t_TABCTRL110 occurs 0,
281              g_TABCTRL110_wa     type t_TABCTRL110. "work area
282    data:     g_TABCTRL110_copied.           "copy flag
283
284    data : wa_zmm_cditem like zmm_cditem.
285    data : ist_zmm_cditem like table of wa_zmm_cditem with header line.
286    Data:  g_itab_del110  type T_TABCTRL110 OCCURS 0.
287
288    *&spwizard: declaration of tablecontrol 'TABCTRL110' itself
289    controls: TABCTRL110 type tableview using screen 0110.
290
291    *&spwizard: lines of tablecontrol 'TABCTRL110'
292    data:     g_TABCTRL110_lines  like sy-loopc.
293
294    ****Long Text for 110*******************************************
295    DATA: ist_textid like thead,
296          wa_textid  like thead,
297          ist_textid_items like thead occurs 0.
298    DATA : BEGIN OF ist_dtspecs OCCURS 0.
299            INCLUDE STRUCTURE tline.
300    DATA : END OF ist_dtspecs.
301    Data : g_stxl like stxl.
302    ******************Screen-130******************************************
303    *&spwizard: type for the data of tablecontrol 'TABLCTRL130'
304    types: begin of t_TABLCTRL130,
305             SRNO like ZMM_CDITEM-SRNO,
306             MATCODE like ZMM_CDITEM-MATCODE,
307             COMP_FLG like ZMM_CDITEM-COMP_FLG,
308             rej_flg like ZMM_CDITEM-REJ_FLG,
309             RSN like ZMM_CDITEM-RSN,
310             OTH1 like ZMM_CDITEM-OTH1,
311             DESC1 like ZMM_CDITEM-DESC1,
312             USER_DESC like ZMM_CDITEM-USER_DESC,
313             DESC_FIN like ZMM_CDITEM-DESC_FIN,
314             UOM like ZMM_CDITEM-UOM,
315             HAZ_FLG like ZMM_CDITEM-HAZ_FLG,
316             ST_COND like ZMM_CDITEM-ST_COND,
317             PACK_COND like ZMM_CDITEM-PACK_COND,
318             GRWGT like ZMM_CDITEM-GRWGT,
319             WTUNIT like ZMM_CDITEM-WTUNIT,
320             GRVOL like ZMM_CDITEM-GRVOL,
321             VOLUNIT like ZMM_CDITEM-VOLUNIT,
322             ENVMAT like ZMM_CDITEM-ENVMAT,
323             TEMPCOND like ZMM_CDITEM-TEMPCOND,
324             SHLF_LIFE like ZMM_CDITEM-SHLF_LIFE,
325             INSUR_MAT like ZMM_CDITEM-INSUR_MAT,
326             CRC_MAT like ZMM_CDITEM-CRC_MAT,
327             DMS like ZMM_CDITEM-DMS,
328             CODBY like ZMM_CDITEM-CODBY,
329             CODDT like ZMM_CDITEM-CODDT,
330             matgp like ZMM_CDITEM-matgp,
331             MATCOST like ZMM_CDITEM-MATCOST,
332             MATCATG like ZMM_CDITEM-matcatg,
333             MATLOC like ZMM_CDITEM-matloc,
334             WRKNG_LIFE like ZMM_CDITEM-WRKNG_LIFE,
335             SPA_GRP like ZMM_CDITEM-SPA_GRP,
336             dsflag type c,
337             req_lt,     " for requisitioner bush button
338             flag,       "flag for mark column
339             mat_fnd like zmm_cditem-mat_fnd,
340           end of t_TABLCTRL130.
341
342    *&spwizard: internal table for tablecontrol 'TABLCTRL130'
343    data:     g_TABLCTRL130_itab   type t_TABLCTRL130 occurs 0,
344              g_TABLCTRL130_wa     type t_TABLCTRL130. "work area
345    data:     g_TABLCTRL130_copied.           "copy flag
346
347    *&spwizard: declaration of tablecontrol 'TABLCTRL130' itself
348    controls: TABLCTRL130 type tableview using screen 0130.
349
350    *&spwizard: lines of tablecontrol 'TABLCTRL130'
351    data:     g_TABLCTRL130_lines  like sy-loopc.
352    DATA      g_CURFIELD(40).
353    Data:     g_itab_del130  type T_TABLCTRL130 OCCURS 0.
354
355    ******************Screen-140******************************************
356    *&spwizard: type for the data of tablecontrol 'TABLCTRL140'
357    types: begin of t_TABLCTRL140,
358             SRNO like ZMM_CDITEM-SRNO,
359             MATCODE like ZMM_CDITEM-MATCODE,
360             COMP_FLG like ZMM_CDITEM-COMP_FLG,
361             RSN like ZMM_CDITEM-RSN,
362             OTH1 like ZMM_CDITEM-OTH1,
363             DESC1 like ZMM_CDITEM-DESC1,
364             USER_DESC like ZMM_CDITEM-USER_DESC,
365             DESC_FIN like ZMM_CDITEM-DESC_FIN,
366             UOM like ZMM_CDITEM-UOM,
367    *         HAZ like ZMM_CDITEM-HAZ,
368             HAZ_FLG like ZMM_CDITEM-HAZ_FLG,
369             ST_COND like ZMM_CDITEM-ST_COND,
370             PACK_COND like ZMM_CDITEM-PACK_COND,
371             GRWGT like ZMM_CDITEM-GRWGT,
372             WTUNIT like ZMM_CDITEM-WTUNIT,
373             GRVOL like ZMM_CDITEM-GRVOL,
374             VOLUNIT like ZMM_CDITEM-VOLUNIT,
375             ENVMAT like ZMM_CDITEM-ENVMAT,
376             TEMPCOND like ZMM_CDITEM-TEMPCOND,
377             SHLF_LIFE like ZMM_CDITEM-SHLF_LIFE,
378             INSUR_MAT like ZMM_CDITEM-INSUR_MAT,
379             CRC_MAT like ZMM_CDITEM-CRC_MAT,
380             DMS like ZMM_CDITEM-DMS,
381             CODBY like ZMM_CDITEM-CODBY,
382             CODDT like ZMM_CDITEM-CODDT,
383             dsflag type c,
384             req_lt,     " for requisitioner bush button
385             flag,       "flag for mark column
386           end of t_TABLCTRL140.
387
388    *&spwizard: internal table for tablecontrol 'TABLCTRL140'
389    data:     g_TABLCTRL140_itab   type t_TABLCTRL140 occurs 0,
390              g_TABLCTRL140_wa     type t_TABLCTRL140. "work area
391    data:     g_TABLCTRL140_copied.           "copy flag
392
393    *&spwizard: declaration of tablecontrol 'TABLCTRL140' itself
394    controls: TABLCTRL140 type tableview using screen 0140.
395
396    *&spwizard: lines of tablecontrol 'TABLCTRL140'
397    data:     g_TABLCTRL140_lines  like sy-loopc.
398    Data:     g_itab_del140  type T_TABLCTRL140 OCCURS 0.
399
400    ******************Screen-120******************************************
401    *&spwizard: type for the data of tablecontrol 'TABLCTRL120'
402    types: begin of t_TABLCTRL120,
403             SRNO like ZMM_CDITEM-SRNO,
404             MATCODE like ZMM_CDITEM-MATCODE,
405             rej_flg like ZMM_CDITEM-REJ_FLG,
406             COMP_FLG like ZMM_CDITEM-COMP_FLG,
407             RSN like ZMM_CDITEM-RSN,
408             PARTNO like ZMM_CDITEM-PARTNO,
409             OTH1 like ZMM_CDITEM-OTH1,
410             DESC1 like ZMM_CDITEM-DESC1,
411             USER_DESC like ZMM_CDITEM-USER_DESC,
412             DESC_FIN like ZMM_CDITEM-DESC_FIN,
413             UOM like ZMM_CDITEM-UOM,
414             CAP_CODE like ZMM_CDITEM-CAP_CODE,
415             CAP_NAME like ZMM_CDITEM-CAP_NAME,
416             OTH_MDL  like ZMM_CDITEM-OTH_MDL,
417             MDLNO like ausp-atwrt,
418             MANU like ZMM_CDITEM-MANU,
419    *         HAZ like ZMM_CDITEM-HAZ,
420             HAZ_FLG like ZMM_CDITEM-HAZ_FLG,
421             ST_COND like ZMM_CDITEM-ST_COND,
422             PACK_COND like ZMM_CDITEM-PACK_COND,
423             GRWGT like ZMM_CDITEM-GRWGT,
424             WTUNIT like ZMM_CDITEM-WTUNIT,
425             GRVOL like ZMM_CDITEM-GRVOL,
426             VOLUNIT like ZMM_CDITEM-VOLUNIT,
427             ENVMAT like ZMM_CDITEM-ENVMAT,
428             TEMPCOND like ZMM_CDITEM-TEMPCOND,
429             SHLF_LIFE like ZMM_CDITEM-SHLF_LIFE,
430             INSUR_MAT like ZMM_CDITEM-INSUR_MAT,
431             CRC_MAT like ZMM_CDITEM-CRC_MAT,
432             DMS like ZMM_CDITEM-DMS,
433             CODBY like ZMM_CDITEM-CODBY,
434             CODDT like ZMM_CDITEM-CODDT,
435             matgp like ZMM_CDITEM-matgp,
436             req_lt,     " for requisitioner bush button
437             flag,       "flag for mark column
438             mat_fnd like zmm_cditem-mat_fnd,
439             dsflag type c,
440           end of t_TABLCTRL120.
441
442    *&spwizard: internal table for tablecontrol 'TABLCTRL120'
443    data:     g_TABLCTRL120_itab   type t_TABLCTRL120 occurs 0,
444              g_TABLCTRL120_wa     type t_TABLCTRL120. "work area
445    data:     g_TABLCTRL120_copied.           "copy flag
446
447    *&spwizard: declaration of tablecontrol 'TABLCTRL120' itself
448    controls: TABLCTRL120 type tableview using screen 0120.
449
450    *&spwizard: lines of tablecontrol 'TABLCTRL120'
451    data:     g_TABLCTRL120_lines  like sy-loopc.
452    Data:     g_itab_del120  type T_TABLCTRL120 OCCURS 0.
453
454    Data : ist_sval1 like sval  occurs 0 with header line.
455    Data : ist_sval2 like sval  occurs 0 with header line.
456    Data : ist_sval3 like sval  occurs 0 with header line.
457    Data : ist_sval4 like sval  occurs 0 with header line.
458
459    **********************Global Data*****************************
460    DATA  sel_flag.
461    DATA  desc(22).
462    data  DESC11(25).
463    data  DESC22(20).
464    data  DESC33(20).
465    data  DESC44(18).
466    DATA  DESC55 like zmm_cditem-user_desc.
467    DATA  DESCP5 like zmm_cditem-user_desc.
468
469    DATA  FIELD(30).
470    DATA  FIELD1(30).
471    DATA  g_matgp(9).
472    DATA  g_matgpo(2).
473    Data  g_reqno(10).
474    Data  g_request_no(10).
475    DATA  l_MATTYPE.
476    DATA  g_MATTY(4).
477    DATA  g_lineno type i.
478    DATA  descp1(25).
479    DATA  descp2(20).
480    DATA  descp3(20).
481    DATA  descp4(18).
482    DATA  check_pos.
483    DATA  g_parno.
484    Data  g_user_desc(87).  "pop up
485    DATA  user_desc_len type i.  "pop up
486    DATA  g_partnoc like zmm_cditem-partno.
487    DATA  g_partno(80) type c.
488    DATA  G_FIELD(40).
489    DATA  check_flag.
490    DATA  check_flag1.
491    DATA : G_Desc1(25),G_Desc2(20),G_Desc3(20),G_Desc4(18).
492    DATA  G_screen115_1st.
493    DATA  check_flag2.
494    DATA  g_hd_copied.
495    DATA  g_desc1_4(87).
496    DATA  g_choice.
497    Data: begin of wa_spell_line,
498            tdformat like tline-tdformat,
499            tdline like tline-tdline,
500            srno   like zmm_cditem-srno,
501            spell_err,
502          End of wa_spell_line.
503
504    DATA  ist_spell_line like table of wa_spell_line with header line.
505    DATA  IST_SPELL_LINE1 like table of wa_spell_line with header line.
506    Data : ist_sval like sval  occurs 0 with header line.   "GZSPR
507    Data : ist_mdl like table of zmm_mdl with header line.  "GZSPR
508
509    Data  g_user. " value 'X'.
510    DATA  g_other.
511    Data  g_spellcheck.
512    DATA  g_spellerror.
513
514    *---------------------------------------------------------------------*
515    * Tree
516    *---------------------------------------------------------------------*
517    DATA: GV_SPLITTER TYPE REF TO CL_GUI_EASY_SPLITTER_CONTAINER,
518          GV_SPLITTER1 TYPE REF TO CL_GUI_EASY_SPLITTER_CONTAINER,
519          GV_SPLITTER2 TYPE REF TO CL_GUI_EASY_SPLITTER_CONTAINER.
520
521    DATA: GV_CUSTOM_CONTAINER TYPE REF TO CL_GUI_CUSTOM_CONTAINER.
522
523    DATA: GV_TEXT_EDITOR TYPE REF TO CL_GUI_TEXTEDIT,
524          GV_TEXT_EDITOR1 TYPE REF TO CL_GUI_TEXTEDIT,
525          GV_TEXT_EDITOR2 TYPE REF TO CL_GUI_TEXTEDIT .
526
527    DATA : DISPLAY_FLAG LIKE  LV70T-XFLAG VALUE SPACE.
528
529    DATA: BEGIN OF TLINETAB OCCURS 10.
530            INCLUDE STRUCTURE TLINE.
531    DATA: END OF TLINETAB.
532    DATA: BEGIN OF TLINETAB1 OCCURS 20.
533            INCLUDE STRUCTURE TLINE.
534    DATA: END OF TLINETAB1.
535    DATA: BEGIN OF TLINETAB2 OCCURS 20.
536            INCLUDE STRUCTURE TLINE.
537    DATA: END OF TLINETAB2.
538
539    CONSTANTS: GC_TEXT_LINE_LENGTH TYPE I VALUE 132.
540
541    TYPES: TEXT_TABLE_TYPE(GC_TEXT_LINE_LENGTH) TYPE C OCCURS 0.
542
543    DATA: LT_TEXT_TABLE TYPE TEXT_TABLE_TYPE,
544          LT_TEXT_TABLE1 TYPE TEXT_TABLE_TYPE,
545          LT_TEXT_TABLE2 TYPE TEXT_TABLE_TYPE.
546
547
548    DATA: GV_XTHEAD_UPDKZ TYPE I.
549
550    DATA: BEGIN OF TINLINETAB OCCURS 10.
551            INCLUDE STRUCTURE TLINE.
552    DATA: END OF TINLINETAB.
553
554    DATA: LS_THEAD LIKE THEAD OCCURS 0 WITH HEADER LINE.
555
556    DATA : L_THEAD LIKE LS_THEAD OCCURS 0 WITH HEADER LINE.
557
558    DATA  G_TDNAME(12).
559
560    DATA: BEGIN OF LINES OCCURS 20.
561            INCLUDE STRUCTURE TLINE.
562    DATA: END OF LINES.
563
564    Data: g2_lines like tline.
565
566    DATA: BEGIN OF LINES_CORS OCCURS 20.
567            INCLUDE STRUCTURE TLINE.
568    DATA: END OF LINES_CORS.
569
570    DATA: BEGIN OF g_LINES OCCURS 20.
571            INCLUDE STRUCTURE TLINE.
572    DATA: END OF g_LINES.
573
574
575    DATA  g_mat_fnd type sy-index.
576    DATA  g_curr_line_110 like sy-stepl.
577    DATA  g_curr_line_120 like sy-stepl.
578    DATA  g_curr_line_100 like sy-stepl.
579    DATA  g_insrflg.
580
581    Data  g_cores_sender like tline-tdline.
582
583    DATA  seltab like rsparams.
584    DATA  ist_seltab like table of rsparams.
585    DATA  wa_rsn like ZMM_CODREQ_RSN.
586    DATA  matgen_flag.
587    DATA  TABCTRL110_check_flag.
588
589    DATA  app_fl2.
590    DATA  g_hits_par.
591    DATA  g_matcode like ZMM_CDITEM-MATCODE.
592    DATA  g_lineno_old like g_lineno.
593    DATA  do_not_change_flag.
594    DATA  g_mat_fnd_flag.
595    DATA  check_others.
596    DATA  g_desc_flag.
597    DATA  g_saveflag.
598    DATA  g_spell_check.
599    DATA  g_check_flag.
600    DATA  ist_modifier_check_list like table of zmm_modifier with header
601    line.
602    DATA  check_list_lines like sy-index.
603    DATA  wa_modifier_check_list like zmm_modifier.
604    DATA  g_long_text_warning.
605    DATA  g_hits_par_oth.
606    DATA  matgrp_change_flag.
607    DATA  matgrp_orig like ZMM_CDITEM-matgp.
608    Data: G_OK_CODE110 like sy-ucomm.
609    *+
610    DATA  g_modi_exists.
611    DATA  g_curr_line1 like g_curr_line.
612    DATA: BEGIN OF CHECKTAB OCCURS 0,
613           BEGRIFF(60),
614           TERMBEGR(60),
615           ART(1),
616          END OF CHECKTAB.
617    DATA  g_user_found.
618    Data g_oth.
619    DATA check_code like sy-ucomm.
620    DATA  g_lock.
621    DATA  check_lines like sy-index.
622    DATA: wa_tabctrl110_cols like line of tabctrl110-cols,
623          wa_tablctrl120_cols like line of tablctrl120-cols,
624          wa_tablctrl130_cols like line of tablctrl130-cols,
625          wa_tablctrl140_cols like line of tablctrl140-cols.
626    DATA: g_filname(40) type c,
627          g_filval(40) type c.
628    DATA  g_filname1(40) type c.
629    DATA  g_delflag.
630    DATA  g_sel_colsort(40) type c.
631    *******************************************************************
632    DATA  g_line132(132) type c.
633    Data:Begin of g_linefrto ,
634           line_fr type i,
635           line_to type i,
636          End of g_linefrto.
637    Data: g_linefrto_itab like table of g_linefrto.
638    DATA  g_matgp_desc(20).
639    DATA  g_sh_partno.
640    Data  g_cors.
641    DATA  g_order(10) type c.
642    Data : g_sh_capeqt , g_sh_mdlno, g_sh_mfr.
643    DATA  g_fst_srchlp.
644    DATA  g_curs_ln type i.
645    DATA  g_mfrnr type lif16.
646    DATA  g_techapr_visible.
647    DATA  g_req_change.
648    DATA  IST_SVAL_org(30).
649    DATA  g_cursor_fld130(40).
650    DATA  g_curr_line_130 type sy-stepl.
651    DATA  g_atinn like cabn-atinn.
652    DATA  g_atwrt like ausp-atwrt.
653    DATA  g_confdel.
654    DATA  g_curfield110(40).
655    DATA  g_curfield120(40).
656    DATA  g_curfield130(40).
657    DATA  g_matgp_selected.
658    Data  g_change_auth.
659    DATA  it_cap_group.
660    DATA  it_alpha_num.
661    DATA  a_choice.
662    DATA  g_srno type ZMM_CDITEM-SRNO.
663    *Data  g_curs_ln1 type sy-tabix.
*--- End of MZMMCODREQ_ERROR_RESETTOP - 663 lines ---

----------------------------------------------------------------------------------------------------
Include          MZMMCODREQ_ERROR_RESETO01                 Level 1    Page 3
Object           SAPMZMMCODREQ_ERROR_RESET                 Lines 3247
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:05
----------------------------------------------------------------------------------------------------
1      ***INCLUDE MZMMCODREQO01 .
2      *&spwizard: output module for tc 'TABCTRL100'. do not change this line!
3      *&spwizard: update lines for equivalent scrollbar
4      module TABCTRL100_change_tc_attr output.
5        describe table IST_SRCHLP lines TABCTRL100-lines.
6      endmodule.
7
8      *&spwizard: output module for tc 'TABCTRL100'. do not change this line!
9      *&spwizard: get lines of tablecontrol
10     module TABCTRL100_get_lines output.
11      if wa_srchlp-filter_flag = ''.
12       g_TABCTRL100_lines = sy-loopc.
13      endif.
14     endmodule.
15
16
17     *&spwizard: output module for tc 'TABCTRL110'. do not change this line!
18     *&spwizard: copy ddic-table to itab
19     module TABCTRL110_init output.
20     ******Local data********
21       Data: l_110lns type i,
22             l_tdname like thead-tdname,
23             l_stxl   like stxl.
24
25     *************************
26     *  check_code = sy-ucomm.
27       clear : g_ok_code110 , sy-ucomm , g_ok_code115.
28
29     *refresh ist_message.
30
31     *&spwizard: copy ddic-table 'ZMM_CDITEM'
32     *&spwizard: into internal table 'g_TABCTRL110_itab'
33     *****Addition*****************
34       IF g_TABCTRL110_copied is initial.
35         if ( g_mode <> 'CRE' and ZMM_CDHD_ST-MTART = 'ZSTO' )
36            or g_mode = 'REL'.
37
38           select * from ZMM_CDITEM
39              into corresponding fields
40              of table g_TABCTRL110_itab
41           where reqno = zmm_cdhd_st-reqno ORDER BY PRIMARY KEY.
42         endif.
43     ***to delete the internal table entries which does not
44     ***belongs to a partiular codifier's assigned class.
45         if sy-tcode = 'ZCODG'.
46           select single * from zmm_cdcodifier
47                  where codifier = sy-uname.
48           if sy-subrc = 0.
49            loop at g_TABCTRL110_itab into g_tabctrl110_wa.
50             select single * from zmm_cdcodifier
51                    where codifier = sy-uname
52                    and   matgp    = g_tabctrl110_wa-matgp.
53             if sy-subrc <> 0.
54              delete g_TABCTRL110_itab index sy-tabix.
55             endif.
56            endloop.
57           endif.
58         endif.
59     ****
60
61         g_TABCTRL110_copied = 'X'.
62         refresh control 'TABCTRL110' from screen '0110'.
63       ENDIF.
64     **********************************************
65     ***To check, if long text maintained or not
66       Case g_mode.
67         WHEN 'CRE'.
68           IF not g_TABCTRL110_itab[] is initial.
69             loop at g_TABCTRL110_itab into g_TABCTRL110_wa.
70               concatenate 'CDDS' '9999999999' g_TABCTRL110_wa-srno
71                into l_tdname.
72               perform check_lt_exist using l_tdname.
73               if not g_lines[] is initial.
74                 read table g_lines into g2_lines index 1.
75                 if not g2_lines-tdline is initial.
76                   g_TABCTRL110_wa-dsflag = 'X'.
77                   modify g_TABCTRL110_itab from g_TABCTRL110_wa
78                       transporting dsflag
79                       where srno = g_TABCTRL110_wa-srno.
80                   clear g_TABCTRL110_wa-dsflag.
81                 else.
82                   g_TABCTRL110_wa-dsflag = ''.
83                   modify g_TABCTRL110_itab from g_TABCTRL110_wa
84                       transporting dsflag
85                       where srno = g_TABCTRL110_wa-srno.
86                 endif.
87                 clear g2_lines.
88               endif.
89             endloop.
90           ENDIF.
91         WHEN 'CHA' OR 'DIS' OR 'DEL' OR 'REL'.
92           loop at g_TABCTRL110_itab into g_TABCTRL110_wa.
93             concatenate 'CDDS' zmm_cdhd_st-reqno g_TABCTRL110_wa-srno
94             into l_tdname.
95             perform check_lt_exist using l_tdname.
96             if not g_lines[] is initial.
97               read table g_lines into g2_lines index 1.
98               if not g2_lines-tdline is initial.
99                 g_TABCTRL110_wa-dsflag = 'X'.
100                modify g_TABCTRL110_itab from g_TABCTRL110_wa
101                     transporting dsflag
102                     where srno = g_TABCTRL110_wa-srno.
103                clear g_TABCTRL110_wa-dsflag.
104              else.
105                g_TABCTRL110_wa-dsflag = ''.
106                modify g_TABCTRL110_itab from g_TABCTRL110_wa
107                     transporting dsflag
108                     where srno = g_TABCTRL110_wa-srno.
109              endif.
110              clear g2_lines.
111            endif.
112          endloop.
113      ENDCASE.
114
115    **********************************************
116      if ( g_mode = 'CRE' ) OR ( g_mode = 'CHA' ).
117        describe table g_TABCTRL110_itab lines l_110lns.
118        if l_110lns < 99.
119          TABCTRL110-lines = 99.
120        endif.
121      endif.
122    endmodule.
123
124    *&spwizard: output module for tc 'TABCTRL110'. do not change this line!
125    *&spwizard: move itab to dynpro
126    module TABCTRL110_move output.
127      Data: l_srno type i,
128            l_srnoflag type c,
129            l_itab110 type t_TABCTRL110.
130    *************************************************************
131
132      move-corresponding g_TABCTRL110_wa to ZMM_CDITEM.
133      if ( g_mode = 'CRE' ) OR
134         ( g_mode = 'CHA' ) OR
135         ( g_mode = 'REL' ).
136       concatenate g_TABCTRL110_wa-desc1
137                   g_TABCTRL110_wa-desc2
138                   g_TABCTRL110_wa-desc3
139                   g_TABCTRL110_wa-desc4
140                   g_TABCTRL110_wa-user_desc
141              into g_TABCTRL110_wa-desc_fin
142              separated by space.
143
144        condense g_TABCTRL110_wa-desc_fin.
145
146        IF not g_TABCTRL110_wa-desc_fin is initial.
147    *     move TABCTRL110-current_line
148    *       to g_TABCTRL110_wa-SRNO.
149    **********To get the maximum srno in the internal table***
150          clear: l_srno,l_srnoflag.
151          describe table g_TABCTRL110_itab lines l_srno.
152          while l_srnoflag <> 'S'.
153            read table g_TABCTRL110_itab into l_itab110
154                 with key srno = l_srno.
155            if sy-subrc <> 0.
156              l_srnoflag = 'S'.
157            else.
158              l_srno = l_srno + 1.
159            endif.
160          endwhile.
161    ************************************************************
162          if g_TABCTRL110_wa-SRNO = 0.
163            move l_srno to g_TABCTRL110_wa-SRNO.
164          endif.
165        ENDIF.
166
167    *
168        if TABCTRL110-current_line = g_curr_line_110.
169
170          if not g_mat_fnd is initial.
171            move g_mat_fnd to ZMM_CDITEM-mat_fnd.
172           else.
173            if do_not_change_flag = 'X'.
174    *            move g_mat_fnd to ZMM_CDITEM-mat_fnd.
175              clear do_not_change_flag.
176            else.
177              move g_TABCTRL110_wa-mat_fnd to ZMM_CDITEM-mat_fnd.
178            endif.
179            if g_mat_fnd_flag = 'X'.
180              move g_mat_fnd to ZMM_CDITEM-mat_fnd.
181              clear g_mat_fnd_flag.
182            endif.
183          endif.
184
185        endif.
186
187        if g_TABCTRL110_wa-dsflag = 'X'.
188          g_long_text_warning = 'X'.
189        endif.
190
191        move g_TABCTRL110_wa-SRNO to ZMM_CDITEM-SRNO.
192        move g_TABCTRL110_wa-desc_fin to ZMM_CDITEM-desc_fin.
193      endif.
194    ******
195      IF sy-tcode = 'ZCODG'.
196        concatenate g_TABCTRL110_wa-desc1
197                    g_TABCTRL110_wa-desc2
198                    g_TABCTRL110_wa-desc3
199                    g_TABCTRL110_wa-desc4
200                    g_TABCTRL110_wa-user_desc
201              into  g_TABCTRL110_wa-desc_fin
202              separated by space.
203
204        condense g_TABCTRL110_wa-desc_fin.
205        move g_TABCTRL110_wa-desc_fin to ZMM_CDITEM-desc_fin.
206      ENDIF.
207    endmodule.
208    ***********************************************************************
209    *&spwizard: output module for tc 'TABCTRL110'. do not change this line!
210    *&spwizard: get lines of tablecontrol
211    module TABCTRL110_get_lines output.
212      g_TABCTRL110_lines = sy-loopc.
213    endmodule.
214    ************************************************************************
215    *&spwizard: output module for tc 'TABLCTRL130'. do not change this line!
216    *&spwizard: copy ddic-table to itab
217    module TABLCTRL130_init output.
218
219      if g_TABLCTRL130_copied is initial.
220    *&spwizard: copy ddic-table 'ZMM_CDITEM'
221    *&spwizard: into internal table 'g_TABLCTRL130_itab'
222        if g_mode <> 'CRE' and ZMM_CDHD_ST-MTART = 'ZCAP'.
223          select * from ZMM_CDITEM
224             into corresponding fields
225             of table g_TABLCTRL130_itab where
226             reqno = ZMM_CDHD_ST-REQNO ORDER BY PRIMARY KEY.
227        Endif.
228        g_TABLCTRL130_copied = 'X'.
229        refresh control 'TABLCTRL130' from screen '0130'.
230    *    if g_mode = 'CRE'.
231    *      TABlCTRL130-lines = 10.
232    *    endif.
233      endif.
234
235    *****
236      if g_mode <> 'CRE'.
237        loop at g_TABLCTRL130_itab into g_TABLCTRL130_wa.
238          Clear l_tdname.
239          concatenate 'CDDS' zmm_cdhd_st-reqno g_TABLCTRL130_wa-srno
240          into l_tdname.
241          Select single * into l_stxl from stxl
242                 where TDOBJECT = 'ZMMCD'
243                 and   TDNAME   = l_tdname
244                 and   TDID     = 'CDDS'.
245          if sy-subrc = 0.
246            g_TABLCTRL130_wa-dsflag = 'X'.
247            modify g_TABLCTRL130_itab from g_TABLCTRL130_wa
248                   transporting dsflag
249                   where srno = g_TABLCTRL130_wa-srno.
250          endif.
251        endloop.
252      endif.
253    ****
254      if ( g_mode = 'CRE' ) OR ( g_mode = 'CHA' ).
255        TABlCTRL130-lines = 99.
256      endif.
257    endmodule.
258    ***********************************************************************
259    *&spwizard: output module for tc 'TABLCTRL130'. do not change this line!
260    *&spwizard: move itab to dynpro
261    module TABLCTRL130_move output.
262      Data: l_itab130 type t_TABLCTRL130.
263      move-corresponding g_TABLCTRL130_wa to ZMM_CDITEM.
264      if ( g_mode = 'CRE' ) OR
265         ( g_mode = 'CHA' ).
266        condense g_TABLCTRL130_wa-desc_fin.
267
268        if not g_TABLCTRL130_wa-desc_fin is initial.
269    *     move TABLCTRL130-current_line
270    *       to g_TABLCTRL130_wa-SRNO.
271    **********To get the maximum srno in the internal table***
272          clear: l_srno,l_srnoflag.
273          describe table g_TABLCTRL130_itab lines l_srno.
274          while l_srnoflag <> 'S'.
275            read table g_TABLCTRL130_itab into l_itab130
276                 with key srno = l_srno.
277            if sy-subrc <> 0.
278              l_srnoflag = 'S'.
279            else.
280              l_srno = l_srno + 1.
281            endif.
282          endwhile.
283          if g_TABLCTRL130_wa-SRNO = 0.
284            move l_srno to g_TABLCTRL130_wa-SRNO.
285          endif.
286
287        endif.
288        if TABLCTRL130-current_line = g_curr_line_130.
289          move g_mat_fnd to ZMM_CDITEM-mat_fnd.
290        else.
291          move g_TABLCTRL130_wa-mat_fnd to ZMM_CDITEM-mat_fnd.
292        endif.
293
294        move g_TABLCTRL130_wa-SRNO to ZMM_CDITEM-SRNO.
295        move g_TABLCTRL130_wa-desc_fin to ZMM_CDITEM-desc_fin.
296      endif.
297
298
299    endmodule.
300    ************************************************************************
301    *&spwizard: output module for tc 'TABLCTRL130'. do not change this line!
302    *&spwizard: get lines of tablecontrol
303    module TABLCTRL130_get_lines output.
304      g_TABLCTRL130_lines = sy-loopc.
305    endmodule.
306    *&---------------------------------------------------------------------*
307    *&      Module  STATUS_0100  OUTPUT
308    *&---------------------------------------------------------------------*
309    *       text
310    *----------------------------------------------------------------------*
311    MODULE STATUS_0100 OUTPUT.
312      Perform fill_sttab.
313      SET PF-STATUS 'OPTNS' excluding it_tab1.
314      case g_mode.
315        when 'CRE'.
316          SET TITLEBAR 'MATCODE_TTL' with ' - CREATE'.
317        when 'CHA'.
318          SET TITLEBAR 'MATCODE_TTL' with ' - CHANGE'.
319        when 'DIS'.
320          SET TITLEBAR 'MATCODE_TTL' with '- DISPLAY'.
321        when 'DEL'.
322          SET TITLEBAR 'MATCODE_TTL' with ' - DELETE'.
323        when others.
324          SET TITLEBAR 'MATCODE_TTL'.
325      endcase.
326    *+260405*********
327    *If g_mode = 'APR' and OKCODE_100 = 'APPROVE'.
328    *    Perform find_user.
329    *endif.
330    *-260405
331    *Perform chng_attr_100.
332    ENDMODULE.                 " STATUS_0100  OUTPUT
333    *&---------------------------------------------------------------------*
334    *&      Module  scr100_attr  OUTPUT
335    *&---------------------------------------------------------------------*
336    *       text
337    *----------------------------------------------------------------------*
338    MODULE scr100_attr OUTPUT.
339
340      Case g_mode.
341    * clear sy-ucomm.
342        When ''.
343          loop at screen.
344            screen-input = 0.
345            modify screen.
346          endloop.
347        When 'CRE'.
348          loop at screen.
349            if screen-name = 'ZMM_CDHD_ST-REQNO' OR
350               screen-name = 'ZMM_CDHD_ST-APPROVE_MRP' OR
351               screen-name = 'ZMM_CDHD_ST-REQCL'.
352              screen-input = 0.
353              modify screen.
354            Endif.
355            if screen-name = 'ZMM_CDHD_ST-APPROVE_L2'.
356              if g_techapr_visible = 'Y'.
357               screen-invisible = 0.
358               screen-input     = 0.
359              else.
360               screen-invisible = 1.
361              endif.
362              modify screen.
363            Endif.
364            if screen-name = 'T_TECHAUTH'.
365              if g_techapr_visible = 'Y'.
366               screen-invisible = 0.
367              else.
368               screen-invisible = 1.
369              endif.
370              modify screen.
371            Endif.
372
373          endloop.
374        When 'CHA'.
375          If zmm_cdhd_st-reqno is initial.
376            loop at screen.
377              if screen-name <> 'ZMM_CDHD_ST-REQNO'.
378                screen-input = 0.
379                modify screen.
380              endif.
381            endloop.
382          Else.
383            loop at screen.
384              if screen-group1 = '02'.
385                screen-input = 0.
386                modify screen.
387              endif.
388              if screen-name = 'ZMM_CDHD_ST-MTART' or
389                 screen-name = 'ZMM_CDHD_ST-STATUS_FLAG' or
390                 screen-name = 'ZMM_CDHD_ST-APPROVE_MRP' OR
391                 screen-name = 'ZMM_CDHD_ST-REQCL'.
392                screen-input = 0.
393                modify screen.
394              endif.
395             if screen-name = 'ZMM_CDHD_ST-APPROVE_L2'.
396              if g_techapr_visible = 'Y'.
397               screen-invisible = 0.
398               screen-input     = 0.
399              else.
400               screen-invisible = 1.
401              endif.
402              modify screen.
403             Endif.
404            if screen-name = 'T_TECHAUTH'.
405              if g_techapr_visible = 'Y'.
406               screen-invisible = 0.
407              else.
408               screen-invisible = 1.
409              endif.
410              modify screen.
411            Endif.
412            endloop.
413          Endif.
414        When 'REL'.
415          loop at screen.
416            if screen-name  = 'ZMM_CDHD_ST-STATUS_FLAG' or
417               Screen-name  = 'ZMM_CDHD_ST-REQNO' or
418               Screen-name  = 'P_REM'             or
419               screen-name  = 'G_SH_CAPEQT'       or
420               screen-name  = 'G_SH_MFR'          or
421               screen-name  = 'G_SH_MDLNO'        OR
422               screen-name  = 'ZMM_CDHD_ST-REQCL'.
423              screen-input = 1.
424              modify screen.
425            Else.
426              screen-input = 0.
427              modify screen.
428            Endif.
429            if screen-name = 'ZMM_CDHD_ST-APPROVE_L2'.
430              if g_techapr_visible = 'Y'.
431               screen-invisible = 0.
432               screen-input     = 0.
433              else.
434               screen-invisible = 1.
435              endif.
436              modify screen.
437            Endif.
438            if screen-name = 'T_TECHAUTH'.
439              if g_techapr_visible = 'Y'.
440               screen-invisible = 0.
441              else.
442               screen-invisible = 1.
443              endif.
444              modify screen.
445            Endif.
446
447          endloop.
448
449        When 'APR'.
450          If zmm_cdhd_st-reqno is initial.
451            loop at screen.
452              if screen-name <> 'ZMM_CDHD_ST-REQNO'.
453                screen-input = 0.
454                modify screen.
455              endif.
456            endloop.
457          Else.
458            loop at screen.
459              if screen-name = 'ZMM_CDHD_ST-APPROVE_MRP'.
460                if  g_user = 'M' .
461                  screen-input = 1.
462                  modify screen.
463                Else.
464                  screen-input = 0.
465                  modify screen.
466                Endif.
467              Elseif screen-name = 'ZMM_CDHD_ST-APPROVE_L2'.
468    ****Addition*************************************
469               if g_user = 'M'.
470                  if g_techapr_visible = 'Y'.
471                    screen-invisible = 0.
472                    screen-input     = 0.
473                  else.
474                    screen-invisible = 1.
475                  endif.
476                  modify screen.
477               endif.
478    ****End******************************************
479                if g_user = 'L'.
480                  screen-input = 1.
481                  modify screen.
482                Else.
483                  screen-input = 0.
484                  modify screen.
485                Endif.
486    ****Addition*************************************
487              Elseif screen-name = 'T_TECHAUTH'.
488                if g_user = 'M'.
489                  if g_techapr_visible = 'Y'.
490                    screen-invisible = 0.
491                  else.
492                    screen-invisible = 1.
493                  endif.
494                  modify screen.
495                endif.
496    ****End******************************************
497              Else.
498                screen-input = 0.
499                modify screen.
500              Endif.
501              IF screen-name = 'P_REM'.
502                screen-input = 1.
503                modify screen.
504              ENDIF.
505            endloop.
506          endif.
507    *040405-E
508
509        When others.
510          Loop at screen.
511            if screen-name = 'ZMM_CDHD_ST-REQNO' or
512               screen-name = 'DD'                or
513               screen-name = 'P_REM'             or
514               screen-name = 'ADNL_DESC'         or
515               screen-name = 'G_SH_CAPEQT'       or
516               screen-name = 'G_SH_MFR'          or
517               screen-name = 'G_SH_MDLNO'.
518              screen-input = 1.
519            else.
520              screen-input = 0.
521            endif.
522            modify screen.
523    *
524            If screen-name = 'ZMM_CDHD_ST-APPROVE_L2'.
525              if g_techapr_visible = 'Y'.
526               screen-invisible = 0.
527               screen-input     = 0.
528              else.
529               screen-invisible = 1.
530              endif.
531              modify screen.
532            Endif.
533    *
534            If screen-name = 'T_TECHAUTH'.
535              if g_techapr_visible = 'Y'.
536               screen-invisible = 0.
537              else.
538               screen-invisible = 1.
539              endif.
540              modify screen.
541            Endif.
542    *
543            If screen-name = 'ZMM_CDHD_ST-REQCL'.
544              if sy-tcode  = 'ZCODG'.
545                 screen-input = 1.
546              else.
547                 screen-input = 0.
548              endif.
549              modify screen.
550            Endif.
551
552          endloop.
553      Endcase.
554      loop at screen.
555       if sy-tcode <> 'ZCODG'.
556        if screen-name = 'ZMM_MODIFIER-MATGRP'.
557          screen-invisible = 1.
558          modify screen.
559        elseif screen-name = 'PB_CPMC'.
560          screen-invisible = 1.
561          modify screen.
562        elseif screen-name = 'PB_UNDOCPMC'.
563          screen-invisible = 1.
564          modify screen.
565        endif.
566       endif.
567      endloop.
568      perform tcode_zcodg_attr.
569    ENDMODULE.                 " scr100_attr  OUTPUT
570
571
572    *&spwizard: output module for tc 'TABLCTRL140'. do not change this line!
573    *&spwizard: copy ddic-table to itab
574    module TABLCTRL140_init output.
575    *&spwizard: copy ddic-table 'ZMM_CDITEM'
576    *&spwizard: into internal table 'g_TABLCTRL140_itab'
577      if g_TABLCTRL140_copied is initial.
578        if g_mode <> 'CRE' and ZMM_CDHD_ST-MTART = 'ZSPR'.
579          select * from ZMM_CDITEM
580             into corresponding fields
581             of table g_TABLCTRL140_itab where reqno = ZMM_CDHD_ST-REQNO ORDER BY PRIMARY KEY.
582        Endif.    .
583        g_TABLCTRL140_copied = 'X'.
584        refresh control 'TABLCTRL140' from screen '0140'.
585      endif.
586    *****
587      If g_mode <> 'CRE'.
588        loop at g_TABLCTRL140_itab into g_TABLCTRL140_wa.
589          Clear l_tdname.
590          concatenate 'CDDS' zmm_cdhd_st-reqno g_TABLCTRL140_wa-srno
591          into l_tdname.
592          Select single * into l_stxl from stxl
593                 where TDOBJECT = 'ZMMCD'
594                 and   TDNAME   = l_tdname
595                 and   TDID     = 'CDDS'.
596          if sy-subrc = 0.
597            g_TABLCTRL140_wa-dsflag = 'X'.
598            modify g_TABLCTRL140_itab from g_TABLCTRL140_wa
599                   transporting dsflag
600                   where srno = g_TABLCTRL140_wa-srno.
601          endif.
602        endloop.
603      Endif.
604    ****
605
606      if ( g_mode = 'CRE' ) OR ( g_mode = 'CHA' ).
607        TABlCTRL140-lines = 99.
608      endif.
609    endmodule.
610
611    *&spwizard: output module for tc 'TABLCTRL140'. do not change this line!
612    *&spwizard: move itab to dynpro
613    module TABLCTRL140_move output.
614      move-corresponding g_TABLCTRL140_wa to ZMM_CDITEM.
615      if g_mode = 'CRE'.
616        concatenate g_TABLCTRL140_wa-desc1
617                    g_TABLCTRL140_wa-user_desc
618               into g_TABLCTRL140_wa-desc_fin
619               separated by space.
620        condense g_TABLCTRL140_wa-desc_fin.
621        if not g_TABLCTRL140_wa-desc_fin is initial.
622          move TABLCTRL140-current_line
623            to g_TABLCTRL140_wa-SRNO.
624        endif.
625
626        move g_TABLCTRL140_wa-SRNO to ZMM_CDITEM-SRNO.
627        move g_TABLCTRL140_wa-desc_fin to ZMM_CDITEM-desc_fin.
628      endif.
629    endmodule.
630
631    *&spwizard: output module for tc 'TABLCTRL140'. do not change this line!
632    *&spwizard: get lines of tablecontrol
633    module TABLCTRL140_get_lines output.
634      g_TABLCTRL140_lines = sy-loopc.
635    endmodule.
636
637    *&spwizard: output module for tc 'TABLCTRL120'. do not change this line!
638    *&spwizard: copy ddic-table to itab
639    module TABLCTRL120_init output.
640    Data : l_120lns type i.
641
642    *  check_code = sy-ucomm.
643    *  clear        sy-ucomm .
644
645    *&spwizard: copy ddic-table 'ZMM_CDITEM'
646    *&spwizard: into internal table 'g_TABLCTRL120_itab'
647    *****Addition*****************
648      if g_TABLCTRL120_copied is initial.
649        if g_mode <> 'CRE' and ZMM_CDHD_ST-MTART = 'ZSPR'.
650          select * from ZMM_CDITEM
651             into corresponding fields
652             of table g_TABLCTRL120_itab
653          where reqno = zmm_cdhd_st-reqno ORDER BY PRIMARY KEY.
654        endif.
655    ***to delete the internal table entries which does not
656    ***belongs to a partiular codifier's assigned class.
657        if sy-tcode = 'ZCODG'.
658          select single * from zmm_cdcodifier
659                 where codifier = sy-uname.
660          if sy-subrc = 0.
661           loop at g_TABCTRL110_itab into g_tabctrl110_wa.
662            select single * from zmm_cdcodifier
663                   where codifier = sy-uname
664                   and   matgp    = g_tabctrl110_wa-matgp.
665            if sy-subrc <> 0.
666             delete g_TABCTRL110_itab index sy-tabix.
667            endif.
668           endloop.
669          endif.
670        endif.
671    ****
672
673        g_TABLCTRL120_copied = 'X'.
674        refresh control 'TABLCTRL120' from screen '0120'.
675      endif.
676    *****
677    ***To check, if long text maintained or not
678      Case g_mode.
679        WHEN 'CRE'.
680          IF not g_TABLCTRL120_itab[] is initial.
681            loop at g_TABLCTRL120_itab into g_TABLCTRL120_wa.
682              concatenate 'CDDS' '9999999999' g_TABLCTRL120_wa-srno
683               into l_tdname.
684              perform check_lt_exist using l_tdname.
685              if not g_lines[] is initial.
686                read table g_lines into g2_lines index 1.
687                if not g2_lines-tdline is initial.
688                  g_TABLCTRL120_wa-dsflag = 'X'.
689                  modify g_TABLCTRL120_itab from g_TABLCTRL120_wa
690                      transporting dsflag
691                      where srno = g_TABLCTRL120_wa-srno.
692                  clear g_TABLCTRL120_wa-dsflag.
693                else.
694                  g_TABLCTRL120_wa-dsflag = ''.
695                  modify g_TABLCTRL120_itab from g_TABLCTRL120_wa
696                      transporting dsflag
697                      where srno = g_TABLCTRL120_wa-srno.
698                endif.
699                clear g2_lines.
700              endif.
701            endloop.
702          ENDIF.
703        WHEN 'CHA' OR 'DIS' OR 'DEL' OR 'REL'.
704          loop at g_TABLCTRL120_itab into g_TABLCTRL120_wa.
705            concatenate 'CDDS' zmm_cdhd_st-reqno g_TABLCTRL120_wa-srno
706            into l_tdname.
707            perform check_lt_exist using l_tdname.
708            if not g_lines[] is initial.
709              read table g_lines into g2_lines index 1.
710              if not g2_lines-tdline is initial.
711                g_TABLCTRL120_wa-dsflag = 'X'.
712                modify g_TABLCTRL120_itab from g_TABLCTRL120_wa
713                     transporting dsflag
714                     where srno = g_TABLCTRL120_wa-srno.
715                clear g_TABLCTRL120_wa-dsflag.
716              else.
717                g_TABLCTRL120_wa-dsflag = ''.
718                modify g_TABLCTRL120_itab from g_TABLCTRL120_wa
719                     transporting dsflag
720                     where srno = g_TABLCTRL120_wa-srno.
721              endif.
722              clear g2_lines.
723            endif.
724          endloop.
725      ENDCASE.
726
727    **********************************************
728      if ( g_mode = 'CRE' ) OR ( g_mode = 'CHA' ).
729        describe table g_TABLCTRL120_itab lines l_120lns.
730        if l_120lns < 99.
731          TABLCTRL120-lines = 99.
732        endif.
733      endif.
734    endmodule.
735
736    *&spwizard: output module for tc 'TABLCTRL120'. do not change this line!
737    *&spwizard: move itab to dynpro
738    module TABLCTRL120_move output.
739      Data: l_itab120 type t_TABLCTRL120,
740            lc_itab120 type t_TABLCTRL120 occurs 0.
741    ***********************************************************
742      move-corresponding g_TABLCTRL120_wa to ZMM_CDITEM.
743      if ( g_mode = 'CRE' ) OR ( g_mode = 'CHA' ).
744    *    concatenate g_TABLCTRL120_wa-desc1
745    *                g_TABLCTRL120_wa-user_desc
746    *           into g_TABLCTRL120_wa-desc_fin
747    *           separated by space.
748    *    condense g_TABLCTRL120_wa-desc_fin.
749        if not g_TABLCTRL120_wa-desc_fin is initial.
750    *     move TABLCTRL120-current_line
751    *       to g_TABLCTRL120_wa-SRNO.
752    **********To get the maximum srno in the internal table***
753          clear: l_srno,l_srnoflag.
754          refresh lc_itab120.
755          append lines of g_TABLCTRL120_itab to lc_itab120.
756          delete lc_itab120 where srno = 0.
757          describe table lc_itab120 lines l_srno.
758    *     describe table g_TABLCTRL120_itab lines l_srno.
759          while l_srnoflag <> 'S'.
760            read table g_TABLCTRL120_itab into l_itab120
761                 with key srno = l_srno.
762            if sy-subrc <> 0.
763              l_srnoflag = 'S'.
764            else.
765              l_srno = l_srno + 1.
766            endif.
767          endwhile.
768          if g_TABLCTRL120_wa-SRNO = 0.
769            move l_srno to g_TABLCTRL120_wa-SRNO.
770          endif.
771
772    ************************************************************
773        endif.
774
775        if TABLCTRL120-current_line = g_curr_line_120.
776          move g_mat_fnd to ZMM_CDITEM-mat_fnd.
777        else.
778          move g_TABLCTRL120_wa-mat_fnd to ZMM_CDITEM-mat_fnd.
779        endif.
780
781        move g_TABLCTRL120_wa-SRNO to ZMM_CDITEM-SRNO.
782        move g_TABLCTRL120_wa-desc_fin to ZMM_CDITEM-desc_fin.
783      endif.
784    endmodule.
785
786    *&spwizard: output module for tc 'TABLCTRL120'. do not change this line!
787    *&spwizard: get lines of tablecontrol
788    module TABLCTRL120_get_lines output.
789      g_TABLCTRL120_lines = sy-loopc.
790    endmodule.
791    *&---------------------------------------------------------------------*
792    *&      Module  GET_MATTY_TCT  OUTPUT
793    *&---------------------------------------------------------------------*
794    *       text
795    *----------------------------------------------------------------------*
796    MODULE GET_MATTY_TCT OUTPUT.
797      Perform fill_mattyp_itemdt.
798      set parameter id 'ZMATGP' field ''.
799      set parameter id 'MTA' field ZMM_CDHD_ST-MTART.
800      if dynnr is initial.
801        dynnr = '0101'.
802      Endif.
803
804    ENDMODULE.                 " GET_MATTY_TCT  OUTPUT
805    *&---------------------------------------------------------------------*
806    *&      Module  get_material_helpdata  OUTPUT
807    *&---------------------------------------------------------------------*
808    *       text
809    *----------------------------------------------------------------------*
810    MODULE get_material_helpdata OUTPUT.
811    if   okcode_100 = 'CAPEQT'   or       " 17-06-05.
812         okcode_100 = 'MDLNO'.
813         clear okcode_100.
814    Else.
815      G_MATTY = ZMM_CDHD_ST-MTART.
816      sel_flag = check_pos.
817      if g_hits_par_oth = 'X'.
818        FIELD1 = 'ZMM_CDITEM-DESC4'.
819      endif.
820      CASE g_matty.
821        WHEN 'ZSTO'.
822          IF not desc11 is initial .
823            If FIELD1 = 'ZMM_CDITEM-DESC1'.
824              REFRESH IST_SRCHLP.
825              clear : DESC22 ,DESC33 , DESC44.
826              PERFORM SELECT_HELP_DATA using
827                            G_PARTNO
828                            DESC11
829                            DESC22
830                            DESC33
831                            DESC44
832                            DESC55
833                            G_MATGP
834                            G_MATTY
835                         changing sel_flag.
836            Endif.
837
838            If FIELD1 = 'ZMM_CDITEM-DESC2'.
839              clear : DESC33, DESC44.
840              PERFORM SELECT_HELP_DATA using
841                            G_PARTNO
842                            DESC11
843                            DESC22
844                            DESC33
845                            DESC44
846                            DESC55
847                            G_MATGP
848                            G_MATTY
849                         changing sel_flag.
850            Endif.
851
852            If FIELD1 = 'ZMM_CDITEM-DESC3'.
853              clear : DESC44.
854              PERFORM SELECT_HELP_DATA using
855                            G_PARTNO
856                            DESC11
857                            DESC22
858                            DESC33
859                            DESC44
860                            DESC55
861                            G_MATGP
862                            G_MATTY
863                         changing sel_flag.
864            Endif.
865
866            If FIELD1 = 'ZMM_CDITEM-DESC4'.
867              PERFORM SELECT_HELP_DATA using
868                            G_PARTNO
869                            DESC11
870                            DESC22
871                            DESC33
872                            DESC44
873                            DESC55
874                            G_MATGP
875                            G_MATTY
876                         changing sel_flag.
877            Endif.
878
879            If FIELD1 = 'ZMM_CDITEM-USER_DESC'.
880              PERFORM SELECT_HELP_DATA using
881                            G_PARTNO
882                            DESC11
883                            DESC22
884                            DESC33
885                            DESC44
886                            DESC55
887                            G_MATGP
888                            G_MATTY
889                         changing sel_flag.
890            Endif.
891          ENDIF.
892
893        WHEN 'ZSPR'.
894
895          If FIELD1 = 'ZMM_CDITEM-PARTNO' .
896
897            PERFORM CHANGE_PARTNO CHANGING G_PARTNO G_PARTNOC.
898
899            REFRESH IST_SRCHLP.
900            clear : DESC11, DESC22 ,DESC33 , DESC44.
901            PERFORM SELECT_HELP_DATA using
902                          G_PARTNO
903                          DESC11
904                          DESC22
905                          DESC33
906                          DESC44
907                          DESC55
908                          G_MATGP
909                          G_MATTY
910                       changing sel_flag.
911          Endif.
912
913          If FIELD1 = 'ZMM_CDITEM-DESC1' .
914
915            clear : DESC22 ,DESC33 , DESC44.
916            PERFORM SELECT_HELP_DATA using
917                          G_PARTNO
918                          DESC11
919                          DESC22
920                          DESC33
921                          DESC44
922                          DESC55
923                          G_MATGP
924                          G_MATTY
925                       changing sel_flag.
926
927          Endif.
928
929          If FIELD1 = 'ZMM_CDITEM-USER_DESC'.
930            PERFORM SELECT_HELP_DATA using
931                          G_PARTNO
932                          DESC11
933                          DESC22
934                          DESC33
935                          DESC44
936                          DESC55
937                          G_MATGP
938                          G_MATTY
939                       changing sel_flag.
940          Endif.
941
942          WHEN 'ZCAP'.
943            Perform get_srchlp_zcap.
944            describe table ist_srchlp lines g_mat_fnd.
945      ENDCASE.
946
947      if g_matty = 'ZSTO'.
948        PERFORM SELECT_MATERIAL_DETAILS.
949      elseif g_matty = 'ZSPR'.
950        PERFORM SELECT_MATERIAL_DETAILS1.
951      endif.
952    Endif.
953    ENDMODULE.                 " get_material_helpdata  OUTPUT
954    *&---------------------------------------------------------------------*
955    *&      Module  header_data  OUTPUT
956    *&---------------------------------------------------------------------*
957    *       text
958    *----------------------------------------------------------------------*
959    MODULE get_header_data OUTPUT.
960    *
961      IF not g_mode is initial.
962        if g_mode <> 'CRE' and g_hd_copied is initial.
963          if ( g_mode = 'CHA' ) OR ( g_mode = 'DEL' ).
964            if not zmm_cdhd_st-reqno is initial.
965              perform lock_reqhd.
966            endif.
967          endif.
968
969          select single * from ZMM_CDHD
970              into corresponding fields of ZMM_CDHD_ST
971               where REQNO = zmm_cdhd_st-reqno.
972    *       move ZMM_CDHD-status to app_fl2.
973          if sy-subrc = 0.
974            g_hd_copied = 'X'.
975    *        If g_user = ''.
976               Perform Change_restrict.
977    *        Else.
978    *          Perform CHANGE_MRP.
979    *        Endif.
980            Perform Change_Rel.  "using l_cdhd.
981            If g_mode = 'APR'.
982              Perform REL_APR_STATUS.
983            Endif.
984          Endif.
985        Endif.
986      ELSE.
987        if sy-tcode = 'ZCODG' and g_hd_copied is initial.
988          select single * from ZMM_CDHD
989              into corresponding fields of ZMM_CDHD_ST
990               where REQNO = zmm_cdhd_st-reqno.
991          if sy-subrc = 0.
992            g_hd_copied = 'X'.
993          endif.
994        endif.
995      ENDIF.
996      set parameter id 'ZMAT_TY' field zmm_cdhd_st-mtart.
997      perform get_correspondense.
998    ENDMODULE.                 " header_data  OUTPUT
999    *&---------------------------------------------------------------------*
1000   *&      Module  TABCTRL110_change_col_attr  OUTPUT
1001   *&---------------------------------------------------------------------*
1002   *       text
1003   *----------------------------------------------------------------------*
1004   MODULE TABCTRL110_change_col_attr OUTPUT.
1005     Case g_mode.
1006       When 'CRE' OR 'CHA'.
1007         loop at screen.
1008           if screen-name = 'FILTER' or
1009              screen-name = 'SORTU' or
1010              screen-name = 'SORTD'.
1011             screen-input = 0.
1012             modify screen.
1013           endif.
1014   *      if screen-name = 'ZMM_CDITEM-DESCFIN'.
1015           if screen-name = 'ZMM_CDITEM-COMP_FLG'.
1016             screen-input = 0.
1017             modify screen.
1018           endif.
1019         endloop.
1020       When 'DIS' OR 'DEL' OR 'REL'.
1021         loop at screen.
1022           if ( screen-name <> 'ZMM_CDITEM-REQ_LT' ).
1023             screen-input = 0.
1024             modify screen.
1025           endif.
1026           if g_mode = 'DIS' OR g_mode = 'REL'.
1027             if screen-name = 'FILTER' OR
1028                screen-name = 'SORTU'  OR
1029                screen-name = 'SORTD'.
1030               screen-input = 1.
1031               modify screen.
1032             endif.
1033           endif.
1034         endloop.
1035       When 'APR'.
1036         loop at screen.
1037           if screen-name = 'ZMM_CDITEM-COMP_FLG' OR
1038              screen-name = 'ZMM_CDITEM-REQ_LT'  OR
1039              screen-name = 'SORTU'  OR
1040              screen-name = 'SORTD'.
1041             screen-input  = 1.
1042             modify screen.
1043           else.
1044             screen-input  = 0.
1045             modify screen.
1046           endif.
1047         endloop.
1048     Endcase.
1049
1050     IF sy-tcode = 'ZCODG'.
1051      loop at screen.
1052       if screen-name = 'TABCTRL110_DELETE'.
1053          screen-input = 0.
1054          modify screen.
1055       elseif screen-name = 'TABLCTRL120_DELETE'.
1056           screen-input = 0.
1057          modify screen.
1058       elseif screen-name = 'TABLCTRL130_DELETE'.
1059           screen-input = 0.
1060          modify screen.
1061       elseif screen-name = 'TABLCTRL140_DELETE'.
1062           screen-input = 0.
1063          modify screen.
1064       endif.
1065      endloop.
1066     ENDIF.
1067
1068   ENDMODULE.                 " TABCTRL110_change_col_attr  OUTPUT
1069   *&---------------------------------------------------------------------*
1070   *&      Module  TABCTRL110_change_field_attr  OUTPUT
1071   *&---------------------------------------------------------------------*
1072   *       text
1073   *----------------------------------------------------------------------*
1074   MODULE TABCTRL110_change_field_attr OUTPUT.
1075   *   get parameter id 'ZMATGP' field g_matgp.
1076
1077   *   g_TABCTRL110_wa-matgp = g_matgp.
1078
1079     SELECT * FROM ZMM_MODIFIER UP TO 1 ROWS
1080    WHERE DESC1 = G_TABCTRL110_WA-DESC1
1081    AND MATGRP = G_TABCTRL110_WA-MATGP
1082    ORDER BY PRIMARY KEY .
1083    ENDSELECT.
1084     if sy-subrc <> 0.
1085       g_parno = '1'.
1086     endif.
1087
1088     if sy-subrc = 0.
1089
1090       if  zmm_modifier-desc2 is initial.
1091         g_parno = '1'.
1092       elseif  zmm_modifier-desc3 is initial.
1093         g_parno = '2'.
1094       elseif  zmm_modifier-desc4 is initial.
1095         g_parno = '3'.
1096       else.
1097         g_parno = '4'.
1098       endif.
1099
1100     endif.
1101
1102
1103     case 'X'.
1104
1105       when ZMM_CDITEM-OTH1.
1106   *      if g_other <> 'X'.
1107   *         clear: ZMM_CDITEM-OTH2, ZMM_CDITEM-OTH3, ZMM_CDITEM-OTH4.
1108   *      endif.
1109         g_parno = '1'.
1110       when ZMM_CDITEM-OTH2.
1111   *      if g_other <> 'X'.
1112   *        clear: ZMM_CDITEM-OTH3, ZMM_CDITEM-OTH4.
1113   *      endif.
1114         g_parno = '2'.
1115       when ZMM_CDITEM-OTH3.
1116   *      if g_other <> 'X'.
1117   *          clear: ZMM_CDITEM-OTH4.
1118   *      endif.
1119         g_parno = '3'.
1120       when ZMM_CDITEM-OTH4.
1121         g_parno = '4'.
1122     endcase.
1123   *
1124     loop at screen.
1125       case g_parno.
1126        when '0'.
1127           if screen-name = 'ZMM_CDITEM-DESC1'.
1128             screen-input = 0.
1129             modify screen.
1130           endif.
1131           if screen-name = 'ZMM_CDITEM-DESC2'.
1132             screen-input = 0.
1133             modify screen.
1134           endif.
1135           if screen-name = 'ZMM_CDITEM-DESC3'.
1136             screen-input = 0.
1137             modify screen.
1138           endif.
1139           if screen-name = 'ZMM_CDITEM-DESC4'.
1140             screen-input = 0.
1141             modify screen.
1142           endif.
1143        when '5'.
1144           if screen-name = 'ZMM_CDITEM-DESC1'.
1145             screen-input = 0.
1146             modify screen.
1147           endif.
1148           if screen-name = 'ZMM_CDITEM-DESC2'.
1149             screen-input = 0.
1150             modify screen.
1151           endif.
1152           if screen-name = 'ZMM_CDITEM-DESC3'.
1153             screen-input = 0.
1154             modify screen.
1155           endif.
1156           if screen-name = 'ZMM_CDITEM-DESC4'.
1157             screen-input = 0.
1158             modify screen.
1159           endif.
1160        when '1'.
1161           if screen-name = 'ZMM_CDITEM-DESC2'.
1162             screen-input = 0.
1163             modify screen.
1164           endif.
1165           if screen-name = 'ZMM_CDITEM-DESC3'.
1166             screen-input = 0.
1167             modify screen.
1168           endif.
1169           if screen-name = 'ZMM_CDITEM-DESC4'.
1170             screen-input = 0.
1171             modify screen.
1172           endif.
1173        when '2'.
1174           if screen-name = 'ZMM_CDITEM-DESC3'.
1175             screen-input = 0.
1176             modify screen.
1177           endif.
1178           if screen-name = 'ZMM_CDITEM-DESC4'.
1179             screen-input = 0.
1180             modify screen.
1181           endif.
1182        when '3'.
1183           if screen-name = 'ZMM_CDITEM-DESC4' .
1184             screen-input = 0.
1185             modify screen.
1186           endif.
1187        when '4'.
1188           if screen-name = 'ZMM_CDITEM-DESC2'.
1189             screen-input = 1.
1190             modify screen.
1191           endif.
1192           if screen-name = 'ZMM_CDITEM-DESC3'.
1193             screen-input = 1.
1194             modify screen.
1195           endif.
1196           if screen-name = 'ZMM_CDITEM-DESC4'.
1197             screen-input = 1.
1198             modify screen.
1199           endif.
1200       endcase.
1201     endloop.
1202
1203
1204     Case g_mode.
1205       When 'CRE' OR 'CHA'.
1206         loop at screen.
1207   *      if screen-name = 'ZMM_CDITEM-DESC_FIN'.
1208           if screen-name = 'ZMM_CDITEM-COMP_FLG'.
1209             screen-input = 0.
1210             modify screen.
1211           endif.
1212           if screen-name = 'ZMM_CDITEM-REQ_LT'.
1213             IF g_TABCTRL110_wa-desc_fin is initial.
1214               screen-input = 0.
1215             ELSE.
1216               screen-input = 1.
1217             ENDIF.
1218             modify screen.
1219           endif.
1220           case g_parno.
1221             when '5'.
1222               if screen-name = 'ZMM_CDITEM-DESC1'.
1223                 screen-input = 0.
1224                 modify screen.
1225               endif.
1226               if screen-name = 'ZMM_CDITEM-DESC2'.
1227                 screen-input = 0.
1228                 modify screen.
1229               endif.
1230               if screen-name = 'ZMM_CDITEM-DESC3'.
1231                 screen-input = 0.
1232                 modify screen.
1233               endif.
1234               if screen-name = 'ZMM_CDITEM-DESC4'.
1235                 screen-input = 0.
1236                 modify screen.
1237               endif.
1238             when '1'.
1239               if screen-name = 'ZMM_CDITEM-DESC2'.
1240                 screen-input = 0.
1241                 modify screen.
1242               endif.
1243               if screen-name = 'ZMM_CDITEM-DESC3'.
1244                 screen-input = 0.
1245                 modify screen.
1246               endif.
1247               if screen-name = 'ZMM_CDITEM-DESC4'.
1248                 screen-input = 0.
1249                 modify screen.
1250               endif.
1251   *Addition ***** ****************************************
1252               IF not g_TABCTRL110_wa-desc1 is initial.
1253                 IF screen-name = 'ZMM_CDITEM-UOM'.
1254                   screen-required = 1.
1255                   modify screen.
1256                 ENDIF.
1257               ENDIF.
1258   *End*********** ****************************************
1259
1260             when '2'.
1261               if screen-name = 'ZMM_CDITEM-DESC3'.
1262                 screen-input = 0.
1263                 modify screen.
1264               endif.
1265
1266               if screen-name = 'ZMM_CDITEM-DESC4'.
1267                 screen-input = 0.
1268                 modify screen.
1269               endif.
1270   *Addition ***** *****************************************
1271               IF screen-name = 'ZMM_CDITEM-DESC2'.
1272                 screen-required = 1.
1273                 modify screen.
1274               ENDIF.
1275
1276               IF not g_TABCTRL110_wa-desc2 is initial.
1277                 IF screen-name = 'ZMM_CDITEM-UOM'.
1278                   screen-required = 1.
1279                   modify screen.
1280                 ENDIF.
1281               ENDIF.
1282   *End*********** *****************************************
1283
1284             when '3'.
1285               if screen-name = 'ZMM_CDITEM-DESC4' .
1286                 screen-input = 0.
1287                 modify screen.
1288               endif.
1289   *Addition ***** *****************************************
1290               IF screen-name = 'ZMM_CDITEM-DESC2'.
1291                 screen-required = 1.
1292                 modify screen.
1293               ENDIF.
1294               IF not g_TABCTRL110_wa-desc2 is initial.
1295                 IF screen-name = 'ZMM_CDITEM-DESC3'.
1296                   screen-required = 1.
1297                   modify screen.
1298                 ENDIF.
1299               ENDIF.
1300               IF not g_TABCTRL110_wa-desc3 is initial.
1301                 IF screen-name = 'ZMM_CDITEM-UOM'.
1302                   screen-required = 1.
1303                   modify screen.
1304                 ENDIF.
1305               ENDIF.
1306   *End*********** *****************************************
1307             when '4'.
1308               if screen-name = 'ZMM_CDITEM-DESC2'.
1309                 screen-input = 1.
1310                 screen-required = 1.
1311                 modify screen.
1312               endif.
1313               if screen-name = 'ZMM_CDITEM-DESC3'.
1314                 screen-input = 1.
1315                 modify screen.
1316               endif.
1317   *Addition ***** ****************************************
1318               IF not g_TABCTRL110_wa-desc2 is initial.
1319                 IF screen-name = 'ZMM_CDITEM-DESC3'.
1320                   screen-required = 1.
1321                   modify screen.
1322                 ENDIF.
1323               ENDIF.
1324   *End*********** *****************************************
1325               if screen-name = 'ZMM_CDITEM-DESC4'.
1326                 screen-input = 1.
1327                 modify screen.
1328               endif.
1329   *Addition ***** *****************************************
1330               IF not g_TABCTRL110_wa-desc3 is initial.
1331                 IF screen-name = 'ZMM_CDITEM-DESC4'.
1332                   screen-required = 1.
1333                   modify screen.
1334                 ENDIF.
1335               ENDIF.
1336               IF not g_TABCTRL110_wa-desc4 is initial.
1337                 IF screen-name = 'ZMM_CDITEM-UOM'.
1338                   screen-required = 1.
1339                   modify screen.
1340                 ENDIF.
1341               ENDIF.
1342   *End*********** *****************************************
1343           endcase.
1344   *Addition ***** ****************************************
1345           if not g_tabctrl110_wa-matcode is initial.
1346             if screen-group4 = 'MC'.
1347               screen-input = 0.
1348               modify screen.
1349             endif.
1350           endif.
1351   *End*********** ****************************************
1352           if screen-name = 'ZMM_CDITEM-REJ_FLG'.
1353            screen-input = 0.
1354            modify screen.
1355           endif.
1356         endloop.
1357       When 'DIS' OR 'DEL' OR
1358            'REL' .
1359         loop at screen.
1360           if screen-name = 'ZMM_CDITEM-REQ_LT' OR
1361              screen-name = 'PB_ADNL_DESC'.
1362              screen-input = 1.
1363              modify screen.
1364           else.
1365             screen-input = 0.
1366             modify screen.
1367           endif.
1368         endloop.
1369       WHEN 'APR'.
1370         loop at screen.
1371           if screen-name = 'ZMM_CDITEM-REQ_LT' OR
1372              Screen-name = 'ZMM_CDITEM-COMP_FLG' OR
1373              screen-name = 'ZMM_CDITEM-REJ_FLG'.
1374             screen-input = 1.
1375             modify screen.
1376           else.
1377             screen-input = 0.
1378             modify screen.
1379           endif.
1380         endloop.
1381     Endcase.
1382     perform tcode_zcodg_attr.
1383
1384   ENDMODULE.                 " TABCTRL110_change_field_attr  OUTPUT
1385   *&---------------------------------------------------------------------*
1386   *&      Module  STATUS_0115  OUTPUT
1387   *&---------------------------------------------------------------------*
1388   *       text
1389   *----------------------------------------------------------------------*
1390   MODULE STATUS_0115 OUTPUT.
1391   *clear sy-ucomm.
1392   *clear g_ok_code115.
1393   *
1394     if sy-ucomm <> ''.
1395        g_ok_code110 = sy-ucomm.
1396     endif.
1397     clear sy-ucomm.
1398     export g_tabctrl110_wa-oth1 to memory id 'OTH1'.
1399      select single WGBEZ from T023T into g_matgp_desc where MATKL =
1400      g_matgp and spras = sy-langu.
1401
1402   *concatenate g_tabctrl110_wa-oth1 g_tabctrl110_wa-oth2
1403   *g_tabctrl110_wa-oth3 g_tabctrl110_wa-oth4 into g_oth.
1404     set pf-status 'STAT115'.
1405   ***********Below part Commented****************************
1406   ***********Added in other module***************************
1407   *  IF g_ok_code110 = 'PB_AD' AND g_ok_code115 = ''.
1408   *     g_desc1 = g_tabctrl110_wa-desc1.
1409   *     g_desc2 = g_tabctrl110_wa-desc2.
1410   *     g_desc3 = g_tabctrl110_wa-desc3.
1411   *     g_desc4 = g_tabctrl110_wa-desc4.
1412   *     g_matgp = g_tabctrl110_wa-matgp.
1413   *     concatenate g_desc1 g_desc2
1414   *                 g_desc3 g_desc4 into g_desc1_4
1415   *                 separated by space.
1416   *     user_desc_len = 87 - strlen( g_desc1_4 ).
1417   *
1418   **    If g_tabctrl110_wa-User_desc <> ''.
1419   **      If g_user_desc = ''.
1420   **        g_user_desc = g_tabctrl110_wa-User_desc.
1421   **      else.
1422   **      Endif.
1423   **    Endif.
1424
1425   **    If g_tabctrl110_wa-User_desc <> g_user_desc.
1426   **    Else.
1427   **        g_user_desc = g_tabctrl110_wa-User_desc.
1428   **    Endif.
1429   *    If g_ok_code110 = 'PB_AD'.
1430   *      g_user_desc = g_tabctrl110_wa-User_desc.
1431   *    Endif.
1432   *
1433   *    loop at screen.
1434   *      If screen-name = 'G_USER_DESC'.
1435   *        screen-length = user_desc_len.
1436   *        screen-input = 1.
1437   *        modify screen.
1438   *      Elseif screen-name = 'OK' or
1439   *             screen-name = 'CANC'.
1440   *        screen-input = 1.
1441   *        modify screen.
1442   *      Else.
1443   *        screen-input = 0.
1444   *        modify screen.
1445   *      Endif.
1446   ***
1447   *      If g_mode = 'DIS' or g_mode = 'REL' or g_mode = 'APR'.
1448   *        If screen-group1 = 'G1'.
1449   *          screen-input = 0.
1450   *          modify screen.
1451   *        Endif.
1452   *      Endif.
1453   ***
1454   *    Endloop.
1455   *
1456   *  Else.  "g_ok_code <> 'PB_AD'
1457   *    concatenate g_desc1 g_desc2
1458   *                g_desc3 g_desc4
1459   *                into g_desc1_4
1460   *                separated by space.
1461   *
1462   *    user_desc_len = 87 - strlen( g_desc1_4 ).
1463   *    If G_screen115_1st is initial.
1464   *
1465   *      If g_mode <> 'CHA'.
1466   *        clear g_user_desc.
1467   *      Endif.
1468   *
1469   *      Case 'OTHER'.
1470   *        when g_tabctrl110_wa-desc1.
1471   *          If g_desc1 = 'OTHER'.
1472   *            g_desc1 = ''.
1473   *          Endif.
1474   *          If g_matgp = 'XX'.
1475   *            g_matgp = ''.
1476   *          Endif.
1477   *          Export zmm_cdhd_st-mtart to memory id 'G_MATTY'.
1478   *        when g_tabctrl110_wa-desc2.
1479   *          g_desc1 = g_tabctrl110_wa-desc1.
1480   **        g_desc2 = ''.
1481   **        g_desc3 = ''.
1482   **        g_desc4 = ''.
1483   *
1484   *          loop at screen.
1485   *            if screen-name = 'G_DESC1' or
1486   *               screen-name = 'G_USER_DESC' or
1487   *               screen-name = 'G_MATGP'.
1488   *              screen-input = 0.
1489   *              modify screen.
1490   *            Endif.
1491   *          Endloop.
1492   *
1493   *        when g_tabctrl110_wa-desc3.
1494   *          g_desc1 = g_tabctrl110_wa-desc1.
1495   *          g_desc2 = g_tabctrl110_wa-desc2.
1496   **          g_desc3 = ''.
1497   **          g_desc4 = ''.
1498   *
1499   *          loop at screen.
1500   *            if screen-name = 'G_DESC1' or
1501   *               screen-name = 'G_DESC2' or
1502   *               screen-name = 'G_USER_DESC' or
1503   *               screen-name = 'G_MATGP'.
1504   *              screen-input = 0.
1505   *              modify screen.
1506   *            Endif.
1507   *          Endloop.
1508   *
1509   *        when g_tabctrl110_wa-desc4.
1510   *          g_desc1 = g_tabctrl110_wa-desc1.
1511   *          g_desc2 = g_tabctrl110_wa-desc2.
1512   *          g_desc3 = g_tabctrl110_wa-desc3.
1513   **          g_desc4 = ''.
1514   *
1515   *          loop at screen.
1516   *            if screen-name = 'G_DESC1' or
1517   *               screen-name = 'G_DESC2' or
1518   *               screen-name = 'G_DESC3' or
1519   *               screen-name = 'G_MATGP' or
1520   *               screen-name = 'G_USER_DESC'.
1521   *              screen-input = 0.
1522   *              modify screen.
1523   *            Endif.
1524   *          Endloop.
1525   *
1526   *      Endcase.
1527   *
1528   *      loop at screen.
1529   *        if screen-name = 'G_USER_DESC' and sy-ucomm = 'PB_AD'.
1530   *          screen-length = 40.
1531   *          screen-input = 1.
1532   *          modify screen.
1533   *        endif.
1534   *      Endloop.
1535   *    Else.
1536   *      loop at screen.
1537   *        if screen-name = 'G_USER_DESC'.
1538   *          screen-length = user_desc_len.
1539   *          screen-input = 1.
1540   *          modify screen.
1541   *        Elseif screen-name = 'G_MATGP'.
1542   *          screen-input = 0.
1543   *          modify screen.
1544   *        endif.
1545   *
1546   **        If g_spellerror = 'X'.
1547   **          if  screen-name = 'G_DESC1' or
1548   **              screen-name = 'G_DESC2' or
1549   **              screen-name = 'G_DESC3' or
1550   **              screen-name = 'G_DESC4' .
1551   **            screen-input = 1.
1552   **            modify screen.
1553   **          Endif.
1554   **
1555   **        Else.
1556   **          if screen-name = 'G_DESC1' or
1557   **             screen-name = 'G_DESC2' or
1558   **             screen-name = 'G_DESC3' or
1559   **             screen-name = 'G_DESC4' .
1560   **            screen-input = 0.
1561   **            modify screen.
1562   **          Endif.
1563   **        Endif.
1564   *        if screen-name = 'ADNL_DESC'.
1565   *          screen-input = 0.
1566   *          modify screen.
1567   *        Endif.
1568   **    If g_tabctrl110_wa-desc1 <> 'OTHER'.
1569   **       if screen-name = zmm_cditem-matgp.
1570   **          screen-input = 0.
1571   **       Endif.
1572   **    Endif.
1573   *      Endloop.
1574   *    Endif.
1575   *  Endif.
1576   **clear g_ok_code110.
1577
1578   *********Comment End *************************************************
1579   ***********************************************************************
1580   ENDMODULE.                 " STATUS_0115  OUTPUT
1581   *&---------------------------------------------------------------------*
1582   *&      Module  ist_alphanum  OUTPUT
1583   *&---------------------------------------------------------------------*
1584   *       text
1585   *----------------------------------------------------------------------*
1586   MODULE ist_alphanum OUTPUT.
1587     g_lineno = '1'.
1588     if check_flag = 'X'.
1589       EXIT.
1590     endif.
1591     check_flag = 'X'.
1592     Data : l_num type i.
1593     do 10 times.
1594       wa_alphanum = l_num.
1595       append wa_alphanum to ist_alphanum.
1596       l_num = l_num + 1.
1597     enddo.
1598     clear l_num.
1599     do 26 times.
1600       wa_alphanum = alpha+l_num(1).
1601   *translate wa_alphanum to upper case.
1602       append wa_alphanum to ist_alphanum.
1603       l_num = l_num + 1.
1604     enddo.
1605   ENDMODULE.                 " ist_alphanum  OUTPUT
1606
1607   *&---------------------------------------------------------------------*
1608   *&      Module  TABCTRL100_set_arrib  OUTPUT
1609   *&---------------------------------------------------------------------*
1610   *       text
1611   *----------------------------------------------------------------------*
1612   MODULE TABCTRL100_set_arrib OUTPUT.
1613
1614     loop at screen.
1615       if screen-name = 'DD' and ( wa_srchlp-mark = '1'
1616                                 or wa_srchlp-matnr is initial ) .
1617         screen-invisible = '1'.
1618         modify screen.
1619       endif.
1620     endloop.
1621
1622   ENDMODULE.                 " TABCTRL100_set_arrib  OUTPUT
1623
1624   *&---------------------------------------------------------------------*
1625   *&      Module  SPLITTER_CONTROL_VORBEREITEN  OUTPUT
1626   *&---------------------------------------------------------------------*
1627   *       text
1628   *----------------------------------------------------------------------*
1629   MODULE SPLITTER_CONTROL_VORBEREITEN OUTPUT.
1630
1631     if gv_splitter is initial.
1632       create object gv_custom_container
1633                     exporting container_name = 'C_CTRL_MAT_SPECS'
1634                     .
1635
1636       create object gv_splitter
1637              exporting
1638                     parent = gv_custom_container
1639                     orientation = 1
1640                     sash_position = 1.
1641     endif.
1642
1643   ENDMODULE.                 " SPLITTER_CONTROL_VORBEREITEN  OUTPUT
1644
1645   *&---------------------------------------------------------------------*
1646   *&      Module  TEXT_CONTROL_VORBEREITEN  OUTPUT
1647   *&---------------------------------------------------------------------*
1648   *       text
1649   *----------------------------------------------------------------------*
1650   MODULE TEXT_CONTROL_VORBEREITEN OUTPUT.
1651
1652     if gv_text_editor is initial.
1653       create object gv_text_editor
1654          exporting
1655               parent = gv_splitter->bottom_right_container
1656               wordwrap_mode = cl_gui_textedit=>wordwrap_at_windowborder
1657               wordwrap_to_linebreak_mode = cl_gui_textedit=>false
1658          exceptions
1659               error_cntl_create      = 1
1660               error_cntl_init        = 2
1661               error_cntl_link        = 3
1662               error_dp_create        = 4
1663               gui_type_not_supported = 5.
1664     endif.
1665
1666     perform text_control_eingabebereit.
1667     perform text_control_set_text_table.
1668
1669   ENDMODULE.                 " TEXT_CONTROL_VORBEREITEN  OUTPUT
1670
1671   *&---------------------------------------------------------------------*
1672   *&      Module  STATUS_0117  OUTPUT
1673   *&---------------------------------------------------------------------*
1674   *       text
1675   *----------------------------------------------------------------------*
1676   MODULE STATUS_0117 OUTPUT.
1677     SET PF-STATUS SPACE.
1678   *  SET TITLEBAR 'xxx'.
1679
1680   ENDMODULE.                 " STATUS_0117  OUTPUT
1681   *&---------------------------------------------------------------------*
1682   *&      Module  TABLCTRL120_change_field_attr  OUTPUT
1683   *&---------------------------------------------------------------------*
1684   *       text
1685   *----------------------------------------------------------------------*
1686   MODULE TABLCTRL120_change_field_attr OUTPUT.
1687
1688   *   get parameter id 'ZMATGP' field g_matgp.
1689
1690   *   g_TABCTRL110_wa-matgp = g_matgp.
1691
1692     SELECT * FROM ZMM_MODIFIER UP TO 1 ROWS
1693    WHERE DESC1 =
1694    G_TABLCTRL120_WA-DESC1
1695    ORDER BY PRIMARY KEY .
1696    ENDSELECT.
1697     if sy-subrc <> 0.
1698       g_parno = '1'.
1699     endif.
1700
1701     if sy-subrc = 0.
1702
1703       if  zmm_modifier-desc2 is initial.
1704         g_parno = '1'.
1705       elseif  zmm_modifier-desc3 is initial.
1706         g_parno = '2'.
1707       elseif  zmm_modifier-desc4 is initial.
1708         g_parno = '3'.
1709       else.
1710         g_parno = '4'.
1711       endif.
1712
1713     endif.
1714
1715
1716     case 'X'.
1717
1718       when ZMM_CDITEM-OTH1.
1719         clear: ZMM_CDITEM-OTH2, ZMM_CDITEM-OTH3, ZMM_CDITEM-OTH4.
1720         g_parno = '1'.
1721       when ZMM_CDITEM-OTH2.
1722         clear: ZMM_CDITEM-OTH3, ZMM_CDITEM-OTH4.
1723         g_parno = '2'.
1724       when ZMM_CDITEM-OTH3.
1725         clear: ZMM_CDITEM-OTH4.
1726         g_parno = '3'.
1727       when ZMM_CDITEM-OTH4.
1728         g_parno = '4'.
1729
1730     endcase.
1731   *
1732     loop at screen.
1733       case g_parno.
1734         when '0'.
1735           if screen-name = 'ZMM_CDITEM-DESC1'.
1736             screen-input = 0.
1737             modify screen.
1738           endif.
1739           if screen-name = 'ZMM_CDITEM-DESC2'.
1740             screen-input = 0.
1741             modify screen.
1742           endif.
1743           if screen-name = 'ZMM_CDITEM-DESC3'.
1744             screen-input = 0.
1745             modify screen.
1746           endif.
1747           if screen-name = 'ZMM_CDITEM-DESC4'.
1748             screen-input = 0.
1749             modify screen.
1750           endif.
1751         when '5'.
1752           if screen-name = 'ZMM_CDITEM-DESC1'.
1753             screen-input = 0.
1754             modify screen.
1755           endif.
1756           if screen-name = 'ZMM_CDITEM-DESC2'.
1757             screen-input = 0.
1758             modify screen.
1759           endif.
1760           if screen-name = 'ZMM_CDITEM-DESC3'.
1761             screen-input = 0.
1762             modify screen.
1763           endif.
1764           if screen-name = 'ZMM_CDITEM-DESC4'.
1765             screen-input = 0.
1766             modify screen.
1767           endif.
1768
1769           if screen-name = 'ZMM_CDITEM-USER_DESC'.
1770             screen-input = 1.
1771             modify screen.
1772           endif.
1773
1774         when '1'.
1775           if screen-name = 'ZMM_CDITEM-DESC2'.
1776             screen-input = 0.
1777             modify screen.
1778           endif.
1779           if screen-name = 'ZMM_CDITEM-DESC3'.
1780             screen-input = 0.
1781             modify screen.
1782           endif.
1783           if screen-name = 'ZMM_CDITEM-DESC4'.
1784             screen-input = 0.
1785             modify screen.
1786           endif.
1787           if screen-name = 'ZMM_CDITEM-USER_DESC'.
1788             screen-input = 1.
1789             modify screen.
1790           endif.
1791         when '2'.
1792           if screen-name = 'ZMM_CDITEM-DESC3'.
1793             screen-input = 0.
1794             modify screen.
1795           endif.
1796           if screen-name = 'ZMM_CDITEM-DESC4'.
1797             screen-input = 0.
1798             modify screen.
1799           endif.
1800           if screen-name = 'ZMM_CDITEM-USER_DESC'.
1801             screen-input = 1.
1802             modify screen.
1803           endif.
1804         when '3'.
1805           if screen-name = 'ZMM_CDITEM-DESC4' .
1806             screen-input = 0.
1807             modify screen.
1808           endif.
1809           if screen-name = 'ZMM_CDITEM-USER_DESC'.
1810             screen-input = 1.
1811             modify screen.
1812           endif.
1813         when '4'.
1814           if screen-name = 'ZMM_CDITEM-DESC2'.
1815             screen-input = 1.
1816             modify screen.
1817           endif.
1818           if screen-name = 'ZMM_CDITEM-DESC3'.
1819             screen-input = 1.
1820             modify screen.
1821           endif.
1822           if screen-name = 'ZMM_CDITEM-DESC4'.
1823             screen-input = 1.
1824             modify screen.
1825           endif.
1826           if screen-name = 'ZMM_CDITEM-USER_DESC'.
1827             screen-input = 1.
1828             modify screen.
1829           endif.
1830       endcase.
1831     endloop.
1832
1833
1834     Case g_mode.
1835       When 'CRE'.
1836         loop at screen.
1837           if Not g_TABLCTRL120_wa-partno IS INITIAL .
1838              if screen-name = 'ZMM_CDITEM-DESC_FIN' or
1839                 screen-name = 'ZMM_CDITEM-UOM'      or
1840                 screen-name = 'ZMM_CDITEM-CAP_CODE'.
1841                 screen-required = 1.
1842                 modify screen.
1843              endif.
1844            else.
1845              if screen-name = 'ZMM_CDITEM-DESC_FIN' or
1846                 screen-name = 'ZMM_CDITEM-UOM'      or
1847                 screen-name = 'ZMM_CDITEM-CAP_CODE'.
1848                 screen-input = 0.
1849                 modify screen.
1850              endif.
1851           endif.
1852   ****
1853           if Not g_TABLCTRL120_wa-CAP_CODE IS INITIAL .
1854              if screen-name = 'ZMM_CDITEM-MDLNO'    or
1855                 screen-name = 'ZMM_CDITEM-MANU'.
1856                 screen-required = 1.
1857                 modify screen.
1858              endif.
1859           else.
1860              if screen-name = 'ZMM_CDITEM-MDLNO'    or
1861                 screen-name = 'ZMM_CDITEM-MANU'.
1862                 screen-input = 0.
1863                 modify screen.
1864              endif.
1865           endif.
1866   ****
1867           if screen-name = 'ZMM_CDITEM-REQ_LT'.
1868             IF g_TABLCTRL120_wa-desc_fin is initial.
1869               screen-input = 0.
1870             ELSE.
1871               screen-input = 1.
1872             ENDIF.
1873             modify screen.
1874           endif.
1875   ****
1876           if screen-name = 'ZMM_CDITEM-REJ_FLG'.
1877            screen-input = 0.
1878            modify screen.
1879           endif.
1880   ****
1881           case g_parno.
1882
1883             when '5'.
1884
1885               if screen-name = 'ZMM_CDITEM-DESC1'.
1886                 screen-input = 0.
1887                 modify screen.
1888               endif.
1889               if screen-name = 'ZMM_CDITEM-DESC2'.
1890                 screen-input = 0.
1891                 modify screen.
1892               endif.
1893               if screen-name = 'ZMM_CDITEM-DESC3'.
1894                 screen-input = 0.
1895                 modify screen.
1896               endif.
1897               if screen-name = 'ZMM_CDITEM-DESC4'.
1898                 screen-input = 0.
1899                 modify screen.
1900               endif.
1901               if screen-name = 'ZMM_CDITEM-USER_DESC'.
1902                 screen-input = 1.
1903                 modify screen.
1904               endif.
1905
1906             when '1'.
1907               if screen-name = 'ZMM_CDITEM-DESC2'.
1908                 screen-input = 0.
1909                 modify screen.
1910               endif.
1911               if screen-name = 'ZMM_CDITEM-DESC3'.
1912                 screen-input = 0.
1913                 modify screen.
1914               endif.
1915               if screen-name = 'ZMM_CDITEM-DESC4'.
1916                 screen-input = 0.
1917                 modify screen.
1918               endif.
1919             when '2'.
1920               if screen-name = 'ZMM_CDITEM-DESC3'.
1921                 screen-input = 0.
1922                 modify screen.
1923               endif.
1924               if screen-name = 'ZMM_CDITEM-DESC4'.
1925                 screen-input = 0.
1926                 modify screen.
1927               endif.
1928             when '3'.
1929               if screen-name = 'ZMM_CDITEM-DESC4' .
1930                 screen-input = 0.
1931                 modify screen.
1932               endif.
1933             when '4'.
1934               if screen-name = 'ZMM_CDITEM-DESC2'.
1935                 screen-input = 1.
1936                 modify screen.
1937               endif.
1938               if screen-name = 'ZMM_CDITEM-DESC3'.
1939                 screen-input = 1.
1940                 modify screen.
1941               endif.
1942               if screen-name = 'ZMM_CDITEM-DESC4'.
1943                 screen-input = 1.
1944                 modify screen.
1945               endif.
1946           endcase.
1947         endloop.
1948       When 'CHA'.
1949         loop at screen.
1950           if Not g_TABLCTRL120_wa-partno IS INITIAL .
1951              if screen-name = 'ZMM_CDITEM-DESC_FIN' or
1952                 screen-name = 'ZMM_CDITEM-UOM'      or
1953                 screen-name = 'ZMM_CDITEM-CAP_CODE'.
1954                 screen-required = 1.
1955                 modify screen.
1956              endif.
1957            else.
1958              if screen-name = 'ZMM_CDITEM-DESC_FIN' or
1959                 screen-name = 'ZMM_CDITEM-UOM'      or
1960                 screen-name = 'ZMM_CDITEM-CAP_CODE'.
1961                 screen-input = 0.
1962                 modify screen.
1963              endif.
1964           endif.
1965   ****
1966           if Not g_TABLCTRL120_wa-CAP_CODE IS INITIAL .
1967              if screen-name = 'ZMM_CDITEM-MDLNO'    or
1968                 screen-name = 'ZMM_CDITEM-MANU'.
1969                 screen-required = 1.
1970                 modify screen.
1971              endif.
1972           else.
1973              if screen-name = 'ZMM_CDITEM-MDLNO'    or
1974                 screen-name = 'ZMM_CDITEM-MANU'.
1975                 screen-input = 0.
1976                 modify screen.
1977              endif.
1978           endif.
1979   ****
1980
1981           if screen-name = 'ZMM_CDITEM-REJ_FLG'.
1982            screen-input = 0.
1983            modify screen.
1984           endif.
1985
1986           if screen-name = 'ZMM_CDITEM-REQ_LT'.
1987             IF g_TABLCTRL120_wa-desc_fin is initial.
1988               screen-input = 0.
1989             ELSE.
1990               screen-input = 1.
1991             ENDIF.
1992             modify screen.
1993           endif.
1994         endloop.
1995       When 'DIS' OR 'DEL' OR 'REL'.
1996         loop at screen.
1997           if screen-name <> 'ZMM_CDITEM-REQ_LT'.
1998             screen-input = 0.
1999             modify screen.
2000           endif.
2001         endloop.
2002     Endcase.
2003     perform tcode_zcodg_attr.
2004
2005   ENDMODULE.                 " TABLCTRL120_change_field_attr  OUTPUT
2006   *&---------------------------------------------------------------------*
2007   *&      Module  TABLCTRL130_change_field_attr  OUTPUT
2008   *&---------------------------------------------------------------------*
2009   *       text
2010   *----------------------------------------------------------------------*
2011   MODULE TABLCTRL130_change_field_attr OUTPUT.
2012     Case g_mode.
2013       When 'CRE'.
2014         Loop at screen.
2015           If g_TABLCTRL130_wa-DESC_FIN is initial.
2016             if screen-name = 'ZMM_CDITEM-REJ_FLG' or
2017                screen-name = 'ZMM_CDITEM-MATCOST' or
2018                screen-name = 'ZMM_CDITEM-MATCATG' OR
2019                screen-name = 'ZMM_CDITEM-MATLOC' or
2020                screen-name = 'ZMM_CDITEM-WRKNG_LIFE' or
2021                screen-name = 'ZMM_CDITEM-SPA_GRP'.
2022                screen-input = 0.
2023                modify screen.
2024             endif.
2025           Else.
2026             If screen-name = 'ZMM_CDITEM-MATCOST' OR
2027                screen-name = 'ZMM_CDITEM-MATCATG' OR
2028                screen-name = 'ZMM_CDITEM-MATLOC'  OR
2029                screen-name = 'ZMM_CDITEM-WRKNG_LIFE' .
2030                screen-required = 1.
2031                modify screen.
2032             endif.
2033           Endif.
2034           if screen-name = 'ZMM_CDITEM-REJ_FLG' or
2035              screen-name = 'ZMM_CDITEM-SPA_GRP'.
2036             screen-input = 0.
2037             modify screen.
2038           endif.
2039
2040           if screen-name = 'ZMM_CDITEM-REQ_LT'.
2041             IF zmm_cditem-desc_fin is initial.
2042   *          IF g_TABLCTRL130_wa-desc_fin is initial.
2043               screen-input = 0.
2044             ELSE.
2045               screen-input = 1.
2046             ENDIF.
2047             modify screen.
2048           endif.
2049         Endloop.
2050         set cursor field 'ZMM_CDITEM-MATCOST'.
2051       When 'CHA'.
2052         loop at screen.
2053           if screen-name = 'ZMM_CDITEM-REQ_LT'.
2054             IF g_TABLCTRL130_wa-desc_fin is initial.
2055               screen-input = 0.
2056             ELSE.
2057               screen-input = 1.
2058             ENDIF.
2059             modify screen.
2060           endif.
2061           if screen-name = 'ZMM_CDITEM-SPA_GRP' OR
2062              screen-name = 'ZMM_CDITEM-REJ_FLG'.
2063              screen-input = 0.
2064              modify screen.
2065           endif.
2066         endloop.
2067       When 'DIS' OR 'DEL'.
2068         loop at screen.
2069           if screen-name <> 'ZMM_CDITEM-REQ_LT'.
2070             screen-input = 0.
2071             modify screen.
2072           endif.
2073         endloop.
2074     Endcase.
2075     perform tcode_zcodg_attr.
2076     If sy-tcode = 'ZCODG'.
2077        loop at screen.
2078           if screen-name = 'ZMM_CDITEM-SPA_GRP'.
2079              screen-input = 1.
2080              screen-required = 1.
2081              modify screen.
2082           endif.
2083        endloop.
2084     Endif.
2085   ENDMODULE.                 " TABLCTRL130_change_field_attr  OUTPUT
2086   *&---------------------------------------------------------------------*
2087   *&      Module  TABLCTRL140_change_field_attr  OUTPUT
2088   *&---------------------------------------------------------------------*
2089   *       text
2090   *----------------------------------------------------------------------*
2091   MODULE TABLCTRL140_change_field_attr OUTPUT.
2092     Case g_mode.
2093       When 'CRE'.
2094         loop at screen.
2095           if screen-name = 'ZMM_CDITEM-DESC_FIN'.
2096             screen-input = 0.
2097             modify screen.
2098           endif.
2099           if screen-name = 'ZMM_CDITEM-REQ_LT'.
2100             IF g_TABLCTRL140_wa-desc_fin is initial.
2101               screen-input = 0.
2102             ELSE.
2103               screen-input = 1.
2104             ENDIF.
2105             modify screen.
2106           endif.
2107         endloop.
2108       When 'CHA'.
2109         loop at screen.
2110           if screen-name = 'ZMM_CDITEM-REQ_LT'.
2111             IF g_TABLCTRL140_wa-desc_fin is initial.
2112               screen-input = 0.
2113             ELSE.
2114               screen-input = 1.
2115             ENDIF.
2116             modify screen.
2117           endif.
2118         endloop.
2119       When 'DIS' OR 'DEL'.
2120         loop at screen.
2121           if screen-name <> 'ZMM_CDITEM-REQ_LT'.
2122             screen-input = 0.
2123             modify screen.
2124           endif.
2125         endloop.
2126     Endcase.
2127
2128   ENDMODULE.                 " TABLCTRL140_change_field_attr  OUTPUT
2129   *&---------------------------------------------------------------------*
2130   *&      Module  STATUS_0105  OUTPUT
2131   *&---------------------------------------------------------------------*
2132   *       text
2133   *----------------------------------------------------------------------*
2134   MODULE STATUS_0105 OUTPUT.
2135     SET PF-STATUS 'STAT105'.
2136   *  SET TITLEBAR 'xxx'.
2137
2138   ENDMODULE.                 " STATUS_0105  OUTPUT
2139   *&---------------------------------------------------------------------*
2140   *&      Module  SPLITTER_CTRL_VORBEREITEN  OUTPUT
2141   *&---------------------------------------------------------------------*
2142   *       text
2143   *----------------------------------------------------------------------*
2144   MODULE SPLITTER_CTRL_VORBEREITEN OUTPUT.
2145     if gv_splitter1 is initial.
2146       create object gv_custom_container
2147                     exporting container_name = 'C_DIS'.
2148
2149
2150       create object gv_splitter1
2151              exporting
2152                     parent = gv_custom_container
2153                     orientation = 1
2154                     sash_position = 1.
2155     endif.
2156     if gv_splitter2 is initial.
2157
2158       create object gv_custom_container
2159                     exporting container_name = 'C_WRT'.
2160
2161
2162       create object gv_splitter2
2163              exporting
2164                     parent = gv_custom_container
2165                     orientation = 1
2166                     sash_position = 1.
2167
2168     endif.
2169
2170   ENDMODULE.                 " SPLITTER_CTRL_VORBEREITEN  OUTPUT
2171   *&---------------------------------------------------------------------*
2172   *&      Module  TEXT_CTRL_VORBEREITEN  OUTPUT
2173   *&---------------------------------------------------------------------*
2174   *       text
2175   *----------------------------------------------------------------------*
2176   MODULE TEXT_CTRL_VORBEREITEN OUTPUT.
2177     if gv_text_editor1 is initial.
2178       create object gv_text_editor1
2179          exporting
2180               parent = gv_splitter1->bottom_right_container
2181               wordwrap_mode = cl_gui_textedit=>wordwrap_at_windowborder
2182               wordwrap_to_linebreak_mode = cl_gui_textedit=>false
2183          exceptions
2184               error_cntl_create      = 1
2185               error_cntl_init        = 2
2186               error_cntl_link        = 3
2187               error_dp_create        = 4
2188               gui_type_not_supported = 5.
2189     endif.
2190     if gv_text_editor2 is initial.
2191       create object gv_text_editor2
2192          exporting
2193               parent = gv_splitter2->bottom_right_container
2194               wordwrap_mode = cl_gui_textedit=>wordwrap_at_windowborder
2195               wordwrap_to_linebreak_mode = cl_gui_textedit=>false
2196          exceptions
2197               error_cntl_create      = 1
2198               error_cntl_init        = 2
2199               error_cntl_link        = 3
2200               error_dp_create        = 4
2201               gui_type_not_supported = 5.
2202     endif.
2203
2204     perform text_control_eingabebereit.
2205     perform text_control_set_text_table.
2206
2207   ENDMODULE.                 " TEXT_CTRL_VORBEREITEN OUTPUT
2208   *&---------------------------------------------------------------------*
2209   *&      Module  SPLITTER_CTRL_VORBEREITEN1  OUTPUT
2210   *&---------------------------------------------------------------------*
2211   *       text
2212   *----------------------------------------------------------------------*
2213   MODULE SPLITTER_CTRL_VORBEREITEN1 OUTPUT.
2214     if gv_splitter1 is initial.
2215       create object gv_custom_container
2216                     exporting container_name = 'C_DIS'.
2217
2218       create object gv_splitter1
2219              exporting
2220                     parent = gv_custom_container
2221                     orientation = 1
2222                     sash_position = 1.
2223     endif.
2224
2225     if ( g_mode = 'CRE' ) or ( g_mode = 'CHA' ) OR
2226        ( g_mode = 'REL' ) or ( g_mode = 'MRP' ) OR
2227        ( g_mode = 'APR' ) or sy-tcode = 'ZCODG'.
2228
2229       if gv_splitter2 is initial.
2230
2231         create object gv_custom_container
2232                       exporting container_name = 'C_WRT'.
2233
2234
2235         create object gv_splitter2
2236                exporting
2237                       parent = gv_custom_container
2238                       orientation = 1
2239                       sash_position = 1.
2240
2241       endif.
2242     endif.
2243
2244   ENDMODULE.                 " SPLITTER_CTRL_VORBEREITEN1  OUTPUT
2245   *&---------------------------------------------------------------------*
2246   *&      Module  TEXT_CTRL_VORBEREITEN1  OUTPUT
2247   *&---------------------------------------------------------------------*
2248   *       text
2249   *----------------------------------------------------------------------*
2250   MODULE TEXT_CTRL_VORBEREITEN1 OUTPUT.
2251     if gv_text_editor1 is initial.
2252       create object gv_text_editor1
2253          exporting
2254               parent = gv_splitter1->bottom_right_container
2255               wordwrap_mode = cl_gui_textedit=>wordwrap_at_windowborder
2256               wordwrap_to_linebreak_mode = cl_gui_textedit=>false
2257          exceptions
2258               error_cntl_create      = 1
2259               error_cntl_init        = 2
2260               error_cntl_link        = 3
2261               error_dp_create        = 4
2262               gui_type_not_supported = 5.
2263     endif.
2264     if ( g_mode = 'CRE' ) or ( g_mode = 'CHA' ) OR
2265        ( g_mode = 'REL' ) or ( g_mode = 'MRP' ) OR
2266        ( g_mode = 'APR' ) or sy-tcode = 'ZCODG'.
2267
2268       if gv_text_editor2 is initial.
2269         create object gv_text_editor2
2270            exporting
2271                 parent = gv_splitter2->bottom_right_container
2272                 wordwrap_mode = cl_gui_textedit=>wordwrap_at_windowborder
2273                 wordwrap_to_linebreak_mode = cl_gui_textedit=>false
2274            exceptions
2275                 error_cntl_create      = 1
2276                 error_cntl_init        = 2
2277                 error_cntl_link        = 3
2278                 error_dp_create        = 4
2279                 gui_type_not_supported = 5.
2280       endif.
2281     endif.
2282
2283     perform text_control_eingabebereit1.
2284     perform text_control_set_text_table1.
2285
2286   ENDMODULE.                 " TEXT_CTRL_VORBEREITEN1  OUTPUT
2287
2288   *&---------------------------------------------------------------------*
2289   *&      Module  spell_ins_modi  OUTPUT
2290   *&---------------------------------------------------------------------*
2291   *       text
2292   *----------------------------------------------------------------------*
2293   MODULE spell_ins_modi OUTPUT.
2294   *if g_user <> 'X'.
2295   *loop at screen.
2296   *If screen-name = 'SPELL' or
2297   *   screen-name = 'INS_MODIFIERS'.
2298   *   screen-input = 0.
2299   *   modify screen.
2300   *Endif.
2301   *Endloop.
2302   *Endif.
2303   ENDMODULE.                 " spell_ins_modi  OUTPUT
2304
2305   *&---------------------------------------------------------------------*
2306   *&      Module  INITIALIZE  OUTPUT
2307   *&---------------------------------------------------------------------*
2308   *       text
2309   *----------------------------------------------------------------------*
2310   MODULE INITIALIZE OUTPUT.
2311     perform get_correspondense.
2312   ENDMODULE.                 " INITIALIZE  OUTPUT
2313   *&---------------------------------------------------------------------*
2314   *&      Module  get_mattytext  OUTPUT
2315   *&---------------------------------------------------------------------*
2316   *       text
2317   *----------------------------------------------------------------------*
2318   MODULE get_mattytext OUTPUT.
2319     Select single ddtext into g_mattytext from dd07t
2320            where domname    = 'ZMATTY'
2321            and   ddlanguage = sy-langu
2322            and   DOMVALUE_L = zmm_cdhd_st-mtart.
2323     if sy-subrc <> 0.
2324       g_mattytext = ''.
2325     endif.
2326   ***Plant Description
2327     Select single name1 into g_plantdesc from t001w
2328            where werks = zmm_cdhd_st-werks.
2329     if sy-subrc <> 0.
2330       g_plantdesc = ''.
2331     endif.
2332   ***Location Description
2333     Select single bldg into g_locdesc from zlocmst
2334            where locid = zmm_cdhd_st-reqloc.
2335     if sy-subrc <> 0.
2336       g_locdesc = ''.
2337     endif.
2338   ENDMODULE.                 " get_mattytext  OUTPUT
2339
2340   *&---------------------------------------------------------------------*
2341   *&      Module  WRITE_MESSAGES  INPUT
2342   *&---------------------------------------------------------------------*
2343   *       text
2344   *----------------------------------------------------------------------*
2345   MODULE WRITE_MESSAGES OUTPUT.
2346
2347     suppress dialog.
2348
2349     Leave to list-processing and return to screen 0.
2350
2351     if g_long_text_warning <> 'X'.
2352
2353       wa_message-srno = '000'.
2354       wa_message-msgtype = 'W'.
2355       wa_message-msgcode = 'C'.
2356   wa_message-msgtext = 'Detailed specifications can be entered if'
2357    &'required.'.
2358       append wa_message to ist_message.
2359       wa_message-srno = '   '.
2360       wa_message-msgtype = 'W'.
2361       wa_message-msgcode = 'C'.
2362   wa_message-msgtext = 'The same will get defaulted in the PR/PO documents '.
2363       append wa_message to ist_message.
2364       clear  g_long_text_warning.
2365
2366     endif.
2367
2368     SET PF-STATUS SPACE.
2369
2370     loop at ist_message into wa_message.
2371       if  wa_message-srno <> '   '.
2372         skip.
2373       endif.
2374       write: wa_message-srno, '|', wa_message-msgtype, '|',
2375   wa_message-msgtext.
2376     endloop.
2377
2378   ENDMODULE.                 " WRITE_MESSAGES  INPUT
2379   *&---------------------------------------------------------------------*
2380   *&      Module  TABCTRL110_check  OUTPUT
2381   *&---------------------------------------------------------------------*
2382   *       text
2383   *----------------------------------------------------------------------*
2384   MODULE TABCTRL110_check OUTPUT.
2385
2386   *if sy-ucomm = 'CHECK'.
2387     if check_code = 'CHECK'.
2388       loop at g_TABCTRL110_itab into g_TABCTRL110_wa.
2389
2390         if g_TABCTRL110_wa-mat_fnd > 0.
2391
2392           wa_message-srno = g_TABCTRL110_wa-srno.
2393           wa_message-msgtype = 'W'.
2394           wa_message-msgcode = 'A'.
2395         wa_message-msgtext = 'There is a list of material codes available as per selection.'.
2396           append wa_message to ist_message.
2397
2398           wa_message-srno = '   '.
2399           wa_message-msgtype = 'W'.
2400           wa_message-msgcode = 'A'.
2401         wa_message-msgtext = 'Do  you  still   require   fresh  material code?'.
2402
2403           append wa_message to ist_message.
2404
2405
2406           wa_message-srno = g_TABCTRL110_wa-srno.
2407           wa_message-msgtype = 'W'.
2408           wa_message-msgcode = 'B'.
2409         wa_message-msgtext =
2410         'Have you checked the detailed speifications(if any)'.
2411
2412           append wa_message to ist_message.
2413
2414           wa_message-srno = '   '.
2415           wa_message-msgtype = 'W'.
2416           wa_message-msgcode = 'B'.
2417         wa_message-msgtext =
2418         'in the  materials  list  appearing  in  the search help?'.
2419
2420           append wa_message to ist_message.
2421
2422         endif.
2423
2424         clear wa_message.
2425       endloop.
2426   *   Perform spell_check1.
2427   *   if g_spellerror = 'X'.
2428   *
2429   *      wa_message-msgtype = 'W'.
2430   *      wa_message-srno    = '000'.
2431   *      wa_message-msgcode = 'S'.
2432   *      wa_message-msgtext = 'Spelling  Errors'.
2433   *      append wa_message to ist_message.
2434   *   Endif.
2435
2436       describe table g_TABCTRL110_itab lines check_lines.
2437
2438       if check_lines > 0.
2439
2440         Call Screen 102 starting at 10 05 ending at 100 15.
2441
2442       else.
2443
2444         message i028(zmm_oth).
2445
2446       endif.
2447
2448       clear : g_TABCTRL110_wa-dsflag,  g_long_text_warning .
2449
2450     endif.
2451
2452   ENDMODULE.                 " TABCTRL110_check  OUTPUT
2453   *_______________________________________________________________________
2454   *&---------------------------------------------------------------------*
2455   *&      Module  TABCTRL100_change_col_attr  OUTPUT
2456   *&---------------------------------------------------------------------*
2457   *       text
2458   *----------------------------------------------------------------------*
2459   MODULE TABCTRL100_change_col_attr OUTPUT.
2460
2461     if ZMM_CDHD_ST-MTART = 'ZSTO' OR ZMM_CDHD_ST-MTART = 'ZCAP'.
2462       LOOP AT TABCTRL100-cols INTO cols WHERE index GT 5.
2463         cols-invisible = '1'.
2464         if cols-screen-name = 'WA_SRCHLP-MAKTX'.
2465           cols-vislength = '65'.
2466         Endif.
2467         MODIFY TABCTRL100-cols FROM cols INDEX sy-tabix.
2468       ENDLOOP.
2469     Elseif ZMM_CDHD_ST-MTART = 'ZSPR'.
2470       LOOP AT TABCTRL100-cols INTO cols.
2471         if cols-screen-name = 'WA_SRCHLP-MAKTX'.
2472           cols-vislength = '40'.
2473           MODIFY TABCTRL100-cols FROM cols INDEX sy-tabix.
2474         Endif.
2475       ENDLOOP.
2476     endif.
2477
2478   ENDMODULE.                 " TABCTRL100_change_col_attr  OUTPUT
2479   *&---------------------------------------------------------------------*
2480   *&      Module  STATUS_0102  OUTPUT
2481   *&---------------------------------------------------------------------*
2482   *       text
2483   *----------------------------------------------------------------------*
2484   MODULE STATUS_0102 OUTPUT.
2485   *  SET PF-STATUS SPACE.
2486   *  SET TITLEBAR 'xxx'.
2487
2488   ENDMODULE.                 " STATUS_0102  OUTPUT
2489   *&---------------------------------------------------------------------*
2490   *&      Module  STATUS_0103  OUTPUT
2491   *&---------------------------------------------------------------------*
2492   *       text
2493   *----------------------------------------------------------------------*
2494   MODULE STATUS_0103 OUTPUT.
2495     SET PF-STATUS 'STAT_REL'.
2496
2497   ENDMODULE.                 " STATUS_0103  OUTPUT
2498   *&---------------------------------------------------------------------*
2499   *&      Module  WRITE_CERTI  OUTPUT
2500   *&---------------------------------------------------------------------*
2501   *       text
2502   *----------------------------------------------------------------------*
2503   MODULE WRITE_CERTI OUTPUT.
2504   *+060505
2505     SUPPRESS DIALOG.
2506     SET PF-STATUS 'STAT_REL'.
2507
2508     LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.
2509   *
2510     NEW-PAGE NO-TITLE.
2511   Case g_mode .
2512     When 'REL'.
2513       If ( g_user = 'M' or g_user = 'L' or zmm_cdhd_st-reqcpf = sy-uname )
2514   .
2515       Write : / '                   Acknowledgement        '
2516               Color 3.
2517       Write : / '-----------------------------------------------------'.
2518       write : / 'The details in the request have been checked and'.
2519       Write : / 'confirmed. Please process the request for generation'.
2520       write : / 'of new Material Code.'.
2521     Else.
2522         Message i042(zmm_oth).
2523         leave to screen 0.
2524     Endif.
2525
2526    When 'APR' .
2527     If  g_user = 'M'.
2528     Write : / '                   Acknowledgement                       '
2529              Color 5.
2530       Write : / '-----------------------------------------------------'.
2531       write : / 'The details in the request have been rechecked and'.
2532       Write : / 'confirmed. Please process the request for generation'.
2533       write : / 'of new Material Code.'.
2534     Else.
2535       message i043(zmm_oth).
2536       leave to screen 0.
2537     Endif.
2538   Endcase.
2539
2540   ENDMODULE.                 " WRITE_CERTI  OUTPUT
2541   *&---------------------------------------------------------------------*
2542   *&      Module  STATUS_0150  OUTPUT
2543   *&---------------------------------------------------------------------*
2544   *       text
2545   *----------------------------------------------------------------------*
2546   MODULE STATUS_0150 OUTPUT.
2547     SET PF-STATUS 'STATUS150'.
2548   *  SET TITLEBAR 'xxx'.
2549
2550   ENDMODULE.                 " STATUS_0150  OUTPUT
2551   *&---------------------------------------------------------------------*
2552   *&      Module  scr100_sh_attr  OUTPUT
2553   *&---------------------------------------------------------------------*
2554   *       text
2555   *----------------------------------------------------------------------*
2556   MODULE scr100_sh_attr OUTPUT.
2557    case zmm_cdhd_st-mtart.
2558        when 'ZSTO' or 'ZCAP' or 'ZDIS'.
2559          loop at screen.
2560           if screen-group2 = 'SH'.
2561            screen-invisible = 1.
2562            modify screen.
2563           endif.
2564          endloop.
2565    endcase.
2566   ENDMODULE.                 " scr100_sh_attr  OUTPUT
2567   *&---------------------------------------------------------------------*
2568   *&      Module  Set_attrib  OUTPUT
2569   *&---------------------------------------------------------------------*
2570   *       text
2571   *----------------------------------------------------------------------*
2572   MODULE Set_attrib OUTPUT.
2573
2574   ************************************************************************
2575   Case G_MODE.
2576     When 'DIS' OR 'DEL' OR 'REL' OR 'APR'.
2577       IF g_ok_code110 = 'PB_AD' AND g_ok_code115 = ''.
2578        g_desc1 = g_tabctrl110_wa-desc1.
2579        g_desc2 = g_tabctrl110_wa-desc2.
2580        g_desc3 = g_tabctrl110_wa-desc3.
2581        g_desc4 = g_tabctrl110_wa-desc4.
2582        IF g_tabctrl110_wa-matgp <> 'XX'.
2583         g_matgp = g_tabctrl110_wa-matgp.
2584        ENDIF.
2585        g_user_desc = g_tabctrl110_wa-user_desc.
2586        concatenate g_desc1 g_desc2
2587                    g_desc3 g_desc4 into g_desc1_4
2588                    separated by space.
2589        user_desc_len = 87 - strlen( g_desc1_4 ).
2590        Loop at screen.
2591          If screen-group1 = 'G1'.
2592             screen-input = 0.
2593             modify screen.
2594           Endif.
2595           IF screen-name = 'G_USER_DESC'.
2596             screen-length = user_desc_len.
2597             modify screen.
2598           ENDIF.
2599        Endloop.
2600       ENDIF.
2601     WHEN 'CRE' OR 'CHA'.
2602       concatenate g_desc1 g_desc2
2603                   g_desc3 g_desc4
2604                   into g_desc1_4
2605                   separated by space.
2606
2607       user_desc_len = 87 - strlen( g_desc1_4 ).
2608
2609   *    If G_screen115_1st is initial.
2610        Case 'OTHER'.
2611           when g_tabctrl110_wa-desc1.
2612             If g_desc1 = 'OTHER'.
2613               g_desc1 = ''.
2614             Endif.
2615             If g_matgp = 'XX'.
2616               g_matgp = ''.
2617             Endif.
2618             Loop at screen.
2619               If screen-name = 'G_USER_DESC'.
2620                  screen-input = 0.
2621                  screen-length = 40.
2622                 modify screen.
2623               Endif.
2624             Endloop.
2625   ** User enter material group in the screen 115, if 'OTHER'
2626   ** is selected in the main attribute
2627             Export zmm_cdhd_st-mtart to memory id 'G_MATTY'.
2628   **
2629           when g_tabctrl110_wa-desc2.
2630             g_desc1 = g_tabctrl110_wa-desc1.
2631             Loop at screen.
2632               If screen-name = 'G_DESC1' or
2633                  screen-name = 'G_USER_DESC' or
2634                  screen-name = 'G_MATGP'.
2635                 screen-input = 0.
2636                 modify screen.
2637               Endif.
2638             Endloop.
2639
2640           when g_tabctrl110_wa-desc3.
2641             g_desc1 = g_tabctrl110_wa-desc1.
2642             g_desc2 = g_tabctrl110_wa-desc2.
2643             Loop at screen.
2644               If screen-name = 'G_DESC1' or
2645                  screen-name = 'G_DESC2' or
2646                  screen-name = 'G_USER_DESC' or
2647                  screen-name = 'G_MATGP'.
2648                 screen-input = 0.
2649                 modify screen.
2650               Endif.
2651             Endloop.
2652
2653           when g_tabctrl110_wa-desc4.
2654             g_desc1 = g_tabctrl110_wa-desc1.
2655             g_desc2 = g_tabctrl110_wa-desc2.
2656             g_desc3 = g_tabctrl110_wa-desc3.
2657             loop at screen.
2658               If screen-name = 'G_DESC1' or
2659                  screen-name = 'G_DESC2' or
2660                  screen-name = 'G_DESC3' or
2661                  screen-name = 'G_MATGP' or
2662                  screen-name = 'G_USER_DESC'.
2663                 screen-input = 0.
2664                 modify screen.
2665               Endif.
2666             Endloop.
2667
2668         Endcase.
2669   ****
2670            Perform other_sectime.
2671   ****
2672        Case g_ok_code115.
2673         When 'A_DESC'.
2674          loop at screen.
2675            if screen-name = 'G_USER_DESC'.
2676             screen-length = user_desc_len.
2677             screen-input = 1.
2678             modify screen.
2679            endif.
2680          Endloop.
2681         ENDCASE.
2682
2683
2684         IF g_ok_code110 = 'PB_AD' AND g_ok_code115 = ''.
2685            g_desc1 = g_tabctrl110_wa-desc1.
2686            g_desc2 = g_tabctrl110_wa-desc2.
2687            g_desc3 = g_tabctrl110_wa-desc3.
2688            g_desc4 = g_tabctrl110_wa-desc4.
2689            g_matgp = g_tabctrl110_wa-matgp.
2690            IF G_screen115_1st is initial.
2691             g_user_desc = g_tabctrl110_wa-user_desc.
2692             G_screen115_1st = 'X'.
2693            ENDIF.
2694            concatenate g_desc1 g_desc2
2695                        g_desc3 g_desc4 into g_desc1_4
2696                        separated by space.
2697            user_desc_len = 87 - strlen( g_desc1_4 ).
2698            loop at screen.
2699              if screen-name = 'G_DESC1' or
2700                 screen-name = 'G_DESC2' or
2701                 screen-name = 'G_DESC3' or
2702                 screen-name = 'G_DESC4' or
2703                 screen-name = 'G_MATGP'.
2704               screen-input  = 0.
2705               modify screen.
2706              elseif screen-name = 'G_USER_DESC'.
2707               screen-length = user_desc_len.
2708               screen-input  = 1.
2709               modify screen.
2710              endif.
2711            endloop.
2712         ENDIF.
2713   Endcase.
2714
2715   IF sy-tcode = 'ZCODG' .
2716        g_desc1 = g_tabctrl110_wa-desc1.
2717        g_desc2 = g_tabctrl110_wa-desc2.
2718        g_desc3 = g_tabctrl110_wa-desc3.
2719        g_desc4 = g_tabctrl110_wa-desc4.
2720        IF g_tabctrl110_wa-matgp <> 'XX'.
2721         g_matgp = g_tabctrl110_wa-matgp.
2722        ENDIF.
2723        concatenate g_desc1 g_desc2
2724                   g_desc3 g_desc4
2725                   into g_desc1_4
2726                   separated by space.
2727        user_desc_len = 87 - strlen( g_desc1_4 ).
2728        g_user_desc = g_tabctrl110_wa-user_desc.
2729
2730        IF g_ok_code110 = 'PB_AD'.
2731          loop at screen.
2732              if screen-name = 'G_DESC1' or
2733                 screen-name = 'G_DESC2' or
2734                 screen-name = 'G_DESC3' or
2735                 screen-name = 'G_DESC4' or
2736                 screen-name = 'G_MATGP'.
2737               screen-input  = 0.
2738               modify screen.
2739              elseif screen-name = 'G_USER_DESC'.
2740               screen-length = user_desc_len.
2741               screen-input  = 1.
2742               modify screen.
2743              endif.
2744          endloop.
2745        ELSE.
2746          loop at screen.
2747            if screen-name = 'G_DESC1'.
2748              if ZMM_CDITEM-OTH1 = 'X'.
2749                screen-input = 1.
2750              else.
2751                screen-input = 0.
2752              endif.
2753                modify screen.
2754            elseif screen-name = 'G_DESC2'.
2755              if ZMM_CDITEM-OTH1 = 'X' OR
2756                 ZMM_CDITEM-OTH2 = 'X'.
2757                 screen-input = 1.
2758              else.
2759                 screen-input = 0.
2760              endif.
2761              modify screen.
2762            elseif screen-name = 'G_DESC3'.
2763              if ZMM_CDITEM-OTH1 = 'X' OR
2764                 ZMM_CDITEM-OTH2 = 'X' OR
2765                 ZMM_CDITEM-OTH3 = 'X'.
2766                 screen-input = 1.
2767              else.
2768                 screen-input = 0.
2769              endif.
2770                 modify screen.
2771            elseif screen-name = 'G_DESC4'.
2772              if ZMM_CDITEM-OTH1 = 'X' OR
2773                 ZMM_CDITEM-OTH2 = 'X' OR
2774                 ZMM_CDITEM-OTH3 = 'X' OR
2775                 ZMM_CDITEM-OTH4 = 'X'.
2776                 screen-input = 1.
2777              else.
2778                 screen-input = 0.
2779              endif.
2780              modify screen.
2781            elseif screen-name = 'G_USER_DESC'.
2782               screen-length = user_desc_len.
2783               screen-input  = 0.
2784               modify screen.
2785            endif.
2786           endloop.
2787        ENDIF.
2788
2789        Case g_ok_code115.
2790         When 'A_DESC'.
2791          loop at screen.
2792             if  screen-name = 'G_DESC1' or
2793                 screen-name = 'G_DESC2' or
2794                 screen-name = 'G_DESC3' or
2795                 screen-name = 'G_DESC4' or
2796                 screen-name = 'G_MATGP'.
2797                 screen-input  = 0.
2798               modify screen.
2799             elseif screen-name = 'G_USER_DESC'.
2800               screen-length = user_desc_len.
2801               screen-input = 1.
2802               modify screen.
2803            endif.
2804          Endloop.
2805         ENDCASE.
2806
2807   Endif.
2808   ************************************************************************
2809   *  IF g_ok_code110 = 'PB_AD' AND g_ok_code115 = ''.
2810   *     g_desc1 = g_tabctrl110_wa-desc1.
2811   *     g_desc2 = g_tabctrl110_wa-desc2.
2812   *     g_desc3 = g_tabctrl110_wa-desc3.
2813   *     g_desc4 = g_tabctrl110_wa-desc4.
2814   *     g_matgp = g_tabctrl110_wa-matgp.
2815   *
2816   *     concatenate g_desc1 g_desc2
2817   *                 g_desc3 g_desc4 into g_desc1_4
2818   *                 separated by space.
2819   *     user_desc_len = 87 - strlen( g_desc1_4 ).
2820   *
2821   *    If g_ok_code110 = 'PB_AD'.
2822   *      g_user_desc = g_tabctrl110_wa-User_desc.
2823   *    Endif.
2824   *
2825   *    loop at screen.
2826   *      If screen-name = 'G_USER_DESC'.
2827   *        screen-length = user_desc_len.
2828   *        screen-input = 1.
2829   *        modify screen.
2830   *      Elseif screen-name = 'OK' or
2831   *             screen-name = 'CANC'.
2832   *        screen-input = 1.
2833   *        modify screen.
2834   *      Else.
2835   *        screen-input = 0.
2836   *        modify screen.
2837   *      Endif.
2838   ***
2839   *      If g_mode = 'DIS' or g_mode = 'REL' or g_mode = 'APR'.
2840   *        If screen-group1 = 'G1'.
2841   *          screen-input = 0.
2842   *          modify screen.
2843   *        Endif.
2844   *      Endif.
2845   ***
2846   *    Endloop.
2847   *
2848   *  Else.  "g_ok_code <> 'PB_AD'
2849   *    concatenate g_desc1 g_desc2
2850   *                g_desc3 g_desc4
2851   *                into g_desc1_4
2852   *                separated by space.
2853   *
2854   *    user_desc_len = 87 - strlen( g_desc1_4 ).
2855   *    If G_screen115_1st is initial.
2856   *
2857   *      If g_mode <> 'CHA'.
2858   *        clear g_user_desc.
2859   *      Endif.
2860   *
2861   *      Case 'OTHER'.
2862   *        when g_tabctrl110_wa-desc1.
2863   *          If g_desc1 = 'OTHER'.
2864   *            g_desc1 = ''.
2865   *          Endif.
2866   *          If g_matgp = 'XX'.
2867   *            g_matgp = ''.
2868   *          Endif.
2869   *          Export zmm_cdhd_st-mtart to memory id 'G_MATTY'.
2870   *        when g_tabctrl110_wa-desc2.
2871   *          g_desc1 = g_tabctrl110_wa-desc1.
2872   *          Loop at screen.
2873   *            If screen-name = 'G_DESC1' or
2874   *               screen-name = 'G_USER_DESC' or
2875   *               screen-name = 'G_MATGP'.
2876   *              screen-input = 0.
2877   *              modify screen.
2878   *            Endif.
2879   *          Endloop.
2880   *
2881   *        when g_tabctrl110_wa-desc3.
2882   *          g_desc1 = g_tabctrl110_wa-desc1.
2883   *          g_desc2 = g_tabctrl110_wa-desc2.
2884   *          loop at screen.
2885   *            if screen-name = 'G_DESC1' or
2886   *               screen-name = 'G_DESC2' or
2887   *               screen-name = 'G_USER_DESC' or
2888   *               screen-name = 'G_MATGP'.
2889   *              screen-input = 0.
2890   *              modify screen.
2891   *            Endif.
2892   *          Endloop.
2893   *
2894   *        when g_tabctrl110_wa-desc4.
2895   *          g_desc1 = g_tabctrl110_wa-desc1.
2896   *          g_desc2 = g_tabctrl110_wa-desc2.
2897   *          g_desc3 = g_tabctrl110_wa-desc3.
2898   *          loop at screen.
2899   *            if screen-name = 'G_DESC1' or
2900   *               screen-name = 'G_DESC2' or
2901   *               screen-name = 'G_DESC3' or
2902   *               screen-name = 'G_MATGP' or
2903   *               screen-name = 'G_USER_DESC'.
2904   *              screen-input = 0.
2905   *              modify screen.
2906   *            Endif.
2907   *          Endloop.
2908   *
2909   *      Endcase.
2910   *
2911   *      loop at screen.
2912   *        if screen-name = 'G_USER_DESC' and sy-ucomm = 'PB_AD'.
2913   *          screen-length = 40.
2914   *          screen-input = 1.
2915   *          modify screen.
2916   *        endif.
2917   *      Endloop.
2918   *    Else.
2919   *      loop at screen.
2920   *        if screen-name = 'G_USER_DESC'.
2921   *          screen-length = user_desc_len.
2922   *          screen-input = 1.
2923   *          modify screen.
2924   *        Elseif screen-name = 'G_MATGP'.
2925   *          screen-input = 0.
2926   *          modify screen.
2927   *        endif.
2928   *        if screen-name = 'ADNL_DESC'.
2929   *          screen-input = 0.
2930   *          modify screen.
2931   *        Endif.
2932   *      Endloop.
2933   *    Endif.
2934   *  Endif.
2935   **clear g_ok_code110.
2936
2937   ENDMODULE.                 " Set_attrib  OUTPUT
2938
2939   *&---------------------------------------------------------------------*
2940   *&      Module  get_coddesc  OUTPUT
2941   *&---------------------------------------------------------------------*
2942   *       text
2943   *----------------------------------------------------------------------*
2944   MODULE get_coddesc OUTPUT.
2945   if not zmm_cditem-cap_code is initial.
2946    SELECT MAKTX INTO ZMM_CDITEM-CAP_NAME FROM MAKT UP TO 1 ROWS
2947    WHERE MATNR = ZMM_CDITEM-CAP_CODE
2948    ORDER BY PRIMARY KEY .
2949    ENDSELECT.
2950    if sy-subrc <> 0.
2951   *    message e041(zmm_oth) with zmm_cditem-cap_code.
2952        zmm_cditem-cap_name = ''.
2953    Endif.
2954   Endif.
2955   ENDMODULE.                 " get_coddesc  OUTPUT
2956   *&---------------------------------------------------------------------*
2957   *&      Module  TABCTRL120_check  OUTPUT
2958   *&---------------------------------------------------------------------*
2959   *       text
2960   *----------------------------------------------------------------------*
2961   MODULE TABCTRL120_check OUTPUT.
2962   clear g_mat_fnd.
2963   if check_code = 'CHECK'.
2964       loop at g_TABLCTRL120_itab into g_TABLCTRL120_wa.
2965
2966         if g_TABLCTRL120_wa-mat_fnd > 0.
2967
2968           wa_message-srno = g_TABLCTRL120_wa-srno.
2969           wa_message-msgtype = 'W'.
2970           wa_message-msgcode = 'A'.
2971         wa_message-msgtext = 'There is a list of material codes available as per selection.'.
2972           append wa_message to ist_message.
2973
2974           wa_message-srno = '   '.
2975           wa_message-msgtype = 'W'.
2976           wa_message-msgcode = 'A'.
2977         wa_message-msgtext = 'Do  you  still   require   fresh  material code?'.
2978
2979           append wa_message to ist_message.
2980
2981
2982           wa_message-srno = g_TABLCTRL120_wa-srno.
2983           wa_message-msgtype = 'W'.
2984           wa_message-msgcode = 'B'.
2985         wa_message-msgtext =
2986         'Have you checked the detailed speifications(if any)'.
2987
2988           append wa_message to ist_message.
2989
2990           wa_message-srno = '   '.
2991           wa_message-msgtype = 'W'.
2992           wa_message-msgcode = 'B'.
2993         wa_message-msgtext =
2994         'in the  materials  list  appearing  in  the search help?'.
2995
2996           append wa_message to ist_message.
2997
2998         endif.
2999
3000         clear wa_message.
3001       endloop.
3002
3003       describe table g_TABLCTRL120_itab lines check_lines.
3004
3005       if check_lines > 0.
3006
3007         Call Screen 102 starting at 10 05 ending at 100 15.
3008
3009       else.
3010
3011         message i028(zmm_oth).
3012
3013       endif.
3014
3015       clear : g_TABLCTRL120_wa-dsflag,  g_long_text_warning .
3016
3017     endif.
3018
3019   ENDMODULE.                 " TABCTRL120_check  OUTPUT
3020   *&---------------------------------------------------------------------*
3021   *&      Module  STATUS_0116  OUTPUT
3022   *&---------------------------------------------------------------------*
3023   *       text
3024   *----------------------------------------------------------------------*
3025   MODULE STATUS_0116 OUTPUT.
3026     SET PF-STATUS 'STAT115'.
3027   ENDMODULE.                 " STATUS_0116  OUTPUT
3028   *&---------------------------------------------------------------------*
3029   *&      Module  loopat_matty_data  OUTPUT
3030   *&---------------------------------------------------------------------*
3031   *       text
3032   *----------------------------------------------------------------------*
3033   *&---------------------------------------------------------------------*
3034   *&      Module  get_srchitab  OUTPUT
3035   *&---------------------------------------------------------------------*
3036   *       text
3037   *----------------------------------------------------------------------*
3038   MODULE get_srchitab OUTPUT.
3039   IF zmm_cdhd_st-mtart = 'ZSPR'.
3040    If NOT g_fst_srchlp IS INITIAL.
3041     IF g_sh_capeqt  = '' and
3042        g_sh_mfr     = '' and
3043        g_sh_mdlno   = ''.
3044        ist_srchlp = ist_srchlp_cpo.
3045     ELSE.
3046        ist_srchlp = ist_srchlp_cp.
3047     ENDIF.
3048    Else.
3049     append lines of ist_srchlp to ist_srchlp_cpo.
3050     If FIELD1 = 'ZMM_CDITEM-PARTNO' .
3051      g_fst_srchlp = 'X'.
3052     ENDIF.
3053    Endif.
3054   * g_fst_srchlp = 'X'.
3055   ENDIF.
3056   ENDMODULE.                 " get_srchitab  OUTPUT
3057   *&---------------------------------------------------------------------*
3058   *&      Module  Modelno_LIST  OUTPUT
3059   *&---------------------------------------------------------------------*
3060   *       text
3061   *----------------------------------------------------------------------*
3062   MODULE Modelno_LIST OUTPUT.
3063    SUPPRESS DIALOG.
3064     LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.
3065     SET PF-STATUS SPACE.
3066     NEW-PAGE NO-TITLE.
3067     sort ist_modifier_check_list by matgrp desc1.
3068     if ZMM_CDHD_ST-MTART = 'ZSTO'.
3069              WRITE : / 'Select group :' .
3070           ULINE.
3071           Loop at ist_modifier_check_list .
3072              WRITE: / ist_modifier_check_list-matgrp,
3073                        ist_modifier_check_list-desc1 COLOR COL_POSITIVE
3074   INTENSIFIED OFF .
3075              HIDE ist_modifier_check_list-matgrp.
3076           Endloop.
3077     else.
3078           WRITE : / 'List of Models similar to :' , ist_sval_org COLOR
3079         col_total.
3080           ULINE.
3081           Loop at ist_mdl.
3082              WRITE: / ist_mdl-mdlno COLOR COL_POSITIVE INTENSIFIED OFF.  "#EC CI_FLDEXT_OK[2215424]
3083              HIDE ist_mdl-mdlno.
3084           Endloop.
3085       endif.
3086
3087   ENDMODULE.                 " Modelno_LIST  OUTPUT
3088   *&---------------------------------------------------------------------*
3089   *&      Module  techauth_visiblity  OUTPUT
3090   *&---------------------------------------------------------------------*
3091   *       text
3092   *----------------------------------------------------------------------*
3093   MODULE techauth_visiblity OUTPUT.
3094   clear g_techapr_visible.
3095   read table g_TABCTRL110_itab into g_TABCTRL110_wa with key oth1 = 'X'.
3096   if sy-subrc = 0.
3097    g_techapr_visible = 'Y'.
3098   else.
3099    g_techapr_visible = ''.
3100   endif.
3101
3102   *loop at   g_TABCTRL110_itab
3103   *       into g_TABCTRL110_wa.
3104   *  if g_TABCTRL110_wa-oth1 = 'X'.
3105   *     g_techapr_visible = 'Y'.
3106   *     exit.
3107   *  else.
3108   *     g_techapr_visible = ''.
3109   *  endif.
3110   *endloop.
3111
3112   ENDMODULE.                 " techauth_visiblity  OUTPUT
3113   *&---------------------------------------------------------------------*
3114   *&      Module  set_cursor_line  OUTPUT
3115   *&---------------------------------------------------------------------*
3116   *       text
3117   *----------------------------------------------------------------------*
3118   MODULE set_cursor_line OUTPUT.
3119
3120   case zmm_cdhd_st-mtart.
3121       when 'ZCAP'.
3122       If g_mode = 'CRE' and g_curfield = 'ZMM_CDHD_ST-TEL'.
3123          SET CURSOR FIELD 'ZMM_CDITEM-DESC_FIN' LINE 1.
3124       Else.
3125          SET CURSOR FIELD g_curfield130 LINE G_CURR_LINE_130 .
3126       Endif.
3127       When 'ZSPR'.
3128         If g_mode = 'CRE' and g_curfield = 'ZMM_CDHD_ST-TEL'.
3129           SET CURSOR FIELD 'ZMM_CDITEM-PARTNO' LINE 1.
3130         Else.
3131          SET CURSOR FIELD g_curfield120 LINE G_CURR_LINE_120 .
3132         Endif.
3133       When 'ZSTO'.
3134         If g_mode = 'CRE' and g_curfield = 'ZMM_CDHD_ST-TEL'.
3135             SET CURSOR FIELD 'ZMM_CDITEM-DESC1' LINE 1.
3136         Else.
3137            SET CURSOR FIELD g_curfield110 LINE G_CURR_LINE_110.
3138         Endif.
3139   Endcase.
3140
3141
3142   ENDMODULE.                 " set_cursor_line  OUTPUT
3143   *&---------------------------------------------------------------------*
3144   *&      Module  TABLCTRL130_check  OUTPUT
3145   *&---------------------------------------------------------------------*
3146   *       text
3147   *----------------------------------------------------------------------*
3148   MODULE TABLCTRL130_check OUTPUT.
3149
3150    if check_code = 'CHECK'.
3151       loop at g_TABLCTRL130_itab into g_TABLCTRL130_wa.
3152
3153         if g_TABLCTRL130_wa-mat_fnd > 0.
3154
3155           wa_message-srno = g_TABLCTRL130_wa-srno.
3156           wa_message-msgtype = 'W'.
3157           wa_message-msgcode = 'A'.
3158         wa_message-msgtext = 'There is a list of material codes available as per selection.'.
3159           append wa_message to ist_message.
3160
3161           wa_message-srno = '   '.
3162           wa_message-msgtype = 'W'.
3163           wa_message-msgcode = 'A'.
3164         wa_message-msgtext = 'Do  you  still   require   fresh  material code?'.
3165
3166           append wa_message to ist_message.
3167
3168
3169           wa_message-srno = g_TABLCTRL130_wa-srno.
3170           wa_message-msgtype = 'W'.
3171           wa_message-msgcode = 'B'.
3172         wa_message-msgtext =
3173         'Have you checked the detailed speifications(if any)'.
3174
3175           append wa_message to ist_message.
3176
3177           wa_message-srno = '   '.
3178           wa_message-msgtype = 'W'.
3179           wa_message-msgcode = 'B'.
3180         wa_message-msgtext =
3181         'in the  materials  list  appearing  in  the search help?'.
3182
3183           append wa_message to ist_message.
3184
3185         endif.
3186
3187         clear wa_message.
3188       endloop.
3189   *   Perform spell_check1.
3190   *   if g_spellerror = 'X'.
3191   *
3192   *      wa_message-msgtype = 'W'.
3193   *      wa_message-srno    = '000'.
3194   *      wa_message-msgcode = 'S'.
3195   *      wa_message-msgtext = 'Spelling  Errors'.
3196   *      append wa_message to ist_message.
3197   *   Endif.
3198
3199       describe table g_TABLCTRL130_itab lines check_lines.
3200
3201       if check_lines > 0.
3202
3203         Call Screen 102 starting at 10 05 ending at 100 15.
3204
3205       else.
3206
3207         message i028(zmm_oth).
3208
3209       endif.
3210
3211       clear : g_TABLCTRL130_wa-dsflag,  g_long_text_warning .
3212
3213     endif.
3214
3215
3216   ENDMODULE.                 " TABLCTRL130_check  OUTPUT
3217   *&---------------------------------------------------------------------*
3218   *&      Module  change_restrict  OUTPUT
3219   *&---------------------------------------------------------------------*
3220   *       text
3221   *----------------------------------------------------------------------*
3222   *MODULE change_restrict OUTPUT.
3223   Form Change_restrict.
3224
3225   *
3226   *
3227     If ( g_mode = 'CHA' or g_mode ='REL' ) and zmm_cdhd_st-REQCPF <> ''
3228   .
3229      If sy-uname <> zmm_cdhd_st-REQCPF.
3230           If  g_user = ''.
3231               message i020(zmm_oth).
3232               Perform Clear_var.
3233               leave to screen 100.
3234           Elseif g_user = 'M'.
3235   *            AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
3236   *                       ID 'WERKS' Field zmm_cdhd_st-werks
3237   *                       ID 'ACTVT'  dummy. "FIELD '01'.
3238   *            If sy-subrc <> 0.
3239   *                g_change_auth = 'X'.
3240   *            leave to screen 100.
3241   *            Endif.
3242
3243           Endif.
3244      Endif.
3245     Endif.
3246   Endform.
3247   *ENDMODULE.                 " change_restrict  OUTPUT
*--- End of MZMMCODREQ_ERROR_RESETO01 - 3247 lines ---

----------------------------------------------------------------------------------------------------
Include          MZMMCODREQ_ERROR_RESETI01                 Level 1    Page 4
Object           SAPMZMMCODREQ_ERROR_RESET                 Lines 2044
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:05
----------------------------------------------------------------------------------------------------
1      ************************************************************************
2      *  Date            Transport      USERID        Description
3      * 30/09/2008      <RD1K960036>    SAB_SUMODH
4      *
5      *1) Obsolete FM POPUP_TO_CONFIRM_STEP Replaced With 'POPUP_TO_CONFIRM'.
6      *
7      *
8      ************************************************************************
9      ***INCLUDE MZMMCODREQI01 .
10     *&spwizard: input modul for tc 'TABCTRL100'. do not change this line!
11     *&spwizard: mark table
12     module TABCTRL100_mark input.
13       data: g_TABCTRL100_wa2 like line of IST_SRCHLP.
14       if TABCTRL100-line_sel_mode = 1.
15         loop at IST_SRCHLP into g_TABCTRL100_wa2
16           where MARK = 'X'.
17           g_TABCTRL100_wa2-MARK = ''.
18           modify IST_SRCHLP
19             from g_TABCTRL100_wa2
20             transporting MARK.
21         endloop.
22       endif.
23       modify IST_SRCHLP
24         from WA_SRCHLP
25         index TABCTRL100-current_line
26         transporting MARK.
27     endmodule.
28
29     *&spwizard: input module for tc 'TABCTRL100'. do not change this line!
30     *&spwizard: process user command
31     module TABCTRL100_user_command input.
32       OKCODE_100 = sy-ucomm.
33       GET CURSOR FIELD g_CURFIELD.
34       if g_curfield = 'ZMM_CDHD_ST-MTART' .
35         Case ZMM_CDHD_ST-MTART.
36           when 'ZCAP'.
37             dynnr = '0130'.
38           when 'ZSPR'.
39             dynnr = '0120'.
40           when 'ZSTO'.
41             dynnr = '0110'.
42           when 'ZDIS'.
43             dynnr = '0140'.
44           when others.
45             dynnr = '0101'.
46         endcase.
47       Endif.
48       perform user_ok_tc using    'TABCTRL100'
49                                   'IST_SRCHLP'
50                                   'MARK'
51                          changing OKCODE_100.
52       sy-ucomm = OKCODE_100.
53     ****Calling transaction MK03 for vendor.
54       read table ist_srchlp into wa_srchlpmk03 index g_curr_line_100.
55       g_mfrnr  = WA_SRCHLPmk03-mfrnr.
56       if g_curfield = 'WA_SRCHLP-MFRNR'. "and g_cursor_line = sy-stepl.
57     *    g_mfrnr     =  WA_SRCHLP-MFRNR.
58         if not g_mfrnr is initial.
59           "Begin of ATC Correction 29.04.2026
60     *      set parameter id 'LIF' field g_mfrnr.
61     *      call transaction 'MK03' and skip first screen.
62           DATA(l_vend) = CONV Lifnr( g_mfrnr ).
63           SELECT PARTNER FROM V_CVI_VEND_LINK
64      INTO @DATA(LV_PARTNER) UP TO 1 ROWS WHERE LIFNR = @L_VEND
65      ORDER BY PRIMARY KEY .
66      ENDSELECT.
67
68           DATA(request) = NEW cl_bupa_navigation_request( ).
69           request->set_partner_number( lv_partner ).     " import your BP number here
70           CALL METHOD request->set_bupa_activity
71           EXPORTING
72           iv_value = request->gc_activity_display.
73           DATA(options) = NEW cl_bupa_dialog_joel_options( ).
74           options->set_navigation_disabled( abap_true ).
75           cl_bupa_dialog_joel=>start_with_navigation( iv_request = request
76           iv_options = options ).
77           "End of ATC Correction 29.04.2026
78         endif.
79       endif.
80     *****End.
81
82     endmodule.
83     *&spwizard: input module for tc 'TABCTRL110'. do not change this line!
84     *&spwizard: modify table
85     *--------------------------------------------------------------------
86     module TABCTRL110_modify input.
87     *---------------------------------------------------------------------
88     *Data : g_field like g_curfield.
89       data : g_oth_level.
90       g_ok_code110 = sy-ucomm.
91       clear g_field.
92
93       if zmm_cditem-oth1 = 'X' or
94          zmm_cditem-oth2 = 'X' or
95          zmm_cditem-oth3 = 'X' or
96          zmm_cditem-oth4 = 'X'.
97       Else.
98         replace 'M' with '' into zmm_cditem-comp_flg.
99       Endif.
100
101      move-corresponding ZMM_CDITEM to g_TABCTRL110_wa.
102
103    *  modify g_TABCTRL110_itab
104    *    from g_TABCTRL110_wa
105    *    index TABCTRL110-current_line.
106    *
107    ***** Addition
108    *  if sy-subrc <> 0.
109    *    append g_TABCTRL110_wa to g_TABCTRL110_itab.
110    *  endif.
111    *****
112
113    *++++++++260405
114      concatenate g_tabctrl110_wa-oth1 g_tabctrl110_wa-oth2
115                  g_tabctrl110_wa-oth3 g_tabctrl110_wa-oth4 into g_oth.
116
117      if g_ok_code110 = 'PB_AD'.
118    *   and g_oth = ''.
119        if g_cursor_line = sy-stepl.
120
121          Perform popup_userdesc.
122          If g_ok_code115 = 'OK115'.
123            Perform GC_Fields_115.
124
125          Endif.
126        Endif.
127      Endif.
128
129      Case 'X'.
130        When g_TABCTRL110_wa-oth1.
131    *       g_oth_level = '1'.
132          concatenate 'ZMM_CDITEM-DESC' '1' into g_field.
133        When g_TABCTRL110_wa-oth2.
134          concatenate 'ZMM_CDITEM-DESC' '2' into g_field.
135    *       g_oth_level = '2'.
136        When g_TABCTRL110_wa-oth3.
137          concatenate 'ZMM_CDITEM-DESC' '3' into g_field.
138    *       g_oth_level = '3'.
139        When g_TABCTRL110_wa-oth4.
140          concatenate 'ZMM_CDITEM-DESC' '4' into g_field.
141    *       g_oth_level = '4'.
142        when others.
143    *       g_oth_level = ''.
144
145      Endcase.
146
147    *++240405
148      if g_mode = 'CHA' and ( sy-ucomm = 'DBLCLK' or sy-ucomm = '' )
149         and  g_field = g_curfield and g_cursor_line = sy-stepl.
150    *   and
151    *        TABCTRL110_wa-oth1 = 'X' or
152    *        g_TABCTRL110_wa-oth2 = 'X'  or
153    *        g_TABCTRL110_wa-oth3 = 'X'  or
154    *        g_TABCTRL110_wa-oth4 = 'X' )
155    *
156        g_desc1 = g_tabctrl110_wa-desc1.
157        g_desc2 = g_tabctrl110_wa-desc2.
158        g_desc3 = g_tabctrl110_wa-desc3.
159        g_desc4 = g_tabctrl110_wa-desc4.
160        g_matgp = g_tabctrl110_wa-matgp.
161    *
162        select single WGBEZ from T023T into g_matgp_desc where MATKL =
163        g_matgp and spras = sy-langu.
164        if sy-subrc <> 0.
165          g_matgp = ''.
166        Endif.
167        G_USER_DESC = g_tabctrl110_wa-user_desc.
168        Perform popup_userdesc.
169        clear g_field.
170        If g_ok_code115 = 'OK115'.
171          Perform GC_Fields_115.
172    *          g_tabctrl110_wa-oth1 = ''.
173        Endif.
174
175      Endif.
176    *----240405
177
178      if g_curfield = 'ZMM_CDITEM-MATCODE' and g_cursor_line = sy-stepl.
179        g_matcode = ZMM_CDITEM-MATCODE.
180        if not g_matcode is initial.
181          set parameter id 'MAT' field g_matcode.
182          call transaction 'MM03' and skip first screen.
183        endif.
184      endif.
185
186    *  PERFORM attrib_parno.
187
188      if g_curfield = 'ZMM_CDITEM-DESC1' and g_cursor_line = sy-stepl.
189
190    *  if desc11 <> g_TABCTRL110_wa-desc1.
191    *
192    *      clear  : g_TABCTRL110_wa-desc2,
193    *               g_TABCTRL110_wa-desc3,
194    *               g_TABCTRL110_wa-desc4,
195    *               g_TABCTRL110_wa-oth2,
196    *               g_TABCTRL110_wa-oth3,
197    *               g_TABCTRL110_wa-oth4,
198    *               g_TABCTRL110_wa-user_desc.
199    *  endif.
200
201        if TABCTRL110_check_flag = 'X'.
202          g_hits_par = '1'.
203        endif.
204
205        desc11 = g_TABCTRL110_wa-desc1.
206        FIELD1 = 'ZMM_CDITEM-DESC1'.
207        if ( g_mode = 'CRE' or g_mode = 'CHA' )
208            and TABCTRL110_check_flag = 'X'.
209          g_hits_par = '1'.
210    *      and g_TABCTRL110_wa-oth1 = 'X'.
211          If g_ok_code115 <> 'OK115'.
212    *         clear : g_TABCTRL110_wa-desc2,
213    *                g_TABCTRL110_wa-desc3,
214    *                g_TABCTRL110_wa-desc4,
215    *                g_TABCTRL110_wa-oth2,
216    *                g_TABCTRL110_wa-oth3,
217    *                g_TABCTRL110_wa-oth4,
218    *                g_TABCTRL110_wa-user_desc,
219            clear  TABCTRL110_check_flag.
220          Endif.
221        Endif.
222        if not g_TABCTRL110_wa-matgp is initial.
223          g_matgp = g_TABCTRL110_wa-matgp.
224        else.
225          get parameter id 'ZMATGP' field g_matgp .
226          g_TABCTRL110_wa-matgp = g_matgp .
227        endif.
228        if g_TABCTRL110_wa-desc1 <> 'OTHER'.
229          perform TABCTRL110_desc1_check.
230          if TABCTRL110_check_flag = 'X'.
231            g_hits_par = '1'.
232          endif.
233    *        if not ZMM_CDITEM-OTH1 is initial.
234    *           Perform popup_userdesc1.
235    *        endif.
236        endif.
237        if g_TABCTRL110_wa-desc1 = 'OTHER'.
238          g_TABCTRL110_wa-OTH1 = 'X'.
239    *       g_hits_par = '0'.
240          g_hits_par = '4'.
241          g_hits_par_oth = 'X'.
242    *        g_TABCTRL110_wa-OTH2 = ''.
243    *        g_TABCTRL110_wa-OTH3 = ''.
244    *        g_TABCTRL110_wa-OTH4 = ''.
245    *        g_TABCTRL110_wa-USER_DESC = ''.
246
247    *        clear: g_TABCTRL110_wa-desc1,   "
248    *               g_TABCTRL110_wa-desc2,   "
249    *               g_TABCTRL110_wa-desc3,   "
250    *               g_TABCTRL110_wa-desc4.   "
251          Perform popup_userdesc.
252          If g_ok_code115 = 'OK115'.
253            Perform GC_Fields_115.
254          endif.
255          Perform move_descriptions.
256        elseif g_TABCTRL110_wa-OTH1 = 'X'.
257          g_hits_par = '4'.
258          g_hits_par_oth = 'X'..
259          descp1 = g_TABCTRL110_wa-desc1.
260        else.
261          clear g_TABCTRL110_wa-OTH1.
262          descp1 = g_TABCTRL110_wa-desc1.
263        endif.
264        check_pos = '1'.
265      endif.
266
267      if g_curfield = 'ZMM_CDITEM-DESC2' and g_cursor_line = sy-stepl..
268        g_matgp = g_TABCTRL110_wa-matgp.
269        g_TABCTRL110_wa-desc1 = zmm_cditem-desc1.
270        descp1 = g_TABCTRL110_wa-desc1.
271        if ( g_mode = 'CRE' or g_mode = 'CHA' )
272           and TABCTRL110_check_flag = 'X'.
273          g_hits_par = '2'.
274    *    and g_TABCTRL110_wa-oth2 = 'X'.
275          clear : g_TABCTRL110_wa-desc3,
276                  g_TABCTRL110_wa-desc4,
277                  g_TABCTRL110_wa-oth3,
278                  g_TABCTRL110_wa-oth4,
279                  g_TABCTRL110_wa-user_desc,
280                  TABCTRL110_check_flag.
281        endif.
282        set parameter id 'ZDESC_1' field g_TABCTRL110_wa-desc1.
283    *    descp2 = g_TABCTRL110_wa-desc2.
284        if g_TABCTRL110_wa-desc2 <> 'OTHER'.
285          perform TABCTRL110_desc2_check.
286          if TABCTRL110_check_flag = 'X'.
287            g_hits_par = '2'.
288          endif.
289    *        if not ZMM_CDITEM-OTH2 is initial.
290    *           Perform popup_userdesc2.
291    *        endif.
292        endif.
293        if g_TABCTRL110_wa-desc2 = 'OTHER'.
294          g_TABCTRL110_wa-OTH2 = 'X'.
295          g_hits_par_oth = 'X'.
296          g_hits_par = '4'.
297    *       g_TABCTRL110_wa-OTH3 = ''.
298    *       g_TABCTRL110_wa-OTH4 = ''.
299    *       g_TABCTRL110_wa-USER_DESC = ''.
300
301    *               g_TABCTRL110_wa-desc2,   "
302    *               g_TABCTRL110_wa-desc3,   "
303    *               g_TABCTRL110_wa-desc4.   "
304          Perform popup_userdesc.
305          If g_ok_code115 = 'OK115'.
306            Perform GC_Fields_115.
307          endif.
308          Perform move_descriptions.
309        elseif g_TABCTRL110_wa-OTH2 = 'X'.
310          clear g_hits_par.
311          descp2 = g_TABCTRL110_wa-desc2.
312        else.
313          clear g_TABCTRL110_wa-OTH2.
314          descp2 = g_TABCTRL110_wa-desc2.
315        endif.
316    *    set parameter id 'ZDESC_2' field desc22.
317        FIELD1 = 'ZMM_CDITEM-DESC2'.
318        check_pos = '2'.
319      endif.
320
321      if g_curfield = 'ZMM_CDITEM-DESC3' and g_cursor_line = sy-stepl.
322        g_matgp = g_TABCTRL110_wa-matgp.
323        descp1 = g_TABCTRL110_wa-desc1.
324        descp2 = g_TABCTRL110_wa-desc2.
325        if ( g_mode = 'CRE' or g_mode = 'CHA' )
326           and TABCTRL110_check_flag = 'X'.
327          g_hits_par = '3'.
328    *    and g_TABCTRL110_wa-oth3 = 'X'.
329          clear : g_TABCTRL110_wa-desc4,
330                  g_TABCTRL110_wa-oth4,
331                  g_TABCTRL110_wa-user_desc,
332                  TABCTRL110_check_flag.
333        endif.
334    *    descp3 = g_TABCTRL110_wa-desc3.
335        if g_TABCTRL110_wa-desc3 <> 'OTHER'.
336          perform TABCTRL110_desc3_check.
337          if TABCTRL110_check_flag = 'X'.
338            g_hits_par = '3'.
339          endif.
340    *        if not ZMM_CDITEM-OTH3 is initial.
341    *           Perform popup_userdesc3.
342    *        endif.
343        endif.
344        if g_TABCTRL110_wa-desc3 = 'OTHER'.
345          g_TABCTRL110_wa-OTH3 = 'X'.
346          g_hits_par_oth = 'X'.
347          g_hits_par = '4'.
348    *       g_TABCTRL110_wa-OTH4 = ''.
349    *       g_TABCTRL110_wa-USER_DESC = ''.
350
351    *               g_TABCTRL110_wa-desc3,   "
352    *               g_TABCTRL110_wa-desc4.   "
353          Perform popup_userdesc.
354          If g_ok_code115 = 'OK115'.
355            Perform GC_Fields_115.
356          endif.
357          Perform move_descriptions.
358        elseif g_TABCTRL110_wa-OTH3 = 'X'.
359          clear g_hits_par.
360          descp3 = g_TABCTRL110_wa-desc3.
361        else.
362          clear g_TABCTRL110_wa-OTH3.
363          descp3 = g_TABCTRL110_wa-desc3.
364        endif.
365    *    set parameter id 'ZDESC_3' field desc33.
366
367        FIELD1 = 'ZMM_CDITEM-DESC3'.
368        check_pos = '3'.
369      endif.
370
371      if g_curfield = 'ZMM_CDITEM-DESC4' and g_cursor_line = sy-stepl.
372        g_matgp = g_TABCTRL110_wa-matgp.
373        descp1 = g_TABCTRL110_wa-desc1.
374        descp2 = g_TABCTRL110_wa-desc2.
375        descp3 = g_TABCTRL110_wa-desc3.
376    *    descp4 = g_TABCTRL110_wa-desc4.
377        if g_TABCTRL110_wa-desc4 <> 'OTHER'.
378          perform TABCTRL110_desc4_check.
379          if TABCTRL110_check_flag = 'X'.
380            g_hits_par = '4'.
381          endif.
382    *        if not ZMM_CDITEM-OTH4 is initial.
383    *           Perform popup_userdesc4.
384    *        endif.
385        endif.
386        if g_TABCTRL110_wa-desc4 = 'OTHER'.
387          g_TABCTRL110_wa-OTH4 = 'X'.
388          g_hits_par_oth = 'X'.
389          g_hits_par = '4'.
390    *       g_TABCTRL110_wa-USER_DESC = ''.
391    *               g_TABCTRL110_wa-desc4.   "
392
393          Perform popup_userdesc.
394          If g_ok_code115 = 'OK115'.
395            Perform GC_Fields_115.
396          endif.
397          Perform move_descriptions.
398
399          g_TABCTRL110_wa-user_desc = g_user_desc.
400        elseif g_TABCTRL110_wa-OTH4 = 'X'.
401          clear g_hits_par.
402          descp4 = g_TABCTRL110_wa-desc4.
403        else.
404          clear g_TABCTRL110_wa-OTH4.
405          descp4 = g_TABCTRL110_wa-desc4.
406        endif.
407    *    set parameter id 'ZDESC_3' field desc33.
408
409        FIELD1 = 'ZMM_CDITEM-DESC4'.
410        check_pos = '4'.
411      endif.
412
413      if g_curfield = 'ZMM_CDITEM-USER_DESC' and g_cursor_line = sy-stepl.
414        descp5 = g_TABCTRL110_wa-user_desc.
415        FIELD1 = 'ZMM_CDITEM-USER_DESC'.
416        check_pos = '5'.
417      endif.
418
419      if g_TABCTRL110_wa-comp_flg is initial and
420         not g_TABCTRL110_wa-rsn is initial.
421        move space to g_TABCTRL110_wa-rsn.
422      elseif not g_TABCTRL110_wa-comp_flg is initial.
423        clear wa_rsn.
424        select single * from ZMM_CODREQ_RSN into wa_rsn
425       where reason = g_TABCTRL110_wa-comp_flg.
426        g_TABCTRL110_wa-rsn = wa_rsn-description.
427        clear wa_rsn.
428      endif.
429    *****Addition************************************
430    *
431      if sy-tcode = 'ZCODG' AND g_cursor_line = sy-stepl.
432        if g_curfield = 'ZMM_CDITEM-DESC1' and zmm_cditem-oth1 = 'X'.
433          Perform popup_userdesc.
434        elseif g_curfield = 'ZMM_CDITEM-DESC2' and zmm_cditem-oth2 = 'X'.
435          Perform popup_userdesc.
436        elseif g_curfield = 'ZMM_CDITEM-DESC3' and zmm_cditem-oth3 = 'X'.
437          Perform popup_userdesc.
438        elseif g_curfield = 'ZMM_CDITEM-DESC4' and zmm_cditem-oth4 = 'X'.
439          Perform popup_userdesc.
440        endif.
441    *     ( zmm_cditem-oth1 = 'X'  OR  zmm_cditem-oth2 = 'X'    OR
442    *       zmm_cditem-oth3 = 'X'  OR  zmm_cditem-oth4 = 'X' ).
443    *    Perform popup_userdesc.
444        clear g_field.
445        If g_ok_code115 = 'OK115'.
446          Perform GC_Fields_115.
447        Endif.
448      endif.
449    *****End*****************************************
450      modify g_TABCTRL110_itab
451        from g_TABCTRL110_wa
452        index TABCTRL110-current_line.
453
454    **** Addition
455      if sy-subrc <> 0.
456        append g_TABCTRL110_wa to g_TABCTRL110_itab.
457      endif.
458    ****
459    *
460
461      if sy-tcode = 'ZCODG' AND g_cursor_line = sy-stepl
462             and ( sy-ucomm = 'DBLCLK' or sy-ucomm = '' ).
463        Perform get_srno.
464      Endif.
465    endmodule.
466
467    *&spwizard: input module for tc 'TABCTRL110'. do not change this line!
468    *&spwizard: mark table
469    module TABCTRL110_mark input.
470      if TABCTRL110-line_sel_mode = 1 and
471         g_TABCTRL110_wa-flag = 'X'.
472        loop at g_TABCTRL110_itab into g_TABCTRL110_wa
473          where flag = 'X'.
474          g_TABCTRL110_wa-flag = ''.
475          modify g_TABCTRL110_itab
476            from g_TABCTRL110_wa
477            transporting flag.
478        endloop.
479        g_TABCTRL110_wa-flag = 'X'.
480      endif.
481      modify g_TABCTRL110_itab
482        from g_TABCTRL110_wa
483        index TABCTRL110-current_line
484        transporting flag.
485    endmodule.
486
487    *&spwizard: input module for tc 'TABCTRL110'. do not change this line!
488    *&spwizard: process user command
489    module TABCTRL110_user_command input.
490
491      if check_pos = '1'.
492
493        set parameter id 'ZDESC_1' field descp1.
494        set parameter id 'ZDESC_2' field ''.
495        set parameter id 'ZDESC_3' field ''.
496        set parameter id 'ZDESC_4' field ''.
497
498        desc11 = descp1.
499        desc22 = ''.
500        desc33 = ''.
501        desc44 = ''.
502        desc55 = ''.
503
504      endif.
505
506      if check_pos = '2'.
507
508        set parameter id 'ZDESC_1' field descp1.
509        set parameter id 'ZDESC_2' field descp2.
510        set parameter id 'ZDESC_3' field ''.
511        set parameter id 'ZDESC_4' field ''.
512
513        desc11 = descp1.
514        desc22 = descp2.
515        desc33 = ''.
516        desc44 = ''.
517        desc55 = ''.
518
519      endif.
520
521      if check_pos = '3'.
522
523        set parameter id 'ZDESC_1' field descp1.
524        set parameter id 'ZDESC_2' field descp2.
525        set parameter id 'ZDESC_3' field descp3.
526        set parameter id 'ZDESC_4' field ''.
527
528        desc11 = descp1.
529        desc22 = descp2.
530        desc33 = descp3.
531        desc44 = ''.
532        desc55 = ''.
533
534      endif.
535
536      if check_pos = '4'.
537
538        set parameter id 'ZDESC_1' field descp1.
539        set parameter id 'ZDESC_2' field descp2.
540        set parameter id 'ZDESC_3' field descp3.
541        set parameter id 'ZDESC_4' field descp4.
542
543        desc11 = descp1.
544        desc22 = descp2.
545        desc33 = descp3.
546        desc44 = descp4.
547        desc55 = ''.
548
549      endif.
550
551      if check_pos = '5'.
552
553        case g_parno.
554          when '2'.
555            clear descp3.
556            clear descp4.
557          when '3'.
558            clear descp4.
559        endcase.
560
561        desc11 = descp1.
562        desc22 = descp2.
563        desc33 = descp3.
564        desc44 = descp4.
565        desc55 = descp5.
566
567      endif.
568
569      if g_hits_par_oth = 'X'.
570
571        set parameter id 'ZDESC_1' field descp1.
572        set parameter id 'ZDESC_2' field descp2.
573        set parameter id 'ZDESC_3' field descp3.
574        set parameter id 'ZDESC_4' field descp4.
575
576        desc11 = descp1.
577        desc22 = descp2.
578        desc33 = descp3.
579        desc44 = descp4.
580        desc55 = ''.
581
582    *   clear g_hits_par_oth.
583
584      endif.
585
586      g_lineno = g_curr_line.
587      g_matgpo = g_matgp.
588
589      get cursor field g_curfield.
590    *  OK_CODE = sy-ucomm.
591    *  perform user_ok_tc using    'TABCTRL110'
592    *                              'G_TABCTRL110_ITAB'
593    *                              'FLAG'
594    *                     changing OK_CODE.
595    *  sy-ucomm = OK_CODE.
596    endmodule.
597
598    *&spwizard: input module for tc 'TABLCTRL130'. do not change this line!
599    *&spwizard: modify table
600    module TABLCTRL130_modify input.
601      ZMM_CDITEM-UOM = 'NO'.
602    *
603      if g_curfield = 'ZMM_CDITEM-MATCODE' and g_cursor_line = sy-stepl.
604        g_matcode = ZMM_CDITEM-MATCODE.
605        if not g_matcode is initial.
606          set parameter id 'MAT' field g_matcode.
607          call transaction 'MM03' and skip first screen.
608        endif.
609      endif.
610
611    *
612      move-corresponding ZMM_CDITEM to g_TABLCTRL130_wa.
613      modify g_TABLCTRL130_itab
614        from g_TABLCTRL130_wa
615        index TABLCTRL130-current_line.
616      if sy-subrc <> 0.
617        append g_TABLCTRL130_wa to g_TABLCTRL130_itab.
618      endif.
619      If sy-tcode = 'ZCODG' AND g_cursor_line = sy-stepl
620             and ( sy-ucomm = 'DBLCLK' or sy-ucomm = '' ).
621        Perform get_srno.
622      Endif.
623
624    endmodule.
625
626    *&spwizard: input module for tc 'TABLCTRL130'. do not change this line!
627    *&spwizard: mark table
628    module TABLCTRL130_mark input.
629      if TABLCTRL130-line_sel_mode = 1 and
630         g_TABLCTRL130_wa-flag = 'X'.
631        loop at g_TABLCTRL130_itab into g_TABLCTRL130_wa
632          where flag = 'X'.
633          g_TABLCTRL130_wa-flag = ''.
634          modify g_TABLCTRL130_itab
635            from g_TABLCTRL130_wa
636            transporting flag.
637        endloop.
638        g_TABLCTRL130_wa-flag = 'X'.
639      endif.
640      modify g_TABLCTRL130_itab
641        from g_TABLCTRL130_wa
642        index TABLCTRL130-current_line
643        transporting flag.
644    endmodule.
645
646    *&spwizard: input module for tc 'TABLCTRL130'. do not change this line!
647    *&spwizard: process user command
648    module TABLCTRL130_user_command input.
649
650      if check_pos = '1'.
651
652        desc11 = descp1.
653        desc22 = ''.
654        desc33 = ''.
655        desc44 = ''.
656        desc55 = ''.
657
658      endif.
659
660      if check_pos = '5'.
661
662        desc11 = descp1.
663        desc22 = ''.
664        desc33 = ''.
665        desc44 = ''.
666        desc55 = descp5.
667      endif.
668
669    *  OK_CODE = sy-ucomm.
670    *  perform user_ok_tc using    'TABLCTRL130'
671    *                              'G_TABLCTRL130_ITAB'
672    *                              'FLAG'
673    *                     changing OK_CODE.
674    *  sy-ucomm = OK_CODE.
675
676    endmodule.
677
678    *&spwizard: input module for tc 'TABLCTRL140'. do not change this line!
679    *&spwizard: modify table
680    module TABLCTRL140_modify input.
681      move-corresponding ZMM_CDITEM to g_TABLCTRL140_wa.
682    *  modify g_TABLCTRL140_itab
683    *    from g_TABLCTRL140_wa
684    *    index TABLCTRL140-current_line.
685    ************Addition********
686    *  if sy-subrc <> 0.
687    *    append g_TABLCTRL140_wa to g_TABLCTRL140_itab.
688    *  endif.
689    ****************************
690      if g_curfield = 'ZMM_CDITEM-DESC1' and sy-STEPL = g_curr_line.
691        descp1 = g_TABLCTRL140_wa-desc1.
692        FIELD1 = 'ZMM_CDITEM-DESC1'.
693        if g_TABLCTRL140_wa-desc1 <> 'OTHER'.
694          perform TABLCTRL140_desc1_check.
695        endif.
696        if g_TABLCTRL140_wa-desc1 = 'OTHER'.
697          g_TABLCTRL140_wa-OTH1 = 'X'.
698          Perform popup_userdesc.
699          g_TABLCTRL140_wa-user_desc = g_user_desc.
700        elseif g_TABLCTRL140_wa-OTH1 = 'X'.
701          descp1 = g_TABLCTRL140_wa-desc1.
702        else.
703          clear g_TABLCTRL140_wa-OTH1.
704          descp1 = g_TABLCTRL140_wa-desc1.
705        endif.
706        check_pos = '1'.
707      endif.
708
709      if g_curfield = 'ZMM_CDITEM-USER_DESC' and sy-STEPL = g_curr_line.
710        descp5 = g_TABLCTRL140_wa-user_desc.
711        FIELD1 = 'ZMM_CDITEM-USER_DESC'.
712        check_pos = '5'.
713      endif.
714
715      modify g_TABLCTRL140_itab
716        from g_TABLCTRL140_wa
717        index TABLCTRL140-current_line.
718    ***********Addition********
719      if sy-subrc <> 0.
720        append g_TABLCTRL140_wa to g_TABLCTRL140_itab.
721      endif.
722    ***************************
723      If sy-tcode = 'ZCODG' AND g_cursor_line = sy-stepl
724        and ( sy-ucomm = 'DBLCLK' or sy-ucomm = '' ).
725        Perform get_srno.
726      Endif.
727
728    endmodule.
729
730    *&spwizard: input module for tc 'TABLCTRL140'. do not change this line!
731    *&spwizard: mark table
732    module TABLCTRL140_mark input.
733      if TABLCTRL140-line_sel_mode = 1 and
734         g_TABLCTRL140_wa-flag = 'X'.
735        loop at g_TABLCTRL140_itab into g_TABLCTRL140_wa
736          where flag = 'X'.
737          g_TABLCTRL140_wa-flag = ''.
738          modify g_TABLCTRL140_itab
739            from g_TABLCTRL140_wa
740            transporting flag.
741        endloop.
742        g_TABLCTRL140_wa-flag = 'X'.
743      endif.
744      modify g_TABLCTRL140_itab
745        from g_TABLCTRL140_wa
746        index TABLCTRL140-current_line
747        transporting flag.
748    endmodule.
749
750    *&spwizard: input module for tc 'TABLCTRL140'. do not change this line!
751    *&spwizard: process user command
752    module TABLCTRL140_user_command input.
753      if check_pos = '1'.
754
755        desc11 = descp1.
756        desc22 = ''.
757        desc33 = ''.
758        desc44 = ''.
759        desc55 = ''.
760
761      endif.
762
763      if check_pos = '5'.
764
765        desc11 = descp1.
766        desc22 = ''.
767        desc33 = ''.
768        desc44 = ''.
769        desc55 = descp5.
770      endif.
771
772      g_lineno = g_curr_line.
773
774    *  OK_CODE = sy-ucomm.
775    *  perform user_ok_tc using    'TABLCTRL140'
776    *                              'G_TABLCTRL140_ITAB'
777    *                              'FLAG'
778    *                     changing OK_CODE.
779    *  sy-ucomm = OK_CODE.
780    endmodule.
781
782    *&spwizard: input module for tc 'TABLCTRL120'. do not change this line!
783    *&spwizard: modify table
784    module TABLCTRL120_modify input.
785      g_sh_partno = 'X'.
786      move-corresponding ZMM_CDITEM to g_TABLCTRL120_wa.
787
788    *
789
790      SELECT ATINN FROM CABN INTO G_ATINN UP TO 1 ROWS WHERE
791     ATNAM = 'Z_ONGC_GROUP_OF_SPARES'
792     ORDER BY PRIMARY KEY .
793     ENDSELECT.
794
795      SELECT ATWRT FROM AUSP INTO G_ATWRT UP TO 1 ROWS WHERE
796     OBJEK = G_TABLCTRL120_WA-CAP_CODE AND ATINN = G_ATINN
797     ORDER BY PRIMARY KEY .  "#EC CI_FLDEXT_OK[2215424]
798     ENDSELECT.
799
800      g_TABLCTRL120_wa-matgp = g_atwrt.
801
802      clear g_atinn.
803
804    *
805      if g_curfield = 'ZMM_CDITEM-MATCODE' and g_cursor_line = sy-stepl.
806        g_matcode = ZMM_CDITEM-MATCODE.
807        if not g_matcode is initial.
808          set parameter id 'MAT' field g_matcode.
809          call transaction 'MM03' and skip first screen.
810        endif.
811      endif.
812
813    *
814
815      if g_curfield = 'ZMM_CDITEM-PARTNO' and sy-STEPL = g_curr_line.
816        if g_partnoc <> g_TABLCTRL120_wa-partno.
817          clear : g_TABLCTRL120_wa-desc1,
818                  g_TABLCTRL120_wa-oth1,
819                  g_TABLCTRL120_wa-user_desc.
820    *               g_TABLCTRL120_wa-desc3,
821    *               g_TABLCTRL120_wa-desc4,
822    *               g_TABLCTRL120_wa-oth2,
823    *               g_TABLCTRL120_wa-oth3,
824    *               g_TABLCTRL120_wa-oth4.
825        endif.
826        g_partnoc = g_TABLCTRL120_wa-partno.
827        FIELD1 = 'ZMM_CDITEM-PARTNO'.
828        if ( g_mode = 'CRE' or g_mode = 'CHA' ) .
829    *    and g_TABCTRL110_wa-oth1 = 'X'.
830          clear : g_TABCTRL110_wa-desc1,
831                  descp1.
832        endif.
833        check_pos = '0'.
834      endif.
835
836      if g_curfield = 'ZMM_CDITEM-DESC1' and sy-STEPL = g_curr_line.
837        descp1 = g_TABLCTRL120_wa-desc1.
838        FIELD1 = 'ZMM_CDITEM-DESC1'.
839
840        if g_TABLCTRL120_wa-desc1 <> 'OTHER'.
841          perform TABLCTRL120_desc1_check.
842        endif.
843        if g_TABLCTRL120_wa-desc1 = 'OTHER'.
844          g_TABLCTRL120_wa-OTH1 = 'X'.
845          Perform popup_userdesc.
846          g_TABLCTRL120_wa-user_desc = g_user_desc.
847        elseif g_TABLCTRL120_wa-OTH1 = 'X'.
848          g_partnoc = g_TABLCTRL120_wa-partno.
849        else.
850          clear g_TABLCTRL120_wa-OTH1.
851          g_partnoc = g_TABLCTRL120_wa-partno.
852        endif.
853        check_pos = '1'.
854      endif.
855
856      if g_curfield = 'ZMM_CDITEM-USER_DESC' and sy-STEPL = g_curr_line.
857        descp5 = g_TABLCTRL120_wa-user_desc.
858        FIELD1 = 'ZMM_CDITEM-USER_DESC'.
859        check_pos = '5'.
860      endif.
861
862      modify g_TABLCTRL120_itab
863        from g_TABLCTRL120_wa
864        index TABLCTRL120-current_line.
865
866    **** Addition
867      if sy-subrc <> 0.
868        append g_TABLCTRL120_wa to g_TABLCTRL120_itab.
869      endif.
870    ****
871      If sy-tcode = 'ZCODG' AND g_cursor_line = sy-stepl
872          and ( sy-ucomm = 'DBLCLK' or sy-ucomm = '' ).
873        Perform get_srno.
874      Endif.
875
876    endmodule.
877
878    *&spwizard: input module for tc 'TABLCTRL120'. do not change this line!
879    *&spwizard: mark table
880    module TABLCTRL120_mark input.
881      if TABLCTRL120-line_sel_mode = 1 and
882         g_TABLCTRL120_wa-flag = 'X'.
883        loop at g_TABLCTRL120_itab into g_TABLCTRL120_wa
884          where flag = 'X'.
885          g_TABLCTRL120_wa-flag = ''.
886          modify g_TABLCTRL120_itab
887            from g_TABLCTRL120_wa
888            transporting flag.
889        endloop.
890        g_TABLCTRL120_wa-flag = 'X'.
891      endif.
892      modify g_TABLCTRL120_itab
893        from g_TABLCTRL120_wa
894        index TABLCTRL120-current_line
895        transporting flag.
896    endmodule.
897
898    *&spwizard: input module for tc 'TABLCTRL120'. do not change this line!
899    *&spwizard: process user command
900    module TABLCTRL120_user_command input.
901
902      if check_pos = '0'.
903
904        desc11 = ''.
905        desc22 = ''.
906        desc33 = ''.
907        desc44 = ''.
908        desc55 = ''.
909    **Addition************************************************
910        if FIELD1 = 'ZMM_CDITEM-PARTNO' AND
911           sy-ucomm = 'DBLCLK' OR sy-ucomm = ''.
912          g_curs_ln = g_curr_line_120.
913          clear : g_sh_capeqt,g_sh_mdlno,g_sh_mfr,g_fst_srchlp.
914          Refresh: ist_srchlp_cpo.
915        endif.
916    **End of addition*****************************************
917
918      endif.
919
920
921      if check_pos = '1'.
922
923        desc11 = descp1.
924        desc22 = ''.
925        desc33 = ''.
926        desc44 = ''.
927        desc55 = ''.
928
929      endif.
930
931      if check_pos = '5'.
932
933        desc11 = descp1.
934        desc22 = ''.
935        desc33 = ''.
936        desc44 = ''.
937        desc55 = descp5.
938      endif.
939
940      g_lineno = g_curr_line.
941
942    *  OK_CODE = sy-ucomm.
943    *  perform user_ok_tc using    'TABLCTRL120'
944    *                              'G_TABLCTRL120_ITAB'
945    *                              'FLAG'
946    *                     changing OK_CODE.
947    *  sy-ucomm = OK_CODE.
948    endmodule.
949    *&---------------------------------------------------------------------*
950    *&      Module  user_command_100  INPUT
951    *&---------------------------------------------------------------------*
952    *       text
953    *----------------------------------------------------------------------*
954    MODULE user_command_100 INPUT.
955      Case okcode_100.
956    *    When 'EXT'.
957    *      perform clear_var.
958    *      leave program.
959        When 'BAC' OR 'CAN'.
960          perform bac_confirm.
961          refresh ist_srchlp.
962          refresh control 'TABCTRL100' from screen '0100'.
963          clear okcode_100.
964        when 'CR_MATCODE'.
965          g_mode = 'CRC'.
966          if not dynnr is initial.
967            Perform create_matcode.
968          endif.
969          clear okcode_100.
970        When 'CREATE'.
971          g_mode = 'CRE'.
972    *      set parameter id 'ZDESC_2' field ''.
973          clear okcode_100.
974        When 'CHANGE'.
975          g_mode = 'CHA'.
976          clear okcode_100.
977        When 'CHANGE_E'.
978          g_mode = 'CHE'.
979          Perform Save_request.
980        When 'DISPLAY'.
981          g_mode = 'DIS'.
982          clear okcode_100.
983        When 'DELETE'.
984          g_mode = 'DEL'.
985          clear okcode_100.
986        when 'SAV'.
987          If not zmm_cdhd_st-mtart is initial.
988            perform check_items.
989            if g_saveflag = 'Y' AND g_check_flag = ''.
990              Perform Save_request.
991            else.
992              clear g_check_flag.
993            endif.
994          Endif.
995          clear okcode_100.
996        when 'RELEASE'.
997          g_mode = 'REL'.
998          clear okcode_100.
999        when 'APPROVE'.
1000         g_mode = 'APR'.
1001         clear okcode_100.
1002       when 'DD'.
1003         Perform Display_text.
1004         clear okcode_100.
1005       when 'REMLT'.
1006         Call Screen 105 starting at 85 05 ending at 148 24.
1007         clear okcode_100.
1008       WHEN 'INS_MODI'.
1009         perform insert_modif.
1010         clear okcode_100.
1011       WHEN 'SPELL'.
1012   *
1013         if ZMM_CDHD_ST-MTART = 'ZSTO'.
1014           perform spell_check1.
1015           Perform modi_check.
1016           clear okcode_100.
1017         Elseif ZMM_CDHD_ST-MTART = 'ZSPR'.
1018           perform spell_check2.
1019           clear okcode_100.
1020         Elseif ZMM_CDHD_ST-MTART = 'ZCAP'.
1021           perform spell_check3.
1022           clear okcode_100.
1023         Endif.
1024       WHEN 'INS_MDL'.
1025         perform insert_mdlno. "ZSPR
1026         clear okcode_100.
1027       WHEN 'REQLT'.
1028         perform ltxtdtsp.
1029         clear okcode_100.
1030       When 'MODNO' OR 'CAPEQT' OR 'MFR'.
1031   *      g_curs_ln = g_curr_line_120.
1032         read table g_tablctrl120_itab into g_tablctrl120_wa
1033         index g_curs_ln.
1034         refresh ist_srchlp_cp.
1035         append lines of ist_srchlp_cpo to ist_srchlp_cp.
1036         perform srchlp_spr_del.
1037         clear okcode_100.
1038   *      refresh control 'TABCTRL100' from screen '0100'.
1039
1040   *    when 'CHECK'.
1041   *      Call Screen 102 starting at 10 05 ending at 140 15.
1042       When 'CPMC'.
1043
1044   * g_SRNO is being picked up thru Perform get_srno.
1045         read table ist_srchlp into wa_srchlp with key mark = 'X'.
1046         if sy-subrc = 0.
1047           Case zmm_cdhd_st-mtart.
1048             When 'ZSTO'.
1049               read table g_tabctrl110_itab into g_tabctrl110_wa
1050                                              with key SRNO = G_SRNO.
1051               If sy-subrc = 0.
1052                 If g_tabctrl110_wa-comp_flg = ''.
1053                  g_tabctrl110_wa-matcode = wa_srchlp-matnr.
1054   *               g_tabctrl110_wa-flag = ''.
1055                  g_tabctrl110_wa-comp_flg = 'A'.
1056                  modify g_tabctrl110_itab from g_tabctrl110_wa
1057                        index sy-tabix transporting flag comp_flg matcode.
1058                 Endif.
1059               Endif.
1060   *               Perform cp_matcode.
1061             When 'ZSPR'.
1062               read table g_tablctrl120_itab into g_tablctrl120_wa
1063                                               with key SRNO = G_SRNO.
1064               If sy-subrc = 0.
1065                 If g_tablctrl120_wa-comp_flg = ''.
1066                  g_tablctrl120_wa-matcode = wa_srchlp-matnr.
1067   *               g_tablctrl120_wa-flag = ''.
1068                  g_tablctrl120_wa-COMP_FLG = 'A'.
1069                  modify g_tablctrl120_itab from g_tablctrl120_wa
1070                        index sy-tabix transporting flag comp_flg matcode .
1071                 Endif.
1072               Endif.
1073
1074   *            Perform cp_matcode.
1075             When 'ZCAP'.
1076               read table g_tablctrl130_itab into g_tablctrl130_wa
1077                                            with key SRNO = G_SRNO.
1078               If sy-subrc = 0.
1079                 If g_tablctrl130_wa-comp_flg = ''.
1080                  g_tablctrl130_wa-matcode = wa_srchlp-matnr.
1081   *               g_tablctrl130_wa-flag = ''.
1082                  g_tablctrl130_wa-comp_flg = 'A'.
1083                  modify g_tablctrl130_itab from g_tablctrl130_wa
1084                        index sy-tabix transporting flag comp_flg matcode.
1085                Endif.
1086               Endif.
1087
1088   *            Perform cp_matcode.
1089           Endcase.
1090   *        clear G_SRNO.
1091         Else.
1092           message i040(zmm_oth) with 'from Search Help'.
1093         Endif.
1094       When 'UNDO_CPMC'.
1095           Case zmm_cdhd_st-mtart.
1096             When 'ZSTO'.
1097               read table g_tabctrl110_itab into g_tabctrl110_wa
1098                                              with key FLAG = 'X'.
1099               If sy-subrc = 0 and g_tabctrl110_wa-comp_flg = 'A'.
1100                  g_tabctrl110_wa-matcode = ''.
1101                  g_tabctrl110_wa-flag = ''.
1102                  g_tabctrl110_wa-comp_flg = ''.
1103                  modify g_tabctrl110_itab from g_tabctrl110_wa
1104                        index sy-tabix transporting flag comp_flg matcode.
1105               Else.
1106                  message i040(Zmm_oth).
1107               Endif.
1108   *               Perform cp_matcode.
1109             When 'ZSPR'.
1110               read table g_tablctrl120_itab into g_tablctrl120_wa
1111                                               with key FLAG = 'X'.
1112                 If sy-subrc = 0 and g_tablctrl120_wa-comp_flg = 'A'.
1113                   g_tablctrl120_wa-matcode = ''.
1114                   g_tablctrl120_wa-flag = ''.
1115                   g_tablctrl120_wa-COMP_FLG = ''.
1116                   modify g_tablctrl120_itab from g_tablctrl120_wa
1117                        index sy-tabix transporting flag comp_flg matcode .
1118                 Else.
1119                   message i040(Zmm_oth).
1120                 Endif.
1121
1122   *            Perform cp_matcode.
1123             When 'ZCAP'.
1124               read table g_tablctrl130_itab into g_tablctrl130_wa
1125                                            with key FLAG = 'X'.
1126               If sy-subrc = 0 and g_tablctrl130_wa-comp_flg = 'A'.
1127                  g_tablctrl130_wa-matcode  = ''.
1128                  g_tablctrl130_wa-flag     = ''.
1129                  g_tablctrl130_wa-comp_flg = ''.
1130                  modify g_tablctrl130_itab from g_tablctrl130_wa
1131                        index sy-tabix transporting flag comp_flg matcode.
1132               Else.
1133                  message i040(Zmm_oth).
1134               Endif.
1135
1136   *            Perform cp_matcode.
1137           Endcase.
1138
1139   Endcase.
1140   *******Addition*********************************
1141   OK_CODE = sy-ucomm.
1142   check_code = sy-ucomm.
1143
1144   CASE zmm_cdhd_st-mtart.
1145     WHEN 'ZSTO'.
1146       perform user_ok_tc using    'TABCTRL110'
1147                                   'G_TABCTRL110_ITAB'
1148                                   'FLAG'
1149                          changing OK_CODE.
1150       clear: ok_code, sy-ucomm.
1151     WHEN 'ZSPR'.
1152       perform user_ok_tc using    'TABLCTRL120'
1153                                   'G_TABLCTRL120_ITAB'
1154                                   'FLAG'
1155                          changing OK_CODE.
1156       clear: ok_code,sy-ucomm.
1157     WHEN 'ZCAP'.
1158       perform user_ok_tc using    'TABLCTRL130'
1159                                   'G_TABLCTRL130_ITAB'
1160                                   'FLAG'
1161                          changing OK_CODE.
1162       clear: ok_code,sy-ucomm.
1163     WHEN 'ZDIS'.
1164       perform user_ok_tc using    'TABLCTRL140'
1165                                   'G_TABLCTRL140_ITAB'
1166                                   'FLAG'
1167                          changing OK_CODE.
1168       clear: ok_code,sy-ucomm.
1169   ENDCASE.
1170
1171
1172   ENDMODULE.                 " user_command_100  INPUT
1173   *&---------------------------------------------------------------------*
1174   *&      Module  get_cursor  INPUT
1175   *&---------------------------------------------------------------------*
1176   *       text
1177   *----------------------------------------------------------------------*
1178   MODULE get_cursor110 INPUT.
1179     clear TABCTRL110_check_flag.
1180   *
1181     g_lineno_old = g_lineno.
1182
1183     get cursor field g_curfield.
1184
1185     get cursor field g_curfield110.
1186
1187     get cursor line g_cursor_line.
1188     g_curr_line = g_cursor_line.
1189     g_curr_line = TABCTRL110-top_line + g_cursor_line - 1.
1190     g_curr_line_110 = g_curr_line.
1191
1192   *  if g_lineno ne g_curr_line.
1193   *     clear g_hits_par.
1194   *  endif.
1195
1196   ENDMODULE.                 " get_cursor  INPUT
1197
1198   *---------------------------------------------------------------------*
1199   *       MODULE get_cursor120 INPUT                                    *
1200   *---------------------------------------------------------------------*
1201   *       ........                                                      *
1202   *---------------------------------------------------------------------*
1203   MODULE get_cursor120 INPUT.
1204
1205     get cursor field g_curfield.
1206
1207     get cursor field g_curfield120.
1208
1209     get cursor line g_cursor_line.
1210     g_curr_line = g_cursor_line.
1211     g_curr_line = TABLCTRL120-top_line + g_cursor_line - 1.
1212     g_curr_line_120 = g_curr_line .
1213
1214   ENDMODULE.                 " get_cursor120  INPUT
1215
1216   *---------------------------------------------------------------------*
1217   *       MODULE get_cursor130 INPUT                                    *
1218   *---------------------------------------------------------------------*
1219   *       ........                                                      *
1220   *---------------------------------------------------------------------*
1221   MODULE get_cursor130 INPUT.
1222
1223     get cursor field g_curfield.
1224     get cursor field g_curfield130.
1225
1226     get cursor line g_cursor_line.
1227     g_curr_line = g_cursor_line.
1228     g_curr_line = TABLCTRL130-top_line + g_cursor_line - 1.
1229     g_curr_line_130 = g_curr_line.
1230
1231   ENDMODULE.                 " get_cursor130  INPUT
1232
1233   *---------------------------------------------------------------------*
1234   *       MODULE get_cursor140 INPUT                                    *
1235   *---------------------------------------------------------------------*
1236   *       ........                                                      *
1237   *---------------------------------------------------------------------*
1238   MODULE get_cursor140 INPUT.
1239
1240     get cursor field g_curfield.
1241
1242     get cursor line g_cursor_line.
1243     g_curr_line = g_cursor_line.
1244     g_curr_line = TABLCTRL140-top_line + g_cursor_line - 1.
1245
1246   ENDMODULE.                 " get_cursor140  INPUT
1247   *&---------------------------------------------------------------------*
1248   *&      Module  USER_COMMAND_0115  INPUT
1249   *&---------------------------------------------------------------------*
1250   *       text
1251   *----------------------------------------------------------------------*
1252   MODULE USER_COMMAND_0115 INPUT.
1253     data : field_name(20).
1254     Data : l_ans.
1255   *
1256     g_ok_code115 = sy-ucomm.
1257     Case g_ok_code115 .
1258       when  ''.
1259         Perform check_modi.
1260       when  'CANC' or 'RW'.
1261         clear : g_desc1,
1262                 g_desc2,
1263                 g_desc3,
1264                 g_desc4,
1265                 g_user_desc,
1266                 g_screen115_1st.
1267         Perform reset_other.
1268         If g_ok_code110 <> 'PB_AD'.
1269           clear : g_user_desc.
1270         Endif.
1271         leave to screen 0.
1272       when  'A_DESC'.
1273         g_screen115_1st = 'X'.
1274   *            Perform other_check.
1275       when 'OK115'.
1276         Perform check_modi.
1277         g_TABCTRL110_wa-USER_DESC = g_user_desc.
1278         clear ist_spell_line.
1279
1280         If  g_TABCTRL110_wa-oth1  = 'X'.
1281           concatenate g_desc1 g_desc2
1282            g_desc3 g_desc4
1283            g_user_desc into ist_spell_line-tdline
1284            separated by space.
1285           g_tabctrl110_wa-COMP_FLG = ' M'.
1286
1287         Elseif g_TABCTRL110_wa-oth2 = 'X'.
1288           concatenate g_desc2 g_desc3 g_desc4 g_user_desc into
1289           ist_spell_line-tdline separated by space.
1290           g_tabctrl110_wa-COMP_FLG = ' M'.
1291
1292         Elseif g_TABCTRL110_wa-oth3 = 'X'.
1293           concatenate g_desc3 g_desc4 g_user_desc into
1294           ist_spell_line-tdline separated by space.
1295           g_tabctrl110_wa-COMP_FLG = ' M'.
1296
1297         Elseif g_TABCTRL110_wa-oth4 = 'X'.
1298           concatenate g_desc4
1299           g_user_desc into ist_spell_line-tdline separated
1300           by space.
1301           g_tabctrl110_wa-COMP_FLG = ' M'.
1302
1303         Else.
1304   *+130705
1305           replace 'M' with '' into g_tabctrl110_wa-COMP_FLG.
1306   *-130705
1307           ist_spell_line-tdline = g_user_desc.
1308         Endif.
1309
1310         append ist_spell_line.
1311
1312         EXPORT G_USER TO MEMORY ID 'G_USER1' .
1313         CALL FUNCTION 'ZSPELL_CHECK'
1314              EXPORTING
1315                   SPRACHE = 'EN'
1316              TABLES
1317                   ILINE   = ist_spell_line.
1318
1319         IMPORT CHECKTAB FROM MEMORY ID 'G_CHECKTAB'.
1320
1321         if not checktab[] is initial.
1322   " Begin of <RD1K960036>.
1323   *        CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
1324   *          EXPORTING
1325   *                   TEXTLINE1            = 'There are spelling errors in description(s)'
1326   *           TEXTLINE2            = 'Proceed with errors? '
1327   *            TITEL                = 'Spelling Errors'
1328   **                  START_COLUMN         = 25
1329   **                  START_ROW            = 6
1330   **                  CANCEL_DISPLAY       = 'X'
1331   *         IMPORTING
1332   *           ANSWER               = l_ans.
1333
1334
1335         DATA : L_ANSWER(1) TYPE C.
1336
1337           CALL FUNCTION 'POPUP_TO_CONFIRM'
1338             EXPORTING
1339              TITLEBAR                    = 'Spelling Errors '
1340               TEXT_QUESTION               = 'There are spelling errors in description(s)'
1341                                             &'Proceed with errors? '
1342              DISPLAY_CANCEL_BUTTON       = 'X'
1343              START_COLUMN                = 25
1344              START_ROW                   = 6
1345            IMPORTING
1346              ANSWER                      = L_ANSWER
1347            EXCEPTIONS
1348              TEXT_NOT_FOUND              = 1
1349              OTHERS                      = 2
1350                     .
1351           IF SY-subrc = 0.
1352
1353             CASE L_ANSWER.
1354               WHEN '1'.
1355                 MOVE 'J' TO L_ANS.
1356                 WHEN '2'.
1357                   MOVE 'N' TO L_ANS.
1358                   ENDCASE.
1359
1360           ENDIF.
1361   " End of <RD1K960036>.
1362           If l_ans = 'J'.
1363             clear : g_screen115_1st,user_desc_len.
1364             g_other = 'X'.
1365             If g_tabctrl110_wa-COMP_FLG+1(1) = 'M'.
1366               g_tabctrl110_wa-COMP_FLG = 'SM'.
1367             Else.
1368               g_tabctrl110_wa-COMP_FLG = 'S'.
1369             Endif.
1370   *          g_tabctrl110_wa-rsn   = 'Spelling mistakes/Modifier not in
1371   *                                   Attributes table'.
1372             leave to screen 0.
1373           Else.
1374             Loop at screen.
1375               if screen-name = 'G_DESC1' or
1376                  screen-name = 'G_DESC2' or
1377                  screen-name = 'G_DESC3' or
1378                  screen-name = 'G_DESC4'.
1379                 screen-input = 1.
1380                 modify screen.
1381               Endif.
1382             Endloop.
1383           endif.
1384         Else.
1385           clear : g_screen115_1st,user_desc_len.
1386           g_other = 'X'.
1387           replace 'S' with '' into g_tabctrl110_wa-COMP_FLG.
1388   *        if g_tabctrl110_wa-COMP_FLG+0(1) = 'S'. "remove spell error
1389   *          g_tabctrl110_wa-COMP_FLG = ' M'.
1390   **          g_tabctrl110_wa-rsn   = 'Modifier not in Attributes table'.
1391   *        Endif.
1392           leave to screen 0.
1393
1394         Endif.
1395     Endcase.
1396
1397
1398
1399   ENDMODULE.                 " USER_COMMAND_0115  INPUT
1400   *&---------------------------------------------------------------------*
1401   *&      Module  TAbctrl110_value  INPUT
1402   *&---------------------------------------------------------------------*
1403   *       text
1404   *----------------------------------------------------------------------*
1405   MODULE TAbctrl110_value INPUT.
1406
1407     get parameter id 'ZMATGP' field g_matgp .
1408     move g_matgp to ZMM_CDITEM-MATGP.
1409
1410   ENDMODULE.                 " TAbctrl110_value  INPUT
1411   *&---------------------------------------------------------------------*
1412   *&      Module  SCREEN100_initialize  INPUT
1413   *&---------------------------------------------------------------------*
1414   *       text
1415   *----------------------------------------------------------------------*
1416   MODULE SCREEN100_initialize INPUT.
1417     Perform check_delreq.
1418     clear g_hd_copied.
1419     clear g_TABCTRL110_copied.
1420   ***Addition ****************************************
1421   ****If reqno change from one mat type to another, to clear the
1422   ****Search help tablecontrol.
1423     refresh: ist_srchlp.
1424     refresh control 'TABCTRL100' from screen '0100'.
1425     clear: FIELD1.
1426   ***End *********************************************
1427   ENDMODULE.                 " SCREEN100_initialize  INPUT
1428
1429   *&---------------------------------------------------------------------*
1430   *&      Module  TEXT_CONTROL_UEBERNEHMEN  INPUT
1431   *&---------------------------------------------------------------------*
1432   *       text
1433   *----------------------------------------------------------------------*
1434   MODULE TEXT_CONTROL_UEBERNEHMEN INPUT.
1435     GV_XTHEAD_UPDKZ = 0.
1436
1437     CALL METHOD GV_TEXT_EDITOR->GET_TEXT_AS_STREAM
1438          IMPORTING
1439               TEXT       = LT_TEXT_TABLE
1440               IS_MODIFIED = GV_XTHEAD_UPDKZ
1441          EXCEPTIONS
1442               ERROR_DP               = 1
1443               ERROR_CNTL_CALL_METHOD = 2
1444               OTHERS                 = 3.
1445
1446     CALL FUNCTION 'CONVERT_STREAM_TO_ITF_TEXT'
1447          TABLES
1448               TEXT_STREAM = LT_TEXT_TABLE
1449               ITF_TEXT    = TLINETAB.
1450
1451   ENDMODULE.                 " TEXT_CONTROL_UEBERNEHMEN  INPUT
1452
1453   *&---------------------------------------------------------------------*
1454   *&      Module  exit_req  INPUT
1455   *&---------------------------------------------------------------------*
1456   *       text
1457   *----------------------------------------------------------------------*
1458   MODULE exit_req INPUT.
1459     Perform bac_confirm.
1460     leave program.
1461   ENDMODULE.                 " exit_req  INPUT
1462   *&---------------------------------------------------------------------*
1463   *&      Module  get_cursor100  INPUT
1464   *&---------------------------------------------------------------------*
1465   *       text
1466   *----------------------------------------------------------------------*
1467   MODULE get_cursor100 INPUT.
1468
1469     get cursor field g_curfield.
1470
1471     get cursor line g_cursor_line.
1472     g_curr_line = g_cursor_line.
1473     g_curr_line = TABCTRL100-top_line + g_cursor_line - 1.
1474     g_curr_line_100 = g_curr_line.
1475
1476   ENDMODULE.                 " get_cursor100  INPUT
1477   *&      Module  SCREEN100_initialize1  INPUT
1478   *&---------------------------------------------------------------------*
1479   *       text
1480   *----------------------------------------------------------------------*
1481   MODULE SCREEN100_initialize1 INPUT.
1482
1483     refresh ist_srchlp.
1484     refresh g_TABCTRL110_itab.
1485     clear g_tabctrl110_itab.
1486     clear zmm_cditem.
1487     clear g_mat_fnd.
1488     PERFORM clear_srchlp_parms.
1489
1490   ENDMODULE.                 " SCREEN100_initialize1  INPUT
1491   *&---------------------------------------------------------------------*
1492   *&      Module  longtext  INPUT
1493   *&---------------------------------------------------------------------*
1494   *       text
1495   *----------------------------------------------------------------------*
1496   MODULE longtext INPUT.
1497     Data: l_okdtsp like sy-ucomm.
1498
1499     l_okdtsp = sy-ucomm.
1500     CASE l_okdtsp.
1501       WHEN 'REQLT'.
1502   *
1503         perform ltxtdtsp.
1504         clear: l_okdtsp,sy-ucomm.
1505     ENDCASE.
1506
1507   ENDMODULE.                 " longtext  INPUT
1508   *&---------------------------------------------------------------------*
1509   *&      Module  TEXT_CTRL_UEBERNEHMEN  INPUT
1510   *&---------------------------------------------------------------------*
1511   *       text
1512   *----------------------------------------------------------------------*
1513   MODULE TEXT_CTRL_UEBERNEHMEN INPUT.
1514     GV_XTHEAD_UPDKZ = 0.
1515
1516     CALL METHOD GV_TEXT_EDITOR1->GET_TEXT_AS_STREAM
1517          IMPORTING
1518               TEXT       =  LT_TEXT_TABLE1
1519               IS_MODIFIED = GV_XTHEAD_UPDKZ
1520          EXCEPTIONS
1521               ERROR_DP               = 1
1522               ERROR_CNTL_CALL_METHOD = 2
1523               OTHERS                 = 3.
1524
1525     CALL FUNCTION 'CONVERT_STREAM_TO_ITF_TEXT'
1526          TABLES
1527               TEXT_STREAM = LT_TEXT_TABLE1
1528               ITF_TEXT    = TLINETAB1.
1529
1530     CALL METHOD GV_TEXT_EDITOR2->GET_TEXT_AS_STREAM
1531          IMPORTING
1532               TEXT       =  LT_TEXT_TABLE2
1533               IS_MODIFIED = GV_XTHEAD_UPDKZ
1534          EXCEPTIONS
1535               ERROR_DP               = 1
1536               ERROR_CNTL_CALL_METHOD = 2
1537               OTHERS                 = 3.
1538
1539     CALL FUNCTION 'CONVERT_STREAM_TO_ITF_TEXT'
1540          TABLES
1541               TEXT_STREAM = LT_TEXT_TABLE2
1542               ITF_TEXT    = TLINETAB2.
1543
1544
1545   ENDMODULE.                 " TEXT_CTRL_UEBERNEHMEN  INPUT
1546   *&---------------------------------------------------------------------*
1547   *&      Module  TREE_CTRL_EMPFANGEN  INPUT
1548   *&---------------------------------------------------------------------*
1549   *       text
1550   *----------------------------------------------------------------------*
1551   MODULE TREE_CTRL_EMPFANGEN INPUT.
1552
1553   ENDMODULE.                 " TREE_CTRL_EMPFANGEN  INPUT
1554   *&---------------------------------------------------------------------*
1555   *&      Module  OTHER_CHECK  INPUT
1556   *&---------------------------------------------------------------------*
1557   *       text
1558   *----------------------------------------------------------------------*
1559   MODULE OTHER_CHECK INPUT.
1560     Perform other_check.
1561   ENDMODULE.                 " OTHER_CHECK  INPUT
1562   *&---------------------------------------------------------------------*
1563   *&      Module  TABCTRL110_check  INPUT
1564   *&---------------------------------------------------------------------*
1565   *       text
1566   *----------------------------------------------------------------------*
1567   MODULE TABCTRL110_check INPUT.
1568
1569     TABCTRL110_check_flag = 'X'.
1570   *g_check_flag          = 'X'.
1571
1572   ENDMODULE.                 " TABCTRL110_check  INPUT
1573   *&---------------------------------------------------------------------*
1574   *&      Module  TEXT_CTRL_UEBERNEHMEN1  INPUT
1575   *&---------------------------------------------------------------------*
1576   *       text
1577   *----------------------------------------------------------------------*
1578   MODULE TEXT_CTRL_UEBERNEHMEN1 INPUT.
1579     GV_XTHEAD_UPDKZ = 0.
1580
1581     CALL METHOD GV_TEXT_EDITOR1->GET_TEXT_AS_STREAM
1582          IMPORTING
1583               TEXT       =  LT_TEXT_TABLE1
1584               IS_MODIFIED = GV_XTHEAD_UPDKZ
1585          EXCEPTIONS
1586               ERROR_DP               = 1
1587               ERROR_CNTL_CALL_METHOD = 2
1588               OTHERS                 = 3.
1589
1590     CALL FUNCTION 'CONVERT_STREAM_TO_ITF_TEXT'
1591          TABLES
1592               TEXT_STREAM = LT_TEXT_TABLE1
1593               ITF_TEXT    = TLINETAB1.
1594   **
1595     IF ( g_mode = 'CRE' ) or ( g_mode = 'CHA' ) OR
1596        ( g_mode = 'REL' ) or ( g_mode = 'APR' ) OR
1597        ( g_mode = 'MRP' ) or sy-tcode = 'ZCODG'.
1598
1599       CALL METHOD GV_TEXT_EDITOR2->GET_TEXT_AS_STREAM
1600            IMPORTING
1601                 TEXT       =  LT_TEXT_TABLE2
1602                 IS_MODIFIED = GV_XTHEAD_UPDKZ
1603            EXCEPTIONS
1604                 ERROR_DP               = 1
1605                 ERROR_CNTL_CALL_METHOD = 2
1606                 OTHERS                 = 3.
1607
1608       CALL FUNCTION 'CONVERT_STREAM_TO_ITF_TEXT'
1609            TABLES
1610                 TEXT_STREAM = LT_TEXT_TABLE2
1611                 ITF_TEXT    = TLINETAB2.
1612     ENDIF..
1613   ENDMODULE.                 " TEXT_CTRL_UEBERNEHMEN1  INPUT
1614   *&---------------------------------------------------------------------*
1615   *&      Module  USER_COMMAND_0105  INPUT
1616   *&---------------------------------------------------------------------*
1617   *       text
1618   *----------------------------------------------------------------------*
1619   MODULE USER_COMMAND_0105 INPUT.
1620     Data: okcode105 like sy-ucomm.
1621
1622     okcode105 = sy-ucomm.
1623
1624     Case okcode105.
1625       When 'OK'.
1626         clear okcode105.
1627       When 'CANCEL'.
1628         refresh tlinetab2[].
1629         clear okcode105.
1630     Endcase.
1631   ENDMODULE.                 " USER_COMMAND_0105  INPUT
1632   *&---------------------------------------------------------------------*
1633   *&      Module  WRITE_MESSAGES  INPUT
1634   *&---------------------------------------------------------------------*
1635   *       text
1636   *----------------------------------------------------------------------*
1637   MODULE WRITE_MESSAGES INPUT.
1638
1639     Leave to list-processing and return to screen 0.
1640     set pf-status space.
1641     loop at ist_message into wa_message.
1642       write: / wa_message-srno, wa_message-msgtype,wa_message-msgcode,
1643                     wa_message-msgtext.
1644     endloop.
1645
1646   ENDMODULE.                 " WRITE_MESSAGES  INPUT
1647   *&---------------------------------------------------------------------*
1648   *&      Module  USER_COMMAND_0102  INPUT
1649   *&---------------------------------------------------------------------*
1650   *       text
1651   *----------------------------------------------------------------------*
1652   MODULE USER_COMMAND_0102 INPUT.
1653
1654     refresh ist_message.
1655
1656   ENDMODULE.                 " USER_COMMAND_0102  INPUT
1657
1658   *&---------------------------------------------------------------------*
1659   *&      Module  TABLE110_check_desc2  INPUT
1660   *&---------------------------------------------------------------------*
1661   *       text
1662   *----------------------------------------------------------------------*
1663   MODULE TABLE110_check_desc2 INPUT.
1664
1665     IF zmm_cditem-desc2 <> 'OTHER'.
1666      select single * from zmm_modifier where desc1 = zmm_cditem-desc1 and
1667                                                 desc2 = zmm_cditem-desc2 .
1668
1669       if sy-subrc <> 0.
1670         message e002(zmm_oth).
1671       endif.
1672     ENDIF.
1673
1674   ENDMODULE.                 " TABLE110_check_desc2  INPUT
1675
1676   *&---------------------------------------------------------------------*
1677   *&      Module  TABLE110_check_desc3  INPUT
1678   *&---------------------------------------------------------------------*
1679   *       text
1680   *----------------------------------------------------------------------*
1681   MODULE TABLE110_check_desc3 INPUT.
1682
1683     IF zmm_cditem-desc3 <> 'OTHER'.
1684      select single * from zmm_modifier where desc1 = zmm_cditem-desc1 and
1685                                              desc2 = zmm_cditem-desc2 and
1686                                                  desc3 = zmm_cditem-desc3.
1687
1688       if sy-subrc <> 0.
1689         message e002(zmm_oth).
1690       endif.
1691     ENDIF.
1692
1693   ENDMODULE.                 " TABLE110_check_desc3  INPUT
1694   *&---------------------------------------------------------------------*
1695   *&      Module  TABLE110_check_desc4  INPUT
1696   *&---------------------------------------------------------------------*
1697   *       text
1698   *----------------------------------------------------------------------*
1699   MODULE TABLE110_check_desc4 INPUT.
1700
1701     IF zmm_cditem-desc4 <> 'OTHER'.
1702      select single * from zmm_modifier where desc1 = zmm_cditem-desc1 and
1703                                              desc2 = zmm_cditem-desc2 and
1704                                              desc3 = zmm_cditem-desc3 and
1705                                                  desc4 = zmm_cditem-desc4.
1706
1707       if sy-subrc <> 0.
1708         message e002(zmm_oth).
1709       endif.
1710     ENDIF.
1711
1712   ENDMODULE.                 " TABLE110_check_desc4  INPUT
1713   *&---------------------------------------------------------------------*
1714   *&      Module  TABLE110_check_desc1  INPUT
1715   *&---------------------------------------------------------------------*
1716   *       text
1717   *----------------------------------------------------------------------*
1718   MODULE TABLE110_check_desc1 INPUT.
1719     Data l_cnt type i.
1720
1721     IF zmm_cditem-desc1 <> 'OTHER'.
1722       select single * from zmm_modifier where desc1 = zmm_cditem-desc1.
1723       if sy-subrc <> 0.
1724         message e002(zmm_oth).
1725       else.
1726         Select count(*) into l_cnt from zmm_modifier
1727                         where desc1 = zmm_cditem-desc1.
1728         If l_cnt > 1.
1729           perform TABCTRL110_desc1_check.
1730         Endif.
1731       endif.
1732     ENDIF.
1733
1734   ENDMODULE.                 " TABLE110_check_desc1  INPUT
1735   *&---------------------------------------------------------------------*
1736   *&      Module  USER_COMMAND_0103  INPUT
1737   *&---------------------------------------------------------------------*
1738   *       text
1739   *----------------------------------------------------------------------*
1740   MODULE USER_COMMAND_0103 INPUT.
1741
1742   ENDMODULE.                 " USER_COMMAND_0103  INPUT
1743   *&---------------------------------------------------------------------*
1744   *&      Module  USER_COMMAND_0150  INPUT
1745   *&---------------------------------------------------------------------*
1746   *       text
1747   *----------------------------------------------------------------------*
1748   MODULE USER_COMMAND_0150 INPUT.
1749
1750     case sy-ucomm.
1751
1752       when 'OK150'.
1753
1754         leave to screen 0.
1755
1756       when 'CAN150'.
1757
1758         leave to screen 0.
1759
1760     endcase.
1761
1762   ENDMODULE.                 " USER_COMMAND_0150  INPUT
1763   *&---------------------------------------------------------------------*
1764   *&      Module  check_plant  INPUT
1765   *&---------------------------------------------------------------------*
1766   *       text
1767   *----------------------------------------------------------------------*
1768   MODULE check_plant INPUT.
1769     Data : l_werks like t001w-werks.
1770     IF not zmm_cdhd_st-werks is initial.
1771       Select single werks into l_werks from t001w
1772              where werks = zmm_cdhd_st-werks.
1773       if sy-subrc <> 0.
1774         message e033(zmm_oth).
1775       endif.
1776     ENDIF.
1777   ENDMODULE.                 " check_plant  INPUT
1778   *&---------------------------------------------------------------------*
1779   *&      Module  check_location  INPUT
1780   *&---------------------------------------------------------------------*
1781   *       text
1782   *----------------------------------------------------------------------*
1783   MODULE check_location INPUT.
1784     Data : l_locid like ZLOCMST-locid.
1785     IF not zmm_cdhd_st-reqloc is initial.
1786       Select single locid into l_locid from  zlocmst
1787              where locid = zmm_cdhd_st-reqloc.
1788       if sy-subrc <> 0.
1789         message e036(zmm_oth).
1790       endif.
1791     ENDIF.
1792
1793   ENDMODULE.                 " check_location  INPUT
1794   *&---------------------------------------------------------------------*
1795   *&      Module  get_matgp_desc  INPUT
1796   *&---------------------------------------------------------------------*
1797   *       text
1798   *----------------------------------------------------------------------*
1799   MODULE get_matgp_desc INPUT.
1800     select single WGBEZ from T023T into g_matgp_desc where MATKL =
1801     g_matgp and spras = sy-langu.
1802     if sy-subrc <> 0.
1803       g_matgp = ''.
1804     Endif.
1805
1806   ENDMODULE.                 " get_matgp_desc  INPUT
1807   *&---------------------------------------------------------------------*
1808   *&      Module  check_capcode  INPUT
1809   *&---------------------------------------------------------------------*
1810   *       text
1811   *----------------------------------------------------------------------*
1812   MODULE check_capcode INPUT.
1813     Data : l_capcode like mara-matnr.
1814     if not zmm_cditem-cap_code is initial.
1815       Select single matnr into l_capcode from mara
1816       where matnr = zmm_cditem-cap_code and
1817             mtart = 'ZCAP'.
1818       if sy-subrc <> 0.
1819         message e041(zmm_oth) with zmm_cditem-cap_code.
1820       Endif.
1821     Endif.
1822
1823   ENDMODULE.                 " check_capcode  INPUT
1824   *&---------------------------------------------------------------------*
1825   *&      Module  check_modelno  INPUT
1826   *&---------------------------------------------------------------------*
1827   *       text
1828   *----------------------------------------------------------------------*
1829   MODULE check_modelno INPUT.
1830     data: l_strlen type I, K type I.
1831     data: l_ans2,X.
1832     data : ist_sval_temp(30).
1833
1834     refresh ist_mdl. clear ist_mdl.
1835     If zmm_cditem-mdlno <> 'OTHER'.
1836       Select single * from zmm_mdl into zmm_mdl
1837        where mdlno = zmm_cditem-mdlno.
1838       if sy-subrc <> 0.
1839         message e044(zmm_oth).
1840         move ' L' to zmm_cditem-comp_flg.
1841       else.
1842         replace 'L' with  '' into zmm_cditem-comp_flg.
1843         move '' to zmm_cditem-oth_mdl.
1844       endif.
1845     Else.
1846       refresh ist_sval.
1847       clear   ist_sval.
1848       clear   ist_sval_temp.
1849
1850       move : 'ZMM_CDITEM'  to ist_sval-TABNAME,
1851              'MDLNO'       to ist_sval-FIELDNAME,
1852              'X'           to ist_sval-FIELD_OBL.
1853       append ist_sval.
1854       CALL FUNCTION 'POPUP_GET_VALUES'
1855         EXPORTING
1856   *   NO_VALUE_CHECK        = ' '
1857           POPUP_TITLE           = 'Enter Model No.'
1858           START_COLUMN          = '5'
1859           START_ROW             = '5'
1860         TABLES
1861           FIELDS                = ist_sval
1862   * EXCEPTIONS
1863   *   ERROR_IN_FIELDS       = 1
1864   *   OTHERS                = 2
1865                 .
1866       IF SY-SUBRC <> 0.
1867   * MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
1868   *         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
1869       ENDIF.
1870       read table ist_sval index 1.
1871       zmm_mdl-mdlno = IST_SVAL-value.  "#EC CI_FLDEXT_OK[2215424]
1872       If not IST_SVAL-value is initial.
1873   *      read table ist_sval index 1.
1874         l_strlen = strlen( ist_sval-value ).
1875         IST_SVAL_org = ist_sval-value.
1876
1877         Translate  ist_sval-value using
1878   '.%-%,%+%*%_%^%?%"%!% %$%:%;%`%"%/%\%<%>%=%§%#%~%(%)%|%<%>%@%{%}%[%]%~%'
1879   .
1880         ist_sval-value = ist_sval-value+0(l_strlen).
1881         l_strlen = l_strlen + 1.
1882         K = 0.
1883         do l_strlen times.
1884           X =  ist_sval-value+K(1).
1885           if X <> '%'.
1886             concatenate ist_sval_temp '%' X into ist_sval_temp.
1887             condense ist_sval_temp no-gaps.
1888           Endif.
1889           K = K + 1 .
1890           X = ''.
1891         Enddo.
1892         ist_sval-value = ist_sval_temp.
1893         select * from zmm_mdl into table ist_mdl where mdlno like
1894         ist_sval-value ORDER BY PRIMARY KEY.
1895         if sy-subrc <> 0.
1896           zmm_cditem-mdlno = zmm_mdl-mdlno.
1897           zmm_cditem-oth_mdl = 'X'.
1898           IF zmm_cditem-comp_flg+0(1) ='S'.
1899             zmm_cditem-comp_flg = 'SL'.
1900           Else.
1901             zmm_cditem-comp_flg = ' L'.
1902           Endif.
1903
1904         Else.
1905
1906           Translate ist_sval-value using '% '.
1907           condense ist_sval-value no-gaps.
1908
1909           Loop at ist_mdl.
1910             Translate  ist_mdl-mdlno using
1911    '. - , + * _ ^ ? " ! $ : ; ` " / \ < > = § # ~ ( ) | < > @ { } [ ] ~ '.
1912             condense ist_mdl-mdlno no-gaps.
1913             If ist_mdl-mdlno <> ist_sval-value.
1914               delete ist_mdl index sy-tabix.
1915             Endif.
1916           Endloop.
1917           CALL SCREEN 104 STARTING AT 40 2
1918                           ENDING   AT 80 18.
1919           If zmm_Cditem-mdlno = 'OTHER'.
1920             zmm_cditem-mdlno = ''.
1921           Endif.
1922         Endif.
1923       Else.
1924         zmm_cditem-mdlno = ''.
1925
1926       Endif.
1927     Endif.
1928   ENDMODULE.                 " check_modelno  INPUT
1929   *&---------------------------------------------------------------------*
1930   *&      Module  check_matgp  INPUT
1931   *&---------------------------------------------------------------------*
1932   *       text
1933   *----------------------------------------------------------------------*
1934   MODULE check_matgp INPUT.
1935   * Check only stores group is selected
1936     if g_tabctrl110_wa-desc1 = 'OTHER' or g_tabctrl110_wa-oth1 = 'X'.
1937       if g_matgp > '16' or g_matgp < '07'.
1938         message e049(zmm_oth).
1939       Endif.
1940     Endif.
1941
1942   ENDMODULE.                 " check_matgp  INPUT
1943   *&---------------------------------------------------------------------*
1944   *&      Module  check_other  INPUT
1945   *&---------------------------------------------------------------------*
1946   *       text
1947   *----------------------------------------------------------------------*
1948   MODULE check_other INPUT.
1949   *
1950     if zmm_cditem-oth1 = 'X' or
1951        zmm_cditem-oth2 = 'X' or
1952        zmm_cditem-oth3 = 'X' or
1953        zmm_cditem-oth4 = 'X'.
1954
1955     Else.
1956       replace 'M' with '' into zmm_cditem-comp_flg.
1957     Endif.
1958   ENDMODULE.                 " check_other  INPUT
1959   *&---------------------------------------------------------------------*
1960   *&      Module  get_cursor_fld  INPUT
1961   *&---------------------------------------------------------------------*
1962   *       text
1963   *----------------------------------------------------------------------*
1964   MODULE get_cursor_fld INPUT.
1965   *
1966     get cursor field g_cursor_fld130.
1967     if zmm_cditem-desc_fin is initial.
1968       message i007(zmm_oth).
1969       set cursor field 'ZMM_CDITEM-DESC_FIN'.
1970     Endif.
1971
1972   ENDMODULE.                 " get_cursor_fld  INPUT
1973   *&---------------------------------------------------------------------*
1974   *&      Module  Check_characterstics_MATCATG  INPUT
1975   *&---------------------------------------------------------------------*
1976   *       text
1977   *----------------------------------------------------------------------*
1978   MODULE Check_characterstics_MATCATG INPUT.
1979   *
1980     Data : l_atwrt like cawn-atwrt.
1981   *  Check g_cursor_fld130 <> 'ZMM_CDITEM-DESC_FIN'.
1982     select single atwrt from zmmcdcap_usrgp_v into l_atwrt where atwrt =
1983       ZMM_CDITEM-MATCATG.
1984     If sy-subrc <> 0.
1985       message e051(zmm_oth).
1986     Endif.
1987
1988   ENDMODULE.                 " Check_characterstics_MATCATG  INPUT
1989   *&---------------------------------------------------------------------*
1990   *&      Module  Check_characterstics_MATLOC  INPUT
1991   *&---------------------------------------------------------------------*
1992   *       text
1993   *----------------------------------------------------------------------*
1994   MODULE Check_characterstics_MATLOC INPUT.
1995   *
1996   *  Check g_cursor_fld130 <> 'ZMM_CDITEM-DESC_FIN'.
1997
1998     select single atwrt from zmmcdcap_loc_v into l_atwrt where atwrt =
1999       ZMM_CDITEM-MATLOC.
2000     If sy-subrc <> 0.
2001       message e051(zmm_oth).
2002     Endif.
2003
2004   ENDMODULE.                 " Check_characterstics_MATLOC  INPUT
2005   *&---------------------------------------------------------------------*
2006   *&      Module  Check_characterstics_SPAGRP  INPUT
2007   *&---------------------------------------------------------------------*
2008   *       text
2009   *----------------------------------------------------------------------*
2010   MODULE Check_characterstics_SPAGRP INPUT.
2011     select single atwrt from zmmcdcap_sprgp_v into l_atwrt where atwrt =
2012       ZMM_CDITEM-SPA_GRP.  "#EC CI_FLDEXT_OK[2215424]
2013     If sy-subrc <> 0.
2014       message e051(zmm_oth).
2015     Endif.
2016
2017   ENDMODULE.                 " Check_characterstics_SPAGRP  INPUT
2018   *&---------------------------------------------------------------------*
2019   *&      Module  Check_WRKNG_LIFE  INPUT
2020   *&---------------------------------------------------------------------*
2021   *       text
2022   *----------------------------------------------------------------------*
2023   MODULE Check_WRKNG_LIFE INPUT.
2024
2025   If ZMM_CDITEM-WRKNG_LIFE CA '.-,#~`!@#$%^&*()<>/:;"'''.
2026      message e058(zmm_oth).
2027   Endif.
2028   ENDMODULE.                 " Check_WRKNG_LIFE  INPUT
2029   *&---------------------------------------------------------------------*
2030   *&      Module  CHECK_TEL  INPUT
2031   *&---------------------------------------------------------------------*
2032   *       text
2033   *----------------------------------------------------------------------*
2034   MODULE CHECK_TEL INPUT.
2035   data : tel_len type i.
2036   tel_len = strlen( ZMM_CDHD_ST-TEL ).
2037     if  ZMM_CDHD_ST-TEL CO '0123456789'.
2038         message e059(zmm_oth).
2039     Else.
2040        if tel_len < 4.
2041          message e060(zmm_oth).
2042        Endif.
2043     Endif.
2044   ENDMODULE.                 " CHECK_TEL  INPUT
*--- End of MZMMCODREQ_ERROR_RESETI01 - 2044 lines ---

----------------------------------------------------------------------------------------------------
Include          MZMMCODREQ_ERROR_RESETF01                 Level 1    Page 5
Object           SAPMZMMCODREQ_ERROR_RESET                 Lines 6419
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:05
----------------------------------------------------------------------------------------------------
1      ************************************************************************
2      *  Date            Transport      USERID        Description
3      * 30/09/2008      <RD1K960036>    SAB_SUMODH
4      *
5      *1) Obsolete FM POPUP_TO_CONFIRM_STEP Replaced With 'POPUP_TO_CONFIRM'.
6      *
7      *
8      ************************************************************************
9      ***INCLUDE MZMMCODREQF01 .
10     *----------------------------------------------------------------------*
11     *   INCLUDE TABLECONTROL_FORMS                                         *
12     *----------------------------------------------------------------------*
13     *&---------------------------------------------------------------------*
14     *&      Form  USER_OK_TC                                               *
15     *&---------------------------------------------------------------------*
16      FORM user_ok_tc USING    p_tc_name TYPE dynfnam
17                               p_table_name
18                               p_mark_name
19                      CHANGING p_ok      LIKE sy-ucomm.
20
21     *-BEGIN OF LOCAL DATA--------------------------------------------------*
22        DATA: l_ok     TYPE sy-ucomm,
23              l_offset TYPE i.
24        DATA l_110itab TYPE TABLE OF t_tabctrl110.
25        DATA x(80).
26     *-END OF LOCAL DATA----------------------------------------------------*
27
28     * Table control specific operations                                    *
29     *   evaluate TC name and operations                                    *
30        SEARCH p_ok FOR p_tc_name.
31        IF sy-subrc <> 0.
32          EXIT.
33        ENDIF.
34        l_offset = strlen( p_tc_name ) + 1.
35        l_ok = p_ok+l_offset.
36     * execute general and TC specific operations                           *
37        CASE l_ok.
38          WHEN 'INSR'.                      "insert row
39            PERFORM check_tabrows.
40            IF g_mode = 'CRE'.
41              IF g_insrflg = 'Y'.
42                PERFORM fcode_insert_row
43                 USING p_tc_name p_table_name.
44                CLEAR p_ok.
45              ENDIF.
46            ELSE.
47              PERFORM fcode_insert_row
48               USING p_tc_name p_table_name.
49              CLEAR: p_ok,l_ok,sy-ucomm.
50            ENDIF.
51          WHEN 'DELE'.                      "delete row
52     ********Addition*****************************************
53            CASE zmm_cdhd_st-mtart.
54              WHEN 'ZSTO'.
55                PERFORM add_delitem110.
56              WHEN 'ZSPR'.
57                PERFORM add_delitem120.
58              WHEN 'ZCAP'.
59                PERFORM add_delitem130.
60              WHEN 'ZDIS'.
61                PERFORM add_delitem140.
62            ENDCASE.
63     ********End**********************************************
64            IF g_delflag <> 'N'.
65     *       message w052(zmm_oth).
66              PERFORM confirm_deletion.
67              IF g_confdel = 'J'.
68                PERFORM fcode_delete_row USING    p_tc_name
69                                                 p_table_name
70                                                 p_mark_name.
71                CLEAR g_confdel.
72              ENDIF.
73            ENDIF.
74            CLEAR g_delflag.
75            CLEAR p_ok.
76
77          WHEN 'P--' OR                     "top of list
78               'P-'  OR                     "previous page
79               'P+'  OR                     "next page
80               'P++'.                       "bottom of list
81            PERFORM compute_scrolling_in_tc USING p_tc_name
82                                                  l_ok.
83            CLEAR p_ok.
84     *     WHEN 'L--'.                       "total left
85     *       PERFORM FCODE_TOTAL_LEFT USING P_TC_NAME.
86     *
87     *     WHEN 'L-'.                        "column left
88     *       PERFORM FCODE_COLUMN_LEFT USING P_TC_NAME.
89     *
90     *     WHEN 'R+'.                        "column right
91     *       PERFORM FCODE_COLUMN_RIGHT USING P_TC_NAME.
92     *
93     *     WHEN 'R++'.                       "total right
94     *       PERFORM FCODE_TOTAL_RIGHT USING P_TC_NAME.
95     *
96          WHEN 'MARK'.                      "mark all filled lines
97            PERFORM fcode_tc_mark_lines USING p_tc_name
98                                              p_table_name
99                                              p_mark_name   .
100           CLEAR p_ok.
101
102         WHEN 'DMRK'.                      "demark all filled lines
103           PERFORM fcode_tc_demark_lines USING p_tc_name
104                                               p_table_name
105                                               p_mark_name .
106           CLEAR p_ok.
107
108    *     WHEN 'SASCEND'   OR
109    *          'SDESCEND'.                  "sort column
110    *       PERFORM FCODE_SORT_TC USING P_TC_NAME
111    *                                   l_ok.
112
113         WHEN 'FILTER'.
114           READ  TABLE tabctrl110-cols WITH  KEY selected = 'X' INTO
115               wa_tabctrl110_cols .
116           IF sy-subrc <> 0.
117             MESSAGE e030(zmm_oth).
118           ENDIF.
119           g_filname = wa_tabctrl110_cols-screen-name.
120           CALL SCREEN 150 STARTING AT 20 05 ENDING AT 80 10.
121
122    *       concatenate g_filname '=' g_filval into X separated by space.
123    *Loop at g_tabctrl110_itab into g_tabctrl110_wa.
124    *   exit.
125    *Endloop.
126
127    *       read table g_tabctrl110_itab with table key (g_filname) =
128    *(g_filval).
129    *       delete g_tabctrl110_itab where (X).
130    *       append lines of g_tabctrl110_itab to l_110itab
131    *                    where (g_filname+11) = g_filval.
132    *       loop at g_tabctrl110_itab into g_tabctrl110_wa
133    *            where (g_filname+11) = g_filval.
134    *       endloop.
135           CLEAR: p_ok,wa_tablctrl120_cols.
136
137         WHEN 'SORTU'.
138           g_order = 'ASCENDING'.
139           CASE zmm_cdhd_st-mtart.
140             WHEN 'ZSTO'.
141               PERFORM sort_sto USING g_order.
142               CLEAR: p_ok,wa_tabctrl110_cols.
143             WHEN 'ZSPR'.
144               PERFORM sort_spr USING g_order.
145               CLEAR: p_ok,wa_tablctrl120_cols.
146             WHEN 'ZCAP'.
147               PERFORM sort_cap USING g_order.
148               CLEAR: p_ok,wa_tablctrl130_cols.
149             WHEN 'ZDIS'.
150               PERFORM sort_dis USING g_order.
151               CLEAR: p_ok,wa_tablctrl140_cols.
152           ENDCASE.
153         WHEN 'SORTD'.
154           g_order = 'DESCENDING'.
155           CASE zmm_cdhd_st-mtart.
156             WHEN 'ZSTO'.
157               PERFORM sort_sto USING g_order.
158               CLEAR: p_ok,wa_tabctrl110_cols.
159             WHEN 'ZSPR'.
160               PERFORM sort_spr USING g_order.
161               CLEAR: p_ok,wa_tablctrl120_cols.
162             WHEN 'ZCAP'.
163               PERFORM sort_cap USING g_order.
164               CLEAR: p_ok,wa_tablctrl130_cols.
165             WHEN 'ZDIS'.
166               PERFORM sort_dis USING g_order.
167               CLEAR: p_ok,wa_tablctrl140_cols.
168           ENDCASE.
169       ENDCASE.
170
171     ENDFORM.                              " USER_OK_TC
172
173    *&---------------------------------------------------------------------*
174    *&      Form  FCODE_INSERT_ROW                                         *
175    *&---------------------------------------------------------------------*
176     FORM fcode_insert_row
177                   USING    p_tc_name           TYPE dynfnam
178                            p_table_name             .
179
180    *-BEGIN OF LOCAL DATA--------------------------------------------------*
181       DATA: l_itab110 LIKE g_tabctrl110_wa OCCURS 0,
182             l_itab120 LIKE g_tablctrl120_wa OCCURS 0,
183             l_itab130 LIKE g_tablctrl130_wa OCCURS 0,
184             l_itab140 LIKE g_tablctrl140_wa OCCURS 0.
185
186       DATA l_lines_name       LIKE feld-name.
187       DATA l_selline          LIKE sy-stepl.
188       DATA l_lastline         TYPE i.
189       DATA l_line             TYPE i.
190       DATA l_table_name       LIKE feld-name.
191       FIELD-SYMBOLS <tc>                 TYPE cxtab_control.
192       FIELD-SYMBOLS <table>              TYPE STANDARD TABLE.
193       FIELD-SYMBOLS <lines>  TYPE i.                           "#EC *
194
195    **-END OF LOCAL
196    *DATA----------------------------------------------------*
197    **********************************************************************
198    *   ASSIGN (P_TC_NAME) TO <TC>.
199    *
200    ** get the table, which belongs to the tc
201    **
202    *   CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
203    *   ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline
204    *
205    ** get looplines of TableControl
206    *   CONCATENATE 'G_' P_TC_NAME '_LINES' INTO L_LINES_NAME.
207    *   ASSIGN (L_LINES_NAME) TO <LINES>.
208    *
209    ** get current line
210    *   GET CURSOR LINE L_SELLINE.
211    *   if sy-subrc <> 0.                   " append line to table
212    *     l_selline = <tc>-lines + 1.
213    **&SPWIZARD: set top line and new cursor line
214    **
215    *     if l_selline > <lines>.
216    *       <tc>-top_line = l_selline - <lines> + 1 .
217    *       L_LINE = 1.
218    *     else.
219    *       <tc>-top_line = 1.
220    *       L_LINE = L_SELLINE.
221    *     endif.
222    *   else.                               " insert line into table
223    *     l_selline = <tc>-top_line + l_selline - 1.
224    *     l_lastline = <tc>-top_line + <lines> - 1.
225    *     IF L_LASTLINE <= <TC>-LINES.
226    *       <TC>-TOP_LINE = L_SELLINE.
227    *       L_LINE = 1.
228    *     ELSEIF <LINES> > <TC>-LINES.
229    *       <TC>-TOP_LINE = 1.
230    *       L_LINE = L_SELLINE.
231    *     ELSE.
232    *       <TC>-TOP_LINE = <TC>-LINES - <LINES> + 2 .
233    *       L_LINE = L_SELLINE - <TC>-TOP_LINE + 1.
234    *     ENDIF.
235    *   endif.
236    **&SPWIZARD: set new cursor line
237    **
238    **   l_line = l_selline - <tc>-top_line + 1.
239    ** insert initial line
240    *   INSERT INITIAL LINE INTO <TABLE> INDEX L_SELLINE.
241    *   <TC>-LINES = <TC>-LINES + 1.
242    ** set cursor
243    *   SET CURSOR LINE L_LINE.
244    ********************************************************
245    ********change/addition**********************************
246       CLEAR l_selline.
247       REFRESH:l_itab110,l_itab120,l_itab130,l_itab140.
248       ASSIGN (p_tc_name) TO <tc>.
249       CONCATENATE p_table_name '[]' INTO l_table_name. "table body
250       ASSIGN (l_table_name) TO <table>.
251    *Case zmm_cdhd_st-mtart.
252    * When 'ZSTO'.
253    *   Append lines of g_tabctrl110_itab to l_itab110.
254    *   Delete l_itab110 where srno = 0.
255    *   describe table l_itab110 lines l_selline.
256    * When 'ZSPR'.
257    *   Append lines of g_tablctrl120_itab to l_itab120.
258    *   Delete l_itab120 where srno = 0..
259    *   describe table l_itab120 lines l_selline.
260    * When 'ZCAP'.
261    *   Append lines of g_tablctrl130_itab to l_itab130.
262    *   Delete l_itab130 where srno = 0..
263    *   describe table l_itab130 lines l_selline.
264    *Endcase.
265    *l_selline = l_selline + 1.
266    *INSERT INITIAL LINE INTO <TABLE> INDEX L_SELLINE.
267       APPEND INITIAL LINE TO <table>.
268       <tc>-lines = <tc>-lines + 1.
269
270     ENDFORM.                              " FCODE_INSERT_ROW
271
272    *&---------------------------------------------------------------------*
273    *&      Form  FCODE_DELETE_ROW                                         *
274    *&---------------------------------------------------------------------*
275     FORM fcode_delete_row
276                   USING    p_tc_name           TYPE dynfnam
277                            p_table_name
278                            p_mark_name   .
279
280    *-BEGIN OF LOCAL DATA--------------------------------------------------*
281       DATA l_table_name       LIKE feld-name.
282
283       FIELD-SYMBOLS <tc>         TYPE cxtab_control.
284       FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
285       FIELD-SYMBOLS <wa>.
286       FIELD-SYMBOLS <mark_field>.
287    *-END OF LOCAL DATA----------------------------------------------------*
288
289       ASSIGN (p_tc_name) TO <tc>.
290
291    * get the table, which belongs to the tc                               *
292       CONCATENATE p_table_name '[]' INTO l_table_name. "table body
293       ASSIGN (l_table_name) TO <table>.                "not headerline
294
295    * delete marked lines                                                  *
296       DESCRIBE TABLE <table> LINES <tc>-lines.
297
298       LOOP AT <table> ASSIGNING <wa>.
299
300    *   access to the component 'FLAG' of the table header                 *
301         ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.
302
303         IF <mark_field> = 'X'.
304           DELETE <table> INDEX syst-tabix.
305           IF sy-subrc = 0.
306             <tc>-lines = <tc>-lines - 1.
307           ENDIF.
308         ENDIF.
309       ENDLOOP.
310
311     ENDFORM.                              " FCODE_DELETE_ROW
312
313    *&---------------------------------------------------------------------*
314    *&      Form  COMPUTE_SCROLLING_IN_TC
315    *&---------------------------------------------------------------------*
316    *       text
317    *----------------------------------------------------------------------*
318    *      -->P_TC_NAME  name of tablecontrol
319    *      -->P_OK       ok code
320    *----------------------------------------------------------------------*
321     FORM compute_scrolling_in_tc USING    p_tc_name
322                                           p_ok.
323    *-BEGIN OF LOCAL DATA--------------------------------------------------*
324       DATA l_tc_new_top_line     TYPE i.
325       DATA l_tc_name             LIKE feld-name.
326       DATA l_tc_lines_name       LIKE feld-name.
327       DATA l_tc_field_name       LIKE feld-name.
328
329       FIELD-SYMBOLS <tc>         TYPE cxtab_control.
330       FIELD-SYMBOLS <lines>      TYPE i.
331       DATA l_tc_itab_name        LIKE feld-name.
332       DATA l_totln               TYPE i.
333    *-END OF LOCAL DATA----------------------------------------------------*
334
335       ASSIGN (p_tc_name) TO <tc>.
336    * get looplines of TableControl
337       CONCATENATE 'G_' p_tc_name '_LINES' INTO l_tc_lines_name.
338       ASSIGN (l_tc_lines_name) TO <lines>.
339
340
341    * is no line filled?                                                   *
342       IF <tc>-lines = 0.
343    *   yes, ...                                                           *
344         l_tc_new_top_line = 1.
345       ELSE.
346    *   no, ...
347    ****Addition
348         CASE zmm_cdhd_st-mtart.
349           WHEN 'ZSTO'.
350             DESCRIBE TABLE g_tabctrl110_itab LINES l_totln.
351           WHEN 'ZSPR'.
352             DESCRIBE TABLE g_tablctrl120_itab LINES l_totln.
353           WHEN 'ZCAP'.
354             DESCRIBE TABLE g_tablctrl130_itab LINES l_totln.
355           WHEN 'ZDIS'.
356             DESCRIBE TABLE g_tablctrl140_itab LINES l_totln.
357         ENDCASE.
358    ****End
359         IF <tc> = tabctrl100.
360           CALL FUNCTION 'SCROLLING_IN_TABLE'
361             EXPORTING
362               entry_act      = <tc>-top_line
363               entry_from     = 1
364               entry_to       = <tc>-lines
365    *          ENTRY_TO       = l_totln
366    *          LAST_PAGE_FULL = ''
367               last_page_full = 'X'
368               loops          = <lines>
369               ok_code        = p_ok
370               overlapping    = 'X'
371             IMPORTING
372               entry_new      = l_tc_new_top_line
373             EXCEPTIONS
374    *          NO_ENTRY_OR_PAGE_ACT  = 01
375    *          NO_ENTRY_TO    = 02
376    *          NO_OK_CODE_OR_PAGE_GO = 03
377               OTHERS         = 0.
378         ELSE.
379           CALL FUNCTION 'SCROLLING_IN_TABLE'
380             EXPORTING
381               entry_act      = <tc>-top_line
382               entry_from     = 1
383    *          ENTRY_TO       = <TC>-LINES
384               entry_to       = l_totln
385               last_page_full = ''
386    *          LAST_PAGE_FULL = 'X'
387               loops          = <lines>
388               ok_code        = p_ok
389               overlapping    = 'X'
390             IMPORTING
391               entry_new      = l_tc_new_top_line
392             EXCEPTIONS
393    *          NO_ENTRY_OR_PAGE_ACT  = 01
394    *          NO_ENTRY_TO    = 02
395    *          NO_OK_CODE_OR_PAGE_GO = 03
396               OTHERS         = 0.
397         ENDIF.
398       ENDIF.
399
400    * get actual tc and column                                             *
401       GET CURSOR FIELD l_tc_field_name
402                  AREA  l_tc_name.
403
404       IF syst-subrc = 0.
405         IF l_tc_name = p_tc_name.
406    *     set actual column                                                *
407           SET CURSOR FIELD l_tc_field_name LINE 1.
408         ENDIF.
409       ENDIF.
410
411    * set the new top line                                                 *
412       <tc>-top_line = l_tc_new_top_line.
413
414
415     ENDFORM.                              " COMPUTE_SCROLLING_IN_TC
416
417    *&---------------------------------------------------------------------*
418    *&      Form  FCODE_TC_MARK_LINES
419    *&---------------------------------------------------------------------*
420    *       marks all TableControl lines
421    *----------------------------------------------------------------------*
422    *      -->P_TC_NAME  name of tablecontrol
423    *----------------------------------------------------------------------*
424     FORM fcode_tc_mark_lines USING p_tc_name
425                                    p_table_name
426                                    p_mark_name.
427    *-BEGIN OF LOCAL DATA--------------------------------------------------*
428       DATA l_table_name       LIKE feld-name.
429
430       FIELD-SYMBOLS <tc>         TYPE cxtab_control.
431       FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
432       FIELD-SYMBOLS <wa>.
433       FIELD-SYMBOLS <mark_field>.
434    *-END OF LOCAL DATA----------------------------------------------------*
435
436       ASSIGN (p_tc_name) TO <tc>.
437
438    * get the table, which belongs to the tc                               *
439       CONCATENATE p_table_name '[]' INTO l_table_name. "table body
440       ASSIGN (l_table_name) TO <table>.                "not headerline
441
442    * mark all filled lines                                                *
443       LOOP AT <table> ASSIGNING <wa>.
444
445    *   access to the component 'FLAG' of the table header                 *
446         ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.
447
448         <mark_field> = 'X'.
449       ENDLOOP.
450     ENDFORM.                                          "fcode_tc_mark_lines
451
452    *&---------------------------------------------------------------------*
453    *&      Form  FCODE_TC_DEMARK_LINES
454    *&---------------------------------------------------------------------*
455    *       demarks all TableControl lines
456    *----------------------------------------------------------------------*
457    *      -->P_TC_NAME  name of tablecontrol
458    *----------------------------------------------------------------------*
459     FORM fcode_tc_demark_lines USING p_tc_name
460                                      p_table_name
461                                      p_mark_name .
462    *-BEGIN OF LOCAL DATA--------------------------------------------------*
463       DATA l_table_name       LIKE feld-name.
464
465       FIELD-SYMBOLS <tc>         TYPE cxtab_control.
466       FIELD-SYMBOLS <table>      TYPE STANDARD TABLE.
467       FIELD-SYMBOLS <wa>.
468       FIELD-SYMBOLS <mark_field>.
469    *-END OF LOCAL DATA----------------------------------------------------*
470
471       ASSIGN (p_tc_name) TO <tc>.
472
473    * get the table, which belongs to the tc                               *
474       CONCATENATE p_table_name '[]' INTO l_table_name. "table body
475       ASSIGN (l_table_name) TO <table>.                "not headerline
476
477    * demark all filled lines                                              *
478       LOOP AT <table> ASSIGNING <wa>.
479
480    *   access to the component 'FLAG' of the table header                 *
481         ASSIGN COMPONENT p_mark_name OF STRUCTURE <wa> TO <mark_field>.
482
483         <mark_field> = space.
484       ENDLOOP.
485     ENDFORM.                                          "fcode_tc_mark_lines
486    *&---------------------------------------------------------------------*
487    *&      Form  fill_sttab
488    *&---------------------------------------------------------------------*
489    *       text
490    *----------------------------------------------------------------------*
491    *  -->  p1        text
492    *  <--  p2        text
493    *----------------------------------------------------------------------*
494     FORM fill_sttab.
495       REFRESH it_tab1.
496
497       IF dynnr IS INITIAL.
498         MOVE 'CR_MATCODE' TO wa_tab-fcode.
499         APPEND wa_tab TO it_tab1.
500         MOVE 'CHECK' TO wa_tab-fcode.
501         APPEND wa_tab TO it_tab1.
502       ENDIF.
503
504
505       IF g_mode =  'CRE'.
506         MOVE 'CREATE' TO wa_tab-fcode.
507         APPEND wa_tab TO it_tab1.
508         MOVE 'CHANGE' TO wa_tab-fcode.
509         APPEND wa_tab TO it_tab1.
510         MOVE 'DELETE' TO wa_tab-fcode.
511         APPEND wa_tab TO it_tab1.
512         MOVE 'DISPLAY' TO wa_tab-fcode.
513         APPEND wa_tab TO it_tab1.
514         MOVE 'RELEASE' TO wa_tab-fcode.
515         APPEND wa_tab TO it_tab1.
516         MOVE 'CR_MATCODE' TO wa_tab-fcode.
517         APPEND wa_tab TO it_tab1.
518
519         MOVE 'APPROVE' TO wa_tab-fcode.
520         APPEND wa_tab TO it_tab1.
521
522       ELSEIF g_mode = 'CHA' .
523         MOVE 'CREATE' TO wa_tab-fcode.
524         APPEND wa_tab TO it_tab1.
525         MOVE 'DELETE' TO wa_tab-fcode.
526         APPEND wa_tab TO it_tab1.
527         MOVE 'DISPLAY' TO wa_tab-fcode.
528         APPEND wa_tab TO it_tab1.
529         MOVE 'RELEASE' TO wa_tab-fcode.
530         APPEND wa_tab TO it_tab1.
531
532         MOVE 'APPROVE' TO wa_tab-fcode.
533         APPEND wa_tab TO it_tab1.
534
535         IF dynnr = '0101'.
536           MOVE 'CR_MATCODE' TO wa_tab-fcode.
537           APPEND wa_tab TO it_tab1.
538
539           MOVE 'CHECK' TO wa_tab-fcode.
540           APPEND wa_tab TO it_tab1.
541         ENDIF.
542
543       ELSEIF g_mode = 'DEL'.
544         MOVE 'CREATE' TO wa_tab-fcode.
545         APPEND wa_tab TO it_tab1.
546         MOVE 'CHANGE' TO wa_tab-fcode.
547         APPEND wa_tab TO it_tab1.
548         MOVE 'DISPLAY' TO wa_tab-fcode.
549         APPEND wa_tab TO it_tab1.
550         MOVE 'DELETE' TO wa_tab-fcode.
551         APPEND wa_tab TO it_tab1.
552         MOVE 'RELEASE' TO wa_tab-fcode.
553         APPEND wa_tab TO it_tab1.
554         MOVE 'CR_MATCODE' TO wa_tab-fcode.
555         APPEND wa_tab TO it_tab1.
556
557         MOVE 'APPROVE' TO wa_tab-fcode.
558         APPEND wa_tab TO it_tab1.
559         MOVE 'CHECK' TO wa_tab-fcode.
560         APPEND wa_tab TO it_tab1.
561
562       ELSEIF g_mode = 'DIS'.
563         MOVE 'CREATE' TO wa_tab-fcode.
564         APPEND wa_tab TO it_tab1.
565         MOVE 'CHANGE' TO wa_tab-fcode.
566         APPEND wa_tab TO it_tab1.
567         MOVE 'DELETE' TO wa_tab-fcode.
568         APPEND wa_tab TO it_tab1.
569         MOVE 'RELEASE' TO wa_tab-fcode.
570         APPEND wa_tab TO it_tab1.
571         MOVE 'CR_MATCODE' TO wa_tab-fcode.
572         APPEND wa_tab TO it_tab1.
573
574         MOVE 'APPROVE' TO wa_tab-fcode.
575         APPEND wa_tab TO it_tab1.
576         MOVE 'CHECK' TO wa_tab-fcode.
577         APPEND wa_tab TO it_tab1.
578
579       ELSEIF g_mode = 'REL'.
580         MOVE 'CREATE' TO wa_tab-fcode.
581         APPEND wa_tab TO it_tab1.
582         MOVE 'CHANGE' TO wa_tab-fcode.
583         APPEND wa_tab TO it_tab1.
584         MOVE 'DELETE' TO wa_tab-fcode.
585         APPEND wa_tab TO it_tab1.
586         MOVE 'DISPLAY' TO wa_tab-fcode.
587         APPEND wa_tab TO it_tab1.
588         MOVE 'CR_MATCODE' TO wa_tab-fcode.
589         APPEND wa_tab TO it_tab1.
590
591         MOVE 'APPROVE' TO wa_tab-fcode.
592         APPEND wa_tab TO it_tab1.
593         MOVE 'CHECK' TO wa_tab-fcode.
594         APPEND wa_tab TO it_tab1.
595
596       ELSEIF g_mode = 'APR'.
597         MOVE 'CREATE' TO wa_tab-fcode.
598         APPEND wa_tab TO it_tab1.
599         MOVE 'CHANGE' TO wa_tab-fcode.
600         APPEND wa_tab TO it_tab1.
601         MOVE 'DELETE' TO wa_tab-fcode.
602         APPEND wa_tab TO it_tab1.
603         MOVE 'DISPLAY' TO wa_tab-fcode.
604         APPEND wa_tab TO it_tab1.
605         MOVE 'CR_MATCODE' TO wa_tab-fcode.
606         APPEND wa_tab TO it_tab1.
607         MOVE 'RELEASE' TO wa_tab-fcode.
608         APPEND wa_tab TO it_tab1.
609         MOVE 'CHECK' TO wa_tab-fcode.
610         APPEND wa_tab TO it_tab1.
611
612       ENDIF.
613
614       IF sy-tcode = 'ZCODG'.
615         CLEAR wa_tab.
616         REFRESH it_tab1.
617         MOVE 'CREATE' TO wa_tab-fcode.
618         APPEND wa_tab TO it_tab1.
619         MOVE 'CHANGE' TO wa_tab-fcode.
620         APPEND wa_tab TO it_tab1.
621         MOVE 'DELETE' TO wa_tab-fcode.
622         APPEND wa_tab TO it_tab1.
623         MOVE 'DISPLAY' TO wa_tab-fcode.
624         APPEND wa_tab TO it_tab1.
625         MOVE 'APPROVE' TO wa_tab-fcode.
626         APPEND wa_tab TO it_tab1.
627         MOVE 'RELEASE' TO wa_tab-fcode.
628         APPEND wa_tab TO it_tab1.
629         MOVE 'CHECK' TO wa_tab-fcode.
630         APPEND wa_tab TO it_tab1.
631       ENDIF.
632
633       IF sy-tcode = 'ZMATRESERR'.
634         CLEAR wa_tab.
635         REFRESH it_tab1.
636         MOVE 'CREATE' TO wa_tab-fcode.
637         APPEND wa_tab TO it_tab1.
638         MOVE 'CHANGE' TO wa_tab-fcode.
639         APPEND wa_tab TO it_tab1.
640         MOVE 'DELETE' TO wa_tab-fcode.
641         APPEND wa_tab TO it_tab1.
642         MOVE 'APPROVE' TO wa_tab-fcode.
643         APPEND wa_tab TO it_tab1.
644         MOVE 'RELEASE' TO wa_tab-fcode.
645         APPEND wa_tab TO it_tab1.
646         MOVE 'CHECK' TO wa_tab-fcode.
647         APPEND wa_tab TO it_tab1.
648         MOVE 'CHANGE_E' TO wa_tab-fcode.
649         APPEND wa_tab TO it_tab1.
650         MOVE 'CR_MATCODE' TO wa_tab-fcode.
651         APPEND wa_tab TO it_tab1.
652       ENDIF.
653
654
655       IF sy-tcode = 'ZMATRESERR' AND NOT sy-dynnr IS INITIAL AND NOT
656                                          zmm_cdhd_st-reqno IS INITIAL.
657         CLEAR wa_tab.
658         REFRESH it_tab1.
659         MOVE 'CREATE' TO wa_tab-fcode.
660         APPEND wa_tab TO it_tab1.
661         MOVE 'CHANGE' TO wa_tab-fcode.
662         APPEND wa_tab TO it_tab1.
663         MOVE 'DELETE' TO wa_tab-fcode.
664         APPEND wa_tab TO it_tab1.
665         MOVE 'APPROVE' TO wa_tab-fcode.
666         APPEND wa_tab TO it_tab1.
667         MOVE 'RELEASE' TO wa_tab-fcode.
668         APPEND wa_tab TO it_tab1.
669         MOVE 'CHECK' TO wa_tab-fcode.
670         APPEND wa_tab TO it_tab1.
671    *     move 'CHANGE_E' to wa_tab-fcode.
672    *     append wa_tab to it_tab1.
673         MOVE 'CR_MATCODE' TO wa_tab-fcode.
674         APPEND wa_tab TO it_tab1.
675       ENDIF.
676
677     ENDFORM.                    " fill_sttab
678    *&---------------------------------------------------------------------*
679    *&      Form  fill_mattyp_itemdt
680    *&---------------------------------------------------------------------*
681    *       text
682    *----------------------------------------------------------------------*
683    *  -->  p1        text
684    *  <--  p2        text
685    *----------------------------------------------------------------------*
686     FORM fill_mattyp_itemdt.
687
688       DATA l_cdhd LIKE zmm_cdhd.
689
690       IF g_mode = 'CRE'.
691         PERFORM set_dynnr USING zmm_cdhd_st-mtart.
692       ELSE.
693         SELECT SINGLE * INTO l_cdhd FROM zmm_cdhd
694                WHERE reqno = zmm_cdhd_st-reqno.
695         IF sy-subrc = 0.
696           PERFORM set_dynnr USING l_cdhd-mtart.
697         ELSE.
698    *       message e003(zmm_oth) with zmm_cdhd_st-reqno.
699         ENDIF.
700    *
701         IF l_cdhd-mtart = 'ZSTO'.
702           SELECT SINGLE * FROM zmm_cditem
703             INTO CORRESPONDING FIELDS OF zmm_cditem
704              WHERE reqno = zmm_cdhd_st-reqno
705              AND   oth1  = 'X'.
706           IF sy-subrc = 0.
707             g_techapr_visible = 'Y'.
708           ENDIF.
709         ENDIF.
710       ENDIF.
711     ENDFORM.                    " fill_mattyp_itemdt
712    *&---------------------------------------------------------------------*
713    *&      Form  chng_attr_100
714    *&---------------------------------------------------------------------*
715    *       text
716    *----------------------------------------------------------------------*
717    *  -->  p1        text
718    *  <--  p2        text
719    *----------------------------------------------------------------------*
720     FORM chng_attr_100.
721       IF g_mode = 'CRE'.
722         LOOP AT SCREEN.
723           IF screen-name = 'ZMM_CDHD_ST-REQNO'.
724             screen-input = 0.
725             MODIFY SCREEN.
726           ENDIF.
727         ENDLOOP.
728       ENDIF.
729     ENDFORM.                    " chng_attr_100
730    *&---------------------------------------------------------------------*
731    *&      Form  SELECT_HELP_DATA
732    *&---------------------------------------------------------------------*
733     FORM select_mat_data USING
734                          partno LIKE zmm_cditem-user_desc
735                          matgp LIKE zmm_modifier-matgrp
736                          mtart LIKE mara-mtart
737                          CHANGING sel_flag.
738
739       DATA : l_lines LIKE sy-index.
740       DATA : l_srno  LIKE sy-index.
741       DATA : l_len   LIKE sy-index.
742       DATA : l_len1  LIKE sy-index.
743       DATA : l_len2  LIKE sy-index.
744       DATA : l_check.
745       DATA : g_partno1 LIKE zmm_cditem-user_desc.
746       DATA : g_partno2 LIKE zmm_cditem-user_desc.
747
748       DATA : g_capcode_no   LIKE ausp-atinn.
749       DATA : g_modelcode_no LIKE ausp-atinn.
750
751       DESCRIBE TABLE ist_srchlp LINES l_lines.
752
753       IF g_lineno <> g_curr_line.
754         l_lines = 0.
755       ENDIF.
756
757       TRANSLATE desc TO UPPER CASE.
758
759       IF mtart = 'ZSPR'  .
760
761         IF  l_lines = 0  OR field1 = 'ZMM_CDITEM-PARTNO'.
762
763           SELECT a~maktg a~matnr b~mfrnr b~meins b~mfrpn b~wrkst
764           INTO CORRESPONDING FIELDS OF TABLE ist_srchlp
765           FROM makt AS a JOIN mara AS b ON a~matnr = b~matnr
766           WHERE b~mfrpn LIKE partno AND
767           ( b~mtart = mtart OR b~mtart = 'ZMPN' ). "Anil Gupta 17-06-05
768
769           IF sy-subrc = 0.
770    * Added by cab_uniyal to get capital code and model no in
771    * spares running search help
772             SELECT atinn FROM cabn INTO g_capcode_no UP TO 1 ROWS
773     WHERE atnam = 'Z_ONGC_CAPCODE'
774     ORDER BY PRIMARY KEY .
775             ENDSELECT.
776             IF sy-subrc <> 0.
777               g_capcode_no = ''.
778             ENDIF.
779             SELECT atinn FROM cabn INTO g_modelcode_no UP TO 1 ROWS
780     WHERE atnam = 'Z_ONGC_MODELCODE'
781     ORDER BY PRIMARY KEY .
782             ENDSELECT.
783             IF sy-subrc <> 0.
784               g_modelcode_no = ''.
785             ENDIF.
786
787             LOOP AT ist_srchlp INTO wa_srchlp.
788               IF g_capcode_no <> ''.
789                 SELECT atwrt FROM ausp INTO wa_srchlp-atwrt UP TO 1 ROWS
790     WHERE objek = wa_srchlp-matnr AND atinn = g_capcode_no
791     ORDER BY PRIMARY KEY .
792                 ENDSELECT.
793
794                 MODIFY  ist_srchlp FROM wa_srchlp INDEX sy-tabix
795                 TRANSPORTING atwrt.
796               ENDIF.
797               IF g_modelcode_no <> ''.
798                 SELECT atwrt FROM ausp INTO wa_srchlp-mdlno UP TO 1 ROWS
799     WHERE objek = wa_srchlp-matnr AND atinn = g_modelcode_no
800     ORDER BY PRIMARY KEY .
801                 ENDSELECT.
802
803                 MODIFY ist_srchlp FROM wa_srchlp INDEX sy-tabix
804                 TRANSPORTING mdlno.
805               ENDIF.
806             ENDLOOP.
807
808           ENDIF.  "For sy-subrc = 0.
809
810
811         ELSEIF field1 = 'ZMM_CDITEM-DESC1'.
812
813           SELECT a~maktg a~matnr b~meins b~mfrpn b~wrkst
814           INTO CORRESPONDING FIELDS OF TABLE ist_srchlp
815           FROM makt AS a
816           JOIN mara AS b
817           ON a~matnr = b~matnr
818           WHERE a~maktg LIKE desc
819           AND   b~mtart = mtart
820           AND   b~mfrpn LIKE partno
821    **Addition***********************************************
822           AND b~mstae = ''.
823    **End****************************************************
824           IF sy-subrc = 0.
825    *       sel_flag = '0'.
826           ENDIF.
827         ENDIF.
828    *      if check_flag2 <> 'X'.
829         PERFORM change_partno1 CHANGING g_partno1 g_partnoc.
830         l_len1 = strlen( g_partno1 ).
831         LOOP AT ist_srchlp INTO wa_srchlp.
832           PERFORM change_partno2 CHANGING g_partno2 wa_srchlp-mfrpn.
833           l_len2 = strlen( g_partno2 ).
834           SEARCH g_partno2 FOR g_partno1.
835           IF sy-subrc = 0 AND l_len1 = l_len2.
836           ELSE.
837             DELETE ist_srchlp.
838           ENDIF.
839         ENDLOOP.
840       ENDIF.                " For matty = ZSPR
841
842       IF mtart = 'ZSTO'.
843
844         IF l_lines = 0 OR sel_flag = '2' OR sel_flag = '3' OR sel_flag = '4'
845                          OR sel_flag = '5'.
846    *       if not matgp is initial.
847    *         select a~MAKTG a~MATNR b~meins b~mfrpn b~wrkst
848    *         into corresponding fields of table ist_srchlp
849    *         from makt as A join mara as B on a~matnr = b~matnr
850    *        where a~maktg like desc and b~mtart = mtart and b~matkl = matgp
851    *.
852    *       else.
853           SELECT a~maktg a~matnr b~meins b~mfrpn b~wrkst
854           INTO CORRESPONDING FIELDS OF TABLE ist_srchlp
855           FROM makt AS a
856           JOIN mara AS b
857           ON a~matnr = b~matnr
858           WHERE ( a~maktg LIKE desc OR b~wrkst <> '' )
859                 AND b~mtart = mtart
860    **Addition***********************************************
861                 AND b~mstae = ''.
862    **End****************************************************
863    *       endif.
864         ENDIF.
865
866         IF sy-subrc = 0.
867
868           sel_flag = '1'.
869
870         ENDIF.
871
872       ENDIF.
873
874
875       IF mtart = 'ZCAP'.
876
877         IF l_lines = 0 OR sel_flag = '2' OR sel_flag = '3' OR sel_flag = '4'
878                          OR sel_flag = '5'.
879           SELECT a~maktg a~matnr b~meins b~mfrpn b~wrkst
880           INTO CORRESPONDING FIELDS OF TABLE ist_srchlp
881           FROM makt AS a
882           JOIN mara AS b
883           ON a~matnr = b~matnr
884           WHERE ( a~maktg LIKE desc OR b~wrkst <> '' )
885           AND b~mtart = mtart
886    **Addition***********************************************
887           AND b~mstae = ''.
888    **End****************************************************
889
890         ENDIF.
891
892         IF sy-subrc = 0.
893
894           sel_flag = '1'.
895
896         ENDIF.
897
898       ENDIF.
899
900       IF mtart = 'ZDIS'.
901
902         IF l_lines = 0 OR sel_flag = '2' OR sel_flag = '3' OR sel_flag = '4'
903                          OR sel_flag = '5'.
904           SELECT a~maktg a~matnr b~meins b~mfrpn b~wrkst
905           INTO CORRESPONDING FIELDS OF TABLE ist_srchlp
906           FROM makt AS a
907           JOIN mara AS b
908           ON a~matnr = b~matnr
909           WHERE ( a~maktg LIKE desc OR b~wrkst LIKE desc )
910           AND b~mtart = mtart
911    **Addition***********************************************
912           AND b~mstae = ''.
913    **End****************************************************
914
915         ENDIF.
916
917         IF sy-subrc = 0.
918
919           sel_flag = '1'.
920
921         ENDIF.
922
923       ENDIF.
924
925       LOOP AT ist_srchlp INTO wa_srchlp.
926
927    *   l_srno = l_srno + 1.
928    *
929    *   wa_srchlp-srno = l_srno.
930
931         l_len = strlen( wa_srchlp-maktg ).
932
933    *    concatenate wa_srchlp-maktg+0(39) wa_srchlp-wrkst into
934    *                wa_srchlp-maktx.
935         l_len = l_len - 1.
936         l_check = wa_srchlp-maktg+l_len(1).
937         IF l_check = '*'.
938           CONCATENATE wa_srchlp-maktg+0(l_len) wa_srchlp-wrkst INTO
939           wa_srchlp-maktx.
940         ELSE.
941           MOVE wa_srchlp-maktg TO wa_srchlp-maktx.
942         ENDIF.
943
944         TRANSLATE wa_srchlp-maktx TO UPPER CASE.
945
946         IF NOT desc11 IS INITIAL.
947
948           SEARCH wa_srchlp-maktx FOR desc11.
949
950           IF sy-subrc = 0.
951
952             l_srno = l_srno + 1.
953
954             wa_srchlp-srno = l_srno.
955
956             MODIFY ist_srchlp FROM wa_srchlp.
957
958           ELSE.
959
960             DELETE ist_srchlp.
961
962           ENDIF.
963
964         ELSE.
965
966           l_srno = l_srno + 1.
967
968           wa_srchlp-srno = l_srno.
969
970           MODIFY ist_srchlp FROM wa_srchlp.
971
972         ENDIF.
973
974       ENDLOOP.
975
976     ENDFORM.
977
978    ***********************************
979    * Form SELECT_HELP_DATA
980    ***********************************
981
982     FORM select_help_data USING VALUE(partno) LIKE zmm_cditem-user_desc
983                                 VALUE(desc1) LIKE zmm_cditem-desc1
984                                 VALUE(desc2) LIKE zmm_cditem-desc2
985                                 VALUE(desc3) LIKE zmm_cditem-desc3
986                                 VALUE(desc4) LIKE zmm_cditem-desc4
987                                 VALUE(desc5) LIKE zmm_cditem-user_desc
988                                 VALUE(matgp) LIKE zmm_modifier-matgrp
989                                 VALUE(matty) LIKE zmm_cdhd_st-mtart
990                                 CHANGING sel_flag.
991
992
993       DATA : l_srno TYPE i.
994
995       IF NOT desc1 IS INITIAL OR NOT partno IS INITIAL.
996         CONCATENATE '%' desc1 '%' INTO desc.
997         PERFORM select_mat_data USING partno matgp matty CHANGING sel_flag.
998         CLEAR : wa_srchlp.
999       ENDIF.
1000
1001      CLEAR l_srno.
1002      IF NOT desc2 IS INITIAL.
1003
1004        LOOP AT ist_srchlp INTO wa_srchlp.
1005
1006          TRANSLATE desc2 TO UPPER CASE.
1007
1008          SEARCH wa_srchlp-maktx FOR desc2.
1009
1010          IF sy-subrc <> 0.
1011            DELETE ist_srchlp .
1012          ELSE.
1013            l_srno = l_srno + 1.
1014            wa_srchlp-srno = l_srno.
1015            MODIFY ist_srchlp FROM wa_srchlp.
1016          ENDIF.
1017
1018        ENDLOOP.
1019
1020        sel_flag = '2'.
1021
1022      ENDIF.
1023
1024      CLEAR l_srno.
1025
1026      IF NOT desc3 IS INITIAL.
1027
1028        LOOP AT ist_srchlp INTO wa_srchlp.
1029
1030          TRANSLATE desc3 TO UPPER CASE.
1031
1032          SEARCH wa_srchlp-maktx FOR desc3.
1033
1034          IF sy-subrc <> 0.
1035            DELETE ist_srchlp .
1036          ELSE.
1037            l_srno = l_srno + 1.
1038            wa_srchlp-srno = l_srno.
1039            MODIFY ist_srchlp FROM wa_srchlp.
1040
1041          ENDIF.
1042
1043        ENDLOOP.
1044
1045        sel_flag = '3'.
1046
1047      ENDIF.
1048
1049      CLEAR l_srno.
1050
1051      IF NOT desc4 IS INITIAL.
1052
1053        LOOP AT ist_srchlp INTO wa_srchlp.
1054
1055          TRANSLATE desc4 TO UPPER CASE.
1056
1057          SEARCH wa_srchlp-maktx FOR desc4.
1058
1059          IF sy-subrc <> 0.
1060            DELETE ist_srchlp .
1061          ELSE.
1062            l_srno = l_srno + 1.
1063            wa_srchlp-srno = l_srno.
1064            MODIFY ist_srchlp FROM wa_srchlp.
1065
1066          ENDIF.
1067
1068        ENDLOOP.
1069
1070        sel_flag = '4'.
1071
1072      ENDIF.
1073
1074      CLEAR l_srno.
1075
1076      IF NOT desc5 IS INITIAL.
1077
1078        LOOP AT ist_srchlp INTO wa_srchlp.
1079
1080          TRANSLATE desc5 TO UPPER CASE.
1081
1082          SEARCH wa_srchlp-maktx FOR desc5.
1083
1084          IF sy-subrc <> 0.
1085            DELETE ist_srchlp .
1086          ELSE.
1087            l_srno = l_srno + 1.
1088            wa_srchlp-srno = l_srno.
1089            MODIFY ist_srchlp FROM wa_srchlp.
1090
1091          ENDIF.
1092
1093        ENDLOOP.
1094
1095        sel_flag = '5'.
1096
1097      ENDIF.
1098
1099
1100    ENDFORM.                    " SELECT_HELP_DATA
1101   *&---------------------------------------------------------------------*
1102   *&      Form  Gen_request
1103   *&---------------------------------------------------------------------*
1104   *       text
1105   *----------------------------------------------------------------------*
1106   *  -->  p1        text
1107   *  <--  p2        text
1108   *----------------------------------------------------------------------*
1109    FORM Save_request.
1110      PERFORM check_other.
1111      IF g_mode = 'CRE'.
1112        PERFORM gen_request.
1113        CASE  zmm_cdhd_st-mtart.
1114          WHEN 'ZSTO'.
1115            l_MATTYPE = 'S'.
1116          WHEN 'ZSPR'.
1117            l_MATTYPE = 'P'.
1118          WHEN 'ZCAP'.
1119            l_MATTYPE = 'C'.
1120          WHEN 'ZDIS'.
1121            l_MATTYPE = 'D'.
1122        ENDCASE.
1123   *
1124        zmm_cdhd_st-reqno = g_reqno.
1125        g_request_no = g_reqno.
1126        PERFORM Insert_into_tab.
1127        MESSAGE i005(zmm_oth) WITH g_request_no.
1128      ELSEIF g_mode = 'CHA' OR g_mode = 'CHE'.     "OR  g_mode = 'APR'.
1129        g_request_no = zmm_cdhd_st-reqno.
1130        PERFORM prepare_update."on commit.
1131        COMMIT WORK.
1132        MESSAGE i006(zmm_oth) WITH g_request_no.
1133        IF g_lock = 'Y'.
1134          PERFORM unlock_req.
1135          CLEAR g_lock.
1136        ENDIF.
1137        PERFORM clear_var.
1138      ELSEIF g_mode = 'DEL'.
1139        PERFORM prepare_delete .
1140        PERFORM clear_var.
1141      ELSEIF g_mode = 'REL'.
1142        IF zmm_cdhd_st-status_flag = ''.
1143          MESSAGE i024(zmm_oth) WITH 'Release'.
1144        ELSE.
1145          CALL SCREEN 103 STARTING AT 10 10 ENDING AT 70 15.
1146        ENDIF.
1147
1148   *    Perform update_release.
1149      ELSEIF g_mode = 'APR'.
1150   **Note - Status flag is not pertaining to Request status, for that
1151   **purpose flag is Reqcl ( Request Status ).
1152        IF zmm_cdhd_st-status_flag = ''.
1153          MESSAGE i026(zmm_oth).
1154          LEAVE TO SCREEN 0.
1155        ELSEIF zmm_cdhd_st-approve_mrp = ''.
1156          MESSAGE i024(zmm_oth) WITH 'APPROVAL MRP CTRL'.
1157        ELSEIF g_user = 'M'.
1158          CALL SCREEN 103 STARTING AT 10 10 ENDING AT 70 15.
1159        ELSEIF zmm_cdhd_st-approve_L2 = '' AND g_user = 'L'.
1160          MESSAGE i024(zmm_oth) WITH 'L2 APPROVAL'.
1161        ELSEIF zmm_cdhd_st-approve_L2 = 'X' AND g_user = 'L'.
1162          PERFORM update_approval.
1163        ENDIF.
1164      ELSEIF g_mode = 'CRC'.
1165        g_request_no = zmm_cdhd_st-reqno.
1166        PERFORM update_codes.
1167        COMMIT WORK.
1168        IF zmm_cdhd_st-reqcl <> 'C'.
1169          PERFORM check_reqstatus.
1170        ENDIF.
1171        MOVE-CORRESPONDING zmm_cdhd_st TO Zmm_cdhd.
1172        MODIFY zmm_cdhd FROM zmm_cdhd.
1173        COMMIT WORK.
1174        MESSAGE i006(zmm_oth) WITH g_request_no.
1175        PERFORM send_mail_to_reqn.
1176      ENDIF.
1177   ***********end**************************************
1178      IF sy-tcode = 'ZCODG'.
1179        IF g_mode = ''.
1180          IF zmm_cdhd_st-reqcl <> 'C'.
1181            PERFORM check_reqstatus.
1182          ENDIF.
1183          MOVE-CORRESPONDING zmm_cdhd_st TO Zmm_cdhd.
1184          MODIFY zmm_cdhd FROM zmm_cdhd.
1185   ************************************************************
1186   ****Saving the long text.                              *****
1187   ************************************************************
1188   ******Header(Correspondence)********************************
1189          PERFORM prepare_update.
1190          COMMIT WORK.
1191          PERFORM send_mail_to_reqn.
1192          MESSAGE i006(zmm_oth) WITH g_request_no.
1193        ENDIF.
1194      ENDIF.
1195    ENDFORM.                    " Gen_request
1196   *&---------------------------------------------------------------------*
1197   *&      Form  gen_request
1198   *&---------------------------------------------------------------------*
1199   *       text
1200   *----------------------------------------------------------------------*
1201   *  -->  p1        text
1202   *  <--  p2        text
1203   *----------------------------------------------------------------------*
1204    FORM gen_request.
1205
1206      CALL FUNCTION 'NUMBER_GET_NEXT'
1207        EXPORTING
1208          nr_range_nr = '01'
1209          object      = 'ZMMCODREQ'
1210        IMPORTING
1211          number      = g_reqno.
1212      IF sy-subrc <> 0.
1213      ENDIF.
1214
1215    ENDFORM.                    " gen_request
1216   *&---------------------------------------------------------------------*
1217   *&      Form  Insert_into_tab
1218   *&---------------------------------------------------------------------*
1219   *       text
1220   *----------------------------------------------------------------------*
1221   *  -->  p1        text
1222   *  <--  p2        text
1223   *----------------------------------------------------------------------*
1224    FORM Insert_into_tab.
1225      IF g_mode = 'CRE'.
1226        MOVE sy-datum TO zmm_cdhd_st-reqdate.
1227        MOVE sy-uname TO zmm_cdhd_st-reqcpf.
1228        MOVE 'N' TO zmm_cdhd_st-reqcl.
1229        MOVE-CORRESPONDING zmm_cdhd_st TO Zmm_cdhd.
1230        INSERT INTO zmm_cdhd VALUES zmm_cdhd.
1231        IF sy-subrc = 0.
1232          MESSAGE i001(zmm_oth) WITH zmm_cdhd-reqno.
1233        ENDIF.
1234      ELSEIF g_mode = 'CHA'.
1235        IF matgen_flag = 'X'.
1236          MOVE matgen_flag TO zmm_cdhd_st-matgen_flag.
1237          MOVE sy-datum TO zmm_cdhd_st-MATGEN_date.
1238        ENDIF.
1239        MOVE-CORRESPONDING zmm_cdhd_st TO Zmm_cdhd.
1240        MODIFY zmm_cdhd FROM zmm_cdhd.
1241      ENDIF.
1242   **
1243      REFRESH ist_zmm_cditem.
1244      CASE L_mattype.
1245        WHEN 'S'.
1246          LOOP AT g_TABCTRL110_itab INTO g_TABCTRL110_wa.
1247            IF NOT g_TABCTRL110_wa-desc_fin IS INITIAL.
1248
1249              IF sy-tcode = 'ZMATRESERR' AND g_TABCTRL110_wa-comp_flg = 'E'.
1250                g_TABCTRL110_wa-comp_flg = ''.
1251              ENDIF.
1252
1253              MOVE-CORRESPONDING g_TABCTRL110_wa TO wa_zmm_cditem.
1254              MOVE zmm_cdhd_st-reqno TO wa_zmm_cditem-reqno.
1255              MOVE sy-datum TO wa_zmm_cditem-coddt.
1256              MOVE sy-uname TO wa_zmm_cditem-codby.
1257              MOVE g_TABCTRL110_wa-matgp TO wa_zmm_cditem-matgp.
1258              APPEND wa_zmm_cditem TO ist_zmm_cditem.
1259            ELSE.
1260              EXIT.
1261            ENDIF.
1262          ENDLOOP.
1263        WHEN 'P'.
1264          LOOP AT g_TABLCTRL120_itab INTO g_TABLCTRL120_wa.
1265            IF NOT g_TABLCTRL120_wa-desc_fin IS INITIAL.
1266              IF sy-tcode = 'ZMATRESERR' AND g_TABLCTRL120_wa-comp_flg = 'E'.
1267                g_TABLCTRL120_wa-comp_flg = ''.
1268              ENDIF.
1269              MOVE-CORRESPONDING g_TABLCTRL120_wa TO wa_zmm_cditem.
1270              MOVE zmm_cdhd_st-reqno TO wa_zmm_cditem-reqno.
1271              MOVE sy-datum TO wa_zmm_cditem-coddt.
1272              MOVE sy-uname TO wa_zmm_cditem-codby.
1273              MOVE g_TABLCTRL120_wa-matgp TO wa_zmm_cditem-matgp.
1274              APPEND wa_zmm_cditem TO ist_zmm_cditem.
1275            ELSE.
1276              EXIT.
1277            ENDIF.
1278          ENDLOOP.
1279        WHEN 'C'.
1280          LOOP AT g_TABLCTRL130_itab INTO g_TABLCTRL130_wa.
1281            IF NOT g_TABLCTRL130_wa-desc_fin IS INITIAL.
1282              IF sy-tcode = 'ZMATRESERR' AND g_TABLCTRL130_wa-comp_flg = 'E'.
1283                g_TABLCTRL130_wa-comp_flg = ''.
1284              ENDIF.
1285
1286              MOVE-CORRESPONDING g_TABLCTRL130_wa TO wa_zmm_cditem.
1287              MOVE zmm_cdhd_st-reqno TO wa_zmm_cditem-reqno.
1288              MOVE sy-datum TO wa_zmm_cditem-coddt.
1289              MOVE sy-uname TO wa_zmm_cditem-codby.
1290   *           move g_TABLCTRL130_wa-matgp to wa_zmm_cditem-matgp.
1291              APPEND wa_zmm_cditem TO ist_zmm_cditem.
1292            ELSE.
1293              EXIT.
1294            ENDIF.
1295          ENDLOOP.
1296        WHEN 'D'.
1297          LOOP AT g_TABLCTRL140_itab INTO g_TABLCTRL140_wa.
1298            IF NOT g_TABLCTRL140_wa-desc_fin IS INITIAL.
1299              MOVE-CORRESPONDING g_TABLCTRL140_wa TO wa_zmm_cditem.
1300              MOVE zmm_cdhd_st-reqno TO wa_zmm_cditem-reqno.
1301              MOVE sy-datum TO wa_zmm_cditem-coddt.
1302              MOVE sy-uname TO wa_zmm_cditem-codby.
1303   *           move g_TABLCTRL140_wa-matgp to wa_zmm_cditem-matgp.
1304              APPEND wa_zmm_cditem TO ist_zmm_cditem.
1305            ELSE.
1306              EXIT.
1307            ENDIF.
1308          ENDLOOP.
1309      ENDCASE.
1310
1311   *   Insert ZMM_CDITEM from table ist_zmm_cditem.
1312   ************************************************************
1313   ****Saving the long text.                              *****
1314   ************************************************************
1315   ******Header(Correspondence)********************************
1316      IF ( g_mode = 'CRE' ) OR ( g_mode = 'CHA' ) OR
1317         ( g_mode = 'APR' ) OR ( g_mode = 'MRP' ) OR
1318           sy-tcode = 'ZCODG'.
1319        PERFORM save_cors_text.
1320      ENDIF.
1321   ******Items*************************************************
1322      IF g_mode = 'CRE'.
1323        DELETE ADJACENT DUPLICATES FROM ist_textid_items.
1324        LOOP AT ist_textid_items INTO wa_textid.
1325          REFRESH : ist_dtspecs.
1326          PERFORM read_text_data TABLES ist_dtspecs USING wa_textid.
1327          CONCATENATE 'CDDS'
1328                       zmm_cdhd_st-reqno
1329                       wa_textid-tdname+14(3)
1330                 INTO  wa_textid-tdname.
1331          PERFORM save_text.
1332        ENDLOOP.
1333        CLEAR wa_textid.
1334   *****Delete temporarily saved long text
1335        LOOP AT ist_textid_items INTO wa_textid.
1336          SELECT SINGLE * INTO g_stxl FROM stxl
1337                     WHERE tdobject = wa_textid-tdobject
1338                      AND  tdid     = wa_textid-tdid
1339                      AND  tdname   = wa_textid-tdname.
1340          IF sy-subrc = 0.
1341            PERFORM delete_text.
1342          ENDIF.
1343        ENDLOOP.
1344        REFRESH ist_textid_items.
1345      ENDIF.
1346   *************End of Long Text Save************************************
1347      PERFORM clear_var.
1348
1349    ENDFORM.                    " Insert_into_tab
1350   *&---------------------------------------------------------------------*
1351   *&      Form  clear_var
1352   *&---------------------------------------------------------------------*
1353   *       text
1354   *----------------------------------------------------------------------*
1355   *  -->  p1        text
1356   *  <--  p2        text
1357   *----------------------------------------------------------------------*
1358    FORM clear_var.
1359      IF NOT gv_text_editor1 IS INITIAL.
1360        PERFORM destroy_ctrl.
1361      ENDIF.
1362      CLEAR zmm_cdhd_st.
1363
1364      REFRESH g_tabctrl110_itab.
1365      REFRESH CONTROL 'TABCTRL110' FROM SCREEN '0110'.
1366
1367      REFRESH g_tablctrl120_itab.
1368      REFRESH CONTROL 'TABLCTRL120' FROM SCREEN '0120'.
1369
1370      REFRESH g_tablctrl130_itab.
1371      REFRESH CONTROL 'TABLCTRL130' FROM SCREEN '0130'.
1372
1373      REFRESH g_tablctrl140_itab.
1374      REFRESH CONTROL 'TABLCTRL140' FROM SCREEN '0140'.
1375
1376
1377      CLEAR: zmm_cdhd_st-reqcpf, zmm_cdhd_st-reqdate, zmm_cdhd_st-appcpf,
1378             zmm_cdhd_st-appdate, zmm_cdhd_st-addr1, zmm_cdhd_st-addr2,
1379             zmm_cdhd_st-addr3,zmm_cdhd_st-reqloc,
1380             g_TABCTRL110_wa, g_TABLCTRL120_wa, g_TABLCTRL130_wa,
1381             g_TABLCTRL140_wa,g_lineno,g_mode,g_hd_copied,
1382             l_mattype,g_saveflag,g_check_flag,g_techapr_visible.
1383      CLEAR  g_cors.
1384      REFRESH: ist_srchlp,tlinetab1,tlinetab2,lines_cors.
1385      REFRESH:lt_text_table1,lt_text_table2.
1386
1387   *   free object GV_CUSTOM_CONTAINER .
1388   *   free object GV_SPLITTER2.
1389   *   free object gv_text_editor1.
1390   *   free object gv_text_editor2.
1391   *
1392   *   clear:GV_SPLITTER1,GV_SPLITTER2,gv_text_editor1,gv_text_editor2.
1393   *****************
1394   *   CALL FUNCTION 'CONTROL_DESTROY'
1395   **    EXPORTING
1396   **       NO_FLUSH                  = 'X'
1397   *     CHANGING
1398   *       H_CONTROL               = 'C_WRT'
1399   *    EXCEPTIONS
1400   *      CNTL_SYSTEM_ERROR       = 1
1401   *      CNTL_ERROR              = 2
1402   *      OTHERS                  = 3
1403   *             .
1404   *   IF SY-SUBRC <> 0.
1405   ** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
1406   **         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
1407   *   ENDIF.
1408   *****Assigning constants and status*****************************
1409      dynnr = ''.
1410      REFRESH it_tab1.
1411      g_TABCTRL110_copied = ''.
1412      g_TABLCTRL120_copied = ''.
1413      g_TABLCTRL130_copied = ''.
1414      g_TABLCTRL140_copied = ''.
1415
1416   ******
1417    ENDFORM.                    " clear_var
1418
1419   *&---------------------------------------------------------------------*
1420   *&      Module  TABCTRL110_desc1_check  INPUT
1421   *&---------------------------------------------------------------------*
1422   *       text
1423   *----------------------------------------------------------------------*
1424    FORM TABCTRL110_desc1_check .
1425
1426      IF NOT g_TABCTRL110_wa-matgp IS INITIAL AND
1427            TABCTRL110_check_flag <> 'X'.
1428   *
1429        matgrp_change_flag = 'X'.
1430        matgrp_orig = g_TABCTRL110_wa-matgp.
1431      ENDIF.
1432
1433      SELECT * FROM zmm_modifier INTO TABLE ist_modifier_check_list
1434                WHERE desc1 = zmm_cditem-desc1 .
1435   *   and matgrp = g_TABCTRL110_wa-matgp.
1436      IF sy-subrc = 0.
1437        SORT ist_modifier_check_list BY
1438                        desc1 matgrp.
1439        DELETE ADJACENT DUPLICATES FROM ist_modifier_check_list COMPARING
1440                        desc1 matgrp.
1441        LOOP AT ist_modifier_check_list INTO wa_modifier_check_list.
1442
1443          IF      wa_modifier_check_list-matgrp = '01'
1444               OR wa_modifier_check_list-matgrp = '02'
1445               OR wa_modifier_check_list-matgrp = '03'
1446               OR wa_modifier_check_list-matgrp = '04'
1447               OR wa_modifier_check_list-matgrp = '05'
1448               OR wa_modifier_check_list-matgrp = '06'
1449               OR wa_modifier_check_list-matgrp = '07'
1450               OR wa_modifier_check_list-matgrp = '08'
1451               OR wa_modifier_check_list-matgrp = '09'
1452               OR wa_modifier_check_list-matgrp = '10'
1453               OR wa_modifier_check_list-matgrp = '11'
1454               OR wa_modifier_check_list-matgrp = '12'
1455               OR wa_modifier_check_list-matgrp = '13'
1456               OR wa_modifier_check_list-matgrp = '14'
1457               OR wa_modifier_check_list-matgrp = '15'
1458               OR wa_modifier_check_list-matgrp = '16'
1459               OR wa_modifier_check_list-matgrp = 'XX'.
1460          ELSE.
1461            DELETE ist_modifier_check_list.
1462          ENDIF.
1463
1464        ENDLOOP.
1465
1466        DESCRIBE TABLE ist_modifier_check_list LINES check_list_lines.
1467
1468        IF check_list_lines > 1 AND TABCTRL110_check_flag ='X'.
1469   *     g_matgp_selected ne 'X'.
1470          CALL SCREEN 104 STARTING AT 40 2
1471                          ENDING   AT 80 18.
1472          g_matgp_selected = 'X'.
1473          CLEAR check_list_lines.
1474        ELSE.
1475          READ TABLE ist_modifier_check_list               "#EC CI_NOORDER
1476          INTO wa_modifier_check_list INDEX 1.
1477        ENDIF.
1478
1479        IF matgrp_change_flag = 'X'.
1480          CLEAR g_matgp_selected.
1481          zmm_cditem-matgp = matgrp_orig.
1482          g_TABCTRL110_wa-matgp = matgrp_orig.
1483          CLEAR : matgrp_orig, matgrp_change_flag.
1484        ELSE.
1485          zmm_cditem-matgp = wa_modifier_check_list-matgrp.
1486          g_TABCTRL110_wa-matgp = wa_modifier_check_list-matgrp.
1487        ENDIF.
1488
1489   *     if check_list_lines > 1.
1490   *       message i025(zmm_oth) with zmm_cditem-matgp.
1491   *     endif.
1492   *+090505 ---------------------------------------------------
1493   * This is being commented because in change mode
1494   * if Other is chosen from F4 at 1st level and data are entered
1495   * then 'X' vanishes from OTH1 field.
1496   *     clear g_TABCTRL110_wa-oth1.
1497   *-090505 ---------------------------------------------------
1498        CLEAR zmm_cditem-oth1.
1499        CLEAR check_list_lines.
1500      ELSE.
1501        IF zmm_cditem-oth1 <> 'X'.
1502   *       g_parno = 1.
1503          MESSAGE i002(zmm_oth).
1504        ENDIF.
1505      ENDIF.
1506
1507    ENDFORM.                 " TABCTRL110_desc1_check
1508
1509   *---------------------------------------------------------------------*
1510   *       FORM TABCTRL110_desc2_check                                   *
1511   *---------------------------------------------------------------------*
1512   *       ........                                                      *
1513   *---------------------------------------------------------------------*
1514    FORM TABCTRL110_desc2_check .
1515
1516      SELECT SINGLE * FROM zmm_modifier WHERE desc1 = zmm_cditem-desc1 AND
1517                                              desc2 = zmm_cditem-desc2 .
1518
1519      IF sy-subrc = 0.
1520        CLEAR g_TABCTRL110_wa-oth2.
1521        CLEAR zmm_cditem-oth2.
1522      ELSE.
1523        IF zmm_cditem-oth2 <> 'X'.
1524          g_parno = 2.
1525          MESSAGE i002(zmm_oth).
1526        ENDIF.
1527      ENDIF.
1528
1529    ENDFORM.                 " TABCTRL110_desc2_check
1530   *&---------------------------------------------------------------------*
1531   *&      Form  TABCTRL110_desc3_check
1532   *&---------------------------------------------------------------------*
1533   *       text
1534   *----------------------------------------------------------------------*
1535   *  -->  p1        text
1536   *  <--  p2        text
1537   *----------------------------------------------------------------------*
1538    FORM TABCTRL110_desc3_check.
1539
1540      SELECT SINGLE * FROM zmm_modifier WHERE desc1 = zmm_cditem-desc1 AND
1541                                              desc2 = zmm_cditem-desc2 AND
1542                                              desc3 = zmm_cditem-desc3 .
1543
1544      IF sy-subrc = 0.
1545        CLEAR g_TABCTRL110_wa-oth3.
1546        CLEAR zmm_cditem-oth3.
1547      ELSE.
1548        IF zmm_cditem-oth3 <> 'X'.
1549          g_parno = 3.
1550          MESSAGE i002(zmm_oth).
1551        ENDIF.
1552      ENDIF.
1553
1554    ENDFORM.                    " TABCTRL110_desc3_check
1555   *---------------------------------------------------------------------*
1556   *       FORM TABCTRL110_desc4_check                                   *
1557   *---------------------------------------------------------------------*
1558   *       ........                                                      *
1559   *---------------------------------------------------------------------*
1560    FORM TABCTRL110_desc4_check.
1561
1562      SELECT SINGLE * FROM zmm_modifier WHERE desc1 = zmm_cditem-desc1 AND
1563                                              desc2 = zmm_cditem-desc2 AND
1564                                              desc3 = zmm_cditem-desc3 AND
1565                                              desc4 = zmm_cditem-desc4 .
1566      IF sy-subrc = 0.
1567        CLEAR g_TABCTRL110_wa-oth4.
1568        CLEAR zmm_cditem-oth4.
1569      ELSE.
1570        IF zmm_cditem-oth4 <> 'X'.
1571          g_parno = 4.
1572          MESSAGE i002(zmm_oth).
1573        ENDIF.
1574      ENDIF.
1575
1576    ENDFORM.                    " TABCTRL110_desc4_check
1577
1578   ****************************************************
1579    FORM popup_userdesc1.
1580      REFRESH : ist_sval1.
1581      CLEAR : ist_sval1.
1582      MOVE : 'ZMM_CDITEM'  TO ist_sval1-tabname,
1583             'USER_DESC'   TO ist_sval1-fieldname,
1584             'X'           TO ist_sval1-field_obl.
1585      APPEND ist_sval1.
1586
1587      CALL FUNCTION 'POPUP_GET_VALUES'
1588        EXPORTING
1589          popup_title     = 'USER DESCRIPTION'
1590          start_column    = '5'
1591          start_row       = '5'
1592        TABLES
1593          fields          = ist_sval1
1594        EXCEPTIONS
1595          error_in_fields = 1
1596          OTHERS          = 2.
1597
1598      IF sy-subrc <> 0.
1599        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
1600                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
1601      ENDIF.
1602      READ TABLE ist_sval1 INDEX 1.
1603      g_TABCTRL110_wa-user_desc = ist_sval1-value.
1604
1605    ENDFORM.                    " popup_userdesc1
1606
1607   *---------------------------------------------------------------------*
1608   *       FORM popup_userdesc2                                          *
1609   *---------------------------------------------------------------------*
1610   *       ........                                                      *
1611   *---------------------------------------------------------------------*
1612    FORM popup_userdesc2.
1613      REFRESH : ist_sval2.
1614      CLEAR : ist_sval2.
1615      MOVE : 'ZMM_CDITEM'  TO ist_sval2-tabname,
1616             'USER_DESC'   TO ist_sval2-fieldname,
1617             'X'           TO ist_sval2-field_obl.
1618      APPEND ist_sval2.
1619
1620      CALL FUNCTION 'POPUP_GET_VALUES'
1621        EXPORTING
1622          popup_title     = 'USER DESCRIPTION'
1623          start_column    = '5'
1624          start_row       = '5'
1625        TABLES
1626          fields          = ist_sval2
1627        EXCEPTIONS
1628          error_in_fields = 1
1629          OTHERS          = 2.
1630
1631      IF sy-subrc <> 0.
1632        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
1633                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
1634      ENDIF.
1635      READ TABLE ist_sval2 INDEX 1.
1636      g_TABCTRL110_wa-user_desc = ist_sval2-value.
1637
1638    ENDFORM.                    " popup_userdesc2
1639
1640   *---------------------------------------------------------------------*
1641   *       FORM popup_userdesc3                                          *
1642   *---------------------------------------------------------------------*
1643   *       ........                                                      *
1644   *---------------------------------------------------------------------*
1645    FORM popup_userdesc3.
1646      REFRESH : ist_sval3.
1647      CLEAR : ist_sval3.
1648      MOVE : 'ZMM_CDITEM'  TO ist_sval3-tabname,
1649             'USER_DESC'   TO ist_sval3-fieldname,
1650             'X'           TO ist_sval3-field_obl.
1651      APPEND ist_sval3.
1652
1653      CALL FUNCTION 'POPUP_GET_VALUES'
1654        EXPORTING
1655          popup_title     = 'USER DESCRIPTION'
1656          start_column    = '5'
1657          start_row       = '5'
1658        TABLES
1659          fields          = ist_sval3
1660        EXCEPTIONS
1661          error_in_fields = 1
1662          OTHERS          = 2.
1663
1664      IF sy-subrc <> 0.
1665        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
1666                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
1667      ENDIF.
1668      READ TABLE ist_sval3 INDEX 1.
1669      g_TABCTRL110_wa-user_desc = ist_sval3-value.
1670
1671    ENDFORM.                    " popup_userdesc3
1672
1673   *---------------------------------------------------------------------*
1674   *       FORM popup_userdesc4                                          *
1675   *---------------------------------------------------------------------*
1676   *       ........                                                      *
1677   *---------------------------------------------------------------------*
1678    FORM popup_userdesc4.
1679      REFRESH : ist_sval4.
1680      CLEAR : ist_sval4.
1681      MOVE : 'ZMM_CDITEM'  TO ist_sval4-tabname,
1682             'USER_DESC'   TO ist_sval4-fieldname,
1683             'X'           TO ist_sval4-field_obl.
1684      APPEND ist_sval4.
1685
1686      CALL FUNCTION 'POPUP_GET_VALUES'
1687        EXPORTING
1688          popup_title     = 'USER DESCRIPTION'
1689          start_column    = '5'
1690          start_row       = '5'
1691        TABLES
1692          fields          = ist_sval4
1693        EXCEPTIONS
1694          error_in_fields = 1
1695          OTHERS          = 2.
1696
1697      IF sy-subrc <> 0.
1698        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
1699                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
1700      ENDIF.
1701      READ TABLE ist_sval4 INDEX 1.
1702      g_TABCTRL110_wa-user_desc = ist_sval4-value.
1703
1704    ENDFORM.                    " popup_userdesc4
1705
1706   *---------------------------------------------------------------------*
1707   *       FORM TABLCTRL120_desc1_check                                  *
1708   *---------------------------------------------------------------------*
1709   *       ........                                                      *
1710   *---------------------------------------------------------------------*
1711    FORM TABLCTRL120_desc1_check .
1712
1713      SELECT SINGLE * FROM zmm_modifier WHERE desc1 = zmm_cditem-desc1 .
1714
1715      IF sy-subrc = 0.
1716        CLEAR g_TABLCTRL120_wa-oth1.
1717        CLEAR zmm_cditem-oth1.
1718      ELSE.
1719        IF zmm_cditem-oth1 <> 'X'.
1720          g_parno = 1.
1721          MESSAGE i002(zmm_oth).
1722        ENDIF.
1723      ENDIF.
1724
1725    ENDFORM.                 " TABLCTRL120_desc1_check
1726
1727   *&---------------------------------------------------------------------*
1728   *&      Form  popup_userdesc
1729   *&---------------------------------------------------------------------*
1730   *       text
1731   *----------------------------------------------------------------------*
1732   *  -->  p1        text
1733   *  <--  p2        text
1734   *----------------------------------------------------------------------*
1735   * FORM popup_userdesc.
1736   *
1737   *   call screen 115 starting at 18 17 ending at 120 23.
1738   *
1739   * ENDFORM.                    " popup_userdesc
1740   *&---------------------------------------------------------------------*
1741   *&      Form  CHANGE_PARTNO
1742   *&---------------------------------------------------------------------*
1743   *       text
1744   *----------------------------------------------------------------------*
1745   *      <--P_G_PARTNO  text
1746   *----------------------------------------------------------------------*
1747    FORM change_partno CHANGING p_g_partno LIKE zmm_cditem-user_desc
1748                                p_g_partnoc LIKE zmm_cditem-partno.
1749
1750      DATA : l_len TYPE i.
1751      DATA : l_ctr TYPE i.
1752      DATA : l_ctr1 TYPE i.
1753      DATA : l_add TYPE i.
1754      DATA : l_sub TYPE i.
1755      DATA : l_ctrf TYPE i.
1756      DATA : l_p_g_partnoc LIKE zmm_cditem-partno.
1757
1758      CLEAR : p_g_partno.
1759      CLEAR : check_flag2.
1760
1761      l_len = strlen( p_g_partnoc ).
1762
1763      l_p_g_partnoc = p_g_partnoc.
1764
1765      DO l_len TIMES.
1766
1767        l_ctr = l_ctr + 1.
1768
1769        wa_char = l_p_g_partnoc+l_ctr(1).
1770        TRANSLATE wa_char TO UPPER CASE.
1771
1772        LOOP AT ist_alphanum INTO wa_alphanum.
1773
1774          IF wa_char = wa_alphanum.
1775            check_flag1 = 'X'.
1776            EXIT.
1777          ELSEIF wa_char = '*'.
1778            check_flag2 = 'X'.
1779            EXIT.
1780          ENDIF.
1781
1782        ENDLOOP.
1783
1784        IF check_flag1 = 'X'.
1785          CLEAR check_flag1.
1786        ELSE.
1787          l_add = l_ctr + 1.
1788          l_sub = l_len - l_add + 1.
1789          IF l_add > l_len.
1790          ELSE.
1791            CONCATENATE l_p_g_partnoc+0(l_ctr) '%' l_p_g_partnoc+l_add(l_sub)
1792                           INTO l_p_g_partnoc.
1793          ENDIF.
1794        ENDIF.
1795
1796      ENDDO.
1797      CLEAR l_ctr.
1798      l_ctrf = l_len - 1.
1799      DO l_len TIMES.
1800        wa_alphanum = l_p_g_partnoc+l_ctr(1).
1801        IF l_ctr = l_ctrf.
1802          CONCATENATE p_g_partno wa_alphanum INTO p_g_partno.
1803        ELSEIF wa_alphanum <> '%'.
1804          CONCATENATE p_g_partno wa_alphanum '%' INTO p_g_partno.
1805        ENDIF.
1806
1807        l_ctr = l_ctr + 1.
1808      ENDDO.
1809
1810    ENDFORM.                    " CHANGE_PARTNO
1811
1812   *---------------------------------------------------------------------*
1813   *       FORM CHANGE_PARTNO1                                           *
1814   *---------------------------------------------------------------------*
1815   *       ........                                                      *
1816   *---------------------------------------------------------------------*
1817   *  -->  P_G_PARTNOO                                                   *
1818   *  -->  P_G_PARTNOCC                                                  *
1819   *---------------------------------------------------------------------*
1820    FORM change_partno1 CHANGING p_g_partnoo LIKE zmm_cditem-user_desc
1821                                p_g_partnocc LIKE zmm_cditem-partno.
1822
1823      DATA : l_len TYPE i.
1824      DATA : l_ctr TYPE i.
1825
1826      CLEAR : p_g_partnoo.
1827
1828      l_len = strlen( p_g_partnocc ).
1829
1830      CLEAR check_flag1.
1831
1832      DO l_len TIMES.
1833
1834        wa_char = p_g_partnocc+l_ctr(1).
1835        TRANSLATE wa_char TO UPPER CASE.
1836        l_ctr = l_ctr + 1.
1837
1838        LOOP AT ist_alphanum INTO wa_alphanum.
1839
1840          IF wa_char = wa_alphanum.
1841            check_flag1 = 'X'.
1842            EXIT.
1843          ENDIF.
1844
1845        ENDLOOP.
1846
1847        IF check_flag1 = 'X'.
1848          CLEAR check_flag1.
1849          CONCATENATE p_g_partnoo wa_char INTO p_g_partnoo.
1850        ENDIF.
1851
1852      ENDDO.
1853
1854    ENDFORM.                    " CHANGE_PARTNO
1855
1856   *---------------------------------------------------------------------*
1857   *       FORM CHANGE_PARTNO2                                           *
1858   *---------------------------------------------------------------------*
1859   *       ........                                                      *
1860   *---------------------------------------------------------------------*
1861   *  -->  P_G_PARTNOO                                                   *
1862   *  -->  P_G_PARTNOCC                                                  *
1863   *---------------------------------------------------------------------*
1864    FORM change_partno2 CHANGING p_g_partnoo LIKE zmm_cditem-user_desc
1865                                p_g_partnocc LIKE zmm_cditem-partno.
1866
1867      DATA : l_len TYPE i.
1868      DATA : l_ctr TYPE i.
1869
1870      CLEAR : p_g_partnoo.
1871
1872      l_len = strlen( p_g_partnocc ).
1873
1874      CLEAR check_flag1.
1875
1876      DO l_len TIMES.
1877
1878        wa_char = p_g_partnocc+l_ctr(1).
1879        TRANSLATE wa_char TO UPPER CASE.
1880        l_ctr = l_ctr + 1.
1881
1882        LOOP AT ist_alphanum INTO wa_alphanum.
1883
1884          IF wa_char = wa_alphanum.
1885            check_flag1 = 'X'.
1886            EXIT.
1887          ENDIF.
1888
1889        ENDLOOP.
1890
1891        IF check_flag1 = 'X'.
1892          CLEAR check_flag1.
1893          CONCATENATE p_g_partnoo wa_char INTO p_g_partnoo.
1894        ENDIF.
1895
1896      ENDDO.
1897
1898    ENDFORM.                    " CHANGE_PARTNO
1899
1900
1901
1902   *---------------------------------------------------------------------*
1903   *       FORM attrib_parno                                             *
1904   *---------------------------------------------------------------------*
1905   *       ........                                                      *
1906   *---------------------------------------------------------------------*
1907    FORM attrib_parno.
1908
1909
1910      SELECT * FROM zmm_modifier UP TO 1 ROWS
1911     WHERE desc1 = g_tabctrl110_wa-desc1
1912     AND matgrp = g_tabctrl110_wa-matgp
1913     ORDER BY PRIMARY KEY .
1914      ENDSELECT.
1915      IF sy-subrc <> 0.
1916        g_parno = '1'.
1917      ENDIF.
1918
1919      IF sy-subrc = 0.
1920
1921        IF  zmm_modifier-desc2 IS INITIAL.
1922          g_parno = '1'.
1923        ELSEIF  zmm_modifier-desc3 IS INITIAL.
1924          g_parno = '2'.
1925        ELSEIF  zmm_modifier-desc4 IS INITIAL.
1926          g_parno = '3'.
1927        ELSE.
1928          g_parno = '4'.
1929        ENDIF.
1930
1931      ENDIF.
1932
1933    ENDFORM.
1934   *&---------------------------------------------------------------------*
1935   *&      Form  TABLCTRL140_desc1_check
1936   *&---------------------------------------------------------------------*
1937   *       text
1938   *----------------------------------------------------------------------*
1939   *  -->  p1        text
1940   *  <--  p2        text
1941   *----------------------------------------------------------------------*
1942    FORM TABLCTRL140_desc1_check.
1943
1944      SELECT SINGLE * FROM zmm_modifier WHERE desc1 = zmm_cditem-desc1 .
1945
1946      IF sy-subrc = 0.
1947        CLEAR g_TABLCTRL140_wa-oth1.
1948        CLEAR zmm_cditem-oth1.
1949      ELSE.
1950        IF zmm_cditem-oth1 <> 'X'.
1951          g_parno = 1.
1952          MESSAGE i002(zmm_oth).
1953        ENDIF.
1954      ENDIF.
1955
1956    ENDFORM.                    " TABLCTRL140_desc1_check
1957   *&---------------------------------------------------------------------*
1958   *&      Form  TABLCTRL130_desc1_check
1959   *&---------------------------------------------------------------------*
1960   *       text
1961   *----------------------------------------------------------------------*
1962   *  -->  p1        text
1963   *  <--  p2        text
1964   *----------------------------------------------------------------------*
1965    FORM TABLCTRL130_desc1_check.
1966
1967      SELECT SINGLE * FROM zmm_modifier WHERE desc1 = zmm_cditem-desc1 .
1968
1969      IF sy-subrc = 0.
1970        CLEAR g_TABLCTRL130_wa-oth1.
1971        CLEAR zmm_cditem-oth1.
1972      ELSE.
1973        IF zmm_cditem-oth1 <> 'X'.
1974          g_parno = 1.
1975          MESSAGE i002(zmm_oth).
1976        ENDIF.
1977      ENDIF.
1978
1979    ENDFORM.                    " TABLCTRL130_desc1_check
1980
1981   *&---------------------------------------------------------------------*
1982   *&      Form  add_delitem
1983   *&---------------------------------------------------------------------*
1984   *       text
1985   *----------------------------------------------------------------------*
1986   *  -->  p1        text
1987   *  <--  p2        text
1988   *----------------------------------------------------------------------*
1989    FORM add_delitem110.
1990      LOOP AT g_TABCTRL110_itab INTO g_TABCTRL110_wa.
1991        IF g_TABCTRL110_wa-flag = 'X'.
1992          IF g_TABCTRL110_wa-matcode IS INITIAL.
1993            APPEND g_TABCTRL110_wa TO g_itab_del110.
1994          ELSE.
1995            MESSAGE i031(zmm_oth).
1996            g_TABCTRL110_wa-flag = ''.
1997            g_delflag = 'N'.
1998          ENDIF.
1999        ENDIF.
2000      ENDLOOP.
2001      CLEAR g_TABCTRL110_wa.
2002    ENDFORM.
2003
2004   *&---------------------------------------------------------------------*
2005   *&      Form  add_delitem120
2006   *&---------------------------------------------------------------------*
2007   *       text
2008   *----------------------------------------------------------------------*
2009   *  -->  p1        text
2010   *  <--  p2        text
2011   *----------------------------------------------------------------------*
2012    FORM add_delitem120.
2013      LOOP AT g_TABLCTRL120_itab INTO g_TABLCTRL120_wa.
2014        IF g_TABLCTRL120_wa-flag = 'X'.
2015          IF g_TABLCTRL120_wa-matcode IS INITIAL.
2016            APPEND g_TABLCTRL120_wa TO g_itab_del120.
2017          ELSE.
2018            MESSAGE i031(zmm_oth).
2019            g_TABLCTRL120_wa-flag = ''.
2020            g_delflag = 'N'.
2021          ENDIF.
2022        ENDIF.
2023      ENDLOOP.
2024      CLEAR g_TABLCTRL120_wa.
2025
2026    ENDFORM.                    " add_delitem120
2027   *&---------------------------------------------------------------------*
2028   *&      Form  add_delitem130
2029   *&---------------------------------------------------------------------*
2030   *       text
2031   *----------------------------------------------------------------------*
2032   *  -->  p1        text
2033   *  <--  p2        text
2034   *----------------------------------------------------------------------*
2035    FORM add_delitem130.
2036      LOOP AT g_TABLCTRL130_itab INTO g_TABLCTRL130_wa.
2037        IF g_TABLCTRL130_wa-flag = 'X'.
2038          IF g_TABLCTRL130_wa-matcode IS INITIAL.
2039            APPEND g_TABLCTRL130_wa TO g_itab_del130.
2040          ELSE.
2041            MESSAGE i031(zmm_oth).
2042            g_TABLCTRL130_wa-flag = ''.
2043            g_delflag = 'N'.
2044          ENDIF.
2045        ENDIF.
2046      ENDLOOP.
2047      CLEAR g_TABLCTRL130_wa.
2048
2049    ENDFORM.                    " add_delitem130
2050   *&---------------------------------------------------------------------*
2051   *&      Form  add_delitem140
2052   *&---------------------------------------------------------------------*
2053   *       text
2054   *----------------------------------------------------------------------*
2055   *  -->  p1        text
2056   *  <--  p2        text
2057   *----------------------------------------------------------------------*
2058    FORM add_delitem140.
2059      LOOP AT g_TABLCTRL140_itab INTO g_TABLCTRL140_wa.
2060        IF g_TABLCTRL140_wa-flag = 'X'.
2061          APPEND g_TABLCTRL140_wa TO g_itab_del140.
2062        ENDIF.
2063      ENDLOOP.
2064      CLEAR g_TABLCTRL140_wa.
2065
2066    ENDFORM.                    " add_delitem140
2067
2068   *&      Form  prepare_update
2069   *&---------------------------------------------------------------------*
2070   *       text
2071   *----------------------------------------------------------------------*
2072   *  -->  p1        text
2073   *  <--  p2        text
2074   *----------------------------------------------------------------------*
2075    FORM prepare_update.
2076   ***To delete the 'DELETED' marked item from the DB table.
2077
2078      CASE zmm_cdhd_st-mtart.
2079        WHEN 'ZSTO'.
2080          l_mattype = 'S'.
2081          PERFORM delitem110.
2082        WHEN 'ZSPR'.
2083          l_mattype = 'P'.
2084          PERFORM delitem120.
2085        WHEN 'ZCAP'.
2086          l_mattype = 'C'.
2087          PERFORM delitem130.
2088        WHEN 'ZDIS'.
2089          l_mattype = 'D'.
2090          PERFORM delitem140.
2091      ENDCASE.
2092      PERFORM Insert_into_tab.
2093
2094    ENDFORM.                    " prepare_update
2095
2096   *&---------------------------------------------------------------------*
2097   *&      Form  delitem110
2098   *&---------------------------------------------------------------------*
2099   *       text
2100   *----------------------------------------------------------------------*
2101   *  -->  p1        text
2102   *  <--  p2        text
2103   *----------------------------------------------------------------------*
2104    FORM delitem110.
2105   * if not g_itab_del110 is initial.
2106   *     loop at g_itab_del110 into g_tabctrl110_wa.
2107      DELETE FROM zmm_cditem
2108      WHERE  reqno   = zmm_cdhd_st-reqno.
2109   *       and    srno    = g_project200.
2110   *     endloop.
2111      REFRESH g_itab_del110.
2112   *  endif.
2113    ENDFORM.                    " delitem110
2114
2115   *&---------------------------------------------------------------------*
2116   *&      Form  delitem120
2117   *&---------------------------------------------------------------------*
2118   *       text
2119   *----------------------------------------------------------------------*
2120   *  -->  p1        text
2121   *  <--  p2        text
2122   *----------------------------------------------------------------------*
2123    FORM delitem120.
2124   *  if not g_itab_del120 is initial.
2125   *     loop at g_itab_del120 into g_tablctrl120_wa.
2126      DELETE FROM zmm_cditem
2127      WHERE  reqno   = zmm_cdhd_st-reqno.
2128   *       and    srno    = g_project200.
2129   *     endloop.
2130      REFRESH g_itab_del120.
2131   *  endif.
2132
2133
2134
2135    ENDFORM.                    " delitem120
2136
2137   *&---------------------------------------------------------------------*
2138   *&      Form  delitem130
2139   *&---------------------------------------------------------------------*
2140   *       text
2141   *----------------------------------------------------------------------*
2142   *  -->  p1        text
2143   *  <--  p2        text
2144   *----------------------------------------------------------------------*
2145    FORM delitem130.
2146   * if not g_itab_del130 is initial.
2147   *     loop at g_itab_del130 into g_tablctrl130_wa.
2148      DELETE FROM zmm_cditem
2149      WHERE  reqno   = zmm_cdhd_st-reqno.
2150   *       and    srno    = g_project200.
2151   *     endloop.
2152      REFRESH g_itab_del130.
2153   * endif.
2154
2155    ENDFORM.                    " delitem130
2156   *&---------------------------------------------------------------------*
2157   *&      Form  delitem140
2158   *&---------------------------------------------------------------------*
2159   *       text
2160   *----------------------------------------------------------------------*
2161   *  -->  p1        text
2162   *  <--  p2        text
2163   *----------------------------------------------------------------------*
2164    FORM delitem140.
2165   * if not g_itab_del140 is initial.
2166   *     loop at g_itab_del140 into g_tablctrl140_wa.
2167      DELETE FROM zmm_cditem
2168      WHERE  reqno   = zmm_cdhd_st-reqno.
2169   *       and    srno    = g_project200.
2170   *     endloop.
2171      REFRESH g_itab_del140.
2172   * endif.
2173    ENDFORM.                    " delitem140
2174
2175   *&---------------------------------------------------------------------*
2176   *&      Form  prepare_delete
2177   *&---------------------------------------------------------------------*
2178   *       text
2179   *----------------------------------------------------------------------*
2180   *  -->  p1        text
2181   *  <--  p2        text
2182   *----------------------------------------------------------------------*
2183    FORM prepare_delete.
2184
2185      PERFORM confirm_del.
2186
2187      IF g_choice = 'J'.
2188
2189        DELETE FROM zmm_cdhd
2190        WHERE reqno = zmm_cdhd_st-reqno.
2191        IF sy-subrc <> 0.
2192          MESSAGE e007(zmm_oth) WITH zmm_cdhd_st-reqno.
2193        ENDIF.
2194   ***
2195        SELECT tdobject tdname tdid FROM stxl
2196         INTO CORRESPONDING FIELDS OF TABLE ist_textid_items
2197         WHERE tdid = 'CDDS'.
2198        IF sy-subrc = 0.
2199          DELETE ist_textid_items
2200             WHERE tdname+4(10) <> zmm_cdhd_st-reqno.
2201          LOOP AT ist_textid_items INTO wa_textid.
2202            PERFORM delete_text.
2203          ENDLOOP.
2204          REFRESH ist_textid_items.
2205        ENDIF.
2206
2207        DELETE FROM zmm_cditem
2208        WHERE reqno = zmm_cdhd_st-reqno.
2209        IF sy-subrc = 0.
2210          MESSAGE i004(zmm_oth) WITH zmm_cdhd_st-reqno.
2211        ENDIF.
2212
2213
2214   *  update zmm_cdhd
2215   *  set lvorm = 'D'
2216   *  where reqno = zmm_cdhd_st-reqno
2217   *  and   lvorm = ''.
2218   *  if sy-subrc <> 0.
2219   *   message e003(zmm_oth) with zmm_cdhd_st-reqno.
2220   *  endif.
2221   *
2222   *  update zmm_cditem
2223   *  set lvorm = 'D'
2224   *  where reqno = zmm_cdhd_st-reqno.
2225   *  if sy-subrc = 0.
2226   *   message i004(zmm_oth) with zmm_cdhd_st-reqno.
2227   *  endif.
2228
2229        CLEAR g_choice.
2230      ENDIF.
2231
2232   *  clear zmm_cdhd_st.
2233   *  case l_mattype.
2234   *    when 'S'.
2235   *      refresh g_tabctrl110_itab.
2236   *      refresh control 'TABCTRL110' from screen '0110'.
2237   *    when 'P'.
2238   *      refresh g_tablctrl120_itab.
2239   *      refresh control 'TABCTRL120' from screen '0120'.
2240   *    when 'C'.
2241   *      refresh g_tablctrl130_itab.
2242   *      refresh control 'TABCTRL130' from screen '0130'.
2243   *    when 'D'.
2244   *      refresh g_tablctrl140_itab.
2245   *      refresh control 'TABCTRL140' from screen '0140'.
2246   *  endcase.
2247
2248    ENDFORM.                    " prepare_delete
2249   *&---------------------------------------------------------------------*
2250   *&      Form  bac_confirm
2251   *&---------------------------------------------------------------------*
2252   *       text
2253   *----------------------------------------------------------------------*
2254   *  -->  p1        text
2255   *  <--  p2        text
2256   *----------------------------------------------------------------------*
2257    FORM matcode_confirm.
2258      " Begin of <RD1K960036>.
2259
2260   *     CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
2261   *          EXPORTING
2262   *               DEFAULTOPTION  = 'N'
2263   *               TEXTLINE1      = 'The details in the request have been'
2264   *               TEXTLINE2      = 'checked. Please generate new Material
2265   *Codes '
2266   *               TITEL          = 'CONFIRM'
2267   *               START_COLUMN   = 25
2268   *               START_ROW      = 6
2269   *               CANCEL_DISPLAY = ''
2270   *          IMPORTING
2271   *               ANSWER         = a_choice.
2272
2273      DATA : l_answer(1) TYPE c.
2274
2275
2276
2277      CALL FUNCTION 'POPUP_TO_CONFIRM'
2278        EXPORTING
2279          titlebar              = 'CONFIRM'
2280          text_question         = 'The details in the request have been checked.'
2281                                  & ' Please generate new Material Codes. '
2282          text_button_1         = 'Yes'
2283          text_button_2         = 'No'
2284          default_button        = '2'
2285          display_cancel_button = ' '
2286          start_column          = 25
2287          start_row             = 6
2288        IMPORTING
2289          answer                = l_answer
2290        EXCEPTIONS
2291          text_not_found        = 1
2292          OTHERS                = 2.
2293      IF sy-subrc = 0.
2294
2295        CASE l_answer.
2296          WHEN '1'.
2297            MOVE 'J' TO a_choice.
2298          WHEN '2'.
2299            MOVE 'N' TO a_choice.
2300        ENDCASE.
2301      ENDIF.
2302
2303      " End of <RD1K960036>.
2304    ENDFORM.                    " matcode_confirm
2305
2306    FORM bac_confirm.
2307      DATA l_choice.
2308      IF g_mode <> 'DIS'.
2309        " Begin of <RD1K960036>.
2310   *     CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
2311   *          EXPORTING
2312   *               TEXTLINE1      = 'Data will be lost, Want to quit? '
2313   *               TITEL          = 'BACK'
2314   *               START_COLUMN   = 25
2315   *               START_ROW      = 6
2316   *               CANCEL_DISPLAY = ''
2317   *          IMPORTING
2318   *               ANSWER         = l_choice.
2319        DATA : l_answer(1) TYPE c.
2320
2321        CALL FUNCTION 'POPUP_TO_CONFIRM'
2322          EXPORTING
2323            titlebar              = 'BACK'
2324            text_question         = 'Data will be lost, Want to quit? '
2325            text_button_1         = 'Yes'
2326            text_button_2         = 'No'
2327            display_cancel_button = ' '
2328            start_column          = 25
2329            start_row             = 6
2330          IMPORTING
2331            answer                = l_answer
2332          EXCEPTIONS
2333            text_not_found        = 1
2334            OTHERS                = 2.
2335        IF sy-subrc = 0.
2336          CASE l_answer.
2337            WHEN '1'.
2338              MOVE 'J' TO l_choice.
2339            WHEN '2'.
2340              MOVE 'N' TO l_choice.
2341          ENDCASE.
2342        ENDIF.
2343
2344        " End of <RD1K960036>.
2345
2346        IF l_choice = 'J'.
2347          PERFORM undo_longtext.
2348          PERFORM clear_var.
2349          CLEAR l_choice.
2350        ENDIF.
2351      ELSE.
2352        PERFORM clear_var.
2353      ENDIF.
2354    ENDFORM.                    " bac_confirm
2355
2356   *&---------------------------------------------------------------------*
2357   *&      Form  check_delreq
2358   *&---------------------------------------------------------------------*
2359   *       text
2360   *----------------------------------------------------------------------*
2361   *  -->  p1        text
2362   *  <--  p2        text
2363   *----------------------------------------------------------------------*
2364    FORM check_delreq.
2365      DATA l_zmm_cdhd LIKE zmm_cdhd.
2366      IF g_mode = 'DEL'.
2367        SELECT SINGLE * INTO l_zmm_cdhd FROM zmm_cdhd
2368              WHERE reqno = zmm_cdhd_st-reqno
2369              AND   lvorm = 'D'.
2370        IF sy-subrc = 0.
2371          MESSAGE e004(zmm_oth) WITH zmm_cdhd_st-reqno.
2372        ENDIF.
2373
2374        SELECT SINGLE * INTO l_zmm_cdhd FROM zmm_cdhd
2375              WHERE reqno = zmm_cdhd_st-reqno
2376              AND   reqcl IN ('C','AC','IC','IR').
2377        IF sy-subrc = 0.
2378          MESSAGE e056(zmm_oth) WITH zmm_cdhd_st-reqno.
2379        ENDIF.
2380
2381      ENDIF.
2382   ****
2383      IF g_mode = 'CHA' OR
2384         g_mode = 'APR'.
2385        SELECT SINGLE * INTO l_zmm_cdhd FROM zmm_cdhd
2386               WHERE reqno = zmm_cdhd_st-reqno.
2387        IF sy-subrc = 0.
2388          IF l_zmm_cdhd-reqcl = 'AC' OR
2389             l_zmm_cdhd-reqcl = 'C'.
2390            MESSAGE e053(zmm_oth) WITH zmm_cdhd_st-reqno.
2391          ELSEIF l_zmm_cdhd-reqcl = 'IC'.
2392            MESSAGE i054(zmm_oth) WITH zmm_cdhd_st-reqno.
2393          ENDIF.
2394        ENDIF.
2395      ENDIF.
2396   ****
2397      IF g_mode = 'APR' AND g_user = 'L'.
2398   ***To check , if Tech Auth Appr is reqired.
2399        SELECT SINGLE * FROM zmm_cditem INTO CORRESPONDING FIELDS OF zmm_cditem
2400              WHERE reqno = zmm_cdhd_st-reqno
2401              AND   oth1  = 'X'.
2402        IF sy-subrc = 0.
2403          MESSAGE e055(zmm_oth) WITH zmm_cdhd_st-reqno.
2404        ENDIF.
2405      ENDIF.
2406
2407    ENDFORM.                    " check_delreq
2408   *&---------------------------------------------------------------------*
2409   *&      Form  confirm_del
2410   *&---------------------------------------------------------------------*
2411   *       text
2412   *----------------------------------------------------------------------*
2413   *  -->  p1        text
2414   *  <--  p2        text
2415   *----------------------------------------------------------------------*
2416    FORM confirm_del.
2417      " Begin of <RD1K960036>.
2418   *   CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
2419   *    EXPORTING
2420   *    TEXTLINE1   = 'Data will be lost, No recovery possible, Are you sure
2421   * ? '
2422   *     TITEL       = 'BACK'
2423   *     START_COLUMN     = 25
2424   *     START_ROW        = 6
2425   *     CANCEL_DISPLAY   = ''
2426   *    IMPORTING
2427   *     ANSWER           = g_choice.
2428
2429      DATA : l_answer(1) TYPE c.
2430
2431      CALL FUNCTION 'POPUP_TO_CONFIRM'
2432        EXPORTING
2433          titlebar       = 'BACK '
2434          text_question  = 'Data will be lost, No recovery possible, Are you sure ?'
2435          start_column   = 25
2436          start_row      = 6
2437        IMPORTING
2438          answer         = l_answer
2439        EXCEPTIONS
2440          text_not_found = 1
2441          OTHERS         = 2.
2442      IF sy-subrc = 0.
2443        CASE l_answer.
2444          WHEN '1'.
2445            MOVE 'J' TO g_choice.
2446          WHEN '2'.
2447            MOVE 'N' TO g_choice.
2448        ENDCASE.
2449      ENDIF.
2450
2451      " End of <RD1K960036>.
2452   *  If g_choice = 'J'.
2453   *    perform clear_var.
2454   *    clear g_choice.
2455   *  endif.
2456
2457
2458
2459    ENDFORM.                    " confirm_del
2460   *&---------------------------------------------------------------------*
2461   *&      Form  check_tabrows
2462   *&---------------------------------------------------------------------*
2463   *       text
2464   *----------------------------------------------------------------------*
2465   *  -->  p1        text
2466   *  <--  p2        text
2467   *----------------------------------------------------------------------*
2468    FORM check_tabrows.
2469      DATA: wa_itab110 TYPE t_TABCTRL110,
2470            wa_itab120 TYPE t_TABLCTRL120,
2471            wa_itab130 TYPE t_TABLCTRL130,
2472            wa_itab140 TYPE t_TABLCTRL140.
2473      CLEAR g_insrflg.
2474      CASE zmm_cdhd_st-mtart.
2475        WHEN 'ZSTO'.
2476          READ TABLE g_tabctrl110_itab INTO wa_itab110
2477               WITH KEY srno = 10.
2478          IF sy-subrc = 0.
2479            g_insrflg = 'Y'.
2480          ENDIF.
2481        WHEN 'ZSPR'.
2482          READ TABLE g_tablctrl120_itab INTO wa_itab120
2483               WITH KEY srno = 10.
2484          IF sy-subrc = 0.
2485            g_insrflg = 'Y'.
2486          ENDIF.
2487        WHEN 'ZCAP'.
2488          READ TABLE g_tablctrl130_itab INTO wa_itab130
2489               WITH KEY srno = 10.
2490          IF sy-subrc = 0.
2491            g_insrflg = 'Y'.
2492          ENDIF.
2493        WHEN 'ZDIS'.
2494          READ TABLE g_tablctrl140_itab INTO wa_itab140
2495               WITH KEY srno = 10.
2496          IF sy-subrc = 0.
2497            g_insrflg = 'Y'.
2498          ENDIF.
2499      ENDCASE.
2500
2501    ENDFORM.                    " check_tabrows
2502   *&---------------------------------------------------------------------*
2503   *&      Form  set_dynnr
2504   *&---------------------------------------------------------------------*
2505   *       text
2506   *----------------------------------------------------------------------*
2507   *      -->P_ZMM_CDHD_ST_MTART  text
2508   *----------------------------------------------------------------------*
2509    FORM set_dynnr USING p_mtart.
2510      CASE p_mtart.
2511        WHEN 'ZSTO'.
2512          dynnr = '0110'.
2513        WHEN 'ZSPR'.
2514          dynnr = '0120'.
2515        WHEN 'ZCAP'.
2516          dynnr = '0130'.
2517        WHEN 'ZDIS'.
2518          dynnr = '0140'.
2519      ENDCASE.
2520    ENDFORM.                    " set_dynnr
2521   *&---------------------------------------------------------------------*
2522   *&      Form  ltxtdtsp
2523   *&---------------------------------------------------------------------*
2524   *       text
2525   *----------------------------------------------------------------------*
2526   *  -->  p1        text
2527   *  <--  p2        text
2528   *----------------------------------------------------------------------*
2529    FORM ltxtdtsp.
2530   *************Local Data*******************************
2531      DATA: l_srno    LIKE zmm_cditem-srno,
2532            l_curs_ln TYPE i,
2533            l_itab110 TYPE t_TABCTRL110,
2534            l_itab120 TYPE t_TABLCTRL120,
2535            l_itab130 TYPE t_TABLCTRL130,
2536            l_itab140 TYPE t_TABLCTRL140.
2537   **
2538      CLEAR ist_textid.
2539
2540   ********************************************************
2541   *  get cursor line l_curs_ln.
2542   ***To get the proper serial no of line item against the
2543   ***Cursor position
2544      CASE zmm_cdhd_st-mtart.
2545        WHEN 'ZSTO'.
2546   *   move tabctrl110-current_line to l_curs_ln.
2547          l_curs_ln = g_curr_line_110.
2548          READ TABLE g_tabctrl110_itab INTO l_itab110
2549                                      INDEX l_curs_ln.
2550          l_srno = l_itab110-srno.
2551        WHEN 'ZSPR'.
2552   *   move tablctrl120-current_line to l_curs_ln.
2553          l_curs_ln = g_curr_line_120.
2554          READ TABLE g_tablctrl120_itab INTO l_itab120
2555                                      INDEX l_curs_ln.
2556          l_srno = l_itab120-srno.
2557        WHEN 'ZCAP'.
2558          MOVE tablctrl130-current_line TO l_curs_ln.
2559          READ TABLE g_tablctrl130_itab INTO l_itab130
2560                                      INDEX l_curs_ln.
2561          l_srno = l_itab130-srno.
2562        WHEN 'ZDIS'.
2563          MOVE tablctrl140-current_line TO l_curs_ln.
2564          READ TABLE g_tablctrl140_itab INTO l_itab140
2565                                      INDEX l_curs_ln.
2566          l_srno = l_itab140-srno.
2567      ENDCASE.
2568
2569   ***
2570      IF g_mode = 'CRE'.
2571        CONCATENATE 'CDDS' '9999999999' l_srno
2572        INTO ist_textid-tdname.
2573      ELSE.
2574        CONCATENATE 'CDDS' zmm_cdhd_st-reqno l_srno
2575        INTO ist_textid-tdname.
2576      ENDIF.
2577
2578      ist_textid-tdobject   = 'ZMMCD'.
2579      ist_textid-tdid       = 'CDDS'.
2580      ist_textid-tdspras    =  sy-langu.
2581      ist_textid-tdlinesize =  72.
2582   ***Appending to internal table for all textid/name.
2583      APPEND ist_textid TO ist_textid_items.
2584   *  if l_srno <> '000'.
2585      PERFORM read_text_dtspecs.
2586   *  endif.
2587
2588    ENDFORM.                    " ltxtdtsp
2589   *&---------------------------------------------------------------------*
2590   *&      Form  read_text_dtspecs
2591   *&---------------------------------------------------------------------*
2592   *       text
2593   *----------------------------------------------------------------------*
2594   *  -->  p1        text
2595   *  <--  p2        text
2596   *----------------------------------------------------------------------*
2597    FORM read_text_dtspecs.
2598      CLEAR   : ist_dtspecs.
2599      REFRESH : ist_dtspecs.
2600      PERFORM read_text_data TABLES ist_dtspecs USING ist_textid.
2601      PERFORM edit_text.
2602   *****To save temporarily in the stxl table with [CDDS9999999999(srno)]
2603   **** for Creation and with [CDDS(reqno)(srno)] for Change
2604      IF ( g_mode = 'CRE' ) OR ( g_mode = 'CHA' ).
2605        wa_textid = ist_textid.
2606        PERFORM save_text.
2607      ENDIF.
2608
2609    ENDFORM.                    " read_text_dtspecs
2610   *&---------------------------------------------------------------------*
2611   *&      Form  read_text_data
2612   *&---------------------------------------------------------------------*
2613   *       text
2614   *----------------------------------------------------------------------*
2615   *      -->P_IST_DTSPECS  text
2616   *      -->P_IST_TEXTID  text
2617   *----------------------------------------------------------------------*
2618    FORM read_text_data TABLES   p_ist_dtspecs STRUCTURE  tline
2619                        USING    p_ist_textid  STRUCTURE  thead.
2620
2621      CALL FUNCTION 'READ_TEXT'
2622        EXPORTING
2623          client                  = sy-mandt
2624          id                      = p_ist_textid-tdid
2625          language                = sy-langu
2626          name                    = p_ist_textid-tdname
2627          object                  = p_ist_textid-tdobject
2628        IMPORTING
2629          header                  = p_ist_textid
2630        TABLES
2631          lines                   = p_ist_dtspecs
2632        EXCEPTIONS
2633          id                      = 1
2634          language                = 2
2635          name                    = 3
2636          not_found               = 4
2637          object                  = 5
2638          reference_check         = 6
2639          wrong_access_to_archive = 7
2640          OTHERS                  = 8.
2641
2642    ENDFORM.                    " read_text_data
2643   *&---------------------------------------------------------------------*
2644   *&      Form  edit_text
2645   *&---------------------------------------------------------------------*
2646   *       text
2647   *----------------------------------------------------------------------*
2648   *  -->  p1        text
2649   *  <--  p2        text
2650   *----------------------------------------------------------------------*
2651    FORM edit_text.
2652
2653      DATA: l_display,
2654            l_USERTITLE,
2655            l_itced LIKE itced.
2656      l_usertitle       = 'X'.
2657      l_itced-usertitle = l_usertitle.
2658
2659      IF ( g_mode = 'CRE' ) OR  ( g_mode = 'CHA' ).
2660        l_display = ''.
2661      ELSE.
2662        l_display = 'X'.
2663      ENDIF.
2664      CALL FUNCTION 'EDIT_TEXT'
2665        EXPORTING
2666          display       = l_display
2667          header        = ist_textid
2668   *************************************************************
2669          control       = l_itced
2670   *************************************************************
2671        TABLES
2672          lines         = ist_dtspecs
2673        EXCEPTIONS
2674          id            = 1
2675          language      = 2
2676          linesize      = 3
2677          name          = 4
2678          object        = 5
2679          textformat    = 6
2680          communication = 7
2681          OTHERS        = 8.
2682
2683    ENDFORM.                    " edit_text
2684   *&---------------------------------------------------------------------*
2685   *&      Form  SAVE_TEXT
2686   *&---------------------------------------------------------------------*
2687   *       text
2688   *----------------------------------------------------------------------*
2689   *  -->  p1        text
2690   *  <--  p2        text
2691   *----------------------------------------------------------------------*
2692    FORM save_text.
2693
2694      DATA : l_dtspecs LIKE tline.
2695
2696      LOOP AT ist_dtspecs INTO l_dtspecs.
2697        TRANSLATE l_dtspecs TO UPPER CASE.
2698        MODIFY ist_dtspecs FROM l_dtspecs INDEX sy-tabix.
2699      ENDLOOP.
2700
2701      CALL FUNCTION 'SAVE_TEXT'
2702        EXPORTING
2703          client          = sy-mandt
2704          header          = wa_textid
2705          savemode_direct = 'X'
2706        TABLES
2707          lines           = ist_dtspecs
2708        EXCEPTIONS
2709          id              = 1
2710          language        = 2
2711          name            = 3
2712          object          = 4
2713          OTHERS          = 5.
2714      IF sy-subrc <> 0.
2715        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
2716                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
2717      ENDIF.
2718
2719    ENDFORM.                    " SAVE_TEXT
2720   *&---------------------------------------------------------------------*
2721   *&      Form  delete_text
2722   *&---------------------------------------------------------------------*
2723   *       text
2724   *----------------------------------------------------------------------*
2725   *  -->  p1        text
2726   *  <--  p2        text
2727   *----------------------------------------------------------------------*
2728    FORM delete_text.
2729      CALL FUNCTION 'DELETE_TEXT'
2730        EXPORTING
2731          client          = sy-mandt
2732          id              = wa_textid-tdid
2733          language        = sy-langu
2734          name            = wa_textid-tdname
2735          object          = wa_textid-tdobject
2736          savemode_direct = 'X'
2737        EXCEPTIONS
2738          not_found       = 1
2739          OTHERS          = 2.
2740
2741      IF sy-subrc <> 0.
2742   * MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
2743   *         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
2744      ENDIF.
2745
2746    ENDFORM.                    " delete_text
2747   *&---------------------------------------------------------------------*
2748   *&      Form  delete_addedtext
2749   *&---------------------------------------------------------------------*
2750   *  This subroutine delete the added long text, added during the change
2751   *mode.From the internal table, delete the items other than original
2752   *----------------------------------------------------------------------*
2753   *  -->  p1        text
2754   *  <--  p2        text
2755   *----------------------------------------------------------------------*
2756    FORM delete_addedtext.
2757      TYPES: BEGIN OF l_items,
2758               reqno LIKE zmm_cdhd-reqno,
2759               srno  LIKE zmm_cditem-srno,
2760             END OF l_items.
2761      DATA: l_items_itab TYPE TABLE OF l_items WITH HEADER LINE.
2762   **************************************************************
2763   ****To get the original items for a reqno
2764      REFRESH l_items_itab.
2765   *Select srno reqno from zmm_cditem
2766   *       appending corresponding fields of table l_items_itab[]
2767   *                  where reqno = zmm_cdhd_st-reqno.
2768      SELECT reqno srno FROM zmm_cditem
2769       INTO CORRESPONDING FIELDS OF TABLE l_items_itab[]
2770                       WHERE reqno = zmm_cdhd_st-reqno.
2771      IF sy-subrc = 0.
2772
2773   ****To delete these numbers from internal table ist_textid_items
2774   ****if found in original items list.
2775        LOOP AT ist_textid_items INTO wa_textid.
2776          READ TABLE l_items_itab WITH KEY
2777                     reqno = wa_textid-tdname+4(10)
2778                     srno  = wa_textid-tdname+14(3).
2779          IF sy-subrc = 0.
2780            DELETE ist_textid_items
2781                   WHERE tdobject = wa_textid-tdobject
2782                   AND   tdid     = wa_textid-tdid
2783                   AND   tdname   = wa_textid-tdname.
2784          ENDIF.
2785        ENDLOOP.
2786      ENDIF.
2787    ENDFORM.                    " delete_addedtext
2788   *&---------------------------------------------------------------------*
2789   *&      Form  undo_longtext
2790   *&---------------------------------------------------------------------*
2791   *       text
2792   *----------------------------------------------------------------------*
2793   *  -->  p1        text
2794   *  <--  p2        text
2795   *----------------------------------------------------------------------*
2796    FORM undo_longtext.
2797      IF NOT ist_textid_items IS INITIAL.
2798        IF g_mode = 'CRE'.
2799          LOOP AT ist_textid_items INTO wa_textid.
2800            PERFORM delete_text.
2801          ENDLOOP.
2802          REFRESH ist_textid_items.
2803        ELSEIF g_mode = 'CHA'.
2804          PERFORM delete_addedtext.
2805          LOOP AT ist_textid_items INTO wa_textid.
2806            PERFORM delete_text.
2807          ENDLOOP.
2808          REFRESH ist_textid_items.
2809        ENDIF.
2810      ENDIF.
2811    ENDFORM.                    " undo_longtext
2812   *&---------------------------------------------------------------------*
2813   *&      Form  text_control_eingabebereit1
2814   *&---------------------------------------------------------------------*
2815   *       text
2816   *----------------------------------------------------------------------*
2817   *  -->  p1        text
2818   *  <--  p2        text
2819   *----------------------------------------------------------------------*
2820    FORM text_control_eingabebereit1.
2821      CALL METHOD gv_text_editor1->set_readonly_mode
2822        EXPORTING
2823          readonly_mode          = gv_text_editor1->true
2824        EXCEPTIONS
2825          error_cntl_call_method = 1
2826          invalid_parameter      = 2
2827          OTHERS                 = 3.
2828      IF ( g_mode = 'CRE' ) OR ( g_mode = 'CHA' ) OR
2829         ( g_mode = 'REL' ) OR ( g_mode = 'MRP' ) OR
2830         ( g_mode = 'APR' ) OR sy-tcode = 'ZCODG'.
2831
2832        CALL METHOD gv_text_editor2->set_readonly_mode
2833          EXPORTING
2834            readonly_mode          = gv_text_editor2->false
2835          EXCEPTIONS
2836            error_cntl_call_method = 1
2837            invalid_parameter      = 2
2838            OTHERS                 = 3.
2839      ENDIF.
2840
2841
2842    ENDFORM.                    " text_control_eingabebereit1
2843   *&---------------------------------------------------------------------*
2844   *&      Form  text_control_set_text_table1
2845   *&---------------------------------------------------------------------*
2846   *       text
2847   *----------------------------------------------------------------------*
2848   *  -->  p1        text
2849   *  <--  p2        text
2850   *----------------------------------------------------------------------*
2851    FORM text_control_set_text_table1.
2852   *Addition***********************************************
2853      REFRESH: tlinetab1,g_linefrto_itab.
2854      IF g_mode <> 'CRE'.
2855        APPEND LINES OF lines_cors TO tlinetab1[].
2856      ENDIF.
2857   *End     ***********************************************
2858   *Addition***********************************************
2859      LOOP AT tlinetab1[] INTO g_line132.
2860        IF ( g_line132+0(7) = '* Reply' ) OR
2861           ( g_line132+0(7) = '**Reply' ).
2862          g_linefrto-line_fr = sy-tabix.
2863          g_linefrto-line_to = sy-tabix.
2864          APPEND g_linefrto TO g_linefrto_itab.
2865          CLEAR: g_linefrto.
2866        ENDIF.
2867      ENDLOOP.
2868   *End     ***********************************************
2869
2870      CALL FUNCTION 'CONVERT_ITF_TO_STREAM_TEXT'
2871        TABLES
2872          itf_text    = tlinetab1[]
2873          text_stream = lt_text_table1.
2874
2875      CALL METHOD gv_text_editor1->set_text_as_stream
2876        EXPORTING
2877          text            = lt_text_table1
2878        EXCEPTIONS
2879          error_dp        = 1
2880          error_dp_create = 2
2881          OTHERS          = 3.
2882   ********************highlight**************************************
2883      CLEAR g_linefrto.
2884      LOOP AT g_linefrto_itab INTO g_linefrto.
2885        CALL METHOD gv_text_editor1->highlight_lines
2886          EXPORTING
2887            from_line      = g_linefrto-line_fr
2888            to_line        = g_linefrto-line_to
2889            highlight_mode = 1.
2890      ENDLOOP.
2891   ********************************************************************
2892
2893
2894      IF ( g_mode = 'CRE' ) OR ( g_mode = 'CHA' ) OR
2895         ( g_mode = 'REL' ) OR ( g_mode = 'MRP' ) OR
2896         ( g_mode = 'APR' ) OR sy-tcode = 'ZCODG'.
2897
2898
2899        CALL FUNCTION 'CONVERT_ITF_TO_STREAM_TEXT'
2900          TABLES
2901            itf_text    = tlinetab2
2902            text_stream = lt_text_table2.
2903
2904        CALL METHOD gv_text_editor2->set_text_as_stream
2905          EXPORTING
2906            text            = lt_text_table2
2907          EXCEPTIONS
2908            error_dp        = 1
2909            error_dp_create = 2
2910            OTHERS          = 3.
2911      ENDIF.
2912
2913    ENDFORM.                    " text_control_set_text_table1
2914
2915   *&---------------------------------------------------------------------*
2916   *&      Form  get_correspondense
2917   *&---------------------------------------------------------------------*
2918   *       text
2919   *----------------------------------------------------------------------*
2920   *  -->  p1        text
2921   *  <--  p2        text
2922   *----------------------------------------------------------------------*
2923    FORM get_correspondense.
2924
2925      DATA : l_cors LIKE thead-tdname.
2926
2927      IF g_mode <> 'CRE'.
2928        CONCATENATE 'CORS' zmm_cdhd_st-reqno INTO l_cors.
2929
2930        CALL FUNCTION 'READ_TEXT'
2931          EXPORTING
2932            client                  = sy-mandt
2933            id                      = 'CORS'
2934            language                = sy-langu
2935            name                    = l_cors
2936            object                  = 'ZMMCD'
2937          TABLES
2938            lines                   = lines_cors
2939          EXCEPTIONS
2940            id                      = 1
2941            language                = 2
2942            name                    = 3
2943            not_found               = 4
2944            object                  = 5
2945            reference_check         = 6
2946            wrong_access_to_archive = 7
2947            OTHERS                  = 8.
2948
2949        IF sy-subrc <> 0.
2950   *     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
2951   *     WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
2952          g_cors = ''.
2953        ELSE.
2954          g_cors = 'X'.
2955        ENDIF.
2956      ENDIF.
2957
2958    ENDFORM.                    " get_correspondense
2959
2960   *&---------------------------------------------------------------------*
2961   *&      Form  save_cors_text
2962   *&---------------------------------------------------------------------*
2963   *       text
2964   *----------------------------------------------------------------------*
2965   *  -->  p1        text
2966   *  <--  p2        text
2967   *----------------------------------------------------------------------*
2968    FORM save_cors_text.
2969      DATA: l_theader LIKE thead.
2970      DATA: l_datech(10) TYPE c.
2971   ***********Assignments***********************
2972      CLEAR l_theader.
2973      l_theader-tdobject   = 'ZMMCD'.
2974      l_theader-tdid       = 'CORS'.
2975      l_theader-tdspras    =  sy-langu.
2976      l_theader-tdlinesize =  72.
2977      CONCATENATE 'CORS' zmm_cdhd_st-reqno INTO l_theader-tdname.
2978      APPEND LINES OF tlinetab2 TO tlinetab1.
2979   *********************************************
2980      IF NOT tlinetab1[] IS INITIAL.
2981        CLEAR g_cores_sender.
2982        CONCATENATE sy-datum+6(2) '/'
2983                    sy-datum+4(2) '/'
2984                    sy-datum+0(4) INTO l_datech.
2985        CONCATENATE '**Reply' l_datech sy-uname INTO g_cores_sender
2986         SEPARATED BY '          '.
2987        IF NOT tlinetab2[] IS INITIAL.
2988          APPEND g_cores_sender TO tlinetab1.
2989        ENDIF.
2990        CLEAR g_cores_sender.
2991        CALL FUNCTION 'SAVE_TEXT'
2992          EXPORTING
2993            client          = sy-mandt
2994            header          = l_theader
2995            savemode_direct = 'X'
2996          TABLES
2997            lines           = tlinetab1
2998          EXCEPTIONS
2999            id              = 1
3000            language        = 2
3001            name            = 3
3002            object          = 4
3003            OTHERS          = 5.
3004
3005        IF sy-subrc <> 0.
3006          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
3007                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
3008        ENDIF.
3009      ENDIF.
3010
3011    ENDFORM.                    " save_cors_text
3012   *&---------------------------------------------------------------------*
3013   *&      Form  destroy_ctrl
3014   *&---------------------------------------------------------------------*
3015   *       text
3016   *----------------------------------------------------------------------*
3017   *  -->  p1        text
3018   *  <--  p2        text
3019   *----------------------------------------------------------------------*
3020    FORM destroy_ctrl.
3021      CASE g_mode.
3022        WHEN 'CRE' OR 'CHA' OR 'REL' OR 'MRP' OR 'APR'.
3023          CALL METHOD gv_text_editor1->free.
3024          CALL METHOD gv_text_editor2->free.
3025        WHEN 'DIS' OR 'DEL'.
3026          CALL METHOD gv_text_editor1->free.
3027      ENDCASE.
3028      CLEAR:gv_text_editor1,gv_text_editor2.
3029
3030    ENDFORM.                    " destroy_ctrl
3031   *&---------------------------------------------------------------------*
3032   *&      Form  check_items
3033   *&---------------------------------------------------------------------*
3034   *       text
3035   *----------------------------------------------------------------------*
3036   *  -->  p1        text
3037   *  <--  p2        text
3038   *----------------------------------------------------------------------*
3039    FORM check_items.
3040      DATA : l_t110 TYPE t_tabctrl110,
3041             l_t120 TYPE t_tablctrl120,
3042             l_t130 TYPE t_TABLCTRL130.
3043      CLEAR g_saveflag.
3044
3045      CASE zmm_cdhd_st-mtart.
3046        WHEN 'ZSTO'.
3047          READ TABLE g_tabctrl110_itab INTO l_t110 INDEX 1.
3048          IF sy-subrc = 0.
3049            IF NOT l_t110-uom IS INITIAL.
3050              g_saveflag = 'Y'.
3051            ELSE.
3052              g_saveflag = 'N'.
3053            ENDIF.
3054          ELSE.
3055            g_saveflag = 'N'.
3056          ENDIF.
3057        WHEN 'ZSPR'.
3058          READ TABLE g_tablctrl120_itab INTO l_t120 INDEX 1.
3059          IF sy-subrc = 0.
3060            IF NOT l_t120-manu IS INITIAL.
3061              g_saveflag = 'Y'.
3062            ELSE.
3063              g_saveflag = 'N'.
3064            ENDIF.
3065          ELSE.
3066            g_saveflag = 'N'.
3067          ENDIF.
3068        WHEN 'ZCAP'.
3069          READ TABLE g_tablctrl130_itab INTO l_t130 INDEX 1.
3070          IF sy-subrc = 0.
3071            IF NOT l_t130-uom IS INITIAL.
3072              g_saveflag = 'Y'.
3073            ELSE.
3074              g_saveflag = 'N'.
3075            ENDIF.
3076          ELSE.
3077            g_saveflag = 'N'.
3078          ENDIF.
3079
3080      ENDCASE.
3081    ENDFORM.                    " check_items
3082   *&---------------------------------------------------------------------*
3083   *&      Form  check_lt_exist
3084   *&---------------------------------------------------------------------*
3085   *       text
3086   *----------------------------------------------------------------------*
3087   *      -->P_L_TDNAME  text
3088   *      -->P_L_LINES  text
3089   *----------------------------------------------------------------------*
3090    FORM check_lt_exist USING    p_tdname.
3091
3092      REFRESH g_lines.
3093      CALL FUNCTION 'READ_TEXT'
3094        EXPORTING
3095          client                  = sy-mandt
3096          id                      = 'CDDS'
3097          language                = sy-langu
3098          name                    = p_tdname
3099          object                  = 'ZMMCD'
3100        TABLES
3101          lines                   = g_lines
3102        EXCEPTIONS
3103          id                      = 1
3104          language                = 2
3105          name                    = 3
3106          not_found               = 4
3107          object                  = 5
3108          reference_check         = 6
3109          wrong_access_to_archive = 7
3110          OTHERS                  = 8.
3111
3112      IF sy-subrc <> 0.
3113   *     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
3114   *     WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
3115      ENDIF.
3116
3117
3118    ENDFORM.                    " check_lt_exist
3119   *&---------------------------------------------------------------------*
3120   *&      Form  lock_reqhd
3121   *&---------------------------------------------------------------------*
3122   *       text
3123   *----------------------------------------------------------------------*
3124   *  -->  p1        text
3125   *  <--  p2        text
3126   *----------------------------------------------------------------------*
3127    FORM lock_reqhd.
3128      CALL FUNCTION 'ENQUEUE_EZ_MM_CDHD'
3129        EXPORTING
3130          mode_zmm_cdhd  = 'E'
3131          mandt          = sy-mandt
3132          reqno          = zmm_cdhd_st-reqno
3133        EXCEPTIONS
3134          foreign_lock   = 1
3135          system_failure = 2
3136          OTHERS         = 3.
3137
3138      IF sy-subrc <> 0.
3139        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
3140               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
3141      ELSE.
3142        MOVE 'Y' TO g_lock.
3143      ENDIF.
3144
3145    ENDFORM.                    " lock_reqhd
3146   *&---------------------------------------------------------------------*
3147   *&      Form  unlock_req
3148   *&---------------------------------------------------------------------*
3149   *       text
3150   *----------------------------------------------------------------------*
3151   *  -->  p1        text
3152   *  <--  p2        text
3153   *----------------------------------------------------------------------*
3154    FORM unlock_req .
3155   *********Header*******************************
3156      CALL FUNCTION 'DEQUEUE_EZ_MM_CDHD'
3157        EXPORTING
3158          mode_zmm_cdhd = 'E'
3159          mandt         = sy-mandt
3160          reqno         = zmm_cdhd_st-reqno.
3161
3162    ENDFORM.                    " unlock_req
3163   ***************************************************
3164
3165    AT USER-COMMAND.
3166      IF sy-ucomm = 'AGREE'.
3167        IF g_mode = 'REL'.
3168          PERFORM update_release.
3169        ELSEIF g_mode = 'APR'.
3170          PERFORM update_approval.
3171        ENDIF.
3172      ENDIF.
3173      PERFORM clear_var.
3174      LEAVE TO SCREEN 0.
3175   ***************************************************
3176   *&---------------------------------------------------------------------*
3177   *&      Form  other_sectime
3178   *&---------------------------------------------------------------------*
3179   *       text
3180   *----------------------------------------------------------------------*
3181   *  -->  p1        text
3182   *  <--  p2        text
3183   *----------------------------------------------------------------------*
3184    FORM other_sectime.
3185      IF zmm_cditem-oth1 = 'X'.
3186        LOOP AT SCREEN.
3187          IF screen-name = 'G_USER_DESC'.
3188            screen-input = 0.
3189            MODIFY SCREEN.
3190          ENDIF.
3191        ENDLOOP.
3192      ELSEIF zmm_cditem-oth1 = '' AND
3193             zmm_cditem-oth2 = 'X'.
3194        LOOP AT SCREEN.
3195          IF screen-name = 'G_USER_DESC' OR
3196             screen-name = 'G_DESC1'    OR
3197             screen-name = 'G_MATGP'.
3198            screen-input = 0.
3199            MODIFY SCREEN.
3200          ENDIF.
3201        ENDLOOP.
3202      ELSEIF zmm_cditem-oth1 = '' AND
3203             zmm_cditem-oth2 = '' AND
3204             zmm_cditem-oth3 = 'X'.
3205        LOOP AT SCREEN.
3206          IF screen-name = 'G_USER_DESC' OR
3207             screen-name = 'G_DESC1'     OR
3208             screen-name = 'G_DESC2'     OR
3209             screen-name = 'G_MATGP'.
3210            screen-input = 0.
3211            MODIFY SCREEN.
3212          ENDIF.
3213        ENDLOOP.
3214
3215      ELSEIF zmm_cditem-oth1 = '' AND
3216             zmm_cditem-oth2 = '' AND
3217             zmm_cditem-oth3 = '' AND
3218             zmm_cditem-oth4 = 'X'.
3219        LOOP AT SCREEN.
3220          IF screen-name = 'G_USER_DESC' OR
3221             screen-name = 'G_DESC1'     OR
3222             screen-name = 'G_DESC2'     OR
3223             screen-name = 'G_DESC3'     OR
3224             screen-name = 'G_MATGP'.
3225
3226            screen-input = 0.
3227            MODIFY SCREEN.
3228          ENDIF.
3229        ENDLOOP.
3230
3231      ENDIF.
3232
3233
3234    ENDFORM.                    " other_sectime
3235   *&---------------------------------------------------------------------*
3236   *&      Form  sort_sto
3237   *&---------------------------------------------------------------------*
3238   *       text
3239   *----------------------------------------------------------------------*
3240   *      -->P_G_ORDER  text
3241   *----------------------------------------------------------------------*
3242    FORM sort_sto USING p_order.
3243      READ  TABLE tabctrl110-cols WITH  KEY selected = 'X' INTO
3244            wa_tabctrl110_cols.
3245      IF sy-subrc <> 0.
3246        MESSAGE e063(zmm_oth).
3247      ENDIF.
3248      g_sel_colsort = wa_tabctrl110_cols-screen-name.
3249      IF p_order = 'ASCENDING'.
3250        SORT g_tabctrl110_itab STABLE BY (g_sel_colsort+11) ASCENDING.
3251      ELSEIF p_order = 'DESCENDING'.
3252        SORT g_tabctrl110_itab STABLE BY (g_sel_colsort+11) DESCENDING.
3253      ENDIF.
3254    ENDFORM.                    " sort_sto
3255   *&---------------------------------------------------------------------*
3256   *&      Form  sort_spr
3257   *&---------------------------------------------------------------------*
3258   *       text
3259   *----------------------------------------------------------------------*
3260   *      -->P_G_ORDER  text
3261   *----------------------------------------------------------------------*
3262    FORM sort_spr USING    p_order.
3263      READ  TABLE tablctrl120-cols WITH  KEY selected = 'X' INTO
3264            wa_tablctrl120_cols.
3265      IF sy-subrc <> 0.
3266        MESSAGE e063(zmm_oth).
3267      ENDIF.
3268      g_sel_colsort = wa_tablctrl120_cols-screen-name.
3269      IF p_order = 'ASCENDING'.
3270        SORT g_tablctrl120_itab STABLE BY (g_sel_colsort+11) ASCENDING.
3271      ELSEIF p_order = 'DESCENDING'.
3272        SORT g_tablctrl120_itab STABLE BY (g_sel_colsort+11) DESCENDING.
3273      ENDIF.
3274    ENDFORM.                    " sort_spr
3275   *&---------------------------------------------------------------------*
3276   *&      Form  sort_cap
3277   *&---------------------------------------------------------------------*
3278   *       text
3279   *----------------------------------------------------------------------*
3280   *      -->P_G_ORDER  text
3281   *----------------------------------------------------------------------*
3282    FORM sort_cap USING    p_order.
3283      READ  TABLE tablctrl130-cols WITH  KEY selected = 'X' INTO
3284            wa_tablctrl130_cols.
3285      IF sy-subrc <> 0.
3286        MESSAGE e063(zmm_oth).
3287      ENDIF.
3288      g_sel_colsort = wa_tablctrl130_cols-screen-name.
3289      IF p_order = 'ASCENDING'.
3290        SORT g_tablctrl130_itab STABLE BY (g_sel_colsort+11) ASCENDING.
3291      ELSEIF p_order = 'DESCENDING'.
3292        SORT g_tablctrl130_itab STABLE BY (g_sel_colsort+11) DESCENDING.
3293      ENDIF.
3294    ENDFORM.                    " sort_cap
3295   *&---------------------------------------------------------------------*
3296   *&      Form  sort_dis
3297   *&---------------------------------------------------------------------*
3298   *       text
3299   *----------------------------------------------------------------------*
3300   *      -->P_G_ORDER  text
3301   *----------------------------------------------------------------------*
3302    FORM sort_dis USING    p_order.
3303      READ  TABLE tablctrl140-cols WITH  KEY selected = 'X' INTO
3304             wa_tablctrl140_cols.
3305      IF sy-subrc <> 0.
3306        MESSAGE e063(zmm_oth).
3307      ENDIF.
3308      g_sel_colsort = wa_tablctrl140_cols-screen-name.
3309      IF p_order = 'ASCENDING'.
3310        SORT g_tablctrl140_itab STABLE BY (g_sel_colsort+11) ASCENDING.
3311      ELSEIF p_order = 'DESCENDING'.
3312        SORT g_tablctrl140_itab STABLE BY (g_sel_colsort+11) DESCENDING.
3313      ENDIF.
3314    ENDFORM.                    " sort_dis
3315   *&---------------------------------------------------------------------*
3316   *&      Form  srchlp_spr_del
3317   *&---------------------------------------------------------------------*
3318   *       text
3319   *----------------------------------------------------------------------*
3320   *  -->  p1        text
3321   *  <--  p2        text
3322   *----------------------------------------------------------------------*
3323    FORM srchlp_spr_del.
3324
3325      CLEAR g_spr_par.
3326
3327      IF g_sh_capeqt = 'X' AND g_sh_mfr = '' AND g_sh_mdlno = ''.
3328        g_spr_par   = '100'.
3329      ELSEIF g_sh_capeqt = 'X' AND g_sh_mfr = 'X' AND g_sh_mdlno = ''.
3330        g_spr_par   = '120'.
3331      ELSEIF g_sh_capeqt = 'X' AND g_sh_mfr = 'X' AND g_sh_mdlno = 'X'.
3332        g_spr_par   = '123'.
3333      ELSEIF g_sh_capeqt = 'X' AND g_sh_mfr = '' AND g_sh_mdlno = 'X'.
3334        g_spr_par   = '103'.
3335      ELSEIF g_sh_capeqt = '' AND g_sh_mfr = 'X' AND g_sh_mdlno = ''.
3336        g_spr_par   = '020'.
3337      ELSEIF g_sh_capeqt = '' AND g_sh_mfr = 'X' AND g_sh_mdlno = 'X'.
3338        g_spr_par   = '023'.
3339      ELSEIF g_sh_capeqt = '' AND g_sh_mfr = '' AND g_sh_mdlno = 'X'.
3340        g_spr_par   = '003'.
3341      ENDIF.
3342
3343      CASE g_spr_par.
3344        WHEN '100'.
3345          DELETE ist_srchlp_cp
3346          WHERE atwrt <> g_tablctrl120_wa-cap_code.
3347        WHEN '120'.
3348          DELETE ist_srchlp_cp
3349          WHERE atwrt <> g_tablctrl120_wa-cap_code.  "#EC CI_FLDEXT_OK[2215424]
3350          DELETE ist_srchlp_cp
3351          WHERE mfrnr <> g_tablctrl120_wa-manu.
3352        WHEN '123'.  "#EC CI_FLDEXT_OK[2215424]
3353          DELETE ist_srchlp_cp
3354          WHERE atwrt <> g_tablctrl120_wa-cap_code.
3355          DELETE ist_srchlp_cp
3356          WHERE mfrnr <> g_tablctrl120_wa-manu.
3357          DELETE ist_srchlp_cp
3358          WHERE mdlno <> g_tablctrl120_wa-mdlno.  "#EC CI_FLDEXT_OK[2215424]
3359        WHEN '103'.
3360          DELETE ist_srchlp_cp
3361          WHERE atwrt <> g_tablctrl120_wa-cap_code. "#EC CI_FLDEXT_OK[2215424]
3362          DELETE ist_srchlp_cp
3363          WHERE mdlno <> g_tablctrl120_wa-mdlno.
3364        WHEN '020'.
3365          DELETE ist_srchlp_cp
3366          WHERE mfrnr <> g_tablctrl120_wa-manu.
3367        WHEN '023'.
3368          DELETE ist_srchlp_cp
3369          WHERE mfrnr <> g_tablctrl120_wa-manu.
3370          DELETE ist_srchlp_cp
3371          WHERE mdlno <> g_tablctrl120_wa-mdlno.
3372        WHEN '003'.
3373          DELETE ist_srchlp_cp
3374          WHERE mdlno <> g_tablctrl120_wa-mdlno.
3375      ENDCASE.
3376
3377    ENDFORM.                    " srchlp_spr_del
3378   *&---------------------------------------------------------------------*
3379   *&      Form  tcode_zcodg_attr
3380   *&---------------------------------------------------------------------*
3381   *       text
3382   *----------------------------------------------------------------------*
3383   *  -->  p1        text
3384   *  <--  p2        text
3385   *----------------------------------------------------------------------*
3386    FORM tcode_zcodg_attr.
3387      IF sy-tcode = 'ZCODG'.
3388        LOOP AT SCREEN.
3389          IF screen-group3 = 'GC'.
3390            screen-input = 1.
3391            MODIFY SCREEN.
3392          ELSEIF screen-name = 'ZMM_CDITEM-DESC1'.
3393            IF zmm_cditem-oth1 = 'X'.
3394              screen-input = 1.
3395            ELSE.
3396              screen-input = 0.
3397            ENDIF.
3398            MODIFY SCREEN.
3399
3400          ELSEIF screen-name = 'ZMM_CDITEM-DESC2'.
3401            IF zmm_cditem-oth1 = 'X' OR
3402               zmm_cditem-oth2 = 'X'.
3403              screen-input = 1.
3404            ELSE.
3405              screen-input = 0.
3406            ENDIF.
3407            MODIFY SCREEN.
3408          ELSEIF screen-name = 'ZMM_CDITEM-DESC3'.
3409            IF zmm_cditem-oth1 = 'X' OR
3410               zmm_cditem-oth2 = 'X' OR
3411               zmm_cditem-oth3 = 'X'.
3412              screen-input = 1.
3413            ELSE.
3414              screen-input = 0.
3415            ENDIF.
3416            MODIFY SCREEN.
3417
3418          ELSEIF screen-name = 'ZMM_CDITEM-DESC4'.
3419            IF zmm_cditem-oth1 = 'X' OR
3420               zmm_cditem-oth2 = 'X' OR
3421               zmm_cditem-oth3 = 'X' OR
3422               zmm_cditem-oth4 = 'X'.
3423              screen-input = 1.
3424            ELSE.
3425              screen-input = 0.
3426            ENDIF.
3427            MODIFY SCREEN.
3428          ELSEIF screen-name = 'WA_SRCHLP-MARK'.
3429            screen-input = 1.
3430            MODIFY SCREEN.
3431          ELSEIF screen-name = 'G_TABCTRL110_WA-FLAG'.
3432            screen-input = 1.
3433            MODIFY SCREEN.
3434          ELSE.
3435            screen-input = 0.
3436            MODIFY SCREEN.
3437          ENDIF.
3438        ENDLOOP.
3439      ENDIF.
3440
3441    ENDFORM.                    " tcode_zcodg_attr
3442   *&---------------------------------------------------------------------*
3443   *&      Form  update_codes
3444   *&---------------------------------------------------------------------*
3445   * TO update the created material codes in the request
3446   *----------------------------------------------------------------------*
3447   *  -->  p1        text
3448   *  <--  p2        text
3449   *----------------------------------------------------------------------*
3450    FORM update_codes.
3451      REFRESH ist_zmm_cditem.
3452      CASE zmm_cdhd_st-mtart.
3453        WHEN 'ZSTO'.
3454   *       append lines of g_TABCTRL110_itab to ist_zmm_cditem.
3455          LOOP AT g_TABCTRL110_itab INTO g_TABCTRL110_wa.
3456            MOVE-CORRESPONDING g_TABCTRL110_wa TO wa_zmm_cditem.
3457            MOVE zmm_cdhd_st-reqno TO wa_zmm_cditem-reqno.
3458            APPEND wa_zmm_cditem TO ist_zmm_cditem.
3459            CLEAR wa_zmm_cditem.
3460          ENDLOOP.
3461        WHEN 'ZSPR'.
3462   *       append lines of g_TABLCTRL120_itab to ist_zmm_cditem.
3463          LOOP AT g_TABLCTRL120_itab INTO g_TABLCTRL120_wa.
3464            MOVE-CORRESPONDING g_TABLCTRL120_wa TO wa_zmm_cditem.
3465            MOVE zmm_cdhd_st-reqno TO wa_zmm_cditem-reqno.
3466            APPEND wa_zmm_cditem TO ist_zmm_cditem.
3467            CLEAR wa_zmm_cditem.
3468          ENDLOOP.
3469        WHEN 'ZCAP'.
3470   *       append lines of g_TABLCTRL130_itab to ist_zmm_cditem.
3471          LOOP AT g_TABLCTRL130_itab INTO g_TABLCTRL130_wa.
3472            MOVE-CORRESPONDING g_TABLCTRL130_wa TO wa_zmm_cditem.
3473            MOVE zmm_cdhd_st-reqno TO wa_zmm_cditem-reqno.
3474            APPEND wa_zmm_cditem TO ist_zmm_cditem.
3475            CLEAR wa_zmm_cditem.
3476          ENDLOOP.
3477
3478        WHEN 'ZDIS'.
3479   *       append lines of g_TABLCTRL140_itab to ist_zmm_cditem.
3480          LOOP AT g_TABLCTRL140_itab INTO g_TABLCTRL140_wa.
3481            MOVE-CORRESPONDING g_TABLCTRL140_wa TO wa_zmm_cditem.
3482            MOVE zmm_cdhd_st-reqno TO wa_zmm_cditem-reqno.
3483            APPEND wa_zmm_cditem TO ist_zmm_cditem.
3484            CLEAR wa_zmm_cditem.
3485          ENDLOOP.
3486      ENDCASE.
3487      DATA lt_zmm_cditem_db TYPE TABLE OF zmm_cditem.
3488      DATA ls_zmm_cditem_db TYPE zmm_cditem.
3489   "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
3490
3491      LOOP AT ist_zmm_cditem INTO DATA(ls_cditem).
3492        CLEAR ls_zmm_cditem_db.
3493        MOVE-CORRESPONDING ls_cditem TO ls_zmm_cditem_db.
3494        APPEND ls_zmm_cditem_db TO lt_zmm_cditem_db.
3495      ENDLOOP.
3496      "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP and 15.06.2026
3497
3498         LOOP AT ist_zmm_cditem INTO ls_cditem.
3499           CLEAR ls_zmm_cditem_db.
3500           MOVE-CORRESPONDING ls_cditem TO ls_zmm_cditem_db.
3501           APPEND ls_zmm_cditem_db TO lt_zmm_cditem_db.
3502         ENDLOOP.
3503     MODIFY zmm_cditem FROM TABLE lt_zmm_cditem_db.
3504   "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP and 15.06.2026
3505   ************************************************************
3506   ****Saving the long text.                              *****
3507   ************************************************************
3508   ******Header(Correspondence)********************************
3509      PERFORM save_cors_text.
3510
3511    ENDFORM.                    " update_codes
3512   *&---------------------------------------------------------------------*
3513   *&      Form  check_reqstatus
3514   *&---------------------------------------------------------------------*
3515   *       text
3516   *----------------------------------------------------------------------*
3517   *  -->  p1        text
3518   *  <--  p2        text
3519   *----------------------------------------------------------------------*
3520    FORM check_reqstatus.
3521      DATA : l_titem TYPE i,
3522             l_citem TYPE i.
3523      CLEAR: l_titem,l_citem.
3524
3525      SELECT COUNT(*) INTO l_titem FROM zmm_cditem
3526             WHERE reqno = zmm_cdhd_st-reqno.
3527      SELECT COUNT(*) INTO l_citem FROM zmm_cditem
3528             WHERE reqno = zmm_cdhd_st-reqno
3529             AND   matcode <> ''.
3530      IF l_citem = l_titem.
3531        MOVE 'C' TO zmm_cdhd_st-reqcl.
3532      ELSEIF l_citem < l_titem.
3533        IF zmm_cdhd_st-reqcl <> 'IR'.
3534          MOVE 'IC' TO zmm_cdhd_st-reqcl.
3535        ENDIF.
3536      ENDIF.
3537
3538    ENDFORM.                    " check_reqstatus
3539   *&---------------------------------------------------------------------*
3540   *&---------------------------------------------------------------------*
3541   *&      Form  send_mail_to_cdcell
3542   *&---------------------------------------------------------------------*
3543   *       text
3544   *----------------------------------------------------------------------*
3545   *  -->  p1        text
3546   *  <--  p2        text
3547   *----------------------------------------------------------------------*
3548    FORM send_mail_to_cdcell.
3549      DATA: l_text  TYPE soli,
3550            l_name  LIKE sood1-objnam,
3551            l_title LIKE sood1-objdes,
3552            l_user  LIKE sy-uname.
3553      DATA  l_text_itab LIKE TABLE OF l_text.
3554      CLEAR : l_name,l_title,l_text,l_user.
3555      REFRESH l_text_itab.
3556   **Assignments.....
3557      l_name   = zmm_cdhd_st-reqno.
3558      CONCATENATE 'New MatCode Request for' zmm_cdhd_st-reqno
3559                  INTO l_title SEPARATED BY space.
3560      l_text = 'Please check the Request and provide the new material codes.This is'
3561   &'a system generated mail, please do not reply.'.
3562      APPEND l_text TO l_text_itab.
3563
3564      l_user = 'CODIFICATION'.
3565
3566   ***Function
3567      CALL FUNCTION 'RS_SEND_MAIL_FOR_SPOOLLIST'
3568        EXPORTING
3569   *      SPOOLNUMBER       = SY-SPONO
3570          mailname  = l_name
3571          mailtitel = l_title
3572          user      = l_user
3573        TABLES
3574          text      = l_text_itab
3575   *   EXCEPTIONS
3576   *      ERROR     = 1
3577   *      OTHERS    = 2.
3578        .
3579      IF sy-subrc <> 0.
3580   * MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
3581   *         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
3582      ENDIF.
3583
3584    ENDFORM.                    " send_mail_to_cdcell
3585   *&---------------------------------------------------------------------*
3586   *&      Form  send_mail_to_reqn
3587   *&---------------------------------------------------------------------*
3588   *       text
3589   *----------------------------------------------------------------------*
3590   *  -->  p1        text
3591   *  <--  p2        text
3592   *----------------------------------------------------------------------*
3593    FORM send_mail_to_reqn.
3594      DATA: r_text  TYPE soli,
3595            r_name  LIKE sood1-objnam,
3596            r_title LIKE sood1-objdes,
3597            r_user  TYPE sy-uname.
3598      DATA:  r_text_itab LIKE TABLE OF r_text.
3599      CLEAR : r_name,r_title,r_text.
3600      REFRESH r_text_itab.
3601   **Assignments.....
3602      r_name   = zmm_cdhd_st-reqno.
3603      CONCATENATE 'Request' zmm_cdhd_st-reqno 'Status'
3604                  INTO r_title SEPARATED BY space.
3605      r_text = 'Request has been updated.Please check the Request,Request'
3606    &'status and Correspondence within it.This is a system generated mail,'
3607    &'please do not reply. - Codification Cell'.
3608      APPEND r_text TO r_text_itab.
3609      SELECT SINGLE reqcpf INTO r_user FROM zmm_cdhd
3610             WHERE reqno = zmm_cdhd_st-reqno.
3611   ***Function
3612      CALL FUNCTION 'RS_SEND_MAIL_FOR_SPOOLLIST'
3613        EXPORTING
3614   *      SPOOLNUMBER       = SY-SPONO
3615          mailname  = r_name
3616          mailtitel = r_title
3617          user      = r_user
3618        TABLES
3619          text      = r_text_itab
3620        EXCEPTIONS
3621          error     = 1
3622          OTHERS    = 2.
3623      IF sy-subrc <> 0.
3624   * MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
3625   *         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
3626      ENDIF.
3627
3628    ENDFORM.                    " send_mail_to_reqn
3629   *&---------------------------------------------------------------------*
3630   *&      Form  confirm_deletion
3631   *&---------------------------------------------------------------------*
3632   *       text
3633   *----------------------------------------------------------------------*
3634   *  -->  p1        text
3635   *  <--  p2        text
3636   *----------------------------------------------------------------------*
3637    FORM confirm_deletion.
3638      " Begin of <RD1K960036>.
3639   *   CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
3640   *    EXPORTING
3641   *    TEXTLINE1            = 'Once deleted can not be restore, Continue?'
3642   *     TITEL                = 'Confirm Deletion'
3643   *     START_COLUMN         = 25
3644   *     START_ROW            = 6
3645   *     CANCEL_DISPLAY       = ''
3646   *    IMPORTING
3647   *     ANSWER               = g_confdel.
3648
3649      DATA : l_answer(1) TYPE c.
3650
3651      CALL FUNCTION 'POPUP_TO_CONFIRM'
3652        EXPORTING
3653          titlebar              = 'CONFRIM DELETION '
3654          text_question         = 'Once deleted can not be restore, Continue?'
3655          display_cancel_button = ' '
3656          start_column          = 25
3657          start_row             = 6
3658        IMPORTING
3659          answer                = l_answer
3660        EXCEPTIONS
3661          text_not_found        = 1
3662          OTHERS                = 2.
3663      IF sy-subrc = 0.
3664        CASE l_answer.
3665          WHEN '1'.
3666            MOVE 'J' TO g_confdel.
3667          WHEN '2'.
3668            MOVE 'N' TO g_confdel.
3669        ENDCASE.
3670      ENDIF.
3671
3672      " End of <RD1K960036>.
3673    ENDFORM.                    " confirm_deletion
3674
3675   *----------------------------------------------------------------------*
3676   *   INCLUDE MZMM_CODREQ_GCU                                            *
3677   *----------------------------------------------------------------------*
3678   *&---------------------------------------------------------------------*
3679   *&      Form  GC_FIELDS_115
3680   *&---------------------------------------------------------------------*
3681   *       text
3682   *----------------------------------------------------------------------*
3683   *  -->  p1        text
3684   *  <--  p2        text
3685   *----------------------------------------------------------------------*
3686    FORM gc_fields_115.
3687      IF g_ok_code110 = 'PB_AD'.
3688        g_TABCTRL110_wa-user_desc = g_user_desc.
3689        g_oth = ''.
3690        g_user_desc = ''.
3691      ELSE.
3692        CASE 'X'.
3693          WHEN g_TABCTRL110_wa-oth1.
3694            g_TABCTRL110_wa-desc1 = g_desc1.
3695            g_TABCTRL110_wa-desc2 = g_desc2.
3696            g_TABCTRL110_wa-desc3 = g_desc3.
3697            g_TABCTRL110_wa-desc4 = g_desc4.
3698            g_TABCTRL110_wa-matgp = g_matgp.
3699            CLEAR : g_desc1,g_desc2,g_desc3,g_desc4.
3700            MOVE : 'X' TO g_TABCTRL110_wa-oth2.
3701   *+1205050
3702            IF g_TABCTRL110_wa-desc3 <> ''.
3703              g_TABCTRL110_wa-oth3 = 'X'.
3704            ENDIF.
3705            IF g_TABCTRL110_wa-desc4 <> ''.
3706              g_TABCTRL110_wa-oth4 = 'X'.
3707            ENDIF.
3708   *-120505
3709            g_TABCTRL110_wa-user_desc = g_user_desc.
3710            LOOP AT SCREEN.
3711              IF screen-name = 'ZMM_CDITEM-DESC1' OR
3712                 screen-name = 'ZMM_CDITEM-DESC2' OR
3713                 screen-name = 'ZMM_CDITEM-DESC3' OR
3714                 screen-name = 'ZMM_CDITEM-DESC4'.
3715                screen-intensified = 1.
3716                MODIFY SCREEN.
3717              ENDIF.
3718            ENDLOOP.
3719          WHEN g_TABCTRL110_wa-oth2.
3720            g_TABCTRL110_wa-desc2 = g_desc2.
3721            g_TABCTRL110_wa-desc3 = g_desc3.
3722            g_TABCTRL110_wa-desc4 = g_desc4.
3723   *+1205050
3724            IF g_TABCTRL110_wa-desc3 <> ''.
3725              g_TABCTRL110_wa-oth3 = 'X'.
3726            ENDIF.
3727            IF g_TABCTRL110_wa-desc4 <> ''.
3728              g_TABCTRL110_wa-oth4 = 'X'.
3729            ENDIF.
3730   *+1205050
3731            CLEAR : g_desc2,g_desc3,g_desc4.
3732            g_TABCTRL110_wa-user_desc = g_user_desc.
3733            IF g_mode = 'CHA'.
3734              MODIFY g_tabctrl110_itab FROM g_TABCTRL110_wa INDEX
3735              g_curr_line_110.
3736            ENDIF.
3737          WHEN g_TABCTRL110_wa-oth3.
3738            g_TABCTRL110_wa-desc3 = g_desc3.
3739            g_TABCTRL110_wa-desc4 = g_desc4.
3740            MOVE 'X' TO g_TABCTRL110_wa-oth4.
3741            g_TABCTRL110_wa-user_desc = g_user_desc.
3742            IF g_mode = 'CHA'.
3743              MODIFY g_tabctrl110_itab FROM g_TABCTRL110_wa INDEX
3744              g_curr_line_110.
3745            ENDIF.
3746
3747            CLEAR : g_desc3,g_desc4.
3748          WHEN g_TABCTRL110_wa-oth4.
3749            g_TABCTRL110_wa-desc4 = g_desc4.
3750            g_TABCTRL110_wa-user_desc = g_user_desc.
3751   *        clear : G_DESC1,G_DESC2,G_DESC3,G_DESC4.
3752            CLEAR : g_desc4.
3753        ENDCASE.
3754      ENDIF.
3755   *  clear : G_DESC1,G_DESC2,G_DESC3,G_DESC4,g_ok_code110.
3756      CLEAR : g_desc1,g_desc2,g_desc3,g_desc4,g_ok_code110,g_user_desc.
3757
3758
3759    ENDFORM.                    " GC_FIELDS_115
3760   *&---------------------------------------------------------------------*
3761   *&      Form  GC_input_keywords
3762   *&---------------------------------------------------------------------*
3763   *       text
3764   *----------------------------------------------------------------------*
3765   *  -->  p1        text
3766   *  <--  p2        text
3767   *----------------------------------------------------------------------*
3768    FORM GC_input_keywords.
3769      CASE 'X'.
3770        WHEN g_TABCTRL110_wa-oth2.
3771          LOOP AT SCREEN.
3772            IF screen-name = 'G_DESC1'.
3773              screen-input = 0.
3774              screen-intensified = 1.
3775              MODIFY SCREEN.
3776            ENDIF.
3777          ENDLOOP.
3778          g_desc1 = g_TABCTRL110_wa-desc1.
3779        WHEN g_TABCTRL110_wa-oth3.
3780          LOOP AT SCREEN.
3781            IF screen-name = 'G_DESC1' OR screen-name = 'G_DESC2'.
3782              screen-input = 0.
3783              screen-intensified = 1.
3784
3785              MODIFY SCREEN.
3786            ENDIF.
3787          ENDLOOP.
3788          g_desc1 = g_TABCTRL110_wa-desc1.
3789          g_desc2 = g_TABCTRL110_wa-desc2.
3790
3791        WHEN g_TABCTRL110_wa-oth4.
3792          LOOP AT SCREEN.
3793            IF screen-name = 'G_DESC1' OR screen-name = 'G_DESC2' OR
3794               screen-name = 'G_DESC3'.
3795              screen-input = 0.
3796              screen-intensified = 1.
3797
3798              MODIFY SCREEN.
3799            ENDIF.
3800
3801          ENDLOOP.
3802          g_desc1 = g_TABCTRL110_wa-desc1.
3803          g_desc2 = g_TABCTRL110_wa-desc2.
3804          g_desc3 = g_TABCTRL110_wa-desc3.
3805      ENDCASE.
3806    ENDFORM.                    " GC_input_keywords
3807   *&---------------------------------------------------------------------*
3808   *&      Module  GC_CURSOR  INPUT
3809   *&---------------------------------------------------------------------*
3810   *       text
3811   *----------------------------------------------------------------------*
3812    MODULE gc_cursor INPUT.
3813    ENDMODULE.                 " GC_CURSOR  INPUT
3814   *&---------------------------------------------------------------------*
3815   *&      Form  SELECT_MATERIAL_DETAILS
3816   *&---------------------------------------------------------------------*
3817   *       text
3818   *----------------------------------------------------------------------*
3819   *  -->  p1        text
3820   *  <--  p2        text
3821   *----------------------------------------------------------------------*
3822    FORM select_material_details.
3823
3824      CLEAR do_not_change_flag.
3825
3826      IF g_mode = 'CRE' OR g_mode = 'CHA'.
3827
3828        CASE g_hits_par.
3829
3830          WHEN '0'.
3831            g_mat_fnd = '0'.
3832          WHEN '1'.
3833            IF check_pos = 1
3834               AND desc22 IS INITIAL
3835               AND desc33 IS INITIAL
3836               AND desc44 IS INITIAL.
3837              DESCRIBE TABLE ist_srchlp LINES g_mat_fnd.
3838              IF g_mat_fnd = 0.
3839                g_mat_fnd_flag = 'X'.
3840              ENDIF.
3841            ENDIF.
3842          WHEN '2'.
3843            IF check_pos = 2
3844               AND desc33 IS INITIAL
3845               AND desc44 IS INITIAL.
3846              DESCRIBE TABLE ist_srchlp LINES g_mat_fnd.
3847              IF g_mat_fnd = 0.
3848                g_mat_fnd_flag = 'X'.
3849              ENDIF.
3850            ENDIF.
3851          WHEN '3'.
3852            IF check_pos = 3
3853               AND desc44 IS INITIAL.
3854              DESCRIBE TABLE ist_srchlp LINES g_mat_fnd.
3855              IF g_mat_fnd = 0.
3856                g_mat_fnd_flag = 'X'.
3857              ENDIF.
3858            ENDIF.
3859          WHEN '4'.
3860            IF check_pos = 4. .
3861              DESCRIBE TABLE ist_srchlp LINES g_mat_fnd.
3862              IF g_mat_fnd = 0.
3863                g_mat_fnd_flag = 'X'.
3864              ENDIF.
3865            ENDIF.
3866            IF g_hits_par_oth = 'X'.
3867              DESCRIBE TABLE ist_srchlp LINES g_mat_fnd.
3868              IF g_mat_fnd = 0.
3869                g_mat_fnd_flag = 'X'.
3870              ENDIF.
3871              CLEAR g_hits_par_oth.
3872            ENDIF.
3873          WHEN OTHERS.
3874            CLEAR g_mat_fnd.
3875
3876        ENDCASE.
3877
3878        IF g_lineno_old <> g_lineno.
3879   *     clear g_mat_fnd.
3880          do_not_change_flag = 'X'.
3881        ENDIF.
3882
3883        CLEAR g_hits_par.
3884
3885      ENDIF.
3886
3887      LOOP AT ist_srchlp INTO wa_srchlp.
3888
3889        DATA : l_matnr LIKE thead-tdname.
3890        l_matnr = wa_srchlp-matnr.
3891
3892        CALL FUNCTION 'READ_TEXT'
3893          EXPORTING
3894   *        CLIENT                  = SY-MANDT
3895            id                      = 'BEST'
3896            language                = 'E'
3897            name                    = l_matnr
3898            object                  = 'MATERIAL'
3899          TABLES
3900            lines                   = lines
3901          EXCEPTIONS
3902            id                      = 1
3903            language                = 2
3904            name                    = 3
3905            not_found               = 4
3906            object                  = 5
3907            reference_check         = 6
3908            wrong_access_to_archive = 7
3909            OTHERS                  = 8.
3910
3911        IF sy-subrc <> 0.
3912   *      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
3913   *      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
3914          wa_srchlp-mark = '1'.
3915          MODIFY ist_srchlp FROM wa_srchlp.
3916        ENDIF.
3917
3918      ENDLOOP.
3919
3920    ENDFORM.                    " SELECT_MATERIAL_DETAILS
3921   *&---------------------------------------------------------------------*
3922   *&      Form  Display_text
3923   *&---------------------------------------------------------------------*
3924   *       text
3925   *----------------------------------------------------------------------*
3926   *  -->  p1        text
3927   *  <--  p2        text
3928   *----------------------------------------------------------------------*
3929    FORM Display_text.
3930
3931      DATA : l_matnr LIKE thead-tdname.
3932      DATA : l_header LIKE thead.
3933      DATA : i LIKE sy-tabix.
3934      READ TABLE ist_srchlp INTO wa_srchlp INDEX g_curr_line_100.
3935      l_matnr = wa_srchlp-matnr.
3936
3937   *  if not l_matnr is initial.
3938      IF NOT l_matnr IS INITIAL AND
3939        g_curr_line_100 <> 0.
3940        CALL FUNCTION 'READ_TEXT'
3941          EXPORTING
3942   *        CLIENT                  = SY-MANDT
3943            id                      = 'BEST'
3944            language                = 'E'
3945            name                    = l_matnr
3946            object                  = 'MATERIAL'
3947   *        ARCHIVE_HANDLE          = 0
3948   *        LOCAL_CAT               = ' '
3949   * IMPORTING
3950   *        HEADER                  =
3951          TABLES
3952            lines                   = tlinetab
3953          EXCEPTIONS
3954            id                      = 1
3955            language                = 2
3956            name                    = 3
3957            not_found               = 4
3958            object                  = 5
3959            reference_check         = 6
3960            wrong_access_to_archive = 7
3961            OTHERS                  = 8.
3962        IF sy-subrc <> 0.
3963
3964          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
3965                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
3966        ENDIF.
3967
3968
3969        CALL SCREEN 117 STARTING AT 70 15 ENDING AT 130 24.
3970
3971      ENDIF.
3972
3973    ENDFORM.                    " Display_text
3974   *&---------------------------------------------------------------------*
3975   *&      Form  text_control_eingabebereit
3976   *&---------------------------------------------------------------------*
3977   *       text
3978   *----------------------------------------------------------------------*
3979   *  -->  p1        text
3980   *  <--  p2        text
3981   *----------------------------------------------------------------------*
3982    FORM text_control_eingabebereit.
3983
3984      CALL METHOD gv_text_editor->set_readonly_mode
3985        EXPORTING
3986          readonly_mode          = gv_text_editor->true
3987        EXCEPTIONS
3988          error_cntl_call_method = 1
3989          invalid_parameter      = 2
3990          OTHERS                 = 3.
3991
3992
3993
3994    ENDFORM.                    " text_control_eingabebereit
3995   *&---------------------------------------------------------------------*
3996   *&      Form  text_control_set_text_table
3997   *&---------------------------------------------------------------------*
3998   *       text
3999   *----------------------------------------------------------------------*
4000   *  -->  p1        text
4001   *  <--  p2        text
4002   *----------------------------------------------------------------------*
4003    FORM text_control_set_text_table.
4004
4005      CALL FUNCTION 'CONVERT_ITF_TO_STREAM_TEXT'
4006        TABLES
4007          itf_text    = tlinetab
4008          text_stream = lt_text_table.
4009
4010      CALL METHOD gv_text_editor->set_text_as_stream
4011        EXPORTING
4012          text            = lt_text_table
4013        EXCEPTIONS
4014          error_dp        = 1
4015          error_dp_create = 2
4016          OTHERS          = 3.
4017
4018
4019    ENDFORM.                    " text_control_set_text_table
4020
4021
4022   *&---------------------------------------------------------------------*
4023   *&      Form  clear_srchlp_parms
4024   *&---------------------------------------------------------------------*
4025   *       text
4026   *----------------------------------------------------------------------*
4027   *  -->  p1        text
4028   *  <--  p2        text
4029   *----------------------------------------------------------------------*
4030    FORM clear_srchlp_parms.
4031
4032      CLEAR : desc11, desc22, desc33, desc44, desc55, g_partno, g_matgp,
4033              g_matty, sel_flag.
4034
4035    ENDFORM.                    " clear_srchlp_parms
4036   *&---------------------------------------------------------------------*
4037   *&      Form  Create_matcode
4038   *&---------------------------------------------------------------------*
4039   *       text
4040   *----------------------------------------------------------------------*
4041   *  -->  p1        text
4042   *  <--  p2        text
4043   *----------------------------------------------------------------------*
4044    FORM create_matcode.
4045
4046      DATA : l_num1 TYPE sy-index.
4047      DATA : l_num2(3) TYPE c.
4048
4049
4050
4051      PERFORM matcode_confirm.
4052
4053      CHECK a_choice = 'J'.
4054
4055      DO 26 TIMES.
4056
4057        it_alpha_num1-alpha = alpha+l_num1(1).
4058        l_num2 = l_num2 + 10.
4059
4060        IF l_num2 < 100.
4061          CONCATENATE '0' l_num2 INTO l_num2.
4062        ENDIF.
4063        it_alpha_num1-number = l_num2.
4064        l_num1 = l_num1 + 1.
4065        APPEND it_alpha_num1.
4066      ENDDO.
4067
4068      CASE zmm_cdhd_st-mtart.
4069
4070        WHEN 'ZSTO'.
4071
4072          DATA : l_mat_len LIKE sy-index.
4073          DATA : l_desc(87) TYPE c.
4074          DATA : l_desc1(40) TYPE c, l_desc2(48) TYPE c.
4075
4076          LOOP AT g_TABCTRL110_itab
4077                 INTO g_TABCTRL110_wa.
4078
4079   *        if      g_TABCTRL110_wa-oth1 = 'X'
4080   *             or g_TABCTRL110_wa-oth2 = 'X'
4081   *             or g_TABCTRL110_wa-oth3 = 'X'
4082   *             or g_TABCTRL110_wa-oth4 = 'X'.
4083   *          check_others = 'X'.
4084   *        endif.
4085
4086            IF ( g_TABCTRL110_wa-matcode IS INITIAL
4087                    OR g_TABCTRL110_wa-matcode = '000000000' )
4088   *                and check_others <> 'X'
4089                    AND g_TABCTRL110_wa-comp_flg IS INITIAL
4090                    AND g_tabctrl110_wa-rej_flg  IS INITIAL.
4091
4092              l_desc = g_TABCTRL110_wa-desc_fin.
4093              l_mat_len = strlen( l_desc ).
4094
4095              IF l_mat_len <= 40 .
4096
4097                l_desc1 = l_desc.
4098
4099                seltab-selname = 'P_DESC1'.
4100                seltab-sign    = 'I'.
4101                seltab-option = 'EQ'.
4102                seltab-low   = l_desc1.
4103                APPEND seltab TO ist_seltab.
4104
4105                CLEAR l_desc2.
4106
4107                seltab-selname = 'P_DESC2'.
4108                seltab-sign    = 'I'.
4109                seltab-option = 'EQ'.
4110                seltab-low   = l_desc2.
4111                APPEND seltab TO ist_seltab.
4112
4113              ELSE.
4114
4115                l_desc1 = l_desc+0(39).
4116                CONCATENATE l_desc1 '*' INTO l_desc1.
4117                l_desc2 = l_desc+39(48).
4118
4119                seltab-selname = 'P_DESC1'.
4120                seltab-sign    = 'I'.
4121                seltab-option = 'EQ'.
4122                seltab-low   = l_desc1.
4123                APPEND seltab TO ist_seltab.
4124
4125                seltab-selname = 'P_DESC2'.
4126                seltab-sign    = 'I'.
4127                seltab-option = 'EQ'.
4128                seltab-low   = l_desc2.
4129                APPEND seltab TO ist_seltab.
4130
4131              ENDIF.
4132
4133              seltab-selname = 'P_UOM'.
4134              seltab-sign    = 'I'.
4135              seltab-option = 'EQ'.
4136              seltab-low   = g_TABCTRL110_wa-uom.
4137              APPEND seltab TO ist_seltab.
4138
4139              seltab-selname = 'P_MATKL'.
4140              seltab-sign    = 'I'.
4141              seltab-option = 'EQ'.
4142              seltab-low   = g_TABCTRL110_wa-matgp.
4143              APPEND seltab TO ist_seltab.
4144
4145              seltab-selname = 'P_MTART'.
4146              seltab-sign    = 'I'.
4147              seltab-option = 'EQ'.
4148              seltab-low   = zmm_cdhd_st-mtart.
4149              APPEND seltab TO ist_seltab.
4150
4151              SUBMIT zmm01_test WITH SELECTION-TABLE ist_seltab AND RETURN.
4152              GET PARAMETER ID 'NEW_MATCODE' FIELD g_TABCTRL110_wa-matcode.
4153              IF g_TABCTRL110_wa-matcode IS INITIAL
4154                 OR g_TABCTRL110_wa-matcode = '000000000'.
4155                g_TABCTRL110_wa-comp_flg = 'E'.
4156                SELECT SINGLE * FROM zmm_codreq_rsn INTO wa_rsn
4157                WHERE reason = 'E'.
4158                g_TABCTRL110_wa-rsn = wa_rsn-description.
4159              ELSE.
4160                matgen_flag = 'X'.
4161                g_TABCTRL110_wa-comp_flg = 'N'.
4162                SELECT SINGLE * FROM zmm_codreq_rsn INTO wa_rsn
4163                WHERE reason = 'N'.
4164                g_TABCTRL110_wa-rsn = wa_rsn-description.
4165   ***********************************************************************
4166                DATA: l_srno LIKE zmm_cditem-srno.
4167                CLEAR ist_textid.
4168                MOVE g_TABCTRL110_wa-srno TO l_srno.
4169                CONCATENATE 'CDDS' zmm_cdhd_st-reqno l_srno
4170                INTO ist_textid-tdname.
4171
4172                ist_textid-tdobject   = 'ZMMCD'.
4173                ist_textid-tdid       = 'CDDS'.
4174                ist_textid-tdspras    =  sy-langu.
4175                ist_textid-tdlinesize =  72.
4176   ***Appending to internal table for all textid/name.
4177                APPEND ist_textid TO ist_textid_items.
4178
4179                CLEAR   : ist_dtspecs.
4180                REFRESH : ist_dtspecs.
4181
4182                PERFORM read_text_data TABLES ist_dtspecs USING ist_textid.
4183
4184                CLEAR : wa_textid.
4185
4186                wa_textid-tdname   = g_TABCTRL110_wa-matcode.
4187                wa_textid-tdid     = 'BEST'.
4188                wa_textid-tdspras  = 'E'.
4189                wa_textid-tdobject = 'MATERIAL'.
4190
4191                PERFORM save_text.
4192
4193                CLEAR   : ist_dtspecs.
4194                REFRESH : ist_dtspecs.
4195
4196   **********************************************************************
4197
4198              ENDIF.
4199              MODIFY g_TABCTRL110_itab FROM g_TABCTRL110_wa.
4200              CLEAR g_TABCTRL110_wa-comp_flg.
4201
4202              CLEAR seltab.
4203              REFRESH ist_seltab.
4204            ENDIF.
4205
4206   ***********************************************************************
4207   *
4208   *       if check_others = 'X'.
4209   *                  g_TABCTRL110_wa-comp_flg = 'E'.
4210   *                  select single * from ZMM_CODREQ_RSN into wa_rsn
4211   *                  where reason = 'E'.
4212   *                  g_TABCTRL110_wa-rsn = wa_rsn-description.
4213   *
4214   *          modify g_TABCTRL110_itab from g_TABCTRL110_wa.
4215   *
4216   *          clear g_TABCTRL110_wa-comp_flg.
4217   *
4218   *                  clear check_others.
4219   *
4220   *       endif.
4221   *
4222   **********************************************************************
4223            CLEAR : g_TABCTRL110_wa-comp_flg,
4224                    g_TABCTRL110_wa-rsn.
4225          ENDLOOP.
4226
4227        WHEN 'ZSPR'.
4228
4229          DATA : l_mpartno_len LIKE sy-index.
4230          DATA : l_mpartno LIKE g_TABLCTRL120_wa-partno.
4231          DATA : l_mpartno1(30) TYPE c.
4232          DATA : l_mpartno2(10) TYPE c.
4233          DATA : l_mfgname(30) TYPE c.
4234
4235          LOOP AT g_TABLCTRL120_itab
4236                   INTO g_TABLCTRL120_wa.
4237
4238
4239            IF ( g_TABLCTRL120_wa-matcode IS INITIAL
4240                      OR g_TABLCTRL120_wa-matcode = '000000000' )
4241   *                and check_others <> 'X'
4242                      AND g_TABLCTRL120_wa-comp_flg IS INITIAL
4243                      AND g_tablctrl120_wa-rej_flg  IS INITIAL.
4244
4245              l_mpartno = g_TABLCTRL120_wa-partno.
4246              l_desc = g_TABLCTRL120_wa-desc_fin.
4247              l_mpartno_len = strlen( l_mpartno ).
4248              l_mat_len = strlen( l_desc ).
4249
4250              IF l_mat_len <= 40 .
4251
4252                l_desc1 = l_desc.
4253
4254                seltab-selname = 'P_DESC1'.
4255                seltab-sign    = 'I'.
4256                seltab-option = 'EQ'.
4257                seltab-low   = l_desc1.
4258                APPEND seltab TO ist_seltab.
4259
4260                CLEAR l_desc2.
4261
4262                seltab-selname = 'P_DESC2'.
4263                seltab-sign    = 'I'.
4264                seltab-option = 'EQ'.
4265                seltab-low   = l_desc2.
4266                APPEND seltab TO ist_seltab.
4267
4268              ELSE.
4269
4270                l_desc1 = l_desc+0(39).
4271                CONCATENATE l_desc1 '*' INTO l_desc1.
4272                l_desc2 = l_desc+39(48).
4273
4274                seltab-selname = 'P_DESC1'.
4275                seltab-sign    = 'I'.
4276                seltab-option = 'EQ'.
4277                seltab-low   = l_desc1.
4278                APPEND seltab TO ist_seltab.
4279
4280                seltab-selname = 'P_DESC2'.
4281                seltab-sign    = 'I'.
4282                seltab-option = 'EQ'.
4283                seltab-low   = l_desc2.
4284                APPEND seltab TO ist_seltab.
4285
4286              ENDIF.
4287
4288              seltab-selname = 'P_UOM'.
4289              seltab-sign    = 'I'.
4290              seltab-option = 'EQ'.
4291              seltab-low   = g_TABLCTRL120_wa-uom.
4292              APPEND seltab TO ist_seltab.
4293
4294              seltab-selname = 'P_MATKL'.
4295              seltab-sign    = 'I'.
4296              seltab-option = 'EQ'.
4297              seltab-low   = g_TABLCTRL120_wa-matgp.
4298              APPEND seltab TO ist_seltab.
4299
4300              SELECT SINGLE name1 FROM lfa1 INTO l_mfgname
4301                     WHERE lifnr = g_TABLCTRL120_wa-manu.
4302
4303              seltab-selname = 'P_MFGNME'.
4304              seltab-sign    = 'I'.
4305              seltab-option = 'EQ'.
4306              seltab-low   = l_mfgname.
4307              APPEND seltab TO ist_seltab.
4308   *
4309              seltab-selname = 'P_MFGCDE'.
4310              seltab-sign    = 'I'.
4311              seltab-option = 'EQ'.
4312              seltab-low   = g_TABLCTRL120_wa-manu.
4313              APPEND seltab TO ist_seltab.
4314
4315              seltab-selname = 'P_CPCDE'.
4316              seltab-sign    = 'I'.
4317              seltab-option = 'EQ'.
4318              seltab-low   = g_TABLCTRL120_wa-cap_code.
4319              APPEND seltab TO ist_seltab.
4320
4321              seltab-selname = 'P_CPCDED'.
4322              seltab-sign    = 'I'.
4323              seltab-option = 'EQ'.
4324              seltab-low   = g_TABLCTRL120_wa-cap_name.
4325              APPEND seltab TO ist_seltab.
4326
4327              seltab-selname = 'P_MDLCDE'.
4328              seltab-sign    = 'I'.
4329              seltab-option = 'EQ'.
4330              seltab-low   = g_TABLCTRL120_wa-mdlno+0(45).
4331              APPEND seltab TO ist_seltab.
4332
4333
4334              IF l_mpartno_len <= 30.
4335
4336                l_mpartno1 = l_mpartno.
4337
4338                seltab-selname = 'P_MPRTN1'.
4339                seltab-sign    = 'I'.
4340                seltab-option = 'EQ'.
4341                seltab-low   = l_mpartno1.
4342                APPEND seltab TO ist_seltab.
4343
4344                l_mpartno2 = ''.
4345
4346              ELSE.
4347
4348                l_mpartno1 = l_mpartno.
4349
4350                seltab-selname = 'P_MPRTN2'.
4351                seltab-sign    = 'I'.
4352                seltab-option = 'EQ'.
4353                seltab-low   = l_mpartno1.
4354                APPEND seltab TO ist_seltab.
4355
4356                l_mpartno2 = l_mpartno+30(10).
4357
4358                seltab-selname = 'P_MPRTN2'.
4359                seltab-sign    = 'I'.
4360                seltab-option = 'EQ'.
4361                seltab-low   = l_mpartno2.
4362                APPEND seltab TO ist_seltab.
4363
4364              ENDIF.
4365
4366              seltab-selname = 'P_MPRTN'.
4367              seltab-sign    = 'I'.
4368              seltab-option = 'EQ'.
4369              seltab-low   = l_mpartno.
4370              APPEND seltab TO ist_seltab.
4371
4372   *          seltab-selname = 'P_MCODE'.
4373   *          seltab-sign    = 'I'.
4374   *          seltab-option = 'EQ'.
4375   *          seltab-low   = g_TABLCTRL120_wa-matgp.
4376   *          append seltab to ist_seltab.
4377
4378              seltab-selname = 'P_DESC'.
4379              seltab-sign    = 'I'.
4380              seltab-option = 'EQ'.
4381              seltab-low   = g_TABLCTRL120_wa-desc_fin.
4382              APPEND seltab TO ist_seltab.
4383
4384              seltab-selname = 'P_MTART'.
4385              seltab-sign    = 'I'.
4386              seltab-option = 'EQ'.
4387              seltab-low   = zmm_cdhd_st-mtart.
4388              APPEND seltab TO ist_seltab.
4389
4390
4391              SUBMIT zmm01_test WITH SELECTION-TABLE ist_seltab AND RETURN.
4392              GET PARAMETER ID 'NEW_MATCODE' FIELD g_TABLCTRL120_wa-matcode.
4393              IF g_TABLCTRL120_wa-matcode IS INITIAL
4394                 OR g_TABLCTRL120_wa-matcode = '000000000'.
4395                g_TABLCTRL120_wa-comp_flg = 'E'.
4396                SELECT SINGLE * FROM zmm_codreq_rsn INTO wa_rsn
4397                WHERE reason = 'E'.
4398                g_TABLCTRL120_wa-rsn = wa_rsn-description.
4399              ELSE.
4400                matgen_flag = 'X'.
4401                g_TABLCTRL120_wa-comp_flg = 'N'.
4402                SELECT SINGLE * FROM zmm_codreq_rsn INTO wa_rsn
4403                WHERE reason = 'N'.
4404                g_TABLCTRL120_wa-rsn = wa_rsn-description.
4405   ***********************************************************************
4406   *            Data: l_srno like ZMM_CDITEM-SRNO.
4407                CLEAR ist_textid.
4408                MOVE g_TABLCTRL120_wa-srno TO l_srno.
4409                CONCATENATE 'CDDS' zmm_cdhd_st-reqno l_srno
4410                INTO ist_textid-tdname.
4411
4412                ist_textid-tdobject   = 'ZMMCD'.
4413                ist_textid-tdid       = 'CDDS'.
4414                ist_textid-tdspras    =  sy-langu.
4415                ist_textid-tdlinesize =  72.
4416   ***Appending to internal table for all textid/name.
4417                APPEND ist_textid TO ist_textid_items.
4418
4419                CLEAR   : ist_dtspecs.
4420                REFRESH : ist_dtspecs.
4421
4422                PERFORM read_text_data TABLES ist_dtspecs USING ist_textid.
4423                CLEAR : wa_textid.
4424
4425                wa_textid-tdname   = g_TABLCTRL120_wa-matcode.
4426                wa_textid-tdid     = 'BEST'.
4427                wa_textid-tdspras  = 'E'.
4428                wa_textid-tdobject = 'MATERIAL'.
4429
4430                PERFORM save_text.
4431
4432                CLEAR   : ist_dtspecs.
4433                REFRESH : ist_dtspecs.
4434
4435   **********************************************************************
4436
4437              ENDIF.
4438              MODIFY g_TABLCTRL120_itab FROM g_TABLCTRL120_wa.
4439              CLEAR g_TABLCTRL120_wa-comp_flg.
4440
4441              CLEAR seltab.
4442              REFRESH ist_seltab.
4443            ENDIF.
4444            CLEAR : g_TABLCTRL120_wa-comp_flg,
4445            g_TABLCTRL120_wa-rsn.
4446          ENDLOOP.
4447
4448        WHEN 'ZCAP'.
4449
4450          DATA : l_matcost(15) TYPE c.
4451
4452          LOOP AT g_TABLCTRL130_itab
4453                   INTO g_TABLCTRL130_wa.
4454
4455
4456            IF ( g_TABLCTRL130_wa-matcode IS INITIAL
4457                      OR g_TABLCTRL130_wa-matcode = '000000000' )
4458   *                and check_others <> 'X'
4459                      AND g_TABLCTRL130_wa-comp_flg IS INITIAL
4460                      AND g_tablctrl130_wa-rej_flg  IS INITIAL.
4461
4462              l_desc = g_TABLCTRL130_wa-desc_fin.
4463              l_mat_len = strlen( l_desc ).
4464
4465              IF l_mat_len <= 40 .
4466
4467                l_desc1 = l_desc.
4468
4469                seltab-selname = 'P_DESC1'.
4470                seltab-sign    = 'I'.
4471                seltab-option = 'EQ'.
4472                seltab-low   = l_desc1.
4473                APPEND seltab TO ist_seltab.
4474
4475                CLEAR l_desc2.
4476
4477                seltab-selname = 'P_DESC2'.
4478                seltab-sign    = 'I'.
4479                seltab-option = 'EQ'.
4480                seltab-low   = l_desc2.
4481                APPEND seltab TO ist_seltab.
4482
4483              ELSE.
4484
4485                l_desc1 = l_desc+0(39).
4486                CONCATENATE l_desc1 '*' INTO l_desc1.
4487                l_desc2 = l_desc+39(48).
4488
4489                seltab-selname = 'P_DESC1'.
4490                seltab-sign    = 'I'.
4491                seltab-option = 'EQ'.
4492                seltab-low   = l_desc1.
4493                APPEND seltab TO ist_seltab.
4494
4495                seltab-selname = 'P_DESC2'.
4496                seltab-sign    = 'I'.
4497                seltab-option = 'EQ'.
4498                seltab-low   = l_desc2.
4499                APPEND seltab TO ist_seltab.
4500
4501              ENDIF.
4502
4503              seltab-selname = 'P_UOM'.
4504              seltab-sign    = 'I'.
4505              seltab-option = 'EQ'.
4506              seltab-low   = g_TABLCTRL130_wa-uom.
4507              APPEND seltab TO ist_seltab.
4508
4509              seltab-selname = 'P_MATKL'.
4510              seltab-sign    = 'I'.
4511              seltab-option = 'EQ'.
4512              seltab-low   = '0C'.
4513              APPEND seltab TO ist_seltab.
4514
4515
4516              l_matcost = g_TABLCTRL130_wa-matcost.
4517
4518              seltab-selname = 'P_MATCOS'.
4519              seltab-sign    = 'I'.
4520              seltab-option = 'EQ'.
4521              seltab-low   = l_matcost.
4522              APPEND seltab TO ist_seltab.
4523
4524              seltab-selname = 'P_MATCAT'.
4525              seltab-sign    = 'I'.
4526              seltab-option = 'EQ'.
4527              seltab-low   = g_TABLCTRL130_wa-matcatg+0(45).
4528              APPEND seltab TO ist_seltab.
4529
4530              seltab-selname = 'P_MATLOC'.
4531              seltab-sign    = 'I'.
4532              seltab-option = 'EQ'.
4533              seltab-low   = g_TABLCTRL130_wa-matloc+0(45).
4534              APPEND seltab TO ist_seltab.
4535
4536              seltab-selname = 'P_WKLIFE'.
4537              seltab-sign    = 'I'.
4538              seltab-option = 'EQ'.
4539              seltab-low   = g_TABLCTRL130_wa-wrkng_life.
4540
4541              APPEND seltab TO ist_seltab.
4542
4543              seltab-selname = 'P_MATGP'.
4544              seltab-sign    = 'I'.
4545              seltab-option = 'EQ'.
4546              seltab-low   = g_TABLCTRL130_wa-spa_grp.
4547              APPEND seltab TO ist_seltab.
4548
4549              seltab-selname = 'P_DESC'.
4550              seltab-sign    = 'I'.
4551              seltab-option = 'EQ'.
4552              seltab-low   = g_TABLCTRL130_wa-desc_fin.
4553              APPEND seltab TO ist_seltab.
4554
4555              seltab-selname = 'P_MTART'.
4556              seltab-sign    = 'I'.
4557              seltab-option = 'EQ'.
4558              seltab-low   = zmm_cdhd_st-mtart.
4559              APPEND seltab TO ist_seltab.
4560
4561              DATA : l_matnr(8) TYPE c.
4562              DATA : rcode_number_get LIKE inri-returncode.
4563              DATA : matnr LIKE mara-matnr.
4564              DATA : l_number_range LIKE it_cap_group1-number_range.
4565
4566
4567
4568              SELECT * FROM zmm_cap_group INTO TABLE it_cap_group1
4569                     WHERE description = g_TABLCTRL130_wa-matcatg+0(30).
4570
4571              IF sy-subrc = 0.
4572                SORT it_cap_group1 BY number_range description ASCENDING.
4573                LOOP AT it_cap_group1.
4574                  IF it_cap_group1-used_flag = 'X'.
4575                    CONTINUE.
4576                  ELSE.
4577                    EXIT.
4578                  ENDIF.
4579                ENDLOOP.
4580              ENDIF.
4581
4582              l_number_range = it_cap_group1-number_range.
4583
4584              DO.
4585
4586                CALL FUNCTION 'NUMBER_GET_NEXT'
4587                  EXPORTING
4588                    nr_range_nr = l_number_range
4589                    object      = 'ZMATERIALC'
4590                  IMPORTING
4591                    number      = l_matnr
4592                    returncode  = rcode_number_get.
4593
4594                DATA : l_alphaa TYPE c.
4595                DATA : l_char2(2) TYPE c.
4596                DATA : l_char3(3) TYPE c.
4597
4598                l_char3 = l_matnr+2(3).
4599
4600                READ TABLE it_alpha_num1 WITH KEY number = l_char3.
4601                l_alphaa = it_alpha_num1-alpha.
4602
4603                l_char2 = l_matnr+2(2).
4604
4605                IF l_char2 EQ '00'.
4606
4607                  CONCATENATE '0C' l_matnr+4(4) '000' INTO matnr.
4608
4609                ELSE.
4610
4611                  CONCATENATE '0C' l_alphaa l_matnr+5(3) '000' INTO matnr.
4612
4613                ENDIF.
4614
4615                CALL FUNCTION 'MARA_SINGLE_READ'
4616                  EXPORTING
4617                    matnr      = matnr
4618                    sperrmodus = ' '
4619                  IMPORTING
4620                    wmara      = mara
4621                  EXCEPTIONS
4622                    not_found  = 4
4623                    OTHERS     = 5.
4624
4625                IF sy-subrc EQ 0.
4626                  CONTINUE.
4627                ELSE.
4628                  EXIT.
4629                ENDIF.
4630
4631              ENDDO.
4632
4633              seltab-selname = 'P_MATNR'.
4634              seltab-sign    = 'I'.
4635              seltab-option = 'EQ'.
4636              seltab-low   = matnr.
4637              APPEND seltab TO ist_seltab.
4638
4639              SUBMIT zmm01_test WITH SELECTION-TABLE ist_seltab AND RETURN.
4640              GET PARAMETER ID 'NEW_MATCODE' FIELD g_TABLCTRL130_wa-matcode.
4641              IF g_TABLCTRL130_wa-matcode IS INITIAL
4642                 OR g_TABLCTRL130_wa-matcode = '000000000'.
4643                g_TABLCTRL130_wa-comp_flg = 'E'.
4644                SELECT SINGLE * FROM zmm_codreq_rsn INTO wa_rsn
4645                WHERE reason = 'E'.
4646                g_TABLCTRL130_wa-rsn = wa_rsn-description.
4647              ELSE.
4648                matgen_flag = 'X'.
4649                g_TABLCTRL130_wa-comp_flg = 'N'.
4650                SELECT SINGLE * FROM zmm_codreq_rsn INTO wa_rsn
4651                WHERE reason = 'N'.
4652                g_TABLCTRL130_wa-rsn = wa_rsn-description.
4653   ***********************************************************************
4654   *            Data: l_srno like ZMM_CDITEM-SRNO.
4655                CLEAR ist_textid.
4656                MOVE g_TABLCTRL130_wa-srno TO l_srno.
4657                CONCATENATE 'CDDS' zmm_cdhd_st-reqno l_srno
4658                INTO ist_textid-tdname.
4659
4660                ist_textid-tdobject   = 'ZMMCD'.
4661                ist_textid-tdid       = 'CDDS'.
4662                ist_textid-tdspras    =  sy-langu.
4663                ist_textid-tdlinesize =  72.
4664   ***Appending to internal table for all textid/name.
4665                APPEND ist_textid TO ist_textid_items.
4666
4667                CLEAR   : ist_dtspecs.
4668                REFRESH : ist_dtspecs.
4669
4670                PERFORM read_text_data TABLES ist_dtspecs USING ist_textid.
4671                CLEAR : wa_textid.
4672
4673                wa_textid-tdname   = g_TABLCTRL130_wa-matcode.
4674                wa_textid-tdid     = 'BEST'.
4675                wa_textid-tdspras  = 'E'.
4676                wa_textid-tdobject = 'MATERIAL'.
4677
4678                PERFORM save_text.
4679
4680                CLEAR   : ist_dtspecs.
4681                REFRESH : ist_dtspecs.
4682
4683   **********************************************************************
4684
4685              ENDIF.
4686              MODIFY g_TABLCTRL130_itab FROM g_TABLCTRL130_wa.
4687              CLEAR g_TABLCTRL130_wa-comp_flg.
4688
4689              CLEAR seltab.
4690              REFRESH ist_seltab.
4691            ENDIF.
4692            CLEAR : g_TABLCTRL130_wa-comp_flg,
4693            g_TABLCTRL130_wa-rsn.
4694          ENDLOOP.
4695
4696      ENDCASE.
4697
4698      PERFORM save_request.
4699
4700    ENDFORM.                    " Create_matcode
4701   *&---------------------------------------------------------------------*
4702   *&      Form  update_approval
4703   *&---------------------------------------------------------------------*
4704   *       text
4705   *----------------------------------------------------------------------*
4706   *  -->  p1        text
4707   *  <--  p2        text
4708   *----------------------------------------------------------------------*
4709    FORM update_release.
4710      UPDATE zmm_cdhd SET status_flag = 'X'
4711      WHERE reqno = zmm_cdhd_st-reqno.
4712      MESSAGE i019(zmm_oth) WITH zmm_cdhd_st-reqno.
4713      PERFORM save_cors_text.
4714      PERFORM clear_var.
4715
4716    ENDFORM.                    " update_approval
4717   *&---------------------------------------------------------------------*
4718   *&      Form  Insert_modif
4719   *&---------------------------------------------------------------------*
4720   *       text
4721   *----------------------------------------------------------------------*
4722   *  -->  p1        text
4723   *  <--  p2        text
4724   *----------------------------------------------------------------------*
4725    FORM Insert_modif.
4726      CLEAR zmm_modifier.
4727      READ TABLE g_tabctrl110_itab INTO g_tabctrl110_wa WITH KEY flag = 'X'.
4728
4729      IF sy-subrc = 0.
4730        IF ( g_tabctrl110_wa-oth1 = 'X' OR
4731             g_tabctrl110_wa-oth2 = 'X' OR
4732             g_tabctrl110_wa-oth3 = 'X' OR
4733             g_tabctrl110_wa-oth4 = 'X' ) AND
4734              g_tabctrl110_wa-comp_flg+0(1) <> 'S'.
4735
4736          MOVE: g_tabctrl110_wa-matgp TO zmm_modifier-matgrp,
4737                g_tabctrl110_wa-desc1 TO zmm_modifier-desc1,
4738                g_tabctrl110_wa-desc2 TO zmm_modifier-desc2,
4739                g_tabctrl110_wa-desc3 TO zmm_modifier-desc3,
4740                g_tabctrl110_wa-desc4 TO zmm_modifier-desc4,
4741                sy-uname              TO zmm_modifier-created_by,
4742                sy-datum              TO zmm_modifier-create_date.
4743          INSERT INTO zmm_modifier VALUES zmm_modifier.
4744   *         g_tabctrl110_wa-oth1 = '' .
4745   *         g_tabctrl110_wa-oth2 = '' .
4746   *         g_tabctrl110_wa-oth3 = '' .
4747   *      concatenate zmm_modifier-desc1 modif_list
4748          REPLACE 'M' WITH '' INTO g_tabctrl110_wa-comp_flg .
4749
4750          MODIFY g_tabctrl110_itab FROM g_tabctrl110_wa INDEX sy-tabix
4751          TRANSPORTING comp_flg.
4752          CALL FUNCTION 'POPUP_TO_DISPLAY_VALUE'
4753            EXPORTING
4754              colbeg    = 1
4755              colend    = 5
4756              itemtxt   = 'Following modifiers inserted'
4757              textline1 = zmm_modifier-desc1
4758              textline2 = zmm_modifier-desc2
4759              textline3 = zmm_modifier-desc3
4760              textline4 = zmm_modifier-desc4
4761              title     = 'Modifiers inserted'.
4762
4763   *      CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
4764   *           EXPORTING
4765   *                TITEL        = 'Insert Modifiers '
4766   *                TEXTLINE1    = 'Following Modifiers inserted.'
4767   *                TEXTLINE2    =
4768   *                START_COLUMN = 25
4769   *                START_ROW    = 6.
4770        ELSE.
4771          MESSAGE i035(zmm_oth).
4772        ENDIF.
4773      ELSE.
4774        MESSAGE i040(zmm_oth).
4775      ENDIF.
4776    ENDFORM.                    " Insert_modif
4777   *&---------------------------------------------------------------------*
4778   *&      Form  reset_other
4779   *&---------------------------------------------------------------------*
4780   *       text
4781   *----------------------------------------------------------------------*
4782   *  -->  p1        text
4783   *  <--  p2        text
4784   *----------------------------------------------------------------------*
4785    FORM reset_other.
4786      IF g_ok_code115 <> 'CANC'.
4787        CASE 'OTHER'.
4788          WHEN g_TABCTRL110_wa-desc1.
4789            CLEAR : g_TABCTRL110_wa-desc1,
4790                    g_TABCTRL110_wa-oth1,
4791                    g_TABCTRL110_wa-matgp.
4792
4793          WHEN g_TABCTRL110_wa-desc2.
4794            CLEAR: g_TABCTRL110_wa-desc2,
4795                   g_TABCTRL110_wa-oth2.
4796
4797          WHEN g_TABCTRL110_wa-desc3.
4798            CLEAR: g_TABCTRL110_wa-desc3,
4799                   g_TABCTRL110_wa-oth3.
4800
4801          WHEN g_TABCTRL110_wa-desc4.
4802            CLEAR: g_TABCTRL110_wa-desc4,
4803                   g_TABCTRL110_wa-oth2 .
4804        ENDCASE.
4805   *+1105
4806      ELSE.
4807        CASE 'OTHER'.
4808          WHEN g_TABCTRL110_wa-desc1.
4809            CLEAR : g_TABCTRL110_wa-desc1,
4810                    g_TABCTRL110_wa-oth1.
4811          WHEN g_TABCTRL110_wa-desc2.
4812            CLEAR: g_TABCTRL110_wa-desc2,
4813                   g_TABCTRL110_wa-oth2.
4814
4815          WHEN g_TABCTRL110_wa-desc3.
4816            CLEAR: g_TABCTRL110_wa-desc3,
4817                   g_TABCTRL110_wa-oth3.
4818
4819          WHEN g_TABCTRL110_wa-desc4.
4820            CLEAR: g_TABCTRL110_wa-desc4,
4821                   g_TABCTRL110_wa-oth2 .
4822        ENDCASE.
4823   *-1105
4824      ENDIF.
4825    ENDFORM.                    " reset_other
4826   *&---------------------------------------------------------------------*
4827   *&      Form  other_check
4828   *&---------------------------------------------------------------------*
4829   *       text
4830   *----------------------------------------------------------------------*
4831   *  -->  p1        text
4832   *  <--  p2        text
4833   *----------------------------------------------------------------------*
4834    FORM other_check.
4835      IF sy-ucomm <> 'CANC' . "X in toolbar of modal screen
4836        CASE 'X'.
4837          WHEN g_TABCTRL110_wa-oth1.
4838            IF g_desc1 = '' OR
4839               g_desc2 = ''.
4840              MESSAGE e007(zmm_oth) WITH 'DESC1' 'DESC2'.
4841   *      elseif g_desc4 <> '' and g_desc3 = ''.
4842   *        message e003(ZMM_OTH) with 'DESC1' 'DESC2'.
4843            ENDIF.
4844            IF g_desc4 <> ''.
4845              IF g_desc3 = ''.
4846                MESSAGE e007(zmm_oth).
4847              ENDIF.
4848            ENDIF.
4849
4850          WHEN g_TABCTRL110_wa-oth2.
4851            IF g_desc2 IS INITIAL.
4852              MESSAGE e007(zmm_oth) WITH 'DESC2'.
4853            ENDIF.
4854            IF g_desc4 <> ''.
4855              IF g_desc3 = ''.
4856                MESSAGE e007(zmm_oth).
4857              ENDIF.
4858            ENDIF.
4859          WHEN g_TABCTRL110_wa-oth3.
4860            IF g_desc3 IS INITIAL.
4861              MESSAGE e007(zmm_oth) WITH 'DESC3'.
4862            ENDIF.
4863          WHEN g_TABCTRL110_wa-oth4.
4864            IF g_desc4 IS INITIAL.
4865              MESSAGE e007(zmm_oth) WITH 'DESC4'.
4866            ENDIF.
4867        ENDCASE.
4868      ENDIF.
4869
4870
4871    ENDFORM.                    " other_check
4872   *****************************************************
4873    FORM find_user.
4874   *****************************************************
4875   *clear g_user.
4876   *
4877
4878   *Data : auth_field1(2) Value 'IM', auth_field2(2) value 'L2'.
4879
4880      AUTHORITY-CHECK OBJECT 'ZMM_CD'
4881                          ID 'ZMM_CODIFR' FIELD '01'.
4882      IF sy-subrc = 0 .
4883        g_user = 'X'.  "Codifier.
4884      ELSE.
4885   * MRP CONTROLLER AUTH CHECK.
4886        AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
4887                            ID 'FRGCO' FIELD '02'.
4888
4889   *                        ACTVT WERKS '01'.
4890   *                        ID 'FRGGR' FIELD '02'.
4891
4892        IF sy-subrc = 0.
4893          g_user = 'M'.
4894        ELSE.
4895          AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
4896                             ID 'FRGCO' FIELD : 'L2',
4897                                                'L1',
4898                                                'HS',
4899                                                'HL',
4900                                                'HC',
4901                                                '1A',
4902                                                '1B',
4903                                                '1C',
4904                                                '1D',
4905                                                '1E',
4906                                                '1F',
4907                                                'DI',
4908                                                'DF',
4909                                                'CS',
4910                                                'BO',
4911                                                'MD',
4912                                                'EC'.
4913
4914          IF sy-subrc = 0.
4915            g_user = 'L'.
4916          ELSE.
4917            g_user = ''.
4918          ENDIF.
4919        ENDIF.
4920      ENDIF.
4921
4922
4923   *
4924      g_user_found = 'X'.
4925   *if g_mode = 'REL'.
4926   *select single * from agr_users where uname = sy-uname and agr_name =
4927   *'D:MM_MAT_IND_APPROVE_02'.
4928   *
4929   *if sy-subrc = 0.
4930   *   g_user = 'M'.
4931   *else.
4932   *   select single * from agr_users where uname = sy-uname and agr_name =
4933   *   'D:MM_SRV_IND_APPROVE_L2'.
4934   *   if sy-subrc = 0.
4935   *       g_user = 'L'.
4936   *   endif.
4937   *Endif.
4938   *Endif.
4939
4940   *
4941    ENDFORM.                    " find_user
4942   *********************************************************************
4943    FORM check_modi.
4944   * Check for existing modifiers
4945      SELECT SINGLE * FROM zmm_modifier WHERE desc1 = g_desc1.
4946      IF sy-subrc = 0 AND ( g_tabctrl110_wa-desc1 = 'OTHER' OR
4947                            g_tabctrl110_wa-oth1 = 'X' ) .
4948        LOOP AT SCREEN.
4949          screen-input = 0.
4950          MODIFY SCREEN.
4951        ENDLOOP.
4952        g_modi_exists = 'X'.
4953        MESSAGE e010(zmm_oth) WITH 'Desc1' g_desc1 .
4954      ELSE.
4955        SELECT SINGLE * FROM zmm_modifier WHERE desc1 = g_desc1 AND desc2 =
4956         g_desc2.
4957        IF sy-subrc = 0 AND ( g_tabctrl110_wa-desc2 = 'OTHER'  OR
4958                             g_tabctrl110_wa-oth2 = 'X' ) .
4959
4960          LOOP AT SCREEN.
4961            screen-input = 0.
4962            MODIFY SCREEN.
4963          ENDLOOP.
4964
4965          MESSAGE e010(zmm_oth) WITH  'Desc2' g_desc2.
4966        ELSE.
4967          SELECT SINGLE * FROM zmm_modifier WHERE desc1 = g_desc1 AND desc2 =
4968                   g_desc2 AND desc3 = g_desc3.
4969          IF sy-subrc = 0 AND ( g_tabctrl110_wa-desc3 = 'OTHER' OR
4970                                g_tabctrl110_wa-oth3 = 'X' ) .
4971
4972            LOOP AT SCREEN.
4973              screen-input = 0.
4974              MODIFY SCREEN.
4975            ENDLOOP.
4976            MESSAGE e010(zmm_oth) WITH  'Desc3' g_desc3.
4977          ELSE.
4978            SELECT SINGLE * FROM zmm_modifier WHERE desc1 = g_desc1 AND
4979            desc2 = g_desc2 AND desc3 = g_desc3 AND desc4 = g_desc4.
4980            IF sy-subrc = 0 AND ( g_tabctrl110_wa-desc4 = 'OTHER'  OR
4981                                  g_tabctrl110_wa-oth4 = 'X' ) .
4982
4983              LOOP AT SCREEN.
4984                screen-input = 0.
4985                MODIFY SCREEN.
4986              ENDLOOP.
4987              MESSAGE e010(zmm_oth) WITH 'Desc4' g_desc4 .
4988            ENDIF.
4989          ENDIF.
4990        ENDIF.
4991      ENDIF.
4992    ENDFORM.
4993   *&---------------------------------------------------------------------*
4994   *&      Form  Spell_check
4995   *&---------------------------------------------------------------------*
4996   *       text
4997   *----------------------------------------------------------------------*
4998   *  -->  p1        text
4999   *  <--  p2        text
5000   *----------------------------------------------------------------------*
5001    FORM Spell_check.
5002      DATA : l_ans.
5003   *clear ist_spell_line.
5004   *if G_USER = '' Or G_USER = 'X'.
5005   *   concatenate g_desc1 g_desc2 g_desc3 g_desc4 g_user_desc
5006   *   into ist_spell_line-tdline separated by space.
5007   *Else.
5008   *   concatenate g_tabctrl110_wa-desc1 g_tabctrl110_wa-desc2
5009   *    g_tabctrl110_wa-desc3 g_tabctrl110_wa-desc4
5010   *    g_tabctrl110_wa-user_desc into ist_spell_line-tdline separated by
5011   *    space.
5012   *Endif.
5013   *   append ist_spell_line.
5014      IF NOT ist_spell_line[] IS INITIAL.
5015        EXPORT g_user TO MEMORY ID 'G_USER1' .
5016        EXPORT ist_spell_line TO MEMORY ID 'IST_SPELL_LINE'.
5017
5018        CALL FUNCTION 'ZSPELL_CHECK'
5019          EXPORTING
5020            sprache = 'EN'
5021          TABLES
5022            iline   = ist_spell_line.
5023        IMPORT checktab FROM MEMORY ID 'G_CHECKTAB'.
5024        IF NOT checktab[] IS INITIAL.
5025
5026          MESSAGE i017(Zmm_oth).
5027          PERFORM spell_error_lines.
5028        ELSE.
5029          MESSAGE i008(Zmm_oth).
5030          LOOP AT g_tabctrl110_itab INTO g_tabctrl110_wa.
5031            IF g_tabctrl110_wa-comp_flg+0(1) = 'S'.
5032              REPLACE 'S' WITH '' INTO g_tabctrl110_wa-comp_flg.
5033              g_tabctrl110_wa-rsn      = ''.
5034              MODIFY g_tabctrl110_itab FROM g_tabctrl110_wa INDEX sy-tabix
5035                TRANSPORTING comp_flg rsn.
5036            ENDIF.
5037          ENDLOOP.
5038
5039
5040        ENDIF.
5041
5042        IF g_user = ''.
5043          IMPORT checktab FROM MEMORY ID 'G_CHECKTAB'.
5044          IF NOT checktab[] IS INITIAL.
5045            " Begin of <RD1K960036>.
5046   *         CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
5047   *            EXPORTING
5048   **        DEFAULTOPTION        = 'Y'
5049   *    TEXTLINE1 = 'There are spelling errors in description(s)'
5050   *           TEXTLINE2            = 'Proceed with errors? '
5051   *            TITEL                = 'Spelling Errors'
5052   **                  START_COLUMN         = 25
5053   **                  START_ROW            = 6
5054   **                  CANCEL_DISPLAY       = 'X'
5055   *           IMPORTING
5056   *              ANSWER               = l_ans.
5057
5058            DATA : l_answer(1) TYPE c.
5059
5060
5061
5062            CALL FUNCTION 'POPUP_TO_CONFIRM'
5063              EXPORTING
5064                titlebar              = 'Spelling Errors'
5065                text_question         = 'There are spelling errors in description(s) Proceed with errors?'
5066                text_button_1         = 'Yes'
5067                text_button_2         = 'No'
5068                default_button        = '1'
5069                display_cancel_button = 'X'
5070                start_column          = 25
5071                start_row             = 6
5072              IMPORTING
5073                answer                = l_answer
5074              EXCEPTIONS
5075                text_not_found        = 1
5076                OTHERS                = 2.
5077            IF sy-subrc = 0.
5078              CASE l_answer.
5079                WHEN '1'.
5080                  MOVE 'J' TO l_ans.
5081                WHEN '2'.
5082                  MOVE 'N' TO l_ans.
5083              ENDCASE.
5084            ENDIF.
5085
5086            " End of <RD1K960036>.
5087
5088
5089            IF l_ans = 'J'.
5090              PERFORM spell_error_lines.
5091              CLEAR : g_screen115_1st,user_desc_len.
5092              g_other = 'X'.
5093              g_spellerror = ''.
5094   *           FREE MEMORY ID 'G_SPELL'.
5095              g_modi_exists = ''.
5096              LEAVE TO SCREEN 0.
5097            ELSE.
5098              LOOP AT SCREEN.
5099                IF screen-name = 'G_DESC1' OR
5100                   screen-name = 'G_DESC2' OR
5101                   screen-name = 'G_DESC3' OR
5102                   screen-name = 'G_DESC4'.
5103                  screen-input = 1.
5104                  MODIFY SCREEN.
5105                ENDIF.
5106              ENDLOOP.
5107            ENDIF.
5108          ELSE.
5109            CLEAR : g_screen115_1st,user_desc_len.
5110            g_other = 'X'.
5111            g_spellerror = ''.
5112            g_modi_exists = ''.
5113   *      FREE MEMORY ID 'G_SPELL'.
5114            LEAVE TO SCREEN 0.
5115          ENDIF.
5116        ENDIF.
5117      ELSE.
5118        MESSAGE i008(Zmm_oth).
5119        LOOP AT g_tabctrl110_itab INTO g_tabctrl110_wa.
5120          IF g_tabctrl110_wa-comp_flg+0(1) = 'S'.
5121            REPLACE 'S' WITH '' INTO g_tabctrl110_wa-comp_flg.
5122            g_tabctrl110_wa-rsn      = ''.
5123            MODIFY g_tabctrl110_itab FROM g_tabctrl110_wa INDEX sy-tabix
5124              TRANSPORTING comp_flg rsn.
5125          ENDIF.
5126        ENDLOOP.
5127
5128      ENDIF.
5129    ENDFORM.                    " Spell_check
5130   *&---------------------------------------------------------------------*
5131   *&      Module  spell_check1  INPUT
5132   *&---------------------------------------------------------------------*
5133   *       text
5134   *----------------------------------------------------------------------*
5135   *MODULE spell_check1 INPUT.
5136    FORM spell_check1.
5137   *+
5138
5139      DATA : ok_code110 LIKE sy-ucomm.
5140   **
5141      ok_code110 = Sy-ucomm.
5142      CLEAR sy-ucomm.
5143      CLEAR ist_spell_line.
5144      REFRESH ist_spell_line.
5145   **
5146      IF ok_code110 = 'SPELL' OR
5147         Check_code = 'CHECK'.
5148        READ TABLE g_tabctrl110_itab INTO g_tabctrl110_wa WITH KEY
5149        flag = 'X' .
5150        IF sy-subrc = 0.
5151          g_curr_line1 = sy-tabix.
5152          IF  g_TABCTRL110_wa-oth1  = 'X'.
5153
5154            CONCATENATE g_tabctrl110_wa-desc1 g_tabctrl110_wa-desc2
5155            g_tabctrl110_wa-desc3 g_tabctrl110_wa-desc4
5156            g_tabctrl110_wa-user_desc INTO ist_spell_line-tdline SEPARATED
5157            BY space.
5158
5159          ELSEIF g_TABCTRL110_wa-oth2 = 'X'.
5160            CONCATENATE g_tabctrl110_wa-desc2
5161            g_tabctrl110_wa-desc3 g_tabctrl110_wa-desc4
5162            g_tabctrl110_wa-user_desc INTO ist_spell_line-tdline SEPARATED
5163            BY space.
5164
5165          ELSEIF g_TABCTRL110_wa-oth3 = 'X'.
5166            CONCATENATE g_tabctrl110_wa-desc3 g_tabctrl110_wa-desc4
5167            g_tabctrl110_wa-user_desc INTO ist_spell_line-tdline SEPARATED
5168            BY space.
5169
5170
5171          ELSEIF g_TABCTRL110_wa-oth4 = 'X'.
5172            CONCATENATE g_tabctrl110_wa-desc4
5173            g_tabctrl110_wa-user_desc INTO ist_spell_line-tdline SEPARATED
5174            BY space.
5175
5176          ELSE.
5177            ist_spell_line-tdline = g_tabctrl110_wa-user_desc.
5178          ENDIF.
5179
5180          APPEND ist_spell_line.
5181          PERFORM Spell_check.
5182          CLEAR:sy-ucomm,ok_code110.
5183        ELSE.
5184          LOOP AT g_tabctrl110_itab INTO g_tabctrl110_wa.
5185            CASE 'X'.
5186              WHEN g_TABCTRL110_wa-oth1.
5187                CONCATENATE g_tabctrl110_wa-desc1 g_tabctrl110_wa-desc2
5188                g_tabctrl110_wa-desc3 g_tabctrl110_wa-desc4
5189            g_tabctrl110_wa-user_desc INTO ist_spell_line-tdline SEPARATED
5190                BY space.
5191                ist_spell_line-srno = g_tabctrl110_wa-srno.
5192                APPEND ist_spell_line.
5193                CONTINUE.
5194              WHEN g_TABCTRL110_wa-oth2.
5195                CONCATENATE g_tabctrl110_wa-desc2
5196                g_tabctrl110_wa-desc3 g_tabctrl110_wa-desc4
5197            g_tabctrl110_wa-user_desc INTO ist_spell_line-tdline SEPARATED
5198                BY space.
5199                ist_spell_line-srno = g_tabctrl110_wa-srno.
5200                APPEND ist_spell_line.
5201                CONTINUE.
5202
5203              WHEN g_TABCTRL110_wa-oth3.
5204                CONCATENATE g_tabctrl110_wa-desc3 g_tabctrl110_wa-desc4
5205            g_tabctrl110_wa-user_desc INTO ist_spell_line-tdline SEPARATED
5206                BY space.
5207                ist_spell_line-srno = g_tabctrl110_wa-srno.
5208                APPEND ist_spell_line.
5209                CONTINUE.
5210
5211              WHEN g_TABCTRL110_wa-oth4.
5212                CONCATENATE g_tabctrl110_wa-desc4
5213            g_tabctrl110_wa-user_desc INTO ist_spell_line-tdline SEPARATED
5214                BY space.
5215                ist_spell_line-srno = g_tabctrl110_wa-srno.
5216                APPEND ist_spell_line.
5217                CONTINUE.
5218
5219              WHEN OTHERS.
5220                IF NOT g_tabctrl110_wa-user_desc IS INITIAL.
5221                  ist_spell_line-tdline = g_tabctrl110_wa-user_desc .
5222                  ist_spell_line-srno   = g_tabctrl110_wa-srno.
5223                  APPEND ist_spell_line.
5224                ENDIF.
5225                CONTINUE.
5226            ENDCASE.
5227          ENDLOOP.
5228          CLEAR:sy-ucomm,ok_code110.
5229
5230   *     Export ist_spell_line to memory id 'SPELL'.
5231          ist_spell_line1[] = ist_spell_line[].
5232          PERFORM Spell_check.
5233
5234        ENDIF.
5235      ELSE.
5236
5237      ENDIF.
5238
5239    ENDFORM.
5240   *ENDMODULE.                 " spell_check1  INPUT
5241   *&---------------------------------------------------------------------*
5242   *&      Module  change_Other  INPUT
5243   *&---------------------------------------------------------------------*
5244   *       text
5245   *----------------------------------------------------------------------*
5246    MODULE change_Other INPUT.
5247      IF sy-ucomm = 'DBCLICK' AND g_mode = 'CHA'.
5248   *   Read table tabctrl110_itab index g_currline.
5249      ENDIF.
5250    ENDMODULE.                 " change_Other  INPUT
5251   *&---------------------------------------------------------------------*
5252   *&      Module  get_user  OUTPUT
5253   *&---------------------------------------------------------------------*
5254   *       text
5255   *----------------------------------------------------------------------*
5256    MODULE get_user OUTPUT.
5257      IF g_user_found = ''.
5258        PERFORM find_user.
5259      ENDIF.
5260   ***
5261      IF g_mode = 'APR'.
5262        IF g_user = 'M' OR
5263           g_user = 'L'.
5264   **      do nothing.
5265        ELSE.
5266          MESSAGE e057(zmm_oth).
5267        ENDIF.
5268      ENDIF.
5269   ***
5270      IF sy-tcode = 'ZCODG'.
5271        GET PARAMETER ID 'ZREQNO' FIELD zmm_cdhd_st-reqno.
5272      ENDIF.
5273
5274    ENDMODULE.                 " get_user  OUTPUT
5275   *&---------------------------------------------------------------------*
5276   *&      Form  change_Rel
5277   *&---------------------------------------------------------------------*
5278   *       text
5279   *----------------------------------------------------------------------*
5280   *  -->  p1        text
5281   *  <--  p2        text
5282   *----------------------------------------------------------------------*
5283    FORM change_Rel.
5284      DATA : l_ans.
5285      CHECK g_mode <> 'CHE'.
5286      IF zmm_cdhd_st-status_flag = 'X' AND g_mode = 'CHA'. " and g_user =
5287        " Begin of <RD1K960036>.
5288   *     CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
5289   *       EXPORTING
5290   *        DEFAULTOPTION        = 'N'
5291   *         TEXTLINE1            = 'Release will be reset. Proceed ?'
5292   **         TEXTLINE2            = ' '
5293   *         TITEL                = 'Release Reset'
5294   **         START_COLUMN         = 25
5295   **         START_ROW            = 6
5296   **         CANCEL_DISPLAY       = 'X'
5297   *    IMPORTING
5298   *        ANSWER               = l_ans.
5299
5300        DATA : l_answer(1) TYPE c.
5301        CALL FUNCTION 'POPUP_TO_CONFIRM'
5302          EXPORTING
5303            titlebar              = 'Release Reset '
5304            text_question         = 'Release will be reset. Proceed ?'
5305            default_button        = '2'
5306            display_cancel_button = 'X'
5307            start_column          = 25
5308            start_row             = 6
5309          IMPORTING
5310            answer                = l_answer
5311          EXCEPTIONS
5312            text_not_found        = 1
5313            OTHERS                = 2.
5314        IF sy-subrc = 0.
5315          CASE l_answer.
5316            WHEN '1'.
5317              MOVE 'J' TO l_ans.
5318            WHEN '2'.
5319              MOVE 'N' TO l_ans.
5320          ENDCASE.
5321        ENDIF.
5322        " End of <RD1K960036>.
5323
5324
5325        IF l_ans = 'J'.
5326          zmm_cdhd_st-status_flag = ''.
5327          zmm_cdhd_st-approve_mrp = ''.
5328          zmm_cdhd_st-approve_l2 = ''.
5329        ELSE.
5330          PERFORM clear_var.
5331          LEAVE TO SCREEN 100.
5332        ENDIF.
5333      ENDIF.
5334    ENDFORM.                    " change_Rel
5335   *&---------------------------------------------------------------------*
5336   *&      Form  Change_Restrict
5337   *&---------------------------------------------------------------------*
5338   *       text
5339   *----------------------------------------------------------------------*
5340   *      -->P_L_CDHD  text
5341   *----------------------------------------------------------------------*
5342    FORM Change_Restrict1.
5343      DATA : l_ans.
5344      IF sy-uname <> zmm_cdhd_st-reqcpf AND g_user = ''.
5345        CASE g_mode.
5346          WHEN 'CHA' OR 'REL'.
5347            MESSAGE i020(zmm_oth).
5348            PERFORM Clear_var.
5349            LEAVE TO SCREEN 100.
5350        ENDCASE.
5351      ENDIF.
5352   *Else.
5353      IF zmm_cdhd_st-status_flag = 'X' AND g_mode = 'CHA'..
5354        " Begin of <RD1K960036>.
5355   *     CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
5356   *       EXPORTING
5357   *        DEFAULTOPTION        = 'N'
5358   *         TEXTLINE1            = 'Release will be reset. Proceed ?'
5359   **         TEXTLINE2            = ' '
5360   *         TITEL                = 'Release Reset'
5361   **         START_COLUMN         = 25
5362   **         START_ROW            = 6
5363   **         CANCEL_DISPLAY       = 'X'
5364   *    IMPORTING
5365   *        ANSWER               = l_ans.
5366        DATA : l_answer(1) TYPE c.
5367
5368
5369        CALL FUNCTION 'POPUP_TO_CONFIRM'
5370          EXPORTING
5371            titlebar              = 'Release Reset '
5372            text_question         = 'Release will be reset. Proceed ?'
5373            default_button        = '2'
5374            display_cancel_button = 'X'
5375            start_column          = 25
5376            start_row             = 6
5377          IMPORTING
5378            answer                = l_answer
5379          EXCEPTIONS
5380            text_not_found        = 1
5381            OTHERS                = 2.
5382
5383        IF sy-subrc = 0.
5384          CASE l_answer.
5385            WHEN '1'.
5386              MOVE 'J' TO l_ans.
5387            WHEN '2'.
5388              MOVE 'N' TO l_ans.
5389          ENDCASE.
5390        ENDIF.
5391
5392        " End of <RD1K960036>.
5393
5394        IF l_ans = 'J'.
5395          zmm_cdhd_st-status_flag = ''.
5396          zmm_cdhd_st-approve_mrp = ''.
5397          zmm_cdhd_st-approve_l2 = ''.
5398        ELSE.
5399          PERFORM clear_var.
5400          LEAVE TO SCREEN 100.
5401        ENDIF.
5402      ENDIF.
5403    ENDFORM.                    " Change_Restrict
5404   *&---------------------------------------------------------------------*
5405   *&      Form  update_approval
5406   *&---------------------------------------------------------------------*
5407   *       text
5408   *----------------------------------------------------------------------*
5409   *  -->  p1        text
5410   *  <--  p2        text
5411   *----------------------------------------------------------------------*
5412    FORM update_approval.
5413      CASE g_user.
5414        WHEN 'M'.
5415          IF zmm_cdhd_st-approve_mrp <> ''.
5416            UPDATE zmm_cdhd SET Approve_mrp = 'X'
5417                                appdate     = sy-datum
5418                                appcpf      = sy-uname
5419                                WHERE reqno = zmm_cdhd_st-reqno.
5420   *Addition********************************
5421   **To check, if the mail has to be send after Tech Auth Approval.
5422            READ TABLE ist_zmm_cditem WITH KEY oth1 = 'X'.
5423            IF sy-subrc <> 0.
5424              PERFORM send_mail_to_cdcell.
5425              IF zmm_cdhd_st-reqcl <> 'N'.
5426                MOVE 'IC' TO zmm_cdhd_st-reqcl.
5427                UPDATE zmm_cdhd SET reqcl = zmm_cdhd_st-reqcl
5428                             WHERE reqno = zmm_cdhd_st-reqno.
5429              ENDIF.
5430            ENDIF.
5431   *End*************************************
5432            PERFORM prepare_update.
5433            MESSAGE i022(zmm_oth).
5434          ELSE.
5435            MESSAGE i024(zmm_oth) WITH 'MRP APPROVAL'.
5436          ENDIF.
5437        WHEN 'L'.
5438          IF zmm_cdhd_st-approve_L2 <> ''.
5439            UPDATE zmm_cdhd SET Approve_L2 = 'X'
5440                                appdate    = sy-datum
5441                                appcpf     = sy-uname
5442            WHERE reqno = zmm_cdhd_st-reqno.
5443   *Addition********************************
5444            PERFORM send_mail_to_cdcell.
5445            IF zmm_cdhd_st-reqcl <> 'N'.
5446              MOVE 'IC' TO zmm_cdhd_st-reqcl.
5447              UPDATE zmm_cdhd SET reqcl = zmm_cdhd_st-reqcl
5448                             WHERE reqno = zmm_cdhd_st-reqno.
5449            ENDIF.
5450
5451   *End*************************************
5452
5453            PERFORM prepare_update.
5454            MESSAGE i023(zmm_oth).
5455          ELSE.
5456            MESSAGE i024(zmm_oth) WITH 'L2 APPROVAL'.
5457          ENDIF.
5458      ENDCASE.
5459      PERFORM clear_var.
5460
5461    ENDFORM.                    " update_approval
5462
5463   *&---------------------------------------------------------------------*
5464   *&      Form  move_descriptions
5465   *&---------------------------------------------------------------------*
5466   *       text
5467   *----------------------------------------------------------------------*
5468   *  -->  p1        text
5469   *  <--  p2        text
5470   *----------------------------------------------------------------------*
5471    FORM move_descriptions.
5472
5473      descp1 = g_TABCTRL110_wa-desc1.
5474      descp2 = g_TABCTRL110_wa-desc2.
5475      descp3 = g_TABCTRL110_wa-desc3.
5476      descp4 = g_TABCTRL110_wa-desc4.
5477
5478    ENDFORM.                    " move_descriptions
5479   *&---------------------------------------------------------------------*
5480   *&      Form  REL_APR_STATUS
5481   *&---------------------------------------------------------------------*
5482   *       text
5483   *----------------------------------------------------------------------*
5484   *  -->  p1        text
5485   *  <--  p2        text
5486   *----------------------------------------------------------------------*
5487    FORM rel_apr_status.
5488      IF zmm_cdhd_st-status_flag IS INITIAL. "Req not released
5489        MESSAGE i026(zmm_oth) WITH '1'.
5490        PERFORM clear_var.
5491        LEAVE TO SCREEN 100.
5492      ENDIF.
5493
5494      IF g_user = 'L' AND zmm_cdhd_st-approve_mrp = ''.
5495        MESSAGE i027(zmm_oth) WITH 'MRP CONTROLLER'.
5496        PERFORM clear_var.
5497        LEAVE TO SCREEN 100.
5498      ENDIF.
5499
5500    ENDFORM.                    " REL_APR_STATUS
5501   **********************************************************
5502    FORM popup_userdesc.
5503      DATA l_ans.
5504      IF g_tabctrl110_wa-desc1 = 'OTHER'.
5505        " Begin of <RD1K960036>.
5506   *
5507   *     CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
5508   *       EXPORTING
5509   *         DEFAULTOPTION        = 'N'
5510   *        TEXTLINE1     = 'OTHER in Main Attribute will require approval'
5511   *         TEXTLINE2     = 'of request by Tech.Appr.Authority, Continue?'
5512   *        TITEL                = 'Technical Authority Approval Required.'
5513   **   START_COLUMN         = 25
5514   **   START_ROW            = 6
5515   *        CANCEL_DISPLAY       = ''
5516   *      IMPORTING
5517   *        ANSWER               = l_ans.
5518
5519
5520        DATA: l_answer(1) TYPE c.
5521
5522
5523        CALL FUNCTION 'POPUP_TO_CONFIRM'
5524          EXPORTING
5525            titlebar              = 'Technical Authority Approval Required.'
5526            text_question         = 'OTHER in Main Attribute will require approval of '
5527                                    & 'request by Tech.Appr.Authority, Continue?'
5528            default_button        = '2'
5529            display_cancel_button = 'X'
5530            start_column          = 25
5531            start_row             = 6
5532          IMPORTING
5533            answer                = l_answer
5534          EXCEPTIONS
5535            text_not_found        = 1
5536            OTHERS                = 2.
5537
5538        IF sy-subrc = 0.
5539          CASE l_answer.
5540            WHEN '1'.
5541              MOVE 'J' TO l_ans.
5542            WHEN '2'.
5543              MOVE 'N' TO l_ans.
5544          ENDCASE.
5545        ENDIF.
5546
5547        " End of <RD1K960036>.
5548
5549        IF l_ans = 'J'.
5550          CALL SCREEN 115 STARTING AT 18 17 ENDING AT 120 23.
5551        ELSE.
5552          g_tabctrl110_wa-desc1 = ''.
5553          g_tabctrl110_wa-oth1 = ''.
5554
5555        ENDIF.
5556      ELSE.
5557        CALL SCREEN 115 STARTING AT 18 17 ENDING AT 120 23.
5558      ENDIF.
5559    ENDFORM.                    " popup_userdesc
5560
5561   **********************************************************
5562    FORM check_other.
5563   *+120505
5564      LOOP AT g_TABCTRL110_itab INTO g_TABCTRL110_wa.
5565        IF g_TABCTRL110_wa-Desc1 = 'OTHER' OR
5566           g_TABCTRL110_wa-Desc2 = 'OTHER' OR
5567           g_TABCTRL110_wa-Desc3 = 'OTHER' OR
5568           g_TABCTRL110_wa-Desc4 = 'OTHER'.
5569          MESSAGE i029(zmm_oth).
5570          LEAVE TO SCREEN 100.
5571        ENDIF.
5572      ENDLOOP.
5573   *+120505
5574
5575    ENDFORM.                    " check_other
5576   **********************************************************
5577   *&---------------------------------------------------------------------*
5578   *&      Form  SPELL_ERROR_LINES
5579   *&---------------------------------------------------------------------*
5580   *       text
5581   *----------------------------------------------------------------------*
5582   *  -->  p1        text
5583   *  <--  p2        text
5584   *----------------------------------------------------------------------*
5585    FORM spell_error_lines.
5586      DATA :z      TYPE i, ct_idx TYPE i.
5587      DATA : l_status(2).
5588   *DATA  ist_spell_line1 like table of wa_spell_line with header line.
5589      TYPES: BEGIN OF itab_type,
5590               word(60),
5591               srno(3),
5592             END   OF itab_type.
5593
5594      DATA: BEGIN OF checktab1 OCCURS 0,
5595              begriff(60),
5596              srno(3)     TYPE n,
5597            END OF checktab1.
5598
5599      DATA: itab TYPE STANDARD TABLE OF itab_type WITH HEADER LINE.
5600      DATA  itab1 LIKE TABLE OF itab WITH HEADER LINE.
5601
5602      IF checktab[] IS INITIAL.
5603        LOOP AT g_tabctrl110_itab INTO g_tabctrl110_wa.
5604          IF g_tabctrl110_wa-comp_flg = 'S'.
5605            REPLACE 'S' WITH '' INTO g_tabctrl110_wa-comp_flg.
5606            g_tabctrl110_wa-rsn      = ''.
5607            MODIFY g_tabctrl110_itab FROM g_tabctrl110_wa INDEX z
5608               TRANSPORTING comp_flg rsn.
5609          ENDIF.
5610        ENDLOOP.
5611      ENDIF.
5612      CHECK NOT checktab[] IS INITIAL.
5613
5614
5615      checktab1[] = checktab[].
5616      LOOP AT g_tabctrl110_itab INTO g_tabctrl110_wa.
5617        z = sy-tabix.
5618        SPLIT  g_tabctrl110_wa-desc_fin AT ' ' INTO TABLE itab.
5619        LOOP AT itab.
5620          MOVE z TO itab-srno.
5621          MODIFY itab INDEX sy-tabix.
5622        ENDLOOP.
5623        APPEND LINES OF itab TO itab1.
5624        CLEAR z.
5625      ENDLOOP.
5626
5627   *LOGIC-2
5628      CLEAR z.
5629      LOOP AT g_tabctrl110_itab INTO g_tabctrl110_wa.
5630        IF g_tabctrl110_wa-comp_flg+0(1) = 'S'.
5631          CONCATENATE '' g_tabctrl110_wa-comp_flg+1(1) INTO
5632                 g_tabctrl110_wa-comp_flg.
5633          g_tabctrl110_wa-rsn      = ''.
5634
5635          MODIFY g_tabctrl110_itab FROM g_tabctrl110_wa INDEX sy-tabix
5636                  TRANSPORTING comp_flg rsn.
5637        ELSE.
5638          CONTINUE.
5639        ENDIF.
5640      ENDLOOP.
5641
5642      LOOP AT checktab1.
5643        ct_idx = sy-tabix.
5644        READ TABLE itab1 WITH KEY word = checktab1-begriff.
5645        IF sy-subrc = 0.
5646          checktab1-srno = itab1-srno.
5647          MODIFY checktab1 INDEX ct_idx TRANSPORTING srno.
5648          IF g_tabctrl110_wa-comp_flg+1(1) = ''.
5649            g_tabctrl110_wa-comp_flg = 'S'.
5650            g_tabctrl110_wa-rsn      = 'Spelling Mistake'.
5651          ELSE.
5652            CONCATENATE 'S' g_tabctrl110_wa-comp_flg+1(1) INTO l_status.
5653            g_tabctrl110_wa-comp_flg = l_status.
5654          ENDIF.
5655          z = itab1-srno.
5656          MODIFY g_tabctrl110_itab FROM g_tabctrl110_wa INDEX z
5657               TRANSPORTING comp_flg rsn.
5658        ENDIF.
5659      ENDLOOP.
5660   *loop at checktab1.
5661   *write : / checktab1-begriff color 5, checktab1-srno.
5662   *Endloop.
5663
5664
5665
5666
5667   ******LOGIC-1
5668   *append lines of checktab to itab1.
5669   *
5670   *sort itab1 by word srno.
5671   *clear z.
5672   *read table itab1 index 1.
5673   *
5674   *loop at itab1.
5675   *   If itab1-srno = ''.
5676   *       word = itab1-word.
5677   *   Endif.
5678   *   if word = itab1-word and itab1-srno <> ''.
5679   *      z = itab1-srno.
5680   *      ist_spell_line1-spell_err = 'S'.
5681   *      modify ist_spell_line1 index z transporting spell_err.
5682   *      clear word.
5683   *   Endif.
5684   **word = itab1-word.
5685   *Endloop.
5686   *sort ist_spell_line1 by srno.
5687   *sort checktab1 by srno.
5688   *
5689   *loop at ist_spell_line1 where spell_err = 'S'.
5690   *  Loop at checktab1.
5691   *       if ist_spell_line1-srno = checktab1-srno.
5692   *          write : / ist_spell_line1-spell_err ,
5693   *ist_spell_line1-tdline+0(88) ,
5694   *                    checktab1-begriff+0(20) color 7,
5695   *ist_spell_line1-srno.
5696   *       Endif.
5697   *  Endloop.
5698   *Endloop.
5699
5700
5701   *loop at checktab.
5702   *
5703   *        search g_tabctrl110_itab for checktab-begriff .
5704   *        if sy-subrc = 0.
5705   *           g_tabctrl110_wa-comp_flg = 'S'.
5706   *           modify g_tabctrl110_itab from g_tabctrl110_wa
5707   *             index sy-tabix transporting comp_flg.
5708   *        Else.
5709   *            g_tabctrl110_wa-comp_flg = ''.
5710   *           modify g_tabctrl110_itab from g_tabctrl110_wa
5711   *             index sy-tabix transporting comp_flg.
5712   *
5713   *        Endif.
5714   *Endloop.
5715      CLEAR sy-ucomm.
5716    ENDFORM.                    " SPELL_ERROR_LINES
5717   *&---------------------------------------------------------------------*
5718   *&      Form  modi_check
5719   *&---------------------------------------------------------------------*
5720   *       text
5721   *----------------------------------------------------------------------*
5722   *  -->  p1        text
5723   *  <--  p2        text
5724   *----------------------------------------------------------------------*
5725    FORM modi_check.
5726      DATA : l_status(2).
5727      LOOP AT g_tabctrl110_itab INTO g_tabctrl110_wa.
5728        IF g_tabctrl110_wa-oth1 = 'X' OR
5729           g_tabctrl110_wa-oth2 = 'X' OR
5730           g_tabctrl110_wa-oth3 = 'X' OR
5731           g_tabctrl110_wa-oth4 = 'X' .
5732
5733          SELECT SINGLE * FROM zmm_modifier WHERE
5734             desc1 = g_tabctrl110_wa-desc1 AND
5735             desc2 = g_tabctrl110_wa-desc2 AND
5736             desc3 = g_tabctrl110_wa-desc3 AND
5737             desc4 = g_tabctrl110_wa-desc4.
5738          IF sy-subrc <> 0.
5739            IF g_tabctrl110_wa-comp_flg+1(1) = 'M'.
5740              CONTINUE.
5741            ELSE.
5742              IF g_tabctrl110_wa-comp_flg+0(1) <> 'M'.
5743                CONCATENATE g_tabctrl110_wa-comp_flg 'M' INTO
5744                g_tabctrl110_wa-comp_flg.
5745                MODIFY g_tabctrl110_itab FROM g_tabctrl110_wa INDEX sy-tabix
5746                     TRANSPORTING comp_flg.
5747              ENDIF.
5748            ENDIF.
5749          ELSE.
5750   *
5751   *        replace  'M' with '' into g_tabctrl110_wa-comp_flg.
5752          ENDIF.
5753        ENDIF.
5754      ENDLOOP.
5755    ENDFORM.                    " modi_check
5756   *&---------------------------------------------------------------------*
5757   *&      Form  SELECT_MATERIAL_DETAILS1
5758   *&---------------------------------------------------------------------*
5759   *       text
5760   *----------------------------------------------------------------------*
5761   *  -->  p1        text
5762   *  <--  p2        text
5763   *----------------------------------------------------------------------*
5764    FORM select_material_details1.
5765
5766      CLEAR do_not_change_flag.
5767
5768      IF g_mode = 'CRE' OR g_mode = 'CHA'.
5769
5770        IF check_pos = 0.
5771          DESCRIBE TABLE ist_srchlp LINES g_mat_fnd.
5772        ENDIF.
5773   *
5774   *    if g_lineno_old <> g_lineno.
5775   **     clear g_mat_fnd.
5776   *      do_not_change_flag = 'X'.
5777   *    endif.
5778
5779        CLEAR g_hits_par.
5780
5781      ENDIF.
5782
5783      LOOP AT ist_srchlp INTO wa_srchlp.
5784
5785        DATA : l_matnr LIKE thead-tdname.
5786        l_matnr = wa_srchlp-matnr.
5787
5788        CALL FUNCTION 'READ_TEXT'
5789          EXPORTING
5790            client                  = sy-mandt
5791            id                      = 'BEST'
5792            language                = 'E'
5793            name                    = l_matnr
5794            object                  = 'MATERIAL'
5795          TABLES
5796            lines                   = lines
5797          EXCEPTIONS
5798            id                      = 1
5799            language                = 2
5800            name                    = 3
5801            not_found               = 4
5802            object                  = 5
5803            reference_check         = 6
5804            wrong_access_to_archive = 7
5805            OTHERS                  = 8.
5806
5807        IF sy-subrc <> 0.
5808   *      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
5809   *      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
5810          wa_srchlp-mark = '1'.
5811          MODIFY ist_srchlp FROM wa_srchlp.
5812        ENDIF.
5813
5814      ENDLOOP.
5815
5816
5817    ENDFORM.                    " SELECT_MATERIAL_DETAILS1
5818   *&---------------------------------------------------------------------*
5819   *&      Module  CHECK_SPELL  INPUT
5820   *&---------------------------------------------------------------------*
5821   *       text
5822   *----------------------------------------------------------------------*
5823    MODULE check_spell INPUT.
5824
5825      IF sy-ucomm <> 'SPELL'.
5826        CLEAR ist_spell_line.
5827        REFRESH ist_spell_line.
5828        ist_spell_line-tdline = zmm_cditem-desc_fin.
5829        APPEND ist_spell_line.
5830        EXPORT ist_spell_line TO MEMORY ID 'IST_SPELL_LINE'.
5831        CALL FUNCTION 'ZSPELL_CHECK'
5832          EXPORTING
5833            sprache = 'EN'
5834          TABLES
5835            iline   = ist_spell_line.
5836        IMPORT checktab FROM MEMORY ID 'G_CHECKTAB'.
5837        IF NOT checktab[] IS INITIAL.
5838          MESSAGE i016(zmm_oth).
5839          REPLACE zmm_cditem-comp_flg+0(1) WITH 'S' INTO zmm_cditem-comp_flg
5840      .
5841        ELSE.
5842          REPLACE zmm_cditem-comp_flg+0(1) WITH '' INTO zmm_cditem-comp_flg.
5843        ENDIF.
5844      ENDIF.
5845    ENDMODULE.                 " CHECK_SPELL  INPUT
5846
5847   *---------------------------------------------------------------------*
5848   *       FORM insert_mdlno                                             *
5849   *---------------------------------------------------------------------*
5850   *       ........                                                      *
5851   *---------------------------------------------------------------------*
5852    FORM insert_mdlno.
5853      DATA l_ans1.
5854   *
5855      READ TABLE g_tablctrl120_itab INTO g_tablctrl120_wa INDEX
5856       g_curr_line_120.
5857      IF sy-subrc = 0.
5858        IF g_tablctrl120_wa-oth_mdl <> 'X'.
5859          MESSAGE i048(zmm_oth).
5860        ELSE.
5861          zmm_mdl-mdlno = g_tablctrl120_wa-mdlno.
5862
5863          IF  zmm_mdl-mdlno <> ''.
5864            TRANSLATE zmm_mdl-mdlno TO UPPER CASE.
5865            " Begin of <RD1K960036>.
5866   *         CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
5867   *           EXPORTING
5868   *             DEFAULTOPTION        = 'Y'
5869   *             TEXTLINE1            = 'Insert Model No. '
5870   *             TEXTLINE2            = zmm_mdl-mdlno
5871   *             TITEL                = 'Insert model no.'
5872   **       START_COLUMN         = 25
5873   **       START_ROW            = 6
5874   **       CANCEL_DISPLAY       = 'X'
5875   *          IMPORTING
5876   *            ANSWER               = l_ans1
5877
5878            DATA : l_answer(1) TYPE c.
5879            CALL FUNCTION 'POPUP_TO_CONFIRM'
5880              EXPORTING
5881                titlebar              = 'Insert model no '
5882                text_question         = 'Insert Model No. zmm_mdl-mdlno '
5883                text_button_1         = 'Yes'
5884                text_button_2         = 'No'
5885                default_button        = '1'
5886                display_cancel_button = 'X'
5887                start_column          = 25
5888                start_row             = 6
5889              IMPORTING
5890                answer                = l_answer
5891              EXCEPTIONS
5892                text_not_found        = 1
5893                OTHERS                = 2.
5894
5895            IF sy-subrc = 0.
5896              CASE l_answer.
5897                WHEN '1'.
5898                  MOVE 'J' TO l_ans1.
5899                WHEN '2'.
5900                  MOVE 'N' TO l_ans1.
5901              ENDCASE.
5902            ENDIF.
5903            " End of <RD1K960036>.
5904            IF l_ans1 = 'J'.
5905              INSERT INTO zmm_mdl VALUES zmm_mdl.
5906              REPLACE 'L' WITH '' INTO g_TABLCTRL120_wa-comp_flg.
5907              MODIFY g_TABLCTRL120_itab FROM g_TABLCTRL120_wa INDEX
5908               g_curr_line_120 TRANSPORTING comp_flg.
5909            ELSE.
5910   *  message i045(zmm_oth). "Operation cancelled by the user
5911            ENDIF.
5912          ELSE.
5913   *    message i046(zmm_oth). "Model no blank!
5914          ENDIF.
5915        ENDIF.
5916      ENDIF.
5917    ENDFORM.                    " insert_mdlno
5918   *&---------------------------------------------------------------------*
5919   *&      Form  spell_check2
5920   *&---------------------------------------------------------------------*
5921   *       text
5922   *----------------------------------------------------------------------*
5923   *  -->  p1        text
5924   *  <--  p2        text
5925   *----------------------------------------------------------------------*
5926    FORM spell_check2.
5927   *
5928      CLEAR ist_spell_line.
5929      REFRESH ist_spell_line.
5930      CLEAR sy-ucomm.
5931
5932      LOOP AT g_tablctrl120_itab INTO g_tablctrl120_wa.
5933        ist_spell_line-tdline = g_tablctrl120_wa-desc_fin.
5934        ist_spell_line-srno =   g_tablctrl120_wa-srno.
5935        APPEND ist_spell_line.
5936      ENDLOOP.
5937      EXPORT ist_spell_line TO MEMORY ID 'IST_SPELL_LINE'.
5938
5939      CALL FUNCTION 'ZSPELL_CHECK'
5940        EXPORTING
5941          sprache = 'EN'
5942        TABLES
5943          iline   = ist_spell_line.
5944
5945      IMPORT checktab FROM MEMORY ID 'G_CHECKTAB'.
5946      IF NOT checktab[] IS INITIAL.
5947
5948        MESSAGE i017(Zmm_oth).
5949        PERFORM spell_error_lines_zspr.
5950      ELSE.
5951        MESSAGE i008(Zmm_oth).
5952        LOOP AT g_tablctrl120_itab INTO g_tablctrl120_wa.
5953   *      if g_tablctrl120_wa-comp_flg+0(1) = 'S'.
5954          REPLACE 'S' WITH '' INTO g_tablctrl120_wa-comp_flg.
5955          MODIFY g_tablctrl120_itab FROM g_tablctrl120_wa INDEX sy-tabix
5956            TRANSPORTING comp_flg .
5957   *      Endif.
5958        ENDLOOP.
5959      ENDIF.
5960   *
5961    ENDFORM.                    " spell_check2
5962   *********************************************************************
5963    AT LINE-SELECTION.
5964   *
5965
5966      IF zmm_cdhd_st-mtart = 'ZSTO'.
5967        READ CURRENT LINE .
5968        wa_modifier_check_list = ist_modifier_check_list.
5969        SET PARAMETER ID 'S_MATGP' FIELD wa_modifier_check_list-matgrp.
5970      ENDIF.
5971
5972      IF sy-dynnr = '0120'.
5973        READ CURRENT LINE .
5974        zmm_cditem-mdlno = sy-lisel.
5975        zmm_cditem-oth_mdl = ''.
5976      ENDIF.
5977      LEAVE TO SCREEN 0.
5978   *&---------------------------------------------------------------------*
5979   *&      Form  SPELL_ERROR_LINES_ZSPR
5980   *&---------------------------------------------------------------------*
5981   *       text
5982   *----------------------------------------------------------------------*
5983   *  -->  p1        text
5984   *  <--  p2        text
5985   *----------------------------------------------------------------------*
5986    FORM spell_error_lines_zspr.
5987      DATA :z      TYPE i, ct_idx TYPE i.
5988      DATA : l_status(2).
5989   *DATA  ist_spell_line1 like table of wa_spell_line with header line.
5990      TYPES: BEGIN OF itab_type,
5991               word(60),
5992               srno(3),
5993             END   OF itab_type.
5994
5995      DATA: BEGIN OF checktab1 OCCURS 0,
5996              begriff(60),
5997              srno(3)     TYPE n,
5998            END OF checktab1.
5999
6000      DATA: itab TYPE STANDARD TABLE OF itab_type WITH HEADER LINE.
6001      DATA  itab1 LIKE TABLE OF itab WITH HEADER LINE.
6002
6003   *
6004      IF checktab[] IS INITIAL.
6005        LOOP AT g_tablctrl120_itab INTO g_tablctrl120_wa.
6006          IF g_tablctrl120_wa-comp_flg+0(1) = 'S'.
6007            REPLACE 'S' WITH '' INTO g_tablctrl120_wa-comp_flg.
6008            MODIFY g_tablctrl120_itab FROM g_tablctrl120_wa INDEX z
6009               TRANSPORTING comp_flg .
6010          ENDIF.
6011        ENDLOOP.
6012      ENDIF.
6013      CHECK NOT checktab[] IS INITIAL.
6014
6015   *
6016      checktab1[] = checktab[].
6017      LOOP AT g_tablctrl120_itab INTO g_tablctrl120_wa.
6018        z = sy-tabix.
6019        SPLIT  g_tablctrl120_wa-desc_fin AT ' ' INTO TABLE itab.
6020        LOOP AT itab.
6021          MOVE z TO itab-srno.
6022          MODIFY itab INDEX sy-tabix.
6023        ENDLOOP.
6024        APPEND LINES OF itab TO itab1.
6025        CLEAR z.
6026      ENDLOOP.
6027
6028   *LOGIC-2
6029      CLEAR z.
6030      LOOP AT g_tablctrl120_itab INTO g_tablctrl120_wa.
6031        IF g_tablctrl120_wa-comp_flg+0(1) = 'S'.
6032          REPLACE 'S' WITH '' INTO g_tablctrl120_wa-comp_flg.
6033          MODIFY g_tablctrl120_itab FROM g_tablctrl120_wa INDEX sy-tabix
6034                  TRANSPORTING comp_flg .
6035        ELSE.
6036          CONTINUE.
6037        ENDIF.
6038      ENDLOOP.
6039
6040      LOOP AT checktab1.
6041        ct_idx = sy-tabix.
6042        READ TABLE itab1 WITH KEY word = checktab1-begriff.
6043        IF sy-subrc = 0.
6044          checktab1-srno = itab1-srno.
6045          MODIFY checktab1 INDEX ct_idx TRANSPORTING srno.
6046          READ TABLE g_tablctrl120_itab INTO g_tablctrl120_wa INDEX
6047          itab1-srno.
6048          IF g_tablctrl120_wa-comp_flg+1(1) = ''.
6049            g_tablctrl120_wa-comp_flg = 'S'.
6050          ELSE.
6051            CONCATENATE 'S' g_tablctrl120_wa-comp_flg+1(1) INTO l_status.
6052            g_tablctrl120_wa-comp_flg = l_status.
6053          ENDIF.
6054          z = itab1-srno.
6055          MODIFY g_tablctrl120_itab FROM g_tablctrl120_wa INDEX z
6056               TRANSPORTING comp_flg .
6057        ENDIF.
6058      ENDLOOP.
6059
6060    ENDFORM.                    " SPELL_ERROR_LINES_ZSPR
6061   *&---------------------------------------------------------------------*
6062   *&      Form  get_srchlp_zcap
6063   *&---------------------------------------------------------------------*
6064   *       text
6065   *----------------------------------------------------------------------*
6066   *  -->  p1        text
6067   *  <--  p2        text
6068   *----------------------------------------------------------------------*
6069    FORM get_srchlp_zcap.
6070      DATA : l_srno  LIKE sy-index.
6071      DATA : l_len   LIKE sy-index.
6072      DATA : l_check.
6073      DATA : BEGIN OF wa_partdesc,
6074               part(40),
6075             END OF wa_partdesc.
6076      DATA : ist_partdesc LIKE TABLE OF wa_partdesc.
6077      DATA : l_desc(100).
6078      DATA : part1(40),part2(40),part3(40),part4(40).
6079      DATA : l_matnr LIKE thead-tdname.
6080      DATA : ist_partdesc_lines TYPE i.
6081
6082
6083   *
6084      CHECK g_cursor_fld130 = 'ZMM_CDITEM-DESC_FIN'.
6085   *  If not zmm_cditem-desc_fin  is initial.
6086      READ TABLE g_TABLCTRL130_itab INTO g_TABLCTRL130_wa INDEX
6087    g_curr_line_130.
6088      IF NOT g_TABLCTRL130_wa-desc_fin  IS INITIAL.
6089        TRANSLATE g_TABLCTRL130_wa-desc_fin TO UPPER CASE.
6090        SPLIT g_TABLCTRL130_wa-desc_fin AT ' ' INTO TABLE ist_partdesc.
6091   *    split zmm_cditem-desc_fin at ' ' into table ist_partdesc.
6092        DESCRIBE TABLE ist_partdesc LINES ist_partdesc_lines.
6093        IF ist_partdesc_lines > 4.
6094          DELETE ist_partdesc FROM 5 TO ist_partdesc_lines.
6095        ENDIF.
6096        READ TABLE ist_partdesc INTO wa_partdesc INDEX 1.
6097
6098        CONCATENATE '%' wa_partdesc-part '%' INTO l_desc .
6099        CONDENSE l_Desc NO-GAPS.
6100   *
6101        SELECT a~maktg a~matnr b~meins b~mfrpn b~wrkst
6102        INTO CORRESPONDING FIELDS OF TABLE ist_srchlp
6103        FROM makt AS a
6104        JOIN mara AS b
6105        ON a~matnr = b~matnr
6106        WHERE b~mtart = 'ZCAP'  AND
6107        ( a~maktg LIKE l_desc OR b~wrkst LIKE l_desc ).
6108   *
6109
6110        LOOP AT ist_partdesc INTO wa_partdesc.
6111          IF sy-tabix = 1.
6112            part1 = wa_partdesc-part.
6113            CONDENSE part1 NO-GAPS.
6114          ELSEIF sy-tabix = 2.
6115            part2 = wa_partdesc-part.
6116            CONDENSE part1 NO-GAPS.
6117          ELSEIF sy-tabix = 3.
6118            part3 = wa_partdesc-part.
6119            CONDENSE part1 NO-GAPS.
6120          ELSEIF sy-tabix = 4.
6121            part4 = wa_partdesc-part.
6122            CONDENSE part1 NO-GAPS.
6123          ENDIF.
6124        ENDLOOP.
6125
6126        LOOP AT ist_srchlp INTO wa_srchlp.
6127          IF wa_srchlp-maktg+39(1) = '*'.
6128            CONCATENATE wa_srchlp-maktg+0(39) wa_srchlp-wrkst INTO
6129            wa_srchlp-maktx.
6130          ELSE.
6131            MOVE wa_srchlp-maktg TO wa_srchlp-maktx.
6132          ENDIF.
6133
6134          TRANSLATE wa_srchlp-maktx TO UPPER CASE.
6135          CHECK part2 <> ''.
6136          SEARCH wa_srchlp-maktx FOR part2.
6137          IF sy-subrc = 0.
6138            CHECK part3 <> ''.
6139            SEARCH wa_srchlp-maktx FOR part3.
6140            IF sy-subrc = 0.
6141              CHECK part4 <> ''.
6142              SEARCH wa_srchlp-maktx FOR part4.
6143              IF sy-subrc = 0.
6144   *             l_srno         = l_srno + 1.
6145   *             wa_srchlp-srno = l_srno.
6146   *             l_matnr = WA_SRCHLP-MATNR.
6147   *
6148   *            CALL FUNCTION 'READ_TEXT'
6149   *               EXPORTING
6150   *                ID                      = 'BEST'
6151   *                LANGUAGE                = 'E'
6152   *                NAME                    = l_matnr
6153   *                OBJECT                  = 'MATERIAL'
6154   *             TABLES
6155   *                LINES                   = lines
6156   *             EXCEPTIONS
6157   *              ID                      = 1
6158   *              LANGUAGE                = 2
6159   *              NAME                    = 3
6160   *              NOT_FOUND               = 4
6161   *              OBJECT                  = 5
6162   *              REFERENCE_CHECK         = 6
6163   *              WRONG_ACCESS_TO_ARCHIVE = 7
6164   *              OTHERS                  = 8.
6165   *
6166   *             IF SY-SUBRC <> 0.
6167   *              wa_srchlp-mark = '1'.
6168   *             ENDIF.
6169   *             modify ist_srchlp from wa_srchlp.
6170                CONTINUE.
6171              ELSE.
6172                DELETE  ist_srchlp INDEX sy-tabix.
6173              ENDIF.
6174            ELSE.
6175              DELETE  ist_srchlp INDEX sy-tabix.
6176            ENDIF.
6177          ELSE.
6178            DELETE  ist_srchlp INDEX sy-tabix.
6179          ENDIF.
6180        ENDLOOP.
6181      ENDIF.
6182      LOOP AT ist_srchlp INTO wa_srchlp.
6183        IF wa_srchlp-maktg+39(1) = '*'.
6184          CONCATENATE wa_srchlp-maktg+0(39) wa_srchlp-wrkst INTO
6185          wa_srchlp-maktx.
6186        ELSE.
6187          MOVE wa_srchlp-maktg TO wa_srchlp-maktx.
6188        ENDIF.
6189        l_srno         = l_srno + 1.
6190        wa_srchlp-srno = l_srno.
6191        l_matnr = wa_srchlp-matnr.
6192
6193        CALL FUNCTION 'READ_TEXT'
6194          EXPORTING
6195            id                      = 'BEST'
6196            language                = 'E'
6197            name                    = l_matnr
6198            object                  = 'MATERIAL'
6199          TABLES
6200            lines                   = lines
6201          EXCEPTIONS
6202            id                      = 1
6203            language                = 2
6204            name                    = 3
6205            not_found               = 4
6206            object                  = 5
6207            reference_check         = 6
6208            wrong_access_to_archive = 7
6209            OTHERS                  = 8.
6210
6211        IF sy-subrc <> 0.
6212   *      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
6213   *      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
6214          wa_srchlp-mark = '1'.
6215        ENDIF.
6216        MODIFY ist_srchlp FROM wa_srchlp.
6217      ENDLOOP.
6218
6219    ENDFORM.                    " get_srchlp_zcap
6220   *&---------------------------------------------------------------------*
6221   *&      Form  spell_check3
6222   *&---------------------------------------------------------------------*
6223   *       text
6224   *----------------------------------------------------------------------*
6225   *  -->  p1        text
6226   *  <--  p2        text
6227   *----------------------------------------------------------------------*
6228    FORM spell_check3.
6229      CLEAR ist_spell_line.
6230      REFRESH ist_spell_line.
6231      CLEAR sy-ucomm.
6232
6233      LOOP AT g_tablctrl130_itab INTO g_tablctrl130_wa.
6234        ist_spell_line-tdline = g_tablctrl130_wa-desc_fin.
6235        ist_spell_line-srno =   g_tablctrl130_wa-srno.
6236        APPEND ist_spell_line.
6237      ENDLOOP.
6238      EXPORT ist_spell_line TO MEMORY ID 'IST_SPELL_LINE'.
6239
6240      CALL FUNCTION 'ZSPELL_CHECK'
6241        EXPORTING
6242          sprache = 'EN'
6243        TABLES
6244          iline   = ist_spell_line.
6245
6246      IMPORT checktab FROM MEMORY ID 'G_CHECKTAB'.
6247      IF NOT checktab[] IS INITIAL.
6248
6249        MESSAGE i017(Zmm_oth).
6250        PERFORM spell_error_lines_zcap.
6251      ELSE.
6252        MESSAGE i008(Zmm_oth).
6253        LOOP AT g_tablctrl130_itab INTO g_tablctrl130_wa.
6254   *      if g_tablctrl130_wa-comp_flg+0(1) = 'S'.
6255          REPLACE 'S' WITH '' INTO g_tablctrl130_wa-comp_flg.
6256          MODIFY g_tablctrl130_itab FROM g_tablctrl130_wa INDEX sy-tabix
6257            TRANSPORTING comp_flg .
6258   *      Endif.
6259        ENDLOOP.
6260      ENDIF.
6261   *
6262
6263    ENDFORM.                    " spell_check3
6264   *&---------------------------------------------------------------------*
6265   *&      Form  SPELL_ERROR_LINES_ZCAP
6266   *&---------------------------------------------------------------------*
6267   *       text
6268   *----------------------------------------------------------------------*
6269   *  -->  p1        text
6270   *  <--  p2        text
6271   *----------------------------------------------------------------------*
6272    FORM spell_error_lines_zcap.
6273      DATA :z      TYPE i, ct_idx TYPE i.
6274      DATA : l_status(2).
6275   *DATA  ist_spell_line1 like table of wa_spell_line with header line.
6276      TYPES: BEGIN OF itab_type,
6277               word(60),
6278               srno(3),
6279             END   OF itab_type.
6280
6281      DATA: BEGIN OF checktab1 OCCURS 0,
6282              begriff(60),
6283              srno(3)     TYPE n,
6284            END OF checktab1.
6285
6286      DATA: itab TYPE STANDARD TABLE OF itab_type WITH HEADER LINE.
6287      DATA  itab1 LIKE TABLE OF itab WITH HEADER LINE.
6288
6289   *
6290      IF checktab[] IS INITIAL.
6291        LOOP AT g_tablctrl130_itab INTO g_tablctrl130_wa.
6292          IF g_tablctrl130_wa-comp_flg+0(1) = 'S'.
6293            REPLACE 'S' WITH '' INTO g_tablctrl130_wa-comp_flg.
6294            MODIFY g_tablctrl130_itab FROM g_tablctrl130_wa INDEX z
6295               TRANSPORTING comp_flg .
6296          ENDIF.
6297        ENDLOOP.
6298      ENDIF.
6299      CHECK NOT checktab[] IS INITIAL.
6300
6301   *
6302      checktab1[] = checktab[].
6303      LOOP AT g_tablctrl130_itab INTO g_tablctrl130_wa.
6304        z = sy-tabix.
6305        SPLIT  g_tablctrl130_wa-desc_fin AT ' ' INTO TABLE itab.
6306        LOOP AT itab.
6307          MOVE z TO itab-srno.
6308          MODIFY itab INDEX sy-tabix.
6309        ENDLOOP.
6310        APPEND LINES OF itab TO itab1.
6311        CLEAR z.
6312      ENDLOOP.
6313
6314   *LOGIC-2
6315      CLEAR z.
6316      LOOP AT g_tablctrl130_itab INTO g_tablctrl130_wa.
6317        IF g_tablctrl130_wa-comp_flg+0(1) = 'S'.
6318          REPLACE 'S' WITH '' INTO g_tablctrl130_wa-comp_flg.
6319          MODIFY g_tablctrl130_itab FROM g_tablctrl130_wa INDEX sy-tabix
6320                  TRANSPORTING comp_flg .
6321        ELSE.
6322          CONTINUE.
6323        ENDIF.
6324      ENDLOOP.
6325
6326      LOOP AT checktab1.
6327        ct_idx = sy-tabix.
6328        READ TABLE itab1 WITH KEY word = checktab1-begriff.
6329        IF sy-subrc = 0.
6330          checktab1-srno = itab1-srno.
6331          MODIFY checktab1 INDEX ct_idx TRANSPORTING srno.
6332          READ TABLE g_tablctrl130_itab INTO g_tablctrl130_wa INDEX
6333          itab1-srno.
6334          IF g_tablctrl130_wa-comp_flg+1(1) = ''.
6335            g_tablctrl130_wa-comp_flg = 'S'.
6336          ELSE.
6337            CONCATENATE 'S' g_tablctrl130_wa-comp_flg+1(1) INTO l_status.
6338            g_tablctrl130_wa-comp_flg = l_status.
6339          ENDIF.
6340          z = itab1-srno.
6341          MODIFY g_tablctrl130_itab FROM g_tablctrl130_wa INDEX z
6342               TRANSPORTING comp_flg .
6343        ENDIF.
6344      ENDLOOP.
6345
6346    ENDFORM.                    " SPELL_ERROR_LINES_ZCAP
6347   *&---------------------------------------------------------------------*
6348   *&      Form  cp_matcode
6349   *&---------------------------------------------------------------------*
6350   *       text
6351   *----------------------------------------------------------------------*
6352   *  -->  p1        text
6353   *  <--  p2        text
6354   *----------------------------------------------------------------------*
6355    FORM cp_matcode.
6356   *   g_tabctrl110_wa = wa_srchlp-matnr.
6357
6358    ENDFORM.                    " cp_matcode
6359   *&---------------------------------------------------------------------*
6360   *&      Form  get_srno
6361   *&---------------------------------------------------------------------*
6362   *       text
6363   *----------------------------------------------------------------------*
6364   *  -->  p1        text
6365   *  <--  p2        text
6366   *----------------------------------------------------------------------*
6367    FORM get_srno.
6368   *  get cursor line l_curs_ln.
6369   ***To get the proper serial no of line item against the
6370   ***Cursor position
6371      CASE zmm_cdhd_st-mtart.
6372        WHEN 'ZSTO'.
6373   *   move tabctrl110-current_line to l_curs_ln.
6374          g_curs_ln = g_curr_line_110.
6375          READ TABLE g_tabctrl110_itab INTO g_tabctrl110_wa
6376                                      INDEX g_curs_ln.
6377          g_srno = g_tabctrl110_wa-srno.
6378        WHEN 'ZSPR'.
6379   *   move tablctrl120-current_line to l_curs_ln.
6380          g_curs_ln = g_curr_line_120.
6381          READ TABLE g_tablctrl120_itab INTO g_tablctrl120_wa
6382                        INDEX g_curs_ln.
6383          g_srno = g_tablctrl120_wa-srno.
6384        WHEN 'ZCAP'.
6385          MOVE tablctrl130-current_line TO g_curs_ln.
6386          READ TABLE g_tablctrl130_itab INTO g_tablctrl130_wa
6387                        INDEX g_curs_ln.
6388          g_srno = g_tablctrl130_wa-srno.
6389        WHEN 'ZDIS'.
6390          MOVE tablctrl140-current_line TO g_curs_ln.
6391          READ TABLE g_tablctrl140_itab INTO g_tablctrl140_wa
6392                                      INDEX g_curs_ln.
6393          g_srno = g_tablctrl140_wa-srno.
6394      ENDCASE.
6395
6396
6397    ENDFORM.                    " get_srno
6398   *&---------------------------------------------------------------------*
6399   *&      Form  CHANGE_MRP
6400   *&---------------------------------------------------------------------*
6401   *       text
6402   *----------------------------------------------------------------------*
6403   *  -->  p1        text
6404   *  <--  p2        text
6405   *----------------------------------------------------------------------*
6406    FORM change_mrp.
6407      IF  g_mode = 'CHA' OR g_mode = 'REL' OR g_mode = 'APR'.
6408
6409        AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
6410                       ID 'M_BANF_WRK' FIELD zmm_cdhd_st-werks
6411                       ID 'ACTVT' FIELD '01'.
6412        IF sy-subrc = 0.
6413          g_change_auth = 'X'.
6414        ELSE.
6415          g_change_auth = ''.
6416        ENDIF.
6417
6418      ENDIF.
6419    ENDFORM.                    " CHANGE_MRP
*--- End of MZMMCODREQ_ERROR_RESETF01 - 6419 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CCNDD                                   Level 1    Page 6
Object           SAPMZMMCODREQ_ERROR_RESET                 Lines 31
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:05
----------------------------------------------------------------------------------------------------
1      TYPE-POOL CNDD .
2      * Flavor is just a string. It could be any string that identifies
3      * a data object type. The flvor may be seen as something similar
4      * to a class name resp. mime type
5
6      TYPES :  CNDD_FLAVOR(40) TYPE C.
7      TYPES :  CNDD_FLAVORS TYPE CNDD_FLAVOR OCCURS 0.
8
9      * simple Propertybag type. A propertybag consist of a table that
10     * associates name to values.
11
12     TYPES :  CNDD_PROPNAME(40) TYPE C.        " Name of Property
13     TYPES :  CNDD_PROPREMOTEVALUE TYPE SWC_VALUE.  " Value of Remote
14                                                     " Automation PROPERTY
15     TYPES :  CNDD_PROPVALUE TYPE STRING.      " Value of property
16     TYPES :  BEGIN OF CNDD_PROP,
17                 PROPNAME  TYPE CNDD_PROPNAME,    " Property Name
18                 PROPVALUE TYPE CNDD_PROPVALUE,  " Property Value
19              END OF CNDD_PROP.
20     * This structure is for transferring property bag through automation
21     * be carefull, the value is only 80 chars !
22     TYPES :  BEGIN OF CNDD_REMOTEPROP,
23                 PROPNAME  TYPE CNDD_PROPNAME,    " Property Name
24                 PROPVALUE TYPE CNDD_PROPREMOTEVALUE,  " Property Value
25              END OF CNDD_REMOTEPROP.
26
27     TYPES : CNDD_REMOTEPROPS TYPE CNDD_REMOTEPROP OCCURS 0.
28                                                     " Table of Properties
29     TYPES : CNDD_HASHEDPROPS TYPE HASHED TABLE OF CNDD_PROP
30                                      WITH UNIQUE KEY PROPNAME.
31     TYPES : CNDD_PROPS TYPE CNDD_HASHEDPROPS.
*--- End of %_CCNDD - 31 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CCNTL                                   Level 1    Page 7
Object           SAPMZMMCODREQ_ERROR_RESET                 Lines 138
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:05
----------------------------------------------------------------------------------------------------
1      TYPE-POOL CNTL .
2
3      * WARNING: Never(!) include references to Control framework here,
4      * i.e. CL_GUI_CFW, CL_GUI_OBJECT or classes using one of these
5
6      TYPES CNTL_TYPE(4).
7      *ypes cntl_clsid(30).                  "// see TOLE-APP ??  GL 3.8.97
8      TYPES CNTL_CLSID LIKE CNTLSTRLIS-NAME. "// 70 (see editor-line)
9      TYPES CNTL_METRIC(4).
10     TYPES CNTL_OBJ_TYPE(10).
11     TYPES: BEGIN OF CNTL_EVENT,
12              EVENTID TYPE I,
13              IS_SHELLEVENT TYPE C,
14              IS_SYSTEMEVENT TYPE C,
15              SHELLID        TYPE I,
16            END OF CNTL_EVENT.
17
18     TYPES CNTL_EVENTS TYPE TABLE OF CNTL_EVENT.
19
20     TYPES: BEGIN OF CNTL_SIMPLE_EVENT,
21              EVENTID TYPE I,
22              APPL_EVENT TYPE C,
23            END OF CNTL_SIMPLE_EVENT.
24
25     TYPES: CNTL_SIMPLE_EVENTS TYPE TABLE OF CNTL_SIMPLE_EVENT.
26
27     * Control-Types
28     CONSTANTS: CNTL_TYPE_TABCONTROL   TYPE CNTL_TYPE VALUE 'TABC'.
29     CONSTANTS: CNTL_TYPE_INTERACT     TYPE CNTL_TYPE VALUE 'IACT'.
30     CONSTANTS: CNTL_TYPE_TREE         TYPE CNTL_TYPE VALUE 'TREE'.
31     CONSTANTS: CNTL_TYPE_COMBOBOX     TYPE CNTL_TYPE VALUE 'COBX'.
32     CONSTANTS: CNTL_TYPE_RTF_EDIT     TYPE CNTL_TYPE VALUE 'RTFE'.
33     CONSTANTS: CNTL_TYPE_SOUND        TYPE CNTL_TYPE VALUE 'SOUN'.
34     CONSTANTS: CNTL_TYPE_BUSG         TYPE CNTL_TYPE VALUE 'BUSG'.
35     CONSTANTS: CNTL_TYPE_PORT         TYPE CNTL_TYPE VALUE 'PORT'.
36     CONSTANTS: CNTL_TYPE_OCX          TYPE CNTL_OBJ_TYPE VALUE 'OCX'.
37     CONSTANTS: CNTL_TYPE_NO_OCX       TYPE CNTL_OBJ_TYPE VALUE 'NO_OC'.
38
39     * Lifetime
40     CONSTANTS: CNTL_LIFETIME_DEFAULT     TYPE I VALUE 0.
41     CONSTANTS: CNTL_LIFETIME_DYNPRO      TYPE I VALUE 1.
42     CONSTANTS: CNTL_LIFETIME_IMODE       TYPE I VALUE 2.
43     CONSTANTS: CNTL_LIFETIME_TRANSACTION TYPE I VALUE 3.
44     CONSTANTS: CNTL_LIFETIME_SESSION     TYPE I VALUE 4.
45     * Other Constants
46     CONSTANTS: CNTL_METRIC_DYNPRO TYPE CNTL_METRIC VALUE 'DYNP'.
47
48     * Handle-Definition
49     TYPES: BEGIN OF CNTL_HANDLE,
50              OBJ LIKE OBJ_RECORD,
51              SHELLID TYPE I,
52              PARENTID TYPE I,
53              C_TYPE TYPE CNTL_TYPE,
54              CLSID  TYPE CNTL_CLSID,
55              ORIGIN LIKE SY-REPID,
56              HANDLE_TYPE TYPE CNTL_OBJ_TYPE, "// 'OCX', 'NO_OCX'
57              LIFETIME TYPE I,
58              PROGRAM LIKE SY-REPID,
59              DYNNR LIKE SY-DYNNR,
60              IMODE TYPE I,
61              DYNPRO_POS TYPE I,            " KS: Vorlaeufig
62              GUID TYPE I,
63            END OF CNTL_HANDLE.
64
65     * For interface definitions
66     TYPES: CNTL_HANDLE_TAB TYPE TABLE OF CNTL_HANDLE.
67
68     * constants: handle_type_ocx like cntl_handle-handle_type value 'OCX',
69     *       handle_type_no_ocx like cntl_handle-handle_type value 'NO_OCX'.
70
71     * Font-Properties
72     TYPES: BEGIN OF CNTL_FONT,
73              INIT(1) TYPE C,
74              F_TYPE  TYPE I,
75              BOLD    TYPE I,
76              ITALIC  TYPE I,
77              SIZE    TYPE I,
78            END OF CNTL_FONT.
79
80     * Default Constant for Font-Properties
81     CONSTANTS: BEGIN OF CNTL_FONT_DEFAULTS,
82                  INIT(1) TYPE C VALUE ' ',
83                  F_TYPE  TYPE I VALUE '-1',
84                  BOLD    TYPE I VALUE '-1',
85                  ITALIC  TYPE I VALUE '-1',
86                  SIZE    TYPE I VALUE '-1',
87                END OF CNTL_FONT_DEFAULTS.
88
89
90     * Types and Constants for ComboBox-Control
91     CONSTANTS: CNTL_CB_ITEM_MAX_LENGTH TYPE I VALUE 80.
92
93     TYPES: CNTL_ITEM(CNTL_CB_ITEM_MAX_LENGTH).
94     TYPES: CNTL_ITEM_TAB TYPE CNTL_ITEM OCCURS 0.
95
96     * Types for CL_GUI_RESSOURCES                 (BRP, 2/99)
97     TYPES: BEGIN OF CNTL_COL_VALUE,
98                ID        TYPE I,
99                STATE     TYPE I,
100               VALUE     TYPE I,
101           END OF CNTL_COL_VALUE.
102    TYPES: CNTL_COL_VALUE_TAB TYPE CNTL_COL_VALUE OCCURS 0.
103    * Eventparameter im DIAG r.h 03.05.99
104    TYPES: BEGIN OF CNTL_EVENT_PARAM,
105             PID TYPE I,                   "Index of Event
106             VALUE TYPE STRING,            "Value of Parameter
107           END OF CNTL_EVENT_PARAM.
108    TYPES: CNTL_EVENT_PARAM_TAB TYPE SORTED TABLE OF CNTL_EVENT_PARAM
109                                     WITH UNIQUE KEY PID.
110
111    * Struktur für Metrik-Umrechnungsfaktoren
112    TYPES: begin of cntl_m_factors,
113             x type i,
114             y type i,
115           end   of cntl_m_factors,
116           begin of cntl_metric_factors,
117             version type i,
118             char          type cntl_m_factors,
119             char_complete type cntl_m_factors,
120             dm            type cntl_m_factors,
121             screen        type cntl_m_factors,
122           end   of  cntl_metric_factors.
123    * Typ für Frontend-Farben
124    TYPES: begin of cntl_1_color,
125             index type i,          " redundant
126             rgb   type i,          " the value
127           end   of cntl_1_color,
128           cntl_colors type standard table of cntl_1_color.
129    * Typ für List-Dimension
130    types: begin of cntl_list_dim,
131             x type i,
132             y type i,
133           end   of cntl_list_dim.
134
135    * Structure for CL_GUI_DYNPRO_COMPANION (which is free of framework
136    * references)
137    types: cntl_dynpro_companions
138           type standard table of ref to cl_gui_dynpro_companion.
*--- End of %_CCNTL - 138 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CCNTO                                   Level 1    Page 8
Object           SAPMZMMCODREQ_ERROR_RESET                 Lines 15
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:05
----------------------------------------------------------------------------------------------------
1      TYPE-POOL CNTO .
2
3      *CLASS CL_GUI_CONTROL DEFINITION DEFERRED PUBLIC.
4      TYPES CNTO_CONTROL_LIST TYPE REF TO CL_GUI_CONTROL OCCURS 0.
5
6      * Type for lifetime description of a control
7      types: begin of cnto_lifetime_info,
8          LIFETIME TYPE I,
9          DYNPRO_PROGRAM TYPE SYREPID,
10         DYNPRO_NR TYPE SYDYNNR,
11         STACKLEVEL TYPE I,
12         IS_CONTAINER,
13         INVISIBLE,
14         TOP_PARENTID TYPE I,
15            end of cnto_lifetime_info.
*--- End of %_CCNTO - 15 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CCXTAB                                  Level 1    Page 9
Object           SAPMZMMCODREQ_ERROR_RESET                 Lines 6
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:05
----------------------------------------------------------------------------------------------------
1      TYPE-POOL CXTAB .
2
3      TYPES:
4             CXTAB_COLUMN type scxtab_column,
5             CXTAB_CONTROL type scxtab_control,
6             CXTAB_TABSTRIP type scxtab_tabstrip.
*--- End of %_CCXTAB - 6 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_COLE2                                   Level 1    Page 10
Object           SAPMZMMCODREQ_ERROR_RESET                 Lines 43
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:05
----------------------------------------------------------------------------------------------------
1      TYPE-POOL OLE2 .
2
3
4      TYPES:
5        OLE2_OBJECT LIKE   OBJ_RECORD.
6      *    Object handle initialization
7      CONSTANTS:
8        OLE2_OBJECT_HEADER TYPE OLE2_OBJECT-HEADER VALUE 'OBJH',
9        OLE2_OBJECT_TYPE   TYPE OLE2_OBJECT-TYPE   VALUE 'OLE2',
10       OLE2_OBJECT_HANDLE TYPE OLE2_OBJECT-HANDLE VALUE -1,
11       BEGIN OF OLE2_OBJECT_INITIAL,
12         HEADER   TYPE OLE2_OBJECT-HEADER    VALUE OLE2_OBJECT_HEADER,
13         TYPE     TYPE OLE2_OBJECT-TYPE      VALUE OLE2_OBJECT_TYPE,
14         HANDLE   TYPE OLE2_OBJECT-HANDLE    VALUE OLE2_OBJECT_HANDLE,
15         CB_INDEX TYPE OLE2_OBJECT-CB_INDEX  VALUE SPACE,
16         CLSID    TYPE OLE2_OBJECT-CLSID     VALUE SPACE,
17       END OF OLE2_OBJECT_INITIAL.
18
19     CONSTANTS: OLE2_%_POINTER POINTER.
20     TYPES: BEGIN OF OLE2_PCB,
21            PCBID TYPE I,
22            DATACB LIKE OLE2_%_POINTER,
23            END OF OLE2_PCB.
24
25     TYPES BEGIN OF OLE2_METH_PARMS.
26       INCLUDE STRUCTURE SWCONT.
27       TYPES POINTER TYPE OLE2_PCB.
28     TYPES END OF   OLE2_METH_PARMS.
29
30     TYPES:
31       OLE2_METH_PARMS_TAB TYPE OLE2_METH_PARMS OCCURS 0,
32     *    Method Parameter Table: contains the methoid parameter
33     *      types and values exporting and importing parameters.
34       OLE2_LCID TYPE I,
35     *    Locale Id: determines the language and other settings
36     *      (like value formats) of the automation server.
37     *      For more information see: Include OLE2LCID
38       OLE2_TYPE TYPE I.
39     *    OLE Variant Type: determines the "variant type" for the
40     *      parameters of Automation Controller requests.
41     *      For more information see: Include OLE2TYPE
42
43     TYPES: OLE2_PARAMETER LIKE SWCBCONT-VALUE.
*--- End of %_COLE2 - 43 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CTXTED                                  Level 1    Page 11
Object           SAPMZMMCODREQ_ERROR_RESET                 Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:05
----------------------------------------------------------------------------------------------------
1      TYPE-POOL TXTED.
2
3      TYPES:
4      **** The string type defined here is only necessary due to
5      ****  strong typ definition demanded by recent ABAP OO Implementation
6      ****  within the public section.
7      ****  Generic string types are refused already by the syntax check
8      ****  (which is also the case for tables!!!)
9      * string for searching and replacing
10           TXTED_STRING(256).
*--- End of %_CTXTED - 10 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  <CONTRO>                                  Level 1    Page 12
Object           SAPMZMMCODREQ_ERROR_RESET                 Lines 76
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:05
----------------------------------------------------------------------------------------------------
1      *----------------------------------------------------------------------*
2      * INCLUDE <CONTRO>                                                     *
3      * Definitions for control types                                        *
4      *----------------------------------------------------------------------*
5      TYPE-POOLS  CXTAB.
6
7      TYPES       CX_BOOL(1) TYPE C.
8      CONSTANTS:
9                  CX_TRUE  TYPE CX_BOOL VALUE 'X',
10                 CX_FALSE TYPE CX_BOOL VALUE ' '.
11
12     TYPES       %_CX_ID TYPE I.
13     CONSTANTS:  %_CX_GRID_ID      TYPE %_CX_ID VALUE 1,
14                 %_CX_TABLEVIEW_ID TYPE %_CX_ID VALUE 2,
15                 %_CX_TABSTRIP_ID  TYPE %_CX_ID VALUE 3.
16
17     TYPES       %_CX_VERSION TYPE I.
18     CONSTANTS:  %_CX_TABLEVIEW_VERSION VALUE 0,
19                 %_CX_TABSTRIP_VERSION VALUE  0.
20
21     DEFINE %_CX_HEAD.        "Cx_Name, %_CX_ID, %_CX_version,
22       DATA ID      TYPE %_CX_ID       VALUE &2.
23       DATA VERSION TYPE %_CX_version  VALUE &3.
24       DATA NAME    LIKE SCREEN-NAME   VALUE '&1'.
25     END-OF-DEFINITION.
26
27     DEFINE CX_SHOW.
28       CALL 'ab_SetVisibleCx' ID 'PROGRAM' FIELD SY-REPID
29                              ID 'CONTROL' FIELD &1
30                              ID 'VISIBLE' FIELD 1.
31     END-OF-DEFINITION.
32
33     DEFINE CX_HIDE.
34       CALL 'ab_SetVisibleCx' ID 'PROGRAM' FIELD SY-REPID
35                              ID 'CONTROL' FIELD &1
36                              ID 'VISIBLE' FIELD 0.
37     END-OF-DEFINITION.
38
39     DEFINE CX_LOAD_DEFAULT.
40       CALL FUNCTION 'INIT_TC'
41         EXPORTING PG     = SY-REPID
42                   TCNAME = '&1'
43         CHANGING  TC     = &1.
44     END-OF-DEFINITION.
45
46     *>>-------- TableView -----------------------------------------------
47     TYPES: CX_TABLEVIEW_COLUMN TYPE CXTAB_COLUMN,
48            CX_TABLEVIEW        TYPE CXTAB_CONTROL.
49
50     DEFINE %_CX_TABLEVIEW-*CX*. "Instanzname, Referenzdynpro
51       DATA: BEGIN OF &1-*CX*.
52       %_CX_HEAD &1 %_CX_TABLEVIEW_ID %_CX_TABLEVIEW_VERSION.
53       DATA: DYNNR(4) TYPE N VALUE &2.
54       DATA: TOP_LINE TYPE CX_TABLEVIEW-TOP_LINE VALUE 1.
55       DATA: FILL1(8).
56       DATA: END   OF &1-*CX*.
57       DATA: &1 TYPE CX_TABLEVIEW.
58     END-OF-DEFINITION.
59     *<<-------- TableView -----------------------------------------------
60
61     * TabStrip
62     TYPES:
63       CX_TABSTRIP TYPE CXTAB_TABSTRIP.
64
65
66     DEFINE %_CX_TABSTRIP-*CX*.
67       DATA: BEGIN OF &1-*CX*.
68       %_CX_HEAD &1 %_CX_TABSTRIP_ID %_CX_TABSTRIP_VERSION.
69       DATA: FILL(4).
70       DATA: END OF &1-*CX*.
71       DATA: &1 TYPE CX_TABSTRIP.
72     END-OF-DEFINITION.
73
74     *
75     * TabStrip
76     * **********************************************************************
*--- End of <CONTRO> - 76 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  <SYSINI>                                  Level 1    Page 13
Object           SAPMZMMCODREQ_ERROR_RESET                 Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:05
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
Generated incl.  CL_GUI_EASY_SPLITTER_CONTAINERCU          Level 1    Page 14
Object           SAPMZMMCODREQ_ERROR_RESET                 Lines 38
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:05
----------------------------------------------------------------------------------------------------
1      class CL_GUI_EASY_SPLITTER_CONTAINER definition
2        public
3        inheriting from CL_GUI_CONTAINER
4        create public .
5
6      *"* public components of class CL_GUI_EASY_SPLITTER_CONTAINER
7      *"* do not include other source files here!!!
8      public section.
9
10       class-data ORIENTATION_HORIZONTAL type I value 1 read-only .
11       class-data ORIENTATION_VERTICAL type I value 0 read-only .
12       data TOP_LEFT_CONTAINER type ref to CL_GUI_CONTAINER read-only .
13       data BOTTOM_RIGHT_CONTAINER type ref to CL_GUI_CONTAINER read-only .
14       data PANE_ORIENTATION type I read-only .
15
16       methods GET_SASH_POSITION
17         exporting
18           !SASH_POSITION type I
19         exceptions
20           CNTL_SYSTEM_ERROR
21           CNTL_ERROR .
22       methods SET_SASH_POSITION
23         importing
24           value(SASH_POSITION) type I .
25       type-pools CNTL .
26       methods CONSTRUCTOR
27         importing
28           value(LINK_DYNNR) type SY-DYNNR optional
29           value(LINK_REPID) type SY-REPID optional
30           value(METRIC) type CNTL_METRIC default CNTL_METRIC_DYNPRO
31           value(PARENT) type ref to CL_GUI_CONTAINER optional
32           value(ORIENTATION) type I default 0
33           value(SASH_POSITION) type I default 50
34           value(WITH_BORDER) type I default 1
35           value(NAME) type STRING optional
36         exceptions
37           CNTL_ERROR
38           CNTL_SYSTEM_ERROR .
*--- End of CL_GUI_EASY_SPLITTER_CONTAINERCU - 38 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CABAP                                   Level 1    Page 15
Object           SAPMZMMCODREQ_ERROR_RESET                 Lines 360
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:05
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
