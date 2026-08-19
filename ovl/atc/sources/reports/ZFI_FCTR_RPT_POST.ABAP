----------------------------------------------------------------------------------------------------
Main program     ZFI_FCTR_RPT_POST                         Level 0    Page 1
Object           ZFI_FCTR_RPT_POST                         Lines 299
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:09
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *& Report  ZFI_FCTR_RPT_POST
3      *&
4      *&---------------------------------------------------------------------*
5      *&
6      *&
7      *&---------------------------------------------------------------------*
8      REPORT ZFI_FCTR_RPT_POST.
9
10     INCLUDE ZFI_FCTR_RPT_POST_DD.
11     *INCLUDE zfi_fctr_rpt_dd.
12     INCLUDE ZFI_FCTR_RPT_POST_SS.
13     *INCLUDE zfi_fctr_rpt_ss.
14     INCLUDE ZFI_FCTR_RPT_POST_SUB.
15     *INCLUDE zfi_fctr_rpt_sub.
16
17     INITIALIZATION.
18
19     AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_period-high.
20       PERFORM f_month_help1.
21
22     AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_kokr-low.
23       PERFORM s_kokr_help.
24
25     AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_kokr-high.
26       PERFORM s_kokr_help.
27
28     AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_kokr1-low.
29       PERFORM s_kokr_help.
30
31     AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_kokr1-high.
32       PERFORM s_kokr_help.
33
34     AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_kokr2-low.
35       PERFORM s_kokr_help.
36
37     AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_kokr2-high.
38       PERFORM s_kokr_help.
39
40     AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_kokr3-low.
41       PERFORM s_kokr_help.
42
43     AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_kokr3-high.
44       PERFORM s_kokr_help.
45
46     AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_pspid-low.
47       PERFORM s_pspid_help.
48
49     AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_pspid-high.
50       PERFORM s_pspid_help.
51
52     at SELECTION-SCREEN.
53
54         IF ( s_period-low eq '01' and s_period-high eq '03' ) or ( s_period-low eq '04' and s_period-high eq '06' )
55           or ( s_period-low eq '07' and s_period-high eq '09' ) or ( s_period-low eq '10' and s_period-high eq '12' ).
56           else.
57
58          MESSAGE 'Please enter correct Quarter' TYPE 'E'.
59
60         ENDIF.
61
62
63
64         if p_year is NOT INITIAL and  S_PERIOD-high is NOT INITIAL.
65
66           p_poper = S_PERIOD-high.
67
68     CALL FUNCTION 'LAST_DAY_IN_PERIOD_GET'
69       EXPORTING
70         I_GJAHR              = p_year
71     *   I_MONMIT             = 00
72         I_PERIV              = 'V3'
73         I_POPER              = p_poper
74      IMPORTING
75        E_DATE               = p_budat
76      EXCEPTIONS
77        INPUT_FALSE          = 1
78        T009_NOTFOUND        = 2
79        T009B_NOTFOUND       = 3
80        OTHERS               = 4
81               .
82     IF SY-SUBRC <> 0.
83     * Implement suitable error handling here
84     ENDIF.
85
86     ENDIF.
87
88
89     ** Added by ss on 2.6.21
90
91     ** Added by ss on 9.6.21
92       IF SSCRFIELDS-UCOMM = 'ONLI'.
93
94         IF S_PERIOD-HIGH = '03'.
95
96           IF S_SENM-LOW IS INITIAL AND S_KOKR IS INITIAL.
97             MESSAGE 'Enter either Cost Center Group or Values for Cost Center' TYPE 'E'.
98           ELSE.
99             IF S_SENM-LOW IS  NOT INITIAL.  " Check for Cost Center Group
100              SELECT SINGLE SETNAME
101                     FROM SETLEAF INTO @DATA(WA_TAB) WHERE SETNAME EQ @S_SENM-LOW.
102              IF SY-SUBRC NE 0.
103                MESSAGE 'Please enter correct Cost Center group' TYPE 'E'.
104              ENDIF.
105            ELSEIF S_KOKR IS NOT INITIAL.  " check Values for Cost Centre
106              LOOP AT S_KOKR.
107                SELECT SINGLE KOSTL FROM CSKS INTO @DATA(LV_KOSTL_RS) WHERE KOSTL EQ @S_KOKR-LOW.
108                IF SY-SUBRC NE 0.
109                  MESSAGE 'Please enter correct Values for Cost Center' TYPE  'E'.
110                ENDIF.
111              ENDLOOP.
112
113            ENDIF.  " (Cost center check )
114          ENDIF. " ( Cost Center values initial or not )
115
116
117          IF S_SECLS-LOW IS INITIAL AND S_KTOP IS INITIAL.
118            MESSAGE 'Enter either Cost Element Group or Values for Cost Element' TYPE 'E'.
119          ELSE.
120            IF S_SECLS-LOW IS  NOT INITIAL. " check for cost Element group
121              SELECT SINGLE SETNAME
122                    FROM SETLEAF INTO @DATA(LV_SETNAME) WHERE SETNAME EQ @S_SECLS-LOW.
123              IF SY-SUBRC NE 0.
124                MESSAGE 'Please enter correct Cost Element group' TYPE 'E'.
125              ENDIF.
126            ELSEIF S_KTOP IS NOT INITIAL.   " values for Cost Element
127                LOOP AT S_KTOP.
128                  SELECT KSTAR FROM CSKA INTO TABLE @DATA(LV_KTOP_EQ) WHERE KSTAR EQ @S_KTOP-LOW.
129                  IF SY-SUBRC NE 0.
130                    MESSAGE 'Please enter correct Values of Cost Element' TYPE 'E'.
131                  ENDIF.
132                ENDLOOP.
133
134            ENDIF. " ( Cost Element check  )
135          ENDIF. " ( Cost Element is not initial )
136
137
138        ELSEIF S_PERIOD-HIGH  = '06'.
139
140          IF S_SENM1-LOW IS INITIAL AND S_KOKR1 IS INITIAL.
141            MESSAGE 'Enter either Cost Center Group or Values for Cost Center' TYPE 'E'.
142          ELSE.
143            IF S_SENM1-LOW IS  NOT INITIAL.  " Check for Cost Center Group
144              SELECT SINGLE SETNAME
145                    FROM SETLEAF INTO @DATA(WA_TAB1) WHERE SETNAME EQ @S_SENM1-LOW.
146              IF SY-SUBRC NE 0.
147                MESSAGE 'Please enter correct Cost Center group' TYPE 'E'.
148              ENDIF.
149
150            ELSEIF S_KOKR1 IS NOT INITIAL.  " check for value for cost center.
151              LOOP AT S_KOKR1.
152                SELECT SINGLE KOSTL FROM CSKS INTO @DATA(LV_KOSTL1_RS) WHERE KOSTL EQ @S_KOKR1-LOW.
153                IF SY-SUBRC NE 0.
154                  MESSAGE 'Please enter correct value for Cost Center' TYPE  'E'.
155                ENDIF.
156              ENDLOOP.
157
158            ENDIF.  " ( Check for Cost Center values)
159          ENDIF.  " (Check if cost center is initial )
160
161
162          IF S_SECLS1-LOW IS INITIAL AND S_KTOP1 IS INITIAL.  " Check for Cost Element
163            MESSAGE 'Enter either Cost Element Group or Values for Cost Element' TYPE 'E'.
164          ELSE.
165            IF S_SECLS1-LOW IS  NOT INITIAL.  " Check for Cost element group
166              SELECT SINGLE SETNAME
167                    FROM SETLEAF INTO @DATA(LV_SETNAME1) WHERE SETNAME EQ @S_SECLS1-LOW.
168              IF SY-SUBRC NE 0.
169                MESSAGE 'Please enter correct Cost Element group' TYPE 'E'.
170              ENDIF.
171            ELSEIF S_KTOP1 IS NOT INITIAL.  " Check value for cost element
172                LOOP AT S_KTOP1.
173                  SELECT KSTAR FROM CSKA INTO TABLE @DATA(LV_KTOP1_EQ) WHERE KSTAR EQ @S_KTOP1-LOW.
174                  IF SY-SUBRC NE 0.
175                    MESSAGE 'Please enter correct values of Cost Element' TYPE 'E'.
176                  ENDIF.
177                ENDLOOP.
178
179              ENDIF.  " ( Check Cost Element)
180            ENDIF. " ( Check for cost Element is initial)
181
182        ELSEIF S_PERIOD-HIGH  = '09'.
183
184          IF S_SENM2-LOW IS INITIAL AND S_KOKR2 IS INITIAL. " Cost center check
185            MESSAGE 'Enter either Cost Center Group or Values for Cost Center' TYPE 'E'.
186          ELSE.
187            IF S_SENM2-LOW IS  NOT INITIAL.  " Check for Cost Group
188              SELECT SINGLE SETNAME
189                    FROM SETLEAF INTO @DATA(WA_TAB2) WHERE SETNAME EQ @S_SENM2-LOW.
190              IF SY-SUBRC NE 0.
191                MESSAGE 'Please enter correct Cost Center group' TYPE 'E'.
192              ENDIF.
193            ELSEIF S_KOKR2 IS NOT INITIAL. " Check for cost center values
194              LOOP AT S_KOKR2.
195                SELECT SINGLE KOSTL FROM CSKS INTO @DATA(LV_KOSTL2_RS) WHERE KOSTL EQ @S_KOKR2-LOW.
196                IF SY-SUBRC NE 0.
197                  MESSAGE 'Please enter correct values for Cost Center' TYPE  'E'.
198                ENDIF.
199              ENDLOOP.
200
201            ENDIF. " ( Check for Cost center )
202          ENDIF. " ( Check for Cost Center is initial )
203
204          IF S_SECLS2-LOW IS INITIAL AND S_KTOP2 IS INITIAL. " Check for Cost Element is initial
205            MESSAGE 'Enter either Cost Element Group or Values for Cost Element' TYPE 'E'.
206          ELSE.
207            IF S_SECLS2-LOW IS  NOT INITIAL.  " Check for Cost Element group
208              SELECT SINGLE SETNAME
209                    FROM SETLEAF INTO @DATA(LV_SETNAME2) WHERE SETNAME EQ @S_SECLS2-LOW.
210              IF SY-SUBRC NE 0.
211                MESSAGE 'Please enter correct Cost Element group' TYPE 'E'.
212              ENDIF.
213            ELSEIF S_KTOP2 IS NOT INITIAL.   " Check for Values for Cost Element
214                LOOP AT S_KTOP2.
215                  SELECT KSTAR FROM CSKA INTO TABLE @DATA(LV_KTOP2_EQ) WHERE KSTAR EQ @S_KTOP2-LOW.
216                  IF SY-SUBRC NE 0.
217                    MESSAGE 'Please enter correct values of Cost Element' TYPE 'E'.
218                  ENDIF.
219                ENDLOOP.
220              ENDIF.  " Check for Cost Element
221          ENDIF.  " ( Check for Cost Element is initial)
222
223
224        ELSEIF S_PERIOD-HIGH  = '012'.
225
226          IF S_SENM3-LOW IS INITIAL AND S_KOKR3 IS INITIAL.  " Check for cost center is initial)
227            MESSAGE 'Enter either Cost Center Group or Values for Cost Center' TYPE 'E'.
228          ELSE.
229            IF S_SENM3-LOW IS  NOT INITIAL.  " Check for Cost Center Group
230              SELECT SINGLE SETNAME
231                    FROM SETLEAF INTO @DATA(WA_TAB3) WHERE SETNAME EQ @S_SENM3-LOW.
232              IF SY-SUBRC NE 0.
233                MESSAGE 'Please enter correct Cost Center group' TYPE 'E'.
234              ENDIF.
235
236            ELSEIF S_KOKR3 IS NOT INITIAL.  " Check for Values for cost center
237              LOOP AT S_KOKR3.
238                SELECT SINGLE KOSTL FROM CSKS INTO @DATA(LV_KOSTL3_RS) WHERE KOSTL EQ @S_KOKR3-LOW.
239                IF SY-SUBRC NE 0.
240                  MESSAGE 'Please enter correct value for Cost Center' TYPE  'E'.
241                ENDIF.
242              ENDLOOP.
243
244            ENDIF.  " (Check Cost Center Values )
245          ENDIF. " ( Check for cost center is initial)
246
247
248          IF S_SECLS3-LOW IS INITIAL AND S_KTOP3 IS INITIAL.
249            MESSAGE 'Enter either Cost Element Group or Values for Cost Element' TYPE 'E'.
250          ELSE.
251            IF S_SECLS3-LOW IS  NOT INITIAL.  " check for Cost element group
252              SELECT SINGLE SETNAME
253                    FROM SETLEAF INTO @DATA(LV_SETNAME3) WHERE SETNAME EQ @S_SECLS3-LOW.
254              IF SY-SUBRC NE 0.
255                MESSAGE 'Please enter correct Cost Element group' TYPE 'E'.
256              ENDIF.
257            ELSEIF S_KTOP3 IS NOT INITIAL.  " Check for Values for Cost element
258                LOOP AT S_KTOP3.
259                  SELECT KSTAR FROM CSKA INTO TABLE @DATA(LV_KTOP3_EQ) WHERE KSTAR EQ @S_KTOP3-LOW.
260                  IF SY-SUBRC NE 0.
261                    MESSAGE 'Please enter correct value of Cost Element' TYPE 'E'.
262                  ENDIF.
263                ENDLOOP.
264              ENDIF. "( Check Cost Element values )
265          ENDIF. " ( Check for Cost Element initial )
266
267
268        ENDIF.  " ( S_PERIOD-HIGH = '03')
269      ENDIF.  "( SSCRFIELDS-UCOMM = 'ONLI')
270    * EOC on 9.6.21
271
272
273
274
275    START-OF-SELECTION.
276    *s = 0.
277    *  IF s_senm-low IS INITIAL.
278    *    MESSAGE 'Please fill Cost Center Group' TYPE 'S' DISPLAY LIKE 'E'.
279    *    s = 1.
280    *  ELSEIF s_secls-low IS INITIAL.
281    *    MESSAGE 'Please fill Cost Element Group' TYPE 'S' DISPLAY LIKE 'E'.
282    *    s = 1.
283    *  ELSE.
284    *    s = 0.
285    *  ENDIF.
286    *  IF s = 0.
287        PERFORM get_data.
288
289        IF gt_saknr IS INITIAL.
290          IF gt_final[] IS NOT INITIAL.
291            PERFORM alv_fieldcat.
292            PERFORM get_event.
293            PERFORM sub_comment_build USING t_list_top_of_page.
294            PERFORM alv_display.
295          ELSE.
296            MESSAGE 'No Data Found' TYPE 'E'.
297          ENDIF.
298        ENDIF.
299    *  ENDIF.
*--- End of ZFI_FCTR_RPT_POST - 299 lines ---

----------------------------------------------------------------------------------------------------
Include          ZFI_FCTR_RPT_POST_DD                      Level 1    Page 2
Object           ZFI_FCTR_RPT_POST                         Lines 402
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:09
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *&  Include           ZFI_FCTR_DD
3      *&---------------------------------------------------------------------*
4      TYPE-POOLS truxs.
5
6      TABLES : ccr1z,ska1,bsis,tcurr,t001,bkpf, faglflext,tka02,v_prpmp,prps,setleaf,csks,cska,coep,SSCRFIELDS.
7
8      *&---------------------------------------------------------------------*
9      *& ALV Data Declaration
10     *&---------------------------------------------------------------------*
11     DATA: it_fieldcat            TYPE slis_t_fieldcat_alv.
12     DATA: wa_fieldcat            LIKE LINE OF it_fieldcat.
13     DATA: t_list_top_of_page     TYPE slis_t_listheader.
14     DATA: t_list_top_of_page1     TYPE slis_t_listheader.
15     DATA: it_events              TYPE slis_t_event WITH HEADER LINE.
16     DATA: g_save                 TYPE c VALUE 'A'.
17     DATA: gt_sort                TYPE slis_t_sortinfo_alv.
18     DATA: gx_save                TYPE c VALUE 'A'.
19     DATA: gx_variant             TYPE disvariant.
20     DATA: g_variant              TYPE disvariant.
21     DATA: gs_layout              TYPE slis_layout_alv.
22     DATA: t_formname_top_of_page TYPE slis_formname VALUE 'TOP_OF_PAGE'.
23     DATA: t_i_event              TYPE slis_alv_event.
24
25     TYPES : BEGIN OF ty_ska1,
26               ktopl TYPE ktopl,
27               saknr TYPE saknr,
28               xbilk TYPE xbilk,
29             END OF ty_ska1,
30
31             BEGIN OF ty_tcurr,
32               kurst  TYPE kurst_curr,
33               fcurr  TYPE fcurr_curr,
34               tcurr  TYPE tcurr_curr,
35               gdatu  TYPE gdatu_inv,
36               ukurs  TYPE ukurs_curr,
37               tdate  TYPE sy-datum,
38               ukurs1 TYPE p DECIMALS 4,
39             END OF ty_tcurr,
40
41             BEGIN OF ty_fctr,
42               gl_account TYPE  zhkont,
43               znature    TYPE znature1,
44               zconvrsn   TYPE zconvrsn,
45               fctr_gl    TYPE zfhkont,
46             END OF ty_fctr,
47
48             BEGIN OF ty_final,
49               fctr_gl     TYPE char16,
50               ktopl       TYPE ktopl,
51               bukrs       TYPE bukrs,
52               saknr       TYPE saknr,
53               xbilk       TYPE xbilk,
54               hkont       TYPE hkont,
55               budat       TYPE budat,
56               blart       TYPE blart,
57               gjahr       TYPE gjahr,
58               dmbe2       TYPE p DECIMALS 2,
59               dmbtr       TYPE p DECIMALS 2,
60               zconvrsn    TYPE zconvrsn,
61               kurst       TYPE kurst_curr,
62               fcurr       TYPE fcurr_curr,
63               tcurr       TYPE tcurr_curr,
64               gdatu       TYPE gdatu_inv,
65               ukurs       TYPE p DECIMALS 4,
66               convert_inr TYPE p DECIMALS 2,
67               exchng      TYPE p DECIMALS 2,
68               gain_loss   TYPE char30,
69               sub_totl    TYPE dmbtr,
70               fctr_gl_pk  TYPE bschl,
71               gl_pk       TYPE bschl,
72               key         TYPE i,
73               hslvt       TYPE hslvt12,
74               kslvt       TYPE hslvt12,
75               hsl01       TYPE hslvt12,
76               hsl02       TYPE hslvt12,
77               hsl03       TYPE hslvt12,
78               hsl04       TYPE hslvt12,
79               hsl05       TYPE hslvt12,
80               hsl06       TYPE hslvt12,
81               hsl07       TYPE hslvt12,
82               hsl08       TYPE hslvt12,
83               hsl09       TYPE hslvt12,
84               hsl10       TYPE hslvt12,
85               hsl11       TYPE hslvt12,
86               hsl12       TYPE hslvt12,
87               hsl13       TYPE hslvt12,
88               hsl14       TYPE hslvt12,
89               hsl15       TYPE hslvt12,
90               hsl16       TYPE hslvt12,
91               ksl01       TYPE kslxx12,
92               ksl02       TYPE kslxx12,
93               ksl03       TYPE kslxx12,
94               ksl04       TYPE kslxx12,
95               ksl05       TYPE kslxx12,
96               ksl06       TYPE kslxx12,
97               ksl07       TYPE kslxx12,
98               ksl08       TYPE kslxx12,
99               ksl09       TYPE kslxx12,
100              ksl10       TYPE kslxx12,
101              ksl11       TYPE kslxx12,
102              ksl12       TYPE kslxx12,
103              ksl13       TYPE kslxx12,
104              ksl14       TYPE kslxx12,
105              ksl15       TYPE kslxx12,
106              ksl16       TYPE kslxx12,
107              wogbtr      TYPE wogxxx,
108              wkgbtr      TYPE wkgxxx,
109              kstar       TYPE kstar,
110              wogbtr1     TYPE wogxxx,
111              wkgbtr1     TYPE wkgxxx,
112              wogbtr1q2   TYPE wogxxx,
113              wkgbtr1q2   TYPE wkgxxx,
114              wogbtr1q3   TYPE wogxxx,
115              wkgbtr1q3   TYPE wkgxxx,
116              wogbtr1q4   TYPE wogxxx,
117              wkgbtr1q4   TYPE wkgxxx,
118              wogbtr1t    TYPE wogxxx,
119              wkgbtr1t    TYPE wkgxxx,
120              inrtot      TYPE p DECIMALS 2,
121              usdtot      TYPE p DECIMALS 2,
122            END OF ty_final,
123
124            BEGIN OF ty_skb1,
125              bukrs TYPE bukrs,
126              saknr TYPE saknr,
127            END OF ty_skb1,
128
129            BEGIN OF ty_saknr,
130              hkont TYPE hkont,
131            END OF ty_saknr.
132
133    DATA : lv_date    TYPE gdatu_inv,
134           datum      TYPE char10,
135           lv_date_ps TYPE gdatu_inv,
136           datum_ps   TYPE char10.
137
138    DATA : lv_odate TYPE char10.
139    DATA : lv_year TYPE char4.
140    DATA : lv_head TYPE char15.
141    DATA : lv_head_date TYPE char10.
142
143    DATA : gt_saknr TYPE STANDARD TABLE OF ty_saknr,
144           gs_saknr TYPE ty_saknr.
145
146    DATA : gt_ska1 TYPE STANDARD TABLE OF ty_ska1,
147           gs_ska1 TYPE ty_ska1.
148
149    DATA : gt_skb1 TYPE STANDARD TABLE OF ty_skb1,
150           gs_skb1 TYPE ty_skb1.
151
152    DATA : gt_tcurr TYPE STANDARD TABLE OF ty_tcurr,
153           gs_tcurr TYPE ty_tcurr.
154
155    DATA : gt_tcurr_pl TYPE STANDARD TABLE OF ty_tcurr,
156           gs_tcurr_pl TYPE ty_tcurr.
157
158    DATA : gt_fctr TYPE STANDARD TABLE OF ty_fctr,
159           gs_fctr TYPE ty_fctr.
160
161    DATA : gt_fctr1 TYPE STANDARD TABLE OF ty_fctr,
162           gs_fctr1 TYPE ty_fctr.
163
164    DATA : gt_final TYPE STANDARD TABLE OF ty_final,
165           gs_final TYPE ty_final.
166
167    DATA : gt_wbs TYPE STANDARD TABLE OF ty_final,
168           gs_wbs TYPE ty_final.
169
170    DATA : gt_final1 TYPE STANDARD TABLE OF ty_final,
171           gs_final1 TYPE ty_final.
172
173    DATA : gt_final2 TYPE STANDARD TABLE OF ty_final,
174           gs_final2 TYPE ty_final.
175
176    DATA : gt_finaltot TYPE STANDARD TABLE OF ty_final,
177           gs_finaltot TYPE ty_final.
178
179    DATA : var  TYPE char50,
180           len  TYPE i,
181           var1 TYPE char1.
182
183    DATA : v_first LIKE sy-datum,
184           v_last  LIKE sy-datum.
185    DATA : lv_fiscal TYPE char4.
186    DATA : lv_fd TYPE t009b-bdatj.
187
188    TYPES : BEGIN OF ty_month,
189              month TYPE monat,
190              text  TYPE makt-maktx,
191            END OF ty_month.
192
193    DATA : lt_read  TYPE STANDARD TABLE OF dynpread,
194           ls_read  TYPE dynpread,
195           lt_month TYPE TABLE OF ty_month,
196           ls_month TYPE ty_month.
197
198    DATA : gt_faglflext TYPE STANDARD TABLE OF faglflext,
199           gs_faglflext TYPE faglflext.
200
201    DATA : gt_faglflext1 TYPE STANDARD TABLE OF faglflext,
202           gs_faglflext1 TYPE faglflext.
203
204    TYPES : BEGIN OF ty_prps,
205              pspnr TYPE ps_posnr,
206              pbukr TYPE ps_pbukr,
207              pkokr TYPE ps_pkokr,
208              posid TYPE ps_posid,  "ADED DISHA JOSHI  14/09/2018
209              objnr TYPE j_objnr ,  "ADED DISHA JOSHI  14/09/2018
210            END OF ty_prps.
211
212    DATA : gt_prps TYPE STANDARD TABLE OF ty_prps,
213           gs_prps TYPE ty_prps.
214
215    TYPES : BEGIN OF ty_tka02,
216              bukrs TYPE bukrs,
217              gsber TYPE gsber,
218              kokrs TYPE setsubcls,
219    *          KOKRS TYPE tka02-KOKRS,
220            END OF ty_tka02,
221
222            BEGIN OF ty_setleaf,
223              setclass TYPE setclass,
224              subclass TYPE setsubcls,
225              setname  TYPE setnamenew,
226              valfrom  TYPE setleaf-valfrom,
227    *          LINEID   TYPE SETLINE,
228            END OF ty_setleaf.
229
230
231    DATA : gt_tka02 TYPE STANDARD TABLE OF ty_tka02,
232           gs_tka02 TYPE ty_tka02.
233
234    DATA : gt_setleaf TYPE STANDARD TABLE OF ty_setleaf,
235           gs_setleaf TYPE ty_setleaf.
236    DATA : gt_setleaf2 TYPE STANDARD TABLE OF ty_setleaf,
237           gs_setleaf2 TYPE ty_setleaf.
238    DATA : gt_setleaf3 TYPE STANDARD TABLE OF ty_setleaf,
239           gs_setleaf3 TYPE ty_setleaf.
240    DATA : gt_setleaf4 TYPE STANDARD TABLE OF ty_setleaf,
241           gs_setleaf4 TYPE ty_setleaf.
242
243
244
245    *****************************Added By Rahul Gupta**************************************
246    DATA : gt_setleaf5 TYPE STANDARD TABLE OF setleaf,
247           gs_setleaf5 TYPE setleaf.
248    DATA : gt_setleaf6 TYPE STANDARD TABLE OF setleaf,
249           gs_setleaf6 TYPE setleaf.
250    DATA : gt_setleaf7 TYPE STANDARD TABLE OF setleaf,
251           gs_setleaf7 TYPE setleaf.
252    DATA : gt_setleaf8 TYPE STANDARD TABLE OF setleaf,
253           gs_setleaf8 TYPE setleaf.
254
255
256    ******************************ADDED By Disha Joshi 14/09/2018**************************************************
257
258    TYPES : BEGIN OF ty_v_prpmp,
259              postu TYPE ps_postu,
260              post1 TYPE ps_post1,
261              poski TYPE ps_poski,
262              pspnr TYPE ps_posnr,
263
264              posid TYPE ps_posid,
265              pspid TYPE ps_pspid,
266            END OF ty_v_prpmp,
267
268    *        BEGIN OF ty_PRPS,
269    *        PSPNR  TYPE PS_POSNR,
270    *        POSID  TYPE PS_POSID,
271    *        END OF ty_PRPS,
272
273            BEGIN OF ty_coep,
274              kokrs  TYPE kokrs,
275              belnr  TYPE co_belnr,
276              buzei  TYPE co_buzei,
277              kstar  TYPE kstar,
278              wogbtr TYPE wogxxx,
279              wkgbtr TYPE wkgxxx,
280              objnr  TYPE j_objnr,
281
282            END OF ty_coep.
283
284    TYPES : BEGIN OF ty_coep1,
285              kstar  TYPE kstar,
286              wogbtr TYPE wogxxx,
287              wkgbtr TYPE wkgxxx,
288            END OF ty_coep1,
289
290            BEGIN OF ty_csks,
291              kokrs TYPE kokrs,
292              kostl TYPE kostl,
293              objnr TYPE j_objnr,
294            END OF ty_csks,
295
296            BEGIN OF ty_tka02_1,
297              bukrs TYPE bukrs,
298              gsber TYPE gsber,
299    *          KOKRS TYPE SETSUBCLS,
300              kokrs TYPE tka02-kokrs,
301            END OF ty_tka02_1,
302
303            BEGIN OF ty_cska,
304              ktopl TYPE ktopl,
305              kstar TYPE kstar,
306            END OF ty_cska.
307
308    DATA : gt_v_prpmp  TYPE STANDARD TABLE OF ty_v_prpmp,
309           gt_v_prpmp1 TYPE STANDARD TABLE OF ty_v_prpmp,
310           gs_v_prpmp  TYPE                   ty_v_prpmp,
311    *        gt_PRPS    TYPE STANDARD TABLE OF ty_PRPS,
312    *        gs_PRPS    TYPE                   ty_PRPS,
313           gt_coep     TYPE STANDARD TABLE OF ty_coep,
314           gt_coep1    TYPE STANDARD TABLE OF ty_coep1,
315           gs_coep     TYPE                   ty_coep,
316           gs_coep1    TYPE                   ty_coep1,
317           gt_coep2    TYPE STANDARD TABLE OF ty_coep,
318           gt_coepq2   TYPE STANDARD TABLE OF ty_coep,
319           gt_coepq3   TYPE STANDARD TABLE OF ty_coep,
320           gt_coepq4   TYPE STANDARD TABLE OF ty_coep,
321           gt_coep3    TYPE STANDARD TABLE OF ty_coep1,
322           gt_coep3q2  TYPE STANDARD TABLE OF ty_coep1,
323           gt_coep3q3  TYPE STANDARD TABLE OF ty_coep1,
324           gt_coep3q4  TYPE STANDARD TABLE OF ty_coep1,
325           gs_coep2    TYPE                   ty_coep,
326           gs_coepq2   TYPE                   ty_coep,
327           gs_coepq3   TYPE                   ty_coep,
328           gs_coepq4   TYPE                   ty_coep,
329           gs_coep3    TYPE                   ty_coep1,
330           gs_coep3q2  TYPE                   ty_coep1,
331           gs_coep3q3  TYPE                   ty_coep1,
332           gs_coep3q4  TYPE                   ty_coep1,
333           gt_csks     TYPE STANDARD TABLE OF ty_csks,
334           gs_csks     TYPE                   ty_csks,
335           gt_csks2    TYPE STANDARD TABLE OF ty_csks,
336           gs_csks2    TYPE                   ty_csks,
337           gt_csks3    TYPE STANDARD TABLE OF ty_csks,
338           gs_csks3    TYPE                   ty_csks,
339           gt_csks4    TYPE STANDARD TABLE OF ty_csks,
340           gs_csks4    TYPE                   ty_csks,
341           gt_tka02_1  TYPE STANDARD TABLE OF ty_tka02_1,
342           gs_tka02_1  TYPE                   ty_tka02_1,
343           gt_cska     TYPE STANDARD TABLE OF ty_cska,
344           gs_cska     TYPE                   ty_cska.
345
346
347    DATA : lv_hkont TYPE hkont.
348    RANGES: r_pspnr FOR prps-posid,
349            r_perio1 FOR bkpf-monat,
350            r_perio2 FOR bkpf-monat,
351            r_perio3 FOR bkpf-monat,
352            r_perio4 FOR bkpf-monat.
353
354    RANGES: r_gl1 FOR faglflext-racct,
355            r_gl2 FOR faglflext-racct,
356            r_gl3 FOR faglflext-racct,
357            r_gl4 FOR faglflext-racct.
358
359    DATA: n TYPE i,
360          s TYPE i.
361    DATA :  documentheader       TYPE bapiache09." OCCURS 0 WITH HEADER  LINE.
362    DATA :  obj_type             TYPE bapiache09-obj_type.
363    DATA :  obj_key              TYPE bapiache09-obj_key.
364    DATA :  obj_sys              TYPE bapiache09-obj_sys.
365    DATA :  wa_accountgl         TYPE bapiacgl09.
366    DATA :  wa_accountreceivable TYPE bapiacar09.
367    DATA :  wa_accountpayable    TYPE bapiacap09.
368    DATA :  wa_currencyamount    TYPE bapiaccr09.
369    DATA :  return               TYPE bapiret2   OCCURS 0 WITH HEADER LINE.
370    DATA :  accountgl            TYPE bapiacgl09 OCCURS 0 WITH HEADER LINE.
371    DATA :  accountreceivable    TYPE bapiacar09 OCCURS 0 WITH HEADER LINE.
372    DATA :  accountpayable       TYPE bapiacap09 OCCURS 0 WITH HEADER LINE.
373    DATA :  currencyamount       TYPE bapiaccr09 OCCURS 0 WITH HEADER LINE.
374    DATA :  it_accountgl         TYPE STANDARD TABLE OF bapiacgl09.
375    DATA : counter_bapi TYPE posnr_acc.
376    DATA :  it_currencyamount    TYPE STANDARD TABLE OF bapiaccr09.
377
378    TYPES : BEGIN OF ty_display,
379              type       TYPE bapi_mtype,
380              id         TYPE symsgid,
381              number     TYPE symsgno,
382              message    TYPE bapi_msg,
383              log_no     TYPE balognr,
384              log_msg_no TYPE balmnr,
385              message_v1 TYPE symsgv,
386              message_v2 TYPE symsgv,
387              message_v3 TYPE symsgv,
388              message_v4 TYPE symsgv,
389              parameter  TYPE bapi_param,
390              row        TYPE bapi_line,
391              field      TYPE bapi_fld,
392              system     TYPE bapilogsys,
393            END OF ty_display.
394
395    DATA : gt_display  TYPE STANDARD TABLE OF esp1_message_wa_type,
396           gs_display  TYPE esp1_message_wa_type,
397           gt_display1  TYPE STANDARD TABLE OF esp1_message_wa_type,
398           gs_display1  TYPE esp1_message_wa_type,
399           wa_post TYPE ZFI_FCTR_DOC,
400           it_post TYPE TABLE OF ZFI_FCTR_DOC,
401           p_poper TYPE poper.
402    ******************************ENDED By Disha Joshi 14/09/2018**************************************************
*--- End of ZFI_FCTR_RPT_POST_DD - 402 lines ---

----------------------------------------------------------------------------------------------------
Include          ZFI_FCTR_RPT_POST_SS                      Level 1    Page 3
Object           ZFI_FCTR_RPT_POST                         Lines 961
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:09
----------------------------------------------------------------------------------------------------
1      SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
2      PARAMETERS : p_bukrs TYPE faglflext-rbukrs.
3      PARAMETERS : p_year TYPE faglflext-ryear OBLIGATORY.
4      SELECT-OPTIONS : s_gl FOR faglflext-racct OBLIGATORY.
5      SELECT-OPTIONS : s_period FOR bkpf-monat OBLIGATORY NO-EXTENSION .
6      PARAMETERS : p_ledger TYPE faglflext-rldnr DEFAULT '0L'.
7      PARAMETERS : p_budat TYPE datum DEFAULT sy-datum.
8
9      SELECTION-SCREEN END OF BLOCK b1.
10     SELECT-OPTIONS : s_kokrs FOR tka02-kokrs NO INTERVALS NO-EXTENSION MODIF ID gre .
11     SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-002.
12     *DATA: ch TYPE c LENGTH 25.
13     SELECT-OPTIONS : s_pspid FOR v_prpmp-pspid NO INTERVALS NO-EXTENSION MODIF ID gre .
14     *                 s_pspnr FOR prps-pspnr.
15     SELECTION-SCREEN END OF BLOCK b2.
16
17     SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE text-003.
18     SELECT-OPTIONS : s_senm FOR setleaf-setname NO INTERVALS NO-EXTENSION  MODIF ID q1,
19     ******************************Cheged Code Disha Joshi 12/09/2018************************************
20                      s_kokr FOR csks-kostl MODIF ID q1,
21     *                 S_KOS  FOR CSKS-KOSTL,
22                      s_secls FOR setleaf-setname NO INTERVALS NO-EXTENSION  MODIF ID q1,
23                      s_ktop FOR cska-kstar MODIF ID q1.
24     ******************************Change Code Disha Joshi 18/09/2018*************************************
25     *SELECT-OPTIONS : S_KOS FOR CSKS-KOSTL ,
26
27     SELECTION-SCREEN END OF BLOCK b3.
28
29
30     SELECTION-SCREEN BEGIN OF BLOCK b4 WITH FRAME TITLE text-004.
31     SELECT-OPTIONS : s_senm1 FOR setleaf-setname NO INTERVALS NO-EXTENSION MODIF ID q2,
32     ******************************Cheged Code Disha Joshi 12/09/2018************************************
33                      s_kokr1 FOR csks-kostl MODIF ID q2,
34     *                 S_KOS  FOR CSKS-KOSTL,
35                      s_secls1 FOR setleaf-setname NO INTERVALS NO-EXTENSION MODIF ID q2,
36                      s_ktop1 FOR cska-kstar MODIF ID q2.
37     ******************************Change Code Disha Joshi 18/09/2018*************************************
38     *SELECT-OPTIONS : S_KOS FOR CSKS-KOSTL ,
39
40     SELECTION-SCREEN END OF BLOCK b4.
41
42
43     SELECTION-SCREEN BEGIN OF BLOCK b5 WITH FRAME TITLE text-005.
44     SELECT-OPTIONS : s_senm2 FOR setleaf-setname NO INTERVALS NO-EXTENSION MODIF ID q3,
45     ******************************Cheged Code Disha Joshi 12/09/2018************************************
46                      s_kokr2 FOR csks-kostl MODIF ID q3,
47     *                 S_KOS  FOR CSKS-KOSTL,
48                      s_secls2 FOR setleaf-setname NO INTERVALS NO-EXTENSION MODIF ID q3,
49                      s_ktop2 FOR cska-kstar MODIF ID q3.
50     ******************************Change Code Disha Joshi 18/09/2018*************************************
51     *SELECT-OPTIONS : S_KOS FOR CSKS-KOSTL ,
52
53     SELECTION-SCREEN END OF BLOCK b5.
54
55
56     SELECTION-SCREEN BEGIN OF BLOCK b6 WITH FRAME TITLE text-006.
57     SELECT-OPTIONS : s_senm3 FOR setleaf-setname NO INTERVALS NO-EXTENSION  MODIF ID q4,
58     ******************************Cheged Code Disha Joshi 12/09/2018************************************
59                      s_kokr3 FOR csks-kostl MODIF ID q4,
60     *                 S_KOS  FOR CSKS-KOSTL,
61                      s_secls3 FOR setleaf-setname NO INTERVALS NO-EXTENSION  MODIF ID q4,
62                      s_ktop3 FOR cska-kstar MODIF ID q4.
63     ******************************Change Code Disha Joshi 18/09/2018*************************************
64     *SELECT-OPTIONS : S_KOS FOR CSKS-KOSTL ,
65
66     SELECTION-SCREEN END OF BLOCK b6.
67
68
69     AT SELECTION-SCREEN OUTPUT.
70
71       CLEAR: s_kokrs, s_pspid.
72       REFRESH: s_kokrs, s_pspid.
73
74       s_kokrs-sign = 'I'.
75       s_kokrs-option = 'EQ'.
76       s_pspid-sign = 'I'.
77       s_pspid-option = 'EQ'.
78       s_pspid-low = 'OV*'.
79       APPEND s_pspid.
80       SELECT *
81         FROM tka02
82         INTO CORRESPONDING FIELDS OF TABLE gt_tka02
83     *  WHERE BUKRS = S_KOKRS.
84          WHERE bukrs = p_bukrs.
85     " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
86       READ TABLE gt_tka02 INTO gs_tka02 INDEX 1. "#EC CI_NOORDER
87     " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
88       IF sy-subrc = 0.
89         s_kokrs-low = gs_tka02-kokrs.
90         APPEND s_kokrs.
91       ENDIF.
92
93
94       n = 1.
95
96         LOOP AT SCREEN.
97     *    IF screen-name = 'S_PERIOD-LOW'.
98     *      screen-input = '0'.
99     *    ENDIF.
100        IF screen-name = 'S_PSPID-LOW'.
101          screen-input = '0'.
102        ENDIF.
103        MODIFY SCREEN.
104        IF screen-group1 = 'GRE'.
105          screen-input = 0.
106          MODIFY SCREEN.
107        ENDIF.
108        IF screen-group1 = 'Q4'.
109    *      IF s_period-high < 10.
110          if  s_period-low ne '10' and s_period-high ne '12'.
111            screen-invisible = 0.
112            screen-active = 0.
113            MODIFY SCREEN.
114            n = 4.
115          ENDIF.
116        ENDIF.
117        IF screen-group1 = 'Q2'.
118    *      IF s_period-high < 4.
119            if  s_period-low ne '04' and s_period-high ne '06'.
120            screen-invisible = 0.
121            screen-active = 0.
122            MODIFY SCREEN.
123            n = 2.
124          ENDIF.
125        ENDIF.
126        IF screen-group1 = 'Q1'.
127    *      IF s_period-high < 1.
128            if  s_period-low ne '01' and s_period-high ne '03'.
129            screen-invisible = 0.
130            screen-active = 0.
131            MODIFY SCREEN.
132            n = 1.
133          ENDIF.
134        ENDIF.
135        IF screen-group1 = 'Q3'.
136    *      IF s_period-high < 7.
137            if  s_period-low ne '07' and s_period-high ne '09'.
138            screen-invisible = '0'.
139            screen-active = 0.
140            MODIFY SCREEN.
141            n = 3.
142          ENDIF.
143        ENDIF.
144
145      ENDLOOP.
146
147    *  LOOP AT SCREEN.
148    **    IF screen-name = 'S_PERIOD-LOW'.
149    **      screen-input = '0'.
150    **    ENDIF.
151    *    IF screen-name = 'S_PSPID-LOW'.
152    *      screen-input = '0'.
153    *    ENDIF.
154    *    MODIFY SCREEN.
155    *    IF screen-group1 = 'GRE'.
156    *      screen-input = 0.
157    *      MODIFY SCREEN.
158    *    ENDIF.
159    *
160    **        IF screen-group1 = 'Q4'.
161    ***      IF s_period-high < 10.
162    **        screen-invisible = 0.
163    **        screen-active = 0.
164    **        MODIFY SCREEN.
165    ***        n = 4.
166    ***      ENDIF.
167    **    ENDIF.
168    **    IF screen-group1 = 'Q2'.
169    ***      IF s_period-high < 4.
170    **        screen-invisible = 0.
171    **        screen-active = 0.
172    **        MODIFY SCREEN.
173    ***        n = 2.
174    ***      ENDIF.
175    **    ENDIF.
176    **    IF screen-group1 = 'Q1'.
177    ***      IF s_period-high < 1.
178    **        screen-invisible = 0.
179    **        screen-active = 0.
180    **        MODIFY SCREEN.
181    ***        n = 1.
182    ***      ENDIF.
183    **    ENDIF.
184    **    IF screen-group1 = 'Q3'.
185    ***      IF s_period-high < 7.
186    **        screen-invisible = '0'.
187    **        screen-active = 0.
188    **        MODIFY SCREEN.
189    ***        n = 3.
190    ***      ENDIF.
191    **    ENDIF.
192    *
193    *    IF screen-group1 = 'Q1'.
194    *
195    **      IF s_period-high < 10.
196    *    if  s_period-low eq '01' and s_period-high eq '03' and s_period-high is NOT INITIAL.
197    *        screen-invisible = 1.
198    *        screen-active = 1.
199    *        MODIFY SCREEN.
200    *        n = 1.
201    *        else.
202    *         screen-invisible = 0.
203    *        screen-active = 0.
204    *        MODIFY SCREEN.
205    *      ENDIF.
206    *    ENDIF.
207    *    IF screen-group1 = 'Q2'.
208    *  if  s_period-low eq '04' and s_period-high eq '06' and s_period-high is NOT INITIAL.
209    **      IF s_period-high < 4.
210    *        screen-invisible = 1.
211    *        screen-active = 1.
212    *        MODIFY SCREEN.
213    *        n = 2.
214    *          else.
215    *         screen-invisible = 0.
216    *        screen-active = 0.
217    *        MODIFY SCREEN.
218    *      ENDIF.
219    *    ENDIF.
220    *    IF screen-group1 = 'Q3'.
221    **      IF s_period-high < 1.
222    *    if  s_period-low eq '07' and s_period-high eq '09' and s_period-high is NOT INITIAL.
223    *        screen-invisible = 1.
224    *        screen-active = 1.
225    *        MODIFY SCREEN.
226    *        n = 1.
227    *        else.
228    **            else.
229    *         screen-invisible = 0.
230    *        screen-active = 0.
231    *        MODIFY SCREEN.
232    *      ENDIF.
233    *    ENDIF.
234    *    IF screen-group1 = 'Q4'.
235    *   if s_period-low eq '10' and s_period-high eq '12' and s_period-high is NOT INITIAL .
236    **      IF s_period-high < 7.
237    *        screen-invisible = 1.
238    *        screen-active = 1.
239    *        MODIFY SCREEN.
240    *        n = 3.
241    *        else.
242    **            else.
243    *         screen-invisible = 0.
244    *        screen-active = 0.
245    *        MODIFY SCREEN.
246    *      ENDIF.
247    *    ENDIF.
248    *
249    *  ENDLOOP.
250
251
252
253    *AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_pspnr-low.
254    *
255    *  SELECT pspnr pbukr pkokr posid
256    *    FROM prps
257    *    INTO CORRESPONDING FIELDS OF TABLE gt_prps
258    *    WHERE pbukr = 'OVL'
259    *      AND pkokr = 'OVL'
260    *      AND posid IN s_pspid
261    *    .
262    *
263    *  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
264    *    EXPORTING
265    *      retfield        = 'PSPNR'
266    *      dynpprog        = sy-repid
267    *      dynpnr          = sy-dynnr "'1000'
268    *      dynprofield     = 'S_PSPNR-LOW'
269    *      value_org       = 'S'
270    *    TABLES
271    *      value_tab       = gt_prps
272    *    EXCEPTIONS
273    *      parameter_error = 1
274    *      no_values_found = 2
275    *      OTHERS          = 3.
276    *
277    *AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_pspnr-high.
278    *
279    *  SELECT pspnr pbukr pkokr
280    *    FROM prps
281    *    INTO CORRESPONDING FIELDS OF TABLE gt_prps
282    *    WHERE pbukr = 'OVL'
283    *      AND pkokr = 'OVL'
284    *      AND posid IN s_pspid
285    *    .
286    *  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
287    *    EXPORTING
288    *      retfield        = 'PSPNR'
289    *      dynpprog        = sy-repid
290    *      dynpnr          = sy-dynnr "'1000'
291    *      dynprofield     = 'S_PSPNR-HIGH'
292    *      value_org       = 'S'
293    *    TABLES
294    *      value_tab       = gt_prps
295    *    EXCEPTIONS
296    *      parameter_error = 1
297    *      no_values_found = 2
298    *      OTHERS          = 3.
299
300
301    ******************************* Code Added By Disha Joshi 12/09/2018*********************
302
303    AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_senm-low.
304
305
306      IF p_bukrs IS INITIAL.
307        REFRESH lt_read[].
308        CONSTANTS: lc_11 TYPE i VALUE 11.
309        ls_read-fieldname = 'P_BUKRS'.
310        APPEND ls_read TO lt_read.
311        CALL FUNCTION 'DYNP_VALUES_READ'
312          EXPORTING
313            dyname               = sy-cprog
314            dynumb               = sy-dynnr
315          TABLES
316            dynpfields           = lt_read
317          EXCEPTIONS
318            invalid_abapworkarea = 1
319            invalid_dynprofield  = 2
320            invalid_dynproname   = 3
321            invalid_dynpronummer = 4
322            invalid_request      = 5
323            no_fielddescription  = 6
324            invalid_parameter    = 7
325            undefind_error       = 8
326            double_conversion    = 9
327            stepl_not_found      = 10
328            OTHERS               = lc_11 ##FM_SUBRC_OK.
329        READ TABLE lt_read INTO ls_read INDEX 1.
330        p_bukrs = to_upper( ls_read-fieldvalue ).
331      ENDIF.
332
333
334      SELECT *
335      FROM tka02
336      INTO CORRESPONDING FIELDS OF TABLE gt_tka02
337    *  WHERE BUKRS = S_KOKRS.
338       WHERE bukrs = p_bukrs.
339
340      IF gt_tka02 IS NOT INITIAL.
341        SELECT setclass subclass setname
342           FROM setleaf
343           INTO CORRESPONDING FIELDS OF TABLE gt_setleaf
344           FOR ALL ENTRIES IN gt_tka02
345           WHERE setclass = '0101'
346           AND   subclass = gt_tka02-kokrs.
347        IF gt_setleaf IS   NOT INITIAL.
348          SORT gt_setleaf BY setclass subclass setname.
349          DELETE ADJACENT DUPLICATES FROM gt_setleaf.
350        ENDIF.
351      ENDIF.
352
353
354
355
356      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
357        EXPORTING
358          retfield        = 'SETNAME'
359          dynpprog        = sy-repid
360          dynpnr          = sy-dynnr "'1000'
361          dynprofield     = 'S_SENM'
362          value_org       = 'S'
363        TABLES
364          value_tab       = gt_setleaf
365        EXCEPTIONS
366          parameter_error = 1
367          no_values_found = 2
368          OTHERS          = 3.
369    *  ******************************* Code Ended By Disha Joshi 12/09/2018*********************
370
371
372
373    AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_senm1-low.
374      IF p_bukrs IS INITIAL.
375        REFRESH lt_read[].
376        CONSTANTS: lc_11 TYPE i VALUE 11.
377        ls_read-fieldname = 'P_BUKRS'.
378        APPEND ls_read TO lt_read.
379        CALL FUNCTION 'DYNP_VALUES_READ'
380          EXPORTING
381            dyname               = sy-cprog
382            dynumb               = sy-dynnr
383          TABLES
384            dynpfields           = lt_read
385          EXCEPTIONS
386            invalid_abapworkarea = 1
387            invalid_dynprofield  = 2
388            invalid_dynproname   = 3
389            invalid_dynpronummer = 4
390            invalid_request      = 5
391            no_fielddescription  = 6
392            invalid_parameter    = 7
393            undefind_error       = 8
394            double_conversion    = 9
395            stepl_not_found      = 10
396            OTHERS               = lc_11 ##FM_SUBRC_OK.
397        READ TABLE lt_read INTO ls_read INDEX 1.
398        p_bukrs = to_upper( ls_read-fieldvalue ).
399      ENDIF.
400      SELECT *
401      FROM tka02
402      INTO CORRESPONDING FIELDS OF TABLE gt_tka02
403    *  WHERE BUKRS = S_KOKRS.
404       WHERE bukrs = p_bukrs.
405
406      IF gt_tka02 IS NOT INITIAL.
407        SELECT setclass subclass setname
408           FROM setleaf
409           INTO CORRESPONDING FIELDS OF TABLE gt_setleaf
410           FOR ALL ENTRIES IN gt_tka02
411           WHERE setclass = '0101'
412           AND   subclass = gt_tka02-kokrs.
413        IF gt_setleaf IS   NOT INITIAL.
414          SORT gt_setleaf BY setclass subclass setname.
415          DELETE ADJACENT DUPLICATES FROM gt_setleaf.
416        ENDIF.
417      ENDIF.
418
419
420
421
422      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
423        EXPORTING
424          retfield        = 'SETNAME'
425          dynpprog        = sy-repid
426          dynpnr          = sy-dynnr "'1000'
427          dynprofield     = 'S_SENM1'
428          value_org       = 'S'
429        TABLES
430          value_tab       = gt_setleaf
431        EXCEPTIONS
432          parameter_error = 1
433          no_values_found = 2
434          OTHERS          = 3.
435    *  ******************************* Code Ended By Disha Joshi 12/09/2018*********************
436
437
438    AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_senm2-low.
439      REFRESH lt_read[].
440      CONSTANTS: lc_11 TYPE i VALUE 11.
441      ls_read-fieldname = 'P_BUKRS'.
442      APPEND ls_read TO lt_read.
443      CALL FUNCTION 'DYNP_VALUES_READ'
444        EXPORTING
445          dyname               = sy-cprog
446          dynumb               = sy-dynnr
447        TABLES
448          dynpfields           = lt_read
449        EXCEPTIONS
450          invalid_abapworkarea = 1
451          invalid_dynprofield  = 2
452          invalid_dynproname   = 3
453          invalid_dynpronummer = 4
454          invalid_request      = 5
455          no_fielddescription  = 6
456          invalid_parameter    = 7
457          undefind_error       = 8
458          double_conversion    = 9
459          stepl_not_found      = 10
460          OTHERS               = lc_11 ##FM_SUBRC_OK.
461      READ TABLE lt_read INTO ls_read INDEX 1.
462      p_bukrs = to_upper( ls_read-fieldvalue ).
463      SELECT *
464      FROM tka02
465      INTO CORRESPONDING FIELDS OF TABLE gt_tka02
466    *  WHERE BUKRS = S_KOKRS.
467       WHERE bukrs = p_bukrs.
468
469      IF gt_tka02 IS NOT INITIAL.
470        SELECT setclass subclass setname
471           FROM setleaf
472           INTO CORRESPONDING FIELDS OF TABLE gt_setleaf
473           FOR ALL ENTRIES IN gt_tka02
474           WHERE setclass = '0101'
475           AND   subclass = gt_tka02-kokrs.
476        IF gt_setleaf IS   NOT INITIAL.
477          SORT gt_setleaf BY setclass subclass setname.
478          DELETE ADJACENT DUPLICATES FROM gt_setleaf.
479        ENDIF.
480      ENDIF.
481
482
483
484
485      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
486        EXPORTING
487          retfield        = 'SETNAME'
488          dynpprog        = sy-repid
489          dynpnr          = sy-dynnr "'1000'
490          dynprofield     = 'S_SENM2'
491          value_org       = 'S'
492        TABLES
493          value_tab       = gt_setleaf
494        EXCEPTIONS
495          parameter_error = 1
496          no_values_found = 2
497          OTHERS          = 3.
498    *  ******************************* Code Ended By Disha Joshi 12/09/2018*********************
499
500
501    AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_senm3-low.
502      IF p_bukrs IS INITIAL.
503        REFRESH lt_read[].
504        CONSTANTS: lc_11 TYPE i VALUE 11.
505        ls_read-fieldname = 'P_BUKRS'.
506        APPEND ls_read TO lt_read.
507        CALL FUNCTION 'DYNP_VALUES_READ'
508          EXPORTING
509            dyname               = sy-cprog
510            dynumb               = sy-dynnr
511          TABLES
512            dynpfields           = lt_read
513          EXCEPTIONS
514            invalid_abapworkarea = 1
515            invalid_dynprofield  = 2
516            invalid_dynproname   = 3
517            invalid_dynpronummer = 4
518            invalid_request      = 5
519            no_fielddescription  = 6
520            invalid_parameter    = 7
521            undefind_error       = 8
522            double_conversion    = 9
523            stepl_not_found      = 10
524            OTHERS               = lc_11 ##FM_SUBRC_OK.
525        READ TABLE lt_read INTO ls_read INDEX 1.
526        p_bukrs = to_upper( ls_read-fieldvalue ).
527      ENDIF.
528      SELECT *
529      FROM tka02
530      INTO CORRESPONDING FIELDS OF TABLE gt_tka02
531    *  WHERE BUKRS = S_KOKRS.
532       WHERE bukrs = p_bukrs.
533
534      IF gt_tka02 IS NOT INITIAL.
535        SELECT setclass subclass setname
536           FROM setleaf
537           INTO CORRESPONDING FIELDS OF TABLE gt_setleaf
538           FOR ALL ENTRIES IN gt_tka02
539           WHERE setclass = '0101'
540           AND   subclass = gt_tka02-kokrs.
541        IF gt_setleaf IS   NOT INITIAL.
542          SORT gt_setleaf BY setclass subclass setname.
543          DELETE ADJACENT DUPLICATES FROM gt_setleaf.
544        ENDIF.
545      ENDIF.
546
547
548
549
550      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
551        EXPORTING
552          retfield        = 'SETNAME'
553          dynpprog        = sy-repid
554          dynpnr          = sy-dynnr "'1000'
555          dynprofield     = 'S_SENM3'
556          value_org       = 'S'
557        TABLES
558          value_tab       = gt_setleaf
559        EXCEPTIONS
560          parameter_error = 1
561          no_values_found = 2
562          OTHERS          = 3.
563    *  ******************************* Code Ended By Disha Joshi 12/09/2018*********************
564
565
566    AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_ktop-low.
567    *
568    *  SELECT *
569    *  FROM TKA02
570    *  INTO CORRESPONDING FIELDS OF TABLE GT_TKA02
571    **  WHERE BUKRS = S_KOKRS.
572    *   WHERE BUKRS = P_BUKRS.
573
574    *  IF GT_TKA02 IS NOT INITIAL.
575      SELECT ktopl kstar
576         FROM cska
577         INTO TABLE gt_cska
578         WHERE ktopl = 'ONGC'.
579
580    *    IF GT_SETLEAF IS   NOT INITIAL.
581    *      SORT GT_SETLEAF BY SETCLASS SUBCLASS SETNAME.
582    *      DELETE ADJACENT DUPLICATES FROM GT_SETLEAF.
583    *    ENDIF.
584    *  ENDIF.
585
586      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
587        EXPORTING
588          retfield        = 'KSTAR'
589          dynpprog        = sy-repid
590          dynpnr          = sy-dynnr "'1000'
591          dynprofield     = 'S_KTOP'
592          value_org       = 'S'
593        TABLES
594          value_tab       = gt_cska
595        EXCEPTIONS
596          parameter_error = 1
597          no_values_found = 2
598          OTHERS          = 3.
599
600
601    *********************  COde added by Rahul Gupta  **********************
602    AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_ktop-high.
603    *
604    *  SELECT *
605    *  FROM TKA02
606    *  INTO CORRESPONDING FIELDS OF TABLE GT_TKA02
607    **  WHERE BUKRS = S_KOKRS.
608    *   WHERE BUKRS = P_BUKRS.
609
610    *  IF GT_TKA02 IS NOT INITIAL.
611      SELECT ktopl kstar
612         FROM cska
613         INTO TABLE gt_cska
614         WHERE ktopl = 'ONGC'.
615
616    *    IF GT_SETLEAF IS   NOT INITIAL.
617    *      SORT GT_SETLEAF BY SETCLASS SUBCLASS SETNAME.
618    *      DELETE ADJACENT DUPLICATES FROM GT_SETLEAF.
619    *    ENDIF.
620    *  ENDIF.
621
622      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
623        EXPORTING
624          retfield        = 'KSTAR'
625          dynpprog        = sy-repid
626          dynpnr          = sy-dynnr "'1000'
627          dynprofield     = 'S_KTOP'
628          value_org       = 'S'
629        TABLES
630          value_tab       = gt_cska
631        EXCEPTIONS
632          parameter_error = 1
633          no_values_found = 2
634          OTHERS          = 3.
635
636    AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_ktop1-low.
637    *
638    *  SELECT *
639    *  FROM TKA02
640    *  INTO CORRESPONDING FIELDS OF TABLE GT_TKA02
641    **  WHERE BUKRS = S_KOKRS.
642    *   WHERE BUKRS = P_BUKRS.
643
644    *  IF GT_TKA02 IS NOT INITIAL.
645      SELECT ktopl kstar
646         FROM cska
647         INTO TABLE gt_cska
648         WHERE ktopl = 'ONGC'.
649
650    *    IF GT_SETLEAF IS   NOT INITIAL.
651    *      SORT GT_SETLEAF BY SETCLASS SUBCLASS SETNAME.
652    *      DELETE ADJACENT DUPLICATES FROM GT_SETLEAF.
653    *    ENDIF.
654    *  ENDIF.
655
656      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
657        EXPORTING
658          retfield        = 'KSTAR'
659          dynpprog        = sy-repid
660          dynpnr          = sy-dynnr "'1000'
661          dynprofield     = 'S_KTOP'
662          value_org       = 'S'
663        TABLES
664          value_tab       = gt_cska
665        EXCEPTIONS
666          parameter_error = 1
667          no_values_found = 2
668          OTHERS          = 3.
669
670
671    *********************  COde added by Rahul Gupta  **********************
672    AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_ktop1-high.
673    *
674    *  SELECT *
675    *  FROM TKA02
676    *  INTO CORRESPONDING FIELDS OF TABLE GT_TKA02
677    **  WHERE BUKRS = S_KOKRS.
678    *   WHERE BUKRS = P_BUKRS.
679
680    *  IF GT_TKA02 IS NOT INITIAL.
681      SELECT ktopl kstar
682         FROM cska
683         INTO TABLE gt_cska
684         WHERE ktopl = 'ONGC'.
685
686    *    IF GT_SETLEAF IS   NOT INITIAL.
687    *      SORT GT_SETLEAF BY SETCLASS SUBCLASS SETNAME.
688    *      DELETE ADJACENT DUPLICATES FROM GT_SETLEAF.
689    *    ENDIF.
690    *  ENDIF.
691
692      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
693        EXPORTING
694          retfield        = 'KSTAR'
695          dynpprog        = sy-repid
696          dynpnr          = sy-dynnr "'1000'
697          dynprofield     = 'S_KTOP'
698          value_org       = 'S'
699        TABLES
700          value_tab       = gt_cska
701        EXCEPTIONS
702          parameter_error = 1
703          no_values_found = 2
704          OTHERS          = 3.
705
706    AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_ktop2-low.
707    *
708    *  SELECT *
709    *  FROM TKA02
710    *  INTO CORRESPONDING FIELDS OF TABLE GT_TKA02
711    **  WHERE BUKRS = S_KOKRS.
712    *   WHERE BUKRS = P_BUKRS.
713
714    *  IF GT_TKA02 IS NOT INITIAL.
715      SELECT ktopl kstar
716         FROM cska
717         INTO TABLE gt_cska
718         WHERE ktopl = 'ONGC'.
719
720    *    IF GT_SETLEAF IS   NOT INITIAL.
721    *      SORT GT_SETLEAF BY SETCLASS SUBCLASS SETNAME.
722    *      DELETE ADJACENT DUPLICATES FROM GT_SETLEAF.
723    *    ENDIF.
724    *  ENDIF.
725
726      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
727        EXPORTING
728          retfield        = 'KSTAR'
729          dynpprog        = sy-repid
730          dynpnr          = sy-dynnr "'1000'
731          dynprofield     = 'S_KTOP'
732          value_org       = 'S'
733        TABLES
734          value_tab       = gt_cska
735        EXCEPTIONS
736          parameter_error = 1
737          no_values_found = 2
738          OTHERS          = 3.
739
740
741    *********************  COde added by Rahul Gupta  **********************
742    AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_ktop2-high.
743    *
744    *  SELECT *
745    *  FROM TKA02
746    *  INTO CORRESPONDING FIELDS OF TABLE GT_TKA02
747    **  WHERE BUKRS = S_KOKRS.
748    *   WHERE BUKRS = P_BUKRS.
749
750    *  IF GT_TKA02 IS NOT INITIAL.
751      SELECT ktopl kstar
752         FROM cska
753         INTO TABLE gt_cska
754         WHERE ktopl = 'ONGC'.
755
756    *    IF GT_SETLEAF IS   NOT INITIAL.
757    *      SORT GT_SETLEAF BY SETCLASS SUBCLASS SETNAME.
758    *      DELETE ADJACENT DUPLICATES FROM GT_SETLEAF.
759    *    ENDIF.
760    *  ENDIF.
761
762      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
763        EXPORTING
764          retfield        = 'KSTAR'
765          dynpprog        = sy-repid
766          dynpnr          = sy-dynnr "'1000'
767          dynprofield     = 'S_KTOP'
768          value_org       = 'S'
769        TABLES
770          value_tab       = gt_cska
771        EXCEPTIONS
772          parameter_error = 1
773          no_values_found = 2
774          OTHERS          = 3.
775
776    AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_ktop3-low.
777    *
778    *  SELECT *
779    *  FROM TKA02
780    *  INTO CORRESPONDING FIELDS OF TABLE GT_TKA02
781    **  WHERE BUKRS = S_KOKRS.
782    *   WHERE BUKRS = P_BUKRS.
783
784    *  IF GT_TKA02 IS NOT INITIAL.
785      SELECT ktopl kstar
786         FROM cska
787         INTO TABLE gt_cska
788         WHERE ktopl = 'ONGC'.
789
790    *    IF GT_SETLEAF IS   NOT INITIAL.
791    *      SORT GT_SETLEAF BY SETCLASS SUBCLASS SETNAME.
792    *      DELETE ADJACENT DUPLICATES FROM GT_SETLEAF.
793    *    ENDIF.
794    *  ENDIF.
795
796      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
797        EXPORTING
798          retfield        = 'KSTAR'
799          dynpprog        = sy-repid
800          dynpnr          = sy-dynnr "'1000'
801          dynprofield     = 'S_KTOP'
802          value_org       = 'S'
803        TABLES
804          value_tab       = gt_cska
805        EXCEPTIONS
806          parameter_error = 1
807          no_values_found = 2
808          OTHERS          = 3.
809
810
811    *********************  COde added by Rahul Gupta  **********************
812    AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_ktop3-high.
813    *
814    *  SELECT *
815    *  FROM TKA02
816    *  INTO CORRESPONDING FIELDS OF TABLE GT_TKA02
817    **  WHERE BUKRS = S_KOKRS.
818    *   WHERE BUKRS = P_BUKRS.
819
820    *  IF GT_TKA02 IS NOT INITIAL.
821      SELECT ktopl kstar
822         FROM cska
823         INTO TABLE gt_cska
824         WHERE ktopl = 'ONGC'.
825
826    *    IF GT_SETLEAF IS   NOT INITIAL.
827    *      SORT GT_SETLEAF BY SETCLASS SUBCLASS SETNAME.
828    *      DELETE ADJACENT DUPLICATES FROM GT_SETLEAF.
829    *    ENDIF.
830    *  ENDIF.
831
832      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
833        EXPORTING
834          retfield        = 'KSTAR'
835          dynpprog        = sy-repid
836          dynpnr          = sy-dynnr "'1000'
837          dynprofield     = 'S_KTOP'
838          value_org       = 'S'
839        TABLES
840          value_tab       = gt_cska
841        EXCEPTIONS
842          parameter_error = 1
843          no_values_found = 2
844          OTHERS          = 3.
845
846    AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_secls-low.
847
848      SELECT setclass subclass setname
849         FROM setleaf
850         INTO CORRESPONDING FIELDS OF TABLE gt_setleaf
851         WHERE setclass = '0102'
852         AND   subclass = 'ONGC'.
853      IF gt_setleaf IS   NOT INITIAL.
854        SORT gt_setleaf BY setclass subclass setname.
855        DELETE ADJACENT DUPLICATES FROM gt_setleaf.
856      ENDIF.
857
858
859
860
861      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
862        EXPORTING
863          retfield        = 'SETNAME'
864          dynpprog        = sy-repid
865          dynpnr          = sy-dynnr "'1000'
866          dynprofield     = 'S_SECLS'
867          value_org       = 'S'
868        TABLES
869          value_tab       = gt_setleaf
870        EXCEPTIONS
871          parameter_error = 1
872          no_values_found = 2
873          OTHERS          = 3.
874
875    AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_secls1-low.
876
877      SELECT setclass subclass setname
878         FROM setleaf
879         INTO CORRESPONDING FIELDS OF TABLE gt_setleaf
880         WHERE setclass = '0102'
881         AND   subclass = 'ONGC'.
882      IF gt_setleaf IS   NOT INITIAL.
883        SORT gt_setleaf BY setclass subclass setname.
884        DELETE ADJACENT DUPLICATES FROM gt_setleaf.
885      ENDIF.
886
887
888
889
890      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
891        EXPORTING
892          retfield        = 'SETNAME'
893          dynpprog        = sy-repid
894          dynpnr          = sy-dynnr "'1000'
895          dynprofield     = 'S_SECLS'
896          value_org       = 'S'
897        TABLES
898          value_tab       = gt_setleaf
899        EXCEPTIONS
900          parameter_error = 1
901          no_values_found = 2
902          OTHERS          = 3.
903
904
905    AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_secls2-low.
906
907      SELECT setclass subclass setname
908         FROM setleaf
909         INTO CORRESPONDING FIELDS OF TABLE gt_setleaf
910         WHERE setclass = '0102'
911         AND   subclass = 'ONGC'.
912      IF gt_setleaf IS   NOT INITIAL.
913        SORT gt_setleaf BY setclass subclass setname.
914        DELETE ADJACENT DUPLICATES FROM gt_setleaf.
915      ENDIF.
916
917
918
919
920      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
921        EXPORTING
922          retfield        = 'SETNAME'
923          dynpprog        = sy-repid
924          dynpnr          = sy-dynnr "'1000'
925          dynprofield     = 'S_SECLS'
926          value_org       = 'S'
927        TABLES
928          value_tab       = gt_setleaf
929        EXCEPTIONS
930          parameter_error = 1
931          no_values_found = 2
932          OTHERS          = 3.
933
934    AT SELECTION-SCREEN ON VALUE-REQUEST FOR s_secls3-low.
935
936      SELECT setclass subclass setname
937         FROM setleaf
938         INTO CORRESPONDING FIELDS OF TABLE gt_setleaf
939         WHERE setclass = '0102'
940         AND   subclass = 'ONGC'.
941      IF gt_setleaf IS   NOT INITIAL.
942        SORT gt_setleaf BY setclass subclass setname.
943        DELETE ADJACENT DUPLICATES FROM gt_setleaf.
944      ENDIF.
945
946
947
948
949      CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
950        EXPORTING
951          retfield        = 'SETNAME'
952          dynpprog        = sy-repid
953          dynpnr          = sy-dynnr "'1000'
954          dynprofield     = 'S_SECLS'
955          value_org       = 'S'
956        TABLES
957          value_tab       = gt_setleaf
958        EXCEPTIONS
959          parameter_error = 1
960          no_values_found = 2
961          OTHERS          = 3.
*--- End of ZFI_FCTR_RPT_POST_SS - 961 lines ---

----------------------------------------------------------------------------------------------------
Include          ZFI_FCTR_RPT_POST_SUB                     Level 1    Page 4
Object           ZFI_FCTR_RPT_POST                         Lines 3708
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:09
----------------------------------------------------------------------------------------------------
1      *&---------------------------------------------------------------------*
2      *& Form GET_DATA
3      *&---------------------------------------------------------------------*
4      FORM get_data.
5        IF s_period-high IS INITIAL .
6          MESSAGE 'Please maintain period ' TYPE 'E'.
7        ENDIF.
8        SELECT gl_account znature zconvrsn fctr_gl
9        FROM zfi_fctr
10       INTO TABLE gt_fctr1
11       WHERE gl_account IN s_gl.
12       LOOP AT gt_fctr1 INTO gs_fctr1 WHERE zconvrsn IS INITIAL .
13         IF sy-subrc = 0.
14           gs_saknr-hkont = gs_fctr1-gl_account.
15           APPEND gs_saknr TO gt_saknr.
16           CLEAR : gs_saknr.
17         ENDIF.
18       ENDLOOP.
19
20       IF gt_saknr IS NOT INITIAL.
21         PERFORM alv_fieldcat_gl.
22         PERFORM get_event1.
23         PERFORM sub_comment_build_gl USING t_list_top_of_page.
24         PERFORM alv_display_gl.
25       ENDIF.
26       IF gt_saknr[] IS INITIAL.
27
28     *  **********************************************ADDED BY DISHA JOSHI 14/09/2018***********************************
29
30     *  **********************************************CHANGED & ADDED BY RAHUL GUPTA 15/10/2018***********************************
31         IF s_pspid IS NOT INITIAL.
32     *      SELECT postu post1 poski pspnr posid pspid
33     **  SELECT POSID PSPID
34     *        FROM v_prpmp
35     *        INTO TABLE gt_v_prpmp
36     *      WHERE pspid IN s_pspid.
37     *    ELSE.
38           SELECT postu post1 poski pspnr posid pspid
39     *  SELECT POSID PSPID
40             FROM v_prpmp
41             INTO TABLE gt_v_prpmp
42           WHERE pspid LIKE 'OV%'.
43         ENDIF.
44
45         IF gt_v_prpmp IS NOT INITIAL.
46     *    SELECT PSPNR PBUKR PKOKR POSID OBJNR
47           SORT gt_v_prpmp BY posid.
48
49
50           DELETE ADJACENT DUPLICATES FROM gt_v_prpmp COMPARING posid.
51     *      IF s_pspnr IS NOT INITIAL.
52     *        LOOP AT s_pspnr.
53     *          r_pspnr-sign = s_pspnr-sign.
54     *          r_pspnr-option = s_pspnr-option.
55     *          CALL FUNCTION 'CONVERSION_EXIT_ABPSP_OUTPUT'
56     *            EXPORTING
57     *              input  = s_pspnr-low
58     *            IMPORTING
59     *              output = r_pspnr-low.
60     **
61     *          CALL FUNCTION 'CONVERSION_EXIT_ABPSP_OUTPUT'
62     *            EXPORTING
63     *              input  = s_pspnr-high
64     *            IMPORTING
65     *              output = r_pspnr-high.
66     *          APPEND r_pspnr.
67     *        ENDLOOP.
68     *        SELECT pspnr pbukr pkokr posid objnr
69     *        FROM prps
70     *        INTO TABLE gt_prps
71     *        FOR ALL ENTRIES IN gt_v_prpmp
72     **          WHERE pspnr = gt_v_prpmp-pspnr
73     *         WHERE  posid = gt_v_prpmp-posid
74     *          AND pspnr IN r_pspnr.
75     *      ELSE.
76           SELECT pspnr pbukr pkokr posid objnr
77             FROM prps
78             INTO  TABLE gt_prps
79             FOR ALL ENTRIES IN gt_v_prpmp
80             WHERE posid = gt_v_prpmp-posid
81             AND pbukr = 'OVL'
82             AND pkokr = 'OVL'.
83     *      ENDIF.
84
85         ENDIF.
86         IF gt_prps IS NOT INITIAL.
87           SORT gt_prps BY objnr.
88           DELETE ADJACENT DUPLICATES FROM gt_prps COMPARING objnr.
89           SELECT kokrs belnr buzei kstar wogbtr wkgbtr objnr
90             FROM coep
91             INTO CORRESPONDING FIELDS OF TABLE gt_coep
92             FOR ALL ENTRIES IN gt_prps
93             WHERE objnr = gt_prps-objnr
94             AND kokrs IN s_kokrs
95             AND perio IN s_period
96             AND ( kstar IN s_gl AND kstar NOT LIKE '000022%' AND kstar NOT LIKE '000024%'  )
97             AND gjahr = p_year
98             AND lednr = '00'
99             AND wrttp NE '60'.
100        ENDIF.
101        IF gt_coep IS NOT INITIAL.
102          SORT gt_coep BY kstar.
103    **  BREAK-POINT.
104          LOOP AT gt_coep INTO gs_coep.
105            gs_coep1-kstar = gs_coep-kstar.
106    *        if  gs_coep ne '0000209999'.
107            gs_coep1-wkgbtr = gs_coep-wkgbtr.
108            gs_coep1-wogbtr = gs_coep-wogbtr.
109    *        ENDIF.
110            COLLECT gs_coep1 INTO gt_coep1.
111            CLEAR gs_coep1.
112          ENDLOOP.
113        ENDIF.
114
115    *   *********************************************ended bY disha JOSHI  14/09/2018***********************************
116    *************************************************ADDED BY RAHUL GUPTA***********************************************
117        IF  s_period-high <= 3.  "quarter 1
118          n = 1.
119          r_perio1-option = s_period-option.
120          r_perio1-sign = s_period-sign.
121          r_perio1-low = '1'.
122          r_perio1-high = s_period-high.
123          APPEND r_perio1.
124        ELSEIF s_period-high <= 6 . "quarter 2
125    **            for quarter 1
126          n = 2.
127          r_perio1-option = s_period-option.
128          r_perio1-sign = s_period-sign.
129          r_perio1-low = '1'.
130          r_perio1-high = '3'.
131          APPEND r_perio1.
132    **            for quarter 2
133          r_perio2-option = s_period-option.
134          r_perio2-sign = 'EQ'.
135          r_perio2-low = '4'.
136          IF s_period-high > 4.
137            r_perio2-sign = s_period-sign.
138            r_perio2-high = s_period-high.
139          ENDIF.
140          APPEND r_perio2.
141        ELSEIF  s_period-high <= 9.  "quarter 3
142    **            for quarter 1
143          n = 3.
144          r_perio1-option = s_period-option.
145          r_perio1-sign = s_period-sign.
146          r_perio1-low = '1'.
147          r_perio1-high = '3'.
148          APPEND r_perio1.
149    **            for quarter 2
150          r_perio2-option = s_period-option.
151          r_perio2-sign = s_period-sign.
152          r_perio2-low = '4'.
153          r_perio2-high = '6'.
154          APPEND r_perio2.
155    **            for quarter 3
156          r_perio3-option = s_period-option.
157          r_perio3-sign = 'EQ'.
158          r_perio3-low = '7'.
159          IF s_period-high > 7.
160            r_perio3-sign = s_period-sign.
161            r_perio3-high = s_period-high.
162          ENDIF.
163          APPEND r_perio3.
164        ELSE.  "quarter 4
165    **            for quarter 1
166          n = 4.
167          r_perio1-option = s_period-option.
168          r_perio1-sign = s_period-sign.
169          r_perio1-low = '1'.
170          r_perio1-high = '3'.
171          APPEND r_perio1.
172    **            for quarter 2
173          r_perio2-option = s_period-option.
174          r_perio2-low = '4'.
175          r_perio2-sign = s_period-sign.
176          r_perio2-high = '6'.
177          APPEND r_perio2.
178    **            for quarter 3
179          r_perio3-option = s_period-option.
180          r_perio3-low = '7'.
181          r_perio3-sign = s_period-sign.
182          r_perio3-high = '9'.
183          APPEND r_perio3.
184    **        for quarter 4
185          r_perio4-option = s_period-option.
186          r_perio4-sign = 'EQ'.
187          r_perio4-low = '10'.
188          IF s_period-high > 10.
189            r_perio4-sign = s_period-sign.
190            r_perio4-high = s_period-high.
191          ENDIF.
192          APPEND r_perio4.
193        ENDIF.
194
195        SELECT *
196         FROM tka02
197         INTO CORRESPONDING FIELDS OF TABLE gt_tka02
198    *  WHERE BUKRS = S_KOKRS.
199          WHERE bukrs = p_bukrs.
200    *********** For Quarter 1
201        IF gt_tka02 IS NOT INITIAL.
202          IF s_senm IS INITIAL.
203            SELECT kokrs kostl objnr
204               FROM csks
205               INTO TABLE gt_csks
206
207               WHERE kostl IN s_kokr
208               AND kokrs = p_bukrs.
209
210          ELSE.
211            SELECT setclass subclass setname valfrom
212                  FROM setleaf
213                  INTO TABLE gt_setleaf
214                  FOR ALL ENTRIES IN gt_tka02
215                  WHERE setname IN s_senm
216                  AND   subclass = gt_tka02-kokrs.
217    *        SELECT *
218    *            FROM setleaf
219    *            INTO TABLE gt_setleaf5
220    *            WHERE setname IN s_secls
221    *            AND   subclass = 'ONGC'.
222          ENDIF.
223
224
225          IF s_secls IS INITIAL.
226            REFRESH r_gl1.
227            LOOP AT s_ktop.
228              r_gl1-sign = s_ktop-sign.
229              r_gl1-option = s_ktop-option.
230              r_gl1-low = s_ktop-low.
231              r_gl1-high = s_ktop-high.
232              APPEND r_gl1.
233              CLEAR: r_gl1, gs_setleaf5.
234            ENDLOOP.
235
236          ELSE.
237            SELECT *
238            FROM setleaf
239            INTO TABLE gt_setleaf5
240            WHERE setname IN s_secls
241            AND   subclass = 'ONGC'.
242
243          ENDIF.
244          IF gt_setleaf IS   NOT INITIAL.
245            SORT gt_setleaf BY valfrom.
246            DELETE ADJACENT DUPLICATES FROM gt_setleaf.
247            SELECT kokrs kostl objnr
248              FROM csks
249              INTO TABLE gt_csks
250              FOR ALL ENTRIES IN gt_setleaf
251              WHERE kostl = gt_setleaf-valfrom+0(10)
252              AND kokrs = p_bukrs.
253          ENDIF.
254        ENDIF.
255        IF gt_setleaf5 IS NOT INITIAL.
256          REFRESH r_gl1[].
257          LOOP AT gt_setleaf5 INTO gs_setleaf5.
258            r_gl1-sign = gs_setleaf5-valsign.
259            r_gl1-option = gs_setleaf5-valoption.
260            r_gl1-low = gs_setleaf5-valfrom.
261            r_gl1-high = gs_setleaf5-valto.
262            APPEND r_gl1.
263            CLEAR: r_gl1, gs_setleaf5.
264          ENDLOOP.
265        ENDIF.
266
267        IF gt_csks IS NOT INITIAL.
268          SORT gt_csks BY objnr.
269          DELETE ADJACENT DUPLICATES FROM gt_csks COMPARING objnr.
270          SELECT kokrs belnr buzei kstar wogbtr wkgbtr objnr
271            FROM coep
272            INTO CORRESPONDING FIELDS OF TABLE gt_coep2
273            FOR ALL ENTRIES IN gt_csks
274            WHERE objnr = gt_csks-objnr
275            AND kokrs IN s_kokrs
276            AND perio IN r_perio1
277            AND ( kstar IN s_gl AND kstar NOT LIKE '000022%' AND kstar NOT LIKE '000024%' AND kstar IN r_gl1 )
278            AND gjahr = p_year
279            AND lednr = '00'
280            AND wrttp NE '60'.
281    *      SELECT kokrs belnr buzei kstar wogbtr wkgbtr objnr  """commented by hiren.
282    *      FROM coep
283    *      APPENDING TABLE gt_coep2
284    *      FOR ALL ENTRIES IN gt_csks
285    *      WHERE objnr = gt_csks-objnr
286    *      AND kokrs IN s_kokrs
287    *      AND perio IN r_perio1
288    *      AND ( kstar = '0000500120' OR kstar = '0000502010')
289    *      AND gjahr = p_year
290    *      AND lednr = '00'
291    *      .
292
293        ENDIF.
294        IF gt_coep2 IS NOT INITIAL.
295          SORT gt_coep2 BY kstar.
296    **  BREAK-POINT.
297          LOOP AT gt_coep2 INTO gs_coep2.
298            gs_coep3-kstar = gs_coep2-kstar.
299            gs_coep3-wkgbtr = gs_coep2-wkgbtr.
300            gs_coep3-wogbtr = gs_coep2-wogbtr.
301
302            COLLECT gs_coep3 INTO gt_coep3.
303            CLEAR gs_coep3.
304          ENDLOOP.
305        ENDIF.
306
307
308    *********** For Quarter 2
309        IF r_perio2 IS NOT INITIAL.
310          IF gt_tka02 IS NOT INITIAL.
311            IF s_senm1 IS INITIAL.
312              SELECT kokrs kostl objnr
313                 FROM csks
314                 INTO TABLE gt_csks2
315
316                 WHERE kostl IN s_kokr1
317                 AND kokrs = p_bukrs.
318
319            ELSE.
320              SELECT setclass subclass setname valfrom
321                    FROM setleaf
322                    INTO TABLE gt_setleaf2
323                    FOR ALL ENTRIES IN gt_tka02
324                    WHERE setname IN s_senm1
325                    AND   subclass = gt_tka02-kokrs.
326
327            ENDIF.
328
329            IF s_secls1 IS INITIAL.
330              REFRESH r_gl1.
331              LOOP AT s_ktop1.
332                r_gl1-sign = s_ktop1-sign.
333                r_gl1-option = s_ktop1-option.
334                r_gl1-low = s_ktop1-low.
335                r_gl1-high = s_ktop1-high.
336                APPEND r_gl1.
337                CLEAR: r_gl1, gs_setleaf5.
338              ENDLOOP.
339
340            ELSE.
341              SELECT *
342              FROM setleaf
343              INTO TABLE gt_setleaf5
344              WHERE setname IN s_secls1
345              AND   subclass = 'ONGC'.
346
347
348            ENDIF.
349
350
351
352            IF gt_setleaf2 IS   NOT INITIAL.
353              SORT gt_setleaf2 BY valfrom.
354              DELETE ADJACENT DUPLICATES FROM gt_setleaf2.
355              SELECT kokrs kostl objnr
356                FROM csks
357                INTO TABLE gt_csks2
358                FOR ALL ENTRIES IN gt_setleaf2
359                WHERE kostl = gt_setleaf2-valfrom+0(10)
360                AND kokrs = p_bukrs.
361            ENDIF.
362          ENDIF.
363
364
365
366          IF gt_setleaf5 IS NOT INITIAL.
367            REFRESH r_gl1.
368            LOOP AT gt_setleaf5 INTO gs_setleaf5.
369              r_gl1-sign = gs_setleaf5-valsign.
370              r_gl1-option = gs_setleaf5-valoption.
371              r_gl1-low = gs_setleaf5-valfrom.
372              r_gl1-high = gs_setleaf5-valto.
373              APPEND r_gl1.
374              CLEAR: r_gl1, gs_setleaf5.
375            ENDLOOP.
376          ENDIF.
377
378
379
380          IF gt_csks2 IS NOT INITIAL.
381            SORT gt_csks2 BY objnr.
382            DELETE ADJACENT DUPLICATES FROM gt_csks2 COMPARING objnr.
383            SELECT kokrs belnr buzei kstar wogbtr wkgbtr objnr
384              FROM coep
385              INTO CORRESPONDING FIELDS OF TABLE gt_coepq2
386              FOR ALL ENTRIES IN gt_csks2
387              WHERE objnr = gt_csks2-objnr
388              AND kokrs IN s_kokrs
389              AND perio IN r_perio2
390              AND ( kstar IN s_gl AND kstar NOT LIKE '000022%' AND kstar NOT LIKE '000024%' AND kstar IN r_gl1  )
391              AND gjahr = p_year
392              AND lednr = '00'
393              AND wrttp NE '60'.
394
395    *        SELECT kokrs belnr buzei kstar wogbtr wkgbtr objnr
396    *           FROM coep
397    *           APPENDING TABLE gt_coepq2
398    *           FOR ALL ENTRIES IN gt_csks
399    *           WHERE objnr = gt_csks-objnr
400    *           AND kokrs IN s_kokrs
401    *           AND perio IN r_perio1
402    *           AND ( kstar = '0000500120' OR kstar = '0000502010')
403    *           AND gjahr = p_year
404    *           AND lednr = '00'
405    *          AND wrttp ne '60'.
406
407
408          ENDIF.
409          IF gt_coepq2 IS NOT INITIAL.
410            SORT gt_coepq2 BY kstar.
411    **  BREAK-POINT.
412            LOOP AT gt_coepq2 INTO gs_coepq2.
413              gs_coep3q2-kstar = gs_coepq2-kstar.
414              gs_coep3q2-wkgbtr = gs_coepq2-wkgbtr.
415              gs_coep3q2-wogbtr = gs_coepq2-wogbtr.
416
417              COLLECT gs_coep3q2 INTO gt_coep3q2.
418              CLEAR gs_coep3q2.
419            ENDLOOP.
420          ENDIF.
421        ENDIF.
422
423
424    *********** For Quarter 3
425        IF r_perio3 IS NOT INITIAL.
426          IF gt_tka02 IS NOT INITIAL.
427            IF s_senm2 IS INITIAL.
428              SELECT kokrs kostl objnr
429                 FROM csks
430                 INTO TABLE gt_csks3
431
432                 WHERE kostl IN s_kokr2
433                 AND kokrs = p_bukrs.
434
435            ELSE.
436              SELECT setclass subclass setname valfrom
437                    FROM setleaf
438                    INTO TABLE gt_setleaf3
439                    FOR ALL ENTRIES IN gt_tka02
440                    WHERE setname IN s_senm2
441                    AND   subclass = gt_tka02-kokrs.
442
443    *          SELECT *
444    *          FROM setleaf
445    *          INTO TABLE gt_setleaf5
446    *          WHERE setname IN s_secls2
447    *          AND   subclass = 'ONGC'.
448
449            ENDIF.
450
451            IF s_secls2 IS INITIAL.
452              REFRESH r_gl1.
453              LOOP AT s_ktop2.
454                r_gl1-sign = s_ktop2-sign.
455                r_gl1-option = s_ktop2-option.
456                r_gl1-low = s_ktop2-low.
457                r_gl1-high = s_ktop2-high.
458                APPEND r_gl1.
459                CLEAR: r_gl1, gs_setleaf5.
460              ENDLOOP.
461
462            ELSE.
463              SELECT *
464              FROM setleaf
465              INTO TABLE gt_setleaf5
466              WHERE setname IN s_secls2
467              AND   subclass = 'ONGC'.
468
469            ENDIF.
470            IF gt_setleaf3 IS   NOT INITIAL.
471              SORT gt_setleaf3 BY valfrom.
472              DELETE ADJACENT DUPLICATES FROM gt_setleaf3.
473              SELECT kokrs kostl objnr
474                FROM csks
475                INTO TABLE gt_csks3
476                FOR ALL ENTRIES IN gt_setleaf3
477                WHERE kostl = gt_setleaf3-valfrom+0(10)
478                AND kokrs = p_bukrs.
479            ENDIF.
480          ENDIF.
481
482
483          IF gt_setleaf5 IS NOT INITIAL.
484            REFRESH r_gl1.
485            LOOP AT gt_setleaf5 INTO gs_setleaf5.
486              r_gl1-sign = gs_setleaf5-valsign.
487              r_gl1-option = gs_setleaf5-valoption.
488              r_gl1-low = gs_setleaf5-valfrom.
489              r_gl1-high = gs_setleaf5-valto.
490              APPEND r_gl1.
491              CLEAR: r_gl1, gs_setleaf5.
492            ENDLOOP.
493          ENDIF.
494
495
496          IF gt_csks3 IS NOT INITIAL.
497            SORT gt_csks3 BY objnr.
498            DELETE ADJACENT DUPLICATES FROM gt_csks3 COMPARING objnr.
499            SELECT kokrs belnr buzei kstar wogbtr wkgbtr objnr
500              FROM coep
501              INTO CORRESPONDING FIELDS OF TABLE gt_coepq3
502              FOR ALL ENTRIES IN gt_csks3
503              WHERE objnr = gt_csks3-objnr
504              AND kokrs IN s_kokrs
505              AND perio IN r_perio3
506              AND ( kstar IN s_gl AND kstar NOT LIKE '000022%' AND kstar NOT LIKE '000024%' AND kstar IN r_gl1 )
507              AND gjahr = p_year
508              AND lednr = '00'
509              AND wrttp NE '60'.
510
511    *        SELECT kokrs belnr buzei kstar wogbtr wkgbtr objnr
512    *          FROM coep
513    *          APPENDING TABLE gt_coepq3
514    *          FOR ALL ENTRIES IN gt_csks
515    *          WHERE objnr = gt_csks-objnr
516    *          AND kokrs IN s_kokrs
517    *          AND perio IN r_perio1
518    *          AND ( kstar = '0000500120' OR kstar = '0000502010')
519    *          AND gjahr = p_year
520    *          AND lednr = '00'
521    *          AND wrttp ne '60'.
522
523          ENDIF.
524          IF gt_coepq3 IS NOT INITIAL.
525            SORT gt_coepq3 BY kstar.
526    **  BREAK-POINT.
527            LOOP AT gt_coepq3 INTO gs_coepq3.
528              gs_coep3q3-kstar = gs_coepq3-kstar.
529              gs_coep3q3-wkgbtr = gs_coepq3-wkgbtr.
530              gs_coep3q3-wogbtr = gs_coepq3-wogbtr.
531
532              COLLECT gs_coep3q3 INTO gt_coep3q3.
533              CLEAR gs_coep3q3.
534            ENDLOOP.
535          ENDIF.
536        ENDIF.
537
538
539    *********** For Quarter 4
540        IF r_perio4 IS NOT INITIAL.
541          IF gt_tka02 IS NOT INITIAL.
542            IF s_senm3 IS INITIAL.
543              SELECT kokrs kostl objnr
544                FROM csks
545                INTO TABLE gt_csks4
546
547                WHERE kostl IN s_kokr2
548                AND kokrs = p_bukrs.
549
550            ELSE.
551              SELECT setclass subclass setname valfrom
552                    FROM setleaf
553                    INTO TABLE gt_setleaf4
554                    FOR ALL ENTRIES IN gt_tka02
555                    WHERE setname IN s_senm3
556                    AND   subclass = gt_tka02-kokrs.
557
558
559
560            ENDIF.
561
562
563            IF s_secls3 IS INITIAL.
564
565              REFRESH r_gl1.
566              LOOP AT s_ktop3.
567                r_gl1-sign = s_ktop3-sign.
568                r_gl1-option = s_ktop3-option.
569                r_gl1-low = s_ktop3-low.
570                r_gl1-high = s_ktop3-high.
571                APPEND r_gl1.
572                CLEAR: r_gl1, gs_setleaf5.
573              ENDLOOP.
574
575            ELSE.
576
577              SELECT *
578              FROM setleaf
579              INTO TABLE gt_setleaf5
580              WHERE setname IN s_secls3
581              AND   subclass = 'ONGC'.
582
583            ENDIF.
584
585            IF gt_setleaf4 IS   NOT INITIAL.
586              SORT gt_setleaf4 BY valfrom.
587              DELETE ADJACENT DUPLICATES FROM gt_setleaf4.
588              SELECT kokrs kostl objnr
589                FROM csks
590                INTO TABLE gt_csks4
591                FOR ALL ENTRIES IN gt_setleaf4
592                WHERE kostl = gt_setleaf4-valfrom+0(10)
593                AND kokrs = p_bukrs.
594            ENDIF.
595          ENDIF.
596
597
598          IF gt_setleaf5 IS NOT INITIAL.
599            REFRESH r_gl1.
600            LOOP AT gt_setleaf5 INTO gs_setleaf5.
601              r_gl1-sign = gs_setleaf5-valsign.
602              r_gl1-option = gs_setleaf5-valoption.
603              r_gl1-low = gs_setleaf5-valfrom.
604              r_gl1-high = gs_setleaf5-valto.
605              APPEND r_gl1.
606              CLEAR: r_gl1, gs_setleaf5.
607            ENDLOOP.
608          ENDIF.
609
610
611
612
613          IF gt_csks4 IS NOT INITIAL.
614            SORT gt_csks4 BY objnr.
615            DELETE ADJACENT DUPLICATES FROM gt_csks4 COMPARING objnr.
616            SELECT kokrs belnr buzei kstar wogbtr wkgbtr objnr
617              FROM coep
618              INTO CORRESPONDING FIELDS OF TABLE gt_coepq4
619              FOR ALL ENTRIES IN gt_csks4
620              WHERE objnr = gt_csks4-objnr
621              AND kokrs IN s_kokrs
622              AND perio IN r_perio4
623              AND ( kstar IN s_gl AND kstar NOT LIKE '000022%' AND kstar NOT LIKE '000024%' AND kstar IN r_gl1 )
624              AND gjahr = p_year
625              AND lednr = '00'
626              AND wrttp NE '60'.
627
628    *        SELECT kokrs belnr buzei kstar wogbtr wkgbtr objnr
629    *          FROM coep
630    *          APPENDING TABLE gt_coepq4
631    *          FOR ALL ENTRIES IN gt_csks
632    *          WHERE objnr = gt_csks-objnr
633    *          AND kokrs IN s_kokrs
634    *          AND perio IN r_perio1
635    *          AND ( kstar = '0000500120' OR kstar = '0000502010')
636    *          AND gjahr = p_year
637    *          AND lednr = '00'
638    *          AND wrttp ne '60'.
639
640
641          ENDIF.
642          IF gt_coepq4 IS NOT INITIAL.
643            SORT gt_coepq4 BY kstar.
644    **  BREAK-POINT.
645            LOOP AT gt_coepq4 INTO gs_coepq4.
646              gs_coep3q4-kstar = gs_coepq4-kstar.
647              gs_coep3q4-wkgbtr = gs_coepq4-wkgbtr.
648              gs_coep3q4-wogbtr = gs_coepq4-wogbtr.
649
650              COLLECT gs_coep3q4 INTO gt_coep3q4.
651              CLEAR gs_coep3q4.
652            ENDLOOP.
653          ENDIF.
654        ENDIF.
655
656
657
658    *************************************************ENDED BY RAHUL GUPTA************************************************
659
660        CALL FUNCTION 'GM_GET_FISCAL_YEAR'
661          EXPORTING
662            i_date                     = p_budat
663            i_fyv                      = 'V3'
664          IMPORTING
665            e_fy                       = lv_fiscal
666          EXCEPTIONS
667            fiscal_year_does_not_exist = 1
668            not_defined_for_date       = 2
669            OTHERS                     = 3.
670        lv_fd = lv_fiscal.
671        IF p_year EQ lv_fiscal.
672          CALL FUNCTION 'FIRST_AND_LAST_DAY_IN_YEAR_GET'
673            EXPORTING
674              i_gjahr        = lv_fd
675              i_periv        = 'V3'
676            IMPORTING
677              e_first_day    = v_first
678              e_last_day     = v_last
679            EXCEPTIONS
680              input_false    = 1
681              t009_notfound  = 2
682              t009b_notfound = 3
683              OTHERS         = 4.
684          CONCATENATE p_budat+6(2) p_budat+4(2) p_budat+0(4) INTO lv_date.
685          CONCATENATE v_first+6(2) v_first+4(2) v_first+0(4) INTO lv_date_ps.
686          IF s_period-high = '01'.
687            IF p_budat GE v_first AND
688            p_budat+0(4) EQ v_first+0(4) AND
689            p_budat+4(2) LE '04'.
690            ELSE.
691              MESSAGE 'Inconsistent date and posting period combination' TYPE 'E'.
692            ENDIF.
693          ENDIF.
694          IF s_period-high = '02'.
695            IF p_budat GE v_first AND
696            p_budat+0(4) EQ v_first+0(4) AND
697            p_budat+4(2) LE '05'.
698            ELSE.
699              MESSAGE 'Inconsistent date and posting period combination' TYPE 'E'.
700            ENDIF.
701          ENDIF.
702    *
703          IF s_period-high = '03'.
704            IF p_budat GE v_first AND
705            p_budat+0(4) EQ v_first+0(4) AND
706            p_budat+4(2) LE '06'.
707            ELSE.
708              MESSAGE 'Inconsistent date and posting period combination ' TYPE 'E'.
709            ENDIF.
710          ENDIF.
711          IF s_period-high = '04'.
712            IF p_budat GE v_first AND
713            p_budat+0(4) EQ v_first+0(4) AND
714            p_budat+4(2) LE '07'.
715            ELSE.
716              MESSAGE 'Inconsistent date and posting period combination ' TYPE 'E'.
717            ENDIF.
718          ENDIF.
719          IF s_period-high = '05'.
720            IF p_budat GE v_first AND
721            p_budat+0(4) EQ v_first+0(4) AND
722            p_budat+4(2) LE '08'.
723            ELSE.
724              MESSAGE 'Inconsistent date and posting period combination ' TYPE 'E'.
725            ENDIF.
726          ENDIF.
727          IF s_period-high = '06'.
728            IF p_budat GE v_first AND
729            p_budat+0(4) EQ v_first+0(4) AND
730            p_budat+4(2) LE '09'.
731            ELSE.
732              MESSAGE 'Inconsistent date and posting period combination' TYPE 'E'.
733            ENDIF.
734          ENDIF.
735          IF s_period-high = '07'.
736            IF p_budat GE v_first AND
737            p_budat+0(4) EQ v_first+0(4) AND
738            p_budat+4(2) LE '10'.
739            ELSE.
740              MESSAGE 'Inconsistent date and posting period combination ' TYPE 'E'.
741            ENDIF.
742          ENDIF.
743          IF s_period-high = '08'.
744            IF p_budat GE v_first AND
745            p_budat+0(4) EQ v_first+0(4) AND
746            p_budat+4(2) LE '11'.
747            ELSE.
748              MESSAGE 'Inconsistent date and posting period combination' TYPE 'E'.
749            ENDIF.
750          ENDIF.
751          IF s_period-high = '09'.
752            IF p_budat GE v_first AND
753            p_budat+0(4) EQ v_first+0(4) AND
754            p_budat+4(2) LE '12'.
755            ELSE.
756              MESSAGE 'Inconsistent date and posting period combination' TYPE 'E'.
757            ENDIF.
758          ENDIF.
759          IF s_period-high = '10'.
760            IF p_budat GE v_first AND
761            p_budat+0(4) NE v_first+0(4) AND
762            p_budat+4(2) LE '01'.
763            ELSE.
764              MESSAGE 'Inconsistent date and posting period combination' TYPE 'E'.
765            ENDIF.
766          ENDIF.
767          IF s_period-high = '11'.
768            IF p_budat GE v_first AND
769            p_budat+0(4) NE v_first+0(4) AND
770            p_budat+4(2) LE '02'.
771            ELSE.
772              MESSAGE 'Inconsistent date and posting period combination ' TYPE 'E'.
773            ENDIF.
774          ENDIF.
775          IF s_period-high = '12'.
776            IF p_budat GE v_first AND
777            p_budat+0(4) NE v_first+0(4) AND
778            p_budat+4(2) LE '03'.
779            ELSE.
780              MESSAGE 'Inconsistent date and posting period combination' TYPE 'E'.
781            ENDIF.
782          ENDIF.
783          IF s_period-high = '13' OR
784          s_period-high = '14' OR
785          s_period-high = '15' OR
786          s_period-high = '16'.
787            IF p_budat GE v_first AND
788            p_budat LE v_last.
789            ELSE.
790              MESSAGE 'Inconsistent date and posting period combination' TYPE 'E'.
791            ENDIF.
792          ENDIF.
793          CALL FUNCTION 'CONVERSION_EXIT_INVDT_INPUT'
794            EXPORTING
795              input  = lv_date
796            IMPORTING
797              output = datum.
798          CALL FUNCTION 'CONVERSION_EXIT_INVDT_INPUT'
799            EXPORTING
800              input  = lv_date_ps
801            IMPORTING
802              output = datum_ps.
803          SELECT kurst fcurr tcurr gdatu ukurs
804          FROM tcurr
805          INTO TABLE gt_tcurr
806          WHERE kurst EQ 'CLT'
807          AND fcurr EQ 'USD'
808          AND tcurr EQ 'INR'
809          AND gdatu EQ datum .
810          IF sy-subrc NE 0.
811            SELECT kurst fcurr tcurr gdatu ukurs
812            FROM tcurr
813            INTO TABLE gt_tcurr
814            WHERE kurst EQ 'CLT'
815            AND fcurr EQ 'USD'
816            AND tcurr EQ 'INR'.
817          ENDIF.
818          SELECT kurst fcurr tcurr gdatu ukurs
819          FROM tcurr
820          INTO TABLE gt_tcurr_pl
821          WHERE kurst EQ 'NTA'
822          AND fcurr EQ 'USD'
823          AND tcurr EQ 'INR'.
824          LOOP AT gt_tcurr INTO gs_tcurr.
825            CALL FUNCTION 'CONVERSION_EXIT_INVDT_OUTPUT'
826              EXPORTING
827                input  = gs_tcurr-gdatu
828              IMPORTING
829                output = lv_odate.
830            CONCATENATE lv_odate+6(4) lv_odate+3(2) lv_odate+0(2) INTO gs_tcurr-tdate.
831            gs_tcurr-ukurs1 = gs_tcurr-ukurs.
832            CLEAR gs_tcurr-ukurs.
833            MODIFY gt_tcurr FROM gs_tcurr TRANSPORTING ukurs tdate ukurs1.
834            CLEAR : gs_tcurr.
835          ENDLOOP.
836          DELETE gt_tcurr WHERE tdate+4(2) NE p_budat+4(2).
837          DELETE gt_tcurr WHERE tdate+0(4) NE p_budat+0(4).
838          IF gt_tcurr_pl[] IS NOT INITIAL.
839            LOOP AT gt_tcurr_pl INTO gs_tcurr_pl.
840              CLEAR : lv_odate.
841              CALL FUNCTION 'CONVERSION_EXIT_INVDT_OUTPUT'
842                EXPORTING
843                  input  = gs_tcurr_pl-gdatu
844                IMPORTING
845                  output = lv_odate.
846              CONCATENATE lv_odate+6(4) lv_odate+3(2) lv_odate+0(2) INTO gs_tcurr_pl-tdate.
847              gs_tcurr_pl-ukurs1 = gs_tcurr_pl-ukurs.
848              CLEAR gs_tcurr_pl-ukurs.
849              MODIFY gt_tcurr_pl FROM gs_tcurr_pl TRANSPORTING ukurs tdate ukurs1.
850              CLEAR : gs_tcurr_pl.
851            ENDLOOP.
852          ENDIF.
853          DATA : gt_plsdate TYPE char8,
854                 gt_pledate TYPE char8.
855          CONCATENATE lv_date_ps+4(4) lv_date_ps+2(2) lv_date_ps+0(2) INTO gt_plsdate.
856          CONCATENATE lv_date+4(4) lv_date+2(2) lv_date+0(2) INTO gt_pledate.
857          LOOP AT gt_tcurr_pl INTO gs_tcurr_pl.
858            IF gs_tcurr_pl-tdate GE gt_plsdate AND
859            gs_tcurr_pl-tdate LE gt_pledate .
860            ELSE.
861              DELETE gt_tcurr_pl[] WHERE kurst = gs_tcurr_pl-kurst
862              AND fcurr = gs_tcurr_pl-fcurr
863              AND tcurr = gs_tcurr_pl-tcurr
864              AND gdatu = gs_tcurr_pl-gdatu
865              AND ukurs = gs_tcurr_pl-ukurs
866              AND ukurs1 = gs_tcurr_pl-ukurs1.
867            ENDIF.
868          ENDLOOP.
869          IF gt_tcurr IS NOT INITIAL OR gt_tcurr_pl IS NOT INITIAL.
870            " " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
871    *        SELECT ktopl saknr xbilk
872    *        FROM ska1
873    *        INTO TABLE gt_ska1
874    *        WHERE ktopl EQ 'ONGC'
875    ** AND XBILK EQ 'X'
876    *        AND saknr IN s_gl.
877            SELECT  chartofaccounts AS ktopl , glaccount AS saknr ,
878           isbalancesheetaccount AS xbilk FROM i_glaccountinchartofaccounts WHERE
879           chartofaccounts EQ 'ONGC' AND glaccount IN @s_gl INTO TABLE  @gt_ska1 .
880            " " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
881            IF gt_ska1[] IS NOT INITIAL.
882              SELECT *
883              FROM faglflext
884              INTO CORRESPONDING FIELDS OF TABLE gt_faglflext
885              WHERE ryear = p_year
886              AND rbukrs = p_bukrs
887              AND rldnr = '0L'
888              AND ( racct IN s_gl AND racct NE '0000160208' ).
889              SELECT gl_account znature zconvrsn fctr_gl
890              FROM zfi_fctr
891              INTO TABLE gt_fctr
892              FOR ALL ENTRIES IN gt_faglflext
893              WHERE gl_account EQ gt_faglflext-racct.
894            ENDIF.
895          ELSE.
896            MESSAGE 'CLT Rate For Thease Month Is Not Maintain ' TYPE 'E'.
897            EXIT.
898          ENDIF.
899          SORT gt_faglflext[] BY racct.
900          LOOP AT gt_faglflext INTO gs_faglflext.
901            gs_final-bukrs = gs_faglflext-rbukrs.
902            gs_final-hkont = gs_faglflext-racct.
903            PERFORM get_loclamt.
904            PERFORM get_usdamt.
905            READ TABLE gt_fctr INTO gs_fctr WITH KEY gl_account = gs_faglflext-racct.
906            IF sy-subrc = 0.
907              gs_final-fctr_gl = gs_fctr-fctr_gl.
908              gs_final-zconvrsn = gs_fctr-zconvrsn.
909            ENDIF.
910            READ TABLE gt_ska1 INTO gs_ska1 WITH KEY saknr = gs_faglflext-racct
911            ktopl = 'ONGC'.
912            IF sy-subrc = 0.
913              gs_final-xbilk = gs_ska1-xbilk.
914            ENDIF.
915            COLLECT gs_final INTO gt_final.
916            CLEAR : gs_final.
917          ENDLOOP.
918          DATA : lv_rate TYPE ukurs_curr.
919          DATA : lv_rmnt TYPE char2.
920          DATA : lv_tmt TYPE char2.
921          SORT gt_tcurr_pl BY tdate.
922          LOOP AT gt_tcurr_pl INTO gs_tcurr_pl.
923    *        lv_rate = lv_rate + gs_tcurr_pl-ukurs.
924            lv_rate = lv_rate + gs_tcurr_pl-ukurs1.
925            IF sy-tabix = '1'.
926              lv_tmt = '1'.
927            ELSEIF gs_tcurr_pl-tdate+4(2) NE lv_rmnt.
928              lv_tmt = lv_tmt + 1.
929            ENDIF.
930            lv_rmnt = gs_tcurr_pl-tdate+4(2).
931    * LV_RATE = LV_RATE + GS_TCURR_PL-UKURS.
932    * IF SY-TABIX = '1'.
933    * LV_TMT = '1'.
934    * ELSEIF GS_TCURR_PL-TDATE+4(2) NE LV_RMNT.
935    * LV_TMT = LV_TMT + 1.
936    * ENDIF.
937    * LV_RMNT = GS_TCURR_PL-TDATE+4(2).
938          ENDLOOP.
939          SORT gt_final BY hkont.
940          SORT gt_tcurr BY gdatu ASCENDING.
941          LOOP AT gt_final INTO gs_final.
942            gs_final1-bukrs = gs_final-bukrs.
943            CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
944              EXPORTING
945                input  = gs_final-hkont
946              IMPORTING
947                output = gs_final-hkont.
948            .
949            gs_final1-hkont = gs_final-hkont.
950            gs_final1-dmbtr = gs_final-hslvt + gs_final-hsl01 + gs_final-hsl02 + gs_final-hsl03 + gs_final-hsl04 + gs_final-hsl05
951                                 + gs_final-hsl06 + gs_final-hsl07 + gs_final-hsl08 + gs_final-hsl09 + gs_final-hsl10 + gs_final-hsl11
952                                 + gs_final-hsl12 + gs_final-hsl13 + gs_final-hsl14 + gs_final-hsl15 + gs_final-hsl16.
953
954            gs_final1-dmbe2 = gs_final-kslvt + gs_final-ksl01 + gs_final-ksl02 + gs_final-ksl03 + gs_final-ksl04 + gs_final-ksl05
955                            + gs_final-ksl06 + gs_final-ksl07 + gs_final-ksl08 + gs_final-ksl09 + gs_final-ksl10 + gs_final-ksl11
956                            + gs_final-ksl12 + gs_final-ksl13 + gs_final-ksl14 + gs_final-ksl15 + gs_final-ksl16.
957            gs_final1-xbilk = gs_final-xbilk.
958            gs_final1-zconvrsn = gs_final-zconvrsn.
959    *        IF gs_final-xbilk = 'X'.
960    *          READ TABLE gt_tcurr INTO gs_tcurr INDEX 1.
961    *          IF sy-subrc = 0.
962    *            gs_final1-kurst = gs_tcurr-kurst.
963    *            gs_final1-fcurr = gs_tcurr-fcurr.
964    *            gs_final1-tcurr = gs_tcurr-tcurr.
965    *            gs_final1-gdatu = gs_tcurr-gdatu.
966    ** GS_FINAL1-UKURS = GS_TCURR-UKURS.
967    *          ENDIF.
968    *          IF gs_final-zconvrsn = 'YES'.
969    *            gs_final1-convert_inr = gs_final1-dmbe2 * gs_tcurr-ukurs1.
970    *            gs_final1-exchng = gs_final1-dmbtr - gs_final1-convert_inr.
971    *            gs_final1-ukurs = gs_tcurr-ukurs1.
972    *          ELSEIF gs_final-zconvrsn = 'NO'.
973    *            gs_final1-convert_inr = gs_final1-dmbtr.
974    *            gs_final1-exchng = gs_final1-dmbtr - gs_final1-convert_inr.
975    *          ENDIF.
976    *        ELSE.
977    *          IF gs_final-zconvrsn = 'YES'.
978    *            gs_final1-ukurs = lv_rate / lv_tmt.
979    ** GS_FINAL1-CONVERT_INR = GS_FINAL1-DMBE2 * LV_RATE / LV_TMT."" GS_FINAL-UKURS.
980    *            gs_final1-convert_inr = gs_final1-dmbe2 * gs_final1-ukurs.
981    *            gs_final1-exchng = gs_final1-dmbtr - gs_final1-convert_inr.
982    *          ELSEIF gs_final-zconvrsn = 'NO'.
983    *            gs_final1-convert_inr = gs_final1-dmbtr.
984    *            gs_final1-exchng = gs_final1-dmbtr - gs_final1-convert_inr.
985    *          ENDIF.
986    *        ENDIF.
987    *        CLEAR : var,len,var1.
988    *        var = gs_final1-exchng.
989    *        CONDENSE var.
990    *        len = strlen( var ) - 1.
991    *        var1 = var+len(1).
992    *        IF var1 = '-'.
993    *          gs_final1-gain_loss = 'Gain'.
994    *        ELSE.
995    *          gs_final1-gain_loss = 'Loss'.
996    *        ENDIF.
997            APPEND gs_final1 TO gt_final1.
998            CLEAR : gs_final1.
999          ENDLOOP.
1000   *      LOOP AT gt_final1 INTO gs_final1.
1001   *        IF gs_final1-dmbtr IS INITIAL AND
1002   *        gs_final1-dmbe2 IS INITIAL.
1003   *          DELETE gt_final1 WHERE hkont = gs_final1-hkont
1004   *          AND dmbe2 = gs_final1-dmbe2
1005   *          AND dmbtr = gs_final1-dmbtr
1006   *          AND exchng = gs_final1-exchng
1007   *          AND convert_inr = gs_final1-convert_inr
1008   *          AND ukurs = gs_final1-ukurs.
1009   *        ENDIF.
1010   *      ENDLOOP.
1011         SELECT *
1012               FROM faglflext
1013               INTO CORRESPONDING FIELDS OF TABLE gt_faglflext1
1014               WHERE ryear = p_year
1015               AND rbukrs = p_bukrs
1016               AND rldnr = '0L'
1017               AND racct = '0000160208'.
1018         REFRESH gt_final[].
1019         gt_final[] = gt_final1[].
1020         REFRESH gt_final1[].
1021         LOOP AT gt_faglflext1 INTO gs_faglflext1.
1022           PERFORM get_loclamt1.
1023           PERFORM get_usd1.
1024           COLLECT gs_finaltot INTO gt_finaltot.
1025           CLEAR : gs_finaltot.
1026         ENDLOOP.
1027         LOOP AT gt_final INTO gs_final.
1028           gs_final1-exchng = gs_final-exchng.
1029           APPEND gs_final1 TO gt_final1.
1030           CLEAR : gs_final1.
1031         ENDLOOP.
1032         LOOP AT gt_final1 INTO gs_final1.
1033           gs_final2-exchng = gs_final1-exchng.
1034           COLLECT gs_final2 INTO gt_final2.
1035           CLEAR : gs_final2.
1036         ENDLOOP.
1037   *      CLEAR : gs_final.
1038   *      LOOP AT gt_finaltot INTO gs_finaltot.
1039   *        gs_final-hkont = '160208'.
1040   *        gs_final-dmbtr = gs_finaltot-hslvt + gs_finaltot-hsl01 + gs_finaltot-hsl02 + gs_finaltot-hsl03 + gs_finaltot-hsl04
1041   *                              + gs_finaltot-hsl05 + gs_finaltot-hsl06 + gs_finaltot-hsl07 + gs_finaltot-hsl08 + gs_finaltot-hsl09
1042   *                              + gs_finaltot-hsl10 + gs_finaltot-hsl11 + gs_finaltot-hsl12 + gs_finaltot-hsl13 + gs_finaltot-hsl14
1043   *                              + gs_finaltot-hsl15 + gs_finaltot-hsl16.
1044   *
1045   *        gs_final-dmbe2 = gs_finaltot-kslvt + gs_finaltot-ksl01 + gs_finaltot-ksl02 + gs_finaltot-ksl03 + gs_finaltot-ksl04
1046   *                       + gs_finaltot-ksl05 + gs_finaltot-ksl06 + gs_finaltot-ksl07 + gs_finaltot-ksl08 + gs_finaltot-ksl09
1047   *                       + gs_finaltot-ksl10 + gs_finaltot-ksl11 + gs_finaltot-ksl12 + gs_finaltot-ksl13 + gs_finaltot-ksl14
1048   *                       + gs_finaltot-ksl15 + gs_finaltot-ksl16.
1049   *
1050   *
1051   *        READ TABLE gt_final2 INTO gs_final2 INDEX 1.
1052   *        IF sy-subrc = 0.
1053   *          gs_final-exchng = gs_final2-exchng.
1054   *        ENDIF.
1055   *        gs_final-convert_inr = gs_final2-exchng + gs_final-dmbtr.
1056   *        CLEAR : var,len,var1.
1057   *        var = gs_final-exchng.
1058   *        CONDENSE var.
1059   *        len = strlen( var ) - 1.
1060   *        var1 = var+len(1).
1061   *        IF var1 = '-'.
1062   *          gs_final-gain_loss = 'Gain'.
1063   *        ELSE.
1064   *          gs_final-gain_loss = 'Loss'.
1065   *        ENDIF.
1066   *        APPEND gs_final TO gt_final.
1067   *        CLEAR gs_final.
1068   *      ENDLOOP.
1069
1070
1071   ***************************************** Code Added By Disha Joshi 15/09/2018*********************************************
1072         DATA : lv_hkont TYPE hkont.
1073
1074
1075
1076         LOOP AT gt_final INTO gs_final.
1077
1078
1079           CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
1080             EXPORTING
1081               input  = gs_final-hkont
1082             IMPORTING
1083               output = lv_hkont.
1084           READ TABLE gt_coep1 INTO gs_coep1 WITH KEY kstar = lv_hkont.
1085           IF sy-subrc = 0.
1086             gs_final-wogbtr = gs_coep1-wogbtr * -1.
1087             gs_final-wkgbtr = gs_coep1-wkgbtr * -1.
1088           ENDIF.
1089           READ TABLE gt_coep3 INTO gs_coep3 WITH KEY kstar = lv_hkont.
1090           IF sy-subrc = 0.
1091             gs_final-wogbtr1 = gs_coep3-wogbtr * -1.
1092             gs_final-wkgbtr1 = gs_coep3-wkgbtr * -1.
1093           ENDIF.
1094           READ TABLE gt_coep3q2 INTO gs_coep3 WITH KEY kstar = lv_hkont.
1095           IF sy-subrc = 0.
1096             gs_final-wogbtr1q2 = gs_coep3-wogbtr * -1.
1097             gs_final-wkgbtr1q2 = gs_coep3-wkgbtr * -1.
1098           ENDIF.
1099           READ TABLE gt_coep3q3 INTO gs_coep3 WITH KEY kstar = lv_hkont.
1100           IF sy-subrc = 0.
1101             gs_final-wogbtr1q3 = gs_coep3-wogbtr * -1.
1102             gs_final-wkgbtr1q3 = gs_coep3-wkgbtr * -1.
1103           ENDIF.
1104           READ TABLE gt_coep3q4 INTO gs_coep3 WITH KEY kstar = lv_hkont.
1105           IF sy-subrc = 0.
1106             gs_final-wogbtr1q4 = gs_coep3-wogbtr * -1.
1107             gs_final-wkgbtr1q4 = gs_coep3-wkgbtr * -1.
1108           ENDIF.
1109
1110
1111
1112           IF lv_hkont = '0000209999'.
1113   *          clear: gs_final-wogbtr,gs_final-wkgbtr, gs_final-wogbtr1,gs_final-wkgbtr1,gs_final-wogbtr1q2,gs_final-wkgbtr1q2,
1114   *          gs_final-wogbtr1q3, gs_final-wogbtr1q4, gs_final-wkgbtr1q3, gs_final-wkgbtr1q4.
1115             READ TABLE gt_coep1 INTO gs_coep1 WITH KEY kstar = '0000500120'.
1116             IF sy-subrc = 0.
1117               gs_final-wogbtr = gs_final-wogbtr - gs_coep1-wogbtr.
1118               gs_final-wkgbtr = gs_final-wkgbtr - gs_coep1-wkgbtr.
1119
1120               READ TABLE gt_coep1 INTO gs_coep1 WITH KEY kstar = '0000502010'.
1121               IF sy-subrc = 0.
1122                 gs_final-wogbtr = gs_final-wogbtr - gs_coep1-wogbtr.
1123                 gs_final-wkgbtr = gs_final-wkgbtr - gs_coep1-wkgbtr.
1124               ENDIF.
1125             ENDIF.
1126             READ TABLE gt_coep3 INTO gs_coep3 WITH KEY kstar = '0000500120'.
1127             IF sy-subrc = 0.
1128               gs_final-wogbtr1 = gs_final-wogbtr1 - gs_coep3-wogbtr.
1129               gs_final-wkgbtr1 = gs_final-wkgbtr1 - gs_coep3-wkgbtr.
1130               READ TABLE gt_coep3 INTO gs_coep3 WITH KEY kstar = '0000502010'.
1131               IF sy-subrc = 0.
1132                 gs_final-wogbtr1 = gs_final-wogbtr1 - gs_coep3-wogbtr.
1133                 gs_final-wkgbtr1 = gs_final-wkgbtr1 - gs_coep3-wkgbtr.
1134               ENDIF.
1135             ENDIF.
1136
1137             READ TABLE gt_coep3q2 INTO gs_coep3 WITH KEY kstar = '0000500120'.
1138             IF sy-subrc = 0.
1139               gs_final-wogbtr1q2 = gs_final-wogbtr1q2 - gs_coep3-wogbtr.
1140               gs_final-wkgbtr1q2 = gs_final-wkgbtr1q2 - gs_coep3-wkgbtr.
1141               READ TABLE gt_coep3q2 INTO gs_coep3 WITH KEY kstar = '0000502010'.
1142               IF sy-subrc = 0.
1143                 gs_final-wogbtr1q2 = gs_final-wogbtr1q2 - gs_coep3-wogbtr.
1144                 gs_final-wkgbtr1q2 = gs_final-wkgbtr1q2 - gs_coep3-wkgbtr.
1145               ENDIF.
1146             ENDIF.
1147
1148             READ TABLE gt_coep3q3 INTO gs_coep3 WITH KEY kstar = '0000500120'.
1149             IF sy-subrc = 0.
1150               gs_final-wogbtr1q3 = gs_final-wogbtr1q3 - gs_coep3-wogbtr.
1151               gs_final-wkgbtr1q3 = gs_final-wkgbtr1q3 - gs_coep3-wkgbtr.
1152               READ TABLE gt_coep3q3 INTO gs_coep3 WITH KEY kstar = '0000502010'.
1153               IF sy-subrc = 0.
1154                 gs_final-wogbtr1q3 = gs_final-wogbtr1q3 - gs_coep3-wogbtr.
1155                 gs_final-wkgbtr1q3 = gs_final-wkgbtr1q3 - gs_coep3-wkgbtr.
1156               ENDIF.
1157             ENDIF.
1158
1159             READ TABLE gt_coep3q4 INTO gs_coep3 WITH KEY kstar = '0000500120'.
1160             IF sy-subrc = 0.
1161               gs_final-wogbtr1q4 = gs_final-wogbtr1q4 - gs_coep3-wogbtr.
1162               gs_final-wkgbtr1q4 = gs_final-wkgbtr1q4 - gs_coep3-wkgbtr.
1163               READ TABLE gt_coep3q4 INTO gs_coep3 WITH KEY kstar = '0000502010'.
1164               IF sy-subrc = 0.
1165                 gs_final-wogbtr1q4 = gs_final-wogbtr1q4 - gs_coep3-wogbtr.
1166                 gs_final-wkgbtr1q4 = gs_final-wkgbtr1q4 - gs_coep3-wkgbtr.
1167               ENDIF.
1168             ENDIF.
1169
1170           ENDIF.
1171
1172           gs_final-wogbtr1t = gs_final-wogbtr1 + gs_final-wogbtr1q2 + gs_final-wogbtr1q3 + gs_final-wogbtr1q4.
1173           gs_final-wkgbtr1t = gs_final-wkgbtr1 + gs_final-wkgbtr1q2 + gs_final-wkgbtr1q3 + gs_final-wkgbtr1q4.
1174           MODIFY gt_final FROM gs_final TRANSPORTING wogbtr wkgbtr wogbtr1 wkgbtr1 wogbtr1q2 wkgbtr1q2 wogbtr1q3 wkgbtr1q3 wogbtr1q4 wkgbtr1q4 wogbtr1t wkgbtr1t.
1175           CLEAR : gs_final,lv_hkont.
1176         ENDLOOP.
1177
1178   ******************************* Code Ended By Disha Joshi 15/09/2018*********************************************************
1179
1180
1181         LOOP AT gt_final INTO gs_final1.
1182           IF gs_final1-dmbtr IS INITIAL AND
1183           gs_final1-dmbe2 IS INITIAL
1184             AND gs_final1-wogbtr IS INITIAL
1185             AND gs_final1-wkgbtr IS INITIAL
1186             AND gs_final1-wogbtr1 IS INITIAL AND gs_final1-wogbtr1q2 IS INITIAL AND gs_final1-wogbtr1q3 IS INITIAL AND gs_final1-wogbtr1q4 IS INITIAL
1187             AND gs_final1-wkgbtr1 IS INITIAL AND gs_final1-wkgbtr1q2 IS INITIAL AND gs_final1-wkgbtr1q3 IS INITIAL AND gs_final1-wkgbtr1q4 IS INITIAL.
1188
1189             DELETE gt_final WHERE hkont = gs_final1-hkont
1190             AND dmbe2 = gs_final1-dmbe2
1191             AND dmbtr = gs_final1-dmbtr
1192             AND exchng = gs_final1-exchng
1193             AND convert_inr = gs_final1-convert_inr
1194             AND ukurs = gs_final1-ukurs.
1195           ENDIF.
1196         ENDLOOP.
1197
1198
1199
1200         DELETE gt_final WHERE hkont IS INITIAL.
1201         LOOP AT gt_final ASSIGNING FIELD-SYMBOL(<fs_final>).
1202           <fs_final>-inrtot = <fs_final>-dmbtr + <fs_final>-wogbtr + <fs_final>-wogbtr1t.
1203           <fs_final>-usdtot = <fs_final>-dmbe2 + <fs_final>-wkgbtr + <fs_final>-wkgbtr1t.
1204
1205           IF <fs_final>-hkont = '160208'.
1206             CONTINUE.
1207           ENDIF.
1208
1209           IF <fs_final>-xbilk = 'X'.
1210             READ TABLE gt_tcurr INTO gs_tcurr INDEX 1.
1211             IF sy-subrc = 0.
1212               <fs_final>-kurst = gs_tcurr-kurst.
1213               <fs_final>-fcurr = gs_tcurr-fcurr.
1214               <fs_final>-tcurr = gs_tcurr-tcurr.
1215               <fs_final>-gdatu = gs_tcurr-gdatu.
1216   * <FS_FINAL>-UKURS = GS_TCURR-UKURS.
1217             ENDIF.
1218             IF <fs_final>-zconvrsn = 'YES'.
1219               <fs_final>-convert_inr = <fs_final>-usdtot * gs_tcurr-ukurs1.
1220               <fs_final>-exchng = <fs_final>-inrtot - <fs_final>-convert_inr.
1221               <fs_final>-ukurs = gs_tcurr-ukurs1.
1222             ELSEIF <fs_final>-zconvrsn = 'NO'.
1223               <fs_final>-convert_inr = <fs_final>-inrtot.
1224               <fs_final>-exchng = <fs_final>-inrtot - <fs_final>-convert_inr.
1225             ENDIF.
1226           ELSE.
1227             IF <fs_final>-zconvrsn = 'YES'.
1228               <fs_final>-ukurs = lv_rate / lv_tmt.
1229   * <FS_FINAL>-CONVERT_INR = <FS_FINAL>-USDTOT * LV_RATE / LV_TMT."" <FS_FINAL>-UKURS.
1230               <fs_final>-convert_inr = <fs_final>-usdtot * <fs_final>-ukurs.
1231               <fs_final>-exchng = <fs_final>-inrtot - <fs_final>-convert_inr.
1232             ELSEIF <fs_final>-zconvrsn = 'NO'.
1233               <fs_final>-convert_inr = <fs_final>-inrtot.
1234               <fs_final>-exchng = <fs_final>-inrtot - <fs_final>-convert_inr.
1235             ENDIF.
1236           ENDIF.
1237           CLEAR : var,len,var1.
1238           var = <fs_final>-exchng.
1239           CONDENSE var.
1240           len = strlen( var ) - 1.
1241           var1 = var+len(1).
1242           IF var1 = '-'.
1243             <fs_final>-gain_loss = 'Gain'.
1244           ELSE.
1245             <fs_final>-gain_loss = 'Loss'.
1246           ENDIF.
1247
1248         ENDLOOP.
1249
1250
1251   ***************LOGIC FOR G/L 160208  Copied from Line no 915 By Rahul Gupta***************
1252
1253
1254   *SELECT *
1255   *            FROM faglflext
1256   *            INTO CORRESPONDING FIELDS OF TABLE gt_faglflext1
1257   *            WHERE ryear = p_year
1258   *            AND rbukrs = p_bukrs
1259   *            AND rldnr = '0L'
1260   *            AND racct = '0000160208'.
1261   **      REFRESH gt_final[].
1262   **      gt_final[] = gt_final1[].
1263   **      REFRESH gt_final1[].
1264   *      LOOP AT gt_faglflext1 INTO gs_faglflext1.
1265   *        PERFORM get_loclamt1.
1266   *        PERFORM get_usd1.
1267   *        COLLECT gs_finaltot INTO gt_finaltot.
1268   *        CLEAR : gs_finaltot.
1269   *      ENDLOOP.
1270         REFRESH: gt_final1, gt_final2.
1271         LOOP AT gt_final INTO gs_final.
1272           gs_final1-exchng = gs_final-exchng.
1273           APPEND gs_final1 TO gt_final1.
1274           CLEAR : gs_final1.
1275         ENDLOOP.
1276         LOOP AT gt_final1 INTO gs_final1.
1277           gs_final2-exchng = gs_final1-exchng.
1278           COLLECT gs_final2 INTO gt_final2.
1279           CLEAR : gs_final2.
1280         ENDLOOP.
1281         CLEAR : gs_final.
1282         LOOP AT gt_finaltot INTO gs_finaltot.
1283           gs_final-hkont = '160208'.
1284           gs_final-dmbtr = gs_finaltot-hslvt + gs_finaltot-hsl01 + gs_finaltot-hsl02 + gs_finaltot-hsl03 + gs_finaltot-hsl04
1285                                 + gs_finaltot-hsl05 + gs_finaltot-hsl06 + gs_finaltot-hsl07 + gs_finaltot-hsl08 + gs_finaltot-hsl09
1286                                 + gs_finaltot-hsl10 + gs_finaltot-hsl11 + gs_finaltot-hsl12 + gs_finaltot-hsl13 + gs_finaltot-hsl14
1287                                 + gs_finaltot-hsl15 + gs_finaltot-hsl16.
1288
1289           gs_final-dmbe2 = gs_finaltot-kslvt + gs_finaltot-ksl01 + gs_finaltot-ksl02 + gs_finaltot-ksl03 + gs_finaltot-ksl04
1290                          + gs_finaltot-ksl05 + gs_finaltot-ksl06 + gs_finaltot-ksl07 + gs_finaltot-ksl08 + gs_finaltot-ksl09
1291                          + gs_finaltot-ksl10 + gs_finaltot-ksl11 + gs_finaltot-ksl12 + gs_finaltot-ksl13 + gs_finaltot-ksl14
1292                          + gs_finaltot-ksl15 + gs_finaltot-ksl16.
1293
1294           gs_final-inrtot = gs_final-dmbtr.
1295           gs_final-usdtot = gs_final-dmbe2.
1296           READ TABLE gt_final2 INTO gs_final2 INDEX 1.
1297           IF sy-subrc = 0.
1298             gs_final-exchng = gs_final2-exchng.
1299           ENDIF.
1300           gs_final-convert_inr = gs_final2-exchng + gs_final-inrtot.
1301           CLEAR : var,len,var1.
1302           var = gs_final-exchng.
1303           CONDENSE var.
1304           len = strlen( var ) - 1.
1305           var1 = var+len(1).
1306           IF var1 = '-'.
1307             gs_final-gain_loss = 'Gain'.
1308           ELSE.
1309             gs_final-gain_loss = 'Loss'.
1310           ENDIF.
1311           APPEND gs_final TO gt_final.
1312           CLEAR gs_final.
1313         ENDLOOP.
1314
1315
1316       ELSE.
1317         MESSAGE 'please change fiscal year or date ' TYPE 'E'.
1318       ENDIF.
1319     ENDIF.
1320   ENDFORM.
1321   *&---------------------------------------------------------------------*
1322   *& Form ALV_FIELDCAT
1323   *&---------------------------------------------------------------------*
1324   FORM alv_fieldcat .
1325     CLEAR wa_fieldcat.
1326     DATA counter TYPE i.
1327     counter = counter + 1.
1328     wa_fieldcat-col_pos = counter.
1329     wa_fieldcat-fieldname = 'HKONT'.
1330     wa_fieldcat-no_zero = 'X'.
1331     wa_fieldcat-seltext_m = 'GL'.
1332     APPEND wa_fieldcat TO it_fieldcat .
1333     CLEAR wa_fieldcat .
1334   *  counter = counter + 1.
1335   *  wa_fieldcat-col_pos = counter.
1336   *  wa_fieldcat-fieldname = 'DMBTR'.
1337   ** WA_FIELDCAT-NO_ZERO = 'X'.
1338   *  wa_fieldcat-seltext_m = 'Actul INR'.
1339   *  APPEND wa_fieldcat TO it_fieldcat .
1340   *  CLEAR wa_fieldcat .
1341   *  counter = counter + 1.
1342   *  wa_fieldcat-col_pos = counter.
1343   *  wa_fieldcat-fieldname = 'DMBE2'.
1344   ** WA_FIELDCAT-NO_ZERO = 'X'.
1345   *  wa_fieldcat-seltext_m = 'Actual USD'.
1346   *  APPEND wa_fieldcat TO it_fieldcat .
1347   *  CLEAR wa_fieldcat .
1348   *  counter = counter + 1.
1349     IF n = 1.
1350       counter = counter + 1.
1351       wa_fieldcat-col_pos   = counter.
1352       wa_fieldcat-fieldname = 'WOGBTR'.
1353       wa_fieldcat-seltext_m =   'WBS INR Ad. Q1'.
1354       APPEND wa_fieldcat TO it_fieldcat .
1355       CLEAR wa_fieldcat .
1356
1357       counter = counter + 1.
1358       wa_fieldcat-col_pos   = counter.
1359       wa_fieldcat-fieldname = 'WKGBTR'.
1360       wa_fieldcat-seltext_m =   'WBS USD Ad. Q1 '.
1361       APPEND wa_fieldcat TO it_fieldcat .
1362       CLEAR wa_fieldcat .
1363
1364     ELSEIF n = 2.
1365
1366       counter = counter + 1.
1367       wa_fieldcat-col_pos   = counter.
1368       wa_fieldcat-fieldname = 'WOGBTR'.
1369       wa_fieldcat-seltext_m =   'WBS INR Ad. Q2'.
1370       APPEND wa_fieldcat TO it_fieldcat .
1371       CLEAR wa_fieldcat .
1372
1373       counter = counter + 1.
1374       wa_fieldcat-col_pos   = counter.
1375       wa_fieldcat-fieldname = 'WKGBTR'.
1376       wa_fieldcat-seltext_m =   'WBS USD Ad. Q2'.
1377       APPEND wa_fieldcat TO it_fieldcat .
1378       CLEAR wa_fieldcat .
1379
1380     ELSEIF n = 3.
1381
1382       counter = counter + 1.
1383       wa_fieldcat-col_pos   = counter.
1384       wa_fieldcat-fieldname = 'WOGBTR'.
1385       wa_fieldcat-seltext_m =   'WBS INR Ad. Q3'.
1386       APPEND wa_fieldcat TO it_fieldcat .
1387       CLEAR wa_fieldcat .
1388
1389       counter = counter + 1.
1390       wa_fieldcat-col_pos   = counter.
1391       wa_fieldcat-fieldname = 'WKGBTR'.
1392       wa_fieldcat-seltext_m =   'WBS USD Ad. Q3'.
1393       APPEND wa_fieldcat TO it_fieldcat .
1394       CLEAR wa_fieldcat .
1395
1396     ELSEIF n = 4.
1397
1398       counter = counter + 1.
1399       wa_fieldcat-col_pos   = counter.
1400       wa_fieldcat-fieldname = 'WOGBTR'.
1401       wa_fieldcat-seltext_m =   'WBS INR Ad. Q4'.
1402       APPEND wa_fieldcat TO it_fieldcat .
1403       CLEAR wa_fieldcat .
1404
1405       counter = counter + 1.
1406       wa_fieldcat-col_pos   = counter.
1407       wa_fieldcat-fieldname = 'WKGBTR'.
1408       wa_fieldcat-seltext_m =   'WBS USD Ad. Q4'.
1409       APPEND wa_fieldcat TO it_fieldcat .
1410       CLEAR wa_fieldcat .
1411
1412     ENDIF.
1413     IF n = 1.
1414       counter = counter + 1.
1415       wa_fieldcat-col_pos   = counter.
1416       wa_fieldcat-fieldname = 'WOGBTR1'.
1417       wa_fieldcat-seltext_m =   'CC INR Ad. Q1'.
1418       APPEND wa_fieldcat TO it_fieldcat .
1419       CLEAR wa_fieldcat .
1420
1421       counter = counter + 1.
1422       wa_fieldcat-col_pos   = counter.
1423       wa_fieldcat-fieldname = 'WKGBTR1'.
1424       wa_fieldcat-seltext_m =   'CC USD Ad. Q1'.
1425       APPEND wa_fieldcat TO it_fieldcat .
1426       CLEAR wa_fieldcat .
1427     ENDIF.
1428     IF n = 2 .
1429       counter = counter + 1.
1430       wa_fieldcat-col_pos   = counter.
1431       wa_fieldcat-fieldname = 'WOGBTR1Q2'.
1432       wa_fieldcat-seltext_m =   'CC INR Ad. Q2'.
1433       APPEND wa_fieldcat TO it_fieldcat .
1434       CLEAR wa_fieldcat .
1435
1436       counter = counter + 1.
1437       wa_fieldcat-col_pos   = counter.
1438       wa_fieldcat-fieldname = 'WKGBTR1Q2'.
1439       wa_fieldcat-seltext_m =   'CC USD Ad. Q2'.
1440       APPEND wa_fieldcat TO it_fieldcat .
1441       CLEAR wa_fieldcat .
1442     ENDIF.
1443   *  endif.
1444     IF n = 3 .
1445       counter = counter + 1.
1446       wa_fieldcat-col_pos   = counter.
1447       wa_fieldcat-fieldname = 'WOGBTR1Q3'.
1448       wa_fieldcat-seltext_m =   'CC INR Ad. Q3'.
1449       APPEND wa_fieldcat TO it_fieldcat .
1450       CLEAR wa_fieldcat .
1451
1452       counter = counter + 1.
1453       wa_fieldcat-col_pos   = counter.
1454       wa_fieldcat-fieldname = 'WKGBTR1Q3'.
1455       wa_fieldcat-seltext_m =   'CC USD Ad. Q3'.
1456       APPEND wa_fieldcat TO it_fieldcat .
1457       CLEAR wa_fieldcat .
1458     ENDIF.
1459     IF n = 4.
1460       counter = counter + 1.
1461       wa_fieldcat-col_pos   = counter.
1462       wa_fieldcat-fieldname = 'WOGBTR1Q4'.
1463       wa_fieldcat-seltext_m =   'CC INR Ad. Q4'.
1464       APPEND wa_fieldcat TO it_fieldcat .
1465       CLEAR wa_fieldcat .
1466
1467       counter = counter + 1.
1468       wa_fieldcat-col_pos   = counter.
1469       wa_fieldcat-fieldname = 'WKGBTR1Q4'.
1470       wa_fieldcat-seltext_m =   'CC USD Ad. Q4'.
1471       APPEND wa_fieldcat TO it_fieldcat .
1472       CLEAR wa_fieldcat .
1473     ENDIF.
1474   *  counter = counter + 1.
1475   *  wa_fieldcat-col_pos   = counter.
1476   *  wa_fieldcat-fieldname = 'WOGBTR1T'.
1477   *  wa_fieldcat-seltext_m =   'CC INR Ad. TOTAL'.
1478   *  APPEND wa_fieldcat TO it_fieldcat .
1479   *  CLEAR wa_fieldcat .
1480   *
1481   *  counter = counter + 1.
1482   *  wa_fieldcat-col_pos   = counter.
1483   *  wa_fieldcat-fieldname = 'WKGBTR1T'.
1484   *  wa_fieldcat-seltext_m =   'CC USD Ad. TOTAL'.
1485   *  APPEND wa_fieldcat TO it_fieldcat .
1486   *  CLEAR wa_fieldcat .
1487
1488   *  counter = counter + 1.
1489   *  wa_fieldcat-col_pos   = counter.
1490   *  wa_fieldcat-fieldname = 'INRTOT'.
1491   *  wa_fieldcat-seltext_m =   'Adjusted INR'.
1492   *  APPEND wa_fieldcat TO it_fieldcat .
1493   *  CLEAR wa_fieldcat .
1494   *
1495   *  counter = counter + 1.
1496   *  wa_fieldcat-col_pos   = counter.
1497   *  wa_fieldcat-fieldname = 'USDTOT'.
1498   *  wa_fieldcat-seltext_m =   'Adjusted USD'.
1499   *  APPEND wa_fieldcat TO it_fieldcat .
1500   *  CLEAR wa_fieldcat .
1501   *
1502   *  wa_fieldcat-col_pos = counter.
1503   *  wa_fieldcat-fieldname = 'UKURS'.
1504   *  wa_fieldcat-seltext_m = 'Exchange Rate'.
1505   *  APPEND wa_fieldcat TO it_fieldcat .
1506   *  CLEAR wa_fieldcat .
1507   *  counter = counter + 1.
1508   *  wa_fieldcat-col_pos = counter.
1509   *  wa_fieldcat-fieldname = 'CONVERT_INR'.
1510   ** WA_FIELDCAT-NO_ZERO = 'X'.
1511   *  wa_fieldcat-seltext_m = 'Converted INR'.
1512   *  APPEND wa_fieldcat TO it_fieldcat .
1513   *  CLEAR wa_fieldcat .
1514   *  counter = counter + 1.
1515   *  wa_fieldcat-col_pos = counter.
1516   *  wa_fieldcat-fieldname = 'EXCHNG'.
1517   *  wa_fieldcat-seltext_m = 'FCTR GL Loss/(Gain)'.
1518   *  APPEND wa_fieldcat TO it_fieldcat .
1519   *  CLEAR wa_fieldcat .
1520   *  counter = counter + 1.
1521   *  wa_fieldcat-col_pos = counter.
1522   *  wa_fieldcat-fieldname = 'GAIN_LOSS'.
1523   *  wa_fieldcat-seltext_m = 'FCTR GL Gain/Loss'.
1524   *  APPEND wa_fieldcat TO it_fieldcat .
1525   *  CLEAR wa_fieldcat .
1526
1527
1528   ENDFORM.
1529   *&---------------------------------------------------------------------*
1530   *& Form GET_EVENT
1531   *&---------------------------------------------------------------------*
1532   FORM get_event .
1533     CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
1534       EXPORTING
1535         i_list_type     = 0
1536       IMPORTING
1537         et_events       = it_events[]
1538       EXCEPTIONS
1539         list_type_wrong = 1
1540         OTHERS          = 2.
1541     IF sy-subrc <> 0.
1542       MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
1543       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
1544     ENDIF.
1545     READ TABLE it_events WITH KEY name = slis_ev_top_of_page
1546     INTO it_events.
1547     IF sy-subrc = 0.
1548       MOVE t_formname_top_of_page TO it_events-form.
1549       APPEND it_events.
1550     ENDIF.
1551   ENDFORM.
1552   *&---------------------------------------------------------------------*
1553   *& Form SUB_COMMENT_BUILD
1554   *&---------------------------------------------------------------------*
1555   * text
1556   *----------------------------------------------------------------------*
1557   * -->P_T_LIST_TOP_OF_PAGE text
1558   *----------------------------------------------------------------------*
1559   FORM sub_comment_build USING p_t_list_top_of_page TYPE slis_t_listheader.
1560     DATA: ls_line TYPE slis_listheader.
1561     DATA: wrk_name TYPE string.
1562     DATA : date TYPE char10.
1563     wrk_name = ''.
1564     CLEAR ls_line.
1565     ls_line-typ = 'H'.
1566     ls_line-info = wrk_name.
1567     APPEND ls_line TO p_t_list_top_of_page.
1568     IF p_budat IS NOT INITIAL.
1569       CONCATENATE p_budat+6(2) '.' p_budat+4(2) '.' p_budat+0(4) INTO date.
1570       CONCATENATE TEXT-h02 'Date of report : ' date INTO ls_line-info SEPARATED BY space.
1571       ls_line-typ = 'S'.
1572       APPEND ls_line TO p_t_list_top_of_page.
1573     ENDIF.
1574   ENDFORM.
1575   *&---------------------------------------------------------------------*
1576   *& Form top_of_page
1577   *&---------------------------------------------------------------------*
1578   FORM top_of_page.
1579     CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
1580       EXPORTING
1581         it_list_commentary = t_list_top_of_page.
1582   ENDFORM. "top_of_page
1583   *&---------------------------------------------------------------------*
1584   *& Form ALV_DISPLAY
1585   *&---------------------------------------------------------------------*
1586   FORM alv_display .
1587   * IF R3 = 'X'.
1588     gs_layout-zebra = 'X'.
1589     gs_layout-detail_popup = 'X'.
1590     gs_layout-detail_initial_lines = 'X'.
1591     gs_layout-colwidth_optimize = 'X'.
1592     CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
1593       EXPORTING
1594         it_fieldcat             = it_fieldcat
1595         it_events               = it_events[]
1596         i_callback_program      = sy-repid
1597         is_layout               = gs_layout
1598         it_sort                 = gt_sort[]
1599         i_save                  = g_save
1600         is_variant              = gx_variant
1601   *     I_CALLBACK_PF_STATUS_SET = 'ZSTATUS'
1602         i_callback_user_command = 'USER_COMMAND'
1603       TABLES
1604         t_outtab                = gt_final[].
1605   * ENDIF.
1606
1607
1608   ENDFORM.
1609
1610   FORM  zstatus USING rt_extab TYPE slis_t_extab.
1611   ***003
1612     SET PF-STATUS 'ZSTATUS'.
1613   ***003
1614   ENDFORM.
1615
1616
1617   FORM user_command USING ucomm TYPE sy-ucomm
1618                           selfield TYPE slis_selfield.
1619     DATA : msgv(100) TYPE c.
1620     CASE ucomm.
1621       WHEN 'POST'.
1622
1623         CLEAR wa_post.
1624         REFRESH : gt_display[].
1625
1626         SELECT SINGLE * FROM zfi_fctr_doc INTO wa_post
1627         WHERE fyear = p_year
1628         AND   fperio = s_period-low
1629         AND   tperio = s_period-high
1630         AND   ind = 'W'
1631         AND   rev = ' '.
1632
1633         IF sy-subrc = 0.
1634           MESSAGE 'Document for Quarter Already posted' TYPE 'I'.
1635         ENDIF.
1636
1637         CHECK sy-subrc NE 0.
1638         gt_wbs[] = gt_final[].
1639         DELETE gt_wbs WHERE  wkgbtr IS INITIAL.
1640         SELECT * FROM zfi_fctr_gl INTO TABLE @DATA(it_wbsgl).
1641
1642         REFRESH : gt_display1.
1643         LOOP AT gt_wbs INTO gs_wbs.
1644           CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
1645             EXPORTING
1646               input  = gs_wbs-hkont
1647             IMPORTING
1648               output = gs_wbs-hkont.
1649
1650
1651           READ TABLE it_wbsgl INTO DATA(wa_wbsgl) WITH KEY osaknr = gs_wbs-hkont.
1652           IF sy-subrc NE 0.
1653   *    wa_accountgl-gl_account = gs_wbs-hkont.
1654   *    CONCATENATE 'Please maintain FCTR G/L against G/L' gs_wbs-hkont INTO msgv SEPARATED BY space.
1655             gs_display1-msgid = 'ZFI1'.
1656             gs_display1-msgty = 'E'.
1657             gs_display1-msgno = '003'.
1658             gs_display1-msgv1 = gs_wbs-hkont.
1659             APPEND gs_display1 TO gt_display1.
1660           ENDIF.
1661
1662
1663         ENDLOOP.
1664
1665         IF gt_display1[] IS INITIAL.
1666
1667           LOOP AT gt_wbs INTO gs_wbs.
1668
1669   *    documentheader-bus_act    = 'RFBU'.
1670             documentheader-username   = sy-uname.
1671             documentheader-comp_code  = gs_wbs-bukrs.
1672             documentheader-doc_date = p_budat.
1673             documentheader-pstng_date = p_budat.
1674             documentheader-doc_type   = 'FY'.
1675             documentheader-header_txt    = 'WBS ADJUSTMENT'.
1676             documentheader-ref_doc_no    = 'WBS ADJUSTMENT'.
1677
1678             counter_bapi = counter_bapi + 1.
1679             wa_accountgl-itemno_acc   = counter_bapi.
1680
1681             CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
1682               EXPORTING
1683                 input  = gs_wbs-hkont
1684               IMPORTING
1685                 output = gs_wbs-hkont.
1686
1687
1688             READ TABLE it_wbsgl INTO wa_wbsgl WITH KEY osaknr = gs_wbs-hkont.
1689             IF sy-subrc = 0.
1690               wa_accountgl-gl_account = wa_wbsgl-asaknr.
1691             ELSE.
1692   *      wa_accountgl-gl_account = gs_wbs-hkont.
1693               CONCATENATE 'Please maintain FCTR G/L against G/L' gs_wbs-hkont INTO msgv SEPARATED BY space.
1694               MESSAGE msgv TYPE 'E'.
1695               EXIT.
1696             ENDIF.
1697
1698             wa_accountgl-item_text = 'WBS ADJUSTMENT'.
1699             wa_accountgl-comp_code  = gs_wbs-bukrs.
1700             wa_accountgl-bus_area   = 'JV'.
1701             wa_accountgl-costcenter = 'OVLJVCP001'.
1702
1703             APPEND wa_accountgl TO it_accountgl.
1704             CLEAR wa_accountgl.
1705
1706   *    IF gs_wbs-WKGBTR lt 0.
1707             wa_currencyamount-itemno_acc  = counter_bapi.
1708             wa_currencyamount-curr_type = '00'.
1709   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1710   *          wa_currencyamount-amt_doccur  = gs_wbs-wkgbtr .
1711             wa_currencyamount-amt_doccur = CONV #( gs_wbs-wkgbtr ).
1712   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1713             wa_currencyamount-currency    = 'USD'.
1714             APPEND wa_currencyamount TO it_currencyamount.
1715             CLEAR : wa_currencyamount.
1716
1717   *      counter_bapi = counter_bapi + 1.
1718             wa_currencyamount-itemno_acc  = counter_bapi.
1719             wa_currencyamount-curr_type = '10'.
1720   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1721   *          wa_currencyamount-amt_doccur  = gs_wbs-wogbtr .
1722             wa_currencyamount-amt_doccur = CONV #( gs_wbs-wogbtr ).
1723   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1724             wa_currencyamount-currency = 'INR'.
1725             APPEND wa_currencyamount TO it_currencyamount.
1726             CLEAR : wa_currencyamount.
1727   *      else.
1728   *         wa_currencyamount-itemno_acc  = counter_bapi.
1729   *      wa_currencyamount-curr_type = '00'.
1730   *      wa_currencyamount-amt_doccur  = gs_wbs-WKGBTR .
1731   *      wa_currencyamount-currency    = 'USD'.
1732   *      APPEND wa_currencyamount TO it_currencyamount.
1733   *      CLEAR : wa_currencyamount.
1734   *
1735   **      counter_bapi = counter_bapi + 1.
1736   *      wa_currencyamount-itemno_acc  = counter_bapi.
1737   *      wa_currencyamount-curr_type = '10'.
1738   *      wa_currencyamount-amt_doccur  = gs_wbs-WOGBTR .
1739   *      wa_currencyamount-currency = 'INR'.
1740   *      APPEND wa_currencyamount TO it_currencyamount.
1741   *      CLEAR : wa_currencyamount.
1742   *
1743   *    ENDIF.
1744           ENDLOOP.
1745
1746           " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
1747           CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'  "#EC CI_USAGE_OK
1748               "#EC CI_USAGE_OK[2628704]
1749     "#EC CI_USAGE_OK[2438131]
1750
1751             " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
1752             EXPORTING
1753               documentheader = documentheader
1754             IMPORTING
1755               obj_type       = obj_type
1756               obj_key        = obj_key
1757               obj_sys        = obj_sys
1758             TABLES
1759               accountgl      = it_accountgl[]
1760               currencyamount = it_currencyamount[]
1761   *           accountreceivable = accountreceivable[]
1762   *           accountpayable = accountpayable[]
1763               return         = return[].
1764
1765           READ TABLE return WITH KEY type = 'E'.
1766           IF sy-subrc = 0.
1767             LOOP AT return WHERE type = 'E'.
1768
1769               gs_display-msgid = return-id.
1770               gs_display-msgty = return-type.
1771               gs_display-msgno = return-number.
1772               gs_display-msgv1 = return-message_v1.
1773               gs_display-msgv2 = return-message_v2.
1774               gs_display-msgv3 = return-message_v3.
1775               gs_display-msgv4 = return-message_v4.
1776               APPEND gs_display TO gt_display.
1777               CLEAR : gs_display.
1778
1779
1780             ENDLOOP.
1781           ELSE.
1782             LOOP AT return .
1783
1784               gs_display-msgid = return-id.
1785               gs_display-msgty = return-type.
1786               gs_display-msgno = return-number.
1787               gs_display-msgv1 = return-message_v1.
1788               gs_display-msgv2 = return-message_v2.
1789               gs_display-msgv3 = return-message_v3.
1790               gs_display-msgv4 = return-message_v4.
1791               APPEND gs_display TO gt_display.
1792               CLEAR : gs_display.
1793
1794             ENDLOOP.
1795             CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
1796
1797             wa_post-fyear = p_year.
1798             wa_post-fperio = s_period-low.
1799             wa_post-tperio = s_period-high.
1800             wa_post-ind    = 'W'.
1801             wa_post-bukrs  = obj_key+10(3).
1802             wa_post-belnr  = obj_key+0(10).
1803             wa_post-gjahr  = obj_key+14(4).
1804   *              REV
1805             MODIFY zfi_fctr_doc FROM wa_post.
1806
1807
1808
1809           ENDIF.
1810
1811           CALL FUNCTION 'C14Z_MESSAGES_SHOW_AS_POPUP'
1812   *            EXPORTING
1813   *              i_lineno      = l_v_lines
1814             TABLES
1815               i_message_tab = gt_display.
1816
1817           REFRESH: return,
1818                  accountgl,
1819                  currencyamount,
1820                  accountreceivable,
1821                  accountpayable,
1822                  gt_display[].
1823   *         documentheader.
1824
1825           CLEAR:   return,
1826                    accountgl,
1827                    currencyamount,
1828                    accountreceivable,
1829                    accountpayable,
1830                    documentheader,
1831                    obj_type,
1832                    obj_sys,
1833                    counter_bapi,
1834                    obj_key,
1835                    it_accountgl,
1836                    it_currencyamount,
1837                    it_accountgl[],
1838                    it_currencyamount[].
1839   *           gt_display.
1840
1841         ELSE.
1842           CALL FUNCTION 'C14Z_MESSAGES_SHOW_AS_POPUP'
1843   *            EXPORTING
1844   *              i_lineno      = l_v_lines
1845             TABLES
1846               i_message_tab = gt_display1.
1847
1848
1849         ENDIF.
1850
1851       WHEN 'CPOST'.
1852
1853         CLEAR wa_post.
1854         REFRESH : gt_display[].
1855
1856         SELECT SINGLE * FROM zfi_fctr_doc INTO wa_post
1857           WHERE fyear = p_year
1858           AND   fperio = s_period-low
1859           AND   tperio = s_period-high
1860           AND   ind = 'C'
1861           AND   rev = ' '.
1862
1863         IF sy-subrc = 0.
1864           MESSAGE 'Document for Quarter Already posted' TYPE 'I'.
1865         ENDIF.
1866
1867         CHECK sy-subrc NE 0.
1868
1869         gt_wbs[] = gt_final[].
1870         IF n = 1.
1871           DELETE gt_wbs WHERE  wkgbtr1 IS INITIAL.
1872         ELSEIF n  = 2     .
1873           DELETE gt_wbs WHERE  wkgbtr1q2 IS INITIAL.
1874         ELSEIF n  = 3     .
1875           DELETE gt_wbs WHERE  wkgbtr1q3 IS INITIAL.
1876         ELSEIF n  = 4     .
1877           DELETE gt_wbs WHERE  wkgbtr1q4 IS INITIAL.
1878         ENDIF.
1879         SELECT * FROM zfi_fctr_gl INTO TABLE it_wbsgl.
1880
1881         REFRESH : gt_display1.
1882         LOOP AT gt_wbs INTO gs_wbs.
1883           CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
1884             EXPORTING
1885               input  = gs_wbs-hkont
1886             IMPORTING
1887               output = gs_wbs-hkont.
1888
1889
1890           READ TABLE it_wbsgl INTO wa_wbsgl WITH KEY osaknr = gs_wbs-hkont.
1891           IF sy-subrc NE 0.
1892   *    wa_accountgl-gl_account = gs_wbs-hkont.
1893             gs_display1-msgid = 'ZFI1'.
1894             gs_display1-msgty = 'E'.
1895             gs_display1-msgno = '003'.
1896             gs_display1-msgv1 = gs_wbs-hkont.
1897             APPEND gs_display1 TO gt_display1.
1898           ENDIF.
1899
1900
1901         ENDLOOP.
1902
1903         IF gt_display1[] IS INITIAL.
1904
1905           LOOP AT gt_wbs INTO gs_wbs.
1906
1907   *    documentheader-bus_act    = 'RFBU'.
1908             documentheader-username   = sy-uname.
1909             documentheader-comp_code  = gs_wbs-bukrs.
1910             documentheader-doc_date = p_budat.
1911             documentheader-pstng_date = p_budat.
1912             documentheader-doc_type   = 'FY'.
1913             documentheader-header_txt    = 'CC ADJUSTMENT'.
1914             documentheader-ref_doc_no    = 'CC ADJUSTMENT'.
1915
1916             counter_bapi = counter_bapi + 1.
1917             wa_accountgl-itemno_acc   = counter_bapi.
1918
1919             CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
1920               EXPORTING
1921                 input  = gs_wbs-hkont
1922               IMPORTING
1923                 output = gs_wbs-hkont.
1924
1925
1926             READ TABLE it_wbsgl INTO wa_wbsgl WITH KEY osaknr = gs_wbs-hkont.
1927             IF sy-subrc = 0.
1928               wa_accountgl-gl_account = wa_wbsgl-asaknr.
1929             ELSE.
1930               CONCATENATE 'Please maintain FCTR G/L against G/L' gs_wbs-hkont INTO msgv SEPARATED BY space.
1931               MESSAGE msgv TYPE 'E'.
1932               EXIT.
1933             ENDIF.
1934
1935             wa_accountgl-item_text = 'CC ADJUSTMENT'.
1936             wa_accountgl-comp_code  = gs_wbs-bukrs.
1937             wa_accountgl-bus_area   = 'JV'.
1938             wa_accountgl-costcenter = 'OVLJVCP001'.
1939
1940             APPEND wa_accountgl TO it_accountgl.
1941             CLEAR wa_accountgl.
1942
1943   *    IF gs_wbs-WKGBTR lt 0.
1944             wa_currencyamount-itemno_acc  = counter_bapi.
1945             wa_currencyamount-curr_type = '00'.
1946             IF n = 1.
1947   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1948   *            wa_currencyamount-amt_doccur  = gs_wbs-wkgbtr1 .
1949               wa_currencyamount-amt_doccur = CONV #( gs_wbs-wkgbtr1 ).
1950   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1951             ELSEIF n = 2.
1952   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1953   *            wa_currencyamount-amt_doccur  = gs_wbs-wkgbtr1q2 .
1954               wa_currencyamount-amt_doccur = CONV #( gs_wbs-wkgbtr1q2 ).
1955   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1956             ELSEIF n = 3.
1957   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1958   *            wa_currencyamount-amt_doccur  = gs_wbs-wkgbtr1q3 .
1959               wa_currencyamount-amt_doccur = CONV #( gs_wbs-wkgbtr1q3 ).
1960   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1961             ELSEIF n = 4.
1962   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1963   *            wa_currencyamount-amt_doccur  = gs_wbs-wkgbtr1q4 .
1964               wa_currencyamount-amt_doccur = CONV #( gs_wbs-wkgbtr1q4 ).
1965   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1966             ENDIF.
1967             wa_currencyamount-currency    = 'USD'.
1968             APPEND wa_currencyamount TO it_currencyamount.
1969             CLEAR : wa_currencyamount.
1970
1971   *      counter_bapi = counter_bapi + 1.
1972             wa_currencyamount-itemno_acc  = counter_bapi.
1973             wa_currencyamount-curr_type = '10'.
1974             IF n = 1.
1975   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1976   *            wa_currencyamount-amt_doccur  = gs_wbs-wogbtr1 .
1977               wa_currencyamount-amt_doccur = CONV #( gs_wbs-wogbtr1 ).
1978   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1979             ELSEIF n = 2.
1980   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1981   *            wa_currencyamount-amt_doccur  = gs_wbs-wogbtr1q2 .
1982               wa_currencyamount-amt_doccur = CONV #( gs_wbs-wogbtr1q2 ).
1983   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1984             ELSEIF n = 3.
1985   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1986   *            wa_currencyamount-amt_doccur  = gs_wbs-wogbtr1q3 .
1987               wa_currencyamount-amt_doccur = CONV #( gs_wbs-wogbtr1q3 ).
1988   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1989             ELSEIF n = 4.
1990   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
1991   *            wa_currencyamount-amt_doccur  = gs_wbs-wogbtr1q4 .
1992               wa_currencyamount-amt_doccur = CONV #( gs_wbs-wogbtr1q4 ).
1993   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
1994             ENDIF.
1995             wa_currencyamount-currency = 'INR'.
1996             APPEND wa_currencyamount TO it_currencyamount.
1997             CLEAR : wa_currencyamount.
1998   *      else.
1999   *         wa_currencyamount-itemno_acc  = counter_bapi.
2000   *      wa_currencyamount-curr_type = '00'.
2001   *      wa_currencyamount-amt_doccur  = gs_wbs-WKGBTR .
2002   *      wa_currencyamount-currency    = 'USD'.
2003   *      APPEND wa_currencyamount TO it_currencyamount.
2004   *      CLEAR : wa_currencyamount.
2005   *
2006   **      counter_bapi = counter_bapi + 1.
2007   *      wa_currencyamount-itemno_acc  = counter_bapi.
2008   *      wa_currencyamount-curr_type = '10'.
2009   *      wa_currencyamount-amt_doccur  = gs_wbs-WOGBTR .
2010   *      wa_currencyamount-currency = 'INR'.
2011   *      APPEND wa_currencyamount TO it_currencyamount.
2012   *      CLEAR : wa_currencyamount.
2013   *
2014   *    ENDIF.
2015           ENDLOOP.
2016
2017           " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
2018           CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'  "#EC CI_USAGE_OK
2019               "#EC CI_USAGE_OK[2628704]
2020     "#EC CI_USAGE_OK[2438131]
2021
2022             " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
2023             EXPORTING
2024               documentheader = documentheader
2025             IMPORTING
2026               obj_type       = obj_type
2027               obj_key        = obj_key
2028               obj_sys        = obj_sys
2029             TABLES
2030               accountgl      = it_accountgl[]
2031               currencyamount = it_currencyamount[]
2032   *           accountreceivable = accountreceivable[]
2033   *           accountpayable = accountpayable[]
2034               return         = return[].
2035
2036           READ TABLE return WITH KEY type = 'E'.
2037           IF sy-subrc = 0.
2038             LOOP AT return WHERE type = 'E'.
2039
2040               gs_display-msgid = return-id.
2041               gs_display-msgty = return-type.
2042               gs_display-msgno = return-number.
2043               gs_display-msgv1 = return-message_v1.
2044               gs_display-msgv2 = return-message_v2.
2045               gs_display-msgv3 = return-message_v3.
2046               gs_display-msgv4 = return-message_v4.
2047               APPEND gs_display TO gt_display.
2048               CLEAR : gs_display.
2049
2050
2051             ENDLOOP.
2052           ELSE.
2053             LOOP AT return .
2054
2055               gs_display-msgid = return-id.
2056               gs_display-msgty = return-type.
2057               gs_display-msgno = return-number.
2058               gs_display-msgv1 = return-message_v1.
2059               gs_display-msgv2 = return-message_v2.
2060               gs_display-msgv3 = return-message_v3.
2061               gs_display-msgv4 = return-message_v4.
2062               APPEND gs_display TO gt_display.
2063               CLEAR : gs_display.
2064
2065             ENDLOOP.
2066             CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
2067
2068             wa_post-fyear = p_year.
2069             wa_post-fperio = s_period-low.
2070             wa_post-tperio = s_period-high.
2071             wa_post-ind    = 'C'.
2072             wa_post-bukrs  = obj_key+10(3).
2073             wa_post-belnr  = obj_key+0(10).
2074             wa_post-gjahr  = obj_key+14(4).
2075   *              REV
2076             MODIFY zfi_fctr_doc FROM wa_post.
2077
2078
2079           ENDIF.
2080
2081           CALL FUNCTION 'C14Z_MESSAGES_SHOW_AS_POPUP'
2082   *            EXPORTING
2083   *              i_lineno      = l_v_lines
2084             TABLES
2085               i_message_tab = gt_display.
2086
2087           REFRESH: return,
2088                  accountgl,
2089                  currencyamount,
2090                  accountreceivable,
2091                  accountpayable,
2092                  gt_display[].
2093   *         documentheader.
2094
2095           CLEAR:   return,
2096                    accountgl,
2097                    currencyamount,
2098                    accountreceivable,
2099                    accountpayable,
2100                    documentheader,
2101                    obj_type,
2102                    obj_sys,
2103                    counter_bapi,
2104                    obj_key,
2105                    it_accountgl,
2106                    it_currencyamount,
2107                    it_accountgl[],
2108                    it_currencyamount[].
2109   *           gt_display.
2110
2111         ELSE.
2112           CALL FUNCTION 'C14Z_MESSAGES_SHOW_AS_POPUP'
2113   *            EXPORTING
2114   *              i_lineno      = l_v_lines
2115             TABLES
2116               i_message_tab = gt_display1.
2117
2118
2119         ENDIF.
2120
2121       WHEN 'REVERSE'.
2122
2123         CLEAR wa_post.
2124         REFRESH : gt_display[] , gt_display1[].
2125
2126   *   TYPES: BEGIN OF TYPE_DOCUMENT,
2127   *         BELNR TYPE BELNR_D,           " Accounting Document Number
2128   *         BLART TYPE BLART,             " Document Type
2129   *         GLVOR TYPE GLVOR,
2130   *         AWTYP TYPE AWTYP,             " Reference Transaction
2131   *         AWKEY TYPE AWKEY,             " Reference Key
2132   *       END OF TYPE_DOCUMENT.
2133
2134         DATA: wa_REVERSAL LIKE bapiacrev,
2135               wa_document TYPE bkpf,
2136               l_t_return  LIKE TABLE OF bapiret2,
2137               l_S_return  TYPE bapiret2.
2138
2139         SELECT SINGLE * FROM zfi_fctr_doc INTO wa_post
2140         WHERE fyear = p_year
2141         AND   fperio = s_period-low
2142         AND   tperio = s_period-high
2143         AND   ind = 'C'.
2144   *    and   rev = 'X'.
2145
2146   *    CHECK sy-subrc ne 0.
2147         IF wa_post-rev NE 'X'.
2148
2149           gt_wbs[] = gt_final[].
2150           IF n = 1.
2151             DELETE gt_wbs WHERE  wkgbtr1 IS INITIAL.
2152           ELSEIF n  = 2     .
2153             DELETE gt_wbs WHERE  wkgbtr1q2 IS INITIAL.
2154           ELSEIF n  = 3     .
2155             DELETE gt_wbs WHERE  wkgbtr1q3 IS INITIAL.
2156           ELSEIF n  = 4     .
2157             DELETE gt_wbs WHERE  wkgbtr1q4 IS INITIAL.
2158           ENDIF.
2159           SELECT * FROM zfi_fctr_gl INTO TABLE it_wbsgl.
2160
2161           LOOP AT gt_wbs INTO gs_wbs.
2162             CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
2163               EXPORTING
2164                 input  = gs_wbs-hkont
2165               IMPORTING
2166                 output = gs_wbs-hkont.
2167
2168
2169             READ TABLE it_wbsgl INTO wa_wbsgl WITH KEY osaknr = gs_wbs-hkont.
2170             IF sy-subrc NE 0.
2171   *    wa_accountgl-gl_account = gs_wbs-hkont.
2172               gs_display1-msgid = 'ZFI1'.
2173               gs_display1-msgty = 'E'.
2174               gs_display1-msgno = '003'.
2175               gs_display1-msgv1 = gs_wbs-hkont.
2176               APPEND gs_display1 TO gt_display1.
2177             ENDIF.
2178
2179
2180           ENDLOOP.
2181
2182           IF gt_display1[] IS INITIAL .
2183
2184             SELECT SINGLE *
2185           FROM bkpf
2186           INTO wa_document
2187          WHERE bukrs     EQ wa_post-bukrs
2188            AND gjahr     EQ wa_post-gjahr
2189            AND belnr     EQ wa_post-belnr.
2190   *     AND BLART     EQ C_DOC_TYPE_Z
2191   *     AND MONAT     EQ G_S_SELECTION-MONAT
2192   *     AND XREVERSAL EQ SPACE.
2193
2194   *    if  wa_document-XREVERSAL ne space.
2195
2196             MOVE: wa_document-awtyp TO wa_reversal-obj_type,
2197                 wa_document-awkey TO wa_reversal-obj_key,
2198   *          L_LOGICAL_SYS       TO wa_reversal-OBJ_SYS,
2199                 wa_document-awkey TO wa_reversal-obj_key_r,
2200                 wa_document-budat TO wa_reversal-pstng_date,
2201                 wa_document-bukrs TO wa_reversal-comp_code,
2202   *          wa_document-BELNR TO wa_reversal-AC_DOC_NO,
2203                 '01'  TO wa_reversal-reason_rev.
2204
2205             CALL FUNCTION 'BAPI_ACC_DOCUMENT_REV_POST'
2206               EXPORTING
2207                 reversal = wa_REVERSAL
2208                 bus_act  = wa_document-glvor
2209               IMPORTING
2210                 obj_type = obj_type
2211                 obj_key  = obj_key
2212                 obj_sys  = obj_sys
2213               TABLES
2214                 return   = l_t_return.
2215
2216   *     endif.
2217
2218             READ TABLE l_t_return INTO l_s_return WITH KEY type = 'E'.
2219             IF sy-subrc = 0 AND wa_document-xreversal EQ space.
2220               LOOP AT l_t_return INTO l_s_return WHERE type = 'E'.
2221
2222                 gs_display-msgid = l_s_RETURN-id.
2223                 gs_display-msgty = l_s_RETURN-type.
2224                 gs_display-msgno = l_s_RETURN-number.
2225                 gs_display-msgv1 = l_s_RETURN-message_v1.
2226                 gs_display-msgv2 = l_s_RETURN-message_v2.
2227                 gs_display-msgv3 = l_s_RETURN-message_v3.
2228                 gs_display-msgv4 = l_s_RETURN-message_v4.
2229                 APPEND gs_display TO gt_display.
2230                 CLEAR : gs_display.
2231
2232
2233               ENDLOOP.
2234             ELSE.
2235               LOOP AT l_t_return INTO l_s_return.
2236
2237                 gs_display-msgid = l_s_return-id.
2238                 gs_display-msgty = l_s_return-type.
2239                 gs_display-msgno = l_s_return-number.
2240                 gs_display-msgv1 = l_s_return-message_v1.
2241                 gs_display-msgv2 = l_s_return-message_v2.
2242                 gs_display-msgv3 = l_s_return-message_v3.
2243                 gs_display-msgv4 = l_s_return-message_v4.
2244                 APPEND gs_display TO gt_display.
2245                 CLEAR : gs_display.
2246
2247               ENDLOOP.
2248               CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
2249
2250   *              wa_post-FYEAR = p_year.
2251   *              wa_post-FPERIO = s_period-low.
2252   *              wa_post-TPERIO = s_period-high.
2253   *              wa_post-IND    = 'C'.
2254   *              wa_post-BUKRS  = obj_key+10(3).
2255   *              wa_post-BELNR  = obj_key+0(10).
2256   *              wa_post-GJAHR  = obj_key+14(4).
2257   *              REV
2258               UPDATE zfi_fctr_doc  SET rev = 'X'
2259               WHERE bukrs = wa_document-bukrs
2260               AND   belnr = wa_document-belnr
2261               AND   gjahr = wa_document-gjahr.
2262   *           MODIFY ZFI_FCTR_DOC FROM wa_post.
2263
2264
2265
2266               CLEAR: wa_document.
2267               REFRESH : l_t_return.
2268
2269
2270
2271   *if gt_display1[] is INITIAL.
2272
2273
2274               LOOP AT gt_wbs INTO gs_wbs.
2275
2276   *    documentheader-bus_act    = 'RFBU'.
2277                 documentheader-username   = sy-uname.
2278                 documentheader-comp_code  = gs_wbs-bukrs.
2279                 documentheader-doc_date = p_budat.
2280                 documentheader-pstng_date = p_budat.
2281                 documentheader-doc_type   = 'FY'.
2282                 documentheader-header_txt    = 'CC ADJUSTMENT'.
2283                 documentheader-ref_doc_no    = 'CC ADJUSTMENT'.
2284
2285                 counter_bapi = counter_bapi + 1.
2286                 wa_accountgl-itemno_acc   = counter_bapi.
2287
2288                 CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
2289                   EXPORTING
2290                     input  = gs_wbs-hkont
2291                   IMPORTING
2292                     output = gs_wbs-hkont.
2293
2294
2295                 READ TABLE it_wbsgl INTO wa_wbsgl WITH KEY osaknr = gs_wbs-hkont.
2296                 IF sy-subrc = 0.
2297                   wa_accountgl-gl_account = wa_wbsgl-asaknr.
2298                 ELSE.
2299                   CONCATENATE 'Please maintain FCTR G/L against G/L' gs_wbs-hkont INTO msgv SEPARATED BY space.
2300                   MESSAGE msgv TYPE 'E'.
2301                   EXIT.
2302                 ENDIF.
2303
2304                 wa_accountgl-item_text = 'CC ADJUSTMENT'.
2305                 wa_accountgl-comp_code  = gs_wbs-bukrs.
2306                 wa_accountgl-bus_area   = 'JV'.
2307                 wa_accountgl-costcenter = 'OVLJVCP001'.
2308
2309                 APPEND wa_accountgl TO it_accountgl.
2310                 CLEAR wa_accountgl.
2311
2312   *    IF gs_wbs-WKGBTR lt 0.
2313                 wa_currencyamount-itemno_acc  = counter_bapi.
2314                 wa_currencyamount-curr_type = '00'.
2315                 IF n = 1.
2316   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
2317   *                wa_currencyamount-amt_doccur  = gs_wbs-wkgbtr1 .
2318                   wa_currencyamount-amt_doccur = CONV #( gs_wbs-wkgbtr1 ).
2319   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
2320                 ELSEIF n = 2.
2321   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
2322   *                wa_currencyamount-amt_doccur  = gs_wbs-wkgbtr1q2 .
2323                   wa_currencyamount-amt_doccur = CONV #( gs_wbs-wkgbtr1q2 ).
2324   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
2325                 ELSEIF n = 3.
2326   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
2327   *                wa_currencyamount-amt_doccur  = gs_wbs-wkgbtr1q3 .
2328                   wa_currencyamount-amt_doccur = CONV #( gs_wbs-wkgbtr1q3 ).
2329   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
2330                 ELSEIF n = 4.
2331   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
2332   *                wa_currencyamount-amt_doccur  = gs_wbs-wkgbtr1q4 .
2333                   wa_currencyamount-amt_doccur = CONV #( gs_wbs-wkgbtr1q4 ).
2334   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
2335                 ENDIF.
2336                 wa_currencyamount-currency    = 'USD'.
2337                 APPEND wa_currencyamount TO it_currencyamount.
2338                 CLEAR : wa_currencyamount.
2339
2340   *      counter_bapi = counter_bapi + 1.
2341                 wa_currencyamount-itemno_acc  = counter_bapi.
2342                 wa_currencyamount-curr_type = '10'.
2343                 IF n = 1.
2344   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
2345   *                wa_currencyamount-amt_doccur  = gs_wbs-wogbtr1 .
2346                   wa_currencyamount-amt_doccur = CONV #( gs_wbs-wogbtr1 ).
2347   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
2348                 ELSEIF n = 2.
2349   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
2350   *                wa_currencyamount-amt_doccur  = gs_wbs-wogbtr1q2 .
2351                   wa_currencyamount-amt_doccur = CONV #( gs_wbs-wogbtr1q2 ).
2352   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
2353                 ELSEIF n = 3.
2354   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
2355   *                wa_currencyamount-amt_doccur  = gs_wbs-wogbtr1q3 .
2356                   wa_currencyamount-amt_doccur = CONV #( gs_wbs-wogbtr1q3 ).
2357   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
2358                 ELSEIF n = 4.
2359   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
2360   *                wa_currencyamount-amt_doccur  = gs_wbs-wogbtr1q4 .
2361                   wa_currencyamount-amt_doccur = CONV #( gs_wbs-wogbtr1q4 ).
2362   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
2363                 ENDIF.
2364                 wa_currencyamount-currency = 'INR'.
2365                 APPEND wa_currencyamount TO it_currencyamount.
2366                 CLEAR : wa_currencyamount.
2367   *      else.
2368   *         wa_currencyamount-itemno_acc  = counter_bapi.
2369   *      wa_currencyamount-curr_type = '00'.
2370   *      wa_currencyamount-amt_doccur  = gs_wbs-WKGBTR .
2371   *      wa_currencyamount-currency    = 'USD'.
2372   *      APPEND wa_currencyamount TO it_currencyamount.
2373   *      CLEAR : wa_currencyamount.
2374   *
2375   **      counter_bapi = counter_bapi + 1.
2376   *      wa_currencyamount-itemno_acc  = counter_bapi.
2377   *      wa_currencyamount-curr_type = '10'.
2378   *      wa_currencyamount-amt_doccur  = gs_wbs-WOGBTR .
2379   *      wa_currencyamount-currency = 'INR'.
2380   *      APPEND wa_currencyamount TO it_currencyamount.
2381   *      CLEAR : wa_currencyamount.
2382   *
2383   *    ENDIF.
2384               ENDLOOP.
2385
2386               " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
2387               CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'  "#EC CI_USAGE_OK
2388                   "#EC CI_USAGE_OK[2628704]
2389     "#EC CI_USAGE_OK[2438131]
2390
2391                 " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
2392                 EXPORTING
2393                   documentheader = documentheader
2394                 IMPORTING
2395                   obj_type       = obj_type
2396                   obj_key        = obj_key
2397                   obj_sys        = obj_sys
2398                 TABLES
2399                   accountgl      = it_accountgl[]
2400                   currencyamount = it_currencyamount[]
2401   *               accountreceivable = accountreceivable[]
2402   *               accountpayable = accountpayable[]
2403                   return         = return[].
2404
2405               READ TABLE return WITH KEY type = 'E'.
2406               IF sy-subrc = 0.
2407                 LOOP AT return WHERE type = 'E'.
2408
2409                   gs_display-msgid = return-id.
2410                   gs_display-msgty = return-type.
2411                   gs_display-msgno = return-number.
2412                   gs_display-msgv1 = return-message_v1.
2413                   gs_display-msgv2 = return-message_v2.
2414                   gs_display-msgv3 = return-message_v3.
2415                   gs_display-msgv4 = return-message_v4.
2416                   APPEND gs_display TO gt_display.
2417                   CLEAR : gs_display.
2418
2419
2420                 ENDLOOP.
2421               ELSE.
2422                 LOOP AT return .
2423
2424                   gs_display-msgid = return-id.
2425                   gs_display-msgty = return-type.
2426                   gs_display-msgno = return-number.
2427                   gs_display-msgv1 = return-message_v1.
2428                   gs_display-msgv2 = return-message_v2.
2429                   gs_display-msgv3 = return-message_v3.
2430                   gs_display-msgv4 = return-message_v4.
2431                   APPEND gs_display TO gt_display.
2432                   CLEAR : gs_display.
2433
2434                 ENDLOOP.
2435                 CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
2436
2437                 wa_post-fyear = p_year.
2438                 wa_post-fperio = s_period-low.
2439                 wa_post-tperio = s_period-high.
2440                 wa_post-ind    = 'C'.
2441                 wa_post-bukrs  = obj_key+10(3).
2442                 wa_post-belnr  = obj_key+0(10).
2443                 wa_post-gjahr  = obj_key+14(4).
2444   *              REV
2445                 MODIFY zfi_fctr_doc FROM wa_post.
2446
2447
2448               ENDIF.
2449
2450               CALL FUNCTION 'C14Z_MESSAGES_SHOW_AS_POPUP'
2451   *            EXPORTING
2452   *              i_lineno      = l_v_lines
2453                 TABLES
2454                   i_message_tab = gt_display.
2455
2456               REFRESH: return,
2457                      accountgl,
2458                      currencyamount,
2459                      accountreceivable,
2460                      accountpayable,
2461                      gt_display[].
2462   *         documentheader.
2463
2464               CLEAR:   return,
2465                        accountgl,
2466                        currencyamount,
2467                        accountreceivable,
2468                        accountpayable,
2469                        documentheader,
2470                        obj_type,
2471                        obj_sys,
2472                        counter_bapi,
2473                        obj_key,
2474                        it_accountgl,
2475                        it_currencyamount,
2476                        it_accountgl[],
2477                        it_currencyamount[].
2478
2479             ENDIF.
2480
2481           ELSE.
2482             CALL FUNCTION 'C14Z_MESSAGES_SHOW_AS_POPUP'
2483   *      EXPORTING
2484   *        i_lineno      = l_v_lines
2485               TABLES
2486                 i_message_tab = gt_display1.
2487
2488           ENDIF.
2489
2490   *     else.
2491   *         CALL FUNCTION 'C14Z_MESSAGES_SHOW_AS_POPUP'
2492   **            EXPORTING
2493   **              i_lineno      = l_v_lines
2494   *            TABLES
2495   *              i_message_tab = gt_display1.
2496   *
2497         ENDIF.
2498
2499       WHEN 'WREVERSE'.
2500
2501         CLEAR wa_post.
2502         REFRESH : gt_display[] , gt_display1.
2503         SELECT SINGLE * FROM zfi_fctr_doc INTO wa_post
2504         WHERE fyear = p_year
2505         AND   fperio = s_period-low
2506         AND   tperio = s_period-high
2507         AND   ind = 'W'.
2508
2509         IF wa_post-rev NE 'X'.
2510
2511
2512           gt_wbs[] = gt_final[].
2513           DELETE gt_wbs WHERE  wkgbtr IS INITIAL.
2514
2515           SELECT * FROM zfi_fctr_gl INTO TABLE it_wbsgl.
2516
2517           LOOP AT gt_wbs INTO gs_wbs.
2518             CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
2519               EXPORTING
2520                 input  = gs_wbs-hkont
2521               IMPORTING
2522                 output = gs_wbs-hkont.
2523
2524
2525             READ TABLE it_wbsgl INTO wa_wbsgl WITH KEY osaknr = gs_wbs-hkont.
2526             IF sy-subrc NE 0.
2527   *    wa_accountgl-gl_account = gs_wbs-hkont.
2528               gs_display1-msgid = 'ZFI1'.
2529               gs_display1-msgty = 'E'.
2530               gs_display1-msgno = '003'.
2531               gs_display1-msgv1 = gs_wbs-hkont.
2532               APPEND gs_display1 TO gt_display1.
2533             ENDIF.
2534
2535
2536           ENDLOOP.
2537
2538           IF gt_display1[] IS INITIAL.
2539
2540             SELECT SINGLE *
2541             FROM bkpf
2542             INTO wa_document
2543            WHERE bukrs     EQ wa_post-bukrs
2544              AND gjahr     EQ wa_post-gjahr
2545              AND belnr     EQ wa_post-belnr.
2546   *     AND BLART     EQ C_DOC_TYPE_Z
2547   *     AND MONAT     EQ G_S_SELECTION-MONAT
2548   *     AND XREVERSAL EQ SPACE.
2549
2550             MOVE: wa_document-awtyp TO wa_reversal-obj_type,
2551                 wa_document-awkey TO wa_reversal-obj_key,
2552   *          L_LOGICAL_SYS       TO wa_reversal-OBJ_SYS,
2553                 wa_document-awkey TO wa_reversal-obj_key_r,
2554                 wa_document-budat TO wa_reversal-pstng_date,
2555                 wa_document-bukrs TO wa_reversal-comp_code,
2556   *          wa_document-BELNR TO wa_reversal-AC_DOC_NO,
2557                 '01'  TO wa_reversal-reason_rev.
2558
2559             CALL FUNCTION 'BAPI_ACC_DOCUMENT_REV_POST'
2560               EXPORTING
2561                 reversal = wa_REVERSAL
2562                 bus_act  = wa_document-glvor
2563               IMPORTING
2564                 obj_type = obj_type
2565                 obj_key  = obj_key
2566                 obj_sys  = obj_sys
2567               TABLES
2568                 return   = l_t_return.
2569
2570             READ TABLE l_t_return INTO l_s_return WITH KEY type = 'E'.
2571             IF sy-subrc = 0 AND wa_document-xreversal EQ space.
2572               LOOP AT l_t_return INTO l_s_return WHERE type = 'E'.
2573
2574                 gs_display-msgid = l_s_RETURN-id.
2575                 gs_display-msgty = l_s_RETURN-type.
2576                 gs_display-msgno = l_s_RETURN-number.
2577                 gs_display-msgv1 = l_s_RETURN-message_v1.
2578                 gs_display-msgv2 = l_s_RETURN-message_v2.
2579                 gs_display-msgv3 = l_s_RETURN-message_v3.
2580                 gs_display-msgv4 = l_s_RETURN-message_v4.
2581                 APPEND gs_display TO gt_display.
2582                 CLEAR : gs_display.
2583
2584
2585               ENDLOOP.
2586             ELSE.
2587               LOOP AT l_t_return INTO l_s_return.
2588
2589                 gs_display-msgid = l_s_return-id.
2590                 gs_display-msgty = l_s_return-type.
2591                 gs_display-msgno = l_s_return-number.
2592                 gs_display-msgv1 = l_s_return-message_v1.
2593                 gs_display-msgv2 = l_s_return-message_v2.
2594                 gs_display-msgv3 = l_s_return-message_v3.
2595                 gs_display-msgv4 = l_s_return-message_v4.
2596                 APPEND gs_display TO gt_display.
2597                 CLEAR : gs_display.
2598
2599               ENDLOOP.
2600               CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
2601
2602   *              wa_post-FYEAR = p_year.
2603   *              wa_post-FPERIO = s_period-low.
2604   *              wa_post-TPERIO = s_period-high.
2605   *              wa_post-IND    = 'C'.
2606   *              wa_post-BUKRS  = obj_key+10(3).
2607   *              wa_post-BELNR  = obj_key+0(10).
2608   *              wa_post-GJAHR  = obj_key+14(4).
2609   *              REV
2610               UPDATE zfi_fctr_doc  SET rev = 'X'
2611               WHERE bukrs = wa_document-bukrs
2612               AND   belnr = wa_document-belnr
2613               AND   gjahr = wa_document-gjahr.
2614   *           MODIFY ZFI_FCTR_DOC FROM wa_post.
2615
2616
2617               SELECT * FROM zfi_fctr_gl INTO TABLE it_wbsgl.
2618
2619               LOOP AT gt_wbs INTO gs_wbs.
2620
2621   *    documentheader-bus_act    = 'RFBU'.
2622                 documentheader-username   = sy-uname.
2623                 documentheader-comp_code  = gs_wbs-bukrs.
2624                 documentheader-doc_date = p_budat.
2625                 documentheader-pstng_date = p_budat.
2626                 documentheader-doc_type   = 'FY'.
2627                 documentheader-header_txt    = 'WBS ADJUSTMENT'.
2628                 documentheader-ref_doc_no    = 'WBS ADJUSTMENT'.
2629
2630                 counter_bapi = counter_bapi + 1.
2631                 wa_accountgl-itemno_acc   = counter_bapi.
2632
2633                 CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
2634                   EXPORTING
2635                     input  = gs_wbs-hkont
2636                   IMPORTING
2637                     output = gs_wbs-hkont.
2638
2639
2640                 READ TABLE it_wbsgl INTO wa_wbsgl WITH KEY osaknr = gs_wbs-hkont.
2641                 IF sy-subrc = 0.
2642                   wa_accountgl-gl_account = wa_wbsgl-asaknr.
2643                 ELSE.
2644                   CONCATENATE 'Please maintain FCTR G/L against G/L' gs_wbs-hkont INTO msgv SEPARATED BY space.
2645                   MESSAGE msgv TYPE 'E'.
2646                   EXIT.
2647                 ENDIF.
2648
2649                 wa_accountgl-item_text = 'WBS ADJUSTMENT'.
2650                 wa_accountgl-comp_code  = gs_wbs-bukrs.
2651                 wa_accountgl-bus_area   = 'JV'.
2652                 wa_accountgl-costcenter = 'OVLJVCP001'.
2653
2654                 APPEND wa_accountgl TO it_accountgl.
2655                 CLEAR wa_accountgl.
2656
2657   *    IF gs_wbs-WKGBTR lt 0.
2658                 wa_currencyamount-itemno_acc  = counter_bapi.
2659                 wa_currencyamount-curr_type = '00'.
2660   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
2661   *              wa_currencyamount-amt_doccur  = gs_wbs-wkgbtr .
2662                 wa_currencyamount-amt_doccur = CONV #( gs_wbs-wkgbtr ).
2663   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
2664                 wa_currencyamount-currency    = 'USD'.
2665                 APPEND wa_currencyamount TO it_currencyamount.
2666                 CLEAR : wa_currencyamount.
2667
2668   *      counter_bapi = counter_bapi + 1.
2669                 wa_currencyamount-itemno_acc  = counter_bapi.
2670                 wa_currencyamount-curr_type = '10'.
2671   " Code Remediation changes S4 2025_1_P Conversion **BEGIN OF CHANGE BY SAP_ABAP 16.06.2026  for ATC
2672   *              wa_currencyamount-amt_doccur  = gs_wbs-wogbtr .
2673                 wa_currencyamount-amt_doccur = CONV #( gs_wbs-wogbtr ).
2674   " Code Remediation changes S4 2025_1_P Conversion * *END OF CHANGE BY SAP_ABAP 16.06.2026 for ATC
2675                 wa_currencyamount-currency = 'INR'.
2676                 APPEND wa_currencyamount TO it_currencyamount.
2677                 CLEAR : wa_currencyamount.
2678   *      else.
2679   *         wa_currencyamount-itemno_acc  = counter_bapi.
2680   *      wa_currencyamount-curr_type = '00'.
2681   *      wa_currencyamount-amt_doccur  = gs_wbs-WKGBTR .
2682   *      wa_currencyamount-currency    = 'USD'.
2683   *      APPEND wa_currencyamount TO it_currencyamount.
2684   *      CLEAR : wa_currencyamount.
2685   *
2686   **      counter_bapi = counter_bapi + 1.
2687   *      wa_currencyamount-itemno_acc  = counter_bapi.
2688   *      wa_currencyamount-curr_type = '10'.
2689   *      wa_currencyamount-amt_doccur  = gs_wbs-WOGBTR .
2690   *      wa_currencyamount-currency = 'INR'.
2691   *      APPEND wa_currencyamount TO it_currencyamount.
2692   *      CLEAR : wa_currencyamount.
2693   *
2694   *    ENDIF.
2695               ENDLOOP.
2696
2697               " Code Remediation changes S4 2025_1_A Conversion **BEGIN OF CHANGE BY SAP_ABAP 05.06.2026  FOR ATC
2698               CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'  "#EC CI_USAGE_OK
2699                   "#EC CI_USAGE_OK[2628704]
2700     "#EC CI_USAGE_OK[2438131]
2701
2702                 " Code Remediation changes S4 2025_1_A Conversion * *END OF CHANGE BY SAP_ABAP 05.06.2026 FOR ATC
2703                 EXPORTING
2704                   documentheader = documentheader
2705                 IMPORTING
2706                   obj_type       = obj_type
2707                   obj_key        = obj_key
2708                   obj_sys        = obj_sys
2709                 TABLES
2710                   accountgl      = it_accountgl[]
2711                   currencyamount = it_currencyamount[]
2712   *               accountreceivable = accountreceivable[]
2713   *               accountpayable = accountpayable[]
2714                   return         = return[].
2715
2716               READ TABLE return WITH KEY type = 'E'.
2717               IF sy-subrc = 0.
2718                 LOOP AT return WHERE type = 'E'.
2719
2720                   gs_display-msgid = return-id.
2721                   gs_display-msgty = return-type.
2722                   gs_display-msgno = return-number.
2723                   gs_display-msgv1 = return-message_v1.
2724                   gs_display-msgv2 = return-message_v2.
2725                   gs_display-msgv3 = return-message_v3.
2726                   gs_display-msgv4 = return-message_v4.
2727                   APPEND gs_display TO gt_display.
2728                   CLEAR : gs_display.
2729
2730
2731                 ENDLOOP.
2732               ELSE.
2733                 LOOP AT return .
2734
2735                   gs_display-msgid = return-id.
2736                   gs_display-msgty = return-type.
2737                   gs_display-msgno = return-number.
2738                   gs_display-msgv1 = return-message_v1.
2739                   gs_display-msgv2 = return-message_v2.
2740                   gs_display-msgv3 = return-message_v3.
2741                   gs_display-msgv4 = return-message_v4.
2742                   APPEND gs_display TO gt_display.
2743                   CLEAR : gs_display.
2744
2745                 ENDLOOP.
2746                 CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
2747
2748                 wa_post-fyear = p_year.
2749                 wa_post-fperio = s_period-low.
2750                 wa_post-tperio = s_period-high.
2751                 wa_post-ind    = 'W'.
2752                 wa_post-bukrs  = obj_key+10(3).
2753                 wa_post-belnr  = obj_key+0(10).
2754                 wa_post-gjahr  = obj_key+14(4).
2755   *              REV
2756                 MODIFY zfi_fctr_doc FROM wa_post.
2757
2758
2759
2760               ENDIF.
2761
2762               CALL FUNCTION 'C14Z_MESSAGES_SHOW_AS_POPUP'
2763   *            EXPORTING
2764   *              i_lineno      = l_v_lines
2765                 TABLES
2766                   i_message_tab = gt_display.
2767
2768               REFRESH: return,
2769                      accountgl,
2770                      currencyamount,
2771                      accountreceivable,
2772                      accountpayable,
2773                      gt_display[].
2774   *         documentheader.
2775
2776               CLEAR:   return,
2777                        accountgl,
2778                        currencyamount,
2779                        accountreceivable,
2780                        accountpayable,
2781                        documentheader,
2782                        obj_type,
2783                        obj_sys,
2784                        counter_bapi,
2785                        obj_key,
2786                        it_accountgl,
2787                        it_currencyamount,
2788                        it_accountgl[],
2789                        it_currencyamount[].
2790
2791             ENDIF.
2792
2793           ELSE.
2794
2795             CALL FUNCTION 'C14Z_MESSAGES_SHOW_AS_POPUP'
2796   *      EXPORTING
2797   *        i_lineno      = l_v_lines
2798               TABLES
2799                 i_message_tab = gt_display1.
2800
2801           ENDIF.
2802
2803
2804         ENDIF.
2805
2806
2807
2808
2809
2810     ENDCASE.
2811
2812
2813   ENDFORM.
2814   *&---------------------------------------------------------------------*
2815   *&---------------------------------------------------------------------*
2816   *& Form ALV_FIELDCAT_GL
2817   *&---------------------------------------------------------------------*
2818   * text
2819   *----------------------------------------------------------------------*
2820   * --> p1 text
2821   * <-- p2 text
2822   *----------------------------------------------------------------------*
2823   FORM alv_fieldcat_gl .
2824     CLEAR wa_fieldcat.
2825     DATA counter TYPE i.
2826     counter = counter + 1.
2827     wa_fieldcat-col_pos = counter.
2828     wa_fieldcat-fieldname = 'HKONT'.
2829     wa_fieldcat-no_zero = 'X'.
2830     wa_fieldcat-seltext_l = 'GL'.
2831     APPEND wa_fieldcat TO it_fieldcat .
2832     CLEAR wa_fieldcat .
2833   ENDFORM.
2834   *&---------------------------------------------------------------------*
2835   *& Form SUB_COMMENT_BUILD_GL
2836   *&---------------------------------------------------------------------*
2837   * text
2838   *----------------------------------------------------------------------*
2839   * -->P_T_LIST_TOP_OF_PAGE text
2840   *----------------------------------------------------------------------*
2841   FORM sub_comment_build_gl USING p_t_list_top_of_page TYPE slis_t_listheader.
2842     DATA: ls_line TYPE slis_listheader.
2843     DATA: wrk_name TYPE string.
2844     DATA : date TYPE char10.
2845     wrk_name = 'PLEASE MAINTAIN CONVERSION INDICATOR IN ZFI_FCTR'.
2846     CLEAR ls_line.
2847     ls_line-typ = 'H'.
2848     ls_line-info = wrk_name.
2849     APPEND ls_line TO p_t_list_top_of_page.
2850   ENDFORM.
2851   *&---------------------------------------------------------------------*
2852   *& Form top_of_page
2853   *&---------------------------------------------------------------------*
2854   FORM top_of_page1.
2855     CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
2856       EXPORTING
2857         it_list_commentary = t_list_top_of_page.
2858   ENDFORM. "top_of_page
2859   *&---------------------------------------------------------------------*
2860   *& Form ALV_DISPLAY_GL
2861   *&---------------------------------------------------------------------*
2862   * text
2863   *----------------------------------------------------------------------*
2864   * --> p1 text
2865   * <-- p2 text
2866   *----------------------------------------------------------------------*
2867   FORM alv_display_gl .
2868     gs_layout-zebra = 'X'.
2869     gs_layout-detail_popup = 'X'.
2870     gs_layout-detail_initial_lines = 'X'.
2871     gs_layout-colwidth_optimize = 'X'.
2872     CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
2873       EXPORTING
2874         it_fieldcat        = it_fieldcat
2875         it_events          = it_events[]
2876         i_callback_program = sy-repid
2877         is_layout          = gs_layout
2878         it_sort            = gt_sort[]
2879         i_save             = g_save
2880         is_variant         = gx_variant
2881   *     I_CALLBACK_PF_STATUS_SET = 'ZSTATUS1'
2882   *     I_CALLBACK_USER_COMMAND = 'USER_COMMAND1'
2883       TABLES
2884         t_outtab           = gt_saknr[].
2885   ENDFORM.
2886   *&---------------------------------------------------------------------*
2887   *& Form GET_EVENT1
2888   *&---------------------------------------------------------------------*
2889   * text
2890   *----------------------------------------------------------------------*
2891   * --> p1 text
2892   * <-- p2 text
2893   *----------------------------------------------------------------------*
2894   FORM get_event1 .
2895     CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
2896       EXPORTING
2897         i_list_type     = 0
2898       IMPORTING
2899         et_events       = it_events[]
2900       EXCEPTIONS
2901         list_type_wrong = 1
2902         OTHERS          = 2.
2903     IF sy-subrc <> 0.
2904       MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
2905       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
2906     ENDIF.
2907     READ TABLE it_events WITH KEY name = slis_ev_top_of_page
2908     INTO it_events.
2909     IF sy-subrc = 0.
2910       MOVE t_formname_top_of_page TO it_events-form.
2911       APPEND it_events.
2912     ENDIF.
2913   ENDFORM.
2914   *&---------------------------------------------------------------------*
2915   *& Form F_MONTH_HELP1
2916   *&---------------------------------------------------------------------*
2917   * text
2918   *----------------------------------------------------------------------*
2919   * --> p1 text
2920   * <-- p2 text
2921   *----------------------------------------------------------------------*
2922   FORM f_month_help1 .
2923     REFRESH lt_read[].
2924     REFRESH lt_month[].
2925     CONSTANTS: lc_11 TYPE i VALUE 11.
2926     ls_read-fieldname = 'P_YEAR'.
2927     APPEND ls_read TO lt_read.
2928     CALL FUNCTION 'DYNP_VALUES_READ'
2929       EXPORTING
2930         dyname               = sy-cprog
2931         dynumb               = sy-dynnr
2932       TABLES
2933         dynpfields           = lt_read
2934       EXCEPTIONS
2935         invalid_abapworkarea = 1
2936         invalid_dynprofield  = 2
2937         invalid_dynproname   = 3
2938         invalid_dynpronummer = 4
2939         invalid_request      = 5
2940         no_fielddescription  = 6
2941         invalid_parameter    = 7
2942         undefind_error       = 8
2943         double_conversion    = 9
2944         stepl_not_found      = 10
2945         OTHERS               = lc_11 ##FM_SUBRC_OK.
2946     READ TABLE lt_read INTO ls_read INDEX 1.
2947     ls_month-month = '01'.
2948     ls_month-text = 'April' && ls_read-fieldvalue.
2949     APPEND ls_month TO lt_month.
2950     ls_month-month = '02'.
2951     ls_month-text = 'May' && ls_read-fieldvalue.
2952     APPEND ls_month TO lt_month.
2953     ls_month-month = '03'.
2954     ls_month-text = 'June' && ls_read-fieldvalue.
2955     APPEND ls_month TO lt_month.
2956     ls_month-month = '04'.
2957     ls_month-text = 'July' && ls_read-fieldvalue.
2958     APPEND ls_month TO lt_month.
2959     ls_month-month = '05'.
2960     ls_month-text = 'August' && ls_read-fieldvalue.
2961     APPEND ls_month TO lt_month.
2962     ls_month-month = '06'.
2963     ls_month-text = 'September' && ls_read-fieldvalue.
2964     APPEND ls_month TO lt_month.
2965     ls_month-month = '07'.
2966     ls_month-text = 'October' && ls_read-fieldvalue.
2967     APPEND ls_month TO lt_month.
2968     ls_month-month = '08'.
2969     ls_month-text = 'November' && ls_read-fieldvalue.
2970     APPEND ls_month TO lt_month.
2971     ls_month-month = '09'.
2972     ls_month-text = 'December' && ls_read-fieldvalue.
2973     APPEND ls_month TO lt_month.
2974     ls_month-month = '10'.
2975     DATA : year TYPE i.
2976     year = ls_read-fieldvalue + 1.
2977     ls_month-text = 'January'.
2978     APPEND ls_month TO lt_month.
2979     ls_month-month = '11'.
2980   * ls_read-fieldvalue = ls_read-fieldvalue + 1.
2981     ls_month-text = 'February'.
2982     APPEND ls_month TO lt_month.
2983     ls_month-month = '12'.
2984   * ls_read-fieldvalue = ls_read-fieldvalue + 1.
2985     ls_month-text = 'March' .
2986     APPEND ls_month TO lt_month.
2987     ls_month-month = '13'.
2988     ls_month-text = 'Special period 1'.
2989     APPEND ls_month TO lt_month.
2990     ls_month-month = '14'.
2991     ls_month-text = 'Special period 2'.
2992     APPEND ls_month TO lt_month.
2993     ls_month-month = '15'.
2994     ls_month-text = 'Special period 3'.
2995     APPEND ls_month TO lt_month.
2996     ls_month-month = '16'.
2997     ls_month-text = 'Special period 4'.
2998     APPEND ls_month TO lt_month.
2999     CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
3000       EXPORTING
3001         retfield         = 'S_PERIOD'
3002         dynpprog         = sy-repid
3003         dynpnr           = sy-dynnr
3004         dynprofield      = 'S_PERIOD-HIGH'
3005         value_org        = 'S'
3006         callback_program = sy-repid
3007       TABLES
3008         value_tab        = lt_month
3009       EXCEPTIONS
3010         parameter_error  = 1
3011         no_values_found  = 2
3012         OTHERS           = 3 ##FM_SUBRC_OK.
3013   ENDFORM.
3014   *&---------------------------------------------------------------------*
3015   *& Form GET_LOCLAMT
3016   *&---------------------------------------------------------------------*
3017   * text
3018   *----------------------------------------------------------------------*
3019   * --> p1 text
3020   * <-- p2 text
3021   *----------------------------------------------------------------------*
3022   FORM get_loclamt .
3023     IF s_period-low IS NOT INITIAL.
3024       gs_final-hslvt = gs_faglflext-hslvt.
3025       IF s_period-low = '01'.
3026         gs_final-hsl01 = gs_faglflext-hsl01.
3027       ENDIF.
3028     ENDIF.
3029     IF s_period-high IS NOT INITIAL.
3030       IF s_period-high = '01'.
3031       ELSEIF s_period-high = '02'.
3032         gs_final-hsl02 = gs_faglflext-hsl02.
3033       ELSEIF s_period-high = '03'.
3034         gs_final-hsl02 = gs_faglflext-hsl02.
3035         gs_final-hsl03 = gs_faglflext-hsl03.
3036       ELSEIF s_period-high = '04'.
3037         gs_final-hsl02 = gs_faglflext-hsl02.
3038         gs_final-hsl03 = gs_faglflext-hsl03.
3039         gs_final-hsl04 = gs_faglflext-hsl04.
3040       ELSEIF s_period-high = '05'.
3041         gs_final-hsl02 = gs_faglflext-hsl02.
3042         gs_final-hsl03 = gs_faglflext-hsl03.
3043         gs_final-hsl04 = gs_faglflext-hsl04.
3044         gs_final-hsl05 = gs_faglflext-hsl05.
3045       ELSEIF s_period-high = '06'.
3046         gs_final-hsl02 = gs_faglflext-hsl02.
3047         gs_final-hsl03 = gs_faglflext-hsl03.
3048         gs_final-hsl04 = gs_faglflext-hsl04.
3049         gs_final-hsl05 = gs_faglflext-hsl05.
3050         gs_final-hsl06 = gs_faglflext-hsl06.
3051       ELSEIF s_period-high = '07'..
3052         gs_final-hsl02 = gs_faglflext-hsl02.
3053         gs_final-hsl03 = gs_faglflext-hsl03.
3054         gs_final-hsl04 = gs_faglflext-hsl04.
3055         gs_final-hsl05 = gs_faglflext-hsl05.
3056         gs_final-hsl06 = gs_faglflext-hsl06.
3057         gs_final-hsl07 = gs_faglflext-hsl07.
3058       ELSEIF s_period-high = '08'.
3059         gs_final-hsl02 = gs_faglflext-hsl02.
3060         gs_final-hsl03 = gs_faglflext-hsl03.
3061         gs_final-hsl04 = gs_faglflext-hsl04.
3062         gs_final-hsl05 = gs_faglflext-hsl05.
3063         gs_final-hsl06 = gs_faglflext-hsl06.
3064         gs_final-hsl07 = gs_faglflext-hsl07.
3065         gs_final-hsl08 = gs_faglflext-hsl08.
3066       ELSEIF s_period-high = '09'.
3067         gs_final-hsl02 = gs_faglflext-hsl02.
3068         gs_final-hsl03 = gs_faglflext-hsl03.
3069         gs_final-hsl04 = gs_faglflext-hsl04.
3070         gs_final-hsl05 = gs_faglflext-hsl05.
3071         gs_final-hsl06 = gs_faglflext-hsl06.
3072         gs_final-hsl07 = gs_faglflext-hsl07.
3073         gs_final-hsl08 = gs_faglflext-hsl08.
3074         gs_final-hsl09 = gs_faglflext-hsl09.
3075       ELSEIF s_period-high = '10'.
3076         gs_final-hsl02 = gs_faglflext-hsl02.
3077         gs_final-hsl03 = gs_faglflext-hsl03.
3078         gs_final-hsl04 = gs_faglflext-hsl04.
3079         gs_final-hsl05 = gs_faglflext-hsl05.
3080         gs_final-hsl06 = gs_faglflext-hsl06.
3081         gs_final-hsl07 = gs_faglflext-hsl07.
3082         gs_final-hsl08 = gs_faglflext-hsl08.
3083         gs_final-hsl09 = gs_faglflext-hsl09.
3084         gs_final-hsl10 = gs_faglflext-hsl10.
3085       ELSEIF s_period-high = '11'.
3086         gs_final-hsl02 = gs_faglflext-hsl02.
3087         gs_final-hsl03 = gs_faglflext-hsl03.
3088         gs_final-hsl04 = gs_faglflext-hsl04.
3089         gs_final-hsl05 = gs_faglflext-hsl05.
3090         gs_final-hsl06 = gs_faglflext-hsl06.
3091         gs_final-hsl07 = gs_faglflext-hsl07.
3092         gs_final-hsl08 = gs_faglflext-hsl08.
3093         gs_final-hsl09 = gs_faglflext-hsl09.
3094         gs_final-hsl10 = gs_faglflext-hsl10.
3095         gs_final-hsl11 = gs_faglflext-hsl11.
3096       ELSEIF s_period-high = '12'.
3097         gs_final-hsl02 = gs_faglflext-hsl02.
3098         gs_final-hsl03 = gs_faglflext-hsl03.
3099         gs_final-hsl04 = gs_faglflext-hsl04.
3100         gs_final-hsl05 = gs_faglflext-hsl05.
3101         gs_final-hsl06 = gs_faglflext-hsl06.
3102         gs_final-hsl07 = gs_faglflext-hsl07.
3103         gs_final-hsl08 = gs_faglflext-hsl08.
3104         gs_final-hsl09 = gs_faglflext-hsl09.
3105         gs_final-hsl10 = gs_faglflext-hsl10.
3106         gs_final-hsl11 = gs_faglflext-hsl11.
3107         gs_final-hsl12 = gs_faglflext-hsl12.
3108       ELSEIF s_period-high = '13'.
3109         gs_final-hsl02 = gs_faglflext-hsl02.
3110         gs_final-hsl03 = gs_faglflext-hsl03.
3111         gs_final-hsl04 = gs_faglflext-hsl04.
3112         gs_final-hsl05 = gs_faglflext-hsl05.
3113         gs_final-hsl06 = gs_faglflext-hsl06.
3114         gs_final-hsl07 = gs_faglflext-hsl07.
3115         gs_final-hsl08 = gs_faglflext-hsl08.
3116         gs_final-hsl09 = gs_faglflext-hsl09.
3117         gs_final-hsl10 = gs_faglflext-hsl10.
3118         gs_final-hsl11 = gs_faglflext-hsl11.
3119         gs_final-hsl12 = gs_faglflext-hsl12.
3120         gs_final-hsl13 = gs_faglflext-hsl13.
3121       ELSEIF s_period-high = '14'.
3122         gs_final-hsl02 = gs_faglflext-hsl02.
3123         gs_final-hsl03 = gs_faglflext-hsl03.
3124         gs_final-hsl04 = gs_faglflext-hsl04.
3125         gs_final-hsl05 = gs_faglflext-hsl05.
3126         gs_final-hsl06 = gs_faglflext-hsl06.
3127         gs_final-hsl07 = gs_faglflext-hsl07.
3128         gs_final-hsl08 = gs_faglflext-hsl08.
3129         gs_final-hsl09 = gs_faglflext-hsl09.
3130         gs_final-hsl10 = gs_faglflext-hsl10.
3131         gs_final-hsl11 = gs_faglflext-hsl11.
3132         gs_final-hsl12 = gs_faglflext-hsl12.
3133         gs_final-hsl13 = gs_faglflext-hsl13.
3134         gs_final-hsl14 = gs_faglflext-hsl14.
3135       ELSEIF s_period-high = '15'.
3136         gs_final-hsl02 = gs_faglflext-hsl02.
3137         gs_final-hsl03 = gs_faglflext-hsl03.
3138         gs_final-hsl04 = gs_faglflext-hsl04.
3139         gs_final-hsl05 = gs_faglflext-hsl05.
3140         gs_final-hsl06 = gs_faglflext-hsl06.
3141         gs_final-hsl07 = gs_faglflext-hsl07.
3142         gs_final-hsl08 = gs_faglflext-hsl08.
3143         gs_final-hsl09 = gs_faglflext-hsl09.
3144         gs_final-hsl10 = gs_faglflext-hsl10.
3145         gs_final-hsl11 = gs_faglflext-hsl11.
3146         gs_final-hsl12 = gs_faglflext-hsl12.
3147         gs_final-hsl13 = gs_faglflext-hsl13.
3148         gs_final-hsl14 = gs_faglflext-hsl14.
3149         gs_final-hsl15 = gs_faglflext-hsl15.
3150       ELSEIF s_period-high = '16'.
3151         gs_final-hsl02 = gs_faglflext-hsl02.
3152         gs_final-hsl03 = gs_faglflext-hsl03.
3153         gs_final-hsl04 = gs_faglflext-hsl04.
3154         gs_final-hsl05 = gs_faglflext-hsl05.
3155         gs_final-hsl06 = gs_faglflext-hsl06.
3156         gs_final-hsl07 = gs_faglflext-hsl07.
3157         gs_final-hsl08 = gs_faglflext-hsl08.
3158         gs_final-hsl09 = gs_faglflext-hsl09.
3159         gs_final-hsl10 = gs_faglflext-hsl10.
3160         gs_final-hsl11 = gs_faglflext-hsl11.
3161         gs_final-hsl12 = gs_faglflext-hsl12.
3162         gs_final-hsl13 = gs_faglflext-hsl13.
3163         gs_final-hsl14 = gs_faglflext-hsl14.
3164         gs_final-hsl15 = gs_faglflext-hsl15.
3165         gs_final-hsl16 = gs_faglflext-hsl16.
3166       ENDIF.
3167     ENDIF.
3168   ENDFORM.
3169   *&---------------------------------------------------------------------*
3170   *& Form GET_USDAMT
3171   *&---------------------------------------------------------------------*
3172   * text
3173   *----------------------------------------------------------------------*
3174   * --> p1 text
3175   * <-- p2 text
3176   *----------------------------------------------------------------------*
3177   FORM get_usdamt .
3178     IF s_period-low IS NOT INITIAL.
3179       gs_final-kslvt = gs_faglflext-kslvt.
3180       IF s_period-low = '01'.
3181         gs_final-ksl01 = gs_faglflext-ksl01.
3182       ENDIF.
3183     ENDIF.
3184     IF s_period-high IS NOT INITIAL.
3185       IF s_period-high = '01'.
3186       ELSEIF s_period-high = '02'.
3187         gs_final-ksl02 = gs_faglflext-ksl02.
3188       ELSEIF s_period-high = '03'.
3189         gs_final-ksl02 = gs_faglflext-ksl02.
3190         gs_final-ksl03 = gs_faglflext-ksl03.
3191       ELSEIF s_period-high = '04'.
3192         gs_final-ksl02 = gs_faglflext-ksl02.
3193         gs_final-ksl03 = gs_faglflext-ksl03.
3194         gs_final-ksl04 = gs_faglflext-ksl04.
3195       ELSEIF s_period-high = '05'.
3196         gs_final-ksl02 = gs_faglflext-ksl02.
3197         gs_final-ksl03 = gs_faglflext-ksl03.
3198         gs_final-ksl04 = gs_faglflext-ksl04.
3199         gs_final-ksl05 = gs_faglflext-ksl05.
3200       ELSEIF s_period-high = '06'.
3201         gs_final-ksl02 = gs_faglflext-ksl02.
3202         gs_final-ksl03 = gs_faglflext-ksl03.
3203         gs_final-ksl04 = gs_faglflext-ksl04.
3204         gs_final-ksl05 = gs_faglflext-ksl05.
3205         gs_final-ksl06 = gs_faglflext-ksl06.
3206       ELSEIF s_period-high = '07'..
3207         gs_final-ksl02 = gs_faglflext-ksl02.
3208         gs_final-ksl03 = gs_faglflext-ksl03.
3209         gs_final-ksl04 = gs_faglflext-ksl04.
3210         gs_final-ksl05 = gs_faglflext-ksl05.
3211         gs_final-ksl06 = gs_faglflext-ksl06.
3212         gs_final-ksl07 = gs_faglflext-ksl07.
3213       ELSEIF s_period-high = '08'.
3214         gs_final-ksl02 = gs_faglflext-ksl02.
3215         gs_final-ksl03 = gs_faglflext-ksl03.
3216         gs_final-ksl04 = gs_faglflext-ksl04.
3217         gs_final-ksl05 = gs_faglflext-ksl05.
3218         gs_final-ksl06 = gs_faglflext-ksl06.
3219         gs_final-ksl07 = gs_faglflext-ksl07.
3220         gs_final-ksl08 = gs_faglflext-ksl08.
3221       ELSEIF s_period-high = '09'.
3222         gs_final-ksl02 = gs_faglflext-ksl02.
3223         gs_final-ksl03 = gs_faglflext-ksl03.
3224         gs_final-ksl04 = gs_faglflext-ksl04.
3225         gs_final-ksl05 = gs_faglflext-ksl05.
3226         gs_final-ksl06 = gs_faglflext-ksl06.
3227         gs_final-ksl07 = gs_faglflext-ksl07.
3228         gs_final-ksl08 = gs_faglflext-ksl08.
3229         gs_final-ksl09 = gs_faglflext-ksl09.
3230       ELSEIF s_period-high = '10'.
3231         gs_final-ksl02 = gs_faglflext-ksl02.
3232         gs_final-ksl03 = gs_faglflext-ksl03.
3233         gs_final-ksl04 = gs_faglflext-ksl04.
3234         gs_final-ksl05 = gs_faglflext-ksl05.
3235         gs_final-ksl06 = gs_faglflext-ksl06.
3236         gs_final-ksl07 = gs_faglflext-ksl07.
3237         gs_final-ksl08 = gs_faglflext-ksl08.
3238         gs_final-ksl09 = gs_faglflext-ksl09.
3239         gs_final-ksl10 = gs_faglflext-ksl10.
3240       ELSEIF s_period-high = '11'.
3241         gs_final-ksl02 = gs_faglflext-ksl02.
3242         gs_final-ksl03 = gs_faglflext-ksl03.
3243         gs_final-ksl04 = gs_faglflext-ksl04.
3244         gs_final-ksl05 = gs_faglflext-ksl05.
3245         gs_final-ksl06 = gs_faglflext-ksl06.
3246         gs_final-ksl07 = gs_faglflext-ksl07.
3247         gs_final-ksl08 = gs_faglflext-ksl08.
3248         gs_final-ksl09 = gs_faglflext-ksl09.
3249         gs_final-ksl10 = gs_faglflext-ksl10.
3250         gs_final-ksl11 = gs_faglflext-ksl11.
3251       ELSEIF s_period-high = '12'.
3252         gs_final-ksl02 = gs_faglflext-ksl02.
3253         gs_final-ksl03 = gs_faglflext-ksl03.
3254         gs_final-ksl04 = gs_faglflext-ksl04.
3255         gs_final-ksl05 = gs_faglflext-ksl05.
3256         gs_final-ksl06 = gs_faglflext-ksl06.
3257         gs_final-ksl07 = gs_faglflext-ksl07.
3258         gs_final-ksl08 = gs_faglflext-ksl08.
3259         gs_final-ksl09 = gs_faglflext-ksl09.
3260         gs_final-ksl10 = gs_faglflext-ksl10.
3261         gs_final-ksl11 = gs_faglflext-ksl11.
3262         gs_final-ksl12 = gs_faglflext-ksl12.
3263       ELSEIF s_period-high = '13'.
3264         gs_final-ksl02 = gs_faglflext-ksl02.
3265         gs_final-ksl03 = gs_faglflext-ksl03.
3266         gs_final-ksl04 = gs_faglflext-ksl04.
3267         gs_final-ksl05 = gs_faglflext-ksl05.
3268         gs_final-ksl06 = gs_faglflext-ksl06.
3269         gs_final-ksl07 = gs_faglflext-ksl07.
3270         gs_final-ksl08 = gs_faglflext-ksl08.
3271         gs_final-ksl09 = gs_faglflext-ksl09.
3272         gs_final-ksl10 = gs_faglflext-ksl10.
3273         gs_final-ksl11 = gs_faglflext-ksl11.
3274         gs_final-ksl12 = gs_faglflext-ksl12.
3275         gs_final-ksl13 = gs_faglflext-ksl13.
3276       ELSEIF s_period-high = '14'.
3277         gs_final-ksl02 = gs_faglflext-ksl02.
3278         gs_final-ksl03 = gs_faglflext-ksl03.
3279         gs_final-ksl04 = gs_faglflext-ksl04.
3280         gs_final-ksl05 = gs_faglflext-ksl05.
3281         gs_final-ksl06 = gs_faglflext-ksl06.
3282         gs_final-ksl07 = gs_faglflext-ksl07.
3283         gs_final-ksl08 = gs_faglflext-ksl08.
3284         gs_final-ksl09 = gs_faglflext-ksl09.
3285         gs_final-ksl10 = gs_faglflext-ksl10.
3286         gs_final-ksl11 = gs_faglflext-ksl11.
3287         gs_final-ksl12 = gs_faglflext-ksl12.
3288         gs_final-ksl13 = gs_faglflext-ksl13.
3289         gs_final-ksl14 = gs_faglflext-ksl14.
3290       ELSEIF s_period-high = '15'.
3291         gs_final-ksl02 = gs_faglflext-ksl02.
3292         gs_final-ksl03 = gs_faglflext-ksl03.
3293         gs_final-ksl04 = gs_faglflext-ksl04.
3294         gs_final-ksl05 = gs_faglflext-ksl05.
3295         gs_final-ksl06 = gs_faglflext-ksl06.
3296         gs_final-ksl07 = gs_faglflext-ksl07.
3297         gs_final-ksl08 = gs_faglflext-ksl08.
3298         gs_final-ksl09 = gs_faglflext-ksl09.
3299         gs_final-ksl10 = gs_faglflext-ksl10.
3300         gs_final-ksl11 = gs_faglflext-ksl11.
3301         gs_final-ksl12 = gs_faglflext-ksl12.
3302         gs_final-ksl13 = gs_faglflext-ksl13.
3303         gs_final-ksl14 = gs_faglflext-ksl14.
3304         gs_final-ksl15 = gs_faglflext-ksl15.
3305       ELSEIF s_period-high = '16'.
3306         gs_final-ksl02 = gs_faglflext-ksl02.
3307         gs_final-ksl03 = gs_faglflext-ksl03.
3308         gs_final-ksl04 = gs_faglflext-ksl04.
3309         gs_final-ksl05 = gs_faglflext-ksl05.
3310         gs_final-ksl06 = gs_faglflext-ksl06.
3311         gs_final-ksl07 = gs_faglflext-ksl07.
3312         gs_final-ksl08 = gs_faglflext-ksl08.
3313         gs_final-ksl09 = gs_faglflext-ksl09.
3314         gs_final-ksl10 = gs_faglflext-ksl10.
3315         gs_final-ksl11 = gs_faglflext-ksl11.
3316         gs_final-ksl12 = gs_faglflext-ksl12.
3317         gs_final-ksl13 = gs_faglflext-ksl13.
3318         gs_final-ksl14 = gs_faglflext-ksl14.
3319         gs_final-ksl15 = gs_faglflext-ksl15.
3320         gs_final-ksl16 = gs_faglflext-ksl16.
3321       ENDIF.
3322     ENDIF.
3323   ENDFORM.
3324   FORM get_loclamt1 .
3325     IF s_period-low IS NOT INITIAL.
3326       gs_finaltot-hslvt = gs_faglflext1-hslvt.
3327       IF s_period-low = '01'.
3328         gs_finaltot-hsl01 = gs_faglflext1-hsl01.
3329       ENDIF.
3330     ENDIF.
3331     IF s_period-high IS NOT INITIAL.
3332       IF s_period-high = '01'.
3333       ELSEIF s_period-high = '02'.
3334         gs_finaltot-hsl02 = gs_faglflext1-hsl02.
3335       ELSEIF s_period-high = '03'.
3336         gs_finaltot-hsl02 = gs_faglflext1-hsl02.
3337         gs_finaltot-hsl03 = gs_faglflext1-hsl03.
3338       ELSEIF s_period-high = '04'.
3339         gs_finaltot-hsl02 = gs_faglflext1-hsl02.
3340         gs_finaltot-hsl03 = gs_faglflext1-hsl03.
3341         gs_finaltot-hsl04 = gs_faglflext1-hsl04.
3342       ELSEIF s_period-high = '05'.
3343         gs_finaltot-hsl02 = gs_faglflext1-hsl02.
3344         gs_finaltot-hsl03 = gs_faglflext1-hsl03.
3345         gs_finaltot-hsl04 = gs_faglflext1-hsl04.
3346         gs_finaltot-hsl05 = gs_faglflext1-hsl05.
3347       ELSEIF s_period-high = '06'.
3348         gs_finaltot-hsl02 = gs_faglflext1-hsl02.
3349         gs_finaltot-hsl03 = gs_faglflext1-hsl03.
3350         gs_finaltot-hsl04 = gs_faglflext1-hsl04.
3351         gs_finaltot-hsl05 = gs_faglflext1-hsl05.
3352         gs_finaltot-hsl06 = gs_faglflext1-hsl06.
3353       ELSEIF s_period-high = '07'..
3354         gs_finaltot-hsl02 = gs_faglflext1-hsl02.
3355         gs_finaltot-hsl03 = gs_faglflext1-hsl03.
3356         gs_finaltot-hsl04 = gs_faglflext1-hsl04.
3357         gs_finaltot-hsl05 = gs_faglflext1-hsl05.
3358         gs_finaltot-hsl06 = gs_faglflext1-hsl06.
3359         gs_finaltot-hsl07 = gs_faglflext1-hsl07.
3360       ELSEIF s_period-high = '08'.
3361         gs_finaltot-hsl02 = gs_faglflext1-hsl02.
3362         gs_finaltot-hsl03 = gs_faglflext1-hsl03.
3363         gs_finaltot-hsl04 = gs_faglflext1-hsl04.
3364         gs_finaltot-hsl05 = gs_faglflext1-hsl05.
3365         gs_finaltot-hsl06 = gs_faglflext1-hsl06.
3366         gs_finaltot-hsl07 = gs_faglflext1-hsl07.
3367         gs_finaltot-hsl08 = gs_faglflext1-hsl08.
3368       ELSEIF s_period-high = '09'.
3369         gs_finaltot-hsl02 = gs_faglflext1-hsl02.
3370         gs_finaltot-hsl03 = gs_faglflext1-hsl03.
3371         gs_finaltot-hsl04 = gs_faglflext1-hsl04.
3372         gs_finaltot-hsl05 = gs_faglflext1-hsl05.
3373         gs_finaltot-hsl06 = gs_faglflext1-hsl06.
3374         gs_finaltot-hsl07 = gs_faglflext1-hsl07.
3375         gs_finaltot-hsl08 = gs_faglflext1-hsl08.
3376         gs_finaltot-hsl09 = gs_faglflext1-hsl09.
3377       ELSEIF s_period-high = '10'.
3378         gs_finaltot-hsl02 = gs_faglflext1-hsl02.
3379         gs_finaltot-hsl03 = gs_faglflext1-hsl03.
3380         gs_finaltot-hsl04 = gs_faglflext1-hsl04.
3381         gs_finaltot-hsl05 = gs_faglflext1-hsl05.
3382         gs_finaltot-hsl06 = gs_faglflext1-hsl06.
3383         gs_finaltot-hsl07 = gs_faglflext1-hsl07.
3384         gs_finaltot-hsl08 = gs_faglflext1-hsl08.
3385         gs_finaltot-hsl09 = gs_faglflext1-hsl09.
3386         gs_finaltot-hsl10 = gs_faglflext1-hsl10.
3387       ELSEIF s_period-high = '11'.
3388         gs_finaltot-hsl02 = gs_faglflext1-hsl02.
3389         gs_finaltot-hsl03 = gs_faglflext1-hsl03.
3390         gs_finaltot-hsl04 = gs_faglflext1-hsl04.
3391         gs_finaltot-hsl05 = gs_faglflext1-hsl05.
3392         gs_finaltot-hsl06 = gs_faglflext1-hsl06.
3393         gs_finaltot-hsl07 = gs_faglflext1-hsl07.
3394         gs_finaltot-hsl08 = gs_faglflext1-hsl08.
3395         gs_finaltot-hsl09 = gs_faglflext1-hsl09.
3396         gs_finaltot-hsl10 = gs_faglflext1-hsl10.
3397         gs_finaltot-hsl11 = gs_faglflext1-hsl11.
3398         gs_finaltot-hsl02 = gs_faglflext1-hsl02.
3399         gs_finaltot-hsl03 = gs_faglflext1-hsl03.
3400         gs_finaltot-hsl04 = gs_faglflext1-hsl04.
3401         gs_finaltot-hsl05 = gs_faglflext1-hsl05.
3402         gs_finaltot-hsl06 = gs_faglflext1-hsl06.
3403         gs_finaltot-hsl07 = gs_faglflext1-hsl07.
3404         gs_finaltot-hsl08 = gs_faglflext1-hsl08.
3405         gs_finaltot-hsl09 = gs_faglflext1-hsl09.
3406         gs_finaltot-hsl10 = gs_faglflext1-hsl10.
3407         gs_finaltot-hsl11 = gs_faglflext1-hsl11.
3408         gs_finaltot-hsl12 = gs_faglflext1-hsl12.
3409       ELSEIF s_period-high = '13'.
3410         gs_finaltot-hsl02 = gs_faglflext1-hsl02.
3411         gs_finaltot-hsl03 = gs_faglflext1-hsl03.
3412         gs_finaltot-hsl04 = gs_faglflext1-hsl04.
3413         gs_finaltot-hsl05 = gs_faglflext1-hsl05.
3414         gs_finaltot-hsl06 = gs_faglflext1-hsl06.
3415         gs_finaltot-hsl07 = gs_faglflext1-hsl07.
3416         gs_finaltot-hsl08 = gs_faglflext1-hsl08.
3417         gs_finaltot-hsl09 = gs_faglflext1-hsl09.
3418         gs_finaltot-hsl10 = gs_faglflext1-hsl10.
3419         gs_finaltot-hsl11 = gs_faglflext1-hsl11.
3420         gs_finaltot-hsl12 = gs_faglflext1-hsl12.
3421         gs_finaltot-hsl13 = gs_faglflext1-hsl13.
3422       ELSEIF s_period-high = '14'.
3423         gs_finaltot-hsl02 = gs_faglflext1-hsl02.
3424         gs_finaltot-hsl03 = gs_faglflext1-hsl03.
3425         gs_finaltot-hsl04 = gs_faglflext1-hsl04.
3426         gs_finaltot-hsl05 = gs_faglflext1-hsl05.
3427         gs_finaltot-hsl06 = gs_faglflext1-hsl06.
3428         gs_finaltot-hsl07 = gs_faglflext1-hsl07.
3429         gs_finaltot-hsl08 = gs_faglflext1-hsl08.
3430         gs_finaltot-hsl09 = gs_faglflext1-hsl09.
3431         gs_finaltot-hsl10 = gs_faglflext1-hsl10.
3432         gs_finaltot-hsl11 = gs_faglflext1-hsl11.
3433         gs_finaltot-hsl12 = gs_faglflext1-hsl12.
3434         gs_finaltot-hsl13 = gs_faglflext1-hsl13.
3435         gs_finaltot-hsl14 = gs_faglflext1-hsl14.
3436       ELSEIF s_period-high = '15'.
3437         gs_finaltot-hsl02 = gs_faglflext1-hsl02.
3438         gs_finaltot-hsl03 = gs_faglflext1-hsl03.
3439         gs_finaltot-hsl04 = gs_faglflext1-hsl04.
3440         gs_finaltot-hsl05 = gs_faglflext1-hsl05.
3441         gs_finaltot-hsl06 = gs_faglflext1-hsl06.
3442         gs_finaltot-hsl07 = gs_faglflext1-hsl07.
3443         gs_finaltot-hsl08 = gs_faglflext1-hsl08.
3444         gs_finaltot-hsl09 = gs_faglflext1-hsl09.
3445         gs_finaltot-hsl10 = gs_faglflext1-hsl10.
3446         gs_finaltot-hsl11 = gs_faglflext1-hsl11.
3447         gs_finaltot-hsl12 = gs_faglflext1-hsl12.
3448         gs_finaltot-hsl13 = gs_faglflext1-hsl13.
3449         gs_finaltot-hsl14 = gs_faglflext1-hsl14.
3450         gs_finaltot-hsl15 = gs_faglflext1-hsl15.
3451       ELSEIF s_period-high = '16'.
3452         gs_finaltot-hsl02 = gs_faglflext1-hsl02.
3453         gs_finaltot-hsl03 = gs_faglflext1-hsl03.
3454         gs_finaltot-hsl04 = gs_faglflext1-hsl04.
3455         gs_finaltot-hsl05 = gs_faglflext1-hsl05.
3456         gs_finaltot-hsl06 = gs_faglflext1-hsl06.
3457         gs_finaltot-hsl07 = gs_faglflext1-hsl07.
3458         gs_finaltot-hsl08 = gs_faglflext1-hsl08.
3459         gs_finaltot-hsl09 = gs_faglflext1-hsl09.
3460         gs_finaltot-hsl10 = gs_faglflext1-hsl10.
3461         gs_finaltot-hsl11 = gs_faglflext1-hsl11.
3462         gs_finaltot-hsl12 = gs_faglflext1-hsl12.
3463         gs_finaltot-hsl13 = gs_faglflext1-hsl13.
3464         gs_finaltot-hsl14 = gs_faglflext1-hsl14.
3465         gs_finaltot-hsl15 = gs_faglflext1-hsl15.
3466         gs_finaltot-hsl16 = gs_faglflext1-hsl16.
3467       ENDIF.
3468     ENDIF.
3469   ENDFORM.
3470   *&---------------------------------------------------------------------*
3471   *& Form GET_USD1
3472   *&---------------------------------------------------------------------*
3473   * text
3474   *----------------------------------------------------------------------*
3475   * --> p1 text
3476   * <-- p2 text
3477   *----------------------------------------------------------------------*
3478   FORM get_usd1 .
3479     IF s_period-low IS NOT INITIAL.
3480       gs_finaltot-kslvt = gs_faglflext1-kslvt.
3481       IF s_period-low = '01'.
3482         gs_finaltot-ksl01 = gs_faglflext1-ksl01.
3483       ENDIF.
3484     ENDIF.
3485     IF s_period-high IS NOT INITIAL.
3486       IF s_period-high = '01'.
3487       ELSEIF s_period-high = '02'.
3488         gs_finaltot-ksl02 = gs_faglflext1-ksl02.
3489       ELSEIF s_period-high = '03'.
3490         gs_finaltot-ksl02 = gs_faglflext1-ksl02.
3491         gs_finaltot-ksl03 = gs_faglflext1-ksl03.
3492       ELSEIF s_period-high = '04'.
3493         gs_finaltot-ksl02 = gs_faglflext1-ksl02.
3494         gs_finaltot-ksl03 = gs_faglflext1-ksl03.
3495         gs_finaltot-ksl04 = gs_faglflext1-ksl04.
3496       ELSEIF s_period-high = '05'.
3497         gs_finaltot-ksl02 = gs_faglflext1-ksl02.
3498         gs_finaltot-ksl03 = gs_faglflext1-ksl03.
3499         gs_finaltot-ksl04 = gs_faglflext1-ksl04.
3500         gs_finaltot-ksl05 = gs_faglflext1-ksl05.
3501       ELSEIF s_period-high = '06'.
3502         gs_finaltot-ksl02 = gs_faglflext1-ksl02.
3503         gs_finaltot-ksl03 = gs_faglflext1-ksl03.
3504         gs_finaltot-ksl04 = gs_faglflext1-ksl04.
3505         gs_finaltot-ksl05 = gs_faglflext1-ksl05.
3506         gs_finaltot-ksl06 = gs_faglflext1-ksl06.
3507       ELSEIF s_period-high = '07'..
3508         gs_finaltot-ksl02 = gs_faglflext1-ksl02.
3509         gs_finaltot-ksl03 = gs_faglflext1-ksl03.
3510         gs_finaltot-ksl04 = gs_faglflext1-ksl04.
3511         gs_finaltot-ksl05 = gs_faglflext1-ksl05.
3512         gs_finaltot-ksl06 = gs_faglflext1-ksl06.
3513         gs_finaltot-ksl07 = gs_faglflext1-ksl07.
3514       ELSEIF s_period-high = '08'.
3515         gs_finaltot-ksl02 = gs_faglflext1-ksl02.
3516         gs_finaltot-ksl03 = gs_faglflext1-ksl03.
3517         gs_finaltot-ksl04 = gs_faglflext1-ksl04.
3518         gs_finaltot-ksl05 = gs_faglflext1-ksl05.
3519         gs_finaltot-ksl06 = gs_faglflext1-ksl06.
3520         gs_finaltot-ksl07 = gs_faglflext1-ksl07.
3521         gs_finaltot-ksl08 = gs_faglflext1-ksl08.
3522       ELSEIF s_period-high = '09'.
3523         gs_finaltot-ksl02 = gs_faglflext1-ksl02.
3524         gs_finaltot-ksl03 = gs_faglflext1-ksl03.
3525         gs_finaltot-ksl04 = gs_faglflext1-ksl04.
3526         gs_finaltot-ksl05 = gs_faglflext1-ksl05.
3527         gs_finaltot-ksl06 = gs_faglflext1-ksl06.
3528         gs_finaltot-ksl07 = gs_faglflext1-ksl07.
3529         gs_finaltot-ksl08 = gs_faglflext1-ksl08.
3530         gs_finaltot-ksl09 = gs_faglflext1-ksl09.
3531       ELSEIF s_period-high = '10'.
3532         gs_finaltot-ksl02 = gs_faglflext1-ksl02.
3533         gs_finaltot-ksl03 = gs_faglflext1-ksl03.
3534         gs_finaltot-ksl04 = gs_faglflext1-ksl04.
3535         gs_finaltot-ksl05 = gs_faglflext1-ksl05.
3536         gs_finaltot-ksl06 = gs_faglflext1-ksl06.
3537         gs_finaltot-ksl07 = gs_faglflext1-ksl07.
3538         gs_finaltot-ksl08 = gs_faglflext1-ksl08.
3539         gs_finaltot-ksl09 = gs_faglflext1-ksl09.
3540         gs_finaltot-ksl10 = gs_faglflext1-ksl10.
3541       ELSEIF s_period-high = '11'.
3542         gs_finaltot-ksl02 = gs_faglflext1-ksl02.
3543         gs_finaltot-ksl03 = gs_faglflext1-ksl03.
3544         gs_finaltot-ksl04 = gs_faglflext1-ksl04.
3545         gs_finaltot-ksl05 = gs_faglflext1-ksl05.
3546         gs_finaltot-ksl06 = gs_faglflext1-ksl06.
3547         gs_finaltot-ksl07 = gs_faglflext1-ksl07.
3548         gs_finaltot-ksl08 = gs_faglflext1-ksl08.
3549         gs_finaltot-ksl09 = gs_faglflext1-ksl09.
3550         gs_finaltot-ksl10 = gs_faglflext1-ksl10.
3551         gs_finaltot-ksl11 = gs_faglflext1-ksl11.
3552       ELSEIF s_period-high = '12'.
3553         gs_finaltot-ksl02 = gs_faglflext1-ksl02.
3554         gs_finaltot-ksl03 = gs_faglflext1-ksl03.
3555         gs_finaltot-ksl04 = gs_faglflext1-ksl04.
3556         gs_finaltot-ksl05 = gs_faglflext1-ksl05.
3557         gs_finaltot-ksl06 = gs_faglflext1-ksl06.
3558         gs_finaltot-ksl07 = gs_faglflext1-ksl07.
3559         gs_finaltot-ksl08 = gs_faglflext1-ksl08.
3560         gs_finaltot-ksl09 = gs_faglflext1-ksl09.
3561         gs_finaltot-ksl10 = gs_faglflext1-ksl10.
3562         gs_finaltot-ksl11 = gs_faglflext1-ksl11.
3563         gs_finaltot-ksl12 = gs_faglflext1-ksl12.
3564       ELSEIF s_period-high = '13'.
3565         gs_finaltot-ksl02 = gs_faglflext1-ksl02.
3566         gs_finaltot-ksl03 = gs_faglflext1-ksl03.
3567         gs_finaltot-ksl04 = gs_faglflext1-ksl04.
3568         gs_finaltot-ksl05 = gs_faglflext1-ksl05.
3569         gs_finaltot-ksl06 = gs_faglflext1-ksl06.
3570         gs_finaltot-ksl07 = gs_faglflext1-ksl07.
3571         gs_finaltot-ksl08 = gs_faglflext1-ksl08.
3572         gs_finaltot-ksl09 = gs_faglflext1-ksl09.
3573         gs_finaltot-ksl10 = gs_faglflext1-ksl10.
3574         gs_finaltot-ksl11 = gs_faglflext1-ksl11.
3575         gs_finaltot-ksl12 = gs_faglflext1-ksl12.
3576         gs_finaltot-ksl13 = gs_faglflext1-ksl13.
3577       ELSEIF s_period-high = '14'.
3578         gs_finaltot-ksl02 = gs_faglflext1-ksl02.
3579         gs_finaltot-ksl03 = gs_faglflext1-ksl03.
3580         gs_finaltot-ksl04 = gs_faglflext1-ksl04.
3581         gs_finaltot-ksl05 = gs_faglflext1-ksl05.
3582         gs_finaltot-ksl06 = gs_faglflext1-ksl06.
3583         gs_finaltot-ksl07 = gs_faglflext1-ksl07.
3584         gs_finaltot-ksl08 = gs_faglflext1-ksl08.
3585         gs_finaltot-ksl09 = gs_faglflext1-ksl09.
3586         gs_finaltot-ksl10 = gs_faglflext1-ksl10.
3587         gs_finaltot-ksl11 = gs_faglflext1-ksl11.
3588         gs_finaltot-ksl12 = gs_faglflext1-ksl12.
3589         gs_finaltot-ksl13 = gs_faglflext1-ksl13.
3590         gs_finaltot-ksl14 = gs_faglflext1-ksl14.
3591       ELSEIF s_period-high = '15'.
3592         gs_finaltot-ksl02 = gs_faglflext1-ksl02.
3593         gs_finaltot-ksl03 = gs_faglflext1-ksl03.
3594         gs_finaltot-ksl04 = gs_faglflext1-ksl04.
3595         gs_finaltot-ksl05 = gs_faglflext1-ksl05.
3596         gs_finaltot-ksl06 = gs_faglflext1-ksl06.
3597         gs_finaltot-ksl07 = gs_faglflext1-ksl07.
3598         gs_finaltot-ksl08 = gs_faglflext1-ksl08.
3599         gs_finaltot-ksl09 = gs_faglflext1-ksl09.
3600         gs_finaltot-ksl10 = gs_faglflext1-ksl10.
3601         gs_finaltot-ksl11 = gs_faglflext1-ksl11.
3602         gs_finaltot-ksl12 = gs_faglflext1-ksl12.
3603         gs_finaltot-ksl13 = gs_faglflext1-ksl13.
3604         gs_finaltot-ksl14 = gs_faglflext1-ksl14.
3605         gs_finaltot-ksl15 = gs_faglflext1-ksl15.
3606       ELSEIF s_period-high = '16'.
3607         gs_finaltot-ksl02 = gs_faglflext1-ksl02.
3608         gs_finaltot-ksl03 = gs_faglflext1-ksl03.
3609         gs_finaltot-ksl04 = gs_faglflext1-ksl04.
3610         gs_finaltot-ksl05 = gs_faglflext1-ksl05.
3611         gs_finaltot-ksl06 = gs_faglflext1-ksl06.
3612         gs_finaltot-ksl07 = gs_faglflext1-ksl07.
3613         gs_finaltot-ksl08 = gs_faglflext1-ksl08.
3614         gs_finaltot-ksl09 = gs_faglflext1-ksl09.
3615         gs_finaltot-ksl10 = gs_faglflext1-ksl10.
3616         gs_finaltot-ksl11 = gs_faglflext1-ksl11.
3617         gs_finaltot-ksl12 = gs_faglflext1-ksl12.
3618         gs_finaltot-ksl13 = gs_faglflext1-ksl13.
3619         gs_finaltot-ksl14 = gs_faglflext1-ksl14.
3620         gs_finaltot-ksl15 = gs_faglflext1-ksl15.
3621         gs_finaltot-ksl16 = gs_faglflext1-ksl16.
3622       ENDIF.
3623     ENDIF.
3624   ENDFORM.
3625
3626   *&---------------------------------------------------------------------*
3627   *&      Form  S_KOKR_HELP
3628   *&---------------------------------------------------------------------*
3629   *       text
3630   *----------------------------------------------------------------------*
3631   *  -->  p1        text
3632   *  <--  p2        text
3633   *----------------------------------------------------------------------*
3634   FORM s_kokr_help .
3635
3636   *AT SELECTION-SCREEN ON VALUE-REQUEST FOR S_KOKR-LOW.
3637
3638     SELECT *
3639     FROM tka02
3640     INTO CORRESPONDING FIELDS OF TABLE gt_tka02_1
3641   *  WHERE BUKRS = S_KOKRS.
3642     WHERE bukrs = p_bukrs.
3643
3644     IF gt_tka02_1 IS NOT INITIAL.
3645       SELECT kokrs kostl
3646          FROM csks
3647          INTO TABLE gt_csks
3648          FOR ALL ENTRIES IN gt_tka02_1
3649       WHERE kokrs = gt_tka02_1-kokrs.
3650
3651       IF gt_csks IS   NOT INITIAL.
3652         SORT gt_csks BY kokrs kostl.
3653         DELETE ADJACENT DUPLICATES FROM gt_csks.
3654       ENDIF.
3655     ENDIF.
3656
3657     CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
3658       EXPORTING
3659         retfield        = 'KOSTL'
3660   *     RETFIELD        = 'KOSTL'
3661         dynpprog        = sy-repid
3662         dynpnr          = sy-dynnr "'1000'
3663         dynprofield     = 'S_KOKR'
3664         value_org       = 'S'
3665       TABLES
3666         value_tab       = gt_csks
3667       EXCEPTIONS
3668         parameter_error = 1
3669         no_values_found = 2
3670         OTHERS          = 3.
3671
3672   ENDFORM.
3673   *&---------------------------------------------------------------------*
3674   *&      Form  S_PSPID_HELP
3675   *&---------------------------------------------------------------------*
3676   *       text
3677   *----------------------------------------------------------------------*
3678   *  -->  p1        text
3679   *  <--  p2        text
3680   *----------------------------------------------------------------------*
3681   FORM s_pspid_help .
3682     DATA srch_str(20) TYPE c.
3683     srch_str = 'OV%'.
3684   *  CONCATENATE srch_str '*' INTO srch_str.
3685     SELECT postu post1 poski pspnr posid pspid
3686   *  SELECT POSID PSPID
3687       FROM v_prpmp
3688       INTO TABLE gt_v_prpmp
3689     WHERE pspid LIKE srch_str.
3690
3691
3692     CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
3693       EXPORTING
3694         retfield        = 'PSPID'
3695   *     RETFIELD        = 'KOSTL'
3696         dynpprog        = sy-repid
3697         dynpnr          = sy-dynnr "'1000'
3698         dynprofield     = 'S_PSPID'
3699         value_org       = 'S'
3700       TABLES
3701         value_tab       = gt_v_prpmp
3702       EXCEPTIONS
3703         parameter_error = 1
3704         no_values_found = 2
3705         OTHERS          = 3.
3706
3707
3708   ENDFORM.
*--- End of ZFI_FCTR_RPT_POST_SUB - 3708 lines ---

----------------------------------------------------------------------------------------------------
Generated incl.  %_CABAP                                   Level 1    Page 5
Object           ZFI_FCTR_RPT_POST                         Lines 360
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:09
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
Generated incl.  %_CESP1                                   Level 1    Page 6
Object           ZFI_FCTR_RPT_POST                         Lines 486
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:09
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
Generated incl.  %_CSLIS                                   Level 1    Page 7
Object           ZFI_FCTR_RPT_POST                         Lines 543
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:09
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
Generated incl.  <REPINI>                                  Level 1    Page 8
Object           ZFI_FCTR_RPT_POST                         Lines 23
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:09
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
Generated incl.  <SYSINI>                                  Level 1    Page 9
Object           ZFI_FCTR_RPT_POST                         Lines 28
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:09
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
Generated incl.  <SYSSEL>                                  Level 1    Page 10
Object           ZFI_FCTR_RPT_POST                         Lines 10
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:09
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
Generated incl.  DB__SSEL                                  Level 1    Page 11
Object           ZFI_FCTR_RPT_POST                         Lines 1
System           OCQ / 500   User SAP_ABAP   08.08.2026 15:15:09
----------------------------------------------------------------------------------------------------
1      * INCLUDE DB__SSEL
*--- End of DB__SSEL - 1 lines ---
