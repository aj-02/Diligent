----------------------------------------------------------------------------------------------------
Main program     ZFI_TAX_CAPEX_POSTING                     Level 0    Page 1
Object           ZFI_TAX_CAPEX_POSTING                     Lines 13
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:34
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *& Report  ZFI_TAX_CAPEX_POSTING
3      *&
4      *&---------------------------------------------------------------------*
5      *&
6      *&
7      *&---------------------------------------------------------------------*
8      REPORT ZFI_TAX_CAPEX_POSTING.
9
10     INCLUDE zfi_tax_CAPEX_posting_top.
11     INCLUDE zfi_tax_CAPEX_posting_sel.
12     INCLUDE zfi_tax_CAPEX_posting_e01.
13     INCLUDE zfi_tax_CAPEX_posting_f01.
*--- End of ZFI_TAX_CAPEX_POSTING - 13 lines ---

----------------------------------------------------------------------------------------------------
Include          ZFI_TAX_CAPEX_POSTING_TOP                 Level 1    Page 2
Object           ZFI_TAX_CAPEX_POSTING                     Lines 69
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:34
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&  Include           ZFI_TAX_CAPEX_POSTING_TOP
3      *&---------------------------------------------------------------------*
4
5      *---------------------------------------------------------------------*
6      *  TOP INCLUDE
7      *---------------------------------------------------------------------*
8      DATA: ls_header    TYPE bapiache09,
9            lt_accountgl TYPE TABLE OF bapiacgl09,
10           ls_accountgl TYPE bapiacgl09,
11           lt_currency  TYPE TABLE OF bapiaccr09,
12           ls_currency  TYPE bapiaccr09,
13           lt_return    TYPE TABLE OF bapiret2,
14           ls_return    TYPE bapiret2.
15
16     DATA: gv_obj_type TYPE bapiache09-obj_type,
17           gv_obj_key  TYPE bapiache09-obj_key,
18           gv_obj_sys  TYPE bapiache09-obj_sys.
19
20     DATA: gv_date    TYPE dats,
21           gv_prctr   TYPE prctr,
22           gv_gjahr   TYPE numc2,
23           gv_heading TYPE char25.
24
25     DATA: gv_item TYPE i.
26
27     DATA: gt_final_return TYPE TABLE OF bapiret2,
28           gs_final_return TYPE bapiret2.
29
30     DATA: gv_error TYPE abap_bool.
31
32     * Custom tables
33     DATA: gs_gl     TYPE zfi_tax_glpost.
34     DATA: gt_block_master TYPE TABLE OF zfi_tax_sec42_1,
35           gs_block_master TYPE zfi_tax_sec42_1,
36           gt_gl_post_comm TYPE TABLE OF zfi_tax_sec42_2,
37           gs_gl_post_comm TYPE zfi_tax_sec42_2,
38           gt_amort_sch    TYPE TABLE OF zfi_tax_sec42_5,
39           gs_amort_sch    TYPE zfi_tax_sec42_5.
40     DATA: gv_total_balance TYPE wrbtr.
41
42     *---------------------------------------------------------------------*
43     * DATA DECLARATION
44     *---------------------------------------------------------------------*
45     *DATA: ls_header    TYPE bapiache09,
46     *      lt_accountgl TYPE TABLE OF bapiacgl09,
47     *      ls_accountgl TYPE bapiacgl09,
48     *      lt_currency  TYPE TABLE OF bapiaccr09,
49     *      ls_currency  TYPE bapiaccr09,
50     *      lt_return    TYPE TABLE OF bapiret2,
51     *      ls_return    TYPE bapiret2.
52     *
53     *DATA: lv_obj_type TYPE bapiache09-obj_type,
54     *      lv_obj_key  TYPE bapiache09-obj_key,
55     *      lv_obj_sys  TYPE bapiache09-obj_sys.
56     *
57     *DATA: lv_date TYPE dats,
58     *      lv_fy   TYPE numc2,
59     *      lv_fy1  TYPE numc2,
60     *      lv_fy2  TYPE numc2.
61     *
62     *DATA: gt_block_master TYPE TABLE OF zfi_tax_sec42_1,
63     *      gs_block_master TYPE zfi_tax_sec42_1,
64     *      gt_gl_post_comm TYPE TABLE OF zfi_tax_sec42_2,
65     *      gs_gl_post_comm TYPE zfi_tax_sec42_2,
66     *      gt_amort_sch    TYPE TABLE OF zfi_tax_sec42_4,
67     *      gs_amort_sch    TYPE zfi_tax_sec42_4.
68     *
69     *DATA: gv_total_balance TYPE wrbtr.
*--- End of ZFI_TAX_CAPEX_POSTING_TOP - 69 lines ---

----------------------------------------------------------------------------------------------------
Include          ZFI_TAX_CAPEX_POSTING_SEL                 Level 1    Page 3
Object           ZFI_TAX_CAPEX_POSTING                     Lines 9
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:34
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&  Include           ZFI_TAX_CAPEX_POSTING_SEL
3      *&---------------------------------------------------------------------*
4
5      SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME.
6      PARAMETERS: p_bukrs TYPE bukrs,
7                  p_gjahr TYPE gjahr,
8                  p_jv    TYPE jv_name.
9      SELECTION-SCREEN END OF BLOCK b1.
*--- End of ZFI_TAX_CAPEX_POSTING_SEL - 9 lines ---

----------------------------------------------------------------------------------------------------
Include          ZFI_TAX_CAPEX_POSTING_E01                 Level 1    Page 4
Object           ZFI_TAX_CAPEX_POSTING                     Lines 134
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:34
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&  Include           ZFI_TAX_CAPEX_POSTING_E01
3      *&---------------------------------------------------------------------*
4      START-OF-SELECTION.
5
6        DATA: lv_capex_gl   TYPE saknr,
7              lv_credit_amt TYPE wrbtr.
8        DATA: lv_gjahr1 TYPE numc2,
9              lv_gjahr2 TYPE numc2.
10
11     * Fetch data
12       PERFORM fetch_data.
13
14     *  IF gs_amort_sch IS INITIAL.
15     *    MESSAGE: 'No data found to process' TYPE 'E'.
16     *    RETURN.
17     *  ENDIF.
18
19
20       SELECT *
21         FROM zfi_tax_sec42_2
22         INTO TABLE @DATA(lt_2).
23
24       SELECT racct
25         INTO TABLE @DATA(lt_act)
26         FROM jvto1
27         FOR ALL ENTRIES IN @lt_2
28     WHERE rbukrs = @p_bukrs
29     AND rjvnam = @p_jv
30     AND ryear  = @p_gjahr
31     AND rldnr = '4A'
32     AND racct = @lt_2-hkont.
33
34
35     *     gs_gl.
36     *LOOP AT lt_act into data(ls_act).
37       READ TABLE lt_act INTO DATA(ls_act) INDEX 1. "#EC CI_NOORDER
38       SELECT SINGLE *
39          FROM zfi_tax_glpost
40          INTO gs_gl
41         WHERE hkont = ls_act-racct.
42
43       PERFORM prepare_date.
44       lv_capex_gl = gs_gl-capex_gl.
45       lv_credit_amt = gs_amort_sch-instl_amt * -1.
46
47       CLEAR: lt_accountgl, lt_currency.
48       gv_gjahr = gv_date+2(2).
49       lv_gjahr1 = gv_gjahr.
50       lv_gjahr2 = gv_gjahr + 1.
51       CONCATENATE 'CIT-Capex Allow-AY' lv_gjahr1 '-' lv_gjahr2 INTO gv_heading.
52       PERFORM build_header USING gv_heading.
53
54       PERFORM calculate_jv_amort.
55       IF gt_amort_sch IS INITIAL.
56         MESSAGE: 'No Data available for Posting' TYPE 'E'.
57       ENDIF.
58     *
59     *  READ TABLE gt_amort_sch INTO gs_amort_sch INDEX 1.
60     *  IF sy-subrc <> 0.
61     *    MESSAGE: 'No Transactions for current Year' TYPE 'E'.
62     *    RETURN.
63     *  ENDIF.
64
65       gv_item = 1.
66
67       PERFORM add_gl_line USING gv_item
68             lv_capex_gl
69             gs_amort_sch-instl_amt
70             'H'
71             'Current Capex Allow - Drilling exploration for production'.
72
73       gv_item = gv_item + 1.
74       lv_credit_amt = gs_amort_sch-instl_amt * -1.
75
76       PERFORM add_gl_line USING gv_item
77             gs_gl-off_capex_gl
78             lv_credit_amt
79             'S'
80             'Current Capex Allow - Drilling exploration for production'.
81       DATA: lt_bkpf TYPE TABLE OF bkpf,
82             lt_bseg TYPE TABLE OF bseg,
83             ls_bkpf TYPE bkpf,
84             ls_bseg TYPE bseg.
85       CLEAR: lt_bkpf, lt_bseg, ls_bkpf, ls_bseg.
86
87     * Step 1: Get headers
88       SELECT *
89         INTO TABLE lt_bkpf
90         FROM bkpf
91        WHERE blart = 'CO'
92          AND bukrs = p_bukrs
93          AND gjahr = p_gjahr.
94
95       IF lt_bkpf IS NOT INITIAL.
96
97     * Step 2: Get line items from BSEG
98         SELECT *
99           INTO TABLE lt_bseg
100          FROM bseg
101          FOR ALL ENTRIES IN lt_bkpf
102         WHERE belnr = lt_bkpf-belnr
103          AND vname = p_jv
104          AND bukrs = p_bukrs
105          AND gjahr = p_gjahr ORDER BY PRIMARY KEY.
106
107      ENDIF.
108
109    * Step 3: Check duplicate
110      LOOP AT lt_bseg INTO ls_bseg.
111
112        READ TABLE lt_bkpf INTO ls_bkpf
113             WITH KEY belnr = ls_bseg-belnr.
114
115        IF sy-subrc = 0.
116
117    * If reversed with reason 01 allow
118          IF ls_bkpf-stgrd = '01' AND ls_bseg-sgtxt = 'Current Capex Allow - Drilling exploration for production'.
119            CONTINUE.
120          ELSEIF ls_bseg-sgtxt = 'Current Capex Allow - Drilling exploration for production'.
121            MESSAGE 'Duplicate document exists. Posting not allowed'
122            TYPE 'E'.
123          ENDIF.
124
125        ENDIF.
126
127      ENDLOOP.
128      PERFORM post_document.
129    *ENDLOOP.
130
131    *---------------------------------------------------------------------*
132    * FINAL RESULT
133    *---------------------------------------------------------------------*
134      PERFORM display_result.
*--- End of ZFI_TAX_CAPEX_POSTING_E01 - 134 lines ---

----------------------------------------------------------------------------------------------------
Include          ZFI_TAX_CAPEX_POSTING_F01                 Level 1    Page 5
Object           ZFI_TAX_CAPEX_POSTING                     Lines 420
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:34
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&  Include           ZFI_TAX_CAPEX_POSTING_F01
3      *&---------------------------------------------------------------------*
4
5      *---------------------------------------------------------------------*
6      *  FORMS
7      *---------------------------------------------------------------------*
8
9      FORM fetch_data.
10
11     *  SELECT SINGLE *
12     *    FROM zfi_tax_sec42_5
13     *    INTO gs_amort_sch
14     *    WHERE bukrs = p_bukrs
15     *      AND venture = p_jv
16     *      AND gjahr = p_gjahr.
17     *
18     *  IF sy-subrc IS INITIAL.
19     *    SELECT SINGLE *
20     *      FROM zfi_tax_glpost
21     *      INTO gs_gl
22     *      WHERE hkont = gs_amort_sch-hkont.
23     *  ENDIF.
24
25       SELECT SINGLE prctr
26         FROM zfi_tax_jv_pc
27         INTO gv_prctr
28         WHERE venture = p_jv.
29
30     ENDFORM.
31
32     *---------------------------------------------------------------------*
33     FORM prepare_date.
34
35       DATA lv_gjahr TYPE numc4.
36
37       lv_gjahr = p_gjahr + 1.
38       CONCATENATE lv_gjahr '0331' INTO gv_date.
39
40     ENDFORM.
41
42     *---------------------------------------------------------------------*
43     FORM build_header USING iv_text TYPE char25.
44
45       CLEAR ls_header.
46
47       ls_header-username   = sy-uname.
48       ls_header-comp_code  = p_bukrs.
49       ls_header-doc_date   = gv_date.
50       ls_header-pstng_date = gv_date.
51       ls_header-trans_date = gv_date.
52       ls_header-doc_type   = 'CO'.
53       ls_header-fisc_year  = p_gjahr.
54       ls_header-fis_period = '16'.
55       ls_header-header_txt = iv_text.
56
57     ENDFORM.
58
59     *---------------------------------------------------------------------*
60     FORM add_gl_line USING iv_item iv_gl iv_amt iv_dc iv_text.
61
62       CLEAR ls_accountgl.
63       ls_accountgl-itemno_acc = iv_item.
64       ls_accountgl-gl_account = iv_gl.
65       ls_accountgl-item_text  = iv_text.
66       ls_accountgl-comp_code  = p_bukrs.
67       ls_accountgl-fis_period = '16'.
68       ls_accountgl-fisc_year  = p_gjahr.
69       ls_accountgl-pstng_date = gv_date.
70       ls_accountgl-profit_ctr = gv_prctr.
71       ls_accountgl-de_cre_ind = iv_dc.
72       ls_accountgl-doc_type = 'CO'.
73       ls_accountgl-bus_area = 'JV'.
74       ls_accountgl-func_area = '0001'.
75       ls_accountgl-value_date = gv_date.
76       ls_accountgl-tr_part_ba  = 'JV'.
77       ls_accountgl-cs_trans_t  = '305'.
78       APPEND ls_accountgl TO lt_accountgl.
79
80       CLEAR ls_currency.
81       ls_currency-itemno_acc = iv_item.
82       ls_currency-currency   = 'INR'.
83       ls_currency-amt_doccur = iv_amt.
84       APPEND ls_currency TO lt_currency.
85
86     ENDFORM.
87
88     *---------------------------------------------------------------------*
89     FORM post_document.
90
91       DATA: lt_return_local TYPE TABLE OF bapiret2,
92             ls_return_local TYPE bapiret2.
93
94       CALL FUNCTION 'BAPI_ACC_DOCUMENT_CHECK' "#EC CI_USAGE_OK[2628704]
95     "#EC CI_USAGE_OK[2438131]
96         EXPORTING
97           documentheader = ls_header
98         TABLES
99           accountgl      = lt_accountgl
100          currencyamount = lt_currency
101          return         = lt_return_local.
102
103      CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST' "#EC CI_USAGE_OK[2628704]
104    "#EC CI_USAGE_OK[2438131]
105        EXPORTING
106          documentheader = ls_header
107        IMPORTING
108          obj_type       = gv_obj_type
109          obj_key        = gv_obj_key
110          obj_sys        = gv_obj_sys
111        TABLES
112          accountgl      = lt_accountgl
113          currencyamount = lt_currency
114          return         = lt_return_local.
115
116      LOOP AT lt_return_local INTO ls_return_local.
117        APPEND ls_return_local TO gt_final_return.
118      ENDLOOP.
119
120    ENDFORM.
121
122    *---------------------------------------------------------------------*
123    FORM display_result.
124      DATA: lv_msg TYPE bapi_msg.
125      gv_error = abap_false.
126      IF gt_final_return IS INITIAL.
127        MESSAGE: 'No Data available for Posting' TYPE 'E'.
128      ENDIF.
129      LOOP AT gt_final_return INTO gs_final_return
130           WHERE type = 'E' OR type = 'A'.
131        gv_error = abap_true.
132      ENDLOOP.
133
134      IF gv_error = abap_true.
135
136        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
137
138        READ TABLE gt_final_return INTO gs_final_return WITH KEY type = 'E' row = '1'.
139        MESSAGE: gs_final_return-message TYPE 'E'.
140
141      ELSE.
142
143        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
144          EXPORTING
145            wait = 'X'.
146        LOOP AT gt_final_return INTO gs_final_return.
147          IF lv_msg IS INITIAL.
148            lv_msg = gs_final_return-message.
149          ELSE.
150            CONCATENATE lv_msg
151                        gs_final_return-message
152                   INTO lv_msg
153                   SEPARATED BY ','.
154          ENDIF.
155        ENDLOOP.
156        MESSAGE lv_msg TYPE 'S' DISPLAY LIKE 'I'.
157
158      ENDIF.
159
160    ENDFORM.
161
162    FORM calculate_jv_amort.
163
164      DATA: lv_saknr      TYPE saknr,
165            lv_instl_year TYPE gjahr,
166            lv_instl_amt  TYPE wrbtr.
167
168      CLEAR gt_amort_sch.
169
170    * Fetch Block Master
171      SELECT *
172        FROM zfi_tax_sec42_1
173        INTO TABLE gt_block_master
174        WHERE venture_code = p_jv
175          AND bukrs        = p_bukrs.
176
177      LOOP AT gt_block_master INTO gs_block_master.
178
179        IF gs_block_master-claim_type = 'P'.
180
181    * Fetch GL mapping
182          SELECT *
183            FROM zfi_tax_sec42_2
184            INTO TABLE gt_gl_post_comm
185            WHERE bukrs = p_bukrs.
186
187          IF gt_gl_post_comm IS INITIAL.
188            CONTINUE.
189          ENDIF.
190
191          LOOP AT gt_gl_post_comm INTO gs_gl_post_comm.
192
193    * Year Logic
194    *        IF gs_block_master-prod_date+4(2) <= '03'.
195    *          lv_instl_year = gs_block_master-prod_date+0(4) - 1.
196    *        ELSE.
197    *          lv_instl_year = gs_block_master-prod_date+0(4).
198    *        ENDIF.
199            lv_instl_year = p_gjahr.
200
201    * Validate GL
202            SELECT SINGLE saknr
203              INTO lv_saknr
204              FROM skb1
205              WHERE bukrs = p_bukrs
206                AND saknr = gs_gl_post_comm-hkont.
207
208            IF sy-subrc <> 0.
209              CONTINUE.
210            ENDIF.
211
212    * Get JV Balance
213            PERFORM get_jv_total
214              USING    gs_block_master-venture_code
215                       gs_gl_post_comm-hkont
216                       gs_gl_post_comm-flow_type
217                       p_bukrs
218                       gs_block_master-prod_date
219              CHANGING gv_total_balance.
220
221    * Installment Calculation
222            lv_instl_amt = gv_total_balance .
223
224    * Fill amort table
225    *        CLEAR gs_amort_sch.
226            IF gs_amort_sch IS INITIAL.
227              gs_amort_sch-bukrs   = p_bukrs.
228              gs_amort_sch-venture = gs_block_master-venture_code.
229              gs_amort_sch-gjahr   = lv_instl_year.
230              gs_amort_sch-hkont   = gs_gl_post_comm-hkont.
231
232              IF gs_block_master-surr_date IS NOT INITIAL.
233                gs_amort_sch-surr_date = gs_block_master-surr_date.
234              ENDIF.
235
236    *        gs_amort_sch-total_amt = gv_total_balance.
237              gs_amort_sch-instl_amt = lv_instl_amt.
238              gs_amort_sch-reversed  = space.
239            ELSE.
240              gs_amort_sch-instl_amt = gs_amort_sch-instl_amt + lv_instl_amt.
241
242            ENDIF.
243
244
245          ENDLOOP.
246          APPEND gs_amort_sch TO gt_amort_sch.
247        ENDIF.
248        IF gs_block_master-claim_type = 'E'.
249          SELECT *
250              FROM zfi_tax_sec42_3
251              INTO TABLE gt_gl_post_comm
252              WHERE bukrs = p_bukrs.
253
254          IF gt_gl_post_comm IS INITIAL.
255            CONTINUE.
256          ENDIF.
257
258          LOOP AT gt_gl_post_comm INTO gs_gl_post_comm.
259
260    * Year Logic
261            IF gs_block_master-prod_date+4(2) <= '03'.
262              lv_instl_year = gs_block_master-prod_date+0(4) - 1.
263            ELSE.
264              lv_instl_year = gs_block_master-prod_date+0(4).
265            ENDIF.
266
267    * Validate GL
268            SELECT SINGLE saknr
269              INTO lv_saknr
270              FROM skb1
271              WHERE bukrs = p_bukrs
272                AND saknr = gs_gl_post_comm-hkont.
273
274            IF sy-subrc <> 0.
275              CONTINUE.
276            ENDIF.
277
278    * Get JV Balance
279            PERFORM get_jv_total
280              USING    gs_block_master-venture_code
281                       gs_gl_post_comm-hkont
282                       gs_gl_post_comm-flow_type
283                       p_bukrs
284                       gs_block_master-prod_date
285              CHANGING gv_total_balance.
286
287    * Installment Calculation
288            lv_instl_amt = gv_total_balance / 10.
289
290    * Fill amort table
291            CLEAR gs_amort_sch.
292            IF gt_amort_sch IS INITIAL.
293              gs_amort_sch-bukrs   = p_bukrs.
294              gs_amort_sch-venture = gs_block_master-venture_code.
295              gs_amort_sch-gjahr   = lv_instl_year.
296              gs_amort_sch-hkont   = gs_gl_post_comm-hkont.
297
298              IF gs_block_master-surr_date IS NOT INITIAL.
299                gs_amort_sch-surr_date = gs_block_master-surr_date.
300              ENDIF.
301
302    *        gs_amort_sch-total_amt = gv_total_balance.
303              gs_amort_sch-instl_amt = lv_instl_amt.
304              gs_amort_sch-reversed  = space.
305            ELSE.
306              gs_amort_sch-instl_amt = gs_amort_sch-instl_amt + lv_instl_amt.
307
308            ENDIF.
309
310
311          ENDLOOP.
312          APPEND gs_amort_sch TO gt_amort_sch.
313        ENDIF.
314      ENDLOOP.
315
316    * Remove zero entries
317      DELETE gt_amort_sch WHERE instl_amt IS INITIAL.
318
319    ENDFORM.
320
321    FORM get_jv_total
322      USING    iv_venture   TYPE char6
323               iv_hkont     TYPE hkont
324               iv_flow_type TYPE char3
325               iv_bukrs     TYPE bukrs
326               iv_date TYPE datum
327      CHANGING cv_total     TYPE wrbtr.
328
329      DATA: iv_gjahr TYPE int4.
330      DATA: lv_count     TYPE numc2,
331            lv_fieldname TYPE string,
332            lv_loop      TYPE i.
333
334      TYPES: BEGIN OF ty_total,
335               hslvt TYPE jvto1-hslvt,
336               hsl01 TYPE jvto1-hsl01,
337               hsl02 TYPE jvto1-hsl02,
338               hsl03 TYPE jvto1-hsl03,
339               hsl04 TYPE jvto1-hsl04,
340               hsl05 TYPE jvto1-hsl05,
341               hsl06 TYPE jvto1-hsl06,
342               hsl07 TYPE jvto1-hsl07,
343               hsl08 TYPE jvto1-hsl08,
344               hsl09 TYPE jvto1-hsl09,
345               hsl10 TYPE jvto1-hsl10,
346               hsl11 TYPE jvto1-hsl11,
347               hsl12 TYPE jvto1-hsl12,
348               hsl13 TYPE jvto1-hsl13,
349               hsl14 TYPE jvto1-hsl14,
350               hsl15 TYPE jvto1-hsl15,
351               hsl16 TYPE jvto1-hsl16,
352             END OF ty_total.
353      DATA: ls_total TYPE ty_total.
354      FIELD-SYMBOLS: <fs_value> TYPE any.
355
356      iv_gjahr = iv_date+0(4).
357      IF iv_date+4(2) < '4'.
358        iv_gjahr = iv_gjahr - 1.
359      ENDIF.
360      cv_total = 0.
361
362      " Read JV transaction totals from JVTO1
363      SELECT
364        SUM( hslvt ) AS hslvt,
365        SUM( hsl01 ) AS hsl01,
366        SUM( hsl02 ) AS hsl02,
367        SUM( hsl03 ) AS hsl03,
368        SUM( hsl04 ) AS hsl04,
369        SUM( hsl05 ) AS hsl05,
370        SUM( hsl06 ) AS hsl06,
371        SUM( hsl07 ) AS hsl07,
372        SUM( hsl08 ) AS hsl08,
373        SUM( hsl09 ) AS hsl09,
374        SUM( hsl10 ) AS hsl10,
375        SUM( hsl11 ) AS hsl11,
376        SUM( hsl12 ) AS hsl12,
377        SUM( hsl13 ) AS hsl13,
378        SUM( hsl14 ) AS hsl14,
379        SUM( hsl15 ) AS hsl15,
380        SUM( hsl16 ) AS hsl16
381      INTO CORRESPONDING FIELDS OF @ls_total
382      FROM jvto1
383      WHERE rbukrs = @iv_bukrs
384      AND rjvnam = @iv_venture
385      AND racct  = @iv_hkont
386      AND ryear  = @p_gjahr
387      AND ranbwa = @iv_flow_type
388      AND rldnr = '4A'.
389
390
391      IF iv_date+4(2) > '03'.
392        lv_loop = iv_date+4(2) - 3.
393      ELSE.
394        lv_loop = iv_date+4(2) + 9.
395      ENDIF.
396
397      IF  iv_gjahr <> p_gjahr.
398        lv_count = 1.
399        DO 16 TIMES.
400          lv_fieldname = |HSL{ lv_count }|.
401
402          ASSIGN COMPONENT lv_fieldname OF STRUCTURE ls_total TO <fs_value>.
403          IF sy-subrc = 0.
404            cv_total = cv_total + <fs_value>.
405          ENDIF.
406          lv_count = lv_count + 1.
407        ENDDO.
408      ELSE.
409        lv_count = lv_loop + 1.
410        DO 12 - lv_loop + 4 TIMES.
411          lv_fieldname = |HSL{ lv_count }|.
412
413          ASSIGN COMPONENT lv_fieldname OF STRUCTURE ls_total TO <fs_value>.
414          IF sy-subrc = 0.
415            cv_total = cv_total + <fs_value>.
416          ENDIF.
417          lv_count = lv_count + 1.
418        ENDDO.
419      ENDIF.
420    ENDFORM.
*--- End of ZFI_TAX_CAPEX_POSTING_F01 - 420 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CABAP                                   Level 1    Page 6
Object           ZFI_TAX_CAPEX_POSTING                     Lines 360
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:34
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
Generated incl.  <REPINI>                                  Level 1    Page 7
Object           ZFI_TAX_CAPEX_POSTING                     Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:34
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
Object           ZFI_TAX_CAPEX_POSTING                     Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:34
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
Object           ZFI_TAX_CAPEX_POSTING                     Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:34
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
Object           ZFI_TAX_CAPEX_POSTING                     Lines 1
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:34
----------------------------------------------------------------------------------------------------
1      * INCLUDE DB__SSEL
*--- End of DB__SSEL - 1 lines ---
