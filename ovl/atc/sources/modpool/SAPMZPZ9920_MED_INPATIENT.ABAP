----------------------------------------------------------------------------------------------------
Main program     SAPMZPZ9920_MED_INPATIENT                 Level 0    Page 1
Object           SAPMZPZ9920_MED_INPATIENT                 Lines 104
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:24
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *& Module pool       SAPMZPZ9920_MED_INPATIENT
3      *
4      *&                                                                     *
5      *&---------------------------------------------------------------------*
6      *&                                                                     *
7      *&                                                                     *
8      *&---------------------------------------------------------------------*
9
10     *----------------------------------------------------------------*
11     * Author                : Alok kumar Singh
12     * Functional Consultant :
13     * Created on            :
14     * Title                 : Medical Expenditure System: Employee
15     * Description           : Payment of Medical bills to vendors -
16     *                         Medical assistant will fill up the details of
17     *                         Medical claims of vendors and it will
18     *                         initiate the flow for approvals. Records will
19     *                         be unlocked by Medical Officer and finally reach
20     *                         to Finance section for payment.
21     *                        CR 30003725
22     *----------------------------------------------------------------*
23     *Change History
24     ***********************************************************************
25     *Date        Transport    USERID   Description                  *
26     *14.06.2011  RD1K976756  CAB_ALOK  30003725: HR infotype update thro' RFC,
27     *                                  1. Code that is doing HR infotype operation
28     *                                  has to be converted to RFC.
29     *                                  2. Calling function then has to
30     *                                     use DESTINATION 'MMREQ_ASSETNO_CR_RFC'
31     *                                  This in turn will enable end-user to perform HR infotype
32     *                                  operation using BGJOB_ADM user's credentials,
33     *                                  (without actually giving him structure authorisation)
34     *19.08.2011 RD1K977570 CAB_ALOK  CR 30006026: Modification for enabling Core team IDs
35     *                                  to access the system without maintaining communication
36     *                                  data (IT0105)
37     *
38     *06.09.2011 RD1K977728 CAB_ALOK CR 30006277 - IUT case.
39     *14.09.2011 RD1K977852 CAB_ALOK CR 30006309:Changes in Field exit, ZHRHOSP Prg
40     *                         1. Validation at the time of data entry & mass upload that at least one
41     *                            Cost Object for the pernr is maintained in the claim period
42     *                         2. For adobe form printing, default print device programmatically set as 'HP01' .
43     *                         3. Program for maintenance of table ZHRCORETEAM_MED, Tcode: ZHRHOSPCORETEAM.
44     *                         4. For re-submitted records, MO Amount being updated with DO Amount.
45     *                         5. Zero balance problem: For each claim line, difference in Credit amount and
46     *                            Sum of amounts in  Debit lines to be adjusted in last debit line.
47     *20.10.2011 RD1K978193 CAB_ALOK  CR 30006378:
48     *                                 1. Recovery Amt field in MO screen.
49     *                                 2. Print order copy adobe form: MO Amount and MO remarks introduced into
50     *                                    the payment order, Vendor No. and Vendor name shifted to header area.
51     *                                 3. The consolidate amount of all the bills approved by Medical officer
52     *                                 4. Dependent data not appearing: issue appeared when Employee and his dependents were in different
53     *                                    cities, so condition on city has now been removed.
54     *                                 5. Validation of CARD NO: because of condition that bills are accepted upto 6 month after expiry of cards,
55     *                                    Two records qualify for selection in case employee had joined within 6 months, and
56     *                                    'SELECT SINGLE' selects wrong data giving wrong validation messages.
57     *                                    we need to consider record having latest begda:
58     *                                 6. Correct name of dependent not appearing in LOV:Issue was that in case of expired
59     *                                    dependent (in this case mother) following condition on PA0021
60     *                                    ( begda <=   sy-datum    AND endda >=  sy-datum ) doesn't give output.
61     *                                    Removed this date condition (for the purpose of extracting name only)
62     *                                 7. Introduction of search option in table controls
63     *18.11.2011 RD1K976266 CAB_ALOK  CR 30006546: Changes in ZHRHOSP-Duplicate document- Posting in Multiple sessions
64     *12.11.2011 RD1K978727 CAB_ALOK  CR 30006619: Lot No. Lock mechanism, to dis-allow Payment of same lot from simultaneously open sessions.
65     *05.01.2012 RD1K979096 CAB_ALOK  CR 30006712: ZHRHOSP - Modification in Tax code logic
66     *01.02.2012 RD1K979337 CAB_ALOK  CR 30006794: Lot status from unlock to Paid ZHRHOSP-
67     *                                Take lock on all the pernr of a lot when TEST/PAY is clicked.
68     *                                If any of the locks fail, unlock all, Come to payment screen and give Msg.
69     *                                if all the pernrs locked, perform BDC, depending on mode and BDC result update 9920.
70     *                                unlock all.
71     *                                3 separate RFCs for LOCK, UPDATE, UNLOCK operations for Payment screen.
72     *27.02.2012 RD1K979590 CAB_ALOK  CR 30006427:New features in ZHRHOSP
73     *                                1. Payment reversal - reversal of FI DOC, rev. of Corresponding claims in PA9920 and
74     *                                       reversal of employee recovery from ZHRMED_EMP_RECOV table
75     *                                2. Dual check before payments as per BDP
76     *                                3. Restriction on Max. number of Claims in a single LOT. (BDC of F-02 supports only a Max of
77     *                                   999 line items in a FI payment doc.)
78     *                                4. Status Report: a) Introduction of patient name
79     *                                                  b) Provision for report download in XLS
80     *11.09.2012  RD1K981858 CAB_ALOK CR 30007832: Modification in 2 Level CHK, LOT-MAX changed to 500
81     *10.09.2012  RD1K981765  CAB_ALOK CR: 30007609 Changes in ZHRHOSP - Vendor name etc
82     *21.03.2013  RD1K984276           CR: 30008902 Changes - Different GL account determination for contingent worker
83     *09.04.2013  RD1K984471  CAB_ALOK CR: 30008930 ZHRHOSP and ZHRNEHOSP sanction limits
84     *                       - CAB_PAREEK -
85     *24.03.2014 RD1K991981 CAB_ALOK CR: 30010772 Changes in ZHRHOSP Sanction Process-
86     *                                            new Commitment item for retd employee
87     *20.10.2014 RD1K994992 CAB_PAREEK CR - 30011878 changes in MZPZ9920_MED_INPATIENT_I01
88     *15.12.2014 RD1K996216 CAB_ALOK   CR30011991  New Sanction Process in ZHRHOSP
89     *09.01.2015 RD1K995325 CAB_ALOK   CR 30012355 BDP-2014 Implemention: FI Medical Paymnt
90     *06.01.2015 RD1K996913 CAB_ALOK   CR 30012633 Report and Logs for hospital Sanction Utilization,
91     *                                             Manual splitting of Section codes and balances for FY 2015
92     *10.06.2015 RD1K997486 CAB_ALOK   CR 30012858 Medical Vendor pymt for Contingent workers
93     *21.10.2015 RD1K998594 CAB_RAMA   CR 30013349 updation after posting of medical documents *
94     *                      (LIPSY)
95
96
97     *-----------------------------------------------------------------------------------------------------
98
99
100    PROGRAM SAPMZPZ9920_MED_INPATIENT NO STANDARD PAGE HEADING .
101    INCLUDE MZPZ9920_MED_INPATIENT_TOP.
102    INCLUDE MZPZ9920_MED_INPATIENT_O01.
103    INCLUDE MZPZ9920_MED_INPATIENT_I01.
104    INCLUDE MZPZ9920_MED_INPATIENT_F01.
*--- End of SAPMZPZ9920_MED_INPATIENT - 104 lines ---

----------------------------------------------------------------------------------------------------
Include          MZPZ9920_MED_INPATIENT_TOP                Level 1    Page 2
Object           SAPMZPZ9920_MED_INPATIENT                 Lines 429
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:24
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&  Include           MZPZ9920_MED_INPATIENT_TOP.
3      *&---------------------------------------------------------------------*
4
5      TYPE-POOLS: vrm, slis,
6                 ESP1       " for messages
7                 .
8
9      Tables: PA0105,
10             ZHR_MED_VENDORS,  "table of vendors for medical payment purpose.
11             V_SECCODE ,
12             ZHRHOSPSANCTION ,
13             BKPF,
14             SKB1,
15             ZHR_MED_USERS.
16     DATA : wa_zhrhospsanction TYPE zhrhospsanction ,
17            wa_zhrhospsanc_utl TYPE zhrhospsanc_utl ,
18     * Begin RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
19            ist_zhrhospsanc_utl TYPE TABLE OF zhrhospsanc_utl ,
20     * End RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
21            ist_zhrhospsanction type table of zhrhospsanction ,
22            t_amt like zhrhospsanction-amt,
23            t_amt1 like zhrhospsanction-amt.
24
25
26     DATA: g_greyoff(1).
27     DATA: g_user_pernr TYPE pernr_d.
28     DATA: g_user_name TYPE emnam.
29     DATA: g_user_orgeh TYPE orgeh.
30     DATA: g_user_plans TYPE plans.
31     DATA: g_user_persa TYPE persa.
32     DATA: g_user_bukrs TYPE bukrs.
33     DATA: g_user_werks TYPE pa0001-werks.
34     DATA: g_user_desig TYPE ZDESIGNATION_REV-DESIG_TEXT.
35
36     DATA: G_FACILITY TYPE ZFACILITY. " eg Hospital : Subty:03
37     "    Doctor   : Subty:04
38
39     DATA: ok_code_0101 TYPE sy-ucomm.
40     DATA: save_ok TYPE sy-ucomm.
41     DATA: G_BUKRS type PA0001-BUKRS,
42           G_WERKS type PA0001-WERKS.
43     DATA: WA_PA0105 TYPE PA0105.
44     DATA: WA_ZHR_MED_VENDORS type ZHR_MED_VENDORS.
45     DATA: IST_ZHR_MED_VENDORS type STANDARD TABLE OF ZHR_MED_VENDORS.
46
47     DATA : DYFIELDS_1   LIKE DYNPREAD OCCURS 1 WITH HEADER LINE.
48     DATA : IST_FIELD LIKE  DFIES OCCURS 1 WITH HEADER LINE.
49     DATA : IST_DYNPFLD_MAPPING LIKE STANDARD TABLE OF DSELC
50                                            WITH  HEADER LINE.
51     DATA : IST_RETURN_TAB LIKE STANDARD TABLE OF DDSHRETVAL
52                                            WITH  HEADER LINE.
53
54     data : ok_code_0050 type sy-ucomm.
55
56     data: ist_mass TYPE STANDARD TABLE OF p9920,
57           wa_mass TYPE p9920.
58     ** SUBMIT
59     DATA: ok_code_0401 TYPE sy-ucomm.
60     TABLES: ZPMED_SUBMIT.
61
62     types: begin of ty_submit.
63     types:   serial_no type i,
64              taxable type zhryes_no.
65             include STRUCTURE P9920.
66     types:   message TYPE ZCHAR_MAX,                            "255 char
67              error_flag(1),
68              sel(1),                  " Row selection indicator
69     *begin RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP-patient name
70              patient_name(80),
71     *end RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
72
73              line_color(4).
74     types:   end of ty_submit.
75
76     data: IST_9920_SUBMIT type table of ty_submit WITH HEADER LINE,
77            wa_9920_SUBMIT TYPE ty_submit.
78
79     DATA  OK_CODE_0301 type sy-ucomm..
80     data: IST_9920_EDIT type table of ty_submit WITH HEADER LINE,
81            wa_9920_EDIT TYPE ty_submit.
82     DATA  OK_CODE_0305 type sy-ucomm..
83     DATA OK_CODE_0051 type sy-ucomm...
84
85
86     SELECTION-SCREEN BEGIN OF SCREEN 402.
87     SELECT-OPTIONS: S_UNAME FOR  IST_9920_SUBMIT-UNAME no-extension .
88     SELECTION-SCREEN END OF SCREEN 402.
89
90     DATA: ok_code_0501 TYPE sy-ucomm.
91     data: IST_9920_UNLOCK type table of ty_submit WITH HEADER LINE,
92            wa_9920_UNLOCK TYPE ty_submit.
93     DATA: ok_code_0505 TYPE sy-ucomm.
94     DATA: save_ok_code_0505 TYPE sy-ucomm.
95
96     DATA  G_FLAG_SAVEMO(1).
97     DATA  G_FLAG_EDITMO(1).
98     DATA  G_FLAG_SAVEDO(1).
99     DATA  G_FLAG_EDITDO(1).
100    DATA  G_FLAG_SAVEFI(1).
101    DATA  G_FLAG_EDITFI(1).
102
103    DATA: ok_code_0601 TYPE sy-ucomm.
104    DATA: ok_code_0605 TYPE sy-ucomm.
105    types: begin of ty_pay.
106    types:   serial_no type i,
107             taxable type zhryes_no.
108            include STRUCTURE P9920.
109    types:   message TYPE ZCHAR_MAX,                            "255 char
110             error_flag(1),
111             sel(1),                  " Row selection indicator
112             line_color(4)
113    *         kidno type kidno,    " paymt ref
114    *         WT_WITHCD type WT_WITHCD, "Withholding tax code
115    *         WT_QSSHB type WT_BS1,      " Withholding tax base amount in
116    *         FIELD1(10),   " for future use
117    *         FIELD2(20),   " for future use
118    *         FIELD3(30)   " for future use
119             .
120    types:   end of ty_pay.
121
122    data: IST_9920_PAY type table of ty_pay WITH HEADER LINE,
123           wa_9920_PAY TYPE ty_pay.
124    DATA:  G_SECCO type BSEG-SECCO, "section code
125           G_BUDAT type BKPF-BUDAT,  " posting date
126           G_KIDNO  type kidno,    " paymt ref type
127           G_WITHT  type WITHT,                   " FS 1.2, Tax type
128           G_WT_WITHCD type WT_WITHCD, "Withholding tax code
129           G_WT_BASE type WT_BSAMNT.
130
131
132
133    types: begin of TY_F_02_HEADER,
134     	      BLDAT	type BLDAT,
135            BLART	type 	 BLART,
136            BUKRS	type 	 BUKRS,    " GRPVL: company code for credit.
137            BUDAT	type   BUDAT,
138            WAERS	type 	 WAERS,
139            XBLNR	type 	 XBLNR1,
140            BKTXT	type   BKTXT,
141           end of TY_F_02_HEADER    .
142
143    types: begin of TY_F_02_CREDIT,
144    *        PST_KEY type NEWBS      " posting key
145            VENDOR type NEWKO,       "NEWKO , ZHOSPID
146            WRBTR type WRBTR,    " amt.
147            SECCO type SECCO,   " section code
148            ZFBDT	type DZFBDT,    " base line date
149            KIDNO	type kidno,    " paymt ref
150            SGTXT  type SGTXT,
151            WT_WITHCD type WT_WITHCD, "Withholding tax code
152            WT_BASE type WT_BSAMNT,      " Withholding tax base amount
153           end of TY_F_02_CREDIT .
154
155    *types: begin of TY_F_02_DEBIT,
156    *include type ty_pay.
157    *types:  GLAC  type NEWKO,           " GL A/c , NEWKO
158    *        COMPNY_PERNR type NEWBK ,   " company code of pernr
159    *        SPLIT_AMT type WRBTR,
160    *        VALUT type VALUT,   " value date
161    *        SGTXT  type SGTXT,
162    *        WBS_ELE  type PS_POSID, " WBS element
163    *        COST_CTR type KOSTL,
164    *       end of TY_F_02_DEBIT .
165
166    types: begin of TY_F_02_DEBIT.
167    types:  serial_no type i.
168            include STRUCTURE P9920.
169    types:  message TYPE ZCHAR_MAX,                             " 255 char
170            error_flag(1),
171            sel(1),                  " Row selection indicator
172            line_color(4),
173
174            GLAC  type NEWKO,           " GL A/c , NEWKO
175            COMPNY_PERNR type NEWBK ,   " company code of pernr
176            SPLIT_AMT type WRBTR,
177            VALUT type VALUT,   " value date
178            SGTXT  type SGTXT,
179            WBS_ELE  type PS_POSID, " WBS element
180            COST_CTR type KOSTL,
181           end of TY_F_02_DEBIT
182             .
183
184
185    *data: WA_F_02_HEADER TYPE TY_F_02_HEADER. move to form PAY_0605
186    *data: WA_F_02_CREDIT TYPE TY_F_02_CREDIT.
187    *data: IST_F_02_DEBIT TYPE table of  TY_F_02_DEBIT,
188    *       WA_F_02_DEBIT TYPE  TY_F_02_DEBIT,
189    *       WA_F_02_DEBIT_NEXT TYPE  TY_F_02_DEBIT.
190
191    data:  STRU_F_02_HEADER TYPE TY_F_02_HEADER,
192           STRU_F_02_CREDIT TYPE TY_F_02_CREDIT,
193           STRU_F_02_DEBIT TYPE table of  TY_F_02_DEBIT.
194
195    data : bdcdata like bdcdata occurs 0 with header line,
196           messtab type table of bdcmsgcoll with header line,
197           wa_messtab type bdcmsgcoll .
198
199    * types for messages
200    TYPES: BEGIN OF TY_ESP1_MESSAGE,
201             MSGID  LIKE SY-MSGID,
202             MSGTY  LIKE SY-MSGTY,
203             MSGNO  LIKE SY-MSGNO,
204             MSGV1  LIKE SY-MSGV1,
205             MSGV2  LIKE SY-MSGV2,
206             MSGV3  LIKE SY-MSGV3,
207             MSGV4  LIKE SY-MSGV4,
208             LINENO LIKE MESG-ZEILE,
209           END OF TY_ESP1_MESSAGE.
210
211    types TY_FLAG(1).
212
213    types: begin of TY_LOT,
214     	      ZLOT_NO type PA9920-ZLOT_NO,
215            BEGDA TYPE PA9920-BEGDA,
216           end of TY_LOT    .
217
218    DATA: IST_LOT type STANDARD TABLE OF TY_LOT.
219
220    DATA: ok_code_0701 TYPE sy-ucomm.
221    DATA: ok_code_0705 TYPE sy-ucomm.
222    data: IST_9920_STATUS type table of ty_submit WITH HEADER LINE,
223           wa_9920_STATUS TYPE ty_submit.
224
225    types: begin of TY_SECCO,
226     	      SECCODE type SECCODE-SECCODE,
227     	"      NAME type V_SECCODE-NAME,
228           end of TY_SECCO       .
229
230    DATA: IST_SECCO type STANDARD TABLE OF TY_SECCO.
231
232    types: begin of TY_WITHT,
233     	      WITHT type WITHT,
234            TEXT40 type T059U-TEXT40,
235           end of TY_WITHT       .
236
237    DATA: IST_WITHT type STANDARD TABLE OF TY_WITHT.
238
239    types: begin of TY_WT_WITHCD,
240     	      WT_WITHCD type WT_WITHCD,
241            TEXT40 type t059zt-text40,
242           end of TY_WT_WITHCD       .
243
244    DATA: IST_WT_WITHCD type STANDARD TABLE OF TY_WT_WITHCD.
245
246    data: ist_9920_pay_tmp type STANDARD TABLE OF ty_pay.
247    data : WA_PAY type ty_pay.
248
249    data: IST_9920_DELETE type table of ty_submit WITH HEADER LINE,
250           wa_9920_DELETE TYPE ty_submit.
251    DATA: ok_code_0801 TYPE sy-ucomm.
252    DATA: ok_code_0805 TYPE sy-ucomm.
253
254    types: begin of TY_STATUS,
255     	      ZSTATUS type PA9920-ZSTATUS,
256           end of TY_STATUS.
257    DATA: IST_STATUS type STANDARD TABLE OF TY_STATUS.
258
259    DATA: ok_code_0901 TYPE sy-ucomm.
260
261    DATA: g_clearscreen(1).
262
263    data:  WA_AGR_USERS type AGR_USERS.
264
265    TABLES: p9920, pa9920, pa0001, pa0000, pa0008,pa9919.
266
267    TYPE-POOLS p99sg .
268
269    DATA: LOTKZ(10).
270    DATA: l_return TYPE bapireturn1.
271    DATA: bapipakey_tab LIKE bapipakey OCCURS 0 WITH HEADER LINE.
272
273    DATA : g_id TYPE vrm_id,
274           g_list TYPE vrm_values,
275           g_value  LIKE LINE OF g_list.
276    data: lv_endda_ch like pa9919 occurs 0 with header line.
277
278    DATA: g_persa TYPE persa.
279    Data:g_city like T500P-CITYC.
280
281    ***************************Container ******************************
282    TYPE-POOLS CNDP.
283    DATA  URL(132).
284    DATA : CONTAINER TYPE REF TO CL_GUI_CUSTOM_CONTAINER.
285    DATA : PICTURE TYPE REF TO CL_GUI_PICTURE.
286    CLASS CL_GUI_CFW DEFINITION LOAD.
287    DATA  INIT.
288    ********************************************************************
289
290    ***********************************************************************
291    * Table controls
292    ***********************************************************************
293
294    *&SPWIZARD: DECLARATION OF TABLECONTROL 'TC_SUBMIT' ITSELF
295    CONTROLS: TC_SUBMIT TYPE TABLEVIEW USING SCREEN 0405.
296
297    *&SPWIZARD: LINES OF TABLECONTROL 'TC_SUBMIT'
298    DATA:     G_TC_SUBMIT_LINES  LIKE SY-LOOPC.
299
300    DATA:     OK_CODE_0405 LIKE SY-UCOMM.
301
302    *&SPWIZARD: DECLARATION OF TABLECONTROL 'TC_UNLOCK' ITSELF
303    CONTROLS: TC_UNLOCK TYPE TABLEVIEW USING SCREEN 0505.
304
305    *&SPWIZARD: LINES OF TABLECONTROL 'TC_UNLOCK'
306    DATA:     G_TC_UNLOCK_LINES  LIKE SY-LOOPC.
307
308    *&SPWIZARD: DECLARATION OF TABLECONTROL 'TC_EDIT' ITSELF
309    CONTROLS: TC_EDIT TYPE TABLEVIEW USING SCREEN 0305.
310
311    *&SPWIZARD: LINES OF TABLECONTROL 'TC_EDIT'
312    DATA:     G_TC_EDIT_LINES  LIKE SY-LOOPC.
313
314    *&SPWIZARD: DECLARATION OF TABLECONTROL 'TC_PAY' ITSELF
315    CONTROLS: TC_PAY TYPE TABLEVIEW USING SCREEN 0605.
316
317    *&SPWIZARD: LINES OF TABLECONTROL 'TC_PAY'
318    DATA:     G_TC_PAY_LINES  LIKE SY-LOOPC.
319
320    *&SPWIZARD: DECLARATION OF TABLECONTROL 'TC_STATUS_REP' ITSELF
321    CONTROLS: TC_STATUS_REP TYPE TABLEVIEW USING SCREEN 0705.
322
323    *&SPWIZARD: LINES OF TABLECONTROL 'TC_STATUS_REP'
324    DATA:     G_TC_STATUS_REP_LINES  LIKE SY-LOOPC.
325
326    *&SPWIZARD: DECLARATION OF TABLECONTROL 'TC_DELETE' ITSELF
327    CONTROLS: TC_DELETE TYPE TABLEVIEW USING SCREEN 0805.
328
329    *&SPWIZARD: LINES OF TABLECONTROL 'TC_DELETE'
330    DATA:     G_TC_DELETE_LINES  LIKE SY-LOOPC.
331
332    * begin RD1K977570  CAB_ALOK  CR 30006026
333    DATA: G_CORE_TEAM_FLAG(1).
334    * end RD1K977570  CAB_ALOK  CR 30006026
335
336
337    * begin RD1K978193 CAB_ALOK CR 30006378
338    DATA  g_srch_flag(1).
339    DATA  OK_CODE_0510 type sy-ucomm..
340    * end RD1K978193 CAB_ALOK CR 30006378
341
342
343    * begin RD1K976266 CAB_ALOK  CR 30006546 Changes in ZHRHOSP-Duplicate documen
344    *DATA: ZSPA_LOT_NO TYPE tpara-paramid .
345    * end RD1K976266 CAB_ALOK  CR 30006546 Changes in ZHRHOSP-Duplicate documen
346
347    * begin RD1K979337 CAB_ALOK Lot status from unlock to Paid ZHRHOSP- CR 30006794
348    data: IST_9920_PAY_COPY type table of ty_pay WITH HEADER LINE. "copy of IST_PAY
349    * End RD1K979337 CAB_ALOK Lot status from unlock to Paid ZHRHOSP- CR 30006794
350
351    *begin RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
352    data: G_FLAG_RESTRICT.  "Flag: Restrict Max No. of rows that can be unlocked under single LOT
353    data: LOT_TOTAL_PCS_AMT type ZAMT15_2 ,
354          SELECT_TOTAL_PCS_AMT type ZAMT15_2 ,
355          PENDING_TOTAL_PCS_AMT type ZAMT15_2,
356          G_USER_PERSK type PERSK.
357
358    data: OK_CODE_1001 type sy-ucomm.
359
360    types: begin of TY_LOT_BELNR,
361     	      ZLOT_NO type PA9920-ZLOT_NO,
362     	      BELNR type PA9920-BELNR,
363     	      GJAHR type PA9920-GJAHR,
364     	      BUKRS type PA9920-BUKRS,
365           end of TY_LOT_BELNR.
366
367    DATA: IST_LOT_BELNR type STANDARD TABLE OF TY_LOT_BELNR.
368
369    data: IST_9920_REV type table of ty_pay WITH HEADER LINE,
370           wa_9920_REV TYPE ty_pay.
371    data: OK_CODE_1005 type sy-ucomm.
372
373
374
375    *&SPWIZARD: DECLARATION OF TABLECONTROL 'TC_REV' ITSELF
376    CONTROLS: TC_REV TYPE TABLEVIEW USING SCREEN 1005.
377
378    *&SPWIZARD: LINES OF TABLECONTROL 'TC_REV'
379    DATA:     G_TC_REV_LINES  LIKE SY-LOOPC.
380
381    DATA:  G_FLAG_REVERSED(1).
382    *end RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
383    *begin RD1K981765 CR: 30007609 CAB_ALOK FS for change in ZHRHOSP
384    DATA  G_VENDOR_NAME TYPE ZHR_MED_VENDORS-NAME1.
385    *end RD1K981765 CR: 30007609 CAB_ALOK FS for change in ZHRHOSP
386
387    data: l_persk TYPE persk. "Employee Group : active, retd etc
388    data: l_persg TYPE persg. " E1, E2, Etc
389
390
391    * Begin RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
392
393    Data: t_amt80 like zhrhospsanction-amt. "80% of sanctioned limit
394    data: WA_ZFIHOSPBUKRSEXEM type ZFIHOSPBUKRSEXEM.
395    * End RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
396
397    Data: TAX_ABLE type zhryes_no,
398          g_claim_not_save type c.
399    Types: Begin of tab_type,
400             fcode like RSMPE-FUNC,
401           end of tab_type.
402
403    Data: it_tab type standard table of tab_type with
404          non-unique default key initial size 10,
405          wa_tab type tab_type.
406
407    *Begin RD1K996216   CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
408    DATA: IST_SECCO1 type STANDARD TABLE OF TY_SECCO.
409    DATA: G_SECCO_REQD. " =X : Section code reqd
410    *End RD1K996216   CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
411
412    * Begin RD1K996913       CAB_AJIT     Report for hospital Sanction Utilization - CR 30012633
413      DATA: l_timestamp TYPE ZPS_GTO-timestamp.
414
415      DATA: WA_ZFIHOSPSANCLOG TYPE ZFIHOSPSANCLOG.
416
417
418    * End RD1K996913       CAB_AJIT     Report for hospital Sanction Utilization - CR 30012633
419
420
421    """""""""""""""""""""""""""""""""""""""""""
422    "added by lipsy on 22.09.2015 for simultaneous updation in ims RD1K998594
423    data:itab_bkpf_update TYPE TABLE OF bkpf,
424         wa_bkpf_update LIKE LINE OF itab_bkpf_update,
425         itab_bseg_update TYPE TABLE OF bseg,
426         wa_bseg_update LIKE LINE OF itab_bseg_update,
427         tmp_date_update type DATS.
428    "end of addition by lipsy on 22.09.2015 for simultaneous updation in ims RD1K998594
429    """"""""""""""""""""""""""""""""""""""""""
*--- End of MZPZ9920_MED_INPATIENT_TOP - 429 lines ---

----------------------------------------------------------------------------------------------------
Include          MZPZ9920_MED_INPATIENT_O01                Level 1    Page 3
Object           SAPMZPZ9920_MED_INPATIENT                 Lines 920
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:24
----------------------------------------------------------------------------------------------------
1      *----------------------------------------------------------------------*
2      ***INCLUDE MZPZ9920_MED_INPATIENT_O01 .
3      *----------------------------------------------------------------------*
4      *&---------------------------------------------------------------------*
5      *&      Module  TITLE_101  OUTPUT
6      *&---------------------------------------------------------------------*
7      *       text
8      *----------------------------------------------------------------------*
9      MODULE TITLE_101 OUTPUT.
10       SET TITLEBAR '101'.
11
12     ENDMODULE.                 " TITLE_101  OUTPUT
13
14     *&---------------------------------------------------------------------*
15     *&      Module  CLEAR_AFTER_SAVE  OUTPUT
16     *&---------------------------------------------------------------------*
17     *       text
18     *----------------------------------------------------------------------*
19     MODULE CLEAR_AFTER_SAVE OUTPUT.
20     ** clear when enter is pressed when screen is still showing claim no. &
21     * previous values in display mode after saving the claim .
22     ** Clear screen if  g_clearscreen = 'X'.
23       if g_clearscreen = 'X'.
24         g_clearscreen = ''.
25         clear P9920.
26         clear G_FACILITY.
27         PERFORM reset_list_box USING 'P9920-ZCRDNO'.
28       endif.
29     ENDMODULE.                 " CLEAR_AFTER_SAVE  OUTPUT
30     *&---------------------------------------------------------------------*
31     *&      Module  SCREEN_ATTRIB_101  OUTPUT
32     *&---------------------------------------------------------------------*
33     *       text
34     *----------------------------------------------------------------------*
35     MODULE SCREEN_ATTRIB_101 OUTPUT.
36
37       p9920-subty = G_FACILITY.
38       IF G_FACILITY = '04'
39           or G_FACILITY = '05'
40            or G_FACILITY = '06'
41            or G_FACILITY = '07'.
42     *    clear P9920-ZDATE_TO.
43         P9920-ZDATE_TO = P9920-ZDATE_FROM.
44         loop at screen.
45           if screen-name = 'P9920-ZDATE_TO'.
46             screen-invisible = 0.
47             screen-input = 0.
48             modify screen.
49           endif.
50         endloop.
51       ENDIF.
52
53
54     ** Grey-off all fields after saving data
55       IF g_greyoff = 'X'.
56         g_greyoff = ''.
57         g_clearscreen = 'X'.
58
59
60         LOOP AT SCREEN.
61           IF screen-group1 = 'OFF'.
62             screen-input = '0'.
63             MODIFY SCREEN.
64           ENDIF.
65         ENDLOOP.
66     *  ELSE.
67     *    LOOP AT SCREEN.
68     *      IF screen-group1 = 'OFF'.
69     *        screen-input = '1'.
70     *        MODIFY SCREEN.
71     *      ENDIF.
72     *    ENDLOOP.
73       ENDIF.
74
75       if G_FACILITY = '07'.
76         LOOP AT SCREEN.
77           IF screen-name = 'P9920-ZCRDNO'.
78             screen-input = '0'.
79             MODIFY SCREEN.
80           ENDIF.
81         ENDLOOP.
82       endif.
83
84
85     ENDMODULE.                 " SCREEN_ATTRIB_101  OUTPUT
86
87     *&---------------------------------------------------------------------*
88     *&      Module  DEFAULT_101  OUTPUT
89     *&---------------------------------------------------------------------*
90     *       text
91     *----------------------------------------------------------------------*
92     MODULE DEFAULT_101 OUTPUT.
93
94       p9920-begda    = sy-datum.
95       p9920-endda    = '99991231'.
96       p9920-zcurr  = 'INR'.
97       p9920-infty  = '9920'.
98       p9920-zindoor = 'X'.
99
100    ENDMODULE.                 " DEFAULT_101  OUTPUT
101    *&---------------------------------------------------------------------*
102    *&      Module  TEST_SCREEN  OUTPUT
103    *&---------------------------------------------------------------------*
104    *       text
105    *----------------------------------------------------------------------*
106    MODULE TEST_SCREEN OUTPUT.
107      loop at screen.
108        if screen-name = 'P9920-ZDATE_TO'.
109
110        endif.
111      endloop.
112    ENDMODULE.                 " TEST_SCREEN  OUTPUT
113    *&---------------------------------------------------------------------*
114    *&      Module  INIT_101  OUTPUT
115    *&---------------------------------------------------------------------*
116    *       text
117    *----------------------------------------------------------------------*
118    MODULE INIT_101 OUTPUT.
119
120    *clear P9920-ZCRDNO.
121    ENDMODULE.                 " INIT_101  OUTPUT
122    *&---------------------------------------------------------------------*
123    *&      Module  STATUS_0101  OUTPUT
124    *&---------------------------------------------------------------------*
125    *       text
126    *----------------------------------------------------------------------*
127    MODULE STATUS_0101 OUTPUT.
128
129      refresh it_tab.
130      clear wa_tab.
131      if g_claim_not_save = 'X'.
132        move 'SAVE' to wa_tab-fcode.
133        append wa_tab to it_tab.
134      endif.
135
136      SET PF-STATUS 'S101' excluding it_tab.
137
138
139
140      SET TITLEBAR '101'.
141
142    ENDMODULE.                 " STATUS_0101  OUTPUT
143    *&---------------------------------------------------------------------*
144    *&      Module  REMOVE_SPURIOUS  OUTPUT
145    *&---------------------------------------------------------------------*
146    *       text
147    *----------------------------------------------------------------------*
148    MODULE REMOVE_SPURIOUS OUTPUT.
149    *  a spurious row was coming in the drop down from the previous run
150      data: T_ZCRDNO type p9920-zcrdno,   " char 10 e.g., EM077783A
151            T_PERNR(8). "to receive p9920-pernr which is NUMC 8 e.g.,00091833
152
153      WRITE p9920-pernr to T_PERNR.
154
155      MOVE p9920-zcrdno+2(6) to T_ZCRDNO.
156      MOVE T_PERNR+2(6) to T_PERNR.
157
158      if T_ZCRDNO <> T_PERNR.
159        clear p9920-zcrdno.
160      endif.
161
162    ENDMODULE.                 " REMOVE_SPURIOUS  OUTPUT
163    *&---------------------------------------------------------------------*
164    *&      Module  STATUS_0050  OUTPUT
165    *&---------------------------------------------------------------------*
166    *       text
167    *----------------------------------------------------------------------*
168    MODULE STATUS_0050 OUTPUT.
169    *  SET PF-STATUS 'S0050'.
170      DATA fcode TYPE TABLE OF sy-ucomm.
171    * begin RD1K977570 CAB_ALOK - CR 30006026
172      if G_CORE_TEAM_FLAG = 'X'.
173        SET PF-STATUS 'S0050'.
174      else.
175    * end RD1K977570 CAB_ALOK - CR 30006026
176        IF WA_AGR_USERS-AGR_NAME = 'Z:HR_MED_VENDOR_HEAD'.
177          APPEND 'PAY'  TO fcode.
178          APPEND 'PAY_SANC'  TO fcode.
179    * Begin RD1K985179 CAB_ALOK Budget role for ZHRHOSP - CR 30009272
180          APPEND 'PYMT_REV'  TO fcode.
181    * End RD1K985179 CAB_ALOK Budget role for ZHRHOSP - CR 30009272
182        ELSEIF WA_AGR_USERS-AGR_NAME = 'Z:HR_MED_VENDOR_DO'.
183          APPEND 'UNLOCK'  TO fcode.
184          APPEND 'PAY'  TO fcode.
185          APPEND 'PAY_SANC'  TO fcode.
186    * Begin RD1K985179 CAB_ALOK Budget role for ZHRHOSP - CR 30009272
187          APPEND 'PYMT_REV'  TO fcode.
188    * End RD1K985179 CAB_ALOK Budget role for ZHRHOSP - CR 30009272
189        ELSEIF WA_AGR_USERS-AGR_NAME = 'Z:HR_MED_VENDOR_PCS'.
190          APPEND 'CREA'  TO fcode.
191          APPEND 'EDIT'  TO fcode.
192          APPEND 'MASSUPD'  TO fcode.
193          APPEND 'SUBMIT'  TO fcode.
194          APPEND 'UNLOCK'  TO fcode.
195          APPEND 'PRINT'  TO fcode.
196          APPEND 'DEL'  TO fcode.
197    * Begin RD1K985179 CAB_ALOK Budget role for ZHRHOSP - CR 30009272
198          APPEND 'PAY_SANC'  TO fcode.
199        ELSEIF WA_AGR_USERS-AGR_NAME = 'Z:HR_MED_VENDOR_FIN_BUDGET'.
200          APPEND 'CREA'  TO fcode.
201          APPEND 'EDIT'  TO fcode.
202          APPEND 'MASSUPD'  TO fcode.
203          APPEND 'SUBMIT'  TO fcode.
204          APPEND 'UNLOCK'  TO fcode.
205          APPEND 'PRINT'  TO fcode.
206          APPEND 'PAY'  TO fcode.
207          APPEND 'PYMT_REV'  TO fcode.
208          APPEND 'DEL'  TO fcode.
209    * End RD1K985179 CAB_ALOK Budget role for ZHRHOSP - CR 30009272
210        ENDIF.
211
212        SET PF-STATUS 'S0050' EXCLUDING fcode.
213    * begin RD1K977570 CAB_ALOK - CR 30006026
214      endif.
215    * end RD1K977570 CAB_ALOK - CR 30006026
216      SET TITLEBAR '0050'.
217
218      LOTKZ = 'abcdefghij'.
219
220      PERFORM LOAD_IMAGE . "CONAINER_INITIALIZATION.
221
222
223
224    ENDMODULE.                 " STATUS_0050  OUTPUT
225
226    *&---------------------------------------------------------------------*
227    *&      Module  GET_BUKRS_PA  OUTPUT
228    *&---------------------------------------------------------------------*
229    *       text
230    *----------------------------------------------------------------------*
231    MODULE GET_BUKRS_PA OUTPUT.
232    *get personnel area WERKS & Comp. code BUKRS of DO
233    *-------------------------------------------------
234    *Get PERNR of the user.
235    * begin RD1K977570 CAB_ALOK - CR 30006026
236
237    *  clear WA_PA0105.
238    *  select single * from PA0105 into WA_PA0105   " Get WA_PA0105-PERNR
239    *    where USRID = SY-UNAME
240    *       AND SUBTY = '0001'
241    *       AND begda <=   sy-datum
242    *       AND endda >=  sy-datum.
243    *  if sy-subrc <> 0.
244    *    MESSAGE ID 'ZMSG' TYPE 'E' NUMBER '000' WITH 'USER ID' text-012 .
245    *  endif.
246
247    * end  RD1K977570 CAB_ALOK - CR 30006026
248
249    *clear: G_BUKRS, G_WERKS.
250    * select single BUKRS WERKS from PA0001 into (G_BUKRS, G_WERKS) "Get
251    *           where pernr = WA_PA0105-PERNR
252    *              AND begda <=   sy-datum
253    *              AND endda >=  sy-datum.
254    *         if sy-subrc = 0.
255    *           if G_WERKS is not initial.
256    *             P9920-GRPVL = G_WERKS.
257    *           else. " WERKS not found
258    *             MESSAGE ID 'ZMSG' TYPE 'E' NUMBER '000' WITH 'Personnel Area' text-012  .
259    *           endif.
260    *
261    *           if G_BUKRS is initial.
262    *             MESSAGE ID 'ZMSG' TYPE 'E' NUMBER '000' WITH 'Company code' text-012  .
263    *           endif.
264    *         else. " WERKS & BUKRS not found
265    *             MESSAGE ID 'ZMSG' TYPE 'E' NUMBER '000' WITH 'Personnel Area & Company code' text-012  .
266    *         endif.
267    ** Above requirement changed from PA & BUKRS to BUKRS only.
268
269    * begin RD1K977570 CAB_ALOK - CR 30006026
270    *  select single BUKRS from PA0001 into P9920-GRPVL "Get company code
271    *            where pernr = WA_PA0105-PERNR
272    *               AND begda <=   sy-datum
273    *               AND endda >=  sy-datum.
274    *  if P9920-GRPVL is initial.
275    *    MESSAGE ID 'ZMSG' TYPE 'E' NUMBER '000' WITH 'Company code' text-012  .
276    *  endif.
277
278      P9920-GRPVL = G_USER_BUKRS.
279    * end RD1K977570 CAB_ALOK - CR 30006026
280    ENDMODULE.                 " GET_BUKRS_PA  OUTPUT
281    *&---------------------------------------------------------------------*
282    *&      Module  STATUS_0401  OUTPUT
283    *&---------------------------------------------------------------------*
284    *       text
285    *----------------------------------------------------------------------*
286    MODULE STATUS_0401 OUTPUT.
287      SET PF-STATUS 'S401'.
288      SET TITLEBAR '401'.
289    *  call screen '402'.
290    ENDMODULE.                 " STATUS_0401  OUTPUT
291    *&---------------------------------------------------------------------*
292    *&      Module  STATUS_0405  OUTPUT
293    *&---------------------------------------------------------------------*
294    *       text
295    *----------------------------------------------------------------------*
296    MODULE STATUS_0405 OUTPUT.
297      SET PF-STATUS 'S405'.
298      SET TITLEBAR '405'.
299    ENDMODULE.                 " STATUS_0405  OUTPUT
300
301
302    *&SPWIZARD: OUTPUT MODULE FOR TC 'TC_SUBMIT'. DO NOT CHANGE THIS LINE!
303    *&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
304    MODULE TC_SUBMIT_CHANGE_TC_ATTR OUTPUT.
305      DESCRIBE TABLE IST_9920_SUBMIT LINES TC_SUBMIT-lines.
306    ENDMODULE.                    "TC_SUBMIT_CHANGE_TC_ATTR OUTPUT
307
308    *&SPWIZARD: OUTPUT MODULE FOR TC 'TC_SUBMIT'. DO NOT CHANGE THIS LINE!
309    *&SPWIZARD: GET LINES OF TABLECONTROL
310    MODULE TC_SUBMIT_GET_LINES OUTPUT.
311      G_TC_SUBMIT_LINES = SY-LOOPC.
312    ENDMODULE.                    "TC_SUBMIT_GET_LINES OUTPUT
313
314    *----------------------------------------------------------------------*
315    *  MODULE STATUS_0501 OUTPUT
316    *----------------------------------------------------------------------*
317    *
318    *----------------------------------------------------------------------*
319    MODULE STATUS_0501 OUTPUT.
320      SET PF-STATUS 'S501'.
321      SET TITLEBAR '501'.
322    ENDMODULE.                    "STATUS_0501 OUTPUT
323    *&---------------------------------------------------------------------*
324    *&      Module  STATUS_0505  OUTPUT
325    *&---------------------------------------------------------------------*
326    *       text
327    *----------------------------------------------------------------------*
328    MODULE STATUS_0505 OUTPUT.
329      SET PF-STATUS 'S505'.
330      SET TITLEBAR '505'.
331    ENDMODULE.                 " STATUS_0505  OUTPUT
332
333    *&SPWIZARD: OUTPUT MODULE FOR TC 'TC_UNLOCK'. DO NOT CHANGE THIS LINE!
334    *&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
335    MODULE TC_UNLOCK_CHANGE_TC_ATTR OUTPUT.
336      DESCRIBE TABLE IST_9920_UNLOCK LINES TC_UNLOCK-lines.
337    ENDMODULE.                    "TC_UNLOCK_CHANGE_TC_ATTR OUTPUT
338
339    *&SPWIZARD: OUTPUT MODULE FOR TC 'TC_UNLOCK'. DO NOT CHANGE THIS LINE!
340    *&SPWIZARD: GET LINES OF TABLECONTROL
341    MODULE TC_UNLOCK_GET_LINES OUTPUT.
342      G_TC_UNLOCK_LINES = SY-LOOPC.
343    ENDMODULE.                    "TC_UNLOCK_GET_LINES OUTPUT
344
345    *&---------------------------------------------------------------------*
346    *&      Module  TC_UNLOCK_CHANGE_FIELD_ATTR  OUTPUT
347    *&---------------------------------------------------------------------*
348    *       text
349    *----------------------------------------------------------------------*
350    MODULE TC_UNLOCK_CHANGE_FIELD_ATTR OUTPUT.
351
352    * Enable edit mode for fields WA_9920_UNLOCK-ZAMTMOTOTAL and ZREMARKSMO .
353      if G_FLAG_EDITMO = 'X'.
354        if WA_9920_UNLOCK-SEL = 'X' and WA_9920_UNLOCK-ZSTATUS = 'SUBMITTED'.
355          LOOP AT SCREEN.
356    *      IF screen-group1 = 'MOE'.
357    *        screen-input = '1'.
358
359            IF   SCREEN-NAME = 'WA_9920_UNLOCK-ZAMTMOTOTAL'
360                or SCREEN-NAME = 'WA_9920_UNLOCK-ZREMARKSMO'
361    * begin RD1K978193 CAB_ALOK CR 30006378
362    * recovery amt to be editable in MO screen
363                or SCREEN-NAME = 'WA_9920_UNLOCK-ZADV_TKN'
364    * end RD1K978193 CAB_ALOK CR 30006378
365                or SCREEN-NAME = 'WA_9920_UNLOCK-TAXABLE'.
366              SCREEN-INPUT = '1'.
367              MODIFY SCREEN.
368            ENDIF.
369    *** Enable 'SAVE' button when SAVE_OK_CODE_0505 = 'EDITMO' and atleast one A_9920_UNLOCK-SEL = 'X'.
370    **        IF   SCREEN-NAME = 'TC_UNLOCK_SAVEMO'.
371    **          SCREEN-INPUT = '1'.
372    **          MODIFY SCREEN.
373    **        ENDIF.   NOT reaching to this point.
374
375
376          ENDLOOP.
377        endif.
378      endif.
379
380    ENDMODULE.                 " TC_UNLOCK_CHANGE_FIELD_ATTR  OUTPUT
381    *&---------------------------------------------------------------------*
382    *&      Module  TC_UNLOCK_ENABLE_SAVE  OUTPUT
383    *&---------------------------------------------------------------------*
384    *       text
385    *----------------------------------------------------------------------*
386    *&---------------------------------------------------------------------*
387    *&      Module  TC_UNLOCK_RESET_OKCODE  OUTPUT
388    *&---------------------------------------------------------------------*
389    *       text
390    *----------------------------------------------------------------------*
391    MODULE TC_UNLOCK_RESET_OKCODE OUTPUT.
392    *  CLEAR SAVE_OK_CODE_0505.
393    ENDMODULE.                 " TC_UNLOCK_RESET_OKCODE  OUTPUT
394    *&---------------------------------------------------------------------*
395    *&      Module  TC_UNLOCK_CHANGE_SCR_ATTR  OUTPUT
396    *&---------------------------------------------------------------------*
397    *       text
398    *----------------------------------------------------------------------*
399    MODULE TC_UNLOCK_CHANGE_SCR_ATTR OUTPUT.
400    * enable/disable 'SAVE'/'EDIT' buttons
401    *  if SAVE_OK_CODE_0505 = 'TC_UNLOCK_EDITMO'.
402      if G_FLAG_EDITMO = 'X'.  "'EDIT' pressed in previous loop
403        LOOP AT SCREEN.
404          IF   SCREEN-NAME = 'TC_UNLOCK_SAVEMO'.  "Enable 'SAVE' button
405            SCREEN-INPUT = '1'.
406            MODIFY SCREEN.
407          ENDIF.
408          IF   SCREEN-NAME = 'TC_UNLOCK_EDITMO' "Disable 'EDIT','UNLOCK' and 'REJMO'
409             or SCREEN-NAME = 'TC_UNLOCK_REJMO'
410             or SCREEN-NAME = 'TC_UNLOCK_UNLOCK'
411             or SCREEN-NAME = 'TC_UNLOCK_MARK'
412             or SCREEN-NAME = 'TC_UNLOCK_DEMARK'
413             or SCREEN-NAME = 'WA_9920_UNLOCK-SEL'. "Disable selection column
414            SCREEN-INPUT = '0'.
415            MODIFY SCREEN.
416          ENDIF.
417        ENDLOOP.
418
419      else.                               "Disable 'SAVE'
420
421        LOOP AT SCREEN.
422          IF   SCREEN-NAME = 'TC_UNLOCK_EDITMO'.
423            SCREEN-INPUT = '1'.
424            MODIFY SCREEN.
425          ENDIF.
426          IF   SCREEN-NAME = 'TC_UNLOCK_SAVEMO'. "Disable 'save'
427            SCREEN-INPUT = '0'.
428            MODIFY SCREEN.
429          ENDIF.
430        ENDLOOP.
431      endif.
432
433    ENDMODULE.                 " TC_UNLOCK_CHANGE_SCR_ATTR  OUTPUT
434    *&---------------------------------------------------------------------*
435    *&      Module  STATUS_0301  OUTPUT
436    *&---------------------------------------------------------------------*
437    *       text
438    *----------------------------------------------------------------------*
439    MODULE STATUS_0301 OUTPUT.
440      SET PF-STATUS 'S301'.
441      SET TITLEBAR '301'.
442
443    ENDMODULE.                 " STATUS_0301  OUTPUT
444
445    *&SPWIZARD: OUTPUT MODULE FOR TC 'TC_EDIT'. DO NOT CHANGE THIS LINE!
446    *&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
447    MODULE TC_EDIT_CHANGE_TC_ATTR OUTPUT.
448      DESCRIBE TABLE IST_9920_EDIT LINES TC_EDIT-lines.
449    ENDMODULE.                    "TC_EDIT_CHANGE_TC_ATTR OUTPUT
450
451    *&SPWIZARD: OUTPUT MODULE FOR TC 'TC_EDIT'. DO NOT CHANGE THIS LINE!
452    *&SPWIZARD: GET LINES OF TABLECONTROL
453    MODULE TC_EDIT_GET_LINES OUTPUT.
454      G_TC_EDIT_LINES = SY-LOOPC.
455    ENDMODULE.                    "TC_EDIT_GET_LINES OUTPUT
456    *&---------------------------------------------------------------------*
457    *&      Module  STATUS_0305  OUTPUT
458    *&---------------------------------------------------------------------*
459    *       text
460    *----------------------------------------------------------------------*
461    MODULE STATUS_0305 OUTPUT.
462      SET PF-STATUS 'S305'.
463      SET TITLEBAR '305'.
464
465    ENDMODULE.                 " STATUS_0305  OUTPUT
466    *&---------------------------------------------------------------------*
467    *&      Module  TC_EDIT_CHANGE_SCR_ATTR  OUTPUT
468    *&---------------------------------------------------------------------*
469    *       text
470    *----------------------------------------------------------------------*
471    MODULE TC_EDIT_CHANGE_SCR_ATTR OUTPUT.
472
473    * enable/disable 'SAVE'/'EDIT' buttons
474      if G_FLAG_EDITDO = 'X'.  "'EDIT' pressed in previous loop
475        LOOP AT SCREEN.
476          IF   SCREEN-NAME = 'TC_EDIT_SAVEDO'.  "Enable 'SAVE' button
477            SCREEN-INPUT = '1'.
478            MODIFY SCREEN.
479          ENDIF.
480          IF   SCREEN-NAME = 'TC_EDIT_EDITDO' "Disable 'EDIT','UNLOCK' and 'REJMO'
481             or SCREEN-NAME = 'TC_EDIT_MARK'
482             or SCREEN-NAME = 'TC_EDIT_DEMARK'
483             or SCREEN-NAME = 'WA_9920_EDIT-SEL'. "Disable selection column
484            SCREEN-INPUT = '0'.
485            MODIFY SCREEN.
486          ENDIF.
487        ENDLOOP.
488
489      else.                               "Disable 'SAVE'
490
491        LOOP AT SCREEN.
492          IF   SCREEN-NAME = 'TC_EDIT_EDITDO'.
493            SCREEN-INPUT = '1'.
494            MODIFY SCREEN.
495          ENDIF.
496          IF   SCREEN-NAME = 'TC_EDIT_SAVEDO'. "Disable 'save'
497            SCREEN-INPUT = '0'.
498            MODIFY SCREEN.
499          ENDIF.
500        ENDLOOP.
501      endif.
502
503    ENDMODULE.                 " TC_EDIT_CHANGE_SCR_ATTR  OUTPUT
504    *&---------------------------------------------------------------------*
505    *&      Module  TC_EDIT_CHANGE_FIELD_ATTR  OUTPUT
506    *&---------------------------------------------------------------------*
507    *       text
508    *----------------------------------------------------------------------*
509    MODULE TC_EDIT_CHANGE_FIELD_ATTR OUTPUT.
510    * Enable edit mode for fields of Screen grp 'DOE' .
511
512      if G_FLAG_EDITDO = 'X'.
513        if WA_9920_EDIT-SEL = 'X'
514           and ( WA_9920_EDIT-ZSTATUS = 'REJFI'
515                   or WA_9920_EDIT-ZSTATUS = 'REJMO' ).
516          LOOP AT SCREEN.
517            IF screen-group1 = 'DOE'.
518              screen-input = '1'.
519
520    *        IF   SCREEN-NAME = 'WA_9920_UNLOCK-'
521    *            or SCREEN-NAME = 'WA_9920_UNLOCK-' .
522    *          SCREEN-INPUT = '1'.
523
524              MODIFY SCREEN.
525            ENDIF.
526
527
528
529          ENDLOOP.
530        endif.
531      endif.
532
533    ENDMODULE.                 " TC_EDIT_CHANGE_FIELD_ATTR  OUTPUT
534    *&---------------------------------------------------------------------*
535    *&      Module  STATUS_0601  OUTPUT
536    *&---------------------------------------------------------------------*
537    *       text
538    *----------------------------------------------------------------------*
539    MODULE STATUS_0601 OUTPUT.
540      SET PF-STATUS 'S601'.
541      SET TITLEBAR '601'.
542
543    ENDMODULE.                 " STATUS_0601  OUTPUT
544    *&---------------------------------------------------------------------*
545    *&      Module  STATUS_0605  OUTPUT
546    *&---------------------------------------------------------------------*
547    *       text
548    *----------------------------------------------------------------------*
549    MODULE STATUS_0605 OUTPUT.
550      SET PF-STATUS 'S605'.
551      SET TITLEBAR '605'.
552
553    ENDMODULE.                 " STATUS_0605  OUTPUT
554
555    *&SPWIZARD: OUTPUT MODULE FOR TC 'TC_PAY'. DO NOT CHANGE THIS LINE!
556    *&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
557    MODULE TC_PAY_CHANGE_TC_ATTR OUTPUT.
558      DESCRIBE TABLE IST_9920_PAY LINES TC_PAY-lines.
559    ENDMODULE.                    "TC_PAY_CHANGE_TC_ATTR OUTPUT
560
561    *&SPWIZARD: OUTPUT MODULE FOR TC 'TC_PAY'. DO NOT CHANGE THIS LINE!
562    *&SPWIZARD: GET LINES OF TABLECONTROL
563    MODULE TC_PAY_GET_LINES OUTPUT.
564      G_TC_PAY_LINES = SY-LOOPC.
565    ENDMODULE.                    "TC_PAY_GET_LINES OUTPUT
566    *&---------------------------------------------------------------------*
567    *&      Module  TC_PAY_CHANGE_SCR_ATTR  OUTPUT
568    *&---------------------------------------------------------------------*
569    *       text
570    *----------------------------------------------------------------------*
571    MODULE TC_PAY_CHANGE_SCR_ATTR OUTPUT.
572    * enable/disable 'SAVE'/'EDIT' buttons
573    *  if SAVE_OK_CODE_0505 = 'TC_UNLOCK_EDITMO'.
574      if G_FLAG_EDITFI = 'X'.  "'EDIT' pressed in previous loop
575        LOOP AT SCREEN.
576          IF   SCREEN-NAME = 'TC_PAY_SAVEFI'.  "Enable 'SAVE' button
577            SCREEN-INPUT = '1'.
578            MODIFY SCREEN.
579          ENDIF.
580          IF   SCREEN-NAME = 'TC_PAY_EDITFI' "Disable 'EDIT','UNLOCK' and 'REJMO'
581             or SCREEN-NAME = 'TC_PAY_REJFI'
582             or SCREEN-NAME = 'TC_PAY_TEST'
583             or SCREEN-NAME = 'TC_PAY_PAY'
584             or SCREEN-NAME = 'TC_PAY_MARK'
585             or SCREEN-NAME = 'TC_PAY_DEMARK'
586             or SCREEN-NAME = 'WA_9920_PAY-SEL'. "Disable selection column
587            SCREEN-INPUT = '0'.
588            MODIFY SCREEN.
589          ENDIF.
590        ENDLOOP.
591
592      else.                               "Disable 'SAVE'
593
594        LOOP AT SCREEN.
595          IF   SCREEN-NAME = 'TC_PAY_EDITFI'. "Enable 'EDIT' button
596            SCREEN-INPUT = '1'.
597            MODIFY SCREEN.
598          ENDIF.
599          IF   SCREEN-NAME = 'TC_PAY_SAVEFI'. "Disable 'save'
600            SCREEN-INPUT = '0'.
601            MODIFY SCREEN.
602          ENDIF.
603        ENDLOOP.
604      endif.
605
606    *begin RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
607    ** Enable the 'CHECK1' button only if following condition is met.
608      data: L_MAX_AMT type ZAMT15_2.
609      L_MAX_AMT = 9999999999999 / 100 .  " = 99999999999.99
610      if LOT_TOTAL_PCS_AMT => 1500001 and LOT_TOTAL_PCS_AMT =< L_MAX_AMT .
611        If G_USER_PERSK between 'E1' and 'E3'.
612          LOOP AT SCREEN.
613            IF   SCREEN-NAME = 'TC_PAY_CHECK'.  "Enable 'CHECK' button
614              SCREEN-INPUT = '1'.
615              MODIFY SCREEN.
616            ENDIF.
617          ENDLOOP.
618        endif.
619      endif.
620    *end RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
621
622
623    ENDMODULE.                 " TC_PAY_CHANGE_SCR_ATTR  OUTPUT
624    *&---------------------------------------------------------------------*
625    *&      Module  TC_PAY_CHANGE_FIELD_ATTR  OUTPUT
626    *&---------------------------------------------------------------------*
627    *       text
628    *----------------------------------------------------------------------*
629    MODULE TC_PAY_CHANGE_FIELD_ATTR OUTPUT.
630    * Enable edit mode for following fields
631    * WA_9920_PAY-ZREMARKSPCS, WA_9920_PAY-KIDNO, WA_9920_PAY-WT_WITHCD, WA_9920_PAY-WT_QSSHB.
632
633    ****** ### make the rows un-selectable.
634    ***** disable selection feature for first row
635    ****  if WA_9920_PAY-serial_no = 1 .
636    ****    LOOP AT SCREEN.
637    ****      IF   SCREEN-NAME = 'WA_9920_PAY-SEL'.
638    ****        SCREEN-INPUT = '0'.
639    ****        MODIFY SCREEN.
640    ****      ENDIF.
641    ****
642    ****    ENDLOOP.
643    ***** if the row has still been selected by select all option, clear SEL variable for locked row
644    ****   clear WA_9920_PAY-SEL.
645    ****  endif.
646
647
648      if G_FLAG_EDITFI = 'X'.
649        if WA_9920_PAY-SEL = 'X' and WA_9920_PAY-ZSTATUS = 'UNLOCKED'.
650          LOOP AT SCREEN.
651    *      IF screen-group1 = 'FIE'.
652    *        screen-input = '1'.
653
654            IF   SCREEN-NAME = 'WA_9920_PAY-ZREMARKSPCS'
655                  or SCREEN-NAME = 'WA_9920_PAY-KIDNO'
656                  or SCREEN-NAME = 'WA_9920_PAY-WT_WITHCD'
657                  or SCREEN-NAME = 'WA_9920_PAY-WT_QSSHB'
658                  or SCREEN-NAME = 'WA_9920_PAY-TAXABLE'.
659              SCREEN-INPUT = '1'.
660              MODIFY SCREEN.
661            ENDIF.
662
663          ENDLOOP.
664        endif.
665      endif.
666
667    *Begin RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
668    ** if the claim line has been checked (i.e. CHECKED_BY_PERNR & CHECKED_BY_LEVEL
669    * are not initial), then highlight it..
670      LOOP AT SCREEN.
671        if  WA_9920_PAY-CHECKED_BY_PERNR is not INITIAL
672                and WA_9920_PAY-CHECKED_BY_LEVEL is not INITIAL .
673          SCREEN-INTENSIFIED = '1'.
674          MODIFY SCREEN.
675    *        ENDIF.
676        endif.
677
678      ENDLOOP.
679
680    *end RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
681
682    ENDMODULE.                 " TC_PAY_CHANGE_FIELD_ATTR  OUTPUT
683
684    *&---------------------------------------------------------------------*
685    *&      Module  STATUS_0701  OUTPUT
686    *&---------------------------------------------------------------------*
687    *       text
688    *----------------------------------------------------------------------*
689    MODULE STATUS_0701 OUTPUT.
690      SET PF-STATUS 'S701'.
691      SET TITLEBAR '701'.
692    ENDMODULE.                 " STATUS_0701  OUTPUT
693
694    *&SPWIZARD: OUTPUT MODULE FOR TC 'TC_STATUS_REP'. DO NOT CHANGE THIS LIN
695    *&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
696    MODULE TC_STATUS_REP_CHANGE_TC_ATTR OUTPUT.
697      DESCRIBE TABLE IST_9920_STATUS LINES TC_STATUS_REP-lines.
698    ENDMODULE.                    "TC_STATUS_REP_CHANGE_TC_ATTR OUTPUT
699
700    *&SPWIZARD: OUTPUT MODULE FOR TC 'TC_STATUS_REP'. DO NOT CHANGE THIS LIN
701    *&SPWIZARD: GET LINES OF TABLECONTROL
702    MODULE TC_STATUS_REP_GET_LINES OUTPUT.
703      G_TC_STATUS_REP_LINES = SY-LOOPC.
704    ENDMODULE.                    "TC_STATUS_REP_GET_LINES OUTPUT
705    *&---------------------------------------------------------------------*
706    *&      Module  STATUS_0705  OUTPUT
707    *&---------------------------------------------------------------------*
708    *       text
709    *----------------------------------------------------------------------*
710    MODULE STATUS_0705 OUTPUT.
711      SET PF-STATUS 'S705'.
712      SET TITLEBAR '705'.
713    ENDMODULE.                 " STATUS_0705  OUTPUT
714    *&---------------------------------------------------------------------*
715    *&      Module  GET_USER_DATA  OUTPUT
716    *&---------------------------------------------------------------------*
717    *       text
718    *----------------------------------------------------------------------*
719    MODULE GET_USER_DATA OUTPUT.
720
721      PERFORM GET_USER_DATA.
722
723    ENDMODULE.                 " GET_USER_DATA  OUTPUT
724    *&---------------------------------------------------------------------*
725    *&      Module  STATUS_0801  OUTPUT
726    *&---------------------------------------------------------------------*
727    *       text
728    *----------------------------------------------------------------------*
729    MODULE STATUS_0801 OUTPUT.
730      SET PF-STATUS 'S801'.
731      SET TITLEBAR '801'.
732
733    ENDMODULE.                 " STATUS_0801  OUTPUT
734
735    *&SPWIZARD: OUTPUT MODULE FOR TC 'TC_DELETE'. DO NOT CHANGE THIS LINE!
736    *&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
737    MODULE TC_DELETE_CHANGE_TC_ATTR OUTPUT.
738      DESCRIBE TABLE IST_9920_DELETE LINES TC_DELETE-lines.
739    ENDMODULE.                    "TC_DELETE_CHANGE_TC_ATTR OUTPUT
740
741    *&SPWIZARD: OUTPUT MODULE FOR TC 'TC_DELETE'. DO NOT CHANGE THIS LINE!
742    *&SPWIZARD: GET LINES OF TABLECONTROL
743    MODULE TC_DELETE_GET_LINES OUTPUT.
744      G_TC_DELETE_LINES = SY-LOOPC.
745    ENDMODULE.                    "TC_DELETE_GET_LINES OUTPUT
746    *&---------------------------------------------------------------------*
747    *&      Module  STATUS_0805  OUTPUT
748    *&---------------------------------------------------------------------*
749    *       text
750    *----------------------------------------------------------------------*
751    MODULE STATUS_0805 OUTPUT.
752      SET PF-STATUS 'S805'.
753      SET TITLEBAR '805'.
754
755    ENDMODULE.                 " STATUS_0805  OUTPUT
756    *&---------------------------------------------------------------------*
757    *&      Module  STATUS_0901  OUTPUT
758    *&---------------------------------------------------------------------*
759    *       text
760    *----------------------------------------------------------------------*
761    MODULE STATUS_0901 OUTPUT.
762      SET PF-STATUS 'S901'.
763      SET TITLEBAR '901'.
764
765    ENDMODULE.                 " STATUS_0901  OUTPUT
766    *&---------------------------------------------------------------------*
767    *&      Module  GET_USER_ROLE_AUTH  OUTPUT
768    *&---------------------------------------------------------------------*
769    *       text
770    *----------------------------------------------------------------------*
771    MODULE  GET_USER_ROLE_AUTH OUTPUT.
772    *Z:HR_MED_VENDOR_DO
773    *Z:HR_MED_VENDOR_HEAD
774    *Z:HR_MED_VENDOR_PCS
775      SELECT * FROM AGR_USERS
776     INTO WA_AGR_USERS UP TO 1 ROWS WHERE UNAME = SY-UNAME AND ( AGR_NAME = 'Z:HR_MED_VENDOR_DO' OR AGR_NAME = 'Z:HR_MED_VENDOR_HEAD' OR AGR_NAME = 'Z:HR_MED_VENDOR_PCS' OR AGR_NAME = 'Z:HR_MED_VENDOR_FIN_BUDGET' ) AND FROM_DAT <= SY-DATUM AND TO_DAT >=
777     SY-DATUM
778     ORDER BY PRIMARY KEY .
779     ENDSELECT.
780
781      if  WA_AGR_USERS-AGR_NAME is initial.
782        MESSAGE ID 'ZMSG' TYPE 'E' NUMBER '000' WITH 'No authorization to run the application' .
783      endif.
784
785
786    ENDMODULE.                 " GET_USER_ROLE_AUTH  OUTPUT
787    *&---------------------------------------------------------------------*
788    *&      Module  STATUS_0510  OUTPUT
789    *&---------------------------------------------------------------------*
790    *       text
791    *----------------------------------------------------------------------*
792    * begin RD1K978193 CAB_ALOK CR 30006378
793    MODULE STATUS_0510 OUTPUT.
794      SET PF-STATUS 'S510'.
795      SET TITLEBAR '510'.
796
797    ENDMODULE.                 " STATUS_0510  OUTPUT
798
799    *&---------------------------------------------------------------------*
800    *&      Module  TC_UNLOCK_SEARCH  OUTPUT
801    *&---------------------------------------------------------------------*
802    *       text
803    *----------------------------------------------------------------------*
804    MODULE TC_UNLOCK_SEARCH OUTPUT.
805
806      perform TC_UNLOCK_SEARCH.
807
808    ENDMODULE.                 " TC_UNLOCK_SEARCH  OUTPUT
809    * end RD1K978193 CAB_ALOK CR 30006378
810    *&---------------------------------------------------------------------*
811    *&      Module  TC_EDIT_SEARCH  OUTPUT
812    *&---------------------------------------------------------------------*
813    *       text
814    *----------------------------------------------------------------------*
815    MODULE TC_EDIT_SEARCH OUTPUT.
816      perform TC_EDIT_SEARCH.
817    ENDMODULE.                 " TC_EDIT_SEARCH  OUTPUT
818    *&---------------------------------------------------------------------*
819    *&      Module  CALCULATE_TOTALS  OUTPUT
820    *&---------------------------------------------------------------------*
821    *       text
822    *----------------------------------------------------------------------*
823    *Begin RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
824    MODULE CALCULATE_TOTALS OUTPUT.
825
826      PERFORM CALCULATE_TOTALS.
827
828    ENDMODULE.                 " CALCULATE_TOTALS  OUTPUT
829    *end RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
830    *&---------------------------------------------------------------------*
831    *&      Module  STATUS_1001  OUTPUT
832    *&---------------------------------------------------------------------*
833    *       text
834    *----------------------------------------------------------------------*
835    *Begin RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
836    MODULE STATUS_1001 OUTPUT.
837      SET PF-STATUS 'S1001'.
838      SET TITLEBAR '1001'.
839
840    ENDMODULE.                 " STATUS_1001  OUTPUT
841
842    *&---------------------------------------------------------------------*
843    *&      Module  STATUS_1005  OUTPUT
844    *&---------------------------------------------------------------------*
845    *       text
846    *----------------------------------------------------------------------*
847    MODULE STATUS_1005 OUTPUT.
848      DATA fcode1 TYPE TABLE OF sy-ucomm.
849      refresh fcode1.
850    * disable 'REVERSE' buton
851      if G_FLAG_REVERSED = 'X'.
852        APPEND 'TC_REV_REV'  TO fcode1.
853      ENDIF.
854      SET PF-STATUS 'S1005' EXCLUDING fcode1.
855      SET TITLEBAR '1005'.
856
857    ENDMODULE.                 " STATUS_1005  OUTPUT
858
859    *&SPWIZARD: OUTPUT MODULE FOR TC 'TC_REV'. DO NOT CHANGE THIS LINE!
860    *&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
861    MODULE TC_REV_CHANGE_TC_ATTR OUTPUT.
862      DESCRIBE TABLE IST_9920_REV LINES TC_REV-lines.
863    ENDMODULE.                    "TC_REV_CHANGE_TC_ATTR OUTPUT
864
865    *&SPWIZARD: OUTPUT MODULE FOR TC 'TC_REV'. DO NOT CHANGE THIS LINE!
866    *&SPWIZARD: GET LINES OF TABLECONTROL
867    MODULE TC_REV_GET_LINES OUTPUT.
868      G_TC_REV_LINES = SY-LOOPC.
869    ENDMODULE.                    "TC_REV_GET_LINES OUTPUT
870
871    *end RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
872    *&---------------------------------------------------------------------*
873    *&      Module  STATUS_0051  OUTPUT
874    *&---------------------------------------------------------------------*
875    *       text
876    *----------------------------------------------------------------------*
877    module STATUS_0051 output.
878
879        SET PF-STATUS 'S0051'.
880
881      SET TITLEBAR '0051'.
882
883    *begin RD1K984471  CAB_ALOK CR: 30008930 ZHRHOSP and ZHRNEHOSP sanction limits
884    *
885    *  SELECT SINGLE BUKRS FROM PA0001 INTO ZHRHOSPSANCTION-BUKRS WHERE pernr = sy-uname
886    *        and begda <= sy-datum and endda >= sy-datum .
887
888      ZHRHOSPSANCTION-BUKRS = G_USER_BUKRS.
889    *end RD1K984471  CAB_ALOK CR: 30008930 ZHRHOSP and ZHRNEHOSP sanction limits
890
891    endmodule.                 " STATUS_0051  OUTPUT
892
893    *
894    *&---------------------------------------------------------------------*
895    *&      Module  STATUS_0052  OUTPUT
896    *&---------------------------------------------------------------------*
897    *       text
898    *----------------------------------------------------------------------*
899    MODULE STATUS_0052 OUTPUT.
900      SET PF-STATUS 'S0052'.
901      SET TITLEBAR '0052'.
902
903    ENDMODULE.                 " STATUS_0052  OUTPUT
904    *&---------------------------------------------------------------------*
905    *&      Module  SECCO_REQD  OUTPUT
906    *&---------------------------------------------------------------------*
907    *       text
908    *----------------------------------------------------------------------*
909    **Begin RD1K996216   CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
910    *
911    *MODULE SECCO_REQD OUTPUT.
912    *
913    *if sy-datum >= '20150401'.
914    *
915    *  G_SECCO_REQD = 'X'.
916    *
917    *endif.
918    *
919    *ENDMODULE.                 " SECCO_REQD  OUTPUT
920    **End RD1K996216   CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
*--- End of MZPZ9920_MED_INPATIENT_O01 - 920 lines ---

----------------------------------------------------------------------------------------------------
Include          MZPZ9920_MED_INPATIENT_I01                Level 1    Page 4
Object           SAPMZPZ9920_MED_INPATIENT                 Lines 2633
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:24
----------------------------------------------------------------------------------------------------
1      *----------------------------------------------------------------------*
2      ***INCLUDE MZPZ9920_MED_INPATIENT_I01 .
3      *----------------------------------------------------------------------*
4
5
6      *****&---------------------------------------------------------------------*
7      *****&      Module  SCREEN_ATTRIB_101_I  INPUT
8      *****&---------------------------------------------------------------------*
9      *****       text
10     *****----------------------------------------------------------------------*
11     ****MODULE SCREEN_ATTRIB_101_I INPUT.
12     ****
13     ****
14     ****  IF G_FACILITY = '0004'
15     ****      or G_FACILITY = '0005'
16     ****       or G_FACILITY = '0006'.
17     ****    loop at screen.
18     ****      if screen-name = 'P9920-ZDATE_TO'.
19     *****        screen-invisible = 0.
20     ****        screen-input = 0.
21     ****        modify screen.
22     ****      endif.
23     ****     endloop.
24     ****  ENDIF.
25     ****
26     ****
27     ****ENDMODULE.                 " SCREEN_ATTRIB_101_I  INPUT
28     *&---------------------------------------------------------------------*
29     *&      Module  GET_101  INPUT
30     *&---------------------------------------------------------------------*
31     *       text
32     *----------------------------------------------------------------------*
33     MODULE GET_CARD_LOV INPUT.
34
35       if P9920-pernr is not INITIAL.
36         PERFORM get_list_box USING 'P9920-ZCRDNO'.
37       endif.
38
39     ENDMODULE.                 " GET_LOV_CARD   INPUT
40     *&---------------------------------------------------------------------*
41     *&      Module  USER_COMMAND_0101  INPUT
42     *&---------------------------------------------------------------------*
43     *       text
44     *----------------------------------------------------------------------*
45     MODULE EXIT_0101 INPUT.
46       if ok_code_0101 = 'XYZ'.
47     * PERFORM get_list_box USING 'P9920-ZCRDNO'.
48     *call screen '0101'.
49       else . " normal exit
50         CASE ok_code_0101.
51
52           WHEN 'BACK' OR 'CANC'.
53             clear : P9920.
54             clear: ok_code_0101, SAVE_OK.
55             clear G_FACILITY.
56             PERFORM reset_list_box USING 'P9920-ZCRDNO'.
57             LEAVE TO SCREEN 0.
58
59           when 'EXIT' .
60             clear : P9920.
61             clear: ok_code_0101, SAVE_OK.
62             clear G_FACILITY.
63             PERFORM reset_list_box USING 'P9920-ZCRDNO'.
64             LEAVE program.
65
66         ENDCASE.
67
68       endif.
69
70     ENDMODULE.                 " USER_COMMAND_0101  INPUT
71     *&---------------------------------------------------------------------*
72     *&      Module  GET_MODIFIED_PERNR  INPUT
73     *&---------------------------------------------------------------------*
74     *       text
75     *----------------------------------------------------------------------*
76     MODULE GET_MODIFIED_PERNR INPUT.
77       Data : ist_dynpflds like dynpread occurs 1 with header line.
78
79       ist_dynpflds-fieldname = 'P9920-PERNR'.
80
81       append ist_dynpflds.
82
83     *  if P9920-ZCRDNO is initial.
84
85       CALL FUNCTION 'DYNP_VALUES_READ'
86         EXPORTING
87           DYNAME               = sy-cprog
88           DYNUMB               = sy-dynnr
89         TABLES
90           DYNPFIELDS           = ist_dynpflds
91         EXCEPTIONS
92           INVALID_ABAPWORKAREA = 1
93           INVALID_DYNPROFIELD  = 2
94           INVALID_DYNPRONAME   = 3
95           INVALID_DYNPRONUMMER = 4
96           INVALID_REQUEST      = 5
97           NO_FIELDDESCRIPTION  = 6
98           INVALID_PARAMETER    = 7
99           UNDEFIND_ERROR       = 8
100          DOUBLE_CONVERSION    = 9
101          STEPL_NOT_FOUND      = 10
102          OTHERS               = 11.
103      IF SY-SUBRC <> 0.
104    * MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
105    *         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
106      ENDIF.
107
108    *  endif.
109
110      CALL FUNCTION 'DYNP_VALUES_UPDATE'
111        EXPORTING
112          DYNAME               = sy-cprog
113          DYNUMB               = sy-dynnr
114        TABLES
115          DYNPFIELDS           = ist_dynpflds
116        EXCEPTIONS
117          INVALID_ABAPWORKAREA = 1
118          INVALID_DYNPROFIELD  = 2
119          INVALID_DYNPRONAME   = 3
120          INVALID_DYNPRONUMMER = 4
121          INVALID_REQUEST      = 5
122          NO_FIELDDESCRIPTION  = 6
123          UNDEFIND_ERROR       = 7
124          OTHERS               = 8.
125      IF SY-SUBRC <> 0.
126    * MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
127    *         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
128      ENDIF.
129
130
131    ENDMODULE.                 " GET_MODIFIED_PERNR  INPUT
132    *&---------------------------------------------------------------------*
133    *&      Module  RESET_DATA  INPUT
134    *&---------------------------------------------------------------------*
135    *       text
136    *----------------------------------------------------------------------*
137    MODULE RESET_DATA INPUT.
138      clear p9920-zcrdno.
139    ENDMODULE.                 " RESET_DATA  INPUT
140    *&---------------------------------------------------------------------*
141    *&      Module  USER_COMMAND_0101  INPUT
142    *&---------------------------------------------------------------------*
143    *       text
144    *----------------------------------------------------------------------*
145    MODULE USER_COMMAND_0101 INPUT.
146
147      save_ok = ok_code_0101.
148      CLEAR ok_code_0101.
149      CASE save_ok.
150        WHEN 'BACK' or 'EXIT' or 'CANC'.
151          clear p9920.
152    *      g_greyoff = space.
153          LEAVE TO SCREEN 0.
154        WHEN 'SAVE'.
155    *      P9920-ZAMTCLTOTAL = P9920-ZAMOUNT.
156          perform calculate_values.
157          perform validate_0101.
158
159    *Begin RD1K976756  CAB_ALOK  HR infotype update thro' RFC
160    **      PERFORM confirm_save.
161    **      IF g_answer = 'J'.
162    *      PERFORM lock_and_update_user_0101.
163    ** Unnlocking the employee number after updatation
164    *      PERFORM unlock_user_0101.
165    **      ELSEIF g_answer <> 'J'.
166    **        g_disp = space.
167    **        MESSAGE ID 'ZMSG' TYPE 'S' NUMBER '000'
168    **          WITH 'Process Cancelled'.
169    **      ENDIF.
170
171          PERFORM lock_update_unlock_user_0101.
172
173    *End RD1K976756  CAB_ALOK  HR infotype update thro' RFC
174        WHEN 'SHVEND'.
175          clear g_claim_not_save.
176          SELECT * FROM ZHR_MED_VENDORS UP TO 1 ROWS
177     WHERE LIFNR = P9920-ZHOSPID
178     AND BUKRS = P9920-GRPVL
179     ORDER BY PRIMARY KEY .
180     ENDSELECT.
181
182          if zhr_med_vendors-taxable is INITIAL.
183            g_claim_not_save = 'X'.
184            message s000(zmsg)
185            with 'Claim can not be saved - Hospital category for taxation '
186                 'not maintained'.
187          endif.
188      ENDCASE.
189
190    ENDMODULE.                 " USER_COMMAND_0101  INPUT
191    *&---------------------------------------------------------------------*
192    *&      Module  GET_VENDOR  INPUT
193    *&---------------------------------------------------------------------*
194    *       text
195    *----------------------------------------------------------------------*
196    MODULE LOV_VENDOR INPUT.
197      data: tmp_lifnr type lfa1-lifnr.
198      REFRESH : DYFIELDS_1.
199      refresh: IST_ZHR_MED_VENDORS, IST_DYNPFLD_MAPPING, IST_FIELD, IST_RETURN_TAB .
200      clear: IST_DYNPFLD_MAPPING, IST_FIELD, IST_RETURN_TAB .
201      select BUKRS LIFNR NAME1 from ZHR_MED_VENDORS   " BUKRS, LIFNR
202        into CORRESPONDING FIELDS OF TABLE IST_ZHR_MED_VENDORS
203    *  where BUKRS = G_BUKRS.  " Now P9920-GRPVL
204          where BUKRS = P9920-GRPVL.
205
206    ***
207    ***   IST_DYNPFLD_MAPPING-FLDNAME   = 'F0001'.
208    ***   IST_DYNPFLD_MAPPING-DYFLDNAME = 'P9920-ZHOSPID'.
209    ***
210    ***   APPEND IST_DYNPFLD_MAPPING.
211    ***   CLEAR : IST_DYNPFLD_MAPPING.
212
213      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
214        EXPORTING
215          RETFIELD        = 'LIFNR'
216          DYNPPROG        = SY-CPROG
217          DYNPNR          = SY-DYNNR
218          DYNPROFIELD     = 'P9920-ZHOSPID'
219          VALUE_ORG       = 'S'
220        TABLES
221          VALUE_TAB       = IST_ZHR_MED_VENDORS
222          FIELD_TAB       = IST_FIELD
223          RETURN_TAB      = IST_RETURN_TAB
224          DYNPFLD_MAPPING = IST_DYNPFLD_MAPPING
225        EXCEPTIONS
226          PARAMETER_ERROR = 1
227          NO_VALUES_FOUND = 2
228          OTHERS          = 3.
229      IF SY-SUBRC <> 0.
230        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
231                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
232      ENDIF.
233
234      P9920-ZHOSPID = IST_RETURN_TAB-FIELDVAL.
235
236      clear tmp_lifnr.
237      tmp_lifnr = P9920-ZHOSPID.
238      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
239        EXPORTING
240          INPUT  = tmp_lifnr
241        IMPORTING
242          OUTPUT = tmp_lifnr.
243
244      P9920-ZHOSPID  = tmp_lifnr.
245
246    ENDMODULE.                 " GET_VENDOR  INPUT
247
248    *&---------------------------------------------------------------------*
249    *&      Module  GET_VENDOR  INPUT
250    *&---------------------------------------------------------------------*
251    *       text
252    *----------------------------------------------------------------------*
253    MODULE LOV_VENDOR_list INPUT.
254    *  data: tmp_lifnr type lfa1-lifnr.
255      REFRESH : DYFIELDS_1.
256      refresh: IST_ZHR_MED_VENDORS, IST_DYNPFLD_MAPPING, IST_FIELD, IST_RETURN_TAB .
257      clear: IST_DYNPFLD_MAPPING, IST_FIELD, IST_RETURN_TAB .
258      select BUKRS LIFNR NAME1 from ZHR_MED_VENDORS   " BUKRS, LIFNR
259        into CORRESPONDING FIELDS OF TABLE IST_ZHR_MED_VENDORS
260    *  where BUKRS = G_BUKRS.  " Now P9920-GRPVL
261          where BUKRS = P9920-GRPVL.
262
263
264    ****  IST_DYNPFLD_MAPPING-FLDNAME   = 'F0001'.
265    ****  IST_DYNPFLD_MAPPING-DYFLDNAME = 'P9920-ZHOSPID'.
266    ****
267    ****  APPEND IST_DYNPFLD_MAPPING.
268    ****  CLEAR : IST_DYNPFLD_MAPPING.
269    ****
270    ****  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
271    ****    EXPORTING
272    ****      RETFIELD        = 'LIFNR'
273    ****      DYNPPROG        = SY-CPROG
274    ****      DYNPNR          = SY-DYNNR
275    ****      DYNPROFIELD     = 'P9920-ZHOSPID'
276    ****      VALUE_ORG       = 'S'
277    ****    TABLES
278    ****      VALUE_TAB       = IST_ZHR_MED_VENDORS
279    ****      FIELD_TAB       = IST_FIELD
280    ****      RETURN_TAB      = IST_RETURN_TAB
281    ****      DYNPFLD_MAPPING = IST_DYNPFLD_MAPPING
282    ****    EXCEPTIONS
283    ****      PARAMETER_ERROR = 1
284    ****      NO_VALUES_FOUND = 2
285    ****      OTHERS          = 3.
286    ****  IF SY-SUBRC <> 0.
287    ****    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
288    ****            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
289    ****  ENDIF.
290
291    ****  P9920-ZHOSPID = IST_RETURN_TAB-FIELDVAL.
292
293      clear tmp_lifnr.
294      tmp_lifnr = P9920-ZHOSPID.
295      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
296        EXPORTING
297          INPUT  = tmp_lifnr
298        IMPORTING
299          OUTPUT = tmp_lifnr.
300
301      P9920-ZHOSPID  = tmp_lifnr.
302
303
304
305      REFRESH : g_list.  CLEAR g_value.
306      CLEAR g_list.
307
308      loop at IST_ZHR_MED_VENDORS into WA_ZHR_MED_VENDORS.
309        g_value-key  = WA_ZHR_MED_VENDORS-LIFNR.
310        CONCATENATE WA_ZHR_MED_VENDORS-BUKRS
311                    WA_ZHR_MED_VENDORS-NAME1 into  g_value-text separated by '-'.
312        APPEND g_value TO g_list.
313        CLEAR g_value.
314      endloop.
315
316      g_id = 'P9920-ZHOSPID'.
317
318      CALL FUNCTION 'VRM_SET_VALUES'
319        EXPORTING
320          id     = g_id
321          values = g_list.
322
323
324    ENDMODULE.                 " GET_VENDOR  INPUT
325
326    *&---------------------------------------------------------------------*
327    *&      Module  USER_COMMAND_0050  INPUT
328    *&---------------------------------------------------------------------*
329    *       text
330    *----------------------------------------------------------------------*
331    MODULE USER_COMMAND_0050 INPUT.
332      case ok_code_0050.
333        when 'CREA'.
334          CALL SCREEN 0101.
335        WHEN 'EDIT'.
336          CALL SCREEN 0301.
337    *    WHEN 'DEL'.
338    *      CALL SCREEN 0601.
339        WHEN 'MASSUPD'.
340          SUBMIT ZHRMED_PYMT_MASS_UPLOAD AND RETURN.
341    *      AND RETURN.
342        WHEN 'SUBMIT'.
343          CALL SCREEN 0401.
344        WHEN 'UNLOCK'.
345          CALL SCREEN 0501.
346        WHEN 'PAY'.
347          CALL SCREEN 0601.
348        WHEN 'STT'.           " status report , FS1.2
349          CALL SCREEN 0701.
350        WHEN 'DEL'.           " Delete claims, FS1.2
351          CALL SCREEN 0801.
352        WHEN 'PRINT'.           " Print Payment order, FS1.2
353          CALL SCREEN 0901.
354    *Begin RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP-Payment rreversal
355        WHEN 'PYMT_REV'.
356          CAll SCREEN 1001.
357    *End RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
358        WHEN 'PAY_SANC'.
359    *BEGIN RD1K984471       CAB_ALOK     ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
360    * Begin RD1K985179 CAB_ALOK Budget role for ZHRHOSP - CR 30009272
361    ** now separate role for medical fund mgmt, hence commented
362    *      PERFORM fund_mgmt_role_auth.
363    * End RD1K985179 CAB_ALOK Budget role for ZHRHOSP - CR 30009272
364    *End RD1K984471       CAB_ALOK     ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
365          CALL SCREEN 0051.
366
367      endcase.
368
369    ENDMODULE.                 " USER_COMMAND_0050  INPUT
370    *&---------------------------------------------------------------------*
371    *&      Module  FILL_LEADING_ZERO  INPUT
372    *&---------------------------------------------------------------------*
373    *       text
374    *----------------------------------------------------------------------*
375    MODULE FILL_LEADING_ZERO INPUT.
376    * Data returned from F4 for ZHOSPID (vendor code) doesn't have leading
377    * Zeros. Even calling CONVERSION_EXIT_ALPHA_INPUT after F4 didn't help.
378    * ( Leading zeros got appended in P9920-ZHOSPID but got over-written in PAI
379    * as screen was still having value without leading zeros returned by F4)
380    *  So, Reading the screen element P9920-ZHOSPID in PAI, adding zeros and
381    *  then updating it again.
382
383      Data : ist_dynpflds_zhospid like dynpread occurs 1 with header line.
384      data : tmp_zhospid type lfa1-lifnr.
385      ist_dynpflds_zhospid-fieldname = 'P9920-ZHOSPID'.
386
387      append ist_dynpflds_zhospid.
388
389      CALL FUNCTION 'DYNP_VALUES_READ'
390        EXPORTING
391          DYNAME               = sy-cprog
392          DYNUMB               = sy-dynnr
393        TABLES
394          DYNPFIELDS           = ist_dynpflds_zhospid
395        EXCEPTIONS
396          INVALID_ABAPWORKAREA = 1
397          INVALID_DYNPROFIELD  = 2
398          INVALID_DYNPRONAME   = 3
399          INVALID_DYNPRONUMMER = 4
400          INVALID_REQUEST      = 5
401          NO_FIELDDESCRIPTION  = 6
402          INVALID_PARAMETER    = 7
403          UNDEFIND_ERROR       = 8
404          DOUBLE_CONVERSION    = 9
405          STEPL_NOT_FOUND      = 10
406          OTHERS               = 11.
407      IF SY-SUBRC <> 0.
408    * MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
409    *         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
410      ENDIF.
411
412
413
414      clear tmp_zhospid.
415      tmp_zhospid = P9920-ZHOSPID.
416      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
417        EXPORTING
418          INPUT  = tmp_zhospid
419        IMPORTING
420          OUTPUT = tmp_zhospid.
421
422      P9920-ZHOSPID  = tmp_zhospid.
423
424      CALL FUNCTION 'DYNP_VALUES_UPDATE'
425        EXPORTING
426          DYNAME               = sy-cprog
427          DYNUMB               = sy-dynnr
428        TABLES
429          DYNPFIELDS           = ist_dynpflds_zhospid
430        EXCEPTIONS
431          INVALID_ABAPWORKAREA = 1
432          INVALID_DYNPROFIELD  = 2
433          INVALID_DYNPRONAME   = 3
434          INVALID_DYNPRONUMMER = 4
435          INVALID_REQUEST      = 5
436          NO_FIELDDESCRIPTION  = 6
437          UNDEFIND_ERROR       = 7
438          OTHERS               = 8.
439      IF SY-SUBRC <> 0.
440    * MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
441    *         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
442      ENDIF.
443
444    ****  if not P9920-ZHOSPID is INITIAL.
445    ****    data wa_medved type ZHR_MED_VENDORS.
446    ****    READ TABLE IST_ZHR_MED_VENDORS into wa_medved with key
447    ****                            lifnr = P9920-ZHOSPID.
448    ****    if sy-subrc ne 0.
449    ****      set CURSOR FIELD 'P9920-ZHOSPID'.
450    ****      message e000(zmsg) with 'Please select vendor from drop down only'.
451    ****    endif.
452    ****
453    ****
454    ****
455    ****    clear g_claim_not_save.
456    ****    select single * from zhr_med_vendors where lifnr = P9920-zhospid and
457    ****                                               BUKRS = P9920-GRPVL.
458    ****
459    ****    if zhr_med_vendors-taxable is INITIAL.
460    ****      g_claim_not_save = 'X'.
461    ****      message s000(zmsg)
462    ****      with 'Claim can not be saved - Hospital category for taxation '
463    ****           'not maintained'.
464    ****    endif.
465    ****
466    ****
467    ****  endif.
468
469    ENDMODULE.                 " FILL_LEADING_ZERO  INPUT
470    *&---------------------------------------------------------------------*
471    *&      Module  USER_COMMAND_0301  INPUT
472    *&---------------------------------------------------------------------*
473    *       text
474    *----------------------------------------------------------------------*
475    MODULE USER_COMMAND_0301 INPUT.
476      case OK_CODE_0301.
477        when 'GETREC'.
478          PERFORM GET_DATA_0301 . "on the basis of ZPMED_SUBMIT
479    **Struct.     ZPMED_SUBMIT
480    **    BEGDA_LOW          20100831
481    **    BEGDA_HIGH         20100929
482    **    UNAME_LOW          CAB_ALOK
483    **    UNAME_HIGH
484    **    ZHOSPID_LOW        800000
485    **    ZHOSPID_HIGH       800001
486          CALL SCREEN 0305.
487
488      endcase.
489
490    ENDMODULE.                 " USER_COMMAND_0301  INPUT
491    *&---------------------------------------------------------------------*
492    *&      Module  USER_COMMAND_0401  INPUT
493    *&---------------------------------------------------------------------*
494    *       text
495    *----------------------------------------------------------------------*
496    MODULE USER_COMMAND_0401 INPUT.
497      case OK_CODE_0401.
498        when 'GETREC'.
499          PERFORM GET_DATA_0401 . "on the basis of ZPMED_SUBMIT
500    **Struct.     ZPMED_SUBMIT
501    **    BEGDA_LOW          20100831
502    **    BEGDA_HIGH         20100929
503    **    UNAME_LOW          CAB_ALOK
504    **    UNAME_HIGH
505    **    ZHOSPID_LOW        800000
506    **    ZHOSPID_HIGH       800001
507          CALL SCREEN 0405.
508
509      endcase.
510    ENDMODULE.                 " USER_COMMAND_0401  INPUT
511    *&---------------------------------------------------------------------*
512    *&      Module  EXIT_0401  INPUT
513    *&---------------------------------------------------------------------*
514    *       text
515    *----------------------------------------------------------------------*
516    MODULE EXIT_0401 INPUT.
517      CASE ok_code_0401.
518
519        WHEN 'BACK' OR 'CANC'.
520          clear : ZPMED_SUBMIT.
521          clear: ok_code_0401.
522          LEAVE TO SCREEN 0.
523        when 'EXIT' .
524          clear : ZPMED_SUBMIT.
525          clear: ok_code_0401 .
526          LEAVE program.
527
528      ENDCASE.
529
530    ENDMODULE.                 " EXIT_0401  INPUT
531    *&---------------------------------------------------------------------*
532    *&      Module  EXIT_0050  INPUT
533    *&---------------------------------------------------------------------*
534    *       text
535    *----------------------------------------------------------------------*
536    MODULE EXIT_0050 INPUT.
537      CASE ok_code_0050.
538
539        WHEN 'BACK' OR 'CANC'.
540          clear : ZPMED_SUBMIT.
541          clear: ok_code_0050.
542          clear: G_USER_PERNR, G_USER_BUKRS, g_user_werks, g_user_name, g_user_desig .
543          clear:  WA_AGR_USERS.
544          LEAVE TO SCREEN 0.
545        when 'EXIT' .
546          clear : ZPMED_SUBMIT.
547          clear: ok_code_0050.
548          clear: G_USER_PERNR, G_USER_BUKRS, g_user_werks, g_user_name, g_user_desig .
549          clear:  WA_AGR_USERS.
550          LEAVE program.
551
552      ENDCASE.
553    ENDMODULE.                 " EXIT_0050  INPUT
554
555    MODULE EXIT_0051 INPUT.
556      CASE ok_code_0051.
557
558        WHEN 'BACK' OR 'CANC'.
559          clear : ZPMED_SUBMIT.
560          clear: ok_code_0051, ZHRHOSPSANCTION.
561          LEAVE TO SCREEN 0.
562        when 'EXIT' .
563          clear : ZPMED_SUBMIT.
564          clear: ok_code_0051, ZHRHOSPSANCTION.
565          LEAVE program.
566
567      ENDCASE.
568    ENDMODULE.                 " EXIT_0050  INPUT
569
570
571
572
573
574    *&SPWIZARD: INPUT MODUL FOR TC 'TC_SUBMIT'. DO NOT CHANGE THIS LINE!
575    *&SPWIZARD: MARK TABLE
576    MODULE TC_SUBMIT_MARK INPUT.
577      DATA: g_TC_SUBMIT_wa2 like line of IST_9920_SUBMIT.
578      if TC_SUBMIT-line_sel_mode = 1
579      and WA_9920_SUBMIT-SEL = 'X'.
580        loop at IST_9920_SUBMIT into g_TC_SUBMIT_wa2
581          where SEL = 'X'.
582          g_TC_SUBMIT_wa2-SEL = ''.
583          modify IST_9920_SUBMIT
584            from g_TC_SUBMIT_wa2
585            transporting SEL.
586        endloop.
587      endif.
588      MODIFY IST_9920_SUBMIT
589        FROM WA_9920_SUBMIT
590        INDEX TC_SUBMIT-CURRENT_LINE
591        TRANSPORTING SEL.
592    ENDMODULE.                    "TC_SUBMIT_MARK INPUT
593
594    *&SPWIZARD: INPUT MODULE FOR TC 'TC_SUBMIT'. DO NOT CHANGE THIS LINE!
595    *&SPWIZARD: PROCESS USER COMMAND
596    MODULE TC_SUBMIT_USER_COMMAND INPUT.
597      OK_CODE_0405 = SY-UCOMM.
598      PERFORM USER_OK_TC_SUBMIT USING    'TC_SUBMIT'
599                                  'IST_9920_SUBMIT'
600                                  'SEL'
601                         CHANGING OK_CODE_0405.
602      SY-UCOMM = OK_CODE_0405.
603    ENDMODULE.                    "TC_SUBMIT_USER_COMMAND INPUT
604    *&---------------------------------------------------------------------*
605    *&      Module  EXIT_0405  INPUT
606    *&---------------------------------------------------------------------*
607    *       text
608    *----------------------------------------------------------------------*
609    MODULE EXIT_0405 INPUT.
610
611      CASE ok_code_0405.
612
613        WHEN 'BACK' OR 'CANC'.
614          clear : IST_9920_SUBMIT , WA_9920_SUBMIT .
615          refresh : IST_9920_SUBMIT.
616          clear: ok_code_0405.
617          LEAVE TO SCREEN 0.
618        when 'EXIT' .
619          clear : IST_9920_SUBMIT , WA_9920_SUBMIT .
620          refresh : IST_9920_SUBMIT.
621          clear: ok_code_0405.
622          LEAVE program.
623
624      ENDCASE.
625
626    ENDMODULE.                 " EXIT_0405  INPUT
627    *&---------------------------------------------------------------------*
628    *&      Module  EXIT_0501  INPUT
629    *&---------------------------------------------------------------------*
630    *       text
631    *----------------------------------------------------------------------*
632    MODULE EXIT_0501 INPUT.
633
634      CASE ok_code_0501.
635
636        WHEN 'BACK' OR 'CANC'.
637          clear : ZPMED_SUBMIT.
638          clear: ok_code_0501.
639          LEAVE TO SCREEN 0.
640        when 'EXIT' .
641          clear : ZPMED_SUBMIT.
642          clear: ok_code_0501.
643          LEAVE program.
644
645      ENDCASE.
646
647    ENDMODULE.                 " EXIT_0501  INPUT
648    *&---------------------------------------------------------------------*
649    *&      Module  USER_COMMAND_0501  INPUT
650    *&---------------------------------------------------------------------*
651    *       text
652    *----------------------------------------------------------------------*
653    MODULE USER_COMMAND_0501 INPUT.
654      case OK_CODE_0501.
655        when 'GETREC'.
656
657          PERFORM GET_DATA_0501 . "on the basis of ZPMED_SUBMIT
658    **Struct.     ZPMED_SUBMIT
659    **    BEGDA_LOW          20100831
660    **    BEGDA_HIGH         20100929
661    **    UNAME_LOW          CAB_ALOK
662    **    UNAME_HIGH
663    **    ZHOSPID_LOW        800000
664    **    ZHOSPID_HIGH       800001
665          CALL SCREEN 0505.
666
667      endcase.
668
669    ENDMODULE.                 " USER_COMMAND_0501  INPUT
670    *&---------------------------------------------------------------------*
671    *&      Module  EXIT_0505  INPUT
672    *&---------------------------------------------------------------------*
673    *       text
674    *----------------------------------------------------------------------*
675    MODULE EXIT_0505 INPUT.   "unlock
676
677      CASE ok_code_0505.
678
679        WHEN 'BACK' OR 'CANC'.
680          clear : IST_9920_UNLOCK , WA_9920_UNLOCK .
681          refresh : IST_9920_UNLOCK.
682          clear: ok_code_0505.
683          clear: G_FLAG_EDITMO,  G_FLAG_SAVEMO.
684          LEAVE TO SCREEN 0.
685        when 'EXIT' .
686          clear : IST_9920_UNLOCK , WA_9920_UNLOCK .
687          refresh : IST_9920_UNLOCK.
688          clear: ok_code_0505.
689          clear: G_FLAG_EDITMO,  G_FLAG_SAVEMO.
690          LEAVE program.
691
692      ENDCASE.
693
694    ENDMODULE.                 " EXIT_0505  INPUT
695    *&---------------------------------------------------------------------*
696    *&      Module  USER_COMMAND_0505  INPUT
697    *&---------------------------------------------------------------------*
698    *       text
699    *----------------------------------------------------------------------*
700    MODULE USER_COMMAND_0505 INPUT.
701
702    ENDMODULE.                 " USER_COMMAND_0505  INPUT
703
704    *&SPWIZARD: INPUT MODULE FOR TC 'TC_UNLOCK'. DO NOT CHANGE THIS LINE!
705    *&SPWIZARD: MODIFY TABLE
706    MODULE TC_UNLOCK_MODIFY INPUT.
707      MODIFY IST_9920_UNLOCK
708        FROM WA_9920_UNLOCK
709        INDEX TC_UNLOCK-CURRENT_LINE.
710    ENDMODULE.                    "TC_UNLOCK_MODIFY INPUT
711
712    *&SPWIZARD: INPUT MODUL FOR TC 'TC_UNLOCK'. DO NOT CHANGE THIS LINE!
713    *&SPWIZARD: MARK TABLE
714    MODULE TC_UNLOCK_MARK INPUT.
715      DATA: g_TC_UNLOCK_wa2 like line of IST_9920_UNLOCK.
716      if TC_UNLOCK-line_sel_mode = 1
717      and WA_9920_UNLOCK-SEL = 'X'.
718        loop at IST_9920_UNLOCK into g_TC_UNLOCK_wa2
719          where SEL = 'X'.
720          g_TC_UNLOCK_wa2-SEL = ''.
721          modify IST_9920_UNLOCK
722            from g_TC_UNLOCK_wa2
723            transporting SEL.
724        endloop.
725      endif.
726      MODIFY IST_9920_UNLOCK
727        FROM WA_9920_UNLOCK
728        INDEX TC_UNLOCK-CURRENT_LINE
729        TRANSPORTING SEL.
730    ENDMODULE.                    "TC_UNLOCK_MARK INPUT
731
732    *&SPWIZARD: INPUT MODULE FOR TC 'TC_UNLOCK'. DO NOT CHANGE THIS LINE!
733    *&SPWIZARD: PROCESS USER COMMAND
734    MODULE TC_UNLOCK_USER_COMMAND INPUT.
735    *begin RD1K979590 CAB_ALOK  CR 30006427:New features in ZHRHOSP
736      if G_FLAG_RESTRICT is INITIAL.
737    *end RD1K979590 CAB_ALOK  CR 30006427:New features in ZHRHOSP
738        OK_CODE_0505 = SY-UCOMM.
739        PERFORM USER_OK_TC_UNLOCK USING    'TC_UNLOCK'
740                                    'IST_9920_UNLOCK'
741                                    'SEL'
742                           CHANGING OK_CODE_0505.
743        SY-UCOMM = OK_CODE_0505.
744    *begin RD1K979590 CAB_ALOK  CR 30006427:New features in ZHRHOSP
745      endif.
746    *end RD1K979590 CAB_ALOK  CR 30006427:New features in ZHRHOSP
747    ENDMODULE.                    "TC_UNLOCK_USER_COMMAND INPUT
748    *&---------------------------------------------------------------------*
749    *&      Module  EXIT_0301  INPUT
750    *&---------------------------------------------------------------------*
751    *       text
752    *----------------------------------------------------------------------*
753    MODULE EXIT_0301 INPUT.
754      CASE ok_code_0301.
755
756        WHEN 'BACK' OR 'CANC'.
757          clear : ZPMED_SUBMIT.
758          clear: ok_code_0301.
759          LEAVE TO SCREEN 0.
760        when 'EXIT' .
761          clear : ZPMED_SUBMIT.
762          clear: ok_code_0301.
763          LEAVE program.
764
765      ENDCASE.
766    ENDMODULE.                 " EXIT_0301  INPUT
767
768    *&SPWIZARD: INPUT MODULE FOR TC 'TC_EDIT'. DO NOT CHANGE THIS LINE!
769    *&SPWIZARD: MODIFY TABLE
770    MODULE TC_EDIT_MODIFY INPUT.
771      MODIFY IST_9920_EDIT
772        FROM WA_9920_EDIT
773        INDEX TC_EDIT-CURRENT_LINE.
774    ENDMODULE.                    "TC_EDIT_MODIFY INPUT
775
776    *&SPWIZARD: INPUT MODUL FOR TC 'TC_EDIT'. DO NOT CHANGE THIS LINE!
777    *&SPWIZARD: MARK TABLE
778    MODULE TC_EDIT_MARK INPUT.
779      DATA: g_TC_EDIT_wa2 like line of IST_9920_EDIT.
780      if TC_EDIT-line_sel_mode = 1
781      and WA_9920_EDIT-SEL = 'X'.
782        loop at IST_9920_EDIT into g_TC_EDIT_wa2
783          where SEL = 'X'.
784          g_TC_EDIT_wa2-SEL = ''.
785          modify IST_9920_EDIT
786            from g_TC_EDIT_wa2
787            transporting SEL.
788        endloop.
789      endif.
790      MODIFY IST_9920_EDIT
791        FROM WA_9920_EDIT
792        INDEX TC_EDIT-CURRENT_LINE
793        TRANSPORTING SEL.
794    ENDMODULE.                    "TC_EDIT_MARK INPUT
795
796    *&SPWIZARD: INPUT MODULE FOR TC 'TC_EDIT'. DO NOT CHANGE THIS LINE!
797    *&SPWIZARD: PROCESS USER COMMAND
798    MODULE TC_EDIT_USER_COMMAND INPUT.
799      OK_CODE_0305 = SY-UCOMM.
800      PERFORM USER_OK_TC_EDIT USING    'TC_EDIT'
801                                  'IST_9920_EDIT'
802                                  'SEL'
803                         CHANGING OK_CODE_0305.
804      SY-UCOMM = OK_CODE_0305.
805    ENDMODULE.                    "TC_EDIT_USER_COMMAND INPUT
806    *&---------------------------------------------------------------------*
807    *&      Module  EXIT_0305  INPUT
808    *&---------------------------------------------------------------------*
809    *       text
810    *----------------------------------------------------------------------*
811    MODULE EXIT_0305 INPUT.
812      CASE ok_code_0305.
813
814        WHEN 'BACK' OR 'CANC'.
815          clear : IST_9920_EDIT , WA_9920_EDIT .
816          refresh : IST_9920_EDIT.
817          clear: ok_code_0305.
818          clear: G_FLAG_EDITDO,  G_FLAG_SAVEDO.
819          LEAVE TO SCREEN 0.
820        WHEN 'EXIT' .
821          clear : IST_9920_EDIT , WA_9920_EDIT .
822          refresh : IST_9920_EDIT.
823          clear: ok_code_0305.
824          clear: G_FLAG_EDITDO,  G_FLAG_SAVEDO.
825          LEAVE program.
826      ENDCASE.
827    ENDMODULE.                 " EXIT_0305  INPUT
828    *&---------------------------------------------------------------------*
829    *&      Module  EXIT_0601  INPUT
830    *&---------------------------------------------------------------------*
831    *       text
832    *----------------------------------------------------------------------*
833    MODULE EXIT_0601 INPUT.
834      CASE ok_code_0601.
835
836        WHEN 'BACK' OR 'CANC'.
837          clear : ZPMED_SUBMIT.
838          clear: ok_code_0601.
839          LEAVE TO SCREEN 0.
840        when 'EXIT' .
841          clear : ZPMED_SUBMIT.
842          clear: ok_code_0601.
843          LEAVE program.
844
845      ENDCASE.
846
847    ENDMODULE.                 " EXIT_0601  INPUT
848    *&---------------------------------------------------------------------*
849    *&      Module  USER_COMMAND_0601  INPUT
850    *&---------------------------------------------------------------------*
851    *       text
852    *----------------------------------------------------------------------*
853    MODULE USER_COMMAND_0601 INPUT.
854      case OK_CODE_0601.
855        when 'GETREC'.
856
857
858
859          if ZPMED_SUBMIT-ZLOT_NO_LOW is not INITIAL.
860    * begin RD1K976266 CAB_ALOK  CR 30006546 Changes in ZHRHOSP-Duplicate documen
861            Perform CHECK_LOT_LOCK .
862    * end RD1K976266 CAB_ALOK  CR 30006546 Changes in ZHRHOSP-Duplicate documen
863            PERFORM GET_DATA_0601 . "on the basis of ZPMED_SUBMIT
864          endif.
865          CALL SCREEN 0605.
866
867      endcase.
868    ENDMODULE.                 " USER_COMMAND_0601  INPUT
869
870    *&---------------------------------------------------------------------*
871    *&      Module  GET_LOTNO  INPUT
872    *&---------------------------------------------------------------------*
873    *       text
874    *----------------------------------------------------------------------*
875    MODULE LOV_LOTNO_UNLOCKED INPUT.
876
877      REFRESH : DYFIELDS_1.
878      refresh: IST_LOT, IST_DYNPFLD_MAPPING, IST_FIELD, IST_RETURN_TAB .
879      Clear: IST_DYNPFLD_MAPPING, IST_FIELD, IST_RETURN_TAB .
880
881      select ZLOT_NO BEGDA from PA9920   "BEGDA, lot no, Submission no.,
882        into CORRESPONDING FIELDS OF TABLE IST_LOT
883          where zstatus = 'UNLOCKED'
884          and GRPVL = G_USER_BUKRS.
885
886      SORT IST_LOT BY ZLOT_NO BEGDA ASCENDING.
887      DELETE ADJACENT DUPLICATES FROM IST_LOT COMPARING ZLOT_NO .
888    *    IST_DYNPFLD_MAPPING-FLDNAME   = 'F0001'.
889    *   IST_DYNPFLD_MAPPING-DYFLDNAME = 'ZPMED_SUBMIT-ZLOT_NO_LOW'.
890    *
891    *   APPEND IST_DYNPFLD_MAPPING.
892    *   CLEAR : IST_DYNPFLD_MAPPING.
893
894
895    *    IST_FIELD-TABNAME   = 'ZPMED_SUBMIT'.
896    *   IST_FIELD-FIELDNAME = 'ZLOT_NO_LOW'.
897    *   IST_FIELD-REPTEXT = 'LOT_NO'.
898    *
899    *  APPEND IST_FIELD.
900    *  CLEAR IST_FIELD.
901
902
903
904      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
905        EXPORTING
906          RETFIELD        = 'ZLOT_NO'
907          DYNPPROG        = SY-CPROG
908          DYNPNR          = SY-DYNNR
909          DYNPROFIELD     = 'ZPMED_SUBMIT-ZLOT_NO_LOW'
910          VALUE_ORG       = 'S'
911        TABLES
912          VALUE_TAB       = IST_LOT
913          FIELD_TAB       = IST_FIELD
914          RETURN_TAB      = IST_RETURN_TAB
915          DYNPFLD_MAPPING = IST_DYNPFLD_MAPPING
916        EXCEPTIONS
917          PARAMETER_ERROR = 1
918          NO_VALUES_FOUND = 2
919          OTHERS          = 3.
920      IF SY-SUBRC <> 0.
921        MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
922                WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
923      ENDIF.
924
925      ZPMED_SUBMIT-ZLOT_NO_LOW = IST_RETURN_TAB-FIELDVAL.
926
927    *  clear tmp_lifnr.
928    *  tmp_lifnr = P9920-ZHOSPID.
929    *  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
930    *    EXPORTING
931    *      INPUT  = tmp_lifnr
932    *    IMPORTING
933    *      OUTPUT = tmp_lifnr.
934    *
935    *  P9920-ZHOSPID  = tmp_lifnr.
936
937
938    ENDMODULE.                 " GET_LOTNO  INPUT
939
940
941    *&---------------------------------------------------------------------*
942    *&      Module  EXIT_0605  INPUT
943    *&---------------------------------------------------------------------*
944    *       text
945    *----------------------------------------------------------------------*
946    MODULE EXIT_0605 INPUT.
947      CASE ok_code_0605.
948
949        WHEN 'BACK' OR 'CANC'.
950          clear : IST_9920_PAY , WA_9920_PAY .
951          refresh : IST_9920_PAY.
952          clear: ok_code_0605.
953          clear: G_FLAG_EDITFI,  G_FLAG_SAVEFI.
954          Clear: G_BUDAT, G_SECCO, G_KIDNO, G_WT_WITHCD, G_WT_BASE, G_WITHT, WA_PAY.
955          refresh: IST_SECCO, IST_WT_WITHCD, IST_WITHT, ist_9920_pay_tmp.
956          Clear: IST_RETURN_TAB.
957          refresh:  IST_RETURN_TAB.
958
959    * Begin RD1K978727 CAB_ALOK  CR 30006619 - Lot No. Lock mechanism
960    * begin RD1K976266 CAB_ALOK  CR 30006546 Changes in ZHRHOSP-Duplicate documen
961    *         SET PARAMETER ID 'ZSPA_LOT_NO' FIELD SPACE .
962    *         DELETE FROM ZHRMED_LOT_LOCK
963    *           WHERE  ZLOT_NO = ZPMED_SUBMIT-ZLOT_NO_LOW.
964
965          perform UNLOCK_LOT_NO using ZPMED_SUBMIT-ZLOT_NO_LOW.
966
967    * end RD1K976266 CAB_ALOK  CR 30006546 Changes in ZHRHOSP-Duplicate documen
968    * end RD1K978727 CAB_ALOK  CR 30006619 - Lot No. Lock mechanism
969          LEAVE TO SCREEN 0.
970        when 'EXIT' .
971          clear : IST_9920_PAY , WA_9920_PAY .
972          refresh : IST_9920_PAY.
973          clear: ok_code_0605.
974          clear: G_FLAG_EDITFI,  G_FLAG_SAVEFI.
975          Clear: G_BUDAT, G_SECCO, G_KIDNO, G_WT_WITHCD, G_WT_BASE, G_WITHT, WA_PAY.
976          refresh: IST_SECCO, IST_WT_WITHCD, IST_WITHT, ist_9920_pay_tmp.
977          Clear: IST_RETURN_TAB.
978          refresh:  IST_RETURN_TAB.
979    * Begin RD1K978727 CAB_ALOK  CR 30006619 - Lot No. Lock mechanism
980    * begin RD1K976266 CAB_ALOK  CR 30006546 Changes in ZHRHOSP-Duplicate documen
981    *         SET PARAMETER ID 'ZSPA_LOT_NO' FIELD SPACE .
982    *         DELETE FROM ZHRMED_LOT_LOCK
983    *           WHERE  ZLOT_NO = ZPMED_SUBMIT-ZLOT_NO_LOW.
984
985          perform UNLOCK_LOT_NO using ZPMED_SUBMIT-ZLOT_NO_LOW.
986    * end RD1K976266 CAB_ALOK  CR 30006546 Changes in ZHRHOSP-Duplicate documen
987    * end RD1K978727 CAB_ALOK  CR 30006619 - Lot No. Lock mechanism
988          LEAVE program.
989
990      ENDCASE.
991    ENDMODULE.                 " EXIT_0605  INPUT
992
993    *&SPWIZARD: INPUT MODULE FOR TC 'TC_PAY'. DO NOT CHANGE THIS LINE!
994    *&SPWIZARD: MODIFY TABLE
995    MODULE TC_PAY_MODIFY INPUT.
996      MODIFY IST_9920_PAY
997        FROM WA_9920_PAY
998        INDEX TC_PAY-CURRENT_LINE.
999    ENDMODULE.                    "TC_PAY_MODIFY INPUT
1000
1001   *&SPWIZARD: INPUT MODUL FOR TC 'TC_PAY'. DO NOT CHANGE THIS LINE!
1002   *&SPWIZARD: MARK TABLE
1003   MODULE TC_PAY_MARK INPUT.
1004     DATA: g_TC_PAY_wa2 like line of IST_9920_PAY.
1005     if TC_PAY-line_sel_mode = 1
1006     and WA_9920_PAY-SEL = 'X'.
1007       loop at IST_9920_PAY into g_TC_PAY_wa2
1008         where SEL = 'X'.
1009         g_TC_PAY_wa2-SEL = ''.
1010         modify IST_9920_PAY
1011           from g_TC_PAY_wa2
1012           transporting SEL.
1013       endloop.
1014     endif.
1015     MODIFY IST_9920_PAY
1016       FROM WA_9920_PAY
1017       INDEX TC_PAY-CURRENT_LINE
1018       TRANSPORTING SEL.
1019   ENDMODULE.                    "TC_PAY_MARK INPUT
1020
1021   *&SPWIZARD: INPUT MODULE FOR TC 'TC_PAY'. DO NOT CHANGE THIS LINE!
1022   *&SPWIZARD: PROCESS USER COMMAND
1023   MODULE TC_PAY_USER_COMMAND INPUT.
1024     OK_CODE_0605 = SY-UCOMM.
1025     PERFORM USER_OK_TC_PAY USING    'TC_PAY'
1026                                 'IST_9920_PAY'
1027                                 'SEL'
1028                        CHANGING OK_CODE_0605.
1029     SY-UCOMM = OK_CODE_0605.
1030   ENDMODULE.                    "TC_PAY_USER_COMMAND INPUT
1031
1032   *&---------------------------------------------------------------------*
1033   *&      Module  EXIT_0701  INPUT
1034   *&---------------------------------------------------------------------*
1035   *       text
1036   *----------------------------------------------------------------------*
1037   MODULE EXIT_0701 INPUT.
1038     CASE ok_code_0701.
1039
1040       WHEN 'BACK' OR 'CANC'.
1041         clear : ZPMED_SUBMIT.
1042         clear: ok_code_0701.
1043         LEAVE TO SCREEN 0.
1044       when 'EXIT' .
1045         clear : ZPMED_SUBMIT.
1046         clear: ok_code_0701.
1047         LEAVE program.
1048
1049     ENDCASE.
1050   ENDMODULE.                 " EXIT_0701  INPUT
1051   *&---------------------------------------------------------------------*
1052   *&      Module  USER_COMMAND_0701  INPUT
1053   *&---------------------------------------------------------------------*
1054   *       text
1055   *----------------------------------------------------------------------*
1056   MODULE USER_COMMAND_0701 INPUT.
1057     case OK_CODE_0701.
1058       when 'GETREC'.
1059
1060         PERFORM GET_DATA_701 . "on the basis of ZPMED_SUBMIT
1061
1062         CALL SCREEN 0705.
1063
1064     endcase.
1065   ENDMODULE.                 " USER_COMMAND_0701  INPUT
1066
1067   *&SPWIZARD: INPUT MODUL FOR TC 'TC_STATUS_REP'. DO NOT CHANGE THIS LINE!
1068   *&SPWIZARD: MARK TABLE
1069   MODULE TC_STATUS_REP_MARK INPUT.
1070     DATA: g_TC_STATUS_REP_wa2 like line of IST_9920_STATUS.
1071     if TC_STATUS_REP-line_sel_mode = 1
1072     and WA_9920_STATUS-SEL = 'X'.
1073       loop at IST_9920_STATUS into g_TC_STATUS_REP_wa2
1074         where SEL = 'X'.
1075         g_TC_STATUS_REP_wa2-SEL = ''.
1076         modify IST_9920_STATUS
1077           from g_TC_STATUS_REP_wa2
1078           transporting SEL.
1079       endloop.
1080     endif.
1081     MODIFY IST_9920_STATUS
1082       FROM WA_9920_STATUS
1083       INDEX TC_STATUS_REP-CURRENT_LINE
1084       TRANSPORTING SEL.
1085   ENDMODULE.                    "TC_STATUS_REP_MARK INPUT
1086
1087   *&SPWIZARD: INPUT MODULE FOR TC 'TC_STATUS_REP'. DO NOT CHANGE THIS LINE
1088   *&SPWIZARD: PROCESS USER COMMAND
1089   MODULE TC_STATUS_REP_USER_COMMAND INPUT.
1090     OK_CODE_0705 = SY-UCOMM.
1091     PERFORM USER_OK_TC_STATUS_REP USING    'TC_STATUS_REP'
1092                                 'IST_9920_STATUS'
1093                                 'SEL'
1094                        CHANGING OK_CODE_0705.
1095     SY-UCOMM = OK_CODE_0705.
1096   ENDMODULE.                    "TC_STATUS_REP_USER_COMMAND INPUT
1097   *&---------------------------------------------------------------------*
1098   *&      Module  EXIT_0705  INPUT
1099   *&---------------------------------------------------------------------*
1100   *       text
1101   *----------------------------------------------------------------------*
1102   MODULE EXIT_0705 INPUT.
1103     CASE ok_code_0705.
1104
1105       WHEN 'BACK' OR 'CANC'.
1106         clear : IST_9920_STATUS , WA_9920_STATUS .
1107         refresh : IST_9920_STATUS.
1108         clear: ok_code_0705.
1109         LEAVE TO SCREEN 0.
1110       when 'EXIT' .
1111         clear : IST_9920_STATUS , WA_9920_STATUS .
1112         refresh : IST_9920_STATUS.
1113         clear: ok_code_0705.
1114         LEAVE program.
1115
1116     ENDCASE.
1117   ENDMODULE.                 " EXIT_0705  INPUT
1118   *&---------------------------------------------------------------------*
1119   *&      Module  LOV_G_SECCO  INPUT
1120   *&---------------------------------------------------------------------*
1121   *       text
1122   *----------------------------------------------------------------------*
1123   MODULE LOV_G_SECCO INPUT.
1124     REFRESH : DYFIELDS_1.
1125     refresh: IST_SECCO, IST_DYNPFLD_MAPPING, IST_FIELD, IST_RETURN_TAB .
1126     clear: IST_DYNPFLD_MAPPING, IST_FIELD, IST_RETURN_TAB .
1127     select SECCODE from SECCODE     "V_SECCODE
1128       into CORRESPONDING FIELDS OF TABLE IST_SECCO
1129         where BUKRS =  G_USER_BUKRS.
1130
1131     SORT IST_SECCO BY SECCODE ASCENDING.  "NAME
1132     DELETE ADJACENT DUPLICATES FROM IST_SECCO COMPARING SECCODE . "NAME
1133   *    IST_DYNPFLD_MAPPING-FLDNAME   = 'F0001'.
1134   *   IST_DYNPFLD_MAPPING-DYFLDNAME = 'ZPMED_SUBMIT-ZLOT_NO_LOW'.
1135   *
1136   *   APPEND IST_DYNPFLD_MAPPING.
1137   *   CLEAR : IST_DYNPFLD_MAPPING.
1138
1139
1140   *    IST_FIELD-TABNAME   = 'ZPMED_SUBMIT'.
1141   *   IST_FIELD-FIELDNAME = 'ZLOT_NO_LOW'.
1142   *   IST_FIELD-REPTEXT = 'LOT_NO'.
1143   *
1144   *  APPEND IST_FIELD.
1145   *  CLEAR IST_FIELD.
1146
1147
1148
1149     CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
1150       EXPORTING
1151         RETFIELD        = 'SECCODE'
1152         DYNPPROG        = SY-CPROG
1153         DYNPNR          = SY-DYNNR
1154         DYNPROFIELD     = 'G_SECCO'
1155         VALUE_ORG       = 'S'
1156       TABLES
1157         VALUE_TAB       = IST_SECCO
1158         FIELD_TAB       = IST_FIELD
1159         RETURN_TAB      = IST_RETURN_TAB
1160         DYNPFLD_MAPPING = IST_DYNPFLD_MAPPING
1161       EXCEPTIONS
1162         PARAMETER_ERROR = 1
1163         NO_VALUES_FOUND = 2
1164         OTHERS          = 3.
1165     IF SY-SUBRC <> 0.
1166       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
1167               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
1168     ENDIF.
1169
1170     G_SECCO = IST_RETURN_TAB-FIELDVAL.
1171
1172   *  clear tmp_lifnr.
1173   *  tmp_lifnr = P9920-ZHOSPID.
1174   *  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
1175   *    EXPORTING
1176   *      INPUT  = tmp_lifnr
1177   *    IMPORTING
1178   *      OUTPUT = tmp_lifnr.
1179   *
1180   *  P9920-ZHOSPID  = tmp_lifnr.
1181
1182   ENDMODULE.                 " LOV_G_SECCO  INPUT
1183   *&---------------------------------------------------------------------*
1184   *&      Module  LOV_LOTNO_ALL  INPUT
1185   *&---------------------------------------------------------------------*
1186   *       text
1187   *----------------------------------------------------------------------*
1188   MODULE LOV_LOTNO_ALL INPUT.
1189
1190     REFRESH : DYFIELDS_1.
1191     refresh: IST_LOT, IST_DYNPFLD_MAPPING, IST_FIELD, IST_RETURN_TAB .
1192     Clear: IST_DYNPFLD_MAPPING, IST_FIELD, IST_RETURN_TAB .
1193     select ZLOT_NO BEGDA from PA9920   "lot no, Submission no., Submission No.,
1194       into CORRESPONDING FIELDS OF TABLE IST_LOT
1195         where GRPVL = G_USER_BUKRS.
1196
1197     SORT IST_LOT BY ZLOT_NO BEGDA ASCENDING.
1198     DELETE ADJACENT DUPLICATES FROM IST_LOT COMPARING ZLOT_NO.
1199     DELETE IST_LOT where ZLOT_NO = '' .
1200
1201     CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
1202       EXPORTING
1203         RETFIELD        = 'ZLOT_NO'
1204         DYNPPROG        = SY-CPROG
1205         DYNPNR          = SY-DYNNR
1206         DYNPROFIELD     = 'ZPMED_SUBMIT-ZLOT_NO_LOW'
1207         VALUE_ORG       = 'S'
1208       TABLES
1209         VALUE_TAB       = IST_LOT
1210         FIELD_TAB       = IST_FIELD
1211         RETURN_TAB      = IST_RETURN_TAB
1212         DYNPFLD_MAPPING = IST_DYNPFLD_MAPPING
1213       EXCEPTIONS
1214         PARAMETER_ERROR = 1
1215         NO_VALUES_FOUND = 2
1216         OTHERS          = 3.
1217     IF SY-SUBRC <> 0.
1218       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
1219               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
1220     ENDIF.
1221
1222     ZPMED_SUBMIT-ZLOT_NO_LOW = IST_RETURN_TAB-FIELDVAL.
1223
1224
1225
1226   ENDMODULE.                 " LOV_LOTNO_ALL  INPUT
1227   *&---------------------------------------------------------------------*
1228   *&      Module  LOV_G_KIDNO  INPUT
1229   *&---------------------------------------------------------------------*
1230   *       text
1231   *----------------------------------------------------------------------*
1232   MODULE LOV_G_KIDNO INPUT.
1233
1234   *DATA : ist_return_tab LIKE STANDARD TABLE OF ddshretval
1235   *                 WITH HEADER LINE.
1236     DATA : BEGIN OF wa_ims,
1237             trackno   TYPE zmm_ims-trackno,
1238   *          trackno   TYPE char30,
1239             lifnr     TYPE zmm_ims-lifnr,
1240             ebeln     TYPE zmm_ims-ebeln,
1241             invoiceno TYPE zmm_ims-invoiceno,
1242             invoicedt TYPE zmm_ims-invoicedt,
1243             reqloc    TYPE zmm_ims-reqloc,
1244            END OF wa_ims.
1245     DATA : BEGIN OF wa_ims2,
1246   *          trackno   TYPE zmm_ims-trackno,
1247             trackno   TYPE char30,
1248             lifnr     TYPE zmm_ims-lifnr,
1249             ebeln     TYPE zmm_ims-ebeln,
1250             invoiceno TYPE zmm_ims-invoiceno,
1251             invoicedt TYPE zmm_ims-invoicedt,
1252             reqloc    TYPE zmm_ims-reqloc,
1253            END OF wa_ims2.
1254     DATA : ist_ims   LIKE TABLE OF wa_ims,
1255            ist_ims_t LIKE TABLE OF wa_ims.
1256     DATA : ist_ims2   LIKE TABLE OF wa_ims2.
1257
1258
1259     DATA : BEGIN OF wa_loc,
1260             locid TYPE zlocmst-locid,
1261            END OF wa_loc.
1262
1263     DATA : ist_loc LIKE TABLE OF wa_loc.
1264
1265     clear: WA_PAY .
1266     clear:  IST_RETURN_TAB .
1267
1268     REFRESH : ist_return_tab,
1269               ist_ims,
1270               ist_ims_t.
1271
1272     CLEAR  : wa_ims,wa_ims2.
1273     REFRESH : ist_ims2.
1274     read table ist_9920_pay into wa_pay index 1.
1275
1276     if sy-subrc = 0.
1277
1278       SELECT trackno ebeln FROM zmm_ims_status
1279                INTO CORRESPONDING FIELDS OF TABLE ist_ims_t
1280                          WHERE mbli_stat IN ('R','Y') AND
1281                                mbli_asn NOT IN ('A','D').
1282
1283
1284       IF sy-subrc = 0.
1285         SELECT trackno lifnr ebeln invoiceno invoicedt
1286                    FROM zmm_ims INTO TABLE ist_ims
1287                       FOR ALL ENTRIES IN ist_ims_t
1288                         WHERE trackno = ist_ims_t-trackno.
1289
1290         IF sy-subrc = 0.
1291
1292           IF NOT WA_PAY-ZHOSPID IS INITIAL.
1293             DELETE ist_ims WHERE lifnr <> WA_PAY-ZHOSPID.
1294           ENDIF.
1295
1296   *Location wise validation for tracking no
1297           REFRESH ist_loc.
1298
1299           SELECT locid FROM zlocmst INTO TABLE ist_loc
1300               WHERE bukrs = G_USER_BUKRS.
1301
1302           IF sy-subrc = 0.
1303
1304             REFRESH ist_ims_t.
1305
1306             LOOP AT ist_ims INTO wa_ims.
1307
1308               READ TABLE ist_loc INTO wa_loc WITH KEY locid = wa_ims-trackno+6(3).
1309
1310               IF sy-subrc = 0.
1311
1312                 APPEND wa_ims TO ist_ims_t.
1313
1314               ENDIF.
1315
1316             ENDLOOP.
1317
1318             ist_ims[] = ist_ims_t[].
1319
1320           ENDIF.
1321
1322           IF ist_ims2[] IS INITIAL.
1323             LOOP AT ist_ims INTO wa_ims.
1324               MOVE-CORRESPONDING wa_ims TO wa_ims2.
1325               APPEND wa_ims2 TO ist_ims2.
1326             ENDLOOP.
1327             CLEAR wa_ims2.
1328   *       wa_ims2-trackno = 'CONT/LABOUR/DRS'.
1329             wa_ims2-trackno = 'CONT LABOUR'.
1330             APPEND wa_ims2 TO ist_ims2.
1331             wa_ims2-trackno = 'IMP/CONT'.
1332             APPEND wa_ims2 TO ist_ims2.
1333             wa_ims2-trackno = 'PAYROLL'.
1334             APPEND wa_ims2 TO ist_ims2.
1335             wa_ims2-trackno = 'LEASE EMPLOYEE'.
1336             APPEND wa_ims2 TO ist_ims2.
1337             wa_ims2-trackno = 'CSR'.
1338             APPEND wa_ims2 TO ist_ims2.
1339             wa_ims2-trackno = 'AUDIT-SCHOOL'.
1340             APPEND wa_ims2 TO ist_ims2.
1341   *       wa_ims2-trackno = 'LSC'.
1342             wa_ims2-trackno = 'LSC/LC'.
1343             APPEND wa_ims2 TO ist_ims2.
1344   *       wa_ims2-trackno = 'EMD/SD/TF'.
1345             wa_ims2-trackno = 'EMD/SD/TFS/LD'.
1346             APPEND wa_ims2 TO ist_ims2.
1347             wa_ims2-trackno = 'INSURANCE'.
1348             APPEND wa_ims2 TO ist_ims2.
1349             wa_ims2-trackno = 'LAQ'.
1350             APPEND wa_ims2 TO ist_ims2.
1351             wa_ims2-trackno = 'LEASE OFFICE'.
1352             APPEND wa_ims2 TO ist_ims2.
1353             wa_ims2-trackno = 'LEGAL'.
1354             APPEND wa_ims2 TO ist_ims2.
1355   *       wa_ims2-trackno = 'JV'.
1356             wa_ims2-trackno = 'JV CASH CALL'.
1357             APPEND wa_ims2 TO ist_ims2.
1358             wa_ims2-trackno = 'STAT PAYMENTS'.
1359             APPEND wa_ims2 TO ist_ims2.
1360
1361             wa_ims2-trackno = 'Utility Payments'.
1362             APPEND wa_ims2 TO ist_ims2.
1363             wa_ims2-trackno = 'Doctor'.
1364             APPEND wa_ims2 TO ist_ims2.
1365             wa_ims2-trackno = 'CLEARING'.
1366             APPEND wa_ims2 TO ist_ims2.
1367
1368
1369             wa_ims2-trackno = 'TRVL-HTL'.
1370             APPEND wa_ims2 TO ist_ims2.
1371
1372
1373           ENDIF.
1374
1375           CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
1376             EXPORTING
1377               retfield        = 'TRACKNO'
1378               dynpprog        = SY-CPROG
1379               dynpnr          = SY-DYNNR
1380               dynprofield     = 'G_KIDNO'
1381               value_org       = 'S'
1382             TABLES
1383   *           value_tab       = ist_ims
1384               value_tab       = ist_ims2
1385               return_tab      = ist_return_tab
1386             EXCEPTIONS
1387               parameter_error = 1
1388               no_values_found = 2
1389               OTHERS          = 3.
1390
1391           IF sy-subrc <> 0.
1392
1393             MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
1394                     WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
1395
1396           ENDIF.
1397
1398           G_KIDNO =  ist_return_tab-fieldval.
1399
1400         ENDIF.
1401
1402       ENDIF.
1403
1404     endif . "sy-subrc = 0.
1405   ENDMODULE.                 " LOV_G_KIDNO  INPUT
1406   *&---------------------------------------------------------------------*
1407   *&      Module  LOV_G_WITHT  INPUT
1408   *&---------------------------------------------------------------------*
1409   *       text
1410   *----------------------------------------------------------------------*
1411   MODULE LOV_G_WITHT INPUT.   "W/tax type
1412     data: WA_WITHT type TY_WITHT.
1413     REFRESH : DYFIELDS_1.
1414     refresh: IST_WITHT, IST_DYNPFLD_MAPPING, IST_FIELD, IST_RETURN_TAB .
1415     clear: IST_DYNPFLD_MAPPING, IST_FIELD, IST_RETURN_TAB .
1416     clear: WA_PAY.
1417     REFRESH : ist_9920_pay_tmp.
1418
1419     ist_9920_pay_tmp[] =  ist_9920_pay[].
1420     read table ist_9920_pay_tmp into wa_pay index 1.
1421
1422     if sy-subrc = 0.
1423
1424       select WITHT from LFBW
1425         into CORRESPONDING FIELDS OF TABLE IST_WITHT
1426           where LIFNR = WA_PAY-ZHOSPID
1427                and BUKRS = G_USER_BUKRS
1428   * begin RD1K979096 CAB_ALOK ZHRHOSP - Modification in Tax code logic- CR 30006712
1429                and WT_SUBJCT = 'X'.  "  Indicator: Subject to withholding tax    .
1430   * end RD1K979096 CAB_ALOK ZHRHOSP - Modification in Tax code logic- CR 30006712
1431
1432
1433       SORT IST_WITHT BY WITHT ASCENDING.
1434       DELETE ADJACENT DUPLICATES FROM IST_WITHT COMPARING WITHT.
1435       delete IST_WITHT where WITHT CA 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.
1436   *   if WA-WITHT CO 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.
1437
1438   *  DELETE IST_WITHT where WITHT = '' .
1439       clear WA_WITHT.
1440       loop at IST_WITHT into WA_WITHT.
1441         select SINGLE TEXT40
1442           into WA_WITHT-TEXT40
1443             from T059U
1444               where  SPRAS = 'EN'
1445                  and LAND1 = 'IN'
1446                  and WITHT = WA_WITHT-WITHT.
1447         concatenate WA_WITHT-WITHT ':' WA_WITHT-TEXT40 into WA_WITHT-TEXT40.
1448         MODIFY  IST_WITHT from WA_WITHT.
1449       endloop.
1450
1451       CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
1452         EXPORTING
1453           RETFIELD        = 'WITHT'
1454           DYNPPROG        = SY-CPROG
1455           DYNPNR          = SY-DYNNR
1456           DYNPROFIELD     = 'G_WITHT'
1457           VALUE_ORG       = 'S'
1458         TABLES
1459           VALUE_TAB       = IST_WITHT
1460           FIELD_TAB       = IST_FIELD
1461           RETURN_TAB      = IST_RETURN_TAB
1462           DYNPFLD_MAPPING = IST_DYNPFLD_MAPPING
1463         EXCEPTIONS
1464           PARAMETER_ERROR = 1
1465           NO_VALUES_FOUND = 2
1466           OTHERS          = 3.
1467       IF SY-SUBRC <> 0.
1468         MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
1469                 WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
1470       ENDIF.
1471
1472       G_WITHT = IST_RETURN_TAB-FIELDVAL.
1473     endif. " sy-subrc = 0.
1474   ENDMODULE.                 " LOV_G_WITHT  INPUT
1475   *&---------------------------------------------------------------------*
1476   *&      Module  LOV_G_WT_WITHCD  INPUT
1477   *&---------------------------------------------------------------------*
1478   *       text
1479   *----------------------------------------------------------------------*
1480   MODULE LOV_G_WT_WITHCD INPUT.
1481     data: WA_WT_WITHCD type TY_WT_WITHCD.
1482     REFRESH : DYFIELDS_1.
1483     refresh: IST_WT_WITHCD, IST_DYNPFLD_MAPPING, IST_FIELD, IST_RETURN_TAB .
1484     clear: IST_DYNPFLD_MAPPING, IST_FIELD, IST_RETURN_TAB .
1485
1486
1487     select WT_WITHCD from t059z
1488        into CORRESPONDING FIELDS OF TABLE IST_WT_WITHCD
1489          where land1 = 'IN'
1490            and WITHT = G_WITHT.
1491
1492     if sy-subrc = 0.
1493
1494
1495       SORT IST_WT_WITHCD BY WT_WITHCD ASCENDING.
1496       DELETE ADJACENT DUPLICATES FROM IST_WT_WITHCD COMPARING WT_WITHCD.
1497   *  DELETE IST_WITHT where WITHT = '' .
1498
1499       clear WA_WT_WITHCD.
1500       loop at IST_WT_WITHCD into WA_WT_WITHCD.
1501         select SINGLE TEXT40
1502           into WA_WT_WITHCD-TEXT40
1503             from T059ZT
1504               where  SPRAS = 'EN'
1505                  and LAND1 = 'IN'
1506                  and WITHT = G_WITHT
1507                  and WT_WITHCD = WA_WT_WITHCD-WT_WITHCD.
1508
1509         concatenate WA_WT_WITHCD-WT_WITHCD ':' WA_WT_WITHCD-TEXT40 into WA_WT_WITHCD-TEXT40.
1510
1511         MODIFY  IST_WT_WITHCD from WA_WT_WITHCD.
1512       endloop.
1513
1514       CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
1515         EXPORTING
1516           RETFIELD        = 'WT_WITHCD'
1517           DYNPPROG        = SY-CPROG
1518           DYNPNR          = SY-DYNNR
1519           DYNPROFIELD     = 'G_WT_WITHCD'
1520           VALUE_ORG       = 'S'
1521         TABLES
1522           VALUE_TAB       = IST_WT_WITHCD
1523           FIELD_TAB       = IST_FIELD
1524           RETURN_TAB      = IST_RETURN_TAB
1525           DYNPFLD_MAPPING = IST_DYNPFLD_MAPPING
1526         EXCEPTIONS
1527           PARAMETER_ERROR = 1
1528           NO_VALUES_FOUND = 2
1529           OTHERS          = 3.
1530       IF SY-SUBRC <> 0.
1531         MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
1532                 WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
1533       ENDIF.
1534
1535       G_WT_WITHCD = IST_RETURN_TAB-FIELDVAL.
1536     endif. " sy-subrc = 0.
1537   ENDMODULE.                 " LOV_G_WT_WITHCD  INPUT
1538   *&---------------------------------------------------------------------*
1539   *&      Module  EXIT_0801  INPUT
1540   *&---------------------------------------------------------------------*
1541   *       text
1542   *----------------------------------------------------------------------*
1543   MODULE EXIT_0801 INPUT.
1544     CASE ok_code_0801.
1545
1546       WHEN 'BACK' OR 'CANC'.
1547         clear : ZPMED_SUBMIT.
1548         clear: ok_code_0801.
1549         LEAVE TO SCREEN 0.
1550       when 'EXIT' .
1551         clear : ZPMED_SUBMIT.
1552         clear: ok_code_0801.
1553         LEAVE program.
1554
1555     ENDCASE.
1556   ENDMODULE.                 " EXIT_0801  INPUT
1557   *&---------------------------------------------------------------------*
1558   *&      Module  USER_COMMAND_0801  INPUT
1559   *&---------------------------------------------------------------------*
1560   *       text
1561   *----------------------------------------------------------------------*
1562   MODULE USER_COMMAND_0801 INPUT.
1563     case OK_CODE_0801.
1564       when 'GETREC'.
1565
1566         PERFORM GET_DATA_801 . "on the basis of ZPMED_SUBMIT
1567
1568         CALL SCREEN 0805.
1569
1570     endcase.
1571   ENDMODULE.                 " USER_COMMAND_0801  INPUT
1572   *&---------------------------------------------------------------------*
1573   *&      Module  LOV_LOTNO_REJ_NEW  INPUT
1574   *&---------------------------------------------------------------------*
1575   *       text
1576   *----------------------------------------------------------------------*
1577   MODULE LOV_LOTNO_REJ_NEW INPUT.
1578     REFRESH : DYFIELDS_1.
1579     refresh: IST_LOT, IST_DYNPFLD_MAPPING, IST_FIELD, IST_RETURN_TAB .
1580     Clear: IST_DYNPFLD_MAPPING, IST_FIELD, IST_RETURN_TAB .
1581
1582     select ZLOT_NO BEGDA from PA9920   "lot no, Submission no., Submission No.,
1583       into CORRESPONDING FIELDS OF TABLE IST_LOT
1584         where GRPVL = G_USER_BUKRS
1585            and ( zstatus = 'NEW' or zstatus = 'REJMO' or zstatus = 'REJFI' ).
1586
1587     SORT IST_LOT BY ZLOT_NO BEGDA ASCENDING.
1588     DELETE ADJACENT DUPLICATES FROM IST_LOT COMPARING ZLOT_NO BEGDA.
1589     DELETE IST_LOT where ZLOT_NO = '' .
1590
1591
1592     CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
1593       EXPORTING
1594         RETFIELD        = 'ZLOT_NO'
1595         DYNPPROG        = SY-CPROG
1596         DYNPNR          = SY-DYNNR
1597         DYNPROFIELD     = 'ZPMED_SUBMIT-ZLOT_NO_LOW'
1598         VALUE_ORG       = 'S'
1599       TABLES
1600         VALUE_TAB       = IST_LOT
1601         FIELD_TAB       = IST_FIELD
1602         RETURN_TAB      = IST_RETURN_TAB
1603         DYNPFLD_MAPPING = IST_DYNPFLD_MAPPING
1604       EXCEPTIONS
1605         PARAMETER_ERROR = 1
1606         NO_VALUES_FOUND = 2
1607         OTHERS          = 3.
1608     IF SY-SUBRC <> 0.
1609       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
1610               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
1611     ENDIF.
1612
1613     ZPMED_SUBMIT-ZLOT_NO_LOW = IST_RETURN_TAB-FIELDVAL.
1614
1615
1616   ENDMODULE.                 " LOV_LOTNO_REJ_NEW  INPUT
1617   *&---------------------------------------------------------------------*
1618   *&      Module  LOV_STATUS_REJ_NEW  INPUT
1619   *&---------------------------------------------------------------------*
1620   *       text
1621   *----------------------------------------------------------------------*
1622   MODULE LOV_STATUS_REJ_NEW INPUT.
1623     REFRESH : DYFIELDS_1.
1624     refresh: IST_STATUS, IST_DYNPFLD_MAPPING, IST_FIELD, IST_RETURN_TAB .
1625     Clear: IST_DYNPFLD_MAPPING, IST_FIELD, IST_RETURN_TAB .
1626
1627     DATA: WA_STATUS type TY_STATUS.
1628
1629     WA_STATUS-zstatus = 'NEW' .
1630     append WA_STATUS to IST_STATUS.
1631     WA_STATUS-zstatus = 'REJMO' .
1632     append WA_STATUS to IST_STATUS.
1633     WA_STATUS-zstatus = 'REJFI' .
1634     append WA_STATUS to IST_STATUS.
1635
1636
1637     CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
1638       EXPORTING
1639         RETFIELD        = 'ZSTATUS'
1640         DYNPPROG        = SY-CPROG
1641         DYNPNR          = SY-DYNNR
1642         DYNPROFIELD     = 'ZPMED_SUBMIT-ZSTATUS'
1643         VALUE_ORG       = 'S'
1644       TABLES
1645         VALUE_TAB       = IST_STATUS
1646         FIELD_TAB       = IST_FIELD
1647         RETURN_TAB      = IST_RETURN_TAB
1648         DYNPFLD_MAPPING = IST_DYNPFLD_MAPPING
1649       EXCEPTIONS
1650         PARAMETER_ERROR = 1
1651         NO_VALUES_FOUND = 2
1652         OTHERS          = 3.
1653     IF SY-SUBRC <> 0.
1654       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
1655               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
1656     ENDIF.
1657
1658   *  ZPMED_SUBMIT-ZSTATUS_LOW = IST_RETURN_TAB-FIELDVAL.
1659
1660   ENDMODULE.                 " LOV_STATUS_REJ_NEW  INPUT
1661
1662   *&SPWIZARD: INPUT MODULE FOR TC 'TC_DELETE'. DO NOT CHANGE THIS LINE!
1663   *&SPWIZARD: MODIFY TABLE
1664   MODULE TC_DELETE_MODIFY INPUT.
1665     MODIFY IST_9920_DELETE
1666       FROM WA_9920_DELETE
1667       INDEX TC_DELETE-CURRENT_LINE.
1668   ENDMODULE.                    "TC_DELETE_MODIFY INPUT
1669
1670   *&SPWIZARD: INPUT MODUL FOR TC 'TC_DELETE'. DO NOT CHANGE THIS LINE!
1671   *&SPWIZARD: MARK TABLE
1672   MODULE TC_DELETE_MARK INPUT.
1673     DATA: g_TC_DELETE_wa2 like line of IST_9920_DELETE.
1674     if TC_DELETE-line_sel_mode = 1
1675     and WA_9920_DELETE-SEL = 'X'.
1676       loop at IST_9920_DELETE into g_TC_DELETE_wa2
1677         where SEL = 'X'.
1678         g_TC_DELETE_wa2-SEL = ''.
1679         modify IST_9920_DELETE
1680           from g_TC_DELETE_wa2
1681           transporting SEL.
1682       endloop.
1683     endif.
1684     MODIFY IST_9920_DELETE
1685       FROM WA_9920_DELETE
1686       INDEX TC_DELETE-CURRENT_LINE
1687       TRANSPORTING SEL.
1688   ENDMODULE.                    "TC_DELETE_MARK INPUT
1689
1690   *&SPWIZARD: INPUT MODULE FOR TC 'TC_DELETE'. DO NOT CHANGE THIS LINE!
1691   *&SPWIZARD: PROCESS USER COMMAND
1692   MODULE TC_DELETE_USER_COMMAND INPUT.
1693     OK_CODE_0805 = SY-UCOMM.
1694     PERFORM USER_OK_TC_DELETE USING    'TC_DELETE'
1695                                 'IST_9920_DELETE'
1696                                 'SEL'
1697                        CHANGING OK_CODE_0805.
1698     SY-UCOMM = OK_CODE_0805.
1699   ENDMODULE.                    "TC_DELETE_USER_COMMAND INPUT
1700   *&---------------------------------------------------------------------*
1701   *&      Module  EXIT_0805  INPUT
1702   *&---------------------------------------------------------------------*
1703   *       text
1704   *----------------------------------------------------------------------*
1705   MODULE EXIT_0805 INPUT.
1706     CASE ok_code_0805.
1707
1708       WHEN 'BACK' OR 'CANC'.
1709         clear : IST_9920_DELETE , WA_9920_DELETE .
1710         refresh : IST_9920_DELETE.
1711         clear: ok_code_0805.
1712         LEAVE TO SCREEN 0.
1713       when 'EXIT' .
1714         clear : IST_9920_DELETE , WA_9920_DELETE .
1715         refresh : IST_9920_DELETE.
1716         clear: ok_code_0805.
1717         LEAVE program.
1718
1719     ENDCASE.
1720   ENDMODULE.                 " EXIT_0805  INPUT
1721   *&---------------------------------------------------------------------*
1722   *&      Module  EXIT_0901  INPUT
1723   *&---------------------------------------------------------------------*
1724   *       text
1725   *----------------------------------------------------------------------*
1726   MODULE EXIT_0901 INPUT.
1727     CASE ok_code_0901.
1728
1729       WHEN 'BACK' OR 'CANC'.
1730         clear : ZPMED_SUBMIT.
1731         clear: ok_code_0901.
1732         LEAVE TO SCREEN 0.
1733       when 'EXIT' .
1734         clear : ZPMED_SUBMIT.
1735         clear: ok_code_0901.
1736         LEAVE program.
1737
1738     ENDCASE.
1739
1740   ENDMODULE.                 " EXIT_0901  INPUT
1741   *&---------------------------------------------------------------------*
1742   *&      Module  USER_COMMAND_0901  INPUT
1743   *&---------------------------------------------------------------------*
1744   *       text
1745   *----------------------------------------------------------------------*
1746   MODULE USER_COMMAND_0901 INPUT.
1747     case OK_CODE_0901.
1748       when 'PRINTL'.
1749
1750         if ZPMED_SUBMIT-ZLOT_NO_LOW is not INITIAL.
1751
1752           PERFORM PRINT_LETTER_0901 . "on the basis of ZPMED_SUBMIT-ZLOT_NO_LOW
1753
1754         endif.
1755
1756
1757     endcase.
1758   ENDMODULE.                 " USER_COMMAND_0901  INPUT
1759   *&---------------------------------------------------------------------*
1760   *&      Module  EXIT_0510  INPUT
1761   *&---------------------------------------------------------------------*
1762   *       text
1763   *----------------------------------------------------------------------*
1764   * begin RD1K978193 CAB_ALOK CR 30006378
1765   MODULE EXIT_0510 INPUT.
1766     CASE ok_code_0510.
1767
1768       WHEN 'BACK' OR 'CANC'.
1769         clear : ZPMED_SUBMIT.
1770         CLEAR  g_srch_flag.
1771         clear: ok_code_0510.
1772         LEAVE TO SCREEN 0.
1773       when 'EXIT' .
1774         clear : ZPMED_SUBMIT.
1775         CLEAR  g_srch_flag.
1776         clear: ok_code_0510.
1777         LEAVE program.
1778
1779     ENDCASE.
1780
1781   ENDMODULE.                 " EXIT_0510  INPUT
1782
1783   *&---------------------------------------------------------------------*
1784   *&      Module  USER_COMMAND_0510  INPUT
1785   *&---------------------------------------------------------------------*
1786   *       text
1787   *----------------------------------------------------------------------*
1788   MODULE USER_COMMAND_0510 INPUT.
1789
1790     CLEAR  g_srch_flag.
1791     CASE ok_code_0510.
1792
1793       when 'ENTR'.
1794   *    clear g_lifnr.
1795   *    clear g_panno.
1796         If ZPMED_SUBMIT-PERNR_LOW is not initial.
1797   *  g_lifnr = j_1imovend-lifnr.
1798           g_srch_flag = 'X'.
1799   *  elseif not j_1imovend-j_1ipanno is initial.
1800   *  g_panno = j_1imovend-j_1ipanno.
1801   *    g_vflag = 'X'.
1802         endif.
1803
1804         clear: ok_code_0510.
1805         leave  to screen  0.
1806       when 'CANC'.
1807         clear: ok_code_0510.
1808         Leave to  screen 0.
1809     ENDCASE.
1810   ENDMODULE.                 " USER_COMMAND_0510  INPUT
1811   * end RD1K978193 CAB_ALOK CR 30006378
1812
1813   *&---------------------------------------------------------------------*
1814   *&      Module  TC_UNLOCK_RESTRICT  INPUT
1815   *&---------------------------------------------------------------------*
1816   *       text
1817   *----------------------------------------------------------------------*
1818   *begin RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
1819   MODULE TC_UNLOCK_RESTRICT INPUT.
1820     data: wa_9920_UNLOCK_RESTRICT TYPE ty_submit,
1821           sel_count type i.
1822     data: MAX_UNLOCK type i.
1823
1824     clear G_FLAG_RESTRICT.
1825   * Begin RD1K981858       CAB_ALOK     Modification in 2 Level CHK :ZHRHOSP - CR 30007832
1826   *  MAX_UNLOCK = 200.       " Max No. of rows that can be unlocked under single LOT
1827     MAX_UNLOCK = 700.
1828   * End RD1K981858       CAB_ALOK     Modification in 2 Level CHK :ZHRHOSP - CR 30007832
1829
1830     if sy-ucomm = 'TC_UNLOCK_UNLOCK'.
1831       sel_count = 0.
1832       Loop at IST_9920_UNLOCK into wa_9920_UNLOCK_RESTRICT where SEL = 'X' and zstatus = 'SUBMITTED'.
1833         sel_count = sel_count + 1.
1834       Endloop.
1835
1836       if sel_count > MAX_UNLOCK.
1837         message w100(ZHR) with MAX_UNLOCK.
1838         G_FLAG_RESTRICT = 'X'.
1839       endif.
1840     endif.
1841
1842   ENDMODULE.                 " TC_UNLOCK_RESTRICT  INPUT
1843
1844   *&---------------------------------------------------------------------*
1845   *&      Module  CALCULATE_TOTALS  INPUT
1846   *&---------------------------------------------------------------------*
1847   *       text
1848   *----------------------------------------------------------------------*
1849   MODULE CALCULATE_TOTALS INPUT.
1850     perform CALCULATE_TOTALS .
1851   ENDMODULE.                 " CALCULATE_TOTALS  INPUT
1852
1853   *&---------------------------------------------------------------------*
1854   *&      Module  EXIT_1001  INPUT
1855   *&---------------------------------------------------------------------*
1856   *       text
1857   *----------------------------------------------------------------------*
1858   MODULE EXIT_1001 INPUT.
1859     CASE ok_code_1001.
1860       WHEN 'BACK' OR 'CANC'.
1861         clear : ZPMED_SUBMIT.
1862         clear: ok_code_1001.
1863         LEAVE TO SCREEN 0.
1864       when 'EXIT' .
1865         clear : ZPMED_SUBMIT.
1866         clear: ok_code_1001.
1867         LEAVE program.
1868
1869     ENDCASE.
1870   ENDMODULE.                 " EXIT_1001  INPUT
1871
1872
1873   *&---------------------------------------------------------------------*
1874   *&      Module  LOV_BELNR  INPUT
1875   *&---------------------------------------------------------------------*
1876   *       text
1877   *----------------------------------------------------------------------*
1878   MODULE LOV_LOT_BELNR INPUT.
1879
1880     REFRESH : DYFIELDS_1.
1881     refresh: IST_LOT_BELNR, IST_DYNPFLD_MAPPING, IST_FIELD, IST_RETURN_TAB .
1882     Clear: IST_DYNPFLD_MAPPING, IST_FIELD, IST_RETURN_TAB .
1883
1884     select ZLOT_NO BELNR GJAHR BUKRS from PA9920
1885       into CORRESPONDING FIELDS OF TABLE IST_LOT_BELNR
1886         where zstatus = 'PAID'.
1887
1888     SORT IST_LOT_BELNR BY ZLOT_NO BELNR GJAHR BUKRS ASCENDING .
1889     DELETE ADJACENT DUPLICATES FROM IST_LOT_BELNR COMPARING ALL FIELDS .
1890
1891
1892     IST_DYNPFLD_MAPPING-FLDNAME   = 'F0001'.
1893     IST_DYNPFLD_MAPPING-DYFLDNAME = 'ZPMED_SUBMIT-ZLOT_NO_LOW'.
1894
1895     APPEND IST_DYNPFLD_MAPPING.
1896     CLEAR : IST_DYNPFLD_MAPPING.
1897
1898     IST_DYNPFLD_MAPPING-FLDNAME   = 'F0002'.
1899     IST_DYNPFLD_MAPPING-DYFLDNAME = 'ZPMED_SUBMIT-BELNR'.
1900
1901     APPEND IST_DYNPFLD_MAPPING.
1902     CLEAR : IST_DYNPFLD_MAPPING.
1903
1904     IST_DYNPFLD_MAPPING-FLDNAME   = 'F0003'.
1905     IST_DYNPFLD_MAPPING-DYFLDNAME = 'ZPMED_SUBMIT-GJAHR'.
1906
1907     APPEND IST_DYNPFLD_MAPPING.
1908     CLEAR : IST_DYNPFLD_MAPPING.
1909
1910     IST_DYNPFLD_MAPPING-FLDNAME   = 'F0004'.
1911     IST_DYNPFLD_MAPPING-DYFLDNAME = 'ZPMED_SUBMIT-BUKRS'.
1912
1913     APPEND IST_DYNPFLD_MAPPING.
1914     CLEAR : IST_DYNPFLD_MAPPING.
1915
1916
1917     CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
1918       EXPORTING
1919         RETFIELD        = 'ZLOT_NO'
1920         DYNPPROG        = SY-CPROG
1921         DYNPNR          = SY-DYNNR
1922         DYNPROFIELD     = 'ZPMED_SUBMIT-ZLOT_NO_LOW'
1923         VALUE_ORG       = 'S'
1924       TABLES
1925         VALUE_TAB       = IST_LOT_BELNR
1926         FIELD_TAB       = IST_FIELD
1927         RETURN_TAB      = IST_RETURN_TAB
1928         DYNPFLD_MAPPING = IST_DYNPFLD_MAPPING
1929       EXCEPTIONS
1930         PARAMETER_ERROR = 1
1931         NO_VALUES_FOUND = 2
1932         OTHERS          = 3.
1933     IF SY-SUBRC <> 0.
1934       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
1935               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
1936     ENDIF.
1937
1938     ZPMED_SUBMIT-ZLOT_NO_LOW = IST_RETURN_TAB-FIELDVAL.
1939   ENDMODULE.                 " LOV_BELNR  INPUT
1940
1941
1942
1943   *&---------------------------------------------------------------------*
1944   *&      Module  VALIDATE_1001  INPUT
1945   *&---------------------------------------------------------------------*
1946   *       text
1947   *----------------------------------------------------------------------*
1948   MODULE VALIDATE_1001 INPUT.
1949
1950   * format data
1951     shift ZPMED_SUBMIT-ZLOT_NO_LOW LEFT DELETING LEADING SPACE.
1952     shift ZPMED_SUBMIT-BELNR LEFT DELETING LEADING SPACE.
1953     shift ZPMED_SUBMIT-GJAHR LEFT DELETING LEADING SPACE.
1954     shift ZPMED_SUBMIT-BUKRS LEFT DELETING LEADING SPACE.
1955
1956   * Validate Input
1957     select single * from PA9920
1958       WHERE ZLOT_NO = ZPMED_SUBMIT-ZLOT_NO_LOW
1959         AND BELNR = ZPMED_SUBMIT-BELNR
1960         AND GJAHR = ZPMED_SUBMIT-GJAHR
1961         AND BUKRS = ZPMED_SUBMIT-BUKRS.
1962     IF sy-subrc <> 0.
1963       message e117(ZHR).
1964     ENDIF.
1965
1966     if ZPMED_SUBMIT-ZLOT_NO_LOW is INITIAL
1967         or ZPMED_SUBMIT-BELNR is INITIAL
1968           or ZPMED_SUBMIT-GJAHR is INITIAL
1969             or ZPMED_SUBMIT-BUKRS is INITIAL   .
1970
1971       MESSAGE  e118(ZHR).
1972     endif.
1973
1974
1975
1976   ENDMODULE.                 " VALIDATE_1001  INPUT
1977
1978
1979   *&---------------------------------------------------------------------*
1980   *&      Module  USER_COMMAND_1001  INPUT
1981   *&---------------------------------------------------------------------*
1982   *       text
1983   *----------------------------------------------------------------------*
1984   MODULE USER_COMMAND_1001 INPUT.
1985     case OK_CODE_1001.
1986       when 'GETREC'.
1987
1988
1989
1990         if ZPMED_SUBMIT-ZLOT_NO_LOW is not INITIAL.
1991           PERFORM GET_DATA_1001 . "on the basis of ZPMED_SUBMIT
1992         endif.
1993
1994         clear G_FLAG_REVERSED . " To enable 'REVERSE' Button
1995         CALL SCREEN 1005.
1996
1997     endcase.
1998
1999
2000   ENDMODULE.                 " USER_COMMAND_1001  INPUT
2001
2002
2003
2004   *&---------------------------------------------------------------------*
2005   *&      Module  EXIT_1005  INPUT
2006   *&---------------------------------------------------------------------*
2007   *       text
2008   *----------------------------------------------------------------------*
2009   MODULE EXIT_1005 INPUT.
2010     CASE ok_code_1005.
2011
2012       WHEN 'BACK' OR 'CANC'.
2013         clear : ok_code_1005, IST_9920_REV , WA_9920_REV .
2014         refresh : IST_9920_REV.
2015         Clear: IST_RETURN_TAB.
2016         refresh:  IST_RETURN_TAB.
2017         LEAVE TO SCREEN 0.
2018
2019       when 'EXIT' .
2020         clear : ok_code_1005, IST_9920_REV , WA_9920_REV .
2021         refresh : IST_9920_REV.
2022         Clear: IST_RETURN_TAB.
2023         refresh:  IST_RETURN_TAB.
2024
2025         LEAVE program.
2026
2027     ENDCASE.
2028   ENDMODULE.                 " EXIT_1005  INPUT
2029
2030   *&SPWIZARD: INPUT MODULE FOR TC 'TC_REV'. DO NOT CHANGE THIS LINE!
2031   *&SPWIZARD: PROCESS USER COMMAND
2032   MODULE TC_REV_USER_COMMAND INPUT.
2033     OK_CODE_1005 = SY-UCOMM.
2034     PERFORM USER_OK_TC_REV USING    'TC_REV'
2035                                 'IST_9920_REV'
2036                                 ' '
2037                        CHANGING OK_CODE_1005.
2038     SY-UCOMM = OK_CODE_1005.
2039   ENDMODULE.                    "TC_REV_USER_COMMAND INPUT
2040   *end RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
2041   *&---------------------------------------------------------------------*
2042   *&      Module  USER_COMMAND_0051  INPUT
2043   *&---------------------------------------------------------------------*
2044   *       text
2045   *----------------------------------------------------------------------*
2046   module USER_COMMAND_0051 input.
2047     Data join_conf.
2048
2049     Case sy-ucomm.
2050
2051   *Begin RD1K997486       CAB_ALOK     Medical Vendor pymt for Contingent workers -CR 30012858
2052       When 'SANCREP'.
2053         CALL TRANSACTION 'ZFIMEDSANCREP'.
2054
2055   *End RD1K997486       CAB_ALOK     Medical Vendor pymt for Contingent workers -CR 30012858
2056
2057       When 'BACK_SANC'.
2058         clear ZHRHOSPSANCTION.
2059         CALL SCREEN 0050.
2060
2061       When 'ADD_SANC'.
2062
2063         If ZHRHOSPSANCTION-BUKRS is initial or
2064   **Begin RD1K996216   CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
2065            ZHRHOSPSANCTION-SECCO is initial or
2066   **End RD1K996216   CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
2067            ZHRHOSPSANCTION-GLHEAD is initial or
2068            ZHRHOSPSANCTION-GJAHR is initial or
2069            ZHRHOSPSANCTION-FILENO is initial or
2070            ZHRHOSPSANCTION-AMT is initial .
2071           MESSAGE i008(zhr).
2072
2073
2074         Else.
2075   * Begin RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
2076
2077
2078   **        Clear join_conf.
2079   **           CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
2080   **           EXPORTING
2081   **           DEFAULTOPTION        = 'J'
2082   **           textline1            = 'Please chose YES to confirm the amount and other details'
2083   ***          TEXTLINE2            = ' '
2084   **           titel                = 'Warning'
2085   ***          START_COLUMN         = 25
2086   ***          START_ROW            = 6
2087   ***          CANCEL_DISPLAY       = 'X'
2088   **          IMPORTING
2089   **          ANSWER               =  join_conf.
2090
2091   **        If join_conf = 'J'.
2092   * End RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
2093
2094
2095           Select single * from zhrhospsanction into wa_zhrhospsanction
2096             where BUKRS = ZHRHOSPSANCTION-BUKRS
2097               and GLHEAD = ZHRHOSPSANCTION-GLHEAD
2098   **Begin RD1K996216   CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
2099               and SECCO = ZHRHOSPSANCTION-SECCO
2100   **End RD1K996216   CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
2101               and GJAHR = ZHRHOSPSANCTION-GJAHR
2102               and FILENO = ZHRHOSPSANCTION-FILENO.
2103           If sy-subrc = 0.
2104   *        wa_zhrhospsanction-amt =   ZHRHOSPSANCTION-AMT + wa_zhrhospsanction-amt .
2105   *        Modify ZHRHOSPSANCTION from wa_zhrhospsanction .
2106   *        Commit work.
2107             Message i026(zhr).
2108   *        Clear ZHRHOSPSANCTION.
2109             CALL SCREEN 0051.
2110
2111           Else.
2112
2113             MOVE-CORRESPONDING ZHRHOSPSANCTION to wa_zhrhospsanction.
2114   * Begin RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
2115
2116             Data L_ANS.
2117             data: L_SANC_AMT type zhrhospsanction-AMT,
2118                   C_SANC_AMT(16),
2119                   L_UTIL_AMT TYPE ZHRHOSPSANC_UTL-UTILAMT,
2120                   C_UTIL_AMT(16),
2121                   L_MSG(255).
2122
2123             Clear: L_ANS, L_SANC_AMT, L_UTIL_AMT, L_MSG .
2124
2125             Select sum( AMT ) from zhrhospsanction
2126               into L_SANC_AMT
2127               where BUKRS = ZHRHOSPSANCTION-BUKRS
2128   **Begin RD1K996216   CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
2129                 and SECCO = ZHRHOSPSANCTION-SECCO
2130   **End RD1K996216   CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
2131                 and GLHEAD = ZHRHOSPSANCTION-GLHEAD
2132                 and GJAHR = ZHRHOSPSANCTION-GJAHR.
2133
2134   ** now only two commitment items
2135   **case  ZHRHOSPSANCTION-GLHEAD.
2136   **
2137   **when '0000200301'.
2138   **        Select sum( UTILAMT ) from ZHRHOSPSANC_UTL
2139   **          into L_UTIL_AMT
2140   **          where BUKRS = ZHRHOSPSANCTION-BUKRS
2141   **            and GLHEAD = ZHRHOSPSANCTION-GLHEAD
2142   **            and GJAHR = ZHRHOSPSANCTION-GJAHR.
2143   **
2144   **when '0000200302'.
2145   **
2146   **        Select sum( UTILAMT ) from ZHRHOSPSANC_UTL
2147   **          into L_UTIL_AMT
2148   **          where BUKRS = ZHRHOSPSANCTION-BUKRS
2149   **            and ( GLHEAD = '0000200302'
2150   **                  OR GLHEAD = '0000200307'
2151   **                  OR GLHEAD = '0000200308'
2152   **                  OR GLHEAD = '0000200309'
2153   **                  OR GLHEAD = '0000200317'
2154   **                  OR GLHEAD = '0000200318'
2155   **                 )
2156   **            and GJAHR = ZHRHOSPSANCTION-GJAHR.
2157   **endcase.
2158
2159             Select sum( UTILAMT ) from ZHRHOSPSANC_UTL
2160               into L_UTIL_AMT
2161               where BUKRS = ZHRHOSPSANCTION-BUKRS
2162   **Begin RD1K996216   CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
2163                 and SECCO = ZHRHOSPSANCTION-SECCO
2164   **End RD1K996216   CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
2165                 and GLHEAD = ZHRHOSPSANCTION-GLHEAD
2166                 and GJAHR = ZHRHOSPSANCTION-GJAHR.
2167
2168             move L_SANC_AMT to  C_SANC_AMT .
2169             move L_UTIL_AMT to  C_UTIL_AMT .
2170
2171             Concatenate 'Already entered sanction amount is RS'
2172               C_SANC_AMT ' out of which utilised is Rs' C_UTIL_AMT
2173               ' Do you want to enter this amount ?' into L_MSG RESPECTING BLANKS.
2174
2175   *           CALL FUNCTION 'POPUP_TO_CONFIRM_step'
2176   *           EXPORTING
2177   *           DEFAULTOPTION        = 'J'
2178   *           textline1            = L_MSG
2179   *           titel                = 'Message'
2180   *           IMPORTING
2181   *           ANSWER               =  L_ANS.
2182   *            if  L_ANS = 'J' .
2183
2184             CALL FUNCTION 'POPUP_TO_CONFIRM'
2185               EXPORTING
2186                 text_question = L_MSG
2187               IMPORTING
2188                 answer        = L_ANS.
2189
2190             if  L_ANS = '1' .
2191
2192   *End RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
2193
2194   * Begin RD1K996913       CAB_ALOK     Report for hospital Sanction Utilization - CR 30012633
2195
2196     CLEAR l_timestamp.
2197     CONVERT DATE SY-DATUM TIME SY-UZEIT INTO
2198             TIME STAMP l_timestamp TIME ZONE 'UTC   '.
2199     wa_zhrhospsanction-TIMESTAMP = l_timestamp.
2200     wa_zhrhospsanction-AENAM = SY-UNAME.
2201
2202   * update logs
2203     MOVE-CORRESPONDING wa_zhrhospsanction to WA_ZFIHOSPSANCLOG.
2204     Insert into ZFIHOSPSANCLOG  values WA_ZFIHOSPSANCLOG.
2205   * End RD1K996913       CAB_ALOK   Report for hospital Sanction Utilization - CR 30012633
2206
2207               Insert into ZHRHOSPSANCTION  values wa_zhrhospsanction.
2208               Commit work.
2209               Message i022(zhr).
2210   *Begin RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
2211   *     Clear ZHRHOSPSANCTION.
2212   *End RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
2213             endif.
2214   *Begin RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
2215             Clear ZHRHOSPSANCTION.
2216   *End RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
2217             CALL SCREEN 0050.
2218           Endif.
2219   * Begin RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
2220   *        Endif. ""
2221   * End RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
2222
2223
2224         Endif.
2225
2226       when 'CHA_SANC'.
2227   *begin RD1K984471  CAB_ALOK CR: 30008930 ZHRHOSP and ZHRNEHOSP sanction limits
2228         if sy-uname+0(3) <> 'CFI'
2229           and sy-uname+0(3) <> 'CAB' .
2230           MESSAGE e053(zhr).
2231         endif.
2232   *end RD1K984471  CAB_ALOK CR: 30008930 ZHRHOSP and ZHRNEHOSP sanction limits
2233
2234         If ZHRHOSPSANCTION-BUKRS is initial or
2235   **Begin RD1K996216   CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
2236             ZHRHOSPSANCTION-SECCO IS INITIAL or
2237   **End RD1K996216   CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
2238            ZHRHOSPSANCTION-GLHEAD is initial or
2239            ZHRHOSPSANCTION-GJAHR is initial or
2240            ZHRHOSPSANCTION-FILENO is initial or
2241            ZHRHOSPSANCTION-AMT is initial .
2242           MESSAGE i008(zhr).
2243         Else.
2244
2245           Clear join_conf.
2246           CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
2247             EXPORTING
2248               DEFAULTOPTION  = 'J'
2249               textline1      = 'Please chose YES to confirm the amount and other details'
2250   *           TEXTLINE2      = ' '
2251               titel          = 'Warning'
2252   *           START_COLUMN   = 25
2253   *           START_ROW      = 6
2254   *           CANCEL_DISPLAY = 'X'
2255             IMPORTING
2256               ANSWER         = join_conf.
2257
2258           If join_conf = 'J'.
2259             Select single * from zhrhospsanction into wa_zhrhospsanction
2260               where BUKRS = ZHRHOSPSANCTION-BUKRS
2261   **Begin RD1K996216   CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
2262                 and SECCO = ZHRHOSPSANCTION-SECCO
2263   **End RD1K996216   CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
2264                 and GLHEAD = ZHRHOSPSANCTION-GLHEAD
2265                 and GJAHR = ZHRHOSPSANCTION-GJAHR
2266                 and FILENO = ZHRHOSPSANCTION-FILENO.
2267             If sy-subrc = 0.
2268               wa_zhrhospsanction-amt =   ZHRHOSPSANCTION-AMT .
2269
2270   * Begin RD1K996913       CAB_ALOK     Report for hospital Sanction Utilization - CR 30012633
2271
2272     CLEAR l_timestamp.
2273     CONVERT DATE SY-DATUM TIME SY-UZEIT INTO
2274             TIME STAMP l_timestamp TIME ZONE 'UTC   '.
2275     wa_zhrhospsanction-TIMESTAMP = l_timestamp.
2276     wa_zhrhospsanction-AENAM = SY-UNAME.
2277
2278   * update logs
2279     MOVE-CORRESPONDING wa_zhrhospsanction to WA_ZFIHOSPSANCLOG.
2280     Insert into ZFIHOSPSANCLOG  values WA_ZFIHOSPSANCLOG.
2281
2282   * End RD1K996913       CAB_ALOK     Report for hospital Sanction Utilization - CR 30012633
2283
2284               Modify ZHRHOSPSANCTION from wa_zhrhospsanction .
2285               Commit work.
2286               Message i022(zhr).
2287               Clear ZHRHOSPSANCTION.
2288               CALL SCREEN 0050.
2289             Else.
2290   *          MOVE-CORRESPONDING ZHRHOSPSANCTION to wa_zhrhospsanction.
2291   *          Insert into ZHRHOSPSANCTION  values wa_zhrhospsanction.
2292   *          Commit work.
2293             Endif.
2294           Endif.
2295         Endif.
2296
2297       WHEN OTHERS.
2298         If ZHRHOSPSANCTION-BUKRS is not initial and
2299   **Begin RD1K996216   CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
2300            ZHRHOSPSANCTION-SECCO IS INITIAL or
2301   **End RD1K996216   CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
2302            ZHRHOSPSANCTION-GLHEAD is not initial and
2303            ZHRHOSPSANCTION-GJAHR is not initial AND
2304            ZHRHOSPSANCTION-FILENO is not initial.
2305           Select single amt from zhrhospsanction into ZHRHOSPSANCTION-AMT
2306             where BUKRS = ZHRHOSPSANCTION-BUKRS and GLHEAD = ZHRHOSPSANCTION-GLHEAD
2307              and GJAHR = ZHRHOSPSANCTION-GJAHR and FILENO = ZHRHOSPSANCTION-FILENO.
2308         Endif.
2309     Endcase.
2310
2311   endmodule.                 " USER_COMMAND_0051  INPUT
2312   *&---------------------------------------------------------------------*
2313   *&      Module  GET_FILENO  INPUT
2314   *&---------------------------------------------------------------------*
2315   *       text
2316   *----------------------------------------------------------------------*
2317   module GET_FILENO input.
2318     DATA : g_t_id TYPE vrm_id,
2319          g_t_list TYPE vrm_values,
2320          g_t_value  LIKE LINE OF g_t_list.
2321
2322   *  DATA: ist_return_tab TYPE STANDARD TABLE OF ddshretval WITH HEADER LINE.
2323
2324     REFRESH : g_t_list.
2325     CLEAR g_t_list.
2326
2327     Types : begin of ty_file ,
2328             fileno type char25 ,
2329             end of ty_file .
2330     data : ist_fileno type table of ty_file WITH HEADER LINE,
2331            wa_fileno type ty_file.
2332
2333     select fileno into CORRESPONDING FIELDS OF TABLE ist_fileno from zhrhospsanction
2334         where BUKRS = ZHRHOSPSANCTION-BUKRS and GLHEAD = ZHRHOSPSANCTION-GLHEAD
2335           and GJAHR = ZHRHOSPSANCTION-GJAHR.
2336   *           and GLHEAD = ZHRHOSPSANCTION-GLHEAD.
2337
2338     Loop at ist_fileno into wa_fileno.
2339       CLEAR g_t_value.
2340   *      g_t_value-key  = wa_state-BEZEI.
2341       g_t_value-key  = wa_fileno-fileno.
2342   *     g_t_value-text = wa_state-BEZEI.
2343       APPEND g_t_value TO g_t_list.
2344     Endloop.
2345
2346   *  g_t_id = 'ZHRHOSPSANCTION-FILENO'.
2347   *
2348   *    CALL FUNCTION 'VRM_SET_VALUES'
2349   *   EXPORTING
2350   *    id     = g_t_id
2351   *    values = g_t_list.
2352
2353
2354     CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
2355             EXPORTING
2356                  retfield    = 'FILENO'
2357                  dynpprog    = 'SAPMZPZ9920_MED_INPATIENT'
2358                  dynpnr      = '0051'
2359                  dynprofield = 'ZHRHOSPSANCTION-FILENO'
2360                  value_org   = 'S'
2361             TABLES
2362                  value_tab   = ist_fileno
2363                  return_tab  = ist_return_tab
2364   *Begin of <RD1K960036>
2365             EXCEPTIONS
2366                 PARAMETER_ERROR        = 1
2367                 NO_VALUES_FOUND        = 2
2368                 OTHERS                 = 3  .
2369
2370     IF sy-subrc <> 0.
2371       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
2372               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
2373     ENDIF.
2374
2375   endmodule.                 " GET_FILENO  INPUT
2376   *&---------------------------------------------------------------------*
2377   *&      Module  VALIDATE_BUKRS  INPUT
2378   *&---------------------------------------------------------------------*
2379   *       text
2380   *----------------------------------------------------------------------*
2381   module VALIDATE_BUKRS input.
2382
2383     If zhrhospsanction-bukrs is not initial.
2384       select single *  from BKPF where bukrs = zhrhospsanction-bukrs.
2385       If sy-subrc <> 0 .
2386         MESSAGE e020(zhr).
2387       Endif.
2388     Endif.
2389
2390
2391   endmodule.                 " VALIDATE_BUKRS  INPUT
2392   *&---------------------------------------------------------------------*
2393   *&      Module  VALIDATE_GLHEAD  INPUT
2394   *&---------------------------------------------------------------------*
2395   *       text
2396   *----------------------------------------------------------------------*
2397   module VALIDATE_GLHEAD input.
2398
2399     If zhrhospsanction-GLHEAD is not initial.
2400       select single *  from SKB1 where SAKNR = zhrhospsanction-GLHEAD.
2401       If sy-subrc <> 0 .
2402         MESSAGE e021(zhr).
2403       Endif.
2404     Endif.
2405
2406   endmodule.                 " VALIDATE_GLHEAD  INPUT
2407   *&---------------------------------------------------------------------*
2408   *&      Module  GET_GLHEAD  INPUT
2409   *&---------------------------------------------------------------------*
2410   *       text
2411   *----------------------------------------------------------------------*
2412   module GET_GLHEAD input.
2413
2414   *  DATA : g_t_id TYPE vrm_id,
2415   *       g_t_list TYPE vrm_values,
2416   *       g_t_value  LIKE LINE OF g_t_list.
2417   *
2418     REFRESH : g_t_list.
2419     CLEAR g_t_list.
2420
2421
2422     Types : begin of ty_glhead ,
2423             SAKNR type SAKNR ,
2424             end of ty_glhead .
2425
2426     data : ist_glhead type table of ty_glhead,
2427            wa_glhead type ty_glhead.
2428
2429   *select SAKNR into CORRESPONDING FIELDS OF TABLE ist_glhead from SKA1 .
2430   *    where BUKRS = ZHRHOSPSANCTION-BUKRS .
2431     Refresh : ist_glhead ,g_t_list .
2432
2433     wa_glhead-SAKNR = '0000200301'.
2434     append wa_glhead to ist_glhead.
2435     wa_glhead-SAKNR = '0000200302'.
2436     append wa_glhead to ist_glhead.
2437
2438   * Begin RD1K991981 CAB_ALOK Changes in ZHRHOSP Sanction Process CR : 30010772
2439     wa_glhead-SAKNR = '0000200309'.
2440     append wa_glhead to ist_glhead.
2441   * End RD1K991981 CAB_ALOK Changes in ZHRHOSP Sanction Process CR : 30010772
2442
2443   *Begin RD1K997486  CAB_ALOK  Medical Vendor pymt for Contingent workers -CR 30012858
2444     wa_glhead-SAKNR = '0000200350'.
2445     append wa_glhead to ist_glhead.
2446   *End RD1K997486   CAB_ALOK  Medical Vendor pymt for Contingent workers -CR 30012858
2447
2448
2449   * Begin RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
2450   *wa_glhead-SAKNR = '0000200308'.
2451   *append wa_glhead to ist_glhead.
2452   *wa_glhead-SAKNR = '0000200309'.
2453   *append wa_glhead to ist_glhead.
2454   *wa_glhead-SAKNR = '0000200307'.
2455   *append wa_glhead to ist_glhead.
2456   *wa_glhead-SAKNR = '0000200317'.
2457   *append wa_glhead to ist_glhead.
2458   *wa_glhead-SAKNR = '0000200318'.
2459   *append wa_glhead to ist_glhead.
2460   * End RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
2461
2462
2463     Loop at ist_glhead  into wa_glhead .
2464       CLEAR g_t_value.
2465   *      g_t_value-key  = wa_state-BEZEI.
2466       g_t_value-key  = wa_glhead-SAKNR.
2467   *     g_t_value-text = wa_state-BEZEI.
2468       APPEND g_t_value TO g_t_list.
2469     Endloop.
2470
2471     g_t_id = 'ZHRHOSPSANCTION-GLHEAD'.
2472
2473     CALL FUNCTION 'VRM_SET_VALUES'
2474       EXPORTING
2475         id     = g_t_id
2476         values = g_t_list.
2477
2478   endmodule.                 " GET_GLHEAD  INPUT
2479   *&---------------------------------------------------------------------*
2480   *&      Module  VALIDATE_0101  INPUT
2481   *&---------------------------------------------------------------------*
2482   *       text
2483   *----------------------------------------------------------------------*
2484   MODULE VALIDATE_0101 INPUT.
2485     data: l_persg1 type persg,
2486           l_kwert type ABRWT,
2487           l_fromdt type datum,
2488           l_tp9920 type pa9920.
2489     SELECT PERSG INTO L_PERSG1 FROM PA0001 UP TO 1 ROWS WHERE PERNR = P9920-PERNR
2490    AND ENDDA GE P9920-ZDATE_FROM AND BEGDA LE P9920-ZDATE_FROM
2491    ORDER BY PRIMARY KEY .
2492    ENDSELECT.
2493   * Begin of <RD1K994992> CAB_PAREEK 20.10.2014
2494   *  if l_persg1 = '9' or l_persg1 = 'T' or l_persg1 = 'C'.
2495   *    if g_facility ne '07'.
2496   *      message e000(zmsg) with 'Only PME claim allowed for term/tenure'
2497   *       '/contingent Employees'.
2498   *    endif.
2499   *  else.
2500   *    if g_facility = '07'.
2501   *      message e000(zmsg) with 'PME claim allowed for term/tenure/contingent'
2502   *          'Employees'.
2503   *    endif.
2504   *  endif.
2505
2506   *Begin RD1K997911 CAB_ALOK Med Vend pymt:incl of contngt & term emp -CR 30013034
2507
2508   *  if l_persg1 = '9' or l_persg1 = 'T'.
2509   *    if g_facility ne '07'.
2510   *      message e000(zmsg) with 'Only PME claim allowed for term/tenure'
2511   *       ' Employees'.
2512      if l_persg1 = 'T'.     "Tenure
2513        if g_facility = '03' or  g_facility = '04' or g_facility = '05' or g_facility = '06' .
2514         message e000(zmsg) with 'Only PME claim allowed for tenure'
2515          ' Employees'.
2516   *End RD1K997911 CAB_ALOK Med Vend pymt:incl of contngt & term emp - contngt -CR 30013034
2517
2518
2519       endif.
2520     elseif  l_persg1 = 'C'.
2521   *Begin RD1K997911 CAB_ALOK Med Vend pymt:incl of contngt & term emp -CR 30013034
2522   *    if g_facility = '05' or g_facility = '06' or g_facility = '07'.
2523       if g_facility = '04' or g_facility = '05' or g_facility = '06' or g_facility = '07'.
2524       "// allowed
2525       else.
2526          message e000(zmsg) with 'Only Doctor/Pharmacy/Diagnostic/PME claim allowed for '
2527          'contingent Employees'.
2528       endif.
2529   *End RD1K997911 CAB_ALOK Med Vend pymt:incl of contngt & term emp -CR 30013034
2530
2531     else.
2532       if g_facility = '07'.
2533         message e000(zmsg) with 'PME claim allowed for tenure/contingent'
2534             'Employees'.
2535       endif.
2536     endif.
2537   * End of <RD1K994992> CAB_PAREEK 20.10.2014
2538
2539     if g_facility = '07'.
2540
2541
2542       l_fromdt = P9920-ZDATE_FROM - 730.
2543
2544       select single * from pa9920 into l_tp9920
2545                                       where pernr = p9920-pernr and
2546                                             subty = '07' and
2547                                             endda gt l_fromdt.
2548       if sy-subrc = 0.
2549         message e000(zmsg) with 'PME already claimed in last two years'.
2550       endif.
2551
2552
2553
2554       SELECT KWERT INTO L_KWERT FROM T511K UP TO 1 ROWS
2555    WHERE MOLGA EQ '40' AND KONST EQ 'ZPME' AND ENDDA GE P9920-ZDATE_FROM AND BEGDA LE P9920-ZDATE_FROM
2556    ORDER BY PRIMARY KEY .
2557    ENDSELECT.
2558       if P9920-ZAMOUNT gt l_kwert.
2559         message e000(zmsg) with 'Maximum limit for PME is'
2560              l_kwert.
2561       endif.
2562     endif.
2563   ENDMODULE.                 " VALIDATE_0101  INPUT
2564   *&---------------------------------------------------------------------*
2565   *&      Module  LOV_SECCO  INPUT
2566   *&---------------------------------------------------------------------*
2567   *       text
2568   *----------------------------------------------------------------------*
2569   **Begin RD1K996216   CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
2570   *
2571   *MODULE LOV_SECCO INPUT.
2572   *
2573   *REFRESH : DYFIELDS_1.
2574   *  refresh: IST_SECCO1, IST_DYNPFLD_MAPPING, IST_FIELD, IST_RETURN_TAB .
2575   *  clear: IST_DYNPFLD_MAPPING, IST_FIELD, IST_RETURN_TAB .
2576   *  select SECCODE from SECCODE     "V_SECCODE
2577   *    into CORRESPONDING FIELDS OF TABLE IST_SECCO1
2578   *      where BUKRS =  ZHRHOSPSANCTION-BUKRS.
2579   *
2580   *  SORT IST_SECCO1 BY SECCODE ASCENDING.  "NAME
2581   *  DELETE ADJACENT DUPLICATES FROM IST_SECCO1 COMPARING SECCODE . "NAME
2582   **    IST_DYNPFLD_MAPPING-FLDNAME   = 'F0001'.
2583   **   IST_DYNPFLD_MAPPING-DYFLDNAME = 'ZPMED_SUBMIT-ZLOT_NO_LOW'.
2584   **
2585   **   APPEND IST_DYNPFLD_MAPPING.
2586   **   CLEAR : IST_DYNPFLD_MAPPING.
2587   *
2588   *
2589   **    IST_FIELD-TABNAME   = 'ZPMED_SUBMIT'.
2590   **   IST_FIELD-FIELDNAME = 'ZLOT_NO_LOW'.
2591   **   IST_FIELD-REPTEXT = 'LOT_NO'.
2592   **
2593   **  APPEND IST_FIELD.
2594   **  CLEAR IST_FIELD.
2595   *
2596   *
2597   *
2598   *  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
2599   *    EXPORTING
2600   *      RETFIELD        = 'SECCODE'
2601   *      DYNPPROG        = SY-CPROG
2602   *      DYNPNR          = SY-DYNNR
2603   *      DYNPROFIELD     = 'ZHRHOSPSANCTION-SECCO'
2604   *      VALUE_ORG       = 'S'
2605   *    TABLES
2606   *      VALUE_TAB       = IST_SECCO1
2607   *      FIELD_TAB       = IST_FIELD
2608   *      RETURN_TAB      = IST_RETURN_TAB
2609   *      DYNPFLD_MAPPING = IST_DYNPFLD_MAPPING
2610   *    EXCEPTIONS
2611   *      PARAMETER_ERROR = 1
2612   *      NO_VALUES_FOUND = 2
2613   *      OTHERS          = 3.
2614   *  IF SY-SUBRC <> 0.
2615   *    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
2616   *            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
2617   *  ENDIF.
2618   *
2619   *  ZHRHOSPSANCTION-SECCO = IST_RETURN_TAB-FIELDVAL.
2620   *
2621   **  clear tmp_lifnr.
2622   **  tmp_lifnr = P9920-ZHOSPID.
2623   **  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
2624   **    EXPORTING
2625   **      INPUT  = tmp_lifnr
2626   **    IMPORTING
2627   **      OUTPUT = tmp_lifnr.
2628   **
2629   **  P9920-ZHOSPID  = tmp_lifnr.
2630   *
2631   *
2632   *ENDMODULE.                 " LOV_SECCO  INPUT
2633   **End RD1K996216   CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
*--- End of MZPZ9920_MED_INPATIENT_I01 - 2633 lines ---

----------------------------------------------------------------------------------------------------
Include          MZPZ9920_MED_INPATIENT_F01                Level 1    Page 5
Object           SAPMZPZ9920_MED_INPATIENT                 Lines 7416
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:24
----------------------------------------------------------------------------------------------------
1      *----------------------------------------------------------------------*
2      ***INCLUDE MZPZ9920_MED_INPATIENT_F01 .
3      *----------------------------------------------------------------------*
4      *&---------------------------------------------------------------------*
5      *&      Form  GET_LIST_BOX
6      *&---------------------------------------------------------------------*
7      *       text
8      *----------------------------------------------------------------------*
9      *      -->P_0007   text
10     *----------------------------------------------------------------------*
11     Form get_list .
12     **    CALL FUNCTION 'HR_PSBUFFER_INITIALIZE'.
13     endform.
14     FORM GET_LIST_BOX  USING   p_id.
15
16       DATA: itab TYPE TABLE OF pa9919 WITH HEADER LINE.
17       DATA: fname LIKE pa0021-favor, lname LIKE pa0021-fanam.
18       Clear :g_city .
19       Clear :g_persa, g_value, g_list.
20       refresh g_list.
21
22
23       SELECT WERKS INTO G_PERSA
24      FROM PA0001 UP TO 1 ROWS WHERE PERNR = P9920-PERNR AND ENDDA = '99991231'
25      ORDER BY PRIMARY KEY .
26      ENDSELECT.
27
28       if sy-subrc = 0.
29         Select single CITYC
30                into g_city
31                from T500P
32                where PERSA = g_persa .
33       endif.
34       g_id = p_id.
35       refresh g_list[].
36       data: lv_cu_date like SY-DATUM,
37               lv_sx_date like sy-datum.
38
39       lv_cu_date = sy-datum.
40
41     * begin RD1K978193 CAB_ALOK CR 30006378
42     * Remove 6-month's validity condition
43     *  CALL FUNCTION 'CCM_GO_BACK_MONTHS'
44     *    EXPORTING
45     *      currdate   = lv_cu_date
46     *      backmonths = 6
47     *    IMPORTING
48     *      NEWDATE    = lv_sx_date.
49     * End RD1K978193 CAB_ALOK CR 30006378
50
51       SELECT * FROM pa9919 INTO TABLE itab WHERE pernr = p9920-pernr "g_pernr
52     * begin RD1K978193 CAB_ALOK CR 30006378
53     * get all cards which were valid at any point of time.(i.e. remove condition on dates)
54     *  AND  begda <= sy-datum AND endda >= lv_sx_date
55     * Employee and his dependents can be in different cities, remove condition on location
56     *  and  ZLOC_CR = g_city .
57        .
58     * end RD1K978193 CAB_ALOK   CR 30006378
59
60       if sy-subrc = 0.
61         move itab[] to lv_endda_ch[] .      " used for card number validation
62       endif.
63       Sort lv_endda_ch by zcrdno endda descending .
64       Clear lv_endda_ch .
65       if g_facility = '07'.
66       else.
67         IF itab[] IS INITIAL.
68           MESSAGE e111(zhr) WITH p9920-pernr.
69         ENDIF.
70       endif.
71       Sort itab by zcrdno endda descending .
72       Clear itab .
73       Delete ADJACENT DUPLICATES FROM  itab comparing zcrdno .
74       LOOP AT itab.
75         g_value-key = itab-zcrdno.
76
77     *** get relation
78         SELECT SINGLE stext FROM t591s INTO g_value-text WHERE sprsl =
79         'E' AND infty =  '0021' AND subty = itab-subty.
80         IF itab-subty <> '16'.
81     *  Get relation-name
82           SELECT FAVOR FANAM FROM PA0021 INTO ( FNAME , LNAME ) UP TO 1 ROWS
83      WHERE PERNR = P9920-PERNR AND SUBTY = ITAB-SUBTY AND OBJPS = ITAB-OBJPS
84      ORDER BY PRIMARY KEY .
85      ENDSELECT.
86     * end RD1K978193 CAB_ALOK CR 30006378
87
88           CONCATENATE g_value-text '-' fname lname INTO g_value-text
89           SEPARATED BY space.
90         elseif itab-subty = '16'.
91           SELECT ENAME
92      FROM PA0001 INTO (FNAME ) UP TO 1 ROWS WHERE PERNR = P9920-PERNR AND BEGDA <= SY-DATUM AND ENDDA >= SY-DATUM
93      ORDER BY PRIMARY KEY .
94      ENDSELECT.
95           CONCATENATE g_value-text '-' fname INTO g_value-text
96           SEPARATED BY space.
97
98         ENDIF.
99         APPEND g_value TO g_list.
100        CLEAR g_value.
101      ENDLOOP.
102      CALL FUNCTION 'VRM_SET_VALUES'
103        EXPORTING
104          id     = g_id
105          values = g_list.
106
107    ENDFORM.                    " GET_LIST_BOX
108    *&---------------------------------------------------------------------*
109    *&      Form  VALIDATE_0101
110    *&---------------------------------------------------------------------*
111    *       text
112    *----------------------------------------------------------------------*
113    *  -->  p1        text
114    *  <--  p2        text
115    *----------------------------------------------------------------------*
116    FORM VALIDATE_0101 .
117    * begin RD1K978193 CAB_ALOK CR 30006378
118    **** Check dates:
119    *  if p9920-subty = '03'.
120    ***  dates empty
121    *    if p9920-zdate_from is initial
122    *      or p9920-zdate_to is initial
123    *        or P9920-ZBILL_DATE is initial.
124    *      MESSAGE ID 'ZMSG' TYPE 'E' NUMBER '000'
125    *          WITH text-021.   " date is empty.
126    ***   error: start date  is greater than end date
127    *    elseif p9920-zdate_from > p9920-zdate_to.
128    *      MESSAGE ID 'ZMSG' TYPE 'E' NUMBER '000'
129    *          WITH text-008.
130    *** dates > current date
131    *    elseif  p9920-zdate_from > sy-datum
132    *      or p9920-zdate_to > sy-datum
133    *        or P9920-ZBILL_DATE > sy-datum .
134    *      MESSAGE ID 'ZMSG' TYPE 'E' NUMBER '000'
135    *         WITH text-022.
136    *    elseif P9920-ZBILL_DATE < p9920-zdate_to  .
137    *      MESSAGE ID 'ZMSG' TYPE 'E' NUMBER '000'
138    *         WITH text-023.
139    *    endif.
140    *
141    *  elseif p9920-subty = '04'
142    *           or p9920-subty = '05'
143    *             or p9920-subty = '06'.
144    ***  dates empty
145    *    if p9920-zdate_from is initial
146    *       or P9920-ZBILL_DATE is initial.
147    *      MESSAGE ID 'ZMSG' TYPE 'E' NUMBER '000'
148    *          WITH text-021.   " date is empty.
149    *** dates > current date
150    *    elseif  p9920-zdate_from > sy-datum
151    *        or P9920-ZBILL_DATE > sy-datum .
152    *      MESSAGE ID 'ZMSG' TYPE 'E' NUMBER '000'
153    *         WITH text-022.
154    *    elseif P9920-ZBILL_DATE < p9920-zdate_from  .
155    *      MESSAGE ID 'ZMSG' TYPE 'E' NUMBER '000'
156    *         WITH text-024.
157    *    endif.
158    *
159    *  endif.
160
161    **Check vendor
162    ** empty?
163    *  if p9920-zhospid is initial.
164    *    MESSAGE ID 'ZMSG' TYPE 'E' NUMBER '000'
165    *           WITH text-025.   "
166    *  endif.
167    ** Validate: (vendor code entered & company code of Dealing officer) pair should
168    **    exist in ZHR_MED_VENDORS
169    *  clear WA_ZHR_MED_VENDORS.
170    *  select single * from ZHR_MED_VENDORS into WA_ZHR_MED_VENDORS
171    **  where BUKRS = G_BUKRS " Now P9920-GRPVL
172    *      where BUKRS = P9920-GRPVL
173    *      and LIFNR = P9920-ZHOSPID.
174    *  if sy-subrc <> 0 .
175    *    MESSAGE ID 'ZMSG' TYPE 'E' NUMBER '000' WITH text-030.
176    *  endif.
177
178    ** Check illness, bill no.
179    *  if p9920-ZILLNESS is initial.
180    *    MESSAGE ID 'ZMSG' TYPE 'E' NUMBER '000'
181    *           WITH text-026.   "
182    *  endif.
183    *  if p9920-ZBILL_NO is initial.
184    *    MESSAGE ID 'ZMSG' TYPE 'E' NUMBER '000'
185    *           WITH text-027.   "
186    *  endif.
187    *
188    **Check claim amt.
189    *  IF P9920-ZAMOUNT is initial.
190    *    MESSAGE ID 'ZMSG' TYPE 'E' NUMBER '000'
191    *           WITH text-028.   "
192    *  ENDIF.
193
194    ** Check: if recovery > 0 then Remarks mandatory.
195    *  IF P9920-ZADV_TKN > 0 and P9920-ZREMARKS is initial.
196    *    MESSAGE ID 'ZMSG' TYPE 'E' NUMBER '000'
197    *           WITH text-029.   "
198    *  ENDIF.
199
200    **  Validate Card No.
201    *  perform validate_card_no.
202    * end RD1K978193 CAB_ALOK CR 30006378
203
204    * validations of p9920
205      DATA: VALIDATION_MSG type ZCHAR_MAX,                      "255 char
206            ERROR_FLAG type CHAR1.
207
208      clear: ERROR_FLAG , VALIDATION_MSG.
209      CALL FUNCTION 'ZHR_MED_PYMT9920_VALIDATE_FILL'
210        IMPORTING
211          VALIDATION_MSG = VALIDATION_MSG
212          ERROR_FLAG     = ERROR_FLAG
213        CHANGING
214          P9920          = P9920.
215
216      if ERROR_FLAG = '1'.  " validation failed
217
218        MESSAGE ID 'ZMSG' TYPE 'E' NUMBER '000'
219               WITH VALIDATION_MSG.
220
221
222      endif.
223
224
225    ****  if ZHR_MED_VENDORS-TAXABLE is INITIAL.
226    ****    g_claim_not_save = 'X'.
227    ****    message s000(zmsg)
228    ****    with 'Claim can not be saved - Hospital category for taxation '
229    ****         'not maintained - if there please press enter'.
230    ****  endif.
231
232    ENDFORM.                    " VALIDATE_0101
233    *&---------------------------------------------------------------------*
234    *&      Form  LOCK_AND_UPDATE_USER_0101
235    *&---------------------------------------------------------------------*
236    *       text
237    *----------------------------------------------------------------------*
238    *  -->  p1        text
239    *  <--  p2        text
240    *----------------------------------------------------------------------*
241    FORM LOCK_AND_UPDATE_USER_0101 .
242
243      CALL FUNCTION 'BAPI_EMPLOYEET_ENQUEUE'
244        EXPORTING
245          number        = p9920-pernr
246          validitybegin = sy-datum
247        IMPORTING
248          return        = l_return.
249      IF l_return-type NE space.
250        PERFORM read_enqueue_table_0101.
251      ELSE.
252
253
254    * Updating data in infotype 9920
255        PERFORM update_info_0101.
256
257      ENDIF.
258
259
260
261    ENDFORM.                    " LOCK_AND_UPDATE_USER_0101
262    *&---------------------------------------------------------------------*
263    *&      Form  READ_ENQUEUE_TABLE_0101
264    *&---------------------------------------------------------------------*
265    *       text
266    *----------------------------------------------------------------------*
267    *  -->  p1        text
268    *  <--  p2        text
269    *----------------------------------------------------------------------*
270    FORM READ_ENQUEUE_TABLE_0101 .
271      DATA: number LIKE sy-tabix,
272              arg    LIKE seqg3-garg,
273              enq    LIKE seqg3 OCCURS 0 WITH HEADER LINE.
274
275      CALL FUNCTION 'ENQUEUE_READ'
276        EXPORTING
277          gclient               = sy-mandt
278          gname                 = 'PREL'
279          garg                  = arg
280          guname                = space
281        IMPORTING
282          number                = number
283        TABLES
284          enq                   = enq
285        EXCEPTIONS
286          communication_failure = 1
287          system_failure        = 2
288          OTHERS                = 3.
289      IF sy-subrc EQ 0.
290        IF number > 0.
291          IF sy-ucomm = 'EXIT' or sy-ucomm = 'BACK' .
292            PERFORM unlock_user_0101.
293            EXIT.
294          ENDIF.
295          CLEAR enq.
296          READ TABLE enq WITH KEY gtarg+3(8) = p9920-pernr.
297    * Is the record locked by the ESS user or administrator?
298          IF enq-guname <> sy-uname.
299            MESSAGE s238(pwww) WITH p9920-pernr enq-guname.
300          ELSE.
301            MESSAGE s238(pwww) WITH p9920-pernr sy-uname.
302          ENDIF.
303          EXIT.
304        ENDIF.
305      ELSE.
306      ENDIF.
307    ENDFORM.                    " READ_ENQUEUE_TABLE_0101
308    *&---------------------------------------------------------------------*
309    *&      Form  UNLOCK_USER_0101
310    *&---------------------------------------------------------------------*
311    *       text
312    *----------------------------------------------------------------------*
313    *  -->  p1        text
314    *  <--  p2        text
315    *----------------------------------------------------------------------*
316    FORM UNLOCK_USER_0101 .
317      CALL FUNCTION 'BAPI_EMPLOYEET_DEQUEUE'
318        EXPORTING
319          number        = p9920-pernr
320          validitybegin = sy-datum
321        IMPORTING
322          return        = l_return.
323
324      IF NOT l_return IS INITIAL.
325        IF l_return-type NE 'S'.
326          l_return-type = 'S'.
327        ENDIF.
328        MESSAGE ID l_return-id TYPE l_return-type NUMBER l_return-number
329             WITH l_return-message_v1 l_return-message_v2
330                  l_return-message_v3 l_return-message_v4.
331        EXIT.
332      ENDIF.
333    ENDFORM.                    " UNLOCK_USER_0101
334    *&---------------------------------------------------------------------*
335    *&      Form  UPDATE_INFO_0101
336    *&---------------------------------------------------------------------*
337    *       text
338    *----------------------------------------------------------------------*
339    *  -->  p1        text
340    *  <--  p2        text
341    *----------------------------------------------------------------------*
342    FORM UPDATE_INFO_0101 .
343      DATA : ist_email LIKE zhr_mailid OCCURS 0.
344      DATA : ist_ret LIKE bapireturn1 OCCURS 0.
345      DATA : l_person TYPE ad_smtpadr.
346      DATA : l_date(10) TYPE c.
347      DATA : l_subjc TYPE witext,
348             l_text1 TYPE ad_smtpadr,
349             l_text2 TYPE ad_smtpadr,
350             l_text3 TYPE ad_smtpadr,
351             l_text4 TYPE ad_smtpadr,
352             l_text5 TYPE ad_smtpadr,
353             l_text6 TYPE ad_smtpadr.
354
355
356
357    * p9920-subty already calculated with G_FACILITY
358      p9920-infty = '9920'.
359
360
361
362
363
364      CALL FUNCTION 'HR_INFOTYPE_OPERATION'
365        EXPORTING
366          infty            = '9920'
367          number           = p9920-pernr
368          subtype          = p9920-subty
369    *     OBJECTID         =
370          lockindicator    = 'X'
371          validityend      = '99991231' "sy-datum
372          validitybegin    = p9920-BEGDA       "sy-datum
373    *     RECORDNUMBER     =
374          record           = p9920
375          operation        = 'INS'  "INS/MOD
376          tclas            = 'A'
377    *     dialog_mode      = '0'
378          nocommit         = 'X'
379    *     VIEW_IDENTIFIER  =
380    *     SECONDARY_RECORD =
381        IMPORTING
382          return           = l_return
383          key              = bapipakey_tab.
384
385      IF NOT l_return IS INITIAL.
386        ROLLBACK WORK.
387
388        IF l_return-type NE 'S'.
389          l_return-type = 'S'.
390        ENDIF.
391        MESSAGE ID 'ZMSG' TYPE 'S' NUMBER '000'
392          WITH l_return-message.
393
394        EXIT.
395      ELSE.
396        COMMIT WORK.
397        g_greyoff = 'X'.  " Record has been saved
398
399
400    *****Send Mail.
401    ****
402    ****        CONCATENATE wa_claims-reimt
403    ****                  ename
404    ****                  '('
405    ****                  g_pernr
406    ****                  ')'
407    ****             INTO l_subjc
408    ****        SEPARATED BY space.
409    ****
410    ****      CONCATENATE wa_claims-reimt
411    ****                  g_pernr
412    ****                  '-'
413    ****                  ename
414    ****                  'has been created.'
415    ****              INTO l_text1
416    ****         SEPARATED BY space.
417    ****
418    ****      l_text2 = 'Please execute the mail to unlock the same'.
419    ****
420    ****
421    ****CALL FUNCTION 'ZHR_SEND_MAIL_TO_ADMIN'
422    ****             EXPORTING
423    ****                  pernr            = '99999999'
424    ****                  persadmin        = space
425    ****                  time             = ' '
426    ****                  payradmin        = space
427    ****                  internet_address = space
428    ****                  sap_inbox        = 'X'
429    ****                  mail_subject     = l_subjc
430    ****                  content1         = l_text1
431    ****                  content2         = l_text2
432    *****                  content3         = l_text3
433    *****                  content4         = l_text4
434    ****                  email            = space
435    ****                  sap_uname        = mail_id
436    ****                  to               = 'X'
437    ****                  cc               = ' '
438    ****                  bcc              = ' '
439    ****                  infty            = '9920'
440    ****                  per              = g_pernr
441    ****                  EXECMAIL         = 'X'
442    ****             TABLES
443    ****                  return           = ist_ret
444    *****               mailid           = lt_mailid
445    ****             EXCEPTIONS
446    ****                  admin_not_found  = 1
447    ****                  usrid_not_found  = 2
448    ****                  usrid_not_assign = 3
449    ****                  mailid_not_found = 4
450    ****                  send_api         = 5
451    ****                  OTHERS           = 6.
452    ****
453    ****    IF sy-subrc <> 0.
454    ****    ENDIF.
455    ****
456    ****
457    *****End send mail
458
459        MESSAGE ID 'ZMSG' TYPE 'S' NUMBER '000'
460          WITH 'Claim created with submission number ' P9920-cnter .
461    *          CLEAR p9920.
462    ****      CLEAR flg_first_9000.
463      ENDIF.
464    ****  ENDIF.
465    ENDFORM.                    " UPDATE_INFO_0101
466
467    *&---------------------------------------------------------------------*
468    *&      Form  GET_COUNTER_0101
469    *&---------------------------------------------------------------------*
470    *       text
471    *----------------------------------------------------------------------*
472    *  -->  p1        text
473    *  <--  p2        text
474    *----------------------------------------------------------------------*
475    FORM GET_COUNTER_0101 .
476      CLEAR p9920-cnter.
477      CALL FUNCTION 'NUMBER_GET_NEXT'
478        EXPORTING
479          nr_range_nr             = '01'
480          object                  = 'ZHR_MED'
481        IMPORTING
482          number                  = p9920-cnter
483        EXCEPTIONS
484          interval_not_found      = 1
485          number_range_not_intern = 2
486          object_not_found        = 3
487          quantity_is_0           = 4
488          quantity_is_not_1       = 5
489          interval_overflow       = 6
490          buffer_overflow         = 7
491          OTHERS                  = 8.
492
493      IF sy-subrc NE 0.
494        CLEAR save_ok.
495        MESSAGE ID 'ZMSG' TYPE 'E' NUMBER '000'
496              WITH 'Can not process, Error in counter generation'.
497      ENDIF.
498    ENDFORM.                    " GET_COUNTER_0101
499    *&---------------------------------------------------------------------*
500    *&      Form  CALCULATE_VALUES
501    *&---------------------------------------------------------------------*
502    *       text
503    *----------------------------------------------------------------------*
504    *  -->  p1        text
505    *  <--  p2        text
506    *----------------------------------------------------------------------*
507    FORM CALCULATE_VALUES .
508
509      p9920-subty = G_FACILITY.
510
511    *   get next free claim number.
512      PERFORM get_counter_0101.
513    *  p9920-cnter = '9999999999'.
514
515      p9920-zstatus = 'NEW'.
516
517
518
519    ENDFORM.                    " CALCULATE_VALUES
520    *&---------------------------------------------------------------------*
521    *&      Form  VALIDATE_CARD_NO
522    *&---------------------------------------------------------------------*
523    *       text
524    *----------------------------------------------------------------------*
525    *  -->  p1        text
526    *  <--  p2        text
527    *----------------------------------------------------------------------*
528    FORM VALIDATE_CARD_NO .
529    * Validate CARD NO.
530      data: lv_cu_date like SY-DATUM,
531              lv_sx_date like sy-datum.
532      refresh lv_endda_ch.
533      clear lv_endda_ch.
534      lv_cu_date = sy-datum.
535      CALL FUNCTION 'CCM_GO_BACK_MONTHS'
536        EXPORTING
537          currdate   = lv_cu_date
538          backmonths = 6
539        IMPORTING
540          NEWDATE    = lv_sx_date.
541
542      SELECT * FROM pa9919
543        INTO TABLE lv_endda_ch
544        WHERE pernr = p9920-pernr
545            AND  begda <= sy-datum
546            AND endda >= lv_sx_date.
547
548      Sort lv_endda_ch by zcrdno endda descending .
549      Clear lv_endda_ch .
550      if g_facility = '07'.
551      else.
552        IF lv_endda_ch[] IS INITIAL.
553          MESSAGE e111(zhr) WITH p9920-pernr.
554        ENDIF.
555      endif.
556
557      Sort lv_endda_ch by zcrdno endda descending .
558      Clear lv_endda_ch .
559      Delete ADJACENT DUPLICATES FROM lv_endda_ch comparing zcrdno .
560
561      read table lv_endda_ch  with key  zcrdno = p9920-zcrdno .
562      if sy-subrc = 0.
563        if P9920-ZDATE_FROM GT lv_endda_ch-endda.
564
565          MESSAGE ID 'ZMSG' TYPE 'E' NUMBER '000'
566             WITH 'Treatment start Date cannot be greater'
567                   'than Medical Card End Date'.
568        endif.
569      endif.
570
571      if lv_endda_ch-endda LT sy-datum.
572        MESSAGE ID 'ZMSG' TYPE 'W' NUMBER '000'
573           WITH 'Medical Card Expiered' lv_endda_ch-endda.
574
575      endif.
576    ENDFORM.                    " VALIDATE_CARD_NO
577    *&---------------------------------------------------------------------*
578    *&      Form  RESET_LIST_BOX
579    *&---------------------------------------------------------------------*
580    *       text
581    *----------------------------------------------------------------------*
582    *      -->P_0030   text
583    *----------------------------------------------------------------------*
584    FORM RESET_LIST_BOX  USING  P_ID .
585      DATA: x_list TYPE vrm_values,
586            X_value  LIKE LINE OF x_list.
587      G_ID = P_ID.
588
589      Refresh X_LIST.
590
591      CALL FUNCTION 'VRM_SET_VALUES'
592        EXPORTING
593          id     = g_id
594          values = x_list.
595
596    *CALL FUNCTION 'VRM_REFRESH_VALUES' .
597
598    *CALL FUNCTION 'VRM_DELETE_VALUES'
599    *  EXPORTING
600    *    ID                         = G_ID
601    **   ID_CONTAINS_PROGNAME       =
602    * EXCEPTIONS
603    *   ID_NOT_FOUND               = 1
604    *   OTHERS                     = 2   .
605    *IF SY-SUBRC <> 0.
606    * MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
607    *         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
608    *ENDIF.
609    ENDFORM.                    " RESET_LIST_BOX
610
611    *&---------------------------------------------------------------------*
612    *&      Form  GET_DATA_0401
613    *&---------------------------------------------------------------------*
614    *       text
615    *----------------------------------------------------------------------*
616    *  -->  p1        text
617    *  <--  p2        text
618    *----------------------------------------------------------------------*
619    FORM GET_DATA_0401 .
620
621      DATA: submit_pernr TYPE pernr_d.
622      DATA: submit_name TYPE emnam.
623      DATA: submit_orgeh TYPE orgeh.
624      DATA: submit_plans TYPE plans.
625      DATA: submit_persa TYPE persa.
626      DATA: submit_bukrs TYPE bukrs.
627    *data: IST_9920_SUBMIT type table of PA9920.
628
629
630
631    *  PERFORM GETDATA_USER
632    *       changing submit_pernr submit_name submit_orgeh
633    *          submit_plans submit_persa submit_bukrs.
634
635      PERFORM GETDATA_IST_9920_SUBMIT tables IST_9920_SUBMIT using G_USER_BUKRS. "submit_bukrs .
636
637
638    ENDFORM.                    " GET_DATA_0401
639    *&---------------------------------------------------------------------*
640    *&      Form  GETDATA_USER
641    *&---------------------------------------------------------------------*
642    *       text
643    *----------------------------------------------------------------------*
644    *  -->  p1        text
645    *  <--  p2        text
646    *----------------------------------------------------------------------*
647    FORM GETDATA_USER changing submit_pernr submit_name submit_orgeh
648            submit_plans submit_persa submit_bukrs..
649    ** find comapny code of current user.
650
651      CALL FUNCTION 'HR_GETEMPLOYEEDATA_FROMUSER'
652        EXPORTING
653          username                  = sy-uname
654          validbegin                = sy-datum
655    *     check_auth                =  space
656        IMPORTING
657          employeenumber            = submit_pernr
658          name                      = submit_name
659          orgunit                   = submit_orgeh
660          position                  = submit_plans
661          personnelarea             = submit_persa
662          COMPANYCODE               = submit_bukrs
663        EXCEPTIONS
664          user_not_found            = 1
665          countrygrouping_not_found = 2
666          infty_not_found           = 3
667          OTHERS                    = 4.
668      IF sy-subrc <> 0.
669    * MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
670    *         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
671      ENDIF.
672
673    *###############################################
674    *** remove after modifying PA30- 0105 (communication) for CHR_SAHA and enable the above MSG
675    *  if sy-uname = 'CHR_SAHA'.
676    *    SUBMIT_PERNR =   '00052970'.
677    *    SUBMIT_BUKRS =   'DLI'.
678    *  endif.
679    *###############################################
680
681    ENDFORM.                    " GETDATA_USER
682
683    *&---------------------------------------------------------------------*
684    *&      Form  GETDATA_IST_9920_SUBMIT
685    *&---------------------------------------------------------------------*
686    *       text
687    *----------------------------------------------------------------------*
688    *  -->  p1        text
689    *  <--  p2        text
690    *----------------------------------------------------------------------*
691
692    * Begin RD1K981765 CR: 30007609 CAB_ALOK
693    *FORM  GETDATA_IST_9920_SUBMIT  tables IST_9920_SUBMIT using submit_bukrs.
694    FORM GETDATA_IST_9920_SUBMIT  tables IST_9920_SUBMIT STRUCTURE IST_9920_SUBMIT using submit_bukrs.
695    * End RD1K981765 CR: 30007609 CAB_ALOK
696      DATA: wa_9920_SUBMIT1 TYPE ty_submit,
697                  l_tabix  TYPE sy-tabix.
698
699      data: R_UNAME TYPE RANGE OF PA9920-UNAME WITH HEADER LINE,
700            R_BEGDA TYPE RANGE OF PA9920-BEGDA WITH HEADER LINE,
701            R_ZHOSPID TYPE RANGE OF PA9920-ZHOSPID WITH HEADER LINE .
702
703
704    *** data:  DATE_LOW type sy-datum,
705    ***        DATE_HIGH type sy-datum.
706
707
708    *get rows from PA9920 based on selection screen input (struct: ZPMED_SUBMIT)
709    * and company code of record = comapny code of current user.
710    * and Status of record = 'NEW'
711    *Struct.     ZPMED_SUBMIT
712    *    BEGDA_LOW          20100831
713    *    BEGDA_HIGH         20100929
714    *    UNAME_LOW          ABC
715    *    UNAME_HIGH         X
716    *    ZHOSPID_LOW        111
717    *    ZHOSPID_HIGH       222
718
719    *** convert dates
720    **            CALL FUNCTION 'ZHR_MED_PYMT_TO_DDMMYYYY'
721    **              EXPORTING
722    **                YYYYMMDD       = ZPMED_SUBMIT-BEGDA_LOW
723    **             IMPORTING
724    **                DDMMYYYY       = DATE_LOW.
725    **
726    **            CALL FUNCTION 'ZHR_MED_PYMT_TO_DDMMYYYY'
727    **              EXPORTING
728    **                YYYYMMDD       = ZPMED_SUBMIT-BEGDA_HIGH
729    **             IMPORTING
730    **                DDMMYYYY       = DATE_HIGH.
731
732    *Put data in range so that 'IN' keyword can be used in SELECT stmt.
733      clear: R_UNAME, R_BEGDA, R_ZHOSPID.
734      refresh: R_UNAME, R_BEGDA, R_ZHOSPID.
735
736      R_UNAME-SIGN = 'I'.
737      R_UNAME-LOW = ZPMED_SUBMIT-UNAME_LOW.
738      R_UNAME-HIGH = ZPMED_SUBMIT-UNAME_HIGH.
739      if R_UNAME-LOW is NOT INITIAL and  R_UNAME-HIGH is NOT INITIAL.
740        R_UNAME-OPTION = 'BT'.
741      else.
742        R_UNAME-OPTION = 'EQ'.
743      endif.
744      append R_UNAME.
745      if R_UNAME-LOW is INITIAL and  R_UNAME-HIGH is INITIAL.
746        clear: R_UNAME.
747        refresh:  R_UNAME.
748      endif.
749
750      R_BEGDA-SIGN = 'I'.
751      R_BEGDA-LOW = ZPMED_SUBMIT-BEGDA_LOW.
752      R_BEGDA-HIGH = ZPMED_SUBMIT-BEGDA_HIGH.
753      if R_BEGDA-LOW is NOT INITIAL and  R_BEGDA-HIGH is NOT INITIAL.
754        R_BEGDA-OPTION = 'BT'.
755      else.
756        R_BEGDA-OPTION = 'EQ'.
757      endif.
758      append R_BEGDA.
759      if R_BEGDA-LOW is INITIAL and  R_BEGDA-HIGH is INITIAL.
760        clear: R_BEGDA.
761        refresh:  R_BEGDA.
762      endif.
763
764
765
766
767      CALL FUNCTION 'ZHR_MED_PYMT_VENDOR_ADD_ZERO'
768        CHANGING
769          VENDOR = ZPMED_SUBMIT-ZHOSPID_LOW.
770
771      CALL FUNCTION 'ZHR_MED_PYMT_VENDOR_ADD_ZERO'
772        CHANGING
773          VENDOR = ZPMED_SUBMIT-ZHOSPID_HIGH.
774
775      R_ZHOSPID-SIGN = 'I'.
776      R_ZHOSPID-LOW = ZPMED_SUBMIT-ZHOSPID_LOW.
777      R_ZHOSPID-HIGH = ZPMED_SUBMIT-ZHOSPID_HIGH.
778      if  R_ZHOSPID-LOW is NOT INITIAL and R_ZHOSPID-HIGH is NOT INITIAL.
779        R_ZHOSPID-OPTION = 'BT'.
780      else.
781        R_ZHOSPID-OPTION = 'EQ'.
782      endif.
783      append R_ZHOSPID.
784      if R_ZHOSPID-LOW is INITIAL and  R_ZHOSPID-HIGH  is INITIAL.
785        clear: R_ZHOSPID.
786        refresh:  R_ZHOSPID.
787      endif.
788
789
790    *if ZPMED_SUBMIT-UNAME_HIGH is INITIAL.
791    *  ZPMED_SUBMIT-UNAME_HIGH = ZPMED_SUBMIT-UNAME_LOW.
792    *endif.
793    *if ZPMED_SUBMIT-BEGDA_HIGH is INITIAL.
794    *  ZPMED_SUBMIT-BEGDA_HIGH = ZPMED_SUBMIT-BEGDA_LOW.
795    *endif.
796    *if ZPMED_SUBMIT-ZHOSPID_HIGH is INITIAL.
797    *  ZPMED_SUBMIT-ZHOSPID_HIGH = ZPMED_SUBMIT-ZHOSPID_LOW.
798    *endif.
799
800    *select * from PA9920
801    *  into corresponding fields of table IST_9920_SUBMIT
802    *    where uname between ZPMED_SUBMIT-UNAME_LOW  AND ZPMED_SUBMIT-UNAME_HIGH
803    *      and BEGDA BETWEEN ZPMED_SUBMIT-BEGDA_LOW AND ZPMED_SUBMIT-BEGDA_HIGH " as YYYYMMDD
804    *      and ZHOSPID BETWEEN ZPMED_SUBMIT-ZHOSPID_LOW AND ZPMED_SUBMIT-ZHOSPID_HIGH  " as 0000800001
805    *      and GRPVL = submit_bukrs
806    *      and ZSTATUS = 'NEW'.
807
808      select * from PA9920
809        into corresponding fields of table IST_9920_SUBMIT
810          where uname IN R_UNAME
811            and BEGDA IN R_BEGDA " as YYYYMMDD
812            and ZHOSPID IN R_ZHOSPID  " as 0000800001
813            and GRPVL = submit_bukrs
814            and ZSTATUS = 'NEW'
815            and ( SUBTY = '03' or SUBTY = '04' or SUBTY = '05' or SUBTY = '06' or
816                  SUBTY = '07' ) .
817
818    * Begin RD1K981765 CR: 30007609 CAB_ALOK
819      Sort IST_9920_SUBMIT by CNTER ASCENDING.
820    * End RD1K981765 CR: 30007609 CAB_ALOK
821
822    ** Fill INFTY, serial no.
823
824      loop at IST_9920_SUBMIT into wa_9920_SUBMIT1.
825        l_tabix = sy-tabix.
826        wa_9920_SUBMIT1-INFTY = '9920'.
827        wa_9920_SUBMIT1-serial_no = l_tabix.
828        MODIFY IST_9920_SUBMIT  FROM  WA_9920_SUBMIT1 INDEX l_tabix.
829      endloop.
830
831
832
833
834
835
836
837
838
839
840    ENDFORM.                    " GETDATA_IST_9920_SUBMIT
841
842    *----------------------------------------------------------------------*
843    *   INCLUDE TABLECONTROL_FORMS                                         *
844    *----------------------------------------------------------------------*
845
846    *&---------------------------------------------------------------------*
847    *&      Form  USER_OK_TC_SUBMIT                                               *
848    *&---------------------------------------------------------------------*
849    FORM USER_OK_TC_SUBMIT USING    P_TC_NAME TYPE DYNFNAM
850                             P_TABLE_NAME
851                             P_MARK_NAME
852                    CHANGING P_OK      LIKE SY-UCOMM.
853
854    *&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
855      DATA: L_OK              TYPE SY-UCOMM,
856            L_OFFSET          TYPE I.
857    *&SPWIZARD: END OF LOCAL DATA------------------------------------------*
858
859    *&SPWIZARD: Table control specific operations                          *
860    *&SPWIZARD: evaluate TC name and operations                            *
861      SEARCH P_OK FOR P_TC_NAME.
862      IF SY-SUBRC <> 0.
863        EXIT.
864      ENDIF.
865      L_OFFSET = STRLEN( P_TC_NAME ) + 1.
866      L_OK = P_OK+L_OFFSET.
867    *&SPWIZARD: execute general and TC specific operations                 *
868      CASE L_OK.
869    *     WHEN 'INSR'.                      "insert row
870    *       PERFORM FCODE_INSERT_ROW USING    P_TC_NAME
871    *                                         P_TABLE_NAME.
872    *       CLEAR P_OK.
873    *
874    *     WHEN 'DELE'.                      "delete row
875    *       PERFORM FCODE_DELETE_ROW USING    P_TC_NAME
876    *                                         P_TABLE_NAME
877    *                                         P_MARK_NAME.
878    *       CLEAR P_OK.
879
880        WHEN 'P--' OR                     "top of list
881             'P-'  OR                     "previous page
882             'P+'  OR                     "next page
883             'P++'.                       "bottom of list
884          PERFORM COMPUTE_SCROLLING_IN_TC USING P_TC_NAME
885                                                L_OK.
886          CLEAR P_OK.
887    *     WHEN 'L--'.                       "total left
888    *       PERFORM FCODE_TOTAL_LEFT USING P_TC_NAME.
889    *
890    *     WHEN 'L-'.                        "column left
891    *       PERFORM FCODE_COLUMN_LEFT USING P_TC_NAME.
892    *
893    *     WHEN 'R+'.                        "column right
894    *       PERFORM FCODE_COLUMN_RIGHT USING P_TC_NAME.
895    *
896    *     WHEN 'R++'.                       "total right
897    *       PERFORM FCODE_TOTAL_RIGHT USING P_TC_NAME.
898    *
899        WHEN 'MARK'.                      "mark all filled lines
900          PERFORM FCODE_TC_MARK_LINES USING P_TC_NAME
901                                            P_TABLE_NAME
902                                            P_MARK_NAME   .
903          CLEAR P_OK.
904
905        WHEN 'DMRK'.                      "demark all filled lines
906          PERFORM FCODE_TC_DEMARK_LINES USING P_TC_NAME
907                                              P_TABLE_NAME
908                                              P_MARK_NAME .
909          CLEAR P_OK.
910
911        WHEN 'SBMT'.                      "demark all filled lines
912
913    *       PERFORM                USING P_TC_NAME
914    *                                           P_TABLE_NAME
915    *                                           P_MARK_NAME .
916
917          PERFORM SUBMIT_0405. " Global IST_9920_SUBMIT
918
919
920          CLEAR P_OK.
921
922    *     WHEN 'SASCEND'   OR
923    *          'SDESCEND'.                  "sort column
924    *       PERFORM FCODE_SORT_TC USING P_TC_NAME
925    *                                   l_ok.
926
927      ENDCASE.
928
929    ENDFORM.                              " USER_OK_TC_SUBMIT
930
931    *&---------------------------------------------------------------------*
932    *&      Form  FCODE_INSERT_ROW                                         *
933    *&---------------------------------------------------------------------*
934    FORM fcode_insert_row
935                  USING    P_TC_NAME           TYPE DYNFNAM
936                           P_TABLE_NAME             .
937
938    *&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
939      DATA L_LINES_NAME       LIKE FELD-NAME.
940      DATA L_SELLINE          LIKE SY-STEPL.
941      DATA L_LASTLINE         TYPE I.
942      DATA L_LINE             TYPE I.
943      DATA L_TABLE_NAME       LIKE FELD-NAME.
944      FIELD-SYMBOLS <TC>                 TYPE CXTAB_CONTROL.
945      FIELD-SYMBOLS <TABLE>              TYPE STANDARD TABLE.
946      FIELD-SYMBOLS <LINES>              TYPE I.
947    *&SPWIZARD: END OF LOCAL DATA------------------------------------------*
948
949      ASSIGN (P_TC_NAME) TO <TC>.
950
951    *&SPWIZARD: get the table, which belongs to the tc                     *
952      CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
953      ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline
954
955    *&SPWIZARD: get looplines of TableControl                              *
956      CONCATENATE 'G_' P_TC_NAME '_LINES' INTO L_LINES_NAME.
957      ASSIGN (L_LINES_NAME) TO <LINES>.
958
959    *&SPWIZARD: get current line                                           *
960      GET CURSOR LINE L_SELLINE.
961      IF SY-SUBRC <> 0.                   " append line to table
962        L_SELLINE = <TC>-LINES + 1.
963    *&SPWIZARD: set top line                                               *
964        IF L_SELLINE > <LINES>.
965          <TC>-TOP_LINE = L_SELLINE - <LINES> + 1 .
966        ELSE.
967          <TC>-TOP_LINE = 1.
968        ENDIF.
969      ELSE.                               " insert line into table
970        L_SELLINE = <TC>-TOP_LINE + L_SELLINE - 1.
971        L_LASTLINE = <TC>-TOP_LINE + <LINES> - 1.
972      ENDIF.
973    *&SPWIZARD: set new cursor line                                        *
974      L_LINE = L_SELLINE - <TC>-TOP_LINE + 1.
975
976    *&SPWIZARD: insert initial line                                        *
977      INSERT INITIAL LINE INTO <TABLE> INDEX L_SELLINE.
978      <TC>-LINES = <TC>-LINES + 1.
979    *&SPWIZARD: set cursor                                                 *
980      SET CURSOR LINE L_LINE.
981
982    ENDFORM.                              " FCODE_INSERT_ROW
983
984    *&---------------------------------------------------------------------*
985    *&      Form  FCODE_DELETE_ROW                                         *
986    *&---------------------------------------------------------------------*
987    FORM fcode_delete_row
988                  USING    P_TC_NAME           TYPE DYNFNAM
989                           P_TABLE_NAME
990                           P_MARK_NAME   .
991
992    *&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
993      DATA L_TABLE_NAME       LIKE FELD-NAME.
994
995      FIELD-SYMBOLS <TC>         TYPE cxtab_control.
996      FIELD-SYMBOLS <TABLE>      TYPE STANDARD TABLE.
997      FIELD-SYMBOLS <WA>.
998      FIELD-SYMBOLS <MARK_FIELD>.
999    *&SPWIZARD: END OF LOCAL DATA------------------------------------------*
1000
1001     ASSIGN (P_TC_NAME) TO <TC>.
1002
1003   *&SPWIZARD: get the table, which belongs to the tc                     *
1004     CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
1005     ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline
1006
1007   *&SPWIZARD: delete marked lines                                        *
1008     DESCRIBE TABLE <TABLE> LINES <TC>-LINES.
1009
1010     LOOP AT <TABLE> ASSIGNING <WA>.
1011
1012   *&SPWIZARD: access to the component 'FLAG' of the table header         *
1013       ASSIGN COMPONENT P_MARK_NAME OF STRUCTURE <WA> TO <MARK_FIELD>.
1014
1015       IF <MARK_FIELD> = 'X'.
1016         DELETE <TABLE> INDEX SYST-TABIX.
1017         IF SY-SUBRC = 0.
1018           <TC>-LINES = <TC>-LINES - 1.
1019         ENDIF.
1020       ENDIF.
1021     ENDLOOP.
1022
1023   ENDFORM.                              " FCODE_DELETE_ROW
1024
1025   *&---------------------------------------------------------------------*
1026   *&      Form  COMPUTE_SCROLLING_IN_TC
1027   *&---------------------------------------------------------------------*
1028   *       text
1029   *----------------------------------------------------------------------*
1030   *      -->P_TC_NAME  name of tablecontrol
1031   *      -->P_OK       ok code
1032   *----------------------------------------------------------------------*
1033   FORM COMPUTE_SCROLLING_IN_TC USING    P_TC_NAME
1034                                         P_OK.
1035   *&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
1036     DATA L_TC_NEW_TOP_LINE     TYPE I.
1037     DATA L_TC_NAME             LIKE FELD-NAME.
1038     DATA L_TC_LINES_NAME       LIKE FELD-NAME.
1039     DATA L_TC_FIELD_NAME       LIKE FELD-NAME.
1040
1041     FIELD-SYMBOLS <TC>         TYPE cxtab_control.
1042     FIELD-SYMBOLS <LINES>      TYPE I.
1043   *&SPWIZARD: END OF LOCAL DATA------------------------------------------*
1044
1045     ASSIGN (P_TC_NAME) TO <TC>.
1046   *&SPWIZARD: get looplines of TableControl                              *
1047     CONCATENATE 'G_' P_TC_NAME '_LINES' INTO L_TC_LINES_NAME.
1048     ASSIGN (L_TC_LINES_NAME) TO <LINES>.
1049
1050
1051   *&SPWIZARD: is no line filled?                                         *
1052     IF <TC>-LINES = 0.
1053   *&SPWIZARD: yes, ...                                                   *
1054       L_TC_NEW_TOP_LINE = 1.
1055     ELSE.
1056   *&SPWIZARD: no, ...                                                    *
1057       CALL FUNCTION 'SCROLLING_IN_TABLE'
1058         EXPORTING
1059           ENTRY_ACT             = <TC>-TOP_LINE
1060           ENTRY_FROM            = 1
1061           ENTRY_TO              = <TC>-LINES
1062           LAST_PAGE_FULL        = 'X'
1063           LOOPS                 = <LINES>
1064           OK_CODE               = P_OK
1065           OVERLAPPING           = 'X'
1066         IMPORTING
1067           ENTRY_NEW             = L_TC_NEW_TOP_LINE
1068         EXCEPTIONS
1069   *       NO_ENTRY_OR_PAGE_ACT  = 01
1070   *       NO_ENTRY_TO           = 02
1071   *       NO_OK_CODE_OR_PAGE_GO = 03
1072           OTHERS                = 0.
1073     ENDIF.
1074
1075   *&SPWIZARD: get actual tc and column                                   *
1076     GET CURSOR FIELD L_TC_FIELD_NAME
1077                AREA  L_TC_NAME.
1078
1079     IF SYST-SUBRC = 0.
1080       IF L_TC_NAME = P_TC_NAME.
1081   *&SPWIZARD: et actual column                                           *
1082         SET CURSOR FIELD L_TC_FIELD_NAME LINE 1.
1083       ENDIF.
1084     ENDIF.
1085
1086   *&SPWIZARD: set the new top line                                       *
1087     <TC>-TOP_LINE = L_TC_NEW_TOP_LINE.
1088
1089
1090   ENDFORM.                              " COMPUTE_SCROLLING_IN_TC
1091
1092   *&---------------------------------------------------------------------*
1093   *&      Form  FCODE_TC_MARK_LINES
1094   *&---------------------------------------------------------------------*
1095   *       marks all TableControl lines
1096   *----------------------------------------------------------------------*
1097   *      -->P_TC_NAME  name of tablecontrol
1098   *----------------------------------------------------------------------*
1099   FORM FCODE_TC_MARK_LINES USING P_TC_NAME
1100                                  P_TABLE_NAME
1101                                  P_MARK_NAME.
1102   *&SPWIZARD: EGIN OF LOCAL DATA-----------------------------------------*
1103     DATA L_TABLE_NAME       LIKE FELD-NAME.
1104
1105     FIELD-SYMBOLS <TC>         TYPE cxtab_control.
1106     FIELD-SYMBOLS <TABLE>      TYPE STANDARD TABLE.
1107     FIELD-SYMBOLS <WA>.
1108     FIELD-SYMBOLS <MARK_FIELD>.
1109   *&SPWIZARD: END OF LOCAL DATA------------------------------------------*
1110
1111     ASSIGN (P_TC_NAME) TO <TC>.
1112
1113   *&SPWIZARD: get the table, which belongs to the tc                     *
1114     CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
1115     ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline
1116
1117   *&SPWIZARD: mark all filled lines                                      *
1118     LOOP AT <TABLE> ASSIGNING <WA>.
1119
1120   *&SPWIZARD: access to the component 'FLAG' of the table header         *
1121       ASSIGN COMPONENT P_MARK_NAME OF STRUCTURE <WA> TO <MARK_FIELD>.
1122
1123       <MARK_FIELD> = 'X'.
1124     ENDLOOP.
1125   ENDFORM.                                          "fcode_tc_mark_lines
1126
1127   *&---------------------------------------------------------------------*
1128   *&      Form  FCODE_TC_DEMARK_LINES
1129   *&---------------------------------------------------------------------*
1130   *       demarks all TableControl lines
1131   *----------------------------------------------------------------------*
1132   *      -->P_TC_NAME  name of tablecontrol
1133   *----------------------------------------------------------------------*
1134   FORM FCODE_TC_DEMARK_LINES USING P_TC_NAME
1135                                    P_TABLE_NAME
1136                                    P_MARK_NAME .
1137   *&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
1138     DATA L_TABLE_NAME       LIKE FELD-NAME.
1139
1140     FIELD-SYMBOLS <TC>         TYPE cxtab_control.
1141     FIELD-SYMBOLS <TABLE>      TYPE STANDARD TABLE.
1142     FIELD-SYMBOLS <WA>.
1143     FIELD-SYMBOLS <MARK_FIELD>.
1144   *&SPWIZARD: END OF LOCAL DATA------------------------------------------*
1145
1146     ASSIGN (P_TC_NAME) TO <TC>.
1147
1148   *&SPWIZARD: get the table, which belongs to the tc                     *
1149     CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
1150     ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline
1151
1152   *&SPWIZARD: demark all filled lines                                    *
1153     LOOP AT <TABLE> ASSIGNING <WA>.
1154
1155   *&SPWIZARD: access to the component 'FLAG' of the table header         *
1156       ASSIGN COMPONENT P_MARK_NAME OF STRUCTURE <WA> TO <MARK_FIELD>.
1157
1158       <MARK_FIELD> = SPACE.
1159     ENDLOOP.
1160   ENDFORM.                                          "fcode_tc_mark_lines
1161   *&---------------------------------------------------------------------*
1162   *&      Form  SUBMIT_0405
1163   *&---------------------------------------------------------------------*
1164   *       text
1165   *----------------------------------------------------------------------*
1166   *      -->P_P_TABLE_NAME  text
1167   *----------------------------------------------------------------------*
1168   FORM SUBMIT_0405.
1169     " Operation on IST_9920_SUBMIT
1170
1171     DATA: WA_9920_SUBMIT_SEL TYPE TY_SUBMIT,
1172           WA_9920_MSG TYPE ZHR_MEDPYMT_9920_MSG,
1173           l_tabix  TYPE sy-tabix.
1174
1175     LOOP AT IST_9920_SUBMIT INTO WA_9920_SUBMIT_SEL WHERE SEL = 'X' AND ZSTATUS = 'NEW'.
1176       l_tabix =   sy-tabix .
1177       MOVE-CORRESPONDING WA_9920_SUBMIT_SEL to WA_9920_MSG.
1178       WA_9920_MSG-SPRPS = 'X' .  "to be retained
1179       WA_9920_MSG-ZSTATUS = 'SUBMITTED' .
1180
1181   *Begin RD1K976756  CAB_ALOK : HR infotype update thro' RFC
1182   *    CALL FUNCTION 'ZHR_MED_PYMT_UPDATE9920_MSG'
1183       CALL FUNCTION 'ZHR_MED_PYMT_UPDATE9920_MSG' DESTINATION 'MMREQ_ASSETNO_CR_RFC'
1184   *End RD1K976756  CAB_ALOK
1185         EXPORTING
1186           OPERATION_TYPE = 'MOD'       "OPERATION of HR_INFOTYPE_OPERATION
1187           LOCK_INDICATOR = 'X'
1188         CHANGING
1189           WA_9920_MSG    = WA_9920_MSG.
1190       if WA_9920_MSG-ERROR_FLAG = '1'. "if update Operation failed, then reset the status
1191         WA_9920_MSG-ZSTATUS = 'NEW' .
1192       endif.
1193       MOVE-CORRESPONDING WA_9920_MSG to  WA_9920_SUBMIT_SEL.
1194
1195   *MODIFY IST_9920_SUBMIT  FROM  WA_9920_SUBMIT_SEL INDEX l_tabix  TRANSPORTING SPRPR ZSTATUS MESSAGE ERROR_FLAG .
1196   *MODIFY IST_9920_SUBMIT  FROM  WA_9920_SUBMIT_SEL INDEX l_tabix  TRANSPORTING p9920-SPRPR p9920-ZSTATUS MESSAGE ERROR_FLAG .
1197       " No component exists with the name "SPRPR". .
1198       " above stmts not working
1199
1200       MODIFY IST_9920_SUBMIT  FROM  WA_9920_SUBMIT_SEL INDEX l_tabix.
1201
1202       CLEAR: WA_9920_SUBMIT_SEL ,
1203              WA_9920_MSG.
1204
1205     ENDLOOP.
1206
1207
1208
1209
1210
1211   ENDFORM.                    " SUBMIT_0405
1212   *&---------------------------------------------------------------------*
1213   *&      Form  GET_DATA_0501
1214   *&---------------------------------------------------------------------*
1215   *       text
1216   *----------------------------------------------------------------------*
1217   *  -->  p1        text
1218   *  <--  p2        text
1219   *----------------------------------------------------------------------*
1220   FORM GET_DATA_0501 .
1221
1222     DATA: submit_pernr TYPE pernr_d.
1223     DATA: submit_name TYPE emnam.
1224     DATA: submit_orgeh TYPE orgeh.
1225     DATA: submit_plans TYPE plans.
1226     DATA: submit_persa TYPE persa.
1227     DATA: submit_bukrs TYPE bukrs.
1228
1229
1230   *  PERFORM GETDATA_USER
1231   *       changing submit_pernr submit_name submit_orgeh
1232   *          submit_plans submit_persa submit_bukrs.
1233
1234     PERFORM GETDATA_IST_9920_UNLOCK tables IST_9920_UNLOCK using G_USER_BUKRS. "submit_bukrs .
1235
1236   ENDFORM.                    " GET_DATA_0501
1237   *&---------------------------------------------------------------------*
1238   *&      Form  GETDATA_IST_9920_UNLOCK
1239   *&---------------------------------------------------------------------*
1240   *       text
1241   *----------------------------------------------------------------------*
1242   *      -->P_IST_9920_UNLOCK  text
1243   *      -->P_SUBMIT_BUKRS  text
1244   *----------------------------------------------------------------------*
1245
1246   * Begin RD1K981765 CR: 30007609 CAB_ALOK
1247   *FORM  GETDATA_IST_9920_UNLOCK   tables IST_9920_UNLOCK using submit_bukrs.
1248   FORM GETDATA_IST_9920_UNLOCK tables IST_9920_UNLOCK STRUCTURE IST_9920_UNLOCK using submit_bukrs.
1249   * End RD1K981765 CR: 30007609 CAB_ALOK
1250     DATA: wa_9920_SUBMIT1 TYPE ty_submit,
1251                 l_tabix  TYPE sy-tabix.
1252
1253     data: R_BEGDA TYPE RANGE OF PA9920-BEGDA WITH HEADER LINE,
1254   *   R_ZHOSPID TYPE RANGE OF PA9920-ZHOSPID WITH HEADER LINE, Now only one vendor in the lot
1255           R_PERNR TYPE RANGE OF PA9920-PERNR WITH HEADER LINE,
1256           R_SUBTY TYPE RANGE OF PA9920-SUBTY WITH HEADER LINE .
1257
1258
1259   *** data:  DATE_LOW type sy-datum,
1260   ***        DATE_HIGH type sy-datum.
1261
1262
1263   *get rows from PA9920 based on selection screen input (struct: ZPMED_SUBMIT)
1264   * and company code of record = comapny code of current user.
1265   * and Status of record = 'NEW'
1266   *Struct.     ZPMED_SUBMIT
1267   *    BEGDA_LOW          20100831
1268   *    BEGDA_HIGH         20100929
1269   *    UNAME_LOW          ABC
1270   *    UNAME_HIGH         X
1271   *    ZHOSPID_LOW        111
1272   *    ZHOSPID_HIGH       222
1273
1274   *** convert dates
1275   **            CALL FUNCTION 'ZHR_MED_PYMT_TO_DDMMYYYY'
1276   **              EXPORTING
1277   **                YYYYMMDD       = ZPMED_SUBMIT-BEGDA_LOW
1278   **             IMPORTING
1279   **                DDMMYYYY       = DATE_LOW.
1280   **
1281   **            CALL FUNCTION 'ZHR_MED_PYMT_TO_DDMMYYYY'
1282   **              EXPORTING
1283   **                YYYYMMDD       = ZPMED_SUBMIT-BEGDA_HIGH
1284   **             IMPORTING
1285   **                DDMMYYYY       = DATE_HIGH.
1286
1287   *Put data in range so that 'IN' keyword can be used in SELECT stmt.
1288     clear:  R_BEGDA,  R_PERNR, R_SUBTY.   "R_ZHOSPID,
1289     refresh:  R_BEGDA,  R_PERNR, R_SUBTY. "R_ZHOSPID,
1290
1291     R_BEGDA-SIGN = 'I'.
1292     R_BEGDA-LOW = ZPMED_SUBMIT-BEGDA_LOW.
1293     R_BEGDA-HIGH = ZPMED_SUBMIT-BEGDA_HIGH.
1294     if R_BEGDA-LOW is NOT INITIAL and  R_BEGDA-HIGH is NOT INITIAL.
1295       R_BEGDA-OPTION = 'BT'.
1296     else.
1297       R_BEGDA-OPTION = 'EQ'.
1298     endif.
1299     append R_BEGDA.
1300     if R_BEGDA-LOW is INITIAL and  R_BEGDA-HIGH is INITIAL.
1301       clear: R_BEGDA.
1302       refresh:  R_BEGDA.
1303     endif.
1304
1305
1306     CALL FUNCTION 'ZHR_MED_PYMT_VENDOR_ADD_ZERO'
1307       CHANGING
1308         VENDOR = ZPMED_SUBMIT-ZHOSPID_LOW.
1309
1310   *   CALL FUNCTION 'ZHR_MED_PYMT_VENDOR_ADD_ZERO'
1311   *      CHANGING
1312   *         VENDOR        = ZPMED_SUBMIT-ZHOSPID_HIGH.
1313   *
1314   *R_ZHOSPID-SIGN = 'I'.
1315   *R_ZHOSPID-LOW = ZPMED_SUBMIT-ZHOSPID_LOW.
1316   *R_ZHOSPID-HIGH = ZPMED_SUBMIT-ZHOSPID_HIGH.
1317   *if  R_ZHOSPID-LOW is NOT INITIAL and R_ZHOSPID-HIGH is NOT INITIAL.
1318   *  R_ZHOSPID-OPTION = 'BT'.
1319   *else.
1320   *  R_ZHOSPID-OPTION = 'EQ'.
1321   *endif.
1322   *append R_ZHOSPID.
1323   *if R_ZHOSPID-LOW is INITIAL and  R_ZHOSPID-HIGH  is INITIAL.
1324   *  clear: R_ZHOSPID.
1325   *  refresh:  R_ZHOSPID.
1326   *endif.
1327
1328
1329     R_PERNR-SIGN = 'I'.
1330     R_PERNR-LOW = ZPMED_SUBMIT-PERNR_LOW.
1331     R_PERNR-HIGH = ZPMED_SUBMIT-PERNR_HIGH.
1332     if R_PERNR-LOW is NOT INITIAL and  R_PERNR-HIGH is NOT INITIAL.
1333       R_PERNR-OPTION = 'BT'.
1334     else.
1335       R_PERNR-OPTION = 'EQ'.
1336     endif.
1337     append R_PERNR.
1338     if R_PERNR-LOW is INITIAL and  R_PERNR-HIGH is INITIAL.
1339       clear: R_PERNR.
1340       refresh:  R_PERNR.
1341     endif.
1342
1343     R_SUBTY-SIGN = 'I'.
1344     R_SUBTY-LOW = ZPMED_SUBMIT-SUBTY_LOW.
1345     R_SUBTY-HIGH = ZPMED_SUBMIT-SUBTY_HIGH.
1346     if R_SUBTY-LOW is NOT INITIAL and  R_SUBTY-HIGH is NOT INITIAL.
1347       R_SUBTY-OPTION = 'BT'.
1348     else.
1349       R_SUBTY-OPTION = 'EQ'.
1350     endif.
1351     append R_SUBTY.
1352     if R_SUBTY-LOW is INITIAL and  R_SUBTY-HIGH is INITIAL.
1353       clear: R_SUBTY.
1354       refresh:  R_SUBTY.
1355     endif.
1356
1357   *if ZPMED_SUBMIT-UNAME_HIGH is INITIAL.
1358   *  ZPMED_SUBMIT-UNAME_HIGH = ZPMED_SUBMIT-UNAME_LOW.
1359   *endif.
1360   *if ZPMED_SUBMIT-BEGDA_HIGH is INITIAL.
1361   *  ZPMED_SUBMIT-BEGDA_HIGH = ZPMED_SUBMIT-BEGDA_LOW.
1362   *endif.
1363   *if ZPMED_SUBMIT-ZHOSPID_HIGH is INITIAL.
1364   *  ZPMED_SUBMIT-ZHOSPID_HIGH = ZPMED_SUBMIT-ZHOSPID_LOW.
1365   *endif.
1366
1367     select * from PA9920
1368       into corresponding fields of table IST_9920_UNLOCK
1369         where BEGDA IN R_BEGDA " as YYYYMMDD
1370           "and ZHOSPID IN R_ZHOSPID  " as 0000800001, Single vendor Lot
1371           and ZHOSPID = ZPMED_SUBMIT-ZHOSPID_LOW
1372           and PERNR IN R_PERNR
1373           and SUBTY IN R_SUBTY
1374           and GRPVL = submit_bukrs
1375           and ZSTATUS = 'SUBMITTED'
1376           and ( SUBTY = '03' or SUBTY = '04' or SUBTY = '05' or SUBTY = '06' or SUBTY = '07' )
1377           order by PERNR .
1378
1379   * Begin RD1K981765 CR: 30007609 CAB_ALOK
1380     Sort IST_9920_UNLOCK by CNTER ASCENDING.
1381   * End RD1K981765 CR: 30007609 CAB_ALOK
1382
1383   ** Fill INFTY, serial no., MO_AMOUNT
1384   *  sort IST_9920_UNLOCK by pernr ASCENDING.
1385     loop at IST_9920_UNLOCK into wa_9920_SUBMIT1.
1386       l_tabix = sy-tabix.
1387       wa_9920_SUBMIT1-INFTY = '9920'.
1388       wa_9920_SUBMIT1-serial_no = l_tabix.
1389       if wa_9920_SUBMIT1-ztax = 'X'.
1390         wa_9920_SUBMIT1-taxable = 'Y'.
1391       elseif wa_9920_SUBMIT1-znontax = 'X'.
1392         wa_9920_SUBMIT1-taxable = 'N'.
1393       else.
1394         wa_9920_SUBMIT1-taxable = 'B'.
1395       endif.
1396       if WA_9920_SUBMIT1-ZAMTMOTOTAL is initial.
1397         WA_9920_SUBMIT1-ZAMTMOTOTAL = wa_9920_SUBMIT1-ZAMOUNT.
1398         "otherwise display ZAMTMOTOTAL value saved after editing by MO.
1399       endif.
1400       MODIFY IST_9920_UNLOCK FROM  WA_9920_SUBMIT1 INDEX l_tabix.
1401     endloop.
1402
1403   *begin RD1K981765 CR: 30007609 CAB_ALOK FS for change in ZHRHOSP
1404     clear G_VENDOR_NAME.
1405     select single NAME1 from ZHR_MED_VENDORS   " BUKRS, LIFNR
1406       into  G_VENDOR_NAME
1407         where BUKRS = P9920-GRPVL
1408           and LIFNR = ZPMED_SUBMIT-ZHOSPID_LOW.
1409   *end RD1K981765 CR: 30007609 CAB_ALOK FS for change in ZHRHOSP
1410   ENDFORM.                    " GETDATA_IST_9920_UNLOCK
1411
1412   *----------------------------------------------------------------------*
1413   *   INCLUDE TABLECONTROL_FORMS                                         *
1414   *----------------------------------------------------------------------*
1415
1416   *&---------------------------------------------------------------------*
1417   *&      Form  USER_OK_TC_UNLOCK                                               *
1418   *&---------------------------------------------------------------------*
1419   FORM USER_OK_TC_UNLOCK USING    P_TC_NAME TYPE DYNFNAM
1420                            P_TABLE_NAME
1421                            P_MARK_NAME
1422                   CHANGING P_OK      LIKE SY-UCOMM.
1423
1424   *&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
1425     DATA: L_OK              TYPE SY-UCOMM,
1426           L_OFFSET          TYPE I.
1427   *&SPWIZARD: END OF LOCAL DATA------------------------------------------*
1428
1429   *&SPWIZARD: Table control specific operations                          *
1430   *&SPWIZARD: evaluate TC name and operations                            *
1431     SEARCH P_OK FOR P_TC_NAME.
1432     IF SY-SUBRC <> 0.
1433       EXIT.
1434     ENDIF.
1435     L_OFFSET = STRLEN( P_TC_NAME ) + 1.
1436     L_OK = P_OK+L_OFFSET.
1437   *   Clear: SAVE_OK_CODE_0505.
1438   *&SPWIZARD: execute general and TC specific operations                 *
1439     CASE L_OK.
1440   *     WHEN 'INSR'.                      "insert row
1441   *       PERFORM FCODE_INSERT_ROW USING    P_TC_NAME
1442   *                                         P_TABLE_NAME.
1443   *       CLEAR P_OK.
1444   *
1445   *     WHEN 'DELE'.                      "delete row
1446   *       PERFORM FCODE_DELETE_ROW USING    P_TC_NAME
1447   *                                         P_TABLE_NAME
1448   *                                         P_MARK_NAME.
1449   *       CLEAR P_OK.
1450
1451       WHEN 'P--' OR                     "top of list
1452            'P-'  OR                     "previous page
1453            'P+'  OR                     "next page
1454            'P++'.                       "bottom of list
1455         PERFORM COMPUTE_SCROLLING_IN_TC USING P_TC_NAME
1456                                               L_OK.
1457         CLEAR P_OK.
1458   *     WHEN 'L--'.                       "total left
1459   *       PERFORM FCODE_TOTAL_LEFT USING P_TC_NAME.
1460   *
1461   *     WHEN 'L-'.                        "column left
1462   *       PERFORM FCODE_COLUMN_LEFT USING P_TC_NAME.
1463   *
1464   *     WHEN 'R+'.                        "column right
1465   *       PERFORM FCODE_COLUMN_RIGHT USING P_TC_NAME.
1466   *
1467   *     WHEN 'R++'.                       "total right
1468   *       PERFORM FCODE_TOTAL_RIGHT USING P_TC_NAME.
1469   *
1470       WHEN 'MARK'.                      "mark all filled lines
1471         PERFORM FCODE_TC_MARK_LINES USING P_TC_NAME
1472                                           P_TABLE_NAME
1473                                           P_MARK_NAME   .
1474         CLEAR P_OK.
1475
1476       WHEN 'DMRK'.                      "demark all filled lines
1477         PERFORM FCODE_TC_DEMARK_LINES USING P_TC_NAME
1478                                             P_TABLE_NAME
1479                                             P_MARK_NAME .
1480         CLEAR P_OK.
1481
1482   *     WHEN 'SASCEND'   OR
1483   *          'SDESCEND'.                  "sort column
1484   *       PERFORM FCODE_SORT_TC USING P_TC_NAME
1485   *                                   l_ok.
1486       WHEN 'UNLOCK'.                      "UNLOCK selected lines
1487
1488         PERFORM UNLOCK_0505. " on Global IST_9920_UNLOCK
1489
1490         CLEAR P_OK.
1491
1492       WHEN 'REJMO'.                      "Reject(by MO) selected lines
1493
1494         PERFORM REJMO_0505. " on Global IST_9920_UNLOCK
1495
1496         CLEAR P_OK.
1497
1498       WHEN 'EDITMO'.                      "EDIT(by MO) selected lines
1499
1500   *       PERFORM EDITMO_0505. " on Global IST_9920_UNLOCK
1501         G_FLAG_EDITMO = 'X'.
1502         CLEAR: G_FLAG_SAVEMO.
1503
1504   *       SAVE_OK_CODE_0505 = OK_CODE_0505.
1505         CLEAR P_OK.
1506
1507       WHEN 'SAVEMO'.                      "SAVE(by MO) selected lines
1508         G_FLAG_SAVEMO = 'X'.
1509         CLEAR: G_FLAG_EDITMO.
1510
1511   *       SAVE_OK_CODE_0505 = OK_CODE_0505.
1512         PERFORM SAVEMO_0505. " on Global IST_9920_UNLOCK
1513         CLEAR P_OK.
1514
1515   * begin RD1K978193 CAB_ALOK CR 30006378
1516       WHEN 'SRCH'.                      "Reject(by MO) selected lines
1517         PERFORM SEARCH. " on Global IST_9920_UNLOCK
1518         CLEAR P_OK.
1519   * end RD1K978193 CAB_ALOK CR 30006378
1520
1521     ENDCASE.
1522
1523   ENDFORM.                              " USER_OK_TC_UNLOCK
1524   *&---------------------------------------------------------------------*
1525   *&      Form  UNLOCK_0505
1526   *&---------------------------------------------------------------------*
1527   *       text
1528   *----------------------------------------------------------------------*
1529   *  -->  p1        text
1530   *  <--  p2        text
1531   *----------------------------------------------------------------------*
1532   FORM UNLOCK_0505 .
1533     " Operation on IST_9920_UNLOCK
1534     DATA: WA_9920_UNLOCK_SEL TYPE TY_SUBMIT,
1535           WA_9920_MSG TYPE ZHR_MEDPYMT_9920_MSG,
1536           l_tabix  TYPE sy-tabix.
1537     DATA: L_ZLOT_NO TYPE p9920-ZLOT_NO,
1538           l_check type c.
1539
1540     clear L_CHECK .
1541     LOOP AT IST_9920_UNLOCK INTO WA_9920_UNLOCK_SEL WHERE SEL = 'X' AND ZSTATUS = 'SUBMITTED'.
1542
1543       if WA_9920_UNLOCK_SEL-taxable = 'Y' or WA_9920_UNLOCK_SEL-taxable = 'N'.
1544       else.
1545         L_CHECK = 'F'. "Fail
1546         WA_9920_UNLOCK_SEL-message = 'Specify Amount is Taxable or not'.
1547         MODIFY IST_9920_UNLOCK   FROM  WA_9920_UNLOCK_SEL INDEX sy-tabix.
1548
1549         message s000(zmsg) with 'Specify Amount is Taxable or not'.
1550       endif.
1551
1552       CLEAR: WA_9920_UNLOCK_SEL .
1553     ENDLOOP.
1554
1555     if l_check = 'F'.
1556     else.
1557       clear: L_ZLOT_NO.
1558       CALL FUNCTION 'NUMBER_GET_NEXT'
1559         EXPORTING
1560           nr_range_nr             = '02'
1561           object                  = 'ZHR_MED'
1562         IMPORTING
1563           number                  = L_ZLOT_NO
1564         EXCEPTIONS
1565           interval_not_found      = 1
1566           number_range_not_intern = 2
1567           object_not_found        = 3
1568           quantity_is_0           = 4
1569           quantity_is_not_1       = 5
1570           interval_overflow       = 6
1571           buffer_overflow         = 7
1572           OTHERS                  = 8.
1573       IF sy-subrc NE 0.
1574         MESSAGE ID 'ZMSG' TYPE 'E' NUMBER '000'
1575               WITH 'Can not process, Error in counter generation'.
1576       ENDIF.
1577
1578
1579       LOOP AT IST_9920_UNLOCK INTO WA_9920_UNLOCK_SEL WHERE SEL = 'X' AND ZSTATUS = 'SUBMITTED'.
1580         l_tabix =   sy-tabix .
1581         MOVE-CORRESPONDING WA_9920_UNLOCK_SEL to WA_9920_MSG.
1582         WA_9920_MSG-SPRPS = '' .  "to be changed from X to ''
1583         WA_9920_MSG-ZLOT_NO = L_ZLOT_NO .  "
1584         WA_9920_MSG-ZSTATUS = 'UNLOCKED' .
1585
1586   *Begin RD1K976756  CAB_ALOK : HR infotype update thro' RFC
1587   *    CALL FUNCTION 'ZHR_MED_PYMT_UPDATE9920_MSG'
1588         CALL FUNCTION 'ZHR_MED_PYMT_UPDATE9920_MSG' DESTINATION 'MMREQ_ASSETNO_CR_RFC'
1589   *End RD1K976756  CAB_ALOK
1590           EXPORTING
1591             OPERATION_TYPE = 'MOD'       "OPERATION of HR_INFOTYPE_OPERATION
1592             LOCK_INDICATOR = 'X'
1593           CHANGING
1594             WA_9920_MSG    = WA_9920_MSG.
1595         if WA_9920_MSG-ERROR_FLAG = '1'. "if update Operation failed, then reset the status
1596           WA_9920_MSG-SPRPS = 'X' .
1597           WA_9920_MSG-ZLOT_NO = ''.
1598           WA_9920_MSG-ZSTATUS = 'SUBMITTED' .
1599         endif.
1600         MOVE-CORRESPONDING WA_9920_MSG to WA_9920_UNLOCK_SEL.
1601
1602   *MODIFY IST_9920_SUBMIT  FROM  WA_9920_SUBMIT_SEL INDEX l_tabix  TRANSPORTING SPRPR ZSTATUS MESSAGE ERROR_FLAG .
1603   *MODIFY IST_9920_SUBMIT  FROM  WA_9920_SUBMIT_SEL INDEX l_tabix  TRANSPORTING p9920-SPRPR p9920-ZSTATUS MESSAGE ERROR_FLAG .
1604         " No component exists with the name "SPRPR". .
1605         " above stmts not working
1606
1607         MODIFY IST_9920_UNLOCK  FROM  WA_9920_UNLOCK_SEL INDEX l_tabix.
1608
1609         CLEAR: WA_9920_UNLOCK_SEL ,
1610                WA_9920_MSG.
1611
1612       ENDLOOP.
1613     endif.
1614   ENDFORM.                    " UNLOCK_0505
1615   *&---------------------------------------------------------------------*
1616   *&      Form  REJMO_0505
1617   *&---------------------------------------------------------------------*
1618   *       text
1619   *----------------------------------------------------------------------*
1620   *  -->  p1        text
1621   *  <--  p2        text
1622   *----------------------------------------------------------------------*
1623   FORM REJMO_0505 .
1624     " Operation on IST_9920_UNLOCK
1625     DATA: WA_9920_UNLOCK_SEL TYPE TY_SUBMIT,
1626           WA_9920_MSG TYPE ZHR_MEDPYMT_9920_MSG,
1627           l_tabix  TYPE sy-tabix.
1628
1629     LOOP AT IST_9920_UNLOCK INTO WA_9920_UNLOCK_SEL WHERE SEL = 'X' AND ZSTATUS = 'SUBMITTED'.
1630       l_tabix =   sy-tabix .
1631       MOVE-CORRESPONDING WA_9920_UNLOCK_SEL to WA_9920_MSG.
1632       WA_9920_MSG-SPRPS = 'X' .  "to be retained
1633       WA_9920_MSG-ZSTATUS = 'REJMO' .
1634
1635   *Begin RD1K976756  CAB_ALOK : HR infotype update thro' RFC
1636   *    CALL FUNCTION 'ZHR_MED_PYMT_UPDATE9920_MSG'
1637       CALL FUNCTION 'ZHR_MED_PYMT_UPDATE9920_MSG' DESTINATION 'MMREQ_ASSETNO_CR_RFC'
1638   *End RD1K976756  CAB_ALOK
1639         EXPORTING
1640           OPERATION_TYPE = 'MOD'       "OPERATION of HR_INFOTYPE_OPERATION
1641           LOCK_INDICATOR = 'X'
1642         CHANGING
1643           WA_9920_MSG    = WA_9920_MSG.
1644       if WA_9920_MSG-ERROR_FLAG = '1'. "if update Operation failed, then reset the status
1645         WA_9920_MSG-SPRPS = 'X' .
1646         WA_9920_MSG-ZSTATUS = 'SUBMITTED' .
1647       endif.
1648       MOVE-CORRESPONDING WA_9920_MSG to WA_9920_UNLOCK_SEL.
1649
1650   *MODIFY IST_9920_SUBMIT  FROM  WA_9920_SUBMIT_SEL INDEX l_tabix  TRANSPORTING SPRPR ZSTATUS MESSAGE ERROR_FLAG .
1651   *MODIFY IST_9920_SUBMIT  FROM  WA_9920_SUBMIT_SEL INDEX l_tabix  TRANSPORTING p9920-SPRPR p9920-ZSTATUS MESSAGE ERROR_FLAG .
1652       " No component exists with the name "SPRPR". .
1653       " above stmts not working
1654
1655       MODIFY IST_9920_UNLOCK  FROM  WA_9920_UNLOCK_SEL INDEX l_tabix.
1656
1657       CLEAR: WA_9920_UNLOCK_SEL ,
1658              WA_9920_MSG.
1659
1660     ENDLOOP.
1661   ENDFORM.                    " REJMO_0505
1662   *&---------------------------------------------------------------------*
1663   *&      Form  SAVEMO_0505
1664   *&---------------------------------------------------------------------*
1665   *       text
1666   *----------------------------------------------------------------------*
1667   *  -->  p1        text
1668   *  <--  p2        text
1669   *----------------------------------------------------------------------*
1670   FORM SAVEMO_0505 .
1671
1672     " Operation on IST_9920_UNLOCK
1673     DATA: WA_9920_UNLOCK_SEL TYPE TY_SUBMIT,
1674           WA_9920_MSG TYPE ZHR_MEDPYMT_9920_MSG,
1675           l_tabix  TYPE sy-tabix.
1676
1677
1678     LOOP AT IST_9920_UNLOCK INTO WA_9920_UNLOCK_SEL WHERE SEL = 'X' AND ZSTATUS = 'SUBMITTED'.
1679       l_tabix =   sy-tabix .
1680       MOVE-CORRESPONDING WA_9920_UNLOCK_SEL to WA_9920_MSG.
1681
1682       if WA_9920_UNLOCK_SEL-taxable = 'Y'.
1683         WA_9920_MSG-ztax = 'X'.
1684         clear WA_9920_MSG-znontax.
1685       elseif WA_9920_UNLOCK_SEL-taxable = 'N'.
1686         WA_9920_MSG-znontax = 'X'.
1687         clear WA_9920_MSG-ztax.
1688       elseif WA_9920_UNLOCK_SEL-taxable = 'B'.
1689         clear: WA_9920_MSG-znontax , WA_9920_MSG-ztax.
1690       endif.
1691
1692
1693       WA_9920_MSG-SPRPS = 'X' .  "to be retained
1694       WA_9920_MSG-ZSTATUS = 'SUBMITTED' .  "to be retained
1695       " only WA_9920_MSG-ZAMTMOTOTAL & WA_9920_MSG-ZREMARKSMO will be updated in PA9920
1696
1697   *Begin RD1K976756  CAB_ALOK : HR infotype update thro' RFC
1698   *    CALL FUNCTION 'ZHR_MED_PYMT_UPDATE9920_MSG'
1699       CALL FUNCTION 'ZHR_MED_PYMT_UPDATE9920_MSG' DESTINATION 'MMREQ_ASSETNO_CR_RFC'
1700   *End RD1K976756  CAB_ALOK
1701         EXPORTING
1702           OPERATION_TYPE = 'MOD'       "OPERATION of HR_INFOTYPE_OPERATION
1703           LOCK_INDICATOR = 'X'
1704         CHANGING
1705           WA_9920_MSG    = WA_9920_MSG.
1706   *if WA_9920_MSG-ERROR_FLAG = '1'. "if update Operation failed, then reset the status
1707   *   WA_9920_MSG-SPRPS = 'X' .
1708   *   WA_9920_MSG-ZSTATUS = 'SUBMITTED' .
1709   *endif.
1710
1711       if WA_9920_MSG-ERROR_FLAG <> '1'. "if update Operation successful, then modify the Message
1712         WA_9920_MSG-MESSAGE = 'Saved '.  " otherwise this message contains 'Status: submitted'
1713       endif.
1714
1715
1716       MOVE-CORRESPONDING WA_9920_MSG to WA_9920_UNLOCK_SEL.
1717
1718   *MODIFY IST_9920_SUBMIT  FROM  WA_9920_SUBMIT_SEL INDEX l_tabix  TRANSPORTING SPRPR ZSTATUS MESSAGE ERROR_FLAG .
1719   *MODIFY IST_9920_SUBMIT  FROM  WA_9920_SUBMIT_SEL INDEX l_tabix  TRANSPORTING p9920-SPRPR p9920-ZSTATUS MESSAGE ERROR_FLAG .
1720       " No component exists with the name "SPRPR". .
1721       " above stmts not working
1722
1723       MODIFY IST_9920_UNLOCK  FROM  WA_9920_UNLOCK_SEL INDEX l_tabix.
1724       CLEAR: WA_9920_UNLOCK_SEL ,
1725              WA_9920_MSG.
1726
1727     ENDLOOP.
1728
1729
1730
1731
1732
1733
1734   ENDFORM.                    " SAVEMO_0505
1735   *&---------------------------------------------------------------------*
1736   *&      Form  GET_DATA_0301
1737   *&---------------------------------------------------------------------*
1738   *       text
1739   *----------------------------------------------------------------------*
1740   *  -->  p1        text
1741   *  <--  p2        text
1742   *----------------------------------------------------------------------*
1743   FORM GET_DATA_0301 .
1744     DATA: submit_pernr TYPE pernr_d.
1745     DATA: submit_name TYPE emnam.
1746     DATA: submit_orgeh TYPE orgeh.
1747     DATA: submit_plans TYPE plans.
1748     DATA: submit_persa TYPE persa.
1749     DATA: submit_bukrs TYPE bukrs.
1750   *data: IST_9920_SUBMIT type table of PA9920.
1751
1752   *  PERFORM GETDATA_USER
1753   *       changing submit_pernr submit_name submit_orgeh
1754   *          submit_plans submit_persa submit_bukrs.
1755
1756     PERFORM GETDATA_IST_9920_EDIT tables IST_9920_EDIT using G_USER_BUKRS. "submit_bukrs .
1757
1758
1759   ENDFORM.                    " GET_DATA_0301
1760   *&---------------------------------------------------------------------*
1761   *&      Form  GETDATA_IST_9920_EDIT_REJECTED
1762   *&---------------------------------------------------------------------*
1763   *       text
1764   *----------------------------------------------------------------------*
1765   *      -->P_IST_9920_SUBMIT  text
1766   *      -->P_SUBMIT_BUKRS  text
1767   *----------------------------------------------------------------------*
1768
1769
1770   * Begin RD1K981765 CR: 30007609 CAB_ALOK
1771   *FORM GETDATA_IST_9920_EDIT  tables IST_9920_EDIT   using submit_bukrs.
1772   FORM GETDATA_IST_9920_EDIT  tables IST_9920_EDIT STRUCTURE IST_9920_EDIT using submit_bukrs.
1773   * End RD1K981765 CR: 30007609 CAB_ALOK
1774     DATA: wa_9920_SUBMIT1 TYPE ty_submit,
1775                 l_tabix  TYPE sy-tabix.
1776
1777     data: R_UNAME TYPE RANGE OF PA9920-UNAME WITH HEADER LINE,
1778           R_BEGDA TYPE RANGE OF PA9920-BEGDA WITH HEADER LINE,
1779           R_ZHOSPID TYPE RANGE OF PA9920-ZHOSPID WITH HEADER LINE .
1780
1781
1782   *** data:  DATE_LOW type sy-datum,
1783   ***        DATE_HIGH type sy-datum.
1784
1785
1786   *get rows from PA9920 based on selection screen input (struct: ZPMED_SUBMIT)
1787   * and company code of record = comapny code of current user.
1788   * and Status of record = 'NEW'
1789   *Struct.     ZPMED_SUBMIT
1790   *    BEGDA_LOW          20100831
1791   *    BEGDA_HIGH         20100929
1792   *    UNAME_LOW          ABC
1793   *    UNAME_HIGH         X
1794   *    ZHOSPID_LOW        111
1795   *    ZHOSPID_HIGH       222
1796
1797   *** convert dates
1798   **            CALL FUNCTION 'ZHR_MED_PYMT_TO_DDMMYYYY'
1799   **              EXPORTING
1800   **                YYYYMMDD       = ZPMED_SUBMIT-BEGDA_LOW
1801   **             IMPORTING
1802   **                DDMMYYYY       = DATE_LOW.
1803   **
1804   **            CALL FUNCTION 'ZHR_MED_PYMT_TO_DDMMYYYY'
1805   **              EXPORTING
1806   **                YYYYMMDD       = ZPMED_SUBMIT-BEGDA_HIGH
1807   **             IMPORTING
1808   **                DDMMYYYY       = DATE_HIGH.
1809
1810   *Put data in range so that 'IN' keyword can be used in SELECT stmt.
1811     clear: R_UNAME, R_BEGDA, R_ZHOSPID.
1812     refresh: R_UNAME, R_BEGDA, R_ZHOSPID.
1813
1814     R_UNAME-SIGN = 'I'.
1815     R_UNAME-LOW = ZPMED_SUBMIT-UNAME_LOW.
1816     R_UNAME-HIGH = ZPMED_SUBMIT-UNAME_HIGH.
1817     if R_UNAME-LOW is NOT INITIAL and  R_UNAME-HIGH is NOT INITIAL.
1818       R_UNAME-OPTION = 'BT'.
1819     else.
1820       R_UNAME-OPTION = 'EQ'.
1821     endif.
1822     append R_UNAME.
1823     if R_UNAME-LOW is INITIAL and  R_UNAME-HIGH is INITIAL.
1824       clear: R_UNAME.
1825       refresh:  R_UNAME.
1826     endif.
1827
1828     R_BEGDA-SIGN = 'I'.
1829     R_BEGDA-LOW = ZPMED_SUBMIT-BEGDA_LOW.
1830     R_BEGDA-HIGH = ZPMED_SUBMIT-BEGDA_HIGH.
1831     if R_BEGDA-LOW is NOT INITIAL and  R_BEGDA-HIGH is NOT INITIAL.
1832       R_BEGDA-OPTION = 'BT'.
1833     else.
1834       R_BEGDA-OPTION = 'EQ'.
1835     endif.
1836     append R_BEGDA.
1837     if R_BEGDA-LOW is INITIAL and  R_BEGDA-HIGH is INITIAL.
1838       clear: R_BEGDA.
1839       refresh:  R_BEGDA.
1840     endif.
1841
1842
1843     CALL FUNCTION 'ZHR_MED_PYMT_VENDOR_ADD_ZERO'
1844       CHANGING
1845         VENDOR = ZPMED_SUBMIT-ZHOSPID_LOW.
1846
1847     CALL FUNCTION 'ZHR_MED_PYMT_VENDOR_ADD_ZERO'
1848       CHANGING
1849         VENDOR = ZPMED_SUBMIT-ZHOSPID_HIGH.
1850
1851     R_ZHOSPID-SIGN = 'I'.
1852     R_ZHOSPID-LOW = ZPMED_SUBMIT-ZHOSPID_LOW.
1853     R_ZHOSPID-HIGH = ZPMED_SUBMIT-ZHOSPID_HIGH.
1854     if  R_ZHOSPID-LOW is NOT INITIAL and R_ZHOSPID-HIGH is NOT INITIAL.
1855       R_ZHOSPID-OPTION = 'BT'.
1856     else.
1857       R_ZHOSPID-OPTION = 'EQ'.
1858     endif.
1859     append R_ZHOSPID.
1860     if R_ZHOSPID-LOW is INITIAL and  R_ZHOSPID-HIGH  is INITIAL.
1861       clear: R_ZHOSPID.
1862       refresh:  R_ZHOSPID.
1863     endif.
1864
1865
1866   *if ZPMED_SUBMIT-UNAME_HIGH is INITIAL.
1867   *  ZPMED_SUBMIT-UNAME_HIGH = ZPMED_SUBMIT-UNAME_LOW.
1868   *endif.
1869   *if ZPMED_SUBMIT-BEGDA_HIGH is INITIAL.
1870   *  ZPMED_SUBMIT-BEGDA_HIGH = ZPMED_SUBMIT-BEGDA_LOW.
1871   *endif.
1872   *if ZPMED_SUBMIT-ZHOSPID_HIGH is INITIAL.
1873   *  ZPMED_SUBMIT-ZHOSPID_HIGH = ZPMED_SUBMIT-ZHOSPID_LOW.
1874   *endif.
1875
1876   *select * from PA9920
1877   *  into corresponding fields of table IST_9920_SUBMIT
1878   *    where uname between ZPMED_SUBMIT-UNAME_LOW  AND ZPMED_SUBMIT-UNAME_HIGH
1879   *      and BEGDA BETWEEN ZPMED_SUBMIT-BEGDA_LOW AND ZPMED_SUBMIT-BEGDA_HIGH " as YYYYMMDD
1880   *      and ZHOSPID BETWEEN ZPMED_SUBMIT-ZHOSPID_LOW AND ZPMED_SUBMIT-ZHOSPID_HIGH  " as 0000800001
1881   *      and GRPVL = submit_bukrs
1882   *      and ZSTATUS = 'NEW'.
1883
1884     select * from PA9920
1885       into corresponding fields of table IST_9920_EDIT
1886         where uname IN R_UNAME
1887           and BEGDA IN R_BEGDA " as YYYYMMDD
1888           and ZHOSPID IN R_ZHOSPID  " as 0000800001
1889           and GRPVL = submit_bukrs  " company code of the current user
1890           and ( ZSTATUS = 'REJMO' or ZSTATUS = 'REJFI' )
1891           and ( SUBTY = '03' or SUBTY = '04' or SUBTY = '05' or SUBTY = '06' or SUBTY = '07' )
1892           order by pernr .
1893
1894   * Begin RD1K981765 CR: 30007609 CAB_ALOK
1895     Sort IST_9920_EDIT by CNTER ASCENDING.
1896   * End RD1K981765 CR: 30007609 CAB_ALOK
1897
1898
1899   ** Fill INFTY, serial no.
1900
1901     loop at IST_9920_EDIT into wa_9920_SUBMIT1.
1902       l_tabix = sy-tabix.
1903       wa_9920_SUBMIT1-INFTY = '9920'.
1904       wa_9920_SUBMIT1-ZLOT_No = ''.
1905       wa_9920_SUBMIT1-serial_no = l_tabix.
1906       MODIFY IST_9920_EDIT  FROM  WA_9920_SUBMIT1 INDEX l_tabix.
1907     endloop.
1908
1909
1910   ENDFORM.                    " GETDATA_IST_9920_EDIT_REJECTED
1911
1912   *----------------------------------------------------------------------*
1913   *   INCLUDE TABLECONTROL_FORMS                                         *
1914   *----------------------------------------------------------------------*
1915
1916   *&---------------------------------------------------------------------*
1917   *&      Form  USER_OK_TC_EDIT                                               *
1918   *&---------------------------------------------------------------------*
1919   FORM USER_OK_TC_EDIT USING    P_TC_NAME TYPE DYNFNAM
1920                            P_TABLE_NAME
1921                            P_MARK_NAME
1922                   CHANGING P_OK      LIKE SY-UCOMM.
1923
1924   *&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
1925     DATA: L_OK              TYPE SY-UCOMM,
1926           L_OFFSET          TYPE I.
1927   *&SPWIZARD: END OF LOCAL DATA------------------------------------------*
1928
1929   *&SPWIZARD: Table control specific operations                          *
1930   *&SPWIZARD: evaluate TC name and operations                            *
1931     SEARCH P_OK FOR P_TC_NAME.
1932     IF SY-SUBRC <> 0.
1933       EXIT.
1934     ENDIF.
1935     L_OFFSET = STRLEN( P_TC_NAME ) + 1.
1936     L_OK = P_OK+L_OFFSET.
1937   *&SPWIZARD: execute general and TC specific operations                 *
1938     CASE L_OK.
1939   *     WHEN 'INSR'.                      "insert row
1940   *       PERFORM FCODE_INSERT_ROW USING    P_TC_NAME
1941   *                                         P_TABLE_NAME.
1942   *       CLEAR P_OK.
1943   *
1944   *     WHEN 'DELE'.                      "delete row
1945   *       PERFORM FCODE_DELETE_ROW USING    P_TC_NAME
1946   *                                         P_TABLE_NAME
1947   *                                         P_MARK_NAME.
1948   *       CLEAR P_OK.
1949
1950       WHEN 'P--' OR                     "top of list
1951            'P-'  OR                     "previous page
1952            'P+'  OR                     "next page
1953            'P++'.                       "bottom of list
1954         PERFORM COMPUTE_SCROLLING_IN_TC USING P_TC_NAME
1955                                               L_OK.
1956         CLEAR P_OK.
1957   *     WHEN 'L--'.                       "total left
1958   *       PERFORM FCODE_TOTAL_LEFT USING P_TC_NAME.
1959   *
1960   *     WHEN 'L-'.                        "column left
1961   *       PERFORM FCODE_COLUMN_LEFT USING P_TC_NAME.
1962   *
1963   *     WHEN 'R+'.                        "column right
1964   *       PERFORM FCODE_COLUMN_RIGHT USING P_TC_NAME.
1965   *
1966   *     WHEN 'R++'.                       "total right
1967   *       PERFORM FCODE_TOTAL_RIGHT USING P_TC_NAME.
1968   *
1969       WHEN 'MARK'.                      "mark all filled lines
1970         PERFORM FCODE_TC_MARK_LINES USING P_TC_NAME
1971                                           P_TABLE_NAME
1972                                           P_MARK_NAME   .
1973         CLEAR P_OK.
1974
1975       WHEN 'DMRK'.                      "demark all filled lines
1976         PERFORM FCODE_TC_DEMARK_LINES USING P_TC_NAME
1977                                             P_TABLE_NAME
1978                                             P_MARK_NAME .
1979         CLEAR P_OK.
1980
1981   *     WHEN 'SASCEND'   OR
1982   *          'SDESCEND'.                  "sort column
1983   *       PERFORM FCODE_SORT_TC USING P_TC_NAME
1984   *                                   l_ok.
1985
1986       WHEN 'EDITDO'.                      "EDIT(by DO) selected lines
1987
1988         G_FLAG_EDITDO = 'X'.
1989         CLEAR: G_FLAG_SAVEDO.
1990
1991         CLEAR P_OK.
1992
1993       WHEN 'SAVEDO'.                      "SAVE(by DO) selected lines
1994         G_FLAG_SAVEDO = 'X'.
1995         CLEAR: G_FLAG_EDITDO.
1996         PERFORM SAVEDO_0305. " on Global IST_9920_EDIT
1997         CLEAR P_OK.
1998
1999   * begin RD1K978193 CAB_ALOK CR 30006378
2000       WHEN 'SRCH'.                      "Reject(by MO) selected lines
2001         PERFORM SEARCH. " on Global IST_9920_EDIT
2002         CLEAR P_OK.
2003   * end RD1K978193 CAB_ALOK CR 30006378
2004
2005     ENDCASE.
2006
2007   ENDFORM.                              " USER_OK_TC_EDIT
2008   *&---------------------------------------------------------------------*
2009   *&      Form  SAVEDO_0305
2010   *&---------------------------------------------------------------------*
2011   *       text
2012   *----------------------------------------------------------------------*
2013   *  -->  p1        text
2014   *  <--  p2        text
2015   *----------------------------------------------------------------------*
2016   FORM SAVEDO_0305 .
2017
2018     " Operation on IST_9920_UNLOCK
2019     DATA: WA_9920_EDIT_SEL TYPE TY_SUBMIT,
2020           WA_9920_MSG TYPE ZHR_MEDPYMT_9920_MSG,
2021           l_tabix  TYPE sy-tabix.
2022
2023     DATA: VALIDATION_MSG type ZCHAR_MAX,                      "255 char
2024           ERROR_FLAG type CHAR1,
2025           l_tabix_val  TYPE sy-tabix.
2026
2027     data: SAVE_ZSTATUS type ZHR_MEDPYMT_9920_MSG-ZSTATUS ,
2028           SAVE_SPRPS type ZHR_MEDPYMT_9920_MSG-SPRPS.
2029   *begin RD1K977852 CAB_ALOK  CR 30006309:Changes in Field exit, ZHRHOSP Prg
2030     data: SAVE_ZAMTMOTOTA type ZHR_MEDPYMT_9920_MSG-ZAMTMOTOTAL.
2031   *end RD1K977852 CAB_ALOK  CR 30006309:Changes in Field exit, ZHRHOSP Prg
2032     LOOP AT IST_9920_EDIT INTO WA_9920_EDIT_SEL WHERE SEL = 'X' AND ( ZSTATUS = 'REJMO' or ZSTATUS = 'REJFI' ).
2033       l_tabix =   sy-tabix .
2034       MOVE-CORRESPONDING WA_9920_EDIT_SEL to WA_9920_MSG.
2035       SAVE_ZSTATUS = WA_9920_MSG-ZSTATUS .
2036       SAVE_SPRPS   = WA_9920_MSG-SPRPS.
2037       WA_9920_MSG-SPRPS = 'X' .  " new status will be 'NEW', so SPRPS = 'X'
2038       WA_9920_MSG-ZSTATUS = 'NEW' .  " to be changed from 'REJ*' to 'NEW'
2039   *begin RD1K977852 CAB_ALOK  CR 30006309:Changes in Field exit, ZHRHOSP Prg
2040       SAVE_ZAMTMOTOTA = WA_9920_MSG-ZAMTMOTOTAL.
2041       WA_9920_MSG-ZAMTMOTOTAL = WA_9920_MSG-ZAMOUNT.
2042   *end RD1K977852 CAB_ALOK  CR 30006309:Changes in Field exit, ZHRHOSP Prg
2043   * Modified fields of WA_9920_MSG  will be updated in PA9920
2044   * VALIDATE the record before updation
2045       clear: P9920, ERROR_FLAG , VALIDATION_MSG.
2046       MOVE-CORRESPONDING WA_9920_MSG to P9920.
2047       CALL FUNCTION 'ZHR_MED_PYMT9920_VALIDATE_FILL'
2048         IMPORTING
2049           VALIDATION_MSG = VALIDATION_MSG
2050           ERROR_FLAG     = ERROR_FLAG
2051         CHANGING
2052           P9920          = P9920.
2053
2054       if ERROR_FLAG = '1'.  " validation failed
2055
2056         WA_9920_MSG-ERROR_FLAG = ERROR_FLAG.
2057         WA_9920_MSG-MESSAGE = VALIDATION_MSG.
2058         "if validation failed, then reset the status & sprps
2059         WA_9920_MSG-SPRPS   = SAVE_SPRPS .
2060         WA_9920_MSG-ZSTATUS = SAVE_ZSTATUS .
2061   *begin RD1K977852 CAB_ALOK  CR 30006309:Changes in Field exit, ZHRHOSP Prg
2062         WA_9920_MSG-ZAMTMOTOTAL = SAVE_ZAMTMOTOTA .
2063   *end RD1K977852 CAB_ALOK  CR 30006309:Changes in Field exit, ZHRHOSP Prg
2064       else.  " Validation OK, now update PA9920
2065
2066         WA_9920_MSG-ZHOSPID = P9920-ZHOSPID.
2067         WA_9920_MSG-ZBILL_NO = P9920-ZBILL_NO.
2068
2069   *Begin RD1K976756  CAB_ALOK : HR infotype update thro' RFC
2070   *    CALL FUNCTION 'ZHR_MED_PYMT_UPDATE9920_MSG'
2071         CALL FUNCTION 'ZHR_MED_PYMT_UPDATE9920_MSG' DESTINATION 'MMREQ_ASSETNO_CR_RFC'
2072   *End RD1K976756  CAB_ALOK
2073             EXPORTING
2074               OPERATION_TYPE = 'MOD'       "OPERATION of HR_INFOTYPE_OPERATION
2075               LOCK_INDICATOR = 'X'
2076             CHANGING
2077               WA_9920_MSG    = WA_9920_MSG.
2078
2079         if WA_9920_MSG-ERROR_FLAG = '1'. "if update Operation failed, then reset the status & sprps
2080           WA_9920_MSG-SPRPS   = SAVE_SPRPS .
2081           WA_9920_MSG-ZSTATUS = SAVE_ZSTATUS .
2082   *begin RD1K977852 CAB_ALOK  CR 30006309:Changes in Field exit, ZHRHOSP Prg
2083           WA_9920_MSG-ZAMTMOTOTAL = SAVE_ZAMTMOTOTA .
2084   *end RD1K977852 CAB_ALOK  CR 30006309:Changes in Field exit, ZHRHOSP Prg
2085         endif.
2086
2087       endif.  " /ERROR_FLAG = '1'.
2088
2089       MOVE-CORRESPONDING WA_9920_MSG to WA_9920_EDIT_SEL.
2090
2091   *MODIFY IST_9920_SUBMIT  FROM  WA_9920_SUBMIT_SEL INDEX l_tabix  TRANSPORTING SPRPR ZSTATUS MESSAGE ERROR_FLAG .
2092   *MODIFY IST_9920_SUBMIT  FROM  WA_9920_SUBMIT_SEL INDEX l_tabix  TRANSPORTING p9920-SPRPR p9920-ZSTATUS MESSAGE ERROR_FLAG .
2093       " No component exists with the name "SPRPR". .
2094       " above stmts not working
2095
2096       MODIFY IST_9920_EDIT  FROM  WA_9920_EDIT_SEL INDEX l_tabix.
2097       CLEAR: WA_9920_EDIT_SEL ,
2098              WA_9920_MSG,
2099              P9920.
2100
2101     ENDLOOP.
2102
2103
2104
2105   ENDFORM.                    " SAVEDO_0305
2106   *&---------------------------------------------------------------------*
2107   *&      Form  GET_DATA_0601
2108   *&---------------------------------------------------------------------*
2109   *       text
2110   *----------------------------------------------------------------------*
2111   *  -->  p1        text
2112   *  <--  p2        text
2113   *----------------------------------------------------------------------*
2114   FORM GET_DATA_0601 .
2115     DATA: submit_pernr TYPE pernr_d.
2116     DATA: submit_name TYPE emnam.
2117     DATA: submit_orgeh TYPE orgeh.
2118     DATA: submit_plans TYPE plans.
2119     DATA: submit_persa TYPE persa.
2120     DATA: submit_bukrs TYPE bukrs.
2121
2122   *  PERFORM GETDATA_USER
2123   *       changing submit_pernr submit_name submit_orgeh
2124   *          submit_plans submit_persa submit_bukrs.
2125
2126     PERFORM GETDATA_IST_9920_PAY tables IST_9920_PAY using G_USER_BUKRS. "submit_bukrs .
2127
2128
2129
2130   ENDFORM.                    " GET_DATA_0601
2131   *&---------------------------------------------------------------------*
2132   *&      Form  GETDATA_IST_9920_PAY
2133   *&---------------------------------------------------------------------*
2134   *       text
2135   *----------------------------------------------------------------------*
2136   *      -->P_IST_9920_PAY  text
2137   *      -->P_SUBMIT_BUKRS  text
2138   *----------------------------------------------------------------------*
2139
2140   * Begin RD1K981765 CR: 30007609 CAB_ALOK
2141   *FORM  GETDATA_IST_9920_PAY  tables IST_9920_PAY using submit_bukrs.
2142   FORM GETDATA_IST_9920_PAY  tables IST_9920_PAY STRUCTURE IST_9920_PAY using submit_bukrs.
2143   * End RD1K981765 CR: 30007609 CAB_ALOK
2144     DATA: wa_9920_PAY1 TYPE ty_pay,
2145                  l_tabix  TYPE sy-tabix.
2146
2147     CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
2148       EXPORTING
2149         INPUT  = ZPMED_SUBMIT-ZLOT_NO_LOW
2150       IMPORTING
2151         OUTPUT = ZPMED_SUBMIT-ZLOT_NO_LOW.
2152
2153     select * from PA9920
2154       into corresponding fields of table IST_9920_PAY
2155         where ZLOT_NO = ZPMED_SUBMIT-ZLOT_NO_LOW
2156           and GRPVL = submit_bukrs
2157   *begin RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
2158   *        and ZSTATUS = 'UNLOCKED'
2159           and ( ZSTATUS = 'UNLOCKED' or ZSTATUS = 'REVERSED' )
2160   *end RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
2161           and ( SUBTY = '03' or SUBTY = '04' or SUBTY = '05' or SUBTY = '06' or SUBTY = '07') .
2162
2163   * Begin RD1K981765 CR: 30007609 CAB_ALOK
2164     Sort IST_9920_PAY by CNTER ASCENDING.
2165   * End RD1K981765 CR: 30007609 CAB_ALOK
2166
2167   ** Fill INFTY, serial no., MO_AMOUNT
2168     loop at IST_9920_PAY into wa_9920_PAY1.
2169       l_tabix = sy-tabix.
2170       wa_9920_PAY1-INFTY = '9920'.
2171       wa_9920_PAY1-serial_no = l_tabix.
2172
2173   *Begin of <RD1K994929> cab_pareek  17.10.2014
2174   * instead of taxable status stored at bill creation it is now
2175   * checking for status in vendor table
2176   *    if wa_9920_PAY1-ztax = 'X'.
2177   *      wa_9920_PAY1-taxable = 'Y'.
2178   *    elseif wa_9920_PAY1-znontax = 'X'.
2179   *      wa_9920_PAY1-taxable = 'N'.
2180   *    else.
2181   *      wa_9920_PAY1-taxable = 'B'.
2182   *    endif.
2183       data l_vendors type ZHR_MED_VENDORS.
2184       select single * from ZHR_MED_VENDORS into l_vendors where
2185                                         lifnr = wa_9920_PAY1-zhospid and
2186                                         taxable = 'N'.
2187       if sy-subrc = 0.
2188         wa_9920_PAY1-taxable = 'N'.
2189       else.
2190         wa_9920_PAY1-taxable = 'Y'.
2191       endif.
2192
2193   *End of <RD1K994929> cab_pareek  17.10.2014
2194
2195       WA_9920_PAY1-ZAMTPCSTOTAL = WA_9920_PAY1-ZAMTMOTOTAL.
2196       MODIFY IST_9920_PAY FROM  WA_9920_PAY1 INDEX l_tabix.
2197     endloop.
2198
2199   ENDFORM.                    " GETDATA_IST_9920_PAY
2200
2201   *----------------------------------------------------------------------*
2202   *   INCLUDE TABLECONTROL_FORMS                                         *
2203   *----------------------------------------------------------------------*
2204
2205   *&---------------------------------------------------------------------*
2206   *&      Form  USER_OK_TC_PAY                                              *
2207   *&---------------------------------------------------------------------*
2208   FORM USER_OK_TC_PAY USING    P_TC_NAME TYPE DYNFNAM
2209                            P_TABLE_NAME
2210                            P_MARK_NAME
2211                   CHANGING P_OK      LIKE SY-UCOMM.
2212
2213     data: TEST_FLAG(1) ,
2214           L_GLAC type char10 ,
2215           L_FISCAL_YEAR(4) TYPE C ,
2216           l_bukrs type bukrs.
2217
2218
2219   *&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
2220     DATA: L_OK              TYPE SY-UCOMM,
2221           L_OFFSET          TYPE I.
2222   *&SPWIZARD: END OF LOCAL DATA------------------------------------------*
2223
2224   *&SPWIZARD: Table control specific operations                          *
2225   *&SPWIZARD: evaluate TC name and operations                            *
2226     SEARCH P_OK FOR P_TC_NAME.
2227     IF SY-SUBRC <> 0.
2228       EXIT.
2229     ENDIF.
2230     L_OFFSET = STRLEN( P_TC_NAME ) + 1.
2231     L_OK = P_OK+L_OFFSET.
2232   *&SPWIZARD: execute general and TC specific operations                 *
2233     CASE L_OK.
2234   *     WHEN 'INSR'.                      "insert row
2235   *       PERFORM FCODE_INSERT_ROW USING    P_TC_NAME
2236   *                                         P_TABLE_NAME.
2237   *       CLEAR P_OK.
2238   *
2239   *     WHEN 'DELE'.                      "delete row
2240   *       PERFORM FCODE_DELETE_ROW USING    P_TC_NAME
2241   *                                         P_TABLE_NAME
2242   *                                         P_MARK_NAME.
2243   *       CLEAR P_OK.
2244
2245       WHEN 'P--' OR                     "top of list
2246            'P-'  OR                     "previous page
2247            'P+'  OR                     "next page
2248            'P++'.                       "bottom of list
2249         PERFORM COMPUTE_SCROLLING_IN_TC USING P_TC_NAME
2250                                               L_OK.
2251         CLEAR P_OK.
2252   *     WHEN 'L--'.                       "total left
2253   *       PERFORM FCODE_TOTAL_LEFT USING P_TC_NAME.
2254   *
2255   *     WHEN 'L-'.                        "column left
2256   *       PERFORM FCODE_COLUMN_LEFT USING P_TC_NAME.
2257   *
2258   *     WHEN 'R+'.                        "column right
2259   *       PERFORM FCODE_COLUMN_RIGHT USING P_TC_NAME.
2260   *
2261   *     WHEN 'R++'.                       "total right
2262   *       PERFORM FCODE_TOTAL_RIGHT USING P_TC_NAME.
2263   *
2264       WHEN 'MARK'.                      "mark all filled lines
2265         PERFORM FCODE_TC_MARK_LINES USING P_TC_NAME
2266                                           P_TABLE_NAME
2267                                           P_MARK_NAME   .
2268         CLEAR P_OK.
2269
2270       WHEN 'DMRK'.                      "demark all filled lines
2271         PERFORM FCODE_TC_DEMARK_LINES USING P_TC_NAME
2272                                             P_TABLE_NAME
2273                                             P_MARK_NAME .
2274         CLEAR P_OK.
2275
2276   *     WHEN 'SASCEND'   OR
2277   *          'SDESCEND'.                  "sort column
2278   *       PERFORM FCODE_SORT_TC USING P_TC_NAME
2279   *                                   l_ok.
2280       WHEN 'TEST'.
2281         TEST_FLAG = 'T'.
2282         PERFORM PAY_0605 using TEST_FLAG.
2283         CLEAR P_OK.
2284   *Begin RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
2285       WHEN 'CHECK'.
2286         PERFORM LEVEL_1_CHECK_0605.
2287         CLEAR P_OK.
2288   *end RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
2289
2290       WHEN 'PAY'.                      " applicable on selected lines
2291
2292         " chnages frm here by Swetha
2293
2294   *  Loop at ist_9920_pay into wa_9920_pay .
2295   *            if WA_9920_PAY-SUBTY = '05'.
2296   *              L_GLAC = '0000200301'.
2297   *            elseif ( WA_9920_PAY-SUBTY = '03' or WA_9920_PAY-SUBTY = '06' ).
2298   *              L_GLAC = '0000200308'.
2299   *            elseif WA_9920_PAY-SUBTY = '04'.
2300   *              L_GLAC = '0000200309'.
2301   *            endif.
2302   *
2303   *             CLEAR: l_persk, l_persg, L_GLAC .
2304   *        SELECT SINGLE persk persg           " bukrs
2305   *              FROM pa0001
2306   *              INTO (l_persk, l_persg)       " , L_BUKRS
2307   *                WHERE pernr = WA_9920_PAY-PERNR
2308   *                 AND begda =< sy-datum
2309   *                 AND endda >= sy-datum.
2310   *
2311   *        if sy-subrc = 0.
2312   *          if   l_persg = '2'
2313   *            or l_persg = 'B' .    " Retd. Employee
2314   *
2315   *            if WA_9920_PAY-SUBTY = '05'.
2316   *              L_GLAC = '0000200301'.
2317   *            elseif ( WA_9920_PAY-SUBTY = '03' or WA_9920_PAY-SUBTY = '06' ).
2318   *              L_GLAC = '0000200308'.
2319   *            elseif WA_9920_PAY-SUBTY = '04'.
2320   *              L_GLAC = '0000200309'.
2321   *            endif.
2322   *
2323   *          elseif l_persg = '1' " Activ. Employee (Officer + Staff)
2324   *              or l_persg = '7'
2325   *              or l_persg = '8'
2326   *              or l_persg = '9'
2327   *              or l_persg = 'A'
2328   *              or l_persg = 'G'
2329   *              or l_persg = 'S'.
2330   *            " now determine whether Officer or Staff
2331   *            if   l_persk = 'C'    " => officer
2332   *              or l_persk = 'D'
2333   *              or l_persk = 'E0'
2334   *              or l_persk = 'E1'
2335   *              or l_persk = 'E2'
2336   *              or l_persk = 'E3'
2337   *              or l_persk = 'E4'
2338   *              or l_persk = 'E5'
2339   *              or l_persk = 'E6'
2340   *              or l_persk = 'E7'
2341   *              or l_persk = 'E8'
2342   *              or l_persk = 'E9'
2343   *              or l_persk = 'GT'.
2344   *
2345   *              if WA_9920_PAY-SUBTY = '05'.
2346   *                L_GLAC = '0000200301'.
2347   *              elseif ( WA_9920_PAY-SUBTY = '03' or WA_9920_PAY-SUBTY = '06' ).
2348   *                L_GLAC = '0000200307'.
2349   *              elseif WA_9920_PAY-SUBTY = '04'.
2350   *                L_GLAC = '0000200302'.
2351   *              endif.    "//officer
2352   *
2353   *            elseif l_persk = 'A1'    " => Staff
2354   *                or l_persk = 'A2'
2355   *                or l_persk = 'A3'
2356   *                or l_persk = 'A4'
2357   *                or l_persk = 'S1'
2358   *                or l_persk = 'S2'
2359   *                or l_persk = 'S3'
2360   *                or l_persk = 'S4'
2361   *                or l_persk = 'TC'
2362   *                or l_persk = 'W1'
2363   *                or l_persk = 'W2'
2364   *                or l_persk = 'W3'
2365   *                or l_persk = 'W4'
2366   *                or l_persk = 'W5'
2367   *                or l_persk = 'W6'
2368   *                or l_persk = 'W7'.
2369   *
2370   *              if WA_9920_PAY-SUBTY = '05'.
2371   *                L_GLAC = '0000200301'.
2372   *              elseif ( WA_9920_PAY-SUBTY = '03' or WA_9920_PAY-SUBTY = '06' ).
2373   *                L_GLAC = '0000200318'.
2374   *              elseif WA_9920_PAY-SUBTY = '04'.
2375   *                L_GLAC = '0000200317'.
2376   *              endif.
2377   *            endif. "//staff
2378   *          elseif l_persg = 'C'.
2379   *
2380   *            if l_persk = 'C1'    " => Contingent worker
2381   *                 or l_persk = 'C2'
2382   *                 or l_persk = 'C3'.
2383   *              L_GLAC = '0000200350'.
2384   *            endif.
2385   *
2386   *          endif.
2387   *        endif. "sy-subrc  " // GL Account logic.
2388   *
2389   *
2390   *
2391   *       CALL FUNCTION 'GM_GET_FISCAL_YEAR'
2392   *        EXPORTING
2393   *          I_DATE    = G_BUDAT
2394   *          i_fyv     = 'V3'
2395   *        IMPORTING
2396   *          E_FY      = L_FISCAL_YEAR .
2397   *
2398   *
2399   *    SELECT SINGLE BUKRS FROM PA0001 INTO L_BUKRS WHERE pernr = sy-uname
2400   *        and begda <= sy-datum and endda >= sy-datum .
2401   *
2402   *    Refresh ist_zhrhospsanction.
2403   *    Select * from zhrhospsanction into corresponding fields of table ist_zhrhospsanction
2404   *       where BUKRS = L_BUKRS and GLHEAD = L_GLAC
2405   *           and GJAHR = L_FISCAL_YEAR.
2406   *     Clear t_amt.
2407   *      Loop at ist_zhrhospsanction into wa_zhrhospsanction.
2408   *        t_amt = t_amt + wa_zhrhospsanction-amt.
2409   *      Endloop.
2410   *
2411   *
2412   *    select single * from zhrhospsanc_utl into  wa_zhrhospsanc_utl
2413   *         where BUKRS = L_BUKRS and GLHEAD = L_GLAC
2414   *           and GJAHR = L_FISCAL_YEAR.
2415   *      If sy-subrc = 0.
2416   *        wa_zhrhospsanc_utl-utilamt = wa_zhrhospsanc_utl-utilamt + WA_9920_PAY-ZAMTPCSTOTAL.
2417   *        t_amt1 = t_amt *   8 / 10 .
2418   *        If wa_zhrhospsanc_utl-utilamt > t_amt .
2419   *          Message e023(ZHR) .
2420   *
2421   *        ElseIf wa_zhrhospsanc_utl-utilamt >=  t_amt1.
2422   *          Message i025(ZHR) .
2423   *        Endif.
2424   *        wa_zhrhospsanc_utl-balamt = t_amt - wa_zhrhospsanc_utl-utilamt.
2425   *        wa_zhrhospsanc_utl-amt = t_amt.
2426   *        Modify zhrhospsanc_utl from wa_zhrhospsanc_utl .
2427   *        Commit Work.
2428   *      Else.
2429   *        If t_amt <> 0  and t_amt is not initial.
2430   *          If WA_9920_PAY-ZAMTPCSTOTAL > t_amt.
2431   *            Message e023(ZHR) .
2432   *          Else.
2433   *          wa_zhrhospsanc_utl-BUKRS = L_BUKRS .
2434   *          wa_zhrhospsanc_utl-GLHEAD = L_GLAC .
2435   *          wa_zhrhospsanc_utl-GJAHR = L_FISCAL_YEAR.
2436   *          wa_zhrhospsanc_utl-amt = t_amt.
2437   *          wa_zhrhospsanc_utl-utilamt = WA_9920_PAY-ZAMTPCSTOTAL.
2438   *          wa_zhrhospsanc_utl-balamt = t_amt - wa_zhrhospsanc_utl-utilamt.
2439   *          Insert into zhrhospsanc_utl values wa_zhrhospsanc_utl.
2440   *          Commit Work.
2441   *          Endif.
2442   *        Else.
2443   *          Message e027(ZHR) .
2444   *        Endif.
2445   *      Endif.
2446
2447   *Endloop.
2448
2449   *Begin RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
2450         data: FLAG_LEVEL_2_CHECK(1).
2451         FLAG_LEVEL_2_CHECK = 'T'.
2452         PERFORM LEVEL_2_CHECK_0605 CHANGING FLAG_LEVEL_2_CHECK.
2453         if FLAG_LEVEL_2_CHECK = 'T'.
2454   *end RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
2455           TEST_FLAG = 'P'.
2456           PERFORM PAY_0605 using TEST_FLAG. " on Global IST_9920_PAY
2457   *Begin RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
2458         endif. "//if FLAG_LEVEL_2_CHECK = 'X'.
2459   *end RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
2460
2461         CLEAR P_OK.
2462
2463       WHEN 'REJFI'.                      "Reject(by Finance) selected lines
2464
2465         PERFORM REJFI_0605. " on Global IST_9920_PAY
2466
2467         CLEAR P_OK.
2468
2469       WHEN 'EDITFI'.                      "EDIT(by Finance) selected lines
2470
2471         G_FLAG_EDITFI = 'X'.
2472         CLEAR: G_FLAG_SAVEFI.
2473         CLEAR P_OK.
2474
2475       WHEN 'SAVEFI'.                      "SAVE(by Finance) selected lines
2476         G_FLAG_SAVEFI = 'X'.
2477         CLEAR: G_FLAG_EDITFI.
2478
2479         PERFORM SAVEFI_0605. " on Global IST_9920_PAY
2480         CLEAR P_OK.
2481     ENDCASE.
2482
2483
2484   ENDFORM.                              " USER_OK_TC
2485
2486   *&---------------------------------------------------------------------*
2487   *&      Form  REJFI_0605
2488   *&---------------------------------------------------------------------*
2489   *       text
2490   *----------------------------------------------------------------------*
2491   *  -->  p1        text
2492   *  <--  p2        text
2493   *----------------------------------------------------------------------*
2494   FORM REJFI_0605 .
2495     " Operation on IST_9920_PAY
2496     DATA: WA_9920_PAY_SEL TYPE TY_PAY,
2497           WA_9920_MSG TYPE ZHR_MEDPYMT_9920_MSG,
2498           l_tabix  TYPE sy-tabix.
2499   *begin RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
2500     DATA: SAVE_CHECKED_BY_PERNR type PERNR,
2501           SAVE_CHECKED_BY_LEVEL type PERSK.
2502   *end RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
2503     LOOP AT IST_9920_PAY INTO WA_9920_PAY_SEL WHERE SEL = 'X' AND ZSTATUS = 'UNLOCKED'.
2504       l_tabix =   sy-tabix .
2505       MOVE-CORRESPONDING WA_9920_PAY_SEL to WA_9920_MSG.
2506
2507       WA_9920_MSG-ZSTATUS = 'REJFI' .
2508       WA_9920_MSG-SPRPS = 'X' .  "to be set to 'X' as the record is being rejected
2509   *begin RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
2510   * clear CHECKED_BY_PERNR and CHECKED_BY_LEVEL in the Rejected record
2511       SAVE_CHECKED_BY_PERNR = WA_9920_MSG-CHECKED_BY_PERNR. "temp save
2512       SAVE_CHECKED_BY_LEVEL = WA_9920_MSG-CHECKED_BY_LEVEL. "temp save
2513       Clear: WA_9920_MSG-CHECKED_BY_PERNR,
2514              WA_9920_MSG-CHECKED_BY_LEVEL.
2515   *end RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
2516   *Begin RD1K976756  CAB_ALOK : HR infotype update thro' RFC
2517   *    CALL FUNCTION 'ZHR_MED_PYMT_UPDATE9920_MSG'
2518       CALL FUNCTION 'ZHR_MED_PYMT_UPDATE9920_MSG' DESTINATION 'MMREQ_ASSETNO_CR_RFC'
2519   *End RD1K976756  CAB_ALOK
2520         EXPORTING
2521           OPERATION_TYPE = 'MOD' "OPERATION of HR_INFOTYPE_OPERATION
2522           LOCK_INDICATOR = ' '   "current value of lockindicator
2523         CHANGING
2524           WA_9920_MSG    = WA_9920_MSG.
2525       if WA_9920_MSG-ERROR_FLAG = '1'. "if update Operation fails, then set the status back to original
2526         WA_9920_MSG-SPRPS = ' ' .
2527         WA_9920_MSG-ZSTATUS = 'UNLOCKED' .
2528   *begin RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
2529   * Set CHECKED_BY_PERNR and CHECKED_BY_LEVEL back to original.
2530         WA_9920_MSG-CHECKED_BY_PERNR = SAVE_CHECKED_BY_PERNR.
2531         WA_9920_MSG-CHECKED_BY_LEVEL = SAVE_CHECKED_BY_LEVEL.
2532       endif.
2533       MOVE-CORRESPONDING WA_9920_MSG to WA_9920_PAY_SEL.
2534
2535   *MODIFY IST_9920_SUBMIT  FROM  WA_9920_SUBMIT_SEL INDEX l_tabix  TRANSPORTING SPRPR ZSTATUS MESSAGE ERROR_FLAG .
2536   *MODIFY IST_9920_SUBMIT  FROM  WA_9920_SUBMIT_SEL INDEX l_tabix  TRANSPORTING p9920-SPRPR p9920-ZSTATUS MESSAGE ERROR_FLAG .
2537       " No component exists with the name "SPRPR". .
2538       " above stmts not working
2539
2540       MODIFY IST_9920_PAY  FROM  WA_9920_PAY_SEL INDEX l_tabix.
2541
2542       CLEAR: WA_9920_PAY_SEL ,
2543              WA_9920_MSG.
2544
2545     ENDLOOP.
2546
2547
2548   ENDFORM.                    " REJFI_0605
2549   *&---------------------------------------------------------------------*
2550   *&      Form  SAVEFI_0605
2551   *&---------------------------------------------------------------------*
2552   *       text
2553   *----------------------------------------------------------------------*
2554   *  -->  p1        text
2555   *  <--  p2        text
2556   *----------------------------------------------------------------------*
2557   FORM SAVEFI_0605 .
2558     " Operation on IST_9920_PAY
2559     DATA: WA_9920_PAY_SEL TYPE TY_PAY,
2560           WA_9920_MSG TYPE ZHR_MEDPYMT_9920_MSG,
2561           l_tabix  TYPE sy-tabix.
2562
2563     LOOP AT IST_9920_PAY INTO WA_9920_PAY_SEL WHERE SEL = 'X' AND ZSTATUS = 'UNLOCKED'.
2564       l_tabix =   sy-tabix .
2565       MOVE-CORRESPONDING WA_9920_PAY_SEL to WA_9920_MSG.
2566       if WA_9920_PAY_SEL-taxable = 'Y'.
2567         WA_9920_MSG-ztax = 'X'.
2568         clear WA_9920_MSG-znontax.
2569       elseif WA_9920_PAY_SEL-taxable = 'N'.
2570         WA_9920_MSG-znontax = 'X'.
2571         clear WA_9920_MSG-ztax.
2572       elseif WA_9920_PAY_SEL-taxable = 'B'.
2573         clear: WA_9920_MSG-znontax , WA_9920_MSG-ztax.
2574       endif.
2575   *   WA_9920_MSG-SPRPS = ' ' .  "to be retained
2576   *   WA_9920_MSG-ZSTATUS = 'UNLOCKED' .  "to be retained
2577
2578       " only WA_9920_MSG-ZREMARKSPCS will be updated in PA9920
2579   *Begin RD1K976756  CAB_ALOK : HR infotype update thro' RFC
2580   *    CALL FUNCTION 'ZHR_MED_PYMT_UPDATE9920_MSG'
2581       CALL FUNCTION 'ZHR_MED_PYMT_UPDATE9920_MSG' DESTINATION 'MMREQ_ASSETNO_CR_RFC'
2582   *End RD1K976756  CAB_ALOK
2583         EXPORTING
2584           OPERATION_TYPE = 'MOD'       "OPERATION of HR_INFOTYPE_OPERATION
2585           LOCK_INDICATOR = ' '   "current value of lockindicator
2586         CHANGING
2587           WA_9920_MSG    = WA_9920_MSG.
2588       if WA_9920_MSG-ERROR_FLAG <> '1'. "if update Operation successful, then modify the Message
2589         WA_9920_MSG-MESSAGE = 'Saved '.  " otherwise this message contains 'Status: UNLOCKED'
2590       endif.
2591
2592       MOVE-CORRESPONDING WA_9920_MSG to WA_9920_PAY_SEL.
2593
2594       MODIFY IST_9920_PAY  FROM  WA_9920_PAY_SEL INDEX l_tabix.
2595       CLEAR: WA_9920_PAY_SEL ,
2596              WA_9920_MSG.
2597
2598     ENDLOOP.
2599
2600
2601   ENDFORM.                    " SAVEFI_0605
2602   *&---------------------------------------------------------------------*
2603   *&      Form  PAY_0605
2604   *&---------------------------------------------------------------------*
2605   *       text
2606   *----------------------------------------------------------------------*
2607   *  -->  p1        text
2608   *  <--  p2        text
2609   *----------------------------------------------------------------------*
2610   FORM PAY_0605 USING TEST_FLAG .
2611
2612
2613   ** F-02, on the basis of:
2614   ** IST_9920_PAY
2615   ** WA_F_02_HEADER TYPE TY_F_02_HEADER.
2616   ** WA_F_02_CREDIT TYPE TY_F_02_CREDIT.
2617   ** IST_F_02_DEBIT TYPE table of  TY_F_02_DEBIT,
2618   ** WA_F_02_DEBIT TYPE  TY_F_02_DEBIT,
2619   ** WA_F_02_DEBIT_NEXT TYPE  TY_F_02_DEBIT.
2620
2621     data:  WA_F_02_HEADER TYPE TY_F_02_HEADER.
2622     data:  WA_F_02_CREDIT TYPE TY_F_02_CREDIT.
2623     data:  IST_F_02_DEBIT TYPE table of  TY_F_02_DEBIT,
2624            WA_F_02_DEBIT TYPE  TY_F_02_DEBIT,
2625            WA_F_02_DEBIT_NEXT TYPE  TY_F_02_DEBIT.
2626
2627     data:  WA_9920_PAY_TMP TYPE TY_PAY,
2628            WA_9920_PAY TYPE TY_PAY,
2629            WA_9920_PAY_SEL TYPE TY_PAY,
2630            l_tabix  TYPE sy-tabix.
2631     data : SUM_ZAMTPCSTOTAL type WRBTR.
2632     data : WA_PA0027 type PA0027.
2633
2634     data: l_persk TYPE persk. "Employee Group : active, retd etc
2635     data: l_persg TYPE persg. " E1, E2, Etc
2636
2637     data: L_GLAC type NEWKO.  "GL A/c
2638     data: L_BUKRS type bukrs. " comp. code. of emp.
2639
2640     FIELD-SYMBOLS : <FS_KPR> type any,               " percentage
2641                     <FS_COMPNY_PERNR> type any,
2642                     <FS_WBS_ELE> type any,
2643                     <FS_COST_CTR> type any.
2644     data: count type i.
2645     data: count_c(2).
2646     data: l_bvorg(10).
2647     data: str_kpr type string,
2648           str_comp type string,
2649           str_wbs_ele type string,
2650           str_cost_ctr type string.
2651
2652     Data :  L_FISCAL_YEAR(4) TYPE C.
2653
2654
2655   * Data : ist_mesg type table of TY_ESP1_MESSAGE with header line.
2656     Data : ist_mesg type ESP1_MESSAGE_TAB_TYPE with header line.
2657     data cnt type i.
2658     data : bdc_subrc like sy-subrc. " capture status of BDC success
2659     data : IST_PA9920 type  table of  PA9920,
2660            WA_PA9920 type PA9920.
2661     data : IST_ZHRMED_EMP_RECOV type table of ZHRMED_EMP_RECOV,
2662            WA_ZHRMED_EMP_RECOV type ZHRMED_EMP_RECOV.
2663
2664   * begin of RD1K977852 CAB_ALOK  CR 30006309: Zero balance problem
2665     DATA IST_F_02_DEBIT_TEMP TYPE table of  TY_F_02_DEBIT.
2666   * end of RD1K977852 CAB_ALOK  CR 30006309
2667
2668   * *begin RD1K979337 CAB_ALOK Lot status from unlock to Paid ZHRHOSP- CR 30006794
2669   *  when MODE is PAY or TEST
2670   *  Take lock on all the pernrs.
2671   *  if any one already locked, get information about who has taken the lock,
2672   *       release all locks, return to screen & display error msg.
2673   *  elseif all pernrs locked
2674   *    run BDC in given mode.
2675   *       .
2676   *       .
2677   *      if mode = production and BDC successful.
2678   *          update 9920.
2679   *              .
2680   *              .
2681   *      endif
2682   *     unlock all pernrs
2683   *   endif
2684     data: WA_9920_PAY_SEL1 TYPE TY_PAY,
2685           WA_9920_MSG TYPE ZHR_MEDPYMT_9920_MSG,
2686           ERROR_PERNR_LOCK type char1.
2687
2688   * Remove previous MESSAGEs & ERROR_FLAGs before each run of table control
2689     clear l_tabix.
2690     CLEAR: WA_9920_PAY_SEL1 .
2691     LOOP AT IST_9920_PAY INTO WA_9920_PAY_SEL1 WHERE ZSTATUS = 'UNLOCKED'.
2692       l_tabix =   sy-tabix .
2693       clear: WA_9920_PAY_SEL1-MESSAGE, WA_9920_PAY_SEL1-ERROR_FLAG.
2694       MODIFY IST_9920_PAY  FROM  WA_9920_PAY_SEL1 INDEX l_tabix.
2695       CLEAR: WA_9920_PAY_SEL1 .
2696     endloop.
2697
2698   *Lock all Pernrs of IST_9920_PAY.
2699     clear l_tabix.
2700     CLEAR: WA_9920_PAY_SEL1, WA_9920_MSG.
2701     LOOP AT IST_9920_PAY INTO WA_9920_PAY_SEL1 WHERE SEL = 'X' AND ZSTATUS = 'UNLOCKED'.
2702       l_tabix =   sy-tabix .
2703       MOVE-CORRESPONDING WA_9920_PAY_SEL1 to WA_9920_MSG.
2704
2705       CALL FUNCTION 'ZHR_MED_PERNR_LOCK' DESTINATION 'MMREQ_ASSETNO_CR_RFC'
2706         CHANGING
2707           WA_9920_MSG = WA_9920_MSG.
2708
2709       if WA_9920_MSG-ERROR_FLAG = '1'.   " at least one pernr lock failed
2710         ERROR_PERNR_LOCK = '1'.
2711       endif.
2712
2713       MOVE-CORRESPONDING WA_9920_MSG to WA_9920_PAY_SEL1.
2714
2715       MODIFY IST_9920_PAY  FROM  WA_9920_PAY_SEL1 INDEX l_tabix.
2716       CLEAR: WA_9920_PAY_SEL1 , WA_9920_MSG.
2717     ENDLOOP.
2718
2719     IF ERROR_PERNR_LOCK = '1'.
2720
2721       MESSAGE i113(zhr). "At least one pernr is locked. See message column.
2722       clear ERROR_PERNR_LOCK.
2723       " at least one pernr lock failed so release other locked pernr of the IST_9920_PAY before exiting
2724       clear l_tabix.
2725       CLEAR: WA_9920_PAY_SEL1, WA_9920_MSG.
2726       LOOP AT IST_9920_PAY INTO WA_9920_PAY_SEL1 WHERE SEL = 'X' AND ZSTATUS = 'UNLOCKED' AND ERROR_FLAG = ''.
2727         l_tabix =   sy-tabix .
2728         MOVE-CORRESPONDING WA_9920_PAY_SEL1 to WA_9920_MSG.
2729
2730         CALL FUNCTION 'ZHR_MED_PERNR_UNLOCK' DESTINATION 'MMREQ_ASSETNO_CR_RFC'
2731           CHANGING
2732             WA_9920_MSG = WA_9920_MSG.
2733
2734         MOVE-CORRESPONDING WA_9920_MSG to WA_9920_PAY_SEL1.
2735
2736         MODIFY IST_9920_PAY  FROM  WA_9920_PAY_SEL1 INDEX l_tabix.
2737         CLEAR: WA_9920_PAY_SEL1 , WA_9920_MSG.
2738       ENDLOOP.
2739
2740     ELSE.  " All pernrs locked, now process BDC (TEST or PAY)
2741   * end RD1K979337 CAB_ALOK Lot status from unlock to Paid ZHRHOSP- CR 30006794
2742
2743   *Clear: WA_F_02_HEADER, WA_F_02_CREDIT, WA_F_02_DEBIT, WA_F_02_DEBIT_NEXT.
2744   *Refresh: IST_F_02_DEBIT.
2745
2746   ** get data from IST_9920_PAY for Header & Credit line item
2747       read table IST_9920_PAY into WA_9920_PAY_TMP
2748                       with key SEL = 'X' ZSTATUS = 'UNLOCKED'.
2749       if sy-subrc = 0.    "Atleast one unlocked row selected.
2750   ** Build WA_F_02_HEADER
2751   *----------------------
2752         WA_F_02_HEADER-BLDAT = sy-datum.
2753         WA_F_02_HEADER-BLART = 'KM'.
2754         WA_F_02_HEADER-BUKRS = WA_9920_PAY_TMP-GRPVL.    " GRPVL: company code for credit.
2755         WA_F_02_HEADER-BUDAT = G_BUDAT.
2756         WA_F_02_HEADER-WAERS = 'INR'.
2757         WA_F_02_HEADER-XBLNR = 'MEDICAL Payment' . " 'ref head'.
2758         WA_F_02_HEADER-BKTXT = WA_9920_PAY_TMP-ZLOT_NO. "'hospital head text'. displaying facility NOT POSSIBLE, All the records belong to different SUBTYPE(facility)
2759
2760
2761   ** Build WA_F_02_CREDIT line item
2762   *--------------------------------
2763         WA_F_02_CREDIT-VENDOR = WA_9920_PAY_TMP-ZHOSPID.      "NEWKO , ZHOSPID
2764
2765   * calculate CREDIT AMT = SUM of ZAMTPCSTOTAL from IST_9920_PAY
2766         SUM_ZAMTPCSTOTAL = 0.
2767         loop at IST_9920_PAY into WA_9920_PAY_SEL WHERE SEL = 'X' AND ZSTATUS = 'UNLOCKED'..
2768           SUM_ZAMTPCSTOTAL = SUM_ZAMTPCSTOTAL + WA_9920_PAY_SEL-ZAMTPCSTOTAL.
2769         endloop.
2770         WA_F_02_CREDIT-WRBTR = SUM_ZAMTPCSTOTAL .   " amt., sum_ZAMTPCSTOTAL
2771
2772         WA_F_02_CREDIT-SECCO = G_SECCO.    " section code
2773         WA_F_02_CREDIT-ZFBDT  = sy-datum.  " base line date
2774         WA_F_02_CREDIT-KIDNO = G_KIDNO.    " paymt ref
2775
2776   *  WA_F_02_CREDIT-SGTXT = 'line item text vendor'
2777         concatenate 'Payment against LOT No.' WA_9920_PAY_TMP-ZLOT_NO into WA_F_02_CREDIT-SGTXT .
2778
2779         WA_F_02_CREDIT-WT_WITHCD = G_WT_WITHCD. "Withholding tax code
2780         WA_F_02_CREDIT-WT_BASE = G_WT_BASE.     "Withholding tax base amount
2781
2782   ** Build WA_F_02_DEBITEBIT line items, split IST_9920_PAY if need be
2783   *=====================================================================
2784         clear: WA_9920_PAY_SEL, WA_F_02_DEBIT.
2785
2786   * Begin RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
2787         Data: FLAG_MODI_UTIL. " F: False- utilization checks fail, T: True-Utilization checks OK ,
2788         FLAG_MODI_UTIL = 'T'.
2789         refresh: ist_zhrhospsanc_utl.
2790
2791   * End RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
2792
2793         loop at IST_9920_PAY into WA_9920_PAY_SEL WHERE SEL = 'X' AND ZSTATUS = 'UNLOCKED'..
2794           l_tabix =   sy-tabix .
2795
2796           MOVE-CORRESPONDING WA_9920_PAY_SEL to WA_F_02_DEBIT.
2797   ** WA_F_02_DEBIT
2798   ****************
2799   * (PA0027(
2800   *MESSAGE
2801   *ERROR_FLAG
2802   *GLAC
2803   *COMPNY_PERNR
2804   *SPLIT_AMT                                      0.00
2805   *VALUT                                      00000000
2806   *SGTXT
2807   *WBS_ELE
2808   *COST_CTR
2809
2810
2811   ** Determine GL Account on the basis of Emp grp & facility, AS PER FOLLOWING TABLE,
2812   ********************************************
2813   *    SUBTY  05        03 or 06           04
2814   *          ( Medicine Hospital / Diag   Doctor )
2815   * Staff     200301    200318            200317
2816   * Officer   200301    200307            200302
2817   * Retd      200301    200308            200309
2818
2819   ** PA0001-PERSG  " employee group
2820   *1  Active employee   ACTIVE
2821   *2  Retiree/pensioner   RETD
2822   *7  Deputation-In   ACTIVE
2823   *8  Deputation-out  ACTIVE
2824   *9  Term based    ACTIVE
2825   *A  Adhoc Appointment   ACTIVE
2826   *B  Separated/deceased    RETD
2827   *G  Graduate Trainee    ACTIVE
2828   *S  Subsidiary    ACTIVE
2829   *T  Tenure Based
2830
2831   ** PA0001-PERSK   " Employee level
2832   * OFFICER                 * STAFF
2833   *C  ONGC CHAIRMAN           A1  ONGC ASST A-I
2834   *D  ONGC DIRECTOR           A2  ONGC ASST A-II
2835   *E0 ONGC EXEC E0            A3  ONGC ASST A-III
2836   *E1 ONGC EXEC E1            A4  ONGC ASST A-IV
2837   *E2 ONGC EXEC E2            S1  ONGC STAFF S-I
2838   *E3 ONGC EXEC E3            S2  ONGC STAFF S-II
2839   *E4 ONGC EXEC E4            S3  ONGC STAFF S-III
2840   *E5 ONGC EXEC E5            S4  ONGC STAFF S-IV
2841   *E6 ONGC EXEC E6            TC  ONGC TOP OF CLSS III
2842   *E7 ONGC EXEC E7            W1  ONGC WORKMEN W-I
2843   *E8 ONGC EXEC E8            W2  ONGC WORKMEN W-II
2844   *E9 ONGC EXEC E9            W3  ONGC WORKMEN W-III
2845   *GT Graduate Trainee        W4  ONGC WORKMEN W-IV
2846   *                           W5  ONGC WORKMEN W-V
2847   *                           W6  ONGC WORKMEN W-VI
2848   *                           W7  ONGC WORKMEN W-VII
2849
2850           CLEAR: l_persk, l_persg, L_GLAC .
2851           SELECT PERSK PERSG
2852    FROM PA0001 INTO ( L_PERSK , L_PERSG ) UP TO 1 ROWS WHERE PERNR = WA_9920_PAY_SEL-PERNR AND BEGDA =< SY-DATUM AND ENDDA >= SY-DATUM
2853    ORDER BY PRIMARY KEY .
2854    ENDSELECT.
2855
2856           if sy-subrc = 0.
2857             if   l_persg = '2'
2858               or l_persg = 'B' .    " Retd. Employee
2859
2860               if WA_9920_PAY_SEL-SUBTY = '05'.
2861                 L_GLAC = '200301'.
2862               elseif ( WA_9920_PAY_SEL-SUBTY = '03' or WA_9920_PAY_SEL-SUBTY = '06' ).
2863                 L_GLAC = '200308'.
2864               elseif WA_9920_PAY_SEL-SUBTY = '04'.
2865                 L_GLAC = '200309'.
2866               endif.
2867
2868             elseif l_persg = '1' " Activ. Employee (Officer + Staff)
2869                 or l_persg = '7'
2870                 or l_persg = '8'
2871                 or l_persg = '9'
2872                 or l_persg = 'A'
2873                 or l_persg = 'G'
2874                 or l_persg = 'S'.
2875               " now determine whether Officer or Staff
2876               if   l_persk = 'C'    " => officer
2877                 or l_persk = 'D'
2878                 or l_persk = 'E0'
2879                 or l_persk = 'E1'
2880                 or l_persk = 'E2'
2881                 or l_persk = 'E3'
2882                 or l_persk = 'E4'
2883                 or l_persk = 'E5'
2884                 or l_persk = 'E6'
2885                 or l_persk = 'E7'
2886                 or l_persk = 'E8'
2887                 or l_persk = 'E9'
2888                 or l_persk = 'GT'.
2889
2890                 if WA_9920_PAY_SEL-SUBTY = '05'.
2891                   L_GLAC = '200301'.
2892                 elseif ( WA_9920_PAY_SEL-SUBTY = '03' or WA_9920_PAY_SEL-SUBTY = '06' ).
2893                   L_GLAC = '200307'.
2894                 elseif WA_9920_PAY_SEL-SUBTY = '04'.
2895                   L_GLAC = '200302'.
2896                 endif.    "//officer
2897
2898               elseif l_persk = 'A1'    " => Staff
2899                   or l_persk = 'A2'
2900                   or l_persk = 'A3'
2901                   or l_persk = 'A4'
2902                   or l_persk = 'S1'
2903                   or l_persk = 'S2'
2904                   or l_persk = 'S3'
2905                   or l_persk = 'S4'
2906                   or l_persk = 'TC'
2907                   or l_persk = 'W1'
2908                   or l_persk = 'W2'
2909                   or l_persk = 'W3'
2910                   or l_persk = 'W4'
2911                   or l_persk = 'W5'
2912                   or l_persk = 'W6'
2913                   or l_persk = 'W7'.
2914
2915                 if WA_9920_PAY_SEL-SUBTY = '05'.
2916                   L_GLAC = '200301'.
2917                 elseif ( WA_9920_PAY_SEL-SUBTY = '03' or WA_9920_PAY_SEL-SUBTY = '06' ).
2918                   L_GLAC = '200318'.
2919                 elseif WA_9920_PAY_SEL-SUBTY = '04'.
2920                   L_GLAC = '200317'.
2921                 endif.
2922               endif. "//staff
2923
2924   * Begin RD1K997486 CAB_ALOK Medical Vendor pymt for Contingent workers -CR 30012858
2925               elseif l_persg = 'C'.  "Contingent worker
2926   *              if l_persk = 'C1'    "
2927   *                   or l_persk = 'C2'
2928   *                   or l_persk = 'C3'.
2929                   L_GLAC = '200350'.
2930   *              endif.
2931   * End RD1K997486 CAB_ALOK Medical Vendor pymt for Contingent workers -CR 30012858
2932
2933             endif.
2934           endif. "sy-subrc  " // GL Account logic.
2935
2936   * GL A/C
2937           WA_F_02_DEBIT-GLAC = L_GLAC.
2938   * Company code
2939   *    WA_F_02_DEBIT-COMPNY_PERNR =  L_BUKRS. " now determined from PA0027
2940   * value date
2941           WA_F_02_DEBIT-VALUT = sy-datum  .
2942   * Txt
2943           WA_F_02_DEBIT-SGTXT = 'line item text vendor' .
2944
2945   *** Determine Split_Amount= ZAMTPCSTOTAL x  KPR**/100, COMPNY_PERNR, COST_CTR &  WBS_ELE
2946   ***************************************************************************
2947           select single * from PA0027 into WA_PA0027
2948              where PERNR = WA_9920_PAY_SEL-PERNR
2949                  and SUBTY = '01'
2950                  and BEGDA =< WA_9920_PAY_SEL-ZDATE_FROM
2951                  AND ENDDA => WA_9920_PAY_SEL-ZDATE_FROM.
2952
2953   **WA_PA0027
2954   ***********
2955   *  PERNR                                      00023733
2956   *SUBTY                                      01
2957   *SPRPS
2958   *ENDDA                                      99991231
2959   *BEGDA                                      20100101
2960   *SEQNR                                      000
2961   *AEDTM                                      20101115
2962   *UNAME                                      CHR_SAHA
2963   *
2964   *KSTAR                                      01
2965   *KBU01                                      MUM
2966   *KGB01                                      FB
2967   *KST01
2968   *KPR01                                      20.00
2969   *KBU02                                      MUM
2970   *KGB02                                      FB
2971   *KST02
2972   *KPR02                                      80.00
2973   *... till KPR25
2974
2975   *PSP01        NUMC 8                        00000560, apply CONVERSION_EXIT_ABPSP_OUTPUT
2976   *PSP02                                      00000561
2977   *PSP03                                      00000564
2978   *PSP04                                      00000000
2979   *PSP05                                      00000000
2980   *... till PSP25
2981
2982   *** calculate Split amount , Comp code: KBU01..KBU25 ,  WBS ele: PSP01..PSP25 or Cost ctr: KST01..KST25,
2983   * as per percentage  WA_PA0027-KPR01 to WA_PA0027-KPR25
2984
2985           count = 1.
2986           do 25 times.
2987             clear count_c.
2988             move count to count_c.
2989             SHIFT count_c RIGHT DELETING TRAILING SPACE.
2990             OVERLAY count_c WITH '00'.
2991
2992             concatenate'WA_PA0027-KPR' count_c into str_kpr.      " cost %age
2993             concatenate'WA_PA0027-KBU' count_c into str_comp.     " Comp.
2994             concatenate 'WA_PA0027-PSP' count_c into str_wbs_ele. " wbs ele
2995             concatenate 'WA_PA0027-KST' count_c into str_cost_ctr. " cost ctr
2996
2997             ASSIGN (str_kpr) to <FS_KPR> .
2998             ASSIGN (str_comp) to <FS_COMPNY_PERNR> .
2999             ASSIGN (str_wbs_ele) to <FS_WBS_ELE> .
3000             ASSIGN (str_cost_ctr) to <FS_COST_CTR> .
3001
3002             if <FS_KPR> is not INITIAL.
3003
3004               clear: WA_F_02_DEBIT-COMPNY_PERNR, WA_F_02_DEBIT-SPLIT_AMT, WA_F_02_DEBIT-WBS_ELE, WA_F_02_DEBIT-COST_CTR.
3005   *COMPNY_PERNR; Company of the pernr in that period
3006               WA_F_02_DEBIT-COMPNY_PERNR = <FS_COMPNY_PERNR>.
3007   * Split Amt
3008               WA_F_02_DEBIT-SPLIT_AMT = WA_F_02_DEBIT-ZAMTPCSTOTAL * <FS_KPR> / 100.
3009   ** WA_PA0027 will have either WBS elements or cost centers.
3010   *   WBS ELE:  WA_PA0027-PSP01(00000560) converted to WA_F_02_DEBIT-WBS_ELE(WO.00S.MUMSW.0022D)
3011               if <FS_WBS_ELE> is not INITIAL.
3012                 CALL FUNCTION 'CONVERSION_EXIT_ABPSP_OUTPUT'
3013                   EXPORTING
3014                     INPUT  = <FS_WBS_ELE>
3015                   IMPORTING
3016                     OUTPUT = WA_F_02_DEBIT-WBS_ELE.
3017   *COST CTR:  WA_PA0027-KST01
3018               elseif <FS_COST_CTR> is not INITIAL.
3019   *Begin RD1K984216 CAB_ALOK ZHRHOSP chng:Cost Ctr,foregrnd mode etc. - CR 30008840
3020   *              WA_F_02_DEBIT-COST_CTR = <FS_COST_CTR> .
3021
3022                 data: WA_CSKS type CSKS.
3023   *      Check: Cost Ctr is valid as on date.
3024                 clear WA_CSKS.
3025                 SELECT *
3026    FROM CSKS INTO WA_CSKS UP TO 1 ROWS WHERE KOSTL = <FS_COST_CTR> AND DATAB =< SY-DATUM AND DATBI >= SY-DATUM AND BKZKP = ''
3027    ORDER BY PRIMARY KEY .
3028    ENDSELECT.     " X = Cost ctr Blocked
3029                 if WA_CSKS-KOSTL is not INITIAL.  " Cost Ctr is valid as on date
3030                   WA_F_02_DEBIT-COST_CTR = WA_CSKS-KOSTL .
3031                 else.     " Cost Ctr is invalid as on date, Get dominant cost ctr
3032
3033                   data: L_GSBER(2),
3034                         L_BUK(3),
3035                        WA_TKA3G type TKA3G.
3036                   clear: L_BUK, L_GSBER.
3037   *         compute business area
3038                   L_BUK   = <FS_COST_CTR>+0(3).
3039                   L_GSBER = <FS_COST_CTR>+3(2).
3040
3041                   clear WA_TKA3G.
3042                   select single *
3043                     from TKA3G
3044                       into WA_TKA3G
3045                         where BUKRS = L_BUK
3046                           and GSBER = L_GSBER.
3047                   if WA_TKA3G-KOSTL is not INITIAL.  " dominant cost ctr found.
3048                     WA_F_02_DEBIT-COST_CTR = WA_TKA3G-KOSTL.
3049                   endif.
3050                 endif.
3051
3052   *End RD1K984216 CAB_ALOK ZHRHOSP chng:Cost Ctr,foregrnd mode etc. - CR 30008840
3053
3054               endif.
3055   * begin of RD1K977852 CAB_ALOK  CR 30006309: Zero balance problem
3056   *   append WA_F_02_DEBIT to IST_F_02_DEBIT.
3057               append WA_F_02_DEBIT to IST_F_02_DEBIT_TEMP.
3058   * end of RD1K977852 CAB_ALOK  CR 30006309
3059             endif . " <FS_KPR>
3060             count = count + 1.
3061
3062             UNASSIGN <FS_KPR> .
3063             UNASSIGN <FS_COMPNY_PERNR>.
3064             UNASSIGN <FS_WBS_ELE> .
3065             UNASSIGN <FS_COST_CTR> .
3066
3067           enddo.     "//  25 times (split debit line items)
3068   * Begin RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
3069   *        clear: WA_9920_PAY_SEL, WA_F_02_DEBIT.
3070   * End RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
3071
3072
3073   * begin of RD1K977852 CAB_ALOK  CR 30006309: Zero balance problem
3074   *  In few cases, Claim amount and Sum of split amounts have a difference of few paisa,
3075   *  hence Zero balance error during F-02 posting. adjusting this additional
3076   *   amount in the last debit line item.
3077           PERFORM zero_balance tables IST_F_02_DEBIT_TEMP.
3078           append LINES OF IST_F_02_DEBIT_TEMP to IST_F_02_DEBIT.
3079           refresh IST_F_02_DEBIT_TEMP.
3080
3081   * Begin RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
3082   *      endloop. " // end of Debit line-items creation .
3083   * End RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
3084   * end of RD1K977852 CAB_ALOK  CR 30006309
3085
3086   * Begin RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
3087   ****** check limits
3088
3089   *BREAK CAB_ALOK.
3090
3091   *g_user_bukrs
3092   *wa_9920_msg-gjahr
3093   *wa_9920_pay_sel-grpvl
3094   *wa_f_02_debit-glac
3095
3096
3097           types:  begin of ty_limits,
3098                     GRPVL type  PA9920-GRPVL,
3099                     GLAC type  HKONT,
3100                     gjahr type  PA9920-gjahr,
3101                   end of ty_limits.
3102
3103           data: WA_9920_limits type ty_limits.
3104           data: WA_F_02_DEBIT_TMP type TY_F_02_DEBIT.
3105           data: OPER_TYPE(3).
3106           clear WA_9920_limits.
3107           data: diff type zhrhospsanc_utl-utilamt,
3108                 l_taxable type c.
3109
3110           read TABLE IST_F_02_DEBIT INTO WA_F_02_DEBIT_TMP INDEX 1.
3111   *WA_F_02_DEBIT_TMP-GRPVL comapny code of Logged-in user
3112   *WA_F_02_DEBIT_TMP-GLAC  GL A/c of pernr
3113   *Calculate WA_9920_limits-GJAHR
3114
3115           WA_9920_limits-GRPVL = WA_F_02_DEBIT_TMP-GRPVL.
3116
3117   *        CALL FUNCTION 'FKK_FM_GET_FISCAL_YEAR'
3118   *          EXPORTING
3119   *            i_bukrs = WA_9920_limits-GRPVL
3120   *            i_budat = wa_f_02_header-budat
3121   *          IMPORTING
3122   *            e_gjahr = WA_9920_limits-gjahr.   " Fiscal yr
3123           CALL FUNCTION 'GET_CURRENT_YEAR'                    "RD1K988011
3124                        EXPORTING
3125                          BUKRS         = WA_9920_limits-GRPVL
3126                          DATE          = wa_f_02_header-budat
3127                        IMPORTING
3128   *               CURRM        =
3129                          CURRY         = WA_9920_limits-gjahr.
3130   *               PREVM        =
3131   *               PREVY        =
3132           .                                                   "RD1K988011
3133
3134
3135
3136   *New logic given:
3137   *Earlier logic given was that amount sanctioned against each GL will be
3138   *checked against payment belonging to that GL only. Now,
3139   *1. Sanctioned amount in 200301 will be checked against payment in GL
3140   *head 200301 of ZHRHOSP and ZHRNEHOSP only.
3141   *2. Sanctioned amount in 200302 will be checked against payment in GL
3142   *heads 200302, 200307,200308,200309,200317,200318 and 200316(ZHRNEHOSP).
3143
3144           WA_9920_limits-GLAC = WA_F_02_DEBIT-GLAC.
3145
3146           data: major_head type HKONT.
3147   * Begin RD1K992265 CAB_ALOK CR 30010881
3148           if G_BUDAT < '20140401' .
3149   * End RD1K992265 CAB_ALOK CR 30010881
3150             case  WA_F_02_DEBIT-GLAC.
3151
3152               when '200301'.
3153                 major_head = '200301'.
3154
3155   *begin RD1K991981 CAB_ALOK Changes in ZHRHOSP Sanction Process CR : 30010772
3156   *          when '200302' or '200307' or '200308' or '200309' or
3157   *                 '200317' or '200318'.
3158   *            major_head = '200302'.
3159
3160   * Begin RD1K992265 CAB_ALOK CR 30010881
3161   *          when '200302' or '200307' or '200317' or '200318'.
3162   *            if G_BUDAT >= '20140401'.
3163   *              major_head = '200302'.
3164   *            endif.
3165   *
3166   *          when  '200308' or '200309' .
3167   *            if G_BUDAT >= '20140401'.
3168   *              major_head = '200309'.
3169   *            endif.
3170
3171               when '200302' or '200307' or '200308' or '200309' or
3172                      '200317' or '200318'.
3173                 major_head = '200302'.
3174
3175   * End RD1K992265 CAB_ALOK CR 30010881
3176
3177   *end RD1K991981 CAB_ALOK Changes in ZHRHOSP Sanction Process CR : 30010772
3178             endcase.
3179
3180   *=======================
3181   * Begin RD1K992265 CAB_ALOK CR 30010881
3182           else. " G_BUDAT >= '20140401'
3183
3184             case  WA_F_02_DEBIT-GLAC.
3185
3186               when '200301'.
3187                 major_head = '200301'.
3188
3189               when '200302' or '200307' or '200317' or '200318'.
3190                 major_head = '200302'.
3191
3192               when  '200308' or '200309' .
3193                 major_head = '200309'.
3194
3195   *Begin RD1K997486  CAB_ALOK  Medical Vendor pymt for Contingent workers -CR 30012858
3196               when  '200350' .
3197                 major_head = '200350'.
3198   *End RD1K997486   CAB_ALOK  Medical Vendor pymt for Contingent workers -CR 30012858
3199
3200
3201
3202             endcase.
3203
3204   * End RD1K992265 CAB_ALOK CR 30010881
3205           endif.
3206
3207
3208   * for handling GL A/c prefix issue. (add 0000 to GL A/c)
3209           CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
3210             EXPORTING
3211   *           INPUT  = WA_9920_limits-GLAC
3212               INPUT  = major_head
3213             IMPORTING
3214   *           OUTPUT = WA_9920_limits-GLAC   .
3215               OUTPUT = major_head.
3216
3217           CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
3218             EXPORTING
3219               INPUT  = WA_9920_limits-GLAC
3220             IMPORTING
3221               OUTPUT = WA_9920_limits-GLAC.
3222
3223   * exemption to company was inserted later, was causing warning at every line item.
3224   * so now first consolidating for (bukrs, GL A/c, Fiscal year)
3225   * then checking.
3226
3227   *Begin RD1K985070       CAB_ALOK     Wrong values in ZHRHOSPSANC_UTL-DEBUG - CR 30009233
3228   ** Commented
3229   ***    select * from zhrhospsanction into corresponding fields of table ist_zhrhospsanction
3230   ***       where bukrs = WA_9920_limits-GRPVL
3231   ****           and glhead = WA_9920_limits-GLAC
3232   ***           and glhead = major_head
3233   ***           and gjahr = WA_9920_limits-gjahr.
3234   ***
3235   ***
3236   ***
3237   **** calculate  total sanc. amt for ( user_bukrs, pernr's GL A/c, Fiscal year )
3238   ***     clear t_amt.
3239   ***     clear wa_zhrhospsanction.
3240   ***     loop at ist_zhrhospsanction into wa_zhrhospsanction.
3241   ***       t_amt = t_amt + wa_zhrhospsanction-amt.
3242   ***     endloop.
3243   ***
3244   ****This check should be applicable for Fiscal year equal to or greater
3245   ****than 2013.
3246   ***if WA_9920_limits-gjahr => '2013'.
3247   **** This check should be excluded for the company codes in table
3248   ****ZFIHOSPBUKRSEXEM.
3249   ***
3250   ***
3251   ***  clear WA_ZFIHOSPBUKRSEXEM.
3252   ***    select single bukrs          "exempted company code
3253   ***      from ZFIHOSPBUKRSEXEM
3254   ***      into WA_ZFIHOSPBUKRSEXEM-BUKRS
3255   ***      where bukrs = WA_9920_limits-GRPVL.
3256   ****  if WA_ZFIHOSPBUKRSEXEM-BUKRS = ''.
3257   *****instead of skipping all the checks and updation for
3258   **** exempted company codes, give msg and update utilization
3259   **** with -ve values (if any).
3260   ***
3261   ***    if t_amt = 0
3262   ***       AnD WA_ZFIHOSPBUKRSEXEM-BUKRS = ''.. " sanc. amt not maintained
3263   ***          FLAG_MODI_UTIL = 'F'.
3264   ***          message e027(zhr) with WA_9920_limits-GRPVL major_head WA_9920_limits-gjahr. .
3265   ***       else.   " sanc. amt maintained, Calc util amt
3266   ***
3267   ***      clear wa_zhrhospsanc_utl.
3268   ***       select single * from zhrhospsanc_utl
3269   ***         into  wa_zhrhospsanc_utl
3270   ***           where bukrs = WA_9920_limits-GRPVL
3271   ****           and glhead = WA_9920_limits-GLAC
3272   ***           and glhead = major_head
3273   ***           and gjahr = WA_9920_limits-gjahr.
3274   ***
3275   ***
3276   ***
3277   *** calc., irrespective of whether the util record is found or not
3278   ***
3279   ***
3280   ***wa_zhrhospsanc_utl-utilamt = wa_zhrhospsanc_utl-utilamt + wa_9920_pay_sel-zamtpcstotal.
3281   ***
3282   ****Utilisation amount exceeds the sanctioned limit.
3283   ***      if wa_zhrhospsanc_utl-utilamt > t_amt.
3284   ***        if WA_ZFIHOSPBUKRSEXEM-BUKRS = ''.
3285   ***          FLAG_MODI_UTIL = 'F'.
3286   ****          message e023(zhr) with WA_9920_limits-GRPVL WA_9920_limits-GLAC WA_9920_limits-gjahr. .
3287   ***          clear diff.
3288   ***          diff = wa_zhrhospsanc_utl-utilamt - t_amt.
3289   ***          message e023(zhr) with diff WA_9920_limits-GRPVL major_head WA_9920_limits-gjahr. .
3290   ***        else. "exempted comp code
3291   ***          message w066(zhr) with WA_9920_limits-GRPVL major_head WA_9920_limits-gjahr. .
3292   ***        endif.
3293   ***      endif.
3294   ***
3295   ****Utilasation amount reached 80% of sanctioned limit
3296   ***      clear t_amt80.
3297   ***      t_amt80 = t_amt *   8 / 10 .
3298   ***      if wa_zhrhospsanc_utl-utilamt >=  t_amt80
3299   ***        AnD WA_ZFIHOSPBUKRSEXEM-BUKRS = ''..
3300   ***          message i029(zhr) with WA_9920_limits-GRPVL major_head WA_9920_limits-gjahr. .
3301   ***      endif.
3302   ***
3303   ****update/insert Utilizn record, only after BDC success
3304   ***    wa_zhrhospsanc_utl-BUKRS = WA_9920_limits-GRPVL.
3305   ****    wa_zhrhospsanc_utl-GLHEAD = WA_9920_limits-GLAC.
3306   ***    wa_zhrhospsanc_utl-GLHEAD = major_head.
3307   ***    wa_zhrhospsanc_utl-GJAHR =  WA_9920_limits-gjahr.
3308   ****    wa_zhrhospsanc_utl-AMT = t_amt.
3309   ***    wa_zhrhospsanc_utl-BALAMT = t_amt - wa_zhrhospsanc_utl-utilamt.
3310   ***
3311   ***    collect wa_zhrhospsanc_utl into ist_zhrhospsanc_utl.
3312   ***
3313   ***    endif. "// t_amt =< 0 . " sanc. amt not maintained
3314   ***
3315   ****  endif. "// WA_ZFIHOSPBUKRSEXEM-BUKRS = ''.
3316   ***
3317   ***endif.  "// WA_9920_limits-gjahr => '2013'.
3318   *###End comment
3319
3320
3321           CLEAR wa_zhrhospsanc_utl.
3322           wa_zhrhospsanc_utl-utilamt = wa_9920_pay_sel-zamtpcstotal.
3323           wa_zhrhospsanc_utl-BUKRS = WA_9920_limits-GRPVL.
3324           wa_zhrhospsanc_utl-GLHEAD = major_head.
3325           wa_zhrhospsanc_utl-GJAHR =  WA_9920_limits-gjahr.
3326
3327   * Begin RD1K996216  CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
3328           wa_zhrhospsanc_utl-SECCO = G_SECCO.
3329   * End RD1K996216  CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
3330
3331           collect wa_zhrhospsanc_utl into ist_zhrhospsanc_utl.
3332
3333   * End RD1K985070       CAB_ALOK     Wrong values in ZHRHOSPSANC_UTL-DEBUG - CR 30009233
3334           clear: WA_9920_PAY_SEL, WA_F_02_DEBIT.
3335         endloop. " // end of Debit line-items creation .
3336   * End RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
3337
3338
3339   * Begin RD1K985070       CAB_ALOK     Wrong values in ZHRHOSPSANC_UTL-DEBUG - CR 30009233
3340         loop at ist_zhrhospsanc_utl into wa_zhrhospsanc_utl.
3341   *This check should be applicable for Fiscal year equal to or greater
3342   *than 2013.
3343           IF wa_zhrhospsanc_utl-gjahr => '2013'.
3344   * util checks should be excluded for the company codes in table
3345   *ZFIHOSPBUKRSEXEM but util table should be updated for these BUKRS
3346   *even if the balance becomes -ve
3347             clear WA_ZFIHOSPBUKRSEXEM.
3348             select single bukrs          "exempted company code
3349              from ZFIHOSPBUKRSEXEM
3350               into WA_ZFIHOSPBUKRSEXEM-BUKRS
3351                  where bukrs = wa_zhrhospsanc_utl-BUKRS
3352   ** Begin RD1K996216  CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
3353   *                and secco = wa_zhrhospsanc_utl-SECCO
3354   ** End RD1K996216  CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
3355                        .
3356
3357
3358
3359   * calculate  total sanc amt for (bukrs, GL A/c, Fiscal year) from DB
3360             refresh ist_zhrhospsanction.
3361             select * from zhrhospsanction
3362              into corresponding fields of table ist_zhrhospsanction
3363               where bukrs = wa_zhrhospsanc_utl-BUKRS
3364   * Begin RD1K996216  CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
3365                   and secco = wa_zhrhospsanc_utl-SECCO
3366   * End RD1K996216  CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
3367                and glhead = wa_zhrhospsanc_utl-GLHEAD
3368                and gjahr = wa_zhrhospsanc_utl-GJAHR.
3369             clear t_amt. "sanc amt
3370             clear wa_zhrhospsanction.
3371             loop at ist_zhrhospsanction into wa_zhrhospsanction.
3372               t_amt = t_amt + wa_zhrhospsanction-amt.
3373               clear wa_zhrhospsanction.
3374             endloop.
3375
3376   * Get current util amt for (bukrs, GL A/c, Fiscal year ) from DB
3377             data: wa_zhrhospsanc_utl_curr type zhrhospsanc_utl.
3378             clear  wa_zhrhospsanc_utl_curr.
3379             select single * from zhrhospsanc_utl
3380              into  wa_zhrhospsanc_utl_curr
3381               where bukrs = wa_zhrhospsanc_utl-BUKRS
3382   * Begin RD1K996216  CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
3383                and secco = wa_zhrhospsanc_utl-SECCO
3384   * End RD1K996216  CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
3385                and glhead = wa_zhrhospsanc_utl-GLHEAD
3386                and gjahr = wa_zhrhospsanc_utl-GJAHR.
3387
3388   * calculate new util amt = util amt on screen + util amt in db table for (bukrs, GL A/c, Fiscal year )
3389             wa_zhrhospsanc_utl-utilamt = wa_zhrhospsanc_utl-utilamt + wa_zhrhospsanc_utl_curr-utilamt.
3390
3391   **CHECKs
3392   *1. Utilisation amount > the sanctioned limit.
3393             if wa_zhrhospsanc_utl-utilamt > t_amt.
3394               if WA_ZFIHOSPBUKRSEXEM-BUKRS = ''.
3395                 FLAG_MODI_UTIL = 'F'.
3396                 clear diff.
3397                 diff = wa_zhrhospsanc_utl-utilamt - t_amt.
3398   * Begin RD1K996216  CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
3399   *                message e023(zhr) with diff wa_zhrhospsanc_utl-BUKRS wa_zhrhospsanc_utl-GLHEAD wa_zhrhospsanc_utl-GJAHR .
3400   data: L_BUK_SECCO(9).
3401   CONCATENATE  wa_zhrhospsanc_utl-BUKRS '/' wa_zhrhospsanc_utl-SECCO INTO L_BUK_SECCO SEPARATED BY SPACE.
3402                  message e062(zhr) with diff L_BUK_SECCO wa_zhrhospsanc_utl-GLHEAD wa_zhrhospsanc_utl-GJAHR .
3403
3404   * End RD1K996216  CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
3405               else. "exempted comp code
3406   * Begin RD1K996216  CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
3407   *              message w066(zhr) with wa_zhrhospsanc_utl-BUKRS wa_zhrhospsanc_utl-GLHEAD wa_zhrhospsanc_utl-GJAHR .
3408                 message w066(zhr) with wa_zhrhospsanc_utl-BUKRS wa_zhrhospsanc_utl-GLHEAD wa_zhrhospsanc_utl-GJAHR wa_zhrhospsanc_utl-SECCO.
3409   * End RD1K996216  CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
3410
3411               endif.
3412             endif.
3413
3414   *2. Utilasation amount reached 80% of sanctioned limit
3415             clear t_amt80.
3416             t_amt80 = t_amt * 8 / 10 .
3417             if wa_zhrhospsanc_utl-utilamt >=  t_amt80
3418               AnD WA_ZFIHOSPBUKRSEXEM-BUKRS = ''.
3419
3420   * Begin RD1K996216  CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
3421   *            message i029(zhr) with WA_9920_limits-GRPVL major_head WA_9920_limits-gjahr. .
3422               message i029(zhr) with WA_9920_limits-GRPVL major_head WA_9920_limits-gjahr G_SECCO. .
3423
3424   * End RD1K996216  CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
3425             endif.
3426
3427   * calculate new balance for (bukrs, GL A/c, Fiscal year )
3428             wa_zhrhospsanc_utl-BALAMT = t_amt - wa_zhrhospsanc_utl-utilamt.
3429
3430   * modify ist with new util & bal
3431             MODIFY ist_zhrhospsanc_utl FROM wa_zhrhospsanc_utl TRANSPORTING utilamt BALAMT.
3432           ENDIF.
3433         endloop.
3434   *End RD1K985070       CAB_ALOK     Wrong values in ZHRHOSPSANC_UTL-DEBUG - CR 30009233
3435
3436         refresh messtab.
3437
3438   * perform BDC only when util limit is available
3439         if  FLAG_MODI_UTIL = 'T'.
3440   * End RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
3441
3442   * F-02 Posting
3443           PERFORM BDC_F_02 tables  IST_F_02_DEBIT
3444              using TEST_FLAG WA_F_02_HEADER WA_F_02_CREDIT CHANGING bdc_subrc . " using Flag_test
3445         endif.
3446   * End RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
3447
3448
3449
3450
3451   * if BDC is successful in Posting Mode then
3452   * 1. change status of selected records to 'PAID' in IST_9920_PAY and PA9920
3453   * 2. post recovery data, if any, to ZHRMED_EMP_RECOV
3454
3455   * Begin RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
3456   *    if bdc_subrc = 0 and TEST_FLAG = 'P'.
3457
3458         if bdc_subrc = 0 and TEST_FLAG = 'P'
3459                               and FLAG_MODI_UTIL = 'T'.
3460
3461   * End RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
3462
3463
3464   * 1.
3465   *============
3466   **  LOOP AT IST_9920_PAY INTO WA_9920_PAY_SEL WHERE SEL = 'X' AND ZSTATUS = 'UNLOCKED'.
3467   **    l_tabix =   sy-tabix .
3468   **
3469   **    " Modify screen display
3470   **    WA_9920_PAY_SEL-ZSTATUS = 'PAID' .
3471   **    WA_9920_PAY_SEL-MESSAGE = 'Paid' .
3472   **    WA_9920_PAY_SEL-AEDTM = sy-datum.
3473   **    WA_9920_PAY_SEL-UNAME = sy-uname.
3474   **
3475   **    MODIFY  IST_9920_PAY INDEX l_tabix FROM  WA_9920_PAY_SEL .
3476   **    " Modify table PA9920
3477   **    MOVE-CORRESPONDING WA_9920_PAY_SEL to WA_PA9920.
3478   **    WA_PA9920-MANDT = sy-mandt.
3479   **    append WA_PA9920 to IST_PA9920  .
3480   *============*
3481
3482   * Begin RD1K979337 CAB_ALOK Lot status from unlock to Paid ZHRHOSP- CR 30006794
3483   *        data: WA_9920_PAY_SEL1 TYPE TY_PAY,
3484   *              WA_9920_MSG TYPE ZHR_MEDPYMT_9920_MSG.
3485           clear: WA_9920_PAY_SEL1, WA_9920_MSG.
3486   * End RD1K979337 CAB_ALOK Lot status from unlock to Paid ZHRHOSP- CR 30006794
3487
3488   *Begin RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP-paymt reversal
3489   *Get FI Doc. no. (messtab-MSGV1) & comp. code (messtab-MSGV2) from Messtab
3490           READ TABLE messtab WITH KEY TCODE ='FB01'
3491                                     DYNAME = 'SAPMF05A'
3492                                     DYNUMB = '0701'
3493                                     MSGTYP = 'S'
3494                                     MSGSPRA = 'E'
3495                                     MSGID   = 'F5'
3496                                     MSGNR = '312'
3497                                       INTO wa_messtab.
3498           if sy-subrc <> 0.
3499             READ TABLE messtab WITH KEY TCODE ='FB01'
3500                                       DYNAME = 'SAPMF05A'
3501                                       DYNUMB = '0700'
3502                                       MSGTYP = 'S'
3503                                       MSGSPRA = 'E'
3504                                       MSGID   = 'F5'
3505                                       MSGNR = '312'
3506                                         INTO wa_messtab.
3507           endif.
3508   *End RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
3509
3510           LOOP AT IST_9920_PAY INTO WA_9920_PAY_SEL1 WHERE SEL = 'X' AND ZSTATUS = 'UNLOCKED'.
3511             l_tabix =   sy-tabix .
3512
3513   ****
3514             select COUNT(*)
3515               FROM  ZHRMED_EMP_RECOV
3516               into l_bvorg
3517               where CNTER = WA_9920_PAY_SEL1-CNTER.
3518
3519
3520
3521             MOVE-CORRESPONDING WA_9920_PAY_SEL1 to WA_9920_MSG.
3522
3523   *Begin of <RD1K994929> cab_pareek  17.10.2014
3524             if WA_9920_PAY_SEL1-taxable = 'N'.
3525               WA_9920_MSG-znontax = 'X'.
3526               clear WA_9920_MSG-ztax.
3527             else.
3528               clear WA_9920_MSG-znontax.
3529               WA_9920_MSG-ztax  = 'X'.
3530             endif.
3531
3532   *End of <RD1K994929> cab_pareek  17.10.2014
3533   *    WA_9920_MSG-SPRPS = '' .  "to be retained as ''
3534
3535   *Begin RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP:dual check, paymt reversal
3536             data: SAVE_ZSTATUS TYPE PA9920-ZSTATUS.
3537   *          WA_9920_MSG-ZSTATUS = 'PAID' .
3538             SAVE_ZSTATUS = WA_9920_MSG-ZSTATUS. "Value: 'UNLOCKED' or 'REVERSED'
3539             WA_9920_MSG-ZSTATUS = 'PAID' .
3540
3541             WA_9920_MSG-PAID_BY_PERNR = G_USER_PERNR .
3542             WA_9920_MSG-PAID_BY_LEVEL = G_USER_PERSK .
3543
3544             WA_9920_MSG-BELNR = wa_messtab-MSGV1.  " FI Doc. no.
3545             WA_9920_MSG-BUKRS = wa_messtab-MSGV2.  "comp. code
3546
3547
3548             DATA: L_BUDAT1 type BUDAT,
3549                   L_BUKRS1 type BUKRS.
3550             MOVE WA_F_02_HEADER-BUDAT TO L_BUDAT1.
3551             MOVE wa_messtab-MSGV2 TO L_BUKRS1.
3552   *          CALL FUNCTION 'FKK_FM_GET_FISCAL_YEAR'
3553   *            EXPORTING
3554   *              I_BUKRS = L_BUKRS1
3555   *              I_BUDAT = L_BUDAT1
3556   *            IMPORTING
3557   *              E_GJAHR = WA_9920_MSG-GJAHR.   " Fiscal yr
3558             CALL FUNCTION 'GET_CURRENT_YEAR'                  "RD1K988011
3559                 EXPORTING
3560                   BUKRS         = l_bukrs1
3561                   DATE          = l_budat1
3562                 IMPORTING
3563   *               CURRM        =
3564                   CURRY         = wa_9920_msg-gjahr.
3565   *               PREVM        =
3566   *               PREVY        =
3567             .                                                 "RD1K988011
3568
3569   *end RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
3570   *begin of CR 30006427 CAB_ALOK
3571
3572   *  clear WA_9920_MSG-SPRPS
3573   *          WA_9920_MSG-ZSTATUS = 'UNLOCKED'.   "  'REVERSED'.
3574   *          WA_9920_MSG-STBLG = L_STBLG.
3575   *
3576   *          SAVE_PAID_BY_PERNR = WA_9920_MSG-PAID_BY_PERNR.
3577   *          SAVE_PAID_BY_LEVEL = WA_9920_MSG-PAID_BY_LEVEL.
3578   *          SAVE_BELNR  =  WA_9920_MSG-BELNR.
3579
3580   **          SAVE_BUKRS  =  WA_9920_MSG-BUKRS.
3581   *          SAVE_GJAHR  =  WA_9920_MSG-GJAHR.
3582
3583   *          SAVE_CHECKED_BY_PERNR  =  WA_9920_MSG-CHECKED_BY_PERNR.
3584   *          SAVE_CHECKED_BY_LEVEL  =  WA_9920_MSG-CHECKED_BY_LEVEL.
3585             CONCATENATE  WA_9920_MSG-ZREMARKS ':' l_bvorg into WA_ZHRMED_EMP_RECOV-RECOVERY_TYPE.
3586   *
3587   *  WA_9920_MSG-ZSTATUS = 'REVERSED'.
3588   *
3589   *end of CR 30006427  CAB_ALOK
3590
3591   * Begin RD1K979337 CAB_ALOK Lot status from unlock to Paid ZHRHOSP- CR 30006794
3592   ****Begin RD1K976756  CAB_ALOK : HR infotype update thro' RFC
3593   ****    CALL FUNCTION 'ZHR_MED_PYMT_UPDATE9920_MSG'
3594   **          CALL FUNCTION 'ZHR_MED_PYMT_UPDATE9920_MSG' DESTINATION 'MMREQ_ASSETNO_CR_RFC'
3595   ***End RD1K976756  CAB_ALOK
3596   **             EXPORTING
3597   **              OPERATION_TYPE = 'MOD'       "OPERATION of HR_INFOTYPE_OPERATION
3598   **              LOCK_INDICATOR = ' '
3599   **            CHANGING
3600   **              WA_9920_MSG    = WA_9920_MSG.
3601
3602   * functionality of ZHR_MED_PYMT_UPDATE9920_MSG now trifurcated into separate
3603   * FMs (LOCK, UPDATE, UNLOCK) for Payment process
3604             CALL FUNCTION 'ZHR_MED_PYMT_INFO_OPER_9920' DESTINATION 'MMREQ_ASSETNO_CR_RFC'
3605               EXPORTING
3606                 OPERATION_TYPE = 'MOD'       "OPERATION of HR_INFOTYPE_OPERATION
3607                 LOCK_INDICATOR = ' '
3608               CHANGING
3609                 WA_9920_MSG    = WA_9920_MSG.
3610   * End RD1K979337 CAB_ALOK Lot status from unlock to Paid ZHRHOSP- CR 30006794
3611
3612             if WA_9920_MSG-ERROR_FLAG = '1'. "if update Operation failed, then reset the status & other data to original.
3613
3614   *Begin RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP:dual check, Paymt reversal
3615   *            WA_9920_MSG-ZSTATUS = 'UNLOCKED' .
3616               WA_9920_MSG-ZSTATUS = SAVE_ZSTATUS. "Value: 'UNLOCKED' or 'REVERSED'
3617               clear: WA_9920_MSG-PAID_BY_PERNR,
3618                      WA_9920_MSG-PAID_BY_LEVEL.
3619
3620               clear: WA_9920_MSG-BELNR,
3621                      WA_9920_MSG-BUKRS,
3622                      WA_9920_MSG-GJAHR.
3623   *end RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
3624
3625   * Begin RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
3626             else. " Infotype oper successful, update utilizn tables
3627               if WA_9920_limits-gjahr => '2013'.
3628                 modify zhrhospsanc_utl from TABLE ist_zhrhospsanc_utl.
3629                 commit work.
3630                 refresh  ist_zhrhospsanc_utl.
3631               endif.  "// WA_9920_limits-gjahr => '2013'.
3632   ** following block commented by Alok
3633   ****
3634   *****    CR 30008930  chages by cab_swetha , specs by cfi_mallik
3635   ****        Else.
3636   ****       " Else statement added .. if payment is successful  tables zhrhospsanction
3637   ****      "       & zhrhospsanc_utl will get updated .
3638   ****        CLEAR: l_persk, l_persg, L_GLAC .
3639   ****        SELECT SINGLE persk persg           " bukrs
3640   ****              FROM pa0001
3641   ****              INTO (l_persk, l_persg)       " , L_BUKRS
3642   ****                WHERE pernr = WA_9920_PAY_SEL1-PERNR
3643   ****                 AND begda =< sy-datum
3644   ****                 AND endda >= sy-datum.
3645   ****
3646   ****        if sy-subrc = 0.
3647   ****          if   l_persg = '2'
3648   ****            or l_persg = 'B' .    " Retd. Employee
3649   ****
3650   ****            if WA_9920_PAY_SEL1-SUBTY = '05'.
3651   ****              L_GLAC = '0000200301'.
3652   ****            elseif ( WA_9920_PAY_SEL1-SUBTY = '03' or WA_9920_PAY_SEL1-SUBTY = '06' ).
3653   ****              L_GLAC = '0000200308'.
3654   ****            elseif WA_9920_PAY_SEL1-SUBTY = '04'.
3655   ****              L_GLAC = '0000200309'.
3656   ****            endif.
3657   ****
3658   ****          elseif l_persg = '1' " Activ. Employee (Officer + Staff)
3659   ****              or l_persg = '7'
3660   ****              or l_persg = '8'
3661   ****              or l_persg = '9'
3662   ****              or l_persg = 'A'
3663   ****              or l_persg = 'G'
3664   ****              or l_persg = 'S'.
3665   ****            " now determine whether Officer or Staff
3666   ****            if   l_persk = 'C'    " => officer
3667   ****              or l_persk = 'D'
3668   ****              or l_persk = 'E0'
3669   ****              or l_persk = 'E1'
3670   ****              or l_persk = 'E2'
3671   ****              or l_persk = 'E3'
3672   ****              or l_persk = 'E4'
3673   ****              or l_persk = 'E5'
3674   ****              or l_persk = 'E6'
3675   ****              or l_persk = 'E7'
3676   ****              or l_persk = 'E8'
3677   ****              or l_persk = 'E9'
3678   ****              or l_persk = 'GT'.
3679   ****
3680   ****              if WA_9920_PAY_SEL1-SUBTY = '05'.
3681   ****                L_GLAC = '0000200301'.
3682   ****              elseif ( WA_9920_PAY_SEL1-SUBTY = '03' or WA_9920_PAY_SEL1-SUBTY = '06' ).
3683   ****                L_GLAC = '0000200307'.
3684   ****              elseif WA_9920_PAY_SEL1-SUBTY = '04'.
3685   ****                L_GLAC = '0000200302'.
3686   ****              endif.    "//officer
3687   ****
3688   ****            elseif l_persk = 'A1'    " => Staff
3689   ****                or l_persk = 'A2'
3690   ****                or l_persk = 'A3'
3691   ****                or l_persk = 'A4'
3692   ****                or l_persk = 'S1'
3693   ****                or l_persk = 'S2'
3694   ****                or l_persk = 'S3'
3695   ****                or l_persk = 'S4'
3696   ****                or l_persk = 'TC'
3697   ****                or l_persk = 'W1'
3698   ****                or l_persk = 'W2'
3699   ****                or l_persk = 'W3'
3700   ****                or l_persk = 'W4'
3701   ****                or l_persk = 'W5'
3702   ****                or l_persk = 'W6'
3703   ****                or l_persk = 'W7'.
3704   ****
3705   ****              if WA_9920_PAY_SEL1-SUBTY = '05'.
3706   ****                L_GLAC = '0000200301'.
3707   ****              elseif ( WA_9920_PAY_SEL1-SUBTY = '03' or WA_9920_PAY_SEL1-SUBTY = '06' ).
3708   ****                L_GLAC = '0000200318'.
3709   ****              elseif WA_9920_PAY_SEL1-SUBTY = '04'.
3710   ****                L_GLAC = '0000200317'.
3711   ****              endif.
3712   ****            endif. "//staff
3713   ****          elseif l_persg = 'C'.
3714   ****
3715   ****            if l_persk = 'C1'    " => Contingent worker
3716   ****                 or l_persk = 'C2'
3717   ****                 or l_persk = 'C3'.
3718   ****              L_GLAC = '0000200350'.
3719   ****            endif.
3720   ****
3721   ****          endif.
3722   ****        endif. "sy-subrc  " // GL Account logic.
3723   ****
3724   ****
3725   ****
3726   *****       CALL FUNCTION 'GM_GET_FISCAL_YEAR'
3727   *****        EXPORTING
3728   *****          I_DATE    = WA_9920_MSG-GJAHR "G_BUDAT
3729   *****          i_fyv     = 'V3'
3730   *****        IMPORTING
3731   *****          E_FY      = L_FISCAL_YEAR .
3732   ****   L_FISCAL_YEAR = WA_9920_MSG-GJAHR .
3733   ****
3734   ****    SELECT SINGLE BUKRS FROM PA0001 INTO L_BUKRS WHERE pernr = sy-uname
3735   ****        and begda <= sy-datum and endda >= sy-datum .
3736   ****
3737   ****    Refresh ist_zhrhospsanction.
3738   ****    Select * from zhrhospsanction into corresponding fields of table ist_zhrhospsanction
3739   ****       where BUKRS = L_BUKRS and GLHEAD = L_GLAC
3740   ****           and GJAHR = L_FISCAL_YEAR.
3741   ****     Clear t_amt.
3742   ****      Loop at ist_zhrhospsanction into wa_zhrhospsanction.
3743   ****        t_amt = t_amt + wa_zhrhospsanction-amt.
3744   ****      Endloop.
3745   ****
3746   ****
3747   ****    select single * from zhrhospsanc_utl into  wa_zhrhospsanc_utl
3748   ****         where BUKRS = L_BUKRS and GLHEAD = L_GLAC
3749   ****           and GJAHR = L_FISCAL_YEAR.
3750   ****      If sy-subrc = 0.
3751   ****        wa_zhrhospsanc_utl-utilamt = wa_zhrhospsanc_utl-utilamt + WA_9920_PAY_SEL1-ZAMTPCSTOTAL.
3752   ****        t_amt1 = t_amt *   8 / 10 .
3753   ****        If wa_zhrhospsanc_utl-utilamt > t_amt .
3754   ****          Message e023(ZHR) .
3755   ****
3756   ****        ElseIf wa_zhrhospsanc_utl-utilamt >=  t_amt1.
3757   ****          Message i025(ZHR) .
3758   ****        Endif.
3759   ****        wa_zhrhospsanc_utl-balamt = t_amt - wa_zhrhospsanc_utl-utilamt.
3760   ****        wa_zhrhospsanc_utl-amt = t_amt.
3761   ****        Modify zhrhospsanc_utl from wa_zhrhospsanc_utl .
3762   ****        Commit Work.
3763   ****      Else.
3764   ****        If t_amt <> 0  and t_amt is not initial.
3765   ****          If WA_9920_PAY_SEL1-ZAMTPCSTOTAL > t_amt.
3766   ****            Message e023(ZHR) .
3767   ****          Else.
3768   ****          wa_zhrhospsanc_utl-BUKRS = L_BUKRS .
3769   ****          wa_zhrhospsanc_utl-GLHEAD = L_GLAC .
3770   ****          wa_zhrhospsanc_utl-GJAHR = L_FISCAL_YEAR.
3771   ****          wa_zhrhospsanc_utl-amt = t_amt.
3772   ****          wa_zhrhospsanc_utl-utilamt = WA_9920_PAY_SEL1-ZAMTPCSTOTAL.
3773   ****          wa_zhrhospsanc_utl-balamt = t_amt - wa_zhrhospsanc_utl-utilamt.
3774   ****          Insert into zhrhospsanc_utl values wa_zhrhospsanc_utl.
3775   ****          Commit Work.
3776   ****          Endif.
3777   ****        Else.
3778   ****          Message e027(ZHR) .
3779   ****        Endif.
3780   ****      Endif.
3781   * End RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
3782
3783             endif.
3784
3785             MOVE-CORRESPONDING WA_9920_MSG to WA_9920_PAY_SEL1.
3786
3787   *MODIFY IST_9920_SUBMIT  FROM  WA_9920_SUBMIT_SEL INDEX l_tabix  TRANSPORTING SPRPR ZSTATUS MESSAGE ERROR_FLAG .
3788   *MODIFY IST_9920_SUBMIT  FROM  WA_9920_SUBMIT_SEL INDEX l_tabix  TRANSPORTING p9920-SPRPR p9920-ZSTATUS MESSAGE ERROR_FLAG .
3789             " No component exists with the name "SPRPR". .
3790             " above stmts not working
3791
3792             MODIFY IST_9920_PAY  FROM  WA_9920_PAY_SEL1 INDEX l_tabix.
3793             MOVE-CORRESPONDING WA_9920_PAY_SEL1 to WA_PA9920.
3794             l_taxable = WA_9920_PAY_SEL1-taxable.
3795             CLEAR: WA_9920_PAY_SEL1 , WA_9920_MSG.
3796   *============*
3797
3798   * 2.
3799   * ZHRMED_EMP_RECOV
3800   *MANDT  MANDT CLNT  3
3801   *PERNR  PERSNO  NUMC  8
3802   *ZCRDNO CHAR10  CHAR  10
3803   *CNTER  CHAR10  CHAR  10
3804   *SUBTY  SUBTY CHAR  4
3805   *RECOVERY_TYPE  CHAR50 CHAR  50
3806   *
3807   *RECOVERY_AMT CHAR10  CHAR  10
3808   *VENDOR_NAME  CHAR20  CHAR  20
3809   *UPDATE_STATUS  CHAR1 CHAR  1
3810   *REMARKS  CHAR50  CHAR  50
3811   *CREATED_ON DATUM DATS  8
3812   *UPDATED_ON AEDTM DATS  8
3813   *CREATED_BY UNAME CHAR  12
3814   *UPDATED_BY AENAM CHAR  12
3815
3816             " Modify table ZHRMED_EMP_RECOV
3817             WA_PA9920-MANDT = sy-mandt.
3818             if WA_PA9920-ZADV_TKN > 0.  " recovery amt exists
3819
3820               MOVE-CORRESPONDING WA_PA9920 to WA_ZHRMED_EMP_RECOV .
3821
3822               WA_ZHRMED_EMP_RECOV-RECOVERY_AMT = WA_PA9920-ZADV_TKN .
3823               WA_ZHRMED_EMP_RECOV-VENDOR_NAME = WA_PA9920-ZHOSPID .
3824               WA_ZHRMED_EMP_RECOV-UPDATE_STATUS = 'N' .
3825
3826
3827   ***begin of CR 30006427 CAB_ALOK
3828   ***            L_RECOVERY_AMT = -1 * WA_PA9920-ZADV_TKN .
3829               if count is INITIAL.
3830   * WA_ZHRMED_EMP_RECOV-RECOVERY_AMT = -1 * WA_PA9920-ZADV_TKN .
3831   ***end of CR 30006427  CAB_ALOK
3832                 WA_ZHRMED_EMP_RECOV-RECOVERY_TYPE = 'RECOV'.
3833   *begin of CR 30006427 CAB_ALOK
3834               endif.
3835   *            WA_ZHRMED_EMP_RECOV-REMARKS = 'REV'.
3836
3837   *            WA_ZHRMED_EMP_RECOV-VENDOR_NAME = WA_9920_REV_SEL1-ZHOSPID .
3838               concatenate 'Lot:' WA_PA9920-ZLOT_NO INTO WA_ZHRMED_EMP_RECOV-REMARKS. "'REVERSAL'. "
3839               WA_ZHRMED_EMP_RECOV-VENDOR_NAME = WA_PA9920-ZHOSPID .
3840   *end of CR 30006427  CAB_ALOK
3841
3842               WA_ZHRMED_EMP_RECOV-CREATED_ON = sy-datum .
3843               WA_ZHRMED_EMP_RECOV-CREATED_BY = sy-uname  .
3844
3845               append WA_ZHRMED_EMP_RECOV to IST_ZHRMED_EMP_RECOV.
3846             endif. "//WA_PA9920-ZADV_TKN
3847
3848   * Append taxable amount.
3849             WA_PA9920-MANDT = sy-mandt.
3850             if l_taxable = 'Y'.  " if claim is taxable
3851
3852               MOVE-CORRESPONDING WA_PA9920 to WA_ZHRMED_EMP_RECOV .
3853
3854               WA_ZHRMED_EMP_RECOV-RECOVERY_AMT = WA_PA9920-ZAMTPCSTOTAL .
3855               WA_ZHRMED_EMP_RECOV-VENDOR_NAME = WA_PA9920-ZHOSPID .
3856               WA_ZHRMED_EMP_RECOV-UPDATE_STATUS = 'N' .
3857               WA_ZHRMED_EMP_RECOV-RECOVERY_TYPE = 'TAXA'.
3858               concatenate 'Lot:' WA_PA9920-ZLOT_NO INTO WA_ZHRMED_EMP_RECOV-REMARKS. "'REVERSAL'. "
3859               WA_ZHRMED_EMP_RECOV-VENDOR_NAME = WA_PA9920-ZHOSPID .
3860               WA_ZHRMED_EMP_RECOV-CREATED_ON = sy-datum .
3861               WA_ZHRMED_EMP_RECOV-CREATED_BY = sy-uname  .
3862
3863               append WA_ZHRMED_EMP_RECOV to IST_ZHRMED_EMP_RECOV.
3864   *Begin of <RD1K994929>  CAB_PAREEK 17.10.2014
3865             else.
3866               MOVE-CORRESPONDING WA_PA9920 to WA_ZHRMED_EMP_RECOV .
3867
3868               WA_ZHRMED_EMP_RECOV-RECOVERY_AMT = WA_PA9920-ZAMTPCSTOTAL .
3869               WA_ZHRMED_EMP_RECOV-VENDOR_NAME = WA_PA9920-ZHOSPID .
3870               WA_ZHRMED_EMP_RECOV-UPDATE_STATUS = 'N' .
3871               WA_ZHRMED_EMP_RECOV-RECOVERY_TYPE = 'NTAXA'.
3872               concatenate 'Lot:' WA_PA9920-ZLOT_NO INTO WA_ZHRMED_EMP_RECOV-REMARKS. "'REVERSAL'. "
3873               WA_ZHRMED_EMP_RECOV-VENDOR_NAME = WA_PA9920-ZHOSPID .
3874               WA_ZHRMED_EMP_RECOV-CREATED_ON = sy-datum .
3875               WA_ZHRMED_EMP_RECOV-CREATED_BY = sy-uname  .
3876
3877               append WA_ZHRMED_EMP_RECOV to IST_ZHRMED_EMP_RECOV.
3878             endif. "//WA_PA9920-ZADV_TKN
3879   *End of <RD1K994929>  CAB_PAREEK 17.10.2014
3880             CLEAR: WA_9920_PAY_SEL, WA_PA9920, WA_ZHRMED_EMP_RECOV , l_taxable.
3881           ENDLOOP.
3882
3883   *================
3884   **  if IST_PA9920 is NOT INITIAL.
3885   **    MODIFY PA9920  from table IST_PA9920.
3886   **  endif.
3887   *=================*
3888           if IST_ZHRMED_EMP_RECOV is NOT INITIAL.
3889             insert ZHRMED_EMP_RECOV from table IST_ZHRMED_EMP_RECOV.
3890           endif.
3891
3892         endif. "//BDC is successful in Posting Mode
3893
3894   * Begin RD1K979337 CAB_ALOK Lot status from unlock to Paid ZHRHOSP- CR 30006794
3895         " Release all the locked PERNRs of the IST_9920_PAY after BDC (in any mode)
3896         clear l_tabix.
3897         clear: WA_9920_PAY_SEL1, WA_9920_MSG.
3898         LOOP AT IST_9920_PAY INTO WA_9920_PAY_SEL1 WHERE SEL = 'X'.
3899           l_tabix =   sy-tabix .
3900           MOVE-CORRESPONDING WA_9920_PAY_SEL1 to WA_9920_MSG.
3901
3902           CALL FUNCTION 'ZHR_MED_PERNR_UNLOCK' DESTINATION 'MMREQ_ASSETNO_CR_RFC'
3903             CHANGING
3904               WA_9920_MSG = WA_9920_MSG.
3905
3906           MOVE-CORRESPONDING WA_9920_MSG to WA_9920_PAY_SEL1.
3907
3908           MODIFY IST_9920_PAY  FROM  WA_9920_PAY_SEL1 INDEX l_tabix.
3909           CLEAR: WA_9920_PAY_SEL1 , WA_9920_MSG.
3910         ENDLOOP.
3911   * End RD1K979337 CAB_ALOK Lot status from unlock to Paid ZHRHOSP- CR 30006794
3912
3913   *show Popup message
3914         refresh ist_mesg.
3915         cnt = 0.
3916         loop at messtab into wa_messtab.
3917           cnt = cnt + 1.
3918           move wa_messtab-MSGTYP   to ist_mesg-msgty.
3919           move wa_messtab-MSGID     to ist_mesg-msgid.
3920           move wa_messtab-MSGNR to ist_mesg-msgno.
3921           move wa_messtab-MSGV1 to ist_mesg-msgv1.
3922           move wa_messtab-MSGV2 to ist_mesg-msgv2.
3923           move wa_messtab-MSGV3 to ist_mesg-msgv3.
3924           move wa_messtab-MSGV4 to ist_mesg-msgv4.
3925           move cnt to ist_mesg-LINENO.
3926           append ist_mesg.
3927           clear wa_messtab.
3928
3929         endloop.
3930
3931         CALL FUNCTION 'C14Z_MESSAGES_SHOW_AS_POPUP'
3932           TABLES
3933             I_MESSAGE_TAB = ist_mesg.
3934
3935   * in test mode if no error is found, C14Z_MESSAGES doesn't give any msg.
3936   * hence give explicit msg
3937         if BDC_SUBRC = 0 and  TEST_FLAG = 'T'  and IST_MESG[] is initial.
3938           MESSAGE ID 'ZMSG' TYPE 'I' NUMBER '000'
3939              WITH 'Test run successful.' .
3940         endif.
3941
3942       endif.  " //sy-subrc: Atleast one row having status 'unlocked' selected.
3943
3944   * begin RD1K979337 CAB_ALOK Lot status from unlock to Paid ZHRHOSP- CR 30006794
3945     ENDIF. " All pernrs locked
3946   * end RD1K979337 CAB_ALOK Lot status from unlock to Paid ZHRHOSP- CR 30006794
3947
3948   ENDFORM.                                                    " PAY_0605
3949   *&---------------------------------------------------------------------*
3950   *&      Form  BDC_F_02
3951   *&---------------------------------------------------------------------*
3952   *       text
3953   *----------------------------------------------------------------------*
3954   *      -->P_IST_F_02_DEBIT  text
3955   *      -->P_WA_F_02_HEADER  text
3956   *      -->P_WA_F_02_CREDIT  text
3957   *----------------------------------------------------------------------*
3958   FORM BDC_F_02  TABLES   IST_F_02_DEBIT LIKE STRU_F_02_DEBIT
3959                  USING  TEST_FLAG
3960                         WA_F_02_HEADER STRUCTURE STRU_F_02_HEADER
3961                         WA_F_02_CREDIT STRUCTURE STRU_F_02_CREDIT
3962                  CHANGING bdc_subrc.
3963
3964     data: l_mode(1).
3965     data :   WA_F_02_DEBIT TYPE  TY_F_02_DEBIT,
3966              WA_F_02_DEBIT_NEXT TYPE  TY_F_02_DEBIT.
3967
3968     data: l_index  TYPE sy-tabix,
3969           l_lines TYPE sy-tabix,
3970           l_index_next TYPE sy-tabix.
3971
3972     data: tmp_date type DATS.
3973     data: tmp_date_str(8).
3974     data: tmp_amt type string.
3975   * begin RD1K977728 CAB_ALOK CR 30006277
3976     data: tmp_c(1).
3977     tmp_c = ''.
3978   * end RD1K977728 CAB_ALOK CR 30006277
3979     REFRESH : bdcdata , messtab .
3980
3981   ***
3982     perform bdc_dynpro      using 'SAPMF05A' '0100'.
3983     perform bdc_field       using 'BDC_CURSOR'
3984                                   'RF05A-NEWKO'.
3985     perform bdc_field       using 'BDC_OKCODE'
3986                                   '/00'.
3987     clear: tmp_date.
3988     CALL FUNCTION 'ZHR_MED_PYMT_TO_DDMMYYYY'
3989       EXPORTING
3990         YYYYMMDD = WA_F_02_HEADER-BLDAT
3991       IMPORTING
3992         DDMMYYYY = tmp_date.
3993
3994     """"""""
3995     "added by lipsy on 22.09.2015 for simultaneous updation in ims RD1K998594
3996     clear:  tmp_date_update.
3997     tmp_date_update = WA_F_02_HEADER-BLDAT.
3998     "end of addition by lipsy on 22.9.2015 for simultaneous updation in ims RD1K998594
3999     """""""""
4000
4001     perform bdc_field       using 'BKPF-BLDAT'
4002                                    tmp_date  . "WA_F_02_HEADER-BLDAT " '20101126'.
4003     perform bdc_field       using 'BKPF-BLART'
4004                                    WA_F_02_HEADER-BLART. " 'KM'.
4005     perform bdc_field       using 'BKPF-BUKRS'
4006                                   WA_F_02_HEADER-BUKRS . "'DLI'.
4007
4008     clear tmp_date.
4009     CALL FUNCTION 'ZHR_MED_PYMT_TO_DDMMYYYY'
4010       EXPORTING
4011         YYYYMMDD = WA_F_02_HEADER-BUDAT
4012       IMPORTING
4013         DDMMYYYY = tmp_date.
4014
4015     perform bdc_field       using 'BKPF-BUDAT'
4016                                    tmp_date  . "WA_F_02_HEADER-BUDAT  .  "'20101126'
4017   ****perform bdc_field       using 'BKPF-MONAT'
4018   ****                              '7'.
4019     perform bdc_field       using 'BKPF-WAERS'
4020                                   WA_F_02_HEADER-WAERS. "'INR'.
4021     perform bdc_field       using 'BKPF-XBLNR'
4022                                   WA_F_02_HEADER-XBLNR  . "'ref head'.
4023     perform bdc_field       using 'BKPF-BKTXT'
4024                                   WA_F_02_HEADER-BKTXT. "'hospital head text'.
4025   ****perform bdc_field       using 'FS006-DOCID'
4026   ****                              ''.
4027
4028     perform bdc_field       using 'RF05A-NEWBS'
4029                                   '31'.
4030     perform bdc_field       using 'RF05A-NEWKO'
4031                                   WA_F_02_CREDIT-VENDOR .     "'800045'.
4032
4033   *BEGIN RD1K976756  CAB_ALOK
4034   *    PERFORM bdc_dynpro      USING 'SAPMF05A' '0330'.
4035   *    PERFORM bdc_field       USING 'BDC_CURSOR'
4036   *                                  'BSEG-XREF1'.
4037   *    PERFORM bdc_field       USING 'BDC_OKCODE'
4038   *                                  '/00'.
4039   *    PERFORM bdc_field       USING 'BSEG-XREF1'
4040   *                                  '.' .
4041   *END RD1K976756  CAB_ALOK
4042
4043   ***
4044
4045     perform bdc_dynpro      using 'SAPMF05A' '0302'.
4046     perform bdc_field       using 'BDC_CURSOR'
4047                                   'RF05A-NEWBK'.
4048     perform bdc_field       using 'BDC_OKCODE'
4049                                   '=QS'.
4050
4051     clear tmp_amt.
4052     Move WA_F_02_CREDIT-WRBTR to tmp_amt.
4053     perform bdc_field       using 'BSEG-WRBTR'
4054                                  tmp_amt.
4055   ****perform bdc_field       using 'BSEG-MWSKZ'
4056   ****                              '**'.
4057     perform bdc_field       using 'BSEG-SECCO'
4058                                   WA_F_02_CREDIT-SECCO. "'dli'.
4059   ****perform bdc_field       using 'BSEG-ZTERM'
4060   ****                              '0001'.
4061
4062     clear tmp_date.
4063     CALL FUNCTION 'ZHR_MED_PYMT_TO_DDMMYYYY'
4064       EXPORTING
4065         YYYYMMDD = WA_F_02_CREDIT-ZFBDT
4066       IMPORTING
4067         DDMMYYYY = tmp_date.
4068     perform bdc_field       using 'BSEG-ZFBDT'
4069                                   tmp_date . "
4070   ****perform bdc_field       using 'BSEG-ZLSPR'
4071   ****                              'X'.
4072     perform bdc_field       using 'BSEG-KIDNO'
4073                                   WA_F_02_CREDIT-KIDNO. "
4074     perform bdc_field       using 'BSEG-SGTXT'
4075                                   WA_F_02_CREDIT-SGTXT. "'
4076
4077
4078     READ TABLE IST_F_02_DEBIT into WA_F_02_DEBIT index 1.
4079
4080     perform bdc_field       using 'RF05A-NEWBS'
4081                                   '40'.
4082     perform bdc_field       using 'RF05A-NEWKO'
4083                                   WA_F_02_DEBIT-GLAC.         "
4084     perform bdc_field       using 'RF05A-NEWBK'
4085                                   WA_F_02_DEBIT-COMPNY_PERNR . "
4086
4087     data: WA_WITHT type ty_witht.
4088     data: l_tabix type sy-tabix.
4089     data: c_tabix(2).
4090     data: s_tabix(4).
4091     data: S_WT_BASE(22),
4092           S_WT_WITHCD(23).
4093
4094     clear: WA_PAY.
4095     REFRESH : ist_9920_pay_tmp, IST_WITHT.
4096
4097     ist_9920_pay_tmp[] =  ist_9920_pay[].
4098     read table ist_9920_pay_tmp into wa_pay index 1.
4099
4100     select WITHT from LFBW
4101       into CORRESPONDING FIELDS OF TABLE IST_WITHT
4102         where LIFNR = WA_PAY-ZHOSPID
4103              and BUKRS = G_USER_BUKRS
4104   * begin RD1K979096 CAB_ALOK ZHRHOSP - CR 30006712
4105              and WT_SUBJCT = 'X'.
4106   * end RD1K979096 CAB_ALOK ZHRHOSP - CR 30006712
4107
4108     if IST_WITHT[] is not initial.
4109
4110       SORT IST_WITHT BY WITHT ASCENDING.
4111       DELETE ADJACENT DUPLICATES FROM IST_WITHT COMPARING WITHT.
4112       delete IST_WITHT where WITHT CA 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.
4113       read table IST_WITHT into WA_WITHT with key WITHT = G_WITHT.
4114       l_tabix = sy-tabix.
4115
4116       move l_tabix to c_tabix.
4117       SHIFT c_tabix RIGHT DELETING TRAILING SPACE.
4118       OVERLAY c_tabix WITH '00'.
4119       concatenate '(' c_tabix ')' into s_tabix.
4120       CONCATENATE 'WITH_DIALG-WT_BASE' '(' c_tabix ')' into S_WT_BASE.
4121       concatenate 'WITH_ITEM-WT_WITHCD' '(' c_tabix ')' into S_WT_WITHCD.
4122
4123       perform bdc_dynpro      using 'SAPLFWTD' '0100'.
4124       perform bdc_field       using 'BDC_CURSOR'
4125                                      S_WT_BASE.  "
4126       perform bdc_field       using 'BDC_OKCODE'
4127                                     '=GO'.
4128       if WA_F_02_CREDIT-WT_WITHCD is NOT INITIAL.
4129
4130         perform bdc_field       using  S_WT_WITHCD
4131                                        WA_F_02_CREDIT-WT_WITHCD.
4132         if WA_F_02_CREDIT-WT_BASE is NOT INITIAL.
4133           clear tmp_amt.
4134           Move WA_F_02_CREDIT-WT_BASE to tmp_amt.
4135           perform bdc_field       using S_WT_BASE
4136                                       tmp_amt.
4137         endif.
4138       endif.
4139
4140     ENDIF. "/ IST_WITHT[] is not initial.
4141
4142
4143     Describe TABLE IST_F_02_DEBIT LINES l_lines.  "** Dr.**
4144     clear WA_F_02_DEBIT.
4145     loop at IST_F_02_DEBIT into WA_F_02_DEBIT.
4146       l_index = sy-tabix.
4147       perform bdc_dynpro      using 'SAPMF05A' '0300'.
4148       perform bdc_field       using 'BDC_CURSOR'
4149                                     'BSEG-WRBTR'.  "
4150       if l_index < l_lines.
4151         perform bdc_field       using 'BDC_OKCODE'
4152                                        '/00'.       " '=BS'      "'/00'.
4153       else .
4154         perform bdc_field       using 'BDC_OKCODE'
4155                                      '=BS'.       " '=BS'      "'/00'.
4156       endif.
4157
4158       clear tmp_amt.
4159       Move WA_F_02_DEBIT-SPLIT_AMT to tmp_amt.
4160       perform bdc_field       using 'BSEG-WRBTR'
4161                                      tmp_amt. "WA_F_02_DEBIT-SPLIT_AMT. "'5000'.
4162       clear tmp_date.
4163       CALL FUNCTION 'ZHR_MED_PYMT_TO_DDMMYYYY'
4164         EXPORTING
4165           YYYYMMDD = WA_F_02_DEBIT-VALUT
4166         IMPORTING
4167           DDMMYYYY = tmp_date.
4168
4169       perform bdc_field       using 'BSEG-VALUT'
4170                                      tmp_date  . "WA_F_02_DEBIT-VALUT. "'29.10.2010'.
4171       perform bdc_field       using 'BSEG-ZUONR'
4172                                     WA_F_02_DEBIT-PERNR.      "'23733'.
4173       perform bdc_field       using 'BSEG-SGTXT'
4174                                     WA_F_02_DEBIT-SGTXT. "'line item text vendor'.
4175
4176       if l_index < l_lines.
4177         l_index_next = l_index + 1.
4178         read table IST_F_02_DEBIT into WA_F_02_DEBIT_NEXT index l_index_next.
4179         perform bdc_field       using 'RF05A-NEWBS'
4180                                       '40'.
4181         perform bdc_field       using 'RF05A-NEWKO'
4182                                       WA_F_02_DEBIT_NEXT-GLAC. "'200307'.
4183         perform bdc_field       using 'RF05A-NEWBK'
4184                                       WA_F_02_DEBIT_NEXT-COMPNY_PERNR . "'DLI'.
4185
4186       endif.
4187
4188   * begin RD1K977728 CAB_ALOK  CR 30006277
4189       if WA_F_02_HEADER-BUKRS <> WA_F_02_DEBIT-COMPNY_PERNR.
4190         tmp_c  = 'X'.
4191       endif.
4192   * end RD1K977728 CAB_ALOK  CR 30006277
4193
4194   ****perform bdc_field       using 'DKACB-FMORE'      "######## NOT NEEDED
4195   ****                              'X'.
4196
4197       perform bdc_dynpro      using 'SAPLKACB' '0002'.
4198
4199       if  WA_F_02_DEBIT-WBS_ELE is not INITIAL.
4200         perform bdc_field       using 'BDC_CURSOR'
4201                                       'COBL-PS_POSID'.
4202         perform bdc_field       using 'BDC_OKCODE'
4203                                       '=ENTE'.
4204         perform bdc_field       using 'COBL-PS_POSID'
4205                                       WA_F_02_DEBIT-WBS_ELE.
4206   *perform bdc_field       using 'COBL-FIPEX'
4207   *                              '200302'.
4208   *perform bdc_field       using 'COBL-FIPOS'
4209   *                              '200302'.
4210       elseif WA_F_02_DEBIT-COST_CTR is not INITIAL.
4211
4212         perform bdc_field       using 'BDC_CURSOR'
4213                                       'COBL-KOSTL'.
4214         perform bdc_field       using 'BDC_OKCODE'
4215                                       '=ENTE'.
4216         perform bdc_field       using 'COBL-KOSTL'
4217                                       WA_F_02_DEBIT-COST_CTR . "'DLICSGEEXE'.
4218   *perform bdc_field       using 'COBL-FIPEX'
4219   *                              'WELFARE'.
4220   *perform bdc_field       using 'COBL-FIPOS'
4221   *                              'WELFARE'.
4222
4223       endif.
4224
4225     endloop.
4226
4227   * begin RD1K977728 CAB_ALOK - CR 30006277
4228
4229     if tmp_c  = 'X'.
4230
4231       perform bdc_dynpro      using 'SAPMF05A' '0701'.
4232     else .
4233       perform bdc_dynpro      using 'SAPMF05A' '0700'.
4234     endif.
4235     perform bdc_field       using 'BDC_CURSOR'
4236                                   'RF05A-NEWBS'.
4237
4238   * end RD1K977728 CAB_ALOK  - CR 30006277
4239   ***
4240     if TEST_FLAG = 'P'.
4241       perform bdc_field       using 'BDC_OKCODE'
4242                                     '=BU'.
4243     elseif TEST_FLAG = 'T'.
4244       perform bdc_field       using 'BDC_OKCODE'
4245                                     '/EEND'.
4246       perform bdc_dynpro      using 'SAPLSPO1' '0200'.
4247       perform bdc_field       using 'BDC_OKCODE'
4248                                     '=YES'.
4249     endif.
4250
4251   *perform bdc_transaction using 'F-02'.
4252   *perform close_group.
4253   *Begin RD1K984216 CAB_ALOK ZHRHOSP chng:Cost Ctr,foregrnd mode etc. - CR 30008840
4254   *  l_mode = 'N'.
4255     data: WA_ZFI_MED_FOREGRND TYPE ZFI_MED_FOREGRND.
4256     SELECT single *
4257       from ZFI_MED_FOREGRND
4258         INTO WA_ZFI_MED_FOREGRND
4259         WHERE UNAME = SY-UNAME.
4260     if sy-subrc = 0.
4261       l_mode = 'A'.
4262     else.
4263       l_mode = 'N'.
4264     endif.
4265   *end RD1K984216 CAB_ALOK ZHRHOSP chng:Cost Ctr,foregrnd mode etc. - CR 30008840
4266     call transaction 'F-02' using bdcdata mode l_mode messages into messtab.  " 'N', 'E' , 'A', 'P'
4267     bdc_subrc = sy-subrc.
4268
4269   data:        wa_messtab1 type bdcmsgcoll .
4270       READ TABLE messtab WITH KEY  MSGTYP = 'E' INTO wa_messtab1.
4271       if wa_messtab1-MSGTYP = 'E'.
4272           bdc_subrc = 4.
4273       endif.
4274     """""""""""""""""""""
4275       "added by lipsy on 22.09.2015 for simultaneous updation in ims RD1K998594
4276
4277     refresh:itab_bkpf_update[],itab_bseg_update.
4278     clear:wa_bkpf_update,wa_bseg_update.
4279     wait up to 5 seconds.
4280     if WA_F_02_HEADER-BKTXT is not initial.
4281
4282     select * from bkpf
4283     INTO CORRESPONDING FIELDS OF TABLE itab_bkpf_update
4284     WHERE bukrs = WA_F_02_HEADER-BUKRS
4285      and    blart = WA_F_02_HEADER-BLART
4286      and bktxt = WA_F_02_HEADER-BKTXT
4287      and bldat =   tmp_date_update ORDER BY PRIMARY KEY.
4288
4289
4290
4291    if sy-subrc = 0.
4292
4293   READ TABLE  itab_bkpf_update INTO wa_bkpf_update INDEX 1.
4294
4295
4296
4297
4298   if wa_bkpf_update-belnr is NOT INITIAL.
4299
4300     select * from bseg
4301     INTO CORRESPONDING FIELDS OF TABLE itab_bseg_update
4302     WHERE bukrs = WA_F_02_HEADER-BUKRS
4303     and  belnr = wa_bkpf_update-belnr
4304     and  gjahr  = wa_bkpf_update-gjahr
4305     and bschl = '31' ORDER BY PRIMARY KEY.
4306
4307       if sy-subrc = 0.
4308
4309
4310    LOOP at  itab_bseg_update INTO wa_bseg_update.
4311
4312   if    wa_bseg_update-kidno+0(1) = '1' or wa_bseg_update-kidno+0(1) = '4' or wa_bseg_update-kidno+0(1) = '6'
4313
4314       or wa_bseg_update-kidno+0(1) = '8'.
4315
4316    call function 'ZMM_IMS_UPDATE_HOSP'
4317         exporting
4318          V_BELNR = wa_bkpf_update-belnr
4319          V_BUDAT = wa_bkpf_update-budat
4320          V_DMBTR = wa_bseg_update-DMBTR
4321          V_WRBTR = wa_bseg_update-WRBTR
4322          V_WAERS =   wa_bkpf_update-WAERS
4323          V_trackno = wa_bseg_update-kidno.
4324
4325    endif.
4326
4327   endloop.
4328
4329
4330   endif.
4331   endif.
4332   endif.
4333
4334   endif.
4335
4336
4337     "end of addition by lipsy on 22.09.2015 for simultaneous updation in ims RD1K998594
4338
4339     """"""""""""""""""""""""
4340
4341
4342   ENDFORM.                                                    " BDC_F_02
4343   *----------------------------------------------------------------------*
4344   *        Start new screen                                              *
4345   *----------------------------------------------------------------------*
4346   form bdc_dynpro using program dynpro.
4347     clear bdcdata.
4348     bdcdata-program  = program.
4349     bdcdata-dynpro   = dynpro.
4350     bdcdata-dynbegin = 'X'.
4351     append bdcdata.
4352   endform.                    "BDC_DYNPRO
4353
4354   *----------------------------------------------------------------------*
4355   *        Insert field                                                  *
4356   *----------------------------------------------------------------------*
4357   form bdc_field using fnam fval.
4358     clear bdcdata.
4359     bdcdata-fnam = fnam.
4360     bdcdata-fval = fval.
4361     append bdcdata.
4362   endform.                    "BDC_FIELD
4363
4364   *&---------------------------------------------------------------------*
4365   *&      Form  GET_DATA_701
4366   *&---------------------------------------------------------------------*
4367   *       text
4368   *----------------------------------------------------------------------*
4369   *  -->  p1        text
4370   *  <--  p2        text
4371   *----------------------------------------------------------------------*
4372   FORM GET_DATA_701 .
4373     DATA: submit_pernr TYPE pernr_d.
4374     DATA: submit_name TYPE emnam.
4375     DATA: submit_orgeh TYPE orgeh.
4376     DATA: submit_plans TYPE plans.
4377     DATA: submit_persa TYPE persa.
4378     DATA: submit_bukrs TYPE bukrs.
4379
4380
4381   *  PERFORM GETDATA_USER
4382   *       changing submit_pernr submit_name submit_orgeh
4383   *          submit_plans submit_persa submit_bukrs.
4384
4385
4386     PERFORM GETDATA_IST_9920_STATUS tables IST_9920_STATUS using G_USER_BUKRS. "submit_bukrs .
4387
4388   ENDFORM.                    " GET_DATA_701
4389   *&---------------------------------------------------------------------*
4390   *&      Form  GETDATA_IST_9920_STATUS
4391   *&---------------------------------------------------------------------*
4392   *       text
4393   *----------------------------------------------------------------------*
4394   *      -->P_IST_9920_STATUS  text
4395   *      -->P_SUBMIT_BUKRS  text
4396   *----------------------------------------------------------------------*
4397
4398   * Begin RD1K981765 CR: 30007609 CAB_ALOK
4399   *FORM GETDATA_IST_9920_STATUS  TABLES IST_9920_STATUS USING SUBMIT_BUKRS.
4400   FORM GETDATA_IST_9920_STATUS  tables IST_9920_STATUS STRUCTURE IST_9920_STATUS using submit_bukrs.
4401   * End RD1K981765 CR: 30007609 CAB_ALOK
4402
4403     DATA: wa_9920_SUBMIT1 TYPE ty_submit,
4404                 l_tabix  TYPE sy-tabix.
4405
4406     data: R_BEGDA TYPE RANGE OF PA9920-BEGDA WITH HEADER LINE,
4407           R_ZHOSPID TYPE RANGE OF PA9920-ZHOSPID WITH HEADER LINE,
4408           R_PERNR TYPE RANGE OF PA9920-PERNR WITH HEADER LINE,
4409           R_ZLOT_NO TYPE RANGE OF PA9920-ZLOT_NO WITH HEADER LINE,
4410           R_UNAME TYPE RANGE OF PA9920-UNAME WITH HEADER LINE,
4411           R_CNTER TYPE RANGE OF PA9920-CNTER WITH HEADER LINE .
4412
4413
4414   *get rows from PA9920 based on selection screen input (struct: ZPMED_SUBMIT)
4415   * and company code of record = comapny code of current user.
4416
4417
4418   *Put data in range so that 'IN' keyword can be used in SELECT stmt.
4419     clear:  R_BEGDA, R_ZHOSPID, R_PERNR, R_ZLOT_NO,  R_UNAME, R_CNTER.
4420     refresh:  R_BEGDA, R_ZHOSPID, R_PERNR, R_ZLOT_NO,  R_UNAME, R_CNTER.
4421
4422   *Create RANGES
4423     R_BEGDA-SIGN = 'I'.
4424     R_BEGDA-LOW = ZPMED_SUBMIT-BEGDA_LOW.
4425     R_BEGDA-HIGH = ZPMED_SUBMIT-BEGDA_HIGH.
4426     if R_BEGDA-LOW is NOT INITIAL and  R_BEGDA-HIGH is NOT INITIAL.
4427       R_BEGDA-OPTION = 'BT'.
4428     else.
4429       R_BEGDA-OPTION = 'EQ'.
4430     endif.
4431     append R_BEGDA.
4432     if R_BEGDA-LOW is INITIAL and  R_BEGDA-HIGH is INITIAL.
4433       clear: R_BEGDA.
4434       refresh:  R_BEGDA.
4435     endif.
4436
4437
4438     CALL FUNCTION 'ZHR_MED_PYMT_VENDOR_ADD_ZERO'
4439       CHANGING
4440         VENDOR = ZPMED_SUBMIT-ZHOSPID_LOW.
4441
4442     CALL FUNCTION 'ZHR_MED_PYMT_VENDOR_ADD_ZERO'
4443       CHANGING
4444         VENDOR = ZPMED_SUBMIT-ZHOSPID_HIGH.
4445
4446     R_ZHOSPID-SIGN = 'I'.
4447     R_ZHOSPID-LOW = ZPMED_SUBMIT-ZHOSPID_LOW.
4448     R_ZHOSPID-HIGH = ZPMED_SUBMIT-ZHOSPID_HIGH.
4449     if  R_ZHOSPID-LOW is NOT INITIAL and R_ZHOSPID-HIGH is NOT INITIAL.
4450       R_ZHOSPID-OPTION = 'BT'.
4451     else.
4452       R_ZHOSPID-OPTION = 'EQ'.
4453     endif.
4454     append R_ZHOSPID.
4455     if R_ZHOSPID-LOW is INITIAL and  R_ZHOSPID-HIGH  is INITIAL.
4456       clear: R_ZHOSPID.
4457       refresh:  R_ZHOSPID.
4458     endif.
4459
4460
4461     R_PERNR-SIGN = 'I'.
4462     R_PERNR-LOW = ZPMED_SUBMIT-PERNR_LOW.
4463     R_PERNR-HIGH = ZPMED_SUBMIT-PERNR_HIGH.
4464     if R_PERNR-LOW is NOT INITIAL and  R_PERNR-HIGH is NOT INITIAL.
4465       R_PERNR-OPTION = 'BT'.
4466     else.
4467       R_PERNR-OPTION = 'EQ'.
4468     endif.
4469     append R_PERNR.
4470     if R_PERNR-LOW is INITIAL and  R_PERNR-HIGH is INITIAL.
4471       clear: R_PERNR.
4472       refresh:  R_PERNR.
4473     endif.
4474
4475     R_ZLOT_NO-SIGN = 'I'.
4476     R_ZLOT_NO-LOW = ZPMED_SUBMIT-ZLOT_NO_LOW.
4477     R_ZLOT_NO-HIGH = ZPMED_SUBMIT-ZLOT_NO_HIGH.
4478     if R_ZLOT_NO-LOW is NOT INITIAL and  R_ZLOT_NO-HIGH is NOT INITIAL.
4479       R_ZLOT_NO-OPTION = 'BT'.
4480     else.
4481       R_ZLOT_NO-OPTION = 'EQ'.
4482     endif.
4483     append R_ZLOT_NO.
4484     if R_ZLOT_NO-LOW is INITIAL and  R_ZLOT_NO-HIGH is INITIAL.
4485       clear: R_ZLOT_NO.
4486       refresh:  R_ZLOT_NO.
4487     endif.
4488
4489     R_UNAME-SIGN = 'I'.
4490     R_UNAME-LOW = ZPMED_SUBMIT-UNAME_LOW.
4491     R_UNAME-HIGH = ZPMED_SUBMIT-UNAME_HIGH.
4492     if R_UNAME-LOW is NOT INITIAL and  R_UNAME-HIGH is NOT INITIAL.
4493       R_UNAME-OPTION = 'BT'.
4494     else.
4495       R_UNAME-OPTION = 'EQ'.
4496     endif.
4497     append R_UNAME.
4498     if R_UNAME-LOW is INITIAL and  R_UNAME-HIGH is INITIAL.
4499       clear: R_UNAME.
4500       refresh:  R_UNAME.
4501     endif.
4502
4503     R_CNTER-SIGN = 'I'.
4504     R_CNTER-LOW = ZPMED_SUBMIT-CNTER_LOW.
4505     R_CNTER-HIGH = ZPMED_SUBMIT-CNTER_HIGH.
4506     if R_CNTER-LOW is NOT INITIAL and  R_CNTER-HIGH is NOT INITIAL.
4507       R_CNTER-OPTION = 'BT'.
4508     else.
4509       R_CNTER-OPTION = 'EQ'.
4510     endif.
4511     append R_CNTER.
4512     if R_CNTER-LOW is INITIAL and  R_CNTER-HIGH is INITIAL.
4513       clear: R_CNTER.
4514       refresh:  R_CNTER.
4515     endif.
4516
4517     select * from PA9920
4518       into corresponding fields of table IST_9920_STATUS
4519         where BEGDA IN R_BEGDA " as YYYYMMDD
4520           and ZHOSPID IN R_ZHOSPID " as 0000800001, S
4521           and PERNR IN R_PERNR
4522           and ZLOT_NO IN R_ZLOT_NO
4523           and UNAME IN R_UNAME
4524           and CNTER IN R_CNTER
4525           and GRPVL = submit_bukrs
4526           and ( SUBTY = '03' or SUBTY = '04' or SUBTY = '05' or SUBTY = '06' or SUBTY = '07' ) .
4527
4528   * Begin RD1K981765 CR: 30007609 CAB_ALOK
4529     Sort IST_9920_STATUS by CNTER ASCENDING.
4530   * End RD1K981765 CR: 30007609 CAB_ALOK
4531
4532   *begin RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
4533     data: WA_9919 type PA9919,
4534           fname LIKE pa0021-favor,
4535           lname LIKE pa0021-fanam.
4536   *end RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
4537
4538   ** Fill INFTY, serial no.
4539     loop at IST_9920_STATUS into wa_9920_SUBMIT1.
4540       l_tabix = sy-tabix.
4541       wa_9920_SUBMIT1-INFTY = '9920'.
4542       wa_9920_SUBMIT1-serial_no = l_tabix.
4543   *begin RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
4544   * Derive patient's name
4545
4546       clear: WA_9919, fname, lname.
4547       SELECT * FROM PA9919
4548    INTO WA_9919 UP TO 1 ROWS WHERE PERNR = WA_9920_SUBMIT1-PERNR AND ZCRDNO = WA_9920_SUBMIT1-ZCRDNO
4549    ORDER BY PRIMARY KEY .
4550    ENDSELECT.
4551
4552       if WA_9919-subty <> '16'.
4553         SELECT FAVOR FANAM
4554    FROM PA0021 INTO ( FNAME , LNAME ) UP TO 1 ROWS WHERE PERNR = WA_9919-PERNR AND SUBTY = WA_9919-SUBTY AND OBJPS = WA_9919-OBJPS AND BEGDA <= SY-DATUM AND ENDDA >= SY-DATUM
4555    ORDER BY PRIMARY KEY .
4556    ENDSELECT.
4557       elseif WA_9919-subty = '16'.
4558         SELECT ENAME
4559    FROM PA0001 INTO FNAME UP TO 1 ROWS WHERE PERNR = WA_9919-PERNR AND BEGDA <= SY-DATUM AND ENDDA >= SY-DATUM
4560    ORDER BY PRIMARY KEY .
4561    ENDSELECT.
4562       endif.
4563       CONCATENATE fname lname INTO wa_9920_SUBMIT1-patient_name SEPARATED BY space.
4564   *end RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
4565       MODIFY IST_9920_STATUS FROM  WA_9920_SUBMIT1 INDEX l_tabix.
4566     endloop.
4567
4568   *begin RD1K981765 CR: 30007609 CAB_ALOK FS for change in ZHRHOSP
4569     clear G_VENDOR_NAME.
4570     if ZPMED_SUBMIT-ZHOSPID_LOW is not INITIAL
4571        and ZPMED_SUBMIT-ZHOSPID_HIGH is INITIAL.
4572       select single NAME1 from ZHR_MED_VENDORS
4573         into  G_VENDOR_NAME
4574           where BUKRS = P9920-GRPVL
4575             and LIFNR = ZPMED_SUBMIT-ZHOSPID_LOW.
4576     endif.
4577   *end RD1K981765 CR: 30007609 CAB_ALOK FS for change in ZHRHOSP
4578   ENDFORM.                    " GETDATA_IST_9920_STATUS
4579
4580   *----------------------------------------------------------------------*
4581   *   INCLUDE TABLECONTROL_FORMS                                         *
4582   *----------------------------------------------------------------------*
4583
4584   *&---------------------------------------------------------------------*
4585   *&      Form  USER_OK_TC                                               *
4586   *&---------------------------------------------------------------------*
4587   FORM USER_OK_TC_STATUS_REP USING    P_TC_NAME TYPE DYNFNAM
4588                            P_TABLE_NAME
4589                            P_MARK_NAME
4590                   CHANGING P_OK      LIKE SY-UCOMM.
4591
4592   *&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
4593     DATA: L_OK              TYPE SY-UCOMM,
4594           L_OFFSET          TYPE I.
4595   *&SPWIZARD: END OF LOCAL DATA------------------------------------------*
4596
4597   *&SPWIZARD: Table control specific operations                          *
4598   *&SPWIZARD: evaluate TC name and operations                            *
4599     SEARCH P_OK FOR P_TC_NAME.
4600     IF SY-SUBRC <> 0.
4601       EXIT.
4602     ENDIF.
4603     L_OFFSET = STRLEN( P_TC_NAME ) + 1.
4604     L_OK = P_OK+L_OFFSET.
4605   *&SPWIZARD: execute general and TC specific operations                 *
4606     CASE L_OK.
4607   *     WHEN 'INSR'.                      "insert row
4608   *       PERFORM FCODE_INSERT_ROW USING    P_TC_NAME
4609   *                                         P_TABLE_NAME.
4610   *       CLEAR P_OK.
4611   *
4612   *     WHEN 'DELE'.                      "delete row
4613   *       PERFORM FCODE_DELETE_ROW USING    P_TC_NAME
4614   *                                         P_TABLE_NAME
4615   *                                         P_MARK_NAME.
4616   *       CLEAR P_OK.
4617
4618       WHEN 'P--' OR                     "top of list
4619            'P-'  OR                     "previous page
4620            'P+'  OR                     "next page
4621            'P++'.                       "bottom of list
4622         PERFORM COMPUTE_SCROLLING_IN_TC USING P_TC_NAME
4623                                               L_OK.
4624         CLEAR P_OK.
4625   *     WHEN 'L--'.                       "total left
4626   *       PERFORM FCODE_TOTAL_LEFT USING P_TC_NAME.
4627   *
4628   *     WHEN 'L-'.                        "column left
4629   *       PERFORM FCODE_COLUMN_LEFT USING P_TC_NAME.
4630   *
4631   *     WHEN 'R+'.                        "column right
4632   *       PERFORM FCODE_COLUMN_RIGHT USING P_TC_NAME.
4633   *
4634   *     WHEN 'R++'.                       "total right
4635   *       PERFORM FCODE_TOTAL_RIGHT USING P_TC_NAME.
4636   *
4637       WHEN 'MARK'.                      "mark all filled lines
4638         PERFORM FCODE_TC_MARK_LINES USING P_TC_NAME
4639                                           P_TABLE_NAME
4640                                           P_MARK_NAME   .
4641         CLEAR P_OK.
4642
4643       WHEN 'DMRK'.                      "demark all filled lines
4644         PERFORM FCODE_TC_DEMARK_LINES USING P_TC_NAME
4645                                             P_TABLE_NAME
4646                                             P_MARK_NAME .
4647         CLEAR P_OK.
4648
4649   *     WHEN 'SASCEND'   OR
4650   *          'SDESCEND'.                  "sort column
4651   *       PERFORM FCODE_SORT_TC USING P_TC_NAME
4652   *                                   l_ok.
4653   *begin RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
4654   * Report download
4655       WHEN 'DNLD'.
4656         PERFORM DOWNLOAD_REPORT.
4657         CLEAR P_OK.
4658   *end RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
4659     ENDCASE.
4660
4661   ENDFORM.                              " USER_OK_TC
4662
4663   *****&---------------------------------------------------------------------*
4664   *****&      Form  FCODE_INSERT_ROW                                         *
4665   *****&---------------------------------------------------------------------*
4666   **** FORM fcode_insert_row
4667   ****               USING    P_TC_NAME           TYPE DYNFNAM
4668   ****                        P_TABLE_NAME             .
4669   ****
4670   *****&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
4671   ****   DATA L_LINES_NAME       LIKE FELD-NAME.
4672   ****   DATA L_SELLINE          LIKE SY-STEPL.
4673   ****   DATA L_LASTLINE         TYPE I.
4674   ****   DATA L_LINE             TYPE I.
4675   ****   DATA L_TABLE_NAME       LIKE FELD-NAME.
4676   ****   FIELD-SYMBOLS <TC>                 TYPE CXTAB_CONTROL.
4677   ****   FIELD-SYMBOLS <TABLE>              TYPE STANDARD TABLE.
4678   ****   FIELD-SYMBOLS <LINES>              TYPE I.
4679   *****&SPWIZARD: END OF LOCAL DATA------------------------------------------*
4680   ****
4681   ****   ASSIGN (P_TC_NAME) TO <TC>.
4682   ****
4683   *****&SPWIZARD: get the table, which belongs to the tc                     *
4684   ****   CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
4685   ****   ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline
4686   ****
4687   *****&SPWIZARD: get looplines of TableControl                              *
4688   ****   CONCATENATE 'G_' P_TC_NAME '_LINES' INTO L_LINES_NAME.
4689   ****   ASSIGN (L_LINES_NAME) TO <LINES>.
4690   ****
4691   *****&SPWIZARD: get current line                                           *
4692   ****   GET CURSOR LINE L_SELLINE.
4693   ****   IF SY-SUBRC <> 0.                   " append line to table
4694   ****     L_SELLINE = <TC>-LINES + 1.
4695   *****&SPWIZARD: set top line                                               *
4696   ****     IF L_SELLINE > <LINES>.
4697   ****       <TC>-TOP_LINE = L_SELLINE - <LINES> + 1 .
4698   ****     ELSE.
4699   ****       <TC>-TOP_LINE = 1.
4700   ****     ENDIF.
4701   ****   ELSE.                               " insert line into table
4702   ****     L_SELLINE = <TC>-TOP_LINE + L_SELLINE - 1.
4703   ****     L_LASTLINE = <TC>-TOP_LINE + <LINES> - 1.
4704   ****   ENDIF.
4705   *****&SPWIZARD: set new cursor line                                        *
4706   ****   L_LINE = L_SELLINE - <TC>-TOP_LINE + 1.
4707   ****
4708   *****&SPWIZARD: insert initial line                                        *
4709   ****   INSERT INITIAL LINE INTO <TABLE> INDEX L_SELLINE.
4710   ****   <TC>-LINES = <TC>-LINES + 1.
4711   *****&SPWIZARD: set cursor                                                 *
4712   ****   SET CURSOR LINE L_LINE.
4713   ****
4714   **** ENDFORM.                              " FCODE_INSERT_ROW
4715   ****
4716   *****&---------------------------------------------------------------------*
4717   *****&      Form  FCODE_DELETE_ROW                                         *
4718   *****&---------------------------------------------------------------------*
4719   **** FORM fcode_delete_row
4720   ****               USING    P_TC_NAME           TYPE DYNFNAM
4721   ****                        P_TABLE_NAME
4722   ****                        P_MARK_NAME   .
4723   ****
4724   *****&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
4725   ****   DATA L_TABLE_NAME       LIKE FELD-NAME.
4726   ****
4727   ****   FIELD-SYMBOLS <TC>         TYPE cxtab_control.
4728   ****   FIELD-SYMBOLS <TABLE>      TYPE STANDARD TABLE.
4729   ****   FIELD-SYMBOLS <WA>.
4730   ****   FIELD-SYMBOLS <MARK_FIELD>.
4731   *****&SPWIZARD: END OF LOCAL DATA------------------------------------------*
4732   ****
4733   ****   ASSIGN (P_TC_NAME) TO <TC>.
4734   ****
4735   *****&SPWIZARD: get the table, which belongs to the tc                     *
4736   ****   CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
4737   ****   ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline
4738   ****
4739   *****&SPWIZARD: delete marked lines                                        *
4740   ****   DESCRIBE TABLE <TABLE> LINES <TC>-LINES.
4741   ****
4742   ****   LOOP AT <TABLE> ASSIGNING <WA>.
4743   ****
4744   *****&SPWIZARD: access to the component 'FLAG' of the table header         *
4745   ****     ASSIGN COMPONENT P_MARK_NAME OF STRUCTURE <WA> TO <MARK_FIELD>.
4746   ****
4747   ****     IF <MARK_FIELD> = 'X'.
4748   ****       DELETE <TABLE> INDEX SYST-TABIX.
4749   ****       IF SY-SUBRC = 0.
4750   ****         <TC>-LINES = <TC>-LINES - 1.
4751   ****       ENDIF.
4752   ****     ENDIF.
4753   ****   ENDLOOP.
4754   ****
4755   **** ENDFORM.                              " FCODE_DELETE_ROW
4756   ****
4757   *****&---------------------------------------------------------------------*
4758   *****&      Form  COMPUTE_SCROLLING_IN_TC
4759   *****&---------------------------------------------------------------------*
4760   *****       text
4761   *****----------------------------------------------------------------------*
4762   *****      -->P_TC_NAME  name of tablecontrol
4763   *****      -->P_OK       ok code
4764   *****----------------------------------------------------------------------*
4765   **** FORM COMPUTE_SCROLLING_IN_TC USING    P_TC_NAME
4766   ****                                       P_OK.
4767   *****&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
4768   ****   DATA L_TC_NEW_TOP_LINE     TYPE I.
4769   ****   DATA L_TC_NAME             LIKE FELD-NAME.
4770   ****   DATA L_TC_LINES_NAME       LIKE FELD-NAME.
4771   ****   DATA L_TC_FIELD_NAME       LIKE FELD-NAME.
4772   ****
4773   ****   FIELD-SYMBOLS <TC>         TYPE cxtab_control.
4774   ****   FIELD-SYMBOLS <LINES>      TYPE I.
4775   *****&SPWIZARD: END OF LOCAL DATA------------------------------------------*
4776   ****
4777   ****   ASSIGN (P_TC_NAME) TO <TC>.
4778   *****&SPWIZARD: get looplines of TableControl                              *
4779   ****   CONCATENATE 'G_' P_TC_NAME '_LINES' INTO L_TC_LINES_NAME.
4780   ****   ASSIGN (L_TC_LINES_NAME) TO <LINES>.
4781   ****
4782   ****
4783   *****&SPWIZARD: is no line filled?                                         *
4784   ****   IF <TC>-LINES = 0.
4785   *****&SPWIZARD: yes, ...                                                   *
4786   ****     L_TC_NEW_TOP_LINE = 1.
4787   ****   ELSE.
4788   *****&SPWIZARD: no, ...                                                    *
4789   ****     CALL FUNCTION 'SCROLLING_IN_TABLE'
4790   ****          EXPORTING
4791   ****               ENTRY_ACT             = <TC>-TOP_LINE
4792   ****               ENTRY_FROM            = 1
4793   ****               ENTRY_TO              = <TC>-LINES
4794   ****               LAST_PAGE_FULL        = 'X'
4795   ****               LOOPS                 = <LINES>
4796   ****               OK_CODE               = P_OK
4797   ****               OVERLAPPING           = 'X'
4798   ****          IMPORTING
4799   ****               ENTRY_NEW             = L_TC_NEW_TOP_LINE
4800   ****          EXCEPTIONS
4801   *****              NO_ENTRY_OR_PAGE_ACT  = 01
4802   *****              NO_ENTRY_TO           = 02
4803   *****              NO_OK_CODE_OR_PAGE_GO = 03
4804   ****               OTHERS                = 0.
4805   ****   ENDIF.
4806   ****
4807   *****&SPWIZARD: get actual tc and column                                   *
4808   ****   GET CURSOR FIELD L_TC_FIELD_NAME
4809   ****              AREA  L_TC_NAME.
4810   ****
4811   ****   IF SYST-SUBRC = 0.
4812   ****     IF L_TC_NAME = P_TC_NAME.
4813   *****&SPWIZARD: et actual column                                           *
4814   ****       SET CURSOR FIELD L_TC_FIELD_NAME LINE 1.
4815   ****     ENDIF.
4816   ****   ENDIF.
4817   ****
4818   *****&SPWIZARD: set the new top line                                       *
4819   ****   <TC>-TOP_LINE = L_TC_NEW_TOP_LINE.
4820   ****
4821   ****
4822   **** ENDFORM.                              " COMPUTE_SCROLLING_IN_TC
4823   ****
4824   *****&---------------------------------------------------------------------*
4825   *****&      Form  FCODE_TC_MARK_LINES
4826   *****&---------------------------------------------------------------------*
4827   *****       marks all TableControl lines
4828   *****----------------------------------------------------------------------*
4829   *****      -->P_TC_NAME  name of tablecontrol
4830   *****----------------------------------------------------------------------*
4831   ****FORM FCODE_TC_MARK_LINES USING P_TC_NAME
4832   ****                               P_TABLE_NAME
4833   ****                               P_MARK_NAME.
4834   *****&SPWIZARD: EGIN OF LOCAL DATA-----------------------------------------*
4835   ****  DATA L_TABLE_NAME       LIKE FELD-NAME.
4836   ****
4837   ****  FIELD-SYMBOLS <TC>         TYPE cxtab_control.
4838   ****  FIELD-SYMBOLS <TABLE>      TYPE STANDARD TABLE.
4839   ****  FIELD-SYMBOLS <WA>.
4840   ****  FIELD-SYMBOLS <MARK_FIELD>.
4841   *****&SPWIZARD: END OF LOCAL DATA------------------------------------------*
4842   ****
4843   ****  ASSIGN (P_TC_NAME) TO <TC>.
4844   ****
4845   *****&SPWIZARD: get the table, which belongs to the tc                     *
4846   ****   CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
4847   ****   ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline
4848   ****
4849   *****&SPWIZARD: mark all filled lines                                      *
4850   ****  LOOP AT <TABLE> ASSIGNING <WA>.
4851   ****
4852   *****&SPWIZARD: access to the component 'FLAG' of the table header         *
4853   ****     ASSIGN COMPONENT P_MARK_NAME OF STRUCTURE <WA> TO <MARK_FIELD>.
4854   ****
4855   ****     <MARK_FIELD> = 'X'.
4856   ****  ENDLOOP.
4857   ****ENDFORM.                                          "fcode_tc_mark_lines
4858   ****
4859   *****&---------------------------------------------------------------------*
4860   *****&      Form  FCODE_TC_DEMARK_LINES
4861   *****&---------------------------------------------------------------------*
4862   *****       demarks all TableControl lines
4863   *****----------------------------------------------------------------------*
4864   *****      -->P_TC_NAME  name of tablecontrol
4865   *****----------------------------------------------------------------------*
4866   ****FORM FCODE_TC_DEMARK_LINES USING P_TC_NAME
4867   ****                                 P_TABLE_NAME
4868   ****                                 P_MARK_NAME .
4869   *****&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
4870   ****  DATA L_TABLE_NAME       LIKE FELD-NAME.
4871   ****
4872   ****  FIELD-SYMBOLS <TC>         TYPE cxtab_control.
4873   ****  FIELD-SYMBOLS <TABLE>      TYPE STANDARD TABLE.
4874   ****  FIELD-SYMBOLS <WA>.
4875   ****  FIELD-SYMBOLS <MARK_FIELD>.
4876   *****&SPWIZARD: END OF LOCAL DATA------------------------------------------*
4877   ****
4878   ****  ASSIGN (P_TC_NAME) TO <TC>.
4879   ****
4880   *****&SPWIZARD: get the table, which belongs to the tc                     *
4881   ****   CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
4882   ****   ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline
4883   ****
4884   *****&SPWIZARD: demark all filled lines                                    *
4885   ****  LOOP AT <TABLE> ASSIGNING <WA>.
4886   ****
4887   *****&SPWIZARD: access to the component 'FLAG' of the table header         *
4888   ****     ASSIGN COMPONENT P_MARK_NAME OF STRUCTURE <WA> TO <MARK_FIELD>.
4889   ****
4890   ****     <MARK_FIELD> = SPACE.
4891   ****  ENDLOOP.
4892   ****ENDFORM.                                          "fcode_tc_mark_lines
4893   *&---------------------------------------------------------------------*
4894   *&      Form  GET_USER_DATA
4895   *&---------------------------------------------------------------------*
4896   *       text
4897   *----------------------------------------------------------------------*
4898   *  -->  p1        text
4899   *  <--  p2        text
4900   *----------------------------------------------------------------------*
4901   FORM GET_USER_DATA .
4902   *get Data of the Logged-in user
4903   *-------------------------------------------------------------------
4904   *Get PERNR of the user_id.
4905
4906     clear: G_USER_PERNR, G_USER_BUKRS, g_user_werks, g_user_name, g_user_desig .
4907   **  CPF No. (PERNR )
4908   * begin  RD1K977570 CAB_ALOK - CR 30006026
4909   * For Core team members, get pernr data from Core team table
4910   * as communication data is not available for their userid.
4911     select single PERNR
4912       from ZHRCORETEAM_MED
4913        into G_USER_PERNR
4914         where USERID = SY-UNAME.
4915     if sy-subrc = 0.
4916   * set Core_team_ID flag,  pop-up for Company code, Location, Name
4917       G_CORE_TEAM_FLAG = 'X'.
4918       PERFORM POPUP_GET_VALUES..
4919     else.
4920   * find pernr from communication data
4921   * end  RD1K977570 CAB_ALOK - CR 30006026
4922       SELECT PERNR
4923    FROM PA0105 INTO G_USER_PERNR UP TO 1 ROWS WHERE USRID = SY-UNAME AND SUBTY = '0001' AND BEGDA <= SY-DATUM AND ENDDA >= SY-DATUM
4924    ORDER BY PRIMARY KEY .
4925    ENDSELECT.
4926       if sy-subrc <> 0.
4927         MESSAGE ID 'ZMSG' TYPE 'E' NUMBER '000' WITH 'USER ID' sy-uname text-012 .
4928       endif.
4929   * begin  RD1K977570 CAB_ALOK - CR 30006026
4930     endif.
4931   * end  RD1K977570 CAB_ALOK - CR 30006026
4932   ** Company code, Location, Name
4933     select single BUKRS WERKS ENAME
4934       from PA0001
4935       into (G_USER_BUKRS, g_user_werks, g_user_name ) " company code, location, name
4936               where pernr = G_USER_PERNR
4937                  AND begda <=   sy-datum
4938                  AND endda >=  sy-datum.
4939
4940   *  select zhr_med_users table for some authorization for overridinh
4941     SELECT * FROM ZHR_MED_USERS UP TO 1 ROWS
4942    WHERE USERID = SY-UNAME AND
4943    BEGDA LE SY-DATUM AND ENDDA GE SY-DATUM
4944    ORDER BY PRIMARY KEY .
4945    ENDSELECT.
4946     if sy-subrc = 0.
4947       G_USER_BUKRS = ZHR_MED_USERS-bukrs.
4948     endif.
4949
4950     if G_USER_BUKRS is initial.
4951       MESSAGE ID 'ZMSG' TYPE 'E' NUMBER '000' WITH 'Company code of' G_USER_PERNR text-012 .
4952     endif.
4953     if G_USER_WERKS is initial.
4954       MESSAGE ID 'ZMSG' TYPE 'E' NUMBER '000' WITH 'Location of' G_USER_PERNR text-012 .
4955     endif.
4956     if G_USER_NAME is initial.
4957       MESSAGE ID 'ZMSG' TYPE 'E' NUMBER '000' WITH 'Name of' G_USER_PERNR text-012 .
4958     endif.
4959
4960   ***PA9930
4961   **PERNR   = 77783
4962   **  ENDDA
4963   ** BEGDA
4964   *DESIGNO = 304
4965   *R_P_CD = MRP80
4966   *VERSION = 1
4967
4968   ***  ZDESIGNATION_REV
4969   **DESIG_CODE                        304
4970   **R_P_CD                            MRP80
4971   **VERSION                           1
4972   *DESIG_TEXT            Senior Programming Officer
4973
4974     data: L_DESIGNO type PA9930-DESIGNO,
4975             L_R_P_CD type PA9930-R_P_CD,
4976              L_VERSION type PA9930-VERSION.
4977
4978
4979   ** Designation:
4980     SELECT DESIGNO R_P_CD VERSION FROM PA9930
4981    INTO ( L_DESIGNO , L_R_P_CD , L_VERSION ) UP TO 1 ROWS WHERE PERNR = G_USER_PERNR AND BEGDA <= SY-DATUM AND ENDDA >= SY-DATUM
4982    ORDER BY PRIMARY KEY .
4983    ENDSELECT.
4984
4985     select single DESIG_TEXT  from ZDESIGNATION_REV
4986      into G_USER_DESIG
4987               where DESIG_CODE = L_DESIGNO
4988                  AND R_P_CD =   L_R_P_CD
4989                  AND VERSION =  L_VERSION.
4990   *Begin RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
4991   ** Get Employee Subgroup (level E1,E2 etc.)
4992     SELECT SINGLE persk
4993           FROM pa0001
4994           INTO G_USER_PERSK
4995             WHERE pernr = G_USER_PERNR
4996              AND begda =< sy-datum
4997              AND endda >= sy-datum.
4998   *end RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
4999
5000
5001   *  CALL FUNCTION 'HR_GETEMPLOYEEDATA_FROMUSER'  "Very Slow
5002   *     EXPORTING
5003   *      username                        = sy-uname
5004   *      validbegin                      =  sy-datum
5005   **    check_auth                      =  space
5006   *    IMPORTING
5007   *      employeenumber                  = g_user_pernr
5008   *      name                            = g_user_name
5009   *      orgunit                         = g_user_orgeh
5010   *      position                        = g_user_plans
5011   *      personnelarea                   = g_user_persa
5012   *      COMPANYCODE                     = g_user_bukrs
5013   *
5014   *    EXCEPTIONS
5015   *      user_not_found                  = 1
5016   *      countrygrouping_not_found       = 2
5017   *      infty_not_found                 = 3
5018   *      OTHERS                          = 4
5019   *             .
5020   *  IF sy-subrc <> 0.
5021   ** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
5022   **         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
5023   *  ENDIF.
5024
5025   ENDFORM.                    " GET_USER_DATA
5026
5027   *
5028   *&---------------------------------------------------------------------*
5029   *&      Form  GET_DATA_801
5030   *&---------------------------------------------------------------------*
5031   *       text
5032   *----------------------------------------------------------------------*
5033   *  -->  p1        text
5034   *  <--  p2        text
5035   *----------------------------------------------------------------------*
5036   FORM GET_DATA_801 .
5037     PERFORM GETDATA_IST_9920_DELETE tables IST_9920_DELETE using G_USER_BUKRS .
5038
5039   ENDFORM.                    " GET_DATA_801
5040   *&---------------------------------------------------------------------*
5041   *&      Form  GETDATA_IST_9920_DELETE
5042   *&---------------------------------------------------------------------*
5043   *       text
5044   *----------------------------------------------------------------------*
5045   *      -->P_IST_9920_DELETE  text
5046   *      -->P_G_USER_BUKRS  text
5047   *----------------------------------------------------------------------*
5048
5049
5050   * Begin RD1K981765 CR: 30007609 CAB_ALOK
5051   *FORM GETDATA_IST_9920_DELETE  TABLES IST_9920_DELETE USING G_USER_BUKRS.
5052   FORM GETDATA_IST_9920_DELETE  tables IST_9920_DELETE STRUCTURE IST_9920_DELETE using submit_bukrs.
5053   * End RD1K981765 CR: 30007609 CAB_ALOK
5054
5055     DATA: wa_9920_SUBMIT1 TYPE ty_submit,
5056                 l_tabix  TYPE sy-tabix.
5057
5058     data: R_BEGDA TYPE RANGE OF PA9920-BEGDA WITH HEADER LINE,
5059           R_ZHOSPID TYPE RANGE OF PA9920-ZHOSPID WITH HEADER LINE,
5060           R_PERNR TYPE RANGE OF PA9920-PERNR WITH HEADER LINE,
5061           R_ZLOT_NO TYPE RANGE OF PA9920-ZLOT_NO WITH HEADER LINE,
5062           R_UNAME TYPE RANGE OF PA9920-UNAME WITH HEADER LINE,
5063           R_CNTER TYPE RANGE OF PA9920-CNTER WITH HEADER LINE ,
5064           R_ZSTATUS TYPE RANGE OF PA9920-ZSTATUS WITH HEADER LINE .
5065
5066
5067   *get rows from PA9920 based on selection screen input (struct: ZPMED_SUBMIT)
5068   * and company code of record = comapny code of current user
5069   * and status = NEW/REJMO/REJFI.
5070
5071
5072   *Put data in range so that 'IN' keyword can be used in SELECT stmt.
5073     clear:  R_BEGDA, R_ZHOSPID, R_PERNR, R_ZLOT_NO,  R_UNAME, R_CNTER, R_ZSTATUS.
5074     refresh:  R_BEGDA, R_ZHOSPID, R_PERNR, R_ZLOT_NO,  R_UNAME, R_CNTER, R_ZSTATUS.
5075
5076   *Create RANGES
5077     R_BEGDA-SIGN = 'I'.
5078     R_BEGDA-LOW = ZPMED_SUBMIT-BEGDA_LOW.
5079     R_BEGDA-HIGH = ZPMED_SUBMIT-BEGDA_HIGH.
5080     if R_BEGDA-LOW is NOT INITIAL and  R_BEGDA-HIGH is NOT INITIAL.
5081       R_BEGDA-OPTION = 'BT'.
5082     else.
5083       R_BEGDA-OPTION = 'EQ'.
5084     endif.
5085     append R_BEGDA.
5086     if R_BEGDA-LOW is INITIAL and  R_BEGDA-HIGH is INITIAL.
5087       clear: R_BEGDA.
5088       refresh:  R_BEGDA.
5089     endif.
5090
5091
5092     CALL FUNCTION 'ZHR_MED_PYMT_VENDOR_ADD_ZERO'
5093       CHANGING
5094         VENDOR = ZPMED_SUBMIT-ZHOSPID_LOW.
5095
5096     CALL FUNCTION 'ZHR_MED_PYMT_VENDOR_ADD_ZERO'
5097       CHANGING
5098         VENDOR = ZPMED_SUBMIT-ZHOSPID_HIGH.
5099
5100     R_ZHOSPID-SIGN = 'I'.
5101     R_ZHOSPID-LOW = ZPMED_SUBMIT-ZHOSPID_LOW.
5102     R_ZHOSPID-HIGH = ZPMED_SUBMIT-ZHOSPID_HIGH.
5103     if  R_ZHOSPID-LOW is NOT INITIAL and R_ZHOSPID-HIGH is NOT INITIAL.
5104       R_ZHOSPID-OPTION = 'BT'.
5105     else.
5106       R_ZHOSPID-OPTION = 'EQ'.
5107     endif.
5108     append R_ZHOSPID.
5109     if R_ZHOSPID-LOW is INITIAL and  R_ZHOSPID-HIGH  is INITIAL.
5110       clear: R_ZHOSPID.
5111       refresh:  R_ZHOSPID.
5112     endif.
5113
5114
5115     R_PERNR-SIGN = 'I'.
5116     R_PERNR-LOW = ZPMED_SUBMIT-PERNR_LOW.
5117     R_PERNR-HIGH = ZPMED_SUBMIT-PERNR_HIGH.
5118     if R_PERNR-LOW is NOT INITIAL and  R_PERNR-HIGH is NOT INITIAL.
5119       R_PERNR-OPTION = 'BT'.
5120     else.
5121       R_PERNR-OPTION = 'EQ'.
5122     endif.
5123     append R_PERNR.
5124     if R_PERNR-LOW is INITIAL and  R_PERNR-HIGH is INITIAL.
5125       clear: R_PERNR.
5126       refresh:  R_PERNR.
5127     endif.
5128
5129     R_ZLOT_NO-SIGN = 'I'.
5130     R_ZLOT_NO-LOW = ZPMED_SUBMIT-ZLOT_NO_LOW.
5131     R_ZLOT_NO-HIGH = ZPMED_SUBMIT-ZLOT_NO_HIGH.
5132     if R_ZLOT_NO-LOW is NOT INITIAL and  R_ZLOT_NO-HIGH is NOT INITIAL.
5133       R_ZLOT_NO-OPTION = 'BT'.
5134     else.
5135       R_ZLOT_NO-OPTION = 'EQ'.
5136     endif.
5137     append R_ZLOT_NO.
5138     if R_ZLOT_NO-LOW is INITIAL and  R_ZLOT_NO-HIGH is INITIAL.
5139       clear: R_ZLOT_NO.
5140       refresh:  R_ZLOT_NO.
5141     endif.
5142
5143     R_UNAME-SIGN = 'I'.
5144     R_UNAME-LOW = ZPMED_SUBMIT-UNAME_LOW.
5145     R_UNAME-HIGH = ZPMED_SUBMIT-UNAME_HIGH.
5146     if R_UNAME-LOW is NOT INITIAL and  R_UNAME-HIGH is NOT INITIAL.
5147       R_UNAME-OPTION = 'BT'.
5148     else.
5149       R_UNAME-OPTION = 'EQ'.
5150     endif.
5151     append R_UNAME.
5152     if R_UNAME-LOW is INITIAL and  R_UNAME-HIGH is INITIAL.
5153       clear: R_UNAME.
5154       refresh:  R_UNAME.
5155     endif.
5156
5157     R_CNTER-SIGN = 'I'.
5158     R_CNTER-LOW = ZPMED_SUBMIT-CNTER_LOW.
5159     R_CNTER-HIGH = ZPMED_SUBMIT-CNTER_HIGH.
5160     if R_CNTER-LOW is NOT INITIAL and  R_CNTER-HIGH is NOT INITIAL.
5161       R_CNTER-OPTION = 'BT'.
5162     else.
5163       R_CNTER-OPTION = 'EQ'.
5164     endif.
5165     append R_CNTER.
5166     if R_CNTER-LOW is INITIAL and  R_CNTER-HIGH is INITIAL.
5167       clear: R_CNTER.
5168       refresh:  R_CNTER.
5169     endif.
5170
5171     R_ZSTATUS-SIGN = 'I'.
5172     R_ZSTATUS-LOW = ZPMED_SUBMIT-CNTER_LOW.
5173     R_ZSTATUS-HIGH = ZPMED_SUBMIT-CNTER_HIGH.
5174     if R_ZSTATUS-LOW is NOT INITIAL and  R_ZSTATUS-HIGH is NOT INITIAL.
5175       R_ZSTATUS-OPTION = 'BT'.
5176     else.
5177       R_ZSTATUS-OPTION = 'EQ'.
5178     endif.
5179     append R_ZSTATUS.
5180     if R_ZSTATUS-LOW is INITIAL and  R_ZSTATUS-HIGH is INITIAL.
5181       clear: R_ZSTATUS.
5182       refresh:  R_ZSTATUS.
5183     endif.
5184
5185
5186     select * from PA9920
5187       into corresponding fields of table IST_9920_DELETE
5188         where BEGDA IN R_BEGDA " as YYYYMMDD
5189           and ZHOSPID IN R_ZHOSPID " as 0000800001, S
5190           and PERNR IN R_PERNR
5191           and ZLOT_NO IN R_ZLOT_NO
5192           and UNAME IN R_UNAME
5193           and CNTER IN R_CNTER
5194           and ZSTATUS IN R_ZSTATUS
5195           and ( ZSTATUS = 'NEW' or ZSTATUS = 'REJMO' or ZSTATUS = 'REJFI' )
5196           and GRPVL = G_USER_BUKRS
5197           and ( SUBTY = '03' or SUBTY = '04' or SUBTY = '05' or SUBTY = '06' or SUBTY = '07' ) .
5198
5199   * Begin RD1K981765 CR: 30007609 CAB_ALOK
5200     Sort IST_9920_DELETE by CNTER ASCENDING.
5201   * End RD1K981765 CR: 30007609 CAB_ALOK
5202
5203   ** Fill INFTY, serial no.
5204     loop at IST_9920_DELETE into wa_9920_SUBMIT1.
5205       l_tabix = sy-tabix.
5206       wa_9920_SUBMIT1-INFTY = '9920'.
5207       wa_9920_SUBMIT1-serial_no = l_tabix.
5208       MODIFY IST_9920_DELETE FROM  WA_9920_SUBMIT1 INDEX l_tabix.
5209     endloop.
5210
5211
5212   ENDFORM.                    " GETDATA_IST_9920_DELETE
5213
5214   *----------------------------------------------------------------------*
5215   *   INCLUDE TABLECONTROL_FORMS                                         *
5216   *----------------------------------------------------------------------*
5217
5218   *&---------------------------------------------------------------------*
5219   *&      Form  USER_OK_TC_DELETE                                               *
5220   *&---------------------------------------------------------------------*
5221   FORM USER_OK_TC_DELETE USING    P_TC_NAME TYPE DYNFNAM
5222                            P_TABLE_NAME
5223                            P_MARK_NAME
5224                   CHANGING P_OK      LIKE SY-UCOMM.
5225
5226   *&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
5227     DATA: L_OK              TYPE SY-UCOMM,
5228           L_OFFSET          TYPE I.
5229   *&SPWIZARD: END OF LOCAL DATA------------------------------------------*
5230
5231   *&SPWIZARD: Table control specific operations                          *
5232   *&SPWIZARD: evaluate TC name and operations                            *
5233     SEARCH P_OK FOR P_TC_NAME.
5234     IF SY-SUBRC <> 0.
5235       EXIT.
5236     ENDIF.
5237     L_OFFSET = STRLEN( P_TC_NAME ) + 1.
5238     L_OK = P_OK+L_OFFSET.
5239   *&SPWIZARD: execute general and TC specific operations                 *
5240     CASE L_OK.
5241   *     WHEN 'INSR'.                      "insert row
5242   *       PERFORM FCODE_INSERT_ROW USING    P_TC_NAME
5243   *                                         P_TABLE_NAME.
5244   *       CLEAR P_OK.
5245
5246       WHEN 'DELE'.                      "delete row
5247   *       PERFORM FCODE_DELETE_ROW USING    P_TC_NAME
5248   *                                         P_TABLE_NAME
5249   *                                         P_MARK_NAME.
5250         PERFORM DELETE_0805. " on Global IST_9920_DELETE
5251         CLEAR P_OK.
5252
5253       WHEN 'P--' OR                     "top of list
5254            'P-'  OR                     "previous page
5255            'P+'  OR                     "next page
5256            'P++'.                       "bottom of list
5257         PERFORM COMPUTE_SCROLLING_IN_TC USING P_TC_NAME
5258                                               L_OK.
5259         CLEAR P_OK.
5260   *     WHEN 'L--'.                       "total left
5261   *       PERFORM FCODE_TOTAL_LEFT USING P_TC_NAME.
5262   *
5263   *     WHEN 'L-'.                        "column left
5264   *       PERFORM FCODE_COLUMN_LEFT USING P_TC_NAME.
5265   *
5266   *     WHEN 'R+'.                        "column right
5267   *       PERFORM FCODE_COLUMN_RIGHT USING P_TC_NAME.
5268   *
5269   *     WHEN 'R++'.                       "total right
5270   *       PERFORM FCODE_TOTAL_RIGHT USING P_TC_NAME.
5271   *
5272       WHEN 'MARK'.                      "mark all filled lines
5273         PERFORM FCODE_TC_MARK_LINES USING P_TC_NAME
5274                                           P_TABLE_NAME
5275                                           P_MARK_NAME   .
5276         CLEAR P_OK.
5277
5278       WHEN 'DMRK'.                      "demark all filled lines
5279         PERFORM FCODE_TC_DEMARK_LINES USING P_TC_NAME
5280                                             P_TABLE_NAME
5281                                             P_MARK_NAME .
5282         CLEAR P_OK.
5283
5284   *     WHEN 'SASCEND'   OR
5285   *          'SDESCEND'.                  "sort column
5286   *       PERFORM FCODE_SORT_TC USING P_TC_NAME
5287   *                                   l_ok.
5288
5289     ENDCASE.
5290
5291   ENDFORM.                              " USER_OK_TC_DELETE
5292   *&---------------------------------------------------------------------*
5293   *&      Form  DELETE_0805
5294   *&---------------------------------------------------------------------*
5295   *       text
5296   *----------------------------------------------------------------------*
5297   *  -->  p1        text
5298   *  <--  p2        text
5299   *----------------------------------------------------------------------*
5300   FORM DELETE_0805 .
5301     " Operation on IST_9920_PAY
5302     DATA: WA_9920_DELETE_SEL TYPE TY_SUBMIT,
5303           WA_9920_MSG TYPE ZHR_MEDPYMT_9920_MSG,
5304           l_tabix  TYPE sy-tabix.
5305     data: SAVE_ZSTATUS type ZHR_MEDPYMT_9920_MSG-ZSTATUS ,
5306           SAVE_SPRPS type ZHR_MEDPYMT_9920_MSG-SPRPS.
5307
5308     LOOP AT IST_9920_DELETE INTO WA_9920_DELETE_SEL WHERE SEL = 'X' and ( ZSTATUS = 'NEW ' or ZSTATUS = 'REJFI'  or ZSTATUS = 'REJMO' ) .  " ONLY new/rejfi/rejmo in the IST
5309       l_tabix =   sy-tabix .
5310       MOVE-CORRESPONDING WA_9920_DELETE_SEL to WA_9920_MSG.
5311
5312       SAVE_ZSTATUS = WA_9920_MSG-ZSTATUS .
5313       SAVE_SPRPS   = WA_9920_MSG-SPRPS.
5314
5315       WA_9920_MSG-ZSTATUS = 'DELETED'. "to be set to 'DELETED'
5316   *    WA_9920_MSG-SPRPS = 'X' .  "to be retained as 'X' as the record is being deleted
5317   *Begin RD1K976756  CAB_ALOK : HR infotype update thro' RFC
5318   *    CALL FUNCTION 'ZHR_MED_PYMT_UPDATE9920_MSG'
5319       CALL FUNCTION 'ZHR_MED_PYMT_UPDATE9920_MSG' DESTINATION 'MMREQ_ASSETNO_CR_RFC'
5320   *End RD1K976756  CAB_ALOK
5321         EXPORTING
5322           OPERATION_TYPE = 'MOD' "OPERATION of HR_INFOTYPE_OPERATION
5323           LOCK_INDICATOR = 'X'   "current value of lockindicator
5324         CHANGING
5325           WA_9920_MSG    = WA_9920_MSG.
5326       if WA_9920_MSG-ERROR_FLAG = '1'. "if update Operation failed, then set the status back to original
5327   *      WA_9920_MSG-SPRPS = 'X' .
5328         WA_9920_MSG-ZSTATUS = SAVE_ZSTATUS .
5329       endif.
5330       MOVE-CORRESPONDING WA_9920_MSG to WA_9920_DELETE_SEL.
5331
5332   *MODIFY IST_9920_SUBMIT  FROM  WA_9920_SUBMIT_SEL INDEX l_tabix  TRANSPORTING SPRPR ZSTATUS MESSAGE ERROR_FLAG .
5333   *MODIFY IST_9920_SUBMIT  FROM  WA_9920_SUBMIT_SEL INDEX l_tabix  TRANSPORTING p9920-SPRPR p9920-ZSTATUS MESSAGE ERROR_FLAG .
5334       " No component exists with the name "SPRPR". .
5335       " above stmts not working
5336
5337       MODIFY IST_9920_DELETE  FROM  WA_9920_DELETE_SEL INDEX l_tabix.
5338
5339       CLEAR: WA_9920_DELETE_SEL ,
5340              WA_9920_MSG.
5341
5342     ENDLOOP.
5343   ENDFORM.                    " DELETE_0805
5344   *&---------------------------------------------------------------------*
5345   *&      Form  PRINT_LETTER_0901
5346   *&---------------------------------------------------------------------*
5347   *       text
5348   *----------------------------------------------------------------------*
5349   *  -->  p1        text
5350   *  <--  p2        text
5351   *----------------------------------------------------------------------*
5352   FORM PRINT_LETTER_0901 .
5353
5354   * ZMED_PRINT_LETTER
5355
5356     DATA : IST_PRINT TYPE  ZMED_PRINT_LETTER_TT,  "table type
5357            WA_PRINT TYPE ZMED_PRINT_LETTER. " struct
5358     DATA: L_VENDOR_NAME type ZHR_MED_VENDORS-NAME1,
5359           l_tabix type sy-tabix.
5360     data: C_DATE type ztxt10 . "      C_DATE(10).
5361   * begin RD1K978193 CAB_ALOK CR 30006378
5362     data L_TOTAL_PAYMT type ZTOTAL_AMT.
5363   * end RD1K978193 CAB_ALOK CR 30006378
5364   * LotNo.:                  ZPMED_SUBMIT-ZLOT_NO_LOW
5365   * Date:                    sy-datum
5366   * Location:                g_user_werks
5367   * Name of Medical Officer: g_user_name
5368   * ZDESIGNATION:            g_user_desig
5369   * CPF No:                  G_USER_PERNR,
5370   * Comp. Code:              G_USER_BUKRS
5371
5372
5373     CONCATENATE sy-datum+6(2) '.' sy-datum+4(2) '.' sy-datum+0(4) INTO C_DATE .
5374
5375     select * from PA9920
5376         into corresponding fields of table IST_PRINT
5377          where   ZLOT_NO = ZPMED_SUBMIT-ZLOT_NO_LOW
5378             and  ZSTATUS = 'UNLOCKED'
5379             and  GRPVL   = G_USER_BUKRS  " company code of the current user
5380             and ( SUBTY  = '03' or SUBTY = '04' or SUBTY = '05' or SUBTY = '06' or SUBTY = '07' ) .
5381        " subty = '07' added by swetha <RD1K9A00TI> 7 june 2016
5382
5383
5384   * Begin RD1K981765 CR: 30007609 CAB_ALOK
5385     Sort IST_PRINT by CNTER ASCENDING.
5386   * End RD1K981765 CR: 30007609 CAB_ALOK
5387
5388
5389   * Vendor name:
5390   *All the rows of a LOT belong to a single vendor, so deriving it only once.
5391     read table IST_PRINT into WA_PRINT index 1.
5392     SELECT NAME1 FROM ZHR_MED_VENDORS
5393    INTO L_VENDOR_NAME UP TO 1 ROWS WHERE LIFNR = WA_PRINT-ZHOSPID AND BUKRS = G_USER_BUKRS
5394    ORDER BY PRIMARY KEY .
5395    ENDSELECT.
5396
5397
5398
5399     Loop at IST_PRINT into WA_PRINT.
5400   * begin RD1K978193 CAB_ALOK CR 30006378
5401       L_TOTAL_PAYMT = L_TOTAL_PAYMT + WA_PRINT-ZAMTMOTOTAL.
5402   * end RD1K978193 CAB_ALOK CR 30006378
5403       l_tabix = sy-tabix.
5404       WA_PRINT-SRNO = l_tabix.
5405       WA_PRINT-NAME1 = L_VENDOR_NAME.
5406       CONCATENATE WA_PRINT-ZBILL_DATE+6(2) '.' WA_PRINT-ZBILL_DATE+4(2) '.' WA_PRINT-ZBILL_DATE+0(4) INTO WA_PRINT-CBILL_DATE .
5407       if WA_PRINT-SUBTY = '03'.
5408         WA_PRINT-FACILITY_NAME = 'Hospital'.
5409       elseif  WA_PRINT-SUBTY = '04'.
5410         WA_PRINT-FACILITY_NAME = 'Doctor'.
5411       elseif  WA_PRINT-SUBTY = '05'.
5412         WA_PRINT-FACILITY_NAME = 'Pharmacy'.
5413       elseif  WA_PRINT-SUBTY = '06'.
5414         WA_PRINT-FACILITY_NAME = 'Diagnostics'.
5415       endif.
5416
5417       MODIFY IST_PRINT  FROM  WA_PRINT INDEX l_tabix.
5418     endloop. "// IST_PRINT
5419
5420
5421     DATA :   fp_outputparams    TYPE sfpoutputparams,
5422                w_doc_param       TYPE sfpdocparams,"Doc Parameters
5423                fm_name    TYPE rs38l_fnam.
5424     DATA : fp_formoutput TYPE fpformoutput.
5425     DATA : fp_docuparams TYPE sfpdocparams.
5426
5427
5428     TRY.
5429   **To get the generated function module
5430         CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'           "#EC ARGCHECKED
5431           EXPORTING
5432             i_name     = 'ZMED_PAYMENT_ORDER_PRINT'
5433           IMPORTING
5434             e_funcname = fm_name.
5435       CATCH cx_fp_api_repository.
5436       CATCH cx_fp_api_usage.
5437       CATCH cx_fp_api_internal.
5438     ENDTRY.
5439
5440
5441     fp_outputparams-nodialog = ''.
5442     fp_outputparams-preview  = ''.    " launch print preview
5443     fp_outputparams-getpdf = ''.
5444     fp_outputparams-connection = 'ADS'."gc_connection.
5445   *Begin RD1K977852 CAB_ALOK  CR 30006309
5446     fp_outputparams-dest = 'HP01'.
5447   *End RD1K977852 CAB_ALOK CR 30006309
5448     sy-cprog = 'X'.                                         "#EC WRITE_OK
5449
5450     CALL FUNCTION 'FP_JOB_OPEN'
5451       CHANGING
5452         ie_outputparams = fp_outputparams
5453       EXCEPTIONS
5454         cancel          = 1
5455         usage_error     = 2
5456         system_error    = 3
5457         internal_error  = 4
5458         OTHERS          = 5.
5459     IF sy-subrc <> 0.
5460       MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
5461               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
5462     ENDIF.
5463
5464     fp_docuparams-langu = 'E'.
5465     fp_docuparams-country = 'US'.
5466     fp_docuparams-fillable = 'X'.
5467     fp_docuparams-dynamic = 'X'.
5468
5469
5470     CALL FUNCTION fm_name
5471       EXPORTING
5472         /1bcdwb/docparams  = fp_docuparams
5473         IST_PRINT          = IST_PRINT
5474         SF_LOT_NO          = ZPMED_SUBMIT-ZLOT_NO_LOW
5475         SF_DATE            = C_DATE
5476         SF_USER_WERKS      = g_user_werks
5477         SF_USER_NAME       = g_user_name
5478         SF_USER_DESIG      = g_user_desig
5479         SF_TOTAL_PAYMT     = L_TOTAL_PAYMT
5480       IMPORTING
5481         /1bcdwb/formoutput = fp_formoutput
5482       EXCEPTIONS
5483         usage_error        = 1
5484         system_error       = 2
5485         internal_error     = 3
5486         OTHERS             = 4.
5487     IF sy-subrc <> 0.
5488       MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
5489               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
5490     ENDIF.
5491     CALL FUNCTION 'FP_JOB_CLOSE'
5492   * IMPORTING
5493   *   E_RESULT             =
5494      EXCEPTIONS
5495        usage_error          = 1
5496        system_error         = 2
5497        internal_error       = 3
5498        OTHERS               = 4 .
5499     IF sy-subrc <> 0.
5500       MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
5501               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
5502     ENDIF.
5503   *****************
5504   ****************************
5505   *$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
5506   ENDFORM . " PRINT_LETTER_0901 .
5507   *&---------------------------------------------------------------------*
5508   *&      Form  CONAINER_INITIALIZATION
5509   *&---------------------------------------------------------------------*
5510   *       text
5511   *----------------------------------------------------------------------*
5512   *  -->  p1        text
5513   *  <--  p2        text
5514   *----------------------------------------------------------------------*
5515   FORM LOAD_IMAGE .
5516     IF INIT IS INITIAL.
5517   * create the custom container
5518       CREATE OBJECT CONTAINER
5519         EXPORTING
5520           CONTAINER_NAME = 'CONTAINER1'.
5521   * create the picture control
5522       CREATE OBJECT PICTURE
5523         EXPORTING
5524           PARENT = CONTAINER.
5525
5526   * Request an URL from the data provider by exporting the pic_data.
5527       CLEAR URL.
5528
5529       PERFORM LOAD_PIC_FROM_DB CHANGING URL.
5530
5531   * load picture
5532       CALL METHOD PICTURE->LOAD_PICTURE_FROM_URL
5533         EXPORTING
5534           URL = URL.
5535
5536       INIT = 'X'.
5537
5538       CALL METHOD CL_GUI_CFW=>FLUSH
5539         EXCEPTIONS
5540           CNTL_SYSTEM_ERROR = 1
5541           CNTL_ERROR        = 2.
5542       IF SY-SUBRC <> 0.
5543   * error handling
5544       ENDIF.
5545     ENDIF.
5546
5547   ENDFORM.                    " CONAINER_INITIALIZATION
5548
5549   *&---------------------------------------------------------------------*
5550   *&      Form  LOAD_PIC_FROM_DB
5551   *&---------------------------------------------------------------------*
5552   *       text
5553   *----------------------------------------------------------------------*
5554   *      <--P_URL  text
5555   *----------------------------------------------------------------------*
5556   FORM LOAD_PIC_FROM_DB CHANGING P_URL.
5557     DATA QUERY_TABLE LIKE W3QUERY OCCURS 1 WITH HEADER LINE.
5558     DATA HTML_TABLE LIKE W3HTML OCCURS 1.
5559     DATA RETURN_CODE LIKE  W3PARAM-RET_CODE.
5560     DATA CONTENT_TYPE LIKE  W3PARAM-CONT_TYPE.
5561     DATA CONTENT_LENGTH LIKE  W3PARAM-CONT_LEN.
5562     DATA PIC_DATA LIKE W3MIME OCCURS 0.
5563     DATA PIC_SIZE TYPE I.
5564
5565     REFRESH QUERY_TABLE.
5566     QUERY_TABLE-NAME = '_OBJECT_ID'.
5567   *   QUERY_TABLE-VALUE = 'YONGCLOGO1'.
5568     QUERY_TABLE-VALUE = 'YONGCLOGO2'.
5569   *   QUERY_TABLE-VALUE = 'ZLION'.
5570
5571     APPEND QUERY_TABLE.
5572
5573     CALL FUNCTION 'WWW_GET_MIME_OBJECT'
5574       TABLES
5575         QUERY_STRING        = QUERY_TABLE
5576         HTML                = HTML_TABLE
5577         MIME                = PIC_DATA
5578       CHANGING
5579         RETURN_CODE         = RETURN_CODE
5580         CONTENT_TYPE        = CONTENT_TYPE
5581         CONTENT_LENGTH      = CONTENT_LENGTH
5582       EXCEPTIONS
5583         OBJECT_NOT_FOUND    = 1
5584         PARAMETER_NOT_FOUND = 2
5585         OTHERS              = 3.
5586     IF SY-SUBRC = 0.
5587       PIC_SIZE = CONTENT_LENGTH.
5588     ENDIF.
5589
5590     CALL FUNCTION 'DP_CREATE_URL'
5591       EXPORTING
5592         TYPE     = 'image'
5593         SUBTYPE  = CNDP_SAP_TAB_UNKNOWN
5594         SIZE     = PIC_SIZE
5595         LIFETIME = CNDP_LIFETIME_TRANSACTION
5596       TABLES
5597         DATA     = PIC_DATA
5598       CHANGING
5599         URL      = URL
5600       EXCEPTIONS
5601         OTHERS   = 1.
5602
5603   ENDFORM.                    " LOAD_PIC_FROM_DB
5604   *&---------------------------------------------------------------------*
5605   *&      Form  LOCK_UPDATE_UNLOCK_USER_0101
5606   *&---------------------------------------------------------------------*
5607   *       text
5608   *----------------------------------------------------------------------*
5609   *  -->  p1        text
5610   *  <--  p2        text
5611   *----------------------------------------------------------------------*
5612   *Begin RD1K976756  CAB_ALOK : HR infotype update thro' RFC
5613   FORM LOCK_UPDATE_UNLOCK_USER_0101 .
5614
5615     DATA: WA_9920_UNLOCK_SEL TYPE TY_SUBMIT,
5616           WA_9920_MSG TYPE ZHR_MEDPYMT_9920_MSG.
5617     p9920-infty = '9920'.
5618
5619     MOVE-CORRESPONDING P9920 to WA_9920_MSG.
5620
5621
5622     WA_9920_MSG-SPRPS = 'X' .  "New rec to be craeted with lock ind = 'X'
5623     WA_9920_MSG-ZSTATUS = 'NEW' .
5624
5625   *  Taxable / not Taxable Decision
5626     if ZHR_MED_VENDORS-taxable = 'Y'.
5627       WA_9920_MSG-ztax = 'X'.
5628       clear  WA_9920_MSG-ZNONTAX.
5629     elseif ZHR_MED_VENDORS-taxable = 'N'.
5630       WA_9920_MSG-ZNONTAX = 'X'.
5631       clear WA_9920_MSG-ztax.
5632     elseif ZHR_MED_VENDORS-taxable = 'B'.
5633       clear: WA_9920_MSG-ZNONTAX , WA_9920_MSG-ztax.
5634     endif.
5635
5636     if WA_9920_MSG-subty = '07'.
5637       WA_9920_MSG-ZCRDNO = 'Self'.
5638     endif.
5639
5640     CALL FUNCTION 'ZHR_MED_PYMT_UPDATE9920_MSG' DESTINATION 'MMREQ_ASSETNO_CR_RFC'
5641       EXPORTING
5642         OPERATION_TYPE = 'INS'       "OPERATION of HR_INFOTYPE_OPERATION
5643   *     LOCK_INDICATOR = 'X'
5644       CHANGING
5645         WA_9920_MSG    = WA_9920_MSG.
5646
5647     if WA_9920_MSG-ERROR_FLAG = '1'. "if update Operation failed, then reset the status
5648       MESSAGE ID 'ZMSG' TYPE 'S' NUMBER '000'
5649         WITH WA_9920_MSG-MESSAGE.          .
5650     else.
5651       MOVE-CORRESPONDING WA_9920_MSG to p9920.
5652       g_greyoff = 'X'.  " Record has been saved
5653       MESSAGE ID 'ZMSG' TYPE 'S' NUMBER '000'
5654         WITH 'Claim created with submission number ' WA_9920_MSG-cnter .
5655     endif.
5656
5657   ENDFORM.                    " LOCK_UPDATE_UNLOCK_USER_0101
5658   *End RD1K976756  CAB_ALOK
5659   *&---------------------------------------------------------------------*
5660   *&      Form  POPUP_GET_VALUES
5661   *&---------------------------------------------------------------------*
5662   *       text
5663   *----------------------------------------------------------------------*
5664   *  -->  p1        text
5665   *  <--  p2        text
5666   *----------------------------------------------------------------------*
5667   *begin  RD1K977570 CAB_ALOK - CR 30006026
5668   FORM POPUP_GET_VALUES .
5669   *data : it_sval like sval occurs 0 with header line.
5670   *
5671   *  refresh it_sval.
5672   *  clear it_sval.
5673   *
5674   *  move : 'ZOL_MFST'  to it_sval-tabname,
5675   *         'MFST_NUM'    to it_sval-fieldname,
5676   *         'X'           to it_sval-field_obl.
5677   *
5678   *  get parameter id 'ZMFN' field it_sval-value.
5679   *  append it_sval.
5680   *
5681   *  call function 'POPUP_GET_VALUES'
5682   *       exporting
5683   *            popup_title     = text-103
5684   *       tables
5685   *            fields          = it_sval
5686   *       exceptions
5687   *            error_in_fields = 1
5688   *            others          = 2.
5689   *
5690   *  if sy-subrc <> 0.
5691   *    message id sy-msgid type sy-msgty number sy-msgno
5692   *            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
5693   *  endif.
5694   *  g_mfst_num = it_sval-value.
5695   *  set parameter id 'ZMFN' field g_mfst_num.
5696   ENDFORM.                    " POPUP_GET_VALUES
5697   *end  RD1K977570 CAB_ALOK - CR 30006026
5698   *&---------------------------------------------------------------------*
5699   *&      Form  ZERO_BALANCE
5700   *&---------------------------------------------------------------------*
5701   *       text
5702   *----------------------------------------------------------------------*
5703   *      -->P_IST_F_02_DEBIT_TEMP  text
5704   *----------------------------------------------------------------------*
5705   * begin of RD1K977852 CAB_ALOK  CR 30006309: Zero balance problem
5706   FORM ZERO_BALANCE  TABLES   P_IST_F_02_DEBIT_TEMP like STRU_F_02_DEBIT.
5707     data: P_WA_F_02_DEBIT_TEMP type TY_F_02_DEBIT.
5708     data: SUM_SPLIT_AMT type TY_F_02_DEBIT-SPLIT_AMT.
5709     data: l_tabix type sy-tabix.
5710     loop at P_IST_F_02_DEBIT_TEMP into P_WA_F_02_DEBIT_TEMP.
5711       l_tabix = sy-tabix.
5712       SUM_SPLIT_AMT = SUM_SPLIT_AMT + P_WA_F_02_DEBIT_TEMP-SPLIT_AMT.
5713     endloop.
5714
5715   *  making adjustment in last debit line.
5716     if SUM_SPLIT_AMT <> P_WA_F_02_DEBIT_TEMP-ZAMTPCSTOTAL.
5717       P_WA_F_02_DEBIT_TEMP-SPLIT_AMT = P_WA_F_02_DEBIT_TEMP-SPLIT_AMT - SUM_SPLIT_AMT + P_WA_F_02_DEBIT_TEMP-ZAMTPCSTOTAL.
5718       MODIFY P_IST_F_02_DEBIT_TEMP  FROM  P_WA_F_02_DEBIT_TEMP INDEX l_tabix.
5719     endif.
5720
5721   ENDFORM.                    " ZERO_BALANCE
5722   * end of RD1K977852 CAB_ALOK  CR 30006309
5723   *&---------------------------------------------------------------------*
5724   *&      Form  SEARCH
5725   *&---------------------------------------------------------------------*
5726   *       text
5727   *----------------------------------------------------------------------*
5728   *  -->  p1        text
5729   *  <--  p2        text
5730   *----------------------------------------------------------------------*
5731   * begin RD1K978193 CAB_ALOK CR 30006378
5732   FORM SEARCH .
5733     CLEAR ZPMED_SUBMIT-PERNR_LOW.
5734   * call screen 0510  starting at  50  50
5735   *                   ending at  100 100 .
5736
5737     call screen 0510  starting at  10 10
5738                       ending at  50 25 .
5739
5740   ENDFORM.                    " SEARCH
5741
5742   *&---------------------------------------------------------------------*
5743   *&      Form  TC_UNLOCK_SEARCH
5744   *&---------------------------------------------------------------------*
5745   *       text
5746   *----------------------------------------------------------------------*
5747   *  -->  p1        text
5748   *  <--  p2        text
5749   *----------------------------------------------------------------------*
5750   FORM TC_UNLOCK_SEARCH .
5751     data: l_tabix type sy-tabix.
5752
5753     IF g_srch_flag = 'X'.
5754       IF ZPMED_SUBMIT-PERNR_LOW is not initial.
5755   *     sort IST_9920_UNLOCK by pernr ASCENDING.
5756         READ TABLE IST_9920_UNLOCK INTO WA_9920_UNLOCK
5757             WITH KEY  pernr = ZPMED_SUBMIT-PERNR_LOW.
5758         IF sy-subrc = 0.
5759           l_tabix = sy-tabix.
5760           TC_UNLOCK-top_line = l_tabix.
5761           SET CURSOR 1 1.
5762           CLEAR g_srch_flag.
5763         ENDIF.
5764       ENDIF.
5765     ENDIF.
5766
5767   ENDFORM.                    " TC_UNLOCK_SEARCH
5768   * end RD1K978193 CAB_ALOK CR 30006378
5769   *&---------------------------------------------------------------------*
5770   *&      Form  TC_EDIT_SEARCH
5771   *&---------------------------------------------------------------------*
5772   *       text
5773   *----------------------------------------------------------------------*
5774   *  -->  p1        text
5775   *  <--  p2        text
5776   *----------------------------------------------------------------------*
5777   FORM TC_EDIT_SEARCH .
5778     data: l_tabix type sy-tabix.
5779
5780     IF g_srch_flag = 'X'.
5781       IF ZPMED_SUBMIT-PERNR_LOW is not initial.
5782   *     sort IST_9920_UNLOCK by pernr ASCENDING.
5783         READ TABLE IST_9920_EDIT INTO WA_9920_UNLOCK
5784             WITH KEY  pernr = ZPMED_SUBMIT-PERNR_LOW.
5785         IF sy-subrc = 0.
5786           l_tabix = sy-tabix.
5787           TC_EDIT-top_line = l_tabix.
5788           SET CURSOR 1 1.
5789           CLEAR g_srch_flag.
5790         ENDIF.
5791       ENDIF.
5792     ENDIF.
5793   ENDFORM.                    " TC_EDIT_SEARCH
5794   *&---------------------------------------------------------------------*
5795   *&      Form  CHECK_MEMORY_LOT_NO
5796   *&---------------------------------------------------------------------*
5797   *       text
5798   *----------------------------------------------------------------------*
5799   *  -->  p1        text
5800   *  <--  p2        text
5801   *----------------------------------------------------------------------*
5802   * begin RD1K976266 CAB_ALOK  CR 30006546 Changes in ZHRHOSP-Duplicate documen
5803   FORM CHECK_LOT_LOCK .
5804
5805   **data L_LOT_NO type ZLOT.
5806   **
5807   **GET PARAMETER ID 'ZSPA_LOT_NO' FIELD L_LOT_NO .
5808   **
5809   **IF sy-subrc <> 0 ." first run
5810   **  MESSAGE 'Lot not in process' TYPE 'I'.
5811   **    L_LOT_NO  = ZPMED_SUBMIT-ZLOT_NO_LOW.
5812   **    SET PARAMETER ID 'ZSPA_LOT_NO' FIELD L_LOT_NO .
5813   ***  // continue process.
5814   **  elseif sy-subrc = 0. "The SPA/GPA parameter exists for the current user in the SAP Memory and its value was transferred to the target field.
5815   **    "lot may be in process in another session
5816   **
5817   **    if L_LOT_NO = ZPMED_SUBMIT-ZLOT_NO_LOW.
5818   **      MESSAGE 'Lot already in process in other session' TYPE 'E'.
5819   **    else.
5820   **       MESSAGE 'Lot not in process' TYPE 'I'.
5821   **       L_LOT_NO  = ZPMED_SUBMIT-ZLOT_NO_LOW.
5822   **       SET PARAMETER ID 'ZSPA_LOT_NO' FIELD L_LOT_NO .
5823   **    endif.
5824   **
5825   **ENDIF.
5826
5827     data L_LOT_NO type ZLOT.
5828     DATA WA_ZHRMED_LOT_LOCK TYPE ZHRMED_LOT_LOCK.
5829
5830   * SELECT single *
5831   *   from ZHRMED_LOT_LOCK
5832   *     into WA_ZHRMED_LOT_LOCK
5833   *       where ZLOT_NO = ZPMED_SUBMIT-ZLOT_NO_LOW.
5834   *
5835   *   if WA_ZHRMED_LOT_LOCK-ZLOT_NO is initial. " LOT is not locked, Lock it in ZHRMED_LOT_LOCK
5836   *     WA_ZHRMED_LOT_LOCK-MANDT = sy-mandt.
5837   *     WA_ZHRMED_LOT_LOCK-ZLOT_NO = ZPMED_SUBMIT-ZLOT_NO_LOW.
5838   *     insert ZHRMED_LOT_LOCK from  WA_ZHRMED_LOT_LOCK.
5839   *
5840   *     else. " LOT is locked for processing by other user or other session
5841   *        MESSAGE 'Lot already in process in another session' TYPE 'E'.
5842   *   endif.
5843
5844   *========================
5845
5846     SELECT single *
5847       from ZHRMED_LOT_LOCK
5848         into WA_ZHRMED_LOT_LOCK
5849           where ZLOT_NO = ZPMED_SUBMIT-ZLOT_NO_LOW.
5850
5851     " if LOT NO. exists then Take a lock on table ZHRMED_LOT_LOCK
5852     if WA_ZHRMED_LOT_LOCK-ZLOT_NO is not initial.
5853
5854   * if LOT NO. doesn't exist, insert ZLOT_NO into table ZHRMED_LOT_LOCK
5855       " and Take the lock
5856     elseif WA_ZHRMED_LOT_LOCK-ZLOT_NO is initial. " LOT is not locked, Lock it in ZHRMED_LOT_LOCK
5857       WA_ZHRMED_LOT_LOCK-MANDT = sy-mandt.
5858       WA_ZHRMED_LOT_LOCK-ZLOT_NO = ZPMED_SUBMIT-ZLOT_NO_LOW.
5859       insert ZHRMED_LOT_LOCK from  WA_ZHRMED_LOT_LOCK.
5860
5861     endif.
5862
5863     perform LOCK_LOT_NO using WA_ZHRMED_LOT_LOCK-ZLOT_NO.
5864
5865
5866   *=========================
5867
5868
5869
5870
5871   ENDFORM.                    " CHECK_MEMORY_LOT_NO
5872   * end RD1K976266 CAB_ALOK  CR 30006546 Changes in ZHRHOSP-Duplicate documen
5873   *&---------------------------------------------------------------------*
5874   *&      Form  LOCK_LOT_NO
5875   *&---------------------------------------------------------------------*
5876   *       text
5877   *----------------------------------------------------------------------*
5878   *  -->  p1        text
5879   *  <--  p2        text
5880   *----------------------------------------------------------------------*
5881   * Begin RD1K978727 CAB_ALOK  CR 30006619 - Lot No. Lock mechanism
5882   FORM LOCK_LOT_NO USING P_ZLOT_NO.
5883
5884   *Call the ENQUEUE FM corresponding to the lock object EZHRMED_LOT_LOCK
5885     CALL FUNCTION 'ENQUEUE_EZHRMED_LOT_LOCK'
5886       EXPORTING
5887         MODE_ZHRMED_LOT_LOCK = 'E'         "write lock
5888         MANDT                = SY-MANDT
5889         ZLOT_NO              = P_ZLOT_NO
5890   *     X_ZLOT_NO            = ' '
5891   *     _SCOPE               = '2'
5892   *     _WAIT                = ' '
5893   *     _COLLECT             = ' '
5894       EXCEPTIONS
5895         FOREIGN_LOCK         = 1
5896         SYSTEM_FAILURE       = 2
5897         OTHERS               = 3.
5898     IF SY-SUBRC <> 0.  "Lock could not be obtained, Show message
5899       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
5900               WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
5901     ENDIF.
5902
5903   ENDFORM.                    " LOCK_LOT_NO
5904   * End RD1K978727 CAB_ALOK  CR 30006619 - Lot No. Lock mechanism
5905   *&---------------------------------------------------------------------*
5906   *&      Form  UNLOCK_LOT_NO
5907   *&---------------------------------------------------------------------*
5908   *       text
5909   *----------------------------------------------------------------------*
5910   *      -->P_ZPMED_SUBMIT_ZLOT_NO_LOW  text
5911   *----------------------------------------------------------------------*
5912   * Begin RD1K978727 CAB_ALOK  CR 30006619 - Lot No. Lock mechanism
5913   FORM UNLOCK_LOT_NO  USING P_ZLOT_NO.
5914
5915     CALL FUNCTION 'DEQUEUE_EZHRMED_LOT_LOCK'
5916       EXPORTING
5917         MODE_ZHRMED_LOT_LOCK = 'E'
5918         MANDT                = SY-MANDT
5919         ZLOT_NO              = P_ZLOT_NO
5920   *     X_ZLOT_NO            = ' '
5921   *     _SCOPE               = '3'
5922   *     _SYNCHRON            = ' '
5923   *     _COLLECT             = ' '
5924       .
5925
5926
5927
5928   ENDFORM.                    " UNLOCK_LOT_NO
5929   * end RD1K978727 CAB_ALOK  CR 30006619 - Lot No. Lock mechanism
5930   *&---------------------------------------------------------------------*
5931   *&      Form  CALCULATE_TOTALS
5932   *&---------------------------------------------------------------------*
5933   *       text
5934   *----------------------------------------------------------------------*
5935   *  -->  p1        text
5936   *  <--  p2        text
5937   *----------------------------------------------------------------------*
5938   *begin RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
5939   FORM CALCULATE_TOTALS .
5940     clear wa_9920_PAY.
5941     clear: LOT_TOTAL_PCS_AMT ,
5942            SELECT_TOTAL_PCS_AMT,
5943            PENDING_TOTAL_PCS_AMT.
5944
5945     loop at IST_9920_PAY into WA_9920_PAY WHERE zstatus = 'UNLOCKED'.
5946       PENDING_TOTAL_PCS_AMT = PENDING_TOTAL_PCS_AMT + WA_9920_PAY-ZAMTPCSTOTAL.
5947       if WA_9920_PAY-SEL = 'X'.  "row has been selected
5948         SELECT_TOTAL_PCS_AMT = SELECT_TOTAL_PCS_AMT + WA_9920_PAY-ZAMTPCSTOTAL.
5949       endif.
5950     endloop.
5951     clear wa_9920_PAY.
5952
5953     select SUM( ZAMTMOTOTAL ) from PA9920
5954       into LOT_TOTAL_PCS_AMT
5955         where ZLOT_NO = ZPMED_SUBMIT-ZLOT_NO_LOW
5956           and ( ZSTATUS = 'UNLOCKED' OR  zstatus = 'PAID' )
5957           and ( SUBTY = '03' or SUBTY = '04' or SUBTY = '05' or SUBTY = '06' or SUBTY = '07' ) .
5958
5959   ENDFORM.                    " CALCULATE_TOTALS
5960
5961   *&---------------------------------------------------------------------*
5962   *&      Form  LEVEL_1_CHECK_0605
5963   *&---------------------------------------------------------------------*
5964   *       text
5965   *----------------------------------------------------------------------*
5966   *  -->  p1        text
5967   *  <--  p2        text
5968   *----------------------------------------------------------------------*
5969   FORM LEVEL_1_CHECK_0605 .
5970   *  If 'CHECK1' is pressed:
5971
5972     data: L_MAX_AMT type ZAMT15_2.
5973     L_MAX_AMT = 9999999999999 / 100 .  " = 99999999999.99
5974
5975   *begin RD1K995325 CAB_ALOK   CR 30012355 BDP-2014 Implemention: FI Medical Paymnt
5976
5977   *  if LOT_TOTAL_PCS_AMT => 1500001 and LOT_TOTAL_PCS_AMT =< L_MAX_AMT .
5978   *    If G_USER_PERSK between 'E1' and 'E3'.
5979   **   Update PA9920-check_by_pernr & PA9920-Check_by_level
5980   *      perform UPDATE_CHECK1_INFO.
5981   *    else.
5982   *      message e114(zhr) with G_USER_PERNR G_USER_PERSK. "Level 1 check not permitted by
5983   *    endif.
5984   *  else.
5985   *    message e115(zhr). " Level 1 check not required for this amount.
5986   *  endif.
5987
5988     if LOT_TOTAL_PCS_AMT > 1000000 and LOT_TOTAL_PCS_AMT =< L_MAX_AMT .
5989       If G_USER_PERSK between 'E1' and 'E9'.
5990   *   Update PA9920-check_by_pernr & PA9920-Check_by_level
5991         perform UPDATE_CHECK1_INFO.
5992       else.
5993         message e114(zhr) with G_USER_PERNR G_USER_PERSK. "Level 1 check not permitted by
5994       endif.
5995     else.
5996       message e115(zhr). " Level 1 check not required for this amount.
5997     endif.
5998
5999
6000   *End RD1K995325 CAB_ALOK   CR 30012355 BDP-2014 Implemention: FI Medical Paymnt
6001
6002
6003
6004
6005   ENDFORM.                    " LEVEL_1_CHECK_0605
6006
6007   *&---------------------------------------------------------------------*
6008   *&      Form  UPDATE_CHECK1_INFO
6009   *&---------------------------------------------------------------------*
6010   *       text
6011   *----------------------------------------------------------------------*
6012   *  -->  p1        text
6013   *  <--  p2        text
6014   *----------------------------------------------------------------------*
6015   FORM UPDATE_CHECK1_INFO .
6016   * Operation on IST_9920_PAY: Update PA9920-checked_by_pernr & PA9920-Checked_by_level
6017     DATA: WA_9920_PAY_SEL TYPE TY_PAY,
6018           WA_9920_MSG TYPE ZHR_MEDPYMT_9920_MSG,
6019           l_tabix  TYPE sy-tabix.
6020
6021     LOOP AT IST_9920_PAY INTO WA_9920_PAY_SEL WHERE SEL = 'X' AND ZSTATUS = 'UNLOCKED'.
6022       l_tabix =   sy-tabix .
6023       MOVE-CORRESPONDING WA_9920_PAY_SEL to WA_9920_MSG.
6024       WA_9920_MSG-CHECKED_BY_PERNR = G_USER_PERNR .
6025       WA_9920_MSG-CHECKED_BY_LEVEL = G_USER_PERSK .
6026
6027       CALL FUNCTION 'ZHR_MED_PYMT_UPDATE9920_MSG' DESTINATION 'MMREQ_ASSETNO_CR_RFC'
6028         EXPORTING
6029           OPERATION_TYPE = 'MOD'       "OPERATION of HR_INFOTYPE_OPERATION
6030           LOCK_INDICATOR = ' '   "current value of lockindicator
6031         CHANGING
6032           WA_9920_MSG    = WA_9920_MSG.
6033       if WA_9920_MSG-ERROR_FLAG <> '1'.  "if update Operation successful, then modify the Message
6034         WA_9920_MSG-MESSAGE = 'Checked '. " otherwise this message contains 'Status: UNLOCKED'
6035       elseif WA_9920_MSG-ERROR_FLAG = '1'.
6036         clear: WA_9920_MSG-CHECKED_BY_PERNR,
6037                WA_9920_MSG-CHECKED_BY_LEVEL.
6038       endif.
6039
6040       MOVE-CORRESPONDING WA_9920_MSG to WA_9920_PAY_SEL.
6041
6042       MODIFY IST_9920_PAY  FROM  WA_9920_PAY_SEL INDEX l_tabix.
6043       CLEAR: WA_9920_PAY_SEL ,
6044              WA_9920_MSG.
6045
6046     ENDLOOP.
6047
6048   ENDFORM.                    " UPDATE_CHECK1_INFO
6049
6050   *&---------------------------------------------------------------------*
6051   *&      Form  LEVEL_2_CHECK_0605
6052   *&---------------------------------------------------------------------*
6053   *       text
6054   *----------------------------------------------------------------------*
6055   *      <--P_FLAG_LEVEL_2_CHECK  text
6056   *----------------------------------------------------------------------*
6057   FORM LEVEL_2_CHECK_0605  CHANGING P_FLAG_LEVEL_2_CHECK.
6058
6059     DATA: WA_9920_PAY_SEL TYPE TY_PAY,
6060           WA_9920_MSG TYPE ZHR_MEDPYMT_9920_MSG,
6061           l_tabix  TYPE sy-tabix.
6062     data: L_MAX_AMT type ZAMT15_2.
6063     L_MAX_AMT = 9999999999999 / 100 .  " = 99999999999.99
6064
6065   *begin RD1K995325 CAB_ALOK   CR 30012355 BDP-2014 Implemention: FI Medical Paymnt
6066
6067   **  if ( LOT_TOTAL_PCS_AMT => 1 and LOT_TOTAL_PCS_AMT =< 10000 )
6068   *** Begin RD1K981858       CAB_ALOK     Modification in 2 Level CHK :ZHRHOSP - CR 30007832
6069   ***                    and ( G_USER_PERSK between 'E0' and 'E4' )
6070   **                    and ( G_USER_PERSK between 'E0' and 'E9' )
6071   *** end RD1K981858       CAB_ALOK     Modification in 2 Level CHK :ZHRHOSP - CR 30007832
6072   **      OR ( LOT_TOTAL_PCS_AMT => 10001 and LOT_TOTAL_PCS_AMT =< 500000 )
6073   *** Begin RD1K981858       CAB_ALOK     Modification in 2 Level CHK :ZHRHOSP - CR 30007832
6074   ***                    and ( G_USER_PERSK between 'E1' and 'E4' )
6075   **                    and ( G_USER_PERSK between 'E1' and 'E9' )
6076   *** end RD1K981858       CAB_ALOK     Modification in 2 Level CHK :ZHRHOSP - CR 30007832
6077   **
6078   **      OR ( LOT_TOTAL_PCS_AMT => 500001 and LOT_TOTAL_PCS_AMT =< 1500000 )
6079   *** Begin RD1K981858       CAB_ALOK     Modification in 2 Level CHK :ZHRHOSP - CR 30007832
6080   ***                    and ( G_USER_PERSK between 'E2' and 'E4' ).
6081   **                    and ( G_USER_PERSK between 'E2' and 'E9' ).
6082   *** end RD1K981858       CAB_ALOK     Modification in 2 Level CHK :ZHRHOSP - CR 30007832
6083   **
6084   **    "// Level 2 check for the row is OK.
6085   **
6086   **  elseif ( LOT_TOTAL_PCS_AMT => 1500001 and LOT_TOTAL_PCS_AMT =< 10000000 )
6087   *** Begin RD1K981858       CAB_ALOK     Modification in 2 Level CHK :ZHRHOSP - CR 30007832
6088   ***                     and ( G_USER_PERSK between 'E2' and 'E4' ).
6089   **                     and ( G_USER_PERSK between 'E2' and 'E9' ).
6090   *** end RD1K981858       CAB_ALOK     Modification in 2 Level CHK :ZHRHOSP - CR 30007832
6091   **
6092   **    LOOP AT IST_9920_PAY INTO WA_9920_PAY_SEL WHERE SEL = 'X' AND ZSTATUS = 'UNLOCKED'.
6093   **      l_tabix =   sy-tabix .
6094   **      if WA_9920_PAY_SEL-CHECKED_BY_PERNR is NOT INITIAL
6095   **                 AND WA_9920_PAY_SEL-CHECKED_BY_LEVEL is  NOT INITIAL. "i.e. Check 1 is OK
6096   **        if WA_9920_PAY_SEL-CHECKED_BY_PERNR <> G_USER_PERNR.
6097   **          "// Level 2 check for the row is OK.
6098   **        else.
6099   **          P_FLAG_LEVEL_2_CHECK = 'F'. "Fail
6100   **          WA_9920_PAY_SEL-message = 'Claim can not be checked & paid by the same pernr'.
6101   **          MODIFY IST_9920_PAY  FROM  WA_9920_PAY_SEL INDEX l_tabix.
6102   **        endif.
6103   **      else.
6104   **        P_FLAG_LEVEL_2_CHECK = 'F'. "Fail
6105   **        WA_9920_PAY_SEL-message = 'Claim needs to be Checked first'.
6106   **        MODIFY IST_9920_PAY  FROM  WA_9920_PAY_SEL INDEX l_tabix.
6107   **      endif.
6108   **
6109   **      if WA_9920_PAY_SEL-taxable = 'Y' or WA_9920_PAY_SEL-taxable = 'N'.
6110   **      else.
6111   **        P_FLAG_LEVEL_2_CHECK = 'F'. "Fail
6112   **        WA_9920_PAY_SEL-message = 'Specify Amount is Taxable or not'.
6113   **        MODIFY IST_9920_PAY  FROM  WA_9920_PAY_SEL INDEX l_tabix.
6114   **      endif.
6115   **
6116   **      CLEAR: WA_9920_PAY_SEL.
6117   **    ENDLOOP.
6118   **
6119   **  elseif ( LOT_TOTAL_PCS_AMT => 10000001 and LOT_TOTAL_PCS_AMT =< L_MAX_AMT )
6120   *** Begin RD1K981858       CAB_ALOK     Modification in 2 Level CHK :ZHRHOSP - CR 30007832
6121   ***              and ( G_USER_PERSK = 'E4' ).
6122   **               and ( G_USER_PERSK between 'E4' and 'E9' ).
6123   *** end RD1K981858       CAB_ALOK     Modification in 2 Level CHK :ZHRHOSP - CR 30007832
6124   **
6125   **    clear l_tabix.
6126   **    LOOP AT IST_9920_PAY INTO WA_9920_PAY_SEL WHERE SEL = 'X' AND ZSTATUS = 'UNLOCKED'.
6127   **      l_tabix = sy-tabix .
6128   **      if WA_9920_PAY_SEL-CHECKED_BY_PERNR is NOT INITIAL
6129   **                 AND WA_9920_PAY_SEL-CHECKED_BY_LEVEL is  NOT INITIAL. "i.e. Check 1 is OK
6130   **        "// Level 2 check for the row is OK.
6131   **      else.
6132   **        P_FLAG_LEVEL_2_CHECK = 'F'. "Fail
6133   **        WA_9920_PAY_SEL-message = 'Claim needs to be Checked first'.
6134   **        MODIFY IST_9920_PAY  FROM  WA_9920_PAY_SEL INDEX l_tabix.
6135   **      endif.
6136   **
6137   **      CLEAR: WA_9920_PAY_SEL.
6138   **    ENDLOOP.
6139   **
6140   **  else.
6141   **    P_FLAG_LEVEL_2_CHECK = 'F'.
6142   **    message e116(zhr) with G_USER_PERNR G_USER_PERSK. "Payment not permitted by
6143   **  endif.
6144
6145     if ( LOT_TOTAL_PCS_AMT >= 1 and LOT_TOTAL_PCS_AMT <= 50000 )
6146                       and ( G_USER_PERSK between 'E0' and 'E9' )
6147
6148         OR ( LOT_TOTAL_PCS_AMT > 50000 and LOT_TOTAL_PCS_AMT <= 1000000 )
6149                      and ( G_USER_PERSK between 'E1' and 'E9' ).
6150
6151       "// Level 2 check for the row is OK.
6152
6153     elseif ( LOT_TOTAL_PCS_AMT > 1000000 and LOT_TOTAL_PCS_AMT <= 5000000 )
6154                        and ( G_USER_PERSK between 'E2' and 'E9' ).
6155
6156       LOOP AT IST_9920_PAY INTO WA_9920_PAY_SEL WHERE SEL = 'X' AND ZSTATUS = 'UNLOCKED'.
6157         l_tabix =   sy-tabix .
6158         if WA_9920_PAY_SEL-CHECKED_BY_PERNR is NOT INITIAL
6159                    AND WA_9920_PAY_SEL-CHECKED_BY_LEVEL is  NOT INITIAL. "i.e. Check 1 is OK
6160           if WA_9920_PAY_SEL-CHECKED_BY_PERNR <> G_USER_PERNR.
6161             "// Level 2 check for the row is OK.
6162           else.
6163             P_FLAG_LEVEL_2_CHECK = 'F'. "Fail
6164             WA_9920_PAY_SEL-message = 'Claim can not be checked & paid by the same pernr'.
6165             MODIFY IST_9920_PAY  FROM  WA_9920_PAY_SEL INDEX l_tabix.
6166           endif.
6167         else.
6168           P_FLAG_LEVEL_2_CHECK = 'F'. "Fail
6169           WA_9920_PAY_SEL-message = 'Claim needs to be Checked first'.
6170           MODIFY IST_9920_PAY  FROM  WA_9920_PAY_SEL INDEX l_tabix.
6171         endif.
6172
6173         if WA_9920_PAY_SEL-taxable = 'Y' or WA_9920_PAY_SEL-taxable = 'N'.
6174         else.
6175           P_FLAG_LEVEL_2_CHECK = 'F'. "Fail
6176           WA_9920_PAY_SEL-message = 'Specify Amount is Taxable or not'.
6177           MODIFY IST_9920_PAY  FROM  WA_9920_PAY_SEL INDEX l_tabix.
6178         endif.
6179
6180         CLEAR: WA_9920_PAY_SEL.
6181       ENDLOOP.
6182
6183     elseif ( LOT_TOTAL_PCS_AMT > 5000000 and LOT_TOTAL_PCS_AMT <= 10000000 )
6184                  and ( G_USER_PERSK between 'E3' and 'E9' ).
6185       clear l_tabix.
6186       LOOP AT IST_9920_PAY INTO WA_9920_PAY_SEL WHERE SEL = 'X' AND ZSTATUS = 'UNLOCKED'.
6187         l_tabix = sy-tabix .
6188         if WA_9920_PAY_SEL-CHECKED_BY_PERNR is NOT INITIAL
6189                    AND WA_9920_PAY_SEL-CHECKED_BY_LEVEL is  NOT INITIAL. "i.e. Check 1 is OK
6190           "// Level 2 check for the row is OK.
6191         else.
6192           P_FLAG_LEVEL_2_CHECK = 'F'. "Fail
6193           WA_9920_PAY_SEL-message = 'Claim needs to be Checked first'.
6194           MODIFY IST_9920_PAY  FROM  WA_9920_PAY_SEL INDEX l_tabix.
6195         endif.
6196
6197         CLEAR: WA_9920_PAY_SEL.
6198       ENDLOOP.
6199
6200     elseif ( LOT_TOTAL_PCS_AMT > 10000000 and LOT_TOTAL_PCS_AMT <= L_MAX_AMT )
6201                  and ( G_USER_PERSK between 'E4' and 'E9' ).
6202
6203       clear l_tabix.
6204       LOOP AT IST_9920_PAY INTO WA_9920_PAY_SEL WHERE SEL = 'X' AND ZSTATUS = 'UNLOCKED'.
6205         l_tabix = sy-tabix .
6206         if WA_9920_PAY_SEL-CHECKED_BY_PERNR is NOT INITIAL
6207                    AND WA_9920_PAY_SEL-CHECKED_BY_LEVEL is  NOT INITIAL. "i.e. Check 1 is OK
6208           "// Level 2 check for the row is OK.
6209         else.
6210           P_FLAG_LEVEL_2_CHECK = 'F'. "Fail
6211           WA_9920_PAY_SEL-message = 'Claim needs to be Checked first'.
6212           MODIFY IST_9920_PAY  FROM  WA_9920_PAY_SEL INDEX l_tabix.
6213         endif.
6214
6215         CLEAR: WA_9920_PAY_SEL.
6216       ENDLOOP.
6217
6218     else.
6219       P_FLAG_LEVEL_2_CHECK = 'F'.
6220       message e116(zhr) with G_USER_PERNR G_USER_PERSK. "Payment not permitted by
6221     endif.
6222
6223   *end RD1K995325 CAB_ALOK   CR 30012355 BDP-2014 Implemention: FI Medical Paymnt
6224
6225   *============================================
6226     LOOP AT IST_9920_PAY INTO WA_9920_PAY_SEL WHERE SEL = 'X' AND ZSTATUS = 'UNLOCKED'.
6227
6228       if WA_9920_PAY_SEL-taxable = 'Y' or WA_9920_PAY_SEL-taxable = 'N'.
6229       else.
6230         P_FLAG_LEVEL_2_CHECK = 'F'. "Fail
6231         WA_9920_PAY_SEL-message = 'Specify Amount is Taxable or not'.
6232         MODIFY IST_9920_PAY  FROM  WA_9920_PAY_SEL INDEX sy-tabix.
6233
6234         message s000(zmsg) with 'Specify Amount is Taxable or not'.
6235       endif.
6236
6237       CLEAR: WA_9920_PAY_SEL.
6238     ENDLOOP.
6239
6240
6241   ENDFORM.                    " LEVEL_2_CHECK_0605
6242
6243   *&---------------------------------------------------------------------*
6244   *&      Form  GET_DATA_1001
6245   *&---------------------------------------------------------------------*
6246   *       text
6247   *----------------------------------------------------------------------*
6248   *  -->  p1        text
6249   *  <--  p2        text
6250   *----------------------------------------------------------------------*
6251   FORM GET_DATA_1001 .
6252
6253     DATA: submit_pernr TYPE pernr_d.
6254     DATA: submit_name TYPE emnam.
6255     DATA: submit_orgeh TYPE orgeh.
6256     DATA: submit_plans TYPE plans.
6257     DATA: submit_persa TYPE persa.
6258     DATA: submit_bukrs TYPE bukrs.
6259
6260     PERFORM GETDATA_IST_9920_REV tables IST_9920_REV using G_USER_BUKRS. "submit_bukrs .
6261
6262   ENDFORM.                    " GET_DATA_1001
6263   *&---------------------------------------------------------------------*
6264   *&      Form  GETDATA_IST_9920_REV
6265   *&---------------------------------------------------------------------*
6266   *       text
6267   *----------------------------------------------------------------------*
6268   *      -->P_IST_9920_PAY  text
6269   *      -->P_G_USER_BUKRS  text
6270   *----------------------------------------------------------------------*
6271
6272
6273   * Begin RD1K981765 CR: 30007609 CAB_ALOK
6274   *FORM GETDATA_IST_9920_REV TABLES IST_9920_REV  USING G_USER_BUKRS.
6275   FORM GETDATA_IST_9920_REV  tables IST_9920_REV STRUCTURE IST_9920_REV using submit_bukrs.
6276   * End RD1K981765 CR: 30007609 CAB_ALOK
6277     DATA: wa_9920_rev1 TYPE ty_pay,
6278                  l_tabix  TYPE sy-tabix.
6279
6280     CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
6281       EXPORTING
6282         INPUT  = ZPMED_SUBMIT-ZLOT_NO_LOW
6283       IMPORTING
6284         OUTPUT = ZPMED_SUBMIT-ZLOT_NO_LOW.
6285
6286     select * from PA9920
6287       into corresponding fields of table IST_9920_REV
6288         where ZLOT_NO = ZPMED_SUBMIT-ZLOT_NO_LOW
6289           and BELNR   = ZPMED_SUBMIT-BELNR
6290           and GJAHR   = ZPMED_SUBMIT-GJAHR
6291           and BUKRS   = ZPMED_SUBMIT-BUKRS
6292           and ZSTATUS = 'PAID'
6293           and ( SUBTY = '03' or SUBTY = '04' or SUBTY = '05' or SUBTY = '06' or  SUBTY = '07' ) .
6294
6295   * Begin RD1K981765 CR: 30007609 CAB_ALOK
6296     Sort IST_9920_REV by CNTER ASCENDING.
6297   * End RD1K981765 CR: 30007609 CAB_ALOK
6298
6299   ** Fill INFTY, serial no., MO_AMOUNT
6300     loop at IST_9920_REV into wa_9920_REV1.
6301       l_tabix = sy-tabix.
6302       wa_9920_REV1-INFTY = '9920'.
6303       wa_9920_REV1-serial_no = l_tabix.
6304       MODIFY IST_9920_REV FROM WA_9920_REV1 INDEX l_tabix.
6305     endloop.
6306
6307   ENDFORM.                    " GETDATA_IST_9920_REV
6308
6309   *----------------------------------------------------------------------*
6310   *   INCLUDE TABLECONTROL_FORMS                                         *
6311   *----------------------------------------------------------------------*
6312
6313   *&---------------------------------------------------------------------*
6314   *&      Form  USER_OK_TC_REV                                               *
6315   *&---------------------------------------------------------------------*
6316   FORM USER_OK_TC_REV USING    P_TC_NAME TYPE DYNFNAM
6317                            P_TABLE_NAME
6318                            P_MARK_NAME
6319                   CHANGING P_OK      LIKE SY-UCOMM.
6320
6321   *&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
6322     DATA: L_OK              TYPE SY-UCOMM,
6323           L_OFFSET          TYPE I.
6324   *&SPWIZARD: END OF LOCAL DATA------------------------------------------*
6325
6326   *&SPWIZARD: Table control specific operations                          *
6327   *&SPWIZARD: evaluate TC name and operations                            *
6328     SEARCH P_OK FOR P_TC_NAME.
6329     IF SY-SUBRC <> 0.
6330       EXIT.
6331     ENDIF.
6332     L_OFFSET = STRLEN( P_TC_NAME ) + 1.
6333     L_OK = P_OK+L_OFFSET.
6334   *&SPWIZARD: execute general and TC specific operations                 *
6335     CASE L_OK.
6336       WHEN 'REV'.
6337         PERFORM REVERSE_1005.
6338         CLEAR P_OK.
6339
6340       WHEN 'INSR'.                      "insert row
6341         PERFORM FCODE_INSERT_ROW USING    P_TC_NAME
6342                                           P_TABLE_NAME.
6343         CLEAR P_OK.
6344
6345       WHEN 'DELE'.                      "delete row
6346         PERFORM FCODE_DELETE_ROW USING    P_TC_NAME
6347                                           P_TABLE_NAME
6348                                           P_MARK_NAME.
6349         CLEAR P_OK.
6350
6351       WHEN 'P--' OR                     "top of list
6352            'P-'  OR                     "previous page
6353            'P+'  OR                     "next page
6354            'P++'.                       "bottom of list
6355         PERFORM COMPUTE_SCROLLING_IN_TC USING P_TC_NAME
6356                                               L_OK.
6357         CLEAR P_OK.
6358   *     WHEN 'L--'.                       "total left
6359   *       PERFORM FCODE_TOTAL_LEFT USING P_TC_NAME.
6360   *
6361   *     WHEN 'L-'.                        "column left
6362   *       PERFORM FCODE_COLUMN_LEFT USING P_TC_NAME.
6363   *
6364   *     WHEN 'R+'.                        "column right
6365   *       PERFORM FCODE_COLUMN_RIGHT USING P_TC_NAME.
6366   *
6367   *     WHEN 'R++'.                       "total right
6368   *       PERFORM FCODE_TOTAL_RIGHT USING P_TC_NAME.
6369   *
6370       WHEN 'MARK'.                      "mark all filled lines
6371         PERFORM FCODE_TC_MARK_LINES USING P_TC_NAME
6372                                           P_TABLE_NAME
6373                                           P_MARK_NAME   .
6374         CLEAR P_OK.
6375
6376       WHEN 'DMRK'.                      "demark all filled lines
6377         PERFORM FCODE_TC_DEMARK_LINES USING P_TC_NAME
6378                                             P_TABLE_NAME
6379                                             P_MARK_NAME .
6380         CLEAR P_OK.
6381
6382   *     WHEN 'SASCEND'   OR
6383   *          'SDESCEND'.                  "sort column
6384   *       PERFORM FCODE_SORT_TC USING P_TC_NAME
6385   *                                   l_ok.
6386
6387     ENDCASE.
6388
6389   ENDFORM.                              " USER_OK_TC_REV
6390
6391   *&---------------------------------------------------------------------*
6392   *&      Form  REVERSE_1005
6393   *&---------------------------------------------------------------------*
6394   *       text
6395   *----------------------------------------------------------------------*
6396   *  -->  p1        text
6397   *  <--  p2        text
6398   *----------------------------------------------------------------------*
6399   FORM REVERSE_1005 .
6400
6401   *  Take lock on all the pernrs.
6402   *  if any one already locked, get information about who has taken the lock,
6403   *       release all locks, return to screen & display error msg.
6404   *  elseif all pernrs are locked
6405   *    run BDC of FB08 or FBU8 .
6406   *       .
6407   *       .
6408   *      if BDC successful.
6409   *        Reverse records of 9920 corresponding to records of IST_REV:
6410   *           update STBLG (reversal doc no.), set status = UNLOCKED,
6411   *           clear BELNR GJAHR BUKRS CHECKED_BY_PERNR CHECKED_BY_LEVEL PAID_BY_PERNR PAID_BY_LEVEL
6412   *           insert Negative (Credit) entry into the Recovery_amt field of the ZHRMED_EMP_RECOV table .
6413   *              .
6414   *              .
6415   *      endif
6416   *     unlock all pernrs
6417   *   endif
6418     Data :   L_GLAC like zhrhospsanction-glhead ,
6419             L_FISCAL_YEAR TYPE GJAHR ,
6420             l_bukrs type bukrs.
6421
6422     data: WA_9920_REV_SEL1 TYPE TY_PAY,
6423           WA_9920_MSG TYPE ZHR_MEDPYMT_9920_MSG,
6424           ERROR_PERNR_LOCK type char1,
6425           l_tabix TYPE  sy-tabix .
6426     data : bdc_subrc_rev like sy-subrc. " capture status of BDC success
6427     Data : ist_mesg type ESP1_MESSAGE_TAB_TYPE with header line.
6428     data cnt type i.
6429     data: count type i.
6430     data: SAVE_PAID_BY_PERNR type PA9920-PAID_BY_PERNR,
6431           SAVE_PAID_BY_LEVEL type PA9920-PAID_BY_LEVEL,
6432           SAVE_BELNR type PA9920-BELNR,
6433           SAVE_BUKRS type PA9920-BUKRS,
6434           SAVE_GJAHR type PA9920-GJAHR,
6435           SAVE_CHECKED_BY_PERNR type PA9920-CHECKED_BY_PERNR,
6436           SAVE_CHECKED_BY_LEVEL type PA9920-CHECKED_BY_LEVEL.
6437
6438     data : IST_PA9920 type  table of  PA9920,
6439            WA_PA9920 type PA9920.
6440
6441     data : IST_ZHRMED_EMP_RECOV type table of ZHRMED_EMP_RECOV,
6442            WA_ZHRMED_EMP_RECOV type ZHRMED_EMP_RECOV.
6443
6444   * Remove previous MESSAGEs & ERROR_FLAGs before each run of table control
6445     clear l_tabix.
6446     CLEAR: WA_9920_REV_SEL1 .
6447     LOOP AT IST_9920_REV INTO WA_9920_REV_SEL1 WHERE ZSTATUS = 'PAID'.
6448       l_tabix =   sy-tabix .
6449       clear: WA_9920_REV_SEL1-MESSAGE, WA_9920_REV_SEL1-ERROR_FLAG.
6450       MODIFY IST_9920_REV  FROM  WA_9920_REV_SEL1 INDEX l_tabix.
6451       CLEAR: WA_9920_REV_SEL1 .
6452     endloop.
6453
6454   *Lock all Pernrs of IST_9920_REV.
6455     clear l_tabix.
6456     CLEAR: WA_9920_REV_SEL1, WA_9920_MSG.
6457     LOOP AT IST_9920_REV INTO WA_9920_REV_SEL1 WHERE ZSTATUS = 'PAID'.
6458       l_tabix =   sy-tabix .
6459       MOVE-CORRESPONDING WA_9920_REV_SEL1 to WA_9920_MSG.
6460
6461       CALL FUNCTION 'ZHR_MED_PERNR_LOCK' DESTINATION 'MMREQ_ASSETNO_CR_RFC'
6462         CHANGING
6463           WA_9920_MSG = WA_9920_MSG.
6464
6465       if WA_9920_MSG-ERROR_FLAG = '1'.   " at least one pernr lock failed
6466         ERROR_PERNR_LOCK = '1'.
6467       endif.
6468
6469       MOVE-CORRESPONDING WA_9920_MSG to WA_9920_REV_SEL1. " if lock failed then ERROR_FLAG set to '1'
6470
6471       MODIFY IST_9920_REV  FROM  WA_9920_REV_SEL1 INDEX l_tabix.
6472       CLEAR: WA_9920_REV_SEL1 , WA_9920_MSG.
6473     ENDLOOP.
6474
6475     IF ERROR_PERNR_LOCK = '1'.
6476
6477       MESSAGE i113(zhr). "At least one pernr is locked. See message column.
6478       clear ERROR_PERNR_LOCK.
6479       " at least one pernr lock failed so release other locked PERNRs of the IST_9920_REV before exiting
6480       clear l_tabix.
6481       CLEAR: WA_9920_REV_SEL1, WA_9920_MSG.
6482       LOOP AT IST_9920_REV INTO WA_9920_REV_SEL1 WHERE ZSTATUS = 'PAID' AND ERROR_FLAG = ''.
6483         l_tabix =   sy-tabix .
6484         MOVE-CORRESPONDING WA_9920_REV_SEL1 to WA_9920_MSG.
6485
6486         CALL FUNCTION 'ZHR_MED_PERNR_UNLOCK' DESTINATION 'MMREQ_ASSETNO_CR_RFC'
6487           CHANGING
6488             WA_9920_MSG = WA_9920_MSG.
6489
6490         MOVE-CORRESPONDING WA_9920_MSG to WA_9920_REV_SEL1.
6491
6492         MODIFY IST_9920_REV  FROM  WA_9920_REV_SEL1 INDEX l_tabix.
6493         CLEAR: WA_9920_REV_SEL1 , WA_9920_MSG.
6494       ENDLOOP.
6495
6496     ELSE. "Locks acquired on all the pernrs, now process BDC for Reversal ( FBU8 or FB08)
6497
6498   ****
6499   * FBU8 takes BVORG  as input, FB08 takes BELNR as input
6500   **find BVORG for above ( belnr, bukrs, gjahr ) in BKPF table
6501   * if BVORG exists => IUT Doc => run FBU8 BDC for  reversal of the doc
6502   * else non-IUT Doc => run FB08 BDC for  reversal of the doc
6503
6504   *    ZPMED_SUBMIT-BELNR.
6505   *    ZPMED_SUBMIT-GJAHR.
6506   *    ZPMED_SUBMIT-BUKRS.
6507   *    ZPMED_SUBMIT-STGRD
6508   *    ZPMED_SUBMIT-BUDAT
6509   *IST_9920_REV-LOT No. "8000000429
6510
6511       data : l_bvorg type bkpf-bvorg.
6512
6513       SELECT single BVORG
6514         into l_bvorg
6515         from bkpf
6516           where BUKRS = ZPMED_SUBMIT-BUKRS
6517             and BELNR = ZPMED_SUBMIT-BELNR
6518             and GJAHR = ZPMED_SUBMIT-GJAHR.
6519
6520       clear: bdc_subrc_rev, wa_messtab, messtab.
6521       refresh: messtab.
6522       if l_bvorg is not initial. " IUT DOC
6523         PERFORM BDC_FBU8 using ZPMED_SUBMIT l_bvorg
6524                CHANGING bdc_subrc_rev . "
6525       else. "non-IUT doc
6526         PERFORM BDC_FB08 using ZPMED_SUBMIT
6527                CHANGING bdc_subrc_rev . "
6528
6529       endif.
6530   * bdc_subrc_rev doesn't give correct indication of BDC's
6531   * success in case of FBU8,
6532   * revised logic: If Reversal doc no. has been updated in BKPF
6533   * => doc has been reversed.
6534
6535       data: L_STBLG type BKPF-STBLG. "Reversal Doc no.
6536
6537       select single STBLG
6538         into L_STBLG
6539           from BKPF
6540             where BUKRS = ZPMED_SUBMIT-BUKRS
6541               and BELNR = ZPMED_SUBMIT-BELNR
6542               and GJAHR = ZPMED_SUBMIT-GJAHR.
6543   *  if bdc_subrc_rev = 0. "BDC successful
6544       if L_STBLG is not INITIAL. " Doc reversed
6545         G_FLAG_REVERSED = 'X'.  "Flag to disable 'REVERSE' buton
6546   **If Document has been reversed, then
6547   * 1. update PA9920
6548   * 2. update ZHRMED_EMP_RECOV table
6549         clear: WA_9920_REV_SEL1, WA_9920_MSG.
6550         LOOP AT IST_9920_REV INTO WA_9920_REV_SEL1 WHERE ZSTATUS = 'PAID'.
6551           l_tabix =   sy-tabix .
6552
6553
6554   **
6555           select COUNT(*)
6556             FROM  ZHRMED_EMP_RECOV
6557             into l_bvorg
6558             where CNTER = WA_9920_REV_SEL1-CNTER.
6559
6560
6561
6562           MOVE-CORRESPONDING WA_9920_REV_SEL1 to WA_9920_MSG.
6563   *    WA_9920_MSG-SPRPS = '' .  "to be retained as ''
6564
6565   *begin of CR 30006427 CAB_ALOK
6566
6567   *  clear WA_9920_MSG-SPRPS
6568   *          WA_9920_MSG-ZSTATUS = 'UNLOCKED'.   "  'REVERSED'.
6569   *          WA_9920_MSG-STBLG = L_STBLG.
6570   *
6571   *          SAVE_PAID_BY_PERNR = WA_9920_MSG-PAID_BY_PERNR.
6572   *          SAVE_PAID_BY_LEVEL = WA_9920_MSG-PAID_BY_LEVEL.
6573   *          SAVE_BELNR  =  WA_9920_MSG-BELNR.
6574
6575   **          SAVE_BUKRS  =  WA_9920_MSG-BUKRS.
6576   *          SAVE_GJAHR  =  WA_9920_MSG-GJAHR.
6577
6578   *          SAVE_CHECKED_BY_PERNR  =  WA_9920_MSG-CHECKED_BY_PERNR.
6579   *          SAVE_CHECKED_BY_LEVEL  =  WA_9920_MSG-CHECKED_BY_LEVEL.
6580
6581   *  WA_9920_MSG-ZSTATUS = 'REVERSED'.
6582   *
6583   *end of CR 30006427  CAB_ALOK
6584
6585
6586   **********************
6587
6588           WA_9920_MSG-ZSTATUS = 'UNLOCKED'.   "  'REVERSED'.
6589           WA_9920_MSG-STBLG = L_STBLG.
6590
6591           SAVE_PAID_BY_PERNR = WA_9920_MSG-PAID_BY_PERNR.
6592           SAVE_PAID_BY_LEVEL = WA_9920_MSG-PAID_BY_LEVEL.
6593           SAVE_BELNR  =  WA_9920_MSG-BELNR.
6594           SAVE_BUKRS  =  WA_9920_MSG-BUKRS.
6595           SAVE_GJAHR  =  WA_9920_MSG-GJAHR.
6596           SAVE_CHECKED_BY_PERNR  =  WA_9920_MSG-CHECKED_BY_PERNR.
6597           SAVE_CHECKED_BY_LEVEL  =  WA_9920_MSG-CHECKED_BY_LEVEL.
6598
6599           clear: WA_9920_MSG-PAID_BY_PERNR,
6600                  WA_9920_MSG-PAID_BY_LEVEL,
6601                  WA_9920_MSG-BELNR,  " FI Doc. no.
6602
6603                  WA_9920_MSG-BUKRS,  " FI Doc. comp. code
6604                  WA_9920_MSG-GJAHR,
6605                  WA_9920_MSG-CHECKED_BY_PERNR,
6606                  WA_9920_MSG-CHECKED_BY_LEVEL.
6607
6608   * functionality of ZHR_MED_PYMT_UPDATE9920_MSG now trifurcated into separate
6609   * FMs (LOCK, UPDATE, UNLOCK) for Payment process
6610           CALL FUNCTION 'ZHR_MED_PYMT_INFO_OPER_9920' DESTINATION 'MMREQ_ASSETNO_CR_RFC'
6611             EXPORTING
6612               OPERATION_TYPE = 'MOD'  "OPERATION of HR_INFOTYPE_OPERATION
6613               LOCK_INDICATOR = ' '
6614             CHANGING
6615               WA_9920_MSG    = WA_9920_MSG.
6616
6617           if WA_9920_MSG-ERROR_FLAG = '1'. "if update Operation failed, then reset the status & other data to original.
6618             WA_9920_MSG-ZSTATUS = 'PAID'.
6619             Clear WA_9920_MSG-STBLG.
6620
6621             WA_9920_MSG-PAID_BY_PERNR = SAVE_PAID_BY_PERNR.
6622             WA_9920_MSG-PAID_BY_LEVEL = SAVE_PAID_BY_LEVEL.
6623             WA_9920_MSG-BELNR = SAVE_BELNR .
6624             WA_9920_MSG-BUKRS = SAVE_BUKRS .
6625             WA_9920_MSG-GJAHR = SAVE_GJAHR .
6626             WA_9920_MSG-CHECKED_BY_PERNR = SAVE_CHECKED_BY_PERNR  .
6627             WA_9920_MSG-CHECKED_BY_LEVEL = SAVE_CHECKED_BY_LEVEL .
6628
6629             clear: WA_9920_MSG-PAID_BY_PERNR,
6630                    WA_9920_MSG-PAID_BY_LEVEL.
6631             clear: WA_9920_MSG-BELNR,
6632                    WA_9920_MSG-BUKRS,
6633                    WA_9920_MSG-GJAHR.
6634           else.
6635             " CR30008930 Updation of tables ZHRHOSPSANCTION and  ZHRHOSPSANC_UTL
6636             " Changes by cab_swetha, specs by cfi_mallik
6637             " changes frm here
6638             Clear : L_GLAC , L_FISCAL_YEAR , L_BUKRS.
6639
6640   * Begin RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
6641   **         if WA_9920_REV_SEL1-SUBTY = '05'.
6642   **              L_GLAC = '200301'.
6643   **            elseif ( WA_9920_REV_SEL1-SUBTY = '03' or WA_9920_REV_SEL1-SUBTY = '06' ).
6644   **              L_GLAC = '200308'.
6645   **            elseif WA_9920_REV_SEL1-SUBTY = '04'.
6646   **              L_GLAC = '200309'.
6647   **            endif.
6648   * End RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
6649
6650             CLEAR: l_persk, l_persg, L_GLAC .
6651             SELECT PERSK PERSG
6652    FROM PA0001 INTO ( L_PERSK , L_PERSG ) UP TO 1 ROWS WHERE PERNR = WA_9920_REV_SEL1-PERNR AND BEGDA =< SY-DATUM AND ENDDA >= SY-DATUM
6653    ORDER BY PRIMARY KEY .
6654    ENDSELECT.
6655
6656             if sy-subrc = 0.
6657
6658               if l_persg = '2'
6659                  or l_persg = 'B' .    " Retd. Employee
6660
6661                 if WA_9920_REV_SEL1-SUBTY = '05'.
6662                   L_GLAC = '0000200301'.
6663                 elseif ( WA_9920_REV_SEL1-SUBTY = '03' or WA_9920_REV_SEL1-SUBTY = '06' ).
6664                   L_GLAC = '0000200308'.
6665                 elseif WA_9920_REV_SEL1-SUBTY = '04'.
6666                   L_GLAC = '0000200309'.
6667                 endif.
6668
6669               elseif l_persg = '1' " Activ. Employee (Officer + Staff)
6670                   or l_persg = '7'
6671                   or l_persg = '8'
6672                   or l_persg = '9'
6673                   or l_persg = 'A'
6674                   or l_persg = 'G'
6675                   or l_persg = 'S'.
6676                 " now determine whether Officer or Staff
6677                 if   l_persk = 'C'    " => officer
6678                   or l_persk = 'D'
6679                   or l_persk = 'E0'
6680                   or l_persk = 'E1'
6681                   or l_persk = 'E2'
6682                   or l_persk = 'E3'
6683                   or l_persk = 'E4'
6684                   or l_persk = 'E5'
6685                   or l_persk = 'E6'
6686                   or l_persk = 'E7'
6687                   or l_persk = 'E8'
6688                   or l_persk = 'E9'
6689                   or l_persk = 'GT'.
6690
6691                   if WA_9920_REV_SEL1-SUBTY = '05'.
6692                     L_GLAC = '0000200301'.
6693                   elseif ( WA_9920_REV_SEL1-SUBTY = '03' or WA_9920_REV_SEL1-SUBTY = '06' ).
6694                     L_GLAC = '0000200307'.
6695                   elseif WA_9920_REV_SEL1-SUBTY = '04'.
6696                     L_GLAC = '0000200302'.
6697                   endif.    "//officer
6698
6699                 elseif l_persk = 'A1'    " => Staff
6700                     or l_persk = 'A2'
6701                     or l_persk = 'A3'
6702                     or l_persk = 'A4'
6703                     or l_persk = 'S1'
6704                     or l_persk = 'S2'
6705                     or l_persk = 'S3'
6706                     or l_persk = 'S4'
6707                     or l_persk = 'TC'
6708                     or l_persk = 'W1'
6709                     or l_persk = 'W2'
6710                     or l_persk = 'W3'
6711                     or l_persk = 'W4'
6712                     or l_persk = 'W5'
6713                     or l_persk = 'W6'
6714                     or l_persk = 'W7'.
6715
6716                   if WA_9920_REV_SEL1-SUBTY = '05'.
6717                     L_GLAC = '0000200301'.
6718                   elseif ( WA_9920_REV_SEL1-SUBTY = '03' or WA_9920_REV_SEL1-SUBTY = '06' ).
6719                     L_GLAC = '0000200318'.
6720                   elseif WA_9920_REV_SEL1-SUBTY = '04'.
6721                     L_GLAC = '0000200317'.
6722                   endif.
6723                 endif. "//staff
6724   * Begin RD1K997486 CAB_ALOK Medical Vendor pymt for Contingent workers -CR 30012858
6725               elseif l_persg = 'C'.  "Contingent worker
6726   *              if l_persk = 'C1'    "
6727   *                   or l_persk = 'C2'
6728   *                   or l_persk = 'C3'.
6729                   L_GLAC = '0000200350'.
6730   *              endif.
6731   * End RD1K997486 CAB_ALOK Medical Vendor pymt for Contingent workers -CR 30012858
6732               endif.
6733             endif. "sy-subrc  " // GL Account logic.
6734
6735             L_FISCAL_YEAR = WA_9920_REV_SEL1-GJAHR.
6736
6737
6738   * Begin RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
6739
6740             data: major_head type HKONT.
6741
6742
6743   * Begin RD1K992265 CAB_ALOK CR 30010881
6744             if G_BUDAT < '20140401' .
6745   * End RD1K992265 CAB_ALOK CR 30010881
6746
6747               case  L_GLAC.
6748
6749                 when '0000200301'.
6750                   major_head = '0000200301'.
6751
6752   *begin RD1K991981 CAB_ALOK Changes in ZHRHOSP Sanction Process CR : 30010772
6753   *          when '0000200302' or '0000200307' or '0000200308' or '0000200309' or
6754   *                 '0000200317' or '0000200318'.
6755   *            major_head = '0000200302'.
6756
6757   * Begin RD1K992265 CAB_ALOK CR 30010881
6758   *          when '0000200302' or '0000200307' or '0000200317' or '0000200318'.
6759   *              major_head = '0000200302'.
6760   *
6761   *          when  '0000200308' or '0000200309' .
6762   *               major_head = '0000200309'.
6763
6764                 when '0000200302' or '0000200307' or '0000200308' or '0000200309' or
6765                        '0000200317' or '0000200318'.
6766                   major_head = '0000200302'.
6767
6768   * end RD1K992265 CAB_ALOK  CR 30010881
6769   *end RD1K991981 CAB_ALOK Changes in ZHRHOSP Sanction Process CR : 30010772
6770               endcase.
6771
6772   * Begin RD1K992265 CAB_ALOK CR 30010881
6773             else. " posting dt >= '20140401'
6774
6775               case  L_GLAC.
6776
6777                 when '0000200301'.
6778                   major_head = '0000200301'.
6779
6780                 when '0000200302' or '0000200307' or '0000200317' or '0000200318'.
6781                   major_head = '0000200302'.
6782
6783                 when  '0000200308' or '0000200309' .
6784                   major_head = '0000200309'.
6785
6786   *Begin RD1K997486  CAB_ALOK  Medical Vendor pymt for Contingent workers -CR 30012858
6787                 when  '0000200350' .
6788                   major_head = '0000200350'.
6789   *End RD1K997486   CAB_ALOK  Medical Vendor pymt for Contingent workers -CR 30012858
6790
6791               endcase.
6792
6793   * End RD1K992265 CAB_ALOK CR 30010881
6794             endif.
6795
6796   * for handling GL A/c prefix issue. (add 0000 to GL A/c)
6797             CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
6798               EXPORTING
6799                 INPUT  = major_head
6800               IMPORTING
6801                 OUTPUT = major_head.
6802
6803
6804   * Begin RD1K996216  CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
6805   ** get secco
6806   data: l_secco TYPE secco.
6807   data: L_WA_9920_REV  TYPE ty_pay.
6808
6809   READ TABLE IST_9920_REV INTO L_WA_9920_REV INDEX 1.
6810   IF sy-subrc = 0.
6811     SELECT SECCO FROM BSEG
6812    INTO L_SECCO UP TO 1 ROWS WHERE BUKRS = L_WA_9920_REV-BUKRS AND BELNR = L_WA_9920_REV-BELNR AND GJAHR = L_WA_9920_REV-GJAHR AND KOART = 'K'
6813    ORDER BY PRIMARY KEY .
6814    ENDSELECT.
6815
6816   Else.
6817     MESSAGE e067(ZHR) with L_SECCO .
6818   ENDIF.
6819   * End RD1K996216  CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
6820
6821   **    SELECT SINGLE BUKRS FROM PA0001 INTO L_BUKRS WHERE pernr = sy-uname
6822   **        and begda <= sy-datum and endda >= sy-datum .
6823   *above code doesn't work for CoreTeam members
6824             L_BUKRS = WA_9920_REV_SEL1-GRPVL.
6825   * This check should be applicable for Fiscal year equal to or greater
6826   *than 2013.
6827             If L_FISCAL_YEAR => '2013'.
6828   * This check should be excluded for the company codes in table
6829   *ZFIHOSPBUKRSEXEM.
6830               clear WA_ZFIHOSPBUKRSEXEM.
6831               select single bukrs
6832                 from ZFIHOSPBUKRSEXEM
6833                 into WA_ZFIHOSPBUKRSEXEM-BUKRS
6834                 where bukrs = WA_9920_REV_SEL1-GRPVL.
6835
6836   *  if WA_ZFIHOSPBUKRSEXEM-BUKRS = ''.
6837   **instead of skipping all the checks and updation for
6838   * exempted company codes, give msg and update utilization
6839   * with -ve values (if any).
6840
6841
6842   * End RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
6843
6844               Refresh ist_zhrhospsanction.
6845               Select * from zhrhospsanction into corresponding fields of table ist_zhrhospsanction
6846                 where BUKRS = L_BUKRS
6847   * Begin RD1K996216  CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
6848                       AND SECCO = L_SECCO
6849   * End RD1K996216  CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
6850   * Begin RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
6851   *           and GLHEAD = L_GLAC
6852                      and GLHEAD = major_head
6853   * End RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
6854                      and GJAHR = L_FISCAL_YEAR.
6855               Clear t_amt.
6856               Loop at ist_zhrhospsanction into wa_zhrhospsanction.
6857                 t_amt = t_amt + wa_zhrhospsanction-amt.
6858               Endloop.
6859
6860               select single * from zhrhospsanc_utl into  wa_zhrhospsanc_utl
6861                    where BUKRS = L_BUKRS
6862   * Begin RD1K996216  CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
6863                       AND SECCO = L_SECCO
6864   * End RD1K996216  CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
6865   * Begin RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
6866   *           and GLHEAD = L_GLAC
6867                      and GLHEAD = major_head
6868   * End RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
6869                      and GJAHR = L_FISCAL_YEAR.
6870               If sy-subrc = 0.
6871   * Begin RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
6872   *        wa_zhrhospsanc_utl-utilamt = wa_zhrhospsanc_utl-utilamt + WA_9920_REV_SEL1-ZAMOUNT.
6873                 wa_zhrhospsanc_utl-utilamt = wa_zhrhospsanc_utl-utilamt - WA_9920_REV_SEL1-ZAMOUNT.
6874   * End RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
6875
6876   *        wa_zhrhospsanction-utilamt = wa_zhrhospsanction-utilamt - WA_9920_PAY-ZAMTPCSTOTAL.
6877   *        wa_zhrhospsanction-balamt = wa_zhrhospsanction-amt - wa_zhrhospsanction-utilamt.
6878                 wa_zhrhospsanc_utl-balamt = t_amt - wa_zhrhospsanc_utl-utilamt.
6879   *        wa_zhrhospsanc_utl-amt = t_amt.
6880                 Modify zhrhospsanc_utl from wa_zhrhospsanc_utl .
6881                 Commit Work.
6882               Else.
6883   * Begin RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
6884   *        Message e028(ZHR)   .
6885   *        Message e028(ZHR) with L_BUKRS  L_GLAC L_FISCAL_YEAR .
6886   * Begin RD1K996216  CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
6887   *         Message e028(ZHR) with L_BUKRS  major_head L_FISCAL_YEAR .
6888             Message e028(ZHR) with L_BUKRS L_SECCO major_head L_FISCAL_YEAR .
6889
6890   * End RD1K996216  CAB_ALOK  New Sanction Process in ZHRHOSP - CR 30011991
6891
6892
6893
6894   * End RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
6895               Endif.
6896
6897   * Begin RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
6898
6899
6900   *      endif. " // WA_ZFIHOSPBUKRSEXEM-BUKRS = ''.
6901             endif.  "// L_FISCAL_YEAR => '2013'.
6902   * End RD1K984471 CAB_ALOK ZHRHOSP and ZHRNEHOSP sanction limits - Addl - CR 30008930
6903
6904           endif.
6905           MOVE-CORRESPONDING WA_9920_MSG to WA_9920_REV_SEL1.
6906
6907           MODIFY IST_9920_REV FROM WA_9920_REV_SEL1 INDEX l_tabix.
6908           MOVE-CORRESPONDING WA_9920_REV_SEL1 to WA_PA9920.
6909           CLEAR: WA_9920_REV_SEL1, WA_9920_MSG.
6910   *        CLEAR:  WA_9920_MSG.
6911
6912   * 2. insert Negative (Credit) entry into the Recovery_amt field of the ZHRMED_EMP_RECOV table .
6913           " Modify table ZHRMED_EMP_RECOV
6914
6915           WA_PA9920-MANDT = sy-mandt.
6916           if WA_PA9920-ZADV_TKN > 0.  " recovery amt exists
6917
6918             MOVE-CORRESPONDING WA_PA9920 to WA_ZHRMED_EMP_RECOV .
6919
6920   ***begin of CR 30006427 CAB_ALOK
6921   ***            L_RECOVERY_AMT = -1 * WA_PA9920-ZADV_TKN .
6922             WA_ZHRMED_EMP_RECOV-RECOVERY_AMT = -1 * WA_PA9920-ZADV_TKN .
6923   ***end of CR 30006427  CAB_ALOK
6924             WA_ZHRMED_EMP_RECOV-RECOVERY_TYPE = 'REVERSAL'.
6925   *
6926   ***   WA_ZHRMED_EMP_RECOV-REMARKS .
6927   ***   WA_ZHRMED_EMP_RECOV-VENDOR_NAME
6928
6929   ***begin of CR 30006427 CAB_ALOK
6930             CONCATENATE 'REVERSAL:' WA_PA9920-ZREMARKS ':' l_bvorg into WA_ZHRMED_EMP_RECOV-RECOVERY_TYPE.
6931   ***    WA_ZHRMED_EMP_RECOV-UPDATE_STATUS
6932   ***    WA_ZHRMED_EMP_RECOV-CREATED_ON
6933   ***    WA_ZHRMED_EMP_RECOV-CREATED_BY
6934             concatenate 'Lot:' WA_PA9920-ZLOT_NO 'REVERSAL' INTO WA_ZHRMED_EMP_RECOV-REMARKS. "'REVERSAL'. "
6935             WA_ZHRMED_EMP_RECOV-VENDOR_NAME = WA_PA9920-ZHOSPID .
6936
6937   *****end of CR 30006427  CAB_ALOK
6938
6939
6940             WA_ZHRMED_EMP_RECOV-UPDATE_STATUS = 'N' .
6941             WA_ZHRMED_EMP_RECOV-CREATED_ON = sy-datum.
6942             WA_ZHRMED_EMP_RECOV-CREATED_BY = sy-uname.
6943
6944             append WA_ZHRMED_EMP_RECOV to IST_ZHRMED_EMP_RECOV.
6945           endif. "//WA_PA9920-ZADV_TKN
6946           CLEAR:  WA_PA9920, WA_ZHRMED_EMP_RECOV.
6947   *      Clear WA_9920_REV_SEL1 .
6948
6949         ENDLOOP.
6950
6951         if IST_ZHRMED_EMP_RECOV is NOT INITIAL.
6952           insert ZHRMED_EMP_RECOV from table IST_ZHRMED_EMP_RECOV.
6953           COMMIT WORK.
6954         endif.
6955
6956       endif. "//if L_STBLG is not INITIAL.
6957
6958       " Release all the locked PERNRs of the IST_9920_REV after BDC
6959       clear l_tabix.
6960       clear: WA_9920_REV_SEL1, WA_9920_MSG.
6961       LOOP AT IST_9920_REV INTO WA_9920_REV_SEL1.
6962         l_tabix =   sy-tabix .
6963         MOVE-CORRESPONDING WA_9920_REV_SEL1 to WA_9920_MSG.
6964
6965         CALL FUNCTION 'ZHR_MED_PERNR_UNLOCK' DESTINATION 'MMREQ_ASSETNO_CR_RFC'
6966           CHANGING
6967             WA_9920_MSG = WA_9920_MSG.
6968
6969         MOVE-CORRESPONDING WA_9920_MSG to WA_9920_REV_SEL1.
6970
6971         MODIFY IST_9920_REV  FROM  WA_9920_REV_SEL1 INDEX l_tabix.
6972         CLEAR: WA_9920_REV_SEL1 , WA_9920_MSG.
6973       ENDLOOP.
6974   *============*
6975
6976   *     show Popup message
6977       refresh ist_mesg.
6978       cnt = 0.
6979       loop at messtab into wa_messtab.
6980         cnt = cnt + 1.
6981         move wa_messtab-MSGTYP   to ist_mesg-msgty.
6982         move wa_messtab-MSGID     to ist_mesg-msgid.
6983         move wa_messtab-MSGNR to ist_mesg-msgno.
6984         move wa_messtab-MSGV1 to ist_mesg-msgv1.
6985         move wa_messtab-MSGV2 to ist_mesg-msgv2.
6986         move wa_messtab-MSGV3 to ist_mesg-msgv3.
6987         move wa_messtab-MSGV4 to ist_mesg-msgv4.
6988         move cnt to ist_mesg-LINENO.
6989         append ist_mesg.
6990         clear wa_messtab.
6991
6992       endloop.
6993
6994       CALL FUNCTION 'C14Z_MESSAGES_SHOW_AS_POPUP'
6995         TABLES
6996           I_MESSAGE_TAB = ist_mesg.
6997
6998
6999
7000     endif.  "Locks acquired on all the pernrs.
7001
7002   ENDFORM.                    " REVERSE_1005
7003   *Begin RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
7004   *&---------------------------------------------------------------------*
7005   *&      Form  BDC_FBU8
7006   *&---------------------------------------------------------------------*
7007   *       text
7008   *----------------------------------------------------------------------*
7009   *      -->P_ZPMED_SUBMIT  text
7010   *      -->P_L_BVORG  text
7011   *      <--P_BDC_SUBRC_REV  text
7012   *----------------------------------------------------------------------*
7013   FORM BDC_FBU8  USING    P_ZPMED_SUBMIT type ZPMED_SUBMIT
7014                           P_L_BVORG
7015                  CHANGING P_BDC_SUBRC_REV.
7016
7017     data: tmp_date type DATS.
7018     data: l_mode(1).
7019
7020     clear: bdcdata.
7021     refresh: bdcdata.
7022
7023     perform bdc_dynpro      using 'SAPMF05U' '0100'.
7024     perform bdc_field       using 'BDC_CURSOR'
7025                                   'RF05U-BUDAT'.
7026     perform bdc_field       using 'BDC_OKCODE'
7027                                   '=BUCH'.
7028     perform bdc_field       using 'RF05U-BVORG'
7029                                   P_L_BVORG.
7030     perform bdc_field       using 'RF05U-BUKRS'
7031                                   P_ZPMED_SUBMIT-BUKRS.
7032     perform bdc_field       using 'RF05U-GJAHR'
7033                                   P_ZPMED_SUBMIT-GJAHR.
7034     perform bdc_field       using 'RF05U-STGRD'
7035                                   P_ZPMED_SUBMIT-STGRD.
7036
7037   *P_ZPMED_SUBMIT-BUDAT 20120521
7038     clear: tmp_date.
7039     CALL FUNCTION 'ZHR_MED_PYMT_TO_DDMMYYYY'
7040       EXPORTING
7041         YYYYMMDD = P_ZPMED_SUBMIT-BUDAT
7042       IMPORTING
7043         DDMMYYYY = tmp_date.
7044
7045     perform bdc_field       using 'RF05U-BUDAT'
7046                                   tmp_date.
7047     perform bdc_dynpro      using 'SAPMF05U' '0110'.
7048     perform bdc_field       using 'BDC_CURSOR'
7049                                   'RF05U-BVORO'.
7050     perform bdc_field       using 'BDC_OKCODE'
7051                                   '=BACK'.
7052     perform bdc_dynpro      using 'SAPMF05U' '0100'.
7053     perform bdc_field       using 'BDC_OKCODE'
7054                                   '/EENDE'.
7055     perform bdc_field       using 'BDC_CURSOR'
7056                                   'RF05U-BVORG'.
7057
7058   *perform bdc_transaction using 'FBU8'.
7059
7060   *Begin RD1K984216 CAB_ALOK ZHRHOSP chng:Cost Ctr,foregrnd mode etc. - CR 30008840
7061   *  l_mode = 'N'.
7062     data: WA_ZFI_MED_FOREGRND TYPE ZFI_MED_FOREGRND.
7063     SELECT single *
7064       from ZFI_MED_FOREGRND
7065         INTO WA_ZFI_MED_FOREGRND
7066         WHERE UNAME = SY-UNAME.
7067     if sy-subrc = 0. " Logged-in user maintained in ZFI_MED_FOREGRND.
7068   *Begin RD1K985070       CAB_ALOK     Wrong values in ZHRHOSPSANC_UTL-DEBUG - CR 30009233
7069   *      l_mode = 'E'.
7070       l_mode = 'A'.
7071   *End RD1K985070       CAB_ALOK     Wrong values in ZHRHOSPSANC_UTL-DEBUG - CR 30009233
7072
7073     else.
7074       l_mode = 'N'.
7075     endif.
7076   *end RD1K984216 CAB_ALOK ZHRHOSP chng:Cost Ctr,foregrnd mode etc. - CR 30008840
7077
7078
7079     call transaction 'FBU8' using bdcdata mode l_mode messages into messtab.  " 'N', 'E' , 'A', 'P'
7080     P_BDC_SUBRC_REV = sy-subrc.
7081
7082
7083   ENDFORM.                                                    " BDC_FBU8
7084   *&---------------------------------------------------------------------*
7085   *&      Form  BDC_FB08
7086   *&---------------------------------------------------------------------*
7087   *       text
7088   *----------------------------------------------------------------------*
7089   *      -->P_ZPMED_SUBMIT  text
7090   *      <--P_BDC_SUBRC_REV  text
7091   *----------------------------------------------------------------------*
7092   FORM BDC_FB08  USING    P_ZPMED_SUBMIT type ZPMED_SUBMIT
7093                  CHANGING P_BDC_SUBRC_REV.
7094
7095     data: tmp_date type DATS.
7096     data: l_mode(1).
7097
7098     clear: bdcdata.
7099     refresh: bdcdata.
7100
7101     perform bdc_dynpro      using 'SAPMF05A' '0105'.
7102     perform bdc_field       using 'BDC_CURSOR'
7103                                   'BSIS-BUDAT'.
7104     perform bdc_field       using 'BDC_OKCODE'
7105                                   '=BU'.
7106     perform bdc_field       using 'RF05A-BELNS'
7107                                   P_ZPMED_SUBMIT-BELNR.
7108     perform bdc_field       using 'BKPF-BUKRS'
7109                                   P_ZPMED_SUBMIT-BUKRS.
7110     perform bdc_field       using 'RF05A-GJAHS'
7111                                   P_ZPMED_SUBMIT-GJAHR.
7112     perform bdc_field       using 'UF05A-STGRD'
7113                                   P_ZPMED_SUBMIT-STGRD.
7114
7115     clear: tmp_date.
7116     CALL FUNCTION 'ZHR_MED_PYMT_TO_DDMMYYYY'
7117       EXPORTING
7118         YYYYMMDD = P_ZPMED_SUBMIT-BUDAT
7119       IMPORTING
7120         DDMMYYYY = tmp_date.
7121
7122     perform bdc_field       using 'BSIS-BUDAT'
7123                                   tmp_date.
7124   *perform bdc_transaction using 'FB08'.
7125
7126   *Begin RD1K984216 CAB_ALOK ZHRHOSP chng:Cost Ctr,foregrnd mode etc. - CR 30008840
7127   *  l_mode = 'N'.
7128     data: WA_ZFI_MED_FOREGRND TYPE ZFI_MED_FOREGRND.
7129     SELECT single *
7130       from ZFI_MED_FOREGRND
7131         INTO WA_ZFI_MED_FOREGRND
7132         WHERE UNAME = SY-UNAME.
7133     if sy-subrc = 0. " Logged-in user maintained in ZFI_MED_FOREGRND.
7134   *Begin RD1K985070       CAB_ALOK     Wrong values in ZHRHOSPSANC_UTL-DEBUG - CR 30009233
7135   *      l_mode = 'E'.
7136       l_mode = 'A'.
7137   *End RD1K985070       CAB_ALOK     Wrong values in ZHRHOSPSANC_UTL-DEBUG - CR 30009233
7138     else.
7139       l_mode = 'N'.
7140     endif.
7141   *end RD1K984216 CAB_ALOK ZHRHOSP chng:Cost Ctr,foregrnd mode etc. - CR 30008840
7142
7143     call transaction 'FB08' using bdcdata mode l_mode messages into messtab.  " 'N', 'E' , 'A', 'P'
7144     P_BDC_SUBRC_REV = sy-subrc.
7145
7146
7147   ENDFORM.                                                    " BDC_FB08
7148   *end RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
7149
7150   *&---------------------------------------------------------------------*
7151   *&      Form  DOWNLOAD_REPORT
7152   *&---------------------------------------------------------------------*
7153   *       text
7154   *----------------------------------------------------------------------*
7155   *  -->  p1        text
7156   *  <--  p2        text
7157   *----------------------------------------------------------------------*
7158   *begin RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
7159   FORM DOWNLOAD_REPORT .
7160   * Download Status Report
7161
7162   *DATA gt_tpar TYPE TABLE OF tpar.
7163   *SELECT * INTO TABLE gt_tpar FROM tpar.
7164   *        IST_9920_STATUS
7165
7166     types: begin of TY_STATUS_REP,
7167               SERIAL_NO type  i,
7168               PERNR type  PA9920-PERNR ,
7169               SUBTY type  PA9920-SUBTY,
7170               GRPVL type  PA9920-GRPVL,
7171               ZCRDNO  type  PA9920-ZCRDNO,
7172               PATIENT_NAME(80),
7173               ZLOT_NO type  PA9920-ZLOT_NO  ,
7174               CNTER type  PA9920-CNTER  ,
7175               ZHOSPID type  PA9920-ZHOSPID  ,
7176               ZBILL_NO  type  PA9920-ZBILL_NO ,
7177   *          ZBILL_DATE  type  PA9920-ZBILL_DATE ,
7178               ZBILL_DATE_CHAR(10),
7179               ZILLNESS  type  PA9920-ZILLNESS ,
7180   *          ZDATE_FROM  type  PA9920-ZDATE_FROM,
7181               ZDATE_FROM_CHAR(10),
7182   *          ZDATE_TO  type  PA9920-ZDATE_TO ,
7183               ZDATE_TO_CHAR(10),
7184               ZAMOUNT type  PA9920-ZAMOUNT  ,
7185               ZADV_TKN  type  PA9920-ZADV_TKN ,
7186               ZREMARKS  type  PA9920-ZREMARKS,
7187               ZAMTMOTOTAL type  PA9920-ZAMTMOTOTAL,
7188               ZREMARKSMO  type  PA9920-ZREMARKSMO ,
7189               ZAMTPCSTOTAL  type  PA9920-ZAMTPCSTOTAL,
7190               ZREMARKSPCS type  PA9920-ZREMARKSPCS  ,
7191               ZREF_NO type  PA9920-ZREF_NO  ,
7192               ZSTATUS type  PA9920-ZSTATUS  ,
7193   *          BEGDA type  PA9920-BEGDA,
7194               BEGDA_CHAR(10),
7195               UNAME type  PA9920-UNAME,
7196   *          AEDTM type  PA9920-AEDTM,
7197               AEDTM_CHAR(10),
7198            end of TY_STATUS_REP .
7199     data:   IST_9920_STATUS_REP TYPE STANDARD TABLE OF TY_STATUS_REP,
7200             WA_9920_STATUS_REP TYPE TY_STATUS_REP.
7201
7202     DATA : " XXL_SIMPLE_API parameters and tables
7203             es_filename LIKE gxxlt_f-file, " File name on the workstation
7204             es_header LIKE gxxlt_p-text, " XXL interface: texts for printing a list
7205             ls_col_text TYPE gxxlt_v,
7206             lt_col_text TYPE TABLE OF gxxlt_v, " Headings for DATA columns
7207             ls_online_text TYPE gxxlt_o,
7208             lt_online_text TYPE TABLE OF gxxlt_o, " Table with online texts
7209             ls_print_text TYPE gxxlt_p,
7210             lt_print_text TYPE TABLE OF gxxlt_p. " Table with print texts
7211
7212   *Prepare Data for downloading
7213     clear WA_9920_STATUS.
7214     Loop at IST_9920_STATUS INTO WA_9920_STATUS.
7215       MOVE-CORRESPONDING WA_9920_STATUS to WA_9920_STATUS_REP.
7216
7217       CALL FUNCTION 'ZHR_MED_PYMT_TO_DD_MM_YYYY'
7218         EXPORTING
7219           YYYYMMDD   = WA_9920_STATUS-ZBILL_DATE
7220         IMPORTING
7221           DD_MM_YYYY = WA_9920_STATUS_REP-ZBILL_DATE_CHAR.
7222
7223       CALL FUNCTION 'ZHR_MED_PYMT_TO_DD_MM_YYYY'
7224         EXPORTING
7225           YYYYMMDD   = WA_9920_STATUS-ZDATE_FROM
7226         IMPORTING
7227           DD_MM_YYYY = WA_9920_STATUS_REP-ZDATE_FROM_CHAR.
7228
7229       CALL FUNCTION 'ZHR_MED_PYMT_TO_DD_MM_YYYY'
7230         EXPORTING
7231           YYYYMMDD   = WA_9920_STATUS-ZDATE_TO
7232         IMPORTING
7233           DD_MM_YYYY = WA_9920_STATUS_REP-ZDATE_TO_CHAR.
7234
7235       CALL FUNCTION 'ZHR_MED_PYMT_TO_DD_MM_YYYY'
7236         EXPORTING
7237           YYYYMMDD   = WA_9920_STATUS-BEGDA
7238         IMPORTING
7239           DD_MM_YYYY = WA_9920_STATUS_REP-BEGDA_CHAR.
7240
7241       CALL FUNCTION 'ZHR_MED_PYMT_TO_DD_MM_YYYY'
7242         EXPORTING
7243           YYYYMMDD   = WA_9920_STATUS-AEDTM
7244         IMPORTING
7245           DD_MM_YYYY = WA_9920_STATUS_REP-AEDTM_CHAR.
7246
7247       APPEND WA_9920_STATUS_REP TO IST_9920_STATUS_REP.
7248
7249     ENDLOOP.
7250
7251     es_filename = 'MEDICAL_VENDOR_PAYMENT_STATUS.xls'.
7252     es_header = 'SAP MVPS Table Contents'.
7253
7254   * Headings for DATA columns
7255     ls_col_text-col_no = '1'.
7256     ls_col_text-col_name = 'Serial_no'.
7257     APPEND ls_col_text TO lt_col_text.
7258
7259     ls_col_text-col_no = '2'.
7260     ls_col_text-col_name = 'CPF_No'.
7261     APPEND ls_col_text TO lt_col_text.
7262
7263     ls_col_text-col_no = '3'.
7264     ls_col_text-col_name = 'Facility'.
7265     APPEND ls_col_text TO lt_col_text.
7266
7267     ls_col_text-col_no = '4'.
7268     ls_col_text-col_name = 'Company'.
7269     APPEND ls_col_text TO lt_col_text.
7270
7271     ls_col_text-col_no = '5'.
7272     ls_col_text-col_name = 'Card_No'.
7273     APPEND ls_col_text TO lt_col_text.
7274
7275     ls_col_text-col_no = '6'.
7276     ls_col_text-col_name = 'Patient_Name'.
7277     APPEND ls_col_text TO lt_col_text.
7278
7279     ls_col_text-col_no = '7'.
7280     ls_col_text-col_name = 'Lot_No.'.
7281     APPEND ls_col_text TO lt_col_text.
7282
7283     ls_col_text-col_no = '8'.
7284     ls_col_text-col_name = 'Submission_No'.
7285     APPEND ls_col_text TO lt_col_text.
7286
7287     ls_col_text-col_no = '9'.
7288     ls_col_text-col_name = 'Vendor'.
7289     APPEND ls_col_text TO lt_col_text.
7290
7291     ls_col_text-col_no = '10'.
7292     ls_col_text-col_name = 'Bill_No_'.
7293     APPEND ls_col_text TO lt_col_text.
7294
7295     ls_col_text-col_no = '11'.
7296     ls_col_text-col_name = 'Bill_Date_'.
7297     APPEND ls_col_text TO lt_col_text.
7298
7299     ls_col_text-col_no = '12'.
7300     ls_col_text-col_name = 'Illness'.
7301     APPEND ls_col_text TO lt_col_text.
7302
7303     ls_col_text-col_no = '13'.
7304     ls_col_text-col_name = 'Date_From'.
7305     APPEND ls_col_text TO lt_col_text.
7306
7307     ls_col_text-col_no = '14'.
7308     ls_col_text-col_name = 'Date_To'.
7309     APPEND ls_col_text TO lt_col_text.
7310
7311     ls_col_text-col_no = '15'.
7312     ls_col_text-col_name = 'Amount'.
7313     APPEND ls_col_text TO lt_col_text.
7314
7315     ls_col_text-col_no = '16'.
7316     ls_col_text-col_name = 'Recovery_Amt'.
7317     APPEND ls_col_text TO lt_col_text.
7318
7319     ls_col_text-col_no = '17'.
7320     ls_col_text-col_name = 'DO_Remarks'.
7321     APPEND ls_col_text TO lt_col_text.
7322
7323     ls_col_text-col_no = '18'.
7324     ls_col_text-col_name = 'MO_Amount'.
7325     APPEND ls_col_text TO lt_col_text.
7326
7327     ls_col_text-col_no = '19'.
7328     ls_col_text-col_name = 'MO_Remarks'.
7329     APPEND ls_col_text TO lt_col_text.
7330
7331     ls_col_text-col_no = '20'.
7332     ls_col_text-col_name = 'PCS_Amount'.
7333     APPEND ls_col_text TO lt_col_text.
7334
7335     ls_col_text-col_no = '21'.
7336     ls_col_text-col_name = 'PCS_Remarks'.
7337     APPEND ls_col_text TO lt_col_text.
7338
7339     ls_col_text-col_no = '22'.
7340     ls_col_text-col_name = 'Ref_No'.
7341     APPEND ls_col_text TO lt_col_text.
7342
7343     ls_col_text-col_no = '23'.
7344     ls_col_text-col_name = 'Status_'.
7345     APPEND ls_col_text TO lt_col_text.
7346
7347     ls_col_text-col_no = '24'.
7348     ls_col_text-col_name = 'Creation_Date'.
7349     APPEND ls_col_text TO lt_col_text.
7350
7351     ls_col_text-col_no = '25'.
7352     ls_col_text-col_name = 'Submit/Chng_By'.
7353     APPEND ls_col_text TO lt_col_text.
7354
7355     ls_col_text-col_no = '26'.
7356     ls_col_text-col_name = 'Last_Chng_On'.
7357     APPEND ls_col_text TO lt_col_text.
7358
7359
7360
7361     CALL FUNCTION 'XXL_SIMPLE_API'
7362       EXPORTING
7363         filename          = es_filename " File name on the workstation
7364         header            = es_header " Heading for exported list object
7365         n_key_cols        = 2 " Number of (hierarchical) key columns
7366       TABLES
7367         col_text          = lt_col_text
7368         data              = IST_9920_STATUS_REP
7369         online_text       = lt_online_text
7370         print_text        = lt_print_text
7371       EXCEPTIONS
7372         dim_mismatch_data = 1 " Non-present DATA column is referenced
7373         file_open_error   = 2 " File FILENAME cannot be opened
7374         file_write_error  = 3 " File FILENAME cannot be written to
7375         inv_winsys        = 4 " Wrong window system, DOS windows required
7376         inv_xxl           = 5 " Installation at the frontend incorrect
7377         OTHERS            = 6.
7378     IF sy-subrc <> 0.
7379       MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
7380       WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
7381     ENDIF.
7382
7383
7384
7385
7386   ENDFORM.                    " DOWNLOAD_REPORT
7387   *end RD1K979590 CAB_ALOK CR 30006427:New features in ZHRHOSP
7388   *&---------------------------------------------------------------------*
7389   *&      Form  FUND_MGMT_ROLE_AUTH
7390   *&---------------------------------------------------------------------*
7391   *       text
7392   *----------------------------------------------------------------------*
7393   *  -->  p1        text
7394   *  <--  p2        text
7395   *----------------------------------------------------------------------*
7396   * Begin RD1K985179 CAB_ALOK Budget role for ZHRHOSP - CR 30009272
7397   ** now separate role for medical fund mgmt, hence commented
7398   *FORM FUND_MGMT_ROLE_AUTH .
7399   *data: WA_AGR_USERS_FM type AGR_USERS.
7400   *
7401   *  select single * from agr_users  " WA_AGR_USERS-AGR_NAME
7402   *     into wa_agr_users_fm
7403   *       where uname = sy-uname
7404   *         and ( agr_name = 'D:PSM_BDGT_COORD_BASE_ROLE_ONG'
7405   *               or agr_name = 'D:PSM_FUND_VRFR_BASE_ROLE_ONGC'
7406   *                or agr_name = 'D:PSM_BDGT_COORD_BASE_ROLE_OVL'
7407   *                or agr_name = 'D:PSM_FUND_VRFR_BASE_ROLE_OVL' )
7408   *         and from_dat <=   sy-datum
7409   *         and   to_dat >=  sy-datum.
7410   *
7411   *  if wa_agr_users_fm-agr_name is initial.
7412   *    message id 'ZMSG' type 'E' number '000' with 'No authorization to run the application' .
7413   *  endif.
7414
7415   *ENDFORM.                    " FUND_MGMT_ROLE_AUTH
7416   * End RD1K985179 CAB_ALOK Budget role for ZHRHOSP - CR 30009272
*--- End of MZPZ9920_MED_INPATIENT_F01 - 7416 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CCNDD                                   Level 1    Page 6
Object           SAPMZPZ9920_MED_INPATIENT                 Lines 31
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:24
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
Generated incl.  %_CCNDP                                   Level 1    Page 7
Object           SAPMZPZ9920_MED_INPATIENT                 Lines 99
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:24
----------------------------------------------------------------------------------------------------
1      * Type Pool for DataProvider
2      TYPE-POOL CNDP.
3      TYPE-POOLS OLE2.
4
5
6      TYPES CNDP_MEDIUM(40).
7
8      CONSTANTS: CNDP_MEDIUM_OBJECT   TYPE CNDP_MEDIUM VALUE 'OBJECT'.
9      * THESE MEDIA ARE OBSOLETE
10     * CONSTANTS: CNDP_MEDIUM_FILE     TYPE CNDP_MEDIUM VALUE 'FILE'.
11     * CONSTANTS: CNDP_MEDIUM_HANDLE   TYPE CNDP_MEDIUM VALUE 'HANDLE'.
12     CONSTANTS: CNDP_MEDIUM_STREAM   TYPE CNDP_MEDIUM VALUE 'STREAM'.
13     CONSTANTS: CNDP_MEDIUM_DATA     TYPE CNDP_MEDIUM VALUE 'DATA'.
14     CONSTANTS: CNDP_MEDIUM_R3TABLE  TYPE CNDP_MEDIUM VALUE 'R3TABLE'.
15
16     * Default name space for ABAP internal data
17     * DO NOT MODIFY, NAMESPACE IS ALSO CODED ON CLIEND SITE
18     CONSTANTS: CNDP_SAP_URL_NAMESPACE(8)     TYPE C VALUE 'SAPR3://'.
19     * Pseudo MIME Type for internal tables
20     * DO NOT MODIFY, TYPE IS ALSO CODED ON CLIEND SITE
21     CONSTANTS: CNDP_SAP_TAB_MIMETYPE(11)     TYPE C VALUE  'APPLICATION'.
22     CONSTANTS: CNDP_SAP_TAB_MIMESUBTYPE(9)   TYPE C VALUE  'X-R3TABLE'.
23     * Pseudo MIME Type for internal tables presented as rowsets
24     * DO NOT MODIFY, TYPE IS ALSO CODED ON CLIEND SITE
25     CONSTANTS: CNDP_SAP_ROWSET_MIMETYPE(11)   TYPE C VALUE  'APPLICATION'.
26     CONSTANTS: CNDP_SAP_ROWSET_MIMESUBTYPE(8) TYPE C VALUE 'X-ROWSET'.
27
28     CONSTANTS: CNDP_SAP_CTXMNU_MIMETYPE(11)    TYPE C VALUE 'APPLICATION'.
29     CONSTANTS: CNDP_SAP_CTXMNU_MIMESUBTYPE(12) TYPE C VALUE 'X-SAPCTXMENU'.
30     * DO NOT MODIFY, TYPE IS ALSO CODED ON CLIEND SITE
31     CONSTANTS: CNDP_SAP_DD_MIMETYPE(11)    TYPE C VALUE 'APPLICATION'.
32     CONSTANTS: CNDP_SAP_DD_MIMESUBTYPE(12) TYPE C VALUE 'X-SAPDDBEHAV'.
33
34
35
36     CONSTANTS: CNDP_SAP_TAB_UNKNOWN(9)       TYPE C VALUE  'X-UNKNOWN'.
37
38     CONSTANTS: CNDP_SAP_TYPE_UNKNOWN(11)     TYPE C VALUE  'APPLICATION'.
39     CONSTANTS: CNDP_SAP_SUBTYPE_UNKNOWN(9)   TYPE C VALUE  'X-UNKNOWN'.
40     * Pseudo MIME Type large parameters in Automation Queue
41     * DO NOT MODIFY, TYPE IS ALSO CODED IN CLIENT SITE
42     CONSTANTS: CNDP_SAP_LACPARAM_TYPE(11)      TYPE C VALUE  'APPLICATION'.
43     CONSTANTS: CNDP_SAP_LACPARAM_SUBTYPE(12)   TYPE C VALUE  'X-SAPACLPARA'.
44     * Lifetimeflag for LocalTable Entries
45     CONSTANTS: CNDP_LIFETIME_VOLATILE TYPE C VALUE '1'.
46     CONSTANTS: CNDP_LIFETIME_TRANSACTION TYPE C VALUE 'T'.
47     * Cannot delete above constant, since it is already in use.
48     * CONSTANTS: CNDP_LIFETIME_IMODE TYPE C VALUE 'I'.
49     CONSTANTS: CNDP_LIFETIME_ALL TYPE C VALUE 'X'.   "over all transactions in a session
50     CONSTANTS: CNDP_LIFETIME_CACHE TYPE C VALUE 'C'. "as long as it lives in the cache, use only for dp_publish_url
51
52     * Structure for UserInfo in DataProvider
53     TYPES: BEGIN OF CNDP_USER_INFO,
54            USER TYPE OLE2_PARAMETER,           " Username am Server
55            PASSWORD TYPE OLE2_PARAMETER,       " Password am Server
56            PROXY TYPE OLE2_PARAMETER,          " Proxy (incl. Port)
57            PROXYUSER TYPE OLE2_PARAMETER,      "User am Proxy
58            PROXYPASSWORD TYPE OLE2_PARAMETER,  "Password am Proxy
59            SCRAMBLED,                           " Flag ob verschlüsselt
60            END OF CNDP_USER_INFO.
61     * RFC_FIELDS Table Type
62     TYPES CNDP_FIELDSTAB TYPE STANDARD TABLE OF RFC_FIELDS
63                             with default key.
64     TYPES CNDP_PROPSTAB TYPE standard TABLE OF DPPROPS
65                             with default key.
66
67
68
69     TYPES : BEGIN OF CNDP_TDataChangeField,
70                ColIdx type i,
71                value type string,
72             END OF CNDP_TDataChangeField.
73     TYPES : CNDP_TDataChangeTab type standard table of
74                  CNDP_TDataChangeField with default key.
75
76     TYPES : cndp_XML_STREAM_LINE(255) TYPE C.
77     TYPES : cndp_XML_STREAM_TAB_TYPE TYPE STANDARD TABLE OF
78                  cndp_XML_STREAM_LINE with default key.
79
80     * Constants for uopload download errortreatment
81     * Success codes
82     CONSTANTS: CNDP_SUCCESS                 TYPE I VALUE 0.
83     CONSTANTS: CNDP_SUCCESS_FAIL            TYPE I VALUE 1.
84     * Error codes
85     CONSTANTS: CNDP_FAIL_UNKNOWN            TYPE I VALUE -1.
86     CONSTANTS: CNDP_FAIL_NOTFOUND           TYPE I VALUE -2.
87     CONSTANTS: CNDP_FAIL_ACCESSDENIED       TYPE I VALUE -3.
88     CONSTANTS: CNDP_FAIL_OUTOFMEM           TYPE I VALUE -4.
89     CONSTANTS: CNDP_FAIL_OUTOFDISKSPACE     TYPE I VALUE -5.
90     CONSTANTS: CNDP_FAIL_TIMEOUT            TYPE I VALUE -6.
91
92     TYPES : CNDP_ASYNC_KEY(210) TYPE C.
93     TYPES : CNDP_ASYNC_NAME(30) TYPE C.
94     TYPES : CNDP_URL(256) TYPE C.
95
96
97     *
98     CONSTANTS: CNDP_ASYNC_WEB_NAMESPACE TYPE CNDP_ASYNC_NAME
99                               VALUE 'WebRepository'.
*--- End of %_CCNDP - 99 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CCNTL                                   Level 1    Page 8
Object           SAPMZPZ9920_MED_INPATIENT                 Lines 138
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:24
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
Object           SAPMZPZ9920_MED_INPATIENT                 Lines 15
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:24
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
Object           SAPMZPZ9920_MED_INPATIENT                 Lines 6
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:24
----------------------------------------------------------------------------------------------------
1      TYPE-POOL CXTAB .
2
3      TYPES:
4             CXTAB_COLUMN type scxtab_column,
5             CXTAB_CONTROL type scxtab_control,
6             CXTAB_TABSTRIP type scxtab_tabstrip.
*--- End of %_CCXTAB - 6 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CESP1                                   Level 1    Page 11
Object           SAPMZPZ9920_MED_INPATIENT                 Lines 486
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:24
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
Generated incl.  %_COLE2                                   Level 1    Page 12
Object           SAPMZPZ9920_MED_INPATIENT                 Lines 43
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:24
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
Generated incl.  %_CVRM                                    Level 1    Page 13
Object           SAPMZPZ9920_MED_INPATIENT                 Lines 30
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:24
----------------------------------------------------------------------------------------------------
1      TYPE-POOL VRM .
2
3      TYPES:
4      *-- Single Value in Value Set
5             BEGIN OF VRM_VALUE,
6               KEY(40) TYPE C,
7               TEXT(80) TYPE C,
8             END OF VRM_VALUE,
9      *-- Table of Values
10            VRM_VALUES TYPE VRM_VALUE OCCURS 0,
11     *-- Id of Value Set
12            VRM_ID TYPE VRM_VALUE-TEXT,
13     *-- table of Ids of Value Set
14            VRM_IDS TYPE VRM_ID OCCURS 0,
15     *-- QueueRow
16            BEGIN OF VRM_QUEUEROW,
17              TAG,
18              VALUE TYPE VRM_VALUE,
19            END   OF VRM_QUEUEROW,
20     *-- Queue
21            VRM_QUEUE TYPE VRM_QUEUEROW OCCURS 0.
22
23     CONSTANTS:
24       VRM_TYPE(20)                          VALUE 'application',
25       VRM_SUBTYPE(20)                       VALUE 'x-sapvaluesets',
26       VRM_QUEUE_TAG_HEADER                  VALUE 'T',
27       VRM_QUEUE_TAG_SUBHEADER               VALUE 'X',
28       VRM_QUEUE_TAG_ENTRY                   VALUE ' ',
29       VRM_QUEUE_KEY_TYPE TYPE VRM_VALUE-KEY VALUE 'TYPE',
30       VRM_QUEUE_KEY_NAME TYPE VRM_VALUE-KEY VALUE 'NAME'.
*--- End of %_CVRM - 30 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  <CONTRO>                                  Level 1    Page 14
Object           SAPMZPZ9920_MED_INPATIENT                 Lines 76
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:24
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
Generated incl.  <REPINI>                                  Level 1    Page 15
Object           SAPMZPZ9920_MED_INPATIENT                 Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:24
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
Object           SAPMZPZ9920_MED_INPATIENT                 Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:24
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
Object           SAPMZPZ9920_MED_INPATIENT                 Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:24
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
