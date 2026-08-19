----------------------------------------------------------------------------------------------------
Main program     ZEYTDS_INV_EXTRACT                        Level 0    Page 1
Object           ZEYTDS_INV_EXTRACT                        Lines 40
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:37
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *& Report ZEYDIGI_INV_EXTRACT_NEW
3      *&---------------------------------------------------------------------*
4      *&
5      *&---------------------------------------------------------------------*
6      REPORT ZEYTDS_INV_EXTRACT.
7
8      INCLUDE ZEYTDS_INV_EXTRACT_TOP.
9
10     INCLUDE ZEYTDS_INV_EXTRACT_SEL.
11
12     INCLUDE ZEYTDS_INV_EXTRACT_F01.
13
14     START-OF-SELECTION.
15
16       PERFORM DYNAMIC_FISCAL_YEAR.    "Fiscal year changes
17
18       IF R_FILE = 'X'.                     "Download option
19         IF R_LIVE = 'X'.
20           PERFORM GENERATE_INVOICE_DATA.
21         ELSEIF R_STG = 'X'.
22           PERFORM GET_DATA_FROM_TABLE.
23         ENDIF.
24         PERFORM DISPLAY_ALV_REPORT.
25
26       ELSEIF R_BACKUP = 'X'.               " Update staging option
27         PERFORM GENERATE_INVOICE_DATA.
28         PERFORM UPDATE_STAGING_TABLE.
29
30       ELSEIF R_RPT = 'X'. " Display report option
31         IF R_STG <> 'X'.
32           PERFORM GENERATE_INVOICE_DATA.
33         ELSE.
34           PERFORM GET_DATA_FROM_TABLE.
35         ENDIF.
36         PERFORM DISPLAY_ALV_REPORT.
37
38       ELSEIF R_DEL = 'X'.                   " Delete staging table data
39         PERFORM DELETE_STAGING_TABLE.
40       ENDIF.
*--- End of ZEYTDS_INV_EXTRACT - 40 lines ---

----------------------------------------------------------------------------------------------------
Include          ZEYTDS_INV_EXTRACT_TOP                    Level 1    Page 2
Object           ZEYTDS_INV_EXTRACT                        Lines 668
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:37
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&  Include           ZEYDIGI_INV_EXTRACT_TOP_NEW
3      *&---------------------------------------------------------------------*
4
5      TYPE-POOLS SLIS.
6      DATA : LV_BELNR TYPE BELNR_D,
7             LV_BUKRS TYPE BUKRS,
8             LV_CPUDT TYPE BKPF-CPUDT,
9             LV_LIFNR TYPE BKPF-CPUDT.
10
11     TYPES :BEGIN OF TY_FINAL_TDS,
12              BUKRS1              TYPE  BUKRS,
13              BELNR               TYPE  BELNR_D,
14              GJAHR               TYPE  GJAHR,
15              BUZEI               TYPE BUZEI,
16              BUDAT               TYPE BUDAT,
17              CR_DATE             TYPE BUDAT,
18              BUPLA               TYPE BUPLA,
19              SOURCE_ID           TYPE  ZEYTDS_SOURCE_ID,
20              SOURCE_FIL          TYPE  ZEYTDS_SOURCE_FIL,
21              COMPANY_CODE        TYPE CHAR4,        "Deductor Code
22              COMPANY_TXT         TYPE CHAR70,        "Deductor Name
23              DOCUMENT_NUMB       TYPE CHAR10,
24              DEDUCTOR_PAN        TYPE   CHAR11,
25              DEDUCTOR_TAN        TYPE   CHAR11,
26              DEDUCTOR_GSTN       TYPE   CHAR18,
27              DEDUCTEE_CODE       TYPE   CHAR12,
28              NAME_OF_DEDUCTEE    TYPE   CHAR70,
29              DEDUCTEE_PAN        TYPE   CHAR40,
30              DEDUCTEE_GSTN       TYPE   CHAR18,
31              VEND_INV_NUM        TYPE  CHAR20,
32              DOCUMENTDATE        TYPE  CHAR10,
33              ERP_NUM             TYPE  CHAR10,
34              POST_DAT_DOCU       TYPE   CHAR10,
35              SUPPLY_TYPE         TYPE   CHAR10,
36              DOCUMENTTYPE        TYPE   CHAR12,
37              ERP_DOC_TYPE        TYPE  CHAR15,
38              LINENUMBER          TYPE   CHAR14,
39              HSN_SAC_CODE(16)    TYPE  C,
40              HSN_SAC_DES         TYPE  CHAR70,
41              SERVICE_DES_INV     TYPE   CHAR50,
42              GL_ACC_CODE         TYPE  CHAR13,
43              GL_ACC_NAME         TYPE  CHAR50,
44              PO_NUMBER           TYPE  CHAR10,
45              PO_DATE             TYPE  CHAR10,
46              PO_DESC             TYPE   CHAR40,
47              TAXABLEVALUE        TYPE   DMBTR,
48              IGSTRATE            TYPE   KBETR,
49              IGSTAMOUNT          TYPE ZEYTDS_INV_EXT1-IGSTAMOUNT,
50              CGSTRATE            TYPE   KBETR,
51              CGSTAMOUNT          TYPE   HWSTE,
52              SGSTRATE            TYPE  KBETR,
53              SGSTAMOUNT          TYPE  HWSTE,
54              CESSRATE            TYPE  KBETR,
55              CESSAMOUNT          TYPE   HWSTE,
56              POS                 TYPE CHAR25,
57              TDS_TAX_CODE_ERP    TYPE  CHAR13,
58              TDS_SECTION         TYPE   CHAR15,
59              TDS_RATE            TYPE  WITH_ITEM-QSATZ,
60              TDS_AMOUNT(13)      TYPE  P DECIMALS 5,
61              CHAL_PAID_FLAG      TYPE  CHAR15,
62              CHAL_PAID_DATE      TYPE  CHAR10,
63              GROSS_UP_IND        TYPE  CHAR16,
64              ORG_DOC_NUM         TYPE   CHAR22,
65              ORG_DOC_DATE        TYPE   CHAR10,
66              XREF3               TYPE   CHAR30,
67              USER1               TYPE CHAR50,
68              USER_1              TYPE CHAR17,
69              USER2               TYPE CHAR50,
70              USER3               TYPE CHAR50,
71              BUSINESS_PLACE      TYPE  CHAR14,
72              BUSINESS_AREA       TYPE   CHAR13,
73              TDS_BASE_VAL(13)    TYPE  P DECIMALS 5,
74              TRANS_TYPE          TYPE   CHAR19,
75              GR_IR_VAL           TYPE   CHAR11,
76              OTHER_EXP_VAL       TYPE  CHAR22,
77              ASSIGN_NUM          TYPE  CHAR20,
78              PO_LINE_ITEM        TYPE  CHAR15,      "PO Item No.
79              DEB_CRED_IND        TYPE  CHAR22,
80              PLANT               TYPE   CHAR5,
81              PROFIT_CENTER       TYPE  CHAR13,
82              USERNAME            TYPE  CHAR20,
83              AMOUNT              TYPE  BSEG-WRBTR,    " hwste,
84              EXCH_RATE(13)       TYPE  P DECIMALS 5,
85              CURRENCY            TYPE  WAERS,
86              ITEM_CODE           TYPE  CHAR40,
87              INVOICE_VAL         TYPE  WRBTR,
88              NRINDICATOR         TYPE CHAR2,
89              GROSSUPINDICATOR    TYPE CHAR2,
90              TDSREMITTANCEDATE   TYPE CHAR15,
91              USER4               TYPE CHAR50,
92              USER5               TYPE CHAR17,
93              USER6               TYPE CHAR17,
94              USER7               TYPE CHAR17,
95              USER8               TYPE CHAR17,
96              USER9               TYPE CHAR17,
97              USER10              TYPE CHAR17,
98              SECCO               TYPE CHAR04,
99              CRED_YN             TYPE CHAR5,
100             NON_RES_DECUCTEE    TYPE CHAR25,
101             DEDUCTEE_ADD        TYPE CHAR120,
102             SERVICE_DES_GLTXT   TYPE CHAR50,
103             SERVICE_DES_PO      TYPE CHAR50,
104             SAC_DEC             TYPE CHAR50,
105             ACCOUNT_SEQ         TYPE CHAR5,
106             SHKZG               TYPE CHAR2,
107             FLAG                TYPE CHAR1,
108             BLART_CR            TYPE BKPF-BLART,
109             TDS_TAX             TYPE CHAR20,
110             RCM                 TYPE CHAR20,
111             GST_DEDU            TYPE CHAR20,
112             TRANS               TYPE CHAR20,
113             TRANS_CODE          TYPE CHAR20,
114             EXEMP_RATE          TYPE CHAR20,
115             ITEM_CAT            TYPE CHAR20,
116             TXGRP               TYPE BSEG-TXGRP,
117             EXEMP_NUM           TYPE CHAR20,
118             VAL                 TYPE CHAR35,
119             VAL2                TYPE CHAR35,
120             FLAG2               TYPE FLAG,
121             FLAG3               TYPE FLAG,
122             SECTIONCODE         TYPE CHAR30,
123             TANPARA             TYPE CHAR30,
124             RETURN_PERIOD(6)    TYPE C,
125             ITC_ELIGBLTY_IND(2) TYPE C,
126             CUSTOM_DUTY         TYPE BSEG-DMBTR,
127             AVAIL_CGST          TYPE HWSTE,
128             AVAIL_SGST          TYPE HWSTE,
129             AVAIL_IGST          TYPE HWSTE,
130             AVAIL_CESS          TYPE HWSTE,
131             CIF_VALUE           TYPE ZEYTDS_INV_EXT_N-CIF_VALUE,
132           END OF TY_FINAL_TDS,
133
134           BEGIN OF TY_PRO,
135             BUKRS        TYPE  BUKRS,
136             BELNR        TYPE  BELNR_D,
137             GJAHR        TYPE  GJAHR,
138             TAXABLEVALUE TYPE  DMBTR,
139             IGSTRATE     TYPE  KBETR,
140             IGSTAMOUNT   TYPE  ZEYTDS_INV_EXT_N-IGSTAMOUNT,
141             CGSTRATE     TYPE  KBETR,
142             CGSTAMOUNT   TYPE  HWSTE,
143             SGSTRATE     TYPE  KBETR,
144             SGSTAMOUNT   TYPE  HWSTE,
145             TXGRP        TYPE  BSEG-TXGRP,
146             CNT          TYPE  NUMC4,
147           END OF TY_PRO,
148
149           BEGIN OF TY_PRO2,
150             BUKRS            TYPE  BUKRS,
151             BELNR            TYPE  BELNR_D,
152             GJAHR            TYPE  GJAHR,
153             TDS_AMOUNT(13)   TYPE  P DECIMALS 5,
154             TDS_BASE_VAL(13) TYPE  P DECIMALS 5,
155           END OF TY_PRO2,
156
157           BEGIN OF TY_PRO3,
158             BUKRS        TYPE  BUKRS,
159             BELNR        TYPE  BELNR_D,
160             GJAHR        TYPE  GJAHR,
161             TAXABLEVALUE TYPE  BSEG-DMBTR,
162           END OF TY_PRO3,
163
164           BEGIN OF TY_HEAD,
165             HEAD(4096) TYPE C,
166           END OF TY_HEAD,
167           TTY_HEAD TYPE STANDARD TABLE OF TY_HEAD,
168
169           BEGIN OF TY_BSEG,
170             BUKRS     TYPE BKPF-BUKRS,
171             BELNR     TYPE BKPF-BELNR,
172             GJAHR     TYPE BKPF-GJAHR,
173             BLART     TYPE BKPF-BLART,
174             BLDAT     TYPE BKPF-BLDAT,
175             BUDAT     TYPE BKPF-BUDAT,
176             CPUDT     TYPE BKPF-CPUDT,
177             USNAM     TYPE BKPF-USNAM,
178             TCODE     TYPE BKPF-TCODE,
179             XBLNR     TYPE BKPF-XBLNR,
180             STBLG     TYPE BKPF-STBLG,
181             STJAH     TYPE BKPF-STJAH,
182             WAERS     TYPE BKPF-WAERS,
183             KURSF     TYPE BKPF-KURSF,
184             AWKEY     TYPE BKPF-AWKEY,
185             XREVERSAL TYPE BKPF-XREVERSAL,
186             BUZEI     TYPE BSEG-BUZEI,
187             BUZID     TYPE BSEG-BUZID,
188             KOART     TYPE BSEG-KOART,
189             UMSKZ     TYPE BSEG-UMSKZ,
190             SHKZG     TYPE BSEG-SHKZG,
191             GSBER     TYPE BSEG-GSBER,
192             MWSKZ     TYPE BSEG-MWSKZ,
193             DMBTR     TYPE BSEG-DMBTR,
194             WRBTR     TYPE BSEG-WRBTR,
195             TXGRP     TYPE BSEG-TXGRP,
196             TAXPS     TYPE BSEG-TAXPS,
197             KTOSL     TYPE BSEG-KTOSL,
198             KOSTL     TYPE BSEG-KOSTL,
199             SAKNR     TYPE BSEG-SAKNR,
200             HKONT     TYPE BSEG-HKONT,
201             LIFNR     TYPE BSEG-LIFNR,
202             REBZG     TYPE BSEG-REBZG,
203             REBZJ     TYPE BSEG-REBZJ,
204             MATNR     TYPE BSEG-MATNR,
205             WERKS     TYPE BSEG-WERKS,
206             EBELN     TYPE BSEG-EBELN,
207             EBELP     TYPE BSEG-EBELP,
208             SECCO     TYPE BSEG-SECCO,
209             PRCTR     TYPE BSEG-PRCTR,
210             BUPLA     TYPE BSEG-BUPLA,
211             PLC_SUP   TYPE BSEG-PLC_SUP,
212             HSN_SAC   TYPE BSEG-HSN_SAC,
213             SGTXT     TYPE BSEG-SGTXT,
214             VORGN     TYPE VORGN,
215             XREF3     TYPE BSEG-XREF3,
216             SKFBT     TYPE BSEG-SKFBT,
217             GVTYP     TYPE BSEG-GVTYP,
218             UMSKS     TYPE BSEG-UMSKS,
219             XNEGP     TYPE BSEG-XNEGP,
220             ZUONR     TYPE BSEG-ZUONR,
221             ZEKKN     TYPE BSEG-ZEKKN,
222           END OF TY_BSEG,
223
224           BEGIN OF TY_BKPF,
225             BUKRS     TYPE BUKRS,
226             BELNR     TYPE BELNR_D,
227             GJAHR     TYPE GJAHR,
228             BLART     TYPE BLART,
229             BLDAT     TYPE BLDAT,
230             BUDAT     TYPE BUDAT,
231             CPUDT     TYPE CPUDT,
232             TCODE     TYPE TCODE,
233             XBLNR     TYPE XBLNR,
234             STBLG     TYPE STBLG,
235             STJAH     TYPE STJAH,
236             WAERS     TYPE WAERS,
237             KURSF     TYPE KURSF,
238             AWTYP     TYPE AWTYP,
239             AWKEY     TYPE AWKEY,
240             GLVOR     TYPE GLVOR,
241             XREVERSAL TYPE XREVERSAL,
242           END OF TY_BKPF,
243
244           BEGIN OF TY_LFA1,
245             LIFNR TYPE LIFNR,
246             NAME1 TYPE NAME1_GP,
247             NAME2 TYPE NAME2_GP,
248             STRAS TYPE STRAS_GP,
249             LAND1 TYPE LAND1,
250             PSTLZ TYPE PSTLZ,
251             ORT01 TYPE ORT01_GP,
252             REGIO TYPE REGIO,
253             MCOD3 TYPE MCDK3,
254             ADRNR TYPE ADRNR,
255             STCD1 TYPE STCD1,
256             STCD3 TYPE STCD3,
257             KTOKK TYPE LFA1-KTOKK,
258           END OF TY_LFA1,
259
260           BEGIN OF TY_T001Z,
261             BUKRS TYPE BUKRS,
262             PARTY TYPE PARTY,
263             PAVAL TYPE PAVAL,
264           END OF TY_T001Z,
265
266           BEGIN OF TY_J_1I_SECCO_CIT,
267             BUKRS   TYPE BUKRS,
268             SECCODE TYPE SECCO,
269             TANNO   TYPE J_1I_TANNO,
270             ADRNR   TYPE ADRNR,
271           END OF TY_J_1I_SECCO_CIT,
272
273           BEGIN OF TY_J_1BBRANCH,
274             BUKRS  TYPE BUKRS,
275             BRANCH TYPE J_1BBRANC_,
276             NAME   TYPE NAME1,
277             ADRNR  TYPE ADRNR,
278             GSTIN  TYPE J_1IGSTCD3,
279           END OF TY_J_1BBRANCH,
280
281           BEGIN OF TY_J_1IMOVEND,
282             LIFNR     TYPE LIFNR,
283             J_1IPANNO TYPE J_1IPANNO,
284    "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP on 13/06/2026
285    *         VEN_CLASS TYPE J_1IMOVEND-VEN_CLASS,
286             VEN_CLASS TYPE J_1IGTAKLD,
287    "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP on 13/06/2026
288           END OF TY_J_1IMOVEND,
289
290           BEGIN OF TY_BSET,
291             BUKRS TYPE BUKRS,
292             BELNR TYPE BELNR_D,
293             GJAHR TYPE GJAHR,
294             BUZEI TYPE BUZEI,
295             MWSKZ TYPE MWSKZ,
296             HKONT TYPE HKONT,
297             TXGRP TYPE TXGRP,
298             TAXPS TYPE TAXPS,
299             KTOSL TYPE KTOSL,
300             FWBAS TYPE FWBAS,
301             KBETR TYPE KBETR,
302             HWSTE TYPE HWSTE,
303             FWSTE TYPE FWSTE,
304             HWBAS TYPE HWBAS,
305             KSCHL TYPE KSCHL,
306             STBKZ TYPE STBKZ_007B,
307             SHKZG TYPE BSET-SHKZG,
308           END OF TY_BSET,
309
310           BEGIN OF TY_T059Z,
311             LAND1     TYPE LAND1,
312             WITHT     TYPE WITHT,
313             WT_WITHCD TYPE WT_WITHCD,
314             QSCOD     TYPE WT_OWTCD,
315             WT_POSIN  TYPE WT_POSIN,
316             QSATZ     TYPE QSATZ,
317           END OF TY_T059Z,
318
319           BEGIN OF TY_WITH_ITEM,
320             BUKRS      TYPE BUKRS,
321             BELNR      TYPE BELNR_D,
322             GJAHR      TYPE GJAHR,
323             BUZEI      TYPE BUZEI,
324             WITHT      TYPE WITHT,
325             WT_WITHCD  TYPE WT_WITHCD,   "GST & TDS Tax Code
326             WT_QSSHH   TYPE WT_BS,    "TDS Base Value
327             QSATZ      TYPE WT_QSATZ,
328             WT_QBSHB   TYPE WERTV8,
329             WT_QBSHH   TYPE WT_WT,
330             WT_GRUWTPD TYPE WT_GRUWTPD,
331             KOART      TYPE KOART,
332             J_1IBUZEI  TYPE BUZEI,
333             WT_OPOWTPD TYPE WT_OPOWTPD,
334             HKONT      TYPE HKONT,
335             WT_QSZRT   TYPE WITH_ITEM-WT_QSZRT,
336             WT_WTEXMN  TYPE WITH_ITEM-WT_WTEXMN,
337           END OF TY_WITH_ITEM,
338
339
340           BEGIN OF TY_EKKO,
341             EBELN   TYPE EKKO-EBELN,
342             BSART   TYPE EKKO-BSART,
343             LIFNR   TYPE EKKO-LIFNR,
344             BEDAT   TYPE EKKO-BEDAT,
345             WAERS   TYPE EKKO-WAERS,
346             EBELP   TYPE EKPO-EBELP,
347             TXZ01   TYPE EKPO-TXZ01,
348             MATNR   TYPE EKPO-MATNR,
349             WERKS   TYPE EKPO-WERKS,
350             WEPOS   TYPE EKPO-WEPOS,
351             WEBRE   TYPE EKPO-WEBRE,
352             J_1BNBM TYPE EKPO-J_1BNBM,
353             KNTTP   TYPE EKPO-KNTTP,
354             PSTYP   TYPE EKPO-PSTYP,
355           END OF TY_EKKO,
356
357           BEGIN OF TY_RSEG,
358             BELNR       TYPE BELNR_D,
359             GJAHR       TYPE GJAHR,
360             BUZEI       TYPE BUZEI,
361             EBELN       TYPE EBELN,
362             EBELP       TYPE EBELP,
363             LFBNR       TYPE LFBNR,
364             WRBTR       TYPE RSEG-WRBTR,
365             SHKZG       TYPE SHKZG,
366             CUSTOMS_VAL TYPE RSEG-CUSTOMS_VAL,
367             KZMEK       TYPE RSEG-KZMEK,   "Added by AM001-18.01.24
368           END OF TY_RSEG,
369
370           BEGIN OF TY_ASMD,
371             ASNUM         TYPE ASNUM,
372             TAXTARIFFCODE TYPE STEUC,
373           END OF TY_ASMD,
374
375           BEGIN OF TY_ASMDT,
376             ASNUM TYPE ASNUM,
377             ASKTX TYPE TEXT40,
378           END OF TY_ASMDT,
379
380           BEGIN OF TY_SKAT,
381             SAKNR TYPE SAKNR,
382             TXT20 TYPE TXT20_SKAT,
383             TXT50 TYPE TXT50_SKAT,
384             KTOPL TYPE SKAT-KTOPL,
385           END OF TY_SKAT,
386
387           BEGIN OF TY_T001,
388             BUKRS TYPE T001-BUKRS,
389             BUTXT TYPE T001-BUTXT,
390             KTOPL TYPE T001-KTOPL,
391           END OF TY_T001,
392
393
394           BEGIN OF TY_MARC,
395             MATNR TYPE MATNR,
396             WERKS TYPE WERKS,
397             STEUC TYPE STEUC,
398           END OF TY_MARC,
399
400           BEGIN OF TY_T604N,
401             SPRAS TYPE SPRAS,
402             LAND1 TYPE LAND1,
403             STEUC TYPE STEUC,
404             TEXT1 TYPE BEZEI60,
405           END OF TY_T604N,
406
407           BEGIN OF TY_ADRC,
408             ADDRNUMBER TYPE ADRC-ADDRNUMBER,
409             NAME1      TYPE AD_NAME1,
410             NAME2      TYPE AD_NAME2,
411             CITY1      TYPE AD_CITY1,
412             CITY2      TYPE AD_CITY2,
413             POST_CODE1 TYPE AD_PSTCD1,
414             POST_CODE2 TYPE AD_PSTCD2,
415             STREET     TYPE AD_STREET,
416             STR_SUPPL1 TYPE AD_STRSPP1,
417             STR_SUPPL2 TYPE AD_STRSPP2,
418             STR_SUPPL3 TYPE AD_STRSPP3,
419             REGION     TYPE REGIO,
420           END OF TY_ADRC,
421
422           BEGIN OF TY_EKBE_1,
423             EBELN TYPE EBELN,
424             EBELP TYPE EBELP,
425             GJAHR TYPE MJAHR,
426             BELNR TYPE MBLNR,
427             BEWTP TYPE BEWTP,
428             VGABE TYPE EKBE-VGABE,
429             DMBTR TYPE EKBE-DMBTR,
430             SHKZG TYPE EKBE-SHKZG,
431           END OF TY_EKBE_1,
432
433           BEGIN OF TY_EKKN,
434             EBELN TYPE  EBELN,
435             EBELP TYPE EBELP,
436             ZEKKN TYPE DZEKKN,
437             SAKTO TYPE SAKNR,
438           END OF TY_EKKN,
439
440           BEGIN OF TY_T030,
441             KTOPL TYPE KTOPL,
442             KTOSL TYPE KTOSL,
443             BWMOD TYPE BWMOD,
444             KOMOK TYPE KOMOK,
445             BKLAS TYPE BKLAS,
446             KONTS TYPE SAKNR,
447           END OF TY_T030,
448
449           BEGIN OF TY_RBKP_O,
450             BELNR TYPE BELNR_D,
451             GJAHR TYPE GJAHR,
452             BLDAT TYPE BLDAT,
453             BUKRS TYPE BUKRS,
454             STBLG TYPE STBLG,
455             IVTYP TYPE RBKP-IVTYP,
456           END OF TY_RBKP_O,
457
458           BEGIN OF TY_MLAN,
459             MATNR TYPE MATNR,
460             ALAND TYPE ALAND,
461             TAXIM TYPE TAXIM1,
462           END OF TY_MLAN,
463
464           BEGIN OF TY_SKAT1,
465             SAKNR TYPE SKAT-SAKNR,
466             TXT50 TYPE SKAT-TXT50,
467           END OF TY_SKAT1,
468
469           BEGIN OF TY_EKPO1,
470             EBELN TYPE EKPO-EBELN,
471             EBELP TYPE EKPO-EBELP,
472             MATNR TYPE EKPO-MATNR,
473             MATKL TYPE EKPO-MATKL,
474             WERKS TYPE EKPO-WERKS,
475             BWTAR TYPE EKPO-BWTAR,
476             PSTYP TYPE EKPO-PSTYP,
477           END OF TY_EKPO1,
478
479           BEGIN OF TY_T001W,
480             WERKS TYPE T001W-WERKS,
481             NAME1 TYPE T001W-NAME1,
482             BWKEY TYPE T001W-BWKEY,
483           END OF TY_T001W,
484
485           BEGIN OF TY_MBEW,
486             MATNR TYPE MBEW-MATNR,
487             BWKEY TYPE MBEW-BWKEY,
488             BWTAR TYPE MBEW-BWTAR,
489             BKLAS TYPE MBEW-BKLAS,
490           END OF TY_MBEW,
491
492           BEGIN OF TY_CONTROL_TAB,
493             TEXT       TYPE STRING,
494             TEXT1      TYPE STRING,
495             TAN        TYPE STRING,
496             STATUS     TYPE STRING,
497             DR_CR      TYPE STRING,
498             BUDAT_S    TYPE STRING,
499             BUDAT_E    TYPE STRING,
500             CPUDT_S    TYPE STRING,
501             CPUDT_E    TYPE STRING,
502             EXTRAT_D   TYPE STRING,
503             NO_REC     TYPE STRING,
504             NO_DOC     TYPE STRING,
505             AMOUNT     TYPE WERTV12,
506             TDS_AMOUNT TYPE ZEYTDS_INV_EXT1-TDS_AMOUNT,
507             INV_AMT    TYPE WERTV12,
508             NO_FBL     TYPE STRING,
509             FBL1N_AMT  TYPE WERTV12,
510           END OF TY_CONTROL_TAB,
511
512           BEGIN OF TY_ZTB_TDS_GL,
513             BUKRS   TYPE ZEYTDS_TDS_GL-BUKRS,
514             HKONT   TYPE ZEYTDS_TDS_GL-HKONT,
515             GL_TYPE TYPE ZEYTDS_TDS_GL-GL_TYPE,
516           END OF TY_ZTB_TDS_GL.
517
518    TYPES:BEGIN OF TY_CONTROL_STR,
519            TEXT           TYPE STRING,
520            TEXT1          TYPE STRING,
521            TAN            TYPE STRING,
522            STATUS         TYPE STRING,
523            DR_CR          TYPE STRING,
524            BUDAT_S        TYPE STRING,
525            BUDAT_E        TYPE STRING,
526            CPUDT_S        TYPE STRING,
527            CPUDT_E        TYPE STRING,
528            EXTRAT_D       TYPE STRING,
529            NO_REC(10)     TYPE C,
530            NO_DOC(10)     TYPE C,
531            AMOUNT(20)     TYPE C,
532            TDS_AMOUNT(20) TYPE C,
533            INV_AMT(20)    TYPE C,
534            NO_FBL(10)     TYPE C,
535            FBL1N_AMT(20)  TYPE C,
536          END OF TY_CONTROL_STR,
537
538          BEGIN OF TY_EXTRA_STR,
539            BELNR TYPE STRING,
540            BUKRS TYPE STRING,
541            BLART TYPE STRING,
542            DMBTR TYPE CHAR20,
543            SHKZG TYPE STRING,
544            BUDAT TYPE STRING,
545            TEXT  TYPE STRING,
546          END OF TY_EXTRA_STR,
547
548          BEGIN OF TY_EXTRA,
549            BELNR TYPE BKPF-BELNR,
550            BUKRS TYPE BKPF-BUKRS,
551            DMBTR TYPE BSEG-DMBTR,
552            SHKZG TYPE BSEG-SHKZG,
553            BUDAT TYPE STRING,
554            BLART TYPE BKPF-BLART,
555            TEXT  TYPE STRING,
556          END OF TY_EXTRA,
557
558          BEGIN OF TY_MSEG2,
559            EBELN TYPE MSEG-EBELN,
560            EBELP TYPE MSEG-EBELP,
561            LFBNR TYPE MSEG-LFBNR,
562            SAKTO TYPE MSEG-SAKTO,
563          END OF TY_MSEG2,
564
565          BEGIN OF TY_ZTBT_KTOSL,
566            KTOSL TYPE ZEYTDS_KTOSL-KTOSL,
567            HSN   TYPE ZEYTDS_KTOSL-HSN,
568            TEXT  TYPE ZEYTDS_KTOSL-TEXT,
569          END OF TY_ZTBT_KTOSL,
570
571          BEGIN OF XML_LINE,
572            DATA(255) TYPE X,
573          END OF XML_LINE,
574
575          BEGIN OF TY_DEL_BEL,
576            BUKRS   TYPE BKPF-BUKRS,
577            BELNR   TYPE BKPF-BELNR,
578            GJAHR   TYPE BKPF-GJAHR,
579            FLAG(1) TYPE C,
580          END OF TY_DEL_BEL.
581
582
583    DATA: LV_BUDAT          TYPE BKPF-BUDAT,
584          LV_AEDAT          TYPE BKPF-AEDAT,
585          GT_FINAL_TDS      TYPE STANDARD TABLE OF TY_FINAL_TDS,
586          GT_PRO            TYPE STANDARD TABLE OF TY_PRO,
587          GT_PRO2           TYPE STANDARD TABLE OF TY_PRO2,
588          GT_PRO3           TYPE STANDARD TABLE OF TY_PRO3,
589          GS_FINAL_TDS      TYPE TY_FINAL_TDS,
590          GS_FINAL_TDS_TEMP TYPE TY_FINAL_TDS,
591          GS_PRO            TYPE TY_PRO,
592          GS_PRO2           TYPE TY_PRO2,
593          GS_PRO3           TYPE TY_PRO3,
594          GS_TDS            TYPE ZEYTDS_INV_EXT_N,
595          GT_TDS            TYPE TABLE OF ZEYTDS_INV_EXT_N,
596          GS_LAYO           TYPE SLIS_LAYOUT_ALV,
597          GV_FILE           TYPE STRING,
598          GV_FILECOUNT(3)   TYPE N,
599          LV_FILECOUNT(3)   TYPE N,
600          GT_ZEYTDS_TDS_GL  TYPE TABLE OF ZEYTDS_TDS_GL,
601          GS_ZEYTDS_TDS_GL  TYPE ZEYTDS_TDS_GL,
602          IT_SKAT           TYPE TABLE OF TY_SKAT1,
603          S_SKAT            TYPE TY_SKAT1,
604          LT_WITH_ITEM_TEMP TYPE STANDARD TABLE OF TY_WITH_ITEM,
605          LS_WITH_ITEM      TYPE TY_WITH_ITEM,
606          LT_BSEG_A         TYPE TABLE OF TY_BSEG,
607          LS_BSEG_A         TYPE TY_BSEG,
608          LT_TDS_COND_TYPE  TYPE TABLE OF ZEYTDS_CONDTYP,
609          LS_TDS_COND_TYPE  TYPE ZEYTDS_CONDTYP,
610          LT_ACCT_GROUP     TYPE TABLE OF ZEYTDS_ACCT_GRP,
611          LT_EKPO1          TYPE TABLE OF TY_EKPO1,
612          LS_EKPO1          TYPE TY_EKPO1,
613          LT_T001W          TYPE TABLE OF TY_T001W,
614          LS_T001W          TYPE  TY_T001W,
615          LT_MBEW           TYPE TABLE OF TY_MBEW,
616          LS_MBEW           TYPE TY_MBEW,
617          LT_CONTROL        TYPE TABLE OF TY_CONTROL_TAB,
618          LS_CONTROL        TYPE TY_CONTROL_TAB,
619          LT_CONTROL_FBL1N  TYPE TABLE OF TY_CONTROL_TAB,
620          LT_CONTROL_TEMP   TYPE TABLE OF TY_CONTROL_TAB,
621          LS_CONTROL_TEMP   TYPE  TY_CONTROL_TAB,
622          LT_CONTROL_COM    TYPE TABLE OF TY_CONTROL_TAB,
623          LS_CONTROL_COM    TYPE TY_CONTROL_TAB,
624          LS_CONTROL_COM1   TYPE TY_CONTROL_TAB,
625
626          R_BLART           TYPE RANGE OF BKPF-BLART,
627          LS_R_BLART        LIKE LINE OF R_BLART,
628          R_MATNR           TYPE RANGE OF EKPO-MATNR,
629          LS_MATNR          LIKE LINE OF R_MATNR,
630
631          LT_TDS_GL         TYPE TABLE OF TY_ZTB_TDS_GL,
632          LT_KTOSL          TYPE TABLE OF TY_ZTBT_KTOSL,
633          LS_KTOSL          TYPE TY_ZTBT_KTOSL,
634          LT_FBL1N_DEL      TYPE TABLE OF RFPOSXEXT,
635          LS_FBL1N_DEL      LIKE LINE OF LT_FBL1N_DEL,
636          LS_STRING         TYPE          TY_CONTROL_STR,
637          LS_STRING1        TYPE          TY_EXTRA_STR,
638          L_XML_TABLE       TYPE TABLE OF XML_LINE,
639          LT_FINAL_HEX      TYPE TABLE OF  SOLIX,
640          LS_FINAL_HEX      TYPE           SOLIX,
641          LT_EXTRA          TYPE TABLE OF TY_EXTRA,
642          LS_EXTRA          TYPE TY_EXTRA,
643          LT_LFA1           TYPE STANDARD TABLE OF TY_LFA1,
644          LS_LFA1           TYPE TY_LFA1,
645          LT_DEL_BEL        TYPE TABLE OF TY_DEL_BEL,
646          LT_DEL_BEL_K      TYPE TABLE OF TY_DEL_BEL,
647          LS_DEL_BEL        TYPE TY_DEL_BEL,
648          LT_ZTDS_DOCTYPE   TYPE TABLE OF ZEYTDS_DOCTYPE,
649          LS_ZTDS_DOCTYPE   TYPE ZEYTDS_DOCTYPE,
650          LT_UPD            TYPE TABLE OF ZEYTDS_RESON_STR,
651          LS_UPD            TYPE ZEYTDS_RESON_STR,
652          LT_MSEG_T         TYPE TABLE OF TY_MSEG2,
653          LS_MSEG_T         TYPE TY_MSEG2,
654          LT_T059Z          TYPE STANDARD TABLE OF TY_T059Z,
655          LS_T059Z          TYPE TY_T059Z,
656          LV_CNT10          TYPE N,
657          LV_NO             TYPE CHAR2,
658          LV_COUNTER        TYPE I.
659
660
661    FIELD-SYMBOLS:<WA_XML> LIKE LINE OF L_XML_TABLE.
662
663    CONSTANTS: GC_DRIVE_ROOT        TYPE STRING VALUE 'C:',
664               GC_FILE_SEPARATOR    TYPE STRING VALUE '/',
665               GC_FOLDER_ROOT       TYPE STRING VALUE 'TDS_INVOICE_EXTRACT',
666               GC_TABLENAME_TDS(30) VALUE 'GT_TDS'.
667
668    RANGES:  R_KSCHL FOR BSET-KSCHL. " zubair 19.3.24
*--- End of ZEYTDS_INV_EXTRACT_TOP - 668 lines ---

----------------------------------------------------------------------------------------------------
Include          ZEYTDS_INV_EXTRACT_SEL                    Level 1    Page 3
Object           ZEYTDS_INV_EXTRACT                        Lines 396
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:37
----------------------------------------------------------------------------------------------------
1      **&---------------------------------------------------------------------*
2      **&  Include          ZEYDIGI_INV_EXTRACT_SEL_NEW
3      **&---------------------------------------------------------------------*
4
5      SELECTION-SCREEN BEGIN OF BLOCK B1 WITH FRAME TITLE TEXT-001.
6      SELECT-OPTIONS: S_BUKRS  FOR LV_BUKRS OBLIGATORY.
7      PARAMETERS:     P_GJAHR  TYPE GJAHR .
8      *PARAMETERS:     P_GJAHR  TYPE GJAHR OBLIGATORY.
9
10     PARAMETERS:     P_GJAHR2 AS CHECKBOX USER-COMMAND U.
11     SELECT-OPTIONS : S_BELNR FOR LV_BELNR.
12
13     PARAMETERS:RB_DATE TYPE CHAR1 RADIOBUTTON GROUP G1 USER-COMMAND UCOM.
14     SELECT-OPTIONS : S_DATE FOR LV_BUDAT MODIF ID ABC.
15
16     PARAMETERS: RB_CDATE TYPE CHAR1 RADIOBUTTON GROUP G1.
17     SELECT-OPTIONS: S_CDATE FOR LV_AEDAT MODIF ID XYZ.
18     SELECTION-SCREEN SKIP 1.
19
20     SELECT-OPTIONS :CR_DATE FOR LV_CPUDT,
21                     S_LIFNR FOR LV_LIFNR.
22     SELECTION-SCREEN END OF BLOCK B1.
23
24
25     SELECTION-SCREEN BEGIN OF BLOCK B2 WITH FRAME TITLE TEXT-002.
26     PARAMETERS : R_FILE   RADIOBUTTON GROUP M1 USER-COMMAND UCM,
27                  R_BACKUP RADIOBUTTON GROUP M1,
28                  R_RPT    RADIOBUTTON GROUP  M1 DEFAULT 'X',
29                  R_DEL    RADIOBUTTON GROUP M1.
30     SELECTION-SCREEN END OF BLOCK B2.
31
32     SELECTION-SCREEN BEGIN OF BLOCK B3 WITH FRAME TITLE TEXT-003.
33     PARAMETERS : R_LIVE RADIOBUTTON GROUP M2,
34                  R_STG  RADIOBUTTON GROUP M2.
35     SELECTION-SCREEN END OF BLOCK B3.
36
37     SELECTION-SCREEN BEGIN OF BLOCK B4 WITH FRAME TITLE TEXT-004.
38     PARAMETERS : R_CHK    AS CHECKBOX USER-COMMAND CMD.
39
40     PARAMETERS: P_SPL_DT TYPE I MODIF ID M5.
41     SELECTION-SCREEN SKIP.
42
43     PARAMETERS : R_LOCL   RADIOBUTTON GROUP M3 USER-COMMAND ABC DEFAULT 'X',
44                  P_LC_CSV AS CHECKBOX MODIF ID M3 USER-COMMAND CMD,
45                  P_LC_XLS AS CHECKBOX USER-COMMAND CMD MODIF ID M3 DEFAULT 'X',
46                  P_LCFILE TYPE IBIPPARMS-PATH MODIF ID M3.
47
48     SELECTION-SCREEN SKIP.
49     PARAMETERS :R_AL11   RADIOBUTTON GROUP M3,
50                 P_LINES  TYPE INT4 MODIF ID M3,
51                 P_ALFILE TYPE DXFILENAME MODIF ID M3,
52                 P_AL_CSV AS CHECKBOX  MODIF ID M3 USER-COMMAND XYZ  DEFAULT 'X',
53                 P_AL_XLS AS CHECKBOX  MODIF ID M3 USER-COMMAND XYZ.
54     SELECTION-SCREEN END OF BLOCK B4.
55
56     SELECTION-SCREEN BEGIN OF BLOCK B6 WITH FRAME TITLE TEXT-005.
57     PARAMETERS:EXP_CHK  AS CHECKBOX USER-COMMAND CMD2 DEFAULT 'X'.
58
59     PARAMETERS CHK AS CHECKBOX USER-COMMAND CMD1 DEFAULT 'X'.
60     PARAMETERS:R_BUKRS RADIOBUTTON GROUP M4 USER-COMMAND CMD MODIF ID M4 DEFAULT 'X',
61                R_PLANT RADIOBUTTON GROUP M4 MODIF ID M4,
62                R_BUPLA RADIOBUTTON GROUP M4 MODIF ID M4,
63                R_GSBER RADIOBUTTON GROUP M4 MODIF ID M4,
64                R_PRCTR RADIOBUTTON GROUP M4 MODIF ID M4.
65     SELECTION-SCREEN END OF BLOCK B6.
66
67     PARAMETERS : P_BYPASS NO-DISPLAY.
68
69     AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_LCFILE.
70
71       CALL FUNCTION 'F4_FILENAME'
72         EXPORTING
73           PROGRAM_NAME  = SYST-CPROG
74           DYNPRO_NUMBER = SYST-DYNNR
75           FIELD_NAME    = ' '
76         IMPORTING
77           FILE_NAME     = P_LCFILE.
78
79     *INITIALIZATION.
80     *
81     *  DATA : E_FY     TYPE CHAR4.
82     *
83     *  IF P_GJAHR IS INITIAL.
84     *    CALL FUNCTION 'GM_GET_FISCAL_YEAR'
85     *      EXPORTING
86     *        I_DATE                     = SY-DATUM
87     *        I_FYV                      = 'V3'
88     *      IMPORTING
89     *        E_FY                       = E_FY
90     *      EXCEPTIONS
91     *        FISCAL_YEAR_DOES_NOT_EXIST = 1
92     *        NOT_DEFINED_FOR_DATE       = 2
93     *        OTHERS                     = 3.
94     *    IF SY-SUBRC EQ 0.
95     *      P_GJAHR = E_FY.
96     *    ENDIF.
97     *  ENDIF.
98
99
100    AT SELECTION-SCREEN OUTPUT.
101      IF R_BACKUP = 'X'.
102        CLEAR:R_STG.
103      ENDIF.
104
105      IF R_FILE = 'X'.
106        CLEAR R_RPT.
107      ENDIF.
108
109      LOOP AT SCREEN.
110
111        " SOC by zubair - 7.3.24
112        IF  SCREEN-NAME CS 'R_AL11' OR SCREEN-NAME CS 'P_ALFILE' OR SCREEN-NAME CS 'P_AL_CSV' OR SCREEN-NAME CS 'P_AL_XLS'
113         OR SCREEN-NAME CS 'P_LINES'.
114          SCREEN-ACTIVE = 0.
115        ENDIF.
116        " EOC by zubair - 7.3.24
117
118        IF SCREEN-GROUP1 = 'ABC'.
119          IF RB_CDATE = 'X' .
120            SCREEN-ACTIVE = 0.
121          ELSE.
122            SCREEN-ACTIVE = 1.
123          ENDIF.
124        ENDIF.
125
126        IF SCREEN-GROUP1 = 'XYZ'.
127          IF RB_DATE = 'X' .
128            SCREEN-ACTIVE = 0.
129          ELSE.
130            SCREEN-ACTIVE = 1.
131          ENDIF.
132        ENDIF.
133
134        IF SCREEN-GROUP1 = 'CR'.
135          IF R_BACKUP = 'X' OR R_DEL  = 'X' OR R_RPT = 'X' OR R_FILE = 'X'.
136            SCREEN-ACTIVE = 1.
137          ELSE.
138            SCREEN-ACTIVE = 0.
139          ENDIF.
140        ENDIF.
141
142        MODIFY SCREEN.
143
144
145        IF  R_RPT = 'X'.
146          IF SCREEN-NAME = 'R_LOCL' OR SCREEN-NAME = 'R_AL11' OR SCREEN-NAME = 'P_LINES'
147            OR SCREEN-NAME =  '%B004024_BLOCK_1000' OR SCREEN-NAME = 'P_ALFILE' OR SCREEN-NAME = 'P_LCFILE'
148            OR SCREEN-NAME = 'R_CHK' OR SCREEN-NAME = '%B004022_BLOCK_1000'
149            OR SCREEN-NAME = '%B004023_BLOCK_1000'.
150            SCREEN-ACTIVE = '0'.
151          ENDIF.
152
153          IF SCREEN-NAME = 'P_LINES' OR SCREEN-NAME = 'P_ALFILE' .
154            SCREEN-INVISIBLE = 1.
155          ENDIF.
156          IF SCREEN-GROUP1 = 'M3'.
157            SCREEN-INVISIBLE = '1'.
158          ENDIF.
159
160          IF SCREEN-NAME CS 'P_SPL_DT' OR SCREEN-NAME CS 'P_SPL_GL'.
161            SCREEN-INVISIBLE = '1'.
162          ENDIF.
163
164        ELSEIF R_BACKUP = 'X'.
165          IF SCREEN-NAME = 'R_STG' OR SCREEN-NAME = 'R_LOCL' OR SCREEN-NAME = 'R_AL11'
166            OR SCREEN-NAME = 'P_LINES' OR SCREEN-NAME = 'P_ALFILE'
167            OR SCREEN-NAME = 'R_CHK'    OR SCREEN-NAME = '%B004022_BLOCK_1000'
168            OR SCREEN-NAME = '%B004023_BLOCK_1000' OR SCREEN-NAME = 'P_LCFILE'.
169            SCREEN-ACTIVE = '0'.
170          ENDIF.
171          IF SCREEN-NAME = 'P_LINES' OR SCREEN-NAME = 'P_ALFILE' .
172            SCREEN-INVISIBLE = 1.
173          ENDIF.
174          IF SCREEN-GROUP1 = 'M3'.
175            SCREEN-INVISIBLE = '1'.
176          ENDIF.
177          IF SCREEN-NAME CS 'P_SPL_DT' OR SCREEN-NAME CS 'P_SPL_GL'.
178            SCREEN-INVISIBLE = '1'.
179          ENDIF.
180
181        ELSEIF R_DEL  = 'X'.
182          IF SCREEN-NAME = 'R_LIVE' OR SCREEN-NAME = 'R_LOCL' " OR screen-name = 'R_STG'
183            OR SCREEN-NAME = 'R_AL11' OR SCREEN-NAME = 'P_LINES' OR SCREEN-NAME = 'P_ALFILE'
184            OR SCREEN-NAME = '%B004022_BLOCK_1000' OR SCREEN-NAME = 'R_CHK'
185            OR SCREEN-NAME = '%B004023_BLOCK_1000'  OR SCREEN-NAME = 'P_LCFILE'.
186            SCREEN-ACTIVE = '0'.
187          ENDIF.
188          IF SCREEN-NAME = 'P_LINES' OR SCREEN-NAME = 'P_ALFILE' .
189            SCREEN-INVISIBLE = 1.
190          ENDIF.
191          IF SCREEN-GROUP1 = 'M3'.
192            SCREEN-INVISIBLE = '1'.
193          ENDIF.
194          IF SCREEN-NAME CS 'P_SPL_DT' OR SCREEN-NAME CS 'P_SPL_GL'.
195            SCREEN-INVISIBLE = '1'.
196          ENDIF.
197        ENDIF.
198
199
200        IF SCREEN-NAME EQ 'R_LIVE' AND R_DEL EQ 'X'.
201          CLEAR: R_RPT, R_LIVE.
202          SCREEN-INVISIBLE = 1.
203          SCREEN-ACTIVE = 0.
204        ENDIF.
205
206        IF SCREEN-NAME EQ 'R_STG' AND R_BACKUP = 'X' .
207          CLEAR: R_RPT, R_STG.
208          SCREEN-INVISIBLE = 1.
209          SCREEN-ACTIVE = 0.
210        ENDIF.
211
212        IF CHK = '' .
213          IF SCREEN-GROUP1 = 'M4'.
214            SCREEN-INVISIBLE = '1'.
215          ENDIF.
216        ENDIF.
217
218        IF R_FILE IS INITIAL AND R_CHK IS INITIAL
219          OR R_FILE IS NOT INITIAL AND R_CHK IS INITIAL
220          OR R_FILE IS INITIAL AND R_CHK IS NOT INITIAL.
221          IF SCREEN-NAME = 'P_EXP_DT' OR SCREEN-NAME = 'P_EXP_GL' OR SCREEN-GROUP1 = 'M5'.
222            SCREEN-ACTIVE = '0'.
223            SCREEN-INVISIBLE = '1'.
224          ENDIF.
225        ENDIF.
226
227        IF R_FILE IS NOT INITIAL AND R_CHK IS INITIAL.
228          IF SCREEN-NAME CS 'P_SPL_DT' OR SCREEN-NAME CS 'P_SPL_GL'.
229            SCREEN-INVISIBLE = '1'.
230            SCREEN-ACTIVE = '0'.
231          ENDIF.
232        ENDIF.
233
234    *    IF SCREEN-NAME EQ  'CHK'.
235    *      SCREEN-INPUT = '0'.
236    *    ENDIF.
237    *
238    *    IF SCREEN-GROUP1 = 'M4'.
239    *      SCREEN-INPUT = '0'.
240    *    ENDIF.
241
242        MODIFY SCREEN.
243      ENDLOOP.
244
245      IF R_FILE = 'X' AND R_LOCL = 'X'.     "Download file or Local
246        CLEAR : R_AL11,P_AL_XLS, P_ALFILE.
247
248        IF P_LC_XLS EQ 'X' AND P_LC_CSV EQ 'X'.
249          CLEAR:P_LC_XLS, P_LC_CSV.
250          MESSAGE 'Please select any one option (.xls, .csv)' TYPE 'I'.
251        ENDIF.
252
253        LOOP AT SCREEN .
254          IF SCREEN-NAME CS 'P_LINES' OR SCREEN-NAME CS 'P_ALFILE'
255           OR SCREEN-NAME EQ 'P_AL_XLS' OR SCREEN-NAME EQ 'P_AL_CSV'.
256            SCREEN-INVISIBLE = 1.
257            SCREEN-ACTIVE = 0.
258          ENDIF.
259
260          MODIFY SCREEN.
261        ENDLOOP.
262      ENDIF.
263
264      IF R_FILE = 'X' AND R_AL11 = 'X'. "Download file or "AL11
265        CLEAR : R_LOCL, P_LC_XLS.
266
267
268        IF P_AL_XLS = 'X' AND P_AL_CSV = 'X'.
269          CLEAR:P_AL_XLS, P_AL_CSV.
270          MESSAGE 'Please select any one option (.xls, .csv)' TYPE 'I'.
271        ENDIF.
272
273        LOOP AT SCREEN .
274          IF SCREEN-NAME EQ 'P_LC_XLS' OR SCREEN-NAME EQ 'P_LC_CSV'
275            OR  SCREEN-NAME CS 'P_LCFILE'.
276            SCREEN-INVISIBLE = 1.
277            SCREEN-ACTIVE = 0.
278          ENDIF.
279          MODIFY SCREEN.
280        ENDLOOP.
281
282      ENDIF.
283    *
284    *
285    * IF r_file = 'X' AND r_locl = 'X'.  "download file or local
286    *    CLEAR : r_al11,p_al_xls,p_al_csv,p_alfile.
287    *
288    *    IF p_lc_xls IS INITIAL AND p_lc_csv IS INITIAL.
289    *      p_lc_xls = 'X'.
290    *    ENDIF.
291    *
292    *    IF p_lc_xls EQ 'X' AND p_lc_csv EQ 'X'.
293    *      MESSAGE 'please select any one option (.xls, .csv)' TYPE 'I'.
294    *    ENDIF.
295    *
296    *    LOOP AT SCREEN .
297    *      IF screen-name CS 'P_LINES' OR screen-name CS 'P_ALFILE'
298    *       OR screen-name EQ 'P_AL_XLS' OR screen-name EQ 'P_AL_CSV'.
299    *        screen-invisible = 1.
300    *        screen-active = 0.
301    *      ENDIF.
302    *
303    *      MODIFY SCREEN.
304    *    ENDLOOP.
305    *  ENDIF.
306    *
307    *  IF r_file = 'X' AND r_al11 = 'X'.
308    *    CLEAR : r_locl, p_lc_xls.
309    *
310    *    IF p_al_csv IS INITIAL AND p_al_csv IS INITIAL.
311    *      p_al_csv = 'X'.
312    *    ENDIF.
313    *
314    *    IF p_al_xls = 'X' AND p_al_csv = 'X'.
315    *      MESSAGE 'please select any one option (.xls, .csv)' TYPE 'I'.
316    *    ENDIF.
317    *
318    *
319    *    LOOP AT SCREEN .
320    *      IF screen-name EQ 'P_LC_XLS' OR screen-name EQ 'P_LC_CSV'
321    *       OR screen-name = 'P_LCFILE'.
322    *        screen-invisible = 1.
323    *        screen-active = 0.
324    *      ENDIF.
325    *
326    *      MODIFY SCREEN.
327    *    ENDLOOP.
328    *  ENDIF.
329
330    *AT SELECTION-SCREEN ON P_GJAHR2.
331    *  DATA : E_FY TYPE CHAR4.
332    *
333    *  IF  P_GJAHR2 = 'X'.
334    *    CALL FUNCTION 'GM_GET_FISCAL_YEAR'
335    *      EXPORTING
336    *        I_DATE                     = SY-DATUM
337    *        I_FYV                      = 'V3'
338    *      IMPORTING
339    *        E_FY                       = E_FY
340    *      EXCEPTIONS
341    *        FISCAL_YEAR_DOES_NOT_EXIST = 1
342    *        NOT_DEFINED_FOR_DATE       = 2
343    *        OTHERS                     = 3.
344    *    IF SY-SUBRC EQ 0.
345    *      P_GJAHR  = E_FY - 1.
346    *    ENDIF.
347    *  ENDIF.
348
349
350    AT SELECTION-SCREEN.
351      DATA(LV_DAY) =  S_DATE-HIGH - S_DATE-LOW.
352
353      IF P_SPL_DT IS NOT INITIAL.
354        IF LV_DAY GT '30'.
355          SET CURSOR FIELD 'S_DATE'.
356          MESSAGE 'For split logic enter posting date within month' TYPE 'E'.
357        ENDIF.
358      ENDIF.
359
360    *&---------------------------------------------------------------------*
361    *&      Form  SPLIT_DATE_LOGIC
362    *&---------------------------------------------------------------------*
363    *       text
364    *----------------------------------------------------------------------*
365    *  -->  p1        text
366    *  <--  p2        text
367    *----------------------------------------------------------------------*
368    FORM SPLIT_DATE_LOGIC .
369
370      DATA : LV_DAYS     TYPE I,
371             LV_DIVISION TYPE STRING,
372             LV_DECI     TYPE CHAR05.
373
374      LV_DAYS =  S_DATE-HIGH - S_DATE-LOW.
375
376      IF LV_DAYS GT '30'.
377        MESSAGE 'For split logic enter posting date within month' TYPE 'E' DISPLAY LIKE 'S'.
378      ENDIF.
379
380      CLEAR:LV_NO,LV_COUNTER.
381      IF LV_DAYS IS NOT INITIAL.
382        LV_DIVISION = LV_DAYS /  P_SPL_DT.
383        SPLIT LV_DIVISION AT '.' INTO LV_NO LV_DECI.
384      ENDIF.
385
386
387      IF LV_DECI IS NOT INITIAL.
388        LV_NO = LV_NO + 1.
389      ELSE.
390        LV_NO = LV_NO.
391      ENDIF.
392      CONDENSE LV_NO.
393
394      LV_COUNTER = LV_NO.
395
396    ENDFORM.
*--- End of ZEYTDS_INV_EXTRACT_SEL - 396 lines ---

----------------------------------------------------------------------------------------------------
Include          ZEYTDS_INV_EXTRACT_F01                    Level 1    Page 4
Object           ZEYTDS_INV_EXTRACT                        Lines 8347
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:37
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&  Include          ZEYDIGI_INV_EXTRACT_F01_NEW
3      *&---------------------------------------------------------------------*
4      FORM   GENERATE_INVOICE_DATA .
5
6        TYPES: BEGIN OF TY_RBKP_NEW,
7                 BELNR TYPE RBKP-BELNR,
8                 GJAHR TYPE RBKP-GJAHR,
9                 BLART TYPE RBKP-BLART,
10                XRECH TYPE RBKP-XRECH,
11                IVTYP TYPE RBKP-IVTYP,
12              END OF TY_RBKP_NEW,
13
14              BEGIN OF TY_RBKP,
15                BELNR TYPE RBKP-BELNR,
16                GJAHR TYPE RBKP-GJAHR,
17                BLART TYPE RBKP-BLART,
18                BLDAT TYPE RBKP-BLDAT,
19                STBLG TYPE RBKP-STBLG,
20                STJAH TYPE RBKP-STJAH,
21              END OF TY_RBKP,
22
23              BEGIN OF TY_BKPF_NEW,
24                BUKRS TYPE BKPF-BUKRS,
25                BELNR TYPE BKPF-BELNR,
26                GJAHR TYPE BKPF-GJAHR,
27                BLART TYPE BKPF-BLART,
28                XBLNR TYPE BKPF-XBLNR,
29                AWKEY TYPE BKPF-AWKEY,
30                BLDAT TYPE BKPF-BLDAT,
31                BUDAT TYPE BKPF-BUDAT,
32              END OF TY_BKPF_NEW,
33
34              BEGIN OF TY_BSEC,
35                BUKRS TYPE BSEC-BUKRS,
36                BELNR TYPE BSEC-BELNR,
37                GJAHR TYPE BSEC-GJAHR,
38                BUZEI TYPE BSEC-BUZEI,
39                NAME1 TYPE BSEC-NAME1,
40                LAND1 TYPE BSEC-LAND1,
41                STRAS TYPE BSEC-STRAS,
42                STCD1 TYPE BSEC-STCD1,
43                STCD2 TYPE BSEC-STCD2,
44                STCD3 TYPE BSEC-STCD3,
45                STCD4 TYPE BSEC-STCD4,
46              END OF TY_BSEC,
47
48              BEGIN OF TY_BKPF_TEMP,
49                BUKRS     TYPE   BKPF-BUKRS,
50                BELNR     TYPE   BKPF-BELNR,
51                GJAHR     TYPE   BKPF-GJAHR,
52                BLART     TYPE   BKPF-BLART,
53                BLDAT     TYPE   BKPF-BLDAT,
54                BUDAT     TYPE   BKPF-BUDAT,
55                CPUDT     TYPE   BKPF-CPUDT,
56                USNAM     TYPE   BKPF-USNAM,
57                TCODE     TYPE   BKPF-TCODE,
58                XBLNR     TYPE   BKPF-XBLNR,
59                STBLG     TYPE   BKPF-STBLG,
60                STJAH     TYPE   BKPF-STJAH,
61                WAERS     TYPE   BKPF-WAERS,
62                KURSF     TYPE   BKPF-KURSF,
63                BSTAT     TYPE   BKPF-BSTAT,
64                GLVOR     TYPE   BKPF-GLVOR,
65                AWTYP     TYPE   BKPF-AWTYP,
66                AWKEY     TYPE   BKPF-AWKEY,
67                XREVERSAL TYPE   BKPF-XREVERSAL,
68              END OF TY_BKPF_TEMP,
69
70              BEGIN OF TY_BSEG_TEMP,
71                BUKRS    TYPE BSEG-BUKRS,
72                BELNR    TYPE BSEG-BELNR,
73                GJAHR    TYPE BSEG-GJAHR,
74                BUZEI    TYPE BSEG-BUZEI,
75                BUZID    TYPE BSEG-BUZID,
76                KOART    TYPE BSEG-KOART,
77                UMSKZ    TYPE BSEG-UMSKZ,
78                UMSKS    TYPE BSEG-UMSKS,
79                ZUMSK    TYPE BSEG-ZUMSK,
80                SHKZG    TYPE BSEG-SHKZG,
81                GSBER    TYPE BSEG-GSBER,
82                MWSKZ    TYPE BSEG-MWSKZ,
83                QSSKZ    TYPE BSEG-QSSKZ,
84                DMBTR    TYPE BSEG-DMBTR,
85                WRBTR    TYPE BSEG-WRBTR,
86                HWBAS    TYPE BSEG-HWBAS,
87                FWBAS    TYPE BSEG-FWBAS,
88                TXGRP    TYPE BSEG-TXGRP,
89                ZUONR    TYPE BSEG-ZUONR,
90                SGTXT    TYPE BSEG-SGTXT,
91                VORGN    TYPE BSEG-VORGN,
92                KTOSL    TYPE BSEG-KTOSL,
93                KOSTL    TYPE BSEG-KOSTL,
94                XHRES    TYPE BSEG-XHRES,
95                SAKNR    TYPE BSEG-SAKNR,
96                HKONT    TYPE BSEG-HKONT,
97                LIFNR    TYPE BSEG-LIFNR,
98                GVTYP    TYPE BSEG-GVTYP,
99                SKFBT    TYPE BSEG-SKFBT,
100               REBZG    TYPE BSEG-REBZG,
101               REBZJ    TYPE BSEG-REBZJ,
102               LANDL    TYPE BSEG-LANDL,
103               QBSHB    TYPE BSEG-QBSHB,
104               MATNR    TYPE BSEG-MATNR,
105               WERKS    TYPE BSEG-WERKS,
106               MENGE    TYPE BSEG-MENGE,
107               MEINS    TYPE BSEG-MEINS,
108               EBELN    TYPE BSEG-EBELN,
109               EBELP    TYPE BSEG-EBELP,
110               ZEKKN    TYPE BSEG-ZEKKN,
111               REWRT    TYPE BSEG-REWRT,
112               PRCTR    TYPE BSEG-PRCTR,
113               LNRAN    TYPE BSEG-LNRAN,
114               XNEGP    TYPE BSEG-XNEGP,
115               XREF3    TYPE BSEG-XREF3,
116               BUPLA    TYPE BSEG-BUPLA,
117               SECCO    TYPE BSEG-SECCO,
118               TAXPS    TYPE BSEG-TAXPS,
119               GST_PART TYPE BSEG-GST_PART,
120               PLC_SUP  TYPE BSEG-PLC_SUP,
121               HSN_SAC  TYPE BSEG-HSN_SAC,
122             END OF TY_BSEG_TEMP,
123
124             BEGIN OF TY_EKKO_TEMP,
125               EBELN TYPE     EKKO-EBELN,
126               BSART TYPE     EKKO-BSART,
127               LIFNR TYPE     EKKO-LIFNR,
128               BEDAT TYPE     EKKO-BEDAT,
129               WAERS TYPE     EKKO-WAERS,
130             END OF TY_EKKO_TEMP,
131
132             BEGIN OF TY_BSEG_PO,
133               BUKRS TYPE BSEG-BUKRS,
134               BELNR TYPE BSEG-BELNR,
135               GJAHR TYPE BSEG-GJAHR,
136               BUZEI TYPE BSEG-BUZEI,
137               BUZID TYPE BSEG-BUZID,
138               HKONT TYPE BSEG-HKONT,
139               EBELN TYPE BSEG-EBELN,
140               EBELP TYPE BSEG-EBELP,
141             END OF TY_BSEG_PO,
142
143             BEGIN OF TY_EKPO_TEMP,
144               EBELN   TYPE     EKPO-EBELN,
145               EBELP   TYPE     EKPO-EBELP,
146               TXZ01   TYPE     EKPO-TXZ01,
147               MATNR   TYPE     EKPO-MATNR,
148               WERKS   TYPE     EKPO-WERKS,
149               WEPOS   TYPE     EKPO-WEPOS,
150               WEBRE   TYPE     EKPO-WEBRE,
151               J_1BNBM TYPE     EKPO-J_1BNBM,
152               KNTTP   TYPE     EKPO-KNTTP,
153               PSTYP   TYPE     EKPO-PSTYP,
154             END OF TY_EKPO_TEMP,
155
156             BEGIN OF TY_T077K,
157               KTOKK TYPE T077K-KTOKK,
158               XCPDS TYPE T077K-XCPDS,
159             END OF TY_T077K.
160
161      DATA: LT_BKPF               TYPE TABLE OF TY_BKPF,
162            LS_BKPF               TYPE TY_BKPF,
163            LS_J_1BBRANCH         TYPE TY_J_1BBRANCH,
164            LT_J_1BBRANCH         TYPE TABLE OF TY_J_1BBRANCH,
165            LT_BSEG               TYPE TABLE OF TY_BSEG,
166            LT_BSEG_T1            TYPE TABLE OF TY_BSEG,
167            LT_BSEG_E             TYPE TABLE OF TY_BSEG,
168            LS_BSEG_E             TYPE  TY_BSEG,
169            LT_BSEG_TDS           TYPE TABLE OF TY_BSEG,
170            LT_BSEG_TDS2          TYPE TABLE OF TY_BSEG,
171            LS_BSEG_TDS           TYPE TY_BSEG,
172            LS_BSEG_TDS2          TYPE TY_BSEG,
173    *        lt_bseg2              TYPE TABLE OF ty_bseg,
174            LS_BSEG               TYPE TY_BSEG,
175            LS_BSEG_KA_NEW        TYPE TY_BSEG,
176            LT_WITH_ITEM          TYPE STANDARD TABLE OF TY_WITH_ITEM,
177            LT_WITH_ITEM_TDS      TYPE STANDARD TABLE OF TY_WITH_ITEM,
178            LS_WITH_ITEM_TDS      TYPE TY_WITH_ITEM,
179            LV_INDEX              TYPE SY-TABIX,
180    *        ls_bseg_amt           TYPE ty_bseg,
181            LT_BSEG_K             TYPE TABLE OF TY_BSEG,
182            LT_BSEG_HIGH          TYPE TABLE OF TY_BSEG,
183            LT_BSEG_LOW           TYPE TABLE OF TY_BSEG,
184            GV_HIGH               TYPE CHAR10,
185            GV_LOW                TYPE CHAR10,
186            LS_BSEG_K             TYPE TY_BSEG,
187            LT_BSEG_T             TYPE TABLE OF TY_BSEG,
188            LT_BSEG_W             TYPE TABLE OF TY_BSEG,
189            LT_BSEG_P             TYPE TABLE OF TY_BSEG,
190            LT_BSEG_WE            TYPE TABLE OF TY_BSEG,
191            LS_BSEG_WE            TYPE  TY_BSEG,
192            LT_BSEG_G             TYPE TABLE OF TY_BSEG,
193            LT_BSEG_S             TYPE TABLE OF TY_BSEG,
194            LS_BSEG_P             TYPE TY_BSEG,
195            LS_BSEG_Q             TYPE TY_BSEG,
196            LS_BSEG_S             TYPE TY_BSEG,
197            LT_T001Z              TYPE STANDARD TABLE OF TY_T001Z,
198            LS_T001Z              TYPE TY_T001Z,
199            LT_J_1I_SECCO_CIT     TYPE STANDARD TABLE OF TY_J_1I_SECCO_CIT,
200            LS_J_1I_SECCO_CIT     TYPE TY_J_1I_SECCO_CIT,
201            LT_BSET               TYPE STANDARD TABLE OF TY_BSET,
202            LT_BSET_T2            TYPE STANDARD TABLE OF TY_BSET,
203            LT_BSET_NEW           TYPE STANDARD TABLE OF TY_BSET,
204            LS_BSET               TYPE TY_BSET,
205            IT_T007B              TYPE TABLE OF T007B,
206            WA_T007B              TYPE T007B,
207            LS_BSET_NEW           TYPE TY_BSET,
208            LT_BSET1              TYPE STANDARD TABLE OF TY_BSET,
209            LS_BSET1              TYPE TY_BSET,
210            LT_J_1IMOVEND         TYPE STANDARD TABLE OF TY_J_1IMOVEND,
211            LS_J_1IMOVEND         TYPE TY_J_1IMOVEND,
212            LT_EKPO               TYPE STANDARD TABLE OF TY_EKKO,
213            LT_RSEG               TYPE STANDARD TABLE OF TY_RSEG,
214            LT_EKPO_T1            TYPE STANDARD TABLE OF TY_EKKO,
215            LS_EKPO               TYPE TY_EKKO,
216            LT_SKAT               TYPE STANDARD TABLE OF TY_SKAT,
217            LS_SKAT               TYPE TY_SKAT,
218            LT_T001               TYPE STANDARD TABLE OF TY_T001,
219            LT_T001_NEW           TYPE STANDARD TABLE OF TY_T001,
220            LS_T001               TYPE TY_T001,
221            LS_T001_NEW           TYPE T001,
222            LS_ASMD               TYPE TY_ASMD,
223            LT_ASMD               TYPE STANDARD TABLE OF TY_ASMD,
224            LS_ASMDT              TYPE TY_ASMDT,
225            LT_ASMDT              TYPE STANDARD TABLE OF TY_ASMDT,
226            LS_MARC               TYPE TY_MARC,
227            LT_MARC               TYPE STANDARD TABLE OF TY_MARC,
228            LS_T604N              TYPE TY_T604N,
229            LT_T604N              TYPE STANDARD TABLE OF TY_T604N,
230            LT_T604N1             TYPE STANDARD TABLE OF TY_T604N,
231            LS_ADRC               TYPE TY_ADRC,
232            LT_ADRC               TYPE STANDARD TABLE OF TY_ADRC,
233            LS_BSEG_V             TYPE TY_BSEG,
234            LT_BSEG_V             TYPE STANDARD TABLE OF TY_BSEG,
235            LS_STATECODE          TYPE ZEYTDS_STATECD,
236            LT_STATECODE          TYPE STANDARD TABLE OF ZEYTDS_STATECD,
237            LS_EKBE_1             TYPE TY_EKBE_1,
238            LT_EKBE_1             TYPE STANDARD TABLE OF TY_EKBE_1,
239            LT_DOCTYPE            TYPE STANDARD TABLE OF ZEYTDS_DOCTYPE1,
240            LS_DOCTYPE            LIKE LINE OF LT_DOCTYPE,
241            LT_EKKN               TYPE STANDARD TABLE OF TY_EKKN,
242            LS_EKKN               TYPE TY_EKKN,
243            LT_T030               TYPE STANDARD TABLE OF TY_T030,
244            LS_T030               TYPE TY_T030,
245            LT_RBKP_O             TYPE STANDARD TABLE OF TY_RBKP_O,
246            LT_MLAN               TYPE STANDARD TABLE OF TY_MLAN,
247            LS_MLAN               TYPE TY_MLAN,
248            LV_BELNR              TYPE BELNR_D,
249            LV_TABIX              TYPE SY-TABIX,
250            LV_AWKEY              TYPE AWKEY,
251            LV_INV_AMOUNT         TYPE DMBTR,
252            LV_FLAG               TYPE C,
253            LV_BUZEI              TYPE BUZEI,
254            LV_TDS_AMT            TYPE WT_WT,
255            LV_CODE               TYPE REGIO,
256            LV_REGIO              TYPE REGIO,
257            R_TDS                 TYPE RANGE OF ZEYTDS_TDS_GL-HKONT,
258            RS_TDS                LIKE LINE OF R_TDS,
259            L_VAL                 TYPE CHAR35,
260            L_PRO                 TYPE DMBTR,
261            L_PRO_C               TYPE DMBTR,
262            L_PRO_S               TYPE DMBTR,
263            L_CNT                 TYPE NUMC4,
264            L_CNT2                TYPE NUMC4,
265            L_CNT3                TYPE NUMC4,
266            L_HKONT               TYPE BSEG-HKONT,
267            G_VAL                 TYPE CHAR35,
268            G_AMT                 TYPE  P DECIMALS 5,
269            G_AMT2                TYPE  P DECIMALS 5,
270            G_BASE2               TYPE  P DECIMALS 5,
271            LT_FINAL_TDS_TEMP     TYPE TABLE OF TY_FINAL_TDS,
272            LS_FINAL_TDS_TEMP     TYPE TY_FINAL_TDS,
273            LT_FINAL_TDS_MODIFY   TYPE TABLE OF TY_FINAL_TDS,
274            LS_FINAL_TDS_MODIFY   TYPE TY_FINAL_TDS,
275            LT_TXGRP_D_C_IND      TYPE TABLE OF TY_FINAL_TDS,
276            LS_TXGRP_D_C_IND      TYPE TY_FINAL_TDS,
277            LV_COUNT1             TYPE I,
278            LV_GRANT_TOTAL        TYPE DMBTR,
279            LF_INV_DR_HAVING_H    TYPE CHAR1,
280            LF_CR_HAVING_S        TYPE CHAR1,
281            LV_TOTAL_IGST         TYPE ZEYTDS_INV_EXT_N-IGSTAMOUNT,
282            LV_TOTAL_IGST_DIFF    TYPE ZEYTDS_INV_EXT_N-IGSTAMOUNT,
283            LV_TOTAL_CGST         TYPE ZEYTDS_INV_EXT_N-IGSTAMOUNT,
284            LV_TOTAL_CGST_DIFF    TYPE ZEYTDS_INV_EXT_N-IGSTAMOUNT,
285            LV_TOTAL_SGST         TYPE ZEYTDS_INV_EXT_N-IGSTAMOUNT,
286            LV_TOTAL_SGST_DIFF    TYPE ZEYTDS_INV_EXT_N-IGSTAMOUNT,
287            LV_DEDUCTES_CODE      TYPE LFA1-LIFNR,
288            LT_BSEC               TYPE TABLE OF TY_BSEC,
289            LS_BSEC               TYPE TY_BSEC,
290            LT_BKPF_TEMP          TYPE TABLE OF TY_BKPF_TEMP,
291            LS_BKPF_TEMP          TYPE TY_BKPF_TEMP,
292            LT_BSEG_TEMP_NEW      TYPE TABLE OF TY_BSEG_TEMP,
293            LS_BSEG_TEMP_NEW      TYPE TY_BSEG_TEMP,
294            LT_T077K              TYPE TABLE OF TY_T077K,
295            LT_TDS_TAN            TYPE TABLE OF ZEYTDS_TAN_DET,
296            LS_TDS_TAN            TYPE ZEYTDS_TAN_DET,
297            LT_RBKP_RE            TYPE TABLE OF TY_RBKP_NEW,
298            LS_RBKP_RE            TYPE TY_RBKP_NEW,
299            LT_RBKP               TYPE TABLE OF TY_RBKP,
300            LS_RBKP               TYPE TY_RBKP,
301            LV_GJAHR              TYPE BKPF-GJAHR,
302            LV_WERKS              TYPE BSEG-WERKS,
303            LV_POSL               TYPE T001W-REGIO,
304            LV_BLART              TYPE BKPF-BLART,
305            LV_MATNR              TYPE MATNR,
306            LV_EBELN              TYPE EKKO-EBELN,
307            LV_EBELP              TYPE EKPO-EBELP,
308            LS_RBKP_NEW1          LIKE LINE OF LT_RBKP,
309            LT_BKPF_NEW           TYPE TABLE OF TY_BKPF_NEW,
310            LT_BKPF_NEW2          TYPE TABLE OF TY_BKPF_NEW,
311            LS_BKPF_NEW           TYPE TY_BKPF_NEW,
312            LV_AWKEY_NEW          TYPE STRING,
313            LT_BSEG_WRX_PO        TYPE TABLE OF TY_BSEG_PO,
314            LS_BSEG_WRX_PO        TYPE TY_BSEG_PO,
315            LT_BSEG_TEMP          TYPE TABLE OF TY_BSEG,
316            LT_BSEG_TEMP1         TYPE TABLE OF TY_BSEG,
317            LT_BSEG_TEMP2         TYPE TABLE OF TY_BSEG,
318            LT_T005U              TYPE TABLE OF T005U,
319            LS_T005U              TYPE T005U,
320            LT_EKKO_TEMP          TYPE TABLE OF TY_EKKO_TEMP,
321            LS_EKKO_TEMP          TYPE TY_EKKO_TEMP,
322            LT_EKPO_TEMP          TYPE TABLE OF TY_EKPO_TEMP,
323            LS_EKPO_TEMP          TYPE TY_EKPO_TEMP,
324            LT_TDS_SEC            TYPE TABLE OF ZEYTDS_TDS_SEC,
325            LS_TDS_SEC            TYPE ZEYTDS_TDS_SEC,
326            LR_BELNR              TYPE RANGE OF RBKP-BELNR,
327            LS_LR_BELNR           LIKE LINE OF LR_BELNR,
328            LR_GJAHR              TYPE RANGE OF RBKP-GJAHR,
329            LS_LR_GJAHR           LIKE LINE OF LR_GJAHR,
330            LR_AWKEY              TYPE RANGE OF BKPF-AWKEY,
331            LS_LR_AWKEY           LIKE LINE OF LR_AWKEY,
332            LS_BSEG_TEMP          LIKE LINE OF LT_BSEG_TEMP,
333            LT_BSEG_WRX           TYPE TABLE OF TY_BSEG,
334            LT_BSEG_PO            TYPE TABLE OF TY_BSEG,
335            LT_BSEG_PO_T1         TYPE TABLE OF TY_BSEG,
336            LT_BSEG_WRX1          TYPE TABLE OF TY_BSEG,
337            LV_SUPPLY_TYP         TYPE CHAR10,
338            LT_FINAL_TDSS         TYPE TABLE OF TY_FINAL_TDS,
339            LS_FINAL_TDSS         TYPE TY_FINAL_TDS,
340            LV_VALUE              TYPE P DECIMALS 5,
341            LV_VALUE1             TYPE  P DECIMALS 5,
342            LV_VALUE3             TYPE  P DECIMALS 5,
343            LV_VALUE_TEMP         TYPE  P DECIMALS 5,
344            LV_VALUE_TEMP1        TYPE  P DECIMALS 5,
345            LV_COUNT_TEMP         TYPE I,
346            GT_FINAL_TDS_AMT      TYPE TABLE OF TY_FINAL_TDS,
347            GT_FINAL_TDS_AMT_TEMP TYPE TABLE OF TY_FINAL_TDS,
348            GT_FINAL_TDS_AMT1     TYPE TABLE OF TY_FINAL_TDS,
349            GS_FINAL_TDS_AMT      TYPE TY_FINAL_TDS,
350            GS_FINAL_TDS_AMT_TEMP TYPE TY_FINAL_TDS,
351            GS_FINAL_TDS_AMT1     TYPE TY_FINAL_TDS,
352            LV_COUNT_T            TYPE I,
353            LV_COUNT_T1           TYPE I,
354            LV_KTOPL              TYPE SKAT-KTOPL,
355
356            LT_ZEYTDS_TAN_PRCT    TYPE TABLE OF ZEYTDS_TAN_PRCT.
357
358      FIELD-SYMBOLS:<FS_FINAL_TDS_MODIFY>  TYPE TY_FINAL_TDS,
359                    <FS_FINAL_TDS_MODIFY2> TYPE TY_FINAL_TDS.
360
361      """**************************************************
362      CLEAR LV_KTOPL.
363      LV_KTOPL  = 'ONGC'.
364
365      CLEAR:GT_ZEYTDS_TDS_GL.
366      SELECT *
367        FROM ZEYTDS_TDS_GL
368        INTO TABLE GT_ZEYTDS_TDS_GL
369        WHERE BUKRS IN S_BUKRS
370        AND GL_TYPE  = 'TDS'.
371      IF SY-SUBRC = 0.
372        SORT GT_ZEYTDS_TDS_GL BY BUKRS HKONT.
373      ENDIF.
374
375      CLEAR LT_T077K.
376      SELECT KTOKK XCPDS
377        FROM T077K
378        INTO TABLE LT_T077K
379        WHERE XCPDS = 'X'.
380      IF SY-SUBRC = 0.
381        SORT LT_T077K BY KTOKK.
382      ENDIF.
383
384      CLEAR LT_TDS_TAN.
385      SELECT *
386        FROM ZEYTDS_TAN_DET
387        INTO TABLE LT_TDS_TAN
388        WHERE BUKRS IN S_BUKRS.
389      IF SY-SUBRC = 0.
390        SORT LT_TDS_TAN BY BUKRS ORG_ELE.
391      ENDIF.
392
393      CLEAR LT_ZTDS_DOCTYPE.
394      SELECT *
395        FROM ZEYTDS_DOCTYPE
396        INTO TABLE LT_ZTDS_DOCTYPE
397        WHERE BUKRS IN S_BUKRS
398        AND EXTRAT_TYPE = 'INV'.
399
400      LOOP AT LT_ZTDS_DOCTYPE INTO LS_ZTDS_DOCTYPE.
401        LS_R_BLART-SIGN = 'I'.
402        LS_R_BLART-OPTION = 'EQ'.
403        LS_R_BLART-LOW = LS_ZTDS_DOCTYPE-BLART.
404        APPEND LS_R_BLART TO R_BLART.
405        CLEAR LS_R_BLART.
406      ENDLOOP.
407
408      IF R_BLART[] IS NOT INITIAL.
409        SORT R_BLART BY LOW.
410      ENDIF.
411
412
413      CLEAR LT_DOCTYPE.
414      SELECT *
415        FROM ZEYTDS_DOCTYPE1
416        INTO TABLE LT_DOCTYPE
417        WHERE EXT_NAME = 'INV'.
418      IF SY-SUBRC = 0.
419        SORT LT_DOCTYPE BY BLART.
420      ENDIF.
421
422      CLEAR LT_TDS_GL.
423      SELECT  BUKRS HKONT GL_TYPE
424        FROM ZEYTDS_TDS_GL
425        INTO TABLE LT_TDS_GL
426        WHERE BUKRS IN S_BUKRS
427        AND GL_TYPE = 'TDS'.
428      IF SY-SUBRC = 0.
429        SORT LT_TDS_GL BY BUKRS HKONT.
430      ENDIF.
431
432
433      CLEAR LT_BKPF_TEMP.
434      SELECT BUKRS BELNR GJAHR  BLART BLDAT BUDAT CPUDT USNAM TCODE
435        XBLNR STBLG STJAH WAERS KURSF BSTAT GLVOR AWTYP AWKEY  XREVERSAL
436        FROM BKPF
437        INTO TABLE LT_BKPF_TEMP
438        WHERE BUKRS IN S_BUKRS
439        AND BUDAT IN S_DATE
440        AND BLDAT IN S_CDATE
441        AND CPUDT IN CR_DATE
442        AND GJAHR EQ P_GJAHR
443        AND BLART IN R_BLART
444        AND BELNR IN S_BELNR
445        AND BSTAT <> 'Z'.
446      IF SY-SUBRC = 0.
447        SORT LT_BKPF_TEMP BY  BUKRS BELNR GJAHR.
448    " " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
449        SELECT BUKRS BELNR GJAHR BUZEI BUZID KOART UMSKZ UMSKS ZUMSK SHKZG GSBER "#EC CI_DB_OPERATION_OK[2431747]
450          MWSKZ QSSKZ DMBTR WRBTR HWBAS FWBAS TXGRP ZUONR SGTXT VORGN KTOSL KOSTL
451          XHRES SAKNR HKONT LIFNR GVTYP SKFBT REBZG REBZJ LANDL QBSHB MATNR WERKS MENGE MEINS
452          EBELN EBELP ZEKKN REWRT PRCTR LNRAN XNEGP XREF3 BUPLA SECCO
453          TAXPS GST_PART PLC_SUP HSN_SAC
454          FROM BSEG
455          INTO TABLE LT_BSEG_TEMP_NEW
456          FOR ALL ENTRIES IN LT_BKPF_TEMP
457          WHERE BUKRS = LT_BKPF_TEMP-BUKRS
458          AND BELNR = LT_BKPF_TEMP-BELNR
459          AND GJAHR = LT_BKPF_TEMP-GJAHR
460          ORDER BY PRIMARY KEY.
461    " " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
462      ENDIF.
463
464      IF LT_BKPF_TEMP[] IS NOT INITIAL .
465        LOOP AT LT_BKPF_TEMP INTO LS_BKPF_TEMP.
466          LOOP AT LT_BSEG_TEMP_NEW INTO LS_BSEG_TEMP_NEW WHERE BUKRS = LS_BKPF_TEMP-BUKRS
467                                                           AND BELNR = LS_BKPF_TEMP-BELNR
468                                                           AND GJAHR = LS_BKPF_TEMP-GJAHR.
469            LS_BSEG-BUKRS         = LS_BKPF_TEMP-BUKRS.
470            LS_BSEG-BELNR         = LS_BKPF_TEMP-BELNR.
471            LS_BSEG-GJAHR         = LS_BKPF_TEMP-GJAHR.
472            LS_BSEG-BLART         = LS_BKPF_TEMP-BLART.
473            LS_BSEG-BLDAT         = LS_BKPF_TEMP-BLDAT.
474            LS_BSEG-BUDAT         = LS_BKPF_TEMP-BUDAT.
475            LS_BSEG-CPUDT         = LS_BKPF_TEMP-CPUDT.
476            LS_BSEG-USNAM         = LS_BKPF_TEMP-USNAM.
477            LS_BSEG-TCODE         = LS_BKPF_TEMP-TCODE.
478            LS_BSEG-XBLNR         = LS_BKPF_TEMP-XBLNR.
479            LS_BSEG-STBLG         = LS_BKPF_TEMP-STBLG.
480            LS_BSEG-STJAH         = LS_BKPF_TEMP-STJAH.
481            LS_BSEG-WAERS         = LS_BKPF_TEMP-WAERS.
482            LS_BSEG-KURSF         = LS_BKPF_TEMP-KURSF.
483            LS_BSEG-AWKEY         = LS_BKPF_TEMP-AWKEY.
484            LS_BSEG-XREVERSAL     = LS_BKPF_TEMP-XREVERSAL.
485            LS_BSEG-BUZEI         = LS_BSEG_TEMP_NEW-BUZEI.
486            LS_BSEG-WERKS         = LS_BSEG_TEMP_NEW-WERKS.
487            LS_BSEG-BUZID         = LS_BSEG_TEMP_NEW-BUZID.
488            LS_BSEG-KOART         = LS_BSEG_TEMP_NEW-KOART.
489            LS_BSEG-UMSKZ         = LS_BSEG_TEMP_NEW-UMSKZ.
490            LS_BSEG-SHKZG         = LS_BSEG_TEMP_NEW-SHKZG.
491            LS_BSEG-GSBER         = LS_BSEG_TEMP_NEW-GSBER.
492            LS_BSEG-MWSKZ         = LS_BSEG_TEMP_NEW-MWSKZ.
493            LS_BSEG-DMBTR         = LS_BSEG_TEMP_NEW-DMBTR.
494            LS_BSEG-WRBTR         = LS_BSEG_TEMP_NEW-WRBTR.
495            LS_BSEG-TXGRP         = LS_BSEG_TEMP_NEW-TXGRP.
496            LS_BSEG-TAXPS         = LS_BSEG_TEMP_NEW-TAXPS.
497            LS_BSEG-KTOSL         = LS_BSEG_TEMP_NEW-KTOSL.
498            LS_BSEG-KOSTL         = LS_BSEG_TEMP_NEW-KOSTL.
499            LS_BSEG-SAKNR         = LS_BSEG_TEMP_NEW-SAKNR.
500            LS_BSEG-HKONT         = LS_BSEG_TEMP_NEW-HKONT.
501            LS_BSEG-LIFNR         = LS_BSEG_TEMP_NEW-LIFNR.
502            LS_BSEG-REBZG         = LS_BSEG_TEMP_NEW-REBZG.
503            LS_BSEG-REBZJ         = LS_BSEG_TEMP_NEW-REBZJ.
504            LS_BSEG-MATNR         = LS_BSEG_TEMP_NEW-MATNR.
505            LS_BSEG-EBELN         = LS_BSEG_TEMP_NEW-EBELN.
506            LS_BSEG-EBELP         = LS_BSEG_TEMP_NEW-EBELP.
507            LS_BSEG-PRCTR         = LS_BSEG_TEMP_NEW-PRCTR.
508            LS_BSEG-BUPLA         = LS_BSEG_TEMP_NEW-BUPLA.
509            LS_BSEG-PLC_SUP       = LS_BSEG_TEMP_NEW-PLC_SUP.
510            LS_BSEG-HSN_SAC       = LS_BSEG_TEMP_NEW-HSN_SAC.
511            LS_BSEG-SECCO         = LS_BSEG_TEMP_NEW-SECCO.
512            LS_BSEG-SGTXT         = LS_BSEG_TEMP_NEW-SGTXT.
513            LS_BSEG-VORGN         = LS_BSEG_TEMP_NEW-VORGN.
514            LS_BSEG-XREF3         = LS_BSEG_TEMP_NEW-XREF3.
515            LS_BSEG-SKFBT         = LS_BSEG_TEMP_NEW-SKFBT.
516            LS_BSEG-GVTYP         = LS_BSEG_TEMP_NEW-GVTYP.
517            LS_BSEG-UMSKS         = LS_BSEG_TEMP_NEW-UMSKS.
518            LS_BSEG-XNEGP         = LS_BSEG_TEMP_NEW-XNEGP.
519            LS_BSEG-ZUONR         = LS_BSEG_TEMP_NEW-ZUONR.
520            LS_BSEG-ZEKKN         = LS_BSEG_TEMP_NEW-ZEKKN.
521            APPEND LS_BSEG TO LT_BSEG.
522            IF LS_BSEG-LIFNR IS NOT INITIAL.
523              APPEND LS_BSEG TO LT_BSEG_T1.
524            ENDIF.
525            CLEAR:LS_BSEG.
526          ENDLOOP.
527        ENDLOOP.
528      ENDIF.
529
530      "SOC for Account type K more than 1 Added by Anil Maurya - 10.01.24
531      IF  LT_BSEG_T1[] IS NOT INITIAL.
532        DATA: LV_COUNT TYPE I.
533        SORT LT_BSEG_T1 BY BUKRS BELNR GJAHR LIFNR.
534        DELETE ADJACENT DUPLICATES FROM LT_BSEG_T1 COMPARING BUKRS BELNR GJAHR LIFNR.
535
536    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
537    *    SELECT BUKRS, BELNR, GJAHR, BUZEI
538    *      FROM BSET
539    *      INTO TABLE @DATA(LT_BSET_T1)
540    *      FOR ALL ENTRIES IN @LT_BSEG_T1
541    *       WHERE BUKRS = @LT_BSEG_T1-BUKRS
542    *       AND BELNR = @LT_BSEG_T1-BELNR
543    *       AND GJAHR = @LT_BSEG_T1-GJAHR
544    *      AND HWBAS <> '0.00'.
545        SELECT BUKRS, BELNR, GJAHR, BUZEI
546          FROM BSET
547          INTO TABLE @DATA(LT_BSET_T1)
548          FOR ALL ENTRIES IN @LT_BSEG_T1
549           WHERE BUKRS = @LT_BSEG_T1-BUKRS
550           AND BELNR = @LT_BSEG_T1-BELNR
551           AND GJAHR = @LT_BSEG_T1-GJAHR
552          AND HWBAS <> '0.00'. "#EC CI_NOORDER
553    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
554
555        SELECT BUKRS, BELNR, GJAHR, BUZEI
556        FROM WITH_ITEM
557        INTO TABLE @DATA(LT_WITH_ITEM_T1)
558        FOR ALL ENTRIES IN @LT_BSEG_T1
559         WHERE BUKRS = @LT_BSEG_T1-BUKRS
560         AND BELNR = @LT_BSEG_T1-BELNR
561         AND GJAHR = @LT_BSEG_T1-GJAHR
562         AND WT_QBSHH <> '0.00'.
563
564        LOOP AT LT_BSEG_T1 INTO DATA(LS_BSEG_T1).
565          CLEAR LV_COUNT.
566
567          READ TABLE LT_BSET_T1 TRANSPORTING NO FIELDS WITH KEY  BUKRS = LS_BSEG_T1-BUKRS
568                                                                 BELNR = LS_BSEG_T1-BELNR
569                                                                 GJAHR = LS_BSEG_T1-GJAHR.
570          IF SY-SUBRC <> 0.
571            READ TABLE LT_WITH_ITEM_T1 TRANSPORTING NO FIELDS WITH KEY   BUKRS = LS_BSEG_T1-BUKRS
572                                                                         BELNR = LS_BSEG_T1-BELNR
573                                                                         GJAHR = LS_BSEG_T1-GJAHR.
574            IF SY-SUBRC <> 0.
575              LOOP AT LT_BSEG INTO LS_BSEG  WHERE BUKRS = LS_BSEG_T1-BUKRS
576                                      AND  BELNR = LS_BSEG_T1-BELNR
577                                      AND GJAHR  = LS_BSEG_T1-GJAHR
578                                      AND KOART  = 'K'.
579                LV_COUNT = LV_COUNT + 1.
580              ENDLOOP.
581            ENDIF.
582          ENDIF.
583
584
585
586          IF LV_COUNT > 1.
587            CLEAR LS_DEL_BEL.
588            LS_DEL_BEL-BUKRS = LS_BSEG_T1-BUKRS.
589            LS_DEL_BEL-BELNR = LS_BSEG_T1-BELNR.
590            LS_DEL_BEL-GJAHR = LS_BSEG_T1-GJAHR.
591            LS_DEL_BEL-FLAG  = 'X'.
592            APPEND LS_DEL_BEL TO LT_DEL_BEL_K.
593
594
595            DELETE LT_BSEG WHERE BUKRS = LS_BSEG_T1-BUKRS
596                            AND BELNR = LS_BSEG_T1-BELNR
597                            AND GJAHR = LS_BSEG_T1-GJAHR.
598
599            DELETE LT_BSEG_T1 WHERE BUKRS = LS_BSEG_T1-BUKRS
600                             AND BELNR = LS_BSEG_T1-BELNR
601                             AND GJAHR = LS_BSEG_T1-GJAHR.
602            CLEAR:LS_BSEG_T1.
603          ENDIF.
604        ENDLOOP.
605      ENDIF.
606      IF LT_DEL_BEL_K[] IS NOT INITIAL.
607        SORT LT_DEL_BEL_K BY BUKRS BELNR GJAHR.
608      ENDIF.
609
610      "Eoc Added by Anil Maurya - 10.01.24
611
612      IF LT_BSEG IS INITIAL.
613        IF P_BYPASS IS INITIAL.
614          MESSAGE 'No data found in BKPF' TYPE 'S' DISPLAY LIKE 'E'.
615        ENDIF.
616        EXIT.
617      ENDIF.
618
619      CLEAR LT_BSEG_WRX.
620      LT_BSEG_WRX = LT_BSEG.
621
622      SORT LT_BSEG BY BUKRS BELNR GJAHR.
623
624      IF LT_BSEG IS NOT INITIAL.
625
626        CLEAR LT_ZEYTDS_TAN_PRCT .
627        SELECT *
628        FROM ZEYTDS_TAN_PRCT
629        INTO TABLE LT_ZEYTDS_TAN_PRCT
630        FOR ALL ENTRIES IN LT_BSEG
631        WHERE PRCTR = LT_BSEG-PRCTR.
632        IF SY-SUBRC = 0.
633          SORT LT_ZEYTDS_TAN_PRCT  BY PRCTR.
634        ENDIF.
635
636        CLEAR LT_BSEC.
637    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
638    *    SELECT BUKRS BELNR GJAHR BUZEI
639    *      NAME1 LAND1 STRAS STCD1
640    *      STCD2 STCD3 STCD4
641    *      FROM BSEC
642    *      INTO TABLE LT_BSEC
643    *      FOR ALL ENTRIES IN LT_BSEG
644    *      WHERE BUKRS = LT_BSEG-BUKRS
645    *      AND BELNR = LT_BSEG-BELNR
646    *      AND GJAHR = LT_BSEG-GJAHR.
647        SELECT BUKRS BELNR GJAHR BUZEI
648          NAME1 LAND1 STRAS STCD1
649          STCD2 STCD3 STCD4
650          FROM BSEC
651          INTO TABLE LT_BSEC
652          FOR ALL ENTRIES IN LT_BSEG
653          WHERE BUKRS = LT_BSEG-BUKRS
654          AND BELNR = LT_BSEG-BELNR
655          AND GJAHR = LT_BSEG-GJAHR. "#EC CI_NOORDER
656    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
657        IF SY-SUBRC = 0.
658          SORT LT_BSEC BY BUKRS BELNR GJAHR.
659        ENDIF.
660
661        CLEAR:LT_BSEG_TEMP, LT_BSEG_TEMP1, LT_BSEG_TEMP2.
662        LT_BSEG_TEMP  = LT_BSEG.
663        LT_BSEG_TEMP1 = LT_BSEG.
664        LT_BSEG_TEMP2 = LT_BSEG.
665
666        DELETE LT_BSEG_TEMP  WHERE TCODE <> 'MR8M'.
667        DELETE LT_BSEG_TEMP1 WHERE XREVERSAL <> '2'.
668        DELETE LT_BSEG_TEMP2 WHERE REBZG EQ ''.
669        APPEND LINES OF LT_BSEG_TEMP1 TO LT_BSEG_TEMP.
670
671        LOOP AT LT_BSEG_TEMP INTO LS_BSEG_TEMP.
672          LS_LR_BELNR-SIGN = 'I'.
673          LS_LR_BELNR-OPTION = 'EQ'.
674          LS_LR_BELNR-LOW = LS_BSEG_TEMP-AWKEY+0(10).
675          APPEND LS_LR_BELNR TO  LR_BELNR.
676          CLEAR LS_LR_BELNR.
677
678          LS_LR_GJAHR-SIGN = 'I'.
679          LS_LR_GJAHR-OPTION = 'EQ'.
680          LS_LR_GJAHR-LOW = LS_BSEG_TEMP-AWKEY+10(4).
681          IF LS_BSEG_TEMP-AWKEY+10(4) IS NOT INITIAL.
682            APPEND LS_LR_GJAHR TO LR_GJAHR.
683            CLEAR LS_LR_GJAHR.
684          ENDIF.
685        ENDLOOP.
686
687        IF LR_BELNR[] IS NOT INITIAL.
688          CLEAR LT_RBKP.
689          SELECT BELNR GJAHR BLART BLDAT STBLG STJAH
690            FROM RBKP
691            INTO TABLE LT_RBKP
692            WHERE BELNR IN LR_BELNR
693            AND GJAHR IN LR_GJAHR.
694          IF SY-SUBRC = 0.
695            SORT LT_RBKP BY BELNR GJAHR.
696
697            LOOP AT LT_RBKP INTO LS_RBKP_NEW1 WHERE  STBLG IS NOT INITIAL.
698              LS_LR_AWKEY-SIGN = 'I'.
699              LS_LR_AWKEY-OPTION = 'EQ'.
700              CONCATENATE LS_RBKP_NEW1-STBLG LS_RBKP_NEW1-STJAH INTO  LS_LR_AWKEY-LOW.
701              APPEND  LS_LR_AWKEY TO LR_AWKEY.
702              CLEAR LS_LR_AWKEY .
703            ENDLOOP.
704
705            IF LR_AWKEY[] IS NOT INITIAL.
706              SORT LR_AWKEY BY LOW.
707              CLEAR LT_BKPF_NEW .
708              SELECT BUKRS BELNR GJAHR BLART XBLNR AWKEY BLDAT BUDAT
709                FROM BKPF
710                INTO TABLE LT_BKPF_NEW
711                WHERE BUKRS = S_BUKRS
712                AND AWKEY IN LR_AWKEY.
713            ENDIF.
714          ENDIF.
715        ENDIF.
716
717        APPEND LINES OF LT_BSEG_TEMP2 TO LT_BSEG_TEMP1.
718        IF LT_BSEG_TEMP1 IS NOT INITIAL.
719          SELECT BUKRS BELNR GJAHR BLART XBLNR AWKEY BLDAT BUDAT
720            FROM BKPF
721            APPENDING TABLE LT_BKPF_NEW
722            FOR ALL ENTRIES IN LT_BSEG_TEMP1
723            WHERE BUKRS = LT_BSEG_TEMP1-BUKRS
724            AND BELNR = LT_BSEG_TEMP1-STBLG
725            AND GJAHR = LT_BSEG_TEMP1-STJAH.
726
727          SELECT BUKRS BELNR GJAHR  BLART XBLNR AWKEY BLDAT BUDAT
728            FROM BKPF
729            APPENDING TABLE LT_BKPF_NEW
730            FOR ALL ENTRIES IN LT_BSEG_TEMP1
731            WHERE BUKRS = LT_BSEG_TEMP1-BUKRS
732            AND BELNR = LT_BSEG_TEMP1-REBZG
733            AND GJAHR = LT_BSEG_TEMP1-REBZJ.
734
735          SORT LT_BKPF_NEW BY BUKRS BELNR GJAHR.
736        ENDIF.
737      ENDIF.
738
739      CLEAR LT_STATECODE.
740      SELECT *
741        FROM ZEYTDS_STATECD
742        INTO TABLE LT_STATECODE.
743      IF SY-SUBRC  = 0.
744        SORT LT_STATECODE BY REGIO.
745      ENDIF.
746
747      " Vendor line item
748    *  lt_bseg2 = lt_bseg.
749
750      " Vendor line item
751      LT_BSEG_K = LT_BSEG.
752      DELETE LT_BSEG_K WHERE KOART <> 'K'.
753
754      " Tax line item
755      LT_BSEG_T = LT_BSEG.
756      DELETE LT_BSEG_T WHERE BUZID = 'T'.
757
758      " Withholding Tax
759      LT_BSEG_W = LT_BSEG.
760      DELETE LT_BSEG_W WHERE KTOSL <> 'WRX' AND KTOSL <> 'FRE' AND KTOSL <> 'FR1' .
761      APPEND LINES OF LT_BSEG_T TO LT_BSEG_W.
762      SORT LT_BSEG_W BY BUKRS BELNR GJAHR BUZEI.
763      DELETE ADJACENT DUPLICATES FROM LT_BSEG_W COMPARING BUKRS BELNR GJAHR BUZEI.
764
765      " Vendor line item
766      LT_BSEG_V = LT_BSEG.
767      DELETE LT_BSEG_V WHERE KOART <> 'K'.
768
769    *  lt_bseg3 = lt_bseg.
770    *  DELETE lt_bseg3 WHERE bupla IS INITIAL.
771    *  DELETE lt_bseg3 WHERE gsber IS INITIAL.
772
773    *  lt_bseg4 = lt_bseg.
774    *  DELETE lt_bseg4 WHERE secco IS INITIAL.
775
776      LT_BSEG_TDS = LT_BSEG.
777      LT_BSEG_TDS2 = LT_BSEG.
778
779      DELETE ADJACENT DUPLICATES FROM LT_BSEG_TDS COMPARING BUKRS BELNR GJAHR TXGRP.
780      DELETE ADJACENT DUPLICATES FROM LT_BSEG_TDS2 COMPARING BUKRS BELNR GJAHR MWSKZ.
781
782      IF LT_BSEG IS NOT INITIAL.
783    * Get GST tax details
784        CLEAR  LT_BSEG_T1.
785        LT_BSEG_T1 =  LT_BSEG.
786        DELETE  LT_BSEG_T1 WHERE PLC_SUP IS INITIAL.
787
788        IF LT_BSEG_T1[] IS NOT INITIAL.
789          CLEAR LT_T005U.
790          SELECT *
791          FROM T005U
792          INTO TABLE LT_T005U
793          FOR ALL ENTRIES IN LT_BSEG_T1
794          WHERE SPRAS = 'E'
795          AND LAND1 = 'IN'
796          AND BLAND = LT_BSEG_T1-PLC_SUP.
797          IF SY-SUBRC = 0.
798            SORT LT_T005U BY BLAND.
799          ENDIF.
800        ENDIF.
801
802        CLEAR LT_BSET .
803    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
804    *    SELECT BUKRS BELNR GJAHR BUZEI MWSKZ HKONT TXGRP TAXPS KTOSL
805    *      FWBAS KBETR HWSTE FWSTE HWBAS KSCHL STBKZ SHKZG
806    *      FROM BSET
807    *      INTO TABLE LT_BSET
808    *      FOR ALL ENTRIES IN LT_BSEG
809    *      WHERE BUKRS = LT_BSEG-BUKRS
810    *      AND BELNR = LT_BSEG-BELNR
811    *      AND  GJAHR = LT_BSEG-GJAHR.
812        SELECT BUKRS BELNR GJAHR BUZEI MWSKZ HKONT TXGRP TAXPS KTOSL
813          FWBAS KBETR HWSTE FWSTE HWBAS KSCHL STBKZ SHKZG
814          FROM BSET
815          INTO TABLE LT_BSET
816          FOR ALL ENTRIES IN LT_BSEG
817          WHERE BUKRS = LT_BSEG-BUKRS
818          AND BELNR = LT_BSEG-BELNR
819          AND  GJAHR = LT_BSEG-GJAHR. "#EC CI_NOORDER
820    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
821    *      and hwste <> '0.00' and  fwste <> '0.00'.
822
823        IF SY-SUBRC = 0.
824          LT_BSET_T2[] = LT_BSET[].
825
826          SORT LT_BSET BY BUKRS BELNR GJAHR TXGRP TAXPS.
827          DELETE LT_BSET WHERE   HWSTE EQ '0.00'.
828
829    *      delete lt_bset_t2 WHERE hwste NE  '0.00'.
830
831          CLEAR LT_TDS_COND_TYPE.
832          SELECT *
833            FROM ZEYTDS_CONDTYP
834            INTO TABLE LT_TDS_COND_TYPE.
835          " comment by zubair 20.3.24
836    *        FOR ALL ENTRIES IN LT_BSET
837    *        WHERE  KSCHL = LT_BSET-KSCHL.                  "#EC CI_NOFIRST.
838          " comment by zubair 20.3.24
839          IF SY-SUBRC = 0.
840            SORT LT_TDS_COND_TYPE BY  KSCHL.
841          ENDIF.
842
843          " SOC by zubair ' 19.3.24
844          LOOP AT LT_TDS_COND_TYPE INTO DATA(WA_TDS_COND_TYPE) WHERE RCM IS INITIAL.
845            R_KSCHL-SIGN = 'I'.
846            R_KSCHL-OPTION = 'EQ'.
847            R_KSCHL-LOW = WA_TDS_COND_TYPE-KSCHL.
848            APPEND R_KSCHL.
849            CLEAR WA_TDS_COND_TYPE.
850          ENDLOOP.
851          "EOC by zubair ' 19.3.24
852
853          LT_BSET_NEW[] = LT_BSET[].
854
855    *      DELETE LT_BSET WHERE KSCHL+3(1) = 'R'. " commented by zubair ' 19.3.24
856          DELETE LT_BSET WHERE KSCHL  NOT IN R_KSCHL.  "Added by zubair ' 19.3.24
857          LT_BSET1[] = LT_BSET[].
858
859        ENDIF.
860
861        IF LT_BSET_NEW[] IS NOT INITIAL.
862          CLEAR: IT_T007B.
863    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
864    *      SELECT *
865    *      FROM T007B
866    *      INTO TABLE IT_T007B
867    *      FOR ALL ENTRIES IN LT_BSET_NEW
868    *      WHERE KTOSL = LT_BSET_NEW-KTOSL.
869          SELECT *
870          FROM T007B
871          INTO TABLE IT_T007B
872          FOR ALL ENTRIES IN LT_BSET_NEW
873          WHERE KTOSL = LT_BSET_NEW-KTOSL. "#EC CI_NOORDER
874    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
875          IF SY-SUBRC = 0.
876            SORT IT_T007B BY KTOSL.
877          ENDIF.
878        ENDIF.
879
880    * Get the vendor details.
881        CLEAR  LT_BSEG_T1.
882        LT_BSEG_T1 =  LT_BSEG.
883        DELETE  LT_BSEG_T1 WHERE LIFNR IS INITIAL.
884
885        IF LT_BSEG_T1[] IS NOT INITIAL.
886          CLEAR LT_LFA1.
887          SELECT LIFNR NAME1 NAME2 STRAS LAND1 PSTLZ ORT01 REGIO MCOD3 ADRNR STCD1 STCD3 KTOKK
888           FROM LFA1
889           INTO TABLE LT_LFA1
890           FOR ALL ENTRIES IN LT_BSEG_T1
891           WHERE LIFNR = LT_BSEG_T1-LIFNR.
892          IF SY-SUBRC = 0.
893            SORT LT_LFA1 BY LIFNR.
894
895            CLEAR LT_ACCT_GROUP.
896            SELECT *
897              FROM ZEYTDS_ACCT_GRP
898              INTO TABLE LT_ACCT_GROUP
899              FOR ALL ENTRIES IN LT_LFA1
900              WHERE KTOKK  = LT_LFA1-KTOKK.
901            IF SY-SUBRC = 0.
902              SORT LT_ACCT_GROUP BY KTOKK.
903            ENDIF.
904
905
906    *  Get the Deductee PAN details
907            CLEAR  LT_J_1IMOVEND.
908    *        SELECT LIFNR J_1IPANNO VEN_CLASS
909    *          FROM J_1IMOVEND
910    *          INTO TABLE LT_J_1IMOVEND
911    *          FOR ALL ENTRIES IN LT_LFA1
912    *          WHERE LIFNR = LT_LFA1-LIFNR.
913                    SELECT LIFNR J_1IPANNO VEN_CLASS
914              FROM LFA1
915              INTO TABLE LT_J_1IMOVEND
916              FOR ALL ENTRIES IN LT_LFA1
917              WHERE LIFNR = LT_LFA1-LIFNR.
918            IF SY-SUBRC = 0.
919              SORT LT_J_1IMOVEND  BY LIFNR.
920            ENDIF.
921
922            CLEAR LT_ADRC .
923            SELECT ADDRNUMBER NAME1 NAME2 CITY1 CITY2 POST_CODE1 POST_CODE2
924              STREET STR_SUPPL1 STR_SUPPL2 STR_SUPPL3 REGION
925              FROM ADRC
926              INTO TABLE LT_ADRC
927              FOR ALL ENTRIES IN LT_LFA1
928              WHERE  ADDRNUMBER = LT_LFA1-ADRNR.
929            IF SY-SUBRC = 0.
930              SORT LT_ADRC BY ADDRNUMBER.
931            ENDIF.
932          ENDIF.
933
934        ENDIF.
935
936
937        CLEAR  LT_BSEG_T1.
938        LT_BSEG_T1 =  LT_BSEG.
939        DELETE  LT_BSEG_T1 WHERE KTOSL IS INITIAL.
940        IF LT_BSEG_T1[] IS NOT INITIAL.
941          CLEAR LT_KTOSL.
942          SELECT  KTOSL HSN TEXT
943            FROM ZEYTDS_KTOSL
944            INTO TABLE LT_KTOSL
945            FOR ALL ENTRIES IN LT_BSEG_T1
946            WHERE KTOSL = LT_BSEG_T1-KTOSL.
947          IF SY-SUBRC = 0.
948            SORT LT_KTOSL BY KTOSL.
949          ENDIF.
950        ENDIF.
951    * Get the TDS rate and TDS amount
952        CLEAR LT_WITH_ITEM.
953        SELECT BUKRS BELNR GJAHR BUZEI WITHT WT_WITHCD WT_QSSHH QSATZ WT_QBSHB
954          WT_QBSHH WT_GRUWTPD KOART J_1IBUZEI WT_OPOWTPD HKONT WT_QSZRT WT_WTEXMN
955          FROM WITH_ITEM
956          INTO TABLE LT_WITH_ITEM
957          FOR ALL ENTRIES IN LT_BSEG
958          WHERE BUKRS = LT_BSEG-BUKRS
959          AND BELNR = LT_BSEG-BELNR
960          AND GJAHR = LT_BSEG-GJAHR.
961        IF SY-SUBRC = 0.
962          SORT LT_WITH_ITEM BY BUKRS BELNR GJAHR J_1IBUZEI.
963    ** Get the TDS section
964          SELECT LAND1 WITHT WT_WITHCD QSCOD WT_POSIN QSATZ
965            FROM T059Z
966            INTO TABLE LT_T059Z
967            FOR ALL ENTRIES IN LT_WITH_ITEM
968            WHERE WITHT = LT_WITH_ITEM-WITHT
969            AND WT_WITHCD = LT_WITH_ITEM-WT_WITHCD.
970          IF SY-SUBRC = 0.
971            SORT LT_T059Z  BY WITHT WT_WITHCD.
972          ENDIF.
973        ENDIF.
974
975    * Get the TDS rate and TDS amount
976        SELECT BUKRS BELNR GJAHR BUZEI WITHT WT_WITHCD WT_QSSHH QSATZ
977          WT_QBSHB WT_QBSHH WT_GRUWTPD KOART J_1IBUZEI WT_OPOWTPD HKONT WT_QSZRT WT_WTEXMN
978          FROM WITH_ITEM
979          INTO TABLE LT_WITH_ITEM_TEMP FOR ALL ENTRIES IN LT_BSEG
980          WHERE BUKRS = LT_BSEG-BUKRS AND
981          BELNR = LT_BSEG-BELNR AND
982          GJAHR = LT_BSEG-GJAHR .
983        IF SY-SUBRC = 0.
984          SORT LT_WITH_ITEM_TEMP BY BUKRS BELNR GJAHR.
985          SELECT LAND1 WITHT WT_WITHCD QSCOD WT_POSIN QSATZ
986            FROM T059Z
987            APPENDING TABLE LT_T059Z
988            FOR ALL ENTRIES IN LT_WITH_ITEM_TEMP
989            WHERE WITHT = LT_WITH_ITEM_TEMP-WITHT
990            AND WT_WITHCD = LT_WITH_ITEM_TEMP-WT_WITHCD.
991          IF SY-SUBRC = 0.
992            SORT LT_T059Z  BY WITHT WT_WITHCD.
993          ENDIF.
994        ENDIF.
995
996    **Get PO Details
997        CLEAR  LT_BSEG_T1.
998        LT_BSEG_T1 =  LT_BSEG.
999        DELETE  LT_BSEG_T1 WHERE EBELN IS INITIAL.
1000       IF LT_BSEG_T1[] IS NOT INITIAL.
1001         CLEAR LT_EKKO_TEMP.
1002         SELECT EBELN BSART LIFNR BEDAT WAERS
1003           FROM EKKO
1004           INTO TABLE LT_EKKO_TEMP
1005           FOR ALL ENTRIES IN  LT_BSEG_T1
1006           WHERE EBELN = LT_BSEG_T1-EBELN.
1007         IF SY-SUBRC = 0.
1008           SORT LT_EKKO_TEMP BY EBELN.
1009
1010           CLEAR LT_EKPO_TEMP.
1011           SELECT EBELN EBELP TXZ01 MATNR  WERKS  WEPOS WEBRE J_1BNBM  KNTTP PSTYP
1012             FROM EKPO
1013             INTO TABLE LT_EKPO_TEMP
1014             FOR ALL ENTRIES IN LT_BSEG_T1
1015             WHERE EBELN = LT_BSEG_T1-EBELN
1016             AND EBELP = LT_BSEG_T1-EBELP.
1017           IF SY-SUBRC = 0.
1018             SORT LT_EKPO_TEMP BY EBELN EBELP.
1019           ENDIF.
1020         ENDIF.
1021
1022         IF LT_EKKO_TEMP IS NOT INITIAL .
1023           LOOP AT LT_EKKO_TEMP INTO LS_EKKO_TEMP.
1024             LOOP AT LT_EKPO_TEMP INTO LS_EKPO_TEMP WHERE EBELN = LS_EKKO_TEMP-EBELN.
1025               LS_EKPO-EBELN = LS_EKKO_TEMP-EBELN.
1026               LS_EKPO-BSART = LS_EKKO_TEMP-BSART.
1027               LS_EKPO-BEDAT = LS_EKKO_TEMP-BEDAT.
1028               LS_EKPO-WAERS = LS_EKKO_TEMP-WAERS.
1029               LS_EKPO-EBELP = LS_EKPO_TEMP-EBELP.
1030               LS_EKPO-TXZ01 = LS_EKPO_TEMP-TXZ01.
1031               LS_EKPO-MATNR = LS_EKPO_TEMP-MATNR.
1032               LS_EKPO-WERKS = LS_EKPO_TEMP-WERKS.
1033               LS_EKPO-WEPOS = LS_EKPO_TEMP-WEPOS.
1034               LS_EKPO-WEBRE = LS_EKPO_TEMP-WEBRE.
1035               LS_EKPO-J_1BNBM = LS_EKPO_TEMP-J_1BNBM.
1036               LS_EKPO-KNTTP = LS_EKPO_TEMP-KNTTP.
1037               LS_EKPO-PSTYP = LS_EKPO_TEMP-PSTYP.
1038               APPEND LS_EKPO TO LT_EKPO.
1039               CLEAR:LS_EKPO.
1040             ENDLOOP.
1041           ENDLOOP.
1042         ENDIF.
1043
1044         IF LT_EKPO IS NOT INITIAL.
1045           "SOC added by anil maurya on 10.01.2024
1046           DATA(LT_EKPO_TEMP1) = LT_EKPO.
1047           DELETE LT_EKPO_TEMP1 WHERE PSTYP <> '0' AND  PSTYP <> '9' AND KNTTP <> 'A'.
1048           IF  LT_EKPO_TEMP1[] IS NOT INITIAL.
1049             SELECT EBELN, EBELP,  ANLN1
1050             FROM EKKN
1051             INTO TABLE @DATA(IT_EKKN1)
1052             FOR ALL ENTRIES IN @LT_EKPO_TEMP1
1053             WHERE EBELN = @LT_EKPO_TEMP1-EBELN
1054             AND EBELP = @LT_EKPO_TEMP1-EBELP
1055             AND ANLN1 <> ''.
1056             IF IT_EKKN1[] IS NOT INITIAL.
1057               SORT IT_EKKN1 BY  EBELN EBELP ANLN1.
1058
1059               SELECT BUKRS, ANLN1, KTOGR
1060               FROM ANLA
1061               INTO TABLE @DATA(LT_ANLA)
1062               FOR ALL ENTRIES IN @IT_EKKN1
1063               WHERE BUKRS IN @S_BUKRS
1064               AND ANLN1  =  @IT_EKKN1-ANLN1.
1065               IF SY-SUBRC = 0.
1066                 SORT LT_ANLA BY ANLN1.
1067
1068                 SELECT KTOPL, KTOGR, KTANSW
1069                 FROM T095
1070                 INTO TABLE @DATA(LT_T095)
1071                 FOR ALL ENTRIES IN @LT_ANLA
1072                 WHERE KTOPL  = @LV_KTOPL
1073                 AND KTOGR = @LT_ANLA-KTOGR.
1074                 IF SY-SUBRC = 0.
1075                   SORT LT_T095 BY KTANSW.
1076
1077                   CLEAR:IT_SKAT.
1078                   SELECT SAKNR,TXT20, TXT50,KTOPL
1079                     FROM SKAT
1080                     INTO TABLE @DATA(IT_SKAT_T1)
1081                     FOR ALL ENTRIES IN @LT_T095
1082                     WHERE SPRAS = @SY-LANGU
1083                     AND KTOPL = @LV_KTOPL
1084                     AND SAKNR = @LT_T095-KTANSW.
1085                   IF SY-SUBRC = 0.
1086                     SORT IT_SKAT_T1 BY SAKNR.
1087                   ENDIF.
1088                 ENDIF.
1089
1090               ENDIF.
1091             ENDIF.
1092           ENDIF.
1093           "EOC added by anil maurya on 10.01.2024
1094
1095
1096           SORT LT_EKPO BY EBELN EBELP.
1097           CLEAR LT_MARC .
1098           SELECT MATNR WERKS STEUC
1099             FROM MARC INTO TABLE LT_MARC
1100             FOR ALL ENTRIES IN LT_EKPO
1101             WHERE MATNR = LT_EKPO-MATNR
1102             AND WERKS = LT_EKPO-WERKS.
1103           IF SY-SUBRC = 0.
1104             SORT LT_MARC BY MATNR WERKS.
1105             CLEAR LT_T604N.
1106             SELECT SPRAS LAND1 STEUC TEXT1
1107               FROM T604N INTO TABLE LT_T604N
1108               FOR ALL ENTRIES IN LT_MARC
1109               WHERE SPRAS = SY-LANGU
1110               AND STEUC = LT_MARC-STEUC
1111               AND LAND1 = 'IN'.
1112             IF SY-SUBRC = 0.
1113               SORT LT_T604N BY STEUC.
1114             ENDIF.
1115           ENDIF.
1116
1117           CLEAR LT_EKPO_T1.
1118           LT_EKPO_T1 = LT_EKPO.
1119           DELETE LT_EKPO_T1 WHERE J_1BNBM IS INITIAL.
1120           IF LT_EKPO_T1[] IS NOT INITIAL.
1121             SELECT SPRAS LAND1 STEUC TEXT1
1122             FROM T604N
1123             APPENDING TABLE LT_T604N
1124             FOR ALL ENTRIES IN LT_EKPO_T1
1125             WHERE SPRAS = SY-LANGU
1126             AND STEUC = LT_EKPO_T1-J_1BNBM
1127             AND  LAND1 = 'IN'.
1128
1129             CLEAR LT_ASMD.
1130             SELECT ASNUM TAXTARIFFCODE
1131               FROM ASMD
1132               INTO TABLE LT_ASMD
1133               FOR ALL ENTRIES IN LT_EKPO_T1
1134               WHERE TAXTARIFFCODE = LT_EKPO_T1-J_1BNBM.
1135             IF SY-SUBRC = 0.
1136               SORT LT_ASMD BY TAXTARIFFCODE.
1137             ENDIF.
1138           ENDIF.
1139
1140         ENDIF.
1141
1142         CLEAR LT_EKBE_1.
1143         SELECT EBELN EBELP GJAHR BELNR BEWTP VGABE DMBTR SHKZG
1144           FROM EKBE
1145           INTO TABLE LT_EKBE_1
1146           FOR ALL ENTRIES IN LT_BSEG_T1
1147           WHERE EBELN = LT_BSEG_T1-EBELN
1148           AND EBELP = LT_BSEG_T1-EBELP.
1149         IF SY-SUBRC = 0.
1150           SORT LT_EKBE_1 BY GJAHR BELNR.
1151         ENDIF.
1152
1153         SELECT EBELN EBELP GJAHR BELNR BEWTP VGABE  DMBTR SHKZG
1154           FROM EKBZ
1155           APPENDING TABLE LT_EKBE_1
1156             FOR ALL ENTRIES IN LT_BSEG_T1
1157           WHERE EBELN = LT_BSEG_T1-EBELN
1158           AND EBELP = LT_BSEG_T1-EBELP.
1159         IF SY-SUBRC = 0.
1160           SORT LT_EKBE_1 BY GJAHR BELNR.
1161         ENDIF.
1162       ENDIF.
1163
1164       "SOC Added by AM001-22.01.24
1165       CLEAR:LR_GJAHR, LR_BELNR.
1166       LOOP AT LT_BSEG INTO LS_BSEG_TEMP WHERE AWKEY IS NOT INITIAL .
1167         LS_LR_BELNR-SIGN = 'I'.
1168         LS_LR_BELNR-OPTION = 'EQ'.
1169         LS_LR_BELNR-LOW = LS_BSEG_TEMP-AWKEY+0(10).
1170         APPEND LS_LR_BELNR TO LR_BELNR.
1171
1172         LS_LR_GJAHR-SIGN = 'I'.
1173         LS_LR_GJAHR-OPTION = 'EQ'.
1174         LS_LR_GJAHR-LOW = LS_BSEG_TEMP-AWKEY+10(4).
1175         APPEND LS_LR_GJAHR TO LR_GJAHR.
1176         CLEAR: LS_LR_GJAHR, LS_LR_BELNR.
1177       ENDLOOP.
1178
1179       SORT LR_BELNR BY LOW.
1180       DELETE ADJACENT DUPLICATES FROM LR_BELNR COMPARING LOW.
1181
1182       SORT LR_GJAHR BY LOW.
1183       DELETE ADJACENT DUPLICATES FROM  LR_GJAHR  COMPARING LOW.
1184
1185       IF LR_BELNR IS NOT INITIAL AND LR_GJAHR IS NOT INITIAL.
1186
1187         SELECT BELNR GJAHR BUZEI EBELN EBELP LFBNR WRBTR SHKZG CUSTOMS_VAL KZMEK
1188           FROM RSEG
1189           INTO TABLE LT_RSEG
1190   *            FOR ALL ENTRIES IN lt_ekpo
1191           WHERE BELNR IN LR_BELNR
1192           AND GJAHR IN LR_GJAHR.
1193   *            AND ebeln = lt_ekpo-ebeln
1194   *            AND ebelp = lt_ekpo-ebelp.
1195         IF SY-SUBRC = 0.
1196           SORT LT_RSEG BY BELNR GJAHR EBELN EBELP WRBTR.
1197
1198           "SOC Added by AM001-18.01.24
1199           DATA(LT_RSEG_NEW) = LT_RSEG.
1200           DELETE LT_RSEG_NEW WHERE  KZMEK IS INITIAL.
1201           IF  LT_RSEG_NEW[] IS NOT INITIAL.
1202             DATA(LT_BSEG_AWKEY)  =  LT_BSEG.
1203             SORT LT_BSEG_AWKEY BY  BUKRS  BELNR GJAHR AWKEY.
1204             DELETE ADJACENT DUPLICATES FROM LT_BSEG_AWKEY COMPARING BUKRS  BELNR GJAHR AWKEY.
1205           ENDIF.
1206         ENDIF.
1207       ENDIF.
1208       "EOC Added by AM001-22.01.24
1209
1210       CLEAR  LT_BSEG_T1.
1211       LT_BSEG_T1 =  LT_BSEG.
1212       DELETE  LT_BSEG_T1 WHERE HKONT IS INITIAL.
1213       IF LT_BSEG_T1[] IS NOT INITIAL.
1214         CLEAR LT_SKAT.
1215         SELECT SAKNR TXT20 TXT50 KTOPL
1216           FROM SKAT
1217           INTO TABLE LT_SKAT
1218           FOR ALL ENTRIES IN LT_BSEG
1219           WHERE SPRAS = SY-LANGU
1220           AND KTOPL = LV_KTOPL
1221           AND SAKNR = LT_BSEG-HKONT.
1222       ENDIF.
1223     ENDIF.
1224
1225     IF S_BUKRS[] IS NOT INITIAL.
1226   *  Get the Deductor PAN details
1227       CLEAR LT_T001Z.
1228   " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1229   *    SELECT BUKRS PARTY PAVAL
1230   *      FROM T001Z
1231   *      INTO TABLE LT_T001Z
1232   *      WHERE BUKRS IN S_BUKRS
1233   *       AND PARTY = 'J_1I02'.
1234       SELECT BUKRS PARTY PAVAL
1235         FROM T001Z
1236         INTO TABLE LT_T001Z
1237         WHERE BUKRS IN S_BUKRS
1238   AND PARTY = 'J_1I02'
1239         ORDER BY PRIMARY KEY.
1240   " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
1241       IF SY-SUBRC = 0.
1242         SORT LT_T001Z BY BUKRS.
1243       ENDIF.
1244
1245   *  Get the Deductor TAN details
1246       CLEAR  LT_J_1I_SECCO_CIT.
1247       SELECT BUKRS SECCODE TANNO ADRNR
1248         FROM J_1I_SECCO_CIT
1249         INTO TABLE LT_J_1I_SECCO_CIT
1250         WHERE BUKRS IN S_BUKRS.
1251       IF SY-SUBRC = 0.
1252         SORT LT_J_1I_SECCO_CIT BY BUKRS  SECCODE.
1253       ENDIF.
1254
1255   * Get the Deductor GSTIN details
1256       CLEAR LT_J_1BBRANCH.
1257   "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP on 13/06/2026
1258   *    SELECT BUKRS BRANCH NAME ADRNR GSTIN
1259   *      FROM J_1BBRANCH
1260   *      INTO TABLE LT_J_1BBRANCH
1261   *      WHERE BUKRS IN S_BUKRS.
1262       SELECT companycode, BUSINESSPLACE, BUSINESSPLACEDESCRIPTION, ADDRESSID, IN_GSTIDENTIFICATIONNUMBER
1263         FROM i_businessplace
1264         INTO TABLE @LT_J_1BBRANCH
1265         WHERE companycode IN @S_BUKRS.
1266   "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP on 13/06/2026
1267       IF SY-SUBRC = 0.
1268         SORT LT_J_1BBRANCH BY BUKRS BRANCH.
1269       ENDIF.
1270
1271   * Get the company code details.
1272       CLEAR LT_T001.
1273       SELECT BUKRS BUTXT KTOPL
1274         FROM T001
1275         INTO TABLE LT_T001
1276         WHERE BUKRS IN S_BUKRS.
1277       IF SY-SUBRC = 0.
1278         SORT LT_T001 BY BUKRS.
1279       ENDIF.
1280     ENDIF.
1281
1282   * Get the Service description
1283     CLEAR  LT_BSEG_T1.
1284     LT_BSEG_T1 =  LT_BSEG.
1285     DELETE  LT_BSEG_T1 WHERE HSN_SAC IS INITIAL.
1286     IF LT_BSEG_T1[] IS NOT INITIAL.
1287       CLEAR LT_ASMD.
1288       SELECT ASNUM TAXTARIFFCODE
1289       FROM ASMD
1290       APPENDING TABLE LT_ASMD
1291       FOR ALL ENTRIES IN LT_BSEG
1292       WHERE TAXTARIFFCODE = LT_BSEG-HSN_SAC.
1293       IF SY-SUBRC = 0.
1294         SORT LT_ASMD BY TAXTARIFFCODE.
1295       ENDIF.
1296
1297       SELECT SPRAS LAND1 STEUC TEXT1
1298         FROM T604N
1299         INTO TABLE LT_T604N1
1300         FOR ALL ENTRIES IN LT_BSEG
1301         WHERE SPRAS EQ SY-LANGU
1302         AND STEUC = LT_BSEG-HSN_SAC.
1303       IF SY-SUBRC = 0.
1304         APPEND LINES OF LT_T604N1 TO LT_T604N.
1305         CLEAR LT_T604N1.
1306       ENDIF.
1307     ENDIF.
1308
1309     SORT LT_ASMD BY TAXTARIFFCODE.
1310     IF LT_ASMD IS NOT INITIAL.
1311       SELECT ASNUM ASKTX
1312         FROM ASMDT
1313         INTO TABLE LT_ASMDT
1314         FOR ALL ENTRIES IN LT_ASMD
1315         WHERE ASNUM = LT_ASMD-ASNUM
1316         AND SPRAS = SY-LANGU.
1317       IF SY-SUBRC = 0 .
1318         SORT LT_ASMDT BY  ASNUM.
1319       ENDIF.
1320     ENDIF.
1321
1322   * Get the orginal document number
1323     IF LT_BSEG IS NOT INITIAL.
1324       LOOP AT LT_BSEG INTO LS_BSEG WHERE XBLNR IS NOT INITIAL.
1325         LV_BELNR = LS_BSEG-XBLNR+0(10).
1326         CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
1327           EXPORTING
1328             INPUT  = LV_BELNR
1329           IMPORTING
1330             OUTPUT = LV_BELNR.
1331
1332         IF LS_BSEG-BLART EQ 'RE' OR LS_BSEG-BLART EQ 'ZA'
1333                                  OR LS_BSEG-BLART EQ 'KS'. " added by zubair 21.03.24
1334           LS_BSEG_E-BUKRS = LS_BSEG-BUKRS.
1335           LS_BSEG_E-GJAHR = LS_BSEG-AWKEY+10(4).
1336           LS_BSEG_E-BELNR = LS_BSEG-AWKEY+0(10).
1337           IF LS_BSEG-AWKEY+10(4) IS NOT INITIAL.
1338             APPEND LS_BSEG_E TO LT_BSEG_E.
1339           ENDIF.
1340           CLEAR:LS_BSEG_E.
1341         ENDIF.
1342         CLEAR: LS_BSEG.
1343       ENDLOOP.
1344
1345       LOOP AT LT_BKPF_NEW INTO LS_BKPF_NEW.
1346         LS_BSEG_E-BUKRS = LS_BKPF_NEW-BUKRS.
1347         LS_BSEG_E-GJAHR = LS_BKPF_NEW-AWKEY+10(4).
1348         LS_BSEG_E-BELNR = LS_BKPF_NEW-AWKEY+0(10).
1349         IF LS_BKPF_NEW-AWKEY+10(4) IS NOT INITIAL.
1350           APPEND LS_BSEG_E TO LT_BSEG_E.
1351         ENDIF.
1352         CLEAR:LS_BSEG_E.
1353       ENDLOOP.
1354
1355       IF LT_BSEG_E IS NOT INITIAL.
1356         CLEAR LT_RBKP_RE .
1357         SELECT BELNR GJAHR BLART XRECH IVTYP
1358           FROM RBKP
1359           INTO TABLE LT_RBKP_RE
1360           FOR ALL ENTRIES IN LT_BSEG_E
1361           WHERE BELNR = LT_BSEG_E-BELNR
1362           AND GJAHR = LT_BSEG_E-GJAHR.
1363         IF SY-SUBRC = 0.
1364           SORT LT_RBKP_RE BY BELNR GJAHR.
1365         ENDIF.
1366       ENDIF.
1367     ENDIF.
1368
1369     SELECT *
1370       FROM ZEYTDS_STATECD
1371       INTO TABLE @DATA(LT_STATECD).
1372     IF SY-SUBRC = 0.
1373       SORT LT_STATECD BY REGIO.
1374     ENDIF.
1375
1376     SELECT *
1377       FROM ZEYTDS_RCMTAX
1378       INTO TABLE @DATA(LT_RCMTAX).                       "#EC CI_NOWHERE.
1379     IF SY-SUBRC = 0.
1380       SORT LT_RCMTAX BY TAX_CODE.
1381     ENDIF.
1382
1383     CLEAR  LT_BSEG_T1.
1384     LT_BSEG_T1 =  LT_BSEG.
1385     DELETE LT_BSEG_T1 WHERE WERKS IS INITIAL.
1386     IF LT_BSEG_T1[] IS NOT INITIAL.
1387
1388       SELECT WERKS, REGIO
1389         FROM T001W
1390         INTO TABLE @DATA(LT_T001W1)
1391         FOR ALL ENTRIES IN @LT_BSEG_T1
1392         WHERE WERKS = @LT_BSEG_T1-WERKS.
1393       IF SY-SUBRC = 0.
1394         SORT LT_T001W1 BY WERKS.
1395       ENDIF.
1396
1397       SELECT *
1398         FROM ZEYTDS_SEZMAP
1399         INTO TABLE @DATA(LT_SEZMAP)
1400          FOR ALL ENTRIES IN @LT_BSEG_T1
1401         WHERE WERKS = @LT_BSEG_T1-WERKS.
1402       IF SY-SUBRC = 0.
1403         SORT LT_SEZMAP BY WERKS.
1404       ENDIF.
1405
1406       SELECT *
1407         FROM ZEYTDS_PLANTMAP
1408         INTO TABLE @DATA(LT_PLANTMAP)
1409         FOR ALL ENTRIES IN @LT_BSEG_T1
1410         WHERE WERKS = @LT_BSEG_T1-WERKS.
1411       IF SY-SUBRC = 0.
1412         SORT LT_PLANTMAP BY WERKS.
1413       ENDIF.
1414
1415     ENDIF.
1416
1417     CLEAR  LT_BSEG_T1.
1418     LT_BSEG_T1 =  LT_BSEG.
1419     DELETE LT_BSEG_T1 WHERE BUPLA IS INITIAL.
1420     IF LT_BSEG_T1[] IS NOT INITIAL.
1421   "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP on 13/06/2026
1422   *    SELECT BUKRS, BRANCH, NAME, ADRNR, GSTIN
1423   *      FROM J_1BBRANCH
1424   *      INTO TABLE @DATA(LT_J_LBBRANCH1)
1425   *      FOR ALL ENTRIES IN @LT_BSEG_T1
1426   *      WHERE BRANCH = @LT_BSEG_T1-BUPLA.
1427       SELECT companycode, BUSINESSPLACE, BUSINESSPLACEDESCRIPTION, ADDRESSID, IN_GSTIDENTIFICATIONNUMBER
1428         FROM i_businessplace
1429         INTO TABLE @DATA(LT_J_LBBRANCH1)
1430         FOR ALL ENTRIES IN @LT_BSEG_T1
1431         WHERE BUSINESSPLACE = @LT_BSEG_T1-BUPLA.
1432   "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP on 13/06/2026
1433       IF SY-SUBRC = 0.
1434         SORT LT_J_LBBRANCH1 BY companycode BUSINESSPLACE.
1435
1436         SELECT ADDRNUMBER, NAME1, NAME2, CITY1, CITY2,  POST_CODE1, POST_CODE2, STREET,
1437               STR_SUPPL1, STR_SUPPL2, STR_SUPPL3, REGION
1438               INTO TABLE @DATA(LT_ADRC1)
1439               FROM ADRC
1440               FOR ALL ENTRIES IN @LT_J_LBBRANCH1
1441               WHERE ADDRNUMBER = @LT_J_LBBRANCH1-ADDRESSID .
1442         IF SY-SUBRC = 0.
1443           SORT LT_ADRC1 BY ADDRNUMBER.
1444         ENDIF.
1445       ENDIF.
1446     ENDIF.
1447
1448
1449     DATA LR_KTOSL TYPE RANGE OF BSEG-KTOSL.
1450
1451     SELECT 'I', 'EQ', KTOSL
1452       FROM ZEYTDS_TRANS
1453       INTO TABLE  @LR_KTOSL .                            "#EC CI_NOWHERE.
1454     IF SY-SUBRC = 0.
1455       SORT LR_KTOSL BY LOW.
1456     ENDIF.
1457
1458
1459     DELETE LT_BSEG_WRX WHERE KTOSL NOT IN LR_KTOSL.
1460     LT_BSEG_WRX1 = LT_BSEG_WRX.
1461     LT_BSEG_PO   = LT_BSEG_WRX.
1462
1463     DELETE LT_BSEG_WRX1 WHERE EBELN IS INITIAL AND EBELP IS INITIAL AND ZEKKN IS INITIAL.
1464
1465     IF LT_BSEG_WRX1 IS NOT INITIAL.
1466       CLEAR LT_EKKN.
1467       SELECT EBELN EBELP ZEKKN SAKTO
1468         FROM EKKN
1469         INTO TABLE LT_EKKN
1470         FOR ALL ENTRIES IN LT_BSEG_WRX1
1471         WHERE EBELN = LT_BSEG_WRX1-EBELN
1472         AND EBELP = LT_BSEG_WRX1-EBELP
1473         AND ZEKKN = LT_BSEG_WRX1-ZEKKN.
1474       IF SY-SUBRC = 0.
1475         SORT LT_EKKN BY EBELN EBELP ZEKKN.
1476
1477         SELECT SAKNR TXT20 TXT50 KTOPL
1478           FROM SKAT
1479           APPENDING TABLE LT_SKAT
1480           FOR ALL ENTRIES IN LT_EKKN
1481           WHERE SPRAS = SY-LANGU
1482          AND KTOPL = LV_KTOPL
1483           AND SAKNR = LT_EKKN-SAKTO.
1484       ENDIF.
1485
1486       CLEAR LT_EKPO1.
1487       SELECT EBELN EBELP MATNR MATKL WERKS BWTAR PSTYP
1488         FROM EKPO
1489         INTO TABLE LT_EKPO1
1490         FOR ALL ENTRIES IN LT_BSEG_WRX1
1491         WHERE EBELN = LT_BSEG_WRX1-EBELN
1492         AND EBELP = LT_BSEG_WRX1-EBELP.
1493       IF SY-SUBRC = 0.
1494         SORT LT_EKPO1 BY EBELN EBELP.
1495
1496         CLEAR R_MATNR.
1497         LOOP AT LT_EKPO1 INTO DATA(WA_EKPO).
1498           LS_MATNR-SIGN = 'I'.
1499           LS_MATNR-OPTION = 'EQ'.
1500           LS_MATNR-LOW = WA_EKPO-MATNR.
1501           APPEND LS_MATNR TO R_MATNR.
1502           CLEAR: LS_MATNR, WA_EKPO.
1503         ENDLOOP.
1504
1505         CLEAR LT_T001W.
1506         SELECT WERKS NAME1 BWKEY
1507           FROM T001W
1508           INTO TABLE LT_T001W
1509           FOR ALL ENTRIES IN LT_EKPO1
1510           WHERE WERKS = LT_EKPO1-WERKS.
1511         IF SY-SUBRC = 0.
1512           SORT LT_T001W BY  WERKS.
1513
1514           CLEAR LT_MBEW.
1515           SELECT MATNR BWKEY BWTAR BKLAS
1516             FROM MBEW
1517             INTO TABLE LT_MBEW
1518             FOR ALL ENTRIES IN LT_T001W
1519             WHERE MATNR IN R_MATNR
1520             AND BWKEY = LT_T001W-BWKEY.
1521           IF SY-SUBRC = 0.
1522             SORT LT_MBEW BY MATNR BWKEY.
1523
1524             READ TABLE LT_T001 INTO LS_T001 INDEX 1.
1525   " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1526   *          SELECT KTOPL KTOSL BWMOD KOMOK BKLAS KONTS
1527   *            FROM T030
1528   *            INTO TABLE LT_T030
1529   *            FOR ALL ENTRIES IN LT_MBEW
1530   *            WHERE KTOPL = LS_T001-KTOPL
1531   *            AND KTOSL = 'BSX'
1532   *            AND BKLAS = LT_MBEW-BKLAS.
1533             SELECT KTOPL KTOSL BWMOD KOMOK BKLAS KONTS
1534               FROM T030
1535               INTO TABLE LT_T030
1536               FOR ALL ENTRIES IN LT_MBEW
1537               WHERE KTOPL = LS_T001-KTOPL
1538               AND KTOSL = 'BSX'
1539               AND BKLAS = LT_MBEW-BKLAS. "#EC CI_NOORDER
1540   " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
1541             IF SY-SUBRC = 0.
1542               SORT LT_T030.
1543               SELECT SAKNR TXT20 TXT50 KTOPL
1544                 FROM SKAT
1545                 APPENDING TABLE LT_SKAT
1546                 FOR ALL ENTRIES IN LT_T030
1547                 WHERE SPRAS = SY-LANGU
1548                 AND KTOPL = LV_KTOPL
1549                 AND SAKNR = LT_T030-KONTS .
1550             ENDIF.
1551           ENDIF.
1552         ENDIF.
1553       ENDIF.
1554     ENDIF.
1555
1556     DELETE LT_BSEG_PO WHERE EBELN IS INITIAL .
1557
1558   *  IF LT_BSEG_PO IS NOT INITIAL.
1559
1560   *    SELECT bukrs,  belnr,  gjahr, buzid, augbl, ebeln,  ebelp
1561   *      FROM bseg
1562   *      INTO TABLE @DATA(lt_bseg_wrx_po_t1)
1563   *      FOR ALL ENTRIES IN @lt_bseg_po
1564   *      WHERE  bukrs  = @lt_bseg_po-bukrs
1565   *      AND belnr = @lt_bseg_po-belnr
1566   *      AND gjahr = @lt_bseg_po-gjahr
1567   *      AND ebeln = @lt_bseg_po-ebeln
1568   *      AND ebelp = @lt_bseg_po-ebelp.
1569   *
1570   *    IF lt_bseg_wrx_po_t1[] IS NOT INITIAL.
1571   *      SELECT bukrs,  belnr,  gjahr, buzei,  buzid, hkont,  ebeln,  ebelp
1572   *     FROM bseg
1573   *     INTO TABLE @DATA(lt_bseg_wrx_po_t2)
1574   *     FOR ALL ENTRIES IN @lt_bseg_wrx_po_t1
1575   *     WHERE  bukrs  = @lt_bseg_wrx_po_t1-bukrs
1576   *      AND belnr = @lt_bseg_wrx_po_t1-belnr
1577   *      AND gjahr = @lt_bseg_wrx_po_t1-gjahr
1578   *      AND augbl = @lt_bseg_wrx_po_t1-augbl
1579   *     AND ebeln = @lt_bseg_wrx_po_t1-ebeln
1580   *     AND ebelp = @lt_bseg_wrx_po_t1-ebelp.
1581   *    ENDIF.
1582   *
1583   *    IF lt_bseg_wrx_po_t1[] IS NOT INITIAL.
1584   *      SELECT bukrs  belnr  gjahr buzei  buzid hkont  ebeln  ebelp
1585   *        FROM bseg
1586   *        INTO TABLE lt_bseg_wrx_po
1587   *        FOR ALL ENTRIES IN lt_bseg_wrx_po_t1
1588   *        WHERE  bukrs  = lt_bseg_wrx_po_t1-bukrs
1589   *      AND belnr = lt_bseg_wrx_po_t1-belnr
1590   *      AND gjahr = lt_bseg_wrx_po_t1-gjahr
1591   *        AND ebeln = lt_bseg_wrx_po_t1-ebeln
1592   *        AND ebelp = lt_bseg_wrx_po_t1-ebelp
1593   *       AND buzid = 'M'.
1594   *    ENDIF.
1595
1596
1597   *    SELECT BUKRS  BELNR  GJAHR BUZEI  BUZID HKONT  EBELN  EBELP
1598   *      FROM BSEG
1599   *      INTO TABLE LT_BSEG_WRX_PO
1600   *      FOR ALL ENTRIES IN LT_BSEG_PO
1601   *      WHERE  BUKRS  = LT_BSEG_PO-BUKRS
1602   **      AND belnr = lt_bseg_po-belnr
1603   **      AND gjahr = lt_bseg_po-gjahr
1604   *      AND EBELN = LT_BSEG_PO-EBELN
1605   *      AND EBELP = LT_BSEG_PO-EBELP.
1606   **     AND BUZID = 'M'.
1607   *    IF SY-SUBRC  = 0.
1608   *      SELECT SAKNR TXT20 TXT50 KTOPL
1609   *      FROM SKAT
1610   *      APPENDING TABLE LT_SKAT
1611   *      FOR ALL ENTRIES IN LT_BSEG_WRX_PO
1612   *      WHERE SPRAS = SY-LANGU
1613   *      AND KTOPL = LV_KTOPL
1614   *      AND SAKNR = LT_BSEG_WRX_PO-HKONT .
1615   *    ENDIF.
1616   *  ENDIF.
1617
1618
1619
1620     DATA: LS_TDS_GL_NEW LIKE LINE OF LT_TDS_GL.
1621     LOOP AT LT_TDS_GL INTO LS_TDS_GL_NEW.
1622       RS_TDS-SIGN = 'I'.
1623       RS_TDS-OPTION = 'EQ'.
1624       RS_TDS-LOW = LS_TDS_GL_NEW-HKONT.
1625       APPEND RS_TDS TO R_TDS.
1626       CLEAR:RS_TDS.
1627     ENDLOOP.
1628     SELECT BUKRS BUTXT FROM T001 INTO TABLE LT_T001_NEW WHERE BUKRS IN S_BUKRS.
1629
1630     DATA:R_KTOPL TYPE RANGE OF SKAT-KTOPL.
1631     DATA:RS_KTOPL LIKE LINE OF R_KTOPL.
1632     LOOP AT LT_T001_NEW INTO LS_T001_NEW.
1633       RS_KTOPL-SIGN = 'I'.
1634       RS_KTOPL-OPTION = 'EQ'.
1635       RS_KTOPL-LOW = LS_T001_NEW-KTOPL.
1636       APPEND RS_KTOPL TO R_KTOPL.
1637       CLEAR:RS_KTOPL.
1638     ENDLOOP.
1639
1640     DELETE R_KTOPL WHERE LOW IS INITIAL.
1641     IF R_KTOPL[] IS NOT INITIAL.
1642       DELETE LT_SKAT WHERE KTOPL NOT IN R_KTOPL.
1643     ENDIF.
1644
1645   *Move the data to final internal table.
1646     SORT LT_BSEG_K DESCENDING BY BUKRS BELNR GJAHR BUZEI EBELP.
1647     SORT LT_BSEG DESCENDING BY BUKRS BELNR GJAHR BUZEI.
1648   *  SORT lt_bseg2 BY bukrs belnr gjahr.
1649     SORT LT_BSEG_V BY BUKRS BELNR GJAHR.
1650     SORT LT_SKAT BY SAKNR .
1651
1652
1653     DELETE LT_T604N WHERE STEUC IS INITIAL.   " zubair 27.3.24
1654     DELETE LT_T604N WHERE TEXT1 IS INITIAL.
1655     SORT LT_T604N BY STEUC.                   " Zubair 27.3.24
1656
1657
1658     SORT LT_BSEG_TDS BY BUKRS BELNR GJAHR TXGRP.
1659     SORT LT_BSEG_TDS2 BY BUKRS BELNR GJAHR MWSKZ.
1660
1661     DELETE LT_WITH_ITEM WHERE WT_QSSHH IS INITIAL .
1662     DELETE LT_WITH_ITEM_TEMP WHERE WT_QSSHH IS INITIAL .
1663
1664     IF LT_WITH_ITEM[] IS NOT INITIAL.
1665       CLEAR LT_TDS_SEC.
1666       SELECT *
1667         FROM ZEYTDS_TDS_SEC
1668         INTO TABLE LT_TDS_SEC
1669         FOR ALL ENTRIES IN LT_WITH_ITEM
1670         WHERE WITHT     = LT_WITH_ITEM-WITHT
1671         AND WT_WITHCD   = LT_WITH_ITEM-WT_WITHCD.
1672     ENDIF.
1673
1674     IF LT_WITH_ITEM_TEMP[] IS NOT INITIAL.
1675       SELECT *
1676         FROM ZEYTDS_TDS_SEC
1677         APPENDING TABLE LT_TDS_SEC
1678         FOR ALL ENTRIES IN LT_WITH_ITEM
1679         WHERE WITHT     = LT_WITH_ITEM-WITHT
1680         AND WT_WITHCD   = LT_WITH_ITEM-WT_WITHCD.
1681     ENDIF.
1682
1683     IF LT_TDS_SEC IS NOT INITIAL.
1684       SORT LT_TDS_SEC BY WITHT WT_WITHCD APPL.
1685     ENDIF.
1686
1687
1688     SORT LT_WITH_ITEM BY BUKRS BELNR GJAHR WITHT.
1689     LT_BSEG_P = LT_BSEG.
1690
1691     "SOC-15.04.2024
1692     DATA(LT_WITH_ITEM_T2) = LT_WITH_ITEM.
1693     IF LT_WITH_ITEM_T2 IS NOT INITIAL.
1694       APPEND LINES OF LT_WITH_ITEM_TEMP TO LT_WITH_ITEM_T2.
1695     ENDIF.
1696
1697     DELETE ADJACENT DUPLICATES FROM LT_WITH_ITEM_T2 COMPARING  BUKRS BELNR GJAHR.
1698     DATA: COUNT TYPE I.
1699     LOOP AT LT_WITH_ITEM_T2 INTO DATA(LS_WITH_ITEM_T2).
1700       LOOP AT LT_WITH_ITEM INTO LS_WITH_ITEM  WHERE  BUKRS = LS_WITH_ITEM_T2-BUKRS
1701                                                 AND  BELNR = LS_WITH_ITEM_T2-BELNR
1702                                                 AND  GJAHR = LS_WITH_ITEM_T2-GJAHR .
1703
1704         READ TABLE LT_TDS_SEC INTO LS_TDS_SEC WITH KEY WITHT     = LS_WITH_ITEM-WITHT
1705                                                     WT_WITHCD    = LS_WITH_ITEM-WT_WITHCD
1706                                                     APPL         = 'X'.
1707         IF SY-SUBRC EQ 0.
1708           COUNT = COUNT + 1.
1709         ELSE.
1710           READ TABLE LT_TDS_SEC INTO LS_TDS_SEC WITH KEY WITHT = LS_WITH_ITEM-WITHT
1711                                                           APPL = 'X'.
1712           IF SY-SUBRC EQ 0.
1713             COUNT = COUNT + 1.
1714           ENDIF.
1715         ENDIF.
1716       ENDLOOP.
1717
1718       IF COUNT = 1.
1719         CLEAR LS_TDS_SEC.
1720         LOOP AT LT_WITH_ITEM INTO LS_WITH_ITEM  WHERE  BUKRS = LS_WITH_ITEM_T2-BUKRS
1721                                                AND  BELNR = LS_WITH_ITEM_T2-BELNR
1722                                                AND  GJAHR = LS_WITH_ITEM_T2-GJAHR .
1723
1724           READ TABLE LT_TDS_SEC INTO LS_TDS_SEC WITH KEY WITHT = LS_WITH_ITEM-WITHT
1725                                                      WT_WITHCD = LS_WITH_ITEM-WT_WITHCD.
1726           IF SY-SUBRC EQ 0 AND LS_TDS_SEC-APPL IS INITIAL.
1727             DELETE LT_WITH_ITEM WHERE BUKRS  = LS_WITH_ITEM-BUKRS
1728                                   AND BELNR  = LS_WITH_ITEM-BELNR
1729                                   AND GJAHR  = LS_WITH_ITEM-GJAHR
1730                                   AND WITHT  = LS_WITH_ITEM-WITHT
1731                                   AND WT_WITHCD =  LS_WITH_ITEM-WT_WITHCD.
1732
1733             DELETE LT_WITH_ITEM_TEMP  WHERE BUKRS  = LS_WITH_ITEM-BUKRS
1734                                 AND BELNR  = LS_WITH_ITEM-BELNR
1735                                 AND GJAHR  = LS_WITH_ITEM-GJAHR
1736                                 AND WITHT  = LS_WITH_ITEM-WITHT
1737                                 AND WT_WITHCD =  LS_WITH_ITEM-WT_WITHCD.
1738           ELSE.
1739             CLEAR LS_TDS_SEC.
1740             READ TABLE LT_TDS_SEC INTO LS_TDS_SEC WITH KEY WITHT = LS_WITH_ITEM-WITHT.
1741
1742             IF SY-SUBRC EQ 0 AND LS_TDS_SEC-APPL IS INITIAL.
1743               DELETE LT_WITH_ITEM WHERE BUKRS  = LS_WITH_ITEM-BUKRS
1744                                  AND BELNR  = LS_WITH_ITEM-BELNR
1745                                  AND GJAHR  = LS_WITH_ITEM-GJAHR
1746                                  AND WITHT  = LS_WITH_ITEM-WITHT
1747                                  AND WT_WITHCD IS INITIAL.
1748
1749               DELETE LT_WITH_ITEM_TEMP WHERE BUKRS  = LS_WITH_ITEM-BUKRS
1750                                 AND BELNR  = LS_WITH_ITEM-BELNR
1751                                 AND GJAHR  = LS_WITH_ITEM-GJAHR
1752                                 AND WITHT  = LS_WITH_ITEM-WITHT
1753                                 AND WT_WITHCD IS INITIAL.
1754             ENDIF.
1755           ENDIF.
1756           CLEAR:LS_TDS_SEC ,LS_WITH_ITEM.
1757         ENDLOOP.
1758       ENDIF.
1759       CLEAR:COUNT,LS_WITH_ITEM_T2.
1760     ENDLOOP.
1761     "EOC-15.04.2024
1762
1763
1764     SORT LT_BSEG_P BY BUKRS BELNR GJAHR.
1765     DELETE LT_BSEG_P WHERE PRCTR = SPACE.
1766   *  LT_WITH_ITEM_TDS[] = LT_WITH_ITEM_TEMP[]."AM-27-03-2024
1767
1768   *  **-->>for "AM-27-03-2024
1769     SELECT * FROM FIWTIN_TDS_MAP
1770              INTO TABLE @DATA(LT_FIWTIN)
1771              WHERE LAND1      = 'IN'.
1772     SELECT WITHT FROM T059P
1773                  INTO TABLE @DATA(LT_TAXTYP)
1774                  WHERE WT_POSTM = '1'.
1775
1776     LOOP AT LT_WITH_ITEM_TEMP INTO DATA(LS_WTTEMP).
1777       READ TABLE LT_TAXTYP TRANSPORTING NO FIELDS
1778                            WITH KEY WITHT = LS_WTTEMP-WITHT.
1779       IF SY-SUBRC EQ 0.
1780         APPEND LS_WTTEMP TO LT_WITH_ITEM_TDS.
1781       ENDIF.
1782       CLEAR LS_WTTEMP.
1783     ENDLOOP.
1784   * **-->>for "AM-27-03-2024
1785
1786     LT_BSEG_A = LT_BSEG.
1787     SORT LT_BSEG_A BY BUKRS BELNR GJAHR.
1788
1789     DELETE LT_BSEG_A WHERE ZUONR = SPACE AND KOART = 'K'.
1790
1791     LT_BSEG_WE = LT_BSEG.
1792     SORT LT_BSEG_WE BY BUKRS BELNR GJAHR.
1793
1794     DELETE LT_BSEG_WE WHERE WERKS EQ ' '.
1795
1796     LT_BSEG_G = LT_BSEG.
1797     SORT LT_BSEG_G BY BUKRS BELNR GJAHR.
1798
1799     LT_BSEG_S = LT_BSEG.
1800     SORT LT_BSEG_S BY BUKRS BELNR GJAHR.
1801     DELETE LT_BSEG_S WHERE ZEKKN EQ ' '.
1802
1803     LT_BSEG_HIGH = LT_BSEG_LOW = LT_BSEG_K.
1804     SORT LT_BSEG_LOW BY BUDAT.
1805     SORT LT_BSEG_HIGH BY BUDAT DESCENDING.
1806
1807     READ TABLE  LT_BSEG_LOW INTO LS_BSEG_K INDEX 1.
1808     IF SY-SUBRC EQ 0.
1809       CONCATENATE LS_BSEG_K-BUDAT+6(2) LS_BSEG_K-BUDAT+4(2)
1810                   LS_BSEG_K-BUDAT+0(4) INTO GV_LOW SEPARATED BY '-'  .
1811     ENDIF.
1812
1813
1814     READ TABLE  LT_BSEG_HIGH INTO LS_BSEG_K INDEX 1.
1815     IF SY-SUBRC EQ 0.
1816       CONCATENATE LS_BSEG_K-BUDAT+6(2) LS_BSEG_K-BUDAT+4(2)
1817                   LS_BSEG_K-BUDAT+0(4) INTO GV_HIGH SEPARATED BY '-'  .
1818     ENDIF.
1819     CLEAR LS_BSEG_K.
1820
1821     IF R_BLART[] IS NOT INITIAL.
1822       LT_BKPF_NEW2[] = LT_BKPF_NEW[].
1823       DELETE LT_BKPF_NEW WHERE BLART IN R_BLART.
1824
1825       LOOP AT LT_BSEG_K INTO LS_BSEG_K.
1826         READ TABLE LT_BKPF_NEW INTO LS_BKPF_NEW WITH  KEY BUKRS = LS_BSEG_K-BUKRS
1827                                                           BELNR = LS_BSEG_K-STBLG
1828                                                           GJAHR = LS_BSEG_K-STJAH BINARY SEARCH.
1829         IF SY-SUBRC = 0.
1830           DELETE LT_BSEG_K WHERE BUKRS = LS_BKPF_NEW-BUKRS
1831                              AND STJAH = LS_BKPF_NEW-GJAHR
1832                              AND STBLG = LS_BKPF_NEW-BELNR.
1833
1834           LS_DEL_BEL-BUKRS = LS_BSEG_K-BUKRS.
1835           LS_DEL_BEL-BELNR = LS_BSEG_K-BELNR.
1836           LS_DEL_BEL-GJAHR = LS_BSEG_K-GJAHR.
1837           APPEND LS_DEL_BEL TO LT_DEL_BEL.
1838           CLEAR:LS_DEL_BEL, LS_BKPF_NEW.
1839         ELSE.
1840
1841           READ TABLE LT_BKPF_NEW INTO LS_BKPF_NEW WITH  KEY BUKRS = LS_BSEG_K-BUKRS
1842                                                             BELNR = LS_BSEG_K-REBZG
1843                                                             GJAHR = LS_BSEG_K-REBZJ BINARY SEARCH.
1844           IF SY-SUBRC = 0.
1845             DELETE LT_BSEG_K WHERE BUKRS = LS_BKPF_NEW-BUKRS
1846                                AND REBZJ = LS_BKPF_NEW-GJAHR
1847                                AND REBZG = LS_BKPF_NEW-BELNR.
1848
1849             LS_DEL_BEL-BUKRS = LS_BSEG_K-BUKRS.
1850             LS_DEL_BEL-BELNR = LS_BSEG_K-BELNR.
1851             LS_DEL_BEL-GJAHR = LS_BSEG_K-GJAHR.
1852             APPEND LS_DEL_BEL TO LT_DEL_BEL.
1853             CLEAR:LS_DEL_BEL, LS_BKPF_NEW.
1854           ENDIF.
1855         ENDIF.
1856       ENDLOOP.
1857     ENDIF.
1858
1859     IF LT_BSEG_W[] IS NOT INITIAL.
1860       CLEAR:IT_SKAT.
1861       SELECT SAKNR TXT50
1862         FROM SKAT
1863         INTO TABLE IT_SKAT
1864         FOR ALL ENTRIES IN LT_BSEG_W
1865         WHERE SPRAS = SY-LANGU
1866         AND KTOPL = LV_KTOPL
1867         AND   SAKNR = LT_BSEG_W-HKONT.
1868       IF SY-SUBRC = 0.
1869         SORT IT_SKAT BY SAKNR.
1870       ENDIF.
1871
1872       SELECT A~MATNR, A~WERKS, A~STEUC, B~TEXT1
1873         FROM MARC AS A INNER JOIN T604N AS B
1874         ON ( B~SPRAS = @SY-LANGU AND B~LAND1 = 'IN' AND A~STEUC = B~STEUC )
1875         FOR ALL ENTRIES IN @LT_BSEG_W
1876         WHERE A~MATNR = @LT_BSEG_W-MATNR
1877         AND A~WERKS = @LT_BSEG_W-WERKS
1878         INTO TABLE @DATA(T_MARC).
1879       IF SY-SUBRC = 0.
1880         SORT T_MARC BY MATNR WERKS.
1881       ENDIF.
1882
1883       DELETE T_MARC WHERE MATNR IS INITIAL.
1884     ENDIF.
1885
1886     CLEAR:LS_BSEG_K.
1887     DELETE ADJACENT DUPLICATES FROM LT_BSEG_K COMPARING BUKRS GJAHR BELNR LIFNR.
1888     SORT LT_BSEG_K BY BUKRS GJAHR BELNR BUZEI.
1889     DELETE ADJACENT DUPLICATES FROM LT_BSEG_K COMPARING BUKRS BELNR GJAHR BUZEI.
1890
1891     DELETE LT_BSEG_K WHERE UMSKZ <> ' '.
1892
1893     LOOP AT LT_BSEG_K INTO LS_BSEG_K.
1894
1895       READ TABLE LT_LFA1 INTO LS_LFA1 WITH  KEY LIFNR = LS_BSEG_K-LIFNR BINARY SEARCH.
1896       IF SY-SUBRC = 0.
1897         READ TABLE LT_ACCT_GROUP TRANSPORTING NO FIELDS WITH  KEY KTOKK = LS_LFA1-KTOKK BINARY SEARCH.
1898         IF SY-SUBRC = 0.
1899           CONTINUE.
1900         ENDIF.
1901       ENDIF.
1902
1903       CLEAR : GS_FINAL_TDS.
1904       GS_FINAL_TDS-SECCO        = LS_BSEG_K-SECCO.
1905
1906       GS_FINAL_TDS-ERP_DOC_TYPE = LS_BSEG_K-BLART.
1907       GS_FINAL_TDS-USERNAME     = LS_BSEG_K-USNAM.
1908
1909   * Get Currency Key.
1910       GS_FINAL_TDS-CURRENCY     = LS_BSEG_K-WAERS.
1911
1912   * Get Exchange Rate.
1913       IF LS_BSEG_K-KURSF LT 0.
1914         GS_FINAL_TDS-EXCH_RATE = LS_BSEG_K-KURSF * -1.
1915       ELSE.
1916         GS_FINAL_TDS-EXCH_RATE   = LS_BSEG_K-KURSF.
1917       ENDIF.
1918       GS_FINAL_TDS-TRANS_CODE   = LS_BSEG_K-TCODE.
1919
1920   *Begin Code for Original Document No. & Original Document Date.
1921       IF LS_BSEG_K-XREVERSAL = 2.
1922         GS_FINAL_TDS-ORG_DOC_NUM   = LS_BSEG_K-STBLG.
1923
1924         IF GS_FINAL_TDS-ORG_DOC_NUM IS NOT INITIAL.
1925           READ TABLE LT_BKPF_NEW2 INTO LS_BKPF_NEW WITH KEY BUKRS = LS_BSEG_K-BUKRS
1926                                                             BELNR = LS_BSEG_K-STBLG
1927                                                             GJAHR = LS_BSEG_K-STJAH BINARY SEARCH.
1928           IF SY-SUBRC = 0.
1929             GS_FINAL_TDS-BLART_CR = LS_BKPF_NEW-BLART.
1930             CONCATENATE LS_BKPF_NEW-BUDAT+6(2) LS_BKPF_NEW-BUDAT+4(2)
1931             LS_BKPF_NEW-BUDAT+0(4)   INTO GS_FINAL_TDS-ORG_DOC_DATE SEPARATED BY '-'  .
1932           ENDIF.
1933         ENDIF.
1934
1935         CLEAR LV_GJAHR.
1936         LV_GJAHR  = LS_BSEG_K-AWKEY+10(4).
1937
1938         READ TABLE LT_RBKP INTO LS_RBKP WITH KEY BELNR = LS_BSEG_K-AWKEY+0(10)
1939                                                  GJAHR = LV_GJAHR BINARY SEARCH.
1940         IF SY-SUBRC = 0.
1941           CONCATENATE LS_RBKP-STBLG LS_RBKP-STJAH INTO LV_AWKEY.
1942           CLEAR LV_BLART.
1943
1944           LV_BLART = GS_FINAL_TDS-ERP_DOC_TYPE.
1945           READ TABLE LT_BKPF_NEW INTO LS_BKPF_NEW WITH KEY BLART = LV_BLART
1946                                                            AWKEY = LV_AWKEY.
1947           IF SY-SUBRC = 0.
1948             GS_FINAL_TDS-ORG_DOC_NUM   = LS_BKPF_NEW-BELNR.
1949
1950             IF GS_FINAL_TDS-ORG_DOC_NUM IS NOT INITIAL.
1951               GS_FINAL_TDS-BLART_CR = LS_BKPF_NEW-BLART.
1952
1953               CONCATENATE LS_BKPF_NEW-BUDAT+6(2)
1954                           LS_BKPF_NEW-BUDAT+4(2) LS_BKPF_NEW-BUDAT+0(4)
1955                           INTO GS_FINAL_TDS-ORG_DOC_DATE SEPARATED BY '-'  .
1956             ENDIF.
1957
1958           ENDIF.
1959         ENDIF.
1960
1961
1962       ELSEIF LS_BSEG_K-TCODE = 'MR8M'.
1963         CLEAR LV_GJAHR.
1964         LV_GJAHR =  LS_BSEG_K-AWKEY+10(4).
1965         READ TABLE LT_RBKP_O TRANSPORTING NO FIELDS WITH KEY BELNR = LS_BSEG_K-AWKEY+0(10)
1966                                                              GJAHR = LV_GJAHR
1967                                                              BUKRS = LS_BSEG_K-BUKRS.
1968         IF SY-SUBRC IS INITIAL.
1969
1970           GS_FINAL_TDS-ORG_DOC_NUM   = LS_BSEG_K-REBZG.
1971
1972           READ TABLE LT_BKPF_NEW INTO LS_BKPF_NEW WITH  KEY BUKRS = LS_BSEG_K-BUKRS
1973                                                           BELNR = LS_BSEG_K-REBZG
1974                                                           GJAHR = LS_BSEG_K-REBZJ BINARY SEARCH.
1975           IF SY-SUBRC = 0.
1976             CONCATENATE LS_BKPF_NEW-BUDAT+6(2)
1977                       LS_BKPF_NEW-BUDAT+4(2)
1978                       LS_BKPF_NEW-BUDAT+0(4)
1979                       INTO GS_FINAL_TDS-ORG_DOC_DATE SEPARATED BY '-'  .
1980             CLEAR LS_BKPF_NEW.
1981           ENDIF.
1982         ENDIF.
1983
1984         CLEAR LV_GJAHR.
1985         LV_GJAHR = LS_BSEG_K-AWKEY+10(4).
1986         READ TABLE LT_RBKP INTO LS_RBKP WITH KEY BELNR = LS_BSEG_K-AWKEY+0(10)
1987                                                          GJAHR = LV_GJAHR BINARY SEARCH.
1988         IF SY-SUBRC = 0.
1989           CONCATENATE LS_RBKP-STBLG LS_RBKP-STJAH INTO LV_AWKEY_NEW.
1990
1991           CLEAR:LV_AWKEY, LV_BLART.
1992           LV_BLART = GS_FINAL_TDS-ERP_DOC_TYPE.
1993           LV_AWKEY = LV_AWKEY_NEW.
1994           READ TABLE LT_BKPF_NEW2 INTO LS_BKPF_NEW WITH KEY BLART = LV_BLART
1995                                                             AWKEY = LV_AWKEY.
1996           IF SY-SUBRC = 0.
1997             GS_FINAL_TDS-ORG_DOC_NUM   = LS_BKPF_NEW-BELNR.
1998
1999             IF GS_FINAL_TDS-ORG_DOC_NUM IS NOT INITIAL.
2000               GS_FINAL_TDS-BLART_CR = LS_BKPF_NEW-BLART.
2001
2002               CONCATENATE LS_BKPF_NEW-BUDAT+6(2)
2003                           LS_BKPF_NEW-BUDAT+4(2)
2004                           LS_BKPF_NEW-BUDAT+0(4)
2005                           INTO GS_FINAL_TDS-ORG_DOC_DATE SEPARATED BY '-'  .
2006
2007             ENDIF.
2008             CLEAR LS_BKPF_NEW.
2009           ENDIF.
2010           CLEAR LS_RBKP.
2011         ENDIF.
2012       ENDIF.
2013
2014   * Get Assignment No.
2015       READ TABLE LT_BSEG_A INTO LS_BSEG_A WITH KEY BUKRS = LS_BSEG_K-BUKRS
2016                                                    BELNR = LS_BSEG_K-BELNR
2017                                                    GJAHR = LS_BSEG_K-GJAHR BINARY SEARCH .
2018       IF SY-SUBRC = 0.
2019         GS_FINAL_TDS-ASSIGN_NUM = LS_BSEG_A-ZUONR.
2020         CLEAR LS_BSEG_A.
2021       ENDIF.
2022
2023       READ TABLE LT_BSEG_S INTO LS_BSEG_S WITH KEY BUKRS = LS_BSEG_K-BUKRS
2024                                                    BELNR = LS_BSEG_K-BELNR
2025                                                    GJAHR = LS_BSEG_K-GJAHR BINARY SEARCH .
2026       IF SY-SUBRC = 0.
2027         GS_FINAL_TDS-ACCOUNT_SEQ = LS_BSEG_S-ZEKKN.
2028         CLEAR LS_BSEG_S.
2029       ENDIF.
2030
2031   *Get Plant & Profit Center.
2032       READ TABLE LT_BSEG_P INTO LS_BSEG_P WITH KEY BUKRS = LS_BSEG_K-BUKRS
2033                                                    BELNR = LS_BSEG_K-BELNR
2034                                                    GJAHR = LS_BSEG_K-GJAHR BINARY SEARCH .
2035       IF SY-SUBRC = 0.
2036         GS_FINAL_TDS-PROFIT_CENTER = LS_BSEG_P-PRCTR.
2037         CLEAR LS_BSEG_P.
2038       ENDIF.
2039
2040       READ TABLE LT_BSEG_WE INTO LS_BSEG_WE WITH KEY BUKRS = LS_BSEG_K-BUKRS
2041                                                      BELNR = LS_BSEG_K-BELNR
2042                                                      GJAHR = LS_BSEG_K-GJAHR BINARY SEARCH .
2043       IF SY-SUBRC = 0.
2044         GS_FINAL_TDS-PLANT = LS_BSEG_WE-WERKS.
2045         CLEAR LS_BSEG_WE.
2046       ENDIF.
2047
2048   *Get GR/IR Value,
2049       GS_FINAL_TDS-VEND_INV_NUM  = LS_BSEG_K-XBLNR.
2050       GS_FINAL_TDS-ERP_NUM  = LS_BSEG_K-BELNR.
2051       GS_FINAL_TDS-BELNR = GS_FINAL_TDS-DOCUMENT_NUMB = LS_BSEG_K-BELNR.
2052
2053       CONCATENATE LS_BSEG_K-BLDAT+6(2) LS_BSEG_K-BLDAT+4(2)
2054                   LS_BSEG_K-BLDAT+0(4)   INTO GS_FINAL_TDS-DOCUMENTDATE SEPARATED BY '-'  .
2055
2056       CONCATENATE LS_BSEG_K-BUDAT+6(2) LS_BSEG_K-BUDAT+4(2)
2057                   LS_BSEG_K-BUDAT+0(4)   INTO GS_FINAL_TDS-POST_DAT_DOCU SEPARATED BY '-'  .
2058
2059       GS_FINAL_TDS-BUDAT = LS_BSEG_K-BUDAT.
2060       IF LS_BSEG_K-BLART = 'WE'.
2061         CONTINUE.
2062       ENDIF.
2063
2064       SORT LT_BSEG_W BY BUKRS BELNR GJAHR DMBTR DESCENDING.
2065
2066       CLEAR : LV_TDS_AMT.
2067       LOOP AT LT_BSEG_W INTO LS_BSEG WHERE BUKRS = LS_BSEG_K-BUKRS
2068                                        AND BELNR = LS_BSEG_K-BELNR
2069                                        AND GJAHR = LS_BSEG_K-GJAHR .
2070         IF LS_BSEG-WERKS IS NOT INITIAL.
2071           CLEAR LV_POSL.
2072           READ TABLE LT_T001W1 INTO DATA(LS_T001WL) WITH KEY WERKS = LS_BSEG-WERKS BINARY SEARCH.
2073           IF SY-SUBRC IS INITIAL.
2074             LV_POSL = LS_T001WL-REGIO.
2075             CLEAR LS_T001WL.
2076           ENDIF.
2077
2078           READ TABLE LT_STATECD INTO DATA(LS_STATECD) WITH KEY REGIO = LV_POSL BINARY SEARCH.
2079           IF SY-SUBRC IS INITIAL.
2080             GS_FINAL_TDS-POS = LS_STATECD-GSTCODE.
2081             CLEAR LS_STATECD.
2082           ENDIF.
2083         ELSE.
2084
2085           READ TABLE LT_J_LBBRANCH1 INTO DATA(LS_J_1BBRANCHL) WITH KEY BUSINESSPLACE = LS_BSEG-BUPLA
2086                                                                         companycode = LS_BSEG-BUKRS TRANSPORTING ADDRESSID.
2087           IF SY-SUBRC IS INITIAL.
2088
2089             READ TABLE LT_ADRC1 INTO DATA(LS_ADRCL) WITH KEY ADDRNUMBER = LS_J_1BBRANCHL-ADDRESSID TRANSPORTING REGION.
2090             IF SY-SUBRC IS INITIAL.
2091
2092               READ TABLE LT_STATECD INTO LS_STATECD WITH KEY REGIO = LS_ADRCL-REGION BINARY SEARCH.
2093               IF SY-SUBRC IS INITIAL.
2094                 GS_FINAL_TDS-POS = LS_STATECD-GSTCODE.
2095                 CLEAR LS_STATECD.
2096               ENDIF.
2097
2098             ENDIF.
2099           ENDIF.
2100         ENDIF.
2101
2102         IF LS_BSEG_K-BLART = 'SA' AND LS_BSEG-GVTYP = ' '.
2103           CONTINUE.
2104         ENDIF.
2105         IF LS_BSEG-KOART = 'K'.
2106           CONTINUE.
2107         ENDIF.
2108
2109         IF ( LS_BSEG-KTOSL = 'WIT' OR LS_BSEG-KTOSL = 'OFF'  OR LS_BSEG-KTOSL = 'GRU' ).
2110           CONTINUE.
2111         ELSE.
2112           IF LS_BSEG_K-BLART = 'KA' AND LS_BSEG-SHKZG = 'S' AND LS_BSEG-KOART <> 'S'.
2113             CONTINUE.
2114           ENDIF.
2115
2116           IF LS_BSEG-KOART = 'K' .
2117             CONTINUE.
2118           ENDIF.
2119
2120           IF LS_BSEG_K-BLART = 'KA' AND LS_BSEG-UMSKZ = 'F' AND LS_BSEG-UMSKS = 'A'.
2121             CONTINUE.
2122           ENDIF.
2123           IF ( LS_BSEG_K-BLART = 'KR' AND LS_BSEG-KOART <> 'S' AND LS_BSEG-KOART <> 'A' ).
2124             CONTINUE.
2125           ENDIF.
2126
2127           READ TABLE LT_TDS_GL TRANSPORTING NO FIELDS WITH KEY BUKRS = LS_BSEG-BUKRS
2128                                                             HKONT = LS_BSEG-HKONT.
2129           IF SY-SUBRC = 0 .
2130             IF LV_CNT10 IS INITIAL.
2131               LOOP AT GT_FINAL_TDS INTO DATA(G_FINAL_TDS) WHERE BUKRS1 = LS_BSEG-BUKRS
2132                                                             AND BELNR = LS_BSEG-BELNR
2133                                                             AND GJAHR = LS_BSEG-GJAHR.
2134                 IF G_FINAL_TDS-TDS_AMOUNT IS INITIAL.
2135                   LV_CNT10 = LV_CNT10 + 1.  "
2136                   LOOP AT LT_BSEG_W INTO DATA(L_BSEG_W) WHERE BUKRS = LS_BSEG-BUKRS
2137                                                         AND   BELNR = LS_BSEG-BELNR
2138                                                         AND   GJAHR = LS_BSEG-GJAHR
2139                                                         AND   HKONT = LS_BSEG-HKONT.
2140                     G_FINAL_TDS-TDS_AMOUNT = G_FINAL_TDS-TDS_AMOUNT + L_BSEG_W-DMBTR.
2141
2142                     "SOC Added by Anil Maurya on 24.04.2024
2143                     G_FINAL_TDS-USER1 = 'DP'.
2144                     G_FINAL_TDS-USER2 = |{ LS_BSEG-HKONT ALPHA = OUT }|.
2145                     READ TABLE LT_SKAT INTO DATA(W_SKAT) WITH KEY SAKNR = LS_BSEG-HKONT.
2146                     IF SY-SUBRC EQ 0.
2147                       G_FINAL_TDS-USER3 = W_SKAT-TXT50.
2148                     ENDIF.
2149                     "SOC Added by Anil Maurya on 24.04.2024
2150
2151                     CLEAR L_BSEG_W.
2152                   ENDLOOP.
2153                   G_FINAL_TDS-FLAG2 = 'X'.
2154                   MODIFY GT_FINAL_TDS FROM G_FINAL_TDS.
2155                 ENDIF.
2156                 EXIT.
2157               ENDLOOP.
2158
2159             ELSE.
2160               LOOP AT GT_FINAL_TDS INTO G_FINAL_TDS WHERE BUKRS1 = LS_BSEG-BUKRS
2161                                                     AND   BELNR  = LS_BSEG-BELNR
2162                                                     AND   GJAHR  = LS_BSEG-GJAHR.
2163                 IF ( SY-TABIX = 1 OR SY-TABIX = 2 OR SY-TABIX = 3 OR SY-TABIX = 4  OR SY-TABIX = 5 )
2164                   AND G_FINAL_TDS-TDS_AMOUNT IS NOT INITIAL.
2165                   CONTINUE.
2166                 ELSE.
2167                   LV_CNT10 = LV_CNT10 + 1.
2168                   LOOP AT LT_BSEG_W INTO L_BSEG_W WHERE BUKRS  = LS_BSEG-BUKRS
2169                                                   AND   BELNR  = LS_BSEG-BELNR
2170                                                   AND   GJAHR  = LS_BSEG-GJAHR
2171                                                   AND   HKONT  = LS_BSEG-HKONT.
2172                     IF G_FINAL_TDS-TDS_AMOUNT IS INITIAL.
2173                       G_FINAL_TDS-TDS_AMOUNT = G_FINAL_TDS-TDS_AMOUNT + L_BSEG_W-DMBTR.
2174
2175                       "SOC Added by Anil Maurya on 24.04.2024
2176                       G_FINAL_TDS-USER1 = 'DP'.
2177                       G_FINAL_TDS-USER2 = |{ LS_BSEG-HKONT ALPHA = OUT }|.
2178                       READ TABLE IT_SKAT INTO S_SKAT WITH KEY SAKNR = LS_BSEG-HKONT.
2179                       IF SY-SUBRC EQ 0.
2180                         G_FINAL_TDS-USER3 = W_SKAT-TXT50.
2181                       ENDIF.
2182                       "EOC Added by Anil Maurya on 24.04.2024
2183
2184                       G_FINAL_TDS-FLAG3 = 'X'.
2185                       G_FINAL_TDS-FLAG2 = 'X'.
2186                       CLEAR L_BSEG_W.
2187                     ENDIF.
2188                   ENDLOOP.
2189                   MODIFY GT_FINAL_TDS FROM G_FINAL_TDS.
2190                   DELETE LT_BSEG_W WHERE HKONT = LS_BSEG-HKONT.
2191                   EXIT.
2192                 ENDIF.
2193               ENDLOOP.
2194             ENDIF.
2195             CONTINUE.
2196           ENDIF.
2197
2198           GS_FINAL_TDS-ACCOUNT_SEQ   = LS_BSEG-ZEKKN.
2199           GS_FINAL_TDS-SHKZG         = LS_BSEG-SHKZG.
2200           GS_FINAL_TDS-ASSIGN_NUM    = LS_BSEG-ZUONR.
2201           GS_FINAL_TDS-PROFIT_CENTER = | { LS_BSEG-PRCTR ALPHA = OUT } |.
2202           GS_FINAL_TDS-XREF3         = LS_BSEG-XREF3.
2203           GS_FINAL_TDS-PLANT         = LS_BSEG-WERKS.
2204
2205           GS_FINAL_TDS-BUKRS1  = LS_BSEG_K-BUKRS.
2206           GS_FINAL_TDS-BELNR   = LS_BSEG_K-BELNR.
2207           GS_FINAL_TDS-GJAHR   = LS_BSEG_K-GJAHR.
2208           GS_FINAL_TDS-BUDAT   = LS_BSEG_K-BUDAT.
2209           GS_FINAL_TDS-CR_DATE = LS_BSEG_K-CPUDT.
2210           GS_FINAL_TDS-BUZEI   = LS_BSEG-BUZEI.
2211           GS_FINAL_TDS-BUPLA   = LS_BSEG_K-BUPLA.
2212
2213           GS_FINAL_TDS-BUSINESS_PLACE  = LS_BSEG_K-BUPLA.
2214           GS_FINAL_TDS-BUSINESS_AREA   = LS_BSEG-GSBER.
2215           GS_FINAL_TDS-SECTIONCODE     = LS_BSEG_K-SECCO.
2216
2217           GS_FINAL_TDS-BUZEI = GS_FINAL_TDS-LINENUMBER = LS_BSEG-BUZEI.
2218           GS_FINAL_TDS-GJAHR = LS_BSEG-GJAHR.
2219
2220           GS_FINAL_TDS-PO_NUMBER     = LS_BSEG-EBELN.
2221           GS_FINAL_TDS-PO_LINE_ITEM     = LS_BSEG-EBELP.
2222           GS_FINAL_TDS-COMPANY_CODE  = LS_BSEG-BUKRS.
2223           IF LS_BSEG-HSN_SAC+3(1) <> ' '.
2224             GS_FINAL_TDS-HSN_SAC_CODE  = LS_BSEG-HSN_SAC.
2225           ENDIF.
2226
2227           IF LS_BSEG_K-BLART = 'RE' OR LS_BSEG_K-BLART = 'ZA' OR LS_BSEG_K-BLART = 'ZC'
2228                                                               OR LS_BSEG_K-BLART = 'KS'. " added by zubair 21.3.24
2229             GS_FINAL_TDS-SERVICE_DES_INV  = LS_BSEG_K-SGTXT.
2230           ELSE.
2231             GS_FINAL_TDS-SERVICE_DES_INV  = LS_BSEG-SGTXT.
2232           ENDIF.
2233
2234
2235           READ TABLE LT_T001Z INTO LS_T001Z WITH KEY BUKRS = LS_BSEG_K-BUKRS BINARY SEARCH.
2236           IF SY-SUBRC = 0.
2237             GS_FINAL_TDS-DEDUCTOR_PAN = LS_T001Z-PAVAL.
2238           ENDIF.
2239
2240           READ TABLE LT_J_1IMOVEND INTO LS_J_1IMOVEND WITH KEY LIFNR = LS_LFA1-LIFNR BINARY SEARCH.
2241           IF SY-SUBRC = 0.
2242             GS_FINAL_TDS-DEDUCTEE_PAN = LS_J_1IMOVEND-J_1IPANNO.
2243           ENDIF.
2244
2245           IF GS_FINAL_TDS-DEDUCTOR_PAN IS NOT INITIAL AND GS_FINAL_TDS-DEDUCTEE_PAN IS NOT INITIAL.
2246             IF SY-SUBRC = 0.
2247               IF GS_FINAL_TDS-DEDUCTOR_PAN = GS_FINAL_TDS-DEDUCTEE_PAN.
2248                 GS_FINAL_TDS-DOCUMENTTYPE = 'INV'.
2249               ENDIF.
2250             ENDIF.
2251           ENDIF.
2252
2253           READ TABLE LT_DOCTYPE INTO LS_DOCTYPE WITH  KEY BLART = LS_BSEG_K-BLART BINARY SEARCH.
2254           IF SY-SUBRC = 0.
2255             GS_FINAL_TDS-DOCUMENTTYPE = LS_DOCTYPE-DOC_TYPE.
2256           ENDIF.
2257
2258           IF LS_BSEG_K-STBLG IS NOT INITIAL AND LS_BSEG_K-XREVERSAL = '2'.
2259             READ TABLE LT_BKPF_NEW INTO LS_BKPF_NEW WITH KEY BUKRS = LS_BSEG_K-BUKRS
2260                                                              BELNR = LS_BSEG_K-STBLG
2261                                                              GJAHR = LS_BSEG_K-STJAH BINARY SEARCH.
2262             IF SY-SUBRC EQ 0.
2263               READ TABLE LT_DOCTYPE INTO LS_DOCTYPE WITH  KEY BLART = LS_BKPF_NEW-BLART BINARY SEARCH.
2264               IF SY-SUBRC = 0.
2265                 GS_FINAL_TDS-DOCUMENTTYPE = LS_DOCTYPE-DOC_TYPE.
2266               ENDIF.
2267             ENDIF.
2268           ENDIF.
2269
2270           LOOP AT LT_BSEG TRANSPORTING NO FIELDS  WHERE BELNR = LS_BSEG-BELNR AND
2271                                                  BUKRS = LS_BSEG-BUKRS AND
2272                                                  GJAHR = LS_BSEG-GJAHR AND
2273                                                  EBELN = LS_BSEG-EBELN AND
2274                                                  EBELP = LS_BSEG-EBELP AND
2275                                                  XREF3 = LS_BSEG-XREF3 AND
2276                                                  TXGRP = LS_BSEG-TXGRP.
2277             CLEAR : GS_FINAL_TDS-TAXABLEVALUE.
2278             CLEAR : GS_FINAL_TDS-AMOUNT.
2279
2280   *          IF ls_bseg_amt-shkzg = 'S' OR ls_bseg_amt-shkzg = 'H' .
2281   *
2282   *          ENDIF.
2283             EXIT.
2284           ENDLOOP.
2285
2286           IF GS_FINAL_TDS-LINENUMBER IS INITIAL.
2287             GS_FINAL_TDS-BUZEI = GS_FINAL_TDS-LINENUMBER = LS_BSEG_K-BUZEI.
2288           ENDIF.
2289           READ TABLE LT_BSEG_TDS INTO LS_BSEG_TDS WITH KEY BUKRS  = LS_BSEG-BUKRS
2290                                                            BELNR  = LS_BSEG-BELNR
2291                                                            GJAHR  = LS_BSEG-GJAHR
2292                                                            TXGRP  = LS_BSEG-TXGRP BINARY SEARCH.
2293           IF SY-SUBRC = 0.
2294             CLEAR : LV_TABIX, GS_FINAL_TDS-RCM .
2295             LV_TABIX = SY-TABIX.
2296
2297             LOOP AT LT_BSET INTO LS_BSET WHERE BUKRS  = LS_BSEG_TDS-BUKRS AND
2298                                                BELNR  = LS_BSEG_TDS-BELNR AND
2299                                                GJAHR  = LS_BSEG_TDS-GJAHR AND
2300                                                TXGRP  = LS_BSEG_TDS-TXGRP AND
2301                                                TAXPS  = LS_BSEG_TDS-TAXPS.
2302
2303               IF LS_BSET-STBKZ = '3'.
2304                 GS_FINAL_TDS-CRED_YN       = 'No'.
2305
2306               ELSEIF LS_BSET-STBKZ = '2'.
2307                 GS_FINAL_TDS-CRED_YN       = 'Yes'.
2308               ENDIF.
2309
2310               CLEAR :LS_BSET_NEW.
2311               LOOP  AT LT_BSET_NEW INTO LS_BSET_NEW WHERE BUKRS  = LS_BSEG_TDS-BUKRS
2312                                                     AND   BELNR  = LS_BSEG_TDS-BELNR
2313                                                     AND   GJAHR  = LS_BSEG_TDS-GJAHR
2314                                                     AND   TXGRP  = LS_BSEG_TDS-TXGRP
2315                                                     AND   STBKZ  = '2'.
2316                 GS_FINAL_TDS-GST_DEDU = 'Y'.
2317
2318                 READ TABLE LT_BSET_NEW INTO LS_BSET_NEW WITH KEY  BUKRS = LS_BSEG_TDS-BUKRS
2319                                                                   BELNR = LS_BSEG_TDS-BELNR
2320                                                                   GJAHR = LS_BSEG_TDS-GJAHR
2321                                                                   TXGRP = LS_BSEG_TDS-TXGRP
2322                                                                   STBKZ = '3'.
2323                 IF SY-SUBRC EQ 0.
2324                   GS_FINAL_TDS-GST_DEDU = 'N'.
2325                 ELSE.
2326                   GS_FINAL_TDS-GST_DEDU = 'Y'.
2327                 ENDIF.
2328
2329                 CLEAR :LS_BSET_NEW.
2330               ENDLOOP.
2331
2332               LOOP AT LT_BSET_NEW INTO LS_BSET_NEW WHERE  BUKRS  = LS_BSEG_TDS-BUKRS
2333                                                      AND  BELNR  = LS_BSEG_TDS-BELNR
2334                                                      AND  GJAHR  = LS_BSEG_TDS-GJAHR
2335                                                      AND  TXGRP  = LS_BSEG_TDS-TXGRP.
2336
2337                 READ TABLE LT_RCMTAX INTO DATA(LS_RCMTAX) WITH KEY TAX_CODE = LS_BSET_NEW-MWSKZ.
2338                 IF SY-SUBRC = 0 AND LS_RCMTAX-INDICATOR1 = 'X'.
2339                   GS_FINAL_TDS-RCM = 'Y'.
2340                   EXIT.
2341                 ELSE.
2342                   GS_FINAL_TDS-RCM = 'N'.
2343                 ENDIF.
2344                 CLEAR: LS_RCMTAX, LS_BSET_NEW.
2345               ENDLOOP.
2346
2347               READ TABLE LT_TDS_COND_TYPE INTO LS_TDS_COND_TYPE WITH  KEY KSCHL = LS_BSET-KSCHL BINARY SEARCH.
2348               IF SY-SUBRC = 0.
2349                 IF LS_TDS_COND_TYPE-TAX_TYPE = 'CGST'.
2350                   GS_FINAL_TDS-CGSTRATE   =  ( LS_BSET-KBETR / 10 ).
2351                   GS_FINAL_TDS-CGSTAMOUNT =  ( LS_BSET-HWSTE ).
2352
2353                   IF GS_FINAL_TDS-GST_DEDU = 'Y'.
2354                     CLEAR:WA_T007B.
2355                     READ TABLE IT_T007B INTO WA_T007B  WITH KEY KTOSL = LS_BSET-KTOSL BINARY SEARCH.
2356                     IF SY-SUBRC EQ 0.
2357                       IF WA_T007B-STAZF = ''.
2358                         GS_FINAL_TDS-AVAIL_CGST   = GS_FINAL_TDS-CGSTAMOUNT.
2359                       ELSE.
2360                         CLEAR:GS_FINAL_TDS-AVAIL_CGST .
2361                       ENDIF.
2362                     ENDIF.
2363                   ENDIF.
2364
2365                 ELSEIF LS_TDS_COND_TYPE-TAX_TYPE = 'SGST'.
2366                   GS_FINAL_TDS-SGSTRATE   = ( LS_BSET-KBETR / 10 ).
2367                   GS_FINAL_TDS-SGSTAMOUNT =  ( LS_BSET-HWSTE ).
2368                   IF GS_FINAL_TDS-GST_DEDU = 'Y'.
2369                     CLEAR:WA_T007B.
2370                     READ TABLE IT_T007B INTO WA_T007B  WITH KEY KTOSL = LS_BSET-KTOSL BINARY SEARCH.
2371                     IF SY-SUBRC EQ 0.
2372                       IF WA_T007B-STAZF = ''.
2373                         GS_FINAL_TDS-AVAIL_SGST   = GS_FINAL_TDS-SGSTAMOUNT.
2374                       ELSE.
2375                         CLEAR:GS_FINAL_TDS-AVAIL_SGST .
2376                       ENDIF.
2377                     ENDIF.
2378                   ENDIF.
2379
2380                 ELSEIF LS_TDS_COND_TYPE-TAX_TYPE = 'IGST'.
2381                   GS_FINAL_TDS-IGSTRATE   = ( LS_BSET-KBETR / 10 ).
2382                   GS_FINAL_TDS-IGSTAMOUNT =  ( LS_BSET-HWSTE ).
2383
2384                   IF GS_FINAL_TDS-GST_DEDU = 'Y'.
2385                     CLEAR:WA_T007B.
2386                     READ TABLE IT_T007B INTO WA_T007B  WITH KEY KTOSL = LS_BSET-KTOSL BINARY SEARCH.
2387                     IF SY-SUBRC EQ 0.
2388                       IF WA_T007B-STAZF = ''.
2389                         GS_FINAL_TDS-AVAIL_IGST   = GS_FINAL_TDS-IGSTAMOUNT.
2390                       ELSE.
2391                         CLEAR:GS_FINAL_TDS-AVAIL_IGST .
2392                       ENDIF.
2393                     ENDIF.
2394                   ENDIF.
2395
2396                 ELSEIF LS_TDS_COND_TYPE-TAX_TYPE = 'CESS'.
2397                   GS_FINAL_TDS-CESSRATE   = ( LS_BSET-KBETR / 10 ) + GS_FINAL_TDS-CESSRATE.
2398                   GS_FINAL_TDS-CESSAMOUNT = LS_BSET-HWSTE + GS_FINAL_TDS-CESSAMOUNT.
2399
2400                   IF GS_FINAL_TDS-GST_DEDU = 'Y'.
2401                     CLEAR:WA_T007B.
2402                     READ TABLE IT_T007B INTO  WA_T007B  WITH KEY KTOSL = LS_BSET-KTOSL BINARY SEARCH.
2403                     IF SY-SUBRC EQ 0.
2404                       IF WA_T007B-STAZF = ''.
2405                         GS_FINAL_TDS-AVAIL_CESS   = GS_FINAL_TDS-CESSAMOUNT.
2406                       ELSE.
2407                         CLEAR:GS_FINAL_TDS-AVAIL_CESS.
2408                       ENDIF.
2409                     ENDIF.
2410                   ENDIF.
2411                 ENDIF.
2412               ENDIF.
2413
2414
2415               DELETE LT_BSET WHERE BUKRS = LS_BSET-BUKRS AND
2416                                    BELNR = LS_BSET-BELNR AND
2417                                    GJAHR = LS_BSET-GJAHR AND
2418                                    TXGRP = LS_BSET-TXGRP AND
2419                                    TAXPS = LS_BSET-TAXPS AND
2420                                    KSCHL+3(1) = 'R'.
2421               CLEAR: LS_BSET.
2422             ENDLOOP.
2423             IF LV_TABIX IS NOT INITIAL .
2424               DELETE LT_BSEG_TDS INDEX LV_TABIX.
2425               CLEAR : LV_TABIX, LS_BSET.
2426             ENDIF.
2427
2428           ENDIF.
2429
2430           IF GS_FINAL_TDS-GST_DEDU IS INITIAL.
2431             READ TABLE LT_BSEG_TDS2 INTO LS_BSEG_TDS2 WITH KEY BUKRS  = LS_BSEG-BUKRS
2432                                                            BELNR  = LS_BSEG-BELNR
2433                                                            GJAHR  = LS_BSEG-GJAHR
2434                                                            MWSKZ  = LS_BSEG-MWSKZ .
2435             IF SY-SUBRC = 0.
2436               READ TABLE LT_BSET_NEW INTO LS_BSET_NEW WITH  KEY  BUKRS  = LS_BSEG_TDS2-BUKRS
2437                                                                 BELNR  = LS_BSEG_TDS2-BELNR
2438                                                                 GJAHR  = LS_BSEG_TDS2-GJAHR
2439                                                                 MWSKZ  = LS_BSEG_TDS2-MWSKZ
2440                                                                 STBKZ = '3'.
2441               IF SY-SUBRC = 0.
2442
2443                 READ TABLE LT_BSET_NEW INTO LS_BSET_NEW WITH  KEY BUKRS = LS_BSEG_TDS-BUKRS
2444                                                                  BELNR  = LS_BSEG_TDS-BELNR
2445                                                                  GJAHR  = LS_BSEG_TDS-GJAHR
2446                                                                  TXGRP  = LS_BSEG_TDS-TXGRP
2447                                                                  STBKZ = '2'.
2448
2449                 GS_FINAL_TDS-GST_DEDU = 'N'.
2450               ENDIF.
2451
2452               READ TABLE LT_BSET_NEW INTO LS_BSET_NEW WITH  KEY  BUKRS  = LS_BSEG_TDS-BUKRS
2453                                                                BELNR  = LS_BSEG_TDS-BELNR
2454                                                                GJAHR  = LS_BSEG_TDS-GJAHR TXGRP  = LS_BSEG_TDS-TXGRP
2455                                                                STBKZ = '2'.
2456               IF SY-SUBRC = 0.
2457                 GS_FINAL_TDS-GST_DEDU = 'Y'.
2458               ENDIF.
2459             ENDIF.
2460           ENDIF.
2461
2462           IF GS_FINAL_TDS-CRED_YN IS INITIAL.
2463             READ TABLE LT_BSET1 INTO LS_BSET1 WITH KEY BUKRS = LS_BSEG-BUKRS
2464                                                        BELNR = LS_BSEG-BELNR
2465                                                        GJAHR = LS_BSEG-GJAHR
2466                                                        TXGRP = LS_BSEG-TXGRP
2467                                                        TAXPS = LS_BSEG-TAXPS.
2468             IF SY-SUBRC  = 0.
2469               IF LS_BSET1-STBKZ = '3'.
2470                 GS_FINAL_TDS-CRED_YN   = 'No'.
2471               ELSEIF LS_BSET1-STBKZ = '2'.
2472                 GS_FINAL_TDS-CRED_YN  = 'Yes'.
2473               ENDIF.
2474             ENDIF.
2475           ENDIF.
2476
2477           CLEAR: GS_FINAL_TDS-TDS_RATE ,
2478           GS_FINAL_TDS-TDS_AMOUNT     ,
2479           GS_FINAL_TDS-GROSS_UP_IND   ,
2480           GS_FINAL_TDS-TDS_BASE_VAL   ,
2481           GS_FINAL_TDS-TDS_TAX_CODE_ERP,
2482           GS_FINAL_TDS-TDS_SECTION ,
2483           GS_FINAL_TDS-TDS_TAX ,
2484           GS_FINAL_TDS-USER_1 ,
2485           GS_FINAL_TDS-EXEMP_RATE ,
2486           GS_FINAL_TDS-EXEMP_NUM,
2487           GS_FINAL_TDS-INVOICE_VAL.
2488
2489           READ TABLE LT_WITH_ITEM INTO LS_WITH_ITEM WITH KEY BUKRS = LS_BSEG-BUKRS
2490                                                              BELNR = LS_BSEG-BELNR
2491                                                              GJAHR = LS_BSEG-GJAHR BINARY SEARCH.
2492           IF SY-SUBRC = 0.
2493             GS_FINAL_TDS-TDS_AMOUNT    = LS_WITH_ITEM-WT_QBSHH.
2494             GS_FINAL_TDS-TDS_TAX       = LS_WITH_ITEM-WITHT.
2495             GS_FINAL_TDS-EXEMP_NUM     = LS_WITH_ITEM-WT_WTEXMN.
2496             GS_FINAL_TDS-EXEMP_RATE    = LS_WITH_ITEM-WT_QSZRT.
2497             IF GS_FINAL_TDS-TDS_AMOUNT LT 0.
2498               GS_FINAL_TDS-TDS_AMOUNT = GS_FINAL_TDS-TDS_AMOUNT * -1.
2499             ENDIF.
2500
2501             GS_FINAL_TDS-TDS_RATE     = LS_WITH_ITEM-QSATZ.
2502
2503             GS_FINAL_TDS-GROSS_UP_IND = LS_WITH_ITEM-WT_GRUWTPD.
2504             GS_FINAL_TDS-TDS_BASE_VAL = LS_WITH_ITEM-WT_QSSHH.
2505             IF GS_FINAL_TDS-TDS_BASE_VAL LT 0.
2506               GS_FINAL_TDS-TDS_BASE_VAL  = GS_FINAL_TDS-TDS_BASE_VAL *  -1.
2507             ENDIF.
2508             GS_FINAL_TDS-TDS_TAX_CODE_ERP = LS_WITH_ITEM-WT_WITHCD.
2509
2510             IF LS_WITH_ITEM-WT_GRUWTPD = 'X'.
2511               GS_FINAL_TDS-GROSSUPINDICATOR = 'G'.
2512             ENDIF.
2513             IF LS_WITH_ITEM-WT_OPOWTPD = 'X'.
2514               GS_FINAL_TDS-GROSSUPINDICATOR = 'O'.
2515             ENDIF.
2516             IF LS_WITH_ITEM-WT_OPOWTPD = ' ' AND LS_WITH_ITEM-WT_GRUWTPD = ' '.
2517               GS_FINAL_TDS-GROSSUPINDICATOR = 'N'.
2518             ENDIF.
2519
2520             DELETE TABLE LT_WITH_ITEM FROM LS_WITH_ITEM.
2521             LOOP AT LT_WITH_ITEM INTO LS_WITH_ITEM WHERE  BUKRS = LS_BSEG-BUKRS
2522                                                   AND     BELNR = LS_BSEG-BELNR
2523                                                   AND     GJAHR = LS_BSEG-GJAHR
2524                                                   AND     WITHT = LS_WITH_ITEM-WITHT
2525                                                   AND    WT_WITHCD = LS_WITH_ITEM-WT_WITHCD.
2526
2527               GS_FINAL_TDS-TDS_RATE     = LS_WITH_ITEM-QSATZ.
2528               IF LS_WITH_ITEM-WT_QBSHH LT 0.
2529                 LS_WITH_ITEM-WT_QBSHH = LS_WITH_ITEM-WT_QBSHH * -1.
2530               ENDIF.
2531
2532               GS_FINAL_TDS-TDS_AMOUNT    =  GS_FINAL_TDS-TDS_AMOUNT +  LS_WITH_ITEM-WT_QBSHH.
2533
2534               GS_FINAL_TDS-GROSS_UP_IND = LS_WITH_ITEM-WT_GRUWTPD.
2535               IF  LS_WITH_ITEM-WT_QSSHH LT 0.
2536                 LS_WITH_ITEM-WT_QSSHH  =  LS_WITH_ITEM-WT_QSSHH *  -1.
2537               ENDIF.
2538               GS_FINAL_TDS-TDS_BASE_VAL =  GS_FINAL_TDS-TDS_BASE_VAL + LS_WITH_ITEM-WT_QSSHH.
2539
2540               DELETE TABLE LT_WITH_ITEM FROM LS_WITH_ITEM.
2541             ENDLOOP.
2542
2543             IF LS_WITH_ITEM-WITHT IS NOT INITIAL OR LS_WITH_ITEM-WT_WITHCD IS NOT INITIAL.
2544               READ TABLE LT_TDS_SEC INTO LS_TDS_SEC WITH KEY WITHT     = LS_WITH_ITEM-WITHT
2545                                                              WT_WITHCD = LS_WITH_ITEM-WT_WITHCD
2546                                                              APPL = 'X'.
2547               IF SY-SUBRC EQ 0.
2548                 GS_FINAL_TDS-TDS_SECTION = LS_TDS_SEC-QSCOD.
2549               ELSE.
2550                 READ TABLE LT_TDS_SEC INTO LS_TDS_SEC WITH KEY WITHT = LS_WITH_ITEM-WITHT
2551                                                                 APPL = 'X'.
2552                 IF SY-SUBRC EQ 0.
2553                   GS_FINAL_TDS-TDS_SECTION = LS_TDS_SEC-QSCOD.
2554                 ENDIF.
2555               ENDIF.
2556             ENDIF.
2557
2558             READ TABLE LT_T059Z INTO LS_T059Z WITH KEY WITHT     = LS_WITH_ITEM-WITHT
2559                                                        WT_WITHCD = LS_WITH_ITEM-WT_WITHCD BINARY SEARCH.
2560             IF SY-SUBRC = 0.
2561               GS_FINAL_TDS-USER1    = LS_T059Z-QSCOD.
2562   *            gs_final_tds-tds_rate = ls_t059z-qsatz.
2563             ENDIF.
2564           ENDIF.
2565
2566   * get Deductor Name & Deductore Code .
2567           READ TABLE LT_T001 INTO LS_T001 WITH KEY BUKRS = LS_BSEG_K-BUKRS BINARY SEARCH.
2568           IF SY-SUBRC = 0.
2569             GS_FINAL_TDS-COMPANY_TXT    = LS_T001-BUTXT.
2570             GS_FINAL_TDS-COMPANY_CODE  = LS_T001-BUKRS.
2571           ENDIF.
2572
2573   * Get Deductor Pan.
2574           READ TABLE LT_T001Z INTO LS_T001Z WITH KEY BUKRS = LS_BSEG_K-BUKRS BINARY SEARCH.
2575           IF SY-SUBRC = 0.
2576             GS_FINAL_TDS-DEDUCTOR_PAN = LS_T001Z-PAVAL.
2577           ENDIF.
2578
2579           READ TABLE LT_ZEYTDS_TAN_PRCT INTO DATA(WA_ZEYTDS_TAN_PRCT) WITH KEY PRCTR = LS_BSEG_K-PRCTR BINARY SEARCH.
2580           IF SY-SUBRC = 0.
2581             GS_FINAL_TDS-DEDUCTOR_TAN = WA_ZEYTDS_TAN_PRCT-VALUE.
2582             GS_FINAL_TDS-TANPARA = 'Profit Center'.
2583             CLEAR WA_ZEYTDS_TAN_PRCT.
2584           ENDIF.
2585
2586           READ TABLE LT_J_1I_SECCO_CIT INTO LS_J_1I_SECCO_CIT WITH KEY BUKRS = LS_BSEG_K-BUKRS
2587                                                                        SECCODE = LS_BSEG_K-SECCO BINARY SEARCH.
2588           IF SY-SUBRC = 0.
2589             GS_FINAL_TDS-DEDUCTOR_TAN = LS_J_1I_SECCO_CIT-TANNO.
2590             GS_FINAL_TDS-TANPARA = 'Section Code'.
2591           ENDIF.
2592
2593           IF CHK = 'X'.
2594             IF GS_FINAL_TDS-DEDUCTOR_TAN IS INITIAL.
2595               IF R_BUKRS = 'X'.
2596                 READ TABLE LT_TDS_TAN INTO LS_TDS_TAN WITH  KEY ORG_ELE = LS_BSEG_K-BUKRS BUKRS = LS_BSEG_K-BUKRS.
2597                 IF SY-SUBRC = 0.
2598                   GS_FINAL_TDS-DEDUCTOR_TAN = LS_TDS_TAN-TAN.
2599                   GS_FINAL_TDS-TANPARA = 'Company Code'.
2600                 ENDIF.
2601               ELSEIF R_PLANT = 'X'.
2602                 READ TABLE LT_TDS_TAN INTO LS_TDS_TAN WITH  KEY ORG_ELE = GS_FINAL_TDS-PLANT BUKRS = LS_BSEG_K-BUKRS.
2603                 IF SY-SUBRC = 0.
2604                   GS_FINAL_TDS-DEDUCTOR_TAN = LS_TDS_TAN-TAN.
2605                   GS_FINAL_TDS-TANPARA = 'Plant'.
2606                 ENDIF.
2607               ELSEIF R_BUPLA = 'X'.
2608                 READ TABLE LT_TDS_TAN INTO LS_TDS_TAN WITH  KEY ORG_ELE = GS_FINAL_TDS-BUPLA  BUKRS = LS_BSEG_K-BUKRS.
2609                 IF SY-SUBRC = 0.
2610                   GS_FINAL_TDS-DEDUCTOR_TAN = LS_TDS_TAN-TAN.
2611                   GS_FINAL_TDS-TANPARA = 'Business Place'.
2612                 ENDIF.
2613               ELSEIF R_PRCTR = 'X'.
2614                 READ TABLE LT_TDS_TAN INTO LS_TDS_TAN WITH  KEY ORG_ELE = GS_FINAL_TDS-PROFIT_CENTER BUKRS = LS_BSEG_K-BUKRS.
2615                 IF SY-SUBRC = 0.
2616                   GS_FINAL_TDS-DEDUCTOR_TAN = LS_TDS_TAN-TAN.
2617                   GS_FINAL_TDS-TANPARA = 'Profit Center'.
2618                 ENDIF.
2619               ELSEIF R_GSBER = 'X'.
2620
2621                 READ TABLE LT_TDS_TAN INTO LS_TDS_TAN WITH  KEY ORG_ELE = GS_FINAL_TDS-BUSINESS_AREA  BUKRS = LS_BSEG_K-BUKRS.
2622                 IF SY-SUBRC = 0.
2623                   GS_FINAL_TDS-DEDUCTOR_TAN = LS_TDS_TAN-TAN.
2624                   GS_FINAL_TDS-TANPARA = 'Business area'.
2625                 ENDIF.
2626               ENDIF.
2627             ENDIF.
2628           ENDIF.
2629
2630           IF GS_FINAL_TDS-DEDUCTOR_TAN IS INITIAL.
2631             READ TABLE LT_TDS_TAN INTO LS_TDS_TAN WITH  KEY ORG_ELE = LS_BSEG_K-BUKRS BUKRS = LS_BSEG_K-BUKRS.
2632             IF SY-SUBRC = 0.
2633               GS_FINAL_TDS-DEDUCTOR_TAN = LS_TDS_TAN-TAN.
2634               GS_FINAL_TDS-TANPARA = 'Company Code'.
2635             ENDIF.
2636           ENDIF.
2637
2638           READ TABLE LT_J_1BBRANCH INTO LS_J_1BBRANCH WITH KEY BUKRS = LS_BSEG_K-BUKRS
2639                                                                BRANCH = LS_BSEG_K-BUPLA BINARY SEARCH.
2640   *                                                                 branch = ls_bseg3-bupla BINARY SEARCH.
2641           IF SY-SUBRC = 0.
2642             GS_FINAL_TDS-DEDUCTOR_GSTN = LS_J_1BBRANCH-GSTIN.
2643           ENDIF.
2644
2645           IF LS_BSEG_K-LIFNR IS NOT INITIAL.
2646             READ TABLE LT_LFA1 INTO LS_LFA1 WITH KEY LIFNR = LS_BSEG_K-LIFNR BINARY SEARCH.
2647             IF SY-SUBRC = 0.
2648               GS_FINAL_TDS-DEDUCTEE_GSTN   = LS_LFA1-STCD3.
2649               GS_FINAL_TDS-DEDUCTEE_CODE   = LS_LFA1-LIFNR.
2650
2651               IF LS_LFA1-LAND1 = 'IN'.
2652                 GS_FINAL_TDS-NON_RES_DECUCTEE = 'Resident'.
2653                 GS_FINAL_TDS-NRINDICATOR = 'N'.
2654               ELSE.
2655                 GS_FINAL_TDS-NON_RES_DECUCTEE = 'Non-Resident'.
2656                 GS_FINAL_TDS-NRINDICATOR = 'Y'.
2657               ENDIF.
2658   *
2659               GS_FINAL_TDS-NAME_OF_DEDUCTEE = LS_LFA1-NAME1.
2660
2661               READ TABLE LT_T077K TRANSPORTING NO FIELDS WITH  KEY KTOKK = LS_LFA1-KTOKK BINARY SEARCH.
2662               IF SY-SUBRC = 0.
2663                 CLEAR:GS_FINAL_TDS-DEDUCTEE_GSTN, GS_FINAL_TDS-NAME_OF_DEDUCTEE, GS_FINAL_TDS-DEDUCTEE_PAN.
2664                 GS_FINAL_TDS-DEDUCTEE_CODE = ' '.
2665                 READ TABLE LT_BSEC INTO LS_BSEC WITH  KEY BUKRS = LS_BSEG_K-BUKRS
2666                                                           BELNR = LS_BSEG_K-BELNR
2667                                                           GJAHR = LS_BSEG_K-GJAHR BINARY SEARCH.
2668                 IF SY-SUBRC = 0.
2669                   GS_FINAL_TDS-NAME_OF_DEDUCTEE = LS_BSEC-NAME1.
2670                   GS_FINAL_TDS-DEDUCTEE_GSTN = LS_BSEC-STCD3.
2671                   GS_FINAL_TDS-DEDUCTEE_PAN = LS_BSEC-STCD1.
2672                   IF LS_BSEC-LAND1 =  'IN'.
2673                     GS_FINAL_TDS-NRINDICATOR = 'N'.
2674                   ELSE.
2675                     GS_FINAL_TDS-NRINDICATOR = 'Y'.
2676                   ENDIF.
2677                   CLEAR LS_BSEC.
2678                 ENDIF.
2679               ENDIF.
2680             ENDIF.
2681           ELSE.
2682             READ TABLE LT_BSEG_V INTO LS_BSEG_V WITH KEY BUKRS = LS_BSEG_K-BUKRS
2683                                                          BELNR = LS_BSEG_K-BELNR
2684                                                          GJAHR = LS_BSEG_K-GJAHR BINARY SEARCH.
2685             IF SY-SUBRC = 0.
2686               READ TABLE LT_LFA1 INTO LS_LFA1 WITH KEY LIFNR = LS_BSEG_V-LIFNR BINARY SEARCH.
2687               IF SY-SUBRC = 0.
2688                 GS_FINAL_TDS-DEDUCTEE_GSTN   = LS_LFA1-STCD3.
2689                 GS_FINAL_TDS-DEDUCTEE_CODE   = LS_LFA1-LIFNR.
2690
2691                 IF LS_LFA1-LAND1 = 'IN'.
2692                   GS_FINAL_TDS-NON_RES_DECUCTEE = 'Resident'.
2693                   GS_FINAL_TDS-NRINDICATOR = 'N'.
2694                 ELSE.
2695                   GS_FINAL_TDS-NON_RES_DECUCTEE = 'Non-Resident'.
2696                   GS_FINAL_TDS-NRINDICATOR = 'Y'.
2697                 ENDIF.
2698
2699                 GS_FINAL_TDS-NAME_OF_DEDUCTEE = LS_LFA1-NAME1.
2700                 CLEAR: GS_FINAL_TDS-DEDUCTEE_GSTN, GS_FINAL_TDS-NAME_OF_DEDUCTEE,
2701                 GS_FINAL_TDS-DEDUCTEE_PAN.
2702
2703                 READ TABLE LT_T077K TRANSPORTING NO FIELDS WITH  KEY KTOKK = LS_LFA1-KTOKK BINARY SEARCH.
2704                 IF SY-SUBRC = 0.
2705                   GS_FINAL_TDS-DEDUCTEE_CODE = ' '.
2706
2707                   READ TABLE LT_BSEC INTO LS_BSEC WITH  KEY BUKRS = LS_BSEG_K-BUKRS
2708                                                             BELNR = LS_BSEG_K-BELNR
2709                                                             GJAHR = LS_BSEG_K-GJAHR BINARY SEARCH.
2710                   IF SY-SUBRC = 0.
2711                     GS_FINAL_TDS-NAME_OF_DEDUCTEE = LS_BSEC-NAME1.
2712                     GS_FINAL_TDS-DEDUCTEE_GSTN = LS_BSEC-STCD3.
2713                     GS_FINAL_TDS-DEDUCTEE_PAN = LS_BSEC-STCD1.
2714
2715                     IF LS_BSEC-LAND1 =  'IN'.
2716                       GS_FINAL_TDS-NRINDICATOR = 'N'.
2717                     ELSE.
2718                       GS_FINAL_TDS-NRINDICATOR = 'Y'.
2719                     ENDIF.
2720                     CLEAR LS_BSEC.
2721                   ENDIF.
2722                 ENDIF.
2723               ENDIF.
2724
2725               GS_FINAL_TDS-SECCO         = LS_BSEG_V-SECCO.
2726             ENDIF.
2727           ENDIF.
2728
2729   ***nri TDS amount begin logic
2730           IF GS_FINAL_TDS-NRINDICATOR = 'Y' AND GS_FINAL_TDS-TDS_AMOUNT IS INITIAL.
2731             READ TABLE LT_TDS_GL TRANSPORTING NO FIELDS  WITH  KEY BUKRS = GS_FINAL_TDS-BUKRS1 HKONT = LS_BSEG-HKONT.
2732             IF SY-SUBRC = 0.
2733               CLEAR: LV_INDEX.
2734               READ TABLE GT_FINAL_TDS INTO GS_FINAL_TDS_TEMP WITH  KEY BUKRS1 = LS_BSEG-BUKRS
2735                                                                        GJAHR = LS_BSEG-GJAHR
2736                                                                        BELNR = LS_BSEG-BELNR .
2737               IF SY-SUBRC = 0.
2738                 LV_INDEX = SY-TABIX.
2739                 GS_FINAL_TDS_TEMP-TDS_AMOUNT = LS_BSEG-DMBTR + GS_FINAL_TDS_TEMP-TDS_AMOUNT.
2740                 MODIFY TABLE GT_FINAL_TDS FROM GS_FINAL_TDS_TEMP.
2741                 CONTINUE.
2742               ENDIF.
2743             ENDIF.
2744           ENDIF.
2745   ***nri TDS amount end logic
2746
2747
2748           READ TABLE LT_ADRC INTO LS_ADRC WITH KEY ADDRNUMBER = LS_LFA1-ADRNR BINARY SEARCH.
2749           IF SY-SUBRC = 0.
2750             CONCATENATE LS_ADRC-STREET LS_ADRC-STR_SUPPL1  LS_ADRC-STR_SUPPL2 LS_ADRC-STR_SUPPL3 LS_ADRC-POST_CODE2
2751                         LS_ADRC-CITY1 LS_ADRC-CITY2 LS_ADRC-REGION  INTO GS_FINAL_TDS-DEDUCTEE_ADD SEPARATED BY ','.
2752           ENDIF.
2753
2754           IF EXP_CHK = 'X'.
2755             IF LS_BSEG-KTOSL IN LR_KTOSL.
2756               READ TABLE LT_EKKN INTO LS_EKKN WITH  KEY EBELN = LS_BSEG-EBELN
2757                                                         EBELP = LS_BSEG-EBELP
2758                                                         ZEKKN = LS_BSEG-ZEKKN BINARY SEARCH.
2759               IF SY-SUBRC = 0.
2760                 READ TABLE LT_SKAT INTO LS_SKAT WITH KEY SAKNR = LS_EKKN-SAKTO BINARY SEARCH.
2761                 IF SY-SUBRC = 0.
2762                   GS_FINAL_TDS-GL_ACC_CODE = LS_SKAT-SAKNR.
2763                   GS_FINAL_TDS-GL_ACC_NAME = LS_SKAT-TXT50.
2764                 ENDIF.
2765               ELSE.
2766                 READ TABLE LT_EKPO1 INTO LS_EKPO1 WITH  KEY EBELN = LS_BSEG-EBELN EBELP = LS_BSEG-EBELP BINARY SEARCH.
2767                 IF SY-SUBRC = 0.
2768                   READ TABLE LT_T001W INTO LS_T001W WITH  KEY WERKS = LS_EKPO1-WERKS.
2769                   IF SY-SUBRC  = 0.
2770                     READ TABLE LT_MBEW INTO LS_MBEW WITH  KEY MATNR = LS_EKPO1-MATNR
2771                                                               BWKEY = LS_T001W-BWKEY
2772                                                               BWTAR = LS_EKPO1-BWTAR.
2773                     IF SY-SUBRC = 0.
2774                       READ TABLE LT_T030 INTO LS_T030 WITH KEY KTOPL = LS_T001-KTOPL
2775                                                                BKLAS = LS_MBEW-BKLAS.
2776                       IF SY-SUBRC = 0.
2777                         READ TABLE LT_SKAT INTO LS_SKAT WITH KEY SAKNR = LS_T030-KONTS BINARY SEARCH.
2778                         IF SY-SUBRC = 0.
2779                           GS_FINAL_TDS-GL_ACC_CODE = LS_SKAT-SAKNR.
2780                           GS_FINAL_TDS-GL_ACC_NAME = LS_SKAT-TXT50.
2781                         ENDIF.
2782                       ENDIF.
2783                     ENDIF.
2784                   ENDIF.
2785                 ENDIF.
2786               ENDIF.
2787
2788             ENDIF.
2789
2790             IF GS_FINAL_TDS-GL_ACC_CODE IS INITIAL .
2791               IF LS_BSEG-BUZID <> 'P' AND LS_BSEG-BUZID <> 'E'.
2792                 READ TABLE LT_BSEG_WRX_PO INTO LS_BSEG_WRX_PO WITH  KEY BUKRS = LS_BSEG-BUKRS
2793                                                                         EBELN = LS_BSEG-EBELN
2794                                                                         EBELP = LS_BSEG-EBELP.
2795                 IF SY-SUBRC = 0.
2796                   READ TABLE LT_SKAT INTO LS_SKAT WITH KEY SAKNR = LS_BSEG_WRX_PO-HKONT BINARY SEARCH.
2797                   IF SY-SUBRC = 0.
2798                     GS_FINAL_TDS-GL_ACC_CODE = LS_SKAT-SAKNR.
2799                     GS_FINAL_TDS-GL_ACC_NAME = LS_SKAT-TXT50.
2800                   ENDIF.
2801                 ENDIF.
2802               ENDIF.
2803             ENDIF.
2804           ENDIF.
2805   *        IF   LS_BSEG_K-BLART NE 'RE' OR GS_FINAL_TDS-PO_NUMBER IS INITIAL.
2806           IF   LS_BSEG_K-BLART NE 'KS' OR GS_FINAL_TDS-PO_NUMBER IS INITIAL. " zubair 21.3.24
2807             GS_FINAL_TDS-TRANS_TYPE = 'F'.
2808           ENDIF.
2809
2810
2811   * Get PO No. PO Date & PO Description.
2812   * Get GL Account Code & Name
2813           IF  GS_FINAL_TDS-GL_ACC_CODE IS INITIAL.
2814             READ TABLE LT_SKAT INTO LS_SKAT WITH KEY SAKNR = LS_BSEG-HKONT BINARY SEARCH.
2815             IF SY-SUBRC = 0.
2816               GS_FINAL_TDS-GL_ACC_CODE = LS_SKAT-SAKNR.
2817               GS_FINAL_TDS-GL_ACC_NAME = LS_SKAT-TXT50.
2818             ENDIF.
2819           ENDIF.
2820
2821           READ TABLE LT_EKPO INTO LS_EKPO WITH KEY EBELN = LS_BSEG-EBELN
2822                                                    EBELP = LS_BSEG-EBELP BINARY SEARCH.
2823           IF SY-SUBRC = 0.
2824             GS_FINAL_TDS-PO_NUMBER       = LS_EKPO-EBELN.
2825             GS_FINAL_TDS-PO_LINE_ITEM    = LS_EKPO-EBELP.
2826             GS_FINAL_TDS-ITEM_CODE   = LS_EKPO-MATNR.
2827   *          SHIFT GS_FINAL_TDS-ITEM_CODE LEFT DELETING LEADING '0'.  "AM-30-04-24
2828
2829             CONCATENATE LS_EKPO-BEDAT+6(2) LS_EKPO-BEDAT+4(2)
2830                         LS_EKPO-BEDAT+0(4) INTO GS_FINAL_TDS-PO_DATE SEPARATED BY '-'  .
2831
2832             GS_FINAL_TDS-SERVICE_DES_PO  = LS_EKPO-TXZ01.
2833             GS_FINAL_TDS-PO_DESC         = LS_EKPO-TXZ01.
2834
2835             IF GS_FINAL_TDS-HSN_SAC_CODE IS INITIAL OR GS_FINAL_TDS-HSN_SAC_CODE+3(1) = ' '.
2836               GS_FINAL_TDS-HSN_SAC_CODE = LS_EKPO-J_1BNBM.
2837             ENDIF.
2838
2839             IF LS_EKPO-WEBRE = SPACE AND LS_EKPO-WEPOS = SPACE .
2840               GS_FINAL_TDS-TRANS_TYPE = 'B'.
2841             ELSEIF LS_EKPO-WEBRE = 'X'.
2842               IF LS_EKPO-PSTYP = '9'.
2843                 GS_FINAL_TDS-TRANS_TYPE = 'A1'.
2844               ELSE.
2845                 GS_FINAL_TDS-TRANS_TYPE = 'A2'.
2846               ENDIF.
2847             ELSEIF LS_EKPO-WEBRE = SPACE.
2848               IF LS_EKPO-PSTYP = '9'.
2849                 GS_FINAL_TDS-TRANS_TYPE = 'C1'.
2850               ELSE.
2851                 GS_FINAL_TDS-TRANS_TYPE = 'C2'.
2852               ENDIF.
2853             ENDIF.
2854             GS_FINAL_TDS-ITEM_CAT = LS_EKPO-PSTYP.
2855           ELSE.
2856             CLEAR: GS_FINAL_TDS-SERVICE_DES_PO, GS_FINAL_TDS-ITEM_CODE,
2857                    GS_FINAL_TDS-PO_DATE, GS_FINAL_TDS-PO_LINE_ITEM, GS_FINAL_TDS-PO_DESC.
2858           ENDIF.
2859
2860           IF GS_FINAL_TDS-ITEM_CODE IS INITIAL.
2861             GS_FINAL_TDS-ITEM_CODE = LS_BSEG-MATNR.
2862           ENDIF.
2863
2864           CLEAR : GS_FINAL_TDS-SAC_DEC.
2865           CLEAR : GS_FINAL_TDS-HSN_SAC_DES.
2866
2867           READ TABLE LT_ASMD INTO LS_ASMD WITH KEY TAXTARIFFCODE = LS_BSEG-HSN_SAC BINARY SEARCH.
2868           IF SY-SUBRC = 0.
2869             READ TABLE LT_ASMDT INTO LS_ASMDT WITH KEY ASNUM = LS_ASMD-ASNUM BINARY SEARCH.
2870             IF SY-SUBRC = 0.
2871               GS_FINAL_TDS-SAC_DEC = LS_ASMDT-ASKTX.
2872             ENDIF.
2873           ENDIF.
2874           IF GS_FINAL_TDS-HSN_SAC_CODE IS INITIAL OR GS_FINAL_TDS-HSN_SAC_CODE+3(1) = ' '.
2875             READ TABLE LT_T604N INTO LS_T604N WITH KEY STEUC = LS_BSEG-HSN_SAC BINARY SEARCH.
2876             IF SY-SUBRC  = 0.
2877               GS_FINAL_TDS-HSN_SAC_DES = LS_T604N-TEXT1.
2878               GS_FINAL_TDS-HSN_SAC_CODE = LS_BSEG-HSN_SAC .
2879             ENDIF.
2880           ELSE.
2881             READ TABLE LT_T604N INTO LS_T604N WITH KEY STEUC = GS_FINAL_TDS-HSN_SAC_CODE BINARY SEARCH.
2882             IF SY-SUBRC  = 0.
2883               GS_FINAL_TDS-HSN_SAC_DES = LS_T604N-TEXT1.
2884             ENDIF.
2885
2886           ENDIF.
2887
2888
2889           IF GS_FINAL_TDS-HSN_SAC_CODE IS INITIAL AND GS_FINAL_TDS-SAC_DEC IS INITIAL.
2890             READ TABLE LT_EKPO INTO LS_EKPO WITH KEY EBELN = LS_BSEG-EBELN
2891                                                      EBELP = LS_BSEG-EBELP BINARY SEARCH.
2892             IF SY-SUBRC = 0 AND GS_FINAL_TDS-HSN_SAC_CODE IS INITIAL OR GS_FINAL_TDS-HSN_SAC_CODE+3(1) = ' '.
2893               GS_FINAL_TDS-HSN_SAC_CODE = LS_EKPO-J_1BNBM.
2894             ENDIF.
2895             CLEAR LV_WERKS.
2896             LV_WERKS =  LS_EKPO-WERKS.
2897             READ TABLE LT_MARC INTO LS_MARC WITH KEY MATNR = LS_EKPO-MATNR
2898                                                      WERKS = LV_WERKS BINARY SEARCH.
2899             IF SY-SUBRC  = 0.
2900               IF GS_FINAL_TDS-HSN_SAC_CODE IS NOT INITIAL OR GS_FINAL_TDS-HSN_SAC_CODE+3(1) = ' '.
2901                 LS_MARC-STEUC = GS_FINAL_TDS-HSN_SAC_CODE.
2902               ENDIF.
2903               READ TABLE LT_T604N INTO LS_T604N WITH KEY STEUC = LS_MARC-STEUC BINARY SEARCH.
2904               IF SY-SUBRC  = 0.
2905                 GS_FINAL_TDS-SAC_DEC = LS_T604N-TEXT1.
2906               ENDIF.
2907
2908               READ TABLE LT_T604N INTO LS_T604N WITH KEY STEUC = LS_MARC-STEUC BINARY SEARCH.
2909               IF SY-SUBRC  = 0.
2910                 GS_FINAL_TDS-HSN_SAC_DES = LS_T604N-TEXT1.
2911               ENDIF.
2912             ENDIF.
2913           ELSE.
2914
2915             READ TABLE LT_EKPO INTO LS_EKPO WITH KEY EBELN = LS_BSEG-EBELN
2916                                                      EBELP = LS_BSEG-EBELP BINARY SEARCH.
2917             IF SY-SUBRC = 0 AND ( GS_FINAL_TDS-HSN_SAC_CODE IS INITIAL OR GS_FINAL_TDS-HSN_SAC_CODE+3(1) = ' ' ).
2918               GS_FINAL_TDS-HSN_SAC_CODE = LS_EKPO-J_1BNBM.
2919             ENDIF.
2920
2921             CLEAR LV_WERKS.
2922             LV_WERKS =  LS_EKPO-WERKS.
2923             READ TABLE LT_MARC INTO LS_MARC WITH KEY MATNR = LS_EKPO-MATNR
2924                                                      WERKS = LV_WERKS BINARY SEARCH.
2925             IF SY-SUBRC  = 0.
2926               IF GS_FINAL_TDS-HSN_SAC_CODE IS NOT INITIAL OR GS_FINAL_TDS-HSN_SAC_CODE+3(1) = ' '.
2927                 LS_MARC-STEUC = GS_FINAL_TDS-HSN_SAC_CODE.
2928               ENDIF.
2929
2930               READ TABLE LT_T604N INTO LS_T604N WITH KEY STEUC = LS_MARC-STEUC BINARY SEARCH.
2931               IF SY-SUBRC  = 0.
2932                 GS_FINAL_TDS-SAC_DEC = LS_T604N-TEXT1.
2933               ENDIF.
2934
2935               READ TABLE LT_T604N INTO LS_T604N WITH KEY STEUC = LS_MARC-STEUC BINARY SEARCH.
2936               IF SY-SUBRC  = 0.
2937                 GS_FINAL_TDS-HSN_SAC_DES = LS_T604N-TEXT1.
2938               ENDIF.
2939             ENDIF.
2940
2941             IF GS_FINAL_TDS-SAC_DEC IS INITIAL.
2942               READ TABLE LT_T604N INTO LS_T604N WITH KEY STEUC = GS_FINAL_TDS-HSN_SAC_CODE BINARY SEARCH.
2943               IF SY-SUBRC  = 0.
2944                 GS_FINAL_TDS-SAC_DEC = LS_T604N-TEXT1.
2945               ENDIF.
2946             ENDIF.
2947
2948             IF GS_FINAL_TDS-HSN_SAC_DES IS INITIAL .
2949               READ TABLE LT_T604N INTO LS_T604N WITH KEY STEUC = GS_FINAL_TDS-HSN_SAC_CODE BINARY SEARCH.
2950               IF SY-SUBRC  = 0.
2951                 GS_FINAL_TDS-HSN_SAC_DES = LS_T604N-TEXT1.
2952               ENDIF.
2953             ENDIF.
2954           ENDIF.
2955
2956           IF GS_FINAL_TDS-HSN_SAC_CODE IS INITIAL OR GS_FINAL_TDS-HSN_SAC_CODE+3(1) = ' '.
2957             IF LS_EKPO-J_1BNBM IS NOT INITIAL.
2958               READ TABLE LT_ASMD INTO LS_ASMD WITH KEY TAXTARIFFCODE =  LS_EKPO-J_1BNBM BINARY SEARCH.
2959               IF SY-SUBRC = 0.
2960                 IF  GS_FINAL_TDS-HSN_SAC_CODE IS INITIAL.
2961                   GS_FINAL_TDS-HSN_SAC_CODE = LS_ASMD-TAXTARIFFCODE.
2962                 ENDIF.
2963                 READ TABLE LT_ASMDT INTO LS_ASMDT WITH KEY ASNUM = LS_ASMD-ASNUM BINARY SEARCH.
2964                 IF SY-SUBRC = 0.
2965                   GS_FINAL_TDS-SAC_DEC = LS_ASMDT-ASKTX.
2966                 ENDIF.
2967               ENDIF.
2968             ENDIF.
2969           ENDIF.
2970
2971
2972           IF GS_FINAL_TDS-SAC_DEC IS INITIAL.
2973             READ TABLE LT_T604N INTO LS_T604N WITH KEY STEUC = GS_FINAL_TDS-HSN_SAC_CODE  BINARY SEARCH.
2974             IF SY-SUBRC  = 0.
2975               GS_FINAL_TDS-SAC_DEC = LS_T604N-TEXT1.
2976             ENDIF.
2977           ENDIF.
2978
2979           GS_FINAL_TDS-TRANS = LS_BSEG-KTOSL.
2980           READ TABLE LT_KTOSL INTO LS_KTOSL WITH  KEY KTOSL = LS_BSEG-KTOSL BINARY SEARCH.
2981           IF SY-SUBRC = 0.
2982             GS_FINAL_TDS-HSN_SAC_DES = LS_KTOSL-TEXT.
2983             GS_FINAL_TDS-HSN_SAC_CODE = LS_KTOSL-HSN.
2984           ENDIF.
2985
2986           IF GS_FINAL_TDS-HSN_SAC_CODE  IS INITIAL.
2987             GS_FINAL_TDS-HSN_SAC_CODE  = LS_BSEG-HSN_SAC.
2988             READ TABLE LT_T604N INTO LS_T604N WITH KEY STEUC = GS_FINAL_TDS-HSN_SAC_CODE  BINARY SEARCH.
2989             IF SY-SUBRC  = 0.
2990               GS_FINAL_TDS-HSN_SAC_DES = LS_T604N-TEXT1.
2991             ENDIF.
2992           ENDIF.
2993
2994   * get supply type.
2995           READ TABLE LT_EKPO INTO LS_EKPO WITH KEY EBELN = LS_BSEG-EBELN
2996                                                      EBELP = LS_BSEG-EBELP BINARY SEARCH.
2997           IF LS_LFA1-LAND1 EQ 'IN'.
2998             READ TABLE LT_J_1IMOVEND INTO LS_J_1IMOVEND WITH KEY LIFNR = LS_LFA1-LIFNR BINARY SEARCH.
2999
3000             CLEAR LV_WERKS.
3001             LV_WERKS =  GS_FINAL_TDS-PLANT.
3002             READ TABLE LT_SEZMAP TRANSPORTING NO FIELDS WITH KEY WERKS = LV_WERKS
3003                                                                  SEZ_PLANT = 'SEZ'.
3004             IF SY-SUBRC = 0.
3005               GS_FINAL_TDS-SUPPLY_TYPE = 'DTA'.
3006             ENDIF.
3007           ENDIF.
3008
3009           IF GS_FINAL_TDS-SUPPLY_TYPE = 'DTA'.
3010             CLEAR LV_WERKS.
3011             LV_WERKS =  GS_FINAL_TDS-PLANT.
3012
3013             READ TABLE LT_PLANTMAP TRANSPORTING NO FIELDS WITH KEY WERKS = LV_WERKS
3014                                                                SEZ_PLANT = 'SEZ'.
3015             IF SY-SUBRC = 0.
3016               IF LS_J_1IMOVEND-VEN_CLASS = '2' AND LS_EKPO-PSTYP EQ '9'.
3017                 GS_FINAL_TDS-SUPPLY_TYPE = 'SEZS'.
3018               ENDIF.
3019             ELSEIF LS_J_1IMOVEND-VEN_CLASS = '2' AND LS_EKPO-PSTYP <> '9'.
3020               GS_FINAL_TDS-SUPPLY_TYPE = 'SEZG'.
3021             ELSE.
3022               GS_FINAL_TDS-SUPPLY_TYPE = 'DTA'.
3023             ENDIF.
3024
3025             IF LS_BSEG_K-XREVERSAL = '2' OR LS_BSEG_K-TCODE = 'MR8M'.
3026               GS_FINAL_TDS-SUPPLY_TYPE = 'CAN'.
3027             ENDIF.
3028
3029           ENDIF.
3030
3031           IF LS_J_1IMOVEND-VEN_CLASS = '1'.
3032             GS_FINAL_TDS-SUPPLY_TYPE = 'COM'.
3033           ENDIF.
3034
3035           IF GS_FINAL_TDS-HSN_SAC_CODE IS NOT INITIAL.
3036             READ TABLE LT_LFA1 INTO LS_LFA1 WITH KEY LIFNR = LS_BSEG_K-LIFNR BINARY SEARCH.
3037
3038             IF SY-SUBRC = 0.
3039               IF LS_LFA1-LAND1 NE 'IN' AND GS_FINAL_TDS-HSN_SAC_CODE+0(2) EQ '99' .
3040                 GS_FINAL_TDS-SUPPLY_TYPE = 'IMPS'.
3041               ELSEIF LS_LFA1-LAND1 NE 'IN' AND GS_FINAL_TDS-HSN_SAC_CODE+0(2) NE '99' .
3042                 GS_FINAL_TDS-SUPPLY_TYPE = 'IMPG'.
3043
3044               ELSE.
3045
3046                 IF LS_BSEG_K-XREVERSAL = '2' OR LS_BSEG_K-TCODE = 'MR8M'.
3047                   GS_FINAL_TDS-SUPPLY_TYPE = 'CAN'.
3048
3049                 ENDIF.
3050               ENDIF.
3051               IF GS_FINAL_TDS-SUPPLY_TYPE = 'IMPG' OR GS_FINAL_TDS-SUPPLY_TYPE = 'IMPS'.
3052                 IF LS_BSEG_K-XREVERSAL = '2' OR LS_BSEG_K-TCODE = 'MR8M'.
3053                   GS_FINAL_TDS-SUPPLY_TYPE = 'CAN'.
3054                 ENDIF.
3055               ENDIF.
3056
3057             ENDIF.
3058           ENDIF.
3059
3060           IF GS_FINAL_TDS-SUPPLY_TYPE IS INITIAL.
3061             READ TABLE LT_LFA1 INTO LS_LFA1 WITH KEY LIFNR = LS_BSEG_K-LIFNR BINARY SEARCH.
3062             IF SY-SUBRC = 0.
3063               IF LS_BSEG_K-XREVERSAL = '2' OR LS_BSEG_K-TCODE = 'MR8M'.
3064                 GS_FINAL_TDS-SUPPLY_TYPE = 'CAN'.
3065               ELSE.
3066                 GS_FINAL_TDS-SUPPLY_TYPE = 'TAX'.
3067               ENDIF.
3068
3069               CLEAR :LS_BKPF_TEMP.
3070               READ TABLE LT_BKPF_TEMP INTO LS_BKPF_TEMP WITH KEY BUKRS = LS_BSEG_K-BUKRS
3071                                                                  BELNR = LS_BSEG_K-BELNR
3072                                                                  GJAHR = LS_BSEG_K-GJAHR BINARY SEARCH.
3073               IF SY-SUBRC EQ 0.
3074                 CLEAR:LS_RBKP_RE, LV_GJAHR.
3075                 LV_GJAHR = LS_BKPF_TEMP-AWKEY+10(4).
3076                 READ TABLE LT_RBKP_RE INTO LS_RBKP_RE WITH KEY BELNR = LS_BKPF_TEMP-AWKEY+0(10)
3077                                                                GJAHR = LV_GJAHR BINARY SEARCH.
3078                 IF SY-SUBRC EQ 0.
3079                   IF LS_RBKP_RE-IVTYP EQ '5'.
3080                     GS_FINAL_TDS-SUPPLY_TYPE = 'CAN'.
3081                   ENDIF.
3082                 ENDIF.
3083               ENDIF.
3084             ENDIF.
3085           ENDIF.
3086
3087           IF GS_FINAL_TDS-SUPPLY_TYPE IS INITIAL.
3088             GS_FINAL_TDS-SUPPLY_TYPE = 'TAX'.
3089           ENDIF.
3090           IF LS_BSEG_K-BLART = 'RE' OR LS_BSEG_K-BLART = 'ZA'
3091                                     OR LS_BSEG_K-BLART = 'KS'. " ZUBAIR 21.3.24
3092             READ TABLE LT_EKBE_1 INTO LS_EKBE_1 WITH KEY GJAHR = LS_BSEG_K-GJAHR BELNR = LS_BSEG_K-AWKEY+0(10).
3093             IF SY-SUBRC EQ 0.
3094               IF LS_EKBE_1-VGABE = '2' AND LS_EKBE_1-SHKZG = 'S' AND  GS_FINAL_TDS-SUPPLY_TYPE <> 'CAN'.
3095                 GS_FINAL_TDS-DOCUMENTTYPE = 'INV'.
3096               ELSEIF LS_EKBE_1-VGABE = '2' AND LS_EKBE_1-SHKZG = 'H' AND GS_FINAL_TDS-SUPPLY_TYPE = 'CAN'.
3097                 GS_FINAL_TDS-DOCUMENTTYPE  = 'INV'.
3098
3099               ELSEIF LS_EKBE_1-VGABE = '2' AND LS_EKBE_1-SHKZG = 'H' AND GS_FINAL_TDS-SUPPLY_TYPE <> 'CAN'.
3100                 GS_FINAL_TDS-DOCUMENTTYPE  = 'CR'.
3101               ELSEIF LS_EKBE_1-VGABE = '2' AND LS_EKBE_1-SHKZG = 'S' AND  GS_FINAL_TDS-SUPPLY_TYPE = 'CAN'.
3102                 GS_FINAL_TDS-DOCUMENTTYPE = 'CR'.
3103               ELSEIF LS_EKBE_1-VGABE = '3' AND LS_EKBE_1-SHKZG = 'S' AND  GS_FINAL_TDS-SUPPLY_TYPE <> 'CAN'.
3104                 GS_FINAL_TDS-DOCUMENTTYPE  = 'DR'.
3105               ELSEIF LS_EKBE_1-VGABE = '3' AND LS_EKBE_1-SHKZG = 'H' AND   GS_FINAL_TDS-SUPPLY_TYPE = 'CAN'.
3106                 GS_FINAL_TDS-DOCUMENTTYPE  = 'DR'.
3107               ELSEIF LS_EKBE_1-VGABE = '3' AND LS_EKBE_1-SHKZG = 'H' AND   GS_FINAL_TDS-SUPPLY_TYPE <> 'CAN'.
3108                 GS_FINAL_TDS-DOCUMENTTYPE  = 'CR'.
3109               ELSEIF LS_EKBE_1-VGABE = '3' AND LS_EKBE_1-SHKZG = 'S' AND   GS_FINAL_TDS-SUPPLY_TYPE = 'CAN'.
3110                 GS_FINAL_TDS-DOCUMENTTYPE  = 'CR'.
3111               ENDIF.
3112             ELSE.
3113               CLEAR LV_GJAHR.
3114               LV_GJAHR =  LS_BSEG_K-AWKEY+10(4).
3115               READ TABLE LT_RBKP_RE INTO LS_RBKP_RE WITH  KEY BELNR = LS_BSEG_K-AWKEY+0(10)
3116                                                               GJAHR = LV_GJAHR BINARY SEARCH.
3117               IF SY-SUBRC = 0 AND LS_RBKP_RE-XRECH <> 'X' .
3118                 GS_FINAL_TDS-DOCUMENTTYPE  = 'CR'.
3119               ENDIF.
3120             ENDIF.
3121           ENDIF.
3122
3123           IF GS_FINAL_TDS-ORG_DOC_NUM IS INITIAL.
3124             IF LS_BSEG_K-BLART <> 'KA'.
3125               IF  GS_FINAL_TDS-DOCUMENTTYPE  = 'CR' OR GS_FINAL_TDS-DOCUMENTTYPE  = 'DR'
3126                   OR GS_FINAL_TDS-DOCUMENTTYPE  = 'INV'.
3127                 READ TABLE LT_BSEG INTO LS_BSEG_KA_NEW WITH  KEY BELNR  = LS_BSEG-BELNR
3128                                                                   BUKRS = LS_BSEG-BUKRS
3129                                                                   GJAHR = LS_BSEG-GJAHR
3130                                                                   KOART = 'K'.
3131                 IF SY-SUBRC = 0.
3132                   IF LS_BSEG_KA_NEW-REBZG <> 'V'.
3133                     GS_FINAL_TDS-ORG_DOC_NUM   = LS_BSEG_KA_NEW-REBZG.
3134                     READ TABLE LT_BKPF_NEW2 INTO LS_BKPF_NEW WITH  KEY BUKRS  = LS_BSEG-BUKRS
3135                                                                         BELNR = LS_BSEG_KA_NEW-REBZG
3136                                                                         GJAHR = LS_BSEG_KA_NEW-REBZJ BINARY SEARCH.
3137                     IF SY-SUBRC = 0.
3138                       GS_FINAL_TDS-BLART_CR = LS_BKPF_NEW-BLART.
3139                       CONCATENATE LS_BKPF_NEW-BUDAT+6(2) LS_BKPF_NEW-BUDAT+4(2)
3140                                   LS_BKPF_NEW-BUDAT+0(4) INTO GS_FINAL_TDS-ORG_DOC_DATE SEPARATED BY '-'  .
3141                     ENDIF.
3142                   ENDIF.
3143                 ENDIF.
3144               ENDIF.
3145             ENDIF.
3146           ENDIF.
3147
3148   " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
3149   *        IF ( LS_BKPF-TCODE = 'MR8M' OR LS_BKPF-TCODE = 'MBST') AND (  LS_BKPF-BLART = 'RE' OR  LS_BKPF-BLART = 'KS'  ).
3150           IF ( LS_BKPF-TCODE = 'MR8M' OR LS_BKPF-TCODE = 'MBST') AND (  LS_BKPF-BLART = 'RE' OR  LS_BKPF-BLART = 'KS'  ). "#EC CI_USAGE_OK[1804812]
3151   " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
3152             LV_INV_AMOUNT = LS_BSEG-DMBTR .
3153           ELSE.
3154             LV_INV_AMOUNT = LS_BSEG-DMBTR.
3155           ENDIF.
3156
3157           IF  ( LS_BKPF-BLART = 'RE' OR LS_BKPF-BLART = 'KS' ) AND  ( LS_BSEG-KOART = 'S' AND LS_BSEG-SHKZG = 'S' AND LS_BSEG-XNEGP = 'X' ).
3158             LV_INV_AMOUNT = LS_BSEG-DMBTR .
3159           ENDIF.
3160
3161           CLEAR : LV_CODE,LV_REGIO.
3162           LV_CODE = GS_FINAL_TDS-POS.
3163           LV_REGIO = LV_CODE.
3164           CONDENSE LV_REGIO.
3165           READ TABLE LT_STATECODE INTO LS_STATECODE WITH KEY GSTCODE = LV_REGIO.
3166           IF SY-SUBRC  = 0.
3167   *          gs_final_tds-pos = ls_statecode-bezei.
3168           ENDIF.
3169
3170           GS_FINAL_TDS-TAXABLEVALUE = LS_BSEG-DMBTR.
3171           GS_FINAL_TDS-AMOUNT = LS_BSEG-WRBTR.
3172
3173           IF LS_BKPF-BLART = 'RE' OR LS_BKPF-BLART = 'RN' OR LS_BKPF-BLART = 'KR' OR LS_BKPF-BLART = 'KS'.
3174             IF GS_FINAL_TDS-TAXABLEVALUE IS NOT INITIAL
3175               AND LS_BSEG_K-SKFBT IS NOT INITIAL
3176               AND GS_FINAL_TDS-TDS_RATE IS INITIAL .
3177               GS_FINAL_TDS-TDS_AMOUNT = ( GS_FINAL_TDS-TAXABLEVALUE / LS_BSEG_K-SKFBT *  LV_TDS_AMT ).
3178             ENDIF.
3179           ENDIF.
3180
3181           IF LS_BSEG_K-SHKZG = 'H' AND GS_FINAL_TDS-TAXABLEVALUE LT 0.
3182             GS_FINAL_TDS-TAXABLEVALUE = GS_FINAL_TDS-TAXABLEVALUE * 1 .
3183           ENDIF.
3184           IF LS_BSEG_K-SHKZG = 'H' AND GS_FINAL_TDS-AMOUNT LT 0.
3185             GS_FINAL_TDS-AMOUNT = GS_FINAL_TDS-AMOUNT * 1.  " -1.
3186           ENDIF.
3187
3188           IF LS_BSEG_K-SHKZG = 'S' AND GS_FINAL_TDS-TAXABLEVALUE GT 0.
3189             GS_FINAL_TDS-TAXABLEVALUE = GS_FINAL_TDS-TAXABLEVALUE * 1.
3190           ENDIF.
3191           IF LS_BSEG_K-SHKZG = 'S' AND GS_FINAL_TDS-AMOUNT GT 0.
3192             GS_FINAL_TDS-AMOUNT = GS_FINAL_TDS-AMOUNT * 1.  " -1.
3193           ENDIF.
3194
3195           IF LS_BSEG_K-SHKZG = 'H' AND GS_FINAL_TDS-TDS_AMOUNT LT 0.
3196             GS_FINAL_TDS-TDS_AMOUNT = GS_FINAL_TDS-TDS_AMOUNT * 1.
3197           ENDIF.
3198
3199           IF LS_BSEG_K-SHKZG = 'S' AND GS_FINAL_TDS-TDS_AMOUNT GT 0.
3200             GS_FINAL_TDS-TDS_AMOUNT = GS_FINAL_TDS-TDS_AMOUNT * 1.
3201           ENDIF.
3202
3203           IF LS_BSEG_K-WAERS = 'INR'.
3204             GS_FINAL_TDS-AMOUNT =  0.
3205             GS_FINAL_TDS-EXCH_RATE =  0.
3206             GS_FINAL_TDS-CURRENCY = ''.
3207
3208           ENDIF.
3209
3210           READ TABLE LT_BSEG_A INTO LS_BSEG_A WITH KEY BELNR  = LS_BSEG-BELNR
3211                                                         BUKRS = LS_BSEG-BUKRS
3212                                                         GJAHR = LS_BSEG-GJAHR
3213                                                         BUZEI = LS_BSEG-BUZEI.
3214           IF SY-SUBRC = 0.
3215             IF ( LS_BSEG_A-BUZID = 'W' AND LS_BSEG_A-KTOSL = 'WRX' )
3216               OR ( LS_BSEG_A-BUZID = 'S' AND LS_BSEG_A-KTOSL = 'KBS' )
3217               OR  ( LS_BSEG_A-BUZID = 'S' AND LS_BSEG_A-KTOSL = 'ANL' ).
3218               GS_FINAL_TDS-XREF3 = LS_BSEG_A-XREF3.
3219             ENDIF.
3220           ENDIF.
3221
3222   * Get Source Id * Source File.
3223           GS_FINAL_TDS-SOURCE_ID = SY-MANDT.
3224           GS_FINAL_TDS-SOURCE_FIL = 'TDS_Invoice CSV file'.
3225
3226           IF GS_FINAL_TDS-ORG_DOC_DATE IS NOT INITIAL AND LS_BSEG_K-XREVERSAL = '2'.
3227             IF GS_FINAL_TDS-POST_DAT_DOCU+3(2) <> GS_FINAL_TDS-ORG_DOC_DATE+3(2).
3228               GS_FINAL_TDS-SUPPLY_TYPE = 'REV'.
3229               " soc by zubair ' 20.3.24
3230             ELSEIF GS_FINAL_TDS-POST_DAT_DOCU+3(2) = GS_FINAL_TDS-ORG_DOC_DATE+3(2).
3231               GS_FINAL_TDS-SUPPLY_TYPE = 'CAN'.
3232             ENDIF.
3233             " eoc by zubair ' 20.3.24
3234           ENDIF.
3235
3236
3237           READ TABLE LT_BKPF_NEW INTO LS_BKPF_NEW WITH  KEY BUKRS = LS_BSEG-BUKRS
3238                                                             BELNR = GS_FINAL_TDS-ORG_DOC_NUM .
3239           IF SY-SUBRC = 0.
3240             IF LS_BKPF_NEW-BLART = 'RE' OR LS_BKPF_NEW-BLART = 'ZA' OR LS_BKPF_NEW-BLART = 'KS'.
3241               READ TABLE LT_RBKP_RE INTO LS_RBKP_RE WITH  KEY BELNR = LS_BKPF_NEW-AWKEY+0(10)
3242                                                               GJAHR = LS_BKPF_NEW-AWKEY+10(4) BINARY SEARCH.
3243               IF SY-SUBRC = 0.
3244                 IF LS_RBKP_RE-XRECH <> 'X'.
3245                   GS_FINAL_TDS-DOCUMENTTYPE  = 'CR'.
3246                 ELSE.
3247                   READ TABLE LT_EKBE_1 INTO LS_EKBE_1 WITH KEY GJAHR = LS_RBKP_RE-GJAHR
3248                                                                BELNR = LS_RBKP_RE-BELNR BINARY SEARCH.
3249                   IF SY-SUBRC = 0.
3250                     IF LS_EKBE_1-VGABE = '2'.
3251                       GS_FINAL_TDS-DOCUMENTTYPE  = 'INV'.
3252                     ELSEIF LS_EKBE_1-VGABE = '3'.
3253                       GS_FINAL_TDS-DOCUMENTTYPE  = 'DR'.
3254                     ENDIF.
3255                   ENDIF.
3256                 ENDIF.
3257               ENDIF.
3258             ENDIF.
3259           ENDIF.
3260
3261           "addition condition logic
3262           CLEAR:GS_FINAL_TDS-FLAG.
3263           IF GS_FINAL_TDS-DOCUMENTTYPE = 'INV'
3264             AND ( GS_FINAL_TDS-SUPPLY_TYPE <> 'CAN'  AND GS_FINAL_TDS-SUPPLY_TYPE <> 'REV' )
3265              AND GS_FINAL_TDS-SHKZG = 'S'.
3266             GS_FINAL_TDS-FLAG = 'X'.
3267
3268           ELSEIF GS_FINAL_TDS-DOCUMENTTYPE = 'DR'
3269             AND ( GS_FINAL_TDS-SUPPLY_TYPE <> 'CAN'  AND GS_FINAL_TDS-SUPPLY_TYPE <> 'REV' )
3270             AND GS_FINAL_TDS-SHKZG = 'S'.
3271             GS_FINAL_TDS-FLAG = 'X'.
3272
3273           ELSEIF GS_FINAL_TDS-DOCUMENTTYPE = 'CR'
3274             AND ( GS_FINAL_TDS-SUPPLY_TYPE <> 'CAN'  AND GS_FINAL_TDS-SUPPLY_TYPE <> 'REV' )
3275             AND GS_FINAL_TDS-SHKZG = 'H'.
3276             GS_FINAL_TDS-FLAG = 'X'.
3277
3278           ELSEIF GS_FINAL_TDS-DOCUMENTTYPE = 'INV'
3279             AND ( GS_FINAL_TDS-SUPPLY_TYPE = 'CAN' OR GS_FINAL_TDS-SUPPLY_TYPE = 'REV' )
3280             AND GS_FINAL_TDS-SHKZG = 'H'.
3281             GS_FINAL_TDS-FLAG = 'X'.
3282
3283           ELSEIF GS_FINAL_TDS-DOCUMENTTYPE = 'DR'
3284             AND ( GS_FINAL_TDS-SUPPLY_TYPE = 'CAN' OR GS_FINAL_TDS-SUPPLY_TYPE = 'REV' )
3285             AND GS_FINAL_TDS-SHKZG = 'H'.
3286             GS_FINAL_TDS-FLAG = 'X'.
3287
3288           ELSEIF GS_FINAL_TDS-DOCUMENTTYPE = 'CR'
3289             AND ( GS_FINAL_TDS-SUPPLY_TYPE = 'CAN' OR GS_FINAL_TDS-SUPPLY_TYPE = 'REV' )
3290             AND GS_FINAL_TDS-SHKZG = 'S'.
3291             GS_FINAL_TDS-FLAG = 'X'.
3292           ENDIF.
3293
3294           "addition condition logic
3295           IF S_DATE[] IS NOT INITIAL OR S_CDATE[] IS NOT INITIAL OR CR_DATE[] IS NOT INITIAL.
3296             IF S_DATE[] IS NOT INITIAL.
3297               IF S_DATE-LOW IS NOT INITIAL AND S_DATE-HIGH IS NOT INITIAL.
3298
3299                 CONCATENATE  'INV_' GS_FINAL_TDS-DEDUCTOR_PAN '_'
3300                                      GS_FINAL_TDS-DEDUCTOR_TAN '_'
3301                                      S_DATE-LOW+6(2) '-' S_DATE-LOW+4(2) '-' S_DATE-LOW+0(4) '_'
3302                                      S_DATE-HIGH+6(2) '-' S_DATE-HIGH+4(2) '-' S_DATE-HIGH+0(4)
3303                                      INTO GS_FINAL_TDS-SOURCE_FIL.
3304
3305               ELSEIF S_DATE-LOW IS NOT INITIAL AND S_DATE-HIGH IS  INITIAL.
3306
3307                 CONCATENATE  'INV_' GS_FINAL_TDS-DEDUCTOR_PAN '_'
3308                                    GS_FINAL_TDS-DEDUCTOR_TAN '_'
3309                                    S_DATE-LOW+6(2) '-' S_DATE-LOW+4(2) '-' S_DATE-LOW+0(4) '_'
3310                                    S_DATE-LOW+6(2) '-' S_DATE-LOW+4(2) '-' S_DATE-LOW+0(4)
3311                                    INTO GS_FINAL_TDS-SOURCE_FIL.
3312               ENDIF.
3313             ELSEIF S_CDATE[] IS NOT INITIAL.
3314               IF S_CDATE-LOW IS NOT INITIAL AND S_CDATE-HIGH IS NOT INITIAL.
3315                 CONCATENATE  'INV_' GS_FINAL_TDS-DEDUCTOR_PAN '_'
3316                                     GS_FINAL_TDS-DEDUCTOR_TAN  '_'
3317                                     S_CDATE-LOW+6(2) '-' S_CDATE-LOW+4(2) '-' S_CDATE-LOW+0(4) '_'
3318                                     S_CDATE-HIGH+6(2) '-' S_CDATE-HIGH+4(2) '-' S_CDATE-HIGH+0(4)
3319                                     INTO GS_FINAL_TDS-SOURCE_FIL.
3320
3321               ELSEIF S_CDATE-LOW IS NOT INITIAL AND S_CDATE-HIGH IS  INITIAL.
3322                 CONCATENATE  'INV_' GS_FINAL_TDS-DEDUCTOR_PAN '_'
3323                                     GS_FINAL_TDS-DEDUCTOR_TAN '_'
3324                                     S_CDATE-LOW+6(2) '-' S_CDATE-LOW+4(2)'-' S_CDATE-LOW+0(4) '_'
3325                                     S_CDATE-LOW+6(2) '-' S_CDATE-LOW+4(2)'-' S_CDATE-LOW+0(4)
3326                                     INTO GS_FINAL_TDS-SOURCE_FIL.
3327               ENDIF.
3328             ELSEIF CR_DATE[] IS NOT INITIAL.
3329
3330               IF CR_DATE-LOW IS NOT INITIAL AND CR_DATE-HIGH IS NOT INITIAL.
3331                 CONCATENATE  'INV_' GS_FINAL_TDS-DEDUCTOR_PAN '_'
3332                                     GS_FINAL_TDS-DEDUCTOR_TAN '_'
3333                                     CR_DATE-LOW+6(2) '-' CR_DATE-LOW+4(2) '-' CR_DATE-LOW+0(4) '_'
3334                                     CR_DATE-HIGH+6(2) '-' CR_DATE-HIGH+4(2) '-' CR_DATE-HIGH+0(4)
3335                                     INTO GS_FINAL_TDS-SOURCE_FIL.
3336
3337               ELSEIF CR_DATE-LOW IS NOT INITIAL AND CR_DATE-HIGH IS  INITIAL.
3338                 CONCATENATE  'INV_' GS_FINAL_TDS-DEDUCTOR_PAN '_'
3339                                    GS_FINAL_TDS-DEDUCTOR_TAN '_'
3340                                    CR_DATE-LOW+6(2) '-' CR_DATE-LOW+4(2) '-' CR_DATE-LOW+0(4) '_'
3341                                    CR_DATE-LOW+6(2) '-' S_CDATE-LOW+4(2) '-' S_CDATE-LOW+0(4)
3342                                    INTO GS_FINAL_TDS-SOURCE_FIL.
3343               ENDIF.
3344             ENDIF.
3345           ELSE.
3346             CONCATENATE  'INV_' GS_FINAL_TDS-DEDUCTOR_PAN '_'
3347                                 GS_FINAL_TDS-DEDUCTOR_TAN '_' GV_LOW '_'
3348                                 GV_HIGH INTO GS_FINAL_TDS-SOURCE_FIL.
3349           ENDIF.
3350
3351           SHIFT GS_FINAL_TDS-ORG_DOC_NUM   LEFT DELETING LEADING '0'.
3352           SHIFT GS_FINAL_TDS-DOCUMENT_NUMB LEFT DELETING LEADING '0'.
3353           SHIFT GS_FINAL_TDS-GL_ACC_CODE   LEFT DELETING LEADING '0'.
3354           SHIFT GS_FINAL_TDS-DEDUCTEE_CODE LEFT DELETING LEADING '0'.
3355           SHIFT GS_FINAL_TDS-ERP_NUM       LEFT DELETING LEADING '0'.
3356           SHIFT GS_FINAL_TDS-PO_LINE_ITEM  LEFT DELETING LEADING '0'.
3357           SHIFT GS_FINAL_TDS-ACCOUNT_SEQ   LEFT DELETING LEADING '0'.
3358   *        SHIFT GS_FINAL_TDS-ITEM_CODE     LEFT DELETING LEADING '0'.  ""AM-30-04-24
3359           SHIFT GS_FINAL_TDS-PO_NUMBER     LEFT DELETING LEADING '0'.
3360
3361           IF GS_FINAL_TDS-HSN_SAC_CODE IS INITIAL.
3362             READ TABLE T_MARC INTO DATA(W_MARC) WITH KEY MATNR = LS_BSEG-MATNR
3363                                                          WERKS = LS_BSEG-WERKS BINARY SEARCH.
3364             IF SY-SUBRC = 0.
3365               GS_FINAL_TDS-HSN_SAC_CODE = W_MARC-STEUC.
3366               GS_FINAL_TDS-HSN_SAC_DES = W_MARC-TEXT1.
3367               CLEAR W_MARC.
3368             ENDIF.
3369           ENDIF.
3370
3371
3372           IF R_FILE <> 'X'.
3373             IF  GS_FINAL_TDS-XREF3 IS NOT INITIAL.
3374               CONCATENATE 'A'  GS_FINAL_TDS-XREF3 INTO  GS_FINAL_TDS-XREF3.
3375             ENDIF.
3376           ENDIF.
3377
3378           IF GS_FINAL_TDS-DOCUMENT_NUMB IS NOT INITIAL.
3379             IF GS_FINAL_TDS-TAXABLEVALUE IS INITIAL.
3380
3381               CLEAR: GS_FINAL_TDS-CGSTRATE, GS_FINAL_TDS-CGSTAMOUNT,
3382                      GS_FINAL_TDS-SGSTRATE, GS_FINAL_TDS-SGSTAMOUNT,
3383                      GS_FINAL_TDS-IGSTRATE, GS_FINAL_TDS-IGSTAMOUNT,
3384                      GS_FINAL_TDS-CESSRATE, GS_FINAL_TDS-CESSAMOUNT,
3385                       GS_FINAL_TDS-AVAIL_CESS, GS_FINAL_TDS-AVAIL_CGST,
3386                     GS_FINAL_TDS-AVAIL_SGST, GS_FINAL_TDS-AVAIL_IGST.
3387
3388             ENDIF.
3389             IF GS_FINAL_TDS-RCM IS INITIAL.
3390               GS_FINAL_TDS-RCM = 'N'.
3391             ENDIF.
3392
3393             READ TABLE LT_RSEG INTO DATA(LS_RSEG) WITH KEY BELNR = LS_BSEG-AWKEY+0(10)
3394                                                      GJAHR = LS_BSEG-AWKEY+10(4)
3395                                                      EBELN = LS_BSEG-EBELN
3396                                                      EBELP = LS_BSEG-EBELP
3397                                                      WRBTR = LS_BSEG-DMBTR BINARY SEARCH.
3398             IF SY-SUBRC = 0.
3399               GS_FINAL_TDS-CIF_VALUE  = LS_RSEG-CUSTOMS_VAL.
3400               CLEAR LS_RSEG.
3401             ENDIF.
3402
3403
3404             IF GS_FINAL_TDS-BUKRS1 = LV_BUKRS
3405               AND GS_FINAL_TDS-LINENUMBER = LV_BUZEI AND GS_FINAL_TDS-BELNR = LV_BELNR.
3406             ELSE.
3407               GS_FINAL_TDS-LINENUMBER = |{ GS_FINAL_TDS-LINENUMBER ALPHA = OUT }|.
3408               APPEND GS_FINAL_TDS TO GT_FINAL_TDS.
3409             ENDIF.
3410             CLEAR : GS_FINAL_TDS-CGSTRATE, GS_FINAL_TDS-CGSTAMOUNT,
3411                     GS_FINAL_TDS-SGSTRATE, GS_FINAL_TDS-SGSTAMOUNT,
3412                     GS_FINAL_TDS-IGSTRATE, GS_FINAL_TDS-IGSTAMOUNT,GS_FINAL_TDS-ITEM_CAT,
3413                     GS_FINAL_TDS-AVAIL_CESS, GS_FINAL_TDS-AVAIL_CGST,
3414                     GS_FINAL_TDS-AVAIL_SGST, GS_FINAL_TDS-AVAIL_IGST,
3415                     GS_FINAL_TDS-CESSRATE, GS_FINAL_TDS-CESSAMOUNT,GS_FINAL_TDS-GROSSUPINDICATOR, GS_FINAL_TDS-HSN_SAC_CODE,
3416             GS_FINAL_TDS-XREF3,
3417             GS_FINAL_TDS-SUPPLY_TYPE,
3418             GS_FINAL_TDS-RCM,
3419             GS_FINAL_TDS-GST_DEDU,
3420             GS_FINAL_TDS-EXEMP_NUM.
3421             LV_FLAG = 'X'.
3422
3423
3424
3425           ENDIF.
3426
3427           LV_BUZEI = LS_BSEG-BUZEI.
3428           LV_BELNR = LS_BSEG-BELNR.
3429           LV_BUKRS = LS_BSEG-BUKRS.
3430
3431   *        AT END OF belnr.
3432   *          DELETE lt_bseg2 WHERE bukrs = ls_bseg-bukrs AND
3433   *                                belnr = ls_bseg-belnr AND
3434   *                                gjahr = ls_bseg-gjahr.
3435   *        ENDAT.
3436
3437           CLEAR: LS_BSEG,LS_BSET,LS_LFA1,LS_J_1IMOVEND,LS_MARC,  LS_T604N, LS_ADRC,
3438                  LS_SKAT,LS_J_1I_SECCO_CIT,LS_J_1BBRANCH,LS_T001Z,LS_T059Z,LS_ASMD,LS_ASMDT, LS_BSEG_V,GS_FINAL_TDS-FLAG,
3439                  LS_WITH_ITEM,LS_T059Z,  LS_STATECODE,LS_BSEG_P,LS_BSEG_Q, LS_EKPO,GS_FINAL_TDS-GL_ACC_CODE.
3440
3441         ENDIF.
3442       ENDLOOP.
3443
3444       IF LV_FLAG = 'X'.
3445         DELETE LT_BSEG_W WHERE BUKRS = LS_BKPF-BUKRS AND
3446                                BELNR = LS_BKPF-BELNR AND
3447                                GJAHR = LS_BKPF-GJAHR.
3448         DELETE LT_BSEG_K WHERE BUKRS = LS_BKPF-BUKRS AND
3449                                BELNR = LS_BKPF-BELNR AND
3450                                GJAHR = LS_BKPF-GJAHR.
3451         CLEAR : LV_FLAG. "AM-03.04.24
3452       ENDIF.
3453
3454       IF LV_FLAG = ' '.
3455         LS_DEL_BEL-BUKRS = LS_BSEG_K-BUKRS.
3456         LS_DEL_BEL-BELNR = LS_BSEG_K-BELNR.
3457         LS_DEL_BEL-GJAHR = LS_BSEG_K-GJAHR.
3458         LS_DEL_BEL-FLAG = 'X'.
3459         APPEND LS_DEL_BEL TO LT_DEL_BEL.
3460         CLEAR:LS_DEL_BEL.
3461       ENDIF.
3462
3463       CLEAR : GS_FINAL_TDS,LS_BKPF,LS_BSEG_K.
3464
3465     ENDLOOP.
3466
3467     "To Maintain single supply type for signle document
3468
3469     CLEAR : LT_FINAL_TDSS.
3470     LT_FINAL_TDSS = GT_FINAL_TDS.
3471
3472     CLEAR :LS_FINAL_TDSS.
3473     LOOP AT LT_FINAL_TDSS INTO LS_FINAL_TDSS.
3474
3475       CLEAR :GS_FINAL_TDS,LV_SUPPLY_TYP.
3476       LOOP AT GT_FINAL_TDS INTO GS_FINAL_TDS WHERE BELNR  EQ LS_FINAL_TDSS-BELNR
3477                                              AND   BUKRS1 EQ LS_FINAL_TDSS-BUKRS1
3478                                              AND   GJAHR  EQ LS_FINAL_TDSS-GJAHR
3479                                              AND   HSN_SAC_CODE IS NOT INITIAL
3480                                              AND   SUPPLY_TYPE IS NOT INITIAL.
3481
3482         CLEAR:LV_SUPPLY_TYP.
3483         LV_SUPPLY_TYP = GS_FINAL_TDS-SUPPLY_TYPE.
3484         EXIT.
3485       ENDLOOP.
3486
3487
3488       IF LV_SUPPLY_TYP IS NOT INITIAL.
3489         LOOP AT GT_FINAL_TDS ASSIGNING FIELD-SYMBOL(<FS_FINAL_TDS>) WHERE BELNR EQ LS_FINAL_TDSS-BELNR
3490                                                                     AND   BUKRS1 EQ LS_FINAL_TDSS-BUKRS1
3491                                                                     AND   GJAHR  EQ LS_FINAL_TDSS-GJAHR
3492                                                                     AND   HSN_SAC_CODE IS INITIAL.
3493           <FS_FINAL_TDS>-SUPPLY_TYPE = LV_SUPPLY_TYP.
3494         ENDLOOP.
3495
3496         UNASSIGN <FS_FINAL_TDS>.
3497       ENDIF.
3498
3499
3500
3501       CLEAR :LS_FINAL_TDSS.
3502     ENDLOOP.
3503
3504     "To Maintain POS if POS not available line item wise
3505     LOOP AT GT_FINAL_TDS ASSIGNING <FS_FINAL_TDS> WHERE POS IS INITIAL.
3506
3507       CLEAR:LS_BSEG_K,LS_T005U.
3508       READ TABLE LT_BSEG_K INTO LS_BSEG_K WITH KEY BELNR = <FS_FINAL_TDS>-BELNR
3509                                                    PLC_SUP = 'K'.
3510       IF SY-SUBRC EQ 0.
3511         <FS_FINAL_TDS>-POS          = LS_BSEG_K-PLC_SUP.
3512
3513         READ TABLE LT_T005U INTO LS_T005U WITH  KEY BLAND = <FS_FINAL_TDS>-POS BINARY SEARCH.
3514         IF SY-SUBRC = 0.
3515           <FS_FINAL_TDS>-POS = LS_T005U-BEZEI.
3516         ENDIF.
3517       ENDIF.
3518       CLEAR :LS_BSEG_K,LS_T005U.
3519     ENDLOOP.
3520
3521
3522
3523   ****************************************************
3524     LOOP AT LT_BSEG_K INTO LS_BSEG_K.
3525
3526       CLEAR : GS_FINAL_TDS.
3527       GS_FINAL_TDS-ERP_DOC_TYPE = LS_BSEG_K-BLART.
3528       GS_FINAL_TDS-USERNAME     = LS_BSEG_K-USNAM.
3529       GS_FINAL_TDS-TRANS_CODE   = LS_BSEG_K-TCODE.
3530
3531       READ TABLE LT_BSEG_A INTO LS_BSEG_A WITH KEY BUKRS = LS_BSEG_K-BUKRS
3532                                                    BELNR = LS_BSEG_K-BELNR
3533                                                    GJAHR = LS_BSEG_K-GJAHR BINARY SEARCH .
3534       IF SY-SUBRC = 0.
3535         GS_FINAL_TDS-ASSIGN_NUM = LS_BSEG_A-ZUONR.
3536         CLEAR LS_BSEG_A.
3537       ENDIF.
3538
3539       READ TABLE LT_BSEG_P INTO LS_BSEG_P WITH KEY BUKRS = LS_BSEG_K-BUKRS
3540                                                    BELNR = LS_BSEG_K-BELNR
3541                                                    GJAHR = LS_BSEG_K-GJAHR BINARY SEARCH .
3542       IF SY-SUBRC = 0.
3543         GS_FINAL_TDS-PROFIT_CENTER = LS_BSEG_P-PRCTR.
3544         CLEAR LS_BSEG_P.
3545       ENDIF.
3546
3547       READ TABLE LT_BSEG_WE INTO LS_BSEG_WE WITH KEY BUKRS = LS_BSEG_K-BUKRS
3548                                                      BELNR = LS_BSEG_K-BELNR
3549                                                      GJAHR = LS_BSEG_K-GJAHR BINARY SEARCH .
3550       IF SY-SUBRC = 0.
3551         GS_FINAL_TDS-PLANT = LS_BSEG_WE-WERKS.
3552         CLEAR LS_BSEG_WE.
3553       ENDIF.
3554
3555       READ TABLE LT_BKPF INTO LS_BKPF WITH KEY BUKRS = LS_BSEG_K-BUKRS
3556                                                BELNR = LS_BSEG_K-BELNR
3557                                                GJAHR = LS_BSEG_K-GJAHR BINARY SEARCH.
3558       CHECK SY-SUBRC = 0.
3559       GS_FINAL_TDS-VEND_INV_NUM  = LS_BKPF-XBLNR.
3560       GS_FINAL_TDS-CR_DATE       = LS_BKPF-CPUDT.
3561       GS_FINAL_TDS-ERP_NUM       = LS_BKPF-BELNR.
3562       GS_FINAL_TDS-BELNR         = GS_FINAL_TDS-DOCUMENT_NUMB = LS_BKPF-BELNR.
3563
3564       CONCATENATE LS_BKPF-BLDAT+6(2) LS_BKPF-BLDAT+4(2) LS_BKPF-BLDAT+0(4)
3565       INTO GS_FINAL_TDS-DOCUMENTDATE SEPARATED BY '-'  .
3566
3567       CONCATENATE LS_BKPF-BUDAT+6(2) LS_BKPF-BUDAT+4(2) LS_BKPF-BUDAT+0(4)
3568       INTO GS_FINAL_TDS-POST_DAT_DOCU SEPARATED BY '-'  .
3569
3570       GS_FINAL_TDS-BUDAT = LS_BKPF-BUDAT.
3571
3572       IF LS_BKPF-BLART = 'WE'.
3573         CONTINUE.
3574       ENDIF.
3575
3576       READ TABLE LT_BSEG_W INTO LS_BSEG WITH KEY BUKRS = LS_BKPF-BUKRS
3577                                                  BELNR = LS_BKPF-BELNR
3578                                                  GJAHR = LS_BKPF-GJAHR .
3579       IF SY-SUBRC = 0 AND LS_BSEG-KOART <> 'K'.
3580         IF ( LS_BSEG-KTOSL = 'WIT' OR LS_BSEG-KTOSL = 'OFF'  OR LS_BSEG-KTOSL = 'GRU' ).
3581           CONTINUE.
3582         ELSE.
3583
3584           IF LS_BKPF-BLART = 'KA' AND LS_BSEG-UMSKZ = 'F'
3585             AND LS_BSEG-UMSKS = 'A'.
3586             CONTINUE.
3587           ENDIF.
3588
3589           GS_FINAL_TDS-BUKRS1 = LS_BKPF-BUKRS.
3590           GS_FINAL_TDS-BELNR  = LS_BKPF-BELNR.
3591           GS_FINAL_TDS-GJAHR  = LS_BKPF-GJAHR.
3592           GS_FINAL_TDS-BUDAT  = LS_BKPF-BUDAT.
3593           GS_FINAL_TDS-BUZEI  = LS_BSEG-BUZEI.
3594           GS_FINAL_TDS-BUPLA  = LS_BSEG_K-BUPLA.
3595
3596           GS_FINAL_TDS-BUSINESS_PLACE  = LS_BSEG_K-BUPLA.
3597           GS_FINAL_TDS-BUSINESS_AREA   = LS_BSEG-GSBER.
3598           GS_FINAL_TDS-SECTIONCODE     = LS_BSEG_K-SECCO.
3599
3600           GS_FINAL_TDS-ASSIGN_NUM  = LS_BSEG-ZUONR.
3601           GS_FINAL_TDS-ACCOUNT_SEQ = LS_BSEG-ZEKKN.
3602           GS_FINAL_TDS-ACCOUNT_SEQ = LS_BSEG-PRCTR.
3603           GS_FINAL_TDS-SHKZG       = LS_BSEG-SHKZG.
3604           GS_FINAL_TDS-BUZEI       = GS_FINAL_TDS-LINENUMBER = LS_BSEG-BUZEI.
3605           GS_FINAL_TDS-GJAHR       = LS_BSEG-GJAHR.
3606
3607           GS_FINAL_TDS-PO_NUMBER     = LS_BSEG-EBELN.
3608           GS_FINAL_TDS-PO_LINE_ITEM  = LS_BSEG-EBELP.
3609           GS_FINAL_TDS-COMPANY_CODE  = LS_BSEG-BUKRS.
3610
3611           GS_FINAL_TDS-ERP_DOC_TYPE  = LS_BKPF-BLART.
3612           GS_FINAL_TDS-HSN_SAC_CODE  = LS_BSEG-HSN_SAC.
3613
3614           IF LS_BKPF-BLART = 'RE' OR LS_BSEG_K-BLART = 'ZA' OR LS_BSEG_K-BLART = 'ZC' OR LS_BKPF-BLART = 'KS'.
3615             GS_FINAL_TDS-SERVICE_DES_INV  = LS_BSEG_K-SGTXT.
3616           ELSE.
3617             GS_FINAL_TDS-SERVICE_DES_INV  = LS_BSEG-SGTXT.
3618           ENDIF.
3619
3620           IF GS_FINAL_TDS-TAXABLEVALUE IS INITIAL.
3621             GS_FINAL_TDS-TAXABLEVALUE = LS_BSEG-DMBTR.
3622           ENDIF.
3623           IF GS_FINAL_TDS-AMOUNT IS INITIAL.
3624             GS_FINAL_TDS-AMOUNT = LS_BSEG-WRBTR.
3625           ENDIF.
3626
3627           IF GS_FINAL_TDS-LINENUMBER IS INITIAL.
3628             GS_FINAL_TDS-BUZEI = GS_FINAL_TDS-LINENUMBER = LS_BSEG_K-BUZEI.
3629           ENDIF.
3630           READ TABLE LT_BSEG_TDS INTO LS_BSEG_TDS WITH KEY BUKRS = LS_BSEG-BUKRS
3631                                                           BELNR  = LS_BSEG-BELNR
3632                                                           GJAHR  = LS_BSEG-GJAHR
3633                                                           TXGRP  = LS_BSEG-TXGRP BINARY SEARCH.
3634           IF SY-SUBRC = 0.
3635             CLEAR : LV_TABIX.
3636
3637             LV_TABIX = SY-TABIX.
3638             LOOP AT LT_BSET INTO LS_BSET WHERE BUKRS  = LS_BSEG_TDS-BUKRS AND
3639                                                BELNR  = LS_BSEG_TDS-BELNR AND
3640                                                GJAHR  = LS_BSEG_TDS-GJAHR AND
3641                                                TXGRP  = LS_BSEG_TDS-TXGRP AND
3642                                                TAXPS  = LS_BSEG_TDS-TAXPS.
3643               IF LS_BSET-STBKZ = '3'.
3644                 GS_FINAL_TDS-CRED_YN       = 'No'.
3645               ELSEIF LS_BSET-STBKZ = '2'.
3646                 GS_FINAL_TDS-CRED_YN       = 'Yes'.
3647               ENDIF.
3648
3649               READ TABLE LT_BSET_NEW INTO LS_BSET_NEW WITH KEY BUKRS   = LS_BSEG_TDS-BUKRS
3650                                                                 BELNR  = LS_BSEG_TDS-BELNR
3651                                                                 GJAHR  = LS_BSEG_TDS-GJAHR
3652                                                                 TXGRP  = LS_BSEG_TDS-TXGRP
3653                                                                  STBKZ = '3'.
3654               IF SY-SUBRC = 0.
3655                 GS_FINAL_TDS-GST_DEDU = 'N'.
3656               ELSE.
3657                 GS_FINAL_TDS-GST_DEDU = 'Y'.
3658               ENDIF.
3659
3660               READ TABLE LT_TDS_COND_TYPE INTO LS_TDS_COND_TYPE WITH  KEY KSCHL = LS_BSET-KSCHL BINARY SEARCH.
3661               IF SY-SUBRC = 0.
3662                 IF LS_TDS_COND_TYPE-TAX_TYPE = 'CGST'.
3663                   GS_FINAL_TDS-CGSTRATE   =  ( LS_BSET-KBETR / 10 ).
3664                   GS_FINAL_TDS-CGSTAMOUNT =  ( LS_BSET-HWSTE ).
3665
3666                   IF GS_FINAL_TDS-GST_DEDU = 'Y'.
3667                     CLEAR:WA_T007B.
3668
3669                     READ TABLE IT_T007B INTO WA_T007B  WITH KEY KTOSL = LS_BSET-KTOSL BINARY SEARCH.
3670                     IF SY-SUBRC EQ 0.
3671                       IF WA_T007B-STAZF = ''.
3672                         GS_FINAL_TDS-AVAIL_CGST   = GS_FINAL_TDS-CGSTAMOUNT.
3673                       ELSE.
3674                         CLEAR:GS_FINAL_TDS-AVAIL_CGST .
3675                       ENDIF.
3676                     ENDIF.
3677                   ENDIF.
3678
3679                 ELSEIF LS_TDS_COND_TYPE-TAX_TYPE = 'SGST'.
3680                   GS_FINAL_TDS-SGSTRATE   = ( LS_BSET-KBETR / 10 ).
3681                   GS_FINAL_TDS-SGSTAMOUNT =  ( LS_BSET-HWSTE ).
3682
3683                   IF GS_FINAL_TDS-GST_DEDU = 'Y'.
3684                     CLEAR:WA_T007B.
3685                     READ TABLE IT_T007B INTO WA_T007B  WITH KEY KTOSL = LS_BSET-KTOSL BINARY SEARCH.
3686                     IF SY-SUBRC EQ 0.
3687                       IF WA_T007B-STAZF = ''.
3688                         GS_FINAL_TDS-AVAIL_SGST   = GS_FINAL_TDS-SGSTAMOUNT.
3689                       ELSE.
3690                         CLEAR:GS_FINAL_TDS-AVAIL_SGST .
3691                       ENDIF.
3692                     ENDIF.
3693                   ENDIF.
3694
3695                 ELSEIF LS_TDS_COND_TYPE-TAX_TYPE = 'IGST'.
3696                   GS_FINAL_TDS-IGSTRATE   = ( LS_BSET-KBETR / 10 ).
3697                   GS_FINAL_TDS-IGSTAMOUNT =  ( LS_BSET-HWSTE ).
3698
3699                   IF GS_FINAL_TDS-GST_DEDU = 'Y'.
3700                     CLEAR:WA_T007B.
3701                     READ TABLE IT_T007B INTO WA_T007B  WITH KEY KTOSL = LS_BSET-KTOSL BINARY SEARCH.
3702                     IF SY-SUBRC EQ 0.
3703                       IF WA_T007B-STAZF = ''.
3704                         GS_FINAL_TDS-AVAIL_IGST   = GS_FINAL_TDS-IGSTAMOUNT.
3705                       ELSE.
3706                         CLEAR:GS_FINAL_TDS-AVAIL_IGST .
3707                       ENDIF.
3708                     ENDIF.
3709                   ENDIF.
3710
3711                 ELSEIF LS_TDS_COND_TYPE-TAX_TYPE = 'CESS'.
3712                   GS_FINAL_TDS-CESSRATE   = ( LS_BSET-KBETR / 10 ) + GS_FINAL_TDS-CESSRATE.
3713                   GS_FINAL_TDS-CESSAMOUNT = LS_BSET-HWSTE + GS_FINAL_TDS-CESSAMOUNT.
3714
3715                   IF GS_FINAL_TDS-GST_DEDU = 'Y'.
3716                     CLEAR:WA_T007B.
3717                     READ TABLE IT_T007B INTO WA_T007B  WITH KEY KTOSL = LS_BSET-KTOSL BINARY SEARCH.
3718                     IF SY-SUBRC EQ 0.
3719                       IF WA_T007B-STAZF = ''.
3720                         GS_FINAL_TDS-AVAIL_CESS   = GS_FINAL_TDS-CESSAMOUNT.
3721                       ELSE.
3722                         CLEAR:GS_FINAL_TDS-AVAIL_CESS .
3723                       ENDIF.
3724                     ENDIF.
3725                   ENDIF.
3726
3727                 ENDIF.
3728               ENDIF.
3729
3730               DELETE LT_BSET WHERE BUKRS = LS_BSET-BUKRS AND
3731                                        BELNR = LS_BSET-BELNR AND
3732                                        GJAHR = LS_BSET-GJAHR AND
3733                                        BUZEI = LS_BSET-BUZEI AND
3734                                        KTOSL = LS_BSET-KTOSL AND
3735                                        TXGRP = LS_BSET-TXGRP AND
3736                                        TAXPS = LS_BSET-TAXPS.
3737
3738               CLEAR: LS_BSET.
3739             ENDLOOP.
3740             IF LV_TABIX IS NOT INITIAL .
3741               DELETE LT_BSEG_TDS INDEX LV_TABIX.
3742               CLEAR : LV_TABIX.
3743             ENDIF.
3744           ENDIF.
3745
3746           IF GS_FINAL_TDS-GST_DEDU IS INITIAL.
3747             READ TABLE LT_BSEG_TDS2 INTO LS_BSEG_TDS2 WITH KEY BUKRS  = LS_BSEG-BUKRS
3748                                                                BELNR  = LS_BSEG-BELNR
3749                                                                GJAHR  = LS_BSEG-GJAHR
3750                                                                MWSKZ  = LS_BSEG-MWSKZ .
3751             IF SY-SUBRC = 0.
3752               READ TABLE LT_BSET_NEW INTO LS_BSET_NEW WITH  KEY BUKRS  = LS_BSEG_TDS2-BUKRS
3753                                                                 BELNR  = LS_BSEG_TDS2-BELNR
3754                                                                 GJAHR  = LS_BSEG_TDS2-GJAHR
3755                                                                 MWSKZ  = LS_BSEG_TDS2-MWSKZ
3756                                                                 STBKZ  = '3'.
3757               IF SY-SUBRC = 0.
3758                 GS_FINAL_TDS-GST_DEDU = 'N'.
3759               ELSE.
3760                 GS_FINAL_TDS-GST_DEDU = 'Y'.
3761               ENDIF.
3762
3763             ENDIF.
3764           ENDIF.
3765
3766           IF GS_FINAL_TDS-CRED_YN IS INITIAL.
3767             READ TABLE LT_BSET1 INTO LS_BSET1 WITH KEY BUKRS = LS_BSEG-BUKRS
3768                                                        BELNR = LS_BSEG-BELNR
3769                                                        GJAHR = LS_BSEG-GJAHR
3770                                                        BUZEI = LS_BSEG-BUZEI
3771                                                        KTOSL = LS_BSEG-KTOSL
3772                                                        TXGRP = LS_BSEG-TXGRP
3773                                                        TAXPS = LS_BSEG-TAXPS.
3774             IF SY-SUBRC  = 0.
3775               IF LS_BSET1-STBKZ = '3'.
3776                 GS_FINAL_TDS-CRED_YN   = 'No'.
3777               ELSEIF LS_BSET1-STBKZ = '2'.
3778                 GS_FINAL_TDS-CRED_YN  = 'Yes'.
3779               ENDIF.
3780             ENDIF.
3781           ENDIF.
3782
3783
3784           READ TABLE LT_T001 INTO LS_T001 WITH KEY BUKRS = LS_BSEG_K-BUKRS BINARY SEARCH.
3785           IF SY-SUBRC = 0.
3786             GS_FINAL_TDS-COMPANY_TXT    = LS_T001-BUTXT.
3787             GS_FINAL_TDS-COMPANY_CODE  = LS_T001-BUKRS.
3788           ENDIF.
3789
3790           READ TABLE LT_T001Z INTO LS_T001Z WITH KEY BUKRS = LS_BSEG_K-BUKRS BINARY SEARCH.
3791           IF SY-SUBRC = 0.
3792             GS_FINAL_TDS-DEDUCTOR_PAN = LS_T001Z-PAVAL.
3793           ENDIF.
3794
3795           CLEAR WA_ZEYTDS_TAN_PRCT.
3796           READ TABLE LT_ZEYTDS_TAN_PRCT INTO WA_ZEYTDS_TAN_PRCT WITH KEY PRCTR = LS_BSEG_K-PRCTR BINARY SEARCH.
3797           IF SY-SUBRC = 0.
3798             GS_FINAL_TDS-DEDUCTOR_TAN = WA_ZEYTDS_TAN_PRCT-VALUE.
3799             GS_FINAL_TDS-TANPARA = 'Profit Center'.
3800             CLEAR WA_ZEYTDS_TAN_PRCT.
3801           ENDIF.
3802
3803           READ TABLE LT_J_1I_SECCO_CIT INTO LS_J_1I_SECCO_CIT WITH KEY BUKRS = LS_BSEG_K-BUKRS
3804                                                                        SECCODE = LS_BSEG_K-SECCO BINARY SEARCH.
3805           IF SY-SUBRC = 0.
3806             GS_FINAL_TDS-DEDUCTOR_TAN = LS_J_1I_SECCO_CIT-TANNO.
3807             GS_FINAL_TDS-TANPARA = 'Section Code'.
3808           ENDIF.
3809
3810           IF CHK = 'X'.
3811             IF GS_FINAL_TDS-DEDUCTOR_TAN IS INITIAL.
3812               IF R_BUKRS = 'X'.
3813                 READ TABLE LT_TDS_TAN INTO LS_TDS_TAN WITH  KEY BUKRS = LS_BSEG_K-BUKRS
3814                                                                 ORG_ELE = LS_BSEG_K-BUKRS BINARY SEARCH.
3815                 IF SY-SUBRC = 0.
3816                   GS_FINAL_TDS-DEDUCTOR_TAN = LS_TDS_TAN-TAN.
3817                   GS_FINAL_TDS-TANPARA = 'Company Code'.
3818                 ENDIF.
3819               ELSEIF R_PLANT = 'X'.
3820                 READ TABLE LT_TDS_TAN INTO LS_TDS_TAN WITH  KEY  BUKRS = LS_BSEG_K-BUKRS
3821                                                                  ORG_ELE = GS_FINAL_TDS-PLANT BINARY SEARCH.
3822                 IF SY-SUBRC = 0.
3823                   GS_FINAL_TDS-DEDUCTOR_TAN = LS_TDS_TAN-TAN.
3824                   GS_FINAL_TDS-TANPARA = 'Plant'.
3825                 ENDIF.
3826               ELSEIF R_BUPLA = 'X'.
3827                 READ TABLE LT_TDS_TAN INTO LS_TDS_TAN WITH  KEY BUKRS = LS_BSEG_K-BUKRS
3828                                                               ORG_ELE = GS_FINAL_TDS-BUPLA BINARY SEARCH .
3829                 IF SY-SUBRC = 0.
3830                   GS_FINAL_TDS-DEDUCTOR_TAN = LS_TDS_TAN-TAN.
3831                   GS_FINAL_TDS-TANPARA = 'Business Place'.
3832                 ENDIF.
3833               ELSEIF R_PRCTR = 'X'.
3834                 READ TABLE LT_TDS_TAN INTO LS_TDS_TAN WITH  KEY BUKRS = LS_BSEG_K-BUKRS
3835                                                               ORG_ELE = GS_FINAL_TDS-PROFIT_CENTER BINARY SEARCH .
3836                 IF SY-SUBRC = 0.
3837                   GS_FINAL_TDS-DEDUCTOR_TAN = LS_TDS_TAN-TAN.
3838                   GS_FINAL_TDS-TANPARA = 'Profit Center'.
3839                 ENDIF.
3840               ELSEIF R_GSBER = 'X'.
3841
3842                 READ TABLE LT_TDS_TAN INTO LS_TDS_TAN WITH  KEY   BUKRS = LS_BSEG_K-BUKRS
3843                                                                   ORG_ELE = GS_FINAL_TDS-BUSINESS_AREA BINARY SEARCH.
3844                 IF SY-SUBRC = 0.
3845                   GS_FINAL_TDS-DEDUCTOR_TAN = LS_TDS_TAN-TAN.
3846                   GS_FINAL_TDS-TANPARA = 'Business area'.
3847                 ENDIF.
3848               ENDIF.
3849             ENDIF.
3850           ENDIF.
3851
3852           IF GS_FINAL_TDS-DEDUCTOR_TAN IS INITIAL.
3853             READ TABLE LT_TDS_TAN INTO LS_TDS_TAN WITH  KEY ORG_ELE = LS_BSEG_K-BUKRS BUKRS = LS_BSEG_K-BUKRS.
3854             IF SY-SUBRC = 0.
3855               GS_FINAL_TDS-DEDUCTOR_TAN = LS_TDS_TAN-TAN.
3856               GS_FINAL_TDS-TANPARA = 'Company Code'.
3857             ENDIF.
3858           ENDIF.
3859
3860           READ TABLE LT_J_1BBRANCH INTO LS_J_1BBRANCH WITH KEY BUKRS = LS_BKPF-BUKRS
3861                                                                BRANCH = LS_BSEG_K-BUPLA BINARY SEARCH.
3862           IF SY-SUBRC = 0.
3863             GS_FINAL_TDS-DEDUCTOR_GSTN = LS_J_1BBRANCH-GSTIN.
3864           ENDIF.
3865
3866           IF LS_BSEG_K-LIFNR IS NOT INITIAL.
3867             READ TABLE LT_LFA1 INTO LS_LFA1 WITH KEY LIFNR = LS_BSEG_K-LIFNR BINARY SEARCH.
3868             IF SY-SUBRC = 0.
3869               GS_FINAL_TDS-DEDUCTEE_GSTN   = LS_LFA1-STCD3.
3870               GS_FINAL_TDS-DEDUCTEE_CODE   = LS_LFA1-LIFNR.
3871
3872               IF LS_LFA1-LAND1 = 'IN'.
3873                 GS_FINAL_TDS-NRINDICATOR = 'N'.
3874                 GS_FINAL_TDS-NON_RES_DECUCTEE = 'Resident'.
3875
3876               ELSE.
3877                 GS_FINAL_TDS-NON_RES_DECUCTEE = 'Non-Resident'.
3878                 GS_FINAL_TDS-NRINDICATOR = 'Y'.
3879               ENDIF.
3880
3881               GS_FINAL_TDS-NAME_OF_DEDUCTEE =  LS_LFA1-NAME1.
3882
3883               READ TABLE LT_T077K TRANSPORTING NO FIELDS WITH  KEY KTOKK = LS_LFA1-KTOKK BINARY SEARCH.
3884               IF SY-SUBRC = 0.
3885                 CLEAR:GS_FINAL_TDS-DEDUCTEE_GSTN,  GS_FINAL_TDS-NAME_OF_DEDUCTEE,
3886                 GS_FINAL_TDS-DEDUCTEE_PAN.
3887
3888                 GS_FINAL_TDS-DEDUCTEE_CODE = ' '.
3889                 READ TABLE LT_BSEC INTO LS_BSEC WITH  KEY BUKRS = LS_BSEG_K-BUKRS
3890                                                           BELNR = LS_BSEG_K-BELNR
3891                                                           GJAHR = LS_BSEG_K-GJAHR BINARY SEARCH.
3892                 IF SY-SUBRC = 0.
3893                   GS_FINAL_TDS-NAME_OF_DEDUCTEE = LS_BSEC-NAME1.
3894                   GS_FINAL_TDS-DEDUCTEE_GSTN = LS_BSEC-STCD3.
3895                   GS_FINAL_TDS-DEDUCTEE_PAN = LS_BSEC-STCD1.
3896                   IF LS_BSEC-LAND1 =  'IN'.
3897                     GS_FINAL_TDS-NRINDICATOR = 'N'.
3898                   ELSE.
3899                     GS_FINAL_TDS-NRINDICATOR = 'Y'.
3900                   ENDIF.
3901                   CLEAR LS_BSEC.
3902                 ENDIF.
3903               ENDIF.
3904             ENDIF.
3905
3906           ELSE.
3907
3908             READ TABLE LT_BSEG_V INTO LS_BSEG_V WITH KEY BUKRS = LS_BSEG_K-BUKRS
3909                                                          BELNR = LS_BSEG_K-BELNR
3910                                                          GJAHR = LS_BSEG_K-GJAHR BINARY SEARCH.
3911             IF SY-SUBRC = 0.
3912               READ TABLE LT_LFA1 INTO LS_LFA1 WITH KEY LIFNR = LS_BSEG_V-LIFNR BINARY SEARCH.
3913               IF SY-SUBRC = 0.
3914                 GS_FINAL_TDS-DEDUCTEE_GSTN   = LS_LFA1-STCD3.
3915                 GS_FINAL_TDS-DEDUCTEE_CODE   = LS_LFA1-LIFNR.
3916
3917                 IF LS_LFA1-LAND1 = 'IN'.
3918                   GS_FINAL_TDS-NON_RES_DECUCTEE = 'Resident'.
3919                   GS_FINAL_TDS-NRINDICATOR = 'N'.
3920
3921                 ELSE.
3922                   GS_FINAL_TDS-NON_RES_DECUCTEE = 'Non-Resident'.
3923                   GS_FINAL_TDS-NRINDICATOR = 'Y'.
3924
3925                 ENDIF.
3926
3927                 GS_FINAL_TDS-NAME_OF_DEDUCTEE = LS_LFA1-NAME1.
3928
3929                 CLEAR:GS_FINAL_TDS-DEDUCTEE_GSTN, GS_FINAL_TDS-NAME_OF_DEDUCTEE,
3930                 GS_FINAL_TDS-DEDUCTEE_PAN.
3931
3932                 READ TABLE LT_T077K TRANSPORTING NO FIELDS WITH  KEY KTOKK = LS_LFA1-KTOKK BINARY SEARCH.
3933                 IF SY-SUBRC = 0.
3934                   GS_FINAL_TDS-DEDUCTEE_CODE = ' '.
3935                   READ TABLE LT_BSEC INTO LS_BSEC WITH  KEY BUKRS = LS_BSEG_K-BUKRS
3936                                                             BELNR = LS_BSEG_K-BELNR
3937                                                             GJAHR = LS_BSEG_K-GJAHR BINARY SEARCH.
3938                   IF SY-SUBRC = 0.
3939                     GS_FINAL_TDS-NAME_OF_DEDUCTEE = LS_BSEC-NAME1.
3940                     GS_FINAL_TDS-DEDUCTEE_GSTN = LS_BSEC-STCD3.
3941                     GS_FINAL_TDS-DEDUCTEE_PAN = LS_BSEC-STCD1.
3942                     IF LS_BSEC-LAND1 =  'IN'.
3943                       GS_FINAL_TDS-NRINDICATOR = 'N'.
3944                     ELSE.
3945                       GS_FINAL_TDS-NRINDICATOR = 'Y'.
3946                     ENDIF.
3947                     CLEAR LS_BSEC.
3948                   ENDIF.
3949                 ENDIF.
3950               ENDIF.
3951
3952               GS_FINAL_TDS-SECCO         = LS_BSEG_V-SECCO.
3953             ENDIF.
3954           ENDIF.
3955
3956           READ TABLE LT_ADRC INTO LS_ADRC WITH KEY ADDRNUMBER = LS_LFA1-ADRNR BINARY SEARCH.
3957           IF SY-SUBRC = 0.
3958             CONCATENATE LS_ADRC-STREET LS_ADRC-STR_SUPPL1  LS_ADRC-STR_SUPPL2 LS_ADRC-STR_SUPPL3 LS_ADRC-POST_CODE2
3959                         LS_ADRC-CITY1 LS_ADRC-CITY2 LS_ADRC-REGION  INTO GS_FINAL_TDS-DEDUCTEE_ADD SEPARATED BY ','.
3960           ENDIF.
3961
3962           READ TABLE LT_SKAT INTO LS_SKAT WITH KEY SAKNR = LS_BSEG-HKONT BINARY SEARCH.
3963           IF SY-SUBRC = 0.
3964             GS_FINAL_TDS-GL_ACC_CODE = LS_SKAT-SAKNR.
3965             GS_FINAL_TDS-GL_ACC_NAME = LS_SKAT-TXT50.
3966             GS_FINAL_TDS-SERVICE_DES_GLTXT = LS_SKAT-TXT20.
3967           ENDIF.
3968
3969           IF EXP_CHK = 'X'.
3970             IF LS_BSEG-KTOSL IN LR_KTOSL.
3971               READ TABLE LT_EKKN INTO LS_EKKN WITH  KEY EBELN = LS_BSEG-EBELN
3972                                                         EBELP = LS_BSEG-EBELP
3973                                                         ZEKKN = LS_BSEG-ZEKKN BINARY SEARCH.
3974               IF SY-SUBRC = 0.
3975                 READ TABLE LT_SKAT INTO LS_SKAT WITH KEY SAKNR = LS_EKKN-SAKTO BINARY SEARCH.
3976                 IF SY-SUBRC = 0.
3977                   GS_FINAL_TDS-GL_ACC_CODE = LS_SKAT-SAKNR.
3978                   GS_FINAL_TDS-GL_ACC_NAME = LS_SKAT-TXT50.
3979                 ENDIF.
3980               ELSE.
3981                 READ TABLE LT_EKPO1 INTO LS_EKPO1 WITH KEY EBELN = LS_BSEG-EBELN
3982                                                            EBELP = LS_BSEG-EBELP BINARY SEARCH.
3983                 IF SY-SUBRC = 0.
3984                   READ TABLE LT_T001W INTO LS_T001W WITH  KEY WERKS = LS_EKPO1-WERKS.
3985                   IF SY-SUBRC  = 0.
3986                     READ TABLE LT_MBEW INTO LS_MBEW WITH  KEY MATNR = LS_EKPO1-MATNR
3987                                                               BWKEY = LS_T001W-BWKEY.
3988                     IF SY-SUBRC = 0.
3989                       READ TABLE LT_T030 INTO LS_T030 WITH KEY KTOPL = LS_T001-KTOPL
3990                                                                BKLAS = LS_MBEW-BKLAS.
3991                       IF SY-SUBRC = 0.
3992                         READ TABLE LT_SKAT INTO LS_SKAT WITH KEY SAKNR = LS_T030-KONTS BINARY SEARCH.
3993                         IF SY-SUBRC = 0.
3994                           GS_FINAL_TDS-GL_ACC_CODE = LS_SKAT-SAKNR.
3995                           GS_FINAL_TDS-GL_ACC_NAME = LS_SKAT-TXT50.
3996                         ENDIF.
3997                       ENDIF.
3998                     ENDIF.
3999                   ENDIF.
4000                 ENDIF.
4001               ENDIF.
4002
4003             ENDIF.
4004           ENDIF.
4005
4006           READ TABLE LT_EKPO INTO LS_EKPO WITH KEY EBELN = LS_BSEG-EBELN BINARY SEARCH.
4007           IF SY-SUBRC = 0.
4008             GS_FINAL_TDS-PO_NUMBER        = LS_EKPO-EBELN.
4009             CONCATENATE LS_EKPO-BEDAT+6(2) LS_EKPO-BEDAT+4(2)
4010             LS_EKPO-BEDAT+0(4) INTO GS_FINAL_TDS-PO_DATE SEPARATED BY '.'.
4011
4012             GS_FINAL_TDS-SERVICE_DES_PO   = LS_EKPO-TXZ01.
4013             GS_FINAL_TDS-PO_DESC          = LS_EKPO-TXZ01.
4014
4015             IF  GS_FINAL_TDS-HSN_SAC_CODE IS INITIAL.
4016               GS_FINAL_TDS-HSN_SAC_CODE = LS_EKPO-J_1BNBM.
4017             ENDIF.
4018           ENDIF.
4019
4020           IF LS_EKPO-WEBRE = SPACE .
4021             IF LS_EKPO-PSTYP = '9'.
4022               GS_FINAL_TDS-TRANS_TYPE = 'C1'.
4023             ELSE.
4024               GS_FINAL_TDS-TRANS_TYPE = 'C2'.
4025             ENDIF.
4026           ELSEIF LS_EKPO-WEBRE = 'X'.
4027             IF LS_EKPO-PSTYP = '9'.
4028               GS_FINAL_TDS-TRANS_TYPE = 'A1'.
4029             ELSE.
4030               GS_FINAL_TDS-TRANS_TYPE = 'A2'.
4031             ENDIF.
4032           ENDIF.
4033
4034           IF LS_EKPO-WEPOS = SPACE AND LS_EKPO-WEBRE = SPACE .
4035             GS_FINAL_TDS-TRANS_TYPE = 'B'.
4036           ENDIF.
4037
4038           GS_FINAL_TDS-ITEM_CAT = LS_EKPO-PSTYP.
4039         ENDIF.
4040       ENDIF.
4041       IF LS_BSEG_K-BLART = 'RE' OR LS_BSEG_K-BLART = 'KS' .
4042         GS_FINAL_TDS-TRANS_TYPE = 'F'.
4043       ENDIF.
4044
4045
4046       READ TABLE LT_ASMD INTO LS_ASMD WITH KEY TAXTARIFFCODE = LS_BSEG-HSN_SAC BINARY SEARCH.
4047       IF SY-SUBRC = 0.
4048         READ TABLE LT_ASMDT INTO LS_ASMDT WITH KEY ASNUM = LS_ASMD-ASNUM BINARY SEARCH.
4049         IF SY-SUBRC = 0.
4050           GS_FINAL_TDS-SAC_DEC = LS_ASMDT-ASKTX.
4051
4052         ENDIF.
4053       ENDIF.
4054       IF GS_FINAL_TDS-SAC_DEC IS INITIAL.
4055         READ TABLE LT_T604N INTO LS_T604N WITH KEY STEUC = LS_BSEG-HSN_SAC BINARY SEARCH.
4056         IF SY-SUBRC  = 0.
4057           GS_FINAL_TDS-SAC_DEC = LS_T604N-TEXT1.
4058         ENDIF.
4059       ENDIF.
4060
4061       IF GS_FINAL_TDS-HSN_SAC_DES IS INITIAL.
4062         READ TABLE LT_T604N INTO LS_T604N WITH KEY STEUC = LS_BSEG-HSN_SAC BINARY SEARCH.
4063         IF SY-SUBRC  = 0.
4064           GS_FINAL_TDS-HSN_SAC_DES = LS_T604N-TEXT1.
4065         ENDIF.
4066       ELSE.
4067         READ TABLE LT_T604N INTO LS_T604N WITH KEY STEUC = GS_FINAL_TDS-HSN_SAC_DES BINARY SEARCH.
4068         IF SY-SUBRC  = 0.
4069           GS_FINAL_TDS-HSN_SAC_DES = LS_T604N-TEXT1.
4070         ENDIF.
4071
4072       ENDIF.
4073
4074       IF GS_FINAL_TDS-HSN_SAC_CODE IS INITIAL AND GS_FINAL_TDS-SAC_DEC IS INITIAL.
4075         READ TABLE LT_EKPO INTO LS_EKPO WITH KEY EBELN = LS_BSEG-EBELN
4076                                                  EBELP = LS_BSEG-EBELP BINARY SEARCH.
4077         IF SY-SUBRC = 0 AND GS_FINAL_TDS-HSN_SAC_CODE IS INITIAL.
4078           GS_FINAL_TDS-HSN_SAC_CODE = LS_EKPO-J_1BNBM.
4079         ENDIF.
4080         CLEAR LV_WERKS.
4081         LV_WERKS = LS_EKPO-WERKS.
4082         READ TABLE LT_MARC INTO LS_MARC WITH KEY MATNR = LS_EKPO-MATNR
4083                                                  WERKS = LV_WERKS BINARY SEARCH.
4084         IF SY-SUBRC  = 0.
4085           IF GS_FINAL_TDS-HSN_SAC_CODE IS NOT INITIAL.
4086             LS_MARC-STEUC = GS_FINAL_TDS-HSN_SAC_CODE.
4087           ENDIF.
4088
4089         ENDIF.
4090         IF GS_FINAL_TDS-SAC_DEC IS INITIAL.
4091           READ TABLE LT_T604N INTO LS_T604N WITH KEY STEUC = GS_FINAL_TDS-HSN_SAC_CODE BINARY SEARCH.
4092           IF SY-SUBRC  = 0.
4093             GS_FINAL_TDS-SAC_DEC = LS_T604N-TEXT1.
4094           ENDIF.
4095         ENDIF.
4096
4097         IF GS_FINAL_TDS-HSN_SAC_DES IS INITIAL.
4098           READ TABLE LT_T604N INTO LS_T604N WITH KEY STEUC = GS_FINAL_TDS-HSN_SAC_CODE BINARY SEARCH.
4099           IF SY-SUBRC  = 0.
4100             GS_FINAL_TDS-HSN_SAC_DES = LS_T604N-TEXT1.
4101           ENDIF.
4102         ENDIF.
4103
4104       ENDIF.
4105       IF GS_FINAL_TDS-HSN_SAC_CODE IS INITIAL.
4106         IF LS_EKPO-J_1BNBM IS NOT INITIAL.
4107           READ TABLE LT_ASMD INTO LS_ASMD WITH KEY TAXTARIFFCODE =  LS_EKPO-J_1BNBM BINARY SEARCH.
4108           IF SY-SUBRC = 0.
4109             IF  GS_FINAL_TDS-HSN_SAC_CODE IS INITIAL.
4110               GS_FINAL_TDS-HSN_SAC_CODE = LS_ASMD-TAXTARIFFCODE.
4111             ENDIF.
4112             READ TABLE LT_ASMDT INTO LS_ASMDT WITH KEY ASNUM = LS_ASMD-ASNUM BINARY SEARCH.
4113             IF SY-SUBRC = 0.
4114               GS_FINAL_TDS-SAC_DEC = LS_ASMDT-ASKTX.
4115             ENDIF.
4116           ENDIF.
4117         ENDIF.
4118       ENDIF.
4119
4120       IF GS_FINAL_TDS-SAC_DEC IS INITIAL.
4121         READ TABLE LT_T604N INTO LS_T604N WITH KEY STEUC = GS_FINAL_TDS-HSN_SAC_CODE  BINARY SEARCH.
4122         IF SY-SUBRC  = 0.
4123           GS_FINAL_TDS-SAC_DEC = LS_T604N-TEXT1.
4124         ENDIF.
4125       ENDIF.
4126
4127       IF GS_FINAL_TDS-HSN_SAC_DES IS INITIAL.
4128         READ TABLE LT_T604N INTO LS_T604N WITH KEY STEUC = GS_FINAL_TDS-HSN_SAC_CODE  BINARY SEARCH.
4129         IF SY-SUBRC  = 0.
4130           GS_FINAL_TDS-HSN_SAC_DES = LS_T604N-TEXT1.
4131         ENDIF.
4132       ENDIF.
4133
4134       READ TABLE LT_BSEG INTO LS_BSEG_Q WITH KEY BELNR = LS_BSEG-BELNR
4135                                                 BUKRS = LS_BSEG-BUKRS
4136                                                 GJAHR = LS_BSEG-GJAHR
4137                                                 KTOSL = 'WRX'
4138                                                 BUZID = 'W'
4139                                                 BUZEI = LS_BSEG-BUZEI.
4140       IF SY-SUBRC = 0 AND LS_BSEG_Q-XREF3 IS NOT INITIAL.
4141
4142       ELSEIF LS_BSEG_Q-EBELN IS NOT INITIAL.
4143         READ TABLE LT_BSEG INTO LS_BSEG_Q WITH KEY BUKRS = LS_BSEG_Q-BUKRS
4144                                                    GJAHR = LS_BSEG_Q-GJAHR
4145                                                    EBELN = LS_BSEG_Q-EBELN
4146                                                    EBELP = LS_BSEG_Q-EBELP
4147                                                    KTOSL = 'WRX'
4148                                                    BUZID = 'W'
4149                                                    VORGN = 'RMRP'.
4150       ENDIF.
4151
4152   *MIGO number new logic begin
4153       READ TABLE LT_BSEG INTO LS_BSEG_Q WITH KEY BELNR = LS_BSEG-BELNR
4154                                                 BUKRS = LS_BSEG-BUKRS
4155                                                 GJAHR = LS_BSEG-GJAHR
4156                                                  BUZEI = LS_BSEG-BUZEI
4157                                                 KTOSL = 'WRX'
4158                                                 BUZID = 'W'.
4159
4160       IF SY-SUBRC = 0 AND LS_BSEG_Q-XREF3 IS NOT INITIAL.
4161
4162       ELSEIF LS_BSEG_Q-EBELN IS NOT INITIAL.
4163         READ TABLE LT_BSEG INTO LS_BSEG_Q WITH KEY BUKRS = LS_BSEG_Q-BUKRS
4164                                                    GJAHR = LS_BSEG_Q-GJAHR
4165                                                    EBELN = LS_BSEG_Q-EBELN
4166                                                    EBELP = LS_BSEG_Q-EBELP
4167                                                    KTOSL = 'WRX'
4168                                                    BUZID = 'W'
4169                                                    VORGN = 'RMWE'.
4170
4171       ENDIF.
4172
4173   " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
4174   *    IF ( LS_BKPF-TCODE = 'MR8M' OR LS_BKPF-TCODE = 'MBST')
4175       IF ( LS_BKPF-TCODE = 'MR8M' OR LS_BKPF-TCODE = 'MBST') "#EC CI_USAGE_OK[1804812]
4176   " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
4177         AND (  LS_BKPF-BLART = 'RE' OR LS_BKPF-BLART = 'KS').
4178         LV_INV_AMOUNT = LS_BSEG_K-DMBTR.
4179       ELSE.
4180         LV_INV_AMOUNT = LS_BSEG_K-DMBTR.
4181       ENDIF.
4182
4183       IF  ( LS_BKPF-BLART = 'RE' OR LS_BKPF-BLART = 'KS' )
4184             AND  ( LS_BSEG-KOART = 'S' AND LS_BSEG-SHKZG = 'S' AND LS_BSEG-XNEGP = 'X' ).
4185         LV_INV_AMOUNT = LS_BSEG-DMBTR .
4186       ENDIF.
4187
4188       IF LV_INV_AMOUNT IS NOT INITIAL.
4189         GS_FINAL_TDS-AMOUNT = LV_INV_AMOUNT.
4190         CLEAR : LV_INV_AMOUNT.
4191       ENDIF.
4192
4193
4194       GS_FINAL_TDS-SOURCE_ID  = SY-MANDT.
4195       GS_FINAL_TDS-SOURCE_FIL = 'TDS_Invoice CSV file'.
4196
4197       IF S_DATE[] IS NOT INITIAL OR S_CDATE[] IS NOT INITIAL.
4198         IF S_CDATE[] IS  INITIAL.
4199           IF S_DATE-LOW IS NOT INITIAL AND S_DATE-HIGH IS NOT INITIAL.
4200             CONCATENATE  'INV_' GS_FINAL_TDS-DEDUCTOR_PAN '_' GS_FINAL_TDS-DEDUCTOR_TAN '_'
4201                                 S_DATE-LOW+6(2) '-' S_DATE-LOW+4(2) '-' S_DATE-LOW+0(4) '_'
4202                                 S_DATE-HIGH+6(2) '-' S_DATE-HIGH+4(2) '-' S_DATE-HIGH+0(4)
4203                                 INTO GS_FINAL_TDS-SOURCE_FIL.
4204
4205           ELSEIF S_DATE-LOW IS NOT INITIAL AND S_DATE-HIGH IS  INITIAL.
4206             CONCATENATE  'INV_' GS_FINAL_TDS-DEDUCTOR_PAN '_' GS_FINAL_TDS-DEDUCTOR_TAN '_'
4207                                 S_DATE-LOW+6(2) '-' S_DATE-LOW+4(2) '-' S_DATE-LOW+0(4) '_'
4208                                 S_DATE-LOW+6(2) '-' S_DATE-LOW+4(2) '-' S_DATE-LOW+0(4)
4209                                 INTO GS_FINAL_TDS-SOURCE_FIL.
4210           ENDIF.
4211         ELSE.
4212           IF S_CDATE-LOW IS NOT INITIAL AND S_CDATE-HIGH IS NOT INITIAL.
4213             CONCATENATE  'INV_' GS_FINAL_TDS-DEDUCTOR_PAN '_' GS_FINAL_TDS-DEDUCTOR_TAN '_'
4214                                 S_CDATE-LOW+6(2) '-' S_CDATE-LOW+4(2) '-' S_CDATE-LOW+0(4) '_'
4215                                 S_CDATE-HIGH+6(2) '-' S_CDATE-HIGH+4(2) '-' S_CDATE-HIGH+0(4)
4216                                  INTO GS_FINAL_TDS-SOURCE_FIL.
4217           ELSEIF S_CDATE-LOW IS NOT INITIAL AND S_CDATE-HIGH IS  INITIAL.
4218             CONCATENATE  'INV_' GS_FINAL_TDS-DEDUCTOR_PAN '_' GS_FINAL_TDS-DEDUCTOR_TAN '_'
4219                                 S_CDATE-LOW+6(2) '-' S_CDATE-LOW+4(2) '-' S_CDATE-LOW+0(4) '_'
4220                                 S_CDATE-LOW+6(2) '-' S_CDATE-LOW+4(2) '-' S_CDATE-LOW+0(4) INTO GS_FINAL_TDS-SOURCE_FIL.
4221           ENDIF.
4222
4223         ENDIF.
4224       ELSE.
4225         CONCATENATE  'INV_' GS_FINAL_TDS-DEDUCTOR_PAN '_'
4226                             GS_FINAL_TDS-DEDUCTOR_TAN '_' GV_LOW '_' GV_HIGH INTO GS_FINAL_TDS-SOURCE_FIL.
4227       ENDIF.
4228
4229       CLEAR : LV_CODE,LV_REGIO.
4230       LV_REGIO = GS_FINAL_TDS-POS.
4231       CONDENSE LV_REGIO.
4232
4233   *    READ TABLE lt_statecode INTO ls_statecode WITH KEY regio = lv_regio BINARY SEARCH.
4234   *    IF sy-subrc  = 0.
4235   *      gs_final_tds-pos = ls_statecode-bezei.
4236   *    ENDIF.
4237
4238       IF LS_BKPF-BLART = 'RE' OR LS_BKPF-BLART = 'RN' OR LS_BKPF-BLART = 'KR' OR LS_BKPF-BLART = 'KS'.
4239         IF GS_FINAL_TDS-TAXABLEVALUE IS NOT INITIAL
4240           AND LS_BSEG_K-SKFBT IS NOT INITIAL AND GS_FINAL_TDS-TDS_RATE IS INITIAL .
4241           GS_FINAL_TDS-TDS_AMOUNT = ( GS_FINAL_TDS-TAXABLEVALUE / LS_BSEG_K-SKFBT *  LV_TDS_AMT ).
4242         ENDIF.
4243
4244       ENDIF.
4245
4246       IF LS_BSEG_K-SHKZG = 'H' AND GS_FINAL_TDS-TAXABLEVALUE LT 0.
4247         GS_FINAL_TDS-TAXABLEVALUE = GS_FINAL_TDS-TAXABLEVALUE * 1.
4248       ENDIF.
4249       IF LS_BSEG_K-SHKZG = 'H' AND GS_FINAL_TDS-AMOUNT LT 0.
4250         GS_FINAL_TDS-AMOUNT = GS_FINAL_TDS-AMOUNT * 1.  "-1.
4251       ENDIF.
4252
4253       IF LS_BSEG_K-SHKZG = 'S' AND GS_FINAL_TDS-TAXABLEVALUE GT 0.
4254         GS_FINAL_TDS-TAXABLEVALUE = GS_FINAL_TDS-TAXABLEVALUE * 1.
4255       ENDIF.
4256
4257       IF LS_BSEG_K-SHKZG = 'S' AND GS_FINAL_TDS-AMOUNT GT 0.
4258         GS_FINAL_TDS-AMOUNT = GS_FINAL_TDS-AMOUNT * 1.  "-1.
4259       ENDIF.
4260
4261       IF LS_BSEG_K-SHKZG = 'H' AND GS_FINAL_TDS-TDS_AMOUNT LT 0.
4262         GS_FINAL_TDS-TDS_AMOUNT = GS_FINAL_TDS-TDS_AMOUNT * 1.
4263       ENDIF.
4264       IF LS_BSEG_K-SHKZG = 'S' AND GS_FINAL_TDS-TDS_AMOUNT GT 0.
4265         GS_FINAL_TDS-TDS_AMOUNT = GS_FINAL_TDS-TDS_AMOUNT * 1.
4266       ENDIF.
4267
4268       IF LS_BSEG_K-WAERS = 'INR'.
4269         GS_FINAL_TDS-AMOUNT = 0.
4270         GS_FINAL_TDS-EXCH_RATE =  0.
4271         GS_FINAL_TDS-CURRENCY = ' '.
4272       ENDIF.
4273
4274
4275       READ TABLE LT_BSEG_A INTO LS_BSEG_A WITH KEY BELNR = LS_BSEG-BELNR
4276                                                           BUKRS = LS_BSEG-BUKRS
4277                                                           GJAHR = LS_BSEG-GJAHR
4278                                                           BUZEI = LS_BSEG-BUZEI.
4279       IF LS_BSEG_A-KOART <> 'K'.
4280         GS_FINAL_TDS-BUSINESS_AREA = LS_BSEG_A-GSBER.
4281       ENDIF.
4282
4283       IF ( LS_BSEG_A-BUZID = 'W' AND LS_BSEG_A-KTOSL = 'WRX' )
4284         OR ( LS_BSEG_A-BUZID = 'S' AND LS_BSEG_A-KTOSL = 'KBS' )
4285         OR  ( LS_BSEG_A-BUZID = 'S' AND LS_BSEG_A-KTOSL = 'ANL' ).
4286         GS_FINAL_TDS-XREF3 = LS_BSEG_A-XREF3.
4287       ENDIF.
4288
4289       READ TABLE LT_RSEG INTO LS_RSEG WITH KEY BELNR = LS_BSEG-AWKEY+0(10)
4290                                                GJAHR = LS_BSEG-AWKEY+10(4)
4291                                                EBELN = LS_BSEG-EBELN
4292                                                EBELP = LS_BSEG-EBELP
4293                                                WRBTR = LS_BSEG-DMBTR BINARY SEARCH.
4294       IF SY-SUBRC = 0.
4295         GS_FINAL_TDS-CIF_VALUE  = LS_RSEG-CUSTOMS_VAL.
4296         CLEAR LS_RSEG.
4297       ENDIF.
4298
4299
4300       GS_FINAL_TDS-SOURCE_ID  = SY-MANDT.
4301       GS_FINAL_TDS-SOURCE_FIL = 'TDS_Invoice CSV file'.
4302
4303       SHIFT GS_FINAL_TDS-ORG_DOC_NUM   LEFT DELETING LEADING '0'.
4304       SHIFT GS_FINAL_TDS-DOCUMENT_NUMB LEFT DELETING LEADING '0'.
4305       SHIFT GS_FINAL_TDS-GL_ACC_CODE   LEFT DELETING LEADING '0'.
4306       SHIFT GS_FINAL_TDS-DEDUCTEE_CODE LEFT DELETING LEADING '0'.
4307       SHIFT GS_FINAL_TDS-ERP_NUM       LEFT DELETING LEADING '0'.
4308       SHIFT GS_FINAL_TDS-PO_LINE_ITEM  LEFT DELETING LEADING '0'.
4309       SHIFT GS_FINAL_TDS-ACCOUNT_SEQ   LEFT DELETING LEADING '0'.
4310   *    SHIFT GS_FINAL_TDS-ITEM_CODE     LEFT DELETING LEADING '0'.  ""AM-30-04-24
4311       SHIFT GS_FINAL_TDS-PO_NUMBER     LEFT DELETING LEADING '0'.
4312
4313       IF GS_FINAL_TDS-DOCUMENT_NUMB IS NOT INITIAL.
4314         IF GS_FINAL_TDS-TAXABLEVALUE IS INITIAL.
4315
4316           CLEAR: GS_FINAL_TDS-CGSTRATE, GS_FINAL_TDS-CGSTAMOUNT,
4317                  GS_FINAL_TDS-SGSTRATE, GS_FINAL_TDS-SGSTAMOUNT,
4318                  GS_FINAL_TDS-IGSTRATE, GS_FINAL_TDS-IGSTAMOUNT,
4319                  GS_FINAL_TDS-CESSRATE, GS_FINAL_TDS-CESSAMOUNT.
4320
4321         ENDIF.
4322
4323         GS_FINAL_TDS-LINENUMBER = |{ GS_FINAL_TDS-LINENUMBER ALPHA = OUT }|.
4324         APPEND GS_FINAL_TDS TO GT_FINAL_TDS.
4325
4326       ENDIF.
4327
4328       CLEAR: GS_FINAL_TDS, LS_BKPF, LS_BSEG, LS_BSET, LS_LFA1, LS_J_1IMOVEND, LS_MARC, LS_T604N, LS_ADRC,
4329              LS_SKAT, LS_J_1I_SECCO_CIT, LS_J_1BBRANCH, LS_T001Z, LS_T059Z, LS_ASMD, LS_ASMDT,
4330              LS_BSEG_K, LS_BSEG_V, LS_WITH_ITEM, LS_T059Z, LS_STATECODE, LS_BSEG_P, LS_BSEG_Q,
4331              LS_EKPO,LS_BSEG_A, LS_EKPO.
4332     ENDLOOP.
4333
4334     IF S_LIFNR IS NOT INITIAL.
4335       DELETE GT_FINAL_TDS WHERE DEDUCTEE_CODE NOT IN S_LIFNR.
4336     ENDIF.
4337
4338     SORT GT_FINAL_TDS BY ERP_NUM.
4339     DELETE ADJACENT DUPLICATES FROM GT_FINAL_TDS.
4340
4341     SORT GT_FINAL_TDS BY COMPANY_CODE ERP_NUM LINENUMBER .
4342
4343
4344     GT_FINAL_TDS_AMT[]      = GT_FINAL_TDS[].
4345     GT_FINAL_TDS_AMT_TEMP[] = GT_FINAL_TDS[].
4346
4347     DELETE ADJACENT DUPLICATES FROM GT_FINAL_TDS_AMT_TEMP COMPARING COMPANY_CODE ERP_NUM .
4348
4349     LOOP AT GT_FINAL_TDS_AMT_TEMP INTO GS_FINAL_TDS_AMT_TEMP.
4350       READ TABLE GT_FINAL_TDS INTO GS_FINAL_TDS WITH  KEY COMPANY_CODE = GS_FINAL_TDS_AMT_TEMP-COMPANY_CODE
4351                                                                ERP_NUM = GS_FINAL_TDS_AMT_TEMP-ERP_NUM.
4352       IF SY-SUBRC = 0.
4353         LV_INDEX = SY-TABIX.
4354
4355         LOOP AT GT_FINAL_TDS INTO GS_FINAL_TDS FROM LV_INDEX .
4356           IF GS_FINAL_TDS-ERP_NUM <> GS_FINAL_TDS_AMT_TEMP-ERP_NUM
4357             OR GS_FINAL_TDS_AMT_TEMP-COMPANY_CODE <> GS_FINAL_TDS-COMPANY_CODE.
4358             EXIT.
4359           ENDIF.
4360
4361           IF GS_FINAL_TDS-FLAG = 'X'.
4362             LV_COUNT_T1 = LV_COUNT_T1 + 1.
4363           ENDIF.
4364
4365           MOVE-CORRESPONDING GS_FINAL_TDS TO GS_FINAL_TDS_AMT1.
4366           CLEAR:LV_COUNT_TEMP.
4367
4368           LOOP AT LT_WITH_ITEM_TDS INTO LS_WITH_ITEM_TDS WHERE BUKRS = GS_FINAL_TDS-COMPANY_CODE
4369                                                            AND BELNR = GS_FINAL_TDS-BELNR
4370                                                            AND GJAHR = GS_FINAL_TDS-GJAHR.
4371             LV_COUNT_TEMP = LV_COUNT_TEMP + 1.
4372             IF LV_COUNT_TEMP = 2.
4373               EXIT.
4374             ENDIF.
4375           ENDLOOP.
4376
4377           IF LV_COUNT_TEMP = 1.
4378             IF GS_FINAL_TDS-FLAG = 'X'.
4379               CLEAR:LV_VALUE, LV_VALUE1, LV_COUNT_T, LV_VALUE3.
4380
4381               LOOP AT GT_FINAL_TDS_AMT INTO GS_FINAL_TDS_AMT WHERE COMPANY_CODE = GS_FINAL_TDS-COMPANY_CODE
4382                                                                AND      ERP_NUM = GS_FINAL_TDS-ERP_NUM
4383                                                                AND        GJAHR = GS_FINAL_TDS-GJAHR
4384                                                                AND         FLAG = 'X'.
4385                 LV_COUNT_T = LV_COUNT_T + 1.
4386                 LV_VALUE = LV_VALUE + GS_FINAL_TDS_AMT-TAXABLEVALUE.
4387               ENDLOOP.
4388
4389               IF GS_FINAL_TDS-TAXABLEVALUE > 0.
4390                 IF LS_WITH_ITEM_TDS-WT_QBSHH LT 0.
4391                   LS_WITH_ITEM_TDS-WT_QBSHH = LS_WITH_ITEM_TDS-WT_QBSHH * -1.
4392                 ENDIF.
4393
4394                 IF LS_WITH_ITEM_TDS-WT_QSSHH LT 0.
4395                   LS_WITH_ITEM_TDS-WT_QSSHH  = LS_WITH_ITEM_TDS-WT_QSSHH *  -1.
4396                 ENDIF.
4397
4398                 LV_VALUE1 = ( GS_FINAL_TDS-TAXABLEVALUE /  LV_VALUE ) * LS_WITH_ITEM_TDS-WT_QBSHH.
4399                 LV_VALUE3 = ( GS_FINAL_TDS-TAXABLEVALUE /  LV_VALUE ) * LS_WITH_ITEM_TDS-WT_QSSHH.
4400
4401                 IF LV_COUNT_T <> LV_COUNT_T1.
4402                   GS_FINAL_TDS_AMT1-TDS_AMOUNT = LV_VALUE1 .
4403                   GS_FINAL_TDS_AMT1-TDS_BASE_VAL = LV_VALUE3 .
4404                 ELSE.
4405                   GS_FINAL_TDS_AMT1-TDS_AMOUNT = LS_WITH_ITEM_TDS-WT_QBSHH - LV_VALUE_TEMP.
4406                   GS_FINAL_TDS_AMT1-TDS_BASE_VAL = LS_WITH_ITEM_TDS-WT_QSSHH - LV_VALUE_TEMP1.
4407                 ENDIF.
4408
4409                 LV_VALUE_TEMP = LV_VALUE_TEMP + GS_FINAL_TDS_AMT1-TDS_AMOUNT.
4410                 LV_VALUE_TEMP1 = LV_VALUE_TEMP1 + GS_FINAL_TDS_AMT1-TDS_BASE_VAL.
4411
4412                 GS_FINAL_TDS_AMT1-TDS_RATE     = LS_WITH_ITEM_TDS-QSATZ.
4413
4414                 GS_FINAL_TDS_AMT1-TDS_TAX     = LS_WITH_ITEM_TDS-WITHT.
4415                 GS_FINAL_TDS_AMT1-EXEMP_RATE  = LS_WITH_ITEM_TDS-WT_QSZRT.
4416                 GS_FINAL_TDS_AMT1-EXEMP_NUM   = LS_WITH_ITEM_TDS-WT_WTEXMN.
4417
4418                 READ TABLE LT_T059Z INTO LS_T059Z WITH KEY WITHT     = LS_WITH_ITEM_TDS-WITHT
4419                                                            WT_WITHCD = LS_WITH_ITEM_TDS-WT_WITHCD BINARY SEARCH.
4420                 IF SY-SUBRC = 0.
4421                   GS_FINAL_TDS_AMT1-USER1     = LS_T059Z-QSCOD.
4422                   IF GS_FINAL_TDS_AMT1-TDS_AMOUNT > 0  AND GS_FINAL_TDS_AMT1-TDS_RATE IS INITIAL.
4423                     GS_FINAL_TDS_AMT1-TDS_RATE  = LS_T059Z-QSATZ.
4424                   ENDIF.
4425                 ENDIF.
4426
4427
4428                 IF LS_WITH_ITEM_TDS-WITHT IS NOT INITIAL OR LS_WITH_ITEM_TDS-WT_WITHCD IS NOT INITIAL.
4429                   READ TABLE LT_TDS_SEC INTO LS_TDS_SEC WITH KEY WITHT     = LS_WITH_ITEM_TDS-WITHT
4430                                                                  WT_WITHCD = LS_WITH_ITEM_TDS-WT_WITHCD
4431                                                                  APPL = 'X' BINARY SEARCH.
4432                   IF SY-SUBRC EQ 0.
4433                     GS_FINAL_TDS_AMT1-TDS_SECTION = LS_TDS_SEC-QSCOD.
4434                   ELSE.
4435                     READ TABLE LT_TDS_SEC INTO LS_TDS_SEC WITH KEY WITHT = LS_WITH_ITEM_TDS-WITHT
4436                                                                     APPL = 'X'.
4437                     IF SY-SUBRC EQ 0.
4438                       GS_FINAL_TDS_AMT1-TDS_SECTION = LS_TDS_SEC-QSCOD.
4439                     ENDIF.
4440                   ENDIF.
4441                 ENDIF.
4442
4443                 GS_FINAL_TDS_AMT1-TDS_TAX_CODE_ERP = LS_WITH_ITEM_TDS-WT_WITHCD.
4444                 IF LS_WITH_ITEM_TDS-WT_GRUWTPD = 'X'.
4445                   GS_FINAL_TDS_AMT1-GROSSUPINDICATOR = 'G'.
4446                 ENDIF.
4447                 IF LS_WITH_ITEM_TDS-WT_OPOWTPD = 'X'.
4448                   GS_FINAL_TDS_AMT1-GROSSUPINDICATOR = 'O'.
4449                 ENDIF.
4450                 IF LS_WITH_ITEM_TDS-WT_OPOWTPD = ' ' AND LS_WITH_ITEM_TDS-WT_GRUWTPD = ' '.
4451                   GS_FINAL_TDS_AMT1-GROSSUPINDICATOR = 'N'.
4452                 ENDIF.
4453               ENDIF.
4454             ELSE.
4455               MOVE-CORRESPONDING GS_FINAL_TDS TO GS_FINAL_TDS_AMT1.
4456
4457               CLEAR:GS_FINAL_TDS_AMT1-GROSSUPINDICATOR, GS_FINAL_TDS_AMT1-TDS_SECTION,
4458                GS_FINAL_TDS_AMT1-TDS_TAX_CODE_ERP , GS_FINAL_TDS_AMT1-TDS_TAX,GS_FINAL_TDS_AMT1-USER_1,
4459               GS_FINAL_TDS_AMT1-TDS_RATE, GS_FINAL_TDS_AMT1-TDS_AMOUNT,
4460               GS_FINAL_TDS_AMT1-TDS_BASE_VAL, LS_WITH_ITEM_TDS-WT_QSZRT.
4461             ENDIF.
4462           ELSE.
4463             MOVE-CORRESPONDING GS_FINAL_TDS TO GS_FINAL_TDS_AMT1.
4464           ENDIF.
4465           GS_FINAL_TDS_AMT1-LINENUMBER = |{ GS_FINAL_TDS_AMT1-LINENUMBER ALPHA = OUT }|.
4466           APPEND GS_FINAL_TDS_AMT1 TO GT_FINAL_TDS_AMT1.
4467         ENDLOOP.
4468         CLEAR:LV_VALUE_TEMP, LV_VALUE_TEMP1, LV_COUNT_T1, LV_COUNT_T,
4469               LV_VALUE1, LV_VALUE, LV_INDEX, LS_EKPO.
4470       ENDIF.
4471     ENDLOOP.
4472
4473     GT_FINAL_TDS[] = GT_FINAL_TDS_AMT1[].
4474
4475     CLEAR:GT_FINAL_TDS_AMT1[].
4476     SORT GT_FINAL_TDS BY COMPANY_CODE ERP_NUM LINENUMBER.
4477
4478     GT_FINAL_TDS_AMT[]      = GT_FINAL_TDS[].
4479     GT_FINAL_TDS_AMT_TEMP[] = GT_FINAL_TDS[].
4480
4481     DELETE ADJACENT DUPLICATES FROM GT_FINAL_TDS_AMT_TEMP COMPARING COMPANY_CODE ERP_NUM.
4482
4483     LOOP AT GT_FINAL_TDS_AMT_TEMP INTO GS_FINAL_TDS_AMT_TEMP.
4484       CLEAR:LV_COUNT_T1.
4485       READ TABLE GT_FINAL_TDS INTO GS_FINAL_TDS WITH KEY COMPANY_CODE = GS_FINAL_TDS_AMT_TEMP-COMPANY_CODE
4486                                                               ERP_NUM = GS_FINAL_TDS_AMT_TEMP-ERP_NUM.
4487       IF SY-SUBRC = 0.
4488         LV_INDEX = SY-TABIX.
4489
4490         LOOP AT GT_FINAL_TDS INTO GS_FINAL_TDS FROM LV_INDEX .
4491           IF GS_FINAL_TDS-ERP_NUM <> GS_FINAL_TDS_AMT_TEMP-ERP_NUM
4492             OR GS_FINAL_TDS_AMT_TEMP-COMPANY_CODE <> GS_FINAL_TDS-COMPANY_CODE.
4493             EXIT.
4494           ENDIF.
4495
4496           LV_COUNT_T1 = LV_COUNT_T1 + 1.
4497
4498           MOVE-CORRESPONDING GS_FINAL_TDS TO GS_FINAL_TDS_AMT1.
4499
4500           GS_FINAL_TDS_AMT1-LINENUMBER = |{ GS_FINAL_TDS_AMT1-LINENUMBER ALPHA = OUT }|.
4501
4502           APPEND GS_FINAL_TDS_AMT1 TO GT_FINAL_TDS_AMT1.
4503
4504           CLEAR:LV_COUNT_TEMP.
4505           LOOP AT LT_WITH_ITEM_TDS INTO LS_WITH_ITEM_TDS WHERE  BUKRS = GS_FINAL_TDS_AMT_TEMP-COMPANY_CODE
4506                                                             AND BELNR = GS_FINAL_TDS_AMT_TEMP-BELNR
4507                                                             AND GJAHR = GS_FINAL_TDS_AMT_TEMP-GJAHR.
4508             LV_COUNT_TEMP = LV_COUNT_TEMP + 1.
4509           ENDLOOP.
4510         ENDLOOP.
4511
4512         IF LV_COUNT_TEMP GT LV_COUNT_T1.
4513           LOOP AT LT_WITH_ITEM_TDS INTO LS_WITH_ITEM_TDS WHERE BUKRS = GS_FINAL_TDS_AMT_TEMP-COMPANY_CODE
4514                                                            AND BELNR = GS_FINAL_TDS_AMT_TEMP-BELNR
4515                                                            AND GJAHR = GS_FINAL_TDS_AMT_TEMP-GJAHR.
4516
4517             "AM-03-04-2024
4518             READ TABLE LT_TDS_SEC TRANSPORTING NO FIELDS WITH KEY WITHT     = LS_WITH_ITEM_TDS-WITHT
4519                                                            WT_WITHCD = LS_WITH_ITEM_TDS-WT_WITHCD
4520                                                            APPL = 'X'.
4521             IF SY-SUBRC EQ 0.
4522               "AM-03-04-2024
4523
4524               READ TABLE GT_FINAL_TDS_AMT1 INTO GS_FINAL_TDS_AMT_TEMP WITH  KEY COMPANY_CODE = GS_FINAL_TDS_AMT_TEMP-COMPANY_CODE
4525                                                                                      ERP_NUM = GS_FINAL_TDS_AMT_TEMP-ERP_NUM
4526                                                                                      TDS_TAX = LS_WITH_ITEM_TDS-WITHT.
4527               IF SY-SUBRC <> 0.
4528                 IF LS_WITH_ITEM_TDS-WT_QBSHH LT 0.
4529                   LS_WITH_ITEM_TDS-WT_QBSHH = LS_WITH_ITEM_TDS-WT_QBSHH * -1.
4530                 ENDIF.
4531
4532                 IF LS_WITH_ITEM_TDS-WT_QSSHH LT 0.
4533                   LS_WITH_ITEM_TDS-WT_QSSHH  = LS_WITH_ITEM_TDS-WT_QSSHH *  -1.
4534                 ENDIF.
4535
4536                 GS_FINAL_TDS_AMT1-TDS_AMOUNT   = LS_WITH_ITEM_TDS-WT_QBSHH .
4537                 GS_FINAL_TDS_AMT1-TDS_BASE_VAL = LS_WITH_ITEM_TDS-WT_QSSHH.
4538                 GS_FINAL_TDS_AMT1-TDS_RATE     = LS_WITH_ITEM_TDS-QSATZ.
4539
4540                 READ TABLE LT_T059Z INTO LS_T059Z WITH KEY WITHT  = LS_WITH_ITEM_TDS-WITHT
4541                                                        WT_WITHCD  = LS_WITH_ITEM_TDS-WT_WITHCD BINARY SEARCH.
4542                 IF SY-SUBRC = 0.
4543                   GS_FINAL_TDS_AMT1-USER1         = LS_T059Z-QSCOD.
4544                   IF GS_FINAL_TDS_AMT1-TDS_AMOUNT > 0  AND GS_FINAL_TDS_AMT1-TDS_RATE IS INITIAL.
4545                     GS_FINAL_TDS_AMT1-TDS_RATE  = LS_T059Z-QSATZ.
4546                   ENDIF.
4547                 ENDIF.
4548
4549                 IF LS_WITH_ITEM_TDS-WITHT IS NOT INITIAL OR LS_WITH_ITEM_TDS-WT_WITHCD IS NOT INITIAL.
4550                   READ TABLE LT_TDS_SEC INTO LS_TDS_SEC WITH KEY WITHT     = LS_WITH_ITEM_TDS-WITHT
4551                                                                  WT_WITHCD = LS_WITH_ITEM_TDS-WT_WITHCD
4552                                                                  APPL      = 'X' BINARY SEARCH.
4553                   IF SY-SUBRC EQ 0.
4554                     GS_FINAL_TDS_AMT1-TDS_SECTION = LS_TDS_SEC-QSCOD.
4555                   ELSE.
4556                     READ TABLE LT_TDS_SEC INTO LS_TDS_SEC WITH KEY WITHT = LS_WITH_ITEM_TDS-WITHT
4557                                                                     APPL = 'X'.
4558                     IF SY-SUBRC EQ 0.
4559                       GS_FINAL_TDS_AMT1-TDS_SECTION = LS_TDS_SEC-QSCOD.
4560                     ENDIF.
4561                   ENDIF.
4562                 ENDIF.
4563
4564                 GS_FINAL_TDS_AMT1-TDS_TAX_CODE_ERP = LS_WITH_ITEM_TDS-WT_WITHCD.
4565
4566                 IF LS_WITH_ITEM_TDS-WT_GRUWTPD = 'X'.
4567                   GS_FINAL_TDS_AMT1-GROSSUPINDICATOR = 'G'.
4568                 ENDIF.
4569
4570                 IF LS_WITH_ITEM_TDS-WT_OPOWTPD = 'X'.
4571                   GS_FINAL_TDS_AMT1-GROSSUPINDICATOR = 'O'.
4572                 ENDIF.
4573
4574                 IF LS_WITH_ITEM_TDS-WT_OPOWTPD = ' ' AND LS_WITH_ITEM_TDS-WT_GRUWTPD = ' '.
4575                   GS_FINAL_TDS_AMT1-GROSSUPINDICATOR = 'N'.
4576                 ENDIF.
4577
4578                 GS_FINAL_TDS_AMT1-TDS_TAX     = LS_WITH_ITEM_TDS-WITHT.
4579                 GS_FINAL_TDS_AMT1-EXEMP_RATE  = LS_WITH_ITEM_TDS-WT_QSZRT.
4580                 GS_FINAL_TDS_AMT1-EXEMP_NUM   = LS_WITH_ITEM_TDS-WT_WTEXMN.
4581
4582                 GS_FINAL_TDS_AMT1-LINENUMBER = '0'.
4583                 CLEAR:GS_FINAL_TDS_AMT1-TAXABLEVALUE, GS_FINAL_TDS_AMT1-IGSTAMOUNT,
4584                 GS_FINAL_TDS_AMT1-INVOICE_VAL ,GS_FINAL_TDS_AMT1-IGSTRATE,
4585                 GS_FINAL_TDS_AMT1-CESSAMOUNT, GS_FINAL_TDS_AMT1-CESSRATE,
4586                 GS_FINAL_TDS_AMT1-CGSTAMOUNT, GS_FINAL_TDS_AMT1-CGSTRATE,
4587                 GS_FINAL_TDS_AMT1-SGSTAMOUNT, GS_FINAL_TDS_AMT1-SGSTRATE,
4588                 GS_FINAL_TDS_AMT1-AMOUNT, GS_FINAL_TDS_AMT1-EXCH_RATE.
4589
4590                 GS_FINAL_TDS_AMT1-LINENUMBER = |{ GS_FINAL_TDS_AMT1-LINENUMBER ALPHA = OUT }|.
4591                 APPEND GS_FINAL_TDS_AMT1 TO GT_FINAL_TDS_AMT1.
4592               ENDIF.
4593               CLEAR LS_TDS_SEC.
4594
4595             ENDIF. "AM-03-04-2024
4596           ENDLOOP.
4597           CLEAR:GS_FINAL_TDS_AMT1.
4598         ENDIF.
4599       ENDIF.
4600     ENDLOOP.
4601
4602     GT_FINAL_TDS[] = GT_FINAL_TDS_AMT1[].
4603
4604     LOOP AT GT_FINAL_TDS ASSIGNING FIELD-SYMBOL(<GS_FINAL>) WHERE TAXABLEVALUE IS NOT INITIAL.
4605
4606       READ TABLE LT_BSEG INTO DATA(L_BSEG) WITH KEY BUKRS = <GS_FINAL>-BUKRS1
4607                                                     BELNR = <GS_FINAL>-BELNR
4608                                                     GJAHR = <GS_FINAL>-GJAHR
4609                                                     BUZEI = <GS_FINAL>-BUZEI.
4610       IF SY-SUBRC = 0.
4611         IF L_BSEG-TXGRP IS NOT INITIAL.
4612           <GS_FINAL>-TXGRP = L_BSEG-TXGRP.
4613         ELSE.
4614           READ TABLE LT_BSET INTO DATA(L_BSET) WITH KEY BUKRS = <GS_FINAL>-BUKRS1
4615                                                       BELNR = <GS_FINAL>-BELNR
4616                                                       GJAHR = <GS_FINAL>-GJAHR
4617                                                       MWSKZ = L_BSEG-MWSKZ.
4618           IF SY-SUBRC = 0.
4619             <GS_FINAL>-TXGRP = L_BSET-TXGRP.
4620           ENDIF.
4621         ENDIF.
4622       ENDIF.
4623
4624       CONCATENATE <GS_FINAL>-BUKRS1 <GS_FINAL>-BELNR <GS_FINAL>-GJAHR <GS_FINAL>-TXGRP INTO <GS_FINAL>-VAL.
4625       CONCATENATE <GS_FINAL>-BUKRS1 <GS_FINAL>-BELNR <GS_FINAL>-GJAHR INTO <GS_FINAL>-VAL2.
4626
4627       GS_PRO-BUKRS = <GS_FINAL>-BUKRS1.
4628       GS_PRO-BELNR = <GS_FINAL>-BELNR.
4629       GS_PRO-GJAHR = <GS_FINAL>-GJAHR.
4630       GS_PRO-TAXABLEVALUE = <GS_FINAL>-TAXABLEVALUE.
4631       GS_PRO-TXGRP = <GS_FINAL>-TXGRP.
4632       GS_PRO-CNT =  1.
4633       COLLECT GS_PRO INTO GT_PRO.
4634       CLEAR GS_PRO.
4635     ENDLOOP.
4636
4637     DATA(LT_BSET_TEMP) = LT_BSET[].
4638     DELETE LT_BSET_TEMP WHERE HWSTE = '0.00'.
4639
4640     LOOP AT GT_PRO INTO GS_PRO.
4641
4642       LOOP AT LT_BSET_TEMP  INTO L_BSET WHERE BUKRS = GS_PRO-BUKRS
4643                                           AND BELNR = GS_PRO-BELNR
4644                                           AND GJAHR = GS_PRO-GJAHR
4645                                           AND TXGRP = GS_PRO-TXGRP.
4646         CASE L_BSET-KSCHL.
4647           WHEN 'JIIG' OR 'JIIN' OR 'JIMD' OR 'JIRN'.
4648   *          gs_pro-igstamount =  l_bset-hwste. "AM001
4649             GS_PRO-IGSTAMOUNT =   GS_PRO-IGSTAMOUNT + L_BSET-HWSTE. "AM001
4650             GS_PRO-IGSTRATE = L_BSET-KBETR / 10.
4651           WHEN 'JICG' OR 'JCRN' OR 'JICN'.
4652   *          gs_pro-cgstamount = l_bset-hwste. "AM001
4653             GS_PRO-CGSTAMOUNT =   GS_PRO-CGSTAMOUNT + L_BSET-HWSTE. "AM001
4654             GS_PRO-CGSTRATE = L_BSET-KBETR / 10.
4655           WHEN 'JISG' OR 'JSRN' OR 'JISN'.
4656   *          gs_pro-sgstamount = l_bset-hwste. "AM001
4657             GS_PRO-SGSTAMOUNT = GS_PRO-SGSTAMOUNT +  L_BSET-HWSTE. "AM001
4658             GS_PRO-SGSTRATE = L_BSET-KBETR / 10.
4659         ENDCASE.
4660       ENDLOOP.
4661
4662       CLEAR GS_PRO-CNT.
4663       LOOP AT GT_FINAL_TDS  TRANSPORTING NO FIELDS WHERE BUKRS1 = GS_PRO-BUKRS
4664                                                 AND BELNR = GS_PRO-BELNR
4665                                                 AND GJAHR = GS_PRO-GJAHR
4666                                                 AND TXGRP = GS_PRO-TXGRP.
4667         GS_PRO-CNT = GS_PRO-CNT + 1.
4668       ENDLOOP.
4669
4670       IF GS_PRO-IGSTAMOUNT IS NOT INITIAL OR GS_PRO-CGSTAMOUNT IS NOT INITIAL OR GS_PRO-SGSTAMOUNT IS NOT INITIAL.
4671         MODIFY GT_PRO FROM GS_PRO.
4672       ELSEIF GS_PRO-IGSTAMOUNT IS INITIAL AND GS_PRO-CGSTAMOUNT IS INITIAL AND GS_PRO-SGSTAMOUNT IS INITIAL.
4673         DELETE GT_PRO.
4674       ENDIF.
4675       CLEAR : GS_PRO, L_BSET.
4676     ENDLOOP.
4677
4678     IF GT_FINAL_TDS[] IS NOT INITIAL.
4679   " " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
4680   *    SELECT BUKRS,
4681   *             BELNR,
4682   *             GJAHR,
4683   *             HKONT,
4684   *             SHKZG,
4685   *             DMBTR FROM BSEG
4686   *             FOR ALL ENTRIES IN @GT_FINAL_TDS
4687   *             WHERE BUKRS = @GT_FINAL_TDS-BUKRS1
4688   *               AND BELNR = @GT_FINAL_TDS-BELNR
4689   *               AND GJAHR = @GT_FINAL_TDS-GJAHR
4690   *               AND HKONT = '0000142018'
4691   *               INTO TABLE @DATA(LT_BSEG_GL).
4692    SELECT  COMPANYCODE AS BUKRS , ACCOUNTINGDOCUMENT AS BELNR ,
4693   FISCALYEAR AS GJAHR , GLACCOUNT AS HKONT , UNADJUSTEDDEBITCREDITCODE AS
4694   SHKZG , ABSOLUTEAMOUNTINCOCODECRCY AS DMBTR FROM
4695   I_OPERATIONALACCTGDOCITEM FOR ALL ENTRIES IN @GT_FINAL_TDS WHERE
4696   COMPANYCODE = @GT_FINAL_TDS-BUKRS1 AND ACCOUNTINGDOCUMENT =
4697   @GT_FINAL_TDS-BELNR AND FISCALYEAR = @GT_FINAL_TDS-GJAHR AND GLACCOUNT =
4698    '0000142018' INTO TABLE  @DATA(LT_BSEG_GL).
4699   " " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
4700       IF SY-SUBRC = 0.
4701         SORT LT_BSEG_GL BY BUKRS BELNR GJAHR HKONT.
4702       ENDIF.
4703     ENDIF.
4704
4705
4706
4707     LOOP AT GT_FINAL_TDS INTO GS_FINAL_TDS.
4708       L_HKONT = GS_FINAL_TDS-GL_ACC_CODE.
4709       L_HKONT = |{ L_HKONT  ALPHA = IN }|.
4710
4711       READ TABLE LT_BSEG_GL TRANSPORTING NO FIELDS WITH KEY BUKRS = GS_FINAL_TDS-BUKRS1
4712                                                      BELNR = GS_FINAL_TDS-BELNR
4713                                                      GJAHR = GS_FINAL_TDS-GJAHR
4714                                                      HKONT = L_HKONT.
4715       IF SY-SUBRC = 0.
4716         DELETE GT_FINAL_TDS.
4717       ENDIF.
4718       CLEAR GS_FINAL_TDS.
4719     ENDLOOP.
4720
4721     SORT GT_FINAL_TDS BY BUKRS1 BELNR GJAHR TXGRP ASCENDING.
4722
4723     LOOP AT GT_FINAL_TDS ASSIGNING <GS_FINAL> WHERE TAXABLEVALUE IS NOT INITIAL.
4724       IF L_VAL <> <GS_FINAL>-VAL.
4725         L_VAL = <GS_FINAL>-VAL.
4726         CLEAR : L_PRO, L_PRO_C, L_PRO_S, L_CNT, L_CNT2, L_CNT3." s_sgst, s_cgst, s_igst.
4727       ENDIF.
4728       IF L_CNT = 0.
4729         READ TABLE GT_PRO INTO GS_PRO WITH KEY BUKRS = <GS_FINAL>-BUKRS1
4730                                                BELNR = <GS_FINAL>-BELNR
4731                                                TXGRP = <GS_FINAL>-TXGRP.
4732         IF SY-SUBRC = 0.
4733           L_CNT = L_CNT + 1.
4734           L_CNT2 = GS_PRO-CNT.
4735           L_PRO = GS_PRO-IGSTAMOUNT.
4736           L_PRO_C = GS_PRO-CGSTAMOUNT.
4737           L_PRO_S = GS_PRO-SGSTAMOUNT.
4738           CLEAR GS_PRO.
4739         ENDIF.
4740       ENDIF.
4741
4742       L_CNT3 = L_CNT3 + 1.
4743       READ TABLE GT_PRO INTO GS_PRO WITH KEY BUKRS = <GS_FINAL>-BUKRS1
4744                                              BELNR = <GS_FINAL>-BELNR
4745                                              TXGRP = <GS_FINAL>-TXGRP.
4746       IF SY-SUBRC = 0.
4747         <GS_FINAL>-IGSTAMOUNT = ( <GS_FINAL>-TAXABLEVALUE / GS_PRO-TAXABLEVALUE ) * GS_PRO-IGSTAMOUNT.
4748         <GS_FINAL>-IGSTRATE = GS_PRO-IGSTRATE.
4749         <GS_FINAL>-CGSTAMOUNT = ( <GS_FINAL>-TAXABLEVALUE / GS_PRO-TAXABLEVALUE ) * GS_PRO-CGSTAMOUNT.
4750         <GS_FINAL>-CGSTRATE = GS_PRO-CGSTRATE.
4751         <GS_FINAL>-SGSTAMOUNT = ( <GS_FINAL>-TAXABLEVALUE / GS_PRO-TAXABLEVALUE ) * GS_PRO-SGSTAMOUNT.
4752         <GS_FINAL>-SGSTRATE = GS_PRO-SGSTRATE.
4753         IF L_CNT3 < L_CNT2.
4754           L_PRO = L_PRO - <GS_FINAL>-IGSTAMOUNT.
4755         ELSE.
4756           IF L_CNT3 = L_CNT2.
4757             IF L_PRO < 0.
4758               CLEAR <GS_FINAL>-IGSTAMOUNT.
4759               LOOP AT GT_FINAL_TDS ASSIGNING FIELD-SYMBOL(<GS_FINAL2>) WHERE BUKRS1 = <GS_FINAL>-BUKRS1
4760                                                AND BELNR = <GS_FINAL>-BELNR
4761                                                AND TXGRP = <GS_FINAL>-TXGRP
4762                                                AND TAXABLEVALUE IS NOT INITIAL.
4763                 <GS_FINAL2>-IGSTAMOUNT = <GS_FINAL2>-IGSTAMOUNT + L_PRO.
4764                 EXIT.
4765               ENDLOOP.
4766             ELSE.
4767               <GS_FINAL>-IGSTAMOUNT = L_PRO.
4768             ENDIF.
4769           ENDIF.
4770         ENDIF.
4771
4772         IF L_CNT3 < L_CNT2.
4773           L_PRO_C = L_PRO_C - <GS_FINAL>-CGSTAMOUNT.
4774         ELSE.
4775           IF L_CNT3 = L_CNT2.
4776             IF L_PRO_C < 0.
4777               CLEAR <GS_FINAL>-CGSTAMOUNT.
4778
4779               LOOP AT GT_FINAL_TDS ASSIGNING <GS_FINAL2> WHERE BUKRS1 = <GS_FINAL>-BUKRS1
4780                                                AND BELNR = <GS_FINAL>-BELNR
4781                                                AND TXGRP = <GS_FINAL>-TXGRP
4782                                                AND TAXABLEVALUE IS NOT INITIAL.
4783                 <GS_FINAL2>-CGSTAMOUNT = <GS_FINAL2>-CGSTAMOUNT + L_PRO_C.
4784                 EXIT.
4785               ENDLOOP.
4786
4787             ELSE.
4788               <GS_FINAL>-CGSTAMOUNT = L_PRO_C.
4789             ENDIF.
4790           ENDIF.
4791         ENDIF.
4792
4793         IF L_CNT3 < L_CNT2.
4794           L_PRO_S = L_PRO_S - <GS_FINAL>-SGSTAMOUNT.
4795         ELSE.
4796           IF L_CNT3 = L_CNT2.
4797             IF L_PRO_S < 0.
4798               CLEAR <GS_FINAL>-SGSTAMOUNT.
4799
4800               LOOP AT GT_FINAL_TDS ASSIGNING <GS_FINAL2> WHERE BUKRS1 = <GS_FINAL>-BUKRS1
4801                                                AND BELNR = <GS_FINAL>-BELNR
4802                                                AND TXGRP = <GS_FINAL>-TXGRP
4803                                                AND TAXABLEVALUE IS NOT INITIAL.
4804
4805                 <GS_FINAL2>-SGSTAMOUNT = <GS_FINAL2>-SGSTAMOUNT + L_PRO_S.
4806                 EXIT.
4807               ENDLOOP.
4808
4809             ELSE.
4810               <GS_FINAL>-SGSTAMOUNT = L_PRO_S.
4811             ENDIF.
4812           ENDIF.
4813         ENDIF.
4814       ENDIF.
4815       CLEAR GS_PRO.
4816     ENDLOOP.
4817
4818     LOOP AT GT_FINAL_TDS ASSIGNING <GS_FINAL>.
4819       IF <GS_FINAL>-TDS_AMOUNT < 0.
4820         <GS_FINAL>-TDS_AMOUNT = <GS_FINAL>-TDS_AMOUNT * -1.
4821       ENDIF.
4822     ENDLOOP.
4823
4824     LOOP AT GT_FINAL_TDS ASSIGNING <GS_FINAL>.
4825       GS_PRO2-BUKRS = <GS_FINAL>-BUKRS1.
4826       GS_PRO2-BELNR = <GS_FINAL>-BELNR.
4827       GS_PRO2-GJAHR = <GS_FINAL>-GJAHR.
4828       GS_PRO2-TDS_AMOUNT = <GS_FINAL>-TDS_AMOUNT.
4829       GS_PRO2-TDS_BASE_VAL = <GS_FINAL>-TDS_BASE_VAL.
4830
4831       COLLECT GS_PRO2 INTO GT_PRO2.
4832       CLEAR : GS_PRO2.
4833     ENDLOOP.
4834
4835     DATA(LT_WITH_ITEM_TEMP1) = LT_WITH_ITEM_TDS. ""AM-27-03-2024
4836
4837     LOOP AT GT_FINAL_TDS ASSIGNING <GS_FINAL> WHERE TDS_AMOUNT IS NOT INITIAL AND FLAG2 IS INITIAL.
4838       IF <GS_FINAL>-TDS_AMOUNT > 1.
4839         IF G_VAL <> <GS_FINAL>-VAL2.
4840           G_VAL = <GS_FINAL>-VAL2.
4841           READ TABLE GT_PRO2 INTO GS_PRO2 WITH KEY BUKRS = <GS_FINAL>-BUKRS1
4842                                                   BELNR = <GS_FINAL>-BELNR
4843                                                   GJAHR = <GS_FINAL>-GJAHR.
4844           IF SY-SUBRC = 0.
4845   *          LOOP AT LT_WITH_ITEM_TEMP1 INTO DATA(LS_WITH_TEMP) WHERE BUKRS = <GS_FINAL>-BUKRS1
4846             LOOP AT LT_WITH_ITEM_TEMP1 INTO DATA(LS_WITH_TEMP) WHERE BUKRS = <GS_FINAL>-BUKRS1
4847                                                                 AND BELNR = <GS_FINAL>-BELNR
4848                                                                 AND GJAHR = <GS_FINAL>-GJAHR.
4849               IF LS_WITH_TEMP-WT_QSSHH < 0.
4850                 LS_WITH_TEMP-WT_QSSHH = LS_WITH_TEMP-WT_QSSHH * -1.
4851               ENDIF.
4852
4853               IF LS_WITH_TEMP-WT_QBSHH < 0.
4854                 LS_WITH_TEMP-WT_QBSHH = LS_WITH_TEMP-WT_QBSHH * -1.
4855               ENDIF.
4856
4857               G_AMT2 = G_AMT2 + LS_WITH_TEMP-WT_QBSHH.
4858               G_BASE2 = G_BASE2 + LS_WITH_TEMP-WT_QSSHH.
4859             ENDLOOP.
4860
4861             CLEAR G_AMT.
4862             IF GS_PRO2-TDS_BASE_VAL < G_BASE2.
4863               G_AMT = G_BASE2 - GS_PRO2-TDS_BASE_VAL.
4864               <GS_FINAL>-TDS_BASE_VAL = <GS_FINAL>-TDS_BASE_VAL + G_AMT.
4865             ELSEIF GS_PRO2-TDS_BASE_VAL > G_BASE2.
4866               G_AMT = GS_PRO2-TDS_BASE_VAL - G_BASE2 .
4867               <GS_FINAL>-TDS_BASE_VAL = <GS_FINAL>-TDS_BASE_VAL - G_AMT.
4868             ENDIF.
4869             CLEAR G_AMT.
4870             IF GS_PRO2-TDS_AMOUNT < G_AMT2.
4871               G_AMT = G_AMT2 - GS_PRO2-TDS_AMOUNT.
4872               <GS_FINAL>-TDS_AMOUNT = <GS_FINAL>-TDS_AMOUNT + G_AMT.
4873             ELSEIF GS_PRO2-TDS_AMOUNT > G_AMT2.
4874               G_AMT = GS_PRO2-TDS_AMOUNT - G_AMT2 .
4875               <GS_FINAL>-TDS_AMOUNT = <GS_FINAL>-TDS_AMOUNT - G_AMT.
4876             ENDIF.
4877
4878           ENDIF.
4879         ENDIF.
4880       ENDIF.
4881       CLEAR : LS_WITH_TEMP,GS_PRO2,G_AMT2, G_BASE2.
4882     ENDLOOP.
4883
4884     LOOP AT GT_FINAL_TDS ASSIGNING <GS_FINAL>.
4885       <GS_FINAL>-INVOICE_VAL = <GS_FINAL>-TAXABLEVALUE + <GS_FINAL>-IGSTAMOUNT
4886                                + <GS_FINAL>-CGSTAMOUNT + <GS_FINAL>-SGSTAMOUNT + <GS_FINAL>-CESSAMOUNT.
4887     ENDLOOP.
4888
4889
4890     LOOP AT GT_FINAL_TDS ASSIGNING <GS_FINAL>.
4891       IF <GS_FINAL>-ITEM_CAT = '9'.
4892         LS_MSEG_T-EBELN = <GS_FINAL>-PO_NUMBER.
4893         LS_MSEG_T-EBELP = <GS_FINAL>-PO_LINE_ITEM.
4894         LS_MSEG_T-EBELP = |{ LS_MSEG_T-EBELP ALPHA = IN }|.
4895   *      LS_MSEG_T-LFBNR = <GS_FINAL>-XREF3+4(10). "AM-03-04-2024
4896         LS_MSEG_T-LFBNR = <GS_FINAL>-XREF3+5(10).
4897         APPEND LS_MSEG_T TO LT_MSEG_T.
4898       ENDIF.
4899     ENDLOOP.
4900
4901     IF EXP_CHK = 'X'.
4902
4903       IF LT_MSEG_T[] IS NOT INITIAL.
4904         SELECT A~EBELN,
4905                A~EBELP,
4906                A~LFBNR,
4907                A~SAKTO,
4908                B~TXT50 FROM MSEG AS A INNER JOIN SKAT AS B ON ( A~SAKTO = B~SAKNR )
4909                FOR ALL ENTRIES IN @LT_MSEG_T
4910                WHERE A~EBELN = @LT_MSEG_T-EBELN
4911                  AND A~EBELP = @LT_MSEG_T-EBELP
4912                  AND A~LFBNR = @LT_MSEG_T-LFBNR
4913                  AND B~SPRAS = @SY-LANGU
4914                  AND B~KTOPL = @LV_KTOPL
4915                  INTO TABLE @DATA(LT_MSEG_T2).
4916       ENDIF.
4917       LOOP AT GT_FINAL_TDS ASSIGNING <GS_FINAL>.
4918         IF <GS_FINAL>-ITEM_CAT = '9'.
4919           LV_EBELP = <GS_FINAL>-PO_LINE_ITEM.
4920           READ TABLE LT_MSEG_T2 INTO DATA(LS_MSEG_T2) WITH KEY EBELN = <GS_FINAL>-PO_NUMBER
4921                                                                EBELP = LV_EBELP
4922   *                                                             LFBNR = <GS_FINAL>-XREF3+4(10). "AM-03-04-2024
4923                                                                LFBNR = <GS_FINAL>-XREF3+5(10).
4924           IF SY-SUBRC = 0.
4925             <GS_FINAL>-GL_ACC_CODE = LS_MSEG_T2-SAKTO.
4926             <GS_FINAL>-GL_ACC_NAME = LS_MSEG_T2-TXT50.
4927           ENDIF.
4928         ENDIF.
4929         CLEAR LV_EBELP.
4930       ENDLOOP.
4931
4932     ENDIF.
4933
4934     CLEAR : LT_FINAL_TDS_TEMP,LT_FINAL_TDS_MODIFY.
4935     LT_FINAL_TDS_TEMP = GT_FINAL_TDS.
4936     LT_FINAL_TDS_MODIFY = GT_FINAL_TDS.
4937
4938     "Filter and Get all the document with same tax group
4939     DELETE ADJACENT DUPLICATES FROM LT_FINAL_TDS_TEMP COMPARING BUKRS1 BELNR GJAHR TXGRP.
4940
4941
4942     CLEAR:LS_FINAL_TDS_TEMP.
4943     LOOP AT LT_FINAL_TDS_TEMP INTO LS_FINAL_TDS_TEMP.
4944
4945       "Fetch all document line item with same tax group
4946       CLEAR : LS_TXGRP_D_C_IND,LT_TXGRP_D_C_IND.
4947       LOOP AT GT_FINAL_TDS ASSIGNING <FS_FINAL_TDS> WHERE BUKRS1 = LS_FINAL_TDS_TEMP-BUKRS1
4948                                                     AND   BELNR = LS_FINAL_TDS_TEMP-BELNR
4949                                                     AND   GJAHR = LS_FINAL_TDS_TEMP-GJAHR
4950                                                     AND   TXGRP = LS_FINAL_TDS_TEMP-TXGRP.
4951
4952         LS_TXGRP_D_C_IND = <FS_FINAL_TDS>.
4953         APPEND LS_TXGRP_D_C_IND TO LT_TXGRP_D_C_IND.
4954
4955         CLEAR : LS_TXGRP_D_C_IND.
4956       ENDLOOP.
4957       UNASSIGN <FS_FINAL_TDS>.
4958
4959       "Check If document and taxgrp have multiple line item.
4960       CLEAR:LV_COUNT1.
4961       DESCRIBE TABLE LT_TXGRP_D_C_IND LINES LV_COUNT1.
4962
4963       IF LV_COUNT1 GT 1.
4964
4965         "calculate Taxable value
4966         CLEAR:LS_TXGRP_D_C_IND,LV_GRANT_TOTAL.
4967         LOOP AT LT_TXGRP_D_C_IND INTO LS_TXGRP_D_C_IND.
4968   *        IF ls_txgrp_d_c_ind-documenttype EQ 'INV' AND ls_txgrp_d_c_ind-shkzg EQ 'S'
4969   *        OR ls_txgrp_d_c_ind-documenttype EQ 'DR' AND ls_txgrp_d_c_ind-shkzg EQ 'S'.
4970   *          lv_grant_total = lv_grant_total + ls_txgrp_d_c_ind-taxablevalue.
4971   *        ELSEIF ls_txgrp_d_c_ind-documenttype EQ 'CR' AND ls_txgrp_d_c_ind-shkzg EQ 'H'.
4972   *          lv_grant_total = lv_grant_total + ls_txgrp_d_c_ind-taxablevalue.
4973   *        ENDIF.
4974
4975
4976           IF LS_TXGRP_D_C_IND-DOCUMENTTYPE EQ 'INV' OR LS_TXGRP_D_C_IND-DOCUMENTTYPE EQ 'DR'.
4977   *          IF ls_txgrp_d_c_ind-shkzg EQ 'S'.
4978             LV_GRANT_TOTAL = LV_GRANT_TOTAL + LS_TXGRP_D_C_IND-TAXABLEVALUE.
4979   *          ELSE.
4980   *            lv_grant_total = lv_grant_total - ls_txgrp_d_c_ind-taxablevalue.
4981   *          ENDIF.
4982
4983           ELSEIF LS_TXGRP_D_C_IND-DOCUMENTTYPE EQ 'CR' .
4984   *          IF ls_txgrp_d_c_ind-shkzg EQ 'S'.
4985             LV_GRANT_TOTAL = LV_GRANT_TOTAL + LS_TXGRP_D_C_IND-TAXABLEVALUE.
4986   *          ELSE.
4987   *            lv_grant_total = lv_grant_total - ls_txgrp_d_c_ind-taxablevalue.
4988   *          ENDIF.
4989           ENDIF.
4990
4991           CLEAR:LS_TXGRP_D_C_IND.
4992         ENDLOOP.
4993
4994         "calculate Taxable value if no document type debit/credit idicator match
4995         IF LV_GRANT_TOTAL IS INITIAL.
4996           CLEAR:LS_TXGRP_D_C_IND.
4997           LOOP AT LT_TXGRP_D_C_IND INTO LS_TXGRP_D_C_IND.
4998             LV_GRANT_TOTAL = LV_GRANT_TOTAL + LS_TXGRP_D_C_IND-TAXABLEVALUE.
4999             CLEAR:LS_TXGRP_D_C_IND.
5000           ENDLOOP.
5001         ENDIF.
5002
5003         "calculate final amount
5004         "SOC Added by AM001 on 10.01.24
5005         DATA: LV_IGST TYPE BSET-HWSTE,
5006               LV_CGST TYPE BSET-HWSTE,
5007               LV_SGST TYPE BSET-HWSTE.
5008         CLEAR :LV_SGST, LV_CGST, LV_IGST.
5009         "EOC Added by AM001 on 10.01.24
5010
5011         LOOP AT LT_TXGRP_D_C_IND ASSIGNING FIELD-SYMBOL(<FS_TXGRP_D_C_IND>).
5012           CLEAR: LS_BSET.
5013           LOOP AT LT_BSET INTO LS_BSET WHERE BUKRS = <FS_TXGRP_D_C_IND>-BUKRS1
5014                                        AND  BELNR = <FS_TXGRP_D_C_IND>-BELNR
5015                                        AND  GJAHR = <FS_TXGRP_D_C_IND>-GJAHR
5016                                        AND  TXGRP = <FS_TXGRP_D_C_IND>-TXGRP.
5017
5018             CLEAR: LS_TDS_COND_TYPE.
5019             READ TABLE LT_TDS_COND_TYPE INTO LS_TDS_COND_TYPE WITH  KEY KSCHL = LS_BSET-KSCHL BINARY SEARCH.
5020             IF SY-SUBRC = 0.
5021               IF LS_TDS_COND_TYPE-TAX_TYPE = 'IGST'.
5022   *              <fs_txgrp_d_c_ind>-igstamount = ( <fs_txgrp_d_c_ind>-taxablevalue / lv_grant_total ) * ls_bset-hwste."AM001
5023                 LV_IGST = LV_IGST + ( <FS_TXGRP_D_C_IND>-TAXABLEVALUE / LV_GRANT_TOTAL ) * LS_BSET-HWSTE."AM001
5024                 <FS_TXGRP_D_C_IND>-IGSTRATE = LS_BSET-KBETR / 10.
5025               ENDIF.
5026
5027               IF LS_TDS_COND_TYPE-TAX_TYPE = 'CGST'.
5028   *              <fs_txgrp_d_c_ind>-cgstamount = ( <fs_txgrp_d_c_ind>-taxablevalue / lv_grant_total ) * ls_bset-hwste."AM001
5029                 LV_CGST = LV_CGST  + ( <FS_TXGRP_D_C_IND>-TAXABLEVALUE / LV_GRANT_TOTAL ) * LS_BSET-HWSTE."AM001
5030                 <FS_TXGRP_D_C_IND>-CGSTRATE = LS_BSET-KBETR / 10.
5031               ENDIF.
5032
5033               IF LS_TDS_COND_TYPE-TAX_TYPE = 'SGST'.
5034   *              <fs_txgrp_d_c_ind>-sgstamount = ( <fs_txgrp_d_c_ind>-taxablevalue / lv_grant_total ) * ls_bset-hwste. "AM001
5035                 LV_SGST = LV_SGST  + ( <FS_TXGRP_D_C_IND>-TAXABLEVALUE / LV_GRANT_TOTAL ) * LS_BSET-HWSTE. "AM001
5036                 <FS_TXGRP_D_C_IND>-SGSTRATE = LS_BSET-KBETR / 10.
5037               ENDIF.
5038             ENDIF.
5039           ENDLOOP.
5040
5041           <FS_TXGRP_D_C_IND>-IGSTAMOUNT = LV_IGST. "AM001
5042           <FS_TXGRP_D_C_IND>-CGSTAMOUNT = LV_CGST. "AM001
5043           <FS_TXGRP_D_C_IND>-SGSTAMOUNT = LV_SGST. "AM001
5044
5045           <FS_TXGRP_D_C_IND>-AVAIL_IGST = LV_IGST. "AM001
5046           <FS_TXGRP_D_C_IND>-AVAIL_CGST = LV_CGST. "AM001
5047           <FS_TXGRP_D_C_IND>-AVAIL_SGST = LV_SGST. "AM001
5048           CLEAR:LV_IGST, LV_CGST, LV_SGST. "AM001
5049         ENDLOOP.
5050
5051         UNASSIGN <FS_TXGRP_D_C_IND>.
5052
5053         LOOP AT LT_TXGRP_D_C_IND ASSIGNING <FS_TXGRP_D_C_IND>.
5054           LOOP AT LT_FINAL_TDS_MODIFY ASSIGNING FIELD-SYMBOL(<FS_FINAL_TDS_MODIFY1>)
5055                                                WHERE BUKRS1 EQ <FS_TXGRP_D_C_IND>-BUKRS1
5056                                                AND   BELNR  EQ <FS_TXGRP_D_C_IND>-BELNR
5057                                                AND   GJAHR  EQ <FS_TXGRP_D_C_IND>-GJAHR
5058                                                AND   TXGRP  EQ <FS_TXGRP_D_C_IND>-TXGRP
5059                                                AND   SHKZG  EQ <FS_TXGRP_D_C_IND>-SHKZG
5060                                                AND   BUZEI  EQ <FS_TXGRP_D_C_IND>-BUZEI.
5061
5062
5063             <FS_FINAL_TDS_MODIFY1>-IGSTAMOUNT = <FS_TXGRP_D_C_IND>-IGSTAMOUNT.
5064             <FS_FINAL_TDS_MODIFY1>-IGSTRATE = <FS_TXGRP_D_C_IND>-IGSTRATE.
5065             <FS_FINAL_TDS_MODIFY1>-CGSTAMOUNT = <FS_TXGRP_D_C_IND>-CGSTAMOUNT.
5066             <FS_FINAL_TDS_MODIFY1>-CGSTRATE = <FS_TXGRP_D_C_IND>-CGSTRATE.
5067             <FS_FINAL_TDS_MODIFY1>-SGSTAMOUNT = <FS_TXGRP_D_C_IND>-SGSTAMOUNT.
5068             <FS_FINAL_TDS_MODIFY1>-SGSTRATE = <FS_TXGRP_D_C_IND>-SGSTRATE.
5069
5070             <FS_FINAL_TDS_MODIFY1>-AVAIL_IGST = <FS_TXGRP_D_C_IND>-AVAIL_IGST. "AM001
5071             <FS_FINAL_TDS_MODIFY1>-AVAIL_CGST = <FS_TXGRP_D_C_IND>-AVAIL_CGST. "AM001
5072             <FS_FINAL_TDS_MODIFY1>-AVAIL_SGST = <FS_TXGRP_D_C_IND>-AVAIL_SGST. "AM001
5073
5074           ENDLOOP.
5075         ENDLOOP.
5076         UNASSIGN <FS_FINAL_TDS_MODIFY1>.
5077         UNASSIGN <FS_TXGRP_D_C_IND>.
5078
5079         "Prioritise to Debit/Credit indicator based on the docuemnt type.
5080         CLEAR: LF_INV_DR_HAVING_H,
5081                LF_CR_HAVING_S.
5082
5083         LOOP AT LT_TXGRP_D_C_IND ASSIGNING <FS_TXGRP_D_C_IND>.
5084
5085           IF <FS_TXGRP_D_C_IND>-DOCUMENTTYPE EQ 'INV'
5086             OR  <FS_TXGRP_D_C_IND>-DOCUMENTTYPE EQ 'DR'.
5087
5088             IF <FS_TXGRP_D_C_IND>-SUPPLY_TYPE EQ 'CAN' OR <FS_TXGRP_D_C_IND>-SUPPLY_TYPE EQ 'REV'.
5089               IF <FS_TXGRP_D_C_IND>-SHKZG EQ 'S'.
5090                 CLEAR: LS_TXGRP_D_C_IND.
5091                 READ TABLE LT_TXGRP_D_C_IND INTO LS_TXGRP_D_C_IND WITH KEY SHKZG = 'H'.
5092                 IF SY-SUBRC EQ 0.
5093                   LF_CR_HAVING_S = 'X'.
5094                 ENDIF.
5095
5096               ELSEIF <FS_TXGRP_D_C_IND>-SHKZG EQ 'H'.
5097                 READ TABLE LT_TXGRP_D_C_IND INTO LS_TXGRP_D_C_IND WITH KEY SHKZG = 'S'.
5098                 IF SY-SUBRC EQ 0.
5099                   LF_CR_HAVING_S = 'X'.
5100                 ENDIF.
5101               ENDIF.
5102
5103             ELSEIF <FS_TXGRP_D_C_IND>-SHKZG EQ 'S'.
5104               CLEAR: LS_TXGRP_D_C_IND.
5105               READ TABLE LT_TXGRP_D_C_IND INTO LS_TXGRP_D_C_IND WITH KEY SHKZG = 'H'.
5106               IF SY-SUBRC EQ 0.
5107                 LF_INV_DR_HAVING_H = 'X'.
5108               ENDIF.
5109
5110             ELSEIF <FS_TXGRP_D_C_IND>-SHKZG EQ 'H'.
5111               CLEAR: LS_TXGRP_D_C_IND.
5112               READ TABLE LT_TXGRP_D_C_IND INTO LS_TXGRP_D_C_IND WITH KEY SHKZG = 'S'.
5113               IF SY-SUBRC EQ 0.
5114                 LF_INV_DR_HAVING_H = 'X'.
5115               ENDIF.
5116
5117             ENDIF.
5118           ENDIF.
5119
5120           IF <FS_TXGRP_D_C_IND>-DOCUMENTTYPE EQ 'CR'.
5121
5122             IF <FS_TXGRP_D_C_IND>-SUPPLY_TYPE EQ 'CAN' OR <FS_TXGRP_D_C_IND>-SUPPLY_TYPE EQ 'REV'.
5123               IF <FS_TXGRP_D_C_IND>-SHKZG EQ 'S'.
5124                 CLEAR: LS_TXGRP_D_C_IND.
5125                 READ TABLE LT_TXGRP_D_C_IND INTO LS_TXGRP_D_C_IND WITH KEY SHKZG = 'H'.
5126                 IF SY-SUBRC EQ 0.
5127                   LF_INV_DR_HAVING_H = 'X'.
5128                 ENDIF.
5129
5130               ELSEIF <FS_TXGRP_D_C_IND>-SHKZG EQ 'H'.
5131                 READ TABLE LT_TXGRP_D_C_IND INTO LS_TXGRP_D_C_IND WITH KEY SHKZG = 'S'.
5132                 IF SY-SUBRC EQ 0.
5133                   LF_INV_DR_HAVING_H = 'X'.
5134                 ENDIF.
5135               ENDIF.
5136
5137             ELSEIF <FS_TXGRP_D_C_IND>-SHKZG EQ 'S'.
5138               CLEAR: LS_TXGRP_D_C_IND.
5139               READ TABLE LT_TXGRP_D_C_IND INTO LS_TXGRP_D_C_IND WITH KEY SHKZG = 'H'.
5140               IF SY-SUBRC EQ 0.
5141                 LF_CR_HAVING_S = 'X'.
5142               ENDIF.
5143
5144             ELSEIF <FS_TXGRP_D_C_IND>-SHKZG EQ 'H'.
5145               CLEAR: LS_TXGRP_D_C_IND.
5146               READ TABLE LT_TXGRP_D_C_IND INTO LS_TXGRP_D_C_IND WITH KEY SHKZG = 'S'.
5147               IF SY-SUBRC EQ 0.
5148                 LF_CR_HAVING_S = 'X'.
5149               ENDIF.
5150             ENDIF.
5151           ENDIF.
5152
5153           CLEAR:LV_IGST, LV_CGST, LV_SGST. "AM001
5154           IF LF_INV_DR_HAVING_H = 'X'.
5155
5156             LOOP AT LT_FINAL_TDS_MODIFY ASSIGNING <FS_FINAL_TDS_MODIFY>
5157                                          WHERE BUKRS1 EQ <FS_TXGRP_D_C_IND>-BUKRS1
5158                                          AND   BELNR  EQ <FS_TXGRP_D_C_IND>-BELNR
5159                                          AND   GJAHR  EQ <FS_TXGRP_D_C_IND>-GJAHR
5160                                          AND   TXGRP  EQ <FS_TXGRP_D_C_IND>-TXGRP
5161                                          AND   SHKZG  EQ 'H'.
5162
5163               LV_IGST = LV_IGST + <FS_FINAL_TDS_MODIFY>-IGSTAMOUNT. "AM001
5164               LV_CGST = LV_CGST + <FS_FINAL_TDS_MODIFY>-CGSTAMOUNT. "AM001
5165               LV_SGST = LV_SGST + <FS_FINAL_TDS_MODIFY>-SGSTAMOUNT. "AM001
5166
5167               CLEAR : <FS_FINAL_TDS_MODIFY>-IGSTAMOUNT,
5168                       <FS_FINAL_TDS_MODIFY>-IGSTRATE,
5169                       <FS_FINAL_TDS_MODIFY>-CGSTAMOUNT,
5170                       <FS_FINAL_TDS_MODIFY>-CGSTRATE,
5171                       <FS_FINAL_TDS_MODIFY>-SGSTAMOUNT,
5172                       <FS_FINAL_TDS_MODIFY>-SGSTRATE.
5173
5174               CLEAR:<FS_FINAL_TDS_MODIFY>-AVAIL_IGST, "AM001
5175                     <FS_FINAL_TDS_MODIFY>-AVAIL_CGST, "AM001
5176                     <FS_FINAL_TDS_MODIFY>-AVAIL_SGST. "AM001
5177
5178             ENDLOOP.
5179
5180             "AM001
5181             IF LV_IGST > 0 OR LV_CGST > 0  OR LV_SGST > 0.
5182   *            lv_igst =  lv_igst + <fs_txgrp_d_c_ind>-igstamount ."AM001
5183   *            lv_cgst =  lv_cgst + <fs_txgrp_d_c_ind>-cgstamount ."AM001
5184   *            lv_sgst =  lv_sgst + <fs_txgrp_d_c_ind>-sgstamount ."AM001
5185
5186               LOOP AT LT_FINAL_TDS_MODIFY ASSIGNING <FS_FINAL_TDS_MODIFY>
5187                                 WHERE BUKRS1 EQ <FS_TXGRP_D_C_IND>-BUKRS1
5188                                 AND   BELNR  EQ <FS_TXGRP_D_C_IND>-BELNR
5189                                 AND   GJAHR  EQ <FS_TXGRP_D_C_IND>-GJAHR
5190                                 AND   TXGRP  EQ <FS_TXGRP_D_C_IND>-TXGRP
5191                                 AND   SHKZG  EQ 'S'.
5192                 IF LV_IGST > 0.
5193                   <FS_FINAL_TDS_MODIFY>-IGSTAMOUNT =   <FS_FINAL_TDS_MODIFY>-IGSTAMOUNT +  LV_IGST.
5194                   <FS_FINAL_TDS_MODIFY>-AVAIL_IGST =   <FS_FINAL_TDS_MODIFY>-IGSTAMOUNT.
5195                 ENDIF.
5196
5197                 IF LV_CGST > 0.
5198                   <FS_FINAL_TDS_MODIFY>-CGSTAMOUNT =   <FS_FINAL_TDS_MODIFY>-CGSTAMOUNT + LV_CGST.
5199                   <FS_FINAL_TDS_MODIFY>-AVAIL_CGST =  <FS_FINAL_TDS_MODIFY>-CGSTAMOUNT.
5200                 ENDIF.
5201
5202                 IF LV_SGST > 0.
5203                   <FS_FINAL_TDS_MODIFY>-SGSTAMOUNT =  <FS_FINAL_TDS_MODIFY>-SGSTAMOUNT + LV_SGST.
5204                   <FS_FINAL_TDS_MODIFY>-AVAIL_SGST =  <FS_FINAL_TDS_MODIFY>-SGSTAMOUNT.
5205                 ENDIF.
5206                 CLEAR:LV_IGST, LV_CGST, LV_SGST. "AM001
5207               ENDLOOP.
5208             ENDIF.
5209             "AM001
5210
5211
5212           ELSEIF LF_CR_HAVING_S = 'X'.
5213
5214             LOOP AT LT_FINAL_TDS_MODIFY ASSIGNING <FS_FINAL_TDS_MODIFY>
5215                                         WHERE BUKRS1 EQ <FS_TXGRP_D_C_IND>-BUKRS1
5216                                         AND   BELNR  EQ <FS_TXGRP_D_C_IND>-BELNR
5217                                         AND   GJAHR  EQ <FS_TXGRP_D_C_IND>-GJAHR
5218                                         AND   TXGRP  EQ <FS_TXGRP_D_C_IND>-TXGRP
5219                                         AND   SHKZG  EQ 'S'.
5220
5221               LV_IGST = LV_IGST + <FS_FINAL_TDS_MODIFY>-IGSTAMOUNT. "AM001
5222               LV_CGST = LV_CGST + <FS_FINAL_TDS_MODIFY>-CGSTAMOUNT. "AM001
5223               LV_SGST = LV_SGST + <FS_FINAL_TDS_MODIFY>-SGSTAMOUNT. "AM001
5224
5225               CLEAR : <FS_FINAL_TDS_MODIFY>-IGSTAMOUNT,
5226                       <FS_FINAL_TDS_MODIFY>-IGSTRATE,
5227                       <FS_FINAL_TDS_MODIFY>-CGSTAMOUNT,
5228                       <FS_FINAL_TDS_MODIFY>-CGSTRATE,
5229                       <FS_FINAL_TDS_MODIFY>-SGSTAMOUNT,
5230                       <FS_FINAL_TDS_MODIFY>-SGSTRATE.
5231
5232               CLEAR:<FS_FINAL_TDS_MODIFY>-AVAIL_IGST, "AM001
5233               <FS_FINAL_TDS_MODIFY>-AVAIL_CGST, "AM001
5234               <FS_FINAL_TDS_MODIFY>-AVAIL_SGST. "AM001
5235
5236             ENDLOOP.
5237
5238             "AM001
5239             IF LV_IGST > 0 OR LV_CGST > 0  OR LV_SGST > 0.
5240   *            lv_igst =  lv_igst + <fs_txgrp_d_c_ind>-igstamount ."AM001
5241   *            lv_cgst =  lv_cgst + <fs_txgrp_d_c_ind>-cgstamount ."AM001
5242   *            lv_sgst =  lv_sgst + <fs_txgrp_d_c_ind>-sgstamount ."AM001
5243
5244               LOOP AT LT_FINAL_TDS_MODIFY ASSIGNING <FS_FINAL_TDS_MODIFY>
5245                                 WHERE BUKRS1 EQ <FS_TXGRP_D_C_IND>-BUKRS1
5246                                 AND   BELNR  EQ <FS_TXGRP_D_C_IND>-BELNR
5247                                 AND   GJAHR  EQ <FS_TXGRP_D_C_IND>-GJAHR
5248                                 AND   TXGRP  EQ <FS_TXGRP_D_C_IND>-TXGRP
5249                                 AND   SHKZG  EQ 'H'.
5250                 IF LV_IGST > 0.
5251                   <FS_FINAL_TDS_MODIFY>-IGSTAMOUNT =   <FS_FINAL_TDS_MODIFY>-IGSTAMOUNT +  LV_IGST.
5252                   <FS_FINAL_TDS_MODIFY>-AVAIL_IGST =   <FS_FINAL_TDS_MODIFY>-IGSTAMOUNT.
5253                 ENDIF.
5254
5255                 IF LV_CGST > 0.
5256                   <FS_FINAL_TDS_MODIFY>-CGSTAMOUNT =   <FS_FINAL_TDS_MODIFY>-CGSTAMOUNT + LV_CGST.
5257                   <FS_FINAL_TDS_MODIFY>-AVAIL_CGST =  <FS_FINAL_TDS_MODIFY>-CGSTAMOUNT.
5258                 ENDIF.
5259
5260                 IF LV_SGST > 0.
5261                   <FS_FINAL_TDS_MODIFY>-SGSTAMOUNT =  <FS_FINAL_TDS_MODIFY>-SGSTAMOUNT + LV_SGST.
5262                   <FS_FINAL_TDS_MODIFY>-AVAIL_SGST =  <FS_FINAL_TDS_MODIFY>-SGSTAMOUNT.
5263                 ENDIF.
5264                 CLEAR:LV_IGST, LV_CGST, LV_SGST. "AM001
5265               ENDLOOP.
5266             ENDIF.
5267             "AM001
5268
5269           ENDIF.
5270
5271           UNASSIGN <FS_FINAL_TDS_MODIFY>.
5272
5273
5274
5275           CLEAR:LS_FINAL_TDS_TEMP.
5276           CLEAR: LF_INV_DR_HAVING_H,
5277                LF_CR_HAVING_S.
5278
5279         ENDLOOP.
5280         UNASSIGN <FS_TXGRP_D_C_IND>.
5281
5282
5283         "AM001
5284   *      LOOP AT lt_txgrp_d_c_ind ASSIGNING FIELD-SYMBOL(<fs_txgrp_d_c_ind2>).
5285   *
5286   *        CLEAR:ls_final_tds_modify.
5287   *        READ TABLE lt_final_tds_modify INTO ls_final_tds_modify
5288   *                                       WITH KEY bukrs1 = <fs_txgrp_d_c_ind2>-bukrs1
5289   *                                                belnr  = <fs_txgrp_d_c_ind2>-belnr
5290   *                                                gjahr  = <fs_txgrp_d_c_ind2>-gjahr
5291   *                                                txgrp  = <fs_txgrp_d_c_ind2>-txgrp
5292   *                                                buzei  = <fs_txgrp_d_c_ind2>-buzei.
5293   *        IF sy-subrc EQ 0.
5294   *          <fs_txgrp_d_c_ind2> =  ls_final_tds_modify.
5295   *        ENDIF.
5296   *      ENDLOOP.
5297
5298
5299         "Check if any difference available in IGST amount
5300   *      CLEAR:lv_total_igst,ls_txgrp_d_c_ind,lv_total_cgst,lv_total_sgst.
5301   *      LOOP AT lt_txgrp_d_c_ind INTO ls_txgrp_d_c_ind.
5302   *        lv_total_igst = lv_total_igst + ls_txgrp_d_c_ind-igstamount.
5303   *        lv_total_cgst = lv_total_cgst + ls_txgrp_d_c_ind-cgstamount.
5304   *        lv_total_sgst = lv_total_sgst + ls_txgrp_d_c_ind-sgstamount.
5305   *        CLEAR:ls_txgrp_d_c_ind.
5306   *      ENDLOOP.
5307
5308         "AM001
5309
5310         "Commented by Anil Maurya
5311   *      READ TABLE lt_txgrp_d_c_ind ASSIGNING FIELD-SYMBOL(<fs_txgrp_d_c_ind1>) INDEX 1.
5312   *      IF sy-subrc EQ 0.
5313   *        CLEAR:ls_bset.
5314   *        LOOP AT lt_bset INTO ls_bset WHERE bukrs = <fs_txgrp_d_c_ind1>-bukrs1
5315   *                                      AND  belnr = <fs_txgrp_d_c_ind1>-belnr
5316   *                                      AND  gjahr = <fs_txgrp_d_c_ind1>-gjahr
5317   *                                      AND  txgrp = <fs_txgrp_d_c_ind1>-txgrp.
5318   *
5319   *          CLEAR: ls_tds_cond_type.
5320   *          READ TABLE lt_tds_cond_type INTO ls_tds_cond_type WITH  KEY kschl = ls_bset-kschl BINARY SEARCH.
5321   *          IF sy-subrc = 0.
5322   *            IF ls_tds_cond_type-tax_type = 'IGST'.
5323   *
5324   *              CLEAR:lv_total_igst_diff.
5325   *              IF lv_total_igst < ls_bset-hwste.
5326   *                lv_total_igst_diff =  ls_bset-hwste - lv_total_igst.
5327   *
5328   *                LOOP AT lt_final_tds_modify ASSIGNING <fs_final_tds_modify2> WHERE bukrs1 EQ <fs_txgrp_d_c_ind1>-bukrs1
5329   *                                                                            AND   belnr  EQ <fs_txgrp_d_c_ind1>-belnr
5330   *                                                                            AND   gjahr  EQ <fs_txgrp_d_c_ind1>-gjahr
5331   *                                                                            AND   buzei  EQ <fs_txgrp_d_c_ind1>-buzei
5332   *                                                                            AND   txgrp  EQ <fs_txgrp_d_c_ind1>-txgrp
5333   *                                                                            AND   shkzg  EQ <fs_txgrp_d_c_ind1>-shkzg.
5334   *
5335   *                  IF <fs_final_tds_modify2>-igstrate NE 0
5336   *                   OR <fs_final_tds_modify2>-cgstrate NE 0
5337   *                   OR <fs_final_tds_modify2>-sgstrate NE 0.
5338   *                    <fs_final_tds_modify2>-igstamount = <fs_final_tds_modify2>-igstamount + lv_total_igst_diff.
5339   *                  ENDIF.
5340   *
5341   *                ENDLOOP.
5342   *
5343   *
5344   *              ELSEIF ls_bset-hwste < lv_total_igst.
5345   *                lv_total_igst_diff =  lv_total_igst - ls_bset-hwste.
5346   *
5347   *                LOOP AT lt_final_tds_modify ASSIGNING <fs_final_tds_modify2> WHERE bukrs1 EQ <fs_txgrp_d_c_ind1>-bukrs1
5348   *                                                                            AND   belnr  EQ <fs_txgrp_d_c_ind1>-belnr
5349   *                                                                            AND   gjahr  EQ <fs_txgrp_d_c_ind1>-gjahr
5350   *                                                                            AND   buzei  EQ <fs_txgrp_d_c_ind1>-buzei
5351   *                                                                            AND   txgrp  EQ <fs_txgrp_d_c_ind1>-txgrp
5352   *                                                                            AND   shkzg  EQ <fs_txgrp_d_c_ind1>-shkzg.
5353   *
5354   *                  IF <fs_final_tds_modify2>-igstrate NE 0
5355   *                    OR <fs_final_tds_modify2>-cgstrate NE 0
5356   *                    OR <fs_final_tds_modify2>-sgstrate NE 0.
5357   *                   <fs_final_tds_modify2>-igstamount = <fs_final_tds_modify2>-igstamount - lv_total_igst_diff.
5358   *                  ENDIF.
5359   *                ENDLOOP.
5360   *
5361   *              ENDIF.
5362   *
5363   *            ELSEIF ls_tds_cond_type-tax_type = 'CGST'.
5364   *
5365   *              CLEAR:lv_total_cgst_diff.
5366   *              IF lv_total_cgst < ls_bset-hwste.
5367   *                lv_total_cgst_diff =  ls_bset-hwste - lv_total_cgst.
5368   *
5369   *                LOOP AT lt_final_tds_modify ASSIGNING <fs_final_tds_modify2> WHERE bukrs1 EQ <fs_txgrp_d_c_ind1>-bukrs1
5370   *                                                                            AND   belnr  EQ <fs_txgrp_d_c_ind1>-belnr
5371   *                                                                            AND   gjahr  EQ <fs_txgrp_d_c_ind1>-gjahr
5372   *                                                                            AND   buzei  EQ <fs_txgrp_d_c_ind1>-buzei
5373   *                                                                            AND   txgrp  EQ <fs_txgrp_d_c_ind1>-txgrp
5374   *                                                                            AND   shkzg  EQ <fs_txgrp_d_c_ind1>-shkzg.
5375   *
5376   *                  IF <fs_final_tds_modify2>-igstrate NE 0
5377   *                   OR <fs_final_tds_modify2>-cgstrate NE 0
5378   *                   OR <fs_final_tds_modify2>-sgstrate NE 0.
5379   *                    <fs_final_tds_modify2>-cgstamount = <fs_final_tds_modify2>-cgstamount + lv_total_cgst_diff.
5380   *                  ENDIF.
5381   *
5382   *                ENDLOOP.
5383   *
5384   *
5385   *              ELSEIF ls_bset-hwste < lv_total_cgst.
5386   *                lv_total_cgst_diff =  lv_total_cgst - ls_bset-hwste.
5387   *
5388   *                LOOP AT lt_final_tds_modify ASSIGNING <fs_final_tds_modify2> WHERE bukrs1 EQ <fs_txgrp_d_c_ind1>-bukrs1
5389   *                                                                            AND   belnr  EQ <fs_txgrp_d_c_ind1>-belnr
5390   *                                                                            AND   gjahr  EQ <fs_txgrp_d_c_ind1>-gjahr
5391   *                                                                            AND   buzei  EQ <fs_txgrp_d_c_ind1>-buzei
5392   *                                                                            AND   txgrp  EQ <fs_txgrp_d_c_ind1>-txgrp
5393   *                                                                            AND   shkzg  EQ <fs_txgrp_d_c_ind1>-shkzg.
5394   *
5395   *                  IF <fs_final_tds_modify2>-igstrate NE 0
5396   *                    OR <fs_final_tds_modify2>-cgstrate NE 0
5397   *                    OR <fs_final_tds_modify2>-sgstrate NE 0.
5398   *                    <fs_final_tds_modify2>-cgstamount = <fs_final_tds_modify2>-cgstamount - lv_total_cgst_diff.
5399   *                  ENDIF.
5400   *                ENDLOOP.
5401   *              ENDIF.
5402   *
5403   *            ELSEIF ls_tds_cond_type-tax_type = 'SGST'.
5404   *
5405   *              CLEAR:lv_total_sgst_diff.
5406   *              IF lv_total_sgst < ls_bset-hwste.
5407   *                lv_total_sgst_diff =  ls_bset-hwste - lv_total_sgst.
5408   *
5409   *                LOOP AT lt_final_tds_modify ASSIGNING <fs_final_tds_modify2> WHERE bukrs1 EQ <fs_txgrp_d_c_ind1>-bukrs1
5410   *                                                                            AND   belnr  EQ <fs_txgrp_d_c_ind1>-belnr
5411   *                                                                            AND   gjahr  EQ <fs_txgrp_d_c_ind1>-gjahr
5412   *                                                                            AND   buzei  EQ <fs_txgrp_d_c_ind1>-buzei
5413   *                                                                            AND   txgrp  EQ <fs_txgrp_d_c_ind1>-txgrp
5414   *                                                                            AND   shkzg  EQ <fs_txgrp_d_c_ind1>-shkzg.
5415   *
5416   *                  IF <fs_final_tds_modify2>-igstrate NE 0
5417   *                   OR <fs_final_tds_modify2>-cgstrate NE 0
5418   *                   OR <fs_final_tds_modify2>-sgstrate NE 0.
5419   *                    <fs_final_tds_modify2>-sgstamount = <fs_final_tds_modify2>-sgstamount + lv_total_sgst_diff.
5420   *                  ENDIF.
5421   *
5422   *                ENDLOOP.
5423   *
5424   *
5425   *              ELSEIF ls_bset-hwste < lv_total_sgst.
5426   *                lv_total_sgst_diff =  lv_total_sgst - ls_bset-hwste.
5427   *
5428   *                LOOP AT lt_final_tds_modify ASSIGNING <fs_final_tds_modify2> WHERE bukrs1 EQ <fs_txgrp_d_c_ind1>-bukrs1
5429   *                                                                            AND   belnr  EQ <fs_txgrp_d_c_ind1>-belnr
5430   *                                                                            AND   gjahr  EQ <fs_txgrp_d_c_ind1>-gjahr
5431   *                                                                            AND   buzei  EQ <fs_txgrp_d_c_ind1>-buzei
5432   *                                                                            AND   txgrp  EQ <fs_txgrp_d_c_ind1>-txgrp
5433   *                                                                            AND   shkzg  EQ <fs_txgrp_d_c_ind1>-shkzg.
5434   *
5435   *                  IF <fs_final_tds_modify2>-igstrate NE 0
5436   *                    OR <fs_final_tds_modify2>-cgstrate NE 0
5437   *                    OR <fs_final_tds_modify2>-sgstrate NE 0.
5438   *                    <fs_final_tds_modify2>-sgstamount = <fs_final_tds_modify2>-sgstamount - lv_total_sgst_diff.
5439   *                  ENDIF.
5440   *                ENDLOOP.
5441   *              ENDIF.
5442   *
5443   *            ENDIF.
5444   *          ENDIF.
5445   *
5446   *        ENDLOOP.
5447   *      ENDIF.
5448   *      UNASSIGN <fs_txgrp_d_c_ind1>.
5449         "Commented by Anil Maurya
5450       ENDIF.
5451       CLEAR:LS_FINAL_TDS_TEMP.
5452     ENDLOOP.
5453
5454     CLEAR: GT_FINAL_TDS.
5455     GT_FINAL_TDS = LT_FINAL_TDS_MODIFY.
5456
5457
5458     LOOP AT GT_FINAL_TDS ASSIGNING <FS_FINAL_TDS>.
5459       IF <FS_FINAL_TDS>-TAXABLEVALUE IS NOT INITIAL OR <FS_FINAL_TDS>-IGSTAMOUNT IS NOT INITIAL
5460       OR <FS_FINAL_TDS>-CGSTAMOUNT IS NOT INITIAL OR <FS_FINAL_TDS>-SGSTAMOUNT IS NOT INITIAL
5461       OR <FS_FINAL_TDS>-CESSAMOUNT IS NOT INITIAL.
5462         <FS_FINAL_TDS>-INVOICE_VAL = <FS_FINAL_TDS>-TAXABLEVALUE +
5463                                      <FS_FINAL_TDS>-IGSTAMOUNT +
5464                                      <FS_FINAL_TDS>-CGSTAMOUNT +
5465                                      <FS_FINAL_TDS>-SGSTAMOUNT +
5466                                      <FS_FINAL_TDS>-CESSAMOUNT.
5467       ENDIF.
5468
5469
5470     ENDLOOP.
5471     UNASSIGN <FS_FINAL_TDS>.
5472
5473     LOOP AT GT_FINAL_TDS ASSIGNING <FS_FINAL_TDS>.
5474       <FS_FINAL_TDS>-TAXABLEVALUE = ABS( <FS_FINAL_TDS>-TAXABLEVALUE ).
5475       <FS_FINAL_TDS>-IGSTAMOUNT = ABS( <FS_FINAL_TDS>-IGSTAMOUNT ).
5476       <FS_FINAL_TDS>-IGSTRATE = ABS( <FS_FINAL_TDS>-IGSTRATE ).
5477       <FS_FINAL_TDS>-CGSTAMOUNT = ABS( <FS_FINAL_TDS>-CGSTAMOUNT ).
5478       <FS_FINAL_TDS>-CGSTRATE = ABS( <FS_FINAL_TDS>-CGSTRATE ).
5479       <FS_FINAL_TDS>-SGSTAMOUNT = ABS( <FS_FINAL_TDS>-SGSTAMOUNT ).
5480       <FS_FINAL_TDS>-SGSTRATE = ABS( <FS_FINAL_TDS>-SGSTRATE ).
5481       <FS_FINAL_TDS>-CESSRATE = ABS( <FS_FINAL_TDS>-CESSRATE ).
5482       <FS_FINAL_TDS>-CESSAMOUNT = ABS( <FS_FINAL_TDS>-CESSAMOUNT ).
5483       <FS_FINAL_TDS>-INVOICE_VAL = ABS( <FS_FINAL_TDS>-INVOICE_VAL ).
5484
5485       CONCATENATE <FS_FINAL_TDS>-BUDAT+4(2)  <FS_FINAL_TDS>-BUDAT+0(4) INTO  <FS_FINAL_TDS>-RETURN_PERIOD.
5486
5487       IF <FS_FINAL_TDS>-IGSTAMOUNT IS INITIAL
5488       AND <FS_FINAL_TDS>-CGSTAMOUNT IS INITIAL
5489       AND <FS_FINAL_TDS>-SGSTAMOUNT IS INITIAL.
5490
5491         CLEAR: <FS_FINAL_TDS>-GST_DEDU.
5492       ENDIF.
5493     ENDLOOP.
5494     UNASSIGN <FS_FINAL_TDS>.
5495
5496     SORT GT_FINAL_TDS BY BUKRS1 BELNR GJAHR TAXABLEVALUE DESCENDING.
5497     SORT GT_FINAL_TDS BY BUKRS1 BELNR GJAHR TDS_AMOUNT DESCENDING.
5498
5499     "AM-30-03-24
5500     IF LT_DEL_BEL_K[] IS NOT INITIAL.
5501       APPEND LINES OF LT_DEL_BEL_K TO LT_DEL_BEL.
5502       SORT LT_DEL_BEL BY BUKRS BELNR GJAHR.
5503       DELETE ADJACENT DUPLICATES FROM LT_DEL_BEL COMPARING BUKRS BELNR GJAHR.
5504     ENDIF.
5505     "AM-30-03-24
5506
5507     LOOP AT LT_DEL_BEL INTO LS_DEL_BEL.
5508       LS_UPD-BELNR = LS_DEL_BEL-BELNR.
5509       LS_UPD-BUKRS = LS_DEL_BEL-BUKRS.
5510       LS_UPD-GJAHR = LS_DEL_BEL-GJAHR.
5511       LS_UPD-FLAG = 'I'.
5512       IF LS_DEL_BEL-FLAG = ' '.
5513         LS_UPD-TEXT = 'Reversal of Not relevant Original Document'.
5514       ELSE.
5515         READ TABLE LT_DEL_BEL_K INTO DATA(LS_DEL_BEL_K) WITH KEY BUKRS = LS_DEL_BEL-BUKRS
5516                                                                  BELNR = LS_DEL_BEL-BELNR
5517                                                                  GJAHR = LS_DEL_BEL-GJAHR BINARY SEARCH.
5518         IF SY-SUBRC = 0.
5519           LS_UPD-TEXT = 'Vendor Clearing'.
5520         ELSE.
5521           LS_UPD-TEXT = 'Vendor to Vendor posting'.
5522         ENDIF.
5523
5524       ENDIF.
5525       APPEND LS_UPD TO LT_UPD.
5526       CLEAR:LS_UPD, LS_DEL_BEL.
5527     ENDLOOP.
5528
5529
5530     IF LT_BSEG[] IS NOT INITIAL.
5531       SELECT  MATNR, ALAND, TAXIM FROM MLAN FOR ALL ENTRIES IN
5532       @LT_BSEG WHERE MATNR = @LT_BSEG-MATNR
5533        INTO TABLE @LT_MLAN.
5534       IF SY-SUBRC = 0.
5535         SORT LT_MLAN BY MATNR ALAND TAXIM.
5536         "AM-01-04-24
5537   *      LT_MLAN_T  = VALUE #( FOR WA
5538   *                           IN LT_MLAN
5539   *                           ( MATNR = |{  WA-MATNR ALPHA = OUT }|
5540   *                             ALAND  =  WA-ALAND
5541   *                            TAXIM =  WA-TAXIM    )
5542   *                         ).
5543   *      CLEAR LT_MLAN.
5544   *      LOOP AT LT_MLAN_T INTO DATA(LS_MLAN_T).
5545   *        SHIFT LS_MLAN_T-MATNR  LEFT DELETING LEADING '0'.
5546   *        APPEND  LS_MLAN_T TO LT_MLAN.
5547   *        CLEAR LS_MLAN_T.
5548   *      ENDLOOP.
5549         "AM-01-04-24
5550
5551       ENDIF.
5552     ENDIF.
5553
5554     IF LT_MLAN[] IS NOT INITIAL.
5555       SORT LT_MLAN BY MATNR ALAND.
5556     ENDIF.
5557
5558     SELECT WERKS, SEZ_PLANT
5559     FROM ZEYTDS_SEZMAP
5560     FOR ALL ENTRIES IN @LT_BSEG
5561     WHERE WERKS = @LT_BSEG-WERKS
5562    INTO TABLE @DATA(LT_SEZ).
5563     IF SY-SUBRC IS INITIAL.
5564       SORT LT_SEZ BY WERKS.
5565     ENDIF.
5566
5567     DATA LV_ORN TYPE BKPF-BELNR.
5568
5569     LOOP AT GT_FINAL_TDS INTO GS_FINAL_TDS.
5570       IF ( GS_FINAL_TDS-SUPPLY_TYPE = 'CAN' OR GS_FINAL_TDS-SUPPLY_TYPE = 'REV' ).
5571       ELSE.
5572         CLEAR: GS_FINAL_TDS-SUPPLY_TYPE, LV_DEDUCTES_CODE.
5573         LV_DEDUCTES_CODE = GS_FINAL_TDS-DEDUCTEE_CODE.
5574
5575         LV_DEDUCTES_CODE = |{  LV_DEDUCTES_CODE ALPHA = IN }|.
5576
5577         IF LV_DEDUCTES_CODE IS INITIAL.
5578           READ TABLE LT_BSEG_K INTO LS_BSEG WITH KEY BUKRS = GS_FINAL_TDS-BUKRS1
5579                                                      BELNR = GS_FINAL_TDS-BELNR
5580                                                      GJAHR = GS_FINAL_TDS-GJAHR.
5581           IF SY-SUBRC EQ 0.
5582             READ TABLE LT_LFA1 INTO LS_LFA1 WITH KEY LIFNR = LS_BSEG-LIFNR.
5583             IF SY-SUBRC EQ 0 AND LS_LFA1-LAND1 <> 'IN'.
5584               LV_DEDUCTES_CODE = LS_BSEG-LIFNR.
5585               CLEAR LS_LFA1.
5586             ENDIF.
5587           ENDIF.
5588         ENDIF.
5589
5590         CLEAR LS_LFA1.
5591         READ TABLE LT_LFA1 INTO LS_LFA1 WITH KEY LIFNR = LV_DEDUCTES_CODE BINARY SEARCH.
5592         IF SY-SUBRC = 0 AND ( LS_LFA1-LAND1 = 'IN' ).
5593           CLEAR  LV_WERKS.
5594           LV_WERKS = GS_FINAL_TDS-PLANT.
5595           READ TABLE LT_SEZ INTO DATA(LS_SEZ) WITH KEY WERKS = LV_WERKS BINARY SEARCH.
5596           IF SY-SUBRC = 0 AND LS_SEZ-SEZ_PLANT = 'X'.
5597             CASE GS_FINAL_TDS-ITEM_CAT.
5598               WHEN '9'.
5599                 GS_FINAL_TDS-SUPPLY_TYPE = 'SEZS'.
5600               WHEN OTHERS.
5601                 GS_FINAL_TDS-SUPPLY_TYPE = 'SEZG'.
5602             ENDCASE.
5603           ENDIF.
5604           READ TABLE LT_J_1IMOVEND INTO LS_J_1IMOVEND WITH KEY LIFNR = LS_LFA1-LIFNR BINARY SEARCH.
5605           IF SY-SUBRC = 0 AND LS_J_1IMOVEND-VEN_CLASS = '1'.
5606             GS_FINAL_TDS-SUPPLY_TYPE = 'COM'.
5607           ENDIF.
5608         ELSEIF LS_LFA1-LAND1 = 'IN' .
5609           GS_FINAL_TDS-SUPPLY_TYPE = 'COM'.
5610         ELSE.
5611
5612           CLEAR  LV_WERKS.
5613           LV_WERKS = GS_FINAL_TDS-PLANT.
5614
5615           IF LS_LFA1-LAND1 = 'IN'.
5616             READ TABLE LT_SEZ TRANSPORTING NO FIELDS WITH KEY WERKS = LV_WERKS BINARY SEARCH.
5617             IF SY-SUBRC IS INITIAL.
5618               GS_FINAL_TDS-SUPPLY_TYPE = 'DTA'.
5619             ENDIF.
5620           ENDIF.
5621         ENDIF.
5622
5623
5624         IF GS_FINAL_TDS-SUPPLY_TYPE IS INITIAL AND GS_FINAL_TDS-ITEM_CAT IS INITIAL.
5625           READ TABLE LT_LFA1 INTO LS_LFA1 WITH KEY LIFNR = LV_DEDUCTES_CODE BINARY SEARCH.
5626           IF SY-SUBRC IS INITIAL AND LS_LFA1-LAND1 <> 'IN'.
5627             GS_FINAL_TDS-SUPPLY_TYPE = 'TAX'.
5628           ENDIF.
5629         ELSE.
5630           IF GS_FINAL_TDS-ITEM_CAT IS NOT INITIAL.
5631             READ TABLE LT_LFA1 INTO LS_LFA1 WITH KEY LIFNR = LV_DEDUCTES_CODE BINARY SEARCH.
5632             IF SY-SUBRC = 0.
5633               IF LS_LFA1-LAND1 NE 'IN' AND GS_FINAL_TDS-ITEM_CAT EQ '9'.
5634                 GS_FINAL_TDS-SUPPLY_TYPE = 'IMPS'.
5635               ELSEIF LS_LFA1-LAND1 NE 'IN' AND GS_FINAL_TDS-ITEM_CAT NE '9'.
5636                 GS_FINAL_TDS-SUPPLY_TYPE = 'IMPG'.
5637               ELSE.
5638
5639                 READ TABLE LT_BSEG_K INTO DATA(LS_BSEG_KL) WITH KEY BUKRS = GS_FINAL_TDS-BUKRS1
5640                                                                     BELNR = GS_FINAL_TDS-BELNR
5641                                                                     GJAHR =  GS_FINAL_TDS-GJAHR.
5642                 IF LS_BSEG_KL-XREVERSAL = '2' OR LS_BSEG_KL-TCODE = 'MR8M'.
5643                   GS_FINAL_TDS-SUPPLY_TYPE = 'CAN'.
5644                 ENDIF.
5645               ENDIF.
5646               IF GS_FINAL_TDS-SUPPLY_TYPE = 'IMPG' OR GS_FINAL_TDS-SUPPLY_TYPE = 'IMPS'.
5647
5648                 READ TABLE LT_BSEG_K INTO DATA(LS_BSEG_K2) WITH KEY BUKRS = GS_FINAL_TDS-BUKRS1
5649                                                                     BELNR = GS_FINAL_TDS-BELNR
5650                                                                     GJAHR = GS_FINAL_TDS-GJAHR.
5651                 IF SY-SUBRC IS INITIAL.
5652                   IF LS_BSEG_K2-XREVERSAL = '2' OR LS_BSEG_K2-TCODE = 'MR8M'.
5653                     GS_FINAL_TDS-SUPPLY_TYPE = 'CAN'.
5654                   ENDIF.
5655                 ENDIF.
5656               ENDIF.
5657             ENDIF.
5658           ENDIF.
5659         ENDIF.
5660
5661         IF GS_FINAL_TDS-SUPPLY_TYPE IS INITIAL.
5662           IF ( GS_FINAL_TDS-IGSTAMOUNT IS INITIAL
5663           AND GS_FINAL_TDS-CGSTAMOUNT IS INITIAL
5664           AND GS_FINAL_TDS-SGSTAMOUNT IS INITIAL ).
5665             READ TABLE LT_LFA1 INTO LS_LFA1 WITH KEY LIFNR = LV_DEDUCTES_CODE BINARY SEARCH.
5666             IF SY-SUBRC IS INITIAL AND GS_FINAL_TDS-ITEM_CODE IS NOT INITIAL.
5667               CLEAR LV_MATNR.
5668   *            LV_MATNR = |{ GS_FINAL_TDS-ITEM_CODE ALPHA = IN }|.
5669               READ TABLE LT_MLAN INTO LS_MLAN WITH KEY MATNR =  GS_FINAL_TDS-ITEM_CODE
5670                                                        ALAND = LS_LFA1-LAND1 BINARY SEARCH.
5671               IF SY-SUBRC IS INITIAL .
5672                 CASE LS_MLAN-TAXIM.
5673                   WHEN '0' OR ' '.
5674
5675                     GS_FINAL_TDS-SUPPLY_TYPE = 'NIL'.
5676                   WHEN '1'.
5677                     GS_FINAL_TDS-SUPPLY_TYPE = 'EXT'.
5678                   WHEN '2'.
5679                     GS_FINAL_TDS-SUPPLY_TYPE = 'NON'.
5680                 ENDCASE.
5681               ENDIF.
5682
5683             ELSE.
5684               GS_FINAL_TDS-SUPPLY_TYPE = 'NIL'.
5685             ENDIF.
5686           ENDIF.
5687         ENDIF.
5688
5689         IF LS_LFA1-LAND1 EQ 'IN'.        " zubair 18.3.24
5690           IF ( GS_FINAL_TDS-IGSTAMOUNT IS NOT INITIAL
5691           OR GS_FINAL_TDS-CGSTAMOUNT IS NOT INITIAL
5692           OR GS_FINAL_TDS-SGSTAMOUNT IS NOT INITIAL ).
5693             READ TABLE LT_LFA1 INTO LS_LFA1 WITH KEY LIFNR =  LV_DEDUCTES_CODE.
5694             IF SY-SUBRC IS INITIAL AND GS_FINAL_TDS-ITEM_CODE IS NOT INITIAL.
5695               CLEAR LV_MATNR.
5696   *          LV_MATNR = |{ GS_FINAL_TDS-ITEM_CODE ALPHA = IN }|.
5697   *            LV_MATNR = |{ GS_FINAL_TDS-ITEM_CODE ALPHA = OUT }|.
5698
5699               READ TABLE LT_MLAN INTO LS_MLAN WITH KEY MATNR = GS_FINAL_TDS-ITEM_CODE
5700               ALAND = LS_LFA1-LAND1 BINARY SEARCH.
5701               IF SY-SUBRC IS INITIAL AND ( LS_MLAN-TAXIM EQ 0 OR LS_MLAN-TAXIM EQ '' ).
5702                 GS_FINAL_TDS-SUPPLY_TYPE = 'TAX'.
5703               ELSE.
5704                 GS_FINAL_TDS-SUPPLY_TYPE = 'NIL'.
5705               ENDIF.
5706             ELSE.
5707               IF GS_FINAL_TDS-SUPPLY_TYPE IS INITIAL.
5708                 GS_FINAL_TDS-SUPPLY_TYPE = 'TAX'.
5709               ENDIF.
5710             ENDIF.
5711           ENDIF.
5712         ENDIF.
5713
5714   *      IF ( gs_final_tds-igstamount IS NOT INITIAL
5715   *      OR gs_final_tds-cgstamount IS NOT INITIAL
5716   *      OR gs_final_tds-sgstamount IS NOT INITIAL ).
5717   *        READ TABLE lt_lfa1 INTO ls_lfa1 WITH KEY lifnr =  lv_deductes_code.
5718   *        IF sy-subrc IS INITIAL AND gs_final_tds-item_code IS NOT INITIAL.
5719   *          IF gs_final_tds-item_code IS NOT INITIAL.
5720   *            CLEAR lv_matnr.
5721   *            lv_matnr = gs_final_tds-item_code.
5722   *            CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
5723   *              EXPORTING
5724   *                input  = lv_matnr
5725   *              IMPORTING
5726   *                output = lv_matnr.
5727   *            READ TABLE lt_mlan INTO ls_mlan
5728   **                               WITH KEY matnr = |{ gs_final_tds-item_code ALPHA = IN }|
5729   *                               WITH KEY matnr = lv_matnr
5730   *                                        aland = ls_lfa1-land1.
5731   *            IF sy-subrc IS INITIAL.
5732   *              IF ls_mlan-taxim EQ 0 OR ls_mlan-taxim EQ ''.
5733   *                gs_final_tds-supply_type = 'TAX'.
5734   *              ELSE.
5735   *                gs_final_tds-supply_type = 'NIL'.
5736   *              ENDIF.
5737   *            ENDIF.
5738   *          ELSE.
5739   *            gs_final_tds-supply_type = 'TAX'.
5740   *          ENDIF.
5741   *        ENDIF.
5742   *      ENDIF.
5743
5744       ENDIF.
5745
5746       IF GS_FINAL_TDS-ITC_ELIGBLTY_IND IS INITIAL.
5747         IF GS_FINAL_TDS-IGSTAMOUNT > 0 OR GS_FINAL_TDS-CGSTAMOUNT > 0 OR GS_FINAL_TDS-SGSTAMOUNT > 0.
5748           IF GS_FINAL_TDS-HSN_SAC_CODE+0(2) <> '99'.
5749             GS_FINAL_TDS-ITC_ELIGBLTY_IND = 'IG'.
5750           ELSE.
5751             GS_FINAL_TDS-ITC_ELIGBLTY_IND = 'IS'.
5752           ENDIF.
5753         ELSE.
5754           GS_FINAL_TDS-ITC_ELIGBLTY_IND = 'NO'.
5755         ENDIF.
5756
5757         READ TABLE LT_BSEG  TRANSPORTING NO FIELDS WITH KEY BUKRS = GS_FINAL_TDS-BUKRS1
5758                                                          BELNR = GS_FINAL_TDS-BELNR
5759                                                          GJAHR = GS_FINAL_TDS-GJAHR
5760                                                          KOART = 'A'.
5761         IF SY-SUBRC EQ 0.
5762           GS_FINAL_TDS-ITC_ELIGBLTY_IND  = 'CG'.
5763         ENDIF.
5764
5765       ENDIF.
5766
5767       IF GS_FINAL_TDS-SUPPLY_TYPE = 'IMPG'.
5768         CLEAR:LV_EBELN, LV_EBELP.
5769
5770         LV_EBELN = GS_FINAL_TDS-PO_NUMBER.
5771         LV_EBELP = GS_FINAL_TDS-PO_LINE_ITEM.
5772         LV_EBELP = |{ LV_EBELP ALPHA = IN }|.
5773         READ TABLE LT_BSEG_W INTO DATA(LS_BSEG_CUS) WITH KEY BUKRS = GS_FINAL_TDS-BUKRS1
5774         BELNR = GS_FINAL_TDS-BELNR
5775         GJAHR = GS_FINAL_TDS-GJAHR
5776         BUZEI = GS_FINAL_TDS-BUZEI
5777         EBELN = LV_EBELN
5778         EBELP = LV_EBELP.
5779         IF SY-SUBRC IS INITIAL .
5780           GS_FINAL_TDS-CUSTOM_DUTY = LS_BSEG_CUS-DMBTR.
5781         ENDIF.
5782       ENDIF.
5783
5784
5785
5786       CLEAR LS_TDS_SEC.
5787       IF  GS_FINAL_TDS-TDS_TAX IS NOT INITIAL   AND  GS_FINAL_TDS-TDS_TAX_CODE_ERP IS NOT INITIAL.
5788
5789         READ TABLE LT_TDS_SEC INTO LS_TDS_SEC WITH KEY WITHT = GS_FINAL_TDS-TDS_TAX
5790                                                    WT_WITHCD =    GS_FINAL_TDS-TDS_TAX_CODE_ERP.
5791         IF SY-SUBRC EQ 0 AND LS_TDS_SEC-APPL IS INITIAL.
5792           CLEAR:  GS_FINAL_TDS-TDS_TAX_CODE_ERP, GS_FINAL_TDS-TDS_SECTION,  GS_FINAL_TDS-TDS_AMOUNT,
5793                  GS_FINAL_TDS-GROSSUPINDICATOR,
5794                  GS_FINAL_TDS-TDS_BASE_VAL, GS_FINAL_TDS-TDSREMITTANCEDATE, GS_FINAL_TDS-TDS_TAX,
5795                  GS_FINAL_TDS-EXEMP_NUM, GS_FINAL_TDS-EXEMP_RATE, GS_FINAL_TDS-USER1, GS_FINAL_TDS-USER2,
5796                  GS_FINAL_TDS-USER3,
5797                   GS_FINAL_TDS-TDS_RATE. " Zubair 27.3.24
5798         ENDIF.
5799       ENDIF.
5800
5801
5802
5803       IF ( GS_FINAL_TDS-ITEM_CAT = '0' OR GS_FINAL_TDS-ITEM_CAT = '9' )
5804         AND GS_FINAL_TDS-PO_NUMBER IS NOT INITIAL.
5805         READ TABLE LT_EKPO_TEMP1 INTO DATA(LS_EKPO_TEMP1) WITH KEY EBELN =  |{ GS_FINAL_TDS-PO_NUMBER ALPHA = IN }|
5806         EBELP  =  |{  GS_FINAL_TDS-PO_LINE_ITEM ALPHA = IN }|  BINARY SEARCH.
5807         IF SY-SUBRC = 0.
5808           READ TABLE IT_EKKN1 INTO DATA(LS_EKKN1) WITH KEY EBELN = LS_EKPO_TEMP1-EBELN
5809           EBELP = LS_EKPO_TEMP1-EBELP.
5810           IF SY-SUBRC = 0.
5811             READ TABLE LT_ANLA INTO DATA(LS_ANLA) WITH KEY ANLN1 = LS_EKKN1-ANLN1 BINARY SEARCH.
5812             IF SY-SUBRC = 0.
5813               READ TABLE LT_T095 INTO DATA(LS_T095) WITH KEY KTOGR = LS_ANLA-KTOGR BINARY SEARCH.
5814               IF SY-SUBRC = 0.
5815                 CLEAR LS_SKAT.
5816                 READ TABLE IT_SKAT_T1 INTO LS_SKAT WITH KEY SAKNR = LS_T095-KTANSW BINARY SEARCH.
5817                 IF SY-SUBRC = 0.
5818                   GS_FINAL_TDS-GL_ACC_CODE = |{ LS_SKAT-SAKNR ALPHA = OUT }| .
5819                   GS_FINAL_TDS-GL_ACC_NAME = LS_SKAT-TXT50.
5820                 ENDIF.
5821                 CLEAR LS_T095.
5822               ENDIF.
5823               CLEAR LS_ANLA.
5824             ENDIF.
5825             CLEAR LS_EKKN1.
5826           ENDIF.
5827           CLEAR LS_EKPO_TEMP1.
5828         ENDIF.
5829       ENDIF.
5830   * "EOC added by anil maurya on 10.01.24
5831
5832       MODIFY GT_FINAL_TDS FROM GS_FINAL_TDS.
5833       CLEAR: GS_FINAL_TDS.
5834     ENDLOOP.
5835
5836
5837     LOOP AT GT_FINAL_TDS ASSIGNING <GS_FINAL>.
5838       GS_PRO3-BUKRS = <GS_FINAL>-BUKRS1.
5839       GS_PRO3-BELNR = <GS_FINAL>-BELNR.
5840       GS_PRO3-GJAHR = <GS_FINAL>-GJAHR.
5841       GS_PRO3-TAXABLEVALUE = <GS_FINAL>-TAXABLEVALUE.
5842       COLLECT GS_PRO3 INTO GT_PRO3.
5843       CLEAR : GS_PRO3.
5844     ENDLOOP.
5845
5846     SORT GT_PRO3 BY BUKRS BELNR GJAHR.
5847
5848
5849     DATA: LV_ERP_NUM TYPE ZEYTDS_INV_EXT_N-ERP_NUM,
5850           LV_AMT     TYPE BSEG-DMBTR.
5851
5852     LOOP AT  GT_FINAL_TDS ASSIGNING FIELD-SYMBOL(<FS_TDS>).
5853       ""AM-30-04-24
5854       IF <FS_TDS>-ITEM_CODE CO '1234567890'.
5855         SHIFT <FS_TDS>-ITEM_CODE LEFT DELETING LEADING '0'.
5856       ENDIF.
5857
5858       SHIFT <FS_TDS>-GL_ACC_CODE LEFT DELETING LEADING '0'.
5859       ""AM-30-04-24
5860
5861       CLEAR:LV_ERP_NUM.
5862       LV_ERP_NUM = |{  <FS_TDS>-ERP_NUM ALPHA = IN }|.
5863
5864       "No DP Scenario
5865       CLEAR:LS_BSEG_A.
5866       LOOP AT LT_BSEG_A INTO LS_BSEG_A WHERE BUKRS = <FS_TDS>-COMPANY_CODE
5867                                        AND   BELNR = LV_ERP_NUM
5868                                        AND   GJAHR = P_GJAHR.
5869
5870         IF LS_BSEG_A-KTOSL = 'WIT'.
5871
5872           CLEAR:LS_WITH_ITEM.
5873           READ TABLE LT_WITH_ITEM_TEMP INTO LS_WITH_ITEM WITH KEY BUKRS = LS_BSEG_A-BUKRS
5874                                                              BELNR = LS_BSEG_A-BELNR
5875                                                              GJAHR = LS_BSEG_A-GJAHR
5876                                                              J_1IBUZEI = LS_BSEG_A-BUZEI
5877                                                              WITHT     = <FS_TDS>-TDS_TAX "AM-26.03.24
5878                                                              WT_WITHCD = <FS_TDS>-TDS_TAX_CODE_ERP. "AM-26.03.24
5879           IF SY-SUBRC = 0.
5880             READ TABLE LT_T059Z INTO LS_T059Z WITH KEY WITHT     = LS_WITH_ITEM-WITHT
5881                                                WT_WITHCD = LS_WITH_ITEM-WT_WITHCD
5882                                                BINARY SEARCH.
5883             IF SY-SUBRC = 0.
5884               <FS_TDS>-USER1 = LS_T059Z-QSCOD.
5885             ENDIF.
5886
5887             <FS_TDS>-USER2 = |{ LS_WITH_ITEM-HKONT ALPHA = OUT }|.
5888
5889             CLEAR:S_SKAT.
5890             READ TABLE IT_SKAT INTO S_SKAT WITH KEY SAKNR = LS_WITH_ITEM-HKONT.
5891             IF SY-SUBRC EQ 0.
5892               <FS_TDS>-USER3 = S_SKAT-TXT50.
5893             ENDIF.
5894           ENDIF.
5895
5896
5897         ELSE.
5898
5899   *        IF <FS_TDS>-USER2 IS INITIAL OR <FS_TDS>-USER3 IS INITIAL.
5900   *
5901   *          CLEAR:GS_ZEYTDS_TDS_GL.
5902   *          READ TABLE GT_ZEYTDS_TDS_GL INTO GS_ZEYTDS_TDS_GL WITH KEY BUKRS = LS_BSEG_A-BUKRS
5903   *                                                               HKONT = LS_BSEG_A-HKONT
5904   *                                                               GL_TYPE = 'TDS'.
5905   *          IF SY-SUBRC EQ 0.
5906   *            <FS_TDS>-TDS_AMOUNT = LS_BSEG_A-DMBTR.
5907   *            <FS_TDS>-USER1 = 'DP'.
5908   *            <FS_TDS>-USER2 = |{ LS_BSEG_A-HKONT ALPHA = OUT }|.
5909   *
5910   *            CLEAR:S_SKAT.
5911   *            READ TABLE IT_SKAT INTO S_SKAT WITH KEY SAKNR = GS_ZEYTDS_TDS_GL-HKONT.
5912   *            IF SY-SUBRC EQ 0.
5913   *              <FS_TDS>-USER3 = S_SKAT-TXT50.
5914   *            ENDIF.
5915   *          ENDIF.
5916   *        ENDIF.
5917
5918           CLEAR:GS_ZEYTDS_TDS_GL.
5919           READ TABLE GT_ZEYTDS_TDS_GL INTO GS_ZEYTDS_TDS_GL WITH KEY BUKRS = LS_BSEG_A-BUKRS
5920                                                                HKONT = LS_BSEG_A-HKONT
5921                                                                GL_TYPE = 'TDS'.
5922           IF SY-SUBRC EQ 0.
5923
5924
5925             READ TABLE GT_PRO3 INTO GS_PRO3 WITH KEY BUKRS = <FS_TDS>-BUKRS1
5926                                               BELNR = <FS_TDS>-BELNR
5927                                               GJAHR = <FS_TDS>-GJAHR BINARY SEARCH.
5928             IF SY-SUBRC = 0 AND  ( GS_PRO3-TAXABLEVALUE IS NOT INITIAL OR GS_PRO3-TAXABLEVALUE > '0.00' ).
5929               CLEAR LV_AMT .
5930               LV_AMT  = ( <FS_TDS>-TAXABLEVALUE / GS_PRO3-TAXABLEVALUE ) * LS_BSEG_A-DMBTR  .
5931               <FS_TDS>-TDS_AMOUNT = LV_AMT .
5932             ENDIF.
5933
5934             IF ( <FS_TDS>-TAXABLEVALUE IS INITIAL OR <FS_TDS>-TAXABLEVALUE = '0.00' ).
5935               IF LS_BSEG_A-SHKZG = 'H'.
5936                 <FS_TDS>-TDS_AMOUNT =  <FS_TDS>-TDS_AMOUNT + LS_BSEG_A-DMBTR * ( -1 ) .
5937               ELSE.
5938                 <FS_TDS>-TDS_AMOUNT =  <FS_TDS>-TDS_AMOUNT +  LS_BSEG_A-DMBTR .
5939               ENDIF.
5940
5941               DELETE TABLE LT_BSEG_A FROM LS_BSEG_A.
5942             ENDIF.
5943
5944             <FS_TDS>-USER1 = 'DP'.
5945             <FS_TDS>-USER2 = |{ LS_BSEG_A-HKONT ALPHA = OUT }|.
5946
5947             CLEAR:S_SKAT.
5948             READ TABLE IT_SKAT INTO S_SKAT WITH KEY SAKNR = GS_ZEYTDS_TDS_GL-HKONT.
5949             IF SY-SUBRC EQ 0.
5950               <FS_TDS>-USER3 = S_SKAT-TXT50.
5951             ENDIF.
5952           ENDIF.
5953
5954         ENDIF.
5955
5956       ENDLOOP.
5957       IF <FS_TDS>-TDS_AMOUNT < '0.00'.
5958         <FS_TDS>-TDS_AMOUNT  = <FS_TDS>-TDS_AMOUNT * ( -1 )  .
5959       ENDIF.
5960
5961       IF <FS_TDS>-TDS_TAX_CODE_ERP IS INITIAL  AND <FS_TDS>-TDS_TAX IS INITIAL AND <FS_TDS>-TDS_AMOUNT IS INITIAL.
5962         CLEAR: <FS_TDS>-USER1,  <FS_TDS>-USER2,  <FS_TDS>-USER3.
5963       ENDIF.
5964
5965   *    IF <FS_TDS>-TDS_TAX_CODE_ERP IS INITIAL OR <FS_TDS>-TDS_TAX IS INITIAL .
5966   *      CLEAR: <FS_TDS>-TDS_AMOUNT, <FS_TDS>-USER1, <FS_TDS>-USER2, <FS_TDS>-USER3.
5967   *    ENDIF.
5968
5969       "" soc zubair 20.3.24
5970       CLEAR LS_BSET_NEW.
5971       LOOP AT LT_BSET_NEW INTO LS_BSET_NEW WHERE BUKRS = <FS_TDS>-BUKRS1
5972                                                AND BELNR = <FS_TDS>-BELNR
5973                                                AND GJAHR = <FS_TDS>-GJAHR
5974                                                AND TXGRP = <FS_TDS>-TXGRP.
5975         CLEAR LS_RCMTAX.
5976         READ TABLE LT_RCMTAX INTO LS_RCMTAX WITH KEY  TAX_CODE = LS_BSET_NEW-MWSKZ.
5977         IF SY-SUBRC = 0  AND LS_RCMTAX-INDICATOR1 = 'X'.
5978           <FS_TDS>-RCM = 'Y'.
5979           EXIT.
5980         ELSE.
5981           <FS_TDS>-RCM = 'N'.
5982         ENDIF.
5983         CLEAR : LS_RCMTAX, LS_BSET_NEW.
5984       ENDLOOP.
5985
5986       "AM-26.03.24
5987       IF <FS_TDS>-RCM IS INITIAL.
5988         <FS_TDS>-RCM = 'N'.
5989       ENDIF.
5990       "AM-26.03.24
5991
5992   *    IF <FS_TDS>-IGSTAMOUNT IS INITIAL AND <FS_TDS>-CGSTAMOUNT IS INITIAL AND <FS_TDS>-SGSTAMOUNT IS INITIAL
5993   *      AND <FS_TDS>-CESSAMOUNT IS INITIAL AND <FS_TDS>-TDS_AMOUNT IS INITIAL.
5994   *      <FS_TDS>-RCM = 'N'.
5995   *    ENDIF.
5996       " eoc zubair 20.3.24
5997
5998     ENDLOOP.
5999     UNASSIGN <FS_TDS>.
6000
6001     IF LT_UPD IS NOT INITIAL.
6002       MODIFY ZEYTDS_RESON_STR FROM TABLE LT_UPD.
6003     ENDIF.
6004
6005   ENDFORM.                    "generate_invoice_data
6006   *&---------------------------------------------------------------------*
6007   *&      Form  DISPLAY_ALV_REPORT
6008   *&---------------------------------------------------------------------*
6009   *       text
6010   *----------------------------------------------------------------------*
6011   *  -->  p1        text
6012   *  <--  p2        text
6013   *----------------------------------------------------------------------*
6014   FORM DISPLAY_ALV_REPORT .
6015
6016     TYPES: BEGIN OF TY_DEL,
6017              BELNR TYPE BKPF-BELNR,
6018              BUKRS TYPE BKPF-BUKRS,
6019            END OF TY_DEL.
6020
6021     DATA: LV_CHAR(255),
6022           LT_FCAT       TYPE SLIS_T_FIELDCAT_ALV,
6023           LS_FCAT       TYPE SLIS_FIELDCAT_ALV,
6024           LT_HEAD       TYPE STANDARD TABLE OF TY_HEAD,
6025           LS_HEAD       TYPE TY_HEAD,
6026           LS_HEAD1      TYPE TY_HEAD,
6027           LV_COUNT      TYPE I,
6028           LS_FINAL      TYPE ZEYTDS_INV_EXT_N,
6029           GT_FINAL1     TYPE STANDARD TABLE OF ZEYTDS_INV_EXT_N,
6030           LR_RTTI_STRUC TYPE REF TO CL_ABAP_STRUCTDESCR,
6031           LT_DDFIELDS   TYPE DDFIELDS,
6032           LS_DDFIELDS   LIKE LINE OF LT_DDFIELDS,
6033           LV_STRU       TYPE CHAR20,
6034           TEXT1         TYPE CHAR100,
6035           CORR_STRING   TYPE CHAR100,
6036           GT_TDS_TEMP   TYPE TABLE OF ZEYTDS_INV_EXT_N,
6037           GT_TDS_TEMP1  TYPE TABLE OF ZEYTDS_INV_EXT_N,
6038           GS_TDS_TEMP   TYPE ZEYTDS_INV_EXT_N,
6039           GS_TDS_TEMP1  TYPE  ZEYTDS_INV_EXT_N,
6040           R_VEN         TYPE RANGE OF LFA1-LIFNR,
6041           LS_R_VEN      LIKE LINE OF R_VEN,
6042           R_BUKRS       TYPE RANGE OF BKPF-BUKRS,
6043           LS_R_BUKRS    LIKE LINE OF R_BUKRS,
6044           LT_DET        TYPE TABLE OF TY_DEL,
6045           LS_DET        TYPE TY_DEL,
6046           LT_FINAL      TYPE TABLE OF ZEYTDS_INV_EXT_N,
6047           LT_FINAL_TEMP TYPE TABLE OF ZEYTDS_INV_EXT_N,
6048           COUNT         TYPE I,
6049           LR_DATA       TYPE REF TO DATA,
6050           LT_FBL1N      TYPE TABLE OF RFPOSXEXT,
6051           R_BUDAT       TYPE RANGE OF BKPF-BUDAT,
6052           LS_R_BUDAT    LIKE LINE OF R_BUDAT,
6053           LT_FINAL_CNT  TYPE TABLE OF ZEYTDS_INV_EXT_N,
6054           LT_FINAL_CNT1 TYPE TABLE OF ZEYTDS_INV_EXT_N,
6055           LV_DATE1      TYPE STRING,
6056           LV_DATE2      TYPE STRING,
6057           LV_LOW        TYPE DATUM,
6058           LV_HIGH       TYPE DATUM,
6059           LV_DTE_LOW    TYPE DATUM,
6060           LV_DTE_HIGH   TYPE DATUM.
6061
6062
6063     FIELD-SYMBOLS: <FS_COMP>     TYPE ANY,
6064                    <FS_WORKAREA> TYPE ANY,
6065                    <LT_FBL1N>    TYPE /SAPPCE/RFPOSXEXT.
6066
6067     LV_STRU = 'ZEYTDS_INV_EXT_N'.
6068     LR_RTTI_STRUC ?= CL_ABAP_STRUCTDESCR=>DESCRIBE_BY_NAME( LV_STRU ).
6069     LT_DDFIELDS = LR_RTTI_STRUC->GET_DDIC_FIELD_LIST( ).
6070
6071     IF  GT_FINAL_TDS[] IS NOT INITIAL.
6072       LOOP AT GT_FINAL_TDS ASSIGNING FIELD-SYMBOL(<FS_FINAL>).
6073
6074         IF P_AL_XLS EQ 'X' OR P_LC_XLS EQ 'X'.
6075           REPLACE ALL OCCURRENCES OF '(' IN <FS_FINAL>-NAME_OF_DEDUCTEE WITH ' '.
6076           REPLACE ALL OCCURRENCES OF ')' IN <FS_FINAL>-NAME_OF_DEDUCTEE WITH ' '.
6077           CONDENSE <FS_FINAL>-NAME_OF_DEDUCTEE.
6078
6079           REPLACE ALL OCCURRENCES OF '(' IN <FS_FINAL>-COMPANY_TXT WITH ' '.
6080           REPLACE ALL OCCURRENCES OF ')' IN <FS_FINAL>-COMPANY_TXT WITH ' '.
6081           CONDENSE <FS_FINAL>-COMPANY_TXT.
6082
6083           REPLACE ALL OCCURRENCES OF '(' IN <FS_FINAL>-GL_ACC_NAME WITH ' '.
6084           REPLACE ALL OCCURRENCES OF ')' IN <FS_FINAL>-GL_ACC_NAME WITH ' '.
6085           CONDENSE <FS_FINAL>-GL_ACC_NAME.
6086
6087           REPLACE ALL OCCURRENCES OF '(' IN <FS_FINAL>-USERNAME WITH ' '.
6088           REPLACE ALL OCCURRENCES OF ')' IN <FS_FINAL>-USERNAME WITH ' '.
6089           CONDENSE <FS_FINAL>-USERNAME.
6090
6091           REPLACE ALL OCCURRENCES OF '(' IN <FS_FINAL>-HSN_SAC_DES WITH ' '.
6092           REPLACE ALL OCCURRENCES OF ')' IN <FS_FINAL>-HSN_SAC_DES WITH ' '.
6093           CONDENSE <FS_FINAL>-HSN_SAC_DES.
6094
6095           REPLACE ALL OCCURRENCES OF '(' IN <FS_FINAL>-PO_DESC WITH ' '.
6096           REPLACE ALL OCCURRENCES OF ')' IN <FS_FINAL>-PO_DESC WITH ' '.
6097           CONDENSE <FS_FINAL>-PO_DESC.
6098
6099           REPLACE ALL OCCURRENCES OF '(' IN <FS_FINAL>-USER3 WITH ' '.
6100           REPLACE ALL OCCURRENCES OF ')' IN <FS_FINAL>-USER3 WITH ' '.
6101           CONDENSE <FS_FINAL>-USER3.
6102
6103           REPLACE ALL OCCURRENCES OF '(' IN <FS_FINAL>-SERVICE_DES_INV WITH ' '.
6104           REPLACE ALL OCCURRENCES OF ')' IN <FS_FINAL>-SERVICE_DES_INV WITH ' '.
6105           CONDENSE <FS_FINAL>-SERVICE_DES_INV.
6106         ENDIF.
6107       ENDLOOP.
6108
6109
6110       CLEAR : LV_COUNT.
6111       CLEAR : GV_FILECOUNT.
6112       LOOP AT LT_DDFIELDS INTO LS_DDFIELDS.
6113         CLEAR LS_FCAT.
6114         LV_COUNT = LV_COUNT + 1.
6115         LS_FCAT-COL_POS   = LV_COUNT.
6116         LS_FCAT-FIELDNAME = LS_DDFIELDS-FIELDNAME.
6117         LS_FCAT-SELTEXT_L = LS_DDFIELDS-FIELDTEXT.
6118         LS_FCAT-DDIC_OUTPUTLEN = LS_DDFIELDS-OUTPUTLEN.
6119         LS_FCAT-TABNAME   = GC_TABLENAME_TDS.
6120         IF LS_FCAT-FIELDNAME = 'DEDUCTEE_ADD'.
6121           LS_FCAT-NO_OUT = 'X'.
6122         ENDIF.
6123         APPEND LS_FCAT TO LT_FCAT.
6124       ENDLOOP.
6125
6126
6127       LOOP AT GT_FINAL_TDS INTO GS_FINAL_TDS.
6128         MOVE-CORRESPONDING GS_FINAL_TDS TO GS_TDS.
6129         GS_TDS-CHAL_PAID_FLAG = 'Y'.     "
6130         APPEND GS_TDS TO GT_TDS.
6131       ENDLOOP.
6132
6133
6134
6135
6136       LOOP AT LT_FCAT INTO LS_FCAT.
6137         REPLACE ALL OCCURRENCES OF ',' IN LS_FCAT-SELTEXT_L WITH ''.
6138         CONCATENATE LS_HEAD1-HEAD LS_FCAT-SELTEXT_L ',' INTO LS_HEAD1-HEAD.
6139       ENDLOOP.
6140
6141       IF R_FILE = 'X'.
6142
6143         SORT GT_TDS BY DEDUCTOR_PAN DEDUCTOR_TAN.
6144         GT_TDS_TEMP = GT_TDS.
6145         DELETE ADJACENT DUPLICATES FROM GT_TDS COMPARING DEDUCTOR_PAN DEDUCTOR_TAN.
6146
6147         LOOP AT GT_TDS INTO LS_FINAL.
6148           LOOP AT GT_TDS_TEMP INTO GS_TDS_TEMP WHERE DEDUCTOR_PAN = LS_FINAL-DEDUCTOR_PAN AND DEDUCTOR_TAN = LS_FINAL-DEDUCTOR_TAN.
6149             MOVE-CORRESPONDING GS_TDS_TEMP TO GS_TDS_TEMP1.
6150             APPEND GS_TDS_TEMP1 TO GT_TDS_TEMP1.
6151             CLEAR:GS_TDS_TEMP,GS_TDS_TEMP1.
6152           ENDLOOP.
6153           IF R_LOCL = 'X'.
6154             CONCATENATE LS_FINAL-DEDUCTOR_PAN '_' LS_FINAL-DEDUCTOR_TAN INTO GV_FILE.
6155             ADD 1 TO GV_FILECOUNT.
6156             PERFORM XLSX_DOWNLOAD USING LT_FCAT GT_TDS_TEMP1.
6157           ENDIF.
6158           CLEAR:GT_TDS_TEMP1.
6159         ENDLOOP.
6160
6161         IF P_AL_XLS = 'X' AND R_AL11 = 'X'.
6162           REPLACE ALL OCCURRENCES OF ',' IN LS_HEAD1-HEAD WITH CL_ABAP_CHAR_UTILITIES=>HORIZONTAL_TAB.
6163         ENDIF.
6164
6165         LOOP AT GT_TDS INTO LS_FINAL.
6166           LOOP AT GT_TDS_TEMP INTO GS_TDS_TEMP WHERE DEDUCTOR_PAN = LS_FINAL-DEDUCTOR_PAN
6167             AND DEDUCTOR_TAN = LS_FINAL-DEDUCTOR_TAN.
6168
6169             REPLACE ALL OCCURRENCES OF '"' IN GS_TDS_TEMP-PO_DESC WITH ''.
6170             REPLACE ALL OCCURRENCES OF '"' IN GS_TDS_TEMP-SERVICE_DES_INV WITH ''.
6171             REPLACE ALL OCCURRENCES OF '"' IN GS_TDS_TEMP-COMPANY_TXT WITH ''.
6172             REPLACE ALL OCCURRENCES OF '"' IN GS_TDS_TEMP-NAME_OF_DEDUCTEE WITH ''.
6173             REPLACE ALL OCCURRENCES OF '"' IN GS_TDS_TEMP-HSN_SAC_DES WITH ''.
6174
6175             REPLACE ALL OCCURRENCES OF ',' IN GS_TDS_TEMP-PO_DESC WITH ''.
6176             REPLACE ALL OCCURRENCES OF ',' IN GS_TDS_TEMP-SERVICE_DES_INV WITH ''.
6177             REPLACE ALL OCCURRENCES OF ',' IN GS_TDS_TEMP-COMPANY_TXT WITH ''.
6178             REPLACE ALL OCCURRENCES OF ',' IN GS_TDS_TEMP-NAME_OF_DEDUCTEE WITH ''.
6179             REPLACE ALL OCCURRENCES OF ',' IN GS_TDS_TEMP-HSN_SAC_DES WITH ''.
6180
6181             CLEAR: TEXT1, CORR_STRING.
6182             TEXT1 = GS_TDS_TEMP-SERVICE_DES_INV.
6183             CALL FUNCTION 'ES_REMOVE_SPECIAL_CHARACTER'
6184               EXPORTING
6185                 TEXT1       = TEXT1
6186               IMPORTING
6187                 CORR_STRING = CORR_STRING.
6188             GS_TDS_TEMP-SERVICE_DES_INV = CORR_STRING.
6189
6190             CLEAR: TEXT1, CORR_STRING.
6191             TEXT1 = GS_TDS_TEMP-PO_DESC.
6192             CALL FUNCTION 'ES_REMOVE_SPECIAL_CHARACTER'
6193               EXPORTING
6194                 TEXT1       = TEXT1
6195               IMPORTING
6196                 CORR_STRING = CORR_STRING.
6197             GS_TDS_TEMP-PO_DESC = CORR_STRING.
6198
6199             CLEAR: TEXT1, CORR_STRING.
6200             TEXT1 = GS_TDS_TEMP-COMPANY_TXT.
6201             CALL FUNCTION 'ES_REMOVE_SPECIAL_CHARACTER'
6202               EXPORTING
6203                 TEXT1       = TEXT1
6204               IMPORTING
6205                 CORR_STRING = CORR_STRING.
6206             GS_TDS_TEMP-COMPANY_TXT = CORR_STRING.
6207
6208             CLEAR: TEXT1, CORR_STRING.
6209             TEXT1 = GS_TDS_TEMP-NAME_OF_DEDUCTEE.
6210             CALL FUNCTION 'ES_REMOVE_SPECIAL_CHARACTER'
6211               EXPORTING
6212                 TEXT1       = TEXT1
6213               IMPORTING
6214                 CORR_STRING = CORR_STRING.
6215             GS_TDS_TEMP-NAME_OF_DEDUCTEE = CORR_STRING.
6216
6217
6218             CLEAR: TEXT1, CORR_STRING.
6219             TEXT1 = GS_TDS_TEMP-HSN_SAC_DES.
6220             CALL FUNCTION 'ES_REMOVE_SPECIAL_CHARACTER'
6221               EXPORTING
6222                 TEXT1       = TEXT1
6223               IMPORTING
6224                 CORR_STRING = CORR_STRING.
6225             GS_TDS_TEMP-HSN_SAC_DES = CORR_STRING.
6226
6227             CONCATENATE '"' GS_TDS_TEMP-COMPANY_TXT '"' INTO GS_TDS_TEMP-COMPANY_TXT.
6228             CONCATENATE '"' GS_TDS_TEMP-NAME_OF_DEDUCTEE '"' INTO GS_TDS_TEMP-NAME_OF_DEDUCTEE.
6229             CONCATENATE '"' GS_TDS_TEMP-DEDUCTEE_PAN '"' INTO GS_TDS_TEMP-DEDUCTEE_PAN.
6230             CONCATENATE '"' GS_TDS_TEMP-VEND_INV_NUM '"' INTO GS_TDS_TEMP-VEND_INV_NUM.
6231             CONCATENATE '"' GS_TDS_TEMP-HSN_SAC_CODE '"' INTO GS_TDS_TEMP-HSN_SAC_CODE.
6232             CONCATENATE '"' GS_TDS_TEMP-HSN_SAC_DES '"' INTO GS_TDS_TEMP-HSN_SAC_DES.
6233             CONCATENATE '"' GS_TDS_TEMP-SERVICE_DES_INV '"' INTO GS_TDS_TEMP-SERVICE_DES_INV.
6234             CONCATENATE '"' GS_TDS_TEMP-GL_ACC_NAME '"' INTO GS_TDS_TEMP-GL_ACC_NAME.
6235             CONCATENATE '"' GS_TDS_TEMP-PO_DESC '"' INTO GS_TDS_TEMP-PO_DESC.
6236             CONCATENATE '"' GS_TDS_TEMP-POS '"' INTO GS_TDS_TEMP-POS.
6237             CONCATENATE '"' GS_TDS_TEMP-TDS_SECTION '"' INTO GS_TDS_TEMP-TDS_SECTION.
6238             CONCATENATE '"' GS_TDS_TEMP-ASSIGN_NUM '"' INTO GS_TDS_TEMP-ASSIGN_NUM.
6239             CONCATENATE '"' GS_TDS_TEMP-USERNAME '"' INTO GS_TDS_TEMP-USERNAME.
6240             CONCATENATE '"' GS_TDS_TEMP-TRANS_CODE '"' INTO GS_TDS_TEMP-TRANS_CODE.
6241   *      CONCATENATE '"' ls_final-user9 '"' INTO ls_final-user9.
6242             CONCATENATE '"' GS_TDS_TEMP-EXEMP_NUM '"' INTO GS_TDS_TEMP-EXEMP_NUM.
6243
6244             APPEND GS_TDS_TEMP TO GT_FINAL1.
6245             CONCATENATE GS_TDS_TEMP-DEDUCTOR_PAN '_' GS_TDS_TEMP-DEDUCTOR_TAN INTO GV_FILE.
6246             CLEAR:GS_TDS_TEMP1,GS_TDS_TEMP.
6247           ENDLOOP.
6248
6249           LOOP AT GT_FINAL1 ASSIGNING <FS_WORKAREA>.
6250             CLEAR LS_HEAD.
6251             LOOP AT LT_DDFIELDS INTO LS_DDFIELDS.
6252               ASSIGN COMPONENT  LS_DDFIELDS-FIELDNAME OF STRUCTURE <FS_WORKAREA> TO <FS_COMP>.
6253               LV_CHAR = <FS_COMP>.
6254               IF R_AL11 EQ 'X'.
6255                 IF P_ALFILE IS NOT INITIAL.
6256                   IF LS_DDFIELDS-FIELDNAME EQ 'XREF3' AND LV_CHAR IS NOT INITIAL.
6257                     CONCATENATE 'A' LV_CHAR INTO LV_CHAR.
6258                   ENDIF.
6259                 ENDIF.
6260               ENDIF.
6261
6262               REPLACE ALL OCCURRENCES OF ',' IN LV_CHAR WITH ' '.
6263               CONDENSE LV_CHAR.
6264
6265               IF P_AL_XLS = 'X' AND  R_AL11 = 'X'.
6266                 CONCATENATE LS_HEAD-HEAD LV_CHAR CL_ABAP_CHAR_UTILITIES=>HORIZONTAL_TAB INTO LS_HEAD-HEAD.
6267               ELSE.
6268                 CONCATENATE LS_HEAD-HEAD LV_CHAR ',' INTO LS_HEAD-HEAD.
6269               ENDIF.
6270
6271             ENDLOOP.
6272             IF SY-TABIX = '1'.
6273               APPEND LS_HEAD1 TO LT_HEAD.
6274             ENDIF.
6275             APPEND LS_HEAD TO LT_HEAD.
6276           ENDLOOP.
6277           CLEAR : GT_FINAL1.
6278
6279           IF R_AL11 = 'X' AND LT_HEAD[] IS NOT INITIAL.
6280             ADD 1 TO GV_FILECOUNT.
6281             PERFORM DOWNLOAD_FILE_AL11 TABLES LT_HEAD. " create file in application server
6282
6283           ENDIF.
6284           CLEAR LS_FINAL.
6285         ENDLOOP.
6286         GT_TDS = GT_TDS_TEMP.
6287
6288         IF GT_FINAL1 IS NOT INITIAL.
6289           LOOP AT GT_FINAL1 ASSIGNING <FS_WORKAREA>.
6290             CLEAR LS_HEAD.
6291             LOOP AT LT_DDFIELDS INTO LS_DDFIELDS.
6292               ASSIGN COMPONENT  LS_DDFIELDS-FIELDNAME OF STRUCTURE <FS_WORKAREA> TO <FS_COMP>.
6293               LV_CHAR = <FS_COMP>.
6294               REPLACE ALL OCCURRENCES OF ',' IN LV_CHAR WITH ' '.
6295               CONDENSE LV_CHAR.
6296
6297               IF P_AL_XLS = 'X' AND  R_AL11 = 'X'.
6298                 CONCATENATE LS_HEAD-HEAD LV_CHAR CL_ABAP_CHAR_UTILITIES=>HORIZONTAL_TAB INTO LS_HEAD-HEAD.
6299               ELSE.
6300                 CONCATENATE LS_HEAD-HEAD LV_CHAR ',' INTO LS_HEAD-HEAD.
6301               ENDIF.
6302             ENDLOOP.
6303             IF SY-TABIX = '1'.
6304               APPEND LS_HEAD1 TO LT_HEAD.
6305             ENDIF.
6306             APPEND LS_HEAD TO LT_HEAD.
6307           ENDLOOP.
6308           CLEAR : GT_FINAL1.
6309
6310           IF R_AL11 = 'X' AND LT_HEAD[] IS NOT INITIAL.
6311             ADD 1 TO GV_FILECOUNT.
6312             PERFORM DOWNLOAD_FILE_AL11 TABLES LT_HEAD. " create file in application server
6313           ENDIF.
6314           CLEAR : GT_FINAL1.
6315         ENDIF.
6316
6317         IF R_CHK IS NOT INITIAL.
6318           "control table download.
6319
6320           LT_FINAL = GT_TDS.
6321           LT_FINAL_TEMP = GT_TDS.
6322           SORT LT_FINAL BY POST_DAT_DOCU ASCENDING.
6323
6324           SORT LT_FINAL_TEMP BY POST_DAT_DOCU DESCENDING.
6325           READ TABLE LT_FINAL_TEMP INTO LS_FINAL INDEX 1.
6326
6327           SORT GT_TDS BY COMPANY_CODE DEDUCTOR_TAN NRINDICATOR SHKZG.
6328           LT_FINAL_CNT = GT_TDS.
6329           LT_FINAL_CNT1 = GT_TDS.
6330
6331           DELETE ADJACENT DUPLICATES FROM GT_TDS COMPARING COMPANY_CODE DEDUCTOR_TAN NRINDICATOR SHKZG.
6332           DATA : LV_INDEX TYPE SY-TABIX.
6333
6334           LOOP AT GT_TDS INTO GS_TDS.
6335             READ TABLE LT_FINAL_CNT TRANSPORTING NO FIELDS WITH  KEY COMPANY_CODE = GS_TDS-COMPANY_CODE
6336                                                                     DEDUCTOR_TAN = GS_TDS-DEDUCTOR_TAN
6337                                                                     NRINDICATOR = GS_TDS-NRINDICATOR
6338                                                                     SHKZG = GS_TDS-SHKZG.
6339             IF SY-SUBRC = 0.
6340               LV_INDEX = SY-TABIX.
6341               LOOP AT LT_FINAL_CNT INTO DATA(LS_FINAL_CNT) FROM LV_INDEX.
6342                 IF LS_FINAL_CNT-DEDUCTOR_TAN <> GS_TDS-DEDUCTOR_TAN OR LS_FINAL_CNT-NRINDICATOR <> GS_TDS-NRINDICATOR
6343                                           OR LS_FINAL_CNT-SHKZG <> GS_TDS-SHKZG OR LS_FINAL_CNT-COMPANY_CODE <> GS_TDS-COMPANY_CODE.
6344                   EXIT.
6345                 ENDIF.
6346                 COUNT = COUNT + 1.
6347                 LS_CONTROL-TEXT = LS_FINAL_CNT-SOURCE_FIL.
6348                 LS_CONTROL-TEXT1 = LS_FINAL_CNT-COMPANY_CODE.
6349                 LS_CONTROL-TAN = LS_FINAL_CNT-DEDUCTOR_TAN.
6350                 IF LS_FINAL_CNT-NRINDICATOR = 'N'.
6351                   LS_CONTROL-STATUS = 'R'.
6352                 ENDIF.
6353                 IF LS_FINAL_CNT-NRINDICATOR = 'Y'.
6354                   LS_CONTROL-STATUS = 'NR'.
6355                 ENDIF.
6356                 IF LS_FINAL_CNT-SHKZG = 'S'.
6357                   LS_CONTROL-DR_CR = 'DR'.
6358                 ENDIF.
6359                 IF LS_FINAL_CNT-SHKZG = 'H'.
6360                   LS_CONTROL-DR_CR = 'CR'.
6361                 ENDIF.
6362                 IF S_DATE[] IS NOT INITIAL AND CR_DATE[] IS NOT INITIAL.
6363                   CONCATENATE S_DATE-LOW+0(4) '-' S_DATE-LOW+4(2) '-' S_DATE-LOW+6(2) INTO LS_CONTROL-BUDAT_S.
6364                   IF S_DATE-HIGH IS NOT INITIAL.
6365                     CONCATENATE S_DATE-HIGH+0(4) '-' S_DATE-HIGH+4(2) '-' S_DATE-HIGH+6(2) INTO LS_CONTROL-BUDAT_E.
6366                   ELSE.
6367                     CONCATENATE S_DATE-LOW+0(4) '-' S_DATE-LOW+4(2) '-' S_DATE-LOW+6(2) INTO LS_CONTROL-BUDAT_E.
6368                   ENDIF.
6369                   CONCATENATE CR_DATE-LOW+0(4) '-' CR_DATE-LOW+4(2) '-' CR_DATE-LOW+6(2) INTO LS_CONTROL-CPUDT_S.
6370                   IF CR_DATE-HIGH IS NOT INITIAL.
6371                     CONCATENATE CR_DATE-HIGH+0(4) '-' CR_DATE-HIGH+4(2) '-' CR_DATE-HIGH+6(2) INTO LS_CONTROL-CPUDT_E.
6372                   ELSE.
6373                     CONCATENATE CR_DATE-LOW+0(4) '-' CR_DATE-LOW+4(2) '-' CR_DATE-LOW+6(2) INTO LS_CONTROL-CPUDT_E.
6374                   ENDIF.
6375                 ELSEIF  S_DATE[] IS NOT INITIAL .
6376                   CONCATENATE S_DATE-LOW+0(4) '-' S_DATE-LOW+4(2) '-' S_DATE-LOW+6(2) INTO LS_CONTROL-BUDAT_S.
6377                   IF S_DATE-HIGH IS NOT INITIAL.
6378                     CONCATENATE S_DATE-HIGH+0(4) '-' S_DATE-HIGH+4(2) '-' S_DATE-HIGH+6(2) INTO LS_CONTROL-BUDAT_E.
6379                   ELSE.
6380                     CONCATENATE S_DATE-LOW+0(4) '-' S_DATE-LOW+4(2) '-' S_DATE-LOW+6(2) INTO LS_CONTROL-BUDAT_E.
6381                   ENDIF.
6382                 ELSEIF CR_DATE[] IS NOT INITIAL.
6383                   CONCATENATE CR_DATE-LOW+0(4) '-' CR_DATE-LOW+4(2) '-' CR_DATE-LOW+6(2) INTO LS_CONTROL-CPUDT_S.
6384                   IF CR_DATE-HIGH IS NOT INITIAL.
6385                     CONCATENATE CR_DATE-HIGH+0(4) '-' CR_DATE-HIGH+4(2) '-' CR_DATE-HIGH+6(2) INTO LS_CONTROL-CPUDT_E.
6386                   ELSE.
6387                     CONCATENATE CR_DATE-LOW+0(4) '-' CR_DATE-LOW+4(2) '-' CR_DATE-LOW+6(2) INTO LS_CONTROL-CPUDT_E.
6388                   ENDIF.
6389                 ELSEIF S_CDATE[] IS NOT INITIAL.
6390                   CONCATENATE S_CDATE-LOW+0(4) '-' S_CDATE-LOW+4(2) '-' S_CDATE-LOW+6(2) INTO LS_CONTROL-BUDAT_S.
6391                   IF S_CDATE-HIGH IS NOT INITIAL.
6392                     CONCATENATE S_CDATE-HIGH+0(4) '-' S_CDATE-HIGH+4(2) '-' S_CDATE-HIGH+6(2) INTO LS_CONTROL-BUDAT_E.
6393                   ELSE.
6394                     CONCATENATE S_CDATE-LOW+0(4) '-' S_CDATE-LOW+4(2) '-' S_CDATE-LOW+6(2) INTO LS_CONTROL-BUDAT_E.
6395                   ENDIF.
6396                 ELSE.
6397                   CONCATENATE  P_GJAHR'-01-01'  INTO LS_CONTROL-BUDAT_S.
6398                   CONCATENATE P_GJAHR '-12-31'  INTO LS_CONTROL-BUDAT_E.
6399                 ENDIF.
6400                 LV_DATE1 = LS_CONTROL-BUDAT_S.
6401                 LV_DATE2 = LS_CONTROL-BUDAT_E.
6402
6403                 CONCATENATE SY-DATUM+0(4) SY-DATUM+4(2) SY-DATUM+6(2) INTO LS_CONTROL-EXTRAT_D SEPARATED BY '-'  .
6404                 LS_CONTROL-NO_REC = COUNT.
6405                 LS_CONTROL-AMOUNT = LS_CONTROL-AMOUNT + LS_FINAL_CNT-TAXABLEVALUE.
6406                 LS_CONTROL-TDS_AMOUNT = LS_CONTROL-TDS_AMOUNT + LS_FINAL_CNT-TDS_AMOUNT.
6407                 LS_CONTROL-INV_AMT = LS_CONTROL-INV_AMT + LS_FINAL_CNT-INVOICE_VAL.
6408
6409                 LS_R_VEN-SIGN = 'I'.
6410                 LS_R_VEN-OPTION = 'EQ'.
6411                 IF LS_FINAL_CNT-DEDUCTEE_CODE IS NOT INITIAL.
6412
6413                   LS_R_VEN-LOW = LS_FINAL_CNT-DEDUCTEE_CODE.
6414                   CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
6415                     EXPORTING
6416                       INPUT  = LS_R_VEN-LOW
6417                     IMPORTING
6418                       OUTPUT = LS_R_VEN-LOW.
6419                   APPEND LS_R_VEN TO R_VEN.
6420                   CLEAR LS_R_VEN.
6421                 ENDIF.
6422
6423                 LS_DET-BUKRS = LS_FINAL_CNT-COMPANY_CODE.
6424                 LS_DET-BELNR = LS_FINAL_CNT-ERP_NUM.    "(+)EY-RAHUL
6425                 APPEND LS_DET TO LT_DET.
6426                 CLEAR:LS_DET.
6427
6428                 LS_R_BUKRS-SIGN = 'I'.
6429                 LS_R_BUKRS-OPTION = 'EQ'.
6430                 LS_R_BUKRS-LOW = LS_FINAL_CNT-COMPANY_CODE.
6431                 APPEND LS_R_BUKRS TO R_BUKRS.
6432                 CLEAR:LS_R_BUKRS.
6433               ENDLOOP.
6434               APPEND LS_CONTROL TO LT_CONTROL.
6435               CLEAR:LS_CONTROL,COUNT,LS_FINAL_CNT,GS_TDS,LV_INDEX.
6436             ENDIF.
6437           ENDLOOP.
6438
6439           DELETE ADJACENT DUPLICATES FROM LT_DET COMPARING ALL FIELDS. "(+)EY-RAHUL
6440
6441           SORT R_VEN BY LOW.
6442           SORT R_BUKRS BY LOW.
6443           DELETE ADJACENT DUPLICATES FROM R_VEN COMPARING LOW.
6444           DELETE ADJACENT DUPLICATES FROM R_BUKRS COMPARING LOW.
6445
6446           REPLACE ALL OCCURRENCES OF '-' IN LV_DATE1 WITH SPACE.
6447           REPLACE ALL OCCURRENCES OF '-' IN LV_DATE2 WITH SPACE.
6448           CONDENSE LV_DATE1.
6449           CONDENSE LV_DATE2.
6450           LS_R_BUDAT-SIGN = 'I'.
6451           LS_R_BUDAT-OPTION = 'BT'.
6452           LS_R_BUDAT-LOW = LV_DATE1.
6453           LS_R_BUDAT-HIGH = LV_DATE2.
6454           APPEND LS_R_BUDAT TO R_BUDAT.
6455           CLEAR LS_R_BUDAT.
6456
6457           IF S_DATE[] IS NOT INITIAL.
6458             IF R_BUKRS[] IS NOT INITIAL.
6459               IF P_SPL_DT IS NOT INITIAL.
6460
6461                 CLEAR:LV_DTE_LOW,LV_DTE_HIGH.
6462                 LV_DTE_LOW = S_DATE-LOW.
6463                 LV_DTE_HIGH = S_DATE-HIGH.
6464
6465   *            IF p_spl_dt IS NOT INITIAL.
6466                 PERFORM SPLIT_DATE_LOGIC.
6467
6468                 CLEAR:LT_FBL1N[].
6469                 WHILE LV_NO NE '0'.
6470
6471                   CLEAR:LV_LOW,LV_HIGH.
6472                   IF SY-INDEX EQ '1'.
6473                     LV_LOW = S_DATE-LOW.
6474                     LV_HIGH = S_DATE-LOW + P_SPL_DT.
6475                   ELSE.
6476                     IF SY-INDEX EQ LV_COUNTER.
6477                       LV_LOW = S_DATE-HIGH + '1'.
6478                       LV_HIGH = LV_DTE_HIGH.
6479                     ELSE.
6480                       LV_LOW = S_DATE-HIGH + '1'.
6481                       LV_HIGH = S_DATE-HIGH + P_SPL_DT.
6482                     ENDIF.
6483                   ENDIF.
6484
6485                   LOOP AT S_DATE[] INTO S_DATE.
6486                     S_DATE-SIGN = 'I'.
6487                     S_DATE-OPTION = 'EQ'.
6488                     S_DATE-LOW = LV_LOW.
6489                     S_DATE-HIGH = LV_HIGH.
6490                     MODIFY S_DATE[] FROM S_DATE.
6491                   ENDLOOP.
6492
6493
6494                   "calling FBL1N
6495                   CLEAR:R_VEN[],LR_DATA.
6496                   CL_SALV_BS_RUNTIME_INFO=>SET( EXPORTING DISPLAY  = ABAP_FALSE
6497                                                           METADATA = ABAP_FALSE
6498                                                           DATA     = ABAP_TRUE ).
6499
6500                   SUBMIT RFITEMAP
6501                                    WITH KD_LIFNR IN R_VEN
6502                                   WITH KD_BUKRS IN R_BUKRS[]
6503                                   WITH X_AISEL = 'X'
6504                                   WITH SO_BUDAT IN S_DATE[]
6505                                   WITH X_NORM = 'X'
6506                                   WITH X_SHBV = ' '
6507                                   WITH X_MERK = ' '
6508                                   WITH X_PARK = ' '
6509                                   AND RETURN
6510                                   EXPORTING LIST TO MEMORY.
6511
6512                   TRY.
6513                       CL_SALV_BS_RUNTIME_INFO=>GET_DATA_REF( IMPORTING R_DATA = LR_DATA ).
6514
6515                       ASSIGN LR_DATA->* TO <LT_FBL1N>.
6516                     CATCH CX_SALV_BS_SC_RUNTIME_INFO.
6517                       MESSAGE `Unable to retrieve ALV data`TYPE 'S' DISPLAY LIKE 'E'.
6518                   ENDTRY.
6519
6520                   CL_SALV_BS_RUNTIME_INFO=>CLEAR( ).
6521
6522                   IF <LT_FBL1N>[] IS ASSIGNED.
6523                     APPEND LINES OF <LT_FBL1N>[] TO LT_FBL1N[].
6524                     UNASSIGN <LT_FBL1N>[].
6525                   ENDIF.
6526   *                  ENDIF.
6527
6528
6529                   LV_NO = LV_NO - '1'.
6530                 ENDWHILE.
6531
6532                 LOOP AT S_DATE[] INTO S_DATE.
6533                   S_DATE-SIGN = 'I'.
6534                   S_DATE-OPTION = 'EQ'.
6535                   S_DATE-LOW = LV_DTE_LOW.
6536                   S_DATE-HIGH = LV_DTE_HIGH.
6537                   MODIFY S_DATE[] FROM S_DATE.
6538                 ENDLOOP.
6539
6540
6541               ELSE.
6542
6543                 "calling FBL1N
6544                 CLEAR:R_VEN[].
6545                 CL_SALV_BS_RUNTIME_INFO=>SET( EXPORTING DISPLAY  = ABAP_FALSE
6546                                                         METADATA = ABAP_FALSE
6547                                                         DATA     = ABAP_TRUE ).
6548
6549                 SUBMIT RFITEMAP
6550                                  WITH KD_LIFNR IN R_VEN
6551                                 WITH KD_BUKRS IN R_BUKRS
6552   *                          WITH kd_bukrs IN s_bukrs[]
6553                                 WITH X_AISEL = 'X'
6554                                 WITH SO_BUDAT IN R_BUDAT
6555                                 WITH X_NORM = 'X'
6556                                 WITH X_SHBV = ' '
6557                                 WITH X_MERK = ' '
6558                                 WITH X_PARK = ' '
6559                                 AND RETURN.              "#EC CI_NOFIRST.
6560
6561                 TRY.
6562                     CL_SALV_BS_RUNTIME_INFO=>GET_DATA_REF( IMPORTING R_DATA = LR_DATA ).
6563                     ASSIGN LR_DATA->* TO <LT_FBL1N>.
6564                   CATCH CX_SALV_BS_SC_RUNTIME_INFO.
6565                     IF P_BYPASS IS INITIAL.
6566                       MESSAGE `Unable to retrieve ALV data`TYPE 'S' DISPLAY LIKE 'E'.
6567                     ENDIF.
6568                 ENDTRY.
6569                 CL_SALV_BS_RUNTIME_INFO=>CLEAR( ).
6570
6571                 IF <LT_FBL1N>[] IS ASSIGNED.
6572                   LT_FBL1N[] = <LT_FBL1N>[] .
6573                 ENDIF.
6574               ENDIF.
6575             ENDIF.
6576           ENDIF.
6577
6578           DELETE LT_FBL1N WHERE BLART NOT IN  R_BLART.
6579           DELETE LT_FBL1N WHERE BELNR NOT IN S_BELNR[]. "(+)EY-RAHUL
6580
6581           SORT LT_FBL1N BY BUKRS SHKZG.
6582           IF LT_DET[] IS NOT INITIAL.
6583             LT_FBL1N_DEL[] =  LT_FBL1N[].
6584             LOOP AT LT_DET INTO LS_DET.
6585               DELETE LT_FBL1N_DEL WHERE BELNR =  LS_DET-BELNR AND BUKRS = LS_DET-BUKRS.
6586             ENDLOOP.
6587             CLEAR:LT_DET[].
6588           ENDIF.
6589
6590           DATA(LT_FBL1N_TEMP) = LT_FBL1N.
6591           DATA:LS_FBL1N LIKE LINE OF LT_FBL1N.
6592           DATA:LS_FBL1N_TEMP LIKE LINE OF LT_FBL1N.
6593           DELETE ADJACENT DUPLICATES FROM LT_FBL1N COMPARING BUKRS SHKZG.
6594           LOOP AT LT_FBL1N INTO LS_FBL1N.
6595             LOOP AT LT_FBL1N_TEMP INTO LS_FBL1N_TEMP WHERE BUKRS = LS_FBL1N-BUKRS AND SHKZG = LS_FBL1N-SHKZG.
6596               IF LS_FBL1N_TEMP-SHKZG = 'H'.
6597                 LS_CONTROL-DR_CR = 'DR'.
6598                 LS_CONTROL-TEXT = 'DR Total at company code level'.
6599               ENDIF.
6600               IF LS_FBL1N_TEMP-SHKZG = 'S'.
6601                 LS_CONTROL-DR_CR = 'CR'.
6602                 LS_CONTROL-TEXT = 'CR Total at company code level'.
6603
6604               ENDIF.
6605               LS_CONTROL-TAN = LS_FBL1N_TEMP-BUKRS.
6606               LS_CONTROL-TEXT1 = LS_FBL1N_TEMP-BUKRS.
6607               LS_CONTROL-STATUS = 'ALL'.
6608               IF LS_FBL1N_TEMP-DMSHB < 0.
6609                 LS_FBL1N_TEMP-DMSHB = LS_FBL1N_TEMP-DMSHB * -1.
6610               ENDIF.
6611               LS_CONTROL-FBL1N_AMT = LS_CONTROL-FBL1N_AMT + LS_FBL1N_TEMP-DMSHB.
6612             ENDLOOP.
6613             APPEND LS_CONTROL TO LT_CONTROL_FBL1N.
6614             CLEAR:LS_CONTROL.
6615           ENDLOOP.
6616   *          ENDIF.
6617   *        ENDIF.
6618
6619
6620           DATA: LS_CONTROL_FBL1N LIKE LINE OF LT_CONTROL_FBL1N.
6621           CLEAR:GT_TDS[],LT_FINAL_CNT[].
6622           GT_TDS = LT_FINAL_CNT1.
6623           SORT GT_TDS BY COMPANY_CODE SHKZG.
6624           LT_FINAL_CNT = GT_TDS.
6625           DELETE ADJACENT DUPLICATES FROM GT_TDS COMPARING COMPANY_CODE SHKZG.
6626           LOOP AT GT_TDS INTO GS_TDS.
6627             READ TABLE LT_FINAL_CNT TRANSPORTING NO FIELDS WITH  KEY COMPANY_CODE = GS_TDS-COMPANY_CODE
6628                                                                        SHKZG = GS_TDS-SHKZG.
6629             IF SY-SUBRC = 0.
6630               LV_INDEX = SY-TABIX.
6631               LOOP AT LT_FINAL_CNT INTO LS_FINAL_CNT FROM LV_INDEX.
6632                 IF LS_FINAL_CNT-COMPANY_CODE <> GS_TDS-COMPANY_CODE  OR LS_FINAL_CNT-SHKZG <> GS_TDS-SHKZG.
6633                   EXIT.
6634                 ENDIF.
6635                 COUNT = COUNT + 1.
6636                 LS_CONTROL-TAN = LS_FINAL_CNT-COMPANY_CODE.
6637                 LS_CONTROL-TEXT1 = LS_FINAL_CNT-COMPANY_CODE.
6638                 LS_CONTROL-STATUS = 'ALL'.
6639                 IF LS_FINAL_CNT-SHKZG = 'H'.
6640                   LS_CONTROL-DR_CR = 'CR'.
6641                   LS_CONTROL-TEXT = 'CR Total at company code level'.
6642                 ENDIF.
6643                 IF LS_FINAL_CNT-SHKZG = 'S'.
6644                   LS_CONTROL-DR_CR = 'DR'.
6645                   LS_CONTROL-TEXT = 'DR Total at company code level'.
6646
6647                 ENDIF.
6648                 IF S_DATE[] IS NOT INITIAL AND CR_DATE[] IS NOT INITIAL.
6649                   CONCATENATE S_DATE-LOW+0(4) '-' S_DATE-LOW+4(2) '-' S_DATE-LOW+6(2) INTO LS_CONTROL-BUDAT_S.
6650                   IF S_DATE-HIGH IS NOT INITIAL.
6651                     CONCATENATE S_DATE-HIGH+0(4) '-' S_DATE-HIGH+4(2) '-' S_DATE-HIGH+6(2) INTO LS_CONTROL-BUDAT_E.
6652                   ELSE.
6653                     CONCATENATE S_DATE-LOW+0(4) '-' S_DATE-LOW+4(2) '-' S_DATE-LOW+6(2) INTO LS_CONTROL-BUDAT_E.
6654                   ENDIF.
6655                   CONCATENATE CR_DATE-LOW+0(4) '-' CR_DATE-LOW+4(2) '-' CR_DATE-LOW+6(2) INTO LS_CONTROL-CPUDT_S.
6656                   IF CR_DATE-HIGH IS NOT INITIAL.
6657                     CONCATENATE CR_DATE-HIGH+0(4) '-' CR_DATE-HIGH+4(2) '-' CR_DATE-HIGH+6(2) INTO LS_CONTROL-CPUDT_E.
6658                   ELSE.
6659                     CONCATENATE CR_DATE-LOW+0(4) '-' CR_DATE-LOW+4(2) '-' CR_DATE-LOW+6(2) INTO LS_CONTROL-CPUDT_E.
6660                   ENDIF.
6661                 ELSEIF  S_DATE[] IS NOT INITIAL .
6662                   CONCATENATE S_DATE-LOW+0(4) '-' S_DATE-LOW+4(2) '-' S_DATE-LOW+6(2) INTO LS_CONTROL-BUDAT_S.
6663                   IF S_DATE-HIGH IS NOT INITIAL.
6664                     CONCATENATE S_DATE-HIGH+0(4) '-' S_DATE-HIGH+4(2) '-' S_DATE-HIGH+6(2) INTO LS_CONTROL-BUDAT_E.
6665                   ELSE.
6666                     CONCATENATE S_DATE-LOW+0(4) '-' S_DATE-LOW+4(2) '-' S_DATE-LOW+6(2) INTO LS_CONTROL-BUDAT_E.
6667                   ENDIF.
6668                 ELSEIF CR_DATE[] IS NOT INITIAL.
6669                   CONCATENATE CR_DATE-LOW+0(4) '-' CR_DATE-LOW+4(2) '-' CR_DATE-LOW+6(2) INTO LS_CONTROL-CPUDT_S.
6670                   IF CR_DATE-HIGH IS NOT INITIAL.
6671                     CONCATENATE CR_DATE-HIGH+0(4) '-' CR_DATE-HIGH+4(2) '-' CR_DATE-HIGH+6(2) INTO LS_CONTROL-CPUDT_E.
6672                   ELSE.
6673                     CONCATENATE CR_DATE-LOW+0(4) '-' CR_DATE-LOW+4(2) '-' CR_DATE-LOW+6(2) INTO LS_CONTROL-CPUDT_E.
6674                   ENDIF.
6675                 ELSEIF S_CDATE[] IS NOT INITIAL.
6676                   CONCATENATE S_CDATE-LOW+0(4) '-' S_CDATE-LOW+4(2) '-' S_CDATE-LOW+6(2) INTO LS_CONTROL-BUDAT_S.
6677                   IF S_CDATE-HIGH IS NOT INITIAL.
6678                     CONCATENATE S_CDATE-HIGH+0(4) '-' S_CDATE-HIGH+4(2) '-' S_CDATE-HIGH+6(2) INTO LS_CONTROL-BUDAT_E.
6679                   ELSE.
6680                     CONCATENATE S_CDATE-LOW+0(4) '-' S_CDATE-LOW+4(2) '-' S_CDATE-LOW+6(2) INTO LS_CONTROL-BUDAT_E.
6681                   ENDIF.
6682                 ELSE.
6683                   CONCATENATE  P_GJAHR'-01-01'  INTO LS_CONTROL-BUDAT_S.
6684                   CONCATENATE P_GJAHR '-12-31'  INTO LS_CONTROL-BUDAT_E.
6685                 ENDIF.
6686                 CONCATENATE SY-DATUM+0(4) SY-DATUM+4(2) SY-DATUM+6(2) INTO LS_CONTROL-EXTRAT_D SEPARATED BY '-'  .
6687                 LS_CONTROL-NO_REC = COUNT.
6688                 LS_CONTROL-AMOUNT = LS_CONTROL-AMOUNT + LS_FINAL_CNT-TAXABLEVALUE.
6689                 LS_CONTROL-TDS_AMOUNT = LS_CONTROL-TDS_AMOUNT + LS_FINAL_CNT-TDS_AMOUNT.
6690                 LS_CONTROL-INV_AMT = LS_CONTROL-INV_AMT + LS_FINAL_CNT-INVOICE_VAL.
6691
6692               ENDLOOP.
6693               READ TABLE LT_CONTROL_FBL1N INTO LS_CONTROL_FBL1N WITH  KEY TAN = LS_CONTROL-TAN TEXT1 = LS_CONTROL-TEXT1 DR_CR = LS_CONTROL-DR_CR.
6694               IF SY-SUBRC = 0.
6695                 LS_CONTROL-FBL1N_AMT = LS_CONTROL_FBL1N-FBL1N_AMT.
6696                 DELETE TABLE LT_CONTROL_FBL1N FROM LS_CONTROL_FBL1N.
6697               ENDIF.
6698
6699               APPEND LS_CONTROL TO LT_CONTROL.
6700               APPEND LS_CONTROL TO LT_CONTROL_COM.
6701               CLEAR:LS_CONTROL,COUNT,LS_FINAL_CNT,GS_TDS,LV_INDEX.
6702             ENDIF.
6703           ENDLOOP.
6704           IF LT_CONTROL_FBL1N IS NOT INITIAL.
6705             APPEND LINES OF LT_CONTROL_FBL1N TO LT_CONTROL.
6706             APPEND LINES OF LT_CONTROL_FBL1N TO LT_CONTROL_COM.
6707           ENDIF.
6708
6709           LT_CONTROL_TEMP[] = LT_CONTROL_COM[].
6710           SORT LT_CONTROL_TEMP BY TEXT1 .
6711           DELETE ADJACENT DUPLICATES FROM LT_CONTROL_TEMP COMPARING TEXT1.
6712
6713           LOOP AT LT_CONTROL_TEMP INTO LS_CONTROL_TEMP.
6714             LS_CONTROL-TEXT1 = LS_CONTROL_TEMP-TEXT1.
6715             LS_CONTROL-TEXT  = 'Total at Company code Level'.
6716             LS_CONTROL-CPUDT_S = LS_CONTROL_TEMP-CPUDT_S.
6717             LS_CONTROL-CPUDT_E = LS_CONTROL_TEMP-CPUDT_E.
6718             LS_CONTROL-BUDAT_S = LS_CONTROL_TEMP-BUDAT_S.
6719             LS_CONTROL-BUDAT_E = LS_CONTROL_TEMP-BUDAT_E.
6720             LS_CONTROL-EXTRAT_D = LS_CONTROL_TEMP-EXTRAT_D.
6721             LOOP AT LT_CONTROL_COM INTO LS_CONTROL_COM WHERE  TEXT1 = LS_CONTROL_TEMP-TEXT1 AND
6722                                                              DR_CR = 'DR'.
6723               LS_CONTROL-NO_REC = LS_CONTROL_COM-NO_REC +  LS_CONTROL-NO_REC.
6724               LS_CONTROL-AMOUNT = LS_CONTROL-AMOUNT + LS_CONTROL_COM-AMOUNT.
6725               LS_CONTROL-TDS_AMOUNT = LS_CONTROL-TDS_AMOUNT + LS_CONTROL_COM-TDS_AMOUNT.
6726               LS_CONTROL-FBL1N_AMT = LS_CONTROL-FBL1N_AMT + LS_CONTROL_COM-FBL1N_AMT.
6727               LS_CONTROL-INV_AMT = LS_CONTROL-INV_AMT + LS_CONTROL_COM-INV_AMT.
6728             ENDLOOP.
6729             LOOP AT LT_CONTROL_COM INTO LS_CONTROL_COM1 WHERE  TEXT1 = LS_CONTROL_TEMP-TEXT1 AND
6730                                                                   DR_CR = 'CR'.
6731
6732               LS_CONTROL-NO_REC = LS_CONTROL-NO_REC + LS_CONTROL_COM1-NO_REC.
6733               LS_CONTROL-AMOUNT = LS_CONTROL-AMOUNT - LS_CONTROL_COM1-AMOUNT.
6734               LS_CONTROL-TDS_AMOUNT = LS_CONTROL-TDS_AMOUNT - LS_CONTROL_COM1-TDS_AMOUNT.
6735               LS_CONTROL-FBL1N_AMT = LS_CONTROL-FBL1N_AMT - LS_CONTROL_COM1-FBL1N_AMT.
6736               LS_CONTROL-INV_AMT = LS_CONTROL-INV_AMT - LS_CONTROL_COM1-INV_AMT.
6737             ENDLOOP.
6738             CLEAR LV_INDEX.
6739             LT_FINAL_CNT1[] = LT_FINAL_CNT[].
6740             DELETE LT_FINAL_CNT1 WHERE COMPANY_CODE NE LS_CONTROL_TEMP-TEXT1.
6741             SORT LT_FINAL_CNT1 BY COMPANY_CODE ERP_NUM.
6742             DELETE ADJACENT DUPLICATES FROM LT_FINAL_CNT1 COMPARING  COMPANY_CODE ERP_NUM.
6743             DESCRIBE TABLE LT_FINAL_CNT1 LINES LV_INDEX.
6744             LS_CONTROL-NO_DOC = LV_INDEX.
6745
6746             CLEAR LV_INDEX.
6747             LT_FBL1N = LT_FBL1N_TEMP.
6748             DELETE LT_FBL1N WHERE BUKRS NE LS_CONTROL_TEMP-TEXT1.
6749             SORT LT_FBL1N BY BUKRS GJAHR BELNR.
6750             DELETE ADJACENT DUPLICATES FROM LT_FBL1N COMPARING BUKRS GJAHR BELNR.
6751             DESCRIBE TABLE LT_FBL1N LINES LV_INDEX.
6752             LS_CONTROL-NO_FBL = LV_INDEX.
6753
6754             APPEND LS_CONTROL TO LT_CONTROL.
6755             CLEAR LS_CONTROL.
6756           ENDLOOP.
6757
6758
6759
6760           CLEAR:LS_HEAD,LT_HEAD[].
6761           LS_HEAD-HEAD = 'Source file name'.
6762           CONCATENATE LS_HEAD-HEAD ',' 'Company Code' INTO LS_HEAD-HEAD.
6763           CONCATENATE LS_HEAD-HEAD ',' 'TAN' INTO LS_HEAD-HEAD.
6764           CONCATENATE LS_HEAD-HEAD ',' 'Deductee Status' INTO LS_HEAD-HEAD.
6765           CONCATENATE LS_HEAD-HEAD ',' 'DR/CR' INTO LS_HEAD-HEAD.
6766           CONCATENATE LS_HEAD-HEAD ',' 'Posting Period Start date' INTO LS_HEAD-HEAD.
6767           CONCATENATE LS_HEAD-HEAD ',' 'Posting Period End date' INTO LS_HEAD-HEAD.
6768           CONCATENATE LS_HEAD-HEAD ',' 'Creation Period Start date' INTO LS_HEAD-HEAD.
6769           CONCATENATE LS_HEAD-HEAD ',' 'Creation Period End date' INTO LS_HEAD-HEAD.
6770           CONCATENATE LS_HEAD-HEAD ',' 'Date of extraction' INTO LS_HEAD-HEAD.
6771           CONCATENATE LS_HEAD-HEAD ',' 'No. of lines items' INTO LS_HEAD-HEAD.
6772           CONCATENATE LS_HEAD-HEAD ',' 'No. of Documents' INTO LS_HEAD-HEAD.
6773           CONCATENATE LS_HEAD-HEAD ',' 'Taxable Amount in Local Currency' INTO LS_HEAD-HEAD.
6774           CONCATENATE LS_HEAD-HEAD ',' 'Invoice Amount in Local Currency' INTO LS_HEAD-HEAD.
6775           CONCATENATE LS_HEAD-HEAD ',' 'TDS Amount in Local Currency' INTO LS_HEAD-HEAD.
6776           CONCATENATE LS_HEAD-HEAD ',' 'No. of FBL1N Documents' INTO LS_HEAD-HEAD.
6777           CONCATENATE LS_HEAD-HEAD ',' 'FBL1N Amount in Local currency' INTO LS_HEAD-HEAD.
6778           APPEND LS_HEAD TO LT_HEAD.
6779
6780           CLEAR:LS_HEAD.
6781           LOOP AT LT_CONTROL ASSIGNING <FS_WORKAREA>.
6782             ASSIGN COMPONENT 'TEXT' OF STRUCTURE <FS_WORKAREA> TO <FS_COMP>.
6783             LV_CHAR = <FS_COMP>.
6784             REPLACE ALL OCCURRENCES OF ',' IN LV_CHAR WITH ' '.
6785             CONDENSE LV_CHAR.
6786             CONCATENATE LS_HEAD-HEAD LV_CHAR ',' INTO LS_HEAD-HEAD.
6787
6788             ASSIGN COMPONENT 'TEXT1' OF STRUCTURE <FS_WORKAREA> TO <FS_COMP>.
6789             LV_CHAR = <FS_COMP>.
6790             REPLACE ALL OCCURRENCES OF ',' IN LV_CHAR WITH ' '.
6791             CONDENSE LV_CHAR.
6792             CONCATENATE LS_HEAD-HEAD LV_CHAR ',' INTO LS_HEAD-HEAD.
6793
6794             ASSIGN COMPONENT 'TAN' OF STRUCTURE <FS_WORKAREA> TO <FS_COMP>.
6795             LV_CHAR = <FS_COMP>.
6796             REPLACE ALL OCCURRENCES OF ',' IN LV_CHAR WITH ' '.
6797             CONDENSE LV_CHAR.
6798             CONCATENATE LS_HEAD-HEAD LV_CHAR ',' INTO LS_HEAD-HEAD.
6799
6800             ASSIGN COMPONENT 'STATUS' OF STRUCTURE <FS_WORKAREA> TO <FS_COMP>.
6801             LV_CHAR = <FS_COMP>.
6802             REPLACE ALL OCCURRENCES OF ',' IN LV_CHAR WITH ' '.
6803             CONDENSE LV_CHAR.
6804             CONCATENATE LS_HEAD-HEAD LV_CHAR ',' INTO LS_HEAD-HEAD.
6805
6806             ASSIGN COMPONENT 'DR_CR' OF STRUCTURE <FS_WORKAREA> TO <FS_COMP>.
6807             LV_CHAR = <FS_COMP>.
6808             REPLACE ALL OCCURRENCES OF ',' IN LV_CHAR WITH ' '.
6809             CONDENSE LV_CHAR.
6810             CONCATENATE LS_HEAD-HEAD LV_CHAR ',' INTO LS_HEAD-HEAD.
6811
6812             ASSIGN COMPONENT 'BUDAT_S' OF STRUCTURE <FS_WORKAREA> TO <FS_COMP>.
6813             LV_CHAR = <FS_COMP>.
6814             REPLACE ALL OCCURRENCES OF ',' IN LV_CHAR WITH ' '.
6815             CONDENSE LV_CHAR.
6816             CONCATENATE LS_HEAD-HEAD LV_CHAR ',' INTO LS_HEAD-HEAD.
6817
6818             ASSIGN COMPONENT 'BUDAT_E' OF STRUCTURE <FS_WORKAREA> TO <FS_COMP>.
6819             LV_CHAR = <FS_COMP>.
6820             REPLACE ALL OCCURRENCES OF ',' IN LV_CHAR WITH ' '.
6821             CONDENSE LV_CHAR.
6822             CONCATENATE LS_HEAD-HEAD LV_CHAR ',' INTO LS_HEAD-HEAD.
6823
6824             ASSIGN COMPONENT 'CPUDT_S' OF STRUCTURE <FS_WORKAREA> TO <FS_COMP>.
6825             LV_CHAR = <FS_COMP>.
6826             REPLACE ALL OCCURRENCES OF ',' IN LV_CHAR WITH ' '.
6827             CONDENSE LV_CHAR.
6828             CONCATENATE LS_HEAD-HEAD LV_CHAR ',' INTO LS_HEAD-HEAD.
6829
6830             ASSIGN COMPONENT 'CPUDT_E' OF STRUCTURE <FS_WORKAREA> TO <FS_COMP>.
6831             LV_CHAR = <FS_COMP>.
6832             REPLACE ALL OCCURRENCES OF ',' IN LV_CHAR WITH ' '.
6833             CONDENSE LV_CHAR.
6834             CONCATENATE LS_HEAD-HEAD LV_CHAR ',' INTO LS_HEAD-HEAD.
6835
6836             ASSIGN COMPONENT 'EXTRAT_D' OF STRUCTURE <FS_WORKAREA> TO <FS_COMP>.
6837             LV_CHAR = <FS_COMP>.
6838             REPLACE ALL OCCURRENCES OF ',' IN LV_CHAR WITH ' '.
6839             CONDENSE LV_CHAR.
6840             CONCATENATE LS_HEAD-HEAD LV_CHAR ',' INTO LS_HEAD-HEAD.
6841
6842             ASSIGN COMPONENT 'NO_REC' OF STRUCTURE <FS_WORKAREA> TO <FS_COMP>.
6843             LV_CHAR = <FS_COMP>.
6844             REPLACE ALL OCCURRENCES OF ',' IN LV_CHAR WITH ' '.
6845             CONDENSE LV_CHAR.
6846             CONCATENATE LS_HEAD-HEAD LV_CHAR ',' INTO LS_HEAD-HEAD.
6847
6848             ASSIGN COMPONENT 'NO_DOC' OF STRUCTURE <FS_WORKAREA> TO <FS_COMP>.
6849             LV_CHAR = <FS_COMP>.
6850             REPLACE ALL OCCURRENCES OF ',' IN LV_CHAR WITH ' '.
6851             CONDENSE LV_CHAR.
6852             CONCATENATE LS_HEAD-HEAD LV_CHAR ',' INTO LS_HEAD-HEAD.
6853
6854             ASSIGN COMPONENT 'AMOUNT' OF STRUCTURE <FS_WORKAREA> TO <FS_COMP>.
6855             LV_CHAR = <FS_COMP>.
6856             REPLACE ALL OCCURRENCES OF ',' IN LV_CHAR WITH ' '.
6857             CONDENSE LV_CHAR.
6858             CONCATENATE LS_HEAD-HEAD LV_CHAR ',' INTO LS_HEAD-HEAD.
6859
6860             ASSIGN COMPONENT 'INV_AMT' OF STRUCTURE <FS_WORKAREA> TO <FS_COMP>.
6861             LV_CHAR = <FS_COMP>.
6862             REPLACE ALL OCCURRENCES OF ',' IN LV_CHAR WITH ' '.
6863             CONDENSE LV_CHAR.
6864             CONCATENATE LS_HEAD-HEAD LV_CHAR ',' INTO LS_HEAD-HEAD.
6865
6866             ASSIGN COMPONENT 'TDS_AMOUNT' OF STRUCTURE <FS_WORKAREA> TO <FS_COMP>.
6867             LV_CHAR = <FS_COMP>.
6868             REPLACE ALL OCCURRENCES OF ',' IN LV_CHAR WITH ' '.
6869             CONDENSE LV_CHAR.
6870             CONCATENATE LS_HEAD-HEAD LV_CHAR ',' INTO LS_HEAD-HEAD.
6871
6872             ASSIGN COMPONENT 'NO_FBL' OF STRUCTURE <FS_WORKAREA> TO <FS_COMP>.
6873             LV_CHAR = <FS_COMP>.
6874             REPLACE ALL OCCURRENCES OF ',' IN LV_CHAR WITH ' '.
6875             CONDENSE LV_CHAR.
6876             CONCATENATE LS_HEAD-HEAD LV_CHAR ',' INTO LS_HEAD-HEAD.
6877
6878             ASSIGN COMPONENT 'FBL1N_AMT' OF STRUCTURE <FS_WORKAREA> TO <FS_COMP>.
6879             LV_CHAR = <FS_COMP>.
6880             REPLACE ALL OCCURRENCES OF ',' IN LV_CHAR WITH ' '.
6881             CONDENSE LV_CHAR.
6882             CONCATENATE LS_HEAD-HEAD LV_CHAR ',' INTO LS_HEAD-HEAD.
6883
6884             APPEND LS_HEAD TO LT_HEAD.
6885             CLEAR: LS_HEAD.
6886           ENDLOOP.
6887           CLEAR:GV_FILE.
6888           CONCATENATE 'Inv Extract Control Table'  GV_FILE INTO GV_FILE.
6889
6890           IF R_AL11 = 'X' AND LT_HEAD[] IS NOT INITIAL.
6891             ADD 1 TO GV_FILECOUNT.
6892             PERFORM DOWNLOAD_FILE_AL11_C TABLES LT_HEAD. " create file in application server
6893           ELSEIF R_LOCL = 'X'.
6894             ADD 1 TO GV_FILECOUNT.
6895             PERFORM CNTR_EXCEL_DOWNLOAD.
6896           ENDIF.
6897         ENDIF.
6898
6899
6900       ELSEIF R_RPT = 'X'.
6901         IF GT_TDS IS NOT INITIAL.
6902           GS_LAYO-COLWIDTH_OPTIMIZE = 'X'.
6903           CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
6904             EXPORTING
6905               I_CALLBACK_PROGRAM = SY-REPID
6906               IS_LAYOUT          = GS_LAYO
6907               IT_FIELDCAT        = LT_FCAT
6908             TABLES
6909               T_OUTTAB           = GT_TDS
6910             EXCEPTIONS
6911               PROGRAM_ERROR      = 1
6912               OTHERS             = 2.
6913           IF SY-SUBRC <> 0.
6914             IF P_BYPASS IS INITIAL.
6915               MESSAGE 'NO DATA FOUND'TYPE 'S' DISPLAY LIKE 'E' .
6916             ENDIF.
6917           ENDIF.
6918         ENDIF.
6919       ENDIF.
6920     ELSE.
6921       IF P_BYPASS IS INITIAL.
6922         MESSAGE 'NO DATA FOUND'TYPE 'S' DISPLAY LIKE 'E' .
6923       ENDIF.
6924     ENDIF.
6925
6926
6927   ENDFORM.                    "display_alv_report
6928
6929   *&---------------------------------------------------------------------*
6930   *&      Form  DOWNLOAD_FILE_AL11
6931   *&---------------------------------------------------------------------*
6932   *       Download file to Application server
6933   *----------------------------------------------------------------------*
6934   *  -->  p1        text
6935   *  <--  p2        text
6936   *----------------------------------------------------------------------*
6937   FORM DOWNLOAD_FILE_AL11 TABLES LT_HEAD TYPE TTY_HEAD.
6938
6939   *    *    *    ------------------------give permisiion to OS level using below script---------------------------
6940     DATA: EXEC              TYPE TABLE OF BTCXPM,
6941           LT_FBL1N_DEL_TEMP TYPE TABLE OF RFPOSXEXT,
6942           LS_FBL1N_DEL_TEMP LIKE LINE OF LT_FBL1N_DEL_TEMP,
6943           LV_FILE           TYPE PATH-PATHEXTERN,
6944           LV_FILECOUNT(3)   TYPE N,
6945           LS_MAIN_HEAD      TYPE TY_HEAD,
6946           LS_MAIN_HEAD1     TYPE TY_HEAD,
6947           LT_TEMP_HEAD      TYPE TTY_HEAD,
6948           LV_FLAG           TYPE C.
6949
6950
6951     CALL FUNCTION 'SXPG_CALL_SYSTEM'
6952       EXPORTING
6953         COMMANDNAME                = 'Z_XI_NFS_FP'
6954   *     ADDITIONAL_PARAMETERS      = ' '
6955   *     TRACE                      =
6956   *     IMPORTING
6957   *     STATUS                     =
6958   *     EXITCODE                   =
6959       TABLES
6960         EXEC_PROTOCOL              = EXEC
6961       EXCEPTIONS
6962         NO_PERMISSION              = 1
6963         COMMAND_NOT_FOUND          = 2
6964         PARAMETERS_TOO_LONG        = 3
6965         SECURITY_RISK              = 4
6966         WRONG_CHECK_CALL_INTERFACE = 5
6967         PROGRAM_START_ERROR        = 6
6968         PROGRAM_TERMINATION_ERROR  = 7
6969         X_ERROR                    = 8
6970         PARAMETER_EXPECTED         = 9
6971         TOO_MANY_PARAMETERS        = 10
6972         ILLEGAL_COMMAND            = 11
6973         OTHERS                     = 12.
6974     IF SY-SUBRC <> 0.
6975   * Implement suitable error handling here
6976     ENDIF.
6977
6978     IF LT_FBL1N_DEL[] IS NOT INITIAL.
6979       CLEAR LT_UPD.
6980       SELECT *
6981         FROM ZEYTDS_RESON_STR
6982         INTO TABLE LT_UPD
6983         FOR ALL ENTRIES IN LT_FBL1N_DEL
6984         WHERE BUKRS = LT_FBL1N_DEL-BUKRS
6985         AND BELNR = LT_FBL1N_DEL-BELNR
6986         AND GJAHR = LT_FBL1N_DEL-GJAHR
6987         AND FLAG = 'I'.
6988       IF SY-SUBRC = 0.
6989         SORT LT_UPD BY BUKRS BELNR GJAHR.
6990       ENDIF.
6991
6992       CLEAR LT_LFA1.
6993       SELECT LIFNR NAME1 NAME2 STRAS LAND1 PSTLZ  ORT01 REGIO
6994              MCOD3 ADRNR STCD1 STCD3 KTOKK
6995         FROM LFA1
6996         INTO TABLE LT_LFA1
6997         FOR ALL ENTRIES IN LT_FBL1N_DEL
6998         WHERE LIFNR = LT_FBL1N_DEL-KONTO.
6999       IF SY-SUBRC = 0.
7000         SORT LT_LFA1 BY LIFNR.
7001         SELECT *
7002           FROM ZEYTDS_ACCT_GRP
7003           INTO TABLE LT_ACCT_GROUP
7004           FOR ALL ENTRIES IN LT_LFA1
7005           WHERE KTOKK = LT_LFA1-KTOKK.
7006         IF SY-SUBRC = 0.
7007           SORT LT_ACCT_GROUP BY KTOKK.
7008         ENDIF.
7009       ENDIF.
7010     ENDIF.
7011
7012     SORT LT_FBL1N_DEL BY BUKRS.
7013
7014     CLEAR LT_FBL1N_DEL_TEMP.
7015     LT_FBL1N_DEL_TEMP[] = LT_FBL1N_DEL.
7016
7017     CLEAR:LT_EXTRA[].
7018     DELETE ADJACENT DUPLICATES FROM LT_FBL1N_DEL_TEMP COMPARING BUKRS.
7019
7020
7021     LOOP AT LT_FBL1N_DEL_TEMP INTO LS_FBL1N_DEL_TEMP.
7022
7023       LOOP AT LT_FBL1N_DEL INTO LS_FBL1N_DEL WHERE BUKRS = LS_FBL1N_DEL_TEMP-BUKRS.
7024         LS_EXTRA-BELNR = LS_FBL1N_DEL-BELNR.
7025         LS_EXTRA-BUKRS = LS_FBL1N_DEL-BUKRS.
7026         LS_EXTRA-BLART = LS_FBL1N_DEL-BLART.
7027
7028         CONCATENATE LS_FBL1N_DEL-BUDAT+0(4) '-' LS_FBL1N_DEL-BUDAT+4(2) '-'
7029                     LS_FBL1N_DEL-BUDAT+6(2) INTO  LS_EXTRA-BUDAT.
7030
7031         IF LS_FBL1N_DEL-DMSHB < 0.
7032           LS_FBL1N_DEL-DMSHB = LS_FBL1N_DEL-DMSHB * - 1.
7033         ENDIF.
7034
7035         LS_EXTRA-DMBTR = LS_FBL1N_DEL-DMSHB.
7036         LS_EXTRA-SHKZG = LS_FBL1N_DEL-SHKZG.
7037
7038         READ TABLE LT_LFA1 INTO LS_LFA1 WITH  KEY LIFNR = LS_FBL1N_DEL-KONTO BINARY SEARCH.
7039         IF SY-SUBRC = 0.
7040           READ TABLE LT_ACCT_GROUP TRANSPORTING NO FIELDS WITH  KEY KTOKK = LS_LFA1-KTOKK BINARY SEARCH.
7041           IF SY-SUBRC = 0.
7042             LS_EXTRA-TEXT = 'Employee Vendor'.
7043           ENDIF.
7044           "SOC Added by Anil Maurya on 11.01.2024
7045         ELSEIF SY-SUBRC <> 0.
7046           READ TABLE LT_DEL_BEL_K INTO DATA(LS_DEL_BEL_K) WITH KEY BUKRS = LS_FBL1N_DEL-BUKRS
7047                                                                    BELNR = LS_FBL1N_DEL-BELNR
7048                                                                    GJAHR = LS_FBL1N_DEL-GJAHR BINARY SEARCH.
7049           IF SY-SUBRC = 0.
7050             LS_EXTRA-TEXT = 'Vendor Clearing'.
7051           ENDIF.
7052           "EOC Added by Anil Maurya on 11.01.2024
7053         ENDIF.
7054         IF LS_EXTRA-TEXT IS INITIAL.
7055           READ TABLE LT_UPD INTO LS_UPD WITH  KEY BUKRS = LS_FBL1N_DEL-BUKRS
7056                                                   BELNR = LS_FBL1N_DEL-BELNR
7057                                                   GJAHR = LS_FBL1N_DEL-GJAHR.
7058           IF SY-SUBRC = 0.
7059             LS_EXTRA-TEXT = LS_UPD-TEXT.
7060           ENDIF.
7061         ENDIF.
7062         SHIFT LS_EXTRA-BELNR LEFT DELETING LEADING '0'.
7063         APPEND LS_EXTRA TO LT_EXTRA.
7064         CLEAR : LS_EXTRA.
7065       ENDLOOP.
7066       APPEND LS_EXTRA TO LT_EXTRA.
7067     ENDLOOP.
7068
7069     READ TABLE LT_HEAD INTO LS_MAIN_HEAD1 INDEX 1.
7070
7071     LOOP AT LT_HEAD  TRANSPORTING NO FIELDS WHERE  HEAD IS NOT INITIAL.
7072       CLEAR : LT_TEMP_HEAD.
7073       IF P_LINES IS NOT INITIAL.
7074         APPEND LINES OF LT_HEAD FROM 1 TO P_LINES TO LT_TEMP_HEAD.
7075         DELETE LT_HEAD FROM 1 TO P_LINES.
7076       ELSE.
7077         APPEND LINES OF LT_HEAD TO LT_TEMP_HEAD.
7078         CLEAR LT_HEAD.
7079       ENDIF.
7080   **  APPLICATION SERVER DIRECTORY PATH FILE CREATION
7081
7082       DELETE LT_TEMP_HEAD WHERE HEAD IS INITIAL.
7083
7084       IF P_ALFILE IS NOT INITIAL.
7085         LV_FILECOUNT = GV_FILECOUNT.
7086
7087         IF P_AL_CSV  = 'X' AND P_AL_XLS = 'X'.
7088           MESSAGE 'Kindly select only one format to push file on AL11' TYPE 'W'.
7089         ELSEIF P_AL_CSV  = 'X'.
7090           CONCATENATE P_ALFILE  GV_FILE '_' SY-DATUM '_' SY-UZEIT '_' LV_FILECOUNT '.csv' INTO LV_FILE.
7091         ELSEIF P_AL_XLS = 'X'.
7092           CONCATENATE P_ALFILE GV_FILE '_' SY-DATUM '_' SY-UZEIT '_' LV_FILECOUNT '.xls' INTO LV_FILE.
7093         ENDIF.
7094
7095         OPEN DATASET LV_FILE FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
7096         IF SY-SUBRC = 0.
7097           IF  LV_FLAG = 'X'.
7098             TRANSFER LS_MAIN_HEAD1 TO LV_FILE.
7099           ENDIF.
7100           LOOP AT LT_TEMP_HEAD INTO LS_MAIN_HEAD.
7101             TRANSFER LS_MAIN_HEAD-HEAD TO LV_FILE.
7102             CLEAR LS_MAIN_HEAD.
7103             LV_FLAG = 'X'.
7104           ENDLOOP.
7105           CLOSE DATASET LV_FILE.
7106           IF SY-SUBRC = 0 AND LV_FLAG = 'X'.
7107             MESSAGE 'File created successfully in AL11' TYPE 'S'.  "zubair-01.03.2024
7108           ELSE.
7109             MESSAGE 'No Authorization to create file in AL11' TYPE 'S'.
7110           ENDIF.
7111         ELSE.
7112           MESSAGE 'File Could not be downlaoded'TYPE 'S' DISPLAY LIKE 'E'.
7113         ENDIF.
7114       ENDIF.
7115     ENDLOOP.
7116   ENDFORM.                    "download_file_al11
7117
7118   *&---------------------------------------------------------------------*
7119   *&      Form  UPDATE_STAGING_TABLE
7120   *&---------------------------------------------------------------------*
7121   *       text
7122   *----------------------------------------------------------------------*
7123   *  -->  p1        text
7124   *  <--  p2        text
7125   *----------------------------------------------------------------------*
7126   FORM UPDATE_STAGING_TABLE .
7127     DATA : LT_FINAL_DB TYPE STANDARD TABLE OF  ZEYTDS_INV_EXT1,
7128            LS_FINAL_DB LIKE LINE OF LT_FINAL_DB.
7129
7130
7131     LOOP AT GT_FINAL_TDS INTO GS_FINAL_TDS.
7132       MOVE-CORRESPONDING GS_FINAL_TDS TO LS_FINAL_DB.
7133       CONCATENATE GS_FINAL_TDS-BUDAT+4(2) GS_FINAL_TDS-BUDAT+0(4) INTO LS_FINAL_DB-RETURN_PERIOD.
7134       LS_FINAL_DB-BUZEI = GS_FINAL_TDS-LINENUMBER.
7135       LS_FINAL_DB-BUZEI = |{ LS_FINAL_DB-BUZEI ALPHA = IN }|.
7136       APPEND LS_FINAL_DB TO LT_FINAL_DB.
7137     ENDLOOP.
7138
7139     IF LT_FINAL_DB IS NOT INITIAL.
7140       MODIFY ZEYTDS_INV_EXT1 FROM TABLE LT_FINAL_DB.
7141       IF SY-SUBRC = 0.
7142         MESSAGE  'Records updated successfully' TYPE 'S'.  "zubair-01.03.2024
7143       ENDIF.
7144     ENDIF.
7145
7146   ENDFORM.                    "update_staging_table
7147   *&---------------------------------------------------------------------*
7148   *&      Form  GET_DATA_FROM_TABLE
7149   *&---------------------------------------------------------------------*
7150   *       text
7151   *----------------------------------------------------------------------*
7152   *  -->  p1        text
7153   *  <--  p2        text
7154   *----------------------------------------------------------------------*
7155   FORM GET_DATA_FROM_TABLE .
7156
7157     DATA : LT_FINAL_DB TYPE STANDARD TABLE OF ZEYTDS_INV_EXT1,
7158            LS_FINAL_DB LIKE LINE OF LT_FINAL_DB.
7159
7160     SELECT * FROM ZEYTDS_INV_EXT1 INTO TABLE LT_FINAL_DB  WHERE BUKRS1  IN  S_BUKRS AND
7161                                                              GJAHR   =  P_GJAHR AND
7162                                                              BUDAT   IN S_DATE AND CR_DATE IN CR_DATE AND
7163                                                              BELNR   IN S_BELNR AND
7164                                                        DEDUCTEE_CODE IN S_LIFNR.
7165     IF SY-SUBRC = 0.
7166       SORT LT_FINAL_DB BY BUKRS1 BELNR GJAHR BUZEI.
7167     ENDIF.
7168     CLEAR : GT_FINAL_TDS.
7169     IF LT_FINAL_DB IS NOT INITIAL.
7170       LOOP AT LT_FINAL_DB INTO LS_FINAL_DB.
7171   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 10.06.2026  for ATC
7172   *       MOVE-CORRESPONDING LS_FINAL_DB TO GS_FINAL_TDS.
7173         MOVE-CORRESPONDING LS_FINAL_DB TO GS_FINAL_TDS.  "#EC CI_FLDEXT_OK[2610650]
7174   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 10.06.2026 for ATC
7175         APPEND GS_FINAL_TDS TO GT_FINAL_TDS.
7176       ENDLOOP.
7177     ENDIF.
7178
7179     SELECT * FROM ZEYTDS_DOCTYPE INTO TABLE LT_ZTDS_DOCTYPE WHERE BUKRS IN S_BUKRS AND EXTRAT_TYPE = 'INV'.
7180     LOOP AT LT_ZTDS_DOCTYPE INTO LS_ZTDS_DOCTYPE.
7181       LS_R_BLART-SIGN = 'I'.
7182       LS_R_BLART-OPTION = 'EQ'.
7183       LS_R_BLART-LOW = LS_ZTDS_DOCTYPE-BLART.
7184       APPEND LS_R_BLART TO R_BLART.
7185       CLEAR LS_R_BLART.
7186     ENDLOOP.
7187   ENDFORM.                    "get_data_from_table
7188   *&---------------------------------------------------------------------*
7189   *&      Form  DELETE_STAGING_TABLE
7190   *&---------------------------------------------------------------------*
7191   *       text
7192   *----------------------------------------------------------------------*
7193   *  -->  p1        text
7194   *  <--  p2        text
7195   *----------------------------------------------------------------------*
7196   FORM DELETE_STAGING_TABLE .
7197     DELETE FROM ZEYTDS_INV_EXT1 WHERE BUKRS1  IN S_BUKRS AND
7198                                    GJAHR   =  P_GJAHR AND
7199                                    BUDAT   IN S_DATE AND CR_DATE IN CR_DATE AND
7200                                    BELNR   IN S_BELNR AND
7201                                    DEDUCTEE_CODE   IN S_LIFNR.
7202     IF SY-SUBRC = 0.
7203       MESSAGE 'Records Deleted successfully' TYPE 'S'.  "zubair-01.03.2024
7204     ENDIF.
7205   ENDFORM.                    "delete_staging_table
7206   *&---------------------------------------------------------------------*
7207   *&      Form  xlsx_download
7208   *&---------------------------------------------------------------------*
7209   *       text
7210   *----------------------------------------------------------------------*
7211   FORM XLSX_DOWNLOAD USING F_IT_FCAT TYPE SLIS_T_FIELDCAT_ALV
7212                            F_T_FINAL TYPE ANY TABLE .
7213     DATA: LO_ALV           TYPE REF TO CL_SALV_TABLE,
7214           LO_COLUMNS       TYPE REF TO CL_SALV_COLUMNS_TABLE,
7215           LO_AGGREG        TYPE REF TO CL_SALV_AGGREGATIONS,
7216           LV_TEMP_FILEPATH TYPE STRING,
7217           LV_FILEPATH      TYPE STRING,
7218           LT_FINAL         TYPE TABLE OF ZEYTDS_INV_EXT_N,
7219           LT_FIELDCATALOG  TYPE LVC_T_FCAT.
7220
7221     FIELD-SYMBOLS: <LFS_FCAT>         TYPE SLIS_FIELDCAT_ALV,
7222                    <LFS_FIELDCATALOG> TYPE LVC_S_FCAT.
7223
7224     LT_FINAL = F_T_FINAL.
7225
7226     TRY .
7227         CL_SALV_TABLE=>FACTORY(
7228         EXPORTING
7229           LIST_DISPLAY = ABAP_FALSE
7230          IMPORTING
7231           R_SALV_TABLE = LO_ALV
7232          CHANGING
7233           T_TABLE      = LT_FINAL ).
7234
7235         LO_COLUMNS  = LO_ALV->GET_COLUMNS( ).
7236         LO_AGGREG   = LO_ALV->GET_AGGREGATIONS( ).
7237         LT_FIELDCATALOG = CL_SALV_CONTROLLER_METADATA=>GET_LVC_FIELDCATALOG(
7238                                       R_COLUMNS      = LO_COLUMNS
7239                                       R_AGGREGATIONS = LO_AGGREG ).
7240       CATCH CX_SALV_MSG .
7241         IF P_BYPASS IS INITIAL.
7242           MESSAGE 'Unable to retrieve ALV data'TYPE 'S' DISPLAY LIKE 'E'.
7243         ENDIF.
7244       CATCH CX_SALV_NOT_FOUND .
7245         IF P_BYPASS IS INITIAL.
7246           MESSAGE 'Data Not Found'TYPE 'S' DISPLAY LIKE 'E'.
7247         ENDIF.
7248     ENDTRY.
7249     LOOP AT F_IT_FCAT ASSIGNING <LFS_FCAT>.
7250       READ TABLE LT_FIELDCATALOG ASSIGNING <LFS_FIELDCATALOG> WITH KEY FIELDNAME = <LFS_FCAT>-FIELDNAME.
7251       IF SY-SUBRC = 0.
7252         <LFS_FIELDCATALOG>-REPTEXT = <LFS_FCAT>-SELTEXT_L.
7253       ENDIF.
7254     ENDLOOP.
7255     LV_FILECOUNT = GV_FILECOUNT.
7256
7257     IF P_LCFILE IS NOT INITIAL.
7258       CONCATENATE P_LCFILE GV_FILE INTO LV_FILEPATH SEPARATED BY GC_FILE_SEPARATOR.
7259     ELSE.
7260       CONCATENATE GC_DRIVE_ROOT GC_FOLDER_ROOT GV_FILE INTO LV_FILEPATH SEPARATED BY GC_FILE_SEPARATOR.
7261     ENDIF.
7262
7263     IF P_LC_CSV = 'X' AND P_LC_XLS = 'X'.
7264       MESSAGE 'Kindly select only one format to download file in local system' TYPE 'W'.
7265     ELSEIF P_LC_XLS = 'X'.
7266       CONCATENATE LV_FILEPATH '_' SY-DATUM '_' SY-UZEIT '_' LV_FILECOUNT '.xlsx' INTO LV_TEMP_FILEPATH.
7267     ELSEIF P_LC_CSV = 'X'.
7268       CONCATENATE LV_FILEPATH '_' SY-DATUM '_' SY-UZEIT '_' LV_FILECOUNT '.csv' INTO LV_TEMP_FILEPATH.
7269     ENDIF.
7270
7271     CALL METHOD YCL_TCS_XLSX_FILE_DOWNLOAD=>FILE_DOWNLOAD
7272       EXPORTING
7273         IM_T_FIELDCATALOG = LT_FIELDCATALOG
7274         IM_V_FILE         = LV_TEMP_FILEPATH
7275       CHANGING
7276         IM_T_DATA         = LT_FINAL
7277       EXCEPTIONS
7278         ERROR_IN_DOWNLOAD = 1
7279         OTHERS            = 2.
7280     IF SY-SUBRC EQ 0.
7281       MESSAGE 'Downloading Successful' TYPE 'S'.  "zubair-01.03.2024
7282     ELSE.
7283       MESSAGE 'Downloading Successful' TYPE 'S'.  "zubair-01.03.2024
7284     ENDIF.
7285
7286   ENDFORM.                    "xlsx_download
7287   *&---------------------------------------------------------------------*
7288   *&      Form  CNTR_EXCEL_DOWNLOAD
7289   *&---------------------------------------------------------------------*
7290   *       text
7291   *----------------------------------------------------------------------*
7292   *  -->  p1        text
7293   *  <--  p2        text
7294   *----------------------------------------------------------------------*
7295   FORM CNTR_EXCEL_DOWNLOAD .
7296
7297     DATA: LT_FBL1N_DEL_TEMP    TYPE TABLE OF RFPOSXEXT,
7298           LS_FBL1N_DEL_TEMP    LIKE LINE OF LT_FBL1N_DEL_TEMP,
7299           L_IXML               TYPE REF TO IF_IXML,
7300           L_DOCUMENT           TYPE REF TO IF_IXML_DOCUMENT,
7301           L_ELEMENT_ROOT       TYPE REF TO IF_IXML_ELEMENT,
7302           NS_ATTRIBUTE         TYPE REF TO IF_IXML_ATTRIBUTE,
7303           R_ELEMENT_PROPERTIES TYPE REF TO IF_IXML_ELEMENT,
7304           R_WORKSHEET          TYPE REF TO IF_IXML_ELEMENT,
7305           R_TABLE              TYPE REF TO IF_IXML_ELEMENT,
7306           R_COLUMN             TYPE REF TO IF_IXML_ELEMENT,
7307           R_ROW                TYPE REF TO IF_IXML_ELEMENT,
7308           R_CELL               TYPE REF TO IF_IXML_ELEMENT,
7309           R_DATA               TYPE REF TO IF_IXML_ELEMENT,
7310           L_VALUE              TYPE STRING,
7311           R_STYLES             TYPE REF TO IF_IXML_ELEMENT,
7312           R_STYLE              TYPE REF TO IF_IXML_ELEMENT,
7313           R_STYLE1             TYPE REF TO IF_IXML_ELEMENT,
7314           R_FORMAT             TYPE REF TO IF_IXML_ELEMENT,
7315           R_BORDER             TYPE REF TO IF_IXML_ELEMENT,
7316           L_STREAMFACTORY      TYPE REF TO IF_IXML_STREAM_FACTORY ##NEEDED,
7317           L_OSTREAM            TYPE REF TO IF_IXML_OSTREAM ##NEEDED,
7318           L_RENDERER           TYPE REF TO IF_IXML_RENDERER ##NEEDED,
7319   *        l_document           TYPE REF TO if_ixml_document ##NEEDED,
7320           L_XML_TABLE          TYPE TABLE OF XML_LINE ##NEEDED,
7321           L_XML_SIZE           TYPE I ##NEEDED,
7322           L_RC                 TYPE I ##NEEDED,
7323           LT_TAB_DATA          TYPE TABLE OF STRING,
7324           LS_TAB_DATA          TYPE STRING,
7325           ITAB_FINAL           TYPE TRUXS_T_TEXT_DATA,
7326           LT_HEADER1           TYPE TABLE OF STRING,
7327           LS_HEADER1           TYPE STRING,
7328           LV_AMOUNT            TYPE CHAR25,
7329           LV_AMOUNT2           TYPE CHAR33,
7330           LV_AMOUNT3           TYPE CHAR25,
7331           LV_AMOUNT4           TYPE CHAR25.
7332
7333     IF LT_FBL1N_DEL[] IS NOT INITIAL.
7334       CLEAR LT_UPD .
7335       SELECT *
7336         FROM ZEYTDS_RESON_STR
7337         INTO TABLE LT_UPD
7338         FOR ALL ENTRIES IN LT_FBL1N_DEL
7339         WHERE BUKRS = LT_FBL1N_DEL-BUKRS
7340         AND BELNR = LT_FBL1N_DEL-BELNR
7341         AND GJAHR = LT_FBL1N_DEL-GJAHR
7342         AND FLAG = 'I'.
7343
7344       IF SY-SUBRC = 0.
7345         SORT LT_UPD BY BUKRS BELNR GJAHR.
7346       ENDIF.
7347
7348       CLEAR LT_LFA1.
7349       SELECT LIFNR NAME1 NAME2 STRAS LAND1 PSTLZ ORT01
7350         REGIO MCOD3 ADRNR STCD1 STCD3 KTOKK
7351         FROM LFA1
7352         INTO TABLE LT_LFA1
7353         FOR ALL ENTRIES IN LT_FBL1N_DEL
7354         WHERE LIFNR = LT_FBL1N_DEL-KONTO.
7355       IF SY-SUBRC = 0.
7356         SORT LT_LFA1 BY LIFNR.
7357         SELECT *
7358           FROM ZEYTDS_ACCT_GRP
7359           INTO TABLE LT_ACCT_GROUP
7360           FOR ALL ENTRIES IN LT_LFA1
7361           WHERE KTOKK = LT_LFA1-KTOKK.
7362         IF SY-SUBRC = 0.
7363           SORT LT_ACCT_GROUP BY KTOKK.
7364         ENDIF.
7365       ENDIF.
7366     ENDIF.
7367
7368     SORT LT_FBL1N_DEL BY BUKRS.
7369     CLEAR LT_FBL1N_DEL_TEMP.
7370     LT_FBL1N_DEL_TEMP[] = LT_FBL1N_DEL.
7371     CLEAR:LT_EXTRA[].
7372
7373     DELETE ADJACENT DUPLICATES FROM LT_FBL1N_DEL_TEMP COMPARING BUKRS.
7374     DELETE LT_FBL1N_DEL WHERE BELNR NOT IN S_BELNR[]. "(+)EY-RAHUL
7375
7376     LOOP AT LT_FBL1N_DEL_TEMP INTO LS_FBL1N_DEL_TEMP.
7377
7378       LOOP AT LT_FBL1N_DEL INTO LS_FBL1N_DEL WHERE BUKRS = LS_FBL1N_DEL_TEMP-BUKRS.
7379         LS_EXTRA-BELNR = LS_FBL1N_DEL-BELNR.
7380         LS_EXTRA-BUKRS = LS_FBL1N_DEL-BUKRS.
7381         LS_EXTRA-BLART = LS_FBL1N_DEL-BLART.
7382
7383         CONCATENATE LS_FBL1N_DEL-BUDAT+0(4) '-' LS_FBL1N_DEL-BUDAT+4(2) '-'
7384                     LS_FBL1N_DEL-BUDAT+6(2) INTO  LS_EXTRA-BUDAT.
7385
7386         IF LS_FBL1N_DEL-DMSHB < 0.
7387           LS_FBL1N_DEL-DMSHB = LS_FBL1N_DEL-DMSHB * - 1.
7388         ENDIF.
7389
7390         LS_EXTRA-DMBTR = LS_FBL1N_DEL-DMSHB.
7391         LS_EXTRA-SHKZG = LS_FBL1N_DEL-SHKZG.
7392
7393         READ TABLE LT_LFA1 INTO LS_LFA1 WITH  KEY LIFNR = LS_FBL1N_DEL-KONTO BINARY SEARCH.
7394         IF SY-SUBRC = 0.
7395           READ TABLE LT_ACCT_GROUP TRANSPORTING NO FIELDS WITH  KEY KTOKK = LS_LFA1-KTOKK BINARY SEARCH.
7396           IF SY-SUBRC = 0.
7397             LS_EXTRA-TEXT = 'Employee Vendor'.
7398           ENDIF.
7399           "SOC Added by Anil Maurya on 11.01.2024
7400         ELSEIF SY-SUBRC <> 0.
7401           READ TABLE LT_DEL_BEL_K INTO DATA(LS_DEL_BEL_K) WITH KEY BUKRS = LS_FBL1N_DEL-BUKRS
7402                                                                    BELNR = LS_FBL1N_DEL-BELNR
7403                                                                    GJAHR = LS_FBL1N_DEL-GJAHR BINARY SEARCH.
7404           IF SY-SUBRC = 0.
7405             LS_EXTRA-TEXT = 'Vendor Clearing'.
7406             "EOC Added by Anil Maurya on 11.01.2024
7407           ENDIF.
7408         ENDIF.
7409
7410         IF LS_EXTRA-TEXT IS INITIAL.
7411           READ TABLE LT_UPD INTO LS_UPD WITH  KEY BUKRS = LS_FBL1N_DEL-BUKRS
7412                                                   BELNR = LS_FBL1N_DEL-BELNR
7413                                                   GJAHR = LS_FBL1N_DEL-GJAHR BINARY SEARCH.
7414           IF SY-SUBRC = 0.
7415             LS_EXTRA-TEXT = LS_UPD-TEXT.
7416           ENDIF.
7417         ENDIF.
7418         SHIFT LS_EXTRA-BELNR LEFT DELETING LEADING '0'.
7419         APPEND LS_EXTRA TO LT_EXTRA.
7420         CLEAR : LS_EXTRA.
7421       ENDLOOP.
7422       APPEND LS_EXTRA TO LT_EXTRA.
7423     ENDLOOP.
7424
7425     L_IXML = CL_IXML=>CREATE( ).
7426
7427   * Creating the DOM Object Model
7428     L_DOCUMENT = L_IXML->CREATE_DOCUMENT( ).
7429
7430   * Create Root Node 'Workbook'
7431     L_ELEMENT_ROOT  = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Workbook'  PARENT = L_DOCUMENT ) ##NO_TEXT.
7432     L_ELEMENT_ROOT->SET_ATTRIBUTE( NAME = 'xmlns'  VALUE = 'urn:schemas-microsoft-com:office:spreadsheet' )  ##NO_TEXT.
7433     NS_ATTRIBUTE = L_DOCUMENT->CREATE_NAMESPACE_DECL( NAME = 'ss'  PREFIX = 'xmlns'  URI = 'urn:schemas-microsoft-com:office:spreadsheet' )  ##NO_TEXT.
7434     L_ELEMENT_ROOT->SET_ATTRIBUTE_NODE( NS_ATTRIBUTE ).
7435     NS_ATTRIBUTE = L_DOCUMENT->CREATE_NAMESPACE_DECL( NAME = 'x'  PREFIX = 'xmlns'  URI = 'urn:schemas-microsoft-com:office:excel' )  ##NO_TEXT.
7436     L_ELEMENT_ROOT->SET_ATTRIBUTE_NODE( NS_ATTRIBUTE ).
7437
7438   * Create node for document properties.
7439     R_ELEMENT_PROPERTIES = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'REPORT'  PARENT = L_ELEMENT_ROOT ).
7440     L_VALUE = SY-UNAME.
7441     L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Author'  VALUE = L_VALUE  PARENT = R_ELEMENT_PROPERTIES  ) ##NO_TEXT.
7442
7443   * Styles
7444     R_STYLES = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Styles'  PARENT = L_ELEMENT_ROOT  ) ##NO_TEXT.
7445
7446
7447     "header text
7448     R_STYLE  = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Style'   PARENT = R_STYLES  ) ##NO_TEXT.
7449     R_STYLE->SET_ATTRIBUTE_NS( NAME = 'ID'  PREFIX = 'ss'  VALUE = 'Header1' ) ##NO_TEXT.
7450     R_FORMAT  = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Font'  PARENT = R_STYLE  ) ##NO_TEXT.
7451     R_FORMAT->SET_ATTRIBUTE_NS( NAME = 'Bold'  PREFIX = 'ss'  VALUE = '1' ) ##NO_TEXT.
7452     R_FORMAT  = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Interior' PARENT = R_STYLE  ) ##NO_TEXT.
7453     R_FORMAT->SET_ATTRIBUTE_NS( NAME = 'Color'   PREFIX = 'ss'  VALUE = '#cdc9c9' ) ##NO_TEXT.
7454     R_FORMAT->SET_ATTRIBUTE_NS( NAME = 'Pattern' PREFIX = 'ss'  VALUE = 'Solid' ) ##NO_TEXT.
7455     R_FORMAT  = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Alignment'  PARENT = R_STYLE  ) ##NO_TEXT.
7456     R_FORMAT->SET_ATTRIBUTE_NS( NAME = 'Vertical'  PREFIX = 'ss'  VALUE = 'Center' ) ##NO_TEXT.
7457     R_FORMAT->SET_ATTRIBUTE_NS( NAME = 'Horizontal'  PREFIX = 'ss'  VALUE = 'Center' ) ##NO_TEXT.
7458     R_BORDER  = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Borders'  PARENT = R_STYLE ) ##NO_TEXT.
7459     R_FORMAT  = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Border'   PARENT = R_BORDER  ) ##NO_TEXT.
7460     R_FORMAT->SET_ATTRIBUTE_NS( NAME = 'Position'  PREFIX = 'ss'  VALUE = 'Bottom' ) ##NO_TEXT.
7461     R_FORMAT->SET_ATTRIBUTE_NS( NAME = 'LineStyle'  PREFIX = 'ss'  VALUE = 'Continuous' ) ##NO_TEXT.
7462     R_FORMAT->SET_ATTRIBUTE_NS( NAME = 'Weight'  PREFIX = 'ss'  VALUE = '1' ) ##NO_TEXT.
7463     R_FORMAT  = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Border'   PARENT = R_BORDER  ) ##NO_TEXT.
7464     R_FORMAT->SET_ATTRIBUTE_NS( NAME = 'Position'  PREFIX = 'ss'  VALUE = 'Left' ) ##NO_TEXT.
7465     R_FORMAT->SET_ATTRIBUTE_NS( NAME = 'LineStyle'  PREFIX = 'ss'  VALUE = 'Continuous' ) ##NO_TEXT.
7466     R_FORMAT->SET_ATTRIBUTE_NS( NAME = 'Weight'  PREFIX = 'ss'  VALUE = '1' ) ##NO_TEXT.
7467     R_FORMAT  = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Border'   PARENT = R_BORDER  ) ##NO_TEXT.
7468     R_FORMAT->SET_ATTRIBUTE_NS( NAME = 'Position'  PREFIX = 'ss'  VALUE = 'Top' ) ##NO_TEXT.
7469     R_FORMAT->SET_ATTRIBUTE_NS( NAME = 'LineStyle'  PREFIX = 'ss'  VALUE = 'Continuous' ) ##NO_TEXT.
7470     R_FORMAT->SET_ATTRIBUTE_NS( NAME = 'Weight'  PREFIX = 'ss'  VALUE = '1' ) ##NO_TEXT.
7471     R_FORMAT  = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Border'   PARENT = R_BORDER  ) ##NO_TEXT.
7472     R_FORMAT->SET_ATTRIBUTE_NS( NAME = 'Position'  PREFIX = 'ss'  VALUE = 'Right' ) ##NO_TEXT.
7473     R_FORMAT->SET_ATTRIBUTE_NS( NAME = 'LineStyle'  PREFIX = 'ss'  VALUE = 'Continuous' ) ##NO_TEXT.
7474     R_FORMAT->SET_ATTRIBUTE_NS( NAME = 'Weight'  PREFIX = 'ss'  VALUE = '1' ) ##NO_TEXT.
7475
7476
7477   * Style for Data
7478     R_STYLE1  = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Style'   PARENT = R_STYLES  ) ##NO_TEXT.
7479     R_STYLE1->SET_ATTRIBUTE_NS( NAME = 'ID'  PREFIX = 'ss'  VALUE = 'Data' ) ##NO_TEXT.
7480     R_BORDER  = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Borders'  PARENT = R_STYLE1 ) ##NO_TEXT.
7481     R_FORMAT  = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Border'   PARENT = R_BORDER  ) ##NO_TEXT.
7482     R_FORMAT->SET_ATTRIBUTE_NS( NAME = 'Position'  PREFIX = 'ss'  VALUE = 'Bottom' ) ##NO_TEXT.
7483     R_FORMAT->SET_ATTRIBUTE_NS( NAME = 'LineStyle'  PREFIX = 'ss'  VALUE = 'Continuous' ) ##NO_TEXT.
7484     R_FORMAT->SET_ATTRIBUTE_NS( NAME = 'Weight'  PREFIX = 'ss'  VALUE = '1' ) ##NO_TEXT.
7485     R_FORMAT  = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Border'   PARENT = R_BORDER  ) ##NO_TEXT.
7486     R_FORMAT->SET_ATTRIBUTE_NS( NAME = 'Position'  PREFIX = 'ss'  VALUE = 'Left' ) ##NO_TEXT.
7487     R_FORMAT->SET_ATTRIBUTE_NS( NAME = 'LineStyle'  PREFIX = 'ss'  VALUE = 'Continuous' ) ##NO_TEXT.
7488     R_FORMAT->SET_ATTRIBUTE_NS( NAME = 'Weight'  PREFIX = 'ss'  VALUE = '1' ) ##NO_TEXT.
7489     R_FORMAT  = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Border'   PARENT = R_BORDER  ) ##NO_TEXT.
7490     R_FORMAT->SET_ATTRIBUTE_NS( NAME = 'Position'  PREFIX = 'ss'  VALUE = 'Top' ) ##NO_TEXT.
7491     R_FORMAT->SET_ATTRIBUTE_NS( NAME = 'LineStyle'  PREFIX = 'ss'  VALUE = 'Continuous' ) ##NO_TEXT.
7492     R_FORMAT->SET_ATTRIBUTE_NS( NAME = 'Weight'  PREFIX = 'ss'  VALUE = '1' ) ##NO_TEXT.
7493     R_FORMAT  = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Border'   PARENT = R_BORDER  ) ##NO_TEXT.
7494     R_FORMAT->SET_ATTRIBUTE_NS( NAME = 'Position'  PREFIX = 'ss'  VALUE = 'Right' ) ##NO_TEXT.
7495     R_FORMAT->SET_ATTRIBUTE_NS( NAME = 'LineStyle'  PREFIX = 'ss'  VALUE = 'Continuous' ) ##NO_TEXT.
7496     R_FORMAT->SET_ATTRIBUTE_NS( NAME = 'Weight'  PREFIX = 'ss'  VALUE = '1' ) ##NO_TEXT.
7497     R_FORMAT->SET_ATTRIBUTE_NS( NAME = 'NumberFormat'  PREFIX = 'ss'  VALUE = '0.00' ) ##NO_TEXT.
7498
7499     R_WORKSHEET = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Worksheet'  PARENT = L_ELEMENT_ROOT ) ##NO_TEXT.
7500     R_WORKSHEET->SET_ATTRIBUTE_NS( NAME = 'Name'  PREFIX = 'ss'  VALUE = 'Invoice Control Table' ) ##NO_TEXT.
7501
7502   * Table
7503     R_TABLE = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Table'  PARENT = R_WORKSHEET ) ##NO_TEXT.
7504     R_TABLE->SET_ATTRIBUTE_NS( NAME = 'FullColumns'  PREFIX = 'x'  VALUE = '1' ).
7505     R_TABLE->SET_ATTRIBUTE_NS( NAME = 'FullRows'     PREFIX = 'x'  VALUE = '1' ).
7506
7507
7508     R_COLUMN = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Column'  PARENT = R_TABLE ) ##NO_TEXT.
7509     R_COLUMN->SET_ATTRIBUTE_NS( NAME = 'Width'  PREFIX = 'ss'  VALUE = '220' ) ##NO_TEXT.
7510
7511     R_COLUMN = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Column'  PARENT = R_TABLE ) ##NO_TEXT.
7512     R_COLUMN->SET_ATTRIBUTE_NS( NAME = 'Width'  PREFIX = 'ss'  VALUE = '150' ) ##NO_TEXT.
7513
7514     DO 50 TIMES ##NUMBER_OK.
7515       R_COLUMN = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Column'  PARENT = R_TABLE ) ##NO_TEXT.
7516       R_COLUMN->SET_ATTRIBUTE_NS( NAME = 'Width'  PREFIX = 'ss'  VALUE = '120' ) ##NO_TEXT.
7517     ENDDO.
7518
7519
7520   * Column Headers Row
7521     R_ROW = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Row'  PARENT = R_TABLE ).
7522     R_ROW->SET_ATTRIBUTE_NS( NAME = 'AutoFitHeight'  PREFIX = 'ss'  VALUE = '1' ).
7523
7524     R_CELL = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Cell'  PARENT = R_ROW ) ##NO_TEXT.
7525     R_CELL->SET_ATTRIBUTE_NS( NAME = 'StyleID'  PREFIX = 'ss'  VALUE = 'Header1' ) ##NO_TEXT.
7526     R_DATA = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Data'  VALUE = 'Source file name'  PARENT = R_CELL ) ##NO_TEXT.
7527     R_DATA->SET_ATTRIBUTE_NS( NAME = 'Type'  PREFIX = 'ss' VALUE = 'String' ) ##NO_TEXT.
7528
7529     R_CELL = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Cell'  PARENT = R_ROW ) ##NO_TEXT.
7530     R_CELL->SET_ATTRIBUTE_NS( NAME = 'StyleID'  PREFIX = 'ss'  VALUE = 'Header1' ) ##NO_TEXT.
7531     R_DATA = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Data'  VALUE = 'Company code'  PARENT = R_CELL ) ##NO_TEXT.
7532     R_DATA->SET_ATTRIBUTE_NS( NAME = 'Type'  PREFIX = 'ss' VALUE = 'String' ) ##NO_TEXT.
7533
7534     R_CELL = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Cell'  PARENT = R_ROW ) ##NO_TEXT.
7535     R_CELL->SET_ATTRIBUTE_NS( NAME = 'StyleID'  PREFIX = 'ss'  VALUE = 'Header1' ) ##NO_TEXT.
7536     R_DATA = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Data'  VALUE = 'TAN'  PARENT = R_CELL ) ##NO_TEXT.
7537     R_DATA->SET_ATTRIBUTE_NS( NAME = 'Type'  PREFIX = 'ss' VALUE = 'String' ) ##NO_TEXT.
7538
7539     R_CELL = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Cell'  PARENT = R_ROW ) ##NO_TEXT.
7540     R_CELL->SET_ATTRIBUTE_NS( NAME = 'StyleID'  PREFIX = 'ss'  VALUE = 'Header1' ) ##NO_TEXT.
7541     R_DATA = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Data'  VALUE = 'Deductee Status'  PARENT = R_CELL ) ##NO_TEXT.
7542     R_DATA->SET_ATTRIBUTE_NS( NAME = 'Type'  PREFIX = 'ss' VALUE = 'String' ) ##NO_TEXT.
7543
7544     R_CELL = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Cell'  PARENT = R_ROW ) ##NO_TEXT.
7545     R_CELL->SET_ATTRIBUTE_NS( NAME = 'StyleID'  PREFIX = 'ss'  VALUE = 'Header1' ) ##NO_TEXT.
7546     R_DATA = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Data'  VALUE = 'DR/CR'  PARENT = R_CELL ) ##NO_TEXT.
7547     R_DATA->SET_ATTRIBUTE_NS( NAME = 'Type'  PREFIX = 'ss' VALUE = 'String' ) ##NO_TEXT.
7548
7549     R_CELL = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Cell'  PARENT = R_ROW ) ##NO_TEXT.
7550     R_CELL->SET_ATTRIBUTE_NS( NAME = 'StyleID'  PREFIX = 'ss'  VALUE = 'Header1' ) ##NO_TEXT.
7551     R_DATA = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Data'  VALUE = 'Posting Period Start date'  PARENT = R_CELL ) ##NO_TEXT.
7552     R_DATA->SET_ATTRIBUTE_NS( NAME = 'Type'  PREFIX = 'ss' VALUE = 'String' ) ##NO_TEXT.
7553
7554     R_CELL = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Cell'  PARENT = R_ROW ) ##NO_TEXT.
7555     R_CELL->SET_ATTRIBUTE_NS( NAME = 'StyleID'  PREFIX = 'ss'  VALUE = 'Header1' ) ##NO_TEXT.
7556     R_DATA = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Data'  VALUE = 'Posting Period End date'  PARENT = R_CELL ) ##NO_TEXT.
7557     R_DATA->SET_ATTRIBUTE_NS( NAME = 'Type'  PREFIX = 'ss' VALUE = 'String' ) ##NO_TEXT.
7558
7559     R_CELL = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Cell'  PARENT = R_ROW ) ##NO_TEXT.
7560     R_CELL->SET_ATTRIBUTE_NS( NAME = 'StyleID'  PREFIX = 'ss'  VALUE = 'Header1' ) ##NO_TEXT.
7561     R_DATA = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Data'  VALUE = 'Creation Period Start date'  PARENT = R_CELL ) ##NO_TEXT.
7562     R_DATA->SET_ATTRIBUTE_NS( NAME = 'Type'  PREFIX = 'ss' VALUE = 'String' ) ##NO_TEXT.
7563
7564     R_CELL = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Cell'  PARENT = R_ROW ) ##NO_TEXT.
7565     R_CELL->SET_ATTRIBUTE_NS( NAME = 'StyleID'  PREFIX = 'ss'  VALUE = 'Header1' ) ##NO_TEXT.
7566     R_DATA = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Data'  VALUE = 'Creation Period End date'  PARENT = R_CELL ) ##NO_TEXT.
7567     R_DATA->SET_ATTRIBUTE_NS( NAME = 'Type'  PREFIX = 'ss' VALUE = 'String' ) ##NO_TEXT.
7568
7569     R_CELL = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Cell'  PARENT = R_ROW ) ##NO_TEXT.
7570     R_CELL->SET_ATTRIBUTE_NS( NAME = 'StyleID'  PREFIX = 'ss'  VALUE = 'Header1' ) ##NO_TEXT.
7571     R_DATA = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Data'  VALUE = 'Date of extraction'  PARENT = R_CELL ) ##NO_TEXT.
7572     R_DATA->SET_ATTRIBUTE_NS( NAME = 'Type'  PREFIX = 'ss' VALUE = 'String' ) ##NO_TEXT.
7573
7574     R_CELL = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Cell'  PARENT = R_ROW ) ##NO_TEXT.
7575     R_CELL->SET_ATTRIBUTE_NS( NAME = 'StyleID'  PREFIX = 'ss'  VALUE = 'Header1' ) ##NO_TEXT.
7576     R_DATA = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Data'  VALUE = 'No of lines items'  PARENT = R_CELL ) ##NO_TEXT.
7577     R_DATA->SET_ATTRIBUTE_NS( NAME = 'Type'  PREFIX = 'ss' VALUE = 'String' ) ##NO_TEXT.
7578
7579     R_CELL = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Cell'  PARENT = R_ROW ) ##NO_TEXT.
7580     R_CELL->SET_ATTRIBUTE_NS( NAME = 'StyleID'  PREFIX = 'ss'  VALUE = 'Header1' ) ##NO_TEXT.
7581     R_DATA = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Data'  VALUE = 'No. of Documents'  PARENT = R_CELL ) ##NO_TEXT.
7582     R_DATA->SET_ATTRIBUTE_NS( NAME = 'Type'  PREFIX = 'ss' VALUE = 'String' ) ##NO_TEXT.
7583
7584
7585     R_CELL = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Cell'  PARENT = R_ROW ) ##NO_TEXT.
7586     R_CELL->SET_ATTRIBUTE_NS( NAME = 'StyleID'  PREFIX = 'ss'  VALUE = 'Header1' ) ##NO_TEXT.
7587     R_DATA = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Data'  VALUE = 'Taxable Amount in Local Currency'  PARENT = R_CELL ) ##NO_TEXT.
7588     R_DATA->SET_ATTRIBUTE_NS( NAME = 'Type'  PREFIX = 'ss' VALUE = 'String' ) ##NO_TEXT.
7589
7590     R_CELL = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Cell'  PARENT = R_ROW ) ##NO_TEXT.
7591     R_CELL->SET_ATTRIBUTE_NS( NAME = 'StyleID'  PREFIX = 'ss'  VALUE = 'Header1' ) ##NO_TEXT.
7592     R_DATA = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Data'  VALUE = 'Invoice Amount in Local Currency'  PARENT = R_CELL ) ##NO_TEXT.
7593     R_DATA->SET_ATTRIBUTE_NS( NAME = 'Type'  PREFIX = 'ss' VALUE = 'String' ) ##NO_TEXT.
7594
7595     R_CELL = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Cell'  PARENT = R_ROW ) ##NO_TEXT.
7596     R_CELL->SET_ATTRIBUTE_NS( NAME = 'StyleID'  PREFIX = 'ss'  VALUE = 'Header1' ) ##NO_TEXT.
7597     R_DATA = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Data'  VALUE = 'TDS Amount in Local Currency'  PARENT = R_CELL ) ##NO_TEXT.
7598     R_DATA->SET_ATTRIBUTE_NS( NAME = 'Type'  PREFIX = 'ss' VALUE = 'String' ) ##NO_TEXT.
7599
7600     R_CELL = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Cell'  PARENT = R_ROW ) ##NO_TEXT.
7601     R_CELL->SET_ATTRIBUTE_NS( NAME = 'StyleID'  PREFIX = 'ss'  VALUE = 'Header1' ) ##NO_TEXT.
7602     R_DATA = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Data'  VALUE = 'No. of FBL1N Documents'  PARENT = R_CELL ) ##NO_TEXT.
7603     R_DATA->SET_ATTRIBUTE_NS( NAME = 'Type'  PREFIX = 'ss' VALUE = 'String' ) ##NO_TEXT.
7604
7605     R_CELL = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Cell'  PARENT = R_ROW ) ##NO_TEXT.
7606     R_CELL->SET_ATTRIBUTE_NS( NAME = 'StyleID'  PREFIX = 'ss'  VALUE = 'Header1' ) ##NO_TEXT.
7607     R_DATA = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Data'  VALUE = 'FBL1N Amount in Local Currency'  PARENT = R_CELL ) ##NO_TEXT.
7608     R_DATA->SET_ATTRIBUTE_NS( NAME = 'Type'  PREFIX = 'ss' VALUE = 'String' ) ##NO_TEXT.
7609
7610     APPEND INITIAL LINE TO LT_CONTROL.
7611     LOOP AT LT_CONTROL INTO LS_CONTROL.
7612
7613       R_ROW = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Row'  PARENT = R_TABLE ).
7614
7615       R_CELL = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Cell'  PARENT = R_ROW ) ##NO_TEXT.
7616       R_CELL->SET_ATTRIBUTE_NS( NAME = 'StyleID'  PREFIX = 'ss'  VALUE = 'Data' ) ##NO_TEXT.
7617       LS_STRING-TEXT = LS_CONTROL-TEXT.
7618       L_VALUE = LS_STRING-TEXT.
7619       R_DATA = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Data'  VALUE = L_VALUE   PARENT = R_CELL ) ##NO_TEXT. " Data
7620       R_DATA->SET_ATTRIBUTE_NS( NAME = 'Type'  PREFIX = 'ss'  VALUE = 'String'  ) ##NO_TEXT.                    " Cell format
7621
7622       R_CELL = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Cell'  PARENT = R_ROW ) ##NO_TEXT.
7623       R_CELL->SET_ATTRIBUTE_NS( NAME = 'StyleID'  PREFIX = 'ss'  VALUE = 'Data' ) ##NO_TEXT.
7624       LS_STRING-TEXT1 = LS_CONTROL-TEXT1.
7625       L_VALUE = LS_STRING-TEXT1.
7626       R_DATA = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Data'  VALUE = L_VALUE   PARENT = R_CELL ) ##NO_TEXT. " Data
7627       R_DATA->SET_ATTRIBUTE_NS( NAME = 'Type'  PREFIX = 'ss'  VALUE = 'String'  ) ##NO_TEXT.                    " Cell format
7628
7629       R_CELL = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Cell'  PARENT = R_ROW ) ##NO_TEXT.
7630       R_CELL->SET_ATTRIBUTE_NS( NAME = 'StyleID'  PREFIX = 'ss'  VALUE = 'Data' ) ##NO_TEXT.
7631       LS_STRING-TAN = LS_CONTROL-TAN.
7632       L_VALUE = LS_STRING-TAN.
7633       R_DATA = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Data'  VALUE = L_VALUE   PARENT = R_CELL ) ##NO_TEXT. " Data
7634       R_DATA->SET_ATTRIBUTE_NS( NAME = 'Type'  PREFIX = 'ss'  VALUE = 'String'  ) ##NO_TEXT.                    " Cell format
7635
7636       R_CELL = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Cell'  PARENT = R_ROW ) ##NO_TEXT.
7637       R_CELL->SET_ATTRIBUTE_NS( NAME = 'StyleID'  PREFIX = 'ss'  VALUE = 'Data' ) ##NO_TEXT.
7638       LS_STRING-STATUS = LS_CONTROL-STATUS.
7639       L_VALUE = LS_STRING-STATUS.
7640       R_DATA = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Data'  VALUE = L_VALUE   PARENT = R_CELL ) ##NO_TEXT. " Data
7641       R_DATA->SET_ATTRIBUTE_NS( NAME = 'Type'  PREFIX = 'ss'  VALUE = 'String'  ) ##NO_TEXT.                    " Cell format
7642
7643       R_CELL = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Cell'  PARENT = R_ROW ) ##NO_TEXT.
7644       R_CELL->SET_ATTRIBUTE_NS( NAME = 'StyleID'  PREFIX = 'ss'  VALUE = 'Data' ) ##NO_TEXT.
7645       LS_STRING-DR_CR = LS_CONTROL-DR_CR.
7646       L_VALUE = LS_STRING-DR_CR.
7647       R_DATA = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Data'  VALUE = L_VALUE   PARENT = R_CELL ) ##NO_TEXT. " Data
7648       R_DATA->SET_ATTRIBUTE_NS( NAME = 'Type'  PREFIX = 'ss'  VALUE = 'String'  ) ##NO_TEXT.                    " Cell format
7649
7650       R_CELL = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Cell'  PARENT = R_ROW ) ##NO_TEXT.
7651       R_CELL->SET_ATTRIBUTE_NS( NAME = 'StyleID'  PREFIX = 'ss'  VALUE = 'Data' ) ##NO_TEXT.
7652       LS_STRING-BUDAT_S = LS_CONTROL-BUDAT_S.
7653       L_VALUE = LS_STRING-BUDAT_S.
7654       R_DATA = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Data'  VALUE = L_VALUE   PARENT = R_CELL ) ##NO_TEXT. " Data
7655       R_DATA->SET_ATTRIBUTE_NS( NAME = 'Type'  PREFIX = 'ss'  VALUE = 'String'  ) ##NO_TEXT.                    " Cell format
7656
7657       R_CELL = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Cell'  PARENT = R_ROW ) ##NO_TEXT.
7658       R_CELL->SET_ATTRIBUTE_NS( NAME = 'StyleID'  PREFIX = 'ss'  VALUE = 'Data' ) ##NO_TEXT.
7659       LS_STRING-BUDAT_E = LS_CONTROL-BUDAT_E.
7660       L_VALUE = LS_STRING-BUDAT_E.
7661       R_DATA = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Data'  VALUE = L_VALUE   PARENT = R_CELL ) ##NO_TEXT. " Data
7662       R_DATA->SET_ATTRIBUTE_NS( NAME = 'Type'  PREFIX = 'ss'  VALUE = 'String'  ) ##NO_TEXT.                    " Cell format
7663
7664       R_CELL = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Cell'  PARENT = R_ROW ) ##NO_TEXT.
7665       R_CELL->SET_ATTRIBUTE_NS( NAME = 'StyleID'  PREFIX = 'ss'  VALUE = 'Data' ) ##NO_TEXT.
7666       LS_STRING-CPUDT_S = LS_CONTROL-CPUDT_S.
7667       L_VALUE = LS_STRING-CPUDT_S.
7668       R_DATA = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Data'  VALUE = L_VALUE   PARENT = R_CELL ) ##NO_TEXT. " Data
7669       R_DATA->SET_ATTRIBUTE_NS( NAME = 'Type'  PREFIX = 'ss'  VALUE = 'String'  ) ##NO_TEXT.                    " Cell format
7670
7671       R_CELL = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Cell'  PARENT = R_ROW ) ##NO_TEXT.
7672       R_CELL->SET_ATTRIBUTE_NS( NAME = 'StyleID'  PREFIX = 'ss'  VALUE = 'Data' ) ##NO_TEXT.
7673       LS_STRING-CPUDT_E = LS_CONTROL-CPUDT_E.
7674       L_VALUE = LS_STRING-CPUDT_E.
7675       R_DATA = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Data'  VALUE = L_VALUE   PARENT = R_CELL ) ##NO_TEXT. " Data
7676       R_DATA->SET_ATTRIBUTE_NS( NAME = 'Type'  PREFIX = 'ss'  VALUE = 'String'  ) ##NO_TEXT.                    " Cell format
7677
7678       R_CELL = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Cell'  PARENT = R_ROW ) ##NO_TEXT.
7679       R_CELL->SET_ATTRIBUTE_NS( NAME = 'StyleID'  PREFIX = 'ss'  VALUE = 'Data' ) ##NO_TEXT.
7680       LS_STRING-EXTRAT_D = LS_CONTROL-EXTRAT_D.
7681       L_VALUE = LS_STRING-EXTRAT_D.
7682       R_DATA = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Data'  VALUE = L_VALUE   PARENT = R_CELL ) ##NO_TEXT. " Data
7683       R_DATA->SET_ATTRIBUTE_NS( NAME = 'Type'  PREFIX = 'ss'  VALUE = 'String'  ) ##NO_TEXT.                    " Cell format
7684
7685       R_CELL = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Cell'  PARENT = R_ROW ) ##NO_TEXT.
7686       R_CELL->SET_ATTRIBUTE_NS( NAME = 'StyleID'  PREFIX = 'ss'  VALUE = 'Data' ) ##NO_TEXT.
7687       LS_STRING-NO_REC = LS_CONTROL-NO_REC.
7688       L_VALUE = LS_STRING-NO_REC.
7689       R_DATA = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Data'  VALUE = L_VALUE   PARENT = R_CELL ) ##NO_TEXT. " Data
7690       R_DATA->SET_ATTRIBUTE_NS( NAME = 'Type'  PREFIX = 'ss'  VALUE = 'Number'  ) ##NO_TEXT.                    " Cell format
7691
7692
7693       R_CELL = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Cell'  PARENT = R_ROW ) ##NO_TEXT.
7694       R_CELL->SET_ATTRIBUTE_NS( NAME = 'StyleID'  PREFIX = 'ss'  VALUE = 'Data' ) ##NO_TEXT.
7695       LS_STRING-NO_DOC = LS_CONTROL-NO_DOC.
7696       L_VALUE = LS_STRING-NO_DOC.
7697       R_DATA = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Data'  VALUE = L_VALUE   PARENT = R_CELL ) ##NO_TEXT. " Data
7698       R_DATA->SET_ATTRIBUTE_NS( NAME = 'Type'  PREFIX = 'ss'  VALUE = 'Number'  ) ##NO_TEXT.                    " Cell format
7699
7700       R_CELL = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Cell'  PARENT = R_ROW ) ##NO_TEXT.
7701       R_CELL->SET_ATTRIBUTE_NS( NAME = 'StyleID'  PREFIX = 'ss'  VALUE = 'Data' ) ##NO_TEXT.
7702       R_CELL->SET_ATTRIBUTE_NS( NAME = 'NumberFormat'  PREFIX = 'ss'  VALUE = '0.00' ) ##NO_TEXT.
7703       PERFORM CURR_WRITE USING LS_CONTROL-AMOUNT LS_STRING-AMOUNT.
7704   *    ls_string-AMOUNT = ls_control-AMOUNT.
7705       L_VALUE = LS_STRING-AMOUNT.
7706       CONDENSE L_VALUE NO-GAPS.
7707       R_DATA = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Data'  VALUE = L_VALUE   PARENT = R_CELL ) ##NO_TEXT. " Data
7708       R_DATA->SET_ATTRIBUTE_NS( NAME = 'Type'  PREFIX = 'ss'  VALUE = 'Number'  ) ##NO_TEXT.                    " Cell format
7709
7710       R_CELL = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Cell'  PARENT = R_ROW ) ##NO_TEXT.
7711       R_CELL->SET_ATTRIBUTE_NS( NAME = 'StyleID'  PREFIX = 'ss'  VALUE = 'Data' ) ##NO_TEXT.
7712       PERFORM CURR_WRITE USING LS_CONTROL-INV_AMT LS_STRING-INV_AMT.
7713   *     ls_string-inv_amt = ls_control-inv_amt.
7714       L_VALUE = LS_STRING-INV_AMT.
7715       CONDENSE L_VALUE NO-GAPS.
7716       R_DATA = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Data'  VALUE = L_VALUE   PARENT = R_CELL ) ##NO_TEXT. " Data
7717       R_DATA->SET_ATTRIBUTE_NS( NAME = 'Type'  PREFIX = 'ss'  VALUE = 'Number'  ) ##NO_TEXT.                    " Cell format
7718
7719       R_CELL = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Cell'  PARENT = R_ROW ) ##NO_TEXT.
7720       R_CELL->SET_ATTRIBUTE_NS( NAME = 'StyleID'  PREFIX = 'ss'  VALUE = 'Data' ) ##NO_TEXT.
7721       PERFORM CURR_WRITE USING LS_CONTROL-TDS_AMOUNT LS_STRING-TDS_AMOUNT.
7722   *     ls_string-TDS_AMOUNT = ls_control-TDS_AMOUNT.
7723       L_VALUE = LS_STRING-TDS_AMOUNT.
7724       CONDENSE L_VALUE NO-GAPS.
7725       R_DATA = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Data'  VALUE = L_VALUE   PARENT = R_CELL ) ##NO_TEXT. " Data
7726       R_DATA->SET_ATTRIBUTE_NS( NAME = 'Type'  PREFIX = 'ss'  VALUE = 'Number'  ) ##NO_TEXT.                    " Cell format
7727
7728       R_CELL = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Cell'  PARENT = R_ROW ) ##NO_TEXT.
7729       R_CELL->SET_ATTRIBUTE_NS( NAME = 'StyleID'  PREFIX = 'ss'  VALUE = 'Data' ) ##NO_TEXT.
7730       LS_STRING-NO_FBL = LS_CONTROL-NO_FBL.
7731       L_VALUE = LS_STRING-NO_FBL.
7732       R_DATA = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Data'  VALUE = L_VALUE   PARENT = R_CELL ) ##NO_TEXT. " Data
7733       R_DATA->SET_ATTRIBUTE_NS( NAME = 'Type'  PREFIX = 'ss'  VALUE = 'Number'  ) ##NO_TEXT.                    " Cell format
7734
7735       R_CELL = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Cell'  PARENT = R_ROW ) ##NO_TEXT.
7736       R_CELL->SET_ATTRIBUTE_NS( NAME = 'StyleID'  PREFIX = 'ss'  VALUE = 'Data' ) ##NO_TEXT.
7737       PERFORM CURR_WRITE USING LS_CONTROL-FBL1N_AMT LS_STRING-FBL1N_AMT.
7738   *     ls_string-FBL1N_AMT = ls_control-FBL1N_AMT.
7739       L_VALUE = LS_STRING-FBL1N_AMT.
7740       CONDENSE L_VALUE NO-GAPS.
7741       R_DATA = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Data'  VALUE = L_VALUE   PARENT = R_CELL ) ##NO_TEXT. " Data
7742       R_DATA->SET_ATTRIBUTE_NS( NAME = 'Type'  PREFIX = 'ss'  VALUE = 'Number'  ) ##NO_TEXT.                    " Cell format
7743
7744       CLEAR :  LS_STRING .
7745
7746     ENDLOOP.
7747
7748   * Column Headers Row
7749     R_ROW = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Row'  PARENT = R_TABLE ).
7750     R_ROW->SET_ATTRIBUTE_NS( NAME = 'AutoFitHeight'  PREFIX = 'ss'  VALUE = '1' ).
7751
7752     R_CELL = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Cell'  PARENT = R_ROW ) ##NO_TEXT.
7753     R_CELL->SET_ATTRIBUTE_NS( NAME = 'StyleID'  PREFIX = 'ss'  VALUE = 'Header1' ) ##NO_TEXT.
7754     R_DATA = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Data'  VALUE = 'Doument Number'  PARENT = R_CELL ) ##NO_TEXT.
7755     R_DATA->SET_ATTRIBUTE_NS( NAME = 'Type'  PREFIX = 'ss' VALUE = 'String' ) ##NO_TEXT.
7756
7757     R_CELL = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Cell'  PARENT = R_ROW ) ##NO_TEXT.
7758     R_CELL->SET_ATTRIBUTE_NS( NAME = 'StyleID'  PREFIX = 'ss'  VALUE = 'Header1' ) ##NO_TEXT.
7759     R_DATA = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Data'  VALUE = 'Company Code'  PARENT = R_CELL ) ##NO_TEXT.
7760     R_DATA->SET_ATTRIBUTE_NS( NAME = 'Type'  PREFIX = 'ss' VALUE = 'String' ) ##NO_TEXT.
7761
7762     R_CELL = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Cell'  PARENT = R_ROW ) ##NO_TEXT.
7763     R_CELL->SET_ATTRIBUTE_NS( NAME = 'StyleID'  PREFIX = 'ss'  VALUE = 'Header1' ) ##NO_TEXT.
7764     R_DATA = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Data'  VALUE = 'Document Type'  PARENT = R_CELL ) ##NO_TEXT.
7765     R_DATA->SET_ATTRIBUTE_NS( NAME = 'Type'  PREFIX = 'ss' VALUE = 'String' ) ##NO_TEXT.
7766
7767     R_CELL = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Cell'  PARENT = R_ROW ) ##NO_TEXT.
7768     R_CELL->SET_ATTRIBUTE_NS( NAME = 'StyleID'  PREFIX = 'ss'  VALUE = 'Header1' ) ##NO_TEXT.
7769     R_DATA = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Data'  VALUE = 'Amount'  PARENT = R_CELL ) ##NO_TEXT.
7770     R_DATA->SET_ATTRIBUTE_NS( NAME = 'Type'  PREFIX = 'ss' VALUE = 'String' ) ##NO_TEXT.
7771
7772
7773     R_CELL = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Cell'  PARENT = R_ROW ) ##NO_TEXT.
7774     R_CELL->SET_ATTRIBUTE_NS( NAME = 'StyleID'  PREFIX = 'ss'  VALUE = 'Header1' ) ##NO_TEXT.
7775     R_DATA = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Data'  VALUE = 'DR/CR'  PARENT = R_CELL ) ##NO_TEXT.
7776     R_DATA->SET_ATTRIBUTE_NS( NAME = 'Type'  PREFIX = 'ss' VALUE = 'String' ) ##NO_TEXT.
7777
7778     R_CELL = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Cell'  PARENT = R_ROW ) ##NO_TEXT.
7779     R_CELL->SET_ATTRIBUTE_NS( NAME = 'StyleID'  PREFIX = 'ss'  VALUE = 'Header1' ) ##NO_TEXT.
7780     R_DATA = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Data'  VALUE = 'Posting Date'  PARENT = R_CELL ) ##NO_TEXT.
7781     R_DATA->SET_ATTRIBUTE_NS( NAME = 'Type'  PREFIX = 'ss' VALUE = 'String' ) ##NO_TEXT.
7782
7783     R_CELL = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Cell'  PARENT = R_ROW ) ##NO_TEXT.
7784     R_CELL->SET_ATTRIBUTE_NS( NAME = 'StyleID'  PREFIX = 'ss'  VALUE = 'Header1' ) ##NO_TEXT.
7785     R_DATA = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Data'  VALUE = 'Reason'  PARENT = R_CELL ) ##NO_TEXT.
7786     R_DATA->SET_ATTRIBUTE_NS( NAME = 'Type'  PREFIX = 'ss' VALUE = 'String' ) ##NO_TEXT.
7787
7788
7789
7790     LOOP AT LT_EXTRA INTO LS_EXTRA.
7791       R_ROW = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Row'  PARENT = R_TABLE ).
7792
7793       R_CELL = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Cell'  PARENT = R_ROW ) ##NO_TEXT.
7794       R_CELL->SET_ATTRIBUTE_NS( NAME = 'StyleID'  PREFIX = 'ss'  VALUE = 'Data' ) ##NO_TEXT.
7795       LS_STRING1-BELNR = LS_EXTRA-BELNR.
7796       L_VALUE = LS_STRING1-BELNR.
7797       R_DATA = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Data'  VALUE = L_VALUE   PARENT = R_CELL ) ##NO_TEXT. " Data
7798       R_DATA->SET_ATTRIBUTE_NS( NAME = 'Type'  PREFIX = 'ss'  VALUE = 'String'  ) ##NO_TEXT.                    " Cell format
7799
7800       R_CELL = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Cell'  PARENT = R_ROW ) ##NO_TEXT.
7801       R_CELL->SET_ATTRIBUTE_NS( NAME = 'StyleID'  PREFIX = 'ss'  VALUE = 'Data' ) ##NO_TEXT.
7802       LS_STRING1-BUKRS = LS_EXTRA-BUKRS.
7803       L_VALUE = LS_STRING1-BUKRS.
7804       R_DATA = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Data'  VALUE = L_VALUE   PARENT = R_CELL ) ##NO_TEXT. " Data
7805       R_DATA->SET_ATTRIBUTE_NS( NAME = 'Type'  PREFIX = 'ss'  VALUE = 'String'  ) ##NO_TEXT.                    " Cell format
7806
7807       R_CELL = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Cell'  PARENT = R_ROW ) ##NO_TEXT.
7808       R_CELL->SET_ATTRIBUTE_NS( NAME = 'StyleID'  PREFIX = 'ss'  VALUE = 'Data' ) ##NO_TEXT.
7809       LS_STRING1-BLART = LS_EXTRA-BLART.
7810       L_VALUE = LS_STRING1-BLART.
7811       R_DATA = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Data'  VALUE = L_VALUE   PARENT = R_CELL ) ##NO_TEXT. " Data
7812       R_DATA->SET_ATTRIBUTE_NS( NAME = 'Type'  PREFIX = 'ss'  VALUE = 'String'  ) ##NO_TEXT.                    " Cell format
7813
7814       R_CELL = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Cell'  PARENT = R_ROW ) ##NO_TEXT.
7815       R_CELL->SET_ATTRIBUTE_NS( NAME = 'StyleID'  PREFIX = 'ss'  VALUE = 'Data' ) ##NO_TEXT.
7816       PERFORM CURR_WRITE USING LS_EXTRA-DMBTR LS_STRING1-DMBTR.
7817   *    ls_string1-dmbtr = ls_extra-dmbtr.
7818       L_VALUE = LS_STRING1-DMBTR.
7819       CONDENSE L_VALUE NO-GAPS.
7820       R_DATA = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Data'  VALUE = L_VALUE   PARENT = R_CELL ) ##NO_TEXT. " Data
7821       R_DATA->SET_ATTRIBUTE_NS( NAME = 'Type'  PREFIX = 'ss'  VALUE = 'Number'  ) ##NO_TEXT.                    " Cell format
7822
7823       R_CELL = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Cell'  PARENT = R_ROW ) ##NO_TEXT.
7824       R_CELL->SET_ATTRIBUTE_NS( NAME = 'StyleID'  PREFIX = 'ss'  VALUE = 'Data' ) ##NO_TEXT.
7825       LS_STRING1-SHKZG = LS_EXTRA-SHKZG.
7826       L_VALUE = LS_STRING1-SHKZG.
7827       R_DATA = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Data'  VALUE = L_VALUE   PARENT = R_CELL ) ##NO_TEXT. " Data
7828       R_DATA->SET_ATTRIBUTE_NS( NAME = 'Type'  PREFIX = 'ss'  VALUE = 'String'  ) ##NO_TEXT.                    " Cell format
7829
7830       R_CELL = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Cell'  PARENT = R_ROW ) ##NO_TEXT.
7831       R_CELL->SET_ATTRIBUTE_NS( NAME = 'StyleID'  PREFIX = 'ss'  VALUE = 'Data' ) ##NO_TEXT.
7832       LS_STRING1-BUDAT = LS_EXTRA-BUDAT.
7833       L_VALUE = LS_STRING1-BUDAT.
7834       R_DATA = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Data'  VALUE = L_VALUE   PARENT = R_CELL ) ##NO_TEXT. " Data
7835       R_DATA->SET_ATTRIBUTE_NS( NAME = 'Type'  PREFIX = 'ss'  VALUE = 'String'  ) ##NO_TEXT.                    " Cell format
7836
7837
7838       R_CELL = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Cell'  PARENT = R_ROW ) ##NO_TEXT.
7839       R_CELL->SET_ATTRIBUTE_NS( NAME = 'StyleID'  PREFIX = 'ss'  VALUE = 'Data' ) ##NO_TEXT.
7840       LS_STRING1-TEXT = LS_EXTRA-TEXT.
7841       L_VALUE = LS_STRING1-TEXT.
7842       R_DATA = L_DOCUMENT->CREATE_SIMPLE_ELEMENT( NAME = 'Data'  VALUE = L_VALUE   PARENT = R_CELL ) ##NO_TEXT. " Data
7843       R_DATA->SET_ATTRIBUTE_NS( NAME = 'Type'  PREFIX = 'ss'  VALUE = 'String'  ) ##NO_TEXT.                    " Cell format
7844
7845       CLEAR :  LS_STRING1 .
7846     ENDLOOP.
7847
7848   * Creating a stream factory
7849     L_STREAMFACTORY = L_IXML->CREATE_STREAM_FACTORY( ).
7850
7851   * Connect Internal XML Table to Stream Factory
7852     L_OSTREAM = L_STREAMFACTORY->CREATE_OSTREAM_ITABLE( TABLE = L_XML_TABLE ).
7853
7854   * Rendering the Document
7855     L_RENDERER = L_IXML->CREATE_RENDERER( OSTREAM  = L_OSTREAM  DOCUMENT = L_DOCUMENT ).
7856
7857     L_RC = L_RENDERER->RENDER( ).
7858
7859   * Saving the XML Document
7860     L_XML_SIZE = L_OSTREAM->GET_NUM_WRITTEN_RAW( ).
7861
7862
7863     CLEAR:LT_FINAL_HEX[].
7864     LOOP AT L_XML_TABLE ASSIGNING <WA_XML>.
7865       LS_FINAL_HEX-LINE = <WA_XML>-DATA.
7866       APPEND LS_FINAL_HEX TO LT_FINAL_HEX.
7867       CLEAR LS_FINAL_HEX.
7868     ENDLOOP.
7869     DATA: LV_TEMP_FILEPATH TYPE STRING,
7870           LV_FILEPATH      TYPE STRING.
7871
7872
7873     LV_FILECOUNT = GV_FILECOUNT.
7874     IF P_LCFILE IS NOT INITIAL.
7875       CONCATENATE P_LCFILE  GV_FILE INTO LV_FILEPATH SEPARATED BY GC_FILE_SEPARATOR.
7876     ELSE.
7877       CONCATENATE GC_DRIVE_ROOT GC_FOLDER_ROOT GV_FILE INTO LV_FILEPATH SEPARATED BY GC_FILE_SEPARATOR.
7878     ENDIF.
7879
7880     CONCATENATE LV_FILEPATH '_' SY-DATUM '_' SY-UZEIT '_' LV_FILECOUNT  INTO LV_TEMP_FILEPATH.
7881
7882     DATA : PS_FILE TYPE STRING.
7883     PS_FILE = LV_TEMP_FILEPATH.
7884
7885     IF P_LC_CSV = 'X' AND P_LC_XLS = 'X'.
7886       MESSAGE 'Kindly select only one format to download file in local system' TYPE 'W'.
7887     ELSEIF P_LC_XLS = 'X'.
7888
7889       CONCATENATE PS_FILE '.xls' INTO PS_FILE.
7890       CALL METHOD CL_GUI_FRONTEND_SERVICES=>GUI_DOWNLOAD
7891         EXPORTING
7892           FILENAME = PS_FILE
7893           FILETYPE = 'BIN'
7894         CHANGING
7895           DATA_TAB = LT_FINAL_HEX
7896         EXCEPTIONS
7897           OTHERS   = 1.
7898
7899       IF SY-SUBRC = 0.
7900         MESSAGE TEXT-502 TYPE 'S' ."Successfully Downloaded' TYPE 'S'.
7901       ELSE.
7902         MESSAGE TEXT-503 TYPE 'S'."'Downloading Failed' TYPE 'S'.
7903       ENDIF.
7904
7905     ELSEIF P_LC_CSV = 'X'.
7906       CONCATENATE PS_FILE '.csv' INTO PS_FILE.
7907
7908       CONCATENATE 'Source file name' ',' 'Company code' ',' 'TAN' ',' 'Deductee Status' ',' 'DR/CR' ',' 'Posting Period Start date' ','
7909                   'Posting Period End date' ',' 'Creation Period Start date' ',' 'Creation Period End date' ',' 'Date of extraction' ','
7910                   'No of lines items' ',' 'No. of Documents' ',' 'Taxable Amount in Local Currency' ',' 'Invoice Amount in Local Currency' ','
7911                   'TDS Amount in Local Currency' ',' 'No. of FBL1N Documents' ',' 'FBL1N Amount in Local Currency' INTO LS_HEADER1.
7912       APPEND LS_HEADER1 TO LT_HEADER1.
7913
7914
7915       CLEAR:LS_CONTROL,LS_TAB_DATA,LV_AMOUNT,LV_AMOUNT2,LV_AMOUNT3,LV_AMOUNT4.
7916       LOOP AT LT_CONTROL INTO LS_CONTROL.
7917
7918         LV_AMOUNT = LS_CONTROL-AMOUNT.
7919         CONDENSE LV_AMOUNT.
7920         LV_AMOUNT2 = LS_CONTROL-TDS_AMOUNT.
7921         CONDENSE LV_AMOUNT2.
7922         LV_AMOUNT3 = LS_CONTROL-INV_AMT.
7923         CONDENSE LV_AMOUNT3.
7924         LV_AMOUNT4 = LS_CONTROL-FBL1N_AMT.
7925         CONDENSE LV_AMOUNT4.
7926
7927         CONCATENATE LS_CONTROL-TEXT ','
7928          LS_CONTROL-TEXT1   ','
7929          LS_CONTROL-TAN     ','
7930          LS_CONTROL-STATUS  ','
7931          LS_CONTROL-DR_CR   ','
7932          LS_CONTROL-BUDAT_S ','
7933          LS_CONTROL-BUDAT_E ','
7934          LS_CONTROL-CPUDT_S ','
7935          LS_CONTROL-CPUDT_E ','
7936          LS_CONTROL-EXTRAT_D  ','
7937          LS_CONTROL-NO_REC   ','
7938          LS_CONTROL-NO_DOC   ','
7939          LV_AMOUNT           ','
7940          LV_AMOUNT2           ','
7941          LV_AMOUNT3           ','
7942          LS_CONTROL-NO_FBL     ','
7943          LV_AMOUNT4   INTO LS_TAB_DATA.
7944
7945         APPEND LS_TAB_DATA TO LT_TAB_DATA.
7946         CLEAR:LS_CONTROL,LS_TAB_DATA,LV_AMOUNT,LV_AMOUNT2,LV_AMOUNT3,LV_AMOUNT4.
7947       ENDLOOP.
7948
7949       ITAB_FINAL = LT_HEADER1.
7950       APPEND LINES OF LT_TAB_DATA TO ITAB_FINAL.
7951       APPEND INITIAL LINE TO ITAB_FINAL.
7952
7953
7954       CLEAR:LS_HEADER1,LT_HEADER1.
7955       CONCATENATE 'Doument Number' ',' 'Company code' ',' 'Document Type' ',' 'Amount' ',' 'DR/CR' ',' 'Posting date' ','
7956                   'Reason' INTO LS_HEADER1.
7957       APPEND LS_HEADER1 TO LT_HEADER1.
7958       APPEND LINES OF LT_HEADER1 TO ITAB_FINAL.
7959
7960       CLEAR:LS_EXTRA,LS_TAB_DATA,LT_TAB_DATA,LV_AMOUNT.
7961       LOOP AT LT_EXTRA INTO LS_EXTRA.
7962
7963         LV_AMOUNT = LS_EXTRA-DMBTR.
7964         CONDENSE LV_AMOUNT.
7965
7966         CONCATENATE LS_EXTRA-BELNR  ','
7967            LS_EXTRA-BUKRS  ','
7968            LS_EXTRA-BLART  ','
7969            LV_AMOUNT       ','
7970            LS_EXTRA-SHKZG  ','
7971            LS_EXTRA-BUDAT  ','
7972            LS_EXTRA-TEXT  INTO LS_TAB_DATA.
7973
7974         APPEND LS_TAB_DATA TO LT_TAB_DATA.
7975
7976         CLEAR:LS_EXTRA,LS_TAB_DATA,LV_AMOUNT.
7977       ENDLOOP.
7978
7979       APPEND LINES OF LT_TAB_DATA TO ITAB_FINAL.
7980
7981
7982       CALL FUNCTION 'GUI_DOWNLOAD'
7983         EXPORTING
7984           FILENAME                = PS_FILE
7985           FILETYPE                = 'DAT'
7986   *       write_field_separator   = ','
7987   *       show_transfer_status    = 'X'
7988         TABLES
7989           DATA_TAB                = ITAB_FINAL[]
7990         EXCEPTIONS
7991           FILE_WRITE_ERROR        = 1
7992           NO_BATCH                = 2
7993           GUI_REFUSE_FILETRANSFER = 3
7994           INVALID_TYPE            = 4
7995           NO_AUTHORITY            = 5
7996           UNKNOWN_ERROR           = 6
7997           HEADER_NOT_ALLOWED      = 7
7998           SEPARATOR_NOT_ALLOWED   = 8
7999           FILESIZE_NOT_ALLOWED    = 9
8000           HEADER_TOO_LONG         = 10
8001           DP_ERROR_CREATE         = 11
8002           DP_ERROR_SEND           = 12
8003           DP_ERROR_WRITE          = 13
8004           UNKNOWN_DP_ERROR        = 14
8005           ACCESS_DENIED           = 15
8006           DP_OUT_OF_MEMORY        = 16
8007           DISK_FULL               = 17
8008           DP_TIMEOUT              = 18
8009           FILE_NOT_FOUND          = 19
8010           DATAPROVIDER_EXCEPTION  = 20
8011           CONTROL_FLUSH_ERROR     = 21
8012           OTHERS                  = 22.
8013       IF SY-SUBRC = 0.
8014         MESSAGE TEXT-502 TYPE 'S'.
8015       ELSEIF SY-SUBRC = '5'.
8016         MESSAGE TEXT-503 TYPE 'S'.
8017       ENDIF.
8018
8019     ENDIF.
8020
8021   ENDFORM.                    " CNTR_EXCEL_DOWNLOAD
8022
8023   *&---------------------------------------------------------------------*
8024   *&      Form  curr_write
8025   *&---------------------------------------------------------------------*
8026   *       text
8027   *----------------------------------------------------------------------*
8028   *      -->P_AMOUNT         text
8029   *      -->##PERF_NO_TYPE   text
8030   *      -->P_STRING_AMOUNT  text
8031   *----------------------------------------------------------------------*
8032   FORM CURR_WRITE  USING    P_AMOUNT     ##PERF_NO_TYPE
8033                           P_STRING_AMOUNT.
8034
8035     DATA lv_amt TYPE p DECIMALS 2.
8036     IF P_AMOUNT < 0.
8037   "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP on 13/06/2026
8038   *    P_AMOUNT = P_AMOUNT * -1.
8039   *    WRITE : P_AMOUNT TO P_STRING_AMOUNT DECIMALS 2.
8040       lv_amt = p_amount.
8041       lv_amt = lv_amt * -1.
8042       WRITE : lv_amt TO P_STRING_AMOUNT DECIMALS 2.
8043   "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP on 13/06/2026
8044       CONCATENATE '-' P_STRING_AMOUNT INTO P_STRING_AMOUNT.
8045       CONDENSE P_STRING_AMOUNT NO-GAPS.
8046   "Code Remediation changes S4 2025 Conversion Begin of change SAP_ABAP on 13/06/2026
8047   *    P_AMOUNT = P_AMOUNT * -1.
8048       P_AMOUNT  = lv_amt * -1.
8049   "Code Remediation changes S4 2025 Conversion End of change SAP_ABAP on 13/06/2026
8050     ELSEIF P_AMOUNT = 0.
8051       CLEAR : P_STRING_AMOUNT.
8052     ELSE.
8053       WRITE : P_AMOUNT TO P_STRING_AMOUNT DECIMALS 2.
8054     ENDIF.
8055   ENDFORM.                    "curr_write
8056   *&---------------------------------------------------------------------*
8057   *&      Form  DOWNLOAD_FILE_AL11_C
8058   *&---------------------------------------------------------------------*
8059   *       text
8060   *----------------------------------------------------------------------*
8061   *      -->P_LT_HEAD  text
8062   *----------------------------------------------------------------------*
8063   FORM DOWNLOAD_FILE_AL11_C   TABLES LT_HEAD TYPE TTY_HEAD.
8064
8065   *    *    *    ------------------------give permisiion to OS level using below script---------------------------
8066     DATA: EXEC              TYPE TABLE OF BTCXPM,
8067           LT_FBL1N_DEL_TEMP TYPE TABLE OF RFPOSXEXT,
8068           LS_FBL1N_DEL_TEMP LIKE LINE OF LT_FBL1N_DEL_TEMP,
8069           LV_FILE           TYPE PATH-PATHEXTERN,
8070           LV_FILECOUNT(3)   TYPE N,
8071           LS_HEAD           TYPE TY_HEAD,
8072           LS_MAIN_HEAD      TYPE TY_HEAD,
8073           LS_MAIN_HEAD1     TYPE TY_HEAD,
8074           LT_TEMP_HEAD      TYPE TTY_HEAD,
8075           LV_FLAG           TYPE C,
8076           LV_CHAR(255).
8077
8078     FIELD-SYMBOLS: <FS_COMP1>     TYPE ANY,
8079                    <FS_WORKAREA1> TYPE ANY.
8080
8081     CALL FUNCTION 'SXPG_CALL_SYSTEM'
8082       EXPORTING
8083         COMMANDNAME                = 'Z_XI_NFS_FP'
8084   *     ADDITIONAL_PARAMETERS      = ' '
8085   *     TRACE                      =
8086   *     IMPORTING
8087   *     STATUS                     =
8088   *     EXITCODE                   =
8089       TABLES
8090         EXEC_PROTOCOL              = EXEC
8091       EXCEPTIONS
8092         NO_PERMISSION              = 1
8093         COMMAND_NOT_FOUND          = 2
8094         PARAMETERS_TOO_LONG        = 3
8095         SECURITY_RISK              = 4
8096         WRONG_CHECK_CALL_INTERFACE = 5
8097         PROGRAM_START_ERROR        = 6
8098         PROGRAM_TERMINATION_ERROR  = 7
8099         X_ERROR                    = 8
8100         PARAMETER_EXPECTED         = 9
8101         TOO_MANY_PARAMETERS        = 10
8102         ILLEGAL_COMMAND            = 11
8103         OTHERS                     = 12.
8104     IF SY-SUBRC <> 0.
8105   * Implement suitable error handling here
8106     ENDIF.
8107
8108     IF LT_FBL1N_DEL[] IS NOT INITIAL.
8109       CLEAR LT_UPD.
8110       SELECT *
8111         FROM ZEYTDS_RESON_STR
8112         INTO TABLE LT_UPD
8113         FOR ALL ENTRIES IN LT_FBL1N_DEL
8114         WHERE BUKRS = LT_FBL1N_DEL-BUKRS
8115         AND BELNR = LT_FBL1N_DEL-BELNR
8116         AND GJAHR = LT_FBL1N_DEL-GJAHR
8117         AND FLAG = 'I'.
8118       IF SY-SUBRC = 0.
8119         SORT LT_UPD BY BUKRS BELNR GJAHR.
8120       ENDIF.
8121
8122       CLEAR LT_LFA1.
8123       SELECT LIFNR NAME1 NAME2 STRAS LAND1 PSTLZ ORT01 REGIO
8124         MCOD3 ADRNR  STCD1  STCD3 KTOKK
8125         FROM LFA1
8126         INTO TABLE LT_LFA1
8127         FOR ALL ENTRIES IN LT_FBL1N_DEL
8128         WHERE LIFNR = LT_FBL1N_DEL-KONTO.
8129
8130       IF LT_LFA1[] IS NOT INITIAL.
8131         SORT LT_LFA1 BY  LIFNR.
8132         SELECT *
8133           FROM ZEYTDS_ACCT_GRP
8134           INTO TABLE LT_ACCT_GROUP
8135         FOR ALL ENTRIES IN LT_LFA1 WHERE  KTOKK =  LT_LFA1-KTOKK.
8136         IF SY-SUBRC = 0.
8137           SORT LT_ACCT_GROUP BY KTOKK.
8138         ENDIF.
8139       ENDIF.
8140     ENDIF.
8141
8142     SORT LT_FBL1N_DEL BY BUKRS.
8143
8144     LT_FBL1N_DEL_TEMP[] = LT_FBL1N_DEL.
8145     CLEAR:LT_EXTRA[].
8146
8147     DELETE ADJACENT DUPLICATES FROM LT_FBL1N_DEL_TEMP COMPARING BUKRS.
8148
8149     LOOP AT LT_FBL1N_DEL_TEMP INTO LS_FBL1N_DEL_TEMP.
8150
8151       LOOP AT LT_FBL1N_DEL INTO LS_FBL1N_DEL WHERE BUKRS = LS_FBL1N_DEL_TEMP-BUKRS.
8152         LS_EXTRA-BELNR = LS_FBL1N_DEL-BELNR.
8153         LS_EXTRA-BUKRS = LS_FBL1N_DEL-BUKRS.
8154         LS_EXTRA-BLART = LS_FBL1N_DEL-BLART.
8155
8156         CONCATENATE LS_FBL1N_DEL-BUDAT+0(4) '-' LS_FBL1N_DEL-BUDAT+4(2) '-'
8157                     LS_FBL1N_DEL-BUDAT+6(2) INTO  LS_EXTRA-BUDAT.
8158
8159         IF LS_FBL1N_DEL-DMSHB < 0.
8160           LS_FBL1N_DEL-DMSHB = LS_FBL1N_DEL-DMSHB * - 1.
8161         ENDIF.
8162
8163         LS_EXTRA-DMBTR = LS_FBL1N_DEL-DMSHB.
8164         LS_EXTRA-SHKZG = LS_FBL1N_DEL-SHKZG.
8165
8166         READ TABLE LT_LFA1 INTO LS_LFA1 WITH  KEY LIFNR = LS_FBL1N_DEL-KONTO BINARY SEARCH.
8167         IF SY-SUBRC = 0.
8168           READ TABLE LT_ACCT_GROUP TRANSPORTING NO FIELDS WITH  KEY KTOKK = LS_LFA1-KTOKK BINARY SEARCH.
8169           IF SY-SUBRC = 0.
8170             LS_EXTRA-TEXT = 'Employee Vendor'.
8171           ENDIF.
8172           "SOC Added by Anil Maurya on 11.01.2024
8173         ELSEIF SY-SUBRC <> 0.
8174           READ TABLE LT_DEL_BEL_K INTO DATA(LS_DEL_BEL_K) WITH KEY BUKRS = LS_FBL1N_DEL-BUKRS
8175                                                                    BELNR = LS_FBL1N_DEL-BELNR
8176                                                                    GJAHR = LS_FBL1N_DEL-GJAHR BINARY SEARCH.
8177           IF SY-SUBRC = 0.
8178             LS_EXTRA-TEXT = 'Vendor Clearing'.
8179           ENDIF.
8180           "EOC Added by Anil Maurya on 11.01.2024
8181         ENDIF.
8182         IF LS_EXTRA-TEXT IS INITIAL.
8183           READ TABLE LT_UPD INTO LS_UPD WITH  KEY BUKRS = LS_FBL1N_DEL-BUKRS
8184                                                   BELNR = LS_FBL1N_DEL-BELNR
8185                                                   GJAHR = LS_FBL1N_DEL-GJAHR.
8186           IF SY-SUBRC = 0.
8187             LS_EXTRA-TEXT = LS_UPD-TEXT.
8188           ENDIF.
8189         ENDIF.
8190         SHIFT LS_EXTRA-BELNR LEFT DELETING LEADING '0'.
8191         APPEND LS_EXTRA TO LT_EXTRA.
8192         CLEAR : LS_EXTRA.
8193       ENDLOOP.
8194       APPEND LS_EXTRA TO LT_EXTRA.
8195     ENDLOOP.
8196
8197
8198
8199
8200     READ TABLE LT_HEAD INTO LS_MAIN_HEAD1 INDEX 1.
8201
8202     LOOP AT LT_HEAD  TRANSPORTING NO FIELDS WHERE  HEAD IS NOT INITIAL.
8203       CLEAR : LT_TEMP_HEAD.
8204       IF P_LINES IS NOT INITIAL.
8205         APPEND LINES OF LT_HEAD FROM 1 TO P_LINES TO LT_TEMP_HEAD.
8206         DELETE LT_HEAD FROM 1 TO P_LINES.
8207       ELSE.
8208         APPEND LINES OF LT_HEAD TO LT_TEMP_HEAD.
8209         CLEAR LT_HEAD.
8210       ENDIF.
8211
8212       LS_HEAD-HEAD = 'Doument Number'.
8213       CONCATENATE LS_HEAD-HEAD ','   'Company Code' INTO LS_HEAD-HEAD.
8214       CONCATENATE LS_HEAD-HEAD ',' 'Document Type' INTO LS_HEAD-HEAD.
8215       CONCATENATE LS_HEAD-HEAD ',' 'Amount' INTO LS_HEAD-HEAD.
8216       CONCATENATE LS_HEAD-HEAD ',' 'DR/CR' INTO LS_HEAD-HEAD.
8217       CONCATENATE LS_HEAD-HEAD ',' 'Posting Date' INTO LS_HEAD-HEAD.
8218       CONCATENATE LS_HEAD-HEAD ',' 'Reason' INTO LS_HEAD-HEAD.
8219       APPEND LS_HEAD TO LT_HEAD.
8220       CLEAR LS_HEAD.
8221
8222       LOOP AT LT_EXTRA ASSIGNING <FS_WORKAREA1>.
8223         ASSIGN COMPONENT 'BELNR' OF STRUCTURE <FS_WORKAREA1> TO <FS_COMP1>.
8224         LV_CHAR = <FS_COMP1>.
8225         REPLACE ALL OCCURRENCES OF ',' IN LV_CHAR WITH ' '.
8226         CONDENSE LV_CHAR.
8227         CONCATENATE LS_HEAD-HEAD LV_CHAR ',' INTO LS_HEAD-HEAD.
8228
8229         ASSIGN COMPONENT 'BUKRS' OF STRUCTURE <FS_WORKAREA1> TO <FS_COMP1>.
8230         LV_CHAR = <FS_COMP1>.
8231         REPLACE ALL OCCURRENCES OF ',' IN LV_CHAR WITH ' '.
8232         CONDENSE LV_CHAR.
8233         CONCATENATE LS_HEAD-HEAD LV_CHAR ',' INTO LS_HEAD-HEAD.
8234
8235         ASSIGN COMPONENT 'BLART' OF STRUCTURE <FS_WORKAREA1> TO <FS_COMP1>.
8236         LV_CHAR = <FS_COMP1>.
8237         REPLACE ALL OCCURRENCES OF ',' IN LV_CHAR WITH ' '.
8238         CONDENSE LV_CHAR.
8239         CONCATENATE LS_HEAD-HEAD LV_CHAR ',' INTO LS_HEAD-HEAD.
8240
8241         ASSIGN COMPONENT 'DMBTR' OF STRUCTURE <FS_WORKAREA1> TO <FS_COMP1>.
8242         LV_CHAR = <FS_COMP1>.
8243         REPLACE ALL OCCURRENCES OF ',' IN LV_CHAR WITH ' '.
8244         CONDENSE LV_CHAR.
8245         CONCATENATE LS_HEAD-HEAD LV_CHAR ',' INTO LS_HEAD-HEAD.
8246
8247         ASSIGN COMPONENT 'SHKZG' OF STRUCTURE <FS_WORKAREA1> TO <FS_COMP1>.
8248         LV_CHAR = <FS_COMP1>.
8249         REPLACE ALL OCCURRENCES OF ',' IN LV_CHAR WITH ' '.
8250         CONDENSE LV_CHAR.
8251         CONCATENATE LS_HEAD-HEAD LV_CHAR ',' INTO LS_HEAD-HEAD.
8252
8253         ASSIGN COMPONENT 'BUDAT' OF STRUCTURE <FS_WORKAREA1> TO <FS_COMP1>.
8254         LV_CHAR = <FS_COMP1>.
8255         REPLACE ALL OCCURRENCES OF ',' IN LV_CHAR WITH ' '.
8256         CONDENSE LV_CHAR.
8257         CONCATENATE LS_HEAD-HEAD LV_CHAR ',' INTO LS_HEAD-HEAD.
8258
8259         ASSIGN COMPONENT 'TEXT' OF STRUCTURE <FS_WORKAREA1> TO <FS_COMP1>.
8260         LV_CHAR = <FS_COMP1>.
8261         REPLACE ALL OCCURRENCES OF ',' IN LV_CHAR WITH ' '.
8262         CONDENSE LV_CHAR.
8263         CONCATENATE LS_HEAD-HEAD LV_CHAR ',' INTO LS_HEAD-HEAD.
8264
8265         APPEND LS_HEAD TO LT_HEAD.
8266         CLEAR: LS_HEAD.
8267       ENDLOOP.
8268
8269       IF  LT_HEAD[] IS NOT INITIAL.
8270         APPEND LINES OF LT_HEAD TO LT_TEMP_HEAD.
8271         CLEAR:LT_HEAD.
8272       ENDIF.
8273
8274       DELETE LT_TEMP_HEAD WHERE HEAD IS INITIAL.
8275
8276       IF P_ALFILE IS NOT INITIAL.
8277   ** FILE TO BE CREATED IN APPLICATION SERVER
8278         LV_FILECOUNT = GV_FILECOUNT.
8279
8280         IF P_AL_CSV  = 'X' AND P_AL_XLS = 'X'.
8281           MESSAGE 'Kindly select only one format to push file on AL11' TYPE 'W'.
8282         ELSEIF P_AL_CSV  = 'X'.
8283           CONCATENATE P_ALFILE  GV_FILE '_' SY-DATUM '_' SY-UZEIT '_' LV_FILECOUNT '.csv' INTO LV_FILE.
8284         ELSEIF P_AL_XLS = 'X'.
8285           CONCATENATE P_ALFILE  GV_FILE '_' SY-DATUM '_' SY-UZEIT '_' LV_FILECOUNT '.xls' INTO LV_FILE.
8286         ENDIF.
8287
8288
8289         OPEN DATASET LV_FILE FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
8290         IF SY-SUBRC = 0.
8291           IF  LV_FLAG = 'X'.
8292             TRANSFER LS_MAIN_HEAD1 TO LV_FILE.
8293           ENDIF.
8294           LOOP AT LT_TEMP_HEAD INTO LS_MAIN_HEAD.
8295             TRANSFER LS_MAIN_HEAD-HEAD TO LV_FILE.
8296             CLEAR LS_MAIN_HEAD.
8297             LV_FLAG = 'X'.
8298           ENDLOOP.
8299           CLOSE DATASET LV_FILE.
8300           IF SY-SUBRC = 0 AND LV_FLAG = 'X'.
8301             MESSAGE 'File created successfully in AL11' TYPE 'S'.    "zubair-01.03.2024
8302           ELSE.
8303             MESSAGE 'No Authorization to create file in AL11' TYPE 'S'.
8304           ENDIF.
8305         ELSE.
8306           MESSAGE 'File Could not be downlaoded' TYPE 'S' DISPLAY LIKE 'E'.
8307         ENDIF.
8308       ENDIF.
8309     ENDLOOP.
8310   ENDFORM.                    " DOWNLOAD_FILE_AL11_C
8311   *&---------------------------------------------------------------------*
8312   *&      Form  DYNAMIC_FISCAL_YEAR
8313   *&---------------------------------------------------------------------*
8314   *       text
8315   *----------------------------------------------------------------------*
8316   *  -->  p1        text
8317   *  <--  p2        text
8318   *----------------------------------------------------------------------*
8319   FORM DYNAMIC_FISCAL_YEAR .
8320
8321     DATA : E_FY TYPE CHAR4.
8322     IF  P_GJAHR IS INITIAL.
8323       CALL FUNCTION 'GM_GET_FISCAL_YEAR'
8324         EXPORTING
8325           I_DATE                     = SY-DATUM
8326           I_FYV                      = 'V3'
8327         IMPORTING
8328           E_FY                       = E_FY
8329         EXCEPTIONS
8330           FISCAL_YEAR_DOES_NOT_EXIST = 1
8331           NOT_DEFINED_FOR_DATE       = 2
8332           OTHERS                     = 3.
8333       IF SY-SUBRC EQ 0.
8334         IF P_GJAHR2 = 'X'.
8335           P_GJAHR  = E_FY - 1.
8336         ELSE.
8337           P_GJAHR  = E_FY.
8338         ENDIF.
8339       ENDIF.
8340
8341     ELSE.
8342       IF P_GJAHR2 = 'X'.
8343         P_GJAHR  = P_GJAHR - 1.
8344       ENDIF.
8345     ENDIF.
8346
8347   ENDFORM.
*--- End of ZEYTDS_INV_EXTRACT_F01 - 8347 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CABAP                                   Level 1    Page 5
Object           ZEYTDS_INV_EXTRACT                        Lines 360
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:37
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
Generated incl.  %_CCNDD                                   Level 1    Page 6
Object           ZEYTDS_INV_EXTRACT                        Lines 31
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:37
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
Object           ZEYTDS_INV_EXTRACT                        Lines 138
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:37
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
Generated incl.  %_CKKBLO                                  Level 1    Page 8
Object           ZEYTDS_INV_EXTRACT                        Lines 492
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:37
----------------------------------------------------------------------------------------------------
1      *----------------------------------------------------------------------*
2      * KORREKTUREN
3      *----------------------------------------------------------------------*
4      * Korrigiert zu Release:   Korrekturkürzel:   Korrekturnummer:   excl:
5      *      Beschreibung:
6      *----------------------------------------------------------------------*
7      * ____                     __________           __________          (_)
8      *----------------------------------------------------------------------*
9      TYPE-POOL KKBLO .
10     TYPE-POOLS: SLIS.
11
12     *--- strings
13     TYPES: KKBLO_TABNAME   TYPE SLIS_TABNAME,
14            KKBLO_FIELDNAME TYPE SLIS_FIELDNAME,
15            KKBLO_FORMNAME  TYPE SLIS_FORMNAME,
16            KKBLO_ENTRY     TYPE SLIS_ENTRY,
17            KKBLO_COLDESC   TYPE SLIS_COLDESC.
18
19     *--- Structure for exception quickinfo
20     TYPES: KKBLO_QINFO TYPE ALV_S_QINF.
21
22     *--- Structure for exception quickinfo table
23     TYPES: KKBLO_T_QINFO TYPE KKBLO_QINFO OCCURS 0.
24
25     *--- Structure for the excluding table (function codes)
26     TYPES: KKBLO_EXTAB TYPE SLIS_EXTAB.
27
28     *--- excluding table
29     TYPES: KKBLO_T_EXTAB TYPE KKBLO_EXTAB OCCURS 1.
30
31     *--- Structure for reprep-initialization
32     TYPES: KKBLO_REPREP_ID TYPE SLIS_REPREP_ID.
33
34     *--- Structure for reprep-parameters
35     TYPES: BEGIN OF KKBLO_REPREP,
36              CALLBACK_PROGRAM LIKE SY-REPID,
37              CALLBACK_REPREP_SEL_MODIFY TYPE KKBLO_FORMNAME,
38              REPREP_ID TYPE KKBLO_REPREP_ID,
39            END OF KKBLO_REPREP.
40
41     *--- Structure for callback_reprep_sel_modify
42     TYPES: KKBLO_REPREP_COMMUNICATION TYPE SLIS_REPREP_COMMUNICATION.
43
44     *--- Structure for colors
45     TYPES: KKBLO_COLOR TYPE SLIS_COLOR.
46     TYPES: BEGIN OF KKBLO_COLTYPES.
47     INCLUDE TYPE SLIS_COLTYPES.
48     TYPES:  END OF KKBLO_COLTYPES.
49
50     *--- Structure for specific color settings
51     TYPES: BEGIN OF KKBLO_SPECIALCOL.
52     INCLUDE TYPE SLIS_SPECIALCOL_ALV.
53     TYPES:  END OF KKBLO_SPECIALCOL.
54     TYPES: KKBLO_T_SPECIALCOL TYPE KKBLO_SPECIALCOL OCCURS 1.
55
56     *--- Structure for scrolling in list
57     TYPES: BEGIN OF KKBLO_LIST_SCROLL,
58              LSIND LIKE SY-LSIND,
59              CPAGE LIKE SY-CPAGE,
60              STARO LIKE SY-STARO,
61              STACO LIKE SY-STACO,
62              CUROW LIKE SY-CUROW,
63              CUCOL LIKE SY-CUCOL,
64              CURSOR_LINE LIKE SY-CUROW,
65              CURSOR_OFFSET LIKE SY-CUCOL,
66            END OF KKBLO_LIST_SCROLL.
67
68     *--- Lineinfo before output
69     TYPES: KKBLO_LINEINFO TYPE SLIS_LINEINFO.
70
71     *--- Marks in list
72     TYPES: BEGIN OF KKBLO_COLMARK,
73              TABNAME TYPE KKBLO_TABNAME,
74              FIELDNAME TYPE KKBLO_FIELDNAME,
75              COLNO TYPE I,
76            END OF KKBLO_COLMARK.
77     TYPES: KKBLO_T_COLMARK TYPE KKBLO_COLMARK OCCURS 1.
78
79     TYPES: BEGIN OF KKBLO_ROWMARK,
80              TABNAME TYPE KKBLO_TABNAME,
81              TABINDEX LIKE SY-TABIX,
82            END OF KKBLO_ROWMARK.
83     TYPES: KKBLO_T_ROWMARK TYPE KKBLO_ROWMARK OCCURS 1.
84
85     types: begin of kkblo_incl_layout1,
86              NO_SELINFOS(1) TYPE C,
87              ROWNO_CHANGE(1) TYPE C,       " number of rows changeable
88              NO_NUMC_SUM(1)  TYPE C,
89              ZEBRA_MULTI(1)  TYPE C,
90              NO_STATIC_SUBTOT,
91              COLORS TYPE KKBLO_COLTYPES,   " description of colors
92              SUPPRESS_DYNPRO(1) TYPE C,    " no call screen
93              INTERNET_PREPARE(1) TYPE C,   " for processing via internet
94              INTERFACE_COMPLETE(1) TYPE C, " just display.
95              NO_FILTER_CONFIRM(1) TYPE C,  " filter on cell without confirm.
96              DETAIL_ONLY(1) TYPE C,        " show only detail
97              DETAIL_EXIT(1) TYPE C,        " ucomm-exit for function 'DETA'
98              S_VARIANT LIKE DISVARIANT,    " display variant
99              WEBLOOK type LVC_LOOK,
100             WEBSTYLE type LVC_STYLE,
101             WEBROWS type LVC_WEBROW,
102             WEBXWIDTH type INT4,
103             WEBXHEIGHT type INT4,
104           end   of kkblo_incl_layout1,
105
106           begin of kkblo_incl_layout0,
107             ROWS_MAX TYPE I,
108             NO_ZEBRA(1)     TYPE C,
109             I_AM_POPUP(1) TYPE C,
110             NEW_FCODES(1) TYPE C,
111             OLD_COLSEL(1) TYPE C,         " 'old' popup for column select.
112             MEMORY(1) TYPE C,             " write layout in memory
113             COL_OFFSET LIKE SY-CUCOL,     " add col_offset to first column
114             ROW_OFFSET LIKE SY-CUROW,     " add row_offset to first row
115             KEYCOLS(1) TYPE N,            " number of keycolumns
116             BLOCK_MODE(1) TYPE C,         " ALV Block mode
117             DEFAULT(1)    TYPE C,
118             SAVE(1) TYPE C,
119             frontend type lvc_front,
120             object_key type bds_typeid,
121             doc_id type bds_docid,
122             template type bds_filena,
123             language type lang,
124           end   of kkblo_incl_layout0.
125
126    TYPES: BEGIN OF KKBLO_INCL_LAYOUT.
127    include type kkblo_incl_layout0.
128    include type kkblo_incl_layout1.
129    types: END OF KKBLO_INCL_LAYOUT.
130
131    *--- Information about the layout of the list
132    TYPES: BEGIN OF KKBLO_LAYOUT.
133            include structure alv_s_layo.
134            include structure kkb_s_layo.
135            include structure alv_s_prnt.
136    INCLUDE TYPE SLIS_LAYOUT_ALV1.
137    INCLUDE TYPE SLIS_PRINT_ALV1.
138    INCLUDE TYPE KKBLO_INCL_LAYOUT1.
139    TYPES: END OF KKBLO_LAYOUT.
140
141    TYPES: BEGIN OF KKBLO_LPRINT,
142             FIRST_COL LIKE SY-CUCOL,      " start column
143             FIRST_ROW LIKE SY-CUROW,      " start row
144             FIRST_HEADCOL LIKE SY-CUCOL,  " start column for header
145             WIDTH TYPE I,                 " width of the list
146             ROWS TYPE I,                  " number of lines
147             ROWS_SLAVE TYPE I,            " number of lines
148             HEADER_LINES TYPE I,          " number of header lines
149             SEPARATOR LIKE SY-VLINE,      " character between two columns
150             OFFSET_BOX TYPE I,            " offset for checkboxes
151             OFFSET_LIGHTS TYPE I,         " offset for exceptions
152             OFFSET_FOLDER TYPE I,         " offset for folder
153             OFFSET_TOTALS TYPE I,         " offset for totals
154           END OF KKBLO_LPRINT.
155
156    *--- Structure for key information
157    TYPES: BEGIN OF KKBLO_KEYINFO,
158             MASTER01 TYPE KKBLO_FIELDNAME,
159             SLAVE01 TYPE KKBLO_FIELDNAME,
160             MASTER02 TYPE KKBLO_FIELDNAME,
161             SLAVE02 TYPE KKBLO_FIELDNAME,
162             MASTER03 TYPE KKBLO_FIELDNAME,
163             SLAVE03 TYPE KKBLO_FIELDNAME,
164             MASTER04 TYPE KKBLO_FIELDNAME,
165             SLAVE04 TYPE KKBLO_FIELDNAME,
166             MASTER05 TYPE KKBLO_FIELDNAME,
167             SLAVE05 TYPE KKBLO_FIELDNAME,
168           END OF KKBLO_KEYINFO.
169
170    *--- information about subtotals and filter
171    TYPES: BEGIN OF KKBLO_SFINFO,
172            INDEX LIKE SY-TABIX,
173            INDEX_SLAVE LIKE SY-TABIX,
174            SUM(3) TYPE C,
175            FILTER(3) TYPE C,
176            SUM_OFF(1) TYPE C,
177          END OF KKBLO_SFINFO.
178
179    TYPES: KKBLO_T_SFINFO TYPE KKBLO_SFINFO OCCURS 1.
180
181    TYPES: BEGIN OF KKBLO_GROUPLEVELS.
182            include structure alv_s_grpl.
183            include structure kkb_s_grpl.
184    types:  CORRINDEX_MASTER LIKE SY-TABIX,
185            CORRINDEX_SLAVE  LIKE SY-TABIX,
186            cindex_from  like sy-tabix,
187          END OF KKBLO_GROUPLEVELS.
188
189    TYPES: KKBLO_T_GROUPLEVELS TYPE KKBLO_GROUPLEVELS OCCURS 1.
190
191    *--- Catalogue of the fields (and description of these fields)
192    TYPES: BEGIN OF KKBLO_FIELDCAT.
193            include structure alv_s_fcat.
194    "YI3K487344 Cl_abap_typedescr=>TYPEKIND_UTCLONG -> PARAMETER1 = TIMEZONE of UTCLONG
195            include structure kkb_s_fcat.
196    include TYPE SLIS_FIELDCAT_ALV1.
197    TYPES:   ROLLNAME_DDIC  LIKE DD03P-ROLLNAME,
198             TECH_ROW_POS   LIKE SY-CUCOL, " technical field
199             TECH_COL_POS   LIKE SY-CUCOL, " technical field
200             TECH_COMPLETE  TYPE C,        " technical flag DO NOT CHANGE!!
201           END OF KKBLO_FIELDCAT.
202
203    TYPES: KKBLO_T_FIELDCAT TYPE KKBLO_FIELDCAT OCCURS 1.
204
205    TYPES: KKBLO_EVENT_EXIT TYPE SLIS_EVENT_EXIT.
206    TYPES: KKBLO_T_EVENT_EXIT TYPE SLIS_T_EVENT_EXIT.
207
208    TYPES: KKBLO_SUBTOT_TEXT TYPE SLIS_SUBTOT_TEXT.
209
210    * special groups for column selection
211    TYPES: BEGIN OF KKBLO_SP_GROUP.
212    include structure alv_s_sgrp.
213    include structure kkb_s_sgrp.
214    types: END OF KKBLO_SP_GROUP.
215    TYPES: KKBLO_T_SP_GROUP TYPE KKBLO_SP_GROUP OCCURS 1.
216
217    * Controlling structure
218    TYPES: BEGIN OF KKBLO_CONTROL,
219             DISPLAY_ONLY(1) TYPE C,
220             SAVE(1)   TYPE C,
221             DEF_GROUP(4) TYPE C,
222             ROWNO_CHANGE(1) TYPE C,
223             LISTTYPE(1) TYPE C,           " (H)ier., (S)imple, (M)atrix
224             ROWS TYPE I,                  " number of lines
225             ROWS_SLAVE TYPE I,            " number of lines (position)
226             T_GROUP TYPE KKBLO_T_SP_GROUP," table of groups
227             S_VARIANT LIKE DISVARIANT,
228    *        Display variants
229             HEADER_TEXT(20) TYPE C,       " Text for header button
230             ITEM_TEXT(20) TYPE C,         " Text for item button
231             DEFAULT_ITEM(1) TYPE C,       " Items as default
232    *
233             TOTALS_INACT(1) TYPE C,
234             COLPOS_INACT(1) TYPE C,
235             ROWPOS_INACT(1) TYPE C,
236             LENGTH_INACT(1) TYPE C,
237             TOTALS_INVIS(1) TYPE C,
238             COLPOS_INVIS(1) TYPE C,
239             ROWPOS_INVIS(1) TYPE C,
240             LENGTH_INVIS(1) TYPE C,
241             OFFSET TYPE I,
242             GROUP_CHANGE_EDIT(1) TYPE C,  " Settings by user for new group
243    *        Sortpopup
244             SORT_DEFAULT(1) TYPE C,
245             NO_SUBTOTALS(1) TYPE C,       " no subtotals possible
246             NO_TOTALLINE(1) TYPE C,       " no totalline
247             UNIT_SPLITTING(1) TYPE C,
248           END OF KKBLO_CONTROL.
249
250    * information cursor position
251    TYPES:  KKBLO_SELFIELD TYPE SLIS_SELFIELD.
252
253    * information for sort and subtotals
254    TYPES: BEGIN OF KKBLO_SORTINFO.
255            include structure alv_s_sort.
256            include structure kkb_s_sort.
257    types: END OF KKBLO_SORTINFO.
258    TYPES: KKBLO_T_SORTINFO TYPE KKBLO_SORTINFO OCCURS 0.
259
260    TYPES: BEGIN OF KKBLO_SORT_EXTEND.
261    INCLUDE TYPE KKBLO_SORTINFO.
262    types:  colcount type i,
263            end of kkblo_sort_extend.  "Y6BK082363/Y6BK083036
264    TYPES: KKBLO_T_SORT_EXTEND TYPE KKBLO_SORT_EXTEND OCCURS 0.
265
266    TYPES: BEGIN OF KKBLO_SUBTOT_OPTIONS,
267             OFFSET TYPE I,
268             TOTALS(1) TYPE C,
269             TOTALS_ON_LIST(1) TYPE C,
270             SUBTOTALS(1) TYPE C,
271             SUBTOTALS_ON_LIST(1) TYPE C,
272             MAX_LEVEL TYPE I,
273             LEN_FOR_TEXT TYPE I,
274             ULINE_FROM_LEVEL TYPE I,
275             T_LEVELS TYPE KKBLO_T_SORT_EXTEND,
276           END OF KKBLO_SUBTOT_OPTIONS.
277
278    TYPES: BEGIN OF KKBLO_SORTSHOW,
279             FIELDNAME TYPE KKBLO_FIELDNAME,
280             TABNAME TYPE KKBLO_FIELDNAME,
281             SELTEXT(40) TYPE C,
282             UP(50) TYPE C,
283             DOWN(50) TYPE C,
284             SUBTOT(50) TYPE C,
285             UP_PRINT(15) TYPE C,
286             DOWN_PRINT(15) TYPE C,
287             SUBTOT_PRINT(15) TYPE C,
288           END OF KKBLO_SORTSHOW.
289    TYPES: KKBLO_T_SORTSHOW TYPE KKBLO_SORTSHOW OCCURS 1.
290
291    * information for scrolling columns
292    TYPES: BEGIN OF KKBLO_COLUMNS,
293            COLNR LIKE SY-CUCOL,
294            ROWNR LIKE SY-CUROW,
295            COLINDEX LIKE SY-CUCOL,
296            FIELDNAME TYPE KKBLO_FIELDNAME,
297            TABNAME TYPE KKBLO_TABNAME,
298            KEY(1)   TYPE C,
299            LAST(1)   TYPE C,
300          END OF KKBLO_COLUMNS.
301    TYPES: KKBLO_T_COLUMNS TYPE KKBLO_COLUMNS OCCURS 1.
302
303
304    TYPES: BEGIN OF KKBLO_SELOTAB,
305            FELDT(40),
306            VALUF(80),
307            VALUT(80),
308            SIGN0(2),
309            OPTIO(2),
310            STYPE(1),
311            LTEXT(50),
312          END OF KKBLO_SELOTAB.
313    TYPES: KKBLO_T_SELOTAB TYPE KKBLO_SELOTAB OCCURS 1.
314
315    * filter
316    TYPES: BEGIN OF KKBLO_FILTER.
317            include structure alv_s_filt.
318            include structure kkb_s_filt.
319    INCLUDE TYPE SLIS_FILTER_ALV1.
320    TYPES: END OF KKBLO_FILTER.
321
322    TYPES: KKBLO_T_FILTER TYPE KKBLO_FILTER OCCURS 1.
323
324    TYPES: BEGIN OF KKBLO_DETAIL_FILTER,
325             FIELDNAME TYPE KKBLO_FIELDNAME,
326             TABNAME TYPE KKBLO_TABNAME,
327             SELTEXT(40),
328             VALUF(80),
329             VALUT(80),
330             VALUF_PRINT(80),
331             VALUT_PRINT(80),
332             SIGN0(4),
333             SIGN0_PRINT(4),
334             SIGN_ICON(4),
335             SIGN_ICON_PRINT(4),
336             OPTIO(2),
337             STYPE(1),
338             OUTPUTLEN LIKE DFIES-OUTPUTLEN,
339             EXCEPTION(1) TYPE C,
340             OR(1) TYPE C,
341           END OF KKBLO_DETAIL_FILTER.
342
343    TYPES: KKBLO_T_DETAIL_FILTER TYPE KKBLO_DETAIL_FILTER OCCURS 1.
344
345    * delete or add an entry in the select-option info
346    * nur in SLIS ändern!!
347    TYPES: KKBLO_SELENTRY_HIDE TYPE SLIS_SELENTRY_HIDE_ALV.
348    TYPES: KKBLO_T_SELENTRY_HIDE TYPE KKBLO_SELENTRY_HIDE OCCURS 1.
349
350    TYPES: KKBLO_SEL_HIDE TYPE SLIS_SEL_HIDE_ALV.
351
352    * information for selections
353    * nur in SLIS ändern!!
354    TYPES: KKBLO_SELDIS1 TYPE SLIS_SELDIS1_ALV.
355    TYPES: KKBLO_SELDIS TYPE KKBLO_SELDIS1 OCCURS 1.
356
357    * Header table for top of page
358    TYPES: BEGIN OF KKBLO_LISTHEADER.
359    INCLUDE TYPE SLIS_LISTHEADER.
360    TYPES: END OF KKBLO_LISTHEADER.
361    TYPES: KKBLO_T_LISTHEADER TYPE KKBLO_LISTHEADER OCCURS 1.
362
363    * Exporting Exit by user
364    TYPES: KKBLO_EXIT_BY_USER TYPE SLIS_EXIT_BY_USER.
365
366    * Detail
367    TYPES: BEGIN OF KKBLO_DETAIL,
368             KEYCHAR(60),
369             DATACHAR(132),
370             DATACHAR_PRINT(132),
371           END OF KKBLO_DETAIL.
372    TYPES: KKBLO_T_DETAIL TYPE KKBLO_DETAIL OCCURS 1.
373
374    TYPES: BEGIN OF KKBLO_COUNTTAB,
375             KEYCHAR(60),
376             DATACHAR TYPE I,
377           END OF KKBLO_COUNTTAB.
378    TYPES: KKBLO_T_COUNTTAB TYPE KKBLO_COUNTTAB OCCURS 1.
379
380    TYPES: BEGIN OF KKBLO_FIELDS,
381             FIELDNAME TYPE KKBLO_FIELDNAME,
382             TABNAME   TYPE KKBLO_TABNAME,
383             SELTEXT   LIKE DD03P-SCRTEXT_L,
384             OUTPUTLEN LIKE DD03P-OUTPUTLEN,
385             DO_SUM(20) TYPE C,
386             DO_SUM_PRINT(15) TYPE C,
387           END OF KKBLO_FIELDS.
388    TYPES: KKBLO_T_FIELDS TYPE KKBLO_FIELDS OCCURS 1.
389
390    TYPES: BEGIN OF KKBLO_HEADER,
391             EXCEPTION(4) TYPE C,
392             FOLDER(4) TYPE C,
393             TEXT01 TYPE KKBLO_ENTRY,
394             TEXT02 TYPE KKBLO_ENTRY,
395             TEXT03 TYPE KKBLO_ENTRY,
396             TEXT04 TYPE KKBLO_ENTRY,
397             TEXT05 TYPE KKBLO_ENTRY,
398             TEXT06 TYPE KKBLO_ENTRY,
399             TEXT07 TYPE KKBLO_ENTRY,
400             TEXT08 TYPE KKBLO_ENTRY,
401             TEXT09 TYPE KKBLO_ENTRY,
402             TEXT10 TYPE KKBLO_ENTRY,
403             TEXT11 TYPE KKBLO_ENTRY,
404             TEXT12 TYPE KKBLO_ENTRY,
405             TEXT13 TYPE KKBLO_ENTRY,
406             TEXT14 TYPE KKBLO_ENTRY,
407             TEXT15 TYPE KKBLO_ENTRY,
408             TEXT16 TYPE KKBLO_ENTRY,
409             TEXT17 TYPE KKBLO_ENTRY,
410             TEXT18 TYPE KKBLO_ENTRY,
411             TEXT19 TYPE KKBLO_ENTRY,
412             TEXT20 TYPE KKBLO_ENTRY,
413             TEXT21 TYPE KKBLO_ENTRY,
414             TEXT22 TYPE KKBLO_ENTRY,
415             TEXT23 TYPE KKBLO_ENTRY,
416             TEXT24 TYPE KKBLO_ENTRY,
417             TEXT25 TYPE KKBLO_ENTRY,
418             TEXT26 TYPE KKBLO_ENTRY,
419             TEXT27 TYPE KKBLO_ENTRY,
420             TEXT28 TYPE KKBLO_ENTRY,
421             TEXT29 TYPE KKBLO_ENTRY,
422             TEXT30 TYPE KKBLO_ENTRY,
423             TEXT31 TYPE KKBLO_ENTRY,
424             TEXT32 TYPE KKBLO_ENTRY,
425             TEXT33 TYPE KKBLO_ENTRY,
426             TEXT34 TYPE KKBLO_ENTRY,
427             TEXT35 TYPE KKBLO_ENTRY,
428             TEXT36 TYPE KKBLO_ENTRY,
429             TEXT37 TYPE KKBLO_ENTRY,
430             TEXT38 TYPE KKBLO_ENTRY,
431             TEXT39 TYPE KKBLO_ENTRY,
432             TEXT40 TYPE KKBLO_ENTRY,
433             TEXT41 TYPE KKBLO_ENTRY,
434             TEXT42 TYPE KKBLO_ENTRY,
435             TEXT43 TYPE KKBLO_ENTRY,
436             TEXT44 TYPE KKBLO_ENTRY,
437             TEXT45 TYPE KKBLO_ENTRY,
438             TEXT46 TYPE KKBLO_ENTRY,
439             TEXT47 TYPE KKBLO_ENTRY,
440             TEXT48 TYPE KKBLO_ENTRY,
441             TEXT49 TYPE KKBLO_ENTRY,
442             TEXT50 TYPE KKBLO_ENTRY,
443             TEXT51 TYPE KKBLO_ENTRY,
444             TEXT52 TYPE KKBLO_ENTRY,
445             TEXT53 TYPE KKBLO_ENTRY,
446             TEXT54 TYPE KKBLO_ENTRY,
447             TEXT55 TYPE KKBLO_ENTRY,
448             TEXT56 TYPE KKBLO_ENTRY,
449             TEXT57 TYPE KKBLO_ENTRY,
450             TEXT58 TYPE KKBLO_ENTRY,
451             TEXT59 TYPE KKBLO_ENTRY,
452             TEXT60 TYPE KKBLO_ENTRY,
453             TEXT61 TYPE KKBLO_ENTRY,
454             TEXT62 TYPE KKBLO_ENTRY,
455             TEXT63 TYPE KKBLO_ENTRY,
456             TEXT64 TYPE KKBLO_ENTRY,
457             TEXT65 TYPE KKBLO_ENTRY,
458             TEXT66 TYPE KKBLO_ENTRY,
459             TEXT67 TYPE KKBLO_ENTRY,
460             TEXT68 TYPE KKBLO_ENTRY,
461             TEXT69 TYPE KKBLO_ENTRY,
462             TEXT70 TYPE KKBLO_ENTRY,
463             TEXT71 TYPE KKBLO_ENTRY,
464             TEXT72 TYPE KKBLO_ENTRY,
465             TEXT73 TYPE KKBLO_ENTRY,
466             TEXT74 TYPE KKBLO_ENTRY,
467             TEXT75 TYPE KKBLO_ENTRY,
468             TEXT76 TYPE KKBLO_ENTRY,
469             TEXT77 TYPE KKBLO_ENTRY,
470             TEXT78 TYPE KKBLO_ENTRY,
471             TEXT79 TYPE KKBLO_ENTRY,
472             TEXT80 TYPE KKBLO_ENTRY,
473             TEXT81 TYPE KKBLO_ENTRY,
474             TEXT82 TYPE KKBLO_ENTRY,
475             TEXT83 TYPE KKBLO_ENTRY,
476             TEXT84 TYPE KKBLO_ENTRY,
477             TEXT85 TYPE KKBLO_ENTRY,
478             TEXT86 TYPE KKBLO_ENTRY,
479             TEXT87 TYPE KKBLO_ENTRY,
480             TEXT88 TYPE KKBLO_ENTRY,
481             TEXT89 TYPE KKBLO_ENTRY,
482             TEXT90 TYPE KKBLO_ENTRY,
483             TEXT91 TYPE KKBLO_ENTRY,
484             TEXT92 TYPE KKBLO_ENTRY,
485             TEXT93 TYPE KKBLO_ENTRY,
486             TEXT94 TYPE KKBLO_ENTRY,
487             TEXT95 TYPE KKBLO_ENTRY,
488             TEXT96 TYPE KKBLO_ENTRY,
489             TEXT97 TYPE KKBLO_ENTRY,
490             TEXT98 TYPE KKBLO_ENTRY,
491             TEXT99 TYPE KKBLO_ENTRY,
492           END OF KKBLO_HEADER.
*--- End of %_CKKBLO - 492 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_COLE2                                   Level 1    Page 9
Object           ZEYTDS_INV_EXTRACT                        Lines 43
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:37
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
Generated incl.  %_CSBDST                                  Level 1    Page 10
Object           ZEYTDS_INV_EXTRACT                        Lines 35
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:37
----------------------------------------------------------------------------------------------------
1      TYPE-POOL sbdst .
2
3      TYPES: sbdst_logical_system LIKE bapibds01-log_system,
4             sbdst_classname LIKE bapibds01-classname,
5             sbdst_classtype LIKE bapibds01-classtype,
6             sbdst_client LIKE bapibds01-client,
7             sbdst_object_key LIKE bapibds01-objkey,
8             sbdst_doc_id LIKE bapibds01-doc_id,
9             sbdst_doc_ver_no LIKE bapibds01-doc_ver_no,
10            sbdst_doc_var_id LIKE bapibds01-doc_var_id,
11            sbdst_doc_var_tg LIKE bapibds01-doc_var_tg,
12            sbdst_new_var_tg LIKE bapibds01-doc_var_tg,
13            sbdst_url LIKE bapibds01-uri,
14            sbdst_url_lifetime LIKE bapibds01-uri_life,
15            sbdst_x LIKE bapibds01-x,
16            sbdst_binary_flag LIKE bapibds01-x,
17            sbdst_mimetype LIKE bapibds01-mimetype.
18
19     TYPES: sbdst_signature LIKE bapisignat OCCURS 1,
20            sbdst_connections LIKE bapiconnec OCCURS 1,
21            sbdst_components LIKE bapicompon OCCURS 1,
22            sbdst_components2 LIKE bapicompo2 OCCURS 1,
23            sbdst_components3 like bapicompo3 occurs 1,
24            sbdst_content LIKE bapiconten OCCURS 1,
25            sbdst_ascii_content LIKE bapiascont OCCURS 1,
26            sbdst_files LIKE bapifiles OCCURS 1,
27            sbdst_uri LIKE bapiuri OCCURS 1,
28            sbdst_properties LIKE bapiproper OCCURS 1,
29            sbdst_dproperties LIKE bapidpropt OCCURS 1,
30            sbdst_lproperties LIKE bapiproptl OCCURS 1,
31            sbdst_relations LIKE bapirelat OCCURS 1,
32            sbdst_srelations LIKE bapisrelat OCCURS 1,
33            sbdst_excluding LIKE bdn_fkt OCCURS 1,
34            sbdst_commfile_entries LIKE bapicomfil OCCURS 1,
35            sbdst_query LIKE bapiquery OCCURS 1.
*--- End of %_CSBDST - 35 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CSFES                                   Level 1    Page 11
Object           ZEYTDS_INV_EXTRACT                        Lines 75
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:37
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
Generated incl.  %_CSLIS                                   Level 1    Page 12
Object           ZEYTDS_INV_EXTRACT                        Lines 543
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:37
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
Generated incl.  %_CSOI                                    Level 1    Page 13
Object           ZEYTDS_INV_EXTRACT                        Lines 328
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:37
----------------------------------------------------------------------------------------------------
1      TYPE-POOL SOI .
2
3      TYPES: SOI_CONTROL_PARAM_TYPE(256).
4
5      TYPES: SOI_RET_STRING(256) TYPE C, SOI_CUSTOM_PARAM(256) TYPE C.
6      TYPES: SOI_MESSAGE_PARAM(50) TYPE C.
7      TYPES: SOI_PROXY_ERROR_CODE TYPE I.
8      TYPES: SOI_BOOLEAN TYPE C.             " 'X' - TRUE, ' ' - FALSE
9
10     TYPES: SOI_FIELDS_TABLE TYPE STANDARD TABLE OF RFC_FIELDS.
11     TYPES: SOI_PROPERTIES_TABLE TYPE STANDARD TABLE OF DPPROPS.
12
13     TYPES: SOI_LINK_ITEM_NAME(128).
14     TYPES: SOI_STRING(64).
15
16     TYPES: BEGIN OF SOI_LINK_ITEM,
17                 ITEM_NAME         TYPE SOI_LINK_ITEM_NAME,
18                 ITEM_TITLE        TYPE SOI_LINK_ITEM_NAME,
19                 SUBITEMS_ALLOWED  TYPE C,
20                 SUBITEM_NAME      TYPE SOI_LINK_ITEM_NAME,
21            END OF SOI_LINK_ITEM.
22
23     TYPES: SOI_LINK_ITEM_TABLE TYPE TABLE OF SOI_LINK_ITEM.
24
25     TYPES: SOI_FIELD_NAME(256) TYPE C.
26
27     TYPES: BEGIN OF SOI_FIELDS,
28              ITEM_NAME TYPE SOI_FIELD_NAME,
29            END OF SOI_FIELDS.
30
31     TYPES: BEGIN OF SOI_SHEETS,
32              SHEET_NAME TYPE SOI_FIELD_NAME,
33            END OF SOI_SHEETS.
34
35     TYPES: BEGIN OF SOI_COLS,
36                COLINDEX TYPE I,
37            END OF SOI_COLS.
38
39     TYPES: SOI_COLS_TABLE TYPE STANDARD TABLE OF SOI_COLS
40                                  WITH DEFAULT KEY.
41
42     TYPES: BEGIN OF SOI_COL_NAMES,
43                COLNAME(256) TYPE C,
44            END OF SOI_COL_NAMES.
45
46     TYPES: SOI_COLNAMES_TABLE TYPE STANDARD TABLE OF SOI_COL_NAMES
47                                  WITH DEFAULT KEY.
48
49     TYPES: BEGIN OF SOI_TABLEINFO_ITEM,
50               ROWS TYPE I,
51               COLUMNS TYPE I,
52            END OF SOI_TABLEINFO_ITEM.
53
54     TYPES: SOI_TABLEINFO_TABLE TYPE STANDARD TABLE OF SOI_TABLEINFO_ITEM
55                                   WITH DEFAULT KEY.
56
57     TYPES: BEGIN OF SOI_TEMPLATE_INFO_ITEM,
58             NAME(128) TYPE C,
59             PATH(256) TYPE C,
60             FULLNAME(512) TYPE C,
61            END OF SOI_TEMPLATE_INFO_ITEM.
62
63     TYPES: SOI_TEMPLATE_INFO TYPE STANDARD TABLE OF SOI_TEMPLATE_INFO_ITEM
64                                 WITH DEFAULT KEY.
65
66     TYPES: SOI_FIELDS_NAME_TABLE TYPE STANDARD TABLE OF SOI_FIELDS
67                                  WITH DEFAULT KEY.
68
69     TYPES: SOI_SHEETS_TABLE TYPE STANDARD TABLE OF SOI_SHEETS
70                                  WITH DEFAULT KEY.
71
72     TYPES: BEGIN OF SOI_FORM_ITEM,
73              TYPE TYPE C,
74              NAME(128) TYPE C,
75              NUMBER(3) TYPE C,
76              VALUE(256) TYPE C,
77              CODE TYPE C,
78            END OF SOI_FORM_ITEM.
79
80     TYPES: SOI_FORM_LIST TYPE STANDARD TABLE OF SOI_FORM_ITEM
81                         WITH DEFAULT KEY.
82
83     TYPES: BEGIN OF SOI_RANGE_ITEM,
84              NAME(128) TYPE C,
85              ROWS(4) TYPE C,
86              COLUMNS(4) TYPE C,
87              CODE(1) TYPE C,
88            END OF SOI_RANGE_ITEM.
89
90     TYPES: SOI_RANGE_LIST TYPE STANDARD TABLE OF SOI_RANGE_ITEM
91                          WITH DEFAULT KEY.
92
93     TYPES: BEGIN OF SOI_FULL_RANGE_ITEM,
94              NAME(128) TYPE C,
95              TOP TYPE I,
96              LEFT TYPE I,
97              ROWS TYPE I,
98              COLUMNS TYPE I,
99              SHEET(128) TYPE C,
100           END OF SOI_FULL_RANGE_ITEM.
101
102    TYPES: SOI_FULL_RANGE_TABLE TYPE STANDARD TABLE OF SOI_FULL_RANGE_ITEM
103                         WITH DEFAULT KEY.
104
105    TYPES: BEGIN OF SOI_STYLE_ITEM,
106             NAME(128) TYPE C,
107             TOP TYPE I,
108             LEFT TYPE I,
109             ROWS TYPE I,
110             COLUMNS TYPE I,
111             STYLE(128) TYPE C,
112           END OF SOI_STYLE_ITEM.
113
114    TYPES: SOI_STYLE_TABLE TYPE STANDARD TABLE OF SOI_STYLE_ITEM
115                         WITH DEFAULT KEY.
116
117    TYPES: BEGIN OF SOI_GENERIC_ITEM,
118             ROW(4) TYPE C,
119             COLUMN(4) TYPE C,
120             VALUE(256) TYPE C,
121           END OF SOI_GENERIC_ITEM.
122
123    TYPES: SOI_GENERIC_TABLE TYPE STANDARD TABLE OF SOI_GENERIC_ITEM
124                          WITH DEFAULT KEY.
125
126    TYPES: BEGIN OF SOI_NAMECOL_ITEM,
127             NAME(256) TYPE C,
128             COLUMN TYPE I,
129           END OF SOI_NAMECOL_ITEM.
130
131    TYPES: SOI_NAMECOL_TABLE TYPE STANDARD TABLE OF SOI_NAMECOL_ITEM
132                          WITH DEFAULT KEY.
133
134    TYPES: BEGIN OF SOI_NAMETYPE_ITEM,
135             NAME(256) TYPE C,
136             TYPE TYPE I,
137           END OF SOI_NAMETYPE_ITEM.
138
139    TYPES: SOI_NAMETYPE_TABLE TYPE STANDARD TABLE OF SOI_NAMETYPE_ITEM
140                          WITH DEFAULT KEY.
141
142    TYPES: BEGIN OF SOI_COLTYPE_ITEM,
143             COL TYPE I,
144             TYPE TYPE I,
145           END OF SOI_COLTYPE_ITEM.
146
147    TYPES: SOI_COLTYPE_TABLE TYPE STANDARD TABLE OF SOI_COLTYPE_ITEM
148                          WITH DEFAULT KEY.
149
150    TYPES: BEGIN OF SOI_FORMAT_ITEM,
151             NAME(256) TYPE C,
152             FRONT TYPE I,
153             BACK TYPE I,
154             FONT(30) TYPE C,
155             SIZE TYPE I,
156             BOLD TYPE I,
157             ITALIC TYPE I,
158             ALIGN TYPE I,
159             FRAMETYP TYPE I,
160             FRAMECOLOR TYPE I,
161             CURRENCY(3) TYPE C,
162             NUMBER TYPE I,
163             DECIMALS TYPE I,
164           END OF SOI_FORMAT_ITEM.
165
166    TYPES: SOI_FORMAT_TABLE TYPE STANDARD TABLE OF SOI_FORMAT_ITEM
167                         WITH DEFAULT KEY.
168
169    TYPES: BEGIN OF SOI_CELL_ITEM,
170             TOP TYPE I,
171             LEFT TYPE I,
172             ROWS TYPE I,
173             COLUMNS TYPE I,
174             FRONT TYPE I,
175             BACK TYPE I,
176             FONT(30) TYPE C,
177             SIZE TYPE I,
178             BOLD TYPE I,
179             ITALIC TYPE I,
180             ALIGN TYPE I,
181             FRAMETYP TYPE I,
182             FRAMECOLOR TYPE I,
183             CURRENCY(3) TYPE C,
184             NUMBER TYPE I,
185             DECIMALS TYPE I,
186             INPUT TYPE I,
187           END OF SOI_CELL_ITEM.
188
189    TYPES: SOI_CELL_TABLE TYPE STANDARD TABLE OF SOI_CELL_ITEM
190                         WITH DEFAULT KEY.
191
192    TYPES: BEGIN OF SOI_DIMENSION_ITEM,
193             ROW TYPE I,
194             COLUMN TYPE I,
195             ROWS TYPE I,
196             COLUMNS TYPE I,
197           END OF SOI_DIMENSION_ITEM.
198
199    TYPES: SOI_DIMENSION_TABLE TYPE STANDARD TABLE OF SOI_DIMENSION_ITEM
200                            WITH DEFAULT KEY.
201
202    TYPES: SOI_SEMA_TABLE TYPE STANDARD TABLE OF GXXLT_S
203                            WITH DEFAULT KEY.
204
205    TYPES: SOI_HKEY_TABLE TYPE STANDARD TABLE OF GXXLT_H
206                            WITH DEFAULT KEY.
207
208    TYPES: SOI_VKEY_TABLE TYPE STANDARD TABLE OF GXXLT_V
209                            WITH DEFAULT KEY.
210
211    TYPES: SOI_ONLINE_TABLE TYPE STANDARD TABLE OF GXXLT_O
212                            WITH DEFAULT KEY.
213
214    TYPES: SOI_DOCUMENT_TYPE(70) TYPE C.
215
216    TYPES: BEGIN OF SOI_AREA_ITEM,
217             TOP TYPE I,
218             LEFT TYPE I,
219             ROWS TYPE I,
220             COLUMNS TYPE I,
221             INDEX TYPE C,
222           END OF SOI_AREA_ITEM.
223
224    TYPES: SOI_AREA_TABLE TYPE STANDARD TABLE OF SOI_AREA_ITEM
225                            WITH DEFAULT KEY.
226
227    TYPES: BEGIN OF SOI_MAP_ITEM,
228             ID TYPE I,
229             TYPE(128) TYPE C,
230             SUBTYPE(128) TYPE C,
231           END OF SOI_MAP_ITEM.
232
233    TYPES: SOI_MAP_TABLE TYPE STANDARD TABLE OF SOI_MAP_ITEM
234                            WITH DEFAULT KEY.
235
236    TYPES: BEGIN OF SOI_HEAD_ITEM,
237             TYP TYPE C,
238             KEY(20) TYPE C,
239             INFO(60) TYPE C,
240           END OF SOI_HEAD_ITEM.
241
242    TYPES: SOI_HEAD_TABLE TYPE STANDARD TABLE OF SOI_HEAD_ITEM
243                            WITH DEFAULT KEY.
244
245    TYPES: BEGIN OF SOI_HIERARCHY_ITEM,
246             FIRSTLINE TYPE I,
247             LENGTH TYPE I,
248             SHEET(128) TYPE C,
249             MODE TYPE I,
250           END OF SOI_HIERARCHY_ITEM.
251
252    TYPES: SOI_HIERARCHY_TABLE TYPE STANDARD TABLE OF SOI_HIERARCHY_ITEM
253                            WITH DEFAULT KEY.
254
255    TYPES: BEGIN OF SOI_DOCUMENT_TYPE_DESCR,
256              DOCUMENT_TYPE             TYPE SOI_DOCUMENT_TYPE, " prog id
257              TYPE_FULL_NAME(70)        TYPE C, " full name
258              TYPE_SHORT_NAME(20)       TYPE C, " short name
259              APPLICATION_NAME(50)      TYPE C, " application name
260              SUPPORTED_INTERFACES(256) TYPE C, " supported SAP interfaces
261              AVAILABLE(1)              TYPE C, " X on return when available
262           END OF SOI_DOCUMENT_TYPE_DESCR.
263
264    TYPES: SOI_DOCUMENT_TYPE_DESCR_LIST
265                       TYPE STANDARD TABLE OF SOI_DOCUMENT_TYPE_DESCR
266                                                           WITH DEFAULT KEY.
267
268    CONSTANTS:                                                "123456789012
269               SOI_TYPE_APPLICATION(11)  TYPE C VALUE 'application',
270               SOI_TYPE_IMAGE(5)         TYPE C VALUE 'image',
271               SOI_SUBTYPE_OLEOBJECT(11) TYPE C VALUE 'x-oleobject',
272               SOI_SUBTYPE_BITMAP(8)     TYPE C VALUE 'x-ms-bmp',
273               SOI_SUBTYPE_GIF(3)        TYPE C VALUE 'gif',
274               SOI_SUBTYPE_JPEG(4)       TYPE C VALUE 'jpeg',
275               SOI_SUBTYPE_RTF(5)        TYPE C VALUE 'x-rtf'.
276
277    CONSTANTS:
278               SOI_DOCTYPE_WORD_DOCUMENT(13) TYPE C
279                                                  VALUE 'Word.Document',
280               SOI_DOCTYPE_WORD95_DOCUMENT(15) TYPE C
281                                                  VALUE 'Word.Document.6',
282               SOI_DOCTYPE_WORD97_DOCUMENT(15) TYPE C
283                                                  VALUE 'Word.Document.8',
284               SOI_DOCTYPE_EXCEL_SHEET(11) TYPE C VALUE 'Excel.Sheet',
285               SOI_DOCTYPE_EXCEL_CHART(11) TYPE C VALUE 'Excel.Chart',
286               SOI_DOCTYPE_EXCEL95_SHEET(13) TYPE C VALUE 'Excel.Sheet.5',
287               SOI_DOCTYPE_EXCEL95_CHART(13) TYPE C VALUE 'Excel.Chart.5',
288               SOI_DOCTYPE_EXCEL97_SHEET(13) TYPE C VALUE 'Excel.Sheet.8',
289               SOI_DOCTYPE_EXCEL97_CHART(13) TYPE C VALUE 'Excel.Chart.8',
290
291               SOI_DOCTYPE_WORDPRO_DOCUMENT(16) TYPE C
292                                                   VALUE 'WordPro.Document',
293               SOI_DOCTYPE_LOTUS123_WORKBOOK(17) TYPE C
294                                                  VALUE 'Lotus123.Workbook',
295               SOI_DOCTYPE_LOTUS123_WORKBK97(20) TYPE C
296                                             VALUE 'Lotus123.Workbook.97',
297
298               SOI_DOCTYPE_WORDPERF7_DOCUMENT(6) TYPE C VALUE 'WP7Doc',
299               SOI_DOCTYPE_WORDPERF8_DOCUMENT(6) TYPE C VALUE 'WP8Doc',
300
301               SOI_DOCTYPE_SWRITER_DOCUMENT(26) TYPE C
302                                      VALUE 'soffice.StarWriterDocument',
303               SOI_DOCTYPE_SWRITER31_DOCUMENT(29) TYPE C
304                                      VALUE 'swriter3.StarWriterDocument.3',
305               SOI_DOCTYPE_SWRITER40_DOCUMENT(28) TYPE C
306                                      VALUE 'soffice.StarWriterDocument.4',
307
308               SOI_DOCTYPE_VISIO_DOCUMENT(13) TYPE C VALUE 'Visio.Drawing',
309               SOI_DOCTYPE_VISIO4_DOCUMENT(15) TYPE C
310                                                    VALUE 'Visio.Drawing.4'.
311
312    CONSTANTS:
313               SOI_DOCFORMAT_COMPOUND(3) TYPE C VALUE 'OLE',
314               SOI_DOCFORMAT_NATIVE(6)   TYPE C VALUE 'NATIVE',
315               SOI_DOCFORMAT_RTF(3)      TYPE C VALUE 'RTF',
316               SOI_DOCFORMAT_TEXT(4)     TYPE C VALUE 'TEXT'.
317
318    * Constants for I_OI_DOCUMENT_PROXY~GET_APPLICATION_PROPERTY
319    CONSTANTS:                                        "12345678901234567890
320        SOI_PROP_TEMPLATE_PATH(13)       TYPE C VALUE 'TEMPLATE_PATH',
321
322        SOI_PROP_INTERNATIONAL(13)       TYPE C VALUE 'INTERNATIONAL',
323        SOI_SUBP_INTERNAT_DECIMALSEP(17) TYPE C VALUE 'DECIMAL_SEPARATOR',
324        SOI_SUBP_INTERNAT_THOUSANDSSEP(19)
325                                         TYPE C VALUE 'THOUSANDS_SEPARATOR',
326        SOI_SUBP_INTERNAT_LISTSEP(14)    TYPE C VALUE 'LIST_SEPARATOR',
327        SOI_SUBP_INTERNAT_DATESEP(14)    TYPE C VALUE 'DATE_SEPARATOR',
328        SOI_SUBP_INTERNAT_TIMESEP(14)    TYPE C VALUE 'TIME_SEPARATOR'.
*--- End of %_CSOI - 328 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CTRUXS                                  Level 1    Page 14
Object           ZEYTDS_INV_EXTRACT                        Lines 166
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:37
----------------------------------------------------------------------------------------------------
1      type-pool truxs .
2
3      * Typ Vertragsnummer
4      types truxs_ranl  type ranl.
5      types truxs_t_ranl type truxs_ranl occurs 0.
6      types: begin of truxs_struc_ranl,
7               sign(1),
8               option(2),
9               low  type truxs_ranl,
10              high type truxs_ranl,
11            end   of truxs_struc_ranl.
12     types truxs_range_ranl type truxs_struc_ranl occurs 0.
13
14     * Typ Anlageform
15     types truxs_sanlf  type sanlf.
16     types truxs_t_sanlf type truxs_sanlf occurs 0.
17     types: begin of truxs_struc_sanlf,
18              sign(1),
19              option(2),
20              low  type truxs_sanlf,
21              high type truxs_sanlf,
22            end   of truxs_struc_sanlf.
23     types truxs_range_sanlf type truxs_struc_sanlf occurs 0.
24
25     * Typ BUKRS
26     types truxs_bukrs  type bukrs.
27     types truxs_t_bukrs type truxs_bukrs occurs 0.
28     types: begin of truxs_struc_bukrs,
29              sign(1),
30              option(2),
31              low  type truxs_bukrs,
32              high type truxs_bukrs,
33            end   of truxs_struc_bukrs.
34     types truxs_range_bukrs type truxs_struc_bukrs occurs 0.
35
36     * Typ Partnr
37     types truxs_partnr  like bp000-partnr.
38     types truxs_t_partnr type truxs_partnr occurs 0.
39     types: begin of truxs_struc_partnr,
40              sign(1),
41              option(2),
42              low  type truxs_partnr,
43              high type truxs_partnr,
44            end   of truxs_struc_partnr.
45     types truxs_range_partnr type truxs_struc_partnr occurs 0.
46     * Typ Customer
47     types truxs_customer like bp000-customer.
48     types truxs_t_customer type truxs_customer occurs 0.
49     types: begin of truxs_struc_customer,
50              sign(1),
51              option(2),
52              low  type truxs_customer,
53              high type truxs_customer,
54            end   of truxs_struc_customer.
55     types truxs_range_customer type truxs_struc_customer occurs 0.
56     * Typ Rklammer
57     types truxs_rklammer type rklammer.
58     types truxs_t_rklammer type truxs_rklammer occurs 0.
59     * Relation alte/neue Debitorennummer zu Partner
60     types truxs_kunnr like knb1-kunnr.
61     types truxs_altkn like knb1-altkn.
62     types: begin of truxs_struc_oldnew_debitor,
63               partnr type truxs_partnr,
64               kunnr  type truxs_kunnr,
65               bukrs  like knb1-bukrs,
66               altkn  type truxs_altkn,
67            end of truxs_struc_oldnew_debitor.
68     types truxs_oldnew_debitor type truxs_struc_oldnew_debitor occurs 0.
69     * weitere types für Strukturprüfung
70     types: begin of truxs_struc_buffered_values.
71             include structure dfies.
72     types:     fieldvalues(72) type c,
73                domvalue_l      like dd07l-domvalue_l,
74                domvalue_h      like dd07l-domvalue_h,
75            end of truxs_struc_buffered_values.
76     types truxs_buffered_values type truxs_struc_buffered_values occurs 0.
77     types truxs_dfies like dfies occurs 0.
78
79     types: begin of truxs_struct_error_fields,
80               tabname     like dfies-tabname,
81               fieldname   like dfies-fieldname,
82               fieldvalue  like sy-msgv1,
83            end   of truxs_struct_error_fields.
84     types truxs_error_fields type truxs_struct_error_fields occurs 0.
85
86     * Typ TABIX
87     types truxs_tabix  like sy-tabix.
88     types truxs_t_tabix type truxs_tabix occurs 0.
89
90     * Type Relation Modulepool+ Dynnr to data structure
91
92     types:  begin of truxs_struc_bdcdata_generate,
93                 dynpro_langu      like sy-langu,
94                 modulpool         like d020s-prog,
95                 dynpro_nr         like d020s-dnum,
96                 sub_modulpool     like d020s-prog,
97                 sub_dynpro_nr     like d020s-dnum,
98                 dynbegin          like bdcdata-dynbegin,
99                 fieldname_ok_code like d021s-fnam,
100                ok_code           like sy-tcode,
101            end   of truxs_struc_bdcdata_generate.
102
103    types: truxs_dynpros type truxs_struc_bdcdata_generate occurs 0.
104
105    * Server Selection
106    *    APP = Application Server
107    *    PRS = Presentation Server
108    *    OLE2 = OLE2 Server
109    types: truxs_server    type trux_servertyp.
110
111    * File formats:
112    *    ASC  = Flat ASCII
113    *    CSV  = Comma Separated Values
114    *    TXT  = TXT Format (Notepad)
115    *    HTM  = Hypertext Markup Language
116    *    HTML = Hypertext Markup Language
117    types: truxs_fileformat  type trtm_format.
118
119    types truxs_t_text_data(4096) type c occurs 0.
120
121    * Partnerumstellung
122    * BP000
123    types:  begin of truxs_struc_bp000,
124                partnr     like bp000-partnr,
125                extpartnr  like bp000-extpartnr,
126                customer   like bp000-customer,
127                adr_ref    like bp000-adr_ref,
128            end   of truxs_struc_bp000.
129    types: truxs_t_bp000 type truxs_struc_bp000 occurs 0.
130
131    * BP1000
132    types:  begin of truxs_struc_bp1000,
133                partnr     like bp1000-partnr,
134                roletyp    like bp1000-roletyp,
135                role       like bp1000-role,
136            end   of truxs_struc_bp1000.
137    types: truxs_t_bp1000 type truxs_struc_bp1000 occurs 0.
138
139    * BPdbank
140    types:  begin of truxs_struc_bpdbank.
141            include structure bpdbank.
142    types:  end   of truxs_struc_bpdbank.
143    types: truxs_t_bpdbank type truxs_struc_bpdbank occurs 0.
144
145    * BPDAZAH
146    types:  begin of truxs_struc_bpdazah,
147                partnr     like bpdazah-partnr,
148                customer   like bpdazah-customer,
149                bukrs      like bpdazah-bukrs,
150                zwels      like bpdazah-zwels,
151            end   of truxs_struc_bpdazah.
152    types: truxs_t_bpdazah type truxs_struc_bpdazah occurs 0.
153
154    types: begin of truxs_MEMORYID_parameter,
155             MEMORYID type MEMORYID,
156             field    type char40,
157           end of truxs_MEMORYID_parameter.
158    types: truxs_tab_MEMORYID_parameter
159                            type table of truxs_MEMORYID_parameter
160                            initial size 0.
161
162    types : begin of truxs_xml_line,
163                data(256) TYPE x,
164            end of truxs_xml_line.
165
166    types: truxs_xml_table TYPE TABLE OF truxs_xml_line.
*--- End of %_CTRUXS - 166 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  <REPINI>                                  Level 1    Page 15
Object           ZEYTDS_INV_EXTRACT                        Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:37
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
Generated incl.  <SYSINI>                                  Level 1    Page 16
Object           ZEYTDS_INV_EXTRACT                        Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:37
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
Generated incl.  <SYSSEL>                                  Level 1    Page 17
Object           ZEYTDS_INV_EXTRACT                        Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:37
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
Generated incl.  CL_ALV_GRID_VIEW_FRONTEND_DATACT          Level 1    Page 18
Object           ZEYTDS_INV_EXTRACT                        Lines 3
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:37
----------------------------------------------------------------------------------------------------
1      *"* dummy include to reduce generation dependencies between
2      *"* class CL_ALV_GRID_VIEW_FRONTEND_DATA and it's users.
3      *"* touched if any type reference has been changed
*--- End of CL_ALV_GRID_VIEW_FRONTEND_DATACT - 3 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  CX_SALV_API_CONTRACT_VIOLATIONCU          Level 1    Page 19
Object           ZEYTDS_INV_EXTRACT                        Lines 57
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:37
----------------------------------------------------------------------------------------------------
1      class CX_SALV_API_CONTRACT_VIOLATION definition
2        public
3        inheriting from CX_SALV_API_DYNAMIC
4        create public .
5
6      public section.
7
8        constants:
9          begin of CX_SALV_API_CONTRACT_VIOLATION,
10           msgid type symsgid value 'SALV_X_API',
11           msgno type symsgno value '021',
12           attr1 type scx_attrname value '',
13           attr2 type scx_attrname value '',
14           attr3 type scx_attrname value '',
15           attr4 type scx_attrname value '',
16         end of CX_SALV_API_CONTRACT_VIOLATION .
17       constants:
18         begin of SRC_DATA_CHANGED_W_O_NOTICE,
19           msgid type symsgid value 'SALV_X_API',
20           msgno type symsgno value '025',
21           attr1 type scx_attrname value '',
22           attr2 type scx_attrname value '',
23           attr3 type scx_attrname value '',
24           attr4 type scx_attrname value '',
25         end of SRC_DATA_CHANGED_W_O_NOTICE .
26       constants:
27         begin of SRC_REF_NOT_BOUND,
28           msgid type symsgid value 'SALV_X_API',
29           msgno type symsgno value '087',
30           attr1 type scx_attrname value '',
31           attr2 type scx_attrname value '',
32           attr3 type scx_attrname value '',
33           attr4 type scx_attrname value '',
34         end of SRC_REF_NOT_BOUND .
35       constants:
36         begin of CALL_CURRENTLY_NOT_ALLOWED,
37           msgid type symsgid value 'SALV_X_API',
38           msgno type symsgno value '094',
39           attr1 type scx_attrname value '',
40           attr2 type scx_attrname value '',
41           attr3 type scx_attrname value '',
42           attr4 type scx_attrname value '',
43         end of CALL_CURRENTLY_NOT_ALLOWED .
44       constants:
45         begin of FUNCTIONALITY_NOT_SUPPORTED,
46           msgid type symsgid value 'SALV_X_API',
47           msgno type symsgno value '130',
48           attr1 type scx_attrname value '',
49           attr2 type scx_attrname value '',
50           attr3 type scx_attrname value '',
51           attr4 type scx_attrname value '',
52         end of FUNCTIONALITY_NOT_SUPPORTED .
53
54       methods CONSTRUCTOR
55         importing
56           !TEXTID like IF_T100_MESSAGE=>T100KEY optional
57           !PREVIOUS like PREVIOUS optional .
*--- End of CX_SALV_API_CONTRACT_VIOLATIONCU - 57 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  CX_SALV_INDEX_TABLE_NOT_SORTEDCT          Level 1    Page 20
Object           ZEYTDS_INV_EXTRACT                        Lines 3
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:37
----------------------------------------------------------------------------------------------------
1      *"* dummy include to reduce generation dependencies between
2      *"* class CX_SALV_INDEX_TABLE_NOT_SORTED and it's users.
3      *"* touched if any type reference has been changed
*--- End of CX_SALV_INDEX_TABLE_NOT_SORTEDCT - 3 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  DB__SSEL                                  Level 1    Page 21
Object           ZEYTDS_INV_EXTRACT                        Lines 1
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:37
----------------------------------------------------------------------------------------------------
1      * INCLUDE DB__SSEL
*--- End of DB__SSEL - 1 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  IF_SALV_GRID_FRONTEND_ANALYSERIT          Level 1    Page 22
Object           ZEYTDS_INV_EXTRACT                        Lines 3
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:37
----------------------------------------------------------------------------------------------------
1      *"* dummy include to reduce generation dependencies between
2      *"* class IF_SALV_GRID_FRONTEND_ANALYSER and it's users.
3      *"* touched if any type reference has been changed
*--- End of IF_SALV_GRID_FRONTEND_ANALYSERIT - 3 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  IF_SALV_GUI_GRID_FWK_CHANGELOGIT          Level 1    Page 23
Object           ZEYTDS_INV_EXTRACT                        Lines 3
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:37
----------------------------------------------------------------------------------------------------
1      *"* dummy include to reduce generation dependencies between
2      *"* class IF_SALV_GUI_GRID_FWK_CHANGELOG and it's users.
3      *"* touched if any type reference has been changed
*--- End of IF_SALV_GUI_GRID_FWK_CHANGELOGIT - 3 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  IF_SALV_GUI_OM_EXTEND_GRID_APIIT          Level 1    Page 24
Object           ZEYTDS_INV_EXTRACT                        Lines 3
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:37
----------------------------------------------------------------------------------------------------
1      *"* dummy include to reduce generation dependencies between
2      *"* class IF_SALV_GUI_OM_EXTEND_GRID_API and it's users.
3      *"* touched if any type reference has been changed
*--- End of IF_SALV_GUI_OM_EXTEND_GRID_APIIT - 3 lines ---
