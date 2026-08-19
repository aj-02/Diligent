----------------------------------------------------------------------------------------------------
Main program     ZFI_GL_ACCOUNT_COL_POST                   Level 0    Page 1
Object           ZFI_GL_ACCOUNT_COL_POST                   Lines 19
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:12
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *& Report  ZFI_GL_ACCOUNT_POST
3      *&---------------------------------------------------------------------*
4
5      REPORT zfi_gl_account_col_post.
6
7      INCLUDE ZFI_GL_ACCOUNT_POST_COL_DD.
8      INCLUDE ZFI_GL_ACCOUNT_POST_COL_SS.
9      INCLUDE ZFI_GL_ACCOUNT_POST_COL_SUB.
10
11
12     AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
13       PERFORM p_file.
14
15     START-OF-SELECTION.
16       PERFORM upload_data.
17       PERFORM modify_ist_gl.
18       PERFORM process_data.
19       PERFORM process_alv.
*--- End of ZFI_GL_ACCOUNT_COL_POST - 19 lines ---

----------------------------------------------------------------------------------------------------
Include          ZFI_GL_ACCOUNT_POST_COL_DD                Level 1    Page 2
Object           ZFI_GL_ACCOUNT_COL_POST                   Lines 264
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:12
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
24               drcr_ind(1),
25               somefield(3),
26               docdt(10),
27               postdt(10),
28               astval_dt(10),
29               txn_type(3),
30               compcd(3),
31               curr(5),
32               refdoc(18),
33               bline_dt(10),
34               paymethod(1),
35               htext(25),
36               postkey(2) ,
37               accntno(10),
38               amtnon(15),
39               amtinr(15),
40               amtidxcurr(15),
41               orderno(12),
42               efund(3),
43               busarea(4)," like bseg-gsber,
44               busi_sec(4),
45               costcntr(10),
46               wbs(24), "  LIKE jvto1-rprojk,
47               profcntr(10),
48               recind(2), " LIKE jvto1-rrecin,
49               allocation(18),
50               itemtext(50),
51               lineno(5),
52               remark         TYPE string,
53             END OF ty_final.
54     *
55
56     TYPES : BEGIN OF ty_final1,
57               drcr_ind(1),
58               somefield(3),
59               docdt(10),
60               doctyp(2), " Bipin Shukla
61               postdt(10),
62               astval_dt(10),
63               txn_type(3),
64               compcd(3),
65               curr(5),
66               refdoc(18),
67               bline_dt(10),
68               paymethod(1),
69               htext(25),
70               postkey(2) ,
71               accntno(10),
72               amtnon(15),
73               amtinr(15),
74               amtidxcurr(15),
75               orderno(12),
76               efund(3),
77               busarea(4)," like bseg-gsber,
78               busi_sec(4),
79               costcntr(10),
80               wbs(24), "  LIKE jvto1-rprojk,
81               profcntr(10),
82               recind(2), " LIKE jvto1-rrecin,
83               allocation(18),
84               itemtext(50),
85               lineno(5),
86               remark         TYPE string,
87             END OF ty_final1.
88     *TYPES : BEGIN OF ty_display,
89     *          bldat        TYPE  char10, "bldat,
90     *          blart        TYPE  blart,
91     *          bukrs        TYPE  bukrs,
92     *          budat        TYPE  char10, " budat,
93     *          monat        TYPE  monat,
94     *          waers        TYPE  waers,
95     *          xblnr        TYPE  xblnr1,
96     *          bktxt        TYPE  bktxt,
97     *          newbs        TYPE  newbs,
98     *          newko        TYPE  newko,
99     *          wrbtr        TYPE  char17, "wrbtr,
100    *          wrbtr1       TYPE  char17, "wrbtr,
101    *          zuonr        TYPE  dzuonr,
102    *          sgtxt        TYPE  sgtxt,
103    *          gsber        TYPE  gsber,
104    *          kostl        TYPE  kostl,
105    *          wbs          TYPE char24,
106    *          rmvct        TYPE rmvct, "Trn Type
107    *          value_date   TYPE char10,
108    **          assignment   TYPE string,
109    **          text         TYPE string,
110    *          pc           TYPE prctr,
111    *          recovery_ind TYPE char2,
112    *          remark       TYPE string,
113    *        END OF ty_display.
114
115    ******Internal Table Declaration
116    DATA : it_final TYPE STANDARD TABLE OF ty_final.
117
118    ******Workarea Declaration
119    DATA : wa_final TYPE ty_final.
120
121
122    ******Internal Table Declaration
123    DATA : it_final1 TYPE STANDARD TABLE OF ty_final1.
124
125    ******Workarea Declaration
126    DATA : wa_final1 TYPE ty_final1.
127    *******Internal Table Declaration
128    *DATA : it_display TYPE STANDARD TABLE OF ty_display.
129    *
130    *******Workarea Declaration
131    *DATA : wa_display TYPE ty_display.
132
133
134    ***********Types Declaration*********
135    TYPES : BEGIN OF ty_display,
136              type       TYPE bapi_mtype,
137              id         TYPE symsgid,
138              number     TYPE symsgno,
139              message    TYPE bapi_msg,
140              FIPOS      TYPE SKB1-FIPOS,
141              FISTL      type fistl,
142              log_no     TYPE balognr,
143              log_msg_no TYPE balmnr,
144              message_v1 TYPE symsgv,
145              message_v2 TYPE symsgv,
146              message_v3 TYPE symsgv,
147              message_v4 TYPE symsgv,
148              parameter  TYPE bapi_param,
149              row        TYPE bapi_line,
150              field      TYPE bapi_fld,
151              system     TYPE bapilogsys,
152            END OF ty_display,
153
154            BEGIN OF ty_display1,
155              type       TYPE bapi_mtype,
156              id         TYPE symsgid,
157              number     TYPE symsgno,
158              message    TYPE bapi_msg,
159              FIPOS      TYPE SKB1-FIPOS,
160              FISTL      type fistl,
161              log_no     TYPE balognr,
162              log_msg_no TYPE balmnr,
163              message_v1 TYPE symsgv,
164              message_v2 TYPE symsgv,
165              message_v3 TYPE symsgv,
166              message_v4 TYPE symsgv,
167              parameter  TYPE bapi_param,
168              row        TYPE bapi_line,
169              field      TYPE bapi_fld,
170              system     TYPE bapilogsys,
171              cell       TYPE slis_t_specialcol_alv,
172            END OF ty_display1.
173
174    *******Internal Table Declaration****
175    DATA : gt_display  TYPE STANDARD TABLE OF ty_display, "bapiret2,
176           gt_display1 TYPE STANDARD TABLE OF ty_display1. "bapiret2.
177
178    *******Workarea Declaration*******
179    DATA : gs_display  TYPE ty_display, "bapiret2,
180           gs_display1 TYPE ty_display1. " bapiret2.
181
182    DATA : fs_cell LIKE LINE OF gs_display1-cell .
183
184    DATA : it_type   TYPE truxs_t_text_data.
185    DATA: bdcdata LIKE bdcdata    OCCURS 0 WITH HEADER LINE.
186
187    DATA : t_msg      TYPE TABLE OF bdcmsgcoll,
188           w_msg      TYPE bdcmsgcoll,
189           w_msg1(51),
190           e_msg(50),
191           s_msg(50).
192
193    ********TYpes Declaration
194    TYPES : BEGIN OF ty_s_error,
195              msg_err(60) TYPE c,
196            END OF ty_s_error.
197
198    DATA:  wa_path    TYPE string,
199           wa_error   TYPE string,
200           wa_cnt     TYPE i,
201           w_mode     TYPE c,
202           wa_cnt1(2) TYPE n,
203           it_output  TYPE TABLE OF ty_s_error,
204           wa_output  LIKE LINE OF it_output.
205
206    DATA : lv_usd   TYPE dmbtr,
207           lv_inr   TYPE dmbtr,
208           lv_gsber TYPE gsber,
209           lv_pc    TYPE prctr,
210           lv_rmvct TYPE rmvct,
211           lv_ri    TYPE char2.
212
213
214    DATA :  documentheader       TYPE bapiache09." OCCURS 0 WITH HEADER  LINE.
215    DATA :  obj_type             TYPE bapiache09-obj_type.
216    DATA :  obj_key              TYPE bapiache09-obj_key.
217    DATA :  obj_sys              TYPE bapiache09-obj_sys.
218    DATA :  wa_accountgl         TYPE bapiacgl09.
219    DATA :  wa_accountreceivable TYPE bapiacar09.
220    DATA :  wa_accountpayable    TYPE bapiacap09.
221    DATA :  wa_currencyamount    TYPE bapiaccr09.
222    DATA :  return               TYPE bapiret2   OCCURS 0 WITH HEADER LINE.
223    DATA :  accountgl            TYPE bapiacgl09 OCCURS 0 WITH HEADER LINE.
224    DATA :  accountreceivable    TYPE bapiacar09 OCCURS 0 WITH HEADER LINE.
225    DATA :  accountpayable       TYPE bapiacap09 OCCURS 0 WITH HEADER LINE.
226    DATA :  currencyamount       TYPE bapiaccr09 OCCURS 0 WITH HEADER LINE.
227    DATA :  it_accountgl         TYPE STANDARD TABLE OF bapiacgl09.
228    DATA : counter_bapi TYPE posnr_acc.
229    DATA :  it_currencyamount TYPE STANDARD TABLE OF bapiaccr09,
230            lt_extension      TYPE bapiparex_tab_ac,
231            ls_extension      TYPE bapiparex.
232
233
234    DATA : lv_tcode TYPE sy-ucomm.
235
236    *DATA:  bdcdata LIKE bdcdata   OCCURS 0 WITH HEADER LINE.
237    DATA : g_upload.
238    DATA : nodata.
239    *DATA : g_save.
240    DATA   g_nextline.
241    DATA   g_group(12).
242    DATA   l_bschl LIKE tbsl-bschl.
243    DATA   l_postkey(2) TYPE n.
244    g_group = 'OVL_GL_UPLD'.
245
246
247    *DATA : ist_gl1 LIKE ist_gl OCCURS 0 WITH HEADER LINE.
248    DATA : lt_setvlue    TYPE TABLE OF rgsb4,
249           lt_setvlue_er TYPE TABLE OF rgsb4,
250           ls_setvlue_er TYPE         rgsb4,
251           ls_setvlue    TYPE          rgsb4,
252           gt_t001       TYPE TABLE OF t001,
253           gs_t001       TYPE          t001,
254           gs_tcurr      TYPE          tcurr,
255           ls_date       TYPE datum,
256           ls_date1       TYPE datum,
257           lv_date    TYPE gdatu_inv,
258           datum      TYPE char10,
259           datum1      TYPE char10.
260
261    data :  lt_tbsl      TYPE STANDARD TABLE OF tbsl,
262          ls_tbsl      TYPE tbsl,
263           lt_t003      TYPE STANDARD TABLE OF t003,
264          ls_t003      TYPE t003.
*--- End of ZFI_GL_ACCOUNT_POST_COL_DD - 264 lines ---

----------------------------------------------------------------------------------------------------
Include          ZFI_GL_ACCOUNT_POST_COL_SS                Level 1    Page 3
Object           ZFI_GL_ACCOUNT_COL_POST                   Lines 7
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:12
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&  Include           ZFI_GL_ACCOUNT_POST_SS
3      *&---------------------------------------------------------------------*
4      SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
5      PARAMETERS: p_file TYPE localfile OBLIGATORY.
6      *            p_mode TYPE c OBLIGATORY DEFAULT 'N'.
7      SELECTION-SCREEN END OF BLOCK b1.
*--- End of ZFI_GL_ACCOUNT_POST_COL_SS - 7 lines ---

----------------------------------------------------------------------------------------------------
Include          ZFI_GL_ACCOUNT_POST_COL_SUB               Level 1    Page 4
Object           ZFI_GL_ACCOUNT_COL_POST                   Lines 1031
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:12
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
34
35
36       LOOP AT it_final INTO wa_final.
37     * Change Posting key 1 => '01'
38         l_postkey = wa_final-postkey.
39         wa_final-postkey = l_postkey.
40
41         wa_final-lineno = sy-tabix.
42         MODIFY it_final FROM wa_final INDEX sy-tabix.
43       ENDLOOP.
44
45     ENDFORM.
46
47
48
49
50     *&---------------------------------------------------------------------*
51     *&      Form  ALV_FIELDCAT
52     *&---------------------------------------------------------------------*
53     *       text
54     *----------------------------------------------------------------------*
55     *  -->  p1        text
56     *  <--  p2        text
57     *----------------------------------------------------------------------*
58     FORM alv_fieldcat .
59       REFRESH it_fieldcat[].
60       CLEAR :  wa_fieldcat.
61
62       DATA: counter TYPE i.
63
64       counter = counter + 1.
65       wa_fieldcat-col_pos    = counter.
66       wa_fieldcat-fieldname  = 'TYPE'.
67       wa_fieldcat-tabname    = 'GT_DISPLAY1'.
68       wa_fieldcat-seltext_l  = 'Message Type'.
69       wa_fieldcat-no_zero    = 'X'.
70       APPEND wa_fieldcat TO it_fieldcat.
71       CLEAR wa_fieldcat.
72
73       counter = counter + 1.
74       wa_fieldcat-col_pos    = counter.
75       wa_fieldcat-fieldname  = 'ID'.
76       wa_fieldcat-tabname    = 'GT_DISPLAY1'.
77     *  wa_fieldcat-seltext_l  = 'Site/Function'.
78       wa_fieldcat-no_zero    = 'X'.
79       APPEND wa_fieldcat TO it_fieldcat.
80       CLEAR wa_fieldcat.
81
82     *  counter = counter + 1.
83     *  wa_fieldcat-col_pos    = counter.
84     *  wa_fieldcat-fieldname  = 'NUMBER'.
85     *  wa_fieldcat-tabname    = 'GT_DISPLAY1'.
86     *  wa_fieldcat-seltext_l  = 'Message Number'.
87     *  wa_fieldcat-no_zero    = 'X'.
88     *  APPEND wa_fieldcat TO it_fieldcat.
89     *  CLEAR wa_fieldcat.
90
91       counter = counter + 1.
92       wa_fieldcat-col_pos    = counter.
93       wa_fieldcat-fieldname  = 'LOG_NO'.
94       wa_fieldcat-tabname    = 'GT_DISPLAY1'.
95       wa_fieldcat-seltext_l  = 'Site/Function No'.
96       wa_fieldcat-no_zero    = 'X'.
97       APPEND wa_fieldcat TO it_fieldcat.
98       CLEAR wa_fieldcat.
99
100      counter = counter + 1.
101      wa_fieldcat-col_pos    = counter.
102      wa_fieldcat-fieldname  = 'MESSAGE'.
103      wa_fieldcat-tabname    = 'GT_DISPLAY1'.
104      wa_fieldcat-seltext_l  = 'Message Text'.
105      wa_fieldcat-no_zero    = 'X'.
106      APPEND wa_fieldcat TO it_fieldcat.
107      CLEAR wa_fieldcat.
108
109
110
111    *  counter = counter + 1.
112    *  wa_fieldcat-col_pos    = counter.
113    *  wa_fieldcat-fieldname  = 'LOG_MSG_NO'.
114    *  wa_fieldcat-tabname    = 'GT_DISPLAY1'.
115    *  wa_fieldcat-seltext_l  = 'Application log: Internal message serial number'.
116    *  wa_fieldcat-no_zero    = 'X'.
117    *  APPEND wa_fieldcat TO it_fieldcat.
118    *  CLEAR wa_fieldcat.
119    *
120      counter = counter + 1.
121      wa_fieldcat-col_pos    = counter.
122      wa_fieldcat-fieldname  = 'MESSAGE_V1'.
123      wa_fieldcat-tabname    = 'GT_DISPLAY1'.
124      wa_fieldcat-seltext_l  = 'Message Variable'.
125      wa_fieldcat-no_zero    = 'X'.
126      APPEND wa_fieldcat TO it_fieldcat.
127      CLEAR wa_fieldcat.
128
129      counter = counter + 1.
130      wa_fieldcat-col_pos    = counter.
131      wa_fieldcat-fieldname  = 'MESSAGE_V2'.
132      wa_fieldcat-tabname    = 'GT_DISPLAY1'.
133      wa_fieldcat-seltext_l  = 'Message Variable'.
134      wa_fieldcat-no_zero    = 'X'.
135      APPEND wa_fieldcat TO it_fieldcat.
136      CLEAR wa_fieldcat.
137    *
138      counter = counter + 1.
139      wa_fieldcat-col_pos    = counter.
140      wa_fieldcat-fieldname  = 'MESSAGE_V3'.
141      wa_fieldcat-tabname    = 'GT_DISPLAY1'.
142      wa_fieldcat-seltext_l  = 'Message Variable'.
143      wa_fieldcat-no_zero    = 'X'.
144      APPEND wa_fieldcat TO it_fieldcat.
145      CLEAR wa_fieldcat.
146    *
147    *  counter = counter + 1.
148    *  wa_fieldcat-col_pos    = counter.
149    *  wa_fieldcat-fieldname  = 'MESSAGE_V4'.
150    *  wa_fieldcat-tabname    = 'GT_DISPLAY1'.
151    *  wa_fieldcat-seltext_l  = 'Message Variable'.
152    *  wa_fieldcat-no_zero    = 'X'.
153    *  APPEND wa_fieldcat TO it_fieldcat.
154    *  CLEAR wa_fieldcat.
155
156    *  counter = counter + 1.
157    *  wa_fieldcat-col_pos    = counter.
158    *  wa_fieldcat-fieldname  = 'PARAMETER'.
159    *  wa_fieldcat-tabname    = 'GT_DISPLAY1'.
160    *  wa_fieldcat-seltext_l  = 'Parameter Name'.
161    *  wa_fieldcat-no_zero    = 'X'.
162    *  APPEND wa_fieldcat TO it_fieldcat.
163    *  CLEAR wa_fieldcat.
164    *
165    *  counter = counter + 1.
166    *  wa_fieldcat-col_pos    = counter.
167    *  wa_fieldcat-fieldname  = 'ROW'.
168    *  wa_fieldcat-tabname    = 'GT_DISPLAY1'.
169    *  wa_fieldcat-seltext_l  = 'Lines in parameter'.
170    *  wa_fieldcat-no_zero    = 'X'.
171    *  APPEND wa_fieldcat TO it_fieldcat.
172    *  CLEAR wa_fieldcat.
173    *
174    *  counter = counter + 1.
175    *  wa_fieldcat-col_pos    = counter.
176    *  wa_fieldcat-fieldname  = 'FIELD'.
177    *  wa_fieldcat-tabname    = 'GT_DISPLAY1'.
178    *  wa_fieldcat-seltext_l  = 'Field in parameter'.
179    *  wa_fieldcat-no_zero    = 'X'.
180    *  APPEND wa_fieldcat TO it_fieldcat.
181    *  CLEAR wa_fieldcat.
182
183    *  counter = counter + 1.
184    *  wa_fieldcat-col_pos    = counter.
185    *  wa_fieldcat-fieldname  = 'SYSTEM'.
186    *  wa_fieldcat-tabname    = 'GT_DISPLAY1'.
187    *  wa_fieldcat-seltext_l  = 'Logical system from which message originates'.
188    *  wa_fieldcat-no_zero    = 'X'.
189    *  APPEND wa_fieldcat TO it_fieldcat.
190    *  CLEAR wa_fieldcat.
191
192    ****  counter = counter + 1.
193    ****  wa_fieldcat-col_pos    = counter.
194    ****  wa_fieldcat-fieldname  = 'REMARK'.
195    ****  wa_fieldcat-tabname    = 'IT_DISPLAY'.
196    ****  wa_fieldcat-seltext_l  = 'Remark'.
197    ****  wa_fieldcat-no_zero    = 'X'.
198    ****  APPEND wa_fieldcat TO it_fieldcat.
199    ****  CLEAR wa_fieldcat.
200
201
202    ENDFORM.                    " ALV_FIELDCAT
203    *&---------------------------------------------------------------------*
204    *&      Form  GET_EVENT
205    *&---------------------------------------------------------------------*
206    *       text
207    *----------------------------------------------------------------------*
208    *  -->  p1        text
209    *  <--  p2        text
210    *----------------------------------------------------------------------*
211    FORM get_event .
212      CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
213        EXPORTING
214          i_list_type     = 0
215        IMPORTING
216          et_events       = it_events[]
217        EXCEPTIONS
218          list_type_wrong = 1
219          OTHERS          = 2.
220      IF sy-subrc <> 0.
221        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
222                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
223      ENDIF.
224
225      READ TABLE it_events WITH KEY name = slis_ev_top_of_page
226                                    INTO it_events.
227      IF sy-subrc = 0.
228        MOVE t_formname_top_of_page TO it_events-form.
229        APPEND it_events.
230      ENDIF.
231    ENDFORM.                    " GET_EVENT
232
233    *&---------------------------------------------------------------------*
234    *&      Form  top_of_page
235    *&---------------------------------------------------------------------*
236    FORM top_of_page.
237      CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
238        EXPORTING
239          it_list_commentary = t_list_top_of_page.
240    *      i_logo             = 'SQUIRREL'.
241    ENDFORM.                    "top_of_page
242    *&---------------------------------------------------------------------*
243    *&      Form  ALV_DISPLAY
244    *&---------------------------------------------------------------------*
245    FORM alv_display .
246      gs_layout-detail_popup         = 'X'.
247      gs_layout-detail_initial_lines = 'X'.
248      gs_layout-colwidth_optimize    = 'X'.
249      gs_layout-coltab_fieldname     = 'CELL'.
250
251      CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
252        EXPORTING
253          it_fieldcat        = it_fieldcat
254          it_events          = it_events[]
255          i_callback_program = sy-repid
256          is_layout          = gs_layout
257          it_sort            = gt_sort[]
258          i_save             = g_save
259          is_variant         = gx_variant
260    *     i_callback_pf_status_set = 'ZSTATUS'
261    *     i_callback_user_command  = 'USER_COMMAND'
262        TABLES
263          t_outtab           = gt_display1[].
264    ENDFORM.                    " ALV_DISPLAY
265    *&---------------------------------------------------------------------*
266    *&      Form  PROCESS_DATA
267    *&---------------------------------------------------------------------*
268    FORM process_data.
269      LOOP AT it_final INTO wa_final.
270    *    documentheader-bus_act    = 'RFBU'.
271        documentheader-username   = sy-uname.
272        documentheader-header_txt    = wa_final-htext.
273        documentheader-comp_code  = wa_final-compcd.
274
275        CALL FUNCTION 'KCD_EXCEL_DATE_CONVERT'
276          EXPORTING
277            excel_date = wa_final-docdt
278          IMPORTING
279            sap_date   = documentheader-doc_date.
280
281
282        CALL FUNCTION 'KCD_EXCEL_DATE_CONVERT'
283          EXPORTING
284            excel_date = wa_final-postdt
285          IMPORTING
286            sap_date   = documentheader-pstng_date.
287
288    *    documentheader-doc_type   = wa_final-blart.
289
290    *    documentheader-fis_period = wa_final-monat.
291        documentheader-ref_doc_no = wa_final-refdoc.
292        documentheader-doc_type = ls_setvlue-from.
293
294        IF wa_final-postkey = '50'
295           OR wa_final-postkey = '75'.
296
297          counter_bapi = counter_bapi + 1.
298          wa_accountgl-itemno_acc   = counter_bapi.
299
300          IF wa_final-postkey = '50'.
301            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
302              EXPORTING
303                input  = wa_final-accntno
304              IMPORTING
305                output = wa_accountgl-gl_account.
306          ELSE.
307            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
308              EXPORTING
309                input  = wa_final-accntno
310              IMPORTING
311                output = wa_accountgl-asset_no.
312          ENDIF.
313
314          IF wa_final-accntno = '102000226' OR  wa_final-accntno = '104002075'.
315            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
316              EXPORTING
317                input  = '10429'
318              IMPORTING
319                output = wa_accountgl-gl_account.
320          ENDIF.
321          IF wa_final-accntno = 'OVLPPEMYA1'.
322            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
323              EXPORTING
324                input  = '70101'
325              IMPORTING
326                output = wa_accountgl-gl_account.
327          ENDIF.
328          wa_accountgl-costcenter   = wa_final-costcntr.
329          wa_accountgl-profit_ctr   = wa_final-profcntr.
330          wa_accountgl-wbs_element = wa_final-wbs.
331          wa_accountgl-item_text    = wa_final-itemtext.
332    *      wa_accountgl-cs_trans_t = wa_final-rmvct.
333          wa_accountgl-bus_area = wa_final-busarea.
334          wa_accountgl-comp_code = wa_final-compcd.
335          wa_accountgl-doc_type = ls_setvlue-from.
336    *      CALL FUNCTION 'KCD_EXCEL_DATE_CONVERT'
337    *        EXPORTING
338    *          excel_date = wa_final-value_date
339    *        IMPORTING
340    *          sap_date   = wa_accountgl-value_date.
341
342          CALL FUNCTION 'KCD_EXCEL_DATE_CONVERT'
343            EXPORTING
344              excel_date = wa_final-postdt
345            IMPORTING
346              sap_date   = documentheader-pstng_date.
347    *      wa_accountgl-pstng_date = wa_final-postdt.
348          wa_accountgl-alloc_nmbr = wa_final-allocation.
349
350          APPEND wa_accountgl TO it_accountgl.
351          CLEAR wa_accountgl.
352        ENDIF.
353
354
355        IF wa_final-postkey = '50'
356           OR wa_final-postkey = '75'.
357          wa_currencyamount-itemno_acc  = counter_bapi.
358          wa_currencyamount-curr_type = '00'.
359    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
360    *      wa_currencyamount-amt_doccur  = wa_final-amtnon * -1.
361          wa_currencyamount-amt_doccur = CONV #( wa_final-amtnon * -1 ).
362    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
363          wa_currencyamount-currency    = wa_final-curr.
364          APPEND wa_currencyamount TO it_currencyamount.
365          CLEAR : wa_currencyamount.
366
367    *      counter_bapi = counter_bapi + 1.
368          wa_currencyamount-itemno_acc  = counter_bapi.
369          wa_currencyamount-curr_type = '10'.
370    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
371    *      wa_currencyamount-amt_doccur  = wa_final-amtinr * -1. """"On 02.02.2017 * -1.
372          wa_currencyamount-amt_doccur = CONV #( wa_final-amtinr * -1 ).""""On 02.02.2017 * -1.
373    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
374          wa_currencyamount-currency = 'INR'.
375          APPEND wa_currencyamount TO it_currencyamount.
376          CLEAR : wa_currencyamount.
377
378    *      counter_bapi = counter_bapi + 1.
379          wa_currencyamount-itemno_acc  = counter_bapi.
380          wa_currencyamount-curr_type = '50'.
381    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
382    *      wa_currencyamount-amt_doccur  = wa_final-amtidxcurr * -1. """"On 02.02.2017 * -1.
383          wa_currencyamount-amt_doccur = CONV #( wa_final-amtidxcurr * -1 ).""""On 02.02.2017 * -1.
384    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
385          wa_currencyamount-currency = 'USD'.
386          APPEND wa_currencyamount TO it_currencyamount.
387          CLEAR : wa_currencyamount.
388        ENDIF.
389
390
391        IF wa_final-postkey = '40'
392           OR wa_final-postkey = '70'.
393          counter_bapi = counter_bapi + 1.
394          wa_accountgl-itemno_acc   = counter_bapi.
395
396          IF wa_final-postkey = '40'.
397            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
398              EXPORTING
399                input  = wa_final-accntno
400              IMPORTING
401                output = wa_accountgl-gl_account.
402          ELSE.
403            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
404              EXPORTING
405                input  = wa_final-accntno
406              IMPORTING
407                output = wa_accountgl-asset_no.
408          ENDIF.
409          IF wa_final-accntno = '102000226' OR  wa_final-accntno = '104002075'.
410            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
411              EXPORTING
412                input  = '10429'
413              IMPORTING
414                output = wa_accountgl-gl_account.
415          ENDIF.
416          IF wa_final-accntno = 'OVLPPEMYA1'.
417            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
418              EXPORTING
419                input  = '70101'
420              IMPORTING
421                output = wa_accountgl-gl_account.
422          ENDIF.
423          wa_accountgl-costcenter   = wa_final-costcntr.
424          wa_accountgl-profit_ctr   = wa_final-profcntr.
425          wa_accountgl-wbs_element = wa_final-wbs.
426          wa_accountgl-item_text    = wa_final-itemtext.
427    *      wa_accountgl-cs_trans_t = wa_final-rmvct.
428          wa_accountgl-doc_type = ls_setvlue-from.
429          wa_accountgl-bus_area = wa_final-busarea.
430          wa_accountgl-comp_code = wa_final-compcd.
431
432    *      CALL FUNCTION 'KCD_EXCEL_DATE_CONVERT'
433    *        EXPORTING
434    *          excel_date = wa_final-value_date
435    *        IMPORTING
436    *          sap_date   = wa_accountgl-value_date.
437
438          CALL FUNCTION 'KCD_EXCEL_DATE_CONVERT'
439            EXPORTING
440              excel_date = wa_final-postdt
441            IMPORTING
442              sap_date   = documentheader-pstng_date.
443    *      wa_accountgl-pstng_date = wa_final-postdt.
444          wa_accountgl-alloc_nmbr = wa_final-allocation.
445
446          APPEND wa_accountgl TO it_accountgl.
447          CLEAR wa_accountgl.
448        ENDIF.
449
450        IF wa_final-postkey = '40'
451             OR wa_final-postkey = '70'.
452          wa_currencyamount-itemno_acc  = counter_bapi.
453          wa_currencyamount-curr_type = '00'.
454    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
455    *      wa_currencyamount-amt_doccur  = wa_final-amtnon. """"On 02.02.2017 * -1.
456          wa_currencyamount-amt_doccur = CONV #( wa_final-amtnon ).""""On 02.02.2017 * -1.
457    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
458          wa_currencyamount-currency    = wa_final-curr.
459          APPEND wa_currencyamount TO it_currencyamount.
460          CLEAR : wa_currencyamount.
461
462    *      counter_bapi = counter_bapi + 1.
463          wa_currencyamount-itemno_acc  = counter_bapi.
464          wa_currencyamount-curr_type = '10'.
465    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
466    *      wa_currencyamount-amt_doccur  = wa_final-amtinr. """"On 02.02.2017 * -1.
467          wa_currencyamount-amt_doccur = CONV #( wa_final-amtinr ).""""On 02.02.2017 * -1.
468    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
469          wa_currencyamount-currency    ='INR'.
470          APPEND wa_currencyamount TO it_currencyamount.
471          CLEAR : wa_currencyamount.
472
473    *      counter_bapi = counter_bapi + 1.
474          wa_currencyamount-itemno_acc  = counter_bapi.
475          wa_currencyamount-curr_type = '50'.
476    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
477    *      wa_currencyamount-amt_doccur  = wa_final-amtidxcurr. """"On 02.02.2017 * -1.
478          wa_currencyamount-amt_doccur = CONV #( wa_final-amtidxcurr ).""""On 02.02.2017 * -1.
479    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
480          wa_currencyamount-currency = 'USD'.
481          APPEND wa_currencyamount TO it_currencyamount.
482          CLEAR : wa_currencyamount.
483        ENDIF.
484
485    *******   CUSTOMER
486        IF wa_final-postkey = '11'."'31'.
487          counter_bapi = counter_bapi + 1.
488          accountreceivable-itemno_acc   = counter_bapi.
489          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
490            EXPORTING
491              input  = wa_final-accntno
492            IMPORTING
493              output = accountreceivable-customer.
494          accountreceivable-profit_ctr   = wa_final-profcntr.
495          accountreceivable-item_text    = wa_final-itemtext.
496          accountreceivable-bus_area = wa_final-busarea.
497    *      accountreceivable-sectioncode = wa_final-sec_code.
498          APPEND accountreceivable TO accountreceivable.
499          CLEAR accountreceivable.
500        ENDIF.
501
502
503        IF wa_final-postkey = '11'."'31'.
504    *      wa_currencyamount-itemno_acc  = counter_bapi.
505    *      wa_currencyamount-curr_type = '00'.
506    *      wa_currencyamount-amt_doccur  = wa_final-amtidxcurr * -1.      """"
507    *      wa_currencyamount-currency    = wa_final-curr.
508    *      APPEND wa_currencyamount TO it_currencyamount.
509    *      CLEAR : wa_currencyamount.
510    *
511    *      wa_currencyamount-itemno_acc  = counter_bapi.
512    *      wa_currencyamount-curr_type = '10'.
513    *      wa_currencyamount-amt_doccur  = wa_final-amtinr * -1. """"On 02.02.2017 * -1.
514    *      wa_currencyamount-currency    ='INR'.
515    *      APPEND wa_currencyamount TO it_currencyamount.
516    *      CLEAR : wa_currencyamount.
517          wa_currencyamount-itemno_acc  = counter_bapi.
518          wa_currencyamount-curr_type = '00'.
519    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
520    *      wa_currencyamount-amt_doccur  = wa_final-amtnon * -1.
521          wa_currencyamount-amt_doccur = CONV #( wa_final-amtnon * -1 ).
522    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
523          wa_currencyamount-currency    = wa_final-curr.
524          APPEND wa_currencyamount TO it_currencyamount.
525          CLEAR : wa_currencyamount.
526
527    *      counter_bapi = counter_bapi + 1.
528          wa_currencyamount-itemno_acc  = counter_bapi.
529          wa_currencyamount-curr_type = '10'.
530    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
531    *      wa_currencyamount-amt_doccur  = wa_final-amtinr * -1. """"On 02.02.2017 * -1.
532          wa_currencyamount-amt_doccur = CONV #( wa_final-amtinr * -1 ).""""On 02.02.2017 * -1.
533    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
534          wa_currencyamount-currency = 'INR'.
535          APPEND wa_currencyamount TO it_currencyamount.
536          CLEAR : wa_currencyamount.
537
538    *      counter_bapi = counter_bapi + 1.
539          wa_currencyamount-itemno_acc  = counter_bapi.
540          wa_currencyamount-curr_type = '50'.
541    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
542    *      wa_currencyamount-amt_doccur  = wa_final-amtidxcurr * -1. """"On 02.02.2017 * -1.
543          wa_currencyamount-amt_doccur = CONV #( wa_final-amtidxcurr * -1 ).""""On 02.02.2017 * -1.
544    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
545          wa_currencyamount-currency = 'USD'.
546          APPEND wa_currencyamount TO it_currencyamount.
547          CLEAR : wa_currencyamount.
548        ENDIF.
549
550
551        IF  wa_final-postkey = '01'."'21'.
552          counter_bapi = counter_bapi + 1.
553          accountreceivable-itemno_acc   = counter_bapi.
554          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
555            EXPORTING
556              input  = wa_final-accntno
557            IMPORTING
558              output = accountreceivable-customer.
559
560          accountreceivable-profit_ctr   = wa_final-profcntr.
561          accountreceivable-item_text    = wa_final-itemtext.
562          accountreceivable-bus_area = wa_final-busarea.
563    *      accountreceivable-sectioncode = wa_final-sec_code.
564          APPEND accountreceivable TO accountreceivable.
565          CLEAR accountreceivable.
566        ENDIF.
567
568        IF wa_final-postkey = '01'."'21'.
569    *      wa_currencyamount-itemno_acc  = counter_bapi.
570    *      wa_currencyamount-curr_type  = '00'.
571    *      wa_currencyamount-amt_doccur  = wa_final-amtidxcurr. """" * -1.
572    *      wa_currencyamount-currency    = wa_final-curr.
573    *      APPEND wa_currencyamount TO it_currencyamount.
574    *      CLEAR : wa_currencyamount.
575    *
576    *      wa_currencyamount-itemno_acc  = counter_bapi.
577    *      wa_currencyamount-curr_type = '10'.
578    *      wa_currencyamount-amt_doccur  = wa_final-amtinr. """"On 02.02.2017 * -1.
579    *      wa_currencyamount-currency    ='INR'.
580    *      APPEND wa_currencyamount TO it_currencyamount.
581    *      CLEAR : wa_currencyamount.
582          wa_currencyamount-itemno_acc  = counter_bapi.
583          wa_currencyamount-curr_type = '00'.
584    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
585    *      wa_currencyamount-amt_doccur  = wa_final-amtnon. "* -1.'" commented by AD Om 31.01.2024
586          wa_currencyamount-amt_doccur = CONV #( wa_final-amtnon )."* -1.'" commented by AD Om 31.01.2024
587    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
588          wa_currencyamount-currency    = wa_final-curr.
589          APPEND wa_currencyamount TO it_currencyamount.
590          CLEAR : wa_currencyamount.
591
592    *      counter_bapi = counter_bapi + 1.
593          wa_currencyamount-itemno_acc  = counter_bapi.
594          wa_currencyamount-curr_type = '10'.
595    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
596    *      wa_currencyamount-amt_doccur  = wa_final-amtinr ."  commented by AD Om 31.01.2024* -1.
597          wa_currencyamount-amt_doccur = CONV #( wa_final-amtinr )."  commented by AD Om 31.01.2024* -1.
598    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
599          wa_currencyamount-currency = 'INR'.
600          APPEND wa_currencyamount TO it_currencyamount.
601          CLEAR : wa_currencyamount.
602
603    *      counter_bapi = counter_bapi + 1.
604          wa_currencyamount-itemno_acc  = counter_bapi.
605          wa_currencyamount-curr_type = '50'.
606    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
607    *      wa_currencyamount-amt_doccur  = wa_final-amtidxcurr .  "commented by AD Om 31.01.2024* -1.
608          wa_currencyamount-amt_doccur = CONV #( wa_final-amtidxcurr )."commented by AD Om 31.01.2024* -1.
609    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
610          wa_currencyamount-currency = 'USD'.
611          APPEND wa_currencyamount TO it_currencyamount.
612          CLEAR : wa_currencyamount.
613        ENDIF.
614    *******    end CUSTOMER
615
616
617
618    *******   VENDOR
619        IF wa_final-postkey = '31'."'11'.
620          counter_bapi = counter_bapi + 1.
621          accountpayable-itemno_acc   = counter_bapi.
622          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
623            EXPORTING
624              input  = wa_final-accntno
625            IMPORTING
626              output = accountpayable-vendor_no.
627
628          accountpayable-profit_ctr   = wa_final-profcntr.
629          accountpayable-item_text    = wa_final-itemtext.
630    *      accountpayable-sectioncode = wa_final-sec_code.
631          accountpayable-bus_area = wa_final-busarea.
632          APPEND accountpayable TO accountpayable.
633          CLEAR accountpayable.
634        ENDIF.
635
636
637        IF wa_final-postkey = '31'."'11'.
638    *      wa_currencyamount-itemno_acc  = counter_bapi.
639    *      wa_currencyamount-curr_type = '00'.
640    *      wa_currencyamount-amt_doccur  = wa_final-amtidxcurr * -1.    """"
641    *      wa_currencyamount-currency    = wa_final-curr.
642    *      APPEND wa_currencyamount TO it_currencyamount.
643    *      CLEAR : wa_currencyamount.
644    *
645    *      wa_currencyamount-itemno_acc  = counter_bapi.
646    *      wa_currencyamount-curr_type = '10'.
647    *      wa_currencyamount-amt_doccur  = wa_final-amtinr * -1. """"On 02.02.2017 * -1.
648    *      wa_currencyamount-currency    ='INR'.
649    *      APPEND wa_currencyamount TO it_currencyamount.
650    *      CLEAR : wa_currencyamount.
651
652          wa_currencyamount-itemno_acc  = counter_bapi.
653          wa_currencyamount-curr_type = '00'.
654    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
655    *      wa_currencyamount-amt_doccur  = wa_final-amtnon * -1.
656          wa_currencyamount-amt_doccur = CONV #( wa_final-amtnon * -1 ).
657    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
658          wa_currencyamount-currency    = wa_final-curr.
659          APPEND wa_currencyamount TO it_currencyamount.
660          CLEAR : wa_currencyamount.
661
662    *      counter_bapi = counter_bapi + 1.
663          wa_currencyamount-itemno_acc  = counter_bapi.
664          wa_currencyamount-curr_type = '10'.
665    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
666    *      wa_currencyamount-amt_doccur  = wa_final-amtinr * -1. """"On 02.02.2017 * -1.
667          wa_currencyamount-amt_doccur = CONV #( wa_final-amtinr * -1 ).""""On 02.02.2017 * -1.
668    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
669          wa_currencyamount-currency = 'INR'.
670          APPEND wa_currencyamount TO it_currencyamount.
671          CLEAR : wa_currencyamount.
672
673    *      counter_bapi = counter_bapi + 1.
674          wa_currencyamount-itemno_acc  = counter_bapi.
675          wa_currencyamount-curr_type = '50'.
676    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
677    *      wa_currencyamount-amt_doccur  = wa_final-amtidxcurr * -1. """"On 02.02.2017 * -1.
678          wa_currencyamount-amt_doccur = CONV #( wa_final-amtidxcurr * -1 ).""""On 02.02.2017 * -1.
679    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
680          wa_currencyamount-currency = 'USD'.
681          APPEND wa_currencyamount TO it_currencyamount.
682          CLEAR : wa_currencyamount.
683        ENDIF.
684
685
686        IF  wa_final-postkey = '21'."'01'.
687          counter_bapi = counter_bapi + 1.
688          accountpayable-itemno_acc   = counter_bapi.
689          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
690            EXPORTING
691              input  = wa_final-accntno
692            IMPORTING
693              output = accountpayable-vendor_no.
694
695          accountpayable-profit_ctr   = wa_final-profcntr.
696          accountpayable-item_text    = wa_final-itemtext.
697          accountpayable-bus_area = wa_final-busarea.
698    *      accountpayable-sectioncode = wa_final-sec_code.
699          APPEND accountpayable TO accountpayable.
700          CLEAR accountpayable.
701        ENDIF.
702
703        IF wa_final-postkey = '21'."'01'.
704    *      wa_currencyamount-itemno_acc  = counter_bapi.
705    *      wa_currencyamount-curr_type = '00'.
706    *      wa_currencyamount-amt_doccur  = wa_final-amtidxcurr. """" * -1.
707    *      wa_currencyamount-currency    = wa_final-curr.
708    *      APPEND wa_currencyamount TO it_currencyamount.
709    *      CLEAR : wa_currencyamount.
710    *
711    *      wa_currencyamount-itemno_acc  = counter_bapi.
712    *      wa_currencyamount-curr_type = '10'.
713    *      wa_currencyamount-amt_doccur  = wa_final-amtinr. """"On 02.02.2017 * -1.
714    *      wa_currencyamount-currency    ='INR'.
715    *      APPEND wa_currencyamount TO it_currencyamount.
716    *      CLEAR : wa_currencyamount.
717       wa_currencyamount-itemno_acc  = counter_bapi.
718          wa_currencyamount-curr_type = '00'.
719    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
720    *      wa_currencyamount-amt_doccur  = wa_final-amtnon * -1.
721          wa_currencyamount-amt_doccur = CONV #( wa_final-amtnon * -1 ).
722    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
723          wa_currencyamount-currency    = wa_final-curr.
724          APPEND wa_currencyamount TO it_currencyamount.
725          CLEAR : wa_currencyamount.
726
727    *      counter_bapi = counter_bapi + 1.
728          wa_currencyamount-itemno_acc  = counter_bapi.
729          wa_currencyamount-curr_type = '10'.
730    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
731    *      wa_currencyamount-amt_doccur  = wa_final-amtinr * -1. """"On 02.02.2017 * -1.
732          wa_currencyamount-amt_doccur = CONV #( wa_final-amtinr * -1 ).""""On 02.02.2017 * -1.
733    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
734          wa_currencyamount-currency = 'INR'.
735          APPEND wa_currencyamount TO it_currencyamount.
736          CLEAR : wa_currencyamount.
737
738    *      counter_bapi = counter_bapi + 1.
739          wa_currencyamount-itemno_acc  = counter_bapi.
740          wa_currencyamount-curr_type = '50'.
741    " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
742    *      wa_currencyamount-amt_doccur  = wa_final-amtidxcurr * -1. """"On 02.02.2017 * -1.
743          wa_currencyamount-amt_doccur = CONV #( wa_final-amtidxcurr * -1 ).""""On 02.02.2017 * -1.
744    " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
745          wa_currencyamount-currency = 'USD'.
746          APPEND wa_currencyamount TO it_currencyamount.
747          CLEAR : wa_currencyamount.
748        ENDIF.
749    *******    end VENDOR
750
751      ENDLOOP.
752
753      CLEAR ls_extension.
754      ls_extension-valuepart1 = sy-repid.
755      ls_extension-valuepart2 = 'STATUS_NEW'.
756      ls_extension-valuepart3 = '3'.
757      APPEND ls_extension TO lt_extension.
758
759    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
760      CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'  "#EC CI_USAGE_OK
761          "#EC CI_USAGE_OK[2628704]
762      "#EC CI_USAGE_OK[2438131]
763
764    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
765        EXPORTING
766          "Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
767          documentheader    = documentheader
768          "Code Remediation changes S4 2025_1_A Conversion **END OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
769    *    IMPORTING
770    *     obj_type          = obj_type
771    *     obj_key           = obj_key
772    *     obj_sys           = obj_sys
773        TABLES
774          accountgl         = it_accountgl[]
775          currencyamount    = it_currencyamount[]
776          accountreceivable = accountreceivable[]
777          accountpayable    = accountpayable[]
778          return            = return[]
779          extension2        = lt_extension[].
780
781      READ TABLE return WITH KEY type = 'E'.
782      IF sy-subrc = 0.
783        LOOP AT return WHERE type = 'E'.
784          MOVE-CORRESPONDING return TO gs_display.
785          APPEND gs_display TO gt_display.
786        ENDLOOP.
787      ELSE.
788        LOOP AT return.
789          MOVE-CORRESPONDING return TO gs_display.
790          APPEND gs_display TO gt_display.
791        ENDLOOP.
792        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
793
794      ENDIF.
795
796        LOOP AT gt_display INTO gs_display.
797        IF gs_display-type = 'E' and gs_display-id = 'FMAVC' and gs_display-number = '005'.
798
799        ENDIF.
800      ENDLOOP.
801
802        SORT IT_FINAL1 BY accntno postkey.
803        DELETE ADJACENT DUPLICATES FROM IT_FINAL1 COMPARING postkey.
804        LOOP AT it_final1 INTO wa_final1.
805          gs_display-type = 'E' .
806          Concatenate 'Posting key' wa_final1-postkey 'is not maintained ZFI_PK_COL_SUB' INTO gs_display-message SEPARATED BY space.
807          APPEND gs_display TO gt_display.
808        ENDLOOP.
809      REFRESH : IT_FINAL1.
810      REFRESH: return,
811             accountgl,
812             currencyamount,
813             accountreceivable,
814             accountpayable.
815    *         documentheader.
816
817      CLEAR:   return,
818               accountgl,
819               currencyamount,
820               accountreceivable,
821               accountpayable,
822               documentheader,
823               obj_type,
824               obj_sys,
825               counter_bapi,
826               obj_key,
827               it_accountgl,
828               it_currencyamount,
829               it_accountgl[],
830               it_currencyamount[].
831    ENDFORM.
832    *&---------------------------------------------------------------------*
833    *&      Form  PROCESS_ALV
834    *&---------------------------------------------------------------------*
835    FORM process_alv .
836      LOOP AT gt_display INTO gs_display.
837        MOVE-CORRESPONDING gs_display TO gs_display1.
838        IF gs_display1-type = 'S'.
839          fs_cell-fieldname = 'TYPE'.
840          fs_cell-color-col = 5.
841          APPEND fs_cell TO gs_display1-cell.
842        ENDIF.
843        IF gs_display1-type = 'E'.
844          fs_cell-fieldname = 'TYPE'.
845          fs_cell-color-col = 6.
846          APPEND fs_cell TO gs_display1-cell.
847        ENDIF.
848        APPEND gs_display1 TO gt_display1.
849        CLEAR : gs_display1.
850      ENDLOOP.
851
852
853
854      IF gt_display1[] IS NOT INITIAL.
855        PERFORM alv_fieldcat.
856        PERFORM alv_display.
857      ENDIF.
858    ENDFORM.
859    *&---------------------------------------------------------------------*
860    *&      Form  MODIFY_IST_GL
861    *&---------------------------------------------------------------------*
862    FORM modify_ist_gl .
863
864    *  DELETE it_final INDEX 1.
865
866    * Reading Set Value for document type
867      CALL FUNCTION 'G_SET_GET_ALL_VALUES'
868        EXPORTING
869          client          = sy-mandt
870          setnr           = 'ZJVNONOPJIB_DOCTYP_MON'
871          table           = 'BKPF'
872          class           = '0000'
873          no_descriptions = 'X'
874          no_rw_info      = 'X'
875          fieldname       = 'BLART'
876        TABLES
877          set_values      = lt_setvlue
878        EXCEPTIONS
879          set_not_found   = 1
880          OTHERS          = 2.
881      IF sy-subrc <> 0.
882    * Implement suitable error handling here
883      ENDIF.
884
885      IF lt_setvlue[] IS NOT INITIAL.
886        READ TABLE lt_setvlue INTO ls_setvlue INDEX 1.
887      ENDIF.
888
889
890    * Reading Set Value for document type
891      CALL FUNCTION 'G_SET_GET_ALL_VALUES'
892        EXPORTING
893          client          = sy-mandt
894          setnr           = 'ZJVNONOPJIB_EXCHTYP_MON'
895          table           = 'BKPF'
896          class           = '0000'
897          no_descriptions = 'X'
898          no_rw_info      = 'X'
899          fieldname       = 'KUTY2'
900        TABLES
901          set_values      = lt_setvlue_er
902        EXCEPTIONS
903          set_not_found   = 1
904          OTHERS          = 2.
905      IF sy-subrc <> 0.
906    * Implement suitable error handling here
907      ENDIF.
908
909      IF lt_setvlue_er[] IS NOT INITIAL.
910        READ TABLE lt_setvlue_er INTO ls_setvlue_er INDEX 1.
911      ENDIF.
912      READ TABLE it_final INTO wa_final INDEX 1.
913          IF wa_final-amtinr is INITIAL.
914        CONCATENATE wa_final-postdt+6(4) wa_final-postdt+3(2) wa_final-postdt+0(2) INTO Ls_date1.
915        CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
916          EXPORTING
917            day_in                  = ls_date1
918         IMPORTING
919           LAST_DAY_OF_MONTH        = ls_Date
920         EXCEPTIONS
921           DAY_IN_NO_DATE          = 1
922           OTHERS                  = 2
923                  .
924        IF sy-subrc <> 0.
925    * Implement suitable error handling here
926        ENDIF.
927
928      CONCATENATE '01' wa_final-postdt+3(2) wa_final-postdt+6(4) INTO LV_DATE.
929      CALL FUNCTION 'CONVERSION_EXIT_INVDT_INPUT'
930        EXPORTING
931          INPUT  = LV_DATE
932        IMPORTING
933          OUTPUT = DATUM.
934
935      clear lv_date.
936
937       CONCATENATE ls_Date+6(2) ls_date+4(2) ls_Date+0(4) INTO LV_DATE.
938        CALL FUNCTION 'CONVERSION_EXIT_INVDT_INPUT'
939        EXPORTING
940          INPUT  = LV_DATE
941        IMPORTING
942          OUTPUT = DATUM1.
943
944
945    " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
946    *  SELECT SINGLE KURST, FCURR, TCURR, GDATU, UKURS
947    *       FROM TCURR
948    *       INTo @data(ls_TCURR)
949    *       WHERE KURST EQ 'NTA'
950    *         AND FCURR EQ 'USD'
951    *         AND TCURR EQ 'INR'
952    *         AND ( GDATU LE @DATUM and gdatu GE @datum1 ).
953     SELECT KURST , FCURR , TCURR , GDATU , UKURS FROM TCURR   UP TO 1 ROWS
954    INTO @DATA(LS_TCURR) WHERE KURST EQ 'NTA' AND FCURR EQ 'USD' AND TCURR
955    EQ 'INR' AND ( GDATU LE @DATUM AND GDATU GE @DATUM1 )  ORDER BY  KURST,
956    FCURR, TCURR, GDATU .   ENDSELECT.
957    " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
958        ENDIF.
959
960        SELECT * FROM ZFI_PK_COL_SUB INTO TABLE @DATA(LT_POSTKEYS).
961
962        clear wa_final.
963     data: v_inr TYPE p DECIMALS 2.
964     DATA : INX TYPE SY-TABIX.
965
966      LOOP AT it_final INTO wa_final .
967    ******* Check posting key
968
969      INX = SY-TABIX.
970
971     clear v_inr.
972     IF wa_final-amtinr is INITIAL.
973    v_inr = wa_final-amtidxcurr * ls_tcurr-UKURS.
974    wa_final-amtinr = v_inr.
975    CONDENSE wa_final-amtinr.
976    ENDIF.
977        SELECT SINGLE  bschl FROM tbsl INTO l_bschl WHERE bschl =
978        wa_final-postkey
979
980                                                                           .
981        IF sy-subrc <> 0.
982          MOVE-CORRESPONDING wa_final TO wa_final1.
983          MOVE sy-tabix TO wa_final1-somefield.
984          wa_final1-doctyp = ls_setvlue-from.
985          APPEND wa_final1 TO it_final1.
986          DELETE it_final INDEX INX."sy-tabix.
987        ENDIF.
988    * Delete blank lines.
989        IF wa_final-docdt  = ''  OR
990           ls_setvlue-from =  '' OR  "Bipin
991           wa_final-postdt = ''.
992          MOVE-CORRESPONDING wa_final TO wa_final1.
993          MOVE sy-tabix TO wa_final1-somefield.
994          wa_final1-doctyp = ls_setvlue-from.
995          APPEND wa_final1 TO it_final1.
996          DELETE it_final INDEX INX."sy-tabix.
997        ENDIF.
998
999    *    IF wa_final-postkey = '40' OR
1000   *       wa_final-postkey = '50' OR
1001   *       wa_final-postkey = '21' OR
1002   *       wa_final-postkey = '31' OR
1003   *       wa_final-postkey = '01' OR
1004   *       wa_final-postkey = '70' OR
1005   *       wa_final-postkey = '75'.
1006        READ TABLE LT_POSTKEYS INTO DATA(LS_POSTKEYS) WITH KEY POST_KEY = wa_final-postkey.
1007        IF wa_final-postkey EQ LS_POSTKEYS-post_key.
1008
1009       ELSE.
1010
1011         MOVE-CORRESPONDING wa_final TO wa_final1.
1012         MOVE sy-tabix TO wa_final1-somefield.
1013         wa_final1-doctyp = ls_setvlue-from.
1014         APPEND wa_final1 TO it_final1.
1015         DELETE it_final INDEX INX."sy-tabix.
1016       ENDIF.
1017
1018
1019
1020       MODIFY it_final FROM wa_final TRANSPORTING amtinr.
1021       CLEAR INX.
1022     ENDLOOP.
1023
1024
1025   " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1026   *  SELECT * FROM tbsl INTO TABLE lt_tbsl.
1027   SELECT * FROM tbsl INTO TABLE lt_tbsl
1028         ORDER BY PRIMARY KEY.
1029   " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
1030     SELECT * FROM t003 INTO TABLE lt_t003.
1031   ENDFORM.
*--- End of ZFI_GL_ACCOUNT_POST_COL_SUB - 1031 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CSLIS                                   Level 1    Page 5
Object           ZFI_GL_ACCOUNT_COL_POST                   Lines 543
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:12
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
Object           ZFI_GL_ACCOUNT_COL_POST                   Lines 166
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:12
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
Object           ZFI_GL_ACCOUNT_COL_POST                   Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:12
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
Object           ZFI_GL_ACCOUNT_COL_POST                   Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:12
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
Object           ZFI_GL_ACCOUNT_COL_POST                   Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:12
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
Object           ZFI_GL_ACCOUNT_COL_POST                   Lines 1
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:12
----------------------------------------------------------------------------------------------------
1      * INCLUDE DB__SSEL
*--- End of DB__SSEL - 1 lines ---
