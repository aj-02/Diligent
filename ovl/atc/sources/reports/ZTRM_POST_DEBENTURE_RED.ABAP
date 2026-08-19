----------------------------------------------------------------------------------------------------
Main program     ZTRM_POST_DEBENTURE_RED                   Level 0    Page 1
Object           ZTRM_POST_DEBENTURE_RED                   Lines 21
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:13
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
15     INCLUDE ZTRM_POST_DEBENTURE_RED_TOP.
16
17     **** E01 decalaration all the vaidation in performs
18     INCLUDE ZTRM_POST_DEBENTURE_RED_E01.
19
20     **** F01 decalaration all the forms process and get data and processing logic BAPI call
21     INCLUDE ZTRM_POST_DEBENTURE_RED_F01.
*--- End of ZTRM_POST_DEBENTURE_RED - 21 lines ---

----------------------------------------------------------------------------------------------------
Include          ZTRM_POST_DEBENTURE_RED_TOP               Level 1    Page 2
Object           ZTRM_POST_DEBENTURE_RED                   Lines 114
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:13
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&  Include           ZTRM_POST_AMORTIZTION_FRX_TOP
3      *&---------------------------------------------------------------------*
4      REPORT ztrm_post_amortiztion_frx.
5
6      *** table declaration
7      TABLES : trgs_position_selection,trlt_flow,trlt_transaction,faglflexa,csks,DIFT_POS_IDENT.
8
9      *** types declartation
10     TYPES: BEGIN OF ty_pos,
11              os_guid        TYPE dift_pos_ident-os_guid,
12              context        TYPE dift_pos_ident-context,
13              identified_oid TYPE dift_pos_ident-identified_oid,
14              company_code   TYPE dift_pos_ident-company_code,
15              security_id    TYPE dift_pos_ident-security_id,
16            END OF ty_pos,
17
18
19            BEGIN OF ty_final,
20              days   TYPE char5,
21              p_days TYPE char5,
22              amount TYPE char10,
23              a_amt  TYPE char10,
24              CURR   TYPE CHAR3,
25            END OF ty_final,
26
27            BEGIN OF ty_select,
28              value TYPE char10,
29            END OF ty_select,
30
31            BEGIN OF  ty_log,
32              id      TYPE char10,
33              number  TYPE char10,
34              message TYPE char10,
35            END OF ty_log.
36
37
38
39     *** End of type defination
40
41
42     *** data table declaration
43     DATA : gt_pos         TYPE TABLE OF ty_pos,
44            gt_flow        TYPE TABLE OF trlt_flow,
45            gt_value       TYPE TABLE OF ty_select,
46            gt_flow1       TYPE TABLE OF trlt_flow,
47            gt_final       TYPE TABLE OF ty_final,
48            gt_ztr_deb_red TYPE TABLE OF ztr_deb_red.
49     *** End data declaration
50
51     *** data table declaration
52     DATA : gs_pos    TYPE   ty_pos,
53            gs_flow   TYPE   trlt_flow,
54            gs_value  TYPE   ty_select,
55            gs_flow1  TYPE   trlt_flow,
56            gs_final  TYPE   ty_final.
57
58
59     DATA : obj_type TYPE bapiache09-obj_type,
60            obj_key  TYPE bapiache09-obj_key,
61            obj_sys  TYPE bapiache09-obj_sys.
62     *** End data declaration
63
64
65     ***  Bapi data declaration
66     DATA : lt_return    TYPE TABLE OF bapiret2,
67            lt_return_f  TYPE TABLE OF bapiret2,
68            gt_accountgl TYPE TABLE OF bapiacgl09,
69            gt_curr      TYPE TABLE OF bapiaccr09.
70     DATA : gs_header    TYPE          bapiache09,
71            gs_accountgl TYPE          bapiacgl09,
72            gs_curr      TYPE          bapiaccr09,
73            ls_return    TYPE          bapiret2,
74            ls_return_f  TYPE          bapiret2.
75
76     *** end declaration
77
78
79     DATA : git_alv TYPE TABLE OF zfi_s_alv,
80            gt_fld  TYPE TABLE OF slis_fieldcat_alv,
81            gt_log  TYPE TABLE OF ztr_deb_red.
82
83     DATA : ls_alv TYPE          zfi_s_alv,
84            gs_fld TYPE          slis_fieldcat_alv,
85            gs_log TYPE          ztr_deb_red.
86     DATA : lv_ans TYPE answer.
87     *** Selection screen defination and with title of frame
88
89     SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
90     ***  select option defination
91     SELECT-OPTIONS : s_bukrs FOR trgs_position_selection-company_code OBLIGATORY NO-EXTENSION NO INTERVALS ,
92                      s_id    FOR trgs_position_selection-security_id OBLIGATORY,
93                      s_acc_n FOR trgs_position_selection-security_account OBLIGATORY NO-EXTENSION NO INTERVALS ,
94                      s_date  FOR trlt_transaction-trldate OBLIGATORY NO-EXTENSION NO INTERVALS .
95     *                 s_cntr  FOR csks-kostl NO-EXTENSION NO INTERVALS OBLIGATORY.
96     PARAMETERS    :  p_change TYPE char1 AS CHECKBOX DEFAULT ' ' USER-COMMAND a.
97
98     SELECT-OPTIONS : s_u_typ FOR trlt_flow-flowtype NO INTERVALS DEFAULT 'SE1200'  ,
99                      s_a_gl  FOR faglflexa-racct NO-EXTENSION NO INTERVALS DEFAULT '160206',
100                     s_f_gl  FOR faglflexa-racct NO-EXTENSION NO INTERVALS DEFAULT '160209',
101                     S_PRCTR FOR CSKS-PRCTR           NO INTERVALS NO-EXTENSION DEFAULT 'OVLJVCORP',
102                     s_val   for DIFT_POS_IDENT-VALUATION_AREA NO INTERVALS NO-EXTENSION  DEFAULT '001' .
103    PARAMETERS   :   p_test  TYPE char1 AS CHECKBOX DEFAULT ' '.
104
105    *** end of select oprion declaration
106
107    SELECTION-SCREEN END OF BLOCK b1.
108
109    *** End of selection screen defination
110
111    s_u_typ-sign   = 'I'.
112    s_u_typ-option = 'EQ'.
113    s_u_typ-low    = 'SAM7100'.
114    APPEND s_u_typ.
*--- End of ZTRM_POST_DEBENTURE_RED_TOP - 114 lines ---

----------------------------------------------------------------------------------------------------
Include          ZTRM_POST_DEBENTURE_RED_E01               Level 1    Page 3
Object           ZTRM_POST_DEBENTURE_RED                   Lines 92
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:13
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&  Include           ZTRM_POST_AMORTIZTION_FRX_E01
3      *&---------------------------------------------------------------------*
4      ************************************************************************
5      * E V E N T : A T S E L E C T I O N S C R E E N O U T P U T *
6      ************************************************************************
7
8      AT SELECTION-SCREEN OUTPUT.
9        IF p_change IS INITIAL.
10         LOOP AT SCREEN.
11           IF screen-name EQ 'S_U_TYP-LOW' OR screen-name EQ 'S_A_GL-LOW' OR screen-name EQ 'S_F_GL-LOW' OR screen-name EQ '%_S_U_TYP_%_APP_%-TEXT'
12             OR screen-name EQ '%_S_A_GL_%_APP_%-TEXT' OR screen-name EQ '%_S_F_GL_%_APP_%-TEXT'
13              OR screen-name EQ '%_S_U_TYP_%_APP_%-OPTI_PUSH' OR screen-name EQ '%_S_U_TYP_%_APP_%-VALU_PUSH' OR screen-name EQ 'S_PRCTR-LOW' OR screen-name EQ '%_S_PRCTR_%_APP_%-TEXT'
14             OR screen-name EQ 'S_VAL-LOW' OR  screen-name EQ '%_S_VAL_%_APP_%-TEXT'.
15             screen-invisible = 1.
16             screen-active = 0.
17             MODIFY SCREEN .
18           ENDIF.
19         ENDLOOP.
20       ENDIF.
21
22     ************************************************************************
23     * E V E N T : S T A R T O F S E L E C T I O N *
24     ************************************************************************
25
26     **** Start of selection fdor prcessing data fetch
27     START-OF-SELECTION .
28       SELECT * FROM ztr_deb_red
29          INTO TABLE   gt_ztr_deb_red
30          WHERE zbukrs       IN s_bukrs
31            AND zid          IN s_id
32            AND zaccount     IN s_acc_n
33            AND zkey_date    gE s_date-low.
34     *       AND zdate        EQ sy-datum
35     *       AND ztime        EQ sy-uzeit.
36
37       IF sy-subrc EQ 0.
38
39
40         CLEAR : lv_ans.
41         CALL FUNCTION 'POPUP_TO_CONFIRM'
42           EXPORTING
43             titlebar              = 'Aprove/Reject'
44             text_question         = 'Posting has already been done do you want to continue'
45             text_button_1         = 'Yes'
46             text_button_2         = 'No'
47             display_cancel_button = ''
48           IMPORTING
49             answer                = lv_ans.
50
51
52         IF lv_ans EQ '1'.
53
54     **** fetch data
55           PERFORM get_data.
56     **** End fetch data
57
58     **** Process Data
59           PERFORM process_data.
60     **** End of prcess data
61
62     **** Call Bapi
63           PERFORM call_bapi.
64     ****  end bapi call
65
66     **** Call alv
67     *  PERFORM display_alv.
68     **** end call
69
70         ELSE.
71
72         ENDIF.
73
74       ELSEIF sy-subrc NE 0.
75
76     *      **** fetch data
77
78         PERFORM get_data.
79     **** End fetch data
80
81     **** Process Data
82         PERFORM process_data.
83     **** End of prcess data
84
85     **** Call Bapi
86         PERFORM call_bapi.
87     ****  end bapi call
88
89     **** Call alv
90     *  PERFORM display_alv.
91     **** end call
92       ENDIF.
*--- End of ZTRM_POST_DEBENTURE_RED_E01 - 92 lines ---

----------------------------------------------------------------------------------------------------
Include          ZTRM_POST_DEBENTURE_RED_F01               Level 1    Page 4
Object           ZTRM_POST_DEBENTURE_RED                   Lines 432
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:13
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
17         WHERE company_code     IN s_bukrs
18           AND security_id      IN s_id
19           AND context          EQ 'TRL'
20           AND security_account IN s_acc_n
21           AND valuation_area   IN s_val.
22     *** sy-subrc check that si successfull check
23       IF sy-subrc EQ 0.
24     *** select from trlt_flow for amount
25         SELECT *
26           FROM trlt_flow
27           INTO TABLE gt_flow
28           FOR ALL ENTRIES IN gt_pos
29           WHERE position_oid EQ gt_pos-identified_oid
30            AND  flowtype     IN s_u_typ.
31         "AND  trldate      LE s_date-low.
32
33         SELECT *
34          FROM trlt_flow
35          INTO TABLE gt_flow1
36           FOR ALL ENTRIES IN gt_pos
37           WHERE  position_oid EQ gt_pos-identified_oid
38            AND   flowtype     IN s_u_typ
39           AND    trldate      LE s_date-low.
40     *** end condition type
41
42
43       ENDIF.
44
45     ENDFORM.
46     *&---------------------------------------------------------------------*
47     *&      Form  PROCESS_DATA
48     *&---------------------------------------------------------------------*
49     *       text
50     *----------------------------------------------------------------------*
51     *  -->  p1        text
52     *  <--  p2        text
53     *----------------------------------------------------------------------*
54     FORM process_data .
55       DATA : lv_value TYPE char10.
56       DATA : lv_mat_date TYPE p0001-begda,
57              lv_last_dat TYPE p0001-begda,
58              lv_diff     TYPE p,
59              lv_index    TYPE sy-tabix.
60
61       CLEAR : gs_pos.
62       LOOP AT   gt_pos INTO gs_pos WHERE    company_code IN s_bukrs
63                                      AND    security_id  IN  s_id
64                                      AND    context      = 'TRL'.
65         lv_index = sy-tabix.
66         CLEAR : gs_flow.
67         LOOP AT gt_flow1 INTO gs_flow1 WHERE position_oid = gs_pos-identified_oid.
68           gs_final-amount = gs_final-amount + gs_flow1-nominal_amt.                     "(A)
69         ENDLOOP.
70
71         CLEAR : gs_flow.
72         READ TABLE gt_flow INTO gs_flow WITH KEY  position_oid = gs_pos-identified_oid
73                                                   flowtype     = 'SAM7100'.
74         IF sy-subrc EQ 0.
75           lv_mat_date = gs_flow-trldate.                                                  "(B)
76         ENDIF.
77
78         SORT gt_flow BY trldate DESCENDING.
79         CLEAR : gs_flow.
80
81         READ TABLE s_u_typ INDEX lv_index.
82
83         READ TABLE gt_flow INTO gs_flow WITH KEY  position_oid = gs_pos-identified_oid
84                                                   flowtype     = s_u_typ-low.
85         IF sy-subrc EQ 0.
86           lv_last_dat = gs_flow-trldate.
87           gs_final-curr = gs_flow-nominal_curr.                                              "(C)
88         ENDIF.
89
90         IF lv_mat_date IS NOT INITIAL AND lv_last_dat IS NOT INITIAL.
91           CLEAR : lv_diff.
92
93           CALL FUNCTION '/SDF/CMO_DATETIME_DIFFERENCE'
94             EXPORTING
95               date1            = lv_last_dat
96               date2            = lv_mat_date
97             IMPORTING
98               datediff         = lv_diff  "(Total number of days)
99             EXCEPTIONS
100              invalid_datetime = 1
101              OTHERS           = 2.
102          IF sy-subrc = 0.
103            gs_final-days = lv_diff.
104    * Implement suitable error handling here
105          ENDIF.
106
107          IF s_date-low IS NOT INITIAL AND lv_last_dat IS  NOT INITIAL .
108            CLEAR : lv_diff.
109
110            CALL FUNCTION '/SDF/CMO_DATETIME_DIFFERENCE'
111              EXPORTING
112                date1            = s_date-low
113                date2            = lv_last_dat
114              IMPORTING
115                datediff         = lv_diff   " ( No of days for Drr)
116              EXCEPTIONS
117                invalid_datetime = 1
118                OTHERS           = 2.
119            IF sy-subrc = 0.
120              gs_final-p_days = lv_diff.
121    * Implement suitable error handling here
122            ENDIF.
123          ENDIF.
124        ENDIF.
125
126        IF gs_final-amount IS NOT INITIAL.
127          CLEAR :lv_value.
128          lv_value = gs_final-days * gs_final-p_days.
129
130          IF lv_value GT 0.
131            gs_final-a_amt = ( gs_final-amount /  lv_value ). "DRR
132          ENDIF.
133        ENDIF.
134        IF gs_final-a_amt IS NOT INITIAL.
135          APPEND gs_final TO gt_final.
136        ENDIF.
137        CLEAR : gs_final.
138
139      ENDLOOP.
140    ENDFORM.
141    *&---------------------------------------------------------------------*
142    *&      Form  CALL_BAPI
143    *&---------------------------------------------------------------------*
144    *       text
145    *----------------------------------------------------------------------*
146    *  -->  p1        text
147    *  <--  p2        text
148    *----------------------------------------------------------------------*
149    FORM call_bapi.
150      DATA : lv_curr TYPE waers,
151             lv_text TYPE char255.
152
153      CLEAR : gs_final.
154      LOOP AT gt_final INTO gs_final.
155        CLEAR gs_header.
156        gs_header-obj_type    = 'BKPFF'.
157        gs_header-doc_date    = s_date-low.
158        gs_header-pstng_date  = s_date-low.
159        gs_header-doc_type    = 'SA'.
160        gs_header-comp_code   = s_bukrs-low.
161        gs_header-header_txt  = 'Debenture Redemption'.
162        gs_header-ref_doc_no  = s_id-low.
163        gs_header-username    = sy-uname.
164
165        CLEAR : lv_text.
166        CONCATENATE 'Tot Days' gs_final-days
167                    'No. Of days' gs_final-p_days
168                     INTO lv_text SEPARATED BY space.
169        CLEAR gs_log.
170        gs_log-zbukrs        = s_bukrs-low.
171        gs_log-zid           = s_id-low.
172        gs_log-zaccount      = s_acc_n-low.
173        gs_log-zloan_amt     = gs_final-amount.
174        gs_log-zdays_tot     = gs_final-days.
175        gs_log-zday_no       = gs_final-p_days.
176        gs_log-zdrr_amt      = gs_final-a_amt.
177        gs_log-zdate         = sy-datum.
178        gs_log-ztime         = sy-uzeit.
179        gs_log-zuser         = sy-uname.
180        gs_log-zkey_date     = s_date-low.
181        gs_log-zcurr          = gs_final-curr.
182
183        gs_accountgl-itemno_acc = 1.
184
185        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
186          EXPORTING
187            input  = s_a_gl-low
188          IMPORTING
189            output = s_a_gl-low.
190
191        gs_accountgl-gl_account = s_a_gl-low.
192        gs_accountgl-bus_area   = 'JV'.
193    *    gs_accountgl-costcenter = s_cntr-low.
194        gs_accountgl-item_text  = lv_text.
195        gs_accountgl-cs_trans_t   = 316.
196        gs_accountgl-profit_ctr = s_prctr-low.
197        APPEND gs_accountgl TO gt_accountgl.
198        CLEAR gs_accountgl.
199
200        CLEAR : lv_curr.
201        lv_curr = gs_final-curr.
202        gs_curr-itemno_acc  = 1.
203        gs_curr-currency    = lv_curr.
204    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
205    *    gs_curr-amt_doccur  = gs_final-a_amt.
206        gs_curr-amt_doccur = CONV #( gs_final-a_amt ).
207    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
208        APPEND gs_curr TO gt_curr.
209        CLEAR : gs_curr.
210
211        gs_accountgl-itemno_acc = 2.
212        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
213          EXPORTING
214            input  = s_f_gl-low
215          IMPORTING
216            output = s_f_gl-low.
217        gs_accountgl-gl_account = s_f_gl-low.
218        gs_accountgl-alloc_nmbr   = 'Debenture Redemption'.
219        gs_accountgl-item_text  = lv_text.
220        gs_accountgl-cs_trans_t   = 317.
221        APPEND gs_accountgl TO gt_accountgl.
222        CLEAR : gs_accountgl.
223
224        gs_curr-itemno_acc  = 2.
225        gs_curr-currency    = lv_curr.
226    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
227    *    gs_curr-amt_doccur  =  gs_final-a_amt * -1.
228        gs_curr-amt_doccur = CONV #( gs_final-a_amt * -1 ).
229    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
230        APPEND gs_curr TO gt_curr.
231        CLEAR : gs_curr.
232
233
234        REFRESH lt_return.
235        CLEAR : obj_type,
236                obj_key,
237                obj_sys.
238
239    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
240        CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'  "#EC CI_USAGE_OK
241            "#EC CI_USAGE_OK[2628704]
242      "#EC CI_USAGE_OK[2438131]
243
244    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
245          EXPORTING
246            documentheader = gs_header
247          IMPORTING
248            obj_type       = obj_type
249            obj_key        = obj_key
250            obj_sys        = obj_sys
251          TABLES
252            accountgl      = gt_accountgl
253            currencyamount = gt_curr
254            return         = lt_return.
255
256        CLEAR : ls_return.
257        LOOP AT lt_return INTO ls_return.
258          ls_return_f = ls_return.
259          APPEND ls_return_f TO lt_return_f.
260        ENDLOOP.
261    ****  IF document is posted succesfully commit the tranaction.
262
263        IF p_test IS INITIAL.
264          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
265            EXPORTING
266              wait = 'X'.
267        ENDIF.
268      ENDLOOP.
269
270
271      CLEAR : ls_return.
272
273
274      LOOP AT lt_return_f INTO ls_return_f WHERE ( type = 'S' OR type = 'E' ).
275        CLEAR : ls_alv.
276        IF ls_return_f-type EQ 'S' AND ls_return_f-number = '605' AND ls_return_f-id = 'RW' .
277          ls_alv-icon =  '@08@'.   "FOR GREEN COLOR
278          gs_log-zdoc_no  = ls_return_f-message_v2.
279          MOVE-CORRESPONDING ls_return_f TO ls_alv.
280          APPEND ls_alv TO git_alv.
281          CLEAR ls_alv.
282          IF p_test IS INITIAL.
283            APPEND gs_log TO gt_log.
284            IF gt_log IS NOT INITIAL.
285              MODIFY ztr_deb_red FROM TABLE gt_log.
286              PERFORM display_log.
287
288            ENDIF.
289          ELSEIF p_test IS NOT INITIAL.
290            APPEND gs_log TO gt_log.
291            CLEAR : gs_log.
292            PERFORM display_log.
293    *        EXIT.
294          ENDIF.
295
296        ELSEIF ls_return_f-type EQ 'E' AND ls_return_f-number <> '609' .
297          ls_alv-icon = '@0A@'.    "FOR RED COLOR
298          MOVE-CORRESPONDING ls_return_f TO ls_alv.
299
300          APPEND ls_alv TO git_alv.
301          CLEAR ls_alv.
302          PERFORM display_alv.
303        ENDIF.
304
305      ENDLOOP.
306
307    ENDFORM.
308    *&---------------------------------------------------------------------*
309    *&      Form  DISPLAY_ALV
310    *&---------------------------------------------------------------------*
311    *       text
312    *----------------------------------------------------------------------*
313    *  -->  p1        text
314    *  <--  p2        text
315    *----------------------------------------------------------------------*
316    FORM display_alv .
317
318      DATA : ls_fld TYPE slis_fieldcat_alv.
319      CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
320        EXPORTING
321          i_program_name         = sy-repid
322          i_structure_name       = 'ZFI_S_ALV'
323          i_client_never_display = 'X'
324        CHANGING
325          ct_fieldcat            = gt_fld
326        EXCEPTIONS
327          inconsistent_interface = 1
328          program_error          = 2
329          OTHERS                 = 3.
330      IF sy-subrc <> 0.
331    * Implement suitable error handling here
332      ELSE.
333        LOOP AT gt_fld INTO gs_fld .
334          IF  gs_fld-fieldname EQ 'INDEX' OR gs_fld-fieldname EQ 'BUKRS_NEW' OR gs_fld-fieldname EQ 'BELNR_NEW' OR gs_fld-fieldname EQ 'GJAHR_NEW'
335              OR gs_fld-fieldname EQ 'BUKRS' OR gs_fld-fieldname EQ 'BELNR' OR  gs_fld-fieldname EQ  'GJAHR' OR gs_fld-fieldname EQ 'BLART'.
336            gs_fld-no_out = 'X' .
337            MODIFY gt_fld FROM gs_fld .
338          ENDIF.
339        ENDLOOP .
340      ENDIF.
341
342      CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
343        EXPORTING
344          i_callback_program     = sy-repid
345          i_callback_top_of_page = 'TOP_OF_PAGE'  "see FORM
346          it_fieldcat            = gt_fld[]
347          i_save                 = 'X'
348        TABLES
349          t_outtab               = git_alv
350        EXCEPTIONS
351          program_error          = 1
352          OTHERS                 = 2.
353      IF sy-subrc <> 0.
354        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
355                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
356      ENDIF.
357
358    ENDFORM.
359
360    FORM top_of_page.
361    *ALV Header declarations
362      DATA: lt_header  TYPE slis_t_listheader,
363            lwa_header TYPE slis_listheader.
364
365    * Title
366      IF p_test IS INITIAL .
367        lwa_header-typ  = 'H'.
368        lwa_header-info = text-004.
369        APPEND lwa_header TO lt_header.
370        CLEAR lwa_header.
371      ELSE.
372        lwa_header-typ  = 'H'.
373        lwa_header-info = text-005.
374        APPEND lwa_header TO lt_header.
375        CLEAR lwa_header.
376      ENDIF.
377    *   date
378
379      lwa_header-typ  = 'S'.
380      lwa_header-key = text-007.
381      CONCATENATE  sy-datum+6(2) '.'
382                   sy-datum+4(2) '.'
383                   sy-datum(4) INTO lwa_header-info.   "todays date
384      APPEND lwa_header TO lt_header.
385      CLEAR: lwa_header.
386
387
388      CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
389        EXPORTING
390          it_list_commentary = lt_header.
391    ENDFORM.
392    *&---------------------------------------------------------------------*
393    *&      Form  DISPLAY_LOG
394    *&---------------------------------------------------------------------*
395    *       text
396    *----------------------------------------------------------------------*
397    *  -->  p1        text
398    *  <--  p2        text
399    *----------------------------------------------------------------------*
400    FORM display_log .
401
402      DATA : ls_fld TYPE slis_fieldcat_alv.
403      CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
404        EXPORTING
405          i_program_name         = sy-repid
406          i_structure_name       = 'ZTR_DEB_RED'
407          i_client_never_display = 'X'
408        CHANGING
409          ct_fieldcat            = gt_fld
410        EXCEPTIONS
411          inconsistent_interface = 1
412          program_error          = 2
413          OTHERS                 = 3.
414      IF sy-subrc EQ 0.
415        CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
416          EXPORTING
417            i_callback_program     = sy-repid
418            i_callback_top_of_page = 'TOP_OF_PAGE'  "see FORM
419            it_fieldcat            = gt_fld[]
420            i_save                 = 'X'
421          TABLES
422            t_outtab               = gt_log
423          EXCEPTIONS
424            program_error          = 1
425            OTHERS                 = 2.
426        IF sy-subrc <> 0.
427          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
428                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
429        ENDIF.
430      ENDIF.
431
432    ENDFORM.
*--- End of ZTRM_POST_DEBENTURE_RED_F01 - 432 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CSLIS                                   Level 1    Page 5
Object           ZTRM_POST_DEBENTURE_RED                   Lines 543
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:13
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
Generated incl.  <REPINI>                                  Level 1    Page 6
Object           ZTRM_POST_DEBENTURE_RED                   Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:13
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
Generated incl.  <SYSINI>                                  Level 1    Page 7
Object           ZTRM_POST_DEBENTURE_RED                   Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:13
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
Generated incl.  <SYSSEL>                                  Level 1    Page 8
Object           ZTRM_POST_DEBENTURE_RED                   Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:13
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
Generated incl.  DB__SSEL                                  Level 1    Page 9
Object           ZTRM_POST_DEBENTURE_RED                   Lines 1
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:17:13
----------------------------------------------------------------------------------------------------
1      * INCLUDE DB__SSEL
*--- End of DB__SSEL - 1 lines ---
