----------------------------------------------------------------------------------------------------
Main program     SAPMZPSJVCCFCFORMS                        Level 0    Page 1
Object           SAPMZPSJVCCFCFORMS                        Lines 46
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:21
----------------------------------------------------------------------------------------------------
1      ***********************************************************************
2      * Program    : SAPMZPSJVCCFCFORMS                                     *
3      *                                                                     *
4      * Title      : OVL FC/ODI Forms for Cash Call,Venture or Subsidiary   *
5      *                                                                     *
6      * FS No.     : FS_OVL_8000002478_ODISFORM.xlsx                        *
7      *                                                                     *
8      * CR No      : 4000000110 ITSM Incident No : 8000002478               *
9      *                                                                     *
10     * TP Request : 	OCDK906918                                            *
11     *                                                                     *
12     * Author     :  Arvind Chauhan CONSULTANT(SAP-ABAP)                   *
13     *                                                                     *
14     * Date       : 16-Oct-2023                                            *
15     *                                                                     *
16     * Login Id   : SAP_ABAP                                               *
17     *                                                                     *
18     * Description: OVL FC/ODI Forms for Cash Call,Venture or Subsidiary   *
19     *                                                                     *
20     * Tran. Code : ZJVCCFC                                                *
21     *                                                                     *
22     ***********************************************************************
23     * Change History                                                      *
24     *                                                                     *
25     * Mod Date      Changed by            Description            Chng ID  *
26     * 10-Sep-2025   Arvind Chauhan       2 Currency Addition   OCDK908512 *
27     *             CONSULTANT(SAP-ABAP)   in Form B Screen                 *
28     ***********************************************************************
29
30     PROGRAM SAPMZPSJVCCFCFORMS.
31
32     INCLUDE SAPMZPSJVCCFCFORMSTOP.
33
34     INCLUDE SAPMZPSJVCCFCFORMSO01.
35
36     INCLUDE SAPMZPSJVCCFCFORMSI01.
37
38     INCLUDE SAPMZPSJVCCFCFORMSF01.
39
40     INCLUDE mzpsjvccfcforms_get_totals_f01.
41
42     INCLUDE mzpsjvccfcforms_user_commani01.
43
44     INCLUDE mzpsjvccfcforms_status_9001o01.
45
46     INCLUDE mzpsjvccfcforms_user_commani02.
*--- End of SAPMZPSJVCCFCFORMS - 46 lines ---

----------------------------------------------------------------------------------------------------
Include          SAPMZPSJVCCFCFORMSTOP                     Level 1    Page 2
Object           SAPMZPSJVCCFCFORMS                        Lines 156
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:21
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&  Include           SAPMZPSJVCCFCFORMSTOP
3      *&---------------------------------------------------------------------*
4      TABLES : zjvc_cc_fcforms,
5               zjvc_cc_fcformsb,zjvc_total,
6      *         ZJVCCFC_TOT,
7               zpa0001,
8               zdesignation_rev,
9               z_desig_latest,
10              zpa9930,
11              adr2,
12              adr6 ,
13              dd07t.
14
15     DATA : total_equity_usd     TYPE zcurr_odifcc,
16            total_equity_euro    TYPE zcurr_odifcc,
17            total_equity_gbp     TYPE zcurr_odifcc,
18            total_equity_eq_usd  TYPE zcurr_odifcc,
19            total_equity_eq_usd1 TYPE zcurr_odifcc,
20            total_equity_eq_inr  TYPE zcurr_odifcc,
21            total_equity_eq_inr1  TYPE zcurr_odifcc,
22            total_loan_usd       TYPE zcurr_odifcc,
23            total_loan_euro      TYPE zcurr_odifcc,
24            total_loan_gbp       TYPE zcurr_odifcc,
25            total_loan_eq_usd    TYPE zcurr_odifcc,
26            total_loan_eq_inr    TYPE zcurr_odifcc,
27            total_pg_eq_usd      TYPE zcurr_odifcc,
28            total_pg_eq_inr      TYPE zcurr_odifcc,
29            total_cg_eq_usd      TYPE zcurr_odifcc,
30            total_cg_eq_inr      TYPE zcurr_odifcc.
31
32     DATA :g_ok_100           TYPE sy-ucomm,
33           save_ok            TYPE sy-ucomm,
34           g_ok_105           TYPE sy-ucomm,
35           g_ok_110           TYPE sy-ucomm,
36           g_okcode           LIKE sy-ucomm,
37           g_ok100_cpydoc     TYPE sy-ucomm,
38           g_tstamp           LIKE oifbbp1-ftmstm,
39           g_item_number      TYPE i,
40           g_flag(1)          TYPE c VALUE 'Y',
41           g_answer           TYPE c,                 "YES/NO/CANCEL
42           g_bbpitem          LIKE zjvc_cc_fcformsb-bbpitem VALUE '0',
43           g_curr             TYPE zjvccfc_curr-curr_key,
44           g_curr1            TYPE zjvccfc_curr-curr_key,
45           g_curr2            TYPE zjvccfc_curr-curr_key,
46           g_curr3            TYPE zjvccfc_curr-curr_key,
47           g_curr4            TYPE zjvccfc_curr-curr_key,
48           g_doc_app_text(30) TYPE c.
49
50     DATA:g_forgn_fincommitfcy_uintot    TYPE zjvc_cc_fcforms-forgn_fincommitfcy_uintot,
51          g_forgn_fincommitfcy_ovltot    TYPE zjvc_cc_fcforms-forgn_fincommitfcy_ovltot,
52          g_forgn_fincommitinr_uintot    TYPE zjvc_cc_fcforms-forgn_fincommitinr_uintot,
53          g_forgn_fincommitinr_ovltot    TYPE zjvc_cc_fcforms-forgn_fincommitinr_ovltot,
54          g_forgn_fincommitusd_uintot    TYPE zjvc_cc_fcforms-forgn_fincommitusd_uintot,
55          g_forgn_fincommitusd_ovltot    TYPE zjvc_cc_fcforms-forgn_fincommitusd_ovltot,
56     ***********************************************************************************
57     *Begin ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
58          g_forgn_fincommitgbp_uintot    TYPE zjvc_cc_fcforms-forgn_fincommitgbp_uintot,
59          g_forgn_fincommitgbp_ovltot    TYPE zjvc_cc_fcforms-forgn_fincommitgbp_ovltot,
60          g_forgn_fincommiteur_uintot    TYPE zjvc_cc_fcforms-forgn_fincommiteur_uintot,
61          g_forgn_fincommiteur_ovltot    TYPE zjvc_cc_fcforms-forgn_fincommiteur_ovltot,
62     *End ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
63     ***********************************************************************************
64          g_forgn_fincommitinr_ovltot_op TYPE zjvc_cc_astblk-forgn_fincommitfcy_opnbal,
65          g_forgn_fincommitusd_ovltot_op TYPE zjvc_cc_astblk-forgn_fincommitinr_opnbal,
66          g_forgn_fincommitinr_uintot_op TYPE zjvc_cc_astblk-forgn_fincommitfcy_opnbal,
67          g_forgn_fincommitusd_uintot_op TYPE zjvc_cc_astblk-forgn_fincommitinr_opnbal,
68     ***********************************************************************************
69     *Begin ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
70          g_forgn_fincommitgbp_ovltot_op TYPE zjvc_cc_astblk-forgn_fincommitfcy_opnbal_gbp,
71          g_forgn_fincommiteur_ovltot_op TYPE zjvc_cc_astblk-forgn_fincommitfcy_opnbal_eur,
72          g_forgn_fincommitgbp_uintot_op TYPE zjvc_cc_astblk-forgn_fincommitfcy_opnbal_gbp,
73          g_forgn_fincommiteur_uintot_op TYPE zjvc_cc_astblk-forgn_fincommitfcy_opnbal_eur,
74     *End ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
75     ***********************************************************************************
76          g_resddoctot_ovlusd            TYPE zjvc_cc_fcforms-forgn_fincommitfcy_ovltot,
77          g_resddoctot_ovlinr            TYPE zjvc_cc_fcforms-forgn_fincommitinr_uintot,
78
79          g_resddoctot_uinusd            TYPE zjvc_cc_fcforms-forgn_fincommitfcy_ovltot,
80          g_resddoctot_uininr            TYPE zjvc_cc_fcforms-forgn_fincommitinr_uintot,
81     ***********************************************************************************
82     *Begin ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
83          g_resddoctot_ovlgbp            TYPE zjvc_cc_fcforms-forgn_fincommitgbp_ovltot,
84          g_resddoctot_ovleur            TYPE zjvc_cc_fcforms-forgn_fincommiteur_uintot,
85
86          g_resddoctot_uingbp            TYPE zjvc_cc_fcforms-forgn_fincommitgbp_ovltot,
87          g_resddoctot_uineur            TYPE zjvc_cc_fcforms-forgn_fincommiteur_uintot,
88     *End ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
89     ***********************************************************************************
90          g_ei_forgnenty_uin             TYPE zjvc_cc_fcforms-ei_forgnenty_uin.
91
92     DATA : ist_ovldetails LIKE zjvc_cc_fcforms OCCURS 0 WITH HEADER LINE .
93     DATA : ist_sumovldetails LIKE zjvc_cc_fcforms OCCURS 0 WITH HEADER LINE .
94     DATA : ist_uindetails LIKE zjvc_cc_fcforms OCCURS 0 WITH HEADER LINE .
95     DATA : ist_mastopnbal LIKE zjvc_cc_astblk  OCCURS 0 WITH HEADER LINE .
96     DATA : ist_mastopnbal1 LIKE zjvc_cc_astblk  OCCURS 0 WITH HEADER LINE .
97     DATA : wa_zjvc_cc_fcforms_prv TYPE zjvc_cc_fcforms .
98
99     DATA:  g_tcode     LIKE sy-tcode,
100           g_title(30) TYPE c.
101
102    DATA : zbasloc(12) TYPE c.
103    DATA : zblkst(20) TYPE c.
104    *---------------------------------------------------------------------*
105    * CONSTANTS
106    *---------------------------------------------------------------------*
107    CONSTANTS: c_i     TYPE c VALUE 'I',
108               c_x     TYPE c VALUE 'X',
109               c_bt(2) TYPE c VALUE 'BT',
110               c_eq(2) TYPE c VALUE 'EQ'.
111
112    CONSTANTS : g_tcode1 LIKE sy-tcode VALUE 'ZJVCCFC1',
113                g_tcode2 LIKE sy-tcode VALUE 'ZJVCCFC2',
114                g_tcode3 LIKE sy-tcode VALUE 'ZJVCCFC3',
115                g_tcode4 LIKE sy-tcode VALUE 'ZJVCCFC4',
116                g_tcode5 LIKE sy-tcode VALUE 'ZJVCCFC5',
117                g_repid  LIKE sy-repid VALUE 'SAPMZPSJVCCFCFORMS'.
118
119
120    CONTROLS ts_110 TYPE TABSTRIP.
121
122    DATA  g_dynnr LIKE sy-dynnr VALUE '0120' .
123    DATA  g_line TYPE c.
124
125    DATA: g_action   VALUE  '2'.
126    DATA: l_action.
127
128    * Gui value
129    TYPES: BEGIN OF guivalues,
130             fcode LIKE rsmpe-func,
131           END OF guivalues.
132
133
134    DATA: gui_val   TYPE STANDARD TABLE OF guivalues WITH
135                   NON-UNIQUE DEFAULT KEY INITIAL SIZE 10,
136          wa_guival TYPE guivalues.
137    **********************************************************************
138    DATA: ist_zjvcccfc TYPE STANDARD TABLE OF zjvc_cc_fcforms." initial size 0.occurs 0 with header line
139
140    DATA : dyfields_1  LIKE dynpread OCCURS 1 WITH HEADER LINE .
141
142    DATA:ist_pidetails LIKE zjvc_cc_fcformsb OCCURS 0 WITH HEADER LINE.
143
144    DATA:ist_pidetails1 LIKE zjvc_cc_fcformsb OCCURS 0 WITH HEADER LINE.
145
146    CONTROLS tc_0130 TYPE TABLEVIEW USING SCREEN 0130.
147
148
149    DATA: cursorfield_0130(50) .
150    DATA: cursorline_0130 TYPE i .
151
152    DEFINE zjvccfc_item .
153
154      DEFINE ZJVCCFC_ITEM .
155        ADD 1 TO &1.
156    END-OF-DEFINITION.
*--- End of SAPMZPSJVCCFCFORMSTOP - 156 lines ---

----------------------------------------------------------------------------------------------------
Include          SAPMZPSJVCCFCFORMSO01                     Level 1    Page 3
Object           SAPMZPSJVCCFCFORMS                        Lines 522
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:21
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&  Include           SAPMZPSJVCCFCFORMSO01
3      *&---------------------------------------------------------------------*
4      *&      Module  STATUS_0100  OUTPUT
5      *&---------------------------------------------------------------------*
6      *       text
7      *----------------------------------------------------------------------*
8      MODULE status_0100 OUTPUT.
9        SET PF-STATUS '0100'.
10       SET TITLEBAR 'T001'.
11
12     ENDMODULE.                 " STATUS_0100  OUTPUT
13     *&---------------------------------------------------------------------*
14     *&      Module  SCREEN_ATTR  OUTPUT
15     *&---------------------------------------------------------------------*
16     *       text
17     *----------------------------------------------------------------------*
18     MODULE screen_attr OUTPUT.
19       IF sy-tcode = g_tcode3 OR g_tcode = 'ZJVCCFC3'.
20         LOOP AT SCREEN.
21           IF screen-group1 = 'DIS'.
22             screen-input = '0'.
23           ENDIF.
24           MODIFY SCREEN.
25         ENDLOOP.
26       ENDIF.
27       IF sy-tcode = g_tcode5 OR g_tcode = 'ZJVCCFC5'.
28         LOOP AT SCREEN.
29           IF screen-group1 = 'DIS'.
30             screen-input = '0'.
31           ENDIF.
32           MODIFY SCREEN.
33         ENDLOOP.
34       ENDIF.
35     *Make block Code field in Display mode in CHANGE Mode-Attrb INV in GROUP 2 in screen field ZPS_MWP_BLOCK-BLKCD
36     *    IF SY-TCODE = G_TCODE2 OR G_TCODE = 'ZJVCCFC2'.
37     *    LOOP AT SCREEN.
38     *      IF SCREEN-GROUP2 = 'INV'.
39     *        SCREEN-INPUT = '0'.
40     *      ENDIF.
41     *      MODIFY SCREEN.
42     *    ENDLOOP.
43     *  ENDIF.
44
45     ENDMODULE.                 " SCREEN_ATTR  OUTPUT
46     *&---------------------------------------------------------------------*
47     *&      Module  SCR_ATTR  OUTPUT
48     *&---------------------------------------------------------------------*
49     *       text
50     *----------------------------------------------------------------------*
51     MODULE scr_attr OUTPUT.
52     * Set screen attributes
53     *Disable all Fields in Display Mode For OVL Cash Call FC Form B
54       IF sy-tcode = g_tcode3 OR g_tcode = 'ZJVCCFC3'.
55         LOOP AT SCREEN.
56           IF screen-group1 = 'DIS'.
57             screen-input = '0'.
58           ENDIF.
59           MODIFY SCREEN.
60         ENDLOOP.
61       ENDIF.
62
63       " add by rohit yadav 01-10-2025
64       LOOP AT SCREEN.
65         IF screen-name = 'ZJVC_CC_FCFORMS-CURR_KEY'.
66           screen-input = '0'.  " Disable input (read-only)
67           MODIFY SCREEN.
68         ENDIF.
69       ENDLOOP.
70
71     *Disable all Fields in Approve Mode For OVL Cash Call FC Form B
72       IF sy-tcode = g_tcode3 OR g_tcode = 'ZJVCCFC5'.
73         LOOP AT SCREEN.
74           IF screen-group1 = 'DIS'.
75             screen-input = '0'.
76           ENDIF.
77           MODIFY SCREEN.
78         ENDLOOP.
79       ENDIF.
80
81     *Disable all Fields in Delete Mode For OVL Cash Call FC Form B
82       IF ( g_tcode = 'ZJVCCFC4' OR g_tcode = 'ZJVCCFC4' OR g_tcode = 'ZJVCCFC4' ) .
83     *       AND SY-DYNNR = '0110' .
84
85         LOOP AT SCREEN .
86           IF screen-group1 = 'DIS'.
87             screen-input = '0'.
88             MODIFY SCREEN.
89           ENDIF.
90         ENDLOOP.
91       ENDIF.
92
93     *Disable Radio Buttons for First entry in the screen and all Fields for cash Call No, JV and Subsidiary in CHANGE Mode.
94       IF ( sy-tcode = g_tcode2 OR g_tcode = 'ZJVCCFC2' ) .
95         LOOP AT SCREEN.
96           IF screen-group2 = 'CLS'.
97             screen-input = '0'.
98           ENDIF.
99           IF screen-group2 = 'CCC'.
100            screen-input = '0'.
101          ENDIF.
102          IF screen-group2 = 'JVC'.
103            screen-input = '0'.
104          ENDIF.
105          IF screen-group2 = 'SBS'.
106            screen-input = '0'.
107          ENDIF.
108          IF screen-group2 = 'FND'.
109            screen-input = '0'.
110          ENDIF.
111          MODIFY SCREEN.
112        ENDLOOP.
113
114      ENDIF.
115
116    *Make Fields Contact Person and Net Worth in INR Required in CREATE Mode.
117      IF ( sy-tcode = g_tcode2 OR g_tcode = 'ZJVCCFC1' ) .
118        IF zjvc_cc_fcforms-vname NE ' ' OR zjvc_cc_fcforms-ccreqno NE ' ' OR zjvc_cc_fcforms-subdry_rcomp NE ' ' .
119          LOOP AT SCREEN.
120            IF screen-group2 = 'REQ'.
121              screen-required = '1'.
122            ENDIF.
123            IF screen-group2 = 'REQ'.
124              screen-required = '1'.
125            ENDIF.
126            MODIFY SCREEN.
127          ENDLOOP.
128        ENDIF ."   IF ZJVC_CC_FCFORMS-JVPRNTREQ = ' ' AND ZJVC_CC_FCFORMS-CCPRNTREQ = ' ' AND ZJVC_CC_FCFORMS-SUBSDRYREQ = ' ' .
129      ENDIF."  IF ( SY-TCODE = G_TCODE2 OR G_TCODE = 'ZJVCCFC1' ) .
130
131    *First Disable all Fields for Cash Call No, JV.and Subsidiary
132      IF  sy-tcode = g_tcode1 OR g_tcode = 'ZJVCCFC1'  .
133        LOOP AT SCREEN.
134          IF screen-group2 = 'CCC'.
135            screen-input = '0'.
136          ENDIF.
137          IF screen-group2 = 'JVC'.
138            screen-input = '0'.
139    *           CLEAR: ZJVC_CC_FCFORMS-CCREQNO .
140          ENDIF.
141          IF screen-group2 = 'SBS'.
142            screen-input = '0'.
143    *           CLEAR: ZJVC_CC_FCFORMS-CCREQNO .
144          ENDIF.
145    ***********************************************************************************
146    *Begin ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
147    *To Disable Fin Doc Entry Field
148          IF screen-group2 = 'FND'.
149            screen-input = '0'.
150    *           CLEAR: ZJVC_CC_FCFORMS-CCREQNO .
151          ENDIF.
152    *End ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
153    ***********************************************************************************
154          MODIFY SCREEN.
155        ENDLOOP.
156
157      ENDIF.
158    *break sap_abap .
159    *Disable JV Fields as per Radio Button Selection to maintain data and generate FC Forms for a Cashcall (OVL non-operator)
160      IF sy-tcode = g_tcode1 OR g_tcode = 'ZJVCCFC1'.
161        IF zjvc_cc_fcforms-ccprntreq = 'X' .
162          LOOP AT SCREEN.
163            IF screen-group2 = 'CCC'.
164              screen-input = '1'.
165    *           SCREEN-REQUIRED = '1'.
166              CLEAR: zjvc_cc_fcforms-subdry_rcomp.
167              CLEAR: zjvc_cc_fcforms-subdry_rcompname.
168            ENDIF.
169            IF screen-group2 = 'JVC'.
170    *           SCREEN-INPUT = '0'.
171    *Open JV field also to fill JV NAME to cater to Venturewise Search Help for CC records.
172              screen-input = '1'.
173    *           SCREEN-REQUIRED = '1'.
174            ENDIF.
175            IF screen-group2 = 'SBS'.
176              screen-input = '0'.
177            ENDIF.
178            MODIFY SCREEN.
179          ENDLOOP.
180        ENDIF.
181      ENDIF.
182
183    *Disable CC No Field as per Radio Button Selection to maintain data and generate FC Forms for a Cashcall for JV (OVL Operator)
184      IF sy-tcode = g_tcode1 OR g_tcode = 'ZJVCCFC1'.
185        IF zjvc_cc_fcforms-jvprntreq = 'X' .
186          LOOP AT SCREEN.
187            IF screen-group2 = 'JVC'.
188              screen-input = '1'.
189    *           SCREEN-REQUIRED = '1'.
190              CLEAR: zjvc_cc_fcforms-ccreqno .
191              CLEAR: zjvc_cc_fcforms-subdry_rcomp.
192              CLEAR: zjvc_cc_fcforms-subdry_rcompname.
193            ENDIF.
194            IF screen-group2 = 'CCC'.
195              screen-input = '0'.
196            ENDIF.
197            IF screen-group2 = 'SBS'.
198              screen-input = '0'.
199            ENDIF.
200    ***********************************************************************************
201    *Begin ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
202    *To Enable Fin Doc Entry Field when JV ODI Form is generated
203            IF screen-group2   = 'FND'.
204              screen-input    = '1'.
205              screen-required = '1'.
206            ENDIF.
207    *Begin ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
208    ***********************************************************************************
209            MODIFY SCREEN.
210          ENDLOOP.
211        ENDIF.
212      ENDIF.
213    *Disable CC No Field as per Radio Button Selection to maintain data and generate FC Forms for a Cashcall for JV (OVL Operator)
214      IF sy-tcode = g_tcode1 OR g_tcode = 'ZJVCCFC1'.
215        IF zjvc_cc_fcforms-subsdryreq = 'X' .
216          LOOP AT SCREEN.
217            IF screen-group2 = 'SBS'.
218              CLEAR: zjvc_cc_fcforms-ccreqno .
219              CLEAR: zjvc_cc_fcforms-vname .
220              screen-input = '1'.
221    *           SCREEN-REQUIRED = '1'.
222            ENDIF.
223    *      LOOP AT SCREEN.
224            IF screen-group2 = 'JVC'.
225              screen-input = '0'.
226            ENDIF.
227            IF screen-group2 = 'CCC'.
228              screen-input = '0'.
229            ENDIF.
230    ***********************************************************************************
231    *Begin ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
232    *To Enable Fin Doc Entry Field when Subsidiary ODI Form is generated
233            IF screen-group2   = 'FND'.
234              screen-input    = '1'.
235              screen-required = '1'.
236            ENDIF.
237    *End ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
238    ***********************************************************************************
239            MODIFY SCREEN.
240          ENDLOOP.
241        ENDIF.
242      ENDIF.
243    ***********************************************
244    *Make Fields required depending FC/ODI forms required based on Radion Button choice
245      IF sy-tcode = g_tcode1 OR g_tcode = 'ZJVCCFC1'.
246    *In case of JV Document, Make JV entry Mandatory and Disable Mandatory of Subsidiary, clear it's entry and make Field in display, if any data was there
247        IF zjvc_cc_fcforms-jvprntreq = 'X' .
248          LOOP AT SCREEN.
249            IF screen-group2 = 'JVC'.
250              screen-required = '1'.
251            ENDIF.
252            IF screen-group2 = 'SBS'.
253              screen-required = '0'.
254              screen-input = '0'.
255            ENDIF.
256            MODIFY SCREEN.
257          ENDLOOP.
258        ENDIF."IF ZJVC_CC_FCFORMS-JVPRNTREQ = 'X' .
259    *In case of CC Document, Make JV & CC Req entry Mandatory and Disable Mandatory of Subsidiary & Fin Doc and clear it's entry and make Field in display, if any data was there
260        IF zjvc_cc_fcforms-ccprntreq = 'X' .
261          LOOP AT SCREEN.
262            IF screen-group2 = 'JVC'.
263              screen-required = '1'.
264            ENDIF.
265            IF screen-group2 = 'CCC'.
266              screen-required = '1'.
267            ENDIF.
268    ***********************************************************************************
269    *Begin ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
270            IF screen-group2 = 'FND'.
271              screen-required = '0'.
272              screen-input = '0'.
273              CLEAR: zjvc_cc_fcforms-belnr .
274            ENDIF.
275    *End ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
276    ***********************************************************************************
277            MODIFY SCREEN.
278          ENDLOOP.
279        ENDIF."IF ZJVC_CC_FCFORMS-CCPRNTREQ = 'X' .
280    *In case of Sub Document, Make Sub. entry Mandatory and Disable Mandatory of JV/CC, clear it's entry and make Field in display, if any data was there
281        IF zjvc_cc_fcforms-subsdryreq = 'X' .
282          LOOP AT SCREEN.
283            IF screen-group2 = 'SBS'.
284              screen-required = '1'.
285            ENDIF.
286            IF screen-group2 = 'JVC'.
287              screen-required = '0'.
288              screen-input = '0'.
289            ENDIF.
290            IF screen-group2 = 'CCC'.
291              screen-required = '0'.
292              screen-input = '0'.
293            ENDIF.
294            MODIFY SCREEN.
295          ENDLOOP.
296        ENDIF."IF ZJVC_CC_FCFORMS-SUBSDRYREQ = 'X' .
297      ENDIF."IF SY-TCODE = G_TCODE1 OR G_TCODE = 'ZJVCCFC1'.
298    **********************************************
299      PERFORM get_totals_fcformb.""""""""""""""""""""""""""""""""""""""""""""""""""comment by rohit
300      PERFORM get_totals_fcformb_new.""""""""""""""""""""""""""""""""""""""""""""""""""add  by rohit
301
302    *To Fetch Subsidiary Name from table T800.
303      IF g_tcode = 'ZJVCCFC1' AND zjvc_cc_fcforms-subsdryreq = 'X' .
304        IF NOT zjvc_cc_fcforms-subdry_rcomp IS INITIAL .
305          PERFORM  get_subsidiaryname .
306        ENDIF.
307      ENDIF .
308    ***********************************************
309
310    *To fetch previous CC Data for this Venture. Only in Create Mode and When Option Doc Creation option is X and Venture Name and CC Req are not INITIAL
311    *  IF ( SY-TCODE = G_TCODE1 OR G_TCODE = 'ZJVCCFC1' ) .
312    *    IF ZJVC_CC_FCFORMS-CCPRNTREQ = 'X'.
313    *      IF ZJVC_CC_FCFORMS-VNAME NE ' ' AND ZJVC_CC_FCFORMS-CCREQNO NE ' ' .
314    **ZJVC_CC_FCFORMS-CCPRNTREQ, ZJVC_CC_FCFORMS-VNAME, ZJVC_CC_FCFORMS-CCREQNO
315    **        PERFORM get_prev_cccdata .
316    **      perform get_prvs_ccprnt_data .
317    *      ENDIF."IF ZJVC_CC_FCFORMS-VNAME NE ' ' AND ZJVC_CC_FCFORMS-CCREQNO NE ' ' .
318    *    ENDIF." IF ZJVC_CC_FCFORMS-CCPRNTREQ = 'X' .
319    *  ENDIF. "G_TCODE = 'ZJVCCFC1'
320
321    *To fetch Cash Call Details from ZPS_CASH_CALL table only in Create Mode .
322      IF ( sy-tcode = g_tcode1 OR g_tcode = 'ZJVCCFC1' ) .
323
324    *********************************************************************************
325    *Get UIN No immediately from master Table ZJVC_CC_ASTBLK
326        DATA: wa_finduin TYPE zjvc_cc_astblk .
327
328        IF zjvc_cc_fcforms-subdry_rcomp IS INITIAL AND NOT zjvc_cc_fcforms-vname IS INITIAL .
329          SELECT * FROM ZJVC_CC_ASTBLK INTO WA_FINDUIN UP TO 1 ROWS WHERE VNAME = ZJVC_CC_FCFORMS-VNAME
330     ORDER BY PRIMARY KEY .
331     ENDSELECT. " OR SUBDRY_RCOMP = ZJVC_CC_FCFORMS-SUBDRY_RCOMP .
332          IF sy-subrc = 0 .
333            zjvc_cc_fcforms-ei_forgnenty_uin = wa_finduin-unq_id .
334          ENDIF.
335        ELSEIF zjvc_cc_fcforms-vname IS INITIAL AND NOT zjvc_cc_fcforms-subdry_rcomp IS INITIAL ..
336          SELECT * FROM ZJVC_CC_ASTBLK INTO WA_FINDUIN UP TO 1 ROWS WHERE SUBDRY_RCOMP = ZJVC_CC_FCFORMS-SUBDRY_RCOMP
337     ORDER BY PRIMARY KEY .
338     ENDSELECT. " OR SUBDRY_RCOMP = ZJVC_CC_FCFORMS-SUBDRY_RCOMP .
339          IF sy-subrc = 0 .
340            zjvc_cc_fcforms-ei_forgnenty_uin = wa_finduin-unq_id .
341          ENDIF.
342
343          CLEAR : wa_finduin .
344        ENDIF."IF ( SY-TCODE = G_TCODE1 OR G_TCODE = 'ZJVCCFC1' ) .
345    ********************************************************************************
346        PERFORM get_ccdetails .
347
348      ENDIF.
349    ********************************************************************************
350      IF zjvc_cc_fcforms-jvprntreq = ' ' AND zjvc_cc_fcforms-ccprntreq = ' ' AND zjvc_cc_fcforms-subsdryreq = ' ' .
351    *   do nothing
352      ELSE .
353    *    PERFORM get_totals . " comment by rohit """""""""""""""""
354      ENDIF.
355    ********************************************************************************
356    *To fetch Cash Call Details from ZPS_CASH_CALL table only in Create Mode .
357      IF ( sy-tcode = g_tcode1 OR g_tcode = 'ZJVCCFC1' ) .
358    *        PERFORM GET_PRVS_PIDATA .
359      ENDIF ."IF ( SY-TCODE = G_TCODE1 OR G_TCODE = 'ZJVCCFC1' ) .
360    ********************************************************************************
361    *To Hide Total Fields in CREATE & CHANGE MODE
362    *  IF SY-TCODE = 'ZJVCCFC2' OR SY-TCODE = 'ZJVCCFC1' OR G_TCODE = 'ZJVCCFC2' OR G_TCODE = 'ZJVCCFC1' AND SY-DYNNR = '0130'.
363    *    LOOP AT SCREEN .
364    *      IF SCREEN-GROUP1 = 'INV'.
365    *        SCREEN-INVISIBLE = '1' .
366    *        SCREEN-INPUT = '0'.
367    *        MODIFY SCREEN.
368    *      endif.
369    *    ENDLOOP .
370    *  ENDIF ."  IF SY-TCODE = 'ZJVCCFC2' OR SY-TCODE = 'ZJVCCFC1' OR G_TCODE = 'ZJVCCFC2' OR G_TCODE = 'ZJVCCFC1'
371    ********************************************************************************
372    *Write Approved Text in case of Approved Document if IF g_tcode  EQ 'ZJVCCFC5'
373      IF sy-tcode = 'ZJVCCFC5' OR g_tcode = g_tcode5 OR g_tcode = g_tcode3 OR sy-tcode = 'ZJVCCFC3' .
374        IF zjvc_cc_fcforms-doc_app = 'X' .
375          g_doc_app_text = 'THIS IS AN APPROVED DOCUMENT' .
376        ELSE.
377          CLEAR : g_doc_app_text .
378        ENDIF .
379      ENDIF.
380
381    ENDMODULE.                 " SCR_ATTR  OUTPUT
382    *&---------------------------------------------------------------------*
383    *&      Module  STATUS_0110  OUTPUT
384    *&---------------------------------------------------------------------*
385    *       text
386    *----------------------------------------------------------------------*
387    MODULE status_0110 OUTPUT.
388    *  SET PF-STATUS 'xxxxxxxx'.
389    *  SET TITLEBAR 'xxx'.
390      DATA : z0        TYPE c VALUE '0',
391             g_doc(10) TYPE n.
392
393    *In display mode excluding save button from screen
394      IF g_tcode  EQ 'ZJVCCFC1' OR
395         g_tcode  EQ 'ZJVCCFC2' OR
396         g_tcode  EQ 'ZJVCCFC3' OR
397         g_tcode  EQ 'ZJVCCFC5' .
398
399        CLEAR:gui_val.REFRESH gui_val.
400
401        IF g_tcode  EQ 'ZJVCCFC3'.
402          MOVE 'SAVE' TO wa_guival.
403          APPEND wa_guival TO gui_val.
404        ENDIF.
405
406        IF g_tcode  EQ 'ZJVCCFC5'.
407          IF zjvc_cc_fcforms-doc_app = 'X' .
408            MOVE 'SAVE' TO wa_guival.
409            APPEND wa_guival TO gui_val.
410          ENDIF .
411        ENDIF.
412
413    *    MOVE 'SAVE' TO wa_guival.
414    *    APPEND wa_guival TO gui_val.
415        MOVE 'DELE' TO wa_guival.
416        APPEND wa_guival TO gui_val.
417      ENDIF.
418      IF g_tcode EQ 'ZJVCCFC4'.
419        CLEAR:gui_val.REFRESH gui_val.
420        MOVE 'SAVE' TO wa_guival.
421        APPEND wa_guival TO gui_val.
422      ENDIF.
423      IF g_tcode = 'ZJVCCFC2' OR
424         g_tcode = 'ZJVCCFC3' .
425        MOVE 'DELE' TO wa_guival.
426        APPEND wa_guival TO gui_val.
427      ENDIF.
428      SET PF-STATUS '0110' EXCLUDING gui_val.
429    **************************************************
430      IF g_tcode = 'ZJVCCFC1' AND save_ok NE 'CPDC'.
431        g_title = text-012.
432      ELSEIF g_tcode  = 'ZJVCCFC2'.
433        g_title = text-013.
434      ELSEIF g_tcode  = 'ZJVCCFC3'.
435        g_title = text-014.
436      ELSEIF g_tcode  = 'ZJVCCFC4'.
437        g_title = text-015.
438      ELSEIF save_ok = 'CPDC' AND g_tcode = 'ZJVCCFC1'.
439        g_title = text-016.
440      ENDIF.
441
442      SET TITLEBAR '0110' WITH g_title zjvc_cc_fcforms-doc_no.
443
444    ENDMODULE.                 " STATUS_0110  OUTPUT
445    *&---------------------------------------------------------------------*
446    *&      Module  STATUS_0105  OUTPUT
447    *&---------------------------------------------------------------------*
448    *       text
449    *----------------------------------------------------------------------*
450    MODULE status_0105 OUTPUT.
451    *In display mode excluding save button from screen
452      IF sy-tcode EQ 'ZJVCCFC3' OR g_tcode = 'ZJVCCFC3'.
453        CLEAR:gui_val.REFRESH gui_val.
454        MOVE 'SAVE' TO wa_guival.
455        APPEND wa_guival TO gui_val.
456      ENDIF.
457      IF g_tcode = 'ZJVCCFC2' OR
458         g_tcode = 'ZJVCCFC3' OR
459         g_tcode = 'ZJVCCFC4' OR
460         g_tcode = 'ZJVCCFC5'.
461        MOVE 'DELE' TO wa_guival.
462        APPEND wa_guival TO gui_val.
463      ENDIF.
464      SET PF-STATUS '0105' EXCLUDING gui_val.
465
466    * Title
467      IF g_tcode = 'ZJVCCFC1'.
468        g_title = text-012.
469      ELSEIF g_tcode  = 'ZJVCCFC2'.
470        g_title = text-013.
471      ELSEIF g_tcode  = 'ZJVCCFC3'.
472        g_title = text-014.
473      ELSEIF g_tcode  = 'ZJVCCFC4'.
474        g_title = text-015.
475      ELSEIF g_tcode = 'ZJVCCFC5'.
476        g_title = text-025.
477      ENDIF.
478
479      SET TITLEBAR '0105' WITH g_title zjvc_cc_fcforms-doc_no.
480
481    ENDMODULE.                 " STATUS_0105  OUTPUT
482    *&---------------------------------------------------------------------*
483    *&      Module  FILL_TC_0130  OUTPUT
484    *&---------------------------------------------------------------------*
485    *       text
486    *----------------------------------------------------------------------*
487    MODULE fill_tc_0130 OUTPUT.
488      CLEAR : zjvc_cc_fcformsb .
489      READ TABLE ist_pidetails INTO zjvc_cc_fcformsb INDEX
490                             tc_0130-current_line.
491
492    ENDMODULE.
493    *&---------------------------------------------------------------------*
494    *&      Module  INCREMENT_TC_LINES_0130  OUTPUT
495    *&---------------------------------------------------------------------*
496    *       text
497    *----------------------------------------------------------------------*
498    MODULE increment_tc_lines_0130 OUTPUT.
499      DATA: tc_lin0130 TYPE i.
500      CLEAR tc_lin0130.
501      DESCRIBE TABLE ist_pidetails LINES tc_lin0130.
502      IF tc_lin0130 GT 0.
503        tc_0130-lines = tc_lin0130.
504      ENDIF.
505    ENDMODULE.
506    *&---------------------------------------------------------------------*
507    *&      Module  SET_CURSOR_FIELD_0130  OUTPUT
508    *&---------------------------------------------------------------------*
509    *       text
510    *----------------------------------------------------------------------*
511    MODULE set_cursor_field_0130 OUTPUT.
512      SET CURSOR  FIELD cursorfield_0130 LINE  cursorline_0130 . "tc_130-current_line.
513    ENDMODULE.
514    *&---------------------------------------------------------------------*
515    *&      Module  GET_CURSOR_FIELD_0130  INPUT
516    *&---------------------------------------------------------------------*
517    *       text
518    *----------------------------------------------------------------------*
519    MODULE get_cursor_field_0130 INPUT.
520      GET CURSOR  FIELD cursorfield_0130 LINE  tc_0130-current_line.
521      cursorline_0130 = tc_0130-current_line .
522    ENDMODULE.
*--- End of SAPMZPSJVCCFCFORMSO01 - 522 lines ---

----------------------------------------------------------------------------------------------------
Include          SAPMZPSJVCCFCFORMSI01                     Level 1    Page 4
Object           SAPMZPSJVCCFCFORMS                        Lines 732
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:21
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&  Include           SAPMZPSJVCCFCFORMSI01
3      *&---------------------------------------------------------------------*
4      *&      Module  USER_COMMAND_0100  INPUT
5      *&---------------------------------------------------------------------*
6      *       text
7      *----------------------------------------------------------------------*
8      MODULE user_command_0100 INPUT.
9
10       save_ok = g_ok_100.
11       CLEAR g_ok_100.
12       CLEAR g_ok100_cpydoc .
13
14       CASE save_ok.
15
16         WHEN 'ENTE' OR 'CREA'.
17     *      g_tcode = '1' .
18           g_tcode = 'ZJVCCFC1' .
19           PERFORM cleardata.
20           CALL SCREEN '9001'.
21     *      CALL SCREEN '0110'.
22     *      perform get_prvs_ccprnt_data .
23         WHEN 'CHNG' .
24           g_tcode = 'ZJVCCFC2' .
25           CALL SCREEN '0105' .
26           PERFORM get_data .
27         WHEN 'DISP'.
28           g_tcode = 'ZJVCCFC3' .
29           CALL SCREEN '0105' .
30           PERFORM get_data .
31           CALL SCREEN '0110'.
32         WHEN 'DELE'.
33           g_tcode = 'ZJVCCFC4' .
34           CALL SCREEN '0105' .
35           PERFORM get_data .
36           CALL SCREEN '0110'.
37         WHEN 'APPR'.
38           g_tcode = 'ZJVCCFC5' .
39           CALL SCREEN '0105' .
40           PERFORM get_data .
41           CALL SCREEN '0110'.
42         WHEN 'PRINT'.
43           CALL TRANSACTION 'ZJVCCFCPR' .
44         WHEN 'EXIT' OR 'BACK' OR 'CANC'.
45     *      perform cleardata.
46           LEAVE PROGRAM.
47
48
49         WHEN 'EFG'.
50           CALL TRANSACTION 'ZJVCCFC_EFG' .
51
52         WHEN 'MASTER'.
53           CALL TRANSACTION 'ZJVCCFCMASTER' .
54
55         WHEN 'UIN_REP'.
56
57           CALL TRANSACTION 'ZJVCCFC_UIN_REP' .
58
59         WHEN 'OVL_REP'.
60           CALL TRANSACTION 'ZJVCCFC_OVL_REP' .
61
62         WHEN 'LOG_REP'.
63           CALL TRANSACTION 'ZJV_LOG_REPORT' .
64
65         WHEN 'PARTNER'.
66           CALL TRANSACTION 'ZJV_PARTNER'.
67
68         WHEN 'OVL_OB'.
69           CALL TRANSACTION 'ZJV_OVL_OB'.
70
71       ENDCASE.
72     ENDMODULE.                 " USER_COMMAND_0100  INPUT
73     *&---------------------------------------------------------------------*
74     *&      Module  EXIT_TRANSACTION_100  INPUT
75     *&---------------------------------------------------------------------*
76     *       text
77     *----------------------------------------------------------------------*
78     MODULE exit_transaction_100 INPUT.
79       CLEAR:g_ok_100.
80       PERFORM exit_confirmation.
81
82     ENDMODULE.                 " EXIT_TRANSACTION_100  INPUT
83     *&---------------------------------------------------------------------*
84     *&      Module  USER_COMMAND_0110  INPUT
85     *&---------------------------------------------------------------------*
86     *       text
87     *----------------------------------------------------------------------*
88     MODULE user_command_0110 INPUT.
89       save_ok = g_ok_110.
90       CLEAR g_ok_110.
91       CASE save_ok.
92     *******************************************
93         WHEN 'PUSH1'.
94           g_dynnr = '0120'.
95           ts_110-activetab = 'PUSH1'.
96     *******************************************
97         WHEN 'PUSH2'.
98           g_dynnr = '0130'.
99           ts_110-activetab = 'PUSH2'.
100    *******************************************
101        WHEN 'PUSH3'.
102          g_dynnr = '0140'.
103          ts_110-activetab = 'PUSH3'.
104    *******************************************
105        WHEN 'PUSH4'.
106          g_dynnr = '0190'.
107          ts_110-activetab = 'PUSH4'.
108    *******************************************
109        WHEN 'BACK' OR 'EXIT' OR 'CANC'.
110          PERFORM unlock_header.
111          PERFORM cleardata.
112          g_dynnr = '0120'.
113          ts_110-activetab = 'PUSH1'.
114
115          IF sy-tcode = g_tcode1 OR g_tcode = g_tcode1.
116            LEAVE TO SCREEN '0100'.
117
118          ELSE.
119    *        leave to screen 100.
120          ENDIF .
121    **************************************************
122        WHEN 'SAVE'.
123          PERFORM save_110_data .
124          PERFORM cleardata.
125          PERFORM unlock_header.
126
127        WHEN 'DPRIR'.
128          PERFORM insert_dpr_row.
129        WHEN 'DPRDR'.
130          PERFORM delete_dpr_row.
131
132        WHEN 'DELE'.
133          PERFORM delete.
134        WHEN 'APPR'.
135    *       perform approve.
136
137    *Begin ARV 29-02-106 CR30014010 RD1K9A0046*************
138        WHEN 'ATTACHDOCS' .
139    *     perform attach_docs.
140
141        WHEN 'LIST'.
142    *     perform list_docs .
143    *End ARV 29-02-106 CR30014010 RD1K9A0046*************
144
145    *Fetch Totals UIN wise and OVL wise from Totals table ZJVCCFC_TOT
146    *WHEN 'GENTOT'.
147    *      perform uintots .
148
149
150
151      ENDCASE.
152    ENDMODULE.                 " USER_COMMAND_0110  INPUT
153    *&---------------------------------------------------------------------*
154    *&      Module  EXIT_TRANSACTION  INPUT
155    *&---------------------------------------------------------------------*
156    *       text
157    *----------------------------------------------------------------------*
158    MODULE exit_transaction INPUT.
159
160      ts_110  = 'PUSH1'.
161      g_dynnr = '0120'.
162      ts_110-activetab = 'PUSH1'.
163
164      IF sy-tcode NE g_tcode3 OR g_tcode NE g_tcode3.
165        CLEAR:g_ok_105.
166        CLEAR: ist_pidetails .
167        REFRESH: ist_pidetails .
168        PERFORM confirm_action USING text-001 text-002 g_action.
169        IF g_action EQ '1'.
170          PERFORM unlock_header.
171          IF sy-tcode = g_tcode1 OR g_tcode = g_tcode1.
172            g_flag = 'Y'.
173            CLEAR: ist_pidetails .
174            REFRESH: ist_pidetails .
175             LEAVE TO SCREEN '9001'.
176    *        LEAVE TO SCREEN '0100'.
177          ELSE.
178            CLEAR: ist_pidetails .
179            REFRESH: ist_pidetails .
180            LEAVE TO SCREEN '0100' .
181    *        leave program .
182          ENDIF.
183        ELSE.
184          LEAVE TO SCREEN '0110' .
185    *      do nothing .
186        ENDIF.
187      ELSE.
188        PERFORM unlock_header.
189      ENDIF.
190
191      CLEAR: ist_pidetails .
192      REFRESH: ist_pidetails .
193    ENDMODULE.                 " EXIT_TRANSACTION  INPUT
194    *&---------------------------------------------------------------------*
195    *&      Module  CHECK_DGRNR  INPUT
196    *&---------------------------------------------------------------------*
197    *       text
198    *----------------------------------------------------------------------*
199    MODULE check_dgrnr INPUT.
200      SELECT SINGLE * FROM zjvc_cc_fcforms
201                    WHERE doc_no = zjvc_cc_fcforms-doc_no.
202      IF sy-subrc NE 0.
203        MESSAGE e106(zps) WITH text-022 zjvc_cc_fcforms-doc_no.
204      ENDIF.
205
206      IF zjvc_cc_fcforms-lvorm = 'X'.
207        MESSAGE i613(zps) WITH zjvc_cc_fcforms-doc_no.
208        CLEAR zjvc_cc_fcforms-doc_no.
209        LEAVE TO SCREEN 100 .
210      ENDIF.
211
212      IF  sy-tcode = 'ZJVCCFC2' OR g_tcode = 'ZJVCCFC2' .
213        IF zjvc_cc_fcforms-doc_app = 'X'.
214          MESSAGE i614(zps) WITH zjvc_cc_fcforms-doc_no.
215          CLEAR zjvc_cc_fcforms-doc_no.
216          LEAVE TO SCREEN 100 .
217        ENDIF.
218      ENDIF."IF  sy-tcode = 'ZJVCCFC2' OR g_tcode = 'ZJVCCFC2' .
219
220      IF g_tcode = g_tcode2.
221        PERFORM lock_header.
222      ENDIF.
223    *Move Initial data to a work area to calculate the on-screen differences in Financial values in FORMB TAB
224      MOVE zjvc_cc_fcforms TO wa_zjvc_cc_fcforms_prv .
225
226    ENDMODULE.                 " CHECK_DGRNR  INPUT
227    *&---------------------------------------------------------------------*
228    *&      Module  USER_COMMAND_0105  INPUT
229    *&---------------------------------------------------------------------*
230    *       text
231    *----------------------------------------------------------------------*
232    MODULE user_command_0105 INPUT.
233      CASE g_ok_105.
234        WHEN 'ENTE'.
235          IF save_ok = 'CHNG'.
236            g_tcode = 'ZJVCCFC2'.
237          ELSEIF save_ok = 'DISP'.
238            g_tcode = 'ZJVCCFC3'.
239          ELSEIF save_ok = 'CREAT'.
240            g_tcode = 'ZJVCCFC1'.
241    *************************************
242    *      ELSEIF save_ok = 'DELE'.
243    *        g_tcode = 'ZPSDGR4'.
244    *      ELSEIF save_ok = 'APPROVE'.
245    *        g_tcode = 'ZPSDGR5'.
246          ENDIF.
247
248          IF save_ok = 'CHNG'.
249            PERFORM lock_header .
250          ENDIF.
251          PERFORM get_data .
252    *      IF save_ok = 'APPROVE'.
253    *        PERFORM lock_header .
254    *      PERFORM get_data .
255    *      ENDIF.
256    *************************************
257          CALL SCREEN '0110'.
258    *************************************
259    *Delete
260          IF g_tcode = 'ZJVCCFC4'.
261            SELECT SINGLE * FROM zjvc_cc_fcforms
262            WHERE lvorm = 'X'
263            AND doc_no = zjvc_cc_fcforms-doc_no.
264            IF sy-subrc EQ 0.
265              MESSAGE i000(zps) WITH text-003 zjvc_cc_fcforms-doc_no text-022.
266              PERFORM cleardata.
267              LEAVE TO SCREEN '0100'.
268            ENDIF.
269          ENDIF.
270          PERFORM get_data .
271          CALL SCREEN '0110'.
272    *************************************
273
274        WHEN 'BACK' OR 'EXIT' OR 'CANC'.
275          PERFORM exit_confirmation.
276      ENDCASE.
277    ENDMODULE.                 " USER_COMMAND_0105  INPUT
278    *&---------------------------------------------------------------------*
279    *&      Module  GET_CURSOR_FIELD  INPUT
280    *&---------------------------------------------------------------------*
281    *       text
282    *----------------------------------------------------------------------*
283    MODULE get_cursor_field INPUT.
284    *GET CURSOR  FIELD cursorfield_130 LINE  tc_130-current_line.
285    *  CURSORLINE_130 = tc_130-current_line .
286    ENDMODULE.                 " GET_CURSOR_FIELD  INPUT
287    *&---------------------------------------------------------------------*
288    *&      Form  SAVE_110_DATA
289    *&---------------------------------------------------------------------*
290    *       text
291    *----------------------------------------------------------------------*
292    *  -->  p1        text
293    *  <--  p2        text
294    *----------------------------------------------------------------------*
295    FORM save_110_data .
296
297    *Check if CPF, Mob No, Email ID is not blank
298      PERFORM check_perdetails .
299      IF g_tcode <> g_tcode2.
300        SELECT SINGLE * FROM  zjvc_cc_fcforms
301                        WHERE doc_no  = zjvc_cc_fcforms-doc_no.
302
303
304        IF sy-subrc NE 0 AND g_tcode EQ g_tcode1.
305          PERFORM insert ON COMMIT.
306        ELSEIF sy-subrc EQ 0 AND g_tcode EQ g_tcode1 AND g_ok100_cpydoc EQ 'CPDC'.
307          PERFORM insert ON COMMIT.
308        ELSEIF sy-subrc EQ 0 AND g_tcode EQ g_tcode1 . "'ZPSMWPJV1'.
309          MESSAGE e101(zps) WITH zjvc_cc_fcforms-doc_no.
310        ENDIF.
311      ENDIF.
312      IF sy-subrc EQ 0 AND ( g_tcode EQ g_tcode2 OR sy-tcode EQ g_tcode5 OR g_tcode EQ 'ZJVCCFC5' ) .
313        PERFORM update ON COMMIT.
314
315    *    IF SY-TCODE = G_TCODE2 OR G_TCODE = 'ZJVCCFC2'.
316    *      MESSAGE s205(zps) WITH TEXT-434 ZJVC_CC_FCFORMS-DOC_NO .
317    *    ELSE .
318    *      MESSAGE s275(zps) WITH TEXT-434 ZJVC_CC_FCFORMS-DOC_NO .
319    *    ENDIF .
320
321      ENDIF.
322      COMMIT WORK .
323      IF sy-subrc NE 0.
324        ROLLBACK WORK.
325        MESSAGE e210(zps) WITH 'ZJVC_CC_FCFORMS' space.
326      ENDIF.
327
328      CLEAR:sy-subrc.
329
330      CLEAR:sy-subrc.
331      CLEAR: zjvc_cc_fcforms, zjvc_cc_fcformsb, ist_pidetails .
332      REFRESH: ist_pidetails .
333
334      LEAVE TO SCREEN '0100'.
335
336    ENDFORM.                    " SAVE_110_DATA
337    FORM delete .
338
339      PERFORM confirm_action USING text-018 text-019 l_action.
340
341      IF l_action EQ '1'.
342        PERFORM lock_header.
343
344    *Let us Mark the status of deleted Document
345
346        UPDATE zjvc_cc_fcforms SET lvorm = 'X'
347               WHERE doc_no = zjvc_cc_fcforms-doc_no.
348
349    ******************************************
350        UPDATE  zjvc_cc_fcforms SET aeusn     = sy-uname
351                WHERE doc_no = zjvc_cc_fcforms-doc_no.
352
353        UPDATE  zjvc_cc_fcforms SET aedtm    = sy-datum
354                WHERE doc_no = zjvc_cc_fcforms-doc_no.
355
356        PERFORM timestamp.
357
358        UPDATE  zjvc_cc_fcforms SET timestamp = g_tstamp
359                WHERE doc_no = zjvc_cc_fcforms-doc_no.
360
361    *******************************************
362        MESSAGE e000(zps) WITH 'OVL Cash Call FC Form Document No' zjvc_cc_fcforms-doc_no text-021.
363
364        PERFORM unlock_header .
365      ENDIF.
366
367    ENDFORM.                    " DELETE
368    *&---------------------------------------------------------------------*
369    *&      Module  GET_CPF1_NAME  INPUT
370    *&---------------------------------------------------------------------*
371    *       text
372    *----------------------------------------------------------------------*
373    MODULE get_cpf1_name INPUT.
374
375    ***********************************************************************************
376    *Begin ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
377    * As the Personal details like CPF, Name, Desig, Mobile No, telephone NO & Emaild ID
378    *  is now to be maintained in Master Table hence the following logic is being commented.
379
380      DATA: l_date TYPE datum.
381      DATA: wa_mobileno TYPE adr2 .
382      DATA: wa_emailid TYPE adr6 .
383      DATA: wa_zpa0001 TYPE zpa0001.
384      DATA: wa_zpa9930 TYPE zpa9930.
385      DATA: wa_desig   TYPE zdesignation_rev.
386      DATA: l_persnumber TYPE ad_persnum .
387
388    *Find Employee Name from CPF...Table ZPA001 is maintained and synced with PA0001 of ICE
389    *break sap_abap .
390      IF NOT zjvc_cc_fcforms-contct_per_cpf IS INITIAL.
391        SELECT * FROM ZPA0001 INTO WA_ZPA0001 UP TO 1 ROWS WHERE PERNR = ZJVC_CC_FCFORMS-CONTCT_PER_CPF AND
392     SPRPS = ' ' AND ENDDA GE L_DATE AND SPRPS = ' ' AND ENDDA GE L_DATE
393     ORDER BY PRIMARY KEY .
394     ENDSELECT.
395        IF sy-subrc = 0.
396          zjvc_cc_fcforms-contct_per_name =  wa_zpa0001-ename.
397        ELSE.
398          MESSAGE e485(zps) WITH zjvc_cc_fcforms-contct_per_cpf.
399        ENDIF.
400      ENDIF.
401    *
402    *
403      CLEAR: l_date, wa_zpa0001 .
404    *
405    **Find Employee Designation
406    *
407      SELECT * FROM ZPA9930
408     INTO CORRESPONDING FIELDS OF WA_ZPA9930 UP TO 1 ROWS WHERE PERNR = ZJVC_CC_FCFORMS-CONTCT_PER_CPF AND ENDDA = '99991231'
409     ORDER BY PRIMARY KEY .
410     ENDSELECT.
411      IF sy-subrc = 0.
412        SELECT SINGLE * FROM zdesignation_rev
413        INTO CORRESPONDING FIELDS OF wa_desig
414        WHERE desig_code = wa_zpa9930-designo
415        AND   r_p_cd     = wa_zpa9930-r_p_cd
416        AND   version    = wa_zpa9930-version.
417        IF sy-subrc = 0.
418    *        PERFORM convert_case USING wa_desig-desig_text.
419          zjvc_cc_fcforms-contct_per_desg = wa_desig-desig_text.
420        ENDIF.
421      ENDIF.
422    **break sap_abap .
423    **Find Mobile Name
424
425      IF NOT zjvc_cc_fcforms-contct_per_cpf IS INITIAL.
426    *    DATA: ist_adr2 LIKE ADR2 OCCURS 0 .
427    *    DATA: lv_mbl1 TYPE zhrphone.
428    **************************************************************
429    *    SELECT SINGLE zphone
430    *    FROM zpa9205 INTO lv_mbl1
431    *    WHERE pernr = ZJVC_CC_FCFORMS-CONTCT_PER_CPF.
432    *    IF lv_mbl1 IS INITIAL.
433    *      MESSAGE e000(zmsg) WITH
434    *      'Mobile No. doesnot exists for-Acceptor1'.
435    *    ENDIF.
436
437    ************************************************************
438        l_persnumber = zjvc_cc_fcforms-contct_per_cpf .
439        SHIFT l_persnumber LEFT DELETING LEADING '0' .
440        SELECT SINGLE * FROM usr21 INTO @DATA(st_usr21) WHERE bname = @l_persnumber.
441
442        SELECT * FROM ADR2 INTO WA_MOBILENO UP TO 1 ROWS WHERE PERSNUMBER = ST_USR21-PERSNUMBER
443     ORDER BY PRIMARY KEY .
444     ENDSELECT. "'0000078356' ."ZJVC_CC_FCFORMS-CONTCT_PER_CPF ." AND  "wa_pa0105-pernr
445    *                                                        ADDRNUMBER =
446    *                                                       sprps  = ' '                            AND
447    *                                                      endda  GE l_date                        AND
448    *                                                      sprps  = ' '                            AND
449    *                                                      endda  GE l_date .
450        IF sy-subrc = 0.
451    *      l_mobileno = ADR2-TEL_NUMBER .
452          zjvc_cc_fcforms-contct_per_mobno =  wa_mobileno-tel_number .
453        ELSE.
454    *      message w485(zps) with ZJVC_CC_FCFORMS-CONTCT_PER_CPF.
455        ENDIF.
456      ENDIF.
457
458    *Find Email ID
459
460      IF NOT zjvc_cc_fcforms-contct_per_cpf IS INITIAL.
461        SELECT * FROM ADR6 INTO WA_EMAILID UP TO 1 ROWS WHERE PERSNUMBER = ST_USR21-PERSNUMBER
462     ORDER BY PRIMARY KEY .
463     ENDSELECT. "ZJVC_CC_FCFORMS-CONTCT_PER_CPF ." AND  "wa_pa0105-pernr
464    *                                                      sprps  = ' '                            AND
465    *                                                      endda  GE l_date                        AND
466    *                                                      sprps  = ' '                            AND
467    *                                                      endda  GE l_date .
468        IF sy-subrc = 0.
469          zjvc_cc_fcforms-contct_per_email =  wa_emailid-smtp_addr .
470        ELSE.
471    *      message w485(zps) with ZJVC_CC_FCFORMS-CONTCT_PER_CPF.
472        ENDIF.
473      ENDIF.
474
475
476
477      IF zjvc_cc_fcforms-contct_per_cpf  IS INITIAL.
478        CLEAR : zjvc_cc_fcforms-contct_per_cpf, zjvc_cc_fcforms-contct_per_name, zjvc_cc_fcforms-contct_per_desg, wa_zpa9930,wa_desig, wa_mobileno, wa_emailid, l_persnumber .
479      ENDIF.
480    *break sap_abap .
481    *********************************************************************************
482    *IF ZJVC_CC_FCFORMS-VNAME <> ' ' AND ZJVC_CC_FCFORMS-SUBDRY_RCOMP <> ' ' .
483    **Get UIN No immediately from master Table ZJVC_CC_ASTBLK
484    *  DATA: wa_finduin TYPE ZJVC_CC_ASTBLK .
485    **    SELECT SINGLE * FROM ZJVC_CC_ASTBLK INTO wa_ventrdtls WHERE VNAME = ZJVC_CC_FCFORMS-VNAME .
486    **  IF ZJVC_CC_FCFORMS-CCPRNTREQ = 'X' OR ZJVC_CC_FCFORMS-JVPRNTREQ = 'X' .
487    *  IF ZJVC_CC_FCFORMS-SUBDRY_RCOMP IS INITIAL .
488    *    SELECT SINGLE * FROM ZJVC_CC_ASTBLK INTO wa_finduin WHERE VNAME = ZJVC_CC_FCFORMS-VNAME." OR SUBDRY_RCOMP = ZJVC_CC_FCFORMS-SUBDRY_RCOMP .
489    *    IF sy-subrc = 0 .
490    *      ZJVC_CC_FCFORMS-EI_FORGNENTY_UIN = wa_finduin-UNQ_ID .
491    *    ENDIF.
492    **ELSEIF ZJVC_CC_FCFORMS-SUBSDRYREQ = 'X'.
493    *    ELSE.
494    *    SELECT SINGLE * FROM ZJVC_CC_ASTBLK INTO wa_finduin WHERE SUBDRY_RCOMP = ZJVC_CC_FCFORMS-SUBDRY_RCOMP." OR SUBDRY_RCOMP = ZJVC_CC_FCFORMS-SUBDRY_RCOMP .
495    *    IF sy-subrc = 0 .
496    *      ZJVC_CC_FCFORMS-EI_FORGNENTY_UIN = wa_finduin-UNQ_ID .
497    *    ENDIF.
498    *  ENDIF.
499    *
500    *    CLEAR : wa_finduin .
501    *ENDIF.    "IF ZJVC_CC_FCFORMS-VNAME <> ' ' AND ZJVC_CC_FCFORMS-SUBDRY_RCOMP <> ' ' .
502    **    IF sy-subrc = 0 .
503    **      ZJVC_CC_FCFORMS-EI_FORGNENTY_NAME = wa_ventrdtls-EI_FORGNENTY_NAME .
504    **      ZJVC_CC_FCFORMS-EI_FORGNENTY_UIN  = wa_ventrdtls- .
505    *      SUBDRY_RCOMP
506    *      VNAME
507    *      CCPRNTREQ
508    *JVPRNTREQ
509    *SUBSDRYREQ
510    ********************************************************************************
511    *       PERFORM check_perdetails .
512
513    ENDMODULE.                 " GET_CPF1_NAME  INPUT
514    *&---------------------------------------------------------------------*
515    *&      Module  CCNO_JVWISEHELP  INPUT
516    *&---------------------------------------------------------------------*
517    *       text
518    *----------------------------------------------------------------------*
519    MODULE ccno_jvwisehelp INPUT.
520      DATA : l_jvname TYPE zjv_cash_call-vname .
521
522      DATA : BEGIN OF ist_jvname OCCURS 0.
523      DATA : ccreqno   LIKE zjv_cash_call-ccreqno,
524             gjahr     LIKE zjv_cash_call-ccreqno,
525             vname     LIKE zjv_cash_call-vname,
526             vtype     LIKE zjv_cash_call-vtype,
527             status_rp LIKE zjv_cash_call-status_rp.
528      DATA : END OF ist_jvname.
529
530      DATA : ist_return_tab LIKE STANDARD TABLE OF ddshretval
531                                             WITH  HEADER LINE.
532
533      DATA:   lv_dname TYPE dcobjdef-name,                      "20032014
534              lt_dd07v TYPE TABLE OF dd07v,
535              ls_dd07v TYPE dd07v.
536
537      REFRESH : dyfields_1, lt_dd07v.
538
539
540      CLEAR : l_jvname.
541
542      dyfields_1-fieldname = 'ZJVC_CC_FCFORMS-VNAME'.
543
544      APPEND dyfields_1.
545
546      CALL FUNCTION 'DYNP_VALUES_READ'
547        EXPORTING
548          dyname     = sy-cprog
549          dynumb     = sy-dynnr
550        TABLES
551          dynpfields = dyfields_1.
552
553      READ TABLE dyfields_1 INDEX 1.
554
555      MOVE dyfields_1-fieldvalue TO l_jvname.
556
557      SELECT ccreqno gjahr vname vtype FROM zjv_cash_call INTO TABLE
558            ist_jvname WHERE vname = l_jvname AND status_rp ='APPROVED' .
559    *  lv_dname = 'ZBASLOC' .
560      CALL FUNCTION 'DDIF_DOMA_GET'
561        EXPORTING
562          name          = lv_dname
563          langu         = sy-langu
564        TABLES
565          dd07v_tab     = lt_dd07v
566        EXCEPTIONS
567          illegal_input = 1
568          OTHERS        = 2.
569
570      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
571        EXPORTING
572          retfield        = 'CCREQNO'
573          dynpprog        = sy-cprog
574          dynpnr          = sy-dynnr
575          dynprofield     = 'ZJVC_CC_FCFORMS-CCREQNO'
576          value_org       = 'S'
577        TABLES
578          value_tab       = ist_jvname
579          return_tab      = ist_return_tab
580        EXCEPTIONS
581          parameter_error = 1
582          no_values_found = 2
583          OTHERS          = 3.
584      IF sy-subrc <> 0.
585
586        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
587                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
588
589      ENDIF.
590      zjvc_cc_fcforms-ccreqno = ist_return_tab-fieldval.
591      REFRESH ist_jvname.
592      CLEAR ist_return_tab-fieldval.
593    ENDMODULE.
594    *&---------------------------------------------------------------------*
595    *&      Module  MODIFY_IST_PIDETAILS  INPUT
596    *&---------------------------------------------------------------------*
597    *       text
598    *----------------------------------------------------------------------*
599    MODULE modify_ist_pidetails INPUT.
600
601    ***Re-intialise Line Item No with current line of Internal Table
602    *  ZJVC_CC_FCFORMSB-bbpitem = tc_0130-current_line .
603    **********************************************************
604    *  ZJVC_CC_FCFORMSB-DOC_NO  = ZJVC_CC_FCFORMS-DOC_NO.
605    *
606    *  modify IST_PIDETAILS index tc_0130-current_line .
607    *  MOVE-CORRESPONDING ZJVC_CC_FCFORMSB to IST_PIDETAILS .
608    *  IST_PIDETAILS-DOC_NO = ZJVC_CC_FCFORMS-DOC_NO .
609    *
610    *  if sy-subrc ne 0.
611    *    append IST_PIDETAILS.
612    *  else.
613    *    modify IST_PIDETAILS index tc_0130-current_line.
614    *  endif.
615    *  clear: IST_PIDETAILS.
616
617    ENDMODULE.
618    *&---------------------------------------------------------------------*
619    *&      Module  CHECK_BLANK  INPUT
620    *&---------------------------------------------------------------------*
621    *       text
622    *----------------------------------------------------------------------*
623    MODULE check_blank INPUT.
624    *Check for blank UIN No...to maintain in the Master Table
625
626    *IF ZJVC_CC_FCFORMS-EI_FORGNENTY_UIN IS INITIAL .
627    *  MESSAGE 'UNI Cannot be Blank. Please update in Master table ZJVC_CC_ASTBLK' type 'E'.
628    *ENDIF .
629    ENDMODULE.
630    *&---------------------------------------------------------------------*
631    *&      Module  CHECK_VNAME  INPUT
632    *&---------------------------------------------------------------------*
633    *       text
634    *----------------------------------------------------------------------*
635    MODULE check_vname INPUT.
636      DATA: wa_venterr TYPE zjvc_cc_astblk .
637      IF NOT zjvc_cc_fcforms-vname IS INITIAL .
638        SELECT SINGLE * FROM zjvc_cc_astblk INTO wa_venterr WHERE vname EQ zjvc_cc_fcforms-vname .
639        IF sy-subrc NE 0 .
640          MESSAGE 'Venture Name is not maintained in Master table ZJVC_CC_ASTBLK' TYPE 'E' .
641        ENDIF .
642      ENDIF.
643    ENDMODULE.
644    *&---------------------------------------------------------------------*
645    *&      Module  CHECK_CCREQNO  INPUT
646    *&---------------------------------------------------------------------*
647    *       text
648    *----------------------------------------------------------------------*
649    MODULE check_ccreqno INPUT.
650      DATA: wa_ccerr TYPE zjv_cash_call .
651
652    *DATA: ccvntr type ZJVC_CC_FCFORMS-VNAME .
653    *DATA: ccrqvntr type ZJVC_CC_FCFORMS-CCREQNO .
654
655      IF NOT zjvc_cc_fcforms-ccreqno IS INITIAL .
656        SELECT SINGLE * FROM zjv_cash_call INTO wa_ccerr WHERE ccreqno EQ zjvc_cc_fcforms-ccreqno .
657        IF sy-subrc NE 0 .
658          MESSAGE 'Venture Name is not maintained in Master table ZJVC_CC_ASTBLK' TYPE 'E' .
659        ENDIF .
660    *    ccvntr   = ZJVC_CC_FCFORMS-VNAME .
661    *    ccrqvntr = ZJVC_CC_FCFORMS-CCREQNO .
662      ENDIF.
663
664    *  IF NOT ZJVC_CC_FCFORMS-CCREQNO IS INITIAL .
665    *    IF ccvntr+0(2) NE ccrqvntr+0(2).
666    *      MESSAGE 'The Venture Name and CC Req does not match' TYPE 'E' .
667    *    ENDIF.
668    *  ENDIF.
669    *
670    *CLEAR: ccvntr, ccrqvntr .
671    *
672    ************************************************************************************
673    **Begin ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
674    *clear : ist_pidetails . refresh : ist_pidetails .
675    * IF ( SY-TCODE = G_TCODE1 OR G_TCODE = 'ZJVCCFC1' ) .
676    *    SELECT * APPENDING CORRESPONDING FIELDS OF TABLE ist_pidetails
677    *                  FROM  ZJVC_CC_FCFORMSB
678    **                  WHERE DOC_NO = ZJVC_CC_FCFORMS-DOC_NO.
679    *                  WHERE EI_FORGNENTY_UIN = ZJVC_CC_FCFORMS-EI_FORGNENTY_UIN .
680    *  ENDIF ."g_tcode = 'ZJVCCFC1' .
681    **End ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
682    ************************************************************************************
683
684    ENDMODULE.
685    *&---------------------------------------------------------------------*
686    *&      Module  CHECK_SUBDRY_RCOMP  INPUT
687    *&---------------------------------------------------------------------*
688    *       text
689    *----------------------------------------------------------------------*
690    MODULE check_subdry_rcomp INPUT.
691    *DATA: wa_subserr type ZJVC_CC_ASTBLK .
692    *IF NOT ZJVC_CC_FCFORMS-SUBDRY_RCOMP IS INITIAL .
693    *  SELECT SINGLE * FROM ZJVC_CC_ASTBLK INTO wa_subserr WHERE SUBDRY_RCOMP EQ ZJVC_CC_FCFORMS-SUBDRY_RCOMP .
694    *  IF sy-subrc NE 0 .
695    *    MESSAGE 'Venture Name is not maintained in Master table ZJVC_CC_ASTBLK' TYPE 'E' .
696    *  ENDIF .
697    *ENDIF.
698    ENDMODULE.
699    *&---------------------------------------------------------------------*
700    *&      Module  PIDETAILS  OUTPUT
701    *&---------------------------------------------------------------------*
702    *       text
703    *----------------------------------------------------------------------*
704    MODULE pidetails OUTPUT.
705    ***********************************************************************************
706    *Begin ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
707      CLEAR : ist_pidetails . REFRESH : ist_pidetails .
708    * IF ( SY-TCODE = G_TCODE1 OR G_TCODE = 'ZJVCCFC1' ) .
709      SELECT * APPENDING CORRESPONDING FIELDS OF TABLE ist_pidetails
710                    FROM  zjvc_cc_fcformsb
711    *                  WHERE DOC_NO = ZJVC_CC_FCFORMS-DOC_NO.
712                    WHERE ei_forgnenty_uin = zjvc_cc_fcforms-ei_forgnenty_uin .
713      SORT ist_pidetails BY india_frgn_partnr ASCENDING .
714    *  ENDIF ."g_tcode = 'ZJVCCFC1' .
715    *End ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
716    ***********************************************************************************
717
718    ENDMODULE.
719    *&---------------------------------------------------------------------*
720    *&      Module  CHECK_BELNR  INPUT
721    *&---------------------------------------------------------------------*
722    *       text
723    *----------------------------------------------------------------------*
724    MODULE check_belnr INPUT.
725      DATA: wa_belnr TYPE bkpf .
726      IF NOT zjvc_cc_fcforms-belnr IS INITIAL .
727        SELECT SINGLE * FROM bkpf INTO wa_belnr WHERE belnr EQ zjvc_cc_fcforms-belnr .
728        IF sy-subrc NE 0 .
729          MESSAGE 'Fin Doc is not maintained in table BKPF' TYPE 'E' .
730        ENDIF .
731      ENDIF.
732    ENDMODULE.
*--- End of SAPMZPSJVCCFCFORMSI01 - 732 lines ---

----------------------------------------------------------------------------------------------------
Include          SAPMZPSJVCCFCFORMSF01                     Level 1    Page 5
Object           SAPMZPSJVCCFCFORMS                        Lines 1777
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:21
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&  Include           SAPMZPSJVCCFCFORMSF01
3      *&---------------------------------------------------------------------*
4      *&      Form  CLEARDATA
5      *&---------------------------------------------------------------------*
6      *       text
7      *----------------------------------------------------------------------*
8      *  -->  p1        text
9      *  <--  p2        text
10     *----------------------------------------------------------------------*
11     FORM cleardata .
12       CLEAR: zjvc_cc_fcforms.
13       REFRESH: ist_zjvcccfc .
14       CLEAR:g_tstamp .
15
16       ts_110  = 'PUSH1'.
17       g_dynnr = '0120'.
18       ts_110-activetab = 'PUSH1'.
19     ENDFORM.                    " CLEARDATA
20     *&---------------------------------------------------------------------*
21     *&      Form  GET_DATA
22     *&---------------------------------------------------------------------*
23     *       text
24     *----------------------------------------------------------------------*
25     *  -->  p1        text
26     *  <--  p2        text
27     *----------------------------------------------------------------------*
28     FORM get_data .
29       IF sy-tcode = 'ZJVCCFC2' OR sy-tcode = 'ZJVCCFC1' OR sy-tcode = 'ZJVCCFC3' OR sy-tcode = 'ZJVCCFC4' OR sy-tcode = 'ZJVCCFC5'
30         OR g_tcode = 'ZJVCCFC2'  OR g_tcode = 'ZJVCCFC1'  OR g_tcode = 'ZJVCCFC3' OR g_tcode = 'ZJVCCFC4' OR g_tcode = 'ZJVCCFC5'.
31
32         CLEAR : ist_pidetails .
33         REFRESH : ist_pidetails .
34         IF  sy-tcode = 'ZJVCCFC2' OR g_tcode = 'ZJVCCFC2' OR sy-tcode = 'ZJVCCFC5' OR g_tcode = 'ZJVCCFC5'.
35           PERFORM lock_header.
36         ENDIF.
37         PERFORM get_alldetails.
38       ENDIF.
39     ENDFORM.                    " GET_DATA
40     *&---------------------------------------------------------------------*
41     *&      Form  LOCK_HEADER
42     *&---------------------------------------------------------------------*
43     *       text
44     *----------------------------------------------------------------------*
45     *  -->  p1        text
46     *  <--  p2        text
47     *----------------------------------------------------------------------*
48     FORM lock_header .
49
50       CALL FUNCTION 'ENQUEUE_EZJV_CC_FCFORM'
51         EXPORTING
52           mode_zjvc_cc_fcforms = 'E'
53           mandt                = sy-mandt
54           doc_no               = zjvc_cc_fcforms-doc_no
55     *     X_MWPDOCNO           = ' '
56     *     X_VERSION            = ' '
57     *     _SCOPE               = '2'
58     *     _WAIT                = ' '
59     *     _COLLECT             = ' '
60         EXCEPTIONS
61           foreign_lock         = 1
62           system_failure       = 2
63           OTHERS               = 3.
64
65       IF sy-subrc <> 0.
66         MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
67                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
68       ENDIF.
69     ENDFORM.                    " LOCK_HEADER
70     *&---------------------------------------------------------------------*
71     *&      Form  GET_ALLDETAILS
72     *&---------------------------------------------------------------------*
73     *       text
74     *----------------------------------------------------------------------*
75     *  -->  p1        text
76     *  <--  p2        text
77     *----------------------------------------------------------------------*
78     FORM get_alldetails .
79       CLEAR: ist_zjvcccfc .
80       REFRESH: ist_zjvcccfc .
81
82       IF  g_tcode = 'ZJVCCFC2' OR g_tcode = 'ZJVCCFC3' OR g_tcode = 'ZJVCCFC4' OR g_tcode = 'ZJVCCFC5'.
83
84         SELECT SINGLE * FROM zjvc_cc_fcforms
85                    WHERE doc_no = zjvc_cc_fcforms-doc_no.
86     *               AND   version  = 'L' .
87
88
89
90         IF sy-subrc EQ 0.
91     *      PERFORM CHECK_AUTH.
92           MOVE-CORRESPONDING zjvc_cc_fcforms TO zjvc_cc_fcforms.
93         ENDIF."sy-subrc EQ 0.
94         SELECT * FROM ZJVC_TOTAL UP TO 1 ROWS
95      WHERE DOC_NO = ZJVC_CC_FCFORMS-DOC_NO
96      ORDER BY PRIMARY KEY .
97      ENDSELECT.
98         IF sy-subrc EQ 0.
99           MOVE-CORRESPONDING zjvc_total TO zjvc_total.
100        ENDIF.
101
102
103      ENDIF ."g_tcode = 'ZJVCCFC2' OR g_tcode = 'ZJVCCFC3' OR g_tcode = 'ZJVCCFC4' ."OR g_tcode = 'ZJVCCFC5'.
104    **Get details from other tables**********
105    **Get Line Item Data
106    **CLEAR : ist_pidetails .
107    **REFRESH : ist_pidetails .
108    ************************************************************************************
109    **Begin ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
110    *    SELECT * APPENDING CORRESPONDING FIELDS OF TABLE ist_pidetails
111    *                  FROM  ZJVC_CC_FCFORMSB
112    **                  WHERE DOC_NO = ZJVC_CC_FCFORMS-DOC_NO.
113    *                  WHERE EI_FORGNENTY_UIN = ZJVC_CC_FCFORMS-EI_FORGNENTY_UIN .
114    *   ENDIF."sy-subrc EQ 0.
115    *  ENDIF ."g_tcode = 'ZJVCCFC2' OR g_tcode = 'ZJVCCFC3' OR g_tcode = 'ZJVCCFC4' ."OR g_tcode = 'ZJVCCFC5'.
116    **End ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
117    ************************************************************************************
118    ** Get domain name for basin location
119
120    *    SELECT SINGLE * FROM ZJVCCFC_TOT
121    *               WHERE DOC_NO = ZJVC_CC_FCFORMS-DOC_NO.
122    *      IF sy-subrc EQ 0.
123    **      PERFORM CHECK_AUTH.
124    *      MOVE-CORRESPONDING ZJVCCFC_TOT TO ZJVCCFC_TOT.
125    *      ENDIF.
126    *PERFORM ALLTOTALS.
127    ENDFORM.                    " GET_ALLDETAILS
128    *&---------------------------------------------------------------------*
129    *&      Form  EXIT_CONFIRMATION
130    *&---------------------------------------------------------------------*
131    *       text
132    *----------------------------------------------------------------------*
133    *  -->  p1        text
134    *  <--  p2        text
135    *----------------------------------------------------------------------*
136    FORM exit_confirmation .
137    *Confirmation for exit the record
138      IF sy-tcode NE g_tcode3 OR g_tcode NE g_tcode3 .
139        CLEAR:g_ok_110.                                         ",g_ok_110.
140        PERFORM confirm_action USING text-001 text-002 g_action.
141        IF g_action EQ '1'.
142    *Unlock the record
143          PERFORM unlock_record.
144    *    leave to transaction g_tcode.
145          IF sy-dynnr = '0100' .
146            LEAVE PROGRAM.
147          ELSEIF sy-dynnr = '0105' .
148            LEAVE TO SCREEN '0100' .
149          ENDIF .
150        ENDIF.
151      ENDIF.
152      CLEAR: g_flag .
153
154    ENDFORM.                    " EXIT_CONFIRMATION
155    *&---------------------------------------------------------------------*
156    *&      Form  CONFIRM_ACTION
157    *&---------------------------------------------------------------------*
158    *       text
159    *----------------------------------------------------------------------*
160    *      -->P_TEXT_001  text
161    *      -->P_TEXT_002  text
162    *      -->P_G_ACTION  text
163    *----------------------------------------------------------------------*
164    FORM confirm_action  USING    l_title
165                                  l_question
166                                  l_action.
167      CALL FUNCTION 'POPUP_TO_CONFIRM'
168        EXPORTING
169          titlebar              = l_title
170          text_question         = l_question
171          text_button_1         = 'Yes'
172          icon_button_1         = 'ICON_OKAY'
173          text_button_2         = 'No'
174          icon_button_2         = 'ICON_REJECT'
175          default_button        = '1'
176          display_cancel_button = 'X'
177          start_column          = 25
178          start_row             = 6
179        IMPORTING
180          answer                = l_action
181        EXCEPTIONS
182          text_not_found        = 1
183          OTHERS                = 2.
184
185      IF sy-subrc <> 0.
186        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
187                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
188      ENDIF.
189
190    ENDFORM.                    " CONFIRM_ACTION
191    *&---------------------------------------------------------------------*
192    *&      Form  UNLOCK_RECORD
193    *&---------------------------------------------------------------------*
194    *       text
195    *----------------------------------------------------------------------*
196    *  -->  p1        text
197    *  <--  p2        text
198    *----------------------------------------------------------------------*
199    FORM unlock_record .
200      CALL FUNCTION 'DEQUEUE_EZJV_CC_FCFORM'
201        EXPORTING
202          mode_zjvc_cc_fcforms = 'E'
203          mandt                = sy-mandt
204          doc_no               = zjvc_cc_fcforms-doc_no
205          x_doc_no             = ' '
206    *     WELLID               = ZPS_DGR_H-WELLID
207    *     DPR_DT               = ZPS_DGR_H-DPR_DT
208    *     X_DGRNR              = ' '
209    *     X_WELLID             = ' '
210    *     X_DPR_DT             = ' '
211          _scope               = '3'
212          _synchron            = ' '
213          _collect             = ' '.
214
215
216
217    ENDFORM.                    " UNLOCK_RECORD
218    *&---------------------------------------------------------------------*
219    *&      Form  UNLOCK_HEADER
220    *&---------------------------------------------------------------------*
221    *       text
222    *----------------------------------------------------------------------*
223    *  -->  p1        text
224    *  <--  p2        text
225    *----------------------------------------------------------------------*
226    FORM unlock_header .
227      CALL FUNCTION 'DEQUEUE_EZJV_CC_FCFORM'
228        EXPORTING
229          mode_zjvc_cc_fcforms = 'E'
230          mandt                = sy-mandt
231          doc_no               = zjvc_cc_fcforms-doc_no.
232    *      version            = ZPS_MWP_BLOCK-VERSION.
233    ENDFORM.                    " UNLOCK_HEADER
234    *&---------------------------------------------------------------------*
235    *&      Form  INSERT
236    *&---------------------------------------------------------------------*
237    *       text
238    *----------------------------------------------------------------------*
239    *  -->  p1        text
240    *  <--  p2        text
241    *----------------------------------------------------------------------*
242    FORM insert .
243      PERFORM generate_dgrdocno .
244      PERFORM timestamp.
245    *******************************************************
246    *PERFORM check_perdetails .
247    *Insert header details
248      zjvc_cc_fcforms-ernam        = sy-uname.
249      zjvc_cc_fcforms-erfdt        = sy-datum.
250      zjvc_cc_fcforms-timestamp    = g_tstamp.
251
252    ************************************************************************************************************************************
253      MOVE-CORRESPONDING zjvc_cc_fcforms TO zjvc_cc_fcforms.
254      INSERT zjvc_cc_fcforms.
255
256      zjvc_total-doc_no = zjvc_cc_fcforms-doc_no.
257      zjvc_total-unq_id = zjvc_cc_fcforms-ei_forgnenty_uin.
258      MODIFY zjvc_total.
259    ********************************************************
260    *Fill Document Values, Totals & Grand Totals (UIN wise and OVL wise) in table ZJVCCFC_TOT
261    ******************************************************************************************
262    *IF NOT ZJVC_CC_FCFORMS-FORGN_FINCOMMITFCY_PFGRNT IS INITIAL .
263    *  ZJVCCFC_TOT-FORGN_FINCOMMITFCY_PFGRNT50 = ZJVC_CC_FCFORMS-FORGN_FINCOMMITFCY_PFGRNT / 2 .
264    *ENDIF.
265    *IF NOT ZJVC_CC_FCFORMS-FORGN_FINCOMMITINR_PFGRNT IS INITIAL .
266    *  ZJVCCFC_TOT-FORGN_FINCOMMITINR_PFGRNT50 = ZJVC_CC_FCFORMS-FORGN_FINCOMMITINR_PFGRNT / 2.
267    *ENDIF.
268    *IF NOT ZJVC_CC_FCFORMS-FORGN_FINCOMMITUSD_PFGRNT IS INITIAL .
269    *  ZJVCCFC_TOT-FORGN_FINCOMMITUSD_PFGRNT50 = ZJVC_CC_FCFORMS-FORGN_FINCOMMITUSD_PFGRNT / 2 .
270    *ENDIF.
271    **Get Totals for current Document
272    *ZJVCCFC_TOT-FORGN_FINCOMMITFCY_DOCUTOT = ( ZJVC_CC_FCFORMS-FORGN_FINCOMMITFCY_EQT + ZJVC_CC_FCFORMS-FORGN_FINCOMMITFCY_LOAN + ZJVCCFC_TOT-FORGN_FINCOMMITFCY_PFGRNT50 + ZJVC_CC_FCFORMS-FORGN_FINCOMMITFCY_CORGRNT ).
273    *ZJVCCFC_TOT-FORGN_FINCOMMITINR_DOCUTOT = ( ZJVC_CC_FCFORMS-FORGN_FINCOMMITINR_EQT + ZJVC_CC_FCFORMS-FORGN_FINCOMMITINR_LOAN + ZJVCCFC_TOT-FORGN_FINCOMMITINR_PFGRNT50 + ZJVC_CC_FCFORMS-FORGN_FINCOMMITINR_CORGRNT ).
274    *ZJVCCFC_TOT-FORGN_FINCOMMITUSD_DOCUTOT = ( ZJVC_CC_FCFORMS-FORGN_FINCOMMITUSD_EQT + ZJVC_CC_FCFORMS-FORGN_FINCOMMITUSD_LOAN + ZJVCCFC_TOT-FORGN_FINCOMMITUSD_PFGRNT50 + ZJVC_CC_FCFORMS-FORGN_FINCOMMITUSD_CORGRNT ).
275    ******************************************************************************************
276    *  perform totals .
277    *  move-corresponding ZJVC_CC_FCFORMS to ZJVCCFC_TOT.
278    *  insert ZJVCCFC_TOT.
279    ********************************************************
280    * Insert Partner details with Stake (PI) details
281    *IF NOT ist_pidetails[] IS INITIAL .
282    *  loop at ist_pidetails.
283    *    ist_pidetails-DOC_NO      = ZJVC_CC_FCFORMS-DOC_NO.
284    **    ist_pidetails-INDIA_FRGN_PARTNR = ZJVC_CC_FCFORMSB-INDIA_FRGN_PARTNR.
285    **    ist_pidetails-NAME_OF_PARTNER   = ZJVC_CC_FCFORMSB-NAME_OF_PARTNER.
286    **    ist_pidetails-PERCTG_STAKE      = ZJVC_CC_FCFORMSB-PERCTG_STAKE.
287    *    ist_pidetails-ernam      = sy-uname.
288    *    ist_pidetails-erfdt      = sy-datum.
289    *    ist_pidetails-aeusn      = sy-uname.
290    *    ist_pidetails-aedtm     = sy-datum.
291    *    ist_pidetails-timestamp  = g_tstamp.
292    *    move-corresponding ist_pidetails to ZJVC_CC_FCFORMSB.
293    *    insert ZJVC_CC_FCFORMSB.
294    *  endloop.
295    *ENDIF. "IF NOT ist_pidetails[] IS INITIAL .
296    *******************************************************
297    *CLEAR : ZJVC_CC_FCFORMS, ZJVCCFC_TOT .
298      IF sy-subrc NE 0.
299        ROLLBACK WORK.
300        MESSAGE e210(zps) WITH 'ZJVC_CC_FCFORMS' space.
301      ENDIF.
302
303      CLEAR:sy-subrc.
304    *******************************************************
305
306    *******************************************************
307      CLEAR:sy-subrc.
308    *BREAK sap_abap .
309      MESSAGE s202(zps) WITH text-434 zjvc_cc_fcforms-doc_no.
310    *  leave to screen '0100'.
311
312    ENDFORM.                    " INSERT
313
314    *&---------------------------------------------------------------------*
315    *&      Form  GENERATE_DGRDOCNO
316    *&---------------------------------------------------------------------*
317    *       text
318    *----------------------------------------------------------------------*
319    *  -->  p1        text
320    *  <--  p2        text
321    *----------------------------------------------------------------------*
322    FORM generate_dgrdocno .
323      CALL FUNCTION 'NUMBER_GET_NEXT'
324        EXPORTING
325          nr_range_nr             = '01'
326    *     OBJECT                  = 'ZPSDGRNR'
327          object                  = 'ZJVCCFC'
328        IMPORTING
329    *     NUMBER                  = ZPS_DGR_H-DGRNR
330          number                  = zjvc_cc_fcforms-doc_no
331        EXCEPTIONS
332          interval_not_found      = 1
333          number_range_not_intern = 2
334          object_not_found        = 3
335          quantity_is_0           = 4
336          quantity_is_not_1       = 5
337          interval_overflow       = 6
338          buffer_overflow         = 7
339          OTHERS                  = 8.
340
341      IF sy-subrc <> 0.
342        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
343                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
344      ENDIF.
345
346    ENDFORM.                    " GENERATE_DGRDOCNO
347    *&---------------------------------------------------------------------*
348    *&      Form  TIMESTAMP
349    *&---------------------------------------------------------------------*
350    *       text
351    *----------------------------------------------------------------------*
352    *  -->  p1        text
353    *  <--  p2        text
354    *----------------------------------------------------------------------*
355    FORM timestamp .
356    * Getting timestamp
357      CALL FUNCTION 'OIF_CONV_DATE_TIME_TS'
358        EXPORTING
359          i_datum           = sy-datum
360          i_time            = sy-uzeit
361        IMPORTING
362          e_timestamp       = g_tstamp
363        EXCEPTIONS
364          date_not_received = 1
365          time_not_received = 2
366          OTHERS            = 3.
367      IF sy-subrc <> 0.
368        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
369                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
370      ENDIF.
371
372    ENDFORM.                    " TIMESTAMP
373    *&---------------------------------------------------------------------*
374    *&      Form  UPDATE
375    *&---------------------------------------------------------------------*
376    *       text
377    *----------------------------------------------------------------------*
378    *  -->  p1        text
379    *  <--  p2        text
380    *----------------------------------------------------------------------*
381    FORM update .
382    *  BREAK-POINT.
383    ** Update
384      PERFORM delete_record.
385      PERFORM timestamp.
386    ********************************************************
387      PERFORM check_perdetails .
388    **Update System Fields
389      IF g_tcode EQ 'ZJVCCFC2' .
390        zjvc_cc_fcforms-aeusn       = sy-uname.
391        zjvc_cc_fcforms-aedtm       = sy-datum.
392        zjvc_cc_fcforms-timestamp   = g_tstamp.
393      ENDIF.
394
395      IF g_tcode EQ 'ZJVCCFC5' .
396
397        DATA: ls_app TYPE zjvc_approve.
398
399        ls_app-aeusn = sy-uname.
400        ls_app-aedtm = sy-datum.
401        ls_app-timestamp = g_tstamp.
402        ls_app-doc_no = zjvc_cc_fcforms-doc_no.
403        ls_app-ei_forgnenty_uin = zjvc_cc_fcforms-ei_forgnenty_uin.
404
405        MODIFY zjvc_approve FROM ls_app.
406
407      ENDIF.
408
409
410      IF sy-tcode = g_tcode5 OR g_tcode = 'ZJVCCFC5'.
411        PERFORM confirm_action USING text-004 text-005 g_action.
412        IF g_action EQ '1'.
413          zjvc_cc_fcforms-doc_app     = 'X' .
414          MESSAGE s275(zps) WITH text-026 zjvc_cc_fcforms-doc_no .
415        ELSE.
416          MESSAGE s276(zps) WITH text-026 zjvc_cc_fcforms-doc_no .
417        ENDIF.
418    *  message s205(zps) with text-026 ZJVC_CC_FCFORMS-DOC_NO .
419      ENDIF .
420
421      MOVE-CORRESPONDING zjvc_cc_fcforms TO zjvc_cc_fcforms .
422
423      MODIFY zjvc_cc_fcforms.
424
425      zjvc_total-doc_no = zjvc_cc_fcforms-doc_no.
426      zjvc_total-unq_id = zjvc_cc_fcforms-ei_forgnenty_uin.
427      MODIFY zjvc_total.
428
429    *  g_EI_FORGNENTY_UIN = ZJVC_CC_FCFORMS-EI_FORGNENTY_UIN .
430    *******************************************************************************************************************************
431    *Apply the addition/reduction all the Document to subsequent document totals. in the loop
432    *  SELECT * APPENDING CORRESPONDING FIELDS OF TABLE ist_ovldetails FROM  ZJVC_CC_FCFORMS .
433    *  IF sy-subrc EQ 0.
434    *    DELETE ist_ovldetails WHERE DOC_NO LE ZJVC_CC_FCFORMS-DOC_NO .
435    *
436    *    LOOP AT ist_ovldetails .
437    *      SELECT SINGLE * FROM ZJVC_CC_FCFORMS WHERE DOC_NO EQ ist_ovldetails-DOC_NO .
438    *      IF sy-subrc EQ 0.
439    *        ZJVC_CC_FCFORMS-FORGN_FINCOMMITUSD_OVLTOT = ist_ovldetails-FORGN_FINCOMMITUSD_OVLTOT + ( 1 * g_resddoctot_ovlusd ) .
440    *        ZJVC_CC_FCFORMS-FORGN_FINCOMMITINR_OVLTOT = ist_ovldetails-FORGN_FINCOMMITINR_OVLTOT + ( 1 * g_resddoctot_ovlinr ) .
441    *
442    *       IF  ist_ovldetails-EI_FORGNENTY_UIN =  g_EI_FORGNENTY_UIN .
443    *        ZJVC_CC_FCFORMS-FORGN_FINCOMMITUSD_UINTOT = ist_ovldetails-FORGN_FINCOMMITUSD_UINTOT + ( 1 * g_resddoctot_ovlusd ) .
444    *        ZJVC_CC_FCFORMS-FORGN_FINCOMMITINR_UINTOT = ist_ovldetails-FORGN_FINCOMMITINR_UINTOT + ( 1 * g_resddoctot_ovlinr ) .
445    *       ENDIF." IF  ist_ovldetails-EI_FORGNENTY_UIN =  g_EI_FORGNENTY_UIN .
446    *
447    *        move-corresponding ZJVC_CC_FCFORMS to ZJVC_CC_FCFORMS .
448    *        MODIFY ZJVC_CC_FCFORMS.
449    *      ENDIF ." IF sy-subrc EQ 0.
450    *    ENDLOOP.
451    *  ENDIF. "  IF sy-subrc EQ 0.
452
453    *******************************************************************************************************************************
454
455    *Fetch Totals UIN wise and OVL wise from Totals table ZJVCCFC_TOT
456    ********************************************************
457    *Fill Document Values, Totals & Grand Totals (UIN wise and OVL wise) in table ZJVCCFC_TOT
458    *IF NOT ZJVC_CC_FCFORMS-FORGN_FINCOMMITFCY_PFGRNT IS INITIAL .
459    *  ZJVCCFC_TOT-FORGN_FINCOMMITFCY_PFGRNT50 = ZJVC_CC_FCFORMS-FORGN_FINCOMMITFCY_PFGRNT / 2 .
460    *ENDIF.
461    *IF NOT ZJVC_CC_FCFORMS-FORGN_FINCOMMITINR_PFGRNT IS INITIAL .
462    *  ZJVCCFC_TOT-FORGN_FINCOMMITINR_PFGRNT50 = ZJVC_CC_FCFORMS-FORGN_FINCOMMITINR_PFGRNT / 2.
463    *ENDIF.
464    *IF NOT ZJVC_CC_FCFORMS-FORGN_FINCOMMITUSD_PFGRNT IS INITIAL .
465    *  ZJVCCFC_TOT-FORGN_FINCOMMITUSD_PFGRNT50 = ZJVC_CC_FCFORMS-FORGN_FINCOMMITUSD_PFGRNT / 2 .
466    *ENDIF.
467    **break sap_abap .
468    **Get Totals for current Document
469    *ZJVCCFC_TOT-FORGN_FINCOMMITFCY_DOCUTOT = ( ZJVC_CC_FCFORMS-FORGN_FINCOMMITFCY_EQT + ZJVC_CC_FCFORMS-FORGN_FINCOMMITFCY_LOAN + ZJVCCFC_TOT-FORGN_FINCOMMITFCY_PFGRNT50 + ZJVC_CC_FCFORMS-FORGN_FINCOMMITFCY_CORGRNT ).
470    *ZJVCCFC_TOT-FORGN_FINCOMMITINR_DOCUTOT = ( ZJVC_CC_FCFORMS-FORGN_FINCOMMITINR_EQT + ZJVC_CC_FCFORMS-FORGN_FINCOMMITINR_LOAN + ZJVCCFC_TOT-FORGN_FINCOMMITINR_PFGRNT50 + ZJVC_CC_FCFORMS-FORGN_FINCOMMITINR_CORGRNT ).
471    *ZJVCCFC_TOT-FORGN_FINCOMMITUSD_DOCUTOT = ( ZJVC_CC_FCFORMS-FORGN_FINCOMMITUSD_EQT + ZJVC_CC_FCFORMS-FORGN_FINCOMMITUSD_LOAN + ZJVCCFC_TOT-FORGN_FINCOMMITUSD_PFGRNT50 + ZJVC_CC_FCFORMS-FORGN_FINCOMMITUSD_CORGRNT ).
472    *
473    **********************************************************
474    *  perform totals .
475    *  move-corresponding ZJVC_CC_FCFORMS to ZJVCCFC_TOT.
476    **
477    *  modify ZJVCCFC_TOT.
478    *CLEAR : ZJVCCFC_TOT .
479    *      perform uintots .
480    ********************************************************
481    *  message s205(zps) with text-434 ZJVC_CC_FCFORMS-DOC_NO .
482
483    *  clear : ZJVC_CC_FCFORMS  .
484    *leave to screen '0100'.
485    ***********************************************************************************
486    *Begin ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
487    ********************************************************
488    * Insert Partner details with Stake (PI) details
489    *IF NOT ist_pidetails[] IS INITIAL .
490    *  loop at ist_pidetails.
491    *    select single * from ZJVC_CC_FCFORMSB
492    *                        where DOC_NO  = ZJVC_CC_FCFORMS-DOC_NO
493    *                        and   BBPITEM       = ist_pidetails-BBPITEM.
494    *    IF sy-subrc eq 0.
495    **    ist_pidetails-DOC_NO            = ZJVC_CC_FCFORMS-DOC_NO.
496    **    ist_pidetails-INDIA_FRGN_PARTNR = ZJVC_CC_FCFORMSB-INDIA_FRGN_PARTNR.
497    **    ist_pidetails-NAME_OF_PARTNER   = ZJVC_CC_FCFORMSB-NAME_OF_PARTNER.
498    **    ist_pidetails-PERCTG_STAKE      = ZJVC_CC_FCFORMSB-PERCTG_STAKE.
499    *    ist_pidetails-ernam      = sy-uname.
500    *    ist_pidetails-erfdt      = sy-datum.
501    *    ist_pidetails-aeusn      = sy-uname.
502    *    ist_pidetails-aedtm     = sy-datum.
503    *    ist_pidetails-timestamp  = g_tstamp.
504    *      move-corresponding ist_pidetails to ZJVC_CC_FCFORMSB.
505    *      modify ZJVC_CC_FCFORMSB.
506    *    ELSE.
507    **    ist_pidetails-DOC_NO            = ZJVC_CC_FCFORMS-DOC_NO.
508    **    ist_pidetails-INDIA_FRGN_PARTNR = ZJVC_CC_FCFORMSB-INDIA_FRGN_PARTNR.
509    **    ist_pidetails-NAME_OF_PARTNER   = ZJVC_CC_FCFORMSB-NAME_OF_PARTNER.
510    **    ist_pidetails-PERCTG_STAKE      = ZJVC_CC_FCFORMSB-PERCTG_STAKE.
511    *    ist_pidetails-ernam      = sy-uname.
512    *    ist_pidetails-erfdt      = sy-datum.
513    *    ist_pidetails-aeusn      = sy-uname.
514    *    ist_pidetails-aedtm     = sy-datum.
515    *    ist_pidetails-timestamp  = g_tstamp.
516    *      move-corresponding ist_pidetails to ZJVC_CC_FCFORMSB.
517    *      insert ZJVC_CC_FCFORMSB.
518    *    ENDIF.
519    *
520    *CLEAR: ist_pidetails .
521    *  endloop.
522    *End ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
523    ***********************************************************************************
524    **************************************************************
525      IF sy-tcode = g_tcode2 OR g_tcode = 'ZJVCCFC2'.
526        MESSAGE s205(zps) WITH text-434 zjvc_cc_fcforms-doc_no .
527      ELSE .
528    *    message s275(zps) with text-434 ZJVC_CC_FCFORMS-DOC_NO .
529      ENDIF .
530    **************************************************************
531      CLEAR: ist_pidetails , zjvc_cc_fcforms .", ZJVCCFC_TOT , ZJVCCFC_TOT-FORGN_FINCOMMITFCY_UINTOT, ZJVCCFC_TOT-FORGN_FINCOMMITFCY_DOCUTOT, ZJVCCFC_TOT-FORGN_FINCOMMITFCY_OVLTOT.
532    ***********************************************************************************
533    *Begin ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
534    *ENDIF. "IF NOT ist_pidetails[] IS INITIAL .
535    *End ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
536    ***********************************************************************************
537    ENDFORM.                    " UPDATE
538    *----------------------------------------------------------------------*
539    *FORM APPROVE .
540    *  PERFORM confirm_action USING text-024 text-025 l_action.
541    *
542    *  IF l_action EQ '1'.
543    *    PERFORM lock_header.
544    *
545    **Let us Mark the status of deleted Document as 'L' in field zps_mwp_block-version
546    *    UPDATE zps_dgr_h SET objects_apprvd = '10'
547    *           WHERE dgrnr = zps_dgr_h-dgrnr.
548    *
549    *
550    **        UPDATE zps_mwp_block SET delin = 'X'
551    **               WHERE mwpdocno = zps_mwp_block-mwpdocno.
552    *
553    *******************************************
554    *    UPDATE  zps_dgr_h SET aenam     = sy-uname
555    *            WHERE dgrnr = zps_dgr_h-dgrnr.
556    *
557    *    UPDATE  zps_dgr_h SET laeda    = sy-datum
558    *            WHERE dgrnr = zps_dgr_h-dgrnr.
559    *
560    *    perform timestamp.
561    *
562    *    UPDATE  zps_dgr_h SET timestamp = g_tstamp
563    *            WHERE dgrnr = zps_dgr_h-dgrnr.
564    *
565    ********************************************
566    **
567    *    MESSAGE e000(zps) WITH 'Document No' zps_dgr_h-dgrnr text-026.
568    *
569    *    PERFORM unlock_header .
570    *
571    *  ENDIF.
572
573    *ENDFORM.                    " APPROVE
574    *&---------------------------------------------------------------------*
575    *&      Form  CHECK
576    *&---------------------------------------------------------------------*
577    *       text
578    *----------------------------------------------------------------------*
579    *  -->  p1        text
580    *  <--  p2        text
581    *----------------------------------------------------------------------*
582    *FORM CHECK .
583
584    *  if g_tcode = 'ZPSDGR1'.
585    *    if zps_dgr_h-dpr_dt gt sy-datum.
586    *      MESSAGE i127(zps) WITH ZPS_DGR_H-dpr_dt space .
587    *      leave to screen '0100'.
588    *    endif.
589    *    select single * from zps_dgr_h where wellid = zps_dgr_h-wellid
590    *                              and dpr_dt = zps_dgr_h-dpr_dt
591    *                              and del ne 'X'.
592    *    if sy-subrc = 0.
593    *      MESSAGE i318(zps) WITH ZPS_DGR_H-DGRNR space .
594    *      leave to screen '0100'.
595    *    endif.
596    *  endif.
597    *ENDFORM.                    " CHECK
598    *&---------------------------------------------------------------------*
599    *&      Form  CHECK_AUTH
600    *&---------------------------------------------------------------------*
601    *       text
602    *----------------------------------------------------------------------*
603    *  -->  p1        text
604    *  <--  p2        text
605    *----------------------------------------------------------------------*
606    FORM check_auth .
607    *  DATA:l_actvt(2) TYPE c.
608    *  DATA : L_BASCD TYPE ZPS_BASINMAST-BASINCD.
609    *  data: l_bukrs type zps_wellmast-bukrs.
610    *
611    *  CLEAR L_ACTVT.
612    *  CLEAR L_BASCD.
613    *  clear l_bukrs.
614    *
615    *  IF save_ok = 'ENTE'.
616    *    l_actvt = '01'.
617    *  ENDIF.
618    *  IF save_ok = 'CHNG'.
619    *    l_actvt = '02'.
620    *  ENDIF.
621    *  IF save_ok = 'DISP'.
622    *    l_actvt = '03'.
623    *  ENDIF.
624    *  IF save_ok = 'DELE'.
625    **    l_actvt = '04'.
626    *    l_actvt = '02'.
627    *  ENDIF.
628    *
629    *  IF sy-subrc NE 0.
630    *    IF l_actvt = '01'.
631    *      MESSAGE e406(zps) WITH text-012 .
632    **    ELSEIF l_actvt = '02'.
633    *    ELSEIF save_ok = 'CHNG'.
634    *      MESSAGE e406(zps) WITH text-013.
635    *    ELSEIF l_actvt = '03'.
636    *      MESSAGE e406(zps) WITH text-014.
637    **    ELSEIF l_actvt = '04'.
638    *    ELSEIF save_ok = 'DELE'.
639    *      MESSAGE e406(zps) WITH text-015.
640    *    ENDIF.
641    *
642    *  ENDIF.
643
644    ENDFORM.                    " CHECK_AUTH
645    *&---------------------------------------------------------------------*
646    *&      Form  ATTACH_DOCS
647    *&---------------------------------------------------------------------*
648    *       text
649    *----------------------------------------------------------------------*
650    *  -->  p1        text
651    *  <--  p2        text
652    *----------------------------------------------------------------------*
653    *FORM ATTACH_DOCS .
654    *  DATA :  ist_att_files like table of SWOTOBJID,
655    *          wa_att_files  like SWOTOBJID.
656    *
657    **  IF NOT ZPS_MWP_BLOCK-MWPDOCNO IS INITIAL.
658    *
659    *  PERFORM unlock_header .
660    *
661    **    wa_att_files-objkey  = ZPS_MWP_BLOCK-MWPDOCNO .
662    *  wa_att_files-logsys  = 'ZDGRDOCS'.
663    *  wa_att_files-objtype = 'ATT'.
664    *  wa_att_files-objkey  = ZPS_DGR_H-DGRNR ."'01'.
665    *
666    *  append wa_att_files to ist_att_files.
667    *
668    *  DATA: dummy_sodocchgi1 TYPE  sodocchgi1.
669    *
670    *  CALL FUNCTION 'SO_WIND_ATTACHMENT_CREATE_API1'
671    *    EXPORTING
672    *      ATTACHMENT_DATA     = dummy_sodocchgi1
673    *      ATTACHMENT_TYPE     = 'DOC'
674    *    TABLES
675    *      APPLICATION_OBJECTS = ist_att_files.
676    *ENDFORM.                    " ATTACH_DOCS
677    *&---------------------------------------------------------------------*
678    *&      Form  LIST_DOCS
679    *&---------------------------------------------------------------------*
680    *       text
681    *----------------------------------------------------------------------*
682    *  -->  p1        text
683    *  <--  p2        text
684    *----------------------------------------------------------------------*
685    *FORM LIST_DOCS .
686    *  DATA :  ist_att_files like table of SWOTOBJID,
687    *          wa_att_files  like SWOTOBJID.
688    *
689    *
690    *  IF NOT ZPS_DGR_H-DGRNR IS INITIAL.
691    *
692    *    wa_att_files-objkey  = ZPS_DGR_H-DGRNR .
693    *    wa_att_files-logsys  = 'ZDGRDOCS'.
694    *    wa_att_files-objtype = 'ATT'.
695    ***    wa_att_files-objkey  = '01'.
696    *
697    *    CALL FUNCTION 'SO_WIND_ATTACHMENT_LIST_API1'
698    *      EXPORTING
699    *        application_object       = wa_att_files
700    ***   FUNCTION                 = ' '
701    *** TABLES
702    ***   FUNC_EXCLUDE             = .
703    *  .
704    ***  ELSE.
705    ***    MESSAGE i000(Zps).
706    *
707    *  ENDIF .
708
709    *ENDFORM.                    " LIST_DOCS
710    *&---------------------------------------------------------------------*
711    *&      Form  GET_CCDETAILS
712    *&---------------------------------------------------------------------*
713    *       text
714    *----------------------------------------------------------------------*
715    *  -->  p1        text
716    *  <--  p2        text
717    *----------------------------------------------------------------------*
718    FORM get_ccdetails .
719      DATA: wa_ccdetails TYPE zjv_cash_call.
720
721      SELECT * FROM ZJV_CASH_CALL INTO WA_CCDETAILS UP TO 1 ROWS WHERE CCREQNO = ZJVC_CC_FCFORMS-CCREQNO
722     ORDER BY PRIMARY KEY .
723     ENDSELECT. "AND STATUS_PM = 'APPROVED'
724
725      IF sy-subrc EQ 0.
726
727        zjvc_cc_fcforms-gjahr = wa_ccdetails-gjahr .
728        zjvc_cc_fcforms-bukrs = wa_ccdetails-bukrs .
729        zjvc_cc_fcforms-vname = wa_ccdetails-vname .
730        zjvc_cc_fcforms-waers = wa_ccdetails-waers .
731        zjvc_cc_fcforms-due_dt = wa_ccdetails-due_dt .
732
733    *Commented Logic below to not fetch Cas Call details from zjv_cash_call Table...as intimated by FI Core Team
734    ************************************************************************************
735    *Begin ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
736    *    zjvc_cc_fcforms-forgn_fincommitfcy_eqt = wa_ccdetails-wrbtr .
737    *    zjvc_cc_fcforms-forgn_fincommitinr_eqt = wa_ccdetails-dmbtr ."""" COMMENT BY ROHIT ON 03-10-2025
738        zjvc_cc_fcforms-bankchnl_amnt          = wa_ccdetails-wrbtr .
739        zjvc_cc_fcforms-bankchnl_eq            = 'X' .
740        zjvc_cc_fcforms-formc_cashcall_amnt    = wa_ccdetails-wrbtr .
741        zjvc_cc_fcforms-belnr                  = wa_ccdetails-belnr .
742      ENDIF.
743    *End ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
744    ************************************************************************************
745    *    break sap_abap .
746      CLEAR :  wa_ccdetails .
747    *Get Form A & B details from Master Table ZJVC_CC_ASTBLK
748      DATA: wa_ventrdtls TYPE zjvc_cc_astblk .
749
750      SELECT SINGLE * FROM zjvc_cc_astblk INTO wa_ventrdtls WHERE unq_id = zjvc_cc_fcforms-ei_forgnenty_uin .
751
752      IF sy-subrc = 0 .
753        zjvc_cc_fcforms-ei_forgnenty_name = wa_ventrdtls-ei_forgnenty_name .
754        zjvc_cc_fcforms-ei_forgnenty_uin  = wa_ventrdtls-unq_id .
755        zjvc_cc_fcforms-countryname       = wa_ventrdtls-country_name .
756        zjvc_cc_fcforms-forgn_emailid     = wa_ventrdtls-emailid_forgn .
757        zjvc_cc_fcforms-forgn_accntyr     = wa_ventrdtls-accnt_year_forgn .
758        zjvc_cc_fcforms-operator_name     = wa_ventrdtls-operator_name .
759        zjvc_cc_fcforms-ei_forgnenty_addr = wa_ventrdtls-address .
760        zjvc_cc_fcforms-sds_lei           = wa_ventrdtls-legal_ent_idnt_forgn .
761        zjvc_cc_fcforms-fcb_forgn_act_cd_ie_3dig1 = wa_ventrdtls-fcb_forgn_act_cd_ie_3dig1 .
762        zjvc_cc_fcforms-fcb_forgn_act_cd_ie_5dig1 = wa_ventrdtls-fcb_forgn_act_cd_ie_5dig1 .
763        zjvc_cc_fcforms-name_ri_trust = wa_ventrdtls-name_ri_trust .
764        zjvc_cc_fcforms-pan           = wa_ventrdtls-pan .
765        zjvc_cc_fcforms-lei           = wa_ventrdtls-lei .
766        zjvc_cc_fcforms-grp_company   = wa_ventrdtls-grp_company .
767        zjvc_cc_fcforms-addr_ie_trust = wa_ventrdtls-addr_ie_trust .
768        zjvc_cc_fcforms-city_ie_trust = wa_ventrdtls-city_ie_trust .
769        zjvc_cc_fcforms-state_ie_trust = wa_ventrdtls-state_ie_trust .
770        zjvc_cc_fcforms-pincd_ie_trust = wa_ventrdtls-pincd_ie_trust .
771        zjvc_cc_fcforms-fcaact_cd_ie_3dig1 = wa_ventrdtls-fcaact_cd_ie_3dig1 .
772        zjvc_cc_fcforms-fcaact_cd_ie_5dig1 = wa_ventrdtls-fcaact_cd_ie_5dig1 .
773        zjvc_cc_fcforms-forgn_dateincorpn  = wa_ventrdtls-forgn_dateincorpn .
774
775    ***********************************************************************************
776    *Begin ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
777    *fetch from Master Table Personal details, % Stake Net Worth (is of Total UINs of OVL
778    *and it only changes Annually. It can be overwritten as past record is not needed)
779    *      ZJVC_CC_FCFORMS-CONTCT_PER_CPF   = wa_ventrdtls-CONTCT_PER_CPF .
780    *      ZJVC_CC_FCFORMS-CONTCT_PER_NAME  = wa_ventrdtls-CONTCT_PER_NAME .
781    *      ZJVC_CC_FCFORMS-CONTCT_PER_DESG  = wa_ventrdtls-CONTCT_PER_DESG .
782    *      ZJVC_CC_FCFORMS-CONTCT_PER_MOBNO = wa_ventrdtls-CONTCT_PER_MOBNO .
783    *      ZJVC_CC_FCFORMS-CONTCT_PER_TELNO = wa_ventrdtls-CONTCT_PER_TELNO .
784    *      ZJVC_CC_FCFORMS-CONTCT_PER_EMAIL = wa_ventrdtls-CONTCT_PER_EMAIL .
785        zjvc_cc_fcforms-perc_stake       = wa_ventrdtls-perc_stake  .
786        zjvc_cc_fcforms-net_wrth_inr_ie  = wa_ventrdtls-net_wrth_inr_ie .
787        zjvc_cc_fcforms-net_wrth_inr_dt  = wa_ventrdtls-net_wrth_inr_dt .
788    *End ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
789    ***********************************************************************************
790
791        IF ( sy-tcode = g_tcode1 OR g_tcode = 'ZJVCCFC1' ) .
792          zjvc_cc_fcforms-forgn_fincommitfcy_docutot = wa_ventrdtls-forgn_fincommitfcy_opnbal .
793          zjvc_cc_fcforms-forgn_fincommitinr_docutot = wa_ventrdtls-forgn_fincommitinr_opnbal .
794          zjvc_cc_fcforms-forgn_fincommitusd_docutot = wa_ventrdtls-forgn_fincommitfcy_opnbal .
795          zjvc_cc_fcforms-forgn_fincommitfcy_opnbal  = wa_ventrdtls-forgn_fincommitfcy_opnbal .
796          zjvc_cc_fcforms-forgn_fincommitinr_opnbal  = wa_ventrdtls-forgn_fincommitinr_opnbal .
797    ***********************************************************************************
798    *Begin ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
799          zjvc_cc_fcforms-forgn_fincommitgbp_docutot = wa_ventrdtls-forgn_fincommitfcy_opnbal_gbp .
800          zjvc_cc_fcforms-forgn_fincommiteur_docutot = wa_ventrdtls-forgn_fincommitfcy_opnbal_eur .
801          zjvc_cc_fcforms-forgn_fincommiteur_opnbal  = wa_ventrdtls-forgn_fincommitfcy_opnbal_eur .
802          zjvc_cc_fcforms-forgn_fincommitgbp_opnbal  = wa_ventrdtls-forgn_fincommitfcy_opnbal_gbp .
803    *End ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
804    ***********************************************************************************
805
806        ENDIF.
807    ****************************************************************************************************************************************
808      ENDIF."    IF sy-subrc = 0 .
809
810    ENDFORM.                    " LIST_DOCS
811    *&---------------------------------------------------------------------*
812    *&      Form  GET_TOTALS_FCFORMB
813    *&---------------------------------------------------------------------*
814    *       text
815    *----------------------------------------------------------------------*
816    *  -->  p1        text
817    *  <--  p2        text
818    *----------------------------------------------------------------------*
819    FORM get_totals_fcformb .
820    *  DATA: l_subtotal_RBIPP TYPE ZJVC_CC_FCFORMS-FORGN_FCY_SUM_RBIPP_RPTD.
821    *  DATA: l_subtotal_RBUPD TYPE ZJVC_CC_FCFORMS-FORGN_FCY_SUM_RBIUPD_RPTD.
822    *  DATA: l_grandtotalRBIFCY TYPE ZJVC_CC_FCFORMS-ZJVC_CC_FCFORMS-FORGN_SUM_FC_FORGN_CURR.
823
824    *Subtotal Reported in RBI Project Profile.
825      zjvc_cc_fcforms-forgn_fcy_sum_rbipp_rptd = ( zjvc_cc_fcforms-forgn_fcy_rptd_rbipp_eq + zjvc_cc_fcforms-forgn_fcy_rptd_rbipp_ln
826                                                 + zjvc_cc_fcforms-forgn_fcy_rptd_rbipp_nfcmmt ).
827
828    *Subtotal Updation required in RBI Profile .
829
830      zjvc_cc_fcforms-forgn_fcy_sum_rbiupd_rptd = ( zjvc_cc_fcforms-forgn_fcy_rptd_rbiupd_eq + zjvc_cc_fcforms-forgn_fcy_rptd_rbiupd_ln
831                                                  + zjvc_cc_fcforms-forgn_fcy_rptd_rbiupd_nfcmmt ).
832
833    *Grand total of the Financial Commitment (FC) in FCY .
834
835      zjvc_cc_fcforms-forgn_sum_fc_forgn_curr = ( zjvc_cc_fcforms-forgn_fcy_sum_rbipp_rptd + zjvc_cc_fcforms-forgn_fcy_sum_rbiupd_rptd ) .
836
837    *CLEAR :  wa_ccdetails .
838
839    *************************************************
840    *Get Currency name from check table ZJVCCFC_CURR.
841      DATA: wa_zjvccfc_curr TYPE zjvccfc_curr.
842    *  DATA: l_curr TYPE ZJVCCFC_CURR-CURR_KEY .
843      " ADD BY ROHIT 01-10-2025
844      SELECT * FROM BKPF INTO @DATA(WA_BKPF) UP TO 1 ROWS WHERE BUKRS = @ZJVC_CC_FCFORMS-BUKRS AND XBLNR EQ @ZJVC_CC_FCFORMS-CCREQNO
845     ORDER BY PRIMARY KEY .
846     ENDSELECT.
847      IF sy-subrc EQ 0.
848
849        zjvc_cc_fcforms-curr_key = wa_bkpf-waers.
850
851      ENDIF.
852
853      IF zjvc_cc_fcforms-curr_key IS  INITIAL.
854        SELECT * FROM BKPF INTO @DATA(WA_BKPF1) UP TO 1 ROWS WHERE BUKRS = 'OVL' AND BELNR EQ @ZJVC_CC_FCFORMS-BELNR
855     ORDER BY PRIMARY KEY .
856     ENDSELECT.
857        IF sy-subrc EQ 0.
858
859          zjvc_cc_fcforms-curr_key = wa_bkpf1-waers.
860
861
862        ENDIF.
863      ENDIF.
864
865      IF NOT zjvc_cc_fcforms-curr_key IS INITIAL.
866        SELECT SINGLE * FROM zjvccfc_curr INTO wa_zjvccfc_curr WHERE curr_key = zjvc_cc_fcforms-curr_key .
867        IF sy-subrc = 0 .
868          zjvc_cc_fcforms-curr_name = wa_zjvccfc_curr-curr_name .
869          g_curr  = wa_zjvccfc_curr-curr_key .
870          g_curr1 = wa_zjvccfc_curr-curr_key .
871          g_curr2 = wa_zjvccfc_curr-curr_key .
872          g_curr3 = wa_zjvccfc_curr-curr_key .
873          g_curr4 = wa_zjvccfc_curr-curr_key .
874        ENDIF.
875      ENDIF.
876      CLEAR: wa_zjvccfc_curr .
877    *************************************************
878    *Get Currency Name on Screen Label as per Currency value.
879    *IF NOT ZJVC_CC_FCFORMS-CURR_KEY IS INITIAL.
880    *      SELECT SINGLE * FROM ZJVCCFC_CURR INTO wa_ZJVCCFC_CURR WHERE CURR_KEY = ZJVC_CC_FCFORMS-CURR_KEY .
881    *    IF sy-subrc = 0 .
882    *      ZJVC_CC_FCFORMS-CURR_NAME = wa_ZJVCCFC_CURR-CURR_NAME .
883    *    ENDIF.
884    *ENDIF.
885    *CLEAR: wa_ZJVCCFC_CURR .
886
887    ENDFORM.                    " LIST_DOCS
888    *&---------------------------------------------------------------------*
889    *&      Form  INSERT_DPR_ROW
890    *&---------------------------------------------------------------------*
891    *       text
892    *----------------------------------------------------------------------*
893    *  -->  p1        text
894    *  <--  p2        text
895    *----------------------------------------------------------------------*
896    FORM insert_dpr_row .
897    * Insert DPR row
898      DATA : l_cnt1 TYPE i.
899
900      DESCRIBE TABLE ist_pidetails LINES l_cnt1.
901      l_cnt1 = l_cnt1 + 1.
902      INSERT INITIAL LINE INTO ist_pidetails INDEX l_cnt1.
903      tc_0130-lines = l_cnt1.
904      SET CURSOR LINE l_cnt1.
905    ENDFORM.
906    *&---------------------------------------------------------------------*
907    *&      Form  DELETE_DPR_ROW
908    *&---------------------------------------------------------------------*
909    *       text
910    *----------------------------------------------------------------------*
911    *  -->  p1        text
912    *  <--  p2        text
913    *----------------------------------------------------------------------*
914    FORM delete_dpr_row .
915
916      DATA: n TYPE sy-tabix .
917
918    * Delete DPR row
919
920      DESCRIBE TABLE ist_pidetails LINES n .
921
922      tc_0130-lines = n .
923
924      READ TABLE ist_pidetails WITH KEY sel = 'X'.
925
926      IF sy-subrc EQ 0.
927        tc_0130-lines = tc_0130-lines - 1.
928        DELETE ist_pidetails INDEX sy-tabix.
929      ENDIF.
930    *  tc_0100-lines =  1.
931
932      CLEAR: ist_pidetails, n .
933    ENDFORM.
934    *&---------------------------------------------------------------------*
935    *&      Form  DELETE_RECORD
936    *&---------------------------------------------------------------------*
937    *       text
938    *----------------------------------------------------------------------*
939    *  -->  p1        text
940    *  <--  p2        text
941    *----------------------------------------------------------------------*
942    FORM delete_record .
943    * Delete record from ZJVC_CC_FCFORMSB Table
944      SELECT * FROM zjvc_cc_fcformsb
945               WHERE doc_no  = zjvc_cc_fcforms-doc_no.
946
947        IF sy-subrc EQ 0.
948          DELETE zjvc_cc_fcformsb.
949        ENDIF.
950      ENDSELECT.
951    **************************************************************
952
953
954    ENDFORM.
955    *&---------------------------------------------------------------------*
956    *&      Form  GET_PREV_CCCDATA
957    *&---------------------------------------------------------------------*
958    *       text
959    *----------------------------------------------------------------------*
960    *  -->  p1        text
961    *  <--  p2        text
962    *----------------------------------------------------------------------*
963    FORM get_prev_cccdata .
964    **In Create Mode Fetch Previous Cash Call Data in New Cash Call Creation Screens
965    **break sap_abap .
966    *DATA  : wa_prvccdtls   TYPE ZJVC_CC_FCFORMS.
967    **DATA  : wa_prvccdtlspi TYPE ZJVC_CC_FCFORMSB.
968    **DATA  :l_CCREQNO      TYPE ZJVC_CC_FCFORMS-CCREQNO.
969    *DATA  :l_PRVCCREQNO   TYPE ZJVC_CC_FCFORMS-CCREQNO.
970    *CLEAR :l_PRVCCREQNO, wa_prvccdtls.
971    *
972    *
973    **break sap_abap .
974    *  SELECT SINGLE * FROM ZJVC_CC_FCFORMS  WHERE CCREQNO = ZJVC_CC_FCFORMS-CCREQNO." l_PRVCCREQNO .INTO wa_prvccdtls
975    *  IF sy-subrc EQ 0.
976    *    MESSAGE 'Document for this Cash Call already exists' type 'E'.
977    **  ELSE.
978    **  move-corresponding ZJVC_CC_FCFORMS to ZJVC_CC_FCFORMS.
979    ***    MOVE-CORRESPONDING wa_prvccdtls TO ZJVC_CC_FCFORMS .
980    **  CLEAR : ZJVC_CC_FCFORMS-CCREQNO .
981    *  ENDIF.
982
983    ENDFORM.
984    *&---------------------------------------------------------------------*
985    *&      Form  GET_SUBSIDIARYNAME
986    *&---------------------------------------------------------------------*
987    *       text
988    *----------------------------------------------------------------------*
989    *  -->  p1        text
990    *  <--  p2        text
991    *----------------------------------------------------------------------*
992    FORM get_subsidiaryname .
993      DATA: wa_t880dtls TYPE  t880.
994
995      SELECT SINGLE * FROM t880 INTO wa_t880dtls WHERE rcomp = zjvc_cc_fcforms-subdry_rcomp .
996      IF sy-subrc EQ 0.
997        zjvc_cc_fcforms-subdry_rcompname = wa_t880dtls-name1 .
998      ENDIF.
999      CLEAR : wa_t880dtls .
1000
1001   ENDFORM.
1002   *&---------------------------------------------------------------------*
1003   *&      Form  GET_PRVS_CCPRNT_DATA
1004   *&---------------------------------------------------------------------*
1005   *       text
1006   *----------------------------------------------------------------------*
1007   *  -->  p1        text
1008   *  <--  p2        text
1009   *----------------------------------------------------------------------*
1010   FORM get_prvs_ccprnt_data .
1011     DATA : wa_prvs_ccprnt_data TYPE zjvc_cc_fcforms.
1012     DATA : ist_prvs_ccprnt_data LIKE zjvc_cc_fcforms OCCURS 0 WITH HEADER LINE.
1013     DATA : wa_prvs_ccprnt_data_pitbl TYPE zjvc_cc_fcformsb.
1014     DATA : ist_prvs_ccprnt_data_pitbl LIKE zjvc_cc_fcformsb OCCURS 0 WITH HEADER LINE.
1015   *break sap_abap .
1016     IF zjvc_cc_fcforms-ccprntreq = 'X' .
1017       SELECT * APPENDING CORRESPONDING FIELDS OF TABLE ist_prvs_ccprnt_data
1018       FROM  zjvc_cc_fcforms
1019       WHERE vname     = zjvc_cc_fcforms-vname
1020       AND ccreqno   NE ' ' .
1021       IF NOT ist_prvs_ccprnt_data[] IS INITIAL .
1022         SORT ist_prvs_ccprnt_data DESCENDING BY ccreqno .
1023         READ TABLE ist_prvs_ccprnt_data INTO wa_prvs_ccprnt_data INDEX 1.
1024         CLEAR: zjvc_cc_fcforms.
1025         MOVE-CORRESPONDING wa_prvs_ccprnt_data TO zjvc_cc_fcforms .
1026       ENDIF.
1027       CLEAR: zjvc_cc_fcforms-doc_no .
1028     ELSEIF zjvc_cc_fcforms-jvprntreq = 'X' .
1029
1030
1031     ELSEIF zjvc_cc_fcforms-subsdryreq = 'X' .
1032
1033
1034     ELSE.
1035     ENDIF.
1036
1037   ENDFORM.
1038   *&---------------------------------------------------------------------*
1039   *&      Form  UINTOTS
1040   *&---------------------------------------------------------------------*
1041   *       text
1042   *----------------------------------------------------------------------*
1043   *  -->  p1        text
1044   *  <--  p2        text
1045   *----------------------------------------------------------------------*
1046   FORM uintots .
1047   *ZJVC_CC_FCFORMS to ZJVCCFC_TOT.
1048   *DATA :ist_uindetails like ZJVC_CC_FCFORMS occurs 0 with header line.
1049   *
1050   **Get Line Item Data
1051   *IF NOT ZJVC_CC_FCFORMS-EI_FORGNENTY_UIN IS INITIAL .
1052   *SELECT * APPENDING CORRESPONDING FIELDS OF TABLE ist_uindetails
1053   *                  FROM  ZJVC_CC_FCFORMS
1054   *                  WHERE EI_FORGNENTY_UIN = ZJVC_CC_FCFORMS-EI_FORGNENTY_UIN.
1055   *   IF SY-SUBRC EQ '0' .
1056   *     IF
1057   *     LOOP AT ist_uindetails .
1058   *
1059   *   ENDIF."sy-subrc EQ 0.
1060   *ENDIF.
1061   ENDFORM.
1062   *&---------------------------------------------------------------------*
1063   *&      Form  TOTALS
1064   *&---------------------------------------------------------------------*
1065   *       text
1066   *----------------------------------------------------------------------*
1067   *  -->  p1        text
1068   *  <--  p2        text
1069   *----------------------------------------------------------------------*
1070   FORM totals .
1071   *ZJVC_CC_FCFORMS to ZJVCCFC_TOT.
1072   *DATA :ist_uindetails like ZJVCCFC_TOT occurs 0 with header line.
1073
1074   *DATA :ist_ovldetails like ZJVCCFC_TOT occurs 0 with header line.
1075
1076   *DATA:l_FORGN_FINCOMMITFCY_UINTOT TYPE ZJVCCFC_TOT-FORGN_FINCOMMITFCY_UINTOT,
1077   *     l_FORGN_FINCOMMITFCY_OVLTOT TYPE ZJVCCFC_TOT-FORGN_FINCOMMITFCY_OVLTOT,
1078   *     l_FORGN_FINCOMMITINR_UINTOT TYPE ZJVCCFC_TOT-FORGN_FINCOMMITINR_UINTOT,
1079   *     l_FORGN_FINCOMMITINR_OVLTOT TYPE ZJVCCFC_TOT-FORGN_FINCOMMITINR_OVLTOT,
1080   *     l_FORGN_FINCOMMITUSD_UINTOT TYPE ZJVCCFC_TOT-FORGN_FINCOMMITINR_UINTOT,
1081   *     l_FORGN_FINCOMMITUSD_OVLTOT TYPE ZJVCCFC_TOT-FORGN_FINCOMMITINR_OVLTOT .
1082
1083   *break sap_abap .
1084   *Get Line Item Data
1085   *IF NOT ZJVC_CC_FCFORMS-EI_FORGNENTY_UIN IS INITIAL .
1086   *Get All records from table ZJVC_CC_FCFORMS in the internal table ist_ovldetails
1087   *Update OVL level Totals for each document having totals of current and previous documents.
1088   *CLEAR: ZJVCCFC_TOT-FORGN_FINCOMMITFCY_OVLTOT, ZJVCCFC_TOT-FORGN_FINCOMMITINR_OVLTOT,ZJVCCFC_TOT-FORGN_FINCOMMITUSD_OVLTOT .
1089   *SELECT * APPENDING CORRESPONDING FIELDS OF TABLE ist_ovldetails
1090   *                  FROM  ZJVCCFC_TOT .
1091   ***                  WHERE EI_FORGNENTY_UIN = ZJVC_CC_FCFORMS-EI_FORGNENTY_UIN.
1092   *   IF SY-SUBRC EQ '0' .
1093   ***     IF ist_ovldetails[] NE '0' .
1094   *     LOOP AT ist_ovldetails .
1095   *       IF ist_ovldetails-doc_no LE ZJVC_CC_FCFORMS-DOC_NO .
1096   *         ZJVCCFC_TOT-FORGN_FINCOMMITFCY_OVLTOT = ist_ovldetails-FORGN_FINCOMMITFCY_DOCUTOT + ZJVCCFC_TOT-FORGN_FINCOMMITFCY_OVLTOT .
1097   *         ZJVCCFC_TOT-FORGN_FINCOMMITINR_OVLTOT = ist_ovldetails-FORGN_FINCOMMITINR_DOCUTOT + ZJVCCFC_TOT-FORGN_FINCOMMITINR_OVLTOT .
1098   *         ZJVCCFC_TOT-FORGN_FINCOMMITUSD_OVLTOT = ist_ovldetails-FORGN_FINCOMMITUSD_DOCUTOT + ZJVCCFC_TOT-FORGN_FINCOMMITUSD_OVLTOT .
1099   *       ENDIF.
1100   *     ENDLOOP .
1101   ***     ENDIF.
1102   *   ENDIF."sy-subrc EQ 0.
1103   **Update UIN Wise Totals for each document having totals of current and previous documents for a UIN.
1104   **break sap_abap .
1105   **SELECT SUM( FORGN_FINCOMMITFCY_DOCUTOT ) FROM ZJVCCFC_TOT INTO @ZJVCCFC_TOT-FORGN_FINCOMMITFCY_OVLTOT WHERE EI_FORGNENTY_UIN = ' NDPRN20010131' .
1106   **CLEAR: ZJVCCFC_TOT-FORGN_FINCOMMITFCY_UINTOT, ZJVCCFC_TOT-FORGN_FINCOMMITINR_UINTOT,ZJVCCFC_TOT-FORGN_FINCOMMITUSD_UINTOT .
1107   *   ist_uindetails[] = ist_ovldetails[] .
1108   *   DELETE ist_uindetails WHERE EI_FORGNENTY_UIN <> ZJVC_CC_FCFORMS-EI_FORGNENTY_UIN .
1109   *     LOOP AT ist_uindetails .
1110   *       IF ist_uindetails-doc_no LE ZJVC_CC_FCFORMS-DOC_NO .
1111   *         ZJVCCFC_TOT-FORGN_FINCOMMITFCY_UINTOT = ist_uindetails-FORGN_FINCOMMITFCY_DOCUTOT + ZJVCCFC_TOT-FORGN_FINCOMMITFCY_UINTOT .
1112   *         ZJVCCFC_TOT-FORGN_FINCOMMITINR_UINTOT = ist_uindetails-FORGN_FINCOMMITINR_DOCUTOT + ZJVCCFC_TOT-FORGN_FINCOMMITINR_UINTOT .
1113   *         ZJVCCFC_TOT-FORGN_FINCOMMITUSD_UINTOT = ist_uindetails-FORGN_FINCOMMITUSD_DOCUTOT + ZJVCCFC_TOT-FORGN_FINCOMMITUSD_UINTOT .
1114   *       ENDIF.
1115   *     ENDLOOP .
1116   *CLEAR : ist_ovldetails, ist_uindetails .
1117   ENDFORM.
1118   *&---------------------------------------------------------------------*
1119   *&      Form  ALLTOTALS
1120   *&---------------------------------------------------------------------*
1121   *       text
1122   *----------------------------------------------------------------------*
1123   *  -->  p1        text
1124   *  <--  p2        text
1125   *----------------------------------------------------------------------*
1126   FORM alltotals .
1127   *ZJVC_CC_FCFORMS to ZJVCCFC_TOT.
1128   *DATA :ist_uindetails like ZJVC_CC_FCFORMS occurs 0 with header line.
1129   *DATA :ist_ovldetails like ZJVC_CC_FCFORMS occurs 0 with header line.
1130   *DATA: wa_ventrdtlsopnbal TYPE ZJVC_CC_ASTBLK ."For gettting opening balances for a UIN first time
1131   *DATA:l_FORGN_FINCOMMITFCY_UINTOT TYPE ZJVC_CC_FCFORMS-FORGN_FINCOMMITFCY_UINTOT,
1132   *     l_FORGN_FINCOMMITFCY_OVLTOT TYPE ZJVC_CC_FCFORMS-FORGN_FINCOMMITFCY_OVLTOT,
1133   *     l_FORGN_FINCOMMITINR_UINTOT TYPE ZJVC_CC_FCFORMS-FORGN_FINCOMMITINR_UINTOT,
1134   *     l_FORGN_FINCOMMITINR_OVLTOT TYPE ZJVC_CC_FCFORMS-FORGN_FINCOMMITINR_OVLTOT,
1135   *     l_FORGN_FINCOMMITUSD_UINTOT TYPE ZJVC_CC_FCFORMS-FORGN_FINCOMMITUSD_UINTOT,
1136   *     l_FORGN_FINCOMMITUSD_OVLTOT TYPE ZJVC_CC_FCFORMS-FORGN_FINCOMMITUSD_OVLTOT .
1137   *
1138   **break sap_abap .
1139   **Get Line Item Data
1140   **IF NOT ZJVC_CC_FCFORMS-EI_FORGNENTY_UIN IS INITIAL .
1141   **Get All records from table ZJVC_CC_FCFORMS in the internal table ist_ovldetails
1142   **Update OVL level Totals for each document having totals of current and previous documents.
1143   **CLEAR: ZJVCCFC_TOT-FORGN_FINCOMMITFCY_OVLTOT, ZJVCCFC_TOT-FORGN_FINCOMMITINR_OVLTOT,ZJVCCFC_TOT-FORGN_FINCOMMITUSD_OVLTOT .
1144   *
1145   *
1146   *     g_FORGN_FINCOMMITFCY_UINTOT = 0 .
1147   *     g_FORGN_FINCOMMITFCY_OVLTOT = 0 .
1148   *     g_FORGN_FINCOMMITINR_UINTOT = 0 .
1149   *     g_FORGN_FINCOMMITINR_OVLTOT = 0 .
1150   *     g_FORGN_FINCOMMITUSD_UINTOT = 0 .
1151   *     g_FORGN_FINCOMMITUSD_OVLTOT = 0 .
1152   *
1153   **CLEAR : ist_ovldetails, ist_uindetails, ZJVC_CC_FCFORMS-FORGN_FINCOMMITFCY_UINTOT, ZJVC_CC_FCFORMS-FORGN_FINCOMMITINR_UINTOT, ZJVC_CC_FCFORMS-FORGN_FINCOMMITUSD_UINTOT,
1154   **        ZJVC_CC_FCFORMS-FORGN_FINCOMMITFCY_OVLTOT, ZJVC_CC_FCFORMS-FORGN_FINCOMMITINR_OVLTOT, ZJVC_CC_FCFORMS-FORGN_FINCOMMITUSD_OVLTOT ,wa_ventrdtlsopnbal .
1155   *
1156   **IF SY-TCODE = G_TCODE1 OR G_TCODE = 'ZJVCCFC1'.
1157   *
1158   *     l_FORGN_FINCOMMITFCY_UINTOT = ZJVC_CC_FCFORMS-FORGN_FINCOMMITFCY_UINTOT .
1159   *     l_FORGN_FINCOMMITFCY_OVLTOT = ZJVC_CC_FCFORMS-FORGN_FINCOMMITFCY_OVLTOT .
1160   *     l_FORGN_FINCOMMITINR_UINTOT = ZJVC_CC_FCFORMS-FORGN_FINCOMMITINR_UINTOT .
1161   *     l_FORGN_FINCOMMITINR_OVLTOT = ZJVC_CC_FCFORMS-FORGN_FINCOMMITINR_OVLTOT .
1162   *     l_FORGN_FINCOMMITUSD_UINTOT = ZJVC_CC_FCFORMS-FORGN_FINCOMMITUSD_UINTOT .
1163   *     l_FORGN_FINCOMMITUSD_OVLTOT = ZJVC_CC_FCFORMS-FORGN_FINCOMMITUSD_OVLTOT .
1164   *
1165   *  SELECT * APPENDING CORRESPONDING FIELDS OF TABLE ist_ovldetails
1166   *  FROM  ZJVC_CC_FCFORMS .
1167   *
1168   *  IF SY-SUBRC EQ '0' .
1169   *****************************************************************************************************************************************
1170   ***     IF ist_ovldetails[] NE '0' .
1171   *      LOOP AT ist_ovldetails .
1172   *       IF ist_ovldetails-doc_no LE ZJVC_CC_FCFORMS-DOC_NO .
1173   *        ZJVC_CC_FCFORMS-FORGN_FINCOMMITFCY_OVLTOT = ist_ovldetails-FORGN_FINCOMMITFCY_DOCUTOT + ZJVC_CC_FCFORMS-FORGN_FINCOMMITFCY_OVLTOT .
1174   *        ZJVC_CC_FCFORMS-FORGN_FINCOMMITINR_OVLTOT = ist_ovldetails-FORGN_FINCOMMITINR_DOCUTOT + ZJVC_CC_FCFORMS-FORGN_FINCOMMITINR_OVLTOT .
1175   *        ZJVC_CC_FCFORMS-FORGN_FINCOMMITUSD_OVLTOT = ist_ovldetails-FORGN_FINCOMMITUSD_DOCUTOT + ZJVC_CC_FCFORMS-FORGN_FINCOMMITUSD_OVLTOT .
1176   *
1177   *       ENDIF.
1178   *      ENDLOOP .
1179   ***     ENDIF.
1180   *    ENDIF."sy-subrc EQ 0.
1181   **Update UIN Wise Totals for each document having totals of current and previous documents for a UIN.
1182   **break sap_abap .
1183   **SELECT SUM( FORGN_FINCOMMITFCY_DOCUTOT ) FROM ZJVCCFC_TOT INTO @ZJVCCFC_TOT-FORGN_FINCOMMITFCY_OVLTOT WHERE EI_FORGNENTY_UIN = ' NDPRN20010131' .
1184   **CLEAR: ZJVCCFC_TOT-FORGN_FINCOMMITFCY_UINTOT, ZJVCCFC_TOT-FORGN_FINCOMMITINR_UINTOT,ZJVCCFC_TOT-FORGN_FINCOMMITUSD_UINTOT .
1185   *    ist_uindetails[] = ist_ovldetails[] .
1186   *    DELETE ist_uindetails WHERE EI_FORGNENTY_UIN <> ZJVC_CC_FCFORMS-EI_FORGNENTY_UIN .
1187   *    LOOP AT ist_uindetails .
1188   **       IF ist_uindetails-doc_no LE ZJVC_CC_FCFORMS-DOC_NO .
1189   *      ZJVC_CC_FCFORMS-FORGN_FINCOMMITFCY_UINTOT = ist_uindetails-FORGN_FINCOMMITFCY_DOCUTOT + ZJVC_CC_FCFORMS-FORGN_FINCOMMITFCY_UINTOT .
1190   *      ZJVC_CC_FCFORMS-FORGN_FINCOMMITINR_UINTOT = ist_uindetails-FORGN_FINCOMMITINR_DOCUTOT + ZJVC_CC_FCFORMS-FORGN_FINCOMMITINR_UINTOT .
1191   *      ZJVC_CC_FCFORMS-FORGN_FINCOMMITUSD_UINTOT = ist_uindetails-FORGN_FINCOMMITUSD_DOCUTOT + ZJVC_CC_FCFORMS-FORGN_FINCOMMITUSD_UINTOT .
1192   **       ENDIF.
1193   *    ENDLOOP .
1194   **  ENDIF." IF SY-SUBRC EQ '0' .
1195   **CLEAR : ist_ovldetails, ist_uindetails, ZJVC_CC_FCFORMS-FORGN_FINCOMMITFCY_UINTOT, ZJVC_CC_FCFORMS-FORGN_FINCOMMITINR_UINTOT, ZJVC_CC_FCFORMS-FORGN_FINCOMMITUSD_UINTOT,
1196   **        ZJVC_CC_FCFORMS-FORGN_FINCOMMITFCY_OVLTOT, ZJVC_CC_FCFORMS-FORGN_FINCOMMITINR_OVLTOT, ZJVC_CC_FCFORMS-FORGN_FINCOMMITUSD_OVLTOT .
1197   *
1198   **     g_FORGN_FINCOMMITFCY_UINTOT = ZJVC_CC_FCFORMS-FORGN_FINCOMMITFCY_UINTOT .
1199   **     g_FORGN_FINCOMMITFCY_OVLTOT = ZJVC_CC_FCFORMS-FORGN_FINCOMMITFCY_OVLTOT .
1200   **     g_FORGN_FINCOMMITINR_UINTOT = ZJVC_CC_FCFORMS-FORGN_FINCOMMITINR_UINTOT .
1201   **     g_FORGN_FINCOMMITINR_OVLTOT = ZJVC_CC_FCFORMS-FORGN_FINCOMMITINR_OVLTOT .
1202   **     g_FORGN_FINCOMMITUSD_UINTOT = ZJVC_CC_FCFORMS-FORGN_FINCOMMITUSD_UINTOT .
1203   **     g_FORGN_FINCOMMITUSD_OVLTOT = ZJVC_CC_FCFORMS-FORGN_FINCOMMITUSD_OVLTOT .
1204   *
1205   *     g_FORGN_FINCOMMITFCY_UINTOT = l_FORGN_FINCOMMITFCY_UINTOT + ZJVC_CC_FCFORMS-FORGN_FINCOMMITFCY_UINTOT .
1206   *     g_FORGN_FINCOMMITFCY_OVLTOT = l_FORGN_FINCOMMITFCY_OVLTOT + ZJVC_CC_FCFORMS-FORGN_FINCOMMITFCY_OVLTOT .
1207   *     g_FORGN_FINCOMMITINR_UINTOT = l_FORGN_FINCOMMITINR_UINTOT + ZJVC_CC_FCFORMS-FORGN_FINCOMMITINR_UINTOT .
1208   *     g_FORGN_FINCOMMITINR_OVLTOT = l_FORGN_FINCOMMITINR_OVLTOT + ZJVC_CC_FCFORMS-FORGN_FINCOMMITINR_OVLTOT .
1209   *     g_FORGN_FINCOMMITUSD_UINTOT = l_FORGN_FINCOMMITUSD_UINTOT + ZJVC_CC_FCFORMS-FORGN_FINCOMMITUSD_UINTOT .
1210   *     g_FORGN_FINCOMMITUSD_OVLTOT = l_FORGN_FINCOMMITUSD_OVLTOT + ZJVC_CC_FCFORMS-FORGN_FINCOMMITUSD_OVLTOT .
1211
1212
1213   ENDFORM.
1214   *&---------------------------------------------------------------------*
1215   *&      Form  GET_TOTALS
1216   *&---------------------------------------------------------------------*
1217   *       text
1218   *----------------------------------------------------------------------*
1219   *  -->  p1        text
1220   *  <--  p2        text
1221   *----------------------------------------------------------------------*
1222   FORM get_totals .
1223
1224     DATA:l_forgn_fincommitfcy_uintot    TYPE zjvc_cc_fcforms-forgn_fincommitfcy_uintot,
1225          l_forgn_fincommitfcy_ovltot    TYPE zjvc_cc_fcforms-forgn_fincommitfcy_ovltot,
1226          l_forgn_fincommitinr_uintot    TYPE zjvc_cc_fcforms-forgn_fincommitinr_uintot,
1227          l_forgn_fincommitinr_ovltot    TYPE zjvc_cc_fcforms-forgn_fincommitinr_ovltot,
1228          l_forgn_fincommitusd_uintot    TYPE zjvc_cc_fcforms-forgn_fincommitusd_uintot,
1229          l_forgn_fincommitusd_ovltot    TYPE zjvc_cc_fcforms-forgn_fincommitusd_ovltot,
1230   ***********************************************************************************
1231   *Begin ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
1232          l_forgn_fincommitgbp_uintot    TYPE zjvc_cc_fcforms-forgn_fincommitgbp_uintot,
1233          l_forgn_fincommitgbp_ovltot    TYPE zjvc_cc_fcforms-forgn_fincommitgbp_ovltot,
1234          l_forgn_fincommiteur_uintot    TYPE zjvc_cc_fcforms-forgn_fincommiteur_uintot,
1235          l_forgn_fincommiteur_ovltot    TYPE zjvc_cc_fcforms-forgn_fincommiteur_ovltot,
1236   *End ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
1237   ***********************************************************************************
1238          l_forgn_fincommitinr_ovltot_op TYPE zjvc_cc_astblk-forgn_fincommitfcy_opnbal,
1239          l_forgn_fincommitusd_ovltot_op TYPE zjvc_cc_astblk-forgn_fincommitinr_opnbal,
1240   ***********************************************************************************
1241   *Begin ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
1242          l_forgn_fincommitgbp_ovltot_op TYPE zjvc_cc_astblk-forgn_fincommitfcy_opnbal_gbp,
1243          l_forgn_fincommiteur_ovltot_op TYPE zjvc_cc_astblk-forgn_fincommitfcy_opnbal_eur,
1244   *End ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
1245   ***********************************************************************************
1246          l_resddoctot_ovlusd            TYPE zjvc_cc_fcforms-forgn_fincommitfcy_ovltot,
1247          l_resddoctot_ovlinr            TYPE zjvc_cc_fcforms-forgn_fincommitinr_uintot,
1248
1249          l_resddoctot_uinusd            TYPE zjvc_cc_fcforms-forgn_fincommitfcy_ovltot,
1250          l_resddoctot_uininr            TYPE zjvc_cc_fcforms-forgn_fincommitinr_uintot,
1251
1252   ***********************************************************************************
1253   *Begin ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
1254          l_resddoctot_ovlgbp            TYPE zjvc_cc_fcforms-forgn_fincommitgbp_ovltot,
1255          l_resddoctot_ovleur            TYPE zjvc_cc_fcforms-forgn_fincommiteur_uintot,
1256
1257          l_resddoctot_uingbp            TYPE zjvc_cc_fcforms-forgn_fincommitgbp_ovltot,
1258          l_resddoctot_uineur            TYPE zjvc_cc_fcforms-forgn_fincommiteur_uintot.
1259   *End ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
1260   ***********************************************************************************
1261
1262
1263   *DATA: wa_ZJVC_CC_FCFORMS_prv TYPE ZJVC_CC_FCFORMS .
1264
1265     DATA: wa_ovldetails TYPE zjvc_cc_fcforms .
1266     DATA: wa_uindetails TYPE zjvc_cc_fcforms .
1267     DATA: wa_mastopnbal1 TYPE zjvc_cc_astblk .
1268
1269   *MOVE ZJVC_CC_FCFORMS TO wa_ZJVC_CC_FCFORMS_prv .
1270
1271     CLEAR: zjvc_cc_fcforms-forgn_fincommitinr_docutot .
1272     CLEAR: zjvc_cc_fcforms-forgn_fincommitusd_docutot .
1273   ***********************************************************************************
1274   *Begin ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
1275     CLEAR: zjvc_cc_fcforms-forgn_fincommitgbp_docutot .
1276     CLEAR: zjvc_cc_fcforms-forgn_fincommiteur_docutot .
1277   *End ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
1278   ***********************************************************************************
1279   ************************************************************************************************************************************
1280   *Add Performance Gurantee and Corporate Gurantee into field Non-Fund Based Committment in Table ZJVC_CC_FCFORMS
1281     zjvc_cc_fcforms-forgn_fincommitfcy_nonfnd = zjvc_cc_fcforms-forgn_fincommitfcy_pfgrnt + zjvc_cc_fcforms-forgn_fincommitfcy_corgrnt .
1282     zjvc_cc_fcforms-forgn_fincommitinr_nonfnd = zjvc_cc_fcforms-forgn_fincommitinr_pfgrnt + zjvc_cc_fcforms-forgn_fincommitinr_corgrnt .
1283     zjvc_cc_fcforms-forgn_fincommitusd_nonfnd = zjvc_cc_fcforms-forgn_fincommitusd_pfgrnt + zjvc_cc_fcforms-forgn_fincommitusd_corgrnt .
1284   ***********************************************************************************
1285   *Begin ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
1286     zjvc_cc_fcforms-forgn_fincommitgbp_nonfnd = zjvc_cc_fcforms-forgn_fincommitgbp_pfgrnt + zjvc_cc_fcforms-forgn_fincommitgbp_corgrnt .
1287     zjvc_cc_fcforms-forgn_fincommiteur_nonfnd = zjvc_cc_fcforms-forgn_fincommiteur_pfgrnt + zjvc_cc_fcforms-forgn_fincommiteur_corgrnt .
1288   *End ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
1289   ***********************************************************************************
1290   *************************************************************************************************************************************
1291   *Fill Document Values in Table ZJVC_CC_FCFORMS
1292   *******************************************************************************************
1293     IF NOT zjvc_cc_fcforms-forgn_fincommitfcy_pfgrnt IS INITIAL .
1294       zjvc_cc_fcforms-forgn_fincommitfcy_pfgrnt50 = zjvc_cc_fcforms-forgn_fincommitfcy_pfgrnt / 2 .
1295     ELSE.
1296       CLEAR: zjvc_cc_fcforms-forgn_fincommitfcy_pfgrnt50 .
1297     ENDIF.
1298     IF NOT zjvc_cc_fcforms-forgn_fincommitinr_pfgrnt IS INITIAL .
1299       zjvc_cc_fcforms-forgn_fincommitinr_pfgrnt50 = zjvc_cc_fcforms-forgn_fincommitinr_pfgrnt / 2.
1300     ELSE.
1301       CLEAR: zjvc_cc_fcforms-forgn_fincommitinr_pfgrnt50 .
1302     ENDIF.
1303     IF NOT zjvc_cc_fcforms-forgn_fincommitusd_pfgrnt IS INITIAL .
1304       zjvc_cc_fcforms-forgn_fincommitusd_pfgrnt50 = zjvc_cc_fcforms-forgn_fincommitusd_pfgrnt / 2 .
1305     ELSE.
1306       CLEAR: zjvc_cc_fcforms-forgn_fincommitusd_pfgrnt50 .
1307     ENDIF.
1308
1309   ***********************************************************************************
1310   *Begin ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
1311     IF NOT zjvc_cc_fcforms-forgn_fincommitgbp_pfgrnt IS INITIAL .
1312       zjvc_cc_fcforms-forgn_fincommitgbp_pfgrnt50 = zjvc_cc_fcforms-forgn_fincommitgbp_pfgrnt / 2.
1313     ELSE.
1314       CLEAR: zjvc_cc_fcforms-forgn_fincommitgbp_pfgrnt50 .
1315     ENDIF.
1316     IF NOT zjvc_cc_fcforms-forgn_fincommiteur_pfgrnt IS INITIAL .
1317       zjvc_cc_fcforms-forgn_fincommiteur_pfgrnt50 = zjvc_cc_fcforms-forgn_fincommiteur_pfgrnt / 2 .
1318     ELSE.
1319       CLEAR: zjvc_cc_fcforms-forgn_fincommiteur_pfgrnt50 .
1320     ENDIF.
1321   *End ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
1322   ***********************************************************************************
1323     zjvc_cc_fcforms-forgn_fincommitfcy_docutot = ( zjvc_cc_fcforms-forgn_fincommitfcy_eqt + zjvc_cc_fcforms-forgn_fincommitfcy_loan + zjvc_cc_fcforms-forgn_fincommitfcy_pfgrnt50 + zjvc_cc_fcforms-forgn_fincommitfcy_corgrnt ).
1324     zjvc_cc_fcforms-forgn_fincommitinr_docutot = ( zjvc_cc_fcforms-forgn_fincommitinr_eqt + zjvc_cc_fcforms-forgn_fincommitinr_loan + zjvc_cc_fcforms-forgn_fincommitinr_pfgrnt50 + zjvc_cc_fcforms-forgn_fincommitinr_corgrnt ).
1325     zjvc_cc_fcforms-forgn_fincommitusd_docutot = ( zjvc_cc_fcforms-forgn_fincommitusd_eqt + zjvc_cc_fcforms-forgn_fincommitusd_loan + zjvc_cc_fcforms-forgn_fincommitusd_pfgrnt50 + zjvc_cc_fcforms-forgn_fincommitusd_corgrnt ).
1326   ***********************************************************************************
1327   *Begin ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
1328     zjvc_cc_fcforms-forgn_fincommitgbp_docutot = ( zjvc_cc_fcforms-forgn_fincommitgbp_eqt + zjvc_cc_fcforms-forgn_fincommitgbp_loan + zjvc_cc_fcforms-forgn_fincommitgbp_pfgrnt50 + zjvc_cc_fcforms-forgn_fincommitgbp_corgrnt ).
1329     zjvc_cc_fcforms-forgn_fincommiteur_docutot = ( zjvc_cc_fcforms-forgn_fincommiteur_eqt + zjvc_cc_fcforms-forgn_fincommiteur_loan + zjvc_cc_fcforms-forgn_fincommiteur_pfgrnt50 + zjvc_cc_fcforms-forgn_fincommiteur_corgrnt ).
1330   *End ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
1331   ***********************************************************************************
1332
1333     IF ( sy-tcode = g_tcode1 OR g_tcode = 'ZJVCCFC1' ) .
1334
1335       IF zjvc_cc_fcforms-vname NE ' ' OR zjvc_cc_fcforms-ccreqno NE ' ' OR zjvc_cc_fcforms-subdry_rcomp NE ' ' .
1336
1337         zjvc_cc_fcforms-forgn_fincommitfcy_uintot = 0 .
1338         zjvc_cc_fcforms-forgn_fincommitfcy_ovltot = 0 .
1339         zjvc_cc_fcforms-forgn_fincommitinr_uintot = 0.
1340         zjvc_cc_fcforms-forgn_fincommitinr_ovltot = 0 .
1341         zjvc_cc_fcforms-forgn_fincommitusd_uintot = 0 .
1342         zjvc_cc_fcforms-forgn_fincommitusd_ovltot = 0 .
1343   ***********************************************************************************
1344   *Begin ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
1345         zjvc_cc_fcforms-forgn_fincommitgbp_uintot = 0.
1346         zjvc_cc_fcforms-forgn_fincommitgbp_ovltot = 0 .
1347         zjvc_cc_fcforms-forgn_fincommiteur_uintot = 0 .
1348         zjvc_cc_fcforms-forgn_fincommiteur_ovltot = 0 .
1349   *End ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
1350   ***********************************************************************************
1351   **For B Total Fields
1352         zjvc_cc_fcforms-forgn_sum_fc_forgn_curr   = 0 .
1353         zjvc_cc_fcforms-forgn_sum_fc_inr          = 0 .
1354   **For A Total Fields
1355         zjvc_cc_fcforms-sum_fc_forgn_curr         = 0 .
1356         zjvc_cc_fcforms-sum_fc_inr                = 0 .
1357
1358   ***********************************************************************
1359         SELECT * APPENDING CORRESPONDING FIELDS OF TABLE ist_ovldetails
1360         FROM  zjvc_cc_fcforms .
1361   ***********************************************************************
1362   *IF ist_ovldetails[] IS INITIAL .
1363
1364         l_forgn_fincommitfcy_uintot = 0 .
1365         l_forgn_fincommitfcy_ovltot = 0 .
1366         l_forgn_fincommitinr_uintot = 0 .
1367         l_forgn_fincommitinr_ovltot = 0 .
1368         l_forgn_fincommitusd_uintot = 0 .
1369         l_forgn_fincommitusd_ovltot = 0 .
1370
1371         l_forgn_fincommitinr_ovltot_op = 0 .
1372         l_forgn_fincommitusd_ovltot_op = 0 .
1373
1374         g_forgn_fincommitfcy_uintot = 0 .
1375         g_forgn_fincommitfcy_ovltot = 0 .
1376         g_forgn_fincommitinr_uintot = 0 .
1377         g_forgn_fincommitinr_ovltot = 0 .
1378         g_forgn_fincommitusd_uintot = 0 .
1379         g_forgn_fincommitusd_ovltot = 0 .
1380
1381         g_forgn_fincommitinr_ovltot_op = 0 .
1382         g_forgn_fincommitusd_ovltot_op = 0 .
1383
1384         g_resddoctot_ovlusd = 0 .
1385         g_resddoctot_ovlinr = 0 .
1386
1387         g_resddoctot_uinusd = 0 .
1388         g_resddoctot_uininr = 0 .
1389
1390   ***********************************************************************************
1391   *Begin ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
1392
1393         l_forgn_fincommitgbp_uintot = 0 .
1394         l_forgn_fincommiteur_ovltot = 0 .
1395         l_forgn_fincommitgbp_uintot = 0 .
1396         l_forgn_fincommiteur_ovltot = 0 .
1397
1398         l_forgn_fincommitgbp_ovltot_op = 0 .
1399         l_forgn_fincommiteur_ovltot_op = 0 .
1400
1401         g_forgn_fincommitgbp_uintot = 0 .
1402         g_forgn_fincommiteur_ovltot = 0 .
1403         g_forgn_fincommitgbp_uintot = 0 .
1404         g_forgn_fincommiteur_ovltot = 0 .
1405
1406         g_forgn_fincommitgbp_ovltot_op = 0 .
1407         g_forgn_fincommiteur_ovltot_op = 0 .
1408
1409         g_resddoctot_ovlgbp = 0 .
1410         g_resddoctot_ovleur = 0 .
1411
1412         g_resddoctot_uingbp = 0 .
1413         g_resddoctot_uineur = 0 .
1414
1415   *End ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
1416   ***********************************************************************************
1417
1418   *Add all opening balances for OVL wise from Master table ZJVC_CC_ASTBLK
1419         SELECT * APPENDING CORRESPONDING FIELDS OF TABLE ist_mastopnbal FROM zjvc_cc_astblk .
1420         LOOP AT ist_mastopnbal .
1421           g_forgn_fincommitusd_ovltot_op = g_forgn_fincommitusd_ovltot_op + ist_mastopnbal-forgn_fincommitfcy_opnbal .
1422           g_forgn_fincommitinr_ovltot_op = g_forgn_fincommitinr_ovltot_op + ist_mastopnbal-forgn_fincommitinr_opnbal .
1423   ***********************************************************************************
1424   *Begin ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
1425           g_forgn_fincommitgbp_ovltot_op = g_forgn_fincommitgbp_ovltot_op + ist_mastopnbal-forgn_fincommitfcy_opnbal_gbp .
1426           g_forgn_fincommiteur_ovltot_op = g_forgn_fincommiteur_ovltot_op + ist_mastopnbal-forgn_fincommitfcy_opnbal_eur .
1427   *End ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
1428   ***********************************************************************************
1429         ENDLOOP .
1430   *BREAK SAP_ABAP  .
1431   *Add all opening balances for OVL wise from Master table ZJVC_CC_ASTBLK
1432         SELECT SINGLE * FROM  zjvc_cc_astblk INTO wa_mastopnbal1 WHERE unq_id = zjvc_cc_fcforms-ei_forgnenty_uin .
1433         g_forgn_fincommitusd_uintot_op = wa_mastopnbal1-forgn_fincommitfcy_opnbal .
1434         g_forgn_fincommitinr_uintot_op = wa_mastopnbal1-forgn_fincommitinr_opnbal .
1435   ***********************************************************************************
1436   *Begin ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
1437         g_forgn_fincommitgbp_uintot_op = wa_mastopnbal1-forgn_fincommitfcy_opnbal_gbp .
1438         g_forgn_fincommiteur_uintot_op = wa_mastopnbal1-forgn_fincommitfcy_opnbal_eur .
1439   *End ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
1440   ***********************************************************************************
1441   *IF ist_ovldetails[] IS INITIAL .
1442         zjvc_cc_fcforms-forgn_fincommitusd_ovltot = zjvc_cc_fcforms-forgn_fincommitusd_docutot + g_forgn_fincommitusd_ovltot_op .
1443         zjvc_cc_fcforms-forgn_fincommitinr_ovltot = zjvc_cc_fcforms-forgn_fincommitinr_docutot + g_forgn_fincommitinr_ovltot_op .
1444
1445         zjvc_cc_fcforms-forgn_fincommitusd_uintot = zjvc_cc_fcforms-forgn_fincommitusd_docutot + g_forgn_fincommitusd_uintot_op .
1446         zjvc_cc_fcforms-forgn_fincommitinr_uintot = zjvc_cc_fcforms-forgn_fincommitinr_docutot + g_forgn_fincommitinr_uintot_op .
1447   ***********************************************************************************
1448   *Begin ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
1449         zjvc_cc_fcforms-forgn_fincommitgbp_ovltot = zjvc_cc_fcforms-forgn_fincommitgbp_docutot + g_forgn_fincommitgbp_ovltot_op .
1450         zjvc_cc_fcforms-forgn_fincommiteur_ovltot = zjvc_cc_fcforms-forgn_fincommiteur_docutot + g_forgn_fincommiteur_ovltot_op .
1451
1452         zjvc_cc_fcforms-forgn_fincommitgbp_uintot = zjvc_cc_fcforms-forgn_fincommitgbp_docutot + g_forgn_fincommitgbp_uintot_op .
1453         zjvc_cc_fcforms-forgn_fincommiteur_uintot = zjvc_cc_fcforms-forgn_fincommiteur_docutot + g_forgn_fincommiteur_uintot_op .
1454
1455   *End ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
1456   ***********************************************************************************
1457
1458   *For OVL Wise TOTALS**********************************************************************************************************
1459         SORT ist_ovldetails DESCENDING BY doc_no .
1460
1461         READ TABLE ist_ovldetails INDEX 1 .
1462         g_forgn_fincommitusd_ovltot = ist_ovldetails-forgn_fincommitusd_ovltot  .
1463         g_forgn_fincommitinr_ovltot = ist_ovldetails-forgn_fincommitinr_ovltot  .
1464   ***********************************************************************************
1465   *Begin ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
1466         g_forgn_fincommitgbp_ovltot = ist_ovldetails-forgn_fincommitgbp_ovltot  .
1467         g_forgn_fincommiteur_ovltot = ist_ovldetails-forgn_fincommiteur_ovltot  .
1468   *End ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
1469   ***********************************************************************************
1470         zjvc_cc_fcforms-forgn_fincommitusd_ovltot = g_forgn_fincommitusd_ovltot + zjvc_cc_fcforms-forgn_fincommitusd_docutot .
1471         zjvc_cc_fcforms-forgn_fincommitinr_ovltot = g_forgn_fincommitinr_ovltot + zjvc_cc_fcforms-forgn_fincommitinr_docutot .
1472   ***********************************************************************************
1473   *Begin ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
1474         zjvc_cc_fcforms-forgn_fincommitgbp_ovltot = g_forgn_fincommitgbp_ovltot + zjvc_cc_fcforms-forgn_fincommitgbp_docutot .
1475         zjvc_cc_fcforms-forgn_fincommiteur_ovltot = g_forgn_fincommiteur_ovltot + zjvc_cc_fcforms-forgn_fincommiteur_docutot .
1476   *End ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
1477   ***********************************************************************************
1478
1479         IF ist_ovldetails[] IS INITIAL .
1480           zjvc_cc_fcforms-forgn_fincommitusd_ovltot = g_forgn_fincommitusd_ovltot_op + zjvc_cc_fcforms-forgn_fincommitusd_docutot .
1481           zjvc_cc_fcforms-forgn_fincommitinr_ovltot = g_forgn_fincommitinr_ovltot_op + zjvc_cc_fcforms-forgn_fincommitinr_docutot .
1482   ***********************************************************************************
1483   *Begin ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
1484           zjvc_cc_fcforms-forgn_fincommitgbp_ovltot = g_forgn_fincommitgbp_ovltot_op + zjvc_cc_fcforms-forgn_fincommitgbp_docutot .
1485           zjvc_cc_fcforms-forgn_fincommiteur_ovltot = g_forgn_fincommiteur_ovltot_op + zjvc_cc_fcforms-forgn_fincommiteur_docutot .
1486   *End ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
1487   ***********************************************************************************
1488         ENDIF. "IF ist_ovldetails[] IS NOT INITIAL .
1489   ******************************************************************************************************************************
1490   *For UIN Wise TOTALS**********************************************************************************************************
1491         ist_uindetails[] = ist_ovldetails[] .
1492
1493         DELETE ist_uindetails WHERE ei_forgnenty_uin <> zjvc_cc_fcforms-ei_forgnenty_uin .
1494         SORT ist_uindetails DESCENDING BY doc_no .
1495         READ TABLE ist_uindetails INDEX 1 .
1496
1497         g_forgn_fincommitusd_uintot = ist_uindetails-forgn_fincommitusd_uintot  .
1498         g_forgn_fincommitinr_uintot = ist_uindetails-forgn_fincommitinr_uintot  .
1499
1500   ***********************************************************************************
1501   *Begin ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
1502         g_forgn_fincommitgbp_uintot = ist_uindetails-forgn_fincommitgbp_uintot  .
1503         g_forgn_fincommiteur_uintot = ist_uindetails-forgn_fincommiteur_uintot  .
1504   *End ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
1505   ***********************************************************************************
1506         zjvc_cc_fcforms-forgn_fincommitusd_uintot = g_forgn_fincommitusd_uintot + zjvc_cc_fcforms-forgn_fincommitusd_docutot .
1507         zjvc_cc_fcforms-forgn_fincommitinr_uintot = g_forgn_fincommitinr_uintot + zjvc_cc_fcforms-forgn_fincommitinr_docutot .
1508   ***********************************************************************************
1509   *Begin ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
1510         zjvc_cc_fcforms-forgn_fincommitgbp_uintot = g_forgn_fincommitgbp_uintot + zjvc_cc_fcforms-forgn_fincommitgbp_docutot .
1511         zjvc_cc_fcforms-forgn_fincommiteur_uintot = g_forgn_fincommiteur_uintot + zjvc_cc_fcforms-forgn_fincommiteur_docutot .
1512   *End ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
1513   ***********************************************************************************
1514
1515         IF ist_uindetails[] IS INITIAL .
1516           zjvc_cc_fcforms-forgn_fincommitusd_uintot = g_forgn_fincommitusd_uintot_op + zjvc_cc_fcforms-forgn_fincommitusd_docutot .
1517           zjvc_cc_fcforms-forgn_fincommitinr_uintot = g_forgn_fincommitinr_uintot_op + zjvc_cc_fcforms-forgn_fincommitinr_docutot .
1518   ***********************************************************************************
1519   *Begin ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
1520           zjvc_cc_fcforms-forgn_fincommitgbp_uintot = g_forgn_fincommitgbp_uintot_op + zjvc_cc_fcforms-forgn_fincommitgbp_docutot .
1521           zjvc_cc_fcforms-forgn_fincommiteur_uintot = g_forgn_fincommiteur_uintot_op + zjvc_cc_fcforms-forgn_fincommiteur_docutot .
1522   *End ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
1523   ***********************************************************************************
1524         ENDIF. "IF ist_uindetails[] IS NOT INITIAL .
1525   *********************************************************************************************************************************
1526   **Populate OVL Wise & UIN Wise Totals accrued at the current document creation stage
1527         zjvc_cc_fcforms-forgn_fincommitusd_uintotdoc = zjvc_cc_fcforms-forgn_fincommitusd_uintot .
1528         zjvc_cc_fcforms-forgn_fincommitusd_ovltotdoc = zjvc_cc_fcforms-forgn_fincommitusd_ovltot .
1529
1530         zjvc_cc_fcforms-forgn_fincommitinr_uintotdoc = zjvc_cc_fcforms-forgn_fincommitinr_uintot .
1531         zjvc_cc_fcforms-forgn_fincommitinr_ovltotdoc = zjvc_cc_fcforms-forgn_fincommitinr_ovltot .
1532
1533   ***********************************************************************************
1534   *Begin ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
1535
1536         zjvc_cc_fcforms-forgn_fincommitgbp_uintotdoc = zjvc_cc_fcforms-forgn_fincommitgbp_uintot .
1537         zjvc_cc_fcforms-forgn_fincommitgbp_ovltotdoc = zjvc_cc_fcforms-forgn_fincommitgbp_ovltot .
1538
1539         zjvc_cc_fcforms-forgn_fincommiteur_uintotdoc = zjvc_cc_fcforms-forgn_fincommiteur_uintot .
1540         zjvc_cc_fcforms-forgn_fincommiteur_ovltotdoc = zjvc_cc_fcforms-forgn_fincommiteur_ovltot .
1541
1542   *End ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
1543   ***********************************************************************************
1544       ENDIF."IF ZJVC_CC_FCFORMS-VNAME NE ' ' OR ZJVC_CC_FCFORMS-CCREQNO NE ' ' OR ZJVC_CC_FCFORMS-SUBDRY_RCOMP NE ' ' .
1545
1546     ENDIF ."IF ( SY-TCODE = G_TCODE1 OR G_TCODE = 'ZJVCCFC1' ) .
1547   ************************************************************************************************************************************************************
1548   ************************************************************************************************************************************************************
1549   *Replace values to cumulate dynamically while change/display .
1550     IF ( sy-tcode = g_tcode2 OR g_tcode = 'ZJVCCFC2' ) OR ( sy-tcode = g_tcode3 OR g_tcode = 'ZJVCCFC3' ) OR ( sy-tcode = g_tcode5 OR g_tcode = 'ZJVCCFC5' ) .
1551
1552   *  IF ( SY-TCODE = G_TCODE4 OR G_TCODE = 'ZJVCCFC5' ) .
1553
1554       DATA : wa_zjvc_cc_fcforms TYPE zjvc_cc_fcforms .
1555
1556       DATA : ldf_forgn_fincommitinr_docutot LIKE zjvc_cc_fcforms-forgn_fincommitinr_docutot,
1557              ldf_forgn_fincommitusd_docutot LIKE zjvc_cc_fcforms-forgn_fincommitusd_docutot,
1558   ***********************************************************************************
1559   *Begin ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
1560              ldf_forgn_fincommitgbp_docutot LIKE zjvc_cc_fcforms-forgn_fincommitgbp_docutot,
1561              ldf_forgn_fincommiteur_docutot LIKE zjvc_cc_fcforms-forgn_fincommiteur_docutot.
1562   *End ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
1563   ***********************************************************************************
1564   ******************************************************************************************************************************
1565   *  SELECT * APPENDING CORRESPONDING FIELDS OF TABLE ist_ovldetails
1566   *  FROM  ZJVC_CC_FCFORMS .
1567       MOVE zjvc_cc_fcforms TO wa_zjvc_cc_fcforms .
1568   ****************************COMMENTED THE TOTALS BEING DISPLAYED CONSIDERING ALL DOCUMENTS TILL LAST IN THE TABLE*************
1569   *For OVL Wise TOTALS**********************************************************************************************************
1570   *    SORT ist_ovldetails DESCENDING BY DOC_NO .
1571   *    READ TABLE ist_ovldetails INDEX 1 .
1572   *     g_FORGN_FINCOMMITUSD_OVLTOT = ist_ovldetails-FORGN_FINCOMMITUSD_OVLTOT  .
1573   *     g_FORGN_FINCOMMITINR_OVLTOT = ist_ovldetails-FORGN_FINCOMMITINR_OVLTOT  .
1574   *
1575   *     ZJVC_CC_FCFORMS-FORGN_FINCOMMITUSD_OVLTOT = g_FORGN_FINCOMMITUSD_OVLTOT ." + ZJVC_CC_FCFORMS-FORGN_FINCOMMITUSD_DOCUTOT .
1576   *     ZJVC_CC_FCFORMS-FORGN_FINCOMMITINR_OVLTOT = g_FORGN_FINCOMMITINR_OVLTOT ."+ ZJVC_CC_FCFORMS-FORGN_FINCOMMITINR_DOCUTOT .
1577   ****************************COMMENTED THE TOTALS BEING DISPLAYED CONSIDERING ALL DOCUMENTS TILL LAST IN THE TABLE*************
1578
1579   *   DELETE ist_uindetails WHERE DOC_NO GT ZJVC_CC_FCFORMS-DOC_NO .
1580   *********************************************************************************************************************************
1581   *For UIN Wise TOTALS*************************************************************************************************************
1582   *    ist_uindetails[] = ist_ovldetails[] .
1583
1584   *    DELETE ist_uindetails WHERE EI_FORGNENTY_UIN <> ZJVC_CC_FCFORMS-EI_FORGNENTY_UIN .
1585   ****************************COMMENTED THE TOTALS BEING DISPLAYED CONSIDERING ALL DOCUMENTS TILL LAST IN THE TABLE*************
1586   *    SORT ist_uindetails DESCENDING BY DOC_NO .
1587   *    READ TABLE ist_uindetails INDEX 1 .
1588   *
1589   *     g_FORGN_FINCOMMITUSD_UINTOT = ist_uindetails-FORGN_FINCOMMITUSD_UINTOT  .
1590   *     g_FORGN_FINCOMMITINR_UINTOT = ist_uindetails-FORGN_FINCOMMITINR_UINTOT  .
1591   *
1592   *     ZJVC_CC_FCFORMS-FORGN_FINCOMMITUSD_UINTOT = g_FORGN_FINCOMMITUSD_UINTOT ."+ ZJVC_CC_FCFORMS-FORGN_FINCOMMITUSD_DOCUTOT .
1593   *     ZJVC_CC_FCFORMS-FORGN_FINCOMMITINR_UINTOT = g_FORGN_FINCOMMITINR_UINTOT ."+ ZJVC_CC_FCFORMS-FORGN_FINCOMMITINR_DOCUTOT .
1594   ****************************COMMENTED THE TOTALS BEING DISPLAYED CONSIDERING ALL DOCUMENTS TILL LAST IN THE TABLE*************
1595   *********************************************************************************************************************************
1596   *break sap_abap .
1597   *In reduced USD doc value scenario
1598       IF zjvc_cc_fcforms-forgn_fincommitusd_docutot LT wa_zjvc_cc_fcforms_prv-forgn_fincommitusd_docutot .
1599         ldf_forgn_fincommitusd_docutot = wa_zjvc_cc_fcforms_prv-forgn_fincommitusd_docutot - zjvc_cc_fcforms-forgn_fincommitusd_docutot .
1600         zjvc_cc_fcforms-forgn_fincommitusd_uintot = zjvc_cc_fcforms-forgn_fincommitusd_uintot - ldf_forgn_fincommitusd_docutot .
1601         zjvc_cc_fcforms-forgn_fincommitusd_ovltot = zjvc_cc_fcforms-forgn_fincommitusd_ovltot - ldf_forgn_fincommitusd_docutot .
1602         g_resddoctot_ovlusd = ( - ldf_forgn_fincommitusd_docutot ) .
1603   *In addition USD doc value scenario
1604       ELSEIF zjvc_cc_fcforms-forgn_fincommitusd_docutot GT wa_zjvc_cc_fcforms_prv-forgn_fincommitusd_docutot .
1605         ldf_forgn_fincommitusd_docutot = zjvc_cc_fcforms-forgn_fincommitusd_docutot - wa_zjvc_cc_fcforms_prv-forgn_fincommitusd_docutot .
1606         zjvc_cc_fcforms-forgn_fincommitusd_uintot = zjvc_cc_fcforms-forgn_fincommitusd_uintot + ldf_forgn_fincommitusd_docutot .
1607         zjvc_cc_fcforms-forgn_fincommitusd_ovltot = zjvc_cc_fcforms-forgn_fincommitusd_ovltot + ldf_forgn_fincommitusd_docutot .
1608         g_resddoctot_ovlusd = ldf_forgn_fincommitusd_docutot .
1609       ELSEIF zjvc_cc_fcforms-forgn_fincommitusd_docutot EQ wa_zjvc_cc_fcforms_prv-forgn_fincommitusd_docutot .
1610         g_resddoctot_ovlusd = 0 .
1611   *Do nothing
1612       ENDIF.
1613   *In reduced INR doc value scenario
1614       IF zjvc_cc_fcforms-forgn_fincommitinr_docutot LT wa_zjvc_cc_fcforms_prv-forgn_fincommitinr_docutot .
1615         ldf_forgn_fincommitinr_docutot = wa_zjvc_cc_fcforms_prv-forgn_fincommitinr_docutot - zjvc_cc_fcforms-forgn_fincommitinr_docutot .
1616         zjvc_cc_fcforms-forgn_fincommitinr_uintot = zjvc_cc_fcforms-forgn_fincommitinr_uintot - ldf_forgn_fincommitinr_docutot .
1617         zjvc_cc_fcforms-forgn_fincommitinr_ovltot = zjvc_cc_fcforms-forgn_fincommitinr_ovltot - ldf_forgn_fincommitinr_docutot .
1618         g_resddoctot_ovlinr = ( - ldf_forgn_fincommitinr_docutot ) .
1619   *In addition INR doc value scenario
1620       ELSEIF zjvc_cc_fcforms-forgn_fincommitinr_docutot GT wa_zjvc_cc_fcforms_prv-forgn_fincommitinr_docutot .
1621         ldf_forgn_fincommitinr_docutot = zjvc_cc_fcforms-forgn_fincommitinr_docutot - wa_zjvc_cc_fcforms_prv-forgn_fincommitinr_docutot .
1622         zjvc_cc_fcforms-forgn_fincommitinr_uintot = zjvc_cc_fcforms-forgn_fincommitinr_uintot + ldf_forgn_fincommitinr_docutot .
1623         zjvc_cc_fcforms-forgn_fincommitinr_ovltot = zjvc_cc_fcforms-forgn_fincommitinr_ovltot + ldf_forgn_fincommitinr_docutot .
1624         g_resddoctot_ovlinr = ldf_forgn_fincommitinr_docutot .
1625       ELSEIF zjvc_cc_fcforms-forgn_fincommitinr_docutot EQ wa_zjvc_cc_fcforms_prv-forgn_fincommitinr_docutot .
1626         g_resddoctot_ovlinr = 0 .
1627   *Do nothing
1628       ENDIF.
1629
1630   ***********************************************************************************
1631   *Begin ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
1632   *In reduced GBP doc value scenario
1633       IF zjvc_cc_fcforms-forgn_fincommitgbp_docutot LT wa_zjvc_cc_fcforms_prv-forgn_fincommitgbp_docutot .
1634         ldf_forgn_fincommitgbp_docutot = wa_zjvc_cc_fcforms_prv-forgn_fincommitgbp_docutot - zjvc_cc_fcforms-forgn_fincommitgbp_docutot .
1635         zjvc_cc_fcforms-forgn_fincommitgbp_uintot = zjvc_cc_fcforms-forgn_fincommitgbp_uintot - ldf_forgn_fincommitgbp_docutot .
1636         zjvc_cc_fcforms-forgn_fincommitgbp_ovltot = zjvc_cc_fcforms-forgn_fincommitgbp_ovltot - ldf_forgn_fincommitgbp_docutot .
1637         g_resddoctot_ovlgbp = ( - ldf_forgn_fincommitgbp_docutot ) .
1638   *In addition GBP doc value scenario
1639       ELSEIF zjvc_cc_fcforms-forgn_fincommitgbp_docutot GT wa_zjvc_cc_fcforms_prv-forgn_fincommitgbp_docutot .
1640         ldf_forgn_fincommitgbp_docutot = zjvc_cc_fcforms-forgn_fincommitgbp_docutot - wa_zjvc_cc_fcforms_prv-forgn_fincommitgbp_docutot .
1641         zjvc_cc_fcforms-forgn_fincommitgbp_uintot = zjvc_cc_fcforms-forgn_fincommitgbp_uintot + ldf_forgn_fincommitgbp_docutot .
1642         zjvc_cc_fcforms-forgn_fincommitgbp_ovltot = zjvc_cc_fcforms-forgn_fincommitgbp_ovltot + ldf_forgn_fincommitgbp_docutot .
1643         g_resddoctot_ovlgbp = ldf_forgn_fincommitgbp_docutot .
1644       ELSEIF zjvc_cc_fcforms-forgn_fincommitgbp_docutot EQ wa_zjvc_cc_fcforms_prv-forgn_fincommitgbp_docutot .
1645         g_resddoctot_ovlgbp = 0 .
1646   *Do nothing
1647       ENDIF.
1648
1649   *In reduced EUR doc value scenario
1650       IF zjvc_cc_fcforms-forgn_fincommiteur_docutot LT wa_zjvc_cc_fcforms_prv-forgn_fincommiteur_docutot .
1651         ldf_forgn_fincommiteur_docutot = wa_zjvc_cc_fcforms_prv-forgn_fincommiteur_docutot - zjvc_cc_fcforms-forgn_fincommiteur_docutot .
1652         zjvc_cc_fcforms-forgn_fincommiteur_uintot = zjvc_cc_fcforms-forgn_fincommiteur_uintot - ldf_forgn_fincommiteur_docutot .
1653         zjvc_cc_fcforms-forgn_fincommiteur_ovltot = zjvc_cc_fcforms-forgn_fincommiteur_ovltot - ldf_forgn_fincommiteur_docutot .
1654         g_resddoctot_ovleur = ( - ldf_forgn_fincommiteur_docutot ) .
1655   *In addition EUR doc value scenario
1656       ELSEIF zjvc_cc_fcforms-forgn_fincommiteur_docutot GT wa_zjvc_cc_fcforms_prv-forgn_fincommiteur_docutot .
1657         ldf_forgn_fincommiteur_docutot = zjvc_cc_fcforms-forgn_fincommiteur_docutot - wa_zjvc_cc_fcforms_prv-forgn_fincommiteur_docutot .
1658         zjvc_cc_fcforms-forgn_fincommiteur_uintot = zjvc_cc_fcforms-forgn_fincommiteur_uintot + ldf_forgn_fincommiteur_docutot .
1659         zjvc_cc_fcforms-forgn_fincommiteur_ovltot = zjvc_cc_fcforms-forgn_fincommiteur_ovltot + ldf_forgn_fincommiteur_docutot .
1660         g_resddoctot_ovleur = ldf_forgn_fincommiteur_docutot .
1661       ELSEIF zjvc_cc_fcforms-forgn_fincommiteur_docutot EQ wa_zjvc_cc_fcforms_prv-forgn_fincommiteur_docutot .
1662         g_resddoctot_ovleur = 0 .
1663   *Do nothing
1664       ENDIF.
1665   *End ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
1666   ***********************************************************************************
1667   *******************************************************************************************************************************
1668   *  SELECT * APPENDING CORRESPONDING FIELDS OF TABLE ist_ovldetails
1669   *  FROM  ZJVC_CC_FCFORMS .
1670   **For OVL Wise TOTALS**********************************************************************************************************
1671   *    SORT ist_ovldetails DESCENDING BY DOC_NO .
1672   *    READ TABLE ist_ovldetails INDEX 1 .
1673   *     g_FORGN_FINCOMMITUSD_OVLTOT = ist_ovldetails-FORGN_FINCOMMITUSD_OVLTOT  .
1674   *     g_FORGN_FINCOMMITINR_OVLTOT = ist_ovldetails-FORGN_FINCOMMITINR_OVLTOT  .
1675   *
1676   *     ZJVC_CC_FCFORMS-FORGN_FINCOMMITUSD_OVLTOT = g_FORGN_FINCOMMITUSD_OVLTOT ." + ZJVC_CC_FCFORMS-FORGN_FINCOMMITUSD_DOCUTOT .
1677   *     ZJVC_CC_FCFORMS-FORGN_FINCOMMITINR_OVLTOT = g_FORGN_FINCOMMITINR_OVLTOT ."+ ZJVC_CC_FCFORMS-FORGN_FINCOMMITINR_DOCUTOT .
1678   *
1679   **    DELETE ist_uindetails WHERE DOC_NO GT ZJVC_CC_FCFORMS-DOC_NO .
1680   **********************************************************************************************************************************
1681   **For UIN Wise TOTALS*************************************************************************************************************
1682   *    ist_uindetails[] = ist_ovldetails[] .
1683   *
1684   *    DELETE ist_uindetails WHERE EI_FORGNENTY_UIN <> ZJVC_CC_FCFORMS-EI_FORGNENTY_UIN .
1685   *    SORT ist_uindetails DESCENDING BY DOC_NO .
1686   *    READ TABLE ist_uindetails INDEX 1 .
1687   *
1688   *     g_FORGN_FINCOMMITUSD_UINTOT = ist_uindetails-FORGN_FINCOMMITUSD_UINTOT  .
1689   *     g_FORGN_FINCOMMITINR_UINTOT = ist_uindetails-FORGN_FINCOMMITINR_UINTOT  .
1690   *
1691   *     ZJVC_CC_FCFORMS-FORGN_FINCOMMITUSD_UINTOT = g_FORGN_FINCOMMITUSD_UINTOT ."+ ZJVC_CC_FCFORMS-FORGN_FINCOMMITUSD_DOCUTOT .
1692   *     ZJVC_CC_FCFORMS-FORGN_FINCOMMITINR_UINTOT = g_FORGN_FINCOMMITINR_UINTOT ."+ ZJVC_CC_FCFORMS-FORGN_FINCOMMITINR_DOCUTOT .
1693   **********************************************************************************************************************************
1694   **Populate OVL Wise Totals in Form A Fields
1695   *     ZJVC_CC_FCFORMS-SUM_FC_FORGN_CURR = ZJVC_CC_FCFORMS-FORGN_FINCOMMITUSD_OVLTOT .
1696   *     ZJVC_CC_FCFORMS-SUM_FC_INR        = ZJVC_CC_FCFORMS-FORGN_FINCOMMITINR_OVLTOT .
1697   *
1698   **Populate UIN Wise Totals in Form B Fields
1699   *     ZJVC_CC_FCFORMS-FORGN_SUM_FC_FORGN_CURR = ZJVC_CC_FCFORMS-FORGN_FINCOMMITUSD_UINTOT .
1700   *     ZJVC_CC_FCFORMS-FORGN_SUM_FC_INR        = ZJVC_CC_FCFORMS-FORGN_FINCOMMITINR_UINTOT .
1701       MOVE zjvc_cc_fcforms TO wa_zjvc_cc_fcforms_prv .
1702     ENDIF." ( SY-TCODE = G_TCODE2 OR G_TCODE = 'ZJVCCFC2' ) OR ( SY-TCODE = G_TCODE3 OR G_TCODE = 'ZJVCCFC3' ) OR ( SY-TCODE = G_TCODE4 OR G_TCODE = 'ZJVCCFC4' )
1703
1704     CLEAR : g_forgn_fincommitinr_ovltot_op, g_forgn_fincommitusd_ovltot_op .
1705   ***********************************************************************************
1706   *Begin ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
1707     CLEAR : g_forgn_fincommitgbp_ovltot_op, g_forgn_fincommiteur_ovltot_op .
1708   *End ARV Two Currency Addition OCDK908512  OCDK908512 10-Sep-2025
1709   ***********************************************************************************
1710   *Populate OVL Wise Totals in Form A Fields
1711     zjvc_cc_fcforms-sum_fc_forgn_curr = zjvc_cc_fcforms-forgn_fincommitusd_ovltot .
1712     zjvc_cc_fcforms-sum_fc_inr        = zjvc_cc_fcforms-forgn_fincommitinr_ovltot .
1713
1714   *Populate UIN Wise Totals in Form B Fields
1715     zjvc_cc_fcforms-forgn_sum_fc_forgn_curr = zjvc_cc_fcforms-forgn_fincommitusd_uintot .
1716     zjvc_cc_fcforms-forgn_sum_fc_inr        = zjvc_cc_fcforms-forgn_fincommitinr_uintot .
1717
1718     REFRESH ist_ovldetails.
1719     REFRESH ist_uindetails .
1720     REFRESH ist_mastopnbal .
1721   *************************************************************************************************
1722
1723   ENDFORM.
1724   *&---------------------------------------------------------------------*
1725   *&      Form  GET_PRVS_PIDATA
1726   *&---------------------------------------------------------------------*
1727   *       text
1728   *----------------------------------------------------------------------*
1729   *  -->  p1        text
1730   *  <--  p2        text
1731   *----------------------------------------------------------------------*
1732   FORM get_prvs_pidata .
1733     DATA : wa_ist_pidetails1 LIKE LINE OF ist_pidetails1 .
1734   *Get Previous Line Item Data of the current UIN, if exists
1735     IF ( sy-tcode = g_tcode1 OR g_tcode = 'ZJVCCFC1' ) .
1736
1737       SELECT * APPENDING CORRESPONDING FIELDS OF TABLE ist_pidetails1
1738       FROM  zjvc_cc_fcformsb
1739       WHERE ei_forgnenty_uin = zjvc_cc_fcforms-ei_forgnenty_uin .
1740
1741       IF sy-subrc = 0 .
1742         SORT ist_pidetails1 DESCENDING BY doc_no .
1743
1744         READ TABLE ist_pidetails1 INDEX 1 INTO wa_ist_pidetails1.
1745
1746         DELETE ist_pidetails1 WHERE doc_no <> wa_ist_pidetails1-doc_no .
1747       ENDIF."sy-subrc EQ 0.
1748
1749     ENDIF ."  IF ( SY-TCODE = G_TCODE1 OR G_TCODE = 'ZJVCCFC1' ) .
1750
1751     CLEAR : wa_ist_pidetails1, ist_pidetails1.
1752   *REFRESH : ist_pidetails.
1753
1754   ENDFORM.
1755   *&---------------------------------------------------------------------*
1756   *&      Form  CHECK_PERDETAILS
1757   *&---------------------------------------------------------------------*
1758   *       text
1759   *----------------------------------------------------------------------*
1760   *  -->  p1        text
1761   *  <--  p2        text
1762   *----------------------------------------------------------------------*
1763   FORM check_perdetails .
1764
1765     IF zjvc_cc_fcforms-contct_per_cpf IS INITIAL .
1766       MESSAGE 'CPF No cannot be Blank ' TYPE 'E'.
1767     ENDIF.
1768
1769     IF zjvc_cc_fcforms-contct_per_mobno IS INITIAL .
1770       MESSAGE 'Mobile No cannot be Blank ' TYPE 'E'.
1771     ENDIF.
1772
1773     IF zjvc_cc_fcforms-contct_per_email IS INITIAL .
1774       MESSAGE 'Email ID cannot be Blank ' TYPE 'E'.
1775     ENDIF.
1776
1777   ENDFORM.
*--- End of SAPMZPSJVCCFCFORMSF01 - 1777 lines ---

----------------------------------------------------------------------------------------------------
Include          MZPSJVCCFCFORMS_GET_TOTALS_F01            Level 1    Page 6
Object           SAPMZPSJVCCFCFORMS                        Lines 91
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:21
----------------------------------------------------------------------------------------------------
1      *----------------------------------------------------------------------*
2      ***INCLUDE MZPSJVCCFCFORMS_GET_TOTALS_F01.
3      *----------------------------------------------------------------------*
4      *&---------------------------------------------------------------------*
5      *&      Form  GET_TOTALS_FCFORMB_NEW
6      *&---------------------------------------------------------------------*
7      *       text
8      *----------------------------------------------------------------------*
9      *  -->  p1        text
10     *  <--  p2        text
11     *----------------------------------------------------------------------*
12     FORM get_totals_fcformb_new .
13       IF zjvc_cc_fcforms-ccprntreq = 'X'.
14     *  break abapuser02.
15     *    SELECT SINGLE * FROM bkpf INTO @DATA(wa_bkpf) WHERE bukrs =  @zjvc_cc_fcforms-bukrs AND xblnr EQ @zjvc_cc_fcforms-ccreqno.
16         SELECT * FROM bkpf UP TO 1 ROWS INTO @DATA(wa_bkpf) WHERE bukrs =  @zjvc_cc_fcforms-bukrs AND xblnr EQ @zjvc_cc_fcforms-ccreqno order by primary key. endselect.
17         IF sy-subrc EQ 0.
18
19           zjvc_cc_fcforms-curr_key = wa_bkpf-waers.
20
21
22         ENDIF.
23
24
25
26     *    SELECT SINGLE * FROM zjvc_cc_astblk INTO @DATA(temp) WHERE unq_id = @zjvc_cc_fcforms-ei_forgnenty_uin.
27         SELECT * FROM zjvc_cc_astblk UP TO 1 ROWS INTO @DATA(temp) WHERE unq_id = @zjvc_cc_fcforms-ei_forgnenty_uin ORDER BY PRIMARY KEY. ENDSELECT.
28     *  IF sy-subrc EQ 0.
29     *
30     *
31     *
32     *  ENDIF.
33     *
34     *
35         IF zjvc_cc_fcforms-forgn_fincommitusd_eqt  IS INITIAL AND  zjvc_cc_fcforms-forgn_fincommiteur_eqt IS INITIAL
36           AND zjvc_cc_fcforms-forgn_fincommitgbp_eqt IS INITIAL.
37     *      SELECT SINGLE * FROM bseg INTO @DATA(wa_bseg) WHERE bukrs = @wa_bkpf-bukrs  AND belnr = @wa_bkpf-belnr .
38           SELECT * FROM bseg UP TO 1 ROWS INTO @DATA(wa_bseg) WHERE bukrs = @wa_bkpf-bukrs  AND belnr = @wa_bkpf-belnr ORDER BY PRIMARY KEY. ENDSELECT.
39           IF sy-subrc EQ 0.
40             IF zjvc_cc_fcforms-curr_key = 'USD'.
41               zjvc_cc_fcforms-forgn_fincommitusd_eqt = wa_bseg-wrbtr.
42             ELSEIF zjvc_cc_fcforms-curr_key = 'EUR'.
43               zjvc_cc_fcforms-forgn_fincommiteur_eqt = wa_bseg-wrbtr.
44             ELSEIF zjvc_cc_fcforms-curr_key = 'GBP'.
45               zjvc_cc_fcforms-forgn_fincommitgbp_eqt = wa_bseg-wrbtr.
46             ENDIF.
47
48             zjvc_cc_fcforms-forgn_fincommitfcy_eqt =  wa_bseg-dmbe2."equivalent_usd
49             zjvc_cc_fcforms-forgn_fincommitinr_eqt =  wa_bseg-dmbtr."equivalent_inr
50
51           ENDIF.
52
53         ENDIF.
54       ENDIF.
55
56       IF zjvc_cc_fcforms-curr_key IS  INITIAL.
57     *    SELECT SINGLE * FROM bkpf INTO @DATA(wa_bkpf1) WHERE bukrs =  'OVL' AND belnr  EQ @zjvc_cc_fcforms-belnr.
58         SELECT * FROM bkpf UP TO 1 ROWS INTO @DATA(wa_bkpf1) WHERE bukrs =  'OVL' AND belnr  EQ @zjvc_cc_fcforms-belnr ORDER BY PRIMARY KEY. ENDSELECT.
59         IF sy-subrc EQ 0.
60
61           zjvc_cc_fcforms-curr_key = wa_bkpf1-waers.
62
63
64         ENDIF.
65
66
67       ENDIF.
68
69     *
70     *  ENDIF.
71     *  " for equity calculation .""""""""""""""
72     *  zjvc_cc_fcforms-forgn_fincommitusd_eqt = temp-equity_usd.
73     *  zjvc_cc_fcforms-forgn_fincommiteur_eqt = temp-equity_euro + wa_bseg-wrbtr.
74     *  zjvc_cc_fcforms-forgn_fincommitgbp_eqt = temp-equity_gbp.
75     *  zjvc_cc_fcforms-forgn_fincommitfcy_eqt = temp-equity_equivalent_usd + wa_bseg-dmbe2.
76     *  zjvc_cc_fcforms-forgn_fincommitinr_eqt = temp-equity_equivalent_inr + wa_bseg-dmbtr.
77     *
78     *  " for loan calculation """""""""""""
79     *
80     *  zjvc_cc_fcforms-forgn_fincommitusd_loan = temp-loan_usd.
81     *  zjvc_cc_fcforms-forgn_fincommiteur_loan = temp-loan_euro.
82     *  zjvc_cc_fcforms-forgn_fincommitgbp_loan = temp-loan_gbp.
83     *  zjvc_cc_fcforms-forgn_fincommitfcy_loan = temp-loan_equivalent_usd.
84     *  zjvc_cc_fcforms-forgn_fincommitinr_loan = temp-loan_equivalent_inr.
85
86
87
88
89
90
91     ENDFORM.
*--- End of MZPSJVCCFCFORMS_GET_TOTALS_F01 - 91 lines ---

----------------------------------------------------------------------------------------------------
Include          MZPSJVCCFCFORMS_USER_COMMANI01            Level 1    Page 7
Object           SAPMZPSJVCCFCFORMS                        Lines 181
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:21
----------------------------------------------------------------------------------------------------
1      *----------------------------------------------------------------------*
2      ***INCLUDE MZPSJVCCFCFORMS_USER_COMMANI01.
3      *----------------------------------------------------------------------*
4      *&---------------------------------------------------------------------*
5      *&      Module  USER_COMMAND_0130  INPUT
6      *&---------------------------------------------------------------------*
7      *       text
8      *----------------------------------------------------------------------*
9      MODULE user_command_0130 INPUT.
10
11       SELECT SINGLE * FROM bkpf INTO @DATA(wa_bkpf) WHERE bukrs =  @zjvc_cc_fcforms-bukrs AND xblnr EQ @zjvc_cc_fcforms-ccreqno.
12
13       SELECT SINGLE * FROM zjvc_cc_astblk INTO @DATA(temp) WHERE unq_id = @zjvc_cc_fcforms-ei_forgnenty_uin.
14       IF sy-subrc EQ 0.
15
16
17
18       ENDIF.
19
20       IF zjvc_cc_fcforms-bukrs IS NOT INITIAL .
21         SELECT SINGLE * FROM zjvc_ovl_ob INTO @DATA(ob_ovl) WHERE bukrs =  @zjvc_cc_fcforms-bukrs .
22       ELSE.
23         SELECT SINGLE * FROM zjvc_ovl_ob INTO ob_ovl WHERE bukrs =  'OVL' .
24
25       ENDIF.
26     *  IF sy-subrc EQ 0.
27
28       IF g_tcode NE 'ZJVCCFC2'  AND g_tcode NE 'ZJVCCFC3' AND g_tcode NE 'ZJVCCFC5'.
29
30
31         SELECT * FROM zjvc_cc_fcforms INTO TABLE @DATA(lt_tran) WHERE ei_forgnenty_uin EQ @zjvc_cc_fcforms-ei_forgnenty_uin .
32
33         LOOP AT lt_tran INTO DATA(ls_tran).
34
35           total_equity_usd  = total_equity_usd  + ls_tran-forgn_fincommitusd_eqt.
36           total_equity_euro = total_equity_euro + ls_tran-forgn_fincommiteur_eqt.
37           total_equity_gbp = total_equity_gbp + ls_tran-forgn_fincommitgbp_eqt.
38           total_equity_eq_usd = total_equity_eq_usd + ls_tran-forgn_fincommitfcy_eqt.
39           total_equity_eq_inr = total_equity_eq_inr + ls_tran-forgn_fincommitinr_eqt.
40
41           total_loan_usd = total_loan_usd + ls_tran-forgn_fincommitusd_loan.
42           total_loan_euro  =  total_loan_euro  + ls_tran-forgn_fincommiteur_loan.
43           total_loan_gbp  = total_loan_gbp  + ls_tran-forgn_fincommitgbp_loan.
44           total_loan_eq_usd  = total_loan_eq_usd  + ls_tran-forgn_fincommitfcy_loan.
45           total_loan_eq_inr  = total_loan_eq_inr  + ls_tran-forgn_fincommitinr_loan.
46
47           total_pg_eq_usd = total_pg_eq_usd + ls_tran-forgn_fincommitfcy_pfgrnt.
48           total_pg_eq_inr = total_pg_eq_inr + ls_tran-forgn_fincommitinr_pfgrnt.
49
50           total_cg_eq_usd = total_cg_eq_usd + ls_tran-forgn_fincommitfcy_corgrnt.
51           total_cg_eq_inr = total_cg_eq_inr + ls_tran-forgn_fincommitinr_corgrnt.
52
53         ENDLOOP.
54
55       ELSE.
56
57         CLEAR lt_tran.
58
59         SELECT * FROM zjvc_cc_fcforms INTO TABLE @lt_tran WHERE ei_forgnenty_uin EQ @zjvc_cc_fcforms-ei_forgnenty_uin
60            AND doc_no LT  @zjvc_cc_fcforms-doc_no .
61     **    DELETE lt_tran WHERE doc_no EQ zjvc_cc_fcforms-doc_no.
62         LOOP AT lt_tran INTO ls_tran.
63           total_equity_usd  = total_equity_usd  + ls_tran-forgn_fincommitusd_eqt.
64           total_equity_euro = total_equity_euro + ls_tran-forgn_fincommiteur_eqt.
65           total_equity_gbp = total_equity_gbp + ls_tran-forgn_fincommitgbp_eqt.
66           total_equity_eq_usd = total_equity_eq_usd + ls_tran-forgn_fincommitfcy_eqt.
67           total_equity_eq_inr = total_equity_eq_inr + ls_tran-forgn_fincommitinr_eqt.
68
69           total_loan_usd = total_loan_usd + ls_tran-forgn_fincommitusd_loan.
70           total_loan_euro  =  total_loan_euro  + ls_tran-forgn_fincommiteur_loan.
71           total_loan_gbp  = total_loan_gbp  + ls_tran-forgn_fincommitgbp_loan.
72           total_loan_eq_usd  = total_loan_eq_usd  + ls_tran-forgn_fincommitfcy_loan.
73           total_loan_eq_inr  = total_loan_eq_inr  + ls_tran-forgn_fincommitinr_loan.
74
75           total_pg_eq_usd = total_pg_eq_usd + ls_tran-forgn_fincommitfcy_pfgrnt.
76           total_pg_eq_inr = total_pg_eq_inr + ls_tran-forgn_fincommitinr_pfgrnt.
77
78           total_cg_eq_usd = total_cg_eq_usd + ls_tran-forgn_fincommitfcy_corgrnt.
79           total_cg_eq_inr = total_cg_eq_inr + ls_tran-forgn_fincommitinr_corgrnt.
80         ENDLOOP.
81     *      SELECT SINGLE * FROM zjvc_total INTO @DATA(total) WHERE doc_no EQ @zjvc_cc_fcforms-doc_no.
82     *      IF sy-subrc EQ 0.
83     *
84     *        total_equity_usd  = total-equity_usd.
85     *        total_equity_euro = total-equity_euro.
86     *        total_equity_gbp = total-equity_gbp.
87     *        total_equity_eq_usd = total-equity_equivalent_usd.
88     *        total_equity_eq_inr = zjvc_total-equity_equivalent_inr.
89     *
90     *        total_loan_usd = total-loan_usd.
91     *        total_loan_euro = total-equity_euro.
92     *        total_loan_gbp = total-loan_gbp.
93     *        total_loan_eq_usd = total-equity_equivalent_usd.
94     *        total_loan_eq_inr = total-equity_equivalent_inr.
95     *
96     *        total_pg_eq_usd  = total-pg_equivalent_usd.
97     *        total_pg_eq_inr = total-pg_equivalent_inr.
98     *        total_cg_eq_usd = total-cg_equivalent_usd.
99     *        total_cg_eq_inr = total-cg_equivalent_inr.
100
101    *    ENDIF.
102      ENDIF.
103    *  ENDIF.
104
105
106      SELECT SINGLE * FROM bseg INTO @DATA(wa_bseg) WHERE bukrs = @wa_bkpf-bukrs  AND belnr = @wa_bkpf-belnr .
107      IF sy-subrc EQ 0 .
108
109
110
111
112      ENDIF.
113
114      IF  zjvc_cc_fcforms-forgn_fincommitusd_eqt IS NOT INITIAL OR zjvc_cc_fcforms-forgn_fincommiteur_eqt IS NOT INITIAL
115        OR zjvc_cc_fcforms-forgn_fincommitgbp_eqt IS NOT INITIAL OR zjvc_cc_fcforms-forgn_fincommitusd_loan IS NOT INITIAL OR zjvc_cc_fcforms-forgn_fincommiteur_loan  IS NOT INITIAL OR
116        zjvc_cc_fcforms-forgn_fincommitgbp_loan IS NOT INITIAL OR zjvc_cc_fcforms-forgn_fincommitfcy_loan IS NOT INITIAL OR zjvc_cc_fcforms-forgn_fincommitinr_loan IS NOT INITIAL
117        OR zjvc_cc_fcforms-forgn_fincommitusd_pfgrnt IS NOT INITIAL OR zjvc_cc_fcforms-forgn_fincommiteur_pfgrnt IS NOT INITIAL OR zjvc_cc_fcforms-forgn_fincommitfcy_pfgrnt IS NOT INITIAL
118        OR zjvc_cc_fcforms-forgn_fincommitinr_pfgrnt IS NOT INITIAL OR zjvc_cc_fcforms-forgn_fincommitusd_corgrnt IS NOT INITIAL OR zjvc_cc_fcforms-forgn_fincommiteur_corgrnt IS NOT INITIAL
119        OR zjvc_cc_fcforms-forgn_fincommitfcy_corgrnt IS NOT INITIAL OR zjvc_cc_fcforms-forgn_fincommitinr_corgrnt IS NOT INITIAL .
120        " for equity calculation .""""""""""""""
121        zjvc_total-equity_usd = temp-equity_usd +  zjvc_cc_fcforms-forgn_fincommitusd_eqt + total_equity_usd .
122        zjvc_total-equity_euro = temp-equity_euro + zjvc_cc_fcforms-forgn_fincommiteur_eqt + total_equity_euro.
123        zjvc_total-equity_gbp = temp-equity_gbp +  zjvc_cc_fcforms-forgn_fincommitgbp_eqt + total_equity_gbp.
124        zjvc_total-equity_equivalent_usd = temp-equity_equivalent_usd +  zjvc_cc_fcforms-forgn_fincommitfcy_eqt + total_equity_eq_usd ."equivalent_usd
125        zjvc_total-equity_equivalent_inr = temp-equity_equivalent_inr +  zjvc_cc_fcforms-forgn_fincommitinr_eqt +  total_equity_eq_inr."equivalent_inr
126
127        " for loan calculation """""""""""""
128
129        zjvc_total-loan_usd = temp-loan_usd + zjvc_cc_fcforms-forgn_fincommitusd_loan + total_loan_usd.
130        zjvc_total-loan_euro = temp-loan_euro + zjvc_cc_fcforms-forgn_fincommiteur_loan + total_loan_euro .
131        zjvc_total-loan_gbp = temp-loan_gbp + zjvc_cc_fcforms-forgn_fincommitgbp_loan + total_loan_gbp.
132        zjvc_total-loan_equivalent_usd = temp-loan_equivalent_usd + zjvc_cc_fcforms-forgn_fincommitfcy_loan  +  total_loan_eq_usd .
133        zjvc_total-loan_equivalent_inr = temp-loan_equivalent_inr + zjvc_cc_fcforms-forgn_fincommitinr_loan + total_loan_eq_inr.
134
135        " PG
136        zjvc_total-pg_equivalent_usd = temp-pg_usd  + zjvc_cc_fcforms-forgn_fincommitfcy_pfgrnt / 2 + total_pg_eq_usd  .
137        zjvc_total-pg_equivalent_inr = temp-pg_inr + zjvc_cc_fcforms-forgn_fincommitinr_pfgrnt / 2 +  total_pg_eq_inr.
138        zjvc_total-cg_equivalent_usd = temp-cg_usd + zjvc_cc_fcforms-forgn_fincommitfcy_corgrnt + total_cg_eq_usd .
139        zjvc_total-cg_equivalent_inr = temp-cg_inr + zjvc_cc_fcforms-forgn_fincommitinr_corgrnt +  total_cg_eq_inr.
140
141
142        CLEAR : zjvc_cc_fcforms-forgn_fincommitusd_ovltot , zjvc_cc_fcforms-forgn_fincommitinr_ovltot.
143
144
145        IF g_tcode NE 'ZJVCCFC2'  AND g_tcode NE 'ZJVCCFC3'AND g_tcode NE 'ZJVCCFC5'.
146          SELECT * FROM zjvc_cc_fcforms INTO TABLE @DATA(lt_tran1) .
147
148          LOOP AT lt_tran1 INTO DATA(ls_tran1).
149
150            total_equity_eq_usd1 = total_equity_eq_usd1 + ls_tran1-forgn_fincommitfcy_eqt + ls_tran1-forgn_fincommitfcy_loan + ls_tran1-forgn_fincommitfcy_pfgrnt / 2 + ls_tran1-forgn_fincommitfcy_corgrnt..
151            total_equity_eq_inr1 = total_equity_eq_inr1 + ls_tran1-forgn_fincommitinr_eqt + ls_tran1-forgn_fincommitinr_loan + ls_tran1-forgn_fincommitinr_pfgrnt / 2 + ls_tran1-forgn_fincommitinr_corgrnt..
152
153          ENDLOOP.
154
155
156        ELSE .
157          CLEAR: lt_tran1 , ls_tran1.
158          SELECT * FROM zjvc_cc_fcforms INTO TABLE @lt_tran1 WHERE doc_no LT  @zjvc_cc_fcforms-doc_no . .
159
160          LOOP AT lt_tran1 INTO ls_tran1.
161
162            total_equity_eq_usd1 = total_equity_eq_usd1 + ls_tran1-forgn_fincommitfcy_eqt + ls_tran1-forgn_fincommitfcy_loan + ls_tran1-forgn_fincommitfcy_pfgrnt / 2 + ls_tran1-forgn_fincommitfcy_corgrnt.
163            total_equity_eq_inr1 = total_equity_eq_inr1 + ls_tran1-forgn_fincommitinr_eqt + ls_tran1-forgn_fincommitinr_loan + ls_tran1-forgn_fincommitinr_pfgrnt / 2 + ls_tran1-forgn_fincommitinr_corgrnt.
164
165          ENDLOOP.
166
167        ENDIF.
168        zjvc_cc_fcforms-forgn_fincommitusd_ovltot = total_equity_eq_usd1 + ob_ovl-equivalent_usd + zjvc_cc_fcforms-forgn_fincommitfcy_eqt  + zjvc_cc_fcforms-forgn_fincommitfcy_loan + zjvc_cc_fcforms-forgn_fincommitfcy_pfgrnt / 2 +
169    zjvc_cc_fcforms-forgn_fincommitfcy_corgrnt.
170        zjvc_cc_fcforms-forgn_fincommitinr_ovltot = total_equity_eq_inr1 + ob_ovl-equivalent_inr + zjvc_cc_fcforms-forgn_fincommitinr_eqt + zjvc_cc_fcforms-forgn_fincommitinr_loan + zjvc_cc_fcforms-forgn_fincommitinr_pfgrnt / 2 +
171    zjvc_cc_fcforms-forgn_fincommitinr_corgrnt.
172
173        CLEAR :  total_equity_usd , total_equity_euro ,total_equity_gbp, total_equity_eq_usd , total_equity_eq_inr ,
174        total_loan_usd,total_loan_euro , total_loan_gbp ,total_loan_eq_usd ,total_loan_eq_inr , total_pg_eq_usd,total_pg_eq_inr,
175        total_cg_eq_usd ,total_cg_eq_inr,total_equity_eq_usd1 ,total_equity_eq_inr1 .
176
177      ENDIF.
178
179
180
181    ENDMODULE.
*--- End of MZPSJVCCFCFORMS_USER_COMMANI01 - 181 lines ---

----------------------------------------------------------------------------------------------------
Include          MZPSJVCCFCFORMS_STATUS_9001O01            Level 1    Page 8
Object           SAPMZPSJVCCFCFORMS                        Lines 12
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:21
----------------------------------------------------------------------------------------------------
1      *----------------------------------------------------------------------*
2      ***INCLUDE MZPSJVCCFCFORMS_STATUS_9001O01.
3      *----------------------------------------------------------------------*
4      *&---------------------------------------------------------------------*
5      *&      Module  STATUS_9001  OUTPUT
6      *&---------------------------------------------------------------------*
7      *       text
8      *----------------------------------------------------------------------*
9      MODULE status_9001 OUTPUT.
10       SET PF-STATUS '0105'.
11       SET TITLEBAR 'T001'.
12     ENDMODULE.
*--- End of MZPSJVCCFCFORMS_STATUS_9001O01 - 12 lines ---

----------------------------------------------------------------------------------------------------
Include          MZPSJVCCFCFORMS_USER_COMMANI02            Level 1    Page 9
Object           SAPMZPSJVCCFCFORMS                        Lines 18
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:21
----------------------------------------------------------------------------------------------------
1      *----------------------------------------------------------------------*
2      ***INCLUDE MZPSJVCCFCFORMS_USER_COMMANI02.
3      *----------------------------------------------------------------------*
4      *&---------------------------------------------------------------------*
5      *&      Module  USER_COMMAND_9001  INPUT
6      *&---------------------------------------------------------------------*
7      *       text
8      *----------------------------------------------------------------------*
9      MODULE user_command_9001 INPUT.
10       CASE sy-ucomm.
11         WHEN 'BACK' OR 'EXIT' OR 'CANC'.
12           CLEAR zjvc_cc_fcforms.
13           LEAVE TO SCREEN '0100'.
14
15         WHEN 'SUB1'.
16           CALL SCREEN '0110'.
17       ENDCASE.
18     ENDMODULE.
*--- End of MZPSJVCCFCFORMS_USER_COMMANI02 - 18 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CABAP                                   Level 1    Page 10
Object           SAPMZPSJVCCFCFORMS                        Lines 360
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:21
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
Generated incl.  %_CCXTAB                                  Level 1    Page 11
Object           SAPMZPSJVCCFCFORMS                        Lines 6
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:21
----------------------------------------------------------------------------------------------------
1      TYPE-POOL CXTAB .
2
3      TYPES:
4             CXTAB_COLUMN type scxtab_column,
5             CXTAB_CONTROL type scxtab_control,
6             CXTAB_TABSTRIP type scxtab_tabstrip.
*--- End of %_CCXTAB - 6 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  <CONTRO>                                  Level 1    Page 12
Object           SAPMZPSJVCCFCFORMS                        Lines 76
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:21
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
Object           SAPMZPSJVCCFCFORMS                        Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:14:21
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
