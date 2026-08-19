----------------------------------------------------------------------------------------------------
Main program     ZTRM_POST_AMORTIZTION_FRX                 Level 0    Page 1
Object           ZTRM_POST_AMORTIZTION_FRX                 Lines 21
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:11
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *& Report  ZTRM_POST_AMORTIZTION_FRX
3      *&
4      *&---------------------------------------------------------------------*
5      *&                          |
6      *&Author : shubham Pamecha  | Post amortization for FOREX Valuation
7      *&Date   : 26/06/2016       | call of bapi_acc_document_post
8      *&                          | TRM posting on basis of update type and key date gl account cost centre
9      *&                          |
10     *&---------------------------------------------------------------------*
11
12     **** Include decalaration
13
14     **** Top decalaration all the types and data decalaration
15     INCLUDE ztrm_post_amortiztion_frx_top.
16
17     **** E01 decalaration all the vaidation in performs
18     INCLUDE ztrm_post_amortiztion_frx_e01.
19
20     **** F01 decalaration all the forms process and get data and processing logic BAPI call
21     INCLUDE ztrm_post_amortiztion_frx_f01.
*--- End of ZTRM_POST_AMORTIZTION_FRX - 21 lines ---

----------------------------------------------------------------------------------------------------
Include          ZTRM_POST_AMORTIZTION_FRX_TOP             Level 1    Page 2
Object           ZTRM_POST_AMORTIZTION_FRX                 Lines 110
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:11
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&  Include           ZTRM_POST_AMORTIZTION_FRX_TOP
3      *&---------------------------------------------------------------------*
4      REPORT ztrm_post_amortiztion_frx.
5
6      *** table declaration
7      TABLES : trgs_position_selection,trlt_flow,trlt_transaction,faglflexa,csks.
8
9      *** types declartation
10     TYPES: BEGIN OF ty_pos,
11              os_guid                    TYPE dift_pos_ident-os_guid,
12              context                    TYPE dift_pos_ident-context,
13              identified_oid             TYPE dift_pos_ident-identified_oid,
14              company_code               TYPE dift_pos_ident-company_code,
15              security_id                TYPE dift_pos_ident-security_id,
16            END OF ty_pos,
17
18
19            BEGIN OF ty_final,
20              days                       TYPE char5,
21              p_days                     TYPE char5,
22              amount                     TYPE char10,
23              a_amt                      TYPE char10,
24            END OF ty_final,
25
26            BEGIN OF ty_select,
27              value                      TYPE char10,
28            END OF ty_select,
29
30            BEGIN OF  ty_log,
31              id                         TYPE char10,
32              number                     TYPE char10,
33              message                    TYPE char10,
34            END OF ty_log.
35
36     *** End of type defination
37
38
39     *** data table declaration
40     DATA : gt_pos                       TYPE TABLE OF ty_pos,
41            gt_flow                      TYPE TABLE OF trlt_flow,
42            gt_value                     TYPE TABLE OF ty_select,
43            gt_flow1                     TYPE TABLE OF trlt_flow,
44            gt_final                     TYPE TABLE OF ty_final,
45            gt_ztr_frdtx_amt             TYPE TABLE OF ztr_frdtx_amt.
46     *** End data declaration
47
48     *** data table declaration
49     DATA : gs_pos                       TYPE   ty_pos,
50            gs_flow                      TYPE   trlt_flow,
51            gs_value                     TYPE   ty_select,
52            gs_flow1                     TYPE   trlt_flow,
53            gs_final                     TYPE   ty_final.
54
55     DATA : obj_type                     TYPE bapiache09-obj_type,
56            obj_key                      TYPE bapiache09-obj_key,
57            obj_sys                      TYPE bapiache09-obj_sys.
58     *** End data declaration
59
60
61     ***  Bapi data declaration
62     DATA : lt_return                    TYPE TABLE OF bapiret2,
63            lt_return_f                  TYPE TABLE OF bapiret2,
64            gt_accountgl                 TYPE TABLE OF bapiacgl09,
65            gt_curr                      TYPE TABLE OF bapiaccr09.
66     DATA : gs_header                    TYPE          bapiache09,
67            gs_accountgl                 TYPE          bapiacgl09,
68            gs_curr                      TYPE          bapiaccr09,
69            ls_return                    TYPE          bapiret2,
70            ls_return_f                  TYPE          bapiret2.
71
72     *** end declaration
73
74
75     DATA : git_alv                      TYPE TABLE OF zfi_s_alv,
76            gt_fld                       TYPE TABLE OF slis_fieldcat_alv,
77            gt_log                       TYPE TABLE OF ztr_frdtx_amt.
78
79     DATA : ls_alv                       TYPE          zfi_s_alv,
80            gs_fld                       TYPE          slis_fieldcat_alv,
81            gs_log                       TYPE          ztr_frdtx_amt.
82     *** Selection screen defination and with title of frame
83
84     SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
85     ***  select option defination
86     SELECT-OPTIONS : s_bukrs            FOR trgs_position_selection-company_code OBLIGATORY NO-EXTENSION NO INTERVALS ,
87                      s_id               FOR trgs_position_selection-security_id OBLIGATORY,
88                      s_acc_n            FOR trgs_position_selection-security_account OBLIGATORY NO-EXTENSION NO INTERVALS ,
89                      s_date             FOR trlt_transaction-trldate OBLIGATORY NO-EXTENSION NO INTERVALS ,
90                      s_cntr             FOR csks-kostl NO-EXTENSION NO INTERVALS OBLIGATORY.
91     PARAMETERS    :  p_change           TYPE char1 AS CHECKBOX DEFAULT ' ' USER-COMMAND a.
92
93     SELECT-OPTIONS : s_u_typ            FOR trlt_flow-flowtype NO INTERVALS DEFAULT 'V202' TO 'V203'  ,
94                      s_a_gl             FOR faglflexa-racct NO-EXTENSION NO INTERVALS DEFAULT '201732',
95                      s_f_gl             FOR faglflexa-racct NO-EXTENSION NO INTERVALS DEFAULT '160213'.
96
97
98     PARAMETERS   :   p_test             TYPE char1 AS CHECKBOX DEFAULT ' '.
99
100    *** end of select oprion declaration
101
102    SELECTION-SCREEN END OF BLOCK b1.
103
104    *** End of selection screen defination
105
106
107    s_u_typ-sign   = 'I'.
108    s_u_typ-option = 'EQ'.
109    s_u_typ-low    = 'SAM7100'.
110    APPEND s_u_typ.
*--- End of ZTRM_POST_AMORTIZTION_FRX_TOP - 110 lines ---

----------------------------------------------------------------------------------------------------
Include          ZTRM_POST_AMORTIZTION_FRX_E01             Level 1    Page 3
Object           ZTRM_POST_AMORTIZTION_FRX                 Lines 49
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:11
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&  Include           ZTRM_POST_AMORTIZTION_FRX_E01
3      *&---------------------------------------------------------------------*
4
5
6      AT SELECTION-SCREEN OUTPUT.
7        IF p_change IS INITIAL.
8          LOOP AT SCREEN.
9            IF screen-name EQ 'S_U_TYP-LOW' OR screen-name EQ 'S_A_GL-LOW' OR screen-name EQ 'S_F_GL-LOW' OR SCREEN-NAME EQ '%_S_U_TYP_%_APP_%-TEXT'
10             OR SCREEN-NAME EQ '%_S_A_GL_%_APP_%-TEXT' OR SCREEN-NAME EQ '%_S_F_GL_%_APP_%-TEXT' OR SCREEN-NAME EQ '%_S_U_TYP_%_APP_%-OPTI_PUSH' OR SCREEN-NAME EQ '%_S_U_TYP_%_APP_%-VALU_PUSH'.
11             screen-invisible = 1.
12             screen-ACTIVE = 0.
13             MODIFY SCREEN .
14           ENDIF.
15         ENDLOOP.
16       ENDIF.
17
18     **** Start of selection fdor prcessing data fetch
19     START-OF-SELECTION .
20
21
22       SELECT * from ZTR_FRDTX_AMT
23         into TABLE gt_ZTR_FRDTX_AMT
24         WHERE ZBUKRS       in s_bukrs
25           and ZID          in s_id
26           and ZACCOUNT     in s_acc_n
27           and ZUPDATE_TYPE in s_u_typ
28           and ZDATE        le s_date.
29
30      if sy-subrc eq 0.
31        MESSAGE 'Posting has already been done' TYPE 'E' DISPLAY LIKE 'I'.
32        endif.
33
34
35     **** fetch data
36       PERFORM get_data.
37     **** End fetch data
38
39     **** Process Data
40       PERFORM process_data.
41     **** End of prcess data
42
43     **** Call Bapi
44       PERFORM call_bapi.
45     ****  end bapi call
46
47     **** Call alv
48       PERFORM display_alv.
49     **** end call
*--- End of ZTRM_POST_AMORTIZTION_FRX_E01 - 49 lines ---

----------------------------------------------------------------------------------------------------
Include          ZTRM_POST_AMORTIZTION_FRX_F01             Level 1    Page 4
Object           ZTRM_POST_AMORTIZTION_FRX                 Lines 359
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:11
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&  Include           ZTRM_POST_AMORTIZTION_FRX_F01
3      *&---------------------------------------------------------------------*
4      *&---------------------------------------------------------------------*
5      *&      Form  GET_DATA
6      *&---------------------------------------------------------------------*
7      *       text
8      *----------------------------------------------------------------------*
9      *  -->  p1        text
10     *  <--  p2        text
11     *----------------------------------------------------------------------*
12     FORM get_data .
13     *** Selection form dift_pos_ident table
14       SELECT os_guid context identified_oid company_code security_id
15         FROM dift_pos_ident
16         INTO TABLE gt_pos
17         WHERE company_code IN s_bukrs
18           AND security_id  IN s_id
19           AND context      EQ 'TRL'
20           AND accounting_code IN s_acc_n.
21     *** sy-subrc check that si successfull check
22       IF sy-subrc EQ 0.
23     *** select from trlt_flow for amount
24         SELECT *
25           FROM trlt_flow
26           INTO TABLE gt_flow
27           FOR ALL ENTRIES IN gt_pos
28           WHERE position_oid EQ gt_pos-identified_oid
29            AND  flowtype     IN s_u_typ.
30         "AND  trldate      LE s_date-low.
31
32         SELECT *
33          FROM trlt_flow
34          INTO TABLE gt_flow1
35           FOR ALL ENTRIES IN gt_pos
36           WHERE  position_oid EQ gt_pos-identified_oid
37            AND   flowtype     IN s_u_typ
38           AND    trldate        LE s_date-low.
39     *** end condition type
40
41
42       ENDIF.
43
44     ENDFORM.
45     *&---------------------------------------------------------------------*
46     *&      Form  PROCESS_DATA
47     *&---------------------------------------------------------------------*
48     *       text
49     *----------------------------------------------------------------------*
50     *  -->  p1        text
51     *  <--  p2        text
52     *----------------------------------------------------------------------*
53     FORM process_data .
54       DATA : lv_mat_date TYPE p0001-begda,
55              lv_last_dat TYPE p0001-begda,
56              lv_diff     TYPE p.
57
58       CLEAR : gs_pos.
59       LOOP AT   gt_pos INTO gs_pos WHERE    company_code IN s_bukrs
60                                      AND    security_id  IN  s_id
61                                      AND    context      = 'TRL'.
62
63         CLEAR : gs_flow.
64         LOOP AT gt_flow1 INTO gs_flow1 WHERE position_oid = gs_pos-identified_oid.
65           gs_final-amount = gs_final-amount + gs_flow1-valuation_amt.
66         ENDLOOP.
67
68         CLEAR : gs_flow.
69         READ TABLE gt_flow INTO gs_flow WITH KEY  position_oid = gs_pos-identified_oid
70                                                   flowtype     = 'SAM7100'.
71         IF sy-subrc EQ 0.
72           lv_mat_date = gs_flow-trldate.
73         ENDIF.
74
75         SORT gt_flow BY trldate DESCENDING.
76         DELETE gt_flow WHERE flowtype NE 'V202' AND flowtype NE 'V203'.
77         CLEAR : gs_flow.
78         READ TABLE gt_flow INTO gs_flow WITH KEY  position_oid = gs_pos-identified_oid.
79         IF sy-subrc EQ 0.
80           lv_last_dat = gs_flow-trldate.
81         ENDIF.
82
83         IF lv_mat_date IS NOT INITIAL AND lv_last_dat IS NOT INITIAL.
84           CLEAR : lv_diff.
85
86           CALL FUNCTION '/SDF/CMO_DATETIME_DIFFERENCE'
87             EXPORTING
88               date1            = lv_mat_date
89               date2            = lv_last_dat
90             IMPORTING
91               datediff         = lv_diff
92             EXCEPTIONS
93               invalid_datetime = 1
94               OTHERS           = 2.
95           IF sy-subrc = 0.
96             gs_final-days = lv_diff.
97     * Implement suitable error handling here
98           ENDIF.
99
100          IF s_date-low IS NOT INITIAL AND lv_last_dat IS  NOT INITIAL .
101            CLEAR : lv_diff.
102
103            CALL FUNCTION '/SDF/CMO_DATETIME_DIFFERENCE'
104              EXPORTING
105                date1            = s_date-low
106                date2            = lv_last_dat
107              IMPORTING
108                datediff         = lv_diff
109              EXCEPTIONS
110                invalid_datetime = 1
111                OTHERS           = 2.
112            IF sy-subrc = 0.
113              gs_final-p_days = lv_diff.
114    * Implement suitable error handling here
115            ENDIF.
116          ENDIF.
117        ENDIF.
118
119        IF gs_final-amount IS NOT INITIAL.
120          gs_final-a_amt = ( gs_final-amount /  ( gs_final-days * gs_final-p_days ) ).
121        ENDIF.
122        IF gs_final-a_amt IS NOT INITIAL.
123          APPEND gs_final TO gt_final.
124        ENDIF.
125        CLEAR : gs_final.
126
127      ENDLOOP.
128    ENDFORM.
129    *&---------------------------------------------------------------------*
130    *&      Form  CALL_BAPI
131    *&---------------------------------------------------------------------*
132    *       text
133    *----------------------------------------------------------------------*
134    *  -->  p1        text
135    *  <--  p2        text
136    *----------------------------------------------------------------------*
137    FORM call_bapi.
138      DATA : lv_curr TYPE waers VALUE 'INR',
139             lv_text TYPE char255.
140
141      CLEAR : gs_final.
142      LOOP AT gt_final INTO gs_final.
143        CLEAR gs_header.
144        gs_header-obj_type    = 'BKPFF'.
145        gs_header-doc_date    = s_date-low.
146        gs_header-pstng_date  = s_date-low.
147        gs_header-doc_type    = 'SA'.
148        gs_header-comp_code   = s_bukrs-low.
149        gs_header-header_txt  = 'Fcmitda Amortization'.
150        gs_header-ref_doc_no  = s_id-low.
151        gs_header-username    = sy-uname.
152
153        CLEAR : lv_text.
154        CONCATENATE 'Day Matry' gs_final-days
155                    'Ptg Day' gs_final-p_days
156                    'Base Amt' gs_final-amount
157                     INTO lv_text SEPARATED BY space.
158        CLEAR gs_log.
159        gs_log-zbukrs        = s_bukrs-low.
160        gs_log-zid           = s_id-low.
161        gs_log-zaccount      = s_acc_n-low.
162        gs_log-zupdate_type  = s_u_typ-low.
163        gs_log-zbase_amnt    = gs_final-amount.
164        gs_log-zdays_mat     = gs_final-days.
165        gs_log-zpst_day      = gs_final-p_days.
166        gs_log-zamrt_amt     = gs_final-a_amt.
167        gs_log-zdate         = sy-datum.
168        gs_log-ztime         = sy-uzeit.
169
170        gs_accountgl-itemno_acc = 1.
171
172        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
173          EXPORTING
174            input  = s_a_gl-low
175          IMPORTING
176            output = s_a_gl-low.
177
178        gs_accountgl-gl_account = s_a_gl-low.
179        gs_accountgl-bus_area   = 'JV'.
180        gs_accountgl-costcenter = s_cntr-low.
181        gs_accountgl-item_text  = lv_text.
182        APPEND gs_accountgl TO gt_accountgl.
183        CLEAR gs_accountgl.
184
185
186        gs_curr-itemno_acc  = 1.
187        gs_curr-currency    = lv_curr.
188    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
189    *    gs_curr-amt_doccur  = gs_final-a_amt.
190        gs_curr-amt_doccur = CONV #( gs_final-a_amt ).
191    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
192        APPEND gs_curr TO gt_curr.
193        CLEAR : gs_curr.
194
195        gs_accountgl-itemno_acc = 2.
196        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
197          EXPORTING
198            input  = s_f_gl-low
199          IMPORTING
200            output = s_f_gl-low.
201        gs_accountgl-gl_account = s_f_gl-low.
202        gs_accountgl-alloc_nmbr   = 'Fcmitda Amortization'.
203
204        APPEND gs_accountgl TO gt_accountgl.
205        CLEAR : gs_accountgl.
206
207        gs_curr-itemno_acc  = 2.
208        gs_curr-currency    = lv_curr.
209    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
210    *    gs_curr-amt_doccur  =  gs_final-a_amt * -1.
211        gs_curr-amt_doccur = CONV #( gs_final-a_amt * -1 ).
212    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
213        APPEND gs_curr TO gt_curr.
214        CLEAR : gs_curr.
215
216
217        REFRESH lt_return.
218        CLEAR : obj_type,
219                obj_key,
220                obj_sys.
221
222    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
223        CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'  "#EC CI_USAGE_OK
224            "#EC CI_USAGE_OK[2628704]
225      "#EC CI_USAGE_OK[2438131]
226
227    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
228          EXPORTING
229            documentheader = gs_header
230          IMPORTING
231            obj_type       = obj_type
232            obj_key        = obj_key
233            obj_sys        = obj_sys
234          TABLES
235            accountgl      = gt_accountgl
236            currencyamount = gt_curr
237            return         = lt_return.
238
239        CLEAR : ls_return.
240        LOOP AT lt_return INTO ls_return.
241          ls_return_f = ls_return.
242          APPEND ls_return_f TO lt_return_f.
243        ENDLOOP.
244    ****  IF document is posted succesfully commit the tranaction.
245
246        IF p_test IS INITIAL.
247          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
248            EXPORTING
249              wait = 'X'.
250        ENDIF.
251      ENDLOOP.
252
253
254      CLEAR : ls_return.
255
256
257      LOOP AT lt_return_f INTO ls_return_f WHERE ( type = 'S' OR type = 'E' ).
258        CLEAR : ls_alv.
259        IF ls_return_f-type EQ 'S' AND ls_return_f-number = '605' AND ls_return_f-id = 'RW' .
260          ls_alv-icon =  '@08@'.   "FOR GREEN COLOR
261
262          MOVE-CORRESPONDING ls_return_f TO ls_alv.
263          APPEND ls_alv TO git_alv.
264          CLEAR ls_alv.
265          IF p_test IS INITIAL.
266            APPEND gs_log TO gt_log.
267            IF gt_log IS NOT INITIAL.
268              MODIFY ztr_frdtx_amt FROM TABLE gt_log.
269            ENDIF.
270          ENDIF.
271
272        ELSEIF ls_return_f-type EQ 'E' AND ls_return_f-number <> '609' .
273          ls_alv-icon = '@0A@'.    "FOR RED COLOR
274          MOVE-CORRESPONDING ls_return_f TO ls_alv.
275
276          APPEND ls_alv TO git_alv.
277          CLEAR ls_alv.
278        ENDIF.
279
280      ENDLOOP.
281
282    ENDFORM.
283    *&---------------------------------------------------------------------*
284    *&      Form  DISPLAY_ALV
285    *&---------------------------------------------------------------------*
286    *       text
287    *----------------------------------------------------------------------*
288    *  -->  p1        text
289    *  <--  p2        text
290    *----------------------------------------------------------------------*
291    FORM display_alv .
292
293      DATA : ls_fld TYPE slis_fieldcat_alv.
294      CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
295        EXPORTING
296          i_program_name         = sy-repid
297          i_structure_name       = 'ZFI_S_ALV'
298          i_client_never_display = 'X'
299        CHANGING
300          ct_fieldcat            = gt_fld
301        EXCEPTIONS
302          inconsistent_interface = 1
303          program_error          = 2
304          OTHERS                 = 3.
305      IF sy-subrc <> 0.
306    * Implement suitable error handling here
307      ELSE.
308        LOOP AT gt_fld INTO gs_fld .
309          IF  gs_fld-fieldname EQ 'INDEX' OR gs_fld-fieldname EQ 'BUKRS_NEW' OR gs_fld-fieldname EQ 'BELNR_NEW' OR gs_fld-fieldname EQ 'GJAHR_NEW'
310              OR gs_fld-fieldname EQ 'BUKRS' OR gs_fld-fieldname EQ 'BELNR' OR  gs_fld-fieldname EQ  'GJAHR' OR gs_fld-fieldname EQ 'BLART'.
311            gs_fld-no_out = 'X' .
312            MODIFY gt_fld FROM gs_fld .
313          ENDIF.
314        ENDLOOP .
315      ENDIF.
316
317      CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
318        EXPORTING
319          i_callback_program     = sy-repid
320          i_callback_top_of_page = 'TOP_OF_PAGE'  "see FORM
321          it_fieldcat            = gt_fld[]
322          i_save                 = 'X'
323        TABLES
324          t_outtab               = git_alv
325        EXCEPTIONS
326          program_error          = 1
327          OTHERS                 = 2.
328      IF sy-subrc <> 0.
329        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
330                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
331      ENDIF.
332
333    ENDFORM.
334
335    FORM top_of_page.
336    *ALV Header declarations
337      DATA: lt_header  TYPE slis_t_listheader,
338            lwa_header TYPE slis_listheader.
339
340    * Title
341      lwa_header-typ  = 'H'.
342      lwa_header-info = text-003.
343      APPEND lwa_header TO lt_header.
344      CLEAR lwa_header.
345
346    *   date
347      lwa_header-typ  = 'S'.
348      lwa_header-key = text-007.
349      CONCATENATE  sy-datum+6(2) '.'
350                   sy-datum+4(2) '.'
351                   sy-datum(4) INTO lwa_header-info.   "todays date
352      APPEND lwa_header TO lt_header.
353      CLEAR: lwa_header.
354
355
356      CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
357        EXPORTING
358          it_list_commentary = lt_header.
359    ENDFORM.
*--- End of ZTRM_POST_AMORTIZTION_FRX_F01 - 359 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CABAP                                   Level 1    Page 5
Object           ZTRM_POST_AMORTIZTION_FRX                 Lines 360
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:11
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
Generated incl.  %_CSLIS                                   Level 1    Page 6
Object           ZTRM_POST_AMORTIZTION_FRX                 Lines 543
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:11
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
Generated incl.  <REPINI>                                  Level 1    Page 7
Object           ZTRM_POST_AMORTIZTION_FRX                 Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:11
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
Object           ZTRM_POST_AMORTIZTION_FRX                 Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:11
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
Object           ZTRM_POST_AMORTIZTION_FRX                 Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:11
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
Generated incl.  DB__SSEL                                  Level 1    Page 10
Object           ZTRM_POST_AMORTIZTION_FRX                 Lines 1
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:11
----------------------------------------------------------------------------------------------------
1      * INCLUDE DB__SSEL
*--- End of DB__SSEL - 1 lines ---
