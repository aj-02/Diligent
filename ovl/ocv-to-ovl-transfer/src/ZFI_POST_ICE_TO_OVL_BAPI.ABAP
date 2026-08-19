----------------------------------------------------------------------------------------------------
Main program     ZFI_POST_ICE_TO_OVL_BAPI                  Level 0    Page 1
Object           ZFI_POST_ICE_TO_OVL_BAPI                  Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:22
----------------------------------------------------------------------------------------------------
1
2      *&---------------------------------------------------------------------*
3      *& Program ID    : ZFI_POST_ICE_TO_OVL
4      *& Program Text  : Replication of FI posting document from ICE server to OVL server
5      *& Overview      : The Documents that are posted in FI at ICE server would be
6      *                  required to be duplicated at OVL server.
7      *                  Program to download the data at ICE would be required to be developed
8      **                 for any FI document posted in OVL.
9      *& Created by    : Rekha Gupta (ABAPUSER01)
10     *& Creation Date : 22.06.2016 12:00:31
11     *&---------------------------------------------------------------------*
12     *& Changing No   :
13     *& Updated by    :
14     *& Update date   :
15     *& Changed Item Description :
16     *&---------------------------------------------------------------------*
17
18     INCLUDE ZFI_POST_ICE_TO_OVL_BAPI_TOP.
19     *INCLUDE zfi_post_ice_to_ovl_top.    " global Data
20     INCLUDE ZFI_POST_ICE_TO_OVL_BAPI_E01.
21     *INCLUDE zfi_post_ice_to_ovl_e01.    " events
22     INCLUDE ZFI_POST_ICE_TO_OVL_BAPI_F01.
23     *INCLUDE zfi_post_ice_to_ovl_f01.  " FORM-Routines
*--- End of ZFI_POST_ICE_TO_OVL_BAPI - 23 lines ---

----------------------------------------------------------------------------------------------------
Include          ZFI_POST_ICE_TO_OVL_BAPI_TOP              Level 1    Page 2
Object           ZFI_POST_ICE_TO_OVL_BAPI                  Lines 73
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:22
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *& Include ZFI_POST_ICE_TO_OVL_TOP
3      *&
4      *&---------------------------------------------------------------------*
5      REPORT zfi_post_ice_to_ovl_bapi.
6
7      TYPE-POOLS: slis,
8                  icon.
9
10     TABLES : rlgrap,
11              rldrp,
12              sscrfields,
13              bkpf,
14              bseg.
15     *-----------------------------------------------------------------------
16     * T Y P E S
17     *-----------------------------------------------------------------------
18     TYPES : tt_curr TYPE TABLE OF bapiaccr09.
19     TYPES : tt_gl   TYPE TABLE OF bapiacgl09. "Added by Manisha bh.Dt:17.05.2017
20
21     *-----------------------------------------------------------------------
22     * D A T A
23     *-----------------------------------------------------------------------
24
25     DATA : gt_bkpf TYPE STANDARD TABLE OF bkpf,
26            gt_bseg TYPE STANDARD TABLE OF bseg.
27
28     DATA : git_alv TYPE TABLE OF zfi_s_alv,
29            gt_fld  TYPE TABLE OF slis_fieldcat_alv.
30
31     DATA   :   gv_functxt TYPE smp_dyntxt,
32                gv_no      TYPE i.
33     *-----------------------------------------------------------------------
34     * C O N S T A N T S
35     *-----------------------------------------------------------------------
36
37     CONSTANTS : gc_e TYPE c LENGTH 1 VALUE 'E',
38                 gc_i TYPE c LENGTH 1 VALUE 'I',
39                 gc_s TYPE c LENGTH 1 VALUE 'S',
40                 gc_x TYPE c LENGTH 1 VALUE 'X'.
41     *-----------------------------------------------------------------------
42     * F I E L D – S Y M B O L S
43     *-----------------------------------------------------------------------
44
45     *-----------------------------------------------------------------------
46     * F I E L D – G R O U P S
47     *-----------------------------------------------------------------------
48
49
50     *-----------------------------------------------------------------------
51     * P A R A M E T E R S   &   S E L E C T - O P T I O N S
52     *-----------------------------------------------------------------------
53
54     SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-000.
55
56     SELECT-OPTIONS : so_bukrs FOR bkpf-bukrs OBLIGATORY DEFAULT 'OVL', " Company Code
57                      so_belnr FOR bkpf-belnr OBLIGATORY , " FI Document No   " Change by rohit 08.04.2024
58                      so_gjahr FOR bkpf-gjahr OBLIGATORY, " Fiscal Year
59                      so_blart FOR bkpf-blart, " Document Type
60                      so_budat FOR bkpf-budat, " Posting Date
61                      so_pernr FOR bseg-pernr NO-EXTENSION NO INTERVALS,
62                      so_prctr FOR bseg-prctr NO-EXTENSION NO INTERVALS,
63
64                      so_kostl FOR bseg-kostl NO INTERVALS NO-EXTENSION, "added on 23.03.23 br hrishi n
65                      so_zuonr FOR bseg-zuonr NO INTERVALS NO-EXTENSION. " added on 09.04.24 by rohit.
66
67     PARAMETER :  p_bkpf LIKE rlgrap-filename NO-DISPLAY , " Accounting Header
68                  p_bseg LIKE rlgrap-filename NO-DISPLAY. " Accounting Line
69     SELECTION-SCREEN END OF BLOCK b1.
70
71     SELECTION-SCREEN FUNCTION KEY 1.
72
73     **************
*--- End of ZFI_POST_ICE_TO_OVL_BAPI_TOP - 73 lines ---

----------------------------------------------------------------------------------------------------
Include          ZFI_POST_ICE_TO_OVL_BAPI_E01              Level 1    Page 3
Object           ZFI_POST_ICE_TO_OVL_BAPI                  Lines 52
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:22
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&  Include           ZFI_POST_ICE_TO_OVL_E01
3      *&---------------------------------------------------------------------*
4
5      *-----------------------------------------------------------------------
6      * I N I T I A L I Z A T I O N
7      *-----------------------------------------------------------------------
8      INITIALIZATION.
9
10     *  gv_functxt-icon_id = icon_export.
11     *  gv_functxt-icon_text = 'Download'(040).
12     *  gv_functxt-quickinfo = 'Download File'(041).
13     *  sscrfields-functxt_01 = gv_functxt.
14
15
16
17     *-----------------------------------------------------------------------
18     * A T   S E L E C T I O N - S C R E E N  O N  V A L U E  R E Q U E S T for P_BKPF
19     *-----------------------------------------------------------------------
20     *AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_bkpf.
21     *  PERFORM fm_upload_bkpf USING p_bkpf.
22     *
23     *
24     **-----------------------------------------------------------------------
25     ** A T   S E L E C T I O N - S C R E E N  O N  V A L U E  R E Q U E S T for P_BSEG
26     **-----------------------------------------------------------------------
27     *AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_bseg.
28     *  PERFORM fm_upload_bkpf USING p_bseg.
29
30
31     *-----------------------------------------------------------------------
32     * A T   S E L E C T I O N - S C R E E N
33     *-----------------------------------------------------------------------
34     AT SELECTION-SCREEN .
35       IF sscrfields-ucomm = 'FC01'.
36         PERFORM fm_clear.
37         PERFORM fm_get_data.
38       ENDIF.
39
40     *-----------------------------------------------------------------------
41     * S T A R T - O F - S E L E C T I O N
42     *-----------------------------------------------------------------------
43
44     START-OF-SELECTION.
45
46       PERFORM fm_clear.
47       PERFORM fm_upload_data.
48       PERFORM fm_get_data_ice .
49       PERFORM fm_post_document.
50       PERFORM sub_fill_alv.
51
52     ************
*--- End of ZFI_POST_ICE_TO_OVL_BAPI_E01 - 52 lines ---

----------------------------------------------------------------------------------------------------
Include          ZFI_POST_ICE_TO_OVL_BAPI_F01              Level 1    Page 4
Object           ZFI_POST_ICE_TO_OVL_BAPI                  Lines 2006
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:22
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&  Include           ZFI_POST_ICE_TO_OVL_F01
3      *&---------------------------------------------------------------------*
4      *&---------------------------------------------------------------------*
5      *&      Form  FM_GET_DATA_ICE
6      *&---------------------------------------------------------------------*
7      *       text
8      *----------------------------------------------------------------------*
9      *  -->  p1        text
10     *  <--  p2        text
11     *----------------------------------------------------------------------*
12     FORM fm_get_data_ice .
13
14     *** Step == > Data Declaration.
15       DATA  : lt_doc TYPE TABLE OF zfihrdoctypes.
16
17       DATA : ls_doc  TYPE zfihrdoctypes,
18              ls_bkpf TYPE bkpf,
19              ls_bseg TYPE bseg.
20
21       DATA : lt_bkpf  TYPE TABLE OF zfibkpf,
22              ls_alv   TYPE zfi_s_alv,
23              lv_index TYPE sy-tabix,
24              ls_bkpf1 TYPE zfibkpf.
25
26       IF  gv_no IS INITIAL .
27         gv_no = 1.
28       ENDIF.
29
30     *** Step == > Select Data from ZFIHRDOCTYPES to fetch relative document type
31       SELECT * FROM zfihrdoctypes INTO TABLE lt_doc.
32       IF  sy-subrc IS  INITIAL .
33         SORT lt_doc BY blart.
34       ELSE.
35     *    MESSAGE e002(zfiovl) WITH zfihrdoctypes .
36       ENDIF.
37
38
39       LOOP AT  gt_bkpf INTO ls_bkpf..
40         lv_index = sy-tabix.
41     *    IF  ls_bkpf-budat LE '20160718'.
42         IF  ls_bkpf-budat LT '20160718'.
43           DELETE gt_bkpf INDEX lv_index .
44           DELETE gt_bseg WHERE bukrs = ls_bkpf-bukrs
45                          AND   belnr = ls_bkpf-belnr
46                          AND   gjahr = ls_bkpf-gjahr.
47           ls_alv-index = gv_no.
48           ls_alv-icon = '@0A@'.
49           ls_alv-bukrs = ls_bkpf-bukrs.
50           ls_alv-belnr = ls_bkpf-belnr.
51           ls_alv-gjahr = ls_bkpf-gjahr.
52           ls_alv-blart = ls_bkpf-blart.
53           ls_alv-message = 'Document before 18 July 2016 is not allowed'.
54           ls_alv-number = '000'.
55           ls_alv-id = 'ZFI'.
56           ls_alv-type = 'E'.
57
58           ADD 1 TO gv_no.
59           APPEND ls_alv TO git_alv.
60           CLEAR : ls_alv.
61           CONTINUE.
62         ENDIF.
63
64         READ TABLE lt_doc INTO ls_doc WITH KEY blart = ls_bkpf-blart.
65         IF  sy-subrc <> 0 .
66           DELETE gt_bkpf INDEX lv_index .
67           DELETE gt_bseg WHERE bukrs = ls_bkpf-bukrs
68                          AND   belnr = ls_bkpf-belnr
69                          AND   gjahr = ls_bkpf-gjahr.
70           ls_alv-index = gv_no.
71           ls_alv-icon = '@0A@'.
72           ls_alv-bukrs = ls_bkpf-bukrs.
73           ls_alv-belnr = ls_bkpf-belnr.
74           ls_alv-gjahr = ls_bkpf-gjahr.
75           ls_alv-blart = ls_bkpf-blart.
76
77           CONCATENATE 'Document Type' ls_bkpf-blart 'is not maintained in ZFIHRDOCTYPES'
78           INTO ls_alv-message.
79           ls_alv-number = '000'.
80           ls_alv-id = 'ZFI'.
81           ls_alv-type = 'E'.
82
83           ADD 1 TO gv_no.
84           APPEND ls_alv TO git_alv.
85           CLEAR : ls_alv.
86
87         ENDIF.
88
89
90
91       ENDLOOP.
92
93
94       IF gt_bkpf IS NOT INITIAL .
95         SELECT * FROM zfibkpf
96           INTO TABLE lt_bkpf
97           FOR ALL ENTRIES IN gt_bkpf
98           WHERE bukrs = gt_bkpf-bukrs
99           AND   belnr = gt_bkpf-belnr
100          AND   gjahr = gt_bkpf-gjahr.
101      ENDIF.
102
103
104
105      LOOP AT  lt_bkpf INTO ls_bkpf1 WHERE type NE 'E' .
106
107        READ TABLE gt_bkpf INTO ls_bkpf WITH KEY bukrs = ls_bkpf1-bukrs
108                                                 belnr = ls_bkpf1-belnr
109                                                 gjahr = ls_bkpf1-gjahr.
110
111        IF  sy-subrc = 0 .
112          DELETE gt_bkpf  INDEX sy-tabix.
113          DELETE gt_bseg WHERE bukrs = ls_bkpf-bukrs
114                         AND   belnr = ls_bkpf-belnr
115                         AND   gjahr = ls_bkpf-gjahr.
116
117          ls_alv-index = gv_no.
118          ls_alv-icon = '@0A@'.
119          ls_alv-bukrs = ls_bkpf1-bukrs.
120          ls_alv-belnr = ls_bkpf1-belnr.
121          ls_alv-gjahr = ls_bkpf1-gjahr.
122          ls_alv-blart = ls_bkpf1-blart.
123          ls_alv-bukrs_new = ls_bkpf1-zbukrs.
124          ls_alv-belnr_new = ls_bkpf1-zbelnr.
125          ls_alv-gjahr_new = ls_bkpf1-zgjahr.
126          ls_alv-message = 'Document is already posted'(002).
127          ls_alv-number = '000'.
128          ls_alv-id = 'ZFI'.
129          ls_alv-type = 'E'.
130
131          ADD 1 TO gv_no.
132
133          APPEND ls_alv TO git_alv.
134          CLEAR : ls_alv.
135        ENDIF.
136
137
138      ENDLOOP.
139
140
141    ENDFORM.
142    *&---------------------------------------------------------------------*
143    *&      Form  FM_UPLOAD_BKPF
144    *&---------------------------------------------------------------------*
145    *       text
146    *----------------------------------------------------------------------*
147    *  -->  p1        text
148    *  <--  p2        text
149    *----------------------------------------------------------------------*
150    FORM fm_upload_bkpf USING uv_file TYPE rlgrap-filename.
151
152      CALL FUNCTION 'F4_FILENAME'
153        EXPORTING
154          program_name  = syst-cprog
155          dynpro_number = syst-dynnr
156          field_name    = ' '
157        IMPORTING
158          file_name     = uv_file.
159    ENDFORM.
160    *&---------------------------------------------------------------------*
161    *&      Form  FM_UPLOAD_DATA
162    *&---------------------------------------------------------------------*
163    *     Upload data from excel
164    *----------------------------------------------------------------------*
165
166    *----------------------------------------------------------------------*
167    FORM fm_upload_data .
168
169    ** Step == > Data Declaration
170
171      SELECT * FROM zfibkpf INTO TABLE @DATA(i_t_bkpf)
172      WHERE bukrs IN  @so_bukrs
173      AND   belnr IN  @so_belnr
174      AND   gjahr IN  @so_gjahr
175      AND   blart IN  @so_blart
176      AND   budat IN  @so_budat.
177
178
179      SELECT * FROM zfi_bseg INTO TABLE @DATA(i_t_bseg)
180       FOR ALL ENTRIES IN @i_t_bkpf
181       WHERE bukrs EQ  @i_t_bkpf-bukrs
182       AND   belnr EQ  @i_t_bkpf-belnr
183       AND   gjahr EQ  @i_t_bkpf-gjahr.
184
185      DATA: ls_zbkpf TYPE zfibkpf,
186            ls_zbseg TYPE zfi_bseg,
187            ls_bkpf  TYPE bkpf,
188            ls_bseg  TYPE  bseg.
189      LOOP AT i_t_bkpf INTO ls_zbkpf.
190        MOVE-CORRESPONDING ls_zbkpf TO ls_bkpf.
191        APPEND ls_bkpf TO gt_bkpf.
192      ENDLOOP.
193
194
195      LOOP AT i_t_bseg INTO ls_zbseg.
196        MOVE-CORRESPONDING ls_zbseg TO ls_bseg.
197        APPEND ls_bseg TO gt_bseg.
198      ENDLOOP.
199
200
201
202
203
204
205
206    ENDFORM.
207    *&---------------------------------------------------------------------*
208    *&      Form  FM_POST_DOCUMENT
209    *&---------------------------------------------------------------------*
210    *       text
211    *----------------------------------------------------------------------*
212    *  -->  p1        text
213    *  <--  p2        text
214    *----------------------------------------------------------------------*
215    FORM fm_post_document .
216
217
218      IF  gv_no IS INITIAL .
219        gv_no = 1.
220      ENDIF.
221    ****  Data declaration .
222      DATA:
223        lv_index TYPE sy-tabix.
224    *    gv_no    TYPE I VALUE 1.
225
226
227
228      DATA  : ls_head       TYPE          bapiache09,
229              ls_gl         TYPE          bapiacgl09,
230              ls_ven        TYPE          bapiacap09,
231              ls_ctmr       TYPE          bapiacar09,
232              ls_asset      TYPE          bapiacgl09,  "Added by Manisha bh.Dt:12.05.2017
233              ls_curr       TYPE          bapiaccr09,
234              ls_return     TYPE          bapiret2,
235              ls_tax        TYPE          bapiactx09,
236              ls_bapiacwt09 TYPE          bapiacwt09,
237              ls_alv        TYPE          zfi_s_alv,
238              lt_gl         TYPE TABLE OF bapiacgl09,
239              lt_ven        TYPE TABLE OF bapiacap09,
240              lt_curr       TYPE TABLE OF bapiaccr09,
241              lt_ctmr       TYPE TABLE OF bapiacar09,
242              lt_asset      TYPE TABLE OF bapiacgl09,  "Added by Manisha bh.Dt:12.05.2017
243              lt_tax        TYPE TABLE OF bapiactx09,
244              lt_bapiacwt09 TYPE TABLE OF bapiacwt09,
245              lt_return     TYPE TABLE OF bapiret2.
246
247
248      DATA : obj_type TYPE bapiache09-obj_type,
249             obj_key  TYPE bapiache09-obj_key,
250             obj_sys  TYPE bapiache09-obj_sys.
251
252
253      DATA : ls_bkpf     TYPE bkpf,
254             ls_bseg     TYPE bseg,
255             ls_bseg_new TYPE zfi_bseg,
256             ls_bseg_i   TYPE bseg,
257             ls_bseg_2   TYPE bseg,
258             lv_k_buzei  TYPE buzei,
259             lv_k_wrbtr  TYPE wrbtr.
260
261
262      DATA : lt_bseg     TYPE TABLE OF zfi_bseg,
263             lt_bseg_new TYPE TABLE OF zfi_bseg,
264             lt_bkpf_new TYPE TABLE OF zfibkpf,
265             ls_bkpf_new TYPE zfibkpf.
266      DATA : lt_extension TYPE bapiparex_tab_ac,
267             ls_extension TYPE bapiparex.
268      FIELD-SYMBOLS : <fs_bseg> TYPE zfi_bseg.
269      DATA : lv_sys TYPE tbdls-logsys.
270
271      SORT   : gt_bkpf BY bukrs belnr gjahr,
272               gt_bseg BY bukrs belnr gjahr.
273
274
275
276      LOOP AT  gt_bkpf INTO ls_bkpf .
277
278        REFRESH : lt_gl,
279                  lt_ven,
280                  lt_return,
281                  lt_curr,
282                  lt_bseg,
283                  lt_ctmr,
284                  lt_bapiacwt09,
285                  lt_extension.
286        CLEAR : ls_head.
287        ls_head-username     = sy-uname.
288        ls_head-trans_date = ls_bkpf-wwert.
289    **    CONCATENATE ls_bkpf-bukrs ls_bkpf-belnr ls_bkpf-gjahr INTO ls_head-obj_key.
290    **
291    **
292    **
293    **    CALL FUNCTION 'OWN_LOGICAL_SYSTEM_GET'
294    **      IMPORTING
295    **        own_logical_system             = lv_sys
296    **      EXCEPTIONS
297    **        own_logical_system_not_defined = 1
298    **        OTHERS                         = 2.
299    **    IF sy-subrc <> 0.
300    *** Implement suitable error handling here
301    **    ENDIF.
302    **    ls_head-obj_sys       = lv_sys.
303        ls_head-obj_type     = 'BKPFF'.
304        ls_head-header_txt   = ls_bkpf-bktxt.
305        ls_head-ref_doc_no   = ls_bkpf-xblnr.
306        ls_head-pstng_date   = ls_bkpf-budat.
307        ls_head-doc_date     = ls_bkpf-bldat.
308    *    ls_head-comp_code    = 'OVL'.
309        ls_head-comp_code    = ls_bkpf-bukrs.
310        ls_head-fisc_year    = ls_bkpf-gjahr.
311        ls_head-fis_period   = ls_bkpf-monat.
312        ls_head-doc_type     = 'EZ'.
313        ls_head-vatdate      = ls_bkpf-vatdate.
314    *    ls_head-DOC_STATUS   = '2'.
315
316
317    *    ls_head-invoice_rec_date      = ls_bkpf-reindat.
318
319
320        CLEAR : ls_bseg_i.
321        READ TABLE gt_bseg INTO ls_bseg_i WITH KEY bukrs = ls_bkpf-bukrs
322                                                   belnr = ls_bkpf-belnr
323                                                   gjahr = ls_bkpf-gjahr
324                                                   BINARY SEARCH.
325        IF  sy-subrc = 0 .
326          lv_index = sy-tabix.
327    ***** Refresh ALl internal tables for line items.
328
329
330    *      READ TABLE gt_bseg INTO ls_bseg_2 WITH KEY bukrs = ls_bkpf-bukrs
331    *                                                 belnr = ls_bkpf-belnr
332    *                                                 gjahr = ls_bkpf-gjahr
333    *                                                 koart = 'K'.
334    *      IF sy-subrc = 0.
335    *        lv_k_buzei = ls_bseg_2-buzei.
336    *        lv_k_wrbtr = ls_bseg_2-wrbtr.
337    *      ENDIF.
338
339          LOOP AT gt_bseg INTO ls_bseg FROM lv_index.
340            IF  ls_bseg-bukrs <> ls_bseg_i-bukrs
341              OR ls_bseg-belnr <> ls_bseg_i-belnr
342              OR ls_bseg-gjahr <> ls_bseg_i-gjahr.
343              EXIT.
344            ENDIF.
345            CLEAR : ls_gl,
346                    ls_curr,
347                    ls_ven,
348                    ls_ctmr.
349
350    **    BOC on 27.4.21 by ss
351            DATA: lv_hkont TYPE bseg-hkont.
352
353    **    EOC on 27.4.21
354
355            CASE ls_bseg-koart.
356              WHEN 'S'.
357                PERFORM fm_change_gl USING  ls_bseg
358                                            ls_bkpf
359                                   CHANGING ls_gl
360                                            ls_curr
361                                            lt_curr.
362                APPEND ls_gl TO lt_gl.
363                ls_extension-valuepart1 = sy-repid.
364
365
366                CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
367                  EXPORTING
368                    input  = ls_bseg-hkont
369                  IMPORTING
370                    output = ls_bseg-hkont.
371
372                ls_extension-valuepart4 = ls_bseg-hkont.
373
374                ls_extension-valuepart2 = 'PERNR'.
375                IF ls_bseg-pernr IS NOT INITIAL.
376                  ls_extension-valuepart3 = ls_bseg-pernr .
377                ELSE.
378    *              if ls_bseg-hkont = '0000100412'.          ""commented on 03/10/22 by hrishi n
379                  ls_extension-valuepart3 = so_pernr-low.
380    *              endif.
381                ENDIF.
382                APPEND ls_extension TO lt_extension.
383                CLEAR ls_extension.
384    *
385    *            IF ls_bseg-qsskz IS NOT INITIAL.
386    *              ls_bapiacwt09-itemno_acc = lv_k_buzei.
387    *              ls_bapiacwt09-wt_type    = ls_bseg-qsskz.
388    *              ls_bapiacwt09-bas_amt_lc = ls_bseg-wrbtr. "lv_k_wrbtr.
389    *              ls_bapiacwt09-bas_amt_ind = 'X'.
390    **              ls_bapiacwt09-man_amt_ind = 'X'.
391    *              IF ls_bseg-qsskz = '65' OR ls_bseg-qsskz = '59' OR ls_bseg-qsskz = '66' OR ls_bseg-qsskz = '96'.
392    *                ls_bapiacwt09-wt_code    = 'C3'.
393    *              ELSEIF ls_bseg-qsskz = '96'.
394    *                ls_bapiacwt09-wt_code    = '3C'.
395    *              ELSEIF ls_bseg-qsskz = 'W8'.
396    *                ls_bapiacwt09-wt_code    = 'W1'.
397    *              ENDIF.
398    *
399    *              APPEND ls_bapiacwt09 TO lt_bapiacwt09.
400    *            ENDIF.
401              WHEN 'K' .
402
403                PERFORM fm_change_vendor USING ls_bseg
404                                               ls_bkpf
405                                      CHANGING ls_ven
406                                               ls_curr
407                                               lt_curr.
408
409    *            ls_ven-w_tax_code = 'XX'.
410                APPEND ls_ven TO lt_ven.
411
412
413    *            IF ls_bseg-qsskz IS NOT INITIAL.
414    *              ls_bapiacwt09-itemno_acc = lv_k_buzei.
415    *              ls_bapiacwt09-wt_type    = ls_bseg-qsskz.
416    *              ls_bapiacwt09-bas_amt_lc = lv_k_wrbtr.
417    *              ls_bapiacwt09-bas_amt_ind = 'X'.
418    *
419    **              ls_bapiacwt09-man_amt_ind = 'X'.
420    *
421    *              IF ls_bseg-qsskz = '65' OR ls_bseg-qsskz = '59' OR ls_bseg-qsskz = '66' OR ls_bseg-qsskz = '96'.
422    *                ls_bapiacwt09-wt_code    = 'C3'.
423    *              ELSEIF ls_bseg-qsskz = '96'.
424    *                ls_bapiacwt09-wt_code    = '3C'.
425    *              ELSEIF ls_bseg-qsskz = 'W8'.
426    *                ls_bapiacwt09-wt_code    = 'W1'.
427    *              ENDIF.
428    *
429    *              APPEND ls_bapiacwt09 TO lt_bapiacwt09.
430    *            ENDIF.
431
432    *            ls_tax-itemno_acc = ls_bseg-buzei.
433    *            ls_tax-gl_account = ls_bseg-hkont.
434    *            ls_tax-tax_code   = ls_bseg-mwskz.
435    *            APPEND ls_tax TO lt_tax.
436
437              WHEN 'D'.
438                CLEAR : ls_ctmr.
439                PERFORM fm_change_customer USING ls_bseg
440                                                 ls_bkpf
441                                        CHANGING ls_ctmr
442                                                 ls_curr
443                                                 lt_curr.
444
445
446                APPEND ls_ctmr TO lt_ctmr.
447
448                "-----Added by Manisha bh.Dt:12.05.2017------*
449              WHEN 'A'.
450                PERFORM fm_update_asset USING ls_bseg
451                                              ls_bkpf
452                                     CHANGING ls_head
453                                              ls_gl
454                                              lt_gl
455                                              ls_curr
456                                              lt_curr.
457
458    *            CLEAR : ls_asset.
459    *            ls_head-doc_type     = 'AA'.
460    *            ls_head-obj_type  = ''. "BKPFF'.
461    *            ls_head-bus_act   = 'RFBU'.   "'RMWE' . "
462    *            PERFORM fm_change_asset USING ls_bseg
463    *                                          ls_bkpf
464    *                                 CHANGING ls_gl
465    *                                          ls_curr
466    *                                          lt_curr.
467    *            APPEND ls_gl TO lt_gl.
468    *
469    *            CLEAR ls_extension.
470    *            ls_extension-valuepart1 = sy-repid.
471    *            ls_extension-valuepart2 = 'STATUS_NEW'.
472    *            ls_extension-valuepart3 = '3'.
473    *            APPEND ls_extension TO lt_extension.
474    *
475    *            ls_extension-valuepart1 = sy-repid.
476    *            ls_extension-valuepart2 = 'ANBWA'.
477    *            IF ls_bseg-anbwa IS NOT INITIAL.
478    *              ls_extension-valuepart3 = ls_bseg-anbwa .
479    *            ENDIF.
480    *
481    *            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
482    *              EXPORTING
483    *                input  = ls_bseg-hkont
484    *              IMPORTING
485    *                output = ls_bseg-hkont.
486    *
487    *            ls_extension-valuepart4 = ls_bseg-hkont.
488    *            APPEND ls_extension TO lt_extension.
489    *            CLEAR ls_extension.
490    *
491    *
492    *            ls_extension-valuepart1 = sy-repid.
493    *            ls_extension-valuepart2 = 'XMWST'.
494    *            ls_extension-valuepart3 = ls_bkpf-xmwst.  "bseg-xmwst
495    *            ls_extension-valuepart4 = ls_bseg-hkont.
496    *            APPEND ls_extension TO lt_extension.
497    *
498    *            "--------------------------------------------*
499            ENDCASE.
500
501            MOVE-CORRESPONDING ls_bseg TO ls_bseg_new.
502            APPEND ls_bseg_new TO lt_bseg.
503            CLEAR : ls_bseg,
504                    ls_bseg_new.
505          ENDLOOP.
506
507
508        ENDIF.
509
510        REFRESH : lt_return.
511        " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
512        CALL FUNCTION 'BAPI_ACC_DOCUMENT_CHECK' "#EC CI_USAGE_OK[2628704]
513          " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
514          EXPORTING
515            documentheader    = ls_head     "#EC CI_USAGE_OK[2438131]
516          TABLES
517            accountgl         = lt_gl
518            accountreceivable = lt_ctmr
519            accountpayable    = lt_ven
520            accounttax        = lt_tax
521            currencyamount    = lt_curr
522            return            = lt_return
523            extension2        = lt_extension
524            accountwt         = lt_bapiacwt09.
525
526        READ TABLE lt_return INTO ls_return WITH KEY type = 'E'.
527        IF sy-subrc <> 0.
528    *      ****** If simulation is successful then post document.
529          REFRESH : lt_return.
530          " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
531          CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'  "#EC CI_USAGE_OK
532              "#EC CI_USAGE_OK[2628704]
533      "#EC CI_USAGE_OK[2438131]
534
535            " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
536            EXPORTING
537              documentheader    = ls_head
538            IMPORTING
539              obj_type          = obj_type
540              obj_key           = obj_key
541              obj_sys           = obj_sys
542            TABLES
543              accountgl         = lt_gl
544              accountreceivable = lt_ctmr
545              accountpayable    = lt_ven
546              accounttax        = lt_tax
547              currencyamount    = lt_curr
548              return            = lt_return
549              extension2        = lt_extension
550              accountwt         = lt_bapiacwt09.
551
552    ****  IF document is posted succesfully commit the tranaction.
553          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
554            EXPORTING
555              wait = 'X'.
556
557
558    ************ Prepare the error/Suceess log
559          CLEAR : ls_return.
560
561
562          LOOP AT lt_return INTO ls_return WHERE ( type = 'S' OR type = 'E' ).
563            CLEAR : ls_alv.
564            IF ls_return-type EQ 'S' AND ls_return-number = '605' AND ls_return-id = 'RW' .
565
566    *          PERFORM FM_LOG USING ls_return
567              ls_alv-icon =  '@08@'.   "FOR GREEN COLOR
568              CLEAR : ls_bkpf_new.
569
570              ls_bkpf_new-zbelnr =  ls_alv-belnr_new = ls_return-message_v2+0(10).
571              ls_bkpf_new-zbukrs =  ls_alv-bukrs_new = ls_return-message_v2+10(4).
572              ls_bkpf_new-zgjahr =  ls_alv-gjahr_new = ls_return-message_v2+14(4).
573              MOVE-CORRESPONDING ls_bkpf TO ls_bkpf_new.
574              ls_bkpf_new-message = ls_return-message.
575              ls_bkpf_new-type = 'S'.
576              APPEND ls_bkpf_new  TO lt_bkpf_new.
577
578              LOOP AT  lt_bseg ASSIGNING <fs_bseg>.
579                <fs_bseg>-zbelnr = ls_alv-belnr_new .
580                <fs_bseg>-zbukrs = ls_alv-bukrs_new .
581                <fs_bseg>-zgjahr = ls_alv-gjahr_new .
582                <fs_bseg>-zbuzei = <fs_bseg>-buzei.
583                <fs_bseg>-message = ls_return-message.
584              ENDLOOP.
585
586              APPEND LINES OF lt_bseg TO lt_bseg_new.
587
588              ls_alv-index = gv_no.
589              MOVE-CORRESPONDING ls_return TO ls_alv.
590              ls_alv-bukrs = ls_bkpf-bukrs.
591              ls_alv-belnr = ls_bkpf-belnr.
592              ls_alv-gjahr = ls_bkpf-gjahr.
593              ls_alv-blart = ls_bkpf-blart.
594
595              ADD 1 TO gv_no.
596
597              APPEND ls_alv TO git_alv.
598              CLEAR ls_alv.
599              EXIT.
600
601            ELSEIF ls_return-type EQ 'E' AND ls_return-number <> '609' .
602              CLEAR : ls_bkpf_new.
603
604              ls_alv-icon = '@0A@'.    "FOR RED COLOR
605              ls_alv-belnr_new = ' '.
606              ls_alv-index = gv_no.
607    *          ls_alv-msg = ls_return-message.
608              MOVE-CORRESPONDING ls_return TO ls_alv.
609              ls_alv-bukrs = ls_bkpf-bukrs.
610              ls_alv-belnr = ls_bkpf-belnr.
611              ls_alv-gjahr = ls_bkpf-gjahr.
612              ls_alv-blart = ls_bkpf-blart.
613
614              ADD 1 TO gv_no.
615
616              APPEND ls_alv TO git_alv.
617              CLEAR ls_alv.
618              MOVE-CORRESPONDING ls_bkpf TO ls_bkpf_new.
619    *            ls_bkpf_new = ls_bkpf.
620              ls_bkpf_new-message = ls_return-message.
621              ls_bkpf_new-type = 'E'.
622              APPEND ls_bkpf_new  TO lt_bkpf_new.
623
624              LOOP AT  lt_bseg ASSIGNING <fs_bseg>.
625                <fs_bseg>-message = ls_return-message .
626              ENDLOOP.
627
628              APPEND LINES OF lt_bseg TO lt_bseg_new.
629
630              EXIT .
631
632            ENDIF.
633
634          ENDLOOP.
635
636
637
638    ***   has to be written
639        ELSE.
640
641
642          LOOP AT lt_return INTO ls_return WHERE type = 'E'
643                                            AND  number <> '609'
644                                            AND message_v1 <> 'BKPFF'.
645            CLEAR : ls_bkpf_new.
646
647            ls_alv-icon = '@0A@'.    "FOR RED COLOR
648            ls_alv-belnr_new = ' '.
649            ls_alv-index = gv_no.
650    *          ls_alv-msg = ls_return-message.
651            MOVE-CORRESPONDING ls_return TO ls_alv.
652            ls_alv-bukrs = ls_bkpf-bukrs.
653            ls_alv-belnr = ls_bkpf-belnr.
654            ls_alv-gjahr = ls_bkpf-gjahr.
655            ls_alv-blart = ls_bkpf-blart.
656
657            ADD 1 TO gv_no.
658
659            APPEND ls_alv TO git_alv.
660            CLEAR ls_alv.
661            MOVE-CORRESPONDING ls_bkpf TO ls_bkpf_new.
662    *            ls_bkpf_new = ls_bkpf.
663            ls_bkpf_new-message = ls_return-message.
664            ls_bkpf_new-type = 'E'.
665            APPEND ls_bkpf_new  TO lt_bkpf_new.
666
667            LOOP AT  lt_bseg ASSIGNING <fs_bseg>.
668              <fs_bseg>-message = ls_return-message .
669            ENDLOOP.
670
671            APPEND LINES OF lt_bseg TO lt_bseg_new.
672
673            EXIT .
674
675
676
677          ENDLOOP.
678        ENDIF.
679        CLEAR : ls_bkpf,lv_k_buzei,lv_k_wrbtr.
680      ENDLOOP.
681
682      CALL FUNCTION 'ZFI_UPDATE_ACT'
683        TABLES
684          it_bkpf     = lt_bkpf_new
685          it_bseg     = lt_bseg_new
686        EXCEPTIONS
687          update_fail = 1
688          OTHERS      = 2.
689      IF sy-subrc <> 0.
690
691
692      ELSE.
693        COMMIT WORK AND WAIT .
694      ENDIF.
695
696
697
698
699
700
701
702    ENDFORM.
703    *&---------------------------------------------------------------------*
704    *&      Form  FM_CHANGE_GL
705    *&---------------------------------------------------------------------*
706    *       text
707    *----------------------------------------------------------------------*
708    *      -->P_LS_BSEG  text
709    *      -->P_LS_BKPF  text
710    *      <--P_LS_GL  text
711    *----------------------------------------------------------------------*
712    FORM fm_change_gl  USING    VALUE(ls_bseg) TYPE bseg
713                                VALUE(ls_bkpf) TYPE bkpf
714                       CHANGING ls_gl   TYPE bapiacgl09
715                                ls_curr TYPE  bapiaccr09
716                                lt_curr  TYPE tt_curr.
717
718      DATA ls_vendor TYPE zfi_vendor.
719
720      ls_gl-itemno_acc = ls_bseg-buzei.
721    *  ls_gl-gl_account =  ls_bseg-hkont.
722    *    PERFORM convert_exit CHANGING ls_gl-gl_account.
723
724      DATA ls_gst TYPE zfi_gstgl.
725    * Addition of logic by Ruhani Garg on 9 April 2019.
726      PERFORM convert_exit CHANGING ls_bseg-hkont.
727      SELECT SINGLE * FROM zfi_gstgl INTO ls_gst
728        WHERE ongc_gl = ls_bseg-hkont.
729      IF sy-subrc EQ 0.
730        ls_gl-gl_account = ls_gst-ovl_gl.
731      ELSE.
732        ls_gl-gl_account = ls_bseg-hkont.
733      ENDIF.
734    * End of Changes
735
736      ls_gl-item_text = ls_bseg-sgtxt.
737    *ls_gl-STAT_CON =
738    *ls_gl-LOG_PROC =
739    *ls_gl-AC_DOC_NO =
740      ls_gl-ref_key_1 = ls_bseg-xref1.
741      ls_gl-ref_key_2 = ls_bseg-xref2.
742      ls_gl-ref_key_3 = ls_bseg-xref3.
743    *  ls_gl-acct_key = ls_bseg-ktosl.
744      PERFORM convert_exit CHANGING ls_gl-acct_key.
745      ls_gl-acct_type = ls_bseg-koart.
746    *  ls_gl-tax_code = ls_bseg-mwskz.                    "27.09.2016
747      ls_gl-itemno_tax = ls_bseg-taxps.
748      ls_gl-taxjurcode                   = ls_bseg-txjcd.
749    *ls_gl-DOC_TYPE =
750    *  ls_gl-comp_code = ls_bkpf-bukrs .
751    *  ls_gl-comp_code = 'OVL'.
752      ls_gl-comp_code = ls_bseg-bukrs .
753      ls_gl-bus_area = ls_bseg-gsber.
754      ls_gl-func_area = ls_bseg-fkber.
755      ls_gl-plant = ls_bseg-werks.
756      ls_gl-fis_period  =  ls_bkpf-monat.
757      ls_gl-fisc_year = ls_bseg-gjahr.
758
759
760      ls_gl-pstng_date = ls_bkpf-budat.
761      ls_gl-value_date =  ls_bseg-valut.
762    *ls_gl-FM_AREA =
763
764      ls_gl-customer = ls_bseg-kunnr.
765      PERFORM convert_exit CHANGING ls_gl-customer.
766      ls_gl-cshdis_ind = ls_bseg-xskrl.
767
768      PERFORM convert_exit CHANGING ls_bseg-lifnr.
769      SELECT SINGLE * FROM zfi_vendor INTO ls_vendor
770       WHERE ongc_vendor = ls_bseg-lifnr.
771
772      IF sy-subrc = 0.
773        ls_gl-vendor_no = ls_vendor-ovl_vendor.
774      ELSE.
775        ls_gl-vendor_no = ls_bseg-lifnr.
776      ENDIF.
777    *  ls_gl-vendor_no = ls_bseg-lifnr.
778      PERFORM convert_exit CHANGING ls_gl-vendor_no.
779      ls_gl-alloc_nmbr = ls_bseg-zuonr.
780      "SOC ON 09.04.24 BY ROHIT.
781      IF ls_gl-alloc_nmbr IS INITIAL.
782        ls_gl-alloc_nmbr = so_zuonr-low.
783      ENDIF.                           " EOC BY ROHIT.
784
785    *  ls_gl-tax_code =  ls_bseg-mwskz.                   "27.09.2016
786      ls_gl-taxjurcode = ls_bseg-txjcd.
787    *ls_gl-EXT_OBJECT_ID =
788    *ls_gl-BUS_SCENARIO =
789      ls_gl-costobject = ls_bseg-kstrg.
790      ls_gl-costcenter =  ls_bseg-kostl.
791      IF ls_gl-costcenter IS INITIAL.  "added on 23.03.23 by hrishi n
792        ls_gl-costcenter = so_kostl-low.
793      ENDIF.
794      PERFORM convert_exit CHANGING ls_gl-costcenter.
795
796
797      ls_gl-acttype = ls_bseg-lstar.
798      ls_gl-profit_ctr = ls_bseg-prctr.
799      IF ls_gl-profit_ctr IS INITIAL.
800        ls_gl-profit_ctr = so_prctr-low.
801      ENDIF.
802      ls_gl-part_prctr = ls_bseg-pprct.
803      ls_gl-network = ls_bseg-nplnr.
804      CALL FUNCTION 'CONVERSION_EXIT_ABPSP_OUTPUT'
805        EXPORTING
806          input  = ls_bseg-projk
807        IMPORTING
808          output = ls_gl-wbs_element.
809
810      ls_gl-orderid = ls_bseg-aufnr.
811      PERFORM convert_exit CHANGING ls_gl-orderid.
812    *ls_gl-ORDER_ITNO =
813      ls_gl-routing_no =  ls_bseg-aufpl.
814    *  ls_gl-activity = ls_bseg-vorgn.
815    **ls_gl-COND_TYPE =
816    **ls_gl-COND_COUNT =
817    **ls_gl-COND_ST_NO =
818      ls_gl-fund = ls_bseg-geber.
819      ls_gl-funds_ctr =  ls_bseg-fistl.
820      ls_gl-cmmt_item = ls_bseg-fipos.
821      ls_gl-co_busproc = ls_bseg-prznr.
822      ls_gl-asset_no = ls_bseg-anln1.
823      PERFORM convert_exit CHANGING ls_gl-asset_no.
824      ls_gl-sub_number = ls_bseg-anln2.
825      PERFORM convert_exit CHANGING ls_gl-sub_number.
826    *ls_gl-BILL_TYPE =
827      ls_gl-sales_ord = ls_bseg-vbel2.
828      PERFORM convert_exit CHANGING  ls_gl-sales_ord.
829      ls_gl-s_ord_item = ls_bseg-posn2.
830    *          ls_gl-distr_chan =  ls_bseg-vtweg.
831    *          ls_gl-division = ls_bseg-spart.
832    *          ls_gl-salesorg = ls_bseg-vkorg.
833    *          ls_gl-sales_grp = ls_bseg-vkgrp.
834    *          ls_gl-sales_off = ls_bseg-vkbur.
835    *          ls_gl-sold_to = ls_bseg-kunag.
836      ls_gl-de_cre_ind = ls_bseg-tbtkz.
837    ***ls_gl-P_EL_PRCTR =
838    ***ls_gl-XMFRW =
839    ***ls_gl-QUANTITY =
840    ***ls_gl-BASE_UOM =
841    ***ls_gl-BASE_UOM_ISO  =
842    ***ls_gl-INV_QTY  =
843    ***ls_gl-INV_QTY_SU  =
844    ***ls_gl-SALES_UNIT  =
845    ***ls_gl-SALES_UNIT_ISO  =
846    ***ls_gl-PO_PR_QNT  =
847    ***ls_gl-PO_PR_UOM  =
848    ***ls_gl-PO_PR_UOM_ISO  =
849    ***ls_gl-ENTRY_QNT  =
850    ***ls_gl-ENTRY_UOM  =
851    ***ls_gl-ENTRY_UOM_ISO  =
852    ***ls_gl-VOLUME  =
853    ***ls_gl-VOLUMEUNIT  =
854    ***ls_gl-VOLUMEUNIT_ISO  =
855    ***ls_gl-GROSS_WT  =
856    ***ls_gl-NET_WEIGHT  =
857    ***ls_gl-UNIT_OF_WT  =
858    ***ls_gl-UNIT_OF_WT_ISO  =
859    ***ls_gl-ITEM_CAT  =
860    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
861    * S/4: material field length 18->40; populate MATERIAL_LONG (40-char).
862    *  ls_gl-material  =  ls_bseg-matnr.
863      ls_gl-material_long = ls_bseg-matnr.
864    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
865      PERFORM convert_exit CHANGING ls_gl-material.
866    ***ls_gl-MATL_TYPE  =
867    ***ls_gl-MVT_IND  =
868    ***ls_gl-REVAL_IND  =
869    ***ls_gl-ORIG_GROUP  =
870    ***ls_gl-ORIG_MAT  =
871    ***ls_gl-SERIAL_NO  =
872    ***ls_gl-PART_ACCT  =
873    ***ls_gl-TR_PART_BA  =
874    ***ls_gl-TRADE_ID  =
875    ***ls_gl-VAL_AREA  =
876    ***ls_gl-VAL_TYPE  =
877    ***ls_gl-ASVAL_DATE  =
878    ***ls_gl-PO_NUMBER  =
879    ***ls_gl-PO_ITEM  =
880    ***ls_gl-ITM_NUMBER  =
881    ***ls_gl-COND_CATEGORY  =
882    ***ls_gl-FUNC_AREA_LONG  =
883    ***ls_gl-CMMT_ITEM_LONG  =
884    ***ls_gl-GRANT_NBR  =
885    ***ls_gl-MEASURE  =
886    ***ls_gl-SEGMENT  =
887    ***ls_gl-PARTNER_SEGMENT  =
888    ***ls_gl-RES_DOC  =
889    ***ls_gl-RES_ITEM  =
890    ***ls_gl-BILLING_PERIOD_START_DATE  =
891    ***ls_gl-BILLING_PERIOD_END_DATE  =
892      ls_gl-cmmt_item = ls_bseg-fipos.
893      ls_gl-ppa_ex_ind  =  ls_bseg-ppa_ex_ind.
894      ls_gl-fastpay  =  ls_bseg-fastpay.
895    ***ls_gl-PARTNER_GRANT_NBR  =
896      ls_gl-budget_period  = ls_bseg-budget_pd.
897      ls_gl-partner_budget_period  =  ls_bseg-pbudget_pd.
898      ls_gl-partner_fund  =  ls_bseg-pgeber.
899      ls_gl-itemno_tax  =  ls_bseg-taxps.
900
901      IF  ls_bseg-vertn IS NOT INITIAL .
902        ls_gl-costcenter = 'OVLJVCP001'.
903      ENDIF.
904    ***ls_gl-PAYMENT_TYPE  =
905    ***ls_gl-EXPENSE_TYPE  =
906    ***ls_gl-PROGRAM_PROFILE  =
907
908
909
910
911      ls_curr-itemno_acc = ls_bseg-buzei.
912      ls_curr-currency = ls_bkpf-waers.
913      IF ls_bseg-shkzg = 'H'.
914        ls_bseg-wrbtr = ls_bseg-wrbtr * -1.
915      ENDIF.
916    *  ls_curr-disc_base = ls_bseg-skfbt.
917    *  ls_curr-disc_amt = ls_bseg-sknto.
918    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
919    *  ls_curr-amt_doccur = ls_bseg-wrbtr.
920      ls_curr-amt_doccur = CONV #( ls_bseg-wrbtr ).
921    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
922    *  ls_curr-exch_rate_v = ls_bkpf-kurs2.
923    *  IF  ls_curr-exch_rate_v LT 0.
924    * ls_curr-exch_rate_v = ls_curr-exch_rate_v * -1.
925    *  ENDIF.
926      ls_curr-exch_rate = ls_bkpf-kursf.
927      IF  ls_curr-exch_rate IS INITIAL .
928        ls_curr-exch_rate = ls_bkpf-kurs2.
929      ENDIF.
930
931      IF  ls_curr-exch_rate LT 0.
932        ls_curr-exch_rate = ls_curr-exch_rate * -1.
933      ENDIF.
934
935
936      APPEND ls_curr TO lt_curr.
937
938      ls_curr-curr_type = '10'.
939      ls_curr-currency = ls_bkpf-hwaer.
940      ls_curr-itemno_acc = ls_bseg-buzei.
941      IF ls_bseg-shkzg = 'H'.
942        ls_bseg-dmbtr = ls_bseg-dmbtr * -1.
943      ENDIF.
944    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
945    *  ls_curr-amt_doccur = ls_bseg-dmbtr.
946      ls_curr-amt_doccur = CONV #( ls_bseg-dmbtr ).
947    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
948      ls_curr-exch_rate = ls_bkpf-kursf.
949      IF  ls_curr-exch_rate IS INITIAL .
950        ls_curr-exch_rate = ls_bkpf-kurs2.
951      ENDIF.
952
953      IF  ls_curr-exch_rate LT 0.
954        ls_curr-exch_rate = ls_curr-exch_rate * -1.
955      ENDIF.
956
957
958      APPEND ls_curr TO lt_curr.
959
960      ls_curr-curr_type = '50'.
961      ls_curr-currency = ls_bkpf-hwae2.
962      ls_curr-itemno_acc = ls_bseg-buzei.
963      IF ls_bseg-shkzg = 'H'.
964        ls_bseg-dmbe2 = ls_bseg-dmbe2 * -1.
965      ENDIF.
966    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
967    *  ls_curr-amt_doccur = ls_bseg-dmbe2.
968      ls_curr-amt_doccur = CONV #( ls_bseg-dmbe2 ).
969    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
970      ls_curr-exch_rate = ls_bkpf-kursf.
971      IF  ls_curr-exch_rate IS INITIAL .
972        ls_curr-exch_rate = ls_bkpf-kurs2.
973      ENDIF.
974
975      IF  ls_curr-exch_rate LT 0.
976        ls_curr-exch_rate = ls_curr-exch_rate * -1.
977      ENDIF.
978
979      APPEND ls_curr TO lt_curr.
980
981    ENDFORM.
982    *&---------------------------------------------------------------------*
983    *&      Form  FM_CHANGE_VENDOR
984    *&---------------------------------------------------------------------*
985    *       text
986    *----------------------------------------------------------------------*
987    *      -->P_LS_BSEG  text
988    *      -->P_LS_BKPF  text
989    *      <--P_LS_VEN  text
990    *      <--P_LS_CURR  text
991    *------------------------------------------ ----------------------------*
992    FORM fm_change_vendor  USING    VALUE(ls_bseg) TYPE bseg
993                                          ls_bkpf  TYPE bkpf
994                          CHANGING        ls_ven   TYPE bapiacap09
995                                          ls_curr  TYPE bapiaccr09
996                                          lt_curr  TYPE tt_curr.
997
998      DATA : ls_vendor TYPE zfi_vendor.
999
1000
1001     CLEAR : ls_ven,
1002                   ls_curr.
1003     ls_ven-itemno_acc = ls_bseg-buzei.
1004     CLEAR ls_vendor.
1005     PERFORM convert_exit CHANGING ls_bseg-lifnr.
1006
1007
1008     SELECT SINGLE * FROM zfi_vendor INTO ls_vendor
1009      WHERE ongc_vendor = ls_bseg-lifnr.
1010
1011     IF sy-subrc = 0.
1012       ls_ven-vendor_no = ls_vendor-ovl_vendor.
1013     ELSE.
1014       ls_ven-vendor_no = ls_bseg-lifnr.
1015     ENDIF.
1016
1017     ls_ven-gl_account = ls_bseg-hkont.
1018     ls_ven-bus_area = ls_bseg-gsber.
1019     PERFORM convert_exit CHANGING ls_ven-gl_account .
1020     PERFORM convert_exit CHANGING ls_ven-vendor_no .
1021     ls_ven-pmnttrms = ls_bseg-zterm.
1022
1023     PERFORM convert_exit CHANGING ls_ven-pmnttrms .
1024     ls_ven-alloc_nmbr =  ls_bseg-zuonr.
1025     IF ls_ven-alloc_nmbr IS INITIAL.
1026       ls_ven-alloc_nmbr = so_zuonr-low.
1027     ENDIF.
1028     ls_ven-bline_date = ls_bseg-zfbdt.
1029     ls_ven-sp_gl_ind = ls_bseg-umskz .
1030   *  ls_ven-itemno_tax = ls_bseg-mwskz.
1031     ls_ven-item_text = ls_bseg-sgtxt.
1032     ls_ven-profit_ctr = ls_bseg-prctr.
1033     ls_ven-pymt_meth = ls_bseg-zlsch.
1034     ls_ven-sectioncode = ls_bseg-secco.
1035     ls_curr-itemno_acc = ls_bseg-buzei.
1036     ls_curr-currency = ls_bkpf-waers.
1037     IF ls_bseg-shkzg = 'H'.
1038       ls_bseg-wrbtr = ls_bseg-wrbtr * -1.
1039     ENDIF.
1040   *  ls_curr-disc_base = ls_bseg-skfbt.
1041   *  ls_curr-disc_amt = ls_bseg-sknto.
1042   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1043   *  ls_curr-amt_doccur = ls_bseg-wrbtr.
1044     ls_curr-amt_doccur = CONV #( ls_bseg-wrbtr ).
1045   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1046   *  ls_curr-exch_rate_v = ls_bkpf-kurs2.
1047     ls_curr-exch_rate = ls_bkpf-kursf.
1048     IF  ls_curr-exch_rate IS INITIAL .
1049       ls_curr-exch_rate = ls_bkpf-kurs2.
1050     ENDIF.
1051
1052     IF  ls_curr-exch_rate LT 0.
1053       ls_curr-exch_rate = ls_curr-exch_rate * -1.
1054     ENDIF.
1055   *    IF  ls_curr-exch_rate_v LT 0.
1056   * ls_curr-exch_rate_v = ls_curr-exch_rate_v * -1.
1057   *  ENDIF.
1058
1059
1060
1061     APPEND ls_curr TO lt_curr.
1062
1063     ls_curr-curr_type = '10'.
1064     ls_curr-currency = ls_bkpf-hwaer.
1065     ls_curr-itemno_acc = ls_bseg-buzei.
1066     IF ls_bseg-shkzg = 'H'.
1067       ls_bseg-dmbtr = ls_bseg-dmbtr * -1.
1068     ENDIF.
1069   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1070   *  ls_curr-amt_doccur = ls_bseg-dmbtr.
1071     ls_curr-amt_doccur = CONV #( ls_bseg-dmbtr ).
1072   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1073     ls_curr-exch_rate = ls_bkpf-kursf.
1074     IF  ls_curr-exch_rate IS INITIAL .
1075       ls_curr-exch_rate = ls_bkpf-kurs2.
1076     ENDIF.
1077
1078     IF  ls_curr-exch_rate LT 0.
1079       ls_curr-exch_rate = ls_curr-exch_rate * -1.
1080     ENDIF.
1081
1082
1083     APPEND ls_curr TO lt_curr.
1084
1085     ls_curr-curr_type = '50'.
1086     ls_curr-currency = ls_bkpf-hwae2.
1087     ls_curr-itemno_acc = ls_bseg-buzei.
1088     IF ls_bseg-shkzg = 'H'.
1089       ls_bseg-dmbe2 = ls_bseg-dmbe2 * -1.
1090     ENDIF.
1091   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1092   *  ls_curr-amt_doccur = ls_bseg-dmbe2.
1093     ls_curr-amt_doccur = CONV #( ls_bseg-dmbe2 ).
1094   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1095     ls_curr-exch_rate = ls_bkpf-kursf.
1096     IF  ls_curr-exch_rate IS INITIAL .
1097       ls_curr-exch_rate = ls_bkpf-kurs2.
1098     ENDIF.
1099
1100     IF  ls_curr-exch_rate LT 0.
1101       ls_curr-exch_rate = ls_curr-exch_rate * -1.
1102     ENDIF.
1103
1104
1105     APPEND ls_curr TO lt_curr.
1106   ENDFORM.
1107   *&---------------------------------------------------------------------*
1108   *&      Form  FM_CHANGE_CUSTOMER
1109   *&---------------------------------------------------------------------*
1110   *       text
1111   *----------------------------------------------------------------------*
1112   *      -->P_LS_BSEG  text
1113   *      -->P_LS_BKPF  text
1114   *      <--P_LS_CTMR  text
1115   *      <--P_LS_CURR  text
1116   *----------------------------------------------------------------------*
1117   FORM fm_change_customer  USING      VALUE(ls_bseg) TYPE bseg
1118                                       VALUE(ls_bkpf) TYPE bkpf
1119                            CHANGING   ls_ctmr        TYPE bapiacar09
1120                                       ls_curr        TYPE  bapiaccr09
1121                                       lt_curr        TYPE tt_curr.
1122
1123
1124     CLEAR : ls_ctmr,
1125             ls_curr.
1126     ls_ctmr-itemno_acc = ls_bseg-buzei.
1127     ls_ctmr-customer = ls_bseg-kunnr.
1128     PERFORM convert_exit CHANGING ls_ctmr-customer.
1129
1130     SELECT SINGLE akont FROM  knb1 INTO ls_ctmr-gl_account   "" added by ss on 02/05/2021
1131                         WHERE kunnr EQ ls_ctmr-customer AND
1132                               bukrs EQ ls_bseg-bukrs.
1133
1134     PERFORM convert_exit CHANGING ls_ctmr-gl_account.
1135     ls_ctmr-pmnttrms = ls_bseg-zterm.
1136   *  ls_ven-bline_date = ls_bseg-zfbdt.
1137     ls_ctmr-sp_gl_ind = ls_bseg-umskz .
1138     ls_ctmr-bus_area = ls_bseg-gsber.
1139   *  ls_ctmr-itemno_tax = ls_bseg-mwskz.
1140
1141     ls_ctmr-item_text = ls_bseg-sgtxt.
1142     ls_ctmr-profit_ctr = ls_bseg-prctr.
1143
1144     ls_curr-itemno_acc = ls_bseg-buzei.
1145     ls_curr-currency = ls_bkpf-waers.
1146     IF ls_bseg-shkzg = 'H'.
1147       ls_bseg-wrbtr = ls_bseg-wrbtr * -1.
1148     ENDIF.
1149   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1150   *  ls_curr-amt_doccur = ls_bseg-wrbtr.
1151     ls_curr-amt_doccur = CONV #( ls_bseg-wrbtr ).
1152   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1153     ls_curr-exch_rate = ls_bkpf-kursf.
1154     IF  ls_curr-exch_rate IS INITIAL .
1155       ls_curr-exch_rate = ls_bkpf-kurs2.
1156     ENDIF.
1157   *  ls_curr-exch_rate_v = ls_bkpf-kurs2.
1158   *  ls_curr-disc_base = ls_bseg-skfbt.
1159   *  ls_curr-disc_amt = ls_bseg-sknto.
1160     IF  ls_curr-exch_rate LT 0.
1161       ls_curr-exch_rate = ls_curr-exch_rate * -1.
1162     ENDIF.
1163
1164
1165
1166     APPEND ls_curr TO lt_curr.
1167
1168     ls_curr-curr_type = '10'.
1169     ls_curr-currency = ls_bkpf-hwaer.
1170     ls_curr-itemno_acc = ls_bseg-buzei.
1171     IF ls_bseg-shkzg = 'H'.
1172       ls_bseg-dmbtr = ls_bseg-dmbtr * -1.
1173     ENDIF.
1174   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1175   *  ls_curr-amt_doccur = ls_bseg-dmbtr.
1176     ls_curr-amt_doccur = CONV #( ls_bseg-dmbtr ).
1177   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1178     ls_curr-exch_rate = ls_bkpf-kursf.
1179     IF  ls_curr-exch_rate IS INITIAL .
1180       ls_curr-exch_rate = ls_bkpf-kurs2.
1181     ENDIF.
1182
1183     IF  ls_curr-exch_rate LT 0.
1184       ls_curr-exch_rate = ls_curr-exch_rate * -1.
1185     ENDIF.
1186
1187
1188     APPEND ls_curr TO lt_curr.
1189
1190     ls_curr-curr_type = '50'.
1191     ls_curr-currency = ls_bkpf-hwae2.
1192     ls_curr-itemno_acc = ls_bseg-buzei.
1193     IF ls_bseg-shkzg = 'H'.
1194       ls_bseg-dmbe2 = ls_bseg-dmbe2 * -1.
1195     ENDIF.
1196   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1197   *  ls_curr-amt_doccur = ls_bseg-dmbe2.
1198     ls_curr-amt_doccur = CONV #( ls_bseg-dmbe2 ).
1199   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1200     ls_curr-exch_rate = ls_bkpf-kursf.
1201     IF  ls_curr-exch_rate IS INITIAL .
1202       ls_curr-exch_rate = ls_bkpf-kurs2.
1203     ENDIF.
1204
1205     IF  ls_curr-exch_rate LT 0.
1206       ls_curr-exch_rate = ls_curr-exch_rate * -1.
1207     ENDIF.
1208
1209
1210     APPEND ls_curr TO lt_curr.
1211   ENDFORM.
1212
1213
1214
1215
1216   *&---------------------------------------------------------------------*
1217   *&      Form  SUB_FILL_ALV
1218   *&---------------------------------------------------------------------*
1219   *       text
1220   *----------------------------------------------------------------------*
1221   *  -->  p1        text
1222   *  <--  p2        text
1223   *----------------------------------------------------------------------*
1224   FORM sub_fill_alv .
1225
1226
1227     DATA : ls_fld TYPE slis_fieldcat_alv.
1228     CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
1229       EXPORTING
1230         i_program_name         = sy-repid
1231         i_structure_name       = 'ZFI_S_ALV'
1232         i_client_never_display = 'X'
1233       CHANGING
1234         ct_fieldcat            = gt_fld
1235       EXCEPTIONS
1236         inconsistent_interface = 1
1237         program_error          = 2
1238         OTHERS                 = 3.
1239     IF sy-subrc <> 0.
1240   * Implement suitable error handling here
1241     ENDIF.
1242
1243
1244     LOOP AT  gt_fld INTO ls_fld.
1245       CASE ls_fld-fieldname.
1246         WHEN 'INDEX'.
1247           ls_fld-seltext_l = TEXT-001.
1248           ls_fld-seltext_m = TEXT-001.
1249           ls_fld-seltext_s = TEXT-001.
1250
1251       ENDCASE.
1252       ls_fld-ddictxt = 'M'.
1253       MODIFY gt_fld FROM ls_fld TRANSPORTING seltext_l seltext_m seltext_s ddictxt.
1254     ENDLOOP.
1255
1256     CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
1257       EXPORTING
1258         i_callback_program     = sy-repid
1259         i_callback_top_of_page = 'TOP_OF_PAGE'  "see FORM
1260         it_fieldcat            = gt_fld[]
1261         i_save                 = 'X'
1262       TABLES
1263         t_outtab               = git_alv
1264       EXCEPTIONS
1265         program_error          = 1
1266         OTHERS                 = 2.
1267     IF sy-subrc <> 0.
1268       MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
1269               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
1270     ENDIF.
1271   ENDFORM.                    " SUB_FILL_ALV
1272
1273
1274   FORM top_of_page.
1275   *ALV Header declarations
1276     DATA: lt_header  TYPE slis_t_listheader,
1277           lwa_header TYPE slis_listheader.
1278
1279   * Title
1280     lwa_header-typ  = 'H'.
1281     lwa_header-info = TEXT-003.
1282     APPEND lwa_header TO lt_header.
1283     CLEAR lwa_header.
1284
1285   *   date
1286     lwa_header-typ  = 'S'.
1287     lwa_header-key = TEXT-007.
1288     CONCATENATE  sy-datum+6(2) '.'
1289                  sy-datum+4(2) '.'
1290                  sy-datum(4) INTO lwa_header-info.   "todays date
1291     APPEND lwa_header TO lt_header.
1292     CLEAR: lwa_header.
1293
1294
1295     CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
1296       EXPORTING
1297         it_list_commentary = lt_header.
1298   ENDFORM.
1299   *&---------------------------------------------------------------------*
1300   *&      Form  FM_CLEAR
1301   *&---------------------------------------------------------------------*
1302   *       text
1303   *----------------------------------------------------------------------*
1304   **Clear  Global internal tables
1305   *----------------------------------------------------------------------*
1306   FORM fm_clear .
1307     REFRESH : gt_bkpf ,
1308               gt_bseg ,
1309               git_alv ,
1310               gt_fld  .
1311
1312     CLEAR : gv_no.
1313   ENDFORM.
1314   *&---------------------------------------------------------------------*
1315   *&      Form  FM_GET_DATA
1316   *&---------------------------------------------------------------------*
1317   *       text
1318   *----------------------------------------------------------------------*
1319   *  -->  p1        text
1320   *  <--  p2        text
1321   *----------------------------------------------------------------------*
1322   FORM fm_get_data .
1323
1324     DATA: l_filename TYPE string,
1325           l_filen    TYPE string,
1326           l_path     TYPE string,
1327           l_fullpath TYPE string,
1328           l_usr_act  TYPE i.
1329
1330     SELECT * FROM bkpf INTO TABLE gt_bkpf
1331       WHERE bukrs IN so_bukrs
1332       AND belnr IN so_belnr
1333       AND gjahr IN so_gjahr
1334       AND budat IN so_budat ORDER BY PRIMARY KEY.
1335
1336     IF  gt_bkpf IS NOT INITIAL .
1337       " " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1338       SELECT * FROM bseg INTO TABLE gt_bseg "#EC CI_DB_OPERATION_OK[2431747]
1339         FOR ALL ENTRIES IN gt_bkpf
1340         WHERE bukrs = gt_bkpf-bukrs
1341         AND belnr = gt_bkpf-belnr
1342         AND gjahr = gt_bkpf-gjahr ORDER BY PRIMARY KEY.
1343       " " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
1344     ENDIF.
1345
1346   **  PERFO.RM FM_GET_DATA_ICE .
1347   *  INSERT INITIAL LINE INTO gt_bkpf INDEX 1.
1348   *  INSERT INITIAL LINE INTO gt_bseg INDEX 1.
1349
1350
1351
1352     l_filename = space.
1353
1354
1355     CALL METHOD cl_gui_frontend_services=>file_save_dialog
1356       EXPORTING
1357         default_file_name    = l_filename
1358       CHANGING
1359         filename             = l_filen
1360         path                 = l_path
1361         fullpath             = l_fullpath
1362         user_action          = l_usr_act
1363       EXCEPTIONS
1364         cntl_error           = 1
1365         error_no_gui         = 2
1366         not_supported_by_gui = 3
1367         OTHERS               = 4.
1368
1369     IF sy-subrc = 0
1370     AND l_usr_act <> cl_gui_frontend_services=>action_cancel.
1371
1372       CALL FUNCTION 'GUI_DOWNLOAD'
1373         EXPORTING
1374           filename                = l_fullpath
1375           filetype                = 'DAT'
1376         TABLES
1377           data_tab                = gt_bkpf
1378   *       FIELDNAMES              =
1379         EXCEPTIONS
1380           file_write_error        = 1
1381           no_batch                = 2
1382           gui_refuse_filetransfer = 3
1383           invalid_type            = 4
1384           no_authority            = 5
1385           unknown_error           = 6
1386           header_not_allowed      = 7
1387           separator_not_allowed   = 8
1388           filesize_not_allowed    = 9
1389           header_too_long         = 10
1390           dp_error_create         = 11
1391           dp_error_send           = 12
1392           dp_error_write          = 13
1393           unknown_dp_error        = 14
1394           access_denied           = 15
1395           dp_out_of_memory        = 16
1396           disk_full               = 17
1397           dp_timeout              = 18
1398           file_not_found          = 19
1399           dataprovider_exception  = 20
1400           control_flush_error     = 21
1401           OTHERS                  = 22.
1402       IF sy-subrc <> 0.
1403   * Implement suitable error handling here
1404       ENDIF.
1405
1406
1407     ENDIF.
1408
1409
1410
1411     l_filename = space.
1412
1413
1414     CALL METHOD cl_gui_frontend_services=>file_save_dialog
1415       EXPORTING
1416         default_file_name    = l_filename
1417       CHANGING
1418         filename             = l_filen
1419         path                 = l_path
1420         fullpath             = l_fullpath
1421         user_action          = l_usr_act
1422       EXCEPTIONS
1423         cntl_error           = 1
1424         error_no_gui         = 2
1425         not_supported_by_gui = 3
1426         OTHERS               = 4.
1427
1428     IF sy-subrc = 0
1429     AND l_usr_act <> cl_gui_frontend_services=>action_cancel.
1430
1431       CALL FUNCTION 'GUI_DOWNLOAD'
1432         EXPORTING
1433           filename                = l_fullpath
1434           filetype                = 'DAT'
1435         TABLES
1436           " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1437   *       data_tab                = gt_bseg
1438           data_tab                = gt_bseg "#EC CI_FLDEXT_OK[2610650]
1439           " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
1440   *       FIELDNAMES              =
1441         EXCEPTIONS
1442           file_write_error        = 1
1443           no_batch                = 2
1444           gui_refuse_filetransfer = 3
1445           invalid_type            = 4
1446           no_authority            = 5
1447           unknown_error           = 6
1448           header_not_allowed      = 7
1449           separator_not_allowed   = 8
1450           filesize_not_allowed    = 9
1451           header_too_long         = 10
1452           dp_error_create         = 11
1453           dp_error_send           = 12
1454           dp_error_write          = 13
1455           unknown_dp_error        = 14
1456           access_denied           = 15
1457           dp_out_of_memory        = 16
1458           disk_full               = 17
1459           dp_timeout              = 18
1460           file_not_found          = 19
1461           dataprovider_exception  = 20
1462           control_flush_error     = 21
1463           OTHERS                  = 22.
1464       IF sy-subrc <> 0.
1465   * Implement suitable error handling here
1466       ENDIF.
1467
1468
1469     ENDIF.
1470   ENDFORM.
1471   **&---------------------------------------------------------------------*
1472   **&      Form  FM_ADD_TAX
1473   **&---------------------------------------------------------------------*
1474   **       text
1475   **----------------------------------------------------------------------*
1476   **      -->P_LS_BSEG  text
1477   **      -->P_LS_BKPF  text
1478   **      -->P_LS_GL  text
1479   **      <--P_LS_TAX  text
1480   **----------------------------------------------------------------------*
1481   *FORM fm_add_tax  USING    VALUE(ls_bseg) TYPE bseg
1482   *                          VALUE(ls_bkpf) TYPE bkpf
1483   *                VALUE(ls_gl)   TYPE bapiacgl09
1484   *                CHANGING ls_tax TYPE bapiactx09.
1485   *
1486   *  ls_tax-itemno_acc = ls_gl-itemno_acc.
1487   *  ls_tax-gl_account = ls_gl-gl_account.
1488   **ls_tax-COND_KEY =
1489   *  ls_tax-acct_key = ls_bseg-ktosl.
1490   *  ls_tax-tax_code = ls_gl-tax_code.
1491   ***ls_tax-TAX_RATE =
1492   ***ls_tax-TAX_DATE
1493   ***ls_tax-TAXJURCODE
1494   ***ls_tax-TAXJURCODE_DEEP
1495   ***ls_tax-TAXJURCODE_LEVEL
1496   *  ls_tax-itemno_tax = ls_gl-itemno_tax.
1497   **ls_tax-DIRECT_TAX
1498   *
1499   *
1500   *ENDFORM.
1501   *&---------------------------------------------------------------------*
1502   *&      Form  FM_MAND
1503   *&---------------------------------------------------------------------*
1504   *       text
1505   *----------------------------------------------------------------------*
1506   *  -->  p1        text
1507   *  <--  p2        text
1508   *----------------------------------------------------------------------*
1509
1510   FORM convert_exit USING p_string .
1511
1512     CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
1513       EXPORTING
1514         input  = p_string
1515       IMPORTING
1516         output = p_string.
1517
1518   ENDFORM.
1519   *&---------------------------------------------------------------------*
1520   *&      Form  FM_CHANGE_CURR
1521   *&---------------------------------------------------------------------*
1522   ***       text
1523   ***----------------------------------------------------------------------*
1524   ***      -->P_LS_BSEG  text
1525   ***      -->P_LS_BKPF  text
1526   ***      <--P_LS_CURR  text
1527   ***----------------------------------------------------------------------*
1528   **FORM fm_change_curr  USING    VALUE(ls_bseg) TYPE bseg
1529   **                             VALUE(ls_bkpf) TYPE bkpf
1530   **                                  uv_1    TYPE char1
1531   **                   CHANGING
1532   **                            ls_curr TYPE  bapiaccr09.
1533   **
1534   **  IF uv_1 = 1.
1535   **    ls_curr-curr_type = '10'.
1536   **    ls_curr-currency = ls_bkpf-hwaer.
1537   **    ls_curr-itemno_acc = ls_bseg-buzei.
1538   **    IF ls_bseg-shkzg = 'H'.
1539   **      ls_bseg-dmbtr = ls_bseg-dmbtr * -1.
1540   **    ENDIF.
1541   **    ls_curr-amt_doccur = ls_bseg-dmbtr.
1542   **    ls_curr-exch_rate = ls_bkpf-kursf.
1543   **    IF  ls_curr-exch_rate IS INITIAL .
1544   **      ls_curr-exch_rate = ls_bkpf-kurs2.
1545   **    ENDIF.
1546   **
1547   **    IF  ls_curr-exch_rate LT 0.
1548   **      ls_curr-exch_rate = ls_curr-exch_rate * -1.
1549   **    ENDIF.
1550   **
1551   **  ELSE.
1552   **    ls_curr-curr_type = '50'.
1553   **    ls_curr-currency = ls_bkpf-hwae2.
1554   **    ls_curr-itemno_acc = ls_bseg-buzei.
1555   **    IF ls_bseg-shkzg = 'H'.
1556   **      ls_bseg-dmbe2 = ls_bseg-dmbe2 * -1.
1557   **    ENDIF.
1558   **    ls_curr-amt_doccur = ls_bseg-dmbe2.
1559   **    ls_curr-exch_rate = ls_bkpf-kursf.
1560   **    IF  ls_curr-exch_rate IS INITIAL .
1561   **      ls_curr-exch_rate = ls_bkpf-kurs2.
1562   **    ENDIF.
1563   **
1564   **    IF  ls_curr-exch_rate LT 0.
1565   **      ls_curr-exch_rate = ls_curr-exch_rate * -1.
1566   **    ENDIF.
1567   **
1568   **
1569   **  ENDIF.
1570   **ENDFORM.
1571   *&---------------------------------------------------------------------*
1572   *&      Form  FM_CHANGE_AASET
1573   *&---------------------------------------------------------------------*
1574   *       text
1575   *----------------------------------------------------------------------*
1576   *      -->P_LS_BSEG  text
1577   *      -->P_LS_BKPF  text
1578   *      <--P_LS_ASSET  text
1579   *      <--P_LS_CURR  text
1580   *      <--P_LT_CURR  text
1581   *----------------------------------------------------------------------*
1582   FORM fm_change_asset  USING   VALUE(ls_bseg)   TYPE bseg
1583                                         ls_bkpf  TYPE bkpf
1584                         CHANGING        ls_gl    TYPE bapiacgl09 "ls_asset TYPE bapiacgl09
1585                                         ls_curr  TYPE bapiaccr09
1586                                         lt_curr  TYPE tt_curr.
1587
1588   *  SELECT SINGLE ktogr FROM anla INTO lv_ktogr
1589   *        WHERE   bukrs = gwa_final-bukrs AND
1590   *                anln1 = lv_text1.
1591   **   READ TABLE lt_anla INTO ls_anla with key
1592   **                bukrs = gwa_final-bukrs
1593   **                anln1 = lv_text1.
1594
1595   *        lv_ktogr1 = lv_ktogr.
1596   *        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
1597   *          EXPORTING
1598   *            input  = lv_ktogr1
1599   *          IMPORTING
1600   *            output = lv_ktogr1.
1601
1602     ls_gl-itemno_acc = ls_bseg-buzei.      ""
1603     ls_gl-gl_account =  ls_bseg-hkont.      ""
1604     PERFORM convert_exit CHANGING ls_gl-gl_account.
1605
1606
1607     ls_gl-item_text = ls_bseg-sgtxt.      ""
1608   *ls_gl-STAT_CON =
1609   *ls_gl-LOG_PROC =
1610   *ls_gl-AC_DOC_NO =
1611     ls_gl-ref_key_1 = ls_bseg-xref1.
1612     ls_gl-ref_key_2 = ls_bseg-xref2.
1613     ls_gl-ref_key_3 = ls_bseg-xref3.
1614   *  ls_gl-acct_key = ls_bseg-ktosl.
1615     PERFORM convert_exit CHANGING ls_gl-acct_key.
1616     ls_gl-acct_type = ls_bseg-koart.
1617   *  ls_gl-tax_code = ls_bseg-mwskz.                    "27.09.2016
1618     "commented by Manisha.bh.Dt:
1619   ***  ls_gl-itemno_tax = ls_bseg-taxps
1620   ***  ls_gl-taxjurcode                   = ls_bseg-txjcd.
1621     "------------
1622   *ls_gl-DOC_TYPE =
1623   *  ls_gl-comp_code = ls_bkpf-bukrs .
1624   *  ls_gl-comp_code = 'OVL'.
1625     ls_gl-comp_code = ls_bseg-bukrs .    ""
1626     ls_gl-bus_area = ls_bseg-vorgn.      ""ls_bseg-gsber. Changed by Manisha bh.Dt:16.05.2017
1627     ls_gl-func_area = ls_bseg-fkber.
1628     ls_gl-plant = ls_bseg-werks.
1629     ls_gl-fis_period  =  ls_bkpf-monat.   ""
1630     ls_gl-fisc_year = ls_bseg-gjahr.
1631
1632
1633     ls_gl-pstng_date = ls_bkpf-budat.    ""
1634     ls_gl-value_date =  ls_bseg-valut.   ""
1635   *ls_gl-FM_AREA =
1636
1637     ls_gl-customer = ls_bseg-kunnr.
1638     PERFORM convert_exit CHANGING ls_gl-customer.
1639     ls_gl-cshdis_ind = ls_bseg-xskrl.
1640
1641     PERFORM convert_exit CHANGING ls_bseg-lifnr.
1642   *  SELECT SINGLE * FROM zfi_vendor INTO ls_vendor
1643   *   WHERE ongc_vendor = ls_bseg-lifnr.
1644
1645   *  IF sy-subrc = 0.
1646   *    ls_gl-vendor_no = ls_vendor-ovl_vendor.
1647   *  ELSE.
1648     ls_gl-vendor_no = ls_bseg-lifnr.
1649   *  ENDIF.
1650   *  ls_gl-vendor_no = ls_bseg-lifnr.
1651     PERFORM convert_exit CHANGING ls_gl-vendor_no.
1652     ls_gl-alloc_nmbr = ls_bseg-zuonr.
1653   ***  ls_gl-tax_code =  ls_bseg-mwskz.                   "27.09.2016
1654   ***  ls_gl-taxjurcode = ls_bseg-txjcd.
1655   *ls_gl-EXT_OBJECT_ID =
1656   *ls_gl-BUS_SCENARIO =
1657     ls_gl-costobject = ls_bseg-kstrg.         ""
1658     ls_gl-costcenter =  ls_bseg-kostl.        ""
1659     PERFORM convert_exit CHANGING ls_gl-costcenter.
1660     ls_gl-acttype = ls_bseg-koart.        ""   Changed by Manisha Bh.Dt:16.05.2017  ls_bseg-lstar.
1661     ls_gl-profit_ctr = ls_bseg-prctr.         ""
1662     ls_gl-part_prctr = ls_bseg-pprct.
1663     ls_gl-network = ls_bseg-nplnr.
1664     CALL FUNCTION 'CONVERSION_EXIT_ABPSP_OUTPUT'
1665       EXPORTING
1666         input  = ls_bseg-projk
1667       IMPORTING
1668         output = ls_gl-wbs_element.
1669
1670     ls_gl-orderid = ls_bseg-aufnr.            ""
1671     PERFORM convert_exit CHANGING ls_gl-orderid.
1672   *ls_gl-ORDER_ITNO =
1673     ls_gl-routing_no =  ls_bseg-aufpl.
1674   *  ls_gl-activity = ls_bseg-vorgn.
1675   **ls_gl-COND_TYPE =
1676   **ls_gl-COND_COUNT =
1677   **ls_gl-COND_ST_NO =
1678     ls_gl-fund = ls_bseg-geber.
1679     ls_gl-funds_ctr =  ls_bseg-fistl.      ""
1680     ls_gl-cmmt_item = ls_bseg-fipos.
1681     ls_gl-co_busproc = ls_bseg-prznr.
1682     ls_gl-asset_no = ls_bseg-anln1.       ""
1683     PERFORM convert_exit CHANGING ls_gl-asset_no.
1684     PERFORM convert_exit CHANGING ls_bseg-anln2.     "Added by Manisha bh.Dt:16.05.2017
1685   *  ls_gl-doc_type = ls_bseg-gsber.                "Added by Manisha bh.Dt:16.05.2017
1686
1687     ls_gl-sub_number = ls_bseg-anln2.            ""
1688     PERFORM convert_exit CHANGING ls_gl-sub_number.
1689   *ls_gl-BILL_TYPE =
1690   *************************************************
1691     ls_gl-sales_ord = ls_bseg-vbel2.
1692     PERFORM convert_exit CHANGING  ls_gl-sales_ord.
1693     ls_gl-s_ord_item = ls_bseg-posn2.
1694     ls_gl-de_cre_ind = ls_bseg-tbtkz.
1695   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1696   * S/4: material field length 18->40; populate MATERIAL_LONG (40-char).
1697   *  ls_gl-material  =  ls_bseg-matnr.
1698     ls_gl-material_long = ls_bseg-matnr.
1699   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1700     PERFORM convert_exit CHANGING ls_gl-material.
1701     ls_gl-cmmt_item = ls_bseg-fipos.
1702     ls_gl-ppa_ex_ind  =  ls_bseg-ppa_ex_ind.
1703     ls_gl-fastpay  =  ls_bseg-fastpay.
1704   ***ls_gl-PARTNER_GRANT_NBR  =
1705     ls_gl-budget_period  = ls_bseg-budget_pd.
1706     ls_gl-partner_budget_period  =  ls_bseg-pbudget_pd.
1707     ls_gl-partner_fund  =  ls_bseg-pgeber.
1708   *  ls_gl-itemno_tax  =  ls_bseg-taxps.
1709
1710     IF  ls_bseg-vertn IS NOT INITIAL .
1711       ls_gl-costcenter = 'OVLJVCP001'.
1712     ENDIF.
1713   *************************************************
1714
1715     ls_curr-itemno_acc = ls_bseg-buzei.
1716     ls_curr-currency = ls_bkpf-waers.
1717     IF ls_bseg-shkzg = 'H'.
1718       ls_bseg-wrbtr = ls_bseg-wrbtr * -1.
1719     ENDIF.
1720   *  ls_curr-disc_base = ls_bseg-skfbt.
1721   *  ls_curr-disc_amt = ls_bseg-sknto.
1722   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1723   *  ls_curr-amt_doccur = ls_bseg-wrbtr.
1724     ls_curr-amt_doccur = CONV #( ls_bseg-wrbtr ).
1725   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1726   *  ls_curr-exch_rate_v = ls_bkpf-kurs2.
1727   *  IF  ls_curr-exch_rate_v LT 0.
1728   * ls_curr-exch_rate_v = ls_curr-exch_rate_v * -1.
1729   *  ENDIF.
1730     ls_curr-exch_rate = ls_bkpf-kursf.
1731     IF  ls_curr-exch_rate IS INITIAL .
1732       ls_curr-exch_rate = ls_bkpf-kurs2.
1733     ENDIF.
1734
1735     IF  ls_curr-exch_rate LT 0.
1736       ls_curr-exch_rate = ls_curr-exch_rate * -1.
1737     ENDIF.
1738
1739
1740     APPEND ls_curr TO lt_curr.
1741   ****************************************************
1742     ls_curr-curr_type = '10'.
1743     ls_curr-currency = ls_bkpf-hwaer.
1744     ls_curr-itemno_acc = ls_bseg-buzei.
1745     IF ls_bseg-shkzg = 'H'.
1746       ls_bseg-dmbtr = ls_bseg-dmbtr * -1.
1747     ENDIF.
1748   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1749   *  ls_curr-amt_doccur = ls_bseg-dmbtr.
1750     ls_curr-amt_doccur = CONV #( ls_bseg-dmbtr ).
1751   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1752     ls_curr-exch_rate = ls_bkpf-kursf.
1753     IF  ls_curr-exch_rate IS INITIAL .
1754       ls_curr-exch_rate = ls_bkpf-kurs2.
1755     ENDIF.
1756
1757     IF  ls_curr-exch_rate LT 0.
1758       ls_curr-exch_rate = ls_curr-exch_rate * -1.
1759     ENDIF.
1760
1761
1762     APPEND ls_curr TO lt_curr.
1763
1764     ls_curr-curr_type = '50'.
1765     ls_curr-currency = ls_bkpf-hwae2.
1766     ls_curr-itemno_acc = ls_bseg-buzei.
1767     IF ls_bseg-shkzg = 'H'.
1768       ls_bseg-dmbe2 = ls_bseg-dmbe2 * -1.
1769     ENDIF.
1770   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1771   *  ls_curr-amt_doccur = ls_bseg-dmbe2.
1772     ls_curr-amt_doccur = CONV #( ls_bseg-dmbe2 ).
1773   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1774     ls_curr-exch_rate = ls_bkpf-kursf.
1775     IF  ls_curr-exch_rate IS INITIAL .
1776       ls_curr-exch_rate = ls_bkpf-kurs2.
1777     ENDIF.
1778
1779     IF  ls_curr-exch_rate LT 0.
1780       ls_curr-exch_rate = ls_curr-exch_rate * -1.
1781     ENDIF.
1782
1783     APPEND ls_curr TO lt_curr.
1784
1785
1786   *-----------------
1787
1788   ENDFORM.
1789   *&---------------------------------------------------------------------*
1790   *&      Form  FM_UPDATE_ASSET
1791   *&---------------------------------------------------------------------*
1792   *       text
1793   *----------------------------------------------------------------------*
1794   *      -->P_LS_BSEG  text
1795   *      -->P_LS_BKPF  text
1796   *      <--P_LS_GL  text
1797   *      <--P_LS_CURR  text
1798   *      <--P_LT_CURR  text
1799   *----------------------------------------------------------------------*
1800   FORM fm_update_asset  USING  VALUE(ls_bseg) TYPE bseg
1801                               VALUE(ls_bkpf) TYPE bkpf
1802                      CHANGING ls_head  TYPE bapiache09
1803                               ls_gl    TYPE bapiacgl09
1804                               lt_gl    TYPE tt_gl
1805                               ls_curr  TYPE bapiaccr09
1806                               lt_curr  TYPE tt_curr.
1807
1808     ls_head-bus_act    = 'RFBU'.
1809     ls_head-username   = sy-uname.
1810     ls_head-comp_code  = ls_bkpf-bukrs.
1811
1812   *  CALL FUNCTION 'KCD_EXCEL_DATE_CONVERT'
1813   *    EXPORTING
1814   *      excel_date = ls_bkpf-bldat
1815   *    IMPORTING
1816   *      sap_date   = ls_head-doc_date.
1817   *
1818   *  CALL FUNCTION 'KCD_EXCEL_DATE_CONVERT'
1819   *    EXPORTING
1820   *      excel_date = ls_bkpf-budat
1821   *    IMPORTING
1822   *      sap_date   = ls_head-pstng_date.
1823     ls_head-doc_date   = ls_bkpf-bldat.
1824     ls_head-pstng_date = ls_bkpf-budat.
1825     ls_head-doc_type   = ls_bkpf-blart.
1826     ls_head-header_txt = ls_bkpf-bktxt.
1827     ls_head-fis_period = ls_bkpf-monat.
1828     ls_head-ref_doc_no = ls_bkpf-xblnr.
1829
1830
1831     IF ls_bseg-bschl = '50'
1832        OR ls_bseg-bschl = '75'.
1833
1834   *    counter_bapi = counter_bapi + 1.
1835       ls_gl-itemno_acc   = ls_bseg-buzei.
1836
1837       IF ls_bseg-bschl = '50'.
1838         CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
1839           EXPORTING
1840             input  = ls_bseg-hkont
1841           IMPORTING
1842             output = ls_gl-gl_account.
1843       ELSE.
1844         CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
1845           EXPORTING
1846             input  = ls_bseg-anln1
1847           IMPORTING
1848             output = ls_gl-asset_no.
1849       ENDIF.
1850
1851   *    IF wa_final-newko = '102000226' OR  wa_final-newko = '104002075'.
1852   *      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
1853   *        EXPORTING
1854   *          input  = '10429'
1855   *        IMPORTING
1856   *          output = ls_gl-gl_account.
1857   *    ENDIF.
1858   *    IF wa_final-newko = 'OVLPPEMYA1'.
1859   *      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
1860   *        EXPORTING
1861   *          input  = '70101'
1862   *        IMPORTING
1863   *          output = ls_gl-gl_account.
1864   *    ENDIF.
1865       ls_gl-costcenter   = ls_bseg-kostl.
1866       ls_gl-profit_ctr   = ls_bseg-prctr.
1867       ls_gl-item_text    = ls_bseg-sgtxt.
1868       ls_gl-cs_trans_t   = ls_bseg-bewar.
1869       ls_gl-bus_area     = ls_bseg-gsber.
1870       ls_gl-comp_code    = ls_bseg-bukrs.
1871   *    CALL FUNCTION 'KCD_EXCEL_DATE_CONVERT'
1872   *      EXPORTING
1873   *        excel_date = ls_bseg-valut
1874   *      IMPORTING
1875   *        sap_date   = ls_gl-value_date.
1876   *
1877   *    CALL FUNCTION 'KCD_EXCEL_DATE_CONVERT'
1878   *      EXPORTING
1879   *        excel_date = ls_bkpf-budat
1880   *      IMPORTING
1881   *        sap_date   = ls_gl-pstng_date.
1882
1883       ls_gl-value_date = ls_bseg-valut.
1884       ls_gl-pstng_date = ls_bkpf-budat.
1885       ls_gl-alloc_nmbr = ls_bseg-zuonr.
1886
1887       APPEND ls_gl TO lt_gl.
1888       CLEAR ls_gl.
1889     ENDIF.
1890
1891
1892     IF ls_bseg-bschl = '50'
1893        OR ls_bseg-bschl = '75'.
1894       ls_curr-itemno_acc  = ls_bseg-buzei.  "counter_bapi.
1895       ls_curr-curr_type = '00'.
1896   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1897   *    ls_curr-amt_doccur  = ls_bseg-wrbtr * -1.
1898       ls_curr-amt_doccur = CONV #( ls_bseg-wrbtr * -1 ).
1899   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1900       ls_curr-currency    = ls_bkpf-waers.
1901       APPEND ls_curr TO lt_curr.
1902       CLEAR : ls_curr.
1903
1904   *      counter_bapi = counter_bapi + 1.
1905       ls_curr-itemno_acc = ls_bseg-buzei.  " counter_bapi.
1906       ls_curr-curr_type = '10'.
1907   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1908   *    ls_curr-amt_doccur  = ls_bseg-dmbe2 * -1. """"On 02.02.2017 * -1.
1909       ls_curr-amt_doccur = CONV #( ls_bseg-dmbe2 * -1 ).""""On 02.02.2017 * -1.
1910   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1911       ls_curr-currency = 'INR'.
1912       APPEND ls_curr TO lt_curr.
1913       CLEAR : ls_curr.
1914     ENDIF.
1915
1916
1917     IF ls_bseg-bschl = '40'
1918        OR ls_bseg-bschl = '70'.
1919   *    counter_bapi = counter_bapi + 1.
1920       ls_gl-itemno_acc   = ls_bseg-buzei.   "counter_bapi.
1921
1922       IF ls_bseg-bschl = '40'.
1923         CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
1924           EXPORTING
1925             input  = ls_bseg-hkont
1926           IMPORTING
1927             output = ls_gl-gl_account.
1928       ELSE.
1929         CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
1930           EXPORTING
1931             input  = ls_bseg-anln1
1932           IMPORTING
1933             output = ls_gl-asset_no.
1934       ENDIF.
1935   *    IF wa_final-newko = '102000226' OR  wa_final-newko = '104002075'.
1936   *      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
1937   *        EXPORTING
1938   *          input  = '10429'
1939   *        IMPORTING
1940   *          output = ls_gl-gl_account.
1941   *    ENDIF.
1942   *    IF wa_final-newko = 'OVLPPEMYA1'.
1943   *      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
1944   *        EXPORTING
1945   *          input  = '70101'
1946   *        IMPORTING
1947   *          output = ls_gl-gl_account.
1948   *    ENDIF.
1949       CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
1950         EXPORTING
1951           input  = ls_bseg-hkont
1952         IMPORTING
1953           output = ls_gl-gl_account.
1954   *    ls_gl-gl_account   = ls_bseg-hkont. Dt:17.05.2017
1955       ls_gl-costcenter   = ls_bseg-kostl.
1956       ls_gl-profit_ctr   = ls_bseg-prctr.
1957       ls_gl-item_text    = ls_bseg-sgtxt.
1958       ls_gl-cs_trans_t   = ls_bseg-bewar.
1959       ls_gl-bus_area     = ls_bseg-gsber.
1960       ls_gl-comp_code    = ls_bseg-bukrs.
1961
1962   *    CALL FUNCTION 'KCD_EXCEL_DATE_CONVERT'
1963   *      EXPORTING
1964   *        excel_date = ls_bseg-valut
1965   *      IMPORTING
1966   *        sap_date   = ls_gl-value_date.
1967   *
1968   *    CALL FUNCTION 'KCD_EXCEL_DATE_CONVERT'
1969   *      EXPORTING
1970   *        excel_date = ls_bkpf-budat
1971   *      IMPORTING
1972   *        sap_date   = ls_gl-pstng_date.
1973
1974       ls_gl-alloc_nmbr = ls_bseg-zuonr.
1975       ls_gl-value_date = ls_bseg-valut.
1976       ls_gl-pstng_date = ls_bkpf-budat.
1977
1978       APPEND ls_gl TO lt_gl.
1979       CLEAR ls_gl.
1980     ENDIF.
1981
1982     IF ls_bseg-bschl = '40'
1983          OR ls_bseg-bschl = '70'.
1984       ls_curr-itemno_acc  = ls_bseg-buzei. "counter_bapi.
1985       ls_curr-curr_type   = '00'.
1986   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1987   *    ls_curr-amt_doccur  = ls_bseg-wrbtr. """"On 02.02.2017 * -1.
1988       ls_curr-amt_doccur = CONV #( ls_bseg-wrbtr ).""""On 02.02.2017 * -1.
1989   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1990       ls_curr-currency    = ls_bkpf-waers.
1991       APPEND ls_curr TO lt_curr.
1992       CLEAR : ls_curr.
1993
1994   *      counter_bapi = counter_bapi + 1.
1995       ls_curr-itemno_acc  = ls_bseg-buzei.  "counter_bapi.
1996       ls_curr-curr_type   = '10'.
1997   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1998   *    ls_curr-amt_doccur  = ls_bseg-dmbe2. """"On 02.02.2017 * -1.
1999       ls_curr-amt_doccur = CONV #( ls_bseg-dmbe2 ).""""On 02.02.2017 * -1.
2000   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
2001       ls_curr-currency    ='INR'.
2002       APPEND ls_curr TO lt_curr.
2003       CLEAR : ls_curr.
2004     ENDIF.
2005
2006   ENDFORM.
*--- End of ZFI_POST_ICE_TO_OVL_BAPI_F01 - 2006 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CABAP                                   Level 1    Page 5
Object           ZFI_POST_ICE_TO_OVL_BAPI                  Lines 360
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:22
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
Generated incl.  %_COLE2                                   Level 1    Page 6
Object           ZFI_POST_ICE_TO_OVL_BAPI                  Lines 43
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:22
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
Generated incl.  %_CSFES                                   Level 1    Page 7
Object           ZFI_POST_ICE_TO_OVL_BAPI                  Lines 75
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:22
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
Generated incl.  %_CSLIS                                   Level 1    Page 8
Object           ZFI_POST_ICE_TO_OVL_BAPI                  Lines 543
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:22
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
Generated incl.  <REPINI>                                  Level 1    Page 9
Object           ZFI_POST_ICE_TO_OVL_BAPI                  Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:22
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
Object           ZFI_POST_ICE_TO_OVL_BAPI                  Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:22
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
Object           ZFI_POST_ICE_TO_OVL_BAPI                  Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:22
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
Object           ZFI_POST_ICE_TO_OVL_BAPI                  Lines 1
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:22
----------------------------------------------------------------------------------------------------
1      * INCLUDE DB__SSEL
*--- End of DB__SSEL - 1 lines ---
