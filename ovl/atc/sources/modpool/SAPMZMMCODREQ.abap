----------------------------------------------------------------------------------------------------
Main program     SAPMZMMCODREQ                             Level 0    Page 1
Object           SAPMZMMCODREQ                             Lines 44
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:59
----------------------------------------------------------------------------------------------------
1      *&--------------------------------------------------------------------*
2      *& Module pool       SAPMZMMCODREQ  .                                 *
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
21     * Tran. Code : ZMMCODEREQ                                             *
22     *              ZCODG - Transaction, called from ZMMCODECR             *
23     *                                                                     *
24     ***********************************************************************
25     * CHANGE HISTORY                                                      *
26     * -----------------------                                             *
27     * CAB_AJIT : An 'EXPORT' button has been created for the user to      *
28     *            export line item data to an excel file - 23/02/2006      *
29     *            Necessary logic is written in the form export_data.      *
30     *+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*
31     ************************************************************************
32     *  Date            Transport      USERID        Description
33     * 12/09/2008      <RD1K960036>    SAB_SUMODH
34     *
35     * 1) Change in INCLUDE MZMMCODREQF01.
36     * 2) Change in INCLUDE MZMMCODREQI01.
37     ************************************************************************
38
39
40
41     INCLUDE MZMMCODREQTOP .
42     INCLUDE MZMMCODREQO01 .
43     INCLUDE MZMMCODREQI01 .
44     INCLUDE MZMMCODREQF01 .
*--- End of SAPMZMMCODREQ - 44 lines ---

----------------------------------------------------------------------------------------------------
Include          MZMMCODREQTOP                             Level 1    Page 2
Object           SAPMZMMCODREQ                             Lines 772
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:59
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *& Include MZMMCODREQTOP .                                             *
3      *&                                                                     *
4      *&---------------------------------------------------------------------*
5      ************************************************************************
6      *  Date            Transport      USERID        Description
7      * 30/09/2008      <RD1K960036>    SAB_SUMODH
8      *
9      *1) Removed the Screen Consistency Error By Declaring the G_OK_CODE103.
10     ************************************************************************
11
12     PROGRAM  SAPMZMMCODREQ.
13     *******************Tables**********************************************
14     Tables: Mara, Makt, Zmm_cdhd,zmm_cditem,Zmm_modifier,ZMM_CDHD_ST,
15             ZMM_CODREQ_RSN,t001w,dd07t,zmm_mdl,zmm_cdcodifier,zmm_cap_group.
16
17     *******************Types************************************************
18     Types : Begin of ty_srchlp,
19               mark,
20               srno   type i,
21               matnr  like mara-matnr,
22               lineno type i,
23               wrkst  like mara-wrkst,
24               maktg  like makt-maktg,
25               maktx(88),
26               meins  like mara-meins,
27               mfrpn  like mara-mfrpn,
28               mfrnr  like mara-MFRNR,  "Manufacturer
29               atwrt  like ausp-atwrt,  "capital equipment code
30               mdlno  like ausp-atwrt,  "model number
31     * start of change by yogesh RD1K962288
32               zzcap_code TYPE mara-zzcap_code,
33               ZZMODELNO TYPE mara-ZZMODELNO,
34               ZZOEM_NAME type mara-ZZOEM_NAME,
35               ZZCAP_NAME TYPE mara-ZZCAP_NAME,
36     * end of change by yogesh RD1K962288
37               Filter_flag ,
38             End of ty_srchlp,
39
40             Begin of ty_message,
41               srno(3)  type c,
42               msgtype  type c,
43               msgcode  type c,
44               msgtext(80) type c,
45             End of ty_message,
46
47             Begin of ty_alpha_num1,
48               alpha type c,
49               number(3) type c,
50             End of ty_alpha_num1.
51
52     Data : wa_message type ty_message.
53     Data : ist_message like standard table of wa_message.
54     Data : it_alpha_num1 type standard table of ty_alpha_num1 with header
55     line.
56
57     data : begin of A,
58              mark,
59              A like zmm_cditem,
60            end of A.
61     Data: wa_spatbl like A.
62     Types : char20(20) type c.
63
64     *****************Types defined to display selected option from status***
65     Types: Begin of tab_type,
66              fcode like RSMPE-FUNC,
67            end of tab_type,
68            Begin of ty_alphanum,
69               alphanum(1) type c,
70            end of ty_alphanum.
71     Data: it_tab1 type standard table of tab_type with
72           non-unique default key initial size 10,
73           wa_tab type tab_type.
74
75     ******************Structures********************************************
76     Data: wa_srchlp type ty_srchlp,
77           wa_srchlpmk03 type ty_srchlp.
78     Data: wa_srchlp1 like wa_srchlp.
79     Data: wa_codmod  like zmm_modifier.
80     Data: wa_alphanum type ty_alphanum.
81     Data: wa_char type c.
82     Data: ist_alphanum type table of ty_alphanum.
83     DATA: alpha(26) type c value 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.
84     Data: ist_codmod like table of wa_codmod.
85     Data: ist_spatbl like table of wa_spatbl.
86
87     ******************Internal Tables***************************************
88     Data: ist_srchlp like standard table of wa_srchlp,
89           ist_srchlp_cp like standard table of wa_srchlp,
90           ist_srchlp_cpo like standard table of wa_srchlp,
91           it_cap_group1 like standard table of zmm_cap_group with header
92     line.
93
94     DATA:wa_cap_group1 like line of it_cap_group1.
95     data: OK_CODE      like sy-ucomm.
96     Data: G_OK_CODE115 like sy-ucomm.
97     Data: g_spr_par(3) type c.
98
99     *****************Data Screen 100*******************************
100    Data: g_mode(3)  type c,
101          okcode_100 like sy-ucomm.
102    DATA  dynnr like sy-dynnr.
103
104    Data : G_sel_col(30),
105           g_cursor_line like sy-stepl,
106           g_curr_line like sy-stepl,
107           "added by lipsy <RD1K979105> for getting correct vendor details
108           g_curr_line_vendor like sy-stepl.
109           "end of addition by lipsy
110    Data : g_mattytext like DD07V-DDTEXT,
111           g_plantdesc like t001w-name1,
112           g_locdesc   like dd07v-ddtext.
113    *&spwizard: declaration of tablecontrol 'TABCTRL100' itself
114    controls: TABCTRL100 type tableview using screen 0100.
115    DATA: cols LIKE LINE OF TABCTRL100-cols.
116
117
118    *&spwizard: lines of tablecontrol 'TABCTRL100'
119    data:     g_TABCTRL100_lines  like sy-loopc.
120
121    *&spwizard: type for the data of tablecontrol 'TABCTRL110'
122    types: begin of t_TABCTRL110,
123             FLAG,
124             SRNO like ZMM_CDITEM-SRNO,
125             MATCODE like ZMM_CDITEM-MATCODE,
126             rej_flg like ZMM_CDITEM-REJ_FLG,
127             COMP_FLG like ZMM_CDITEM-COMP_FLG,
128             RSN like ZMM_CDITEM-RSN,
129             OTH1 like ZMM_CDITEM-OTH1,
130             DESC1 like ZMM_CDITEM-DESC1,
131             OTH2 like ZMM_CDITEM-OTH2,
132             DESC2 like ZMM_CDITEM-DESC2,
133             OTH3 like ZMM_CDITEM-OTH3,
134             DESC3 like ZMM_CDITEM-DESC3,
135             OTH4 like ZMM_CDITEM-OTH4,
136             DESC4 like ZMM_CDITEM-DESC4,
137    *{   INSERT         OCPK900087                                        1
138    *********************Add HSN code*************************************
139    STEUC LIKE ZMM_CDITEM-STEUC,
140      TAXIM LIKE ZMM_CDITEM-TAXIM,
141    **********************************************************************
142    *}   INSERT
143             USER_DESC like ZMM_CDITEM-USER_DESC,
144             DESC_FIN like ZMM_CDITEM-DESC_FIN,
145             DESC_CDCELL like ZMM_CDITEM-DESC_CDCELL,
146             UOM like ZMM_CDITEM-UOM,
147             HAZ like ZMM_CDITEM-HAZ,
148             HAZ_FLG like ZMM_CDITEM-HAZ_FLG,
149             ST_COND like ZMM_CDITEM-ST_COND,
150             PACK_COND like ZMM_CDITEM-PACK_COND,
151             GRWGT like ZMM_CDITEM-GRWGT,
152             WTUNIT like ZMM_CDITEM-WTUNIT,
153             GRVOL like ZMM_CDITEM-GRVOL,
154             VOLUNIT like ZMM_CDITEM-VOLUNIT,
155             ENVMAT like ZMM_CDITEM-ENVMAT,
156             TEMPCOND like ZMM_CDITEM-TEMPCOND,
157             SHLF_LIFE1 like ZMM_CDITEM-SHLF_LIFE1,
158             INSUR_MAT like ZMM_CDITEM-INSUR_MAT,
159             CRC_MAT like ZMM_CDITEM-CRC_MAT,
160             DMS like ZMM_CDITEM-DMS,
161             CODBY like ZMM_CDITEM-CODBY,
162             CODDT like ZMM_CDITEM-CODDT,
163             CODCRBY like ZMM_CDITEM-CODCRBY,
164             CODCRDT like ZMM_CDITEM-CODCRDT,
165             matgp like ZMM_CDITEM-matgp,
166             req_lt,     " for requisitioner bush button
167             mat_fnd like zmm_cditem-mat_fnd,
168             dsflag type c,
169           end of t_TABCTRL110.
170
171    types: begin of t_TABCTRL110_a,
172             SRNO(4) ,
173             MATCODE(12),
174             rej_flg(6),
175             COMP_FLG(6),
176             mat_fnd(6),
177             OTH1(4),
178             DESC1(20),
179             OTH2(4),
180             DESC2(20),
181             OTH3(4),
182             DESC3(20),
183             OTH4(4),
184             DESC4(20),
185    *{   INSERT         OCPK900087                                        2
186    STEUC(16),
187      TAXIM(2),
188    *}   INSERT
189             USER_DESC(20),
190             DESC_FIN(88),
191             UOM(3),
192             HAZ_FLG(10),
193             GRWGT(10),
194             WTUNIT(8),
195             GRVOL(10),
196             VOLUNIT(8),
197             ENVMAT(8),
198             SHLF_LIFE1(10),
199             DMS(6),
200             CODBY(12),
201             CODDT(12),
202             CODCRBY(12),
203             CODCRDT(12),
204             matgp(6),
205             dsflag(6),
206           end of t_TABCTRL110_a,
207
208           begin of t_TABCTRL120_a,
209             SRNO(4) ,
210             MATCODE(12),
211             rej_flg(6),
212             COMP_FLG(6),
213             mat_fnd(6),
214             PARTNO(40),
215             DESC_FIN(88),
216    *{   INSERT         OCPK900087                                        9
217     STEUC(16),
218             TAXIM(2),
219    *}   INSERT
220             UOM(3),
221             CAP_CODE(12),
222             CAP_NAME(88),
223             SUBASS(30),
224             OTH_MDL(8),
225             MDLNO(30),
226             MANU(12),
227             HAZ_FLG(10),
228             GRWGT(10),
229             WTUNIT(8),
230             GRVOL(10),
231             VOLUNIT(8),
232             ENVMAT(8),
233             SHLF_LIFE1(10),
234             DMS(6),
235             CODBY(12),
236             CODDT(12),
237             CODCRBY(12),
238             CODCRDT(6),
239             matgp(6),
240    *{   INSERT         OCPK900087                                        6
241
242    *}   INSERT
243             dsflag(6),
244
245           end of t_TABCTRL120_a,
246
247           begin of t_TABCTRL130_a,
248             SRNO(4) ,
249             MATCODE(12),
250             rej_flg(6),
251             COMP_FLG(6),
252             mat_fnd(6),
253             DESC_FIN(88),
254             DESC_CDCELL(87),
255             UOM(3),
256             MATCOST(15),
257             MATCATG(30),
258             MATLOC(30),
259             WRKNG_LIFE(10),
260             SPA_GRP(10),
261             HAZ_FLG(10),
262             GRWGT(10),
263             WTUNIT(8),
264             GRVOL(10),
265             VOLUNIT(8),
266             ENVMAT(8),
267             SHLF_LIFE1(10),
268             DMS(6),
269             CODBY(12),
270             CODDT(12),
271             CODCRBY(12),
272             CODCRDT(6),
273    *{   INSERT         OCPK900087                                        7
274    STEUC(16),
275             TAXIM(2),
276    *}   INSERT
277             dsflag(6),
278
279           end of t_TABCTRL130_a.
280
281
282
283    *&spwizard: internal table for tablecontrol 'TABCTRL110'
284    data:     g_TABCTRL110_itab   type t_TABCTRL110 occurs 0,
285              g_TABCTRL110_wa     type t_TABCTRL110. "work area
286    data:     g_TABCTRL110_copied.           "copy flag
287
288    data : wa_zmm_cditem like zmm_cditem.
289    data : ist_zmm_cditem like table of wa_zmm_cditem with header line.
290    Data:  g_itab_del110  type T_TABCTRL110 OCCURS 0.
291
292    *&spwizard: declaration of tablecontrol 'TABCTRL110' itself
293    controls: TABCTRL110 type tableview using screen 0110.
294    Data : cols110 like line of tabctrl110-cols.
295    *&spwizard: lines of tablecontrol 'TABCTRL110'
296    data:     g_TABCTRL110_lines  like sy-loopc.
297
298    ****Long Text for 110*************************************************
299    DATA: ist_textid like thead,
300          wa_textid  like thead,
301          ist_textid_items like thead occurs 0.
302    DATA : BEGIN OF ist_dtspecs OCCURS 0.
303            INCLUDE STRUCTURE tline.
304    DATA : END OF ist_dtspecs.
305    Data : g_stxl like stxl.
306
307    *&spwizard: type for the data of tablecontrol 'TABLCTRL130'
308    types: begin of t_TABLCTRL130,
309             SRNO like ZMM_CDITEM-SRNO,
310             MATCODE like ZMM_CDITEM-MATCODE,
311             COMP_FLG like ZMM_CDITEM-COMP_FLG,
312             rej_flg like ZMM_CDITEM-REJ_FLG,
313             RSN like ZMM_CDITEM-RSN,
314             OTH1 like ZMM_CDITEM-OTH1,
315             DESC1 like ZMM_CDITEM-DESC1,
316             USER_DESC like ZMM_CDITEM-USER_DESC,
317             DESC_FIN like ZMM_CDITEM-DESC_FIN,
318             DESC_CDCELL like ZMM_CDITEM-DESC_CDCELL,
319             UOM like ZMM_CDITEM-UOM,
320             HAZ like ZMM_CDITEM-HAZ,
321             HAZ_FLG like ZMM_CDITEM-HAZ_FLG,
322             ST_COND like ZMM_CDITEM-ST_COND,
323             PACK_COND like ZMM_CDITEM-PACK_COND,
324             GRWGT like ZMM_CDITEM-GRWGT,
325             WTUNIT like ZMM_CDITEM-WTUNIT,
326             GRVOL like ZMM_CDITEM-GRVOL,
327             VOLUNIT like ZMM_CDITEM-VOLUNIT,
328             ENVMAT like ZMM_CDITEM-ENVMAT,
329             TEMPCOND like ZMM_CDITEM-TEMPCOND,
330             SHLF_LIFE1 like ZMM_CDITEM-SHLF_LIFE1,
331             INSUR_MAT like ZMM_CDITEM-INSUR_MAT,
332             CRC_MAT like ZMM_CDITEM-CRC_MAT,
333             DMS like ZMM_CDITEM-DMS,
334             CODBY like ZMM_CDITEM-CODBY,
335             CODDT like ZMM_CDITEM-CODDT,
336             CODCRBY like ZMM_CDITEM-CODCRBY,
337             CODCRDT like ZMM_CDITEM-CODCRDT,
338             matgp like ZMM_CDITEM-matgp,
339             MATCOST like ZMM_CDITEM-MATCOST,
340             MATCATG like ZMM_CDITEM-MATCATG,
341             MATLOC like ZMM_CDITEM-MATLOC,
342             WRKNG_LIFE like ZMM_CDITEM-WRKNG_LIFE,
343             SPA_GRP like ZMM_CDITEM-SPA_GRP,
344             dsflag type c,
345             req_lt,     " for requisitioner bush button
346             flag,       "flag for mark column
347    *{   INSERT         OCPK900087                                        5
348    STEUC LIKE ZMM_CDITEM-STEUC,
349      TAXIM LIKE ZMM_CDITEM-TAXIM,
350    *}   INSERT
351             mat_fnd like zmm_cditem-mat_fnd,
352           end of t_TABLCTRL130.
353
354    *&spwizard: internal table for tablecontrol 'TABLCTRL130'
355    data:     g_TABLCTRL130_itab   type t_TABLCTRL130 occurs 0,
356              g_TABLCTRL130_wa     type t_TABLCTRL130. "work area
357    data:     g_TABLCTRL130_copied.           "copy flag
358
359    *&spwizard: declaration of tablecontrol 'TABLCTRL130' itself
360    controls: TABLCTRL130 type tableview using screen 0130.
361
362    *&spwizard: lines of tablecontrol 'TABLCTRL130'
363    data:     g_TABLCTRL130_lines  like sy-loopc.
364    DATA      g_CURFIELD(40).
365    Data:     g_itab_del130  type T_TABLCTRL130 OCCURS 0.
366
367    *&spwizard: type for the data of tablecontrol 'TABLCTRL140'
368    types: begin of t_TABLCTRL140,
369             SRNO like ZMM_CDITEM-SRNO,
370             MATCODE like ZMM_CDITEM-MATCODE,
371             COMP_FLG like ZMM_CDITEM-COMP_FLG,
372             RSN like ZMM_CDITEM-RSN,
373             OTH1 like ZMM_CDITEM-OTH1,
374             DESC1 like ZMM_CDITEM-DESC1,
375             USER_DESC like ZMM_CDITEM-USER_DESC,
376             DESC_FIN like ZMM_CDITEM-DESC_FIN,
377             UOM like ZMM_CDITEM-UOM,
378             HAZ like ZMM_CDITEM-HAZ,
379             HAZ_FLG like ZMM_CDITEM-HAZ_FLG,
380             ST_COND like ZMM_CDITEM-ST_COND,
381             PACK_COND like ZMM_CDITEM-PACK_COND,
382             GRWGT like ZMM_CDITEM-GRWGT,
383             WTUNIT like ZMM_CDITEM-WTUNIT,
384             GRVOL like ZMM_CDITEM-GRVOL,
385             VOLUNIT like ZMM_CDITEM-VOLUNIT,
386             ENVMAT like ZMM_CDITEM-ENVMAT,
387             TEMPCOND like ZMM_CDITEM-TEMPCOND,
388             SHLF_LIFE1 like ZMM_CDITEM-SHLF_LIFE1,
389             INSUR_MAT like ZMM_CDITEM-INSUR_MAT,
390             CRC_MAT like ZMM_CDITEM-CRC_MAT,
391             DMS like ZMM_CDITEM-DMS,
392             CODBY like ZMM_CDITEM-CODBY,
393             CODDT like ZMM_CDITEM-CODDT,
394             CODCRBY like ZMM_CDITEM-CODCRBY,
395             CODCRDT like ZMM_CDITEM-CODCRDT,
396             dsflag type c,
397             req_lt,     " for requisitioner bush button
398             flag,       "flag for mark column
399           end of t_TABLCTRL140.
400
401    *&spwizard: internal table for tablecontrol 'TABLCTRL140'
402    data:     g_TABLCTRL140_itab   type t_TABLCTRL140 occurs 0,
403              g_TABLCTRL140_wa     type t_TABLCTRL140. "work area
404    data:     g_TABLCTRL140_copied.           "copy flag
405
406    *&spwizard: declaration of tablecontrol 'TABLCTRL140' itself
407    controls: TABLCTRL140 type tableview using screen 0140.
408
409    *&spwizard: lines of tablecontrol 'TABLCTRL140'
410    data:     g_TABLCTRL140_lines  like sy-loopc.
411    Data:     g_itab_del140  type T_TABLCTRL140 OCCURS 0.
412
413    *&spwizard: type for the data of tablecontrol 'TABLCTRL120'
414    types: begin of t_TABLCTRL120,
415             SRNO like ZMM_CDITEM-SRNO,
416             MATCODE like ZMM_CDITEM-MATCODE,
417             rej_flg like ZMM_CDITEM-REJ_FLG,
418             COMP_FLG like ZMM_CDITEM-COMP_FLG,
419             RSN like ZMM_CDITEM-RSN,
420             PARTNO like ZMM_CDITEM-PARTNO,
421             OTH1 like ZMM_CDITEM-OTH1,
422             DESC1 like ZMM_CDITEM-DESC1,
423             USER_DESC like ZMM_CDITEM-USER_DESC,
424             DESC_FIN like ZMM_CDITEM-DESC_FIN,
425    *{   INSERT         OCPK900087                                        8
426          steuc TYPE zmm_cditem-STEUC,
427          taxim TYPe zmm_cditem-TAXIM,
428    *}   INSERT
429             UOM like ZMM_CDITEM-UOM,
430             CAP_CODE like ZMM_CDITEM-CAP_CODE,
431             SUBASS like ZMM_CDITEM-SUBASS,
432             CAP_NAME like ZMM_CDITEM-CAP_NAME,
433             OTH_MDL  like ZMM_CDITEM-OTH_MDL,
434             MDLNO like ausp-atwrt,
435             MANU like ZMM_CDITEM-MANU,
436             HAZ like ZMM_CDITEM-HAZ,
437             HAZ_FLG like ZMM_CDITEM-HAZ_FLG,
438             ST_COND like ZMM_CDITEM-ST_COND,
439             PACK_COND like ZMM_CDITEM-PACK_COND,
440             GRWGT like ZMM_CDITEM-GRWGT,
441             WTUNIT like ZMM_CDITEM-WTUNIT,
442             GRVOL like ZMM_CDITEM-GRVOL,
443             VOLUNIT like ZMM_CDITEM-VOLUNIT,
444             ENVMAT like ZMM_CDITEM-ENVMAT,
445             TEMPCOND like ZMM_CDITEM-TEMPCOND,
446             SHLF_LIFE1 like ZMM_CDITEM-SHLF_LIFE1,
447             INSUR_MAT like ZMM_CDITEM-INSUR_MAT,
448             CRC_MAT like ZMM_CDITEM-CRC_MAT,
449             DMS like ZMM_CDITEM-DMS,
450             CODBY like ZMM_CDITEM-CODBY,
451             CODDT like ZMM_CDITEM-CODDT,
452             CODCRBY like ZMM_CDITEM-CODCRBY,
453             CODCRDT like ZMM_CDITEM-CODCRDT,
454             matgp like ZMM_CDITEM-matgp,
455             req_lt,     " for requisitioner bush button
456             flag,       "flag for mark column
457             mat_fnd like zmm_cditem-mat_fnd,
458             dsflag type c,
459      "added by lipsy on 04.09.2012 <RD1K979105> for adding another column of vendor name
460    *{   INSERT         OCPK900087                                        4
461
462    *}   INSERT
463             name1 TYPE NAME1_GP,
464      "end of addition by lipsy on 04.09.2012
465           end of t_TABLCTRL120.
466
467    *&spwizard: internal table for tablecontrol 'TABLCTRL120'
468    data:     g_TABLCTRL120_itab   type t_TABLCTRL120 occurs 0,
469              g_TABLCTRL120_wa     type t_TABLCTRL120. "work area
470    data:     g_TABLCTRL120_copied.           "copy flag
471
472    *&spwizard: declaration of tablecontrol 'TABLCTRL120' itself
473    controls: TABLCTRL120 type tableview using screen 0120.
474
475    *&spwizard: lines of tablecontrol 'TABLCTRL120'
476    data:     g_TABLCTRL120_lines  like sy-loopc.
477    Data:     g_itab_del120  type T_TABLCTRL120 OCCURS 0.
478
479    Data : ist_sval1 like sval  occurs 0 with header line.
480    Data : ist_sval2 like sval  occurs 0 with header line.
481    Data : ist_sval3 like sval  occurs 0 with header line.
482    Data : ist_sval4 like sval  occurs 0 with header line.
483
484    **********************Global Data*****************************
485    DATA  sel_flag.
486    DATA  desc(22).
487    data  DESC11(25).
488    data  DESC22(20).
489    data  DESC33(20).
490    data  DESC44(18).
491    DATA  DESC55 like zmm_cditem-user_desc.
492    DATA  DESCP5 like zmm_cditem-user_desc.
493    *{   INSERT         OCPK900087                                        3
494    DATA STEUC(16).
495    *}   INSERT
496
497    DATA  FIELD(30).
498    DATA  FIELD1(30).
499    DATA  g_matgp(9).
500    DATA  g_matgpo(2).
501    Data  g_reqno(10).
502    Data  g_request_no(10).
503    DATA  l_MATTYPE.
504    DATA  g_MATTY(4).
505    DATA  g_lineno type i.
506    DATA  descp1(25).
507    DATA  descp2(20).
508    DATA  descp3(20).
509    DATA  descp4(18).
510    DATA  check_pos.
511    DATA  g_parno.
512    Data  g_user_desc(87).  "pop up
513    Data  g_user_descx(87).
514    DATA  user_desc_len type i.  "pop up
515    DATA  g_partnoc like zmm_cditem-partno.
516    DATA  g_partno(80) type c.
517    DATA  G_FIELD(40).
518    DATA  check_flag.
519    DATA  check_flag1.
520    DATA : G_Desc1(25),G_Desc2(20),G_Desc3(20),G_Desc4(18).
521    DATA  G_screen115_1st.
522    DATA  check_flag2.
523    DATA  g_hd_copied.
524    DATA  g_desc1_4(87).
525    DATA  g_choice.
526    Data: begin of wa_spell_line,
527            tdformat like tline-tdformat,
528            tdline like tline-tdline,
529            srno   like zmm_cditem-srno,
530            spell_err,
531          End of wa_spell_line.
532
533    DATA  ist_spell_line like table of wa_spell_line with header line.
534    DATA  IST_SPELL_LINE1 like table of wa_spell_line with header line.
535    Data : ist_sval like sval  occurs 0 with header line.   "GZSPR
536    Data : ist_mdl like table of zmm_mdl with header line.  "GZSPR
537
538    Data  g_user. " value 'X'.
539    DATA  g_other.
540    Data  g_spellcheck.
541    DATA  g_spellerror.
542
543    *---------------------------------------------------------------------*
544    * Tree
545    *---------------------------------------------------------------------*
546    DATA: GV_SPLITTER TYPE REF TO CL_GUI_EASY_SPLITTER_CONTAINER,
547          GV_SPLITTER1 TYPE REF TO CL_GUI_EASY_SPLITTER_CONTAINER,
548          GV_SPLITTER2 TYPE REF TO CL_GUI_EASY_SPLITTER_CONTAINER.
549
550    DATA: GV_CUSTOM_CONTAINER TYPE REF TO CL_GUI_CUSTOM_CONTAINER.
551
552    DATA: GV_TEXT_EDITOR TYPE REF TO CL_GUI_TEXTEDIT,
553          GV_TEXT_EDITOR1 TYPE REF TO CL_GUI_TEXTEDIT,
554          GV_TEXT_EDITOR2 TYPE REF TO CL_GUI_TEXTEDIT .
555
556    DATA : DISPLAY_FLAG LIKE  LV70T-XFLAG VALUE SPACE.
557
558    DATA: BEGIN OF TLINETAB OCCURS 10.
559            INCLUDE STRUCTURE TLINE.
560    DATA: END OF TLINETAB.
561    DATA: BEGIN OF TLINETAB1 OCCURS 20.
562            INCLUDE STRUCTURE TLINE.
563    DATA: END OF TLINETAB1.
564    DATA: BEGIN OF TLINETAB2 OCCURS 20.
565            INCLUDE STRUCTURE TLINE.
566    DATA: END OF TLINETAB2.
567
568    CONSTANTS: GC_TEXT_LINE_LENGTH TYPE I VALUE 132.
569
570    TYPES: TEXT_TABLE_TYPE(GC_TEXT_LINE_LENGTH) TYPE C OCCURS 0.
571
572    DATA: LT_TEXT_TABLE TYPE TEXT_TABLE_TYPE,
573          LT_TEXT_TABLE1 TYPE TEXT_TABLE_TYPE,
574          LT_TEXT_TABLE2 TYPE TEXT_TABLE_TYPE.
575
576
577    DATA: GV_XTHEAD_UPDKZ TYPE I.
578
579    DATA: BEGIN OF TINLINETAB OCCURS 10.
580            INCLUDE STRUCTURE TLINE.
581    DATA: END OF TINLINETAB.
582
583    DATA: LS_THEAD LIKE THEAD OCCURS 0 WITH HEADER LINE.
584
585    DATA : L_THEAD LIKE LS_THEAD OCCURS 0 WITH HEADER LINE.
586
587    DATA  G_TDNAME(12).
588
589    DATA: BEGIN OF LINES OCCURS 20.
590            INCLUDE STRUCTURE TLINE.
591    DATA: END OF LINES.
592
593    Data: g2_lines like tline.
594
595    DATA: BEGIN OF LINES_CORS OCCURS 20.
596            INCLUDE STRUCTURE TLINE.
597    DATA: END OF LINES_CORS.
598
599    DATA: BEGIN OF g_LINES OCCURS 20.
600            INCLUDE STRUCTURE TLINE.
601    DATA: END OF g_LINES.
602
603    DATA  g_mat_fnd type sy-index.
604    DATA  g_curr_line_110 like sy-stepl.
605    DATA  g_curr_line_120 like sy-stepl.
606    DATA  g_curr_line_100 like sy-stepl.
607    DATA  g_insrflg.
608
609    Data  g_cores_sender like tline-tdline.
610
611    DATA  seltab like rsparams.
612    DATA  ist_seltab like table of rsparams.
613    DATA  wa_rsn like ZMM_CODREQ_RSN.
614    DATA  matgen_flag.
615    DATA  TABCTRL110_check_flag.
616
617    DATA  app_fl2.
618    DATA  g_hits_par.
619    DATA  g_matcode like ZMM_CDITEM-MATCODE.
620    DATA  g_lineno_old like g_lineno.
621    DATA  do_not_change_flag.
622    DATA  g_mat_fnd_flag.
623    DATA  check_others.
624    DATA  g_desc_flag.
625    DATA  g_saveflag.
626    DATA  g_spell_check.
627    DATA  g_check_flag.
628    DATA  ist_modifier_check_list like table of zmm_modifier with header
629    line.
630    DATA  check_list_lines like sy-index.
631    DATA  wa_modifier_check_list like zmm_modifier.
632    DATA  g_long_text_warning.
633    DATA  g_hits_par_oth.
634    DATA  matgrp_change_flag.
635    DATA  matgrp_orig like ZMM_CDITEM-matgp.
636    Data: G_OK_CODE110 like sy-ucomm.
637
638    DATA  g_modi_exists.
639    DATA  g_curr_line1 like g_curr_line.
640    DATA: BEGIN OF CHECKTAB OCCURS 0,
641           BEGRIFF(60),
642           TERMBEGR(60),
643           ART(1),
644          END OF CHECKTAB.
645    DATA  g_user_found.
646    Data g_oth.
647    DATA check_code like sy-ucomm.
648    DATA  g_lock.
649    DATA  check_lines like sy-index.
650    DATA: wa_tabctrl110_cols like line of tabctrl110-cols,
651          wa_tablctrl120_cols like line of tablctrl120-cols,
652          wa_tablctrl130_cols like line of tablctrl130-cols,
653          wa_tablctrl140_cols like line of tablctrl140-cols.
654    DATA: g_filname(40) type c,
655          g_filval(40) type c.
656    DATA  g_filname1(40) type c.
657    DATA  g_delflag.
658    DATA  g_sel_colsort(40) type c.
659    *******************************************************************
660    DATA  g_line132(132) type c.
661    Data:Begin of g_linefrto ,
662           line_fr type i,
663           line_to type i,
664          End of g_linefrto.
665    Data: g_linefrto_itab like table of g_linefrto.
666    DATA  g_matgp_desc(20).
667    DATA  g_sh_partno.
668    Data  g_cors.
669    DATA  g_order(10) type c.
670    Data : g_sh_capeqt , g_sh_mdlno, g_sh_mfr.
671    DATA  g_fst_srchlp.
672    DATA  g_curs_ln type i.
673    DATA  g_mfrnr type lif16.
674    DATA  g_capcode like ausp-atwrt.
675    DATA  g_techapr_visible.
676    DATA  g_req_change.
677    DATA  IST_SVAL_org(30).
678    DATA  g_cursor_fld130(40).
679    DATA  g_curr_line_130 type sy-stepl.
680    DATA  g_atinn like cabn-atinn.
681    DATA  g_atwrt like ausp-atwrt.
682    DATA G_ZZMAGR TYPE MARA-ZZMAGR.
683    DATA  g_confdel.
684    DATA  g_curfield110(40).
685    DATA  g_curfield120(40).
686    DATA  g_curfield130(40).
687    DATA  g_matgp_selected.
688    Data  g_change_auth.
689    DATA  it_cap_group.
690    DATA  it_alpha_num.
691    DATA  a_choice.
692    DATA  g_srno type ZMM_CDITEM-SRNO.
693    DATA  g_new_cap_range.
694    DATA  g_spell_ans.
695    DATA  g_user_logged like sy-uname.
696    DATA  g_matcode_fl.
697    DATA  g_prev_desc_fin like zmm_cditem-desc_fin.
698    DATA  g_desc_fin_chng.
699    DATA  g_matty1 like g_matty.
700    DATA  g_first_time_flag.
701    DATA  do_not_change_flag1.
702    DATA: g_dstext(80) type c,
703          g_dschoice type c.
704    DATA  g_grpcount type i.
705    DATA  g_coduser  type c.
706    DATA  g_len_ex87.  " +
707    DATA  g_desc_fin like zmm_cditem-desc_fin.
708    DATA  g_cditem like zmm_cditem.
709    DATA  g_Current_line type sy-stepl.
710    DATA  G_Duplicate_rec.
711    Data  g_cditem_itab like table of zmm_cditem.
712    Data: p1_file LIKE rlgrap-filename .
713    DATA  g_file_flag.
714    DATA  G_OK_CODE103 LIKE sy-ucomm.
715
716    "added by lipsy on 3.09.2012 <RD1K979105> for attaching files,getting vendor details
717
718    *  ***Working Area for attaching and listing files
719     Data  g_att_files_wa like SWOTOBJID.
720    ***Internal Table.
721      DATA : g_att_files like table of SWOTOBJID.
722
723    data : exclude_tab like soxet occurs 0 with header line.
724
725    """""""""""""FOR ATTACHING PROCESS GUIDE
726     DATA : ist_exclude_tab LIKE soxet OCCURS 0 WITH HEADER LINE.
727      DATA : wa_att_files LIKE swotobjid.
728
729
730    TYPES:BEGIN OF ty_lfa1,
731          lifnr TYPE lifnr,
732          name1  TYPE NAME1_GP,
733      END OF ty_lfa1.
734
735    data :itab_lfa1 TYPE TABLE OF ty_lfa1,
736          wa_lfa1 LIKE LINE OF itab_lfa1,
737          v_vendor TYPE NAME1_GP,
738          g_fname(30) TYPE c ,
739          s_lifnr  TYPE lfa1-lifnr,
740          count type i.
741
742
743    """"""""for sending sms to requistioner
744
745
746    DATA   :It_9205 TYPE  STANDARD TABLE OF  PA9205,
747            Wa_9205 TYPE PA9205 .
748
749    DATA   : mob_no(12) TYPE C.
750
751
752    DATA: http_client TYPE REF TO if_http_client .
753    DATA: wf_string TYPE string ,
754          result    TYPE string .
755    DATA: result_tab TYPE TABLE OF string.
756
757    DATA:R_USER_SMS  TYPE SY-UNAME.
758    DATA : Sms_text(170)  TYPE C.
759
760    DATA:   L_TEXT1 TYPE AD_SMTPADR,
761            L_TEXT2 TYPE AD_SMTPADR,
762            L_TEXT3 TYPE AD_SMTPADR,
763            L_TEXT4 TYPE AD_SMTPADR,
764            L_TEXT5 TYPE AD_SMTPADR.
765
766
767
768
769
770
771
772    "end of addition by lipsy on 3.09.2012
*--- End of MZMMCODREQTOP - 772 lines ---

----------------------------------------------------------------------------------------------------
Include          MZMMCODREQO01                             Level 1    Page 3
Object           SAPMZMMCODREQ                             Lines 3543
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:59
----------------------------------------------------------------------------------------------------
1      ***INCLUDE MZMMCODREQO01 .
2      *&spwizard: output module for tc 'TABCTRL100'. do not change this line!
3      *&spwizard: update lines for equivalent scrollbar
4      module TABCTRL100_change_tc_attr output.
5        describe table IST_SRCHLP lines TABCTRL100-lines.
6      endmodule.
7      *&spwizard: output module for tc 'TABCTRL100'. do not change this line!
8      *&spwizard: get lines of tablecontrol
9      module TABCTRL100_get_lines output.
10       if wa_srchlp-filter_flag = ''.
11         g_TABCTRL100_lines = sy-loopc.
12       endif.
13     endmodule.
14
15     *&spwizard: output module for tc 'TABCTRL110'. do not change this line!
16     *&spwizard: copy ddic-table to itab
17     module TABCTRL110_init output.
18     *{   INSERT         OCPK900087                                        1
19     *DATA: BEGIN OF WA_T604F,
20     *      LAND1 TYPE LAND1,
21     *      STEUC TYPE STEUC,
22     *  END OF WA_T604F,
23     *  ZMSG110 TYPE STRING.
24     *LOOP AT G_TABCTRL110_ITAB INTO G_TABCTRL110_WA.
25     *
26     * SELECT LAND1 STEUC FROM T604F INTO WA_T604F WHERE LAND1 = 'IN' AND STEUC = G_TABCTRL110_WA-STEUC.
27     *ENDSELECT.
28     *
29     *IF WA_T604F IS INITIAL.
30     *
31     * CONCATENATE G_TABCTRL110_WA-STEUC ` DOESN'T EXIST IN T604F ` INTO ZMSG110.
32     * MESSAGE ZMSG110 TYPE 'E'.
33     *
34     *ENDIF.
35     *
36     *CLEAR: G_TABCTRL110_WA, WA_T604F.
37     *ENDLOOP.
38
39     *}   INSERT
40     ******Local data********
41       Data: l_110lns type i,
42             l_tdname like thead-tdname,
43             l_stxl   like stxl.
44
45     *************************
46     *
47       clear : g_ok_code110 , sy-ucomm , g_ok_code115.
48
49     *&spwizard: copy ddic-table 'ZMM_CDITEM'
50     *&spwizard: into internal table 'g_TABCTRL110_itab'
51     *
52       IF g_TABCTRL110_copied is initial.
53         if ( g_mode <> 'CRE' and ZMM_CDHD_ST-MTART = 'ZSTO' )
54            or g_mode = 'REL'.
55
56           select * from ZMM_CDITEM
57              into corresponding fields
58              of table g_TABCTRL110_itab
59           where reqno = zmm_cdhd_st-reqno ORDER BY PRIMARY KEY.
60         endif.
61     ***to delete the internal table entries which do not
62     ***belong to a partiular codifier's assigned class
63         if sy-tcode = 'ZCODG'.
64           select single * from zmm_cdcodifier
65                   where codifier = sy-uname
66                   and   matgp    = ''
67                   and   status   = 'A'.
68           if sy-subrc <> 0.
69             delete g_TABCTRL110_itab where rej_flg = 'RM' or
70                                            rej_flg = 'RT'.
71             select single * from zmm_cdcodifier
72                    where codifier = sy-uname.
73             if sy-subrc = 0.
74               loop at g_TABCTRL110_itab into g_tabctrl110_wa.
75                 select single * from zmm_cdcodifier
76                      where codifier = sy-uname
77                      and   matgp    = g_tabctrl110_wa-matgp.
78                 if sy-subrc <> 0.
79                   delete g_TABCTRL110_itab index sy-tabix.
80                 endif.
81               endloop.
82             endif.
83           endif.
84         endif.
85     ****
86
87         g_TABCTRL110_copied = 'X'.
88         refresh control 'TABCTRL110' from screen '0110'.
89       ENDIF.
90     **********************************************
91     ***To check, if long text maintained or not
92       Case g_mode.
93         WHEN 'CRE'.
94           IF not g_TABCTRL110_itab[] is initial.
95             loop at g_TABCTRL110_itab into g_TABCTRL110_wa.
96               concatenate 'CDDS' g_user_logged g_TABCTRL110_wa-srno
97                into l_tdname.
98               perform check_lt_exist using l_tdname.
99               if not g_lines[] is initial.
100                read table g_lines into g2_lines index 1.
101                if not g2_lines-tdline is initial.
102                  g_TABCTRL110_wa-dsflag = 'X'.
103                  modify g_TABCTRL110_itab from g_TABCTRL110_wa
104                      transporting dsflag
105                      where srno = g_TABCTRL110_wa-srno.
106                  clear g_TABCTRL110_wa-dsflag.
107                else.
108                  g_TABCTRL110_wa-dsflag = ''.
109                  modify g_TABCTRL110_itab from g_TABCTRL110_wa
110                      transporting dsflag
111                      where srno = g_TABCTRL110_wa-srno.
112                endif.
113                clear g2_lines.
114              endif.
115            endloop.
116          ENDIF.
117        WHEN 'CHA' OR 'DIS' OR 'DEL' OR 'REL'.
118          loop at g_TABCTRL110_itab into g_TABCTRL110_wa.
119            concatenate 'CDDS' zmm_cdhd_st-reqno g_TABCTRL110_wa-srno
120            into l_tdname.
121            perform check_lt_exist using l_tdname.
122            if not g_lines[] is initial.
123              read table g_lines into g2_lines index 1.
124              if not g2_lines-tdline is initial.
125                g_TABCTRL110_wa-dsflag = 'X'.
126                modify g_TABCTRL110_itab from g_TABCTRL110_wa
127                     transporting dsflag
128                     where srno = g_TABCTRL110_wa-srno.
129                clear g_TABCTRL110_wa-dsflag.
130              else.
131                g_TABCTRL110_wa-dsflag = ''.
132                modify g_TABCTRL110_itab from g_TABCTRL110_wa
133                     transporting dsflag
134                     where srno = g_TABCTRL110_wa-srno.
135              endif.
136              clear g2_lines.
137            endif.
138          endloop.
139      ENDCASE.
140
141    **********************************************
142      if ( g_mode = 'CRE' ) OR ( g_mode = 'CHA' ).
143        describe table g_TABCTRL110_itab lines l_110lns.
144        if l_110lns < 999.
145          TABCTRL110-lines = 999.
146        endif.
147      endif.
148    endmodule.
149
150    *&spwizard: output module for tc 'TABCTRL110'. do not change this line!
151    *&spwizard: move itab to dynpro
152    module TABCTRL110_move output.
153
154      Data: l_srno type i,
155            l_srnoflag type c,
156            l_itab110 type t_TABCTRL110.
157    *************************************************************
158    *
159      move-corresponding g_TABCTRL110_wa to ZMM_CDITEM.
160      if ( g_mode = 'CRE' ) OR
161         ( g_mode = 'CHA' ) OR
162         ( g_mode = 'REL' ).
163    * --  Commented + moving this to GC_FIELD115.
164    *---  to take care of duplicate record check.
165        clear g_desc1_4.
166        concatenate g_TABCTRL110_wa-desc1
167                    g_TABCTRL110_wa-desc2
168                    g_TABCTRL110_wa-desc3
169                    g_TABCTRL110_wa-desc4
170                    into g_desc1_4 separated by space.
171        condense g_desc1_4.
172        condense g_TABCTRL110_wa-user_desc.
173
174        concatenate g_desc1_4 g_TABCTRL110_wa-user_desc
175        into g_TABCTRL110_wa-desc_fin
176        separated by space.
177    *    concatenate g_TABCTRL110_wa-desc1
178    *                g_TABCTRL110_wa-desc2
179    *                g_TABCTRL110_wa-desc3
180    *                g_TABCTRL110_wa-desc4
181    *                g_TABCTRL110_wa-user_desc
182    *           into g_TABCTRL110_wa-desc_fin
183    *           separated by space.
184
185        condense g_TABCTRL110_wa-desc_fin.
186
187    *----------- End comment +.
188
189    **********To get the maximum srno in the internal table***
190        IF not g_TABCTRL110_wa-desc_fin is initial.
191          clear: l_srno,l_srnoflag.
192          if g_TABCTRL110_wa-SRNO = 0.
193            perform get_nextsrno_sto.
194            move l_srno to g_TABCTRL110_wa-SRNO.
195            modify g_TABCTRL110_itab from g_TABCTRL110_wa
196            index tabctrl110-current_line transporting srno.
197          endif.
198        ENDIF.
199
200    *
201        if TABCTRL110-current_line = g_curr_line_110.
202
203          if not g_mat_fnd is initial.
204            move g_mat_fnd to ZMM_CDITEM-mat_fnd.
205          else.
206            if do_not_change_flag = 'X' .
207              clear do_not_change_flag.
208            else.
209              move g_TABCTRL110_wa-mat_fnd to ZMM_CDITEM-mat_fnd.
210            endif.
211            if g_mat_fnd_flag = 'X'.
212              move g_mat_fnd to ZMM_CDITEM-mat_fnd.
213              clear g_mat_fnd_flag.
214            endif.
215          endif.
216
217          if do_not_change_flag1 = 'X'.
218            move g_TABCTRL110_wa-mat_fnd to ZMM_CDITEM-mat_fnd.
219            clear do_not_change_flag1.
220          endif.
221
222        endif.
223
224        if g_TABCTRL110_wa-dsflag = 'X'.
225          g_long_text_warning = 'X'.
226        endif.
227
228        move g_TABCTRL110_wa-SRNO to ZMM_CDITEM-SRNO.
229        move g_TABCTRL110_wa-desc_fin to ZMM_CDITEM-desc_fin.
230      endif.
231    *
232      IF sy-tcode = 'ZCODG'.
233        concatenate g_TABCTRL110_wa-desc1
234                    g_TABCTRL110_wa-desc2
235                    g_TABCTRL110_wa-desc3
236                    g_TABCTRL110_wa-desc4
237                    g_TABCTRL110_wa-user_desc
238              into  g_TABCTRL110_wa-desc_fin
239              separated by space.
240
241        condense g_TABCTRL110_wa-desc_fin.
242        move g_TABCTRL110_wa-desc_fin to ZMM_CDITEM-desc_fin.
243        if g_TABCTRL110_wa-desc_cdcell is initial.
244         g_TABCTRL110_wa-desc_cdcell = g_TABCTRL110_wa-desc_fin+0(87).
245        endif.
246        move g_TABCTRL110_wa-desc_cdcell to ZMM_CDITEM-desc_cdcell.
247      ENDIF.
248    endmodule.
249    ***********************************************************************
250    *&spwizard: output module for tc 'TABCTRL110'. do not change this line!
251    *&spwizard: get lines of tablecontrol
252    module TABCTRL110_get_lines output.
253      g_TABCTRL110_lines = sy-loopc.
254    endmodule.
255    ************************************************************************
256    *&spwizard: output module for tc 'TABLCTRL130'. do not change this line!
257    *&spwizard: copy ddic-table to itab
258    module TABLCTRL130_init output.
259
260      if g_TABLCTRL130_copied is initial.
261    *&spwizard: copy ddic-table 'ZMM_CDITEM'
262    *&spwizard: into internal table 'g_TABLCTRL130_itab'
263        if g_mode <> 'CRE' and ZMM_CDHD_ST-MTART = 'ZCAP'.
264          select * from ZMM_CDITEM
265             into corresponding fields
266             of table g_TABLCTRL130_itab where
267             reqno = ZMM_CDHD_ST-REQNO ORDER BY PRIMARY KEY.
268        Endif.
269    ***to delete the internal table entries which do not
270    ***belong to a partiular codifier's assigned class
271        if sy-tcode = 'ZCODG'.
272          select single * from zmm_cdcodifier
273                  where codifier = sy-uname
274                  and   matgp    = ''
275                  and   status   = 'A'.
276          if sy-subrc <> 0.
277            delete g_TABLCTRL130_itab where rej_flg = 'RM' or
278                                            rej_flg = 'RT'.
279            select single * from zmm_cdcodifier
280                   where codifier = sy-uname.
281            if sy-subrc = 0.
282              loop at g_TABLCTRL130_itab into g_tablctrl130_wa.
283                select single * from zmm_cdcodifier
284                       where codifier = sy-uname
285                       and   matgp    = g_tablctrl130_wa-matgp.
286                if sy-subrc <> 0.
287                  delete g_TABLCTRL130_itab index sy-tabix.
288                endif.
289              endloop.
290            endif.
291          endif.
292        endif.
293    *
294        g_TABLCTRL130_copied = 'X'.
295        refresh control 'TABLCTRL130' from screen '0130'.
296    *
297      endif.
298    *
299    ***To check, if long text maintained or not
300      Case g_mode.
301        WHEN 'CRE'.
302          IF not g_TABLCTRL130_itab[] is initial.
303            loop at g_TABLCTRL130_itab into g_TABLCTRL130_wa.
304              concatenate 'CDDS' g_user_logged g_TABLCTRL130_wa-srno
305               into l_tdname.
306              perform check_lt_exist using l_tdname.
307              if not g_lines[] is initial.
308                read table g_lines into g2_lines index 1.
309                if not g2_lines-tdline is initial.
310                  g_TABLCTRL130_wa-dsflag = 'X'.
311                  modify g_TABLCTRL130_itab from g_TABLCTRL130_wa
312                      transporting dsflag
313                      where srno = g_TABLCTRL130_wa-srno.
314                  clear g_TABLCTRL130_wa-dsflag.
315                else.
316                  g_TABLCTRL130_wa-dsflag = ''.
317                  modify g_TABLCTRL130_itab from g_TABLCTRL130_wa
318                      transporting dsflag
319                      where srno = g_TABLCTRL130_wa-srno.
320                endif.
321                clear g2_lines.
322              endif.
323            endloop.
324          ENDIF.
325        WHEN 'CHA' OR 'DIS' OR 'DEL' OR 'REL'.
326          loop at g_TABLCTRL130_itab into g_TABLCTRL130_wa.
327            concatenate 'CDDS' zmm_cdhd_st-reqno g_TABLCTRL130_wa-srno
328            into l_tdname.
329            perform check_lt_exist using l_tdname.
330            if not g_lines[] is initial.
331              read table g_lines into g2_lines index 1.
332              if not g2_lines-tdline is initial.
333                g_TABLCTRL130_wa-dsflag = 'X'.
334                modify g_TABLCTRL130_itab from g_TABLCTRL130_wa
335                     transporting dsflag
336                     where srno = g_TABLCTRL130_wa-srno.
337                clear g_TABLCTRL130_wa-dsflag.
338              else.
339                g_TABLCTRL130_wa-dsflag = ''.
340                modify g_TABLCTRL130_itab from g_TABLCTRL130_wa
341                     transporting dsflag
342                     where srno = g_TABLCTRL130_wa-srno.
343              endif.
344              clear g2_lines.
345            endif.
346          endloop.
347      ENDCASE.
348    *  if g_mode <> 'CRE'.
349    *    loop at g_TABLCTRL130_itab into g_TABLCTRL130_wa.
350    *      Clear l_tdname.
351    *      concatenate 'CDDS' zmm_cdhd_st-reqno g_TABLCTRL130_wa-srno
352    *      into l_tdname.
353    *      Select single * into l_stxl from stxl
354    *             where TDOBJECT = 'ZMMCD'
355    *             and   TDNAME   = l_tdname
356    *             and   TDID     = 'CDDS'.
357    *      if sy-subrc = 0.
358    *        g_TABLCTRL130_wa-dsflag = 'X'.
359    *        modify g_TABLCTRL130_itab from g_TABLCTRL130_wa
360    *               transporting dsflag
361    *               where srno = g_TABLCTRL130_wa-srno.
362    *      endif.
363    *    endloop.
364    *  endif.
365    *
366      if ( g_mode = 'CRE' ) OR ( g_mode = 'CHA' ).
367        TABlCTRL130-lines = 999.
368      endif.
369    endmodule.
370    ***********************************************************************
371    *&spwizard: output module for tc 'TABLCTRL130'. do not change this line!
372    *&spwizard: move itab to dynpro
373    module TABLCTRL130_move output.
374      Data: l_itab130 type t_TABLCTRL130,
375            lc_itab130 type t_TABLCTRL130 occurs 0.
376    ***********************************************************
377      move-corresponding g_TABLCTRL130_wa to ZMM_CDITEM.
378      if ( g_mode = 'CRE' ) OR ( g_mode = 'CHA' ).
379        if not g_TABLCTRL130_wa-desc_fin is initial.
380    **********To get the maximum srno in the internal table***
381          clear: l_srno,l_srnoflag.
382    *
383          if g_TABLCTRL130_wa-SRNO = 0.
384            perform get_nextsrno_cap.
385            move l_srno to g_TABLCTRL130_wa-SRNO.
386            modify g_tablctrl130_itab from g_TABLCTRL130_wa index
387                 tablctrl130-current_line transporting srno.
388          endif.
389    ************************************************************
390        endif.
391
392    ******Begin of Original Coding  commented
393
394    *  Data: l_itab130 type t_TABLCTRL130.
395    *  move-corresponding g_TABLCTRL130_wa to ZMM_CDITEM.
396    *  if ( g_mode = 'CRE' ) OR
397    *     ( g_mode = 'CHA' ).
398    *    condense g_TABLCTRL130_wa-desc_fin.
399    *
400    *    if not g_TABLCTRL130_wa-desc_fin is initial.
401    **     move TABLCTRL130-current_line
402    **       to g_TABLCTRL130_wa-SRNO.
403    ***********To get the maximum srno in the internal table***
404    *      clear: l_srno,l_srnoflag.
405    *      describe table g_TABLCTRL130_itab lines l_srno.
406    *      while l_srnoflag <> 'S'.
407    *        read table g_TABLCTRL130_itab into l_itab130
408    *             with key srno = l_srno.
409    *        if sy-subrc <> 0.
410    *          l_srnoflag = 'S'.
411    *        else.
412    *          l_srno = l_srno + 1.
413    *        endif.
414    *      endwhile.
415    *      if g_TABLCTRL130_wa-SRNO = 0.
416    *        move l_srno to g_TABLCTRL130_wa-SRNO.
417    *      endif.
418    *    endif.
419
420    *    if TABLCTRL130-current_line = g_curr_line_130.
421    *      move g_mat_fnd to ZMM_CDITEM-mat_fnd.
422    *    else.
423    *      move g_TABLCTRL130_wa-mat_fnd to ZMM_CDITEM-mat_fnd.
424    *    endif.
425    *
426    *    move g_TABLCTRL130_wa-SRNO to ZMM_CDITEM-SRNO.
427    *    move g_TABLCTRL130_wa-desc_fin to ZMM_CDITEM-desc_fin.
428
429    *****End  Original Coding  commented
430
431        if g_TABLCTRL130_wa-Desc_fin is initial.
432          clear  g_mat_fnd.
433        endif.
434
435        If okcode_100 = 'TABLCTRL130_DELE'.
436          move g_TABLCTRL130_wa-mat_fnd to ZMM_CDITEM-mat_fnd.
437        Else.
438          If TABLCTRL130-current_line = g_curr_line_130.
439            move g_mat_fnd to ZMM_CDITEM-mat_fnd.
440          Else.
441            move g_TABLCTRL130_wa-mat_fnd to ZMM_CDITEM-mat_fnd.
442          Endif.
443        Endif.
444
445    *
446        If  g_TABLCTRL130_wa-SRNO <> 0.
447          move g_TABLCTRL130_wa-SRNO to ZMM_CDITEM-SRNO.
448          move g_TABLCTRL130_wa-desc_fin to ZMM_CDITEM-desc_fin.
449        endif.
450      endif.
451    endmodule.
452    ************************************************************************
453    *&spwizard: output module for tc 'TABLCTRL130'. do not change this line!
454    *&spwizard: get lines of tablecontrol
455    module TABLCTRL130_get_lines output.
456      g_TABLCTRL130_lines = sy-loopc.
457    endmodule.
458    *&---------------------------------------------------------------------*
459    *&      Module  STATUS_0100  OUTPUT
460    *&---------------------------------------------------------------------*
461    *       text
462    *----------------------------------------------------------------------*
463    MODULE STATUS_0100 OUTPUT.
464      Perform fill_sttab.
465      SET PF-STATUS 'OPTNS' excluding it_tab1.
466      case g_mode.
467        when 'CRE'.
468          SET TITLEBAR 'MATCODE_TTL' with ': Create Request'.
469        when 'CHA'.
470          SET TITLEBAR 'MATCODE_TTL' with ': Change Request'.
471        when 'DIS'.
472          SET TITLEBAR 'MATCODE_TTL' with ': Display Request'.
473        when 'DEL'.
474          SET TITLEBAR 'MATCODE_TTL' with ': Delete Request'.
475        when 'REL'.
476          SET TITLEBAR 'MATCODE_TTL' with ': Release Request'.
477        when 'APR'.
478          if g_user = 'M'.
479            SET TITLEBAR 'MATCODE_TTL' with ': Approve Req-MRP'.
480          elseif g_user = 'L'.
481            SET TITLEBAR 'MATCODE_TTL' with ': Approve Req-TAA'.
482          endif.
483        when others.
484          SET TITLEBAR 'MATCODE_TTL' with ''.
485      endcase.
486    *
487    ENDMODULE.                 " STATUS_0100  OUTPUT
488    *&---------------------------------------------------------------------*
489    *&      Module  scr100_attr  OUTPUT
490    *&---------------------------------------------------------------------*
491    *       text
492    *----------------------------------------------------------------------*
493    MODULE scr100_attr OUTPUT.
494
495      Case g_mode.
496    *
497        When ''.
498          loop at screen.
499            screen-input = 0.
500            modify screen.
501          endloop.
502        When 'CRE'.
503          loop at screen.
504            if screen-name = 'ZMM_CDHD_ST-REQNO' OR
505               screen-name = 'ZMM_CDHD_ST-APPROVE_MRP' OR
506               screen-name = 'ZMM_CDHD_ST-REQCL'.
507              screen-input = 0.
508              modify screen.
509            Endif.
510            if screen-name = 'ZMM_CDHD_ST-APPROVE_L2'.
511              if g_techapr_visible = 'Y'.
512                screen-invisible = 0.
513                screen-input     = 0.
514              else.
515                screen-invisible = 1.
516              endif.
517              modify screen.
518            Endif.
519            if screen-name = 'T_TECHAUTH'.
520              if g_techapr_visible = 'Y'.
521                screen-invisible = 0.
522              else.
523                screen-invisible = 1.
524              endif.
525              modify screen.
526            Endif.
527
528          endloop.
529        When 'CHA'.
530          If zmm_cdhd_st-reqno is initial.
531            loop at screen.
532              if screen-name <> 'ZMM_CDHD_ST-REQNO'.
533                screen-input = 0.
534                modify screen.
535              endif.
536            endloop.
537          Else.
538            loop at screen.
539              if screen-group1 = '02'.
540                screen-input = 0.
541                modify screen.
542              endif.
543              if screen-name = 'ZMM_CDHD_ST-MTART' or
544                 screen-name = 'ZMM_CDHD_ST-STATUS_FLAG' or
545                 screen-name = 'ZMM_CDHD_ST-APPROVE_MRP' OR
546                 screen-name = 'ZMM_CDHD_ST-REQCL'.
547                screen-input = 0.
548                modify screen.
549              endif.
550              if screen-name = 'ZMM_CDHD_ST-APPROVE_L2'.
551                if g_techapr_visible = 'Y'.
552                  screen-invisible = 0.
553                  screen-input     = 0.
554                else.
555                  screen-invisible = 1.
556                endif.
557                modify screen.
558              Endif.
559              if screen-name = 'T_TECHAUTH'.
560                if g_techapr_visible = 'Y'.
561                  screen-invisible = 0.
562                else.
563                  screen-invisible = 1.
564                endif.
565                modify screen.
566              Endif.
567            endloop.
568
569          Endif.
570        When 'REL'.
571          loop at screen.
572            if screen-name  = 'ZMM_CDHD_ST-STATUS_FLAG' or
573               Screen-name  = 'ZMM_CDHD_ST-REQNO' or
574               Screen-name  = 'P_REM'             or
575               screen-name  = 'G_SH_CAPEQT'       or
576               screen-name  = 'G_SH_MFR'          or
577               screen-name  = 'G_SH_MDLNO' .
578              screen-input = 1.
579              modify screen.
580            Else.
581              screen-input = 0.
582              modify screen.
583            Endif.
584            if screen-name = 'ZMM_CDHD_ST-APPROVE_L2'.
585              if g_techapr_visible = 'Y'.
586                screen-invisible = 0.
587                screen-input     = 0.
588              else.
589                screen-invisible = 1.
590              endif.
591              modify screen.
592            Endif.
593            if screen-name = 'T_TECHAUTH'.
594              if g_techapr_visible = 'Y'.
595                screen-invisible = 0.
596              else.
597                screen-invisible = 1.
598              endif.
599              modify screen.
600            Endif.
601
602          endloop.
603
604        When 'APR'.
605
606          If zmm_cdhd_st-reqno is initial.
607            loop at screen.
608              if screen-name <> 'ZMM_CDHD_ST-REQNO'.
609                screen-input = 0.
610                modify screen.
611              endif.
612            endloop.
613          Else.
614            loop at screen.
615              if screen-name = 'ZMM_CDHD_ST-APPROVE_MRP'.
616                if  g_user = 'M' .
617                  screen-input = 1.
618                  modify screen.
619                Else.
620                  screen-input = 0.
621                  modify screen.
622                Endif.
623              Elseif screen-name = 'ZMM_CDHD_ST-APPROVE_L2'.
624    *
625                if g_user = 'M'.
626                  if g_techapr_visible = 'Y'.
627                    screen-invisible = 0.
628                    screen-input     = 0.
629                  else.
630                    screen-invisible = 1.
631                  endif.
632                  modify screen.
633                endif.
634    *
635                if g_user = 'L'.
636                  screen-input = 1.
637                  modify screen.
638                Else.
639                  screen-input = 0.
640                  modify screen.
641                Endif.
642    *
643              Elseif screen-name = 'T_TECHAUTH'.
644                if g_user = 'M'.
645                  if g_techapr_visible = 'Y'.
646                    screen-invisible = 0.
647                  else.
648                    screen-invisible = 1.
649                  endif.
650                  modify screen.
651                endif.
652    *
653              Else.
654                screen-input = 0.
655                modify screen.
656              Endif.
657              IF screen-name = 'P_REM'.
658                screen-input = 1.
659                modify screen.
660              ENDIF.
661            endloop.
662          endif.
663    *
664        When others.
665          Loop at screen.
666            if screen-name = 'ZMM_CDHD_ST-REQNO' or
667               screen-name = 'DD'                or
668               screen-name = 'P_REM'             or
669               screen-name = 'ADNL_DESC'         or
670               screen-name = 'G_SH_CAPEQT'       or
671               screen-name = 'G_SH_MFR'          or
672               screen-name = 'G_SH_MDLNO'.
673              screen-input = 1.
674            else.
675              screen-input = 0.
676            endif.
677            modify screen.
678    *
679            If screen-name = 'ZMM_CDHD_ST-APPROVE_L2'.
680              if g_techapr_visible = 'Y'.
681                screen-invisible = 0.
682                screen-input     = 0.
683              else.
684                screen-invisible = 1.
685              endif.
686              modify screen.
687            Endif.
688    *
689            If screen-name = 'T_TECHAUTH'.
690              if g_techapr_visible = 'Y'.
691                screen-invisible = 0.
692              else.
693                screen-invisible = 1.
694              endif.
695              modify screen.
696            Endif.
697    *
698    *        If screen-name = 'ZMM_CDHD_ST-REQCL'.
699    *          if sy-tcode  = 'ZCODG'.
700    *            screen-input = 1.
701    *          else.
702    *            screen-input = 0.
703    *          endif.
704    *          modify screen.
705    *        Endif.
706
707          endloop.
708      Endcase.
709      loop at screen.
710        if sy-tcode <> 'ZCODG'.
711          if screen-name = 'ZMM_MODIFIER-MATGRP'.
712            screen-invisible = 1.
713            modify screen.
714          elseif screen-name = 'PB_CPMC'.
715            screen-invisible = 1.
716            modify screen.
717          elseif screen-name = 'PB_UNDOCPMC'.
718            screen-invisible = 1.
719            modify screen.
720          endif.
721        endif.
722      endloop.
723      perform tcode_zcodg_attr.
724    ENDMODULE.                 " scr100_attr  OUTPUT
725
726
727    *&spwizard: output module for tc 'TABLCTRL140'. do not change this line!
728    *&spwizard: copy ddic-table to itab
729    module TABLCTRL140_init output.
730    *&spwizard: copy ddic-table 'ZMM_CDITEM'
731    *&spwizard: into internal table 'g_TABLCTRL140_itab'
732      if g_TABLCTRL140_copied is initial.
733        if g_mode <> 'CRE' and ZMM_CDHD_ST-MTART = 'ZSPR'.
734          select * from ZMM_CDITEM
735             into corresponding fields
736             of table g_TABLCTRL140_itab where reqno = ZMM_CDHD_ST-REQNO ORDER BY PRIMARY KEY.
737        Endif.    .
738        g_TABLCTRL140_copied = 'X'.
739        refresh control 'TABLCTRL140' from screen '0140'.
740      endif.
741    *
742      If g_mode <> 'CRE'.
743        loop at g_TABLCTRL140_itab into g_TABLCTRL140_wa.
744          Clear l_tdname.
745          concatenate 'CDDS' zmm_cdhd_st-reqno g_TABLCTRL140_wa-srno
746          into l_tdname.
747          Select single * into l_stxl from stxl
748                 where TDOBJECT = 'ZMMCD'
749                 and   TDNAME   = l_tdname
750                 and   TDID     = 'CDDS'.
751          if sy-subrc = 0.
752            g_TABLCTRL140_wa-dsflag = 'X'.
753            modify g_TABLCTRL140_itab from g_TABLCTRL140_wa
754                   transporting dsflag
755                   where srno = g_TABLCTRL140_wa-srno.
756          endif.
757        endloop.
758      Endif.
759    *
760      if ( g_mode = 'CRE' ) OR ( g_mode = 'CHA' ).
761        TABlCTRL140-lines = 999.
762      endif.
763    endmodule.
764
765    *&spwizard: output module for tc 'TABLCTRL140'. do not change this line!
766    *&spwizard: move itab to dynpro
767    module TABLCTRL140_move output.
768      move-corresponding g_TABLCTRL140_wa to ZMM_CDITEM.
769      if g_mode = 'CRE'.
770        concatenate g_TABLCTRL140_wa-desc1
771                    g_TABLCTRL140_wa-user_desc
772               into g_TABLCTRL140_wa-desc_fin
773               separated by space.
774        condense g_TABLCTRL140_wa-desc_fin.
775        if not g_TABLCTRL140_wa-desc_fin is initial.
776          move TABLCTRL140-current_line
777            to g_TABLCTRL140_wa-SRNO.
778        endif.
779
780        move g_TABLCTRL140_wa-SRNO to ZMM_CDITEM-SRNO.
781        move g_TABLCTRL140_wa-desc_fin to ZMM_CDITEM-desc_fin.
782      endif.
783    endmodule.
784
785    *&spwizard: output module for tc 'TABLCTRL140'. do not change this line!
786    *&spwizard: get lines of tablecontrol
787    module TABLCTRL140_get_lines output.
788      g_TABLCTRL140_lines = sy-loopc.
789    endmodule.
790
791    *&spwizard: output module for tc 'TABLCTRL120'. do not change this line!
792    *&spwizard: copy ddic-table to itab
793    module TABLCTRL120_init output.
794      Data : l_120lns type i.
795
796    *&spwizard: copy ddic-table 'ZMM_CDITEM'
797    *&spwizard: into internal table 'g_TABLCTRL120_itab'
798    *****Addition*****************
799      if g_TABLCTRL120_copied is initial.
800        if g_mode <> 'CRE' and ZMM_CDHD_ST-MTART = 'ZSPR'.
801          select * from ZMM_CDITEM
802             into corresponding fields
803             of table g_TABLCTRL120_itab
804          where reqno = zmm_cdhd_st-reqno ORDER BY PRIMARY KEY.
805     "added by lipsy on 04.09.2012 <RD1K979105> for creating a new column for vendor name
806         refresh:itab_lfa1.
807
808     if g_TABLCTRL120_itab is not initial.
809         select lifnr name1
810           FROM lfa1
811           INTO CORRESPONDING FIELDS OF TABLE  itab_lfa1
812           FOR ALL ENTRIES IN g_TABLCTRL120_itab
813           WHERE lifnr =  g_TABLCTRL120_itab-manu.
814     endif.
815
816         loop at g_TABLCTRL120_itab INTO g_TABLCTRL120_wa.
817           clear:wa_lfa1.
818           READ TABLE itab_lfa1 INTO wa_lfa1 with key lifnr = g_TABLCTRL120_wa-manu.
819           g_TABLCTRL120_wa-name1 = wa_lfa1-name1.
820           MODIFY  g_TABLCTRL120_itab FROM g_TABLCTRL120_wa
821            TRANSPORTING name1
822            where manu = g_TABLCTRL120_wa-manu .
823         ENDLOOP.
824     "end of addition by lipsy on 04.09.2012
825        endif.
826    ***to delete the internal table entries which do not
827    ***belong to a partiular codifier's assigned class
828        if sy-tcode = 'ZCODG'.
829          select single * from zmm_cdcodifier
830                  where codifier = sy-uname
831                  and   matgp    = ''
832                  and   status   = 'A'.
833          if sy-subrc <> 0.
834            delete g_TABLCTRL120_itab where rej_flg = 'RM' or
835                                            rej_flg = 'RT'.
836            select single * from zmm_cdcodifier
837                   where codifier = sy-uname.
838            if sy-subrc = 0.
839              loop at g_TABLCTRL120_itab into g_tablctrl120_wa.
840                select single * from zmm_cdcodifier
841                       where codifier = sy-uname
842                       and   matgp    = g_tablctrl120_wa-matgp.
843                if sy-subrc <> 0.
844                  delete g_TABLCTRL120_itab index sy-tabix.
845                endif.
846              endloop.
847            endif.
848          endif.
849        endif.
850    *
851        g_TABLCTRL120_copied = 'X'.
852        refresh control 'TABLCTRL120' from screen '0120'.
853      endif.
854    *
855    ***To check, if long text maintained or not
856      Case g_mode.
857        WHEN 'CRE'.
858          IF not g_TABLCTRL120_itab[] is initial.
859            loop at g_TABLCTRL120_itab into g_TABLCTRL120_wa.
860              concatenate 'CDDS' g_user_logged g_TABLCTRL120_wa-srno
861               into l_tdname.
862              perform check_lt_exist using l_tdname.
863              if not g_lines[] is initial.
864                read table g_lines into g2_lines index 1.
865                if not g2_lines-tdline is initial.
866                  g_TABLCTRL120_wa-dsflag = 'X'.
867                  modify g_TABLCTRL120_itab from g_TABLCTRL120_wa
868                      transporting dsflag
869                      where srno = g_TABLCTRL120_wa-srno.
870                  clear g_TABLCTRL120_wa-dsflag.
871                else.
872                  g_TABLCTRL120_wa-dsflag = ''.
873                  modify g_TABLCTRL120_itab from g_TABLCTRL120_wa
874                      transporting dsflag
875                      where srno = g_TABLCTRL120_wa-srno.
876                endif.
877                clear g2_lines.
878              endif.
879            endloop.
880          ENDIF.
881        WHEN 'CHA' OR 'DIS' OR 'DEL' OR 'REL'.
882          loop at g_TABLCTRL120_itab into g_TABLCTRL120_wa.
883            concatenate 'CDDS' zmm_cdhd_st-reqno g_TABLCTRL120_wa-srno
884            into l_tdname.
885            perform check_lt_exist using l_tdname.
886            if not g_lines[] is initial.
887              read table g_lines into g2_lines index 1.
888              if not g2_lines-tdline is initial.
889                g_TABLCTRL120_wa-dsflag = 'X'.
890                modify g_TABLCTRL120_itab from g_TABLCTRL120_wa
891                     transporting dsflag
892                     where srno = g_TABLCTRL120_wa-srno.
893                clear g_TABLCTRL120_wa-dsflag.
894              else.
895                g_TABLCTRL120_wa-dsflag = ''.
896                modify g_TABLCTRL120_itab from g_TABLCTRL120_wa
897                     transporting dsflag
898                     where srno = g_TABLCTRL120_wa-srno.
899              endif.
900              clear g2_lines.
901            endif.
902          endloop.
903      ENDCASE.
904
905    **********************************************
906      if ( g_mode = 'CRE' ) OR ( g_mode = 'CHA' ).
907        describe table g_TABLCTRL120_itab lines l_120lns.
908        if l_120lns < 999.
909          TABLCTRL120-lines = 999.
910        endif.
911      endif.
912      "added by lipsy on 7.09.2012 <RD1K979105> to get correct vendor details on double click.
913      CLEAR:count.
914      "end of addition by lipsy on 07.09.2012
915    endmodule.
916
917    *&spwizard: output module for tc 'TABLCTRL120'. do not change this line!
918    *&spwizard: move itab to dynpro
919    module TABLCTRL120_move output.
920      Data: l_itab120 type t_TABLCTRL120,
921            lc_itab120 type t_TABLCTRL120 occurs 0.
922    ***********************************************************
923      move-corresponding g_TABLCTRL120_wa to ZMM_CDITEM.
924      "added by lipsy on 05.09.2012 <RD1K979105> for getting vendor name for original equipment
925    *  data:v_vendor TYPE NAME1_GP.
926      CLEAR:v_vendor.
927      move g_TABLCTRL120_wa-name1 to v_vendor.
928      "end of addition by lipsy on 05.09.2012
929      if ( g_mode = 'CRE' ) OR ( g_mode = 'CHA' ).
930        if not g_TABLCTRL120_wa-partno is initial.
931    **********To get the maximum srno in the internal table***
932          clear: l_srno,l_srnoflag.
933          if g_TABLCTRL120_wa-SRNO = 0.
934            perform get_nextsrno_spr.
935            move l_srno to g_TABLCTRL120_wa-SRNO.
936            modify g_tablctrl120_itab from g_TABLCTRL120_wa index
937                 tablctrl120-current_line transporting srno.
938          endif.
939    ************************************************************
940        endif.
941
942        if g_TABLCTRL120_wa-partno is initial.
943          clear  g_mat_fnd.
944        endif.
945
946        if ok_code = 'TABLCTRL120_DELE'.
947          move g_TABLCTRL120_wa-mat_fnd to ZMM_CDITEM-mat_fnd.
948        else.
949    ****Changes***********************************<<SK20102005>>
950          if TABLCTRL120-current_line = g_curr_line_120.
951            move g_mat_fnd to ZMM_CDITEM-mat_fnd.
952          else.
953            move g_TABLCTRL120_wa-mat_fnd to ZMM_CDITEM-mat_fnd.
954          endif.
955    *****End***************************************<<SK20102005>>
956        endif.
957
958    *
959        if  g_TABLCTRL120_wa-SRNO <> 0.
960          move g_TABLCTRL120_wa-SRNO to ZMM_CDITEM-SRNO.
961          move g_TABLCTRL120_wa-desc_fin to ZMM_CDITEM-desc_fin.
962        endif.
963      endif.
964    endmodule.
965
966    *&spwizard: output module for tc 'TABLCTRL120'. do not change this line!
967    *&spwizard: get lines of tablecontrol
968    module TABLCTRL120_get_lines output.
969      g_TABLCTRL120_lines = sy-loopc.
970    endmodule.
971    *&---------------------------------------------------------------------*
972    *&      Module  GET_MATTY_TCT  OUTPUT
973    *&---------------------------------------------------------------------*
974    *       text
975    *----------------------------------------------------------------------*
976    MODULE GET_MATTY_TCT OUTPUT.
977      Perform fill_mattyp_itemdt.
978      set parameter id 'ZMATGP' field ''.
979      set parameter id 'MTA' field ZMM_CDHD_ST-MTART.
980      if dynnr is initial.
981        dynnr = '0101'.
982      Endif.
983
984    ENDMODULE.                 " GET_MATTY_TCT  OUTPUT
985    *&---------------------------------------------------------------------*
986    *&      Module  get_material_helpdata  OUTPUT
987    *&---------------------------------------------------------------------*
988    *       text
989    *----------------------------------------------------------------------*
990    MODULE get_material_helpdata OUTPUT.
991      if   okcode_100 = 'CAPEQT'   or
992           okcode_100 = 'MDLNO'.
993        clear okcode_100.
994      Else.
995        G_MATTY = ZMM_CDHD_ST-MTART.
996        sel_flag = check_pos.
997    *
998        CASE g_matty.
999          WHEN 'ZSTO'.
1000           IF not desc11 is initial .
1001   *{   INSERT         OCPK900087                                       12
1002   *DATA: BEGIN OF WA_T604F,
1003   *      LAND1 TYPE LAND1,
1004   *      STEUC TYPE STEUC,
1005   *  END OF WA_T604F,
1006   *  ZMSG110 TYPE STRING.
1007   **LOOP AT G_TABCTRL110_ITAB INTO G_TABCTRL110_WA.
1008   *READ TABLE G_TABCTRL110_ITAB INTO G_TABCTRL110_WA WITH KEY DESC1 = DESC11.
1009   *STEUC = G_TABCTRL110_WA-STEUC.
1010   * SELECT LAND1 STEUC FROM T604F INTO WA_T604F WHERE LAND1 = 'IN' AND STEUC = STEUC.
1011   *ENDSELECT.
1012   *
1013   *IF WA_T604F IS INITIAL.
1014   *
1015   * CONCATENATE STEUC ` DOESN'T EXIST IN T604F ` INTO ZMSG110.
1016   * MESSAGE ZMSG110 TYPE 'S' DISPLAY LIKE 'E'.
1017   *
1018   *
1019   *ELSE.
1020
1021   *}   INSERT
1022             If FIELD1 = 'ZMM_CDITEM-DESC1'.
1023               REFRESH IST_SRCHLP.
1024               clear : DESC22 ,DESC33 , DESC44.
1025   *{   INSERT         OCPK900087                                        9
1026   *READ TABLE G_TABCTRL110_ITAB INTO G_TABCTRL110_WA WITH KEY DESC1 = DESC11.
1027   *STEUC = G_TABCTRL110_WA-STEUC.
1028   *}   INSERT
1029               PERFORM SELECT_HELP_DATA using
1030                             G_PARTNO
1031                             DESC11
1032                             DESC22
1033                             DESC33
1034                             DESC44
1035   *{   INSERT         OCPK900087                                        1
1036   **********************************************************************
1037   *                          STEUC
1038   **********************************************************************
1039   *}   INSERT
1040                             DESC55
1041                             G_MATGP
1042                             G_MATTY
1043                          changing sel_flag.
1044             Endif.
1045   *{   INSERT         OCPK900087                                       10
1046   *IF SY-SUBRC = 0.
1047
1048   *}   INSERT
1049
1050             If FIELD1 = 'ZMM_CDITEM-DESC2'.
1051               clear : DESC33, DESC44.
1052               PERFORM SELECT_HELP_DATA using
1053                             G_PARTNO
1054                             DESC11
1055                             DESC22
1056                             DESC33
1057                             DESC44
1058   *{   INSERT         OCPK900087                                        2
1059   *STEUC
1060   *}   INSERT
1061                             DESC55
1062                             G_MATGP
1063                             G_MATTY
1064                          changing sel_flag.
1065             Endif.
1066
1067             If FIELD1 = 'ZMM_CDITEM-DESC3'.
1068               clear : DESC44.
1069               PERFORM SELECT_HELP_DATA using
1070                             G_PARTNO
1071                             DESC11
1072                             DESC22
1073                             DESC33
1074                             DESC44
1075   *{   INSERT         OCPK900087                                        3
1076   *STEUC
1077   *}   INSERT
1078                             DESC55
1079                             G_MATGP
1080                             G_MATTY
1081                          changing sel_flag.
1082             Endif.
1083
1084             If FIELD1 = 'ZMM_CDITEM-DESC4'.
1085               PERFORM SELECT_HELP_DATA using
1086                             G_PARTNO
1087                             DESC11
1088                             DESC22
1089                             DESC33
1090                             DESC44
1091   *{   INSERT         OCPK900087                                        4
1092   *STEUC
1093   *}   INSERT
1094                             DESC55
1095                             G_MATGP
1096                             G_MATTY
1097                          changing sel_flag.
1098             Endif.
1099
1100             If FIELD1 = 'ZMM_CDITEM-USER_DESC'.
1101               PERFORM SELECT_HELP_DATA using
1102                             G_PARTNO
1103                             DESC11
1104                             DESC22
1105                             DESC33
1106                             DESC44
1107   *{   INSERT         OCPK900087                                        5
1108   *STEUC
1109   *}   INSERT
1110                             DESC55
1111                             G_MATGP
1112                             G_MATTY
1113                          changing sel_flag.
1114             Endif.
1115           ENDIF.
1116   *{   INSERT         OCPK900087                                       13
1117   *ENDIF.
1118   *}   INSERT
1119
1120           If FIELD1 = 'ZMM_CDITEM-USER_DESC'.
1121             perform search_copyofdesc.
1122           Endif.
1123
1124         WHEN 'ZSPR'.
1125
1126           If FIELD1 = 'ZMM_CDITEM-PARTNO' .
1127
1128             PERFORM CHANGE_PARTNO CHANGING G_PARTNO G_PARTNOC.
1129   *
1130             clear : DESC11, DESC22 ,DESC33 , DESC44.
1131
1132             PERFORM SELECT_HELP_DATA using
1133                           G_PARTNO
1134                           DESC11
1135                           DESC22
1136                           DESC33
1137                           DESC44
1138   *{   INSERT         OCPK900087                                        6
1139   *STEUC
1140   *}   INSERT
1141                           DESC55
1142                           G_MATGP
1143                           G_MATTY
1144                        changing sel_flag.
1145           Endif.
1146
1147           If FIELD1 = 'ZMM_CDITEM-DESC1' .
1148
1149             clear : DESC22 ,DESC33 , DESC44.
1150             PERFORM SELECT_HELP_DATA using
1151                           G_PARTNO
1152                           DESC11
1153                           DESC22
1154                           DESC33
1155                           DESC44
1156   *{   INSERT         OCPK900087                                        7
1157   *STEUC
1158   *}   INSERT
1159                           DESC55
1160                           G_MATGP
1161                           G_MATTY
1162                        changing sel_flag.
1163
1164           Endif.
1165
1166           If FIELD1 = 'ZMM_CDITEM-USER_DESC'.
1167             PERFORM SELECT_HELP_DATA using
1168                           G_PARTNO
1169                           DESC11
1170                           DESC22
1171                           DESC33
1172                           DESC44
1173   *{   INSERT         OCPK900087                                        8
1174   *STEUC
1175   *}   INSERT
1176                           DESC55
1177                           G_MATGP
1178                           G_MATTY
1179                        changing sel_flag.
1180           Endif.
1181
1182         WHEN 'ZCAP'.
1183           Perform get_srchlp_zcap.
1184           Describe table ist_srchlp lines g_mat_fnd.
1185       ENDCASE.
1186
1187       if g_matty = 'ZSTO'.
1188   *{   INSERT         OCPK900087                                       14
1189   *IF WA_T604F IS NOT INITIAL.
1190
1191   *}   INSERT
1192         PERFORM SELECT_MATERIAL_DETAILS.
1193   *{   INSERT         OCPK900087                                       15
1194
1195   *ENDIF.
1196   *}   INSERT
1197       elseif g_matty = 'ZSPR'.
1198         PERFORM SELECT_MATERIAL_DETAILS1.
1199       endif.
1200     Endif.
1201   ENDMODULE.                 " get_material_helpdata  OUTPUT
1202   *&---------------------------------------------------------------------*
1203   *&      Module  header_data  OUTPUT
1204   *&---------------------------------------------------------------------*
1205   *       text
1206   *----------------------------------------------------------------------*
1207   MODULE get_header_data OUTPUT.
1208   *
1209     IF not g_mode is initial.
1210       if g_mode <> 'CRE' and g_hd_copied is initial.
1211         if ( g_mode = 'CHA' ) OR ( g_mode = 'DEL' ).
1212           if not zmm_cdhd_st-reqno is initial.
1213             perform lock_reqhd.
1214           endif.
1215         endif.
1216   ***
1217         if sy-tcode = 'ZCODG'.
1218           perform lock_reqhd.
1219         endif.
1220   *
1221
1222        """""""""""""""""""""""""""""""""""""""""""""""""""""""""
1223         """"""""""added by lipsy on 10.09.2013 for getting correct request no in other than creation mode RD1K982397.
1224
1225                  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
1226                    EXPORTING
1227                  INPUT         = zmm_cdhd_st-reqno
1228                    IMPORTING
1229                  OUTPUT        =  zmm_cdhd_st-reqno.
1230
1231
1232
1233
1234         "end of addition by lipsy on 10.09.2013 for getting correct request no in other than  creation mode RD1K982397.
1235         """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""'
1236
1237
1238         select single * from ZMM_CDHD
1239             into corresponding fields of ZMM_CDHD_ST
1240              where REQNO = zmm_cdhd_st-reqno.
1241         g_first_time_flag = 'X'.
1242         If g_user = 'Z' and zmm_cdhd_st-reqno <> ''.
1243           Perform set_g_user. " For g_user = 'Z' <<03.10.05>>
1244         Endif.
1245   *
1246         if sy-subrc = 0.
1247           g_hd_copied = 'X'.
1248   *
1249           Perform Change_Rel.  "using l_cdhd.
1250           If g_mode = 'APR'.
1251             Perform REL_APR_STATUS.
1252           Endif.
1253         Endif.
1254       Endif.
1255     ELSE.
1256       if sy-tcode = 'ZCODG' and g_hd_copied is initial.
1257         select single * from ZMM_CDHD
1258             into corresponding fields of ZMM_CDHD_ST
1259              where REQNO = zmm_cdhd_st-reqno.
1260         if sy-subrc = 0.
1261           g_hd_copied = 'X'.
1262         endif.
1263       endif.
1264     ENDIF.
1265     set parameter id 'ZMAT_TY' field zmm_cdhd_st-mtart.
1266     perform get_correspondense.
1267
1268     """"""""""""""""""""""""""""""""""""""""""""""""""""
1269       """""""""""""""""""""""""""""""""""""""""""""""""""""
1270     """""""""added by lipsy on 10.09.2013 for telephone no in creation mode RD1K982397.
1271
1272     PERFORM get_tel_creation.
1273
1274     "end of addition by lipsy on 10.09.2013 for telephone no in creation mode RD1K982397.
1275     """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""
1276
1277     """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
1278
1279
1280   ENDMODULE.                 " header_data  OUTPUT
1281   *&---------------------------------------------------------------------*
1282   *&      Module  TABCTRL110_change_col_attr  OUTPUT
1283   *&---------------------------------------------------------------------*
1284   *       text
1285   *----------------------------------------------------------------------*
1286   MODULE TABCTRL110_change_col_attr OUTPUT.
1287     Case g_mode.
1288       When 'CRE' OR 'CHA'.
1289         loop at screen.
1290           if screen-name = 'FILTER' or
1291              screen-name = 'SORTU' or
1292              screen-name = 'SORTD' or
1293              screen-name = 'EXPORT'.
1294             screen-input = 0.
1295             modify screen.
1296           elseif screen-name = 'INS_MODIFIERS' or
1297                  screen-name = 'INS_MDLNO'.
1298             screen-invisible = 1.
1299             modify screen.
1300           endif.
1301   *
1302           if screen-name = 'ZMM_CDITEM-COMP_FLG'.
1303             screen-input = 0.
1304             modify screen.
1305           endif.
1306         endloop.
1307       When 'DIS' OR 'DEL' OR 'REL'.
1308         loop at screen.
1309           if ( screen-name <> 'ZMM_CDITEM-REQ_LT' ).
1310             screen-input = 0.
1311             modify screen.
1312           endif.
1313           if g_mode = 'DIS' OR g_mode = 'REL'.
1314             if screen-name = 'SORTU'  OR
1315                screen-name = 'SORTD' OR
1316                screen-name = 'EXPORT'.
1317                if screen-name = 'EXPORT'.
1318                  screen-invisible = 0.
1319                  screen-input = 1.
1320                else.
1321                  screen-input = 1.
1322                endif.
1323               modify screen.
1324             elseif screen-name = 'INS_MODIFIERS' or
1325                    screen-name = 'INS_MDLNO'.
1326               screen-invisible = 1.
1327               modify screen.
1328             endif.
1329           endif.
1330         endloop.
1331       When 'APR'.
1332         loop at screen.
1333           if screen-name = 'ZMM_CDITEM-COMP_FLG' OR
1334              screen-name = 'ZMM_CDITEM-REQ_LT'  OR
1335              screen-name = 'SORTU'  OR
1336              screen-name = 'SORTD'  OR
1337              screen-name = 'SPELL'.
1338             screen-input  = 1.
1339             modify screen.
1340           elseif screen-name = 'INS_MODIFIERS' or
1341                  screen-name = 'INS_MDLNO'.
1342             screen-invisible = 1.
1343             modify screen.
1344           else.
1345             screen-input  = 0.
1346             modify screen.
1347           endif.
1348         endloop.
1349     Endcase.
1350
1351     IF sy-tcode = 'ZCODG'.
1352       loop at screen.
1353         if screen-name = 'TABCTRL110_DELETE' or
1354            screen-name = 'TABLCTRL120_DELETE' or
1355            screen-name = 'TABLCTRL130_DELETE' or
1356            screen-name = 'TABLCTRL140_DELETE' or
1357            screen-name = 'FILTER'.
1358           screen-input = 0.
1359           modify screen.
1360         elseif screen-name = 'SPELL' or
1361                screen-name = 'INS_MODIFIER' or
1362                screen-name = 'INS_MDLNO'.
1363           screen-input = 1.
1364           modify screen.
1365         endif.
1366       endloop.
1367     ENDIF.
1368
1369   ENDMODULE.                 " TABCTRL110_change_col_attr  OUTPUT
1370   *&---------------------------------------------------------------------*
1371   *&      Module  TABCTRL110_change_field_attr  OUTPUT
1372   *&---------------------------------------------------------------------*
1373   *       text
1374   *----------------------------------------------------------------------*
1375   MODULE TABCTRL110_change_field_attr OUTPUT.
1376   *
1377     SELECT * FROM ZMM_MODIFIER UP TO 1 ROWS
1378
1379    WHERE DESC1 = G_TABCTRL110_WA-DESC1 AND MATGRP = G_TABCTRL110_WA-MATGP
1380    ORDER BY PRIMARY KEY .
1381    ENDSELECT.
1382     if sy-subrc <> 0.
1383       g_parno = '1'.
1384     endif.
1385
1386     if sy-subrc = 0.
1387       if  zmm_modifier-desc2 is initial.
1388         g_parno = '1'.
1389       elseif  zmm_modifier-desc3 is initial.
1390         g_parno = '2'.
1391       elseif  zmm_modifier-desc4 is initial.
1392         g_parno = '3'.
1393       else.
1394         g_parno = '4'.
1395       endif.
1396     endif.
1397
1398
1399     case 'X'.
1400
1401       when ZMM_CDITEM-OTH1.
1402   *
1403         g_parno = '1'.
1404       when ZMM_CDITEM-OTH2.
1405   *
1406         g_parno = '2'.
1407       when ZMM_CDITEM-OTH3.
1408   *
1409         g_parno = '3'.
1410       when ZMM_CDITEM-OTH4.
1411         g_parno = '4'.
1412     endcase.
1413
1414     loop at screen.
1415       case g_parno.
1416         when '0'.
1417           if screen-name = 'ZMM_CDITEM-DESC1'.
1418             screen-input = 0.
1419             modify screen.
1420           endif.
1421           if screen-name = 'ZMM_CDITEM-DESC2'.
1422             screen-input = 0.
1423             modify screen.
1424           endif.
1425           if screen-name = 'ZMM_CDITEM-DESC3'.
1426             screen-input = 0.
1427             modify screen.
1428           endif.
1429           if screen-name = 'ZMM_CDITEM-DESC4'.
1430             screen-input = 0.
1431             modify screen.
1432           endif.
1433         when '5'.
1434           if screen-name = 'ZMM_CDITEM-DESC1'.
1435             screen-input = 0.
1436             modify screen.
1437           endif.
1438           if screen-name = 'ZMM_CDITEM-DESC2'.
1439             screen-input = 0.
1440             modify screen.
1441           endif.
1442           if screen-name = 'ZMM_CDITEM-DESC3'.
1443             screen-input = 0.
1444             modify screen.
1445           endif.
1446           if screen-name = 'ZMM_CDITEM-DESC4'.
1447             screen-input = 0.
1448             modify screen.
1449           endif.
1450         when '1'.
1451           if screen-name = 'ZMM_CDITEM-DESC2'.
1452             screen-input = 0.
1453             modify screen.
1454           endif.
1455           if screen-name = 'ZMM_CDITEM-DESC3'.
1456             screen-input = 0.
1457             modify screen.
1458           endif.
1459           if screen-name = 'ZMM_CDITEM-DESC4'.
1460             screen-input = 0.
1461             modify screen.
1462           endif.
1463         when '2'.
1464           if screen-name = 'ZMM_CDITEM-DESC3'.
1465             screen-input = 0.
1466             modify screen.
1467           endif.
1468           if screen-name = 'ZMM_CDITEM-DESC4'.
1469             screen-input = 0.
1470             modify screen.
1471           endif.
1472         when '3'.
1473           if screen-name = 'ZMM_CDITEM-DESC4' .
1474             screen-input = 0.
1475             modify screen.
1476           endif.
1477         when '4'.
1478           if screen-name = 'ZMM_CDITEM-DESC2'.
1479             screen-input = 1.
1480             modify screen.
1481           endif.
1482           if screen-name = 'ZMM_CDITEM-DESC3'.
1483             screen-input = 1.
1484             modify screen.
1485           endif.
1486           if screen-name = 'ZMM_CDITEM-DESC4'.
1487             screen-input = 1.
1488             modify screen.
1489           endif.
1490       endcase.
1491     endloop.
1492
1493
1494     Case g_mode.
1495         When 'CRE' OR 'CHA'.
1496   *    When 'CRE' OR 'CHA' OR 'COD'.  "GCU 101105
1497         loop at screen.
1498   *
1499           if screen-name = 'ZMM_CDITEM-COMP_FLG'.
1500             screen-input = 0.
1501             modify screen.
1502           endif.
1503           if screen-name = 'ZMM_CDITEM-REQ_LT'.
1504             IF g_TABCTRL110_wa-desc_fin is initial.
1505               screen-input = 0.
1506             ELSE.
1507               screen-input = 1.
1508             ENDIF.
1509             modify screen.
1510           endif.
1511           case g_parno.
1512             when '5'.
1513               if screen-name = 'ZMM_CDITEM-DESC1'.
1514                 screen-input = 0.
1515                 modify screen.
1516               endif.
1517               if screen-name = 'ZMM_CDITEM-DESC2'.
1518                 screen-input = 0.
1519                 modify screen.
1520               endif.
1521               if screen-name = 'ZMM_CDITEM-DESC3'.
1522                 screen-input = 0.
1523                 modify screen.
1524               endif.
1525               if screen-name = 'ZMM_CDITEM-DESC4'.
1526                 screen-input = 0.
1527                 modify screen.
1528               endif.
1529             when '1'.
1530               if screen-name = 'ZMM_CDITEM-DESC2'.
1531                 screen-input = 0.
1532                 modify screen.
1533               endif.
1534               if screen-name = 'ZMM_CDITEM-DESC3'.
1535                 screen-input = 0.
1536                 modify screen.
1537               endif.
1538               if screen-name = 'ZMM_CDITEM-DESC4'.
1539                 screen-input = 0.
1540                 modify screen.
1541               endif.
1542   *
1543               IF not g_TABCTRL110_wa-desc1 is initial.
1544                 IF screen-name = 'ZMM_CDITEM-UOM'.
1545                   screen-required = 1.
1546                   modify screen.
1547                 ENDIF.
1548               ENDIF.
1549   *
1550             when '2'.
1551               if screen-name = 'ZMM_CDITEM-DESC3'.
1552                 screen-input = 0.
1553                 modify screen.
1554               endif.
1555
1556               if screen-name = 'ZMM_CDITEM-DESC4'.
1557                 screen-input = 0.
1558                 modify screen.
1559               endif.
1560   *
1561               IF screen-name = 'ZMM_CDITEM-DESC2'.
1562                 screen-required = 1.
1563                 modify screen.
1564               ENDIF.
1565
1566               IF not g_TABCTRL110_wa-desc2 is initial.
1567                 IF screen-name = 'ZMM_CDITEM-UOM'.
1568                   screen-required = 1.
1569                   modify screen.
1570                 ENDIF.
1571               ENDIF.
1572   *
1573             when '3'.
1574               if screen-name = 'ZMM_CDITEM-DESC4' .
1575                 screen-input = 0.
1576                 modify screen.
1577               endif.
1578   *
1579               IF screen-name = 'ZMM_CDITEM-DESC2'.
1580                 screen-required = 1.
1581                 modify screen.
1582               ENDIF.
1583               IF not g_TABCTRL110_wa-desc2 is initial.
1584                 IF screen-name = 'ZMM_CDITEM-DESC3'.
1585                   screen-required = 1.
1586                   modify screen.
1587                 ENDIF.
1588               ENDIF.
1589               IF not g_TABCTRL110_wa-desc3 is initial.
1590                 IF screen-name = 'ZMM_CDITEM-UOM'.
1591                   screen-required = 1.
1592                   modify screen.
1593                 ENDIF.
1594               ENDIF.
1595   *
1596             when '4'.
1597               if screen-name = 'ZMM_CDITEM-DESC2'.
1598                 screen-input = 1.
1599                 screen-required = 1.
1600                 modify screen.
1601               endif.
1602               if screen-name = 'ZMM_CDITEM-DESC3'.
1603                 screen-input = 1.
1604                 modify screen.
1605               endif.
1606   *
1607               IF not g_TABCTRL110_wa-desc2 is initial.
1608                 IF screen-name = 'ZMM_CDITEM-DESC3'.
1609                   screen-required = 1.
1610                   modify screen.
1611                 ENDIF.
1612               ENDIF.
1613   *
1614               if screen-name = 'ZMM_CDITEM-DESC4'.
1615                 screen-input = 1.
1616                 modify screen.
1617               endif.
1618   *
1619               IF not g_TABCTRL110_wa-desc3 is initial.
1620                 IF screen-name = 'ZMM_CDITEM-DESC4'.
1621                   screen-required = 1.
1622                   modify screen.
1623                 ENDIF.
1624               ENDIF.
1625               IF not g_TABCTRL110_wa-desc4 is initial.
1626                 IF screen-name = 'ZMM_CDITEM-UOM'.
1627                   screen-required = 1.
1628                   modify screen.
1629                 ENDIF.
1630               ENDIF.
1631   *
1632           endcase.
1633   *
1634           if not g_tabctrl110_wa-matcode is initial.
1635             if screen-group4 = 'MC'.
1636               screen-input = 0.
1637               modify screen.
1638             endif.
1639           endif.
1640   *
1641           if screen-name = 'ZMM_CDITEM-REJ_FLG' or
1642              screen-name = 'ZMM_CDITEM-DESC_CDCELL'.
1643             screen-input = 0.
1644             modify screen.
1645           endif.
1646         endloop.
1647       When 'DIS' OR 'DEL' OR
1648            'REL' .
1649         loop at screen.
1650           if screen-name = 'ZMM_CDITEM-REQ_LT'.
1651              screen-input = 1.
1652              modify screen.
1653           else.
1654             screen-input = 0.
1655             modify screen.
1656           endif.
1657         endloop.
1658       WHEN 'APR'.
1659         loop at screen.
1660           if screen-name = 'ZMM_CDITEM-REQ_LT' OR
1661              Screen-name = 'ZMM_CDITEM-COMP_FLG' OR
1662              screen-name = 'ZMM_CDITEM-REJ_FLG'.
1663             screen-input = 1.
1664             modify screen.
1665           else.
1666             screen-input = 0.
1667             modify screen.
1668           endif.
1669         endloop.
1670     Endcase.
1671     perform tcode_zcodg_attr.
1672
1673   ENDMODULE.                 " TABCTRL110_change_field_attr  OUTPUT
1674   *&---------------------------------------------------------------------*
1675   *&      Module  STATUS_0115  OUTPUT
1676   *&---------------------------------------------------------------------*
1677   *       text
1678   *----------------------------------------------------------------------*
1679   MODULE STATUS_0115 OUTPUT.
1680   ** commented on 03-09-05 TO CORRECT ADDTION DESC PROBLEM IN THE LINE
1681   ** WHERE THER ARE NO 'OTHER' ENTERIES.
1682   *  if sy-ucomm <> ''.
1683   *    g_ok_code110 = sy-ucomm.
1684   *  endif.
1685   * End comment.
1686
1687     clear sy-ucomm.
1688     export g_tabctrl110_wa-oth1 to memory id 'OTH1'.
1689     select single WGBEZ from T023T into g_matgp_desc where MATKL =
1690     g_matgp and spras = sy-langu.
1691
1692     clear zmm_modifier.
1693     select single * from zmm_modifier where desc1 = zmm_cditem-desc1 and
1694   MATGRP = zmm_cditem-MATGP.
1695
1696     set pf-status 'STAT115'.
1697   *
1698   ENDMODULE.                 " STATUS_0115  OUTPUT
1699   *&---------------------------------------------------------------------*
1700   *&      Module  ist_alphanum  OUTPUT
1701   *&---------------------------------------------------------------------*
1702   *       text
1703   *----------------------------------------------------------------------*
1704   MODULE ist_alphanum OUTPUT.
1705     g_lineno = '1'.
1706     if check_flag = 'X'.
1707       EXIT.
1708     endif.
1709     check_flag = 'X'.
1710     Data : l_num type i.
1711     do 10 times.
1712       wa_alphanum = l_num.
1713       append wa_alphanum to ist_alphanum.
1714       l_num = l_num + 1.
1715     enddo.
1716     clear l_num.
1717     do 26 times.
1718       wa_alphanum = alpha+l_num(1).
1719   *translate wa_alphanum to upper case.
1720       append wa_alphanum to ist_alphanum.
1721       l_num = l_num + 1.
1722     enddo.
1723   ENDMODULE.                 " ist_alphanum  OUTPUT
1724
1725   *&---------------------------------------------------------------------*
1726   *&      Module  TABCTRL100_set_arrib  OUTPUT
1727   *&---------------------------------------------------------------------*
1728   *       text
1729   *----------------------------------------------------------------------*
1730   MODULE TABCTRL100_set_arrib OUTPUT.
1731
1732     loop at screen.
1733       if screen-name = 'DD' and ( wa_srchlp-mark = '1'
1734                                 or wa_srchlp-matnr is initial ) .
1735         screen-invisible = '1'.
1736         modify screen.
1737       endif.
1738     endloop.
1739
1740   ENDMODULE.                 " TABCTRL100_set_arrib  OUTPUT
1741
1742   *&---------------------------------------------------------------------*
1743   *&      Module  SPLITTER_CONTROL_VORBEREITEN  OUTPUT
1744   *&---------------------------------------------------------------------*
1745   *       text
1746   *----------------------------------------------------------------------*
1747   MODULE SPLITTER_CONTROL_VORBEREITEN OUTPUT.
1748
1749     if gv_splitter is initial.
1750       create object gv_custom_container
1751                     exporting container_name = 'C_CTRL_MAT_SPECS'
1752                     .
1753
1754       create object gv_splitter
1755              exporting
1756                     parent = gv_custom_container
1757                     orientation = 1
1758                     sash_position = 1.
1759     endif.
1760
1761   ENDMODULE.                 " SPLITTER_CONTROL_VORBEREITEN  OUTPUT
1762
1763   *&---------------------------------------------------------------------*
1764   *&      Module  TEXT_CONTROL_VORBEREITEN  OUTPUT
1765   *&---------------------------------------------------------------------*
1766   *       text
1767   *----------------------------------------------------------------------*
1768   MODULE TEXT_CONTROL_VORBEREITEN OUTPUT.
1769
1770     if gv_text_editor is initial.
1771       create object gv_text_editor
1772          exporting
1773               parent = gv_splitter->bottom_right_container
1774               wordwrap_mode = cl_gui_textedit=>wordwrap_at_windowborder
1775               wordwrap_to_linebreak_mode = cl_gui_textedit=>false
1776          exceptions
1777               error_cntl_create      = 1
1778               error_cntl_init        = 2
1779               error_cntl_link        = 3
1780               error_dp_create        = 4
1781               gui_type_not_supported = 5.
1782     endif.
1783
1784     perform text_control_eingabebereit.
1785     perform text_control_set_text_table.
1786
1787   ENDMODULE.                 " TEXT_CONTROL_VORBEREITEN  OUTPUT
1788
1789   *&---------------------------------------------------------------------*
1790   *&      Module  STATUS_0117  OUTPUT
1791   *&---------------------------------------------------------------------*
1792   *       text
1793   *----------------------------------------------------------------------*
1794   MODULE STATUS_0117 OUTPUT.
1795     SET PF-STATUS SPACE.
1796   *  SET TITLEBAR 'xxx'.
1797
1798   ENDMODULE.                 " STATUS_0117  OUTPUT
1799   *&---------------------------------------------------------------------*
1800   *&      Module  TABLCTRL120_change_field_attr  OUTPUT
1801   *&---------------------------------------------------------------------*
1802   *       text
1803   *----------------------------------------------------------------------*
1804   MODULE TABLCTRL120_change_field_attr OUTPUT.
1805   *
1806     SELECT * FROM ZMM_MODIFIER UP TO 1 ROWS
1807    WHERE DESC1 =
1808    G_TABLCTRL120_WA-DESC1
1809    ORDER BY PRIMARY KEY .
1810    ENDSELECT.
1811     if sy-subrc <> 0.
1812       g_parno = '1'.
1813     endif.
1814
1815     if sy-subrc = 0.
1816
1817       if  zmm_modifier-desc2 is initial.
1818         g_parno = '1'.
1819       elseif  zmm_modifier-desc3 is initial.
1820         g_parno = '2'.
1821       elseif  zmm_modifier-desc4 is initial.
1822         g_parno = '3'.
1823       else.
1824         g_parno = '4'.
1825       endif.
1826
1827     endif.
1828
1829     case 'X'.
1830
1831       when ZMM_CDITEM-OTH1.
1832         clear: ZMM_CDITEM-OTH2, ZMM_CDITEM-OTH3, ZMM_CDITEM-OTH4.
1833         g_parno = '1'.
1834       when ZMM_CDITEM-OTH2.
1835         clear: ZMM_CDITEM-OTH3, ZMM_CDITEM-OTH4.
1836         g_parno = '2'.
1837       when ZMM_CDITEM-OTH3.
1838         clear: ZMM_CDITEM-OTH4.
1839         g_parno = '3'.
1840       when ZMM_CDITEM-OTH4.
1841         g_parno = '4'.
1842
1843     endcase.
1844   *
1845     loop at screen.
1846       case g_parno.
1847         when '0'.
1848           if screen-name = 'ZMM_CDITEM-DESC1'.
1849             screen-input = 0.
1850             modify screen.
1851           endif.
1852           if screen-name = 'ZMM_CDITEM-DESC2'.
1853             screen-input = 0.
1854             modify screen.
1855           endif.
1856           if screen-name = 'ZMM_CDITEM-DESC3'.
1857             screen-input = 0.
1858             modify screen.
1859           endif.
1860           if screen-name = 'ZMM_CDITEM-DESC4'.
1861             screen-input = 0.
1862             modify screen.
1863           endif.
1864         when '5'.
1865           if screen-name = 'ZMM_CDITEM-DESC1'.
1866             screen-input = 0.
1867             modify screen.
1868           endif.
1869           if screen-name = 'ZMM_CDITEM-DESC2'.
1870             screen-input = 0.
1871             modify screen.
1872           endif.
1873           if screen-name = 'ZMM_CDITEM-DESC3'.
1874             screen-input = 0.
1875             modify screen.
1876           endif.
1877           if screen-name = 'ZMM_CDITEM-DESC4'.
1878             screen-input = 0.
1879             modify screen.
1880           endif.
1881
1882           if screen-name = 'ZMM_CDITEM-USER_DESC'.
1883             screen-input = 1.
1884             modify screen.
1885           endif.
1886
1887         when '1'.
1888           if screen-name = 'ZMM_CDITEM-DESC2'.
1889             screen-input = 0.
1890             modify screen.
1891           endif.
1892           if screen-name = 'ZMM_CDITEM-DESC3'.
1893             screen-input = 0.
1894             modify screen.
1895           endif.
1896           if screen-name = 'ZMM_CDITEM-DESC4'.
1897             screen-input = 0.
1898             modify screen.
1899           endif.
1900           if screen-name = 'ZMM_CDITEM-USER_DESC'.
1901             screen-input = 1.
1902             modify screen.
1903           endif.
1904         when '2'.
1905           if screen-name = 'ZMM_CDITEM-DESC3'.
1906             screen-input = 0.
1907             modify screen.
1908           endif.
1909           if screen-name = 'ZMM_CDITEM-DESC4'.
1910             screen-input = 0.
1911             modify screen.
1912           endif.
1913           if screen-name = 'ZMM_CDITEM-USER_DESC'.
1914             screen-input = 1.
1915             modify screen.
1916           endif.
1917         when '3'.
1918           if screen-name = 'ZMM_CDITEM-DESC4' .
1919             screen-input = 0.
1920             modify screen.
1921           endif.
1922           if screen-name = 'ZMM_CDITEM-USER_DESC'.
1923             screen-input = 1.
1924             modify screen.
1925           endif.
1926         when '4'.
1927           if screen-name = 'ZMM_CDITEM-DESC2'.
1928             screen-input = 1.
1929             modify screen.
1930           endif.
1931           if screen-name = 'ZMM_CDITEM-DESC3'.
1932             screen-input = 1.
1933             modify screen.
1934           endif.
1935           if screen-name = 'ZMM_CDITEM-DESC4'.
1936             screen-input = 1.
1937             modify screen.
1938           endif.
1939           if screen-name = 'ZMM_CDITEM-USER_DESC'.
1940             screen-input = 1.
1941             modify screen.
1942           endif.
1943       endcase.
1944     endloop.
1945
1946     Case g_mode.
1947       When 'CRE'.
1948         loop at screen.
1949           if Not g_TABLCTRL120_wa-partno IS INITIAL .
1950             if screen-name = 'ZMM_CDITEM-DESC_FIN' or
1951                screen-name = 'ZMM_CDITEM-UOM'      or
1952                screen-name = 'ZMM_CDITEM-CAP_CODE'.
1953               screen-required = 1.
1954               modify screen.
1955             endif.
1956           else.
1957             if screen-name = 'ZMM_CDITEM-DESC_FIN' or
1958                screen-name = 'ZMM_CDITEM-UOM'      or
1959                screen-name = 'ZMM_CDITEM-CAP_CODE'.
1960               screen-input = 0.
1961               modify screen.
1962             endif.
1963           endif.
1964   *
1965           if Not g_TABLCTRL120_wa-CAP_CODE IS INITIAL .
1966             if screen-name = 'ZMM_CDITEM-MDLNO'  or
1967                screen-name = 'ZMM_CDITEM-MANU'.
1968               screen-required = 1.
1969               modify screen.
1970             endif.
1971           else.
1972             if screen-name = 'ZMM_CDITEM-MDLNO'    or
1973                screen-name = 'ZMM_CDITEM-MANU'.
1974               screen-input = 0.
1975               modify screen.
1976             endif.
1977           endif.
1978   *
1979           if screen-name = 'ZMM_CDITEM-REQ_LT'.
1980             IF g_TABLCTRL120_wa-desc_fin is initial.
1981               screen-input = 0.
1982             ELSE.
1983               screen-input = 1.
1984             ENDIF.
1985             modify screen.
1986           endif.
1987   *
1988           if screen-name = 'ZMM_CDITEM-REJ_FLG'.
1989             screen-input = 0.
1990             modify screen.
1991           endif.
1992   *
1993           case g_parno.
1994
1995             when '5'.
1996
1997               if screen-name = 'ZMM_CDITEM-DESC1'.
1998                 screen-input = 0.
1999                 modify screen.
2000               endif.
2001               if screen-name = 'ZMM_CDITEM-DESC2'.
2002                 screen-input = 0.
2003                 modify screen.
2004               endif.
2005               if screen-name = 'ZMM_CDITEM-DESC3'.
2006                 screen-input = 0.
2007                 modify screen.
2008               endif.
2009               if screen-name = 'ZMM_CDITEM-DESC4'.
2010                 screen-input = 0.
2011                 modify screen.
2012               endif.
2013               if screen-name = 'ZMM_CDITEM-USER_DESC'.
2014                 screen-input = 1.
2015                 modify screen.
2016               endif.
2017
2018             when '1'.
2019               if screen-name = 'ZMM_CDITEM-DESC2'.
2020                 screen-input = 0.
2021                 modify screen.
2022               endif.
2023               if screen-name = 'ZMM_CDITEM-DESC3'.
2024                 screen-input = 0.
2025                 modify screen.
2026               endif.
2027               if screen-name = 'ZMM_CDITEM-DESC4'.
2028                 screen-input = 0.
2029                 modify screen.
2030               endif.
2031             when '2'.
2032               if screen-name = 'ZMM_CDITEM-DESC3'.
2033                 screen-input = 0.
2034                 modify screen.
2035               endif.
2036               if screen-name = 'ZMM_CDITEM-DESC4'.
2037                 screen-input = 0.
2038                 modify screen.
2039               endif.
2040             when '3'.
2041               if screen-name = 'ZMM_CDITEM-DESC4' .
2042                 screen-input = 0.
2043                 modify screen.
2044               endif.
2045             when '4'.
2046               if screen-name = 'ZMM_CDITEM-DESC2'.
2047                 screen-input = 1.
2048                 modify screen.
2049               endif.
2050               if screen-name = 'ZMM_CDITEM-DESC3'.
2051                 screen-input = 1.
2052                 modify screen.
2053               endif.
2054               if screen-name = 'ZMM_CDITEM-DESC4'.
2055                 screen-input = 1.
2056                 modify screen.
2057               endif.
2058           endcase.
2059           if not g_tablctrl120_wa-matcode is initial.
2060             if screen-group4 = 'MC'.
2061               screen-input = 0.
2062               modify screen.
2063             endif.
2064           endif.
2065         endloop.
2066       When 'CHA'.
2067         loop at screen.
2068           if Not g_TABLCTRL120_wa-partno IS INITIAL .
2069             if screen-name = 'ZMM_CDITEM-DESC_FIN' or
2070                screen-name = 'ZMM_CDITEM-UOM'      or
2071                screen-name = 'ZMM_CDITEM-CAP_CODE'.
2072               screen-required = 1.
2073               modify screen.
2074             endif.
2075           else.
2076             if screen-name = 'ZMM_CDITEM-DESC_FIN' or
2077                screen-name = 'ZMM_CDITEM-UOM'      or
2078                screen-name = 'ZMM_CDITEM-CAP_CODE'.
2079               screen-input = 0.
2080               modify screen.
2081             endif.
2082           endif.
2083   *
2084           if Not g_TABLCTRL120_wa-CAP_CODE IS INITIAL .
2085             if screen-name = 'ZMM_CDITEM-MDLNO'    or
2086                screen-name = 'ZMM_CDITEM-MANU'.
2087               screen-required = 1.
2088               modify screen.
2089             endif.
2090           else.
2091             if screen-name = 'ZMM_CDITEM-MDLNO'    or
2092                screen-name = 'ZMM_CDITEM-MANU'.
2093               screen-input = 0.
2094               modify screen.
2095             endif.
2096           endif.
2097   *
2098
2099           if screen-name = 'ZMM_CDITEM-REJ_FLG'.
2100             screen-input = 0.
2101             modify screen.
2102           endif.
2103
2104           if screen-name = 'ZMM_CDITEM-REQ_LT'.
2105             IF g_TABLCTRL120_wa-desc_fin is initial.
2106               screen-input = 0.
2107             ELSE.
2108               screen-input = 1.
2109             ENDIF.
2110             modify screen.
2111           endif.
2112
2113           if not g_tablctrl120_wa-matcode is initial.
2114             if screen-group4 = 'MC'.
2115               screen-input = 0.
2116               modify screen.
2117             endif.
2118           endif.
2119
2120         endloop.
2121       When 'DIS' OR 'DEL' OR 'REL'.
2122         loop at screen.
2123           if screen-name <> 'ZMM_CDITEM-REQ_LT'.
2124             screen-input = 0.
2125             modify screen.
2126           endif.
2127         endloop.
2128       WHEN 'APR'.
2129         loop at screen.
2130           if screen-name = 'ZMM_CDITEM-REQ_LT' OR
2131              Screen-name = 'ZMM_CDITEM-COMP_FLG' OR
2132              screen-name = 'ZMM_CDITEM-REJ_FLG'.
2133             screen-input = 1.
2134             modify screen.
2135           else.
2136             screen-input = 0.
2137             modify screen.
2138           endif.
2139         endloop.
2140     Endcase.
2141     perform tcode_zcodg_attr.
2142
2143   ENDMODULE.                 " TABLCTRL120_change_field_attr  OUTPUT
2144   *&---------------------------------------------------------------------*
2145   *&      Module  TABLCTRL130_change_field_attr  OUTPUT
2146   *&---------------------------------------------------------------------*
2147   *       text
2148   *----------------------------------------------------------------------*
2149   MODULE TABLCTRL130_change_field_attr OUTPUT.
2150     Case g_mode.
2151       When 'CRE' OR 'CHA'.
2152         Loop at screen.
2153           If g_TABLCTRL130_wa-DESC_FIN is initial.
2154             if screen-name = 'ZMM_CDITEM-REJ_FLG' or
2155                screen-name = 'ZMM_CDITEM-MATCOST' or
2156                screen-name = 'ZMM_CDITEM-MATCATG' OR
2157                screen-name = 'ZMM_CDITEM-MATLOC' or
2158                screen-name = 'ZMM_CDITEM-WRKNG_LIFE' or
2159   *             screen-name = 'ZMM_CDITEM-DESC_CDCELL' or
2160                screen-name = 'ZMM_CDITEM-SPA_GRP'.
2161               screen-input = 0.
2162               modify screen.
2163             endif.
2164           Else.
2165             If screen-name = 'ZMM_CDITEM-MATCOST' OR
2166                screen-name = 'ZMM_CDITEM-MATCATG' OR
2167                screen-name = 'ZMM_CDITEM-MATLOC'  OR
2168                screen-name = 'ZMM_CDITEM-WRKNG_LIFE' .
2169               screen-required = 1.
2170               modify screen.
2171             endif.
2172           Endif.
2173           if screen-name = 'ZMM_CDITEM-REJ_FLG' or
2174              screen-name = 'ZMM_CDITEM-SPA_GRP' or
2175              screen-name = 'ZMM_CDITEM-DESC_CDCELL'.
2176              screen-input = 0.
2177             modify screen.
2178           endif.
2179
2180           if screen-name = 'ZMM_CDITEM-REQ_LT'.
2181             IF zmm_cditem-desc_fin is initial.
2182   *          IF g_TABLCTRL130_wa-desc_fin is initial.
2183               screen-input = 0.
2184             ELSE.
2185               screen-input = 1.
2186             ENDIF.
2187             modify screen.
2188           endif.
2189
2190           if not g_tablctrl130_wa-matcode is initial.
2191             if screen-group4 = 'MC'.
2192               screen-input = 0.
2193               modify screen.
2194             endif.
2195           endif.
2196
2197         Endloop.
2198         set cursor field 'ZMM_CDITEM-MATCOST'.
2199       When 'DIS' OR 'DEL' OR 'REL'.
2200         loop at screen.
2201           if screen-name <> 'ZMM_CDITEM-REQ_LT'.
2202             screen-input = 0.
2203             modify screen.
2204           endif.
2205         endloop.
2206       WHEN 'APR'.
2207         loop at screen.
2208           if screen-name = 'ZMM_CDITEM-REQ_LT' OR
2209              Screen-name = 'ZMM_CDITEM-COMP_FLG' OR
2210              screen-name = 'ZMM_CDITEM-REJ_FLG'.
2211             screen-input = 1.
2212             modify screen.
2213           else.
2214             screen-input = 0.
2215             modify screen.
2216           endif.
2217         endloop.
2218     Endcase.
2219     perform tcode_zcodg_attr.
2220     If sy-tcode = 'ZCODG'.
2221       loop at screen.
2222         if screen-name = 'ZMM_CDITEM-SPA_GRP'.
2223           screen-input = 1.
2224           screen-required = 1.
2225           modify screen.
2226         endif.
2227       endloop.
2228     Endif.
2229   ENDMODULE.                 " TABLCTRL130_change_field_attr  OUTPUT
2230   *&---------------------------------------------------------------------*
2231   *&      Module  TABLCTRL140_change_field_attr  OUTPUT
2232   *&---------------------------------------------------------------------*
2233   *       text
2234   *----------------------------------------------------------------------*
2235   MODULE TABLCTRL140_change_field_attr OUTPUT.
2236     Case g_mode.
2237       When 'CRE'.
2238         loop at screen.
2239           if screen-name = 'ZMM_CDITEM-DESC_FIN'.
2240             screen-input = 0.
2241             modify screen.
2242           endif.
2243           if screen-name = 'ZMM_CDITEM-REQ_LT'.
2244             IF g_TABLCTRL140_wa-desc_fin is initial.
2245               screen-input = 0.
2246             ELSE.
2247               screen-input = 1.
2248             ENDIF.
2249             modify screen.
2250           endif.
2251         endloop.
2252       When 'CHA'.
2253         loop at screen.
2254           if screen-name = 'ZMM_CDITEM-REQ_LT'.
2255             IF g_TABLCTRL140_wa-desc_fin is initial.
2256               screen-input = 0.
2257             ELSE.
2258               screen-input = 1.
2259             ENDIF.
2260             modify screen.
2261           endif.
2262         endloop.
2263       When 'DIS' OR 'DEL'.
2264         loop at screen.
2265           if screen-name <> 'ZMM_CDITEM-REQ_LT'.
2266             screen-input = 0.
2267             modify screen.
2268           endif.
2269         endloop.
2270     Endcase.
2271
2272   ENDMODULE.                 " TABLCTRL140_change_field_attr  OUTPUT
2273   *&---------------------------------------------------------------------*
2274   *&      Module  STATUS_0105  OUTPUT
2275   *&---------------------------------------------------------------------*
2276   *       text
2277   *----------------------------------------------------------------------*
2278   MODULE STATUS_0105 OUTPUT.
2279
2280     SET PF-STATUS 'STAT105'.
2281
2282   ENDMODULE.                 " STATUS_0105  OUTPUT
2283   *&---------------------------------------------------------------------*
2284   *&      Module  SPLITTER_CTRL_VORBEREITEN  OUTPUT
2285   *&---------------------------------------------------------------------*
2286   *       text
2287   *----------------------------------------------------------------------*
2288   MODULE SPLITTER_CTRL_VORBEREITEN OUTPUT.
2289
2290     if gv_splitter1 is initial.
2291       create object gv_custom_container
2292                     exporting container_name = 'C_DIS'.
2293
2294
2295       create object gv_splitter1
2296              exporting
2297                     parent = gv_custom_container
2298                     orientation = 1
2299                     sash_position = 1.
2300     endif.
2301     if gv_splitter2 is initial.
2302
2303       create object gv_custom_container
2304                     exporting container_name = 'C_WRT'.
2305
2306
2307       create object gv_splitter2
2308              exporting
2309                     parent = gv_custom_container
2310                     orientation = 1
2311                     sash_position = 1.
2312
2313     endif.
2314
2315   ENDMODULE.                 " SPLITTER_CTRL_VORBEREITEN  OUTPUT
2316   *&---------------------------------------------------------------------*
2317   *&      Module  TEXT_CTRL_VORBEREITEN  OUTPUT
2318   *&---------------------------------------------------------------------*
2319   *       text
2320   *----------------------------------------------------------------------*
2321   MODULE TEXT_CTRL_VORBEREITEN OUTPUT.
2322     if gv_text_editor1 is initial.
2323       create object gv_text_editor1
2324          exporting
2325               parent = gv_splitter1->bottom_right_container
2326               wordwrap_mode = cl_gui_textedit=>wordwrap_at_windowborder
2327               wordwrap_to_linebreak_mode = cl_gui_textedit=>false
2328          exceptions
2329               error_cntl_create      = 1
2330               error_cntl_init        = 2
2331               error_cntl_link        = 3
2332               error_dp_create        = 4
2333               gui_type_not_supported = 5.
2334     endif.
2335     if gv_text_editor2 is initial.
2336       create object gv_text_editor2
2337          exporting
2338               parent = gv_splitter2->bottom_right_container
2339               wordwrap_mode = cl_gui_textedit=>wordwrap_at_windowborder
2340               wordwrap_to_linebreak_mode = cl_gui_textedit=>false
2341          exceptions
2342               error_cntl_create      = 1
2343               error_cntl_init        = 2
2344               error_cntl_link        = 3
2345               error_dp_create        = 4
2346               gui_type_not_supported = 5.
2347     endif.
2348
2349     perform text_control_eingabebereit.
2350     perform text_control_set_text_table.
2351
2352   ENDMODULE.                 " TEXT_CTRL_VORBEREITEN OUTPUT
2353   *&---------------------------------------------------------------------*
2354   *&      Module  SPLITTER_CTRL_VORBEREITEN1  OUTPUT
2355   *&---------------------------------------------------------------------*
2356   *       text
2357   *----------------------------------------------------------------------*
2358   MODULE SPLITTER_CTRL_VORBEREITEN1 OUTPUT.
2359     if gv_splitter1 is initial.
2360       create object gv_custom_container
2361                     exporting container_name = 'C_DIS'.
2362
2363       create object gv_splitter1
2364              exporting
2365                     parent = gv_custom_container
2366                     orientation = 1
2367                     sash_position = 1.
2368     endif.
2369
2370     if ( g_mode = 'CRE' ) or ( g_mode = 'CHA' ) OR
2371        ( g_mode = 'REL' ) or ( g_mode = 'MRP' ) OR
2372        ( g_mode = 'APR' ) or sy-tcode = 'ZCODG'.
2373
2374       if gv_splitter2 is initial.
2375
2376         create object gv_custom_container
2377                       exporting container_name = 'C_WRT'.
2378
2379
2380         create object gv_splitter2
2381                exporting
2382                       parent = gv_custom_container
2383                       orientation = 1
2384                       sash_position = 1.
2385
2386       endif.
2387     endif.
2388
2389   ENDMODULE.                 " SPLITTER_CTRL_VORBEREITEN1  OUTPUT
2390   *&---------------------------------------------------------------------*
2391   *&      Module  TEXT_CTRL_VORBEREITEN1  OUTPUT
2392   *&---------------------------------------------------------------------*
2393   *       text
2394   *----------------------------------------------------------------------*
2395   MODULE TEXT_CTRL_VORBEREITEN1 OUTPUT.
2396     if gv_text_editor1 is initial.
2397       create object gv_text_editor1
2398          exporting
2399               parent = gv_splitter1->bottom_right_container
2400               wordwrap_mode = cl_gui_textedit=>wordwrap_at_windowborder
2401               wordwrap_to_linebreak_mode = cl_gui_textedit=>false
2402          exceptions
2403               error_cntl_create      = 1
2404               error_cntl_init        = 2
2405               error_cntl_link        = 3
2406               error_dp_create        = 4
2407               gui_type_not_supported = 5.
2408     endif.
2409     if ( g_mode = 'CRE' ) or ( g_mode = 'CHA' ) OR
2410        ( g_mode = 'REL' ) or ( g_mode = 'MRP' ) OR
2411        ( g_mode = 'APR' ) or sy-tcode = 'ZCODG'.
2412
2413       if gv_text_editor2 is initial.
2414         create object gv_text_editor2
2415            exporting
2416                 parent = gv_splitter2->bottom_right_container
2417                 wordwrap_mode = cl_gui_textedit=>wordwrap_at_windowborder
2418                 wordwrap_to_linebreak_mode = cl_gui_textedit=>false
2419            exceptions
2420                 error_cntl_create      = 1
2421                 error_cntl_init        = 2
2422                 error_cntl_link        = 3
2423                 error_dp_create        = 4
2424                 gui_type_not_supported = 5.
2425       endif.
2426     endif.
2427
2428     perform text_control_eingabebereit1.
2429     perform text_control_set_text_table1.
2430
2431   ENDMODULE.                 " TEXT_CTRL_VORBEREITEN1  OUTPUT
2432
2433   *&---------------------------------------------------------------------*
2434   *&      Module  spell_ins_modi  OUTPUT
2435   *&---------------------------------------------------------------------*
2436   *       text
2437   *----------------------------------------------------------------------*
2438   MODULE spell_ins_modi OUTPUT.
2439   ENDMODULE.                 " spell_ins_modi  OUTPUT
2440
2441   *&---------------------------------------------------------------------*
2442   *&      Module  INITIALIZE  OUTPUT
2443   *&---------------------------------------------------------------------*
2444   *       text
2445   *----------------------------------------------------------------------*
2446   MODULE INITIALIZE OUTPUT.
2447     perform get_correspondense.
2448   ENDMODULE.                 " INITIALIZE  OUTPUT
2449   *&---------------------------------------------------------------------*
2450   *&      Module  get_mattytext  OUTPUT
2451   *&---------------------------------------------------------------------*
2452   *       text
2453   *----------------------------------------------------------------------*
2454   MODULE get_mattytext OUTPUT.
2455     Select single ddtext into g_mattytext from dd07t
2456            where domname    = 'ZMATTY'
2457            and   ddlanguage = sy-langu
2458            and   DOMVALUE_L = zmm_cdhd_st-mtart.
2459     if sy-subrc <> 0.
2460       g_mattytext = ''.
2461     endif.
2462   ***Plant Description
2463     Select single name1 into g_plantdesc from t001w
2464            where werks = zmm_cdhd_st-werks.
2465     if sy-subrc <> 0.
2466       g_plantdesc = ''.
2467     endif.
2468   ***Location Description
2469     Select single bldg into g_locdesc from zlocmst
2470            where locid = zmm_cdhd_st-reqloc.
2471     if sy-subrc <> 0.
2472       g_locdesc = ''.
2473     endif.
2474   ENDMODULE.                 " get_mattytext  OUTPUT
2475
2476   *&---------------------------------------------------------------------*
2477   *&      Module  WRITE_MESSAGES  INPUT
2478   *&---------------------------------------------------------------------*
2479   *       text
2480   *----------------------------------------------------------------------*
2481   MODULE WRITE_MESSAGES OUTPUT.
2482
2483     suppress dialog.
2484
2485     Leave to list-processing and return to screen 0.
2486     IF not g_cditem_itab is initial.
2487
2488       SET PF-STATUS SPACE.
2489     write: / 'Duplicate Records existing in the following requests' color
2490     7
2491     .
2492       Write: / '---------------------------------------------------'.
2493       Write : / 'Ln No ' Color 5,   'Request No. Srno  Desc'  .
2494       loop at g_cditem_itab into g_cditem.
2495         Write: /(5)  g_cditem-mat_fnd color 5.
2496         Write:(11) g_cditem-Reqno.
2497         Write:(4)  g_cditem-srno.
2498         Write:(87) g_cditem-desc_fin.
2499       Endloop.
2500
2501     Else.
2502       if g_long_text_warning <> 'X' and sy-tcode = 'ZCODG'.
2503
2504         wa_message-srno = '000'.
2505         wa_message-msgtype = 'W'.
2506         wa_message-msgcode = 'C'.
2507
2508         wa_message-msgtext = 'Detailed specifications can be entered if required.' .
2509   *      wa_message-msgtext = text-001.
2510
2511         append wa_message to ist_message.
2512         wa_message-srno = '   '.
2513         wa_message-msgtype = 'W'.
2514         wa_message-msgcode = 'C'.
2515
2516         wa_message-msgtext = 'The same will get defaulted in the PR/PO documents ' .
2517   *      wa_message-msgtext = text-002.
2518
2519         append wa_message to ist_message.
2520         clear  g_long_text_warning.
2521
2522       endif.
2523
2524       SET PF-STATUS SPACE.
2525       loop at ist_message into wa_message.
2526         if  wa_message-srno <> '   '.
2527           skip.
2528         endif.
2529         write: wa_message-srno, '|', wa_message-msgtype, '|',
2530     wa_message-msgtext.
2531       endloop.
2532     Endif.
2533   ENDMODULE.                 " WRITE_MESSAGES  INPUT
2534   *&---------------------------------------------------------------------*
2535   *&      Module  TABCTRL110_check  OUTPUT
2536   *&---------------------------------------------------------------------*
2537   *       text
2538   *----------------------------------------------------------------------*
2539   MODULE TABCTRL110_check OUTPUT.
2540
2541   *
2542     if check_code = 'CHECK'.
2543       loop at g_TABCTRL110_itab into g_TABCTRL110_wa.
2544
2545         if g_TABCTRL110_wa-mat_fnd > 0.
2546
2547           wa_message-srno = g_TABCTRL110_wa-srno.
2548           wa_message-msgtype = 'W'.
2549           wa_message-msgcode = 'A'.
2550         wa_message-msgtext = 'There is a list of material codes available as per selection.'.
2551           append wa_message to ist_message.
2552
2553           wa_message-srno = '   '.
2554           wa_message-msgtype = 'W'.
2555           wa_message-msgcode = 'A'.
2556         wa_message-msgtext = 'Do  you  still   require   fresh  material code?'.
2557
2558           append wa_message to ist_message.
2559
2560
2561         if sy-tcode <> 'ZCODG'.
2562
2563           wa_message-srno = g_TABCTRL110_wa-srno.
2564           wa_message-msgtype = 'W'.
2565           wa_message-msgcode = 'B'.
2566           wa_message-msgtext =
2567           'Have you checked the detailed speifications(if any)'.
2568
2569           append wa_message to ist_message.
2570
2571           wa_message-srno = '   '.
2572           wa_message-msgtype = 'W'.
2573           wa_message-msgcode = 'B'.
2574           wa_message-msgtext =
2575           'in the  materials  list  appearing  in  the search help?'.
2576
2577           append wa_message to ist_message.
2578
2579          endif.
2580
2581         endif.
2582
2583         if g_TABCTRL110_wa-dsflag = 'X' and sy-tcode = 'ZCODG'.
2584           wa_message-srno = g_TABCTRL110_wa-srno.
2585           wa_message-msgtype = 'W'.
2586           wa_message-msgcode = 'Z'.
2587           wa_message-msgtext =
2588           'Detail Specification has been maintained for this line item'.
2589
2590           append wa_message to ist_message.
2591         endif.
2592
2593         clear wa_message.
2594       endloop.
2595   *
2596       describe table g_TABCTRL110_itab lines check_lines.
2597
2598       if check_lines > 0.
2599
2600         Call Screen 102 starting at 10 05 ending at 100 15.
2601
2602       else.
2603
2604         message i028(zmm_oth).
2605
2606       endif.
2607
2608       clear : g_TABCTRL110_wa-dsflag,  g_long_text_warning .
2609
2610     endif.
2611
2612   ENDMODULE.                 " TABCTRL110_check  OUTPUT
2613   *
2614   *&---------------------------------------------------------------------*
2615   *&      Module  TABCTRL100_change_col_attr  OUTPUT
2616   *&---------------------------------------------------------------------*
2617   *       text
2618   *----------------------------------------------------------------------*
2619   MODULE TABCTRL100_change_col_attr OUTPUT.
2620
2621     if ZMM_CDHD_ST-MTART = 'ZSTO' OR ZMM_CDHD_ST-MTART = 'ZCAP'.
2622       LOOP AT TABCTRL100-cols INTO cols WHERE index GT 5.
2623         cols-invisible = '1'.
2624         if cols-screen-name = 'WA_SRCHLP-MAKTX'.
2625           cols-vislength = '65'.
2626         Endif.
2627         MODIFY TABCTRL100-cols FROM cols INDEX sy-tabix.
2628       ENDLOOP.
2629     Elseif ZMM_CDHD_ST-MTART = 'ZSPR'.
2630       LOOP AT TABCTRL100-cols INTO cols.
2631         if cols-screen-name = 'WA_SRCHLP-MAKTX'.
2632           cols-vislength = '40'.
2633           MODIFY TABCTRL100-cols FROM cols INDEX sy-tabix.
2634         Endif.
2635       ENDLOOP.
2636     endif.
2637
2638   ENDMODULE.                 " TABCTRL100_change_col_attr  OUTPUT
2639   *&---------------------------------------------------------------------*
2640   *&      Module  STATUS_0102  OUTPUT
2641   *&---------------------------------------------------------------------*
2642   *       text
2643   *----------------------------------------------------------------------*
2644   MODULE STATUS_0102 OUTPUT.
2645   *  SET PF-STATUS SPACE.
2646   *  SET TITLEBAR 'xxx'.
2647
2648   ENDMODULE.                 " STATUS_0102  OUTPUT
2649   *&---------------------------------------------------------------------*
2650   *&      Module  STATUS_0103  OUTPUT
2651   *&---------------------------------------------------------------------*
2652   *       text
2653   *----------------------------------------------------------------------*
2654   MODULE STATUS_0103 OUTPUT.
2655
2656     SET PF-STATUS 'STAT_REL'.
2657
2658   ENDMODULE.                 " STATUS_0103  OUTPUT
2659   *&---------------------------------------------------------------------*
2660   *&      Module  WRITE_CERTI  OUTPUT
2661   *&---------------------------------------------------------------------*
2662   *       text
2663   *----------------------------------------------------------------------*
2664   MODULE WRITE_CERTI OUTPUT.
2665   *
2666     SUPPRESS DIALOG.
2667     SET PF-STATUS 'STAT_REL'.
2668     LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.
2669   *
2670     NEW-PAGE NO-TITLE.
2671     Case g_mode .
2672       When 'REL'.
2673      If ( g_user = 'M' or g_user = 'L' or zmm_cdhd_st-reqcpf = sy-uname )
2674                 .
2675   Write : / '                   Acknowledgement                         '
2676                           Color 3.
2677   Write : / '-----------------------------------------------------------'.
2678      Write : / 'The Material Search has been done using tcode ZMMMATHELP'.
2679   WRite : / 'and MM03. Relevant material code not available. The details'.
2680        write : / 'in the request have been checked and confirmed. Please'.
2681      Write : / 'process the request for generation of new Material Code.'.
2682
2683         Else.
2684           Message i042(zmm_oth).
2685           leave to screen 0.
2686         Endif.
2687
2688       When 'APR' .
2689         If  g_user = 'M'.
2690     Write : / '                   Acknowledgement                       '
2691                                            Color 5.
2692         Write : / '-----------------------------------------------------'.
2693           write: / 'The details in the request have been rechecked and'.
2694          Write : / 'confirmed. Please process the request for generation'.
2695           write: / 'of new Material Code.'.
2696         Else.
2697           message i043(zmm_oth).
2698           leave. "to screen 0.
2699         Endif.
2700      when 'COD'.
2701       IF OKCODE_100 = 'INS_MODI'.
2702        Write : / 'Following Modifiers will be inserted' color 6.
2703        write : /.
2704        if not zmm_modifier-desc1 is initial.
2705           Write : / '1. ',zmm_modifier-desc1.
2706        Endif.
2707        if not zmm_modifier-desc2 is initial.
2708           Write : / '2. ',zmm_modifier-desc2.
2709        Endif.
2710        if not zmm_modifier-desc3 is initial.
2711           Write : / '3. ',zmm_modifier-desc3.
2712        Endif.
2713        if not zmm_modifier-desc4 is initial.
2714           Write : / '4. ',zmm_modifier-desc4.
2715        Endif.
2716
2717       Endif.
2718
2719     Endcase.
2720
2721   ENDMODULE.                 " WRITE_CERTI  OUTPUT
2722   *&---------------------------------------------------------------------*
2723   *&      Module  STATUS_0150  OUTPUT
2724   *&---------------------------------------------------------------------*
2725   *       text
2726   *----------------------------------------------------------------------*
2727   MODULE STATUS_0150 OUTPUT.
2728     SET PF-STATUS 'STATUS150'.
2729   *  SET TITLEBAR 'xxx'.
2730
2731   ENDMODULE.                 " STATUS_0150  OUTPUT
2732   *&---------------------------------------------------------------------*
2733   *&      Module  scr100_sh_attr  OUTPUT
2734   *&---------------------------------------------------------------------*
2735   *       text
2736   *----------------------------------------------------------------------*
2737   MODULE scr100_sh_attr OUTPUT.
2738     case zmm_cdhd_st-mtart.
2739       when 'ZSTO' or 'ZCAP' or 'ZDIS'.
2740         loop at screen.
2741           if screen-group2 = 'SH'.
2742             screen-invisible = 1.
2743             modify screen.
2744           endif.
2745         endloop.
2746     endcase.
2747   ENDMODULE.                 " scr100_sh_attr  OUTPUT
2748   *&---------------------------------------------------------------------*
2749   *&      Module  Set_attrib  OUTPUT
2750   *&---------------------------------------------------------------------*
2751   *       text
2752   *----------------------------------------------------------------------*
2753   MODULE Set_attrib OUTPUT.
2754
2755   ************************************************************************
2756     PERFORM GET_PARNO.
2757     Case G_MODE.
2758
2759       When 'DIS' OR 'DEL' OR 'REL' OR 'APR' .
2760         IF g_ok_code110 = 'PB_AD' AND g_ok_code115 = ''.
2761           g_desc1 = g_tabctrl110_wa-desc1.
2762           g_desc2 = g_tabctrl110_wa-desc2.
2763           g_desc3 = g_tabctrl110_wa-desc3.
2764           g_desc4 = g_tabctrl110_wa-desc4.
2765           IF g_tabctrl110_wa-matgp <> 'XX'.
2766             g_matgp = g_tabctrl110_wa-matgp.
2767           ENDIF.
2768           g_user_desc = g_tabctrl110_wa-user_desc.
2769
2770           concatenate g_desc1 g_desc2
2771                       g_desc3 g_desc4 into g_desc1_4
2772                       separated by space.
2773           condense g_desc1_4.
2774
2775           user_desc_len = 86 - strlen( g_desc1_4 ).
2776
2777           Loop at screen.
2778             If screen-group1 = 'G1'.
2779               screen-input = 0.
2780               modify screen.
2781             Endif.
2782             IF screen-name = 'G_USER_DESC' and user_desc_len > 0.
2783               screen-length = user_desc_len.
2784               modify screen.
2785             ENDIF.
2786           Endloop.
2787         ENDIF.
2788       WHEN 'CRE' OR 'CHA' OR 'COD'.
2789         If sy-tcode <> 'ZCODG'.
2790           concatenate g_desc1 g_desc2 g_desc3 g_desc4 into g_desc1_4
2791                                                separated by space.
2792           condense g_desc1_4.
2793           user_desc_len = 86 - strlen( g_desc1_4 ).
2794         Endif.
2795         Case 'OTHER'.
2796           when g_tabctrl110_wa-desc1.
2797             if  g_tabctrl110_wa-srno = ''. "New line
2798               If sy-ucomm <> ''.
2799                 g_desc1 = ''.
2800               Endif.
2801               move  'X'  to g_tabctrl110_wa-oth1.
2802               move  'X'  to g_tabctrl110_wa-oth2.
2803               move  'X'  to g_tabctrl110_wa-oth3.
2804               move  'X'  to g_tabctrl110_wa-oth4.
2805             Else.
2806               read table g_tabctrl110_itab into
2807                      g_tabctrl110_wa index g_curr_line_110.
2808               g_desc1 = g_tabctrl110_wa-desc1. "change existing line
2809               g_desc2 = g_tabctrl110_wa-desc2.
2810               g_desc3 = g_tabctrl110_wa-desc3.
2811               g_desc4 = g_tabctrl110_wa-desc4.
2812               G_USER_DESc = g_tabctrl110_wa-user_desc.
2813               g_matgp = g_tabctrl110_wa-matgp.
2814               move  'X'  to g_tabctrl110_wa-oth1.
2815             Endif.
2816             If g_matgp = 'XX'.
2817               g_matgp = ''.
2818             Endif.
2819             Loop at screen.
2820               If screen-name = 'G_USER_DESC'.
2821                 screen-input = 0.
2822                 screen-length = 40.
2823                 modify screen.
2824               Endif.
2825               If g_parno = 3 and screen-name = 'G_DESC4'.
2826                 screen-input = 0.
2827                 modify screen.
2828               Endif.
2829               If g_parno = 2 and ( screen-name = 'G_DESC3' or
2830                                    screen-name = 'G_DESC4' ).
2831                 screen-input = 0.
2832                 modify screen.
2833               Endif.
2834
2835               If sy-tcode = 'ZCODG' and screen-name = 'ADNL_DESC'.
2836                 screen-input = 0.
2837                 modify screen.
2838               Endif.
2839
2840               IF screen-name = 'G_DESC3' or screen-name = 'G_DESC4'.
2841                 screen-required = 0.
2842                 modify screen.
2843               Endif.
2844             Endloop.
2845
2846           when g_tabctrl110_wa-desc2.
2847             If g_tabctrl110_wa-srno = ''. "New line
2848               g_desc1 = g_tabctrl110_wa-desc1.
2849               g_desc2 = ''.
2850               g_matgp = g_tabctrl110_wa-matgp.
2851               move  'X'  to g_tabctrl110_wa-oth2.
2852               move  'X'  to g_tabctrl110_wa-oth3.
2853               move  'X'  to g_tabctrl110_wa-oth4.
2854             Else.                                  "existing line
2855               read table g_tabctrl110_itab into
2856                 g_tabctrl110_wa index g_curr_line_110.
2857               g_desc1 = g_tabctrl110_wa-desc1.
2858               g_desc2 = g_tabctrl110_wa-desc2.
2859               If g_desc2 = 'OTHER'.
2860                 g_desc2 = ''.
2861               Endif.
2862               IF g_parno = 2.  " GCU 27-10-2005
2863                 g_desc3 = ''.
2864                 g_desc4 = ''.
2865               Elseif g_parno = 3.
2866                 g_desc3 = g_tabctrl110_wa-desc3.
2867                 g_desc4 = ''.
2868               Else.
2869                 g_desc3 = g_tabctrl110_wa-desc3.
2870                 g_desc4 = g_tabctrl110_wa-desc4.
2871               Endif.
2872               G_USER_DESc = g_tabctrl110_wa-user_desc.
2873               g_matgp = g_tabctrl110_wa-matgp.
2874               move  'X'  to g_tabctrl110_wa-oth2.
2875             Endif.
2876             Loop at screen.
2877               If screen-name = 'G_DESC1' or
2878                  screen-name = 'G_USER_DESC' or
2879                  screen-name = 'G_MATGP'.
2880                 screen-input = 0.
2881                 modify screen.
2882               Endif.
2883               If g_parno = 3 and screen-name = 'G_DESC4'.
2884                 screen-input = 0.
2885                 modify screen.
2886               Endif.
2887               If g_parno = 2 and ( screen-name = 'G_DESC3' or
2888                                    screen-name = 'G_DESC4' ).
2889                 screen-input = 0.
2890                 modify screen.
2891               Endif.
2892               If sy-tcode = 'ZCODG' and screen-name = 'ADNL_DESC'.
2893                 screen-input = 0.
2894                 modify screen.
2895               Endif.
2896
2897             Endloop.
2898
2899           when g_tabctrl110_wa-desc3.
2900             If g_tabctrl110_wa-srno = ''. "New line
2901               g_desc1 = g_tabctrl110_wa-desc1.
2902               g_desc2 = g_tabctrl110_wa-desc2.
2903               If sy-ucomm <> ''. "Enter Pressed
2904                 g_desc3 = ''.
2905               Endif.
2906               g_matgp = g_tabctrl110_wa-matgp.
2907               move  'X'  to g_tabctrl110_wa-oth3.
2908               move  'X'  to g_tabctrl110_wa-oth4.
2909             Else.
2910               read table g_tabctrl110_itab into
2911                        g_tabctrl110_wa index g_curr_line_110.
2912               g_desc1 = g_tabctrl110_wa-desc1.
2913               g_desc2 = g_tabctrl110_wa-desc2.
2914               g_desc3 = g_tabctrl110_wa-desc3.
2915               if g_desc3 = 'OTHER'.
2916                 g_desc3 = ''.
2917               Endif.
2918               IF g_parno = 2.
2919                 g_desc3 = ''.
2920                 g_desc4 = ''.
2921               ELSEIF g_parno = 3.   " GCU 27-10-2005
2922                 g_desc3 = g_tabctrl110_wa-desc3.
2923                 g_desc4 = ''.
2924               Else.
2925                 g_desc4 = g_tabctrl110_wa-desc4.
2926               Endif.
2927
2928               G_USER_DESc = g_tabctrl110_wa-user_desc.
2929               g_matgp = g_tabctrl110_wa-matgp.
2930               move  'X'  to g_tabctrl110_wa-oth3.
2931             Endif.
2932
2933             Loop at screen.
2934               If screen-name = 'G_DESC1'     or
2935                  screen-name = 'G_DESC2'     or
2936                  screen-name = 'G_USER_DESC' or
2937                  screen-name = 'G_MATGP'.
2938                 screen-input = 0.
2939                 modify screen.
2940               Endif.
2941               If g_parno = 3 and screen-name = 'G_DESC4'.
2942                 screen-input = 0.
2943                 modify screen.
2944               Endif.
2945               If g_parno = 2 and ( screen-name = 'G_DESC3' or
2946                                    screen-name = 'G_DESC4' ).
2947
2948                 screen-input = 0.
2949                 modify screen.
2950               Endif.
2951               If sy-tcode = 'ZCODG' and screen-name = 'ADNL_DESC'.
2952                 screen-input = 0.
2953                 modify screen.
2954               Endif.
2955
2956             Endloop.
2957
2958           when g_tabctrl110_wa-desc4.
2959             If g_tabctrl110_wa-srno = ''. "New line
2960               g_desc1 = g_tabctrl110_wa-desc1.
2961               g_desc2 = g_tabctrl110_wa-desc2.
2962               g_desc3 = g_tabctrl110_wa-desc3.
2963               g_desc4 = ''.
2964               g_matgp = g_tabctrl110_wa-matgp.
2965               move  'X'  to g_tabctrl110_wa-oth4.
2966             Else.
2967               read table g_tabctrl110_itab into
2968                        g_tabctrl110_wa index g_curr_line_110.
2969               g_desc1 = g_tabctrl110_wa-desc1.
2970               g_desc2 = g_tabctrl110_wa-desc2.
2971               g_desc3 = g_tabctrl110_wa-desc3.
2972               g_desc4 = g_tabctrl110_wa-desc4.
2973               if g_desc4 = 'OTHER'.
2974                 g_desc4 = ''.
2975               Endif.
2976
2977               G_USER_DESc = g_tabctrl110_wa-user_desc.
2978               g_matgp = g_tabctrl110_wa-matgp.
2979               move  'X'  to g_tabctrl110_wa-oth4.
2980             Endif.
2981
2982             loop at screen.
2983               If screen-name = 'G_DESC1' or
2984                  screen-name = 'G_DESC2' or
2985                  screen-name = 'G_DESC3' or
2986                  screen-name = 'G_MATGP' or
2987                  screen-name = 'G_USER_DESC'.
2988                 screen-input = 0.
2989                 modify screen.
2990               Endif.
2991               If sy-tcode = 'ZCODG' and screen-name = 'ADNL_DESC'.
2992                 screen-input = 0.
2993                 modify screen.
2994               Endif.
2995
2996             Endloop.
2997
2998         Endcase.
2999
3000         If g_ok_code115 = 'A_DESC'.
3001           Perform set_addnl_desc.
3002         Elseif g_ok_code115 = 'OK115' and g_ok_code110 = 'PB_AD' and
3003                g_spell_ans = 'N'.
3004           Perform set_addnl_desc.
3005
3006         Elseif g_ok_code115 = 'OK115' and g_spell_ans = 'N'.
3007           Perform other_sectime.   "+
3008         Elseif  g_ok_code115 = ''.
3009           Perform other_sectime.   "+
3010         Elseif g_ok_code115 = 'OK115' and g_len_ex87 = 'X'.
3011           g_len_ex87 = ''.
3012           Perform other_sectime.   "+
3013
3014         Endif.
3015
3016         Case g_ok_code115.
3017           When 'A_DESC'.
3018             loop at screen.
3019               if screen-name = 'G_USER_DESC' AND USER_DESC_LEN > 0..
3020                 screen-length = user_desc_len.
3021                 screen-input = 1.
3022                 modify screen.
3023               endif.
3024             Endloop.
3025           When 'CANC' or 'RW'.
3026             IF g_spell_ans = 'N'.
3027             Endif.
3028         ENDCASE.
3029
3030         IF g_ok_code110 = 'PB_AD' AND g_ok_code115 = ''.
3031           g_desc1 = g_tabctrl110_wa-desc1.
3032           g_desc2 = g_tabctrl110_wa-desc2.
3033           g_desc3 = g_tabctrl110_wa-desc3.
3034           g_desc4 = g_tabctrl110_wa-desc4.
3035           g_matgp = g_tabctrl110_wa-matgp.
3036           IF G_screen115_1st is initial.
3037             g_user_desc = g_tabctrl110_wa-user_desc.
3038             G_screen115_1st = 'X'.
3039           ENDIF.
3040           concatenate g_desc1 g_desc2
3041                       g_desc3 g_desc4 into g_desc1_4
3042                       separated by space.
3043           condense g_desc1_4.
3044           user_desc_len = 86 - strlen( g_desc1_4 ).
3045           loop at screen.
3046             if screen-name = 'G_DESC1' or
3047                screen-name = 'G_DESC2' or
3048                screen-name = 'G_DESC3' or
3049                screen-name = 'G_DESC4' or
3050                screen-name = 'G_MATGP'.
3051               screen-input  = 0.
3052               modify screen.
3053             elseif screen-name = 'G_USER_DESC' AND USER_DESC_LEN > 0 .
3054               screen-length = user_desc_len.
3055               screen-input  = 1.
3056               modify screen.
3057             elseif screen-name = 'G_USER_DESC' AND USER_DESC_LEN <= 0 .
3058               screen-input  = 0.
3059             endif.
3060           endloop.
3061         ENDIF.
3062     Endcase.
3063
3064   ENDMODULE.                 " Set_attrib  OUTPUT
3065
3066   *&---------------------------------------------------------------------*
3067   *&      Module  get_coddesc  OUTPUT
3068   *&---------------------------------------------------------------------*
3069   *       text
3070   *----------------------------------------------------------------------*
3071   MODULE get_coddesc OUTPUT.
3072     if not zmm_cditem-cap_code is initial.
3073       SELECT MAKTX INTO ZMM_CDITEM-CAP_NAME FROM MAKT UP TO 1 ROWS
3074    WHERE MATNR = ZMM_CDITEM-CAP_CODE
3075    ORDER BY PRIMARY KEY .
3076    ENDSELECT.
3077       if sy-subrc <> 0.
3078   *
3079         zmm_cditem-cap_name = ''.
3080       Endif.
3081     Endif.
3082   ENDMODULE.                 " get_coddesc  OUTPUT
3083   *&---------------------------------------------------------------------*
3084   *&      Module  TABCTRL120_check  OUTPUT
3085   *&---------------------------------------------------------------------*
3086   *       text
3087   *----------------------------------------------------------------------*
3088   MODULE TABCTRL120_check OUTPUT.
3089     data : l_Manuf_ty type lfa1-J_1KFTBUS.
3090     clear g_mat_fnd.
3091     if check_code = 'CHECK'.
3092       loop at g_TABLCTRL120_itab into g_TABLCTRL120_wa.
3093   *
3094         select single J_1KFTBUS from lfa1 into l_manuf_ty where lifnr =
3095             g_TABLCTRL120_wa-manu.
3096         if sy-subrc = 0 and l_Manuf_ty <> 'OEM'.
3097           wa_message-srno = g_TABLCTRL120_wa-srno .
3098           wa_message-msgtype = 'W'.
3099           wa_message-msgcode = 'A'.
3100           concatenate 'Vendor' g_TABLCTRL120_wa-manu
3101           'Not an OEM' into wa_message-msgtext separated by space.
3102           append wa_message to ist_message.
3103         Endif.
3104   *
3105         if g_TABLCTRL120_wa-mat_fnd > 0.
3106
3107           wa_message-srno = g_TABLCTRL120_wa-srno.
3108           wa_message-msgtype = 'W'.
3109           wa_message-msgcode = 'A'.
3110         wa_message-msgtext = 'There is a list of material codes available as per selection.'.
3111           append wa_message to ist_message.
3112
3113           wa_message-srno = '   '.
3114           wa_message-msgtype = 'W'.
3115           wa_message-msgcode = 'A'.
3116         wa_message-msgtext = 'Do  you  still   require   fresh  material code?'.
3117
3118           append wa_message to ist_message.
3119
3120         if sy-tcode <> 'ZCODG'.
3121
3122           wa_message-srno = g_TABLCTRL120_wa-srno.
3123           wa_message-msgtype = 'W'.
3124           wa_message-msgcode = 'B'.
3125           wa_message-msgtext =
3126           'Have you checked the detailed speifications(if any)'.
3127
3128           append wa_message to ist_message.
3129
3130           wa_message-srno = '   '.
3131           wa_message-msgtype = 'W'.
3132           wa_message-msgcode = 'B'.
3133           wa_message-msgtext =
3134           'in the  materials  list  appearing  in  the search help?'.
3135
3136           append wa_message to ist_message.
3137
3138          endif.
3139
3140         endif.
3141
3142         if g_TABLCTRL120_wa-dsflag = 'X' and sy-tcode = 'ZCODG'.
3143           wa_message-srno = g_TABLCTRL120_wa-srno.
3144           wa_message-msgtype = 'W'.
3145           wa_message-msgcode = 'Z'.
3146           wa_message-msgtext =
3147           'Detail Specification has been maintained for this line item'.
3148
3149           append wa_message to ist_message.
3150         endif.
3151
3152         clear wa_message.
3153       endloop.
3154
3155       describe table g_TABLCTRL120_itab lines check_lines.
3156
3157       if check_lines > 0.
3158
3159         Call Screen 102 starting at 10 05 ending at 100 15.
3160
3161       else.
3162
3163         message i028(zmm_oth).
3164
3165       endif.
3166
3167       clear : g_TABLCTRL120_wa-dsflag,  g_long_text_warning .
3168
3169     endif.
3170
3171   ENDMODULE.                 " TABCTRL120_check  OUTPUT
3172   *&---------------------------------------------------------------------*
3173   *&      Module  STATUS_0116  OUTPUT
3174   *&---------------------------------------------------------------------*
3175   *       text
3176   *----------------------------------------------------------------------*
3177   MODULE STATUS_0116 OUTPUT.
3178     SET PF-STATUS 'STAT115'.
3179   ENDMODULE.                 " STATUS_0116  OUTPUT
3180   *&---------------------------------------------------------------------*
3181   *&      Module  loopat_matty_data  OUTPUT
3182   *&---------------------------------------------------------------------*
3183   *       text
3184   *----------------------------------------------------------------------*
3185   *&---------------------------------------------------------------------*
3186   *&      Module  get_srchitab  OUTPUT
3187   *&---------------------------------------------------------------------*
3188   *       text
3189   *----------------------------------------------------------------------*
3190   MODULE get_srchitab OUTPUT.
3191     IF zmm_cdhd_st-mtart = 'ZSPR'.
3192       If NOT g_fst_srchlp IS INITIAL.
3193         IF g_sh_capeqt  = '' and
3194            g_sh_mfr     = '' and
3195            g_sh_mdlno   = ''.
3196           ist_srchlp = ist_srchlp_cpo.
3197         ELSE.
3198           ist_srchlp = ist_srchlp_cp.
3199         ENDIF.
3200       Else.
3201         append lines of ist_srchlp to ist_srchlp_cpo.
3202         If FIELD1 = 'ZMM_CDITEM-PARTNO' .
3203           g_fst_srchlp = 'X'.
3204         ENDIF.
3205       Endif.
3206   *
3207     ENDIF.
3208   ENDMODULE.                 " get_srchitab  OUTPUT
3209   *&---------------------------------------------------------------------*
3210   *&      Module  Modelno_LIST  OUTPUT
3211   *&---------------------------------------------------------------------*
3212   *       text
3213   *----------------------------------------------------------------------*
3214   MODULE Modelno_LIST OUTPUT.
3215     SUPPRESS DIALOG.
3216     LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.
3217     SET PF-STATUS SPACE.
3218     NEW-PAGE NO-TITLE.
3219
3220     if ZMM_CDHD_ST-MTART = 'ZSTO'.
3221       WRITE : / 'Select group :' .
3222       ULINE.
3223       Loop at ist_modifier_check_list .
3224         WRITE: / ist_modifier_check_list-matgrp,
3225                   ist_modifier_check_list-desc1 COLOR COL_POSITIVE
3226   INTENSIFIED OFF .  "#EC CI_NOORDER
3227         HIDE ist_modifier_check_list-matgrp.
3228       Endloop.
3229     else.
3230       WRITE : / 'List of Models similar to :' , ist_sval_org COLOR
3231     col_total.
3232       ULINE.
3233       Loop at ist_mdl.
3234         WRITE: / ist_mdl-mdlno COLOR COL_POSITIVE INTENSIFIED OFF.  "#EC CI_FLDEXT_OK[2215424]
3235         HIDE ist_mdl-mdlno.
3236       Endloop.
3237     endif.
3238
3239   ENDMODULE.                 " Modelno_LIST  OUTPUT
3240   *&---------------------------------------------------------------------*
3241   *&      Module  techauth_visiblity  OUTPUT
3242   *&---------------------------------------------------------------------*
3243   *       text
3244   *----------------------------------------------------------------------*
3245   MODULE techauth_visiblity OUTPUT.
3246     clear g_techapr_visible.
3247     read table g_TABCTRL110_itab into g_TABCTRL110_wa with key oth1 = 'X'.
3248     if sy-subrc = 0.
3249       g_techapr_visible = 'Y'.
3250     else.
3251       g_techapr_visible = ''.
3252     endif.
3253
3254   ENDMODULE.                 " techauth_visiblity  OUTPUT
3255   *&---------------------------------------------------------------------*
3256   *&      Module  set_cursor_line  OUTPUT
3257   *&---------------------------------------------------------------------*
3258   *       text
3259   *----------------------------------------------------------------------*
3260   MODULE set_cursor_line OUTPUT.
3261     data : l_curr_row type sy-stepl.
3262     data : l_old_top_line type sy-stepl.
3263     data : g_cursor_line_in_tc like sy-loopc.
3264
3265     If g_mode = 'CRE' or g_mode = 'CHA' or g_mode = 'DIS' or g_mode =
3266           'APR' or g_mode = 'COD' or g_mode = 'REL'.
3267   .
3268       case zmm_cdhd_st-mtart.
3269         when 'ZCAP'.
3270   *        If g_mode = 'CRE' and g_curfield = 'ZMM_CDHD_ST-TEL'.
3271           If g_curfield = 'ZMM_CDHD_ST-TEL'.
3272             SET CURSOR FIELD 'ZMM_CDITEM-DESC_FIN' LINE 1.
3273           Else.
3274              g_cursor_line_in_tc = G_CURR_LINE_130 -
3275                                    Tablctrl130-top_line + 1.
3276              SET CURSOR FIELD g_curfield130 LINE g_cursor_line_in_tc.
3277
3278   *          SET CURSOR FIELD g_curfield130 LINE G_CURR_LINE_130 .
3279           Endif.
3280         When 'ZSPR'.
3281           If g_mode = 'CRE' and g_curfield = 'ZMM_CDHD_ST-TEL'.
3282             SET CURSOR FIELD 'ZMM_CDITEM-PARTNO' LINE 1.
3283           Else.
3284              g_cursor_line_in_tc = G_CURR_LINE_120 -
3285                                    Tablctrl120-top_line + 1.
3286
3287              SET CURSOR FIELD g_curfield120 LINE g_cursor_line_in_tc.
3288
3289           Endif.
3290         When 'ZSTO'.
3291           clear g_parno.
3292           l_curr_row = g_Current_line.
3293           clear g_parno.
3294   *        l_curr_row = G_CURR_LINE_110 - TABCTRL110-TOP_LINE + 1 .
3295   *       Else.
3296   *        l_curr_row = G_CURR_LINE_110.
3297   *       ENDIF.
3298           If sy-tcode = 'ZCODG' or g_mode = 'DIS' or g_mode = 'REL' or
3299              g_mode = 'APR'.
3300              g_cursor_line_in_tc = G_CURR_LINE_110 -
3301                                    Tabctrl110-top_line + 1.
3302
3303              SET CURSOR FIELD g_curfield110 LINE g_cursor_line_in_tc.
3304              check 1 = 2.
3305           Endif.
3306           If g_curfield = 'ZMM_CDHD_ST-TEL'.
3307             SET CURSOR FIELD 'ZMM_CDITEM-DESC1' LINE 1.
3308           Else.
3309
3310             If  tabctrl110-top_line <> l_old_top_line .
3311               SET CURSOR FIELD 'ZMM_CDITEM-DESC1' LINE l_curr_row.
3312               l_old_top_line = tabctrl110-top_line.
3313               check 1 = 2.
3314             Endif.
3315             IF g_curfield110 = 'ZMM_CDITEM-DESC1'.
3316               Perform get_parno1.
3317               If g_parno = '1'.
3318                 SET CURSOR FIELD 'ZMM_CDITEM-UOM' LINE l_curr_row.
3319               Else.
3320                 SET CURSOR FIELD 'ZMM_CDITEM-DESC2' LINE l_curr_row.
3321               Endif.
3322
3323   *           SET CURSOR FIELD 'ZMM_CDITEM-DESC2' LINE G_CURR_LINE_110.
3324             Elseif g_curfield110 = 'ZMM_CDITEM-DESC2'.
3325               Perform get_parno1.
3326               If g_parno = '2'.
3327                 If ZMM_CDITEM-UOM is initial.
3328                   SET CURSOR FIELD 'ZMM_CDITEM-UOM' LINE l_curr_row.
3329                 Else.
3330                   SET CURSOR FIELD 'ZMM_CDITEM-DESC2' LINE l_curr_row.
3331                 Endif.
3332               Else.
3333                 SET CURSOR FIELD 'ZMM_CDITEM-DESC3' LINE l_curr_row.
3334               Endif.
3335             Elseif g_curfield110 = 'ZMM_CDITEM-DESC3'.
3336               Perform get_parno1.
3337               If g_parno = '3'.
3338                 If ZMM_CDITEM-UOM is initial.
3339                   SET CURSOR FIELD 'ZMM_CDITEM-UOM' LINE l_curr_row.
3340                 Else.
3341                   SET CURSOR FIELD 'ZMM_CDITEM-DESC3' LINE l_curr_row.
3342                 Endif.
3343               Else.
3344                 SET CURSOR FIELD 'ZMM_CDITEM-DESC4' LINE l_curr_row.
3345               Endif.
3346             Elseif g_curfield110 = 'ZMM_CDITEM-DESC4'.
3347               If ZMM_CDITEM-UOM is initial.
3348                 SET CURSOR FIELD 'ZMM_CDITEM-UOM' LINE l_curr_row.
3349               Else.
3350                 SET CURSOR FIELD 'ZMM_CDITEM-DESC4' LINE l_curr_row.
3351               Endif.
3352
3353             Elseif g_curfield110 = 'ZMM_CDITEM-UOM'.
3354   *           TABCTRL110-TOP_LINE = G_CURR_LINE_110 .
3355   *           TABCTRL110-CURRENT_LINE = G_CURR_LINE_110 + 1.
3356   *           G_CURR_LINE_110 = G_CURR_LINE_110 + 1.
3357
3358               SET CURSOR FIELD 'ZMM_CDITEM-DESC1' LINE l_curr_row.
3359   *        Elseif g_curfield110 = 'ZMM_CDITEM-ST_COND'  .
3360   *           G_CURR_LINE_110 = G_CURR_LINE_110 + 1.
3361   *           SET CURSOR FIELD 'ZMM_CDITEM-DESC1' LINE G_CURR_LINE_110.
3362             Endif.
3363           Endif.
3364           l_old_top_line = tabctrl110-top_line.
3365
3366       Endcase.
3367     Endif.
3368   *
3369   ENDMODULE.                 " set_cursor_line  OUTPUT
3370   *&---------------------------------------------------------------------*
3371   *&      Module  TABLCTRL130_check  OUTPUT
3372   *&---------------------------------------------------------------------*
3373   *       text
3374   *----------------------------------------------------------------------*
3375   MODULE TABLCTRL130_check OUTPUT.
3376
3377     if check_code = 'CHECK'.
3378       loop at g_TABLCTRL130_itab into g_TABLCTRL130_wa.
3379
3380         if g_TABLCTRL130_wa-mat_fnd > 0.
3381
3382           wa_message-srno = g_TABLCTRL130_wa-srno.
3383           wa_message-msgtype = 'W'.
3384           wa_message-msgcode = 'A'.
3385         wa_message-msgtext = 'There is a list of material codes available as per selection.'.
3386           append wa_message to ist_message.
3387
3388           wa_message-srno = '   '.
3389           wa_message-msgtype = 'W'.
3390           wa_message-msgcode = 'A'.
3391         wa_message-msgtext = 'Do  you  still   require   fresh  material code?'.
3392
3393           append wa_message to ist_message.
3394
3395        if sy-tcode <> 'ZCODG'.
3396
3397           wa_message-srno = g_TABLCTRL130_wa-srno.
3398           wa_message-msgtype = 'W'.
3399           wa_message-msgcode = 'B'.
3400           wa_message-msgtext =
3401           'Have you checked the detailed speifications(if any)'.
3402
3403           append wa_message to ist_message.
3404
3405           wa_message-srno = '   '.
3406           wa_message-msgtype = 'W'.
3407           wa_message-msgcode = 'B'.
3408           wa_message-msgtext =
3409           'in the  materials  list  appearing  in  the search help?'.
3410
3411           append wa_message to ist_message.
3412
3413         endif.
3414
3415         endif.
3416
3417         if g_TABLCTRL130_wa-dsflag = 'X' and sy-tcode = 'ZCODG'.
3418           wa_message-srno = g_TABLCTRL130_wa-srno.
3419           wa_message-msgtype = 'W'.
3420           wa_message-msgcode = 'Z'.
3421           wa_message-msgtext =
3422           'Detail Specification has been maintained for this line item'.
3423
3424           append wa_message to ist_message.
3425         endif.
3426
3427         clear wa_message.
3428       endloop.
3429   *
3430       describe table g_TABLCTRL130_itab lines check_lines.
3431
3432       if check_lines > 0.
3433
3434         Call Screen 102 starting at 10 05 ending at 100 15.
3435
3436       else.
3437
3438         message i028(zmm_oth).
3439
3440       endif.
3441
3442       clear : g_TABLCTRL130_wa-dsflag,  g_long_text_warning .
3443
3444     endif.
3445
3446
3447   ENDMODULE.                 " TABLCTRL130_check  OUTPUT
3448   *&---------------------------------------------------------------------*
3449   *&      Module  change_restrict  OUTPUT
3450   *&---------------------------------------------------------------------*
3451   *       text
3452   *----------------------------------------------------------------------*
3453   *MODULE change_restrict OUTPUT.
3454   Form Change_restrict.
3455   *
3456     select single reqcpf werks from zmm_cdhd into (zmm_Cdhd_st-reqcpf ,
3457         zmm_Cdhd_st-werks) where reqno = zmm_cdhd_st-reqno.
3458
3459     If ( g_mode = 'CHA' or g_mode ='REL' or g_mode = 'APR' )
3460          and zmm_cdhd_st-REQCPF <> ''
3461   .
3462       If sy-uname <> zmm_cdhd_st-REQCPF.
3463         If  g_user = '' and ( g_mode = 'CHA' or g_mode = 'REL' ).
3464           message i020(zmm_oth).
3465           Perform Clear_var.
3466           leave to screen 100.
3467         Elseif g_user = 'M'.
3468           AUTHORITY-CHECK OBJECT 'M_BANF_WRK'
3469                      ID 'WERKS' Field zmm_cdhd_st-werks
3470                      ID 'ACTVT'  FIELD '01'.
3471           If sy-subrc <> 0.
3472             g_change_auth = 'X'.
3473             message i061(zmm_oth) with zmm_cdhd_st-werks.
3474             Perform Clear_var.
3475   *
3476             leave to screen 100.
3477           Endif.
3478
3479         Endif.
3480       Elseif g_user = '' and g_mode = 'APR'.
3481         message i043(zmm_oth).
3482         Perform Clear_var.
3483         leave to screen 100.
3484       Endif.
3485     Endif.
3486   Endform.
3487   *ENDMODULE.                 " change_restrict  OUTPUT
3488   *&---------------------------------------------------------------------*
3489   *&      Module  set_multi_sel_line  OUTPUT
3490   *&---------------------------------------------------------------------*
3491   *       text
3492   *----------------------------------------------------------------------*
3493   MODULE set_multi_sel_line OUTPUT.
3494     If sy-tcode = 'ZCODG'.
3495       TABLCTRL120-LINE_SEL_MODE = 2.
3496     Endif.
3497   ENDMODULE.                 " set_multi_sel_line  OUTPUT
3498   *&---------------------------------------------------------------------*
3499   *&      Module  Status_104  OUTPUT
3500   *&---------------------------------------------------------------------*
3501   *       text
3502   *----------------------------------------------------------------------*
3503   MODULE Status_104 OUTPUT.
3504   If okcode_100 = 'INS_MODI'.
3505      set pf-status '104'.
3506   Endif.
3507   ENDMODULE.                 " Status_104  OUTPUT
3508   *&---------------------------------------------------------------------*
3509   *&      Module  tabctrl110_attr  OUTPUT
3510   *&---------------------------------------------------------------------*
3511   *       text
3512   *----------------------------------------------------------------------*
3513   MODULE tabctrl110_attr OUTPUT.
3514    if ZMM_CDHD_ST-MTART = 'ZSTO' and sy-tcode <> 'ZCODG'.
3515       LOOP AT TABCTRL110-cols INTO cols110 WHERE index EQ 17.
3516         cols110-invisible = '1'.
3517         MODIFY TABCTRL110-cols FROM cols110 INDEX sy-tabix.
3518       ENDLOOP.
3519     endif.
3520   ENDMODULE.                 " tabctrl110_attr  OUTPUT
3521   *&---------------------------------------------------------------------*
3522   *&      Module  POP_MESSAGE  OUTPUT
3523   *&---------------------------------------------------------------------*
3524   *       text
3525   *----------------------------------------------------------------------*
3526   MODULE POP_MESSAGE OUTPUT.
3527    CALL FUNCTION 'ZMM_POPUP_IMAC_MESSAGE'
3528         EXPORTING
3529           arbgb             = 'ZMM'
3530           msgnr             = '861'
3531           msgty             = 'I'
3532         EXCEPTIONS
3533           user_cancel       = 1
3534           message_not_found = 2
3535           OTHERS            = 3.
3536       IF sy-subrc <> 0.
3537   * MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
3538   *         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
3539       ENDIF.
3540
3541       CALL SCREEN '0100'.
3542
3543   ENDMODULE.                 " POP_MESSAGE  OUTPUT
*--- End of MZMMCODREQO01 - 3543 lines ---

----------------------------------------------------------------------------------------------------
Include          MZMMCODREQI01                             Level 1    Page 4
Object           SAPMZMMCODREQ                             Lines 2834
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:59
----------------------------------------------------------------------------------------------------
1      ************************************************************************
2      *  Date            Transport      USERID        Description
3      * 30/09/2008      <RD1K960036>    SAB_SUMODH
4      *
5      *1) Obsolete FM POPUP_TO_CONFIRM_STEP Replaced With 'POPUP_TO_CONFIRM'.
6      *
7      ************************************************************************
8      ***INCLUDE MZMMCODREQI01 .
9      *&spwizard: input modul for tc 'TABCTRL100'. do not change this line!
10     *&spwizard: mark table
11     MODULE TABCTRL100_MARK INPUT.
12       DATA: G_TABCTRL100_WA2 LIKE LINE OF IST_SRCHLP.
13       IF TABCTRL100-LINE_SEL_MODE = 1.
14         LOOP AT IST_SRCHLP INTO G_TABCTRL100_WA2
15           WHERE MARK = 'X'.
16           G_TABCTRL100_WA2-MARK = ''.
17           MODIFY IST_SRCHLP
18             FROM G_TABCTRL100_WA2
19             TRANSPORTING MARK.
20         ENDLOOP.
21       ENDIF.
22       MODIFY IST_SRCHLP
23         FROM WA_SRCHLP
24         INDEX TABCTRL100-CURRENT_LINE
25         TRANSPORTING MARK.
26     ENDMODULE.                    "TABCTRL100_mark INPUT
27     *&spwizard: input module for tc 'TABCTRL100'. do not change this line!
28     *&spwizard: process user command
29     MODULE TABCTRL100_USER_COMMAND INPUT.
30     *  OKCODE_100 = sy-ucomm.   <<SBD - 080905>>
31       GET CURSOR FIELD G_CURFIELD.
32       IF G_CURFIELD = 'ZMM_CDHD_ST-MTART' .
33         CASE ZMM_CDHD_ST-MTART.
34           WHEN 'ZCAP'.
35             DYNNR = '0130'.
36           WHEN 'ZSPR'.
37             DYNNR = '0120'.
38           WHEN 'ZSTO'.
39             DYNNR = '0110'.
40           WHEN 'ZDIS'.
41             DYNNR = '0140'.
42           WHEN OTHERS.
43             DYNNR = '0101'.
44         ENDCASE.
45       ENDIF.
46     ****Calling transaction MK03 for vendor.
47       READ TABLE IST_SRCHLP INTO WA_SRCHLPMK03 INDEX G_CURR_LINE_100.
48     *  G_MFRNR  = WA_SRCHLPMK03-MFRNR.
49       G_CAPCODE = WA_SRCHLPMK03-ZZCAP_CODE.
50     *  IF G_CURFIELD = 'WA_SRCHLP-MFRNR'. "and g_cursor_line = sy-stepl.
51     *    IF NOT G_MFRNR IS INITIAL.
52     *      SET PARAMETER ID 'LIF' FIELD G_MFRNR.
53     *      CALL TRANSACTION 'MK03' AND SKIP FIRST SCREEN.
54     *    ENDIF.
55     *  ENDIF.
56
57     ****Caliing transaction MM03 for capital code
58       IF G_CURFIELD = 'WA_SRCHLP-ZZCAP_CODE'. "and g_cursor_line = sy-stepl. "CHANGE BY YOGESH
59         IF NOT G_CAPCODE IS INITIAL.
60           SET PARAMETER ID 'MAT' FIELD WA_SRCHLPMK03-ZZCAP_CODE.
61           CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
62         ENDIF.
63       ENDIF.
64
65     ENDMODULE.                    "TABCTRL100_user_command INPUT
66
67     *    &spwizard: modify table
68     MODULE TABCTRL110_MODIFY INPUT.
69       DATA : G_OTH_LEVEL.
70       G_OK_CODE110 = SY-UCOMM.
71       CLEAR G_FIELD.
72     *{   INSERT         OCPK900087                                        1
73
74     *}   INSERT
75
76       IF ZMM_CDITEM-OTH1 = 'X' OR
77          ZMM_CDITEM-OTH2 = 'X' OR
78          ZMM_CDITEM-OTH3 = 'X' OR
79          ZMM_CDITEM-OTH4 = 'X'.
80       ELSE.
81         REPLACE 'M' WITH '' INTO ZMM_CDITEM-COMP_FLG.
82       ENDIF.
83
84       MOVE-CORRESPONDING ZMM_CDITEM TO G_TABCTRL110_WA.
85
86       CONCATENATE G_TABCTRL110_WA-OTH1 G_TABCTRL110_WA-OTH2
87                   G_TABCTRL110_WA-OTH3 G_TABCTRL110_WA-OTH4 INTO G_OTH.
88
89       IF G_OK_CODE110 = 'PB_AD'.
90
91         IF G_CURSOR_LINE = SY-STEPL.
92
93           G_USER_DESCX = G_TABCTRL110_WA-USER_DESC.
94
95           PERFORM POPUP_USERDESC.
96           IF G_OK_CODE115 = 'OK115'.
97             PERFORM GC_FIELDS_115.
98
99           ELSEIF G_OK_CODE115 = 'CANC'.
100            G_TABCTRL110_WA-USER_DESC = G_USER_DESCX.
101
102          ENDIF.
103        ENDIF.
104      ENDIF.
105
106      CASE 'X'.
107        WHEN G_TABCTRL110_WA-OTH1.
108
109          CONCATENATE 'ZMM_CDITEM-DESC' '1' INTO G_FIELD.
110        WHEN G_TABCTRL110_WA-OTH2.
111          CONCATENATE 'ZMM_CDITEM-DESC' '2' INTO G_FIELD.
112
113        WHEN G_TABCTRL110_WA-OTH3.
114          CONCATENATE 'ZMM_CDITEM-DESC' '3' INTO G_FIELD.
115
116        WHEN G_TABCTRL110_WA-OTH4.
117          CONCATENATE 'ZMM_CDITEM-DESC' '4' INTO G_FIELD.
118
119        WHEN OTHERS.
120
121      ENDCASE.
122
123    *commented by on 24-08-05 to change DBLCLK behaviour in CHANGE mode.
124    *  if g_mode = 'CHA' and ( sy-ucomm = 'DBLCLK' or sy-ucomm = '' )
125    *     and  g_field = g_curfield and g_cursor_line = sy-stepl.
126    **   and
127    **        TABCTRL110_wa-oth1 = 'X' or
128    **        g_TABCTRL110_wa-oth2 = 'X'  or
129    **        g_TABCTRL110_wa-oth3 = 'X'  or
130    **        g_TABCTRL110_wa-oth4 = 'X' )
131    **
132    *    g_desc1 = g_tabctrl110_wa-desc1.
133    *    g_desc2 = g_tabctrl110_wa-desc2.
134    *    g_desc3 = g_tabctrl110_wa-desc3.
135    *    g_desc4 = g_tabctrl110_wa-desc4.
136    *    g_matgp = g_tabctrl110_wa-matgp.
137    *    select single WGBEZ from T023T into g_matgp_desc where MATKL =
138    *    g_matgp and spras = sy-langu.
139    *    if sy-subrc <> 0.
140    *      g_matgp = ''.
141    *    Endif.
142    *    G_USER_DESC = g_tabctrl110_wa-user_desc.
143    *    Perform popup_userdesc.
144    *    clear g_field.
145    *    If g_ok_code115 = 'OK115'.
146    *      Perform GC_Fields_115.
147    **          g_tabctrl110_wa-oth1 = ''.
148    *    Endif.
149    *
150    *  Endif.
151    * END: commented by on 24-08-05 to change DBLCLK behaviour in
152    * CHANGE mode.
153
154      IF G_CURFIELD = 'ZMM_CDITEM-MATCODE' AND G_CURSOR_LINE = SY-STEPL.
155        G_MATCODE = ZMM_CDITEM-MATCODE.
156        IF NOT G_MATCODE IS INITIAL.
157          SET PARAMETER ID 'MAT' FIELD G_MATCODE.
158          CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
159        ENDIF.
160      ENDIF.
161
162    *  PERFORM attrib_parno.
163
164      IF G_CURFIELD = 'ZMM_CDITEM-DESC1' AND G_CURSOR_LINE = SY-STEPL.
165
166        IF TABCTRL110_CHECK_FLAG = 'X'.
167          G_HITS_PAR = '1'.
168        ENDIF.
169
170        DESC11 = G_TABCTRL110_WA-DESC1.
171        FIELD1 = 'ZMM_CDITEM-DESC1'.
172        IF ( G_MODE = 'CRE' OR G_MODE = 'CHA' )
173            AND TABCTRL110_CHECK_FLAG = 'X'.
174          G_HITS_PAR = '1'.
175          IF G_OK_CODE115 <> 'OK115'.
176            CLEAR  TABCTRL110_CHECK_FLAG.
177          ENDIF.
178        ENDIF.
179        IF NOT G_TABCTRL110_WA-MATGP IS INITIAL.
180          G_MATGP = G_TABCTRL110_WA-MATGP.
181        ELSE.
182          GET PARAMETER ID 'ZMATGP' FIELD G_MATGP .
183          G_TABCTRL110_WA-MATGP = G_MATGP .
184        ENDIF.
185        IF G_TABCTRL110_WA-DESC1 <> 'OTHER'.
186          PERFORM TABCTRL110_DESC1_CHECK.
187          IF TABCTRL110_CHECK_FLAG = 'X'.
188            G_HITS_PAR = '1'.
189          ENDIF.
190        ENDIF.
191        IF G_TABCTRL110_WA-DESC1 = 'OTHER'.
192          DO_NOT_CHANGE_FLAG1 = 'X'.
193          G_TABCTRL110_WA-OTH1 = 'X'.
194          G_HITS_PAR = '4'.
195          G_HITS_PAR_OTH = 'X'.
196          PERFORM POPUP_USERDESC.
197          IF G_OK_CODE115 = 'OK115'.
198            PERFORM GC_FIELDS_115.
199          ENDIF.
200          PERFORM MOVE_DESCRIPTIONS.
201        ELSEIF G_TABCTRL110_WA-OTH1 = 'X'.
202          DO_NOT_CHANGE_FLAG1 = 'X'.
203          G_HITS_PAR = '4'.
204          G_HITS_PAR_OTH = 'X'..
205          DESCP1 = G_TABCTRL110_WA-DESC1.
206        ELSE.
207          CLEAR G_TABCTRL110_WA-OTH1.
208          DESCP1 = G_TABCTRL110_WA-DESC1.
209        ENDIF.
210        CHECK_POS = '1'.
211      ENDIF.
212
213      IF G_CURFIELD = 'ZMM_CDITEM-DESC2' AND G_CURSOR_LINE = SY-STEPL..
214        G_MATGP = G_TABCTRL110_WA-MATGP.
215        G_TABCTRL110_WA-DESC1 = ZMM_CDITEM-DESC1.
216        DESCP1 = G_TABCTRL110_WA-DESC1.
217        IF ( G_MODE = 'CRE' OR G_MODE = 'CHA' )
218           AND TABCTRL110_CHECK_FLAG = 'X'.
219          G_HITS_PAR = '2'.
220    *      clear : g_TABCTRL110_wa-desc3,
221    *              g_TABCTRL110_wa-desc4,
222    *              g_TABCTRL110_wa-oth3,
223    *              g_TABCTRL110_wa-oth4,
224    *              g_TABCTRL110_wa-user_desc,
225    *              TABCTRL110_check_flag.
226        ENDIF.
227        SET PARAMETER ID 'ZDESC_1' FIELD G_TABCTRL110_WA-DESC1.
228        IF G_TABCTRL110_WA-DESC2 <> 'OTHER'.
229          PERFORM TABCTRL110_DESC2_CHECK.
230          IF TABCTRL110_CHECK_FLAG = 'X'.
231            G_HITS_PAR = '2'.
232          ENDIF.
233        ENDIF.
234        IF G_TABCTRL110_WA-DESC2 = 'OTHER'.
235          DO_NOT_CHANGE_FLAG1 = 'X'.
236          G_TABCTRL110_WA-OTH2 = 'X'.
237          G_HITS_PAR_OTH = 'X'.
238          G_HITS_PAR = '4'.
239          PERFORM POPUP_USERDESC.
240          IF G_OK_CODE115 = 'OK115'.
241            PERFORM GC_FIELDS_115.
242          ENDIF.
243          PERFORM MOVE_DESCRIPTIONS.
244        ELSEIF G_TABCTRL110_WA-OTH2 = 'X'.
245          DO_NOT_CHANGE_FLAG1 = 'X'.
246          CLEAR G_HITS_PAR.
247          DESCP2 = G_TABCTRL110_WA-DESC2.
248        ELSE.
249          CLEAR G_TABCTRL110_WA-OTH2.
250          DESCP2 = G_TABCTRL110_WA-DESC2.
251        ENDIF.
252        FIELD1 = 'ZMM_CDITEM-DESC2'.
253        CHECK_POS = '2'.
254      ENDIF.
255
256      IF G_CURFIELD = 'ZMM_CDITEM-DESC3' AND G_CURSOR_LINE = SY-STEPL.
257        G_MATGP = G_TABCTRL110_WA-MATGP.
258        DESCP1 = G_TABCTRL110_WA-DESC1.
259        DESCP2 = G_TABCTRL110_WA-DESC2.
260        IF ( G_MODE = 'CRE' OR G_MODE = 'CHA' )
261           AND TABCTRL110_CHECK_FLAG = 'X'.
262          G_HITS_PAR = '3'.
263    *      clear : g_TABCTRL110_wa-desc4,
264    *              g_TABCTRL110_wa-oth4,
265    *              g_TABCTRL110_wa-user_desc,
266    *              TABCTRL110_check_flag.
267        ENDIF.
268        IF G_TABCTRL110_WA-DESC3 <> 'OTHER'.
269          PERFORM TABCTRL110_DESC3_CHECK.
270          IF TABCTRL110_CHECK_FLAG = 'X'.
271            G_HITS_PAR = '3'.
272          ENDIF.
273        ENDIF.
274        IF G_TABCTRL110_WA-DESC3 = 'OTHER'.
275          DO_NOT_CHANGE_FLAG1 = 'X'.
276          G_TABCTRL110_WA-OTH3 = 'X'.
277          G_HITS_PAR_OTH = 'X'.
278          G_HITS_PAR = '4'.
279          PERFORM POPUP_USERDESC.
280          IF G_OK_CODE115 = 'OK115'.
281            PERFORM GC_FIELDS_115.
282          ENDIF.
283          PERFORM MOVE_DESCRIPTIONS.
284        ELSEIF G_TABCTRL110_WA-OTH3 = 'X'.
285          DO_NOT_CHANGE_FLAG1 = 'X'.
286          CLEAR G_HITS_PAR.
287          DESCP3 = G_TABCTRL110_WA-DESC3.
288        ELSE.
289          CLEAR G_TABCTRL110_WA-OTH3.
290          DESCP3 = G_TABCTRL110_WA-DESC3.
291        ENDIF.
292
293        FIELD1 = 'ZMM_CDITEM-DESC3'.
294        CHECK_POS = '3'.
295      ENDIF.
296
297      IF G_CURFIELD = 'ZMM_CDITEM-DESC4' AND G_CURSOR_LINE = SY-STEPL.
298        G_MATGP = G_TABCTRL110_WA-MATGP.
299        DESCP1 = G_TABCTRL110_WA-DESC1.
300        DESCP2 = G_TABCTRL110_WA-DESC2.
301        DESCP3 = G_TABCTRL110_WA-DESC3.
302        IF G_TABCTRL110_WA-DESC4 <> 'OTHER'.
303          PERFORM TABCTRL110_DESC4_CHECK.
304          IF TABCTRL110_CHECK_FLAG = 'X'.
305            G_HITS_PAR = '4'.
306          ENDIF.
307        ENDIF.
308        IF G_TABCTRL110_WA-DESC4 = 'OTHER'.
309          DO_NOT_CHANGE_FLAG1 = 'X'.
310          G_TABCTRL110_WA-OTH4 = 'X'.
311          G_HITS_PAR_OTH = 'X'.
312          G_HITS_PAR = '4'.
313          PERFORM POPUP_USERDESC.
314          IF G_OK_CODE115 = 'OK115'.
315            PERFORM GC_FIELDS_115.
316          ENDIF.
317          PERFORM MOVE_DESCRIPTIONS.
318
319          G_TABCTRL110_WA-USER_DESC = G_USER_DESC.
320        ELSEIF G_TABCTRL110_WA-OTH4 = 'X'.
321          DO_NOT_CHANGE_FLAG1 = 'X'.
322          CLEAR G_HITS_PAR.
323          DESCP4 = G_TABCTRL110_WA-DESC4.
324        ELSE.
325          CLEAR G_TABCTRL110_WA-OTH4.
326          DESCP4 = G_TABCTRL110_WA-DESC4.
327        ENDIF.
328        FIELD1 = 'ZMM_CDITEM-DESC4'.
329        CHECK_POS = '4'.
330      ENDIF.
331
332      IF G_CURFIELD = 'ZMM_CDITEM-USER_DESC' AND G_CURSOR_LINE = SY-STEPL.
333        DESCP5 = G_TABCTRL110_WA-USER_DESC.
334        FIELD1 = 'ZMM_CDITEM-USER_DESC'.
335        CHECK_POS = '5'.
336      ENDIF.
337    ****Addition for Copy of Description**********************************
338      IF G_CURFIELD = 'ZMM_CDITEM-DESC_CDCELL' AND G_CURSOR_LINE = SY-STEPL.
339        FIELD1 = 'ZMM_CDITEM-USER_DESC'.
340    *    check_pos = '5'.
341      ENDIF.
342    ****End                             **********************************
343
344      IF G_TABCTRL110_WA-COMP_FLG IS INITIAL AND
345         NOT G_TABCTRL110_WA-RSN IS INITIAL.
346        MOVE SPACE TO G_TABCTRL110_WA-RSN.
347      ELSEIF NOT G_TABCTRL110_WA-COMP_FLG IS INITIAL.
348        CLEAR WA_RSN.
349        SELECT SINGLE * FROM ZMM_CODREQ_RSN INTO WA_RSN
350       WHERE REASON = G_TABCTRL110_WA-COMP_FLG.
351        G_TABCTRL110_WA-RSN = WA_RSN-DESCRIPTION.
352        CLEAR WA_RSN.
353      ENDIF.
354    * for codifier
355    *
356      CONCATENATE G_TABCTRL110_WA-DESC1
357                    G_TABCTRL110_WA-DESC2
358                    G_TABCTRL110_WA-DESC3
359                    G_TABCTRL110_WA-DESC4
360                    G_TABCTRL110_WA-USER_DESC
361               INTO G_TABCTRL110_WA-DESC_FIN
362               SEPARATED BY SPACE.
363
364      CONDENSE G_TABCTRL110_WA-DESC_FIN.
365      MODIFY G_TABCTRL110_ITAB
366        FROM G_TABCTRL110_WA
367        INDEX TABCTRL110-CURRENT_LINE.
368      IF SY-SUBRC <> 0.
369        IF G_TABCTRL110_WA-DESC1 = 'OTHER' OR
370           G_TABCTRL110_WA-DESC2 = 'OTHER' OR
371           G_TABCTRL110_WA-DESC3 = 'OTHER' OR
372           G_TABCTRL110_WA-DESC4 = 'OTHER'.
373        ELSE.
374          APPEND G_TABCTRL110_WA TO G_TABCTRL110_ITAB.
375        ENDIF.
376      ENDIF.
377      IF SY-TCODE = 'ZCODG' AND G_CURSOR_LINE = SY-STEPL
378             AND ( SY-UCOMM = 'DBLCLK' OR SY-UCOMM = '' ).
379        PERFORM GET_SRNO.
380      ENDIF.
381    ENDMODULE.                    "TABCTRL110_modify INPUT
382
383    *&spwizard: mark table
384    MODULE TABCTRL110_MARK INPUT.
385      IF TABCTRL110-LINE_SEL_MODE = 1 AND
386         G_TABCTRL110_WA-FLAG = 'X'.
387        LOOP AT G_TABCTRL110_ITAB INTO G_TABCTRL110_WA
388          WHERE FLAG = 'X'.
389          G_TABCTRL110_WA-FLAG = ''.
390          MODIFY G_TABCTRL110_ITAB
391            FROM G_TABCTRL110_WA
392            TRANSPORTING FLAG.
393        ENDLOOP.
394        G_TABCTRL110_WA-FLAG = 'X'.
395      ENDIF.
396      MODIFY G_TABCTRL110_ITAB
397        FROM G_TABCTRL110_WA
398        INDEX TABCTRL110-CURRENT_LINE
399        TRANSPORTING FLAG.
400    ENDMODULE.                    "TABCTRL110_mark INPUT
401
402    *&spwizard: input module for tc 'TABCTRL110'. do not change this line!
403    *&spwizard: process user command
404    MODULE TABCTRL110_USER_COMMAND INPUT.
405
406      IF CHECK_POS = '1'.
407
408        SET PARAMETER ID 'ZDESC_1' FIELD DESCP1.
409        SET PARAMETER ID 'ZDESC_2' FIELD ''.
410        SET PARAMETER ID 'ZDESC_3' FIELD ''.
411        SET PARAMETER ID 'ZDESC_4' FIELD ''.
412
413        DESC11 = DESCP1.
414        DESC22 = ''.
415        DESC33 = ''.
416        DESC44 = ''.
417        DESC55 = ''.
418
419      ENDIF.
420
421      IF CHECK_POS = '2'.
422
423        SET PARAMETER ID 'ZDESC_1' FIELD DESCP1.
424        SET PARAMETER ID 'ZDESC_2' FIELD DESCP2.
425        SET PARAMETER ID 'ZDESC_3' FIELD ''.
426        SET PARAMETER ID 'ZDESC_4' FIELD ''.
427
428        DESC11 = DESCP1.
429        DESC22 = DESCP2.
430        DESC33 = ''.
431        DESC44 = ''.
432        DESC55 = ''.
433
434      ENDIF.
435
436      IF CHECK_POS = '3'.
437
438        SET PARAMETER ID 'ZDESC_1' FIELD DESCP1.
439        SET PARAMETER ID 'ZDESC_2' FIELD DESCP2.
440        SET PARAMETER ID 'ZDESC_3' FIELD DESCP3.
441        SET PARAMETER ID 'ZDESC_4' FIELD ''.
442
443        DESC11 = DESCP1.
444        DESC22 = DESCP2.
445        DESC33 = DESCP3.
446        DESC44 = ''.
447        DESC55 = ''.
448
449      ENDIF.
450
451      IF CHECK_POS = '4'.
452
453        SET PARAMETER ID 'ZDESC_1' FIELD DESCP1.
454        SET PARAMETER ID 'ZDESC_2' FIELD DESCP2.
455        SET PARAMETER ID 'ZDESC_3' FIELD DESCP3.
456        SET PARAMETER ID 'ZDESC_4' FIELD DESCP4.
457
458        DESC11 = DESCP1.
459        DESC22 = DESCP2.
460        DESC33 = DESCP3.
461        DESC44 = DESCP4.
462        DESC55 = ''.
463
464      ENDIF.
465
466      IF CHECK_POS = '5'.
467
468        CASE G_PARNO.
469          WHEN '2'.
470            CLEAR DESCP3.
471            CLEAR DESCP4.
472          WHEN '3'.
473            CLEAR DESCP4.
474        ENDCASE.
475
476        DESC11 = DESCP1.
477        DESC22 = DESCP2.
478        DESC33 = DESCP3.
479        DESC44 = DESCP4.
480        DESC55 = DESCP5.
481
482      ENDIF.
483
484      G_LINENO = G_CURR_LINE.
485      G_MATGPO = G_MATGP.
486
487      GET CURSOR FIELD G_CURFIELD.
488
489    ENDMODULE.                    "TABCTRL110_user_command INPUT
490
491    *&spwizard: input module for tc 'TABLCTRL130'. do not change this line!
492    *&spwizard: modify table
493    MODULE TABLCTRL130_MODIFY INPUT.
494      ZMM_CDITEM-UOM = 'NO'.
495    *
496      IF G_CURFIELD = 'ZMM_CDITEM-MATCODE' AND G_CURSOR_LINE = SY-STEPL.
497        G_MATCODE = ZMM_CDITEM-MATCODE.
498        IF NOT G_MATCODE IS INITIAL.
499          SET PARAMETER ID 'MAT' FIELD G_MATCODE.
500          CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
501        ENDIF.
502      ENDIF.
503
504    *
505      MOVE-CORRESPONDING ZMM_CDITEM TO G_TABLCTRL130_WA.
506      MODIFY G_TABLCTRL130_ITAB
507           FROM G_TABLCTRL130_WA
508             INDEX TABLCTRL130-CURRENT_LINE.
509
510      IF SY-SUBRC <> 0 .
511        IF G_MODE = 'CRE' .
512          APPEND G_TABLCTRL130_WA TO G_TABLCTRL130_ITAB.
513        ELSE.
514          IF G_MODE = 'CHA' AND ZMM_CDITEM-SRNO = '' AND OKCODE_100 = 'SAV'.
515          ELSE.
516            APPEND G_TABLCTRL130_WA TO G_TABLCTRL130_ITAB.
517          ENDIF.
518        ENDIF.
519      ENDIF.
520
521      IF SY-TCODE = 'ZCODG' AND G_CURSOR_LINE = SY-STEPL
522             AND ( SY-UCOMM = 'DBLCLK' OR SY-UCOMM = '' ).
523        PERFORM GET_SRNO.
524      ENDIF.
525
526    ENDMODULE.                    "TABLCTRL130_modify INPUT
527
528    *&spwizard: input module for tc 'TABLCTRL130'. do not change this line!
529    *&spwizard: mark table
530    MODULE TABLCTRL130_MARK INPUT.
531      IF TABLCTRL130-LINE_SEL_MODE = 1 AND
532         G_TABLCTRL130_WA-FLAG = 'X'.
533        LOOP AT G_TABLCTRL130_ITAB INTO G_TABLCTRL130_WA
534          WHERE FLAG = 'X'.
535          G_TABLCTRL130_WA-FLAG = ''.
536          MODIFY G_TABLCTRL130_ITAB
537            FROM G_TABLCTRL130_WA
538            TRANSPORTING FLAG.
539        ENDLOOP.
540        G_TABLCTRL130_WA-FLAG = 'X'.
541      ENDIF.
542      MODIFY G_TABLCTRL130_ITAB
543        FROM G_TABLCTRL130_WA
544        INDEX TABLCTRL130-CURRENT_LINE
545        TRANSPORTING FLAG.
546    ENDMODULE.                    "TABLCTRL130_mark INPUT
547
548    *&spwizard: input module for tc 'TABLCTRL130'. do not change this line!
549    *&spwizard: process user command
550    MODULE TABLCTRL130_USER_COMMAND INPUT.
551
552      IF CHECK_POS = '1'.
553
554        DESC11 = DESCP1.
555        DESC22 = ''.
556        DESC33 = ''.
557        DESC44 = ''.
558        DESC55 = ''.
559
560      ENDIF.
561
562      IF CHECK_POS = '5'.
563
564        DESC11 = DESCP1.
565        DESC22 = ''.
566        DESC33 = ''.
567        DESC44 = ''.
568        DESC55 = DESCP5.
569      ENDIF.
570
571    ENDMODULE.                    "TABLCTRL130_user_command INPUT
572
573    *&spwizard: input module for tc 'TABLCTRL140'. do not change this line!
574    *&spwizard: modify table
575    MODULE TABLCTRL140_MODIFY INPUT.
576      MOVE-CORRESPONDING ZMM_CDITEM TO G_TABLCTRL140_WA.
577      IF G_CURFIELD = 'ZMM_CDITEM-DESC1' AND SY-STEPL = G_CURR_LINE.
578        DESCP1 = G_TABLCTRL140_WA-DESC1.
579        FIELD1 = 'ZMM_CDITEM-DESC1'.
580        IF G_TABLCTRL140_WA-DESC1 <> 'OTHER'.
581          PERFORM TABLCTRL140_DESC1_CHECK.
582        ENDIF.
583        IF G_TABLCTRL140_WA-DESC1 = 'OTHER'.
584          G_TABLCTRL140_WA-OTH1 = 'X'.
585          PERFORM POPUP_USERDESC.
586          G_TABLCTRL140_WA-USER_DESC = G_USER_DESC.
587        ELSEIF G_TABLCTRL140_WA-OTH1 = 'X'.
588          DESCP1 = G_TABLCTRL140_WA-DESC1.
589        ELSE.
590          CLEAR G_TABLCTRL140_WA-OTH1.
591          DESCP1 = G_TABLCTRL140_WA-DESC1.
592        ENDIF.
593        CHECK_POS = '1'.
594      ENDIF.
595
596      IF G_CURFIELD = 'ZMM_CDITEM-USER_DESC' AND SY-STEPL = G_CURR_LINE.
597        DESCP5 = G_TABLCTRL140_WA-USER_DESC.
598        FIELD1 = 'ZMM_CDITEM-USER_DESC'.
599        CHECK_POS = '5'.
600      ENDIF.
601
602      MODIFY G_TABLCTRL140_ITAB
603        FROM G_TABLCTRL140_WA
604        INDEX TABLCTRL140-CURRENT_LINE.
605    *
606      IF SY-SUBRC <> 0.
607        APPEND G_TABLCTRL140_WA TO G_TABLCTRL140_ITAB.
608      ENDIF.
609    *
610      IF SY-TCODE = 'ZCODG' AND G_CURSOR_LINE = SY-STEPL
611        AND ( SY-UCOMM = 'DBLCLK' OR SY-UCOMM = '' ).
612        PERFORM GET_SRNO.
613      ENDIF.
614
615    ENDMODULE.                    "TABLCTRL140_modify INPUT
616
617    *&spwizard: input module for tc 'TABLCTRL140'. do not change this line!
618    *&spwizard: mark table
619    MODULE TABLCTRL140_MARK INPUT.
620      IF TABLCTRL140-LINE_SEL_MODE = 1 AND
621         G_TABLCTRL140_WA-FLAG = 'X'.
622        LOOP AT G_TABLCTRL140_ITAB INTO G_TABLCTRL140_WA
623          WHERE FLAG = 'X'.
624          G_TABLCTRL140_WA-FLAG = ''.
625          MODIFY G_TABLCTRL140_ITAB
626            FROM G_TABLCTRL140_WA
627            TRANSPORTING FLAG.
628        ENDLOOP.
629        G_TABLCTRL140_WA-FLAG = 'X'.
630      ENDIF.
631      MODIFY G_TABLCTRL140_ITAB
632        FROM G_TABLCTRL140_WA
633        INDEX TABLCTRL140-CURRENT_LINE
634        TRANSPORTING FLAG.
635    ENDMODULE.                    "TABLCTRL140_mark INPUT
636
637    *&spwizard: input module for tc 'TABLCTRL140'. do not change this line!
638    *&spwizard: process user command
639    MODULE TABLCTRL140_USER_COMMAND INPUT.
640      IF CHECK_POS = '1'.
641
642        DESC11 = DESCP1.
643        DESC22 = ''.
644        DESC33 = ''.
645        DESC44 = ''.
646        DESC55 = ''.
647
648      ENDIF.
649
650      IF CHECK_POS = '5'.
651
652        DESC11 = DESCP1.
653        DESC22 = ''.
654        DESC33 = ''.
655        DESC44 = ''.
656        DESC55 = DESCP5.
657      ENDIF.
658
659      G_LINENO = G_CURR_LINE.
660
661    ENDMODULE.                    "TABLCTRL140_user_command INPUT
662
663    *&spwizard: input module for tc 'TABLCTRL120'. do not change this line!
664    *&spwizard: modify table
665    MODULE TABLCTRL120_MODIFY INPUT.
666      G_SH_PARTNO = 'X'.
667      MOVE-CORRESPONDING ZMM_CDITEM TO G_TABLCTRL120_WA.
668
669    *  SELECT SINGLE ATINN FROM CABN INTO G_ATINN WHERE
670    *  ATNAM = 'Z_ONGC_GROUP_OF_SPARES'.
671    *
672    *  SELECT SINGLE ATWRT FROM AUSP INTO G_ATWRT WHERE
673    *  OBJEK = G_TABLCTRL120_WA-CAP_CODE AND ATINN = G_ATINN.
674
675       SELECT SINGLE ZZMAGR FROM MARA INTO G_ZZMAGR WHERE MATNR = G_TABLCTRL120_WA-CAP_CODE.
676
677       G_TABLCTRL120_WA-MATGP = G_ZZMAGR.
678
679    *  CLEAR G_ATINN.
680
681    *
682      IF G_CURFIELD = 'ZMM_CDITEM-MATCODE' AND G_CURSOR_LINE = SY-STEPL.
683        G_MATCODE = ZMM_CDITEM-MATCODE.
684        IF NOT G_MATCODE IS INITIAL.
685          SET PARAMETER ID 'MAT' FIELD G_MATCODE.
686          CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
687        ENDIF.
688      ENDIF.
689
690    ****Calling transaction MK03 for vendor.
691
692      IF SY-TCODE = 'ZCODG'.
693
694        G_MFRNR  = ZMM_CDITEM-MANU.
695
696        IF G_CURFIELD = 'ZMM_CDITEM-MANU'. "and g_cursor_line = sy-stepl.
697          IF NOT G_MFRNR IS INITIAL.
698
699    "Begin of atc correction on 29.04.2026
700
701    *        SET PARAMETER ID 'LIF' FIELD G_MFRNR.
702    *        CALL TRANSACTION 'MK03' AND SKIP FIRST SCREEN.
703            DATA(l_vend) = CONV lifnr( g_mfrnr ).
704            SELECT PARTNER FROM V_CVI_VEND_LINK
705     INTO @DATA(LV_PARTNER) UP TO 1 ROWS WHERE LIFNR = @L_VEND
706     ORDER BY PRIMARY KEY .
707     ENDSELECT.
708              IF sy-subrc IS INITIAL.
709
710           DATA(request) = NEW cl_bupa_navigation_request( ).
711            request->set_partner_number( lv_partner ).     " import your BP number here
712            CALL METHOD request->set_bupa_activity
713              EXPORTING
714                iv_value = request->gc_activity_display.
715
716           DATA(options) = NEW cl_bupa_dialog_joel_options( ).
717              options->set_navigation_disabled( abap_true ).
718              cl_bupa_dialog_joel=>start_with_navigation( iv_request = request
719                                                          iv_options = options ).
720              ENDIF.
721    "End of atc correction on 29.04.2026
722
723          ENDIF.
724        ENDIF.
725
726      ENDIF.
727
728    *
729      IF G_CURFIELD = 'ZMM_CDITEM-PARTNO' AND SY-STEPL = G_CURSOR_LINE.
730        IF G_PARTNOC <> G_TABLCTRL120_WA-PARTNO.
731          CLEAR : G_TABLCTRL120_WA-DESC1,
732                  G_TABLCTRL120_WA-OTH1,
733                  G_TABLCTRL120_WA-USER_DESC.
734        ENDIF.
735        G_PARTNOC = G_TABLCTRL120_WA-PARTNO.
736        FIELD1 = 'ZMM_CDITEM-PARTNO'.
737        IF ( G_MODE = 'CRE' OR G_MODE = 'CHA' ) .
738          CLEAR : G_TABCTRL110_WA-DESC1,DESCP1.
739        ENDIF.
740        CHECK_POS = '0'.
741      ENDIF.
742
743      IF G_CURFIELD = 'ZMM_CDITEM-DESC1' AND SY-STEPL = G_CURSOR_LINE.
744        DESCP1 = G_TABLCTRL120_WA-DESC1.
745        FIELD1 = 'ZMM_CDITEM-DESC1'.
746
747        IF G_TABLCTRL120_WA-DESC1 <> 'OTHER'.
748          PERFORM TABLCTRL120_DESC1_CHECK.
749        ENDIF.
750        IF G_TABLCTRL120_WA-DESC1 = 'OTHER'.
751          G_TABLCTRL120_WA-OTH1 = 'X'.
752          PERFORM POPUP_USERDESC.
753          G_TABLCTRL120_WA-USER_DESC = G_USER_DESC.
754        ELSEIF G_TABLCTRL120_WA-OTH1 = 'X'.
755          G_PARTNOC = G_TABLCTRL120_WA-PARTNO.
756        ELSE.
757          CLEAR G_TABLCTRL120_WA-OTH1.
758          G_PARTNOC = G_TABLCTRL120_WA-PARTNO.
759        ENDIF.
760        CHECK_POS = '1'.
761      ENDIF.
762
763      IF G_CURFIELD = 'ZMM_CDITEM-USER_DESC' AND SY-STEPL = G_CURSOR_LINE.
764        DESCP5 = G_TABLCTRL120_WA-USER_DESC.
765        FIELD1 = 'ZMM_CDITEM-USER_DESC'.
766        CHECK_POS = '5'.
767      ENDIF.
768
769      MODIFY G_TABLCTRL120_ITAB
770        FROM G_TABLCTRL120_WA
771        INDEX TABLCTRL120-CURRENT_LINE.
772
773    *
774      IF SY-SUBRC <> 0.
775        APPEND G_TABLCTRL120_WA TO G_TABLCTRL120_ITAB.
776      ENDIF.
777    *
778      IF SY-TCODE = 'ZCODG' AND G_CURSOR_LINE = SY-STEPL
779          AND ( SY-UCOMM = 'DBLCLK' OR SY-UCOMM = '' ).
780        PERFORM GET_SRNO.
781      ENDIF.
782
783      G_LINENO = G_CURR_LINE.
784
785
786
787    "added by lipsy on 0n 05.09.2012 <RD1K979105> to get vendor name
788
789    if g_mode = 'CRE' OR g_mode = 'CHA'.
790         REFRESH:itab_lfa1.
791
792      if g_TABLCTRL120_itab is not INITIAL.
793      select lifnr name1
794           FROM lfa1
795           INTO CORRESPONDING FIELDS OF TABLE  itab_lfa1
796           FOR ALL ENTRIES IN g_TABLCTRL120_itab
797           WHERE lifnr =  g_TABLCTRL120_itab-manu.
798      endif.
799
800      CLEAR:WA_LFA1.
801
802          READ TABLE itab_lfa1 INTO wa_lfa1 with key lifnr = g_TABLCTRL120_wa-manu.
803           g_TABLCTRL120_wa-name1 = wa_lfa1-name1.
804           MODIFY  g_TABLCTRL120_itab FROM g_TABLCTRL120_wa
805            TRANSPORTING name1
806            where manu = g_TABLCTRL120_wa-manu .
807    ENDIF.
808     "end of addition on 05.09.2012
809    ENDMODULE.                    "TABLCTRL120_modify INPUT
810
811    *&spwizard: input module for tc 'TABLCTRL120'. do not change this line!
812    *&spwizard: mark table
813    MODULE TABLCTRL120_MARK INPUT.
814      IF TABLCTRL120-LINE_SEL_MODE = 1 AND
815         G_TABLCTRL120_WA-FLAG = 'X'.
816        LOOP AT G_TABLCTRL120_ITAB INTO G_TABLCTRL120_WA
817          WHERE FLAG = 'X'.
818          G_TABLCTRL120_WA-FLAG = ''.
819          MODIFY G_TABLCTRL120_ITAB
820            FROM G_TABLCTRL120_WA
821            TRANSPORTING FLAG.
822        ENDLOOP.
823        G_TABLCTRL120_WA-FLAG = 'X'.
824      ENDIF.
825      MODIFY G_TABLCTRL120_ITAB
826        FROM G_TABLCTRL120_WA
827        INDEX TABLCTRL120-CURRENT_LINE
828        TRANSPORTING FLAG.
829
830    ENDMODULE.                    "TABLCTRL120_mark INPUT
831
832    *&spwizard: input module for tc 'TABLCTRL120'. do not change this line!
833    *&spwizard: process user command
834    MODULE TABLCTRL120_USER_COMMAND INPUT.
835
836      IF CHECK_POS = '0'.
837
838        DESC11 = ''.
839        DESC22 = ''.
840        DESC33 = ''.
841        DESC44 = ''.
842        DESC55 = ''.
843    *
844        IF FIELD1 = 'ZMM_CDITEM-PARTNO' AND
845           SY-UCOMM = 'DBLCLK' OR SY-UCOMM = ''.
846          G_CURS_LN = G_CURR_LINE_120.
847          CLEAR : G_SH_CAPEQT,G_SH_MDLNO,G_SH_MFR,G_FST_SRCHLP.
848          REFRESH: IST_SRCHLP_CPO.
849        ENDIF.
850    *
851
852      ENDIF.
853
854
855      IF CHECK_POS = '1'.
856
857        DESC11 = DESCP1.
858        DESC22 = ''.
859        DESC33 = ''.
860        DESC44 = ''.
861        DESC55 = ''.
862
863      ENDIF.
864
865      IF CHECK_POS = '5'.
866
867        DESC11 = DESCP1.
868        DESC22 = ''.
869        DESC33 = ''.
870        DESC44 = ''.
871        DESC55 = DESCP5.
872      ENDIF.
873
874      OK_CODE = SY-UCOMM.
875
876      IF OK_CODE = 'SAV' AND G_LINENO <> 0.
877
878        PERFORM GET_MAT_FIND.
879
880      ENDIF.
881
882      PERFORM USER_OK_TC USING    'TABLCTRL120'
883                                  'G_TABLCTRL120_ITAB'
884                                  'FLAG'
885                         CHANGING OK_CODE.
886      SY-UCOMM = OK_CODE.
887    *
888    *perform get_cursor120.
889    *
890
891
892    ENDMODULE.                    "TABLCTRL120_user_command INPUT
893    *&---------------------------------------------------------------------*
894    *&      Module  user_command_100  INPUT
895    *&---------------------------------------------------------------------*
896    *       text
897    *----------------------------------------------------------------------*
898    MODULE USER_COMMAND_100 INPUT.
899      DATA : L_ANS1.
900      CASE OKCODE_100.
901        WHEN 'BAC' OR 'CAN'.
902          IF SY-TCODE = 'ZCODG'.
903            PERFORM EXIT_CONFIRM.
904          ENDIF.
905          PERFORM BAC_CONFIRM.
906          REFRESH IST_SRCHLP.
907          REFRESH CONTROL 'TABCTRL100' FROM SCREEN '0100'.
908          CLEAR G_CURR_LINE_120.
909          CLEAR OKCODE_100.
910        WHEN 'CR_MATCODE'.
911          G_MODE = 'CRC'.
912          IF NOT DYNNR IS INITIAL.
913            PERFORM CREATE_MATCODE.
914    *        IF zmm_cdhd_st-reqcl = 'C' or
915    *           zmm_cdhd_st-reqcl = 'IR'.
916    *           perform send_mail_to_reqn.
917    *        ENDIF.
918          ENDIF.
919          CLEAR OKCODE_100.
920        WHEN 'CREATE'.
921          G_MODE = 'CRE'.
922          CLEAR OKCODE_100.
923        WHEN 'CHANGE'.
924          G_MODE = 'CHA'.
925          CLEAR OKCODE_100.
926        WHEN 'DISPLAY'.
927          G_MODE = 'DIS'.
928          CLEAR OKCODE_100.
929        WHEN 'DELETE'.
930          G_MODE = 'DEL'.
931          CLEAR OKCODE_100.
932        WHEN 'SAV'.
933          CLEAR OKCODE_100.   "gcu 24-10-05
934          IF NOT ZMM_CDHD_ST-MTART IS INITIAL.
935            PERFORM CHECK_ITEMS.
936            PERFORM CHECK_DUPL_REC1.  "+
937            IF NOT G_CDITEM_ITAB IS INITIAL.
938              G_SAVEFLAG = 'N'.
939              CLEAR G_CDITEM.
940              REFRESH G_CDITEM_ITAB.
941            ENDIF.
942            IF G_SAVEFLAG = 'Y' AND G_CHECK_FLAG = ''.
943              PERFORM SAVE_REQUEST.
944            ELSE.
945              MESSAGE I075(ZMM_OTH).
946              CLEAR G_CHECK_FLAG.
947            ENDIF.
948          ENDIF.
949          CLEAR OKCODE_100.
950          CLEAR G_CURR_LINE_120.
951          IF SY-TCODE = 'ZCODG'.
952    *        IF zmm_cdhd_st-reqcl = 'C' or
953    *           zmm_cdhd_st-reqcl = 'IR'.
954    *           perform send_mail_to_reqn.
955    *        ENDIF.
956            LEAVE PROGRAM.
957          ENDIF.
958        WHEN 'RELEASE'.
959          G_MODE = 'REL'.
960          CLEAR OKCODE_100.
961        WHEN 'APPROVE'.
962          G_MODE = 'APR'.
963          CLEAR OKCODE_100.
964        WHEN 'DD'.
965          PERFORM DISPLAY_TEXT.
966          CLEAR OKCODE_100.
967        WHEN 'REMLT'.
968          CALL SCREEN 105 STARTING AT 85 05 ENDING AT 148 24.
969          CLEAR OKCODE_100.
970        WHEN 'INS_MODI'.
971          PERFORM INSERT_MODIF.
972          CLEAR OKCODE_100.
973        WHEN 'SPELL'.
974
975          IF ZMM_CDHD_ST-MTART = 'ZSTO'.
976            PERFORM SPELL_CHECK1.
977            PERFORM MODI_CHECK.
978            CLEAR OKCODE_100.
979          ELSEIF ZMM_CDHD_ST-MTART = 'ZSPR'.
980            PERFORM SPELL_CHECK2.
981            CLEAR OKCODE_100.
982          ELSEIF ZMM_CDHD_ST-MTART = 'ZCAP'.
983            PERFORM SPELL_CHECK3.
984            CLEAR OKCODE_100.
985          ENDIF.
986        WHEN 'INS_MDL'.
987          PERFORM INSERT_MDLNO. "ZSPR
988          CLEAR OKCODE_100.
989        WHEN 'REQLT'.
990    **Addition*******************************************<<SK18112005>>
991          IF G_MODE = 'CRE' OR
992              G_MODE = 'CHA'.
993    ****End********************************************<<SK18112005>>
994            G_DSTEXT = 'The detailed specifications will default in PR/PO.Continue?'.
995            " Begin of <RD1K960036>.
996
997    *        CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
998    *          EXPORTING
999    *            DEFAULTOPTION  = 'N'
1000   *            TEXTLINE1      = g_dstext
1001   *            TITEL          = 'Confirm-Detail Specification'
1002   *            START_COLUMN   = 25
1003   *            START_ROW      = 6
1004   *            CANCEL_DISPLAY = ''
1005   *          IMPORTING
1006   *            ANSWER         = g_dschoice.
1007           DATA : L_GET12(1) TYPE C.
1008           CALL FUNCTION 'POPUP_TO_CONFIRM'
1009             EXPORTING
1010               TITLEBAR       = 'Confirm-Detail Specification'
1011               TEXT_QUESTION  = G_DSTEXT
1012               DEFAULT_BUTTON = '2'
1013               START_COLUMN   = 25
1014               START_ROW      = 6
1015             IMPORTING
1016               ANSWER         = L_GET12
1017             EXCEPTIONS
1018               TEXT_NOT_FOUND = 1
1019               OTHERS         = 2.
1020           IF SY-SUBRC = 0.
1021             CASE L_GET12.
1022               WHEN '1'.
1023                 MOVE 'J' TO G_DSCHOICE.
1024               WHEN '2'.
1025                 MOVE 'N' TO G_DSCHOICE.
1026             ENDCASE.
1027           ENDIF.
1028           " End of <RD1K960036>.
1029           IF G_DSCHOICE = 'J'.
1030             PERFORM LTXTDTSP.
1031           ENDIF.
1032   **Addition*******************************************<<SK18112005>>
1033         ELSE.
1034           PERFORM LTXTDTSP.
1035         ENDIF.
1036   ****End********************************************<<SK18112005>>
1037         CLEAR OKCODE_100.
1038       WHEN 'MODNO' OR 'CAPEQT' OR 'MFR'.
1039
1040         READ TABLE G_TABLCTRL120_ITAB INTO G_TABLCTRL120_WA
1041         INDEX G_CURS_LN.
1042         REFRESH IST_SRCHLP_CP.
1043         APPEND LINES OF IST_SRCHLP_CPO TO IST_SRCHLP_CP.
1044         PERFORM SRCHLP_SPR_DEL.
1045         CLEAR OKCODE_100.
1046
1047   *** CAB_AJIT 03.02.2006 ************
1048       WHEN 'EXPORT'.
1049         PERFORM EXPORT_DATA.
1050         CLEAR OKCODE_100.
1051   ************************************
1052       WHEN 'CPMC'.
1053         " Begin of <RD1K960036>.
1054
1055   *      CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
1056   *        EXPORTING
1057   *         DEFAULTOPTION         = 'Y'
1058   *          TEXTLINE1            = 'You are about to copy existing'
1059   *          TEXTLINE2            = 'Material Code. Continue?'
1060   *          TITEL                = 'Copy Existing Material Code'
1061   *          START_COLUMN         = 25
1062   *          START_ROW            = 6
1063   **         CANCEL_DISPLAY       = 'X'
1064   *       IMPORTING
1065   *          ANSWER               = l_ans1 .
1066         DATA : L_GET13(1) TYPE C.
1067         CALL FUNCTION 'POPUP_TO_CONFIRM'
1068           EXPORTING
1069             TITLEBAR       = 'Copy Existing Material Code '
1070             TEXT_QUESTION  = 'You are about to copy existing Material Code. Continue?'
1071             DEFAULT_BUTTON = '1'
1072             START_COLUMN   = 25
1073             START_ROW      = 6
1074           IMPORTING
1075             ANSWER         = L_GET13
1076           EXCEPTIONS
1077             TEXT_NOT_FOUND = 1
1078             OTHERS         = 2.
1079         IF SY-SUBRC = 0.
1080           CASE L_GET13.
1081             WHEN '1'.
1082               MOVE 'J' TO L_ANS1 .
1083             WHEN '2'.
1084               MOVE 'N' TO L_ANS1 .
1085           ENDCASE.
1086         ENDIF.
1087         " End of <RD1K960036>.
1088         CHECK L_ANS1 = 'J'.
1089         CLEAR L_ANS1.
1090
1091   * G_SRNO is being picked up thru Perform get_srno.
1092         READ TABLE IST_SRCHLP INTO WA_SRCHLP WITH KEY MARK = 'X'.
1093         IF SY-SUBRC = 0.
1094           CASE ZMM_CDHD_ST-MTART.
1095             WHEN 'ZSTO'.
1096               READ TABLE G_TABCTRL110_ITAB INTO G_TABCTRL110_WA
1097                                              WITH KEY SRNO = G_SRNO.
1098               IF SY-SUBRC = 0.
1099                 G_TABCTRL110_WA-MATCODE = WA_SRCHLP-MATNR.
1100                 WA_SRCHLP-MARK = ''.
1101                 G_TABCTRL110_WA-HAZ = G_TABCTRL110_WA-COMP_FLG.
1102                 G_TABCTRL110_WA-COMP_FLG = 'A'.
1103
1104                 MODIFY G_TABCTRL110_ITAB FROM G_TABCTRL110_WA
1105                       INDEX SY-TABIX TRANSPORTING COMP_FLG
1106                                                   MATCODE HAZ.
1107                 MODIFY  IST_SRCHLP FROM WA_SRCHLP
1108                          TRANSPORTING MARK WHERE MARK = 'X'.
1109               ENDIF.
1110   *
1111             WHEN 'ZSPR'.
1112               READ TABLE G_TABLCTRL120_ITAB INTO G_TABLCTRL120_WA
1113                                               WITH KEY SRNO = G_SRNO.
1114               IF SY-SUBRC = 0.
1115   *
1116                 G_TABLCTRL120_WA-MATCODE = WA_SRCHLP-MATNR.
1117                 G_TABLCTRL120_WA-FLAG = ''.
1118                 G_TABLCTRL120_WA-HAZ = G_TABCTRL110_WA-COMP_FLG.
1119                 G_TABLCTRL120_WA-COMP_FLG = 'A'.
1120                 MODIFY G_TABLCTRL120_ITAB FROM G_TABLCTRL120_WA
1121                       INDEX SY-TABIX TRANSPORTING FLAG COMP_FLG MATCODE
1122                                                        HAZ.
1123                 CLEAR G_TABLCTRL120_WA.
1124               ENDIF.
1125
1126   *
1127             WHEN 'ZCAP'.
1128               READ TABLE G_TABLCTRL130_ITAB INTO G_TABLCTRL130_WA
1129                                            WITH KEY SRNO = G_SRNO.
1130               IF SY-SUBRC = 0.
1131   *
1132                 G_TABLCTRL130_WA-MATCODE = WA_SRCHLP-MATNR.
1133   *
1134                 G_TABLCTRL130_WA-DESC_CDCELL = WA_SRCHLP-MAKTX.
1135                 G_TABLCTRL130_WA-HAZ = G_TABCTRL110_WA-COMP_FLG.
1136                 G_TABLCTRL130_WA-COMP_FLG = 'A'.
1137                 MODIFY G_TABLCTRL130_ITAB FROM G_TABLCTRL130_WA
1138                       INDEX SY-TABIX TRANSPORTING FLAG COMP_FLG MATCODE
1139                                                   DESC_CDCELL HAZ.
1140                 CLEAR G_TABLCTRL130_WA.
1141               ENDIF.
1142
1143   *
1144           ENDCASE.
1145   *
1146         ELSE.
1147           MESSAGE I040(ZMM_OTH) WITH 'from Search Help Table'.
1148         ENDIF.
1149       WHEN 'UNDO_CPMC'.
1150         " Begin of <RD1K960036>.
1151   *      CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
1152   *        EXPORTING
1153   *         DEFAULTOPTION         = 'Y'
1154   *          TEXTLINE1            = 'You are about to remove existing'
1155   *          TEXTLINE2            = 'Material Code. Continue?'
1156   *          TITEL                = 'Remove Existing Material Code'
1157   *          START_COLUMN         = 25
1158   *          START_ROW            = 6
1159   **         CANCEL_DISPLAY       = 'X'
1160   *       IMPORTING
1161   *          ANSWER               = l_ans1 .
1162
1163         DATA : L_GET14(1) TYPE C.
1164         CALL FUNCTION 'POPUP_TO_CONFIRM'
1165           EXPORTING
1166             TITLEBAR              = 'Remove Existing Material Code'
1167             TEXT_QUESTION         = 'You are about to remove existing Material Code. Continue?'
1168             DEFAULT_BUTTON        = '1'
1169             DISPLAY_CANCEL_BUTTON = 'X'
1170             START_COLUMN          = 25
1171             START_ROW             = 6
1172           IMPORTING
1173             ANSWER                = L_GET14
1174           EXCEPTIONS
1175             TEXT_NOT_FOUND        = 1
1176             OTHERS                = 2.
1177         IF SY-SUBRC = 0.
1178           CASE L_GET14.
1179             WHEN '1'.
1180               MOVE 'J' TO L_ANS1 .
1181             WHEN '2'.
1182               MOVE 'N' TO L_ANS1 .
1183           ENDCASE.
1184         ENDIF.
1185         " End of <RD1K960036>.
1186         CHECK L_ANS1 = 'J'.
1187         CLEAR L_ANS1.
1188         CASE ZMM_CDHD_ST-MTART.
1189           WHEN 'ZSTO'.
1190             READ TABLE G_TABCTRL110_ITAB INTO G_TABCTRL110_WA
1191                                            WITH KEY FLAG = 'X'.
1192             IF SY-SUBRC = 0 AND G_TABCTRL110_WA-COMP_FLG = 'A'.
1193               G_TABCTRL110_WA-MATCODE = ''.
1194               G_TABCTRL110_WA-FLAG = ''.
1195               G_TABCTRL110_WA-COMP_FLG = G_TABCTRL110_WA-HAZ.
1196               MODIFY G_TABCTRL110_ITAB FROM G_TABCTRL110_WA
1197                     INDEX SY-TABIX TRANSPORTING FLAG COMP_FLG MATCODE.
1198             ELSE.
1199               MESSAGE I040(ZMM_OTH).
1200             ENDIF.
1201   *
1202           WHEN 'ZSPR'.
1203             READ TABLE G_TABLCTRL120_ITAB INTO G_TABLCTRL120_WA
1204                                             WITH KEY FLAG = 'X'.
1205             IF SY-SUBRC = 0 AND G_TABLCTRL120_WA-COMP_FLG = 'A'.
1206               G_TABLCTRL120_WA-MATCODE = ''.
1207               G_TABLCTRL120_WA-FLAG = ''.
1208               G_TABLCTRL120_WA-COMP_FLG = G_TABLCTRL120_WA-HAZ.
1209               MODIFY G_TABLCTRL120_ITAB FROM G_TABLCTRL120_WA
1210                    INDEX SY-TABIX TRANSPORTING FLAG COMP_FLG MATCODE .
1211             ELSE.
1212               MESSAGE I040(ZMM_OTH).
1213             ENDIF.
1214
1215   *
1216           WHEN 'ZCAP'.
1217             READ TABLE G_TABLCTRL130_ITAB INTO G_TABLCTRL130_WA
1218                                          WITH KEY FLAG = 'X'.
1219             IF SY-SUBRC = 0 AND G_TABLCTRL130_WA-COMP_FLG = 'A'.
1220               G_TABLCTRL130_WA-MATCODE  = ''.
1221               G_TABLCTRL130_WA-DESC_CDCELL = ''.
1222               G_TABLCTRL130_WA-FLAG     = ''.
1223               G_TABLCTRL130_WA-COMP_FLG = G_TABLCTRL130_WA-HAZ.
1224               MODIFY G_TABLCTRL130_ITAB FROM G_TABLCTRL130_WA
1225                     INDEX SY-TABIX TRANSPORTING FLAG COMP_FLG MATCODE.
1226             ELSE.
1227               MESSAGE I040(ZMM_OTH).
1228             ENDIF.
1229
1230   *
1231         ENDCASE.
1232   "ADDED BY LIPSY ON 31.08.2012 <RD1K979105> for attaching files and process guides
1233       when 'ATTACH'.
1234       perform attach_files.
1235       CLEAR OKCODE_100.
1236        WHEN 'LIST'.
1237        PERFORM list_files.
1238        CLEAR OKCODE_100.
1239         WHEN 'HELP'.
1240         PERFORM DISP_PROCESS_GUIDE.
1241         CLEAR OKCODE_100.
1242    "END OF ADDITION BY LIPSY ON 31.08.2012
1243     ENDCASE.
1244   *
1245     OK_CODE = SY-UCOMM.
1246     CHECK_CODE = SY-UCOMM.
1247
1248     CASE ZMM_CDHD_ST-MTART.
1249       WHEN 'ZSTO'.
1250         PERFORM USER_OK_TC USING    'TABCTRL110'
1251                                     'G_TABCTRL110_ITAB'
1252                                     'FLAG'
1253                            CHANGING OK_CODE.
1254         CLEAR: OK_CODE, SY-UCOMM.
1255       WHEN 'ZCAP'.
1256         PERFORM USER_OK_TC USING    'TABLCTRL130'
1257                                     'G_TABLCTRL130_ITAB'
1258                                     'FLAG'
1259                            CHANGING OK_CODE.
1260         CLEAR: OK_CODE,SY-UCOMM.
1261       WHEN 'ZDIS'.
1262         PERFORM USER_OK_TC USING    'TABLCTRL140'
1263                                     'G_TABLCTRL140_ITAB'
1264                                     'FLAG'
1265                            CHANGING OK_CODE.
1266         CLEAR: OK_CODE,SY-UCOMM.
1267
1268     ENDCASE.
1269
1270   ENDMODULE.                 " user_command_100  INPUT
1271   *&---------------------------------------------------------------------*
1272   *&      Module  get_cursor  INPUT
1273   *&---------------------------------------------------------------------*
1274   *       text
1275   *----------------------------------------------------------------------*
1276   MODULE GET_CURSOR110 INPUT.
1277     CLEAR TABCTRL110_CHECK_FLAG.
1278     G_LINENO_OLD = G_LINENO.
1279
1280     GET CURSOR FIELD G_CURFIELD.
1281
1282     GET CURSOR FIELD G_CURFIELD110.
1283
1284     GET CURSOR LINE G_CURSOR_LINE.
1285     G_CURR_LINE = G_CURSOR_LINE.
1286     G_CURRENT_LINE  = G_CURSOR_LINE.
1287     G_CURR_LINE = TABCTRL110-TOP_LINE + G_CURSOR_LINE - 1.
1288     G_CURR_LINE_110 = G_CURR_LINE.
1289
1290   ENDMODULE.                 " get_cursor  INPUT
1291
1292   *---------------------------------------------------------------------*
1293   *       MODULE get_cursor120 INPUT                                    *
1294   *---------------------------------------------------------------------*
1295   *       ........                                                      *
1296   *---------------------------------------------------------------------*
1297   MODULE GET_CURSOR120 INPUT.
1298
1299     GET CURSOR FIELD G_CURFIELD.
1300
1301     GET CURSOR FIELD G_CURFIELD120.
1302
1303     GET CURSOR LINE G_CURSOR_LINE.
1304     G_CURR_LINE = G_CURSOR_LINE.
1305     G_CURR_LINE = TABLCTRL120-TOP_LINE + G_CURSOR_LINE - 1.
1306     G_CURR_LINE_120 = G_CURR_LINE .
1307
1308   ENDMODULE.                 " get_cursor120  INPUT
1309
1310   *---------------------------------------------------------------------*
1311   *       MODULE get_cursor130 INPUT                                    *
1312   *---------------------------------------------------------------------*
1313   *       ........                                                      *
1314   *---------------------------------------------------------------------*
1315   MODULE GET_CURSOR130 INPUT.
1316     DATA : L_CUR_FLDVAL(88).
1317     DATA : L_OFFSET TYPE I.
1318   *
1319     GET CURSOR FIELD G_CURFIELD.
1320     GET CURSOR FIELD G_CURFIELD OFFSET L_OFFSET VALUE L_CUR_FLDVAL.
1321
1322     GET CURSOR FIELD G_CURFIELD130.
1323
1324     GET CURSOR LINE G_CURSOR_LINE.
1325     G_CURR_LINE = G_CURSOR_LINE.
1326     G_CURR_LINE = TABLCTRL130-TOP_LINE + G_CURSOR_LINE - 1.
1327     G_CURR_LINE_130 = G_CURR_LINE.
1328
1329   ENDMODULE.                 " get_cursor130  INPUT
1330
1331   *---------------------------------------------------------------------*
1332   *       MODULE get_cursor140 INPUT                                    *
1333   *---------------------------------------------------------------------*
1334   *       ........                                                      *
1335   *---------------------------------------------------------------------*
1336   MODULE GET_CURSOR140 INPUT.
1337
1338     GET CURSOR FIELD G_CURFIELD.
1339
1340     GET CURSOR LINE G_CURSOR_LINE.
1341     G_CURR_LINE = G_CURSOR_LINE.
1342     G_CURR_LINE = TABLCTRL140-TOP_LINE + G_CURSOR_LINE - 1.
1343
1344   ENDMODULE.                 " get_cursor140  INPUT
1345   *&---------------------------------------------------------------------*
1346   *&      Module  USER_COMMAND_0115  INPUT
1347   *&---------------------------------------------------------------------*
1348   *       text
1349   *----------------------------------------------------------------------*
1350   MODULE USER_COMMAND_0115 INPUT.
1351     DATA : FIELD_NAME(20).
1352     DATA : L_ANS.
1353     G_OK_CODE115 = SY-UCOMM.
1354     CASE G_OK_CODE115 .
1355       WHEN  ''.                                               "+
1356         PERFORM GET_ATTRIB_115.
1357         "+
1358       WHEN  'CANC' OR 'RW'.       "+
1359
1360
1361         CLEAR : G_DESC1,
1362                 G_DESC2,
1363                 G_DESC3,
1364                 G_DESC4,
1365                 G_USER_DESC,                                  "=
1366                 G_SCREEN115_1ST,
1367                 G_MATGP.
1368         IF G_OK_CODE110 <> 'PB_AD'.
1369           CLEAR : G_USER_DESC.       "+
1370         ENDIF.
1371         IF G_DESC1 = 'OTHER'.
1372           CLEAR ZMM_CDITEM-DESC1.
1373         ELSEIF G_DESC2 = 'OTHER'.
1374           CLEAR ZMM_CDITEM-DESC2.
1375         ELSEIF G_DESC3 = 'OTHER'.
1376           CLEAR ZMM_CDITEM-DESC3.
1377         ELSEIF G_DESC4 ='OTHER'.
1378           CLEAR ZMM_CDITEM-DESC4.
1379         ENDIF.
1380
1381         IF ZMM_CDITEM-OTH1 = '' AND  G_TABCTRL110_WA-OTH1 = 'X'.
1382           CLEAR G_TABCTRL110_WA-OTH1.
1383           CLEAR G_MATGP.
1384         ENDIF.
1385         IF ZMM_CDITEM-OTH2 = '' AND  G_TABCTRL110_WA-OTH2 = 'X'.
1386           CLEAR G_TABCTRL110_WA-OTH2.
1387         ENDIF.
1388
1389         IF ZMM_CDITEM-OTH3 = '' AND  G_TABCTRL110_WA-OTH3 = 'X'.
1390           CLEAR G_TABCTRL110_WA-OTH3.
1391         ENDIF.
1392
1393         IF ZMM_CDITEM-OTH4 = '' AND  G_TABCTRL110_WA-OTH4 = 'X'.
1394           CLEAR G_TABCTRL110_WA-OTH4.
1395         ENDIF.
1396
1397   *      If g_tabctrl110_wa-desc1 = 'OTHER'.
1398   *        clear :
1399   *               zmm_cditem-desc1,
1400   *               g_tabctrl110_wa-desc1,
1401   *               g_tabctrl110_wa-oth1,
1402   *               g_tabctrl110_wa-oth2,
1403   *               g_tabctrl110_wa-oth3,
1404   *               g_tabctrl110_wa-oth4,
1405   *               g_matgp.
1406   *      Elseif  g_tabctrl110_wa-desc2 = 'OTHER'.
1407   *        clear :
1408   *               zmm_cditem-desc2,
1409   *               g_tabctrl110_wa-desc2,
1410   *               g_tabctrl110_wa-oth2.
1411   *      Elseif  g_tabctrl110_wa-desc3 = 'OTHER'.
1412   *         clear :
1413   *               zmm_cditem-desc3,
1414   *               g_tabctrl110_wa-desc3,
1415   *               g_tabctrl110_wa-oth3.
1416   *      Elseif g_tabctrl110_wa-desc4 = 'OTHER'.
1417   *               Clear :
1418   *               zmm_cditem-desc4,
1419   *               g_tabctrl110_wa-desc4,
1420   *               g_tabctrl110_wa-oth3.
1421   *      Endif.
1422
1423         LEAVE TO SCREEN 0.
1424       WHEN  'A_DESC'.
1425         G_SCREEN115_1ST = 'X'.
1426   *            Perform other_check.   "+
1427       WHEN 'OK115'.
1428         PERFORM CHECK_MODI.
1429         PERFORM CHECK_LENGTH.
1430         G_TABCTRL110_WA-USER_DESC = G_USER_DESC.
1431         CLEAR IST_SPELL_LINE.
1432         IF  G_TABCTRL110_WA-OTH1  = 'X'.
1433           CONCATENATE G_DESC1 G_DESC2
1434            G_DESC3 G_DESC4
1435            G_USER_DESC INTO IST_SPELL_LINE-TDLINE
1436            SEPARATED BY SPACE.
1437           G_TABCTRL110_WA-COMP_FLG = ' M'.
1438
1439         ELSEIF G_TABCTRL110_WA-OTH2 = 'X'.
1440           CONCATENATE G_DESC2 G_DESC3 G_DESC4 G_USER_DESC INTO
1441           IST_SPELL_LINE-TDLINE SEPARATED BY SPACE.
1442           G_TABCTRL110_WA-COMP_FLG = ' M'.
1443
1444         ELSEIF G_TABCTRL110_WA-OTH3 = 'X'.
1445           CONCATENATE G_DESC3 G_DESC4 G_USER_DESC INTO
1446           IST_SPELL_LINE-TDLINE SEPARATED BY SPACE.
1447           G_TABCTRL110_WA-COMP_FLG = ' M'.
1448
1449         ELSEIF G_TABCTRL110_WA-OTH4 = 'X'.
1450           CONCATENATE G_DESC4
1451           G_USER_DESC INTO IST_SPELL_LINE-TDLINE SEPARATED
1452           BY SPACE.
1453           G_TABCTRL110_WA-COMP_FLG = ' M'.
1454
1455         ELSE.
1456           REPLACE 'M' WITH '' INTO G_TABCTRL110_WA-COMP_FLG.
1457           IST_SPELL_LINE-TDLINE = G_USER_DESC.
1458         ENDIF.
1459
1460         APPEND IST_SPELL_LINE.
1461
1462         EXPORT G_USER TO MEMORY ID 'G_USER1' .
1463         CLEAR G_SPELL_ANS.     "+
1464         CALL FUNCTION 'ZSPELL_CHECK'
1465           EXPORTING
1466             SPRACHE = 'EN'
1467           TABLES
1468             ILINE   = IST_SPELL_LINE.
1469
1470         IMPORT CHECKTAB FROM MEMORY ID 'G_CHECKTAB' ACCEPTING TRUNCATION.
1471
1472         IF NOT CHECKTAB[] IS INITIAL.
1473
1474           " Begin of <RD1K960036>.
1475   *        CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
1476   *          EXPORTING
1477   *          TEXTLINE1            = 'There are spelling errors in description(s)'
1478   *
1479   *           TEXTLINE2            = 'Proceed with errors? '
1480   *            TITEL                = 'Spelling Errors'
1481   *                  START_COLUMN         = 25
1482   *                  START_ROW            = 6
1483   *                  CANCEL_DISPLAY       = 'X'
1484   *         IMPORTING
1485   *           ANSWER               = l_ans.
1486   *
1487   *        g_spell_ans = l_ans.
1488
1489           DATA : L_VALUE(1) TYPE C.
1490           CALL FUNCTION 'POPUP_TO_CONFIRM'
1491             EXPORTING
1492              TITLEBAR                    = 'Spelling Errors'
1493               TEXT_QUESTION               = 'There are spelling errors in description(s)'
1494                                             &'Proceed with errors? '
1495              DISPLAY_CANCEL_BUTTON       = 'X'
1496              START_COLUMN                = 25
1497              START_ROW                   = 6
1498            IMPORTING
1499              ANSWER                      = L_VALUE
1500            EXCEPTIONS
1501              TEXT_NOT_FOUND              = 1
1502              OTHERS                      = 2
1503                     .
1504           IF SY-SUBRC = 0.
1505             CASE L_VALUE.
1506               WHEN '1'.
1507                 MOVE 'J' TO L_ANS.
1508               WHEN '2'.
1509                 MOVE 'N' TO L_ANS.
1510             ENDCASE.
1511           ENDIF.
1512
1513           IF L_ANS = 'J'.
1514             CLEAR : G_SCREEN115_1ST,USER_DESC_LEN.
1515             G_OTHER = 'X'.                                    "+
1516             IF G_TABCTRL110_WA-COMP_FLG+1(1) = 'M'.
1517               G_TABCTRL110_WA-COMP_FLG = 'SM'.
1518             ELSE.
1519               G_TABCTRL110_WA-COMP_FLG = 'S'.
1520             ENDIF.
1521   *          g_tabctrl110_wa-rsn   = 'Spelling mistakes/Modifier not in
1522   *                                   Attributes table'.
1523             LEAVE TO SCREEN 0.
1524           ELSE.
1525             G_TABCTRL110_WA-USER_DESC = ''.
1526   *        g_user_desc = ''.
1527   *
1528           ENDIF.
1529         ELSE.
1530           CLEAR : G_SCREEN115_1ST,USER_DESC_LEN.
1531           G_OTHER = 'X'.                                      "+
1532           REPLACE 'S' WITH '' INTO G_TABCTRL110_WA-COMP_FLG.
1533   *        if g_tabctrl110_wa-COMP_FLG+0(1) = 'S'. "remove spell error
1534   *          g_tabctrl110_wa-COMP_FLG = ' M'.
1535   **          g_tabctrl110_wa-rsn   = 'Modifier not in Attributes table'.
1536   *        Endif.
1537
1538           """added by lipsy on 10.09.2012 <RD1K979105> to get pop-up message in sub-attributes
1539
1540        DATA : L_GET1(1) TYPE C.
1541        CALL FUNCTION 'POPUP_TO_CONFIRM'
1542          EXPORTING
1543           TITLEBAR                    = 'proceed '
1544           DIAGNOSE_OBJECT             = 'ZMM_IMAC_TEXT'
1545            TEXT_QUESTION               = 'Do you still want to proceed ?'
1546           DEFAULT_BUTTON              = '2'
1547           START_COLUMN                = 25
1548           START_ROW                   = 6
1549         IMPORTING
1550           ANSWER                      = L_GET1
1551         EXCEPTIONS
1552        TEXT_NOT_FOUND              = 1
1553        OTHERS                      = 2
1554                  .
1555   IF SY-SUBRC = 0.
1556          CASE L_GET1.
1557            WHEN '1'.
1558              MOVE 'J' TO L_ANS.
1559            WHEN '2'.
1560              MOVE 'N' TO L_ANS.
1561          ENDCASE.
1562        ENDIF.
1563
1564               if  l_ans = 'J'.
1565           "end of addition by lipsy on 10.09.2012
1566           LEAVE TO SCREEN 0.
1567         ENDIF. "ADDED BY LIPSY ON 10.09.2012 <RD1K979105> to get pop-up message in sub-attributes
1568
1569         ENDIF.
1570
1571     ENDCASE.
1572   ENDMODULE.                 " USER_COMMAND_0115  INPUT
1573   *&---------------------------------------------------------------------*
1574   *&      Module  TAbctrl110_value  INPUT
1575   *&---------------------------------------------------------------------*
1576   *       text
1577   *----------------------------------------------------------------------*
1578   MODULE TABCTRL110_VALUE INPUT.
1579
1580     GET PARAMETER ID 'ZMATGP' FIELD G_MATGP .
1581     MOVE G_MATGP TO ZMM_CDITEM-MATGP.
1582   ***Addition*************************************=
1583     CLEAR: ZMM_CDITEM-DESC2,ZMM_CDITEM-DESC3,ZMM_CDITEM-DESC4,
1584            ZMM_CDITEM-USER_DESC.
1585   ***End******************************************=
1586
1587   ENDMODULE.                 " TAbctrl110_value  INPUT
1588   *&---------------------------------------------------------------------*
1589   *&      Module  SCREEN100_initialize  INPUT
1590   *&---------------------------------------------------------------------*
1591   *       text
1592   *----------------------------------------------------------------------*
1593   MODULE SCREEN100_INITIALIZE INPUT.
1594     PERFORM CHECK_DELREQ. "Check request deletion
1595     CLEAR G_HD_COPIED.
1596     CLEAR: G_TABCTRL110_COPIED,G_TABLCTRL120_COPIED,G_TABLCTRL130_COPIED.
1597   ****If reqno change from one mat type to another, clear the*************
1598   ****Search help tablecontrol********************************************
1599     REFRESH: IST_SRCHLP.
1600     REFRESH CONTROL 'TABCTRL100' FROM SCREEN '0100'.
1601     CLEAR: FIELD1.
1602   *
1603   ENDMODULE.                 " SCREEN100_initialize  INPUT
1604
1605   *&---------------------------------------------------------------------*
1606   *&      Module  TEXT_CONTROL_UEBERNEHMEN  INPUT
1607   *&---------------------------------------------------------------------*
1608   *       text
1609   *----------------------------------------------------------------------*
1610   MODULE TEXT_CONTROL_UEBERNEHMEN INPUT.
1611     GV_XTHEAD_UPDKZ = 0.
1612
1613     CALL METHOD GV_TEXT_EDITOR->GET_TEXT_AS_STREAM
1614       IMPORTING
1615         TEXT                   = LT_TEXT_TABLE
1616         IS_MODIFIED            = GV_XTHEAD_UPDKZ
1617       EXCEPTIONS
1618         ERROR_DP               = 1
1619         ERROR_CNTL_CALL_METHOD = 2
1620         OTHERS                 = 3.
1621
1622     CALL FUNCTION 'CONVERT_STREAM_TO_ITF_TEXT'
1623       TABLES
1624         TEXT_STREAM = LT_TEXT_TABLE
1625         ITF_TEXT    = TLINETAB.
1626
1627   ENDMODULE.                 " TEXT_CONTROL_UEBERNEHMEN  INPUT
1628
1629   *&---------------------------------------------------------------------*
1630   *&      Module  exit_req  INPUT
1631   *&---------------------------------------------------------------------*
1632   *       text
1633   *----------------------------------------------------------------------*
1634   MODULE EXIT_REQ INPUT.
1635     .
1636     PERFORM EXIT_CONFIRM.
1637   *   .
1638   ENDMODULE.                 " exit_req  INPUT
1639   *&---------------------------------------------------------------------*
1640   *&      Module  get_cursor100  INPUT
1641   *&---------------------------------------------------------------------*
1642   *       text
1643   *----------------------------------------------------------------------*
1644   MODULE GET_CURSOR100 INPUT.
1645
1646     GET CURSOR FIELD G_CURFIELD.
1647
1648     GET CURSOR LINE G_CURSOR_LINE.
1649     G_CURR_LINE = G_CURSOR_LINE.
1650     G_CURR_LINE = TABCTRL100-TOP_LINE + G_CURSOR_LINE - 1.
1651     G_CURR_LINE_100 = G_CURR_LINE.
1652
1653   ENDMODULE.                 " get_cursor100  INPUT
1654   *&      Module  SCREEN100_initialize1  INPUT
1655   *&---------------------------------------------------------------------*
1656   *       text
1657   *----------------------------------------------------------------------*
1658   MODULE SCREEN100_INITIALIZE1 INPUT.
1659
1660     REFRESH IST_SRCHLP.
1661     REFRESH G_TABCTRL110_ITAB.
1662     CLEAR G_TABCTRL110_ITAB.
1663     CLEAR ZMM_CDITEM.
1664     CLEAR G_MAT_FND.
1665     PERFORM CLEAR_SRCHLP_PARMS.
1666
1667   ENDMODULE.                 " SCREEN100_initialize1  INPUT
1668   *&---------------------------------------------------------------------*
1669   *&      Module  longtext  INPUT
1670   *&---------------------------------------------------------------------*
1671   *       text
1672   *----------------------------------------------------------------------*
1673   MODULE LONGTEXT INPUT.
1674     DATA: L_OKDTSP LIKE SY-UCOMM.
1675
1676     L_OKDTSP = SY-UCOMM.
1677     CASE L_OKDTSP.
1678       WHEN 'REQLT'.
1679   *
1680         PERFORM LTXTDTSP.
1681         CLEAR: L_OKDTSP,SY-UCOMM.
1682     ENDCASE.
1683
1684   ENDMODULE.                 " longtext  INPUT
1685   *&---------------------------------------------------------------------*
1686   *&      Module  TEXT_CTRL_UEBERNEHMEN  INPUT
1687   *&---------------------------------------------------------------------*
1688   *       text
1689   *----------------------------------------------------------------------*
1690   MODULE TEXT_CTRL_UEBERNEHMEN INPUT.
1691     GV_XTHEAD_UPDKZ = 0.
1692
1693     CALL METHOD GV_TEXT_EDITOR1->GET_TEXT_AS_STREAM
1694       IMPORTING
1695         TEXT                   = LT_TEXT_TABLE1
1696         IS_MODIFIED            = GV_XTHEAD_UPDKZ
1697       EXCEPTIONS
1698         ERROR_DP               = 1
1699         ERROR_CNTL_CALL_METHOD = 2
1700         OTHERS                 = 3.
1701
1702     CALL FUNCTION 'CONVERT_STREAM_TO_ITF_TEXT'
1703       TABLES
1704         TEXT_STREAM = LT_TEXT_TABLE1
1705         ITF_TEXT    = TLINETAB1.
1706
1707     CALL METHOD GV_TEXT_EDITOR2->GET_TEXT_AS_STREAM
1708       IMPORTING
1709         TEXT                   = LT_TEXT_TABLE2
1710         IS_MODIFIED            = GV_XTHEAD_UPDKZ
1711       EXCEPTIONS
1712         ERROR_DP               = 1
1713         ERROR_CNTL_CALL_METHOD = 2
1714         OTHERS                 = 3.
1715
1716     CALL FUNCTION 'CONVERT_STREAM_TO_ITF_TEXT'
1717       TABLES
1718         TEXT_STREAM = LT_TEXT_TABLE2
1719         ITF_TEXT    = TLINETAB2.
1720
1721
1722   ENDMODULE.                 " TEXT_CTRL_UEBERNEHMEN  INPUT
1723   *&---------------------------------------------------------------------*
1724   *&      Module  TREE_CTRL_EMPFANGEN  INPUT
1725   *&---------------------------------------------------------------------*
1726   *       text
1727   *----------------------------------------------------------------------*
1728   MODULE TREE_CTRL_EMPFANGEN INPUT.
1729
1730   ENDMODULE.                 " TREE_CTRL_EMPFANGEN  INPUT
1731   *&---------------------------------------------------------------------*
1732   *&      Module  OTHER_CHECK  INPUT
1733   *&---------------------------------------------------------------------*
1734   *       text
1735   *----------------------------------------------------------------------*
1736   MODULE OTHER_CHECK INPUT.
1737     PERFORM OTHER_CHECK.
1738   ENDMODULE.                 " OTHER_CHECK  INPUT
1739   *&---------------------------------------------------------------------*
1740   *&      Module  TABCTRL110_check  INPUT
1741   *&---------------------------------------------------------------------*
1742   *       text
1743   *----------------------------------------------------------------------*
1744   MODULE TABCTRL110_CHECK INPUT.
1745
1746     TABCTRL110_CHECK_FLAG = 'X'.
1747   *
1748   ENDMODULE.                 " TABCTRL110_check  INPUT
1749   *&---------------------------------------------------------------------*
1750   *&      Module  TEXT_CTRL_UEBERNEHMEN1  INPUT
1751   *&---------------------------------------------------------------------*
1752   *       text
1753   *----------------------------------------------------------------------*
1754   MODULE TEXT_CTRL_UEBERNEHMEN1 INPUT.
1755     GV_XTHEAD_UPDKZ = 0.
1756
1757     CALL METHOD GV_TEXT_EDITOR1->GET_TEXT_AS_STREAM
1758       IMPORTING
1759         TEXT                   = LT_TEXT_TABLE1
1760         IS_MODIFIED            = GV_XTHEAD_UPDKZ
1761       EXCEPTIONS
1762         ERROR_DP               = 1
1763         ERROR_CNTL_CALL_METHOD = 2
1764         OTHERS                 = 3.
1765
1766     CALL FUNCTION 'CONVERT_STREAM_TO_ITF_TEXT'
1767       TABLES
1768         TEXT_STREAM = LT_TEXT_TABLE1
1769         ITF_TEXT    = TLINETAB1.
1770   *
1771     IF ( G_MODE = 'CRE' ) OR ( G_MODE = 'CHA' ) OR
1772        ( G_MODE = 'REL' ) OR ( G_MODE = 'APR' ) OR
1773        ( G_MODE = 'MRP' ) OR SY-TCODE = 'ZCODG'.
1774
1775       CALL METHOD GV_TEXT_EDITOR2->GET_TEXT_AS_STREAM
1776         IMPORTING
1777           TEXT                   = LT_TEXT_TABLE2
1778           IS_MODIFIED            = GV_XTHEAD_UPDKZ
1779         EXCEPTIONS
1780           ERROR_DP               = 1
1781           ERROR_CNTL_CALL_METHOD = 2
1782           OTHERS                 = 3.
1783
1784       CALL FUNCTION 'CONVERT_STREAM_TO_ITF_TEXT'
1785         TABLES
1786           TEXT_STREAM = LT_TEXT_TABLE2
1787           ITF_TEXT    = TLINETAB2.
1788     ENDIF..
1789   ENDMODULE.                 " TEXT_CTRL_UEBERNEHMEN1  INPUT
1790   *&---------------------------------------------------------------------*
1791   *&      Module  USER_COMMAND_0105  INPUT
1792   *&---------------------------------------------------------------------*
1793   *       text
1794   *----------------------------------------------------------------------*
1795   MODULE USER_COMMAND_0105 INPUT.
1796     DATA: OKCODE105 LIKE SY-UCOMM.
1797
1798     OKCODE105 = SY-UCOMM.
1799
1800     CASE OKCODE105.
1801       WHEN 'OK'.
1802         CLEAR OKCODE105.
1803       WHEN 'CANCEL'.
1804         REFRESH TLINETAB2[].
1805         CLEAR OKCODE105.
1806     ENDCASE.
1807   ENDMODULE.                 " USER_COMMAND_0105  INPUT
1808   *&---------------------------------------------------------------------*
1809   *&      Module  WRITE_MESSAGES  INPUT
1810   *&---------------------------------------------------------------------*
1811   *       text
1812   *----------------------------------------------------------------------*
1813   MODULE WRITE_MESSAGES INPUT.
1814
1815     LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.
1816     SET PF-STATUS SPACE.
1817     LOOP AT IST_MESSAGE INTO WA_MESSAGE.
1818       WRITE: / WA_MESSAGE-SRNO, WA_MESSAGE-MSGTYPE,WA_MESSAGE-MSGCODE,
1819                     WA_MESSAGE-MSGTEXT.
1820     ENDLOOP.
1821
1822   ENDMODULE.                 " WRITE_MESSAGES  INPUT
1823   *&---------------------------------------------------------------------*
1824   *&      Module  USER_COMMAND_0102  INPUT
1825   *&---------------------------------------------------------------------*
1826   *       text
1827   *----------------------------------------------------------------------*
1828   MODULE USER_COMMAND_0102 INPUT.
1829
1830     REFRESH IST_MESSAGE.
1831
1832   ENDMODULE.                 " USER_COMMAND_0102  INPUT
1833
1834   *&---------------------------------------------------------------------*
1835   *&      Module  TABLE110_check_desc1  INPUT
1836   *&---------------------------------------------------------------------*
1837   *       text
1838   *----------------------------------------------------------------------*
1839   MODULE TABLE110_CHECK_DESC1 INPUT.
1840     DATA L_CNT TYPE I.
1841     DATA L_DESC_FIN_LEN TYPE I.
1842     DATA L_DESC(87).
1843   *{   INSERT         OCPK900087                                        2
1844   *DATA: BEGIN OF WA_T604F,
1845   *      LAND1 TYPE LAND1,
1846   *      STEUC TYPE STEUC,
1847   *  END OF WA_T604F,
1848   *  ZMSG110 TYPE STRING.
1849   *}   INSERT
1850
1851     IF ZMM_CDITEM-DESC1 <> 'OTHER' . "+
1852       SELECT SINGLE * FROM ZMM_MODIFIER WHERE DESC1 = ZMM_CDITEM-DESC1.
1853       IF SY-SUBRC <> 0.
1854         MESSAGE E002(ZMM_OTH).
1855       ELSE.
1856   *{   INSERT         OCPK900087                                        1
1857   **DATA: BEGIN OF WA_T604F,
1858   **      LAND1 TYPE LAND1,
1859   **      STEUC TYPE STEUC,
1860   **  END OF WA_T604F,
1861   **  ZMSG110 TYPE STRING.
1862   **LOOP AT G_TABCTRL110_ITAB INTO G_TABCTRL110_WA.
1863   **READ TABLE G_TABCTRL110_ITAB INTO G_TABCTRL110_WA WITH KEY DESC1 = ZMM_CDITEM-DESC1.
1864   **STEUC = G_TABCTRL110_WA-STEUC.
1865   **STEUC = ZMM_CDITEM-STEUC.
1866   * SELECT LAND1 STEUC FROM T604F INTO WA_T604F WHERE LAND1 = 'IN' AND STEUC = ZMM_CDITEM-STEUC.
1867   *ENDSELECT.
1868   *  IF SY-SUBRC <> 0.
1869   **
1870   **IF WA_T604F IS INITIAL.
1871   *
1872   * CONCATENATE ZMM_CDITEM-STEUC ` DOESN'T EXIST IN T604F ` INTO ZMSG110.
1873   * MESSAGE ZMSG110 TYPE 'E'.
1874   **MESSAGE ID '00' TYPE 'E' NUMBER '058' WITH STEUC '' '' 'T604F'.
1875   *
1876   *endif.
1877   *ELSE.
1878
1879   *}   INSERT
1880         SELECT COUNT(*) INTO L_CNT FROM ZMM_MODIFIER
1881                         WHERE DESC1 = ZMM_CDITEM-DESC1.
1882         IF L_CNT > 1.
1883   *
1884           CLEAR MATGRP_CHANGE_FLAG.
1885           PERFORM TABCTRL110_DESC1_CHECK.
1886         ENDIF.
1887       ENDIF.
1888   *
1889     ENDIF.
1890
1891     IF ZMM_CDITEM-USER_DESC <> ''.
1892       CONCATENATE ZMM_CDITEM-DESC1 ZMM_CDITEM-DESC2 ZMM_CDITEM-DESC3
1893                   ZMM_CDITEM-DESC4 INTO G_DESC1_4.
1894       CONDENSE G_DESC1_4.
1895       CONCATENATE G_DESC1_4 ZMM_CDITEM-USER_DESC INTO L_DESC.
1896       IF SY-SUBRC <> 0.
1897         MESSAGE I073(ZMM_OTH).
1898         CLEAR ZMM_CDITEM-USER_DESC.
1899       ENDIF.
1900     ENDIF.
1901   ENDMODULE.                 " TABLE110_check_desc1  INPUT
1902
1903   *&---------------------------------------------------------------------*
1904   *&      Module  TABLE110_check_desc2  INPUT
1905   *&---------------------------------------------------------------------*
1906   *       text
1907   *----------------------------------------------------------------------*
1908   MODULE TABLE110_CHECK_DESC2 INPUT.
1909   *  Data l_desc_fin_len type i.
1910   *  Data l_desc87(87).
1911
1912     IF ZMM_CDITEM-DESC2 <> 'OTHER'.  "+
1913   *   IF zmm_cditem-oth2 <> 'X' .      "+
1914       SELECT SINGLE * FROM ZMM_MODIFIER WHERE DESC1 = ZMM_CDITEM-DESC1 AND
1915                                                  DESC2 = ZMM_CDITEM-DESC2 .
1916
1917       IF SY-SUBRC <> 0.
1918         MESSAGE E002(ZMM_OTH).
1919       ENDIF.
1920     ENDIF.
1921
1922     IF ZMM_CDITEM-USER_DESC <> ''.
1923       CONCATENATE ZMM_CDITEM-DESC1 ZMM_CDITEM-DESC2 ZMM_CDITEM-DESC3
1924                   ZMM_CDITEM-DESC4 INTO G_DESC1_4.
1925       CONDENSE G_DESC1_4.
1926       CONCATENATE G_DESC1_4 ZMM_CDITEM-USER_DESC INTO L_DESC.
1927       IF SY-SUBRC <> 0.
1928         MESSAGE I073(ZMM_OTH).
1929         CLEAR ZMM_CDITEM-USER_DESC.
1930       ENDIF.
1931     ENDIF.
1932
1933   ENDMODULE.                 " TABLE110_check_desc2  INPUT
1934
1935   *&---------------------------------------------------------------------*
1936   *&      Module  TABLE110_check_desc3  INPUT
1937   *&---------------------------------------------------------------------*
1938   *       text
1939   *----------------------------------------------------------------------*
1940   MODULE TABLE110_CHECK_DESC3 INPUT.
1941   *  Data l_desc_fin_len type i.
1942   *  Data l_desc87(87).
1943   *
1944     IF ZMM_CDITEM-DESC3 <> 'OTHER'.
1945       SELECT SINGLE * FROM ZMM_MODIFIER WHERE DESC1 = ZMM_CDITEM-DESC1 AND
1946                                               DESC2 = ZMM_CDITEM-DESC2 AND
1947                                                   DESC3 = ZMM_CDITEM-DESC3.
1948
1949       IF SY-SUBRC <> 0.
1950         MESSAGE E002(ZMM_OTH).
1951       ENDIF.
1952     ENDIF.
1953
1954     IF ZMM_CDITEM-USER_DESC <> ''.
1955       CONCATENATE ZMM_CDITEM-DESC1 ZMM_CDITEM-DESC2 ZMM_CDITEM-DESC3
1956                   ZMM_CDITEM-DESC4 INTO G_DESC1_4.
1957       CONDENSE G_DESC1_4.
1958       CONCATENATE G_DESC1_4 ZMM_CDITEM-USER_DESC INTO L_DESC.
1959       IF SY-SUBRC <> 0.
1960         MESSAGE I073(ZMM_OTH).
1961         CLEAR ZMM_CDITEM-USER_DESC.
1962       ENDIF.
1963     ENDIF.
1964
1965   ENDMODULE.                 " TABLE110_check_desc3  INPUT
1966   *&---------------------------------------------------------------------*
1967   *&      Module  TABLE110_check_desc4  INPUT
1968   *&---------------------------------------------------------------------*
1969   *       text
1970   *----------------------------------------------------------------------*
1971   MODULE TABLE110_CHECK_DESC4 INPUT.
1972   *  Data l_desc_fin_len type i.
1973   *  Data l_desc87(87).
1974
1975     IF ZMM_CDITEM-DESC4 <> 'OTHER'.
1976       SELECT SINGLE * FROM ZMM_MODIFIER WHERE DESC1 = ZMM_CDITEM-DESC1 AND
1977                                               DESC2 = ZMM_CDITEM-DESC2 AND
1978                                               DESC3 = ZMM_CDITEM-DESC3 AND
1979                                                   DESC4 = ZMM_CDITEM-DESC4.
1980
1981       IF SY-SUBRC <> 0.
1982         MESSAGE E002(ZMM_OTH).
1983       ENDIF.
1984     ENDIF.
1985
1986     IF ZMM_CDITEM-USER_DESC <> ''.
1987       CONCATENATE ZMM_CDITEM-DESC1 ZMM_CDITEM-DESC2 ZMM_CDITEM-DESC3
1988                   ZMM_CDITEM-DESC4 INTO G_DESC1_4.
1989       CONDENSE G_DESC1_4.
1990       CONCATENATE G_DESC1_4 ZMM_CDITEM-USER_DESC INTO L_DESC.
1991       IF SY-SUBRC <> 0.
1992         MESSAGE I073(ZMM_OTH).
1993         CLEAR ZMM_CDITEM-USER_DESC.
1994       ENDIF.
1995     ENDIF.
1996
1997   ENDMODULE.                 " TABLE110_check_desc4  INPUT
1998   *&---------------------------------------------------------------------*
1999   *&      Module  USER_COMMAND_0150  INPUT
2000   *&---------------------------------------------------------------------*
2001   *       text
2002   *----------------------------------------------------------------------*
2003   MODULE USER_COMMAND_0150 INPUT.
2004
2005     CASE SY-UCOMM.
2006
2007       WHEN 'OK150'.
2008
2009         LEAVE TO SCREEN 0.
2010
2011       WHEN 'CAN150'.
2012
2013         LEAVE TO SCREEN 0.
2014
2015     ENDCASE.
2016
2017   ENDMODULE.                 " USER_COMMAND_0150  INPUT
2018   *&---------------------------------------------------------------------*
2019   *&      Module  check_plant  INPUT
2020   *&---------------------------------------------------------------------*
2021   *       text
2022   *----------------------------------------------------------------------*
2023   MODULE CHECK_PLANT INPUT.
2024     DATA : L_WERKS LIKE T001W-WERKS.
2025     IF NOT ZMM_CDHD_ST-WERKS IS INITIAL.
2026       SELECT SINGLE WERKS INTO L_WERKS FROM T001W
2027              WHERE WERKS = ZMM_CDHD_ST-WERKS.
2028       IF SY-SUBRC <> 0.
2029         MESSAGE E033(ZMM_OTH).
2030       ENDIF.
2031     ENDIF.
2032   ENDMODULE.                 " check_plant  INPUT
2033   *&---------------------------------------------------------------------*
2034   *&      Module  check_location  INPUT
2035   *&---------------------------------------------------------------------*
2036   *       text
2037   *----------------------------------------------------------------------*
2038   MODULE CHECK_LOCATION INPUT.
2039     DATA : L_LOCID LIKE ZLOCMST-LOCID.
2040     IF NOT ZMM_CDHD_ST-REQLOC IS INITIAL.
2041       SELECT SINGLE LOCID INTO L_LOCID FROM  ZLOCMST
2042              WHERE LOCID = ZMM_CDHD_ST-REQLOC.
2043       IF SY-SUBRC <> 0.
2044         MESSAGE E036(ZMM_OTH).
2045       ENDIF.
2046     ENDIF.
2047
2048   ENDMODULE.                 " check_location  INPUT
2049   *&---------------------------------------------------------------------*
2050   *&      Module  get_matgp_desc  INPUT
2051   *&---------------------------------------------------------------------*
2052   *       text
2053   *----------------------------------------------------------------------*
2054   MODULE GET_MATGP_DESC INPUT.
2055     SELECT SINGLE WGBEZ FROM T023T INTO G_MATGP_DESC WHERE MATKL =
2056     G_MATGP AND SPRAS = SY-LANGU.
2057     IF SY-SUBRC <> 0.
2058       G_MATGP = ''.
2059     ENDIF.
2060
2061   ENDMODULE.                 " get_matgp_desc  INPUT
2062   *&---------------------------------------------------------------------*
2063   *&      Module  check_capcode  INPUT
2064   *&---------------------------------------------------------------------*
2065   *       text
2066   *----------------------------------------------------------------------*
2067   MODULE CHECK_CAPCODE INPUT.
2068
2069     PERFORM VALIDATE_CAPCODE.
2070
2071   ENDMODULE.                 " check_capcode  INPUT
2072   *&---------------------------------------------------------------------*
2073   *&      Module  check_modelno  INPUT
2074   *&---------------------------------------------------------------------*
2075   *       text
2076   *----------------------------------------------------------------------*
2077   MODULE CHECK_MODELNO INPUT.
2078     DATA:  L_STRLEN TYPE I, K TYPE I.
2079     DATA : L_LASTCHAR.
2080     DATA:  L_ANS2,X.
2081     DATA : IST_SVAL_TEMP(30).
2082     DATA : G_TABLCTRL120_WA1 LIKE G_TABLCTRL120_WA.
2083   *  data : g_tablctrl120_wa2 like g_tablctrl120_wa.
2084   *  If sy-tcode <> 'ZCODG'.
2085     REFRESH IST_MDL. CLEAR IST_MDL.
2086
2087     IF ZMM_CDITEM-MDLNO <> 'OTHER'. "and zmm_cditem-oth_mdl = ''.
2088       SELECT SINGLE * FROM ZMM_MDL
2089              WHERE MDLNO = ZMM_CDITEM-MDLNO.
2090       IF SY-SUBRC <> 0.
2091         MOVE G_TABLCTRL120_WA TO G_TABLCTRL120_WA1.
2092
2093         READ TABLE G_TABLCTRL120_ITAB INTO G_TABLCTRL120_WA1 WITH KEY
2094         MDLNO = ZMM_CDITEM-MDLNO.
2095
2096         IF SY-SUBRC = 0.
2097           IF G_TABLCTRL120_WA1-OTH_MDL = 'X'.
2098             ZMM_CDITEM-OTH_MDL = G_TABLCTRL120_WA1-OTH_MDL.
2099   ***          if zmm_cditem-comp_flg ca 'L'.  " to prevent LL
2100   ***          Else.
2101   ***           replace ' ' with 'L' into zmm_cditem-comp_flg.
2102   ***          Endif.
2103           ENDIF.
2104         ELSE.
2105           MESSAGE E044(ZMM_OTH).
2106   ***        move ' L' to zmm_cditem-comp_flg.
2107         ENDIF.
2108       ELSE.
2109         REPLACE 'L' WITH  '' INTO ZMM_CDITEM-COMP_FLG.
2110         MOVE '' TO ZMM_CDITEM-OTH_MDL.
2111       ENDIF.
2112     ELSE.
2113       REFRESH IST_SVAL.
2114       CLEAR   IST_SVAL.
2115       CLEAR   IST_SVAL_TEMP.
2116
2117       MOVE : 'ZMM_CDITEM'  TO IST_SVAL-TABNAME,
2118              'MDLNO'       TO IST_SVAL-FIELDNAME,
2119              'X'           TO IST_SVAL-FIELD_OBL.
2120       APPEND IST_SVAL.
2121       CALL FUNCTION 'POPUP_GET_VALUES'
2122         EXPORTING
2123   *       NO_VALUE_CHECK        = ' '
2124           POPUP_TITLE           = 'Enter Model No.'
2125           START_COLUMN          = '5'
2126           START_ROW             = '5'
2127         TABLES
2128           FIELDS                = IST_SVAL.
2129
2130       IF SY-SUBRC <> 0.
2131   * MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
2132   *         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
2133       ENDIF.
2134       TRANSLATE IST_SVAL-VALUE TO UPPER CASE.
2135       READ TABLE IST_SVAL INDEX 1.
2136       ZMM_MDL-MDLNO = IST_SVAL-VALUE.  "#EC CI_FLDEXT_OK[2215424]
2137
2138       IF NOT IST_SVAL-VALUE IS INITIAL.
2139   *      read table ist_sval index 1.
2140         L_STRLEN = STRLEN( IST_SVAL-VALUE ).
2141         IST_SVAL_ORG = IST_SVAL-VALUE.
2142
2143         TRANSLATE  IST_SVAL-VALUE USING
2144   '.%-%,%+%*%_%^%?%"%!% %$%:%;%`%"%/%\%<%>%=%§%#%~%(%)%|%<%>%@%{%}%[%]%~%'
2145     .
2146         IST_SVAL-VALUE = IST_SVAL-VALUE+0(L_STRLEN).
2147         L_STRLEN = L_STRLEN + 1.
2148         K = 0.
2149         DO L_STRLEN TIMES.
2150           X =  IST_SVAL-VALUE+K(1).
2151           IF X <> '%'.
2152             CONCATENATE IST_SVAL_TEMP '%' X INTO IST_SVAL_TEMP.
2153             CONDENSE IST_SVAL_TEMP NO-GAPS.
2154           ENDIF.
2155           K = K + 1 .
2156           X = ''.
2157         ENDDO.
2158         IST_SVAL-VALUE = IST_SVAL_TEMP.
2159         SELECT * FROM ZMM_MDL INTO TABLE IST_MDL WHERE MDLNO LIKE
2160         IST_SVAL-VALUE ORDER BY PRIMARY KEY.
2161         IF SY-SUBRC <> 0.
2162   *        zmm_cditem-mdlno = zmm_mdl-mdlno.  "* <<07.10.05>>
2163   *  Added on  07-10-05 to remove all special chars at the end except
2164   *  ',",),#,+
2165           L_STRLEN = STRLEN( ZMM_MDL-MDLNO ).
2166           L_STRLEN = L_STRLEN - 1.
2167           L_LASTCHAR = ZMM_MDL-MDLNO+L_STRLEN(1).  "#EC CI_FLDEXT_OK[2215424]
2168           IF L_LASTCHAR = '''' OR
2169              L_LASTCHAR = '"' OR
2170              L_LASTCHAR = ')' OR
2171              L_LASTCHAR = '#' OR
2172              L_LASTCHAR = '+' .
2173             ZMM_CDITEM-MDLNO = ZMM_MDL-MDLNO.
2174           ELSE.
2175             IF L_LASTCHAR BETWEEN '0' AND '9' OR
2176                L_LASTCHAR BETWEEN 'A' AND 'Z'.
2177               ZMM_CDITEM-MDLNO = ZMM_MDL-MDLNO.
2178             ELSE.
2179               ZMM_CDITEM-MDLNO = ZMM_MDL-MDLNO+0(L_STRLEN).  "#EC CI_FLDEXT_OK[2215424]
2180             ENDIF.
2181           ENDIF.
2182   ** End add 07-10-05
2183
2184           ZMM_CDITEM-OTH_MDL = 'X'.
2185   ***        IF zmm_cditem-comp_flg+0(1) ='S'.
2186   ***          zmm_cditem-comp_flg = 'SL'.
2187   ***        Else.
2188   ***          zmm_cditem-comp_flg = ' L'.
2189   ***        Endif.
2190
2191         ELSE.
2192
2193           TRANSLATE IST_SVAL-VALUE USING '% '.
2194           CONDENSE IST_SVAL-VALUE NO-GAPS.
2195
2196           LOOP AT IST_MDL.
2197             TRANSLATE  IST_MDL-MDLNO USING
2198    '. - , + * _ ^ ? " ! $ : ; ` " / \ < > = § # ~ ( ) | < > @ { } [ ] ~ '.
2199             CONDENSE IST_MDL-MDLNO NO-GAPS.
2200             IF IST_MDL-MDLNO <> IST_SVAL-VALUE.
2201               DELETE IST_MDL INDEX SY-TABIX.
2202             ENDIF.
2203           ENDLOOP.
2204           IF NOT IST_MDL[] IS INITIAL.
2205             CALL SCREEN 104 STARTING AT 40 2
2206                          ENDING   AT 80 18.
2207           ELSE.
2208             ZMM_CDITEM-MDLNO = IST_SVAL-VALUE.
2209             ZMM_CDITEM-OTH_MDL = 'X'.
2210   ***          replace ' ' with 'L' into zmm_cditem-comp_flg.
2211           ENDIF.
2212           IF ZMM_CDITEM-MDLNO = 'OTHER'. " In case OTHER is entered in
2213   *                                        popup
2214             ZMM_CDITEM-MDLNO = ''.
2215             ZMM_CDITEM-OTH_MDL = ''.
2216
2217           ENDIF.
2218         ENDIF.
2219       ELSE.
2220         ZMM_CDITEM-MDLNO = ''.
2221
2222       ENDIF.
2223     ENDIF.
2224
2225     IF ZMM_CDITEM-MDLNO = ''.
2226       MESSAGE E044(ZMM_OTH).
2227     ELSE.
2228   * Added on 26-10-2005 to remove LL etc problem in comp_flg field
2229       IF ZMM_CDITEM-OTH_MDL = 'X'.
2230         IF ZMM_CDITEM-COMP_FLG+0(1) ='S'.
2231           ZMM_CDITEM-COMP_FLG = 'SL'.
2232         ELSE.
2233           ZMM_CDITEM-COMP_FLG = ' L'.
2234         ENDIF.
2235       ELSE.
2236         IF ZMM_CDITEM-COMP_FLG+0(1) ='S'.
2237           ZMM_CDITEM-COMP_FLG = 'S'.
2238         ELSE.
2239           ZMM_CDITEM-COMP_FLG = ''.
2240         ENDIF.
2241       ENDIF.
2242     ENDIF.
2243   *Endif.
2244   ENDMODULE.                 " check_modelno  INPUT
2245   *&---------------------------------------------------------------------*
2246   *&      Module  check_matgp  INPUT
2247   *&---------------------------------------------------------------------*
2248   *       text
2249   *----------------------------------------------------------------------*
2250   MODULE CHECK_MATGP INPUT.
2251   * Check only stores group is selected
2252     IF G_TABCTRL110_WA-DESC1 = 'OTHER' OR G_TABCTRL110_WA-OTH1 = 'X'.
2253       IF G_MATGP GT '16' OR G_MATGP LT '07'.
2254         MESSAGE E049(ZMM_OTH).
2255       ENDIF.
2256     ENDIF.
2257
2258   ENDMODULE.                 " check_matgp  INPUT
2259   *&---------------------------------------------------------------------*
2260   *&      Module  check_other  INPUT
2261   *&---------------------------------------------------------------------*
2262   *       text
2263   *----------------------------------------------------------------------*
2264   MODULE CHECK_OTHER INPUT.
2265   *
2266     IF ZMM_CDITEM-OTH1 = 'X' OR
2267        ZMM_CDITEM-OTH2 = 'X' OR
2268        ZMM_CDITEM-OTH3 = 'X' OR
2269        ZMM_CDITEM-OTH4 = 'X'.
2270
2271     ELSE.
2272       REPLACE 'M' WITH '' INTO ZMM_CDITEM-COMP_FLG.
2273     ENDIF.
2274   ENDMODULE.                 " check_other  INPUT
2275   *&---------------------------------------------------------------------*
2276   *&      Module  get_cursor_fld  INPUT
2277   *&---------------------------------------------------------------------*
2278   *       text
2279   *----------------------------------------------------------------------*
2280   MODULE GET_CURSOR_FLD INPUT.
2281     DATA : L_CDITEMC LIKE ZMM_CDITEM.
2282     CLEAR : L_CDITEMC.
2283   **
2284     GET CURSOR FIELD G_CURSOR_FLD130.
2285     IF ZMM_CDITEM-DESC_FIN IS INITIAL.
2286       MESSAGE I007(ZMM_OTH).
2287       SET CURSOR FIELD 'ZMM_CDITEM-DESC_FIN'.
2288     ENDIF.
2289   **
2290     IF G_MODE = 'CRE' OR G_MODE = 'CHA'.
2291       SELECT * INTO L_CDITEMC FROM ZMM_CDITEM UP TO 1 ROWS
2292    WHERE DESC_FIN = ZMM_CDITEM-DESC_FIN
2293    ORDER BY PRIMARY KEY .
2294    ENDSELECT.
2295       IF SY-SUBRC = 0.
2296         IF G_MODE = 'CHA'.
2297           IF L_CDITEMC-REQNO <> ZMM_CDHD_ST-REQNO.
2298             MESSAGE I074(ZMM_OTH)
2299             WITH L_CDITEMC-REQNO L_CDITEMC-SRNO.
2300           ENDIF.
2301         ELSE.
2302           MESSAGE I074(ZMM_OTH)
2303           WITH L_CDITEMC-REQNO L_CDITEMC-SRNO.
2304         ENDIF.
2305       ENDIF.
2306     ENDIF.
2307   ENDMODULE.                 " get_cursor_fld  INPUT
2308   *&---------------------------------------------------------------------*
2309   *&      Module  Check_characterstics_MATCATG  INPUT
2310   *&---------------------------------------------------------------------*
2311   *       text
2312   *----------------------------------------------------------------------*
2313   MODULE CHECK_CHARACTERSTICS_MATCATG INPUT.
2314   *
2315     DATA : L_ATWRT LIKE CAWN-ATWRT.
2316   *
2317     SELECT SINGLE ATWRT FROM ZMMCDCAP_USRGP_V INTO L_ATWRT WHERE ATWRT =
2318       ZMM_CDITEM-MATCATG.
2319     IF SY-SUBRC <> 0.
2320       MESSAGE E051(ZMM_OTH).
2321     ENDIF.
2322
2323   ENDMODULE.                 " Check_characterstics_MATCATG  INPUT
2324   *&---------------------------------------------------------------------*
2325   *&      Module  Check_characterstics_MATLOC  INPUT
2326   *&---------------------------------------------------------------------*
2327   *       text
2328   *----------------------------------------------------------------------*
2329   MODULE CHECK_CHARACTERSTICS_MATLOC INPUT.
2330   *
2331     SELECT SINGLE ATWRT FROM ZMMCDCAP_LOC_V INTO L_ATWRT WHERE ATWRT =
2332       ZMM_CDITEM-MATLOC.
2333     IF SY-SUBRC <> 0 .
2334       MESSAGE E051(ZMM_OTH).
2335     ENDIF.
2336   ENDMODULE.                 " Check_characterstics_MATLOC  INPUT
2337   *&---------------------------------------------------------------------*
2338   *&      Module  Check_characterstics_SPAGRP  INPUT
2339   *&---------------------------------------------------------------------*
2340   *       text
2341   *----------------------------------------------------------------------*
2342   MODULE CHECK_CHARACTERSTICS_SPAGRP INPUT.
2343     SELECT SINGLE ATWRT FROM ZMMCDCAP_SPRGP_V INTO L_ATWRT WHERE ATWRT =
2344       ZMM_CDITEM-SPA_GRP.  "#EC CI_FLDEXT_OK[2215424]
2345     IF SY-SUBRC <> 0.
2346       MESSAGE E051(ZMM_OTH).
2347     ENDIF.
2348
2349   ENDMODULE.                 " Check_characterstics_SPAGRP  INPUT
2350   *&---------------------------------------------------------------------*
2351   *&      Module  Check_WRKNG_LIFE  INPUT
2352   *&---------------------------------------------------------------------*
2353   *       text
2354   *----------------------------------------------------------------------*
2355   MODULE CHECK_WRKNG_LIFE INPUT.
2356   *
2357     TRANSLATE ZMM_CDITEM-WRKNG_LIFE TO UPPER CASE.
2358     CONDENSE ZMM_CDITEM-WRKNG_LIFE NO-GAPS.
2359     IF ZMM_CDITEM-WRKNG_LIFE
2360     CA '.-'',#~`!@#$%^&*()<>/:;"ABCDEFGHIJKLMNOPQRSTUVWXYZ'.
2361       MESSAGE E058(ZMM_OTH).
2362     ENDIF.
2363   ENDMODULE.                 " Check_WRKNG_LIFE  INPUT
2364   *&---------------------------------------------------------------------*
2365   *&      Module  CHECK_TEL  INPUT
2366   *&---------------------------------------------------------------------*
2367   *       text
2368   *----------------------------------------------------------------------*
2369   MODULE CHECK_TEL INPUT.
2370     DATA : TEL_LEN TYPE I.
2371     TEL_LEN = STRLEN( ZMM_CDHD_ST-TEL ).
2372     IF  ZMM_CDHD_ST-TEL CN ' 0123456789-'.
2373       MESSAGE E059(ZMM_OTH).
2374     ELSE.
2375       IF TEL_LEN < 7.
2376         MESSAGE E060(ZMM_OTH).
2377       ENDIF.
2378     ENDIF.
2379   ENDMODULE.                 " CHECK_TEL  INPUT
2380   *&---------------------------------------------------------------------*
2381   *&      Module  Check_werks  INPUT
2382   *&---------------------------------------------------------------------*
2383   *       text
2384   *----------------------------------------------------------------------*
2385   MODULE CHECK_WERKS INPUT.
2386     AUTHORITY-CHECK OBJECT 'M_BANF_WRK'
2387                ID 'WERKS' FIELD ZMM_CDHD_ST-WERKS
2388                ID 'ACTVT'  FIELD '01'.
2389     IF SY-SUBRC <> 0.
2390       G_CHANGE_AUTH = 'X'.
2391       MESSAGE E062(ZMM_OTH) WITH ZMM_CDHD_ST-WERKS.
2392
2393     ENDIF.
2394
2395   ENDMODULE.                 " Check_werks  INPUT
2396   *&---------------------------------------------------------------------*
2397   *&      Module  CHeck_OEM  INPUT
2398   *&---------------------------------------------------------------------*
2399   *       text
2400   *----------------------------------------------------------------------*
2401   MODULE CHECK_OEM INPUT.
2402     DATA : L_MANUF_TY1 TYPE LFA1-J_1KFTBUS.
2403     DATA : L_MANUF_DEL TYPE LFA1-LOEVM.
2404
2405     SELECT SINGLE J_1KFTBUS LOEVM FROM LFA1 INTO (L_MANUF_TY1,L_MANUF_DEL)
2406                WHERE LIFNR =  ZMM_CDITEM-MANU.
2407
2408     IF L_MANUF_DEL = 'X'.
2409
2410       MESSAGE E082(ZMM_OTH) WITH ZMM_CDITEM-MANU.
2411
2412     ELSE.
2413
2414       IF SY-SUBRC = 0 AND L_MANUF_TY1 <> 'OEM'.
2415
2416         " Begin of <RD1K960036>.
2417
2418   *      CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
2419   *        EXPORTING
2420   *          DEFAULTOPTION        = 'N'
2421   *          TEXTLINE1            = 'This vendor is not OEM'
2422   *         TEXTLINE2            =  'Continue? '
2423   *          TITEL                = 'Vendor'
2424   **             START_COLUMN         = 25
2425   **             START_ROW            = 6
2426   **             CANCEL_DISPLAY       = 'X'
2427   *       IMPORTING
2428   *         ANSWER               = l_ans
2429
2430         DATA : L_GET15(1) TYPE C.
2431         CALL FUNCTION 'POPUP_TO_CONFIRM'
2432           EXPORTING
2433             TITLEBAR              = 'Vendor'
2434             TEXT_QUESTION         = 'This vendor is not OEM Continue?'
2435             DEFAULT_BUTTON        = '2'
2436             DISPLAY_CANCEL_BUTTON = 'X'
2437             START_COLUMN          = 25
2438             START_ROW             = 6
2439           IMPORTING
2440             ANSWER                = L_GET15
2441           EXCEPTIONS
2442             TEXT_NOT_FOUND        = 1
2443             OTHERS                = 2.
2444         IF SY-SUBRC = 0.
2445           CASE L_GET15.
2446             WHEN '1'.
2447               MOVE 'J' TO L_ANS.
2448             WHEN '2'.
2449               MOVE 'N' TO L_ANS.
2450           ENDCASE.
2451         ENDIF.
2452         " End of <RD1K960036>.
2453         .
2454         IF L_ANS <> 'J'.
2455           ZMM_CDITEM-MANU = ''.
2456         ENDIF.
2457       ENDIF.
2458
2459     ENDIF.
2460
2461   ENDMODULE.                 " CHeck_OEM  INPUT
2462   *&---------------------------------------------------------------------*
2463   *&      Module  Desc_fin_change  INPUT
2464   *&---------------------------------------------------------------------*
2465   *       text
2466   *----------------------------------------------------------------------*
2467   MODULE DESC_FIN_CHANGE INPUT.
2468   *  Data:l_cditemd  like  zmm_cditem.
2469   * changing hits for existing descriptions.
2470     IF G_MODE = 'CHA' AND OKCODE_100 = 'SAV' AND ZMM_CDITEM-MATCOST <> 0.
2471       G_DESC_FIN_CHNG = 'X'.
2472       PERFORM GET_SRCHLP_ZCAP.
2473       DESCRIBE TABLE IST_SRCHLP LINES G_MAT_FND.
2474       ZMM_CDITEM-MAT_FND = G_MAT_FND.
2475       CLEAR G_DESC_FIN_CHNG.
2476     ENDIF.
2477
2478   ENDMODULE.                 " Desc_fin_change  INPUT
2479   *&---------------------------------------------------------------------*
2480   *&      Module  POV_CAP_CODE  INPUT
2481   *&---------------------------------------------------------------------*
2482   *       text
2483   *----------------------------------------------------------------------*
2484   MODULE POV_CAP_CODE INPUT.
2485
2486     DATA : L_CSP_CODE LIKE ZMM_CDITEM-CAP_CODE.
2487
2488     DATA  :  IST_RETURN_TAB1 LIKE STANDARD TABLE OF DDSHRETVAL
2489                                                  WITH  HEADER LINE.
2490
2491     TABLES : CABN, AUSP.
2492     TYPES  : BEGIN OF MOD_MARA,
2493                 MATNR LIKE MARA-MATNR,
2494                 MTART LIKE MARA-MTART,
2495                 MAKTX LIKE MAKT-MAKTX,
2496              END OF MOD_MARA.
2497     DATA   : IST_MOD_MARA TYPE TABLE OF MOD_MARA WITH HEADER LINE.
2498     DATA   : IST_MARA LIKE TABLE OF MARA WITH HEADER LINE.
2499     DATA   : WA_MARA LIKE LINE OF IST_MARA.
2500     DATA   : L_MAKTX LIKE MAKT-MAKTX.
2501
2502     SELECT * FROM CABN UP TO 1 ROWS
2503    WHERE ATNAM = 'Z_ONGC_GROUP_OF_SPARES'
2504    ORDER BY PRIMARY KEY .
2505    ENDSELECT.
2506
2507     SELECT A~MATNR A~MTART C~MAKTX  INTO CORRESPONDING FIELDS OF TABLE
2508                         IST_MOD_MARA
2509                         FROM MARA AS A  INNER JOIN AUSP AS B
2510                         ON A~MATNR = B~OBJEK
2511                         INNER JOIN MAKT AS C
2512                         ON A~MATNR = C~MATNR
2513                         WHERE B~ATINN = CABN-ATINN AND
2514                         B~ATWRT <> ''.
2515
2516     CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
2517       EXPORTING
2518         RETFIELD        = 'MATNR'
2519         DYNPPROG        = SY-CPROG
2520         DYNPNR          = SY-DYNNR
2521         DYNPROFIELD     = 'ZMM_CDITEM-CAP_CODE'
2522         VALUE_ORG       = 'S'
2523       TABLES
2524         VALUE_TAB       = IST_MOD_MARA
2525         RETURN_TAB      = IST_RETURN_TAB1
2526       EXCEPTIONS
2527         PARAMETER_ERROR = 1
2528         NO_VALUES_FOUND = 2
2529         OTHERS          = 3.
2530
2531     IF SY-SUBRC <> 0.
2532       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
2533               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
2534
2535     ENDIF.
2536
2537     REFRESH:IST_MOD_MARA,IST_RETURN_TAB1.
2538     FREE : IST_MOD_MARA,IST_RETURN_TAB1.
2539
2540   ENDMODULE.                 " POV_CAP_CODE  INPUT
2541   *&---------------------------------------------------------------------*
2542   *&      Module  check_uom  INPUT
2543   *&---------------------------------------------------------------------*
2544   *       text
2545   *----------------------------------------------------------------------*
2546   MODULE CHECK_UOM INPUT.
2547     DATA: L_CDITEMS LIKE ZMM_CDITEM.
2548     IF OKCODE_100 = 'SAV' AND ZMM_CDITEM-UOM IS INITIAL.
2549       MESSAGE E071(ZMM_OTH).
2550     ENDIF.
2551
2552   ***To check the duplicate entry in other request.
2553     IF G_MODE = 'CRE' OR G_MODE = 'CHA'.
2554       SELECT * INTO L_CDITEMS FROM ZMM_CDITEM UP TO 1 ROWS
2555    WHERE DESC_FIN = ZMM_CDITEM-DESC_FIN AND UOM = ZMM_CDITEM-UOM
2556    ORDER BY PRIMARY KEY .
2557    ENDSELECT.
2558       IF SY-SUBRC = 0.
2559         IF G_MODE = 'CHA'.
2560           IF L_CDITEMS-REQNO <> ZMM_CDHD_ST-REQNO.
2561             MESSAGE I074(ZMM_OTH)
2562             WITH L_CDITEMS-REQNO L_CDITEMS-SRNO.
2563           ENDIF.
2564         ELSE.
2565           MESSAGE I074(ZMM_OTH)
2566           WITH L_CDITEMS-REQNO L_CDITEMS-SRNO.
2567         ENDIF.
2568       ENDIF.
2569     ENDIF.
2570
2571
2572   ENDMODULE.                 " check_uom  INPUT
2573   *&---------------------------------------------------------------------*
2574   *&      Module  check_duplicate_rec  INPUT
2575   *&---------------------------------------------------------------------*
2576   *       text
2577   *----------------------------------------------------------------------*
2578   MODULE CHECK_DUPLICATE_REC INPUT.
2579
2580     DATA:L_130W TYPE T_TABLCTRL130.
2581     DATA:L_110 TYPE TABLE OF T_TABCTRL110,
2582          L_120 TYPE TABLE OF T_TABLCTRL120,
2583          L_130 TYPE TABLE OF T_TABLCTRL130,
2584          L_140 TYPE TABLE OF T_TABLCTRL140,
2585          L_CDITEM   LIKE  ZMM_CDITEM.
2586     CLEAR: L_110 ,L_120,L_130,L_140,G_DESC_FIN.
2587     REFRESH: L_110,L_120,L_130,L_140.
2588   **Addition-Duplicate Check*******************=
2589     IF G_MODE = 'CHA' OR G_MODE = 'CRE'.
2590       CASE ZMM_CDHD_ST-MTART.
2591         WHEN 'ZSTO'.
2592   *{   INSERT         OCPK900087                                        1
2593   *DATA: BEGIN OF WA_T604F,
2594   *      LAND1 TYPE LAND1,
2595   *      STEUC TYPE STEUC,
2596   *  END OF WA_T604F,
2597   *  ZMSG110 TYPE STRING.
2598   *LOOP AT G_TABCTRL110_ITAB INTO G_TABCTRL110_WA.
2599   *
2600   * SELECT LAND1 STEUC FROM T604F INTO WA_T604F WHERE LAND1 = 'IN' AND STEUC = G_TABCTRL110_WA-STEUC.
2601   *ENDSELECT.
2602   *
2603   *IF WA_T604F IS INITIAL.
2604   *
2605   * CONCATENATE G_TABCTRL110_WA-STEUC ` DOESN'T EXIST IN T604F ` INTO ZMSG110.
2606   * MESSAGE ZMSG110 TYPE 'E'.
2607   *
2608   *ENDIF.
2609   *
2610   *CLEAR: G_TABCTRL110_WA, WA_T604F.
2611   *ENDLOOP.
2612
2613
2614
2615   *}   INSERT
2616           APPEND LINES OF G_TABCTRL110_ITAB TO L_110.
2617           SORT L_110 BY DESC_FIN UOM ASCENDING.
2618           DELETE ADJACENT DUPLICATES FROM L_110 COMPARING DESC_FIN UOM.
2619           IF SY-SUBRC = 0.
2620             MESSAGE I072(ZMM_OTH).
2621             IF OKCODE_100 = 'SAV'.
2622               CLEAR OKCODE_100.
2623             ENDIF.
2624           ENDIF.
2625         WHEN 'ZSPR'.
2626           APPEND LINES OF G_TABLCTRL120_ITAB TO L_120.
2627           SORT L_120 BY DESC_FIN UOM CAP_CODE MDLNO MANU ASCENDING.
2628           DELETE ADJACENT DUPLICATES FROM L_120
2629                  COMPARING PARTNO DESC_FIN UOM CAP_CODE MDLNO MANU.
2630           IF SY-SUBRC = 0.
2631             MESSAGE I072(ZMM_OTH).
2632             IF OKCODE_100 = 'SAV'.
2633               CLEAR OKCODE_100.
2634             ENDIF.
2635           ENDIF.
2636         WHEN 'ZCAP'.
2637           APPEND LINES OF G_TABLCTRL130_ITAB TO L_130.
2638           SORT L_130 BY DESC_FIN ASCENDING.
2639           DELETE ADJACENT DUPLICATES FROM L_130 COMPARING DESC_FIN.
2640           IF SY-SUBRC = 0.
2641             MESSAGE I072(ZMM_OTH).
2642             IF OKCODE_100 = 'SAV'.
2643               CLEAR OKCODE_100.
2644             ENDIF.
2645           ENDIF.
2646         WHEN 'ZDIS'.
2647           APPEND LINES OF G_TABLCTRL140_ITAB TO L_140.
2648           SORT L_140 BY DESC_FIN ASCENDING.
2649           DELETE ADJACENT DUPLICATES FROM L_140 COMPARING DESC_FIN.
2650           IF SY-SUBRC = 0.
2651             MESSAGE I072(ZMM_OTH).
2652             IF OKCODE_100 = 'SAV'.
2653               CLEAR OKCODE_100.
2654             ENDIF.
2655           ENDIF.
2656       ENDCASE.
2657     ENDIF.
2658   **End****************************************=
2659   ENDMODULE.                    "check_duplicate_rec INPUT
2660   *&---------------------------------------------------------------------*
2661   *&      Module  duplicate_inothreq  INPUT
2662   *&---------------------------------------------------------------------*
2663   *       text
2664   *----------------------------------------------------------------------*
2665   MODULE DUPLICATE_INOTHREQ INPUT.
2666     DATA: L_CDITEMP LIKE ZMM_CDITEM.
2667     IF G_MODE = 'CRE' OR G_MODE = 'CHA'.
2668       SELECT * INTO L_CDITEMP FROM ZMM_CDITEM UP TO 1 ROWS
2669    WHERE PARTNO = ZMM_CDITEM-PARTNO AND DESC_FIN = ZMM_CDITEM-DESC_FIN AND UOM = ZMM_CDITEM-UOM AND CAP_CODE = ZMM_CDITEM-CAP_CODE AND MDLNO = ZMM_CDITEM-MDLNO AND MANU = ZMM_CDITEM-MANU
2670    ORDER BY PRIMARY KEY .
2671    ENDSELECT.
2672       IF SY-SUBRC = 0.
2673         IF G_MODE = 'CHA'.
2674           IF L_CDITEMP-REQNO <> ZMM_CDHD_ST-REQNO.
2675             MESSAGE I074(ZMM_OTH)
2676             WITH L_CDITEMP-REQNO L_CDITEMP-SRNO.
2677           ENDIF.
2678         ELSE.
2679           MESSAGE I074(ZMM_OTH)
2680           WITH L_CDITEMP-REQNO L_CDITEMP-SRNO.
2681         ENDIF.
2682       ENDIF.
2683     ENDIF.
2684   ENDMODULE.                 " duplicate_inothreq  INPUT
2685   *&---------------------------------------------------------------------*
2686   *&      Module  check_other1  INPUT
2687   *&---------------------------------------------------------------------*
2688   *       text
2689   *----------------------------------------------------------------------*
2690   MODULE CHECK_OTHER1 INPUT.
2691     IF OKCODE_100 = 'SAV'.
2692       IF ZMM_CDITEM-DESC1 = 'OTHER'.
2693         CLEAR OKCODE_100.
2694         MESSAGE E029(ZMM_OTH).
2695       ENDIF.
2696     ENDIF.
2697   ENDMODULE.                 " check_other1  INPUT
2698   *&---------------------------------------------------------------------*
2699   *&      Module  check_other2  INPUT
2700   *&---------------------------------------------------------------------*
2701   *       text
2702   *----------------------------------------------------------------------*
2703
2704   MODULE CHECK_OTHER2 INPUT.
2705     IF OKCODE_100 = 'SAV'.
2706       IF ZMM_CDITEM-DESC2 = 'OTHER'.
2707         CLEAR OKCODE_100.
2708         MESSAGE E029(ZMM_OTH).
2709       ENDIF.
2710     ENDIF.
2711   ENDMODULE.                 " check_other1  INPUT
2712   *&---------------------------------------------------------------------*
2713   *&      Module  check_other3 INPUT
2714   *&---------------------------------------------------------------------*
2715   *       text
2716   *----------------------------------------------------------------------*
2717
2718   MODULE CHECK_OTHER3 INPUT.
2719     IF OKCODE_100 = 'SAV'.
2720       IF ZMM_CDITEM-DESC3 = 'OTHER'.
2721         CLEAR OKCODE_100.
2722         MESSAGE E029(ZMM_OTH).
2723       ENDIF.
2724     ENDIF.
2725   ENDMODULE.                 " check_other1  INPUT
2726   *&---------------------------------------------------------------------*
2727   *&      Module  check_other4 INPUT
2728   *&---------------------------------------------------------------------*
2729   *       text
2730   *----------------------------------------------------------------------*
2731
2732   MODULE CHECK_OTHER4 INPUT.
2733     IF OKCODE_100 = 'SAV'.
2734       IF ZMM_CDITEM-DESC4 = 'OTHER'.
2735         CLEAR OKCODE_100.
2736         MESSAGE E029(ZMM_OTH).
2737       ENDIF.
2738     ENDIF.
2739   ENDMODULE.                 " check_other4 INPUT
2740   *&---------------------------------------------------------------------*
2741   *&      Module  CHECK_REQUEST_FILE  INPUT
2742   *&---------------------------------------------------------------------*
2743   *       text
2744   *----------------------------------------------------------------------*
2745   MODULE CHECK_REQUEST_FILE INPUT.
2746
2747   if OKCODE_100 = 'ATTACH' OR OKCODE_100 = 'LIST' .
2748   if ZMM_CDHD_ST-REQNO is INITIAL.
2749    MESSAGE 'ENTER REQUEST NO' TYPE 'E'.
2750   endif.
2751   ENDIF.
2752   ENDMODULE.                 " CHECK_REQUEST_FILE  INPUT
2753   *&---------------------------------------------------------------------*
2754   *&      Module  GET_VENDOR_DETAILS  INPUT
2755   *&---------------------------------------------------------------------*
2756   *       text
2757   *----------------------------------------------------------------------*
2758   MODULE GET_VENDOR_DETAILS INPUT.
2759
2760   *added by lipsy on 0n 05.09.2012 <RD1K979105> to get vendor details on double click
2761
2762    get CURSOR LINE g_curr_line_vendor.
2763
2764    read TABLE G_TABLCTRL120_ITAB INTO G_TABLCTRL120_WA with KEY srno = g_curr_line_vendor.
2765   CLEAR:g_fname,s_lifnr.
2766   if sy-subrc = 0.
2767    GET CURSOR FIELD g_fname .
2768       IF g_fname = 'ZMM_CDITEM-MANU'  AND
2769       SY-UCOMM = 'DBLCLK' .
2770    if count = 0.
2771    SUBMIT ZMM_VEN_SHLP  AND RETURN WITH s_lifnr eq G_TABLCTRL120_WA-manu .
2772   if  sy-subrc  =  0.
2773   count = count + 1.
2774    endif.
2775      ENDIF.
2776      endif.
2777
2778      endif.
2779   ENDMODULE.                 " GET_VENDOR_DETAILS  INPUT
2780   *&---------------------------------------------------------------------*
2781   *&      Module  ERNAM_FLD_DCLK  INPUT
2782   *&---------------------------------------------------------------------*
2783   *       text
2784   *----------------------------------------------------------------------*
2785   MODULE ERNAM_FLD_DCLK INPUT.
2786
2787   DATA l_user_dblclk  LIKE soud3.
2788     CLEAR : g_fname,l_user_dblclk.
2789
2790   if sy-ucomm = 'DBLCLK'.
2791     GET CURSOR FIELD g_fname.
2792     CASE g_fname.
2793       WHEN 'ZMM_CDHD_ST-APPCPF'.
2794         l_user_dblclk = ZMM_CDHD_ST-APPCPF.
2795         PERFORM details_ondblclk.
2796
2797       WHEN 'ZMM_CDHD_ST-REQCPF'.
2798     l_user_dblclk = ZMM_CDHD_ST-REQCPF.
2799       PERFORM details_ondblclk.
2800     ENDCASE.
2801
2802     ENDIF.
2803
2804   ENDMODULE.                 " ERNAM_FLD_DCLK  INPUT
2805
2806   *{   INSERT         OCPK900087                                        1
2807   *&---------------------------------------------------------------------*
2808   *&      Module  TABLE110_CHECK_STEUC  INPUT
2809   *&---------------------------------------------------------------------*
2810   *       text
2811   *----------------------------------------------------------------------*
2812   MODULE TABLE110_CHECK_STEUC INPUT.
2813     DATA: HSN TYPE T604F-STEUC.
2814
2815           IF ZMM_CDITEM-STEUC IS NOT INITIAL.
2816             CLEAR : HSN .
2817             SELECT SINGLE STEUC
2818               INTO HSN
2819               FROM T604F
2820               WHERE STEUC = ZMM_CDITEM-STEUC.
2821               IF HSN  IS INITIAL.
2822                 MESSAGE E503(ZMM_OTH).
2823
2824
2825               ENDIF.
2826
2827
2828
2829           ENDIF.
2830
2831
2832
2833   ENDMODULE.
2834   *}   INSERT
*--- End of MZMMCODREQI01 - 2834 lines ---

----------------------------------------------------------------------------------------------------
Include          MZMMCODREQF01                             Level 1    Page 5
Object           SAPMZMMCODREQ                             Lines 9400
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:59
----------------------------------------------------------------------------------------------------
1      *INCLUDE MZMMCODREQF01 .
2      *----------------------------------------------------------------------*
3      *   INCLUDE TABLECONTROL_FORMS                                         *
4      *----------------------------------------------------------------------*
5      ************************************************************************
6      *  Date            Transport      USERID        Description
7      * 30/09/2008      <RD1K960036>    SAB_SUMODH
8      *
9      *1) Obsolete FM Ws_Download Replaced With 'GUI_DOWNLOAD'.
10     *2) Obsolete FM Ws_Upload Replaced With 'GUI_UPLOAD'.
11     *3) Obsolete FM POPUP_TO_CONFIRM_STEP Replaced With 'POPUP_TO_CONFIRM'.
12     *4) Obsolete FM WS_FILENAME_GET Replaced with  Method .
13     ************************************************************************
14     *&---------------------------------------------------------------------*
15     *&      Form  USER_OK_TC                                               *
16     *&---------------------------------------------------------------------*
17      FORM USER_OK_TC USING    P_TC_NAME TYPE DYNFNAM
18                               P_TABLE_NAME
19                               P_MARK_NAME
20                      CHANGING P_OK      LIKE SY-UCOMM.
21
22     *-BEGIN OF LOCAL DATA--------------------------------------------------*
23        DATA: L_OK              TYPE SY-UCOMM,
24              L_OFFSET          TYPE I.
25        DATA L_110ITAB TYPE TABLE OF T_TABCTRL110.
26        DATA X(80).
27     *-END OF LOCAL DATA----------------------------------------------------*
28
29     * Table control specific operations                                    *
30     *   evaluate TC name and operations                                    *
31        SEARCH P_OK FOR P_TC_NAME.
32        IF SY-SUBRC <> 0.
33          EXIT.
34        ENDIF.
35        L_OFFSET = STRLEN( P_TC_NAME ) + 1.
36        L_OK = P_OK+L_OFFSET.
37     * execute general and TC specific operations                           *
38        CASE L_OK.
39          WHEN 'INSR'.                      "insert row
40            PERFORM CHECK_TABROWS.
41            IF G_MODE = 'CRE'.
42              IF G_INSRFLG = 'Y'.
43                PERFORM FCODE_INSERT_ROW
44                 USING P_TC_NAME P_TABLE_NAME.
45                CLEAR P_OK.
46              ENDIF.
47            ELSE.
48              PERFORM FCODE_INSERT_ROW
49               USING P_TC_NAME P_TABLE_NAME.
50              CLEAR: P_OK,L_OK,SY-UCOMM.
51            ENDIF.
52          WHEN 'DELE'.                      "delete row
53     *
54            CASE ZMM_CDHD_ST-MTART.
55              WHEN 'ZSTO'.
56                PERFORM ADD_DELITEM110.
57              WHEN 'ZSPR'.
58                PERFORM ADD_DELITEM120.
59              WHEN 'ZCAP'.
60                PERFORM ADD_DELITEM130.
61              WHEN 'ZDIS'.
62                PERFORM ADD_DELITEM140.
63            ENDCASE.
64     *
65            IF G_DELFLAG <> 'N'.
66     *
67              PERFORM CONFIRM_DELETION.
68              IF G_CONFDEL = 'J'.
69                PERFORM FCODE_DELETE_ROW USING    P_TC_NAME
70                                                 P_TABLE_NAME
71                                                 P_MARK_NAME.
72                CLEAR G_CONFDEL.
73              ENDIF.
74            ENDIF.
75            CLEAR G_DELFLAG.
76            CLEAR P_OK.
77
78          WHEN 'P--' OR                     "top of list
79               'P-'  OR                     "previous page
80               'P+'  OR                     "next page
81               'P++'.                       "bottom of list
82            PERFORM COMPUTE_SCROLLING_IN_TC USING P_TC_NAME
83                                                  L_OK.
84            CLEAR P_OK.
85     *
86          WHEN 'MARK'.                      "mark all filled lines
87            PERFORM FCODE_TC_MARK_LINES USING P_TC_NAME
88                                              P_TABLE_NAME
89                                              P_MARK_NAME   .
90            CLEAR P_OK.
91
92          WHEN 'DMRK'.                      "demark all filled lines
93            PERFORM FCODE_TC_DEMARK_LINES USING P_TC_NAME
94                                                P_TABLE_NAME
95                                                P_MARK_NAME .
96            CLEAR P_OK.
97
98     *
99          WHEN 'FILTER'.
100           READ  TABLE TABCTRL110-COLS WITH  KEY SELECTED = 'X' INTO
101               WA_TABCTRL110_COLS .
102           IF SY-SUBRC <> 0.
103             MESSAGE I030(ZMM_OTH).
104           ENDIF.
105           G_FILNAME = WA_TABCTRL110_COLS-SCREEN-NAME.
106           CALL SCREEN 150 STARTING AT 20 05 ENDING AT 80 10.
107    *
108           CLEAR: P_OK,WA_TABLCTRL120_COLS.
109
110         WHEN 'SORTU'.
111           G_ORDER = 'ASCENDING'.
112           CASE ZMM_CDHD_ST-MTART.
113             WHEN 'ZSTO'.
114               PERFORM SORT_STO USING G_ORDER.
115               CLEAR: P_OK,WA_TABCTRL110_COLS.
116             WHEN 'ZSPR'.
117               PERFORM SORT_SPR USING G_ORDER.
118               CLEAR: P_OK,WA_TABLCTRL120_COLS.
119             WHEN 'ZCAP'.
120               PERFORM SORT_CAP USING G_ORDER.
121               CLEAR: P_OK,WA_TABLCTRL130_COLS.
122             WHEN 'ZDIS'.
123               PERFORM SORT_DIS USING G_ORDER.
124               CLEAR: P_OK,WA_TABLCTRL140_COLS.
125           ENDCASE.
126         WHEN 'SORTD'.
127           G_ORDER = 'DESCENDING'.
128           CASE ZMM_CDHD_ST-MTART.
129             WHEN 'ZSTO'.
130               PERFORM SORT_STO USING G_ORDER.
131               CLEAR: P_OK,WA_TABCTRL110_COLS.
132             WHEN 'ZSPR'.
133               PERFORM SORT_SPR USING G_ORDER.
134               CLEAR: P_OK,WA_TABLCTRL120_COLS.
135             WHEN 'ZCAP'.
136               PERFORM SORT_CAP USING G_ORDER.
137               CLEAR: P_OK,WA_TABLCTRL130_COLS.
138             WHEN 'ZDIS'.
139               PERFORM SORT_DIS USING G_ORDER.
140               CLEAR: P_OK,WA_TABLCTRL140_COLS.
141           ENDCASE.
142       ENDCASE.
143
144     ENDFORM.                              " USER_OK_TC
145
146    *&---------------------------------------------------------------------*
147    *&      Form  FCODE_INSERT_ROW                                         *
148    *&---------------------------------------------------------------------*
149     FORM FCODE_INSERT_ROW
150                   USING    P_TC_NAME           TYPE DYNFNAM
151                            P_TABLE_NAME             .
152
153    *-BEGIN OF LOCAL DATA--------------------------------------------------*
154       DATA: L_ITAB110 LIKE G_TABCTRL110_WA OCCURS 0,
155             L_ITAB120 LIKE G_TABLCTRL120_WA OCCURS 0,
156             L_ITAB130 LIKE G_TABLCTRL130_WA OCCURS 0,
157             L_ITAB140 LIKE G_TABLCTRL140_WA OCCURS 0.
158
159       DATA L_LINES_NAME       LIKE FELD-NAME.
160       DATA L_SELLINE          LIKE SY-STEPL.
161       DATA L_LASTLINE         TYPE I.
162       DATA L_LINE             TYPE I.
163       DATA L_TABLE_NAME       LIKE FELD-NAME.
164       FIELD-SYMBOLS <TC>                 TYPE CXTAB_CONTROL.
165       FIELD-SYMBOLS <TABLE>              TYPE STANDARD TABLE.
166       FIELD-SYMBOLS <LINES>  TYPE I.                           "#EC *
167    **-END OF LOCAL
168    *
169       CLEAR L_SELLINE.
170       REFRESH:L_ITAB110,L_ITAB120,L_ITAB130,L_ITAB140.
171       ASSIGN (P_TC_NAME) TO <TC>.
172       CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
173       ASSIGN (L_TABLE_NAME) TO <TABLE>.
174    *
175       APPEND INITIAL LINE TO <TABLE>.
176       <TC>-LINES = <TC>-LINES + 1.
177
178     ENDFORM.                              " FCODE_INSERT_ROW
179
180    *&---------------------------------------------------------------------*
181    *&      Form  FCODE_DELETE_ROW                                         *
182    *&---------------------------------------------------------------------*
183     FORM FCODE_DELETE_ROW
184                   USING    P_TC_NAME           TYPE DYNFNAM
185                            P_TABLE_NAME
186                            P_MARK_NAME   .
187
188    *-BEGIN OF LOCAL DATA--------------------------------------------------*
189       DATA L_TABLE_NAME       LIKE FELD-NAME.
190
191       FIELD-SYMBOLS <TC>         TYPE CXTAB_CONTROL.
192       FIELD-SYMBOLS <TABLE>      TYPE STANDARD TABLE.
193       FIELD-SYMBOLS <WA>.
194       FIELD-SYMBOLS <MARK_FIELD>.
195    *-END OF LOCAL DATA----------------------------------------------------*
196
197       ASSIGN (P_TC_NAME) TO <TC>.
198
199    * get the table, which belongs to the tc                               *
200       CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
201       ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline
202
203    * delete marked lines                                                  *
204       DESCRIBE TABLE <TABLE> LINES <TC>-LINES.
205
206       LOOP AT <TABLE> ASSIGNING <WA>.
207
208    *   access to the component 'FLAG' of the table header                 *
209         ASSIGN COMPONENT P_MARK_NAME OF STRUCTURE <WA> TO <MARK_FIELD>.
210
211         IF <MARK_FIELD> = 'X'.
212           DELETE <TABLE> INDEX SYST-TABIX.
213           IF SY-SUBRC = 0.
214             <TC>-LINES = <TC>-LINES - 1.
215           ENDIF.
216         ENDIF.
217       ENDLOOP.
218
219     ENDFORM.                              " FCODE_DELETE_ROW
220
221    *&---------------------------------------------------------------------*
222    *&      Form  COMPUTE_SCROLLING_IN_TC
223    *&---------------------------------------------------------------------*
224    *       text
225    *----------------------------------------------------------------------*
226    *      -->P_TC_NAME  name of tablecontrol
227    *      -->P_OK       ok code
228    *----------------------------------------------------------------------*
229     FORM COMPUTE_SCROLLING_IN_TC USING    P_TC_NAME
230                                           P_OK.
231    *-BEGIN OF LOCAL DATA--------------------------------------------------*
232       DATA L_TC_NEW_TOP_LINE     TYPE I.
233       DATA L_TC_NAME             LIKE FELD-NAME.
234       DATA L_TC_LINES_NAME       LIKE FELD-NAME.
235       DATA L_TC_FIELD_NAME       LIKE FELD-NAME.
236
237       FIELD-SYMBOLS <TC>         TYPE CXTAB_CONTROL.
238       FIELD-SYMBOLS <LINES>      TYPE I.
239       DATA L_TC_ITAB_NAME        LIKE FELD-NAME.
240       DATA L_TOTLN               TYPE I.
241    *-END OF LOCAL DATA----------------------------------------------------*
242
243       ASSIGN (P_TC_NAME) TO <TC>.
244    * get looplines of TableControl
245       CONCATENATE 'G_' P_TC_NAME '_LINES' INTO L_TC_LINES_NAME.
246       ASSIGN (L_TC_LINES_NAME) TO <LINES>.
247
248
249    * is no line filled?                                                   *
250       IF <TC>-LINES = 0.
251    *   yes, ...                                                           *
252         L_TC_NEW_TOP_LINE = 1.
253       ELSE.
254    *   no, ...
255    ****Addition
256         CASE ZMM_CDHD_ST-MTART.
257           WHEN 'ZSTO'.
258             DESCRIBE TABLE G_TABCTRL110_ITAB LINES L_TOTLN.
259           WHEN 'ZSPR'.
260             DESCRIBE TABLE G_TABLCTRL120_ITAB LINES L_TOTLN.
261           WHEN 'ZCAP'.
262             DESCRIBE TABLE G_TABLCTRL130_ITAB LINES L_TOTLN.
263           WHEN 'ZDIS'.
264             DESCRIBE TABLE G_TABLCTRL140_ITAB LINES L_TOTLN.
265         ENDCASE.
266    ****End
267         IF <TC> = TABCTRL100.
268           CALL FUNCTION 'SCROLLING_IN_TABLE'
269                EXPORTING
270                     ENTRY_ACT             = <TC>-TOP_LINE
271                     ENTRY_FROM            = 1
272                     ENTRY_TO              = <TC>-LINES
273    *               ENTRY_TO              = l_totln
274    *               LAST_PAGE_FULL        = ''
275                     LAST_PAGE_FULL        = 'X'
276                     LOOPS                 = <LINES>
277                     OK_CODE               = P_OK
278                     OVERLAPPING           = 'X'
279                IMPORTING
280                     ENTRY_NEW             = L_TC_NEW_TOP_LINE
281                EXCEPTIONS
282    *              NO_ENTRY_OR_PAGE_ACT  = 01
283    *              NO_ENTRY_TO           = 02
284    *              NO_OK_CODE_OR_PAGE_GO = 03
285                     OTHERS                = 0.
286         ELSE.
287           CALL FUNCTION 'SCROLLING_IN_TABLE'
288                EXPORTING
289                     ENTRY_ACT             = <TC>-TOP_LINE
290                     ENTRY_FROM            = 1
291    *               ENTRY_TO              = <TC>-LINES
292                     ENTRY_TO              = L_TOTLN
293                     LAST_PAGE_FULL        = ''
294    *               LAST_PAGE_FULL        = 'X'
295                     LOOPS                 = <LINES>
296                     OK_CODE               = P_OK
297                     OVERLAPPING           = 'X'
298                IMPORTING
299                     ENTRY_NEW             = L_TC_NEW_TOP_LINE
300                EXCEPTIONS
301    *              NO_ENTRY_OR_PAGE_ACT  = 01
302    *              NO_ENTRY_TO           = 02
303    *              NO_OK_CODE_OR_PAGE_GO = 03
304                     OTHERS                = 0.
305         ENDIF.
306       ENDIF.
307
308    * get actual tc and column                                             *
309       GET CURSOR FIELD L_TC_FIELD_NAME
310                  AREA  L_TC_NAME.
311
312       IF SYST-SUBRC = 0.
313         IF L_TC_NAME = P_TC_NAME.
314    *     set actual column                                                *
315           SET CURSOR FIELD L_TC_FIELD_NAME LINE 1.
316         ENDIF.
317       ENDIF.
318
319    * set the new top line                                                 *
320       <TC>-TOP_LINE = L_TC_NEW_TOP_LINE.
321
322
323     ENDFORM.                              " COMPUTE_SCROLLING_IN_TC
324
325    *&---------------------------------------------------------------------*
326    *&      Form  FCODE_TC_MARK_LINES
327    *&---------------------------------------------------------------------*
328    *       marks all TableControl lines
329    *----------------------------------------------------------------------*
330    *      -->P_TC_NAME  name of tablecontrol
331    *----------------------------------------------------------------------*
332     FORM FCODE_TC_MARK_LINES USING P_TC_NAME
333                                    P_TABLE_NAME
334                                    P_MARK_NAME.
335    *-BEGIN OF LOCAL DATA--------------------------------------------------*
336       DATA L_TABLE_NAME       LIKE FELD-NAME.
337
338       FIELD-SYMBOLS <TC>         TYPE CXTAB_CONTROL.
339       FIELD-SYMBOLS <TABLE>      TYPE STANDARD TABLE.
340       FIELD-SYMBOLS <WA>.
341       FIELD-SYMBOLS <MARK_FIELD>.
342    *-END OF LOCAL DATA----------------------------------------------------*
343
344       ASSIGN (P_TC_NAME) TO <TC>.
345
346    * get the table, which belongs to the tc                               *
347       CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
348       ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline
349
350    * mark all filled lines                                                *
351       LOOP AT <TABLE> ASSIGNING <WA>.
352
353    *   access to the component 'FLAG' of the table header                 *
354         ASSIGN COMPONENT P_MARK_NAME OF STRUCTURE <WA> TO <MARK_FIELD>.
355
356         <MARK_FIELD> = 'X'.
357       ENDLOOP.
358     ENDFORM.                                          "fcode_tc_mark_lines
359
360    *&---------------------------------------------------------------------*
361    *&      Form  FCODE_TC_DEMARK_LINES
362    *&---------------------------------------------------------------------*
363    *       demarks all TableControl lines
364    *----------------------------------------------------------------------*
365    *      -->P_TC_NAME  name of tablecontrol
366    *----------------------------------------------------------------------*
367     FORM FCODE_TC_DEMARK_LINES USING P_TC_NAME
368                                      P_TABLE_NAME
369                                      P_MARK_NAME .
370    *-BEGIN OF LOCAL DATA--------------------------------------------------*
371       DATA L_TABLE_NAME       LIKE FELD-NAME.
372
373       FIELD-SYMBOLS <TC>         TYPE CXTAB_CONTROL.
374       FIELD-SYMBOLS <TABLE>      TYPE STANDARD TABLE.
375       FIELD-SYMBOLS <WA>.
376       FIELD-SYMBOLS <MARK_FIELD>.
377    *-END OF LOCAL DATA----------------------------------------------------*
378
379       ASSIGN (P_TC_NAME) TO <TC>.
380
381    * get the table, which belongs to the tc                               *
382       CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
383       ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline
384
385    * demark all filled lines                                              *
386       LOOP AT <TABLE> ASSIGNING <WA>.
387
388    *   access to the component 'FLAG' of the table header                 *
389         ASSIGN COMPONENT P_MARK_NAME OF STRUCTURE <WA> TO <MARK_FIELD>.
390
391         <MARK_FIELD> = SPACE.
392       ENDLOOP.
393     ENDFORM.                                          "fcode_tc_mark_lines
394    *&---------------------------------------------------------------------*
395    *&      Form  fill_sttab
396    *&---------------------------------------------------------------------*
397    *       text
398    *----------------------------------------------------------------------*
399    *  -->  p1        text
400    *  <--  p2        text
401    *----------------------------------------------------------------------*
402     FORM FILL_STTAB.
403       REFRESH IT_TAB1.
404       IF SY-TCODE <> 'ZCODG'.
405         IF  DYNNR IS INITIAL.
406           MOVE 'CR_MATCODE' TO WA_TAB-FCODE.
407           APPEND WA_TAB TO IT_TAB1.
408           MOVE 'CHECK' TO WA_TAB-FCODE.
409           APPEND WA_TAB TO IT_TAB1.
410
411          "START OF ADDITION BY LIPSY <RD1K979105> for attaching files
412         MOVE 'ATTACH' TO WA_TAB-FCODE.
413         APPEND WA_TAB TO IT_TAB1.
414         MOVE 'LIST' TO WA_TAB-FCODE.
415         APPEND WA_TAB TO IT_TAB1.
416         "END OF ADDITION BY LIPSY ON 31.08.2012
417
418         ELSE.
419           MOVE 'CR_MATCODE' TO WA_TAB-FCODE.
420           APPEND WA_TAB TO IT_TAB1.
421          "START OF ADDITION BY LIPSY <RD1K979105> for attaching files
422           IF SY-UCOMM = 'HELP'.
423         MOVE 'ATTACH' TO WA_TAB-FCODE.
424         APPEND WA_TAB TO IT_TAB1.
425         MOVE 'LIST' TO WA_TAB-FCODE.
426         APPEND WA_TAB TO IT_TAB1.
427         MOVE 'CHECK' TO WA_TAB-FCODE.
428         APPEND WA_TAB TO IT_TAB1.
429         ENDIF.
430         "END OF ADDITION BY LIPSY ON 31.08.2012
431
432         ENDIF.
433       ENDIF.
434
435    "START OF COMMENT BY LIPSY ON 31.08.2012 <RD1K979105> for attaching files
436    *   IF G_MODE =  'CRE' OR
437    *      G_MODE =  'CHA' OR
438    *      G_MODE =  'REL' OR
439    *      G_MODE =  'APR' .
440    *     MOVE 'CREATE' TO WA_TAB-FCODE.
441    *     APPEND WA_TAB TO IT_TAB1.
442    *     MOVE 'CHANGE' TO WA_TAB-FCODE.
443    *     APPEND WA_TAB TO IT_TAB1.
444    *     MOVE 'DELETE' TO WA_TAB-FCODE.
445    *     APPEND WA_TAB TO IT_TAB1.
446    *     MOVE 'DISPLAY' TO WA_TAB-FCODE.
447    *     APPEND WA_TAB TO IT_TAB1.
448    *     MOVE 'RELEASE' TO WA_TAB-FCODE.
449    *     APPEND WA_TAB TO IT_TAB1.
450    *     MOVE 'CR_MATCODE' TO WA_TAB-FCODE.
451    *     APPEND WA_TAB TO IT_TAB1.
452    *     MOVE 'APPROVE' TO WA_TAB-FCODE.
453    *     APPEND WA_TAB TO IT_TAB1.
454    "END OF COMMENT BY LIPSY ON 31.08.2012
455
456         "START OF ADDITION BY LIPSY <RD1K979105> for attaching files
457          IF G_MODE =  'CRE' .
458         MOVE 'CREATE' TO WA_TAB-FCODE.
459         APPEND WA_TAB TO IT_TAB1.
460         MOVE 'CHANGE' TO WA_TAB-FCODE.
461         APPEND WA_TAB TO IT_TAB1.
462         MOVE 'DELETE' TO WA_TAB-FCODE.
463         APPEND WA_TAB TO IT_TAB1.
464         MOVE 'DISPLAY' TO WA_TAB-FCODE.
465         APPEND WA_TAB TO IT_TAB1.
466         MOVE 'RELEASE' TO WA_TAB-FCODE.
467         APPEND WA_TAB TO IT_TAB1.
468         MOVE 'CR_MATCODE' TO WA_TAB-FCODE.
469         APPEND WA_TAB TO IT_TAB1.
470         MOVE 'APPROVE' TO WA_TAB-FCODE.
471         APPEND WA_TAB TO IT_TAB1.
472         MOVE 'ATTACH' TO WA_TAB-FCODE.
473         APPEND WA_TAB TO IT_TAB1.
474         MOVE 'LIST' TO WA_TAB-FCODE.
475         APPEND WA_TAB TO IT_TAB1.
476         MOVE 'HELP' TO WA_TAB-FCODE.
477         APPEND WA_TAB TO IT_TAB1.
478
479         ELSEIF  G_MODE =  'REL' OR
480          G_MODE =  'APR' .
481         MOVE 'CREATE' TO WA_TAB-FCODE.
482         APPEND WA_TAB TO IT_TAB1.
483         MOVE 'CHANGE' TO WA_TAB-FCODE.
484         APPEND WA_TAB TO IT_TAB1.
485         MOVE 'DELETE' TO WA_TAB-FCODE.
486         APPEND WA_TAB TO IT_TAB1.
487         MOVE 'DISPLAY' TO WA_TAB-FCODE.
488         APPEND WA_TAB TO IT_TAB1.
489         MOVE 'RELEASE' TO WA_TAB-FCODE.
490         APPEND WA_TAB TO IT_TAB1.
491         MOVE 'CR_MATCODE' TO WA_TAB-FCODE.
492         APPEND WA_TAB TO IT_TAB1.
493         MOVE 'APPROVE' TO WA_TAB-FCODE.
494         APPEND WA_TAB TO IT_TAB1.
495         MOVE 'ATTACH' TO WA_TAB-FCODE.
496         APPEND WA_TAB TO IT_TAB1.
497         MOVE 'HELP' TO WA_TAB-FCODE.
498         APPEND WA_TAB TO IT_TAB1.
499
500
501       ELSEIF   G_MODE =  'CHA' .
502         MOVE 'CREATE' TO WA_TAB-FCODE.
503         APPEND WA_TAB TO IT_TAB1.
504         MOVE 'CHANGE' TO WA_TAB-FCODE.
505         APPEND WA_TAB TO IT_TAB1.
506         MOVE 'DELETE' TO WA_TAB-FCODE.
507         APPEND WA_TAB TO IT_TAB1.
508         MOVE 'DISPLAY' TO WA_TAB-FCODE.
509         APPEND WA_TAB TO IT_TAB1.
510         MOVE 'RELEASE' TO WA_TAB-FCODE.
511         APPEND WA_TAB TO IT_TAB1.
512         MOVE 'CR_MATCODE' TO WA_TAB-FCODE.
513         APPEND WA_TAB TO IT_TAB1.
514         MOVE 'APPROVE' TO WA_TAB-FCODE.
515         APPEND WA_TAB TO IT_TAB1.
516         MOVE 'HELP' TO WA_TAB-FCODE.
517         APPEND WA_TAB TO IT_TAB1.
518
519
520
521
522         "END OF ADDITION BY LIPSY
523    *   elseif g_mode = 'CHA' .
524    *     move 'CREATE' to wa_tab-fcode.
525    *     append wa_tab to it_tab1.
526    *     move 'CHANGE' to wa_tab-fcode.
527    *     append wa_tab to it_tab1.
528    *     move 'DELETE' to wa_tab-fcode.
529    *     append wa_tab to it_tab1.
530    *     move 'DISPLAY' to wa_tab-fcode.
531    *     append wa_tab to it_tab1.
532    *     move 'RELEASE' to wa_tab-fcode.
533    *     append wa_tab to it_tab1.
534    *     move 'APPROVE' to wa_tab-fcode.
535    *     append wa_tab to it_tab1.
536    *     move 'CR_MATCODE' to wa_tab-fcode.
537    *     append wa_tab to it_tab1.
538    *     if dynnr = '0101'.
539    *       move 'CR_MATCODE' to wa_tab-fcode.
540    *       append wa_tab to it_tab1.
541    *       move 'CHECK' to wa_tab-fcode.
542    *       append wa_tab to it_tab1.
543    *     endif.
544    "start of comment by lipsy on 17.10.2012 <RD1K979105> for attaching files
545    *   ELSEIF G_MODE = 'DEL' OR
546    *          G_MODE = 'DIS'.
547     "end of comment by lipsy on 17.10.2012
548
549      "start of addition by lipsy on 17.10.2012 <RD1K979105> for attaching files
550
551          ELSEIF G_MODE = 'DEL' .
552
553      "end of addition by lipsy on 17.10.2012
554         MOVE 'CREATE' TO WA_TAB-FCODE.
555         APPEND WA_TAB TO IT_TAB1.
556         MOVE 'CHANGE' TO WA_TAB-FCODE.
557         APPEND WA_TAB TO IT_TAB1.
558         MOVE 'DISPLAY' TO WA_TAB-FCODE.
559         APPEND WA_TAB TO IT_TAB1.
560         MOVE 'DELETE' TO WA_TAB-FCODE.
561         APPEND WA_TAB TO IT_TAB1.
562         MOVE 'RELEASE' TO WA_TAB-FCODE.
563         APPEND WA_TAB TO IT_TAB1.
564         MOVE 'CR_MATCODE' TO WA_TAB-FCODE.
565         APPEND WA_TAB TO IT_TAB1.
566         MOVE 'APPROVE' TO WA_TAB-FCODE.
567         APPEND WA_TAB TO IT_TAB1.
568         MOVE 'CHECK' TO WA_TAB-FCODE.
569         APPEND WA_TAB TO IT_TAB1.
570
571
572         "START OF ADDITION BY LIPSY <RD1K979105> for attaching files
573         MOVE 'ATTACH' TO WA_TAB-FCODE.
574         APPEND WA_TAB TO IT_TAB1.
575         MOVE 'LIST' TO WA_TAB-FCODE.
576         APPEND WA_TAB TO IT_TAB1.
577         MOVE 'HELP' TO WA_TAB-FCODE.
578         APPEND WA_TAB TO IT_TAB1.
579
580
581         elseif G_MODE = 'DIS'.
582
583            MOVE 'CREATE' TO WA_TAB-FCODE.
584         APPEND WA_TAB TO IT_TAB1.
585         MOVE 'CHANGE' TO WA_TAB-FCODE.
586         APPEND WA_TAB TO IT_TAB1.
587         MOVE 'DISPLAY' TO WA_TAB-FCODE.
588         APPEND WA_TAB TO IT_TAB1.
589         MOVE 'DELETE' TO WA_TAB-FCODE.
590         APPEND WA_TAB TO IT_TAB1.
591         MOVE 'RELEASE' TO WA_TAB-FCODE.
592         APPEND WA_TAB TO IT_TAB1.
593         MOVE 'CR_MATCODE' TO WA_TAB-FCODE.
594         APPEND WA_TAB TO IT_TAB1.
595         MOVE 'APPROVE' TO WA_TAB-FCODE.
596         APPEND WA_TAB TO IT_TAB1.
597         MOVE 'CHECK' TO WA_TAB-FCODE.
598         APPEND WA_TAB TO IT_TAB1.
599
600
601         "START OF ADDITION BY LIPSY <RD1K979105> for attaching files
602         MOVE 'ATTACH' TO WA_TAB-FCODE.
603         APPEND WA_TAB TO IT_TAB1.
604         MOVE 'HELP' TO WA_TAB-FCODE.
605         APPEND WA_TAB TO IT_TAB1.
606         "END OF ADDITION BY LIPSY ON 31.08.2012
607
608    *   elseif g_mode = 'REL'.
609    *     move 'CREATE' to wa_tab-fcode.
610    *     append wa_tab to it_tab1.
611    *     move 'CHANGE' to wa_tab-fcode.
612    *     append wa_tab to it_tab1.
613    *     move 'DELETE' to wa_tab-fcode.
614    *     append wa_tab to it_tab1.
615    *     move 'DISPLAY' to wa_tab-fcode.
616    *     append wa_tab to it_tab1.
617    *     move 'RELEASE' to wa_tab-fcode.
618    *     append wa_tab to it_tab1.
619    *     move 'CR_MATCODE' to wa_tab-fcode.
620    *     append wa_tab to it_tab1.
621    *     move 'APPROVE' to wa_tab-fcode.
622    *     append wa_tab to it_tab1.
623    *   elseif g_mode = 'APR'.
624    *     move 'CREATE' to wa_tab-fcode.
625    *     append wa_tab to it_tab1.
626    *     move 'CHANGE' to wa_tab-fcode.
627    *     append wa_tab to it_tab1.
628    *     move 'DELETE' to wa_tab-fcode.
629    *     append wa_tab to it_tab1.
630    *     move 'DISPLAY' to wa_tab-fcode.
631    *     append wa_tab to it_tab1.
632    *     move 'CR_MATCODE' to wa_tab-fcode.
633    *     append wa_tab to it_tab1.
634    *     move 'RELEASE' to wa_tab-fcode.
635    *     append wa_tab to it_tab1.
636    *     move 'APPROVE' to wa_tab-fcode.
637    *     append wa_tab to it_tab1.
638       ENDIF.
639
640       IF SY-TCODE = 'ZCODG'.
641         CLEAR WA_TAB.
642         REFRESH IT_TAB1.
643         IF G_MODE = 'COD'.
644           MOVE 'CREATE' TO WA_TAB-FCODE.
645           APPEND WA_TAB TO IT_TAB1.
646           MOVE 'CHANGE' TO WA_TAB-FCODE.
647           APPEND WA_TAB TO IT_TAB1.
648           MOVE 'DELETE' TO WA_TAB-FCODE.
649           APPEND WA_TAB TO IT_TAB1.
650           MOVE 'DISPLAY' TO WA_TAB-FCODE.
651           APPEND WA_TAB TO IT_TAB1.
652           MOVE 'APPROVE' TO WA_TAB-FCODE.
653           APPEND WA_TAB TO IT_TAB1.
654           MOVE 'RELEASE' TO WA_TAB-FCODE.
655           APPEND WA_TAB TO IT_TAB1.
656
657         "START OF ADDITION BY LIPSY <RD1K979105> for attaching files
658         MOVE 'ATTACH' TO WA_TAB-FCODE.
659         APPEND WA_TAB TO IT_TAB1.
660         MOVE 'HELP' TO WA_TAB-FCODE.
661         APPEND WA_TAB TO IT_TAB1.
662         "END OF ADDITION BY LIPSY ON 31.08.2012
663
664         ELSEIF G_MODE = 'DIS'.
665           MOVE 'CREATE' TO WA_TAB-FCODE.
666           APPEND WA_TAB TO IT_TAB1.
667           MOVE 'CHANGE' TO WA_TAB-FCODE.
668           APPEND WA_TAB TO IT_TAB1.
669           MOVE 'DELETE' TO WA_TAB-FCODE.
670           APPEND WA_TAB TO IT_TAB1.
671           MOVE 'APPROVE' TO WA_TAB-FCODE.
672           APPEND WA_TAB TO IT_TAB1.
673           MOVE 'RELEASE' TO WA_TAB-FCODE.
674           APPEND WA_TAB TO IT_TAB1.
675           MOVE 'CR_MATCODE' TO WA_TAB-FCODE.
676           APPEND WA_TAB TO IT_TAB1.
677
678           "START OF ADDITION BY LIPSY <RD1K979105> for attaching files
679         MOVE 'ATTACH' TO WA_TAB-FCODE.
680         APPEND WA_TAB TO IT_TAB1.
681         MOVE 'HELP' TO WA_TAB-FCODE.
682         APPEND WA_TAB TO IT_TAB1.
683         "END OF ADDITION BY LIPSY ON 31.08.2012
684         ENDIF.
685       ENDIF.
686
687     ENDFORM.                    " fill_sttab
688    *&---------------------------------------------------------------------*
689    *&      Form  fill_mattyp_itemdt
690    *&---------------------------------------------------------------------*
691    *       text
692    *----------------------------------------------------------------------*
693    *  -->  p1        text
694    *  <--  p2        text
695    *----------------------------------------------------------------------*
696     FORM FILL_MATTYP_ITEMDT.
697
698       DATA L_CDHD LIKE ZMM_CDHD.
699
700       IF G_MODE = 'CRE'.
701         PERFORM SET_DYNNR USING ZMM_CDHD_ST-MTART.
702       ELSE.
703         SELECT SINGLE * INTO L_CDHD FROM ZMM_CDHD
704                WHERE REQNO = ZMM_CDHD_ST-REQNO.
705         IF SY-SUBRC = 0.
706           PERFORM SET_DYNNR USING L_CDHD-MTART.
707         ELSE.
708    *       message e003(zmm_oth) with zmm_cdhd_st-reqno.
709         ENDIF.
710    *
711         IF L_CDHD-MTART = 'ZSTO'.
712           SELECT SINGLE * FROM ZMM_CDITEM
713              WHERE REQNO = ZMM_CDHD_ST-REQNO
714              AND   OTH1  = 'X'.
715           IF SY-SUBRC = 0.
716             G_TECHAPR_VISIBLE = 'Y'.
717           ENDIF.
718         ENDIF.
719       ENDIF.
720     ENDFORM.                    " fill_mattyp_itemdt
721    *&---------------------------------------------------------------------*
722    *&      Form  chng_attr_100
723    *&---------------------------------------------------------------------*
724    *       text
725    *----------------------------------------------------------------------*
726    *  -->  p1        text
727    *  <--  p2        text
728    *----------------------------------------------------------------------*
729     FORM CHNG_ATTR_100.
730       IF G_MODE = 'CRE'.
731         LOOP AT SCREEN.
732           IF SCREEN-NAME = 'ZMM_CDHD_ST-REQNO'.
733             SCREEN-INPUT = 0.
734             MODIFY SCREEN.
735           ENDIF.
736         ENDLOOP.
737       ENDIF.
738     ENDFORM.                    " chng_attr_100
739    *&---------------------------------------------------------------------*
740    *&      Form  SELECT_HELP_DATA
741    *&---------------------------------------------------------------------*
742     FORM SELECT_MAT_DATA USING
743                          PARTNO LIKE ZMM_CDITEM-USER_DESC
744                          MATGP LIKE ZMM_MODIFIER-MATGRP
745                          MTART LIKE MARA-MTART
746                          CHANGING SEL_FLAG.
747
748       DATA : L_LINES LIKE SY-INDEX.
749       DATA : L_SRNO  LIKE SY-INDEX.
750       DATA : L_LEN   LIKE SY-INDEX.
751       DATA : L_LEN1  LIKE SY-INDEX.
752       DATA : L_LEN2  LIKE SY-INDEX.
753       DATA : L_CHECK.
754       DATA : G_PARTNO1 LIKE ZMM_CDITEM-USER_DESC.
755       DATA : G_PARTNO2 LIKE ZMM_CDITEM-USER_DESC.
756
757       DATA : G_CAPCODE_NO   LIKE AUSP-ATINN.
758       DATA : G_MODELCODE_NO LIKE AUSP-ATINN.
759    **
760       DATA : L_120HITS TYPE T_TABLCTRL120.
761       DATA : L_HITS TYPE I.
762    **
763       DESCRIBE TABLE IST_SRCHLP LINES L_LINES.
764
765    *
766       TRANSLATE DESC TO UPPER CASE.
767
768       IF MTART = 'ZSPR'.
769
770         IF  L_LINES = 0  OR FIELD1 = 'ZMM_CDITEM-PARTNO'.
771
772           SELECT A~MAKTG A~MATNR B~MFRNR B~MEINS B~MFRPN B~WRKST B~ZZCAP_CODE B~ZZMODELNO B~ZZOEM_NAME B~ZZCAP_NAME
773                  INTO CORRESPONDING FIELDS OF TABLE IST_SRCHLP
774                  FROM MAKT AS A JOIN MARA AS B
775                  ON    A~MATNR = B~MATNR
776                  WHERE B~MFRPN LIKE PARTNO
777                  AND ( B~MTART = MTART OR B~MTART = 'ZMPN' )
778                  AND B~MSTAE = ''.
779    *start of change by yogesh
780
781    *       if sy-subrc = 0.
782    ******get capital code and model no in spares running search help
783    *         select single atinn from CABN into g_capcode_no
784    *                where atnam = 'Z_ONGC_CAPCODE'.
785    *         if sy-subrc <> 0.
786    *           g_capcode_no = ''.
787    *         Endif.
788    *         select single atinn from CABN into g_modelcode_no
789    *                where atnam = 'Z_ONGC_MODELCODE'.
790    *         if sy-subrc <> 0.
791    *           g_modelcode_no = ''.
792    *         Endif.
793    *         Loop at ist_srchlp into wa_srchlp.
794    *           if g_capcode_no <> ''.
795    *             select single atwrt from ausp into wa_srchlp-atwrt
796    *                   where objek = wa_srchlp-matnr
797    *                   and atinn = g_capcode_no.
798    *
799    *             modify  ist_srchlp from wa_srchlp index sy-tabix
800    *             transporting atwrt.
801    *           endif.
802    *           if g_modelcode_no <> ''.
803    *             select single atwrt from ausp into wa_srchlp-mdlno
804    *                   where objek = wa_srchlp-matnr
805    *                   and atinn = g_modelcode_no.
806    *
807    *             modify ist_srchlp from wa_srchlp index sy-tabix
808    *             transporting mdlno.
809    *           endif.
810    *         Endloop.
811    *
812    *       Endif.  "For sy-subrc = 0.
813    *end of change by yogesh
814
815
816         ELSEIF FIELD1 = 'ZMM_CDITEM-DESC1'.
817
818           SELECT A~MAKTG A~MATNR B~MEINS B~MFRPN B~WRKST B~ZZCAP_CODE B~ZZMODELNO B~ZZOEM_NAME B~ZZCAP_NAME
819           INTO CORRESPONDING FIELDS OF TABLE IST_SRCHLP
820           FROM MAKT AS A
821           JOIN MARA AS B
822           ON A~MATNR = B~MATNR
823           WHERE A~MAKTG LIKE DESC
824           AND   B~MTART = MTART
825           AND   B~MFRPN LIKE PARTNO
826    *
827           AND B~MSTAE = ''.
828    *
829           IF SY-SUBRC = 0.
830    *       sel_flag = '0'.
831           ENDIF.
832         ENDIF.
833
834         FIELD-SYMBOLS <WA_SRCHLP> TYPE TY_SRCHLP.
835
836         LOOP AT IST_SRCHLP ASSIGNING <WA_SRCHLP>.
837           <WA_SRCHLP>-ATWRT = <WA_SRCHLP>-ZZCAP_CODE.
838           <WA_SRCHLP>-MDLNO = <WA_SRCHLP>-ZZMODELNO.
839         ENDLOOP.
840
841
842
843    *
844         PERFORM CHANGE_PARTNO1 CHANGING G_PARTNO1 G_PARTNOC.
845         L_LEN1 = STRLEN( G_PARTNO1 ).
846         LOOP AT IST_SRCHLP INTO WA_SRCHLP.
847           PERFORM CHANGE_PARTNO2 CHANGING G_PARTNO2 WA_SRCHLP-MFRPN.
848           L_LEN2 = STRLEN( G_PARTNO2 ).
849           SEARCH G_PARTNO2 FOR G_PARTNO1.
850           IF SY-SUBRC = 0 AND L_LEN1 = L_LEN2.
851           ELSE.
852             DELETE IST_SRCHLP.
853           ENDIF.
854         ENDLOOP.
855       ENDIF.                " For matty = ZSPR
856
857
858    ***For Store items
859       IF MTART = 'ZSTO'.
860
861         IF L_LINES = 0 OR SEL_FLAG = '2' OR SEL_FLAG = '3'
862                       OR SEL_FLAG = '4' OR SEL_FLAG = '5'.
863           SELECT A~MAKTG A~MATNR B~MEINS B~MFRPN B~WRKST
864           INTO CORRESPONDING FIELDS OF TABLE IST_SRCHLP
865           FROM MAKT AS A
866           JOIN MARA AS B
867           ON A~MATNR = B~MATNR
868           WHERE ( A~MAKTG LIKE DESC OR B~WRKST <> '' )
869                 AND B~MTART = MTART
870                 AND B~MSTAE = ''.
871         ENDIF.
872
873         IF SY-SUBRC = 0.
874           SEL_FLAG = '1'.
875         ENDIF.
876
877       ENDIF.
878    ***For Capital Items.
879       IF MTART = 'ZCAP'.
880
881         IF L_LINES = 0 OR SEL_FLAG = '2' OR SEL_FLAG = '3'
882                       OR SEL_FLAG = '4' OR SEL_FLAG = '5'.
883           SELECT A~MAKTG A~MATNR B~MEINS B~MFRPN B~WRKST
884           INTO CORRESPONDING FIELDS OF TABLE IST_SRCHLP
885           FROM MAKT AS A
886           JOIN MARA AS B
887           ON A~MATNR = B~MATNR
888           WHERE ( A~MAKTG LIKE DESC OR B~WRKST <> '' )
889           AND B~MTART = MTART
890           AND B~MSTAE = ''.
891         ENDIF.
892
893         IF SY-SUBRC = 0.
894           SEL_FLAG = '1'.
895         ENDIF.
896
897       ENDIF.
898    **For disposal items.
899       IF MTART = 'ZDIS'.
900         IF L_LINES = 0 OR SEL_FLAG = '2' OR SEL_FLAG = '3'
901                        OR SEL_FLAG = '4' OR SEL_FLAG = '5'.
902           SELECT A~MAKTG A~MATNR B~MEINS B~MFRPN B~WRKST
903           INTO CORRESPONDING FIELDS OF TABLE IST_SRCHLP
904           FROM MAKT AS A
905           JOIN MARA AS B
906           ON A~MATNR = B~MATNR
907           WHERE ( A~MAKTG LIKE DESC OR B~WRKST LIKE DESC )
908           AND B~MTART = MTART
909           AND B~MSTAE = ''.
910         ENDIF.
911
912         IF SY-SUBRC = 0.
913           SEL_FLAG = '1'.
914         ENDIF.
915       ENDIF.
916
917       LOOP AT IST_SRCHLP INTO WA_SRCHLP.
918
919    *
920         L_LEN = STRLEN( WA_SRCHLP-MAKTG ).
921    *
922         L_LEN = L_LEN - 1.
923         L_CHECK = WA_SRCHLP-MAKTG+L_LEN(1).
924         IF L_CHECK = '*'.
925           CONCATENATE WA_SRCHLP-MAKTG+0(L_LEN) WA_SRCHLP-WRKST INTO
926           WA_SRCHLP-MAKTX.
927         ELSE.
928           MOVE WA_SRCHLP-MAKTG TO WA_SRCHLP-MAKTX.
929         ENDIF.
930
931         TRANSLATE WA_SRCHLP-MAKTX TO UPPER CASE.
932
933         IF NOT DESC11 IS INITIAL.
934
935           SEARCH WA_SRCHLP-MAKTX FOR DESC11.
936
937           IF SY-SUBRC = 0.
938
939             L_SRNO = L_SRNO + 1.
940
941             WA_SRCHLP-SRNO = L_SRNO.
942
943             MODIFY IST_SRCHLP FROM WA_SRCHLP.
944
945           ELSE.
946
947             DELETE IST_SRCHLP.
948
949           ENDIF.
950
951         ELSE.
952
953           L_SRNO = L_SRNO + 1.
954
955           WA_SRCHLP-SRNO = L_SRNO.
956
957           MODIFY IST_SRCHLP FROM WA_SRCHLP.
958
959         ENDIF.
960
961       ENDLOOP.
962
963     ENDFORM.                    "SELECT_MAT_DATA
964
965    ***********************************
966    * Form SELECT_HELP_DATA
967    ***********************************
968
969     FORM SELECT_HELP_DATA USING VALUE(PARTNO) LIKE ZMM_CDITEM-USER_DESC
970                                 VALUE(DESC1) LIKE ZMM_CDITEM-DESC1
971                                 VALUE(DESC2) LIKE ZMM_CDITEM-DESC2
972                                 VALUE(DESC3) LIKE ZMM_CDITEM-DESC3
973                                 VALUE(DESC4) LIKE ZMM_CDITEM-DESC4
974    *{   INSERT         OCPK900087                                        1
975    **********************************************************************
976    *                             VALUE(STEUC) LIKE ZMM_CDITEM-STEUC
977    **********************************************************************
978    *}   INSERT
979                                 VALUE(DESC5) LIKE ZMM_CDITEM-USER_DESC
980                                 VALUE(MATGP) LIKE ZMM_MODIFIER-MATGRP
981                                 VALUE(MATTY) LIKE ZMM_CDHD_ST-MTART
982                                 CHANGING SEL_FLAG.
983
984    *{   INSERT         OCPK900087                                        3
985    *DATA: BEGIN OF WA_T604F,
986    *      LAND1 TYPE LAND1,
987    *      STEUC TYPE STEUC,
988    *  END OF WA_T604F,
989    *  ZMSG110 TYPE STRING.
990    **LOOP AT G_TABCTRL110_ITAB INTO G_TABCTRL110_WA.
991    *
992    * SELECT LAND1 STEUC FROM T604F INTO WA_T604F WHERE LAND1 = 'IN' AND STEUC = STEUC.
993    *ENDSELECT.
994    *
995    *IF WA_T604F IS INITIAL.
996    *
997    * CONCATENATE STEUC ` DOESN'T EXIST IN T604F ` INTO ZMSG110.
998    * MESSAGE ZMSG110 TYPE 'S' DISPLAY LIKE 'E'.
999    *ENDIF.
1000   *}   INSERT
1001
1002      DATA : L_SRNO TYPE I.
1003
1004      IF NOT DESC1 IS INITIAL OR NOT PARTNO IS INITIAL.
1005        CONCATENATE '%' DESC1 '%' INTO DESC.
1006        PERFORM SELECT_MAT_DATA USING PARTNO MATGP MATTY CHANGING SEL_FLAG.
1007        CLEAR : WA_SRCHLP.
1008      ENDIF.
1009
1010      CLEAR L_SRNO.
1011      IF NOT DESC2 IS INITIAL.
1012
1013        LOOP AT IST_SRCHLP INTO WA_SRCHLP.
1014
1015          TRANSLATE DESC2 TO UPPER CASE.
1016
1017          SEARCH WA_SRCHLP-MAKTX FOR DESC2.
1018
1019          IF SY-SUBRC <> 0.
1020            DELETE IST_SRCHLP .
1021          ELSE.
1022            L_SRNO = L_SRNO + 1.
1023            WA_SRCHLP-SRNO = L_SRNO.
1024            MODIFY IST_SRCHLP FROM WA_SRCHLP.
1025          ENDIF.
1026
1027        ENDLOOP.
1028
1029        SEL_FLAG = '2'.
1030
1031      ENDIF.
1032
1033      CLEAR L_SRNO.
1034
1035      IF NOT DESC3 IS INITIAL.
1036
1037        LOOP AT IST_SRCHLP INTO WA_SRCHLP.
1038
1039          TRANSLATE DESC3 TO UPPER CASE.
1040
1041          SEARCH WA_SRCHLP-MAKTX FOR DESC3.
1042
1043          IF SY-SUBRC <> 0.
1044            DELETE IST_SRCHLP .
1045          ELSE.
1046            L_SRNO = L_SRNO + 1.
1047            WA_SRCHLP-SRNO = L_SRNO.
1048            MODIFY IST_SRCHLP FROM WA_SRCHLP.
1049
1050          ENDIF.
1051
1052        ENDLOOP.
1053
1054        SEL_FLAG = '3'.
1055
1056      ENDIF.
1057
1058      CLEAR L_SRNO.
1059
1060      IF NOT DESC4 IS INITIAL.
1061
1062        LOOP AT IST_SRCHLP INTO WA_SRCHLP.
1063
1064          TRANSLATE DESC4 TO UPPER CASE.
1065
1066          SEARCH WA_SRCHLP-MAKTX FOR DESC4.
1067
1068          IF SY-SUBRC <> 0.
1069            DELETE IST_SRCHLP .
1070          ELSE.
1071            L_SRNO = L_SRNO + 1.
1072            WA_SRCHLP-SRNO = L_SRNO.
1073            MODIFY IST_SRCHLP FROM WA_SRCHLP.
1074
1075          ENDIF.
1076
1077        ENDLOOP.
1078
1079        SEL_FLAG = '4'.
1080
1081      ENDIF.
1082
1083      CLEAR L_SRNO.
1084
1085      IF NOT DESC5 IS INITIAL.
1086
1087        LOOP AT IST_SRCHLP INTO WA_SRCHLP.
1088
1089          TRANSLATE DESC5 TO UPPER CASE.
1090
1091          SEARCH WA_SRCHLP-MAKTX FOR DESC5.
1092
1093          IF SY-SUBRC <> 0.
1094            DELETE IST_SRCHLP .
1095          ELSE.
1096            L_SRNO = L_SRNO + 1.
1097            WA_SRCHLP-SRNO = L_SRNO.
1098            MODIFY IST_SRCHLP FROM WA_SRCHLP.
1099
1100          ENDIF.
1101
1102        ENDLOOP.
1103
1104        SEL_FLAG = '5'.
1105
1106      ENDIF.
1107
1108
1109    ENDFORM.                    " SELECT_HELP_DATA
1110   *&---------------------------------------------------------------------*
1111   *&      Form  Gen_request
1112   *&---------------------------------------------------------------------*
1113   *       text
1114   *----------------------------------------------------------------------*
1115   *  -->  p1        text
1116   *  <--  p2        text
1117   *----------------------------------------------------------------------*
1118    FORM SAVE_REQUEST.
1119      PERFORM CHECK_OTHER.
1120      IF G_MODE = 'CRE'.
1121        PERFORM GEN_REQUEST.
1122        CASE  ZMM_CDHD_ST-MTART.
1123          WHEN 'ZSTO'.
1124            L_MATTYPE = 'S'.
1125          WHEN 'ZSPR'.
1126            L_MATTYPE = 'P'.
1127          WHEN 'ZCAP'.
1128            L_MATTYPE = 'C'.
1129          WHEN 'ZDIS'.
1130            L_MATTYPE = 'D'.
1131        ENDCASE.
1132   *
1133        ZMM_CDHD_ST-REQNO = G_REQNO.
1134        G_REQUEST_NO = G_REQNO.
1135        PERFORM INSERT_INTO_TAB.
1136        MESSAGE I005(ZMM_OTH) WITH G_REQUEST_NO.
1137      ELSEIF G_MODE = 'CHA'.     "OR  g_mode = 'APR'.
1138        G_REQUEST_NO = ZMM_CDHD_ST-REQNO.
1139        PERFORM PREPARE_UPDATE."on commit.
1140        COMMIT WORK.
1141        MESSAGE I006(ZMM_OTH) WITH G_REQUEST_NO.
1142        IF G_LOCK = 'Y'.
1143          PERFORM UNLOCK_REQ.
1144          CLEAR G_LOCK.
1145        ENDIF.
1146        PERFORM CLEAR_VAR.
1147      ELSEIF G_MODE = 'DEL'.
1148        PERFORM PREPARE_DELETE .
1149        PERFORM CLEAR_VAR.
1150      ELSEIF G_MODE = 'REL'.
1151        IF ZMM_CDHD_ST-STATUS_FLAG = ''.
1152          MESSAGE I024(ZMM_OTH) WITH 'Release'.
1153        ELSE.
1154          CALL SCREEN 103 STARTING AT 10 10 ENDING AT 70 15.
1155        ENDIF.
1156   *    Perform update_release.
1157      ELSEIF G_MODE = 'APR'.
1158   **Note - Status flag is not pertaining to Request status, for that
1159   **purpose flag is Reqcl ( Request Status ).
1160        IF ZMM_CDHD_ST-STATUS_FLAG = ' '.
1161          MESSAGE I026(ZMM_OTH).
1162          LEAVE TO SCREEN 0.
1163        ELSEIF ZMM_CDHD_ST-APPROVE_MRP = ''.
1164          MESSAGE I024(ZMM_OTH) WITH 'APPROVAL MRP CTRL'.
1165        ELSEIF  G_USER = ''.
1166          MESSAGE I043(ZMM_OTH).
1167          PERFORM CLEAR_VAR.
1168          LEAVE TO SCREEN 100.
1169        ELSEIF G_USER = 'M'.
1170          CALL SCREEN 103 STARTING AT 10 10 ENDING AT 70 15.
1171        ELSEIF ZMM_CDHD_ST-APPROVE_L2 = '' AND G_USER = 'L'.
1172          MESSAGE I024(ZMM_OTH) WITH 'L2 APPROVAL'.
1173        ELSEIF ZMM_CDHD_ST-APPROVE_L2 = 'X' AND G_USER = 'L'.
1174          PERFORM UPDATE_APPROVAL.
1175        ENDIF.
1176      ELSEIF G_MODE = 'CRC'.
1177        G_REQUEST_NO = ZMM_CDHD_ST-REQNO.
1178        PERFORM UPDATE_CODES.
1179        IF ZMM_CDHD_ST-MTART = 'ZCAP'.
1180          READ TABLE IST_ZMM_CDITEM WITH KEY SPA_GRP = ''.
1181          IF SY-SUBRC = 0.
1182            MESSAGE I083(ZMM_OTH).
1183            CLEAR OKCODE_100.
1184            EXIT.
1185          ENDIF.
1186        ENDIF.
1187        COMMIT WORK.
1188        IF ZMM_CDHD_ST-REQCL <> 'C'.
1189          PERFORM CHECK_REQSTATUS.
1190        ENDIF.
1191        MOVE-CORRESPONDING ZMM_CDHD_ST TO ZMM_CDHD.
1192        MODIFY ZMM_CDHD FROM ZMM_CDHD.
1193        COMMIT WORK.
1194        IF ZMM_CDHD_ST-REQCL = 'C'.
1195          PERFORM SEND_MAIL_TO_REQN.
1196
1197        """"""""""""""""""""""""""""""""""""""""
1198         """""""""""""""""""""""""""""""""""""""""""""""""""
1199          """"""added by lipsy on 10.09.2013 for sending  sms to requisitioner
1200          "in case of status RD1K982397
1201
1202
1203          PERFORM SEND_SMS_TO_REQN.
1204
1205
1206          "end of add by lipsy on 10.09.2013 for sending  sms to requisitioner
1207          "in case of status RD1K982397
1208         """"""""""""""""""""""""""""""""""""""""""""""""""""""
1209
1210        """""""""""""""""""""""""""""""""""""""""""""""""
1211
1212        ENDIF.
1213        MESSAGE I006(ZMM_OTH) WITH G_REQUEST_NO.
1214      ENDIF.
1215   *
1216      IF G_MODE = 'COD'.
1217        CLEAR G_MODE.
1218      ENDIF.
1219   *
1220      IF SY-TCODE = 'ZCODG'.
1221        IF G_MODE = ''.
1222          PERFORM UPDATE_CODES.
1223          PERFORM CHECK_REQSTATUS.
1224   *
1225          IF ZMM_CDHD_ST-REQCL = 'IR'.
1226            SELECT SINGLE * FROM ZMM_CDHD
1227                WHERE REQNO = ZMM_CDHD_ST-REQNO.
1228            IF ZMM_CDHD-IR_DATE IS INITIAL.
1229              ZMM_CDHD_ST-IR_DATE = SY-DATUM.
1230            ENDIF.
1231          ELSE.
1232            CLEAR ZMM_CDHD_ST-IR_DATE.
1233          ENDIF.
1234   *
1235          MOVE-CORRESPONDING ZMM_CDHD_ST TO ZMM_CDHD.
1236          MODIFY ZMM_CDHD FROM ZMM_CDHD.
1237   *       Perform update_codes.
1238          COMMIT WORK.
1239          IF ZMM_CDHD_ST-REQCL = 'C' OR
1240             ZMM_CDHD_ST-REQCL = 'IR'.
1241            PERFORM SEND_MAIL_TO_REQN.
1242      """"""""""""""""""""""""""""""""""""""""""""""""""""""""
1243       """""""""""""""""""""""""""""""""""""""""""""""""""
1244          """"""added by lipsy on 10.09.2013 for sending  sms to requisitioner
1245          "in case of status RD1K982397
1246
1247
1248          PERFORM SEND_SMS_TO_REQN.
1249
1250
1251          "end of add by lipsy on 10.09.2013 for sending  sms to requisitioner
1252          "in case of status RD1K982397
1253         """"""""""""""""""""""""""""""""""""""""""""""""""""""
1254      """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
1255          ENDIF.
1256          PERFORM CLEAR_VAR.
1257          MESSAGE I006(ZMM_OTH) WITH G_REQUEST_NO.
1258        ENDIF.
1259      ENDIF.
1260    ENDFORM.                    " Gen_request
1261   *&---------------------------------------------------------------------*
1262   *&      Form  gen_request
1263   *&---------------------------------------------------------------------*
1264   *       text
1265   *----------------------------------------------------------------------*
1266   *  -->  p1        text
1267   *  <--  p2        text
1268   *----------------------------------------------------------------------*
1269    FORM GEN_REQUEST.
1270
1271      CALL FUNCTION 'NUMBER_GET_NEXT'
1272        EXPORTING
1273          NR_RANGE_NR = '01'
1274          OBJECT      = 'ZMMCODREQ'
1275        IMPORTING
1276          NUMBER      = G_REQNO.
1277      IF SY-SUBRC <> 0.
1278      ENDIF.
1279
1280    ENDFORM.                    " gen_request
1281   *&---------------------------------------------------------------------*
1282   *&      Form  Insert_into_tab
1283   *&---------------------------------------------------------------------*
1284   *       text
1285   *----------------------------------------------------------------------*
1286   *  -->  p1        text
1287   *  <--  p2        text
1288   *----------------------------------------------------------------------*
1289    FORM INSERT_INTO_TAB.
1290
1291      DATA L_CLOSE_REQ VALUE 'Y'.
1292      IF G_MODE = 'CRE'.
1293        MOVE SY-DATUM TO ZMM_CDHD_ST-REQDATE.
1294        MOVE SY-UNAME TO ZMM_CDHD_ST-REQCPF.
1295        MOVE 'N' TO ZMM_CDHD_ST-REQCL.
1296        MOVE-CORRESPONDING ZMM_CDHD_ST TO ZMM_CDHD.
1297        INSERT INTO ZMM_CDHD VALUES ZMM_CDHD.
1298        IF SY-SUBRC = 0.
1299          MESSAGE I001(ZMM_OTH) WITH ZMM_CDHD-REQNO.
1300        ENDIF.
1301      ELSEIF G_MODE = 'CHA'.
1302        IF MATGEN_FLAG = 'X'.
1303          MOVE MATGEN_FLAG TO ZMM_CDHD_ST-MATGEN_FLAG.
1304          MOVE SY-DATUM TO ZMM_CDHD_ST-MATGEN_DATE.
1305        ENDIF.
1306   *
1307        CASE L_MATTYPE.
1308          WHEN 'S'.
1309            LOOP AT G_TABCTRL110_ITAB INTO G_TABCTRL110_WA.
1310              IF G_TABCTRL110_WA-MATCODE IS INITIAL.
1311                L_CLOSE_REQ = 'N'.
1312              ENDIF.
1313            ENDLOOP.
1314          WHEN 'P'.
1315            LOOP AT G_TABLCTRL120_ITAB INTO G_TABLCTRL120_WA.
1316              IF  G_TABLCTRL120_WA-MATCODE IS INITIAL.
1317                L_CLOSE_REQ = 'N'.
1318              ENDIF.
1319            ENDLOOP.
1320          WHEN 'C'.
1321            LOOP AT G_TABLCTRL130_ITAB INTO G_TABLCTRL130_WA.
1322              IF G_TABLCTRL130_WA-MATCODE IS INITIAL.
1323                L_CLOSE_REQ = 'N'.
1324              ENDIF.
1325            ENDLOOP.
1326        ENDCASE.
1327        IF L_CLOSE_REQ = 'Y'.
1328          MOVE 'C' TO ZMM_CDHD_ST-REQCL.
1329        ENDIF.
1330   *
1331        MOVE-CORRESPONDING ZMM_CDHD_ST TO ZMM_CDHD.
1332        MODIFY ZMM_CDHD FROM ZMM_CDHD.
1333      ENDIF.
1334   *
1335      REFRESH IST_ZMM_CDITEM.
1336      CASE L_MATTYPE.
1337        WHEN 'S'.
1338          LOOP AT G_TABCTRL110_ITAB INTO G_TABCTRL110_WA.
1339            IF NOT G_TABCTRL110_WA-DESC_FIN IS INITIAL.
1340              IF NOT ZMM_CDHD_ST-STATUS_FLAG IS INITIAL AND
1341                     ZMM_CDHD_ST-APPROVE_MRP IS INITIAL.
1342                PERFORM GET_NOOFHITS.
1343              ENDIF.
1344              MOVE-CORRESPONDING G_TABCTRL110_WA TO WA_ZMM_CDITEM.
1345              MOVE ZMM_CDHD_ST-REQNO TO WA_ZMM_CDITEM-REQNO.
1346              MOVE G_TABCTRL110_WA-MATGP TO WA_ZMM_CDITEM-MATGP.
1347              PERFORM CHABY_CHADT.
1348              CLEAR WA_ZMM_CDITEM-DESC_CDCELL.
1349              APPEND WA_ZMM_CDITEM TO IST_ZMM_CDITEM.
1350            ELSE.
1351              EXIT.
1352            ENDIF.
1353          ENDLOOP.
1354        WHEN 'P'.
1355          LOOP AT G_TABLCTRL120_ITAB INTO G_TABLCTRL120_WA.
1356            IF NOT G_TABLCTRL120_WA-DESC_FIN IS INITIAL.
1357              IF NOT ZMM_CDHD_ST-STATUS_FLAG IS INITIAL AND
1358                     ZMM_CDHD_ST-APPROVE_MRP IS INITIAL .
1359                PERFORM GET_NOOFHITS.
1360              ENDIF.
1361              MOVE-CORRESPONDING G_TABLCTRL120_WA TO WA_ZMM_CDITEM.
1362              MOVE ZMM_CDHD_ST-REQNO TO WA_ZMM_CDITEM-REQNO.
1363              MOVE G_TABLCTRL120_WA-MATGP TO WA_ZMM_CDITEM-MATGP.
1364              PERFORM CHABY_CHADT.
1365              APPEND WA_ZMM_CDITEM TO IST_ZMM_CDITEM.
1366            ELSE.
1367              EXIT.
1368            ENDIF.
1369          ENDLOOP.
1370        WHEN 'C'.
1371          LOOP AT G_TABLCTRL130_ITAB INTO G_TABLCTRL130_WA.
1372            IF NOT G_TABLCTRL130_WA-DESC_FIN IS INITIAL.
1373              IF NOT ZMM_CDHD_ST-STATUS_FLAG IS INITIAL AND
1374                     ZMM_CDHD_ST-APPROVE_MRP IS INITIAL.
1375                PERFORM GET_NOOFHITS.
1376              ENDIF.
1377              MOVE-CORRESPONDING G_TABLCTRL130_WA TO WA_ZMM_CDITEM.
1378              MOVE '0C' TO WA_ZMM_CDITEM-MATGP.
1379              MOVE ZMM_CDHD_ST-REQNO TO WA_ZMM_CDITEM-REQNO.
1380              PERFORM CHABY_CHADT.
1381              APPEND WA_ZMM_CDITEM TO IST_ZMM_CDITEM.
1382            ELSE.
1383              EXIT.
1384            ENDIF.
1385          ENDLOOP.
1386        WHEN 'D'.
1387          LOOP AT G_TABLCTRL140_ITAB INTO G_TABLCTRL140_WA.
1388            IF NOT G_TABLCTRL140_WA-DESC_FIN IS INITIAL.
1389              MOVE-CORRESPONDING G_TABLCTRL140_WA TO WA_ZMM_CDITEM.
1390              MOVE ZMM_CDHD_ST-REQNO TO WA_ZMM_CDITEM-REQNO.
1391              MOVE SY-DATUM TO WA_ZMM_CDITEM-CODDT.
1392              MOVE SY-UNAME TO WA_ZMM_CDITEM-CODBY.
1393              APPEND WA_ZMM_CDITEM TO IST_ZMM_CDITEM.
1394            ELSE.
1395              EXIT.
1396            ENDIF.
1397          ENDLOOP.
1398      ENDCASE.
1399
1400      INSERT ZMM_CDITEM FROM TABLE IST_ZMM_CDITEM.
1401   ************************************************************
1402   ****Saving the long text.                              *****
1403   ************************************************************
1404   ******Header(Correspondence)********************************
1405      IF ( G_MODE = 'CRE' ) OR ( G_MODE = 'CHA' ) OR
1406         ( G_MODE = 'APR' ) OR ( G_MODE = 'MRP' ) OR
1407           SY-TCODE = 'ZCODG'.
1408        PERFORM SAVE_CORS_TEXT.
1409      ENDIF.
1410   ******Items*************************************************
1411      IF G_MODE = 'CRE'.
1412        DELETE ADJACENT DUPLICATES FROM IST_TEXTID_ITEMS.
1413        LOOP AT IST_TEXTID_ITEMS INTO WA_TEXTID.
1414          REFRESH : IST_DTSPECS.
1415          PERFORM READ_TEXT_DATA TABLES IST_DTSPECS USING WA_TEXTID.
1416          CONCATENATE 'CDDS'
1417                       ZMM_CDHD_ST-REQNO
1418                       WA_TEXTID-TDNAME+14(3)
1419                 INTO  WA_TEXTID-TDNAME.
1420          PERFORM SAVE_TEXT.
1421        ENDLOOP.
1422        CLEAR WA_TEXTID.
1423   *****Delete temporarily saved long text*******************************
1424        LOOP AT IST_TEXTID_ITEMS INTO WA_TEXTID.
1425          SELECT SINGLE * INTO G_STXL FROM STXL
1426                     WHERE TDOBJECT = WA_TEXTID-TDOBJECT
1427                      AND  TDID     = WA_TEXTID-TDID
1428                      AND  TDNAME   = WA_TEXTID-TDNAME.
1429          IF SY-SUBRC = 0.
1430            PERFORM DELETE_TEXT.
1431          ENDIF.
1432        ENDLOOP.
1433        REFRESH IST_TEXTID_ITEMS.
1434      ENDIF.
1435   *************End of Long Text Save************************************
1436      PERFORM CLEAR_VAR.
1437
1438    ENDFORM.                    " Insert_into_tab
1439   *&---------------------------------------------------------------------*
1440   *&      Form  clear_var
1441   *&---------------------------------------------------------------------*
1442   *       text
1443   *----------------------------------------------------------------------*
1444   *  -->  p1        text
1445   *  <--  p2        text
1446   *----------------------------------------------------------------------*
1447    FORM CLEAR_VAR.
1448      IF NOT GV_TEXT_EDITOR1 IS INITIAL.
1449        PERFORM DESTROY_CTRL.
1450      ENDIF.
1451      CLEAR ZMM_CDHD_ST.
1452
1453      REFRESH G_TABCTRL110_ITAB.
1454      REFRESH CONTROL 'TABCTRL110' FROM SCREEN '0110'.
1455
1456      REFRESH G_TABLCTRL120_ITAB.
1457      REFRESH CONTROL 'TABLCTRL120' FROM SCREEN '0120'.
1458
1459      REFRESH G_TABLCTRL130_ITAB.
1460      REFRESH CONTROL 'TABLCTRL130' FROM SCREEN '0130'.
1461
1462      REFRESH G_TABLCTRL140_ITAB.
1463      REFRESH CONTROL 'TABLCTRL140' FROM SCREEN '0140'.
1464
1465      IF G_LOCK = 'Y'.
1466        PERFORM UNLOCK_REQ.
1467        CLEAR G_LOCK.
1468      ENDIF.
1469      CLEAR: ZMM_CDHD_ST-REQCPF, ZMM_CDHD_ST-REQDATE, ZMM_CDHD_ST-APPCPF,
1470             ZMM_CDHD_ST-APPDATE, ZMM_CDHD_ST-ADDR1, ZMM_CDHD_ST-ADDR2,
1471             ZMM_CDHD_ST-ADDR3,ZMM_CDHD_ST-REQLOC,
1472             G_TABCTRL110_WA, G_TABLCTRL120_WA, G_TABLCTRL130_WA,
1473             G_TABLCTRL140_WA,G_LINENO,G_MODE,G_HD_COPIED,G_CDITEM,
1474             L_MATTYPE,G_SAVEFLAG,G_CHECK_FLAG,G_TECHAPR_VISIBLE,
1475             G_USER_FOUND.  "<< TAA+MRP check 03/10/05
1476      CLEAR  G_CORS.
1477      REFRESH: IST_SRCHLP,TLINETAB1,TLINETAB2,LINES_CORS.
1478      REFRESH:LT_TEXT_TABLE1,LT_TEXT_TABLE2.
1479   *****Assigning constants and status*************************************
1480      DYNNR = ''.
1481      REFRESH IT_TAB1.
1482      G_TABCTRL110_COPIED = ''.
1483      G_TABLCTRL120_COPIED = ''.
1484      G_TABLCTRL130_COPIED = ''.
1485      G_TABLCTRL140_COPIED = ''.
1486   *
1487    ENDFORM.                    " clear_var
1488
1489   *&---------------------------------------------------------------------*
1490   *&      Module  TABCTRL110_desc1_check  INPUT
1491   *&---------------------------------------------------------------------*
1492   *       text
1493   *----------------------------------------------------------------------*
1494    FORM TABCTRL110_DESC1_CHECK .
1495
1496      IF NOT G_TABCTRL110_WA-MATGP IS INITIAL AND
1497            TABCTRL110_CHECK_FLAG <> 'X'.
1498   *
1499        MATGRP_CHANGE_FLAG = 'X'.
1500        MATGRP_ORIG = G_TABCTRL110_WA-MATGP.
1501      ENDIF.
1502
1503      SELECT * FROM ZMM_MODIFIER INTO TABLE IST_MODIFIER_CHECK_LIST
1504                WHERE DESC1 = ZMM_CDITEM-DESC1 .
1505   *
1506      IF SY-SUBRC = 0.
1507
1508        DELETE ADJACENT DUPLICATES FROM IST_MODIFIER_CHECK_LIST COMPARING
1509                        DESC1 MATGRP.
1510        LOOP AT IST_MODIFIER_CHECK_LIST INTO WA_MODIFIER_CHECK_LIST.
1511
1512          IF      WA_MODIFIER_CHECK_LIST-MATGRP = '01'
1513               OR WA_MODIFIER_CHECK_LIST-MATGRP = '02'
1514               OR WA_MODIFIER_CHECK_LIST-MATGRP = '03'
1515               OR WA_MODIFIER_CHECK_LIST-MATGRP = '04'
1516               OR WA_MODIFIER_CHECK_LIST-MATGRP = '05'
1517               OR WA_MODIFIER_CHECK_LIST-MATGRP = '06'
1518               OR WA_MODIFIER_CHECK_LIST-MATGRP = '07'
1519               OR WA_MODIFIER_CHECK_LIST-MATGRP = '08'
1520               OR WA_MODIFIER_CHECK_LIST-MATGRP = '09'
1521               OR WA_MODIFIER_CHECK_LIST-MATGRP = '10'
1522               OR WA_MODIFIER_CHECK_LIST-MATGRP = '11'
1523               OR WA_MODIFIER_CHECK_LIST-MATGRP = '12'
1524               OR WA_MODIFIER_CHECK_LIST-MATGRP = '13'
1525               OR WA_MODIFIER_CHECK_LIST-MATGRP = '14'
1526               OR WA_MODIFIER_CHECK_LIST-MATGRP = '15'
1527               OR WA_MODIFIER_CHECK_LIST-MATGRP = '16'
1528               OR WA_MODIFIER_CHECK_LIST-MATGRP = 'XX'.
1529          ELSE.
1530            DELETE IST_MODIFIER_CHECK_LIST.
1531          ENDIF.
1532
1533        ENDLOOP.
1534
1535        DESCRIBE TABLE IST_MODIFIER_CHECK_LIST LINES CHECK_LIST_LINES.
1536
1537        IF CHECK_LIST_LINES > 1 AND TABCTRL110_CHECK_FLAG ='X'.
1538   *
1539          CALL SCREEN 104 STARTING AT 40 2
1540                          ENDING   AT 80 18.
1541          G_MATGP_SELECTED = 'X'.
1542          CLEAR CHECK_LIST_LINES.
1543        ELSE.
1544          READ TABLE IST_MODIFIER_CHECK_LIST
1545          INTO WA_MODIFIER_CHECK_LIST INDEX 1.  "#EC CI_NOORDER
1546        ENDIF.
1547
1548        IF MATGRP_CHANGE_FLAG = 'X'.
1549          CLEAR G_MATGP_SELECTED.
1550          ZMM_CDITEM-MATGP = MATGRP_ORIG.
1551          G_TABCTRL110_WA-MATGP = MATGRP_ORIG.
1552          CLEAR : MATGRP_ORIG, MATGRP_CHANGE_FLAG.
1553        ELSE.
1554          ZMM_CDITEM-MATGP = WA_MODIFIER_CHECK_LIST-MATGRP.
1555          G_TABCTRL110_WA-MATGP = WA_MODIFIER_CHECK_LIST-MATGRP.
1556        ENDIF.
1557
1558   *
1559        CLEAR ZMM_CDITEM-OTH1.
1560        CLEAR CHECK_LIST_LINES.
1561      ELSE.
1562        IF ZMM_CDITEM-OTH1 <> 'X'.
1563   *
1564          MESSAGE I002(ZMM_OTH).
1565        ENDIF.
1566      ENDIF.
1567
1568    ENDFORM.                 " TABCTRL110_desc1_check
1569
1570   *---------------------------------------------------------------------*
1571   *       FORM TABCTRL110_desc2_check                                   *
1572   *---------------------------------------------------------------------*
1573   *       ........                                                      *
1574   *---------------------------------------------------------------------*
1575    FORM TABCTRL110_DESC2_CHECK .
1576
1577      SELECT SINGLE * FROM ZMM_MODIFIER WHERE DESC1 = ZMM_CDITEM-DESC1 AND
1578                                              DESC2 = ZMM_CDITEM-DESC2 .
1579
1580      IF SY-SUBRC = 0.
1581        CLEAR G_TABCTRL110_WA-OTH2.
1582        CLEAR ZMM_CDITEM-OTH2.
1583      ELSE.
1584        IF ZMM_CDITEM-OTH2 <> 'X'.
1585          G_PARNO = 2.
1586          MESSAGE I002(ZMM_OTH).
1587        ENDIF.
1588      ENDIF.
1589
1590    ENDFORM.                 " TABCTRL110_desc2_check
1591   *&---------------------------------------------------------------------*
1592   *&      Form  TABCTRL110_desc3_check
1593   *&---------------------------------------------------------------------*
1594   *       text
1595   *----------------------------------------------------------------------*
1596   *  -->  p1        text
1597   *  <--  p2        text
1598   *----------------------------------------------------------------------*
1599    FORM TABCTRL110_DESC3_CHECK.
1600
1601      SELECT SINGLE * FROM ZMM_MODIFIER WHERE DESC1 = ZMM_CDITEM-DESC1 AND
1602                                              DESC2 = ZMM_CDITEM-DESC2 AND
1603                                              DESC3 = ZMM_CDITEM-DESC3 .
1604
1605      IF SY-SUBRC = 0.
1606        CLEAR G_TABCTRL110_WA-OTH3.
1607        CLEAR ZMM_CDITEM-OTH3.
1608      ELSE.
1609        IF ZMM_CDITEM-OTH3 <> 'X'.
1610          G_PARNO = 3.
1611          MESSAGE I002(ZMM_OTH).
1612        ENDIF.
1613      ENDIF.
1614
1615    ENDFORM.                    " TABCTRL110_desc3_check
1616   *---------------------------------------------------------------------*
1617   *       FORM TABCTRL110_desc4_check                                   *
1618   *---------------------------------------------------------------------*
1619   *       ........                                                      *
1620   *---------------------------------------------------------------------*
1621    FORM TABCTRL110_DESC4_CHECK.
1622
1623      SELECT SINGLE * FROM ZMM_MODIFIER WHERE DESC1 = ZMM_CDITEM-DESC1 AND
1624                                              DESC2 = ZMM_CDITEM-DESC2 AND
1625                                              DESC3 = ZMM_CDITEM-DESC3 AND
1626                                              DESC4 = ZMM_CDITEM-DESC4 .
1627      IF SY-SUBRC = 0.
1628        CLEAR G_TABCTRL110_WA-OTH4.
1629        CLEAR ZMM_CDITEM-OTH4.
1630      ELSE.
1631        IF ZMM_CDITEM-OTH4 <> 'X'.
1632          G_PARNO = 4.
1633          MESSAGE I002(ZMM_OTH).
1634        ENDIF.
1635      ENDIF.
1636
1637    ENDFORM.                    " TABCTRL110_desc4_check
1638
1639   ****************************************************
1640    FORM POPUP_USERDESC1.
1641      REFRESH : IST_SVAL1.
1642      CLEAR : IST_SVAL1.
1643      MOVE : 'ZMM_CDITEM'  TO IST_SVAL1-TABNAME,
1644             'USER_DESC'   TO IST_SVAL1-FIELDNAME,
1645             'X'           TO IST_SVAL1-FIELD_OBL.
1646      APPEND IST_SVAL1.
1647
1648      CALL FUNCTION 'POPUP_GET_VALUES'
1649        EXPORTING
1650          POPUP_TITLE     = 'USER DESCRIPTION'
1651          START_COLUMN    = '5'
1652          START_ROW       = '5'
1653        TABLES
1654          FIELDS          = IST_SVAL1
1655        EXCEPTIONS
1656          ERROR_IN_FIELDS = 1
1657          OTHERS          = 2.
1658
1659      IF SY-SUBRC <> 0.
1660        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
1661                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
1662      ENDIF.
1663      READ TABLE IST_SVAL1 INDEX 1.
1664      G_TABCTRL110_WA-USER_DESC = IST_SVAL1-VALUE.
1665
1666    ENDFORM.                    " popup_userdesc1
1667
1668   *---------------------------------------------------------------------*
1669   *       FORM popup_userdesc2                                          *
1670   *---------------------------------------------------------------------*
1671   *       ........                                                      *
1672   *---------------------------------------------------------------------*
1673    FORM POPUP_USERDESC2.
1674      REFRESH : IST_SVAL2.
1675      CLEAR : IST_SVAL2.
1676      MOVE : 'ZMM_CDITEM'  TO IST_SVAL2-TABNAME,
1677             'USER_DESC'   TO IST_SVAL2-FIELDNAME,
1678             'X'           TO IST_SVAL2-FIELD_OBL.
1679      APPEND IST_SVAL2.
1680
1681      CALL FUNCTION 'POPUP_GET_VALUES'
1682        EXPORTING
1683          POPUP_TITLE     = 'USER DESCRIPTION'
1684          START_COLUMN    = '5'
1685          START_ROW       = '5'
1686        TABLES
1687          FIELDS          = IST_SVAL2
1688        EXCEPTIONS
1689          ERROR_IN_FIELDS = 1
1690          OTHERS          = 2.
1691
1692      IF SY-SUBRC <> 0.
1693        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
1694                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
1695      ENDIF.
1696      READ TABLE IST_SVAL2 INDEX 1.
1697      G_TABCTRL110_WA-USER_DESC = IST_SVAL2-VALUE.
1698
1699    ENDFORM.                    " popup_userdesc2
1700
1701   *---------------------------------------------------------------------*
1702   *       FORM popup_userdesc3                                          *
1703   *---------------------------------------------------------------------*
1704   *       ........                                                      *
1705   *---------------------------------------------------------------------*
1706    FORM POPUP_USERDESC3.
1707      REFRESH : IST_SVAL3.
1708      CLEAR : IST_SVAL3.
1709      MOVE : 'ZMM_CDITEM'  TO IST_SVAL3-TABNAME,
1710             'USER_DESC'   TO IST_SVAL3-FIELDNAME,
1711             'X'           TO IST_SVAL3-FIELD_OBL.
1712      APPEND IST_SVAL3.
1713
1714      CALL FUNCTION 'POPUP_GET_VALUES'
1715        EXPORTING
1716          POPUP_TITLE     = 'USER DESCRIPTION'
1717          START_COLUMN    = '5'
1718          START_ROW       = '5'
1719        TABLES
1720          FIELDS          = IST_SVAL3
1721        EXCEPTIONS
1722          ERROR_IN_FIELDS = 1
1723          OTHERS          = 2.
1724
1725      IF SY-SUBRC <> 0.
1726        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
1727                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
1728      ENDIF.
1729      READ TABLE IST_SVAL3 INDEX 1.
1730      G_TABCTRL110_WA-USER_DESC = IST_SVAL3-VALUE.
1731
1732    ENDFORM.                    " popup_userdesc3
1733
1734   *---------------------------------------------------------------------*
1735   *       FORM popup_userdesc4                                          *
1736   *---------------------------------------------------------------------*
1737   *       ........                                                      *
1738   *---------------------------------------------------------------------*
1739    FORM POPUP_USERDESC4.
1740      REFRESH : IST_SVAL4.
1741      CLEAR : IST_SVAL4.
1742      MOVE : 'ZMM_CDITEM'  TO IST_SVAL4-TABNAME,
1743             'USER_DESC'   TO IST_SVAL4-FIELDNAME,
1744             'X'           TO IST_SVAL4-FIELD_OBL.
1745      APPEND IST_SVAL4.
1746
1747      CALL FUNCTION 'POPUP_GET_VALUES'
1748        EXPORTING
1749          POPUP_TITLE     = 'USER DESCRIPTION'
1750          START_COLUMN    = '5'
1751          START_ROW       = '5'
1752        TABLES
1753          FIELDS          = IST_SVAL4
1754        EXCEPTIONS
1755          ERROR_IN_FIELDS = 1
1756          OTHERS          = 2.
1757
1758      IF SY-SUBRC <> 0.
1759        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
1760                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
1761      ENDIF.
1762      READ TABLE IST_SVAL4 INDEX 1.
1763      G_TABCTRL110_WA-USER_DESC = IST_SVAL4-VALUE.
1764
1765    ENDFORM.                    " popup_userdesc4
1766
1767   *---------------------------------------------------------------------*
1768   *       FORM TABLCTRL120_desc1_check                                  *
1769   *---------------------------------------------------------------------*
1770   *       ........                                                      *
1771   *---------------------------------------------------------------------*
1772    FORM TABLCTRL120_DESC1_CHECK .
1773
1774      SELECT SINGLE * FROM ZMM_MODIFIER WHERE DESC1 = ZMM_CDITEM-DESC1 .
1775
1776      IF SY-SUBRC = 0.
1777        CLEAR G_TABLCTRL120_WA-OTH1.
1778        CLEAR ZMM_CDITEM-OTH1.
1779      ELSE.
1780        IF ZMM_CDITEM-OTH1 <> 'X'.
1781          G_PARNO = 1.
1782          MESSAGE I002(ZMM_OTH).
1783        ENDIF.
1784      ENDIF.
1785
1786    ENDFORM.                 " TABLCTRL120_desc1_check
1787   *&---------------------------------------------------------------------*
1788   *&      Form  CHANGE_PARTNO
1789   *&---------------------------------------------------------------------*
1790   *       text
1791   *----------------------------------------------------------------------*
1792   *      <--P_G_PARTNO  text
1793   *----------------------------------------------------------------------*
1794    FORM CHANGE_PARTNO CHANGING P_G_PARTNO LIKE ZMM_CDITEM-USER_DESC
1795                                P_G_PARTNOC LIKE ZMM_CDITEM-PARTNO.
1796
1797      DATA : L_LEN TYPE I.
1798      DATA : L_CTR TYPE I.
1799      DATA : L_CTR1 TYPE I.
1800      DATA : L_ADD TYPE I.
1801      DATA : L_SUB TYPE I.
1802      DATA : L_CTRF TYPE I.
1803      DATA : L_P_G_PARTNOC LIKE ZMM_CDITEM-PARTNO.
1804
1805      CLEAR : P_G_PARTNO.
1806      CLEAR : CHECK_FLAG2.
1807
1808      L_LEN = STRLEN( P_G_PARTNOC ).
1809
1810      L_P_G_PARTNOC = P_G_PARTNOC.
1811
1812      DO L_LEN TIMES.
1813
1814   *     l_ctr = l_ctr + 1.
1815
1816        WA_CHAR = L_P_G_PARTNOC+L_CTR(1).
1817        TRANSLATE WA_CHAR TO UPPER CASE.
1818   *
1819        L_CTR = L_CTR + 1.
1820   *
1821        LOOP AT IST_ALPHANUM INTO WA_ALPHANUM.
1822
1823          IF WA_CHAR = WA_ALPHANUM.
1824            CHECK_FLAG1 = 'X'.
1825            EXIT.
1826          ELSEIF WA_CHAR = '*'.
1827            CHECK_FLAG2 = 'X'.
1828            EXIT.
1829          ENDIF.
1830
1831        ENDLOOP.
1832
1833        IF CHECK_FLAG1 = 'X'.
1834          CLEAR CHECK_FLAG1.
1835        ELSE.
1836          L_ADD = L_CTR + 1.
1837          L_SUB = L_LEN - L_ADD + 1.
1838          IF L_ADD > L_LEN.
1839          ELSE.
1840            CONCATENATE L_P_G_PARTNOC+0(L_CTR) '%' L_P_G_PARTNOC+L_ADD(L_SUB)
1841                                                           INTO L_P_G_PARTNOC.
1842          ENDIF.
1843        ENDIF.
1844
1845      ENDDO.
1846      CLEAR L_CTR.
1847      L_CTRF = L_LEN - 1.
1848      DO L_LEN TIMES.
1849        WA_ALPHANUM = L_P_G_PARTNOC+L_CTR(1).
1850        IF L_CTR = L_CTRF.
1851          CONCATENATE P_G_PARTNO WA_ALPHANUM INTO P_G_PARTNO.
1852        ELSEIF WA_ALPHANUM <> '%'.
1853          CONCATENATE P_G_PARTNO WA_ALPHANUM '%' INTO P_G_PARTNO.
1854        ENDIF.
1855
1856        L_CTR = L_CTR + 1.
1857      ENDDO.
1858
1859    ENDFORM.                    " CHANGE_PARTNO
1860
1861   *---------------------------------------------------------------------*
1862   *       FORM CHANGE_PARTNO1                                           *
1863   *---------------------------------------------------------------------*
1864   *       ........                                                      *
1865   *---------------------------------------------------------------------*
1866   *  -->  P_G_PARTNOO                                                   *
1867   *  -->  P_G_PARTNOCC                                                  *
1868   *---------------------------------------------------------------------*
1869    FORM CHANGE_PARTNO1 CHANGING P_G_PARTNOO LIKE ZMM_CDITEM-USER_DESC
1870                                P_G_PARTNOCC LIKE ZMM_CDITEM-PARTNO.
1871
1872      DATA : L_LEN TYPE I.
1873      DATA : L_CTR TYPE I.
1874
1875      CLEAR : P_G_PARTNOO.
1876
1877      L_LEN = STRLEN( P_G_PARTNOCC ).
1878
1879      CLEAR CHECK_FLAG1.
1880
1881      DO L_LEN TIMES.
1882
1883        WA_CHAR = P_G_PARTNOCC+L_CTR(1).
1884        TRANSLATE WA_CHAR TO UPPER CASE.
1885        L_CTR = L_CTR + 1.
1886
1887        LOOP AT IST_ALPHANUM INTO WA_ALPHANUM.
1888
1889          IF WA_CHAR = WA_ALPHANUM.
1890            CHECK_FLAG1 = 'X'.
1891            EXIT.
1892          ENDIF.
1893
1894        ENDLOOP.
1895
1896        IF CHECK_FLAG1 = 'X'.
1897          CLEAR CHECK_FLAG1.
1898          CONCATENATE P_G_PARTNOO WA_CHAR INTO P_G_PARTNOO.
1899        ENDIF.
1900
1901      ENDDO.
1902
1903    ENDFORM.                    " CHANGE_PARTNO
1904
1905   *---------------------------------------------------------------------*
1906   *       FORM CHANGE_PARTNO2                                           *
1907   *---------------------------------------------------------------------*
1908   *       ........                                                      *
1909   *---------------------------------------------------------------------*
1910   *  -->  P_G_PARTNOO                                                   *
1911   *  -->  P_G_PARTNOCC                                                  *
1912   *---------------------------------------------------------------------*
1913    FORM CHANGE_PARTNO2 CHANGING P_G_PARTNOO LIKE ZMM_CDITEM-USER_DESC
1914                                P_G_PARTNOCC LIKE ZMM_CDITEM-PARTNO.
1915
1916      DATA : L_LEN TYPE I.
1917      DATA : L_CTR TYPE I.
1918
1919      CLEAR : P_G_PARTNOO.
1920
1921      L_LEN = STRLEN( P_G_PARTNOCC ).
1922
1923      CLEAR CHECK_FLAG1.
1924
1925      DO L_LEN TIMES.
1926
1927        WA_CHAR = P_G_PARTNOCC+L_CTR(1).
1928        TRANSLATE WA_CHAR TO UPPER CASE.
1929        L_CTR = L_CTR + 1.
1930
1931        LOOP AT IST_ALPHANUM INTO WA_ALPHANUM.
1932
1933          IF WA_CHAR = WA_ALPHANUM.
1934            CHECK_FLAG1 = 'X'.
1935            EXIT.
1936          ENDIF.
1937
1938        ENDLOOP.
1939
1940        IF CHECK_FLAG1 = 'X'.
1941          CLEAR CHECK_FLAG1.
1942          CONCATENATE P_G_PARTNOO WA_CHAR INTO P_G_PARTNOO.
1943        ENDIF.
1944
1945      ENDDO.
1946
1947    ENDFORM.                    " CHANGE_PARTNO
1948
1949   *---------------------------------------------------------------------*
1950   *       FORM attrib_parno                                             *
1951   *---------------------------------------------------------------------*
1952   *       ........                                                      *
1953   *---------------------------------------------------------------------*
1954    FORM ATTRIB_PARNO.
1955
1956
1957      SELECT * FROM ZMM_MODIFIER UP TO 1 ROWS
1958    WHERE DESC1 = G_TABCTRL110_WA-DESC1
1959    AND MATGRP = G_TABCTRL110_WA-MATGP
1960    ORDER BY PRIMARY KEY .
1961    ENDSELECT.
1962      IF SY-SUBRC <> 0.
1963        G_PARNO = '1'.
1964      ENDIF.
1965
1966      IF SY-SUBRC = 0.
1967
1968        IF  ZMM_MODIFIER-DESC2 IS INITIAL.
1969          G_PARNO = '1'.
1970        ELSEIF  ZMM_MODIFIER-DESC3 IS INITIAL.
1971          G_PARNO = '2'.
1972        ELSEIF  ZMM_MODIFIER-DESC4 IS INITIAL.
1973          G_PARNO = '3'.
1974        ELSE.
1975          G_PARNO = '4'.
1976        ENDIF.
1977
1978      ENDIF.
1979
1980    ENDFORM.                    "attrib_parno
1981   *&---------------------------------------------------------------------*
1982   *&      Form  TABLCTRL140_desc1_check
1983   *&---------------------------------------------------------------------*
1984   *       text
1985   *----------------------------------------------------------------------*
1986   *  -->  p1        text
1987   *  <--  p2        text
1988   *----------------------------------------------------------------------*
1989    FORM TABLCTRL140_DESC1_CHECK.
1990
1991      SELECT SINGLE * FROM ZMM_MODIFIER WHERE DESC1 = ZMM_CDITEM-DESC1 .
1992
1993      IF SY-SUBRC = 0.
1994        CLEAR G_TABLCTRL140_WA-OTH1.
1995        CLEAR ZMM_CDITEM-OTH1.
1996      ELSE.
1997        IF ZMM_CDITEM-OTH1 <> 'X'.
1998          G_PARNO = 1.
1999          MESSAGE I002(ZMM_OTH).
2000        ENDIF.
2001      ENDIF.
2002
2003    ENDFORM.                    " TABLCTRL140_desc1_check
2004   *&---------------------------------------------------------------------*
2005   *&      Form  TABLCTRL130_desc1_check
2006   *&---------------------------------------------------------------------*
2007   *       text
2008   *----------------------------------------------------------------------*
2009   *  -->  p1        text
2010   *  <--  p2        text
2011   *----------------------------------------------------------------------*
2012    FORM TABLCTRL130_DESC1_CHECK.
2013
2014      SELECT SINGLE * FROM ZMM_MODIFIER WHERE DESC1 = ZMM_CDITEM-DESC1 .
2015
2016      IF SY-SUBRC = 0.
2017        CLEAR G_TABLCTRL130_WA-OTH1.
2018        CLEAR ZMM_CDITEM-OTH1.
2019      ELSE.
2020        IF ZMM_CDITEM-OTH1 <> 'X'.
2021          G_PARNO = 1.
2022          MESSAGE I002(ZMM_OTH).
2023        ENDIF.
2024      ENDIF.
2025
2026    ENDFORM.                    " TABLCTRL130_desc1_check
2027
2028   *&---------------------------------------------------------------------*
2029   *&      Form  add_delitem
2030   *&---------------------------------------------------------------------*
2031   *       text
2032   *----------------------------------------------------------------------*
2033   *  -->  p1        text
2034   *  <--  p2        text
2035   *----------------------------------------------------------------------*
2036    FORM ADD_DELITEM110.
2037      LOOP AT G_TABCTRL110_ITAB INTO G_TABCTRL110_WA.
2038        IF G_TABCTRL110_WA-FLAG = 'X'.
2039          IF G_TABCTRL110_WA-MATCODE IS INITIAL.
2040            APPEND G_TABCTRL110_WA TO G_ITAB_DEL110.
2041          ELSE.
2042            MESSAGE I031(ZMM_OTH).
2043            G_TABCTRL110_WA-FLAG = ''.
2044            G_DELFLAG = 'N'.
2045          ENDIF.
2046        ENDIF.
2047      ENDLOOP.
2048      CLEAR G_TABCTRL110_WA.
2049    ENDFORM.                    "add_delitem110
2050
2051   *&---------------------------------------------------------------------*
2052   *&      Form  add_delitem120
2053   *&---------------------------------------------------------------------*
2054   *       text
2055   *----------------------------------------------------------------------*
2056   *  -->  p1        text
2057   *  <--  p2        text
2058   *----------------------------------------------------------------------*
2059    FORM ADD_DELITEM120.
2060      LOOP AT G_TABLCTRL120_ITAB INTO G_TABLCTRL120_WA.
2061        IF G_TABLCTRL120_WA-FLAG = 'X'.
2062          IF G_TABLCTRL120_WA-MATCODE IS INITIAL.
2063            APPEND G_TABLCTRL120_WA TO G_ITAB_DEL120.
2064          ELSE.
2065            MESSAGE I031(ZMM_OTH).
2066            G_TABLCTRL120_WA-FLAG = ''.
2067            G_DELFLAG = 'N'.
2068          ENDIF.
2069        ENDIF.
2070      ENDLOOP.
2071      CLEAR G_TABLCTRL120_WA.
2072
2073    ENDFORM.                    " add_delitem120
2074   *&---------------------------------------------------------------------*
2075   *&      Form  add_delitem130
2076   *&---------------------------------------------------------------------*
2077   *       text
2078   *----------------------------------------------------------------------*
2079   *  -->  p1        text
2080   *  <--  p2        text
2081   *----------------------------------------------------------------------*
2082    FORM ADD_DELITEM130.
2083      LOOP AT G_TABLCTRL130_ITAB INTO G_TABLCTRL130_WA.
2084        IF G_TABLCTRL130_WA-FLAG = 'X'.
2085          IF G_TABLCTRL130_WA-MATCODE IS INITIAL.
2086            APPEND G_TABLCTRL130_WA TO G_ITAB_DEL130.
2087          ELSE.
2088            MESSAGE I031(ZMM_OTH).
2089            G_TABLCTRL130_WA-FLAG = ''.
2090            G_DELFLAG = 'N'.
2091          ENDIF.
2092        ENDIF.
2093      ENDLOOP.
2094      CLEAR G_TABLCTRL130_WA.
2095
2096    ENDFORM.                    " add_delitem130
2097   *&---------------------------------------------------------------------*
2098   *&      Form  add_delitem140
2099   *&---------------------------------------------------------------------*
2100   *       text
2101   *----------------------------------------------------------------------*
2102   *  -->  p1        text
2103   *  <--  p2        text
2104   *----------------------------------------------------------------------*
2105    FORM ADD_DELITEM140.
2106      LOOP AT G_TABLCTRL140_ITAB INTO G_TABLCTRL140_WA.
2107        IF G_TABLCTRL140_WA-FLAG = 'X'.
2108          APPEND G_TABLCTRL140_WA TO G_ITAB_DEL140.
2109        ENDIF.
2110      ENDLOOP.
2111      CLEAR G_TABLCTRL140_WA.
2112
2113    ENDFORM.                    " add_delitem140
2114
2115   *&      Form  prepare_update
2116   *&---------------------------------------------------------------------*
2117   *       text
2118   *----------------------------------------------------------------------*
2119   *  -->  p1        text
2120   *  <--  p2        text
2121   *----------------------------------------------------------------------*
2122    FORM PREPARE_UPDATE.
2123
2124   ***To delete the 'DELETED' marked item from the DB table.
2125   ***Select statement to store the previus CODBY/CODDT.
2126      CLEAR G_CDITEM.
2127      SELECT SINGLE * INTO G_CDITEM FROM ZMM_CDITEM
2128             WHERE REQNO = ZMM_CDHD_ST-REQNO.
2129   *
2130      CASE ZMM_CDHD_ST-MTART.
2131        WHEN 'ZSTO'.
2132          L_MATTYPE = 'S'.
2133          PERFORM DELITEM110.
2134        WHEN 'ZSPR'.
2135          L_MATTYPE = 'P'.
2136          PERFORM DELITEM120.
2137        WHEN 'ZCAP'.
2138          L_MATTYPE = 'C'.
2139          PERFORM DELITEM130.
2140        WHEN 'ZDIS'.
2141          L_MATTYPE = 'D'.
2142          PERFORM DELITEM140.
2143      ENDCASE.
2144      PERFORM INSERT_INTO_TAB.
2145
2146    ENDFORM.                    " prepare_update
2147
2148   *&---------------------------------------------------------------------*
2149   *&      Form  delitem110
2150   *&---------------------------------------------------------------------*
2151   *       text
2152   *----------------------------------------------------------------------*
2153   *  -->  p1        text
2154   *  <--  p2        text
2155   *----------------------------------------------------------------------*
2156    FORM DELITEM110.
2157   *
2158      DELETE FROM ZMM_CDITEM
2159      WHERE  REQNO   = ZMM_CDHD_ST-REQNO.
2160   *
2161      REFRESH G_ITAB_DEL110.
2162   *
2163    ENDFORM.                    " delitem110
2164
2165   *&---------------------------------------------------------------------*
2166   *&      Form  delitem120
2167   *&---------------------------------------------------------------------*
2168   *       text
2169   *----------------------------------------------------------------------*
2170   *  -->  p1        text
2171   *  <--  p2        text
2172   *----------------------------------------------------------------------*
2173    FORM DELITEM120.
2174   *
2175      DELETE FROM ZMM_CDITEM
2176      WHERE  REQNO   = ZMM_CDHD_ST-REQNO.
2177   *
2178      REFRESH G_ITAB_DEL120.
2179   *
2180    ENDFORM.                    " delitem120
2181
2182   *&---------------------------------------------------------------------*
2183   *&      Form  delitem130
2184   *&---------------------------------------------------------------------*
2185   *       text
2186   *----------------------------------------------------------------------*
2187   *  -->  p1        text
2188   *  <--  p2        text
2189   *----------------------------------------------------------------------*
2190    FORM DELITEM130.
2191   *
2192      DELETE FROM ZMM_CDITEM
2193      WHERE  REQNO   = ZMM_CDHD_ST-REQNO.
2194   *
2195      REFRESH G_ITAB_DEL130.
2196   *
2197    ENDFORM.                    " delitem130
2198   *&---------------------------------------------------------------------*
2199   *&      Form  delitem140
2200   *&---------------------------------------------------------------------*
2201   *       text
2202   *----------------------------------------------------------------------*
2203   *  -->  p1        text
2204   *  <--  p2        text
2205   *----------------------------------------------------------------------*
2206    FORM DELITEM140.
2207   *
2208      DELETE FROM ZMM_CDITEM
2209      WHERE  REQNO   = ZMM_CDHD_ST-REQNO.
2210   *
2211      REFRESH G_ITAB_DEL140.
2212   *
2213    ENDFORM.                    " delitem140
2214
2215   *&---------------------------------------------------------------------*
2216   *&      Form  prepare_delete
2217   *&---------------------------------------------------------------------*
2218   *       text
2219   *----------------------------------------------------------------------*
2220   *  -->  p1        text
2221   *  <--  p2        text
2222   *----------------------------------------------------------------------*
2223    FORM PREPARE_DELETE.
2224
2225      PERFORM CONFIRM_DEL.
2226
2227      IF G_CHOICE = 'J'.
2228
2229        DELETE FROM ZMM_CDHD
2230        WHERE REQNO = ZMM_CDHD_ST-REQNO.
2231        IF SY-SUBRC <> 0.
2232          MESSAGE E007(ZMM_OTH) WITH ZMM_CDHD_ST-REQNO.
2233        ENDIF.
2234   *
2235        SELECT TDOBJECT TDNAME TDID FROM STXL
2236         INTO CORRESPONDING FIELDS OF TABLE IST_TEXTID_ITEMS
2237         WHERE TDID = 'CDDS'.
2238        IF SY-SUBRC = 0.
2239          DELETE IST_TEXTID_ITEMS
2240             WHERE TDNAME+4(10) <> ZMM_CDHD_ST-REQNO.
2241          LOOP AT IST_TEXTID_ITEMS INTO WA_TEXTID.
2242            PERFORM DELETE_TEXT.
2243          ENDLOOP.
2244          REFRESH IST_TEXTID_ITEMS.
2245        ENDIF.
2246
2247        DELETE FROM ZMM_CDITEM
2248        WHERE REQNO = ZMM_CDHD_ST-REQNO.
2249        IF SY-SUBRC = 0.
2250          MESSAGE I004(ZMM_OTH) WITH ZMM_CDHD_ST-REQNO.
2251        ENDIF.
2252        CLEAR G_CHOICE.
2253      ENDIF.
2254   *
2255    ENDFORM.                    " prepare_delete
2256   *&---------------------------------------------------------------------*
2257   *&      Form  bac_confirm
2258   *&---------------------------------------------------------------------*
2259   *       text
2260   *----------------------------------------------------------------------*
2261   *  -->  p1        text
2262   *  <--  p2        text
2263   *----------------------------------------------------------------------*
2264    FORM MATCODE_CONFIRM.
2265      " Begin of <RD1K960036>.
2266   *   CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
2267   *        EXPORTING
2268   *             DEFAULTOPTION  = 'N'
2269   *             TEXTLINE1      = 'The details in the request have been'
2270   *               TEXTLINE2      = 'checked. Please generate new Material Codes '
2271   *             TITEL          = 'CONFIRM'
2272   *             START_COLUMN   = 25
2273   *             START_ROW      = 6
2274   *             CANCEL_DISPLAY = ''
2275   *        IMPORTING
2276   *             ANSWER         = a_choice.
2277
2278      DATA : L_GET5(5) TYPE C.
2279      CALL FUNCTION 'POPUP_TO_CONFIRM'
2280        EXPORTING
2281         TITLEBAR                    = 'CONFIRM '
2282   *      DIAGNOSE_OBJECT             = ' '
2283          TEXT_QUESTION               = 'The details in the request have been checked.'
2284                                        &' Please generate new Material Codes.'
2285   *      TEXT_BUTTON_1               = 'Ja'(001)
2286   *      ICON_BUTTON_1               = ' '
2287   *      TEXT_BUTTON_2               = 'Nein'(002)
2288   *      ICON_BUTTON_2               = ' '
2289         DEFAULT_BUTTON              = '2'
2290   *      DISPLAY_CANCEL_BUTTON       = 'X'
2291   *      USERDEFINED_F1_HELP         = ' '
2292         START_COLUMN                = 25
2293         START_ROW                   = 6
2294   *      POPUP_TYPE                  =
2295   *      IV_QUICKINFO_BUTTON_1       = ' '
2296   *      IV_QUICKINFO_BUTTON_2       = ' '
2297       IMPORTING
2298         ANSWER                      = L_GET5
2299   *    TABLES
2300   *      PARAMETER                   =
2301       EXCEPTIONS
2302         TEXT_NOT_FOUND              = 1
2303         OTHERS                      = 2
2304                .
2305
2306      IF SY-SUBRC = 0.
2307        CASE L_GET5.
2308          WHEN '1'.
2309            MOVE 'J' TO A_CHOICE.
2310          WHEN '2'.
2311            MOVE 'N' TO A_CHOICE.
2312        ENDCASE.
2313      ENDIF.
2314      " End of <RD1K960036>.
2315    ENDFORM.                    " matcode_confirm
2316
2317   *---------------------------------------------------------------------*
2318   *       FORM bac_confirm                                              *
2319   *---------------------------------------------------------------------*
2320   *       ........                                                      *
2321   *---------------------------------------------------------------------*
2322    FORM BAC_CONFIRM.
2323      DATA L_CHOICE.
2324      CLEAR L_CHOICE.
2325      IF G_MODE <> 'DIS'.
2326        " Begin of <RD1K960036>.
2327   *     CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
2328   *          EXPORTING
2329   *               TEXTLINE1      = 'Data will be lost, Want to quit? '
2330   *               TITEL          = 'BACK'
2331   *               START_COLUMN   = 25
2332   *               START_ROW      = 6
2333   *               CANCEL_DISPLAY = ''
2334   *          IMPORTING
2335   *               ANSWER         = l_choice.
2336        DATA : L_GET6(1) TYPE C.
2337        CALL FUNCTION 'POPUP_TO_CONFIRM'
2338          EXPORTING
2339           TITLEBAR                    = 'BACK'
2340   *        DIAGNOSE_OBJECT             = ' '
2341            TEXT_QUESTION               = 'Data will be lost, Want to quit? '
2342   *        TEXT_BUTTON_1               = 'Ja'(001)
2343   *        ICON_BUTTON_1               = ' '
2344   *        TEXT_BUTTON_2               = 'Nein'(002)
2345   *        ICON_BUTTON_2               = ' '
2346   *        DEFAULT_BUTTON              = '1'
2347   *        DISPLAY_CANCEL_BUTTON       = 'X'
2348   *        USERDEFINED_F1_HELP         = ' '
2349           START_COLUMN                = 25
2350           START_ROW                   = 6
2351   *        POPUP_TYPE                  =
2352   *        IV_QUICKINFO_BUTTON_1       = ' '
2353   *        IV_QUICKINFO_BUTTON_2       = ' '
2354         IMPORTING
2355           ANSWER                      = L_GET6
2356   *      TABLES
2357   *        PARAMETER                   =
2358         EXCEPTIONS
2359           TEXT_NOT_FOUND              = 1
2360           OTHERS                      = 2
2361                  .
2362        IF SY-SUBRC = 0.
2363          CASE L_GET6.
2364            WHEN '1'.
2365              MOVE 'J' TO L_CHOICE.
2366            WHEN '2'.
2367              MOVE 'N' TO L_CHOICE.
2368          ENDCASE.
2369        ENDIF.
2370        " End of <RD1K960036>.
2371
2372        IF L_CHOICE = 'J'.
2373          PERFORM UNDO_LONGTEXT.
2374          PERFORM CLEAR_VAR.
2375          CLEAR L_CHOICE.
2376        ENDIF.
2377      ELSE.
2378        PERFORM CLEAR_VAR.
2379      ENDIF.
2380    ENDFORM.                    " bac_confirm
2381
2382   *&---------------------------------------------------------------------*
2383   *&      Form  check_delreq
2384   *&---------------------------------------------------------------------*
2385   *       text
2386   *----------------------------------------------------------------------*
2387   *  -->  p1        text
2388   *  <--  p2        text
2389   *----------------------------------------------------------------------*
2390    FORM CHECK_DELREQ.
2391      DATA L_ZMM_CDHD LIKE ZMM_CDHD.
2392      IF G_MODE = 'DEL'.
2393        SELECT SINGLE * INTO L_ZMM_CDHD FROM ZMM_CDHD
2394              WHERE REQNO = ZMM_CDHD_ST-REQNO
2395              AND   LVORM = 'D'.
2396        IF SY-SUBRC = 0.
2397          MESSAGE E004(ZMM_OTH) WITH ZMM_CDHD_ST-REQNO.
2398        ENDIF.
2399
2400        SELECT SINGLE * INTO L_ZMM_CDHD FROM ZMM_CDHD
2401              WHERE REQNO = ZMM_CDHD_ST-REQNO
2402              AND   REQCL IN ('C','AC','IC','IR').
2403        IF SY-SUBRC = 0.
2404          MESSAGE E056(ZMM_OTH) WITH ZMM_CDHD_ST-REQNO.
2405        ENDIF.
2406
2407      ENDIF.
2408   *
2409      IF G_MODE = 'CHA' OR
2410         G_MODE = 'APR' OR
2411         G_MODE = 'REL'.
2412        SELECT SINGLE * INTO L_ZMM_CDHD FROM ZMM_CDHD
2413               WHERE REQNO = ZMM_CDHD_ST-REQNO.
2414        IF SY-SUBRC = 0.
2415          IF L_ZMM_CDHD-REQCL = 'AC' OR
2416             L_ZMM_CDHD-REQCL = 'C'.
2417            MESSAGE E053(ZMM_OTH) WITH ZMM_CDHD_ST-REQNO.
2418          ELSEIF L_ZMM_CDHD-REQCL = 'IC'.
2419            MESSAGE E054(ZMM_OTH) WITH ZMM_CDHD_ST-REQNO.
2420          ENDIF.
2421        ENDIF.
2422      ENDIF.
2423   *
2424      IF G_MODE = 'APR' AND G_USER = 'L'.
2425   ***To check , if Tech Auth Appr is reqired.
2426        SELECT SINGLE * FROM ZMM_CDITEM
2427              WHERE REQNO = ZMM_CDHD_ST-REQNO
2428              AND   OTH1  = 'X'.
2429        IF SY-SUBRC <> 0.
2430          MESSAGE E055(ZMM_OTH) WITH ZMM_CDHD_ST-REQNO.
2431        ENDIF.
2432      ENDIF.
2433   *
2434      PERFORM CHANGE_RESTRICT.
2435
2436    ENDFORM.                    " check_delreq
2437   *&---------------------------------------------------------------------*
2438   *&      Form  confirm_del
2439   *&---------------------------------------------------------------------*
2440   *       text
2441   *----------------------------------------------------------------------*
2442   *  -->  p1        text
2443   *  <--  p2        text
2444   *----------------------------------------------------------------------*
2445    FORM CONFIRM_DEL.
2446      " Begin of <RD1K960036>.
2447   *   CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
2448   *    EXPORTING
2449   *    TEXTLINE1   = 'Data will be lost, No recovery possible, Are you sure ? '
2450   *     TITEL       = 'BACK'
2451   *     START_COLUMN     = 25
2452   *     START_ROW        = 6
2453   *     CANCEL_DISPLAY   = ''
2454   *    IMPORTING
2455   *     ANSWER           = g_choice.
2456
2457      DATA : L_GET7(1) TYPE C.
2458      CALL FUNCTION 'POPUP_TO_CONFIRM'
2459        EXPORTING
2460         TITLEBAR                    = 'BACK'
2461   *      DIAGNOSE_OBJECT             = ' '
2462          TEXT_QUESTION               = 'Data will be lost, No recovery possible, Are you sure ? '
2463   *      TEXT_BUTTON_1               = 'Ja'(001)
2464   *      ICON_BUTTON_1               = ' '
2465   *      TEXT_BUTTON_2               = 'Nein'(002)
2466   *      ICON_BUTTON_2               = ' '
2467   *      DEFAULT_BUTTON              = '1'
2468   *      DISPLAY_CANCEL_BUTTON       = 'X'
2469   *      USERDEFINED_F1_HELP         = ' '
2470         START_COLUMN                = 25
2471         START_ROW                   = 6
2472   *      POPUP_TYPE                  =
2473   *      IV_QUICKINFO_BUTTON_1       = ' '
2474   *      IV_QUICKINFO_BUTTON_2       = ' '
2475       IMPORTING
2476         ANSWER                      = L_GET7
2477   *    TABLES
2478   *      PARAMETER                   =
2479       EXCEPTIONS
2480         TEXT_NOT_FOUND              = 1
2481         OTHERS                      = 2
2482                .
2483
2484      IF SY-SUBRC = 0.
2485        CASE L_GET7.
2486          WHEN '1'.
2487            MOVE 'J' TO G_CHOICE.
2488          WHEN '2'.
2489            MOVE 'N' TO G_CHOICE.
2490        ENDCASE.
2491      ENDIF.
2492      " End of <RD1K960036>.
2493    ENDFORM.                    " confirm_del
2494   *&---------------------------------------------------------------------*
2495   *&      Form  check_tabrows
2496   *&---------------------------------------------------------------------*
2497   *       text
2498   *----------------------------------------------------------------------*
2499   *  -->  p1        text
2500   *  <--  p2        text
2501   *----------------------------------------------------------------------*
2502    FORM CHECK_TABROWS.
2503      DATA: WA_ITAB110 TYPE T_TABCTRL110,
2504            WA_ITAB120 TYPE T_TABLCTRL120,
2505            WA_ITAB130 TYPE T_TABLCTRL130,
2506            WA_ITAB140 TYPE T_TABLCTRL140.
2507      CLEAR G_INSRFLG.
2508      CASE ZMM_CDHD_ST-MTART.
2509        WHEN 'ZSTO'.
2510          READ TABLE G_TABCTRL110_ITAB INTO WA_ITAB110
2511               WITH KEY SRNO = 10.
2512          IF SY-SUBRC = 0.
2513            G_INSRFLG = 'Y'.
2514          ENDIF.
2515        WHEN 'ZSPR'.
2516          READ TABLE G_TABLCTRL120_ITAB INTO WA_ITAB120
2517               WITH KEY SRNO = 10.
2518          IF SY-SUBRC = 0.
2519            G_INSRFLG = 'Y'.
2520          ENDIF.
2521        WHEN 'ZCAP'.
2522          READ TABLE G_TABLCTRL130_ITAB INTO WA_ITAB130
2523               WITH KEY SRNO = 10.
2524          IF SY-SUBRC = 0.
2525            G_INSRFLG = 'Y'.
2526          ENDIF.
2527        WHEN 'ZDIS'.
2528          READ TABLE G_TABLCTRL140_ITAB INTO WA_ITAB140
2529               WITH KEY SRNO = 10.
2530          IF SY-SUBRC = 0.
2531            G_INSRFLG = 'Y'.
2532          ENDIF.
2533      ENDCASE.
2534
2535    ENDFORM.                    " check_tabrows
2536   *&---------------------------------------------------------------------*
2537   *&      Form  set_dynnr
2538   *&---------------------------------------------------------------------*
2539   *       text
2540   *----------------------------------------------------------------------*
2541   *      -->P_ZMM_CDHD_ST_MTART  text
2542   *----------------------------------------------------------------------*
2543    FORM SET_DYNNR USING P_MTART.
2544      CASE P_MTART.
2545        WHEN 'ZSTO'.
2546          DYNNR = '0110'.
2547        WHEN 'ZSPR'.
2548          DYNNR = '0120'.
2549        WHEN 'ZCAP'.
2550          DYNNR = '0130'.
2551        WHEN 'ZDIS'.
2552          DYNNR = '0140'.
2553      ENDCASE.
2554    ENDFORM.                    " set_dynnr
2555   *&---------------------------------------------------------------------*
2556   *&      Form  ltxtdtsp
2557   *&---------------------------------------------------------------------*
2558   *       text
2559   *----------------------------------------------------------------------*
2560   *  -->  p1        text
2561   *  <--  p2        text
2562   *----------------------------------------------------------------------*
2563    FORM LTXTDTSP.
2564   *************Local Data*******************************
2565      DATA: L_SRNO LIKE ZMM_CDITEM-SRNO,
2566             L_CURS_LN TYPE I,
2567             L_ITAB110 TYPE T_TABCTRL110,
2568             L_ITAB120 TYPE T_TABLCTRL120,
2569             L_ITAB130 TYPE T_TABLCTRL130,
2570             L_ITAB140 TYPE T_TABLCTRL140.
2571   *
2572      CLEAR IST_TEXTID.
2573
2574   ********************************************************
2575   ***To get the proper serial no of line item against the
2576   ***cursor position
2577      CASE ZMM_CDHD_ST-MTART.
2578        WHEN 'ZSTO'.
2579   *
2580          L_CURS_LN = G_CURR_LINE_110.
2581          READ TABLE G_TABCTRL110_ITAB INTO L_ITAB110
2582                                      INDEX L_CURS_LN.
2583          L_SRNO = L_ITAB110-SRNO.
2584        WHEN 'ZSPR'.
2585   *
2586          L_CURS_LN = G_CURR_LINE_120.
2587          READ TABLE G_TABLCTRL120_ITAB INTO L_ITAB120
2588                                      INDEX L_CURS_LN.
2589          L_SRNO = L_ITAB120-SRNO.
2590        WHEN 'ZCAP'.
2591          L_CURS_LN = G_CURR_LINE_130.
2592   *       move tablctrl130-current_line to l_curs_ln.
2593          READ TABLE G_TABLCTRL130_ITAB INTO L_ITAB130
2594                                      INDEX L_CURS_LN.
2595          L_SRNO = L_ITAB130-SRNO.
2596        WHEN 'ZDIS'.
2597   *       l_curs_ln = g_curr_line_140.
2598          MOVE TABLCTRL140-CURRENT_LINE TO L_CURS_LN.
2599          READ TABLE G_TABLCTRL140_ITAB INTO L_ITAB140
2600                                      INDEX L_CURS_LN.
2601          L_SRNO = L_ITAB140-SRNO.
2602      ENDCASE.
2603
2604   *
2605      IF G_MODE = 'CRE'.
2606        PERFORM GET_DUMMYNO.
2607        CONCATENATE 'CDDS' G_USER_LOGGED L_SRNO
2608        INTO IST_TEXTID-TDNAME.
2609      ELSE.
2610        CONCATENATE 'CDDS' ZMM_CDHD_ST-REQNO L_SRNO
2611        INTO IST_TEXTID-TDNAME.
2612      ENDIF.
2613
2614      IST_TEXTID-TDOBJECT   = 'ZMMCD'.
2615      IST_TEXTID-TDID       = 'CDDS'.
2616      IST_TEXTID-TDSPRAS    =  SY-LANGU.
2617      IST_TEXTID-TDLINESIZE =  72.
2618   ***Appending to internal table for all textid/name.
2619      APPEND IST_TEXTID TO IST_TEXTID_ITEMS.
2620   *
2621      PERFORM READ_TEXT_DTSPECS.
2622   *
2623    ENDFORM.                    " ltxtdtsp
2624   *&---------------------------------------------------------------------*
2625   *&      Form  read_text_dtspecs
2626   *&---------------------------------------------------------------------*
2627   *       text
2628   *----------------------------------------------------------------------*
2629   *  -->  p1        text
2630   *  <--  p2        text
2631   *----------------------------------------------------------------------*
2632    FORM READ_TEXT_DTSPECS.
2633      CLEAR   : IST_DTSPECS.
2634      REFRESH : IST_DTSPECS.
2635      PERFORM READ_TEXT_DATA TABLES IST_DTSPECS USING IST_TEXTID.
2636      PERFORM EDIT_TEXT.
2637   *****To save temporarily in the stxl table with [CDDS9999999999(srno)]
2638   **** for Creation and with [CDDS(reqno)(srno)] for Change
2639      IF ( G_MODE = 'CRE' ) OR ( G_MODE = 'CHA' ).
2640        WA_TEXTID = IST_TEXTID.
2641        PERFORM SAVE_TEXT.
2642      ENDIF.
2643
2644    ENDFORM.                    " read_text_dtspecs
2645   *&---------------------------------------------------------------------*
2646   *&      Form  read_text_data
2647   *&---------------------------------------------------------------------*
2648   *       text
2649   *----------------------------------------------------------------------*
2650   *      -->P_IST_DTSPECS  text
2651   *      -->P_IST_TEXTID  text
2652   *----------------------------------------------------------------------*
2653    FORM READ_TEXT_DATA TABLES   P_IST_DTSPECS STRUCTURE  TLINE
2654                        USING    P_IST_TEXTID  STRUCTURE  THEAD.
2655
2656      CALL FUNCTION 'READ_TEXT'
2657        EXPORTING
2658          CLIENT                  = SY-MANDT
2659          ID                      = P_IST_TEXTID-TDID
2660          LANGUAGE                = SY-LANGU
2661          NAME                    = P_IST_TEXTID-TDNAME
2662          OBJECT                  = P_IST_TEXTID-TDOBJECT
2663        IMPORTING
2664          HEADER                  = P_IST_TEXTID
2665        TABLES
2666          LINES                   = P_IST_DTSPECS
2667        EXCEPTIONS
2668          ID                      = 1
2669          LANGUAGE                = 2
2670          NAME                    = 3
2671          NOT_FOUND               = 4
2672          OBJECT                  = 5
2673          REFERENCE_CHECK         = 6
2674          WRONG_ACCESS_TO_ARCHIVE = 7
2675          OTHERS                  = 8.
2676
2677    ENDFORM.                    " read_text_data
2678   *&---------------------------------------------------------------------*
2679   *&      Form  edit_text
2680   *&---------------------------------------------------------------------*
2681   *       text
2682   *----------------------------------------------------------------------*
2683   *  -->  p1        text
2684   *  <--  p2        text
2685   *----------------------------------------------------------------------*
2686    FORM EDIT_TEXT.
2687
2688      DATA: L_DISPLAY,
2689            L_USERTITLE,
2690            L_ITCED LIKE ITCED.
2691      L_USERTITLE       = 'X'.
2692      L_ITCED-USERTITLE = L_USERTITLE.
2693
2694      IF ( G_MODE = 'CRE' ) OR  ( G_MODE = 'CHA' ).
2695        L_DISPLAY = ''.
2696      ELSE.
2697        L_DISPLAY = 'X'.
2698      ENDIF.
2699      CALL FUNCTION 'EDIT_TEXT'
2700            EXPORTING
2701                 DISPLAY       = L_DISPLAY
2702                 HEADER        = IST_TEXTID
2703   *************************************************************
2704                 CONTROL       = L_ITCED
2705   *************************************************************
2706            TABLES
2707                 LINES         = IST_DTSPECS
2708            EXCEPTIONS
2709                 ID            = 1
2710                 LANGUAGE      = 2
2711                 LINESIZE      = 3
2712                 NAME          = 4
2713                 OBJECT        = 5
2714                 TEXTFORMAT    = 6
2715                 COMMUNICATION = 7
2716                 OTHERS        = 8.
2717
2718    ENDFORM.                    " edit_text
2719   *&---------------------------------------------------------------------*
2720   *&      Form  SAVE_TEXT
2721   *&---------------------------------------------------------------------*
2722   *       text
2723   *----------------------------------------------------------------------*
2724   *  -->  p1        text
2725   *  <--  p2        text
2726   *----------------------------------------------------------------------*
2727    FORM SAVE_TEXT.
2728
2729      DATA : L_DTSPECS LIKE TLINE.
2730
2731      LOOP AT IST_DTSPECS INTO L_DTSPECS.
2732        TRANSLATE L_DTSPECS TO UPPER CASE.
2733        MODIFY IST_DTSPECS FROM L_DTSPECS INDEX SY-TABIX.
2734      ENDLOOP.
2735
2736      CALL FUNCTION 'SAVE_TEXT'
2737        EXPORTING
2738          CLIENT          = SY-MANDT
2739          HEADER          = WA_TEXTID
2740          SAVEMODE_DIRECT = 'X'
2741        TABLES
2742          LINES           = IST_DTSPECS
2743        EXCEPTIONS
2744          ID              = 1
2745          LANGUAGE        = 2
2746          NAME            = 3
2747          OBJECT          = 4
2748          OTHERS          = 5.
2749      IF SY-SUBRC <> 0.
2750        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
2751                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
2752      ENDIF.
2753
2754    ENDFORM.                    " SAVE_TEXT
2755   *&---------------------------------------------------------------------*
2756   *&      Form  delete_text
2757   *&---------------------------------------------------------------------*
2758   *       text
2759   *----------------------------------------------------------------------*
2760   *  -->  p1        text
2761   *  <--  p2        text
2762   *----------------------------------------------------------------------*
2763    FORM DELETE_TEXT.
2764      CALL FUNCTION 'DELETE_TEXT'
2765        EXPORTING
2766          CLIENT          = SY-MANDT
2767          ID              = WA_TEXTID-TDID
2768          LANGUAGE        = SY-LANGU
2769          NAME            = WA_TEXTID-TDNAME
2770          OBJECT          = WA_TEXTID-TDOBJECT
2771          SAVEMODE_DIRECT = 'X'
2772        EXCEPTIONS
2773          NOT_FOUND       = 1
2774          OTHERS          = 2.
2775
2776      IF SY-SUBRC <> 0.
2777   * MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
2778   *         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
2779      ENDIF.
2780
2781    ENDFORM.                    " delete_text
2782   *&---------------------------------------------------------------------*
2783   *&      Form  delete_addedtext
2784   *&---------------------------------------------------------------------*
2785   *  This subroutine delete the added long text, added during the change
2786   *mode.From the internal table, delete the items other than original
2787   *----------------------------------------------------------------------*
2788   *  -->  p1        text
2789   *  <--  p2        text
2790   *----------------------------------------------------------------------*
2791    FORM DELETE_ADDEDTEXT.
2792      TYPES: BEGIN OF L_ITEMS,
2793              REQNO LIKE ZMM_CDHD-REQNO,
2794              SRNO LIKE ZMM_CDITEM-SRNO,
2795             END OF L_ITEMS.
2796      DATA: L_ITEMS_ITAB TYPE TABLE OF L_ITEMS WITH HEADER LINE.
2797   **************************************************************
2798   ****To get the original items for a reqno
2799      REFRESH L_ITEMS_ITAB.
2800   *
2801      SELECT REQNO SRNO FROM ZMM_CDITEM
2802       INTO CORRESPONDING FIELDS OF TABLE L_ITEMS_ITAB[]
2803                       WHERE REQNO = ZMM_CDHD_ST-REQNO.
2804      IF SY-SUBRC = 0.
2805
2806   ****To delete these numbers from internal table ist_textid_items
2807   ****if found in original items list.
2808        LOOP AT IST_TEXTID_ITEMS INTO WA_TEXTID.
2809          READ TABLE L_ITEMS_ITAB WITH KEY
2810                     REQNO = WA_TEXTID-TDNAME+4(10)
2811                     SRNO  = WA_TEXTID-TDNAME+14(3).
2812          IF SY-SUBRC = 0.
2813            DELETE IST_TEXTID_ITEMS
2814                   WHERE TDOBJECT = WA_TEXTID-TDOBJECT
2815                   AND   TDID     = WA_TEXTID-TDID
2816                   AND   TDNAME   = WA_TEXTID-TDNAME.
2817          ENDIF.
2818        ENDLOOP.
2819      ENDIF.
2820    ENDFORM.                    " delete_addedtext
2821   *&---------------------------------------------------------------------*
2822   *&      Form  undo_longtext
2823   *&---------------------------------------------------------------------*
2824   *       text
2825   *----------------------------------------------------------------------*
2826   *  -->  p1        text
2827   *  <--  p2        text
2828   *----------------------------------------------------------------------*
2829    FORM UNDO_LONGTEXT.
2830      IF NOT IST_TEXTID_ITEMS IS INITIAL.
2831        IF G_MODE = 'CRE'.
2832          LOOP AT IST_TEXTID_ITEMS INTO WA_TEXTID.
2833            PERFORM DELETE_TEXT.
2834          ENDLOOP.
2835          REFRESH IST_TEXTID_ITEMS.
2836        ELSEIF G_MODE = 'CHA'.
2837          PERFORM DELETE_ADDEDTEXT.
2838          LOOP AT IST_TEXTID_ITEMS INTO WA_TEXTID.
2839            PERFORM DELETE_TEXT.
2840          ENDLOOP.
2841          REFRESH IST_TEXTID_ITEMS.
2842        ENDIF.
2843      ENDIF.
2844    ENDFORM.                    " undo_longtext
2845   *&---------------------------------------------------------------------*
2846   *&      Form  text_control_eingabebereit1
2847   *&---------------------------------------------------------------------*
2848   *       text
2849   *----------------------------------------------------------------------*
2850   *  -->  p1        text
2851   *  <--  p2        text
2852   *----------------------------------------------------------------------*
2853    FORM TEXT_CONTROL_EINGABEBEREIT1.
2854      CALL METHOD GV_TEXT_EDITOR1->SET_READONLY_MODE
2855        EXPORTING
2856          READONLY_MODE          = GV_TEXT_EDITOR1->TRUE
2857        EXCEPTIONS
2858          ERROR_CNTL_CALL_METHOD = 1
2859          INVALID_PARAMETER      = 2
2860          OTHERS                 = 3.
2861      IF ( G_MODE = 'CRE' ) OR ( G_MODE = 'CHA' ) OR
2862         ( G_MODE = 'REL' ) OR ( G_MODE = 'MRP' ) OR
2863         ( G_MODE = 'APR' ) OR SY-TCODE = 'ZCODG'.
2864
2865        CALL METHOD GV_TEXT_EDITOR2->SET_READONLY_MODE
2866          EXPORTING
2867            READONLY_MODE          = GV_TEXT_EDITOR2->FALSE
2868          EXCEPTIONS
2869            ERROR_CNTL_CALL_METHOD = 1
2870            INVALID_PARAMETER      = 2
2871            OTHERS                 = 3.
2872      ENDIF.
2873
2874
2875    ENDFORM.                    " text_control_eingabebereit1
2876   *&---------------------------------------------------------------------*
2877   *&      Form  text_control_set_text_table1
2878   *&---------------------------------------------------------------------*
2879   *       text
2880   *----------------------------------------------------------------------*
2881   *  -->  p1        text
2882   *  <--  p2        text
2883   *----------------------------------------------------------------------*
2884    FORM TEXT_CONTROL_SET_TEXT_TABLE1.
2885   *
2886      REFRESH: TLINETAB1,G_LINEFRTO_ITAB.
2887      IF G_MODE <> 'CRE'.
2888        APPEND LINES OF LINES_CORS TO TLINETAB1[].
2889      ENDIF.
2890   *
2891      LOOP AT TLINETAB1[] INTO G_LINE132.
2892        IF ( G_LINE132+0(7) = '* Reply' ) OR
2893           ( G_LINE132+0(7) = '**Reply' ).
2894          G_LINEFRTO-LINE_FR = SY-TABIX.
2895          G_LINEFRTO-LINE_TO = SY-TABIX.
2896          APPEND G_LINEFRTO TO G_LINEFRTO_ITAB.
2897          CLEAR: G_LINEFRTO.
2898        ENDIF.
2899      ENDLOOP.
2900   *
2901      CALL FUNCTION 'CONVERT_ITF_TO_STREAM_TEXT'
2902        TABLES
2903          ITF_TEXT    = TLINETAB1[]
2904          TEXT_STREAM = LT_TEXT_TABLE1.
2905
2906      CALL METHOD GV_TEXT_EDITOR1->SET_TEXT_AS_STREAM
2907        EXPORTING
2908          TEXT            = LT_TEXT_TABLE1
2909        EXCEPTIONS
2910          ERROR_DP        = 1
2911          ERROR_DP_CREATE = 2
2912          OTHERS          = 3.
2913   ********************highlight**************************************
2914      CLEAR G_LINEFRTO.
2915      LOOP AT G_LINEFRTO_ITAB INTO G_LINEFRTO.
2916        CALL METHOD GV_TEXT_EDITOR1->HIGHLIGHT_LINES
2917          EXPORTING
2918            FROM_LINE      = G_LINEFRTO-LINE_FR
2919            TO_LINE        = G_LINEFRTO-LINE_TO
2920            HIGHLIGHT_MODE = 1.
2921      ENDLOOP.
2922   ********************************************************************
2923
2924      IF ( G_MODE = 'CRE' ) OR ( G_MODE = 'CHA' ) OR
2925         ( G_MODE = 'REL' ) OR ( G_MODE = 'MRP' ) OR
2926         ( G_MODE = 'APR' ) OR SY-TCODE = 'ZCODG'.
2927
2928        CALL FUNCTION 'CONVERT_ITF_TO_STREAM_TEXT'
2929          TABLES
2930            ITF_TEXT    = TLINETAB2
2931            TEXT_STREAM = LT_TEXT_TABLE2.
2932
2933        CALL METHOD GV_TEXT_EDITOR2->SET_TEXT_AS_STREAM
2934          EXPORTING
2935            TEXT            = LT_TEXT_TABLE2
2936          EXCEPTIONS
2937            ERROR_DP        = 1
2938            ERROR_DP_CREATE = 2
2939            OTHERS          = 3.
2940      ENDIF.
2941
2942    ENDFORM.                    " text_control_set_text_table1
2943
2944   *&---------------------------------------------------------------------*
2945   *&      Form  get_correspondense
2946   *&---------------------------------------------------------------------*
2947   *       text
2948   *----------------------------------------------------------------------*
2949   *  -->  p1        text
2950   *  <--  p2        text
2951   *----------------------------------------------------------------------*
2952    FORM GET_CORRESPONDENSE.
2953
2954      DATA : L_CORS LIKE THEAD-TDNAME.
2955
2956      IF G_MODE <> 'CRE'.
2957        CONCATENATE 'CORS' ZMM_CDHD_ST-REQNO INTO L_CORS.
2958
2959        CALL FUNCTION 'READ_TEXT'
2960          EXPORTING
2961            CLIENT                  = SY-MANDT
2962            ID                      = 'CORS'
2963            LANGUAGE                = SY-LANGU
2964            NAME                    = L_CORS
2965            OBJECT                  = 'ZMMCD'
2966          TABLES
2967            LINES                   = LINES_CORS
2968          EXCEPTIONS
2969            ID                      = 1
2970            LANGUAGE                = 2
2971            NAME                    = 3
2972            NOT_FOUND               = 4
2973            OBJECT                  = 5
2974            REFERENCE_CHECK         = 6
2975            WRONG_ACCESS_TO_ARCHIVE = 7
2976            OTHERS                  = 8.
2977
2978        IF SY-SUBRC <> 0.
2979   *     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
2980   *     WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
2981          G_CORS = ''.
2982        ELSE.
2983          G_CORS = 'X'.
2984        ENDIF.
2985      ENDIF.
2986
2987    ENDFORM.                    " get_correspondense
2988
2989   *&---------------------------------------------------------------------*
2990   *&      Form  save_cors_text
2991   *&---------------------------------------------------------------------*
2992   *       text
2993   *----------------------------------------------------------------------*
2994   *  -->  p1        text
2995   *  <--  p2        text
2996   *----------------------------------------------------------------------*
2997    FORM SAVE_CORS_TEXT.
2998      DATA: L_THEADER LIKE THEAD.
2999      DATA: L_DATECH(10) TYPE C.
3000   ***********Assignments***********************
3001      CLEAR L_THEADER.
3002      L_THEADER-TDOBJECT   = 'ZMMCD'.
3003      L_THEADER-TDID       = 'CORS'.
3004      L_THEADER-TDSPRAS    =  SY-LANGU.
3005      L_THEADER-TDLINESIZE =  72.
3006      CONCATENATE 'CORS' ZMM_CDHD_ST-REQNO INTO L_THEADER-TDNAME.
3007      APPEND LINES OF TLINETAB2 TO TLINETAB1.
3008   *********************************************
3009      IF NOT TLINETAB1[] IS INITIAL.
3010        CLEAR G_CORES_SENDER.
3011        CONCATENATE SY-DATUM+6(2) '/'
3012                    SY-DATUM+4(2) '/'
3013                    SY-DATUM+0(4) INTO L_DATECH.
3014        CONCATENATE '**Reply' L_DATECH SY-UNAME INTO G_CORES_SENDER
3015         SEPARATED BY '          '.
3016        IF NOT TLINETAB2[] IS INITIAL.
3017          APPEND G_CORES_SENDER TO TLINETAB1.
3018        ENDIF.
3019        CLEAR G_CORES_SENDER.
3020        CALL FUNCTION 'SAVE_TEXT'
3021          EXPORTING
3022            CLIENT          = SY-MANDT
3023            HEADER          = L_THEADER
3024            SAVEMODE_DIRECT = 'X'
3025          TABLES
3026            LINES           = TLINETAB1
3027          EXCEPTIONS
3028            ID              = 1
3029            LANGUAGE        = 2
3030            NAME            = 3
3031            OBJECT          = 4
3032            OTHERS          = 5.
3033
3034        IF SY-SUBRC <> 0.
3035          MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
3036                  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
3037        ENDIF.
3038      ENDIF.
3039
3040    ENDFORM.                    " save_cors_text
3041   *&---------------------------------------------------------------------*
3042   *&      Form  destroy_ctrl
3043   *&---------------------------------------------------------------------*
3044   *       text
3045   *----------------------------------------------------------------------*
3046   *  -->  p1        text
3047   *  <--  p2        text
3048   *----------------------------------------------------------------------*
3049    FORM DESTROY_CTRL.
3050      CASE G_MODE.
3051        WHEN 'CRE' OR 'CHA' OR 'REL' OR 'MRP' OR 'APR'.
3052          CALL METHOD GV_TEXT_EDITOR1->FREE.
3053          CALL METHOD GV_TEXT_EDITOR2->FREE.
3054        WHEN 'DIS' OR 'DEL'.
3055          CALL METHOD GV_TEXT_EDITOR1->FREE.
3056      ENDCASE.
3057      CLEAR:GV_TEXT_EDITOR1,GV_TEXT_EDITOR2.
3058
3059    ENDFORM.                    " destroy_ctrl
3060   *&---------------------------------------------------------------------*
3061   *&      Form  check_items
3062   *&---------------------------------------------------------------------*
3063   *       text
3064   *----------------------------------------------------------------------*
3065   *  -->  p1        text
3066   *  <--  p2        text
3067   *----------------------------------------------------------------------*
3068    FORM CHECK_ITEMS.
3069      DATA : L_T110 TYPE T_TABCTRL110,
3070             L_T120 TYPE T_TABLCTRL120,
3071             L_T130 TYPE T_TABLCTRL130.
3072      CLEAR G_SAVEFLAG.
3073   *
3074      CASE ZMM_CDHD_ST-MTART.
3075        WHEN 'ZSTO'.
3076          READ TABLE G_TABCTRL110_ITAB INTO L_T110 INDEX 1.
3077          IF SY-SUBRC = 0.
3078            IF NOT L_T110-UOM IS INITIAL.
3079              G_SAVEFLAG = 'Y'.
3080            ELSE.
3081              G_SAVEFLAG = 'N'.
3082            ENDIF.
3083          ELSE.
3084            G_SAVEFLAG = 'N'.
3085          ENDIF.
3086   *       If G_duplicate_rec = 'X'.
3087   *         g_saveflag = 'N'.
3088   *         G_duplicate_rec = ''.
3089   *       Endif.
3090        WHEN 'ZSPR'.
3091          READ TABLE G_TABLCTRL120_ITAB INTO L_T120 INDEX 1.
3092          IF SY-SUBRC = 0.
3093            IF NOT L_T120-MANU IS INITIAL.
3094              G_SAVEFLAG = 'Y'.
3095            ELSE.
3096              G_SAVEFLAG = 'N'.
3097            ENDIF.
3098          ELSE.
3099            G_SAVEFLAG = 'N'.
3100          ENDIF.
3101        WHEN 'ZCAP'.
3102          READ TABLE G_TABLCTRL130_ITAB INTO L_T130 INDEX 1.
3103          IF SY-SUBRC = 0.
3104            IF NOT L_T130-UOM IS INITIAL.
3105              G_SAVEFLAG = 'Y'.
3106            ELSE.
3107              G_SAVEFLAG = 'N'.
3108            ENDIF.
3109          ELSE.
3110            G_SAVEFLAG = 'N'.
3111          ENDIF.
3112
3113      ENDCASE.
3114    ENDFORM.                    " check_items
3115   *&---------------------------------------------------------------------*
3116   *&      Form  check_lt_exist
3117   *&---------------------------------------------------------------------*
3118   *       text
3119   *----------------------------------------------------------------------*
3120   *      -->P_L_TDNAME  text
3121   *      -->P_L_LINES  text
3122   *----------------------------------------------------------------------*
3123    FORM CHECK_LT_EXIST USING    P_TDNAME.
3124
3125      REFRESH G_LINES.
3126      CALL FUNCTION 'READ_TEXT'
3127        EXPORTING
3128          CLIENT                  = SY-MANDT
3129          ID                      = 'CDDS'
3130          LANGUAGE                = SY-LANGU
3131          NAME                    = P_TDNAME
3132          OBJECT                  = 'ZMMCD'
3133        TABLES
3134          LINES                   = G_LINES
3135        EXCEPTIONS
3136          ID                      = 1
3137          LANGUAGE                = 2
3138          NAME                    = 3
3139          NOT_FOUND               = 4
3140          OBJECT                  = 5
3141          REFERENCE_CHECK         = 6
3142          WRONG_ACCESS_TO_ARCHIVE = 7
3143          OTHERS                  = 8.
3144
3145      IF SY-SUBRC <> 0.
3146   *     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
3147   *     WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
3148      ENDIF.
3149
3150
3151    ENDFORM.                    " check_lt_exist
3152   *&---------------------------------------------------------------------*
3153   *&      Form  lock_reqhd
3154   *&---------------------------------------------------------------------*
3155   *       text
3156   *----------------------------------------------------------------------*
3157   *  -->  p1        text
3158   *  <--  p2        text
3159   *----------------------------------------------------------------------*
3160    FORM LOCK_REQHD.
3161      CALL FUNCTION 'ENQUEUE_EZ_MM_CDHD'
3162        EXPORTING
3163          MODE_ZMM_CDHD  = 'E'
3164          MANDT          = SY-MANDT
3165          REQNO          = ZMM_CDHD_ST-REQNO
3166        EXCEPTIONS
3167          FOREIGN_LOCK   = 1
3168          SYSTEM_FAILURE = 2
3169          OTHERS         = 3.
3170
3171      IF SY-SUBRC <> 0.
3172        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
3173               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
3174      ELSE.
3175        MOVE 'Y' TO G_LOCK.
3176      ENDIF.
3177
3178    ENDFORM.                    " lock_reqhd
3179   *&---------------------------------------------------------------------*
3180   *&      Form  unlock_req
3181   *&---------------------------------------------------------------------*
3182   *       text
3183   *----------------------------------------------------------------------*
3184   *  -->  p1        text
3185   *  <--  p2        text
3186   *----------------------------------------------------------------------*
3187    FORM UNLOCK_REQ .
3188   *********Header*******************************
3189      CALL FUNCTION 'DEQUEUE_EZ_MM_CDHD'
3190        EXPORTING
3191          MODE_ZMM_CDHD = 'E'
3192          MANDT         = SY-MANDT
3193          REQNO         = ZMM_CDHD_ST-REQNO.
3194
3195    ENDFORM.                    " unlock_req
3196   ***************************************************
3197   *****  AT USER COMMAND IN LIST PROCESSING
3198   ***************************************************
3199    AT USER-COMMAND.
3200      IF OKCODE_100 = 'INS_MODI'.
3201        LEAVE TO SCREEN 0.
3202      ENDIF.
3203      IF SY-UCOMM = 'AGREE'.
3204        IF G_MODE = 'REL'.
3205          PERFORM UPDATE_RELEASE.
3206   *       perform update_noofhits.
3207          PERFORM CLEAR_VAR.
3208        ELSEIF G_MODE = 'APR'.
3209          PERFORM UPDATE_APPROVAL.
3210        ENDIF.
3211        PERFORM CLEAR_VAR.
3212      ENDIF.
3213      LEAVE TO SCREEN 0.
3214   ***************************************************
3215   *&---------------------------------------------------------------------*
3216   *&      Form  other_sectime
3217   *&---------------------------------------------------------------------*
3218   *       text
3219   *----------------------------------------------------------------------*
3220   *  -->  p1        text
3221   *  <--  p2        text
3222   *----------------------------------------------------------------------*
3223    FORM OTHER_SECTIME.
3224      IF SY-TCODE <> 'ZCODG'.
3225        IF ZMM_CDITEM-DESC1 = 'OTHER'.
3226          LOOP AT SCREEN.
3227            IF SCREEN-NAME = 'G_USER_DESC'.
3228              SCREEN-INPUT = 0.
3229              MODIFY SCREEN.
3230            ENDIF.
3231            IF G_PARNO = 3 AND SCREEN-NAME = 'G_DESC4'.
3232              SCREEN-INPUT = 0.
3233              MODIFY SCREEN.
3234            ENDIF.
3235            IF G_PARNO = 2 AND ( SCREEN-NAME = 'G_DESC3' OR
3236                                 SCREEN-NAME = 'G_DESC4' ).
3237              SCREEN-INPUT = 0.
3238              MODIFY SCREEN.
3239            ENDIF.
3240            IF SY-TCODE = 'ZCODG' AND SCREEN-NAME = 'ADNL_DESC'.
3241              SCREEN-INPUT = 0.
3242              MODIFY SCREEN.
3243            ENDIF.
3244            IF SCREEN-NAME = 'G_DESC3' OR SCREEN-NAME = 'G_DESC4'.
3245              SCREEN-REQUIRED = 0.
3246              MODIFY SCREEN.
3247            ENDIF.
3248
3249          ENDLOOP.
3250        ELSEIF ZMM_CDITEM-OTH1 = '' AND
3251   *          ZMM_CDITEM-OTH2 = 'X'.
3252               ZMM_CDITEM-DESC2 = 'OTHER'.
3253
3254
3255          LOOP AT SCREEN.
3256            IF SCREEN-NAME = 'G_USER_DESC' OR
3257               SCREEN-NAME = 'G_DESC1'    OR
3258               SCREEN-NAME = 'G_MATGP'.
3259              SCREEN-INPUT = 0.
3260              MODIFY SCREEN.
3261            ENDIF.
3262            IF G_PARNO = 3 AND SCREEN-NAME = 'G_DESC4'.
3263              SCREEN-INPUT = 0.
3264              MODIFY SCREEN.
3265            ENDIF.
3266            IF G_PARNO = 2 AND ( SCREEN-NAME = 'G_DESC3' OR
3267                                 SCREEN-NAME = 'G_DESC4' ).
3268              SCREEN-INPUT = 0.
3269              MODIFY SCREEN.
3270            ENDIF.
3271            IF SY-TCODE = 'ZCODG' AND SCREEN-NAME = 'ADNL_DESC'.
3272              SCREEN-INPUT = 0.
3273              MODIFY SCREEN.
3274            ENDIF.
3275          ENDLOOP.
3276        ELSEIF ZMM_CDITEM-OTH1 = '' AND
3277               ZMM_CDITEM-OTH2 = '' AND
3278   *          ZMM_CDITEM-OTH3 = 'X' AND
3279               ZMM_CDITEM-DESC3 = 'OTHER'.
3280
3281          LOOP AT SCREEN.
3282            IF SCREEN-NAME = 'G_USER_DESC' OR
3283               SCREEN-NAME = 'G_DESC1'     OR
3284               SCREEN-NAME = 'G_DESC2'     OR
3285               SCREEN-NAME = 'G_MATGP'.
3286              SCREEN-INPUT = 0.
3287              MODIFY SCREEN.
3288            ENDIF.
3289            IF G_PARNO = 3 AND SCREEN-NAME = 'G_DESC4'.
3290              SCREEN-INPUT = 0.
3291              MODIFY SCREEN.
3292            ENDIF.
3293            IF G_PARNO = 2 AND ( SCREEN-NAME = 'G_DESC3' OR
3294                                 SCREEN-NAME = 'G_DESC4' ).
3295              SCREEN-INPUT = 0.
3296              MODIFY SCREEN.
3297            ENDIF.
3298            IF SY-TCODE = 'ZCODG' AND SCREEN-NAME = 'ADNL_DESC'.
3299              SCREEN-INPUT = 0.
3300              MODIFY SCREEN.
3301            ENDIF.
3302
3303          ENDLOOP.
3304
3305        ELSEIF ZMM_CDITEM-OTH1 = '' AND
3306               ZMM_CDITEM-OTH2 = '' AND
3307               ZMM_CDITEM-OTH3 = '' AND
3308   *          ZMM_CDITEM-OTH4 = 'X'.
3309              ZMM_CDITEM-DESC4 = 'OTHER'.
3310
3311          LOOP AT SCREEN.
3312            IF SCREEN-NAME = 'G_USER_DESC' OR
3313               SCREEN-NAME = 'G_DESC1'     OR
3314               SCREEN-NAME = 'G_DESC2'     OR
3315               SCREEN-NAME = 'G_DESC3'     OR
3316               SCREEN-NAME = 'G_MATGP'.
3317
3318              SCREEN-INPUT = 0.
3319              MODIFY SCREEN.
3320            ENDIF.
3321            IF G_PARNO = 3 AND SCREEN-NAME = 'G_DESC4'.
3322              SCREEN-INPUT = 0.
3323              MODIFY SCREEN.
3324            ENDIF.
3325            IF G_PARNO = 2 AND ( SCREEN-NAME = 'G_DESC3' OR
3326                                 SCREEN-NAME = 'G_DESC4' ).
3327              SCREEN-INPUT = 0.
3328              MODIFY SCREEN.
3329            ENDIF.
3330            IF SY-TCODE = 'ZCODG' AND SCREEN-NAME = 'ADNL_DESC'.
3331              SCREEN-INPUT = 0.
3332              MODIFY SCREEN.
3333            ENDIF.
3334
3335          ENDLOOP.
3336        ENDIF.
3337
3338      ELSE.
3339
3340   *     If screen-name = 'ADNL_DESC'.
3341   *        screen = 0.
3342   *        modify screen.
3343   *     Endif.
3344        IF ZMM_CDITEM-DESC1 = 'OTHER'.
3345          LOOP AT SCREEN.
3346            IF SCREEN-NAME = 'G_USER_DESC'.
3347              SCREEN-INPUT = 0.
3348              MODIFY SCREEN.
3349            ENDIF.
3350
3351            IF ZMM_CDITEM-DESC4 IS INITIAL
3352               AND SCREEN-NAME = 'G_DESC4'.
3353              SCREEN-INPUT = 0.
3354              MODIFY SCREEN.
3355            ENDIF.
3356
3357            IF ZMM_CDITEM-DESC3 IS INITIAL
3358               AND SCREEN-NAME = 'G_DESC3'.
3359              SCREEN-INPUT = 0.
3360              MODIFY SCREEN.
3361            ENDIF.
3362
3363            IF SCREEN-NAME = 'G_DESC3' OR SCREEN-NAME = 'G_DESC4'.
3364              SCREEN-REQUIRED = 0.
3365              MODIFY SCREEN.
3366            ENDIF.
3367
3368            IF SY-TCODE = 'ZCODG' AND SCREEN-NAME = 'ADNL_DESC'.
3369              SCREEN-INPUT = 0.
3370              MODIFY SCREEN.
3371            ENDIF.
3372          ENDLOOP.
3373
3374        ELSEIF ZMM_CDITEM-DESC2 = 'OTHER'.
3375   *           ZMM_CDITEM-OTH1 = 'X' AND
3376          LOOP AT SCREEN.
3377            IF SCREEN-NAME = 'G_USER_DESC' OR
3378               SCREEN-NAME = 'G_DESC1'    OR
3379               SCREEN-NAME = 'G_MATGP'.
3380              SCREEN-INPUT = 0.
3381              MODIFY SCREEN.
3382            ENDIF.
3383
3384            IF ZMM_CDITEM-DESC4 IS INITIAL
3385               AND SCREEN-NAME = 'G_DESC4'.
3386              SCREEN-INPUT = 0.
3387              MODIFY SCREEN.
3388            ENDIF.
3389
3390            IF ZMM_CDITEM-DESC3 IS INITIAL
3391               AND SCREEN-NAME = 'G_DESC3'.
3392              SCREEN-INPUT = 0.
3393              MODIFY SCREEN.
3394            ENDIF.
3395
3396            IF SY-TCODE = 'ZCODG' AND SCREEN-NAME = 'ADNL_DESC'.
3397              SCREEN-INPUT = 0.
3398              MODIFY SCREEN.
3399            ENDIF.
3400
3401          ENDLOOP.
3402        ELSEIF ZMM_CDITEM-DESC3 = 'OTHER'.
3403   *     ZMM_CDITEM-OTH2 = 'X' AND
3404
3405
3406          LOOP AT SCREEN.
3407            IF SCREEN-NAME = 'G_USER_DESC' OR
3408               SCREEN-NAME = 'G_DESC1'     OR
3409               SCREEN-NAME = 'G_DESC2'     OR
3410               SCREEN-NAME = 'G_MATGP'.
3411              SCREEN-INPUT = 0.
3412              MODIFY SCREEN.
3413            ENDIF.
3414
3415            IF ZMM_CDITEM-DESC4 IS INITIAL
3416               AND SCREEN-NAME = 'G_DESC4'.
3417              SCREEN-INPUT = 0.
3418              MODIFY SCREEN.
3419            ENDIF.
3420
3421            IF ZMM_CDITEM-DESC3 IS INITIAL
3422               AND SCREEN-NAME = 'G_DESC3'.
3423              SCREEN-INPUT = 0.
3424              MODIFY SCREEN.
3425            ENDIF.
3426            IF SY-TCODE = 'ZCODG' AND SCREEN-NAME = 'ADNL_DESC'.
3427              SCREEN-INPUT = 0.
3428              MODIFY SCREEN.
3429            ENDIF.
3430
3431          ENDLOOP.
3432
3433        ELSEIF  ZMM_CDITEM-DESC4 = 'OTHER'.
3434
3435   *     ZMM_CDITEM-OTH3 = 'X' AND
3436
3437          LOOP AT SCREEN.
3438            IF SCREEN-NAME = 'G_USER_DESC' OR
3439               SCREEN-NAME = 'G_DESC1'     OR
3440               SCREEN-NAME = 'G_DESC2'     OR
3441               SCREEN-NAME = 'G_DESC3'     OR
3442               SCREEN-NAME = 'G_MATGP'.
3443
3444              SCREEN-INPUT = 0.
3445              MODIFY SCREEN.
3446            ENDIF.
3447
3448            IF SY-TCODE = 'ZCODG' AND SCREEN-NAME = 'ADNL_DESC'.
3449              SCREEN-INPUT = 0.
3450              MODIFY SCREEN.
3451            ENDIF.
3452
3453          ENDLOOP.
3454        ENDIF.
3455      ENDIF.
3456    ENDFORM.                    " other_sectime
3457   *&---------------------------------------------------------------------*
3458   *&      Form  sort_sto
3459   *&---------------------------------------------------------------------*
3460   *       text
3461   *----------------------------------------------------------------------*
3462   *      -->P_G_ORDER  text
3463   *----------------------------------------------------------------------*
3464    FORM SORT_STO USING P_ORDER.
3465      READ  TABLE TABCTRL110-COLS WITH  KEY SELECTED = 'X' INTO
3466            WA_TABCTRL110_COLS.
3467      IF SY-SUBRC <> 0.
3468        MESSAGE I084(ZMM_OTH).
3469      ENDIF.
3470      G_SEL_COLSORT = WA_TABCTRL110_COLS-SCREEN-NAME.
3471      IF P_ORDER = 'ASCENDING'.
3472        SORT G_TABCTRL110_ITAB STABLE BY (G_SEL_COLSORT+11) ASCENDING.
3473      ELSEIF P_ORDER = 'DESCENDING'.
3474        SORT G_TABCTRL110_ITAB STABLE BY (G_SEL_COLSORT+11) DESCENDING.
3475      ENDIF.
3476    ENDFORM.                    " sort_sto
3477   *&---------------------------------------------------------------------*
3478   *&      Form  sort_spr
3479   *&---------------------------------------------------------------------*
3480   *       text
3481   *----------------------------------------------------------------------*
3482   *      -->P_G_ORDER  text
3483   *----------------------------------------------------------------------*
3484    FORM SORT_SPR USING    P_ORDER.
3485      READ  TABLE TABLCTRL120-COLS WITH  KEY SELECTED = 'X' INTO
3486            WA_TABLCTRL120_COLS.
3487      IF SY-SUBRC <> 0.
3488        MESSAGE I084(ZMM_OTH).
3489      ENDIF.
3490      G_SEL_COLSORT = WA_TABLCTRL120_COLS-SCREEN-NAME.
3491      IF P_ORDER = 'ASCENDING'.
3492        SORT G_TABLCTRL120_ITAB STABLE BY (G_SEL_COLSORT+11) ASCENDING.
3493      ELSEIF P_ORDER = 'DESCENDING'.
3494        SORT G_TABLCTRL120_ITAB STABLE BY (G_SEL_COLSORT+11) DESCENDING.
3495      ENDIF.
3496    ENDFORM.                    " sort_spr
3497   *&---------------------------------------------------------------------*
3498   *&      Form  sort_cap
3499   *&---------------------------------------------------------------------*
3500   *       text
3501   *----------------------------------------------------------------------*
3502   *      -->P_G_ORDER  text
3503   *----------------------------------------------------------------------*
3504    FORM SORT_CAP USING    P_ORDER.
3505      READ  TABLE TABLCTRL130-COLS WITH  KEY SELECTED = 'X' INTO
3506            WA_TABLCTRL130_COLS.
3507      IF SY-SUBRC <> 0.
3508        MESSAGE I084(ZMM_OTH).
3509      ENDIF.
3510      G_SEL_COLSORT = WA_TABLCTRL130_COLS-SCREEN-NAME.
3511      IF P_ORDER = 'ASCENDING'.
3512        SORT G_TABLCTRL130_ITAB STABLE BY (G_SEL_COLSORT+11) ASCENDING.
3513      ELSEIF P_ORDER = 'DESCENDING'.
3514        SORT G_TABLCTRL130_ITAB STABLE BY (G_SEL_COLSORT+11) DESCENDING.
3515      ENDIF.
3516    ENDFORM.                    " sort_cap
3517   *&---------------------------------------------------------------------*
3518   *&      Form  sort_dis
3519   *&---------------------------------------------------------------------*
3520   *       text
3521   *----------------------------------------------------------------------*
3522   *      -->P_G_ORDER  text
3523   *----------------------------------------------------------------------*
3524    FORM SORT_DIS USING    P_ORDER.
3525      READ  TABLE TABLCTRL140-COLS WITH  KEY SELECTED = 'X' INTO
3526             WA_TABLCTRL140_COLS.
3527      IF SY-SUBRC <> 0.
3528        MESSAGE I084(ZMM_OTH).
3529      ENDIF.
3530      G_SEL_COLSORT = WA_TABLCTRL140_COLS-SCREEN-NAME.
3531      IF P_ORDER = 'ASCENDING'.
3532        SORT G_TABLCTRL140_ITAB STABLE BY (G_SEL_COLSORT+11) ASCENDING.
3533      ELSEIF P_ORDER = 'DESCENDING'.
3534        SORT G_TABLCTRL140_ITAB STABLE BY (G_SEL_COLSORT+11) DESCENDING.
3535      ENDIF.
3536    ENDFORM.                    " sort_dis
3537   *&---------------------------------------------------------------------*
3538   *&      Form  srchlp_spr_del
3539   *&---------------------------------------------------------------------*
3540   *       text
3541   *----------------------------------------------------------------------*
3542   *  -->  p1        text
3543   *  <--  p2        text
3544   *----------------------------------------------------------------------*
3545    FORM SRCHLP_SPR_DEL.
3546
3547      CLEAR G_SPR_PAR.
3548
3549      IF G_SH_CAPEQT = 'X' AND G_SH_MFR = '' AND G_SH_MDLNO = ''.
3550        G_SPR_PAR   = '100'.
3551      ELSEIF G_SH_CAPEQT = 'X' AND G_SH_MFR = 'X' AND G_SH_MDLNO = ''.
3552        G_SPR_PAR   = '120'.
3553      ELSEIF G_SH_CAPEQT = 'X' AND G_SH_MFR = 'X' AND G_SH_MDLNO = 'X'.
3554        G_SPR_PAR   = '123'.
3555      ELSEIF G_SH_CAPEQT = 'X' AND G_SH_MFR = '' AND G_SH_MDLNO = 'X'.
3556        G_SPR_PAR   = '103'.
3557      ELSEIF G_SH_CAPEQT = '' AND G_SH_MFR = 'X' AND G_SH_MDLNO = ''.
3558        G_SPR_PAR   = '020'.
3559      ELSEIF G_SH_CAPEQT = '' AND G_SH_MFR = 'X' AND G_SH_MDLNO = 'X'.
3560        G_SPR_PAR   = '023'.
3561      ELSEIF G_SH_CAPEQT = '' AND G_SH_MFR = '' AND G_SH_MDLNO = 'X'.
3562        G_SPR_PAR   = '003'.
3563      ENDIF.
3564
3565      CASE G_SPR_PAR.
3566        WHEN '100'.
3567          DELETE IST_SRCHLP_CP
3568          WHERE ATWRT <> G_TABLCTRL120_WA-CAP_CODE.  "#EC CI_FLDEXT_OK[2215424]
3569        WHEN '120'.
3570          DELETE IST_SRCHLP_CP
3571          WHERE ATWRT <> G_TABLCTRL120_WA-CAP_CODE.  "#EC CI_FLDEXT_OK[2215424]
3572          DELETE IST_SRCHLP_CP
3573          WHERE MFRNR <> G_TABLCTRL120_WA-MANU.
3574        WHEN '123'.
3575          DELETE IST_SRCHLP_CP
3576          WHERE ATWRT <> G_TABLCTRL120_WA-CAP_CODE.  "#EC CI_FLDEXT_OK[2215424]
3577          DELETE IST_SRCHLP_CP
3578          WHERE MFRNR <> G_TABLCTRL120_WA-MANU.
3579          DELETE IST_SRCHLP_CP
3580          WHERE MDLNO <> G_TABLCTRL120_WA-MDLNO.
3581        WHEN '103'.
3582          DELETE IST_SRCHLP_CP
3583          WHERE ATWRT <> G_TABLCTRL120_WA-CAP_CODE.  "#EC CI_FLDEXT_OK[2215424]
3584          DELETE IST_SRCHLP_CP
3585          WHERE MDLNO <> G_TABLCTRL120_WA-MDLNO.
3586        WHEN '020'.
3587          DELETE IST_SRCHLP_CP
3588          WHERE MFRNR <> G_TABLCTRL120_WA-MANU.
3589        WHEN '023'.
3590          DELETE IST_SRCHLP_CP
3591          WHERE MFRNR <> G_TABLCTRL120_WA-MANU.
3592          DELETE IST_SRCHLP_CP
3593          WHERE MDLNO <> G_TABLCTRL120_WA-MDLNO.
3594        WHEN '003'.
3595          DELETE IST_SRCHLP_CP
3596          WHERE MDLNO <> G_TABLCTRL120_WA-MDLNO.
3597      ENDCASE.
3598
3599    ENDFORM.                    " srchlp_spr_del
3600   *&---------------------------------------------------------------------*
3601   *&      Form  tcode_zcodg_attr
3602   *&---------------------------------------------------------------------*
3603   *       text
3604   *----------------------------------------------------------------------*
3605   *  -->  p1        text
3606   *  <--  p2        text
3607   *----------------------------------------------------------------------*
3608    FORM TCODE_ZCODG_ATTR.
3609      IF SY-TCODE = 'ZCODG' AND G_MODE <> 'DIS'.
3610        LOOP AT SCREEN.
3611          IF SCREEN-GROUP3 = 'GC'.
3612            IF SCREEN-NAME = 'ZMM_CDHD_ST-REQCL'.
3613              PERFORM CHECK_MORETHANONEGRP.
3614              IF G_CODUSER <> 'A'.
3615                IF G_GRPCOUNT > 1.
3616                  SCREEN-INPUT = 0.
3617                  MODIFY SCREEN.
3618                ELSEIF G_GRPCOUNT = 1.
3619                  SCREEN-INPUT = 1.
3620                  MODIFY SCREEN.
3621                ENDIF.
3622              ELSE.
3623                SCREEN-INPUT = 1.
3624                MODIFY SCREEN.
3625              ENDIF.
3626            ELSE.
3627              SCREEN-INPUT = 1.
3628              MODIFY SCREEN.
3629            ENDIF.
3630          ELSEIF SCREEN-NAME = 'ZMM_CDITEM-DESC1'.
3631            IF ZMM_CDITEM-OTH1 = 'X'.
3632              SCREEN-INPUT = 1.
3633            ELSE.
3634              SCREEN-INPUT = 0.
3635            ENDIF.
3636            MODIFY SCREEN.
3637          ELSEIF SCREEN-NAME = 'ZMM_CDITEM-DESC2'.
3638            IF ZMM_CDITEM-OTH1 = 'X' OR
3639               ZMM_CDITEM-OTH2 = 'X'.
3640              SCREEN-INPUT = 1.
3641            ELSE.
3642              SCREEN-INPUT = 0.
3643            ENDIF.
3644            MODIFY SCREEN.
3645          ELSEIF SCREEN-NAME = 'ZMM_CDITEM-DESC3'.
3646            IF ZMM_CDITEM-OTH1 = 'X' OR
3647               ZMM_CDITEM-OTH2 = 'X' OR
3648               ZMM_CDITEM-OTH3 = 'X'.
3649              IF NOT ZMM_CDITEM-DESC3 IS INITIAL.
3650                SCREEN-INPUT = 1.
3651              ENDIF.
3652            ELSE.
3653              SCREEN-INPUT = 0.
3654            ENDIF.
3655            MODIFY SCREEN.
3656          ELSEIF SCREEN-NAME = 'ZMM_CDITEM-DESC4'.
3657            IF ZMM_CDITEM-OTH1 = 'X' OR
3658               ZMM_CDITEM-OTH2 = 'X' OR
3659               ZMM_CDITEM-OTH3 = 'X' OR
3660               ZMM_CDITEM-OTH4 = 'X'.
3661              IF NOT ZMM_CDITEM-DESC4 IS INITIAL.
3662                SCREEN-INPUT = 1.
3663              ENDIF.
3664            ELSE.
3665              SCREEN-INPUT = 0.
3666            ENDIF.
3667            MODIFY SCREEN.
3668   *       elseif screen-name = 'ZMM_CDITEM-USER_DESC'.
3669   *         if not ZMM_CDITEM-USER_DESC is initial.
3670   *           screen-input = 1.
3671   *           modify screen.
3672   *         endif.
3673          ELSEIF SCREEN-NAME = 'ZMM_CDITEM-MDLNO'  OR
3674                 SCREEN-NAME = 'ZMM_CDITEM-PARTNO' OR
3675                 SCREEN-NAME = 'ZMM_CDITEM-MANU'.
3676   *         if ZMM_CDITEM-OTH_MDL = 'X'.
3677            SCREEN-INPUT = 1.
3678            MODIFY SCREEN.
3679   *         else.
3680   *           screen-input = 0.
3681   *           modify screen.
3682   *         endif.
3683          ELSEIF SCREEN-NAME = 'ZMM_CDITEM-DESC_CDCELL'.
3684            SCREEN-INPUT = 1.
3685            MODIFY SCREEN.
3686          ELSEIF SCREEN-NAME = 'WA_SRCHLP-MARK' OR
3687                 SCREEN-NAME = 'DD' OR
3688                 SCREEN-NAME = 'PB_ADNL_DESC'.
3689            SCREEN-INPUT = 1.
3690            MODIFY SCREEN.
3691          ELSEIF SCREEN-NAME = 'G_TABCTRL110_WA-FLAG'. "ZSTO
3692            SCREEN-INPUT = 1.
3693            MODIFY SCREEN.
3694          ELSEIF SCREEN-NAME  = 'G_TABLCTRL120_WA-FLAG'. "ZSPR
3695            SCREEN-INPUT = 1.
3696            MODIFY SCREEN.
3697          ELSEIF SCREEN-NAME  = 'G_TABLCTRL130_WA-FLAG'. "ZCAP
3698            SCREEN-INPUT = 1.
3699            MODIFY SCREEN.
3700          ELSEIF SCREEN-NAME = 'G_TABCTRL110_WA-FLAG'.
3701            SCREEN-INPUT = 1.
3702            MODIFY SCREEN.
3703          ELSE.
3704            SCREEN-INPUT = 0.
3705            MODIFY SCREEN.
3706          ENDIF.
3707          IF NOT G_TABCTRL110_WA-MATCODE IS INITIAL OR
3708             NOT G_TABLCTRL120_WA-MATCODE IS INITIAL OR
3709             NOT G_TABLCTRL130_WA-MATCODE IS INITIAL.
3710            IF SCREEN-GROUP4 = 'MC'.
3711              SCREEN-INPUT = 0.
3712              MODIFY SCREEN.
3713            ENDIF.
3714          ENDIF.
3715        ENDLOOP.
3716      ENDIF.
3717
3718    ENDFORM.                    " tcode_zcodg_attr
3719   *&---------------------------------------------------------------------*
3720   *&      Form  update_codes
3721   *&---------------------------------------------------------------------*
3722   * TO update the created material codes in the request
3723   *----------------------------------------------------------------------*
3724   *  -->  p1        text
3725   *  <--  p2        text
3726   *----------------------------------------------------------------------*
3727    FORM UPDATE_CODES.
3728      REFRESH IST_ZMM_CDITEM.
3729      CASE ZMM_CDHD_ST-MTART.
3730        WHEN 'ZSTO'.
3731          LOOP AT G_TABCTRL110_ITAB INTO G_TABCTRL110_WA.
3732            MOVE-CORRESPONDING G_TABCTRL110_WA TO WA_ZMM_CDITEM.
3733            MOVE ZMM_CDHD_ST-REQNO TO WA_ZMM_CDITEM-REQNO.
3734            IF WA_ZMM_CDITEM-CODCRDT IS INITIAL.
3735              MOVE SY-DATUM TO WA_ZMM_CDITEM-CODCRDT.
3736            ENDIF.
3737            IF WA_ZMM_CDITEM-CODCRBY IS INITIAL.
3738              MOVE SY-UNAME TO WA_ZMM_CDITEM-CODCRBY.
3739            ENDIF.
3740            APPEND WA_ZMM_CDITEM TO IST_ZMM_CDITEM.
3741            CLEAR WA_ZMM_CDITEM.
3742          ENDLOOP.
3743        WHEN 'ZSPR'.
3744          LOOP AT G_TABLCTRL120_ITAB INTO G_TABLCTRL120_WA.
3745            MOVE-CORRESPONDING G_TABLCTRL120_WA TO WA_ZMM_CDITEM.
3746            MOVE ZMM_CDHD_ST-REQNO TO WA_ZMM_CDITEM-REQNO.
3747            IF WA_ZMM_CDITEM-CODCRDT IS INITIAL.
3748              MOVE SY-DATUM TO WA_ZMM_CDITEM-CODCRDT.
3749            ENDIF.
3750            IF WA_ZMM_CDITEM-CODCRBY IS INITIAL.
3751              MOVE SY-UNAME TO WA_ZMM_CDITEM-CODCRBY.
3752            ENDIF.
3753            APPEND WA_ZMM_CDITEM TO IST_ZMM_CDITEM.
3754            CLEAR WA_ZMM_CDITEM.
3755          ENDLOOP.
3756        WHEN 'ZCAP'.
3757          LOOP AT G_TABLCTRL130_ITAB INTO G_TABLCTRL130_WA.
3758            MOVE-CORRESPONDING G_TABLCTRL130_WA TO WA_ZMM_CDITEM.
3759            MOVE ZMM_CDHD_ST-REQNO TO WA_ZMM_CDITEM-REQNO.
3760            IF WA_ZMM_CDITEM-CODCRDT IS INITIAL.
3761              MOVE SY-DATUM TO WA_ZMM_CDITEM-CODCRDT.
3762            ENDIF.
3763            IF WA_ZMM_CDITEM-CODCRBY IS INITIAL.
3764              MOVE SY-UNAME TO WA_ZMM_CDITEM-CODCRBY.
3765            ENDIF.
3766            APPEND WA_ZMM_CDITEM TO IST_ZMM_CDITEM.
3767            CLEAR WA_ZMM_CDITEM.
3768          ENDLOOP.
3769
3770        WHEN 'ZDIS'.
3771          LOOP AT G_TABLCTRL140_ITAB INTO G_TABLCTRL140_WA.
3772            MOVE-CORRESPONDING G_TABLCTRL140_WA TO WA_ZMM_CDITEM.
3773            MOVE ZMM_CDHD_ST-REQNO TO WA_ZMM_CDITEM-REQNO.
3774            IF WA_ZMM_CDITEM-CODCRDT IS INITIAL.
3775              MOVE SY-DATUM TO WA_ZMM_CDITEM-CODCRDT.
3776            ENDIF.
3777            IF WA_ZMM_CDITEM-CODCRBY IS INITIAL.
3778              MOVE SY-UNAME TO WA_ZMM_CDITEM-CODCRBY.
3779            ENDIF.
3780            APPEND WA_ZMM_CDITEM TO IST_ZMM_CDITEM.
3781            CLEAR WA_ZMM_CDITEM.
3782          ENDLOOP.
3783      ENDCASE.
3784      MODIFY ZMM_CDITEM FROM TABLE IST_ZMM_CDITEM.
3785   ************************************************************
3786   ****Saving the long text.                              *****
3787   ************************************************************
3788   ******Header(Correspondence)********************************
3789      PERFORM SAVE_CORS_TEXT.
3790
3791    ENDFORM.                    " update_codes
3792   *&---------------------------------------------------------------------*
3793   *&      Form  check_reqstatus
3794   *&---------------------------------------------------------------------*
3795   *       text
3796   *----------------------------------------------------------------------*
3797   *  -->  p1        text
3798   *  <--  p2        text
3799   *----------------------------------------------------------------------*
3800    FORM CHECK_REQSTATUS.
3801      DATA : L_110_ITAB TYPE TABLE OF T_TABCTRL110,
3802             L_120_ITAB TYPE TABLE OF T_TABLCTRL120,
3803             L_130_ITAB TYPE TABLE OF T_TABLCTRL130,
3804             L_140_ITAB TYPE TABLE OF T_TABLCTRL140.
3805      DATA : L_TITEM TYPE I,
3806             L_CITEM TYPE I,
3807             L_DCITEM TYPE I,
3808             L_RAITEM TYPE I,
3809             L_ITEM   TYPE I.
3810      CLEAR: L_TITEM,L_CITEM,L_DCITEM,L_RAITEM.
3811
3812      SELECT COUNT(*) INTO L_TITEM FROM ZMM_CDITEM
3813             WHERE REQNO = ZMM_CDHD_ST-REQNO.
3814   *
3815      CASE ZMM_CDHD_ST-MTART.
3816        WHEN 'ZSTO'.
3817          REFRESH L_110_ITAB.
3818          APPEND LINES OF G_TABCTRL110_ITAB TO L_110_ITAB.
3819          DELETE L_110_ITAB WHERE MATCODE = ''.
3820          DESCRIBE TABLE L_110_ITAB LINES L_CITEM.
3821        WHEN 'ZSPR'.
3822          REFRESH L_120_ITAB.
3823          APPEND LINES OF G_TABLCTRL120_ITAB TO L_120_ITAB.
3824          DELETE L_120_ITAB WHERE MATCODE = ''.
3825          DESCRIBE TABLE L_120_ITAB LINES L_CITEM.
3826        WHEN 'ZCAP'.
3827          REFRESH L_130_ITAB.
3828          APPEND LINES OF G_TABLCTRL130_ITAB TO L_130_ITAB.
3829          DELETE L_130_ITAB WHERE MATCODE = ''.
3830          DESCRIBE TABLE L_130_ITAB LINES L_CITEM.
3831        WHEN 'ZDIS'.
3832          REFRESH L_140_ITAB.
3833          APPEND LINES OF G_TABLCTRL140_ITAB TO L_140_ITAB.
3834          DELETE L_140_ITAB WHERE MATCODE = ''.
3835          DESCRIBE TABLE L_140_ITAB LINES L_CITEM.
3836      ENDCASE.
3837   ***
3838      IF L_CITEM = L_TITEM.
3839        MOVE 'C' TO ZMM_CDHD_ST-REQCL.
3840      ELSEIF L_CITEM < L_TITEM.
3841        IF ZMM_CDHD_ST-REQCL <> 'IR'.
3842          MOVE 'IC' TO ZMM_CDHD_ST-REQCL.
3843        ENDIF.
3844      ENDIF.
3845   ***
3846      SELECT COUNT(*) INTO L_DCITEM FROM ZMM_CDITEM
3847             WHERE REQNO = ZMM_CDHD_ST-REQNO
3848             AND   MATCODE <> ''.
3849      SELECT COUNT(*) INTO L_RAITEM FROM ZMM_CDITEM
3850             WHERE REQNO = ZMM_CDHD_ST-REQNO
3851             AND   REJ_FLG IN ('RM','RT').
3852   ***
3853
3854      IF ZMM_CDHD_ST-REQCL = 'N' OR
3855         ZMM_CDHD_ST-REQCL = 'IC'.
3856        L_ITEM = L_DCITEM + L_RAITEM.
3857        IF L_TITEM = L_ITEM.
3858          MOVE 'C' TO ZMM_CDHD_ST-REQCL.
3859        ENDIF.
3860      ENDIF.
3861
3862    ENDFORM.                    " check_reqstatus
3863   *&---------------------------------------------------------------------*
3864   *&---------------------------------------------------------------------*
3865   *&      Form  send_mail_to_cdcell
3866   *&---------------------------------------------------------------------*
3867   *       text
3868   *----------------------------------------------------------------------*
3869   *  -->  p1        text
3870   *  <--  p2        text
3871   *----------------------------------------------------------------------*
3872    FORM SEND_MAIL_TO_CDCELL.
3873      DATA: L_TEXT  TYPE SOLI,
3874            L_NAME  LIKE SOOD1-OBJNAM,
3875            L_TITLE LIKE SOOD1-OBJDES,
3876            L_USER  LIKE SY-UNAME.
3877      DATA  L_TEXT_ITAB LIKE TABLE OF L_TEXT.
3878      CLEAR : L_NAME,L_TITLE,L_TEXT,L_USER.
3879      REFRESH L_TEXT_ITAB.
3880   **Assignments.....
3881      L_NAME   = ZMM_CDHD_ST-REQNO.
3882      CONCATENATE 'New MatCode Request for' ZMM_CDHD_ST-REQNO
3883                  INTO L_TITLE SEPARATED BY SPACE.
3884      L_TEXT = 'Please check the Request and provide the new material codes.'
3885               &'This is a system generated mail, please do not reply.'.
3886      APPEND L_TEXT TO L_TEXT_ITAB.
3887
3888      L_USER = 'CODIFICATION'.
3889
3890   ***Function
3891      CALL FUNCTION 'RS_SEND_MAIL_FOR_SPOOLLIST'
3892        EXPORTING
3893   *
3894          MAILNAME          = L_NAME
3895          MAILTITEL         = L_TITLE
3896          USER              = L_USER
3897       TABLES
3898         TEXT              =  L_TEXT_ITAB.
3899
3900      IF SY-SUBRC <> 0.
3901   * MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
3902   *         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
3903      ENDIF.
3904
3905    ENDFORM.                    " send_mail_to_cdcell
3906   *&---------------------------------------------------------------------*
3907   *&      Form  send_mail_to_reqn
3908   *&---------------------------------------------------------------------*
3909   *       text
3910   *----------------------------------------------------------------------*
3911   *  -->  p1        text
3912   *  <--  p2        text
3913   *----------------------------------------------------------------------*
3914    FORM SEND_MAIL_TO_REQN.
3915      DATA:  R_TEXT  TYPE SOLI,
3916             R_NAME  LIKE SOOD1-OBJNAM,
3917             R_TITLE LIKE SOOD1-OBJDES,
3918             R_USER  TYPE SY-UNAME.
3919      DATA:  R_TEXT_ITAB LIKE TABLE OF R_TEXT.
3920      CLEAR : R_NAME,R_TITLE,R_TEXT.
3921      REFRESH R_TEXT_ITAB.
3922   **Assignments.....
3923      R_NAME   = ZMM_CDHD_ST-REQNO.
3924      CONCATENATE 'Request' ZMM_CDHD_ST-REQNO 'Status'
3925                  INTO R_TITLE SEPARATED BY SPACE.
3926      IF ZMM_CDHD_ST-REQCL = 'C'.
3927        R_TEXT = 'Request has been updated.Please check the Request,Request'
3928      &'status and Correspondence within it.This is a system generated mail,'
3929      &'please do not reply. - Codification Cell'.
3930        APPEND R_TEXT TO R_TEXT_ITAB.
3931      ELSEIF ZMM_CDHD_ST-REQCL = 'IR'.
3932        R_TEXT = 'Please go through the correspondence comments if any & the'
3933      &'request. After changes, the request should be re-released, re-approved'
3934      &'by the MRP controller and re-approved by Technical Approving'.
3935        APPEND R_TEXT TO R_TEXT_ITAB.
3936        CLEAR R_TEXT.
3937        R_TEXT = 'Authority(L2 or above) if required as per release strategy.'
3938      &'All the actions taken should be recorded only in correspondence. No'
3939      &'separate communication will be entertained. This is a system generated'
3940      &'mail.Please do not reply'.
3941        APPEND R_TEXT TO R_TEXT_ITAB.
3942      ENDIF.
3943
3944   *   append r_text to r_text_itab.
3945      SELECT SINGLE REQCPF INTO R_USER FROM ZMM_CDHD
3946             WHERE REQNO = ZMM_CDHD_ST-REQNO.
3947   ***Function
3948      CALL FUNCTION 'RS_SEND_MAIL_FOR_SPOOLLIST'
3949        EXPORTING
3950   *
3951          MAILNAME          = R_NAME
3952          MAILTITEL         = R_TITLE
3953          USER              = R_USER
3954       TABLES
3955         TEXT              =  R_TEXT_ITAB
3956       EXCEPTIONS
3957         ERROR             = 1
3958         OTHERS            = 2.
3959      IF SY-SUBRC <> 0.
3960   * MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
3961   *         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
3962      ENDIF.
3963
3964    ENDFORM.                    " send_mail_to_reqn
3965   *&---------------------------------------------------------------------*
3966   *&      Form  confirm_deletion
3967   *&---------------------------------------------------------------------*
3968   *       text
3969   *----------------------------------------------------------------------*
3970   *  -->  p1        text
3971   *  <--  p2        text
3972   *----------------------------------------------------------------------*
3973    FORM CONFIRM_DELETION.
3974      " Begin of <RD1K960036>.
3975   *   CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
3976   *    EXPORTING
3977   *    TEXTLINE1            = 'Once deleted can not be restore, Continue?'
3978   *     TITEL                = 'Confirm Deletion'
3979   *     START_COLUMN         = 25
3980   *     START_ROW            = 6
3981   *     CANCEL_DISPLAY       = ''
3982   *    IMPORTING
3983   *     ANSWER               = g_confdel.
3984      DATA : L_GET8(1) TYPE C.
3985      CALL FUNCTION 'POPUP_TO_CONFIRM'
3986        EXPORTING
3987         TITLEBAR                    = 'Confirm Deletion'
3988   *      DIAGNOSE_OBJECT             = ' '
3989          TEXT_QUESTION               = 'Once deleted can not be restore, Continue?'
3990   *      TEXT_BUTTON_1               = 'Ja'(001)
3991   *      ICON_BUTTON_1               = ' '
3992   *      TEXT_BUTTON_2               = 'Nein'(002)
3993   *      ICON_BUTTON_2               = ' '
3994   *      DEFAULT_BUTTON              = '1'
3995   *      DISPLAY_CANCEL_BUTTON       = 'X'
3996   *      USERDEFINED_F1_HELP         = ' '
3997         START_COLUMN                = 25
3998         START_ROW                   = 6
3999   *      POPUP_TYPE                  =
4000   *      IV_QUICKINFO_BUTTON_1       = ' '
4001   *      IV_QUICKINFO_BUTTON_2       = ' '
4002       IMPORTING
4003         ANSWER                      = L_GET8
4004   *    TABLES
4005   *      PARAMETER                   =
4006       EXCEPTIONS
4007         TEXT_NOT_FOUND              = 1
4008         OTHERS                      = 2
4009                .
4010      IF SY-SUBRC = 0.
4011        CASE L_GET8.
4012          WHEN '1'.
4013            MOVE 'J' TO G_CONFDEL.
4014          WHEN '2'.
4015            MOVE 'N' TO G_CONFDEL.
4016        ENDCASE.
4017      ENDIF.
4018
4019      " End of <RD1K960036>.
4020    ENDFORM.                    " confirm_deletion
4021
4022   *----------------------------------------------------------------------*
4023   *&      Form  GC_FIELDS_115
4024   *&---------------------------------------------------------------------*
4025   *       text
4026   *----------------------------------------------------------------------*
4027   *  -->  p1        text
4028   *  <--  p2        text
4029   *----------------------------------------------------------------------*
4030    FORM GC_FIELDS_115.
4031      IF G_OK_CODE115 = 'OK115'.
4032        IF G_OK_CODE110 = 'PB_AD'.
4033          G_TABCTRL110_WA-USER_DESC = G_USER_DESC.
4034          CONCATENATE G_TABCTRL110_WA-DESC_FIN
4035                     G_TABCTRL110_WA-USER_DESC
4036                INTO G_TABCTRL110_WA-DESC_FIN
4037                SEPARATED BY SPACE.
4038          CONDENSE G_TABCTRL110_WA-DESC_FIN.
4039          G_OTH = ''.
4040          G_USER_DESC = ''.
4041        ELSE.
4042   *     case 'X'.
4043          CASE 'OTHER'.
4044   *       when g_TABCTRL110_wa-oth1.
4045            WHEN ZMM_CDITEM-DESC1.
4046              G_TABCTRL110_WA-DESC1 = G_DESC1.
4047              G_TABCTRL110_WA-DESC2 = G_DESC2.
4048              G_TABCTRL110_WA-DESC3 = G_DESC3.
4049              G_TABCTRL110_WA-DESC4 = G_DESC4.
4050              G_TABCTRL110_WA-MATGP = G_MATGP.
4051              CLEAR : G_DESC1,G_DESC2,G_DESC3,G_DESC4.
4052   *         move : 'X' to g_TABCTRL110_wa-oth2.
4053              G_TABCTRL110_WA-OTH1 = 'X'.
4054              G_TABCTRL110_WA-OTH2 = 'X'.
4055
4056   *+
4057              IF G_TABCTRL110_WA-DESC3 <> ''.
4058                G_TABCTRL110_WA-OTH3 = 'X'.
4059              ELSE.
4060                G_TABCTRL110_WA-OTH3 = ''.
4061              ENDIF.
4062
4063              IF G_TABCTRL110_WA-DESC4 <> ''.
4064                G_TABCTRL110_WA-OTH4 = 'X'.
4065              ELSE.
4066                G_TABCTRL110_WA-OTH4 = ''.
4067              ENDIF.
4068   *-
4069              G_TABCTRL110_WA-USER_DESC = G_USER_DESC.
4070              LOOP AT SCREEN.
4071                IF SCREEN-NAME = 'ZMM_CDITEM-DESC1' OR
4072                   SCREEN-NAME = 'ZMM_CDITEM-DESC2' OR
4073                   SCREEN-NAME = 'ZMM_CDITEM-DESC3' OR
4074                   SCREEN-NAME = 'ZMM_CDITEM-DESC4'.
4075                  SCREEN-INTENSIFIED = 1.
4076                  MODIFY SCREEN.
4077                ENDIF.
4078              ENDLOOP.
4079   *       when g_TABCTRL110_wa-oth2.
4080            WHEN ZMM_CDITEM-DESC2.
4081              G_TABCTRL110_WA-DESC2 = G_DESC2.    "+
4082              G_TABCTRL110_WA-DESC3 = G_DESC3.    "+
4083              G_TABCTRL110_WA-DESC4 = G_DESC4.    "+
4084   *+
4085              G_TABCTRL110_WA-OTH2 = 'X'.
4086
4087              IF G_TABCTRL110_WA-DESC3 <> ''.
4088                G_TABCTRL110_WA-OTH3 = 'X'.
4089              ELSE.
4090                G_TABCTRL110_WA-OTH3 = ''.
4091              ENDIF.
4092              IF G_TABCTRL110_WA-DESC4 <> ''.
4093                G_TABCTRL110_WA-OTH4 = 'X'.
4094              ELSE.
4095                G_TABCTRL110_WA-OTH4 = ''.
4096              ENDIF.
4097   *-
4098              CLEAR : G_DESC2,G_DESC3,G_DESC4.
4099              G_TABCTRL110_WA-USER_DESC = G_USER_DESC.
4100              IF G_MODE = 'CHA'.
4101                MODIFY G_TABCTRL110_ITAB FROM G_TABCTRL110_WA INDEX
4102                G_CURR_LINE_110.
4103              ENDIF.
4104            WHEN ZMM_CDITEM-DESC3.
4105              G_TABCTRL110_WA-DESC3 = G_DESC3.    "+
4106              G_TABCTRL110_WA-DESC4 = G_DESC4.    "+
4107              G_TABCTRL110_WA-OTH3 = 'X'.
4108
4109              IF G_TABCTRL110_WA-DESC4 <> ''.
4110                MOVE 'X' TO G_TABCTRL110_WA-OTH4.
4111              ELSE.
4112                MOVE '' TO G_TABCTRL110_WA-OTH4.
4113              ENDIF.
4114
4115              G_TABCTRL110_WA-USER_DESC = G_USER_DESC.
4116              IF G_MODE = 'CHA'.
4117                MODIFY G_TABCTRL110_ITAB FROM G_TABCTRL110_WA INDEX
4118                G_CURR_LINE_110.
4119              ENDIF.
4120
4121              CLEAR : G_DESC3,G_DESC4.
4122            WHEN ZMM_CDITEM-DESC4.
4123              G_TABCTRL110_WA-DESC4 = G_DESC4.     "+
4124              G_TABCTRL110_WA-OTH4 = 'X'.
4125              G_TABCTRL110_WA-USER_DESC = G_USER_DESC.
4126              CLEAR : G_DESC4.
4127          ENDCASE.
4128        ENDIF.
4129      ELSE.
4130
4131      ENDIF.
4132
4133      CLEAR : G_DESC1,G_DESC2,G_DESC3,G_DESC4,G_OK_CODE110,G_USER_DESC,
4134              G_MATGP.
4135      CLEAR : G_OK_CODE115. "+
4136
4137
4138
4139    ENDFORM.                    " GC_FIELDS_115
4140   *&---------------------------------------------------------------------*
4141   *&      Form  GC_input_keywords
4142   *&---------------------------------------------------------------------*
4143   *       text
4144   *----------------------------------------------------------------------*
4145   *  -->  p1        text
4146   *  <--  p2        text
4147   *----------------------------------------------------------------------*
4148    FORM GC_INPUT_KEYWORDS.
4149      CASE 'X'.
4150        WHEN G_TABCTRL110_WA-OTH2.
4151          LOOP AT SCREEN.
4152            IF SCREEN-NAME = 'G_DESC1'.
4153              SCREEN-INPUT = 0.
4154              SCREEN-INTENSIFIED = 1.
4155              MODIFY SCREEN.
4156            ENDIF.
4157          ENDLOOP.
4158          G_DESC1 = G_TABCTRL110_WA-DESC1.
4159        WHEN G_TABCTRL110_WA-OTH3.
4160          LOOP AT SCREEN.
4161            IF SCREEN-NAME = 'G_DESC1' OR SCREEN-NAME = 'G_DESC2'.
4162              SCREEN-INPUT = 0.
4163              SCREEN-INTENSIFIED = 1.
4164
4165              MODIFY SCREEN.
4166            ENDIF.
4167          ENDLOOP.
4168          G_DESC1 = G_TABCTRL110_WA-DESC1.
4169          G_DESC2 = G_TABCTRL110_WA-DESC2.
4170
4171        WHEN G_TABCTRL110_WA-OTH4.
4172          LOOP AT SCREEN.
4173            IF SCREEN-NAME = 'G_DESC1' OR SCREEN-NAME = 'G_DESC2' OR
4174               SCREEN-NAME = 'G_DESC3'.
4175              SCREEN-INPUT = 0.
4176              SCREEN-INTENSIFIED = 1.
4177
4178              MODIFY SCREEN.
4179            ENDIF.
4180
4181          ENDLOOP.
4182          G_DESC1 = G_TABCTRL110_WA-DESC1.
4183          G_DESC2 = G_TABCTRL110_WA-DESC2.
4184          G_DESC3 = G_TABCTRL110_WA-DESC3.
4185      ENDCASE.
4186    ENDFORM.                    " GC_input_keywords
4187   *&---------------------------------------------------------------------*
4188   *&      Module  GC_CURSOR  INPUT
4189   *&---------------------------------------------------------------------*
4190   *       text
4191   *----------------------------------------------------------------------*
4192    MODULE GC_CURSOR INPUT.
4193    ENDMODULE.                 " GC_CURSOR  INPUT
4194   *&---------------------------------------------------------------------*
4195   *&      Form  SELECT_MATERIAL_DETAILS
4196   *&---------------------------------------------------------------------*
4197   *       text
4198   *----------------------------------------------------------------------*
4199   *  -->  p1        text
4200   *  <--  p2        text
4201   *----------------------------------------------------------------------*
4202    FORM SELECT_MATERIAL_DETAILS.
4203
4204      CLEAR DO_NOT_CHANGE_FLAG.
4205
4206      IF G_MODE = 'CRE' OR G_MODE = 'CHA'.
4207
4208        CASE G_HITS_PAR.
4209
4210          WHEN '0'.
4211            G_MAT_FND = '0'.
4212          WHEN '1'.
4213            IF CHECK_POS = 1
4214               AND DESC22 IS INITIAL
4215               AND DESC33 IS INITIAL
4216               AND DESC44 IS INITIAL.
4217              DESCRIBE TABLE IST_SRCHLP LINES G_MAT_FND.
4218              IF G_MAT_FND = 0.
4219                G_MAT_FND_FLAG = 'X'.
4220              ENDIF.
4221            ENDIF.
4222          WHEN '2'.
4223            IF CHECK_POS = 2
4224               AND DESC33 IS INITIAL
4225               AND DESC44 IS INITIAL.
4226              DESCRIBE TABLE IST_SRCHLP LINES G_MAT_FND.
4227              IF G_MAT_FND = 0.
4228                G_MAT_FND_FLAG = 'X'.
4229              ENDIF.
4230            ENDIF.
4231          WHEN '3'.
4232            IF CHECK_POS = 3
4233               AND DESC44 IS INITIAL.
4234              DESCRIBE TABLE IST_SRCHLP LINES G_MAT_FND.
4235              IF G_MAT_FND = 0.
4236                G_MAT_FND_FLAG = 'X'.
4237              ENDIF.
4238            ENDIF.
4239          WHEN '4'.
4240            IF CHECK_POS = 4. .
4241              DESCRIBE TABLE IST_SRCHLP LINES G_MAT_FND.
4242              IF G_MAT_FND = 0.
4243                G_MAT_FND_FLAG = 'X'.
4244              ENDIF.
4245            ENDIF.
4246            IF G_HITS_PAR_OTH = 'X'.
4247              DESCRIBE TABLE IST_SRCHLP LINES G_MAT_FND.
4248              IF G_MAT_FND = 0.
4249                G_MAT_FND_FLAG = 'X'.
4250              ENDIF.
4251              CLEAR G_HITS_PAR_OTH.
4252            ENDIF.
4253          WHEN OTHERS.
4254            CLEAR G_MAT_FND.
4255
4256        ENDCASE.
4257
4258        IF G_LINENO_OLD <> G_LINENO.
4259   *     clear g_mat_fnd.
4260          DO_NOT_CHANGE_FLAG = 'X'.
4261        ENDIF.
4262
4263        CLEAR G_HITS_PAR.
4264
4265      ENDIF.
4266
4267      LOOP AT IST_SRCHLP INTO WA_SRCHLP.
4268
4269        DATA : L_MATNR LIKE THEAD-TDNAME.
4270        L_MATNR = WA_SRCHLP-MATNR.
4271
4272        CALL FUNCTION 'READ_TEXT'
4273          EXPORTING
4274   *
4275            ID                            = 'BEST'
4276            LANGUAGE                      = 'E'
4277            NAME                          =  L_MATNR
4278            OBJECT                        = 'MATERIAL'
4279          TABLES
4280            LINES                         = LINES
4281          EXCEPTIONS
4282             ID                            = 1
4283             LANGUAGE                      = 2
4284             NAME                          = 3
4285             NOT_FOUND                     = 4
4286             OBJECT                        = 5
4287             REFERENCE_CHECK               = 6
4288             WRONG_ACCESS_TO_ARCHIVE       = 7
4289             OTHERS                        = 8.
4290
4291        IF SY-SUBRC <> 0.
4292   *      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
4293   *      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
4294          WA_SRCHLP-MARK = '1'.
4295          MODIFY IST_SRCHLP FROM WA_SRCHLP.
4296        ENDIF.
4297
4298      ENDLOOP.
4299
4300    ENDFORM.                    " SELECT_MATERIAL_DETAILS
4301   *&---------------------------------------------------------------------*
4302   *&      Form  Display_text
4303   *&---------------------------------------------------------------------*
4304   *       text
4305   *----------------------------------------------------------------------*
4306   *  -->  p1        text
4307   *  <--  p2        text
4308   *----------------------------------------------------------------------*
4309    FORM DISPLAY_TEXT.
4310
4311      DATA : L_MATNR LIKE THEAD-TDNAME.
4312      DATA : L_HEADER LIKE THEAD.
4313      DATA : I LIKE SY-TABIX.
4314      READ TABLE IST_SRCHLP INTO WA_SRCHLP INDEX G_CURR_LINE_100.
4315      L_MATNR = WA_SRCHLP-MATNR.
4316
4317   *
4318      IF NOT L_MATNR IS INITIAL AND
4319        G_CURR_LINE_100 <> 0.
4320        CALL FUNCTION 'READ_TEXT'
4321          EXPORTING
4322   *
4323            ID                            = 'BEST'
4324            LANGUAGE                      = 'E'
4325            NAME                          = L_MATNR
4326            OBJECT                        = 'MATERIAL'
4327   *
4328          TABLES
4329            LINES                         = TLINETAB
4330     EXCEPTIONS
4331       ID                            = 1
4332       LANGUAGE                      = 2
4333       NAME                          = 3
4334       NOT_FOUND                     = 4
4335       OBJECT                        = 5
4336       REFERENCE_CHECK               = 6
4337       WRONG_ACCESS_TO_ARCHIVE       = 7
4338       OTHERS                        = 8
4339                  .
4340        IF SY-SUBRC <> 0.
4341
4342          MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
4343                  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
4344        ENDIF.
4345
4346
4347        CALL SCREEN 117 STARTING AT 70 15 ENDING AT 130 24.
4348
4349      ENDIF.
4350
4351    ENDFORM.                    " Display_text
4352   *&---------------------------------------------------------------------*
4353   *&      Form  text_control_eingabebereit
4354   *&---------------------------------------------------------------------*
4355   *       text
4356   *----------------------------------------------------------------------*
4357   *  -->  p1        text
4358   *  <--  p2        text
4359   *----------------------------------------------------------------------*
4360    FORM TEXT_CONTROL_EINGABEBEREIT.
4361
4362      CALL METHOD GV_TEXT_EDITOR->SET_READONLY_MODE
4363        EXPORTING
4364          READONLY_MODE          = GV_TEXT_EDITOR->TRUE
4365        EXCEPTIONS
4366          ERROR_CNTL_CALL_METHOD = 1
4367          INVALID_PARAMETER      = 2
4368          OTHERS                 = 3.
4369
4370    ENDFORM.                    " text_control_eingabebereit
4371   *&---------------------------------------------------------------------*
4372   *&      Form  text_control_set_text_table
4373   *&---------------------------------------------------------------------*
4374   *       text
4375   *----------------------------------------------------------------------*
4376   *  -->  p1        text
4377   *  <--  p2        text
4378   *----------------------------------------------------------------------*
4379    FORM TEXT_CONTROL_SET_TEXT_TABLE.
4380
4381      CALL FUNCTION 'CONVERT_ITF_TO_STREAM_TEXT'
4382        TABLES
4383          ITF_TEXT    = TLINETAB
4384          TEXT_STREAM = LT_TEXT_TABLE.
4385
4386      CALL METHOD GV_TEXT_EDITOR->SET_TEXT_AS_STREAM
4387        EXPORTING
4388          TEXT            = LT_TEXT_TABLE
4389        EXCEPTIONS
4390          ERROR_DP        = 1
4391          ERROR_DP_CREATE = 2
4392          OTHERS          = 3.
4393
4394    ENDFORM.                    " text_control_set_text_table
4395
4396
4397   *&---------------------------------------------------------------------*
4398   *&      Form  clear_srchlp_parms
4399   *&---------------------------------------------------------------------*
4400   *       text
4401   *----------------------------------------------------------------------*
4402   *  -->  p1        text
4403   *  <--  p2        text
4404   *----------------------------------------------------------------------*
4405    FORM CLEAR_SRCHLP_PARMS.
4406
4407      CLEAR : DESC11, DESC22, DESC33, DESC44, DESC55, G_PARTNO, G_MATGP,
4408              G_MATTY, SEL_FLAG.
4409
4410    ENDFORM.                    " clear_srchlp_parms
4411   *&---------------------------------------------------------------------*
4412   *&      Form  Create_matcode
4413   *&---------------------------------------------------------------------*
4414   *       text
4415   *----------------------------------------------------------------------*
4416   *  -->  p1        text
4417   *  <--  p2        text
4418   *----------------------------------------------------------------------*
4419    FORM CREATE_MATCODE.
4420
4421      DATA : L_NUM1 TYPE SY-INDEX.
4422      DATA : L_NUM2(3) TYPE C.
4423      DATA : L_CAP130 TYPE T_TABLCTRL130.
4424
4425
4426      IF ZMM_CDHD_ST-MTART = 'ZCAP'.
4427        READ TABLE G_TABLCTRL130_ITAB INTO L_CAP130
4428             WITH KEY SPA_GRP = ''.
4429        IF SY-SUBRC = 0.
4430          MESSAGE I083(ZMM_OTH).
4431          CLEAR OKCODE_100.
4432          EXIT.
4433        ENDIF.
4434      ENDIF.
4435
4436
4437      IF G_NEW_CAP_RANGE <> 'X'.
4438        PERFORM MATCODE_CONFIRM.
4439        CHECK A_CHOICE = 'J'.
4440      ELSE.
4441        CLEAR G_NEW_CAP_RANGE.
4442      ENDIF.
4443
4444      DO 26 TIMES.
4445
4446        IT_ALPHA_NUM1-ALPHA = ALPHA+L_NUM1(1).
4447        L_NUM2 = L_NUM2 + 10.
4448
4449        IF L_NUM2 < 100.
4450          CONCATENATE '0' L_NUM2 INTO L_NUM2.
4451        ENDIF.
4452        IT_ALPHA_NUM1-NUMBER = L_NUM2.
4453        L_NUM1 = L_NUM1 + 1.
4454        APPEND IT_ALPHA_NUM1.
4455      ENDDO.
4456
4457      CASE ZMM_CDHD_ST-MTART.
4458
4459        WHEN 'ZSTO'.
4460
4461          DATA : L_MAT_LEN LIKE SY-INDEX.
4462          DATA : L_DESC(87) TYPE C.
4463          DATA : L_DESC1(40) TYPE C, L_DESC2(48) TYPE C.
4464
4465          LOOP AT G_TABCTRL110_ITAB
4466                 INTO G_TABCTRL110_WA.
4467
4468            IF ( G_TABCTRL110_WA-MATCODE IS INITIAL
4469                    OR G_TABCTRL110_WA-MATCODE = '000000000' )
4470   *
4471                    AND G_TABCTRL110_WA-COMP_FLG IS INITIAL
4472                    AND G_TABCTRL110_WA-REJ_FLG  IS INITIAL.
4473
4474              L_DESC = G_TABCTRL110_WA-DESC_FIN.
4475              L_MAT_LEN = STRLEN( L_DESC ).
4476
4477              IF L_MAT_LEN <= 40 .
4478
4479                L_DESC1 = L_DESC.
4480
4481                SELTAB-SELNAME = 'P_DESC1'.
4482                SELTAB-SIGN    = 'I'.
4483                SELTAB-OPTION = 'EQ'.
4484                SELTAB-LOW   = L_DESC1.
4485                APPEND SELTAB TO IST_SELTAB.
4486
4487                CLEAR L_DESC2.
4488
4489                SELTAB-SELNAME = 'P_DESC2'.
4490                SELTAB-SIGN    = 'I'.
4491                SELTAB-OPTION = 'EQ'.
4492                SELTAB-LOW   = L_DESC2.
4493                APPEND SELTAB TO IST_SELTAB.
4494
4495                SET PARAMETER ID 'P_DESC2' FIELD L_DESC2.
4496
4497              ELSE.
4498
4499                L_DESC1 = L_DESC+0(39).
4500                IF L_DESC+38(1) = ' '.
4501                  L_DESC1 = L_DESC+0(38).
4502                  CONCATENATE L_DESC1 '*' INTO L_DESC1 SEPARATED BY SPACE.
4503                  L_DESC2 = L_DESC+39(48).
4504                ELSE.
4505                  CONCATENATE L_DESC1 '*' INTO L_DESC1.
4506                  L_DESC2 = L_DESC+39(48).
4507                ENDIF.
4508
4509                SELTAB-SELNAME = 'P_DESC1'.
4510                SELTAB-SIGN    = 'I'.
4511                SELTAB-OPTION = 'EQ'.
4512                SELTAB-LOW   = L_DESC1.
4513                APPEND SELTAB TO IST_SELTAB.
4514
4515                SELTAB-SELNAME = 'P_DESC2'.
4516                SELTAB-SIGN    = 'I'.
4517                SELTAB-OPTION = 'EQ'.
4518                SELTAB-LOW   = L_DESC2.
4519                APPEND SELTAB TO IST_SELTAB.
4520
4521                SET PARAMETER ID 'P_DESC2' FIELD L_DESC2.
4522
4523              ENDIF.
4524
4525              SELTAB-SELNAME = 'P_UOM'.
4526              SELTAB-SIGN    = 'I'.
4527              SELTAB-OPTION = 'EQ'.
4528              SELTAB-LOW   = G_TABCTRL110_WA-UOM.
4529              APPEND SELTAB TO IST_SELTAB.
4530
4531              SELTAB-SELNAME = 'P_MATKL'.
4532              SELTAB-SIGN    = 'I'.
4533              SELTAB-OPTION = 'EQ'.
4534              SELTAB-LOW   = G_TABCTRL110_WA-MATGP.
4535              APPEND SELTAB TO IST_SELTAB.
4536
4537              SELTAB-SELNAME = 'P_MTART'.
4538              SELTAB-SIGN    = 'I'.
4539              SELTAB-OPTION = 'EQ'.
4540              SELTAB-LOW   = ZMM_CDHD_ST-MTART.
4541              APPEND SELTAB TO IST_SELTAB.
4542
4543
4544              SELTAB-SELNAME = 'P_SRNO'.
4545              SELTAB-SIGN    = 'I'.
4546              SELTAB-OPTION = 'EQ'.
4547              SELTAB-LOW   = G_TABCTRL110_WA-SRNO.
4548              APPEND SELTAB TO IST_SELTAB.
4549
4550
4551              SUBMIT ZMM_MATCODE_CR WITH SELECTION-TABLE IST_SELTAB AND
4552              RETURN.
4553              GET PARAMETER ID 'NEW_MATCODE' FIELD G_TABCTRL110_WA-MATCODE.
4554              IF G_TABCTRL110_WA-MATCODE IS INITIAL
4555                 OR G_TABCTRL110_WA-MATCODE = '000000000'.
4556                G_TABCTRL110_WA-COMP_FLG = 'E'.
4557                SELECT SINGLE * FROM ZMM_CODREQ_RSN INTO WA_RSN
4558                WHERE REASON = 'E'.
4559                G_TABCTRL110_WA-RSN = WA_RSN-DESCRIPTION.
4560              ELSE.
4561                MATGEN_FLAG = 'X'.
4562                G_TABCTRL110_WA-COMP_FLG = 'N'.
4563                SELECT SINGLE * FROM ZMM_CODREQ_RSN INTO WA_RSN
4564                WHERE REASON = 'N'.
4565                G_TABCTRL110_WA-RSN = WA_RSN-DESCRIPTION.
4566   ***********************************************************************
4567                DATA: L_SRNO LIKE ZMM_CDITEM-SRNO.
4568                CLEAR IST_TEXTID.
4569                MOVE G_TABCTRL110_WA-SRNO TO L_SRNO.
4570                CONCATENATE 'CDDS' ZMM_CDHD_ST-REQNO L_SRNO
4571                INTO IST_TEXTID-TDNAME.
4572
4573                IST_TEXTID-TDOBJECT   = 'ZMMCD'.
4574                IST_TEXTID-TDID       = 'CDDS'.
4575                IST_TEXTID-TDSPRAS    =  SY-LANGU.
4576                IST_TEXTID-TDLINESIZE =  72.
4577   ***Appending to internal table for all textid/name.
4578                APPEND IST_TEXTID TO IST_TEXTID_ITEMS.
4579
4580                CLEAR   : IST_DTSPECS.
4581                REFRESH : IST_DTSPECS.
4582
4583                PERFORM READ_TEXT_DATA TABLES IST_DTSPECS USING IST_TEXTID.
4584
4585                CLEAR : WA_TEXTID.
4586
4587                WA_TEXTID-TDNAME   = G_TABCTRL110_WA-MATCODE.
4588                WA_TEXTID-TDID     = 'BEST'.
4589                WA_TEXTID-TDSPRAS  = 'E'.
4590                WA_TEXTID-TDOBJECT = 'MATERIAL'.
4591
4592                PERFORM SAVE_TEXT.
4593
4594                CLEAR   : IST_DTSPECS.
4595                REFRESH : IST_DTSPECS.
4596
4597   **********************************************************************
4598
4599              ENDIF.
4600              MODIFY G_TABCTRL110_ITAB FROM G_TABCTRL110_WA.
4601              CLEAR G_TABCTRL110_WA-COMP_FLG.
4602
4603              CLEAR SELTAB.
4604              REFRESH IST_SELTAB.
4605            ENDIF.
4606
4607   *
4608            CLEAR : G_TABCTRL110_WA-COMP_FLG,
4609                    G_TABCTRL110_WA-RSN.
4610          ENDLOOP.
4611
4612        WHEN 'ZSPR'.
4613
4614          DATA : L_MPARTNO_LEN LIKE SY-INDEX.
4615          DATA : L_MPARTNO LIKE G_TABLCTRL120_WA-PARTNO.
4616          DATA : L_MPARTNO1(30) TYPE C.
4617          DATA : L_MPARTNO2(10) TYPE C.
4618          DATA : L_MFGNAME(30) TYPE C.
4619
4620          LOOP AT G_TABLCTRL120_ITAB
4621                   INTO G_TABLCTRL120_WA.
4622
4623   **  Added for group initialisation problems
4624
4625            IF  G_TABLCTRL120_WA-MATGP IS INITIAL.
4626
4627              G_TABLCTRL120_WA-COMP_FLG = 'E'.
4628
4629              MODIFY G_TABLCTRL120_ITAB FROM G_TABLCTRL120_WA
4630                     INDEX SY-TABIX.
4631              CONTINUE.
4632            ENDIF.
4633
4634            IF ( G_TABLCTRL120_WA-MATCODE IS INITIAL
4635                      OR G_TABLCTRL120_WA-MATCODE = '000000000' )
4636   *
4637                      AND G_TABLCTRL120_WA-COMP_FLG IS INITIAL
4638                      AND G_TABLCTRL120_WA-REJ_FLG  IS INITIAL.
4639
4640              L_MPARTNO = G_TABLCTRL120_WA-PARTNO.
4641              L_DESC = G_TABLCTRL120_WA-DESC_FIN.
4642              L_MPARTNO_LEN = STRLEN( L_MPARTNO ).
4643              L_MAT_LEN = STRLEN( L_DESC ).
4644
4645              IF L_MAT_LEN <= 40 .
4646
4647                L_DESC1 = L_DESC.
4648
4649                SELTAB-SELNAME = 'P_DESC1'.
4650                SELTAB-SIGN    = 'I'.
4651                SELTAB-OPTION = 'EQ'.
4652                SELTAB-LOW   = L_DESC1.
4653                APPEND SELTAB TO IST_SELTAB.
4654
4655                CLEAR L_DESC2.
4656
4657                SELTAB-SELNAME = 'P_DESC2'.
4658                SELTAB-SIGN    = 'I'.
4659                SELTAB-OPTION = 'EQ'.
4660                SELTAB-LOW   = L_DESC2.
4661                APPEND SELTAB TO IST_SELTAB.
4662
4663                SET PARAMETER ID 'P_DESC2' FIELD L_DESC2.
4664
4665              ELSE.
4666
4667                L_DESC1 = L_DESC+0(39).
4668                IF L_DESC+38(1) = ' '.
4669                  L_DESC1 = L_DESC+0(38).
4670                  CONCATENATE L_DESC1 '*' INTO L_DESC1 SEPARATED BY SPACE.
4671                  L_DESC2 = L_DESC+39(48).
4672                ELSE.
4673                  CONCATENATE L_DESC1 '*' INTO L_DESC1.
4674                  L_DESC2 = L_DESC+39(48).
4675                ENDIF.
4676
4677                SELTAB-SELNAME = 'P_DESC1'.
4678                SELTAB-SIGN    = 'I'.
4679                SELTAB-OPTION = 'EQ'.
4680                SELTAB-LOW   = L_DESC1.
4681                APPEND SELTAB TO IST_SELTAB.
4682
4683                SELTAB-SELNAME = 'P_DESC2'.
4684                SELTAB-SIGN    = 'I'.
4685                SELTAB-OPTION = 'EQ'.
4686                SELTAB-LOW   = L_DESC2.
4687                APPEND SELTAB TO IST_SELTAB.
4688
4689                SET PARAMETER ID 'P_DESC2' FIELD L_DESC2.
4690
4691              ENDIF.
4692
4693              SELTAB-SELNAME = 'P_UOM'.
4694              SELTAB-SIGN    = 'I'.
4695              SELTAB-OPTION = 'EQ'.
4696              SELTAB-LOW   = G_TABLCTRL120_WA-UOM.
4697              APPEND SELTAB TO IST_SELTAB.
4698
4699              SELTAB-SELNAME = 'P_MATKL'.
4700              SELTAB-SIGN    = 'I'.
4701              SELTAB-OPTION = 'EQ'.
4702              SELTAB-LOW   = G_TABLCTRL120_WA-MATGP.
4703              APPEND SELTAB TO IST_SELTAB.
4704
4705              SELECT SINGLE NAME1 FROM LFA1 INTO L_MFGNAME
4706                     WHERE LIFNR = G_TABLCTRL120_WA-MANU.
4707
4708              SELTAB-SELNAME = 'P_MFGNME'.
4709              SELTAB-SIGN    = 'I'.
4710              SELTAB-OPTION = 'EQ'.
4711              SELTAB-LOW   = L_MFGNAME.
4712              APPEND SELTAB TO IST_SELTAB.
4713   *
4714              SELTAB-SELNAME = 'P_MFGCDE'.
4715              SELTAB-SIGN    = 'I'.
4716              SELTAB-OPTION = 'EQ'.
4717              SELTAB-LOW   = G_TABLCTRL120_WA-MANU.
4718              APPEND SELTAB TO IST_SELTAB.
4719
4720              SELTAB-SELNAME = 'P_CPCDE'.
4721              SELTAB-SIGN    = 'I'.
4722              SELTAB-OPTION = 'EQ'.
4723              SELTAB-LOW   = G_TABLCTRL120_WA-CAP_CODE.
4724              APPEND SELTAB TO IST_SELTAB.
4725
4726              SELTAB-SELNAME = 'P_CPCDED'.
4727              SELTAB-SIGN    = 'I'.
4728              SELTAB-OPTION = 'EQ'.
4729              SELTAB-LOW   = G_TABLCTRL120_WA-CAP_NAME.
4730              APPEND SELTAB TO IST_SELTAB.
4731
4732              SELTAB-SELNAME = 'P_MDLCDE'.
4733              SELTAB-SIGN    = 'I'.
4734              SELTAB-OPTION = 'EQ'.
4735              SELTAB-LOW   = G_TABLCTRL120_WA-MDLNO.
4736              APPEND SELTAB TO IST_SELTAB.
4737
4738
4739              IF L_MPARTNO_LEN <= 30.
4740
4741                L_MPARTNO1 = L_MPARTNO.
4742
4743                SELTAB-SELNAME = 'P_MPRTN1'.
4744                SELTAB-SIGN    = 'I'.
4745                SELTAB-OPTION = 'EQ'.
4746                SELTAB-LOW   = L_MPARTNO1.
4747                APPEND SELTAB TO IST_SELTAB.
4748
4749                L_MPARTNO2 = ''.
4750
4751              ELSE.
4752
4753                L_MPARTNO1 = L_MPARTNO.
4754
4755                SELTAB-SELNAME = 'P_MPRTN1'.
4756                SELTAB-SIGN    = 'I'.
4757                SELTAB-OPTION = 'EQ'.
4758                SELTAB-LOW   = L_MPARTNO1.
4759                APPEND SELTAB TO IST_SELTAB.
4760
4761                L_MPARTNO2 = L_MPARTNO+30(10).
4762
4763                SELTAB-SELNAME = 'P_MPRTN2'.
4764                SELTAB-SIGN    = 'I'.
4765                SELTAB-OPTION = 'EQ'.
4766                SELTAB-LOW   = L_MPARTNO2.
4767                APPEND SELTAB TO IST_SELTAB.
4768
4769              ENDIF.
4770
4771              SELTAB-SELNAME = 'P_MPRTN'.
4772              SELTAB-SIGN    = 'I'.
4773              SELTAB-OPTION = 'EQ'.
4774              SELTAB-LOW   = L_MPARTNO.
4775              APPEND SELTAB TO IST_SELTAB.
4776
4777   *
4778              SELTAB-SELNAME = 'P_DESC'.
4779              SELTAB-SIGN    = 'I'.
4780              SELTAB-OPTION = 'EQ'.
4781              SELTAB-LOW   = G_TABLCTRL120_WA-DESC_FIN.
4782              APPEND SELTAB TO IST_SELTAB.
4783
4784              SELTAB-SELNAME = 'P_MTART'.
4785              SELTAB-SIGN    = 'I'.
4786              SELTAB-OPTION = 'EQ'.
4787              SELTAB-LOW   = ZMM_CDHD_ST-MTART.
4788              APPEND SELTAB TO IST_SELTAB.
4789
4790              SELTAB-SELNAME = 'P_EQDESC'.
4791              SELTAB-SIGN    = 'I'.
4792              SELTAB-OPTION = 'EQ'.
4793              SELTAB-LOW   = G_TABLCTRL120_WA-SUBASS.
4794              APPEND SELTAB TO IST_SELTAB.
4795
4796
4797              SELTAB-SELNAME = 'P_SRNO'.
4798              SELTAB-SIGN    = 'I'.
4799              SELTAB-OPTION = 'EQ'.
4800              SELTAB-LOW   = G_TABLCTRL120_WA-SRNO.
4801              APPEND SELTAB TO IST_SELTAB.
4802
4803              SUBMIT ZMM_MATCODE_CR WITH SELECTION-TABLE IST_SELTAB AND
4804   RETURN.
4805              GET PARAMETER ID 'NEW_MATCODE' FIELD G_TABLCTRL120_WA-MATCODE.
4806              IF G_TABLCTRL120_WA-MATCODE IS INITIAL
4807                 OR G_TABLCTRL120_WA-MATCODE = '000000000'.
4808                G_TABLCTRL120_WA-COMP_FLG = 'E'.
4809                SELECT SINGLE * FROM ZMM_CODREQ_RSN INTO WA_RSN
4810                WHERE REASON = 'E'.
4811                G_TABLCTRL120_WA-RSN = WA_RSN-DESCRIPTION.
4812              ELSE.
4813                MATGEN_FLAG = 'X'.
4814                G_TABLCTRL120_WA-COMP_FLG = 'N'.
4815                SELECT SINGLE * FROM ZMM_CODREQ_RSN INTO WA_RSN
4816                WHERE REASON = 'N'.
4817                G_TABLCTRL120_WA-RSN = WA_RSN-DESCRIPTION.
4818   ***********************************************************************
4819   *
4820                CLEAR IST_TEXTID.
4821                MOVE G_TABLCTRL120_WA-SRNO TO L_SRNO.
4822                CONCATENATE 'CDDS' ZMM_CDHD_ST-REQNO L_SRNO
4823                INTO IST_TEXTID-TDNAME.
4824
4825                IST_TEXTID-TDOBJECT   = 'ZMMCD'.
4826                IST_TEXTID-TDID       = 'CDDS'.
4827                IST_TEXTID-TDSPRAS    =  SY-LANGU.
4828                IST_TEXTID-TDLINESIZE =  72.
4829   ***Appending to internal table for all textid/name.
4830                APPEND IST_TEXTID TO IST_TEXTID_ITEMS.
4831
4832                CLEAR   : IST_DTSPECS.
4833                REFRESH : IST_DTSPECS.
4834
4835                PERFORM READ_TEXT_DATA TABLES IST_DTSPECS USING IST_TEXTID.
4836                CLEAR : WA_TEXTID.
4837
4838                WA_TEXTID-TDNAME   = G_TABLCTRL120_WA-MATCODE.
4839                WA_TEXTID-TDID     = 'BEST'.
4840                WA_TEXTID-TDSPRAS  = 'E'.
4841                WA_TEXTID-TDOBJECT = 'MATERIAL'.
4842
4843                PERFORM SAVE_TEXT.
4844
4845                CLEAR   : IST_DTSPECS.
4846                REFRESH : IST_DTSPECS.
4847
4848   **********************************************************************
4849
4850              ENDIF.
4851              MODIFY G_TABLCTRL120_ITAB FROM G_TABLCTRL120_WA.
4852              CLEAR G_TABLCTRL120_WA-COMP_FLG.
4853
4854              CLEAR SELTAB.
4855              REFRESH IST_SELTAB.
4856            ENDIF.
4857            CLEAR : G_TABLCTRL120_WA-COMP_FLG,
4858            G_TABLCTRL120_WA-RSN.
4859          ENDLOOP.
4860
4861        WHEN 'ZCAP'.
4862
4863          DATA : L_MATCOST(15) TYPE C.
4864
4865          LOOP AT G_TABLCTRL130_ITAB
4866                   INTO G_TABLCTRL130_WA.
4867
4868   **  Added for group initialisation problems
4869
4870            IF  G_TABLCTRL130_WA-SPA_GRP IS INITIAL.
4871
4872              G_TABLCTRL130_WA-COMP_FLG = 'E'.
4873
4874              MODIFY G_TABLCTRL130_ITAB FROM G_TABLCTRL130_WA
4875                     INDEX SY-TABIX.
4876              CONTINUE.
4877            ENDIF.
4878
4879            IF ( G_TABLCTRL130_WA-MATCODE IS INITIAL
4880                      OR G_TABLCTRL130_WA-MATCODE = '000000000' )
4881   *
4882                      AND G_TABLCTRL130_WA-COMP_FLG IS INITIAL
4883                      AND G_TABLCTRL130_WA-REJ_FLG  IS INITIAL.
4884
4885              L_DESC = G_TABLCTRL130_WA-DESC_FIN.
4886              L_MAT_LEN = STRLEN( L_DESC ).
4887
4888              IF L_MAT_LEN <= 40 .
4889
4890                L_DESC1 = L_DESC.
4891
4892                SELTAB-SELNAME = 'P_DESC1'.
4893                SELTAB-SIGN    = 'I'.
4894                SELTAB-OPTION = 'EQ'.
4895                SELTAB-LOW   = L_DESC1.
4896                APPEND SELTAB TO IST_SELTAB.
4897
4898                CLEAR L_DESC2.
4899
4900                SELTAB-SELNAME = 'P_DESC2'.
4901                SELTAB-SIGN    = 'I'.
4902                SELTAB-OPTION = 'EQ'.
4903                SELTAB-LOW   = L_DESC2.
4904                APPEND SELTAB TO IST_SELTAB.
4905
4906                SET PARAMETER ID 'P_DESC2' FIELD L_DESC2.
4907
4908              ELSE.
4909
4910                L_DESC1 = L_DESC+0(39).
4911                CONCATENATE L_DESC1 '*' INTO L_DESC1.
4912                L_DESC2 = L_DESC+39(48).
4913
4914                SELTAB-SELNAME = 'P_DESC1'.
4915                SELTAB-SIGN    = 'I'.
4916                SELTAB-OPTION = 'EQ'.
4917                SELTAB-LOW   = L_DESC1.
4918                APPEND SELTAB TO IST_SELTAB.
4919
4920                SELTAB-SELNAME = 'P_DESC2'.
4921                SELTAB-SIGN    = 'I'.
4922                SELTAB-OPTION = 'EQ'.
4923                SELTAB-LOW   = L_DESC2.
4924                APPEND SELTAB TO IST_SELTAB.
4925
4926                SET PARAMETER ID 'P_DESC2' FIELD L_DESC2.
4927
4928              ENDIF.
4929
4930              SELTAB-SELNAME = 'P_UOM'.
4931              SELTAB-SIGN    = 'I'.
4932              SELTAB-OPTION = 'EQ'.
4933              SELTAB-LOW   = G_TABLCTRL130_WA-UOM.
4934              APPEND SELTAB TO IST_SELTAB.
4935
4936              SELTAB-SELNAME = 'P_MATKL'.
4937              SELTAB-SIGN    = 'I'.
4938              SELTAB-OPTION = 'EQ'.
4939              SELTAB-LOW   = '0C'.
4940              APPEND SELTAB TO IST_SELTAB.
4941
4942
4943              L_MATCOST = G_TABLCTRL130_WA-MATCOST.
4944
4945              SELTAB-SELNAME = 'P_MATCOS'.
4946              SELTAB-SIGN    = 'I'.
4947              SELTAB-OPTION = 'EQ'.
4948              SELTAB-LOW   = L_MATCOST.
4949              APPEND SELTAB TO IST_SELTAB.
4950
4951              SELTAB-SELNAME = 'P_MATCAT'.
4952              SELTAB-SIGN    = 'I'.
4953              SELTAB-OPTION = 'EQ'.
4954              SELTAB-LOW   = G_TABLCTRL130_WA-MATCATG.
4955              APPEND SELTAB TO IST_SELTAB.
4956
4957              SELTAB-SELNAME = 'P_MATLOC'.
4958              SELTAB-SIGN    = 'I'.
4959              SELTAB-OPTION = 'EQ'.
4960              SELTAB-LOW   = G_TABLCTRL130_WA-MATLOC.
4961              APPEND SELTAB TO IST_SELTAB.
4962
4963              SELTAB-SELNAME = 'P_WKLIFE'.
4964              SELTAB-SIGN    = 'I'.
4965              SELTAB-OPTION = 'EQ'.
4966              SELTAB-LOW   = G_TABLCTRL130_WA-WRKNG_LIFE.
4967
4968              APPEND SELTAB TO IST_SELTAB.
4969
4970              SELTAB-SELNAME = 'P_MATGP'.
4971              SELTAB-SIGN    = 'I'.
4972              SELTAB-OPTION = 'EQ'.
4973              SELTAB-LOW   = G_TABLCTRL130_WA-SPA_GRP.
4974              APPEND SELTAB TO IST_SELTAB.
4975
4976              SELTAB-SELNAME = 'P_DESC'.
4977              SELTAB-SIGN    = 'I'.
4978              SELTAB-OPTION = 'EQ'.
4979              SELTAB-LOW   = G_TABLCTRL130_WA-DESC_FIN.
4980              APPEND SELTAB TO IST_SELTAB.
4981
4982              SELTAB-SELNAME = 'P_MTART'.
4983              SELTAB-SIGN    = 'I'.
4984              SELTAB-OPTION = 'EQ'.
4985              SELTAB-LOW   = ZMM_CDHD_ST-MTART.
4986              APPEND SELTAB TO IST_SELTAB.
4987
4988              DATA : L_MATNR(8) TYPE C.
4989              DATA : RCODE_NUMBER_GET LIKE INRI-RETURNCODE.
4990              DATA : MATNR LIKE MARA-MATNR.
4991              DATA : L_NUMBER_RANGE LIKE IT_CAP_GROUP1-NUMBER_RANGE.
4992
4993              SELECT * FROM ZMM_CAP_GROUP INTO TABLE IT_CAP_GROUP1
4994                     WHERE DESCRIPTION = G_TABLCTRL130_WA-MATCATG.
4995
4996              IF SY-SUBRC = 0.
4997                SORT IT_CAP_GROUP1 BY NUMBER_RANGE DESCRIPTION ASCENDING.
4998                LOOP AT IT_CAP_GROUP1.
4999                  IF IT_CAP_GROUP1-USED_FLAG = 'X'.
5000                    CONTINUE.
5001                  ELSE.
5002                    EXIT.
5003                  ENDIF.
5004                ENDLOOP.
5005              ENDIF.
5006
5007              L_NUMBER_RANGE = IT_CAP_GROUP1-NUMBER_RANGE.
5008
5009              DO.
5010
5011                CALL FUNCTION 'NUMBER_GET_NEXT'
5012                  EXPORTING
5013                    NR_RANGE_NR             = L_NUMBER_RANGE
5014                    OBJECT                  = 'ZMATERIALC'
5015                  IMPORTING
5016                    NUMBER                  = L_MATNR
5017                    RETURNCODE              = RCODE_NUMBER_GET
5018                  EXCEPTIONS
5019                    INTERVAL_NOT_FOUND      = 1
5020                    NUMBER_RANGE_NOT_INTERN = 2
5021                    OBJECT_NOT_FOUND        = 3
5022                    QUANTITY_IS_0           = 4
5023                    QUANTITY_IS_NOT_1       = 5
5024                    INTERVAL_OVERFLOW       = 6
5025                    BUFFER_OVERFLOW         = 7
5026                    OTHERS                  = 8.
5027                IF SY-SUBRC = 6.
5028                  IT_CAP_GROUP1-USED_FLAG = 'X'.
5029                  MODIFY IT_CAP_GROUP1 INDEX SY-INDEX.
5030                  MODIFY ZMM_CAP_GROUP FROM TABLE IT_CAP_GROUP1.
5031                  G_NEW_CAP_RANGE = 'X'.
5032                  EXIT.
5033                ENDIF.
5034
5035                DATA : L_ALPHAA TYPE C.
5036                DATA : L_CHAR2(2) TYPE C.
5037                DATA : L_CHAR3(3) TYPE C.
5038
5039                L_CHAR3 = L_MATNR+2(3).
5040
5041                READ TABLE IT_ALPHA_NUM1 WITH KEY NUMBER = L_CHAR3.
5042                L_ALPHAA = IT_ALPHA_NUM1-ALPHA.
5043
5044                L_CHAR2 = L_MATNR+2(2).
5045
5046                IF L_CHAR2 EQ '00'.
5047
5048                  CONCATENATE '0C' L_MATNR+4(4) '000' INTO MATNR.
5049
5050                ELSE.
5051
5052                  CONCATENATE '0C' L_ALPHAA L_MATNR+5(3) '000' INTO MATNR.
5053
5054                ENDIF.
5055
5056                CALL FUNCTION 'MARA_SINGLE_READ'
5057                  EXPORTING
5058                    MATNR      = MATNR
5059                    SPERRMODUS = ' '
5060                  IMPORTING
5061                    WMARA      = MARA
5062                  EXCEPTIONS
5063                    NOT_FOUND  = 4
5064                    OTHERS     = 5.
5065
5066                IF SY-SUBRC EQ 0.
5067                  CONTINUE.
5068                ELSE.
5069                  EXIT.
5070                ENDIF.
5071
5072              ENDDO.
5073
5074              IF G_NEW_CAP_RANGE  = 'X'.
5075                PERFORM CREATE_MATCODE.
5076              ENDIF.
5077
5078              SELTAB-SELNAME = 'P_MATNR'.
5079              SELTAB-SIGN    = 'I'.
5080              SELTAB-OPTION = 'EQ'.
5081              SELTAB-LOW   = MATNR.
5082              APPEND SELTAB TO IST_SELTAB.
5083
5084
5085
5086              SELTAB-SELNAME = 'P_SRNO'.
5087              SELTAB-SIGN    = 'I'.
5088              SELTAB-OPTION = 'EQ'.
5089              SELTAB-LOW   = G_TABLCTRL130_WA-SRNO.
5090              APPEND SELTAB TO IST_SELTAB.
5091
5092
5093              SUBMIT ZMM_MATCODE_CR WITH SELECTION-TABLE IST_SELTAB AND
5094   RETURN.
5095
5096              GET PARAMETER ID 'NEW_MATCODE' FIELD G_TABLCTRL130_WA-MATCODE
5097              .
5098              IF G_TABLCTRL130_WA-MATCODE IS INITIAL
5099                 OR G_TABLCTRL130_WA-MATCODE = '000000000'.
5100                G_TABLCTRL130_WA-COMP_FLG = 'E'.
5101                SELECT SINGLE * FROM ZMM_CODREQ_RSN INTO WA_RSN
5102                WHERE REASON = 'E'.
5103                G_TABLCTRL130_WA-RSN = WA_RSN-DESCRIPTION.
5104              ELSE.
5105                MATGEN_FLAG = 'X'.
5106                G_TABLCTRL130_WA-COMP_FLG = 'N'.
5107                SELECT SINGLE * FROM ZMM_CODREQ_RSN INTO WA_RSN
5108                WHERE REASON = 'N'.
5109                G_TABLCTRL130_WA-RSN = WA_RSN-DESCRIPTION.
5110   ***********************************************************************
5111                CLEAR IST_TEXTID.
5112                MOVE G_TABLCTRL130_WA-SRNO TO L_SRNO.
5113                CONCATENATE 'CDDS' ZMM_CDHD_ST-REQNO L_SRNO
5114                INTO IST_TEXTID-TDNAME.
5115
5116                IST_TEXTID-TDOBJECT   = 'ZMMCD'.
5117                IST_TEXTID-TDID       = 'CDDS'.
5118                IST_TEXTID-TDSPRAS    =  SY-LANGU.
5119                IST_TEXTID-TDLINESIZE =  72.
5120   ***Appending to internal table for all textid/name.
5121                APPEND IST_TEXTID TO IST_TEXTID_ITEMS.
5122
5123                CLEAR   : IST_DTSPECS.
5124                REFRESH : IST_DTSPECS.
5125
5126                PERFORM READ_TEXT_DATA TABLES IST_DTSPECS USING IST_TEXTID.
5127                CLEAR : WA_TEXTID.
5128
5129                WA_TEXTID-TDNAME   = G_TABLCTRL130_WA-MATCODE.
5130                WA_TEXTID-TDID     = 'BEST'.
5131                WA_TEXTID-TDSPRAS  = 'E'.
5132                WA_TEXTID-TDOBJECT = 'MATERIAL'.
5133
5134                PERFORM SAVE_TEXT.
5135
5136                CLEAR   : IST_DTSPECS.
5137                REFRESH : IST_DTSPECS.
5138
5139   **********************************************************************
5140
5141              ENDIF.
5142              MODIFY G_TABLCTRL130_ITAB FROM G_TABLCTRL130_WA.
5143              CLEAR G_TABLCTRL130_WA-COMP_FLG.
5144
5145              CLEAR SELTAB.
5146              REFRESH IST_SELTAB.
5147            ENDIF.
5148            CLEAR : G_TABLCTRL130_WA-COMP_FLG,
5149            G_TABLCTRL130_WA-RSN.
5150          ENDLOOP.
5151
5152      ENDCASE.
5153
5154      PERFORM SAVE_REQUEST.
5155
5156    ENDFORM.                    " Create_matcode
5157   *&---------------------------------------------------------------------*
5158   *&      Form  update_approval
5159   *&---------------------------------------------------------------------*
5160   *       text
5161   *----------------------------------------------------------------------*
5162   *  -->  p1        text
5163   *  <--  p2        text
5164   *----------------------------------------------------------------------*
5165    FORM UPDATE_RELEASE.
5166      UPDATE ZMM_CDHD SET STATUS_FLAG = 'X'
5167      WHERE REQNO = ZMM_CDHD_ST-REQNO.
5168      PERFORM UPDATE_NOOFHITS.
5169      PERFORM SAVE_CORS_TEXT.
5170      MESSAGE I019(ZMM_OTH) WITH ZMM_CDHD_ST-REQNO.
5171
5172    ENDFORM.                    " update_approval
5173   *&---------------------------------------------------------------------*
5174   *&      Form  Insert_modif
5175   *&---------------------------------------------------------------------*
5176   *       text
5177   *----------------------------------------------------------------------*
5178   *  -->  p1        text
5179   *  <--  p2        text
5180   *----------------------------------------------------------------------*
5181    FORM INSERT_MODIF.
5182      DATA L_TAB_INDEX LIKE SY-TABIX.
5183      CLEAR ZMM_MODIFIER.
5184      READ TABLE G_TABCTRL110_ITAB INTO G_TABCTRL110_WA WITH KEY FLAG = 'X'.
5185      IF SY-SUBRC = 0.
5186        PERFORM GET_PARNO.     "+
5187        CASE G_PARNO.
5188          WHEN '4'.
5189            IF G_TABCTRL110_WA-DESC4 IS INITIAL.
5190              MESSAGE I069(ZMM_OTH) WITH G_TABCTRL110_WA-DESC1
5191                                         G_PARNO.
5192              CHECK 1 = 2.
5193            ENDIF.
5194          WHEN '3'.
5195            IF G_TABCTRL110_WA-DESC3 IS INITIAL .
5196              MESSAGE I069(ZMM_OTH) WITH G_TABCTRL110_WA-DESC1
5197                                         G_PARNO.
5198              CHECK 1 = 2.
5199            ELSEIF G_TABCTRL110_WA-DESC4 <> ''.
5200              MESSAGE I070(ZMM_OTH) WITH G_TABCTRL110_WA-DESC1
5201                                         G_PARNO.
5202
5203              CHECK 1 = 2.
5204            ENDIF.
5205          WHEN '2'.
5206            IF G_TABCTRL110_WA-DESC2 IS INITIAL.
5207              MESSAGE I069(ZMM_OTH) WITH G_TABCTRL110_WA-DESC1
5208                                         G_PARNO.
5209              CHECK 1 = 2.
5210            ELSEIF G_TABCTRL110_WA-DESC3 <> ''.
5211              MESSAGE I070(ZMM_OTH) WITH G_TABCTRL110_WA-DESC1
5212                                         G_PARNO.
5213              CHECK 1 = 2.
5214            ENDIF.
5215   *
5216   *       when '1'.
5217   *         if g_tabctrl110_wa-desc4 is initial.
5218   *           message i069(zmm_oth) with g_tabctrl110_wa-desc1.
5219   *           check 1 = 2.
5220   *         Endif.
5221        ENDCASE.
5222
5223        IF ( G_TABCTRL110_WA-OTH1 = 'X' OR
5224             G_TABCTRL110_WA-OTH2 = 'X' OR
5225             G_TABCTRL110_WA-OTH3 = 'X' OR
5226             G_TABCTRL110_WA-OTH4 = 'X' ) AND
5227             G_TABCTRL110_WA-COMP_FLG+0(1) <> 'S'.
5228
5229          MOVE: G_TABCTRL110_WA-MATGP TO ZMM_MODIFIER-MATGRP,
5230                G_TABCTRL110_WA-DESC1 TO ZMM_MODIFIER-DESC1,
5231                G_TABCTRL110_WA-DESC2 TO ZMM_MODIFIER-DESC2,
5232                G_TABCTRL110_WA-DESC3 TO ZMM_MODIFIER-DESC3,
5233                G_TABCTRL110_WA-DESC4 TO ZMM_MODIFIER-DESC4,
5234                SY-UNAME              TO ZMM_MODIFIER-CREATED_BY,
5235                SY-DATUM              TO ZMM_MODIFIER-CREATE_DATE.
5236          L_TAB_INDEX = SY-TABIX.
5237          CALL SCREEN 103 STARTING AT 40 2 ENDING AT 80 8.
5238          IF SY-UCOMM = 'AGREE'.
5239            INSERT INTO ZMM_MODIFIER VALUES ZMM_MODIFIER.
5240            REPLACE 'M' WITH '' INTO G_TABCTRL110_WA-COMP_FLG .
5241            MODIFY G_TABCTRL110_ITAB FROM G_TABCTRL110_WA INDEX L_TAB_INDEX
5242             TRANSPORTING COMP_FLG FLAG.
5243            CLEAR SY-UCOMM.
5244          ELSE.
5245            MODIFY G_TABCTRL110_ITAB FROM G_TABCTRL110_WA INDEX L_TAB_INDEX
5246             TRANSPORTING FLAG.
5247            CLEAR SY-UCOMM.
5248          ENDIF.
5249        ELSE.
5250          MESSAGE I035(ZMM_OTH).
5251        ENDIF.
5252      ELSE.
5253        MESSAGE I040(ZMM_OTH).
5254      ENDIF.
5255    ENDFORM.                    " Insert_modif
5256
5257   *&---------------------------------------------------------------------*
5258   *&      Form  reset_other
5259   *&---------------------------------------------------------------------*
5260   *       text
5261   *----------------------------------------------------------------------*
5262   *  -->  p1        text
5263   *  <--  p2        text
5264   *----------------------------------------------------------------------*
5265    FORM RESET_OTHER.
5266      IF G_OK_CODE115 <> 'CANC'.
5267        CASE 'OTHER'.
5268          WHEN G_TABCTRL110_WA-DESC1.
5269            CLEAR : G_TABCTRL110_WA-DESC1,
5270                    G_TABCTRL110_WA-OTH1,
5271                    G_TABCTRL110_WA-MATGP.
5272
5273          WHEN G_TABCTRL110_WA-DESC2.
5274            CLEAR: G_TABCTRL110_WA-DESC2,
5275                   G_TABCTRL110_WA-OTH2.
5276
5277          WHEN G_TABCTRL110_WA-DESC3.
5278            CLEAR: G_TABCTRL110_WA-DESC3,
5279                   G_TABCTRL110_WA-OTH3.
5280
5281          WHEN G_TABCTRL110_WA-DESC4.
5282            CLEAR: G_TABCTRL110_WA-DESC4,
5283                   G_TABCTRL110_WA-OTH2 .
5284        ENDCASE.
5285   *
5286      ELSE.
5287        CASE 'OTHER'.
5288          WHEN G_TABCTRL110_WA-DESC1.
5289            CLEAR : G_TABCTRL110_WA-DESC1,
5290                    G_TABCTRL110_WA-OTH1.
5291          WHEN G_TABCTRL110_WA-DESC2.
5292            CLEAR: G_TABCTRL110_WA-DESC2,
5293                   G_TABCTRL110_WA-OTH2.
5294
5295          WHEN G_TABCTRL110_WA-DESC3.
5296            CLEAR: G_TABCTRL110_WA-DESC3,
5297                   G_TABCTRL110_WA-OTH3.
5298
5299          WHEN G_TABCTRL110_WA-DESC4.
5300            CLEAR: G_TABCTRL110_WA-DESC4,
5301                   G_TABCTRL110_WA-OTH2 .
5302        ENDCASE.
5303   *
5304      ENDIF.
5305    ENDFORM.                    " reset_other
5306   *&---------------------------------------------------------------------*
5307   *&      Form  other_check
5308   *&---------------------------------------------------------------------*
5309   *       text
5310   *----------------------------------------------------------------------*
5311   *  -->  p1        text
5312   *  <--  p2        text
5313   *----------------------------------------------------------------------*
5314    FORM OTHER_CHECK.
5315      IF SY-UCOMM <> 'CANC' . "X in toolbar of modal screen
5316        CASE 'X'.
5317          WHEN G_TABCTRL110_WA-OTH1.
5318            IF G_DESC1 = '' OR
5319               G_DESC2 = ''.
5320              MESSAGE E007(ZMM_OTH) WITH 'DESC1' 'DESC2'.
5321   *
5322            ENDIF.
5323            IF G_DESC4 <> ''.
5324              IF G_DESC3 = ''.
5325                MESSAGE E007(ZMM_OTH).
5326              ENDIF.
5327            ENDIF.
5328
5329          WHEN G_TABCTRL110_WA-OTH2.
5330            IF G_DESC2 IS INITIAL.
5331              MESSAGE E007(ZMM_OTH) WITH 'DESC2'.
5332            ENDIF.
5333            IF G_DESC4 <> ''.
5334              IF G_DESC3 = ''.
5335                MESSAGE E007(ZMM_OTH).
5336              ENDIF.
5337            ENDIF.
5338          WHEN G_TABCTRL110_WA-OTH3.
5339            IF G_DESC3 IS INITIAL.
5340              MESSAGE E007(ZMM_OTH) WITH 'DESC3'.
5341            ENDIF.
5342          WHEN G_TABCTRL110_WA-OTH4.
5343            IF G_DESC4 IS INITIAL.
5344              MESSAGE E007(ZMM_OTH) WITH 'DESC4'.
5345            ENDIF.
5346        ENDCASE.
5347      ENDIF.
5348
5349
5350    ENDFORM.                    " other_check
5351   *****************************************************
5352    FORM FIND_USER.
5353   *****************************************************
5354      DATA : G_TTA_AUTH.
5355      DATA : G_MRP_AUTH.
5356
5357      CLEAR : G_TTA_AUTH, G_MRP_AUTH.
5358
5359      IF SY-TCODE = 'ZCODG'.
5360        G_USER = 'X'.  "Codifier.
5361      ELSE.
5362   * MRP CONTROLLER AUTH CHECK.
5363        AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
5364                           ID 'FRGCO' FIELD : 'L1'.
5365        IF SY-SUBRC = 0.
5366          G_TTA_AUTH = 'X'.
5367        ENDIF.
5368        AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
5369                           ID 'FRGCO' FIELD : 'L2'.
5370        IF SY-SUBRC = 0.
5371          G_TTA_AUTH = 'X'.
5372        ENDIF.
5373        AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
5374                           ID 'FRGCO' FIELD : 'HS'.
5375        IF SY-SUBRC = 0.
5376          G_TTA_AUTH = 'X'.
5377        ENDIF.
5378        AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
5379                           ID 'FRGCO' FIELD : 'HO'.
5380        IF SY-SUBRC = 0.
5381          G_TTA_AUTH = 'X'.
5382        ENDIF.
5383        AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
5384                           ID 'FRGCO' FIELD : 'HL'.
5385        IF SY-SUBRC = 0.
5386          G_TTA_AUTH = 'X'.
5387        ENDIF.
5388        AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
5389                           ID 'FRGCO' FIELD : 'HC'.
5390        IF SY-SUBRC = 0.
5391          G_TTA_AUTH = 'X'.
5392        ENDIF.
5393        AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
5394                           ID 'FRGCO' FIELD : '1A'.
5395        IF SY-SUBRC = 0.
5396          G_TTA_AUTH = 'X'.
5397        ENDIF.
5398        AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
5399                           ID 'FRGCO' FIELD : '1B'.
5400        IF SY-SUBRC = 0.
5401          G_TTA_AUTH = 'X'.
5402        ENDIF.
5403        AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
5404                           ID 'FRGCO' FIELD : '1C'.
5405        IF SY-SUBRC = 0.
5406          G_TTA_AUTH = 'X'.
5407        ENDIF.
5408
5409        AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
5410                           ID 'FRGCO' FIELD : '1D'.
5411        IF SY-SUBRC = 0.
5412          G_TTA_AUTH = 'X'.
5413        ENDIF.
5414        AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
5415                           ID 'FRGCO' FIELD : '1E'.
5416        IF SY-SUBRC = 0.
5417          G_TTA_AUTH = 'X'.
5418        ENDIF.
5419        AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
5420                           ID 'FRGCO' FIELD : '1F'.
5421        IF SY-SUBRC = 0.
5422          G_TTA_AUTH = 'X'.
5423        ENDIF.
5424        AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
5425                           ID 'FRGCO' FIELD : 'DI'.
5426        IF SY-SUBRC = 0.
5427          G_TTA_AUTH = 'X'.
5428        ENDIF.
5429        AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
5430                           ID 'FRGCO' FIELD : 'DF'.
5431        IF SY-SUBRC = 0.
5432          G_TTA_AUTH = 'X'.
5433        ENDIF.
5434        AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
5435                           ID 'FRGCO' FIELD : 'CI'.
5436        IF SY-SUBRC = 0.
5437          G_TTA_AUTH = 'X'.
5438        ENDIF.
5439        AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
5440                           ID 'FRGCO' FIELD : 'CS'.
5441        IF SY-SUBRC = 0.
5442          G_TTA_AUTH = 'X'.
5443        ENDIF.
5444        AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
5445                           ID 'FRGCO' FIELD : 'BO'.
5446        IF SY-SUBRC = 0.
5447          G_TTA_AUTH = 'X'.
5448        ENDIF.
5449        AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
5450                           ID 'FRGCO' FIELD : 'MD'.
5451        IF SY-SUBRC = 0.
5452          G_TTA_AUTH = 'X'.
5453        ENDIF.
5454        AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
5455                           ID 'FRGCO' FIELD : 'EC'.
5456        IF SY-SUBRC = 0.
5457          G_TTA_AUTH = 'X'.
5458        ENDIF.
5459
5460        IF G_TTA_AUTH = 'X'.
5461          G_USER = 'L'.         "TAA
5462          AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
5463                           ID 'FRGCO' FIELD '02'
5464                           ID 'FRGGR' FIELD 'IM'.
5465          IF SY-SUBRC = 0.
5466            G_USER = 'Z'.  "MRP CONTROLLER+TAA
5467          ENDIF.
5468   * ------- Find if user is MRP Controller
5469        ELSE.
5470          AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
5471                           ID 'FRGCO' FIELD '02'
5472                           ID 'FRGGR' FIELD 'IM'.
5473          IF SY-SUBRC = 0.
5474            G_USER = 'M'.  "MRP CONTROLLER
5475          ELSE.
5476            G_USER = ''.
5477          ENDIF.
5478        ENDIF.
5479      ENDIF.
5480   *
5481      G_USER_FOUND = 'X'.
5482   *
5483    ENDFORM.                    " find_user
5484   *********************************************************************
5485    FORM CHECK_MODI.
5486   * Check for existing modifiers
5487      SELECT SINGLE * FROM ZMM_MODIFIER WHERE DESC1 = G_DESC1.
5488      IF SY-SUBRC = 0 AND ( G_TABCTRL110_WA-DESC1 = 'OTHER' OR
5489                            G_TABCTRL110_WA-OTH1 = 'X' ) .
5490        LOOP AT SCREEN.
5491          SCREEN-INPUT = 0.
5492          MODIFY SCREEN.
5493        ENDLOOP.
5494        G_MODI_EXISTS = 'X'.
5495        MESSAGE E010(ZMM_OTH)  .
5496      ELSE.
5497        SELECT SINGLE * FROM ZMM_MODIFIER WHERE DESC1 = G_DESC1 AND DESC2 =
5498                    G_DESC2.
5499        IF SY-SUBRC = 0 AND ( G_TABCTRL110_WA-DESC2 = 'OTHER'  OR
5500                             G_TABCTRL110_WA-OTH2 = 'X' ) .
5501
5502          LOOP AT SCREEN.
5503            SCREEN-INPUT = 0.
5504            MODIFY SCREEN.
5505          ENDLOOP.
5506
5507          MESSAGE E010(ZMM_OTH) .
5508        ELSE.
5509          SELECT SINGLE * FROM ZMM_MODIFIER WHERE DESC1 = G_DESC1 AND DESC2 =
5510                                                  G_DESC2 AND DESC3 = G_DESC3.
5511          IF SY-SUBRC = 0 AND ( G_TABCTRL110_WA-DESC3 = 'OTHER' OR
5512                                G_TABCTRL110_WA-OTH3 = 'X' ) .
5513
5514            LOOP AT SCREEN.
5515              SCREEN-INPUT = 0.
5516              MODIFY SCREEN.
5517            ENDLOOP.
5518            MESSAGE E010(ZMM_OTH)  .
5519          ELSE.
5520            SELECT SINGLE * FROM ZMM_MODIFIER WHERE DESC1 = G_DESC1 AND
5521            DESC2 = G_DESC2 AND DESC3 = G_DESC3 AND DESC4 = G_DESC4.
5522            IF SY-SUBRC = 0 AND ( G_TABCTRL110_WA-DESC4 = 'OTHER'  OR
5523                                  G_TABCTRL110_WA-OTH4 = 'X' ) .
5524
5525              LOOP AT SCREEN.
5526                SCREEN-INPUT = 0.
5527                MODIFY SCREEN.
5528              ENDLOOP.
5529              MESSAGE E010(ZMM_OTH)  .
5530            ENDIF.
5531          ENDIF.
5532        ENDIF.
5533      ENDIF.
5534    ENDFORM.                    "check_modi
5535   *&---------------------------------------------------------------------*
5536   *&      Form  Spell_check
5537   *&---------------------------------------------------------------------*
5538   *       text
5539   *----------------------------------------------------------------------*
5540   *  -->  p1        text
5541   *  <--  p2        text
5542   *----------------------------------------------------------------------*
5543    FORM SPELL_CHECK.
5544      DATA : L_ANS.
5545   *
5546      IF NOT IST_SPELL_LINE[] IS INITIAL.
5547        EXPORT G_USER TO MEMORY ID 'G_USER1' .
5548        EXPORT IST_SPELL_LINE TO MEMORY ID 'IST_SPELL_LINE'.
5549
5550        CALL FUNCTION 'ZSPELL_CHECK'
5551          EXPORTING
5552            SPRACHE = 'EN'
5553          TABLES
5554            ILINE   = IST_SPELL_LINE.
5555        IMPORT CHECKTAB FROM MEMORY ID 'G_CHECKTAB'ACCEPTING TRUNCATION.
5556        IF NOT CHECKTAB[] IS INITIAL.
5557
5558          MESSAGE I017(ZMM_OTH).
5559          PERFORM SPELL_ERROR_LINES.
5560        ELSE.
5561          MESSAGE I008(ZMM_OTH).
5562          LOOP AT G_TABCTRL110_ITAB INTO G_TABCTRL110_WA.
5563            IF G_TABCTRL110_WA-COMP_FLG+0(1) = 'S'.
5564              REPLACE 'S' WITH '' INTO G_TABCTRL110_WA-COMP_FLG.
5565              G_TABCTRL110_WA-RSN      = ''.
5566              MODIFY G_TABCTRL110_ITAB FROM G_TABCTRL110_WA INDEX SY-TABIX
5567                TRANSPORTING COMP_FLG RSN.
5568            ENDIF.
5569          ENDLOOP.
5570
5571
5572        ENDIF.
5573
5574        IF G_USER = ' '.
5575          IMPORT CHECKTAB FROM MEMORY ID 'G_CHECKTAB' ACCEPTING TRUNCATION.
5576          IF NOT CHECKTAB[] IS INITIAL.
5577            " Begin of <RD1K960036>.
5578   *         CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
5579   *            EXPORTING
5580   **
5581   *    TEXTLINE1 = 'There are spelling errors in description(s)'
5582   *           TEXTLINE2            = 'Proceed with errors? '
5583   *            TITEL                = 'Spelling Errors'
5584   **
5585   *           IMPORTING
5586   *              ANSWER               = l_ans.
5587            DATA : L_GET9(1) TYPE C.
5588            CALL FUNCTION 'POPUP_TO_CONFIRM'
5589              EXPORTING
5590               TITLEBAR                    = 'Spelling Errors '
5591   *            DIAGNOSE_OBJECT             = ' '
5592                TEXT_QUESTION               = 'There are spelling errors in description(s) Proceed with errors?'
5593   *            TEXT_BUTTON_1               = 'Ja'(001)
5594   *            ICON_BUTTON_1               = ' '
5595   *            TEXT_BUTTON_2               = 'Nein'(002)
5596   *            ICON_BUTTON_2               = ' '
5597   *            DEFAULT_BUTTON              = '1'
5598   *            DISPLAY_CANCEL_BUTTON       = 'X'
5599   *            USERDEFINED_F1_HELP         = ' '
5600               START_COLUMN                = 25
5601               START_ROW                   = 6
5602   *            POPUP_TYPE                  =
5603   *            IV_QUICKINFO_BUTTON_1       = ' '
5604   *            IV_QUICKINFO_BUTTON_2       = ' '
5605             IMPORTING
5606               ANSWER                      = L_GET9
5607   *          TABLES
5608   *            PARAMETER                   =
5609             EXCEPTIONS
5610               TEXT_NOT_FOUND              = 1
5611               OTHERS                      = 2
5612                      .
5613            IF SY-SUBRC = 0.
5614              CASE L_GET9.
5615                WHEN '1'.
5616                  MOVE 'J' TO L_ANS.
5617                WHEN '2'.
5618                  MOVE 'N' TO L_ANS.
5619              ENDCASE.
5620            ENDIF.
5621            " End of <RD1K960036>.
5622            IF L_ANS = 'J'.
5623              PERFORM SPELL_ERROR_LINES.
5624              CLEAR : G_SCREEN115_1ST,USER_DESC_LEN.
5625              G_OTHER = 'X'.
5626              G_SPELLERROR = ''.
5627   *
5628              G_MODI_EXISTS = ''.
5629              LEAVE TO SCREEN 0.
5630            ELSE.
5631              LOOP AT SCREEN.
5632   *
5633              ENDLOOP.
5634            ENDIF.
5635          ELSE.
5636            CLEAR : G_SCREEN115_1ST,USER_DESC_LEN.
5637            G_OTHER = 'X'.
5638            G_SPELLERROR = ''.
5639            G_MODI_EXISTS = ''.
5640   *
5641            LEAVE TO SCREEN 0.
5642          ENDIF.
5643        ENDIF.
5644      ELSE.
5645        MESSAGE I008(ZMM_OTH).
5646        LOOP AT G_TABCTRL110_ITAB INTO G_TABCTRL110_WA.
5647          IF G_TABCTRL110_WA-COMP_FLG+0(1) = 'S'.
5648            REPLACE 'S' WITH '' INTO G_TABCTRL110_WA-COMP_FLG.
5649            G_TABCTRL110_WA-RSN      = ''.
5650            MODIFY G_TABCTRL110_ITAB FROM G_TABCTRL110_WA INDEX SY-TABIX
5651              TRANSPORTING COMP_FLG RSN.
5652          ENDIF.
5653        ENDLOOP.
5654
5655      ENDIF.
5656    ENDFORM.                    " Spell_check
5657   *&---------------------------------------------------------------------*
5658   *&      Module  spell_check1  INPUT
5659   *&---------------------------------------------------------------------*
5660   *       text
5661   *----------------------------------------------------------------------*
5662   *MODULE spell_check1 INPUT.
5663    FORM SPELL_CHECK1.
5664   *
5665      DATA : OK_CODE110 LIKE SY-UCOMM.
5666   *
5667      OK_CODE110 = SY-UCOMM.
5668      CLEAR SY-UCOMM.
5669      CLEAR IST_SPELL_LINE.
5670      REFRESH IST_SPELL_LINE.
5671   *
5672      IF OK_CODE110 = 'SPELL' OR
5673         CHECK_CODE = 'CHECK'.
5674        READ TABLE G_TABCTRL110_ITAB INTO G_TABCTRL110_WA WITH KEY
5675        FLAG = 'X' .
5676        IF SY-SUBRC = 0.
5677          G_CURR_LINE1 = SY-TABIX.
5678          IF  G_TABCTRL110_WA-OTH1  = 'X'.
5679
5680            CONCATENATE G_TABCTRL110_WA-DESC1 G_TABCTRL110_WA-DESC2
5681            G_TABCTRL110_WA-DESC3 G_TABCTRL110_WA-DESC4
5682            G_TABCTRL110_WA-USER_DESC INTO IST_SPELL_LINE-TDLINE SEPARATED
5683            BY SPACE.
5684
5685          ELSEIF G_TABCTRL110_WA-OTH2 = 'X'.
5686            CONCATENATE G_TABCTRL110_WA-DESC2
5687            G_TABCTRL110_WA-DESC3 G_TABCTRL110_WA-DESC4
5688            G_TABCTRL110_WA-USER_DESC INTO IST_SPELL_LINE-TDLINE SEPARATED
5689            BY SPACE.
5690
5691          ELSEIF G_TABCTRL110_WA-OTH3 = 'X'.
5692            CONCATENATE G_TABCTRL110_WA-DESC3 G_TABCTRL110_WA-DESC4
5693            G_TABCTRL110_WA-USER_DESC INTO IST_SPELL_LINE-TDLINE SEPARATED
5694            BY SPACE.
5695
5696
5697          ELSEIF G_TABCTRL110_WA-OTH4 = 'X'.
5698            CONCATENATE G_TABCTRL110_WA-DESC4
5699            G_TABCTRL110_WA-USER_DESC INTO IST_SPELL_LINE-TDLINE SEPARATED
5700            BY SPACE.
5701
5702          ELSE.
5703            IST_SPELL_LINE-TDLINE = G_TABCTRL110_WA-USER_DESC.
5704          ENDIF.
5705
5706          APPEND IST_SPELL_LINE.
5707          PERFORM SPELL_CHECK.
5708          CLEAR:SY-UCOMM,OK_CODE110.
5709        ELSE.
5710          LOOP AT G_TABCTRL110_ITAB INTO G_TABCTRL110_WA.
5711            CASE 'X'.
5712              WHEN G_TABCTRL110_WA-OTH1.
5713                CONCATENATE G_TABCTRL110_WA-DESC1 G_TABCTRL110_WA-DESC2
5714                G_TABCTRL110_WA-DESC3 G_TABCTRL110_WA-DESC4
5715            G_TABCTRL110_WA-USER_DESC INTO IST_SPELL_LINE-TDLINE SEPARATED
5716                BY SPACE.
5717                IST_SPELL_LINE-SRNO = G_TABCTRL110_WA-SRNO.
5718                APPEND IST_SPELL_LINE.
5719                CONTINUE.
5720              WHEN G_TABCTRL110_WA-OTH2.
5721                CONCATENATE G_TABCTRL110_WA-DESC2
5722                G_TABCTRL110_WA-DESC3 G_TABCTRL110_WA-DESC4
5723            G_TABCTRL110_WA-USER_DESC INTO IST_SPELL_LINE-TDLINE SEPARATED
5724                BY SPACE.
5725                IST_SPELL_LINE-SRNO = G_TABCTRL110_WA-SRNO.
5726                APPEND IST_SPELL_LINE.
5727                CONTINUE.
5728
5729              WHEN G_TABCTRL110_WA-OTH3.
5730                CONCATENATE G_TABCTRL110_WA-DESC3 G_TABCTRL110_WA-DESC4
5731            G_TABCTRL110_WA-USER_DESC INTO IST_SPELL_LINE-TDLINE SEPARATED
5732                BY SPACE.
5733                IST_SPELL_LINE-SRNO = G_TABCTRL110_WA-SRNO.
5734                APPEND IST_SPELL_LINE.
5735                CONTINUE.
5736
5737              WHEN G_TABCTRL110_WA-OTH4.
5738                CONCATENATE G_TABCTRL110_WA-DESC4
5739            G_TABCTRL110_WA-USER_DESC INTO IST_SPELL_LINE-TDLINE SEPARATED
5740                BY SPACE.
5741                IST_SPELL_LINE-SRNO = G_TABCTRL110_WA-SRNO.
5742                APPEND IST_SPELL_LINE.
5743                CONTINUE.
5744
5745              WHEN OTHERS.
5746                IF NOT G_TABCTRL110_WA-USER_DESC IS INITIAL.
5747                  IST_SPELL_LINE-TDLINE = G_TABCTRL110_WA-USER_DESC .
5748                  IST_SPELL_LINE-SRNO   = G_TABCTRL110_WA-SRNO.
5749                  APPEND IST_SPELL_LINE.
5750                ENDIF.
5751                CONTINUE.
5752            ENDCASE.
5753          ENDLOOP.
5754          CLEAR:SY-UCOMM,OK_CODE110.
5755
5756   *     Export ist_spell_line to memory id 'SPELL'.
5757          IST_SPELL_LINE1[] = IST_SPELL_LINE[].
5758          PERFORM SPELL_CHECK.
5759   *      .
5760        ENDIF.
5761      ELSE.
5762
5763      ENDIF.
5764
5765    ENDFORM.                    "spell_check1
5766   *ENDMODULE.                 " spell_check1  INPUT
5767   *&---------------------------------------------------------------------*
5768   *&      Module  change_Other  INPUT
5769   *&---------------------------------------------------------------------*
5770   *       text
5771   *----------------------------------------------------------------------*
5772    MODULE CHANGE_OTHER INPUT.
5773      IF SY-UCOMM = 'DBCLICK' AND G_MODE = 'CHA'.
5774   *   Read table tabctrl110_itab index g_currline.
5775      ENDIF.
5776    ENDMODULE.                 " change_Other  INPUT
5777   *&---------------------------------------------------------------------*
5778   *&      Module  get_user  OUTPUT
5779   *&---------------------------------------------------------------------*
5780   *       text
5781   *----------------------------------------------------------------------*
5782    MODULE GET_USER OUTPUT.
5783      DATA: L_REQNO LIKE ZMM_CDHD-REQNO.
5784
5785      IF SY-TCODE = 'ZCODG'.
5786        GET PARAMETER ID 'ZREQNO' FIELD L_REQNO.
5787        SELECT SINGLE * FROM ZMM_CDHD
5788              WHERE REQNO = L_REQNO.
5789        IF SY-UNAME <> 'CODIFICATION' AND
5790           ZMM_CDHD-REQCL = 'IR'.
5791          G_MODE = 'DIS'.
5792        ELSEIF SY-UNAME <> 'CODIFICATION' AND
5793           ZMM_CDHD-REQCL <> 'IR' .
5794          G_MODE = 'COD'.
5795        ELSEIF SY-UNAME = 'CODIFICATION'.
5796          G_MODE = 'COD'.
5797        ENDIF.
5798      ENDIF.
5799
5800      IF G_USER_FOUND = ''.
5801        PERFORM FIND_USER.
5802      ENDIF.
5803      IF  ZMM_CDHD_ST-REQNO <> ''.
5804        IF G_MODE = 'APR'.
5805          IF G_USER = 'M' OR
5806             G_USER = 'L'.
5807   *       do nothing.
5808          ELSE.
5809   *        message e057(zmm_oth).  << GC100805>>
5810          ENDIF.
5811        ENDIF.
5812      ENDIF.
5813   *
5814      IF SY-TCODE = 'ZCODG'.
5815        GET PARAMETER ID 'ZREQNO' FIELD ZMM_CDHD_ST-REQNO.
5816        IF IST_ALPHANUM IS INITIAL.
5817          PERFORM ALPHANUM.
5818        ENDIF.
5819      ENDIF.
5820
5821    ENDMODULE.                 " get_user  OUTPUT
5822   *&---------------------------------------------------------------------*
5823   *&      Form  change_Rel
5824   *&---------------------------------------------------------------------*
5825   *       text
5826   *----------------------------------------------------------------------*
5827   *  -->  p1        text
5828   *  <--  p2        text
5829   *----------------------------------------------------------------------*
5830    FORM CHANGE_REL.
5831      DATA : L_ANS.
5832      IF ZMM_CDHD_ST-STATUS_FLAG = 'X' AND G_MODE = 'CHA'.
5833        " Begin of <RD1k960036>.
5834   *     CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
5835   *       EXPORTING
5836   *        DEFAULTOPTION        = 'N'
5837   *         TEXTLINE1            = 'Release will be reset. Proceed ?'
5838   **         TEXTLINE2            = ' '
5839   *         TITEL                = 'Release Reset'
5840   **
5841   *    IMPORTING
5842   *        ANSWER               = l_ans.
5843
5844        DATA : L_GET10(1) TYPE C.
5845        CALL FUNCTION 'POPUP_TO_CONFIRM'
5846          EXPORTING
5847            TITLEBAR       = 'Release Reset'
5848            TEXT_QUESTION  = 'Release will be reset. Proceed ?'
5849            DEFAULT_BUTTON = '2'
5850            START_COLUMN   = 25
5851            START_ROW      = 6
5852          IMPORTING
5853            ANSWER         = L_GET10
5854          EXCEPTIONS
5855            TEXT_NOT_FOUND = 1
5856            OTHERS         = 2.
5857        IF SY-SUBRC = 0.
5858          CASE L_GET10.
5859            WHEN '1'.
5860              MOVE 'J' TO L_ANS.
5861            WHEN '2'.
5862              MOVE 'N' TO L_ANS.
5863          ENDCASE.
5864        ENDIF.
5865        " End of <RD1k960036>.
5866
5867        IF L_ANS = 'J'.
5868          ZMM_CDHD_ST-STATUS_FLAG = ''.
5869          ZMM_CDHD_ST-APPROVE_MRP = ''.
5870          ZMM_CDHD_ST-APPROVE_L2 = ''.
5871        ELSE.
5872          PERFORM CLEAR_VAR.
5873          LEAVE TO SCREEN 100.
5874        ENDIF.
5875      ENDIF.
5876    ENDFORM.                    " change_Rel
5877   *&---------------------------------------------------------------------*
5878   *&      Form  Change_Restrict
5879   *&---------------------------------------------------------------------*
5880   *       text
5881   *----------------------------------------------------------------------*
5882   *      -->P_L_CDHD  text
5883   *----------------------------------------------------------------------*
5884    FORM CHANGE_RESTRICT1.
5885      DATA : L_ANS.
5886      IF SY-UNAME <> ZMM_CDHD_ST-REQCPF AND G_USER = ''.
5887        CASE G_MODE.
5888          WHEN 'CHA' OR 'REL'.
5889            MESSAGE I020(ZMM_OTH).
5890            PERFORM CLEAR_VAR.
5891            LEAVE TO SCREEN 100.
5892        ENDCASE.
5893      ENDIF.
5894   *
5895      IF ZMM_CDHD_ST-STATUS_FLAG = 'X' AND G_MODE = 'CHA'..
5896        " Begin of <RD1K960036>.
5897
5898   *     CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
5899   *       EXPORTING
5900   *        DEFAULTOPTION        = 'N'
5901   *         TEXTLINE1            = 'Release will be reset. Proceed ?'
5902   **         TEXTLINE2            = ' '
5903   *         TITEL                = 'Release Reset'
5904   **
5905   *    IMPORTING
5906   *        ANSWER               = l_ans.
5907
5908        DATA : L_GET11(1) TYPE C.
5909
5910        CALL FUNCTION 'POPUP_TO_CONFIRM'
5911          EXPORTING
5912            TEXT_QUESTION  = 'Release will be reset. Proceed ?'
5913            DEFAULT_BUTTON = '2'
5914            START_COLUMN   = 25
5915            START_ROW      = 6
5916          IMPORTING
5917            ANSWER         = L_GET11
5918          EXCEPTIONS
5919            TEXT_NOT_FOUND = 1
5920            OTHERS         = 2.
5921
5922        IF SY-SUBRC = 0.
5923          CASE L_GET11.
5924            WHEN '1'.
5925              MOVE 'J' TO L_ANS.
5926            WHEN '2'.
5927              MOVE 'N' TO L_ANS.
5928          ENDCASE.
5929        ENDIF.
5930        " End of <RD1K960036>.
5931
5932        IF L_ANS = 'J'.
5933          ZMM_CDHD_ST-STATUS_FLAG = ''.
5934          ZMM_CDHD_ST-APPROVE_MRP = ''.
5935          ZMM_CDHD_ST-APPROVE_L2 = ''.
5936        ELSE.
5937          PERFORM CLEAR_VAR.
5938          LEAVE TO SCREEN 100.
5939        ENDIF.
5940      ENDIF.
5941    ENDFORM.                    " Change_Restrict
5942   *&---------------------------------------------------------------------*
5943   *&      Form  update_approval
5944   *&---------------------------------------------------------------------*
5945   *       text
5946   *----------------------------------------------------------------------*
5947   *  -->  p1        text
5948   *  <--  p2        text
5949   *----------------------------------------------------------------------*
5950    FORM UPDATE_APPROVAL.
5951      DATA : L_110ITAB TYPE T_TABCTRL110.
5952      CASE G_USER.
5953        WHEN 'M'.
5954          IF ZMM_CDHD_ST-APPROVE_MRP <> ''.
5955            UPDATE ZMM_CDHD SET APPROVE_MRP = 'X'
5956                                APPDATE     = SY-DATUM
5957                                APPCPF      = SY-UNAME
5958                                WHERE REQNO = ZMM_CDHD_ST-REQNO.
5959   **To check, if the mail has to be send after Tech Auth Approval.
5960            IF ZMM_CDHD_ST-MTART = 'ZSTO'.
5961              READ TABLE G_TABCTRL110_ITAB INTO L_110ITAB
5962                   WITH KEY OTH1 = 'X'.
5963              IF SY-SUBRC <> 0.
5964                PERFORM SEND_MAIL_TO_CDCELL.
5965                IF ZMM_CDHD_ST-REQCL <> 'N'.
5966                  MOVE 'IC' TO ZMM_CDHD_ST-REQCL.
5967                  UPDATE ZMM_CDHD SET REQCL = ZMM_CDHD_ST-REQCL
5968                               WHERE REQNO = ZMM_CDHD_ST-REQNO.
5969                ENDIF.
5970              ENDIF.
5971            ELSE.
5972              PERFORM SEND_MAIL_TO_CDCELL.
5973              IF ZMM_CDHD_ST-REQCL <> 'N'.
5974                MOVE 'IC' TO ZMM_CDHD_ST-REQCL.
5975                UPDATE ZMM_CDHD SET REQCL = ZMM_CDHD_ST-REQCL
5976                             WHERE REQNO = ZMM_CDHD_ST-REQNO.
5977              ENDIF.
5978            ENDIF.
5979   *
5980            PERFORM PREPARE_UPDATE.
5981            MESSAGE I022(ZMM_OTH).
5982          ELSE.
5983            MESSAGE I024(ZMM_OTH) WITH 'MRP APPROVAL'.
5984          ENDIF.
5985        WHEN 'L'.
5986          IF ZMM_CDHD_ST-APPROVE_L2 <> ''.
5987            UPDATE ZMM_CDHD SET APPROVE_L2 = 'X'
5988                                APPDATE    = SY-DATUM
5989                                APPCPF     = SY-UNAME
5990            WHERE REQNO = ZMM_CDHD_ST-REQNO.
5991   *
5992            PERFORM SEND_MAIL_TO_CDCELL.
5993            IF ZMM_CDHD_ST-REQCL <> 'N'.
5994              MOVE 'IC' TO ZMM_CDHD_ST-REQCL.
5995              UPDATE ZMM_CDHD SET REQCL = ZMM_CDHD_ST-REQCL
5996                             WHERE REQNO = ZMM_CDHD_ST-REQNO.
5997            ENDIF.
5998
5999   *
6000            PERFORM PREPARE_UPDATE.
6001            MESSAGE I023(ZMM_OTH).
6002          ELSE.
6003            MESSAGE I024(ZMM_OTH) WITH 'L2 APPROVAL'.
6004          ENDIF.
6005      ENDCASE.
6006      PERFORM CLEAR_VAR.
6007
6008    ENDFORM.                    " update_approval
6009
6010   *&---------------------------------------------------------------------*
6011   *&      Form  move_descriptions
6012   *&---------------------------------------------------------------------*
6013   *       text
6014   *----------------------------------------------------------------------*
6015   *  -->  p1        text
6016   *  <--  p2        text
6017   *----------------------------------------------------------------------*
6018    FORM MOVE_DESCRIPTIONS.
6019
6020      DESCP1 = G_TABCTRL110_WA-DESC1.
6021      DESCP2 = G_TABCTRL110_WA-DESC2.
6022      DESCP3 = G_TABCTRL110_WA-DESC3.
6023      DESCP4 = G_TABCTRL110_WA-DESC4.
6024
6025    ENDFORM.                    " move_descriptions
6026   *&---------------------------------------------------------------------*
6027   *&      Form  REL_APR_STATUS
6028   *&---------------------------------------------------------------------*
6029   *       text
6030   *----------------------------------------------------------------------*
6031   *  -->  p1        text
6032   *  <--  p2        text
6033   *----------------------------------------------------------------------*
6034    FORM REL_APR_STATUS.
6035      IF ZMM_CDHD_ST-STATUS_FLAG IS INITIAL. "Req not released
6036        MESSAGE I026(ZMM_OTH).
6037        PERFORM CLEAR_VAR.
6038        LEAVE TO SCREEN 100.
6039      ENDIF.
6040
6041      IF G_USER = 'L' AND ZMM_CDHD_ST-APPROVE_MRP = ''.
6042        MESSAGE I027(ZMM_OTH) WITH 'MRP CONTROLLER'.
6043        PERFORM CLEAR_VAR.
6044        LEAVE TO SCREEN 100.
6045      ENDIF.
6046
6047    ENDFORM.                    " REL_APR_STATUS
6048   **********************************************************
6049    FORM POPUP_USERDESC.
6050      DATA L_ANS.
6051      IF G_TABCTRL110_WA-DESC1 = 'OTHER' AND SY-TCODE <> 'ZCODG'.
6052        " Begin of <RD1K960036>.
6053   *     CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_MESSAGE'
6054   *          EXPORTING
6055   *           DEFAULTOPTION        = 'N'
6056   *      DIAGNOSETEXT1        = 'Use of "OTHER" in Main Material Attribute  will  change the release'
6057   *           DIAGNOSETEXT2        = 'strategy to: '
6058   *           DIAGNOSETEXT3        =  '(1) Creator (2) MRP controller (3) Tech.Appr.Authority(L2 or above)'
6059   *      TEXTLINE1            = 'The request will be posted to Codification  cell only after'
6060   *           TEXTLINE2            =
6061   *           'approval of  TECH.APPR.AUTHORITY(L2 or above)   Continue? '
6062   *           TITEL                = 'Approval'
6063   **                        START_COLUMN         = 25
6064   **                        START_ROW            = 6
6065   *          CANCEL_DISPLAY       = ''
6066   *           IMPORTING
6067   *              ANSWER               = l_ans
6068
6069        DATA : L_GET1(1) TYPE C.
6070        CALL FUNCTION 'POPUP_TO_CONFIRM'
6071          EXPORTING
6072           TITLEBAR                    = 'Approva '
6073           DIAGNOSE_OBJECT             = 'ZHR1'
6074            TEXT_QUESTION               = 'The request will be posted to Codification  cell only after'
6075                                          &' approval of TECH.APPR.AUTHORITY(L2 or above)   Continue?.'
6076           DEFAULT_BUTTON              = '2'
6077           START_COLUMN                = 25
6078           START_ROW                   = 6
6079         IMPORTING
6080           ANSWER                      = L_GET1
6081         EXCEPTIONS
6082        TEXT_NOT_FOUND              = 1
6083        OTHERS                      = 2
6084                  .
6085        IF SY-SUBRC = 0.
6086          CASE L_GET1.
6087            WHEN '1'.
6088              MOVE 'J' TO L_ANS.
6089            WHEN '2'.
6090              MOVE 'N' TO L_ANS.
6091          ENDCASE.
6092        ENDIF.
6093        " End of <RD1K960036>.
6094        .
6095        IF L_ANS = 'J'.
6096          CALL SCREEN 115 STARTING AT 18 17 ENDING AT 120 23.
6097        ELSE.
6098          G_TABCTRL110_WA-DESC1 = ''.
6099          G_TABCTRL110_WA-OTH1 = ''.
6100
6101        ENDIF.
6102      ELSE.
6103        IF G_OK_CODE110 = 'PB_AD'.
6104          CONCATENATE G_TABCTRL110_WA-DESC1 G_TABCTRL110_WA-DESC2
6105                      G_TABCTRL110_WA-DESC3 G_TABCTRL110_WA-DESC4
6106                      INTO G_DESC1_4 SEPARATED BY SPACE.
6107          CONDENSE G_DESC1_4.
6108          USER_DESC_LEN = STRLEN( G_DESC1_4 ).
6109          IF USER_DESC_LEN >= 86.
6110            MESSAGE I076(ZMM_OTH).
6111          ELSE.
6112            CLEAR USER_DESC_LEN.
6113            CALL SCREEN 115 STARTING AT 18 17 ENDING AT 120 23.
6114          ENDIF.
6115        ELSE.     " OTHER at subattrib 1/2/3
6116          CALL SCREEN 115 STARTING AT 18 17 ENDING AT 120 23.
6117        ENDIF.
6118      ENDIF.
6119    ENDFORM.                    " popup_userdesc
6120
6121   **********************************************************
6122    FORM CHECK_OTHER.
6123   *
6124      LOOP AT G_TABCTRL110_ITAB INTO G_TABCTRL110_WA.
6125        IF G_TABCTRL110_WA-DESC1 = 'OTHER' OR
6126           G_TABCTRL110_WA-DESC2 = 'OTHER' OR
6127           G_TABCTRL110_WA-DESC3 = 'OTHER' OR
6128           G_TABCTRL110_WA-DESC4 = 'OTHER'.
6129          MESSAGE I029(ZMM_OTH).
6130          LEAVE TO SCREEN 100.
6131        ENDIF.
6132      ENDLOOP.
6133   *
6134    ENDFORM.                    " check_other
6135   **********************************************************
6136   *&---------------------------------------------------------------------*
6137   *&      Form  SPELL_ERROR_LINES
6138   *&---------------------------------------------------------------------*
6139   *       text
6140   *----------------------------------------------------------------------*
6141   *  -->  p1        text
6142   *  <--  p2        text
6143   *----------------------------------------------------------------------*
6144    FORM SPELL_ERROR_LINES.
6145      DATA :Z TYPE I, CT_IDX TYPE I.
6146      DATA : L_STATUS(2).
6147   *
6148      TYPES: BEGIN OF ITAB_TYPE,
6149              WORD(60),
6150              SRNO(3),
6151            END   OF ITAB_TYPE.
6152
6153      DATA: BEGIN OF CHECKTAB1 OCCURS 0,
6154             BEGRIFF(60),
6155             SRNO(3) TYPE N,
6156            END OF CHECKTAB1.
6157
6158      DATA: ITAB TYPE STANDARD TABLE OF ITAB_TYPE WITH HEADER LINE.
6159      DATA  ITAB1 LIKE TABLE OF ITAB WITH HEADER LINE.
6160
6161      IF CHECKTAB[] IS INITIAL.
6162        LOOP AT G_TABCTRL110_ITAB INTO G_TABCTRL110_WA.
6163          IF G_TABCTRL110_WA-COMP_FLG = 'S'.
6164            REPLACE 'S' WITH '' INTO G_TABCTRL110_WA-COMP_FLG.
6165            G_TABCTRL110_WA-RSN      = ''.
6166            MODIFY G_TABCTRL110_ITAB FROM G_TABCTRL110_WA INDEX Z
6167               TRANSPORTING COMP_FLG RSN.
6168          ENDIF.
6169        ENDLOOP.
6170      ENDIF.
6171      CHECK NOT CHECKTAB[] IS INITIAL.
6172   *
6173      CHECKTAB1[] = CHECKTAB[].
6174      LOOP AT G_TABCTRL110_ITAB INTO G_TABCTRL110_WA.
6175        Z = SY-TABIX.
6176        SPLIT  G_TABCTRL110_WA-DESC_FIN AT ' ' INTO TABLE ITAB.
6177        LOOP AT ITAB.
6178          MOVE Z TO ITAB-SRNO.
6179          MODIFY ITAB INDEX SY-TABIX.
6180        ENDLOOP.
6181        APPEND LINES OF ITAB TO ITAB1.
6182        CLEAR Z.
6183      ENDLOOP.
6184   *
6185      CLEAR Z.
6186      LOOP AT G_TABCTRL110_ITAB INTO G_TABCTRL110_WA.
6187        IF G_TABCTRL110_WA-COMP_FLG+0(1) = 'S'.
6188          CONCATENATE '' G_TABCTRL110_WA-COMP_FLG+1(1) INTO
6189                 G_TABCTRL110_WA-COMP_FLG.
6190          G_TABCTRL110_WA-RSN      = ''.
6191
6192          MODIFY G_TABCTRL110_ITAB FROM G_TABCTRL110_WA INDEX SY-TABIX
6193                  TRANSPORTING COMP_FLG RSN.
6194        ELSE.
6195          CONTINUE.
6196        ENDIF.
6197      ENDLOOP.
6198
6199      LOOP AT CHECKTAB1.
6200        CT_IDX = SY-TABIX.
6201        READ TABLE ITAB1 WITH KEY WORD = CHECKTAB1-BEGRIFF.
6202        IF SY-SUBRC = 0.
6203          CHECKTAB1-SRNO = ITAB1-SRNO.
6204          MODIFY CHECKTAB1 INDEX CT_IDX TRANSPORTING SRNO.
6205          IF G_TABCTRL110_WA-COMP_FLG+1(1) = ''.
6206            G_TABCTRL110_WA-COMP_FLG = 'S'.
6207            G_TABCTRL110_WA-RSN      = 'Spelling Mistake'.
6208          ELSE.
6209            CONCATENATE 'S' G_TABCTRL110_WA-COMP_FLG+1(1) INTO L_STATUS.
6210            G_TABCTRL110_WA-COMP_FLG = L_STATUS.
6211          ENDIF.
6212          Z = ITAB1-SRNO.
6213          MODIFY G_TABCTRL110_ITAB FROM G_TABCTRL110_WA INDEX Z
6214               TRANSPORTING COMP_FLG RSN.
6215        ENDIF.
6216      ENDLOOP.
6217   *
6218      CLEAR SY-UCOMM.
6219    ENDFORM.                    " SPELL_ERROR_LINES
6220   *&---------------------------------------------------------------------*
6221   *&      Form  modi_check
6222   *&---------------------------------------------------------------------*
6223   *       text
6224   *----------------------------------------------------------------------*
6225   *  -->  p1        text
6226   *  <--  p2        text
6227   *----------------------------------------------------------------------*
6228    FORM MODI_CHECK.
6229      DATA : L_STATUS(2).
6230      LOOP AT G_TABCTRL110_ITAB INTO G_TABCTRL110_WA.
6231        IF G_TABCTRL110_WA-OTH1 = 'X' OR
6232           G_TABCTRL110_WA-OTH2 = 'X' OR
6233           G_TABCTRL110_WA-OTH3 = 'X' OR
6234           G_TABCTRL110_WA-OTH4 = 'X' .
6235
6236          SELECT SINGLE * FROM ZMM_MODIFIER WHERE
6237             DESC1 = G_TABCTRL110_WA-DESC1 AND
6238             DESC2 = G_TABCTRL110_WA-DESC2 AND
6239             DESC3 = G_TABCTRL110_WA-DESC3 AND
6240             DESC4 = G_TABCTRL110_WA-DESC4.
6241          IF SY-SUBRC <> 0.
6242            IF G_TABCTRL110_WA-COMP_FLG+1(1) = 'M'.
6243              CONTINUE.
6244            ELSE.
6245              IF G_TABCTRL110_WA-COMP_FLG+0(1) <> 'M'.
6246                CONCATENATE G_TABCTRL110_WA-COMP_FLG 'M' INTO
6247                G_TABCTRL110_WA-COMP_FLG.
6248                MODIFY G_TABCTRL110_ITAB FROM G_TABCTRL110_WA INDEX SY-TABIX
6249                                           TRANSPORTING COMP_FLG.
6250              ENDIF.
6251            ENDIF.
6252          ELSE.
6253   *
6254          ENDIF.
6255        ENDIF.
6256      ENDLOOP.
6257    ENDFORM.                    " modi_check
6258   *&---------------------------------------------------------------------*
6259   *&      Form  SELECT_MATERIAL_DETAILS1
6260   *&---------------------------------------------------------------------*
6261   *       text
6262   *----------------------------------------------------------------------*
6263   *  -->  p1        text
6264   *  <--  p2        text
6265   *----------------------------------------------------------------------*
6266    FORM SELECT_MATERIAL_DETAILS1.
6267
6268      CLEAR DO_NOT_CHANGE_FLAG.
6269
6270      IF G_MODE = 'CRE' OR G_MODE = 'CHA'.
6271
6272        IF CHECK_POS = 0.
6273          DESCRIBE TABLE IST_SRCHLP LINES G_MAT_FND.
6274        ENDIF.
6275   *
6276        CLEAR G_HITS_PAR.
6277
6278      ENDIF.
6279
6280      LOOP AT IST_SRCHLP INTO WA_SRCHLP.
6281
6282        DATA : L_MATNR LIKE THEAD-TDNAME.
6283        L_MATNR = WA_SRCHLP-MATNR.
6284
6285        CALL FUNCTION 'READ_TEXT'
6286          EXPORTING
6287            CLIENT                  = SY-MANDT
6288            ID                      = 'BEST'
6289            LANGUAGE                = 'E'
6290            NAME                    = L_MATNR
6291            OBJECT                  = 'MATERIAL'
6292          TABLES
6293            LINES                   = LINES
6294          EXCEPTIONS
6295            ID                      = 1
6296            LANGUAGE                = 2
6297            NAME                    = 3
6298            NOT_FOUND               = 4
6299            OBJECT                  = 5
6300            REFERENCE_CHECK         = 6
6301            WRONG_ACCESS_TO_ARCHIVE = 7
6302            OTHERS                  = 8.
6303
6304        IF SY-SUBRC <> 0.
6305   *      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
6306   *      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
6307          WA_SRCHLP-MARK = '1'.
6308          MODIFY IST_SRCHLP FROM WA_SRCHLP.
6309        ENDIF.
6310
6311      ENDLOOP.
6312
6313
6314    ENDFORM.                    " SELECT_MATERIAL_DETAILS1
6315   *&---------------------------------------------------------------------*
6316   *&      Module  CHECK_SPELL  INPUT
6317   *&---------------------------------------------------------------------*
6318   *       text
6319   *----------------------------------------------------------------------*
6320    MODULE CHECK_SPELL INPUT.
6321      DATA : L_DESC87 TYPE I.
6322      L_DESC87 = STRLEN( ZMM_CDITEM-DESC_FIN ).
6323      IF L_DESC87 > 87.
6324        MESSAGE E065(ZMM_OTH).
6325      ENDIF.
6326      IF SY-UCOMM <> 'SPELL'.
6327        CLEAR IST_SPELL_LINE.
6328        REFRESH IST_SPELL_LINE.
6329        IST_SPELL_LINE-TDLINE = ZMM_CDITEM-DESC_FIN.
6330        APPEND IST_SPELL_LINE.
6331        EXPORT G_USER TO MEMORY ID 'G_USER1'.
6332        EXPORT IST_SPELL_LINE TO MEMORY ID 'IST_SPELL_LINE'.
6333        CALL FUNCTION 'ZSPELL_CHECK'
6334          EXPORTING
6335            SPRACHE = 'EN'
6336          TABLES
6337            ILINE   = IST_SPELL_LINE.
6338        IMPORT CHECKTAB FROM MEMORY ID 'G_CHECKTAB' ACCEPTING TRUNCATION.
6339        IF NOT CHECKTAB[] IS INITIAL.
6340          MESSAGE I016(ZMM_OTH).
6341          REPLACE ZMM_CDITEM-COMP_FLG+0(1) WITH 'S' INTO ZMM_CDITEM-COMP_FLG
6342                            .
6343        ELSE.
6344          REPLACE ZMM_CDITEM-COMP_FLG+0(1) WITH '' INTO ZMM_CDITEM-COMP_FLG.
6345        ENDIF.
6346      ENDIF.
6347    ENDMODULE.                 " CHECK_SPELL  INPUT
6348   *{   INSERT         OCPK900087                                        1
6349   MODULE CHECK_STEUC INPUT.
6350     DATA: HSN1 TYPE T604F-STEUC.
6351
6352           IF ZMM_CDITEM-STEUC IS NOT INITIAL.
6353             CLEAR : HSN1 .
6354             SELECT SINGLE STEUC
6355               INTO HSN1
6356               FROM T604F
6357               WHERE STEUC = ZMM_CDITEM-STEUC.
6358               IF HSN1  IS INITIAL.
6359                 MESSAGE E503(ZMM_OTH).
6360
6361
6362               ENDIF.
6363
6364
6365
6366           ENDIF.
6367
6368
6369
6370   ENDMODULE.
6371
6372   *}   INSERT
6373
6374   *---------------------------------------------------------------------*
6375   *       FORM insert_mdlno                                             *
6376   *---------------------------------------------------------------------*
6377   *       ........                                                      *
6378   *---------------------------------------------------------------------*
6379    FORM INSERT_MDLNO.
6380      DATA L_ANS1.
6381      DATA L_INDEX LIKE SY-TABIX.
6382      DATA L_MDLNO LIKE ZMM_MDL-MDLNO.
6383   ***   read table g_tablctrl120_itab into g_tablctrl120_wa index
6384   ***    g_curr_line_120.
6385   *  read table g_tablctrl120_itab into g_tablctrl120_wa "added on 20.12.
6386   *05
6387   *    with key flag = 'X'.
6388   *  If sy-subrc = 0 .
6389   *
6390      " Begin of <RD1K960036>.
6391
6392   *   CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
6393   *          EXPORTING
6394   *            DEFAULTOPTION        = 'Y'
6395   *             TEXTLINE1            = 'Model No. of selected lines will be '
6396   *                                     &'inserted. Continue?'
6397   *            TITEL                = 'Insert OTHER Models'
6398   *
6399   *         IMPORTING
6400   *           ANSWER               = l_ans1
6401      DATA : L_GET2(1) TYPE C.
6402      CALL FUNCTION 'POPUP_TO_CONFIRM'
6403        EXPORTING
6404          TITLEBAR       = 'Insert OTHER Models '
6405          TEXT_QUESTION  = 'Model No. of selected lines will be inserted. Continue?'
6406          DEFAULT_BUTTON = '1'
6407          START_COLUMN   = 25
6408          START_ROW      = 6
6409        IMPORTING
6410          ANSWER         = L_GET2
6411        EXCEPTIONS
6412          TEXT_NOT_FOUND = 1
6413          OTHERS         = 2.
6414      IF SY-SUBRC = 0.
6415        CASE L_GET2.
6416          WHEN '1'.
6417            MOVE 'J' TO L_ANS1.
6418          WHEN '2'.
6419            MOVE 'N' TO L_ANS1.
6420        ENDCASE.
6421      ENDIF.
6422      " End of <RD1K960036>.
6423      .
6424      IF L_ANS1 = 'J'.
6425
6426        LOOP AT G_TABLCTRL120_ITAB INTO G_TABLCTRL120_WA.
6427          L_INDEX = SY-TABIX.
6428          IF G_TABLCTRL120_WA-FLAG = 'X'.
6429            IF G_TABLCTRL120_WA-OTH_MDL = 'X'.
6430              ZMM_MDL-MDLNO = G_TABLCTRL120_WA-MDLNO.
6431              ZMM_MDL-CREBY = SY-UNAME.
6432              ZMM_MDL-CREDT = SY-DATUM.
6433              TRANSLATE ZMM_MDL-MDLNO TO UPPER CASE.
6434   *         modify zmm_mdl from zmm_mdl.
6435              INSERT INTO ZMM_MDL VALUES ZMM_MDL.
6436              COMMIT WORK.
6437              REPLACE 'L' WITH '' INTO G_TABLCTRL120_WA-COMP_FLG.
6438              MODIFY G_TABLCTRL120_ITAB FROM G_TABLCTRL120_WA INDEX
6439               SY-TABIX TRANSPORTING COMP_FLG.
6440              CLEAR ZMM_MDL-MDLNO.
6441            ENDIF.
6442          ELSE.
6443            SELECT SINGLE MDLNO FROM ZMM_MDL INTO L_MDLNO WHERE MDLNO =
6444                G_TABLCTRL120_WA-MDLNO.
6445            IF SY-SUBRC = 0 AND G_TABLCTRL120_WA-OTH_MDL = 'X'.
6446              REPLACE 'L' WITH '' INTO G_TABLCTRL120_WA-COMP_FLG.
6447              MODIFY G_TABLCTRL120_ITAB FROM G_TABLCTRL120_WA INDEX
6448               L_INDEX TRANSPORTING COMP_FLG.
6449            ENDIF.
6450          ENDIF.
6451        ENDLOOP.
6452      ENDIF.
6453    ENDFORM.                    " insert_mdlno
6454   *&---------------------------------------------------------------------*
6455   *&      Form  spell_check2
6456   *&---------------------------------------------------------------------*
6457   *       text
6458   *----------------------------------------------------------------------*
6459   *  -->  p1        text
6460   *  <--  p2        text
6461   *----------------------------------------------------------------------*
6462    FORM SPELL_CHECK2.
6463   *
6464      CLEAR IST_SPELL_LINE.
6465      REFRESH IST_SPELL_LINE.
6466      CLEAR SY-UCOMM.
6467
6468      LOOP AT G_TABLCTRL120_ITAB INTO G_TABLCTRL120_WA.
6469        IST_SPELL_LINE-TDLINE = G_TABLCTRL120_WA-DESC_FIN.
6470        IST_SPELL_LINE-SRNO =   G_TABLCTRL120_WA-SRNO.
6471        APPEND IST_SPELL_LINE.
6472      ENDLOOP.
6473      EXPORT IST_SPELL_LINE TO MEMORY ID 'IST_SPELL_LINE'.
6474      EXPORT G_USER TO MEMORY ID 'G_USER1'.
6475      CALL FUNCTION 'ZSPELL_CHECK'
6476        EXPORTING
6477          SPRACHE = 'EN'
6478        TABLES
6479          ILINE   = IST_SPELL_LINE.
6480
6481      IMPORT CHECKTAB FROM MEMORY ID 'G_CHECKTAB' ACCEPTING TRUNCATION.
6482      IF NOT CHECKTAB[] IS INITIAL.
6483
6484        MESSAGE I017(ZMM_OTH).
6485        PERFORM SPELL_ERROR_LINES_ZSPR.
6486      ELSE.
6487        MESSAGE I008(ZMM_OTH).
6488        LOOP AT G_TABLCTRL120_ITAB INTO G_TABLCTRL120_WA.
6489   *
6490          REPLACE 'S' WITH '' INTO G_TABLCTRL120_WA-COMP_FLG.
6491          MODIFY G_TABLCTRL120_ITAB FROM G_TABLCTRL120_WA INDEX SY-TABIX
6492            TRANSPORTING COMP_FLG .
6493   *
6494        ENDLOOP.
6495      ENDIF.
6496   *
6497    ENDFORM.                    " spell_check2
6498   *********************************************************************
6499    AT LINE-SELECTION.
6500   *
6501
6502      IF ZMM_CDHD_ST-MTART = 'ZSTO'.
6503        READ CURRENT LINE .
6504        WA_MODIFIER_CHECK_LIST = IST_MODIFIER_CHECK_LIST.
6505        SET PARAMETER ID 'S_MATGP' FIELD WA_MODIFIER_CHECK_LIST-MATGRP.
6506      ENDIF.
6507
6508      IF SY-DYNNR = '0120'.
6509        READ CURRENT LINE .
6510        ZMM_CDITEM-MDLNO = SY-LISEL.
6511        ZMM_CDITEM-OTH_MDL = ''.
6512        REPLACE 'L' WITH '' INTO ZMM_CDITEM-COMP_FLG.
6513      ENDIF.
6514      LEAVE TO SCREEN 0.
6515   *&---------------------------------------------------------------------*
6516   *&      Form  SPELL_ERROR_LINES_ZSPR
6517   *&---------------------------------------------------------------------*
6518   *       text
6519   *----------------------------------------------------------------------*
6520   *  -->  p1        text
6521   *  <--  p2        text
6522   *----------------------------------------------------------------------*
6523    FORM SPELL_ERROR_LINES_ZSPR.
6524      DATA :Z TYPE I, CT_IDX TYPE I.
6525      DATA : L_STATUS(2).
6526   *
6527      TYPES: BEGIN OF ITAB_TYPE,
6528              WORD(60),
6529              SRNO(3),
6530            END   OF ITAB_TYPE.
6531
6532      DATA: BEGIN OF CHECKTAB1 OCCURS 0,
6533             BEGRIFF(60),
6534             SRNO(3) TYPE N,
6535            END OF CHECKTAB1.
6536
6537      DATA: ITAB TYPE STANDARD TABLE OF ITAB_TYPE WITH HEADER LINE.
6538      DATA  ITAB1 LIKE TABLE OF ITAB WITH HEADER LINE.
6539
6540   *
6541      IF CHECKTAB[] IS INITIAL.
6542        LOOP AT G_TABLCTRL120_ITAB INTO G_TABLCTRL120_WA.
6543          IF G_TABLCTRL120_WA-COMP_FLG+0(1) = 'S'.
6544            REPLACE 'S' WITH '' INTO G_TABLCTRL120_WA-COMP_FLG.
6545            MODIFY G_TABLCTRL120_ITAB FROM G_TABLCTRL120_WA INDEX Z
6546               TRANSPORTING COMP_FLG .
6547          ENDIF.
6548        ENDLOOP.
6549      ENDIF.
6550      CHECK NOT CHECKTAB[] IS INITIAL.
6551
6552   *
6553      CHECKTAB1[] = CHECKTAB[].
6554      LOOP AT G_TABLCTRL120_ITAB INTO G_TABLCTRL120_WA.
6555        Z = SY-TABIX.
6556        SPLIT  G_TABLCTRL120_WA-DESC_FIN AT ' ' INTO TABLE ITAB.
6557        LOOP AT ITAB.
6558          MOVE Z TO ITAB-SRNO.
6559          MODIFY ITAB INDEX SY-TABIX.
6560        ENDLOOP.
6561        APPEND LINES OF ITAB TO ITAB1.
6562        CLEAR Z.
6563      ENDLOOP.
6564
6565   *
6566      CLEAR Z.
6567      LOOP AT G_TABLCTRL120_ITAB INTO G_TABLCTRL120_WA.
6568        IF G_TABLCTRL120_WA-COMP_FLG+0(1) = 'S'.
6569          REPLACE 'S' WITH '' INTO G_TABLCTRL120_WA-COMP_FLG.
6570          MODIFY G_TABLCTRL120_ITAB FROM G_TABLCTRL120_WA INDEX SY-TABIX
6571                  TRANSPORTING COMP_FLG .
6572        ELSE.
6573          CONTINUE.
6574        ENDIF.
6575      ENDLOOP.
6576
6577      LOOP AT CHECKTAB1.
6578        CT_IDX = SY-TABIX.
6579        READ TABLE ITAB1 WITH KEY WORD = CHECKTAB1-BEGRIFF.
6580        IF SY-SUBRC = 0.
6581          CHECKTAB1-SRNO = ITAB1-SRNO.
6582          MODIFY CHECKTAB1 INDEX CT_IDX TRANSPORTING SRNO.
6583          READ TABLE G_TABLCTRL120_ITAB INTO G_TABLCTRL120_WA INDEX
6584          ITAB1-SRNO.
6585          IF G_TABLCTRL120_WA-COMP_FLG+1(1) = ''.
6586            G_TABLCTRL120_WA-COMP_FLG = 'S'.
6587          ELSE.
6588            CONCATENATE 'S' G_TABLCTRL120_WA-COMP_FLG+1(1) INTO L_STATUS.
6589            G_TABLCTRL120_WA-COMP_FLG = L_STATUS.
6590          ENDIF.
6591          Z = ITAB1-SRNO.
6592          MODIFY G_TABLCTRL120_ITAB FROM G_TABLCTRL120_WA INDEX Z
6593               TRANSPORTING COMP_FLG .
6594        ENDIF.
6595      ENDLOOP.
6596
6597    ENDFORM.                    " SPELL_ERROR_LINES_ZSPR
6598   *&---------------------------------------------------------------------*
6599   *&      Form  get_srchlp_zcap
6600   *&---------------------------------------------------------------------*
6601   *       text
6602   *----------------------------------------------------------------------*
6603   *  -->  p1        text
6604   *  <--  p2        text
6605   *----------------------------------------------------------------------*
6606    FORM GET_SRCHLP_ZCAP.
6607      DATA : L_SRNO  LIKE SY-INDEX.
6608      DATA : L_LEN   LIKE SY-INDEX.
6609      DATA : L_CHECK.
6610      DATA : BEGIN OF WA_PARTDESC,
6611               PART(40),
6612             END OF WA_PARTDESC.
6613      DATA : IST_PARTDESC LIKE TABLE OF WA_PARTDESC.
6614      DATA : L_DESC(100).
6615      DATA : PART1(40),PART2(40),PART3(40),PART4(40).
6616      DATA : L_MATNR LIKE THEAD-TDNAME.
6617      DATA : IST_PARTDESC_LINES TYPE I.
6618
6619   *
6620   *   CHECK g_cursor_fld130 = 'ZMM_CDITEM-DESC_FIN' .
6621      IF G_CURSOR_FLD130 = 'ZMM_CDITEM-DESC_FIN' .
6622   *
6623        READ TABLE G_TABLCTRL130_ITAB INTO G_TABLCTRL130_WA INDEX
6624        G_CURR_LINE_130.
6625   ****To change desc_fin and SAVE without pressing ENTER
6626        IF G_DESC_FIN_CHNG = 'X' AND ZMM_CDITEM-DESC_FIN <>
6627                                     G_TABLCTRL130_WA-DESC_FIN.
6628          G_TABLCTRL130_WA-DESC_FIN = ZMM_CDITEM-DESC_FIN.
6629        ENDIF.
6630   ****To change desc_fin and SAVE without pressing ENTER
6631
6632        IF NOT G_TABLCTRL130_WA-DESC_FIN  IS INITIAL.
6633          TRANSLATE G_TABLCTRL130_WA-DESC_FIN TO UPPER CASE.
6634          SPLIT G_TABLCTRL130_WA-DESC_FIN AT ' ' INTO TABLE IST_PARTDESC.
6635   *
6636          DESCRIBE TABLE IST_PARTDESC LINES IST_PARTDESC_LINES.
6637          IF IST_PARTDESC_LINES > 2.
6638            DELETE IST_PARTDESC FROM 3 TO IST_PARTDESC_LINES.
6639          ENDIF.
6640          READ TABLE IST_PARTDESC INTO WA_PARTDESC INDEX 1.
6641
6642          CONCATENATE '%' WA_PARTDESC-PART '%' INTO L_DESC .
6643          CONDENSE L_DESC NO-GAPS.
6644   *
6645          SELECT A~MAKTG A~MATNR B~MEINS B~MFRPN B~WRKST
6646          INTO CORRESPONDING FIELDS OF TABLE IST_SRCHLP
6647          FROM MAKT AS A
6648          JOIN MARA AS B
6649          ON A~MATNR = B~MATNR
6650          WHERE B~MTART = 'ZCAP'  AND
6651          ( A~MAKTG LIKE L_DESC OR B~WRKST LIKE L_DESC )
6652   * Added on 29.12.05
6653          AND B~MSTAE = ''.
6654   * End addition.
6655          LOOP AT IST_PARTDESC INTO WA_PARTDESC.
6656            IF SY-TABIX = 1.
6657              PART1 = WA_PARTDESC-PART.
6658              CONDENSE PART1 NO-GAPS.
6659            ELSEIF SY-TABIX = 2.
6660              PART2 = WA_PARTDESC-PART.
6661              CONDENSE PART1 NO-GAPS.
6662   *
6663            ENDIF.
6664          ENDLOOP.
6665
6666          LOOP AT IST_SRCHLP INTO WA_SRCHLP.
6667            IF WA_SRCHLP-MAKTG+39(1) = '*'.
6668              CONCATENATE WA_SRCHLP-MAKTG+0(39) WA_SRCHLP-WRKST INTO
6669              WA_SRCHLP-MAKTX.
6670            ELSE.
6671              MOVE WA_SRCHLP-MAKTG TO WA_SRCHLP-MAKTX.
6672            ENDIF.
6673
6674            TRANSLATE WA_SRCHLP-MAKTX TO UPPER CASE.
6675            CHECK PART2 <> ''.
6676            SEARCH WA_SRCHLP-MAKTX FOR PART2.
6677            IF SY-SUBRC = 0.
6678   *
6679            ELSE.
6680              DELETE  IST_SRCHLP INDEX SY-TABIX.
6681            ENDIF.
6682          ENDLOOP.
6683        ENDIF.
6684        LOOP AT IST_SRCHLP INTO WA_SRCHLP.
6685          IF WA_SRCHLP-MAKTG+39(1) = '*'.
6686            CONCATENATE WA_SRCHLP-MAKTG+0(39) WA_SRCHLP-WRKST INTO
6687            WA_SRCHLP-MAKTX.
6688          ELSE.
6689            MOVE WA_SRCHLP-MAKTG TO WA_SRCHLP-MAKTX.
6690          ENDIF.
6691          L_SRNO         = L_SRNO + 1.
6692          WA_SRCHLP-SRNO = L_SRNO.
6693          L_MATNR = WA_SRCHLP-MATNR.
6694
6695          CALL FUNCTION 'READ_TEXT'
6696            EXPORTING
6697              ID                      = 'BEST'
6698              LANGUAGE                = 'E'
6699              NAME                    = L_MATNR
6700              OBJECT                  = 'MATERIAL'
6701            TABLES
6702              LINES                   = LINES
6703            EXCEPTIONS
6704              ID                      = 1
6705              LANGUAGE                = 2
6706              NAME                    = 3
6707              NOT_FOUND               = 4
6708              OBJECT                  = 5
6709              REFERENCE_CHECK         = 6
6710              WRONG_ACCESS_TO_ARCHIVE = 7
6711              OTHERS                  = 8.
6712
6713          IF SY-SUBRC <> 0.
6714   *      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
6715   *      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
6716            WA_SRCHLP-MARK = '1'.
6717          ENDIF.
6718          MODIFY IST_SRCHLP FROM WA_SRCHLP.
6719        ENDLOOP.
6720        DESCRIBE TABLE IST_SRCHLP LINES G_MAT_FND.
6721   *********************************************************************
6722   ***********************Date : 01.12.2005*****************************
6723   ** Addition for Search on Sugested Capital Code
6724   *  CHECK g_cursor_fld130 = 'ZMM_CDITEM-DESC_CDCELL' .
6725   *
6726      ELSEIF G_CURSOR_FLD130 = 'ZMM_CDITEM-DESC_CDCELL' .
6727
6728        READ TABLE G_TABLCTRL130_ITAB INTO G_TABLCTRL130_WA INDEX
6729        G_CURR_LINE_130.
6730   *****To change desc_fin and SAVE without pressing ENTER
6731   *   if G_desc_fin_chng = 'X' and zmm_cditem-desc_fin <>
6732   *                                g_TABLCTRL130_wa-desc_fin.
6733   *     g_TABLCTRL130_wa-desc_fin = zmm_cditem-desc_fin.
6734   *   Endif.
6735   *****To change desc_fin and SAVE without pressing ENTER
6736
6737        IF NOT G_TABLCTRL130_WA-DESC_CDCELL  IS INITIAL.
6738          TRANSLATE G_TABLCTRL130_WA-DESC_CDCELL TO UPPER CASE.
6739          SPLIT G_TABLCTRL130_WA-DESC_CDCELL AT ' ' INTO TABLE IST_PARTDESC.
6740   *
6741          DESCRIBE TABLE IST_PARTDESC LINES IST_PARTDESC_LINES.
6742          IF IST_PARTDESC_LINES > 2.
6743            DELETE IST_PARTDESC FROM 3 TO IST_PARTDESC_LINES.
6744          ENDIF.
6745          READ TABLE IST_PARTDESC INTO WA_PARTDESC INDEX 1.
6746
6747          CONCATENATE '%' WA_PARTDESC-PART '%' INTO L_DESC .
6748          CONDENSE L_DESC NO-GAPS.
6749   *
6750          SELECT A~MAKTG A~MATNR B~MEINS B~MFRPN B~WRKST
6751          INTO CORRESPONDING FIELDS OF TABLE IST_SRCHLP
6752          FROM MAKT AS A
6753          JOIN MARA AS B
6754          ON A~MATNR = B~MATNR
6755          WHERE B~MTART = 'ZCAP'  AND
6756          ( A~MAKTG LIKE L_DESC OR B~WRKST LIKE L_DESC )
6757          AND B~MSTAE = ''.
6758   *
6759          LOOP AT IST_PARTDESC INTO WA_PARTDESC.
6760            IF SY-TABIX = 1.
6761              PART1 = WA_PARTDESC-PART.
6762              CONDENSE PART1 NO-GAPS.
6763            ELSEIF SY-TABIX = 2.
6764              PART2 = WA_PARTDESC-PART.
6765              CONDENSE PART1 NO-GAPS.
6766   *
6767            ENDIF.
6768          ENDLOOP.
6769
6770          LOOP AT IST_SRCHLP INTO WA_SRCHLP.
6771            IF WA_SRCHLP-MAKTG+39(1) = '*'.
6772              CONCATENATE WA_SRCHLP-MAKTG+0(39) WA_SRCHLP-WRKST INTO
6773              WA_SRCHLP-MAKTX.
6774            ELSE.
6775              MOVE WA_SRCHLP-MAKTG TO WA_SRCHLP-MAKTX.
6776            ENDIF.
6777
6778            TRANSLATE WA_SRCHLP-MAKTX TO UPPER CASE.
6779            CHECK PART2 <> ''.
6780            SEARCH WA_SRCHLP-MAKTX FOR PART2.
6781            IF SY-SUBRC = 0.
6782   *
6783            ELSE.
6784              DELETE  IST_SRCHLP INDEX SY-TABIX.
6785            ENDIF.
6786          ENDLOOP.
6787        ENDIF.
6788        LOOP AT IST_SRCHLP INTO WA_SRCHLP.
6789          IF WA_SRCHLP-MAKTG+39(1) = '*'.
6790            CONCATENATE WA_SRCHLP-MAKTG+0(39) WA_SRCHLP-WRKST INTO
6791            WA_SRCHLP-MAKTX.
6792          ELSE.
6793            MOVE WA_SRCHLP-MAKTG TO WA_SRCHLP-MAKTX.
6794          ENDIF.
6795          L_SRNO         = L_SRNO + 1.
6796          WA_SRCHLP-SRNO = L_SRNO.
6797          L_MATNR = WA_SRCHLP-MATNR.
6798
6799          CALL FUNCTION 'READ_TEXT'
6800            EXPORTING
6801              ID                      = 'BEST'
6802              LANGUAGE                = 'E'
6803              NAME                    = L_MATNR
6804              OBJECT                  = 'MATERIAL'
6805            TABLES
6806              LINES                   = LINES
6807            EXCEPTIONS
6808              ID                      = 1
6809              LANGUAGE                = 2
6810              NAME                    = 3
6811              NOT_FOUND               = 4
6812              OBJECT                  = 5
6813              REFERENCE_CHECK         = 6
6814              WRONG_ACCESS_TO_ARCHIVE = 7
6815              OTHERS                  = 8.
6816
6817          IF SY-SUBRC <> 0.
6818   *      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
6819   *      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
6820            WA_SRCHLP-MARK = '1'.
6821          ENDIF.
6822          MODIFY IST_SRCHLP FROM WA_SRCHLP.
6823        ENDLOOP.
6824        DESCRIBE TABLE IST_SRCHLP LINES G_MAT_FND.
6825      ENDIF.
6826    ENDFORM.                    " get_srchlp_zcap
6827   *&---------------------------------------------------------------------*
6828   *&      Form  spell_check3
6829   *&---------------------------------------------------------------------*
6830   *       text
6831   *----------------------------------------------------------------------*
6832   *  -->  p1        text
6833   *  <--  p2        text
6834   *----------------------------------------------------------------------*
6835    FORM SPELL_CHECK3.
6836      CLEAR IST_SPELL_LINE.
6837      REFRESH IST_SPELL_LINE.
6838      CLEAR SY-UCOMM.
6839
6840      LOOP AT G_TABLCTRL130_ITAB INTO G_TABLCTRL130_WA.
6841        IST_SPELL_LINE-TDLINE = G_TABLCTRL130_WA-DESC_FIN.
6842        IST_SPELL_LINE-SRNO =   G_TABLCTRL130_WA-SRNO.
6843        APPEND IST_SPELL_LINE.
6844      ENDLOOP.
6845      EXPORT IST_SPELL_LINE TO MEMORY ID 'IST_SPELL_LINE'.
6846      EXPORT G_USER TO MEMORY ID 'G_USER1'.
6847      CALL FUNCTION 'ZSPELL_CHECK'
6848        EXPORTING
6849          SPRACHE = 'EN'
6850        TABLES
6851          ILINE   = IST_SPELL_LINE.
6852
6853      IMPORT CHECKTAB FROM MEMORY ID 'G_CHECKTAB' ACCEPTING TRUNCATION.
6854      IF NOT CHECKTAB[] IS INITIAL.
6855
6856        MESSAGE I017(ZMM_OTH).
6857        PERFORM SPELL_ERROR_LINES_ZCAP.
6858      ELSE.
6859        MESSAGE I008(ZMM_OTH).
6860        LOOP AT G_TABLCTRL130_ITAB INTO G_TABLCTRL130_WA.
6861   *
6862          REPLACE 'S' WITH '' INTO G_TABLCTRL130_WA-COMP_FLG.
6863          MODIFY G_TABLCTRL130_ITAB FROM G_TABLCTRL130_WA INDEX SY-TABIX
6864            TRANSPORTING COMP_FLG .
6865   *
6866        ENDLOOP.
6867      ENDIF.
6868   *
6869
6870    ENDFORM.                    " spell_check3
6871   *&---------------------------------------------------------------------*
6872   *&      Form  SPELL_ERROR_LINES_ZCAP
6873   *&---------------------------------------------------------------------*
6874   *       text
6875   *----------------------------------------------------------------------*
6876   *  -->  p1        text
6877   *  <--  p2        text
6878   *----------------------------------------------------------------------*
6879    FORM SPELL_ERROR_LINES_ZCAP.
6880      DATA :Z TYPE I, CT_IDX TYPE I.
6881      DATA : L_STATUS(2).
6882   * .
6883      TYPES: BEGIN OF ITAB_TYPE,
6884              WORD(60),
6885              SRNO(3),
6886            END   OF ITAB_TYPE.
6887
6888      DATA: BEGIN OF CHECKTAB1 OCCURS 0,
6889             BEGRIFF(60),
6890             SRNO(3) TYPE N,
6891            END OF CHECKTAB1.
6892
6893      DATA: ITAB TYPE STANDARD TABLE OF ITAB_TYPE WITH HEADER LINE.
6894      DATA  ITAB1 LIKE TABLE OF ITAB WITH HEADER LINE.
6895
6896   *
6897      IF CHECKTAB[] IS INITIAL.
6898        LOOP AT G_TABLCTRL130_ITAB INTO G_TABLCTRL130_WA.
6899          IF G_TABLCTRL130_WA-COMP_FLG+0(1) = 'S'.
6900            REPLACE 'S' WITH '' INTO G_TABLCTRL130_WA-COMP_FLG.
6901            MODIFY G_TABLCTRL130_ITAB FROM G_TABLCTRL130_WA INDEX Z
6902               TRANSPORTING COMP_FLG .
6903          ENDIF.
6904        ENDLOOP.
6905      ENDIF.
6906      CHECK NOT CHECKTAB[] IS INITIAL.
6907
6908   *
6909      CHECKTAB1[] = CHECKTAB[].
6910      LOOP AT G_TABLCTRL130_ITAB INTO G_TABLCTRL130_WA.
6911        Z = SY-TABIX.
6912        SPLIT  G_TABLCTRL130_WA-DESC_FIN AT ' ' INTO TABLE ITAB.
6913        LOOP AT ITAB.
6914          MOVE Z TO ITAB-SRNO.
6915          MODIFY ITAB INDEX SY-TABIX.
6916        ENDLOOP.
6917        APPEND LINES OF ITAB TO ITAB1.
6918        CLEAR Z.
6919      ENDLOOP.
6920
6921   *
6922      CLEAR Z.
6923      LOOP AT G_TABLCTRL130_ITAB INTO G_TABLCTRL130_WA.
6924        IF G_TABLCTRL130_WA-COMP_FLG+0(1) = 'S'.
6925          REPLACE 'S' WITH '' INTO G_TABLCTRL130_WA-COMP_FLG.
6926          MODIFY G_TABLCTRL130_ITAB FROM G_TABLCTRL130_WA INDEX SY-TABIX
6927                  TRANSPORTING COMP_FLG .
6928        ELSE.
6929          CONTINUE.
6930        ENDIF.
6931      ENDLOOP.
6932
6933      LOOP AT CHECKTAB1.
6934        CT_IDX = SY-TABIX.
6935        READ TABLE ITAB1 WITH KEY WORD = CHECKTAB1-BEGRIFF.
6936        IF SY-SUBRC = 0.
6937          CHECKTAB1-SRNO = ITAB1-SRNO.
6938          MODIFY CHECKTAB1 INDEX CT_IDX TRANSPORTING SRNO.
6939          READ TABLE G_TABLCTRL130_ITAB INTO G_TABLCTRL130_WA INDEX
6940          ITAB1-SRNO.
6941          IF G_TABLCTRL130_WA-COMP_FLG+1(1) = ''.
6942            G_TABLCTRL130_WA-COMP_FLG = 'S'.
6943          ELSE.
6944            CONCATENATE 'S' G_TABLCTRL130_WA-COMP_FLG+1(1) INTO L_STATUS.
6945            G_TABLCTRL130_WA-COMP_FLG = L_STATUS.
6946          ENDIF.
6947          Z = ITAB1-SRNO.
6948          MODIFY G_TABLCTRL130_ITAB FROM G_TABLCTRL130_WA INDEX Z
6949               TRANSPORTING COMP_FLG .
6950        ENDIF.
6951      ENDLOOP.
6952
6953    ENDFORM.                    " SPELL_ERROR_LINES_ZCAP
6954   *&---------------------------------------------------------------------*
6955   *&      Form  cp_matcode
6956   *&---------------------------------------------------------------------*
6957   *       text
6958   *----------------------------------------------------------------------*
6959   *  -->  p1        text
6960   *  <--  p2        text
6961   *----------------------------------------------------------------------*
6962    FORM CP_MATCODE.
6963   *   g_tabctrl110_wa = wa_srchlp-matnr.
6964
6965    ENDFORM.                    " cp_matcode
6966   *&---------------------------------------------------------------------*
6967   *&      Form  get_srno
6968   *&---------------------------------------------------------------------*
6969   *       text
6970   *----------------------------------------------------------------------*
6971   *  -->  p1        text
6972   *  <--  p2        text
6973   *----------------------------------------------------------------------*
6974    FORM GET_SRNO.
6975   *
6976   ***To get the proper serial no of line item against the
6977   ***Cursor position
6978      CASE ZMM_CDHD_ST-MTART.
6979        WHEN 'ZSTO'.
6980   *
6981          G_CURS_LN = G_CURR_LINE_110.
6982          READ TABLE G_TABCTRL110_ITAB INTO G_TABCTRL110_WA
6983                                      INDEX G_CURS_LN.
6984          G_SRNO = G_TABCTRL110_WA-SRNO.
6985        WHEN 'ZSPR'.
6986   *
6987          G_CURS_LN = G_CURR_LINE_120.
6988          READ TABLE G_TABLCTRL120_ITAB INTO G_TABLCTRL120_WA
6989                        INDEX G_CURS_LN.
6990          G_SRNO = G_TABLCTRL120_WA-SRNO.
6991        WHEN 'ZCAP'.
6992          MOVE TABLCTRL130-CURRENT_LINE TO G_CURS_LN.
6993          READ TABLE G_TABLCTRL130_ITAB INTO G_TABLCTRL130_WA
6994                        INDEX G_CURS_LN.
6995          G_SRNO = G_TABLCTRL130_WA-SRNO.
6996        WHEN 'ZDIS'.
6997          MOVE TABLCTRL140-CURRENT_LINE TO G_CURS_LN.
6998          READ TABLE G_TABLCTRL140_ITAB INTO G_TABLCTRL140_WA
6999                                      INDEX G_CURS_LN.
7000          G_SRNO = G_TABLCTRL140_WA-SRNO.
7001      ENDCASE.
7002
7003
7004    ENDFORM.                    " get_srno
7005   *&---------------------------------------------------------------------*
7006   *&      Form  CHANGE_MRP
7007   *&---------------------------------------------------------------------*
7008   *       text
7009   *----------------------------------------------------------------------*
7010   *  -->  p1        text
7011   *  <--  p2        text
7012   *----------------------------------------------------------------------*
7013    FORM CHANGE_MRP.
7014      IF  G_MODE = 'CHA' OR G_MODE = 'REL' OR G_MODE = 'APR'.
7015   *
7016        AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
7017                       ID 'M_BANF_WRK' FIELD ZMM_CDHD_ST-WERKS
7018                       ID 'ACTVT' FIELD '01'.
7019        IF SY-SUBRC = 0.
7020          G_CHANGE_AUTH = 'X'.
7021        ELSE.
7022          G_CHANGE_AUTH = ''.
7023        ENDIF.
7024
7025      ENDIF.
7026    ENDFORM.                    " CHANGE_MRP
7027   *&---------------------------------------------------------------------*
7028   *&      Form  exit_confirm
7029   *&---------------------------------------------------------------------*
7030   *       text
7031   *----------------------------------------------------------------------*
7032   *  -->  p1        text
7033   *  <--  p2        text
7034   *----------------------------------------------------------------------*
7035    FORM EXIT_CONFIRM.
7036      DATA L_CHOICE1.
7037      CLEAR L_CHOICE1.
7038      IF G_MODE <> 'DIS'.
7039        " Begin of <RD1K960036>.
7040
7041   *     CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
7042   *          EXPORTING
7043   *               TEXTLINE1      = 'Data will be lost, Want to quit? '
7044   *               TITEL          = 'EXIT'
7045   *               START_COLUMN   = 25
7046   *               START_ROW      = 6
7047   *               CANCEL_DISPLAY = ''
7048   *          IMPORTING
7049   *               ANSWER         = l_choice1.
7050        DATA : L_GET3(1) TYPE C.
7051        CALL FUNCTION 'POPUP_TO_CONFIRM'
7052          EXPORTING
7053            TITLEBAR       = 'EXIT '
7054            TEXT_QUESTION  = 'Data will be lost, Want to quit? '
7055            START_COLUMN   = 25
7056            START_ROW      = 6
7057          IMPORTING
7058            ANSWER         = L_GET3
7059          EXCEPTIONS
7060            TEXT_NOT_FOUND = 1
7061            OTHERS         = 2.
7062        IF SY-SUBRC = 0.
7063          CASE L_GET3.
7064            WHEN '1'.
7065              MOVE 'J' TO L_CHOICE1.
7066            WHEN '2'.
7067              MOVE 'N' TO L_CHOICE1.
7068          ENDCASE.
7069        ENDIF.
7070        " End of <RD1K960036>.
7071
7072        IF L_CHOICE1 = 'J'.
7073          CLEAR L_CHOICE1.
7074          PERFORM UNDO_LONGTEXT.
7075          PERFORM CLEAR_VAR.
7076          PERFORM UNLOCK_REQ.
7077          IF OKCODE_100 = 'BAC'.
7078            LEAVE TO SCREEN 100.
7079          ELSE.
7080            LEAVE PROGRAM.
7081          ENDIF.
7082        ENDIF.
7083      ELSE.
7084        " Begin of <RD1K960036>.
7085
7086   *     CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
7087   *          EXPORTING
7088   *               TEXTLINE1      = 'Want to quit? '
7089   *               TITEL          = 'EXIT'
7090   *               START_COLUMN   = 25
7091   *               START_ROW      = 6
7092   *               CANCEL_DISPLAY = ''
7093   *          IMPORTING
7094   *               ANSWER         = l_choice1.
7095
7096        DATA : L_GET4(1) TYPE C.
7097        CALL FUNCTION 'POPUP_TO_CONFIRM'
7098          EXPORTING
7099            TITLEBAR       = 'EXIT '
7100            TEXT_QUESTION  = 'Want to quit? '
7101            START_COLUMN   = 25
7102            START_ROW      = 6
7103          IMPORTING
7104            ANSWER         = L_GET4
7105          EXCEPTIONS
7106            TEXT_NOT_FOUND = 1
7107            OTHERS         = 2.
7108        IF SY-SUBRC = 0.
7109          CASE L_GET4.
7110            WHEN '1'.
7111              MOVE 'J' TO L_CHOICE1.
7112            WHEN '2'.
7113              MOVE 'N' TO L_CHOICE1.
7114          ENDCASE.
7115        ENDIF.
7116        " End of <RD1K960036>.
7117
7118        IF L_CHOICE1 = 'J'.
7119          PERFORM CLEAR_VAR.
7120          IF OKCODE_100 = 'BAC'.
7121            LEAVE TO SCREEN 100.
7122          ELSE.
7123            LEAVE PROGRAM.
7124          ENDIF.
7125        ENDIF.
7126      ENDIF.
7127    ENDFORM.                    " exit_confirm
7128   *
7129   *&---------------------------------------------------------------------*
7130   *&      Form  get_dummyno
7131   *&---------------------------------------------------------------------*
7132   *       text
7133   *----------------------------------------------------------------------*
7134   *  -->  p1        text
7135   *  <--  p2        text
7136   *----------------------------------------------------------------------*
7137    FORM GET_DUMMYNO.
7138      DATA:  X TYPE I,
7139             Y TYPE I,
7140             L_USER LIKE SY-UNAME.
7141      CLEAR: L_USER, G_USER_LOGGED.
7142      L_USER = SY-UNAME.
7143      X = STRLEN( SY-UNAME ).
7144      Y = 10 - X.
7145      IF X < 10.
7146        DO Y TIMES.
7147          CONCATENATE L_USER '0' INTO L_USER.
7148        ENDDO.
7149        G_USER_LOGGED = L_USER.
7150      ELSEIF X > 10.
7151        G_USER_LOGGED = SY-UNAME+0(10).
7152      ELSE.
7153        G_USER_LOGGED = SY-UNAME.
7154      ENDIF.
7155    ENDFORM.                    " get_dummyno
7156   *&---------------------------------------------------------------------*
7157   *&      Form  get_nextsrno_spr
7158   *&---------------------------------------------------------------------*
7159   *       text
7160   *----------------------------------------------------------------------*
7161   *  -->  p1        text
7162   *  <--  p2        text
7163   *----------------------------------------------------------------------*
7164    FORM GET_NEXTSRNO_SPR.
7165      DATA : G_120ITAB TYPE TABLE OF T_TABLCTRL120.
7166   *  Data:  l_itab120 type table of t_tablctrl120.
7167      REFRESH G_120ITAB.
7168      APPEND LINES OF G_TABLCTRL120_ITAB TO G_120ITAB.
7169      SORT G_120ITAB BY SRNO DESCENDING.
7170      READ TABLE G_120ITAB INTO L_ITAB120 INDEX 1.
7171      L_SRNO = L_ITAB120-SRNO + 1.
7172    ENDFORM.                    " get_nextsrno_spr
7173   *&---------------------------------------------------------------------*
7174   *&      Form  get_nextsrno_sto
7175   *&---------------------------------------------------------------------*
7176   *       text
7177   *----------------------------------------------------------------------*
7178   *  -->  p1        text
7179   *  <--  p2        text
7180   *----------------------------------------------------------------------*
7181    FORM GET_NEXTSRNO_STO.
7182      DATA : G_110ITAB TYPE TABLE OF T_TABCTRL110.
7183      DATA : L_110ITAB TYPE T_TABCTRL110.
7184      CLEAR L_110ITAB.
7185      REFRESH G_110ITAB.
7186
7187      APPEND LINES OF G_TABCTRL110_ITAB TO G_110ITAB.
7188      SORT G_110ITAB BY SRNO DESCENDING.
7189      READ TABLE G_110ITAB INTO L_110ITAB INDEX 1.
7190      L_SRNO = L_110ITAB-SRNO + 1.
7191
7192    ENDFORM.                    " get_nextsrno_sto
7193   *&---------------------------------------------------------------------*
7194   *&      Form  get_cursor120
7195   *&---------------------------------------------------------------------*
7196   *       text
7197   *----------------------------------------------------------------------*
7198   *  -->  p1        text
7199   *  <--  p2        text
7200   *----------------------------------------------------------------------*
7201    FORM GET_CURSOR120.
7202
7203      GET CURSOR LINE G_CURSOR_LINE.
7204      G_CURR_LINE = G_CURSOR_LINE.
7205      G_CURR_LINE = TABLCTRL120-TOP_LINE + G_CURSOR_LINE - 1.
7206      G_CURR_LINE_120 = G_CURR_LINE .
7207
7208    ENDFORM.                    " get_cursor120
7209   *&---------------------------------------------------------------------*
7210   *&      Form  alphanum
7211   *&---------------------------------------------------------------------*
7212   *       text
7213   *----------------------------------------------------------------------*
7214   *  -->  p1        text
7215   *  <--  p2        text
7216   *----------------------------------------------------------------------*
7217    FORM ALPHANUM.
7218      G_LINENO = '1'.
7219      IF CHECK_FLAG = 'X'.
7220        EXIT.
7221      ENDIF.
7222      CHECK_FLAG = 'X'.
7223      DATA : L_NUM TYPE I.
7224      DO 10 TIMES.
7225        WA_ALPHANUM = L_NUM.
7226        APPEND WA_ALPHANUM TO IST_ALPHANUM.
7227        L_NUM = L_NUM + 1.
7228      ENDDO.
7229      CLEAR L_NUM.
7230      DO 26 TIMES.
7231        WA_ALPHANUM = ALPHA+L_NUM(1).
7232   *translate wa_alphanum to upper case.
7233        APPEND WA_ALPHANUM TO IST_ALPHANUM.
7234        L_NUM = L_NUM + 1.
7235      ENDDO.
7236
7237    ENDFORM.                    " alphanum
7238   *&---------------------------------------------------------------------*
7239   *&      Form  get_nextsrno_cap
7240   *&---------------------------------------------------------------------*
7241   *       text
7242   *----------------------------------------------------------------------*
7243   *  -->  p1        text
7244   *  <--  p2        text
7245   *----------------------------------------------------------------------*
7246    FORM GET_NEXTSRNO_CAP.
7247      DATA : G_130ITAB TYPE TABLE OF T_TABLCTRL130.
7248   *
7249      REFRESH G_130ITAB.
7250      APPEND LINES OF G_TABLCTRL130_ITAB TO G_130ITAB.
7251      SORT G_130ITAB BY SRNO DESCENDING.
7252      READ TABLE G_130ITAB INTO L_ITAB130 INDEX 1.
7253      L_SRNO = L_ITAB130-SRNO + 1.
7254
7255    ENDFORM.                    " get_nextsrno_cap
7256   *&---------------------------------------------------------------------*
7257   *&      Form  get_mat_find
7258   *&---------------------------------------------------------------------*
7259   *       text
7260   *----------------------------------------------------------------------*
7261   *  -->  p1        text
7262   *  <--  p2        text
7263   *----------------------------------------------------------------------*
7264    FORM GET_MAT_FIND.
7265
7266      IF FIELD1 = 'ZMM_CDITEM-PARTNO' .
7267
7268        G_MATTY1 = ZMM_CDHD_ST-MTART.
7269
7270        PERFORM CHANGE_PARTNO CHANGING G_PARTNO G_PARTNOC.
7271        CLEAR : DESC11, DESC22 ,DESC33 , DESC44.
7272        PERFORM SELECT_HELP_DATA USING
7273                      G_PARTNO
7274                      DESC11
7275                      DESC22
7276                      DESC33
7277                      DESC44
7278   *{   INSERT         OCPK900087                                        1
7279   *STEUC
7280   *}   INSERT
7281                      DESC55
7282                      G_MATGP
7283                      G_MATTY1
7284                   CHANGING SEL_FLAG.
7285      ENDIF.
7286
7287      DESCRIBE TABLE IST_SRCHLP LINES G_MAT_FND.
7288
7289      READ TABLE G_TABLCTRL120_ITAB INTO G_TABLCTRL120_WA INDEX
7290   G_LINENO.
7291
7292      G_TABLCTRL120_WA-MAT_FND = G_MAT_FND .
7293
7294      MODIFY G_TABLCTRL120_ITAB FROM G_TABLCTRL120_WA INDEX G_LINENO.
7295
7296      CLEAR G_MATTY1.
7297
7298    ENDFORM.                    " get_mat_find
7299   *&---------------------------------------------------------------------*
7300   *&      Form  validate_capcode
7301   *&---------------------------------------------------------------------*
7302   *       text
7303   *----------------------------------------------------------------------*
7304   *  -->  p1        text
7305   *  <--  p2        text
7306   *----------------------------------------------------------------------*
7307    FORM VALIDATE_CAPCODE.
7308
7309      DATA : L_CAPCODE LIKE MARA-MATNR.
7310   *
7311      IF NOT ZMM_CDITEM-CAP_CODE IS INITIAL.
7312
7313        SELECT * FROM CABN UP TO 1 ROWS
7314    WHERE ATNAM = 'Z_ONGC_GROUP_OF_SPARES'
7315    ORDER BY PRIMARY KEY .
7316    ENDSELECT.
7317
7318        SELECT SINGLE A~MATNR INTO L_CAPCODE
7319                            FROM MARA AS A  INNER JOIN AUSP AS B
7320                            ON A~MATNR = B~OBJEK
7321                            WHERE B~ATINN = CABN-ATINN AND
7322                            B~ATWRT <> '' AND
7323                            A~MATNR = ZMM_CDITEM-CAP_CODE.
7324
7325        IF SY-SUBRC <> 0.
7326          MESSAGE E067(ZMM_OTH).
7327        ENDIF.
7328
7329      ENDIF.
7330
7331    ENDFORM.                    " validate_capcode
7332   *&---------------------------------------------------------------------*
7333   *&      Form  check_morethanonegrp
7334   *&---------------------------------------------------------------------*
7335   *       text
7336   *----------------------------------------------------------------------*
7337   *  -->  p1        text
7338   *  <--  p2        text
7339   *----------------------------------------------------------------------*
7340    FORM CHECK_MORETHANONEGRP.
7341      DATA : BEGIN OF L_MATGP_ITAB OCCURS 0,
7342             MATGP LIKE ZMM_CDITEM-MATGP,
7343            END   OF L_MATGP_ITAB.
7344
7345      CLEAR: G_GRPCOUNT,G_CODUSER.
7346      REFRESH L_MATGP_ITAB.
7347
7348      SELECT MATGP INTO TABLE L_MATGP_ITAB
7349             FROM ZMM_CDITEM
7350             WHERE REQNO = ZMM_CDHD_ST-REQNO.
7351      SORT L_MATGP_ITAB ASCENDING BY MATGP.
7352      DELETE ADJACENT DUPLICATES FROM L_MATGP_ITAB.
7353      DESCRIBE TABLE L_MATGP_ITAB LINES G_GRPCOUNT.
7354
7355      SELECT SINGLE * FROM ZMM_CDCODIFIER
7356           WHERE CODIFIER = SY-UNAME
7357           AND   MATGP    = ''
7358           AND   STATUS   = 'A'.
7359      IF SY-SUBRC = 0.
7360        G_CODUSER = 'A'.
7361      ENDIF.
7362    ENDFORM.                    " check_morethanonegrp
7363
7364   *&---------------------------------------------------------------------*
7365   *&      Form  GET_PARNO
7366   *&---------------------------------------------------------------------*
7367   *       text
7368   *----------------------------------------------------------------------*
7369   *  -->  p1        text
7370   *  <--  p2        text
7371   *----------------------------------------------------------------------*
7372    FORM GET_PARNO.
7373      SELECT * FROM ZMM_MODIFIER UP TO 1 ROWS
7374    WHERE DESC1 = G_TABCTRL110_WA-DESC1
7375    AND MATGRP = G_TABCTRL110_WA-MATGP
7376    ORDER BY PRIMARY KEY .
7377    ENDSELECT.
7378      IF SY-SUBRC <> 0.
7379        G_PARNO = '1'.
7380      ELSE.
7381        IF  ZMM_MODIFIER-DESC2 IS INITIAL.
7382          G_PARNO = '1'.
7383        ELSEIF  ZMM_MODIFIER-DESC3 IS INITIAL.
7384          G_PARNO = '2'.
7385        ELSEIF  ZMM_MODIFIER-DESC4 IS INITIAL.
7386          G_PARNO = '3'.
7387        ELSE.
7388          G_PARNO = '4'.
7389        ENDIF.
7390      ENDIF.
7391    ENDFORM.                    " GET_PARNO
7392   *&---------------------------------------------------------------------*
7393   *&      Form  set_addnl_desc
7394   *&---------------------------------------------------------------------*
7395   *       text
7396   *----------------------------------------------------------------------*
7397   *  -->  p1        text
7398   *  <--  p2        text
7399   *----------------------------------------------------------------------*
7400    FORM SET_ADDNL_DESC.
7401
7402      IF SY-TCODE <> 'ZCODG'.
7403        LOOP AT SCREEN.
7404          IF SCREEN-NAME = 'G_DESC1'     OR
7405             SCREEN-NAME = 'G_DESC2'     OR
7406             SCREEN-NAME = 'G_DESC3'     OR
7407             SCREEN-NAME = 'G_DESC4'     OR
7408             SCREEN-NAME = 'G_MATGP'.
7409            SCREEN-INPUT = 0.
7410            MODIFY SCREEN.
7411          ELSEIF SCREEN-NAME = 'G_USER_DESC' AND USER_DESC_LEN > 0.
7412            SCREEN-LENGTH = USER_DESC_LEN.
7413            SCREEN-INPUT = 1.
7414            MODIFY SCREEN.
7415          ENDIF.
7416          IF G_PARNO = 3 AND SCREEN-NAME = 'G_DESC4'.
7417            SCREEN-INPUT = 0.
7418            MODIFY SCREEN.
7419          ENDIF.
7420          IF G_PARNO = 2 AND ( SCREEN-NAME = 'G_DESC3' OR
7421                               SCREEN-NAME = 'G_DESC4' ).
7422            SCREEN-INPUT = 0.
7423            MODIFY SCREEN.
7424          ENDIF.
7425
7426        ENDLOOP.
7427      ENDIF.
7428    ENDFORM.                    " set_addnl_desc
7429   *&---------------------------------------------------------------------*
7430   *&      Form  check_length
7431   *&---------------------------------------------------------------------*
7432   *       text
7433   *----------------------------------------------------------------------*
7434   *  -->  p1        text
7435   *  <--  p2        text
7436   *----------------------------------------------------------------------*
7437    FORM CHECK_LENGTH.
7438      DATA L_TOTAL_LEN TYPE I.
7439      DATA G_DESC_FIN(150).
7440   *   if sy-tcode = 'ZCODG'.
7441      CONCATENATE G_DESC1 G_DESC2
7442      G_DESC3
7443      G_DESC4 G_USER_DESC INTO G_DESC_FIN
7444     SEPARATED BY SPACE.
7445      CONDENSE G_DESC_FIN.
7446      L_TOTAL_LEN = STRLEN( G_DESC_FIN ).
7447      IF L_TOTAL_LEN > 87.
7448        G_LEN_EX87 = 'X'.
7449        MESSAGE I063(ZMM_OTH).
7450        LEAVE TO SCREEN 115.
7451      ENDIF.
7452   *   Endif.
7453
7454    ENDFORM.                    " check_length
7455   *&---------------------------------------------------------------------*
7456   *&      Form  get_attrib_115
7457   *&---------------------------------------------------------------------*
7458   *       text
7459   *----------------------------------------------------------------------*
7460   *  -->  p1        text
7461   *  <--  p2        text
7462   *----------------------------------------------------------------------*
7463    FORM GET_ATTRIB_115.
7464      DATA : L_DESC1_ATTRIB , L_DESC2_ATTRIB, L_DESC3_ATTRIB, L_DESC4_ATTRIB,
7465                        L_ADESC_ATTRIB.
7466      LOOP AT SCREEN.
7467        IF SCREEN-INPUT = 0 AND SCREEN-NAME = 'G_DESC1'.
7468          L_DESC1_ATTRIB = 'X'.
7469        ELSEIF  SCREEN-INPUT = 0 AND SCREEN-NAME = 'G_DESC2'.
7470          L_DESC2_ATTRIB = 'X'.
7471        ELSEIF  SCREEN-INPUT = 0 AND SCREEN-NAME = 'G_DESC3'.
7472          L_DESC3_ATTRIB = 'X'.
7473        ELSEIF  SCREEN-INPUT = 0 AND SCREEN-NAME = 'G_DESC4'.
7474          L_DESC4_ATTRIB = 'X'.
7475        ELSEIF  SCREEN-INPUT = 0 AND SCREEN-NAME = 'A_DESC'.
7476          L_ADESC_ATTRIB = 'X'.
7477        ENDIF.
7478      ENDLOOP.
7479
7480    ENDFORM.                    " get_attrib_115
7481   *&---------------------------------------------------------------------*
7482   *&      Form  get_parno1
7483   *&---------------------------------------------------------------------*
7484   *       text
7485   *----------------------------------------------------------------------*
7486   *  -->  p1        text
7487   *  <--  p2        text
7488   *----------------------------------------------------------------------*
7489    FORM GET_PARNO1.
7490      READ TABLE G_TABCTRL110_ITAB INTO G_TABCTRL110_WA INDEX
7491      G_CURR_LINE_110.
7492      IF SY-SUBRC = 0.
7493
7494        SELECT * FROM ZMM_MODIFIER UP TO 1 ROWS
7495    WHERE DESC1 =
7496    G_TABCTRL110_WA-DESC1 AND MATGRP = G_TABCTRL110_WA-MATGP
7497    ORDER BY PRIMARY KEY .
7498    ENDSELECT.
7499        IF SY-SUBRC <> 0.
7500          G_PARNO = '1'.
7501        ELSE.
7502          IF  ZMM_MODIFIER-DESC2 IS INITIAL.
7503            G_PARNO = '1'.
7504          ELSEIF  ZMM_MODIFIER-DESC3 IS INITIAL.
7505            G_PARNO = '2'.
7506          ELSEIF  ZMM_MODIFIER-DESC4 IS INITIAL.
7507            G_PARNO = '3'.
7508          ELSE.
7509            G_PARNO = '4'.
7510          ENDIF.
7511        ENDIF.
7512      ENDIF.
7513    ENDFORM.                    " get_parno1
7514   *&---------------------------------------------------------------------*
7515   *&      Form  chaby_chadt
7516   *&---------------------------------------------------------------------*
7517   *       text
7518   *----------------------------------------------------------------------*
7519   *  -->  p1        text
7520   *  <--  p2        text
7521   *----------------------------------------------------------------------*
7522    FORM CHABY_CHADT.
7523      IF G_MODE = 'APR'.
7524        IF G_USER = 'M'.
7525          IF WA_ZMM_CDITEM-REJ_FLG = 'RM'.
7526            MOVE SY-DATUM TO WA_ZMM_CDITEM-CODDT.
7527            MOVE SY-UNAME TO WA_ZMM_CDITEM-CODBY.
7528          ELSE.
7529            MOVE G_CDITEM-CODDT TO WA_ZMM_CDITEM-CODDT.
7530            MOVE G_CDITEM-CODBY TO WA_ZMM_CDITEM-CODBY.
7531          ENDIF.
7532        ELSEIF G_USER = 'L'.
7533          IF WA_ZMM_CDITEM-REJ_FLG = 'RT'.
7534            MOVE SY-DATUM TO WA_ZMM_CDITEM-CODDT.
7535            MOVE SY-UNAME TO WA_ZMM_CDITEM-CODBY.
7536          ELSE.
7537            MOVE G_CDITEM-CODDT TO WA_ZMM_CDITEM-CODDT.
7538            MOVE G_CDITEM-CODBY TO WA_ZMM_CDITEM-CODBY.
7539          ENDIF.
7540        ENDIF.
7541      ENDIF.
7542      IF G_MODE <> 'APR'.
7543        IF SY-TCODE <> 'ZCODG'.
7544          MOVE SY-DATUM TO WA_ZMM_CDITEM-CODDT.
7545          MOVE SY-UNAME TO WA_ZMM_CDITEM-CODBY.
7546        ENDIF.
7547      ENDIF.
7548    ENDFORM.                    " chaby_chadt
7549   *&---------------------------------------------------------------------*
7550   *&      Form  Check_dupl_rec
7551   *&---------------------------------------------------------------------*
7552   *       text
7553   *----------------------------------------------------------------------*
7554   *  -->  p1        text
7555   *  <--  p2        text
7556   *----------------------------------------------------------------------*
7557    FORM CHECK_DUPL_REC.
7558      DATA:L_110 TYPE TABLE OF T_TABCTRL110,
7559           L_120 TYPE TABLE OF T_TABLCTRL120,
7560           L_130 TYPE TABLE OF T_TABLCTRL130,
7561           L_140 TYPE TABLE OF T_TABLCTRL140,
7562           L_CDITEM   LIKE  ZMM_CDITEM.
7563      CLEAR: L_110 ,L_120,L_130,L_140,G_DESC_FIN.
7564      REFRESH: L_110,L_120,L_130,L_140.
7565   **Addition-Duplicate Check*******************=
7566      .
7567      IF G_MODE = 'CHA' OR G_MODE = 'CRE'.
7568
7569        CASE ZMM_CDHD_ST-MTART.
7570          WHEN 'ZSTO'.
7571            IF G_MODE = 'CRE'.
7572              SELECT * INTO L_CDITEM FROM ZMM_CDITEM UP TO 1 ROWS
7573    WHERE DESC_FIN = G_TABCTRL110_WA-DESC_FIN AND UOM = G_TABCTRL110_WA-UOM
7574    ORDER BY PRIMARY KEY .
7575    ENDSELECT.
7576              IF SY-SUBRC = 0.
7577                G_DUPLICATE_REC = 'X'.
7578                MESSAGE I074(ZMM_OTH) WITH L_CDITEM-REQNO
7579                                   G_TABCTRL110_WA-SRNO .
7580              ENDIF.
7581            ELSEIF G_MODE = 'CHA'.
7582              SELECT * INTO L_CDITEM FROM ZMM_CDITEM UP TO 1 ROWS
7583    WHERE DESC_FIN = G_TABCTRL110_WA-DESC_FIN AND UOM = G_TABCTRL110_WA-UOM AND REQNO <> ZMM_CDHD_ST-REQNO
7584    ORDER BY PRIMARY KEY .
7585    ENDSELECT.
7586              IF SY-SUBRC = 0.
7587                G_DUPLICATE_REC = 'X'.
7588                MESSAGE I074(ZMM_OTH) WITH L_CDITEM-REQNO
7589                                    G_TABCTRL110_WA-SRNO .
7590              ENDIF.
7591            ENDIF.
7592            APPEND LINES OF G_TABCTRL110_ITAB TO L_110.
7593            SORT L_110 BY DESC_FIN ASCENDING.
7594            DELETE ADJACENT DUPLICATES FROM L_110 COMPARING DESC_FIN UOM.
7595            IF SY-SUBRC = 0.
7596              MESSAGE I072(ZMM_OTH).
7597              IF OKCODE_100 = 'SAV'.
7598                CLEAR OKCODE_100.
7599              ENDIF.
7600            ENDIF.
7601          WHEN 'ZSPR'.
7602            SELECT * INTO L_CDITEM FROM ZMM_CDITEM UP TO 1 ROWS
7603    WHERE PARTNO = G_TABLCTRL120_WA-PARTNO AND DESC_FIN = G_TABLCTRL120_WA-DESC_FIN AND UOM = G_TABLCTRL120_WA-UOM AND CAP_CODE = G_TABLCTRL120_WA-CAP_CODE AND MDLNO = G_TABLCTRL120_WA-MDLNO AND MANU = G_TABLCTRL120_WA-MANU
7604    ORDER BY PRIMARY KEY .
7605    ENDSELECT.
7606            IF SY-SUBRC = 0.
7607              MESSAGE E074(ZMM_OTH) WITH L_CDITEM-REQNO.
7608            ENDIF.
7609
7610            APPEND LINES OF G_TABLCTRL120_ITAB TO L_120.
7611            SORT L_120 BY DESC_FIN ASCENDING.
7612            DELETE ADJACENT DUPLICATES FROM L_120
7613                   COMPARING PARTNO DESC_FIN UOM CAP_CODE MDLNO MANU.
7614            IF SY-SUBRC = 0.
7615              MESSAGE I072(ZMM_OTH).
7616              IF OKCODE_100 = 'SAV'.
7617                CLEAR OKCODE_100.
7618              ENDIF.
7619            ENDIF.
7620          WHEN 'ZCAP'.
7621            SELECT * INTO L_CDITEM FROM ZMM_CDITEM UP TO 1 ROWS
7622    WHERE DESC_FIN = G_TABLCTRL130_WA-DESC_FIN
7623    ORDER BY PRIMARY KEY .
7624    ENDSELECT.
7625
7626            IF SY-SUBRC = 0.
7627              MESSAGE E074(ZMM_OTH) WITH L_CDITEM-REQNO.
7628            ENDIF.
7629            APPEND LINES OF G_TABLCTRL130_ITAB TO L_130.
7630            SORT L_130 BY DESC_FIN ASCENDING.
7631            DELETE ADJACENT DUPLICATES FROM L_130 COMPARING DESC_FIN.
7632            IF SY-SUBRC = 0.
7633              MESSAGE I072(ZMM_OTH).
7634              IF OKCODE_100 = 'SAV'.
7635                CLEAR OKCODE_100.
7636              ENDIF.
7637            ENDIF.
7638          WHEN 'ZDIS'.
7639            APPEND LINES OF G_TABLCTRL140_ITAB TO L_140.
7640            SORT L_140 BY DESC_FIN ASCENDING.
7641            DELETE ADJACENT DUPLICATES FROM L_140 COMPARING DESC_FIN.
7642            IF SY-SUBRC = 0.
7643              MESSAGE I072(ZMM_OTH).
7644              IF OKCODE_100 = 'SAV'.
7645                CLEAR OKCODE_100.
7646              ENDIF.
7647            ENDIF.
7648        ENDCASE.
7649      ENDIF.
7650
7651    ENDFORM.                    " Check_dupl_rec
7652   *******************************************************************
7653    FORM CHECK_DUPL_REC1.
7654      DATA:L_110 TYPE TABLE OF T_TABCTRL110,
7655           L_120 TYPE TABLE OF T_TABLCTRL120,
7656           L_130 TYPE TABLE OF T_TABLCTRL130,
7657           L_140 TYPE TABLE OF T_TABLCTRL140,
7658           L_CDITEM   LIKE  ZMM_CDITEM.
7659      DATA :  L_CURR_SRNO TYPE N.
7660      CLEAR: L_110 ,L_120,L_130,L_140,G_DESC_FIN,L_CDITEM , G_CDITEM_ITAB.
7661      REFRESH: L_110,L_120,L_130,L_140, G_CDITEM_ITAB.
7662   **
7663      IF G_MODE = 'CHA' OR G_MODE = 'CRE'.
7664        CASE ZMM_CDHD_ST-MTART.
7665          WHEN 'ZSTO'.
7666   **Addition-Duplicate Check*for other request****
7667            LOOP AT G_TABCTRL110_ITAB INTO G_TABCTRL110_WA.
7668              IF G_MODE = 'CRE'.
7669                SELECT  REQNO SRNO DESC_FIN
7670                      APPENDING CORRESPONDING FIELDS OF
7671                      TABLE G_CDITEM_ITAB
7672                      FROM ZMM_CDITEM
7673                      WHERE DESC_FIN = G_TABCTRL110_WA-DESC_FIN
7674                      AND   UOM      = G_TABCTRL110_WA-UOM ORDER BY PRIMARY KEY.
7675              ELSEIF G_MODE = 'CHA'.
7676                SELECT  REQNO SRNO DESC_FIN
7677                      APPENDING CORRESPONDING FIELDS OF
7678                      TABLE G_CDITEM_ITAB
7679                      FROM ZMM_CDITEM
7680                      WHERE DESC_FIN = G_TABCTRL110_WA-DESC_FIN
7681                      AND   UOM      = G_TABCTRL110_WA-UOM
7682                      AND   REQNO    <> ZMM_CDHD_ST-REQNO ORDER BY PRIMARY KEY.
7683              ENDIF.
7684              LOOP AT G_CDITEM_ITAB INTO G_CDITEM.
7685                IF G_CDITEM-MAT_FND IS INITIAL.
7686   *****Mat_fnd is used as place holder for exsiting srno.
7687                  G_CDITEM-MAT_FND = G_TABCTRL110_WA-SRNO.
7688                  MODIFY G_CDITEM_ITAB FROM G_CDITEM
7689                                       INDEX SY-TABIX
7690                                       TRANSPORTING MAT_FND.
7691                ENDIF.
7692              ENDLOOP.
7693            ENDLOOP.
7694            IF NOT G_CDITEM_ITAB IS INITIAL.
7695              G_DUPLICATE_REC = 'X'.
7696              CALL SCREEN 102.
7697            ENDIF.
7698   ****Duplicate check for same request
7699            APPEND LINES OF G_TABCTRL110_ITAB TO L_110.
7700            SORT L_110 BY DESC_FIN ASCENDING.
7701            DELETE ADJACENT DUPLICATES FROM L_110 COMPARING DESC_FIN UOM.
7702            IF SY-SUBRC = 0.
7703              MESSAGE I072(ZMM_OTH).
7704              IF OKCODE_100 = 'SAV'.
7705                CLEAR OKCODE_100.
7706              ENDIF.
7707            ENDIF.
7708          WHEN 'ZSPR'.
7709   ****Duplicate entry check in other requests.
7710            LOOP AT G_TABLCTRL120_ITAB INTO G_TABLCTRL120_WA.
7711              IF G_MODE = 'CRE'.
7712                SELECT  REQNO SRNO DESC_FIN
7713                  APPENDING CORRESPONDING FIELDS OF
7714                  TABLE G_CDITEM_ITAB
7715                  FROM ZMM_CDITEM
7716                  WHERE PARTNO   = G_TABLCTRL120_WA-PARTNO
7717                  AND   DESC_FIN = G_TABLCTRL120_WA-DESC_FIN
7718                  AND   UOM      = G_TABLCTRL120_WA-UOM
7719                  AND   CAP_CODE = G_TABLCTRL120_WA-CAP_CODE
7720                  AND   MDLNO    = G_TABLCTRL120_WA-MDLNO
7721                  AND   MANU     = G_TABLCTRL120_WA-MANU.
7722              ELSEIF G_MODE = 'CHA'.
7723                SELECT  REQNO SRNO DESC_FIN
7724                  APPENDING CORRESPONDING FIELDS OF
7725                  TABLE G_CDITEM_ITAB
7726                  FROM ZMM_CDITEM
7727                  WHERE PARTNO   = G_TABLCTRL120_WA-PARTNO
7728                  AND   DESC_FIN = G_TABLCTRL120_WA-DESC_FIN
7729                  AND   UOM      = G_TABLCTRL120_WA-UOM
7730                  AND   CAP_CODE = G_TABLCTRL120_WA-CAP_CODE
7731                  AND   MDLNO    = G_TABLCTRL120_WA-MDLNO
7732                  AND   MANU     = G_TABLCTRL120_WA-MANU
7733                  AND   REQNO    <> ZMM_CDHD_ST-REQNO.
7734              ENDIF.
7735              LOOP AT G_CDITEM_ITAB INTO G_CDITEM.
7736                IF G_CDITEM-MAT_FND IS INITIAL.
7737   *****Mat_fnd is used as place holder for exsiting srno.
7738                  G_CDITEM-MAT_FND = G_TABLCTRL120_WA-SRNO.
7739                  MODIFY G_CDITEM_ITAB FROM G_CDITEM
7740                                       INDEX SY-TABIX
7741                                       TRANSPORTING MAT_FND.
7742                ENDIF.
7743              ENDLOOP.
7744            ENDLOOP.
7745            IF NOT G_CDITEM_ITAB IS INITIAL.
7746              G_DUPLICATE_REC = 'X'.
7747              CALL SCREEN 102.
7748            ENDIF.
7749   ******Duplicate entry check in the same request.
7750            APPEND LINES OF G_TABLCTRL120_ITAB TO L_120.
7751            SORT L_120 BY DESC_FIN ASCENDING.
7752            DELETE ADJACENT DUPLICATES FROM L_120
7753                   COMPARING PARTNO DESC_FIN UOM CAP_CODE MDLNO MANU.
7754            IF SY-SUBRC = 0.
7755              MESSAGE I072(ZMM_OTH).
7756              IF OKCODE_100 = 'SAV'.
7757                CLEAR OKCODE_100.
7758              ENDIF.
7759            ENDIF.
7760          WHEN 'ZCAP'.
7761   ****Duplicate entry check in other requests.
7762            LOOP AT G_TABLCTRL130_ITAB INTO G_TABLCTRL130_WA.
7763              IF G_MODE = 'CRE'.
7764                SELECT  REQNO SRNO DESC_FIN
7765                  APPENDING CORRESPONDING FIELDS OF
7766                  TABLE G_CDITEM_ITAB
7767                  FROM ZMM_CDITEM
7768                  WHERE DESC_FIN = G_TABLCTRL130_WA-DESC_FIN.
7769              ELSEIF G_MODE = 'CHA'.
7770                SELECT  REQNO SRNO DESC_FIN
7771                  APPENDING CORRESPONDING FIELDS OF
7772                  TABLE G_CDITEM_ITAB
7773                  FROM ZMM_CDITEM
7774                  WHERE DESC_FIN = G_TABLCTRL130_WA-DESC_FIN
7775                  AND   REQNO    <> ZMM_CDHD_ST-REQNO.
7776              ENDIF.
7777              LOOP AT G_CDITEM_ITAB INTO G_CDITEM.
7778                IF G_CDITEM-MAT_FND IS INITIAL.
7779   *****Mat_fnd is used as place holder for exsiting srno.
7780                  G_CDITEM-MAT_FND = G_TABLCTRL130_WA-SRNO.
7781                  MODIFY G_CDITEM_ITAB FROM G_CDITEM
7782                                       INDEX SY-TABIX
7783                                       TRANSPORTING MAT_FND.
7784                ENDIF.
7785              ENDLOOP.
7786            ENDLOOP.
7787            IF NOT G_CDITEM_ITAB IS INITIAL.
7788              G_DUPLICATE_REC = 'X'.
7789              CALL SCREEN 102.
7790            ENDIF.
7791   ******Duplicate entry check in the same request.
7792            APPEND LINES OF G_TABLCTRL130_ITAB TO L_130.
7793            SORT L_130 BY DESC_FIN ASCENDING.
7794            DELETE ADJACENT DUPLICATES FROM L_130 COMPARING DESC_FIN.
7795            IF SY-SUBRC = 0.
7796              MESSAGE I072(ZMM_OTH).
7797              IF OKCODE_100 = 'SAV'.
7798                CLEAR OKCODE_100.
7799              ENDIF.
7800            ENDIF.
7801          WHEN 'ZDIS'.
7802            APPEND LINES OF G_TABLCTRL140_ITAB TO L_140.
7803            SORT L_140 BY DESC_FIN ASCENDING.
7804            DELETE ADJACENT DUPLICATES FROM L_140 COMPARING DESC_FIN.
7805            IF SY-SUBRC = 0.
7806              MESSAGE I072(ZMM_OTH).
7807              IF OKCODE_100 = 'SAV'.
7808                CLEAR OKCODE_100.
7809              ENDIF.
7810            ENDIF.
7811        ENDCASE.
7812      ENDIF.
7813
7814    ENDFORM.                    " Check_dupl_rec1
7815   *&---------------------------------------------------------------------*
7816   *&      Form  set_g_user
7817   *&---------------------------------------------------------------------*
7818   *       text
7819   *----------------------------------------------------------------------*
7820   *  -->  p1        text
7821   *  <--  p2        text
7822   *----------------------------------------------------------------------*
7823    FORM SET_G_USER.
7824      IF ZMM_CDHD_ST-APPROVE_MRP = 'X'.
7825        G_USER = 'L'.
7826      ELSE.
7827        G_USER = 'M'.
7828      ENDIF.
7829    ENDFORM.                    " set_g_user
7830   *&---------------------------------------------------------------------*
7831   *&      Form  get_noofhits
7832   *&---------------------------------------------------------------------*
7833   *       text
7834   *----------------------------------------------------------------------*
7835   *  -->  p1        text
7836   *  <--  p2        text
7837   *----------------------------------------------------------------------*
7838    FORM GET_NOOFHITS.
7839      DATA : G_PARTNO11 LIKE ZMM_CDITEM-USER_DESC.
7840      DATA : G_PARTNO22 LIKE ZMM_CDITEM-USER_DESC.
7841
7842      DATA : L_LEN11 TYPE I,
7843             L_LEN22 TYPE I.
7844      REFRESH :IST_SRCHLP.
7845   ************
7846      CASE ZMM_CDHD_ST-MTART.
7847        WHEN 'ZSPR'.
7848          G_PARTNOC = G_TABLCTRL120_WA-PARTNO.
7849
7850          PERFORM CHANGE_PARTNO CHANGING G_PARTNO G_PARTNOC.
7851
7852          SELECT A~MAKTG A~MATNR B~MFRNR B~MEINS B~MFRPN B~WRKST
7853                     INTO CORRESPONDING FIELDS OF TABLE IST_SRCHLP
7854                     FROM MAKT AS A JOIN MARA AS B
7855                     ON    A~MATNR = B~MATNR
7856                     WHERE B~MFRPN LIKE G_PARTNO
7857                     AND ( B~MTART = 'ZSPR' OR B~MTART = 'ZMPN' )
7858                     AND B~MSTAE = ''.
7859
7860          PERFORM CHANGE_PARTNO1 CHANGING G_PARTNO11 G_PARTNOC.
7861          L_LEN11 = STRLEN( G_PARTNO11 ).
7862
7863          LOOP AT IST_SRCHLP INTO WA_SRCHLP.
7864            PERFORM CHANGE_PARTNO2 CHANGING G_PARTNO22 WA_SRCHLP-MFRPN.
7865            L_LEN22 = STRLEN( G_PARTNO22 ).
7866            SEARCH G_PARTNO22 FOR G_PARTNO11.
7867            IF SY-SUBRC = 0 AND L_LEN11 = L_LEN22.
7868            ELSE.
7869              DELETE IST_SRCHLP.
7870            ENDIF.
7871          ENDLOOP.
7872
7873          DESCRIBE TABLE IST_SRCHLP LINES G_MAT_FND.
7874          G_TABLCTRL120_WA-MAT_FND = G_MAT_FND.
7875
7876        WHEN 'ZSTO'.
7877          IF G_TABCTRL110_WA-OTH1 = 'X'.
7878            G_TABCTRL110_WA-MAT_FND = 0.
7879          ELSEIF G_TABCTRL110_WA-OTH2 = 'X' AND
7880                 G_TABCTRL110_WA-OTH1 = ''.
7881            PERFORM GET_STO_HITCNT.
7882            DESCRIBE TABLE IST_SRCHLP LINES G_MAT_FND.
7883            G_TABCTRL110_WA-MAT_FND = G_MAT_FND.
7884          ELSEIF G_TABCTRL110_WA-OTH3 = 'X' AND
7885                 G_TABCTRL110_WA-OTH2 = ''  AND
7886                 G_TABCTRL110_WA-OTH1 = ''.
7887            PERFORM GET_STO_HITCNT.
7888            PERFORM GET_STO_HITCNT_DEL2.
7889            DESCRIBE TABLE IST_SRCHLP LINES G_MAT_FND.
7890            G_TABCTRL110_WA-MAT_FND = G_MAT_FND.
7891          ELSEIF G_TABCTRL110_WA-OTH4 = 'X' AND
7892                 G_TABCTRL110_WA-OTH3 = ''  AND
7893                 G_TABCTRL110_WA-OTH2 = ''  AND
7894                 G_TABCTRL110_WA-OTH1 = ''.
7895            PERFORM GET_STO_HITCNT.
7896            PERFORM GET_STO_HITCNT_DEL23.
7897            DESCRIBE TABLE IST_SRCHLP LINES G_MAT_FND.
7898            G_TABCTRL110_WA-MAT_FND = G_MAT_FND.
7899          ELSEIF G_TABCTRL110_WA-OTH4 = ''  AND
7900                 G_TABCTRL110_WA-OTH3 = ''  AND
7901                 G_TABCTRL110_WA-OTH2 = ''  AND
7902                 G_TABCTRL110_WA-OTH1 = ''.
7903            PERFORM GET_STO_HITCNT.
7904            PERFORM GET_STO_HITCNT_DEL234.
7905            DESCRIBE TABLE IST_SRCHLP LINES G_MAT_FND.
7906            G_TABCTRL110_WA-MAT_FND = G_MAT_FND.
7907          ENDIF.
7908
7909        WHEN 'ZCAP'.
7910
7911          PERFORM GET_CAP_HITCNT.
7912          DESCRIBE TABLE IST_SRCHLP LINES G_MAT_FND.
7913   *       break cab_subodhk.
7914          G_TABLCTRL130_WA-MAT_FND = G_MAT_FND.
7915      ENDCASE.
7916    ENDFORM.                    " get_noofhits
7917   *&---------------------------------------------------------------------*
7918   *&      Form  get_sto_hitcnt
7919   *&---------------------------------------------------------------------*
7920   *       text
7921   *----------------------------------------------------------------------*
7922   *  -->  p1        text
7923   *  <--  p2        text
7924   *----------------------------------------------------------------------*
7925    FORM GET_STO_HITCNT.
7926      DATA:  L_LEN3  TYPE I,
7927             L_SRNO3 TYPE I,
7928             L_CHECK3 .
7929
7930      REFRESH IST_SRCHLP.
7931      CONCATENATE '%' G_TABCTRL110_WA-DESC1 '%' INTO DESC.
7932      SELECT A~MAKTG A~MATNR B~MEINS B~MFRPN B~WRKST
7933          INTO CORRESPONDING FIELDS OF TABLE IST_SRCHLP
7934          FROM MAKT AS A
7935          JOIN MARA AS B
7936          ON A~MATNR = B~MATNR
7937          WHERE ( A~MAKTG LIKE DESC OR B~WRKST <> '' )
7938                AND B~MTART = 'ZSTO'
7939                AND B~MSTAE = ''.
7940
7941      LOOP AT IST_SRCHLP INTO WA_SRCHLP.
7942        L_LEN3 = STRLEN( WA_SRCHLP-MAKTG ).
7943        L_LEN3 = L_LEN3 - 1.
7944        L_CHECK3 = WA_SRCHLP-MAKTG+L_LEN3(1).
7945        IF L_CHECK3 = '*'.
7946          CONCATENATE WA_SRCHLP-MAKTG+0(L_LEN3) WA_SRCHLP-WRKST INTO
7947          WA_SRCHLP-MAKTX.
7948        ELSE.
7949          MOVE WA_SRCHLP-MAKTG TO WA_SRCHLP-MAKTX.
7950        ENDIF.
7951        TRANSLATE WA_SRCHLP-MAKTX TO UPPER CASE.
7952        IF NOT DESC11 IS INITIAL.
7953          SEARCH WA_SRCHLP-MAKTX FOR DESC11.
7954          IF SY-SUBRC <> 0.
7955            DELETE IST_SRCHLP.
7956          ENDIF.
7957        ENDIF.
7958      ENDLOOP.
7959
7960    ENDFORM.                    " get_sto_hitcnt
7961   *&---------------------------------------------------------------------*
7962   *&      Form  get_sto_hitcnt_del234
7963   *&---------------------------------------------------------------------*
7964   *       text
7965   *----------------------------------------------------------------------*
7966   *  -->  p1        text
7967   *  <--  p2        text
7968   *----------------------------------------------------------------------*
7969    FORM GET_STO_HITCNT_DEL234.
7970
7971      DATA: L4_LEN TYPE I,
7972            L4_CHECK TYPE C.
7973
7974   *  if not g_tabctrl110_wa-desc2 is initial.
7975   *     loop at ist_srchlp into wa_srchlp.
7976   *       move wa_srchlp-maktg to wa_srchlp-maktx.
7977   *       TRANSLATE g_tabctrl110_wa-desc2 to upper case.
7978   *       search wa_srchlp-maktx for g_tabctrl110_wa-desc2.
7979   *       if sy-subrc <> 0.
7980   *         delete ist_srchlp .
7981   *       endif.
7982   *     endloop.
7983   *  endif.
7984   *  if not g_tabctrl110_wa-desc3 is initial.
7985   *     loop at ist_srchlp into wa_srchlp.
7986   *       move wa_srchlp-maktg to wa_srchlp-maktx.
7987   *       TRANSLATE g_tabctrl110_wa-desc3 to upper case.
7988   *       search wa_srchlp-maktx for g_tabctrl110_wa-desc3.
7989   *       if sy-subrc <> 0.
7990   *         delete ist_srchlp .
7991   *       endif.
7992   *     endloop.
7993   *   endif.
7994      PERFORM GET_STO_HITCNT_DEL23.
7995      IF NOT G_TABCTRL110_WA-DESC4 IS INITIAL.
7996        LOOP AT IST_SRCHLP INTO WA_SRCHLP.
7997          L4_LEN = STRLEN( WA_SRCHLP-MAKTG ).
7998          L4_LEN = L4_LEN - 1.
7999          L4_CHECK = WA_SRCHLP-MAKTG+L4_LEN(1).
8000          IF L4_CHECK = '*'.
8001            CONCATENATE WA_SRCHLP-MAKTG+0(L4_LEN) WA_SRCHLP-WRKST INTO
8002            WA_SRCHLP-MAKTX.
8003          ELSE.
8004            MOVE WA_SRCHLP-MAKTG TO WA_SRCHLP-MAKTX.
8005          ENDIF.
8006          TRANSLATE G_TABCTRL110_WA-DESC4 TO UPPER CASE.
8007          SEARCH WA_SRCHLP-MAKTX FOR G_TABCTRL110_WA-DESC4.
8008          IF SY-SUBRC <> 0.
8009            DELETE IST_SRCHLP .
8010          ENDIF.
8011        ENDLOOP.
8012      ENDIF.
8013    ENDFORM.                    " get_sto_hitcnt_del234
8014   *&---------------------------------------------------------------------*
8015   *&      Form  get_sto_hitcnt_del2
8016   *&---------------------------------------------------------------------*
8017   *       text
8018   *----------------------------------------------------------------------*
8019   *  -->  p1        text
8020   *  <--  p2        text
8021   *----------------------------------------------------------------------*
8022    FORM GET_STO_HITCNT_DEL2.
8023      DATA: L2_LEN TYPE I,
8024            L2_CHECK TYPE C.
8025
8026      IF NOT G_TABCTRL110_WA-DESC2 IS INITIAL.
8027        LOOP AT IST_SRCHLP INTO WA_SRCHLP.
8028          L2_LEN = STRLEN( WA_SRCHLP-MAKTG ).
8029          L2_LEN = L2_LEN - 1.
8030          L2_CHECK = WA_SRCHLP-MAKTG+L2_LEN(1).
8031          IF L2_CHECK = '*'.
8032            CONCATENATE WA_SRCHLP-MAKTG+0(L2_LEN) WA_SRCHLP-WRKST INTO
8033            WA_SRCHLP-MAKTX.
8034          ELSE.
8035            MOVE WA_SRCHLP-MAKTG TO WA_SRCHLP-MAKTX.
8036          ENDIF.
8037          TRANSLATE G_TABCTRL110_WA-DESC2 TO UPPER CASE.
8038          SEARCH WA_SRCHLP-MAKTX FOR G_TABCTRL110_WA-DESC2.
8039          IF SY-SUBRC <> 0.
8040            DELETE IST_SRCHLP .
8041          ENDIF.
8042        ENDLOOP.
8043      ENDIF.
8044
8045    ENDFORM.                    " get_sto_hitcnt_del2
8046   *&---------------------------------------------------------------------*
8047   *&      Form  get_sto_hitcnt_del23
8048   *&---------------------------------------------------------------------*
8049   *       text
8050   *----------------------------------------------------------------------*
8051   *  -->  p1        text
8052   *  <--  p2        text
8053   *----------------------------------------------------------------------*
8054    FORM GET_STO_HITCNT_DEL23.
8055      DATA: L3_LEN TYPE I,
8056            L3_CHECK TYPE C.
8057
8058   * if not g_tabctrl110_wa-desc2 is initial.
8059   *     loop at ist_srchlp into wa_srchlp.
8060   *       move wa_srchlp-maktg to wa_srchlp-maktx.
8061   *       TRANSLATE g_tabctrl110_wa-desc2 to upper case.
8062   *       search wa_srchlp-maktx for g_tabctrl110_wa-desc2.
8063   *       if sy-subrc <> 0.
8064   *         delete ist_srchlp .
8065   *       endif.
8066   *     endloop.
8067   *  endif.
8068      PERFORM GET_STO_HITCNT_DEL2.
8069      IF NOT G_TABCTRL110_WA-DESC3 IS INITIAL.
8070        LOOP AT IST_SRCHLP INTO WA_SRCHLP.
8071          L3_LEN = STRLEN( WA_SRCHLP-MAKTG ).
8072          L3_LEN = L3_LEN - 1.
8073          L3_CHECK = WA_SRCHLP-MAKTG+L3_LEN(1).
8074          IF L3_CHECK = '*'.
8075            CONCATENATE WA_SRCHLP-MAKTG+0(L3_LEN) WA_SRCHLP-WRKST INTO
8076            WA_SRCHLP-MAKTX.
8077          ELSE.
8078            MOVE WA_SRCHLP-MAKTG TO WA_SRCHLP-MAKTX.
8079          ENDIF.
8080          TRANSLATE G_TABCTRL110_WA-DESC3 TO UPPER CASE.
8081          SEARCH WA_SRCHLP-MAKTX FOR G_TABCTRL110_WA-DESC3.
8082          IF SY-SUBRC <> 0.
8083            DELETE IST_SRCHLP .
8084          ENDIF.
8085        ENDLOOP.
8086      ENDIF.
8087    ENDFORM.                    " get_sto_hitcnt_del23
8088   *&---------------------------------------------------------------------*
8089   *&      Form  update_noofhits
8090   *&---------------------------------------------------------------------*
8091   *       text
8092   *----------------------------------------------------------------------*
8093   *  -->  p1        text
8094   *  <--  p2        text
8095   *----------------------------------------------------------------------*
8096    FORM UPDATE_NOOFHITS.
8097      CASE ZMM_CDHD_ST-MTART.
8098          REFRESH IST_ZMM_CDITEM.
8099        WHEN 'ZSTO'.
8100          LOOP AT G_TABCTRL110_ITAB INTO G_TABCTRL110_WA.
8101            IF NOT ZMM_CDHD_ST-STATUS_FLAG IS INITIAL AND
8102                 ZMM_CDHD_ST-APPROVE_MRP IS INITIAL.
8103              DESC11 = G_TABCTRL110_WA-DESC1.
8104              PERFORM GET_NOOFHITS.
8105            ENDIF.
8106            UPDATE ZMM_CDITEM
8107              SET MAT_FND = G_TABCTRL110_WA-MAT_FND
8108              WHERE REQNO = ZMM_CDHD_ST-REQNO
8109              AND   SRNO  = G_TABCTRL110_WA-SRNO.
8110          ENDLOOP.
8111        WHEN 'ZSPR'.
8112          LOOP AT G_TABLCTRL120_ITAB INTO G_TABLCTRL120_WA.
8113            IF NOT ZMM_CDHD_ST-STATUS_FLAG IS INITIAL AND
8114                 ZMM_CDHD_ST-APPROVE_MRP IS INITIAL .
8115              PERFORM GET_NOOFHITS.
8116            ENDIF.
8117            UPDATE ZMM_CDITEM
8118             SET MAT_FND = G_TABLCTRL120_WA-MAT_FND
8119             WHERE REQNO  = ZMM_CDHD_ST-REQNO
8120             AND   SRNO  = G_TABLCTRL120_WA-SRNO.
8121          ENDLOOP.
8122        WHEN 'ZCAP'.
8123          LOOP AT G_TABLCTRL130_ITAB INTO G_TABLCTRL130_WA.
8124            IF NOT ZMM_CDHD_ST-STATUS_FLAG IS INITIAL AND
8125                 ZMM_CDHD_ST-APPROVE_MRP IS INITIAL.
8126              PERFORM GET_NOOFHITS.
8127            ENDIF.
8128            UPDATE ZMM_CDITEM
8129            SET MAT_FND = G_TABLCTRL130_WA-MAT_FND
8130            WHERE REQNO  = ZMM_CDHD_ST-REQNO
8131            AND   SRNO  = G_TABLCTRL130_WA-SRNO.
8132          ENDLOOP.
8133
8134      ENDCASE.
8135
8136    ENDFORM.                    " update_noofhits
8137   *&---------------------------------------------------------------------*
8138   *&      Form  get_cap_hitcnt
8139   *&---------------------------------------------------------------------*
8140   *       text
8141   *----------------------------------------------------------------------*
8142   *  -->  p1        text
8143   *  <--  p2        text
8144   *----------------------------------------------------------------------*
8145    FORM GET_CAP_HITCNT.
8146      DATA : L_SRNO1  LIKE SY-INDEX.
8147      DATA : L_LEN1   LIKE SY-INDEX.
8148      DATA : L_CHECK1.
8149      DATA : BEGIN OF WA_PARTDESC1,
8150               PART(40),
8151             END OF WA_PARTDESC1.
8152      DATA : IST_PARTDESC1 LIKE TABLE OF WA_PARTDESC1.
8153      DATA : L_DESC1(100).
8154      DATA : PART11(40),PART21(40),PART31(40),PART41(40).
8155      DATA : L_MATNR1 LIKE THEAD-TDNAME.
8156      DATA : IST_PARTDESC_LINES1 TYPE I.
8157
8158   *
8159
8160      IF NOT G_TABLCTRL130_WA-DESC_FIN  IS INITIAL.
8161        TRANSLATE G_TABLCTRL130_WA-DESC_FIN TO UPPER CASE.
8162        SPLIT G_TABLCTRL130_WA-DESC_FIN AT ' ' INTO TABLE IST_PARTDESC1.
8163   *
8164        DESCRIBE TABLE IST_PARTDESC1 LINES IST_PARTDESC_LINES1.
8165        IF IST_PARTDESC_LINES1 > 2.
8166          DELETE IST_PARTDESC1 FROM 3 TO IST_PARTDESC_LINES1.
8167        ENDIF.
8168        READ TABLE IST_PARTDESC1 INTO WA_PARTDESC1 INDEX 1.
8169
8170        CONCATENATE '%' WA_PARTDESC1-PART '%' INTO L_DESC1.
8171        CONDENSE L_DESC1 NO-GAPS.
8172   *
8173        SELECT A~MAKTG A~MATNR B~MEINS B~MFRPN B~WRKST
8174        INTO CORRESPONDING FIELDS OF TABLE IST_SRCHLP
8175        FROM MAKT AS A
8176        JOIN MARA AS B
8177        ON A~MATNR = B~MATNR
8178        WHERE B~MTART = 'ZCAP'  AND
8179        ( A~MAKTG LIKE L_DESC1 OR B~WRKST LIKE L_DESC1 ).
8180   *
8181        LOOP AT IST_PARTDESC1 INTO WA_PARTDESC1.
8182          IF SY-TABIX = 1.
8183            PART11 = WA_PARTDESC1-PART.
8184            CONDENSE PART11 NO-GAPS.
8185          ELSEIF SY-TABIX = 2.
8186            PART21 = WA_PARTDESC1-PART.
8187            CONDENSE PART11 NO-GAPS.
8188   *
8189          ENDIF.
8190        ENDLOOP.
8191
8192        LOOP AT IST_SRCHLP INTO WA_SRCHLP.
8193          IF WA_SRCHLP-MAKTG+39(1) = '*'.
8194            CONCATENATE WA_SRCHLP-MAKTG+0(39) WA_SRCHLP-WRKST INTO
8195            WA_SRCHLP-MAKTX.
8196          ELSE.
8197            MOVE WA_SRCHLP-MAKTG TO WA_SRCHLP-MAKTX.
8198          ENDIF.
8199
8200          TRANSLATE WA_SRCHLP-MAKTX TO UPPER CASE.
8201          CHECK PART21 <> ''.
8202          SEARCH WA_SRCHLP-MAKTX FOR PART21.
8203          IF SY-SUBRC = 0.
8204   *
8205          ELSE.
8206            DELETE  IST_SRCHLP INDEX SY-TABIX.
8207          ENDIF.
8208        ENDLOOP.
8209      ENDIF.
8210      LOOP AT IST_SRCHLP INTO WA_SRCHLP.
8211        IF WA_SRCHLP-MAKTG+39(1) = '*'.
8212          CONCATENATE WA_SRCHLP-MAKTG+0(39) WA_SRCHLP-WRKST INTO
8213          WA_SRCHLP-MAKTX.
8214        ELSE.
8215          MOVE WA_SRCHLP-MAKTG TO WA_SRCHLP-MAKTX.
8216        ENDIF.
8217        L_SRNO1         = L_SRNO1 + 1.
8218        WA_SRCHLP-SRNO = L_SRNO1.
8219        L_MATNR1 = WA_SRCHLP-MATNR.
8220
8221        CALL FUNCTION 'READ_TEXT'
8222          EXPORTING
8223            ID                      = 'BEST'
8224            LANGUAGE                = 'E'
8225            NAME                    = L_MATNR1
8226            OBJECT                  = 'MATERIAL'
8227          TABLES
8228            LINES                   = LINES
8229          EXCEPTIONS
8230            ID                      = 1
8231            LANGUAGE                = 2
8232            NAME                    = 3
8233            NOT_FOUND               = 4
8234            OBJECT                  = 5
8235            REFERENCE_CHECK         = 6
8236            WRONG_ACCESS_TO_ARCHIVE = 7
8237            OTHERS                  = 8.
8238
8239        IF SY-SUBRC <> 0.
8240   *      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
8241   *      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
8242          WA_SRCHLP-MARK = '1'.
8243        ENDIF.
8244        MODIFY IST_SRCHLP FROM WA_SRCHLP.
8245      ENDLOOP.
8246      DESCRIBE TABLE IST_SRCHLP LINES G_MAT_FND.
8247
8248    ENDFORM.                    " get_cap_hitcnt
8249   *&---------------------------------------------------------------------*
8250   *&      Form  search_copyofdesc
8251   *&---------------------------------------------------------------------*
8252   *       text
8253   *----------------------------------------------------------------------*
8254   *  -->  p1        text
8255   *  <--  p2        text
8256   *----------------------------------------------------------------------*
8257    FORM SEARCH_COPYOFDESC.
8258      DATA : LSTO_SRNO  LIKE SY-INDEX.
8259      DATA : L_LEN   LIKE SY-INDEX.
8260      DATA : LSTO_DESC(100).
8261      DATA : LSTO_MATNR LIKE THEAD-TDNAME.
8262
8263      READ TABLE G_TABCTRL110_ITAB INTO G_TABCTRL110_WA INDEX
8264      G_CURR_LINE_110.
8265
8266      IF NOT G_TABCTRL110_WA-DESC_CDCELL  IS INITIAL.
8267
8268        TRANSLATE G_TABCTRL110_WA-DESC_CDCELL TO UPPER CASE.
8269
8270        CONCATENATE '%' G_TABCTRL110_WA-DESC_CDCELL '%'
8271                    INTO LSTO_DESC .
8272        CONDENSE LSTO_DESC.
8273   *
8274        SELECT A~MAKTG A~MATNR B~MFRNR B~MEINS B~MFRPN B~WRKST
8275        INTO CORRESPONDING FIELDS OF TABLE IST_SRCHLP
8276        FROM MAKT AS A
8277        JOIN MARA AS B
8278        ON A~MATNR = B~MATNR
8279        WHERE            "b~mtart = 'ZSTO'  and
8280        ( A~MAKTG LIKE LSTO_DESC OR B~WRKST LIKE LSTO_DESC ).
8281   *
8282      ENDIF.
8283      LOOP AT IST_SRCHLP INTO WA_SRCHLP.
8284        IF WA_SRCHLP-MAKTG+39(1) = '*'.
8285          CONCATENATE WA_SRCHLP-MAKTG+0(39) WA_SRCHLP-WRKST INTO
8286          WA_SRCHLP-MAKTX.
8287        ELSE.
8288          MOVE WA_SRCHLP-MAKTG TO WA_SRCHLP-MAKTX.
8289        ENDIF.
8290        LSTO_SRNO      = LSTO_SRNO + 1.
8291        WA_SRCHLP-SRNO = LSTO_SRNO.
8292        LSTO_MATNR     = WA_SRCHLP-MATNR.
8293
8294        CALL FUNCTION 'READ_TEXT'
8295          EXPORTING
8296            ID                      = 'BEST'
8297            LANGUAGE                = 'E'
8298            NAME                    = LSTO_MATNR
8299            OBJECT                  = 'MATERIAL'
8300          TABLES
8301            LINES                   = LINES
8302          EXCEPTIONS
8303            ID                      = 1
8304            LANGUAGE                = 2
8305            NAME                    = 3
8306            NOT_FOUND               = 4
8307            OBJECT                  = 5
8308            REFERENCE_CHECK         = 6
8309            WRONG_ACCESS_TO_ARCHIVE = 7
8310            OTHERS                  = 8.
8311
8312        IF SY-SUBRC <> 0.
8313   *      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
8314   *      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
8315          WA_SRCHLP-MARK = '1'.
8316        ENDIF.
8317        MODIFY IST_SRCHLP FROM WA_SRCHLP.
8318      ENDLOOP.
8319      DESCRIBE TABLE IST_SRCHLP LINES G_MAT_FND.
8320
8321    ENDFORM.                    " search_copyofdesc
8322   *&---------------------------------------------------------------------*
8323   *&      Form  export_data
8324   *&---------------------------------------------------------------------*
8325   *       text
8326   *----------------------------------------------------------------------*
8327   *  -->  p1        text
8328   *  <--  p2        text
8329   *----------------------------------------------------------------------*
8330    FORM EXPORT_DATA.
8331
8332      PERFORM GET_FILENAME USING P1_FILE.
8333
8334      IF G_FILE_FLAG <> 'X'.
8335
8336        DATA : G_CHECK_ITAB TYPE T_TABCTRL110_A OCCURS 0.
8337
8338        DATA : G_TABCTRL110_ITAB_HDR TYPE T_TABCTRL110_A OCCURS 0.
8339        DATA : G_TABCTRL110_ITAB_ITEM TYPE T_TABCTRL110_A OCCURS 0.
8340        DATA : G_TABCTRL110_WA_A TYPE T_TABCTRL110_A.
8341
8342        DATA : G_TABCTRL120_ITAB_HDR TYPE T_TABCTRL120_A OCCURS 0.
8343        DATA : G_TABCTRL120_ITAB_ITEM TYPE T_TABCTRL120_A OCCURS 0.
8344        DATA : G_TABCTRL120_WA_A TYPE T_TABCTRL120_A.
8345
8346        DATA : G_TABCTRL130_ITAB_HDR TYPE T_TABCTRL130_A OCCURS 0.
8347        DATA : G_TABCTRL130_ITAB_ITEM TYPE T_TABCTRL130_A OCCURS 0.
8348        DATA : G_TABCTRL130_WA_A TYPE T_TABCTRL130_A.
8349
8350        G_TABCTRL110_WA_A-SRNO     = 'Srno'.
8351        G_TABCTRL110_WA_A-REJ_FLG  = 'Rejflg'.
8352        G_TABCTRL110_WA_A-COMP_FLG = 'Errflg'.
8353        G_TABCTRL110_WA_A-MAT_FND  = 'Hits'.
8354        G_TABCTRL110_WA_A-OTH1  = 'Oth1'.
8355        G_TABCTRL110_WA_A-OTH2  = 'Oth2'.
8356        G_TABCTRL110_WA_A-OTH3  = 'Oth3'.
8357        G_TABCTRL110_WA_A-OTH4  = 'Oth4'.
8358
8359        G_TABCTRL110_WA_A-DESC2  = 'Sub attr 1'.
8360        G_TABCTRL110_WA_A-DESC3  = 'Sub attr 2'.
8361        G_TABCTRL110_WA_A-DESC4  = 'Sub attr 3'.
8362        G_TABCTRL110_WA_A-USER_DESC  = 'Addl Description'.
8363        G_TABCTRL110_WA_A-DESC_FIN   = 'Material Description'.
8364        G_TABCTRL110_WA_A-UOM     = 'UOM'.
8365        G_TABCTRL110_WA_A-HAZ_FLG = 'Hazardous'.
8366        G_TABCTRL110_WA_A-GRWGT   = 'Gross Wt'.
8367
8368        G_TABCTRL110_WA_A-WTUNIT  = 'Wt Unit'.
8369        G_TABCTRL110_WA_A-GRVOL   = 'Gross Vol'.
8370        G_TABCTRL110_WA_A-VOLUNIT = 'Vol Unit'.
8371        G_TABCTRL110_WA_A-SHLF_LIFE1 = 'Shelf life'.
8372        G_TABCTRL110_WA_A-ENVMAT     = 'Env Mat'.
8373
8374        G_TABCTRL110_WA_A-DMS    = 'DMS'.
8375        G_TABCTRL110_WA_A-CODBY  = 'Changed by'.
8376        G_TABCTRL110_WA_A-CODDT  = 'Changed date'.
8377
8378        G_TABCTRL110_WA_A-CODCRBY  = 'Codified by'.
8379        G_TABCTRL110_WA_A-CODCRDT  = 'Codified date'.
8380        G_TABCTRL110_WA_A-MATGP  = 'Mat Group'.
8381        G_TABCTRL110_WA_A-DSFLAG = 'Det spec flag'.
8382
8383        G_TABCTRL110_WA_A-MATCODE = 'Matcode'.
8384        G_TABCTRL110_WA_A-DESC1   = 'Main Mat Attribute'.
8385
8386        APPEND G_TABCTRL110_WA_A TO G_TABCTRL110_ITAB_HDR.
8387
8388        G_TABCTRL120_WA_A-SRNO     = 'Srno'.
8389        G_TABCTRL120_WA_A-MATCODE = 'Matcode'.
8390        G_TABCTRL120_WA_A-REJ_FLG  = 'Rejflg'.
8391        G_TABCTRL120_WA_A-COMP_FLG = 'Errflg'.
8392        G_TABCTRL120_WA_A-MAT_FND  = 'Hits'.
8393
8394        G_TABCTRL120_WA_A-DESC_FIN  = 'Material Description'.
8395        G_TABCTRL120_WA_A-UOM  = 'UOM'.
8396        G_TABCTRL120_WA_A-CAP_CODE  = 'Capital code'.
8397        G_TABCTRL120_WA_A-CAP_NAME  = 'Capital item desc'.
8398        G_TABCTRL120_WA_A-SUBASS  = 'Sub Ass'.
8399        G_TABCTRL120_WA_A-OTH_MDL  = 'Oth model'.
8400        G_TABCTRL120_WA_A-MDLNO  = 'Model No'.
8401        G_TABCTRL120_WA_A-MANU  = 'Orig eqpt mnfr'.
8402
8403        G_TABCTRL120_WA_A-HAZ_FLG  = 'Hazardous'.
8404        G_TABCTRL120_WA_A-GRWGT  = 'Gross Wt'.
8405
8406        G_TABCTRL120_WA_A-GRWGT  = 'Gross Wt'.
8407        G_TABCTRL120_WA_A-WTUNIT  = 'Wt Unit'.
8408        G_TABCTRL120_WA_A-GRVOL  = 'Gross Vol'.
8409        G_TABCTRL120_WA_A-VOLUNIT  = 'Vol unit'.
8410        G_TABCTRL120_WA_A-ENVMAT  = 'Env Mat'.
8411        G_TABCTRL120_WA_A-SHLF_LIFE1  = 'Shelf life'.
8412
8413        G_TABCTRL120_WA_A-DMS  = 'DMS'.
8414        G_TABCTRL120_WA_A-CODBY  = 'Changed by'.
8415        G_TABCTRL120_WA_A-CODDT  = 'Changed date'.
8416
8417        G_TABCTRL120_WA_A-CODCRBY  = 'Codified by'.
8418        G_TABCTRL120_WA_A-CODCRDT  = 'Codified date'.
8419        G_TABCTRL120_WA_A-MATGP  = 'Mat Group'.
8420        G_TABCTRL120_WA_A-DSFLAG = 'Det spec flag'.
8421
8422        G_TABCTRL120_WA_A-PARTNO = 'Manu Part No'.
8423
8424        APPEND G_TABCTRL120_WA_A TO G_TABCTRL120_ITAB_HDR.
8425
8426        G_TABCTRL130_WA_A-SRNO     = 'Srno'.
8427        G_TABCTRL130_WA_A-MATCODE = 'Matcode'.
8428        G_TABCTRL130_WA_A-REJ_FLG  = 'Rejflg'.
8429        G_TABCTRL130_WA_A-COMP_FLG = 'Errflg'.
8430        G_TABCTRL130_WA_A-MAT_FND  = 'Hits'.
8431
8432        G_TABCTRL130_WA_A-DESC_FIN  = 'Capital Item Description'.
8433        G_TABCTRL130_WA_A-DESC_CDCELL  = 'Suggested Description'.
8434
8435        G_TABCTRL130_WA_A-UOM  = 'UOM'.
8436        G_TABCTRL130_WA_A-MATCOST  = 'Appx matcost Rs'.
8437        G_TABCTRL130_WA_A-MATCATG  = 'User/Group'.
8438        G_TABCTRL130_WA_A-MATLOC  = 'Place of use'.
8439        G_TABCTRL130_WA_A-WRKNG_LIFE  = 'Life in years'.
8440        G_TABCTRL130_WA_A-SPA_GRP  = 'Spare grp'.
8441
8442        G_TABCTRL130_WA_A-HAZ_FLG  = 'Hazardous'.
8443        G_TABCTRL130_WA_A-GRWGT  = 'Gross Wt'.
8444
8445        G_TABCTRL130_WA_A-GRWGT  = 'Gross Wt'.
8446        G_TABCTRL130_WA_A-WTUNIT  = 'Wt Unit'.
8447        G_TABCTRL130_WA_A-GRVOL  = 'Gross Vol'.
8448        G_TABCTRL130_WA_A-VOLUNIT  = 'Vol unit'.
8449        G_TABCTRL130_WA_A-ENVMAT  = 'Env Mat'.
8450        G_TABCTRL130_WA_A-SHLF_LIFE1  = 'Shelf life'.
8451
8452        G_TABCTRL130_WA_A-DMS  = 'DMS'.
8453        G_TABCTRL130_WA_A-CODBY  = 'Changed by'.
8454        G_TABCTRL130_WA_A-CODDT  = 'Changed date'.
8455
8456        G_TABCTRL130_WA_A-CODCRBY  = 'Codified by'.
8457        G_TABCTRL130_WA_A-CODCRDT  = 'Codified date'.
8458        G_TABCTRL130_WA_A-DSFLAG = 'Det spec flag'.
8459
8460        APPEND G_TABCTRL130_WA_A TO G_TABCTRL130_ITAB_HDR.
8461
8462   ***************************************************
8463        " Begin of <RD1K960036>.
8464   *CALL FUNCTION 'WS_UPLOAD'
8465   * EXPORTING
8466   **   CODEPAGE                      = ' '
8467   *   FILENAME                      = p1_file
8468   *   FILETYPE                      = 'DAT'
8469   **   HEADLEN                       = ' '
8470   **   LINE_EXIT                     = ' '
8471   **   TRUNCLEN                      = ' '
8472   **   USER_FORM                     = ' '
8473   **   USER_PROG                     = ' '
8474   **   DAT_D_FORMAT                  = ' '
8475   ** IMPORTING
8476   **   FILELENGTH                    =
8477   *  TABLES
8478   *    DATA_TAB                      = g_check_itab
8479   * EXCEPTIONS
8480   *   CONVERSION_ERROR              = 1
8481   *   FILE_OPEN_ERROR               = 2
8482   *   FILE_READ_ERROR               = 3
8483   *   INVALID_TYPE                  = 4
8484   *   NO_BATCH                      = 5
8485   *   UNKNOWN_ERROR                 = 6
8486   *   INVALID_TABLE_WIDTH           = 7
8487   *   GUI_REFUSE_FILETRANSFER       = 8
8488   *   CUSTOMER_ERROR                = 9
8489   *   OTHERS                        = 10
8490   *          .
8491        CONSTANTS: G_C_ASC TYPE CHAR10 VALUE 'ASC'.
8492
8493        DATA : I_FILE_TABLE TYPE  TABLE OF FILE_TABLE,
8494               L_FILETABLE  TYPE  FILE_TABLE,
8495               L_RC         TYPE  I,
8496               L_P_DEF_FILE TYPE  STRING,
8497               L_P_FILE     TYPE  STRING,
8498               L_USR_ACT    TYPE  I.
8499        L_P_FILE = P1_FILE.
8500
8501        CALL FUNCTION 'GUI_UPLOAD'
8502          EXPORTING
8503            FILENAME                = L_P_FILE
8504            FILETYPE                = G_C_ASC
8505            HAS_FIELD_SEPARATOR     = 'X'
8506          TABLES
8507            DATA_TAB                = G_CHECK_ITAB
8508          EXCEPTIONS
8509            FILE_OPEN_ERROR         = 1
8510            FILE_READ_ERROR         = 2
8511            NO_BATCH                = 3
8512            GUI_REFUSE_FILETRANSFER = 4
8513            INVALID_TYPE            = 5
8514            NO_AUTHORITY            = 6
8515            UNKNOWN_ERROR           = 7
8516            BAD_DATA_FORMAT         = 8
8517            HEADER_NOT_ALLOWED      = 9
8518            SEPARATOR_NOT_ALLOWED   = 10
8519            HEADER_TOO_LONG         = 11
8520            UNKNOWN_DP_ERROR        = 12
8521            ACCESS_DENIED           = 13
8522            DP_OUT_OF_MEMORY        = 14
8523            DISK_FULL               = 15
8524            DP_TIMEOUT              = 16
8525            OTHERS                  = 17.
8526        " End of <RD1K960036>.
8527        IF SY-SUBRC = 0.
8528          MESSAGE I089(ZMM_OTH) WITH P1_FILE.
8529        ELSE.
8530
8531   ***************************************************
8532
8533          CASE ZMM_CDHD_ST-MTART.
8534
8535              DATA : L_FILE1 TYPE STRING.
8536              L_FILE1 = L_P_FILE.
8537
8538            WHEN 'ZSTO'.
8539
8540              LOOP AT G_TABCTRL110_ITAB INTO G_TABCTRL110_WA.
8541
8542                MOVE-CORRESPONDING G_TABCTRL110_WA TO G_TABCTRL110_WA_A.
8543
8544                APPEND G_TABCTRL110_WA_A TO G_TABCTRL110_ITAB_ITEM.
8545
8546              ENDLOOP.
8547              " Begin of <RD1K960036>.
8548
8549
8550   *    CALL FUNCTION 'WS_DOWNLOAD'
8551   *     EXPORTING
8552   **       BIN_FILESIZE                  = ' '
8553   **       CODEPAGE                      = ' '
8554   *       FILENAME                      = p1_file
8555   *       FILETYPE                      = 'DAT'
8556   **       MODE                          = ' '
8557   **       WK1_N_FORMAT                  = ' '
8558   **       WK1_N_SIZE                    = ' '
8559   **       WK1_T_FORMAT                  = ' '
8560   **       WK1_T_SIZE                    = ' '
8561   **       COL_SELECT                    = ' '
8562   **       COL_SELECTMASK                = ' '
8563   **       NO_AUTH_CHECK                 = ' '
8564   **     IMPORTING
8565   **       FILELENGTH                    =
8566   *
8567   *      TABLES
8568   *        DATA_TAB                      = g_TABCTRL110_itab_hdr
8569   *
8570   *     EXCEPTIONS
8571   *       FILE_OPEN_ERROR               = 1
8572   *       FILE_WRITE_ERROR              = 2
8573   *       INVALID_FILESIZE              = 3
8574   *       INVALID_TYPE                  = 4
8575   *       NO_BATCH                      = 5
8576   *       UNKNOWN_ERROR                 = 6
8577   *       INVALID_TABLE_WIDTH           = 7
8578   *       GUI_REFUSE_FILETRANSFER       = 8
8579   *       CUSTOMER_ERROR                = 9
8580   *       OTHERS                        = 10.
8581
8582              CALL FUNCTION 'GUI_DOWNLOAD'
8583                EXPORTING
8584                  FILENAME                = L_FILE1
8585                  FILETYPE                = 'DAT'
8586                TABLES
8587                  DATA_TAB                = G_TABCTRL110_ITAB_HDR
8588                EXCEPTIONS
8589                  FILE_WRITE_ERROR        = 1
8590                  NO_BATCH                = 2
8591                  GUI_REFUSE_FILETRANSFER = 3
8592                  INVALID_TYPE            = 4
8593                  NO_AUTHORITY            = 5
8594                  UNKNOWN_ERROR           = 6
8595                  HEADER_NOT_ALLOWED      = 7
8596                  SEPARATOR_NOT_ALLOWED   = 8
8597                  FILESIZE_NOT_ALLOWED    = 9
8598                  HEADER_TOO_LONG         = 10
8599                  DP_ERROR_CREATE         = 11
8600                  DP_ERROR_SEND           = 12
8601                  DP_ERROR_WRITE          = 13
8602                  UNKNOWN_DP_ERROR        = 14
8603                  ACCESS_DENIED           = 15
8604                  DP_OUT_OF_MEMORY        = 16
8605                  DISK_FULL               = 17
8606                  DP_TIMEOUT              = 18
8607                  FILE_NOT_FOUND          = 19
8608                  DATAPROVIDER_EXCEPTION  = 20
8609                  CONTROL_FLUSH_ERROR     = 21
8610                  OTHERS                  = 22.
8611
8612              " End of <RD1K960036>.
8613
8614              IF SY-SUBRC = 0.
8615                " Begin of <RD1K960036>.
8616   *    CALL FUNCTION 'WS_DOWNLOAD'
8617   *     EXPORTING
8618   **       BIN_FILESIZE                  = ' '
8619   **       CODEPAGE                      = ' '
8620   *       FILENAME                      = p1_file
8621   *       FILETYPE                      = 'DAT'
8622   *       MODE                          = 'A'
8623   **       WK1_N_FORMAT                  = ' '
8624   **       WK1_N_SIZE                    = ' '
8625   **       WK1_T_FORMAT                  = ' '
8626   **       WK1_T_SIZE                    = ' '
8627   **       COL_SELECT                    = ' '
8628   **       COL_SELECTMASK                = ' '
8629   **       NO_AUTH_CHECK                 = ' '
8630   **     IMPORTING
8631   **       FILELENGTH                    =
8632   *      TABLES
8633   *        DATA_TAB                      = g_TABCTRL110_itab_item
8634   **       FIELDNAMES                    =
8635   **     EXCEPTIONS
8636   **       FILE_OPEN_ERROR               = 1
8637   **       FILE_WRITE_ERROR              = 2
8638   **       INVALID_FILESIZE              = 3
8639   **       INVALID_TYPE                  = 4
8640   **       NO_BATCH                      = 5
8641   **       UNKNOWN_ERROR                 = 6
8642   **       INVALID_TABLE_WIDTH           = 7
8643   **       GUI_REFUSE_FILETRANSFER       = 8
8644   **       CUSTOMER_ERROR                = 9
8645   **       OTHERS                        = 10
8646   *              .
8647
8648                CALL FUNCTION 'GUI_DOWNLOAD'
8649                  EXPORTING
8650                    FILENAME                = L_FILE1
8651                    FILETYPE                = 'DAT'
8652                    APPEND                  = 'X'
8653                  TABLES
8654                    DATA_TAB                = G_TABCTRL110_ITAB_ITEM
8655                  EXCEPTIONS
8656                    FILE_WRITE_ERROR        = 1
8657                    NO_BATCH                = 2
8658                    GUI_REFUSE_FILETRANSFER = 3
8659                    INVALID_TYPE            = 4
8660                    NO_AUTHORITY            = 5
8661                    UNKNOWN_ERROR           = 6
8662                    HEADER_NOT_ALLOWED      = 7
8663                    SEPARATOR_NOT_ALLOWED   = 8
8664                    FILESIZE_NOT_ALLOWED    = 9
8665                    HEADER_TOO_LONG         = 10
8666                    DP_ERROR_CREATE         = 11
8667                    DP_ERROR_SEND           = 12
8668                    DP_ERROR_WRITE          = 13
8669                    UNKNOWN_DP_ERROR        = 14
8670                    ACCESS_DENIED           = 15
8671                    DP_OUT_OF_MEMORY        = 16
8672                    DISK_FULL               = 17
8673                    DP_TIMEOUT              = 18
8674                    FILE_NOT_FOUND          = 19
8675                    DATAPROVIDER_EXCEPTION  = 20
8676                    CONTROL_FLUSH_ERROR     = 21
8677                    OTHERS                  = 22.
8678
8679                " End of <RD1k960036>.
8680                IF SY-SUBRC = 0.
8681                  MESSAGE I085(ZMM_OTH) WITH P1_FILE.
8682                ENDIF.
8683
8684              ELSE.
8685
8686                IF SY-SUBRC = 1.
8687                  MESSAGE I086(ZMM_OTH) WITH 'File open error'.
8688                ELSEIF SY-SUBRC = 2.
8689                  MESSAGE I086(ZMM_OTH) WITH 'File write error'.
8690                ELSE.
8691                  MESSAGE I086(ZMM_OTH).
8692                ENDIF.
8693
8694              ENDIF.
8695
8696              CLEAR : G_TABCTRL110_WA_A, G_TABCTRL110_ITAB_ITEM.
8697              REFRESH G_TABCTRL110_ITAB_ITEM.
8698
8699            WHEN 'ZSPR'.
8700
8701              LOOP AT G_TABLCTRL120_ITAB INTO G_TABLCTRL120_WA.
8702
8703                MOVE-CORRESPONDING G_TABLCTRL120_WA TO G_TABCTRL120_WA_A.
8704
8705                APPEND G_TABCTRL120_WA_A TO G_TABCTRL120_ITAB_ITEM.
8706
8707              ENDLOOP.
8708              " Begin of <RD1K960036>.
8709   *    CALL FUNCTION 'WS_DOWNLOAD'
8710   *     EXPORTING
8711   **       BIN_FILESIZE                  = ' '
8712   **       CODEPAGE                      = ' '
8713   *       FILENAME                      = p1_file
8714   *       FILETYPE                      = 'DAT'
8715   **       MODE                          = ' '
8716   **       WK1_N_FORMAT                  = ' '
8717   **       WK1_N_SIZE                    = ' '
8718   **       WK1_T_FORMAT                  = ' '
8719   **       WK1_T_SIZE                    = ' '
8720   **       COL_SELECT                    = ' '
8721   **       COL_SELECTMASK                = ' '
8722   **       NO_AUTH_CHECK                 = ' '
8723   **     IMPORTING
8724   **       FILELENGTH                    =
8725   *      TABLES
8726   *        DATA_TAB                      = g_TABCTRL120_itab_hdr
8727   *
8728   *      EXCEPTIONS
8729   *       FILE_OPEN_ERROR               = 1
8730   *       FILE_WRITE_ERROR              = 2
8731   *       INVALID_FILESIZE              = 3
8732   *       INVALID_TYPE                  = 4
8733   *       NO_BATCH                      = 5
8734   *       UNKNOWN_ERROR                 = 6
8735   *       INVALID_TABLE_WIDTH           = 7
8736   *       GUI_REFUSE_FILETRANSFER       = 8
8737   *       CUSTOMER_ERROR                = 9
8738   *       OTHERS                        = 10.
8739
8740              CALL FUNCTION 'GUI_DOWNLOAD'
8741                EXPORTING
8742                  FILENAME                = L_FILE1
8743                  FILETYPE                = 'DAT'
8744   *        APPEND                  = 'X'
8745                TABLES
8746                  DATA_TAB                = G_TABCTRL120_ITAB_HDR
8747                EXCEPTIONS
8748                  FILE_WRITE_ERROR        = 1
8749                  NO_BATCH                = 2
8750                  GUI_REFUSE_FILETRANSFER = 3
8751                  INVALID_TYPE            = 4
8752                  NO_AUTHORITY            = 5
8753                  UNKNOWN_ERROR           = 6
8754                  HEADER_NOT_ALLOWED      = 7
8755                  SEPARATOR_NOT_ALLOWED   = 8
8756                  FILESIZE_NOT_ALLOWED    = 9
8757                  HEADER_TOO_LONG         = 10
8758                  DP_ERROR_CREATE         = 11
8759                  DP_ERROR_SEND           = 12
8760                  DP_ERROR_WRITE          = 13
8761                  UNKNOWN_DP_ERROR        = 14
8762                  ACCESS_DENIED           = 15
8763                  DP_OUT_OF_MEMORY        = 16
8764                  DISK_FULL               = 17
8765                  DP_TIMEOUT              = 18
8766                  FILE_NOT_FOUND          = 19
8767                  DATAPROVIDER_EXCEPTION  = 20
8768                  CONTROL_FLUSH_ERROR     = 21
8769                  OTHERS                  = 22.
8770              .
8771              " End of <RD1K960036>.
8772              IF SY-SUBRC = 0.
8773                " Begin of <RD1K960036>.
8774   *    CALL FUNCTION 'WS_DOWNLOAD'
8775   *     EXPORTING
8776   **       BIN_FILESIZE                  = ' '
8777   **       CODEPAGE                      = ' '
8778   *       FILENAME                      = p1_file
8779   *       FILETYPE                      = 'DAT'
8780   *       MODE                          = 'A'
8781   **       WK1_N_FORMAT                  = ' '
8782   **       WK1_N_SIZE                    = ' '
8783   **       WK1_T_FORMAT                  = ' '
8784   **       WK1_T_SIZE                    = ' '
8785   **       COL_SELECT                    = ' '
8786   **       COL_SELECTMASK                = ' '
8787   **       NO_AUTH_CHECK                 = ' '
8788   **     IMPORTING
8789   **       FILELENGTH                    =
8790   *      TABLES
8791   *        DATA_TAB                      = g_TABCTRL120_itab_item
8792   **       FIELDNAMES                    =
8793   **     EXCEPTIONS
8794   **       FILE_OPEN_ERROR               = 1
8795   **       FILE_WRITE_ERROR              = 2
8796   **       INVALID_FILESIZE              = 3
8797   **       INVALID_TYPE                  = 4
8798   **       NO_BATCH                      = 5
8799   **       UNKNOWN_ERROR                 = 6
8800   **       INVALID_TABLE_WIDTH           = 7
8801   **       GUI_REFUSE_FILETRANSFER       = 8
8802   **       CUSTOMER_ERROR                = 9
8803   **       OTHERS                        = 10
8804   *              .
8805                CALL FUNCTION 'GUI_DOWNLOAD'
8806                  EXPORTING
8807                    FILENAME                = L_FILE1
8808                    FILETYPE                = 'DAT'
8809                    APPEND                  = 'X'
8810                  TABLES
8811                    DATA_TAB                = G_TABCTRL120_ITAB_ITEM
8812                  EXCEPTIONS
8813                    FILE_WRITE_ERROR        = 1
8814                    NO_BATCH                = 2
8815                    GUI_REFUSE_FILETRANSFER = 3
8816                    INVALID_TYPE            = 4
8817                    NO_AUTHORITY            = 5
8818                    UNKNOWN_ERROR           = 6
8819                    HEADER_NOT_ALLOWED      = 7
8820                    SEPARATOR_NOT_ALLOWED   = 8
8821                    FILESIZE_NOT_ALLOWED    = 9
8822                    HEADER_TOO_LONG         = 10
8823                    DP_ERROR_CREATE         = 11
8824                    DP_ERROR_SEND           = 12
8825                    DP_ERROR_WRITE          = 13
8826                    UNKNOWN_DP_ERROR        = 14
8827                    ACCESS_DENIED           = 15
8828                    DP_OUT_OF_MEMORY        = 16
8829                    DISK_FULL               = 17
8830                    DP_TIMEOUT              = 18
8831                    FILE_NOT_FOUND          = 19
8832                    DATAPROVIDER_EXCEPTION  = 20
8833                    CONTROL_FLUSH_ERROR     = 21
8834                    OTHERS                  = 22.
8835                .
8836                " End of <RD1K960036>.
8837                IF SY-SUBRC = 0.
8838                  MESSAGE I085(ZMM_OTH) WITH P1_FILE.
8839                ENDIF.
8840
8841              ELSE.
8842
8843                IF SY-SUBRC = 1.
8844                  MESSAGE I086(ZMM_OTH) WITH 'File open error'.
8845                ELSEIF SY-SUBRC = 2.
8846                  MESSAGE I086(ZMM_OTH) WITH 'File write error'.
8847                ELSE.
8848                  MESSAGE I086(ZMM_OTH).
8849                ENDIF.
8850
8851              ENDIF.
8852
8853              CLEAR : G_TABCTRL120_WA_A, G_TABCTRL120_ITAB_ITEM.
8854              REFRESH G_TABCTRL120_ITAB_ITEM.
8855
8856
8857            WHEN 'ZCAP'.
8858
8859              LOOP AT G_TABLCTRL130_ITAB INTO G_TABLCTRL130_WA.
8860
8861                MOVE-CORRESPONDING G_TABLCTRL130_WA TO G_TABCTRL130_WA_A.
8862
8863                APPEND G_TABCTRL130_WA_A TO G_TABCTRL130_ITAB_ITEM.
8864
8865              ENDLOOP.
8866              " Begin of <RD1K960036>.
8867   *    CALL FUNCTION 'WS_DOWNLOAD'
8868   *     EXPORTING
8869   **       BIN_FILESIZE                  = ' '
8870   **       CODEPAGE                      = ' '
8871   *       FILENAME                      = p1_file
8872   *       FILETYPE                      = 'DAT'
8873   **       MODE                          = ' '
8874   **       WK1_N_FORMAT                  = ' '
8875   **       WK1_N_SIZE                    = ' '
8876   **       WK1_T_FORMAT                  = ' '
8877   **       WK1_T_SIZE                    = ' '
8878   **       COL_SELECT                    = ' '
8879   **       COL_SELECTMASK                = ' '
8880   **       NO_AUTH_CHECK                 = ' '
8881   **     IMPORTING
8882   **       FILELENGTH                    =
8883   *      TABLES
8884   *        DATA_TAB                      = g_TABCTRL130_itab_hdr
8885   *
8886   *      EXCEPTIONS
8887   *       FILE_OPEN_ERROR               = 1
8888   *       FILE_WRITE_ERROR              = 2
8889   *       INVALID_FILESIZE              = 3
8890   *       INVALID_TYPE                  = 4
8891   *       NO_BATCH                      = 5
8892   *       UNKNOWN_ERROR                 = 6
8893   *       INVALID_TABLE_WIDTH           = 7
8894   *       GUI_REFUSE_FILETRANSFER       = 8
8895   *       CUSTOMER_ERROR                = 9
8896   *       OTHERS                        = 10.
8897   *  .
8898              CALL FUNCTION 'GUI_DOWNLOAD'
8899                    EXPORTING
8900                      FILENAME                = L_FILE1
8901                      FILETYPE                = 'DAT'
8902   *        APPEND                  = 'X'
8903                    TABLES
8904                      DATA_TAB                = G_TABCTRL130_ITAB_HDR
8905                    EXCEPTIONS
8906                      FILE_WRITE_ERROR        = 1
8907                      NO_BATCH                = 2
8908                      GUI_REFUSE_FILETRANSFER = 3
8909                      INVALID_TYPE            = 4
8910                      NO_AUTHORITY            = 5
8911                      UNKNOWN_ERROR           = 6
8912                      HEADER_NOT_ALLOWED      = 7
8913                      SEPARATOR_NOT_ALLOWED   = 8
8914                      FILESIZE_NOT_ALLOWED    = 9
8915                      HEADER_TOO_LONG         = 10
8916                      DP_ERROR_CREATE         = 11
8917                      DP_ERROR_SEND           = 12
8918                      DP_ERROR_WRITE          = 13
8919                      UNKNOWN_DP_ERROR        = 14
8920                      ACCESS_DENIED           = 15
8921                      DP_OUT_OF_MEMORY        = 16
8922                      DISK_FULL               = 17
8923                      DP_TIMEOUT              = 18
8924                      FILE_NOT_FOUND          = 19
8925                      DATAPROVIDER_EXCEPTION  = 20
8926                      CONTROL_FLUSH_ERROR     = 21
8927                      OTHERS                  = 22.
8928              .
8929              " End of <RD1K960036>.
8930              IF SY-SUBRC = 0.
8931                " Begin of <RD1K960036>.
8932   *    CALL FUNCTION 'WS_DOWNLOAD'
8933   *     EXPORTING
8934   **       BIN_FILESIZE                  = ' '
8935   **       CODEPAGE                      = ' '
8936   *       FILENAME                      = p1_file
8937   *       FILETYPE                      = 'DAT'
8938   *       MODE                          = 'A'
8939   **       WK1_N_FORMAT                  = ' '
8940   **       WK1_N_SIZE                    = ' '
8941   **       WK1_T_FORMAT                  = ' '
8942   **       WK1_T_SIZE                    = ' '
8943   **       COL_SELECT                    = ' '
8944   **       COL_SELECTMASK                = ' '
8945   **       NO_AUTH_CHECK                 = ' '
8946   **     IMPORTING
8947   **       FILELENGTH                    =
8948   *      TABLES
8949   *        DATA_TAB                      = g_TABCTRL130_itab_item
8950   **       FIELDNAMES                    =
8951   **     EXCEPTIONS
8952   **       FILE_OPEN_ERROR               = 1
8953   **       FILE_WRITE_ERROR              = 2
8954   **       INVALID_FILESIZE              = 3
8955   **       INVALID_TYPE                  = 4
8956   **       NO_BATCH                      = 5
8957   **       UNKNOWN_ERROR                 = 6
8958   **       INVALID_TABLE_WIDTH           = 7
8959   **       GUI_REFUSE_FILETRANSFER       = 8
8960   **       CUSTOMER_ERROR                = 9
8961   **       OTHERS                        = 10
8962   *              .
8963                CALL FUNCTION 'GUI_DOWNLOAD'
8964                  EXPORTING
8965                    FILENAME                = L_FILE1
8966                    FILETYPE                = 'DAT'
8967                    APPEND                  = 'X'
8968                  TABLES
8969                    DATA_TAB                = G_TABCTRL130_ITAB_ITEM
8970                  EXCEPTIONS
8971                    FILE_WRITE_ERROR        = 1
8972                    NO_BATCH                = 2
8973                    GUI_REFUSE_FILETRANSFER = 3
8974                    INVALID_TYPE            = 4
8975                    NO_AUTHORITY            = 5
8976                    UNKNOWN_ERROR           = 6
8977                    HEADER_NOT_ALLOWED      = 7
8978                    SEPARATOR_NOT_ALLOWED   = 8
8979                    FILESIZE_NOT_ALLOWED    = 9
8980                    HEADER_TOO_LONG         = 10
8981                    DP_ERROR_CREATE         = 11
8982                    DP_ERROR_SEND           = 12
8983                    DP_ERROR_WRITE          = 13
8984                    UNKNOWN_DP_ERROR        = 14
8985                    ACCESS_DENIED           = 15
8986                    DP_OUT_OF_MEMORY        = 16
8987                    DISK_FULL               = 17
8988                    DP_TIMEOUT              = 18
8989                    FILE_NOT_FOUND          = 19
8990                    DATAPROVIDER_EXCEPTION  = 20
8991                    CONTROL_FLUSH_ERROR     = 21
8992                    OTHERS                  = 22.
8993                .
8994                " End of <RD1K960036>.
8995                IF SY-SUBRC = 0.
8996   *     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
8997   *             WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
8998   *               MESSAGE I085(ZMM_OTH) WITH P1_FILE.
8999
9000                  CALL FUNCTION 'POPUP_TO_DISPLAY_TEXT'
9001                    EXPORTING
9002                      TITEL     = 'Information'
9003                      TEXTLINE1 = 'Data copied to file'
9004                      TEXTLINE2 = P1_FILE.
9005
9006
9007                ENDIF.
9008
9009              ELSE.
9010
9011                IF SY-SUBRC = 1.
9012                  MESSAGE I086(ZMM_OTH) WITH 'File open error'.
9013                ELSEIF SY-SUBRC = 2.
9014                  MESSAGE I086(ZMM_OTH) WITH 'File write error'.
9015                ELSE.
9016                  MESSAGE I086(ZMM_OTH).
9017                ENDIF.
9018
9019              ENDIF.
9020
9021              CLEAR : G_TABCTRL130_WA_A, G_TABCTRL130_ITAB_ITEM.
9022              REFRESH G_TABCTRL130_ITAB_ITEM.
9023
9024          ENDCASE.
9025
9026        ENDIF.
9027
9028      ELSE.
9029        CLEAR G_FILE_FLAG.
9030      ENDIF.
9031
9032    ENDFORM.                    " export_data
9033   *&---------------------------------------------------------------------*
9034   *&      Form  get_filename
9035   *&---------------------------------------------------------------------*
9036   *       text
9037   *----------------------------------------------------------------------*
9038   *      -->P_P1_FILE  text
9039   *----------------------------------------------------------------------*
9040    FORM GET_FILENAME USING   L_FILE1.
9041   *Begin of <RD1K960036>.
9042   *CALL FUNCTION 'WS_FILENAME_GET'
9043   *       EXPORTING
9044   *            DEF_PATH         = 'C:\'
9045   *            MASK             = ',*.txt.'
9046   *       IMPORTING
9047   *            FILENAME         = l_file1
9048   *       EXCEPTIONS
9049   *            INV_WINSYS       = 1
9050   *            NO_BATCH         = 2
9051   *            SELECTION_CANCEL = 3
9052   *            SELECTION_ERROR  = 4
9053   *            OTHERS           = 5.
9054   *
9055   *         IF SY-SUBRC <> 0.
9056   *      message i107(zhelp).
9057   *      g_file_flag = 'X'.
9058   *  ENDIF.
9059
9060   *DATA:lt_files TYPE filetable,
9061   *     l_file  TYPE file_table,
9062   *     l_title TYPE string,
9063   *     l_subrc TYPE i,
9064   *     l_def_file TYPE string.
9065   *
9066   *l_def_file = ' '.
9067   *
9068   *  CALL METHOD cl_gui_frontend_services=>file_open_dialog
9069   *    EXPORTING
9070   *         window_title     = l_title
9071   *         default_filename = l_def_file
9072   *         file_filter      = ' '
9073   *         initial_directory = 'C: \'
9074   *    CHANGING
9075   *         File_table = lt_files
9076   *         rc = l_subrc
9077   * EXCEPTIONS
9078   *  file_open_dialog_failed = 1
9079   *  cntl_error              = 2
9080   *  error_no_gui            = 3
9081   *  OTHERS                  = 4.
9082   *  CHECK sy-subrc = 0.
9083   *
9084   *  LOOP AT lt_files INTO l_file.
9085   *   l_file1 = l_file.
9086   *    EXIT.
9087   *  ENDLOOP.
9088   *
9089   *
9090   *IF SY-SUBRC <> 0.
9091   *      message i107(zhelp).
9092   *      g_file_flag = 'X'.
9093   *  ENDIF.
9094
9095   *End of <RD1K960036>.
9096
9097
9098
9099      DATA: L_DEFAULT_FILE_NAME TYPE STRING,
9100          L_INITIAL_DIRECTORY TYPE STRING,
9101          L_FILENAME          TYPE STRING,
9102          L_PATH              TYPE STRING,
9103          L_FULL_PATH         TYPE STRING,
9104          L_USER_ACTION       TYPE I.
9105
9106      CLEAR: L_DEFAULT_FILE_NAME,
9107             L_INITIAL_DIRECTORY.
9108
9109   *   L_DEFAULT_FILE_NAME = 'C:\Output'.
9110   *   L_INITIAL_DIRECTORY = 'C:\'.
9111
9112      CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG
9113        EXPORTING
9114          DEFAULT_FILE_NAME    = L_DEFAULT_FILE_NAME
9115          INITIAL_DIRECTORY    = L_INITIAL_DIRECTORY
9116        CHANGING
9117          FILENAME             = L_FILENAME
9118          PATH                 = L_PATH
9119          FULLPATH             = L_FULL_PATH
9120          USER_ACTION          = L_USER_ACTION
9121        EXCEPTIONS
9122          CNTL_ERROR           = 1
9123          ERROR_NO_GUI         = 2
9124          NOT_SUPPORTED_BY_GUI = 3
9125          OTHERS               = 4.
9126      L_FILE1 = L_FULL_PATH.
9127
9128    ENDFORM.                    " get_filename
9129   *&---------------------------------------------------------------------*
9130   *&      Form  ATTACH_FILES
9131   *&---------------------------------------------------------------------*
9132   *       text
9133   *----------------------------------------------------------------------*
9134   *  -->  p1        text
9135   *  <--  p2        text
9136   *----------------------------------------------------------------------*
9137   FORM ATTACH_FILES .
9138
9139   *  IF ZMM_CDHD_ST-REQNO IS INITIAL.
9140   *   MESSAGE 'enter request no' TYPE 'E'.
9141   *   ENDIF.
9142
9143   clear g_att_files_wa.
9144   refresh g_att_files.
9145
9146      g_att_files_wa-LOGSYS  = ZMM_CDHD_ST-REQNO.
9147      g_att_files_wa-objtype = 'IMAC'.
9148      g_att_files_wa-objkey  = '01'.
9149
9150      append g_att_files_wa to g_att_files.
9151
9152      CALL FUNCTION 'SO_WIND_ATTACHMENT_CREATE_API1'
9153        EXPORTING
9154          ATTACHMENT_DATA     = ''
9155          ATTACHMENT_TYPE     = 'DOC'
9156        TABLES
9157          APPLICATION_OBJECTS = g_att_files.
9158   ENDFORM.                    " ATTACH_FILES
9159   *&---------------------------------------------------------------------*
9160   *&      Form  LIST_FILES
9161   *&---------------------------------------------------------------------*
9162   *       text
9163   *----------------------------------------------------------------------*
9164   *  -->  p1        text
9165   *  <--  p2        text
9166   *----------------------------------------------------------------------*
9167   FORM LIST_FILES .
9168     clear g_att_files_wa.
9169
9170      g_att_files_wa-LOGSYS = ZMM_CDHD_ST-REQNO.
9171      g_att_files_wa-objtype = 'IMAC'.
9172      g_att_files_wa-objkey = '01'.
9173
9174      refresh exclude_tab[].
9175
9176      MOVE 'ENTR' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
9177      MOVE 'CHNG' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
9178      MOVE 'CREA' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
9179      MOVE 'DELE' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
9180      MOVE 'IMPO' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
9181      MOVE 'EXPO' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
9182      MOVE 'OLNK' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
9183      MOVE 'PRIN' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
9184      MOVE 'COPY' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
9185      MOVE 'HGEN' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
9186      MOVE 'REFL' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
9187      MOVE 'MOVE' TO EXCLUDE_TAB. APPEND EXCLUDE_TAB.
9188
9189
9190      CALL FUNCTION 'SO_WIND_ATTACHMENT_LIST_API1'
9191        EXPORTING
9192          APPLICATION_OBJECT       = g_att_files_wa
9193      FUNCTION                 = ' '
9194     TABLES
9195         FUNC_EXCLUDE              = exclude_tab.
9196   ENDFORM.                    " LIST_FILES
9197   *&---------------------------------------------------------------------*
9198   *&      Form  DISP_PROCESS_GUIDE
9199   *&---------------------------------------------------------------------*
9200   *       text
9201   *----------------------------------------------------------------------*
9202   *  -->  p1        text
9203   *  <--  p2        text
9204   *----------------------------------------------------------------------*
9205   FORM DISP_PROCESS_GUIDE .
9206
9207   *  DATA : ist_exclude_tab LIKE soxet OCCURS 0 WITH HEADER LINE.
9208   *  DATA : wa_att_files LIKE swotobjid.
9209   *  DATA L_OBJ TYPE SOOD4-OBJNO.
9210
9211     wa_att_files-logsys  = 'AC'        .
9212     wa_att_files-objtype = 'IMAC'.
9213     wa_att_files-objkey  = 'AC921'.
9214
9215     REFRESH ist_exclude_tab[].
9216     MOVE 'ENTR' TO ist_exclude_tab. APPEND ist_exclude_tab.
9217     MOVE 'CHNG' TO ist_exclude_tab. APPEND ist_exclude_tab.
9218     MOVE 'CREA' TO ist_exclude_tab. APPEND ist_exclude_tab.
9219     MOVE 'DELE' TO ist_exclude_tab. APPEND ist_exclude_tab.
9220     MOVE 'IMPO' TO ist_exclude_tab. APPEND ist_exclude_tab.
9221     MOVE 'EXPO' TO ist_exclude_tab. APPEND ist_exclude_tab.
9222     MOVE 'OLNK' TO ist_exclude_tab. APPEND ist_exclude_tab.
9223     MOVE 'PRIN' TO ist_exclude_tab. APPEND ist_exclude_tab.
9224     MOVE 'COPY' TO ist_exclude_tab. APPEND ist_exclude_tab.
9225     MOVE 'HGEN' TO ist_exclude_tab. APPEND ist_exclude_tab.
9226     MOVE 'REFL' TO ist_exclude_tab. APPEND ist_exclude_tab.
9227     MOVE 'MOVE' TO ist_exclude_tab. APPEND ist_exclude_tab.
9228
9229     CALL FUNCTION 'SO_WIND_ATTACHMENT_LIST_API1'
9230       EXPORTING
9231         application_object = wa_att_files
9232       TABLES
9233         func_exclude       = ist_exclude_tab.
9234   ENDFORM.                    " DISP_PROCESS_GUIDE
9235   *&---------------------------------------------------------------------*
9236   *&      Form  DETAILS_ONDBLCLK
9237   *&---------------------------------------------------------------------*
9238   *       text
9239   *----------------------------------------------------------------------*
9240   *  -->  p1        text
9241   *  <--  p2        text
9242   *----------------------------------------------------------------------*
9243   FORM DETAILS_ONDBLCLK .
9244    CALL FUNCTION 'SO_ADDRESS_SHOW'
9245      EXPORTING
9246   *     DLI_OWNER                        = ' '
9247   *     OWNER                            = ' '
9248        user                             = l_user_dblclk
9249      EXCEPTIONS
9250        parameter_error                  = 1
9251        user_not_exist                   = 2
9252        x_error                          = 3
9253        operation_no_authorization       = 4
9254        OTHERS                           = 5
9255               .
9256     IF sy-subrc <> 0.
9257   * MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
9258   *         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
9259     ENDIF.
9260   ENDFORM.                    " DETAILS_ONDBLCLK
9261   *&---------------------------------------------------------------------*
9262   *&      Form  SEND_SMS_TO_REQN
9263   *&---------------------------------------------------------------------*
9264   *       text
9265   *----------------------------------------------------------------------*
9266   *  -->  p1        text
9267   *  <--  p2        text
9268   *----------------------------------------------------------------------*
9269   FORM SEND_SMS_TO_REQN .
9270   """"""""code added by lipsy on 10.09.2013 for sending sms to requisitioner.
9271      REFRESH :IT_9205.
9272
9273       CLEAR:R_USER_SMS.
9274       SELECT SINGLE REQCPF INTO R_USER_SMS FROM ZMM_CDHD
9275       WHERE REQNO = ZMM_CDHD_ST-REQNO.
9276
9277
9278    SELECT * FROM  PA9205 APPENDING
9279         CORRESPONDING FIELDS OF TABLE IT_9205
9280         WHERE Pernr = R_USER_SMS AND
9281               Subty = '01' AND
9282               Endda = '99991231' .
9283
9284   IF SY-SUBRC = 0.          ""  PHONE NO. OF REQUIRED requisitioner HAS BEEN FOUND
9285
9286     SORT  IT_9205 By Begda DESCENDING  .
9287     CLEAR   :Wa_9205 .
9288     READ TABLE It_9205 INTO Wa_9205 INDEX 1  .
9289
9290     clear MOB_NO.
9291     CONCATENATE '91' Wa_9205-ZPHONE+1(10) INTO  MOB_NO .
9292   ******END OF FINDING PHONE NO. OF Requistioner***********************************
9293
9294   ****SENDING SMS TO requisitioner**************************************************************************
9295      CLEAR: wf_string ,  L_TEXT1 ,L_TEXT2 , L_TEXT3 , L_TEXT4 ,  L_TEXT5 .
9296
9297       L_TEXT1 = 'Material Code Request Number :'.
9298       L_TEXT2 =  ZMM_CDHD_ST-REQNO.
9299       L_TEXT3 = 'is completed.'.
9300       L_TEXT4 = 'Please'.
9301       L_TEXT5 = 'Check the request for further details. '.
9302
9303
9304          CONCATENATE L_TEXT1 L_TEXT2  L_TEXT3 L_TEXT4 L_TEXT5 INTO sms_text SEPARATED BY space.
9305       CONCATENATE
9306       'http://10.205.48.190:13013/cgi-bin/sendsms?'
9307       'username=ongc&password=ongc12&from=ONGC&to='
9308   *  919968282246+919968282468&text=Hellow+Test+4&remLen=147
9309   * 'http://www.webservicex.net/SendSMS.asmx/SendSMSToIndia?MobileNumber='
9310       mob_no "m_no
9311      '&text='
9312      sms_text
9313      '&remLen=180'
9314       INTO
9315       wf_string .
9316
9317       CALL METHOD cl_http_client=>create_by_url
9318         EXPORTING
9319           url                = wf_string
9320         IMPORTING
9321           client             = http_client
9322         EXCEPTIONS
9323           argument_not_found = 1
9324           plugin_not_active  = 2
9325           internal_error     = 3
9326           OTHERS             = 4.
9327
9328       CALL METHOD http_client->send
9329         EXCEPTIONS
9330           http_communication_failure = 1
9331           http_invalid_state         = 2.
9332
9333       CALL METHOD http_client->receive
9334         EXCEPTIONS
9335           http_communication_failure = 1
9336           http_invalid_state         = 2
9337           http_processing_failed     = 3.
9338       CLEAR result .
9339       result = http_client->response->get_cdata( ).
9340
9341       REFRESH result_tab .
9342      SPLIT result AT cl_abap_char_utilities=>cr_lf INTO TABLE result_tab.
9343   ****END OF SENDING SMS TO requistioner**************************************************************
9344   ***Added for memory overflow problem
9345      CALL METHOD http_client->close( ).
9346   ELSE.
9347     ENDIF.
9348
9349     """""""" end of addition  by lipsy on 10.09.2013 for sending sms to requisitioner RD1K982397.
9350   ENDFORM.                    " SEND_SMS_TO_REQN
9351   *&---------------------------------------------------------------------*
9352   *&      Form  GET_TEL_CREATION
9353   *&---------------------------------------------------------------------*
9354   *       text
9355   *----------------------------------------------------------------------*
9356   *  -->  p1        text
9357   *  <--  p2        text
9358   *----------------------------------------------------------------------*
9359   FORM GET_TEL_CREATION .
9360
9361   """""""""added by lipsy on 10.09.2013 for telephone no in creation mode RD1K982397.
9362
9363    if sy-tcode = 'ZMM_IMAC'.
9364    case g_mode.
9365
9366       when 'CRE'.
9367
9368         loop at screen.
9369           if screen-name = 'ZMM_CDHD_ST-TEL' .
9370             screen-input = 0.
9371             modify screen.
9372            ENDIF.
9373        ENDLOOP.
9374
9375
9376   refresh:IT_9205.
9377     SELECT * FROM  PA9205 INTO
9378      CORRESPONDING FIELDS OF TABLE IT_9205
9379      WHERE Pernr = sy-uname  AND
9380            Subty = '01' AND
9381            Endda = '99991231' .
9382
9383          IF SY-SUBRC = 0.          "" It means PHONE NO. has been found
9384
9385       SORT  IT_9205 By Begda DESCENDING .
9386
9387       CLEAR:Wa_9205.
9388       READ TABLE It_9205 INTO Wa_9205 INDEX 1  .
9389       zmm_cdhd_st-tel = Wa_9205-ZPHONE+1(10).
9390
9391        endif.
9392
9393
9394    ENDCASE.
9395
9396     endif.
9397
9398     """"""""""""END OF addition  by lipsy on 10.09.2013 for telephone no in creation mode RD1K982397.
9399
9400   ENDFORM.                    " GET_TEL_CREATION
*--- End of MZMMCODREQF01 - 9400 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CABAP                                   Level 1    Page 6
Object           SAPMZMMCODREQ                             Lines 360
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:59
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
Generated incl.  %_CCNDD                                   Level 1    Page 7
Object           SAPMZMMCODREQ                             Lines 31
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:59
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
Generated incl.  %_CCNTL                                   Level 1    Page 8
Object           SAPMZMMCODREQ                             Lines 138
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:59
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
Generated incl.  %_CCNTO                                   Level 1    Page 9
Object           SAPMZMMCODREQ                             Lines 15
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:59
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
Generated incl.  %_CCXTAB                                  Level 1    Page 10
Object           SAPMZMMCODREQ                             Lines 6
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:59
----------------------------------------------------------------------------------------------------
1      TYPE-POOL CXTAB .
2
3      TYPES:
4             CXTAB_COLUMN type scxtab_column,
5             CXTAB_CONTROL type scxtab_control,
6             CXTAB_TABSTRIP type scxtab_tabstrip.
*--- End of %_CCXTAB - 6 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CIHTTP                                  Level 1    Page 11
Object           SAPMZMMCODREQ                             Lines 527
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:59
----------------------------------------------------------------------------------------------------
1      TYPE-POOL ihttp .
2
3
4      *------------------------------------------------------------------
5      * table of registered handler class instances
6      *------------------------------------------------------------------
7      TYPES:
8              BEGIN OF ihttp_ext_instance,
9                extension  TYPE seoclsname,
10               refpointer TYPE REF TO if_http_extension,
11               url        TYPE string,
12             END   OF ihttp_ext_instance.
13
14     TYPES:
15            ihttp_ext_instances TYPE STANDARD TABLE OF ihttp_ext_instance
16                                  WITH KEY url.
17
18     " http client instances
19     TYPES:
20             BEGIN OF ihttp_client_instance,
21               name            TYPE string,
22               client          TYPE REF TO cl_abap_weak_reference,
23               state           TYPE i,
24               path_translated TYPE string, "established for MI application view and debugger (in CL_MI_SEMANTIC_TREE_ICF)
25             END   OF ihttp_client_instance.
26
27     TYPES:
28             ihttp_client_instances TYPE STANDARD TABLE OF
29                                       ihttp_client_instance WITH KEY name.
30
31     * --
32     * administration of server objects in case of
33     * local calls (CREATE_INTERNAL) and in HTTP_DISPATCH_REQUEST
34     * --
35     TYPES: BEGIN OF ihttp_local_server_instance,
36              client_name   TYPE string,
37              server        TYPE REF TO if_http_server,
38            END OF ihttp_local_server_instance.
39
40     TYPES:
41             ihttp_local_server_instances TYPE STANDARD TABLE OF
42                           ihttp_local_server_instance WITH KEY client_name.
43
44     *
45     * -- ICF recorder exchange (upload/download) types
46     *
47     TYPES:
48             BEGIN OF ihttp_recorder_action,
49               client       TYPE symandt,
50               user         TYPE syuname,
51               action       TYPE i,
52               time_stamp   TYPE timestampl,
53             END OF ihttp_recorder_action.
54
55     TYPES: ihttp_recorder_actions
56               TYPE STANDARD TABLE OF ihttp_recorder_action.
57
58     TYPES:
59             BEGIN OF ihttp_recorder_attribute,
60                type      TYPE i,
61                version   TYPE i,
62                entry     TYPE xstring,
63             END OF ihttp_recorder_attribute.
64
65     TYPES: ihttp_recorder_attributes
66                TYPE TABLE OF ihttp_recorder_attribute WITH KEY type.
67
68     * -- for recorder logon procedure (based on user/password or rfc ticket)
69     TYPES:
70             BEGIN OF ihttp_recorder_logon,
71               version        TYPE i,
72               logon_client   TYPE symandt,
73               logon_username TYPE syuname,
74               logon_password TYPE string,
75               logon_language TYPE sylangu,
76               logon_ticket   TYPE xstring,
77             END OF ihttp_recorder_logon.
78
79     CONSTANTS:
80             ihttp_recorder_x_entry_size  TYPE i VALUE 500.
81
82     TYPES:
83             BEGIN OF ihttp_recorder_x,
84                 entry(ihttp_recorder_x_entry_size)   TYPE x,
85             END   OF ihttp_recorder_x,
86
87             ihttp_recorder_x_version(1)              TYPE x.
88
89     * -- ICF Recorder runtime info
90     TYPES:
91             BEGIN OF ihttp_recorder_field,
92               range  TYPE i,
93               index  TYPE i,
94               name   TYPE string,
95               value  TYPE string,
96             END OF ihttp_recorder_field.
97
98     TYPES: ihttp_recorder_fields
99                 TYPE TABLE OF ihttp_recorder_field WITH KEY range.
100
101    TYPES:
102    * for CL_HTTP_RESPONSE (SET_COMPRESSION)
103            BEGIN OF ihttp_icfparameter,
104               compression_supported TYPE i,
105               protocol        TYPE string,
106               accept_encoding TYPE string,
107            END OF ihttp_icfparameter.
108
109    * -- cache for ICF runtime
110    TYPES:
111            BEGIN OF ihttp_rmemory_icfhandlst,
112              icfhandlst               TYPE icfhandlst,
113              header_fields            TYPE tihttpnvp,
114              script_name              TYPE string,
115              path_info                TYPE string,
116            END OF ihttp_rmemory_icfhandlst,
117
118            BEGIN OF ihttp_runtime_memory,
119              version  TYPE i,
120              host     TYPE i,
121              path     TYPE string,
122              servtbl  TYPE TABLE OF ihttp_rmemory_icfhandlst
123                                      WITH KEY script_name,
124              actlogin TYPE icflogin,
125              urlsuffix TYPE string,
126            END OF ihttp_runtime_memory.
127
128    * send last page IF_HTTP_SERVER
129    TYPES:
130           BEGIN OF ihttp_service_page,
131             kind       TYPE c,
132             header     TYPE sotr_conc,
133             body       TYPE sotr_conc,
134             redirect   TYPE string,
135             redirect_code TYPE i,
136           END OF ihttp_service_page.
137    *
138    * mapping of options/extensions for ICF service from application aoutput
139    * string into generic service string "container"
140    *
141    TYPES:
142            BEGIN OF ihttp_icfservice_extension,
143              kind       TYPE i,
144              version    TYPE i,
145              content    TYPE string,
146            END OF ihttp_icfservice_extension.
147    TYPES:
148            ihttp_icfservice_extensions TYPE STANDARD TABLE OF
149                      ihttp_icfservice_extension WITH KEY kind.
150    *
151    * mapping of authentication code to the name of the authentication method
152    *
153    TYPES:
154            BEGIN OF ihttp_authmethod_identifier,
155              code TYPE i,
156              name TYPE string,
157            END OF ihttp_authmethod_identifier.
158    TYPES:
159            ihttp_authmethod_mapping TYPE TABLE OF ihttp_authmethod_identifier
160              WITH KEY code.
161
162    *------------------------------------------------------------------
163    * constants
164    *------------------------------------------------------------------
165
166    * ICF virtual host number
167    CONSTANTS:
168      ihttp_vhost_default             TYPE i VALUE 0.
169
170    * authorization types
171    CONSTANTS:
172      ihttp_auth_type_basic_auth      TYPE i VALUE 1.
173
174    * authorization types
175    CONSTANTS:
176      ihttp_user_agent_unknown       TYPE i VALUE -1, " ?
177      ihttp_user_agent_null          TYPE i VALUE 0,  " ?
178      ihttp_user_agent_nn            TYPE i VALUE 1,  " netscape navigator
179      ihttp_user_agent_ie            TYPE i VALUE 2,  " ms internet explorer
180      ihttp_user_agent_sapwebapp     TYPE i VALUE 3,
181      ihttp_user_agent_opera         TYPE i VALUE 4,
182      ihttp_user_agent_mozilla       TYPE i VALUE 5,
183      ihttp_user_agent_mz            TYPE i VALUE 5,
184      ihttp_user_agent_safari        TYPE i VALUE 6.
185
186    * cache invalidation modes
187    CONSTANTS:
188      ihttp_inv_literal              TYPE i VALUE 0,
189      ihttp_inv_wildcard             TYPE i VALUE 1,
190      ihttp_inv_etag                 TYPE i VALUE 2.
191
192
193    * cache invalidation scope
194    CONSTANTS:
195      ihttp_inv_local                TYPE i VALUE 0,
196      ihttp_inv_global               TYPE i VALUE 1.
197
198    * use virtual host index fron request to determine the cache
199    CONSTANTS:
200      ihttp_vhost_fromreq            TYPE i value -1.
201
202    * encoding types (cl_http_utility=>string_to_fields etc.)
203    CONSTANTS:
204      ihttp_enc_none                 TYPE i VALUE 0,
205      ihttp_enc_base64               TYPE i VALUE 1,
206      ihttp_enc_url64                TYPE i VALUE 5.
207
208
209    *
210    * system-call IDs: keep in sync with krn/ict/ictxxabap.c !!!
211    *
212    CONSTANTS:
213      ihttp_scid_get_status               TYPE i VALUE  1,
214      ihttp_scid_set_status               TYPE i VALUE  2,
215      ihttp_scid_add_multipart            TYPE i VALUE  3,
216      ihttp_scid_append_cdata             TYPE i VALUE  4,
217      ihttp_scid_append_data              TYPE i VALUE  5,
218      ihttp_scid_get_cdata                TYPE i VALUE  6,
219      ihttp_scid_get_cookie               TYPE i VALUE  7,
220      ihttp_scid_get_data                 TYPE i VALUE  8,
221      ihttp_scid_get_form_field           TYPE i VALUE  9,
222      ihttp_scid_get_form_fields          TYPE i VALUE 10,
223      ihttp_scid_get_header_field         TYPE i VALUE 11,
224      ihttp_scid_get_header_fields        TYPE i VALUE 12,
225      ihttp_scid_get_multipart            TYPE i VALUE 13,
226      ihttp_scid_instantiate              TYPE i VALUE 14,
227      ihttp_scid_num_multiparts           TYPE i VALUE 15,
228      ihttp_scid_serialize                TYPE i VALUE 16,
229      ihttp_scid_set_cdata                TYPE i VALUE 17,
230      ihttp_scid_add_cookie               TYPE i VALUE 18,
231      ihttp_scid_set_data                 TYPE i VALUE 19,
232      ihttp_scid_add_form_field           TYPE i VALUE 20,
233      ihttp_scid_add_form_fields          TYPE i VALUE 21,
234      ihttp_scid_add_header_field         TYPE i VALUE 22,
235      ihttp_scid_add_header_fields        TYPE i VALUE 23,
236      ihttp_scid_create_message           TYPE i VALUE 24,
237      ihttp_scid_delete_message           TYPE i VALUE 25,
238      ihttp_scid_remove_header_field      TYPE i VALUE 26,
239      ihttp_scid_remove_cookie            TYPE i VALUE 27,
240      ihttp_scid_get_message_data         TYPE i VALUE 28,
241      ihttp_scid_get_cookie_field         TYPE i VALUE 30,
242      ihttp_scid_add_cookie_field         TYPE i VALUE 31,
243      ihttp_scid_remove_form_field        TYPE i VALUE 32,
244      ihttp_scid_get_authorization        TYPE i VALUE 33,
245      ihttp_scid_url_escape               TYPE i VALUE 34,
246      ihttp_scid_url_unescape             TYPE i VALUE 35,
247      ihttp_scid_html_escape              TYPE i VALUE 36,
248      ihttp_scid_base64_escape            TYPE i VALUE 37,
249      ihttp_scid_base64_unescape          TYPE i VALUE 38,
250      ihttp_scid_set_authorization        TYPE i VALUE 39,
251      ihttp_scid_str_to_field_list        TYPE i VALUE 40,
252      ihttp_scid_field_list_to_str        TYPE i VALUE 41,
253      ihttp_scid_get_user_agent           TYPE i VALUE 46,
254      ihttp_scid_get_cookies              TYPE i VALUE 48,
255      ihttp_scid_get_uri_parameter        TYPE i VALUE 49,
256      ihttp_scid_append_cdata2            TYPE i VALUE 50,
257      ihttp_scid_get_form_field_cs        TYPE i VALUE 51,
258      ihttp_scid_get_form_fields_cs       TYPE i VALUE 53,
259      ihttp_scid_compress_data            TYPE i VALUE 54,
260      ihttp_scid_compress_supported       TYPE i VALUE 56,
261      ihttp_scid_get_proto_version        TYPE i VALUE 57,
262      ihttp_scid_del_hfield_secure        TYPE i VALUE 60,
263      ihttp_scid_del_cookie_secure        TYPE i VALUE 61,
264      ihttp_scid_del_ffield_secure        TYPE i VALUE 62,
265      ihttp_scid_suppr_content_type       TYPE i VALUE 63,
266      ihttp_scid_call_is_implemented      TYPE i VALUE 64,
267      ihttp_scid_copy_message             TYPE i VALUE 65,
268      ihttp_scid_get_request_method       TYPE i VALUE 66,
269      ihttp_scid_get_message_length       TYPE i VALUE 67,
270      ihttp_scid_get_content_type         TYPE i VALUE 68,
271      ihttp_scid_set_proto_version        TYPE i VALUE 69,
272      ihttp_scid_set_request_method       TYPE i VALUE 70,
273      ihttp_scid_set_content_type         TYPE i VALUE 72,
274      ihttp_scid_get_serialized_leng      TYPE i VALUE 73,
275      ihttp_scid_http_redirect            TYPE i VALUE 74,
276      ihttp_scid_get_data2                TYPE i VALUE 76,
277      ihttp_scid_get_data_length          TYPE i VALUE 77,
278      ihttp_scid_url_escape_2             TYPE i VALUE 78,
279      ihttp_scid_url_unescape_2           TYPE i VALUE 79,
280      ihttp_scid_html_escape2             TYPE i VALUE 80,
281      ihttp_scid_crc32_checksum           TYPE i VALUE 81,
282      ihttp_scid_set_request_message      TYPE i VALUE 82,
283      ihttp_scid_jscript_escape           TYPE i VALUE 83,
284      ihttp_scid_url_normalize            TYPE i VALUE 84,
285      ihttp_scid_check_uri                TYPE i VALUE 85,
286      ihttp_scid_base64_escape_x          TYPE i VALUE 86,
287      ihttp_scid_base64_unescape_x        TYPE i VALUE 87,
288      ihttp_scid_get_form_field_2         TYPE i VALUE 90,
289      ihttp_scid_get_form_fields_2        TYPE i VALUE 91,
290      ihttp_scid_suppr_content_len        TYPE i VALUE 92,
291      ihttp_scid_url_path_escape          TYPE i VALUE 93,
292      ihttp_scid_xmlhtml_escape_xss       TYPE i VALUE 94,
293      ihttp_scid_jscript_escape_xss       TYPE i VALUE 95,
294      ihttp_scid_url_escape_xss           TYPE i VALUE 96,
295      ihttp_scid_css_escape_xss           TYPE i VALUE 97,
296      ihttp_scid_instname_encode          TYPE i VALUE 98,
297      ihttp_scid_serialize_with_opt       TYPE i VALUE 99,
298      ihttp_scid_str_to_cookie_hash       TYPE i VALUE 100,
299      ihttp_scid_suppr_charset            TYPE i VALUE 101,
300      ihttp_scid_suppr_f_fields_body      TYPE i VALUE 102,
301      ihttp_scid_preserve_mp_boundry      TYPE i VALUE 103,
302      ihttp_scid_get_serversentevent      TYPE i VALUE 104.
303    *
304    * return code for non-existing (ICT_ENOTIMPL) syscalls
305    *
306    CONSTANTS:
307      ihttp_syscall_not_implemented       TYPE i VALUE 4.
308
309    * option for IF_HTTP_UTILITY~ESCAPE_HTML parameter KEEP_NUM_CHAR_REF
310    * if set, HTML numeric character references are not escaped.
311    * if HTML_ESCAPE_ATTRIBUTE the character = is also escaped.
312    * The option JSCRIPT_ESCAPE_IN_HTML is for IF_HTTP_UTILITY~ESCAPE_JAVASCRIPT
313    CONSTANTS:
314      ihttp_keep_num_char_ref             TYPE i VALUE 1,
315      ihttp_html_escape_attribute         TYPE i VALUE 2,
316      ihttp_jscript_escape_in_html        TYPE i VALUE 4.
317
318    * options for serialize (not exposed to application)
319    * see krn/ict/ictxxabap.c for details
320    CONSTANTS:
321      ihttp_serialize_tilde_fld           TYPE i VALUE 1,
322      ihttp_serialize_hide_sensitive      TYPE i VALUE 2,
323      ihttp_serialize_header_only         TYPE i VALUE 4.
324
325    * -- icf recorder constants
326
327    CONSTANTS: ihttp_c_timezone_utc         TYPE tznzone VALUE IS INITIAL.
328
329    CONSTANTS:
330      ihttp_start_modify_record             TYPE i VALUE 1, " enqueue step
331      ihttp_cont_modify_record              TYPE i VALUE 2, " continue modi.
332      ihttp_canc_modify_record              TYPE i VALUE 3, " cancel modi.
333      ihttp_end_modify_record               TYPE i VALUE 4, " dequeue step
334      ihttp_show_record                     TYPE i VALUE 5,
335      ihttp_show_failed_logon_record        TYPE i VALUE 6,
336      ihttp_delete_record                   TYPE i VALUE 7,
337      ihttp_execute_record_request          TYPE i VALUE 8,
338      ihttp_execute_record_request_o        TYPE i VALUE 9, "origin exec.
339      ihttp_execute_record_request_l        TYPE i VALUE 10,"local exec.
340      ihttp_download_record                 TYPE i VALUE 11,
341      ihttp_upload_record                   TYPE i VALUE 12,
342      ihttp_activate_protocol_action        TYPE i VALUE 13,
343      ihttp_copy_record                     TYPE i VALUE 14,
344      ihttp_delete_recorder_client          TYPE i VALUE 15,
345      ihttp_start_admin_record              TYPE i VALUE 16, " enqueue step
346      ihttp_cont_admin_record               TYPE i VALUE 17, " continue modi
347      ihttp_canc_admin_record               TYPE i VALUE 18, " cancel modi.
348      ihttp_end_admin_record                TYPE i VALUE 19, " dequeue step
349      ihttp_show_protocol_record            TYPE i VALUE 20. " dequeue step
350
351
352    CONSTANTS:
353       ihttp_recorder_attrib_version     TYPE  i VALUE 1,
354       ihttp_recorder_attrib_action      TYPE  i VALUE 2,
355       ihttp_recorder_attrib_logon       TYPE  i VALUE 3,
356       ihttp_recorder_attrib_fields      TYPE  i VALUE 4.
357
358    * -- recorder level for ICF server
359    CONSTANTS:
360       ihttp_record_playback              TYPE  i VALUE -100,
361       ihttp_record_failed_auth           TYPE  i VALUE 1,
362       ihttp_record_request_status        TYPE  i VALUE 2,
363       ihttp_record_request               TYPE  i VALUE 3,
364       ihttp_record_response_status       TYPE  i VALUE 4,
365       ihttp_record_response              TYPE  i VALUE 5,
366       ihttp_record_last_possibility      TYPE  i VALUE 6,
367       ihttp_record_with_cookie           TYPE  i VALUE 100.
368
369    * -- recorder level for ICF client
370    CONSTANTS:
371       ihttp_record_crequest_status       TYPE  i VALUE 1,
372       ihttp_record_crequest              TYPE  i VALUE 2,
373       ihttp_record_cresponse_status      TYPE  i VALUE 3,
374       ihttp_record_cresponse             TYPE  i VALUE 4,
375       ihttp_record_clast_possibility     TYPE  i VALUE 5.
376
377    *constants:
378    *   ihttp_record_accept_cookie_id      type  i value -100,
379    *   ihttp_record_send_cookie_id        type  i value -200.
380
381    CONSTANTS:
382    * LOGON
383       ihttp_recorder_status_logon      TYPE  icfstatus VALUE '1',
384    * DOWNLOAD
385       ihttp_recorder_status_download   TYPE  icfstatus VALUE '2',
386    * UPLOAD
387       ihttp_recorder_status_upload     TYPE  icfstatus VALUE '4',
388    * COPY
389       ihttp_recorder_status_copy       TYPE  icfstatus VALUE '10'.
390
391    CONSTANTS:
392       ihttp_recorder_client_oblig   TYPE  icfrecoder_lmethod VALUE '1',
393       ihttp_recorder_client_hfield  TYPE  icfrecoder_lmethod VALUE '2',
394       ihttp_recorder_client_ffield  TYPE  icfrecoder_lmethod VALUE '3',
395       ihttp_recorder_client_context TYPE  icfrecoder_lmethod VALUE '4',
396       ihttp_recorder_client_service TYPE  icfrecoder_lmethod VALUE '5',
397       ihttp_recorder_client_server  TYPE  icfrecoder_lmethod VALUE '6'.
398
399    CONSTANTS:
400       ihttp_recorder_langu_oblig   TYPE  icfrecoder_lmethod VALUE '1',
401       ihttp_recorder_langu_hfield  TYPE  icfrecoder_lmethod VALUE '2',
402       ihttp_recorder_langu_ffield  TYPE  icfrecoder_lmethod VALUE '3',
403       ihttp_recorder_langu_context TYPE  icfrecoder_lmethod VALUE '4',
404       ihttp_recorder_langu_service TYPE  icfrecoder_lmethod VALUE '5',
405       ihttp_recorder_langu_server  TYPE  icfrecoder_lmethod VALUE '6',
406       ihttp_recorder_langu_accept  TYPE  icfrecoder_lmethod VALUE '7',
407       ihttp_recorder_langu_slogin  TYPE  icfrecoder_lmethod VALUE '8'.
408
409
410    CONSTANTS:
411       ihttp_recorder_user_oblig   TYPE  c VALUE '1',
412       ihttp_recorder_user_hfield  TYPE  c VALUE '2',
413       ihttp_recorder_user_ffield  TYPE  c VALUE '3',
414       ihttp_recorder_user_service TYPE  c VALUE '4',
415       ihttp_recorder_user_bauth   TYPE  c VALUE '5',
416       ihttp_recorder_auser_hfield TYPE  c VALUE '6',
417       ihttp_recorder_auser_ffield TYPE  c VALUE '7',
418       ihttp_recorder_auser_bauth  TYPE  c VALUE '8'.
419
420    CONSTANTS:
421       ihttp_recorder_passwd_oblig   TYPE  c VALUE '1',
422       ihttp_recorder_passwd_hfield  TYPE  c VALUE '2',
423       ihttp_recorder_passwd_ffield  TYPE  c VALUE '3',
424       ihttp_recorder_passwd_service TYPE  c VALUE '4',
425       ihttp_recorder_passwd_bauth   TYPE  c VALUE '5'.
426
427    CONSTANTS:
428       ihttp_recorder_bauth_ticket  TYPE c VALUE '1',
429       ihttp_recorder_sso_ticket    TYPE c VALUE '2',
430       ihttp_recorder_ssorej_ticket TYPE c VALUE '3',
431       ihttp_recorder_r3auth_ticket TYPE c VALUE '4',
432       ihttp_recorder_x509_ticket   TYPE c VALUE '5',
433       ihttp_recorder_saml_ticket   TYPE c VALUE '6',
434       ihttp_recorder_oauth2_ticket TYPE c VALUE '7',
435       ihttp_recorder_spnego_ticket TYPE c VALUE '8'.
436
437    CONSTANTS:
438       ihttp_recorder_break_token   TYPE icfchar4 VALUE '=',
439       ihttp_recorder_tickets_token TYPE icfchar4 VALUE '-T:',
440       ihttp_recorder_auth_token    TYPE icfchar4 VALUE '-a:',
441       ihttp_recorder_user_token    TYPE icfchar4 VALUE '-u:',
442       ihttp_recorder_users_token   TYPE icfchar4 VALUE '-U:',
443       ihttp_recorder_passwds_token TYPE icfchar4 VALUE '-P:',
444       ihttp_recorder_client_token  TYPE icfchar4 VALUE '-c:',
445       ihttp_recorder_clients_token TYPE icfchar4 VALUE '-C:',
446       ihttp_recorder_langu_token   TYPE icfchar4 VALUE '-l:',
447       ihttp_recorder_langus_token  TYPE icfchar4 VALUE '-L:',
448       ihttp_recorder_subrc_token   TYPE icfchar4 VALUE '-r:',
449       ihttp_recorder_saprc_token   TYPE icfchar4 VALUE '-R:'.
450
451    CONSTANTS:
452    * -- E: for upload/download messages
453       ihttp_recorder_ext_message_e  TYPE icfexternal_message VALUE 'E'.
454
455    CONSTANTS:
456       ihttp_recorder_message_type_i  TYPE icfmsgtype VALUE 'I',
457       ihttp_recorder_exp_mstype      TYPE icfmsgtype VALUE 'A'.
458
459    CONSTANTS:
460       ihttp_recorder_exp_mandt TYPE symandt         VALUE '000',
461       ihttp_recorder_exp_msgid TYPE icfrecoder_uuid VALUE 'FFFF',
462       ihttp_icf_admin_msgid    TYPE icfrecoder_uuid VALUE 'AAAA'.
463
464    CONSTANTS:
465      ihttp_recorder_role_sextern     TYPE char2 VALUE 'SE',
466      ihttp_recorder_role_slocal      TYPE char2 VALUE 'SL',
467      ihttp_recorder_role_cextern     TYPE char2 VALUE 'CE',
468      ihttp_recorder_role_clocal      TYPE char2 VALUE 'CL'.
469
470    CONSTANTS:
471       ihttp_recorder_exp_date_basis TYPE sydatum VALUE '20010101',
472       ihttp_recorder_def_exp_day    TYPE i VALUE 30, "-> ~ 1 Month
473       ihttp_recorder_def_exp_time   TYPE syuzeit VALUE '000000'.
474
475    CONSTANTS:
476       ihttp_recorder_protocol_http  TYPE c       VALUE '1',
477       ihttp_recorder_protocol_https TYPE c       VALUE '2'.
478
479    * -- Taskhandler performance (perfinterval)
480    CONSTANTS: ihttp_opcode_open_interval     TYPE x VALUE 17,
481               ihttp_opcode_close_interval    TYPE x VALUE 18.
482
483
484    *
485    * Header, Form and Cookie Fields used in ICF
486    *
487    CONSTANTS:
488      ihttp_c_sap_recorder     TYPE string VALUE 'sap-recorder',
489      ihttp_c_sap_recorder_sid TYPE string VALUE 'sap-recorder_sid',
490      ihttp_c_sap_recorder_aut TYPE string VALUE 'sap-rauth'.
491
492    *
493    * Maximum number of recorder entries per user account
494    * Maximum number of failed logon entries per client
495    *
496    CONSTANTS:
497      ihttp_recorder_max_usr_entries  TYPE i VALUE 100,
498      ihttp_recorder_max_log_entries  TYPE i VALUE 500.
499
500    * icf service extension kindes
501    CONSTANTS:
502      ihttp_icfservice_extension_its  TYPE i VALUE 1,
503      ihttp_icfservice_extension_bsp  TYPE i VALUE 2,
504      ihttp_icfservice_extension_sam  TYPE i VALUE 3. "saml logon procedure
505
506
507    CONSTANTS:
508      ihttp_icfservice_action_pack    TYPE i VALUE 1,
509      ihttp_icfservice_action_unpack  TYPE i VALUE 2.
510
511    CONSTANTS:
512      ihttp_recorder_field_range_loc   TYPE i VALUE 1, "locale information
513      ihttp_recorder_field_range_exe   TYPE i VALUE 2, "execute_request
514      ihttp_recorder_field_range_cck   TYPE i VALUE 3, "client cookie
515      ihttp_recorder_field_range_clo   TYPE i VALUE 4, "client logon popup
516      ihttp_recorder_field_range_cre   TYPE i VALUE 5, "client redirect
517      ihttp_recorder_field_range_col   TYPE i VALUE 6, "client obj. length
518      ihttp_recorder_field_range_sol   TYPE i VALUE 7. "server obj. length
519
520    CONSTANTS:
521      ihttp_recorder_field_name_ext   TYPE char32 VALUE 'IF_HTTP_EXTENSION',
522      ihttp_recorder_field_name_ccoo  TYPE char32
523                                      VALUE 'PROPERTYTYPE_ACCEPT_COOKIE'.
524
525    *
526    * /system-call IDs: keep in sync with krn/ict/ictxxabap.c !!!
527    *
*--- End of %_CIHTTP - 527 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_COLE2                                   Level 1    Page 12
Object           SAPMZMMCODREQ                             Lines 43
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:59
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
Generated incl.  %_CSFES                                   Level 1    Page 13
Object           SAPMZMMCODREQ                             Lines 75
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:59
----------------------------------------------------------------------------------------------------
1      TYPE-POOL SFES .
2
3      *--table structure definition for mapping xml content after parsing
4
5        TYPES SFES_OBJ_TYPE(32) TYPE C.
6        TYPES:
7          begin of sfes_features_record_type,
8            component(30) type c,
9            featurename(30) type c,
10           value(30) type c,
11       end of sfes_features_record_type.
12       TYPES sfes_features_tab_type type table of sfes_features_record_type with non-unique key component.
13
14
15     CONSTANTS:
16       SFES_OBJ_ACTIVEX
17         TYPE SFES_OBJ_TYPE
18         VALUE 'ACTX',
19       SFES_OBJ_JAVABEANS
20         TYPE SFES_OBJ_TYPE
21         VALUE 'JBEAN',
22       SFES_OBJ_OLE
23         TYPE SFES_OBJ_TYPE
24         VALUE 'OLE',
25       SFES_OBJ_SAP
26         TYPE SFES_OBJ_TYPE
27         VALUE 'SAP',
28       SFES_OBJ_HTML
29         TYPE SFES_OBJ_TYPE
30         VALUE 'HTML'.
31
32     * Constants for GUI_GET_DESKTOP_INFO
33     CONSTANTS:
34       SFES_INFO_SAPDIR
35         TYPE I
36         VALUE -1,
37       SFES_INFO_SAPSYSDIR
38         TYPE I
39         VALUE -2,
40       SFES_INFO_COMPUTER_NAME
41         TYPE I
42         VALUE 1,
43       SFES_INFO_WINDOWS_DIRECTORY
44         TYPE I
45         VALUE 2,
46       SFES_INFO_SYSTEM_DIRECTORY
47         TYPE I
48         VALUE 3,
49       SFES_INFO_TEMP_DIRECTORY
50         TYPE I
51         VALUE 4,
52       SFES_INFO_USER_NAME
53         TYPE I
54         VALUE 5,
55       SFES_INFO_WINDOWS_PLATFORM
56         TYPE I
57         VALUE 6,
58       SFES_INFO_WINDOWS_BUILDNO
59         TYPE I
60         VALUE 7,
61       SFES_INFO_WINDOWS_VERSION
62         TYPE I
63         VALUE 8,
64       SFES_INFO_PROGRAM_NAME
65         TYPE I
66         VALUE 9,
67       SFES_INFO_PROGRAM_PATH
68         TYPE I
69         VALUE 10,
70       SFES_INFO_CURRENT_DIRECTORY
71         TYPE I
72         VALUE 11,
73       SFES_INFO_DESKTOP_DIRECTORY
74         TYPE I
75         VALUE 12.
*--- End of %_CSFES - 75 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CTXTED                                  Level 1    Page 14
Object           SAPMZMMCODREQ                             Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:59
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
Generated incl.  <CONTRO>                                  Level 1    Page 15
Object           SAPMZMMCODREQ                             Lines 76
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:59
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
Generated incl.  <SYSINI>                                  Level 1    Page 16
Object           SAPMZMMCODREQ                             Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:59
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
Generated incl.  CL_GUI_EASY_SPLITTER_CONTAINERCU          Level 1    Page 17
Object           SAPMZMMCODREQ                             Lines 38
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:13:59
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
