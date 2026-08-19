----------------------------------------------------------------------------------------------------
Main program     ZFI_CP_MASS_VEN_PAY                       Level 0    Page 1
Object           ZFI_CP_MASS_VEN_PAY                       Lines 37
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:03
----------------------------------------------------------------------------------------------------
1                 REPORT zfi_cp_mass_ven_pay .
2
3      *--  PROGRAM FOR   vendor  local payments -----------------------------*
4      ***********************************************************************
5      * Program    :                                                        *
6      *                                                                     *
7      *                                                                     *
8      * Author     : S.R.Sudha                     Date : 17.03.2008
9      *                                                                     *
10     * Login Id   : CAB_SUDHA                                              *
11     *                                                                      *
12     * Description: For the selected vendor  making payments & creating    *
13     *                cheques.
14     *                                                                     *
15     * Tran.Code  : ZFIAPP
16     *
17     *                                                                     *
18     **************************************************************
19     * CHANGE HISTORY                                                      *
20     * Date      Transport  USERID   Description
21     *13.04.2010 RD1K971751 CAB_ALOK CR30004067: Correction
22     *                                 in pgrm for ZFIAPP
23     *
24
25     INCLUDE zfi_cp_mass_ven_pay_top.
26     INCLUDE zfi_cp_mas_ven_ai001.
27     INCLUDE zfi_cp_mas_ven_bo001.
28     INCLUDE zfi_cp_mas_ven_e0001.
29     *----------------------------------*
30     START-OF-SELECTION.
31     *-----------------------------------*
32     *-------select vendors  --------*
33       PERFORM  get_vendors.
34
35     *-------display vendors --------*
36       CALL SCREEN 100.
37     *------------------------------------*
*--- End of ZFI_CP_MASS_VEN_PAY - 37 lines ---

----------------------------------------------------------------------------------------------------
Include          ZFI_CP_MASS_VEN_PAY_TOP                   Level 1    Page 2
Object           ZFI_CP_MASS_VEN_PAY                       Lines 143
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:03
----------------------------------------------------------------------------------------------------
1      *----------------------------------------------------------------------*
2      *   INCLUDE ZFI_CP_MASS_VEN_PAY_TOP                                    *
3      *----------------------------------------------------------------------*
4
5      *-----tables ---------------------*
6      TABLES :   bseg, bsik , lfa1 , lfb1, pcec , t001 , zfi_bcm_payordr.
7      *--------controls------------------*
8      CONTROLS : tc_vend  TYPE TABLEVIEW USING SCREEN '0100'.
9      CONTROLS : tc_op_it  TYPE TABLEVIEW USING SCREEN '0200'.
10     data :        ist_setleaf  LIKE setleaf OCCURS 0 WITH HEADER LINE.
11     CONSTANTS: g_setclass LIKE setleaf-setclass VALUE '0000',
12                g_setname  LIKE setleaf-setname VALUE 'LIFNR_BP_SINGLE'.
13     *---------types ---------------------*
14
15     TYPES : BEGIN OF ty_lifnr ,
16             mark(1),
17             lifnr   LIKE lfa1-lifnr ,
18             name1   LIKE lfa1-name1,
19             END  OF ty_lifnr .
20     *----------internal tables & work areas ------------*
21     DATA : BEGIN OF ist_srcbsik OCCURS 0 ,
22            selcbox(1) TYPE c,
23            lifnr LIKE bsik-lifnr ,
24            umskz LIKE bsik-umskz,
25            bukrs LIKE bsik-bukrs ,
26            gjahr LIKE bsik-gjahr,
27            belnr  LIKE bsik-belnr,
28            buzei  LIKE bsik-buzei,
29            budat  LIKE bsik-budat,
30            bschl LIKE bsik-bschl,
31            zlsch LIKE bsik-zlsch,
32            zlspr LIKE  bsik-zlspr,
33            shkzg LIKE bsik-shkzg,
34            wrbtr LIKE bsik-wrbtr,
35            zfbdt LIKE bsik-zfbdt,
36            ZWELS LIKE LFB1-ZWELS,
37            amount(17).
38     DATA:  END OF ist_srcbsik .
39
40     DATA : ist_bsiks LIKE ist_srcbsik OCCURS 0 WITH HEADER LINE.
41     DATA : ist_bsiks_omit LIKE ist_srcbsik OCCURS 0 WITH HEADER LINE.
42     DATA : ist_bsiks_vblk LIKE ist_srcbsik OCCURS 0 WITH HEADER LINE.
43     DATA : ist_bsik  TYPE TABLE OF bsik.
44     DATA : ist_bseg TYPE TABLE OF  bseg.
45     DATA : wa_bsik_t  TYPE bsik.
46     DATA : wa_bseg TYPE  bseg.
47
48
49     data: sval_tab like sval occurs 0 with header line,
50           WA_sval_tab TYPE sval,
51           WA_sval_tab_B TYPE sval,
52                       WA_sval_tab_BU TYPE sval,
53                                               WA_sval_tab_AM TYPE sval,
54          rcode(1) type c.
55
56     TYPES : BEGIN OF ty_vend ,
57             lifnr   LIKE lfa1-lifnr ,
58             END  OF ty_vend.
59
60     DATA : wa_bsik LIKE ist_srcbsik.
61     DATA : wa_lfa1  TYPE ty_lifnr.
62
63     DATA : ist_lifnr1  TYPE STANDARD TABLE OF  ty_lifnr WITH HEADER LINE.
64
65     DATA : ist_lifnr    TYPE STANDARD TABLE OF  ty_vend  WITH HEADER LINE.
66
67
68     DATA: ist_msg_f53 TYPE TABLE OF bdcmsgcoll WITH HEADER LINE.
69     DATA: ist_msg_fch TYPE TABLE OF bdcmsgcoll WITH HEADER LINE.
70
71     DATA: ist_msgs TYPE TABLE OF bdcmsgcoll WITH HEADER LINE.
72
73     DATA:   bdcdata LIKE bdcdata    OCCURS 0 WITH HEADER LINE.
74     DATA : ist_doc TYPE STANDARD TABLE OF zfi_cp_vend_docs  WITH HEADER LINE
75     .
76     DATA :wa_doc  TYPE zfi_cp_vend_docs.
77
78     *-------------global variables -------------------*
79
80     DATA : g_tclin TYPE i .
81     DATA : g_tclin2 TYPE i .
82     DATA : g_msgd(120).
83     DATA : g_msgc(120).
84     DATA : mark(1)   .
85     DATA :selcbox(1).
86     DATA : g_tc_copied(1).
87     DATA : g_tc_copied2(1).
88     DATA : p_ch1(1) VALUE  'X'.
89     DATA : g_answer(1).
90     DATA : g_count2  TYPE i .
91     DATA : g_count3  TYPE i .
92     DATA : g_syvar(16).
93     DATA : g_gjahr  LIKE bseg-gjahr ,
94            g_checl  LIKE pcec-checl ,
95            g_cheq  LIKE pcec-checl ,
96            g_refdoc LIKE bseg-belnr.
97
98     DATA : g_count  TYPE i ,
99            g_lifnr  TYPE lfa1-lifnr.
100    DATA : g_ok_code1 TYPE sy-ucomm.
101    DATA : g_ok_code2 TYPE sy-ucomm.
102    DATA : g_tot_amt(17) . " like bseg-wrbtr.
103    *-------------constants ----------------------------*
104    CONSTANTS  : g_zlspr_x   LIKE bseg-zlspr  VALUE 'X',
105                 g_zlspr_s   LIKE bseg-zlspr VALUE ' '.
106
107    DATA : OK_CODE_100 TYPE SY-UCOMM,
108           OK_CODE_200 TYPE SY-UCOMM.
109
110    DATA L_INDEX(3) TYPE N.
111    *-----------------selection screen -------------------*
112    DATA l_flag.
113    DATA l_c.
114    DATA l_err.
115    SELECTION-SCREEN :  BEGIN OF BLOCK blk1 .
116
117
118
119    PARAMETERS :   p_budat LIKE bkpf-budat obligatory,
120    *             p_blart like bkpf-blart,   hardcoded
121                  p_bukrs LIKE bkpf-bukrs obligatory,
122                  p_hbkid LIKE payr-hbkid obligatory,  " house bacnk id
123                  p_hktid LIKE payr-hktid obligatory,   " account id
124                  p_bhkont LIKE   bseg-hkont obligatory,
125                  p_rzawe LIKE   payr-rzawe obligatory,   " pay method
126                  p_stapl LIKE pcec-stapl obligatory.
127    SELECT-OPTIONS : s_lifnr  FOR lfb1-lifnr obligatory .
128
129    SELECTION-SCREEN :  END OF BLOCK blk1 .
130
131
132
133    *------------events on selction screen----------------*
134    AT SELECTION-SCREEN ON p_bukrs .
135      SELECT SINGLE * FROM t001  WHERE bukrs = p_bukrs.
136      IF sy-subrc <> 0.
137        MESSAGE e010(fi)  WITH p_bukrs.
138      ENDIF.
139
140    AT SELECTION-SCREEN ON p_budat .
141      IF p_budat > sy-datum.
142        MESSAGE e316(zfi).
143      ENDIF.
*--- End of ZFI_CP_MASS_VEN_PAY_TOP - 143 lines ---

----------------------------------------------------------------------------------------------------
Include          ZFI_CP_MAS_VEN_AI001                      Level 1    Page 3
Object           ZFI_CP_MASS_VEN_PAY                       Lines 508
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:03
----------------------------------------------------------------------------------------------------
1
2      *----------------------------------------------------------------------*
3      *   INCLUDE ZFI_CP_MAS_VEN_AI001                                       *
4      *----------------------------------------------------------------------*
5
6      *&---------------------------------------------------------------------*
7      *&      Form  get_open_items
8      *&---------------------------------------------------------------------*
9      *       text
10     *----------------------------------------------------------------------*
11     *  -->  p1        text
12     *  <--  p2        text
13     *----------------------------------------------------------------------*
14     form get_open_items.
15       if not g_lifnr  is initial.
16         clear ist_srcbsik.
17         refresh ist_srcbsik.
18         SELECT bukrs lifnr umskz gjahr belnr buzei budat bschl
19          zlsch zlspr shkzg dmbtr wrbtr zfbdt APPENDING
20         CORRESPONDING FIELDS OF TABLE
21                        ist_srcbsik  FROM bsik
22                        WHERE
23                        bukrs  =  p_bukrs
24                    and lifnr  =  g_lifnr.
25
26
27         delete  ist_srcbsik where zfbdt > p_budat.
28     *delete  ist_srcbsik where zlsch = 'A'.
29
30         delete  ist_srcbsik where zlspr = 'A'.
31
32
33         ist_bsiks[] = ist_srcbsik[].
34
35
36         REFRESH ist_srcbsik.
37         CLEAR ist_srcbsik.
38
39
40         LOOP AT ist_bsiks .
41           IF ist_bsiks-umskz = 'P' OR ist_bsiks-umskz = 'F'  OR
42           ist_bsiks-umskz  IS INITIAL.
43             ist_srcbsik = ist_bsiks.
44             APPEND ist_srcbsik.
45             CLEAR ist_srcbsik.
46           ENDIF.
47         ENDLOOP.
48
49
50
51         CHECK  NOT ist_srcbsik[] IS INITIAL.
52
53         LOOP AT ist_srcbsik.
54           IF ist_srcbsik-shkzg = 'S'.
55     *      ist_srcbsik-dmbtr = ist_srcbsik-dmbtr.
56             ist_srcbsik-amount = ist_srcbsik-wrbtr.
57           ELSEIF ist_srcbsik-shkzg = 'H'.
58     *      ist_srcbsik-dmbtr = - ist_srcbsik-dmbtr.
59             ist_srcbsik-amount = - ist_srcbsik-wrbtr.
60           ENDIF.
61     *{cr 300126666
62           SELECT SINGLE ZWELS FROM LFB1
63             INTO ist_srcbsik-ZWELS
64             WHERE LIFNR = ist_srcbsik-LIFNR
65               AND BUKRS = ist_srcbsik-BUKRS.
66     *{cr 300126666
67           MODIFY ist_srcbsik .
68           clear ist_srcbsik.
69         ENDLOOP.
70
71         sort ist_srcbsik by  belnr bschl budat.
72
73       endif.
74       clear ist_bsiks.
75       refresh ist_bsiks.
76     endform.
77     *&---------------------------------------------------------------------*
78     *&      Module  exit  INPUT
79     *&---------------------------------------------------------------------*
80     *       text
81     *----------------------------------------------------------------------*
82     module exit input.
83       leave program.
84     endmodule.                 " exit  INPUT
85     *&---------------------------------------------------------------------*
86     *&      Module  reaD_OP_ITEMS  INPUT
87     *&---------------------------------------------------------------------*
88     *       text
89     *----------------------------------------------------------------------*
90     module reaD_OP_ITEMS input.
91       MODIFY ist_srcbsik from wa_bsik INDEX  tc_op_it-current_line.
92
93     endmodule.                 " reaD_OP_ITEMS  INPUT
94
95     *&---------------------------------------------------------------------*
96     *&      Module  read_table_control  INPUT
97     *&---------------------------------------------------------------------*
98     *       text
99     *----------------------------------------------------------------------*
100    MODULE read_table_control INPUT.
101      MODIFY ist_lifnr1 FROM wa_lfa1 INDEX  tc_vend-current_line.
102      CLEAR mark.
103    ENDMODULE.                 " read_table_control  INPUT
104    *&---------------------------------------------------------------------*
105    *&      Module  user_command_0100  INPUT
106    *&---------------------------------------------------------------------*
107    *       text
108    *----------------------------------------------------------------------*
109    MODULE user_command_0100 INPUT.
110      g_ok_code1 = sy-ucomm.
111    *  g_ok_code1 = OK_CODE_100.
112      CASE g_ok_code1.
113        WHEN  'BACK'.
114          SET SCREEN 0 .
115        WHEN  'CANC'.
116          LEAVE PROGRAM .
117    *-----payment summary-----------------*
118        WHEN 'PAYS' .
119
120          LEAVE TO LIST-PROCESSING.
121          CLEAR g_lifnr .
122          LOOP AT ist_lifnr1 WHERE mark = 'X'.
123            g_count =  g_count + 1 .
124            g_lifnr = ist_lifnr1-lifnr.
125          ENDLOOP.
126          IF g_count  = 0.
127            MESSAGE e314(zfi).
128          ENDIF.
129
130          SELECT *  INTO TABLE ist_doc FROM zfi_cp_vend_docs  WHERE
131               bukrs = p_bukrs
132              AND lifnr = g_lifnr
133              AND budat = p_budat.
134
135          IF NOT ist_doc[] IS INITIAL.
136            FORMAT COLOR COL_HEADING .
137            WRITE :/ text-006, text-007 , text-008 , text-009 , text-010 , "#EC CI_NOORDER
138    text-011.
139            WRITE :/ sy-uline. "#EC CI_NOORDER
140            FORMAT   COLOR COL_NORMAL.
141            LOOP AT ist_doc.
142              WRITE :/ ist_doc-bukrs , ist_doc-budat , ist_doc-lifnr , "#EC CI_NOORDER
143       ist_doc-belnr, ist_doc-pdocnr, ist_doc-checl.  "#EC CI_NOORDER
144            ENDLOOP.
145          ENDIF.
146          LEAVE TO SCREEN '0100'.
147    *------process open items proceed
148        WHEN 'PROC'.
149          CLEAR g_count .
150          LOOP AT ist_lifnr1 WHERE mark = 'X'.
151            g_count =  g_count + 1 .
152          ENDLOOP.
153          IF g_count > 1.
154            MESSAGE e313(zfi) .
155          ELSEIF   g_count = 1.
156            CLEAR g_lifnr.
157            READ TABLE ist_lifnr1 WITH KEY  mark = 'X'.
158            IF sy-subrc = 0.
159              g_lifnr =  ist_lifnr1-lifnr.
160            ENDIF.
161          ELSEIF g_count  = 0.
162            MESSAGE e314(zfi).
163          ENDIF.
164    *------------selct open items
165          PERFORM  get_open_items.
166
167          CALL SCREEN 200 .
168    * leave program.
169
170        when 'ASC'.
171          sort ist_lifnr1 by lifnr ascending.
172        when 'DES'.
173          sort ist_lifnr1 by lifnr DEScending.
174        when 'FILT'.
175          PERFORM filter_data.
176      ENDCASE.
177    ENDMODULE.                 " user_command_0100  INPUT
178    *&---------------------------------------------------------------------*
179    *&      Module  USER_COMMAND_0200  INPUT
180    *&---------------------------------------------------------------------*
181    *       text
182    *----------------------------------------------------------------------*
183    MODULE user_command_0200 INPUT.
184
185      DATA:  field_count TYPE i.
186
187      FIELD-SYMBOLS: <field> TYPE ANY,
188                    <wa> TYPE ANY.
189
190      DATA: ls_comp TYPE abap_componentdescr,
191             ls_stru TYPE REF TO cl_abap_structdescr,
192             lt_comp TYPE STANDARD TABLE OF abap_componentdescr WITH KEY name.
193
194
195      DATA : ls_ist_srcbsik like LINE OF ist_srcbsik. " UCCHECK
196
197      FIELD-SYMBOLS:  <lfs_first>.
198
199      data wa like LINE OF TC_OP_IT-COLS.
200
201      g_ok_code2 = sy-ucomm .
202      CASE g_ok_code2.
203        WHEN 'CANC'.
204          leave program.
205        WHEN 'CALC'.
206    *-----calculate total amount
207          PERFORM  cal_tot_amt.
208
209        WHEN 'BACK'.
210          SET SCREEN  '0100'.
211    *      SET CURSOR FIELD ON G_LIFNR.
212        WHEN 'POST'.
213          perform pre_post_checks.
214          if l_err <> 'X'.
215            PERFORM  cal_tot_amt.
216
217            if l_flag <> 'N'.
218              IF NOT g_tot_amt IS INITIAL.
219                IF g_tot_amt > 0 .
220                  MESSAGE e315(zfi).
221                ELSEIF g_tot_amt < 0.
222                  g_tot_amt = ( -1 ) * g_tot_amt .
223                ENDIF.
224    *----get user confimation for prceeding-----*
225                PERFORM  get_confirmation.
226                IF g_answer = 1.
227    *-------rem payemnt block-----*
228                  PERFORM  rem_pay_block.
229    *-----------bdc f-53 ---------*
230                  PERFORM  bdc_f53.
231    *---------messages  f-53 -------*
232                  PERFORM  get_mesg_f53.
233
234                  IF NOT g_refdoc IS  INITIAL.
235                    IF  p_ch1 = 'X'.
236    *----------generate cheque number
237                      PERFORM gen_chec_number .
238                      LEAVE TO  SCREEN '0100'.
239                    ELSE.
240                      LEAVE TO  SCREEN '0100'.
241                    ENDIF.
242                  ELSE.
243                    LEAVE TO SCREEN '0100'.
244                  ENDIF.
245                ELSE.
246                  LEAVE TO  SCREEN '0100'.
247                ENDIF.
248              endif.
249            else.
250    *        leave to screen 0.
251            ENDIF.
252          endif.
253        when 'POS'.
254
255
256    *  sval_tab-tabname    = 'OIUOW_TR_WK'.
257    *  sval_tab-fieldname  = 'TR_NO'.
258    *  sval_tab-fieldtext  = 'Tract No'(007).
259    *  append sval_tab.
260          clear : sval_tab.
261          refresh : sval_tab.
262
263          sval_tab-tabname    = 'BSIK'.
264          sval_tab-fieldname  = 'BELNR'.
265          sval_tab-fieldtext  = 'DOCUMENT No'(012).
266          append sval_tab.
267
268    *      sval_tab-tabname    = 'BSIK'.
269    *      sval_tab-fieldname  = 'LIFNR'.
270    *      sval_tab-fieldtext  = 'VENDOR'(008).
271    *      append sval_tab.
272
273    *      sval_tab-tabname    = 'BSIK'.
274    *      sval_tab-fieldname  = 'GJAHR'.
275    *      sval_tab-fieldtext  = 'YEAR'(013).
276    *      append sval_tab.
277
278          sval_tab-tabname    = 'BSIK'.
279          sval_tab-fieldname  = 'BUZEI'.
280          sval_tab-fieldtext  = 'Line Item'(015).
281          append sval_tab.
282
283          sval_tab-tabname    = 'BSIK'.
284          sval_tab-fieldname  = 'WRBTR'.
285          sval_tab-fieldtext  = 'Amount'(016).
286          append sval_tab.
287    *
288    *      sval_tab-tabname    = 'WA_BSIK'.
289    *      sval_tab-fieldname  = 'AMOUNT'.
290    *      sval_tab-fieldtext  = 'Amount'(016).
291    *      append sval_tab.
292
293          call function 'POPUP_GET_VALUES_USER_HELP'
294                exporting
295    *           F1_FORMNAME               = ' '
296    *           F1_PROGRAMNAME            = ' '
297    *           F4_FORMNAME               = ' '
298    *           F4_PROGRAMNAME            = ' '
299    *           FORMNAME                  = ' '
300                     popup_title               = 'Filter Criteria'(014)
301    *           PROGRAMNAME               = ' '
302    *           START_COLUMN              = '5'
303    *           START_ROW                 = '5'
304    *           NO_CHECK_FOR_FIXED_VALUES = ' '
305    *      IMPORTING
306    *           RETURNCODE                =
307                tables
308                     fields                    = sval_tab
309    *      EXCEPTIONS
310    *           ERROR_IN_FIELDS           = 1
311    *           OTHERS                    = 2
312                     .
313
314          if rcode eq 'A'.                     "user cancels from pop up box
315            exit.
316          endif.
317
318          loop at ist_srcbsik into WA_BSIK where selcbox = 'X'.
319            WA_BSIK-selcbox = ''.
320            modify ist_srcbsik from WA_BSIK TRANSPORTING selcbox.
321          endloop.
322
323
324    *      loop at sval_tab.
325    *    read table trtc_tab with key tr_no = sval_tab-value.
326          read TABLE sval_tab INTO WA_sval_tab_B WITH KEY fieldname = 'BELNR'.
327          if sy-subrc = 0.
328            read TABLE sval_tab INTO WA_sval_tab_BU WITH KEY fieldname = 'BUZEI'.
329            if sy-subrc = 0.
330              if not sval_tab-value is initial.
331                read table ist_srcbsik with key belnr = WA_sval_tab_B-value
332                                                BUZEI = WA_sval_tab_BU-VALUE.
333              endif.
334            ELSE.
335              if not sval_tab-value is initial.
336                read table ist_srcbsik with key belnr = sval_tab-value.
337              endif.
338            ENDIF.
339            tc_op_it-top_line = sy-tabix.
340    *SELECT THE LINE
341
342            IF NOT WA_sval_tab_BU-VALUE IS INITIAL.
343              loop at ist_srcbsik into WA_BSIK where belnr = WA_sval_tab_B-value
344                                                     AND BUZEI = WA_sval_tab_BU-VALUE.
345                WA_BSIK-selcbox = 'X'.
346                modify ist_srcbsik from WA_BSIK TRANSPORTING selcbox.
347              endloop.
348            ELSE.
349              loop at ist_srcbsik into WA_BSIK where belnr = WA_sval_tab_B-value.
350
351                WA_BSIK-selcbox = 'X'.
352                modify ist_srcbsik from WA_BSIK TRANSPORTING selcbox.
353              endloop.
354            ENDIF.
355            exit.
356          ELSE.
357
358            read TABLE sval_tab INTO WA_sval_tab_BU WITH KEY fieldname = 'BUZEI'.
359            if sy-subrc = 0.
360              if not sval_tab-value is initial.
361                read table ist_srcbsik with key buzei = sval_tab-value.
362              endif.
363              tc_op_it-top_line = sy-tabix.
364    *SELECT THE LINE
365
366
367              loop at ist_srcbsik into wa_bsik "WA_sval_tab
368                where  BUZEI = WA_sval_tab_BU-VALUE.
369                WA_bsik-selcbox = 'X'.
370                modify ist_srcbsik from WA_bsik TRANSPORTING selcbox.
371              endloop.
372              exit.
373            endif.
374
375    *          read TABLE sval_tab WITH KEY fieldname = 'LIFNR'.
376    *          if sy-subrc = 0.
377    *            if not sval_tab-value is initial.
378    *              read table ist_srcbsik with key LIFNR = sval_tab-value.
379    *            endif.
380    *            tc_op_it-top_line = sy-tabix.
381    **SELECT THE LINE
382    *          loop at ist_srcbsik into WA_sval_tab where LIFNR = WA_sval_tab-value
383    *                                                 AND BUZEI = WA_sval_tab_2-VALUE.
384    *            WA_sval_tab-mark = 'X'.
385    *            modify ist_srcbsik from WA_sval_tab TRANSPORTING mark.
386    *          endloop.
387    *            exit.
388    *          endif.
389
390            read TABLE sval_tab INTO WA_sval_tab_AM WITH KEY fieldname = 'WRBTR'.
391            if sy-subrc = 0.
392              if not sval_tab-value is initial.
393                read table ist_srcbsik with key AMOUNT = sval_tab-value.
394              endif.
395              tc_op_it-top_line = sy-tabix.
396    *SELECT THE LINE
397              loop at ist_srcbsik into wa_bsik" WA_sval_tab
398                where belnr = WA_sval_tab-value   "uccheck
399                                                     AND BUZEI = WA_sval_tab_AM-VALUE.
400                WA_bsik-selcbox = 'X'.
401                modify ist_srcbsik from WA_bsik TRANSPORTING selcbox.
402              endloop.
403
404
405
406              exit.
407            endif.
408
409            IF NOT WA_sval_tab_AM-VALUE IS INITIAL AND NOT WA_sval_tab_BU-VALUE IS INITIAL AND NOT WA_sval_tab-VALUE IS INITIAL.
410              loop at ist_srcbsik into wa_bsik"WA_sval_tab
411                 where belnr = WA_sval_tab_B-value
412                                                     AND BUZEI = WA_sval_tab_AM-VALUE
413                                                     AND AMOUNT = WA_sval_tab_AM-VALUE.
414                WA_bsik-selcbox = 'X'.
415                modify ist_srcbsik from WA_bsik TRANSPORTING selcbox.
416              endloop.
417              exit.
418            ENDIF.
419
420    *    tc_tract_detail-top_line = sy-tabix.
421          ENDIF.
422    *      endloop.
423    *ist_srcbsik
424
425        when 'ASC'.
426
427    *        DATA: l_repid TYPE sy-repid.
428    *  DATA: l_t_comp TYPE rstrucinfo OCCURS 0 WITH HEADER LINE.
429          CLEAR WA.
430          read table TC_OP_IT-COLS into wa WITH KEY selected = 'X'.
431
432          ls_comp-name = WA-SCREEN-NAME+8.
433    *      l_repid = sy-repid.
434    *      l_repid = 'ZFI_CP_MAS_VEN_AI001'.
435    *      CALL FUNCTION 'GET_COMPONENT_LIST'
436    *        EXPORTING
437    *          program    = l_repid
438    *          fieldname  = 'IST_SRCBSIK'
439    *        TABLES
440    *          components = l_t_comp[]
441    *        EXCEPTIONS
442    *          OTHERS     = 1.
443
444
445    ****Assign field symbol here
446    **  ls_stru ?= cl_abap_typedescr=>describe_by_data( <lfs_first> ).
447    *      ls_stru ?= cl_abap_typedescr=>describe_by_data( WA_BSIK ).
448    *      lt_comp = ls_stru->get_components( ).
449    *
450    **  LOOP AT ut_comp INTO ls_comp.
451    **    CASE ls_comp-name.
452    **    WHEN #COMPONENT_NAME#.
453    **** write some code here
454    **
455    **    ENDCASE.
456    **  ENDLOOP.
457    *      L_INDEX = wa-INDEX + 1.
458    *      READ TABLE Lt_comp INTO ls_comp INDEX L_INDEX.
459          CASE ls_comp-name.
460    *    WHEN #COMPONENT_NAME#.
461    *** write some code here
462            WHEN 'LIFNR'.
463              sort ist_srcbsik by LIFNR ascending.
464            WHEN 'BELNR'.
465              sort ist_srcbsik by belnr ascending.
466            WHEN 'AMOUNT'.
467              sort ist_srcbsik by AMOUNT ascending.
468            WHEN 'BUZEI'.
469              sort ist_srcbsik by BUZEI ascending.
470            WHEN 'BUDAT'.
471              sort ist_srcbsik by BUDAT ascending.
472          ENDCASE.
473
474    *LOOP AT ist_srcbsik ASSIGNING <wa>.
475    *  field_count = wa-INDEX.
476    **  DO.
477    *    ASSIGN COMPONENT field_count OF STRUCTURE <wa> TO <field>.
478    *    IF sy-subrc IS NOT INITIAL.
479    *      EXIT.
480    *    ENDIF.
481    **    ...build your output string from <field> and pipe, output to new table
482    **    ADD 1 TO field_count.
483    **  ENDDO.
484    *ENDLOOP.
485
486        when 'DES'.
487          CLEAR WA.
488          read table TC_OP_IT-COLS into wa WITH KEY selected = 'X'.
489          ls_comp-name = WA-SCREEN-NAME+8.
490    *      L_INDEX = wa-INDEX + 1.
491    *      READ TABLE Lt_comp INTO ls_comp INDEX L_INDEX.
492          CASE ls_comp-name.
493    *    WHEN #COMPONENT_NAME#.
494    *** write some code here
495            WHEN 'LIFNR'.
496              sort ist_srcbsik by LIFNR descending.
497            WHEN 'BELNR'.
498              sort ist_srcbsik by belnr descending.
499            WHEN 'AMOUNT'.
500              sort ist_srcbsik by AMOUNT descending.
501            WHEN 'BUZEI'.
502              sort ist_srcbsik by BUZEI descending.
503            WHEN 'BUDAT'.
504              sort ist_srcbsik by BUDAT descending.
505          ENDCASE.
506
507      ENDCASE.
508    ENDMODULE.                 " USER_COMMAND_0200  INPUT
*--- End of ZFI_CP_MAS_VEN_AI001 - 508 lines ---

----------------------------------------------------------------------------------------------------
Include          ZFI_CP_MAS_VEN_BO001                      Level 1    Page 4
Object           ZFI_CP_MASS_VEN_PAY                       Lines 99
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:03
----------------------------------------------------------------------------------------------------
1      *----------------------------------------------------------------------*
2      *   INCLUDE ZFI_CP_MAS_VEN_BO001                                       *
3      *----------------------------------------------------------------------*
4      *&---------------------------------------------------------------------*
5      *&      Module  set_screen_status  OUTPUT
6      *&---------------------------------------------------------------------*
7      *       text
8      *----------------------------------------------------------------------*
9      module set_screen_status output.
10      LOOP AT SCREEN .
11      if screen-group1 = 'GR1'.
12         screen-input = 0.
13          MODIFY SCREEN.
14       else.
15         screen-input = 1.
16          MODIFY SCREEN.
17       endif.
18       ENDLOOP.
19
20     endmodule.                 " set_screen_status  OUTPUT
21     *&---------------------------------------------------------------------*
22     *&      Module  STATUS_0200  OUTPUT
23     *&---------------------------------------------------------------------*
24     *       text
25     *----------------------------------------------------------------------*
26     module STATUS_0200 output.
27       SET PF-STATUS 'S200'.
28     *  SET TITLEBAR 'xxx'.
29     SET TITLEBAR 'OPI' ."WITH text-010 g_ok_code1.
30
31
32     endmodule.                 " STATUS_0200  OUTPUT
33     *&---------------------------------------------------------------------*
34     *&      Module  int_tc_op_it  OUTPUT
35     *&---------------------------------------------------------------------*
36     *       text
37     *----------------------------------------------------------------------*
38     module int_tc_op_it output.
39     DESCRIBE TABLE ist_srcbsik  LINES g_tclin2.
40       tc_op_it-lines = g_tclin2.
41
42     endmodule.                 " int_tc_op_it  OUTPUT
43     *&---------------------------------------------------------------------*
44     *&      Module  move_tc_op_it  OUTPUT
45     *&---------------------------------------------------------------------*
46     *       text
47     *----------------------------------------------------------------------*
48     module move_tc_op_it output.
49      IF NOT ist_srcbsik[]  IS INITIAL .
50         MOVE-CORRESPONDING  ist_srcbsik TO  wa_bsik.
51       ENDIF.
52
53     endmodule.                 " move_tc_op_it  OUTPUT
54     *&---------------------------------------------------------------------*
55     *&      Module  REFRESH_TC_OP_IT  OUTPUT
56     *&---------------------------------------------------------------------*
57     *       text
58     *----------------------------------------------------------------------*
59     module REFRESH_TC_OP_IT output.
60     *clear g_tot_amt.
61      IF g_tc_copied2 IS INITIAL.
62         g_tc_copied2 = 'X'.
63      REFRESH CONTROL 'TC_OP_IT' FROM SCREEN '0200'.
64       ENDIF.
65
66     endmodule.                 " REFRESH_TC_OP_IT  OUTPUT
67     *&---------------------------------------------------------------------*
68     *&      Module  INT_TC_vend  OUTPUT
69     *&---------------------------------------------------------------------*
70     *       text
71     *----------------------------------------------------------------------*
72     MODULE int_tc_vend OUTPUT.
73       DESCRIBE TABLE ist_lifnr1  LINES g_tclin.
74       tc_vend-lines = g_tclin.
75     ENDMODULE.                 " INT_TC_vend  OUTPUT
76     *&---------------------------------------------------------------------*
77     *&      Module  MOVE_Tc_vend  OUTPUT
78     *&---------------------------------------------------------------------*
79     *       text
80     *----------------------------------------------------------------------*
81     MODULE move_tc_vend OUTPUT.
82       IF NOT ist_lifnr1[]  IS INITIAL .
83         MOVE-CORRESPONDING  ist_lifnr1 TO  wa_lfa1.
84       ENDIF.
85     ENDMODULE.                 " MOVE_Tc_vend  OUTPUT
86     *&---------------------------------------------------------------------*
87     *&      Module  STATUS_0100  OUTPUT
88     *&---------------------------------------------------------------------*
89     *       text
90     *----------------------------------------------------------------------*
91     MODULE status_0100 OUTPUT.
92       SET PF-STATUS 'S100'.
93       SET TITLEBAR 'TTL'.
94
95       IF g_tc_copied IS INITIAL.
96         g_tc_copied = 'X'.
97         REFRESH CONTROL 'TC_VEND' FROM SCREEN '0100'.
98       ENDIF.
99     ENDMODULE.                 " STATUS_0100  OUTPUT
*--- End of ZFI_CP_MAS_VEN_BO001 - 99 lines ---

----------------------------------------------------------------------------------------------------
Include          ZFI_CP_MAS_VEN_E0001                      Level 1    Page 5
Object           ZFI_CP_MASS_VEN_PAY                       Lines 863
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:03
----------------------------------------------------------------------------------------------------
1      *----------------------------------------------------------------------*
2      *   INCLUDE ZFI_CP_MAS_VEN_E0001                                       *
3      *----------------------------------------------------------------------*
4      *&---------------------------------------------------------------------*
5      *&      Form  cal_tot_amt
6      *&---------------------------------------------------------------------*
7      *       text
8      *----------------------------------------------------------------------*
9      *  -->  p1        text
10     *  <--  p2        text
11     *----------------------------------------------------------------------*
12     FORM cal_tot_amt.
13
14       CLEAR ist_srcbsik.
15       CLEAR g_tot_amt.
16
17       CLEAR g_count2 .
18       LOOP AT ist_srcbsik WHERE selcbox = 'X'.
19         g_count2 =  g_count2 + 1 .
20       ENDLOOP.
21
22       IF g_count2  = 0.
23         MESSAGE e286(zfi).
24       ENDIF.
25
26
27       CLEAR g_tot_amt.
28       LOOP AT ist_srcbsik  WHERE  selcbox = 'X'.
29         IF sy-subrc = 0.
30           g_tot_amt = g_tot_amt  +  ist_srcbsik-amount .
31         ENDIF.
32       ENDLOOP.
33     ENDFORM.               " cal_tot_amt
34     *&---------------------------------------------------------------------*
35     *&      Form  get_confirmation
36     *&---------------------------------------------------------------------*
37     *       text
38     *----------------------------------------------------------------------*
39     *  -->  p1        text
40     *  <--  p2        text
41     *----------------------------------------------------------------------*
42     FORM get_confirmation.
43       CALL FUNCTION 'POPUP_TO_CONFIRM'
44         EXPORTING
45           titlebar              = 'Confirmation for posting'
46           text_question         = text-001
47           display_cancel_button = ' '
48           start_column          = 25
49           start_row             = 6
50         IMPORTING
51           answer                = g_answer
52         EXCEPTIONS
53           text_not_found        = 1
54           OTHERS                = 2.
55       IF sy-subrc <> 0.
56     * MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
57     *         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
58       ENDIF.
59
60
61     ENDFORM.                    " get_confirmation
62     *&---------------------------------------------------------------------*
63     *&      Form  rem_pay_block
64     *&---------------------------------------------------------------------*
65     *       text
66     *----------------------------------------------------------------------*
67     *  -->  p1        text
68     *  <--  p2        text
69     *----------------------------------------------------------------------*
70     FORM rem_pay_block.
71
72       DATA : l_tabix TYPE sy-tabix.
73
74       CHECK NOT ist_srcbsik[] IS INITIAL.
75
76       CLEAR  ist_bsiks.
77       REFRESH ist_bsiks.
78
79       ist_bsiks[] = ist_srcbsik[].
80
81       DELETE ist_bsiks WHERE  selcbox <> 'X'.
82     *perform check if pyord exists if so do not pass those records to BDC
83       clear : ist_bsiks_omit,ist_bsiks_vblk.
84       refresh : ist_bsiks_omit,ist_bsiks_vblk.
85
86       loop at ist_bsiks into wa_bsik.
87         select single * FROM zfi_bcm_payordr
88           where lifnr = wa_bsik-lifnr
89             and belnr = wa_bsik-belnr
90           and pyord <> ''
91           and zstatus in ('001','002').
92
93         if sy-subrc = 0.
94           append wa_bsik to ist_bsiks_omit.
95           delete ist_bsiks
96           where lifnr = wa_bsik-lifnr
97                   and belnr = wa_bsik-belnr.
98         endif.
99         select single *
100          from lfa1
101          where lifnr = wa_bsik-lifnr
102          and sperr = 'X'.
103        if sy-subrc = 0.
104          append wa_bsik to ist_bsiks_vblk.
105          delete ist_bsiks
106          where lifnr = wa_bsik-lifnr.
107        endif.
108      endloop.
109      IF NOT ist_bsiks[] IS  INITIAL.
110
111        CLEAR bsik.
112        CLEAR wa_bsik_t.
113
114        SELECT * INTO TABLE ist_bsik   FROM bsik
115          FOR ALL ENTRIES  IN  ist_bsiks
116          WHERE   lifnr = ist_bsiks-lifnr
117                AND  bukrs  =  p_bukrs
118                 AND gjahr = ist_bsiks-gjahr
119                 AND belnr = ist_bsiks-belnr
120                 AND buzei = ist_bsiks-buzei.
121
122        IF NOT ist_bsik IS INITIAL.
123
124          CLEAR l_tabix.
125          LOOP AT ist_bsik INTO wa_bsik_t.
126            l_tabix = sy-tabix.
127            IF wa_bsik_t-zlspr = g_zlspr_x.
128              wa_bsik_t-zlspr =  g_zlspr_s.
129              MODIFY ist_bsik  FROM  wa_bsik_t INDEX l_tabix  TRANSPORTING zlspr.
130            ENDIF.
131          ENDLOOP.
132
133
134    *      MODIFY  bsik FROM TABLE ist_bsik.
135        ENDIF.
136
137        CLEAR bseg.
138        CLEAR wa_bseg.
139
140        SELECT * INTO TABLE ist_bseg   FROM bseg
141          FOR ALL ENTRIES  IN  ist_bsiks
142          WHERE   lifnr = ist_bsiks-lifnr
143                AND  bukrs  =  p_bukrs
144                 AND gjahr = ist_bsiks-gjahr
145                 AND belnr = ist_bsiks-belnr
146                 AND buzei = ist_bsiks-buzei ORDER BY PRIMARY KEY.
147
148        IF NOT ist_bseg IS INITIAL.
149
150          CLEAR l_tabix.
151          LOOP AT ist_bseg INTO wa_bseg.
152            l_tabix = sy-tabix.
153            IF wa_bseg-zlspr = g_zlspr_x.
154              wa_bseg-zlspr =  g_zlspr_s.
155              MODIFY ist_bseg  FROM  wa_bseg INDEX l_tabix  TRANSPORTING zlspr.
156            ENDIF.
157          ENDLOOP.
158
159
160    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
161    * S/4: BSEG payment block (ZLSPR) via FI_DOCUMENT_CHANGE (FB02); direct write not allowed.
162    *      MODIFY  bseg FROM TABLE ist_bseg.
163          LOOP AT ist_bseg INTO wa_bseg.
164            PERFORM zz_s4_bseg_zlspr USING wa_bseg-bukrs wa_bseg-belnr wa_bseg-gjahr wa_bseg-buzei wa_bseg-zlspr.
165          ENDLOOP.
166          COMMIT WORK.
167    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
168
169        ENDIF.
170
171      ENDIF.
172    ENDFORM.                    " rem_pay_block
173    *&---------------------------------------------------------------------*
174    *&      Form  bdc_f53
175    *&---------------------------------------------------------------------*
176    *       text
177    *----------------------------------------------------------------------*
178    *  -->  p1        text
179    *  <--  p2        text
180    *----------------------------------------------------------------------*
181    FORM bdc_f53.
182
183      CLEAR bdcdata.
184      REFRESH bdcdata.
185
186      DESCRIBE TABLE  ist_bsiks LINES g_count3.
187
188      DATA : l_setdat(10).
189      DATA : l_count(1).
190
191    if not ist_bsiks[] is initial.
192
193      WRITE p_budat TO l_setdat  DD/MM/YYYY.
194
195
196
197      PERFORM bdc_dynpro      USING 'SAPMF05A' '0103'.
198      PERFORM bdc_field       USING 'BDC_CURSOR'
199                                    'RF05A-XPOS1(03)'.
200      PERFORM bdc_field       USING 'BDC_OKCODE'
201                                    '=PA'.
202      PERFORM bdc_field       USING 'BKPF-BLDAT'
203                                    l_setdat.
204      PERFORM bdc_field       USING 'BKPF-BLART'
205                                    'BP'.
206      PERFORM bdc_field       USING 'BKPF-BUKRS'
207                                    p_bukrs.
208      PERFORM bdc_field       USING 'BKPF-BUDAT'
209                                    l_setdat.
210    *perform bdc_field       using 'BKPF-MONAT'
211    *                              '12'.
212      PERFORM bdc_field       USING 'BKPF-WAERS'
213                                    'INR'.
214      PERFORM bdc_field       USING 'RF05A-KONTO'
215                                     p_bhkont.
216      PERFORM bdc_field       USING 'BSEG-WRBTR'
217                                     g_tot_amt.
218      PERFORM bdc_field       USING 'BSEG-VALUT'
219                                    l_setdat.
220    *read table  ist_bsiks index 1.
221
222      PERFORM bdc_field       USING 'RF05A-AGKON'
223                                    g_lifnr.
224      PERFORM bdc_field       USING 'RF05A-AGKOA'
225                                    'K'.
226      PERFORM bdc_field       USING 'RF05A-AGUMS'
227                                    'PF'.               "+ Change on 05-07-2013 by Vikas
228      PERFORM bdc_field       USING 'RF05A-XNOPS'
229                                    'X'.
230      PERFORM bdc_field       USING 'RF05A-XPOS1(01)'
231                                    ''.
232      PERFORM bdc_field       USING 'RF05A-XPOS1(03)'
233                                    'X'.
234
235      PERFORM bdc_dynpro      USING 'SAPMF05A' '0731'.
236      PERFORM bdc_field       USING 'BDC_CURSOR'
237                                    'RF05A-SEL01(01)'.
238
239      l_count = 0.
240      LOOP AT ist_bsiks.
241
242        IF l_count = 6.
243
244
245          PERFORM bdc_dynpro      USING 'SAPMF05A' '0731'.
246          PERFORM bdc_field       USING 'BDC_CURSOR'
247                                        'RF05A-SEL01(01)'.
248          PERFORM bdc_field       USING 'BDC_OKCODE'
249                                        '=SL2'.
250
251          PERFORM bdc_dynpro      USING 'SAPMF05A' '0608'.
252          PERFORM bdc_field       USING 'BDC_CURSOR'
253                                        'RF05A-XPOS1(02)'.
254          PERFORM bdc_field       USING 'BDC_OKCODE'
255                                        '=ENTR'.
256          PERFORM bdc_field       USING 'RF05A-XPOS1(01)'
257                                        ''.
258          PERFORM bdc_field       USING 'RF05A-XPOS1(02)'
259                                        'X'.
260
261          l_count = 0.
262          PERFORM bdc_dynpro      USING 'SAPMF05A' '0731'.
263          PERFORM bdc_field       USING 'BDC_CURSOR'
264                                     'RF05A-SEL01(01)'.
265
266        ENDIF.
267
268        l_count = l_count + 1.
269        CONCATENATE 'RF05A-SEL01(0' l_count ')' INTO g_syvar.
270        PERFORM bdc_field       USING g_syvar ist_bsiks-belnr.
271
272
273      ENDLOOP.
274
275      PERFORM bdc_dynpro      USING 'SAPMF05A' '0731'.
276      PERFORM bdc_field       USING 'BDC_CURSOR'
277                                    'RF05A-SEL01(01)'.
278      PERFORM bdc_field       USING 'BDC_OKCODE'
279                                    '=PA'.
280
281      PERFORM bdc_dynpro      USING 'SAPDF05X' '3100'.
282      PERFORM bdc_field       USING 'BDC_OKCODE'
283                                    '=BS'.
284      PERFORM bdc_field       USING 'BDC_CURSOR'
285                                    'DF05B-PSSKT(01)'.
286      PERFORM bdc_field       USING 'RF05A-ABPOS'
287                                    '1'.
288      PERFORM bdc_dynpro      USING 'SAPMF05A' '0700'.
289      PERFORM bdc_field       USING 'BDC_CURSOR'
290                                    'RF05A-NEWBS'.
291      PERFORM bdc_field       USING 'BDC_OKCODE'
292                                    '=BU'.
293      PERFORM bdc_transaction USING 'F-53'.
294    endif.
295    ENDFORM.                                                    " bdc_f53
296    *&---------------------------------------------------------------------*
297    *&      Form  bdc_dynpro
298    *&---------------------------------------------------------------------*
299    *       text
300    *----------------------------------------------------------------------*
301    *      -->P_0403   text
302    *      -->P_0404   text
303    *----------------------------------------------------------------------*
304    FORM bdc_field USING fnam fval.
305
306      CLEAR bdcdata.
307      bdcdata-fnam = fnam.
308      bdcdata-fval = fval.
309      APPEND bdcdata.
310
311    ENDFORM.    "bdc_field
312
313    *&---------------------------------------------------------------------*
314    *&      Form  bdc_dynpro
315    *&---------------------------------------------------------------------*
316    *       text
317    *----------------------------------------------------------------------*
318    *      -->P_0480   text
319    *      -->P_0481   text
320    *----------------------------------------------------------------------*
321    FORM bdc_dynpro USING program dynpro.
322      CLEAR bdcdata.
323      bdcdata-program  = program.
324      bdcdata-dynpro   = dynpro.
325      bdcdata-dynbegin = 'X'.
326      APPEND bdcdata.
327    ENDFORM.                  " bdcdynpro
328    *&---------------------------------------------------------------------*
329    *&      Form  bdc_transaction
330    *&---------------------------------------------------------------------*
331    *       text
332    *----------------------------------------------------------------------*
333    *      -->P_0495   text
334    *----------------------------------------------------------------------*
335    FORM bdc_transaction USING tcode .
336      REFRESH ist_msgs.
337      CLEAR ist_msgs.
338      CALL TRANSACTION tcode USING bdcdata
339                       MODE  'N'  " later oit should be 'E' CTUMODE
340                       UPDATE 'S' " CUPDATE
341                       MESSAGES INTO  ist_msgs. "ist_msg_f53.
342
343    ENDFORM.                    " bdc_transaction
344    *&---------------------------------------------------------------------*
345    *&      Form  get_mesg_f53
346    *&---------------------------------------------------------------------*
347    *       text
348    *----------------------------------------------------------------------*
349    *  -->  p1        text
350    *  <--  p2        text
351    *----------------------------------------------------------------------*
352    FORM get_mesg_f53.
353      data l_msg type string.
354      CLEAR ist_msg_f53.
355      REFRESH ist_msg_f53 .
356      ist_msg_f53[] = ist_msgs[].
357      clear g_refdoc.
358      READ TABLE ist_msg_f53   WITH  KEY
359                                    msgtyp = 'S'
360                                    msgid = 'F5'
361                                    msgnr = '312'.
362      IF sy-subrc = 0.
363        CONCATENATE ist_msg_f53-msgv1 text-002 INTO  g_msgd.
364        g_refdoc =  ist_msg_f53-msgv1.
365        write :/ g_refdoc.
366        loop at ist_srcbsik where selcbox = 'X'.
367          wa_doc-bukrs = p_bukrs.
368          wA_doc-lifnr = g_lifnr.
369          wa_doc-budat = p_budat.
370          wa_doc-belnr = ist_srcbsik-belnr .
371          wa_doc-pdocnr = g_refdoc.
372          append wa_doc  to ist_doc.
373          clear wa_doc.
374        endloop.
375
376
377        modify zfi_cp_vend_docs  from  table ist_doc .
378
379      ELSE.
380        PERFORM put_payblock.
381        leave to list-processing .
382        format color col_heading.
383        write :/ text-004.
384        format color col_normal.
385        Loop at ist_srcbsik where selcbox = 'X'.
386          write :/ ist_srcbsik-belnr.
387        endloop.
388        format color col_heading.
389    * Begin of <RD1K985128>
390        loop at ist_msg_f53 where msgtyp = 'E'.
391          clear l_msg.
392          CALL FUNCTION 'FORMAT_MESSAGE'
393            EXPORTING
394              ID        = ist_msg_f53-MSGID
395              LANG      = 'EN'
396              NO        = ist_msg_f53-MSGNR
397              V1        = ist_msg_f53-MSGV1
398              V2        = ist_msg_f53-MSGV2
399              V3        = ist_msg_f53-MSGV3
400              V4        = ist_msg_f53-MSGV4
401            IMPORTING
402              MSG       = l_msg
403            EXCEPTIONS
404              NOT_FOUND = 1
405              OTHERS    = 2.
406          IF SY-SUBRC <> 0.
407    * MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
408    *         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
409          ENDIF.
410
411    *    write :/ text-005.
412          CONCATENATE ist_msg_f53-MSGID '(' ist_msg_f53-MSGNR ')-' l_msg INTO l_msg.
413          write :/ l_msg.
414    *          write :/ 'Please contact - ICE-FI, Coreteam'.
415        endloop.
416        if not ist_bsiks_omit[] is INITIAL.
417          loop at ist_bsiks_omit into wa_bsik.
418            clear l_msg.
419            CONCATENATE wa_bsik-BELNR 'PayOrder already created Pls Check ZFIAPP_PAYREP' into l_msg.
420            write :/ l_msg.
421          ENDLOOP.
422    *    write :/ 'Please contact - ICE-FI, Coreteam'.
423        endif.
424        if not ist_bsiks_vblk[] is INITIAL.
425          loop at ist_bsiks_vblk into wa_bsik.
426            clear l_msg.
427            CONCATENATE wa_bsik-lifnr 'Vendor is blocked' into l_msg SEPARATED BY SPACE.
428            write :/ l_msg.
429          ENDLOOP.
430    *          write :/ 'Please contact - ICE-FI, Coreteam'.
431        endif.
432        write :/ 'Please contact - ICE-FI, Coreteam'.
433    * End of <RD1K985128>
434      ENDIF.
435
436
437    ENDFORM.                    " get_mesg_f53
438    *&---------------------------------------------------------------------*
439    *&      Form  put_payblock
440    *&---------------------------------------------------------------------*
441    *       text
442    *----------------------------------------------------------------------*
443    *  -->  p1        text
444    *  <--  p2        text
445    *----------------------------------------------------------------------*
446    FORM put_payblock.
447
448      DATA : l_tabix LIKE sy-tabix .
449
450      IF NOT ist_bsiks[] IS  INITIAL.
451        CLEAR ist_bsik.
452        CLEAR wa_bsik_t.
453
454        SELECT * INTO TABLE ist_bsik   FROM bsik
455          FOR ALL ENTRIES  IN  ist_bsiks
456          WHERE   lifnr = ist_bsiks-lifnr
457                AND  bukrs  =  p_bukrs
458                 AND gjahr = ist_bsiks-gjahr
459                 AND belnr = ist_bsiks-belnr
460                 AND buzei = ist_bsiks-buzei.
461
462        IF NOT ist_bsik IS INITIAL.
463
464          CLEAR l_tabix.
465          LOOP AT ist_bsik INTO wa_bsik_t.
466            l_tabix = sy-tabix.
467            IF wa_bsik_t-zlspr = g_zlspr_s.
468              wa_bsik_t-zlspr =  g_zlspr_x.
469              MODIFY ist_bsik  FROM  wa_bsik_t INDEX l_tabix  TRANSPORTING zlspr.
470            ENDIF.
471          ENDLOOP.
472
473
474    *      MODIFY  bsik FROM TABLE ist_bsik.
475        ENDIF.
476
477        CLEAR ist_bseg.
478        CLEAR wa_bseg.
479
480        SELECT * INTO TABLE ist_bseg   FROM bseg
481            FOR ALL ENTRIES  IN  ist_bsiks
482            WHERE   lifnr = ist_bsiks-lifnr
483                  AND  bukrs  =  p_bukrs
484                   AND gjahr = ist_bsiks-gjahr
485                   AND belnr = ist_bsiks-belnr
486                   AND buzei = ist_bsiks-buzei ORDER BY PRIMARY KEY.
487
488        IF NOT ist_bseg IS INITIAL.
489
490          CLEAR l_tabix.
491          LOOP AT ist_bseg INTO wa_bseg.
492            l_tabix = sy-tabix.
493            IF wa_bseg-zlspr = g_zlspr_s.
494              wa_bseg-zlspr =  g_zlspr_x.
495              MODIFY ist_bseg  FROM  wa_bseg INDEX l_tabix  TRANSPORTING zlspr.
496            ENDIF.
497          ENDLOOP.
498
499
500    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
501    * S/4: BSEG payment block (ZLSPR) via FI_DOCUMENT_CHANGE (FB02); direct write not allowed.
502    *      MODIFY  bseg FROM TABLE ist_bseg.
503          LOOP AT ist_bseg INTO wa_bseg.
504            PERFORM zz_s4_bseg_zlspr USING wa_bseg-bukrs wa_bseg-belnr wa_bseg-gjahr wa_bseg-buzei wa_bseg-zlspr.
505          ENDLOOP.
506          COMMIT WORK.
507    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
508
509        ENDIF.
510
511      ENDIF.
512
513    ENDFORM.                    " put_payblock
514    *&---------------------------------------------------------------------*
515    *&      Form  gen_chec_number
516    *&---------------------------------------------------------------------*
517    *       text
518    *----------------------------------------------------------------------*
519    *  -->  p1        text
520    *  <--  p2        text
521    *----------------------------------------------------------------------*
522    FORM gen_chec_number.
523
524    *---find prsent checueq no by cheq  lot no.
525      PERFORM   find_chec_no.
526
527      PERFORM   bdc_fch5.
528    ENDFORM.                    " gen_chec_number
529    *&---------------------------------------------------------------------*
530    *&      Form  find_chec_no
531    *&---------------------------------------------------------------------*
532    *       text
533    *----------------------------------------------------------------------*
534    *  -->  p1        text
535    *  <--  p2        text
536    *----------------------------------------------------------------------*
537    FORM find_chec_no.
538    * Begin of RD1K971753 CAB_ALOK CR30004067.
539      data len type i.
540      data len_g_checl type i.
541      data len_diff type i.
542    * End of RD1K971753 CAB_ALOK CR30004067.
543      clear g_checl.
544      SELECT SINGLE  * FROM pcec WHERE zbukr = p_bukrs
545                                 AND hbkid = p_hbkid
546                              AND hktid = p_hktid
547                              AND stapl = p_stapl.
548      IF sy-subrc = 0.
549    * Begin of RD1K971753 CAB_ALOK CR30004067.
550    *    g_checl =  pcec-checl.
551    *    g_checl = g_checl + 1.
552    *    condense g_checl.
553
554    *  Requirement
555    *  if checl is SPACE then take g_checl = PCEC-CHECF
556    *      else take g_checl = pcec-checl + 1.
557    *   and preserve leading zeros of g_checl.
558        if pcec-checl = SPACE.
559          len = strlen( PCEC-CHECF ).  "required length of g_checl
560          g_checl = PCEC-CHECF.
561          condense g_checl.
562          len_g_checl = strlen(  g_checl ). " current length of g_checl without spaces
563    *      Concat ZEROs
564          if len <> len_g_checl .
565            len_diff = len - len_g_checl.  "number of ZEROs to be added
566            do len_diff times.
567              CONCATENATE  '0' g_checl INTO g_checl .
568            enddo.
569          endif.
570        else .
571          len = strlen( PCEC-CHECL ).
572          g_checl = pcec-checl + 1.
573          condense g_checl.
574          len_g_checl = strlen(  g_checl ).
575    *      Concat ZEROs
576          if len <> len_g_checl .
577            len_diff = len - len_g_checl.
578            do len_diff times.
579              CONCATENATE  '0' g_checl INTO g_checl .
580            enddo.
581
582          endif.
583
584        endif.
585
586    * End of RD1K971753 CAB_ALOK CR30004067.
587      ENDIF.
588    ENDFORM.                    " find_chec_no
589    *&---------------------------------------------------------------------*
590    *&      Form  bdc_fch5
591    *&---------------------------------------------------------------------*
592    *       text
593    *----------------------------------------------------------------------*
594    *  -->  p1        text
595    *  <--  p2        text
596    *----------------------------------------------------------------------*
597    FORM bdc_fch5.
598      IF NOT g_checl IS INITIAL.
599
600        CALL FUNCTION 'DATE_TO_PERIOD_CONVERT'
601          EXPORTING
602            i_date   = p_budat
603    *       I_MONMIT = 00
604            i_periv  = 'V3'
605          IMPORTING
606    *       E_BUPER  =
607            e_gjahr  = g_gjahr.
608    * EXCEPTIONS
609    *   INPUT_FALSE          = 1
610    *   T009_NOTFOUND        = 2
611    *   T009B_NOTFOUND       = 3
612    *   OTHERS               = 4
613        .
614        IF sy-subrc <> 0.
615    * MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
616    *         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
617        ENDIF.
618
619
620
621        CLEAR bdcdata .
622        REFRESH bdcdata .
623
624
625        PERFORM bdc_dynpro      USING 'SAPMFCHK' '0500'.
626        PERFORM bdc_field       USING 'BDC_CURSOR'
627                                      'PAYR-CHECT'.
628        PERFORM bdc_field       USING 'BDC_OKCODE'
629                                      '=UPDA'.
630        PERFORM bdc_field       USING 'PAYR-VBLNR'
631                                      g_refdoc. "'1705000172'.
632        PERFORM bdc_field       USING 'PAYR-ZBUKR'
633                                      p_bukrs . "'mum'.
634        PERFORM bdc_field       USING 'PAYR-GJAHR'
635                                      g_gjahr .                 "'2007'.
636        PERFORM bdc_field       USING 'PAYR-HBKID'
637                                      p_hbkid .                 "'hb_01'.
638        PERFORM bdc_field       USING 'PAYR-HKTID'
639                                      p_hktid .                 "'hb001'.
640        PERFORM bdc_field       USING 'PAYR-CHECT'       "################
641                                      g_checl.                  "'10180'.
642        PERFORM bdc_transaction USING 'FCH5'.
643
644
645      ENDIF.
646
647
648      ist_msg_fch[] = ist_msgs[].
649      READ TABLE ist_msg_fch  WITH KEY msgtyp = 'S'
650                                       msgid  ='FS'
651                                       msgnr = '568'.
652      IF sy-subrc = 0.
653        g_cheq = ist_msg_fch-msgv4.
654        clear ist_doc .
655        refresh ist_doc.
656        if not ist_bsiks[]  is initial.
657          select *  into  table ist_doc from  zfi_cp_vend_docs
658                 for all entries in ist_bsiks
659                            where  bukrs = p_bukrs
660                            and  lifnr = g_lifnr
661                            and  belnr =  ist_bsiks-belnr.  "#EC CI_NOORDER
662          loop at ist_doc .
663            ist_doc-checl =  g_cheq.
664            modify ist_doc index sy-tabix  transporting checl.
665          endloop.
666
667          modify zfi_cp_vend_docs  from  ist_doc.
668        endif.
669      endif.
670    ENDFORM.                                                    " bdc_fch5
671    *&---------------------------------------------------------------------*
672    *&      Form  get_vendors
673    *&---------------------------------------------------------------------*
674    *       text
675    *----------------------------------------------------------------------*
676    *  -->  p1        text
677    *  <--  p2        text
678    *----------------------------------------------------------------------*
679    FORM get_vendors.
680      data :l_tabix like sy-tabix.
681      SELECT lifnr  INTO  TABLE  ist_lifnr FROM   lfb1 WHERE   bukrs = p_bukrs
682                                                        AND  lifnr IN s_lifnr.  "#EC CI_NOORDER
683      IF NOT ist_lifnr[] IS INITIAL.
684
685        SELECT *
686         APPENDING CORRESPONDING FIELDS OF  TABLE ist_lifnr1
687         FROM lfa1
688            FOR ALL ENTRIES IN ist_lifnr
689            WHERE  lifnr  =  ist_lifnr-lifnr .
690      ENDIF.
691
692      SORT ist_lifnr1 BY lifnr.
693      DELETE ADJACENT DUPLICATES FROM ist_lifnr1.
694
695      clear l_tabix.
696      loop at ist_lifnr1 .
697        l_tabix = sy-tabix.
698        select single * from bsik where bukrs = p_bukrs
699                                  and lifnr = ist_lifnr1-lifnr.
700        if sy-subrc = 0.
701          continue.
702        else.
703          delete  ist_lifnr1  index l_tabix.
704        endif.
705      endloop.
706
707
708      DESCRIBE TABLE ist_lifnr1  LINES g_tclin.
709
710
711    ENDFORM.                    " get_vendors
712    *&---------------------------------------------------------------------*
713    *&      Form  PRE_POST_CHECKS
714    *&---------------------------------------------------------------------*
715    *       text
716    *----------------------------------------------------------------------*
717    *  -->  p1        text
718    *  <--  p2        text
719    *----------------------------------------------------------------------*
720    FORM PRE_POST_CHECKS .
721      data : lv_ans type c.
722      LOOP AT ist_srcbsik  WHERE  selcbox = 'X'.
723    *   N or S or L
724        if ist_srcbsik-zwels = 'N' or ist_srcbsik-zwels = 'S' or ist_srcbsik-zwels = 'L'.
725    *    MESSAGE e100(zfi) with text-016.
726          CALL FUNCTION 'POPUP_TO_CONFIRM'
727            EXPORTING
728             TITLEBAR                    = 'Confirmation'
729    *         DIAGNOSE_OBJECT             = ' '
730              TEXT_QUESTION               = text-017
731             TEXT_BUTTON_1               = 'YES'(018)
732             ICON_BUTTON_1               = ' '
733             TEXT_BUTTON_2               = 'NO'(019)
734             ICON_BUTTON_2               = ' '
735             DEFAULT_BUTTON              = '1'
736             DISPLAY_CANCEL_BUTTON       = ''
737    *         USERDEFINED_F1_HELP         = ' '
738    *         START_COLUMN                = 25
739    *         START_ROW                   = 6
740    *         POPUP_TYPE                  =
741    *         IV_QUICKINFO_BUTTON_1       = ' '
742    *         IV_QUICKINFO_BUTTON_2       = ' '
743           IMPORTING
744             ANSWER                      = lv_ans
745    *       TABLES
746    *         PARAMETER                   =
747    *       EXCEPTIONS
748    *         TEXT_NOT_FOUND              = 1
749    *         OTHERS                      = 2
750                    .
751          IF SY-SUBRC <> 0.
752    * Implement suitable error handling here
753
754          ENDIF.
755          if lv_ans = '1'.
756
757          else.
758            l_flag = 'N'.
759            exit.
760          endif.
761        endif.
762    *set to omit vendors LAQ RENT, LAQ DAMAGE, CSR VENDOR & OTHERS
763        clear l_err.
764
765        SELECT * FROM setleaf
766    INTO CORRESPONDING FIELDS OF TABLE ist_setleaf
767    WHERE setclass = g_setclass
768      AND setname = g_setname.
769        READ TABLE ist_setleaf WITH KEY setclass = g_setclass
770                                        setname  = g_setname
771                                        valfrom  = ist_srcbsik-lifnr.
772        CHECK sy-subrc EQ 0.
773        clear l_c.
774        loop at ist_srcbsik into wa_bsik where selcbox = 'X'.
775    *      and belnr = ist_srcbsik-belnr.
776          l_c = l_c + 1.
777        endloop.
778        if l_c > 1.
779          loop at ist_srcbsik into WA_BSIK where selcbox = 'X'.
780            WA_BSIK-selcbox = ''.
781            modify ist_srcbsik from WA_BSIK TRANSPORTING selcbox.
782          endloop.
783          REFRESH CONTROL 'TC_OP_IT' FROM SCREEN '0200'.
784          l_err = 'X'.
785          MESSAGE e100(zfi) with text-020.
786        endif.
787      ENDLOOP.
788    ENDFORM.                    " PRE_POST_CHECKS
789    *&---------------------------------------------------------------------*
790    *&      Form  FILTER_DATA
791    *&---------------------------------------------------------------------*
792    *       text
793    *----------------------------------------------------------------------*
794    *  -->  p1        text
795    *  <--  p2        text
796    *----------------------------------------------------------------------*
797    FORM FILTER_DATA .
798      clear : sval_tab.
799      refresh : sval_tab.
800
801      sval_tab-tabname    = 'BSIK'.
802      sval_tab-fieldname  = 'LIFNR'.
803      sval_tab-fieldtext  = 'VENDOR'(008).
804      append sval_tab.
805
806      call function 'POPUP_GET_VALUES_USER_HELP'
807                exporting
808    *           F1_FORMNAME               = ' '
809    *           F1_PROGRAMNAME            = ' '
810    *           F4_FORMNAME               = ' '
811    *           F4_PROGRAMNAME            = ' '
812    *           FORMNAME                  = ' '
813                     popup_title               = 'Filter Criteria'(014)
814    *           PROGRAMNAME               = ' '
815    *           START_COLUMN              = '5'
816    *           START_ROW                 = '5'
817    *           NO_CHECK_FOR_FIXED_VALUES = ' '
818    *      IMPORTING
819    *           RETURNCODE                =
820                tables
821                     fields                    = sval_tab
822    *      EXCEPTIONS
823    *           ERROR_IN_FIELDS           = 1
824    *           OTHERS                    = 2
825                     .
826
827      if rcode eq 'A'.                     "user cancels from pop up box
828        exit.
829      endif.
830
831      loop at ist_lifnr1 into wa_lfa1 where mark = 'X'.
832        wa_lfa1-mark = ''.
833        modify ist_lifnr1 from wa_lfa1 TRANSPORTING mark.
834      endloop.
835
836      loop at sval_tab.
837    *    read table trtc_tab with key tr_no = sval_tab-value.
838        read TABLE sval_tab WITH KEY fieldname = 'LIFNR'.
839        if sy-subrc = 0.
840          if not sval_tab-value is initial.
841            read table ist_lifnr1 with key lifnr = sval_tab-value.
842          endif.
843    *      tc_vend-top_line = sy-tabix.
844          loop at ist_lifnr1 into wa_lfa1 where lifnr = sval_tab-value.
845            wa_lfa1-mark = 'X'.
846            modify ist_lifnr1 from wa_lfa1 TRANSPORTING mark.
847          endloop.
848          tc_vend-top_line = sy-tabix.
849          exit.
850        endif.
851      Endloop.
852
853    ENDFORM.                    " FILTER_DATA
854
855    *-- S/4 helper: change BSEG payment block via FI_DOCUMENT_CHANGE - SAP_ABAP 16.06.2026 --
856    FORM zz_s4_bseg_zlspr USING p_bukrs p_belnr p_gjahr p_buzei p_zlspr.
857      DATA: lt_acchg TYPE STANDARD TABLE OF accchg, ls_acchg TYPE accchg.
858      REFRESH lt_acchg. CLEAR ls_acchg.
859      ls_acchg-fdname = 'ZLSPR'. ls_acchg-newval = p_zlspr.
860      APPEND ls_acchg TO lt_acchg.
861      CALL FUNCTION 'FI_DOCUMENT_CHANGE' EXPORTING i_bukrs = p_bukrs i_belnr = p_belnr i_gjahr = p_gjahr
862           i_buzei = p_buzei TABLES t_acchg = lt_acchg EXCEPTIONS OTHERS = 0.
863    ENDFORM.
*--- End of ZFI_CP_MAS_VEN_E0001 - 863 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CABAP                                   Level 1    Page 6
Object           ZFI_CP_MASS_VEN_PAY                       Lines 360
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:03
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
Generated incl.  %_CCXTAB                                  Level 1    Page 7
Object           ZFI_CP_MASS_VEN_PAY                       Lines 6
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:03
----------------------------------------------------------------------------------------------------
1      TYPE-POOL CXTAB .
2
3      TYPES:
4             CXTAB_COLUMN type scxtab_column,
5             CXTAB_CONTROL type scxtab_control,
6             CXTAB_TABSTRIP type scxtab_tabstrip.
*--- End of %_CCXTAB - 6 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  <CONTRO>                                  Level 1    Page 8
Object           ZFI_CP_MASS_VEN_PAY                       Lines 76
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:03
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
Generated incl.  <REPINI>                                  Level 1    Page 9
Object           ZFI_CP_MASS_VEN_PAY                       Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:03
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
Generated incl.  <SYSINI>                                  Level 1    Page 10
Object           ZFI_CP_MASS_VEN_PAY                       Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:03
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
Generated incl.  <SYSSEL>                                  Level 1    Page 11
Object           ZFI_CP_MASS_VEN_PAY                       Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:03
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
Generated incl.  DB__SSEL                                  Level 1    Page 12
Object           ZFI_CP_MASS_VEN_PAY                       Lines 1
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:03
----------------------------------------------------------------------------------------------------
1      * INCLUDE DB__SSEL
*--- End of DB__SSEL - 1 lines ---
