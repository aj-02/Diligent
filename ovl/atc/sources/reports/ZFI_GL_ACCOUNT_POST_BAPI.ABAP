----------------------------------------------------------------------------------------------------
Main program     ZFI_GL_ACCOUNT_POST_BAPI                  Level 0    Page 1
Object           ZFI_GL_ACCOUNT_POST_BAPI                  Lines 18
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:14
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *& Report  ZFI_GL_ACCOUNT_POST
3      *&---------------------------------------------------------------------*
4
5      REPORT zfi_gl_account_post_bapi.
6
7      INCLUDE ZFI_GL_ACCOUNT_POST_BAPI_DD.
8      INCLUDE ZFI_GL_ACCOUNT_POST_BAPI_SS.
9      INCLUDE ZFI_GL_ACCOUNT_POST_BAPI_SUB.
10
11
12     AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
13       PERFORM p_file.
14
15     START-OF-SELECTION.
16       PERFORM upload_data.
17       PERFORM process_data.
18       PERFORM process_alv.
*--- End of ZFI_GL_ACCOUNT_POST_BAPI - 18 lines ---

----------------------------------------------------------------------------------------------------
Include          ZFI_GL_ACCOUNT_POST_BAPI_DD               Level 1    Page 2
Object           ZFI_GL_ACCOUNT_POST_BAPI                  Lines 186
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:14
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&  Include           ZFI_GL_ACCOUNT_POST_DD
3      *&---------------------------------------------------------------------*
4      TYPE-POOLS: truxs.
5      TYPE-POOLS: slis.
6
7      *&---------------------------------------------------------------------*
8      *& ALV Data Declaration
9      *&---------------------------------------------------------------------*
10     DATA: it_fieldcat            TYPE slis_t_fieldcat_alv.
11     DATA: wa_fieldcat            LIKE LINE OF it_fieldcat.
12     DATA: t_list_top_of_page     TYPE slis_t_listheader.
13     DATA: it_events              TYPE slis_t_event WITH HEADER LINE.
14     DATA: g_save                 TYPE c VALUE 'A'.
15     DATA: gt_sort                TYPE slis_t_sortinfo_alv.
16     DATA: gx_save                TYPE c VALUE 'A'.
17     DATA: gx_variant             TYPE disvariant.
18     DATA: g_variant              TYPE disvariant.
19     DATA: gs_layout              TYPE slis_layout_alv.
20     DATA: t_formname_top_of_page TYPE slis_formname VALUE 'TOP_OF_PAGE'.
21     DATA: t_i_event              TYPE slis_alv_event.
22
23     TYPES : BEGIN OF ty_final,
24               bldat        TYPE  char10, "bldat,
25               blart        TYPE  blart,
26               bukrs        TYPE  bukrs,
27               budat        TYPE  char10, " budat,
28               monat        TYPE  monat,
29               waers        TYPE  waers,
30               xblnr        TYPE  xblnr1,
31               bktxt        TYPE  bktxt,
32               newbs        TYPE  newbs,
33               newko        TYPE  newko,
34               wrbtr        TYPE  char17, "wrbtr,
35               wrbtr1       TYPE  char17, "wrbtr,
36               zuonr        TYPE  dzuonr,
37               sgtxt        TYPE  sgtxt,
38               gsber        TYPE  gsber,
39               kostl        TYPE  kostl,
40               wbs          TYPE char24,
41               rmvct        TYPE rmvct, "Trn Type
42               value_date   TYPE char10,
43     *          assignment   TYPE string,
44     *          text         TYPE string,
45               pc           TYPE prctr,
46               recovery_ind TYPE char2,
47               sec_code     TYPE acpi_secco1,
48               assign       TYPE acpi_zuonr,
49               remark       TYPE string,
50             END OF ty_final.
51     *
52     *TYPES : BEGIN OF ty_display,
53     *          bldat        TYPE  char10, "bldat,
54     *          blart        TYPE  blart,
55     *          bukrs        TYPE  bukrs,
56     *          budat        TYPE  char10, " budat,
57     *          monat        TYPE  monat,
58     *          waers        TYPE  waers,
59     *          xblnr        TYPE  xblnr1,
60     *          bktxt        TYPE  bktxt,
61     *          newbs        TYPE  newbs,
62     *          newko        TYPE  newko,
63     *          wrbtr        TYPE  char17, "wrbtr,
64     *          wrbtr1       TYPE  char17, "wrbtr,
65     *          zuonr        TYPE  dzuonr,
66     *          sgtxt        TYPE  sgtxt,
67     *          gsber        TYPE  gsber,
68     *          kostl        TYPE  kostl,
69     *          wbs          TYPE char24,
70     *          rmvct        TYPE rmvct, "Trn Type
71     *          value_date   TYPE char10,
72     **          assignment   TYPE string,
73     **          text         TYPE string,
74     *          pc           TYPE prctr,
75     *          recovery_ind TYPE char2,
76     *          remark       TYPE string,
77     *        END OF ty_display.
78
79     ******Internal Table Declaration
80     DATA : it_final TYPE STANDARD TABLE OF ty_final.
81
82     ******Workarea Declaration
83     DATA : wa_final TYPE ty_final.
84
85     *******Internal Table Declaration
86     *DATA : it_display TYPE STANDARD TABLE OF ty_display.
87     *
88     *******Workarea Declaration
89     *DATA : wa_display TYPE ty_display.
90
91
92     ***********Types Declaration*********
93     TYPES : BEGIN OF ty_display,
94               type       TYPE bapi_mtype,
95               id         TYPE symsgid,
96               number     TYPE symsgno,
97               message    TYPE bapi_msg,
98               log_no     TYPE balognr,
99               log_msg_no TYPE balmnr,
100              message_v1 TYPE symsgv,
101              message_v2 TYPE symsgv,
102              message_v3 TYPE symsgv,
103              message_v4 TYPE symsgv,
104              parameter  TYPE bapi_param,
105              row        TYPE bapi_line,
106              field      TYPE bapi_fld,
107              system     TYPE bapilogsys,
108            END OF ty_display,
109
110            BEGIN OF ty_display1,
111              type       TYPE bapi_mtype,
112              id         TYPE symsgid,
113              number     TYPE symsgno,
114              message    TYPE bapi_msg,
115              log_no     TYPE balognr,
116              log_msg_no TYPE balmnr,
117              message_v1 TYPE symsgv,
118              message_v2 TYPE symsgv,
119              message_v3 TYPE symsgv,
120              message_v4 TYPE symsgv,
121              parameter  TYPE bapi_param,
122              row        TYPE bapi_line,
123              field      TYPE bapi_fld,
124              system     TYPE bapilogsys,
125              cell       TYPE slis_t_specialcol_alv,
126            END OF ty_display1.
127
128    *******Internal Table Declaration****
129    DATA : gt_display  TYPE STANDARD TABLE OF ty_display, "bapiret2,
130           gt_display1 TYPE STANDARD TABLE OF ty_display1. "bapiret2.
131
132    *******Workarea Declaration*******
133    DATA : gs_display  TYPE ty_display, "bapiret2,
134           gs_display1 TYPE ty_display1. " bapiret2.
135
136    DATA : fs_cell LIKE LINE OF gs_display1-cell .
137
138    DATA : it_type   TYPE truxs_t_text_data.
139    DATA: bdcdata LIKE bdcdata    OCCURS 0 WITH HEADER LINE.
140
141    DATA : t_msg      TYPE TABLE OF bdcmsgcoll,
142           w_msg      TYPE bdcmsgcoll,
143           w_msg1(51),
144           e_msg(50),
145           s_msg(50).
146
147    ********TYpes Declaration
148    TYPES : BEGIN OF ty_s_error,
149              msg_err(60) TYPE c,
150            END OF ty_s_error.
151
152    DATA:  wa_path    TYPE string,
153           wa_error   TYPE string,
154           wa_cnt     TYPE i,
155           w_mode     TYPE c,
156           wa_cnt1(2) TYPE n,
157           it_output  TYPE TABLE OF ty_s_error,
158           wa_output  LIKE LINE OF it_output.
159
160    DATA : lv_usd   TYPE dmbtr,
161           lv_inr   TYPE dmbtr,
162           lv_gsber TYPE gsber,
163           lv_pc    TYPE prctr,
164           lv_rmvct TYPE rmvct,
165           lv_ri    TYPE char2.
166
167
168    DATA :  documentheader       TYPE bapiache09." OCCURS 0 WITH HEADER  LINE.
169    DATA :  obj_type             TYPE bapiache09-obj_type.
170    DATA :  obj_key              TYPE bapiache09-obj_key.
171    DATA :  obj_sys              TYPE bapiache09-obj_sys.
172    DATA :  wa_accountgl         TYPE bapiacgl09.
173    DATA :  wa_accountreceivable TYPE bapiacar09.
174    DATA :  wa_accountpayable    TYPE bapiacap09.
175    DATA :  wa_currencyamount    TYPE bapiaccr09.
176    DATA :  return               TYPE bapiret2   OCCURS 0 WITH HEADER LINE.
177    DATA :  accountgl            TYPE bapiacgl09 OCCURS 0 WITH HEADER LINE.
178    DATA :  accountreceivable    TYPE bapiacar09 OCCURS 0 WITH HEADER LINE.
179    DATA :  accountpayable       TYPE bapiacap09 OCCURS 0 WITH HEADER LINE.
180    DATA :  currencyamount       TYPE bapiaccr09 OCCURS 0 WITH HEADER LINE.
181    DATA :  it_accountgl         TYPE STANDARD TABLE OF bapiacgl09.
182    DATA : counter_bapi TYPE posnr_acc.
183    DATA :  it_currencyamount    TYPE STANDARD TABLE OF bapiaccr09.
184
185
186    data : lv_tcode type sy-ucomm.
*--- End of ZFI_GL_ACCOUNT_POST_BAPI_DD - 186 lines ---

----------------------------------------------------------------------------------------------------
Include          ZFI_GL_ACCOUNT_POST_BAPI_SS               Level 1    Page 3
Object           ZFI_GL_ACCOUNT_POST_BAPI                  Lines 7
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:14
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&  Include           ZFI_GL_ACCOUNT_POST_SS
3      *&---------------------------------------------------------------------*
4      SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
5      PARAMETERS: p_file TYPE localfile OBLIGATORY.
6      *            p_mode TYPE c OBLIGATORY DEFAULT 'N'.
7      SELECTION-SCREEN END OF BLOCK b1.
*--- End of ZFI_GL_ACCOUNT_POST_BAPI_SS - 7 lines ---

----------------------------------------------------------------------------------------------------
Include          ZFI_GL_ACCOUNT_POST_BAPI_SUB              Level 1    Page 4
Object           ZFI_GL_ACCOUNT_POST_BAPI                  Lines 701
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:14
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&  Include           ZFI_GL_ACCOUNT_POST_SUB
3      *&---------------------------------------------------------------------*
4      FORM p_file .
5        CALL FUNCTION 'F4_FILENAME'
6      *  EXPORTING
7      *    PROGRAM_NAME        = SYST-CPROG
8      *    DYNPRO_NUMBER       = SYST-DYNNR
9      *    FIELD_NAME          = ' '
10         IMPORTING
11           file_name = p_file.
12     ENDFORM.
13     *&---------------------------------------------------------------------*
14     *&      Form  UPLOAD_DATA
15     *&---------------------------------------------------------------------*
16     FORM upload_data .
17       CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
18         EXPORTING
19     *     I_FIELD_SEPERATOR    = 'X'
20           i_line_header        = 'X'
21           i_tab_raw_data       = it_type
22           i_filename           = p_file
23         TABLES
24           i_tab_converted_data = it_final[]
25         EXCEPTIONS
26           conversion_failed    = 1
27           OTHERS               = 2.
28       IF sy-subrc <> 0.
29         MESSAGE ID sy-msgid
30                        TYPE sy-msgty
31                        NUMBER sy-msgno
32                        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
33       ENDIF.
34     ENDFORM.
35
36
37
38
39     *&---------------------------------------------------------------------*
40     *&      Form  ALV_FIELDCAT
41     *&---------------------------------------------------------------------*
42     *       text
43     *----------------------------------------------------------------------*
44     *  -->  p1        text
45     *  <--  p2        text
46     *----------------------------------------------------------------------*
47     FORM alv_fieldcat .
48       REFRESH it_fieldcat[].
49       CLEAR :  wa_fieldcat.
50
51       DATA: counter TYPE i.
52
53       counter = counter + 1.
54       wa_fieldcat-col_pos    = counter.
55       wa_fieldcat-fieldname  = 'TYPE'.
56       wa_fieldcat-tabname    = 'GT_DISPLAY1'.
57       wa_fieldcat-seltext_l  = 'Message Type'.
58       wa_fieldcat-no_zero    = 'X'.
59       APPEND wa_fieldcat TO it_fieldcat.
60       CLEAR wa_fieldcat.
61
62       counter = counter + 1.
63       wa_fieldcat-col_pos    = counter.
64       wa_fieldcat-fieldname  = 'ID'.
65       wa_fieldcat-tabname    = 'GT_DISPLAY1'.
66     *  wa_fieldcat-seltext_l  = 'Site/Function'.
67       wa_fieldcat-no_zero    = 'X'.
68       APPEND wa_fieldcat TO it_fieldcat.
69       CLEAR wa_fieldcat.
70
71     *  counter = counter + 1.
72     *  wa_fieldcat-col_pos    = counter.
73     *  wa_fieldcat-fieldname  = 'NUMBER'.
74     *  wa_fieldcat-tabname    = 'GT_DISPLAY1'.
75     *  wa_fieldcat-seltext_l  = 'Message Number'.
76     *  wa_fieldcat-no_zero    = 'X'.
77     *  APPEND wa_fieldcat TO it_fieldcat.
78     *  CLEAR wa_fieldcat.
79
80       counter = counter + 1.
81       wa_fieldcat-col_pos    = counter.
82       wa_fieldcat-fieldname  = 'LOG_NO'.
83       wa_fieldcat-tabname    = 'GT_DISPLAY1'.
84       wa_fieldcat-seltext_l  = 'Site/Function No'.
85       wa_fieldcat-no_zero    = 'X'.
86       APPEND wa_fieldcat TO it_fieldcat.
87       CLEAR wa_fieldcat.
88
89       counter = counter + 1.
90       wa_fieldcat-col_pos    = counter.
91       wa_fieldcat-fieldname  = 'MESSAGE'.
92       wa_fieldcat-tabname    = 'GT_DISPLAY1'.
93       wa_fieldcat-seltext_l  = 'Message Text'.
94       wa_fieldcat-no_zero    = 'X'.
95       APPEND wa_fieldcat TO it_fieldcat.
96       CLEAR wa_fieldcat.
97
98
99
100    *  counter = counter + 1.
101    *  wa_fieldcat-col_pos    = counter.
102    *  wa_fieldcat-fieldname  = 'LOG_MSG_NO'.
103    *  wa_fieldcat-tabname    = 'GT_DISPLAY1'.
104    *  wa_fieldcat-seltext_l  = 'Application log: Internal message serial number'.
105    *  wa_fieldcat-no_zero    = 'X'.
106    *  APPEND wa_fieldcat TO it_fieldcat.
107    *  CLEAR wa_fieldcat.
108    *
109    *  counter = counter + 1.
110    *  wa_fieldcat-col_pos    = counter.
111    *  wa_fieldcat-fieldname  = 'MESSAGE_V1'.
112    *  wa_fieldcat-tabname    = 'GT_DISPLAY1'.
113    *  wa_fieldcat-seltext_l  = 'Message Variable'.
114    *  wa_fieldcat-no_zero    = 'X'.
115    *  APPEND wa_fieldcat TO it_fieldcat.
116    *  CLEAR wa_fieldcat.
117    *
118    *  counter = counter + 1.
119    *  wa_fieldcat-col_pos    = counter.
120    *  wa_fieldcat-fieldname  = 'MESSAGE_V2'.
121    *  wa_fieldcat-tabname    = 'GT_DISPLAY1'.
122    *  wa_fieldcat-seltext_l  = 'Message Variable'.
123    *  wa_fieldcat-no_zero    = 'X'.
124    *  APPEND wa_fieldcat TO it_fieldcat.
125    *  CLEAR wa_fieldcat.
126    *
127    *  counter = counter + 1.
128    *  wa_fieldcat-col_pos    = counter.
129    *  wa_fieldcat-fieldname  = 'MESSAGE_V3'.
130    *  wa_fieldcat-tabname    = 'GT_DISPLAY1'.
131    *  wa_fieldcat-seltext_l  = 'Message Variable'.
132    *  wa_fieldcat-no_zero    = 'X'.
133    *  APPEND wa_fieldcat TO it_fieldcat.
134    *  CLEAR wa_fieldcat.
135    *
136    *  counter = counter + 1.
137    *  wa_fieldcat-col_pos    = counter.
138    *  wa_fieldcat-fieldname  = 'MESSAGE_V4'.
139    *  wa_fieldcat-tabname    = 'GT_DISPLAY1'.
140    *  wa_fieldcat-seltext_l  = 'Message Variable'.
141    *  wa_fieldcat-no_zero    = 'X'.
142    *  APPEND wa_fieldcat TO it_fieldcat.
143    *  CLEAR wa_fieldcat.
144
145    *  counter = counter + 1.
146    *  wa_fieldcat-col_pos    = counter.
147    *  wa_fieldcat-fieldname  = 'PARAMETER'.
148    *  wa_fieldcat-tabname    = 'GT_DISPLAY1'.
149    *  wa_fieldcat-seltext_l  = 'Parameter Name'.
150    *  wa_fieldcat-no_zero    = 'X'.
151    *  APPEND wa_fieldcat TO it_fieldcat.
152    *  CLEAR wa_fieldcat.
153    *
154    *  counter = counter + 1.
155    *  wa_fieldcat-col_pos    = counter.
156    *  wa_fieldcat-fieldname  = 'ROW'.
157    *  wa_fieldcat-tabname    = 'GT_DISPLAY1'.
158    *  wa_fieldcat-seltext_l  = 'Lines in parameter'.
159    *  wa_fieldcat-no_zero    = 'X'.
160    *  APPEND wa_fieldcat TO it_fieldcat.
161    *  CLEAR wa_fieldcat.
162    *
163    *  counter = counter + 1.
164    *  wa_fieldcat-col_pos    = counter.
165    *  wa_fieldcat-fieldname  = 'FIELD'.
166    *  wa_fieldcat-tabname    = 'GT_DISPLAY1'.
167    *  wa_fieldcat-seltext_l  = 'Field in parameter'.
168    *  wa_fieldcat-no_zero    = 'X'.
169    *  APPEND wa_fieldcat TO it_fieldcat.
170    *  CLEAR wa_fieldcat.
171
172    *  counter = counter + 1.
173    *  wa_fieldcat-col_pos    = counter.
174    *  wa_fieldcat-fieldname  = 'SYSTEM'.
175    *  wa_fieldcat-tabname    = 'GT_DISPLAY1'.
176    *  wa_fieldcat-seltext_l  = 'Logical system from which message originates'.
177    *  wa_fieldcat-no_zero    = 'X'.
178    *  APPEND wa_fieldcat TO it_fieldcat.
179    *  CLEAR wa_fieldcat.
180
181    ****  counter = counter + 1.
182    ****  wa_fieldcat-col_pos    = counter.
183    ****  wa_fieldcat-fieldname  = 'REMARK'.
184    ****  wa_fieldcat-tabname    = 'IT_DISPLAY'.
185    ****  wa_fieldcat-seltext_l  = 'Remark'.
186    ****  wa_fieldcat-no_zero    = 'X'.
187    ****  APPEND wa_fieldcat TO it_fieldcat.
188    ****  CLEAR wa_fieldcat.
189
190
191    ENDFORM.                    " ALV_FIELDCAT
192    *&---------------------------------------------------------------------*
193    *&      Form  GET_EVENT
194    *&---------------------------------------------------------------------*
195    *       text
196    *----------------------------------------------------------------------*
197    *  -->  p1        text
198    *  <--  p2        text
199    *----------------------------------------------------------------------*
200    FORM get_event .
201      CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
202        EXPORTING
203          i_list_type     = 0
204        IMPORTING
205          et_events       = it_events[]
206        EXCEPTIONS
207          list_type_wrong = 1
208          OTHERS          = 2.
209      IF sy-subrc <> 0.
210        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
211                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
212      ENDIF.
213
214      READ TABLE it_events WITH KEY name = slis_ev_top_of_page
215                                    INTO it_events.
216      IF sy-subrc = 0.
217        MOVE t_formname_top_of_page TO it_events-form.
218        APPEND it_events.
219      ENDIF.
220    ENDFORM.                    " GET_EVENT
221
222    *&---------------------------------------------------------------------*
223    *&      Form  top_of_page
224    *&---------------------------------------------------------------------*
225    FORM top_of_page.
226      CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
227        EXPORTING
228          it_list_commentary = t_list_top_of_page.
229    *      i_logo             = 'SQUIRREL'.
230    ENDFORM.                    "top_of_page
231    *&---------------------------------------------------------------------*
232    *&      Form  ALV_DISPLAY
233    *&---------------------------------------------------------------------*
234    FORM alv_display .
235      gs_layout-detail_popup         = 'X'.
236      gs_layout-detail_initial_lines = 'X'.
237      gs_layout-colwidth_optimize    = 'X'.
238      gs_layout-coltab_fieldname     = 'CELL'.
239
240      CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
241        EXPORTING
242          it_fieldcat        = it_fieldcat
243          it_events          = it_events[]
244          i_callback_program = sy-repid
245          is_layout          = gs_layout
246          it_sort            = gt_sort[]
247          i_save             = g_save
248          is_variant         = gx_variant
249    *     i_callback_pf_status_set = 'ZSTATUS'
250    *     i_callback_user_command  = 'USER_COMMAND'
251        TABLES
252          t_outtab           = gt_display1[].
253    ENDFORM.                    " ALV_DISPLAY
254    *&---------------------------------------------------------------------*
255    *&      Form  PROCESS_DATA
256    *&---------------------------------------------------------------------*
257    FORM process_data.
258
259      lv_tcode = sy-ucomm.
260
261      EXPORT it_final TO MEMORY ID 'IT_FINAL'.
262      EXPORT lv_tcode TO MEMORY ID 'LV_TCODE'.
263
264      LOOP AT it_final INTO wa_final.
265        documentheader-bus_act    = 'RFBU'.
266        documentheader-username   = sy-uname.
267        documentheader-comp_code  = wa_final-bukrs.
268
269        CALL FUNCTION 'KCD_EXCEL_DATE_CONVERT'
270          EXPORTING
271            excel_date = wa_final-bldat
272          IMPORTING
273            sap_date   = documentheader-doc_date.
274
275        CALL FUNCTION 'KCD_EXCEL_DATE_CONVERT'
276          EXPORTING
277            excel_date = wa_final-budat
278          IMPORTING
279            sap_date   = documentheader-pstng_date.
280
281        documentheader-doc_type   = wa_final-blart.
282        documentheader-header_txt    = wa_final-bktxt.
283        documentheader-fis_period = wa_final-monat.
284        documentheader-ref_doc_no = wa_final-xblnr.
285
286
287        IF wa_final-newbs = '50'
288           OR wa_final-newbs = '75'.
289
290          counter_bapi = counter_bapi + 1.
291          wa_accountgl-itemno_acc   = counter_bapi.
292
293          IF wa_final-newbs = '50'.
294            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
295              EXPORTING
296                input  = wa_final-newko
297              IMPORTING
298                output = wa_accountgl-gl_account.
299          ELSE.
300            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
301              EXPORTING
302                input  = wa_final-newko
303              IMPORTING
304                output = wa_accountgl-asset_no.
305          ENDIF.
306
307          IF wa_final-newko = '102000226' OR  wa_final-newko = '104002075'.
308            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
309              EXPORTING
310                input  = '10429'
311              IMPORTING
312                output = wa_accountgl-gl_account.
313          ENDIF.
314          IF wa_final-newko = 'OVLPPEMYA1'.
315            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
316              EXPORTING
317                input  = '70101'
318              IMPORTING
319                output = wa_accountgl-gl_account.
320          ENDIF.
321          wa_accountgl-costcenter   = wa_final-kostl.
322          wa_accountgl-profit_ctr   = wa_final-pc.
323          wa_accountgl-item_text    = wa_final-sgtxt.
324          wa_accountgl-cs_trans_t = wa_final-rmvct.
325          wa_accountgl-bus_area = wa_final-gsber.
326          wa_accountgl-comp_code = wa_final-bukrs.
327          CALL FUNCTION 'KCD_EXCEL_DATE_CONVERT'
328            EXPORTING
329              excel_date = wa_final-value_date
330            IMPORTING
331              sap_date   = wa_accountgl-value_date.
332
333          CALL FUNCTION 'KCD_EXCEL_DATE_CONVERT'
334            EXPORTING
335              excel_date = wa_final-budat
336            IMPORTING
337              sap_date   = wa_accountgl-pstng_date.
338
339          wa_accountgl-alloc_nmbr = wa_final-assign.
340
341          APPEND wa_accountgl TO it_accountgl.
342          CLEAR wa_accountgl.
343        ENDIF.
344
345
346        IF wa_final-newbs = '50'
347           OR wa_final-newbs = '75'.
348          wa_currencyamount-itemno_acc  = counter_bapi.
349          wa_currencyamount-curr_type = '00'.
350    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
351    *      wa_currencyamount-amt_doccur  = wa_final-wrbtr * -1.
352          wa_currencyamount-amt_doccur = CONV #( wa_final-wrbtr * -1 ).
353    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
354          wa_currencyamount-currency    = wa_final-waers.
355          APPEND wa_currencyamount TO it_currencyamount.
356          CLEAR : wa_currencyamount.
357
358    *      counter_bapi = counter_bapi + 1.
359          wa_currencyamount-itemno_acc  = counter_bapi.
360          wa_currencyamount-curr_type = '10'.
361    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
362    *      wa_currencyamount-amt_doccur  = wa_final-wrbtr1 * -1. """"On 02.02.2017 * -1.
363          wa_currencyamount-amt_doccur = CONV #( wa_final-wrbtr1 * -1 ).""""On 02.02.2017 * -1.
364    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
365          wa_currencyamount-currency = 'INR'.
366          APPEND wa_currencyamount TO it_currencyamount.
367          CLEAR : wa_currencyamount.
368        ENDIF.
369
370
371        IF wa_final-newbs = '40'
372           OR wa_final-newbs = '70'.
373          counter_bapi = counter_bapi + 1.
374          wa_accountgl-itemno_acc   = counter_bapi.
375
376          IF wa_final-newbs = '40'.
377            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
378              EXPORTING
379                input  = wa_final-newko
380              IMPORTING
381                output = wa_accountgl-gl_account.
382          ELSE.
383            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
384              EXPORTING
385                input  = wa_final-newko
386              IMPORTING
387                output = wa_accountgl-asset_no.
388          ENDIF.
389          IF wa_final-newko = '102000226' OR  wa_final-newko = '104002075'.
390            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
391              EXPORTING
392                input  = '10429'
393              IMPORTING
394                output = wa_accountgl-gl_account.
395          ENDIF.
396          IF wa_final-newko = 'OVLPPEMYA1'.
397            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
398              EXPORTING
399                input  = '70101'
400              IMPORTING
401                output = wa_accountgl-gl_account.
402          ENDIF.
403          wa_accountgl-costcenter   = wa_final-kostl.
404          wa_accountgl-profit_ctr   = wa_final-pc.
405          wa_accountgl-item_text    = wa_final-sgtxt.
406          wa_accountgl-cs_trans_t = wa_final-rmvct.
407          wa_accountgl-bus_area = wa_final-gsber.
408          wa_accountgl-comp_code = wa_final-bukrs.
409
410          CALL FUNCTION 'KCD_EXCEL_DATE_CONVERT'
411            EXPORTING
412              excel_date = wa_final-value_date
413            IMPORTING
414              sap_date   = wa_accountgl-value_date.
415
416          CALL FUNCTION 'KCD_EXCEL_DATE_CONVERT'
417            EXPORTING
418              excel_date = wa_final-budat
419            IMPORTING
420              sap_date   = wa_accountgl-pstng_date.
421          wa_accountgl-alloc_nmbr = wa_final-assign.
422
423          APPEND wa_accountgl TO it_accountgl.
424          CLEAR wa_accountgl.
425        ENDIF.
426
427        IF wa_final-newbs = '40'
428             OR wa_final-newbs = '70'.
429          wa_currencyamount-itemno_acc  = counter_bapi.
430          wa_currencyamount-curr_type = '00'.
431    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
432    *      wa_currencyamount-amt_doccur  = wa_final-wrbtr. """"On 02.02.2017 * -1.
433          wa_currencyamount-amt_doccur = CONV #( wa_final-wrbtr ).""""On 02.02.2017 * -1.
434    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
435          wa_currencyamount-currency    = wa_final-waers.
436          APPEND wa_currencyamount TO it_currencyamount.
437          CLEAR : wa_currencyamount.
438
439    *      counter_bapi = counter_bapi + 1.
440          wa_currencyamount-itemno_acc  = counter_bapi.
441          wa_currencyamount-curr_type = '10'.
442    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
443    *      wa_currencyamount-amt_doccur  = wa_final-wrbtr1. """"On 02.02.2017 * -1.
444          wa_currencyamount-amt_doccur = CONV #( wa_final-wrbtr1 ).""""On 02.02.2017 * -1.
445    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
446          wa_currencyamount-currency    ='INR'.
447          APPEND wa_currencyamount TO it_currencyamount.
448          CLEAR : wa_currencyamount.
449        ENDIF.
450
451    *******   CUSTOMER
452        IF wa_final-newbs = '11'."'31'.
453          counter_bapi = counter_bapi + 1.
454          accountreceivable-itemno_acc   = counter_bapi.
455          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
456            EXPORTING
457              input  = wa_final-newko
458            IMPORTING
459              output = accountreceivable-customer.
460          accountreceivable-profit_ctr   = wa_final-pc.
461          accountreceivable-item_text    = wa_final-sgtxt.
462          accountreceivable-bus_area = wa_final-gsber.
463          accountreceivable-sectioncode = wa_final-sec_code.
464          APPEND accountreceivable TO accountreceivable.
465          CLEAR accountreceivable.
466        ENDIF.
467
468
469        IF wa_final-newbs = '11'."'31'.
470          wa_currencyamount-itemno_acc  = counter_bapi.
471          wa_currencyamount-curr_type = '00'.
472    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
473    *      wa_currencyamount-amt_doccur  = wa_final-wrbtr * -1.      """"
474          wa_currencyamount-amt_doccur = CONV #( wa_final-wrbtr * -1 ).""""
475    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
476          wa_currencyamount-currency    = wa_final-waers.
477          APPEND wa_currencyamount TO it_currencyamount.
478          CLEAR : wa_currencyamount.
479
480          wa_currencyamount-itemno_acc  = counter_bapi.
481          wa_currencyamount-curr_type = '10'.
482    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
483    *      wa_currencyamount-amt_doccur  = wa_final-wrbtr1 * -1. """"On 02.02.2017 * -1.
484          wa_currencyamount-amt_doccur = CONV #( wa_final-wrbtr1 * -1 ).""""On 02.02.2017 * -1.
485    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
486          wa_currencyamount-currency    ='INR'.
487          APPEND wa_currencyamount TO it_currencyamount.
488          CLEAR : wa_currencyamount.
489        ENDIF.
490
491
492        IF  wa_final-newbs = '01'."'21'.
493          counter_bapi = counter_bapi + 1.
494          accountreceivable-itemno_acc   = counter_bapi.
495          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
496            EXPORTING
497              input  = wa_final-newko
498            IMPORTING
499              output = accountreceivable-customer.
500
501          accountreceivable-profit_ctr   = wa_final-pc.
502          accountreceivable-item_text    = wa_final-sgtxt.
503          accountreceivable-bus_area = wa_final-gsber.
504          accountreceivable-sectioncode = wa_final-sec_code.
505          APPEND accountreceivable TO accountreceivable.
506          CLEAR accountreceivable.
507        ENDIF.
508
509        IF wa_final-newbs = '01'."'21'.
510          wa_currencyamount-itemno_acc  = counter_bapi.
511          wa_currencyamount-curr_type  = '00'.
512    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
513    *      wa_currencyamount-amt_doccur  = wa_final-wrbtr. """" * -1.
514          wa_currencyamount-amt_doccur = CONV #( wa_final-wrbtr )."""" * -1.
515    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
516          wa_currencyamount-currency    = wa_final-waers.
517          APPEND wa_currencyamount TO it_currencyamount.
518          CLEAR : wa_currencyamount.
519
520          wa_currencyamount-itemno_acc  = counter_bapi.
521          wa_currencyamount-curr_type = '10'.
522    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
523    *      wa_currencyamount-amt_doccur  = wa_final-wrbtr1. """"On 02.02.2017 * -1.
524          wa_currencyamount-amt_doccur = CONV #( wa_final-wrbtr1 ).""""On 02.02.2017 * -1.
525    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
526          wa_currencyamount-currency    ='INR'.
527          APPEND wa_currencyamount TO it_currencyamount.
528          CLEAR : wa_currencyamount.
529        ENDIF.
530    *******    end CUSTOMER
531
532
533
534    *******   VENDOR
535        IF wa_final-newbs = '31'."'11'.
536          counter_bapi = counter_bapi + 1.
537          accountpayable-itemno_acc   = counter_bapi.
538          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
539            EXPORTING
540              input  = wa_final-newko
541            IMPORTING
542              output = accountpayable-vendor_no.
543
544          accountpayable-profit_ctr   = wa_final-pc.
545          accountpayable-item_text    = wa_final-sgtxt.
546          accountpayable-sectioncode = wa_final-sec_code.
547          accountpayable-bus_area = wa_final-gsber.
548          APPEND accountpayable TO accountpayable.
549          CLEAR accountpayable.
550        ENDIF.
551
552
553        IF wa_final-newbs = '31'."'11'.
554          wa_currencyamount-itemno_acc  = counter_bapi.
555          wa_currencyamount-curr_type = '00'.
556    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
557    *      wa_currencyamount-amt_doccur  = wa_final-wrbtr * -1.    """"
558          wa_currencyamount-amt_doccur = CONV #( wa_final-wrbtr * -1 ).""""
559    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
560          wa_currencyamount-currency    = wa_final-waers.
561          APPEND wa_currencyamount TO it_currencyamount.
562          CLEAR : wa_currencyamount.
563
564          wa_currencyamount-itemno_acc  = counter_bapi.
565          wa_currencyamount-curr_type = '10'.
566    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
567    *      wa_currencyamount-amt_doccur  = wa_final-wrbtr1 * -1. """"On 02.02.2017 * -1.
568          wa_currencyamount-amt_doccur = CONV #( wa_final-wrbtr1 * -1 ).""""On 02.02.2017 * -1.
569    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
570          wa_currencyamount-currency    ='INR'.
571          APPEND wa_currencyamount TO it_currencyamount.
572          CLEAR : wa_currencyamount.
573        ENDIF.
574
575
576        IF  wa_final-newbs = '21'."'01'.
577          counter_bapi = counter_bapi + 1.
578          accountpayable-itemno_acc   = counter_bapi.
579          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
580            EXPORTING
581              input  = wa_final-newko
582            IMPORTING
583              output = accountpayable-vendor_no.
584
585          accountpayable-profit_ctr   = wa_final-pc.
586          accountpayable-item_text    = wa_final-sgtxt.
587          accountpayable-bus_area = wa_final-gsber.
588          accountpayable-sectioncode = wa_final-sec_code.
589          APPEND accountpayable TO accountpayable.
590          CLEAR accountpayable.
591        ENDIF.
592
593        IF wa_final-newbs = '21'."'01'.
594          wa_currencyamount-itemno_acc  = counter_bapi.
595          wa_currencyamount-curr_type = '00'.
596    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
597    *      wa_currencyamount-amt_doccur  = wa_final-wrbtr. """" * -1.
598          wa_currencyamount-amt_doccur = CONV #( wa_final-wrbtr )."""" * -1.
599    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
600          wa_currencyamount-currency    = wa_final-waers.
601          APPEND wa_currencyamount TO it_currencyamount.
602          CLEAR : wa_currencyamount.
603
604          wa_currencyamount-itemno_acc  = counter_bapi.
605          wa_currencyamount-curr_type = '10'.
606    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
607    *      wa_currencyamount-amt_doccur  = wa_final-wrbtr1. """"On 02.02.2017 * -1.
608          wa_currencyamount-amt_doccur = CONV #( wa_final-wrbtr1 ).""""On 02.02.2017 * -1.
609    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
610          wa_currencyamount-currency    ='INR'.
611          APPEND wa_currencyamount TO it_currencyamount.
612          CLEAR : wa_currencyamount.
613        ENDIF.
614    *******    end VENDOR
615
616      ENDLOOP.
617
618
619    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
620      CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'  "#EC CI_USAGE_OK
621          "#EC CI_USAGE_OK[2628704]
622      "#EC CI_USAGE_OK[2438131]
623
624    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
625        EXPORTING
626          "Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
627          documentheader    = documentheader
628          "Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
629        IMPORTING
630          obj_type          = obj_type
631          obj_key           = obj_key
632          obj_sys           = obj_sys
633        TABLES
634          accountgl         = it_accountgl[]
635          currencyamount    = it_currencyamount[]
636          accountreceivable = accountreceivable[]
637          accountpayable    = accountpayable[]
638          return            = return[].
639
640      READ TABLE return WITH KEY type = 'E'.
641      IF sy-subrc = 0.
642        LOOP AT return WHERE type = 'E'.
643          MOVE-CORRESPONDING return TO gs_display.
644          APPEND gs_display TO gt_display.
645        ENDLOOP.
646      ELSE.
647        LOOP AT return.
648          MOVE-CORRESPONDING return TO gs_display.
649          APPEND gs_display TO gt_display.
650        ENDLOOP.
651        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
652
653      ENDIF.
654
655      REFRESH: return,
656             accountgl,
657             currencyamount,
658             accountreceivable,
659             accountpayable.
660    *         documentheader.
661
662      CLEAR:   return,
663               accountgl,
664               currencyamount,
665               accountreceivable,
666               accountpayable,
667               documentheader,
668               obj_type,
669               obj_sys,
670               counter_bapi,
671               obj_key,
672               it_accountgl,
673               it_currencyamount,
674               it_accountgl[],
675               it_currencyamount[].
676    ENDFORM.
677    *&---------------------------------------------------------------------*
678    *&      Form  PROCESS_ALV
679    *&---------------------------------------------------------------------*
680    FORM process_alv .
681      LOOP AT gt_display INTO gs_display.
682        MOVE-CORRESPONDING gs_display TO gs_display1.
683        IF gs_display1-type = 'S'.
684          fs_cell-fieldname = 'TYPE'.
685          fs_cell-color-col = 5.
686          APPEND fs_cell TO gs_display1-cell.
687        ENDIF.
688        IF gs_display1-type = 'E'.
689          fs_cell-fieldname = 'TYPE'.
690          fs_cell-color-col = 6.
691          APPEND fs_cell TO gs_display1-cell.
692        ENDIF.
693        APPEND gs_display1 TO gt_display1.
694        CLEAR : gs_display1.
695      ENDLOOP.
696
697      IF gt_display1[] IS NOT INITIAL.
698        PERFORM alv_fieldcat.
699        PERFORM alv_display.
700      ENDIF.
701    ENDFORM.
*--- End of ZFI_GL_ACCOUNT_POST_BAPI_SUB - 701 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CSLIS                                   Level 1    Page 5
Object           ZFI_GL_ACCOUNT_POST_BAPI                  Lines 543
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:14
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
Generated incl.  %_CTRUXS                                  Level 1    Page 6
Object           ZFI_GL_ACCOUNT_POST_BAPI                  Lines 166
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:14
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
Generated incl.  <REPINI>                                  Level 1    Page 7
Object           ZFI_GL_ACCOUNT_POST_BAPI                  Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:14
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
Object           ZFI_GL_ACCOUNT_POST_BAPI                  Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:14
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
Object           ZFI_GL_ACCOUNT_POST_BAPI                  Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:14
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
Object           ZFI_GL_ACCOUNT_POST_BAPI                  Lines 1
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:14
----------------------------------------------------------------------------------------------------
1      * INCLUDE DB__SSEL
*--- End of DB__SSEL - 1 lines ---
