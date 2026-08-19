----------------------------------------------------------------------------------------------------
Main program     ZBILL_PROCESS                             Level 0    Page 1
Object           ZBILL_PROCESS                             Lines 150
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:32
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *& Report  ZBILL_PROCESS
3      *&
4      *&---------------------------------------------------------------------*
5      *&
6      *&
7      *&---------------------------------------------------------------------*
8      ** Change History
9      * Date       TP_Req     ID       Desc
10     * 06.08.2014 RD1K994186 CAB_ALOK Biller Direct:issues in upload, Process - CR 30011487
11     *                                - DUE_DATE not being uploaded properly when XLS upload is used
12     * 05.11.2014 RD1K995140 CAB_ALOK Changes in biller direct ZFIBD_PROCE - CR 30011847
13     *                                - Processing error for bill type 3 (landline residential)-
14     *                                 Cost center determination logic was missing for bill type 3.
15     *
16     REPORT zbill_process.
17     * Selection Screen
18     INCLUDE zbill_process_top.
19     INCLUDE zbill_process_s01.
20     INCLUDE zbill_process_f01. " Include for Upload Process by Vikas
21
22     INCLUDE zbill_post_f01.     " SAB_MURTHY for Posting the selected records in the alv
23
24     INITIALIZATION.
25
26     IF sy-tcode = 'ZFIBD_REPORT'.
27       MOVE 'Print Letter' TO sscrfields-functxt_01.
28       MOVE 'Print Autorization letter' TO sscrfields-functxt_02.
29     *  MOVE 'Test' TO sscrfields-functxt_03.
30     ENDIF.
31
32
33     *----------------------------------------------------------------------*
34     * A T - S E L E C T I O N - S C R E E N   O U T P U T
35     *----------------------------------------------------------------------*
36     AT SELECTION-SCREEN OUTPUT.
37
38
39       IF sy-tcode = 'ZFIBD_POST' OR sy-tcode = 'ZFIBD_REPORT'.
40
41         LOOP AT SCREEN.
42           IF screen-name = 'RB_UPLD' OR screen-group1 = 'U' OR screen-group1 = 'B'.
43
44             screen-active = 0.
45             screen-invisible = 1.
46             MODIFY SCREEN.
47           ENDIF.
48
49
50         ENDLOOP.
51
52       ENDIF.
53
54     * Start - RD1K991454
55       IF sy-tcode <> 'ZFIBD_REPORT'.
56         LOOP AT SCREEN.
57           IF screen-group1 = 'R'.
58             screen-active = 0.
59             screen-invisible = 1.
60             MODIFY SCREEN.
61           ENDIF.
62         ENDLOOP.
63       ENDIF.
64     * End - RD1K991454
65
66
67       IF rb_proc IS NOT INITIAL.
68         LOOP AT SCREEN.
69           IF screen-group1 = 'P'.
70             screen-active = 1.
71             screen-invisible = 0.
72             MODIFY SCREEN.
73           ENDIF.
74         ENDLOOP.
75       ELSE.
76         LOOP AT SCREEN.
77           IF screen-group1 = 'P'.
78             screen-active = 0.
79             screen-invisible = 1.
80             MODIFY SCREEN.
81           ENDIF.
82         ENDLOOP.
83       ENDIF.
84
85       IF rb_upld IS NOT INITIAL.
86         LOOP AT SCREEN.
87           IF screen-group1 = 'U'.
88             screen-active = 1.
89             screen-invisible = 0.
90             MODIFY SCREEN.
91           ENDIF.
92         ENDLOOP.
93       ELSE.
94         LOOP AT SCREEN.
95           IF screen-group1 = 'U'.
96             screen-active = 0.
97             screen-invisible = 1.
98             MODIFY SCREEN.
99           ENDIF.
100        ENDLOOP.
101
102      ENDIF.
103
104    AT SELECTION-SCREEN .
105
106    *AT SELECTION-SCREEN ON BLOCK b2.
107      IF sy-ucomm = 'ONLI'.
108
109
110        IF rb_upld IS NOT INITIAL.
111          IF ser_pro IS INITIAL OR
112            p_filtyp IS INITIAL OR
113            p_bukrs IS INITIAL OR
114            p_btype IS INITIAL.
115
116            MESSAGE 'Please enter all the selecion fields'(010) TYPE 'E'.
117            LEAVE TO SCREEN 0.
118          ENDIF.
119        ENDIF.
120
121    * Start - RD1K991454
122        IF rb_proc IS NOT INITIAL.
123          IF sy-tcode = 'ZFIBD_REPORT'.
124            IF bukrs IS INITIAL OR
125               bil_type IS INITIAL.
126              MESSAGE 'Please enter mandatory fields Company Code and Bill type'(017) TYPE 'E'.
127            ENDIF.
128          ELSE.
129            IF bukrs IS INITIAL OR
130               bil_type IS INITIAL OR
131               reqt_num IS INITIAL.
132              MESSAGE 'Please enter mandatory fields Company Code,Req. Number and Bill type'(017) TYPE 'E'.
133            ENDIF.
134          ENDIF.
135        ENDIF.
136    * End - RD1K991454
137      ELSEIF SY-UCOMM = 'FC01'.
138        SUBMIT ZBD_PRINT_AUTH_LETTER AND RETURN.
139      ENDIF.
140
141    START-OF-SELECTION.
142      PERFORM sub_get_action.
143    *  For Processing
144      IF rb_proc IS NOT INITIAL.
145
146        PERFORM display_records.
147        CALL SCREEN 900.
148      ELSEIF rb_upld IS NOT INITIAL.
149        PERFORM sub_upload_file.
150      ENDIF.
*--- End of ZBILL_PROCESS - 150 lines ---

----------------------------------------------------------------------------------------------------
Include          ZBILL_PROCESS_TOP                         Level 1    Page 2
Object           ZBILL_PROCESS                             Lines 498
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:32
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&  Include           ZBILL_PROCESS_TOP
3      *&---------------------------------------------------------------------*
4      TABLES : ZBILL_MAST,ZBILL_HEAD,ZBILL_DATA, ZBILL_GL, pa0001,sscrfields.
5      TYPE-POOLS : SLIS,ABAP,ICON.
6
7            TYPES : BEGIN OF ty_wbs_prc,
8                     PSPNR TYPE PS_POSNR,
9                     PGSBR TYPE PS_PGSBR,
10                    PRCTR TYPE PRCTR,
11                   END OF ty_wbs_prc.
12
13           TYPES : BEGIN OF ty_ord_prc,
14                    AUFNR TYPE AUFNR,
15                    GSBER TYPE GSBER,
16                    PRCTR TYPE PRCTR,
17                   END OF ty_ord_prc.
18            TYPES : ty_t_wbs_prc TYPE STANDARD TABLE OF ty_wbs_prc,
19                    ty_t_ord_prc TYPE STANDARD TABLE OF ty_ord_prc,
20                    ty_t_csks    TYPE STANDARD TABLE OF csks.
21     *---------------------------------------------------------------------*
22     *       CLASS lcl_alv_toolbar DEFINITION
23     *---------------------------------------------------------------------*
24     *       ALV event handler
25     *---------------------------------------------------------------------*
26     CLASS LCL_ALV_TOOLBAR DEFINITION.
27       PUBLIC SECTION.
28     * Constructor
29         METHODS: CONSTRUCTOR
30                    IMPORTING
31                      IO_ALV_GRID TYPE REF TO CL_GUI_ALV_GRID,
32     * Event for toolbar
33         ON_TOOLBAR
34            FOR EVENT TOOLBAR
35            OF  CL_GUI_ALV_GRID
36            IMPORTING
37              E_OBJECT E_INTERACTIVE,
38
39         HANDLE_USER_COMMAND
40             FOR EVENT USER_COMMAND OF CL_GUI_ALV_GRID
41                 IMPORTING E_UCOMM,
42
43                   HANDLE_HOTSPOT_CLICK FOR EVENT HOTSPOT_CLICK OF CL_GUI_ALV_GRID
44                   IMPORTING E_ROW_ID E_COLUMN_ID ES_ROW_NO.
45
46
47
48
49     ENDCLASS.                    "lcl_alv_toolbar DEFINITION
50
51     TYPES : BEGIN OF TY_ITEMS,
52               CHECK              TYPE CHAR01,             " Check Box
53               CHECK1             TYPE CHAR01,             " Check Box
54               BUKRS              TYPE BUKRS,              " Company Code
55               STATUS             TYPE ZBILL_STATUS,       " Bill line item Status
56               REQT_NUM           TYPE ZBILL_REQ_NM,       " Request Number
57               REQT_ID            TYPE ZBILL_REQ_ID,       " Request Line ID
58               ENAME              TYPE EMNAM,              " Formatted Name of Employee or Applicant
59               ZPHONE             TYPE ZBILL_COMM,"ZHRPHONE,           " Communication ID/Number
60               CONN_NUMB          TYPE ZBILL_CONN_NUMBER,  " Account Number
61               BILL_FROM          TYPE ZTELBILFROM,        " Bill From Date
62               BILL_TO            TYPE ZTELBILTO,          " Bill To Date
63               BILL_NUM           TYPE ZBILL_NUMBER,       " Bill Number
64               BILL_DATE          TYPE ZBILL_DATE,         " Bill Date
65               DUE_DATE           TYPE ZBILL_DUEDT,
66     ************************  + by Bipin on 20/11/2013 for electricity bill
67               OPRED              TYPE  ZBILL_OPEN_READING,
68               CLRED              TYPE  ZBILL_CLOSE_READING,
69               NERED	             TYPE ZBILL_NET_READING,
70     ************************  + by Bipin on 20/11/2013 for electricity bill
71               RENT               TYPE ZBILL_RENT,         " Rent
72               RENT_FINAL         TYPE ZBILL_RENT,         " Final Rent
73               CALL_CHARGE        TYPE ZBILL_CALL_CHARGES, " Call Charges
74               CALL_CHARGES_FINAL TYPE ZBILL_CALL_CHARGES, " Final Call Charges
75               OTH_CHARGES        TYPE ZBILL_OTH_CHARGES,  " Other Charges
76               OTH_CHARGES_FIN    TYPE ZBILL_OTH_CHARGES,  " Final Other Charges
77               SERVICE_TAX        TYPE J_1ISER,            " Service Tax
78               SERVICE_TAX_FIN    TYPE J_1ISER,            " Final Service Tax
79     *          GRS_TOTAL          TYPE ZGRS_TOTAL,         " Gross Total " RD1K991454
80               SECURITY_DEP       TYPE ZBILL_SECURITY_DEP,
81               SECURITY_DEP_FIN   TYPE ZBILL_SECURITY_DEP_APPR,
82               INTEREST           TYPE ZBILL_INTEREST,
83               INTEREST_FIN       TYPE ZBILL_INTEREST_APPR,
84               MISCL              TYPE ZBILL_MISCL,
85               MISCL_FIN          TYPE ZBILL_MISCL_APPR,
86               APPROVED_BY        TYPE ICL_RESERVEAB,      " Approved By
87               APPROVE_BY         TYPE AD_NAMTEXT,         " Full Name of Person
88               ACCOUNT_DOC_NO     TYPE BELNR_D,            " Accounting Document Number
89               POSTED_BY          TYPE ZBILL_POSTED_BY,    " Posted by
90               POST_BY            TYPE AD_NAMTEXT,         " Full Name of Person
91               REMARKS            TYPE ZBILL_REMARKS,      " Remarks
92               RAMT               TYPE ZBILL_RAMT,         " Recovery Amount
93               FYEAR              TYPE ZBILL_FYEAR,        " fiscal year " Added by Bipin on 18th Oct 2013
94     *          KST01              TYPE KOSTL,              " Cost Center " Added by Bipin on 18th Oct 2013
95               KST01              TYPE CHAR50,              " Cost Object " RD1K991454
96               BILL_TYPE          TYPE ZBILL_TYPE,         " Bill Type " Added by Bipin on 18th Oct 2013
97               CREATE_DATE        TYPE ZBILL_CREAT_DAT,    " Bill Creation Date " Added by Bipin on 18th Oct 2013
98               COMP_CODE          TYPE BUKRS,              " Company Code " Added by Bipin on 18th Oct 2013
99               PERNR              TYPE PERSNO,             " Personnel number  " Added by Bipin on 18th Oct 2013
100              NAME               TYPE PAD_NACHN,          " Employee Name  " Added by Bipin on 18th Oct 2013
101              SUBTY              TYPE SUBTY,              " Subtype  " Added by Bipin on 18th Oct 2013
102              ZAMT               TYPE ZTEL_AMT,           " Telephone Reimb Admissible Amount  " Added by Bipin on 18th Oct 2013
103              SEC_REMARKS        TYPE ZBILL_REMARKS,      " Remarks 2  " Added by Bipin on 18th Oct 2013
104              BUAR               TYPE GSBER,              " Business area  " Added by Bipin on 18th Oct 2013
105              STS_FLAG           TYPE ZSTS_FLAG,
106            END OF TY_ITEMS.
107
108    TYPES : BEGIN OF ty_emp_org,
109             pernr TYPE pernr_d,
110             WERKS TYPE PERSA,
111             persk TYPE persk,
112            END OF ty_emp_org.
113
114    *  Internal Table and Work Area Declarations
115    DATA : WA_ITEMS TYPE TY_ITEMS,
116           IT_ITEMS TYPE STANDARD TABLE OF TY_ITEMS,
117           IT_ITEMS_PHN TYPE STANDARD TABLE OF TY_ITEMS,
118           IT_ITEMS_PHN_MBL TYPE STANDARD TABLE OF TY_ITEMS,
119           WA_ITEMS_PHN_MBL TYPE  TY_ITEMS,
120           IT_ITEMS_PHN_LAN TYPE STANDARD TABLE OF TY_ITEMS,
121           IT_HEAD TYPE TABLE OF ZBILL_HEAD,
122           WA_HEAD TYPE          ZBILL_HEAD,
123           IT_MAST TYPE TABLE OF ZBILL_MAST,
124           WA_MAST TYPE          ZBILL_MAST,
125           IT_PA9205 TYPE TABLE OF PA9205,
126           WA_PA9205 TYPE        PA9205,
127           WA_PA9205_l TYPE        PA9205,
128           IT_PA9351 TYPE TABLE OF PA9351, " Added by bipin to pick cost center on 26/12/2013
129           WA_PA9351 TYPE        PA9351,
130
131           gt_pa0027 TYPE STANDARD TABLE OF pa0027,
132           gs_pa0027 TYPE pa0027,
133
134           IT_PA0002 TYPE TABLE OF PA0002,
135           IT_PA0001 TYPE TABLE OF PA0001,
136           WA_PA0001 TYPE PA0001,
137           LV_COMM   TYPE STRING,
138           LC_NULL   TYPE I VALUE '10' ,
139           LV_NULL(4)   TYPE X VALUE 'A0',
140
141           LV_NULLC(10)   TYPE C,
142
143           LV_NULL_MBL(4)   TYPE X VALUE 'A0',
144
145           LV_NULLC_MBL(10)   TYPE C,
146
147
148           WA_PA0002 TYPE         PA0002.
149    FIELD-SYMBOLS : <GFS_NULL> TYPE C.
150    FIELD-SYMBOLS : <GFS_NULL_MBL> TYPE C.
151    DATA : F1 TYPE ZHRPHONE,
152            F2 TYPE ZBILL_NUMBER,
153              F3 TYPE  ZBILL_DATE.
154    *  Declarations for Processing ALV
155    DATA : WA_FIELDCAT   TYPE LVC_S_FCAT,
156           IT_FIELDCAT   TYPE LVC_T_FCAT,
157           WA_LAYOUT     TYPE LVC_S_LAYO,
158           WA_EXCLUDE    TYPE UI_FUNC,
159           IT_EXCLUDE    TYPE UI_FUNCTIONS,
160           WA_ZBILL_DATA TYPE ZBILL_DATA,
161           IT_ZBILL_DATA TYPE STANDARD TABLE OF ZBILL_DATA,
162           WA_SELECTED   TYPE LVC_S_ROW,
163           IT_SELECTED   TYPE LVC_T_ROW,
164           IT_TOOLBAR    TYPE TTB_BUTTON,
165           WA_TOOLBAR TYPE STB_BUTTON.
166    *        g_toolbar     TYPE REF TO cl_gui_toolbar.
167
168    *  Container Declarations
169    DATA : R_CONTAINER TYPE REF TO CL_GUI_DOCKING_CONTAINER,
170           R_GRID TYPE REF TO CL_GUI_ALV_GRID,
171           C_ALV_TOOLBAR    TYPE REF TO LCL_ALV_TOOLBAR,           "Alv toolbar
172           C_ALV_TOOLBARMANAGER TYPE REF TO CL_ALV_GRID_TOOLBAR_MANAGER.  "Toolbar manager
173
174    DATA : gv_variant TYPE disvariant.
175
176    *  Global Data Declarations
177    DATA : OK_CODE TYPE SY-UCOMM,
178           GV_POSTED TYPE C VALUE SPACE,
179           GV_REQT_NUM TYPE ZBILL_REQ_NM.
180
181    DATA: GV_FILE_PATH TYPE CHAR255,
182          GV_FILE_NAME TYPE CHAR255.
183
184    DATA : LV_URNAME TYPE PAD_NACHN. " For employee name based on PERNR " added by Bipin 19th oct 2013
185
186
187    TYPES: BEGIN OF TY_ITEM1.
188            INCLUDE STRUCTURE ZBILL_STYLE_ST.
189    TYPES: STYLE TYPE LVC_T_STYL,
190           ERROR_FLAG TYPE FLAG,
191           ROWCOLOR(4) TYPE C,
192           KST011 TYPE CHAR10,
193           ROW_NUM TYPE I,
194    *       T_MSG  TYPE BAPIRET2TAB,"CRMT_BSP_STRING_TAB.
195           T_MSG  TYPE BAPIRET2_T,"CRMT_BSP_STRING_TAB.
196           GV_TOTAL_AMT TYPE ZBILL_CALL_CHARGES,
197           GV_VENDOR_AMT TYPE ZBILL_CALL_CHARGES,
198           STS_FLAG           TYPE ZSTS_FLAG,
199           GV_LO_VAR TYPE STRING.
200
201    TYPES: END OF TY_ITEM1.
202
203    TYPES: BEGIN OF GTY_MSG,
204        STATUS TYPE CHAR4,
205        MSG    TYPE C LENGTH 255,
206        END OF GTY_MSG.
207
208    *    DATA : RT_MSG TYPE     WA_ITEM2-T_MSG.
209
210    DATA : IT_ITEM1 TYPE TABLE OF TY_ITEM1,
211           WA_ITEM1 TYPE          TY_ITEM1.
212
213    DATA : IT_ITEM2 TYPE TABLE OF TY_ITEM1,
214           WA_ITEM2 TYPE          TY_ITEM1,
215           WA_ITEMS2 TYPE          TY_ITEM1,
216           IT_CHANGED TYPE TABLE OF TY_ITEM1,
217           WA_CHANGED TYPE          TY_ITEM1,
218           IT_CHANGED_NEW TYPE TABLE OF TY_ITEM1,
219           WA_CHANGED_NEW TYPE          TY_ITEM1.
220    DATA : IT_ITEM3 TYPE TABLE OF TY_ITEM1,
221           WA_ITEM3 TYPE          TY_ITEM1.
222
223    DATA : IT_ITEM_L2 TYPE TABLE OF TY_ITEM1,
224           WA_ITEM_L2 TYPE          TY_ITEM1.
225
226    DATA : LV_CHECK TYPE I.
227
228
229    DATA:  LS_STYLE TYPE LINE OF LVC_T_STYL.
230
231    DATA : GT_CSKS TYPE TABLE OF CSKS,
232           WA_CSKS TYPE          CSKS.
233
234    DATA : IT_STATUS TYPE TABLE OF ZBILL_T_STATUS,
235           WA_STATUS TYPE          ZBILL_T_STATUS,
236           IT_CHECK TYPE TABLE OF  ZBILL_FIELD_MAP,
237           WA_CHECK TYPE          ZBILL_FIELD_MAP.
238
239    TYPES : BEGIN OF TY_CHECK1,
240           INT_FIELD  TYPE ZBILL_INT_FIELD,
241            END OF TY_CHECK1.
242    DATA : IT_CHECK1 TYPE TABLE OF TY_CHECK1,
243           WA_CHECK1 TYPE TY_CHECK1.
244
245    DATA : S_STAT TYPE TABLE OF SELOPTTAB,
246           WA_STAT  TYPE SELOPTTAB.
247
248    DATA : S_STAT1 TYPE TABLE OF SELOPTTAB,
249           WA_STAT1  TYPE SELOPTTAB,
250           WA_ITEMS_PHN TYPE TY_ITEMS.
251
252    DATA : S_STAT2 TYPE TABLE OF SELOPTTAB,
253           WA_STAT2  TYPE SELOPTTAB.
254
255    DATA: OTAB  TYPE ABAP_SORTORDER_TAB,
256          OLINE TYPE ABAP_SORTORDER,
257          DREF  TYPE REF TO DATA.
258
259    FIELD-SYMBOLS: <COLUMN> TYPE SELOPTTAB ,
260                   <ITAB> TYPE ANY,
261                   <FS_WA1> TYPE ANY,
262                   <FS_WA2> TYPE ANY.
263
264
265    DATA : LV_FIELD TYPE STRING,
266           LV_COUNT TYPE I.
267
268
269    TYPES : BEGIN OF TY_BILL_GL,
270    *BILL_TYPE  type ZBILL_TYPE,
271    *EXPENCE  type ZEXPENCE,
272      COSTCENTER TYPE KOSTL,
273    HKONT	 TYPE HKONT,
274      AMOUNT TYPE ZBILL_RENT,
275          END OF TY_BILL_GL.
276
277    DATA : IT_ZBILL_GL TYPE TABLE OF TY_BILL_GL,
278           WA_ZBILL_GL TYPE TY_BILL_GL.
279
280    TYPES : BEGIN OF ty_gl,
281            BUKRS     TYPE BUKRS,
282            HKONT	    TYPE HKONT,
283            KOSTL     TYPE KOSTL,
284            AUFNR     TYPE AUFNR,
285            WBS       TYPE PS_PSP_PNR,
286            EXPENCE   TYPE ZEXPENCE,
287            CONN_NUMB TYPE ZBILL_CONN_NUMBER,
288            BILL_NUM  TYPE ZBILL_NUMBER,
289            AMOUNT    TYPE ZBILL_RENT,
290            END OF ty_gl.
291    TYPES : ty_t_gl TYPE STANDARD TABLE OF ty_gl.
292
293    DATA : GT_GL    TYPE STANDARD TABLE OF ty_gl,
294           GT_GLAMT TYPE STANDARD TABLE OF ty_gl,
295           GS_GL TYPE TY_GL.
296
297    DATA: W_SETID LIKE SETHIER-SETID,
298           INT_VLAUES TYPE STANDARD TABLE OF RGSBV,
299           WA_VLAUES TYPE  RGSBV.
300
301    *----------------------------------------------------------------------*
302    *       CLASS LCL_EVENT_HANDLER DEFINITION
303    *----------------------------------------------------------------------*
304    *
305    *----------------------------------------------------------------------*
306    CLASS LCL_EVENT_HANDLER DEFINITION.
307      PUBLIC SECTION.
308        METHODS : HANDLE_DATA_CHANGED
309                 FOR EVENT DATA_CHANGED OF CL_GUI_ALV_GRID
310                 IMPORTING ER_DATA_CHANGED.
311    ENDCLASS.                    "LCL_EVENT_HANDLER DEFINITION
312
313    *----------------------------------------------------------------------*
314    *       CLASS LCL_EVENT_HANDLER IMPLEMENTATION
315    *----------------------------------------------------------------------*
316    *
317    *----------------------------------------------------------------------*
318    CLASS LCL_EVENT_HANDLER IMPLEMENTATION.
319      METHOD : HANDLE_DATA_CHANGED .
320        PERFORM HANDLE_CHECKBOX
321        USING ER_DATA_CHANGED.
322
323      ENDMETHOD.                    ":
324
325    ENDCLASS.                    "LCL_EVENT_HANDLER IMPLEMENTATION
326
327
328    DATA : LV_H TYPE REF TO LCL_EVENT_HANDLER.
329    DATA: GT_DYN_TAB TYPE REF TO DATA,
330          GT_FIELD_MAP TYPE TABLE OF ZBILL_FIELD_MAP,
331          GV_FIELDS_NO TYPE I,
332          GV_STD_CODE TYPE ZBILL_STD_CODE.
333
334
335    * FOR GL ACCOUNT DETERMINATION
336
337    DATA : GT_BILL_GL TYPE TABLE OF ZBILL_GL,
338           WA_BILL_GL TYPE          ZBILL_GL.
339
340    *   FOR PAYMENT TERMS AND METHODS FROM LFB1
341
342    DATA : GT_LFB1 TYPE TABLE OF LFB1,
343           WA_LFB1 TYPE          LFB1.
344
345
346    DATA: LT_FIELDS_DATA TYPE TABLE OF DFIES,
347          LX_FIELDS_DATA TYPE DFIES.
348
349
350    DATA : SEC_CODE TYPE SECCO,
351           POST_DT TYPE MKPF-BUDAT,
352           DUE_DATE TYPE SY-DATUM,
353           TXT TYPE C LENGTH 50,
354           ER_KBLNR TYPE KBLNR_FI,
355           ER_KBLPOS TYPE KBLPOS,
356           gv_kidno TYPE kidno.
357
358    DATA : ANSWER TYPE I.
359
360    DATA:GT_FCAT TYPE LVC_T_FCAT.
361
362    DATA : IT_SKA1 TYPE TABLE OF SKA1,
363           WA_SKA1 TYPE SKA1.
364
365    DATA WA_T001 TYPE T001.
366
367    DATA : GT_BA_MAP TYPE TABLE OF ZBILL_BA_MAP,
368           WA_BA_MAP TYPE          ZBILL_BA_MAP.
369
370    ***** FOR TEXT EDITOR
371    DATA : OKCODE_901 TYPE SY-UCOMM.
372    DATA : OKCODE_902 TYPE SY-UCOMM.
373    DATA : GO_CC_NAME TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
374           GO_TXT_EDIT  TYPE REF TO CL_GUI_TEXTEDIT.
375
376    * document simulation
377
378    DATA  : SIMU_CCODE TYPE BUKRS,
379            SIMU_DATE TYPE BLDAT,
380            SIMU_REF_NUM TYPE XBLNR1,
381            SIMU_PDATE TYPE BUDAT,
382            SIMU_CUR TYPE WAERS,
383            SIMU_FYEAR TYPE GJAHR.
384
385    ************** FOR FIRST CONTAINER
386    DATA GR_ALVGRID TYPE REF TO CL_GUI_ALV_GRID . " 902 screen ACCOUNTING alv
387    DATA GC_CUSTOM_CONTROL_NAME TYPE SCRFNAME VALUE 'CC_ACC'.
388    DATA GR_CCONTAINER TYPE REF TO CL_GUI_CUSTOM_CONTAINER .
389    DATA GT_FIELDCAT TYPE LVC_T_FCAT WITH HEADER LINE .
390
391    **************** for second container
392    DATA GR_ALVGRID1 TYPE REF TO CL_GUI_ALV_GRID . " 902 screen ACCOUNTING alv
393    DATA GC_CUSTOM_CONTROL_NAME1 TYPE SCRFNAME VALUE 'CC_PAY'.
394    DATA GR_CCONTAINER1 TYPE REF TO CL_GUI_CUSTOM_CONTAINER .
395
396    *************** for bapi return value
397
398    DATA GR_ALVGRID2 TYPE REF TO CL_GUI_ALV_GRID . " 902 screen ACCOUNTING alv
399    DATA GC_CUSTOM_CONTROL_NAME2 TYPE SCRFNAME VALUE 'CC_ERROR'.
400    DATA GR_CCONTAINER2 TYPE REF TO CL_GUI_CUSTOM_CONTAINER .
401    DATA: GT_FIELDCAT2 TYPE LVC_T_FCAT WITH HEADER LINE .
402    DATA : GS_LAY_OUT TYPE LVC_S_LAYO.
403    *************** for bapi return value
404
405    DATA: GT_FIELDCAT1 TYPE LVC_T_FCAT WITH HEADER LINE ,
406          GO_MSG_ALV TYPE REF TO CL_GUI_ALV_GRID,
407          GO_MSG_CNT TYPE REF TO CL_GUI_CUSTOM_CONTAINER,
408          GT_MSG_FCAT TYPE LVC_T_FCAT,
409          GT_MSG TYPE TABLE OF GTY_MSG.
410
411    DATA : T_TCODE TYPE TT_FCODES.
412    DATA:  DOCDATA TYPE SODOCCHGI1,
413           LV_DATE        TYPE CHAR10,
414           LV_TIME        TYPE CHAR8,
415           GT_OBJHEAD TYPE TABLE OF SOLISTI1,
416           GT_RECLIST TYPE TABLE OF SOMLRECI1,
417           WA_RECLIST TYPE SOMLRECI1,
418           WA_OBJHEAD TYPE SOLISTI1,
419           LV_TAB_LINES TYPE SY-TABIX,
420           GT_OBJPACK   TYPE TABLE OF SOPCKLSTI1,
421           WA_OBJPACK   TYPE SOPCKLSTI1.
422
423
424
425    DATA : GT_UNAME TYPE TABLE OF ZBILL_AUTH,
426           WA_UNAME TYPE ZBILL_AUTH.
427
428
429    DATA : LV_BTYPE TYPE DD07T-DDTEXT.
430
431    DATA : S_STAT4 TYPE TABLE OF SELOPTTAB,
432           WA_STAT4  TYPE SELOPTTAB.
433
434    DATA : ALL_REQ TYPE STRING.
435
436
437    DATA : LV_APPSVR TYPE RZLLITAB-CLASSNAME VALUE ' '. "'parallel_generators'.
438
439    DATA : LV_PP_TOTAL     TYPE I,                                                   " Total no of dialog work process available in the group server
440         LV_AVAILABLE TYPE I,                                                   " No of dialog work process that are free.
441         LV_OCCUPIED  TYPE I,                                                   " No of occupied dialog process
442         LV_DIFF      TYPE I,                                                   " Percentage difference of available work process
443         LV_SPLIT     TYPE I.                                                   " No of partitions the main data is to be split
444
445    DATA : LV_LINES TYPE I,                                                       " No of records in the internal table
446           LV_LINES_TAB TYPE I,                                                   " No of lines per tab
447           LV_LINES_TAB1 TYPE I,                                                   " No of lines per tab
448           LV_LINES_TAB2 TYPE I,                                                   " No of lines per tab
449           LV_LINES_TAB3 TYPE I,                                                   " No of lines per tab
450           LV_LINES_TAB4 TYPE I,                                                   " No of lines per tab
451           LV_START TYPE I,                                                       " Start point for processing
452           LV_END TYPE I.                                                         " End point for processing
453
454    DATA : LV_TASK TYPE STRING,                                                   " Name of the task to be created
455           LV_INDEX TYPE STRING,                                                  " Variable for index
456           LV_SENT  TYPE I,                                                       " No of package sent
457           LV_COMP  TYPE I,                                                       " No of package completed
458           LV_RESULT TYPE FLAG.                                                   " Variable to collect the result.
459
460    DATA : LV_RESULT_STRING TYPE STRING.
461
462    DATA: FUNCTIONCALL1(1) TYPE C.
463    CONSTANTS: DONE(1) TYPE C VALUE 'X'.
464
465    DATA  : L_RETURN1 TYPE ZBILL_RETURN_TT.
466    DATA  : L_RETURN2 TYPE ZBILL_RETURN_TT.
467    DATA  : L_RETURN3 TYPE ZBILL_RETURN_TT.
468    DATA  : L_RETURN4 TYPE ZBILL_RETURN_TT.
469    DATA  : L_RETURN6 TYPE ZBILL_RETURN_TT.
470    DATA  : L_RETURN5 TYPE ZBILL_RETURN_TT,
471            W_RETURN5 TYPE ZBILL_RETURN_ST,
472            LV_TABIX TYPE SY-TABIX.
473    *DATA: GROUP LIKE RZLLITAB-CLASSNAME VALUE ' '.
474
475
476    DATA : IT_DOM TYPE TABLE OF DD07V,
477           WA_DOM TYPE DD07V,
478           LV_RET_TYPE TYPE C.
479
480
481
482    DATA : POST_DOC TYPE BELNR_D,
483           POST_COMP_CODE TYPE BUKRS,
484           POST_YEAR TYPE ZBILL_FYEAR.
485
486    DATA : POST_MSG TYPE STRING.
487
488    DATA : GT_SEL_COL TYPE LVC_T_COL,
489           WA_SEL_COL TYPE LVC_S_COL.
490
491    DATA : REJ_FLAG TYPE C.
492
493
494    DATA : REJ_TEXT TYPE UG_TXTLG .
495
496    DATA : Wa1_9205 TYPE PA9205 ,
497           It_mob_dir TYPE ZHR_MOBILE_DIR OCCURS 0,
498           Wa_mob_dir TYPE  ZHR_MOBILE_DIR .
*--- End of ZBILL_PROCESS_TOP - 498 lines ---

----------------------------------------------------------------------------------------------------
Include          ZBILL_PROCESS_S01                         Level 1    Page 3
Object           ZBILL_PROCESS                             Lines 45
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:32
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&  Include           ZBILL_PROCESS_S01
3      *&---------------------------------------------------------------------*
4
5      *----------------------------------------------------------------------*
6      *    S E L E C T I O N - S C R E E N
7      *----------------------------------------------------------------------*
8      SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-004.
9      SELECTION-SCREEN BEGIN OF LINE.
10     SELECTION-SCREEN POSITION 2.
11     PARAMETERS rb_proc RADIOBUTTON GROUP g1 USER-COMMAND space DEFAULT 'X'.
12     SELECTION-SCREEN COMMENT 5(10) text-003 .
13
14     *SELECTION-SCREEN POSITION 30.
15     *PARAMETERS RB_MANL RADIOBUTTON GROUP G1 .
16     *SELECTION-SCREEN COMMENT 33(10) TEXT-002.
17     SELECTION-SCREEN POSITION 30.
18     PARAMETERS rb_upld RADIOBUTTON GROUP g1 .
19     SELECTION-SCREEN COMMENT 33(10) text-001 MODIF ID b.
20
21     SELECTION-SCREEN END OF LINE.
22     SELECTION-SCREEN END OF BLOCK b1.
23
24     SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-005.
25     SELECTION-SCREEN FUNCTION KEY 1.
26     PARAMETERS : bukrs TYPE bukrs MODIF ID p. "OBLIGATORY.
27     SELECT-OPTIONS : ser_prov     FOR zbill_head-serv_prov    MODIF ID p,
28                      reqt_num     FOR zbill_data-reqt_num     MODIF ID p,
29                      crt_date     FOR zbill_head-create_date  MODIF ID p,
30                      s_billdt     FOR zbill_data-bill_date    MODIF ID r, "RD1K991454
31                      s_bilper     FOR zbill_data-bill_date    MODIF ID r NO-EXTENSION, "RD1K991454
32                      s_zphone     FOR zbill_data-zphone       MODIF ID r, "RD1K991454
33                      s_connno     FOR zbill_data-conn_numb    MODIF ID r, "RD1K991454
34                      s_werks      FOR pa0001-werks,
35                      status       FOR zbill_data-status       MODIF ID p.
36     *                 BIL_TYPE FOR ZBILL_HEAD-BILL_TYPE  MODIF ID P.
37     PARAMETERS :     bil_type TYPE zbill_type  MODIF ID p ."OBLIGATORY.
38
39     PARAMETERS: ser_pro  TYPE zbill_head-serv_prov MODIF ID u,
40                 p_filtyp TYPE zbill_field_map-file_type MODIF ID u,
41                 p_bukrs  TYPE bukrs MODIF ID u,
42                 p_btype  TYPE zbill_type MODIF ID u.
43
44
45     SELECTION-SCREEN END OF BLOCK b2.
*--- End of ZBILL_PROCESS_S01 - 45 lines ---

----------------------------------------------------------------------------------------------------
Include          ZBILL_PROCESS_F01                         Level 1    Page 4
Object           ZBILL_PROCESS                             Lines 1683
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:32
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&  Include           ZBILL_PROCESS_F01
3      *&---------------------------------------------------------------------*
4      *&---------------------------------------------------------------------*
5      *&      Form  SUB_GET_ACTION
6      *&---------------------------------------------------------------------*
7      *       text
8      *----------------------------------------------------------------------*
9      *  -->  p1        text
10     *  <--  p2        text
11     *----------------------------------------------------------------------*
12     FORM sub_get_action .
13       DATA: lv_filetype TYPE zbill_file_type,
14             lv_message TYPE string,
15             lt_file_name TYPE TABLE OF char255,
16             lv_fnum     TYPE i.
17       IF rb_upld IS NOT INITIAL.
18         CALL FUNCTION 'ALV_BDS_LVC_OS_DLOG'
19           EXPORTING
20             i_dlog_mode = 'O'
21     *       I_MASK      =
22     *       I_TITLE     =
23           CHANGING
24             c_loc_dir   = gv_file_path
25             c_loc_fname = gv_file_name
26           EXCEPTIONS
27             cancel      = 1
28             error       = 2
29             OTHERS      = 3.
30         IF sy-subrc EQ 0.
31           CALL FUNCTION 'TRINT_FILE_GET_EXTENSION'
32             EXPORTING
33               filename  = gv_file_name
34     *         UPPERCASE = 'X'
35             IMPORTING
36               extension = lv_filetype.
37           IF lv_filetype NE p_filtyp.
38             CONCATENATE 'Please upload'(008) p_filtyp 'file'(009) INTO lv_message SEPARATED BY space.
39             MESSAGE lv_message TYPE 'E'.
40     *        LEAVE TO SCREEN 1000.
41
42           ENDIF.
43         ELSEIF gv_file_path IS NOT INITIAL.
44           SPLIT gv_file_path AT '\' INTO TABLE lt_file_name.
45           DESCRIBE TABLE lt_file_name LINES lv_fnum.
46           READ TABLE lt_file_name INTO gv_file_name INDEX lv_fnum.
47           DELETE lt_file_name INDEX lv_fnum.
48           REPLACE FIRST OCCURRENCE OF gv_file_name IN gv_file_path WITH space.
49         ENDIF.
50
51       ENDIF.
52
53       SELECT SINGLE * INTO wa_t001
54         FROM t001
55         WHERE
56         bukrs = bukrs.
57
58
59     ENDFORM.                    " SUB_GET_ACTION
60     *&---------------------------------------------------------------------*
61     *&      Form  SUB_UPLOAD_FILE
62     *&---------------------------------------------------------------------*
63     *       text
64     *----------------------------------------------------------------------*
65     *  -->  p1        text
66     *  <--  p2        text
67     *----------------------------------------------------------------------*
68     FORM sub_upload_file .
69       DATA: lt_bill_data TYPE TABLE OF zbill_data,
70             lx_head_data TYPE zbill_head,
71             lx_fcat       TYPE lvc_s_fcat,
72             lv_req_num TYPE zbill_req_nm.
73     * Read Service provider config. data
74       PERFORM sub_read_servprov_dat.
75
76     * Read XLS and CSV files
77       IF p_filtyp = 'XLS'  OR p_filtyp = 'CSV' OR p_filtyp = 'XLSX'.
78         PERFORM sub_read_xl CHANGING lt_bill_data
79                                      lx_head_data
80                                      lv_req_num.
81     *    PERFORM sub_display_alv TABLES  lt_bill_data.
82         IF lv_req_num IS INITIAL.
83           lx_fcat-col_pos    = 1.
84           lx_fcat-coltext    = 'Status'.
85           lx_fcat-fieldname    = 'STATUS'.
86           lx_fcat-icon       = 'X'.
87           lx_fcat-outputlen  = '4'.
88           APPEND lx_fcat TO gt_msg_fcat.
89           CLEAR lx_fcat.
90
91           lx_fcat-col_pos    = 2.
92           lx_fcat-coltext    = 'Message'.
93           lx_fcat-fieldname    = 'MSG'.
94     *    lx_fcat-icon       = 'X'.
95           lx_fcat-outputlen  = '255'.
96           APPEND lx_fcat TO gt_msg_fcat.
97
98           CALL SCREEN 9001 STARTING AT 10 10 ENDING AT 120 30.
99
100        ELSE.
101          PERFORM sub_save_data   TABLES lt_bill_data
102                                  USING lx_head_data
103                                        lv_req_num.
104          PERFORM sub_save_file_app USING lv_req_num.
105        ENDIF.
106    *  ELSEIF p_filtyp = 'CSV'.
107    *    PERFORM sub_read_csv CHANGING lt_bill_data
108    *    lx_head_data.
109      ELSEIF p_filtyp = 'ZIP' OR p_filtyp = 'RAR' OR p_filtyp = 'XML'.
110        PERFORM sub_read_zip CHANGING  lt_bill_data
111                                     lx_head_data
112                                     lv_req_num.
113      ENDIF.
114
115    ENDFORM.                    " SUB_UPLOAD_FILE
116    *&---------------------------------------------------------------------*
117    *&      Form  SUB_READ_SERVPROV_DAT
118    *&---------------------------------------------------------------------*
119    *       text
120    *----------------------------------------------------------------------*
121    *  -->  p1        text
122    *  <--  p2        text
123    *----------------------------------------------------------------------*
124    FORM sub_read_servprov_dat .
125      DATA:
126
127            lt_fcat TYPE lvc_t_fcat,
128    * begin RD1K9A00QV  CAB_ALOK run time error CONVT_NO_NUMBER-CR 30014376
129    *        lv_index TYPE char2 VALUE '00',
130            lv_index TYPE char3 VALUE '000',
131    * end RD1K9A00QV  CAB_ALOK run time error CONVT_NO_NUMBER-CR 30014376
132
133            lx_fcat TYPE lvc_s_fcat,
134            lx_field_map TYPE zbill_field_map.
135
136      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
137        EXPORTING
138          input  = ser_pro
139        IMPORTING
140          output = ser_pro.
141
142      SELECT * FROM zbill_field_map
143        INTO TABLE gt_field_map
144        WHERE serv_provider = ser_pro ORDER BY PRIMARY KEY. "AND
145      "file_type = p_filtyp.
146
147      DESCRIBE TABLE gt_field_map LINES gv_fields_no.
148      DO gv_fields_no TIMES.
149        lv_index = lv_index + 1.
150        lx_fcat-col_pos = lv_index."sy-tabix.
151        CONCATENATE 'field' lv_index INTO lx_fcat-fieldname.
152        APPEND lx_fcat TO lt_fcat.
153        CLEAR lx_fcat.
154      ENDDO.
155      gt_fcat = lt_fcat.
156      CALL METHOD cl_alv_table_create=>create_dynamic_table
157        EXPORTING
158    *     i_style_table             =
159          it_fieldcatalog           = lt_fcat
160    *     i_length_in_byte          =
161        IMPORTING
162          ep_table                  = gt_dyn_tab
163    *     e_style_fname             =
164        EXCEPTIONS
165          generate_subpool_dir_full = 1
166          OTHERS                    = 2.
167      IF sy-subrc <> 0.
168    *   Implement suitable error handling here
169      ENDIF.
170    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
171      READ TABLE gt_field_map INTO lx_field_map INDEX 1. "#EC CI_NOORDER
172    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
173      IF sy-subrc EQ 0.
174        gv_std_code = lx_field_map-std_code.
175        CONDENSE gv_std_code.
176      ENDIF.
177    ENDFORM.                    " SUB_READ_SERVPROV_DAT
178    *&---------------------------------------------------------------------*
179    *&      Form  SUB_READ_XL
180    *&---------------------------------------------------------------------*
181    *       text
182    *----------------------------------------------------------------------*
183    *  -->  p1        text
184    *  <--  p2        text
185    *----------------------------------------------------------------------*
186    FORM sub_read_xl CHANGING ct_bill_data
187                              cx_head_data
188                              cv_req_num.
189      TYPES:BEGIN OF ty_field_stru,
190              ext_field TYPE string,
191              int_field TYPE string,
192              value_tab TYPE ztt_bill_values,
193            END OF ty_field_stru.
194
195
196      DATA: lv_file_path TYPE rlgrap-filename,
197            lv_file_path_xl TYPE string,
198            ld_new_line TYPE REF TO data,
199            lt_field_dat TYPE TABLE OF ty_field_stru,
200            lx_field_dat TYPE ty_field_stru,
201            lx_field_dat1 TYPE ty_field_stru,
202            lx_field_map TYPE zbill_field_map,
203            wa_field_map TYPE zbill_field_map,
204                    lv_msg1        TYPE char50,
205            lv_msg2        TYPE char50,
206            lv_msg3        TYPE char50,
207            lv_msg4        TYPE char50,
208    lt_return TYPE  TABLE OF  ebpp_messages,
209    lx_messages TYPE bal_s_msg,
210    lx_msg1 TYPE gty_msg,
211       lv_succ_msg  TYPE symsgv,
212      lx_return       TYPE fimsg,"ebpp_messages,
213      l_v_fieldname   TYPE dynfnam,
214      lv_data         TYPE string,
215      lv_cond         TYPE string,
216      lt_bill_dup     TYPE TABLE OF zbill_data,
217      lx_bill_del     TYPE zbill_data,
218      lx_bill_dup     TYPE zbill_data,
219      lx_fields_prim TYPE abap_sortorder,
220      lt_fields_prim TYPE TABLE OF abap_sortorder,
221      lt_fields_comp TYPE STANDARD TABLE OF string,
222      lv_int_field    TYPE string,
223      lv_count TYPE i VALUE 1,
224      lv_loop_count TYPE i ,
225      lv_field_number TYPE i VALUE 1,
226      lv_value_number TYPE i VALUE 1,
227      lt_bill_data TYPE TABLE OF zbill_data,
228      lt_msg          TYPE TABLE OF  fimsg,
229      lx_msg          TYPE fimsg,
230      lx_head_data TYPE zbill_head,
231      lx_bill_data TYPE zbill_data,
232      lv_value TYPE string,
233      lv_amount_val TYPE string,
234      lv_field_name TYPE string,
235      lv_req_num TYPE zbill_req_nm,
236      lv_amount     TYPE bapicurr_d,
237              lv_lastm_mnt   TYPE sy-datum,
238            lv_bill_frm    TYPE sy-datum,
239            lv_bill_to    TYPE sy-datum.
240
241      CONSTANTS: lc_head_status TYPE char1 VALUE '1',
242                 lc_currency TYPE tcurc-waers VALUE 'INR',
243                 lc_curr_dig TYPE i VALUE 20.
244
245      FIELD-SYMBOLS:<fs_dyn_tab> TYPE STANDARD TABLE,
246                    <fs_dyn_wa>,
247                    <fs_dyn_field>,
248                    <fs_name> TYPE string,
249                     <fs_field_name> TYPE any,
250    *                   <fs_field_name> TYPE any,
251      <fs_field_del> TYPE any.
252
253      DATA: lt_xcel TYPE TABLE OF alsmex_tabline,
254    *        lx_xcel TYPE alsmex_tabline,
255            lt_csv TYPE kcde_intern,
256            lx_csv TYPE kcde_intern_struc,
257            lx_xcel TYPE alsmex_tabline,
258            lv_phone_len TYPE i.
259
260      CONCATENATE gv_file_path gv_file_name INTO lv_file_path.
261      CONCATENATE gv_file_path gv_file_name INTO lv_file_path_xl.
262
263      ASSIGN gt_dyn_tab->* TO <fs_dyn_tab>.
264
265    * Create dynamic work area and assign to FS
266      CREATE DATA ld_new_line LIKE LINE OF <fs_dyn_tab>.
267
268      ASSIGN ld_new_line->* TO <fs_dyn_wa>.
269
270      IF p_filtyp = 'XLS' OR p_filtyp = 'XLSX'.
271
272
273        CALL FUNCTION 'ZALSM_EXCEL_TO_INTERNAL_TABLE'
274          EXPORTING
275            filename                = lv_file_path_xl
276            i_begin_col             = '1'
277            i_begin_row             = '1'
278            i_end_col               = '200'
279            i_end_row               = '5000'
280          TABLES
281            intern                  = lt_xcel
282          EXCEPTIONS
283            inconsistent_parameters = 1
284            upload_ole              = 2
285            OTHERS                  = 3.
286
287      ELSEIF p_filtyp = 'CSV'.
288        CALL FUNCTION 'KCD_CSV_FILE_TO_INTERN_CONVERT'
289          EXPORTING
290            i_filename      = lv_file_path
291            i_separator     = ','
292          TABLES
293            e_intern        = lt_csv
294          EXCEPTIONS
295            upload_csv      = 1
296            upload_filetype = 2
297            OTHERS          = 3.
298        LOOP AT lt_csv INTO lx_csv.
299          lx_xcel-col = lx_csv-col.
300          lx_xcel-row = lx_csv-row.
301          lx_xcel-value = lx_csv-value.
302          APPEND lx_xcel TO lt_xcel.
303          CLEAR lx_xcel.
304        ENDLOOP.
305      ENDIF.
306      LOOP AT lt_xcel INTO lx_xcel.
307
308        ASSIGN COMPONENT lx_xcel-col OF STRUCTURE <fs_dyn_wa> TO <fs_dyn_field>.
309        IF sy-subrc = 0.
310          <fs_dyn_field> = lx_xcel-value.
311        ENDIF.
312
313        IF lx_xcel-row = 1.
314          TRANSLATE lx_xcel-value TO UPPER CASE.
315          lx_field_dat-ext_field = lx_xcel-value.
316
317          READ TABLE gt_field_map INTO lx_field_map WITH KEY ext_field = lx_xcel-value.
318          IF sy-subrc = 0.
319            lx_field_dat-int_field = lx_field_map-int_field.
320          ENDIF.
321
322          APPEND lx_field_dat TO lt_field_dat.
323          CLEAR lx_field_dat.
324        ELSE.
325          IF lv_count NE lx_xcel-col."+ Vikas on 31-12-2013
326
327            lv_loop_count = lx_xcel-col - lv_count.
328            DO  lv_loop_count TIMES.
329              READ TABLE lt_field_dat INTO lx_field_dat INDEX lv_count.
330              IF sy-subrc EQ 0.
331                IF lx_field_dat-int_field = 'RENT' OR
332                        lx_field_dat-int_field = 'RENT_FINAL' OR
333                        lx_field_dat-int_field = 'CALL_CHARGE' OR
334                        lx_field_dat-int_field = 'CALL_CHARGES_FINAL' OR
335                        lx_field_dat-int_field = 'OTH_CHARGES' OR
336                        lx_field_dat-int_field = 'OTH_CHARGES_FIN' OR
337                        lx_field_dat-int_field = 'SERVICE_TAX' OR
338                        lx_field_dat-int_field = 'SERVICE_TAX_FIN' OR
339                        lx_field_dat-int_field = 'RAMT'..
340                  APPEND 0 TO lx_field_dat-value_tab.
341                  MODIFY lt_field_dat FROM lx_field_dat INDEX lv_count.
342                ELSE.
343                  APPEND space TO lx_field_dat-value_tab.
344                  MODIFY lt_field_dat FROM lx_field_dat INDEX lv_count.
345                ENDIF.
346              ENDIF.
347
348              lv_count = lv_count + 1.
349            ENDDO.
350          ENDIF.
351          READ TABLE lt_field_dat INTO lx_field_dat INDEX lv_count.
352          IF sy-subrc EQ 0.
353
354            APPEND lx_xcel-value TO lx_field_dat-value_tab.
355            MODIFY lt_field_dat FROM lx_field_dat INDEX lv_count.
356          ENDIF.
357        ENDIF.
358        lv_count = lv_count + 1.
359        AT END OF row.
360    *      APPEND <fs_dyn_wa> TO <fs_dyn_tab>.
361    *      CLEAR <fs_dyn_wa>.
362          lv_count = 1.
363        ENDAT.
364
365      ENDLOOP.
366
367
368      IF lt_field_dat IS NOT INITIAL.
369
370
371        DO.
372
373          READ TABLE lt_field_dat INTO lx_field_dat INDEX lv_field_number.
374          IF sy-subrc = 0 AND lx_field_dat-int_field IS NOT INITIAL.
375            ASSIGN lx_field_dat-int_field TO <fs_name> .
376
377            READ TABLE lx_field_dat-value_tab INTO lv_value INDEX lv_value_number.
378            IF sy-subrc NE 0.
379              EXIT."- vikas on 31-12-2013
380    *          IF lx_field_dat-int_field = 'RENT' OR
381    *                    lx_field_dat-int_field = 'RENT_FINAL' OR
382    *                    lx_field_dat-int_field = 'CALL_CHARGE' OR
383    *                    lx_field_dat-int_field = 'CALL_CHARGES_FINAL' OR
384    *                    lx_field_dat-int_field = 'OTH_CHARGES' OR
385    *                    lx_field_dat-int_field = 'OTH_CHARGES_FIN' OR
386    *                    lx_field_dat-int_field = 'SERVICE_TAX' OR
387    *                    lx_field_dat-int_field = 'SERVICE_TAX_FIN' OR
388    *                    lx_field_dat-int_field = 'RAMT'..
389    *            lv_value = 0. "+ vikas on 31-12-2013
390    *            EXIT.
391    *          ELSE.
392    *            lv_value = space."+ vikas on 31-12-2013
393    *            EXIT.
394    *          ENDIF.
395            ENDIF.
396    *      wa_bill_data-<fs_field_name> =
397            CONCATENATE  'LX_BILL_DATA-' <fs_name>  INTO lv_field_name.
398
399            ASSIGN (lv_field_name) TO <fs_field_name>.
400            IF sy-subrc EQ 0.
401
402    *Begin RD1K994186 CAB_ALOK Biller Direct:issues in upload, Process - CR 30011487
403    *          IF lx_field_dat-int_field = 'BILL_DATE' OR lx_field_dat-int_field = 'BILL_FROM' OR
404    *            lx_field_dat-int_field = 'BILL_TO' .
405              IF lx_field_dat-int_field = 'BILL_DATE' OR lx_field_dat-int_field = 'BILL_FROM' OR
406                lx_field_dat-int_field = 'BILL_TO' OR lx_field_dat-int_field = 'DUE_DATE'.
407    *End RD1K994186 CAB_ALOK Biller Direct:issues in upload, Process - CR 30011487
408
409    *          WRITE lv_valuE TO <fs_field_name>
410                CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
411                  EXPORTING
412                    date_external            = lv_value
413    *               ACCEPT_INITIAL_DATE      =
414                  IMPORTING
415                    date_internal            = <fs_field_name>
416                  EXCEPTIONS
417                    date_external_is_invalid = 1
418                    OTHERS                   = 2.
419                IF sy-subrc <> 0.
420    * Implement suitable error handling here
421                ENDIF.
422
423              ELSEIF  lx_field_dat-int_field = 'RENT' OR
424                      lx_field_dat-int_field = 'RENT_FINAL' OR
425                      lx_field_dat-int_field = 'CALL_CHARGE' OR
426                      lx_field_dat-int_field = 'CALL_CHARGES_FINAL' OR
427                      lx_field_dat-int_field = 'OTH_CHARGES' OR
428                      lx_field_dat-int_field = 'OTH_CHARGES_FIN' OR
429                      lx_field_dat-int_field = 'SERVICE_TAX' OR
430                      lx_field_dat-int_field = 'SERVICE_TAX_FIN' OR
431                      lx_field_dat-int_field = 'RAMT'.
432    * Converting external currency format to internal
433                REPLACE ALL OCCURRENCES OF ',' IN lv_value WITH space.
434                CONDENSE lv_value.
435                lv_amount = lv_value.
436
437                CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_INTERNAL'
438                  EXPORTING
439                    currency             = lc_currency
440                    amount_external      = lv_amount
441                    max_number_of_digits = lc_curr_dig
442                  IMPORTING
443                    amount_internal      = lv_amount_val
444    *               RETURN               =
445                  .
446                READ TABLE gt_field_map INTO lx_field_map WITH KEY ext_field = lx_field_dat-ext_field.
447                IF sy-subrc EQ 0 AND
448                   lx_field_map-neg_field EQ 'X'.
449                  <fs_field_name> = <fs_field_name> - lv_amount_val.
450                ELSE.
451                  <fs_field_name> = <fs_field_name> + lv_amount_val.
452
453                ENDIF.
454    *            <fs_field_name> = <fs_field_name> + lv_amount_val.
455              ELSE.
456                <fs_field_name> = lv_value.
457              ENDIF.
458
459
460            ENDIF.
461          ENDIF.
462          lv_field_number = lv_field_number + 1.
463          IF  lv_field_number GT gv_fields_no.
464            lv_field_number = 1.
465            lx_bill_data-status = lc_head_status.
466            lx_bill_data-reqt_num = lv_req_num.
467            lx_bill_data-reqt_id = lv_value_number.
468            APPEND lx_bill_data TO lt_bill_data.
469            CLEAR lx_bill_data.
470            lv_value_number = lv_value_number + 1.
471          ENDIF.
472          CLEAR lx_field_map.
473        ENDDO.
474
475      ENDIF.
476      IF lt_bill_data IS NOT INITIAL.
477        LOOP AT gt_field_map INTO wa_field_map.
478          IF wa_field_map-primary_field IS NOT INITIAL.
479            IF lv_cond IS INITIAL.
480              lv_int_field = 'LT_BILL_DATA-' && wa_field_map-int_field.
481              CONCATENATE wa_field_map-int_field '=' lv_int_field INTO  lv_cond
482              SEPARATED BY space.
483            ELSE.
484              lv_int_field = 'LT_BILL_DATA-' && wa_field_map-int_field.
485              CONCATENATE lv_cond 'AND' wa_field_map-int_field '=' lv_int_field INTO  lv_cond
486              SEPARATED BY space.
487
488            ENDIF.
489    *          CONCATENATE lv_field_names '(' wa_field_map-int_field ')' INTO lv_field_names. "SEPARATED BY space.
490    *          APPEND wa_field_map-int_field TO lt_field_name.
491            lx_fields_prim-name = wa_field_map-int_field.
492
493            IF lt_fields_comp IS INITIAL.
494              CONCATENATE wa_field_map-int_field ' = LX_BILL_DUP-' wa_field_map-int_field INTO lv_data RESPECTING BLANKS.
495              APPEND lv_data TO lt_fields_comp.
496            ELSE.
497              CONCATENATE 'AND ' wa_field_map-int_field ' = LX_BILL_DUP-' wa_field_map-int_field INTO lv_data RESPECTING BLANKS.
498              APPEND lv_data TO lt_fields_comp.
499            ENDIF.
500            APPEND lx_fields_prim TO lt_fields_prim.
501          ENDIF.
502        ENDLOOP.
503        IF lv_cond IS NOT INITIAL.
504
505
506          TRY.
507
508
509              SELECT * FROM zbill_data
510              INTO TABLE lt_bill_dup
511              FOR ALL ENTRIES IN lt_bill_data
512              WHERE (lv_cond).
513            CATCH cx_sy_dynamic_osql_error.
514    *      MESSAGE `Wrong WHERE condition!` TYPE 'I'.
515          ENDTRY.
516        ENDIF.
517        SORT lt_bill_dup BY (lt_fields_prim).
518    *      DELETE ADJACENT DUPLICATES FROM lt_bill_dup COMPARING (lv_field_names)."USING KEY (lv_field_names).
519        LOOP AT lt_bill_dup INTO lx_bill_dup.
520          lv_index = sy-tabix.
521          IF lv_index NE 1.
522            READ TABLE lt_bill_dup INTO lx_bill_del INDEX ( lv_index - 1 ).
523
524    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
525    SORT GT_FIELD_MAP .
526    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
527    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
528    SORT GT_FIELD_MAP BY serv_provider .
529    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
530            LOOP AT gt_field_map INTO wa_field_map WHERE primary_field IS NOT INITIAL.
531
532              lv_data = 'LX_BILL_DUP-' &&  wa_field_map-int_field.
533              ASSIGN (lv_data) TO <fs_field_name>.
534
535              lv_data = 'LX_BILL_DEL-' &&  wa_field_map-int_field.
536              ASSIGN (lv_data) TO <fs_field_del>.
537              IF <fs_field_del> NE <fs_field_name>.
538                EXIT.
539              ENDIF.
540              AT END OF serv_provider.
541                DELETE  lt_bill_dup INDEX lv_index.
542              ENDAT.
543            ENDLOOP.
544          ENDIF.
545        ENDLOOP.
546    *  Creating message.
547        LOOP AT lt_bill_dup  INTO lx_bill_dup.
548          lx_bill_del = lx_bill_dup.
549          lx_bill_del-reqt_num = lv_req_num.
550    *          DELETE TABLE lt_bill_data FROM  lx_bill_del." USING KEY (lv_field_names).
551          DELETE lt_bill_data WHERE (lt_fields_comp).
552          IF sy-subrc EQ 0.
553
554
555    * Getting field name for error message
556            LOOP AT gt_field_map INTO wa_field_map WHERE primary_field IS NOT INITIAL.
557              CONCATENATE 'LX_BILL_DUP-' wa_field_map-int_field INTO l_v_fieldname.
558              ASSIGN (l_v_fieldname) TO <fs_field_name>.
559              IF <fs_field_name> IS ASSIGNED.
560                lv_data = <fs_field_name>.
561                IF lv_msg1 IS INITIAL.
562                  CONCATENATE 'Duplicate entries with key: ' wa_field_map-ext_field '=' lv_data
563                  INTO lv_msg1 SEPARATED BY space.
564                ELSE.
565                  lv_count = strlen( lv_msg1 ).
566                  IF lv_count < 40.
567
568                    CONCATENATE lv_msg1 wa_field_map-ext_field '=' lv_data
569                    INTO lv_msg1 SEPARATED BY space.
570                  ELSE.
571                    lv_count = strlen( lv_msg2 ).
572                    IF lv_count < 40.
573
574                      CONCATENATE lv_msg2 wa_field_map-ext_field '=' lv_data
575                      INTO lv_msg2 SEPARATED BY space.
576                    ELSE.
577                      lv_count = strlen( lv_msg3 ).
578                      IF lv_count < 40.
579
580                        CONCATENATE lv_msg3 wa_field_map-ext_field '=' lv_data
581                        INTO lv_msg3 SEPARATED BY space.
582                      ELSE.
583                        lv_count = strlen( lv_msg4 ).
584                        IF lv_count < 40.
585
586                          CONCATENATE lv_msg4 wa_field_map-ext_field '=' lv_data
587                          INTO lv_msg4 SEPARATED BY space.
588                        ELSE.
589                        ENDIF.
590
591                      ENDIF.
592
593                    ENDIF.
594
595                  ENDIF.
596                ENDIF.
597              ENDIF.
598            ENDLOOP.
599          ENDIF.
600    * Sending a Error message to Billers Direct screen
601          lx_msg-msgid = 'ZFI_OTH'.
602          lx_msg-msgno = '035'. "Document successfully uploaded with Request Number &
603          lx_msg-msgty = 'E'.
604          lx_msg-msgv1 = lv_msg1.
605          lx_msg-msgv2 = lv_msg2.
606          lx_msg-msgv3 = lv_msg3.
607          lx_msg-msgv4 = lv_msg4.
608
609          IF lx_msg-msgv1 IS NOT INITIAL.
610            APPEND lx_msg TO lt_msg."t_messages.
611          ENDIF.
612
613          CLEAR: lv_msg1,
614          lv_msg2,
615          lv_msg3,
616          lv_msg4,
617          lx_msg.
618        ENDLOOP.
619        LOOP AT lt_msg INTO lx_return.
620
621          lx_messages-msgty = lx_return-msgty.
622          lx_messages-msgid = lx_return-msgid.
623          lx_messages-msgno = lx_return-msgno.
624          lx_messages-msgv1 = lx_return-msgv1.
625          lx_messages-msgv2 = lx_return-msgv2.
626          lx_messages-msgv3 = lx_return-msgv3.
627          lx_messages-msgv4 = lx_return-msgv4.
628    *        lx_msg = lx_messages-msgv1.
629    *        APPEND lx_messages TO lt_messages.
630          IF lx_return-msgty EQ 'E'.
631            lx_msg1-status = '@0A@'.
632          ELSEIF lx_return-msgty EQ 'I'.
633            lx_msg1-status = '@08@'.
634          ELSEIF lx_return-msgty EQ 'W'.
635            lx_msg1-status = '@09@'.
636          ENDIF.
637          IF lx_return-msgty EQ 'I'. "AND lx_messages-msgv1 IS INITIAL.
638    *        lx_return-msgv2 = lx_messages-msgv1.
639            lv_succ_msg = text-011.
640
641          ENDIF.
642          IF sy-tabix NE 1.
643            CLEAR lv_succ_msg.
644          ENDIF.
645          CONCATENATE lv_succ_msg lx_return-msgv1 lx_return-msgv2 lx_return-msgv3 lx_return-msgv4
646            INTO lx_msg1-msg SEPARATED BY space.
647          APPEND lx_msg1 TO gt_msg.
648          CLEAR lx_msg1.
649    *      lx_msg-status = '@08@'.
650    *      CONCATENATE lx_return-msgv3 lx_return-msgv4
651    *    INTO lx_msg-msg SEPARATED BY space.
652    *      APPEND lx_msg TO gt_msg.
653    *      CLEAR lx_msg.
654        ENDLOOP.
655
656      ENDIF.
657      IF lt_bill_data IS NOT INITIAL.
658
659        CALL FUNCTION 'NUMBER_GET_NEXT'
660          EXPORTING
661            nr_range_nr             = '01'
662            object                  = 'ZBILL_REQ'
663          IMPORTING
664            number                  = lv_req_num
665          EXCEPTIONS
666            interval_not_found      = 1
667            number_range_not_intern = 2
668            object_not_found        = 3
669            quantity_is_0           = 4
670            quantity_is_not_1       = 5
671            interval_overflow       = 6
672            buffer_overflow         = 7
673            OTHERS                  = 8.
674        IF sy-subrc <> 0.
675    * Implement suitable error handling here
676        ENDIF.
677
678        LOOP AT lt_bill_data INTO lx_bill_data.
679          lx_bill_data-reqt_num = lv_req_num.
680          lv_phone_len = strlen( lx_bill_data-zphone ).
681
682          IF ( bil_type = '3' OR
683             bil_type = '4' ) AND
684            lv_phone_len LT 11.
685            CONCATENATE gv_std_code  lx_bill_data-zphone INTO lx_bill_data-zphone.
686          ENDIF.
687          MODIFY lt_bill_data FROM lx_bill_data.
688        ENDLOOP.
689        lx_head_data-reqt_num = lv_req_num.
690        lx_head_data-serv_prov = ser_pro."'123032'."'MTNL'.
691        lx_head_data-bukrs = p_bukrs.
692        lx_head_data-create_date  = sy-datum.
693        lx_head_data-create_time = sy-uzeit.
694        lx_head_data-bill_type = p_btype.
695        lx_head_data-status = lc_head_status.
696
697      ENDIF.
698    *  begin of logic to add bill from and to date if not uploaded
699      READ TABLE gt_field_map INTO wa_field_map WITH KEY int_field = 'BILL_FROM'.
700      IF sy-subrc NE 0.
701        CALL FUNCTION 'CCM_GO_BACK_MONTHS'
702          EXPORTING
703            currdate   = sy-datum
704            backmonths = 1
705          IMPORTING
706            newdate    = lv_lastm_mnt.
707
708        CALL FUNCTION 'HRWPC_BL_DATES_MONTH_INTERVAL'
709          EXPORTING
710            datum          = lv_lastm_mnt
711            month_pst      = 0
712            month_ftr      = 0
713          IMPORTING
714            begda          = lv_bill_frm
715            endda          = lv_bill_to
716          EXCEPTIONS
717            invalid_values = 1
718            OTHERS         = 2.
719        IF sy-subrc EQ 0 AND
720        lt_bill_data IS NOT INITIAL.
721          LOOP AT lt_bill_data INTO lx_bill_data.
722            IF lx_bill_data-bill_from IS INITIAL.
723              lx_bill_data-bill_from = lv_bill_frm.
724            ENDIF.
725            IF lx_bill_data-bill_to IS INITIAL.
726              lx_bill_data-bill_to = lv_bill_to.
727            ENDIF.
728
729            MODIFY lt_bill_data FROM lx_bill_data INDEX sy-tabix.
730          ENDLOOP.
731        ENDIF.
732      ENDIF.
733    * end of logic to add bill from and to date if not uploaded
734      ct_bill_data = lt_bill_data.
735      cx_head_data = lx_head_data.
736
737      cv_req_num = lv_req_num.
738    ENDFORM.                    " SUB_READ_XL
739    *&---------------------------------------------------------------------*
740    *&      Form  SUB_SAVE_DATA
741    *&---------------------------------------------------------------------*
742    *       text
743    *----------------------------------------------------------------------*
744    *      -->P_LT_BILL_DATA  text
745    *      -->P_LX_HEAD_DATA  text
746    *----------------------------------------------------------------------*
747    FORM sub_save_data  TABLES pt_bill_data
748                        USING  px_head_data
749                               pv_req_num.
750
751      DATA: lv_message TYPE string,
752            lt_return TYPE  TABLE OF  ebpp_messages,
753            lt_filemeta TYPE  ebpp_inv_filemeta_tab,
754            lx_filemeta TYPE  ebpp_inv_filemeta,
755            wa_bill_data    TYPE zbill_data,
756            lv_total_entry TYPE i,
757            lv_total_entc TYPE string,
758            lv_bill_ttext  TYPE val_text,
759            lx_fcat       TYPE lvc_s_fcat,
760            lv_bill_ttextf  TYPE string,
761            lt_dd07_tab    TYPE dd07v_tab ,
762            lx_dd07_tab    TYPE dd07v,
763            lx_msg TYPE gty_msg,
764            lx_return TYPE fimsg,
765
766            lv_total_amount TYPE zbill_call_charges,
767            lv_total_amt TYPE string,
768      lv_partner TYPE buspa_key.
769      CONCATENATE gv_file_path gv_file_name INTO lx_filemeta-comp_id.
770      APPEND lx_filemeta TO lt_filemeta.
771      CLEAR lx_filemeta.
772
773      MODIFY zbill_data FROM TABLE pt_bill_data.
774
775      IF sy-subrc EQ 0.
776
777        INSERT INTO zbill_head VALUES px_head_data.
778
779        IF sy-subrc EQ 0.
780          DESCRIBE TABLE pt_bill_data LINES lv_total_entry.
781          lv_total_entc = lv_total_entry.
782
783    * get total amount
784          LOOP AT pt_bill_data INTO wa_bill_data.
785            lv_total_amount = lv_total_amount + wa_bill_data-rent.
786            lv_total_amount = lv_total_amount + wa_bill_data-call_charge.
787            lv_total_amount = lv_total_amount + wa_bill_data-oth_charges.
788            lv_total_amount = lv_total_amount + wa_bill_data-service_tax.
789          ENDLOOP.
790          lv_total_amt = lv_total_amount .
791
792    * Get bill type description
793    * Get Bill type text
794          CALL FUNCTION 'DDIF_DOMA_GET'
795            EXPORTING
796              name                = 'ZBILL_TYPE'
797    *     STATE               = 'A'
798             langu               = sy-langu
799    *   IMPORTING
800    *     GOTSTATE            =
801    *     DD01V_WA            =
802           TABLES
803             dd07v_tab           = lt_dd07_tab
804         EXCEPTIONS
805           illegal_input       = 1
806           OTHERS              = 2
807                    .
808          IF sy-subrc EQ 0.
809            READ TABLE lt_dd07_tab INTO lx_dd07_tab WITH KEY domvalue_l = p_btype.
810            IF sy-subrc EQ 0.
811              lv_bill_ttext = lx_dd07_tab-ddtext.
812              lv_bill_ttextf = lv_bill_ttext.
813            ENDIF.
814          ENDIF.
815          lx_return-msgv1 = 'Data uploaded successfully with request number:'(011) .
816          lx_return-msgv2 = pv_req_num && '.' && 'Bill type ' && p_btype && '-'  && lv_bill_ttext && '.'.
817
818
819          lx_return-msgv3 = 'Number of records uploaded: ' && lv_total_entc && '.'.
820          lx_return-msgv4 = 'Total amount: Rs'  && lv_total_amt.
821    *      lx_return-msgv4 =
822          lx_msg-status = '@08@'.
823          CONCATENATE lx_return-msgv1 lx_return-msgv2 "lx_return-msgv3 lx_return-msgv4
824            INTO lx_msg-msg SEPARATED BY space.
825          APPEND lx_msg TO gt_msg.
826          CLEAR lx_msg.
827          lx_msg-status = '@08@'.
828          CONCATENATE lx_return-msgv3 lx_return-msgv4
829            INTO lx_msg-msg SEPARATED BY space.
830          APPEND lx_msg TO gt_msg.
831          CLEAR lx_msg.
832
833          lx_fcat-col_pos    = 1.
834          lx_fcat-coltext    = 'Status'.
835          lx_fcat-fieldname    = 'STATUS'.
836          lx_fcat-icon       = 'X'.
837          lx_fcat-outputlen  = '4'.
838          APPEND lx_fcat TO gt_msg_fcat.
839          CLEAR lx_fcat.
840
841          lx_fcat-col_pos    = 2.
842          lx_fcat-coltext    = 'Message'.
843          lx_fcat-fieldname    = 'MSG'.
844    *    lx_fcat-icon       = 'X'.
845          lx_fcat-outputlen  = '255'.
846          APPEND lx_fcat TO gt_msg_fcat.
847
848          CALL SCREEN 9001 STARTING AT 10 10 ENDING AT 120 30.
849          CLEAR gt_msg_fcat.
850    *      CONCATENATE 'Data uploaded successfully with request number:'(011) pv_req_num '.'
851    *       'Bill type ' p_btype '-' lv_bi1ll_ttext '.'
852    *       'Number of records uploaded: ' lv_total_entc '.'
853    *      'Total amount: Rs'  lv_total_amt INTO lv_message .
854
855    *      MESSAGE lv_message TYPE 'I'.
856
857          lv_partner = ser_pro.
858          CALL FUNCTION 'ZBILL_SEND_UPD_MAIL'
859            EXPORTING
860              im_partner    = lv_partner
861              im_req_num    = pv_req_num
862              im_tot_amount = lv_total_amount
863              im_tot_ent    = lv_total_entc
864              im_bill_type  = p_btype
865              im_bill_ttext = lv_bill_ttext
866            TABLES
867              return        = lt_return
868              t_filemeta    = lt_filemeta.
869
870        ENDIF.
871      ENDIF.
872
873    ENDFORM.                    " SUB_SAVE_DATA
874    *&---------------------------------------------------------------------*
875    *&      Form  GET_FIELDNAME_GL
876    *&---------------------------------------------------------------------*
877    *       text
878    *----------------------------------------------------------------------*
879    *  -->  p1        text
880    *  <--  p2        text
881    *----------------------------------------------------------------------*
882    FORM get_fieldname_gl .
883
884      TYPES: BEGIN OF lty_field_stru,
885               fieldname TYPE fieldname,
886               reptext TYPE reptext,
887              END OF lty_field_stru.
888
889      DATA: lt_fields_data1 TYPE TABLE OF dfies,
890      lx_fields_data1 TYPE dfies,
891      lt_field_stru TYPE TABLE OF lty_field_stru,
892      lx_field_stru TYPE lty_field_stru,
893      lt_sel_fields TYPE TABLE OF ddshretval,
894      lx_sel_fields TYPE ddshretval.
895
896      DATA: patt TYPE string VALUE 'FIN',
897            result_tab TYPE match_result_tab.
898
899
900      CALL FUNCTION 'DDIF_FIELDINFO_GET'
901        EXPORTING
902          tabname              = 'ZBILL_DATA'
903    *   FIELDNAME            = ' '
904    *   LANGU                = SY-LANGU
905    *   LFIELDNAME           = ' '
906    *   ALL_TYPES            = ' '
907    *   GROUP_NAMES          = ' '
908    *   UCLEN                =
909    *   DO_NOT_WRITE         = ' '
910    * IMPORTING
911    *   X030L_WA             =
912    *   DDOBJTYPE            =
913    *   DFIES_WA             =
914    *   LINES_DESCR          =
915       TABLES
916         dfies_tab            = lt_fields_data
917    *   FIXED_VALUES         =
918     EXCEPTIONS
919       not_found            = 1
920       internal_error       = 2
921       OTHERS               = 3
922                .
923      IF sy-subrc <> 0.
924    * Implement suitable error handling here
925
926      ENDIF.
927
928
929      DELETE  lt_fields_data WHERE domname NE 'BWHR'.
930
931    * DELETE  LT_FIELDS_DATA WHERE FIELDNAME EQ '*FIN'.
932
933      LOOP AT  lt_fields_data INTO lx_fields_data.
934
935        FIND ALL OCCURRENCES OF patt IN lx_fields_data-fieldname RESULTS result_tab.
936        IF sy-subrc EQ 0.
937          DELETE lt_fields_data  WHERE fieldname = lx_fields_data-fieldname.
938        ENDIF.
939
940      ENDLOOP.
941
942
943    ENDFORM.                    " GET_FIELDNAME_GL
944    *&---------------------------------------------------------------------*
945    *&      Form  SUB_READ_CSV
946    *&---------------------------------------------------------------------*
947    *       text
948    *----------------------------------------------------------------------*
949    *      <--P_LT_BILL_DATA  text
950    *      <--P_LX_HEAD_DATA  text
951    *----------------------------------------------------------------------*
952    FORM sub_read_csv  CHANGING p_lt_bill_data
953                                p_lx_head_data.
954      DATA: lv_file_path TYPE string,
955            lt_csv_file TYPE TABLE OF string.
956      TYPES:BEGIN OF ty_field_stru,
957              ext_field TYPE string,
958              int_field TYPE string,
959              value_tab TYPE ztt_bill_values,
960            END OF ty_field_stru.
961
962
963      DATA: "lv_file_path TYPE rlgrap-filename,
964            ld_new_line TYPE REF TO data,
965            lt_field_dat TYPE TABLE OF string,
966            lx_field_dat TYPE string,
967            lx_field_dat1 TYPE ty_field_stru,
968            lx_field_map TYPE zbill_field_map,
969            lv_count TYPE i VALUE 1,
970            lv_field_number TYPE i VALUE 1,
971            lv_value_number TYPE i VALUE 1,
972            lt_bill_data TYPE TABLE OF zbill_data,
973            lx_head_data TYPE zbill_head,
974            lx_bill_data TYPE zbill_data,
975            lv_value TYPE string,
976            lv_field_name TYPE string,
977            lv_req_num TYPE zbill_req_nm.
978
979      CONSTANTS: lc_head_status TYPE char1 VALUE '1'.
980
981      FIELD-SYMBOLS:<fs_dyn_tab> TYPE STANDARD TABLE,
982                    <fs_dyn_wa>,
983                    <fs_dyn_field>,
984                    <fs_name> TYPE string,
985                     <fs_field_name> TYPE any.
986      DATA: lt_xcel TYPE TABLE OF alsmex_tabline,
987            lx_xcel TYPE alsmex_tabline.
988
989      CONCATENATE gv_file_path gv_file_name INTO lv_file_path.
990
991      ASSIGN gt_dyn_tab->* TO <fs_dyn_tab>.
992
993    * Create dynamic work area and assign to FS
994      CREATE DATA ld_new_line LIKE LINE OF <fs_dyn_tab>.
995
996      ASSIGN ld_new_line->* TO <fs_dyn_wa>.
997
998      CONCATENATE gv_file_path gv_file_name INTO lv_file_path.
999
1000   *  CALL FUNCTION 'KCD_CSV_FILE_TO_INTERN_CONVERT'
1001   *    EXPORTING
1002   *      i_filename            = lv_file_path
1003   *      i_separator           = ','
1004   *    TABLES
1005   *      e_intern              =
1006   **   EXCEPTIONS
1007   **     UPLOAD_CSV            = 1
1008   **     UPLOAD_FILETYPE       = 2
1009   **     OTHERS                = 3
1010   *            .
1011     IF sy-subrc <> 0.
1012   * Implement suitable error handling here
1013     ENDIF.
1014
1015   *  CALL FUNCTION 'GUI_UPLOAD'
1016   *    EXPORTING
1017   *      filename                      = lv_file_path
1018   *     filetype                      = 'ASC'
1019   *   has_field_separator           = 'X'
1020   **   HEADER_LENGTH                 = 0
1021   **   READ_BY_LINE                  = 'X'
1022   **   DAT_MODE                      = ' '
1023   **   CODEPAGE                      = ' '
1024   **   IGNORE_CERR                   = ABAP_TRUE
1025   **   REPLACEMENT                   = '#'
1026   **   CHECK_BOM                     = ' '
1027   **   VIRUS_SCAN_PROFILE            =
1028   **   NO_AUTH_CHECK                 = ' '
1029   **   ISDOWNLOAD                    = ' '
1030   ** IMPORTING
1031   **   FILELENGTH                    =
1032   **   HEADER                        =
1033   *    TABLES
1034   *      data_tab                      = lt_field_dat"<fs_dyn_tab>
1035   ** CHANGING
1036   **   ISSCANPERFORMED               = ' '
1037   *   EXCEPTIONS
1038   *     file_open_error               = 1
1039   *     file_read_error               = 2
1040   *     no_batch                      = 3
1041   *     gui_refuse_filetransfer       = 4
1042   *     invalid_type                  = 5
1043   *     no_authority                  = 6
1044   *     unknown_error                 = 7
1045   *     bad_data_format               = 8
1046   *     header_not_allowed            = 9
1047   *     separator_not_allowed         = 10
1048   *     header_too_long               = 11
1049   *     unknown_dp_error              = 12
1050   *     access_denied                 = 13
1051   *     dp_out_of_memory              = 14
1052   *     disk_full                     = 15
1053   *     dp_timeout                    = 16
1054   *     OTHERS                        = 17
1055   *            .
1056   *  IF sy-subrc <> 0.
1057   ** Implement suitable error handling here
1058   *  ENDIF.
1059   *
1060   *  LOOP AT lt_field_dat INTO lx_field_dat.
1061   *    SPLIT lx_field_dat AT ',' INTO <fs_dyn_wa>-FIELD1 <fs_dyn_wa>-FIELD2 <fs_dyn_wa>-FIELD3
1062   *    <fs_dyn_wa>-FIELD4 <fs_dyn_wa>-FIELD5 <fs_dyn_wa>-FIELD6
1063   *    <fs_dyn_wa>-FIELD7 <fs_dyn_wa>-FIELD8 <fs_dyn_wa>-FIELD9
1064   *    <fs_dyn_wa>-FIELD10  .
1065   *
1066   *  ENDLOOP.
1067   ENDFORM.                    " SUB_READ_CSV
1068   *&---------------------------------------------------------------------*
1069   *&      Form  SUB_DISPLAY_ALV
1070   *&---------------------------------------------------------------------*
1071   *       text
1072   *----------------------------------------------------------------------*
1073   *      <--P_LT_BILL_DATA  text
1074   *----------------------------------------------------------------------*
1075   FORM sub_display_alv  TABLES pt_bill_data .
1076
1077     DATA: lt_fieldcat TYPE slis_t_fieldcat_alv,
1078           lx_fieldcat TYPE slis_fieldcat_alv,
1079           lx_fcat TYPE lvc_s_fcat.
1080   *
1081   *  LOOP AT gt_fcat INTO lx_fcat.
1082   *    lx_fieldcat-col_pos        = lx_fcat-col_pos.
1083   *    lx_fieldcat-fieldname = lx_fcat-fieldname.
1084   *    lx_fieldcat-tabname = 'PT_BILL_DATA'.
1085   *    APPEND lx_fieldcat TO lt_fieldcat.
1086   *    CLEAR lx_fieldcat.
1087   *  ENDLOOP.
1088
1089     CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
1090       EXPORTING
1091         i_program_name         = sy-repid
1092   *     I_INTERNAL_TABNAME     =
1093         i_structure_name       = 'ZBILL_DATA'
1094   *     I_CLIENT_NEVER_DISPLAY = 'X'
1095   *     I_INCLNAME             =
1096   *     I_BYPASSING_BUFFER     =
1097   *     I_BUFFER_ACTIVE        =
1098       CHANGING
1099         ct_fieldcat            = lt_fieldcat
1100       EXCEPTIONS
1101         inconsistent_interface = 1
1102         program_error          = 2
1103         OTHERS                 = 3.
1104     LOOP AT lt_fieldcat INTO lx_fieldcat.
1105       lx_fieldcat-input = 'X'.
1106       MODIFY lt_fieldcat FROM lx_fieldcat .
1107     ENDLOOP.
1108     IF sy-subrc <> 0.
1109   * Implement suitable error handling here
1110     ENDIF.
1111
1112     CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
1113       EXPORTING
1114   *   I_TITLE                       =
1115      i_selection                   = 'X'
1116   *   I_ALLOW_NO_SELECTION          =
1117   *   I_ZEBRA                       = ' '
1118   *   I_SCREEN_START_COLUMN         = 0
1119   *   I_SCREEN_START_LINE           = 0
1120   *   I_SCREEN_END_COLUMN           = 0
1121   *   I_SCREEN_END_LINE             = 0
1122   *   I_CHECKBOX_FIELDNAME          =
1123   *   I_LINEMARK_FIELDNAME          =
1124   *   I_SCROLL_TO_SEL_LINE          = 'X'
1125         i_tabname                     = 'PT_BILL_DATA'
1126   *   I_STRUCTURE_NAME              =
1127      it_fieldcat                   = lt_fieldcat
1128   *   IT_EXCLUDING                  =
1129   *   I_CALLBACK_PROGRAM            =
1130   *   I_CALLBACK_USER_COMMAND       =
1131   *   IS_PRIVATE                    =
1132   * IMPORTING
1133   *   ES_SELFIELD                   =
1134   *   E_EXIT                        =
1135       TABLES
1136         t_outtab                      = pt_bill_data
1137    EXCEPTIONS
1138      program_error                 = 1
1139      OTHERS                        = 2
1140               .
1141     IF sy-subrc <> 0.
1142   * Implement suitable error handling here
1143     ENDIF.
1144
1145   ENDFORM.                    " SUB_DISPLAY_ALV
1146   *&---------------------------------------------------------------------*
1147   *&      Form  SUB_READ_ZIP
1148   *&---------------------------------------------------------------------*
1149   *       text
1150   *----------------------------------------------------------------------*
1151   *      <--P_LT_BILL_DATA  text
1152   *      <--P_LX_HEAD_DATA  text
1153   *      <--P_LV_REQ_NUM  text
1154   *----------------------------------------------------------------------*
1155   FORM sub_read_zip  CHANGING ct_bill_data
1156                               cx_head_data
1157                               cv_req_num.
1158     TYPES:
1159     BEGIN OF lty_file,
1160            name TYPE string,
1161            date TYPE d,
1162            time TYPE t,
1163            size TYPE i,
1164          END OF lty_file .
1165     DATA: lv_file_path TYPE string,
1166           lx_dataline TYPE x LENGTH 1024,
1167           lt_zip_data LIKE TABLE OF lx_dataline,
1168           lv_cursor   TYPE i,
1169           lv_length TYPE i,
1170           lv_file_size TYPE i,
1171           lx_zip TYPE xstring,
1172           lx_files TYPE lty_file,
1173           lo_patch_zip TYPE REF TO cl_abap_zip,
1174           lt_file_content TYPE ebpp_inv_filecontent_tab,
1175           lx_file_content TYPE ebpp_inv_filecontent,
1176           lv_xstring TYPE xstring,
1177           lt_xstring_dat TYPE TABLE OF lxe_xtab,
1178           lx_xstring_dat TYPE lxe_xtab,
1179           lx_partner TYPE ebpp_partner,
1180           lt_filemeta TYPE ebpp_inv_filemeta_tab,
1181           lx_log TYPE bal_s_log,
1182           lx_filemeta TYPE ebpp_inv_filemeta,
1183           lt_return TYPE TABLE OF fimsg,"ebpp_messages,
1184   *        lt_messages TYPE hrpayca_message_tab,
1185           lx_messages TYPE bal_s_msg,
1186   *        lx_msg TYPE balloghndl,
1187           lx_display_profile TYPE bal_s_prof,
1188           lx_return TYPE fimsg,"ebpp_messages,
1189           lv_succ_msg  TYPE symsgv,
1190           lv_message TYPE string,
1191           lo_msg TYPE REF TO cl_alv_changed_data_protocol,
1192           lx_fcat TYPE lvc_s_fcat,
1193           lx_msg TYPE gty_msg.
1194
1195     CONSTANTS lc_datalinelength TYPE i VALUE 1024.
1196
1197   * Partner key
1198     lx_partner-partnerkey = ser_pro.
1199     lx_partner-uname = sy-uname.
1200     CONCATENATE gv_file_path gv_file_name INTO lv_file_path.
1201     CALL METHOD cl_gui_frontend_services=>gui_upload
1202       EXPORTING
1203         filename                = lv_file_path
1204         filetype                = 'BIN'
1205       IMPORTING
1206         filelength              = lv_file_size
1207       CHANGING
1208         data_tab                = lt_zip_data
1209       EXCEPTIONS
1210         file_open_error         = 1
1211         file_read_error         = 2
1212         no_batch                = 3
1213         gui_refuse_filetransfer = 4
1214         invalid_type            = 5
1215         no_authority            = 6
1216         unknown_error           = 7
1217         bad_data_format         = 8
1218         header_not_allowed      = 9
1219         separator_not_allowed   = 10
1220         header_too_long         = 11
1221         unknown_dp_error        = 12
1222         access_denied           = 13
1223         dp_out_of_memory        = 14
1224         disk_full               = 15
1225         dp_timeout              = 16
1226         not_supported_by_gui    = 17
1227         error_no_gui            = 18
1228         OTHERS                  = 19.
1229     IF sy-subrc <> 0.
1230   *   Implement suitable error handling here
1231     ENDIF.
1232     LOOP AT lt_zip_data INTO lx_dataline.
1233       ADD lc_datalinelength TO lv_cursor.
1234       IF lv_cursor > lv_file_size.
1235         lv_length = lv_file_size - lv_cursor + lc_datalinelength.
1236         CONCATENATE lx_zip lx_dataline(lv_length) INTO lx_zip IN BYTE MODE.
1237       ELSE.
1238         CONCATENATE lx_zip lx_dataline INTO lx_zip IN BYTE MODE.
1239       ENDIF.
1240     ENDLOOP.
1241     IF lx_zip IS INITIAL.
1242       RETURN.
1243     ENDIF.
1244     IF p_filtyp = 'ZIP'.
1245
1246
1247   * Read zip xstring
1248       CREATE OBJECT lo_patch_zip.
1249       CALL METHOD lo_patch_zip->load
1250         EXPORTING
1251           zip             = lx_zip
1252         EXCEPTIONS
1253           zip_parse_error = 1
1254           OTHERS          = 2.
1255       IF sy-subrc <> 0.
1256   *   Implement suitable error handling here
1257       ENDIF.
1258
1259       LOOP AT lo_patch_zip->files INTO lx_files.
1260         lx_file_content-file_id = sy-tabix.
1261         lx_filemeta-file_id = lx_file_content-file_id.
1262         lx_filemeta-comp_id = lx_files-name.
1263         lx_filemeta-comp_size = lx_files-size.
1264         APPEND lx_filemeta TO lt_filemeta.
1265         CLEAR lx_filemeta.
1266
1267         CALL METHOD lo_patch_zip->get
1268           EXPORTING
1269             name                    = lx_files-name
1270   *         index                   = 0
1271           IMPORTING
1272             content                 = lv_xstring
1273           EXCEPTIONS
1274             zip_index_error         = 1
1275             zip_decompression_error = 2
1276             OTHERS                  = 3.
1277         IF sy-subrc NE 0.
1278           CONTINUE.
1279   *     Implement suitable error handling here
1280         ENDIF.
1281
1282         CALL FUNCTION 'LXE_COMMON_XSTRING_TO_TABLE'
1283           EXPORTING
1284             in_xstring = lv_xstring
1285           TABLES
1286             ex_tab     = lt_xstring_dat.
1287
1288         LOOP AT lt_xstring_dat INTO lx_xstring_dat.
1289           lx_file_content-content_line =  lx_xstring_dat-text.
1290           APPEND lx_file_content TO lt_file_content.
1291           CLEAR lx_file_content-content_line.
1292         ENDLOOP.
1293
1294         CLEAR lx_file_content.
1295       ENDLOOP.
1296     ELSEIF p_filtyp = 'XML'.
1297       lx_file_content-file_id = '001'.
1298       lx_filemeta-file_id = lx_file_content-file_id.
1299       lx_filemeta-comp_id = gv_file_name.
1300
1301       APPEND lx_filemeta TO lt_filemeta.
1302       CLEAR lx_filemeta.
1303       CALL FUNCTION 'LXE_COMMON_XSTRING_TO_TABLE'
1304         EXPORTING
1305           in_xstring = lx_zip
1306         TABLES
1307           ex_tab     = lt_xstring_dat.
1308
1309       LOOP AT lt_xstring_dat INTO lx_xstring_dat.
1310         lx_file_content-content_line =  lx_xstring_dat-text.
1311         APPEND lx_file_content TO lt_file_content.
1312         CLEAR lx_file_content-content_line.
1313       ENDLOOP.
1314
1315       CLEAR lx_file_content.
1316
1317     ENDIF.
1318     CALL FUNCTION 'ZBILL_UPDATE_DATA'
1319       EXPORTING
1320         it_filecontent = lt_file_content
1321         im_partner     = lx_partner
1322         im_bukrs       = p_bukrs
1323         im_bill_type   = p_btype
1324       IMPORTING
1325         im_req_nm      = cv_req_num
1326       TABLES
1327         return         = lt_return
1328         t_filemeta     = lt_filemeta.
1329     IF lt_return IS INITIAL.
1330       CONCATENATE 'Data uploaded successfully with request number:'(011) cv_req_num INTO lv_message.
1331       MESSAGE lv_message TYPE 'I'.
1332     ELSE.
1333
1334       LOOP AT lt_return INTO lx_return.
1335
1336         lx_messages-msgty = lx_return-msgty.
1337         lx_messages-msgid = lx_return-msgid.
1338         lx_messages-msgno = lx_return-msgno.
1339         lx_messages-msgv1 = lx_return-msgv1.
1340         lx_messages-msgv2 = lx_return-msgv2.
1341         lx_messages-msgv3 = lx_return-msgv3.
1342         lx_messages-msgv4 = lx_return-msgv4.
1343   *        lx_msg = lx_messages-msgv1.
1344   *        APPEND lx_messages TO lt_messages.
1345         IF lx_return-msgty EQ 'E'.
1346           lx_msg-status = '@0A@'.
1347         ELSEIF lx_return-msgty EQ 'I'.
1348           lx_msg-status = '@08@'.
1349         ELSEIF lx_return-msgty EQ 'W'.
1350           lx_msg-status = '@09@'.
1351         ENDIF.
1352         IF lx_return-msgty EQ 'I'. "AND lx_messages-msgv1 IS INITIAL.
1353   *        lx_return-msgv2 = lx_messages-msgv1.
1354           lv_succ_msg = text-011.
1355
1356         ENDIF.
1357         IF sy-tabix NE 1.
1358           CLEAR lv_succ_msg.
1359         ENDIF.
1360         CONCATENATE lv_succ_msg lx_return-msgv1 lx_return-msgv2 lx_return-msgv3 lx_return-msgv4
1361           INTO lx_msg-msg SEPARATED BY space.
1362         APPEND lx_msg TO gt_msg.
1363         CLEAR lx_msg.
1364   *      lx_msg-status = '@08@'.
1365   *      CONCATENATE lx_return-msgv3 lx_return-msgv4
1366   *    INTO lx_msg-msg SEPARATED BY space.
1367   *      APPEND lx_msg TO gt_msg.
1368   *      CLEAR lx_msg.
1369       ENDLOOP.
1370
1371       lx_fcat-col_pos    = 1.
1372       lx_fcat-coltext    = 'Status'.
1373       lx_fcat-fieldname    = 'STATUS'.
1374       lx_fcat-icon       = 'X'.
1375       lx_fcat-outputlen  = 4.
1376       lx_fcat-tabname      = 'GT_MSG'.
1377       APPEND lx_fcat TO gt_msg_fcat.
1378       CLEAR lx_fcat.
1379
1380       lx_fcat-col_pos    = 2.
1381       lx_fcat-coltext    = 'Message'.
1382       lx_fcat-fieldname    = 'MSG'.
1383       lx_fcat-tabname      = 'GT_MSG'.
1384
1385   *    lx_fcat-icon       = 'X'.
1386       lx_fcat-outputlen  = '000255'.
1387       APPEND lx_fcat TO gt_msg_fcat.
1388
1389       CALL SCREEN 9001 STARTING AT 10 10 ENDING AT 120 30.
1390     ENDIF.
1391   ENDFORM.                    " SUB_READ_ZIP
1392   *&---------------------------------------------------------------------*
1393   *&      Module  STATUS_9001  OUTPUT
1394   *&---------------------------------------------------------------------*
1395   *       text
1396   *----------------------------------------------------------------------*
1397   MODULE status_9001 OUTPUT.
1398     SET PF-STATUS 'STATUS_9001'.
1399   *  SET TITLEBAR 'xxx'.
1400
1401   ENDMODULE.                 " STATUS_9001  OUTPUT
1402   *&---------------------------------------------------------------------*
1403   *&      Module  MODULE_DISP_MSG  OUTPUT
1404   *&---------------------------------------------------------------------*
1405   *       text
1406   *----------------------------------------------------------------------*
1407   MODULE module_disp_msg OUTPUT.
1408     IF go_msg_cnt IS INITIAL.
1409       CREATE OBJECT go_msg_cnt
1410         EXPORTING
1411   *        parent                      =
1412           container_name              = 'CC_CONT'
1413   *        style                       =
1414   *        lifetime                    = lifetime_default
1415   *        repid                       =
1416   *        dynnr                       =
1417   *        no_autodef_progid_dynnr     =
1418         EXCEPTIONS
1419           cntl_error                  = 1
1420           cntl_system_error           = 2
1421           create_error                = 3
1422           lifetime_error              = 4
1423           lifetime_dynpro_dynpro_link = 5
1424           OTHERS                      = 6
1425           .
1426       IF sy-subrc <> 0.
1427   *     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
1428   *                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
1429       ENDIF.
1430
1431     ENDIF.
1432     IF go_msg_alv IS INITIAL.
1433       CREATE OBJECT go_msg_alv
1434         EXPORTING
1435   *        i_shellstyle      = 0
1436   *        i_lifetime        =
1437           i_parent          = go_msg_cnt
1438   *        i_appl_events     = space
1439   *        i_parentdbg       =
1440   *        i_applogparent    =
1441   *        i_graphicsparent  =
1442   *        i_name            =
1443   *        i_fcat_complete   = SPACE
1444         EXCEPTIONS
1445           error_cntl_create = 1
1446           error_cntl_init   = 2
1447           error_cntl_link   = 3
1448           error_dp_create   = 4
1449           OTHERS            = 5
1450           .
1451       IF sy-subrc <> 0.
1452   *     MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
1453   *                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
1454       ENDIF.
1455
1456     ENDIF.
1457
1458     CALL METHOD go_msg_alv->set_table_for_first_display
1459   *    EXPORTING
1460   *      i_buffer_active               =
1461   *      i_bypassing_buffer            =
1462   *      i_consistency_check           =
1463   *      i_structure_name              =
1464   *      is_variant                    =
1465   *      i_save                        =
1466   *      i_default                     = 'X'
1467   *      is_layout                     =
1468   *      is_print                      =
1469   *      it_special_groups             =
1470   *      it_toolbar_excluding          =
1471   *      it_hyperlink                  =
1472   *      it_alv_graphics               =
1473   *      it_except_qinfo               =
1474   *      ir_salv_adapter               =
1475       CHANGING
1476         it_outtab                     = gt_msg
1477         it_fieldcatalog               = gt_msg_fcat
1478   *      it_sort                       =
1479   *      it_filter                     =
1480       EXCEPTIONS
1481         invalid_parameter_combination = 1
1482         program_error                 = 2
1483         too_many_lines                = 3
1484         OTHERS                        = 4
1485             .
1486     IF sy-subrc <> 0.
1487   *   Implement suitable error handling here
1488     ENDIF.
1489
1490   ENDMODULE.                 " MODULE_DISP_MSG  OUTPUT
1491   *&---------------------------------------------------------------------*
1492   *&      Module  USER_COMMAND_9001  INPUT
1493   *&---------------------------------------------------------------------*
1494   *       text
1495   *----------------------------------------------------------------------*
1496   MODULE user_command_9001 INPUT.
1497     CASE sy-ucomm.
1498       WHEN 'OK'.
1499         LEAVE TO SCREEN 0.
1500       WHEN 'CANCEL'.
1501         LEAVE TO SCREEN 0.
1502       WHEN OTHERS.
1503     ENDCASE.
1504   ENDMODULE.                 " USER_COMMAND_9001  INPUT
1505   *&---------------------------------------------------------------------*
1506   *&      Form  SUB_SAVE_FILE_APP
1507   *&---------------------------------------------------------------------*
1508   *       text
1509   *----------------------------------------------------------------------*
1510   *      -->P_LV_REQ_NUM  text
1511   *----------------------------------------------------------------------*
1512   FORM sub_save_file_app  USING    p_lv_req_num.
1513     TYPES:BEGIN OF lty_file,
1514          name TYPE string,
1515          date TYPE d,
1516          time TYPE t,
1517          size TYPE i,
1518        END OF lty_file.
1519     DATA:lv_file_path TYPE string,
1520     lv_file_size TYPE i,
1521     lx_dataline TYPE x LENGTH 1024,
1522     lt_xl_data LIKE TABLE OF lx_dataline,
1523     lv_cursor   TYPE i,
1524     lv_length TYPE i,
1525     lx_zip TYPE xstring,
1526     lt_xstring_dat TYPE TABLE OF lxe_xtab,
1527     lx_xstring_dat TYPE lxe_xtab,
1528     lx_file_map     TYPE zbill_file_map,
1529     lt_file_map     TYPE TABLE OF zbill_file_map,
1530             lv_sysid_all  TYPE string,
1531           lv_sysid_curr  TYPE string,
1532           lv_sysid_dev  TYPE string VALUE '/usr/sap/RD1/FIN/CMD_MIS/',
1533           lv_file_name    TYPE string,
1534                   lo_patch_zip TYPE REF TO cl_abap_zip,
1535     lx_files TYPE lty_file,
1536           lx_file_content TYPE ebpp_inv_filecontent,
1537           lv_xstring TYPE xstring.
1538
1539     CONSTANTS lc_datalinelength TYPE i VALUE 1024.
1540
1541     CONCATENATE gv_file_path gv_file_name INTO lv_file_path.
1542     CALL METHOD cl_gui_frontend_services=>gui_upload
1543       EXPORTING
1544         filename                = lv_file_path
1545         filetype                = 'BIN'
1546       IMPORTING
1547         filelength              = lv_file_size
1548       CHANGING
1549         data_tab                = lt_xl_data
1550       EXCEPTIONS
1551         file_open_error         = 1
1552         file_read_error         = 2
1553         no_batch                = 3
1554         gui_refuse_filetransfer = 4
1555         invalid_type            = 5
1556         no_authority            = 6
1557         unknown_error           = 7
1558         bad_data_format         = 8
1559         header_not_allowed      = 9
1560         separator_not_allowed   = 10
1561         header_too_long         = 11
1562         unknown_dp_error        = 12
1563         access_denied           = 13
1564         dp_out_of_memory        = 14
1565         disk_full               = 15
1566         dp_timeout              = 16
1567         not_supported_by_gui    = 17
1568         error_no_gui            = 18
1569         OTHERS                  = 19.
1570     IF sy-subrc <> 0.
1571   *   Implement suitable error handling here
1572     ENDIF.
1573     LOOP AT lt_xl_data INTO lx_dataline.
1574       ADD lc_datalinelength TO lv_cursor.
1575       IF lv_cursor > lv_file_size.
1576         lv_length = lv_file_size - lv_cursor + lc_datalinelength.
1577         CONCATENATE lx_zip lx_dataline(lv_length) INTO lx_zip IN BYTE MODE.
1578       ELSE.
1579         CONCATENATE lx_zip lx_dataline INTO lx_zip IN BYTE MODE.
1580       ENDIF.
1581     ENDLOOP.
1582     IF lx_zip IS INITIAL.
1583       RETURN.
1584     ENDIF.
1585
1586   * File Path
1587     CONCATENATE '/usr/sap/' sy-sysid '/FIN/ebill/' INTO lv_sysid_all.
1588     IF sy-sysid EQ 'RD1'.
1589       lv_sysid_curr = lv_sysid_dev.
1590     ELSEIF sy-sysid EQ 'RP1'.
1591       lv_sysid_curr = '/usr/sap/RP1/FIN/epay/ebill/'.
1592     ELSE.
1593       lv_sysid_curr = lv_sysid_all.
1594     ENDIF.
1595
1596     CONCATENATE lv_sysid_curr p_lv_req_num '_001'  '.' p_filtyp INTO lv_file_name.
1597     OPEN DATASET lv_file_name FOR OUTPUT IN BINARY MODE .
1598   *  LOOP AT lt_xstring_dat INTO lx_xstring_dat."it_filecontent INTO lx_filecontent.
1599     TRANSFER lx_zip TO lv_file_name.
1600   *  ENDLOOP.
1601     CLOSE DATASET lv_file_name.
1602
1603     lx_file_map-reqt_num = p_lv_req_num.
1604     lx_file_map-file_id  = 1.
1605     lx_file_map-file_name = p_lv_req_num && '_001.' && p_filtyp.
1606     APPEND lx_file_map TO lt_file_map.
1607     CLEAR lx_file_map.
1608   * Update DB Table
1609     MODIFY zbill_file_map FROM TABLE lt_file_map.
1610
1611
1612   ENDFORM.                   " SUB_SAVE_FILE_APP
1613   *&---------------------------------------------------------------------*
1614   *&      Form  DERIVE_COST_CENTER
1615   *&---------------------------------------------------------------------*
1616   *       text
1617   *----------------------------------------------------------------------*
1618   *      <--P_WA_ITEMS  text
1619   *----------------------------------------------------------------------*
1620   * Begin RD1K995140 CAB_ALOK changes in biller direct ZFIBD_PROCE - CR 30011847
1621   FORM DERIVE_COST_CENTER  CHANGING fp_s_items TYPE ty_items.
1622
1623     FIELD-SYMBOLS : <lv_costctr> TYPE kostl.
1624     DATA : lv_field TYPE char20,
1625            lv_idx   TYPE num02.
1626
1627     FIELD-SYMBOLS :
1628                     <lv_wbs1>     TYPE ps_psp_pnr,
1629                     <lv_aufnr1>   TYPE aufnr.
1630     fp_s_items-pernr = wa_pa9205-pernr.
1631   * Get Cost center from infotype 27
1632     LOOP AT gt_pa0027 INTO gs_pa0027 WHERE pernr = fp_s_items-pernr
1633                                      and SUBTY = '01'
1634                                      AND   endda GE fp_s_items-bill_from
1635                                      AND   begda LE fp_s_items-bill_from.
1636       DO.
1637         CLEAR : lv_idx,lv_field.
1638         lv_idx = sy-index.
1639   *         Cost Center
1640         CONCATENATE 'KST' lv_idx INTO lv_field.
1641         UNASSIGN <lv_costctr>.
1642         ASSIGN COMPONENT lv_field OF STRUCTURE gs_pa0027 TO <lv_costctr>.
1643         IF <lv_costctr> IS ASSIGNED AND fp_s_items-kst01 IS INITIAL.
1644           fp_s_items-kst01 = <lv_costctr>.
1645   *{{{ 30014024
1646           IF fp_s_items-kst01 IS INITIAL.
1647             CLEAR : lv_field.
1648   *             WBS Element
1649             CONCATENATE 'PSP' lv_idx INTO lv_field.
1650             UNASSIGN <lv_wbs1>.
1651             ASSIGN COMPONENT lv_field OF STRUCTURE gs_pa0027 TO <lv_wbs1>.
1652             IF <lv_wbs1> IS ASSIGNED.
1653               CALL FUNCTION 'CONVERSION_EXIT_ABPSP_OUTPUT'
1654                 EXPORTING
1655                   input  = <lv_wbs1>
1656                 IMPORTING
1657                   output = fp_s_items-kst01.
1658   *                fp_s_items-kst01 = <lv_wbs>.
1659               IF fp_s_items-kst01 IS INITIAL.
1660                 CLEAR : lv_field.
1661   *                 Internal Order
1662                 CONCATENATE 'AUF' lv_idx INTO lv_field.
1663                 UNASSIGN <lv_aufnr1>.
1664                 ASSIGN COMPONENT lv_field OF STRUCTURE gs_pa0027 TO <lv_aufnr1>.
1665                 IF <lv_aufnr1> IS ASSIGNED.
1666                   fp_s_items-kst01 = <lv_aufnr1>.
1667                 ENDIF.
1668               ENDIF.
1669             ENDIF.
1670           ENDIF.
1671
1672   *}}}30014024 2.3.2016
1673         ELSE.
1674           EXIT.
1675         ENDIF.
1676       ENDDO.
1677
1678       EXIT.
1679     ENDLOOP.
1680
1681   *                    fp_s_items-pernr = wa_pa9205-pernr.
1682   ENDFORM.                    " DERIVE_COST_CENTER
1683   * End RD1K995140 CAB_ALOK changes in biller direct ZFIBD_PROCE - CR 30011847
*--- End of ZBILL_PROCESS_F01 - 1683 lines ---

----------------------------------------------------------------------------------------------------
Include          ZBILL_POST_F01                            Level 1    Page 5
Object           ZBILL_PROCESS                             Lines 7066
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:32
----------------------------------------------------------------------------------------------------
1      *----------------------------------------------------------------------*
2      ***INCLUDE ZBILL_POST_F01.
3      *----------------------------------------------------------------------*
4      *&---------------------------------------------------------------------*
5      *&      Form  DISPLAY_RECORDS
6      *&---------------------------------------------------------------------*
7      *       text
8      *----------------------------------------------------------------------*
9      *  -->  p1        text
10     *  <--  p2        text
11     *----------------------------------------------------------------------*
12         FORM display_records .
13           TYPES: BEGIN OF lty_range,
14           sign(1) TYPE c,
15           option(2) TYPE c,
16           low  TYPE zhrphone,
17           high TYPE zhrphone,
18           END OF lty_range.
19
20           DATA:lv_len TYPE i,
21                 lv_len_mbl TYPE i,
22                 lv_phone10 TYPE char11,
23                 lv_phone11 TYPE char11,
24                 lt_phone_ran TYPE TABLE OF lty_range,
25                 wa_phone_ran TYPE lty_range,
26                 lv_phn_land    TYPE zhrphone,
27                 lv_phone_len   TYPE i,
28                 lv_exp_ln TYPE i.
29
30
31           DATA : lt_phone_exp TYPE TABLE OF selopttab,
32                  wa_phone_exp  TYPE selopttab.
33
34     * Start - RD1K991454
35           DATA : lt_itm_h  TYPE STANDARD TABLE OF ty_items,
36                  lt_pernr  TYPE STANDARD TABLE OF ty_emp_org,
37                  ls_pernr  TYPE ty_emp_org,
38                  ls_itm_h  TYPE ty_items.
39     *             lv_ctotal TYPE zgrs_total.
40
41           FIELD-SYMBOLS : <fs_item> TYPE ty_item1.
42     * End - RD1K991454
43
44     ********************** code added by Bipin shukla : on 19th oct 2013
45           SELECT * FROM zbill_t_status INTO CORRESPONDING FIELDS OF TABLE it_status
46           WHERE tcode = sy-tcode.
47
48           IF it_status[] IS NOT INITIAL.
49             LOOP AT it_status INTO wa_status.
50               wa_stat-sign = 'I'.
51               wa_stat-option = 'EQ'.
52               wa_stat-low = wa_status-status.
53               APPEND wa_stat TO s_stat.
54             ENDLOOP.
55           ENDIF.
56
57           IF status IS NOT INITIAL.
58             LOOP AT status.
59               wa_stat2-sign = 'I'.
60               wa_stat2-option = 'EQ'.
61               wa_stat2-low = status-low.
62               APPEND wa_stat2 TO s_stat2.
63     *      delete S_STAT where low ne STATUS-LOW.
64             ENDLOOP.
65           ENDIF.
66
67     *  IF S_STAT2[] IS NOT INITIAL.
68     *    DELETE S_STAT WHERE LOW NOT IN S_STAT2.
69     *  ENDIF.
70
71
72           SELECT * FROM zbill_head INTO CORRESPONDING FIELDS OF TABLE it_head WHERE
73           bukrs EQ bukrs   AND bill_type EQ bil_type AND reqt_num IN reqt_num
74           AND create_date IN crt_date AND serv_prov IN ser_prov .
75
76     * Start - RD1K991454
77           CLEAR lt_itm_h.
78           IF it_head[] IS NOT INITIAL.
79     *       Fetch Bill Item data
80             IF s_bilper-low IS NOT INITIAL AND s_bilper-high IS NOT INITIAL.
81               SELECT * FROM zbill_data
82                        INTO CORRESPONDING FIELDS OF TABLE it_items
83                        FOR ALL ENTRIES IN it_head
84                        WHERE reqt_num   EQ it_head-reqt_num
85                        AND   zphone     IN s_zphone
86                        AND   conn_numb  IN s_connno
87                        AND   bill_from  >= s_bilper-low
88                        AND   bill_to    <= s_bilper-high
89                        AND   bill_date  IN s_billdt
90                        AND   status     IN s_stat.
91             ELSE.
92               SELECT * FROM zbill_data
93                        INTO CORRESPONDING FIELDS OF TABLE it_items
94                        FOR ALL ENTRIES IN it_head
95                        WHERE reqt_num   EQ it_head-reqt_num
96                        AND   zphone     IN s_zphone
97                        AND   conn_numb  IN s_connno
98                        AND   bill_date  IN s_billdt
99                        AND   status     IN s_stat.
100            ENDIF.
101            IF sy-subrc = 0.
102              lt_itm_h[] = it_items[].
103              SORT lt_itm_h BY reqt_num.
104              DELETE ADJACENT DUPLICATES FROM lt_itm_h COMPARING reqt_num.
105    *           Remove headers which does not exist in Items
106              LOOP AT it_head INTO wa_head.
107                CLEAR ls_itm_h.
108                READ TABLE lt_itm_h INTO ls_itm_h WITH KEY reqt_num = wa_head-reqt_num
109                                                           BINARY SEARCH.
110                IF sy-subrc <> 0.
111                  DELETE TABLE it_head FROM wa_head.
112                ENDIF.
113                CLEAR wa_head.
114              ENDLOOP.
115
116    **         Process items for rounding off difference
117    *          LOOP AT it_items ASSIGNING <fs_items> WHERE grs_total > 0.
118    *            CLEAR : lv_ctotal.
119    **           Calculated total
120    *            lv_ctotal = <fs_items>-rent        +
121    *                        <fs_items>-call_charge +
122    *                        <fs_items>-oth_charges +
123    *                        <fs_items>-service_tax .
124    *
125    **           Post rounding difference to CALL_CHARGE(Variable charges)
126    *            <fs_items>-call_charge = <fs_items>-call_charge +
127    *                                    ( <fs_items>-grs_total - lv_ctotal ).
128    *          ENDLOOP.
129
130            ENDIF.
131          ENDIF.
132    * End - RD1K991454
133
134          IF it_head[] IS INITIAL.
135            IF sy-tcode = 'ZFIBD_REPORT'.
136              MESSAGE e011(zbill).
137            ELSE.
138              MESSAGE e008(zbill) WITH reqt_num-low.
139            ENDIF.
140          ELSE.
141    *        SELECT * FROM zbill_data INTO CORRESPONDING FIELDS OF TABLE it_items
142    *        FOR ALL ENTRIES IN it_head
143    *        WHERE reqt_num EQ it_head-reqt_num
144    *        AND status IN s_stat.
145
146            SELECT * FROM zbill_field_map INTO CORRESPONDING FIELDS OF TABLE it_check
147            FOR ALL ENTRIES IN it_head
148            WHERE bukrs         EQ it_head-bukrs
149            AND   serv_provider EQ it_head-serv_prov.
150          ENDIF.
151    ********************** code added by Bipin shukla : on 19th oct 2013
152          IF s_stat2 IS NOT INITIAL.
153            DELETE it_items WHERE status NOT IN s_stat2.
154          ENDIF.
155
156
157
158    *******************************  Changes by Bipin Shukla for Cost Center : 18th Oct 2013
159
160          SELECT * FROM zbill_mast INTO CORRESPONDING FIELDS OF TABLE it_mast.
161          IF it_items IS NOT INITIAL.  " AND BIL_TYPE = '4'.
162
163            it_items_phn = it_items.
164
165            ASSIGN lv_null TO <gfs_null> CASTING TYPE c.
166            MOVE <gfs_null>(2) TO lv_nullc.
167
168            LOOP AT it_items_phn INTO wa_items.
169              SHIFT wa_items-zphone LEFT DELETING LEADING lv_nullc.
170              lv_len = strlen( wa_items-zphone ).
171              IF lv_len = 13.
172                wa_items-zphone = '0' && wa_items-zphone+3(10).
173              ELSEIF lv_len = 12.
174                wa_items-zphone = '0' && wa_items-zphone+2(10).
175              ELSEIF lv_len = 11.
176                wa_items-zphone = '0' && wa_items-zphone+1(10).
177              ELSEIF lv_len = 10.
178                wa_items-zphone = '0' && wa_items-zphone(10).
179              ELSE.
180                CONTINUE.
181              ENDIF.
182              MODIFY it_items_phn FROM wa_items INDEX sy-tabix.
183            ENDLOOP.
184    ****** Logic of 10 digit reading for mobile number from exception table **********
185
186
187            it_items_phn_mbl = it_items.
188
189            ASSIGN lv_null_mbl TO <gfs_null_mbl> CASTING TYPE c.
190            MOVE <gfs_null_mbl>(2) TO lv_nullc_mbl.
191
192            LOOP AT it_items_phn_mbl INTO wa_items.
193              SHIFT wa_items-zphone LEFT DELETING LEADING lv_nullc_mbl.
194              lv_len_mbl = strlen( wa_items-zphone ).
195              IF lv_len_mbl = 13.
196                wa_items-zphone = '*' && wa_items-zphone+3(10) && '*'.
197              ELSEIF lv_len_mbl = 12.
198                wa_items-zphone = '*' && wa_items-zphone+2(10) && '*'.
199              ELSEIF lv_len_mbl = 11.
200                wa_items-zphone = '*' && wa_items-zphone+1(10) && '*'.
201              ELSEIF lv_len_mbl = 10.
202                wa_items-zphone = '*' && wa_items-zphone(10) && '*'.
203              ELSE.
204                CONTINUE.
205              ENDIF.
206              MODIFY it_items_phn_mbl FROM wa_items INDEX sy-tabix.
207            ENDLOOP.
208
209            IF it_items_phn_mbl[] IS NOT INITIAL.
210
211              LOOP AT it_items_phn_mbl INTO wa_items_phn_mbl.
212                wa_phone_exp-sign = 'I'.
213                wa_phone_exp-option = 'CP'.
214                wa_phone_exp-low = wa_items_phn_mbl-zphone.
215                APPEND wa_phone_exp TO lt_phone_exp.
216
217              ENDLOOP.
218              CLEAR : wa_phone_exp,wa_items_phn_mbl.
219
220            ENDIF.
221
222
223
224
225    ****** Logic of 10 digit reading for mobile number from exception table **********
226
227
228    * Begin of changes by vikas on 20-12-2013
229            IF bil_type = '3' OR
230            bil_type = '4'.
231              IF it_items_phn[] IS NOT INITIAL.
232                LOOP AT it_items_phn[] INTO wa_items_phn.
233    *          wa_items_phn-zphone = '%' && wa_items_phn-zphone.
234    *          APPEND wa_items_phn TO it_items_phn_lan.
235                  wa_phone_ran-sign = 'I'.
236                  lv_phone_len = strlen( wa_items_phn-zphone ).
237                  IF lv_phone_len LT 11.
238                    wa_phone_ran-option = 'CP'.
239                    wa_phone_ran-low = '*' && wa_items_phn-zphone.
240                  ELSE.
241                    wa_phone_ran-option = 'EQ'.
242                    wa_phone_ran-low = wa_items_phn-zphone.
243
244                  ENDIF.
245                  APPEND wa_phone_ran TO lt_phone_ran.
246                ENDLOOP.
247
248    * Begin RD1K996580 CAB_ALOK CHANGES IN BILLER DIRECT - CR 30012490
249                SELECT * FROM pa9205 INTO
250    *          INTO CORRESPONDING FIELDS OF
251                TABLE it_pa9205
252    *          FOR ALL ENTRIES IN it_items_phn
253                WHERE  zphone IN lt_phone_ran AND
254                ( subty = '03' OR
255                subty = '04' OR
256                subty = '05' ).
257
258    **  if  bil_type <> '4'.
259    **         SELECT * FROM pa9205 INTO
260    ***          INTO CORRESPONDING FIELDS OF
261    **            TABLE it_pa9205
262    ***          FOR ALL ENTRIES IN it_items_phn
263    **            WHERE  zphone IN lt_phone_ran AND
264    **            ( subty = '03' OR
265    **             subty = '05' ).
266    **
267    **  endif.
268    * End RD1K996580 CAB_ALOK CHANGES IN BILLER DIRECT - CR 30012490
269
270    ****Start of Addition 08.07.2014 CR No: 30011389 CAB_SILA
271                CLEAR : It_mob_dir .
272                SELECT * FROM ZHR_MOBILE_DIR
273                    APPENDING CORRESPONDING FIELDS OF TABLE It_mob_dir
274                    WHERE  zphone IN lt_phone_ran
275    ** Begin RD1K996580 CAB_ALOK CHANGES IN BILLER DIRECT - CR 30012490
276    *                  AND Endda >= sy-datum
277    *                  And Begda <= sy-datum
278    ** End RD1K996580 CAB_ALOK CHANGES IN BILLER DIRECT - CR 30012490
279                       .
280
281                LOOP AT It_mob_dir INTO Wa_mob_dir  .
282                  MOVE-CORRESPONDING Wa_mob_dir to Wa1_9205 .
283                  APPEND Wa1_9205 to It_pa9205 .
284                ENDLOOP.
285    ****End of Addition CR No: 30011389
286    *           AND
287    *                 endda GE it_items_phn-bill_from AND
288    *                 begda LE it_items_phn-bill_from .
289                IF sy-subrc EQ 0.
290                  LOOP AT it_items_phn INTO wa_items.
291                    lv_phone_len = strlen( wa_items_phn-zphone ).
292                    IF lv_phone_len LT 11.
293                      lv_phn_land = '*' && wa_items-zphone.
294                      IF wa_items-bill_from IS NOT INITIAL.
295                        LOOP AT it_pa9205 INTO wa_pa9205
296                        WHERE zphone CP lv_phn_land.
297                          IF wa_pa9205-endda GE wa_items-bill_from AND
298                          wa_pa9205-begda LE wa_items-bill_from.
299                          ELSE.
300                            DELETE TABLE it_pa9205 FROM wa_pa9205 .
301                          ENDIF.
302                        ENDLOOP.
303                      ENDIF.
304                    ELSE.
305                      IF wa_items-bill_from IS NOT INITIAL.
306
307                        LOOP AT it_pa9205 INTO wa_pa9205
308                        WHERE zphone EQ wa_items_phn-zphone.
309                          IF wa_pa9205-endda GE wa_items-bill_from AND
310                          wa_pa9205-begda LE wa_items-bill_from.
311                          ELSE.
312                            DELETE TABLE  it_pa9205 FROM wa_pa9205.
313                          ENDIF.
314                        ENDLOOP.
315                      ENDIF.
316                    ENDIF.
317                  ENDLOOP.
318
319    *         RD1K991454
320                  SORT it_pa9205 BY zphone endda DESCENDING begda DESCENDING.
321                  DELETE ADJACENT DUPLICATES FROM it_pa9205 COMPARING zphone. " endda.
322    *         RD1K991454
323
324
325
326                  SORT it_pa9205 BY pernr endda begda DESCENDING.
327                  DELETE ADJACENT DUPLICATES FROM it_pa9205 COMPARING pernr endda begda.
328
329                  SELECT * FROM pa0001
330                  INTO TABLE it_pa0001
331                  FOR ALL ENTRIES IN it_pa9205
332                  WHERE pernr = it_pa9205-pernr AND
333                  endda GE it_pa9205-endda AND
334                  begda LE it_pa9205-begda .
335                ENDIF.
336              ENDIF.
337            ELSE.
338    * End of changes by vikas on 20-12-2013
339              IF it_items_phn[] IS NOT INITIAL.
340                SELECT * FROM pa9205 INTO CORRESPONDING FIELDS OF TABLE it_pa9205
341                FOR ALL ENTRIES IN it_items_phn WHERE  ( zphone = it_items_phn-zphone(11) OR
342                zphone = it_items_phn-zphone+1(11) ) AND
343                endda GE it_items_phn-bill_from AND
344                begda LE it_items_phn-bill_from . "AND SUBTY EQ '01'.
345    *                                          endda GE sy-datum AND
346    *                                          begda LE sy-datum . "AND SUBTY EQ '01'.
347
348
349    ****Start of Addition 08.07.2014 CR No: 30011389 CAB_SILA
350                CLEAR : It_mob_dir .
351    *            SELECT * FROM ZHR_MOBILE_DIR
352    *                APPENDING CORRESPONDING FIELDS OF TABLE It_mob_dir .
353                SELECT * FROM ZHR_MOBILE_DIR
354                    APPENDING CORRESPONDING FIELDS OF TABLE It_mob_dir
355                  FOR ALL ENTRIES IN it_items_phn WHERE  ( zphone = it_items_phn-zphone(11) OR
356                  zphone = it_items_phn-zphone+1(11) ) AND
357                  endda GE it_items_phn-bill_from AND
358                  begda LE it_items_phn-bill_from .
359                LOOP AT It_mob_dir INTO Wa_mob_dir  .
360                  MOVE-CORRESPONDING Wa_mob_dir to Wa1_9205 .
361                  APPEND Wa1_9205 to It_pa9205 .
362                ENDLOOP.
363    ****End of Addition CR No: 30011389
364
365              ENDIF.
366    *         RD1K991454
367              SORT it_pa9205 BY zphone endda DESCENDING begda DESCENDING.
368              DELETE ADJACENT DUPLICATES FROM it_pa9205 COMPARING zphone. " endda.
369    *         RD1K991454
370
371              SORT it_pa9205 BY zphone begda DESCENDING. " ASCENDING.
372    * Begin of changes by vikas on 20-12-2013
373            ENDIF.
374    * End of changes by vikas on 20-12-2013
375
376          ENDIF.
377          IF it_pa9205 IS NOT INITIAL.
378            SELECT * FROM pa0002 INTO CORRESPONDING FIELDS OF TABLE it_pa0002 FOR ALL ENTRIES IN it_pa9205
379            WHERE pernr = it_pa9205-pernr ."AND ENDDA GE SY-DATUM AND BEGDA LE SY-DATUM.
380    ****************************** + by bipin ro pick cost center from infotype 9351 on 20/01/2014
381    *        SELECT * FROM pa9351 INTO CORRESPONDING FIELDS OF TABLE it_pa9351
382    *        FOR ALL ENTRIES IN it_pa9205
383    *        WHERE pernr = it_pa9205-pernr.
384
385    *       Fetch infotype 27 to get cost center
386            SELECT *  FROM pa0027
387                      INTO CORRESPONDING FIELDS OF TABLE gt_pa0027
388                      FOR ALL ENTRIES IN it_pa9205
389                      WHERE pernr = it_pa9205-pernr
390                      AND   subty = '01' "Wage/salary
391                      AND   sprps <> abap_true.
392
393            SORT gt_pa0027 BY pernr endda DESCENDING begda DESCENDING.
394    ******************************* + by bipin ro pick cost center from infotype 9351 on 20/01/2014
395          ENDIF.
396
397
398
399
400          DELETE it_check WHERE  primary_field IS INITIAL.
401
402          IF sy-subrc EQ 0.
403
404            LOOP AT it_check INTO wa_check.
405
406              wa_stat1-sign = 'I'.
407              wa_stat1-option = 'EQ'.
408              wa_stat1-low = wa_check-int_field.
409              APPEND wa_stat1 TO s_stat1.
410
411            ENDLOOP.
412
413          ENDIF.
414
415          SELECT * FROM csks INTO CORRESPONDING FIELDS OF TABLE gt_csks.
416
417    * Code Added by ROhit Agrawal
418          DATA : lt_zbill_exception TYPE STANDARD TABLE OF zbill_exception,
419                ls_zbill_exception TYPE zbill_exception.
420    *            lt_zbill_exception_lan TYPE STANDARD TABLE OF zbill_exception,
421    *            ls_zbill_exception_lan TYPE zbill_exception,
422    *            lt_zbill_excep TYPE STANDARD TABLE OF zbill_exception.
423
424
425    * Added by ujjaval - Start - RD1K991454
426          SELECT * FROM zbill_exception INTO TABLE lt_zbill_exception.
427          IF sy-subrc = 0.
428            SORT lt_zbill_exception by zphone.
429          ENDIF.
430
431    *      CLEAR lt_zbill_excep.
432    *      SELECT * FROM zbill_exception INTO TABLE lt_zbill_excep.
433    *      IF lt_phone_exp[] IS NOT INITIAL.
434    *        LOOP AT lt_zbill_excep INTO ls_zbill_exception WHERE zphone IN lt_phone_exp.
435    *          APPEND ls_zbill_exception TO lt_zbill_exception.
436    *          CLEAR ls_zbill_exception.
437    *        ENDLOOP.
438    *      ENDIF.
439    *
440    *      IF lt_phone_ran[] IS NOT INITIAL.
441    *        LOOP AT lt_zbill_excep INTO ls_zbill_exception WHERE zphone IN lt_phone_ran.
442    *          APPEND ls_zbill_exception TO lt_zbill_exception.
443    *          CLEAR ls_zbill_exception.
444    *        ENDLOOP.
445    *      ENDIF.
446    *
447    *      IF lt_phone_exp[] IS NOT INITIAL.
448    *        SELECT * FROM zbill_exception INTO TABLE lt_zbill_exception
449    **        FOR ALL ENTRIES IN LT_PHONE_EXP
450    *        WHERE zphone IN lt_phone_exp.
451    *      ENDIF.
452
453    *      IF lt_phone_ran[] IS NOT INITIAL.
454    *        SELECT * FROM zbill_exception INTO TABLE lt_zbill_exception_lan
455    *       WHERE zphone IN lt_phone_ran .
456    *      ENDIF.
457    *      APPEND LINES OF lt_zbill_exception_lan TO lt_zbill_exception.
458
459    * Added by ujjaval - End - RD1K991454
460
461    ****************  GET FULL NAME OF DOMAIN
462          CALL FUNCTION 'DDIF_DOMA_GET'
463          EXPORTING
464            name               = 'ZBILL_STATUS'
465            state               = 'A'
466            langu               = 'E'
467    *     IMPORTING
468    *       GOTSTATE            =
469    *       DD01V_WA            =
470          TABLES
471            dd07v_tab           = it_dom
472          EXCEPTIONS
473            illegal_input       = 1
474            OTHERS              = 2
475            .
476          IF sy-subrc <> 0.
477    * Implement suitable error handling here
478          ENDIF.
479
480
481
482    *      SORT IT_PA9351 BY PERNR ENDDA BEGDA DESCENDING.
483          LOOP AT it_items INTO wa_items .
484
485            SHIFT wa_items-zphone LEFT DELETING LEADING lv_nullc.
486            lv_len = strlen( wa_items-zphone ).
487
488            IF lv_len = 10.
489              lv_phone11 = '0' && wa_items-zphone(10).
490              lv_phone10 = wa_items-zphone(10).
491            ELSEIF lv_len = 11.
492              lv_phone11 = wa_items-zphone(11).
493              lv_phone10 = wa_items-zphone+1(10).
494            ELSEIF lv_len = 12.
495              lv_phone11 = '0' && wa_items-zphone+2(10).
496              lv_phone10 = wa_items-zphone+2(10).
497            ELSEIF lv_len = 13.
498              lv_phone11 = '0' && wa_items-zphone+3(10).
499              lv_phone10 = wa_items-zphone+3(10).
500
501            ENDIF.
502
503            READ TABLE it_head INTO wa_head WITH KEY reqt_num = wa_items-reqt_num.
504
505            IF sy-subrc = 0.
506              wa_items-bill_type = wa_head-bill_type.
507              wa_items-create_date = wa_head-create_date.
508
509
510              CASE wa_head-bill_type.
511                WHEN   '4' OR '5'.
512                  READ TABLE it_mast INTO wa_mast WITH KEY zphone = wa_items-zphone.
513                  IF sy-subrc = 0.
514                    wa_items-kst01 = wa_mast-kst01.
515    *            WA_ITEMS-BILL_TYPE = WA_HEAD-BILL_TYPE.
516    *            WA_ITEMS-CREATE_DATE = WA_HEAD-CREATE_DATE.
517                  ELSE.
518    *Begin of changes by vikas on 20-12-2013
519                    IF wa_head-bill_type = '4'.
520                      lv_phone_len = strlen( wa_items-zphone ).
521                      IF lv_phone_len LT 11.
522                        lv_phn_land = '*' && wa_items-zphone.
523                        LOOP AT it_pa9205 INTO wa_pa9205
524                        WHERE zphone CP lv_phn_land.
525                          READ TABLE it_pa0001 INTO wa_pa0001 WITH KEY pernr = wa_pa9205-pernr.
526                          IF sy-subrc EQ 0.
527                            IF wa_pa0001-bukrs NE bukrs.
528    *                    CONTINUE.
529                            ENDIF.
530
531                          ENDIF.
532    *                      WA_ITEMS-KST01 = WA_PA9205-KST01. " Commented by bipin on 26/12/2013
533    ****************************** + by bipin ro pick cost center from infotype 9351 on 26/12/2013
534    *                      LOOP AT it_pa9351 INTO wa_pa9351 WHERE pernr = wa_items-pernr.
535    *                        IF wa_pa9351-endda GT wa_items-bill_from AND wa_pa9351-begda LE wa_items-bill_from.
536    *                          wa_items-kst01 = wa_pa9351-kostl.
537    *                        ENDIF.
538    *                      ENDLOOP.
539
540                          wa_items-pernr = wa_pa9205-pernr.
541                          wa_items-subty = wa_pa9205-subty.
542                          CLEAR wa_pa0002.
543                          READ TABLE it_pa0002 INTO wa_pa0002 WITH KEY pernr = wa_pa9205-pernr.
544                          IF sy-subrc EQ 0.
545                            CLEAR lv_urname.
546                            CONCATENATE  wa_pa0002-vorna wa_pa0002-nachn INTO lv_urname SEPARATED BY space.
547                            wa_items-name = lv_urname.
548                          ENDIF.
549
550
551    *                     Get Cost center
552                          PERFORM f_get_cost_center CHANGING wa_items.
553
554    ****************************** + by bipin ro pick cost center from infotype 9351 on 26/12/2013 : end of code
555                        ENDLOOP.
556                      ELSE.
557                        LOOP AT it_pa9205 INTO wa_pa9205
558                        WHERE zphone EQ wa_items-zphone.
559                          READ TABLE it_pa0001 INTO wa_pa0001 WITH KEY pernr = wa_pa9205-pernr.
560                          IF sy-subrc EQ 0.
561                            IF wa_pa0001-bukrs NE bukrs.
562    *                    CONTINUE.
563                            ENDIF.
564
565                          ENDIF.
566    *                      WA_ITEMS-KST01 = WA_PA9205-KST01. " Commented by bipin on 26/12/2013
567    ****************************** + by bipin ro pick cost center from infotype 9351 on 26/12/2013
568    *                      LOOP AT it_pa9351 INTO wa_pa9351 WHERE pernr = wa_items-pernr.
569    *                        IF wa_pa9351-endda GT wa_items-bill_from AND wa_pa9351-begda LE wa_items-bill_from.
570    *                          wa_items-kst01 = wa_pa9351-kostl.
571    *                        ENDIF.
572    *                      ENDLOOP.
573
574                          wa_items-pernr = wa_pa9205-pernr.
575                          wa_items-subty = wa_pa9205-subty.
576                          CLEAR wa_pa0002.
577                          READ TABLE it_pa0002 INTO wa_pa0002 WITH KEY pernr = wa_pa9205-pernr.
578                          IF sy-subrc EQ 0.
579                            CLEAR lv_urname.
580                            CONCATENATE  wa_pa0002-vorna wa_pa0002-nachn INTO lv_urname SEPARATED BY space.
581                            wa_items-name = lv_urname.
582                          ENDIF.
583
584
585    *                     Get Cost center
586                          PERFORM f_get_cost_center CHANGING wa_items.
587    ****************************** + by bipin ro pick cost center from infotype 9351 on 26/12/2013 : end of code
588                        ENDLOOP.
589                      ENDIF.
590
591                    ELSE.
592    *End of changes by vikas on 20-12-2013
593                      READ TABLE it_pa9205 INTO wa_pa9205 WITH KEY zphone = lv_phone11."wa_items-zphone.
594                      IF sy-subrc = 0.
595    *                    WA_ITEMS-KST01 = WA_PA9205-KST01. " Commented by bipin on 26/12/2013
596
597    ****************************** + by bipin ro pick cost center from infotype 9351 on 26/12/2013
598    *                    LOOP AT it_pa9351 INTO wa_pa9351 WHERE pernr = wa_items-pernr.
599    *                      IF wa_pa9351-endda GT wa_items-bill_from AND wa_pa9351-begda LE wa_items-bill_from.
600    *                        wa_items-kst01 = wa_pa9351-kostl.
601    *                      ENDIF.
602    *                    ENDLOOP.
603
604                        wa_items-pernr = wa_pa9205-pernr.
605                        wa_items-subty = wa_pa9205-subty.
606                        CLEAR wa_pa0002.
607                        READ TABLE it_pa0002 INTO wa_pa0002 WITH KEY pernr = wa_pa9205-pernr.
608                        IF sy-subrc EQ 0.
609                          CLEAR lv_urname.
610                          CONCATENATE  wa_pa0002-vorna wa_pa0002-nachn INTO lv_urname SEPARATED BY space.
611                          wa_items-name = lv_urname.
612                        ENDIF.
613
614
615    *                     Get Cost center
616                        PERFORM f_get_cost_center CHANGING wa_items.
617
618    ****************************** + by bipin ro pick cost center from infotype 9351 on 26/12/2013 : end of code
619                      ELSE.
620                        READ TABLE it_pa9205 INTO wa_pa9205 WITH KEY zphone = lv_phone10 .
621                        IF sy-subrc = 0.
622    *                      WA_ITEMS-KST01 = WA_PA9205-KST01. " Commented by bipin on 26/12/2013
623    ****************************** + by bipin ro pick cost center from infotype 9351 on 26/12/2013
624    *                      LOOP AT it_pa9351 INTO wa_pa9351 WHERE pernr = wa_items-pernr.
625    *                        IF wa_pa9351-endda GT wa_items-bill_from AND wa_pa9351-begda LE wa_items-bill_from.
626    *                          wa_items-kst01 = wa_pa9351-kostl.
627    *                        ENDIF.
628    *                      ENDLOOP.
629
630                          wa_items-pernr = wa_pa9205-pernr.
631                          wa_items-subty = wa_pa9205-subty.
632                          CLEAR wa_pa0002.
633                          READ TABLE it_pa0002 INTO wa_pa0002 WITH KEY pernr = wa_pa9205-pernr.
634                          IF sy-subrc EQ 0.
635                            CLEAR lv_urname.
636                            CONCATENATE  wa_pa0002-vorna wa_pa0002-nachn INTO lv_urname SEPARATED BY space.
637                            wa_items-name = lv_urname.
638                          ENDIF.
639
640    *                     Get Cost center
641                          PERFORM f_get_cost_center CHANGING wa_items.
642
643    ****************************** + by bipin ro pick cost center from infotype 9351 on 26/12/2013 : end of code
644                        ENDIF.
645                      ENDIF.
646                    ENDIF.
647                  ENDIF.
648                  MODIFY it_items FROM wa_items TRANSPORTING kst01 bill_type create_date WHERE zphone = wa_items-zphone.
649    */..Begin of Change CR :30013178
650    *            WHEN '1' OR '2' OR '3' .
651                WHEN '1' OR '2' OR '3' or '6'.
652    */..End of Change CR :30013178
653                  IF wa_head-bill_type EQ '3'.
654
655    *Begin of changes by vikas on 20-12-2013
656                    lv_phone_len = strlen( wa_items-zphone ).
657                    IF lv_phone_len LT 11.
658
659                      lv_phn_land = '*' && wa_items-zphone.
660                      LOOP AT it_pa9205 INTO wa_pa9205
661                      WHERE zphone CP lv_phn_land.
662                        READ TABLE it_pa0001 INTO wa_pa0001 WITH KEY pernr = wa_pa9205-pernr.
663                        IF sy-subrc EQ 0.
664                          IF wa_pa0001-bukrs NE bukrs.
665    *                  CONTINUE.
666                          ENDIF.
667
668                        ENDIF.
669    *              wa_items-kst01 = wa_pa9205-kst01.
670    * Begin RD1K995140 CAB_ALOK changes in biller direct ZFIBD_PROCE - CR 30011847
671    *                    wa_items-pernr = wa_pa9205-pernr.
672
673                        PERFORM derive_cost_center CHANGING wa_items.
674
675    * End RD1K995140 CAB_ALOK changes in biller direct ZFIBD_PROCE - CR 30011847
676
677
678                      ENDLOOP.
679                    ELSE.
680                      LOOP AT it_pa9205 INTO wa_pa9205
681                      WHERE zphone EQ wa_items-zphone.
682                        READ TABLE it_pa0001 INTO wa_pa0001
683                        WITH KEY pernr = wa_pa9205-pernr.
684                        IF sy-subrc EQ 0.
685                          IF wa_pa0001-bukrs NE bukrs.
686    *                  CONTINUE.
687                          ENDIF.
688
689                        ENDIF.
690    *              wa_items-kst01 = wa_pa9205-kst01.
691    * Begin RD1K995140 CAB_ALOK changes in biller direct ZFIBD_PROCE - CR 30011847
692                        clear  WA_PA9205_l.
693                        loop at it_pa9205 into WA_PA9205_l
694                        where begda <= wa_items-bill_from
695                          and endda >= wa_items-bill_from
696    *{ CAB_RAMA 24.02.2016 30013556
697                          AND zphone EQ wa_items-zphone .
698
699    *} CAB_RAMA 24.02.2016 30013556
700                        endloop.
701    **/..Begin of Change CR :30013556
702    *                    loop at it_pa9205 into WA_PA9205_l
703    *                    where zphone EQ wa_items-zphone
704    *                      and begda <= wa_items-bill_from
705    *                      and endda >= wa_items-bill_from.
706    *                    endloop.
707    **/..End of Change CR :30013556
708                        wa_items-pernr = wa_pa9205_l-pernr.
709
710    *                    wa_items-pernr = wa_pa9205-pernr.
711                        PERFORM derive_cost_center CHANGING wa_items.
712    * End RD1K995140 CAB_ALOK changes in biller direct ZFIBD_PROCE - CR 30011847
713
714                      ENDLOOP.
715
716                    ENDIF.
717                  ELSE.
718    ********************************************                code comment by Bipin on 07/01/2013
719    *End of changes by vikas on 20-12-2013
720    *                READ TABLE IT_PA9205 INTO WA_PA9205 WITH KEY ZPHONE = LV_PHONE11."wa_items-zphone.
721    *                IF SY-SUBRC NE 0.
722    *                  READ TABLE IT_PA9205 INTO WA_PA9205 WITH KEY ZPHONE = LV_PHONE10.
723    *                ENDIF.
724    *Begin of changes by vikas on 20-12-2013
725    ********************************************                code comment by Bipin on 07/01/2013
726    ********************************************                + by Bipin on 07/01/2013
727                    LOOP AT it_pa9205 INTO wa_pa9205. "AND ENDDA GT WA_ITEM2-BILL_FROM AND BEGDA LE WA_ITEM2-BILL_FROM.
728                      IF wa_pa9205-zphone = lv_phone11.
729                        IF wa_pa9205-endda GT wa_items-bill_from AND wa_pa9205-begda LE wa_items-bill_from.
730
731                          READ TABLE it_pa0002 INTO wa_pa0002 WITH KEY pernr = wa_pa9205-pernr.
732                          IF sy-subrc EQ 0.
733                            CONCATENATE  wa_pa0002-vorna wa_pa0002-nachn INTO lv_urname SEPARATED BY space.
734    *                        WA_ITEMS-KST01 = WA_PA9205-KST01. " Code commented by bipin on 20/01/2014
735                            wa_items-pernr = wa_pa9205-pernr.
736                            wa_items-subty = wa_pa9205-subty.
737                            wa_items-name = lv_urname.
738
739                          ELSE.
740
741                            READ TABLE it_mast INTO wa_mast WITH KEY zphone = wa_items-zphone.
742                            IF sy-subrc = 0.
743                              wa_items-kst01 = wa_mast-kst01.
744                            ENDIF.
745                          ENDIF.
746
747                        ENDIF.
748                      ELSEIF wa_pa9205-zphone = lv_phone10.
749                        IF wa_pa9205-endda GT wa_items-bill_from AND wa_pa9205-begda LE wa_items-bill_from.
750
751                          READ TABLE it_pa0002 INTO wa_pa0002 WITH KEY pernr = wa_pa9205-pernr.
752                          IF sy-subrc EQ 0.
753                            CONCATENATE  wa_pa0002-vorna wa_pa0002-nachn INTO lv_urname SEPARATED BY space.
754    *                        WA_ITEMS-KST01 = WA_PA9205-KST01. " Code commented by bipin on 20/01/2014
755                            wa_items-pernr = wa_pa9205-pernr.
756                            wa_items-subty = wa_pa9205-subty.
757                            wa_items-name = lv_urname.
758
759                          ELSE.
760                            READ TABLE it_mast INTO wa_mast WITH KEY zphone = wa_items-zphone.
761                            IF sy-subrc = 0.
762                              wa_items-kst01 = wa_mast-kst01.
763                            ENDIF.
764                          ENDIF.
765                        ENDIF.
766
767                      ENDIF.
768
769                    ENDLOOP.
770    *              ENDIF.   "Code commented by bipin on 20/01/2014
771    *********************************
772    ******************************* + by bipin ro pick cost center from infotype 9351 on 26/12/2013
773
774    *                READ TABLE IT_PA9351 INTO WA_PA9351 WITH KEY PERNR = WA_PA9205-PERNR.
775    *                IF SY-SUBRC EQ 0.
776    *                  WA_ITEMS-KST01 = WA_PA9351-KOSTL.
777    *                ENDIF.
778    *              ENDIF.
779
780    *                LOOP AT it_pa9351 INTO wa_pa9351 WHERE pernr = wa_items-pernr.
781    *                  IF wa_pa9351-endda GT wa_items-bill_from AND wa_pa9351-begda LE wa_items-bill_from.
782    *                    wa_items-kst01 = wa_pa9351-kostl.
783    *                  ENDIF.
784    *                ENDLOOP.
785
786    *                     Get Cost center
787                    PERFORM f_get_cost_center CHANGING wa_items.
788
789                  ENDIF.
790    ******************************* + by bipin ro pick cost center from infotype 9351 on 26/12/2013 : end of code
791    *                CONCATENATE  WA_PA0002-VORNA WA_PA0002-NACHN INTO LV_URNAME SEPARATED BY SPACE.
792    *                WA_ITEMS-KST01 = WA_PA9205-KST01. " Code commented by bipin on 26/12/2013
793    *                WA_ITEMS-PERNR = WA_PA9205-PERNR.
794    *                WA_ITEMS-SUBTY = WA_PA9205-SUBTY.
795    **            WA_ITEMS-ZAMT = WA_PA9205-ZAMT.
796    *                WA_ITEMS-NAME = LV_URNAME.
797    **            wa_items-bill_type = wa_head-bill_type.
798    **            wa_items-create_date = wa_head-create_date.
799    *
800    *              ELSE.
801    *                READ TABLE IT_MAST INTO WA_MAST WITH KEY ZPHONE = WA_ITEMS-ZPHONE.
802    *                IF SY-SUBRC = 0.
803    *                  WA_ITEMS-KST01 = WA_MAST-KST01.
804    *                ENDIF.
805    *              ENDIF.
806    ********************************************                code comment by Bipin on 07/01/2013
807
808
809
810
811    * Added by Rohit Agrawal
812                  IF  wa_items-kst01 IS INITIAL.
813                    lv_exp_ln = strlen( wa_items-zphone ).
814                    IF lv_exp_ln = 13.
815                      CLEAR: ls_zbill_exception.
816                      READ TABLE lt_zbill_exception INTO ls_zbill_exception WITH KEY zphone  = wa_items-zphone+3(10)
817                                                                            BINARY SEARCH.
818                      IF sy-subrc EQ 0.
819                        wa_items-kst01 = ls_zbill_exception-kst01.
820                        wa_items-pernr = ls_zbill_exception-pernr.
821                      ENDIF.
822                    ELSEIF lv_exp_ln = 12.
823                      READ TABLE lt_zbill_exception INTO ls_zbill_exception WITH KEY zphone  = wa_items-zphone+2(10)
824                                                                            BINARY SEARCH.
825                      IF sy-subrc EQ 0.
826                        wa_items-kst01 = ls_zbill_exception-kst01.
827                        wa_items-pernr = ls_zbill_exception-pernr.
828                      ENDIF.
829                    ELSEIF lv_exp_ln = 11.
830                      READ TABLE lt_zbill_exception INTO ls_zbill_exception WITH KEY zphone  = wa_items-zphone+1(10)
831                                                                            BINARY SEARCH.
832                      IF sy-subrc EQ 0.
833                        wa_items-kst01 = ls_zbill_exception-kst01.
834                        wa_items-pernr = ls_zbill_exception-pernr.
835                      ENDIF.
836                    ELSEIF lv_exp_ln = 10.
837                      READ TABLE lt_zbill_exception INTO ls_zbill_exception WITH KEY zphone  = wa_items-zphone
838                                                                            BINARY SEARCH.
839                      IF sy-subrc EQ 0.
840                        wa_items-kst01 = ls_zbill_exception-kst01.
841                        wa_items-pernr = ls_zbill_exception-pernr.
842                      ENDIF.
843
844                    ENDIF.
845                  ENDIF.
846    * End by Rohit Agrawal
847
848
849                  MODIFY it_items FROM wa_items TRANSPORTING kst01 pernr bill_type create_date name WHERE zphone = wa_items-zphone.
850
851
852                WHEN OTHERS.
853              ENDCASE.
854            ENDIF.
855
856    ********************    GET FULL NAME OF DOMAIN
857
858            READ TABLE it_dom INTO wa_dom WITH KEY domvalue_l = wa_items-status.
859            IF sy-subrc EQ 0.
860              CONCATENATE wa_items-status '-' wa_dom-ddtext INTO wa_items-status SEPARATED BY space.
861            ENDIF.
862
863
864
865            MODIFY it_items FROM wa_items TRANSPORTING status.
866    ********************    GET FULL NAME OF DOMAIN
867    *************************************** CODE OF SECOND LOOP
868            IF wa_items-kst01 IS NOT INITIAL.
869              wa_items-check = 'X'.
870              wa_items-check1 = ''.
871            ENDIF.
872
873            IF wa_items-status = '3 - Rejected by Level 1' OR wa_items-status = '5 - Rejected by finance'.
874              wa_items-check = ''.
875              wa_items-check1 = 'X'.
876            ENDIF.
877            MODIFY it_items FROM wa_items TRANSPORTING check check1.
878    *************************************** CODE OF SECOND LOOP
879
880
881    ************************************************* CODE OF THIRD LOOP
882            REFRESH wa_item1-style[].
883    ****************************************** code added by Bipin Shukla : 23/12/2013  : for approve ammount
884            IF wa_items-rent_final IS INITIAL.
885              IF ( wa_items-remarks IS INITIAL AND wa_items-sec_remarks IS  INITIAL ).
886                wa_items-rent_final = wa_items-rent.
887              ENDIF.
888            ENDIF.
889
890            IF wa_items-call_charges_final IS INITIAL.
891              IF ( wa_items-remarks IS INITIAL AND wa_items-sec_remarks IS INITIAL ).
892                wa_items-call_charges_final = wa_items-call_charge.
893              ENDIF.
894            ENDIF.
895
896            IF wa_items-oth_charges_fin IS INITIAL.
897              IF ( wa_items-remarks IS INITIAL AND wa_items-sec_remarks IS INITIAL ).
898                wa_items-oth_charges_fin = wa_items-oth_charges.
899              ENDIF.
900            ENDIF.
901
902            IF wa_items-service_tax_fin IS INITIAL.
903              IF ( wa_items-remarks IS INITIAL AND wa_items-sec_remarks IS INITIAL ).
904                wa_items-service_tax_fin = wa_items-service_tax.
905              ENDIF.
906            ENDIF.
907
908            IF wa_items-security_dep_fin IS INITIAL.
909              IF ( wa_items-remarks IS INITIAL AND wa_items-sec_remarks IS INITIAL ).
910                wa_items-security_dep_fin = wa_items-security_dep.
911              ENDIF.
912            ENDIF.
913
914            IF wa_items-interest_fin IS INITIAL.
915              IF ( wa_items-remarks IS INITIAL AND wa_items-sec_remarks IS INITIAL ).
916                wa_items-interest_fin = wa_items-interest.
917              ENDIF.
918            ENDIF.
919
920            IF wa_items-miscl_fin IS INITIAL.
921              IF ( wa_items-remarks IS INITIAL AND wa_items-sec_remarks IS INITIAL ).
922                wa_items-miscl_fin = wa_items-miscl.
923              ENDIF.
924            ENDIF.
925    ****************************************** code added by Bipin Shukla : 23/12/2013  : for approve ammount
926
927            MOVE-CORRESPONDING wa_items TO wa_item1.
928
929            IF wa_item1-kst01 IS  INITIAL.
930              wa_item1-comment = 'Cost Object Not maintained'(012).
931            ELSE.
932              READ TABLE gt_csks INTO wa_csks WITH KEY kostl = wa_item1-kst01.
933              IF sy-subrc EQ 0.
934
935                wa_item1-buar = wa_csks-gsber.
936
937              ENDIF.
938            ENDIF.
939
940            APPEND wa_item1 TO it_item1.
941            REFRESH wa_item1-style[].
942    ************************************************* CODE OF THIRD LOOP
943            wa_item1-kst011 = wa_item1-kst01.
944            APPEND wa_item1 TO it_item2.
945
946            CLEAR : wa_item1 , wa_items , wa_mast , wa_pa9205 , wa_csks.
947
948          ENDLOOP.
949
950    * Start - RD1K991454
951    * Logic to filter records according to personnel area
952    *      IF s_werks[] IS NOT INITIAL.
953          REFRESH : lt_pernr.
954    *   Fetch personnel area from Infotype 0001
955          SELECT pernr werks persk INTO TABLE lt_pernr
956                       FROM pa0001
957                       FOR ALL ENTRIES IN it_item2
958                       WHERE pernr = it_item2-pernr
959                       AND   endda GE it_item2-bill_from
960                       AND   begda LE it_item2-bill_from
961                       AND   werks IN s_werks.
962          IF sy-subrc = 0.
963            SORT lt_pernr BY pernr.
964          ENDIF.
965
966    *     Remove records which does not belongs to personnel area selected
967          LOOP AT it_item2 ASSIGNING <fs_item>.
968            CLEAR ls_pernr.
969            READ TABLE lt_pernr INTO ls_pernr WITH KEY pernr = <fs_item>-pernr
970                                              BINARY SEARCH.
971            IF sy-subrc = 0.
972              <fs_item>-persk = ls_pernr-persk.
973            ELSEIF sy-subrc <> 0 AND s_werks[] IS NOT INITIAL.
974              DELETE TABLE it_item2 FROM <fs_item>.
975            ENDIF.
976          ENDLOOP.
977    *      ENDIF.
978    * End - RD1K991454
979
980    ******************************* for duplicate entries
981          ASSIGN it_item2 TO <itab>.
982
983          SORT s_stat1 BY low.
984          DELETE ADJACENT DUPLICATES FROM s_stat1 COMPARING low.
985          DELETE s_stat1 WHERE low IS INITIAL.
986
987          LOOP AT s_stat1 ASSIGNING <column>.
988            oline-name = <column>-low.
989            APPEND oline TO otab.
990          ENDLOOP.
991
992          SORT it_item2 BY (otab).
993          DATA: i TYPE i,
994                lv_index TYPE i,
995                lv_index1 TYPE i.
996
997
998          SORT it_item2 BY reqt_num reqt_id. " + by bipin on 03/12/2013
999
1000         LOOP AT it_item2 INTO wa_item2.
1001           lv_index = sy-tabix.
1002           lv_index1 = sy-tabix.
1003
1004           IF sy-tcode <> 'ZFIBD_REPORT'.
1005             CALL FUNCTION 'ENQUEUE_EZBILL_DATA'
1006               EXPORTING
1007                 mode_zbill_data = 'E'
1008                 mandt           = sy-mandt
1009                 reqt_num        = wa_item2-reqt_num
1010                 reqt_id         = wa_item2-reqt_id
1011               EXCEPTIONS
1012                 foreign_lock    = 1
1013                 system_failure  = 2
1014                 OTHERS          = 3.
1015             IF sy-subrc <> 0.
1016               wa_item2-gv_lo_var = 'Locked with other user'.
1017             ENDIF.
1018           ENDIF.
1019   ***************************************** for horizontal total
1020           wa_item2-gv_total_amt = wa_item2-rent_final + wa_item2-call_charges_final +
1021                                   wa_item2-oth_charges_fin + wa_item2-service_tax_fin +
1022                                   wa_item2-security_dep_fin + wa_item2-interest_fin +
1023                                   wa_item2-miscl_fin.
1024
1025           wa_item2-gv_vendor_amt = wa_item2-rent        + wa_item2-call_charge +
1026                                    wa_item2-oth_charges + wa_item2-service_tax +
1027                                    wa_item2-security_dep + wa_item2-interest +
1028                                    wa_item2-miscl.
1029
1030   *        MODIFY IT_ITEM2 FROM WA_ITEM2 TRANSPORTING GV_TOTAL_AMT GV_VENDOR_AMT.
1031   ***************************************** for horizontal total
1032
1033           IF wa_item2-sts_flag = 'A'.
1034             wa_item2-check = 'X'.
1035             wa_item2-check1 = ''.
1036           ELSEIF wa_item2-sts_flag = 'R'.
1037             wa_item2-check1 = 'X'.
1038             wa_item2-check = ''.
1039           ELSEIF wa_item2-sts_flag = ''.
1040             wa_item2-check = 'X'.
1041             wa_item2-check1 = ''.
1042           ENDIF.
1043
1044           MODIFY it_item2 FROM wa_item2 TRANSPORTING gv_total_amt gv_vendor_amt check1 check gv_lo_var.
1045
1046
1047           IF lv_index NE 1.
1048             READ TABLE it_item2 INTO wa_items2 INDEX ( lv_index - 1 ).
1049             IF sy-subrc EQ 0.
1050               DESCRIBE TABLE s_stat1 LINES i.
1051               LOOP AT s_stat1 INTO wa_stat1.
1052
1053                 CONCATENATE 'WA_ITEM2-'wa_stat1-low INTO lv_field.
1054                 ASSIGN (lv_field) TO <fs_wa1>.
1055
1056                 CONCATENATE 'WA_ITEMS2-'wa_stat1-low INTO lv_field.
1057                 ASSIGN (lv_field) TO <fs_wa2>.
1058
1059                 IF <fs_wa1> NE <fs_wa2>.
1060                   EXIT.
1061                 ENDIF.
1062
1063                 AT LAST.
1064   *         add coments
1065                   wa_item2-error_flag = 'X'.
1066                   CONCATENATE wa_item2-comment 'Duplicate entry'(013) INTO wa_item2-comment SEPARATED BY space.
1067
1068
1069                   MODIFY it_item2 FROM wa_item2.
1070
1071   *            IF LV_INDEX EQ 2.
1072                   IF wa_items2-comment NS 'Duplicate entry'(013).
1073                     CONCATENATE wa_items2-comment 'Duplicate entry'(013) INTO wa_items2-comment SEPARATED BY space.
1074   *              WA_ITEMS2-ERROR_FLAG = 'X'.
1075                     MODIFY it_item2 FROM wa_items2 INDEX ( lv_index1 - 1 ) .
1076                   ENDIF.
1077
1078                 ENDAT.
1079               ENDLOOP.
1080
1081             ENDIF.
1082           ENDIF.
1083
1084   ***************** TO CHECK AUTHORIZATION
1085           AUTHORITY-CHECK OBJECT 'ZBILL'
1086           ID  'ZCOMP' FIELD bukrs
1087           ID  'ZBAAR' FIELD wa_items2-buar
1088           ID  'ZBTYPE' FIELD bil_type.
1089
1090           IF sy-subrc NE 0.
1091             DELETE TABLE it_item2 FROM wa_item2.
1092             CONTINUE.
1093           ENDIF.
1094
1095   ***************** TO CHECK AUTHORIZATION
1096
1097           IF wa_item2-error_flag = 'X' OR wa_item2-kst01 IS INITIAL OR wa_item2-gv_lo_var IS NOT INITIAL." OR STATUS = '6'.
1098             REFRESH wa_item2-style[].
1099
1100             CLEAR ls_style.
1101             ls_style-fieldname = 'CALL_CHARGES_FINAL'.
1102             ls_style-style     = cl_gui_alv_grid=>mc_style_disabled .
1103             INSERT ls_style INTO TABLE wa_item2-style.
1104
1105             CLEAR ls_style.
1106             ls_style-fieldname = 'CHECK'.
1107             ls_style-style     = cl_gui_alv_grid=>mc_style_disabled .
1108             INSERT ls_style INTO TABLE wa_item2-style.
1109
1110             CLEAR ls_style.
1111             ls_style-fieldname = 'CHECK1'.
1112             ls_style-style     = cl_gui_alv_grid=>mc_style_disabled .
1113             INSERT ls_style INTO TABLE wa_item2-style.
1114
1115             CLEAR ls_style.
1116             ls_style-fieldname = 'INTEREST_FIN'.
1117             ls_style-style     = cl_gui_alv_grid=>mc_style_disabled .
1118             INSERT ls_style INTO TABLE wa_item2-style.
1119
1120             CLEAR ls_style.
1121             ls_style-fieldname = 'MISCL_FIN'.
1122             ls_style-style     = cl_gui_alv_grid=>mc_style_disabled .
1123             INSERT ls_style INTO TABLE wa_item2-style.
1124
1125             CLEAR ls_style.
1126             ls_style-fieldname = 'OTH_CHARGES_FIN'.
1127             ls_style-style     = cl_gui_alv_grid=>mc_style_disabled .
1128             INSERT ls_style INTO TABLE wa_item2-style.
1129
1130             CLEAR ls_style.
1131             ls_style-fieldname = 'REMARKS'.
1132             ls_style-style     = cl_gui_alv_grid=>mc_style_disabled .
1133             INSERT ls_style INTO TABLE wa_item2-style.
1134
1135             CLEAR ls_style.
1136             ls_style-fieldname = 'RENT_FINAL'.
1137             ls_style-style     = cl_gui_alv_grid=>mc_style_disabled .
1138             INSERT ls_style INTO TABLE wa_item2-style.
1139
1140             CLEAR ls_style.
1141             ls_style-fieldname = 'SEC_REMARKS'.
1142             ls_style-style     = cl_gui_alv_grid=>mc_style_disabled .
1143             INSERT ls_style INTO TABLE wa_item2-style.
1144
1145             CLEAR ls_style.
1146             ls_style-fieldname = 'SECURITY_DEP_FIN'.
1147             ls_style-style     = cl_gui_alv_grid=>mc_style_disabled .
1148             INSERT ls_style INTO TABLE wa_item2-style.
1149
1150             CLEAR ls_style.
1151             ls_style-fieldname = 'SERVICE_TAX_FIN'.
1152             ls_style-style     = cl_gui_alv_grid=>mc_style_disabled .
1153             INSERT ls_style INTO TABLE wa_item2-style.
1154
1155             CLEAR ls_style.
1156
1157             wa_item2-check = ''.
1158             wa_item2-check1 = ''.
1159
1160             wa_item2-rowcolor = 'C600'.
1161
1162             MODIFY it_item2 FROM wa_item2.
1163
1164           ENDIF.
1165           CLEAR : wa_item2.
1166         ENDLOOP.
1167
1168
1169         IF it_item2[] IS INITIAL.
1170
1171   *        MESSAGE 'No Data to display'(016) TYPE 'E'.
1172           MESSAGE e007(zbill) WITH reqt_num-low.
1173
1174         ENDIF.
1175
1176
1177   ******************************* for duplicate entries
1178
1179   *  LOOP AT IT_ITEM2 INTO WA_ITEM1 WHERE  ERROR_FLAG = 'X' OR KST01 IS INITIAL ." OR STATUS = '6'.
1180   *    REFRESH WA_ITEM1-STYLE[].
1181   *
1182   *    LS_STYLE-FIELDNAME = 'CALL_CHARGES_FINAL'.
1183   *    LS_STYLE-STYLE     = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED .
1184   *    APPEND LS_STYLE TO WA_ITEM1-STYLE.
1185   *    CLEAR LS_STYLE.
1186   *
1187   *
1188   *    LS_STYLE-FIELDNAME = 'CHECK'.
1189   *    LS_STYLE-STYLE     = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED .
1190   *    APPEND LS_STYLE TO WA_ITEM1-STYLE.
1191   *    CLEAR LS_STYLE.
1192   *
1193   *    LS_STYLE-FIELDNAME = 'CHECK1'.
1194   *    LS_STYLE-STYLE     = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED .
1195   *    APPEND LS_STYLE TO WA_ITEM1-STYLE.
1196   *    CLEAR LS_STYLE.
1197   *
1198   *
1199   *    LS_STYLE-FIELDNAME = 'OTH_CHARGES_FIN'.
1200   *    LS_STYLE-STYLE     = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED .
1201   *    APPEND LS_STYLE TO WA_ITEM1-STYLE.
1202   *    CLEAR LS_STYLE.
1203   *
1204   *
1205   *    LS_STYLE-FIELDNAME = 'REMARKS'.
1206   *    LS_STYLE-STYLE     = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED .
1207   *    APPEND LS_STYLE TO WA_ITEM1-STYLE.
1208   *    CLEAR LS_STYLE.
1209   *
1210   *    LS_STYLE-FIELDNAME = 'RENT_FINAL'.
1211   *    LS_STYLE-STYLE     = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED .
1212   *    APPEND LS_STYLE TO WA_ITEM1-STYLE.
1213   *    CLEAR LS_STYLE.
1214   *
1215   *    LS_STYLE-FIELDNAME = 'SEC_REMARKS'.
1216   *    LS_STYLE-STYLE     = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED .
1217   *    APPEND LS_STYLE TO WA_ITEM1-STYLE.
1218   *    CLEAR LS_STYLE.
1219   *
1220   *    LS_STYLE-FIELDNAME = 'SERVICE_TAX_FIN'.
1221   *    LS_STYLE-STYLE     = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED .
1222   *    APPEND LS_STYLE TO WA_ITEM1-STYLE.
1223   *    CLEAR LS_STYLE.
1224   *
1225   *
1226   *    WA_ITEM1-CHECK = ''.
1227   *    WA_ITEM1-CHECK1 = ''.
1228   *
1229   *    WA_ITEM1-ROWCOLOR = 'C600'.
1230   *
1231   *    MODIFY IT_ITEM2 FROM WA_ITEM1.
1232   *    CLEAR: WA_ITEM1,WA_ITEM3.
1233   *    REFRESH WA_ITEM1-STYLE[].
1234   *
1235   *  ENDLOOP.
1236
1237
1238   *******************************  Changes by Bipin Shukla for Cost Center : 18th Oct 2013
1239   * Build Field Catalog
1240         PERFORM build_fieldcat USING : '01' 'CHECK'              'IT_ITEM1' 'C' 'Approve'              '04' '' 'X' '',
1241               '02' 'CHECK1'             'IT_ITEM1' 'C' 'Reject'               '04' '' 'X' '', " Added by Bipin shukla on 19th oct 2013
1242               '03' 'STATUS'             'IT_ITEM1' 'L' 'Status'               '06' '' '' '',
1243               '04' 'REQT_NUM'           'IT_ITEM1' 'L' 'Request No'           '10' '' '' '',
1244               '05' 'REQT_ID'            'IT_ITEM1' 'C' 'Request ID'           '10' '' '' '',
1245               '06' 'BILL_TYPE'          'IT_ITEM1' 'L' 'Bill Type'      '12' '' '' '',
1246               '07' 'CREATE_DATE'        'IT_ITEM1' 'L' 'Upload Date'      '12' '' '' '',
1247               '08' 'BILL_NUM'           'IT_ITEM1' 'L' 'Bill Number'          '20' '' '' '',
1248               '09' 'BILL_DATE'          'IT_ITEM1' 'L' 'Bill Date'            '10' '' '' '',
1249               '10' 'BILL_FROM'          'IT_ITEM1' 'L' 'Bill From'            '10' '' '' '',
1250               '11' 'BILL_TO'            'IT_ITEM1' 'L' 'Bill To'              '10' '' '' '',
1251               '11' 'DUE_DATE'            'IT_ITEM1' 'L' 'Bill due date'              '10' '' '' '',
1252               '12' 'ZPHONE'             'IT_ITEM1' 'L' 'Communication ID/Number'      '12' '' '' '',
1253               '13' 'CONN_NUMB'          'IT_ITEM1' 'L' 'Account Number'      '12' '' '' '',
1254   ************************************  + by Bipin on 20/11/2013
1255               '14' 'OPRED'              'IT_ITEM1' 'L' 'Opening Reading'      '10' '' '' '',
1256               '15' 'CLRED'              'IT_ITEM1' 'L' 'Closing Reading'      '10' '' '' '',
1257               '16' 'NERED'              'IT_ITEM1' 'L' 'Net Reading'          '10' '' '' '',
1258   ************************************  + by Bipin on 20/11/2013
1259               '17' 'RENT'               'IT_ITEM1' 'R' 'Rent'                 '10' '' '' 'X',
1260               '18' 'RENT_FINAL'         'IT_ITEM1' 'R' 'Approved Rent'        '12' '' '' 'X',
1261               '19' 'CALL_CHARGE'        'IT_ITEM1' 'R' 'Variable Charges'          '12' '' '' 'X',
1262               '20' 'CALL_CHARGES_FINAL' 'IT_ITEM1' 'R' 'Approved Variable Charges' '17' '' '' 'X',
1263
1264               '20' 'OTH_CHARGES'        'IT_ITEM1' 'R' 'Recoveries' '12' '' '' 'X', "RD1K991454
1265               '20' 'OTH_CHARGES_FIN'    'IT_ITEM1' 'R' 'Approved Recoveries' '17' '' '' 'X', "RD1K991454
1266
1267               '20' 'SECURITY_DEP'        'IT_ITEM1' 'R' 'Security Deposit' '12' '' '' 'X',
1268               '20' 'SECURITY_DEP_FIN'    'IT_ITEM1' 'R' 'Approved Security Deposit' '17' '' '' 'X',
1269               '20' 'INTEREST'            'IT_ITEM1' 'R' 'Interest' '12' '' '' 'X',
1270               '20' 'INTEREST_FIN'        'IT_ITEM1' 'R' 'Approved Interest' '17' '' '' 'X',
1271               '20' 'MISCL'               'IT_ITEM1' 'R' 'Miscellaneous' '12' '' '' 'X',
1272               '20' 'MISCL_FIN'           'IT_ITEM1' 'R' 'Approved Miscellaneous' '17' '' '' 'X',
1273
1274
1275               '21' 'SERVICE_TAX'        'IT_ITEM1' 'R' 'Tax'          '12' '' '' 'X',
1276               '22' 'SERVICE_TAX_FIN'    'IT_ITEM1' 'R' 'Approved Tax'         '12' '' '' 'X',
1277
1278               '23' 'REMARKS'            'IT_ITEM1' 'L' 'Remarks 1'              '20' '' '' '',
1279               '24' 'SEC_REMARKS'        'IT_ITEM1' 'L' 'Remarks 2'      '50' '' '' '',
1280               '25' 'PERNR'              'IT_ITEM1' 'L' 'Personnel number'      '12' '' '' '',
1281               '26' 'KST01'              'IT_ITEM1' 'L' 'Cost Object'      '30' '' '' '',
1282               '25' 'PERSK'              'IT_ITEM1' 'L' 'Emp. Subgroup'      '12' '' '' '',
1283               '27' 'NAME'               'IT_ITEM1' 'L' 'Employee name'      '12' '' '' '',
1284               '28' 'ENAME'              'IT_ITEM1' 'L' 'Employee Name (Vendor Records) '      '30' '' '' '',
1285               '29' 'SUBTY'              'IT_ITEM1' 'L' 'Subtype'      '12' '' '' '',
1286               '30' 'RAMT'               'IT_ITEM1' 'R' 'Recovery Amount'      '12' '' '' '',
1287               '31' 'COMMENT'            'IT_ITEM1' 'L' 'Error Log'      '50' 'X' '' '',
1288   *                                 '21' 'APPROVED_BY'        'IT_ITEM1' 'L' 'Approved By'          '12' '',
1289               '32' 'ACCOUNT_DOC_NO'     'IT_ITEM1' 'L' 'Document No'          '12' '' '' '',
1290               '33' 'COMP_CODE'          'IT_ITEM1' 'L' 'Company Code'      '12' '' '' '',
1291   ************************************  Added by Bipin on 18th Oct 2013
1292               '34' 'FYEAR'              'IT_ITEM1' 'L' 'Fiscal year'      '12' '' '' '',
1293               '35' 'GV_TOTAL_AMT'              'IT_ITEM1' 'R' 'Total App. Amt'      '20' '' '' 'X',
1294               '36' 'GV_VENDOR_AMT'              'IT_ITEM1' 'R' 'Total Amt (Vendor)'      '20' '' '' 'X',
1295               '37' 'GV_LO_VAR'              'IT_ITEM1' 'L' 'Lock Commet'      '30' '' '' 'X'.
1296
1297
1298
1299
1300   *                                 '35' 'ZAMT'               'IT_ITEM1' 'R' 'Reimb Admissible Amount'      '20' '',
1301
1302   *                                 '36' 'SEC_REMARKS'        'IT_ITEM1' 'R' 'Remarks 2'      '50' ''.
1303
1304   *************************************  End of changes by Bipin on 18th Oct 2013
1305
1306
1307       ENDFORM.                    " DISPLAY_RECORDS
1308   *&---------------------------------------------------------------------*
1309   *&      Form  BUILD_FIELDCAT
1310   *&---------------------------------------------------------------------*
1311   *       text
1312   *----------------------------------------------------------------------*
1313   *      -->P_0030   text
1314   *      -->P_0031   text
1315   *      -->P_0032   text
1316   *      -->P_0033   text
1317   *      -->P_0034   text
1318   *      -->P_0035   text
1319   *----------------------------------------------------------------------*
1320       FORM build_fieldcat  USING p_col_pos TYPE lvc_colpos
1321             p_fname   TYPE lvc_fname
1322             p_tname   TYPE lvc_tname
1323             p_just    TYPE lvc_just
1324             p_coltext TYPE lvc_txtcol
1325             p_outlen  TYPE lvc_ddlen
1326             p_hotspot TYPE lvc_hotspt
1327             p_key     TYPE lvc_key
1328             p_sum     TYPE lvc_dosum.
1329
1330
1331         wa_fieldcat-col_pos = p_col_pos.
1332         wa_fieldcat-fieldname = p_fname.
1333         wa_fieldcat-tabname = p_tname.
1334         wa_fieldcat-just = p_just.
1335         wa_fieldcat-coltext = p_coltext.
1336         wa_fieldcat-dd_outlen = p_outlen.
1337         wa_fieldcat-hotspot = p_hotspot.
1338         wa_fieldcat-key = p_key.
1339         wa_fieldcat-do_sum = p_sum.
1340
1341         IF p_fname EQ 'RENT_FINAL' OR p_fname EQ 'CALL_CHARGES_FINAL'
1342         OR p_fname EQ 'OTH_CHARGES_FIN' OR p_fname EQ 'SERVICE_TAX_FIN' OR
1343           p_fname EQ 'SECURITY_DEP_FIN' OR p_fname EQ 'INTEREST_FIN' OR
1344           p_fname EQ 'MISCL_FIN'.
1345           wa_fieldcat-edit = abap_true.
1346           wa_fieldcat-ref_table = 'ZBILL_DATA'.
1347   *        wa_fieldcat-ref_field = 'RENT'.
1348           wa_fieldcat-ref_field = 'INTEREST'.
1349         ENDIF.
1350         IF p_fname EQ 'CHECK'.
1351           wa_fieldcat-checkbox = 'X'.
1352           wa_fieldcat-edit = abap_true.
1353         ENDIF.
1354         IF p_fname EQ 'CHECK1'.
1355           wa_fieldcat-checkbox = 'X'.
1356           wa_fieldcat-edit = abap_true.
1357         ENDIF.
1358
1359
1360
1361         IF p_fname EQ 'REMARKS' AND sy-tcode = 'ZFIBD_PROCESS'.
1362
1363           wa_fieldcat-edit = abap_true.
1364           wa_fieldcat-ref_table = 'ZBILL_DATA'.
1365           wa_fieldcat-ref_field = 'REMARKS'.
1366
1367         ENDIF.
1368
1369         IF p_fname EQ 'SEC_REMARKS' AND sy-tcode = 'ZFIBD_POST'.
1370
1371           wa_fieldcat-edit = abap_true.
1372           wa_fieldcat-ref_table = 'ZBILL_DATA'.
1373           wa_fieldcat-ref_field = 'SEC_REMARKS'.
1374         ENDIF.
1375
1376         IF sy-tcode = 'ZFIBD_REPORT'.
1377
1378           IF p_fname EQ 'RENT_FINAL' OR p_fname EQ 'CALL_CHARGES_FINAL'
1379            OR p_fname EQ 'OTH_CHARGES_FIN' OR p_fname EQ 'SERVICE_TAX_FIN' OR
1380              p_fname EQ 'SECURITY_DEP_FIN' OR p_fname EQ 'INTEREST_FIN' OR
1381              p_fname EQ 'MISCL_FIN'.
1382
1383             wa_fieldcat-edit = ' '.
1384             wa_fieldcat-ref_table = 'ZBILL_DATA'.
1385   *          wa_fieldcat-ref_field = 'RENT'.
1386             wa_fieldcat-ref_field = 'INTEREST'.
1387
1388           ENDIF.
1389
1390           IF p_fname = 'CHECK' OR p_fname = 'CHECK1'.
1391             wa_fieldcat-fieldname = ''.
1392           ENDIF.
1393
1394
1395
1396         ENDIF.
1397
1398         IF  bil_type NE '5'.
1399
1400           IF p_fname = 'OPRED'.
1401             wa_fieldcat-fieldname = ''.
1402           ENDIF.
1403
1404           IF p_fname = 'CLRED'.
1405             wa_fieldcat-fieldname = ''.
1406           ENDIF.
1407
1408           IF p_fname = 'NERED'.
1409             wa_fieldcat-fieldname = ''.
1410           ENDIF.
1411
1412         ENDIF.
1413
1414
1415         APPEND wa_fieldcat TO it_fieldcat.
1416         CLEAR wa_fieldcat.
1417
1418       ENDFORM.                    " BUILD_FIELDCAT
1419   *&---------------------------------------------------------------------*
1420   *&      Module  STATUS_0900  OUTPUT
1421   *&---------------------------------------------------------------------*
1422   *       text
1423   *----------------------------------------------------------------------*
1424       MODULE status_0900 OUTPUT.
1425         DATA lt_fcode TYPE TABLE OF sy-ucomm.
1426         IF sy-tcode = 'ZFIBD_PROCESS'.
1427           APPEND 'SIMULATE' TO lt_fcode.
1428           APPEND 'EXECUTE' TO lt_fcode.
1429         ELSEIF sy-tcode = 'ZFIBD_POST'.
1430           APPEND 'EXPOST' TO lt_fcode.
1431         ELSEIF sy-tcode = 'ZFIBD_REPORT'.
1432           APPEND 'SIMULATE' TO lt_fcode.
1433           APPEND 'EXECUTE' TO lt_fcode.
1434           APPEND 'EXPOST' TO lt_fcode.
1435         ENDIF.
1436         SET PF-STATUS 'ZBILL' EXCLUDING lt_fcode.
1437         SET TITLEBAR 'ZBIL'.
1438       ENDMODULE.                 " STATUS_0900  OUTPUT
1439   *&---------------------------------------------------------------------*
1440   *&      Module  CREATE_OBJECT  OUTPUT
1441   *&---------------------------------------------------------------------*
1442   *       text
1443   *----------------------------------------------------------------------*
1444       MODULE create_object OUTPUT.
1445   *  To Create the Grid Instance
1446         CHECK r_container IS INITIAL.
1447         CREATE OBJECT r_container
1448           EXPORTING
1449             extension                   = 9999
1450           EXCEPTIONS
1451             cntl_error                  = 1
1452             cntl_system_error           = 2
1453             create_error                = 3
1454             lifetime_error              = 4
1455             lifetime_dynpro_dynpro_link = 5
1456             OTHERS                      = 6.
1457
1458   * To Create the Grid Instance
1459         CREATE OBJECT r_grid
1460           EXPORTING
1461             i_parent          = r_container
1462           EXCEPTIONS
1463             error_cntl_create = 1
1464             error_cntl_init   = 2
1465             error_cntl_link   = 3
1466             error_dp_create   = 4
1467             OTHERS            = 5.
1468
1469         wa_layout-zebra      = abap_true.
1470         wa_layout-cwidth_opt = abap_true.
1471         wa_layout-no_rowmark = abap_true.
1472         wa_layout-stylefname = 'STYLE'.
1473         wa_layout-info_fname = 'ROWCOLOR'.
1474
1475         CREATE OBJECT lv_h.
1476         PERFORM exclude_toolbar.
1477
1478   *  IF BIL_TYPE-LOW NE '5'.
1479   *    DELETE IT_FIELDCAT WHERE FIELDNAME = 'OPRED' OR FIELDNAME = 'CLRED' OR FIELDNAME = 'NERED'.
1480   *  ENDIF.
1481
1482         CLEAR gv_variant.
1483         gv_variant = sy-repid.
1484
1485         CALL METHOD r_grid->set_table_for_first_display
1486           EXPORTING
1487             i_save                        = 'A'
1488             is_variant                    = gv_variant
1489             is_layout                     = wa_layout
1490             it_toolbar_excluding          = it_exclude
1491           CHANGING
1492             it_outtab                     = it_item2
1493             it_fieldcatalog               = it_fieldcat
1494   *         it_sort                       =
1495   *         it_filter                     =
1496           EXCEPTIONS
1497             invalid_parameter_combination = 1
1498             program_error                 = 2
1499             too_many_lines                = 3
1500             OTHERS                        = 4.
1501
1502         CREATE OBJECT c_alv_toolbar
1503           EXPORTING
1504             io_alv_grid = r_grid.
1505   * Register event handler
1506         SET HANDLER c_alv_toolbar->on_toolbar FOR r_grid.
1507         SET HANDLER c_alv_toolbar->handle_user_command FOR r_grid.
1508         SET HANDLER lv_h->handle_data_changed FOR r_grid.
1509
1510   *  SET HANDLER C_ALV_TOOLBAR-> FOR R_GRID.
1511
1512         SET HANDLER c_alv_toolbar->handle_hotspot_click FOR r_grid.
1513         CALL METHOD r_grid->set_toolbar_interactive.
1514
1515         CALL METHOD r_grid->register_edit_event
1516           EXPORTING
1517             i_event_id = cl_gui_alv_grid=>mc_evt_modified.
1518
1519
1520       ENDMODULE.                 " CREATE_OBJECT  OUTPUT
1521   *&---------------------------------------------------------------------*
1522   *&      Module  USER_COMMAND_0900  INPUT
1523   *&---------------------------------------------------------------------*
1524   *       text
1525   *----------------------------------------------------------------------*
1526       MODULE user_command_0900 INPUT.
1527
1528   *       RD1K991454
1529         DATA : lv_mode TYPE abap_bool.
1530         DATA : ls_item TYPE ty_item1,
1531                ls_head TYPE zbill_head.
1532
1533   *     Assumption: At a time, Only one request will be posted.
1534         CLEAR : ls_item,gv_kidno,lv_mode.
1535         READ TABLE it_item2 INTO ls_item INDEX 1.
1536         IF sy-subrc = 0.
1537           CLEAR ls_head.
1538           READ TABLE it_head INTO ls_head WITH KEY reqt_num = ls_item-reqt_num.
1539         ENDIF.
1540   *       RD1K991454
1541
1542         ok_code = sy-ucomm.
1543         CASE ok_code.
1544           WHEN 'BACK'.
1545             PERFORM  dequeue_data.
1546             LEAVE TO SCREEN 0.
1547           WHEN 'EXIT'.
1548             PERFORM dequeue_data.
1549             LEAVE TO SCREEN 0.
1550           WHEN 'CANC'.
1551             PERFORM dequeue_data.
1552             LEAVE TO SCREEN 0.
1553           WHEN 'SAVE'.
1554   *      PERFORM PUT_REMARK.
1555             PERFORM save_data.
1556           WHEN 'EXECUTE'.
1557             PERFORM save_data.
1558             CALL FUNCTION 'ZPOPUP_TO_INPUT'
1559               EXPORTING
1560                 bukrs       = bukrs
1561                 i_serv_prov = ls_head-serv_prov
1562               IMPORTING
1563                 sec_code    = sec_code
1564                 post_date   = post_dt
1565                 due_date    = due_date
1566                 er_fund     = er_kblnr
1567                 er_doc      = er_kblpos
1568                 text        = txt
1569                 e_kidno     = gv_kidno
1570                 answer      = answer.
1571             IF sy-subrc EQ 0.
1572               CASE answer .
1573                 WHEN '1'.
1574                   LOOP AT it_item2 INTO wa_item2 WHERE check IS NOT INITIAL.
1575                     wa_item2-status = '4'.
1576                     MODIFY it_item2 FROM wa_item2.
1577                   ENDLOOP.
1578
1579   ***                PERFORM post_records.
1580   *               Prepare accounting document - X = Post, SPACE = Simulate
1581                   lv_mode = abap_true.
1582                   PERFORM f_release_to_accounting USING lv_mode.
1583
1584                 WHEN '2'.
1585                   RETURN.
1586                 WHEN OTHERS.
1587               ENDCASE.
1588             ENDIF.
1589           WHEN 'EXPOST'.
1590   *      PERFORM SAVE_DATA.
1591             PERFORM approve_data.
1592
1593           WHEN 'PRINT'.
1594             PERFORM print_form.
1595           WHEN 'SIMULATE'.
1596             LOOP AT it_item2 INTO wa_item2 WHERE check IS NOT INITIAL.
1597               wa_item2-status = '4'.
1598               MODIFY it_item2 FROM wa_item2.
1599             ENDLOOP.
1600
1601             CLEAR it_item3[].
1602             it_item3[] = it_item2[].
1603             DELETE it_item3 WHERE check IS INITIAL.
1604
1605             SORT it_item3 BY reqt_num.
1606             DELETE ADJACENT DUPLICATES FROM it_item3 COMPARING reqt_num.
1607             DESCRIBE TABLE it_item3 LINES lv_check.
1608             CLEAR : lv_check.
1609             DESCRIBE TABLE it_item3 LINES lv_check.
1610
1611             IF lv_check GT 1.
1612               MESSAGE 'Please select only request'(015) TYPE 'E'.
1613             ENDIF.
1614
1615             CALL FUNCTION 'ZPOPUP_TO_INPUT'
1616               EXPORTING
1617                 bukrs       = bukrs
1618                 i_serv_prov = ls_head-serv_prov
1619               IMPORTING
1620                 sec_code    = sec_code
1621                 post_date   = post_dt
1622                 due_date    = due_date
1623                 er_fund     = er_kblnr
1624                 er_doc      = er_kblpos
1625                 text        = txt
1626                 e_kidno     = gv_kidno
1627                 answer      = answer.
1628             IF sy-subrc EQ 0.
1629               CASE answer .
1630                 WHEN '1'.
1631   ***                PERFORM simulate.
1632   *               Prepare accounting document - X = Post, SPACE = Simulate
1633                   lv_mode = abap_false.
1634                   PERFORM f_release_to_accounting USING lv_mode.
1635                 WHEN '2'.
1636                   RETURN.
1637                 WHEN OTHERS.
1638               ENDCASE.
1639             ENDIF.
1640           WHEN 'P++'.
1641             PERFORM f_scroll_up_down USING ok_code.
1642           WHEN 'P+'.
1643             PERFORM f_scroll_up_down USING ok_code.
1644           WHEN 'P--'.
1645             PERFORM f_scroll_up_down USING ok_code.
1646           WHEN 'P-'.
1647             PERFORM f_scroll_up_down USING ok_code.
1648         ENDCASE.
1649       ENDMODULE.                 " USER_COMMAND_0900  INPUT
1650   *&---------------------------------------------------------------------*
1651   *&      Form  EXCLUDE_TOOLBAR
1652   *&---------------------------------------------------------------------*
1653   *       text
1654   *----------------------------------------------------------------------*
1655   *  -->  p1        text
1656   *  <--  p2        text
1657   *----------------------------------------------------------------------*
1658       FORM exclude_toolbar .
1659
1660         MOVE cl_gui_alv_grid=>mc_fc_loc_delete_row TO wa_exclude.
1661         APPEND wa_exclude TO it_exclude.
1662         CLEAR wa_exclude.
1663
1664         MOVE cl_gui_alv_grid=>mc_fc_loc_insert_row TO wa_exclude.
1665         APPEND wa_exclude TO it_exclude.
1666         CLEAR wa_exclude.
1667
1668         MOVE cl_gui_alv_grid=>mc_fc_loc_append_row TO wa_exclude.
1669         APPEND wa_exclude TO it_exclude.
1670         CLEAR wa_exclude.
1671
1672         MOVE cl_gui_alv_grid=>mc_fc_loc_paste TO wa_exclude.
1673         APPEND wa_exclude TO it_exclude.
1674         CLEAR wa_exclude.
1675
1676         MOVE cl_gui_alv_grid=>mc_fc_loc_cut TO wa_exclude.
1677         APPEND wa_exclude TO it_exclude.
1678         CLEAR wa_exclude.
1679
1680         MOVE cl_gui_alv_grid=>mc_fc_loc_copy TO wa_exclude.
1681         APPEND wa_exclude TO it_exclude.
1682         CLEAR wa_exclude.
1683
1684         MOVE cl_gui_alv_grid=>mc_fc_loc_undo TO wa_exclude.
1685         APPEND wa_exclude TO it_exclude.
1686         CLEAR wa_exclude.
1687
1688         MOVE cl_gui_alv_grid=>mc_fc_loc_paste_new_row TO wa_exclude.
1689         APPEND wa_exclude TO it_exclude.
1690         CLEAR wa_exclude.
1691
1692         MOVE cl_gui_alv_grid=>mc_fc_print TO wa_exclude.
1693         APPEND wa_exclude TO it_exclude.
1694         CLEAR wa_exclude.
1695
1696         MOVE cl_gui_alv_grid=>mc_fc_views TO wa_exclude.
1697         APPEND wa_exclude TO it_exclude.
1698         CLEAR wa_exclude.
1699
1700         MOVE cl_gui_alv_grid=>mc_fc_detail TO wa_exclude.
1701         APPEND wa_exclude TO it_exclude.
1702         CLEAR wa_exclude.
1703
1704         MOVE cl_gui_alv_grid=>mc_fc_check TO wa_exclude.
1705         APPEND wa_exclude TO it_exclude.
1706         CLEAR wa_exclude.
1707
1708         MOVE cl_gui_alv_grid=>mc_fc_loc_copy_row TO wa_exclude.
1709         APPEND wa_exclude TO it_exclude.
1710         CLEAR wa_exclude.
1711
1712
1713       ENDFORM.                    " EXCLUDE_TOOLBAR
1714   *&---------------------------------------------------------------------*
1715   *&      Form  SAVE_DATA
1716   *&---------------------------------------------------------------------*
1717   *       text
1718   *----------------------------------------------------------------------*
1719   *  -->  p1        text
1720   *  <--  p2        text
1721   *----------------------------------------------------------------------*
1722       FORM save_data.
1723         REFRESH :  it_zbill_data[] , it_changed[].
1724         CLEAR :  it_zbill_data[] , it_changed[] ,it_item_l2[] .
1725         CLEAR : wa_item2.
1726         CALL METHOD r_grid->check_changed_data.
1727
1728   ******************************* Added by bipin : on 20/01/2014 : for sec remarks in case of L2
1729         IF sy-tcode EQ 'ZFIBD_POST'.
1730           SELECT * FROM zbill_data INTO CORRESPONDING FIELDS OF TABLE it_item_l2
1731             WHERE reqt_num IN reqt_num AND status = '2'.
1732         ENDIF.
1733   ******************************* Added by bipin : on 20/01/2014 : for sec remarks in case of L2
1734
1735
1736   ************************* Validation for reject all : Bipin on 21/01/2014
1737
1738         IF ok_code = 'SAVE'.
1739
1740           IF rej_flag = 'R'.
1741             CALL FUNCTION 'UR_CF_POPUP_TEXT_INPUT'
1742               EXPORTING
1743                 i_title   = 'Rejection Reason'
1744                 i_text    = ' '
1745               IMPORTING
1746                 e_text    = rej_text
1747               EXCEPTIONS
1748                 cancelled = 1
1749                 OTHERS    = 2.
1750             IF sy-subrc <> 0.
1751   * Implement suitable error handling here
1752             ENDIF.
1753
1754             LOOP AT it_item2 INTO wa_item2 WHERE check1 = 'X'.
1755
1756               IF sy-tcode = 'ZFIBD_PROCESS'.
1757
1758                 wa_item2-remarks = rej_text.
1759
1760               ELSEIF sy-tcode = 'ZFIBD_POST'.
1761                 wa_item2-sec_remarks = rej_text.
1762               ENDIF.
1763
1764               MODIFY it_item2 FROM wa_item2 TRANSPORTING remarks sec_remarks.
1765
1766
1767             ENDLOOP.
1768
1769             CALL METHOD r_grid->refresh_table_display.
1770
1771           ENDIF.
1772           CLEAR : rej_flag.
1773
1774         ENDIF.
1775
1776   ************************* Validation for reject all : Bipin on 21/01/2014
1777
1778         LOOP AT it_item2 INTO wa_item2.
1779
1780
1781           IF ok_code = 'EXPOST'.
1782
1783   *         Rent
1784             PERFORM f_check_at_save USING wa_item2-rent
1785                                           wa_item2-rent_final
1786                                           wa_item2
1787                                           'RENT_FINAL'.
1788
1789   *         Variable Charges
1790             PERFORM f_check_at_save USING wa_item2-call_charge
1791                                           wa_item2-call_charges_final
1792                                           wa_item2
1793                                           'CALL_CHARGES_FINAL'.
1794
1795   *         Recoveries
1796             PERFORM f_check_at_save USING wa_item2-oth_charges
1797                                           wa_item2-oth_charges_fin
1798                                           wa_item2
1799                                           'OTH_CHARGES_FIN'.
1800
1801   *         Taxes
1802             PERFORM f_check_at_save USING wa_item2-service_tax
1803                                           wa_item2-service_tax_fin
1804                                           wa_item2
1805                                           'SERVICE_TAX_FIN'.
1806
1807   *         Security Deposit
1808             PERFORM f_check_at_save USING wa_item2-security_dep
1809                                           wa_item2-security_dep_fin
1810                                           wa_item2
1811                                           'SECURITY_DEP_FIN'.
1812
1813   *         Interest
1814             PERFORM f_check_at_save USING wa_item2-interest
1815                                           wa_item2-interest_fin
1816                                           wa_item2
1817                                           'INTEREST_FIN'.
1818
1819   *         Miscellaneous
1820             PERFORM f_check_at_save USING wa_item2-miscl
1821                                           wa_item2-miscl_fin
1822                                           wa_item2
1823                                           'MISCL_FIN'.
1824
1825
1826   *          IF wa_item2-rent_final GT wa_item2-rent.
1827   *            MESSAGE e001(zbill) WITH wa_item2-reqt_num wa_item2-reqt_id.
1828   *          ENDIF.
1829   *          IF wa_item2-rent_final NE wa_item2-rent.
1830   *            IF wa_item2-remarks IS INITIAL.
1831   *              MESSAGE e006(zbill) WITH wa_item2-reqt_num wa_item2-reqt_id.
1832   *            ENDIF.
1833   *          ENDIF.
1834   *
1835   *
1836   *
1837   *
1838   *          IF wa_item2-call_charges_final GT wa_item2-call_charge.
1839   *            MESSAGE e001(zbill) WITH wa_item2-reqt_num wa_item2-reqt_id.
1840   *          ENDIF.
1841   *          IF wa_item2-call_charges_final NE wa_item2-call_charge.
1842   *            IF wa_item2-remarks IS INITIAL.
1843   *              MESSAGE e006(zbill) WITH wa_item2-reqt_num wa_item2-reqt_id.
1844   *            ENDIF.
1845   *          ENDIF.
1846   *
1847   *          IF wa_item2-oth_charges_fin GT wa_item2-oth_charges.
1848   *            MESSAGE e001(zbill) WITH wa_item2-reqt_num wa_item2-reqt_id.
1849   *          ENDIF.
1850   *          IF wa_item2-oth_charges_fin NE wa_item2-oth_charges.
1851   *            IF wa_item2-remarks IS INITIAL.
1852   *              MESSAGE e006(zbill) WITH wa_item2-reqt_num wa_item2-reqt_id.
1853   *            ENDIF.
1854   *          ENDIF.
1855   *
1856   *          IF wa_item2-service_tax_fin GT wa_item2-service_tax.
1857   *            MESSAGE e001(zbill) WITH wa_item2-reqt_num wa_item2-reqt_id.
1858   *          ENDIF.
1859   *          IF wa_item2-service_tax_fin NE wa_item2-service_tax.
1860   *            IF wa_item2-remarks IS INITIAL.
1861   *              MESSAGE e006(zbill) WITH wa_item2-reqt_num wa_item2-reqt_id.
1862   *            ENDIF.
1863   *          ENDIF.
1864   *
1865   **         If value is positive then only be triggereds
1866   *          IF wa_item2-security_dep_fin GT wa_item2-security_dep AND
1867   *             wa_item2-security_dep > 0.
1868   *            MESSAGE e001(zbill) WITH wa_item2-reqt_num wa_item2-reqt_id.
1869   *          ENDIF.
1870   *          IF wa_item2-security_dep_fin NE wa_item2-security_dep.
1871   *            IF wa_item2-remarks IS INITIAL.
1872   *              MESSAGE e006(zbill) WITH wa_item2-reqt_num wa_item2-reqt_id.
1873   *            ENDIF.
1874   *          ENDIF.
1875   *
1876   *          IF wa_item2-interest_fin GT wa_item2-interest AND
1877   *             wa_item2-interest > 0.
1878   *            MESSAGE e001(zbill) WITH wa_item2-reqt_num wa_item2-reqt_id.
1879   *          ENDIF.
1880   *          IF wa_item2-interest_fin NE wa_item2-interest_fin.
1881   *            IF wa_item2-remarks IS INITIAL.
1882   *              MESSAGE e006(zbill) WITH wa_item2-reqt_num wa_item2-reqt_id.
1883   *            ENDIF.
1884   *          ENDIF.
1885   *
1886   *          IF wa_item2-miscl_fin GT wa_item2-miscl AND
1887   *             wa_item2-miscl > 0.
1888   *            MESSAGE e001(zbill) WITH wa_item2-reqt_num wa_item2-reqt_id.
1889   *          ENDIF.
1890   *          IF wa_item2-miscl_fin NE wa_item2-miscl.
1891   *            IF wa_item2-remarks IS INITIAL.
1892   *              MESSAGE e006(zbill) WITH wa_item2-reqt_num wa_item2-reqt_id.
1893   *            ENDIF.
1894   *          ENDIF.
1895
1896           ENDIF.
1897
1898   ******************************* VALIDATION FOR SAVE
1899
1900           IF sy-tcode = 'ZFIBD_PROCESS'.
1901
1902             IF ok_code = 'SAVE' .
1903
1904   *         Rent
1905               PERFORM f_check_at_save USING wa_item2-rent
1906                                             wa_item2-rent_final
1907                                             wa_item2
1908                                             'RENT_FINAL'.
1909
1910   *         Variable Charges
1911               PERFORM f_check_at_save USING wa_item2-call_charge
1912                                             wa_item2-call_charges_final
1913                                             wa_item2
1914                                             'CALL_CHARGES_FINAL'.
1915
1916   *         Recoveries
1917               PERFORM f_check_at_save USING wa_item2-oth_charges
1918                                             wa_item2-oth_charges_fin
1919                                             wa_item2
1920                                             'OTH_CHARGES_FIN'.
1921
1922   *         Taxes
1923               PERFORM f_check_at_save USING wa_item2-service_tax
1924                                             wa_item2-service_tax_fin
1925                                             wa_item2
1926                                             'SERVICE_TAX_FIN'.
1927
1928   *         Security Deposit
1929               PERFORM f_check_at_save USING wa_item2-security_dep
1930                                             wa_item2-security_dep_fin
1931                                             wa_item2
1932                                             'SECURITY_DEP_FIN'.
1933
1934   *         Interest
1935               PERFORM f_check_at_save USING wa_item2-interest
1936                                             wa_item2-interest_fin
1937                                             wa_item2
1938                                             'INTEREST_FIN'.
1939
1940   *         Miscellaneous
1941               PERFORM f_check_at_save USING wa_item2-miscl
1942                                             wa_item2-miscl_fin
1943                                             wa_item2
1944                                             'MISCL_FIN'.
1945
1946   *            IF wa_item2-rent_final GT wa_item2-rent.
1947   *              MESSAGE e001(zbill) WITH wa_item2-reqt_num wa_item2-reqt_id.
1948   *            ENDIF.
1949   *            IF wa_item2-rent_final NE wa_item2-rent.
1950   *              IF wa_item2-remarks IS INITIAL.
1951   *                MESSAGE e006(zbill) WITH wa_item2-reqt_num wa_item2-reqt_id.
1952   *              ENDIF.
1953   *
1954   *            ENDIF.
1955   *
1956   *            IF wa_item2-call_charges_final GT wa_item2-call_charge.
1957   *              MESSAGE e001(zbill) WITH wa_item2-reqt_num wa_item2-reqt_id.
1958   *            ENDIF.
1959   *            IF wa_item2-call_charges_final NE wa_item2-call_charge.
1960   *              IF wa_item2-remarks IS INITIAL.
1961   *                MESSAGE e006(zbill) WITH wa_item2-reqt_num wa_item2-reqt_id.
1962   *              ENDIF.
1963   *            ENDIF.
1964   *
1965   *            IF wa_item2-oth_charges_fin GT wa_item2-oth_charges.
1966   *              MESSAGE e001(zbill) WITH wa_item2-reqt_num wa_item2-reqt_id.
1967   *            ENDIF.
1968   *            IF wa_item2-oth_charges_fin NE wa_item2-oth_charges.
1969   *              IF wa_item2-remarks IS INITIAL.
1970   *                MESSAGE e006(zbill) WITH wa_item2-reqt_num wa_item2-reqt_id.
1971   *              ENDIF.
1972   *            ENDIF.
1973   *
1974   *            IF wa_item2-service_tax_fin GT wa_item2-service_tax.
1975   *              MESSAGE e001(zbill) WITH wa_item2-reqt_num wa_item2-reqt_id.
1976   *            ENDIF.
1977   *            IF wa_item2-service_tax_fin NE wa_item2-service_tax.
1978   *              IF wa_item2-remarks IS INITIAL.
1979   *                MESSAGE e006(zbill) WITH wa_item2-reqt_num wa_item2-reqt_id.
1980   *              ENDIF.
1981   *            ENDIF.
1982   *
1983   **         If value is positive then only be triggereds
1984   *            IF wa_item2-security_dep_fin GT wa_item2-security_dep AND
1985   *               wa_item2-security_dep > 0.
1986   *              MESSAGE e001(zbill) WITH wa_item2-reqt_num wa_item2-reqt_id.
1987   *            ENDIF.
1988   *            IF wa_item2-security_dep_fin NE wa_item2-security_dep.
1989   *              IF wa_item2-remarks IS INITIAL.
1990   *                MESSAGE e006(zbill) WITH wa_item2-reqt_num wa_item2-reqt_id.
1991   *              ENDIF.
1992   *            ENDIF.
1993   *
1994   *            IF wa_item2-interest_fin GT wa_item2-interest AND
1995   *               wa_item2-interest > 0.
1996   *              MESSAGE e001(zbill) WITH wa_item2-reqt_num wa_item2-reqt_id.
1997   *            ENDIF.
1998   *            IF wa_item2-interest_fin NE wa_item2-interest_fin.
1999   *              IF wa_item2-remarks IS INITIAL.
2000   *                MESSAGE e006(zbill) WITH wa_item2-reqt_num wa_item2-reqt_id.
2001   *              ENDIF.
2002   *            ENDIF.
2003   *
2004   *            IF wa_item2-miscl_fin GT wa_item2-miscl AND
2005   *               wa_item2-miscl > 0.
2006   *              MESSAGE e001(zbill) WITH wa_item2-reqt_num wa_item2-reqt_id.
2007   *            ENDIF.
2008   *            IF wa_item2-miscl_fin NE wa_item2-miscl.
2009   *              IF wa_item2-remarks IS INITIAL.
2010   *                MESSAGE e006(zbill) WITH wa_item2-reqt_num wa_item2-reqt_id.
2011   *              ENDIF.
2012   *            ENDIF.
2013
2014               IF wa_item2-check = 'X'.
2015                 wa_item2-sts_flag = 'A'.
2016               ELSEIF wa_item2-check1 = 'X'.
2017                 IF wa_item2-remarks IS NOT INITIAL.
2018                   wa_item2-sts_flag = 'R'.
2019                 ELSE.
2020                   MESSAGE  e004(zbill).
2021                 ENDIF.
2022               ELSEIF  wa_item2-check = '' AND wa_item2-check1 = ''.
2023                 wa_item2-sts_flag = ''.
2024               ENDIF.
2025
2026             ENDIF.
2027
2028           ENDIF.
2029
2030   ******************************* VALIDATION FOR SAVE
2031
2032           IF sy-tcode = 'ZFIBD_POST'.
2033
2034             IF ok_code = 'SAVE'  OR ok_code = 'EXECUTE'.
2035
2036   *            IF WA_ITEM2-RENT_FINAL GT WA_ITEM2-RENT.
2037   *              MESSAGE E001(ZBILL) WITH WA_ITEM2-REQT_NUM WA_ITEM2-REQT_ID.
2038   *            ENDIF.
2039   *            IF WA_ITEM2-RENT_FINAL NE WA_ITEM2-RENT.
2040   *              IF WA_ITEM2-SEC_REMARKS IS INITIAL.
2041   *                MESSAGE E006(ZBILL) WITH WA_ITEM2-REQT_NUM WA_ITEM2-REQT_ID.
2042   *              ENDIF.
2043   *            ENDIF.
2044
2045   ******************************* Added by bipin : on 20/01/2014 : for sec remarks in case of L2
2046   ****************************** changes by bipin : on 20/01/2013    : start of changes
2047
2048               READ TABLE it_item_l2 INTO wa_item_l2 WITH KEY reqt_num = wa_item2-reqt_num
2049                                                              reqt_id  = wa_item2-reqt_id.
2050
2051               IF sy-subrc EQ 0.
2052
2053   *         Rent
2054                 PERFORM f_check_at_save USING wa_item2-rent
2055                                               wa_item2-rent_final
2056                                               wa_item2
2057                                               'RENT_FINAL'.
2058
2059   *         Variable Charges
2060                 PERFORM f_check_at_save USING wa_item2-call_charge
2061                                               wa_item2-call_charges_final
2062                                               wa_item2
2063                                               'CALL_CHARGES_FINAL'.
2064
2065   *         Recoveries
2066                 PERFORM f_check_at_save USING wa_item2-oth_charges
2067                                               wa_item2-oth_charges_fin
2068                                               wa_item2
2069                                               'OTH_CHARGES_FIN'.
2070
2071   *         Taxes
2072                 PERFORM f_check_at_save USING wa_item2-service_tax
2073                                               wa_item2-service_tax_fin
2074                                               wa_item2
2075                                               'SERVICE_TAX_FIN'.
2076
2077   *         Security Deposit
2078                 PERFORM f_check_at_save USING wa_item2-security_dep
2079                                               wa_item2-security_dep_fin
2080                                               wa_item2
2081                                               'SECURITY_DEP_FIN'.
2082
2083   *         Interest
2084                 PERFORM f_check_at_save USING wa_item2-interest
2085                                               wa_item2-interest_fin
2086                                               wa_item2
2087                                               'INTEREST_FIN'.
2088
2089   *         Miscellaneous
2090                 PERFORM f_check_at_save USING wa_item2-miscl
2091                                               wa_item2-miscl_fin
2092                                               wa_item2
2093                                               'MISCL_FIN'.
2094
2095
2096   *              IF wa_item2-rent_final GT wa_item_l2-rent_final.
2097   *                MESSAGE e001(zbill) WITH wa_item2-reqt_num wa_item2-reqt_id.
2098   *              ENDIF.
2099   *
2100   *              IF wa_item2-rent_final NE wa_item_l2-rent_final.
2101   *                IF wa_item2-sec_remarks IS INITIAL.
2102   *                  MESSAGE e006(zbill) WITH wa_item2-reqt_num wa_item2-reqt_id.
2103   *                ENDIF.
2104   *              ENDIF.
2105   *
2106   *              IF wa_item2-call_charges_final GT wa_item_l2-call_charges_final.
2107   *                MESSAGE e001(zbill) WITH wa_item2-reqt_num wa_item2-reqt_id.
2108   *              ENDIF.
2109   *              IF wa_item2-call_charges_final NE wa_item_l2-call_charges_final.
2110   *                IF wa_item2-sec_remarks IS INITIAL.
2111   *                  MESSAGE e006(zbill) WITH wa_item2-reqt_num wa_item2-reqt_id.
2112   *                ENDIF.
2113   *              ENDIF.
2114   *
2115   *              IF wa_item2-oth_charges_fin GT wa_item_l2-oth_charges.
2116   *                MESSAGE e001(zbill) WITH wa_item2-reqt_num wa_item2-reqt_id.
2117   *              ENDIF.
2118   *              IF wa_item2-oth_charges_fin NE wa_item_l2-oth_charges.
2119   *                IF wa_item2-sec_remarks IS INITIAL.
2120   *                  MESSAGE e006(zbill) WITH wa_item2-reqt_num wa_item2-reqt_id.
2121   *                ENDIF.
2122   *              ENDIF.
2123   *
2124   *              IF wa_item2-service_tax_fin GT wa_item_l2-service_tax.
2125   *                MESSAGE e001(zbill) WITH wa_item2-reqt_num wa_item2-reqt_id.
2126   *              ENDIF.
2127   *              IF wa_item2-service_tax_fin NE wa_item_l2-service_tax.
2128   *                IF wa_item2-sec_remarks IS INITIAL.
2129   *                  MESSAGE e006(zbill) WITH wa_item2-reqt_num wa_item2-reqt_id.
2130   *                ENDIF.
2131   *              ENDIF.
2132   *
2133   *            ENDIF.
2134   *
2135   **         If value is positive then only be triggereds
2136   *            IF wa_item2-security_dep_fin GT wa_item2-security_dep AND
2137   *               wa_item2-security_dep > 0.
2138   *              MESSAGE e001(zbill) WITH wa_item2-reqt_num wa_item2-reqt_id.
2139   *            ENDIF.
2140   *            IF wa_item2-security_dep_fin NE wa_item2-security_dep.
2141   *              IF wa_item2-remarks IS INITIAL.
2142   *                MESSAGE e006(zbill) WITH wa_item2-reqt_num wa_item2-reqt_id.
2143   *              ENDIF.
2144   *            ENDIF.
2145   *
2146   *            IF wa_item2-interest_fin GT wa_item2-interest AND
2147   *               wa_item2-interest > 0.
2148   *              MESSAGE e001(zbill) WITH wa_item2-reqt_num wa_item2-reqt_id.
2149   *            ENDIF.
2150   *            IF wa_item2-interest_fin NE wa_item2-interest_fin.
2151   *              IF wa_item2-remarks IS INITIAL.
2152   *                MESSAGE e006(zbill) WITH wa_item2-reqt_num wa_item2-reqt_id.
2153   *              ENDIF.
2154   *            ENDIF.
2155   *
2156   *            IF wa_item2-miscl_fin GT wa_item2-miscl AND
2157   *               wa_item2-miscl > 0.
2158   *              MESSAGE e001(zbill) WITH wa_item2-reqt_num wa_item2-reqt_id.
2159   *            ENDIF.
2160   *            IF wa_item2-miscl_fin NE wa_item2-miscl.
2161   *              IF wa_item2-remarks IS INITIAL.
2162   *                MESSAGE e006(zbill) WITH wa_item2-reqt_num wa_item2-reqt_id.
2163   *              ENDIF.
2164   *            ENDIF.
2165               ENDIF.
2166   ****************************** changes by bipin : on 20/01/2013    : end of changes
2167   ******************************* Added by bipin : on 20/01/2014 : for sec remarks in case of L2
2168
2169   *            IF WA_ITEM2-CALL_CHARGES_FINAL GT WA_ITEM2-CALL_CHARGE.
2170   *              MESSAGE E001(ZBILL) WITH WA_ITEM2-REQT_NUM WA_ITEM2-REQT_ID.
2171   *            ENDIF.
2172   *            IF WA_ITEM2-CALL_CHARGES_FINAL NE WA_ITEM2-CALL_CHARGE.
2173   *              IF WA_ITEM2-SEC_REMARKS IS INITIAL.
2174   *                MESSAGE E006(ZBILL) WITH WA_ITEM2-REQT_NUM WA_ITEM2-REQT_ID.
2175   *              ENDIF.
2176   *            ENDIF.
2177   *
2178   *            IF WA_ITEM2-OTH_CHARGES_FIN GT WA_ITEM2-OTH_CHARGES.
2179   *              MESSAGE E001(ZBILL) WITH WA_ITEM2-REQT_NUM WA_ITEM2-REQT_ID.
2180   *            ENDIF.
2181   *            IF WA_ITEM2-OTH_CHARGES_FIN NE WA_ITEM2-OTH_CHARGES.
2182   *              IF WA_ITEM2-SEC_REMARKS IS INITIAL.
2183   *                MESSAGE E006(ZBILL) WITH WA_ITEM2-REQT_NUM WA_ITEM2-REQT_ID.
2184   *              ENDIF.
2185   *            ENDIF.
2186   *
2187   *            IF WA_ITEM2-SERVICE_TAX_FIN GT WA_ITEM2-SERVICE_TAX.
2188   *              MESSAGE E001(ZBILL) WITH WA_ITEM2-REQT_NUM WA_ITEM2-REQT_ID.
2189   *            ENDIF.
2190   *            IF WA_ITEM2-SERVICE_TAX_FIN NE WA_ITEM2-SERVICE_TAX.
2191   *              IF WA_ITEM2-SEC_REMARKS IS INITIAL.
2192   *                MESSAGE E006(ZBILL) WITH WA_ITEM2-REQT_NUM WA_ITEM2-REQT_ID.
2193   *              ENDIF.
2194   *            ENDIF.
2195
2196               IF wa_item2-check1 = 'X'.
2197                 IF wa_item2-sec_remarks IS INITIAL.
2198
2199                   MESSAGE  e004(zbill).
2200                 ENDIF.
2201
2202               ENDIF.
2203             ENDIF.
2204
2205             IF ok_code = 'SAVE'.
2206
2207               IF wa_item2-check = 'X'.
2208                 wa_item2-sts_flag = 'A'.
2209               ELSEIF wa_item2-check1 = 'X'.
2210                 IF wa_item2-sec_remarks IS NOT INITIAL.
2211                   wa_item2-sts_flag = 'R'.
2212                 ELSE.
2213                   MESSAGE  e004(zbill).
2214                 ENDIF.
2215               ELSEIF  wa_item2-check = '' AND wa_item2-check1 = ''.
2216                 wa_item2-sts_flag = ''.
2217               ENDIF.
2218
2219             ENDIF.
2220           ENDIF.
2221
2222
2223   ******************************************* for posting
2224   ************************** Bellow code comment by bipin on 20/01/2014 : start of changes
2225   *        IF OK_CODE = 'EXECUTE'.
2226   *          IF WA_ITEM2-RENT_FINAL GT WA_ITEM2-RENT.
2227   *            MESSAGE E001(ZBILL) WITH WA_ITEM2-REQT_NUM WA_ITEM2-REQT_ID.
2228   *          ENDIF.
2229   *          IF WA_ITEM2-RENT_FINAL NE WA_ITEM2-RENT.
2230   *            IF WA_ITEM2-SEC_REMARKS IS INITIAL.
2231   *              MESSAGE E006(ZBILL) WITH WA_ITEM2-REQT_NUM WA_ITEM2-REQT_ID.
2232   *            ENDIF.
2233   *
2234   *          ENDIF.
2235   *
2236   *          IF WA_ITEM2-CALL_CHARGES_FINAL GT WA_ITEM2-CALL_CHARGE.
2237   *            MESSAGE E001(ZBILL) WITH WA_ITEM2-REQT_NUM WA_ITEM2-REQT_ID.
2238   *          ENDIF.
2239   *          IF WA_ITEM2-CALL_CHARGES_FINAL NE WA_ITEM2-CALL_CHARGE.
2240   *            IF WA_ITEM2-SEC_REMARKS IS INITIAL.
2241   *              MESSAGE E006(ZBILL) WITH WA_ITEM2-REQT_NUM WA_ITEM2-REQT_ID.
2242   *            ENDIF.
2243   *          ENDIF.
2244   *
2245   *          IF WA_ITEM2-OTH_CHARGES_FIN GT WA_ITEM2-OTH_CHARGES.
2246   *            MESSAGE E001(ZBILL) WITH WA_ITEM2-REQT_NUM WA_ITEM2-REQT_ID.
2247   *          ENDIF.
2248   *          IF WA_ITEM2-OTH_CHARGES_FIN NE WA_ITEM2-OTH_CHARGES.
2249   *            IF WA_ITEM2-SEC_REMARKS IS INITIAL.
2250   *              MESSAGE E006(ZBILL) WITH WA_ITEM2-REQT_NUM WA_ITEM2-REQT_ID.
2251   *            ENDIF.
2252   *          ENDIF.
2253   *
2254   *          IF WA_ITEM2-SERVICE_TAX_FIN GT WA_ITEM2-SERVICE_TAX.
2255   *            MESSAGE E001(ZBILL) WITH WA_ITEM2-REQT_NUM WA_ITEM2-REQT_ID.
2256   *          ENDIF.
2257   *          IF WA_ITEM2-SERVICE_TAX_FIN NE WA_ITEM2-SERVICE_TAX.
2258   *            IF WA_ITEM2-SEC_REMARKS IS INITIAL.
2259   *              MESSAGE E006(ZBILL) WITH WA_ITEM2-REQT_NUM WA_ITEM2-REQT_ID.
2260   *            ENDIF.
2261   *          ENDIF.
2262   *        ENDIF.
2263   ************************** above code comment by bipin on 20/01/2014 : end of changes
2264   ******************************************* for posting
2265
2266
2267
2268           wa_item2-status = wa_item2-status+0(1).
2269   ***************************************** CODE FOR REJECTED LINE ITEM TO CHANGE ONLY STATUS
2270
2271           IF ok_code = 'EXECUTE' OR ok_code = 'EXPOST'.
2272             IF wa_item2-check1 IS NOT INITIAL AND sy-tcode = 'ZFIBD_PROCESS'." AND WA_ITEM2-REMARKS IS NOT INITIAL.
2273
2274               IF wa_item2-remarks IS NOT INITIAL.
2275                 wa_item2-status = '3'.
2276               ELSE.
2277                 MESSAGE  e004(zbill).
2278               ENDIF.
2279
2280             ELSEIF wa_item2-check1 IS NOT INITIAL AND sy-tcode = 'ZFIBD_POST'.
2281               IF wa_item2-sec_remarks IS NOT INITIAL.
2282                 wa_item2-status = '5'.
2283               ELSE.
2284                 MESSAGE  e004(zbill).
2285               ENDIF.
2286             ENDIF.
2287           ENDIF.
2288   ********************************************** changes by Bipin on 21/01/2014
2289
2290   *        IF OK_CODE = 'SAVE' ." OR OK_CODE = 'EXPOST'.
2291   *          IF REJ_FLAG NE 'R'.
2292   *            IF WA_ITEM2-CHECK1 IS NOT INITIAL AND SY-TCODE = 'ZFIBD_PROCESS'." AND WA_ITEM2-REMARKS IS NOT INITIAL.
2293   *
2294   *              IF WA_ITEM2-REMARKS IS NOT INITIAL.
2295   **              WA_ITEM2-STATUS = '3'.
2296   **            ELSE.
2297   *                MESSAGE  E004(ZBILL).
2298   *              ENDIF.
2299   *
2300   *            ELSEIF WA_ITEM2-CHECK1 IS NOT INITIAL AND SY-TCODE = 'ZFIBD_POST'.
2301   *              IF WA_ITEM2-SEC_REMARKS IS NOT INITIAL.
2302   **              WA_ITEM2-STATUS = '5'.
2303   **            ELSE.
2304   *                MESSAGE  E004(ZBILL).
2305   *              ENDIF.
2306   *            ENDIF.
2307   *          ENDIF.
2308   *        ENDIF.
2309
2310   ********************************************** changes by Bipin on 21/01/2014
2311           IF ok_code = 'EXECUTE' OR ok_code = 'EXPOST'.
2312             IF wa_item2-check IS NOT INITIAL AND sy-tcode = 'ZFIBD_PROCESS'.
2313   *        CONCATENATE WA_ITEM2-REQT_NUM ALL_REQ INTO ALL_REQ SEPARATED BY SPACE.
2314               all_req = wa_item2-reqt_num.
2315             ENDIF.
2316           ENDIF.
2317   ***************************************** CODE FOR REJECTED LINE ITEM TO CHANGE ONLY STATUS
2318
2319
2320           MOVE-CORRESPONDING wa_item2 TO wa_zbill_data.
2321
2322           IF sy-tcode = 'ZFIBD_POST' AND ok_code = 'EXECUTE'.
2323             wa_zbill_data-pernr = wa_item2-pernr.
2324           ELSE.
2325             CLEAR wa_zbill_data-pernr.
2326           ENDIF.
2327
2328
2329           MOVE sy-mandt TO wa_zbill_data-mandt.
2330           APPEND wa_zbill_data TO it_zbill_data.
2331           CLEAR : wa_zbill_data,wa_item2.
2332   *    UPDATE ZBILL_DATA FROM TABLE IT_ZBILL_DATA. " ADDED BY BIPIN 28/10/2013
2333         ENDLOOP.
2334         UPDATE zbill_data FROM TABLE it_zbill_data.
2335         COMMIT WORK AND WAIT.
2336   *  UPDATE ZBILL_DATA FROM TABLE IT_ZBILL_DATA.
2337
2338
2339
2340
2341         IF sy-subrc EQ 0.
2342
2343           IF sy-tcode = 'ZFIBD_PROCESS'.
2344             docdata-obj_descr = 'Request approved by INFOCOM'. " Mail subject
2345
2346   *************      mail body
2347             CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
2348               EXPORTING
2349                 date_internal            = sy-datum
2350               IMPORTING
2351                 date_external            = lv_date
2352               EXCEPTIONS
2353                 date_internal_is_invalid = 1
2354                 OTHERS                   = 2.
2355             WRITE sy-uzeit TO lv_time USING EDIT MASK '__:__:__'.
2356             IF sy-subrc <> 0.
2357   * Implement suitable error handling here
2358             ENDIF.
2359             CALL FUNCTION 'STF4_GET_DOMAIN_VALUE_TEXT'
2360               EXPORTING
2361                 iv_domname      = 'ZBILL_TYPE'
2362                 iv_value        = bil_type
2363               IMPORTING
2364                 ev_value_text   = lv_btype
2365               EXCEPTIONS
2366                 value_not_found = 1
2367                 OTHERS          = 2.
2368             IF sy-subrc <> 0.
2369   * Implement suitable error handling here
2370             ENDIF.
2371
2372             CONCATENATE lv_btype
2373             ' Bill has been approved with following request' all_req 'on'
2374             ' date ' lv_date
2375             ' time: '  lv_time
2376             INTO wa_objhead-line
2377             SEPARATED BY space.
2378
2379             APPEND wa_objhead TO gt_objhead.
2380             CLEAR wa_objhead.
2381
2382             wa_objhead-line = 'Kindly check and approve.'.
2383   *
2384             APPEND wa_objhead TO gt_objhead.
2385             CLEAR wa_objhead.
2386
2387
2388
2389   ******** Code for Mail sending SAP inbox
2390
2391   *APPEND 'ZFIBD_POST' TO T_TCODE.
2392
2393   " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
2394   *          SELECT SINGLE * FROM zbill_auth
2395   *          INTO CORRESPONDING FIELDS OF  wa_uname
2396   *          WHERE tcode = 'ZFIBD_POST' AND
2397   *          comp_code = bukrs  AND
2398   *          bill_type = bil_type.
2399    SELECT * FROM ZBILL_AUTH   UP TO 1 ROWS INTO CORRESPONDING FIELDS OF
2400   WA_UNAME WHERE TCODE = 'ZFIBD_POST' AND COMP_CODE = BUKRS AND BILL_TYPE
2401   = BIL_TYPE  ORDER BY  TCODE COMP_CODE BILL_TYPE APPROVER .   ENDSELECT.
2402   " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
2403
2404
2405             wa_reclist-receiver  = wa_uname-approver.
2406             wa_reclist-rec_type = 'B'.
2407             APPEND wa_reclist TO gt_reclist.
2408
2409
2410             DESCRIBE TABLE gt_objhead LINES lv_tab_lines.
2411             CLEAR wa_objpack-transf_bin.
2412             wa_objpack-head_start = 1.
2413             wa_objpack-head_num = 0.
2414             wa_objpack-body_start = 1.
2415             wa_objpack-body_num = lv_tab_lines.
2416             wa_objpack-doc_type = 'RAW'.
2417             APPEND wa_objpack TO gt_objpack.
2418
2419
2420             CALL FUNCTION 'SO_NEW_DOCUMENT_ATT_SEND_API1'
2421               EXPORTING
2422                 document_data              = docdata
2423                 put_in_outbox              = 'X'
2424                 commit_work                = 'X'
2425               TABLES
2426                 packing_list               = gt_objpack[]
2427   *             OBJECT_HEADER              =
2428   *             CONTENTS_BIN               =
2429                 contents_txt               = gt_objhead[]
2430   *             CONTENTS_HEX               =
2431   *             OBJECT_PARA                =
2432   *             OBJECT_PARB                =
2433                 receivers                  = gt_reclist[]
2434               EXCEPTIONS
2435                 too_many_receivers         = 1
2436                 document_not_sent          = 2
2437                 document_type_not_exist    = 3
2438                 operation_no_authorization = 4
2439                 parameter_error            = 5
2440                 x_error                    = 6
2441                 enqueue_error              = 7
2442                 OTHERS                     = 8.
2443             IF sy-subrc EQ 0.
2444   * Implement suitable error handling here
2445   *        MESSAGE 'Mail successfully sent to creator !!' TYPE 'S'.
2446             ENDIF.
2447
2448
2449
2450   ******** Code for Mail sending SAP inbox
2451   *
2452   *      APPEND 'ZFIBD_POST' TO T_TCODE.
2453
2454   *      CALL FUNCTION 'ZBILL_MAIL'
2455   *        EXPORTING
2456   *          IT_TCODE             = T_TCODE
2457   *          IM_COMP_CODE         = BUKRS
2458   *          IM_BILL_TYPE         = BIL_TYPE
2459   *          IT_MAIL_CONTENT      = GT_OBJHEAD
2460   *          IM_DOC_CHNG          = DOCDATA
2461   *        EXCEPTIONS
2462   *          NO_CONFIG_MAINTAINED = 1
2463   *          NO_USER_IN_HR        = 2
2464   *          OTHERS               = 3.
2465   *      IF SY-SUBRC <> 0.
2466   ** Implement suitable error handling here
2467   *      ENDIF.
2468
2469           ENDIF.
2470
2471
2472
2473
2474           IF ok_code = 'EXPOST'. "OR OK_CODE = 'EXECUTE'.
2475             MESSAGE 'Your data saved.'
2476                                        TYPE 'S'.
2477             PERFORM dequeue_data.
2478             LEAVE TO SCREEN 0.
2479           ENDIF.
2480
2481           IF ok_code = 'EXECUTE'.
2482             IMPORT lv_ret_type FROM MEMORY ID 'LV_RET'.
2483
2484
2485             IF lv_ret_type = 'S'.
2486               CLEAR : post_msg.
2487               IMPORT post_doc FROM MEMORY ID 'P_DOC'.
2488               IMPORT post_comp_code FROM MEMORY ID 'P_CC'.
2489               IMPORT post_year FROM MEMORY ID 'P_DOC'.
2490
2491               CONCATENATE post_msg 'Accounting Document No.' post_doc 'Company Code' post_comp_code 'and Fiscal year' post_year '.' INTO post_msg
2492               SEPARATED BY space.
2493
2494
2495
2496
2497               CALL FUNCTION 'POPUP_TO_INFORM'
2498                 EXPORTING
2499                   titel = 'Accounting Document'
2500                   txt1  = 'Posting successfully done.'
2501                   txt2  = post_msg
2502   *               TXT3  = ' '
2503   *               TXT4  = ' '
2504                 .
2505
2506               FREE MEMORY ID 'LV_RET'.
2507               MESSAGE 'Your data saved.' TYPE 'S'.
2508               PERFORM dequeue_data.
2509               LEAVE TO SCREEN 0.
2510
2511             ENDIF.
2512
2513           ENDIF.
2514
2515         ENDIF.
2516       ENDFORM.                    " SAVE_DATA
2517
2518   *---------------------------------------------------------------------*
2519   *       CLASS lcl_alv_toolbar IMPLEMENTATION
2520   *---------------------------------------------------------------------*
2521   *       ALV event handler
2522   *---------------------------------------------------------------------*
2523       CLASS lcl_alv_toolbar IMPLEMENTATION.
2524         METHOD constructor.
2525   *   Create ALV toolbar manager instance
2526           CREATE OBJECT c_alv_toolbarmanager
2527             EXPORTING
2528               io_alv_grid = io_alv_grid.
2529         ENDMETHOD.                    "constructor
2530
2531         METHOD on_toolbar.
2532   *    BREAK SAB_VAIBHAV.
2533           CHECK sy-tcode <> 'ZFIBD_REPORT'.
2534   *  Below Code Commented by ROhit Agrawal
2535   *   Add customized toolbar buttons.
2536   *   variable for Toolbar Button
2537           wa_toolbar-function  = 'SALL'.
2538           wa_toolbar-icon      =  icon_select_all.
2539           wa_toolbar-quickinfo =  'Select All'.
2540           wa_toolbar-text      =  'Select'.
2541           wa_toolbar-butn_type = 0.
2542   *    wa_toolbar-text = ''.
2543           APPEND wa_toolbar TO e_object->mt_toolbar.
2544           wa_toolbar-function = 'DALL'.
2545           wa_toolbar-icon      =  icon_deselect_all.
2546           wa_toolbar-quickinfo =  'Deselect All'.
2547           wa_toolbar-text      =  'Deselect'.
2548           wa_toolbar-butn_type = 0.
2549   **    wa_toolbar-text = ''.
2550   *
2551           APPEND wa_toolbar TO e_object->mt_toolbar.
2552   ***   Call reorganize method of toolbar manager to
2553   ***   display the toolbar
2554   *    CALL METHOD C_ALV_TOOLBARMANAGER->REORGANIZE
2555   *      EXPORTING
2556   *        IO_ALV_TOOLBAR = E_OBJECT.
2557         ENDMETHOD.                    "on_toolbar
2558
2559         METHOD handle_user_command.
2560
2561           CALL METHOD r_grid->get_selected_columns
2562             IMPORTING
2563               et_index_columns = gt_sel_col.
2564
2565           CASE e_ucomm.
2566             WHEN 'SALL'.
2567               PERFORM select_all.
2568             WHEN 'DALL'.
2569               PERFORM deselect_all.
2570           ENDCASE.
2571           CALL METHOD r_grid->refresh_table_display
2572   *      EXPORTING
2573   *        is_stable      =
2574   *        i_soft_refresh =
2575           EXCEPTIONS
2576             finished       = 1
2577             OTHERS         = 2.
2578
2579         ENDMETHOD.                    "HANDLE_USER_COMMAND
2580         METHOD handle_hotspot_click.
2581           DATA : lt_msg TYPE esp1_message_tab_type.
2582           CLEAR wa_item2.
2583           READ TABLE it_item2 INTO wa_item2 INDEX e_row_id-index.
2584
2585
2586
2587           IF sy-subrc EQ 0.
2588             CALL FUNCTION 'C14ALD_BAPIRET2_SHOW'
2589               TABLES
2590                 i_bapiret2_tab = wa_item2-t_msg.
2591           ENDIF.
2592
2593         ENDMETHOD.                           "handle_user_command
2594
2595       ENDCLASS.                    "lcl_alv_toolbar IMPLEMENTATION
2596   *&---------------------------------------------------------------------*
2597   *&      Form  SELECT_ALL
2598   *&---------------------------------------------------------------------*
2599   *       text
2600   *----------------------------------------------------------------------*
2601   *  -->  p1        text
2602   *  <--  p2        text
2603   *----------------------------------------------------------------------*
2604       FORM select_all.
2605
2606
2607
2608         READ TABLE gt_sel_col INTO wa_sel_col WITH KEY fieldname = 'CHECK'.
2609         IF sy-subrc EQ 0.
2610           LOOP AT it_item2 INTO wa_item2 WHERE rowcolor NE 'C600'.
2611             MOVE abap_true TO wa_item2-check.
2612             MOVE abap_false TO wa_item2-check1.
2613             MODIFY it_item2 FROM wa_item2 INDEX sy-tabix TRANSPORTING check check1.
2614           ENDLOOP.
2615         ENDIF.
2616
2617         READ TABLE gt_sel_col INTO wa_sel_col WITH KEY fieldname = 'CHECK1'.
2618         IF sy-subrc EQ 0.
2619           CLEAR : rej_flag.
2620           rej_flag = 'R'.
2621           LOOP AT it_item2 INTO wa_item2 WHERE rowcolor NE 'C600'.
2622             MOVE abap_true TO wa_item2-check1.
2623             MOVE abap_false TO wa_item2-check.
2624             MODIFY it_item2 FROM wa_item2 INDEX sy-tabix TRANSPORTING check1 check.
2625           ENDLOOP.
2626         ENDIF.
2627
2628
2629       ENDFORM.                    " SELECT_ALL
2630   *&---------------------------------------------------------------------*
2631   *&      Form  DESELECT_ALL
2632   *&---------------------------------------------------------------------*
2633   *       text
2634   *----------------------------------------------------------------------*
2635   *  -->  p1        text
2636   *  <--  p2        text
2637   *----------------------------------------------------------------------*
2638       FORM deselect_all .
2639
2640         READ TABLE gt_sel_col INTO wa_sel_col WITH KEY fieldname = 'CHECK'.
2641         IF sy-subrc EQ 0.
2642           LOOP AT it_item2 INTO wa_item2 WHERE rowcolor NE 'C600'.
2643             MOVE abap_false TO wa_item2-check.
2644   *          MOVE ABAP_FALSE TO WA_ITEM2-CHECK1.
2645             MODIFY it_item2 FROM wa_item2 INDEX sy-tabix TRANSPORTING check .
2646           ENDLOOP.
2647         ENDIF.
2648
2649         READ TABLE gt_sel_col INTO wa_sel_col WITH KEY fieldname = 'CHECK1'.
2650         IF sy-subrc EQ 0.
2651           LOOP AT it_item2 INTO wa_item2 WHERE rowcolor NE 'C600'.
2652   *          MOVE ABAP_TRUE TO WA_ITEM2-CHECK1.
2653             MOVE abap_false TO wa_item2-check1.
2654             MODIFY it_item2 FROM wa_item2 INDEX sy-tabix TRANSPORTING check1 .
2655           ENDLOOP.
2656         ENDIF.
2657
2658   *      LOOP AT IT_ITEM2 INTO WA_ITEM2.
2659   *        MOVE ABAP_FALSE TO WA_ITEM2-CHECK.
2660   *        MODIFY IT_ITEM2 FROM WA_ITEM2 INDEX SY-TABIX TRANSPORTING CHECK.
2661   *      ENDLOOP.
2662       ENDFORM.                    " DESELECT_ALL
2663   **&---------------------------------------------------------------------*
2664   **&      Form  POST_RECORDS
2665   **&---------------------------------------------------------------------*
2666   **       text
2667   **----------------------------------------------------------------------*
2668   **  -->  p1        text
2669   **  <--  p2        text
2670   **----------------------------------------------------------------------*
2671   *    FORM post_records .
2672   *      TYPES : BEGIN OF ty_billtype,
2673   *      key TYPE char10,
2674   *      text TYPE c LENGTH 60,
2675   *      END OF ty_billtype.
2676   *
2677   *      TYPES : BEGIN OF ty_error,
2678   *      er_type TYPE bapi_mtype,
2679   *      msg_id TYPE symsgid,
2680   *      msg_num TYPE symsgno,
2681   *      msg TYPE bapi_msg,
2682   *      reqnum TYPE  zbill_req_nm,
2683   *      END OF ty_error.
2684   *
2685   *      DATA :  it_error TYPE TABLE OF ty_error,
2686   *            wa_error TYPE          ty_error.
2687   *
2688   *      TYPES : BEGIN OF ty_error1,
2689   *      er_type TYPE bapi_mtype,
2690   *      msg_id TYPE symsgid,
2691   *      msg_num TYPE symsgno,
2692   *      msg TYPE bapi_msg,
2693   *      reqnum TYPE  zbill_req_nm,
2694   *      pernr TYPE pernr_d,
2695   *      END OF ty_error1.
2696   *
2697   *      DATA :  it_error1 TYPE TABLE OF ty_error1,
2698   *            wa_error1 TYPE          ty_error1.
2699   *
2700   *      DATA : wa_header TYPE bapiache09,
2701   *            wa_accountgl TYPE bapiacgl09,
2702   *            wa_accountgl2 TYPE bapiacgl09,
2703   *            wa_payable TYPE bapiacap09,
2704   *            it_accountgl TYPE STANDARD TABLE OF bapiacgl09,
2705   *            it_accountgl1 TYPE STANDARD TABLE OF bapiacgl09,
2706   *            it_accountgl2 TYPE STANDARD TABLE OF bapiacgl09,
2707   *            it_payable TYPE STANDARD TABLE OF bapiacap09,
2708   *            wa_return TYPE bapiret2,
2709   *            it_return TYPE STANDARD TABLE OF bapiret2,
2710   *            it_values TYPE re_t_rsdomaval,
2711   *            wa_values TYPE LINE OF re_t_rsdomaval,
2712   *            it_billtype TYPE STANDARD TABLE OF ty_billtype,
2713   *            wa_billtype TYPE ty_billtype,
2714   *            it_billhead TYPE STANDARD TABLE OF zbill_head,
2715   *            wa_billhead TYPE zbill_head,
2716   *            it_currency TYPE STANDARD TABLE OF bapiaccr09,
2717   *            it_currency1 TYPE STANDARD TABLE OF bapiaccr09,
2718   *            wa_currency TYPE bapiaccr09,
2719   *            wa_extension TYPE bapiparex,
2720   *            it_extension TYPE bapiparex_tab_ac,
2721   *            lv_total TYPE zbill_call_charges,
2722   *            l_total_pay TYPE zbill_call_charges,
2723   *            l_total_acc TYPE zbill_call_charges,
2724   *            l_kst01 TYPE kostl,
2725   *            lv_item TYPE posnr_acc,
2726   *            ind TYPE sy-index,
2727   *            lv_attach_check TYPE char1,
2728   *            wa_pa9105 TYPE p9105,
2729   *            it_pa9105 TYPE TABLE OF p9105, " + BY SAB_BIPIN ON 11/11/2013
2730   *            it_pa9105_1 TYPE TABLE OF p9105, " + BY SAB_BIPIN ON 11/11/2013
2731   *            it_pa9105_2 TYPE TABLE OF p9105, " + BY SAB_BIPIN ON 11/11/2013
2732   *            it_pa9105_3 TYPE TABLE OF p9105, " + BY SAB_BIPIN ON 11/11/2013
2733   *            it_pa9105_4 TYPE TABLE OF p9105, " + BY SAB_BIPIN ON 11/11/2013
2734   *            it_pa9105_5 TYPE TABLE OF p9105, " + BY SAB_BIPIN ON 11/11/2013
2735   *            it_data_temp TYPE TABLE OF p9105,
2736   *            lt_pa9205 TYPE TABLE OF pa9205,
2737   *            wa_pa9205 TYPE pa9205,
2738   *            lv_len TYPE i,
2739   *            lv_phone10 TYPE char11,
2740   *            lv_phone11 TYPE char11,
2741   *            lv_phone_len TYPE i.
2742   *
2743   *
2744   *      DATA : wa_user TYPE bapip0001.
2745   *
2746   *      DATA : it_bapireturn TYPE STANDARD TABLE OF bapireturn1,
2747   *            l_bapireturn TYPE bapireturn1,
2748   *            l_key TYPE bapipakey,
2749   *            l_return        TYPE bapireturn1.
2750   **        ls_doc_data TYPE          ty_item1.
2751   *
2752   *      TYPES :  BEGIN OF ty_hr_return,
2753   *      ermsg_type  TYPE bapi_mtype,
2754   *      er_id  TYPE symsgid,
2755   *      er_number TYPE symsgno,
2756   *      er_message TYPE bapi_msg,
2757   *      pernr TYPE persno,
2758   *      re_num  TYPE zbill_req_nm,
2759   *      END OF ty_hr_return.
2760   *
2761   *      DATA : it_hr_return TYPE TABLE OF ty_hr_return,
2762   *            lv_phn_land    TYPE zhrphone,
2763   *            wa_hr_return TYPE ty_hr_return.
2764   *
2765   ****************   Data Declaration for parallel prosessing : + by Bipin on 06/12/2013
2766   *
2767   **  DATA : LV_APPSVR TYPE RZLLITAB-CLASSNAME VALUE 'parallel_generators'.
2768   **
2769   **  DATA : LV_PP_TOTAL     TYPE I,                                                   " Total no of dialog work process available in the group server
2770   **       LV_AVAILABLE TYPE I,                                                   " No of dialog work process that are free.
2771   **       LV_OCCUPIED  TYPE I,                                                   " No of occupied dialog process
2772   **       LV_DIFF      TYPE I,                                                   " Percentage difference of available work process
2773   **       LV_SPLIT     TYPE I.                                                   " No of partitions the main data is to be split
2774   **
2775   **  DATA : LV_LINES TYPE I,                                                       " No of records in the internal table
2776   **         LV_LINES_TAB TYPE I,                                                   " No of lines per tab
2777   **         LV_START TYPE I,                                                       " Start point for processing
2778   **         LV_END TYPE I.                                                         " End point for processing
2779   **
2780   **  DATA : LV_TASK TYPE STRING,                                                   " Name of the task to be created
2781   **         LV_INDEX TYPE STRING,                                                  " Variable for index
2782   **         LV_SENT  TYPE I,                                                       " No of package sent
2783   **         LV_COMP  TYPE I,                                                       " No of package completed
2784   **         LV_RESULT TYPE FLAG.                                                   " Variable to collect the result.
2785   **
2786   **  DATA : LV_RESULT_STRING TYPE STRING.
2787   **
2788   **  DATA: FUNCTIONCALL1(1) TYPE C.
2789   **  CONSTANTS: DONE(1) TYPE C VALUE 'X'.
2790   ****************   Data Declaration for parallel prosessing : + by Bipin on 06/12/2013
2791   *
2792   *
2793   *      DELETE it_item2 WHERE status   EQ '6'.
2794   *
2795   *
2796   *      SORT it_item2 BY bukrs reqt_num reqt_id.
2797   *      IF it_item2 IS NOT INITIAL.
2798   *        SELECT * FROM zbill_head
2799   *        INTO TABLE it_billhead
2800   *        FOR ALL ENTRIES IN it_item2
2801   *        WHERE reqt_num EQ it_item2-reqt_num.
2802   *        IF sy-subrc EQ 0.
2803   *          SORT it_billhead BY reqt_num.
2804   *        ENDIF.
2805   *      ELSE.
2806   *        MESSAGE 'Please select the records which are not processed.' TYPE 'I'.
2807   *      ENDIF.
2808   *
2809   *      CALL METHOD cl_reca_ddic_doma=>get_values
2810   *        EXPORTING
2811   *          id_name   = 'ZBILL_TYPE'
2812   *          id_langu  = sy-langu
2813   *        IMPORTING
2814   *          et_values = it_values
2815   *        EXCEPTIONS
2816   *          not_found = 1
2817   *          OTHERS    = 2.
2818   *      IF sy-subrc EQ 0.
2819   *        LOOP AT it_values INTO wa_values.
2820   *          MOVE : wa_values-domvalue_l TO wa_billtype-key,
2821   *          wa_values-ddtext TO wa_billtype-text.
2822   *          APPEND wa_billtype TO it_billtype.
2823   *          CLEAR : wa_billtype,wa_values.
2824   *        ENDLOOP.
2825   *      ENDIF.
2826   *
2827   **BREAK-POINT.
2828   *      SORT it_item2 BY   reqt_num.
2829   *
2830   ******************************************* code added by Bipin Shukla : 23/12/2013 : for comp code
2831   ** FOR MAITAIN  COMPANY CODE BASED ON COST CENTER
2832   *      IF it_item2 IS NOT INITIAL.
2833   *
2834   *        SELECT * FROM zbill_gl INTO CORRESPONDING FIELDS OF TABLE gt_bill_gl
2835   *        FOR ALL ENTRIES IN it_item2
2836   *        WHERE bill_type = it_item2-bill_type.
2837   *        IF sy-subrc = 0.
2838   *          SELECT * INTO TABLE it_ska1
2839   *          FROM ska1
2840   *          FOR ALL ENTRIES IN gt_bill_gl
2841   *          WHERE
2842   *          saknr = gt_bill_gl-hkont
2843   *          AND
2844   *          xbilk <> 'X'
2845   *          AND
2846   *          ktopl = wa_t001-ktopl..
2847   *
2848   *
2849   *        ENDIF.
2850   *      ENDIF.
2851   *
2852   *      LOOP AT it_billhead INTO wa_billhead.
2853   *        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
2854   *          EXPORTING
2855   *            input  = wa_billhead-serv_prov
2856   *          IMPORTING
2857   *            output = wa_billhead-serv_prov.
2858   *        MODIFY it_billhead FROM wa_billhead.
2859   *      ENDLOOP.
2860   *      IF it_billhead IS NOT INITIAL.
2861   *        SELECT * FROM lfb1 INTO CORRESPONDING FIELDS OF TABLE gt_lfb1
2862   *        FOR ALL ENTRIES IN it_billhead
2863   *        WHERE bukrs = it_billhead-bukrs AND lifnr = it_billhead-serv_prov.
2864   *      ENDIF.
2865   ******************************************* code added by Bipin Shukla : 23/12/2013 : for comp code
2866   *
2867   *      FIELD-SYMBOLS : <fs_amt> TYPE any.
2868   *      REFRESH it_zbill_gl.
2869   *      DATA l_kts01 TYPE kostl.
2870   *
2871   *      CALL FUNCTION 'G_SET_GET_ID_FROM_NAME'
2872   *        EXPORTING
2873   *          shortname = 'Z_COST_CTR_CENVAT'       "Set Name
2874   *        IMPORTING
2875   *          new_setid = w_setid
2876   *        EXCEPTIONS
2877   *          OTHERS    = 1.
2878   *
2879   *      CALL FUNCTION 'G_SET_FETCH'
2880   *        EXPORTING
2881   *          setnr           = w_setid
2882   *        TABLES
2883   *          set_lines_basic = int_vlaues
2884   *        EXCEPTIONS
2885   *          OTHERS          = 1.
2886   *
2887   *      SORT it_item2 BY check.
2888   *      LOOP AT it_item2 INTO wa_item2 WHERE check IS NOT INITIAL.
2889   ************************************************  for HR table updation
2890   *        wa_user-pernr = wa_item2-pernr.
2891   ************************************************  for HR table updation
2892   *        CLEAR l_kts01.
2893   *        READ TABLE int_vlaues INTO wa_vlaues WITH KEY from = wa_item2-kst01.
2894   *        IF sy-subrc EQ 0.
2895   *          LOOP AT gt_bill_gl INTO wa_bill_gl.
2896   *            CLEAR wa_zbill_gl.
2897   *            ASSIGN COMPONENT wa_bill_gl-expence OF STRUCTURE wa_item2 TO <fs_amt>.
2898   *            IF <fs_amt> IS ASSIGNED.
2899   *              IF wa_bill_gl-alt_hkont IS NOT INITIAL.
2900   *                READ TABLE it_ska1 INTO wa_ska1 WITH KEY saknr = wa_bill_gl-alt_hkont.
2901   *                IF sy-subrc <> 0.
2902   *                  CLEAR l_kst01.
2903   *                ELSE.
2904   *                  l_kst01 = wa_item2-kst01.
2905   *                ENDIF.
2906   *                READ TABLE it_zbill_gl INTO wa_zbill_gl WITH KEY hkont = wa_bill_gl-alt_hkont
2907   *                costcenter = l_kst01."WA_ITEM2-KST01..
2908   *                IF sy-subrc = 0.
2909   *                  wa_zbill_gl-amount = wa_zbill_gl-amount + <fs_amt>.
2910   *                  MODIFY it_zbill_gl FROM wa_zbill_gl INDEX sy-tabix.
2911   *                ELSE.
2912   *                  READ TABLE it_ska1 INTO wa_ska1 WITH KEY saknr = wa_bill_gl-alt_hkont.
2913   *                  IF sy-subrc = 0.
2914   *                    wa_zbill_gl-costcenter = wa_item2-kst01.
2915   *                  ELSE.
2916   *                    CLEAR wa_zbill_gl-costcenter.
2917   *                  ENDIF.
2918   *                  wa_zbill_gl-hkont = wa_bill_gl-alt_hkont.
2919   *                  wa_zbill_gl-amount = <fs_amt>.
2920   *                  IF wa_zbill_gl-amount NE '0'. " + by Bipin on 20/11/2013
2921   *                    APPEND wa_zbill_gl TO it_zbill_gl.
2922   *                  ENDIF.                       " + by Bipin on 20/11/2013
2923   *                ENDIF.
2924   *              ELSE. " + BY BIPIN ON 26/11/2012
2925   *                READ TABLE it_ska1 INTO wa_ska1 WITH KEY saknr = wa_bill_gl-hkont.
2926   *                IF sy-subrc <> 0.
2927   *                  CLEAR l_kst01.
2928   *                ELSE.
2929   *                  l_kst01 = wa_item2-kst01.
2930   *                ENDIF.
2931   *                READ TABLE it_zbill_gl INTO wa_zbill_gl WITH KEY hkont = wa_bill_gl-hkont
2932   *                costcenter = l_kst01."WA_ITEM2-KST01..
2933   *                IF sy-subrc = 0.
2934   *                  wa_zbill_gl-amount = wa_zbill_gl-amount + <fs_amt>.
2935   *                  MODIFY it_zbill_gl FROM wa_zbill_gl INDEX sy-tabix.
2936   *                ELSE.
2937   *                  READ TABLE it_ska1 INTO wa_ska1 WITH KEY saknr = wa_bill_gl-hkont.
2938   *                  IF sy-subrc = 0.
2939   *                    wa_zbill_gl-costcenter = wa_item2-kst01.
2940   *                  ELSE.
2941   *                    CLEAR wa_zbill_gl-costcenter.
2942   *                  ENDIF.
2943   *                  wa_zbill_gl-hkont = wa_bill_gl-hkont.
2944   *                  wa_zbill_gl-amount = <fs_amt>.
2945   *                  IF wa_zbill_gl-amount NE '0'. " + by Bipin on 20/11/2013
2946   *                    APPEND wa_zbill_gl TO it_zbill_gl.
2947   *                  ENDIF.                       " + by Bipin on 20/11/2013
2948   *                ENDIF.
2949   *              ENDIF. " + BY BIPIN ON 26/11/2012
2950   *            ENDIF.
2951   *          ENDLOOP.
2952   *
2953   *        ELSE.
2954   *
2955   *          LOOP AT gt_bill_gl INTO wa_bill_gl.
2956   *            CLEAR wa_zbill_gl.
2957   *            ASSIGN COMPONENT wa_bill_gl-expence OF STRUCTURE wa_item2 TO <fs_amt>.
2958   *            IF <fs_amt> IS ASSIGNED.
2959   *
2960   *              READ TABLE it_ska1 INTO wa_ska1 WITH KEY saknr = wa_bill_gl-hkont.
2961   *              IF sy-subrc <> 0.
2962   *                CLEAR l_kst01.
2963   *              ELSE.
2964   *                l_kst01 = wa_item2-kst01.
2965   *              ENDIF.
2966   *
2967   *              READ TABLE it_zbill_gl INTO wa_zbill_gl WITH KEY hkont = wa_bill_gl-hkont
2968   *              costcenter = l_kst01."WA_ITEM2-KST01..
2969   *              IF sy-subrc = 0.
2970   *                wa_zbill_gl-amount = wa_zbill_gl-amount + <fs_amt>.
2971   *                MODIFY it_zbill_gl FROM wa_zbill_gl INDEX sy-tabix.
2972   *              ELSE.
2973   *                READ TABLE it_ska1 INTO wa_ska1 WITH KEY saknr = wa_bill_gl-hkont.
2974   *                IF sy-subrc = 0.
2975   *                  wa_zbill_gl-costcenter = wa_item2-kst01.
2976   *                ELSE.
2977   *                  CLEAR wa_zbill_gl-costcenter.
2978   *                ENDIF.
2979   *                wa_zbill_gl-hkont = wa_bill_gl-hkont.
2980   *                wa_zbill_gl-amount = <fs_amt>.
2981   *                IF wa_zbill_gl-amount NE '0'. " + by Bipin on 20/11/2013
2982   *                  APPEND wa_zbill_gl TO it_zbill_gl.
2983   *                ENDIF.                       " + by Bipin on 20/11/2013
2984   *              ENDIF.
2985   *            ENDIF.
2986   *          ENDLOOP.
2987   *
2988   *        ENDIF.
2989   *
2990   *        MOVE space TO gv_posted.
2991   *        lv_total = wa_item2-rent_final + wa_item2-call_charges_final
2992   *        + wa_item2-oth_charges_fin + wa_item2-service_tax_fin.
2993   *
2994   *        READ TABLE it_billhead INTO wa_billhead WITH KEY reqt_num = wa_item2-reqt_num BINARY SEARCH.
2995   *        IF sy-subrc EQ 0.
2996   *          READ TABLE it_billtype INTO wa_billtype WITH KEY key = wa_billhead-bill_type.
2997   *          IF sy-subrc EQ 0.
2998   *            MOVE wa_billtype-text TO wa_header-header_txt.
2999   *          ENDIF.
3000   *        ENDIF.
3001   *        MOVE : wa_billhead-bukrs TO wa_header-comp_code,
3002   *        wa_billhead-create_date TO wa_header-doc_date.
3003   **           WA_BILLHEAD-CREATE_DATE TO WA_HEADER-PSTNG_DATE.
3004   *
3005   **    CALL FUNCTION 'BAPI_COMPANYCODE_GET_PERIOD'
3006   **      EXPORTING
3007   **        companycodeid = wa_billhead-bukrs
3008   **        posting_date  = wa_billhead-create_date
3009   **      IMPORTING
3010   **        fiscal_year   = wa_header-fisc_year
3011   **        fiscal_period = wa_header-fis_period.
3012   *
3013   **    WA_HEADER-HEADER_TXT = TXT.    " ADDED BY BIPIN FOR HEADER TXT " ON 28/10/2013
3014   *        wa_header-pstng_date = post_dt. " ADDED BY BIPIN FOR POSTING DATE " ON 28/10/2013
3015   *        wa_header-doc_type = 'KM'.
3016   *        wa_header-ref_doc_no = wa_item2-reqt_num.
3017   *        wa_header-username = sy-uname.
3018   *
3019   *
3020   *        l_total_pay = l_total_pay + lv_total.
3021   *        l_total_acc = l_total_acc + lv_total.
3022   *
3023   **      AT END OF KST011.
3024   **IF L_KST01 <> WA_ITEM2-KST01.
3025   *
3026   *        ADD 1 TO lv_item.
3027   **  G/L Account internal table for Posting
3028   **    WA_ACCOUNTGL-GL_ACCOUNT = '201460'. " Need to be changed
3029   *
3030   ** FOR GL ACCOUNT/
3031   **  READ TABLE GT_BILL_GL INTO WA_BILL_GL WITH KEY BILL_TYPE = WA_ITEM2-BILL_TYPE.
3032   **   WA_ACCOUNTGL-GL_ACCOUNT = WA_BILL_GL-HKONT.
3033   *
3034   **    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
3035   **      EXPORTING
3036   **        INPUT  = WA_ACCOUNTGL-GL_ACCOUNT
3037   **      IMPORTING
3038   **        OUTPUT = WA_ACCOUNTGL-GL_ACCOUNT.
3039   **    ADD 1 TO LV_ITEM.
3040   *        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
3041   *          EXPORTING
3042   *            input  = lv_item
3043   *          IMPORTING
3044   *            output = wa_accountgl-itemno_acc.
3045   *
3046   *        wa_accountgl-item_text = wa_header-header_txt.
3047   *
3048   *        wa_accountgl-acct_type = 'S'.
3049   *        wa_accountgl-doc_type = 'KM'.
3050   **    WA_ACCOUNTGL-COMP_CODE = WA_HEADER-COMP_CODE. " COMMENT BY BIPIN SHUKLA FOR ADD COMPANY CODE DYNAMICALLY
3051   **    wa_accountgl-fis_period = wa_header-fis_period.
3052   **    wa_accountgl-fisc_year = wa_header-fisc_year.
3053   *        wa_accountgl-pstng_date = wa_header-pstng_date.
3054   *        wa_accountgl-value_date = wa_header-pstng_date.
3055   *        wa_accountgl-alloc_nmbr = wa_item2-reqt_num.
3056   **    WA_ACCOUNTGL-COSTCENTER = 'DLICSICMTN'.        " from alv
3057   *        wa_accountgl-costcenter = wa_item2-kst01.        " from alv " Changed by Bipin
3058   ************    EARMARKED FUNDS
3059   *        wa_accountgl-res_doc = er_kblnr.
3060   *        wa_accountgl-res_item = er_kblpos.
3061   ************    EARMARKED FUNDS
3062   *        wa_accountgl-ref_key_1 = wa_item2-kst01.
3063   *        APPEND wa_accountgl TO it_accountgl.
3064   *
3065   *        wa_currency-itemno_acc = wa_accountgl-itemno_acc.
3066   *        wa_currency-curr_type = '00'.
3067   *        wa_currency-currency = 'INR'.
3068   *        wa_currency-amt_doccur = l_total_acc.
3069   *        APPEND wa_currency TO it_currency.
3070   *
3071   *        CLEAR l_total_acc.
3072   *        CLEAR l_kst01.
3073   *
3074   *******************************************************     added by bipin
3075   *        SHIFT wa_item2-zphone LEFT DELETING LEADING lv_nullc.
3076   *        lv_len = strlen( wa_item2-zphone ).
3077   *        IF lv_len = 10.
3078   *          lv_phone11 = '0' && wa_item2-zphone(10).
3079   *          lv_phone10 = wa_item2-zphone(10).
3080   *        ELSEIF lv_len = 11.
3081   *          lv_phone11 = wa_item2-zphone(11).
3082   *          lv_phone10 = wa_item2-zphone+1(10).
3083   *        ELSEIF lv_len = 12.
3084   *          lv_phone11 = '0' && wa_item2-zphone+2(10).
3085   *          lv_phone10 = wa_item2-zphone+2(10).
3086   *        ELSEIF lv_len = 13.
3087   *          lv_phone11 = '0' && wa_item2-zphone+3(10).
3088   *          lv_phone10 = wa_item2-zphone+3(10).
3089   *        ENDIF.
3090   ************************************ADDED BY BIPIN ON 11/11/2013
3091   **Begin of changes by vikas on 20-12-2013
3092   *        IF bil_type = '4' OR bil_type = '3'.
3093   *          lv_phone_len = strlen( wa_item2-zphone ).
3094   *          IF lv_phone_len LT 11.
3095   *
3096   *            lv_phn_land = '*' && wa_item2-zphone.
3097   *            LOOP AT it_pa9205 INTO wa_pa9205
3098   *            WHERE zphone CP lv_phn_land.
3099   *              READ TABLE it_pa0001 INTO wa_pa0001 WITH KEY pernr = wa_pa9205-pernr.
3100   *              IF sy-subrc EQ 0.
3101   *                IF wa_pa0001-bukrs NE bukrs.
3102   **            CONTINUE.
3103   *                ENDIF.
3104   *
3105   *              ENDIF.
3106   *              wa_pa9105-infty = '9105'.
3107   *              wa_pa9105-begda = sy-datum.
3108   *              wa_pa9105-endda = '99991231'.
3109   *              wa_pa9105-pernr = wa_pa9205-pernr.
3110   *              CONCATENATE wa_item2-bill_from(2) wa_item2-bill_from+2(2) wa_item2-bill_from+4(4)   INTO wa_pa9105-zbill_date_fr.
3111   *              CONCATENATE wa_item2-bill_to(2) wa_item2-bill_to+2(2) wa_item2-bill_to+4(4)   INTO wa_pa9105-zbill_date_to.
3112   *              wa_pa9105-begda = wa_pa9105-zbill_date_fr.  "sy-datum.
3113   *              wa_pa9105-endda = wa_pa9105-zbill_date_to . "'99991231'.
3114   *              wa_pa9105-zbill_no = wa_item2-bill_num.
3115   *              wa_pa9105-zphn_no = wa_pa9205-zphone."+vikas
3116   *              wa_pa9105-doc_no = wa_item2-reqt_num.
3117   *              wa_pa9105-subty   = wa_pa9205-subty.
3118   *              wa_pa9105-aedtm   = sy-datum.
3119   *              wa_pa9105-uname   = sy-uname.
3120   *              wa_pa9105-zadm_amt = lv_total.
3121   *              APPEND wa_pa9105 TO it_pa9105.
3122   *            ENDLOOP.
3123   *          ELSE.
3124   *            LOOP AT it_pa9205 INTO wa_pa9205
3125   *            WHERE zphone EQ wa_item2-zphone.
3126   *              READ TABLE it_pa0001 INTO wa_pa0001 WITH KEY pernr = wa_pa9205-pernr.
3127   *              IF sy-subrc EQ 0.
3128   *                IF wa_pa0001-bukrs NE bukrs.
3129   **            CONTINUE.
3130   *                ENDIF.
3131   *
3132   *              ENDIF.
3133   *              wa_pa9105-infty = '9105'.
3134   *              wa_pa9105-begda = sy-datum.
3135   *              wa_pa9105-endda = '99991231'.
3136   *              wa_pa9105-pernr = wa_pa9205-pernr.
3137   *              CONCATENATE wa_item2-bill_from(2) wa_item2-bill_from+2(2) wa_item2-bill_from+4(4)   INTO wa_pa9105-zbill_date_fr.
3138   *              CONCATENATE wa_item2-bill_to(2) wa_item2-bill_to+2(2) wa_item2-bill_to+4(4)   INTO wa_pa9105-zbill_date_to.
3139   *              wa_pa9105-begda = wa_pa9105-zbill_date_fr.  "sy-datum.
3140   *              wa_pa9105-endda = wa_pa9105-zbill_date_to . "'99991231'.
3141   *              wa_pa9105-zbill_no = wa_item2-bill_num.
3142   *              wa_pa9105-zphn_no = wa_pa9205-zphone."+vikas
3143   *              wa_pa9105-doc_no = wa_item2-reqt_num.
3144   *              wa_pa9105-subty   = wa_pa9205-subty.
3145   *              wa_pa9105-aedtm   = sy-datum.
3146   *              wa_pa9105-uname   = sy-uname.
3147   *              wa_pa9105-zadm_amt = lv_total.
3148   *              APPEND wa_pa9105 TO it_pa9105.
3149   *            ENDLOOP.
3150   *
3151   *          ENDIF.
3152   *        ELSE.
3153   **End of changes by vikas on 20-12-2013
3154   *          READ TABLE it_pa9205 INTO wa_pa9205 WITH KEY zphone = lv_phone11."wa_item2-zphone.
3155   *          IF sy-subrc = 0.
3156   *            wa_pa9105-infty = '9105'.
3157   *            wa_pa9105-begda = sy-datum.
3158   *            wa_pa9105-endda = '99991231'.
3159   *            wa_pa9105-pernr = wa_pa9205-pernr.
3160   *            CONCATENATE wa_item2-bill_from(2) wa_item2-bill_from+2(2) wa_item2-bill_from+4(4)   INTO wa_pa9105-zbill_date_fr.
3161   *            CONCATENATE wa_item2-bill_to(2) wa_item2-bill_to+2(2) wa_item2-bill_to+4(4)   INTO wa_pa9105-zbill_date_to.
3162   *            wa_pa9105-begda = wa_pa9105-zbill_date_fr.  "sy-datum.
3163   *            wa_pa9105-endda = wa_pa9105-zbill_date_to . "'99991231'.
3164   *            wa_pa9105-zbill_no = wa_item2-bill_num.
3165   *            wa_pa9105-zphn_no = lv_phone11."wa_item2-zphone."+vikas
3166   *            wa_pa9105-doc_no = wa_item2-reqt_num.
3167   *            wa_pa9105-subty   = '03'.
3168   *            wa_pa9105-aedtm   = sy-datum.
3169   *            wa_pa9105-uname   = sy-uname.
3170   *            wa_pa9105-zadm_amt = lv_total.
3171   *            APPEND wa_pa9105 TO it_pa9105.
3172   *          ELSE.
3173   *            READ TABLE it_pa9205 INTO wa_pa9205 WITH KEY zphone = lv_phone10.
3174   *            IF sy-subrc EQ 0.
3175   *              wa_pa9105-infty = '9105'.
3176   *              wa_pa9105-begda = sy-datum.
3177   *              wa_pa9105-endda = '99991231'.
3178   *              wa_pa9105-pernr = wa_pa9205-pernr.
3179   *              CONCATENATE wa_item2-bill_from(2) wa_item2-bill_from+2(2) wa_item2-bill_from+4(4)   INTO wa_pa9105-zbill_date_fr.
3180   *              CONCATENATE wa_item2-bill_to(2) wa_item2-bill_to+2(2) wa_item2-bill_to+4(4)   INTO wa_pa9105-zbill_date_to.
3181   *              wa_pa9105-begda = wa_pa9105-zbill_date_fr.  "sy-datum.
3182   *              wa_pa9105-endda = wa_pa9105-zbill_date_to . "'99991231'.
3183   *              wa_pa9105-zbill_no = wa_item2-bill_num.
3184   *              wa_pa9105-zphn_no = lv_phone10."wa_item2-zphone."+vikas
3185   *              wa_pa9105-doc_no = wa_item2-reqt_num.
3186   *              wa_pa9105-subty   = '01'.
3187   *              wa_pa9105-aedtm   = sy-datum.
3188   *              wa_pa9105-uname   = sy-uname.
3189   *              wa_pa9105-zadm_amt = lv_total.
3190   *              APPEND wa_pa9105 TO it_pa9105.
3191   *            ENDIF.
3192   *          ENDIF.
3193   **Begin of changes by vikas on 20-12-2013
3194   *        ENDIF.
3195   **End of changes by vikas on 20-12-2013
3196   ************************************ADDED BY BIPIN ON 11/11/2013
3197   *        AT END OF reqt_num.
3198   *          REFRESH it_accountgl1.
3199   *          CLEAR lv_item.
3200   *          SORT it_accountgl BY costcenter.
3201   *          MOVE it_accountgl[] TO it_accountgl2[].
3202   *          DELETE ADJACENT DUPLICATES FROM it_accountgl2 COMPARING costcenter.
3203   ********************** added by bipin on 25/11/2013
3204   *          ADD 1 TO lv_item.
3205   **   Vendor Internal Table for Posting
3206   *          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
3207   *            EXPORTING
3208   *              input  = wa_billhead-serv_prov
3209   *            IMPORTING
3210   *              output = wa_payable-vendor_no.
3211   *          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
3212   *            EXPORTING
3213   *              input  = lv_item
3214   *            IMPORTING
3215   *              output = wa_payable-itemno_acc.
3216   *
3217   *          wa_payable-comp_code = wa_header-comp_code.
3218   *          READ TABLE gt_lfb1 INTO wa_lfb1 WITH KEY bukrs = wa_header-comp_code lifnr = wa_payable-vendor_no.
3219   *          IF sy-subrc EQ 0.
3220   *            wa_payable-pmnttrms = wa_lfb1-zterm.
3221   *            wa_payable-pymt_meth = wa_lfb1-zwels.
3222   *          ENDIF.
3223   **      WA_PAYABLE-PMNTTRMS = '0001'. " Need to be changed " comment by bipin
3224   *          wa_payable-item_text = txt.
3225   **      WA_PAYABLE-BLINE_DATE = WA_BILLHEAD-CREATE_DATE. " COMMENT BY BIPIN FOR DUE DATE ON 13/11/2013
3226   *          wa_payable-bline_date = due_date.
3227   *          wa_payable-alloc_nmbr = wa_item2-reqt_num.
3228   **      WA_PAYABLE-SECTIONCODE = 'HQ'. " Need to be changed
3229   *          wa_payable-sectioncode = sec_code. " section code added by Bipin on 28/10/2013
3230   *
3231   **      WA_PAYABLE-PYMT_METH = 'S'.    " Need to be changed   " comment by bipin
3232   *
3233   *          APPEND wa_payable TO it_payable.
3234   ********************** added by bipin on 25/11/2013
3235   *
3236   *          LOOP AT it_zbill_gl INTO wa_zbill_gl.
3237   *
3238   *            l_total_acc = wa_zbill_gl-amount.
3239   *            READ TABLE it_accountgl INTO wa_accountgl WITH KEY costcenter = wa_zbill_gl-costcenter."WA_ACCOUNTGL2-COSTCENTER.
3240   *
3241   *            ADD 1 TO lv_item.
3242   *            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
3243   *              EXPORTING
3244   *                input  = lv_item
3245   *              IMPORTING
3246   *                output = wa_accountgl-itemno_acc.
3247   *
3248   *            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
3249   *              EXPORTING
3250   *                input  = wa_zbill_gl-hkont
3251   *              IMPORTING
3252   *                output = wa_accountgl-gl_account.
3253   *
3254   *
3255   **MOVE WA_ACCOUNTGL TO WA_ACCOUNTGL1.
3256   *            CLEAR wa_accountgl-ref_key_1.
3257   *
3258   *            READ TABLE it_ska1 INTO wa_ska1 WITH KEY saknr = wa_zbill_gl-hkont.
3259   *            IF sy-subrc <> 0.
3260   *              CLEAR wa_accountgl-costcenter.
3261   *              CLEAR wa_accountgl-comp_code. " + bipin
3262   *              CLEAR wa_accountgl-res_doc.
3263   *              CLEAR wa_accountgl-res_item.
3264   *            ENDIF.
3265   *
3266   *            READ TABLE gt_csks INTO wa_csks WITH KEY kostl = wa_accountgl-costcenter.
3267   *            IF sy-subrc EQ 0.
3268   *              READ TABLE it_ska1 INTO wa_ska1 WITH KEY saknr = wa_accountgl-gl_account.
3269   *              IF sy-subrc = 0.
3270   *                wa_accountgl-comp_code = wa_csks-bukrs.
3271   *              ELSE.
3272   *                CLEAR wa_accountgl-comp_code.
3273   *              ENDIF.
3274   *            ENDIF.
3275   *            APPEND wa_accountgl TO it_accountgl1.
3276   *            wa_currency-itemno_acc = wa_accountgl-itemno_acc.
3277   *            wa_currency-curr_type = '00'.
3278   *            wa_currency-currency = 'INR'.
3279   *            wa_currency-amt_doccur = l_total_acc.
3280   *
3281   *            APPEND wa_currency TO it_currency1.
3282   *            CLEAR l_total_acc.
3283   *          ENDLOOP.
3284   *
3285   *          wa_currency-itemno_acc = wa_payable-itemno_acc.
3286   *          wa_currency-curr_type = '00'.
3287   *          wa_currency-currency = 'INR'.
3288   *          COMPUTE wa_currency-amt_doccur = ( l_total_pay * -1 ).
3289   *          APPEND wa_currency TO it_currency1.
3290   *
3291   *          wa_extension-valuepart1 = sy-repid.
3292   *          wa_extension-valuepart2 = 'KIDNO'.
3293   **          wa_extension-valuepart3 = wa_item2-reqt_num."WA_ITEM2-REQT_NUM.
3294   *          IF gv_kidno IS NOT INITIAL.
3295   *            wa_extension-valuepart3 = gv_kidno.
3296   *          ELSE.
3297   *            wa_extension-valuepart3 = 'UTILITY PAYMENTS'.
3298   *          ENDIF.
3299   *          wa_extension-valuepart4 = wa_payable-itemno_acc.
3300   *          APPEND wa_extension TO it_extension.
3301   *          CLEAR wa_extension.
3302   *
3303   *          MOVE : abap_true TO gv_posted,
3304   *          wa_item2-reqt_num TO gv_reqt_num.
3305   *          CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
3306   *            EXPORTING
3307   *              documentheader = wa_header
3308   *            TABLES
3309   *              accountgl      = it_accountgl1
3310   *              accountpayable = it_payable
3311   *              currencyamount = it_currency1
3312   *              extension2     = it_extension
3313   *              return         = it_return.
3314   **      IF SY-SUBRC EQ 0."- by vikas
3315   **      IF it_return IS NOT INITIAL."+ by vikas
3316   *
3317   *          LOOP AT it_return INTO wa_return.
3318   **          IF WA_RETURN-TYPE = 'E'.
3319   *
3320   *            wa_error-reqnum  = wa_item2-reqt_num.
3321   *            wa_error-er_type = wa_return-type.
3322   *            wa_error-msg_id = wa_return-id.
3323   *            wa_error-msg_num = wa_return-number.
3324   *            wa_error-msg = wa_return-message.
3325   *            APPEND wa_error TO it_error.
3326   **          ENDIF.
3327   *          ENDLOOP.
3328   *          CLEAR : wa_error.
3329   **      ELSE."+ by vikas
3330   *          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
3331   *            EXPORTING
3332   *              wait = 'X'.
3333   **      ENDIF."+ by vikas
3334   **      ENDIF."- by vikas
3335   *
3336   *
3337   *************************************** To update HR table
3338   **
3339   **      IF GV_POSTED EQ ABAP_TRUE.
3340   **
3341   **        READ TABLE IT_RETURN INTO WA_RETURN INDEX 1.
3342   **        IF WA_RETURN-TYPE EQ 'S'.
3343   *
3344   ************************* Parallel processing to update HR info type : start Of Code : by Bipin
3345   **
3346   **          DESCRIBE TABLE IT_PA9105 LINES LV_LINES.
3347   **          LV_LINES_TAB = LV_LINES / 5 .
3348   **          LV_LINES_TAB1 = LV_LINES_TAB * 2.
3349   **          LV_LINES_TAB2 = LV_LINES_TAB * 3.
3350   **          LV_LINES_TAB3 = LV_LINES_TAB * 4.
3351   **          LV_LINES_TAB4 = LV_LINES - LV_LINES_TAB3. "LV_LINES_TAB * 4.
3352   **
3353   **
3354   **
3355   **          IF LV_LINES <= 5 .
3356   **
3357   **            LOOP AT IT_PA9105 INTO WA_PA9105.
3358   **              APPEND  WA_PA9105 TO IT_PA9105_1.
3359   **            ENDLOOP.
3360   **            CLEAR WA_PA9105.
3361   **
3362   **          ELSE.
3363   **
3364   **            LOOP AT IT_PA9105 INTO WA_PA9105.
3365   **              LV_INDEX = SY-TABIX.
3366   **
3367   **              IF LV_INDEX <= LV_LINES_TAB.
3368   **                APPEND WA_PA9105 TO IT_PA9105_1.
3369   **              ELSEIF LV_INDEX > LV_LINES_TAB AND LV_INDEX <= LV_LINES_TAB1.
3370   **                APPEND WA_PA9105 TO IT_PA9105_2.
3371   **              ELSEIF LV_INDEX > LV_LINES_TAB1 AND LV_INDEX <= LV_LINES_TAB2.
3372   **                APPEND WA_PA9105 TO IT_PA9105_3.
3373   **              ELSEIF LV_INDEX > LV_LINES_TAB2 AND LV_INDEX <= LV_LINES_TAB3.
3374   **                APPEND WA_PA9105 TO IT_PA9105_4.
3375   **              ELSEIF LV_INDEX > LV_LINES_TAB3 AND LV_INDEX >= LV_LINES_TAB4.
3376   **                APPEND WA_PA9105 TO IT_PA9105_5.
3377   **              ENDIF.
3378   **            ENDLOOP.
3379   **          ENDIF.
3380   **
3381   **
3382   **
3383   **          CALL FUNCTION 'ZBILL_PP_OF_RECORD'
3384   **            STARTING NEW TASK 'TASK1'
3385   **            PERFORMING UPDATE_STATUS ON END OF TASK
3386   **            EXPORTING
3387   **              REQ_NUM  = WA_ITEM2-REQT_NUM
3388   **            TABLES
3389   **              T_PA9105 = IT_PA9105_1.
3390   **
3391   **          CALL FUNCTION 'ZBILL_PP_OF_RECORD'
3392   **            STARTING NEW TASK 'TASK2'
3393   **            PERFORMING UPDATE_STATUS1 ON END OF TASK
3394   **            EXPORTING
3395   **              REQ_NUM  = WA_ITEM2-REQT_NUM
3396   **            TABLES
3397   **              T_PA9105 = IT_PA9105_2.
3398   **
3399   **          CALL FUNCTION 'ZBILL_PP_OF_RECORD'
3400   **            STARTING NEW TASK 'TASK3'
3401   **            PERFORMING UPDATE_STATUS2 ON END OF TASK
3402   **            EXPORTING
3403   **              REQ_NUM  = WA_ITEM2-REQT_NUM
3404   **            TABLES
3405   **              T_PA9105 = IT_PA9105_3.
3406   **
3407   **          CALL FUNCTION 'ZBILL_PP_OF_RECORD'
3408   **            STARTING NEW TASK 'TASK4'
3409   **            PERFORMING UPDATE_STATUS3 ON END OF TASK
3410   **            EXPORTING
3411   **              REQ_NUM  = WA_ITEM2-REQT_NUM
3412   **            TABLES
3413   **              T_PA9105 = IT_PA9105_4.
3414   **
3415   **          CALL FUNCTION 'ZBILL_PP_OF_RECORD'
3416   **            STARTING NEW TASK 'TASK5'
3417   **            PERFORMING UPDATE_STATUS4 ON END OF TASK
3418   **            EXPORTING
3419   **              REQ_NUM  = WA_ITEM2-REQT_NUM
3420   **            TABLES
3421   **              T_PA9105 = IT_PA9105_5.
3422   **
3423   **
3424   **          WAIT UNTIL LV_COMP = 5.
3425   **
3426   **          APPEND LINES OF L_RETURN1[] TO L_RETURN5[].
3427   **          APPEND LINES OF L_RETURN2[] TO L_RETURN5[].
3428   **          APPEND LINES OF L_RETURN3[] TO L_RETURN5[].
3429   **          APPEND LINES OF L_RETURN4[] TO L_RETURN5[].
3430   **          APPEND LINES OF L_RETURN6[] TO L_RETURN5[].
3431   *
3432   ************************* Parallel processing to update HR info type : End Of Code : by Bipin
3433   *
3434   **        ENDIF.
3435   **      ENDIF.
3436   *
3437   *          REFRESH : it_accountgl[],it_payable[],it_currency[],it_extension, it_accountgl1,it_currency1 ,it_pa9105.
3438   *          REFRESH : it_zbill_gl , it_pa9205.
3439   *          CLEAR : wa_header,lv_total,lv_item,l_total_pay.
3440   *
3441   *        ENDAT.
3442   *        CLEAR : wa_billhead,wa_items,wa_payable,wa_accountgl,wa_billtype,wa_header,wa_item2 .
3443   *        IF gv_posted EQ abap_true.
3444   *          LOOP AT it_item2 INTO wa_item2 WHERE reqt_num EQ gv_reqt_num AND check IS NOT INITIAL.
3445   *            ind = sy-tabix.
3446   *            READ TABLE it_return INTO wa_return INDEX 1.
3447   **        READ TABLE IT_ERROR1 INTO WA_ERROR1 INDEX 1.
3448   *
3449   *            IF wa_return-type EQ 'S' ."AND L_BAPIRETURN-TYPE NE 'E' AND L_RETURN-TYPE NE 'E'. " CHANGES BY BIPIN ON 13/11/2013
3450   *              CLEAR : lv_ret_type , post_doc , post_comp_code , post_year.
3451   *              lv_ret_type = wa_return-type.
3452   *              EXPORT lv_ret_type TO MEMORY ID 'LV_RET'.
3453   *******************          changes by bipin on 06/12/2014
3454   *              MOVE wa_return-message_v2+0(10) TO wa_item2-account_doc_no.
3455   *              MOVE wa_return-message_v2+10(4) TO wa_item2-comp_code.
3456   *              MOVE wa_return-message_v2+14(4) TO wa_item2-fyear.
3457   *              MOVE '6' TO wa_item2-status.
3458   *
3459   *              post_doc = wa_item2-account_doc_no.
3460   *              post_comp_code = wa_item2-comp_code.
3461   *              post_year = wa_item2-fyear.
3462   *
3463   *
3464   *              EXPORT post_doc TO MEMORY ID 'P_DOC'.
3465   *              EXPORT post_comp_code TO MEMORY ID 'P_CC'.
3466   *              EXPORT post_year TO MEMORY ID 'P_DOC'.
3467   *
3468   *
3469   *******************          changes by bipin on 06/12/2014
3470   *
3471   *              IF lv_attach_check = space.
3472   ** Begin of changes by vikas on 01-11-2013
3473   ** Attaching uploaded document with FI document
3474   **          AT END OF reqt_num.
3475   *                CALL FUNCTION 'ZBILL_ATTACH_DOCUMENT'
3476   *                  EXPORTING
3477   *                    im_reqt_num  = gv_reqt_num
3478   *                    im_belnr     = wa_item2-account_doc_no
3479   *                    im_bukrs     = bukrs
3480   *                    im_bill_date = wa_item2-bill_date.
3481   **              IND = IND + 1.
3482   *                lv_attach_check = 'X'.
3483   *              ENDIF.
3484   *
3485   **          READ TABLE IT_ERROR1 INTO WA_ERROR1 WITH KEY REQNUM = GV_REQT_NUM PERNR = WA_ITEM2-PERNR. " comment by bipin : 10/12/2013
3486   *              READ TABLE l_return5 INTO w_return5 WITH KEY req_num = gv_reqt_num pernr = w_return5-pernr.
3487   *
3488   **          IF WA_ERROR1-ER_TYPE = '' OR WA_ERROR1-ER_TYPE = 'S'.  " comment by bipin : 10/12/2013
3489   *              IF w_return5-er_type = '' OR w_return5-er_type = 'S'.
3490   *
3491   ************************* + SAB_BIPIN on 11/11/2013
3492   *                REFRESH wa_item2-style[].
3493   *                ls_style-fieldname = 'CALL_CHARGES_FINAL'.
3494   *                ls_style-style     = cl_gui_alv_grid=>mc_style_disabled .
3495   *                APPEND ls_style TO wa_item2-style.
3496   *                CLEAR ls_style.
3497   *
3498   *                ls_style-fieldname = 'CHECK'.
3499   *                ls_style-style     = cl_gui_alv_grid=>mc_style_disabled .
3500   *                APPEND ls_style TO wa_item2-style.
3501   *                CLEAR ls_style.
3502   *
3503   *                ls_style-fieldname = 'CHECK1'.
3504   *                ls_style-style     = cl_gui_alv_grid=>mc_style_disabled .
3505   *                APPEND ls_style TO wa_item2-style.
3506   *                CLEAR ls_style.
3507   *
3508   *                ls_style-fieldname = 'OTH_CHARGES_FIN'.
3509   *                ls_style-style     = cl_gui_alv_grid=>mc_style_disabled .
3510   *                APPEND ls_style TO wa_item2-style.
3511   *                CLEAR ls_style.
3512   *                ls_style-fieldname = 'REMARKS'.
3513   *                ls_style-style     = cl_gui_alv_grid=>mc_style_disabled .
3514   *                APPEND ls_style TO wa_item2-style.
3515   *                CLEAR ls_style.
3516   *                ls_style-fieldname = 'RENT_FINAL'.
3517   *                ls_style-style     = cl_gui_alv_grid=>mc_style_disabled .
3518   *                APPEND ls_style TO wa_item2-style.
3519   *                CLEAR ls_style.
3520   *
3521   *
3522   *                ls_style-fieldname = 'SERVICE_TAX_FIN'.
3523   *                ls_style-style     = cl_gui_alv_grid=>mc_style_disabled .
3524   *                APPEND ls_style TO wa_item2-style.
3525   *                CLEAR ls_style.
3526   *
3527   *                wa_item2-check = ''.
3528   *                wa_item2-check1 = ''.
3529   ************************* + SAB_BIPIN on 11/11/2013
3530   ********************* Added by Bipin
3531   *                READ TABLE it_error INTO wa_error WITH KEY reqnum = wa_item2-reqt_num.
3532   *                IF sy-subrc EQ 0.
3533   *                  MOVE wa_error-msg TO wa_item2-comment.
3534   *                  CONCATENATE 'FI - ' wa_item2-comment INTO wa_item2-comment SEPARATED BY space.
3535   *                ENDIF.
3536   ********************* Added by Bipin
3537   *
3538   **          ELSEIF WA_ERROR1-ER_TYPE = 'E'. " comment by bipin : 10/12/2013
3539   *              ELSEIF w_return5-er_type = 'E'.
3540   *
3541   *                MOVE wa_return-message_v2+0(10) TO wa_item2-account_doc_no.
3542   *                MOVE wa_return-message_v2+10(4) TO wa_item2-comp_code.
3543   *                MOVE wa_return-message_v2+14(4) TO wa_item2-fyear.
3544   *
3545   **            CONCATENATE 'HR - ' WA_ERROR1-MSG  INTO WA_ERROR1-MSG SEPARATED BY SPACE .
3546   *                CONCATENATE 'HR - ' w_return5-msg  INTO w_return5-msg SEPARATED BY space .
3547   **            MOVE WA_ERROR1-MSG TO WA_ITEM2-COMMENT.
3548   *                MOVE w_return5-msg TO wa_item2-comment.
3549   *                MOVE '8' TO wa_item2-status. " ADDED BY BIPIN FOR HR ERROR
3550   *                wa_item2-rowcolor = 'C610'.
3551   *
3552   *              ENDIF.
3553   *
3554   *            ELSEIF  wa_return-type EQ 'E'.
3555   *              READ TABLE it_error INTO wa_error WITH KEY reqnum = wa_item2-reqt_num.
3556   *              MOVE wa_error-msg TO wa_item2-comment.
3557   *              CONCATENATE 'FI - ' wa_item2-comment INTO wa_item2-comment SEPARATED BY space.
3558   *              wa_item2-rowcolor = 'C610'.
3559   *
3560   *
3561   ********************* Added by Bipin
3562   *              wa_item2-t_msg = it_return.
3563   *            ENDIF.
3564   *            MODIFY it_item2 FROM wa_item2 INDEX ind TRANSPORTING account_doc_no comp_code fyear status comment rowcolor style check check1 t_msg.
3565   *            REFRESH wa_item2-style[].
3566   *          ENDLOOP.
3567   *          PERFORM save_data.
3568   *        ENDIF.
3569   *
3570   *        l_kst01 = wa_item2-kst01.
3571   *        REFRESH : it_return[] , it_error[] , l_return5[], l_return4[] , l_return3[] , l_return2[] , l_return1[].
3572   *        CLEAR : wa_items,wa_return,wa_item2 , w_return5.
3573   *
3574   *      ENDLOOP.
3575   *      CALL METHOD r_grid->refresh_table_display.
3576   *
3577   *
3578   *    ENDFORM.                    " POST_RECORDS
3579   *&---------------------------------------------------------------------*
3580   *&      Form  HANDLE_CHECKBOX
3581   *&---------------------------------------------------------------------*
3582   *       text
3583   *----------------------------------------------------------------------*
3584   *  -->  p1        text
3585   *  <--  p2        text
3586   *----------------------------------------------------------------------*
3587       FORM handle_checkbox  USING er_data_changed TYPE REF TO cl_alv_changed_data_protocol .
3588
3589
3590         DATA : ac_rent TYPE zbill_rent,
3591               ap_rent TYPE zbill_rent.
3592
3593         DATA : check_remarks TYPE zbill_remarks.
3594         DATA : check_sec_remarks TYPE zbill_remarks.
3595
3596         DATA : ac_charge TYPE zbill_call_charges,
3597               ap_charge TYPE zbill_call_charges.
3598
3599         DATA : ac_ot_charge TYPE zbill_oth_charges,
3600               ap_ot_charge TYPE zbill_oth_charges.
3601
3602         DATA :ac_service TYPE j_1iser,
3603               ap_service TYPE j_1iser.
3604
3605         DATA : it_cell TYPE lvc_t_modi,
3606               it_cell1 TYPE lvc_t_modi,
3607               wa_cell TYPE lvc_s_modi.
3608
3609         DATA : req_num TYPE zbill_data-reqt_num.
3610
3611         DATA : lv_cell TYPE c.
3612   * Change by vikas
3613         IF sy-ucomm EQ 'EXPOST' OR sy-ucomm EQ 'SAVE' OR sy-ucomm = 'EXECUTE' .
3614           RETURN.
3615         ENDIF.
3616   * Change by vikas
3617         it_cell = er_data_changed->mt_mod_cells.
3618
3619         it_cell1[] = it_cell[].
3620         EXPORT it_cell1 TO MEMORY ID 'CELL1'.
3621
3622         LOOP AT it_cell INTO wa_cell.
3623
3624           CASE wa_cell-fieldname.
3625
3626             WHEN 'CHECK1'.
3627               CALL METHOD er_data_changed->modify_cell
3628                 EXPORTING
3629                   i_row_id    = wa_cell-row_id
3630                   i_tabix     = wa_cell-tabix
3631                   i_fieldname = 'CHECK'
3632                   i_value     = ' '.
3633
3634             WHEN 'CHECK'.
3635               CALL METHOD er_data_changed->modify_cell
3636                 EXPORTING
3637                   i_row_id    = wa_cell-row_id
3638                   i_tabix     = wa_cell-tabix
3639                   i_fieldname = 'CHECK1'
3640                   i_value     = ' '.
3641
3642             WHEN 'RENT_FINAL'.
3643               PERFORM f_validate_cell_value USING er_data_changed
3644                                                   wa_cell
3645                                                   wa_cell-fieldname
3646                                                   'RENT'.
3647   *            CALL METHOD er_data_changed->get_cell_value
3648   *              EXPORTING
3649   *                i_row_id    = wa_cell-row_id
3650   **               I_TABIX     =
3651   *                i_fieldname = wa_cell-fieldname
3652   *              IMPORTING
3653   *                e_value     = ap_rent.
3654   *            CALL METHOD er_data_changed->get_cell_value
3655   *              EXPORTING
3656   *                i_row_id    = wa_cell-row_id
3657   **               I_TABIX     =
3658   *                i_fieldname = 'RENT'
3659   *              IMPORTING
3660   *                e_value     = ac_rent.
3661   *
3662   ********* BEGIEN OF CHANGES BY BIPIN : CODE FOR PUT REMARK WHEN AMOUNT CHANGE
3663   **        IF AP_RENT NE AC_RENT.
3664   **          CALL METHOD ER_DATA_CHANGED->GET_CELL_VALUE
3665   **            EXPORTING
3666   **              I_ROW_ID    = WA_CELL-ROW_ID
3667   ***             I_TABIX     =
3668   **              I_FIELDNAME = 'REQT_NUM'
3669   **            IMPORTING
3670   **              E_VALUE     = REQ_NUM.
3671   **          PERFORM PUT_REMARK.
3672   **        ENDIF.
3673   ********* END OF CHANGES BY BIPIN : CODE FOR PUT REMARK WHEN AMOUNT CHANGE
3674   *
3675   *            IF  ac_rent < ap_rent AND ac_rent > 0.
3676   *
3677   *              CALL METHOD er_data_changed->add_protocol_entry
3678   *                EXPORTING
3679   *                  i_msgid     = 'ZBILL'
3680   *                  i_msgty     = 'E'
3681   *                  i_msgno     = '002'
3682   **                 I_MSGV1     = 'max rent'
3683   **                 I_MSGV2     = 'app rent'
3684   **                 I_MSGV3     =
3685   **                 I_MSGV4     =
3686   *                  i_fieldname = wa_cell-fieldname
3687   *                  i_row_id    = wa_cell-row_id
3688   **                 I_TABIX     =
3689   *                .
3690   *            ELSEIF  ap_rent < 0 AND ac_rent > 0.
3691   *              CALL METHOD er_data_changed->add_protocol_entry
3692   *                EXPORTING
3693   *                  i_msgid     = 'ZBILL'
3694   *                  i_msgty     = 'E'
3695   *                  i_msgno     = '012'
3696   *                  i_fieldname = wa_cell-fieldname
3697   *                  i_row_id    = wa_cell-row_id.
3698   *
3699   *            ELSEIF  ac_rent < 0 AND ap_rent > 0.
3700   *              CALL METHOD er_data_changed->add_protocol_entry
3701   *                EXPORTING
3702   *                  i_msgid     = 'ZBILL'
3703   *                  i_msgty     = 'E'
3704   *                  i_msgno     = '013'
3705   *                  i_fieldname = wa_cell-fieldname
3706   *                  i_row_id    = wa_cell-row_id.
3707   **            ENDIF.
3708   ********************* MAKING REMARKS MANDATORY WHEN AMOUNT CHANGED
3709   *            ELSEIF ap_rent NE ac_rent AND sy-tcode = 'ZFIBD_POST'.
3710   *
3711   *              CALL METHOD er_data_changed->get_cell_value
3712   *                EXPORTING
3713   *                  i_row_id    = wa_cell-row_id
3714   **                 I_TABIX     =
3715   *                  i_fieldname = 'SEC_REMARKS'
3716   *                IMPORTING
3717   *                  e_value     = check_sec_remarks.
3718   *
3719   *              IF check_sec_remarks IS INITIAL.
3720   *
3721   *                CALL METHOD er_data_changed->add_protocol_entry
3722   *                  EXPORTING
3723   *                    i_msgid     = 'ZBILL'
3724   *                    i_msgty     = 'E'
3725   *                    i_msgno     = '004'
3726   **                   I_MSGV1     = 'max rent'
3727   **                   I_MSGV2     = 'app rent'
3728   **                   I_MSGV3     =
3729   **                   I_MSGV4     =
3730   **                   I_FIELDNAME = WA_CELL-FIELDNAME
3731   *                    i_fieldname = 'SEC_REMARKS'
3732   *                    i_row_id    = wa_cell-row_id
3733   **                   I_TABIX     =
3734   *                  .
3735   *              ENDIF.
3736   *
3737   **            ENDIF.
3738   *
3739   *            ELSEIF ap_rent NE ac_rent AND sy-tcode = 'ZFIBD_PROCESS'.
3740   *
3741   *              CALL METHOD er_data_changed->get_cell_value
3742   *                EXPORTING
3743   *                  i_row_id    = wa_cell-row_id
3744   **                 I_TABIX     =
3745   *                  i_fieldname = 'REMARKS'
3746   *                IMPORTING
3747   *                  e_value     = check_remarks.
3748   *
3749   *              IF check_remarks IS INITIAL.
3750   *
3751   *                CALL METHOD er_data_changed->add_protocol_entry
3752   *                  EXPORTING
3753   *                    i_msgid     = 'ZBILL'
3754   *                    i_msgty     = 'E'
3755   *                    i_msgno     = '004'
3756   **                   I_MSGV1     = 'max rent'
3757   **                   I_MSGV2     = 'app rent'
3758   **                   I_MSGV3     =
3759   **                   I_MSGV4     =
3760   **                   I_FIELDNAME = WA_CELL-FIELDNAME
3761   *                    i_fieldname = 'REMARKS'
3762   *                    i_row_id    = wa_cell-row_id
3763   **                   I_TABIX     =
3764   *                  .
3765   *              ENDIF.
3766   *
3767   *            ENDIF.
3768
3769   ******************************** END OF CHANGED
3770             WHEN 'CALL_CHARGES_FINAL'.
3771               PERFORM f_validate_cell_value USING er_data_changed
3772                                                   wa_cell
3773                                                   wa_cell-fieldname
3774                                                   'CALL_CHARGE'.
3775
3776   *            CALL METHOD er_data_changed->get_cell_value
3777   *              EXPORTING
3778   *                i_row_id    = wa_cell-row_id
3779   **               I_TABIX     =
3780   *                i_fieldname = wa_cell-fieldname
3781   *              IMPORTING
3782   *                e_value     = ap_charge.
3783   *            CALL METHOD er_data_changed->get_cell_value
3784   *              EXPORTING
3785   *                i_row_id    = wa_cell-row_id
3786   **               I_TABIX     =
3787   *                i_fieldname = 'CALL_CHARGE'
3788   *              IMPORTING
3789   *                e_value     = ac_charge.
3790   *            IF  ac_charge < ap_charge AND ac_charge > 0.
3791   *
3792   *              CALL METHOD er_data_changed->add_protocol_entry
3793   *                EXPORTING
3794   *                  i_msgid     = 'ZBILL'
3795   *                  i_msgty     = 'E'
3796   *                  i_msgno     = '002'
3797   *                  i_fieldname = wa_cell-fieldname
3798   *                  i_row_id    = wa_cell-row_id.
3799   *
3800   *            ELSEIF  ap_charge < 0 AND ac_charge > 0.
3801   *              CALL METHOD er_data_changed->add_protocol_entry
3802   *                EXPORTING
3803   *                  i_msgid     = 'ZBILL'
3804   *                  i_msgty     = 'E'
3805   *                  i_msgno     = '012'
3806   *                  i_fieldname = wa_cell-fieldname
3807   *                  i_row_id    = wa_cell-row_id.
3808   *
3809   *            ELSEIF  ac_charge < 0 AND ap_charge > 0.
3810   *              CALL METHOD er_data_changed->add_protocol_entry
3811   *                EXPORTING
3812   *                  i_msgid     = 'ZBILL'
3813   *                  i_msgty     = 'E'
3814   *                  i_msgno     = '013'
3815   *                  i_fieldname = wa_cell-fieldname
3816   *                  i_row_id    = wa_cell-row_id.
3817   **          ENDIF.
3818   ********************* MAKING REMARKS MANDATORY WHEN AMOUNT CHANGED
3819   *            ELSEIF ap_charge NE ac_charge AND sy-tcode = 'ZFIBD_PROCESS'.
3820   *
3821   *              CALL METHOD er_data_changed->get_cell_value
3822   *                EXPORTING
3823   *                  i_row_id    = wa_cell-row_id
3824   **                 I_TABIX     =
3825   *                  i_fieldname = 'REMARKS'
3826   *                IMPORTING
3827   *                  e_value     = check_remarks.
3828   *
3829   *              IF check_remarks IS INITIAL.
3830   *
3831   *                CALL METHOD er_data_changed->add_protocol_entry
3832   *                  EXPORTING
3833   *                    i_msgid     = 'ZBILL'
3834   *                    i_msgty     = 'E'
3835   *                    i_msgno     = '004'
3836   **                   I_MSGV1     = 'max rent'
3837   **                   I_MSGV2     = 'app rent'
3838   **                   I_MSGV3     =
3839   **                   I_MSGV4     =
3840   **                   I_FIELDNAME = WA_CELL-FIELDNAME
3841   *                    i_fieldname = 'REMARKS'
3842   *                    i_row_id    = wa_cell-row_id
3843   **                   I_TABIX     =
3844   *                  .
3845   *              ENDIF.
3846   *
3847   **            ENDIF.
3848   *
3849   *            ELSEIF ap_charge NE ac_charge AND sy-tcode = 'ZFIBD_POST'.
3850   *
3851   *              CALL METHOD er_data_changed->get_cell_value
3852   *                EXPORTING
3853   *                  i_row_id    = wa_cell-row_id
3854   **                 I_TABIX     =
3855   *                  i_fieldname = 'SEC_REMARKS'
3856   *                IMPORTING
3857   *                  e_value     = check_remarks.
3858   *
3859   *              IF check_sec_remarks IS INITIAL.
3860   *
3861   *                CALL METHOD er_data_changed->add_protocol_entry
3862   *                  EXPORTING
3863   *                    i_msgid     = 'ZBILL'
3864   *                    i_msgty     = 'E'
3865   *                    i_msgno     = '004'
3866   **                   I_MSGV1     = 'max rent'
3867   **                   I_MSGV2     = 'app rent'
3868   **                   I_MSGV3     =
3869   **                   I_MSGV4     =
3870   **                   I_FIELDNAME = WA_CELL-FIELDNAME
3871   *                    i_fieldname = 'SEC_REMARKS'
3872   *                    i_row_id    = wa_cell-row_id
3873   **                   I_TABIX     =
3874   *                  .
3875   *              ENDIF.
3876   *
3877   *            ENDIF.
3878
3879   ******************************** END OF CHANGED
3880             WHEN 'OTH_CHARGES_FIN'.
3881
3882               PERFORM f_validate_cell_value USING er_data_changed
3883                                                   wa_cell
3884                                                   wa_cell-fieldname
3885                                                   'OTH_CHARGES'.
3886
3887   *            CALL METHOD er_data_changed->get_cell_value
3888   *              EXPORTING
3889   *                i_row_id    = wa_cell-row_id
3890   **               I_TABIX     =
3891   *                i_fieldname = wa_cell-fieldname
3892   *              IMPORTING
3893   *                e_value     = ap_ot_charge.
3894   *            CALL METHOD er_data_changed->get_cell_value
3895   *              EXPORTING
3896   *                i_row_id    = wa_cell-row_id
3897   **               I_TABIX     =
3898   *                i_fieldname = 'OTH_CHARGES'
3899   *              IMPORTING
3900   *                e_value     = ac_ot_charge.
3901   *            IF  ac_ot_charge < ap_ot_charge AND ac_ot_charge > 0.
3902   *
3903   *              CALL METHOD er_data_changed->add_protocol_entry
3904   *                EXPORTING
3905   *                  i_msgid     = 'ZBILL'
3906   *                  i_msgty     = 'E'
3907   *                  i_msgno     = '002'
3908   **                 I_MSGV1     = 'max rent'
3909   **                 I_MSGV2     = 'app rent'
3910   **                 I_MSGV3     =
3911   **                 I_MSGV4     =
3912   *                  i_fieldname = wa_cell-fieldname
3913   *                  i_row_id    = wa_cell-row_id
3914   **                 I_TABIX     =
3915   *                .
3916   *            ELSEIF  ap_ot_charge < 0 AND ac_ot_charge > 0.
3917   *              CALL METHOD er_data_changed->add_protocol_entry
3918   *                EXPORTING
3919   *                  i_msgid     = 'ZBILL'
3920   *                  i_msgty     = 'E'
3921   *                  i_msgno     = '012'
3922   *                  i_fieldname = wa_cell-fieldname
3923   *                  i_row_id    = wa_cell-row_id.
3924   *
3925   *            ELSEIF  ac_ot_charge < 0 AND ap_ot_charge > 0.
3926   *              CALL METHOD er_data_changed->add_protocol_entry
3927   *                EXPORTING
3928   *                  i_msgid     = 'ZBILL'
3929   *                  i_msgty     = 'E'
3930   *                  i_msgno     = '013'
3931   *                  i_fieldname = wa_cell-fieldname
3932   *                  i_row_id    = wa_cell-row_id.
3933   *
3934   *            ELSEIF  ac_ot_charge < 0 AND ap_ot_charge < ac_ot_charge.
3935   *              CALL METHOD er_data_changed->add_protocol_entry
3936   *                EXPORTING
3937   *                  i_msgid     = 'ZBILL'
3938   *                  i_msgty     = 'E'
3939   *                  i_msgno     = '014'
3940   *                  i_fieldname = wa_cell-fieldname
3941   *                  i_row_id    = wa_cell-row_id.
3942   *
3943   *            ENDIF.
3944
3945             WHEN 'SERVICE_TAX_FIN'.
3946               PERFORM f_validate_cell_value USING er_data_changed
3947                                                   wa_cell
3948                                                   wa_cell-fieldname
3949                                                   'SERVICE_TAX'.
3950
3951   *            CALL METHOD er_data_changed->get_cell_value
3952   *              EXPORTING
3953   *                i_row_id    = wa_cell-row_id
3954   **               I_TABIX     =
3955   *                i_fieldname = wa_cell-fieldname
3956   *              IMPORTING
3957   *                e_value     = ap_service.
3958   *            CALL METHOD er_data_changed->get_cell_value
3959   *              EXPORTING
3960   *                i_row_id    = wa_cell-row_id
3961   **               I_TABIX     =
3962   *                i_fieldname = 'SERVICE_TAX'
3963   *              IMPORTING
3964   *                e_value     = ac_service.
3965   *            IF  ac_service < ap_service AND ac_service > 0.
3966   *
3967   *              CALL METHOD er_data_changed->add_protocol_entry
3968   *                EXPORTING
3969   *                  i_msgid     = 'ZBILL'
3970   *                  i_msgty     = 'E'
3971   *                  i_msgno     = '002'
3972   **                 I_MSGV1     = 'max rent'
3973   **                 I_MSGV2     = 'app rent'
3974   **                 I_MSGV3     =
3975   **                 I_MSGV4     =
3976   *                  i_fieldname = wa_cell-fieldname
3977   *                  i_row_id    = wa_cell-row_id
3978   **                 I_TABIX     =
3979   *                .
3980   *            ELSEIF  ap_service < 0 AND ac_service > 0.
3981   *              CALL METHOD er_data_changed->add_protocol_entry
3982   *                EXPORTING
3983   *                  i_msgid     = 'ZBILL'
3984   *                  i_msgty     = 'E'
3985   *                  i_msgno     = '012'
3986   *                  i_fieldname = wa_cell-fieldname
3987   *                  i_row_id    = wa_cell-row_id.
3988   *
3989   *            ELSEIF  ac_service < 0 AND ap_service > 0.
3990   *              CALL METHOD er_data_changed->add_protocol_entry
3991   *                EXPORTING
3992   *                  i_msgid     = 'ZBILL'
3993   *                  i_msgty     = 'E'
3994   *                  i_msgno     = '013'
3995   *                  i_fieldname = wa_cell-fieldname
3996   *                  i_row_id    = wa_cell-row_id.
3997   *
3998   *
3999   **            ENDIF.
4000   *
4001   *
4002   ********************* MAKING REMARKS MANDATORY WHEN AMOUNT CHANGED
4003   *            ELSEIF ap_service NE ac_service AND sy-tcode = 'ZFIBD_PROCESS'.
4004   *
4005   *              CALL METHOD er_data_changed->get_cell_value
4006   *                EXPORTING
4007   *                  i_row_id    = wa_cell-row_id
4008   **                 I_TABIX     =
4009   *                  i_fieldname = 'REMARKS'
4010   *                IMPORTING
4011   *                  e_value     = check_remarks.
4012   *
4013   *              IF check_remarks IS INITIAL.
4014   *
4015   *                CALL METHOD er_data_changed->add_protocol_entry
4016   *                  EXPORTING
4017   *                    i_msgid     = 'ZBILL'
4018   *                    i_msgty     = 'E'
4019   *                    i_msgno     = '004'
4020   **                   I_MSGV1     = 'max rent'
4021   **                   I_MSGV2     = 'app rent'
4022   **                   I_MSGV3     =
4023   **                   I_MSGV4     =
4024   **                   I_FIELDNAME = WA_CELL-FIELDNAME
4025   *                    i_fieldname = 'REMARKS'
4026   *                    i_row_id    = wa_cell-row_id
4027   **                   I_TABIX     =
4028   *                  .
4029   *              ENDIF.
4030   *
4031   **            ENDIF.
4032   *
4033   *            ELSEIF ap_service NE ac_service AND sy-tcode = 'ZFIBD_POST'.
4034   *
4035   *              CALL METHOD er_data_changed->get_cell_value
4036   *                EXPORTING
4037   *                  i_row_id    = wa_cell-row_id
4038   **                 I_TABIX     =
4039   *                  i_fieldname = 'SEC_REMARKS'
4040   *                IMPORTING
4041   *                  e_value     = check_remarks.
4042   *
4043   *              IF check_sec_remarks IS INITIAL.
4044   *
4045   *                CALL METHOD er_data_changed->add_protocol_entry
4046   *                  EXPORTING
4047   *                    i_msgid     = 'ZBILL'
4048   *                    i_msgty     = 'E'
4049   *                    i_msgno     = '004'
4050   **                   I_MSGV1     = 'max rent'
4051   **                   I_MSGV2     = 'app rent'
4052   **                   I_MSGV3     =
4053   **                   I_MSGV4     =
4054   **                   I_FIELDNAME = WA_CELL-FIELDNAME
4055   *                    i_fieldname = 'SEC_REMARKS'
4056   *                    i_row_id    = wa_cell-row_id
4057   **                   I_TABIX     =
4058   *                  .
4059   *              ENDIF.
4060   *
4061   *            ENDIF.
4062
4063             WHEN 'SECURITY_DEP_FIN'.
4064               PERFORM f_validate_cell_value USING er_data_changed
4065                                                   wa_cell
4066                                                   wa_cell-fieldname
4067                                                   'SECURITY_DEP'.
4068
4069             WHEN 'INTEREST_FIN'.
4070               PERFORM f_validate_cell_value USING er_data_changed
4071                                                   wa_cell
4072                                                   wa_cell-fieldname
4073                                                   'INTEREST'.
4074
4075             WHEN 'MISCL_FIN'.
4076               PERFORM f_validate_cell_value USING er_data_changed
4077                                                   wa_cell
4078                                                   wa_cell-fieldname
4079                                                   'MISCL'.
4080   ******************************** END OF CHANGED
4081
4082           ENDCASE.
4083           CLEAR wa_cell.
4084         ENDLOOP.
4085
4086   *  LOOP AT IT_ITEM2 INTO WA_ITEM2.
4087   *
4088   *    CASE WA_ITEM2-RENT_FINAL.
4089   *    	WHEN .
4090   *    	WHEN .
4091   *    	WHEN OTHERS.
4092   *    ENDCASE.
4093   *
4094   *  ENDLOOP.
4095
4096       ENDFORM.                    " HANDLE_CHECKBOX
4097   *&---------------------------------------------------------------------*
4098   *&      Form  EXPOST
4099   *&---------------------------------------------------------------------*
4100   *       text
4101   *----------------------------------------------------------------------*
4102   *  -->  p1        text
4103   *  <--  p2        text
4104   *----------------------------------------------------------------------*
4105       FORM expost .
4106
4107         CALL METHOD r_grid->check_changed_data.
4108
4109         LOOP AT it_item2 INTO wa_item2 WHERE check IS NOT INITIAL AND status NE '2'.
4110
4111   *         Rent
4112           PERFORM f_check_at_save USING wa_item2-rent
4113                                         wa_item2-rent_final
4114                                         wa_item2
4115                                         'RENT_FINAL'.
4116
4117   *         Variable Charges
4118           PERFORM f_check_at_save USING wa_item2-call_charge
4119                                         wa_item2-call_charges_final
4120                                         wa_item2
4121                                         'CALL_CHARGES_FINAL'.
4122
4123   *         Recoveries
4124           PERFORM f_check_at_save USING wa_item2-oth_charges
4125                                         wa_item2-oth_charges_fin
4126                                         wa_item2
4127                                         'OTH_CHARGES_FIN'.
4128
4129   *         Taxes
4130           PERFORM f_check_at_save USING wa_item2-service_tax
4131                                         wa_item2-service_tax_fin
4132                                         wa_item2
4133                                         'SERVICE_TAX_FIN'.
4134
4135   *         Security Deposit
4136           PERFORM f_check_at_save USING wa_item2-security_dep
4137                                         wa_item2-security_dep_fin
4138                                         wa_item2
4139                                         'SECURITY_DEP_FIN'.
4140
4141   *         Interest
4142           PERFORM f_check_at_save USING wa_item2-interest
4143                                         wa_item2-interest_fin
4144                                         wa_item2
4145                                         'INTEREST_FIN'.
4146
4147   *         Miscellaneous
4148           PERFORM f_check_at_save USING wa_item2-miscl
4149                                         wa_item2-miscl_fin
4150                                         wa_item2
4151                                         'MISCL_FIN'.
4152
4153
4154   *        IF wa_item2-rent_final GT wa_item2-rent.
4155   *          MESSAGE e001(zbill) WITH wa_item2-reqt_num wa_item2-reqt_id.
4156   *        ENDIF.
4157   *        IF wa_item2-rent_final NE wa_item2-rent.
4158   *          IF wa_item2-remarks IS INITIAL.
4159   *            MESSAGE e006(zbill) WITH wa_item2-reqt_num wa_item2-reqt_id.
4160   *          ENDIF.
4161   *
4162   *        ENDIF.
4163   *
4164   *        IF wa_item2-call_charges_final GT wa_item2-call_charge.
4165   *          MESSAGE e001(zbill) WITH wa_item2-reqt_num wa_item2-reqt_id.
4166   *        ENDIF.
4167   *        IF wa_item2-call_charges_final NE wa_item2-call_charge.
4168   *          IF wa_item2-remarks IS INITIAL.
4169   *            MESSAGE e006(zbill) WITH wa_item2-reqt_num wa_item2-reqt_id.
4170   *          ENDIF.
4171   *        ENDIF.
4172   *
4173   *        IF wa_item2-oth_charges_fin GT wa_item2-oth_charges.
4174   *          MESSAGE e001(zbill) WITH wa_item2-reqt_num wa_item2-reqt_id.
4175   *        ENDIF.
4176   *        IF wa_item2-oth_charges_fin NE wa_item2-oth_charges.
4177   *          IF wa_item2-remarks IS INITIAL.
4178   *            MESSAGE e006(zbill) WITH wa_item2-reqt_num wa_item2-reqt_id.
4179   *          ENDIF.
4180   *        ENDIF.
4181   *
4182   *        IF wa_item2-service_tax_fin GT wa_item2-service_tax.
4183   *          MESSAGE e001(zbill) WITH wa_item2-reqt_num wa_item2-reqt_id.
4184   *        ENDIF.
4185   *        IF wa_item2-service_tax_fin NE wa_item2-service_tax.
4186   *          IF wa_item2-remarks IS INITIAL.
4187   *            MESSAGE e006(zbill) WITH wa_item2-reqt_num wa_item2-reqt_id.
4188   *          ENDIF.
4189   *        ENDIF.
4190
4191
4192           REFRESH wa_item2-style[].
4193
4194           wa_item2-status = '2'.
4195           MODIFY it_item2 FROM wa_item2.
4196
4197           CLEAR ls_style.
4198           ls_style-fieldname = 'CALL_CHARGES_FINAL'.
4199           ls_style-style     = cl_gui_alv_grid=>mc_style_disabled .
4200           INSERT ls_style INTO TABLE wa_item2-style.
4201
4202           CLEAR ls_style.
4203           ls_style-fieldname = 'CHECK'.
4204           ls_style-style     = cl_gui_alv_grid=>mc_style_disabled .
4205           INSERT ls_style INTO TABLE wa_item2-style.
4206
4207           CLEAR ls_style.
4208           ls_style-fieldname = 'CHECK1'.
4209           ls_style-style     = cl_gui_alv_grid=>mc_style_disabled .
4210           INSERT ls_style INTO TABLE wa_item2-style.
4211
4212           CLEAR ls_style.
4213           ls_style-fieldname = 'INTEREST_FIN'.
4214           ls_style-style     = cl_gui_alv_grid=>mc_style_disabled .
4215           INSERT ls_style INTO TABLE wa_item2-style.
4216
4217           CLEAR ls_style.
4218           ls_style-fieldname = 'MISCL_FIN'.
4219           ls_style-style     = cl_gui_alv_grid=>mc_style_disabled .
4220           INSERT ls_style INTO TABLE wa_item2-style.
4221
4222           CLEAR ls_style.
4223           ls_style-fieldname = 'OTH_CHARGES_FIN'.
4224           ls_style-style     = cl_gui_alv_grid=>mc_style_disabled .
4225           INSERT ls_style INTO TABLE wa_item2-style.
4226
4227           CLEAR ls_style.
4228           ls_style-fieldname = 'REMARKS'.
4229           ls_style-style     = cl_gui_alv_grid=>mc_style_disabled .
4230           INSERT ls_style INTO TABLE wa_item2-style.
4231
4232           CLEAR ls_style.
4233           ls_style-fieldname = 'RENT_FINAL'.
4234           ls_style-style     = cl_gui_alv_grid=>mc_style_disabled .
4235           INSERT ls_style INTO TABLE wa_item2-style.
4236
4237           CLEAR ls_style.
4238           ls_style-fieldname = 'SECURITY_DEP_FIN'.
4239           ls_style-style     = cl_gui_alv_grid=>mc_style_disabled .
4240           INSERT ls_style INTO TABLE wa_item2-style.
4241
4242           CLEAR ls_style.
4243           ls_style-fieldname = 'SERVICE_TAX_FIN'.
4244           ls_style-style     = cl_gui_alv_grid=>mc_style_disabled .
4245           INSERT ls_style INTO TABLE wa_item2-style.
4246
4247           CLEAR ls_style.
4248
4249
4250   *    WA_ITEM2-CHECK = ''.
4251   *    WA_ITEM2-CHECK1 = ''.
4252
4253   *    WA_ITEM1-ROWCOLOR = 'C600'.
4254
4255           MODIFY it_item2 FROM wa_item2.
4256           CLEAR: wa_item2,wa_item3.
4257           REFRESH wa_item2-style[].
4258
4259         ENDLOOP.
4260
4261         LOOP AT it_item2 INTO wa_item2 WHERE check1 IS NOT INITIAL.
4262
4263           wa_item2-status = '3'.
4264           MODIFY it_item2 FROM wa_item2.
4265
4266         ENDLOOP.
4267
4268         CALL METHOD r_grid->refresh_table_display.
4269
4270
4271       ENDFORM.                    " EXPOST
4272   *&---------------------------------------------------------------------*
4273   *&      Form  PRINT_FORM
4274   *&---------------------------------------------------------------------*
4275   *       text
4276   *----------------------------------------------------------------------*
4277   *  -->  p1        text
4278   *  <--  p2        text
4279   *----------------------------------------------------------------------*
4280       FORM print_form .
4281
4282         DATA: l_outputparams      TYPE sfpoutputparams,
4283               gv_fm_name          TYPE rs38l_fnam,
4284               gv_form             TYPE fpwbformname.
4285         DATA : formoutput TYPE fpformoutput.
4286         gv_form = 'ZBILLER_PAYMENT_FORM'.
4287
4288         CLEAR : wa_item2.
4289
4290         READ TABLE it_item2 INTO wa_item2 WITH KEY check = 'X'.
4291
4292         CALL FUNCTION 'FP_JOB_OPEN'
4293           CHANGING
4294             ie_outputparams = l_outputparams
4295           EXCEPTIONS
4296             cancel          = 1
4297             usage_error     = 2
4298             system_error    = 3
4299             internal_error  = 4
4300             OTHERS          = 5.
4301         IF sy-subrc <> 0.
4302   * Implement suitable error handling here
4303         ENDIF.
4304
4305         CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'
4306           EXPORTING
4307             i_name              = gv_form
4308           IMPORTING
4309             e_funcname          = gv_fm_name
4310   *         E_INTERFACE_TYPE    =
4311   *         EV_FUNCNAME_INBOUND =
4312           .
4313
4314         CALL FUNCTION gv_fm_name "'/1BCDWB/SM00000146'
4315         EXPORTING
4316   *   /1BCDWB/DOCPARAMS        =
4317           reqt_num               = wa_item2-reqt_num
4318         IMPORTING
4319           /1bcdwb/formoutput       = formoutput
4320         EXCEPTIONS
4321           usage_error              = 1
4322           system_error             = 2
4323           internal_error           = 3
4324           OTHERS                   = 4
4325           .
4326         IF sy-subrc <> 0.
4327   * Implement suitable error handling here
4328         ENDIF.
4329
4330         CALL FUNCTION 'FP_JOB_CLOSE'
4331           EXCEPTIONS
4332             usage_error    = 1
4333             system_error   = 2
4334             internal_error = 3
4335             OTHERS         = 4.
4336         IF sy-subrc <> 0.
4337   * Implement suitable error handling here
4338         ENDIF.
4339
4340       ENDFORM.                    " PRINT_FORM
4341   *&---------------------------------------------------------------------*
4342   *&      Form  PUT_REMARK
4343   *&---------------------------------------------------------------------*
4344   *       text
4345   *----------------------------------------------------------------------*
4346   *  -->  p1        text
4347   *  <--  p2        text
4348   *----------------------------------------------------------------------*
4349       FORM put_remark.
4350   *  DATA : IT_CELL1 TYPE LVC_T_MODI.
4351   *
4352   *
4353   *  IF OK_CODE = 'SAVE'.
4354   *    IMPORT IT_CELL1 FROM MEMORY ID 'CELL1'.
4355   *  ENDIF.
4356
4357         CALL SCREEN 0901.
4358
4359
4360
4361       ENDFORM.                    " PUT_REMARK
4362
4363   *&---------------------------------------------------------------------*
4364   *&      Module  STATUS_0901  OUTPUT
4365   *&---------------------------------------------------------------------*
4366   *       text
4367   *----------------------------------------------------------------------*
4368       MODULE status_0901 OUTPUT.
4369         SET PF-STATUS 'ST_901'.
4370         SET TITLEBAR 'TL_901'.
4371
4372       ENDMODULE.                 " STATUS_0901  OUTPUT
4373   *&---------------------------------------------------------------------*
4374   *&      Module  USER_COMMAND_0901  INPUT
4375   *&---------------------------------------------------------------------*
4376   *       text
4377   *----------------------------------------------------------------------*
4378       MODULE user_command_0901 INPUT.
4379
4380
4381
4382         CASE okcode_901.
4383           WHEN 'BACK' OR 'EXIT'.
4384
4385             LEAVE TO SCREEN 0.
4386
4387   *  	WHEN 'SAVE'.
4388           WHEN OTHERS.
4389         ENDCASE.
4390
4391       ENDMODULE.                 " USER_COMMAND_0901  INPUT
4392   *&---------------------------------------------------------------------*
4393   *&      Module  REMARK_TEXT_901  OUTPUT
4394   *&---------------------------------------------------------------------*
4395   *       text
4396   *----------------------------------------------------------------------*
4397       MODULE remark_text_901 OUTPUT.
4398
4399         IF go_cc_name IS INITIAL.
4400
4401
4402
4403         ENDIF.
4404
4405
4406       ENDMODULE.                 " REMARK_TEXT_901  OUTPUT
4407   **&---------------------------------------------------------------------*
4408   **&      Form  SIMULATE
4409   **&---------------------------------------------------------------------*
4410   **       text
4411   **----------------------------------------------------------------------*
4412   **  -->  p1        text
4413   **  <--  p2        text
4414   **----------------------------------------------------------------------*
4415   *    FORM simulate .
4416   *
4417   *      TYPES : BEGIN OF ty_billtype,
4418   *      key TYPE char10,
4419   *      text TYPE c LENGTH 60,
4420   *      END OF ty_billtype.
4421   *
4422   *      TYPES : BEGIN OF ty_error,
4423   *      er_type TYPE bapi_mtype,
4424   *      msg_id TYPE symsgid,
4425   *      msg_num TYPE symsgno,
4426   *      msg TYPE bapi_msg,
4427   *      reqnum TYPE  zbill_req_nm,
4428   *      END OF ty_error.
4429   *
4430   *      DATA :  it_error TYPE TABLE OF ty_error,
4431   *            wa_error TYPE          ty_error.
4432   *
4433   *      TYPES : BEGIN OF ty_error1,
4434   *      er_type TYPE bapi_mtype,
4435   *      msg_id TYPE symsgid,
4436   *      msg_num TYPE symsgno,
4437   *      msg TYPE bapi_msg,
4438   *      reqnum TYPE  zbill_req_nm,
4439   *      pernr TYPE pernr_d,
4440   *      END OF ty_error1.
4441   *
4442   *      DATA :  it_error1 TYPE TABLE OF ty_error1,
4443   *            wa_error1 TYPE          ty_error1.
4444   *
4445   *      DATA : wa_header TYPE bapiache09,
4446   *            wa_accountgl TYPE bapiacgl09,
4447   *            wa_accountgl2 TYPE bapiacgl09,
4448   *            wa_payable TYPE bapiacap09,
4449   *            it_accountgl TYPE STANDARD TABLE OF bapiacgl09,
4450   *            it_accountgl1 TYPE STANDARD TABLE OF bapiacgl09,
4451   *            it_accountgl2 TYPE STANDARD TABLE OF bapiacgl09,
4452   *            it_payable TYPE STANDARD TABLE OF bapiacap09,
4453   *            wa_return TYPE bapiret2,
4454   *            it_return TYPE STANDARD TABLE OF bapiret2,
4455   *            it_values TYPE re_t_rsdomaval,
4456   *            wa_values TYPE LINE OF re_t_rsdomaval,
4457   *            it_billtype TYPE STANDARD TABLE OF ty_billtype,
4458   *            wa_billtype TYPE ty_billtype,
4459   *            it_billhead TYPE STANDARD TABLE OF zbill_head,
4460   *            wa_billhead TYPE zbill_head,
4461   *            it_currency TYPE STANDARD TABLE OF bapiaccr09,
4462   *            it_currency1 TYPE STANDARD TABLE OF bapiaccr09,
4463   *            wa_currency TYPE bapiaccr09,
4464   *            wa_extension TYPE bapiparex,
4465   *            it_extension TYPE bapiparex_tab_ac,
4466   *            lv_total TYPE zbill_call_charges,
4467   *            l_total_pay TYPE zbill_call_charges,
4468   *            l_total_acc TYPE zbill_call_charges,
4469   *            l_kst01 TYPE kostl,
4470   *            lv_item TYPE posnr_acc,
4471   *            ind TYPE sy-index,
4472   *            lv_attach_check TYPE char1,
4473   *            wa_pa9105 TYPE p9105,
4474   *            it_pa9105 TYPE TABLE OF p9105, " + BY SAB_BIPIN ON 11/11/2013
4475   *            it_pa9105_1 TYPE TABLE OF p9105, " + BY SAB_BIPIN ON 11/11/2013
4476   *            it_pa9105_2 TYPE TABLE OF p9105, " + BY SAB_BIPIN ON 11/11/2013
4477   *            it_pa9105_3 TYPE TABLE OF p9105, " + BY SAB_BIPIN ON 11/11/2013
4478   *            it_pa9105_4 TYPE TABLE OF p9105, " + BY SAB_BIPIN ON 11/11/2013
4479   *            it_pa9105_5 TYPE TABLE OF p9105, " + BY SAB_BIPIN ON 11/11/2013
4480   *            it_data_temp TYPE TABLE OF p9105,
4481   *            lt_pa9205 TYPE TABLE OF pa9205,
4482   *            wa_pa9205 TYPE pa9205,
4483   *            lv_len TYPE i,
4484   *            lv_phone10 TYPE char11,
4485   *            lv_phone11 TYPE char11.
4486   *
4487   *      DATA : wa_user TYPE bapip0001.
4488   *
4489   *      DATA : it_bapireturn TYPE STANDARD TABLE OF bapireturn1,
4490   *            l_bapireturn TYPE bapireturn1,
4491   *            l_key TYPE bapipakey,
4492   *            l_return        TYPE bapireturn1.
4493   **        ls_doc_data TYPE          ty_item1.
4494   *
4495   *      TYPES :  BEGIN OF ty_hr_return,
4496   *      ermsg_type  TYPE bapi_mtype,
4497   *      er_id  TYPE symsgid,
4498   *      er_number TYPE symsgno,
4499   *      er_message TYPE bapi_msg,
4500   *      pernr TYPE persno,
4501   *      re_num  TYPE zbill_req_nm,
4502   *      END OF ty_hr_return.
4503   *
4504   *      DATA : it_hr_return TYPE TABLE OF ty_hr_return,
4505   *            wa_hr_return TYPE ty_hr_return.
4506   *
4507   *      CALL METHOD r_grid->check_changed_data.
4508   *
4509   *      REFRESH it_item3.
4510   *      MOVE it_item2[] TO it_item3[].
4511   *
4512   *      SORT it_item2 BY status.
4513   *      DELETE it_item2 WHERE status   EQ '6'.
4514   *      SORT it_item2 BY check1.
4515   *      DELETE it_item2 WHERE check1  EQ 'X'.
4516   **    DELETE IT_ITEM2 WHERE CHECK  EQ 'X'.
4517   *
4518   *
4519   *
4520   *
4521   *      SORT it_item2 BY bukrs reqt_num reqt_id.
4522   **  SORT IT_ITEM2 BY REQT_NUM REQT_ID.
4523   *      IF it_item2 IS NOT INITIAL.
4524   *        SELECT * FROM zbill_head
4525   *        INTO TABLE it_billhead
4526   *        FOR ALL ENTRIES IN it_item2
4527   *        WHERE reqt_num EQ it_item2-reqt_num.
4528   *        IF sy-subrc EQ 0.
4529   *          SORT it_billhead BY reqt_num.
4530   *        ENDIF.
4531   *      ELSE.
4532   *        MESSAGE 'Please select the records which are not processed.' TYPE 'I'.
4533   *      ENDIF.
4534   *
4535   *      CALL METHOD cl_reca_ddic_doma=>get_values
4536   *        EXPORTING
4537   *          id_name   = 'ZBILL_TYPE'
4538   *          id_langu  = sy-langu
4539   *        IMPORTING
4540   *          et_values = it_values
4541   *        EXCEPTIONS
4542   *          not_found = 1
4543   *          OTHERS    = 2.
4544   *      IF sy-subrc EQ 0.
4545   *        LOOP AT it_values INTO wa_values.
4546   *          MOVE : wa_values-domvalue_l TO wa_billtype-key,
4547   *          wa_values-ddtext TO wa_billtype-text.
4548   *          APPEND wa_billtype TO it_billtype.
4549   *          CLEAR : wa_billtype,wa_values.
4550   *        ENDLOOP.
4551   *      ENDIF.
4552   *
4553   **BREAK-POINT.
4554   **  SORT IT_ITEM2 BY   REQT_NUM.
4555   *      SORT it_item2 BY bukrs reqt_num reqt_id.
4556   ******************************************* code added by Bipin Shukla : 23/12/2013 : for comp code
4557   ** FOR MAITAIN  COMPANY CODE BASED ON COST CENTER
4558   *      IF it_item2 IS NOT INITIAL.
4559   *
4560   *        SELECT * FROM zbill_gl INTO CORRESPONDING FIELDS OF TABLE gt_bill_gl
4561   *        FOR ALL ENTRIES IN it_item2
4562   *        WHERE bill_type = it_item2-bill_type.
4563   *        IF sy-subrc = 0.
4564   *          SELECT * INTO TABLE it_ska1
4565   *          FROM ska1
4566   *          FOR ALL ENTRIES IN gt_bill_gl
4567   *          WHERE
4568   *          saknr = gt_bill_gl-hkont
4569   *          AND
4570   *          xbilk <> 'X'
4571   *          AND
4572   *          ktopl = wa_t001-ktopl..
4573   *
4574   *
4575   *        ENDIF.
4576   *      ENDIF.
4577   *
4578   *      LOOP AT it_billhead INTO wa_billhead.
4579   *        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
4580   *          EXPORTING
4581   *            input  = wa_billhead-serv_prov
4582   *          IMPORTING
4583   *            output = wa_billhead-serv_prov.
4584   *        MODIFY it_billhead FROM wa_billhead.
4585   *      ENDLOOP.
4586   *      IF it_billhead IS NOT INITIAL.
4587   *        SELECT * FROM lfb1 INTO CORRESPONDING FIELDS OF TABLE gt_lfb1
4588   *        FOR ALL ENTRIES IN it_billhead
4589   *        WHERE bukrs = it_billhead-bukrs AND lifnr = it_billhead-serv_prov.
4590   *      ENDIF.
4591   ******************************************* code added by Bipin Shukla : 23/12/2013 : for comp code
4592   *
4593   *      FIELD-SYMBOLS : <fs_amt> TYPE any.
4594   *      REFRESH it_zbill_gl.
4595   *      DATA l_kts01 TYPE kostl.
4596   *
4597   *      CALL FUNCTION 'G_SET_GET_ID_FROM_NAME'
4598   *        EXPORTING
4599   *          shortname = 'Z_COST_CTR_CENVAT'       "Set Name
4600   *        IMPORTING
4601   *          new_setid = w_setid
4602   *        EXCEPTIONS
4603   *          OTHERS    = 1.
4604   *
4605   *      CALL FUNCTION 'G_SET_FETCH'
4606   *        EXPORTING
4607   *          setnr           = w_setid
4608   *        TABLES
4609   *          set_lines_basic = int_vlaues
4610   *        EXCEPTIONS
4611   *          OTHERS          = 1.
4612   *
4613   *      SORT it_item2 BY check.
4614   *      LOOP AT it_item2 INTO wa_item2 WHERE check IS NOT INITIAL.
4615   ************************************************  for HR table updation
4616   *        wa_user-pernr = wa_item2-pernr.
4617   ************************************************  for HR table updation
4618   *        CLEAR l_kts01.
4619   *        READ TABLE int_vlaues INTO wa_vlaues WITH KEY from = wa_item2-kst01.
4620   *        IF sy-subrc EQ 0.
4621   *          LOOP AT gt_bill_gl INTO wa_bill_gl.
4622   *            CLEAR wa_zbill_gl.
4623   *            ASSIGN COMPONENT wa_bill_gl-expence OF STRUCTURE wa_item2 TO <fs_amt>.
4624   *            IF <fs_amt> IS ASSIGNED.
4625   *              IF wa_bill_gl-alt_hkont IS NOT INITIAL.
4626   *                READ TABLE it_ska1 INTO wa_ska1 WITH KEY saknr = wa_bill_gl-alt_hkont.
4627   *                IF sy-subrc <> 0.
4628   *                  CLEAR l_kst01.
4629   *                ELSE.
4630   *                  l_kst01 = wa_item2-kst01.
4631   *                ENDIF.
4632   *                READ TABLE it_zbill_gl INTO wa_zbill_gl WITH KEY hkont = wa_bill_gl-alt_hkont
4633   *                costcenter = l_kst01."WA_ITEM2-KST01..
4634   *                IF sy-subrc = 0.
4635   *                  wa_zbill_gl-amount = wa_zbill_gl-amount + <fs_amt>.
4636   *                  MODIFY it_zbill_gl FROM wa_zbill_gl INDEX sy-tabix.
4637   *                ELSE.
4638   *                  READ TABLE it_ska1 INTO wa_ska1 WITH KEY saknr = wa_bill_gl-alt_hkont.
4639   *                  IF sy-subrc = 0.
4640   *                    wa_zbill_gl-costcenter = wa_item2-kst01.
4641   *                  ELSE.
4642   *                    CLEAR wa_zbill_gl-costcenter.
4643   *                  ENDIF.
4644   *                  wa_zbill_gl-hkont = wa_bill_gl-alt_hkont.
4645   *                  wa_zbill_gl-amount = <fs_amt>.
4646   *                  IF wa_zbill_gl-amount NE '0'. " + by Bipin on 20/11/2013
4647   *                    APPEND wa_zbill_gl TO it_zbill_gl.
4648   *                  ENDIF.                       " + by Bipin on 20/11/2013
4649   *                ENDIF.
4650   *              ELSE. " + BY BIPIN ON 26/11/2012
4651   *                READ TABLE it_ska1 INTO wa_ska1 WITH KEY saknr = wa_bill_gl-hkont.
4652   *                IF sy-subrc <> 0.
4653   *                  CLEAR l_kst01.
4654   *                ELSE.
4655   *                  l_kst01 = wa_item2-kst01.
4656   *                ENDIF.
4657   *                READ TABLE it_zbill_gl INTO wa_zbill_gl WITH KEY hkont = wa_bill_gl-hkont
4658   *                costcenter = l_kst01."WA_ITEM2-KST01..
4659   *                IF sy-subrc = 0.
4660   *                  wa_zbill_gl-amount = wa_zbill_gl-amount + <fs_amt>.
4661   *                  MODIFY it_zbill_gl FROM wa_zbill_gl INDEX sy-tabix.
4662   *                ELSE.
4663   *                  READ TABLE it_ska1 INTO wa_ska1 WITH KEY saknr = wa_bill_gl-hkont.
4664   *                  IF sy-subrc = 0.
4665   *                    wa_zbill_gl-costcenter = wa_item2-kst01.
4666   *                  ELSE.
4667   *                    CLEAR wa_zbill_gl-costcenter.
4668   *                  ENDIF.
4669   *                  wa_zbill_gl-hkont = wa_bill_gl-hkont.
4670   *                  wa_zbill_gl-amount = <fs_amt>.
4671   *                  IF wa_zbill_gl-amount NE '0'. " + by Bipin on 20/11/2013
4672   *                    APPEND wa_zbill_gl TO it_zbill_gl.
4673   *                  ENDIF.                       " + by Bipin on 20/11/2013
4674   *                ENDIF.
4675   *              ENDIF. " + BY BIPIN ON 26/11/2012
4676   *            ENDIF.
4677   *          ENDLOOP.
4678   *
4679   *        ELSE.
4680   *
4681   *          LOOP AT gt_bill_gl INTO wa_bill_gl.
4682   *            CLEAR wa_zbill_gl.
4683   *            ASSIGN COMPONENT wa_bill_gl-expence OF STRUCTURE wa_item2 TO <fs_amt>.
4684   *            IF <fs_amt> IS ASSIGNED.
4685   *
4686   *              READ TABLE it_ska1 INTO wa_ska1 WITH KEY saknr = wa_bill_gl-hkont.
4687   *              IF sy-subrc <> 0.
4688   *                CLEAR l_kst01.
4689   *              ELSE.
4690   *                l_kst01 = wa_item2-kst01.
4691   *              ENDIF.
4692   *
4693   *              READ TABLE it_zbill_gl INTO wa_zbill_gl WITH KEY hkont = wa_bill_gl-hkont
4694   *              costcenter = l_kst01."WA_ITEM2-KST01..
4695   *              IF sy-subrc = 0.
4696   *                wa_zbill_gl-amount = wa_zbill_gl-amount + <fs_amt>.
4697   *                MODIFY it_zbill_gl FROM wa_zbill_gl INDEX sy-tabix.
4698   *              ELSE.
4699   *                READ TABLE it_ska1 INTO wa_ska1 WITH KEY saknr = wa_bill_gl-hkont.
4700   *                IF sy-subrc = 0.
4701   *                  wa_zbill_gl-costcenter = wa_item2-kst01.
4702   *                ELSE.
4703   *                  CLEAR wa_zbill_gl-costcenter.
4704   *                ENDIF.
4705   *                wa_zbill_gl-hkont = wa_bill_gl-hkont.
4706   *                wa_zbill_gl-amount = <fs_amt>.
4707   *                IF wa_zbill_gl-amount NE '0'. " + by Bipin on 20/11/2013
4708   *                  APPEND wa_zbill_gl TO it_zbill_gl.
4709   *                ENDIF.                       " + by Bipin on 20/11/2013
4710   *              ENDIF.
4711   *            ENDIF.
4712   *          ENDLOOP.
4713   *
4714   *        ENDIF.
4715   *
4716   *        MOVE space TO gv_posted.
4717   *        lv_total = wa_item2-rent_final + wa_item2-call_charges_final
4718   *        + wa_item2-oth_charges_fin + wa_item2-service_tax_fin.
4719   *
4720   *        READ TABLE it_billhead INTO wa_billhead WITH KEY reqt_num = wa_item2-reqt_num BINARY SEARCH.
4721   *        IF sy-subrc EQ 0.
4722   *          READ TABLE it_billtype INTO wa_billtype WITH KEY key = wa_billhead-bill_type.
4723   *          IF sy-subrc EQ 0.
4724   *            MOVE wa_billtype-text TO wa_header-header_txt.
4725   *          ENDIF.
4726   *        ENDIF.
4727   *        MOVE : wa_billhead-bukrs TO wa_header-comp_code,
4728   *        wa_billhead-create_date TO wa_header-doc_date.
4729   *
4730   *        wa_header-pstng_date = post_dt. " ADDED BY BIPIN FOR POSTING DATE " ON 28/10/2013
4731   *        wa_header-doc_type = 'KM'.
4732   *        wa_header-ref_doc_no = wa_item2-reqt_num.
4733   *        wa_header-username = sy-uname.
4734   *
4735   *
4736   *        l_total_pay = l_total_pay + lv_total.
4737   *        l_total_acc = l_total_acc + lv_total.
4738   *
4739   *        ADD 1 TO lv_item.
4740   *
4741   *        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
4742   *          EXPORTING
4743   *            input  = lv_item
4744   *          IMPORTING
4745   *            output = wa_accountgl-itemno_acc.
4746   *
4747   *        wa_accountgl-item_text = wa_header-header_txt.
4748   *
4749   *        wa_accountgl-acct_type = 'S'.
4750   *        wa_accountgl-doc_type = 'KM'.
4751   *
4752   *        wa_accountgl-pstng_date = wa_header-pstng_date.
4753   *        wa_accountgl-value_date = wa_header-pstng_date.
4754   *        wa_accountgl-alloc_nmbr = wa_item2-reqt_num.
4755   **    WA_ACCOUNTGL-COSTCENTER = 'DLICSICMTN'.        " from alv
4756   *        wa_accountgl-costcenter = wa_item2-kst01.        " from alv " Changed by Bipin
4757   ************    EARMARKED FUNDS
4758   *        wa_accountgl-res_doc = er_kblnr.
4759   *        wa_accountgl-res_item = er_kblpos.
4760   ************    EARMARKED FUNDS
4761   *        wa_accountgl-ref_key_1 = wa_item2-kst01.
4762   *        APPEND wa_accountgl TO it_accountgl.
4763   *
4764   *        wa_currency-itemno_acc = wa_accountgl-itemno_acc.
4765   *        wa_currency-curr_type = '00'.
4766   *        wa_currency-currency = 'INR'.
4767   *        wa_currency-amt_doccur = l_total_acc.
4768   *        APPEND wa_currency TO it_currency.
4769   *
4770   *        CLEAR l_total_acc.
4771   *        CLEAR l_kst01.
4772   *
4773   *******************************************************     added by bipin
4774   *        SHIFT wa_item2-zphone LEFT DELETING LEADING lv_nullc.
4775   *        lv_len = strlen( wa_item2-zphone ).
4776   *        IF lv_len = 10.
4777   *          lv_phone11 = '0' && wa_item2-zphone(10).
4778   *          lv_phone10 = wa_item2-zphone(10).
4779   *        ELSEIF lv_len = 11.
4780   *          lv_phone11 = wa_item2-zphone(11).
4781   *          lv_phone10 = wa_item2-zphone+1(10).
4782   *        ELSEIF lv_len = 12.
4783   *          lv_phone11 = '0' && wa_item2-zphone+2(10).
4784   *          lv_phone10 = wa_item2-zphone+2(10).
4785   *        ELSEIF lv_len = 13.
4786   *          lv_phone11 = '0' && wa_items2-zphone+3(10).
4787   *          lv_phone10 = wa_items2-zphone+3(10).
4788   *        ENDIF.
4789   ************************************ADDED BY BIPIN ON 11/11/2013
4790   *        READ TABLE it_pa9205 INTO wa_pa9205 WITH KEY zphone = lv_phone11."wa_item2-zphone.
4791   *        IF sy-subrc = 0.
4792   *          wa_pa9105-infty = '9105'.
4793   *          wa_pa9105-begda = sy-datum.
4794   *          wa_pa9105-endda = '99991231'.
4795   *          wa_pa9105-pernr = wa_pa9205-pernr.
4796   *          CONCATENATE wa_item2-bill_from(2) wa_item2-bill_from+2(2) wa_item2-bill_from+4(4)   INTO wa_pa9105-zbill_date_fr.
4797   *          CONCATENATE wa_item2-bill_to(2) wa_item2-bill_to+2(2) wa_item2-bill_to+4(4)   INTO wa_pa9105-zbill_date_to.
4798   *          wa_pa9105-begda = wa_pa9105-zbill_date_fr.  "sy-datum.
4799   *          wa_pa9105-endda = wa_pa9105-zbill_date_to . "'99991231'.
4800   *          wa_pa9105-zbill_no = wa_item2-bill_num.
4801   *          wa_pa9105-zphn_no = lv_phone11."wa_item2-zphone."+vikas
4802   *          wa_pa9105-doc_no = wa_item2-reqt_num.
4803   *          wa_pa9105-subty   = '01'.
4804   *          wa_pa9105-aedtm   = sy-datum.
4805   *          wa_pa9105-uname   = sy-uname.
4806   *          wa_pa9105-zadm_amt = lv_total.
4807   *          APPEND wa_pa9105 TO it_pa9105.
4808   *        ELSE.
4809   *          READ TABLE it_pa9205 INTO wa_pa9205 WITH KEY zphone = lv_phone10.
4810   *          IF sy-subrc EQ 0.
4811   *            wa_pa9105-infty = '9105'.
4812   *            wa_pa9105-begda = sy-datum.
4813   *            wa_pa9105-endda = '99991231'.
4814   *            wa_pa9105-pernr = wa_pa9205-pernr.
4815   *            CONCATENATE wa_item2-bill_from(2) wa_item2-bill_from+2(2) wa_item2-bill_from+4(4)   INTO wa_pa9105-zbill_date_fr.
4816   *            CONCATENATE wa_item2-bill_to(2) wa_item2-bill_to+2(2) wa_item2-bill_to+4(4)   INTO wa_pa9105-zbill_date_to.
4817   *            wa_pa9105-begda = wa_pa9105-zbill_date_fr.  "sy-datum.
4818   *            wa_pa9105-endda = wa_pa9105-zbill_date_to . "'99991231'.
4819   *            wa_pa9105-zbill_no = wa_item2-bill_num.
4820   *            wa_pa9105-zphn_no = lv_phone10."wa_item2-zphone."+vikas
4821   *            wa_pa9105-doc_no = wa_item2-reqt_num.
4822   *            wa_pa9105-subty   = '01'.
4823   *            wa_pa9105-aedtm   = sy-datum.
4824   *            wa_pa9105-uname   = sy-uname.
4825   *            wa_pa9105-zadm_amt = lv_total.
4826   *            APPEND wa_pa9105 TO it_pa9105.
4827   *          ENDIF.
4828   *        ENDIF.
4829   ************************************ADDED BY BIPIN ON 11/11/2013
4830   *        AT END OF reqt_num.
4831   *          REFRESH it_accountgl1.
4832   *          CLEAR lv_item.
4833   *          SORT it_accountgl BY costcenter.
4834   *          MOVE it_accountgl[] TO it_accountgl2[].
4835   *          DELETE ADJACENT DUPLICATES FROM it_accountgl2 COMPARING costcenter.
4836   ********************** added by bipin on 25/11/2013
4837   *          ADD 1 TO lv_item.
4838   **   Vendor Internal Table for Posting
4839   *          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
4840   *            EXPORTING
4841   *              input  = wa_billhead-serv_prov
4842   *            IMPORTING
4843   *              output = wa_payable-vendor_no.
4844   *          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
4845   *            EXPORTING
4846   *              input  = lv_item
4847   *            IMPORTING
4848   *              output = wa_payable-itemno_acc.
4849   *
4850   *          wa_payable-comp_code = wa_header-comp_code.
4851   *          READ TABLE gt_lfb1 INTO wa_lfb1 WITH KEY bukrs = wa_header-comp_code lifnr = wa_payable-vendor_no.
4852   *          IF sy-subrc EQ 0.
4853   *            wa_payable-pmnttrms = wa_lfb1-zterm.
4854   *            wa_payable-pymt_meth = wa_lfb1-zwels.
4855   *          ENDIF.
4856   **      WA_PAYABLE-PMNTTRMS = '0001'. " Need to be changed " comment by bipin
4857   *          wa_payable-item_text = txt.
4858   **      WA_PAYABLE-BLINE_DATE = WA_BILLHEAD-CREATE_DATE. " COMMENT BY BIPIN FOR DUE DATE ON 13/11/2013
4859   *          wa_payable-bline_date = due_date.
4860   *          wa_payable-alloc_nmbr = wa_item2-reqt_num.
4861   **      WA_PAYABLE-SECTIONCODE = 'HQ'. " Need to be changed
4862   *          wa_payable-sectioncode = sec_code. " section code added by Bipin on 28/10/2013
4863   *
4864   **      WA_PAYABLE-PYMT_METH = 'S'.    " Need to be changed   " comment by bipin
4865   *
4866   *          APPEND wa_payable TO it_payable.
4867   ********************** added by bipin on 25/11/2013
4868   *
4869   *          LOOP AT it_zbill_gl INTO wa_zbill_gl.
4870   *
4871   *            l_total_acc = wa_zbill_gl-amount.
4872   *            READ TABLE it_accountgl INTO wa_accountgl WITH KEY costcenter = wa_zbill_gl-costcenter."WA_ACCOUNTGL2-COSTCENTER.
4873   *
4874   *            ADD 1 TO lv_item.
4875   *            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
4876   *              EXPORTING
4877   *                input  = lv_item
4878   *              IMPORTING
4879   *                output = wa_accountgl-itemno_acc.
4880   *
4881   *            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
4882   *              EXPORTING
4883   *                input  = wa_zbill_gl-hkont
4884   *              IMPORTING
4885   *                output = wa_accountgl-gl_account.
4886   *
4887   *
4888   **MOVE WA_ACCOUNTGL TO WA_ACCOUNTGL1.
4889   *            CLEAR wa_accountgl-ref_key_1.
4890   *
4891   *            READ TABLE it_ska1 INTO wa_ska1 WITH KEY saknr = wa_zbill_gl-hkont.
4892   *            IF sy-subrc <> 0.
4893   *              CLEAR wa_accountgl-costcenter.
4894   *              CLEAR wa_accountgl-comp_code. " + bipin
4895   *              CLEAR wa_accountgl-res_doc.
4896   *              CLEAR wa_accountgl-res_item.
4897   *            ENDIF.
4898   *
4899   *            READ TABLE gt_csks INTO wa_csks WITH KEY kostl = wa_accountgl-costcenter.
4900   *            IF sy-subrc EQ 0.
4901   *              READ TABLE it_ska1 INTO wa_ska1 WITH KEY saknr = wa_accountgl-gl_account.
4902   *              IF sy-subrc = 0.
4903   *                wa_accountgl-comp_code = wa_csks-bukrs.
4904   *              ELSE.
4905   *                CLEAR wa_accountgl-comp_code.
4906   *              ENDIF.
4907   *            ENDIF.
4908   *            APPEND wa_accountgl TO it_accountgl1.
4909   *            wa_currency-itemno_acc = wa_accountgl-itemno_acc.
4910   *            wa_currency-curr_type = '00'.
4911   *            wa_currency-currency = 'INR'.
4912   *            wa_currency-amt_doccur = l_total_acc.
4913   *
4914   *            APPEND wa_currency TO it_currency1.
4915   *            CLEAR l_total_acc.
4916   *          ENDLOOP.
4917   *
4918   *          wa_currency-itemno_acc = wa_payable-itemno_acc.
4919   *          wa_currency-curr_type = '00'.
4920   *          wa_currency-currency = 'INR'.
4921   *          COMPUTE wa_currency-amt_doccur = ( l_total_pay * -1 ).
4922   *          APPEND wa_currency TO it_currency1.
4923   *
4924   *          wa_extension-valuepart1 = sy-repid.
4925   *          wa_extension-valuepart2 = 'KIDNO'.
4926   **          wa_extension-valuepart3 = wa_item2-reqt_num."WA_ITEM2-REQT_NUM.
4927   *          IF gv_kidno IS NOT INITIAL.
4928   *            wa_extension-valuepart3 = gv_kidno.
4929   *          ELSE.
4930   *            wa_extension-valuepart3 = 'Utility Payment'.
4931   *          ENDIF.
4932   *          wa_extension-valuepart4 = wa_payable-itemno_acc.
4933   *          APPEND wa_extension TO it_extension.
4934   *          CLEAR wa_extension.
4935   *
4936   *          MOVE : abap_true TO gv_posted,
4937   *          wa_item2-reqt_num TO gv_reqt_num.
4938   *          CALL FUNCTION 'BAPI_ACC_DOCUMENT_CHECK'
4939   *            EXPORTING
4940   *              documentheader = wa_header
4941   **             CUSTOMERCPD    =
4942   **             CONTRACTHEADER =
4943   *            TABLES
4944   *              accountgl      = it_accountgl1
4945   *              accountpayable = it_payable
4946   *              currencyamount = it_currency1
4947   *              extension2     = it_extension
4948   *              return         = it_return.
4949   *
4950   **      IF SY-SUBRC EQ 0."- by vikas
4951   **      IF it_return IS NOT INITIAL."+ by vikas
4952   *
4953   *          LOOP AT it_return INTO wa_return.
4954   **          IF WA_RETURN-TYPE = 'E'.
4955   *
4956   *            wa_error-reqnum  = wa_item2-reqt_num.
4957   *            wa_error-er_type = wa_return-type.
4958   *            wa_error-msg_id = wa_return-id.
4959   *            wa_error-msg_num = wa_return-number.
4960   *            wa_error-msg = wa_return-message.
4961   *            APPEND wa_error TO it_error.
4962   **          ENDIF.
4963   *          ENDLOOP.
4964   *          CLEAR : wa_error.
4965   **      ELSE."+ by vikas
4966   *          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
4967   *            EXPORTING
4968   *              wait = 'X'.
4969   **      ENDIF."+ by vikas
4970   **      ENDIF."- by vikas
4971   *          EXPORT wa_header TO MEMORY ID 'SIMU_HEAD'.
4972   *          EXPORT it_accountgl1 TO MEMORY ID 'SIMU_ACC'.
4973   *          EXPORT it_payable TO MEMORY ID 'SIMU_PAY'.
4974   *          EXPORT it_currency1 TO MEMORY ID 'SIMU_CUR'.
4975   *          EXPORT it_error TO MEMORY ID 'SIMU_ERROR'.
4976   **      EXPORT WA_HEADER TO MEMORY ID 'SIMU_HEAD'.
4977   *
4978   *
4979   *          REFRESH : it_accountgl[],it_payable[],it_currency[],it_extension, it_accountgl1,it_currency1.
4980   *          REFRESH it_zbill_gl.
4981   *          CLEAR : wa_header,lv_total,lv_item,l_total_pay.
4982   *
4983   *          CALL SCREEN 0902.
4984   *
4985   *
4986   *************************************** To update HR table
4987   *
4988   **      REFRESH : IT_ACCOUNTGL[],IT_PAYABLE[],IT_CURRENCY[],IT_EXTENSION, IT_ACCOUNTGL1,IT_CURRENCY1.
4989   **      REFRESH IT_ZBILL_GL.
4990   **      CLEAR : WA_HEADER,LV_TOTAL,LV_ITEM,L_TOTAL_PAY.
4991   *
4992   *        ENDAT.
4993   *        CLEAR : wa_billhead,wa_items,wa_payable,wa_accountgl,wa_billtype,wa_header,wa_item2 .
4994   *
4995   *      ENDLOOP.
4996   *
4997   *
4998   *      l_kst01 = wa_item2-kst01.
4999   *      REFRESH : it_return[] , it_error[].
5000   *      CLEAR : wa_items,wa_return,wa_item2.
5001   *
5002   **BREAK-POINT.
5003   *      MOVE it_item3[] TO it_item2[].
5004   *      REFRESH it_item3.
5005   *
5006   *    ENDFORM.                    " SIMULATE
5007   *&---------------------------------------------------------------------*
5008   *&      Module  STATUS_0902  OUTPUT
5009   *&---------------------------------------------------------------------*
5010   *       text
5011   *----------------------------------------------------------------------*
5012       MODULE status_0902 OUTPUT.
5013         SET PF-STATUS 'STATUS_902'.
5014         SET TITLEBAR 'TB_902'.
5015
5016       ENDMODULE.                 " STATUS_0902  OUTPUT
5017   *&---------------------------------------------------------------------*
5018   *&      Module  USER_COMMAND_0902  INPUT
5019   *&---------------------------------------------------------------------*
5020   *       text
5021   *----------------------------------------------------------------------*
5022       MODULE user_command_0902 INPUT.
5023
5024         CASE okcode_902.
5025           WHEN 'BACK' OR 'EXIT'.
5026
5027             CALL METHOD gr_ccontainer->free
5028               EXCEPTIONS
5029                 cntl_error        = 1
5030                 cntl_system_error = 2
5031                 OTHERS            = 3.
5032             IF sy-subrc <> 0.
5033   * Implement suitable error handling here
5034             ENDIF.
5035
5036             CALL METHOD gr_ccontainer1->free
5037               EXCEPTIONS
5038                 cntl_error        = 1
5039                 cntl_system_error = 2
5040                 OTHERS            = 3.
5041             IF sy-subrc <> 0.
5042   * Implement suitable error handling here
5043             ENDIF.
5044
5045             CALL METHOD gr_ccontainer2->free
5046               EXCEPTIONS
5047                 cntl_error        = 1
5048                 cntl_system_error = 2
5049                 OTHERS            = 3.
5050             IF sy-subrc <> 0.
5051   * Implement suitable error handling here
5052             ENDIF.
5053
5054
5055             CALL METHOD gr_alvgrid->free
5056               EXCEPTIONS
5057                 cntl_error        = 1
5058                 cntl_system_error = 2
5059                 OTHERS            = 3.
5060             IF sy-subrc <> 0.
5061   *       Implement suitable error handling here
5062             ENDIF.
5063
5064             CALL METHOD gr_alvgrid1->free
5065               EXCEPTIONS
5066                 cntl_error        = 1
5067                 cntl_system_error = 2
5068                 OTHERS            = 3.
5069             IF sy-subrc <> 0.
5070   *       Implement suitable error handling here
5071             ENDIF.
5072
5073             CALL METHOD gr_alvgrid2->free
5074               EXCEPTIONS
5075                 cntl_error        = 1
5076                 cntl_system_error = 2
5077                 OTHERS            = 3.
5078             IF sy-subrc <> 0.
5079   *       Implement suitable error handling here
5080             ENDIF.
5081
5082
5083
5084
5085             FREE gr_ccontainer.
5086             FREE gr_ccontainer1.
5087             FREE gr_ccontainer2.
5088             FREE gr_alvgrid.
5089             FREE gr_alvgrid1.
5090             FREE gr_alvgrid2.
5091
5092             LEAVE TO SCREEN 0.
5093         ENDCASE.
5094
5095
5096
5097
5098
5099       ENDMODULE.                 " USER_COMMAND_0902  INPUT
5100   *&---------------------------------------------------------------------*
5101   *&      Module  SIMU_HEADER_DATA  OUTPUT
5102   *&---------------------------------------------------------------------*
5103   *       text
5104   *----------------------------------------------------------------------*
5105       MODULE simu_header_data OUTPUT.
5106
5107         TYPES : BEGIN OF ty_error,
5108         er_type TYPE bapi_mtype,
5109         msg_id TYPE symsgid,
5110         msg_num TYPE symsgno,
5111         msg TYPE bapi_msg,
5112         reqnum TYPE  zbill_req_nm,
5113         light TYPE c,
5114         END OF ty_error.
5115
5116         DATA : wa_header TYPE bapiache09,
5117               it_accountgl1 TYPE STANDARD TABLE OF bapiacgl09,
5118               wa_accountgl1 TYPE bapiacgl09,
5119               it_payable TYPE STANDARD TABLE OF bapiacap09,
5120               wa_payable TYPE bapiacap09,
5121               it_currency1 TYPE STANDARD TABLE OF bapiaccr09,
5122               wa_currency1 TYPE bapiaccr09,
5123               it_error TYPE TABLE OF ty_error,
5124               wa_error TYPE          ty_error,
5125               it_error1 TYPE TABLE OF ty_error,
5126               wa_error1 TYPE          ty_error.
5127
5128         TYPES : BEGIN OF ty_account.
5129                 INCLUDE STRUCTURE bapiacgl09.
5130         TYPES:  amt_doccur TYPE bapidoccur.
5131         TYPES:  prctr TYPE prctr.
5132         TYPES : END OF ty_account.
5133
5134         TYPES : BEGIN OF ty_pay.
5135                 INCLUDE STRUCTURE bapiacap09.
5136         TYPES:  amt_doccur TYPE bapidoccur.
5137         TYPES : END OF ty_pay.
5138
5139         DATA : it_account TYPE TABLE OF ty_account,
5140                wa_account TYPE ty_account,
5141               it_pay TYPE TABLE OF ty_pay,
5142               wa_pay TYPE ty_pay.
5143
5144         DATA : simu_error TYPE string.
5145
5146         DATA : it_accountgl TYPE STANDARD TABLE OF bapiacgl09,
5147                it_currency TYPE STANDARD TABLE OF bapiaccr09.
5148
5149
5150         CLEAR : wa_header , it_accountgl1 , it_payable, it_currency1 , it_error , it_account , it_payable , it_pay.
5151
5152         IMPORT wa_header FROM MEMORY ID 'SIMU_HEAD'.
5153         IMPORT it_accountgl FROM MEMORY ID 'SIMU_ACC'.
5154         IMPORT it_payable FROM MEMORY ID 'SIMU_PAY'.
5155         IMPORT it_currency FROM MEMORY ID 'SIMU_CUR'.
5156         IMPORT it_error FROM MEMORY ID 'SIMU_ERROR'.
5157
5158         it_accountgl1[] = it_accountgl[].
5159         it_currency1[]  = it_currency[].
5160
5161         FREE MEMORY ID  'SIMU_HEAD'.
5162         FREE MEMORY ID  'SIMU_ACC'.
5163         FREE MEMORY ID  'SIMU_PAY'.
5164         FREE MEMORY ID  'SIMU_CUR'.
5165         FREE MEMORY ID  'SIMU_ERROR'.
5166
5167
5168         simu_ccode = wa_header-comp_code.
5169         simu_date = wa_header-doc_date.
5170         simu_ref_num = wa_header-ref_doc_no.
5171         simu_pdate = wa_header-pstng_date.
5172         simu_fyear = '2013'.
5173         simu_cur = 'INR'.
5174
5175
5176         LOOP AT it_accountgl1 INTO wa_accountgl1.
5177           CLEAR wa_currency1.
5178           READ TABLE it_currency1 INTO wa_currency1 WITH KEY itemno_acc = wa_accountgl1-itemno_acc.
5179           IF sy-subrc = 0.
5180   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
5181   *          wa_account-amt_doccur = wa_currency1-amt_doccur.
5182             wa_account-amt_doccur = CONV #( wa_currency1-amt_doccur ).
5183   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
5184           ENDIF.
5185           MOVE-CORRESPONDING wa_accountgl1 TO wa_account.
5186
5187           CLEAR wa_csks.
5188           READ TABLE gt_csks INTO wa_csks WITH KEY kostl = wa_accountgl1-costcenter.
5189           IF sy-subrc = 0.
5190             wa_account-prctr = wa_csks-prctr.
5191           ELSE.
5192             wa_account-prctr = wa_account-profit_ctr.
5193           ENDIF.
5194
5195           APPEND wa_account TO it_account.
5196           CLEAR : wa_accountgl1,wa_account.
5197         ENDLOOP.
5198         CLEAR : wa_account , wa_accountgl1, wa_csks.
5199
5200         LOOP AT it_payable INTO wa_payable.
5201           CLEAR wa_currency1.
5202           READ TABLE it_currency1 INTO wa_currency1 WITH KEY itemno_acc = wa_payable-itemno_acc.
5203           IF sy-subrc = 0.
5204   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
5205   *          wa_pay-amt_doccur = wa_currency1-amt_doccur.
5206             wa_pay-amt_doccur = CONV #( wa_currency1-amt_doccur ).
5207   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
5208           ENDIF.
5209           MOVE-CORRESPONDING wa_payable TO wa_pay.
5210           APPEND wa_pay TO it_pay.
5211           CLEAR : wa_payable,wa_pay.
5212         ENDLOOP.
5213
5214         CLEAR : it_error1.
5215
5216         LOOP AT  it_error INTO wa_error.
5217
5218           MOVE-CORRESPONDING wa_error TO wa_error1.
5219
5220           IF wa_error1-er_type = 'S'.
5221             wa_error1-light = '3'.
5222           ELSEIF wa_error1-er_type = 'W'.
5223             wa_error1-light = '2'.
5224           ELSEIF wa_error1-er_type = 'E'.
5225             wa_error1-light = '1'.
5226           ENDIF.
5227
5228           APPEND wa_error1 TO it_error1.
5229           CLEAR : wa_error , wa_error1.
5230   *        CONCATENATE WA_ERROR-MSG SIMU_ERROR INTO SIMU_ERROR SEPARATED BY '.'.
5231   *        CLEAR WA_ERROR.
5232         ENDLOOP.
5233
5234         simu_error = simu_error.
5235
5236         CLEAR : wa_pay , wa_payable.
5237
5238
5239         PERFORM acc_alv.
5240         PERFORM pay_alv.
5241         PERFORM bapi_msg.
5242
5243
5244       ENDMODULE.                 " SIMU_HEADER_DATA  OUTPUT
5245   *&---------------------------------------------------------------------*
5246   *&      Form  ACC_ALV
5247   *&---------------------------------------------------------------------*
5248   *       text
5249   *----------------------------------------------------------------------*
5250   *  -->  p1        text
5251   *  <--  p2        text
5252   *----------------------------------------------------------------------*
5253       FORM acc_alv .
5254         DATA : ls_layo TYPE lvc_s_layo.
5255
5256         IF gr_alvgrid IS INITIAL .
5257
5258
5259           CREATE OBJECT gr_ccontainer
5260             EXPORTING
5261               container_name              = gc_custom_control_name
5262             EXCEPTIONS
5263               cntl_error                  = 1
5264               cntl_system_error           = 2
5265               create_error                = 3
5266               lifetime_error              = 4
5267               lifetime_dynpro_dynpro_link = 5
5268               OTHERS                      = 6.
5269           IF sy-subrc <> 0.
5270
5271           ENDIF.
5272
5273           CREATE OBJECT gr_alvgrid
5274             EXPORTING
5275               i_parent          = gr_ccontainer
5276             EXCEPTIONS
5277               error_cntl_create = 1
5278               error_cntl_init   = 2
5279               error_cntl_link   = 3
5280               error_dp_create   = 4
5281               OTHERS            = 5.
5282           IF sy-subrc <> 0.
5283   *--Exception handling
5284           ENDIF.
5285
5286           REFRESH gt_fieldcat.
5287           PERFORM build_simu_fieldcat.
5288
5289   *       Optimize column width
5290           CLEAR ls_layo.
5291           ls_layo-cwidth_opt = abap_true.
5292           ls_layo-col_opt    = abap_true.
5293
5294           CALL METHOD gr_alvgrid->set_table_for_first_display
5295             EXPORTING
5296   *           I_BUFFER_ACTIVE               =
5297   *           I_BYPASSING_BUFFER            =
5298   *           I_CONSISTENCY_CHECK           =
5299   *           I_STRUCTURE_NAME              =
5300   *           IS_VARIANT                    =
5301               i_save                        = 'X'
5302               i_default                     = 'X'
5303               is_layout                     = ls_layo
5304   *           IS_PRINT                      =
5305   *           IT_SPECIAL_GROUPS             =
5306   *           IT_TOOLBAR_EXCLUDING          =
5307   *           IT_HYPERLINK                  =
5308   *           IT_ALV_GRAPHICS               =
5309   *           IT_EXCEPT_QINFO               =
5310   *           IR_SALV_ADAPTER               =
5311             CHANGING
5312               it_outtab                     = it_account[]
5313               it_fieldcatalog               = gt_fieldcat[]
5314   *           IT_SORT                       =
5315   *           IT_FILTER                     =
5316             EXCEPTIONS
5317               invalid_parameter_combination = 1
5318               program_error                 = 2
5319               too_many_lines                = 3
5320               OTHERS                        = 4.
5321           IF sy-subrc <> 0.
5322   *     Implement suitable error handling here
5323           ENDIF.
5324
5325         ENDIF.
5326
5327       ENDFORM.                    " ACC_ALV
5328   *&---------------------------------------------------------------------*
5329   *&      Form  BUILD_SIMU_FIELDCAT
5330   *&---------------------------------------------------------------------*
5331   *       text
5332   *----------------------------------------------------------------------*
5333   *  -->  p1        text
5334   *  <--  p2        text
5335   *----------------------------------------------------------------------*
5336       FORM build_simu_fieldcat .
5337         FIELD-SYMBOLS : <ls_fcat> TYPE lvc_s_fcat.
5338
5339         DEFINE macro_fieldcat.
5340           add &6 to gt_fieldcat-col_pos.
5341           move:
5342           &1 to gt_fieldcat-fieldname,
5343           &2 to gt_fieldcat-scrtext_l,
5344           &3 to gt_fieldcat-no_out,
5345           &4 to gt_fieldcat-outputlen,
5346           &5 to gt_fieldcat-key,
5347           'IT_ACCOUNTGL1' to gt_fieldcat-tabname.
5348
5349           append gt_fieldcat.
5350           clear gt_fieldcat.
5351         END-OF-DEFINITION.
5352
5353
5354         macro_fieldcat 'ITEMNO_ACC' 'Item' '' '' '' ''.
5355         macro_fieldcat 'COMP_CODE' 'Company Code' '' '' '' ''.
5356         macro_fieldcat 'GL_ACCOUNT' 'GL Account' '' '' '' ''.
5357         macro_fieldcat 'ITEM_TEXT' 'Bill Type' '' '' '' ''.
5358         macro_fieldcat 'ACCT_TYPE' 'Account type' '' '' '' ''.
5359         macro_fieldcat 'DOC_TYPE' 'Doc Type' '' '' '' ''.
5360         macro_fieldcat 'COSTCENTER' 'Cost Center' '' '' '' ''.
5361         macro_fieldcat 'PRCTR' 'Profit Center' '' '' '' ''.
5362         macro_fieldcat 'AMT_DOCCUR' 'Amount' '' '' '' ''.
5363         UNASSIGN <ls_fcat>.
5364         READ TABLE gt_fieldcat ASSIGNING <ls_fcat> WITH KEY fieldname = 'AMT_DOCCUR'.
5365         IF <ls_fcat> IS ASSIGNED.
5366           <ls_fcat>-decimals_o = '2'.
5367         ENDIF.
5368         macro_fieldcat 'RES_DOC' 'Earmarked Funds' '' '' '' ''.
5369         macro_fieldcat 'RES_ITEM' 'Line Item' '' '' '' ''.
5370         macro_fieldcat 'WBS_ELEMENT' 'WBS Element' '' '' '' ''.
5371         macro_fieldcat 'ORDERID' 'Order' '' '' '' ''.
5372
5373       ENDFORM.                    " BUILD_SIMU_FIELDCAT
5374   *&---------------------------------------------------------------------*
5375   *&      Form  PAY_ALV
5376   *&---------------------------------------------------------------------*
5377   *       text
5378   *----------------------------------------------------------------------*
5379   *  -->  p1        text
5380   *  <--  p2        text
5381   *----------------------------------------------------------------------*
5382       FORM pay_alv .
5383         DATA : ls_layo TYPE lvc_s_layo.
5384
5385         IF gr_alvgrid1 IS INITIAL .
5386
5387           CREATE OBJECT gr_ccontainer1
5388             EXPORTING
5389               container_name              = gc_custom_control_name1
5390             EXCEPTIONS
5391               cntl_error                  = 1
5392               cntl_system_error           = 2
5393               create_error                = 3
5394               lifetime_error              = 4
5395               lifetime_dynpro_dynpro_link = 5
5396               OTHERS                      = 6.
5397           IF sy-subrc <> 0.
5398
5399           ENDIF.
5400
5401           CREATE OBJECT gr_alvgrid1
5402             EXPORTING
5403               i_parent          = gr_ccontainer1
5404             EXCEPTIONS
5405               error_cntl_create = 1
5406               error_cntl_init   = 2
5407               error_cntl_link   = 3
5408               error_dp_create   = 4
5409               OTHERS            = 5.
5410           IF sy-subrc <> 0.
5411   *--Exception handling
5412           ENDIF.
5413
5414           REFRESH gt_fieldcat1.
5415           PERFORM build_simu_pay_fieldcat.
5416
5417   *       Optimize column width
5418           CLEAR ls_layo.
5419           ls_layo-cwidth_opt = abap_true.
5420           ls_layo-col_opt    = abap_true.
5421
5422           CALL METHOD gr_alvgrid1->set_table_for_first_display
5423             EXPORTING
5424   *           I_BUFFER_ACTIVE               =
5425   *           I_BYPASSING_BUFFER            =
5426   *           I_CONSISTENCY_CHECK           =
5427   *           I_STRUCTURE_NAME              =
5428   *           IS_VARIANT                    =
5429               i_save                        = 'X'
5430               i_default                     = 'X'
5431               is_layout                     = ls_layo
5432   *           IS_PRINT                      =
5433   *           IT_SPECIAL_GROUPS             =
5434   *           IT_TOOLBAR_EXCLUDING          =
5435   *           IT_HYPERLINK                  =
5436   *           IT_ALV_GRAPHICS               =
5437   *           IT_EXCEPT_QINFO               =
5438   *           IR_SALV_ADAPTER               =
5439             CHANGING
5440               it_outtab                     = it_pay[]
5441               it_fieldcatalog               = gt_fieldcat1[]
5442   *           IT_SORT                       =
5443   *           IT_FILTER                     =
5444             EXCEPTIONS
5445               invalid_parameter_combination = 1
5446               program_error                 = 2
5447               too_many_lines                = 3
5448               OTHERS                        = 4.
5449           IF sy-subrc <> 0.
5450   *     Implement suitable error handling here
5451           ENDIF.
5452
5453
5454
5455         ENDIF.
5456
5457
5458
5459       ENDFORM.                    " PAY_ALV
5460   *&---------------------------------------------------------------------*
5461   *&      Form  BUILD_SIMU_PAY_FIELDCAT
5462   *&---------------------------------------------------------------------*
5463   *       text
5464   *----------------------------------------------------------------------*
5465   *  -->  p1        text
5466   *  <--  p2        text
5467   *----------------------------------------------------------------------*
5468       FORM build_simu_pay_fieldcat .
5469         FIELD-SYMBOLS : <ls_fcat> TYPE lvc_s_fcat.
5470
5471         DEFINE macro_fieldcat1.
5472           add &6 to gt_fieldcat1-col_pos.
5473           move:
5474           &1 to gt_fieldcat1-fieldname,
5475           &2 to gt_fieldcat1-scrtext_l,
5476           &3 to gt_fieldcat1-no_out,
5477           &4 to gt_fieldcat1-outputlen,
5478           &5 to gt_fieldcat1-key,
5479           'IT_PAYABLE' to gt_fieldcat1-tabname.
5480
5481           append gt_fieldcat1.
5482           clear gt_fieldcat1.
5483         END-OF-DEFINITION.
5484
5485
5486         macro_fieldcat1 'ITEMNO_ACC' 'Item' '' '' '' ''.
5487         macro_fieldcat1 'COMP_CODE' 'Company Code' '' '' '' ''.
5488         macro_fieldcat1 'VENDOR_NO' 'Vendor No.' '' '' '' ''.
5489         macro_fieldcat1 'PMNTTRMS' 'Payment Term' '' '' '' ''.
5490         macro_fieldcat1 'BLINE_DATE' 'Base line date' '' '' '' ''.
5491         macro_fieldcat1 'PYMT_METH' 'Payment Method' '' '' '' ''.
5492         macro_fieldcat1 'SECTIONCODE' 'Section Code' '' '' '' ''.
5493         macro_fieldcat1 'ITEM_TEXT' 'Item Text' '' '' '' ''.
5494         macro_fieldcat1 'AMT_DOCCUR' 'Amount' '' '' '' ''.
5495
5496         UNASSIGN <ls_fcat>.
5497         READ TABLE gt_fieldcat1 ASSIGNING <ls_fcat> WITH KEY fieldname = 'AMT_DOCCUR'.
5498         IF <ls_fcat> IS ASSIGNED.
5499           <ls_fcat>-decimals_o = '2'.
5500         ENDIF.
5501
5502       ENDFORM.                    " BUILD_SIMU_PAY_FIELDCAT
5503   *&---------------------------------------------------------------------*
5504   *&      Form  UPDATE_STATUS
5505   *&---------------------------------------------------------------------*
5506   *       text
5507   *----------------------------------------------------------------------*
5508   *  -->  p1        text
5509   *  <--  p2        text
5510   *----------------------------------------------------------------------*
5511       FORM update_status USING taskname .
5512   *  DATA  : L_RETURN1 TYPE TABLE OF ZBILL_RETURN_TT.
5513
5514         RECEIVE RESULTS FROM FUNCTION 'ZBILL_PP_OF_RECORD' KEEPING TASK
5515         TABLES
5516           t_return1 = l_return1.
5517         lv_comp = lv_comp + 1.
5518
5519
5520       ENDFORM.                    " UPDATE_STATUS
5521
5522   *&---------------------------------------------------------------------*
5523   *&      Form  UPDATE_STATUS1
5524   *&---------------------------------------------------------------------*
5525   *       text
5526   *----------------------------------------------------------------------*
5527   *      -->TASKNAME   text
5528   *----------------------------------------------------------------------*
5529       FORM update_status1 USING taskname .
5530   *  DATA  : L_RETURN2 TYPE TABLE OF ZBILL_RETURN_TT .
5531         RECEIVE RESULTS FROM FUNCTION 'ZBILL_PP_OF_RECORD' KEEPING TASK
5532         TABLES
5533           t_return1 = l_return2.
5534         lv_comp = lv_comp + 1.
5535
5536
5537       ENDFORM.                    "UPDATE_STATUS1
5538
5539   *&---------------------------------------------------------------------*
5540   *&      Form  UPDATE_STATUS2
5541   *&---------------------------------------------------------------------*
5542   *       text
5543   *----------------------------------------------------------------------*
5544   *      -->TASKNAME   text
5545   *----------------------------------------------------------------------*
5546       FORM update_status2 USING taskname .
5547   *  DATA  : L_RETURN3 TYPE TABLE OF ZBILL_RETURN_TT .
5548         RECEIVE RESULTS FROM FUNCTION 'ZBILL_PP_OF_RECORD' KEEPING TASK
5549         TABLES
5550           t_return1 = l_return3.
5551         lv_comp = lv_comp + 1.
5552
5553       ENDFORM.                    "UPDATE_STATUS2
5554
5555   *&---------------------------------------------------------------------*
5556   *&      Form  UPDATE_STATUS3
5557   *&---------------------------------------------------------------------*
5558   *       text
5559   *----------------------------------------------------------------------*
5560   *      -->TASKNAME   text
5561   *----------------------------------------------------------------------*
5562       FORM update_status3 USING taskname .
5563   *  DATA  : L_RETURN4 TYPE TABLE OF ZBILL_RETURN_TT .
5564         RECEIVE RESULTS FROM FUNCTION 'ZBILL_PP_OF_RECORD' KEEPING TASK
5565         TABLES
5566           t_return1 = l_return4.
5567
5568         lv_comp = lv_comp + 1.
5569
5570       ENDFORM.                    "UPDATE_STATUS3
5571   *&---------------------------------------------------------------------*
5572   *&      Form  UPDATE_STATUS4
5573   *&---------------------------------------------------------------------*
5574   *       text
5575   *----------------------------------------------------------------------*
5576   *      -->P_T_PA9105  text
5577   *      -->P_=  text
5578   *      -->P_IT_PA9105_5  text
5579   *----------------------------------------------------------------------*
5580       FORM update_status4 USING taskname .
5581   *  DATA  : L_RETURN4 TYPE TABLE OF ZBILL_RETURN_TT .
5582         RECEIVE RESULTS FROM FUNCTION 'ZBILL_PP_OF_RECORD' KEEPING TASK
5583         TABLES
5584           t_return1 = l_return5.
5585
5586         lv_comp = lv_comp + 1.
5587
5588       ENDFORM.                    "UPDATE_STATUS4
5589   *&---------------------------------------------------------------------*
5590   *&      Form  BAPI_MSG
5591   *&---------------------------------------------------------------------*
5592   *       text
5593   *----------------------------------------------------------------------*
5594   *  -->  p1        text
5595   *  <--  p2        text
5596   *----------------------------------------------------------------------*
5597       FORM bapi_msg .
5598         IF gr_alvgrid2 IS INITIAL .
5599
5600           CREATE OBJECT gr_ccontainer2
5601             EXPORTING
5602               container_name              = gc_custom_control_name2
5603             EXCEPTIONS
5604               cntl_error                  = 1
5605               cntl_system_error           = 2
5606               create_error                = 3
5607               lifetime_error              = 4
5608               lifetime_dynpro_dynpro_link = 5
5609               OTHERS                      = 6.
5610           IF sy-subrc <> 0.
5611
5612           ENDIF.
5613
5614           CREATE OBJECT gr_alvgrid2
5615             EXPORTING
5616               i_parent          = gr_ccontainer2
5617             EXCEPTIONS
5618               error_cntl_create = 1
5619               error_cntl_init   = 2
5620               error_cntl_link   = 3
5621               error_dp_create   = 4
5622               OTHERS            = 5.
5623           IF sy-subrc <> 0.
5624   *--Exception handling
5625           ENDIF.
5626
5627           REFRESH gt_fieldcat2.
5628           PERFORM build_msg_fieldcat.
5629
5630           gs_lay_out-excp_fname = 'LIGHT'.
5631           gs_lay_out-cwidth_opt = abap_true.
5632           gs_lay_out-col_opt    = abap_true.
5633
5634           CALL METHOD gr_alvgrid2->set_table_for_first_display
5635             EXPORTING
5636   *           I_BUFFER_ACTIVE               =
5637   *           I_BYPASSING_BUFFER            =
5638   *           I_CONSISTENCY_CHECK           =
5639   *           I_STRUCTURE_NAME              =
5640   *           IS_VARIANT                    =
5641   *           I_SAVE                        =
5642               i_default                     = 'X'
5643               is_layout                     = gs_lay_out
5644   *           IS_PRINT                      =
5645   *           IT_SPECIAL_GROUPS             =
5646   *           IT_TOOLBAR_EXCLUDING          =
5647   *           IT_HYPERLINK                  =
5648   *           IT_ALV_GRAPHICS               =
5649   *           IT_EXCEPT_QINFO               =
5650   *           IR_SALV_ADAPTER               =
5651             CHANGING
5652               it_outtab                     = it_error1[]
5653               it_fieldcatalog               = gt_fieldcat2[]
5654   *           IT_SORT                       =
5655   *           IT_FILTER                     =
5656             EXCEPTIONS
5657               invalid_parameter_combination = 1
5658               program_error                 = 2
5659               too_many_lines                = 3
5660               OTHERS                        = 4.
5661           IF sy-subrc <> 0.
5662   *         Implement suitable error handling here
5663           ENDIF.
5664
5665
5666
5667
5668         ENDIF.
5669
5670
5671       ENDFORM.                    " BAPI_MSG
5672   *&---------------------------------------------------------------------*
5673   *&      Form  BUILD_MSG_FIELDCAT
5674   *&---------------------------------------------------------------------*
5675   *       text
5676   *----------------------------------------------------------------------*
5677   *  -->  p1        text
5678   *  <--  p2        text
5679   *----------------------------------------------------------------------*
5680       FORM build_msg_fieldcat .
5681
5682         DEFINE macro_fieldcat2.
5683           add &6 to gt_fieldcat2-col_pos.
5684           move:
5685           &1 to gt_fieldcat2-fieldname,
5686           &2 to gt_fieldcat2-scrtext_l,
5687           &3 to gt_fieldcat2-no_out,
5688           &4 to gt_fieldcat2-outputlen,
5689           &5 to gt_fieldcat2-key,
5690           'IT_ERROR1' to gt_fieldcat2-tabname.
5691
5692           append gt_fieldcat2.
5693           clear gt_fieldcat2.
5694         END-OF-DEFINITION.
5695
5696
5697         macro_fieldcat2 'LIGHT' 'Signal' '' '' '' ''.
5698         macro_fieldcat2 'ER_TYPE' 'Type' '' '' '' ''.
5699         macro_fieldcat2 'MSG' 'Message' '' '' '' ''.
5700   *      MACRO_FIELDCAT2 'PMNTTRMS' 'Payment Term' '' '' '' ''.
5701
5702
5703       ENDFORM.                    " BUILD_MSG_FIELDCAT
5704   *&---------------------------------------------------------------------*
5705   *&      Form  DEQUEUE_DATA
5706   *&---------------------------------------------------------------------*
5707   *       text
5708   *----------------------------------------------------------------------*
5709   *  -->  p1        text
5710   *  <--  p2        text
5711   *----------------------------------------------------------------------*
5712       FORM dequeue_data .
5713
5714         CHECK sy-tcode <> 'ZFIBD_REPORT'.
5715
5716         LOOP AT it_item2 INTO wa_item2.
5717           CALL FUNCTION 'DEQUEUE_EZBILL_DATA'
5718             EXPORTING
5719               mode_zbill_data = 'E'
5720               mandt           = sy-mandt
5721               reqt_num        = wa_item2-reqt_num
5722               reqt_id         = wa_item2-reqt_id.
5723         ENDLOOP.
5724
5725
5726       ENDFORM.                    " DEQUEUE_DATA
5727   *&---------------------------------------------------------------------*
5728   *&      Form  F_GET_COST_CENTER
5729   *&---------------------------------------------------------------------*
5730   *       text
5731   *----------------------------------------------------------------------*
5732   *      -->P_WA_ITEMS  text
5733   *----------------------------------------------------------------------*
5734       FORM f_get_cost_center  CHANGING  fp_s_items TYPE ty_items.
5735
5736         FIELD-SYMBOLS : <lv_costctr> TYPE kostl,
5737                         <lv_wbs>     TYPE ps_psp_pnr,
5738                         <lv_aufnr>   TYPE aufnr,
5739                         <lv_busar>   TYPE gsber.
5740
5741         DATA : lv_field TYPE char20,
5742                lv_idx   TYPE num02.
5743
5744   * Get Cost center from infotype 27
5745         LOOP AT gt_pa0027 INTO gs_pa0027 WHERE pernr = fp_s_items-pernr
5746                                          AND   endda GE fp_s_items-bill_from
5747                                          AND   begda LE fp_s_items-bill_from.
5748           DO.
5749             CLEAR : lv_idx,lv_field.
5750             lv_idx = sy-index.
5751   *         Cost Center
5752             CONCATENATE 'KST' lv_idx INTO lv_field.
5753             UNASSIGN <lv_costctr>.
5754             ASSIGN COMPONENT lv_field OF STRUCTURE gs_pa0027 TO <lv_costctr>.
5755             IF <lv_costctr> IS ASSIGNED AND fp_s_items-kst01 IS INITIAL.
5756               fp_s_items-kst01 = <lv_costctr>.
5757               IF fp_s_items-kst01 IS INITIAL.
5758                 CLEAR : lv_field.
5759   *             WBS Element
5760                 CONCATENATE 'PSP' lv_idx INTO lv_field.
5761                 UNASSIGN <lv_wbs>.
5762                 ASSIGN COMPONENT lv_field OF STRUCTURE gs_pa0027 TO <lv_wbs>.
5763                 IF <lv_wbs> IS ASSIGNED.
5764                   CALL FUNCTION 'CONVERSION_EXIT_ABPSP_OUTPUT'
5765                     EXPORTING
5766                       input  = <lv_wbs>
5767                     IMPORTING
5768                       output = fp_s_items-kst01.
5769   *                fp_s_items-kst01 = <lv_wbs>.
5770                   IF fp_s_items-kst01 IS INITIAL.
5771                     CLEAR : lv_field.
5772   *                 Internal Order
5773                     CONCATENATE 'AUF' lv_idx INTO lv_field.
5774                     UNASSIGN <lv_aufnr>.
5775                     ASSIGN COMPONENT lv_field OF STRUCTURE gs_pa0027 TO <lv_aufnr>.
5776                     IF <lv_aufnr> IS ASSIGNED.
5777                       fp_s_items-kst01 = <lv_aufnr>.
5778                     ENDIF.
5779                   ENDIF.
5780                 ENDIF.
5781               ENDIF.
5782   *           Fetch business area
5783               CLEAR : lv_field.
5784               CONCATENATE 'KGB' lv_idx INTO lv_field.
5785               UNASSIGN <lv_busar>.
5786               ASSIGN COMPONENT lv_field OF STRUCTURE gs_pa0027 TO <lv_busar>.
5787               IF <lv_busar> IS ASSIGNED.
5788                 fp_s_items-buar = <lv_busar>.
5789               ENDIF.
5790
5791             ELSE.
5792               EXIT.
5793             ENDIF.
5794           ENDDO.
5795
5796           EXIT.
5797         ENDLOOP.
5798
5799
5800       ENDFORM.                    " F_GET_COST_CENTER
5801
5802
5803
5804
5805   *&---------------------------------------------------------------------*
5806   *&      Form  F_COST_DISTRIBUTION
5807   *&---------------------------------------------------------------------*
5808   *       text
5809   *----------------------------------------------------------------------*
5810   *      -->P_GS_PA0027  text
5811   *      <--P_GS_GL  text
5812   *----------------------------------------------------------------------*
5813       FORM f_cost_distribution  USING    fp_s_pa0027 TYPE pa0027
5814                                          fp_v_amt    TYPE any
5815                                 CHANGING fp_s_gl     TYPE ty_gl.
5816
5817         FIELD-SYMBOLS : <lv_costctr> TYPE kostl,
5818                         <lv_wbs>     TYPE ps_psp_pnr,
5819                         <lv_aufnr>   TYPE aufnr,
5820                         <lv_bukrs>   TYPE bukrs,
5821                         <lv_perc>    TYPE pkprz.
5822
5823         DATA : lv_field TYPE char20,
5824                lv_idx   TYPE num02.
5825
5826   ******** Cost center ******************************
5827
5828         DO.
5829           CLEAR : fp_s_gl-kostl,fp_s_gl-aufnr,
5830                   fp_s_gl-wbs,fp_s_gl-bukrs,
5831                   fp_s_gl-amount.
5832           CLEAR : lv_idx,lv_field.
5833           lv_idx = sy-index.
5834   *   Get Cost center
5835           CONCATENATE 'KST' lv_idx INTO lv_field.
5836           UNASSIGN <lv_costctr>.
5837           ASSIGN COMPONENT lv_field OF STRUCTURE fp_s_pa0027 TO <lv_costctr>.
5838           IF <lv_costctr> IS ASSIGNED.  " AND <lv_costctr> IS NOT INITIAL.
5839             fp_s_gl-kostl = <lv_costctr>.
5840
5841   *           Check for alternative G/L.
5842             CLEAR : wa_vlaues.
5843             READ TABLE int_vlaues INTO wa_vlaues WITH KEY from = fp_s_gl-kostl.
5844             IF sy-subrc = 0 AND wa_bill_gl-alt_hkont IS NOT INITIAL.
5845               fp_s_gl-hkont = wa_bill_gl-alt_hkont.
5846             ENDIF.
5847
5848   *          Get Company code
5849             CLEAR : lv_field.
5850             CONCATENATE 'KBU' lv_idx INTO lv_field.
5851             UNASSIGN <lv_bukrs>.
5852             ASSIGN COMPONENT lv_field OF STRUCTURE fp_s_pa0027 TO <lv_bukrs>.
5853             IF <lv_bukrs> IS ASSIGNED.
5854               fp_s_gl-bukrs = <lv_bukrs>.
5855             ENDIF.
5856
5857             CLEAR : lv_field.
5858   *     Get Percentage
5859             CONCATENATE 'KPR' lv_idx INTO lv_field.
5860             UNASSIGN <lv_perc>.
5861             ASSIGN COMPONENT lv_field OF STRUCTURE fp_s_pa0027 TO <lv_perc>.
5862             IF <lv_perc> IS ASSIGNED AND <lv_costctr> IS NOT INITIAL.
5863               fp_s_gl-amount = ( fp_v_amt * <lv_perc> ) / 100.
5864   *            COLLECT fp_s_gl INTO gt_gl.
5865               APPEND fp_s_gl TO gt_glamt.
5866             ENDIF.
5867           ELSE.
5868             EXIT.
5869           ENDIF.
5870
5871         ENDDO.
5872
5873   ******** Internal Order ******************************
5874
5875         DO.
5876           CLEAR : fp_s_gl-kostl,fp_s_gl-aufnr,
5877                   fp_s_gl-wbs,fp_s_gl-bukrs,
5878                   fp_s_gl-amount.
5879           CLEAR : lv_idx,lv_field.
5880           lv_idx = sy-index.
5881   *   Get Internal Order
5882           CONCATENATE 'AUF' lv_idx INTO lv_field.
5883           UNASSIGN <lv_aufnr>.
5884           ASSIGN COMPONENT lv_field OF STRUCTURE fp_s_pa0027 TO <lv_aufnr>.
5885           IF <lv_aufnr> IS ASSIGNED.  " AND <lv_costctr> IS NOT INITIAL.
5886             fp_s_gl-aufnr = <lv_aufnr>.
5887
5888   *          Get Company code
5889             CLEAR : lv_field.
5890             CONCATENATE 'KBU' lv_idx INTO lv_field.
5891             UNASSIGN <lv_bukrs>.
5892             ASSIGN COMPONENT lv_field OF STRUCTURE fp_s_pa0027 TO <lv_bukrs>.
5893             IF <lv_bukrs> IS ASSIGNED.
5894               fp_s_gl-bukrs = <lv_bukrs>.
5895             ENDIF.
5896
5897             CLEAR : lv_field.
5898   *     Get Percentage
5899             CONCATENATE 'KPR' lv_idx INTO lv_field.
5900             UNASSIGN <lv_perc>.
5901             ASSIGN COMPONENT lv_field OF STRUCTURE fp_s_pa0027 TO <lv_perc>.
5902             IF <lv_perc> IS ASSIGNED AND <lv_aufnr> IS NOT INITIAL.
5903               fp_s_gl-amount = ( fp_v_amt * <lv_perc> ) / 100.
5904   *            COLLECT fp_s_gl INTO gt_gl.
5905               APPEND fp_s_gl TO gt_glamt.
5906             ENDIF.
5907           ELSE.
5908             EXIT.
5909           ENDIF.
5910
5911         ENDDO.
5912
5913   ******** WBS Element ******************************
5914
5915         DO.
5916           CLEAR : fp_s_gl-kostl,fp_s_gl-aufnr,
5917                   fp_s_gl-wbs,fp_s_gl-bukrs,
5918                   fp_s_gl-amount.
5919           CLEAR : lv_idx,lv_field.
5920           lv_idx = sy-index.
5921   *   Get WBS Element
5922           CONCATENATE 'PSP' lv_idx INTO lv_field.
5923           UNASSIGN <lv_wbs>.
5924           ASSIGN COMPONENT lv_field OF STRUCTURE fp_s_pa0027 TO <lv_wbs>.
5925           IF <lv_wbs> IS ASSIGNED.
5926             fp_s_gl-wbs = <lv_wbs>.
5927
5928   *       Get Company code
5929             CLEAR : lv_field.
5930             CONCATENATE 'KBU' lv_idx INTO lv_field.
5931             UNASSIGN <lv_bukrs>.
5932             ASSIGN COMPONENT lv_field OF STRUCTURE fp_s_pa0027 TO <lv_bukrs>.
5933             IF <lv_bukrs> IS ASSIGNED.
5934               fp_s_gl-bukrs = <lv_bukrs>.
5935             ENDIF.
5936
5937             CLEAR : lv_field.
5938   *     Get Percentage
5939             CONCATENATE 'KPR' lv_idx INTO lv_field.
5940             UNASSIGN <lv_perc>.
5941             ASSIGN COMPONENT lv_field OF STRUCTURE fp_s_pa0027 TO <lv_perc>.
5942             IF <lv_perc> IS ASSIGNED AND <lv_wbs> IS NOT INITIAL.
5943               fp_s_gl-amount = ( fp_v_amt * <lv_perc> ) / 100.
5944   *            COLLECT fp_s_gl INTO gt_gl.
5945               APPEND fp_s_gl TO gt_glamt.
5946             ENDIF.
5947           ELSE.
5948             EXIT.
5949           ENDIF.
5950
5951         ENDDO.
5952
5953
5954       ENDFORM.                    " F_COST_DISTRIBUTION
5955
5956   *&---------------------------------------------------------------------*
5957   *&      Form  F_RELEASE_TO_ACCOUNTING
5958   *&---------------------------------------------------------------------*
5959   *       text
5960   *----------------------------------------------------------------------*
5961   *      -->P_LV_MODE  text
5962   *----------------------------------------------------------------------*
5963       FORM f_release_to_accounting  USING    fp_v_mode TYPE abap_bool.
5964
5965
5966         TYPES : BEGIN OF ty_billtype,
5967                   key         TYPE char10,
5968                   text        TYPE c LENGTH 60,
5969                 END OF ty_billtype.
5970
5971         TYPES : BEGIN OF ty_error,
5972                   er_type     TYPE bapi_mtype,
5973                   msg_id      TYPE symsgid,
5974                   msg_num     TYPE symsgno,
5975                   msg         TYPE bapi_msg,
5976                   reqnum      TYPE  zbill_req_nm,
5977                 END OF ty_error.
5978
5979         DATA :it_error        TYPE TABLE OF ty_error,
5980               wa_error        TYPE          ty_error.
5981
5982         TYPES : BEGIN OF ty_error1,
5983                   er_type     TYPE bapi_mtype,
5984                   msg_id      TYPE symsgid,
5985                   msg_num     TYPE symsgno,
5986                   msg         TYPE bapi_msg,
5987                   reqnum      TYPE  zbill_req_nm,
5988                   pernr       TYPE pernr_d,
5989                 END OF ty_error1.
5990
5991
5992         DATA : lt_wbs_prc TYPE STANDARD TABLE OF ty_wbs_prc,
5993                ls_wbs_prc TYPE ty_wbs_prc,
5994                lt_ord_prc TYPE STANDARD TABLE OF ty_ord_prc,
5995                ls_ord_prc TYPE ty_ord_prc,
5996                lt_csks    TYPE STANDARD TABLE OF csks,
5997                ls_csks    TYPE csks.
5998
5999         DATA:  lt_svalue  TYPE STANDARD TABLE OF rgsbv,
6000                ls_svalue  TYPE rgsbv.
6001
6002         DATA :it_error1       TYPE TABLE OF ty_error1,
6003               wa_error1       TYPE          ty_error1.
6004
6005         DATA :wa_header       TYPE bapiache09,
6006               wa_accountgl    TYPE bapiacgl09,
6007               wa_accountgl2   TYPE bapiacgl09,
6008               wa_payable      TYPE bapiacap09,
6009               it_accountgl    TYPE STANDARD TABLE OF bapiacgl09,
6010               it_accountgl1   TYPE STANDARD TABLE OF bapiacgl09,
6011               it_accountgl2   TYPE STANDARD TABLE OF bapiacgl09,
6012               it_payable      TYPE STANDARD TABLE OF bapiacap09,
6013               wa_return       TYPE bapiret2,
6014               it_return       TYPE STANDARD TABLE OF bapiret2,
6015               it_values       TYPE re_t_rsdomaval,
6016               wa_values       TYPE LINE OF re_t_rsdomaval,
6017               it_billtype     TYPE STANDARD TABLE OF ty_billtype,
6018               wa_billtype     TYPE ty_billtype,
6019               it_billhead     TYPE STANDARD TABLE OF zbill_head,
6020               wa_billhead     TYPE zbill_head,
6021               it_currency     TYPE STANDARD TABLE OF bapiaccr09,
6022               it_currency1    TYPE STANDARD TABLE OF bapiaccr09,
6023               wa_currency     TYPE bapiaccr09,
6024               wa_extension    TYPE bapiparex,
6025               it_extension    TYPE bapiparex_tab_ac,
6026               lv_total        TYPE zbill_call_charges,
6027               l_total_pay     TYPE zbill_call_charges,
6028               l_total_acc     TYPE zbill_call_charges,
6029               l_kst01         TYPE kostl,
6030               lv_item         TYPE posnr_acc,
6031               ind             TYPE sy-index,
6032               lv_attach_check TYPE char1,
6033               wa_pa9105       TYPE p9105,
6034               it_pa9105       TYPE TABLE OF p9105, "
6035               it_pa9105_1     TYPE TABLE OF p9105,
6036               it_pa9105_2     TYPE TABLE OF p9105,
6037               it_pa9105_3     TYPE TABLE OF p9105,
6038               it_pa9105_4     TYPE TABLE OF p9105,
6039               it_pa9105_5     TYPE TABLE OF p9105,
6040               it_data_temp    TYPE TABLE OF p9105,
6041               lt_pa9205       TYPE TABLE OF pa9205,
6042               wa_pa9205       TYPE pa9205,
6043               lv_len          TYPE i,
6044               lv_phone10      TYPE char11,
6045               lv_phone11      TYPE char11.
6046
6047         DATA : wa_user TYPE bapip0001.
6048
6049         DATA : it_bapireturn  TYPE STANDARD TABLE OF bapireturn1,
6050                l_bapireturn   TYPE bapireturn1,
6051                l_key          TYPE bapipakey,
6052                l_return       TYPE bapireturn1.
6053
6054         TYPES :  BEGIN OF ty_hr_return,
6055                   ermsg_type  TYPE bapi_mtype,
6056                   er_id       TYPE symsgid,
6057                   er_number   TYPE symsgno,
6058                   er_message  TYPE bapi_msg,
6059                   pernr       TYPE persno,
6060                   re_num      TYPE zbill_req_nm,
6061                 END OF ty_hr_return.
6062
6063         DATA : it_hr_return   TYPE TABLE OF ty_hr_return,
6064                wa_hr_return   TYPE ty_hr_return.
6065
6066         DATA : lv_dist_tot    TYPE dmbtr," Distribution toal " bapidoccur.
6067                lv_diff_tot    TYPE dmbtr.
6068         FIELD-SYMBOLS : <ls_gl> TYPE ty_gl.
6069
6070         CALL METHOD r_grid->check_changed_data.
6071
6072         REFRESH it_item3.
6073         MOVE it_item2[] TO it_item3[].
6074
6075         SORT   it_item2 BY status.
6076         DELETE it_item2 WHERE status   EQ '6'.
6077         SORT   it_item2 BY check1.
6078         DELETE it_item2 WHERE check1  EQ 'X'.
6079
6080         SORT it_item2 BY bukrs reqt_num reqt_id.
6081         IF it_item2 IS NOT INITIAL.
6082           SELECT * FROM zbill_head
6083                    INTO TABLE it_billhead
6084                    FOR ALL ENTRIES IN it_item2
6085                    WHERE reqt_num EQ it_item2-reqt_num.
6086           IF sy-subrc EQ 0.
6087             SORT it_billhead BY reqt_num.
6088           ENDIF.
6089         ELSE.
6090           MESSAGE 'Please select the records which are not processed.' TYPE 'I'.
6091         ENDIF.
6092
6093         CALL METHOD cl_reca_ddic_doma=>get_values
6094           EXPORTING
6095             id_name   = 'ZBILL_TYPE'
6096             id_langu  = sy-langu
6097           IMPORTING
6098             et_values = it_values
6099           EXCEPTIONS
6100             not_found = 1
6101             OTHERS    = 2.
6102         IF sy-subrc EQ 0.
6103           LOOP AT it_values INTO wa_values.
6104             MOVE : wa_values-domvalue_l TO wa_billtype-key,
6105             wa_values-ddtext TO wa_billtype-text.
6106             APPEND wa_billtype TO it_billtype.
6107             CLEAR : wa_billtype,wa_values.
6108           ENDLOOP.
6109         ENDIF.
6110
6111         SORT it_item2 BY bukrs reqt_num reqt_id.
6112   ****************************************** code added by Bipin Shukla : 23/12/2013 : for comp code
6113         IF it_item2 IS NOT INITIAL.
6114
6115           SELECT * FROM zbill_gl
6116               INTO CORRESPONDING FIELDS OF TABLE gt_bill_gl
6117               FOR ALL ENTRIES IN it_item2
6118               WHERE bill_type = it_item2-bill_type.
6119           IF sy-subrc = 0 AND gt_bill_gl[] IS NOT INITIAL.
6120   " " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
6121             SELECT * INTO TABLE it_ska1 "#EC CI_DB_OPERATION_OK[2431747]
6122                      FROM ska1  "#EC CI_DB_OPERATION_OK[2389136]
6123                      FOR ALL ENTRIES IN gt_bill_gl
6124                      WHERE saknr = gt_bill_gl-hkont
6125                      AND   xbilk <> 'X'
6126                      AND   ktopl = wa_t001-ktopl.
6127   " " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
6128           ENDIF.
6129         ENDIF.
6130
6131         LOOP AT it_billhead INTO wa_billhead.
6132           CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
6133             EXPORTING
6134               input  = wa_billhead-serv_prov
6135             IMPORTING
6136               output = wa_billhead-serv_prov.
6137           MODIFY it_billhead FROM wa_billhead.
6138         ENDLOOP.
6139         IF it_billhead[] IS NOT INITIAL.
6140           SELECT * FROM lfb1
6141                 INTO CORRESPONDING FIELDS OF TABLE gt_lfb1
6142                 FOR ALL ENTRIES IN it_billhead
6143                 WHERE bukrs = it_billhead-bukrs
6144                 AND lifnr = it_billhead-serv_prov.
6145         ENDIF.
6146   ****************************************** code added by Bipin Shukla : 23/12/2013 : for comp code
6147
6148   *     Check for alternative G/L
6149         FIELD-SYMBOLS : <fs_amt> TYPE any.
6150         REFRESH it_zbill_gl.
6151         DATA : l_kts01 TYPE kostl.
6152
6153         CALL FUNCTION 'G_SET_GET_ID_FROM_NAME'
6154           EXPORTING
6155             shortname = 'Z_COST_CTR_CENVAT'       "Set Name
6156           IMPORTING
6157             new_setid = w_setid
6158           EXCEPTIONS
6159             OTHERS    = 1.
6160
6161         CALL FUNCTION 'G_SET_FETCH'
6162           EXPORTING
6163             setnr           = w_setid
6164           TABLES
6165             set_lines_basic = int_vlaues
6166           EXCEPTIONS
6167             OTHERS          = 1.
6168
6169
6170         SORT it_item2 BY check.
6171         LOOP AT it_item2 INTO wa_item2 WHERE check IS NOT INITIAL.
6172
6173           REFRESH : gt_glamt. CLEAR : lv_dist_tot.
6174
6175   *       For Employees
6176           IF wa_item2-pernr IS NOT INITIAL.
6177
6178             LOOP AT gt_bill_gl INTO wa_bill_gl WHERE bill_type = wa_item2-bill_type.
6179               CLEAR : gs_gl.
6180               gs_gl-hkont = wa_bill_gl-hkont. "G/L Account
6181               gs_gl-expence = wa_bill_gl-expence.
6182
6183               UNASSIGN <fs_amt>.
6184               ASSIGN COMPONENT wa_bill_gl-expence OF STRUCTURE wa_item2 TO <fs_amt>.
6185               IF <fs_amt> IS ASSIGNED.
6186                 LOOP AT gt_pa0027 INTO gs_pa0027 WHERE pernr = wa_item2-pernr
6187                                                  AND   endda GE wa_item2-bill_from
6188                                                  AND   begda LE wa_item2-bill_from.
6189   *              Cost Distribution as in Infotype 27
6190                   PERFORM f_cost_distribution USING gs_pa0027
6191                                                     <fs_amt>
6192                                               CHANGING gs_gl.
6193
6194                   CLEAR gs_pa0027.
6195                   EXIT.
6196                 ENDLOOP.
6197
6198               ENDIF.
6199             ENDLOOP.
6200
6201           ELSE.
6202
6203   *         For Vendors
6204             LOOP AT gt_bill_gl INTO wa_bill_gl WHERE bill_type = wa_item2-bill_type.
6205               CLEAR : gs_gl.
6206               gs_gl-hkont = wa_bill_gl-hkont. "G/L Account
6207               gs_gl-expence = wa_bill_gl-expence.
6208   *           Check for alternative G/L.
6209               CLEAR : wa_vlaues.
6210               READ TABLE int_vlaues INTO wa_vlaues WITH KEY from = wa_item2-kst01.
6211               IF sy-subrc = 0 AND wa_bill_gl-alt_hkont IS NOT INITIAL.
6212                 gs_gl-hkont = wa_bill_gl-alt_hkont.
6213               ENDIF.
6214               UNASSIGN <fs_amt>.
6215               ASSIGN COMPONENT wa_bill_gl-expence OF STRUCTURE wa_item2 TO <fs_amt>.
6216               IF <fs_amt> IS ASSIGNED.
6217   *              CLEAR wa_ska1.
6218   *              READ TABLE it_ska1 INTO wa_ska1 WITH KEY saknr = gs_gl-hkont.
6219   *              IF sy-subrc = 0.
6220                 CLEAR wa_csks.
6221                 READ TABLE gt_csks INTO wa_csks WITH KEY kostl = wa_item2-kst01.
6222                 IF sy-subrc EQ 0.
6223                   gs_gl-bukrs = wa_csks-bukrs. "Company Code
6224                 ENDIF.
6225                 gs_gl-kostl  = wa_item2-kst01.  "Cost center
6226                 gs_gl-amount = <fs_amt>.        "Amount
6227   *                COLLECT gs_gl INTO gt_gl.
6228
6229                 APPEND gs_gl TO gt_glamt.
6230                 CLEAR : gs_gl-kostl,gs_gl-amount.
6231   *              ENDIF.
6232               ENDIF.
6233
6234             ENDLOOP.
6235
6236           ENDIF.
6237
6238
6239   *       Collect amounts
6240           LOOP AT gt_glamt INTO gs_gl.
6241             CHECK gs_gl-amount <> 0.
6242
6243   *         Balance sheet account
6244             CLEAR wa_ska1.
6245             READ TABLE it_ska1 INTO wa_ska1 WITH KEY saknr = gs_gl-hkont.
6246             IF sy-subrc <> 0.
6247               CLEAR gs_gl-kostl.
6248               CLEAR gs_gl-wbs.
6249               CLEAR gs_gl-aufnr.
6250             ENDIF.
6251
6252   *       Check Expence type
6253             IF gs_gl-expence = 'SECURITY_DEP_FIN' OR
6254                gs_gl-expence = 'MISCL_FIN'.
6255               gs_gl-conn_numb = wa_item2-conn_numb.
6256               gs_gl-bill_num  = wa_item2-bill_num.
6257             ELSE.
6258               CLEAR gs_gl-expence.
6259             ENDIF.
6260
6261             COLLECT gs_gl INTO gt_gl.
6262             lv_dist_tot = lv_dist_tot + gs_gl-amount.
6263             CLEAR gs_gl.
6264           ENDLOOP.
6265
6266
6267           MOVE space TO gv_posted.
6268
6269   *       Get approved line Total
6270           CLEAR lv_total.
6271           lv_total = wa_item2-rent_final + wa_item2-call_charges_final +
6272                      wa_item2-oth_charges_fin + wa_item2-service_tax_fin +
6273                      wa_item2-security_dep_fin + wa_item2-interest_fin +
6274                      wa_item2-miscl_fin.
6275
6276           l_total_pay = l_total_pay + lv_total.
6277
6278   *         Total of approved amount and sum of total of distributed amount not matched ?
6279           IF lv_dist_tot <> lv_total.
6280             CLEAR : gs_gl,lv_diff_tot.
6281             lv_diff_tot = lv_total - lv_dist_tot .
6282             READ TABLE gt_glamt INTO gs_gl INDEX 1.
6283             IF sy-subrc = 0.
6284               UNASSIGN <ls_gl>.
6285               READ TABLE gt_gl ASSIGNING <ls_gl> WITH KEY bukrs = gs_gl-bukrs
6286                                                           hkont = gs_gl-hkont
6287                                                           kostl = gs_gl-kostl
6288                                                           aufnr = gs_gl-aufnr
6289                                                           wbs   = gs_gl-wbs.
6290               IF <ls_gl> IS ASSIGNED.
6291                 <ls_gl>-amount = <ls_gl>-amount + lv_diff_tot.
6292               ENDIF.
6293             ENDIF.
6294           ENDIF.
6295   *******************************************************     added by bipin
6296   *        SHIFT wa_item2-zphone LEFT DELETING LEADING lv_nullc.
6297   *        lv_len = strlen( wa_item2-zphone ).
6298   *        IF lv_len = 10.
6299   *          lv_phone11 = '0' && wa_item2-zphone(10).
6300   *          lv_phone10 = wa_item2-zphone(10).
6301   *        ELSEIF lv_len = 11.
6302   *          lv_phone11 = wa_item2-zphone(11).
6303   *          lv_phone10 = wa_item2-zphone+1(10).
6304   *        ELSEIF lv_len = 12.
6305   *          lv_phone11 = '0' && wa_item2-zphone+2(10).
6306   *          lv_phone10 = wa_item2-zphone+2(10).
6307   *        ELSEIF lv_len = 13.
6308   *          lv_phone11 = '0' && wa_items2-zphone+3(10).
6309   *          lv_phone10 = wa_items2-zphone+3(10).
6310   *        ENDIF.
6311   ************************************ADDED BY BIPIN ON 11/11/2013
6312   *        READ TABLE it_pa9205 INTO wa_pa9205 WITH KEY zphone = lv_phone11."wa_item2-zphone.
6313   *        IF sy-subrc = 0.
6314   *          wa_pa9105-infty = '9105'.
6315   *          wa_pa9105-begda = sy-datum.
6316   *          wa_pa9105-endda = '99991231'.
6317   *          wa_pa9105-pernr = wa_pa9205-pernr.
6318   *          CONCATENATE wa_item2-bill_from(2) wa_item2-bill_from+2(2) wa_item2-bill_from+4(4)   INTO wa_pa9105-zbill_date_fr.
6319   *          CONCATENATE wa_item2-bill_to(2) wa_item2-bill_to+2(2) wa_item2-bill_to+4(4)   INTO wa_pa9105-zbill_date_to.
6320   *          wa_pa9105-begda = wa_pa9105-zbill_date_fr.  "sy-datum.
6321   *          wa_pa9105-endda = wa_pa9105-zbill_date_to . "'99991231'.
6322   *          wa_pa9105-zbill_no = wa_item2-bill_num.
6323   *          wa_pa9105-zphn_no = lv_phone11."wa_item2-zphone."+vikas
6324   *          wa_pa9105-doc_no = wa_item2-reqt_num.
6325   *          wa_pa9105-subty   = '01'.
6326   *          wa_pa9105-aedtm   = sy-datum.
6327   *          wa_pa9105-uname   = sy-uname.
6328   *          wa_pa9105-zadm_amt = lv_total.
6329   *          APPEND wa_pa9105 TO it_pa9105.
6330   *        ELSE.
6331   *          READ TABLE it_pa9205 INTO wa_pa9205 WITH KEY zphone = lv_phone10.
6332   *          IF sy-subrc EQ 0.
6333   *            wa_pa9105-infty = '9105'.
6334   *            wa_pa9105-begda = sy-datum.
6335   *            wa_pa9105-endda = '99991231'.
6336   *            wa_pa9105-pernr = wa_pa9205-pernr.
6337   *            CONCATENATE wa_item2-bill_from(2) wa_item2-bill_from+2(2) wa_item2-bill_from+4(4)   INTO wa_pa9105-zbill_date_fr.
6338   *            CONCATENATE wa_item2-bill_to(2) wa_item2-bill_to+2(2) wa_item2-bill_to+4(4)   INTO wa_pa9105-zbill_date_to.
6339   *            wa_pa9105-begda = wa_pa9105-zbill_date_fr.  "sy-datum.
6340   *            wa_pa9105-endda = wa_pa9105-zbill_date_to . "'99991231'.
6341   *            wa_pa9105-zbill_no = wa_item2-bill_num.
6342   *            wa_pa9105-zphn_no = lv_phone10."wa_item2-zphone."+vikas
6343   *            wa_pa9105-doc_no = wa_item2-reqt_num.
6344   *            wa_pa9105-subty   = '01'.
6345   *            wa_pa9105-aedtm   = sy-datum.
6346   *            wa_pa9105-uname   = sy-uname.
6347   *            wa_pa9105-zadm_amt = lv_total.
6348   *            APPEND wa_pa9105 TO it_pa9105.
6349   *          ENDIF.
6350   *        ENDIF.
6351
6352           AT END OF reqt_num.
6353
6354   *       Prepare header for Acc.documet
6355
6356   *       Header text - Request number
6357             CLEAR : wa_billhead,wa_header.
6358             READ TABLE it_billhead INTO wa_billhead WITH KEY reqt_num = wa_item2-reqt_num BINARY SEARCH.
6359             IF sy-subrc EQ 0.
6360               READ TABLE it_billtype INTO wa_billtype WITH KEY key = wa_billhead-bill_type.
6361               IF sy-subrc EQ 0.
6362                 MOVE wa_billtype-text TO wa_header-header_txt.
6363               ENDIF.
6364               MOVE : wa_billhead-bukrs       TO wa_header-comp_code,
6365                      wa_billhead-create_date TO wa_header-doc_date.
6366             ENDIF.
6367
6368             wa_header-pstng_date = post_dt.
6369             wa_header-doc_type   = 'KM'.
6370             wa_header-ref_doc_no = wa_item2-reqt_num.
6371             wa_header-username   = sy-uname.
6372
6373   *       Prepare header for Acc.documet - end
6374
6375
6376   *         Prepare Acc.Payble(Vendor) table
6377
6378             REFRESH : it_payable,it_currency.
6379             CLEAR : lv_item.
6380             ADD 1 TO lv_item.
6381             CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
6382               EXPORTING
6383                 input  = wa_billhead-serv_prov
6384               IMPORTING
6385                 output = wa_payable-vendor_no.
6386             CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
6387               EXPORTING
6388                 input  = lv_item
6389               IMPORTING
6390                 output = wa_payable-itemno_acc.
6391
6392             wa_payable-comp_code = wa_header-comp_code.
6393             CLEAR wa_lfb1.
6394             READ TABLE gt_lfb1 INTO wa_lfb1 WITH KEY bukrs = wa_header-comp_code lifnr = wa_payable-vendor_no.
6395             IF sy-subrc EQ 0.
6396               wa_payable-pmnttrms  = wa_lfb1-zterm.
6397               wa_payable-pymt_meth = wa_lfb1-zwels.
6398             ENDIF.
6399             wa_payable-item_text   = txt.
6400             wa_payable-bline_date  = due_date.
6401             wa_payable-alloc_nmbr  = wa_item2-reqt_num.
6402             wa_payable-sectioncode = sec_code. " section code added by Bipin on 28/10/2013
6403             APPEND wa_payable TO it_payable.
6404
6405             wa_currency-itemno_acc = wa_payable-itemno_acc.
6406             wa_currency-curr_type  = '00'.
6407             wa_currency-currency   = 'INR'.
6408             COMPUTE wa_currency-amt_doccur = ( l_total_pay * -1 ).
6409             APPEND wa_currency TO it_currency.
6410
6411   *         Prepare Acc.Payble(Vendor) table - End
6412
6413             CLEAR : lt_csks, lt_wbs_prc, lt_ord_prc,
6414                     lt_svalue.
6415
6416   *       Get Profit Center
6417             PERFORM f_get_profit_ctr USING     gt_gl
6418                                      CHANGING  lt_csks
6419                                                lt_wbs_prc
6420                                                lt_ord_prc
6421                                                lt_svalue.
6422
6423   *         Prepare G/L Line items
6424
6425             REFRESH it_accountgl.
6426             LOOP AT gt_gl INTO gs_gl.
6427               CLEAR wa_accountgl.
6428               ADD 1 TO lv_item.
6429               CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
6430                 EXPORTING
6431                   input  = lv_item
6432                 IMPORTING
6433                   output = wa_accountgl-itemno_acc.
6434
6435               CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
6436                 EXPORTING
6437                   input  = gs_gl-hkont
6438                 IMPORTING
6439                   output = wa_accountgl-gl_account.
6440
6441               wa_accountgl-item_text  = wa_header-header_txt.
6442               wa_accountgl-acct_type  = 'S'.
6443               wa_accountgl-doc_type   = 'KM'.
6444               wa_accountgl-pstng_date = wa_header-pstng_date.
6445               wa_accountgl-value_date = wa_header-pstng_date.
6446               wa_accountgl-alloc_nmbr = wa_item2-reqt_num.
6447               wa_accountgl-costcenter = gs_gl-kostl.
6448               wa_accountgl-orderid    = gs_gl-aufnr.
6449               IF gs_gl-wbs IS NOT INITIAL.
6450                 CALL FUNCTION 'CONVERSION_EXIT_ABPSP_OUTPUT'
6451                   EXPORTING
6452                     input  = gs_gl-wbs
6453                   IMPORTING
6454                     output = wa_accountgl-wbs_element.
6455               ENDIF.
6456
6457   *           Check Set of G/L Account for Profit center
6458               CLEAR ls_svalue.
6459               READ TABLE lt_svalue INTO ls_svalue WITH KEY from = wa_accountgl-gl_account.
6460               IF sy-subrc = 0.
6461
6462   *             Profit center for cost center
6463                 CLEAR : ls_csks.
6464                 READ TABLE lt_csks INTO ls_csks WITH KEY kostl = wa_accountgl-costcenter.
6465                 IF sy-subrc = 0.
6466                   CLEAR wa_accountgl-costcenter.
6467                   wa_accountgl-bus_area   = ls_csks-gsber.
6468                   wa_accountgl-profit_ctr = ls_csks-prctr.
6469                 ENDIF.
6470
6471   *             Profit center for WBS
6472                 CLEAR : ls_wbs_prc.
6473                 READ TABLE lt_wbs_prc INTO ls_wbs_prc WITH KEY pspnr = gs_gl-wbs.
6474                 "wa_accountgl-wbs_element.
6475                 IF sy-subrc = 0.
6476                   CLEAR wa_accountgl-wbs_element.
6477                   wa_accountgl-bus_area   = ls_wbs_prc-pgsbr.
6478                   wa_accountgl-profit_ctr = ls_wbs_prc-prctr.
6479                 ENDIF.
6480
6481   *             Profit center for Order
6482                 CLEAR : ls_ord_prc.
6483                 READ TABLE lt_ord_prc INTO ls_ord_prc WITH KEY aufnr = wa_accountgl-orderid.
6484                 IF sy-subrc = 0.
6485                   CLEAR wa_accountgl-orderid.
6486                   wa_accountgl-bus_area   = ls_ord_prc-gsber.
6487                   wa_accountgl-profit_ctr = ls_ord_prc-prctr.
6488                 ENDIF.
6489
6490               ENDIF.
6491
6492               wa_accountgl-res_doc    = er_kblnr.
6493               wa_accountgl-res_item   = er_kblpos.
6494               wa_accountgl-ref_key_1  = gs_gl-kostl.
6495
6496   *           Check Expence type
6497               IF gs_gl-expence = 'SECURITY_DEP_FIN' OR
6498                  gs_gl-expence = 'MISCL_FIN'.
6499                 wa_accountgl-ref_key_2  = gs_gl-bill_num.
6500                 wa_accountgl-ref_key_3  = gs_gl-conn_numb.
6501               ENDIF.
6502
6503               CLEAR wa_ska1.
6504               READ TABLE it_ska1 INTO wa_ska1 WITH KEY saknr = wa_accountgl-gl_account.
6505               IF sy-subrc <> 0.
6506   *            CLEAR wa_accountgl-costcenter.
6507   *            CLEAR wa_accountgl-comp_code.
6508                 CLEAR wa_accountgl-res_doc.
6509                 CLEAR wa_accountgl-res_item.
6510               ELSE.
6511                 wa_accountgl-comp_code = gs_gl-bukrs.
6512               ENDIF.
6513
6514               APPEND wa_accountgl TO it_accountgl.
6515
6516               CLEAR wa_currency.
6517               wa_currency-itemno_acc = wa_accountgl-itemno_acc.
6518               wa_currency-curr_type  = '00'.
6519               wa_currency-currency   = 'INR'.
6520   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
6521   *            wa_currency-amt_doccur = gs_gl-amount.
6522               wa_currency-amt_doccur = CONV #( gs_gl-amount ).
6523   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
6524               APPEND wa_currency TO it_currency.
6525               CLEAR gs_gl.
6526             ENDLOOP.
6527
6528   *         Prepare G/L Line items - end
6529
6530
6531   *         Prepare Extension table
6532
6533             REFRESH it_extension.
6534             wa_extension-valuepart1 = sy-repid.
6535             wa_extension-valuepart2 = 'KIDNO'.
6536             IF gv_kidno IS NOT INITIAL.
6537               wa_extension-valuepart3 = gv_kidno.
6538             ELSE.
6539               wa_extension-valuepart3 = 'Utility Payment'.
6540             ENDIF.
6541             wa_extension-valuepart4 = wa_payable-itemno_acc.
6542             APPEND wa_extension TO it_extension.
6543             CLEAR wa_extension.
6544
6545   *         Prepare Extension table - End
6546
6547
6548             IF fp_v_mode = abap_true.
6549   *         Post Acc. Document
6550   " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
6551               CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'  "#EC CI_USAGE_OK
6552                   "#EC CI_USAGE_OK[2628704]
6553     "#EC CI_USAGE_OK[2438131]
6554
6555   " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
6556                 EXPORTING
6557                   documentheader = wa_header
6558                 TABLES
6559                   accountgl      = it_accountgl
6560                   accountpayable = it_payable
6561                   currencyamount = it_currency
6562                   extension2     = it_extension
6563                   return         = it_return.
6564
6565             ELSE.
6566   *         Simulate Acc. Document
6567   " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
6568               CALL FUNCTION 'BAPI_ACC_DOCUMENT_CHECK'  "#EC CI_USAGE_OK
6569                   "#EC CI_USAGE_OK[2628704]
6570     "#EC CI_USAGE_OK[2438131]
6571
6572   " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
6573                 EXPORTING
6574                   documentheader = wa_header
6575                 TABLES
6576                   accountgl      = it_accountgl
6577                   accountpayable = it_payable
6578                   currencyamount = it_currency
6579                   extension2     = it_extension
6580                   return         = it_return.
6581             ENDIF.
6582
6583             LOOP AT it_return INTO wa_return.
6584               wa_error-reqnum  = wa_item2-reqt_num.
6585               wa_error-er_type = wa_return-type.
6586               wa_error-msg_id = wa_return-id.
6587               wa_error-msg_num = wa_return-number.
6588               wa_error-msg = wa_return-message.
6589               APPEND wa_error TO it_error.
6590             ENDLOOP.
6591             CLEAR : wa_error.
6592
6593             CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
6594               EXPORTING
6595                 wait = 'X'.
6596
6597             EXPORT wa_header     TO MEMORY ID 'SIMU_HEAD'.
6598             EXPORT it_accountgl  TO MEMORY ID 'SIMU_ACC'.
6599             EXPORT it_payable    TO MEMORY ID 'SIMU_PAY'.
6600             EXPORT it_currency   TO MEMORY ID 'SIMU_CUR'.
6601             EXPORT it_error      TO MEMORY ID 'SIMU_ERROR'.
6602
6603             REFRESH : gt_gl,it_accountgl[],it_payable[],
6604                       it_currency[],it_extension, it_accountgl1,
6605                       it_currency1,it_zbill_gl.
6606             CLEAR : wa_header,lv_total,lv_item,l_total_pay.
6607
6608   *        If simulated
6609             IF fp_v_mode <> abap_true.
6610               CALL SCREEN 0902.
6611             ENDIF.
6612
6613             MOVE : abap_true TO gv_posted,
6614             wa_item2-reqt_num TO gv_reqt_num.
6615   ************************************** To update HR table
6616           ENDAT.
6617           CLEAR : wa_billhead,wa_items,wa_payable,wa_accountgl,wa_billtype,wa_header,wa_item2 .
6618
6619   *     If posted
6620           IF fp_v_mode = abap_true.
6621
6622             IF gv_posted EQ abap_true.
6623               LOOP AT it_item2 INTO wa_item2 WHERE reqt_num EQ gv_reqt_num AND check IS NOT INITIAL.
6624                 ind = sy-tabix.
6625                 READ TABLE it_return INTO wa_return INDEX 1.
6626
6627                 IF wa_return-type EQ 'S' ."AND L_BAPIRETURN-TYPE NE 'E' AND L_RETURN-TYPE NE 'E'. " CHANGES BY BIPIN ON 13/11/2013
6628                   CLEAR : lv_ret_type , post_doc , post_comp_code , post_year.
6629                   lv_ret_type = wa_return-type.
6630                   EXPORT lv_ret_type TO MEMORY ID 'LV_RET'.
6631   ******************          changes by bipin on 06/12/2014
6632                   MOVE wa_return-message_v2+0(10) TO wa_item2-account_doc_no.
6633                   MOVE wa_return-message_v2+10(4) TO wa_item2-comp_code.
6634                   MOVE wa_return-message_v2+14(4) TO wa_item2-fyear.
6635                   MOVE '6' TO wa_item2-status.
6636
6637                   post_doc = wa_item2-account_doc_no.
6638                   post_comp_code = wa_item2-comp_code.
6639                   post_year = wa_item2-fyear.
6640
6641
6642                   EXPORT post_doc TO MEMORY ID 'P_DOC'.
6643                   EXPORT post_comp_code TO MEMORY ID 'P_CC'.
6644                   EXPORT post_year TO MEMORY ID 'P_DOC'.
6645
6646   ******************          changes by bipin on 06/12/2014
6647
6648                   IF lv_attach_check = space.
6649   * Begin of changes by vikas on 01-11-2013
6650   * Attaching uploaded document with FI document
6651                     CALL FUNCTION 'ZBILL_ATTACH_DOCUMENT'
6652                       EXPORTING
6653                         im_reqt_num  = gv_reqt_num
6654                         im_belnr     = wa_item2-account_doc_no
6655                         im_bukrs     = bukrs
6656                         im_bill_date = wa_item2-bill_date.
6657                     lv_attach_check = 'X'.
6658                   ENDIF.
6659
6660                   READ TABLE l_return5 INTO w_return5 WITH KEY req_num = gv_reqt_num pernr = w_return5-pernr.
6661
6662                   IF w_return5-er_type = '' OR w_return5-er_type = 'S'.
6663
6664   ************************ + SAB_BIPIN on 11/11/2013
6665                     REFRESH wa_item2-style[].
6666
6667                     CLEAR ls_style.
6668                     ls_style-fieldname = 'CALL_CHARGES_FINAL'.
6669                     ls_style-style     = cl_gui_alv_grid=>mc_style_disabled .
6670                     INSERT ls_style INTO TABLE wa_item2-style.
6671
6672                     CLEAR ls_style.
6673                     ls_style-fieldname = 'CHECK'.
6674                     ls_style-style     = cl_gui_alv_grid=>mc_style_disabled .
6675                     INSERT ls_style INTO TABLE wa_item2-style.
6676
6677                     CLEAR ls_style.
6678                     ls_style-fieldname = 'CHECK1'.
6679                     ls_style-style     = cl_gui_alv_grid=>mc_style_disabled .
6680                     INSERT ls_style INTO TABLE wa_item2-style.
6681
6682                     CLEAR ls_style.
6683                     ls_style-fieldname = 'INTEREST_FIN'.
6684                     ls_style-style     = cl_gui_alv_grid=>mc_style_disabled .
6685                     INSERT ls_style INTO TABLE wa_item2-style.
6686
6687                     CLEAR ls_style.
6688                     ls_style-fieldname = 'MISCL_FIN'.
6689                     ls_style-style     = cl_gui_alv_grid=>mc_style_disabled .
6690                     INSERT ls_style INTO TABLE wa_item2-style.
6691
6692                     CLEAR ls_style.
6693                     ls_style-fieldname = 'OTH_CHARGES_FIN'.
6694                     ls_style-style     = cl_gui_alv_grid=>mc_style_disabled .
6695                     INSERT ls_style INTO TABLE wa_item2-style.
6696
6697                     CLEAR ls_style.
6698                     ls_style-fieldname = 'REMARKS'.
6699                     ls_style-style     = cl_gui_alv_grid=>mc_style_disabled .
6700                     INSERT ls_style INTO TABLE wa_item2-style.
6701
6702                     CLEAR ls_style.
6703                     ls_style-fieldname = 'RENT_FINAL'.
6704                     ls_style-style     = cl_gui_alv_grid=>mc_style_disabled .
6705                     INSERT ls_style INTO TABLE wa_item2-style.
6706
6707                     CLEAR ls_style.
6708                     ls_style-fieldname = 'SECURITY_DEP_FIN'.
6709                     ls_style-style     = cl_gui_alv_grid=>mc_style_disabled .
6710                     INSERT ls_style INTO TABLE wa_item2-style.
6711
6712                     CLEAR ls_style.
6713                     ls_style-fieldname = 'SERVICE_TAX_FIN'.
6714                     ls_style-style     = cl_gui_alv_grid=>mc_style_disabled .
6715                     INSERT ls_style INTO TABLE wa_item2-style.
6716
6717                     CLEAR ls_style.
6718                     wa_item2-check = ''.
6719                     wa_item2-check1 = ''.
6720   ******************** Added by Bipin
6721                     READ TABLE it_error INTO wa_error WITH KEY reqnum = wa_item2-reqt_num.
6722                     IF sy-subrc EQ 0.
6723                       MOVE wa_error-msg TO wa_item2-comment.
6724                       CONCATENATE 'FI - ' wa_item2-comment INTO wa_item2-comment SEPARATED BY space.
6725                     ENDIF.
6726   ******************** Added by Bipin
6727                   ELSEIF w_return5-er_type = 'E'.
6728
6729                     MOVE wa_return-message_v2+0(10) TO wa_item2-account_doc_no.
6730                     MOVE wa_return-message_v2+10(4) TO wa_item2-comp_code.
6731                     MOVE wa_return-message_v2+14(4) TO wa_item2-fyear.
6732                     CONCATENATE 'HR - ' w_return5-msg  INTO w_return5-msg SEPARATED BY space .
6733                     MOVE w_return5-msg TO wa_item2-comment.
6734                     MOVE '8' TO wa_item2-status. " ADDED BY BIPIN FOR HR ERROR
6735                     wa_item2-rowcolor = 'C610'.
6736                   ENDIF.
6737
6738                 ELSEIF  wa_return-type EQ 'E'.
6739                   READ TABLE it_error INTO wa_error WITH KEY reqnum = wa_item2-reqt_num.
6740                   MOVE wa_error-msg TO wa_item2-comment.
6741                   CONCATENATE 'FI - ' wa_item2-comment INTO wa_item2-comment SEPARATED BY space.
6742                   wa_item2-rowcolor = 'C610'.
6743
6744   ******************** Added by Bipin
6745                   wa_item2-t_msg = it_return.
6746                 ENDIF.
6747                 MODIFY it_item2 FROM wa_item2 INDEX ind TRANSPORTING account_doc_no comp_code fyear status comment rowcolor style check check1 t_msg.
6748                 REFRESH wa_item2-style[].
6749               ENDLOOP.
6750               PERFORM save_data.
6751             ENDIF.
6752           ENDIF.
6753         ENDLOOP.
6754
6755         CALL METHOD r_grid->refresh_table_display.
6756
6757       ENDFORM.                    " F_RELEASE_TO_ACCOUNTING
6758   *&---------------------------------------------------------------------*
6759   *&      Form  F_SCROLL_UP_DOWN
6760   *&---------------------------------------------------------------------*
6761   *       text
6762   *----------------------------------------------------------------------*
6763   *      -->P_OK_CODE  text
6764   *----------------------------------------------------------------------*
6765       FORM f_scroll_up_down  USING    fp_v_fcode TYPE sy-ucomm.
6766
6767         DATA : lv_lines TYPE sy-tabix,
6768                lv_rowno TYPE lvc_s_roid.
6769
6770         CLEAR lv_lines.
6771         DESCRIBE TABLE it_item2 LINES lv_lines.
6772         CLEAR lv_rowno.
6773         CASE fp_v_fcode.
6774           WHEN 'P++'.
6775             lv_rowno-row_id = lv_lines.
6776           WHEN 'P+'.
6777             CALL METHOD r_grid->get_current_cell
6778               IMPORTING
6779                 es_row_no = lv_rowno.
6780             lv_rowno-row_id = lv_rowno-row_id + 25.
6781             IF lv_rowno-row_id > lv_lines.
6782               lv_rowno-row_id = lv_lines.
6783             ENDIF.
6784           WHEN 'P-'.
6785             CALL METHOD r_grid->get_current_cell
6786               IMPORTING
6787                 es_row_no = lv_rowno.
6788             lv_rowno-row_id = lv_rowno-row_id - 25.
6789             IF lv_rowno-row_id < 1.
6790               lv_rowno-row_id = 1.
6791             ENDIF.
6792           WHEN 'P--'.
6793             lv_rowno-row_id = 1.
6794           WHEN OTHERS.
6795         ENDCASE.
6796         IF r_grid IS BOUND.
6797           CALL METHOD r_grid->set_current_cell_via_id
6798             EXPORTING
6799               is_row_no = lv_rowno.
6800         ENDIF.
6801
6802       ENDFORM.                    " F_SCROLL_UP_DOWN
6803   *&---------------------------------------------------------------------*
6804   *&      Form  F_VALIDATE_CELL_VALUE
6805   *&---------------------------------------------------------------------*
6806   *       text
6807   *----------------------------------------------------------------------*
6808   *      -->P_ER_DATA_CHANGED  text
6809   *      -->P_WA_CELL  text
6810   *      -->P_F_FIELD  text
6811   *----------------------------------------------------------------------*
6812       FORM f_validate_cell_value  USING    fp_r_data_changed TYPE REF TO cl_alv_changed_data_protocol
6813                                            fp_s_cell         TYPE lvc_s_modi
6814                                            fp_v_field        TYPE lvc_fname
6815                                            fp_v_acfield      TYPE lvc_fname.
6816
6817         DATA : check_remarks     TYPE zbill_remarks.
6818         DATA : check_sec_remarks TYPE zbill_remarks.
6819
6820         DATA : ac_charge TYPE zbill_interest,
6821                ap_charge TYPE zbill_interest.
6822
6823         CLEAR : ac_charge,ap_charge,check_remarks,check_sec_remarks.
6824         CALL METHOD fp_r_data_changed->get_cell_value
6825           EXPORTING
6826             i_row_id    = fp_s_cell-row_id
6827             i_fieldname = fp_s_cell-fieldname
6828           IMPORTING
6829             e_value     = ap_charge.
6830         CALL METHOD fp_r_data_changed->get_cell_value
6831           EXPORTING
6832             i_row_id    = fp_s_cell-row_id
6833             i_fieldname = fp_v_acfield
6834           IMPORTING
6835             e_value     = ac_charge.
6836         IF  ac_charge < ap_charge AND ac_charge > 0.
6837
6838           CALL METHOD fp_r_data_changed->add_protocol_entry
6839             EXPORTING
6840               i_msgid     = 'ZBILL'
6841               i_msgty     = 'E'
6842               i_msgno     = '002'
6843               i_fieldname = fp_s_cell-fieldname
6844               i_row_id    = fp_s_cell-row_id.
6845   *      ENDIF.
6846         ELSEIF  ap_charge < 0 AND ac_charge > 0.
6847           CALL METHOD fp_r_data_changed->add_protocol_entry
6848             EXPORTING
6849               i_msgid     = 'ZBILL'
6850               i_msgty     = 'E'
6851               i_msgno     = '012'
6852               i_fieldname = fp_s_cell-fieldname
6853               i_row_id    = fp_s_cell-row_id.
6854
6855         ELSEIF  ac_charge < 0 AND ap_charge > 0.
6856           CALL METHOD fp_r_data_changed->add_protocol_entry
6857             EXPORTING
6858               i_msgid     = 'ZBILL'
6859               i_msgty     = 'E'
6860               i_msgno     = '013'
6861               i_fieldname = fp_s_cell-fieldname
6862               i_row_id    = fp_s_cell-row_id.
6863
6864         ELSEIF  ac_charge < 0 AND ap_charge < ac_charge.
6865           CALL METHOD fp_r_data_changed->add_protocol_entry
6866             EXPORTING
6867               i_msgid     = 'ZBILL'
6868               i_msgty     = 'E'
6869               i_msgno     = '014'
6870               i_fieldname = fp_s_cell-fieldname
6871               i_row_id    = fp_s_cell-row_id.
6872   ******************** MAKING REMARKS MANDATORY WHEN AMOUNT CHANGED
6873         ELSEIF ap_charge NE ac_charge AND sy-tcode = 'ZFIBD_PROCESS'.
6874
6875           CALL METHOD fp_r_data_changed->get_cell_value
6876             EXPORTING
6877               i_row_id    = fp_s_cell-row_id
6878               i_fieldname = 'REMARKS'
6879             IMPORTING
6880               e_value     = check_remarks.
6881
6882           IF check_remarks IS INITIAL.
6883
6884             CALL METHOD fp_r_data_changed->add_protocol_entry
6885               EXPORTING
6886                 i_msgid     = 'ZBILL'
6887                 i_msgty     = 'E'
6888                 i_msgno     = '004'
6889                 i_fieldname = 'REMARKS'
6890                 i_row_id    = fp_s_cell-row_id.
6891           ENDIF.
6892
6893   *      ENDIF.
6894
6895         ELSEIF ap_charge NE ac_charge AND sy-tcode = 'ZFIBD_POST'.
6896
6897           CALL METHOD fp_r_data_changed->get_cell_value
6898             EXPORTING
6899               i_row_id    = fp_s_cell-row_id
6900   *           I_TABIX     =
6901               i_fieldname = 'SEC_REMARKS'
6902             IMPORTING
6903               e_value     = check_remarks.
6904
6905           IF check_sec_remarks IS INITIAL.
6906
6907             CALL METHOD fp_r_data_changed->add_protocol_entry
6908               EXPORTING
6909                 i_msgid     = 'ZBILL'
6910                 i_msgty     = 'E'
6911                 i_msgno     = '004'
6912                 i_fieldname = 'SEC_REMARKS'
6913                 i_row_id    = fp_s_cell-row_id.
6914           ENDIF.
6915
6916         ENDIF.
6917
6918       ENDFORM.                    " F_VALIDATE_CELL_VALUE
6919   *&---------------------------------------------------------------------*
6920   *&      Form  F_CHECK_AT_SAVE
6921   *&---------------------------------------------------------------------*
6922   *       text
6923   *----------------------------------------------------------------------*
6924   *      -->P_WA_ITEM2_RENT  text
6925   *      -->P_WA_ITEM2_RENT_FINAL  text
6926   *      -->P_WA_ITEM2  text
6927   *----------------------------------------------------------------------*
6928       FORM f_check_at_save  USING    ac_charge  TYPE zbill_rent
6929                                      ap_charge  TYPE zbill_rent
6930                                      fp_s_item  TYPE ty_item1
6931                                      fp_v_field TYPE lvc_fname.
6932
6933         DATA : ls_item          TYPE ty_items,
6934                lv_ap_charge_old TYPE zbill_rent.
6935
6936         FIELD-SYMBOLS : <ls_apcharge> TYPE zbill_rent.
6937
6938   *     Get Old value of approved charges
6939         CLEAR : ls_item.
6940         READ TABLE it_items INTO ls_item WITH KEY reqt_num = fp_s_item-reqt_num
6941                                                   reqt_id  = fp_s_item-reqt_id.
6942         IF sy-subrc = 0.
6943           UNASSIGN <ls_apcharge>.
6944           ASSIGN COMPONENT fp_v_field OF STRUCTURE ls_item TO <ls_apcharge>.
6945           IF <ls_apcharge> IS ASSIGNED.
6946             lv_ap_charge_old = <ls_apcharge>.
6947           ENDIF.
6948         ENDIF.
6949
6950         IF  ac_charge < ap_charge AND ac_charge > 0.
6951           MESSAGE e015(zbill) WITH fp_s_item-reqt_num fp_s_item-reqt_id.
6952         ELSEIF  ap_charge < 0 AND ac_charge > 0.
6953           MESSAGE e015(zbill) WITH fp_s_item-reqt_num fp_s_item-reqt_id.
6954         ELSEIF  ac_charge < 0 AND ap_charge < ac_charge.
6955           MESSAGE e015(zbill) WITH fp_s_item-reqt_num fp_s_item-reqt_id.
6956         ELSEIF ap_charge NE ac_charge AND sy-tcode = 'ZFIBD_PROCESS' AND
6957                wa_item2-remarks IS INITIAL.
6958           MESSAGE e006(zbill) WITH fp_s_item-reqt_num fp_s_item-reqt_id.
6959   *      ELSEIF ap_charge NE ac_charge AND sy-tcode = 'ZFIBD_POST' AND
6960         ELSEIF ap_charge NE lv_ap_charge_old AND sy-tcode = 'ZFIBD_POST' AND
6961                wa_item2-sec_remarks IS INITIAL.
6962   *        IF ap_charge NE lv_ap_charge_old.
6963           MESSAGE e006(zbill) WITH fp_s_item-reqt_num fp_s_item-reqt_id.
6964   *        ENDIF.
6965         ENDIF.
6966
6967
6968       ENDFORM.                    " F_CHECK_AT_SAVE
6969   *&---------------------------------------------------------------------*
6970   *&      Form  F_GET_PROFIT_CTR
6971   *&---------------------------------------------------------------------*
6972   *       text
6973   *----------------------------------------------------------------------*
6974   *      -->P_GT_GL  text
6975   *      -->P_LT_CSKS  text
6976   *      -->P_LT_WBS_PRC  text
6977   *      -->P_LT_ORD_PRC  text
6978   *----------------------------------------------------------------------*
6979       FORM f_get_profit_ctr  USING    fp_t_gl      TYPE ty_t_gl
6980                              CHANGING fp_t_csks    TYPE ty_t_csks
6981                                       fp_t_wbs_prc TYPE ty_t_wbs_prc
6982                                       fp_t_ord_prc TYPE ty_t_ord_prc
6983                                       fp_t_svalue  TYPE rgsbv_tab.
6984
6985         DATA : ls_setid   TYPE setid.
6986
6987         CLEAR ls_setid.
6988   * Exceptional G/L for Profit center
6989         CALL FUNCTION 'G_SET_GET_ID_FROM_NAME'
6990           EXPORTING
6991             shortname = 'BDGL_INCOME_PROFIT'       "Set Name
6992           IMPORTING
6993             new_setid = ls_setid
6994           EXCEPTIONS
6995             OTHERS    = 1.
6996
6997         CALL FUNCTION 'G_SET_FETCH'
6998           EXPORTING
6999             setnr           = ls_setid
7000           TABLES
7001             set_lines_basic = fp_t_svalue
7002           EXCEPTIONS
7003             OTHERS          = 1.
7004
7005         IF fp_t_gl[] IS NOT INITIAL.
7006
7007   * Fetch profit center from WBS
7008           SELECT pspnr
7009                  pgsbr
7010                  prctr INTO TABLE fp_t_wbs_prc
7011                        FROM prps
7012                        FOR ALL ENTRIES IN fp_t_gl
7013                        WHERE pspnr = fp_t_gl-wbs.
7014           IF sy-subrc = 0.
7015             SORT fp_t_wbs_prc BY pspnr.
7016           ENDIF.
7017
7018   * Fetch profit center from Order
7019           SELECT aufnr
7020                  gsber
7021                  prctr INTO TABLE fp_t_ord_prc
7022                        FROM aufk
7023                        FOR ALL ENTRIES IN fp_t_gl
7024                        WHERE aufnr = fp_t_gl-aufnr.
7025           IF sy-subrc = 0.
7026             SORT fp_t_ord_prc BY aufnr.
7027           ENDIF.
7028
7029   * Fetch profit center from Cost Center
7030           fp_t_csks[] = gt_csks[].
7031           DELETE fp_t_csks WHERE datab > post_dt OR datbi < post_dt.
7032
7033         ENDIF.
7034
7035       ENDFORM.                    " F_GET_PROFIT_CTR
7036   *&---------------------------------------------------------------------*
7037   *&      Form  APPROVE_DATA
7038   *&---------------------------------------------------------------------*
7039   *       text
7040   *----------------------------------------------------------------------*
7041   *  -->  p1        text
7042   *  <--  p2        text
7043   *----------------------------------------------------------------------*
7044       FORM approve_data .
7045         CONSTANTS  : lc_que TYPE char1024 VALUE 'You are going to approve the request!             Do you want to continue?'.
7046
7047         DATA  : lv_answer TYPE char1.
7048         CLEAR lv_answer.
7049         CALL FUNCTION 'POPUP_TO_CONFIRM'
7050           EXPORTING
7051             titlebar              = 'Please Confirm'
7052             text_question         = lc_que
7053             text_button_1         = 'Yes'
7054             text_button_2         = 'No'
7055             display_cancel_button = abap_false
7056           IMPORTING
7057             answer                = lv_answer
7058           EXCEPTIONS
7059             text_not_found        = 1
7060             OTHERS                = 2.
7061         IF sy-subrc = 0 AND lv_answer = '1'.
7062           PERFORM expost.
7063           PERFORM save_data.
7064         ENDIF.
7065
7066       ENDFORM.                    " APPROVE_DATA
*--- End of ZBILL_POST_F01 - 7066 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CABAP                                   Level 1    Page 6
Object           ZBILL_PROCESS                             Lines 360
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:32
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
Object           ZBILL_PROCESS                             Lines 31
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:32
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
Object           ZBILL_PROCESS                             Lines 138
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:32
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
Object           ZBILL_PROCESS                             Lines 15
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:32
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
Generated incl.  %_CESP1                                   Level 1    Page 10
Object           ZBILL_PROCESS                             Lines 486
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:32
----------------------------------------------------------------------------------------------------
1      ************************************************************************
2      * Name     : ESP1
3      * Issue    : DD-Mon-YY - [ Name ] - TechniDATA GmbH/Markdorf
4      *
5      * Purpose  : Common type definitions for EH&S .........
6      *
7      * Changes  :
8      * [ Date  ] - [ Name    ] - [ Action                              ]
9      * 13.10.98    C5000678      Insert Types for Searchmode
10     * 13.10.98    C5000678      Insert Types for Daterange
11     * 13.10.98    C5000678      Insert Types for Val.Table incl. Daterange
12     * 20.01.99    msa            Insert types for Ltxt-Key-search
13     * 18.03.02    C5027806      Added Download, Upload, and Control to
14     *                           ESP1_C_ACTVT
15     * 13.03.2003  C5023441      added READ to ESP1_C_ACTVT
16     * 19.12.2005  C5035418      Added SEND to ESP1_C_ACTVT
17     ************************************************************************
18
19     TYPE-POOL ESP1 .
20
21     * general boolean type (compare include file CBUI09)
22     *TYPES: ESP1_BOOLEAN(1) TYPE C.
23     *TYPES: ESP1_BOOLEAN LIKE BOOLE-BOOLE.
24     TYPES: ESP1_BOOLEAN LIKE BAPISTDTYP-BOOLEAN.
25     CONSTANTS: ESP1_FALSE TYPE ESP1_BOOLEAN VALUE ' ',
26                ESP1_TRUE  TYPE ESP1_BOOLEAN VALUE 'X'.
27
28
29     * type of ok-code field
30     TYPES: ESP1_OKCODE_TYPE LIKE SY-UCOMM.
31
32
33     * types for f4-help-request
34     TYPES: BEGIN OF ESP1_F4_LENGTH_TYPE,
35              DATA_LEN       TYPE I,
36              VISIBLE_LEN    TYPE I,
37              ORIENTATION    TYPE C,        " 'l'eft or 'r'ight
38              HEADING(30)    TYPE C,
39              TAB_FIELD_NAME LIKE DD03L-FIELDNAME, " for sorting
40              COLUMN_START   TYPE I,
41              COLUMN_END     TYPE I,
42            END OF ESP1_F4_LENGTH_TYPE.
43
44     TYPES: ESP1_F4_LENGTH_TAB_TYPE TYPE ESP1_F4_LENGTH_TYPE
45                                    OCCURS 5.
46
47
48     * types for authority check
49     * activity
50     TYPES: ESP1_ACTVT_TYPE  LIKE TACTT-ACTVT.
51
52     CONSTANTS: BEGIN OF ESP1_C_ACTVT,
53         INITIAL TYPE ESP1_ACTVT_TYPE VALUE IS INITIAL,
54         SHOW    TYPE ESP1_ACTVT_TYPE VALUE '03',
55         CHANGE  TYPE ESP1_ACTVT_TYPE VALUE '02',
56         CREATE  TYPE ESP1_ACTVT_TYPE VALUE '01',
57         LOCK    TYPE ESP1_ACTVT_TYPE VALUE '05',
58         DELETE  TYPE ESP1_ACTVT_TYPE VALUE '06',
59         MAINT   TYPE ESP1_ACTVT_TYPE VALUE '23',
60         SEND    TYPE ESP1_ACTVT_TYPE VALUE '59',
61         IMPORT  TYPE ESP1_ACTVT_TYPE VALUE '60',
62         EXPORT  TYPE ESP1_ACTVT_TYPE VALUE '61',
63         SCHED   TYPE ESP1_ACTVT_TYPE VALUE '81',
64         REACT   TYPE ESP1_ACTVT_TYPE VALUE '91',
65         ALE     TYPE ESP1_ACTVT_TYPE VALUE 'A9',
66         CONTROL TYPE ESP1_ACTVT_TYPE VALUE '16',
67         DWNLOAD TYPE ESP1_ACTVT_TYPE VALUE 'DL',
68         UPLOAD  TYPE ESP1_ACTVT_TYPE VALUE 'UL',
69         READ    TYPE ESP1_ACTVT_TYPE VALUE '33',
70       END OF ESP1_C_ACTVT.
71
72     * constants for the EH&S-activity
73     CONSTANTS: BEGIN OF ESP1_ACTYPE,
74         INITIAL LIKE RCGDIALCTR-ACTYPE VALUE IS INITIAL, " (initial)
75         CREATE  LIKE RCGDIALCTR-ACTYPE VALUE 'C',        " create
76         CHANGE  LIKE RCGDIALCTR-ACTYPE VALUE 'E',        " change
77         SHOW    LIKE RCGDIALCTR-ACTYPE VALUE 'D',        " show
78         INFO    LIKE RCGDIALCTR-ACTYPE VALUE 'I',        " info system
79         SEND    LIKE RCGDIALCTR-ACTYPE VALUE 'S',        " send
80       END OF ESP1_ACTYPE.
81
82     * type for the lock-object-prefix-name
83     TYPES: ESP1_LOCK_OBJECT_PREFIX(4) TYPE C.
84
85     * type for the language (Because the type LIKE SY-LANGU
86     * does not provide a F4-help!)
87     *TYPES: ESP1_SPRAS LIKE T002T-SPRAS.
88     TYPES: ESP1_SPRAS LIKE ESTRI-LANGU.
89
90     * name-types for dynamic performs and calls
91     * (Rem.: Many useful fields and types for R/3-objects can be found
92     *  in the development classes SABP ('ABAP/4 Runtime Environment')
93     *  and SEU ('ABAP/4 Development Workbench'), or in all development
94     *  classes, whose names match with 'SE*'.)
95     TYPES: ESP1_FORM_NAME       TYPE EX_CPU_VAL, "see 40 in 487994
96     *       ESP1_FORM_NAME       LIKE RS38T-FORM_NAME,
97            ESP1_PROG_NAME       LIKE RS38M-PROGRAMM,
98            ESP1_FUNC_NAME       LIKE TFDIR-FUNCNAME,
99            ESP1_LOCK_OBJ        LIKE RSRD1-ENQU_VAL,
100           ESP1_TAB_NAME        LIKE DD02L-TABNAME,
101           ESP1_FIELD_NAME      LIKE DD03L-FIELDNAME,
102           ESP1_DYNP_NUM        LIKE D020S-DNUM,
103           ESP1_TAB_PAR_NAME    LIKE RS38L_PARA-TABLES,
104           ESP1_PROG_FIELD_NAME LIKE RFIELDLIST-NAME,
105           ESP1_CUA_STATE_NAME  LIKE RSEU1-STATUS,
106           ESP1_CUA_TITLE_NAME  LIKE RSEU1-TIT_CODE,
107           ESP1_TEXT_ELEMENT    LIKE RS38M-ITEX,
108           ESP1_STRING          LIKE ESTPP-PHRTEXT.
109
110    * structure for internal tables with field information /fieldnames)
111    TYPES: BEGIN OF ESP1_FIELDNAME_WA_TYPE,
112             FIELDNAME TYPE ESP1_FIELD_NAME,
113           END OF ESP1_FIELDNAME_WA_TYPE.
114
115    TYPES: ESP1_FIELDNAME_TAB_TYPE TYPE ESP1_FIELDNAME_WA_TYPE OCCURS 0.
116
117    * type for the position of a window
118    TYPES: ESP1_WINDOW_POSITION LIKE SY-WINX1.
119
120    * type for a table containing tablenames, fieldnames and values
121    TYPES: BEGIN OF ESP1_TABNAME_WA_TYPE,
122             TABNAME   LIKE DD02L-TABNAME,
123             FIELDNAME LIKE DD03L-FIELDNAME,
124             VALUE     LIKE CVDDP-VALUE,
125           END OF ESP1_TABNAME_WA_TYPE.
126    TYPES: ESP1_TABNAME_TAB_TYPE TYPE ESP1_TABNAME_WA_TYPE OCCURS 10.
127
128    * types for dynamic where-condition-tables
129    *TYPES: ESP1_CONDLINE_TYPE LIKE ABAPSOURCE. (= better alternative?)
130    TYPES: BEGIN OF ESP1_CONDLINE_TYPE,
131             LINE(72) TYPE C,
132           END OF ESP1_CONDLINE_TYPE.
133    TYPES: ESP1_CONDTAB_TYPE TYPE ESP1_CONDLINE_TYPE OCCURS 50.
134
135    * constant for the date with the initial value
136    * Begin Correction 19.07.2004 0753891 *******************
137    SET EXTENDED CHECK ON.
138    CONSTANTS: ESP1_INITIAL_DATE LIKE SY-DATUM VALUE IS INITIAL.
139    SET EXTENDED CHECK OFF.
140    * End Correction 19.07.2004 0753891 *********************
141
142    * constant for the record-number with the initial value
143    CONSTANTS: ESP1_INITIAL_RECN LIKE RCGUKEY-RECN VALUE IS INITIAL.
144
145    * type definitions for general set/get parameter archive library ------
146    TYPES: BEGIN OF ESP1_SGP_TCODE_WA_TYPE,
147        TCODE LIKE SY-TCODE,
148      END OF ESP1_SGP_TCODE_WA_TYPE.
149    TYPES: ESP1_SGP_TCODE_TAB_TYPE TYPE ESP1_SGP_TCODE_WA_TYPE OCCURS 20.
150
151    * value for dummy entry (to indicate empty set/get parameter)
152    CONSTANTS:
153      BEGIN OF ESP1_SGP_INITIAL,
154        TABLENAME  LIKE TCGSGP-TABLENAME  VALUE '(TABLE)',
155        FIELDNAME  LIKE TCGSGP-FIELDNAME  VALUE '(FIELD)',
156        VALUE      LIKE TCGSGP-VALUE      VALUE '(EMPTY)',
157      END OF ESP1_SGP_INITIAL.
158
159    * types for messages
160    TYPES: BEGIN OF ESP1_MESSAGE_WA_TYPE,
161             MSGID  LIKE SY-MSGID,
162             MSGTY  LIKE SY-MSGTY,
163             MSGNO  LIKE SY-MSGNO,
164             MSGV1  LIKE SY-MSGV1,
165             MSGV2  LIKE SY-MSGV2,
166             MSGV3  LIKE SY-MSGV3,
167             MSGV4  LIKE SY-MSGV4,
168             LINENO LIKE MESG-ZEILE,
169           END OF ESP1_MESSAGE_WA_TYPE.
170    TYPES: ESP1_MESSAGE_TAB_TYPE TYPE ESP1_MESSAGE_WA_TYPE OCCURS 20.
171
172    * type to maintain table-indexes
173    TYPES: BEGIN OF ESP1_TABIX_WA_TYPE,
174             TABIX LIKE SY-TABIX,
175           END OF ESP1_TABIX_WA_TYPE.
176    TYPES: ESP1_TABIX_HTAB_TYPE TYPE HASHED TABLE OF ESP1_TABIX_WA_TYPE
177                                WITH UNIQUE KEY TABIX
178                                INITIAL SIZE 100.
179
180    * type for modes, especially for the valuation check function
181    TYPES: ESP1_MODE_TYPE     TYPE C.
182
183    *
184    TYPES ESP1_STRING132_TYPE(132) TYPE C.
185
186    TYPES ESP1_STRING132_TAB_TYPE TYPE ESP1_STRING132_TYPE OCCURS 10.
187
188    TYPES: BEGIN OF ESP1_SUBST_PARAM_DESC_WA,
189             NAME(30)  TYPE C,
190             VALUE     TYPE ESP1_STRING,
191           END OF ESP1_SUBST_PARAM_DESC_WA,
192           ESP1_SUBST_PARAM_DESC_TAB_TYPE TYPE ESP1_SUBST_PARAM_DESC_WA
193                                     OCCURS 10.
194
195    TYPES: BEGIN OF ESP1_SUBST_PARAM_WA,
196             FIELD1 TYPE ESP1_STRING132_TYPE,
197             FIELD2 TYPE ESP1_STRING132_TYPE,
198             FIELD3 TYPE ESP1_STRING132_TYPE,
199             FIELD4 TYPE ESP1_STRING132_TYPE,
200             FIELD5 TYPE ESP1_STRING132_TYPE,
201           END OF ESP1_SUBST_PARAM_WA,
202           ESP1_SUBST_PARAM_TAB_TYPE TYPE ESP1_SUBST_PARAM_WA OCCURS 10.
203
204
205    * ehs version info type -----------------------------------------------
206    TYPES: ESP1_EHS_VERSION_INFO_TYPE(5) TYPE C.
207    * note: modifications also must be updated in the wwi-setup
208    * and in interface-classes.
209    CONSTANTS: BEGIN OF ESP1_C_EHS_VERSION,
210        ALASKA     TYPE ESP1_EHS_VERSION_INFO_TYPE VALUE '2.2b',
211        DELAWARE   TYPE ESP1_EHS_VERSION_INFO_TYPE VALUE '2.5a',
212        FINLAND    TYPE ESP1_EHS_VERSION_INFO_TYPE VALUE '2.5b',
213        FLORIDA    TYPE ESP1_EHS_VERSION_INFO_TYPE VALUE '2.7a',
214        GREENLAND  TYPE ESP1_EHS_VERSION_INFO_TYPE VALUE '2.7b',
215        CALIFORNIA TYPE ESP1_EHS_VERSION_INFO_TYPE VALUE '3.1',
216        ICELAND    TYPE ESP1_EHS_VERSION_INFO_TYPE VALUE '3.2',
217        HAWAII     TYPE ESP1_EHS_VERSION_INFO_TYPE VALUE '2004',
218        ARCTIC     TYPE ESP1_EHS_VERSION_INFO_TYPE VALUE '2005',
219        MADAGASCAR TYPE ESP1_EHS_VERSION_INFO_TYPE VALUE '2006',
220      END OF ESP1_C_EHS_VERSION.
221
222
223    * ehs application identification --------------------------------------
224
225    * type and constants for the ranges of applications of the EH&S-system
226    TYPES: ESP1_APPL_RANGE_TYPE(30) TYPE C.
227    CONSTANTS: BEGIN OF ESP1_C_APPL_RANGE,
228    *            the whole EH&S
229                 GENERAL       TYPE ESP1_APPL_RANGE_TYPE
230                               VALUE 'GENERAL',                 "#EC NOTEXT
231    *            specification-management
232                 SUBSTANCE     TYPE ESP1_APPL_RANGE_TYPE
233                               VALUE 'SUBSTANCE',               "#EC NOTEXT
234    *            import/export
235                 DATA_TRANSFER TYPE ESP1_APPL_RANGE_TYPE
236                               VALUE 'DATA_TRANSFER',           "#EC NOTEXT
237    *            (obsolet) classification-key
238                 CLASSIF_KEY   TYPE ESP1_APPL_RANGE_TYPE
239                               VALUE 'CLASSIF_KEY',             "#EC NOTEXT
240    *            <next application range>
241    *            ...           TYPE ESP1_APPL_RANGE_TYPE
242    *                          VALUE '...',           "#EC NOTEXT
243               END OF ESP1_C_APPL_RANGE.
244
245
246    * type of/constants for application in TCG03 (buffer meta dictionary)
247    TYPES:
248      ESP1_APPLICATION_TYPE TYPE TCG03-APPL.
249
250    CONSTANTS:
251      BEGIN OF ESP1_C_APPLICATION_TYPE,
252        SUBSTANCE  TYPE ESP1_APPLICATION_TYPE  VALUE 'STST',    "#EC NOTEXT
253        PHRASE     TYPE ESP1_APPLICATION_TYPE  VALUE 'PHRS',    "#EC NOTEXT
254        REPORT     TYPE ESP1_APPLICATION_TYPE  VALUE 'BERW',    "#EC NOTEXT
255        IMPEXP     TYPE ESP1_APPLICATION_TYPE  VALUE 'IMEX',    "#EC NOTEXT
256        IHYGIENE   TYPE ESP1_APPLICATION_TYPE  VALUE 'IHS',     "#EC NOTEXT
257        APPL_SCOPE TYPE ESP1_APPLICATION_TYPE  VALUE 'ASCP',    "#EC NOTEXT
258      END OF ESP1_C_APPLICATION_TYPE.
259
260
261    *** Search including usage check                 " <<< C5000678 25.11.98
262
263    * fields necessary for usage check
264    TYPES: BEGIN OF ESP1_ESTVA_UC_TYPE,
265             RECN     LIKE ESTVA-RECN,
266             RECNROOT LIKE ESTVA-RECNROOT,
267           END   OF ESP1_ESTVA_UC_TYPE.
268
269    * table for usage check
270    TYPES: ESP1_ESTVA_UC_TAB_TYPE TYPE ESP1_ESTVA_UC_TYPE OCCURS 10.
271
272    * fields necessary for usage check
273    TYPES: BEGIN OF ESP1_ESTVA_FRTO_UC_TYPE,
274             RECN     LIKE ESTVA-RECN,
275             RECNROOT LIKE ESTVA-RECNROOT.
276            INCLUDE STRUCTURE RCGDATERANGE.
277    TYPES: END OF ESP1_ESTVA_FRTO_UC_TYPE.
278
279    * table for usage check
280    TYPES: ESP1_ESTVA_FRTO_UC_TAB_TYPE
281                              TYPE ESP1_ESTVA_FRTO_UC_TYPE OCCURS 10.
282
283
284    *** Searchmode                                   " <<< C5000678 13.10.98
285
286    * Searchmode for time interval search ('Historic Data')
287    TYPES: ESP1_SEARCHMODE_TYPE LIKE RCGSELSCR-SEARCHMODE.
288
289    * Searchmode: Legal Values
290    CONSTANTS: BEGIN OF ESP1_SEARCHMODE,
291                 INITIAL TYPE ESP1_SEARCHMODE_TYPE VALUE ' ',
292                 WEAK    TYPE ESP1_SEARCHMODE_TYPE VALUE 'w',
293                 MEDIUM  TYPE ESP1_SEARCHMODE_TYPE VALUE 'm',
294                 STRONG  TYPE ESP1_SEARCHMODE_TYPE VALUE 's',
295               END OF ESP1_SEARCHMODE.
296
297    * Searchmode: Shortcut for initial value
298    CONSTANTS: ESP1_SRCHMD_INIT TYPE ESP1_SEARCHMODE_TYPE
299                 VALUE ESP1_SEARCHMODE-INITIAL.
300
301    *** Flat Tables including daterange for SELECTs ---------------------- *
302
303    *** Daterange                                    " <<< C5000678 13.10.98
304
305    * Type "Daterange"
306    TYPES: BEGIN OF ESP1_DATERANGE_TYPE.
307            INCLUDE STRUCTURE RCGDATERANGE.
308    TYPES: END   OF ESP1_DATERANGE_TYPE.
309
310    * Internal Table "Daterange"
311    TYPES: ESP1_DATERANGE_TAB_TYPE TYPE ESP1_DATERANGE_TYPE OCCURS 10.
312
313
314    * Time Interval Search: Basics (Ltxt-Key)              <<< msa 20.01.99
315    TYPES: BEGIN OF ESP1_FRTO_LTXTKEY_TYPE.
316            INCLUDE STRUCTURE RCGLTXTKEY.
317            INCLUDE STRUCTURE RCGDATERANGE.
318    TYPES: END OF ESP1_FRTO_LTXTKEY_TYPE.
319
320    * Internal Table for Searching a Time Interval: Basics (Ltxt-Key)
321    TYPES: ESP1_FRTO_LTXTKEY_TAB_TYPE TYPE ESP1_FRTO_LTXTKEY_TYPE OCCURS 10.
322
323
324    * 3-dimensional tables including daterange for resulting hit tables -- *
325    * Note: these tables employ the infix 'frto' ------------------------- *
326
327    *** Material                                     " <<< C5000678 19.11.98
328
329    * Time Interval Search: Material
330    TYPES: BEGIN OF ESP1_FRTO_MAT_TYPE,
331             RECNROOT  LIKE  ESTRH-RECN,
332             FRTO_TAB  TYPE  ESP1_DATERANGE_TAB_TYPE,
333             MATNR     LIKE  MARA-MATNR,
334             MAKTX     LIKE  MAKT-MAKTX,
335           END OF ESP1_FRTO_MAT_TYPE.
336
337    * Internal Table for Searching a Time Interval: Material
338    TYPES: ESP1_FRTO_MAT_TAB_TYPE TYPE ESP1_FRTO_MAT_TYPE OCCURS 10.
339
340
341    *** Status
342
343    * Time Interval Search: Status
344    TYPES: BEGIN OF ESP1_FRTO_STAT_TYPE,
345    *         RECNROOT  LIKE  ESTST-RECN,
346             RECNROOT  LIKE  EHSBT_APPL_SCOPE-RECN,
347             FRTO_TAB  TYPE  ESP1_DATERANGE_TAB_TYPE,
348    *         VACLID    LIKE  ESTST-VACLID,
349             VACLID    LIKE  EHSBT_APPL_SCOPE-VACLID,
350    *         RVLID     LIKE  ESTST-RVLID,
351             RVLID     LIKE  EHSBT_APPL_SCOPE-RVLID,
352           END OF ESP1_FRTO_STAT_TYPE.
353
354    * Internal Table for Searching a Time Interval: Status
355    TYPES: ESP1_FRTO_STAT_TAB_TYPE TYPE ESP1_FRTO_STAT_TYPE OCCURS 10.
356
357    *** Ident
358    * Time Interval Search: Ident
359    TYPES: BEGIN OF ESP1_FRTO_IDENT_TYPE,
360             RECN      LIKE  ESTRH-RECN,
361             FRTO_TAB  TYPE  ESP1_DATERANGE_TAB_TYPE,
362             AUTHGRP   LIKE  RCGIDENT-AUTHGRP,
363             POS       LIKE  RCGIDENT-POS,
364             COUNTER   LIKE  RCGIDENT-COUNTER,
365             LANGU     LIKE  RCGIDENT-LANGU,
366             IDTYPE    LIKE  RCGIDENT-IDTYPE,
367             IDCAT     LIKE  RCGIDENT-IDCAT,
368             IDENT     LIKE  RCGIDENT-IDENT,
369             MATINFO   LIKE  RCGIDENT-MATINFO,
370    * Begin Correction 15.07.2004 0753891 *******************
371             RI_RECN   LIKE  RCGIDENT-RI_RECN,
372    * End Correction 15.07.2004 0753891 *********************
373           END OF ESP1_FRTO_IDENT_TYPE.
374
375    * Internal Table for Searching a Time Interval: Ident
376    TYPES: ESP1_FRTO_IDENT_TAB_TYPE TYPE ESP1_FRTO_IDENT_TYPE OCCURS 10.
377
378    *** HEAD
379    * Time Interval Search: Head (authgrp)
380    TYPES: BEGIN OF ESP1_FRTO_AUTHGRP_TYPE,
381             RECN      LIKE ESTRH-RECN,
382             AUTHGRP   LIKE ESTRH-AUTHGRP,
383             FRTO_TAB  TYPE  ESP1_DATERANGE_TAB_TYPE,
384           END OF ESP1_FRTO_AUTHGRP_TYPE.
385
386    * Internal Table for Searching a Time Interval: Head (authgrp)
387    TYPES: ESP1_FRTO_AUTHGRP_TAB_TYPE TYPE ESP1_FRTO_AUTHGRP_TYPE OCCURS 10.
388
389
390    *** Basic Form - used for Substance List / Extended Search / Result Tabl
391
392    * Time Interval Search: Basic Form (Recn & daterange)
393    TYPES: BEGIN OF ESP1_FRTO_RECN_TYPE,
394             RECN      LIKE  ESTRH-RECN,
395             FRTO_TAB  TYPE  ESP1_DATERANGE_TAB_TYPE,
396           END OF ESP1_FRTO_RECN_TYPE.
397
398    * Internal Table for Searching a Time Interval: Basic Form
399    TYPES: ESP1_FRTO_RECN_TAB_TYPE TYPE ESP1_FRTO_RECN_TYPE OCCURS 1.
400
401
402    * Time Interval Search:  Referencing subs (Recn & recnref & daterange)
403    TYPES: BEGIN OF ESP1_FRTO_RECNREF_TYPE,
404             RECNREF   LIKE  ESTRR-RECNREF,
405             RECNROOT  LIKE  ESTRR-RECNROOT,
406             FRTO_TAB  TYPE  ESP1_DATERANGE_TAB_TYPE,
407           END OF ESP1_FRTO_RECNREF_TYPE.
408
409    * Internal Table for Searching a Time Interval: Referencing subs
410    TYPES: ESP1_FRTO_RECNREF_TAB_TYPE TYPE ESP1_FRTO_RECNREF_TYPE OCCURS 1.
411
412
413    *<<< msa
414    * Time Interval Search: extended search functions (user exits)
415    *                       Basic Form (Recn & HitInfo & daterange)
416    *types: begin of esp1_frto_hitinfo_type.
417    *         include  structure  rcghitinfo.
418    *types:   frto_tab type       esp1_daterange_tab_type.
419    *types: end of esp1_frto_hitinfo_type.
420    *
421    * Internal Table for Searching a Time Interval: Basic Form
422    *types: esp1_frto_hitinfo_tab_type type esp1_frto_hitinfo_type occurs 1.
423
424
425    *** Valuation                                    " <<< C5000678 13.10.98
426
427    * Time Interval Search: Valuation
428    TYPES: BEGIN OF ESP1_FRTO_ESTVA_TYPE,
429             RECN      LIKE  ESTRH-RECN,
430             FRTO_TAB  TYPE  ESP1_DATERANGE_TAB_TYPE,
431             RECNROOT  LIKE  ESTVA-RECNROOT,
432             RECNTVH   LIKE  ESTVA-RECNTVH,
433             ORD       LIKE  ESTVA-ORD,
434             COMPREL   LIKE  ESTVA-COMPREL,
435           END   OF ESP1_FRTO_ESTVA_TYPE.
436
437    * Internal Table for Searching a Time Interval: Valuation
438    TYPES: ESP1_FRTO_ESTVA_TAB_TYPE TYPE ESP1_FRTO_ESTVA_TYPE OCCURS 10.
439
440
441    * Internal table for searching a time interval: Valuation
442    *
443    TYPES: BEGIN OF ESP1_FRTO_ESTCAT_TYPE,
444             RECN      LIKE      ESTRH-RECN,
445             FRTO_TAB  TYPE      ESP1_DATERANGE_TAB_TYPE,
446             ESTCAT    LIKE      TCG11-ESTCAT,
447           END OF ESP1_FRTO_ESTCAT_TYPE.
448    TYPES: ESP1_FRTO_ESTCAT_TAB_TYPE TYPE ESP1_FRTO_ESTCAT_TYPE OCCURS 10.
449
450    * Time Interval Search:  Referencing subs (Recn & recnref & daterange)
451    TYPES: BEGIN OF ESP1_FRTO_INDIRECT_TYPE,
452             RECN      LIKE      ESTRH-RECNROOT,
453             FRTO_TAB  TYPE      ESP1_DATERANGE_TAB_TYPE,
454             RECNREF   LIKE      ESTRR-RECNREF,
455             ESTCAT     LIKE TCG11-ESTCAT,
456    *          include  type      esprh_usage_info_type,
457           END OF ESP1_FRTO_INDIRECT_TYPE.
458    TYPES: ESP1_FRTO_INDIRECT_TAB_TYPE
459                       TYPE ESP1_FRTO_INDIRECT_TYPE OCCURS 10.
460
461
462    * one line of the where-used list
463    TYPES: BEGIN OF ESP1_FRTO_USAGE_TYPE,
464    *        record-no. of the used substance
465             RECN      LIKE ESTRH-RECN,
466    *        record-no. of the using substance
467             RECN_USER LIKE ESTRH-RECN,
468             FRTO_TAB  TYPE      ESP1_DATERANGE_TAB_TYPE,
469    *        additional informations about the usage
470    * include  type      esprh_usage_info_type.
471    *        component category
472             COMPCAT    LIKE ESTVP-COMPCAT,
473    *        precision and value of lower limit of component concentration
474             PRECL      LIKE ESTVP-PRECL,
475             COMPLOW    LIKE ESTVP-COMPLOW,
476    *        precision and value of upper limit of component concentration
477             PRECU      LIKE ESTVP-PRECU,
478             COMPUPP    LIKE ESTVP-COMPUPP,
479    *        (average) value of component concentration
480             COMPAVG    LIKE ESTVP-COMPAVG,
481    *        exponent / unit of above values
482             COMPEXP    LIKE ESTVP-COMPEXP,
483           END OF ESP1_FRTO_USAGE_TYPE.
484
485    * the where-used list
486    TYPES: ESP1_FRTO_USAGE_TAB_TYPE TYPE ESP1_FRTO_USAGE_TYPE OCCURS 100.
*--- End of %_CESP1 - 486 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CICON                                   Level 1    Page 11
Object           ZBILL_PROCESS                             Lines 1246
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:32
----------------------------------------------------------------------------------------------------
1      TYPE-POOL ICON.
2      INCLUDE >ICON<.
3      *
4      *                     DEFINITION OF ICONS
5      *
6      *Icon_Length                           ID
7      *      Name                                     Quickinfo
8      ICON_2 ICON_DUMMY                     '@00@'."  PlaceholderIcon
9      ICON_2 ICON_CHECKED                   '@01@'."  Checked; OK
10     ICON_2 ICON_INCOMPLETE                '@02@'."  Incomplete
11     ICON_2 ICON_FAILURE                   '@03@'."  Failed
12     ICON_2 ICON_POSITIVE                  '@04@'."  Positive
13     ICON_2 ICON_NEGATIVE                  '@05@'."  Negative
14     ICON_2 ICON_LOCKED                    '@06@'."  Locked
15     ICON_2 ICON_UNLOCKED                  '@07@'."  Free; unlock
16     ICON_4 ICON_GREEN_LIGHT               '@08@'."  Green light; positive
17     ICON_4 ICON_YELLOW_LIGHT              '@09@'."  Yellow light; neutral
18     ICON_4 ICON_RED_LIGHT                 '@0A@'."  Red light; negative
19     ICON_2 ICON_TOTAL_LEFT                '@0B@'."  Extreme left; first ...
20     ICON_2 ICON_TOTAL_RIGHT               '@0C@'."  Extreme right; last ...
21     ICON_2 ICON_COLUMN_LEFT               '@0D@'."  Column left; previous ..
22     ICON_2 ICON_COLUMN_RIGHT              '@0E@'."  Column right; next ...
23     ICON_2 ICON_PAGE_RIGHT                '@0F@'."  Page right
24     ICON_2 ICON_PAGE_LEFT                 '@0G@'."  Page left
25     ICON_2 ICON_PREVIOUS_VALUE            '@0H@'."  Previous value; next ent
26     ICON_2 ICON_NEXT_VALUE                '@0I@'."  Next value; previous ent
27     ICON_2 ICON_ANNOTATION                '@0J@'."  Note; remark
28     ICON_2 ICON_CREATE_NOTE               '@0K@'."  Create note
29     ICON_2 ICON_DISPLAY_NOTE              '@0L@'."  Display note
30     ICON_2 ICON_CALCULATION               '@0M@'."  Costing
31     ICON_2 ICON_GRAPHICS                  '@0N@'."  Graphics
32     ICON_2 ICON_CREATE_TEXT               '@0O@'."  Create text
33     ICON_2 ICON_DISPLAY_TEXT              '@0P@'."  Display text
34     ICON_2 ICON_CHANGE_TEXT               '@0Q@'."  Text
35     ICON_2 ICON_VARIANTS                  '@0R@'."  Variants
36     ICON_2 ICON_INFORMATION               '@0S@'."  Information
37     ICON_2 ICON_ADDRESS                   '@0T@'."  Address
38     ICON_2 ICON_VIEWER_OPTICAL_ARCHIVE    '@0U@'."  Optical archive viewer
39     ICON_2 ICON_OKAY                      '@0V@'."  OK; Continue; Choose <va
40     ICON_2 ICON_CANCEL                    '@0W@'."  Cancel
41     ICON_2 ICON_PRINT                     '@0X@'."  Print
42     ICON_2 ICON_CREATE                    '@0Y@'."  Create
43     ICON_2 ICON_CHANGE                    '@0Z@'."  Change
44     ICON_2 ICON_DISPLAY                   '@10@'."  Display
45     ICON_2 ICON_DELETE                    '@11@'."  Delete
46     ICON_2 ICON_TEST                      '@12@'."  Test
47     ICON_2 ICON_SEARCH                    '@13@'."  Find
48     ICON_2 ICON_COPY_OBJECT               '@14@'."  Copy <object>
49     ICON_2 ICON_EXECUTE_OBJECT            '@15@'."  Execute <object>
50     ICON_2 ICON_SELECT_DETAIL             '@16@'."  Choose detail; detail sc
51     ICON_2 ICON_INSERT_ROW                '@17@'."  Insert line
52     ICON_2 ICON_DELETE_ROW                '@18@'."  Delete line
53     ICON_4 ICON_MESSAGE_INFORMATION       '@19@'."  Information message
54     ICON_4 ICON_MESSAGE_WARNING           '@1A@'."  Warning
55     ICON_4 ICON_MESSAGE_ERROR             '@1B@'."  Error message
56     ICON_4 ICON_MESSAGE_QUESTION          '@1C@'."  Question
57     ICON_4 ICON_MESSAGE_CRITICAL          '@1D@'."  Critical message
58     ICON_2 ICON_DISPLAY_MORE              '@1E@'."  Display/change more
59     ICON_2 ICON_ENTER_MORE                '@1F@'."  Create more
60     ICON_2 ICON_EQUAL                     '@1G@'."  Equal
61     ICON_2 ICON_NOT_EQUAL                 '@1H@'."  Not equal
62     ICON_2 ICON_GREATER                   '@1I@'."  Greater
63     ICON_2 ICON_LESS                      '@1J@'."  Less
64     ICON_2 ICON_GREATER_EQUAL             '@1K@'."  Greater/equal
65     ICON_2 ICON_LESS_EQUAL                '@1L@'."  Less than/equal
66     ICON_2 ICON_INTERVAL_INCLUDE          '@1M@'."  Include range
67     ICON_2 ICON_INTERVAL_EXCLUDE          '@1N@'."  Exclude range
68     ICON_2 ICON_PATTERN_INCLUDE           '@1O@'."  Include pattern
69     ICON_2 ICON_PATTERN_EXCLUDE           '@1P@'."  Exclude pattern
70     ICON_2 ICON_PHONE                     '@1Q@'."  Telephone number
71     ICON_2 ICON_FAX                       '@1R@'."  Fax number
72     ICON_2 ICON_MAIL                      '@1S@'."  Send message; mail
73     ICON_2 ICON_TIME                      '@1T@'."  Time
74     ICON_2 ICON_DATE                      '@1U@'."  Date
75     ICON_2 ICON_ALARM                     '@1V@'."  Alarm
76     ICON_2 ICON_PROSHARE                  '@1W@'."  Per share
77     ICON_2 ICON_VIDEO                     '@1X@'."  Video
78     ICON_2 ICON_VOICE_INPUT               '@1Y@'."  Language input
79     ICON_2 ICON_VOICE_OUTPUT              '@1Z@'."  Language output
80     ICON_2 ICON_EQUAL_GREEN               '@20@'."  Select: Equal
81     ICON_2 ICON_NOT_EQUAL_GREEN           '@21@'."  Select: Not equal
82     ICON_2 ICON_GREATER_GREEN             '@22@'."  Select: Greater than
83     ICON_2 ICON_LESS_GREEN                '@23@'."  Select: Less than
84     ICON_2 ICON_GREATER_EQUAL_GREEN       '@24@'."  Select: Greater than or
85     ICON_2 ICON_LESS_EQUAL_GREEN          '@25@'."  Select: Less than or equ
86     ICON_2 ICON_INTERVAL_INCLUDE_GREEN    '@26@'."  Select: Include range
87     ICON_2 ICON_INTERVAL_EXCLUDE_GREEN    '@27@'."  Select: Exclude range
88     ICON_2 ICON_PATTERN_INCLUDE_GREEN     '@28@'."  Select: Include pattern
89     ICON_2 ICON_PATTERN_EXCLUDE_GREEN     '@29@'."  Select: Exclude pattern
90     ICON_2 ICON_EQUAL_RED                 '@2A@'."  Do not select: Equal
91     ICON_2 ICON_NOT_EQUAL_RED             '@2B@'."  Do not select: Not equal
92     ICON_2 ICON_GREATER_RED               '@2C@'."  Do not select: Greater t
93     ICON_2 ICON_LESS_RED                  '@2D@'."  Do not select: Less than
94     ICON_2 ICON_GREATER_EQUAL_RED         '@2E@'."  Do not select: Greater/e
95     ICON_2 ICON_LESS_EQUAL_RED            '@2F@'."  Do not select: Less than
96     ICON_2 ICON_INTERVAL_INCLUDE_RED      '@2G@'."  Do not select: Include r
97     ICON_2 ICON_INTERVAL_EXCLUDE_RED      '@2H@'."  Do not select: Exclude r
98     ICON_2 ICON_PATTERN_INCLUDE_RED       '@2I@'."  Do not select: Include p
99     ICON_2 ICON_PATTERN_EXCLUDE_RED       '@2J@'."  Do not select: Exclude p
100    ICON_2 ICON_SYSTEM_OKAY               '@2K@'."  OK
101    ICON_2 ICON_SYSTEM_SAVE               '@2L@'."  Save
102    ICON_2 ICON_SYSTEM_BACK               '@2M@'."  Back
103    ICON_2 ICON_SYSTEM_END                '@2N@'."  Exit
104    ICON_2 ICON_SYSTEM_CANCEL             '@2O@'."  Cancel
105    ICON_2 ICON_SYSTEM_PRINT              '@2P@'."  Print
106    ICON_2 ICON_OTHER_OBJECT              '@2Q@'."  Other <object>
107    ICON_2 ICON_PREVIOUS_OBJECT           '@2R@'."  Previous screen
108    ICON_2 ICON_NEXT_OBJECT               '@2S@'."  Next screen
109    ICON_2 ICON_SYSTEM_CUT                '@2T@'."  Cut
110    ICON_2 ICON_SYSTEM_COPY               '@2U@'."  Copy
111    ICON_2 ICON_SYSTEM_PASTE              '@2V@'."  Paste
112    ICON_2 ICON_SYSTEM_UNDO               '@2W@'."  Undo
113    ICON_2 ICON_SYSTEM_MARK               '@2X@'."  Select mode; select
114    ICON_2 ICON_FIRST_PAGE                '@2Y@'."  First page
115    ICON_2 ICON_PREVIOUS_PAGE             '@2Z@'."  Prev. page
116    ICON_2 ICON_NEXT_PAGE                 '@30@'."  Next page
117    ICON_2 ICON_LAST_PAGE                 '@31@'."  Last page
118    ICON_2 ICON_SYSTEM_MODUS_CREATE       '@32@'."  Create session
119    ICON_2 ICON_SYSTEM_MODUS_DELETE       '@33@'."  Delete session
120    ICON_2 ICON_SYSTEM_USERMENU           '@34@'."  Session Manager
121    ICON_2 ICON_SYSTEM_HELP               '@35@'."  Help
122    ICON_2 ICON_TABLE_SETTINGS            '@36@'."  Report-report call
123    ICON_2 ICON_REPLACE                   '@37@'."  Replace
124    ICON_2 ICON_CHECK                     '@38@'."  Check
125    ICON_2 ICON_GENERATE                  '@39@'."  Generate
126    ICON_2 ICON_REFERENCE_LIST            '@3A@'."  Where-used list
127    ICON_2 ICON_STACK                     '@3B@'."  Stack
128    ICON_2 ICON_ACTIVATE                  '@3C@'."  Activate
129    ICON_2 ICON_ICON_LIST                 '@3D@'."  Icon list; key
130    ICON_2 ICON_SORT_UP                   '@3E@'."  Sort in ascending order
131    ICON_2 ICON_SORT_DOWN                 '@3F@'."  Sort in descending order
132    ICON_2 ICON_LAYOUT_CONTROL            '@3G@'."  Page view
133    ICON_2 ICON_CONVERT                   '@3H@'."  Convert
134    ICON_2 ICON_TOGGLE_DISPLAY_CHANGE     '@3I@'."  Display <-> Change
135    ICON_2 ICON_SET_STATE                 '@3J@'."  Set status
136    ICON_2 ICON_PREVIOUS_NODE             '@3K@'."  Previous node
137    ICON_2 ICON_NEXT_NODE                 '@3L@'."  Next node
138    ICON_2 ICON_TREE                      '@3M@'."  Hierarchy
139    ICON_2 ICON_INSERT_RELATION           '@3N@'."  Insert dependency
140    ICON_2 ICON_FINAL_DATE                '@3O@'."  End date
141    ICON_2 ICON_HEADER                    '@3P@'."  Header; basic data
142    ICON_2 ICON_OVERVIEW                  '@3Q@'."  Overview; overview; list
143    ICON_2 ICON_DETAIL                    '@3R@'."  Detail view
144    ICON_2 ICON_EXPAND                    '@3S@'."  Expand; enlarge
145    ICON_2 ICON_COLLAPSE                  '@3T@'."  Compress; reduce
146    ICON_2 ICON_BREAKPOINT                '@3U@'."  Breakpoint
147    ICON_2 ICON_FOREIGN_KEY               '@3V@'."  Foreign key
148    ICON_2 ICON_LIST                      '@3W@'."  List
149    ICON_2 ICON_CLOSE                     '@3X@'."  Close
150    ICON_2 ICON_POSITION                  '@3Y@'."  Position; other entry
151    ICON_2 ICON_SUM                       '@3Z@'."  Sum
152    ICON_2 ICON_MOVE                      '@40@'."  Move
153    ICON_2 ICON_RETRIEVE                  '@41@'."  Restore
154    ICON_2 ICON_REFRESH                   '@42@'."  Refresh
155    ICON_2 ICON_SKIP                      '@43@'."  Skip
156    ICON_2 ICON_SYSTEM_SETTINGS           '@44@'."  User settings
157    ICON_2 ICON_TOOLS                     '@45@'."  Tools
158    ICON_2 ICON_COMPARE                   '@46@'."  Compare
159    ICON_2 ICON_SHORT_MESSAGE             '@47@'."  Short message
160    ICON_2 ICON_IMPORT                    '@48@'."  Import
161    ICON_2 ICON_EXPORT                    '@49@'."  Export
162    ICON_2 ICON_TRANSPORT                 '@4A@'."  Transport
163    ICON_2 ICON_SELECT_ALL                '@4B@'."  Select all
164    ICON_2 ICON_SELECT_BLOCK              '@4C@'."  Select block
165    ICON_2 ICON_DESELECT_ALL              '@4D@'."  Deselect all
166    ICON_2 ICON_SEARCH_NEXT               '@4E@'."  Continue search
167    ICON_2 ICON_RENAME                    '@4F@'."  Rename
168    ICON_2 ICON_FILTER                    '@4G@'."  Filter
169    ICON_2 ICON_NEXT_HIERARCHY_LEVEL      '@4H@'."  Next hierarchy level
170    ICON_2 ICON_PREVIOUS_HIERARCHY_LEVEL  '@4I@'."  Previous hierarchy level
171    ICON_2 ICON_SYSTEM_POSSIBLE_ENTRIES   '@4J@'."  Possible entries
172    ICON_2 ICON_INTENSIFY                 '@4K@'."  Emphasize
173    ICON_2 ICON_PERSONAL_HELP             '@4L@'."  Individual help
174    ICON_2 ICON_VARIABLE                  '@4M@'."  Variable
175    ICON_2 ICON_SYSTEM_LOCAL_CUT          '@4N@'."  Cut (local)
176    ICON_2 ICON_SYSTEM_LOCAL_COPY         '@4O@'."  Copy (local)
177    ICON_2 ICON_SYSTEM_LOCAL_PASTE        '@4P@'."  Paste (local)
178    ICON_2 ICON_SYSTEM_LOCAL_MARK         '@4Q@'."  Selection mode (local)
179    ICON_2 ICON_SYSTEM_REDO               '@4R@'."  Repeat
180    ICON_2 ICON_BUSINAV_PROCESS           '@4S@'."  Process
181    ICON_2 ICON_BUSINAV_PROCESSMATRIX     '@4T@'."  Proc. sel. matrix
182    ICON_2 ICON_BUSINAV_SYSORGI           '@4U@'."  System chart
183    ICON_2 ICON_BUSINAV_SZENARIO          '@4V@'."  Scenario
184    ICON_2 ICON_BUSINAV_OBJECTS           '@4W@'."  Business objects
185    ICON_2 ICON_BUSINAV_INFODIAG          '@4X@'."  Info flow diagram
186    ICON_2 ICON_BUSINAV_ENTITY            '@4Y@'."  Entity type
187    ICON_2 ICON_BUSINAV_PROC_EXIST        '@4Z@'."  Process exists
188    ICON_2 ICON_BUSINAV_COMMDIAG          '@50@'."  Communication diagram
189    ICON_2 ICON_BUSINAV_DATAMODEL         '@51@'."  Data model
190    ICON_2 ICON_ALIGN                     '@52@'."  Align
191    ICON_2 ICON_CUT_RELATION              '@53@'."  Cancel link
192    ICON_2 ICON_FIX_COLUMN                '@54@'."  Fix columns
193    ICON_2 ICON_RELEASE_COLUMN            '@55@'."  Cancel column fix
194    ICON_2 ICON_NET_GRAPHIC               '@56@'."  Network graphics
195    ICON_2 ICON_PLANNING_TABLE            '@57@'."  Bar chart graphic; plan.
196    ICON_2 ICON_PERIOD                    '@58@'."  Period screen; time brea
197    ICON_2 ICON_ZOOM_IN                   '@59@'."  Maximize objects
198    ICON_2 ICON_ZOOM_OUT                  '@5A@'."  Minimize objects
199    ICON_2 ICON_LED_GREEN                 '@5B@'."  Go
200    ICON_2 ICON_LED_RED                   '@5C@'."  Stop
201    ICON_2 ICON_LED_YELLOW                '@5D@'."  Stop
202    ICON_2 ICON_SYSTEM_EXTENDED_HELP      '@5E@'."  Stop
203    ICON_2 ICON_SPACE                     '@5F@'."  Stop
204    ICON_2 ICON_BUSINAV_VALUE_CHAIN       '@5G@'."  Stop
205    ICON_2 ICON_WORKFLOW_ACTIVITY         '@5H@'."  Stop
206    ICON_2 ICON_WORKFLOW_CONDITION        '@5I@'."  Stop
207    ICON_2 ICON_WORKFLOW_DECISION         '@5J@'."  Stop
208    ICON_2 ICON_WORKFLOW_CONT_OPERATION   '@5K@'."  Stop
209    ICON_2 ICON_WORKFLOW_EXTERNAL_EVENT   '@5L@'."  Stop
210    ICON_2 ICON_WORKFLOW_INTERNAL_EVENT   '@5M@'."  Stop
211    ICON_2 ICON_WORKFLOW_MULT_CONDITION   '@5N@'."  Stop
212    ICON_2 ICON_WORKFLOW_FORK             '@5O@'."  Stop
213    ICON_2 ICON_WORKFLOW_EVENT_PRODUCER   '@5P@'."  Stop
214    ICON_2 ICON_WORKFLOW_FLOW_OF_CONTROL  '@5Q@'."  Stop
215    ICON_2 ICON_WORKFLOW_INDEFINITE_STEP  '@5R@'."  Stop
216    ICON_2 ICON_WORKFLOW_UNTIL            '@5S@'."  Stop
217    ICON_2 ICON_WORKFLOW_WAIT_FOR_EVENTS  '@5T@'."  Stop
218    ICON_2 ICON_WORKFLOW_WHILE            '@5U@'."  Stop
219    ICON_2 ICON_INTERMEDIATE_SUM          '@5V@'."  Stop
220    ICON_2 ICON_EMPLOYEE                  '@5W@'."  Stop
221    ICON_2 ICON_TIME_ZONE                 '@5X@'."  Stop
222    ICON_2 ICON_RELEASE                   '@5Y@'."  Stop
223    ICON_2 ICON_QUALIFY                   '@5Z@'."  Stop
224    ICON_2 ICON_ISO_CODE                  '@60@'."  Stop
225    ICON_2 ICON_MODIFY                    '@61@'."  Stop
226    ICON_2 ICON_GET_AREA                  '@62@'."  Stop
227    ICON_2 ICON_INTERFACE                 '@63@'."  Stop
228    ICON_2 ICON_ROUTING_OPERATION         '@64@'."  Stop
229    ICON_2 ICON_ROUTING_REF_OPERATION     '@65@'."  Stop
230    ICON_2 ICON_ROUTING_TASK              '@66@'."  Stop
231    ICON_2 ICON_ROUTING_TODO              '@67@'."  Stop
232    ICON_2 ICON_EXPAND_ALL                '@68@'."  Stop
233    ICON_2 ICON_COLLAPSE_ALL              '@69@'."  Stop
234    ICON_2 ICON_SYSTEM_SAP_MENU           '@6A@'."  Stop
235    ICON_2 ICON_SYSTEM_COMP_MENU          '@6B@'."  Stop
236    ICON_2 ICON_SYSTEM_USER_MENU          '@6C@'."  Stop
237    ICON_2 ICON_SYSTEM_FAVORITES          '@6D@'."  Stop
238    ICON_2 ICON_BIW_INFO_SOURCE           '@6E@'."  Stop
239    ICON_2 ICON_BIW_APPLICATION           '@6F@'."  Stop
240    ICON_2 ICON_BIW_INFO_AREA             '@6G@'."  Stop
241    ICON_2 ICON_BIW_INFO_CUBE             '@6H@'."  Stop
242    ICON_2 ICON_BIW_RULES_INA             '@6I@'."  Stop
243    ICON_2 ICON_BIW_SOURCE_SYS_GEN        '@6J@'."  Stop
244    ICON_2 ICON_BIW_SOURCE_SYS_R3         '@6K@'."  Stop
245    ICON_2 ICON_BIW_SOURCE_SYS_EXT        '@6L@'."  Stop
246    ICON_2 ICON_BIW_SOURCE_SYS_FILE       '@6M@'."  Stop
247    ICON_2 ICON_BIW_INFO_CATALOG          '@6N@'."  Stop
248    ICON_2 ICON_BIW_INFO_OBJECT           '@6O@'."  Stop
249    ICON_2 ICON_BIW_MONITOR               '@6P@'."  Stop
250    ICON_2 ICON_BIW_SCHEDULER             '@6Q@'."  Stop
251    ICON_2 ICON_BIW_FORMULA               '@6R@'."  Stop
252    ICON_2 ICON_BIW_REF_STRUCTURE         '@6S@'."  Stop
253    ICON_2 ICON_BIW_REPORT                '@6T@'."  Stop
254    ICON_2 ICON_BIW_REPORT_VIEW           '@6U@'."  Stop
255    ICON_2 ICON_MASTER_DATA_ACT           '@6V@'."  Stop
256    ICON_2 ICON_MASTER_DATA_INA           '@6W@'."  Stop
257    ICON_2 ICON_TEXT_ACT                  '@6X@'."  Stop
258    ICON_2 ICON_TEXT_INA                  '@6Y@'."  Stop
259    ICON_2 ICON_HIERARCHY_ACT             '@6Z@'."  Stop
260    ICON_2 ICON_HIERARCHY_INA             '@70@'."  Stop
261    ICON_2 ICON_MOVING_DATA_ACT           '@71@'."  Stop
262    ICON_2 ICON_MOVING_DATA_INA           '@72@'."  Stop
263    ICON_2 ICON_DEBUGGER_STEP_INTO        '@73@'."  Stop
264    ICON_2 ICON_DEBUGGER_STEP_OVER        '@74@'."  Stop
265    ICON_2 ICON_DEBUGGER_STEP_OUT         '@75@'."  Stop
266    ICON_2 ICON_DEBUGGER_CONTINUE         '@76@'."  Stop
267    ICON_2 ICON_PARAMETER                 '@77@'."  Stop
268    ICON_2 ICON_PARAMETER_IMPORT          '@78@'."  Stop
269    ICON_2 ICON_PARAMETER_EXPORT          '@79@'."  Stop
270    ICON_2 ICON_PARAMETER_CHANGING        '@7A@'."  Stop
271    ICON_2 ICON_PARAMETER_RESULT          '@7B@'."  Stop
272    ICON_2 ICON_OO_CLASS                  '@7C@'."  Stop
273    ICON_2 ICON_OO_INTERFACE              '@7D@'."  Stop
274    ICON_2 ICON_OO_ATTRIBUTE              '@7E@'."  Stop
275    ICON_2 ICON_OO_CLASS_ATTRIBUTE        '@7F@'."  Stop
276    ICON_2 ICON_OO_INST_ATTRIBUTE         '@7G@'."  Stop
277    ICON_2 ICON_OO_METHOD                 '@7H@'."  Stop
278    ICON_2 ICON_OO_CLASS_METHOD           '@7I@'."  Stop
279    ICON_2 ICON_OO_INST_METHOD            '@7J@'."  Stop
280    ICON_2 ICON_OO_EVENT                  '@7K@'."  Stop
281    ICON_2 ICON_OO_CONSTANT               '@7L@'."  Stop
282    ICON_2 ICON_OO_OVERWRITE              '@7M@'."  Stop
283    ICON_2 ICON_OO_CONNECTION             '@7N@'."  Stop
284    ICON_2 ICON_OO_INHERITANCE            '@7O@'."  Stop
285    ICON_2 ICON_OO_INTERFACE_IC           '@7P@'."  Stop
286    ICON_2 ICON_WS_TRUCK                  '@7Q@'."  Stop
287    ICON_2 ICON_WS_RAIL                   '@7R@'."  Stop
288    ICON_2 ICON_WS_SHIP                   '@7S@'."  Stop
289    ICON_2 ICON_WS_PLANE                  '@7T@'."  Stop
290    ICON_2 ICON_WS_POST                   '@7U@'."  Stop
291    ICON_2 ICON_WS_TRANSFER               '@7V@'."  Stop
292    ICON_2 ICON_WS_DOUANE                 '@7W@'."  Stop
293    ICON_2 ICON_SELECTION                 '@7X@'."  Stop
294    ICON_2 ICON_SYSTEM_STOP_RECORDING     '@7Y@'."  Stop
295    ICON_2 ICON_FENCING                   '@7Z@'."  Stop
296    ICON_2 ICON_BIW_RULES_ACT             '@80@'."  Stop
297    ICON_2 ICON_CHARACTERISTICS_ACT       '@81@'."  Stop
298    ICON_2 ICON_CHARACTERISTICS_INA       '@82@'."  Stop
299    ICON_2 ICON_KEYFIGURE_ACT             '@83@'."  Stop
300    ICON_2 ICON_KEYFIGURE_INA             '@84@'."  Stop
301    ICON_2 ICON_BIW_INFO_OBJECT_UNITS_ACT '@85@'."  Stop
302    ICON_2 ICON_BIW_INFO_OBJECT_UNITS_INA '@86@'."  Stop
303    ICON_2 ICON_WORKFLOW_INT_EVENT_DATE   '@87@'."  Stop
304    ICON_2 ICON_BIW_INFO_OBJECT_CATALOGUE '@88@'."  Stop
305    ICON_2 ICON_SET_A                     '@89@'."  Stop
306    ICON_2 ICON_SET_B                     '@8A@'."  Stop
307    ICON_2 ICON_SET_SUM                   '@8B@'."  Stop
308    ICON_2 ICON_SET_INTERSECTION          '@8C@'."  Stop
309    ICON_2 ICON_SET_A_MINUS_B             '@8D@'."  Stop
310    ICON_2 ICON_SET_B_MINUS_A             '@8E@'."  Stop
311    ICON_2 ICON_SET_COPY_IN_A             '@8F@'."  Stop
312    ICON_2 ICON_SET_COPY_IN_B             '@8G@'."  Stop
313    ICON_2 ICON_DANGEROUS_GOODS           '@8H@'."  Stop
314    ICON_2 ICON_DEACTIVATE                '@8I@'."  Stop
315    ICON_2 ICON_DESELECT_BLOCK            '@8J@'."  Stop
316    ICON_2 ICON_INVERT_COLUMN             '@8K@'."  Stop
317    ICON_2 ICON_INVERT_LINE               '@8L@'."  Stop
318    ICON_2 ICON_FOREIGN_TRADE             '@8M@'."  Stop
319    ICON_2 ICON_MESSAGE_CRITICAL_SMALL    '@8N@'."  Stop
320    ICON_2 ICON_MESSAGE_ERROR_SMALL       '@8O@'."  Stop
321    ICON_2 ICON_MESSAGE_INFORMATION_SMALL '@8P@'."  Stop
322    ICON_2 ICON_MESSAGE_QUESTION_SMALL    '@8Q@'."  Stop
323    ICON_2 ICON_MESSAGE_WARNING_SMALL     '@8R@'."  Stop
324    ICON_2 ICON_URL                       '@8S@'."  Stop
325    ICON_2 ICON_SYSTEM_SHORTCUT           '@8T@'."  Stop
326    ICON_2 ICON_PLANNING_IN               '@8U@'."  Stop
327    ICON_2 ICON_PLANNING_OUT              '@8V@'."  Stop
328    ICON_2 ICON_SUBMIT                    '@8W@'."  Stop
329    ICON_2 ICON_ALLOW                     '@8X@'."  Stop
330    ICON_2 ICON_REJECT                    '@8Y@'."  Stop
331    ICON_2 ICON_SIMULATE                  '@8Z@'."  Stop
332    ICON_2 ICON_TE_RECEIPTS               '@90@'."  Stop
333    ICON_2 ICON_TE_STOPOVER               '@91@'."  Stop
334    ICON_2 ICON_TE_KM_DIVISION            '@92@'."  Stop
335    ICON_2 ICON_TE_ADVANCE_PAYMENT        '@93@'."  Stop
336    ICON_2 ICON_TE_DEDUCTION              '@94@'."  Stop
337    ICON_2 ICON_TE_COSTS_ASSIGN           '@95@'."  Stop
338    ICON_2 ICON_HISTORY                   '@96@'."  Stop
339    ICON_2 ICON_MODIFICATION_CREATE       '@97@'."  Stop
340    ICON_2 ICON_MODIFICATION_OVERVIEW     '@98@'."  Stop
341    ICON_2 ICON_MODIFICATION_ORIGINAL     '@99@'."  Stop
342    ICON_2 ICON_MODIFICATION_RESET        '@9A@'."  Stop
343    ICON_2 ICON_ACTIVE_INACTIVE           '@9B@'."  Stop
344    ICON_2 ICON_BEN_OFFER                 '@9C@'."  Stop
345    ICON_2 ICON_BEN_OFFER_DEFAULT         '@9D@'."  Stop
346    ICON_2 ICON_BEN_OFFER_EVENT           '@9E@'."  Stop
347    ICON_2 ICON_BEN_OFFER_OPEN            '@9F@'."  Stop
348    ICON_2 ICON_BEN_WAIVE_COVERAGE        '@9G@'."  Stop
349    ICON_2 ICON_DEPENDENTS                '@9H@'."  Stop
350    ICON_2 ICON_BEN_CURRENT_BENEFITS      '@9I@'."  Stop
351    ICON_2 ICON_BEN_TERMINATION           '@9J@'."  Stop
352    ICON_2 ICON_WS_TRANSPORT              '@9K@'."  Stop
353    ICON_2 ICON_ODS_ACT                   '@9L@'."  Stop
354    ICON_2 ICON_ODS_INA                   '@9M@'."  Stop
355    ICON_2 ICON_BIW_INFO_PACKAGE          '@9N@'."  Stop
356    ICON_2 ICON_ACTION_FAULT              '@9O@'."  Stop
357    ICON_2 ICON_ACTION_SUCCESS            '@9P@'."  Stop
358    ICON_2 ICON_DIMENSION                 '@9Q@'."  Stop
359    ICON_2 ICON_TIME_INA                  '@9R@'."  Stop
360    ICON_2 ICON_ARROW_LEFT                '@9S@'."  Stop
361    ICON_2 ICON_ARROW_RIGHT               '@9T@'."  Stop
362    ICON_2 ICON_ABAP                      '@9U@'."  Stop
363    ICON_2 ICON_ABAP_LOCAL                '@9V@'."  Stop
364    ICON_2 ICON_TRANSFER_STRUCTURE        '@9W@'."  Stop
365    ICON_2 ICON_OPERATION                 '@9X@'."  Stop
366    ICON_2 ICON_ACTIVITY                  '@9Y@'."  Stop
367    ICON_2 ICON_ORDER                     '@9Z@'."  Stop
368    ICON_2 ICON_CUSTOMER                  '@A0@'."  Stop
369    ICON_2 ICON_WAREHOUSE                 '@A1@'."  Stop
370    ICON_2 ICON_DISPO_LEVEL               '@A2@'."  Stop
371    ICON_2 ICON_DISTRIBUTION              '@A3@'."  Stop
372    ICON_2 ICON_CUSTOMER_WAREHOUSE        '@A4@'."  Stop
373    ICON_2 ICON_TRANSPORT_POINT           '@A5@'."  Stop
374    ICON_2 ICON_MATERIAL                  '@A6@'."  Stop
375    ICON_2 ICON_MODEL                     '@A7@'."  Stop
376    ICON_2 ICON_PLANT                     '@A8@'."  Stop
377    ICON_2 ICON_PRODUCT_GROUP             '@A9@'."  Stop
378    ICON_2 ICON_RELATIONSHIP              '@AA@'."  Stop
379    ICON_2 ICON_RESOURCE                  '@AB@'."  Stop
380    ICON_2 ICON_STORE_LOCATION            '@AC@'."  Stop
381    ICON_2 ICON_SUPPLIER                  '@AD@'."  Stop
382    ICON_2 ICON_TRANSPORTATION_MODE       '@AE@'."  Stop
383    ICON_2 ICON_LOCATION                  '@AF@'."  Stop
384    ICON_2 ICON_ALERT                     '@AG@'."  Stop
385    ICON_2 ICON_WARNING                   '@AH@'."  Stop
386    ICON_2 ICON_HINT                      '@AI@'."  Stop
387    ICON_2 ICON_WORKING_PLAN              '@AJ@'."  Stop
388    ICON_2 ICON_MAINTENANCE_PLAN          '@AK@'."  Stop
389    ICON_2 ICON_REPORT                    '@AL@'."  Stop
390    ICON_2 ICON_WORKPLACE                 '@AM@'."  Stop
391    ICON_2 ICON_EQUIPMENT                 '@AN@'."  Stop
392    ICON_2 ICON_TECHNICAL_PLACE           '@AO@'."  Stop
393    ICON_2 ICON_BOM                       '@AP@'."  Stop
394    ICON_2 ICON_BOM_ITEM                  '@AQ@'."  Stop
395    ICON_2 ICON_DOCUMENT                  '@AR@'."  Stop
396    ICON_2 ICON_DOCUMENT_REVISION         '@AS@'."  Stop
397    ICON_2 ICON_MATERIAL_REVISION         '@AT@'."  Stop
398    ICON_2 ICON_CHANGE_NUMBER             '@AU@'."  Stop
399    ICON_2 ICON_FLIGHT                    '@AV@'."  Stop
400    ICON_2 ICON_CAR                       '@AW@'."  Stop
401    ICON_2 ICON_HOTEL                     '@AX@'."  Stop
402    ICON_2 ICON_RAILWAY                   '@AY@'."  Stop
403    ICON_2 ICON_MONEY                     '@AZ@'."  Stop
404    ICON_2 ICON_QUESTION                  '@B0@'."  Stop
405    ICON_2 ICON_BOOKING_OK                '@B1@'."  Stop
406    ICON_2 ICON_BOOKING_STOP              '@B2@'."  Stop
407    ICON_2 ICON_STATUS_OPEN               '@B3@'."  Stop
408    ICON_2 ICON_STATUS_BOOKED             '@B4@'."  Stop
409    ICON_2 ICON_STATUS_PARTLY_BOOKED      '@B5@'."  Stop
410    ICON_2 ICON_STATUS_REVERSE            '@B6@'."  Stop
411    ICON_2 ICON_PREFERENCE                '@B7@'."  Stop
412    ICON_2 ICON_NEXT_STEP                 '@B8@'."  Stop
413    ICON_2 ICON_PREVIOUS_STEP             '@B9@'."  Stop
414    ICON_2 ICON_STORNO                    '@BA@'."  Stop
415    ICON_2 ICON_INTERCHANGE               '@BB@'."  Stop
416    ICON_2 ICON_CASHING_UP                '@BC@'."  Stop
417    ICON_2 ICON_WORKLOAD                  '@BD@'."  Stop
418    ICON_2 ICON_PROPOSITION               '@BE@'."  Stop
419    ICON_2 ICON_PRESENCE                  '@BF@'."  Stop
420    ICON_2 ICON_ABSENCE                   '@BG@'."  Stop
421    ICON_2 ICON_TIME_CONTROL              '@BH@'."  Stop
422    ICON_2 ICON_POSITION_HR               '@BI@'."  Stop
423    ICON_2 ICON_PARAMETER_TABLE           '@BJ@'."  Stop
424    ICON_2 ICON_TASK                      '@BK@'."  Stop
425    ICON_2 ICON_COST_CENTER               '@BL@'."  Stop
426    ICON_2 ICON_MANAGER                   '@BM@'."  Stop
427    ICON_2 ICON_ORG_UNIT                  '@BN@'."  Stop
428    ICON_2 ICON_QUERY                     '@BO@'."  Stop
429    ICON_2 ICON_WORKFLOW_INBOX            '@BP@'."  Stop
430    ICON_2 ICON_FAST_ENTRY                '@BQ@'."  Stop
431    ICON_2 ICON_LIFE_EVENTS               '@BR@'."  Stop
432    ICON_2 ICON_WORK_CENTER               '@BS@'."  Stop
433    ICON_2 ICON_GRADUATE                  '@BT@'."  Stop
434    ICON_2 ICON_EXTRA                     '@BU@'."  Stop
435    ICON_2 ICON_CONVERT_ALL               '@BV@'."  Stop
436    ICON_2 ICON_RELATION                  '@BW@'."  Stop
437    ICON_2 ICON_CONFIGURATION             '@BX@'."  Stop
438    ICON_2 ICON_WIZARD                    '@BY@'."  Stop
439    ICON_2 ICON_LED_INACTIVE              '@BZ@'."  Stop
440    ICON_2 ICON_STORE                     '@C0@'."  Stop
441    ICON_2 ICON_LINK                      '@C1@'."  Stop
442    ICON_2 ICON_LATE_STORE                '@C2@'."  Stop
443    ICON_2 ICON_LATE_LINK                 '@C3@'."  Stop
444    ICON_2 ICON_EARLY_STORE               '@C4@'."  Stop
445    ICON_2 ICON_EARLY_LINK                '@C5@'."  Stop
446    ICON_2 ICON_OO_CLASS_EVENT            '@C6@'."  Stop
447    ICON_2 ICON_OO_INST_EVENT             '@C7@'."  Stop
448    ICON_2 ICON_OO_ALIAS                  '@C8@'."  Stop
449    ICON_2 ICON_OO_OBJECT                 '@C9@'."  Stop
450    ICON_2 ICON_JOB                       '@CA@'."  Stop
451    ICON_2 ICON_DELIVERY_DATE             '@CB@'."  Stop
452    ICON_2 ICON_DELIVERY_COMPLETE         '@CC@'."  Stop
453    ICON_2 ICON_DELIVERY_PROPOSAL         '@CD@'."  Stop
454    ICON_2 ICON_PDIR_BACK_SWITCH          '@CE@'."  Stop
455    ICON_2 ICON_PDIR_BACK                 '@CF@'."  Stop
456    ICON_2 ICON_PDIR_FOREWARD             '@CG@'."  Stop
457    ICON_2 ICON_PDIR_FOREWARD_SWITCH      '@CH@'."  Stop
458    ICON_2 ICON_FINITE                    '@CI@'."  Stop
459    ICON_2 ICON_NONWORK                   '@CJ@'."  Stop
460    ICON_2 ICON_PM_FREE                   '@CK@'."  Stop
461    ICON_2 ICON_PM_INSERT                 '@CL@'."  Stop
462    ICON_2 ICON_PM_PRESS                  '@CM@'."  Stop
463    ICON_2 ICON_PM_ORDER                  '@CN@'."  Stop
464    ICON_2 ICON_DANGEROUS_GOOD_CHECK      '@CO@'."  Stop
465    ICON_2 ICON_WORKFLOW_DOC_CREATE       '@CP@'."  Stop
466    ICON_2 ICON_WF_LINK                   '@CQ@'."  Stop
467    ICON_2 ICON_WF_UNLINK                 '@CR@'."  Stop
468    ICON_2 ICON_WF_WORKITEM_READY         '@CS@'."  Stop
469    ICON_2 ICON_WF_WORKITEM_RESERVED      '@CT@'."  Stop
470    ICON_2 ICON_WF_WORKITEM_STARTED       '@CU@'."  Stop
471    ICON_2 ICON_WF_WORKITEM_COMMITTED     '@CV@'."  Stop
472    ICON_2 ICON_WF_WORKITEM_WAITING       '@CW@'."  Stop
473    ICON_2 ICON_WF_WORKITEM_COMPLETED     '@CX@'."  Stop
474    ICON_2 ICON_WF_WORKITEM_ERROR         '@CY@'."  Stop
475    ICON_2 ICON_WF_WORKITEM_CANCEL        '@CZ@'."  Stop
476    ICON_2 ICON_WF_RESERVE_WORKITEM       '@D0@'."  Stop
477    ICON_2 ICON_WF_REPLACE_WORKITEM       '@D1@'."  Stop
478    ICON_2 ICON_PROFIT_CENTER             '@D2@'."  Stop
479    ICON_2 ICON_WF_RULE_SYSTEM            '@D3@'."  Stop
480    ICON_2 ICON_WF_PARAMETER              '@D4@'."  Stop
481    ICON_2 ICON_JAPAN                     '@D5@'."  Stop
482    ICON_2 ICON_SLS                       '@D6@'."  Stop
483    ICON_2 ICON_CUSTOMS                   '@D7@'."  Stop
484    ICON_2 ICON_LEGAL_REG                 '@D8@'."  Stop
485    ICON_2 ICON_COMPANY_CODE              '@D9@'."  Stop
486    ICON_2 ICON_UNIT_COSTING              '@DA@'."  Stop
487    ICON_2 ICON_BASE_PLANNING_OBJECT      '@DB@'."  Stop
488    ICON_2 ICON_ACTIVITY_TYPE             '@DC@'."  Stop
489    ICON_2 ICON_RENTAL_AGREEMENT          '@DD@'."  Stop
490    ICON_2 ICON_REAL_ESTATE_OBJECT        '@DE@'."  Stop
491    ICON_2 ICON_COMPLETE                  '@DF@'."  Stop
492    ICON_2 ICON_PARTNER                   '@DG@'."  Stop
493    ICON_2 ICON_PROTOCOL                  '@DH@'."  Stop
494    ICON_2 ICON_MAINTENANCE_OBJECT_LIST   '@DI@'."  Stop
495    ICON_2 ICON_XXL                       '@DJ@'."  Stop
496    ICON_2 ICON_WORD_PROCESSING           '@DK@'."  Stop
497    ICON_2 ICON_ABC                       '@DL@'."  Stop
498    ICON_2 ICON_ALV_VARIANT_CHOOSE        '@DM@'."  Stop
499    ICON_2 ICON_ALV_VARIANT_SAVE          '@DN@'."  Stop
500    ICON_2 ICON_EXCLUDED_CORRESPONDENCE   '@DO@'."  Stop
501    ICON_2 ICON_INCREASE_DECIMAL          '@DP@'."  Stop
502    ICON_2 ICON_DECREASE_DECIMAL          '@DQ@'."  Stop
503    ICON_2 ICON_ERROR_PROTOCOL            '@DR@'."  Stop
504    ICON_2 ICON_PARTNER_SALES_ACTIVITY    '@DS@'."  Stop
505    ICON_2 ICON_PHONE_CALL_IN             '@DT@'."  Stop
506    ICON_2 ICON_NAFTA                     '@DU@'."  Stop
507    ICON_2 ICON_EU                        '@DV@'."  Stop
508    ICON_2 ICON_PHONE_CALL_OUT            '@DW@'."  Stop
509    ICON_2 ICON_CONTROLLING_AREA          '@DX@'."  Stop
510    ICON_2 ICON_DISTRIBUTION_LIST         '@DY@'."  Stop
511    ICON_2 ICON_MAIL_SAP_UNREAD           '@DZ@'."  Stop
512    ICON_2 ICON_MAIL_SAP_READ             '@E0@'."  Stop
513    ICON_2 ICON_ENVELOPE_OPEN             '@E1@'."  Stop
514    ICON_2 ICON_ENVELOPE_CLOSED           '@E2@'."  Stop
515    ICON_2 ICON_OFFICE_DOCUMENT           '@E3@'."  Stop
516    ICON_4 ICON_INCLUDE_IN_SELECTION      '@E4@'."  Stop
517    ICON_2 ICON_WF_WORKITEM_OL            '@E5@'."  Stop
518    ICON_2 ICON_NEW_HANDLING_UNIT         '@E6@'."  Stop
519    ICON_2 ICON_NEW_HANDLING_IF_FULL      '@E7@'."  Stop
520    ICON_2 ICON_PACKING                   '@E8@'."  Stop
521    ICON_2 ICON_UNPACK                    '@E9@'."  Stop
522    ICON_2 ICON_EMPTY_HANDLING_UNIT       '@EA@'."  Stop
523    ICON_4 ICON_LIGHT_OUT                 '@EB@'."  Stop
524    ICON_2 ICON_PS_PROJECT_DEFINITION     '@EC@'."  Stop
525    ICON_2 ICON_PS_WBS_ELEMENT            '@ED@'."  Stop
526    ICON_2 ICON_PS_NETWORK_HEADER         '@EE@'."  Stop
527    ICON_2 ICON_PS_NETWORK_ACTIVITY       '@EF@'."  Stop
528    ICON_2 ICON_PS_ACTIVITY_ELEMENT       '@EG@'."  Stop
529    ICON_2 ICON_PS_RELATIONSHIP           '@EH@'."  Stop
530    ICON_2 ICON_STATUS                    '@EI@'."  Stop
531    ICON_2 ICON_BATCH                     '@EJ@'."  Stop
532    ICON_2 ICON_ADMINISTRATIVE_DATA       '@EK@'."  Stop
533    ICON_2 ICON_STOCK                     '@EL@'."  Stop
534    ICON_2 ICON_ACCOUNT_ASSIGNMENT        '@EM@'."  Stop
535    ICON_2 ICON_LOT_ORIGIN                '@EN@'."  Stop
536    ICON_2 ICON_INSPECTION_LOT            '@EO@'."  Stop
537    ICON_2 ICON_SHOW_EXTERNAL_JOBS        '@EP@'."  Stop
538    ICON_2 ICON_SPOOL_REQUEST             '@EQ@'."  Stop
539    ICON_2 ICON_OUTPUT_REQUEST            '@ER@'."  Stop
540    ICON_2 ICON_DELETE_FAVORITES          '@ES@'."  Stop
541    ICON_2 ICON_SHOW_EVENTS               '@ET@'."  Stop
542    ICON_2 ICON_SPOOL_STATUS              '@EU@'."  Stop
543    ICON_2 ICON_INSERT_FAVORITES          '@EV@'."  Stop
544    ICON_2 ICON_PRINT_WITH_PARAMETERS     '@EW@'."  Stop
545    ICON_2 ICON_USED_RELATION             '@EX@'."  Stop
546    ICON_2 ICON_MAPPED_RELATION           '@EY@'."  Stop
547    ICON_2 ICON_CREATE_COPY               '@EZ@'."  Stop
548    ICON_2 ICON_FLUSH                     '@F0@'."  Stop
549    ICON_2 ICON_DEFECT                    '@F1@'."  Stop
550    ICON_2 ICON_BW_GIS                    '@F2@'."  Stop
551    ICON_2 ICON_BW_INFO_CUBE_SAP          '@F3@'."  Stop
552    ICON_2 ICON_BW_INFO_CUBE_INA          '@F4@'."  Stop
553    ICON_2 ICON_BW_INFO_OBJECT_CATALOGUE  '@F5@'."  Stop
554    ICON_2 ICON_BW_SUGGEST_VALUE          '@F6@'."  Stop
555    ICON_2 ICON_DOC_POSITION_PROPOSAL     '@F7@'."  Stop
556    ICON_2 ICON_CUSTOMER_MASTER_DATA_LIST '@F8@'."  Stop
557    ICON_2 ICON_STATUS_OVERVIEW           '@F9@'."  Stop
558    ICON_2 ICON_DOC_HEADER_DETAIL         '@FA@'."  Stop
559    ICON_2 ICON_DOC_ITEM_DETAIL           '@FB@'."  Stop
560    ICON_2 ICON_AVAILABILITY_CHECK        '@FC@'."  Stop
561    ICON_2 ICON_PRICE                     '@FD@'."  Stop
562    ICON_2 ICON_SCHEDULE_LINE             '@FE@'."  Stop
563    ICON_2 ICON_AVAILABILITY_DISPLAY      '@FF@'."  Stop
564    ICON_2 ICON_STATISTICS                '@FG@'."  Stop
565    ICON_2 ICON_CLAIM                     '@FH@'."  Stop
566    ICON_2 ICON_PLANNING_SITUATION        '@FI@'."  Stop
567    ICON_2 ICON_CHANGE_ORDER              '@FJ@'."  Stop
568    ICON_2 ICON_PRODUCT_REQUIREMENTS      '@FK@'."  Stop
569    ICON_2 ICON_PRODUCT_RECEIPTS          '@FL@'."  Stop
570    ICON_2 ICON_ATTACHMENT                '@FM@'."  Stop
571    ICON_2 ICON_CLOSED_FOLDER             '@FN@'."  Stop
572    ICON_2 ICON_OPEN_FOLDER               '@FO@'."  Stop
573    ICON_2 ICON_OBJECT_FOLDER             '@FP@'."  Stop
574    ICON_2 ICON_OUTBOX                    '@FQ@'."  Stop
575    ICON_2 ICON_RESUBMISSION              '@FR@'."  Stop
576    ICON_2 ICON_PRIVATE_FILES             '@FS@'."  Stop
577    ICON_2 ICON_PUBLIC_FILES              '@FT@'."  Stop
578    ICON_2 ICON_SUBSCRIPTION              '@FU@'."  Stop
579    ICON_2 ICON_AVERAGE                   '@FV@'."  Stop
580    ICON_2 ICON_BOLD                      '@FW@'."  Stop
581    ICON_2 ICON_ITALIC                    '@FX@'."  Stop
582    ICON_2 ICON_UNDERLINE                 '@FY@'."  Stop
583    ICON_2 ICON_ALIGN_LEFT                '@FZ@'."  Stop
584    ICON_2 ICON_ALIGN_RIGHT               '@G0@'."  Stop
585    ICON_2 ICON_ALIGN_CENTER              '@G1@'."  Stop
586    ICON_2 ICON_JUSTIFIED                 '@G2@'."  Stop
587    ICON_2 ICON_COLOR                     '@G3@'."  Stop
588    ICON_2 ICON_DELETE_ALL_ATTRIBUTES     '@G4@'."  Stop
589    ICON_2 ICON_IDOC                      '@G5@'."  Stop
590    ICON_2 ICON_HOST                      '@G6@'."  Stop
591    ICON_2 ICON_SYM_SPOOL_SERVER          '@G7@'."  Stop
592    ICON_2 ICON_SYM_REAL_SERVER           '@G8@'."  Stop
593    ICON_2 ICON_SYM_LOG_SERVER            '@G9@'."  Stop
594    ICON_2 ICON_SYM_ALT_SERVER            '@GA@'."  Stop
595    ICON_2 ICON_CONNECT                   '@GB@'."  Stop
596    ICON_2 ICON_DISCONNECT                '@GC@'."  Stop
597    ICON_2 ICON_FILTER_UNDO               '@GD@'."  Stop
598    ICON_2 ICON_SET_SUM_UNDO              '@GE@'."  Stop
599    ICON_2 ICON_INTENSIFY_UNDO            '@GF@'."  Stop
600    ICON_2 ICON_SORT_UNDO                 '@GG@'."  Stop
601    ICON_2 ICON_BW_DATA_MARTS             '@GH@'."  Stop
602    ICON_4 ICON_REMOVE_FROM_SELECTION     '@GI@'."  Stop
603    ICON_2 ICON_BW_CHARACTERISTICS_SAP    '@GJ@'."  Stop
604    ICON_2 ICON_BW_KEYFIGURE_SAP          '@GK@'."  Stop
605    ICON_2 ICON_BW_INFO_OBJECT_UNITS_SAP  '@GL@'."  Stop
606    ICON_2 ICON_BW_TIME_SAP               '@GM@'."  Stop
607    ICON_2 ICON_BW_RULES_SAP              '@GN@'."  Stop
608    ICON_2 ICON_BW_REPORT_SAP             '@GO@'."  Stop
609    ICON_2 ICON_BW_VARIABLE_SAP           '@GP@'."  Stop
610    ICON_2 ICON_BW_REF_STRUCTURE_SAP      '@GQ@'."  Stop
611    ICON_2 ICON_BW_SELECTION_SAP          '@GR@'."  Stop
612    ICON_2 ICON_INSPECTION_METHOD         '@GS@'."  Stop
613    ICON_2 ICON_CATALOG                   '@GT@'."  Stop
614    ICON_2 ICON_INSERT_MULTIPLE_LINES     '@GU@'."  Stop
615    ICON_2 ICON_INSPECTION_CHARACTERISTIC '@GV@'."  Stop
616    ICON_2 ICON_PHYSICAL_SAMPLE           '@GW@'."  Stop
617    ICON_2 ICON_BW_FORMULA_SAP            '@GX@'."  Stop
618    ICON_2 ICON_BW_INFO_CATALOGUE_SAP     '@GY@'."  Stop
619    ICON_2 ICON_BUDGET_STRUCTURE_ELEMENT  '@GZ@'."  Stop
620    ICON_2 ICON_FINANCING                 '@H0@'."  Stop
621    ICON_2 ICON_RECLASSIFICATION_RULE     '@H1@'."  Stop
622    ICON_2 ICON_RECLASSIFICATION          '@H2@'."  Stop
623    ICON_2 ICON_REMOVE                    '@H3@'."  Stop
624    ICON_2 ICON_SPECIAL_PURPOSE           '@H4@'."  Stop
625    ICON_2 ICON_DEPUTY                    '@H5@'."  Stop
626    ICON_2 ICON_BUDGET_UPDATE             '@H6@'."  Stop
627    ICON_2 ICON_BUDGET_TRANSFER           '@H7@'."  Stop
628    ICON_2 ICON_BW_SEGMENT_ACT            '@H8@'."  Stop
629    ICON_2 ICON_BW_SEGMENT_INA            '@H9@'."  Stop
630    ICON_2 ICON_BW_SEGMENT_SAP            '@HA@'."  Stop
631    ICON_2 ICON_MASS_CHANGE               '@HB@'."  Stop
632    ICON_2 ICON_INTENSIFY_CRITICAL        '@HC@'."  Stop
633    ICON_2 ICON_INTENSIFY_UNCRITICAL      '@HD@'."  Stop
634    ICON_2 ICON_CHOOSE_COLUMNS            '@HE@'."  Stop
635    ICON_2 ICON_TOTAL_UP                  '@HF@'."  Stop
636    ICON_2 ICON_TOTAL_DOWN                '@HG@'."  Stop
637    ICON_2 ICON_PAGE_UP                   '@HH@'."  Stop
638    ICON_2 ICON_PAGE_DOWN                 '@HI@'."  Stop
639    ICON_2 ICON_READ_FILE                 '@HJ@'."  Stop
640    ICON_2 ICON_WRITE_FILE                '@HK@'."  Stop
641    ICON_2 ICON_EDIT_FILE                 '@HL@'."  Stop
642    ICON_2 ICON_PS_MILESTONE              '@HM@'."  Stop
643    ICON_2 ICON_PS_PROJECT_TEXT           '@HN@'."  Stop
644    ICON_2 ICON_ELEMENT                   '@HO@'."  Stop
645    ICON_2 ICON_STRUCTURE                 '@HP@'."  Stop
646    ICON_2 ICON_WS_WHSE_STOCK             '@HQ@'."  Stop
647    ICON_2 ICON_ROUTING                   '@HR@'."  Stop
648    ICON_2 ICON_MATERIAL_ROUTING_ALLOC    '@HS@'."  Stop
649    ICON_2 ICON_ROUTING_SUB_OPERATION     '@HT@'."  Stop
650    ICON_2 ICON_ROUTING_REF_SUB_OPERATION '@HU@'."  Stop
651    ICON_2 ICON_ROUTING_SEQUENCE          '@HV@'."  Stop
652    ICON_2 ICON_BOM_SUB_ITEM              '@HW@'."  Stop
653    ICON_2 ICON_EFFECTIVITY_PERIOD        '@HX@'."  Stop
654    ICON_2 ICON_KEY_DATE                  '@HY@'."  Stop
655    ICON_2 ICON_SELECTION_PERIOD          '@HZ@'."  Stop
656    ICON_2 ICON_EFF                       '@I0@'."  Stop
657    ICON_2 ICON_SUPPLY_AREA               '@I1@'."  Stop
658    ICON_2 ICON_REPORT_CALL               '@I2@'."  Stop
659    ICON_2 ICON_ASSIGN                    '@I3@'."  Stop
660    ICON_2 ICON_UNASSIGN                  '@I4@'."  Stop
661    ICON_2 ICON_SYSTEM_START_RECORDING    '@I5@'."  Stop
662    ICON_2 ICON_SYSTEM_PLAY               '@I6@'."  Stop
663    ICON_2 ICON_TRANSLATION               '@I7@'."  Stop
664    ICON_2 ICON_TRANSLATION_SHOW          '@I8@'."  Stop
665    ICON_2 ICON_CHANGE_PASSWORD           '@I9@'."  Stop
666    ICON_2 ICON_DISTRIBUTE                '@IA@'."  Stop
667    ICON_2 ICON_SYSTEMS                   '@IB@'."  Stop
668    ICON_2 ICON_ACTIVITY_GROUP            '@IC@'."  Stop
669    ICON_2 ICON_USERGROUP                 '@ID@'."  Stop
670    ICON_2 ICON_UNLINK                    '@IE@'."  Stop
671    ICON_2 ICON_CONTENT_OBJECT            '@IF@'."  Stop
672    ICON_2 ICON_OBJECT_LIST               '@IG@'."  Stop
673    ICON_2 ICON_FOLDER                    '@IH@'."  Stop
674    ICON_2 ICON_DIFFERENCE                '@II@'."  Stop
675    ICON_2 ICON_DIFFERENCE_BACK           '@IJ@'."  Stop
676    ICON_2 ICON_SYSTEM_DESELECT           '@IK@'."  Stop
677    ICON_2 ICON_ADOPT                     '@IL@'."  Stop
678    ICON_2 ICON_TERMINOLOGY               '@IM@'."  Stop
679    ICON_2 ICON_TRIANGULAR_RELATIONSHIP   '@IN@'."  Stop
680    ICON_2 ICON_AEW_PROJECT               '@IO@'."  Stop
681    ICON_2 ICON_SICKNESS                  '@IP@'."  Stop
682    ICON_2 ICON_HOLIDAY                   '@IQ@'."  Stop
683    ICON_2 ICON_ROLE                      '@IR@'."  Stop
684    ICON_2 ICON_PERSONNEL_ADMINISTRATION  '@IS@'."  Stop
685    ICON_2 ICON_PDF                       '@IT@'."  Stop
686    ICON_2 ICON_BMP                       '@IU@'."  Stop
687    ICON_2 ICON_FAX_DOC                   '@IV@'."  Stop
688    ICON_2 ICON_GIF                       '@IW@'."  Stop
689    ICON_2 ICON_HLP                       '@IX@'."  Stop
690    ICON_2 ICON_HTT                       '@IY@'."  Stop
691    ICON_2 ICON_ITS                       '@IZ@'."  Stop
692    ICON_2 ICON_JPG                       '@J0@'."  Stop
693    ICON_2 ICON_MSG                       '@J1@'."  Stop
694    ICON_2 ICON_XLS                       '@J2@'."  Stop
695    ICON_2 ICON_XLV                       '@J3@'."  Stop
696    ICON_2 ICON_HTM                       '@J4@'."  Stop
697    ICON_2 ICON_PPT                       '@J5@'."  Stop
698    ICON_2 ICON_DOT                       '@J6@'."  Stop
699    ICON_2 ICON_DOC                       '@J7@'."  Stop
700    ICON_2 ICON_EML                       '@J8@'."  Stop
701    ICON_2 ICON_RTF                       '@J9@'."  Stop
702    ICON_2 ICON_TIF                       '@JA@'."  Stop
703    ICON_2 ICON_WRI                       '@JB@'."  Stop
704    ICON_2 ICON_LWP                       '@JC@'."  Stop
705    ICON_2 ICON_LOTUS                     '@JD@'."  Stop
706    ICON_2 ICON_VSD                       '@JE@'."  Stop
707    ICON_2 ICON_DEFAULT_WINDOWS           '@JF@'."  Stop
708    ICON_2 ICON_DISPLAY_TREE              '@JG@'."  Stop
709    ICON_2 ICON_EXTENDED_SEARCH           '@JH@'."  Stop
710    ICON_2 ICON_CLOSE_OBJECT              '@JI@'."  Stop
711    ICON_2 ICON_OPEN                      '@JJ@'."  Stop
712    ICON_2 ICON_POLICY                    '@JK@'."  Stop
713    ICON_2 ICON_PAYMENT                   '@JL@'."  Stop
714    ICON_2 ICON_CATASTROPHE               '@JM@'."  Stop
715    ICON_2 ICON_AGGREGATE                 '@JN@'."  Stop
716    ICON_2 ICON_SUBCLAIM_PERSONAL_INJURY  '@JO@'."  Stop
717    ICON_2 ICON_SUB_INTELLECTUAL_PROPERTY '@JP@'."  Stop
718    ICON_2 ICON_SUBCLAIM_VEHICLE          '@JQ@'."  Stop
719    ICON_2 ICON_SUB_PERSONAL_PROPERTY     '@JR@'."  Stop
720    ICON_2 ICON_SUBCLAIM_BUILDING         '@JS@'."  Stop
721    ICON_2 ICON_SUB_BODILY_INJURY_TREAT   '@JT@'."  Stop
722    ICON_2 ICON_SUBCLAIM_BODILY_INJURY    '@JU@'."  Stop
723    ICON_2 ICON_SUB_ENVRONMENTAL_SITE     '@JV@'."  Stop
724    ICON_2 ICON_SUB_FINANCIAL_IMPAIRMENT  '@JW@'."  Stop
725    ICON_2 ICON_BW_PROCESS                '@JX@'."  Stop
726    ICON_2 ICON_BW_SIMULATE               '@JY@'."  Stop
727    ICON_2 ICON_BW_PROCESS_CANCEL         '@JZ@'."  Stop
728    ICON_2 ICON_BW_SIMULATE_CANCEL        '@K0@'."  Stop
729    ICON_2 ICON_DATA_AREA_EXPAND          '@K1@'."  Stop
730    ICON_2 ICON_DATA_AREA_COLLAPSE        '@K2@'."  Stop
731    ICON_2 ICON_SCRAP                     '@K3@'."  Stop
732    ICON_2 ICON_IMPORT_ALL_REQUESTS       '@K4@'."  Stop
733    ICON_2 ICON_IMPORT_TRANSPORT_REQUEST  '@K5@'."  Stop
734    ICON_2 ICON_TOGGLE_DISPLAY            '@K6@'."  Stop
735    ICON_2 ICON_TOGGLE_FUNCTION           '@K7@'."  Stop
736    ICON_2 ICON_PERSONAL_SETTINGS         '@K8@'."  Stop
737    ICON_2 ICON_PROJECT                   '@K9@'."  Stop
738    ICON_2 ICON_INCLUDE_OBJECTS           '@KA@'."  Stop
739    ICON_2 ICON_TRANSFER                  '@KB@'."  Stop
740    ICON_2 ICON_DISTRIBUTE_CONFIGURATION  '@KC@'."  Stop
741    ICON_2 ICON_ADJUST_CONFIGURATION      '@KD@'."  Stop
742    ICON_2 ICON_STANDARD_CONFIGURATION    '@KE@'."  Stop
743    ICON_2 ICON_MODIFIED_OBJECT           '@KF@'."  Stop
744    ICON_2 ICON_SELECT_WITH_CONDITION     '@KG@'."  Stop
745    ICON_2 ICON_ADDRESS_LIST              '@KH@'."  Stop
746    ICON_2 ICON_APPOINTMENT_COMPARISON    '@KI@'."  Stop
747    ICON_2 ICON_BUSINESS_PARTNER_MASTER_D '@KJ@'."  Stop
748    ICON_2 ICON_INCOMPLETION_LOG          '@KK@'."  Stop
749    ICON_2 ICON_MESSAGE                   '@KL@'."  Stop
750    ICON_2 ICON_TELEPHONE_CALL            '@KM@'."  Stop
751    ICON_2 ICON_VISIT                     '@KN@'."  Stop
752    ICON_2 ICON_LETTER                    '@KO@'."  Stop
753    ICON_2 ICON_OPERATOR                  '@KP@'."  Stop
754    ICON_2 ICON_SYSTEM_ADMINISTRATOR      '@KQ@'."  Stop
755    ICON_2 ICON_SAP                       '@KR@'."  Stop
756    ICON_2 ICON_PUBLIC                    '@KS@'."  Stop
757    ICON_2 ICON_SUMMARIZE                 '@KT@'."  Stop
758    ICON_2 ICON_SUMMARIZE_UNDO            '@KU@'."  Stop
759    ICON_2 ICON_SUM_RED                   '@KV@'."  Stop
760    ICON_2 ICON_UNSPECIFIED_ONE           '@KW@'."  Stop
761    ICON_2 ICON_UNSPECIFIED_TWO           '@KX@'."  Stop
762    ICON_2 ICON_UNSPECIFIED_THREE         '@KY@'."  Stop
763    ICON_2 ICON_UNSPECIFIED_FOUR          '@KZ@'."  Stop
764    ICON_2 ICON_UNSPECIFIED_FIVE          '@L0@'."  Stop
765    ICON_2 ICON_HR_MANAGER                '@L1@'."  Stop
766    ICON_2 ICON_TBH                       '@L2@'."  Stop
767    ICON_2 ICON_TBH_HOLD                  '@L3@'."  Stop
768    ICON_2 ICON_NEW_EMPLOYEE              '@L4@'."  Stop
769    ICON_2 ICON_INCOMING_EMPLOYEE         '@L5@'."  Stop
770    ICON_2 ICON_OUTGOING_EMPLOYEE         '@L6@'."  Stop
771    ICON_2 ICON_OBSOLETE_POSITION         '@L7@'."  Stop
772    ICON_2 ICON_TERMINATED_POSITION       '@L8@'."  Stop
773    ICON_2 ICON_SHARED_POSITION           '@L9@'."  Stop
774    ICON_2 ICON_OBSOLETE_SHARED_POSITION  '@LA@'."  Stop
775    ICON_2 ICON_TERMINATED_SHARED_POSITIO '@LB@'."  Stop
776    ICON_2 ICON_HR_POSITION               '@LC@'."  Stop
777    ICON_2 ICON_CREATE_POSITION           '@LD@'."  Stop
778    ICON_2 ICON_HR_ORG_UNIT               '@LE@'."  Stop
779    ICON_2 ICON_TERMINATED_ORG_UNIT       '@LF@'."  Stop
780    ICON_2 ICON_NEW_ORG_UNIT              '@LG@'."  Stop
781    ICON_2 ICON_OUTGOING_ORG_UNIT         '@LH@'."  Stop
782    ICON_2 ICON_INCOMING_ORG_UNIT         '@LI@'."  Stop
783    ICON_2 ICON_NEW_TASK                  '@LJ@'."  Stop
784    ICON_2 ICON_TERMINATED_TASK           '@LK@'."  Stop
785    ICON_2 ICON_OUTGOING_TASK             '@LL@'."  Stop
786    ICON_2 ICON_INCOMING_TASK             '@LM@'."  Stop
787    ICON_2 ICON_OUTGOING_JOB              '@LN@'."  Stop
788    ICON_2 ICON_INCOMING_JOB              '@LO@'."  Stop
789    ICON_2 ICON_NEW_JOB                   '@LP@'."  Stop
790    ICON_2 ICON_TERMINATED_JOB            '@LQ@'."  Stop
791    ICON_2 ICON_INCOMING_OBJECT           '@LR@'."  Stop
792    ICON_2 ICON_OUTGOING_OBJECT           '@LS@'."  Stop
793    ICON_2 ICON_WS_START_WHSE_PROC_BACKGR '@LT@'."  Stop
794    ICON_2 ICON_WS_START_WHSE_PROC_FOREGR '@LU@'."  Stop
795    ICON_2 ICON_WS_CONFIRM_WHSE_PROC_BACK '@LV@'."  Stop
796    ICON_2 ICON_WS_CONFIRM_WHSE_PROC_FORE '@LW@'."  Stop
797    ICON_2 ICON_HOLD                      '@LX@'."  Stop
798    ICON_2 ICON_HOLD_UNDO                 '@LY@'."  Stop
799    ICON_2 ICON_ALV_VARIANTS              '@LZ@'."  Stop
800    ICON_2 ICON_TE_FLAT_RATE              '@M0@'."  Stop
801    ICON_2 ICON_BIW_SOURCE_SYS_OWN        '@M1@'."  Stop
802    ICON_2 ICON_WORKFLOW_JOIN             '@M2@'."  Stop
803    ICON_2 ICON_WORKFLOW_PROCESS          '@M3@'."  Stop
804    ICON_2 ICON_BACKGROUND_JOB            '@M4@'."  Stop
805    ICON_2 ICON_JOB_DETAIL                '@M5@'."  Stop
806    ICON_2 ICON_SYSTEMTYPE                '@M6@'."  Stop
807    ICON_2 ICON_COMPOSITE_ACTIVITYGROUP   '@M7@'."  Stop
808    ICON_2 ICON_TREND_DOWN                '@M8@'."  Stop
809    ICON_2 ICON_TREND_DECREASING          '@M9@'."  Stop
810    ICON_2 ICON_TREND_UNCHANGED           '@MA@'."  Stop
811    ICON_2 ICON_TREND_RISING              '@MB@'."  Stop
812    ICON_2 ICON_TREND_UP                  '@MC@'."  Stop
813    ICON_2 ICON_STATUS_ALERT              '@MD@'."  Stop
814    ICON_2 ICON_STATUS_OK                 '@ME@'."  Stop
815    ICON_2 ICON_STATUS_BEST               '@MF@'."  Stop
816    ICON_2 ICON_NO_STATUS                 '@MG@'."  Stop
817    ICON_2 ICON_DRAW_SELECT               '@MH@'."  Stop
818    ICON_2 ICON_DRAW_FREEHAND             '@MI@'."  Stop
819    ICON_2 ICON_DRAW_ARROW                '@MJ@'."  Stop
820    ICON_2 ICON_DRAW_LINE                 '@MK@'."  Stop
821    ICON_2 ICON_DRAW_POLYLINE             '@ML@'."  Stop
822    ICON_2 ICON_DRAW_ELLIPSE              '@MM@'."  Stop
823    ICON_2 ICON_DRAW_POLYGON              '@MN@'."  Stop
824    ICON_2 ICON_DRAW_RECTANGLE            '@MO@'."  Stop
825    ICON_2 ICON_DRAW_ANGULAR              '@MP@'."  Stop
826    ICON_2 ICON_DRAW_LINEAR               '@MQ@'."  Stop
827    ICON_2 ICON_DRAW_RADIAL               '@MR@'."  Stop
828    ICON_2 ICON_BW_EXCEPTION_MONITOR      '@MS@'."  Stop
829    ICON_2 ICON_BOOKMARK                  '@MT@'."  Stop
830    ICON_2 ICON_TRANSFER_STRUCTURE_INA    '@MU@'."  Stop
831    ICON_2 ICON_EXCEPTION                 '@MV@'."  Stop
832    ICON_2 ICON_RANKING                   '@MW@'."  Stop
833    ICON_2 ICON_PPE_BHNODE                '@MX@'."  Stop
834    ICON_2 ICON_PPE_AENODE                '@MY@'."  Stop
835    ICON_2 ICON_PPE_ANODE                 '@MZ@'."  Stop
836    ICON_2 ICON_PPE_CVNODE                '@N0@'."  Stop
837    ICON_2 ICON_PPE_SNODE                 '@N1@'."  Stop
838    ICON_2 ICON_PPE_ENODE                 '@N2@'."  Stop
839    ICON_2 ICON_PPE_APNODE                '@N3@'."  Stop
840    ICON_2 ICON_PPE_VNODE                 '@N4@'."  Stop
841    ICON_2 ICON_PPE_MODNODE               '@N5@'."  Stop
842    ICON_2 ICON_PPE_AANODE                '@N6@'."  Stop
843    ICON_2 ICON_PPE_AAEXPNODE             '@N7@'."  Stop
844    ICON_2 ICON_PPE_OPNODE                '@N8@'."  Stop
845    ICON_2 ICON_PPE_ACTNODE               '@N9@'."  Stop
846    ICON_2 ICON_PPE_VACTNODE              '@NA@'."  Stop
847    ICON_2 ICON_PPE_VANODE                '@NB@'."  Stop
848    ICON_2 ICON_PPE_LSEG                  '@NC@'."  Stop
849    ICON_2 ICON_PPE_PLINE                 '@ND@'."  Stop
850    ICON_2 ICON_PPE_BPNODE                '@NE@'."  Stop
851    ICON_2 ICON_GIS_BAR                   '@NF@'."  Stop
852    ICON_2 ICON_GIS_COLOR_SHADING         '@NG@'."  Stop
853    ICON_2 ICON_GIS_DEMOTE                '@NH@'."  Stop
854    ICON_2 ICON_GIS_DOT_DENSITY           '@NI@'."  Stop
855    ICON_2 ICON_GIS_LAYER_PROPERTIES      '@NJ@'."  Stop
856    ICON_2 ICON_GIS_PAN                   '@NK@'."  Stop
857    ICON_2 ICON_GIS_PIE                   '@NL@'."  Stop
858    ICON_2 ICON_GIS_PROMOTE               '@NM@'."  Stop
859    ICON_2 ICON_GIS_SPATIAL_SELECT        '@NN@'."  Stop
860    ICON_2 ICON_GIS_SYMBOL                '@NO@'."  Stop
861    ICON_2 ICON_CALL_ANSWER               '@NP@'."  Stop
862    ICON_2 ICON_CALL_ALTERNATE            '@NQ@'."  Stop
863    ICON_2 ICON_CALL_HOLD                 '@NR@'."  Stop
864    ICON_2 ICON_CALL_DEFLECT              '@NS@'."  Stop
865    ICON_2 ICON_CALL_CONSULT              '@NT@'."  Stop
866    ICON_2 ICON_CALL_CONFERENCE           '@NU@'."  Stop
867    ICON_2 ICON_CALL_BLIND_TRANSFER       '@NV@'."  Stop
868    ICON_2 ICON_CALL_RECONNECT            '@NW@'."  Stop
869    ICON_2 ICON_CALL_RETRIEVE             '@NX@'."  Stop
870    ICON_2 ICON_CALL_WARM_TRANSFER        '@NY@'."  Stop
871    ICON_2 ICON_CREATE_CALLBACK           '@NZ@'."  Stop
872    ICON_2 ICON_PROCESS_CALLBACK          '@O0@'."  Stop
873    ICON_2 ICON_BW_RA_SETTING_ACTIVE      '@O1@'."  Stop
874    ICON_2 ICON_BW_RA_SETTING_INACTIVE    '@O2@'."  Stop
875    ICON_2 ICON_SNC_INFO                  '@O3@'."  Stop
876    ICON_2 ICON_DELIVERY                  '@O4@'."  Stop
877    ICON_2 ICON_PPE_ASSY_POS              '@O5@'."  Stop
878    ICON_2 ICON_PPE_ASSY_HEAD             '@O6@'."  Stop
879    ICON_2 ICON_PPE_PARTOF_ALT_ACT        '@O7@'."  Stop
880    ICON_2 ICON_BINARY_DOCUMENT           '@O8@'."  Stop
881    ICON_2 ICON_ANY_DOCUMENT              '@O9@'."  Stop
882    ICON_2 ICON_OTF_DOCUMENT              '@OA@'."  Stop
883    ICON_2 ICON_TEXT_FIELD                '@OB@'."  Stop
884    ICON_2 ICON_FIELD_WITH_TEXT           '@OC@'."  Stop
885    ICON_2 ICON_SIMPLE_FIELD              '@OD@'."  Stop
886    ICON_2 ICON_TRANSPORT_PROPOSAL        '@OE@'."  Stop
887    ICON_2 ICON_HELPASSISTENT_ON          '@OF@'."  Stop
888    ICON_2 ICON_HELPASSISTENT_OFF         '@OG@'."  Stop
889    ICON_2 ICON_DIALGHELP                 '@OH@'."  Stop
890    ICON_2 ICON_DIALOGHELPACTIV           '@OI@'."  Stop
891    ICON_2 ICON_STATUS_CRITICAL           '@OJ@'."  Stop
892    ICON_2 ICON_SYSTEM_SERVICE_FILLED     '@OK@'."  Stop
893    ICON_2 ICON_SYSTEM_SERVICE_OFF        '@OL@'."  Stop
894    ICON_2 ICON_SYSTEM_SERVICE_EMPTY      '@OM@'."  Stop
895    ICON_2 ICON_CONSUMPTION_ALTERNATIVE   '@ON@'."  Stop
896    ICON_2 ICON_PROCUREMENT_ALTERNATIVE   '@OO@'."  Stop
897    ICON_2 ICON_PROCUREMENT_PROCESS       '@OP@'."  Stop
898    ICON_2 ICON_WORKFLOW                  '@OQ@'."  Stop
899    ICON_2 ICON_DOCUMENT_MODEL_SPACE      '@OR@'."  Stop
900    ICON_2 ICON_RELATION_CLASS            '@OS@'."  Stop
901    ICON_2 ICON_IO_ATTRIBUTE              '@OT@'."  Stop
902    ICON_2 ICON_VIRTUAL_RELATION_CLASS    '@OU@'."  Stop
903    ICON_2 ICON_CLASS_CONNECTION_SPACE    '@OV@'."  Stop
904    ICON_2 ICON_IO_PREDEFINED_VALUE       '@OW@'."  Stop
905    ICON_2 ICON_CONTEXT_CLASS             '@OX@'."  Stop
906    ICON_2 ICON_LOIO_CLASS                '@OY@'."  Stop
907    ICON_2 ICON_VIRTUAL_LOIO_CLASS        '@OZ@'."  Stop
908    ICON_2 ICON_PHIO_CLASS                '@P0@'."  Stop
909    ICON_2 ICON_VIRTUAL_PHIO_CLASS        '@P1@'."  Stop
910    ICON_2 ICON_PARAGRAPH                 '@P2@'."  Stop
911    ICON_2 ICON_MC_CONTENTINDICATOR       '@P3@'."  Stop
912    ICON_2 ICON_BSC_CONTENTINDICATOR      '@P4@'."  Stop
913    ICON_2 ICON_RATING_MINUSMINUS         '@P5@'."  Stop
914    ICON_2 ICON_RATING_MINUS              '@P6@'."  Stop
915    ICON_2 ICON_RATING_NEUTRAL            '@P7@'."  Stop
916    ICON_2 ICON_RATING_POSITIVE           '@P8@'."  Stop
917    ICON_2 ICON_RATING_POSITIVEPOSITIVE   '@P9@'."  Stop
918    ICON_2 ICON_WORKFLOW_WEB_ACTIVITY     '@PA@'."  Stop
919    ICON_2 ICON_DELIVERY_NO_CONFIRMATION  '@PB@'."  Stop
920    ICON_2 ICON_SNAP_TO_GRID              '@PC@'."  Stop
921    ICON_2 ICON_GRID                      '@PD@'."  Stop
922    ICON_2 ICON_MAIN_GRID                 '@PE@'."  Stop
923    ICON_2 ICON_TARGET_GROUP              '@PF@'."  Stop
924    ICON_2 ICON_DELIVERY_INBOUND          '@PG@'."  Stop
925    ICON_2 ICON_PPE_LBAL                  '@PH@'."  Stop
926    ICON_2 ICON_PPE_ENTOBJ                '@PI@'."  Stop
927    ICON_2 ICON_PAW_TEST                  '@PJ@'."  Stop
928    ICON_2 ICON_PAW_SUBTEST               '@PK@'."  Stop
929    ICON_2 ICON_PAW_PU                    '@PL@'."  Stop
930    ICON_2 ICON_PAW_ITEM                  '@PM@'."  Stop
931    ICON_2 ICON_BUSINESS_AREA             '@PN@'."  Stop
932    ICON_2 ICON_DATABASE_TABLE            '@PO@'."  Stop
933    ICON_2 ICON_DATABASE_TABLE_INA        '@PP@'."  Stop
934    ICON_2 ICON_CONNECTION_OBJECT         '@PQ@'."  Stop
935    ICON_2 ICON_CONTRACT_ACCOUNT          '@PR@'."  Stop
936    ICON_2 ICON_REGISTER                  '@PS@'."  Stop
937    ICON_2 ICON_INSTALLATION              '@PT@'."  Stop
938    ICON_2 ICON_BORDER_TOP                '@PU@'."  Stop
939    ICON_2 ICON_BORDER_RIGHT              '@PV@'."  Stop
940    ICON_2 ICON_BORDER_OUTSIDE            '@PW@'."  Stop
941    ICON_2 ICON_BORDER_LEFT               '@PX@'."  Stop
942    ICON_2 ICON_BORDER_BOTTOM             '@PY@'."  Stop
943    ICON_2 ICON_BORDER_INSIDE             '@PZ@'."  Stop
944    ICON_2 ICON_DELETE_TEMPLATE           '@Q0@'."  Stop
945    ICON_2 ICON_SAVE_AS_TEMPLATE          '@Q1@'."  Stop
946    ICON_2 ICON_PATIENT_SMARTCARD         '@Q2@'."  Stop
947    ICON_2 ICON_INITIAL                   '@Q3@'."  Stop
948    ICON_2 ICON_GENERAL_RECIPE            '@Q4@'."  Stop
949    ICON_2 ICON_WORKFLOW_ADHOC_ANCHOR     '@Q5@'."  Stop
950    ICON_2 ICON_PRICE_ANALYSIS            '@Q6@'."  Stop
951    ICON_2 ICON_COST_COMPONENTS           '@Q7@'."  Stop
952    ICON_2 ICON_VAL_QUANTITY_STRUCTURE    '@Q8@'."  Stop
953    ICON_2 ICON_REVALUATED_CONS_ALTERNAT  '@Q9@'."  Stop
954    ICON_2 ICON_PACKAGE_QUERY             '@QA@'."  Stop
955    ICON_2 ICON_PACKAGE_DYNAMIC           '@QB@'."  Stop
956    ICON_2 ICON_PACKAGE_STANDARD          '@QC@'."  Stop
957    ICON_2 ICON_PACKAGE_APPLICATION       '@QD@'."  Stop
958    ICON_2 ICON_LINKED_DOCUMENT           '@QE@'."  Stop
959    ICON_2 ICON_CLOSED_LINKED_FOLDER      '@QF@'."  Stop
960    ICON_2 ICON_OPEN_LINKED_FOLDER        '@QG@'."  Stop
961    ICON_2 ICON_REPORT_TEMPLATE           '@QH@'."  Stop
962    ICON_2 ICON_INFOSET_ACT               '@QI@'."  Stop
963    ICON_2 ICON_INFOSET_INA               '@QJ@'."  Stop
964    ICON_2 ICON_CHARACTERISTICS_FML       '@QK@'."  Stop
965    ICON_2 ICON_CHARACTERISTICS_HIER      '@QL@'."  Stop
966    ICON_2 ICON_HIERARCHY_RED             '@QM@'."  Stop
967    ICON_2 ICON_HIERARCHY_VAR_GREEN       '@QN@'."  Stop
968    ICON_2 ICON_HIERARCHY_VAR_RED         '@QO@'."  Stop
969    ICON_2 ICON_KEYFIGURE_FML             '@QP@'."  Stop
970    ICON_2 ICON_VAR_EQUAL_GREEN           '@QQ@'."  Stop
971    ICON_2 ICON_VAR_EQUAL_RED             '@QR@'."  Stop
972    ICON_2 ICON_VAR_GR_EQUAL_GREEN        '@QS@'."  Stop
973    ICON_2 ICON_VAR_GREATER_GREEN         '@QT@'."  Stop
974    ICON_2 ICON_VAR_LESS_EQUAL_GREEN      '@QU@'."  Stop
975    ICON_2 ICON_VAR_LESS_GREEN            '@QV@'."  Stop
976    ICON_2 ICON_VAR_INT_INCLUDE_GREEN     '@QW@'."  Stop
977    ICON_2 ICON_VAR_INT_INCLUDE_RED       '@QX@'."  Stop
978    ICON_2 ICON_MULTI_DATA_PROVIDER       '@QY@'."  Stop
979    ICON_2 ICON_MULTI_DATA_PROVIDER_INA   '@QZ@'."  Stop
980    ICON_2 ICON_BW_SOURCE_SYS_DB          '@R0@'."  Stop
981    ICON_2 ICON_BW_SOURCE_SYS_WEB         '@R1@'."  Stop
982    ICON_2 ICON_BW_DATASOURCE             '@R2@'."  Stop
983    ICON_2 ICON_BW_WEB_REPORT             '@R3@'."  Stop
984    ICON_2 ICON_XML_DOC                   '@R4@'."  Stop
985    ICON_2 ICON_DROPDOWNLIST              '@R5@'."  Stop
986    ICON_2 ICON_RADIOBUTTON               '@R6@'."  Stop
987    ICON_2 ICON_CHECKBOX                  '@R7@'."  Stop
988    ICON_2 ICON_GEO_CHARACTERISTIC        '@R8@'."  Stop
989    ICON_2 ICON_GEO_CHARACTERISTIC_INA    '@R9@'."  Stop
990    ICON_2 ICON_MANIKIN_FEMALE            '@RA@'."  Stop
991    ICON_2 ICON_MANIKIN_MALE              '@RB@'."  Stop
992    ICON_2 ICON_MANIKIN_UNKNOWN_GENDER    '@RC@'."  Stop
993    ICON_2 ICON_SYMBOL_FEMALE             '@RD@'."  Stop
994    ICON_2 ICON_SYMBOL_MALE               '@RE@'."  Stop
995    ICON_2 ICON_DECEASED_PATIENT          '@RF@'."  Stop
996    ICON_2 ICON_WD_APPL_COMPONENT         '@RG@'."  Stop
997    ICON_2 ICON_WD_TAG_LIBRARY            '@RH@'."  Stop
998    ICON_2 ICON_WD_TAB_LIBRARY_REF        '@RI@'."  Stop
999    ICON_2 ICON_WD_WEB_PROJECT            '@RJ@'."  Stop
1000   ICON_2 ICON_WD_WEB_APPL_PROJECT       '@RK@'."  Stop
1001   ICON_2 ICON_WD_INBOUND_PLUG           '@RL@'."  Stop
1002   ICON_2 ICON_WD_OUTBOUND_PLUG          '@RM@'."  Stop
1003   ICON_2 ICON_WD_VIEW                   '@RN@'."  Stop
1004   ICON_2 ICON_WD_VIEWS                  '@RO@'."  Stop
1005   ICON_2 ICON_WD_INTERFACE_VIEW         '@RP@'."  Stop
1006   ICON_2 ICON_WD_INTERFACE_VIEWS        '@RQ@'."  Stop
1007   ICON_2 ICON_WD_VIEW_AREA              '@RR@'."  Stop
1008   ICON_2 ICON_WD_VIEW_SET_T_LAYOUT      '@RS@'."  Stop
1009   ICON_2 ICON_WD_VIEW_SET_T_LAYOUT_REV  '@RT@'."  Stop
1010   ICON_2 ICON_WD_VIEW_SET_T_LAYOUT_270  '@RU@'."  Stop
1011   ICON_2 ICON_WD_VIEW_SET_T_LAYOUT_90   '@RV@'."  Stop
1012   ICON_2 ICON_WD_VIEW_SET_TAB_LAYOUT    '@RW@'."  Stop
1013   ICON_2 ICON_WD_VIEW_SET_GRID          '@RX@'."  Stop
1014   ICON_2 ICON_WD_VIEW_CONTAINER         '@RY@'."  Stop
1015   ICON_2 ICON_WD_WINDOWS_COLLECTION     '@RZ@'."  Stop
1016   ICON_2 ICON_WD_WINDOW                 '@S0@'."  Stop
1017   ICON_2 ICON_WD_BUILD_ALL              '@S1@'."  Stop
1018   ICON_2 ICON_WD_BUILD_INCREMENTAL      '@S2@'."  Stop
1019   ICON_2 ICON_WD_COMPONENTS             '@S3@'."  Stop
1020   ICON_2 ICON_WD_COMPONENT              '@S4@'."  Stop
1021   ICON_2 ICON_WD_COMPONENT_INTERFACE    '@S5@'."  Stop
1022   ICON_2 ICON_WD_APPLICATION            '@S6@'."  Stop
1023   ICON_2 ICON_WD_APPLICATIONS           '@S7@'."  Stop
1024   ICON_2 ICON_WD_CONTEXT                '@S8@'."  Stop
1025   ICON_2 ICON_WD_VALUE_NODE             '@S9@'."  Stop
1026   ICON_2 ICON_WD_VALUE_ATTR             '@SA@'."  Stop
1027   ICON_2 ICON_WD_MAPPED_VALUE_NODE      '@SB@'."  Stop
1028   ICON_2 ICON_WD_MAPPED_VALUE_ATTR      '@SC@'."  Stop
1029   ICON_2 ICON_WD_MODEL_NODE             '@SD@'."  Stop
1030   ICON_2 ICON_WD_MODEL_ATTRIBUTE        '@SE@'."  Stop
1031   ICON_2 ICON_WD_MAPPED_MODEL_NODE      '@SF@'."  Stop
1032   ICON_2 ICON_WD_MAPPED_MODEL_ATTR      '@SG@'."  Stop
1033   ICON_2 ICON_WD_RECURSION_NODE         '@SH@'."  Stop
1034   ICON_2 ICON_WD_IMAGE                  '@SI@'."  Stop
1035   ICON_2 ICON_WD_CAPTION                '@SJ@'."  Stop
1036   ICON_2 ICON_WD_BUSINESS_GRAPHICS      '@SK@'."  Stop
1037   ICON_2 ICON_WD_LABEL                  '@SL@'."  Stop
1038   ICON_2 ICON_WD_INPUT_FIELD            '@SM@'."  Stop
1039   ICON_2 ICON_WD_NUMERIC_VALUE          '@SN@'."  Stop
1040   ICON_2 ICON_WD_TIME_VALUE             '@SO@'."  Stop
1041   ICON_2 ICON_WD_CHECK_BOX_INDEXED      '@SP@'."  Stop
1042   ICON_2 ICON_WD_CHECK_BOX_GROUP        '@SQ@'."  Stop
1043   ICON_2 ICON_WD_RADIO_BUTTON_EMPTY     '@SR@'."  Stop
1044   ICON_2 ICON_WD_RADIO_BUTTON_INDEX     '@SS@'."  Stop
1045   ICON_2 ICON_WD_RADIO_BUTTON_KEY       '@ST@'."  Stop
1046   ICON_2 ICON_WD_DROPDOWN_INDEX         '@SU@'."  Stop
1047   ICON_2 ICON_WD_DROPDOWN_KEY           '@SV@'."  Stop
1048   ICON_2 ICON_WD_LINK_TO_ACTION         '@SW@'."  Stop
1049   ICON_2 ICON_WD_LINK_TO_URL            '@SX@'."  Stop
1050   ICON_2 ICON_WD_TOOLBAR_BUTTON         '@SY@'."  Stop
1051   ICON_2 ICON_WD_TOOLBAR_DROPDOWN_IDX   '@SZ@'."  Stop
1052   ICON_2 ICON_WD_TOOLBAR_DROPDOWN_KEY   '@T0@'."  Stop
1053   ICON_2 ICON_WD_TOOLBAR_INPUT_FIELD    '@T1@'."  Stop
1054   ICON_2 ICON_WD_TOOLBAR_SEPARATOR      '@T2@'."  Stop
1055   ICON_2 ICON_WD_TOOLBAR_CAPTION        '@T3@'."  Stop
1056   ICON_2 ICON_WD_TABLE                  '@T4@'."  Stop
1057   ICON_2 ICON_WD_TABLE_COLUMN           '@T5@'."  Stop
1058   ICON_2 ICON_WD_TREE                   '@T6@'."  Stop
1059   ICON_2 ICON_WD_TREE_NODE              '@T7@'."  Stop
1060   ICON_2 ICON_WD_TREE_ITEM              '@T8@'."  Stop
1061   ICON_2 ICON_WD_IFRAME                 '@T9@'."  Stop
1062   ICON_2 ICON_WD_CHECK_BOX              '@TA@'."  Stop
1063   ICON_2 ICON_WD_RADIO_BUTTON           '@TB@'."  Stop
1064   ICON_2 ICON_WD_BUTTON                 '@TC@'."  Stop
1065   ICON_2 ICON_WD_TEXT_VIEW              '@TD@'."  Stop
1066   ICON_2 ICON_WD_TEXT_EDIT              '@TE@'."  Stop
1067   ICON_2 ICON_WD_TOOLBAR                '@TF@'."  Stop
1068   ICON_2 ICON_WD_TABSTRIP               '@TG@'."  Stop
1069   ICON_2 ICON_WD_TAB                    '@TH@'."  Stop
1070   ICON_2 ICON_WD_GROUP                  '@TI@'."  Stop
1071   ICON_2 ICON_WD_TRAY                   '@TJ@'."  Stop
1072   ICON_2 ICON_WD_TRANSPARENT_CONTAINER  '@TK@'."  Stop
1073   ICON_2 ICON_WD_SCROLL_CONTAINER       '@TL@'."  Stop
1074   ICON_2 ICON_WD_NAVIGATION_LINK        '@TM@'."  Stop
1075   ICON_2 ICON_WD_NAVLINK_BIDIRECTIONAL  '@TN@'."  Stop
1076   ICON_2 ICON_WD_NAVLINK_OUT            '@TO@'."  Stop
1077   ICON_2 ICON_WD_NAVLINK_IN             '@TP@'."  Stop
1078   ICON_2 ICON_WD_CONTROLLER             '@TQ@'."  Stop
1079   ICON_2 ICON_CONTEXT_MENU              '@TR@'."  Stop
1080   ICON_2 ICON_ERASE                     '@TS@'."  Stop
1081   ICON_2 ICON_RETAIL_PRODUCT            '@TT@'."  Stop
1082   ICON_2 ICON_RETAIL_STORE              '@TU@'."  Stop
1083   ICON_2 ICON_HANDLING_UNIT             '@TV@'."  Stop
1084   ICON_2 ICON_BW_DM                     '@TW@'."  Stop
1085   ICON_2 ICON_BW_APD_VISUALIZATION      '@TX@'."  Stop
1086   ICON_2 ICON_BW_APD_TARGET             '@TY@'."  Stop
1087   ICON_2 ICON_BW_APD_TRANSFORMATION     '@TZ@'."  Stop
1088   ICON_2 ICON_BW_APD_SOURCE             '@U0@'."  Stop
1089   ICON_2 ICON_BW_APD_COLUMN_TO_ROW      '@U1@'."  Stop
1090   ICON_2 ICON_BW_APD_ROW_TO_COLUMN      '@U2@'."  Stop
1091   ICON_2 ICON_BW_APD_DB                 '@U3@'."  Stop
1092   ICON_2 ICON_BW_APD                    '@U4@'."  Stop
1093   ICON_2 ICON_BW_DM_3RD                 '@U5@'."  Stop
1094   ICON_2 ICON_BW_DM_WST                 '@U6@'."  Stop
1095   ICON_2 ICON_BW_APD_REGRESSION         '@U7@'."  Stop
1096   ICON_2 ICON_BW_DM_CLUS                '@U8@'."  Stop
1097   ICON_2 ICON_BW_DM_AA                  '@U9@'."  Stop
1098   ICON_2 ICON_BW_DM_DT                  '@UA@'."  Stop
1099   ICON_2 ICON_BW_CONVERT_UNIT           '@UB@'."  Stop
1100   ICON_2 ICON_BW_PLANNING_LAYER         '@UC@'."  Stop
1101   ICON_2 ICON_BW_PLANNING_LAYER_INA     '@UD@'."  Stop
1102   ICON_2 ICON_BW_OPEN_HUB_DESTINATION   '@UE@'."  Stop
1103   ICON_2 ICON_BW_ROTATE_RIGHT           '@UF@'."  Stop
1104   ICON_2 ICON_BW_ROTATE_LEFT            '@UG@'."  Stop
1105   ICON_2 ICON_VIEW_FORM                 '@UH@'."  Stop
1106   ICON_2 ICON_VIEW_LIST                 '@UI@'."  Stop
1107   ICON_2 ICON_MEDIUM                    '@UJ@'."  Stop
1108   ICON_2 ICON_VIEW_MAXIMIZE             '@UK@'."  Stop
1109   ICON_2 ICON_VIEW_EXPAND_VERTICAL      '@UL@'."  Stop
1110   ICON_2 ICON_VIEW_EXPAND_HORIZONTAL    '@UM@'."  Stop
1111   ICON_2 ICON_VIEW_REFRESH              '@UN@'."  Stop
1112   ICON_2 ICON_VIEW_CREATE               '@UO@'."  Stop
1113   ICON_2 ICON_VIEW_CLOSE                '@UP@'."  Stop
1114   ICON_2 ICON_VIEW_SWITCH               '@UQ@'."  Stop
1115   ICON_2 ICON_BREAKPOINT_DISABLE        '@UR@'."  Stop
1116   ICON_2 ICON_WD_CUSTOM_CONTROLLER      '@US@'."  Stop
1117   ICON_2 ICON_WD_CUSTOM_CONTROLLERS     '@UT@'."  Stop
1118   ICON_2 ICON_WD_INPUT_MODEL_ATT        '@UU@'."  Stop
1119   ICON_2 ICON_WD_INPUT_MODEL_NODE       '@UV@'."  Stop
1120   ICON_2 ICON_WD_INPUT_VAL_ATT          '@UW@'."  Stop
1121   ICON_2 ICON_WD_INPUT_VAL_NODE         '@UX@'."  Stop
1122   ICON_2 ICON_WD_MAPPED_INPUT_MODEL_ATT '@UY@'."  Stop
1123   ICON_2 ICON_WD_MAPPED_INPUT_MODEL_NOD '@UZ@'."  Stop
1124   ICON_2 ICON_WD_MAPPED_INPUT_VAL_ATT   '@V0@'."  Stop
1125   ICON_2 ICON_WD_MAPPED_INPUT_VAL_NODE  '@V1@'."  Stop
1126   ICON_2 ICON_WD_COMPONENT_CTRL         '@V2@'."  Stop
1127   ICON_2 ICON_WD_COMPONENT_CTRL_USAGE   '@V3@'."  Stop
1128   ICON_2 ICON_WD_COMPONENT_IF_CTRL      '@V4@'."  Stop
1129   ICON_2 ICON_COMPONENT_IF_DEF          '@V5@'."  Stop
1130   ICON_2 ICON_COMPONENT_IF_DEFS         '@V6@'."  Stop
1131   ICON_2 ICON_WD_COMPONENT_USAGE        '@V7@'."  Stop
1132   ICON_2 ICON_WD_COMPONENT_USAGES       '@V8@'."  Stop
1133   ICON_2 ICON_WEBBREAKPOINT             '@V9@'."  Stop
1134   ICON_2 ICON_WEBBREAKPOINT_DISABLED    '@VA@'."  Stop
1135   ICON_2 ICON_USER_BREAKPOINT           '@VB@'."  Stop
1136   ICON_2 ICON_USER_BREAKPOINT_DISABLED  '@VC@'."  Stop
1137   ICON_2 ICON_CLIENT_BREAKPOINT         '@VD@'."  Stop
1138   ICON_2 ICON_CLIENT_BREAKPOINT_DIS     '@VE@'."  Stop
1139   ICON_2 ICON_ES_REPOSITORY             '@VF@'."  Stop
1140   ICON_2 ICON_RED_DASH                  '@VG@'."  Stop
1141   ICON_2 ICON_RED_SLASH                 '@VH@'."  Stop
1142   ICON_2 ICON_RED_XCIRCLE               '@VI@'."  Stop
1143   ICON_2 ICON_VALUE_HELP                '@VJ@'."  Stop
1144   ICON_2 ICON_BW_DTP_ACTIVE             '@VK@'."  Stop
1145   ICON_2 ICON_BW_DTP_INACTIVE           '@VL@'."  Stop
1146   ICON_2 ICON_BW_OPEN_HUB_INACTIVE      '@VM@'."  Stop
1147   ICON_2 ICON_OO_INTERFACE_MSGTP        '@VN@'."  Stop
1148   ICON_2 ICON_OO_INTERFACE_FAULT_MSGTP  '@VO@'."  Stop
1149   ICON_2 ICON_SEGMENTED_DATA_ACT        '@VP@'."  Stop
1150   ICON_2 ICON_SEGMENTED_DATA_INA        '@VQ@'."  Stop
1151   ICON_2 ICON_BIW_VIRTUAL_INFO_PROVIDER '@VR@'."  Stop
1152   ICON_2 ICON_BIW_VIRTUAL_INFO_PROV_INA '@VS@'."  Stop
1153   ICON_2 ICON_ALL_GREEN                 '@VT@'."  Stop
1154   ICON_2 ICON_BW_SOURCE_SYS_UDC         '@VU@'."  Stop
1155   ICON_2 ICON_AGENT                     '@VV@'."  Stop
1156   ICON_2 ICON_BIW_INFO_SOURCE_INA       '@VW@'."  BW Info Source Inactive
1157   ICON_2 ICON_CHECKED_OUT               '@VX@'."  Checked Out
1158   ICON_2 ICON_CHECKIN_REQUESTED         '@VY@'."  Request Check In
1159   ICON_2 ICON_CHECKOUT_REQUESTED        '@VZ@'."  Request Check Out
1160   ICON_2 ICON_MESSAGE_TYPE              '@W0@'."  Message
1161   ICON_2 ICON_MESSAGE_FAULTY            '@W1@'."  Error Message
1162   ICON_2 ICON_BUSINAV_OBJECTS_UPTODATE  '@W2@'."  Business Object (Current
1163   ICON_2 ICON_BUSINAV_OBJECTS_OUTDATE   '@W3@'."  Business Object (Old)
1164   ICON_2 ICON_BUSINAV_OBJECTS_ORPHAN    '@W4@'."  Business Object (Orphane
1165   ICON_2 ICON_CLOSED_FOLDER_UPTODATE    '@W5@'."  Folder (Current)
1166   ICON_2 ICON_CLOSED_FOLDER_OUTDATE     '@W6@'."  Folder (Old)
1167   ICON_2 ICON_CLOSED_FOLDER_ORPHANED    '@W7@'."  Folder (Orphaned)
1168   ICON_2 ICON_MESSAGE_UPTODATE          '@W8@'."  Message (Current)
1169   ICON_2 ICON_MESSAGE_OUTOFDATE         '@W9@'."  Message (Old)
1170   ICON_2 ICON_MESSAGE_ORPHANED          '@WA@'."  Message (Orphaned)
1171   ICON_2 ICON_MESSAGE_FAULTY_UPTODATE   '@WB@'."  Error Message (Current)
1172   ICON_2 ICON_MESSAGE_FAULTY_OUTDATE    '@WC@'."  Error Message (Old)
1173   ICON_2 ICON_MESSAGE_FAULTY_ORPHAN     '@WD@'."  Error Message (Orphaned)
1174   ICON_2 ICON_OO_INTERFACE_UPTODATE     '@WE@'."  Object Interface (Curren
1175   ICON_2 ICON_OO_INTERFACE_OUTDATE      '@WF@'."  Object Interface (Old)
1176   ICON_2 ICON_OO_INTERFACE_ORPHAN       '@WG@'."  Object Interface (Orphan
1177   ICON_2 ICON_DATATYPES_UPTODATE        '@WH@'."  Data Types (Current)
1178   ICON_2 ICON_DATATYPES_OUTDATE         '@WI@'."  Data Types (Old)
1179   ICON_2 ICON_DATATYPES_ORPHAN          '@WJ@'."  Data Types (Orphaned)
1180   ICON_2 ICON_DATATYPES_ENH_UPTODATE    '@WK@'."  Data Type Enhancement (C
1181   ICON_2 ICON_DATATYPES_ENH_OUTDATE     '@WL@'."  Data Type Enhancement (O
1182   ICON_2 ICON_DATATYPES_ENH_ORPHAN      '@WM@'."  Data Type Enhancement (O
1183   ICON_2 ICON_AGENT_UPTODATE            '@WN@'."  Agent (Current)
1184   ICON_2 ICON_AGENT_OUTDATE             '@WO@'."  Agent (Old)
1185   ICON_2 ICON_AGENT_ORPHAN              '@WP@'."  Agent (Orphaned)
1186   ICON_2 ICON_ENHANCED_BO               '@WQ@'."  Enhanced Business Object
1187   ICON_2 ICON_ENHANCED_BO_UPTODATE      '@WR@'."  Enh. Business Object (Cu
1188   ICON_2 ICON_ENHANCED_BO_OUTDATE       '@WS@'."  Enhance. Business Object
1189   ICON_2 ICON_ENHANCED_BO_ORPHAN        '@WT@'."  En. Business Object (Orp
1190   ICON_2 ICON_STORES                    '@WU@'."  Subsidiaries
1191   ICON_2 ICON_WAREHOUSES                '@WV@'."  Multiple Central Warehou
1192   ICON_2 ICON_CONDITION_BREAKPOINT      '@WW@'."  Multiple Central Warehou
1193   ICON_2 ICON_CONDITION_BREAKPOINT_DIS  '@WX@'."  Multiple Central Warehou
1194   ICON_2 ICON_JOB_FAMILY                '@WY@'."  Multiple Central Warehou
1195   ICON_2 ICON_INTELLECTUAL_PROPERTY     '@WZ@'."  Multiple Central Warehou
1196   ICON_2 ICON_PROPRIETARY               '@X0@'."  Multiple Central Warehou
1197   ICON_2 ICON_INSTALL_PACKAGE           '@X1@'."  Multiple Central Warehou
1198   ICON_2 ICON_SAP_LOGON                 '@X2@'."  Multiple Central Warehou
1199   ICON_2 ICON_SAP_SHORTCUT              '@X3@'."  Multiple Central Warehou
1200   ICON_2 ICON_SAP_GUI_SESSION           '@X4@'."  Multiple Central Warehou
1201   ICON_2 ICON_SAP_SERVER                '@X5@'."  Multiple Central Warehou
1202   ICON_2 ICON_SAP_LOGON_SERVER_SSO      '@X6@'."  Multiple Central Warehou
1203   ICON_2 ICON_SAP_LOGON_USERDEFINED     '@X7@'."  Multiple Central Warehou
1204   ICON_2 ICON_SAP_LOGON_USERDEFINED_SSO '@X8@'."  Multiple Central Warehou
1205   ICON_2 ICON_SAP_LOGON_GROUP           '@X9@'."  Multiple Central Warehou
1206   ICON_2 ICON_SAP_LOGON_GROUP_SSO       '@XA@'."  Multiple Central Warehou
1207   ICON_2 ICON_SAP_LOGON_GROUP_USER      '@XB@'."  Multiple Central Warehou
1208   ICON_2 ICON_SETTINGS                  '@XC@'."  Multiple Central Warehou
1209   ICON_2 ICON_VIEW_TABLE                '@XD@'."  Multiple Central Warehou
1210   ICON_2 ICON_VIEW_HIER_LIST            '@XE@'."  Multiple Central Warehou
1211   ICON_2 ICON_VIEW_TREE                 '@XF@'."  Multiple Central Warehou
1212   ICON_2 ICON_VIEW_THUMBNAILS           '@XG@'."  Multiple Central Warehou
1213   ICON_2 ICON_SAP_LOGON_GROUP_CERT      '@XH@'."  Multiple Central Warehou
1214   ICON_2 ICON_SAP_LOGON_GROUP_CERT_SSO  '@XI@'."  Multiple Central Warehou
1215   ICON_2 ICON_SAP_LOGON_GROUP_CERT_USER '@XJ@'."  Multiple Central Warehou
1216   ICON_2 ICON_LOGON_GROUP_CERT_SSO_USR  '@XK@'."  Multiple Central Warehou
1217   ICON_2 ICON_SAP_LOGON_SRV_CERT        '@XL@'."  Multiple Central Warehou
1218   ICON_2 ICON_SAP_LOGON_SRV_CERT_SSO    '@XM@'."  Multiple Central Warehou
1219   ICON_2 ICON_SAP_LOGON_SRV_CERT_USER   '@XN@'."  Multiple Central Warehou
1220   ICON_2 ICON_LOGON_SRV_CERT_SSO_USER   '@XO@'."  Multiple Central Warehou
1221   ICON_2 ICON_MASS_CHANGE_DONE          '@XP@'."  Multiple Central Warehou
1222   ICON_2 ICON_REMOVE_ROW                '@XQ@'."  Multiple Central Warehou
1223   ICON_2 ICON_ADD_ROW                   '@XR@'."  Multiple Central Warehou
1224   ICON_2 ICON_SAP_LOGON_GROUP_SSO_USR   '@XS@'."  Multiple Central Warehou
1225   ICON_2 ICON_APPLE_KEYNOTE             '@XT@'."  Multiple Central Warehou
1226   ICON_2 ICON_APPLE_NUMBERS             '@XU@'."  Multiple Central Warehou
1227   ICON_2 ICON_APPLE_PAGES               '@XV@'."  Multiple Central Warehou
1228   ICON_2 ICON_GOS_SERVICES              '@XW@'."  Multiple Central Warehou
1229   ICON_2 ICON_GOS_SERVICES_ATTACHMENT   '@XX@'."  Multiple Central Warehou
1230   ICON_2 ICON_GOS_SERVICES_RELATIONS    '@XY@'."  Multiple Central Warehou
1231   ICON_2 ICON_GOS_SERVICES_ATT_REL      '@XZ@'."  Multiple Central Warehou
1232   ICON_2 ICON_REBATE                    '@Y0@'."  Multiple Central Warehou
1233   ICON_2 ICON_CHARGE                    '@Y1@'."  Multiple Central Warehou
1234   ICON_2 ICON_START_VIEWER              '@Y2@'."  Multiple Central Warehou
1235   ICON_2 ICON_CLOUD                     '@Y3@'."  Multiple Central Warehou
1236   ICON_2 ICON_CLOUD_DOWNLOAD            '@Y4@'."  Multiple Central Warehou
1237   ICON_2 ICON_CLOUD_UPLOAD              '@Y5@'."  Multiple Central Warehou
1238   ICON_2 ICON_SHOPPINGCART              '@Y6@'."  Multiple Central Warehou
1239   ICON_2 ICON_ADD_SHOPPINGCART          '@Y7@'."  Multiple Central Warehou
1240   ICON_2 ICON_REMOVE_SHOPPINGCART       '@Y8@'."  Multiple Central Warehou
1241   ICON_2 ICON_DELETE_SHOPPINGCART       '@Y9@'."  Multiple Central Warehou
1242   ICON_2 ICON_ALV_COLLAPSE              '@YA@'."  Multiple Central Warehou
1243   ICON_2 ICON_ALV_EXPAND                '@YB@'."  Multiple Central Warehou
1244
1245   * bugfix for wrong usage of ICON_BW_SUGGEST_VALUE
1246   ICON_2 ICON_SUGGEST_VALUE             '@F6@'."  Stop
*--- End of %_CICON - 1246 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CKCDE                                   Level 1    Page 12
Object           ZBILL_PROCESS                             Lines 60
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:32
----------------------------------------------------------------------------------------------------
1      TYPE-POOL KCDE .
2      TYPES KCDE_ROW_COL(4) TYPE N.
3      TYPES: KCDE_INTERN_VALUE(32).
4      TYPES: BEGIN OF KCDE_INTERN_STRUC.
5                INCLUDE STRUCTURE  KCDE_CELLS.
6      *        row   type kcde_row_col,
7      *        col   type kcde_row_col,
8      *        value type kcde_intern_value,
9      TYPES: END OF KCDE_INTERN_STRUC.
10     *      end of kcde_intern_struc.
11
12     TYPES: KCDE_SENDER_LINE(4096)      TYPE C.
13     TYPES: BEGIN OF KCDE_SENDER_STRUC,
14              LINE TYPE KCDE_SENDER_LINE,
15            END OF KCDE_SENDER_STRUC.
16
17     TYPES: KCDE_SENDER TYPE KCDE_SENDER_STRUC  OCCURS 0.
18
19     TYPES: BEGIN OF KCDE_RANGE_SENDER_STRUC,
20              DEST     LIKE KCDEDATAR-DEST,
21              RANGE_ID LIKE KCDEDATAR-RANGE_ID,
22              TAB      TYPE KCDE_SENDER,
23            END OF KCDE_RANGE_SENDER_STRUC.
24
25     TYPES: BEGIN OF KCDE_KEY_FIG_STRUC,
26              FILE_ID   LIKE KCDEHEAD-FILE_ID,
27              KEY_ID    LIKE KCDEKEY-KEY_ID,
28              RANGE_ID  LIKE KCDEDATAR-RANGE_ID,
29              ZROW      TYPE KCDE_ROW_COL,
30              COL       TYPE KCDE_ROW_COL,
31              SFELD     LIKE KCDER_H-SFELD,
32           END OF KCDE_KEY_FIG_STRUC.
33
34     TYPES: KCDE_DIRECTORY LIKE RLGRAP-FILENAME OCCURS 0.
35
36     TYPES: KCDE_INTERN  TYPE KCDE_INTERN_STRUC  OCCURS 0.
37
38
39
40
41     TYPES: KCDE_RA_SEND TYPE KCDE_RANGE_SENDER_STRUC OCCURS 4,
42            KCDE_KEY_FIG TYPE KCDE_KEY_FIG_STRUC OCCURS 100.
43
44     TYPES: BEGIN OF KCDE_OBJ_POS,
45              OLROW TYPE KCDE_ROW_COL,
46              OLCOL TYPE KCDE_ROW_COL,
47              URROW TYPE KCDE_ROW_COL,
48              URCOL TYPE KCDE_ROW_COL,
49            END OF KCDE_OBJ_POS.
50
51     TYPES: BEGIN OF KCDE_YS_PROT_KPP,
52              FILENAME LIKE  KCDEFILE-FILENAME,
53              FILE_ID  LIKE  KCDEFILE-FILE_ID,
54              EXTNR    LIKE  BALHDRI-EXTNUMBER,
55              SUBRC    LIKE  SY-SUBRC,
56            END OF KCDE_YS_PROT_KPP.
57
58     TYPES: KCDE_YT_PROT_KPP TYPE KCDE_YS_PROT_KPP OCCURS 30.
59
60     TYPES: KCDE_YT_FILE_ID LIKE KCDEFILE-FILE_ID OCCURS 0.
*--- End of %_CKCDE - 60 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_COLE2                                   Level 1    Page 13
Object           ZBILL_PROCESS                             Lines 43
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:32
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
Generated incl.  %_CSBDST                                  Level 1    Page 14
Object           ZBILL_PROCESS                             Lines 35
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:32
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
Generated incl.  %_CSFES                                   Level 1    Page 15
Object           ZBILL_PROCESS                             Lines 75
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:32
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
Generated incl.  %_CSLIS                                   Level 1    Page 16
Object           ZBILL_PROCESS                             Lines 543
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:32
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
Generated incl.  %_CSOI                                    Level 1    Page 17
Object           ZBILL_PROCESS                             Lines 328
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:32
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
Generated incl.  <REPINI>                                  Level 1    Page 18
Object           ZBILL_PROCESS                             Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:32
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
Generated incl.  <SYSINI>                                  Level 1    Page 19
Object           ZBILL_PROCESS                             Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:32
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
Generated incl.  <SYSSEL>                                  Level 1    Page 20
Object           ZBILL_PROCESS                             Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:32
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
Generated incl.  >ICON<                                    Level 1    Page 21
Object           ZBILL_PROCESS                             Lines 24
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:32
----------------------------------------------------------------------------------------------------
1      ***INCLUDE >ICON< .
2      *** INCLUDE for INCLUDE <ICON>, Definition of Icons                  ***
3
4      * Icon length 2
5      DEFINE ICON_2.
6      CONSTANTS:   &1 TYPE ICON_L2 VALUE  &2.
7      END-OF-DEFINITION.
8
9      * Icon length 4
10     DEFINE ICON_4.
11     CONSTANTS:   &1 TYPE ICON_L4 VALUE  &2.
12     END-OF-DEFINITION.
13
14
15     DEFINE ICON_PREPARE_FOR_MODIFY.
16     * trunkate ICON_ID, e.g.  '@3M@' --> '3M'
17       TRANSLATE &1 USING '@ '.
18       CONDENSE  &1 NO-GAPS.
19     END-OF-DEFINITION.
20
21
22
23
24
*--- End of >ICON< - 24 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  CL_ALV_GRID_VIEW_FRONTEND_DATACT          Level 1    Page 22
Object           ZBILL_PROCESS                             Lines 3
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:32
----------------------------------------------------------------------------------------------------
1      *"* dummy include to reduce generation dependencies between
2      *"* class CL_ALV_GRID_VIEW_FRONTEND_DATA and it's users.
3      *"* touched if any type reference has been changed
*--- End of CL_ALV_GRID_VIEW_FRONTEND_DATACT - 3 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  CX_SALV_API_CONTRACT_VIOLATIONCT          Level 1    Page 23
Object           ZBILL_PROCESS                             Lines 3
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:32
----------------------------------------------------------------------------------------------------
1      *"* dummy include to reduce generation dependencies between
2      *"* class CX_SALV_API_CONTRACT_VIOLATION and it's users.
3      *"* touched if any type reference has been changed
*--- End of CX_SALV_API_CONTRACT_VIOLATIONCT - 3 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  CX_SALV_INDEX_TABLE_NOT_SORTEDCT          Level 1    Page 24
Object           ZBILL_PROCESS                             Lines 3
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:32
----------------------------------------------------------------------------------------------------
1      *"* dummy include to reduce generation dependencies between
2      *"* class CX_SALV_INDEX_TABLE_NOT_SORTED and it's users.
3      *"* touched if any type reference has been changed
*--- End of CX_SALV_INDEX_TABLE_NOT_SORTEDCT - 3 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  DB__SSEL                                  Level 1    Page 25
Object           ZBILL_PROCESS                             Lines 1
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:32
----------------------------------------------------------------------------------------------------
1      * INCLUDE DB__SSEL
*--- End of DB__SSEL - 1 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  IF_SALV_GRID_FRONTEND_ANALYSERIT          Level 1    Page 26
Object           ZBILL_PROCESS                             Lines 3
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:32
----------------------------------------------------------------------------------------------------
1      *"* dummy include to reduce generation dependencies between
2      *"* class IF_SALV_GRID_FRONTEND_ANALYSER and it's users.
3      *"* touched if any type reference has been changed
*--- End of IF_SALV_GRID_FRONTEND_ANALYSERIT - 3 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  OSQL_DYNAMIC_EXTERNAL_ENTITIESCCDEF       Level 1    Page 27
Object           ZBILL_PROCESS                             Lines 4
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:32
----------------------------------------------------------------------------------------------------
1      *"* use this source file for any type of declarations (class
2      *"* definitions, interfaces or type declarations) you need for
3      *"* components in the private section
4
*--- End of OSQL_DYNAMIC_EXTERNAL_ENTITIESCCDEF - 4 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  OSQL_DYNAMIC_EXTERNAL_ENTITIESCI          Level 1    Page 28
Object           ZBILL_PROCESS                             Lines 2
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:32
----------------------------------------------------------------------------------------------------
1        private section.
2          class-data: s_dynamic_entities type dynamic_entities.
*--- End of OSQL_DYNAMIC_EXTERNAL_ENTITIESCI - 2 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  OSQL_DYNAMIC_EXTERNAL_ENTITIESCO          Level 1    Page 29
Object           ZBILL_PROCESS                             Lines 1
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:32
----------------------------------------------------------------------------------------------------
1        protected section.
*--- End of OSQL_DYNAMIC_EXTERNAL_ENTITIESCO - 1 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  OSQL_DYNAMIC_EXTERNAL_ENTITIESCU          Level 1    Page 30
Object           ZBILL_PROCESS                             Lines 17
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:32
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
